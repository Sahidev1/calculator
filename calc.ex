
# Grammar:
# E -> E + E | E - E| (E) | V | (-V)
# V -> INTEGER
defmodule Calc do
  @type op():: :PLUS | :MINUS
  @type delim():: :LPARAN | :RPARAN
  @type literal():: integer()
  @type token():: op() | delim() | literal()

  @type expr()::{:LITERAL,literal()}
  | {op(), expr(), expr()}
  | {op(), expr()}|{}


  def example do
    input = " 1 + 3345 - (41 + 6)  -334   + 2141 - (123 + 5654 - 5)+1"
    buildAST(input)

  end

  def buildAST(input) do
    input = String.replace(input, ~r/\s+/, "")
    input = String.to_charlist(input)
    token = getTokens(input, [])
    IO.inspect(input)
    parse(token, true)
  end

  def isDigit?(c) do
    c >= 48 && c <= 57
  end

  def consume([]) do {nil,[]} end
  def consume(tokens=[toconsume|rest]) do
    {toconsume, rest}
  end


  def consumeSubExpr(tokens=[:RPARAN|rest], subToks) do
    {subToks, rest}
  end
  def consumeSubExpr(tokens=[curr|rest], subToks) do consumeSubExpr(rest,subToks++[curr]) end

  def parse([], _) do nil end
  def parse(tokens, first=true) do
    {tok, tokens} = consume(tokens)
    case tok do
      {:LITERAL, v} ->
        if(tokens != []) do
          {op, tokens} = consume(tokens)
          {op, tok, parse(tokens, false)}
        else
          tok
        end
      :PLUS -> {:ERROR, "invalid token ordering"} #dont allow +k unary
      :MINUS ->
        if(tokens == []) do {:MINUS, 0, tok} else {:MINUS, 0, parse(tokens, true)} end
      :LPARAN ->
        {subToks, tokens} = consumeSubExpr(tokens, [])
        {op, tokens} = consume(tokens)
        {op, parse(subToks, true), parse(tokens, false)}
      true->{:ERROR, "invalid token"}
    end
  end

  def parse(tokens, first=false) do
    {tok, tokens} = consume(tokens)
    case tok do
      {:LITERAL, v} ->
        if(tokens != []) do
          {op, tokens} = consume(tokens)
          {op, tok, parse(tokens, false)}
        else
          tok
        end
      :LPARAN ->
        {subToks, tokens} = consumeSubExpr(tokens, [])
        {op, tokens} = consume(tokens)
        {op, parse(subToks, true), parse(tokens, false)}
      true->{:ERROR, "invalid token"}
    end
  end



  def getTokens(input=[], tokens) do tokens end
  def getTokens(input, tokens) do
    {nextTok, remInput} = scanToken(input, [], false)
    getTokens(remInput, tokens++[nextTok])
  end

  def scanToken([],foundTok, true) do
    {{:LITERAL, String.to_integer(to_string(foundTok))}, []}
  end
  def scanToken([], _, false) do {nil, []} end
  def scanToken(input=[c|rest], foundTok=[], scanningInt=false) do
    cond do
      isDigit?(c)-> scanToken(rest, foundTok++[c], true)
      [c] == '+'-> {:PLUS, rest}
      [c] == '-'-> {:MINUS, rest}
      [c] == '('-> {:LPARAN, rest}
      [c] == ')'-> {:RPARAN, rest}
      true -> {:INVALID, rest}
    end
  end


  def scanToken(input=[c|rest], foundTok, scanningInt=true) do
    cond do
      isDigit?(c)->scanToken(rest, foundTok++[c], true)
      true->{{:LITERAL, String.to_integer(to_string(foundTok))}, input}
    end
  end
end

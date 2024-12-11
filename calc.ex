
# Grammar:
# E -> T + E | T - E | T
# T -> INTEGER | (E) | -T


#steps:
#1) Tokenize input
#2) parse token sequence and build AST
#3 optional) Evaluate AST
defmodule Calc do
  @type op():: :PLUS | :MINUS |:NEGATE
  @type delim():: :LPARAN | :RPARAN
  @type literal():: integer()
  @type token():: op() | delim() | literal()

  @type expr()::{:LITERAL,literal()}
  | {op(), expr(), expr()}
  | {op(), expr()}

  def eval(expr) do
    ast = buildAST(expr)
    evalAST(ast)
  end

  def example do
    input = " 1 + 3345 - (41 + 6)  -334   + 2141 - (123 + 5654 - 5)+1"
    ast = buildAST(input)
    v=evalAST(ast)
    {ast, v}
  end

  def timedRun (expr) do
    {time0, ast} = :timer.tc(fn-> buildAST(expr) end)
    {time1, v} = :timer.tc(fn -> evalAST(ast) end)
    {time0, time1}
  end

  def buildAST(input) do
    input = String.replace(input, ~r/\s+/, "")
    input = String.to_charlist(input)
    tokens = tokenize(input, [])
    {ast,_} = parseE(tokens)
    ast
  end

  def evalAST({:LITERAL, v}) do v end
  def evalAST({:NEGATE, expr}) do -evalAST(expr) end
  def evalAST({:PLUS, left, right}) do evalAST(left) + evalAST(right) end
  def evalAST({:MINUS, left, right}) do evalAST(left) - evalAST(right) end

  def parseE(tokens) do
    {a, tokens} = parseT(tokens)
    {nextTok, tokens} = scanToken(tokens)

    case nextTok do
      :PLUS->
        {b, tokens} = parseT(tokens)
        parseE_prime({:PLUS, a, b}, tokens)
      :MINUS->
        {b, tokens} = parseT(tokens)
        parseE_prime({:MINUS, a, b}, tokens)
      _-> {a, tokens}
    end
  end

  def parseE_prime(a_prime={op, a, b}, tokens) do
    {nextTok, tokens} = scanToken(tokens)

    case nextTok do
      :PLUS ->
        {b, tokens} = parseT(tokens)
        parseE_prime({:PLUS, a_prime, b}, tokens)
      :MINUS ->
        {b, tokens} = parseT(tokens)
        parseE_prime({:MINUS, a_prime, b}, tokens)
      _->{a_prime, tokens}
    end
  end

  def parseT([]) do {nil, []} end
  def parseT(tokens) do
    {a, tokens} = scanToken(tokens)

    case a do
      {:LITERAL, v} -> {a, tokens}
      [_|_] -> #this happens if if we get an expression between LPARAN and RPARAN, this is expression in between
        {res, _} = parseE(a)
        {res, tokens}
      :MINUS->
          {res, tokens} = parseT(tokens)
          {{:NEGATE, res}, tokens}
      _->{{:ERROR, "invalid term "}, tokens}
    end
  end

  def scanToken([]) do consume([]) end
  def scanToken(tokens=[:LPARAN| rest]) do consumeSubExpr(rest, [], []) end
  def scanToken(tokens=[nextTok|rest]) do consume(tokens) end

  def consume([]) do {nil,[]} end
  def consume(tokens=[toconsume|rest]) do {toconsume, rest} end

  def consumeSubExpr(tokens=[:RPARAN|rest], subToks, stack=[]) do {Enum.reverse(subToks), rest} end
  def consumeSubExpr(tokens=[:RPARAN|rest], subToks, stack=[popped|remstack]) do consumeSubExpr(rest, [:RPARAN|subToks], remstack) end
  def consumeSubExpr(tokens=[:LPARAN| rest], subtoks, stack) do consumeSubExpr(rest, [:LPARAN|subtoks], [:LPARAN|stack]) end
  def consumeSubExpr(tokens=[curr|rest], subToks, stack) do consumeSubExpr(rest,[curr|subToks], stack) end

  def tokenize(input=[], tokens) do tokens end
  def tokenize(input, tokens) do
    {nextTok, remInput} = scanInput(input, [], false)
    tokenize(remInput, tokens++[nextTok])
  end

  def scanInput([],foundTok, true) do
    {{:LITERAL, String.to_integer(to_string(foundTok))}, []}
  end
  def scanInput([], _, false) do {nil, []} end
  def scanInput(input=[c|rest], foundTok=[], scanningInt=false) do
    cond do
      isDigit?(c)-> scanInput(rest, foundTok++[c], true)
      [c] == '+'-> {:PLUS, rest}
      [c] == '-'-> {:MINUS, rest}
      [c] == '('-> {:LPARAN, rest}
      [c] == ')'-> {:RPARAN, rest}
      true -> {:INVALID, rest}
    end
  end

  def scanInput(input=[c|rest], foundTok, scanningInt=true) do
    cond do
      isDigit?(c)->scanInput(rest, foundTok++[c], true)
      true->{{:LITERAL, String.to_integer(to_string(foundTok))}, input}
    end
  end

  def isDigit?(c) do
    c >= 48 && c <= 57
  end
end

# Uses higher order function to generape parsers
defmodule Parser do
  def generatePrimeParser(cases, subparser) do
    fun = fn a_prime={op, a, b}, tokens, fself, topself ->
      {nextTok, tokens} = scanToken(tokens)

      if (Enum.any?(cases, fn e -> e == nextTok end)) do
        {b, tokens} = subparser.(tokens, topself)
        fself.({nextTok, a_prime, b}, tokens, fself, topself)
      else
        {a_prime, [nextTok|tokens]}
      end
    end
  end

  def generateParser(cases, isTop?, subparser, primeparser, err) do
    fun = fn tokens, topself ->
      {a, tokens} = subparser.(tokens, topself)
      {nextTok, tokens} = scanToken(tokens)

      topNil? = isTop? && (nextTok == nil)
      if(topNil?) do
        {a, tokens}
      else
        if (Enum.any?(cases, fn e -> e == nextTok end)) do
          {b, tokens} = subparser.(tokens, topself)
          primeparser.({nextTok, a, b}, tokens, primeparser, topself)
        else
          if (isTop?) do
            {err, tokens}
          else
            {a, [nextTok|tokens]}
          end
        end
      end
    end
  end

  def gen_parseE do generateParser([:PLUS, :MINUS], true, gen_parseT, gen_parseE_prime, {:ERROR, "invalid operator token"}) end
  def gen_parseE_prime do generatePrimeParser([:PLUS, :MINUS], gen_parseT) end
  def gen_parseT do generateParser([:MUL, :DIV, :MOD], false, gen_parseP, gen_parseT_prime, {}) end
  def gen_parseT_prime do generatePrimeParser([:MUL, :DIV, :MOD], gen_parseP) end
  def gen_parseP do generateParser([:EXP], false, gen_parseF, gen_parseP_prime, {}) end
  def gen_parseP_prime do generatePrimeParser([:EXP], gen_parseF) end
  def gen_parseF do fn tokens, parseEcpy -> parseF(tokens, parseEcpy) end end

  def parseF([], _) do {nil, []} end
  def parseF(tokens, parseEcpy) do
    {a, tokens} = scanToken(tokens)

    case a do
      {:LITERAL, v} -> {a, tokens}
      [_|_] -> #this happens if if we get an expression between LPARAN and RPARAN, this is expression in between
        {res, _} = parseEcpy.(a, parseEcpy)
        {res, tokens}
      :MINUS->
          {res, tokens} = parseF(tokens, parseEcpy)
          {{:NEGATE, res}, tokens}
      _->{{:ERROR, "invalid term or expression"}, tokens}
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
  def consumeSubExpr([],_,_) do {nil, []} end
end

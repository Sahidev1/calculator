defmodule Parser do

  def generatePrimeParser(cases, subparser) do
    fun = fn a_prime={op, a, b}, tokens, fself ->
      {nextTok, tokens} = scanToken(tokens)

      if (Enum.any?(cases, fn e -> e == nextTok end)) do
        {b, tokens} = subparser.(tokens)
        fself.({nextTok, a_prime, b}, tokens)
      else
        {a_prime, [nextTok|tokens]}
      end
    end

    fn a_prime, tokens -> fun.(a_prime, tokens, fun) end
  end


  def generateParser(cases, isTop?, subparser, primeparser, err) do
    fun = fn tokens ->
      {a, tokens} = subparser.(tokens)
      {nextTok, tokens} = scanToken(tokens)

      topNil? = isTop? && (nextTok == nil)

      if(topNil?) do
        {a, tokens}
      else
        if (Enum.any?(cases, fn e -> e == nextTok end)) do
          {b, tokens} = subparser.(tokens)
          primeparser.({nextTok, a, b}, tokens)
        else
          if (isTop?) do
            err
          else
            {a, [nextTok|tokens]}
        end
      end
    end
  end

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
      nil-> {a, tokens}
      _-> {{:ERROR, "invalid operator token"}, tokens}
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
      _->{a_prime, [nextTok|tokens]}
    end
  end

  def parseT(tokens) do
    {a, tokens} = parseP(tokens)
    {nextTok, tokens} = scanToken(tokens)

    case nextTok do
      :MUL->
        {b, tokens} = parseP(tokens)
        parseT_prime({:MUL, a, b}, tokens)
      :DIV->
        {b, tokens} = parseP(tokens)
        parseT_prime({:DIV, a, b}, tokens)
      :MOD->
        {b, tokens} = parseP(tokens)
        parseT_prime({:MOD, a, b}, tokens)
      _->{a, [nextTok|tokens]}
    end
  end

  def parseT_prime(a_prime={op, a, b},tokens)do
    {nextTok, tokens} = scanToken(tokens)

    case nextTok do
      :MUL ->
        {b, tokens} = parseP(tokens)
        parseT_prime({:MUL, a_prime, b}, tokens)
      :DIV ->
        {b, tokens} = parseP(tokens)
        parseT_prime({:DIV, a_prime, b}, tokens)
      :MOD->
        {b, tokens} = parseP(tokens)
        parseT_prime({:MOD, a_prime, b}, tokens)
      _->{a_prime, [nextTok|tokens]}
    end
  end



  def gen_parseP do generateParser([:EXP], false, gen_parseF, gen_parseP_prime, {}) end
  def gen_parseP_prime do generatePrimeParser([:EXP], gen_parseF) end
  def gen_parseF do fn tokens -> parseF(tokens) end end

  def parseF([]) do {nil, []} end
  def parseF(tokens) do
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
end

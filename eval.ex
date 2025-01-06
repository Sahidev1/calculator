
# Grammar:
# E -> E + T | E - T | T
# T -> T * P | T / P | T % P | P
# P -> P ^ F | F
# F -> INTEGER | (E) | -F


# Non left recursive implementation of grammar:
# E -> TE'
# E' -> (+|-)TE' | ε
# T -> PT'
# T'-> (*|/|%)PT' | ε
# P -> FP'
# P' -> ^FP'
# F -> INTEGER | (E) | -T

# simpler more understandable expression:
# E -> T{(+|-) T | ε} , where E' = {(+|-) T | ε}
# T -> P{(*|/|%) P | ε} , where T' = {(*|/|%) P | ε}
# P -> F{^F | ε}, where P' = {^F | ε}
# F -> INTEGER | (E) | -T


#steps:
#1) Lexer.tokenize input
#2) parse token sequence and build AST
#3 optional) Evaluate AST

Code.require_file("lexer.ex")
Code.require_file("parser.ex")

defmodule Eval do
  @type op():: :EXP |:MUL | :DIV | :MOD |:PLUS | :MINUS |:NEGATE
  @type delim():: :LPARAN | :RPARAN
  @type literal():: integer()
  @type token():: op() | delim() | literal()

  @type expr()::{:LITERAL,literal()}
  | {op(), expr(), expr()}
  | {op(), expr()}


  def eval(expr) do
    ast = buildAST(expr)
    {err?, msg} = evalAST_error_precheck(ast)
    if err? do
      {:ERROR, msg}
    else
      evalAST(ast)
    end
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
    [TIME_UNIT: :MICRO_SECONDS ,ASTBUILD_TIME: time0, EVAL_TIME: time1, EVAL_RESULT: v]
  end

  def buildAST(input) do
    input = String.replace(input, ~r/\s+/, "")
    input = String.to_charlist(input)
    tokens = Lexer.tokenize(input, [])
    parseEfun = Parser.gen_parseE()
    {ast,_} = parseEfun.(tokens, parseEfun)
    ast
  end

  def evalAST_error_precheck({:ERROR, msg}) do {true, msg} end
  def evalAST_error_precheck({:LITERAL, v}) do {false, ""} end
  def evalAST_error_precheck({:NEGATE, expr}) do evalAST_error_precheck(expr) end
  def evalAST_error_precheck({:DIV, _, {:LITERAL, 0}}) do {true, "divide by zero"} end
  def evalAST_error_precheck({op, left, right}) do
    {lcheck,lmsg} = evalAST_error_precheck(left)
    {rcheck,rmsg} = evalAST_error_precheck(right)
    if lcheck do
      {lcheck,lmsg}
    else
      if rcheck do
        {rcheck,rmsg}
      else
        {false, ""}
      end
    end
  end
  def evalAST_error_precheck(tok) do {true, "nil token"} end

  def evalAST(err={:ERROR, msg}) do
    exit(err)
  end
  def evalAST({:LITERAL, v}) do v end
  def evalAST({:NEGATE, expr}) do -evalAST(expr) end
  def evalAST({:PLUS, left, right}) do evalAST(left) + evalAST(right) end
  def evalAST({:MINUS, left, right}) do evalAST(left) - evalAST(right) end
  def evalAST({:MUL, left, right}) do evalAST(left)*evalAST(right) end
  def evalAST({:DIV, left, right}) do div(evalAST(left), evalAST(right)) end
  def evalAST({:MOD, left, right}) do rem(evalAST(left), evalAST(right)) end
  def evalAST({:EXP, left, right}) do evalAST(left) ** evalAST(right) end

end

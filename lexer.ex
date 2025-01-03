
defmodule Lexer do

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
      [c] == '^' -> {:EXP, rest}
      [c] == '*'-> {:MUL, rest}
      [c] == '/'-> {:DIV, rest}
      [c] == '%' -> {:MOD, rest}
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

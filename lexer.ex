
defmodule Lexer do

  def tokenize(input=[], tokens) do Enum.reverse(tokens) end
  def tokenize([?\s| remaining], tokens) do tokenize(remaining, tokens) end
  def tokenize([?\n| remaining], tokens) do tokenize(remaining, tokens) end
  def tokenize([?\r| remaining], tokens) do tokenize(remaining, tokens) end
  def tokenize(input, tokens) do
    {nextTok, remInput} = scanInput(input)
    tokenize(remInput, [nextTok|tokens])
  end


  def scanInput(l=[c|rest]) when c in ?0..?9 do parse_number(l,0) end
  def scanInput([?^|rest]) do {:EXP, rest} end
  def scanInput([?*|rest]) do {:MUL, rest} end
  def scanInput([?/|rest]) do {:DIV, rest} end
  def scanInput([?%|rest]) do {:MOD, rest} end
  def scanInput([?+|rest]) do {:PLUS, rest} end
  def scanInput([?-|rest]) do {:MINUS, rest} end
  def scanInput([?( |rest]) do {:LPARAN, rest} end
  def scanInput([?) |rest]) do {:RPARAN, rest} end
  def scanInput([_|rest]) do {:INVALID, rest} end

  def parse_number([c | rest], acc) when c in ?0..?9 do
    parse_number(rest, acc*10 + (c - ?0))
  end
  def parse_number(input, acc) do
    {{:LITERAL, acc}, input}
  end

end



#charcodes: +(43), -(45), "("(41), ")"(42)
defmodule Basic do
  @type op():: :plus | :minus
  @type expr():: {:literal, integer()}
  |{op(), expr(), expr()}
  |nil

  def parser(rawExpr) do
    data = String.replace(rawExpr, ~r/\s+/, "")
    literals = Regex.scan(~r/[0-9]+/, data)|>Enum.map(fn [e]->
      String.to_integer(e)
    end)
    ops = Regex.scan(~r/\+|\-/, data)|>Enum.map(fn [e] ->
      to_charlist(e)
    end)
    [literals, ops]
  end

  def calculate([a|[b|rest]],[op|rest], s) do

  end

  def example do
    raw = "153 +   1123 - 12 + 1"
    parsed = parser(raw)
  end
end

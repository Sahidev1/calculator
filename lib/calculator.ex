
defmodule Calculator do
  defdelegate main(args\\[]), to: Calculator.Interactive
end

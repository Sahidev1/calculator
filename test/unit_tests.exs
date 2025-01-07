
#Code.require_file("lib/eval.ex")

defmodule Unit_tests do
  use ExUnit.Case, async: true

  describe "test/0" do
    test_cases = [
      {"0",0},
      {"-1", -1},
      {"--1", 1},
      {"---1", -1},
      {"2 + 3", 5},
      {"10 - 4", 6},
      {"3 * 6", 18},
      {"15 / 3", 5},
      {"17 % 5", 2},
      {"2 ^ 3", 8},
      {"2 + 3 * 4", 14},
      {"(2 + 3) * 4", 20},
      {"2 * 3 + 4", 10},
      {"(2 + 3) * (4 + 5)", 45},
      {"2 ^ (3 + 1)", 16},
      {"((15 / 3) + 2) * 3", 21},
      {"10 % (4 + 3)", 3},
      {"2 + 3 + 4 + 5", 14},
      {"2 * 3 * 4 * 5", 120},
      {"(2 + (3 * 4) + (5 - 1))", 18},
      {"2 ^ (3 ^ 2)", 512},
      {"0 + 0", 0},
      {"1 ^ 0", 1},
      {"0 * 99999", 0},
      {"999 % 1", 0},
      {"¤#¤%", {:ERROR, "invalid operator token"}},
      {"1/0", {:ERROR, "divide by zero"}},
      {"a+3", {:ERROR, "invalid term or expression"}},
      {"", {:ERROR, "nil token"}},
      {"1-)(2+3)", {:ERROR, "invalid term or expression"}},
      {"3.434*3.673", Float.round(3.434*3.673, 3)},
      {"45*0.3410", Float.round(45*0.3410, 3)},
      {"34 + 4.5", 38.5},
      {"3.4+ 6.5", 9.9},
      {"1/0.0", {:ERROR, "divide by zero"}},
      {"5/10.0", 0.5},
      {"5%0.3", :RUNTIME_ERROR},
      {"-1^0.5", :RUNTIME_ERROR},
    ]



    for {expression, expected} <- test_cases do
      test "evaluates #{expression}" do
        try do
          result = Calculator.Eval.eval(unquote(expression))
          result = if is_float(result), do: Float.round(result, 3), else: result
          assert result == unquote(expected)
        rescue
          RuntimeError ->
            assert unquote(expected) == :RUNTIME_ERROR
        end
      end
    end
  end

end


Code.require_file("eval.ex")

defmodule Unit_tests do

  def test do
    test_cases = [
      {"0",0},
      {"-1", -1},
      {"--1", 1},
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
      {"a+3", {:ERROR, "invalid term"}},
      {"", {:ERROR, "nil token"}}
    ]



    res=Enum.reduce(test_cases,[0,0,[]] ,fn {expression, expected}, acc=[cases,failed, failStack] ->
      result = Eval.eval(expression)
      if (result == expected) do
        [cases + 1, failed, failStack]
      else
        [cases + 1, failed + 1, [{:FAIL, EXPR: expression, EXPECTED: expected, GOT: result}|failStack]]
      end
    end)
    [cases, fails, stack] = res
    [CASES: cases, FAILS: fails, FAILSTACK: stack]
  end

end


{time, res}=:timer.tc(fn -> Unit_tests.test() end)
IO.inspect([TIME_MICROS: time, TESTRESULT: res])
exit("finished")

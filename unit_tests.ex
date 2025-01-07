
Code.require_file("eval.ex")

defmodule Unit_tests do

  def test do
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



    res=Enum.reduce(test_cases,[0,0,[]] ,fn {expression, expected}, [cases,failed, failStack] ->
      try do
        result = Eval.eval(expression)
        result = if is_float(result) do Float.round(result, 3) else result end
        if (result == expected) do
          [cases + 1, failed, failStack]
        else
          [cases + 1, failed + 1, [{:FAIL, EXPR: expression, EXPECTED: expected, GOT: result}|failStack]]
        end
      rescue _e in RuntimeError ->
        if expected == :RUNTIME_ERROR do
          [cases + 1, failed, failStack]
        else
          [cases + 1, failed + 1, [{:FAIL, EXPR: expression, EXPECTED: expected, GOT: :RUNTIME_ERROR}|failStack]]
        end
      end
    end)
    [cases, fails, stack] = res
    [CASES: cases, FAILS: fails, FAILSTACK: stack]
  end

end


{time, res}=:timer.tc(fn -> Unit_tests.test() end)
IO.inspect([TIME_MICROS: time, TESTRESULT: res])
exit("finished")

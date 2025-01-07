




#Code.require_file("lib/eval.ex")

defmodule Calculator.Interactive do

  def main([]) do
    interactive()
  end

  def interactive do interactive(true) end
  def interactive(true) do
    IO.puts("Enter an expression to evaluate")
    interactive(false)
  end
  def interactive(false) do
    input = IO.gets("")
    if input == "exit\n" or input == "q\n" do
      IO.puts("Exiting")
      :QUIT
    else
      ast = Calculator.Eval.buildAST(input)
      {err?, msg} = Calculator.Eval.evalAST_error_precheck(ast)

      if err? do
        IO.inspect({:ERROR, msg})
      else
        try do
          evalres=Calculator.Eval.evalAST(ast)
          IO.inspect(evalres)
        rescue
          e in RuntimeError -> IO.inspect(e)
          e in ArithmeticError -> IO.inspect(e)
        end
      end

      interactive(false)
    end
  end
end

#Interactive.main()

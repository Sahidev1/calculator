




Code.require_file("eval.ex")

defmodule Interactive do

  def main do
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
      ast = Eval.buildAST(input)
      {err?, msg} = Eval.evalAST_error_precheck(ast)

      if err? do
        IO.inspect({:ERROR, msg})
      else
        try do
          evalres=Eval.evalAST(ast)
          IO.inspect(evalres)
        rescue
          e in RuntimeError -> IO.inspect(e)
        end
      end

      interactive(false)
    end
  end
end

Interactive.main()

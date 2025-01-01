

This is code for an arithmetic calculator, it evaluates arbitrary mathematical expresssions such as "3 + 4 * (5 - 1)". It supports integer addition,subtraction,multiplication,division,modulus and exponentiation.

The calculator consists of a tokenizer, parser and evaluater. The tokenizer creates tokens for the expression. The parser is a recursive decent parser which parses the tokens and builds an abstract syntax tree. The evaluater simply evaluates the abstract syntax tree. 

To run the interactive calculator you need elixir installed. To run it from terminal:
    `iex interactive_calculator.ex`
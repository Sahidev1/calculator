

This is code for an arithmetic calculator, it evaluates arbitrary mathematical expresssions such as "3 + 4 * (5 - 4/2)". It supports integer and decimal addition,subtraction,multiplication,division and exponentiation. It also support integer modulus operation. 

The calculator consists of a tokenizer, parser and evaluater. The tokenizer creates tokens for the expression. The parser is a recursive decent parser which parses the tokens and builds an abstract syntax tree. The evaluater simply evaluates the abstract syntax tree. 

To run the interactive calculator you need elixir installed. To run it from terminal:

    iex interactive_calculator.ex

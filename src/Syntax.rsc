module Syntax

import ParseTree;

extend lang::std::Layout;
extend lang::std::Id;

/*
 * Concrete syntax of QL
 */

start syntax Form 
  = "form" Id name "{" Block* blocks "}"; 

// TODO: question, computed question, block, if-then-else, if-then
syntax Block 
  = Question Statement* statements
  | ComputedQuestion Statement* statements
  | IfBlock
  ;

syntax IfBlock 
  = "if" "(" Expr guard ")" "{" Block* blocks "}" ("else" "{" Block* elseblocks "}")? 
  ;



// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)

syntax Statement = Id identifier ":" Type type ("=" Expr expression)? ;

syntax Expr 
  = var: Id \ Reserved
  | neg: "!" Expr
  > left and: Expr l "&&" Expr r
  > left or : Expr l "||" Expr r
  > left ge : Expr l "\>" Expr r
  > left geq: Expr l "\>=" Expr r
  > left le : Expr l "\<" Expr r
  > left leq: Expr l "\<=" Expr r
  > left eq : Expr l "==" Expr r
  > left neq: Expr l "!=" Expr r
  > left mul: Expr l "*" Expr r
  > left div: Expr!div "/" Expr!div
  > left add: Expr l "+" Expr r
  > left sub: Expr l "-" Expr r
  | bracket "(" Expr ")"
  | Bool boolean
  | Int integer
  | Str string
  ;

  
syntax Type 
  = "string"
  | "integer"
  | "boolean"
  ;

lexical Str = "\"" (![\"])* "\"" ;

lexical Int 
  = [0-9]* ("." [0-9]* ([Ee] "-" [0-9]+)? )? ;

lexical Bool = "true" | "false";

lexical Question = "\"" (![\"])* "?" "\"" ;

lexical ComputedQuestion = "\"" (![\"])* ":" "\"" ;

keyword Reserved
  = "true" | "false";

start[Form] example1()
  = parse(#start[Form], 
  "form myForm {
  '   \"Is this a question?\"
  '     myIdentifier : boolean = truee
  }");

start[Form] example2() 
  = parse(#start[Form], 
  "form myComplexForm {
  '  \"What is your age?\" age: integer
  '  \"Do you like programming?\" programmingInterest: boolean = true
  '  if (programmingInterest) {
  '      \"What is your favorite programming language?\" favoriteLanguage: string
  '  } else {
  '      \"Recommended language:\" recommendedLanguage: string = Python
  '  }
  '  if (age) {
  '      \"Favorite cartoon:\" favoriteCartoon: string
  '  }
  '  \"Calculated field: Your programming score is:\" 
  '      programmingScore: integer = 50
  '}");

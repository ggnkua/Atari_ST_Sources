DEFINITION MODULE PL0Scanner;

FROM Files IMPORT File;

TYPE 
  Symbol = (null, odd, times, div, plus, minus, eql, neq, lss, leq,
  gtr, geq, comma, rparen, then, do, lparen, becomes, number,
  ident, semicolon, end, call, if, while, begin, read, write, const,
  var, procedure, period, eof);
  

VAR
  sym : Symbol;
  id : CARDINAL;
  num : CARDINAL;
  source : File;
  

PROCEDURE Diff(u,v : CARDINAL) : INTEGER;

PROCEDURE KeepId;

PROCEDURE Mark(n : CARDINAL);

PROCEDURE GetSym;

PROCEDURE InitScanner;

PROCEDURE CloseScanner;


END PL0Scanner.


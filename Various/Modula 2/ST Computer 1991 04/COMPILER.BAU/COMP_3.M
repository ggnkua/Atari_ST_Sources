RULE Assign ::= Ident ':=' Expr.
ATTRIBUTION
  Assign.code := Expr.code ++ {Ident.name := Expr.loc;};

RULE Expr ::= Expr '+' Expr.
ATTRIBUTION
  Expr[0].loc := GenerateNewTemp ();
  Expr[0].code := Expr[1].code ++ Expr[2].code
                  ++ IF Expr[0].primode = integer 
                     THEN {Expr[0].loc := add_int (Expr[1].loc, Expr[2].loc);}
                     ELSE {Expr[0].loc := add_real (Expr[1].loc, Expr[2].loc);}
                     END;

RULE Expr ::= Expr '[' Expr ']'.
ATTRIBUTION
  Expr[0].loc := GenerateNewTemp ();
  Expr[0].code := Expr[1].code ++ Expr[2].code
                  ++ {Expr[0].loc := Expr[1].loc[Expr[2].loc];};

RULE Expr ::= Ident.
ATTRIBUTION
  Expr.loc := Ident.name;
  Expr.code := {};


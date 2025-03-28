RULE Assign ::= Ident ':=' Expr.
ATTRIBUTION
  Ident.env := Assign.env;
  Expr.env := Assign.env;
  Ident.primode := LookUpType (Ident.env, Ident.name);
  Ident.postmode := Ident.primode;
  Expr.postmode := Ident.primode;

RULE Expr ::= Expr '+' Expr.
ATTRIBUTION
  Expr[1].env := Expr[0].env;
  Expr[2].env := Expr[0].env;
  Expr[0].primode := IF Expr[1].primode = real OR Expr[2].primode = real
                     THEN real ELSE integer END;
  Expr[1].postmode := Expr[0].primode;
  Expr[2].postmode := Expr[0].primode;
CONDITION
  Coercible (Expr[0].primode, Expr[0].postmode);

RULE Expr ::= Expr '[' Expr ']'.
ATTRIBUTION
  Expr[1].env := Expr[0].env;
  Expr[2].env := Expr[0].env;
  Expr[0].primode := ElemType (Expr[1].primode);
  Expr[1].postmode := Expr[1].primode;
  Expr[2].postmode := IndexType (Expr[1].primode);
CONDITION
  IsArrayType (Expr[1].primode);
  Expr[2].primode = integer;
  Coercible (Expr[0].primode, Expr[0].postmode);

RULE Expr ::= Ident.
ATTRIBUTION
  Expr.primode := LookUpType (Expr.env, Ident.name);
CONDITION
  Coercible (Expr.primode, Expr.postmode);




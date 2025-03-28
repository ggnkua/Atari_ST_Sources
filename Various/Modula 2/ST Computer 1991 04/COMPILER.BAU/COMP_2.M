TYPE    ExprKind = (plus, arrAc, ident);
        TypeKind = (integer, real, array);

        StatTree = POINTER TO StatNode;
        StatNode = RECORD      (*  Assignment  *)
                     lhs: ExprTree;
                     rhs: ExprTree;
                   END;
        
        ExprTree = POINTER TO ExprNode;
        ExprNode = RECORD      (*  Expression  *)
                     CASE kind: ExprKind OF
                       plus  : lhs,
                               rhs : AttrTree|
                       arrAc : arr,
                               idx : AttrTree|
                       ident : name: Symbol|
                     END;
                     pri : TypeTree;
                     post: TypeTree;
                   END;
        
        TypeTree = POINTER TO TypeNode;
        TypeNode = RECORD      (*  Typausdruck  *)
                     CASE kind: TypeKind OF
                       integer: |
                       real   : |
                       array  : elemType: TypeTree;
                                idxType : TypeTree|
                     END;
                   END;
                          

(*  Attributiere eine Zuweisung
 *)
PROCEDURE AttrAssign (tree: StatTree; env: Env);
  BEGIN
    WITH tree^
    DO
      lhs^.pri := LookUpType (env, lhs^.name);
      lhs^.post := lhs^.pri;
      rhs^.post := lhs^.pri;
      AttrExpr1 (rhs, env);
      AttrExpr2 (rhs);
    END;
  END AttrAssign;

(*  Attributiere eine Ausdruck: Erster Durchlauf
 *)
PROCEDURE AttrExpr1 (tree: ExprTree; env: Env);
  BEGIN
    WITH tree^ DO
      CASE kind OF
      
        plus : AttrExpr1 (lhs, env);
               AttrExpr1 (rhs, env);
               IF lhs^.pri^.kind = real
                  OR rhs^.pri^.kind = real
               THEN pri := MakeRealType ();
               ELSE pri := MakeIntType () END|
               
        arrAc: AttrExpr1 (arr, env);
               AttrExpr1 (idx, env);
               pri := ElemType (arr^.pri);
               IF idx^.pri^.kind # integer
                  OR arr^.pri^.kind # array
               THEN RaiseError END|
               
        ident: pri := LookUpType (env, name)|
        
      END;
    END;
  END AttrExpr1;

(*  Attributiere eine Ausdruck: Zweiter Durchlauf
 *)
PROCEDURE AttrExpr2 (tree: ExprTree);
  BEGIN
    WITH tree^ DO
      CASE kind OF
      
        plus : lhs^.post := pri;
               rhs^.post := pri;
               AttrExpr2 (lhs);
               AttrExpr2 (rhs)|
               
        arrAc: arr^.post := arr^.pri;
               idx^.post := IndexType (arr^.pri);
               AttrExpr2 (arr);
               AttrExpr2 (idx)|
               
        ident: |
        
      END;
    IF NOT Coercible (pri, post) THEN RaiseError END
    END;
  END AttrExpr2;

(*  Liefert den Elementtyp eines Arrays.
 *)
PROCEDURE ElemType (type: TypeTree): TypeTree;
  BEGIN
    IF type^.kind # array THEN RaiseError
    ELSE
      RETURN type^.elemType
    END;
  END ElemType;
  
(*  Liefert den Indextyp eines Arrays.
 *)
PROCEDURE IndexType (type: TypeTree): TypeTree;
  BEGIN
    IF type^.kind # array THEN RaiseError
    ELSE
      RETURN type^.idxType
    END;
  END ElemType;
  


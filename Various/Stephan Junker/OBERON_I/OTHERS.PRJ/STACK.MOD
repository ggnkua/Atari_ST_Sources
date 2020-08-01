MODULE Stack; (* generic ADT stack 1.0. By D. Theisen *)

(* You should not use Top or Empty. They are inefficient, *)
(* but complete the Procs.                                *)
(* Use stack^ and (stack=NIL) instead.                    *)

(* Note: Initialize a stack with NIL. Stack points to the *)
(*       top of the stack. NIL, if empty.                 *)

TYPE

  Elem*      = POINTER TO ElemDesc;

  ElemDesc*  = RECORD
                 Next : Elem;
               END(*RECORD*);

  Stack*     = POINTER TO ElemDesc; (* the first element *)

  PROCEDURE (VAR s: Stack) Pop*();
  BEGIN
    IF s#NIL THEN
      s:=s.Next;
    END(*IF*);
  END Pop;

  PROCEDURE (VAR s: Stack) Push*(e:Elem);
  BEGIN
    e.Next:=s;
    s:=e;
  END Push;

  PROCEDURE (s: Stack) Empty*():BOOLEAN;
  (* same as (s=NIL)! *)
  BEGIN
    RETURN s=NIL;
  END Empty;

  PROCEDURE (s: Stack) Top*(): Elem;
  (* same as s! *)
  BEGIN
    RETURN s;
  END Top;

END Stack.
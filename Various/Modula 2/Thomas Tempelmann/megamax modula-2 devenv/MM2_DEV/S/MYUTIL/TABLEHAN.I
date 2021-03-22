(*---------------------------------------------------------------------*)
(*---                     Modul TableHandler                        ---*)
(*---                    --------------------                       ---*)
(*---                                                               ---*)
(*---  Basismodul fuer XREF, aus 4th Edition WIRTH Seite 91         ---*)
(*---                                                               ---*)
(*--- Programmiersprache :  Megamax-Modula-2 fÅr Atari ST           ---*)
(*--- Implementation     :  Uwe A. Ruttkamp, 30.1.89                ---*)
(*--- Portierung         :  Thomas Tempelmann, 4.5.90               ---*)
(*---                                                               ---*)
(*---------------------------------------------------------------------*)

IMPLEMENTATION MODULE TableHandler;

FROM InOut   IMPORT Write, WriteInt, WriteLn;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;

CONST
  TableLength = 3000;

TYPE
  TreePtr = POINTER TO Word;
  ListPtr = POINTER TO Item;

  Item = RECORD
           num  : INTEGER;
           next : ListPtr;
         END;

  Word = RECORD
           key        : INTEGER;   (* table index *)
           first      : ListPtr;   (* list head   *)
           left, right: TreePtr;
         END;

  Table = TreePtr;

VAR
  id    : ARRAY [0..WordLength] OF CHAR;
  ascinx: INTEGER;
  asc   : ARRAY [0..TableLength-1] OF CHAR;

PROCEDURE InitTable (VAR t: Table );
  BEGIN
    ALLOCATE (t, SIZE (Word)); t^.right:= NIL;
  END InitTable;
 
PROCEDURE Search (p: TreePtr): TreePtr;
   (* search node with name equal to id *)
  TYPE
    Relation = (less, equal, greater);
  VAR
    q: TreePtr;
    r: Relation;
    i: INTEGER;
  
  PROCEDURE rel (k: INTEGER ): Relation;
      (* compare id with asc[k] *)
    VAR
      i  : INTEGER;
      R  : Relation;
      x,y: CHAR;
    BEGIN
      i:= 0; R:= equal;
      LOOP
        x:= id[i]; y:= asc[k];
        IF CAP (x) # CAP (y) THEN EXIT END;
        IF x <= " " THEN RETURN R END;
        IF x < y THEN R:= less ELSIF x > y THEN R:= greater END;
        INC (i); INC (k)
      END;
      IF CAP (x) > CAP (y) THEN RETURN greater ELSE RETURN less END
    END rel;
    
  BEGIN
    q:= p^.right;
    r:= greater;
    WHILE q # NIL DO
      p:= q; r:= rel (p^.key);
      IF r = equal THEN RETURN p
      ELSIF r = less THEN q:= p^.left
      ELSE q:= p^.right
      END
    END;
    ALLOCATE (q, SIZE (Word));   (* not found, hence insert *)
    IF q # NIL THEN
      WITH q^ DO
        key:= ascinx; first:= NIL; left:= NIL; right:= NIL
      END;
      IF r = less THEN p^.left:= q ELSE p^.right:= q END;
      i:= 0;   (* copy identifier into asc table *)
      WHILE id[i] > " " DO
        IF ascinx = TableLength THEN
          asc[ascinx]:= " "; id[i]:= " "; overflow:= 1
        ELSE
          asc[ascinx]:= id[i]; INC (ascinx); INC (i)
        END
      END;
      asc[ascinx]:= " "; INC (ascinx)
    END;
    RETURN q
  END Search;
  
PROCEDURE Record (t: Table; VAR x: ARRAY OF CHAR; n: INTEGER);
  VAR
    p: TreePtr;
    q: ListPtr;
    i: INTEGER;
  BEGIN
    i:= 0;
    REPEAT
      id[i]:= x[i]; INC (i)
    UNTIL (id[i-1] = " ") OR (i = WordLength);
    p:= Search (VAL (TreePtr, t) );
    IF p = NIL THEN
      overflow:= 2
    ELSE
      ALLOCATE (q, SIZE (Item));
      IF q = NIL THEN
        overflow:= 3
      ELSE
        q^.num:= n; q^.next:= p^.first; p^.first:= q
      END
    END
  END Record;

PROCEDURE Tabulate (t: Table);
 
  PROCEDURE PrintItem (p: TreePtr);
    CONST
      L = 6;
      N = (LineWidth-WordLength) DIV L;
    VAR
      ch : CHAR;
      i,k: INTEGER;
      q  : ListPtr;
    BEGIN
      i:= WordLength + 1;
      k:= p^.key;
      REPEAT
        ch:= asc[k];
        DEC (i); INC (k); Write (ch)
      UNTIL ch <= " ";
      WHILE i > 0 DO
        Write (" "); DEC (i)
      END;
      q:= p^.first; i:= N;
      WHILE q # NIL DO
        IF i = 0 THEN
          WriteLn; i:= WordLength + 1;
          REPEAT
            Write (" "); DEC (i);
          UNTIL i = 0;
          i:= N;
        END;
        WriteInt (q^.num, L); q:= q^.next; DEC (i)
      END;
      WriteLn;
    END PrintItem;
   
  PROCEDURE TraverseTree (p: TreePtr);
    BEGIN
      IF p # NIL THEN
        TraverseTree (p^.left);
        PrintItem (p);
        TraverseTree (p^.right);
      END;
    END TraverseTree;
   
  BEGIN
    WriteLn;
    TraverseTree (t^.right)
  END Tabulate;
 
PROCEDURE FinishTable (VAR t: Table);
 
  PROCEDURE DeleteList (l: ListPtr);
    BEGIN
      IF l # NIL THEN
        DeleteList (l^.next);
        DEALLOCATE (l, 0);
      END;
    END DeleteList;
 
  PROCEDURE DeleteTree (p: TreePtr);
    BEGIN
      IF p # NIL THEN
        DeleteTree (p^.left);
        DeleteTree (p^.right);
        DeleteList (p^.first);
        DEALLOCATE (p, 0);
      END;
    END DeleteTree;
 
  BEGIN
    DeleteTree (t^.right);
    DEALLOCATE (t, 0);
    t:= NIL;
  END FinishTable;
 
BEGIN
  ascinx:= 0;
  id [WordLength]:= " ";
  overflow:= 0;
END TableHandler.

IMPLEMENTATION MODULE Lists; (* V#031 *)
(*$Y+,R-,N-,H+*)

(*
  Die gehîren nach 'ListsBase':
  -----------------------------
        (*
         * MOS-interne Funktionen
         * ----------------------
         *)
        
        TYPE LCarrRec = ARRAY [1..3] OF ADDRESS;
        
        PROCEDURE LinkIn ( VAR list: List; VAR carr: LCarrRec; entry: ADDRESS );
          (*
           * Wie 'InsertEntry'.
           *)

        PROCEDURE LinkOut ( VAR list: List );
          (*
           * Wie 'RemoveEntry'.
           *)

*)

(*
 * Allgemeine Listenverwaltung.
 *
 * Nach 'ADTLists' aus: Dal Cin, Lutz, Risse: Programmierung in Modula-2.
 *
 * Erstellt 25.3.87, TT
 *
 * 27.08.88  TT  Bei 'releaseLevel' werden die Listen nun richtig freigegeben.
 * 30.09.88  TT  Sys-Funktionen werden nicht autom. bei unterstem Level-Ende
 *               abgemeldet.
 * 25.10.88  TT  CatchRemoval-Aufruf
 * 16.02.89  TT  create setzt 'level' nun korrekt (bisher wurde ein .L statt .W
 *               Zugriff gemacht, was zufolge hatte, daû nachfolgender Speicher
 *               Åberschrieben wurde.
 *)

FROM SYSTEM IMPORT ASSEMBLER;
FROM SYSTEM IMPORT ADDRESS, LONGWORD, ADR, TSIZE;

FROM Storage IMPORT DEALLOCATE;

FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;

IMPORT PrgCtrl, Storage, MOSGlobals;

TYPE    LCarrier = POINTER TO Carrier;
        Carrier  = RECORD
                     next, prev: LCarrier;
                     data: ADDRESS
                   END;
        
        P_Control= POINTER TO Control;
        Control  = RECORD
                     next,prev: P_Control;
                     owner: LCarrier;
                     level: INTEGER
                   END;
(*
        List = RECORD
                 root, current: LCarrier
               END;

        LCondProc = PROCEDURE ( ADDRESS ): BOOLEAN;

        LDir = ( frwd, back );
*)

VAR LRoot: Control;
    Level: INTEGER;

PROCEDURE SysAlloc (VAR ad:LONGWORD; l:LONGCARD);
  (*$L-*)
  BEGIN
    ASSEMBLER
      JMP Storage.SysAlloc
    END
  END SysAlloc;
  (*$L=*)

(*
PROCEDURE LinkIn ( VAR list: List; VAR carr: LCarrRec; entry: ADDRESS );
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D2        ; entry
        MOVE.L  -(A3),A1        ; carr: A1
        MOVE.L  -(A3),A0        ; list: A0
        TST.L   List.root(A0)
        BEQ     ende
        
        MOVE.L  List.current(A0),A2
        MOVE.L  A1,List.current(A0)
        
        MOVE.L  Carrier.next(A2),A0     ; current^.next
        MOVE.L  A0,Carrier.next(A1)
        MOVE.L  A2,Carrier.prev(A1)
        MOVE.L  D2,Carrier.data(A1)
        
        MOVE.L  A1,Carrier.prev(A0)
        MOVE.L  A1,Carrier.next(A2)
      ende:
    END
  END LinkIn;
  (*$L=*)

PROCEDURE LinkOut ( VAR list: List );
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0        ; list: A0
        MOVE.L  List.root(A0),D0
        BEQ     ende
        MOVE.L  List.current(A0),A2
        CMP.L   A2,D0
        BEQ     ende
        MOVE.L  Carrier.prev(A2),List.current(A0)
        MOVE.L  Carrier.next(A2),A1
        MOVE.L  Carrier.prev(A2),A0
        MOVE.L  A0,Carrier.prev(A1)
        MOVE.L  A1,Carrier.next(A0)
      ende:
    END
  END LinkOut;
  (*$L=*)
*)

PROCEDURE InitList ( VAR l: List );
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        CLR.L   (A0)+
        CLR.L   (A0)+
        CLR.L   (A0)
    END
  END InitList;
  (*$L=*)

PROCEDURE ResetList ( VAR list: List );
  (*$L-*)
  BEGIN
    (*
       WITH list DO
         current:= root
       END
    *)
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  List.root(A0),List.current(A0)
    END
  END ResetList;
  (*$L=*)

PROCEDURE create ( VAR list: List; VAR error: BOOLEAN; lev: INTEGER );
  VAR p:P_Control;
  BEGIN
    SysAlloc (p,SIZE (p^));
    SysAlloc (list.root,SIZE (list.root^));
    error:= (list.root=NIL) OR (p=NIL);
    IF error THEN
      DISPOSE (p);
      DISPOSE (list.root)
    ELSE
      (*
        WITH p^ DO
          next:= LRoot.next;
          prev:= ADR (LRoot);
          owner:= list.root;
          level:= lev;
        END;
        LRoot.next^.prev:= p;
        LRoot.next:= p;
        WITH list.root^ DO
          prev:= list.root;
          next:= list.root;
          data:= p
        END;
      *)
      ASSEMBLER
        MOVE.L  p(A6),A0
        LEA     LRoot,A1
        MOVE.L  list(A6),A2
        MOVE.L  Control.next(A1),Control.next(A0)
        MOVE.L  A1,Control.prev(A0)
        MOVE.L  List.root(A2),Control.owner(A0)
        MOVE.W  lev(A6),Control.level(A0)
        MOVE.L  A0,D0
        MOVE.L  Control.next(A1),A0
        MOVE.L  D0,Control.prev(A0)
        MOVE.L  D0,Control.next(A1)
        MOVE.L  List.root(A2),A0
        MOVE.L  A0,Carrier.next(A0)
        MOVE.L  A0,Carrier.prev(A0)
        MOVE.L  D0,Carrier.data(A0)
      END
    END;
    ResetList (list)
  END create;

PROCEDURE CreateList ( VAR list: List; VAR error: BOOLEAN );
  (*$L-*)
  BEGIN
    ASSEMBLER
        ;create (list,error,Level)
        MOVE    Level,(A3)+
        JMP     create
    END
  END CreateList;
  (*$L=*)

PROCEDURE SysCreateList ( VAR list: List; VAR error: BOOLEAN );
  (*$L-*)
  BEGIN
    ASSEMBLER
        ;create (list,error,-1)
        MOVE    #-1,(A3)+
        JMP     create
    END
  END SysCreateList;
  (*$L=*)

PROCEDURE ListEmpty (VAR list:List): BOOLEAN;
  (*$L-*)
  BEGIN
    (* WITH list DO
         RETURN (root=NIL) OR ( (root^.next=root) & (root^.prev=root) ) *)
    ASSEMBLER
        MOVE.L  -(A3),A0        ; list
        MOVE.L  List.root(A0),D0
        BEQ     T
        MOVE.L  D0,A1
        CMPA.L  Carrier.next(A1),A1
        BNE     F
        CMPA.L  Carrier.prev(A1),A1
        BNE     F
     T: MOVE    #1,(A3)+
        RTS
     F: CLR     (A3)+
    END
  END ListEmpty;
  (*$L=*)

PROCEDURE DeleteList ( VAR list: List; VAR error: BOOLEAN );
  VAR p:P_Control;
  BEGIN
    error:= ~ListEmpty (list);
    IF ~error THEN
      WITH list DO
        IF root#NIL THEN
          p:= root^.data;
          WITH p^ DO
            prev^.next:= next;
            next^.prev:= prev
          END;
          DISPOSE (p);
          DISPOSE (root)
        END
      END
    END
  END DeleteList;


PROCEDURE InsertEntry ( VAR list: List; entry: ADDRESS; VAR error: BOOLEAN );
  VAR p:LCarrier;
  BEGIN
    (* WITH list DO *)
    IF list.root=NIL THEN
      error:= TRUE
    ELSE
      SysAlloc (p,SIZE (p^));
      (*
        error:= (p=NIL);
        IF ~error THEN
          p^.next:= current^.next;
          p^.prev:= current;
          p^.data:= entry;
          WITH current^ DO
            next^.prev:= p;
            next:= p
          END;
          current:= p
        END
      *)
      ASSEMBLER
        MOVE.L  error(A6),A1
        MOVE.L  p(A6),D0
        BEQ     ERR
        
        CLR     (A1)
        MOVE.L  D0,A1           ; p: A1
        MOVE.L  list(A6),A0     ; list: A0
        MOVE.L  List.current(A0),A2
        MOVE.L  Carrier.next(A2),A0     ; current^.next
        MOVE.L  A0,Carrier.next(A1)
        MOVE.L  A2,Carrier.prev(A1)
        MOVE.L  entry(A6),Carrier.data(A1)
        
        MOVE.L  A1,Carrier.prev(A0)
        MOVE.L  A1,Carrier.next(A2)
        MOVE.L  list(A6),A0
        MOVE.L  A1,List.current(A0)
        BRA     CONT
        
      ERR:
        MOVE    #1,(A1)
      CONT:
      END
    END
  END InsertEntry;

PROCEDURE AppendEntry ( VAR list: List; entry: ADDRESS; VAR error: BOOLEAN );
  VAR p:LCarrier;
  BEGIN
    (*WITH list DO*)
    IF list.root=NIL THEN
      error:= TRUE
    ELSE
      SysAlloc (p,SIZE (p^));
      (*
        error:= (p=NIL);
        IF ~error THEN
          p^.prev:= root^.prev;
          p^.next:= root;
          p^.data:= entry;
          WITH root^ DO
            prev^.next:= p;
            prev:= p
          END;
        END
      *)
      ASSEMBLER
        MOVE.L  error(A6),A1
        MOVE.L  p(A6),D0
        BEQ     ERR
        
        CLR     (A1)
        MOVE.L  D0,A1           ; p: A1
        MOVE.L  list(A6),A0     ; list: A0
        MOVE.L  List.root(A0),A2
        MOVE.L  Carrier.prev(A2),A0     ; root^.prev
        MOVE.L  A0,Carrier.prev(A1)
        MOVE.L  A2,Carrier.next(A1)
        MOVE.L  entry(A6),Carrier.data(A1)
        
        MOVE.L  A1,Carrier.next(A0)
        MOVE.L  A1,Carrier.prev(A2)
        BRA     CONT
        
      ERR:
        MOVE    #1,(A1)
      CONT:
      END
    END
  END AppendEntry;

PROCEDURE RemoveEntry ( VAR list: List; VAR error: BOOLEAN );
  (*$L-*)
  BEGIN
    (*
      VAR p:LCarrier;
      WITH list DO
        error := (root=NIL) OR (current=root);
        IF ~error THEN
          p:= current;
          current:= current^.prev;
          WITH p^ DO
            next^.prev:= prev;
            prev^.next:= next
          END;
          DISPOSE (p)
        END
      END
    *)
    ASSEMBLER
        MOVE.L  -(A3),A1
        MOVE.L  -(A3),A0
        MOVE.L  List.root(A0),D0
        BEQ     err
        MOVE.L  List.current(A0),A2
        CMP.L   A2,D0
        BEQ     err
        
        CLR     (A1)
        MOVE.L  Carrier.prev(A2),List.current(A0)
        MOVE.L  Carrier.next(A2),A1
        MOVE.L  Carrier.prev(A2),A0
        MOVE.L  A0,Carrier.prev(A1)
        MOVE.L  A1,Carrier.next(A0)
        
        MOVE.L  A2,-(A7)
        MOVE.L  A7,(A3)+
        CLR.L   (A3)+
        JSR     DEALLOCATE
        ADDQ.L  #4,A7
        RTS
        
      err:
        MOVE    #1,(A1)
    END
  END RemoveEntry;
  (*$L=*)

PROCEDURE NextEntry ( VAR list: List ): ADDRESS;
  (*$L-*)
  BEGIN
    (*
      WITH list DO
        IF current#NIL THEN
          current:= current^.next;
          IF current=root THEN
            RETURN NIL
          ELSE
            RETURN current^.data
          END
        ELSE
          RETURN NIL
        END
      END
    *)
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  List.current(A0),D0
        BEQ     ende
        MOVE.L  D0,A1
        MOVE.L  Carrier.next(A1),A2
        MOVE.L  A2,List.current(A0)
        MOVEQ   #0,D0
        CMPA.L  List.root(A0),A2
        BEQ     ende
        MOVE.L  Carrier.data(A2),D0
      ende:
        MOVE.L  D0,(A3)+
    END
  END NextEntry;
  (*$L=*)

PROCEDURE PrevEntry ( VAR list: List ): ADDRESS;
  (*$L-*)
  BEGIN
    (*
      WITH list DO
        IF current#NIL THEN
          current:= current^.prev;
          IF current=root THEN
            RETURN NIL
          ELSE
            RETURN current^.data
          END
        ELSE
          RETURN NIL
        END
      END
    *)
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  List.current(A0),D0
        BEQ     ende
        MOVE.L  D0,A1
        MOVE.L  Carrier.prev(A1),A2
        MOVE.L  A2,List.current(A0)
        MOVEQ   #0,D0
        CMPA.L  List.root(A0),A2
        BEQ     ende
        MOVE.L  Carrier.data(A2),D0
      ende:
        MOVE.L  D0,(A3)+
    END
  END PrevEntry;
  (*$L=*)

PROCEDURE CurrentEntry ( VAR list: List ): ADDRESS;
  (*$L-*)
  BEGIN
    (*
      WITH list DO
        IF (current=NIL) OR(current=root) THEN
          RETURN NIL
        ELSE
          RETURN current^.data
        END
      END
    *)
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  List.current(A0),D0
        BEQ     ende
        MOVE.L  D0,A2
        MOVEQ   #0,D0
        CMPA.L  List.root(A0),A2
        BEQ     ende
        MOVE.L  Carrier.data(A2),D0
      ende:
        MOVE.L  D0,(A3)+
    END
  END CurrentEntry;
  (*$L=*)

PROCEDURE FindEntry ( VAR list: List; entry: ADDRESS; VAR found: BOOLEAN );
  (*$L-*)
    (*VAR scan:LCarrier;*)
  BEGIN
    (*
      found:= FALSE;
      IF list.root#NIL THEN
        scan:= list.root^.next;
        WHILE scan#list.root DO
          IF scan^.data=entry THEN found:= TRUE; list.current:= scan; RETURN END;
          scan:= scan^.next
        END
      END
    *)
    ASSEMBLER
        MOVE.L  -(A3),A2
        CLR     (A2)                    ; A2: found
        MOVE.L  -(A3),D2                ; D2: entry
        MOVE.L  -(A3),A0                ; A0: list
        
        MOVE.L  List.root(A0),D1
        BEQ     ende
        
        MOVE.L  D1,A1                   ; A1: scan
      lup:
        MOVE.L  Carrier.next(A1),A1
        CMP.L   A1,D1
        BEQ     ende
        CMP.L   Carrier.data(A1),D2
        BNE     lup
        
        MOVE    #1,(A2)
        MOVE.L  A1,List.current(A0)
        
      ende:
    END
  END FindEntry;
  (*$L=*)

PROCEDURE scanFrwd ( VAR list: List; cond: LCondProc; info:ADDRESS;
                     VAR found: BOOLEAN );
  BEGIN
    WITH list DO
      IF current#NIL THEN
        LOOP
          current:= current^.next;
          IF current=root THEN EXIT END;
          IF cond (current^.data,info) THEN
            found:= TRUE;
            EXIT
          END
        END
      END
    END
  END scanFrwd;

PROCEDURE scanBack ( VAR list: List; cond: LCondProc; info:ADDRESS;
                     VAR found: BOOLEAN );
  BEGIN
    WITH list DO
      IF current#NIL THEN
        LOOP
          current:= current^.prev;
          IF current=root THEN EXIT END;
          IF cond (current^.data,info) THEN
            found:= TRUE;
            RETURN
          END
        END
      END
    END
  END scanBack;

PROCEDURE ScanEntries ( VAR list: List; dir: LDir; cond: LCondProc;
                        info:ADDRESS; VAR found: BOOLEAN );
  VAR scan:LCarrier;
  BEGIN
    found:= FALSE;
    IF dir=forward THEN
      scanFrwd (list,cond,info,found)
    ELSE
      scanBack (list,cond,info,found)
    END
  END ScanEntries;

PROCEDURE EndOfList ( VAR list: List ): BOOLEAN;
  (*$L-*)
  BEGIN
    (*
      WITH list DO
        RETURN (current=root) OR (root=NIL)
      END
    *)
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  List.root(A0),D0
        BEQ     ende
        MOVE.L  D0,D1
        MOVEQ   #0,D0
        CMP.L   List.current(A0),D1
        BEQ     ende
        MOVEQ   #1,D0
      ende:
        EORI    #1,D0
        MOVE    D0,(A3)+
    END
  END EndOfList;
  (*$L=*)

PROCEDURE FirstEntry ( VAR list: List ): BOOLEAN;
  (*$L-*)
  BEGIN
    (* WITH list DO
         RETURN (current^.prev=root) OR (root=NIL)
    *)
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  List.root(A0),D0
        BEQ     ende
        MOVE.L  D0,D1
        MOVE.L  List.current(A0),D0
        BEQ     ende
        MOVE.L  D0,A2
        MOVEQ   #0,D0
        CMP.L   Carrier.prev(A2),D1
        BEQ     ende
        MOVEQ   #1,D0
      ende:
        EORI    #1,D0
        MOVE    D0,(A3)+
    END
  END FirstEntry;
  (*$L=*)

PROCEDURE LastEntry ( VAR list: List ): BOOLEAN;
  (*$L-*)
  BEGIN
    (* WITH list DO
         RETURN (current^.next=root) OR (root=NIL)
    *)
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.L  List.root(A0),D0
        BEQ     ende
        MOVE.L  D0,D1
        MOVE.L  List.current(A0),D0
        BEQ     ende
        MOVE.L  D0,A2
        MOVEQ   #0,D0
        CMP.L   Carrier.next(A2),D1
        BEQ     ende
        MOVEQ   #1,D0
      ende:
        EORI    #1,D0
        MOVE    D0,(A3)+
    END
  END LastEntry;
  (*$L=*)

PROCEDURE NoOfEntries ( VAR list: List ): CARDINAL;
  (*$L-*)
    (*VAR n:CARDINAL; scan:LCarrier;*)
  BEGIN
    (*
      n:= 0;
      IF list.root#NIL THEN
        scan:= list.root^.next;
        WHILE scan#list.root DO
          INC (n);
          scan:= scan^.next
        END
      END;
      RETURN n
    *)
    ASSEMBLER
        CLR     D0              ; n
        MOVE.L  -(A3),A0
        MOVE.L  List.root(A0),D1
        BEQ     ende
        
        MOVE.L  D1,A1                   ; A1: scan
      lup:
        MOVE.L  Carrier.next(A1),A1
        CMP.L   A1,D1
        BEQ     ende
        ADDQ    #1,D0
        BNE     lup
        TRAP    #6
        DC.W    MOSGlobals.Overflow-$4000  ; callerCaused
      ende:
        MOVE    D0,(A3)+
    END
  END NoOfEntries;
  (*$L=*)


PROCEDURE releaseLevel;
  VAR p:P_Control; ent: ADDRESS; del, err: BOOLEAN; li: List;
  BEGIN
    p:= ADR (LRoot);
    p:= p^.next;
    WHILE p # ADR (LRoot) DO
      del:= p^.level>=Level;
      li.root:= p^.owner;
      p:= p^.next;
      IF del THEN
        ResetList (li);
        ent:= PrevEntry (li);
        REPEAT
          RemoveEntry (li,err)  (* Alle Entries lîschen *)
        UNTIL err;
        DeleteList (li,err)  (* Nun Liste freigeben *)
      END
    END
  END releaseLevel;

PROCEDURE chgLevel (start:BOOLEAN; inChild:BOOLEAN; VAR exitCode:INTEGER);
  BEGIN
    IF inChild THEN
      IF start THEN
        INC (Level)
      ELSE
        releaseLevel;
        DEC (Level)
      END
    END
  END chgLevel;

PROCEDURE freeSys;
  BEGIN
    Level:= MinInt;
    releaseLevel
  END freeSys;

VAR eHdl: PrgCtrl.EnvlpCarrier;
    tHdl: PrgCtrl.TermCarrier;
    rHdl: RemovalCarrier;
    wsp: MOSGlobals.MemArea;

BEGIN
  Level:= 0;
  LRoot.prev:= ADR (LRoot);
  LRoot.next:= ADR (LRoot);
  wsp.bottom:= NIL;
  PrgCtrl.SetEnvelope (eHdl,chgLevel,wsp);
  PrgCtrl.CatchProcessTerm (tHdl,releaseLevel,wsp);
  CatchRemoval (rHdl,freeSys,wsp);
END Lists.
 
(* $00001249$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$0000451A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFF8B082$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016A$FFFB016AÄ$00000038T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000D02$00000082$0000002F$00000496$00000742$00000038$00000DCF$00000DB9$00000DA8$00000D9C$00000DA8$00000D41$0000022E$00000082$000001D3$00000855òÄÅ*)

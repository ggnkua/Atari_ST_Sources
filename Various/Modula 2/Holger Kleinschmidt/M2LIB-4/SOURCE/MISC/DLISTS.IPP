IMPLEMENTATION MODULE DLists;
__IMP_SWITCHES__
__DEBUG__
#ifdef HM2
#ifdef __LONG_WHOLE__
(*$!i+: Modul muss mit $i- uebersetzt werden! *)
(*$!w+: Modul muss mit $w- uebersetzt werden! *)
#else
(*$!i-: Modul muss mit $i+ uebersetzt werden! *)
(*$!w-: Modul muss mit $w+ uebersetzt werden! *)
#endif
#endif
(*****************************************************************************)
(* 05-Aug-96, Holger Kleinschmidt                                            *)
(*****************************************************************************)

/* Wenn das nachfolgende Makro aktiviert ist (#if 1), wird Code fuer die
 * Testprozeduren am Ende des Moduls erzeugt.
 */
#if 0
#define _DEBUG
#endif

/* Wenn das nachfolgende Makro aktiviert ist (#if 1), wird Code fuer
 * Sicherheitschecks am Anfang jeder Prozedur erzeugt.
 */
#if 1
#define __CHECKS__
#endif


VAL_INTRINSIC
CAST_IMPORT
PTR_ARITH_IMPORT


FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, TSIZE;

FROM PORTAB IMPORT
(* CONST*) MAXSIGNEDWORD, MAXUNSIGNEDWORD,
(* TYPE *) ANYTYPE, UNSIGNEDWORD, UNSIGNEDLONG;

FROM ISOStorage IMPORT
(* PROC *) ALLOCATE, DEALLOCATE;

FROM blk IMPORT
(* PROC *) memmove;

FROM ADTBase IMPORT
(* TYPE *) ADTExceptions, CompareProc, ADTHeap,
(* PROC *) RaiseADTException, InstallADTHeap, FreeADTHeap, DeInstallADTHeap,
           ALLOC, DEALLOC;

#ifdef _DEBUG
FROM DosIO IMPORT Write, WriteString, WriteCard, WriteLn;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  LISTMAGIC = 0A987ABCCH;

TYPE
  ListItem = POINTER TO ListNode;
  ListNode = RECORD
    next : ListItem;
      (* -> naechstes Element *)
    prev : ListItem;
      (* -> vorhergehendes Element *)
  END;
  (* Hier beginnt die Information des Eintrags *)

  List = POINTER TO ListInfo;
  ListInfo = RECORD
#ifdef __CHECKS__
    magic    : UNSIGNEDLONG;
      (* = LISTMAGIC, falls definiert *)
#endif
    nil      : ListItem;
      (* -> Marke und Kopf der Liste *)
    cmp      : CompareProc;
      (* Vergleichsoperation *)
    nElems   : UNSIGNEDWORD;
      (* Anzahl der Elemente *)
    elemsize : UNSIGNEDWORD;
      (* Groesse der Elemente in Bytes *)
    heap     : ADTHeap;
      (* Fuer die Speicherverwaltung *)
  END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE find ((* EIN/ -- *)     list : List;
                (* EIN/ -- *) VAR val  : ARRAY OF ANYTYPE;
                (* -- /AUS *) VAR rank : CARDINAL;
                (* -- /AUS *) VAR node : ListItem ): BOOLEAN;

VAR __REG__ act : ListItem;
    __REG__ i   : UNSIGNEDWORD;

BEGIN
 WITH list^ DO
   (* Endmarke fuers Suchen *)
   memmove(ADDADR(nil, TSIZE(ListNode)),
           ADR(val),
           VAL(UNSIGNEDLONG,elemsize));
   act := nil^.next;
   i   := 1;
   WHILE cmp(ADR(val), ADDADR(act, TSIZE(ListNode))) # 0 DO
     act := act^.next;
     INC(i);
   END;
   IF act = nil THEN
     RETURN(FALSE);
   ELSE
     rank := VAL(CARDINAL,i);
     node := act;
     RETURN(TRUE);
   END;
 END;
END find;

(*---------------------------------------------------------------------------*)

PROCEDURE Create ((* EIN/ -- *)     eSize   : CARDINAL;
                  (* EIN/ -- *)     bSize   : CARDINAL;
                  (* EIN/ -- *)     compare : CompareProc;
                  (* -- /AUS *) VAR list    : List;
                  (* -- /AUS *) VAR done    : BOOLEAN );

BEGIN
 done := FALSE;
 list := NIL;
 IF   (eSize = 0) OR (eSize > VAL(CARDINAL,CAST(UNSIGNEDWORD,MAXSIGNEDWORD)))
   OR (bSize = 0) OR (bSize > VAL(CARDINAL,MAXUNSIGNEDWORD))
 THEN
   RETURN;
 END;

 ALLOCATE(list,  VAL(UNSIGNEDLONG,TSIZE(ListInfo))
                 (* fuer 'nil' *)
               + VAL(UNSIGNEDLONG,TSIZE(ListNode))
               + VAL(UNSIGNEDLONG,eSize));
 IF list # NIL THEN
   WITH list^ DO
     InstallADTHeap(VAL(CARDINAL,TSIZE(ListNode)) + eSize, bSize, heap, done);
     IF done THEN
       elemsize  := VAL(UNSIGNEDWORD,eSize);
       cmp       := compare;
       nElems    := 0;
       nil       := ADDADR(list, TSIZE(ListInfo));
       nil^.prev := nil;
       nil^.next := nil;
#ifdef __CHECKS__
       magic     := LISTMAGIC;
#endif
     ELSE
       DEALLOCATE(list,  VAL(UNSIGNEDLONG,TSIZE(ListInfo))
                       + VAL(UNSIGNEDLONG,TSIZE(ListNode))
                       + VAL(UNSIGNEDLONG,eSize));
     END; (* IF done *)
   END; (* WITH list *)
 END; (* IF list *)

 IF ~done THEN
   list := NIL;
 END;
END Create;

(*---------------------------------------------------------------------------*)

PROCEDURE Clear ((* EIN/ -- *) list : List );
BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Clear: <list> not defined");
   END;
#endif
   FreeADTHeap(heap);
   (* 'nil' sicherheitshalber neu initialisieren *)
   nil^.prev := nil;
   nil^.next := nil;
 END;
END Clear;

(*---------------------------------------------------------------------------*)

PROCEDURE Delete ((* EIN/AUS *) VAR list : List );
BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Delete: <list> not defined");
   END;
#endif
   DeInstallADTHeap(heap);
#ifdef __CHECKS__
   magic  := 0;
#endif
   nil    := NIL;
   nElems := 0;
   DEALLOCATE(list,   VAL(UNSIGNEDLONG,TSIZE(ListInfo))
                    + VAL(UNSIGNEDLONG,TSIZE(ListNode))
                    + VAL(UNSIGNEDLONG,elemsize));
 END;
 list := NIL;
END Delete;

(*---------------------------------------------------------------------------*)

PROCEDURE IsEmpty ((* EIN/ -- *) list : List ): BOOLEAN;
BEGIN
#ifdef __CHECKS__
 IF (list = NIL) OR (list^.magic # LISTMAGIC) THEN
   RaiseADTException(notAnADT, "DLists.IsEmpty: <list> not defined");
 END;
#endif
 RETURN(list^.nElems = 0);
END IsEmpty;

(*---------------------------------------------------------------------------*)

PROCEDURE Size ((* EIN/ -- *) list : List ): CARDINAL;
BEGIN
#ifdef __CHECKS__
 IF (list = NIL) OR (list^.magic # LISTMAGIC) THEN
   RaiseADTException(notAnADT, "DLists.Size: <list> not defined");
 END;
#endif
 RETURN(VAL(CARDINAL,list^.nElems));
END Size;

(*---------------------------------------------------------------------------*)

PROCEDURE GetInfo ((* EIN/ -- *)     list : List;
                   (* EIN/ -- *)     item : ListEntry;
                   (* -- /AUS *) VAR val  : ARRAY OF ANYTYPE );

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.GetInfo: <list> not defined");
   END;
   IF elemsize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "DLists.GetInfo: wrong element size");
   END;
#endif
   memmove(ADR(val),
           ADDADR(item, TSIZE(ListNode)),
           VAL(UNSIGNEDLONG,elemsize));
 END;
END GetInfo;

(*---------------------------------------------------------------------------*)

PROCEDURE SetInfo ((* EIN/ -- *)     list : List;
                   (* EIN/ -- *) VAR val  : ARRAY OF ANYTYPE;
                   (* EIN/ -- *)     item : ListEntry );

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.SetInfo: <list> not defined");
   END;
   IF elemsize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "DLists.SetInfo: wrong element size");
   END;
#endif
   memmove(ADDADR(item, TSIZE(ListNode)),
           ADR(val),
           VAL(UNSIGNEDLONG,elemsize));
 END;
END SetInfo;

(*---------------------------------------------------------------------------*)

PROCEDURE Insert ((* EIN/ -- *)     list   : List;
                  (* EIN/ -- *) VAR val    : ARRAY OF ANYTYPE;
                  (* EIN/ -- *)     before : BOOLEAN;
                  (* EIN/ -- *)     item   : ListEntry ): ListEntry;

VAR new  : ListItem;
    node : ListItem;

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Insert: <list> not defined");
   END;
   IF elemsize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "DLists.Insert: wrong element size");
   END;
#endif
   IF nElems = MAXUNSIGNEDWORD THEN
     RETURN(NIL);
   END;

   ALLOC(new, heap);
   IF new # NIL THEN
     node := CAST(ListItem,item);
     WITH node^ DO
       IF before THEN
         new^.next  := node;
         new^.prev  := prev;
         prev^.next := new;
         prev       := new;
       ELSE
         new^.next  := next;
         new^.prev  := node;
         next^.prev := new;
         next       := new;
       END;
     END;
     memmove(ADDADR(new, TSIZE(ListNode)),
             ADR(val),
             VAL(UNSIGNEDLONG,elemsize));
     INC(nElems);
   END; (* IF new # NIL *)
 END; (* WITH list^ *)
 RETURN(CAST(ListEntry,new));
END Insert;

(*---------------------------------------------------------------------------*)

PROCEDURE Push ((* EIN/ -- *)     list : List;
                (* EIN/ -- *) VAR val  : ARRAY OF ANYTYPE ): ListEntry;

VAR new : ListItem;

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Push: <list> not defined");
   END;
   IF elemsize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "DLists.Push: wrong element size");
   END;
#endif
   IF nElems = MAXUNSIGNEDWORD THEN
     RETURN(NIL);
   END;

   ALLOC(new, heap);
   IF new # NIL THEN
     WITH nil^ DO
       new^.next  := next;
       new^.prev  := nil;
       next^.prev := new;
       next       := new;
     END;
     memmove(ADDADR(new, TSIZE(ListNode)),
             ADR(val),
             VAL(UNSIGNEDLONG,elemsize));
     INC(nElems);
   END; (* IF new # NIL *)
 END; (* WITH list^ *)
 RETURN(CAST(ListEntry,new));
END Push;

(*---------------------------------------------------------------------------*)

PROCEDURE Append ((* EIN/ -- *)     list : List;
                  (* EIN/ -- *) VAR val  : ARRAY OF ANYTYPE ): ListEntry;

VAR new : ListItem;

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Append: <list> not defined");
   END;
   IF elemsize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "DLists.Append: wrong element size");
   END;
#endif
   IF nElems = MAXUNSIGNEDWORD THEN
     RETURN(NIL);
   END;

   ALLOC(new, heap);
   IF new # NIL THEN
     WITH nil^ DO
       new^.next  := nil;
       new^.prev  := prev;
       prev^.next := new;
       prev       := new;
     END;
     memmove(ADDADR(new, TSIZE(ListNode)),
             ADR(val),
             VAL(UNSIGNEDLONG,elemsize));
     INC(nElems);
   END; (* IF new # NIL *)
 END; (* WITH list^ *)
 RETURN(CAST(ListEntry,new));
END Append;

(*---------------------------------------------------------------------------*)

PROCEDURE Remove ((* EIN/ -- *)     list : List;
                  (* EIN/ -- *) VAR val  : ARRAY OF ANYTYPE );

VAR node : ListItem;
    rank : CARDINAL;

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Remove: <list> not defined");
   END;
   IF elemsize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "DLists.Remove: wrong element size");
   END;
#endif
   IF find(list, val, rank, node) THEN
     WITH node^ DO
       prev^.next := next;
       next^.prev := prev;
     END;
     DEALLOC(node, heap);
     DEC(nElems);
   END;
 END;
END Remove;

(*---------------------------------------------------------------------------*)

PROCEDURE RemoveItem ((* EIN/ -- *)     list : List;
                      (* EIN/AUS *) VAR item : ListEntry );

VAR node : ListItem;

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.RemoveItem: <list> not defined");
   END;
#endif
   node := CAST(ListItem,item);
   IF node # nil THEN
     WITH node^ DO
       prev^.next := next;
       next^.prev := prev;
     END;
     DEALLOC(node, heap);
     DEC(nElems);
   END;
   item := NIL;
 END;
END RemoveItem;

(*---------------------------------------------------------------------------*)

PROCEDURE Min ((* EIN/ -- *) list : List ): ListEntry;

VAR __REG__ act : ListItem;
    __REG__ min : ListItem;

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Min: <list> not defined");
   END;
#endif
   IF nElems = 0 THEN
     RETURN(NIL);
   END;
   min := nil^.next;
   act := min^.next;
   WHILE act # nil DO
     IF cmp(ADDADR(act, TSIZE(ListNode)), ADDADR(min, TSIZE(ListNode))) < 0 THEN
       min := act;
     END;
     act := act^.next;
   END;
 END;
 RETURN(CAST(ListEntry,min));
END Min;

(*---------------------------------------------------------------------------*)

PROCEDURE Max ((* EIN/ -- *) list : List ): ListEntry;

VAR __REG__ act : ListItem;
    __REG__ max : ListItem;

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Max: <list> not defined");
   END;
#endif
   IF nElems = 0 THEN
     RETURN(NIL);
   END;
   max := nil^.next;
   act := max^.next;
   WHILE act # nil DO
     IF cmp(ADDADR(act, TSIZE(ListNode)), ADDADR(max, TSIZE(ListNode))) > 0 THEN
       max := act;
     END;
     act := act^.next;
   END;
 END;
 RETURN(CAST(ListEntry,max));
END Max;

(*---------------------------------------------------------------------------*)

PROCEDURE Succ ((* EIN/ -- *) list : List;
                (* EIN/ -- *) item : ListEntry ): ListEntry;

VAR __REG__ node : ListItem;

BEGIN
#ifdef __CHECKS__
 IF (list = NIL) OR (list^.magic # LISTMAGIC) THEN
   RaiseADTException(notAnADT, "DLists.Succ: <list> not defined");
 END;
#endif
 node := CAST(ListItem,item);
 node := node^.next;
 IF node = list^.nil THEN
   RETURN(NIL);
 ELSE
   RETURN(CAST(ListEntry,node));
 END;
END Succ;

(*---------------------------------------------------------------------------*)

PROCEDURE Pred ((* EIN/ -- *) list : List;
                (* EIN/ -- *) item : ListEntry ): ListEntry;

VAR __REG__ node : ListItem;

BEGIN
#ifdef __CHECKS__
 IF (list = NIL) OR (list^.magic # LISTMAGIC) THEN
   RaiseADTException(notAnADT, "DLists.Pred: <list> not defined");
 END;
#endif
 node := CAST(ListItem,item);
 node := node^.prev;
 IF node = list^.nil THEN
   RETURN(NIL);
 ELSE
   RETURN(CAST(ListEntry,node));
 END;
END Pred;

(*---------------------------------------------------------------------------*)

PROCEDURE CyclicSucc ((* EIN/ -- *) list : List;
                      (* EIN/ -- *) item : ListEntry ): ListEntry;

VAR __REG__ node : ListItem;

BEGIN
#ifdef __CHECKS__
 IF (list = NIL) OR (list^.magic # LISTMAGIC) THEN
   RaiseADTException(notAnADT, "DLists.CyclicSucc: <list> not defined");
 END;
#endif
 node := CAST(ListItem,item);
 node := node^.next;
 IF node = list^.nil THEN
   (* <item> ist das letzte Element, also das erste liefern.
    * Da <item> ein Element der Liste sein muss, ist die Liste nicht leer
    * und nil^.next deswegen ein gueltiges Element (nicht 'nil', kann aber
    * <item> selbst sein).
    *)
   RETURN(CAST(ListEntry,list^.nil^.next));
 ELSE
   RETURN(CAST(ListEntry,node));
 END;
END CyclicSucc;

(*---------------------------------------------------------------------------*)

PROCEDURE CyclicPred ((* EIN/ -- *) list : List;
                      (* EIN/ -- *) item : ListEntry ): ListEntry;

VAR __REG__ node : ListItem;

BEGIN
#ifdef __CHECKS__
 IF (list = NIL) OR (list^.magic # LISTMAGIC) THEN
   RaiseADTException(notAnADT, "DLists.CyclicSucc: <list> not defined");
 END;
#endif
 node := CAST(ListItem,item);
 node := node^.prev;
 IF node = list^.nil THEN
   (* <item> ist das erste Element, also das letzte liefern.
    * Da <item> ein Element der Liste sein muss, ist die Liste nicht leer
    * und nil^.prev deswegen ein gueltiges Element (nicht 'nil', kann aber
    * <item> selbst sein).
    *)
   RETURN(CAST(ListEntry,list^.nil^.prev));
 ELSE
   RETURN(CAST(ListEntry,node));
 END;
END CyclicPred;

(*---------------------------------------------------------------------------*)

PROCEDURE First ((* EIN/ -- *) list : List ): ListEntry;
BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.First: <list> not defined");
   END;
#endif
   IF nElems = 0 THEN
     RETURN(NIL);
   ELSE
     RETURN(CAST(ListEntry,nil^.next));
   END;
 END;
END First;

(*---------------------------------------------------------------------------*)

PROCEDURE Last ((* EIN/ -- *) list : List ): ListEntry;
BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Last: <list> not defined");
   END;
#endif
   IF nElems = 0 THEN
     RETURN(NIL);
   ELSE
     RETURN(CAST(ListEntry,nil^.prev));
   END;
 END;
END Last;

(*---------------------------------------------------------------------------*)

PROCEDURE Head ((* EIN/ -- *)     list : List;
                (* -- /AUS *) VAR val  : ARRAY OF ANYTYPE );
BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Head/Pop: <list> not defined");
   END;
   IF elemsize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "DLists.Head/Pop: wrong element size");
   END;
#endif
   IF nElems = 0 THEN
     RaiseADTException(noEntry, "DLists.Head/Pop: list is empty");
   END;
   memmove(ADR(val),
           ADDADR(nil^.next, TSIZE(ListNode)),
           VAL(UNSIGNEDLONG,elemsize));
 END;
END Head;

(*---------------------------------------------------------------------------*)

PROCEDURE Tail ((* EIN/ -- *)     list : List;
                (* -- /AUS *) VAR val  : ARRAY OF ANYTYPE );
BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Tail/PopLast: <list> not defined");
   END;
   IF elemsize # VAL(UNSIGNEDWORD,HIGH(val) + 1) THEN
     RaiseADTException(wrongElemSize, "DLists.Tail/PopLast: wrong element size");
   END;
#endif
   IF nElems = 0 THEN
     RaiseADTException(noEntry, "DLists.Tail/PopLast: list is empty");
   END;
   memmove(ADR(val),
           ADDADR(nil^.prev, TSIZE(ListNode)),
           VAL(UNSIGNEDLONG,elemsize));
 END;
END Tail;

(*---------------------------------------------------------------------------*)

PROCEDURE Pop ((* EIN/ -- *)     list : List;
               (* -- /AUS *) VAR val  : ARRAY OF ANYTYPE );

VAR node : ListItem;

BEGIN
 WITH list^ DO
   Head(list, val);
   node := nil^.next;
   WITH node^ DO
     prev^.next := next;
     next^.prev := prev;
   END;
   DEALLOC(node, heap);
   DEC(nElems);
 END;
END Pop;

(*---------------------------------------------------------------------------*)

PROCEDURE PopLast ((* EIN/ -- *)     list : List;
                   (* -- /AUS *) VAR val  : ARRAY OF ANYTYPE );

VAR node : ListItem;

BEGIN
 WITH list^ DO
   Tail(list, val);
   node := nil^.prev;
   WITH node^ DO
     prev^.next := next;
     next^.prev := prev;
   END;
   DEALLOC(node, heap);
   DEC(nElems);
 END;
END PopLast;

(*---------------------------------------------------------------------------*)

PROCEDURE Search ((* EIN/ -- *)     list : List;
                  (* EIN/ -- *) VAR val  : ARRAY OF ANYTYPE ): ListEntry;

VAR rank : CARDINAL;
    node : ListItem;

BEGIN
#ifdef __CHECKS__
 IF (list = NIL) OR (list^.magic # LISTMAGIC) THEN
   RaiseADTException(notAnADT, "DLists.Search: <list> not defined");
 END;
#endif
 IF find(list, val, rank, node) THEN
   RETURN(node);
 ELSE
   RETURN(NIL);
 END;
END Search;

(*---------------------------------------------------------------------------*)

PROCEDURE Select ((* EIN/ -- *) list : List;
                  (* EIN/ -- *) i    : CARDINAL ): ListEntry;

VAR __REG__ act  : ListItem;
    __REG__ rank : UNSIGNEDWORD;

BEGIN
#ifdef __CHECKS__
 IF (list = NIL) OR (list^.magic # LISTMAGIC) THEN
   RaiseADTException(notAnADT, "DLists.Select: <list> not defined");
 END;
#endif
 IF (i = 0) OR (i > VAL(CARDINAL,list^.nElems)) THEN
   RETURN(NIL);
 END;
 rank := VAL(UNSIGNEDWORD,i - 1);
 act  := list^.nil^.next;
 WHILE rank > 0 DO
   DEC(rank);
   act := act^.next;
 END;
 RETURN(CAST(ListEntry,act));
END Select;

(*---------------------------------------------------------------------------*)

PROCEDURE Rank ((* EIN/ -- *)     list : List;
                (* EIN/ -- *) VAR val  : ARRAY OF ANYTYPE ): CARDINAL;

VAR rank : CARDINAL;
    node : ListItem;

BEGIN
#ifdef __CHECKS__
 IF (list = NIL) OR (list^.magic # LISTMAGIC) THEN
   RaiseADTException(notAnADT, "DLists.Rank: <list> not defined");
 END;
#endif
 IF find(list, val, rank, node) THEN
   RETURN(rank);
 ELSE
   RETURN(0);
 END;
END Rank;

(*---------------------------------------------------------------------------*)

PROCEDURE Map ((* EIN/ -- *) list  : List;
               (* EIN/ -- *) visit : VisitProc );

VAR __REG__ act : ListItem;

BEGIN
 WITH list^ DO
#ifdef __CHECKS__
   IF (list = NIL) OR (magic # LISTMAGIC) THEN
     RaiseADTException(notAnADT, "DLists.Map: <list> not defined");
   END;
#endif
   act := nil^.next;
   WHILE (act # nil) & visit(list, act) DO
     act := act^.next;
   END;
 END;
END Map;

(*---------------------------------------------------------------------------*)

PROCEDURE CheckList ((* EIN/ -- *) list  : List;
                     (* EIN/ -- *) print : VisitProc );
#ifdef _DEBUG
VAR act  : ListItem;
    cnt  : UNSIGNEDWORD;
    done : BOOLEAN;

BEGIN
 WITH list^ DO
   IF (list = NIL) OR (magic # LISTMAGIC) OR (nil = NIL) THEN
     WriteString("*** Liste undefiniert!");
     RETURN;
   END;
   cnt := 0;
   act := nil^.next;
   WHILE act # nil DO
     IF (act^.prev^.next # act) OR (act^.next^.prev # act) THEN
       WriteString("*** Verzeigerung bei Knoten : ");
       done := print(list, act);
       WriteLn;
       RETURN;
     END;
     act := act^.next;
     INC(cnt);
   END;
   IF cnt # nElems THEN
     WriteString("*** SIZE stimmt nicht: ");
     WriteCard(VAL(UNSIGNEDLONG,cnt), 1);
     WriteString(" <-> ");
     WriteCard(VAL(UNSIGNEDLONG,nElems), 1);
     WriteLn;
   END;
 END;
#endif
END CheckList;

(*---------------------------------------------------------------------------*)

PROCEDURE PrintList ((* EIN/ -- *) list  : List;
                     (* EIN/ -- *) print : VisitProc );
#ifdef _DEBUG
VAR act  : ListItem;
    done : BOOLEAN;

BEGIN
 WITH list^ DO
   act := nil^.next;
   WHILE act # nil DO
     done := print(list, act);
     Write('=');
     act  := act^.next;
   END;
 END;
#endif
END PrintList;

END DLists.


IMPLEMENTATION MODULE RBTrees;
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
(* Dieses Modul ist eine Implementation der (etwas geaenderten und erweiter- *)
(* ten) Algorithmen rund um Such- und Rot-Schwarz-Baeume aus "Introduction   *)
(* To Algorithms" (siehe Literaturverzeichnis).                              *)
(*                                                                           *)
(* Ein Rot-Schwarz-Baum ist ein binaerer Suchbaum mit folgenden zusaetzlichen*)
(* Eigenschaften, die fuer Ausgeglichenheit des Baums sorgen:                *)
(*                                                                           *)
(*  - Jeder Knoten ist entweder rot oder schwarz gefaerbt                    *)
(*                                                                           *)
(*  - Jeder externe Knoten ist schwarz gefaerbt                              *)
(*                                                                           *)
(*  - Wenn ein Knoten rot gefaerbt ist, sind seine Kinder schwarz gefaerbt   *)
(*                                                                           *)
(*  - Jeder Pfad von einem Knoten zu den von ihm erreichbaren Blaettern hat  *)
(*    die gleiche Anzahl schwarz gefaerbter Knoten                           *)
(*                                                                           *)
(*                                                                           *)
(* Binaerer Suchbaum bedeutet, dass ein Knoten maximal zwei Nachfolger hat,  *)
(* wobei die Schluessel im linken Teilbaum jeweils kleiner und im rechten    *)
(* Teilbaum groesser als der eigene Schluessel sind.                         *)
(*                                                                           *)
(* Mit externen Knoten sind die imaginaeren Knoten, die an den Blaettern     *)
(* haengen, gemeint. Hier wird fuer die externen Knoten tatsaechlich ein     *)
(* Knoten verwendet ('nil'), der vom Baum-Infoknoten direkt ansprechbar      *)
(* ist; allerdings gibt es nur einen einzigen solchen Knoten fuer alle Blaet-*)
(* ter, d.h. alle Blaetter haben als Nachfolger diesen Knoten. Dieser        *)
(* zusaetzliche 'nil'-Knoten vereinfacht die Programmierung, da nicht immer  *)
(* auf NIL abgefragt werden muss, sondern die benoetigten Felder je nach     *)
(* Bedarf wie bei einem normalen (``internen'') Knoten gesetzt und abgefragt *)
(* werden koennen.                                                           *)
(* --------------------------------------------------------------------------*)
(* Okt-91 / 05-Aug-96, Holger Kleinschmidt                                   *)
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

FROM blk IMPORT
(* PROC *) memmove;

FROM ISOStorage IMPORT
(* PROC *) ALLOCATE, DEALLOCATE;

FROM ADTBase IMPORT
(* TYPE *) ADTExceptions, CompareProc, ADTHeap,
(* PROC *) RaiseADTException, InstallADTHeap, FreeADTHeap, DeInstallADTHeap,
           ALLOC, DEALLOC;

#ifdef _DEBUG
FROM DosIO IMPORT Write, WriteString, WriteCard, WriteLn;
#endif

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  RBTREEMAGIC = 0A987ABCFH;

TYPE
  RBColor = (BLACK, RED);

  NodeType = (ROOT, LEFTCHILD, RIGHTCHILD);

  RBItem = POINTER TO RBNode;
  RBNode = RECORD
    parent : RBItem;
      (* -> Vorgaenger, nil <=> Knoten = Wurzel *)
    left   : RBItem;
      (* -> kleinerer Nachfolger,  nil <=> Knoten = Blatt *)
    right  : RBItem;
      (* -> groesserer Nachfolger, nil <=> Knoten = Blatt *)
    size   : UNSIGNEDWORD;
      (* Anzahl der Elemente des Teilbaums ab einschliesslich Knoten.
       * Wird nur fuer die Operationen "Rank()" und "Select()" benoetigt.
       *)
    color  : RBColor;
      (* Farbe des Knotens *)
    type   : NodeType;
      (* Knoten ist linkes Kind, rechtes Kind oder Wurzel *)
  END;
  (* Hier folgen Schluessel und Infoeintrag *)


  RBTree = POINTER TO RBInfo;
  RBInfo = RECORD
#ifdef __CHECKS__
    magic    : UNSIGNEDLONG;
      (* = RBTREEMAGIC, falls definiert *)
#endif
    root     : RBItem;
      (* -> oberster Knoten, Wurzel *)
    nil      : RBItem;
      (* -> Marke, vereinfacht einige Operationen *)
    cmp      : CompareProc;
      (* Vergleichsoperation fuer Schluessel *)
    keysize  : UNSIGNEDWORD;
      (* Groesse des Schluesselwerts in Bytes *)
    infosize : UNSIGNEDWORD;
      (* Groesse des Infoeintrags in Bytes *)
    heap     : ADTHeap;
      (* Fuer die Speicherverwaltung *)
  END;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

PROCEDURE min ((* EIN/ -- *) nil  : RBItem;
               (* EIN/ -- *) node : RBItem ): RBItem;

(* Entsprechend der Suchbaumeigenschaft ist der kleinste Knoten das
 * Blatt ganz links unten.
 * <node> muss ungleich <nil> sein!
 *)
VAR __REG__ n : RBItem;

BEGIN
 n := node;
 WHILE n^.left # nil DO
   n := n^.left;
 END;
 RETURN(n);
END min;

(*---------------------------------------------------------------------------*)

PROCEDURE max ((* EIN/ -- *) nil  : RBItem;
               (* EIN/ -- *) node : RBItem ): RBItem;

(* Entsprechend der Suchbaumeigenschaft ist der groesste Knoten das
 * Blatt ganz rechts unten.
 * <node> muss ungleich <nil> sein!
 *)
VAR __REG__ n : RBItem;

BEGIN
 n := node;
 WHILE n^.right # nil DO
   n := n^.right;
 END;
 RETURN(n);
END max;

(*---------------------------------------------------------------------------*)

PROCEDURE find ((* EIN/ -- *)     Tree : RBTree;
                (* EIN/ -- *) VAR Key  : ARRAY OF ANYTYPE;
                (* -- /AUS *) VAR Rank : CARDINAL ): ADDRESS;

(* Im Suchbaum <Tree> wird das Element mit dem Schluessel <Key> gesucht.
 * Existiert das Element, wird ein Zeiger auf den Eintrag zurueckgeliefert
 * und <Rank> enthaelt die Position des Elements, sonst wird NIL geliefert
 * und <Rank> ist gleich Null.
 *)
VAR __REG__ node : RBItem;
    __REG__ cres : INTEGER;
    __REG__ rank : UNSIGNEDWORD;

BEGIN
 WITH Tree^ DO
   (* Endmarke fuers Suchen *)
   memmove(ADDADR(nil, TSIZE(RBNode)), ADR(Key), VAL(UNSIGNEDLONG,keysize));
   rank := 1;
   node := root;
   LOOP
     cres := cmp(ADR(Key), ADDADR(node, TSIZE(RBNode)));
     IF cres = 0 THEN
       EXIT;
     ELSIF cres < 0 THEN
       node := node^.left;
     ELSE
       (* Die Elemente im linken Teilbaum und der Elternknoten kommen vorher *)
       INC(rank, node^.left^.size + 1);
       node := node^.right;
     END;
   END;
   IF node = nil THEN
     Rank := 0;
     RETURN(NIL);
   ELSE
     Rank := VAL(CARDINAL,rank + node^.left^.size);
     RETURN(CAST(ADDRESS,node));
   END;
 END;
END find;

(*---------------------------------------------------------------------------*)

PROCEDURE leftRotate ((* EIN/ -- *) Tree : RBTree;
                      (* EIN/ -- *) node : RBItem );

(*
 *      <node>                        <succ>
 *      /   \                          /  \
 *     /     \          ===>          /    \
 *    A     <succ>                 <node>   C
 *           /  \                  /   \
 *          /    \                /     \
 *         B      C              A       B  <-- 'parent' und 'type' geaendert
 *
 * <node> muss einen rechten Nachfolger besitzen (node^.right # nil)!
 * <node> wird zum linken Nachfolger seines frueheren rechten
 * Nachfolgers. Zum rechten Nachfolger von <node> wird jetzt der
 * linke Nachfolger seines frueheren rechten Nachfolgers;
 * Wenn dieser 'nil' ist, also der fruehere rechte Nachfolger keinen
 * linken Nachfolger hatte, wird der 'parent'-Pointer von 'nil'
 * veraendert und der Typ von 'nil' auf 'RIGHTCHILD' gesetzt !
 * Die Suchbaumeigenschaft wird durch das Rotieren nicht verletzt.
 *)

VAR __REG__ succ : RBItem;

BEGIN
 WITH node^ DO
   succ := right;

   right         := succ^.left;
   right^.parent := node;
   right^.type   := RIGHTCHILD;

   succ^.parent := parent;
   IF type = ROOT THEN
     Tree^.root    := succ;
   ELSIF type = LEFTCHILD THEN
     parent^.left  := succ;
   ELSE
     parent^.right := succ;
   END;

   succ^.left := node;
   parent     := succ;
   succ^.size := size;
   size       := left^.size + right^.size + 1;
   succ^.type := type;
   type       := LEFTCHILD;
 END; (* WITH node *)
END leftRotate;

(*---------------------------------------------------------------------------*)

PROCEDURE rightRotate ((* EIN/ -- *) Tree : RBTree;
                       (* EIN/ -- *) node : RBItem );

(*
 *         <node>                  <succ>
 *         /   \                    /  \
 *        /     \       ===>       /    \
 *     <succ>    C                A    <node>
 *      /  \                           /   \
 *     /    \                         /     \
 *    A      B                       B       C
 *                                   ^
 *                                    \ 'parent' und 'type' geaendert
 *
 * <node> muss einen linken Nachfolger besitzen (node^.left # nil)!
 * <node> wird zum rechten Nachfolger seines frueheren linken
 * Nachfolgers. Zum linken Nachfolger von <node> wird jetzt der
 * rechte Nachfolger seines frueheren linken Nachfolgers;
 * Wenn dieser 'nil' ist, also der fruehere linke Nachfolger keinen
 * rechten Nachfolger hatte, wird der 'parent'-Pointer von 'nil'
 * veraendert und der Typ von 'nil' auf 'LEFTCHILD' gesetzt!
 * Die Suchbaumeigenschaft wird durch das Rotieren nicht verletzt.
 *)

VAR __REG__ succ : RBItem;

BEGIN
 WITH node^ DO
   succ := left;

   left         := succ^.right;
   left^.parent := node;
   left^.type   := LEFTCHILD;

   succ^.parent := parent;
   IF type = ROOT THEN
     Tree^.root := succ;
   ELSIF type = LEFTCHILD THEN
     parent^.left  := succ;
   ELSE
     parent^.right := succ;
   END;

   succ^.right := node;
   parent      := succ;
   succ^.size  := size;
   size        := left^.size + right^.size + 1;
   succ^.type  := type;
   type        := RIGHTCHILD;
 END; (* WITH node *)
END rightRotate;

(*---------------------------------------------------------------------------*)

PROCEDURE treeInsert ((* EIN/ -- *)     Tree    : RBTree;
                      (* EIN/ -- *) VAR Key     : ARRAY OF ANYTYPE;
                      (* EIN/ -- *) VAR Info    : ARRAY OF ANYTYPE;
                      (* -- /AUS *) VAR new     : RBItem;
                      (* -- /AUS *) VAR replace : BOOLEAN );

(* Zuerst wird geprueft, ob in <Tree> bereits ein Eintrag mit dem Schluessel
 * <Key> existiert; ist das der Fall, wird die alte Information durch
 * <Info> ersetzt, <replace> auf TRUE gesetzt und in <new> ein Verweis
 * auf diesen Eintrag geliefert.
 * Existiert noch kein solcher Eintrag, wird ein neuer Knoten als
 * Blatt entsprechend der Suchbaumeigenschaft mit <Key> und <Info> erzeugt.
 * Ein Zeiger auf den neuen Knoten wird in <new> zurueckgegeben
 * oder NIL, falls kein Speicher mehr frei ist.
 *)

VAR __REG__ newNode    : RBItem;
            parentNode : RBItem;
    __REG__ cres       : INTEGER;
            sel        : INTEGER;

BEGIN
 WITH Tree^ DO
   (* 'nil' als Marke benutzen *)
   memmove(ADDADR(nil, TSIZE(RBNode)), ADR(Key), VAL(UNSIGNEDLONG,keysize));
   parentNode := nil;
   newNode    := root;

   LOOP
     cres := cmp(ADR(Key), ADDADR(newNode, TSIZE(RBNode)));
     IF cres = 0 THEN
       EXIT;
     END;
     sel        := cres;
     parentNode := newNode;
     (* Wenn ein neues Blatt angefuegt wird, haben alle Teilbaeume,
      * die von den auf dem Weg zum neuen Blatt erreichten Knoten
      * ausgehen, ein Element mehr.
      *)
     INC(newNode^.size);
     IF cres < 0 THEN
       newNode := newNode^.left;
     ELSE
       newNode := newNode^.right;
     END;
   END;

   replace := newNode # nil;
   IF replace THEN
     (* Ein Eintrag mit dem Schluessel existiert bereits, nur die
      * neue Information uebernehmen.
      *)
     memmove(ADDADR(newNode, VAL(UNSIGNEDWORD,TSIZE(RBNode)) + keysize),
             ADR(Info),
             VAL(UNSIGNEDLONG,infosize));
     new := newNode;
     WHILE newNode # root DO
       (* Es wurde kein neuer Knoten eingefuegt, daher muss die
        * Erhoehung der Knotenzahl bei jedem Vorgaengerknoten
        * rueckgaengig gemacht werden.
        *)
       newNode := newNode^.parent;
       DEC(newNode^.size);
     END;
   ELSE
     ALLOC(new, heap);
     IF new # NIL THEN
       WITH new^ DO
         left   := nil;
         right  := nil;
         parent := parentNode;
         size   := 1;

         IF parent = nil THEN
           root          := new;
           type          := ROOT;
         ELSIF sel < 0 THEN
           parent^.left  := new;
           type          := LEFTCHILD;
         ELSE
           parent^.right := new;
           type          := RIGHTCHILD;
         END;
         memmove(ADDADR(new, TSIZE(RBNode)),
                 ADR(Key),
                 VAL(UNSIGNEDLONG,keysize));
         memmove(ADDADR(new, VAL(UNSIGNEDWORD,TSIZE(RBNode)) + keysize),
                 ADR(Info),
                 VAL(UNSIGNEDLONG,infosize));
       END; (* WITH new *)
     END; (* IF new # NIL *)
   END; (* IF replace *)
 END; (* WITH Tree *)
END treeInsert;

(*---------------------------------------------------------------------------*)

PROCEDURE removeRB ((* EIN/ -- *) Tree : RBTree;
                    (* EIN/ -- *) node : RBItem );

(* Der schwarz eingefaerbte Vorgaenger von <node> wurde entfernt, wodurch
 * alle Pfade, in denen dieser Knoten enthalten war, nun einen schwarz
 * eingefaerbten Knoten zuwenig haben.
 * Es wird so getan, als habe <node> ein zusaetzliches Schwarz (das
 * fehlende); dieses zusaetzliche Schwarz wird entweder solange nach oben
 * im Baum verschoben bis <node> auf einen rot eingefaerbten Knoten zeigt,
 * der dann einfach schwarz eingefaerbt wird, oder <node> auf die Wurzel
 * zeigt, wodurch es dann einfach entfallen kann, weil es keinen Nachbar-
 * Teilbaum geben kann, der eine andere Schwarzhoehe hat, oder geeignete
 * Rotationen und Umfaerbungen erfolgen koennen.
 *)

VAR __REG__ neighbourNode : RBItem;
            parentNode    : RBItem;

BEGIN
 WITH Tree^ DO
   WHILE (node # root) & (node^.color = BLACK) DO

     (* Da <node> auch 'nil' sein kann, aber nur ein 'nil' fuer
      * den gesamtem Baum existiert, koennte beim Rotieren auch
      * der 'parent'-Pointer von <node> veraendert werden (wenn
      * naemlich der beim Rotieren miteinbezogene Nachfolger ein
      * Blatt ist, und dessen Nachfolger - also 'nil' auf einen
      * neuen Vorgaengerknoten gesetzt wird); deswegen wird der
      * 'parent'-Pointer zu Beginn der Schleife gesichert.
      *)

     parentNode := node^.parent;

     IF node^.type = LEFTCHILD THEN
       WITH parentNode^ DO
         neighbourNode := right;
         IF neighbourNode^.color = RED THEN

           (* FALL 1:
            *
            * Wenn der Nachbar von <node> rot eingefaerbt ist,
            * MUSS der Vorgaenger schwarz eingefaerbt sein, da es
            * sonst zwei aufeinanderfolgende rot eingefaerbte Knoten
            * gaebe, und der Nachbar MUSS an jedem Zweig noch mindestens
            * einen schwarz gefaerbten Nachfolger (nicht 'nil') haben,
            * da der entfernte Knoten (der fuehere Vorgaenger von
            * <node>) ein schwarz eingefaerbter Knoten war, und die
            * Schwarzhoehe in jedem Zweig gleich sein muss.
            *
            * Durch Austauschen der Farben von Vorgaenger und Nachbar
            * und Rotieren bleibt die Schwarzhoehe erhalten, aber nun
            * ist der Nachbar der schwarz eingefaerbte linke Nachfolger
            * des frueheren Nachbarn.
            *)

           neighbourNode^.color := BLACK;
           color                := RED;
           leftRotate(Tree, parentNode);
           neighbourNode        := right;
         END;
       END;

       (* Der Nachbar von <node> ist schwarz eingefaerbt *)

       IF     (neighbourNode^.left^.color  = BLACK)
          & (neighbourNode^.right^.color = BLACK)
       THEN

         (* FALL 2:
          *
          * Wenn beide Nachfolger des Nachbarknotens ebenfalls
          * schwarz eingefaerbt sind, kann der Nachbar rot eingefaerbt
          * werden, und die Schleife wird mit dem Vorgaengerknoten als
          * neuem Knoten mit dem zusaetzlichen Schwarz fortgefuehrt.
          * Ist der Vorgaengerknoten rot eingefaerbt (z.B. durch
          * die Abarbeitung von FALL 1), ist die Schleife beendet.
          *)

         neighbourNode^.color := RED;
         node                 := parentNode;
       ELSE (* mind. ein Nachfolger des Nachbarn ist rot eingefaerbt *)
         WITH neighbourNode^ DO
           IF left^.color = RED THEN

             (* FALL 3:
              *
              * Wenn der linke Nachfolger des Nachbarknoten rot eingefaerbt
              * ist (und der rechte schwarz), wird dies in Fall 4
              * transformiert, indem die Farben vom Nachbarn und dessen
              * linken Nachfolger ausgetauscht werden und eine
              * Rechts-Rotation mit dem Nachfolger ausgefuehrt wird, so dass
              * der Nachbarknoten (der linke Nachfolger des frueheren
              * Nachbarn) jetzt schwarz ist und dessen rechter Nachfolger
              * (der fruehere Nachbar) rot (da dessen rechter Nachfolger
              * schwarz ist, entstehen keine aufeinanderfolgenden roten
              * Knoten).
              *)

             left^.color   := BLACK;
             color         := RED;
             rightRotate(Tree, neighbourNode);
             neighbourNode := parentNode^.right;
           END;
         END;

         (* FALL 4:
          *
          * Der rechte Nachfolger des schwarz eingefaerbten Nachbarn ist
          * rot eingefaerbt.
          * Der/Die Interessierte moege sich ein Bildchen malen, ist
          * viel zu kompliziert, ums hier zu erklaeren...
          *)
         WITH parentNode^ DO
           neighbourNode^.color        := color;
           color                       := BLACK;
           neighbourNode^.right^.color := BLACK;
           leftRotate(Tree, parentNode);
         END;
         node := root; (* =>  Schleife beendet *)
       END
     ELSE (* node^.type = RIGHTCHILD *)
       (* das gleiche wie oben, nur 'right' und 'left' bzw.
        * "leftRotate()" und "rightRotate()" vertauscht.
        *)
       WITH parentNode^ DO
         neighbourNode := left;
         IF neighbourNode^.color = RED THEN
           neighbourNode^.color := BLACK;
           color                := RED;
           rightRotate(Tree, parentNode);
           neighbourNode        := left;
         END;
       END;
       IF     (neighbourNode^.left^.color  = BLACK)
          & (neighbourNode^.right^.color = BLACK)
       THEN
         neighbourNode^.color := RED;
         node                 := parentNode;
       ELSE
         WITH neighbourNode^ DO
           IF right^.color = RED THEN
             right^.color  := BLACK;
             color         := RED;
             leftRotate(Tree, neighbourNode);
             neighbourNode := parentNode^.left;
           END;
         END;
         WITH parentNode^ DO
           neighbourNode^.color       := color;
           color                      := BLACK;
           neighbourNode^.left^.color := BLACK;
           rightRotate(Tree, parentNode);
         END;
         node := root;
       END;
     END; (* IF node^.type *)
   END; (* WHILE *)

   (* Ein rot eingefaerbter Knoten in dem Teilbaum, aus dem ein
    * schwarz eingefaerbter Knoten entfernt wurde, wird mit dem
    * zusaetzlichen Schwarz eingefaerbt, oder die ohnehin schwarze
    * Wurzel.
    *)
   node^.color := BLACK;

 END; (* WITH Tree^ *)
END removeRB;

(*---------------------------------------------------------------------------*)

PROCEDURE treeRemove ((* EIN/ -- *)     Tree : RBTree;
                      (* EIN/AUS *) VAR node : RBItem );

(* Der Knoten <node> wird aus <Tree> entfernt, wobei die Rot-Schwarz-
 * Eigenschaft erhalten bleibt. <node> muss ein gueltiger Wert ungleich
 * 'nil' sein!
 *)

VAR __REG__ delNode  : RBItem;
            succNode : RBItem;
            delSave  : RBItem;
            delColor : RBColor;

BEGIN
 WITH Tree^ DO
   WITH node^ DO
     IF (left = nil) OR (right = nil) THEN
       (* Wenn maximal ein Nachfolger existiert, kann der Knoten
        * ohne Probleme ausgeklinkt werden.
        *)
       delNode := node;
     ELSE
       (* ansonsten wird der Knoten mit dem naechstgroesseren
        * Schluesselwert an Stelle des zu loeschenden Knotens
        * eingesetzt; dieser hat keinen linken Nachfolger.
        *)
       delNode := min(nil, right);
     END;
   END; (* WITH node^ *)

   delSave := delNode;
   WHILE delSave # root DO
     delSave := delSave^.parent;
     DEC(delSave^.size);
     (* Wenn ein Knoten entfernt wird, haben alle Teilbaeume,
      * die von den auf dem Weg zum neuen Blatt erreichten Knoten
      * ausgehen, ein Element weniger.
      *)
   END;

   WITH delNode^ DO
     delColor := color; (* Farbe des geloeschten Knotens merken *)

     (* Der hoechstens eine Nachfolger des zu loeschenden Knotens wird
      * ermittelt (kann auch 'nil' sein).
      *)
     IF left # nil THEN
       succNode := left;
     ELSE
       succNode := right;
     END;

     (* der zu loeschende Knoten wird aus der Verzeigerung
      * ausgeklinkt, ist aber noch ueber 'delNode' referenzierbar.
      *)
     succNode^.parent := parent;
     succNode^.type   := type;
     IF type = ROOT THEN
       root := succNode;
     ELSIF type = LEFTCHILD THEN
       parent^.left  := succNode;
     ELSE
       parent^.right := succNode;
     END;

     IF delNode # node THEN
       (* Wenn <node> zwei Nachfolger hatte und deswegen der
        * naechstgroessere Knoten stattdessen ausgeklinkt wurde,
        * muss dieser noch an Stelle von <node> im Baum eingeklinkt
        * werden.
        * Die alten Werte von <node> muessen erhalten bleiben.
        *)

       parent := node^.parent;
       left   := node^.left;
       right  := node^.right;
       size   := node^.size;
       color  := node^.color;
       type   := node^.type;

       left^.parent  := delNode;
       right^.parent := delNode;
       IF type = ROOT THEN
         root          := delNode;
       ELSIF type = LEFTCHILD THEN
         parent^.left  := delNode;
       ELSE
         parent^.right := delNode;
       END;
     END; (* IF delNode *)
   END; (* WITH delNode^ *)

   (* Der Knoten kann nun endgueltig geloescht werden *)
   DEALLOC(node, heap);

   IF delColor = BLACK THEN
     (* Wenn der geloeschte Knoten die Farbe Schwarz hatte, hat
      * sich die Schwarzhoehe im betreffenden Zweig geaendert,
      * und evtl. stehen nun zwei rote Knoten hintereinander,
      * was korrigiert werden muss.
      *)
     removeRB(Tree, succNode);
   END;
 END; (* WITH Tree^ *)
END treeRemove;

(*---------------------------------------------------------------------------*)

PROCEDURE BlackHeight ((* EIN/ -- *) tree : RBTree ): CARDINAL;

(* Da in einem Rot-Schwarz-Baum die Schwarzhoehe von einem Knoten zu jedem
 * der von ihm aus erreichbaren Blaetter gleich sein muss, ist der Weg
 * beliebig. Hier wird einfach nur links aussen runtergegangen.
 *)
VAR __REG__ bh   : CARDINAL;
    __REG__ node : RBItem;
            x    : INTEGER;

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.BlackHeight: <tree> not defined");
   END;
#endif
   bh   := 0;
   node := root;
   WHILE node # nil DO
     IF node^.color = BLACK THEN
       INC(bh);
     END;
     node := node^.left;
   END;
   RETURN(bh);
 END;
END BlackHeight;

(*---------------------------------------------------------------------------*)

PROCEDURE PreOrder ((* EIN/ -- *) tree  : RBTree;
                    (* EIN/ -- *) visit : VisitProc );

PROCEDURE pre ((* EIN/ -- *) node : RBItem );
BEGIN
 IF node # tree^.nil THEN
   visit(tree, CAST(RBEntry,node));
   pre(node^.left);
   pre(node^.right);
 END;
END pre;

BEGIN (* PreOrder *)
#ifdef __CHECKS__
 IF (tree = NIL) OR (tree^.magic # RBTREEMAGIC) THEN
   RaiseADTException(notAnADT, "RBTrees.PreOrder: <tree> not defined");
 END;
#endif
 pre(tree^.root);
END PreOrder;

(*---------------------------------------------------------------------------*)

PROCEDURE InOrder ((* EIN/ -- *) tree  : RBTree;
                   (* EIN/ -- *) visit : VisitProc );

PROCEDURE in ((* EIN/ -- *) node : RBItem );
BEGIN
 IF node # tree^.nil THEN
   in(node^.left);
   visit(tree, CAST(RBEntry,node));
   in(node^.right);
 END;
END in;

BEGIN (* InOrder *)
#ifdef __CHECKS__
 IF (tree = NIL) OR (tree^.magic # RBTREEMAGIC) THEN
   RaiseADTException(notAnADT, "RBTrees.InOrder: <tree> not defined");
 END;
#endif
 in(tree^.root);
END InOrder;

(*---------------------------------------------------------------------------*)

PROCEDURE PostOrder ((* EIN/ -- *) tree  : RBTree;
                     (* EIN/ -- *) visit : VisitProc );

PROCEDURE post ((* EIN/ -- *) node : RBItem );
BEGIN
 IF node # tree^.nil THEN
   post(node^.left);
   post(node^.right);
   visit(tree, CAST(RBEntry,node));
 END;
END post;

BEGIN (* PostOrder *)
#ifdef __CHECKS__
 IF (tree = NIL) OR (tree^.magic # RBTREEMAGIC) THEN
   RaiseADTException(notAnADT, "RBTrees.PostOrder: <tree> not defined");
 END;
#endif
 post(tree^.root);
END PostOrder;

(*---------------------------------------------------------------------------*)

PROCEDURE Create ((* EIN/ -- *)     keySize   : CARDINAL;
                  (* EIN/ -- *)     infoSize  : CARDINAL;
                  (* EIN/ -- *)     blockSize : CARDINAL;
                  (* EIN/ -- *)     compare   : CompareProc;
                  (* -- /AUS *) VAR tree      : RBTree;
                  (* -- /AUS *) VAR done      : BOOLEAN );

BEGIN
 done := FALSE;
 tree := NIL;
 IF   (keySize = 0)
   OR (infoSize = 0)
   OR (keySize > VAL(CARDINAL,CAST(UNSIGNEDWORD,MAXSIGNEDWORD)))
   OR (VAL(CARDINAL,CAST(UNSIGNEDWORD,MAXSIGNEDWORD)) - keySize < infoSize)
   OR (blockSize = 0)
   OR (blockSize > VAL(CARDINAL,MAXUNSIGNEDWORD))
 THEN
   RETURN;
 END;

 ALLOCATE(tree,  VAL(UNSIGNEDLONG,TSIZE(RBInfo))
                 (* fuer 'nil' *)
               + VAL(UNSIGNEDLONG,TSIZE(RBNode))
               + VAL(UNSIGNEDLONG,keySize));
 IF tree # NIL THEN
   WITH tree^ DO
     InstallADTHeap(VAL(CARDINAL,TSIZE(RBNode)) + keySize + infoSize,
                    blockSize,
                    heap,
                    done);
     IF done THEN
       nil      := ADDADR(tree, TSIZE(RBInfo));
       root     := nil;
       keysize  := VAL(UNSIGNEDWORD,keySize);
       infosize := VAL(UNSIGNEDWORD,infoSize);
       cmp      := compare;
       WITH nil^ DO
         left   := NIL;
         right  := NIL;
         parent := NIL;
         size   := 0;
         color  := BLACK;
         type   := ROOT;
       END;
#ifdef __CHECKS__
       magic    := RBTREEMAGIC;
#endif
     ELSE
       DEALLOCATE(tree,  VAL(UNSIGNEDLONG,TSIZE(RBInfo))
                       + VAL(UNSIGNEDLONG,TSIZE(RBNode))
                       + VAL(UNSIGNEDLONG,keySize));
       tree := NIL;
     END; (* IF done *)
   END; (* WITH tree *)
 END; (* IF tree *)

 IF ~done THEN
   tree := NIL;
 END;
END Create;

(*---------------------------------------------------------------------------*)

PROCEDURE Clear ((* EIN/ -- *) tree : RBTree );
BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Clear: <tree> not defined");
   END;
#endif
   FreeADTHeap(heap);
   root := nil;
   WITH nil^ DO
     (* 'nil' sicherheitshalber neu initialisieren *)
     left   := NIL;
     right  := NIL;
     parent := NIL;
     size   := 0;
     color  := BLACK;
     type   := ROOT;
   END;
 END; (* WITH tree^ *)
END Clear;

(*---------------------------------------------------------------------------*)

PROCEDURE Delete ((* EIN/AUS *) VAR tree : RBTree );
BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Delete: <tree> not defined");
   END;
#endif
   DeInstallADTHeap(heap);
#ifdef __CHECKS__
   magic := 0;
#endif
   root  := NIL;
   nil   := NIL;
   DEALLOCATE(tree,   VAL(UNSIGNEDLONG,TSIZE(RBInfo))
                    + VAL(UNSIGNEDLONG,TSIZE(RBNode))
                    + VAL(UNSIGNEDLONG,keysize));
   tree := NIL;
 END; (* WITH tree^ *)
END Delete;

(*---------------------------------------------------------------------------*)

PROCEDURE IsEmpty ((* EIN/ -- *) tree : RBTree ): BOOLEAN;
BEGIN
#ifdef __CHECKS__
 IF (tree = NIL) OR (tree^.magic # RBTREEMAGIC) THEN
   RaiseADTException(notAnADT, "RBTrees.IsEmpty: <tree> not defined");
 END;
#endif
 RETURN(tree^.root^.size = 0);
END IsEmpty;

(*---------------------------------------------------------------------------*)

PROCEDURE Size ((* EIN/ -- *) tree : RBTree ): CARDINAL;
BEGIN
#ifdef __CHECKS__
 IF (tree = NIL) OR (tree^.magic # RBTREEMAGIC) THEN
   RaiseADTException(notAnADT, "RBTrees.Size: <tree> not defined");
 END;
#endif
 RETURN(tree^.root^.size);
END Size;

(*---------------------------------------------------------------------------*)

PROCEDURE GetKey ((* EIN/ -- *)     tree : RBTree;
                  (* EIN/ -- *)     item : RBEntry;
                  (* -- /AUS *) VAR key  : ARRAY OF ANYTYPE );

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.GetKey: <tree> not defined");
   END;
   IF keysize # VAL(UNSIGNEDWORD,HIGH(key) + 1) THEN
     RaiseADTException(wrongElemSize, "RBTrees.GetKey: wrong key size");
   END;
#endif
   memmove(ADR(key),
           ADDADR(item, VAL(UNSIGNEDLONG,TSIZE(RBNode))),
           VAL(UNSIGNEDLONG,keysize));
 END;
END GetKey;

(*---------------------------------------------------------------------------*)

PROCEDURE GetInfo ((* EIN/ -- *)     tree : RBTree;
                   (* EIN/ -- *)     item : RBEntry;
                   (* -- /AUS *) VAR info : ARRAY OF ANYTYPE );

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.GetInfo: <tree> not defined");
   END;
   IF infosize # VAL(UNSIGNEDWORD,HIGH(info) + 1) THEN
     RaiseADTException(wrongElemSize, "RBTrees.GetInfo: wrong info size");
   END;
#endif
   memmove(ADR(info),
           ADDADR(item, VAL(UNSIGNEDWORD,TSIZE(RBNode)) + keysize),
           VAL(UNSIGNEDLONG,infosize));
 END;
END GetInfo;

(*---------------------------------------------------------------------------*)

PROCEDURE SetInfo ((* EIN/ -- *)     tree : RBTree;
                   (* EIN/ -- *) VAR info : ARRAY OF ANYTYPE;
                   (* EIN/ -- *)     item : RBEntry          );

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.SetInfo: <tree> not defined");
   END;
   IF infosize # VAL(UNSIGNEDWORD,HIGH(info) + 1) THEN
     RaiseADTException(wrongElemSize, "RBTrees.SetInfo: wrong info size");
   END;
#endif
   memmove(ADDADR(item, VAL(UNSIGNEDWORD,TSIZE(RBNode)) + keysize),
           ADR(info),
           VAL(UNSIGNEDLONG,infosize));
 END;
END SetInfo;

(*---------------------------------------------------------------------------*)

PROCEDURE Lookup ((* EIN/ -- *)     tree : RBTree;
                  (* EIN/ -- *) VAR key  : ARRAY OF ANYTYPE ): RBEntry;

VAR rank : CARDINAL;

BEGIN
#ifdef __CHECKS__
 IF (tree = NIL) OR (tree^.magic # RBTREEMAGIC) THEN
   RaiseADTException(notAnADT, "RBTrees.Lookup: <tree> not defined");
 END;
 IF tree^.keysize # VAL(UNSIGNEDWORD,HIGH(key) + 1) THEN
   RaiseADTException(wrongElemSize, "RBTrees.Lookup: wrong key size");
 END;
#endif
 RETURN(find(tree, key, rank));
END Lookup;

(*---------------------------------------------------------------------------*)

PROCEDURE Access ((* EIN/ -- *)     tree : RBTree;
                  (* EIN/ -- *) VAR key  : ARRAY OF ANYTYPE;
                  (* -- /AUS *) VAR info : ARRAY OF ANYTYPE );

VAR rank : CARDINAL;
    node : RBItem;

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Access: <tree> not defined");
   END;
   IF keysize # VAL(UNSIGNEDWORD,HIGH(key) + 1) THEN
     RaiseADTException(wrongElemSize, "RBTrees.Access: wrong key size");
   END;
   IF infosize # VAL(UNSIGNEDWORD,HIGH(info) + 1) THEN
     RaiseADTException(wrongElemSize, "RBTrees.Access: wrong info size");
   END;
#endif
   node := find(tree, key, rank);
   IF node = NIL THEN
     RaiseADTException(noEntry, "RBTrees.Access: no such element");
   ELSE
     memmove(ADR(info),
             ADDADR(node, VAL(UNSIGNEDWORD,TSIZE(RBNode)) + keysize),
             VAL(UNSIGNEDLONG,infosize));
   END;
 END;
END Access;

(*---------------------------------------------------------------------------*)

PROCEDURE Insert ((* EIN/ -- *)     tree : RBTree;
                  (* EIN/ -- *) VAR key  : ARRAY OF ANYTYPE;
                  (* EIN/ -- *) VAR info : ARRAY OF ANYTYPE ): RBEntry;

VAR __REG__ newNode         : RBItem;
            newNodeSave     : RBItem;
            parentNeighbour : RBItem;
            replace         : BOOLEAN;

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Insert: <tree> not defined");
   END;
   IF keysize # VAL(UNSIGNEDWORD,HIGH(key) + 1) THEN
     RaiseADTException(wrongElemSize, "RBTrees.Insert: wrong key size");
   END;
   IF infosize # VAL(UNSIGNEDWORD,HIGH(info) + 1) THEN
     RaiseADTException(wrongElemSize, "RBTrees.Insert: wrong info size");
   END;
#endif
   IF root^.size = MAXUNSIGNEDWORD THEN
     RETURN(NIL);
   END;

   treeInsert(tree, key, info, newNodeSave, replace);
   IF ~replace THEN
     IF newNodeSave # NIL THEN
       newNode        := newNodeSave;
       newNode^.color := RED;

       (* Der neue Knoten wurde wie in einen normalen Suchbaum
        * einsortiert; jetzt muss die Rot-Schwarz-Eigenschaft
        * sichergestellt werden.
        *)

       WHILE (newNode # root) & (newNode^.parent^.color = RED) DO

         (* Die Bedingung der WHILE-Schleife garantiert, dass
          * newNode^.parent^.parent existiert, da die Wurzel durch
          * Einfuegen mit dieser Prozedur immer schwarz ist und deswegen
          * ueber newNode^.parent noch mindestens die Wurzel steht.
          *)

         IF (newNode^.parent^.type = LEFTCHILD) THEN

           (* Nachbar des Vorgaengers ermitteln *)
           parentNeighbour := newNode^.parent^.parent^.right;

           IF parentNeighbour^.color = RED THEN

             (* FALL 1:
              *
              * Wenn der Vorgaenger-Nachbar ebenfalls rot ist wie
              * der Vorgaenger, koennen sowohl Vorgaenger als auch
              * Nachbar schwarz eingefaerbt werden und deren gemeinsamer
              * Vorgaenger rot (dieser war vorher schwarz eingefaerbt,
              * da er rot eingefaerbte Nachfolger hatte); damit ist der
              * Konflikt mit dem neu eingefuegten Knoten beseitigt und
              * die Schwarzhohe wurde nicht veraendert.
              *)

             WITH newNode^.parent^ DO
               color                  := BLACK;
               parentNeighbour^.color := BLACK;
               parent^.color          := RED;
             END;

             (* Da mit dem nun rot eingefaerbten Knoten das gleiche
              * Problem auftreten kann (dessen Vorgaenger ist evtl.
              * rot), wird die Korrekturschleife nun mit diesem
              * wiederholt bis max. zur Wurzel.
              *)
             newNode := newNode^.parent^.parent;

           ELSE (* Der Vorgaenger-Nachbar ist schwarz eingefaerbt *)

             IF newNode^.type = RIGHTCHILD THEN

               (* FALL 2:
                *
                * Falls der neue Knoten ein rechter Nachfolger ist,
                * wird zunaechst eine Linksrotation des Vorgaengers
                * durchgefuehrt. Dadurch besteht das Problem jetzt
                * einheitlich in einem rot eingefaerbten Knoten, der
                * der LINKE Nachfolger eines ebenfalls rot eingefaerbten
                * Vorgaengers ist (der fruehere rote Vorgaenger ist nun
                * der linke Nachfolger des neuen Knotens).
                * Da an der Rotation keine schwarz eingefaerbten Knoten
                * beteiligt sind, kann auch die Schwarzhoehe nicht
                * veraendert werden.
                *)
               newNode := newNode^.parent;
               leftRotate(tree, newNode);
             END;

             (* FALL 3:
              *
              * Der rot eingefaerbte Knoten ist linker Nachfolger eines
              * ebenfalls rot eingefaerbten Knotens. Da der Nachbar des
              * Vorgaengers schwarz eingefaerbt ist, und der Vorgaenger
              * des Vorgaengers ebenfalls (sonst duerfte er keinen rot
              * eingefaerbten Nachfolger haben), kann der Vorgaenger
              * nun schwarz und dessen Vorgaenger rot eingefaerbt werden,
              * und eine Rechts-Rotation mit diesem ausgefuehrt werden,
              * so dass sowhl die Schwarzhoehe erhalten bleibt, als auch
              * keine aufeinanderfolgenden rot eingefaerbten Knoten mehr
              * existieren (der schwarz eingefaerbte Vorgaenger des
              * neuen roten Knotens ist jetzt Wurzel des Teilbaums anstatt
              * seine ehemaligen schwarzen Vorgaengers, der nun sein
              * rechter, rot eingefaerbter Nachfolger ist).
              *)

             WITH newNode^.parent^ DO
               color         := BLACK;
               parent^.color := RED;
               rightRotate(tree, parent);
             END;
           END;
         ELSE
           (* das gleiche, nur 'left' und 'right' bzw. "leftRotate()"
            * und "rightRotate()" vertauscht.
            *)
           parentNeighbour := newNode^.parent^.parent^.left;
           IF parentNeighbour^.color = RED THEN
             WITH newNode^.parent^ DO
               color                  := BLACK;
               parentNeighbour^.color := BLACK;
               parent^.color          := RED;
             END;
             newNode := newNode^.parent^.parent;
           ELSE
             IF newNode^.type = LEFTCHILD THEN
               newNode := newNode^.parent;
               rightRotate(tree, newNode);
             END;
             WITH newNode^.parent^ DO
               color         := BLACK;
               parent^.color := RED;
               leftRotate(tree, parent);
             END;
           END;
         END;
       END; (* WHILE *)
       root^.color := BLACK;
     END; (* IF newNode # NIL *)
   END; (* IF ~replace *)
   RETURN(CAST(RBEntry,newNodeSave));
 END; (* WITH tree^ *)
END Insert;

(*---------------------------------------------------------------------------*)

PROCEDURE Remove ((* EIN/ -- *)     tree : RBTree;
                  (* EIN/ -- *) VAR key  : ARRAY OF ANYTYPE );

VAR delNode    : RBItem;
    parentNode : RBItem;
    rank       : CARDINAL;

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Remove: <tree> not defined");
   END;
   IF keysize # VAL(UNSIGNEDWORD,HIGH(key) + 1) THEN
     RaiseADTException(wrongElemSize, "RBTrees.Remove: wrong key size");
   END;
#endif

   delNode := find(tree, key, rank);
   IF delNode # nil THEN
     (* Der Eintrag existiert und kann entfernt werden *)
     treeRemove(tree, delNode);
   END;
 END; (* WITH tree^ *)
END Remove;

(*---------------------------------------------------------------------------*)

PROCEDURE RemoveItem ((* EIN/ -- *)     tree : RBTree;
                      (* EIN/AUS *) VAR item : RBEntry );

VAR entry : RBItem;

BEGIN
#ifdef __CHECKS__
 IF (tree = NIL) OR (tree^.magic # RBTREEMAGIC) THEN
   RaiseADTException(notAnADT, "RBTrees.RemoveItem: <tree> not defined");
 END;
#endif
 entry := item;
 item  := NIL;
 treeRemove(tree, entry);
END RemoveItem;

(*---------------------------------------------------------------------------*)

PROCEDURE Min ((* EIN/ -- *) tree : RBTree ): RBEntry;
BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Min: <tree> not defined");
   END;
#endif
   IF root = nil THEN
     RETURN(NIL);
   ELSE
     RETURN(CAST(RBEntry,min(nil, root)));
   END;
 END;
END Min;

(*---------------------------------------------------------------------------*)

PROCEDURE Max ((* EIN/ -- *) tree : RBTree ): RBEntry;
BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Max: <tree> not defined");
   END;
#endif
   IF root = nil THEN
     RETURN(NIL);
   ELSE
     RETURN(CAST(RBEntry,max(nil, root)));
   END;
 END;
END Max;

(*---------------------------------------------------------------------------*)

PROCEDURE Succ ((* EIN/ -- *) tree : RBTree;
                (* EIN/ -- *) item : RBEntry ): RBEntry;

VAR __REG__ succ : RBItem;

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Succ: <tree> not defined");
   END;
#endif

   succ := item;
   IF succ^.right # nil THEN
     (* Wenn der Knoten einen rechten Nachfolger besitzt, d.h.
      * wenn es Knoten mit groesserem Schluessel gibt, ist der
      * naechstgroessere der kleinste der groesseren.
      *)
     RETURN(CAST(RBEntry,min(nil, succ^.right)));
   END;

   (* Hat der Knoten keinen rechten Nachfolger, ist der naechst-
    * groessere Knoten der erste, in dessen linkem Teilbaum <item>
    * steht, da dieser ja groesser als alle seine Nachfolger im linken
    * Teilbaum ist. D.h. der naechstgroessere ist der Vorgaenger des
    * ersten Knotens (von unten nach oben gesehen), der ein linker
    * Nachfolger ist.
    * Ist kein Knoten ein linker Nachfolger, ist man bei der Wurzel
    * angelangt, und es gibt keinen groesseren Knoten.
    *)

   WHILE succ^.type = RIGHTCHILD DO
     succ := succ^.parent;
   END;
   IF succ^.type = ROOT THEN
     RETURN(NIL);
   ELSE
     RETURN(CAST(RBEntry,succ^.parent));
   END;
 END;
END Succ;

(*---------------------------------------------------------------------------*)

PROCEDURE Pred ((* EIN/ -- *) tree : RBTree;
                (* EIN/ -- *) item : RBEntry ): RBEntry;

VAR __REG__ pred : RBItem;

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Pred: <tree> not defined");
   END;
#endif

   pred := item;
   IF pred^.left # nil THEN
     (* Wenn der Knoten einen linken Nachfolger besitzt, d.h.
      * wenn es Knoten mit kleinerem Schluessel gibt, ist der
      * naechstkleinere der groesste der kleineren.
      *)
     RETURN(CAST(RBEntry,max(nil, pred^.left)));
   END;

   (* Hat der Knoten keinen linken Nachfolger, ist der naechst-
    * kleinere Knoten der erste, in dessen rechtem Teilbaum <item>
    * steht, da dieser ja kleiner als alle seine Nachfolger im rechten
    * Teilbaum ist. D.h. der naechstkleinere ist der Vorgaenger des
    * ersten Knotens (von unten nach oben gesehen), der ein rechter
    * Nachfolger ist.
    * Ist kein Knoten ein rechter Nachfolger, ist man bei der Wurzel
    * angelangt, und es gibt keinen kleineren Knoten.
    *)

   WHILE pred^.type = LEFTCHILD DO
     pred := pred^.parent;
   END;
   IF pred^.type = ROOT THEN
     RETURN(NIL);
   ELSE
     RETURN(CAST(RBEntry,pred^.parent));
   END;
 END;
END Pred;

(*---------------------------------------------------------------------------*)

PROCEDURE Select ((* EIN/ -- *) tree : RBTree;
                  (* EIN/ -- *) i    : CARDINAL ): RBEntry;

VAR __REG__ rank : CARDINAL;
    __REG__ node : RBItem;

BEGIN
 WITH tree^ DO
#ifdef __CHECKS__
   IF (tree = NIL) OR (magic # RBTREEMAGIC) THEN
     RaiseADTException(notAnADT, "RBTrees.Select: <tree> not defined");
   END;
#endif

   IF (i = 0) OR (i > VAL(CARDINAL,root^.size)) THEN
     (* Sicherstellen, dass auch wirklich Position <i> existiert *)
     RETURN(NIL);
   ELSE
     node := root;

     (* Da das i-tkleinste Element eines binaeren Suchbaums das i-te bei
      * einem Inorder-Durchlauf besuchte ist, und bei einem Inorder-Durchlauf
      * zuerst alle Elemente des linken Teilbaums eines Knotens besucht werden,
      * ist die Position von 'node' in dem von ihm ausgehenden Teilbaum
      * um Eins groesser als die Anzahl der Knoten im linken Teilbaum.
      * Da von der Wurzel ausgegangen wird, kann ueber die Anzahl der
      * Elemente des jeweiligen Teilbaums immer entschieden werden, ob sich
      * das gewuenschte Element im linken oder rechten Teilbaum befindet.
      *)

     LOOP
       rank := node^.left^.size + 1; (* Position des betr. Knotens *)
       IF i = rank THEN
         (* gewuenschtes Element gefunden *)
         EXIT;
       ELSIF i < rank THEN
         (* Wenn die Position des gewuenschten Elements kleiner
          * ist als die Position des augenblicklichen Knotens,
          * liegt das gewuenschte Element im linken Teilbaum.
          *)
         node := node^.left;
       ELSE (* i > rank *)
         (* Wenn die Position des gewuenschten Elements dagegen
          * groesser ist, muss es im rechten Teilbaum liegen.
          * Da 'rank' Elemente vor dem ersten Element im rechten Teilbaum
          * liegen, wird dieser Wert von der Position des gewuenschten
          * Elements subtrahiert, um die Position im rechten Teilbaum
          * zu bestimmen.
          *)
         node := node^.right;
         DEC(i, rank);
       END;
     END;
     RETURN(CAST(RBEntry,node));
   END;
 END;
END Select;

(*---------------------------------------------------------------------------*)

PROCEDURE Rank ((* EIN/ -- *)     tree : RBTree;
                (* EIN/ -- *) VAR key  : ARRAY OF ANYTYPE ): CARDINAL;

VAR rank : CARDINAL;

BEGIN
#ifdef __CHECKS__
 IF (tree = NIL) OR (tree^.magic # RBTREEMAGIC) THEN
   RaiseADTException(notAnADT, "RBTrees.Rank: <tree> not defined");
 END;
#endif
 IF find(tree, key, rank) = NIL THEN
   RETURN(0);
 ELSE
   RETURN(rank);
 END;
END Rank;

(*---------------------------------------------------------------------------*)

PROCEDURE CheckTree ((* EIN/ -- *) tree  : RBTree;
                     (* EIN/ -- *) print : VisitProc );

#ifdef _DEBUG
VAR BH : CARDINAL;

PROCEDURE checknode ((* EIN/ -- *) node : RBEntry );

VAR n : RBItem;

BEGIN (* checknode *)
 WITH tree^ DO
   n := CAST(RBItem,node);
   WITH n^ DO
     IF    (left  # nil) & (left^.parent  # n)
        OR (right # nil) & (right^.parent # n)
     THEN
       WriteString("*** Verzeigerung bei Knoten : ");
       print(tree, node);
       WriteLn;
       RETURN;
     END;
     IF size # left^.size + right^.size + 1 THEN
       WriteString("*** SIZE bei Knoten : ");
       print(tree, node);
       WriteString(" = ");
       WriteCard(VAL(UNSIGNEDLONG,size), 1);
       WriteLn;
     END;
     IF    (VAL(CARDINAL,color) > 1)
        OR (color = RED) & ((left^.color = RED) OR (right^.color = RED))
     THEN
       WriteString("*** RED-Nachfolger bei RED-Knoten : ");
       print(tree, node);
       WriteLn;
     END;
     IF    (VAL(CARDINAL,type) > 2)
        OR (type = ROOT)       & (node # root)
        OR (type = LEFTCHILD)  & (node # parent^.left)
        OR (type = RIGHTCHILD) & (node # parent^.right)
     THEN
       WriteString("*** TYP bei Knoten : ");
       print(tree, node);
       WriteLn;
     END;
     IF    (type = LEFTCHILD)  & (cmp(ADDADR(n, TSIZE(RBNode)), ADDADR(parent, TSIZE(RBNode))) >= 0)
        OR (type = RIGHTCHILD) & (cmp(ADDADR(n, TSIZE(RBNode)), ADDADR(parent, TSIZE(RBNode))) <= 0)
     THEN
       WriteString("*** Ordnung verletzt bei Knoten : ");
       print(tree, node);
       WriteLn;
     END;
   END;
 END;
END checknode;

PROCEDURE trbh ((* EIN/ -- *) node : RBItem;
                (* EIN/ -- *) bh   : CARDINAL );

BEGIN (* trbh *)
 WITH tree^ DO
   WITH node^ DO
     IF node # nil THEN
       IF color = BLACK THEN
         INC(bh);
       END;
       IF (left = nil) & (right = nil) THEN
         (* Blatt *)
         IF bh # BH THEN
           WriteString("*** Schwarzh”he bei Knoten : ");
           print(tree, node);
           WriteString(" = ");
           WriteCard(VAL(UNSIGNEDLONG,bh), 1);
           WriteLn;
         END;
       END;
       checknode(node);
       trbh(left, bh);
       trbh(right, bh);
     END;
   END;
 END;
END trbh;

BEGIN (* CheckTree *)
 IF (tree = NIL) OR (tree^.magic # RBTREEMAGIC) OR (tree^.nil = NIL) THEN
   WriteString("*** Baum undefiniert!");
   RETURN;
 END;
 WITH tree^.nil^ DO
   IF size # 0 THEN
     WriteString("*** SIZE von `nil' nicht Null: ");
     WriteCard(VAL(UNSIGNEDLONG,tree^.nil^.size), 1);
     WriteLn;
   END;
   IF color # BLACK THEN
     WriteString("*** `nil' nicht schwarz");
     WriteLn;
   END;
   IF (left # NIL) OR (right # NIL) THEN
     WriteString("*** Verzeigerung von `nil'");
     WriteLn;
   END;
 END;
 BH := BlackHeight(tree);
 trbh(tree^.root, 0);
#endif
END CheckTree;

(*--------------------------------------------------------------------------*)

PROCEDURE PrintTree ((* EIN/ -- *) tree  : RBTree;
                     (* EIN/ -- *) verb  : BOOLEAN;
                     (* EIN/ -- *) print : VisitProc );
#ifdef _DEBUG

PROCEDURE inorder ((* EIN/ -- *) node   : RBItem;
                   (* EIN/ -- *) height : INTEGER );

VAR i : INTEGER;

BEGIN
 IF node # tree^.nil THEN
   WITH node^ DO
     (* Zuerst den rechten Teilbaum. Dadurch ist die Darstellung einfach
      * um 90 Grad gedreht (die kleineren Elemente unterhalb der Wurzel).
      *)
     inorder(right, height + 1);
     FOR i := 0 TO height - 1 DO
       Write(' ');
     END;
     IF type = LEFTCHILD THEN
       WriteString("\=");
     ELSIF type = RIGHTCHILD THEN
       WriteString("/=");
     ELSIF type = ROOT THEN
       WriteString("<=");
     END;
     IF verb THEN
       WriteCard(VAL(UNSIGNEDLONG,size), 1);
       IF color = BLACK THEN
         WriteString("B=");
       ELSIF color = RED THEN
         WriteString("R=");
       END;
     END;
     print(tree, node);
     WriteLn;
     inorder(left, height + 1);
   END;
 END;
END inorder;

BEGIN (* PrintTree *)
 WriteString("Der Baum besteht aus (INORDER):");
 WriteLn;
 inorder(tree^.root, 0);
 WriteLn;
#endif
END PrintTree;

END RBTrees.

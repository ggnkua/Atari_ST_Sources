MODULE SortTest;

(* Demo test program for BinTree *)

IMPORT Struct := BinTree, IO;

TYPE
     Text = ARRAY 130 OF CHAR;
     p0 = POINTER TO r0;
     r0 = RECORD (Struct.Node)
            num: INTEGER        (* dient als SortierschlÅssel *)
          END;
     p00 = POINTER TO r00;
     r00 = RECORD (r0)
             value: INTEGER 
           END;
     p01 = POINTER TO r01;
     r01 = RECORD (r0)
             text: Text
           END;
(*
     r02 = RECORD x: INTEGER END;
*)
            
VAR
    root, v: Struct.pNode;
    v0     : p0;
    v00    : p00;
    v01    : p01;
    key    : INTEGER;
    ch     : CHAR;
            
PROCEDURE^ Print(node: Struct.pNode);

PROCEDURE compare(node1, node2: Struct.pNode): SHORTINT;
BEGIN
  IF (node1 IS p0) & (node1 IS p0) THEN
    WITH node1: p0 DO
      WITH node2: p0 DO
        IF node1.num < node2.num THEN RETURN -1
        ELSIF node1.num = node2.num THEN RETURN 0
        ELSE RETURN 1
        END
      END
    END
  ELSE
    RETURN -1
  END
END compare;

PROCEDURE visit(node: Struct.pNode);
BEGIN
  IF node IS p0 THEN
    IO.WriteString("SchlÅssel:"); IO.WriteInt(node(p0).num, 5);
    Print(node)
  ELSE
    IO.WriteString("visit: Knotentyp unbekannt!"); IO.WriteLn
  END
END visit;

PROCEDURE find(node: Struct.pNode): SHORTINT;
BEGIN
  IF node IS p0 THEN
    WITH node: p0 DO
      IF key < node.num THEN RETURN -1
      ELSIF key = node.num THEN RETURN 0
      ELSE RETURN 1
      END
    END
  ELSE
    RETURN -1
  END
END find;

PROCEDURE Menu;
BEGIN
  IO.WriteString("Menue"); IO.WriteLn;
  IO.WriteString("-----"); IO.WriteLn;
  IO.WriteLn;
  IO.WriteString("(E)infÅgen"); IO.WriteLn;
  IO.WriteString("(L)îschen"); IO.WriteLn;
  IO.WriteString("(S)uchen"); IO.WriteLn;
  IO.WriteString("(T)raversieren"); IO.WriteLn;
  IO.WriteString("(M)enue anzeigen"); IO.WriteLn;
  IO.WriteString("(B)eenden"); IO.WriteLn
END Menu;

PROCEDURE Insert;

VAR typ: CHAR;

BEGIN
  IO.WriteString("  SchlÅssel:"); IO.ReadInt(key); IO.WriteLn;
  REPEAT
    IO.WriteString("  (Z)ahl oder (S)tring:"); IO.Read(typ); IO.WriteLn;
    typ:=CAP(typ);
    IF (typ # "Z") & (typ # "S") THEN
      IO.WriteString("    Nur 'Z' oder 'S'!"); IO.WriteLn
    END
  UNTIL (typ = "Z") OR (typ = "S");
  IF typ = "Z" THEN
    NEW(v00);
    IF v00 # NIL THEN
      v00.num:=key;
      IO.WriteString("  Zahl:"); IO.ReadInt(v00.value); IO.WriteLn;
      Struct.Insert(root, v00, compare)
    ELSE
      IO.WriteString("Insert: Kein freier Speicher mehr!"); IO.WriteLn
    END
  ELSE
    NEW(v01);
    IF v01 # NIL THEN
      v01.num:=key;
      IO.WriteString("  String:"); IO.ReadString(v01.text); IO.WriteLn;
      Struct.Insert(root, v01, compare)
    ELSE
      IO.WriteString("Insert: Kein freier Speicher mehr!"); IO.WriteLn
    END
  END
END Insert;

PROCEDURE Print(node: Struct.pNode);
BEGIN
  IF node IS p00 THEN
    IO.WriteString("  Zahl:"); IO.WriteInt(node(p00).value, 0); IO.WriteLn
  ELSIF node IS p01 THEN
    IO.WriteString("  String:"); IO.WriteString(node(p01).text); IO.WriteLn
  ELSE
    IO.WriteString("Print: Knotentyp ist nicht bekannt!"); IO.WriteLn
  END
END Print;

BEGIN
  root := NIL;
  IO.WriteString("SortTest"); IO.WriteLn;
  IO.WriteString("========"); IO.WriteLn;
  IO.WriteLn;
  Menu;
  REPEAT
    IO.WriteLn;
    IO.WriteString("Auswahl:"); IO.Read(ch); IO.WriteLn;
    IO.WriteLn;
    ch := CAP(ch);
    CASE ch OF
      "M", "?": Menu
    | "E": Insert
    | "L":
      IO.WriteString("  SchlÅssel:"); IO.ReadInt(key); IO.WriteLn;
      v := Struct.Find(root, find);
      IF v # NIL THEN
        Struct.Delete(root, v);
        IO.WriteString("  ... wurde gelîscht!"); IO.WriteLn
      ELSE
        IO.WriteString("  ... wurde nicht gefunden!"); IO.WriteLn
      END
    | "S":
      IO.WriteString("  SchlÅssel:"); IO.ReadInt(key); IO.WriteLn;
      v := Struct.Find(root, find);
      IF v # NIL THEN
        IO.WriteString("  ... gefunden:"); IO.WriteLn;
        Print(v)
      ELSE
        IO.WriteString("  ... wurde nicht gefunden!"); IO.WriteLn
      END
    | "T":
      Struct.Traverse(root, visit)
    | "B": (* Programmende *)
    ELSE
      IO.WriteString("SortTest: Unbekannter Befehl!"); IO.WriteLn
    END
  UNTIL ch = "B";
  IO.WriteString("SortTest Ende"); IO.WriteLn
END SortTest.


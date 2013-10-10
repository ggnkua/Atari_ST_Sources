DEFINITION MODULE CompTree;

(*
 * Wertet ID-BÑume des Compilers aus.
 *)

(*$H+,Z+*)

FROM SYSTEM IMPORT ADDRESS;
FROM Strings IMPORT String;

VAR Buffer: ADDRESS;            (* untere Grenze vom Tree *)

VAR TreeBase: ADDRESS;          (* A1-Register *)
    DisplayStack: ADDRESS;      (* A6-Register *)
    RelocationStack: ADDRESS;   (* RStkPtr     *)
  (*
   * MÅssen von auûen zugewiesen werden, 'DisplayStack' und 'RelocationStack'
   * werden nur fÅr 'ScanWholeTree' benîtigt.
   *)

TYPE PtrItem = LONGINT;

CONST NoItem = VAL (PtrItem, 0);

TYPE TreeProc = PROCEDURE ( REF (* name: *) ARRAY OF CHAR,
                                (* item: *) PtrItem );

     TreeType = (local, newscope, global, module, pervasive);
     NewTreeProc = PROCEDURE ( TreeType ): BOOLEAN;

TYPE EntryType = (const, pointer, scope);
     ItemEntry = RECORD
                   name: String;
                   CASE type: EntryType OF
                     const  : constVal: LONGCARD |
                     scope,
                     pointer: ptrVal: PtrItem
                   END;
                 END;
     ItemProc  = PROCEDURE ( REF (* entry: *) ItemEntry, (* more: *) BOOLEAN );

TYPE ItemFlags = SET OF [0..7];
     ItemDesc  = RECORD
                   flag: ItemFlags;
                   kind: CARDINAL;
                 END;

PROCEDURE ScanWholeTree (scanner: TreeProc; new: NewTreeProc);

PROCEDURE ScanLocalTree (scanner: TreeProc; tree: PtrItem);

PROCEDURE FindItemByName (REF name: ARRAY OF CHAR; VAR item: PtrItem);

PROCEDURE GetNameOfItem (item: PtrItem;
                         VAR name: ARRAY OF CHAR; VAR found: BOOLEAN);

PROCEDURE GetItemDesc (item: PtrItem; VAR desc: ItemDesc): BOOLEAN;
PROCEDURE Kind (REF desc: ItemDesc): String;
PROCEDURE Flags (REF desc: ItemDesc): String;

PROCEDURE SystemType (REF desc: ItemDesc): BOOLEAN;
  (* TRUE, wenn's ein bekannter Typ ist, der nicht tiefer beschrieben
     werden braucht (z.B. CARDINAL) *)

PROCEDURE ScanItem (scanner: ItemProc; item: PtrItem);

PROCEDURE LoadDef (REF name: ARRAY OF CHAR);
  (*
   * LÑdt und decodiert ein Def-Modul. Dabei wird Speicher alloziert
   * und TreeBase entspr. gesetzt. Alter Speicher wird vorher freigegeben.
   * Scannen mit 'ScanLocalTree (scanner, 0)'.
   *)

END CompTree.

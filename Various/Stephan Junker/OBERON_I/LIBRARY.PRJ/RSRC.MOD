MODULE Rsrc;

(* Rsrc not only contains the TOS routines for resource files but also
   routines for using resource files included in the code. This is
   necessary for accessories *)

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |28.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM, AES, Objc, Form, Fsel, FN:=FileName, Str:= Strings, Appl,
       Task, Items;

CONST
  RTREE*          = 0;
  ROBJECT*        = 1;
  RTEDINFO*       = 2;
  RICONBLK*       = 3;
  RBITBLK*        = 4;
  RSTRING*        = 5;
  RIMGDATA*       = 6;
  ROBJSPEC*       = 7;
  RTEPTEXT*       = 8;
  RTEPTMPLT*      = 9;
  RTEPVALID*      = 10;
  RIBPMASK*       = 11;
  RIBPDATA*       = 12;
  RIBPTEXT*       = 13;
  RBIPDATA*       = 14;
  RFRSTR*         = 15;
  RFRIMG*         = 16;


TYPE
  header* = RECORD
              Version*     : INTEGER;
              ObjectPos*   : INTEGER;
              TedinfoPos*  : INTEGER;
              IconblkPos*  : INTEGER;
              BitblkPos*   : INTEGER;
              FreeStrPos*  : INTEGER;
              StringPos*   : INTEGER;
              ImagePos*    : INTEGER;
              FreeImgPos*  : INTEGER;
              TreeTblPos*  : INTEGER;
              NumObjects*  : INTEGER;
              NumTrees*    : INTEGER;
              NumTedinfos* : INTEGER;
              NumIcons*    : INTEGER;
              NumBitblks*  : INTEGER;
              NumStrings*  : INTEGER;
              NumImages*   : INTEGER;
              RscSize*     : INTEGER;
            END(*RECORD*);


TYPE objptr     = POINTER TO ARRAY 1300 OF Objc.object;
     headptr    = POINTER TO header;

VAR
  rsrcFiles : Items.List;

PROCEDURE Load* (Name : ARRAY OF CHAR) : BOOLEAN;
  VAR n,p : ARRAY 80 OF CHAR;
      f : Items.Item;
 BEGIN
  AES.AddrIn[0] := S.ADR(Name);
  AES.Call(6E000101H);
  IF AES.IntOut[0] <= 0 THEN
    FN.GetName(Name,n);
    FN.GetPath(Name,p);
    Str.Append('*.RSC',p);
    IF (Form.Alert(1,'[1][RSC file not found][Search|Cancel]') = 1)
       AND Fsel.ExInput(p,n,'RSC-Datei laden') THEN
      AES.AddrIn[0] := S.ADR(n);
      AES.Call(6E000101H);
    ELSE
      RETURN FALSE
    END(*IF*);
  END(*IF*);
  IF AES.IntOut[0] > 0 THEN
    NEW(f); rsrcFiles.AddItem(f, AES.Global.Rsrcaddr);
    RETURN TRUE
  END;
  RETURN FALSE
 END Load;

PROCEDURE Free* ();
 BEGIN
  rsrcFiles.FindAndDelete( AES.Global.Rsrcaddr);
  AES.Call(6F000100H);
 END Free;

PROCEDURE FreeRsrc;
 BEGIN
  IF Task.level = 0 THEN
    WHILE rsrcFiles.root # NIL DO
      AES.Global.Rsrcaddr := rsrcFiles.root(Items.Item).itemId;
      Free;
    END;
  END;
 END FreeRsrc;

PROCEDURE GetAddr* (Object : INTEGER) : LONGINT;
 BEGIN
  AES.IntIn[0] := 0;
  AES.IntIn[1] := Object;
  AES.Call(70020100H);
  RETURN AES.AddrOut[0]
 END GetAddr;

PROCEDURE ExtGetAddr* (Type : INTEGER; Object : INTEGER) : LONGINT;
 BEGIN
  AES.IntIn[0] := Type;
  AES.IntIn[1] := Object;
  AES.Call(70020100H);
  RETURN AES.AddrOut[0]
 END ExtGetAddr;

PROCEDURE SetAddr* (Object : INTEGER; Addr : LONGINT);
 BEGIN
  AES.IntIn[0] := 0;
  AES.IntIn[1] := Object;
  AES.AddrIn[0] := Addr;
  AES.Call(71020101H);
 END SetAddr;

PROCEDURE Obfix* (Tree : LONGINT; Object : INTEGER);
 BEGIN
  AES.IntIn[0] := Object;
  AES.AddrIn[0] := Tree;
  AES.Call(72010101H);
 END Obfix;

PROCEDURE CountObjects(Ptr : headptr; VAR ObPtr : objptr) : INTEGER;
 BEGIN
  ObPtr := S.VAL(LONGINT,Ptr) + LONG(Ptr.ObjectPos);
  RETURN (Ptr.TreeTblPos - Ptr.ObjectPos) DIV 24
 END CountObjects;

PROCEDURE CorrectAddresses(BaseAddr : LONGINT; VAR Object : Objc.object);
  VAR Type : INTEGER; TEdPtr : Objc.tedinfoptr; BitPtr : Objc.bitblkptr;
 BEGIN Type := Object.Type - 20;
  IF Type IN {1,2,3,6,8,9,10,11,12} THEN
    INC(Object.ObSpec,BaseAddr);
    IF Type IN {1,2,9,10,11} THEN TEdPtr := Object.ObSpec;
      INC(TEdPtr.Text,BaseAddr);
      INC(TEdPtr.Template,BaseAddr);
      INC(TEdPtr.Valid,BaseAddr);
    ELSIF Type = 3 THEN BitPtr := Object.ObSpec;
      INC(BitPtr.Data,BaseAddr);
    END(*IF*);
  END(*IF*);
 END CorrectAddresses;

PROCEDURE Init* (BaseAddr : LONGINT);
  (* initializes an integrated resource file. BaseAddr is the address of
     the procedure containig the resource file :

    PROCEDURE Procedure;
     BEGIN
      SYSTEM.INLINE(...); (* the resource file *)
    END Procedure;
    ...
    Rsrc.Init(S.ADR(Procedure)); *)

  VAR Ptr   : headptr;
      ObPtr : objptr;
      NumOb,i : INTEGER;
 BEGIN
  INC(BaseAddr,4); Ptr := BaseAddr;
  NumOb := CountObjects(Ptr,ObPtr); i := 0;
  WHILE i < NumOb DO
    CorrectAddresses(BaseAddr,ObPtr[i]);
    Obfix(S.VAL(LONGINT,ObPtr),i); INC(i);
  END(*WHILE*);
 END Init;

PROCEDURE TreeAddr* (BaseAddr : LONGINT; Index : INTEGER) : LONGINT;
 (* returns the tree address for an integrated resource file. Use it instead
    of GetAddr *)
  VAR Ptr : POINTER TO ARRAY 50 OF LONGINT;
      ptr : headptr;
 BEGIN
  INC(BaseAddr,4); ptr := BaseAddr;
  Ptr := LONG(ptr.TreeTblPos) + BaseAddr;
  RETURN Ptr[Index] + BaseAddr
 END TreeAddr;

BEGIN
  NEW(rsrcFiles); rsrcFiles.Init;
  Task.StoreExit(FreeRsrc);
END Rsrc.

MODULE Objc;

(* changes :
author     |date     |change
----------------------------------------------------------------------------
S. Junker  |28.1.93  |correction for Oberon
----------------------------------------------------------------------------
*)

IMPORT S:=SYSTEM,AES,Str:=Strings,Appl;

CONST (* Object-Types *)
      BOX* = 20;     TEXT* = 21;  BOXTEXT* = 22;   IMAGE* = 23;
      PROGDEF* = 24; FRAME* = 25; BUTTON* = 26;    BOXCHAR* = 27;
      STRING* = 28;  FTEXT* = 29; FBOXTEXT* = 30;  ICON* = 31;
      TITLE* = 32;

      (* Farben *)
      WHITE* = 0;    BLACK* = 1;

      (* Fonts *)
      NORMAL* = 3;   SMALL* = 5;

      (* Justification *)
      LEFT* = 0;     RIGHT* = 1;  CENTER* = 2;

      (* state bits *)
      SELECTED* = 0; CROSSED* = 1; CHECKED* = 2; DISABLED* = 3;
      OUTLINED* = 4; SHADOWED* = 5;

      (* flag bits *)
      SELECTABLE* = 0; DEFAULT* = 1; EXITDIAL* = 2; EDITABLE* = 3;
      RADIOBUTTON* = 4; LASTOBJECT* = 5; TOUCHEXIT* = 6; HIDDEN* = 7;
      INDIRECT* = 9;

      (* edittypes *)
      INIT* = 1; SHOW* = 2; FINISH* = 3;

      (* hvdir *)
      HOR* = 0; VERT* = 1;

      (* place *)
      OUTSIDE* = 0; INSIDE* = 1;

TYPE  tedinfo*      = RECORD
                       Text*,Template*,Valid* : Str.ptr;
                       Font*,junk1,Just*      : INTEGER; (* siehe CONST *)
                       Color*,junk2,Thick*    : INTEGER;
                       TextLen*,TemplateLen*  : INTEGER;
                     END(*RECORD*);
      tedinfoptr*   = POINTER TO tedinfo;

      iconblk*      = RECORD
                       MaskData*,IconData* : LONGINT;
                       IconText* : Str.ptr;
                       IconChar* : INTEGER;
                       CharX*,CharY* : INTEGER;
                       IconX*,IconY*,IconW*,IconH* : INTEGER;
                       TextX*,TextY*,TextW*,TextH* : INTEGER;
                       Reserved : INTEGER;
                     END(*RECORD*);
      iconblkptr*   = POINTER TO iconblk;

      bitblk*       = RECORD
                       Data* : LONGINT;
                       W*,H*,X*,Y* : INTEGER;
                       Color* : INTEGER;
                     END(*RECORD*);
      bitblkptr*    = POINTER TO bitblk;

      applblk*      = RECORD
                       ProgramCode*  : LONGINT;
                       Parameter*    : LONGINT;
                     END(*RECORD*);
      applblkptr*   = POINTER TO applblk;

      parmblk*      = RECORD
                       Tree*         : LONGINT;
                       Index*        : INTEGER;
                       Prv*,Curr*    : INTEGER;
                       X*,Y*,W*,H*   : INTEGER;
                       ClipX*,ClipY* : INTEGER;
                       ClipW*,ClipH* : INTEGER;
                       Parameter*    : LONGINT;
                     END(*RECORD*);
      parmblkptr*   = POINTER TO parmblk;

      object*       = RECORD
                       Next*,Head*,Tail*,Type* : INTEGER;
                       Flags*,State* : INTEGER;
                       ObSpec*       : LONGINT;
                       X*,Y*,W*,H*   : INTEGER;
                     END(*RECORD*);
      ptr*         = POINTER TO object;

PROCEDURE GetPtr* (Tree : LONGINT; Index : INTEGER) : ptr;
 (* returns pointer to object with the index Index *)
 BEGIN
  RETURN Tree + LONG(Index * 24);
 END GetPtr;

PROCEDURE GetState* (Tree : LONGINT; Index : INTEGER) : SET;
  VAR ObjPtr : ptr;
 BEGIN
  ObjPtr := GetPtr(Tree,Index); RETURN S.VAL(SET,LONG(ObjPtr.State))
 END GetState;

PROCEDURE SetState* (Tree : LONGINT; Index : INTEGER; State : SET);
  VAR ObjPtr : ptr;
 BEGIN
  ObjPtr := GetPtr(Tree,Index); ObjPtr.State := SHORT(S.VAL(LONGINT,State))
 END SetState;

PROCEDURE GetFlags* (Tree : LONGINT; Index : INTEGER) : SET;
  VAR ObjPtr : ptr;
 BEGIN
  ObjPtr := GetPtr(Tree,Index); RETURN S.VAL(SET,LONG(ObjPtr.Flags))
 END GetFlags;

PROCEDURE SetFlags* (Tree : LONGINT; Index : INTEGER; Flags : SET);
  VAR ObjPtr : ptr;
 BEGIN
  ObjPtr := GetPtr(Tree,Index); ObjPtr.Flags := SHORT(S.VAL(LONGINT,Flags))
 END SetFlags;

PROCEDURE GetSpec* (Tree : LONGINT; Index : INTEGER) : LONGINT;
  (* returns the objects specific data *)
  VAR ObjPtr : ptr;
 BEGIN
  ObjPtr := GetPtr(Tree,Index); RETURN ObjPtr.ObSpec
 END GetSpec;

PROCEDURE Add* (Tree : LONGINT; Parent,Child : INTEGER);
 BEGIN
  AES.IntIn[0] := Parent; AES.IntIn[1] := Child;
  AES.AddrIn[0] := Tree; AES.Call(28020101H);
 END Add;

PROCEDURE Delete* (Tree : LONGINT; Object : INTEGER);
 BEGIN
  AES.IntIn[0] := Object; AES.AddrIn[0] := Tree; AES.Call(29010101H);
 END Delete;

PROCEDURE Draw* (Tree : LONGINT; Startob,Depth,ClipX,ClipY,ClipW,ClipH : INTEGER);
 BEGIN
  AES.IntIn[0] := Startob; AES.IntIn[1] := Depth;
  AES.IntIn[2] := ClipX; AES.IntIn[3] := ClipY;
  AES.IntIn[4] := ClipW; AES.IntIn[5] := ClipH;
  AES.AddrIn[0] := Tree; AES.Call(2A060101H);
 END Draw;

PROCEDURE Find* (Tree : LONGINT; Startob,Depth,Mx,My : INTEGER) : INTEGER;
 BEGIN
  AES.IntIn[0] := Startob; AES.IntIn[1] := Depth;
  AES.IntIn[2] := Mx; AES.IntIn[3] := My;
  AES.AddrIn[0] := Tree; AES.Call(2B040101H);
  RETURN AES.IntOut[0]
 END Find;

PROCEDURE Offset* (Tree : LONGINT; Object : INTEGER; VAR Xoff,Yoff : INTEGER);
 BEGIN
  AES.IntIn[0] := Object; AES.AddrIn[0] := Tree; AES.Call(2C010301H);
  Xoff := AES.IntOut[1]; Yoff := AES.IntOut[2];
END Offset;

PROCEDURE Order* (Tree : LONGINT; Object,Newpos : INTEGER);
 BEGIN
  AES.IntIn[0] := Object; AES.IntIn[1] := Newpos;
  AES.AddrIn[0] := Tree; AES.Call(2D020101H);
 END Order;

PROCEDURE Edit* (Tree : LONGINT; Object : INTEGER; Char : INTEGER;
                 Pos,Type : INTEGER; VAR Next : INTEGER);
 BEGIN
  AES.IntIn[0] := Object; AES.IntIn[1] := Char;
  AES.IntIn[2] := Pos; AES.IntIn[3] := Type;
  AES.AddrIn[0] := Tree; AES.Call(2E040201H);
  Next := AES.IntOut[1];
 END Edit;

PROCEDURE Change* (Tree : LONGINT; Object,ClipX,ClipY,ClipW,ClipH,NewState : INTEGER);
 BEGIN
  AES.IntIn[0] := Object; AES.IntIn[1] := 0;
  AES.IntIn[2] := ClipX; AES.IntIn[3] := ClipY;
  AES.IntIn[4] := ClipW; AES.IntIn[5] := ClipH;
  AES.IntIn[6] := NewState; AES.IntIn[7] := 1;
  AES.AddrIn[0] := Tree; AES.Call(2F080101H);
 END Change;

PROCEDURE Watchbox* (Tree : LONGINT; Object,InState,OutState : INTEGER) : INTEGER;
 BEGIN
  AES.IntIn[1] := Object; AES.IntIn[2] := InState;
  AES.IntIn[3] := OutState; AES.AddrIn[0] := Tree;
  AES.Call(4B040101H); RETURN AES.IntOut[0]
 END Watchbox;

PROCEDURE Slidebox* (Tree : LONGINT; Parent,Object,Direc : INTEGER) : INTEGER;
 BEGIN
  AES.IntIn[0] := Parent; AES.IntIn[1] := Object;
  AES.IntIn[2] := Direc; AES.AddrIn[0] := Tree;
  AES.Call(4C030101H); RETURN AES.IntOut[0]
 END Slidebox;

END Objc.

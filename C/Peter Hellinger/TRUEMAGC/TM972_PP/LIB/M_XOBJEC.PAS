UNIT M_Xobjects;

INTERFACE

USES AES;

TYPE DrawProc = FUNCTION (para: POINTER): INTEGER;

TYPE    PtrUSER_BLK =   ^USER_BLK; (* Intern erweitert! *)
        USER_BLK =      RECORD
                         ubCode: POINTER;
                         ubPara: Objcspec;
                         draw:   DrawProc;
                         obType: INTEGER;
                         priv:   POINTER;
                        END;


FUNCTION InstUserdef (tree: POINTER; objc: INTEGER; proc: DrawProc; private: POINTER): BOOLEAN;
PROCEDURE FreeUserdef (tree: POINTER; objc: INTEGER);
FUNCTION GetObtype (tree: POINTER; objc: INTEGER): INTEGER;
FUNCTION GetObSpec (tree: POINTER; objc: INTEGER): POINTER;
FUNCTION GetPrivate (tree: POINTER; objc: INTEGER): POINTER;
PROCEDURE GetValues (tree: POINTER; objc: INTEGER; VAR v1, v2: LONGINT);
PROCEDURE SetValues (tree: POINTER; objc: INTEGER; v1, v2: LONGINT);
PROCEDURE SetPrivate (tree: POINTER; objc: INTEGER; priv: POINTER);

IMPLEMENTATION

{$I COMPOPT.INC}

USES M_Sys;


FUNCTION InstUserdef (tree: POINTER; objc: INTEGER;
                      proc: DrawProc; private: POINTER): BOOLEAN;
VAR p: ^DrawProc;
BEGIN
 p:= ADDR (App^.MagicPB^.AddrIn[1]);
 App^.MagicPB^.IntIn[0]:= objc;
 App^.MagicPB^.AddrIn[0]:= tree;
 p^:= proc;
 App^.MagicPB^.AddrIn[2]:= private;
 CallMagic(2500);
 InstUserdef:= BOOLEAN (App^.MagicPB^.IntOut[0]);
END (*InstUserdef*);

PROCEDURE FreeUserdef (tree: POINTER; objc: INTEGER);
BEGIN
 App^.MagicPB^.IntIn[0]:= objc;
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic(2501);
END (*FreeUserdef*);

FUNCTION GetObtype (tree: POINTER; objc: INTEGER): INTEGER;
BEGIN
 App^.MagicPB^.IntIn[0]:= objc;
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic(2502);
 GetObtype:= App^.MagicPB^.IntOut[0];
END (*GetObtype*);

FUNCTION GetObSpec (tree: POINTER; objc: INTEGER): POINTER;
BEGIN
 App^.MagicPB^.IntIn[0]:= objc;
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic(2503);
 GetObspec:= App^.MagicPB^.AddrOut[0];
END (*GetObSpec*);

FUNCTION GetPrivate (tree: POINTER; objc: INTEGER): POINTER;
BEGIN
 App^.MagicPB^.IntIn[0]:= objc;
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic(2504);
 GetPrivate:= App^.MagicPB^.AddrOut[0];
END (*GetPrivate*);

PROCEDURE GetValues (tree: POINTER; objc: INTEGER; VAR v1, v2: LONGINT);
BEGIN
 App^.MagicPB^.IntIn[0]:= objc;
 App^.MagicPB^.AddrIn[0]:= tree;
 CallMagic(2505);
 v1:= App^.MagicPB^.LongOut[0];
 v2:= App^.MagicPB^.LongOut[1];
END (*GetValues*);

PROCEDURE SetValues (tree: POINTER; objc: INTEGER; v1, v2: LONGINT);
BEGIN
 App^.MagicPB^.IntIn[0]:= objc;
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.LongIn[0]:= v1;
 App^.MagicPB^.LongIn[1]:= v2;
 CallMagic(2506);
END (*SetValues*);

PROCEDURE SetPrivate (tree: POINTER; objc: INTEGER; priv: POINTER);
BEGIN
 App^.MagicPB^.IntIn[0]:= objc;
 App^.MagicPB^.AddrIn[0]:= tree;
 App^.MagicPB^.AddrIn[1]:= priv;
 CallMagic(2507);
END (*SetPrivate*);

END (*M_Xobjects*).

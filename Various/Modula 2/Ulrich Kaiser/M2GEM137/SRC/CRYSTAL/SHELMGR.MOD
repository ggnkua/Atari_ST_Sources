IMPLEMENTATION MODULE ShelMgr;

(*
AES Shell Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES       IMPORT IntIn,IntOut,Addr,crystal,Version,Integer;
FROM PORTAB    IMPORT UNSIGNEDWORD,SIGNEDWORD,ANYPOINTER;
#if ST
FROM INTRINSIC IMPORT INCPTR;
#endif
#ifdef MM2
FROM SYSTEM    IMPORT CADR,ADR;
#else
FROM SYSTEM    IMPORT ADR;
#endif
AES_SYSTEM_IMPORT

#if Seimet
CONST F120 = 078000102H;
      F121 = 079030102H;
      F122 = 07A010101H;
      F123 = 07B010101H;
      F124 = 07C000101H;
      F125 = 07D000102H;
      F126 = 07E000102H;
      F127 = 07F000102H;
#endif

PROCEDURE ShelRead(VAR Cmd : ARRAY OF CHAR;
                   VAR Tail: ARRAY OF CHAR);
BEGIN
  Addr[0]:= ADR(Cmd);
  Addr[1]:= ADR(Tail);
  crystal(120,0,1,2);
END ShelRead;

PROCEDURE ShelWrite(ExecMode : UNSIGNEDWORD;
                    GraphMode: UNSIGNEDWORD;
                    CrysMode : UNSIGNEDWORD;
                    PCmd     : ANYPOINTER;
                    PTail    : ANYPOINTER): SIGNEDWORD;
BEGIN
  Addr[0]:= PCmd;
  Addr[1]:= PTail;
  WITH IntIn DO
    Array[0]:= ExecMode;
    Array[1]:= GraphMode;
    Array[2]:= CrysMode;
  END;
  crystal(121,3,1,2);
  RETURN IntOut[0];
END ShelWrite;

PROCEDURE ShelGet(VAR Data  : ARRAY OF CHAR;
                      Length: SIGNEDWORD): UNSIGNEDWORD;
BEGIN
  IntIn.Array[0]:= Length;
  Addr[0]:= ADR(Data);
  crystal(122,1,1,1);
  RETURN IntOut[0];
END ShelGet;

PROCEDURE ShelPut(VAR Data  : ARRAY OF CHAR;
                      Length: UNSIGNEDWORD): BOOLEAN;
BEGIN
  IntIn.Array[0]:= Length;
  Addr[0]:= ADR(Data);
  crystal(123,1,1,1);
  RETURN IntOut[0] > 0;
END ShelPut;

PROCEDURE ShelFind(REF Name: ARRAY OF CHAR): BOOLEAN;
BEGIN
#ifdef MM2
  Addr[0]:= CADR(Name);
#else
  Addr[0]:= ADR(Name);
#endif
  crystal(124,0,1,1);
  RETURN IntOut[0] # 0;
END ShelFind;

PROCEDURE ShelEnvrn(VAR Ptr: ANYPOINTER;
                        Var: ARRAY OF CHAR);
#if ST
CONST VarLength = 5; (* length of var string "PATH=" *)

TYPE CharPtr = POINTER TO CHAR;

VAR Temp   : ARRAY[0..VarLength] OF CHAR;
    TempPtr: CharPtr;
    i      : [0..VarLength];
#endif
BEGIN
  Addr[0]:= ADR(Ptr); (* pointer to pointer to array of character *)
  Addr[1]:= ADR(Var);
  crystal(125,0,1,2);
#if ST
  Temp:= "PATH=";
  i:= 0;
  WHILE (Var[i] = Temp[i]) AND (i < (VarLength - 1)) DO
    INC(i);
  END;
  TempPtr:= CAST(CharPtr,Ptr);
  IF (i = (VarLength - 1)) AND (TempPtr^ < "A") THEN
    INCPTR(Ptr,1); (* fix bug *)
  END;
#endif
END ShelEnvrn;

PROCEDURE ShelRDef(VAR Cmd: ARRAY OF CHAR;
                   VAR Dir: ARRAY OF CHAR);
BEGIN
#if ST
  IF (Version() = 0220H) OR (Version() = 1042H) OR (Version() = 0399H) THEN
#else
  IF Version() >= 0220H THEN (* GEM 2.x, GEM 3.x *)
#endif
    Addr[0]:= ADR(Cmd);
    Addr[1]:= ADR(Dir);
    crystal(126,0,1,2);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
END ShelRDef;

PROCEDURE ShelWDef(VAR Cmd: ARRAY OF CHAR;
                       Dir: ARRAY OF CHAR);
BEGIN
#if ST
  IF (Version() = 0220H) OR (Version() = 1042H) OR (Version() = 0399H) THEN
#else
  IF Version() >= 0220H THEN (* GEM 2.x, GEM 3.x *)
#endif
    Addr[0]:= ADR(Cmd);
    Addr[1]:= ADR(Dir);
    crystal(127,0,1,2);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
END ShelWDef;

END ShelMgr.

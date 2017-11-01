IMPLEMENTATION MODULE MenuMgr;

(*
AES Menu Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES    IMPORT IntIn,IntOut,Addr,crystal,Version,Integer,
                   GPnt,Indirect,Selectable,Disabled;
FROM PORTAB IMPORT ANYPOINTER,SIGNEDWORD,UNSIGNEDWORD,WORDSET;
FROM SYSTEM IMPORT ADR;
AES_SYSTEM_IMPORT

#if ST
#warning ...using ProcessDomain(),
#warning you need M2POSIX/M2LIB
FROM DosSystem IMPORT ProcessDomain;
#endif

#if ST
#ifdef MM2
IMPORT PrgCtrl;
#elif (defined HM2)
IMPORT TOS;
#elif (defined LPRM2)
#warning you need the module
#warning LPRTERMINATION from
#warning LPR_UTL?.ZOO
FROM LPRTERMINATION IMPORT IsAPP;
#elif (defined TDIM2)
#warning you need a special module,
#warning determining accessory execution,
#warning e.g. the modified GEMX by R.S.
#endif
#endif

#if Seimet
CONST F30 = 01E010101H;
      F31 = 01F020101H;
      F32 = 020020101H;
      F33 = 021020101H;
      F34 = 022010102H;
      F35 = 023010101H;
    (*F36 = 024010100H;*) F36 = 024020102H; (* MenuPopup *)
    (*F37 = 025020100H;*) F37 = 025020102H; (* MenuAttach *)
      F38 = 026030101H;
      F39 = 027010101H;
#endif

PROCEDURE MenuBar(PTree: TreePtr;
                  Show : SIGNEDWORD): SIGNEDWORD;
BEGIN
  IntIn.Array[0]:= Show;
  Addr[0]:= PTree;
  crystal(30,1,1,1);
  RETURN IntOut[0];
END MenuBar;

PROCEDURE MenuICheck(PTree: TreePtr;
                     Item : ObjectIndex;
                     Check: BOOLEAN);
BEGIN
  WITH IntIn DO
    Array[0]:= Item;
    Array[1]:= ORD(Check);
  END;
  Addr[0]:= PTree;
  crystal(31,2,1,1);
END MenuICheck;

PROCEDURE MenuIEnable(PTree : TreePtr;
                      Item  : ObjectIndex;
                      Enable: BOOLEAN);
BEGIN
  WITH IntIn DO
    Array[0]:= Item;
    Array[1]:= ORD(Enable);
  END;
  Addr[0]:= PTree;
  crystal(32,2,1,1);
END MenuIEnable;

PROCEDURE MenuTNormal(PTree : TreePtr;
                      Title : ObjectIndex;
                      Normal: BOOLEAN);
BEGIN
  WITH IntIn DO
    Array[0]:= Title;
    Array[1]:= ORD(Normal);
  END;
  Addr[0]:= PTree;
  crystal(33,2,1,1);
END MenuTNormal;

PROCEDURE MenuText(    PTree: TreePtr;
                       Item : ObjectIndex;
                   VAR Text : ARRAY OF CHAR);

BEGIN
#if 1
  (* handle bug at ATARI-GEM and PC-GEM *)
  IF Indirect IN PTree^[Item].ObFlags THEN
    PTree^[Item].ObSpec.Extension^.Spec.String:= ADR(Text);
  ELSE
    IntIn.Array[0]:= Item;
    Addr[0]:= PTree;
    Addr[1]:= ADR(Text);
    crystal(34,1,1,2);
  END;
#else
  IntIn.Array[0]:= Item;
  Addr[0]:= PTree;
  Addr[1]:= ADR(Text);
  crystal(34,1,1,2);
#endif
END MenuText;

PROCEDURE Accessory(): BOOLEAN;
BEGIN
#ifdef HM2
  RETURN NOT(TOS.IsApp);
#elif (defined LPRM2)
  RETURN NOT(IsAPP());
#elif (defined MM2)
  RETURN PrgCtrl.Accessory();
#elif (defined TDIM2)
  RETURN FALSE;
(*RETURN TRUE; for accessories *)
#elif (defined SPCM2)
  RETURN FALSE;
(*RETURN TRUE; for accessories *)
#else
  RETURN FALSE;
(*RETURN TRUE; for accessories *)
#endif
END Accessory;

PROCEDURE MenuRegister(    Id   : SIGNEDWORD;
                       VAR MName: ARRAY OF CHAR): SIGNEDWORD;

VAR Result: INTEGER;

BEGIN
#if ST
(*
Actually, under GEM 3.2 or lower and MiNT 1.09 or lower accessories
and the GEM-Desktop (NEWDESK) seem to be one and the same (MiNT-)process.
A call of ProcessDomain(1) within the module body of DosSystem,
imported by an accessory, will confuse NEWDESK, that means all
filesystems will behave case-sensitiv. This hack will not work if
an accessory does not call MenuRegister(), of course.
Since AES 4.0 applications may call MenuRegister(), else they must not.
*)

  IF (Version() < 0400H) THEN
    IF Accessory() THEN
      Result:= ProcessDomain(0); (* switch to TOS domain *)
    ELSE
      RETURN -1; (* not allowed for applications *)
    END;
  END;
  IntIn.Array[0]:= Id;
  Addr[0]:= ADR(MName);
  crystal(35,1,1,1);
  RETURN IntOut[0];
#else
  IF Accessory() THEN
    IntIn.Array[0]:= Id;
    Addr[0]:= ADR(MName);
    crystal(35,1,1,1);
    RETURN IntOut[0];
  ELSE
    RETURN -1;
  END;
#endif
END MenuRegister;

PROCEDURE MenuUnregister(Id: SIGNEDWORD);
BEGIN
#if ST
#if ABC
#warning ...taking care of ABC-GEM
  IF (Version() = 0220H) OR (Version() = 1042H) OR (Version() = 0399H) THEN
#endif
#else
  IF Version() >= 0220H THEN (* GEM 2.x, GEM 3.x *)
#endif
#if ST
#if ABC
    IntIn.Array[0]:= Id;
    crystal(36,1,1,0);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
#else
  IntOut[0]:= 0; (* error *)
#endif
#else
    IntIn.Array[0]:= Id;
    crystal(36,1,1,0);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
#endif
END MenuUnregister;

PROCEDURE MenuPopup(VAR PMenu: Menu;
                        Pos  : GPnt;
                    VAR PData: Menu): BOOLEAN;
BEGIN
#if ST
  IF Version() >= 0400H THEN
    IntIn.Array[0]:= Pos.GX;
    IntIn.Array[1]:= Pos.GY;
    Addr[0]:= ADR(PMenu);
    Addr[1]:= ADR(PData);
    crystal(36,2,1,2);
    RETURN IntOut[0] > 0;
  END;
#endif
  RETURN FALSE;
END MenuPopup;

PROCEDURE MenuClick(Click: BOOLEAN;
                    SetIt: BOOLEAN);
BEGIN
#if ST
  IF (Version() = 1042H) OR (Version() = 0399H)THEN (* KAOS-GEM/MagX 2.0 *)
#else
  IF Version() >= 0300H THEN (* GEM 3.x *)
#endif
    WITH IntIn DO
      Array[0]:= ORD(Click);
      Array[1]:= ORD(SetIt);
    END;
    crystal(37,2,1,0);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
END MenuClick;

PROCEDURE MenuAttach(    Flag : UNSIGNEDWORD;
                         PTree: TreePtr;
                         Item : ObjectIndex;
                     VAR PData: Menu): BOOLEAN;
BEGIN
#if ST
  IF Version() >= 0400H THEN
    IntIn.Array[0]:= Flag;
    IntIn.Array[1]:= Item;
    Addr[0]:= PTree;
    Addr[1]:= ADR(PData);
    crystal(37,2,1,2);
    RETURN IntOut[0] > 0;
  END;
#endif
  RETURN FALSE;
END MenuAttach;

PROCEDURE MenuIStart(Flag : UNSIGNEDWORD;
                     PTree: TreePtr;
                     IMenu: ObjectIndex;
                     Item : ObjectIndex): BOOLEAN;
BEGIN
#if ST
  IF Version() >= 0400H THEN
    WITH IntIn DO
      Array[0]:= Flag;
      Array[1]:= IMenu;
      Array[2]:= Item;
    END;
    Addr[0]:= PTree;
    crystal(38,3,1,1);
    RETURN IntOut[0] > 0;
  END;
#endif
  RETURN FALSE;
END MenuIStart;

PROCEDURE MenuSettings(    Flag  : UNSIGNEDWORD;
                       VAR Values: MnSet);
BEGIN
#if ST
  IF Version() >= 0400H THEN
    IntIn.Array[0]:= Flag;
    Addr[0]:= ADR(Values);
    crystal(39,1,1,1);
  END;
#endif
END MenuSettings;

END MenuMgr.

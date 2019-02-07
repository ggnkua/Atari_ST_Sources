IMPLEMENTATION MODULE RsrcMgr;

(*
AES Resource Manager.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

FROM AES      IMPORT Control,Global,IntIn,IntOut,Addr,crystal,Version,
                     Integer;
FROM pSTORAGE IMPORT ALLOCATE,DEALLOCATE;
FROM PORTAB   IMPORT UNSIGNEDWORD,SIGNEDWORD,ANYPOINTER,NULL;
FROM SYSTEM   IMPORT ADR;
AES_SYSTEM_IMPORT

#if ST
#warning ...using exit(),
#warning you need M2POSIX/M2LIB
FROM er        IMPORT ENOMEM;
FROM DosSystem IMPORT exit;
#endif

#if Seimet
CONST F110 = 06E000101H;
      F111 = 06F000100H;
      F112 = 070020100H;
      F113 = 071020101H;
      F114 = 072010101H;
      F115 = 073000101H;

      F53  = 035010100H;

      F124 = 07C000101H;
#endif

(* RsrcLoad() **************************************************************)

TYPE RsrcLoadPtr = POINTER TO RsrcLoadRec;
     RsrcLoadRec = RECORD
                     Next: RsrcLoadPtr;
                     Proc: RsrcLoadProc;
                   END;

VAR RsrcLoadList: RsrcLoadPtr;
    CurrRsrcLoad: RsrcLoadPtr;

PROCEDURE rsrcload(Name: ARRAY OF CHAR): BOOLEAN;

CONST MaxNameLen = 32;

TYPE NameRange = [0..MaxNameLen];

VAR i        : NameRange;
    LocalName: ARRAY NameRange OF CHAR; (* long file names allowed *)

BEGIN
  IF HIGH(Name) > (MaxNameLen - 1) THEN
    RETURN FALSE; (* too long *)
  END;
  FOR i:= 0 TO HIGH(Name) DO
    LocalName[i]:= Name[i];
  END;
  LocalName[HIGH(Name) + 1]:= 0C;

  Addr[0]:= ADR(LocalName);
  Global.ApPTree:= NULL; (* must be set to zero *)
  crystal(110,0,1,1);
  IF IntOut[0] = 0 THEN
    (* try lower case, no national characters assumed *)
    i:= 0;
    WHILE LocalName[i] # 0C DO
      IF (LocalName[i] >= "A") AND (LocalName[i] <= "Z") THEN
        LocalName[i]:= CHR(ORD(LocalName[i]) + 20H);
      END;
      INC(i);
    END;
    crystal(110,0,1,1);
  END;
  IF IntOut[0] = 0 THEN
    (* try upper case, no national characters assumed *)
    i:= 0;
    WHILE LocalName[i] # 0C DO
      IF (LocalName[i] >= "a") AND (LocalName[i] <= "z") THEN
        LocalName[i]:= CHR(ORD(LocalName[i]) - 20H);
      END;
      INC(i);
    END;
    crystal(110,0,1,1);
  END;

  RETURN IntOut[0] # 0;
END rsrcload;

PROCEDURE RsrcLoad(Name: ARRAY OF CHAR): BOOLEAN;

#if GEMDOS
CONST NoFile   = -33;
      NoMemory = -39;
#elif PCDOS
CONST NoFile   = 2;
      NoMemory = 8;
#elif UNIX
CONST NoFile   = -33;
      NoMemory = -39;
#endif

VAR Done: BOOLEAN;

  PROCEDURE FormError(Error: SIGNEDWORD);
  BEGIN
#if ST
    IntIn.Array[0]:= -Error - 31; (* to PC-DOS error code *)
#else
    IntIn.Array[0]:= Error;
#endif
    crystal(53,1,1,0);
  END FormError;

  PROCEDURE ShelFind(Name: ARRAY OF CHAR): BOOLEAN;
  BEGIN
    Addr[0]:= ADR(Name);
    crystal(124,0,1,1);
    RETURN IntOut[0] # 0;
  END ShelFind;

BEGIN
  CurrRsrcLoad:= RsrcLoadList;
  Done:= CurrRsrcLoad # NIL;
  IF NOT Done THEN
    FormError(NoMemory);
  END;

  WHILE (CurrRsrcLoad # NIL) AND Done DO
    Done:= CurrRsrcLoad^.Proc(Name);
    RsrcLoadList:= CurrRsrcLoad;
    CurrRsrcLoad:= CurrRsrcLoad^.Next;
    DISPOSE(RsrcLoadList);
  END;

  IF NOT Done THEN
    IF NOT ShelFind(Name) THEN
      FormError(NoFile);
    ELSE
      FormError(NoMemory);
    END;
  END;

  RETURN Done;
END RsrcLoad;

(***************************************************************************)

TYPE RsrcFreePtr = POINTER TO RsrcFreeRec;
     RsrcFreeRec = RECORD
                     Next: RsrcFreePtr;
                     Proc: RsrcFreeProc;
                   END;

VAR RsrcFreeList: RsrcFreePtr;
    CurrRsrcFree: RsrcFreePtr;

PROCEDURE rsrcfree;
BEGIN
  IF Global.ApPMem # NULL THEN (* ApPMem is initialised by NULL *)
    crystal(111,0,1,0);
    Global.ApPMem:= NULL; (* protection versus multiple calls *)
  END;
END rsrcfree;

PROCEDURE RsrcFree;
BEGIN
  CurrRsrcFree:= RsrcFreeList;

  WHILE CurrRsrcFree # NIL DO
    CurrRsrcFree^.Proc();
    RsrcFreeList:= CurrRsrcFree;
    CurrRsrcFree:= CurrRsrcFree^.Next;
    DISPOSE(RsrcFreeList);
  END;
END RsrcFree;

(***************************************************************************)

PROCEDURE gaddr(    Type   : ResourceTypes;
                    Index  : TreeIndex;
                VAR OutAddr: ANYPOINTER): BOOLEAN;
BEGIN
  WITH IntIn DO
    Array[0]:= ORD(Type);
    Array[1]:= Index;
  END;
  Control.SizeAddrOut:= 1;
  crystal(112,2,1,0);
  Control.SizeAddrOut:= 0;
  OutAddr:= Addr[2];
  RETURN IntOut[0] # 0;
END gaddr;

PROCEDURE saddr(Type  : ResourceTypes;
                Index : TreeIndex;
                InAddr: ANYPOINTER): BOOLEAN;
BEGIN
  WITH IntIn DO
    Array[0]:= ORD(Type);
    Array[1]:= Index;
  END;
  Addr[0]:= InAddr;
  crystal(113,2,1,1);
  RETURN IntOut[0] # 0;
END saddr;

PROCEDURE obfix(PTree: TreePtr;
                Ob   : ObjectIndex);
BEGIN
  IntIn.Array[0]:= Ob;
  Addr[0]:= PTree;
  crystal(114,1,1,1);
END obfix;

PROCEDURE rcfix(RawRsc: RsPtr);
BEGIN
#if ST
  IF (Version() >= 0399H) AND (Version() < 1042H) THEN
    Addr[0]:= RawRsc;
    crystal(115,0,1,1);
  ELSE
    IntOut[0]:= 0; (* error *)
  END;
#endif
END rcfix;

PROCEDURE AddRsrcLoad(LoadProc: RsrcLoadProc);
BEGIN
  IF CurrRsrcLoad # NIL THEN
    NEW(CurrRsrcLoad^.Next); (* NIL in case of failure *)
    CurrRsrcLoad:= CurrRsrcLoad^.Next;
  ELSE
#if ST
    exit(ENOMEM);
#endif
  END;

  IF CurrRsrcLoad # NIL THEN
    WITH CurrRsrcLoad^ DO
      Next:= NIL;
      Proc:= LoadProc;
    END;
  END;
END AddRsrcLoad;

PROCEDURE AddRsrcFree(FreeProc: RsrcFreeProc);
BEGIN
  NEW(CurrRsrcFree); (* NIL in case of failure *)
  IF CurrRsrcFree # NIL THEN
    WITH CurrRsrcFree^ DO
      Next:= RsrcFreeList;
      Proc:= FreeProc;
    END;
    RsrcFreeList:= CurrRsrcFree;
  ELSE
#if ST
    exit(ENOMEM);
#endif
  END;
END AddRsrcFree;

BEGIN
  NEW(RsrcLoadList);
  IF RsrcLoadList # NIL THEN
    RsrcLoadList^.Next:= NIL;
    RsrcLoadList^.Proc:= rsrcload;
  END;
  CurrRsrcLoad:= RsrcLoadList; (* may be NIL, necessary for AddRsrcLoad() *)

  NEW(RsrcFreeList);
  IF RsrcFreeList # NIL THEN
    RsrcFreeList^.Next:= NIL;
    RsrcFreeList^.Proc:= rsrcfree;
  END;
(*CurrRsrcFree:= RsrcFreeList; not necessary *)

  rsrcgaddr:= gaddr; RsrcGAddr:= rsrcgaddr;
  rsrcsaddr:= saddr; RsrcSAddr:= rsrcsaddr;
  rsrcobfix:= obfix; RsrcObFix:= rsrcobfix;
  rsrcrcfix:= rcfix; RsrcRCFix:= rsrcrcfix;
END RsrcMgr.

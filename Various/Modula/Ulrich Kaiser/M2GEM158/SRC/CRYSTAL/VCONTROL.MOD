IMPLEMENTATION MODULE VControl;

(*
VDI Control Functions.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

#if ST
FROM AES      IMPORT Version;
(*FROM GrafMgr  IMPORT GrafHandle;*)
#endif
FROM VDI      IMPORT contrl,intin,ptsin,intout,ptsout,v,vdi,CallVDI,XY,
                     Integer,EOS,IntegerOutputRange,IntegerInputRange,
                     MaxInput,CallVDIEsc,MFDB;
FROM PORTAB   IMPORT UNSIGNEDLONG,UNSIGNEDWORD,SIGNEDWORD,ANYBYTE,ANYPOINTER,
                     NULL;
#ifdef FTLM2

#else
FROM SYSTEM   IMPORT ADR;
#endif
#if (defined LPRM2) || (defined SPCM2)
FROM SYSTEM   IMPORT REG,INLINE,VAL,SHORT;
FROM Register IMPORT D0;
#elif (defined HM2)
FROM SYSTEM   IMPORT CAST,STORE,CODE;
FROM Register IMPORT D0;
#elif (defined TDIM2)
FROM SYSTEM   IMPORT REGISTER,CODE;
FROM Register IMPORT D0;
#elif (defined ANAM2)
FROM SYSTEM   IMPORT REGISTER,CODE;
FROM Register IMPORT D0;
#elif (defined MM2)
FROM SYSTEM   IMPORT ASSEMBLER,CAST;
#elif (defined FTLM2)
FROM SYSTEM   IMPORT ADR,GETREG,CODE;
FROM Register IMPORT D0;
#else
CAST_IMPORT
#endif

#if ST
#warning ...using GetCookie,
#warning you need M2POSIX/M2LIB
FROM DosSystem IMPORT GetCookie,CookieVal;

VAR OffScreen: UNSIGNEDWORD; (* for NVDI 2.5 or higher *)
#endif

#if (defined LPRM2) || (defined SPCM2)
PROCEDURE NOTVQGDOS(): BOOLEAN;

  PROCEDURE Trap2;
    CODE(04E42H);

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    INLINE(070FEH); (* moveq  #-2,d0 *)
    Trap2;          (* trap   #2     *)
    INLINE(05440H); (* addq.w #$2,d0 *)
    RETURN CHR(SHORT(REG(D0))) = 0C;
  END;
END NOTVQGDOS;

PROCEDURE VQFSMGDOS(): BOOLEAN;

  PROCEDURE Trap2;
    CODE(04E42H);

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    INLINE(070FEH); (* moveq #-2,d0 *)
    Trap2;          (* trap  #2     *)
    RETURN REG(D0) = 05F46534DH;
  END;
END VQFSMGDOS;

PROCEDURE VQFNTGDOS(): BOOLEAN;

  PROCEDURE Trap2;
    CODE(04E42H);

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    INLINE(070FEH); (* moveq #-2,d0 *)
    Trap2;          (* trap  #2     *)
    RETURN REG(D0) = 05F464E54H;
  END;
END VQFNTGDOS;
#endif

#ifdef HM2
PROCEDURE NOTVQGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

VAR Ret: UNSIGNEDLONG;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(070FEH); (* moveq  #-2,d0 *)
    CODE(trap2);  (* trap   #2     *)
    CODE(05440H); (* addq.w #$2,d0 *)
    STORE(D0,Ret);
    RETURN CHR(Ret) = 0C;
  END;
END NOTVQGDOS;

PROCEDURE VQFSMGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

VAR Ret: UNSIGNEDLONG;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(070FEH); (* moveq  #-2,d0 *)
    CODE(trap2);  (* trap   #2     *)
    STORE(D0,Ret);
    RETURN Ret = 05F46534DH;
  END;
END VQFSMGDOS;

PROCEDURE VQFNTGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

VAR Ret: UNSIGNEDLONG;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(070FEH); (* moveq  #-2,d0 *)
    CODE(trap2);  (* trap   #2     *)
    STORE(D0,Ret);
    RETURN Ret = 05F464E54H;
  END;
END VQFNTGDOS;
#endif

#ifdef TDIM2
PROCEDURE NOTVQGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(303CH,-2);  (* move.w #-2,d0 *)
    CODE(trap2);     (* trap   #2     *)
    CODE(0B07CH,-2); (* cmp.w  #-2,d0 *)
    CODE(57C0H);     (* seq    d0     *)
    RETURN BOOLEAN(CHR(SHORT(LONGCARD(REGISTER(D0)))));
  END;
END NOTVQGDOS;

PROCEDURE VQFSMGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(303CH,-2);  (* move.w #-2,d0 *)
    CODE(trap2);     (* trap   #2     *)
    RETURN REGISTER(D0) = 05F46534DH;
  END;
END VQFSMGDOS;

PROCEDURE VQFNTGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(303CH,-2);  (* move.w #-2,d0 *)
    CODE(trap2);     (* trap   #2     *)
    RETURN REGISTER(D0) = 05F464E54H;
  END;
END VQFNTGDOS;
#endif

#ifdef FTLM2
PROCEDURE NOTVQGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

VAR Ret: UNSIGNEDLONG;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(070FEH); (* moveq  #-2,d0 *)
    CODE(trap2);  (* trap   #2     *)
    CODE(05440H); (* addq.w #$2,d0 *)
    GETREG(D0,Ret);
    RETURN CHR(CARDINAL(Ret)) = 0C;
  END;
END NOTVQGDOS;

PROCEDURE VQFSMGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

VAR Ret: UNSIGNEDLONG;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(070FEH); (* moveq  #-2,d0 *)
    CODE(trap2);  (* trap   #2     *)
    GETREG(D0,Ret);
    RETURN Ret = 05F46534DH;
  END;
END VQFSMGDOS;

PROCEDURE VQFNTGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

VAR Ret: UNSIGNEDLONG;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(070FEH); (* moveq  #-2,d0 *)
    CODE(trap2);  (* trap   #2     *)
    GETREG(D0,Ret);
    RETURN Ret = 05F464E54H;
  END;
END VQFNTGDOS;
#endif

#ifdef ANAM2
PROCEDURE NOTVQGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(070FEH); (* moveq  #-2,d0 *)
    CODE(trap2);  (* trap   #2     *)
    CODE(05440H); (* addq.w #$2,d0 *)
    RETURN CHR(REGISTER(D0)) = 0C;
  END;
END NOTVQGDOS;

PROCEDURE VQFSMGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(070FEH); (* moveq #-2,d0 *)
    CODE(trap2);  (* trap  #2     *)
    RETURN REGISTER(D0) = 05F46534DH;
  END;
END NOTVQFSMGDOS;

PROCEDURE VQFNTGDOS(): BOOLEAN;

CONST trap2 = 4E42H;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    CODE(070FEH); (* move.w #-2,d0 *)
    CODE(trap2);  (* trap   #2     *)
    RETURN REGISTER(D0) = 05F464E54H;
  END;
END NOTVQFNTGDOS;
#endif

#ifdef MM2
PROCEDURE NOTVQGDOS(): BOOLEAN;

VAR X: LONGINT;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    ASSEMBLER
      MOVEQ  #-2,D0;
      TRAP   #2;
      MOVE.L D0,X(A6);
    END;
    RETURN X = -2L;
  END;
END NOTVQGDOS;

PROCEDURE VQFSMGDOS(): BOOLEAN;

VAR X: LONGINT;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    ASSEMBLER
      MOVEQ  #-2,D0;
      TRAP   #2;
      MOVE.L D0,X(A6);
    END;
    RETURN X = 5F46534DH;
  END;
END VQFSMGDOS;

PROCEDURE VQFNTGDOS(): BOOLEAN;

VAR X: LONGINT;

BEGIN
  IF Version() = 0220H THEN
    RETURN FALSE; (* NOT TRUE *)
  ELSE
    ASSEMBLER
      MOVEQ  #-2,D0;
      TRAP   #2;
      MOVE.L D0,X(A6);
    END;
    RETURN X = 5F464E54H;
  END;
END VQFNTGDOS;
#endif

#if ST
PROCEDURE VQSpeedoGDOS(): BOOLEAN;

CONST FSMC   = 046534D43H;
      Speedo = 05F535044H;

VAR Value: CookieVal;

BEGIN
  IF GetCookie(FSMC,Value) THEN
    IF Value.ul = Speedo THEN
      RETURN TRUE;
    END;
  END;
  RETURN FALSE;
END VQSpeedoGDOS;
#endif

PROCEDURE VGetDriverInfo(    Device    : UNSIGNEDWORD;
                             Info      : InfoSelections;
                         VAR InfoString: ARRAY OF CHAR;
                         VAR InfoWord  : UNSIGNEDWORD);

VAR i: IntegerOutputRange;

BEGIN
#if ST
  IF NOTVQGDOS() THEN
    InfoString[0]:= 0C;
    InfoWord:= 0;
    intout[0]:= 0; (* error *)
    RETURN;
  END;
#endif
  WITH contrl DO
    c[0]:= CAST(UNSIGNEDWORD,-1);
    c[1]:= 0;
    c[3]:= 2;
    c[5]:= 4;
    c[6]:= 0;
  END;
  intin[0]:= Device;
  intin[1]:= ORD(Info);
  vdi;
  IF Info # DrvPatch THEN
    i:= 0;
    WHILE i < contrl.c[4] DO
      InfoString[i]:= CHR(CAST(UNSIGNEDWORD,intout[i]));
      INC(i);
    END;
    InfoString[i]:= EOS;
  ELSE
    InfoWord:= intout[0];
  END;
END VGetDriverInfo;

PROCEDURE VOpnWk(VAR WorkIn : ARRAY OF UNSIGNEDWORD;
                     MaxX   : XY;
                     MaxY   : XY;
                 VAR Handle : UNSIGNEDWORD;
                 VAR WorkOut: ARRAY OF UNSIGNEDWORD;
                 VAR Buffer : MFDB);

#if ST
CONST OffScreenWork = 90;
      EdDI = 045644449H;
#endif

VAR i: [0..(MaxWorkIn - 1)];
    P: POINTER TO ANYPOINTER;
    D: UNSIGNEDWORD;
#if ST
    Value: CookieVal;
#endif

BEGIN
#if ST
  IF NOTVQGDOS() THEN
    intout[0]:= 0; (* error *)
    Handle:= 0; (* error *)
    RETURN;
  END;
#endif

#if ST
  IF WorkIn[0] = OffScreenWork THEN
    IF NOT GetCookie(EdDI,Value) THEN
      intout[0]:= 0; (* error *)
      Handle:= 0; (* error *)
      RETURN;
    ELSE
      WorkIn[11]:= MaxX;
      WorkIn[12]:= MaxY;

      WorkIn[13]:= 0;
      WorkIn[14]:= 0;

      FOR i:= 15 TO 19 DO
        WorkIn[i]:= 0;
      END;
    END;
  END;
#endif

#if long
  FOR i:= 0 TO VAL(IntegerInputRange,HIGH(WorkIn)) DO
    intin[i]:= WorkIn[i];
  END;
#else
  WITH v DO
    iioff:= ADR(WorkIn);
    iooff:= ADR(WorkOut);
    pooff:= ADR(WorkOut[45]);
#endif

    WITH contrl DO
      CASE WorkIn[0] OF Printer..(Metafile - 1),Memory..(Image - 1):
        IF MaxX # 0 THEN
          ptsin[0]:= MaxX + 1;
          ptsin[1]:= MaxY + 1;
          c[1]:= 1; (* #ptsin[]/2 *)
        ELSE
          c[1]:= 0; (* #ptsin[]/2 *)
        END;
      ELSE
        c[1]:= 0; (* #ptsin[]/2 *)
      END;

      c[0]:= 1; (* OpCode *)
    (*c[1] see above *)
      c[2]:= 6;
      c[3]:= HIGH(WorkIn) + 1; (* #intin[] *)
      c[4]:= 45;
    END;

#if ST
    IF WorkIn[0] = OffScreenWork THEN
      WITH contrl.v DO
        a[0]:= 100; (*VOpnBm() *)
        a[1]:= 0;
      (*a[2]:= 6;*)
        a[3]:= 20;
      (*a[4]:= 45;*)
        a[5]:= 1; (*VOpnBm() *)
      (*a[6]:= GrafHandle(D,D,D,D);*)
        v1:= ADR(Buffer); (* a[7..8] *)
      END;
    END;
#endif

    vdi;

    Handle:= contrl.c[6];

#if ST
    IF WorkIn[0] # OffScreenWork THEN
#endif
      Buffer.FDAddr:= contrl.b; (* contrl.c[0..1] *)
#if ST
    ELSE
      OffScreen:= Handle;
    END;
#endif

#if long
   FOR i:= 0 TO 44 DO
     WorkOut[i]:= intout[i];
   END;

   FOR i:= 45 TO (MaxWorkOut - 1) DO
     WorkOut[i]:= ptsout[i - 45];
   END;
#else
    iioff:= ADR(intin);
    iooff:= ADR(intout);
    pooff:= ADR(ptsout);
  END;
#endif
END VOpnWk;

PROCEDURE VClsWk(VAR Handle: UNSIGNEDWORD);
BEGIN
#if ST
  IF Handle = OffScreen THEN
    contrl.c[5]:= 1; (* VClsBm() *)
    CallVDI(101,0,0,Handle);
    OffScreen:= 0;
  ELSE
#endif
    CallVDI(2,0,0,Handle);
#if ST
  END;
#endif
  Handle:= 0; (* to use as a flag *)
END VClsWk;

PROCEDURE VOpnVWk(VAR WorkIn : ARRAY OF UNSIGNEDWORD;
                  VAR Handle : UNSIGNEDWORD;
                  VAR WorkOut: ARRAY OF UNSIGNEDWORD);
#if long
VAR i: [0..(MaxWorkIn - 1)];
#endif

BEGIN
#if long
  FOR i:= 0 TO HIGH(WorkIn) DO
    intin[i]:= WorkIn[i];
  END;
#else
  WITH v DO
    iioff:= ADR(WorkIn);
    iooff:= ADR(WorkOut);
    pooff:= ADR(WorkOut[45]);
#endif
    CallVDI(100,0,HIGH(WorkIn) + 1,Handle); (* input handle  *)
 (* Handle:= contrl.c[6]; *)
    IF contrl.c[6] = Handle THEN
      Handle:= 0; (* error *)
    ELSE
      Handle:= contrl.c[6];
    END;
#if long
  FOR i:= 0 TO 44 DO
    WorkOut[i]:= intout[i];
  END;
  FOR i:= 45 TO (MaxWorkOut - 1) DO
    WorkOut[i]:= ptsout[i - 45];
  END;
#else
    iioff:= ADR(intin);
    iooff:= ADR(intout);
    pooff:= ADR(ptsout);
  END;
#endif
END VOpnVWk;

PROCEDURE VClsVWk(VAR Handle: UNSIGNEDWORD);
BEGIN
  IF Handle # 0 THEN
    CallVDI(101,0,0,Handle);
    Handle:= 0; (* protection versus multiple calls *)
  END;
END VClsVWk;

PROCEDURE VOpnBm(VAR WorkIn : ARRAY OF UNSIGNEDWORD;
                 VAR Bitmap : MFDB;
                 VAR Handle : UNSIGNEDWORD;
                 VAR WorkOut: ARRAY OF UNSIGNEDWORD);
#if long
VAR i: [0..(MaxWorkIn - 1)];
#endif

BEGIN
#if long
  FOR i:= 0 TO HIGH(WorkIn) DO
    intin[i]:= WorkIn[i];
  END;
#else
  WITH v DO
    iioff:= ADR(WorkIn);
    iooff:= ADR(WorkOut);
    pooff:= ADR(WorkOut[45]);
#endif
    WITH contrl.v DO
      a[0]:= 100; (*VOpnBm() *)
      a[1]:= 0;
    (*a[2]:= 6;*)
      a[3]:= 20;
    (*a[4]:= 45;*)
      a[5]:= 1; (*VOpnBm() *)
      v1:= ADR(Bitmap); (* a[7..8] *)
    END;

    vdi;

    Handle:= contrl.c[6];

#if long
  FOR i:= 0 TO 44 DO
    WorkOut[i]:= intout[i];
  END;
  FOR i:= 45 TO (MaxWorkOut - 1) DO
    WorkOut[i]:= ptsout[i - 45];
  END;
#else
    iioff:= ADR(intin);
    iooff:= ADR(intout);
    pooff:= ADR(ptsout);
  END;
#endif
END VOpnBm;

PROCEDURE VClsBm(VAR Handle: UNSIGNEDWORD);
BEGIN
  WITH contrl.v DO
    a[0]:= 101; (*VClsBm() *)
    a[1]:= 0;
    a[3]:= 0;
    a[5]:= 1; (*VClsBm() *)
    a[6]:= Handle;
  END;

  vdi;

  Handle:= 0; (* to use as a flag *)
END VClsBm;

PROCEDURE VClrWk(Handle: UNSIGNEDWORD);
BEGIN
  CallVDI(3,0,0,Handle);
END VClrWk;

PROCEDURE VUpdWk(    Handle: UNSIGNEDWORD;
                 VAR Buffer: MFDB): UNSIGNEDWORD;
BEGIN
  contrl.c[4]:= 0; (* st magazin 7/1993 p. 89 *)
  IF (Buffer.FDAddr # NIL) OR (Buffer.FDAddr # NULL) THEN
    v.iioff:= Buffer.FDAddr;
    CallVDI(4,1,2,Handle);
  ELSE
    CallVDI(4,0,0,Handle); (* clear buffer *)
  END;
  v.iioff:= ADR(intin);
  RETURN intout[0];
END VUpdWk;

PROCEDURE VSTLoadFonts(Handle: UNSIGNEDWORD;
                       Select: UNSIGNEDWORD;
                       Max   : UNSIGNEDWORD;
                       Free  : UNSIGNEDWORD): UNSIGNEDWORD;
BEGIN
#if ST
  IF NOTVQGDOS() THEN
    intout[0]:= 0; (* error *)
    RETURN 0;
  END;
#endif
  intin[0]:= Select;

  (* compatibility to GEM/3 *)
  intin[1]:= Max;
  intin[2]:= Free;

  CallVDI(119,0,3,Handle);
  RETURN intout[0];
END VSTLoadFonts;

PROCEDURE VSTUnloadFonts(Handle: UNSIGNEDWORD;
                         Select: UNSIGNEDWORD);
BEGIN
  intin[0]:= Select;
  CallVDI(120,0,1,Handle);
END VSTUnloadFonts;

PROCEDURE VSClip(    Handle: UNSIGNEDWORD;
                     Clip  : BOOLEAN;
                 VAR PXY   : ARRAY OF XY);
#if long
VAR i: [0..3];
#endif

BEGIN
#if long
  FOR i:= 0 TO 3 DO
    ptsin[i]:= PXY[i];
  END;
#else
  v.pioff:= ADR(PXY);
#endif
  intin[0]:= ORD(Clip);
  CallVDI(129,2,1,Handle);
#if not long
  v.pioff:= ADR(ptsin);
#endif
END VSClip;

PROCEDURE VSetAppBuff(Handle: UNSIGNEDWORD;
                      Buf   : ANYPOINTER;
                      Size  : UNSIGNEDWORD);

VAR P: POINTER TO ANYPOINTER;

BEGIN
  P:= ADR(intin);
  P^:=Buf;
  intin[2]:= Size;
  WITH contrl DO
    c[0]:= CAST(UNSIGNEDWORD,-1);
    c[1]:= 0;
    c[3]:= 3; (* sometimes documented: c[3]:= 2; *)
    c[5]:= 6;
    c[6]:= Handle; (* for NVDI *)
  END;
  vdi;
END VSetAppBuff;

PROCEDURE VBezCOn(Handle: UNSIGNEDWORD; OnOff: BOOLEAN): UNSIGNEDWORD;
BEGIN
  intin[0]:= ORD(OnOff);
  contrl.c[5]:= 13;
  CallVDI(11,ORD(OnOff),1,Handle);
  RETURN intout[0];
END VBezCOn;

PROCEDURE VBezOn(Handle: UNSIGNEDWORD): UNSIGNEDWORD;

CONST On = 1;

BEGIN
  intin[0]:= On;
  contrl.c[4]:= 4; (* ATARI docs say so *)
  contrl.c[5]:= 13;
  CallVDI(11,On,1,Handle); (* s. st computer 9/1993 p. 93 *)
  RETURN intout[0];
END VBezOn;

PROCEDURE VBezOff(Handle: UNSIGNEDWORD);

CONST Off = 0;

BEGIN
  intin[0]:= Off;
  contrl.c[4]:= 0;
  contrl.c[5]:= 13;
  CallVDI(11,Off,1,Handle); (* s. st computer 9/1993 p. 93 *)
END VBezOff;

PROCEDURE VBezQual(Handle : UNSIGNEDWORD;
                   Percent: UNSIGNEDWORD): UNSIGNEDWORD;
BEGIN
  intin[0]:= 32;
  intin[1]:= 1;
  intin[2]:= Percent;
  contrl.c[4]:= 1;
  CallVDIEsc(99,0,3,Handle);
  RETURN intout[0];
END VBezQual;

PROCEDURE VQBez(Handle: UNSIGNEDWORD):BOOLEAN;

VAR Qual: UNSIGNEDWORD;

BEGIN
  Qual:= VBezQual(Handle,100);
  intout[0]:= 0;
  Qual:= VBezOn(Handle);
  VBezOff(Handle);
  RETURN Qual # 0;
END VQBez;

PROCEDURE VPatRotate(Handle: UNSIGNEDWORD;
                     Angle : UNSIGNEDWORD);
BEGIN
  intin[0]:= Angle;
  CallVDI(134,0,1,Handle);
END VPatRotate;

PROCEDURE VSaveCache(    Handle  : UNSIGNEDWORD;
                     VAR FileName: ARRAY OF CHAR): SIGNEDWORD;

VAR i: [0..MaxInput];

BEGIN
#if ST
  IF HIGH(FileName) > (MaxInput - 1) THEN
    RETURN 0; (* too long *)
  END;

  IF VQFSMGDOS() THEN
    i:= 0;
    LOOP
      IF FileName[i] # EOS THEN
        intin[i]:= ORD(FileName[i]);
      ELSE
        EXIT;
      END;
      INC(i);
      IF i > HIGH(FileName) THEN
        EXIT;
      END;
    END;
    CallVDI(249,0,i,Handle);
    RETURN intout[0];
  END;
#endif
  RETURN 0;
END VSaveCache;

PROCEDURE VLoadCache(    Handle  : UNSIGNEDWORD;
                     VAR FileName: ARRAY OF CHAR;
                         Replace : BOOLEAN): SIGNEDWORD;

VAR i: [0..MaxInput];

BEGIN
#if ST
  IF HIGH(FileName) > (MaxInput - 2) THEN
    RETURN 0; (* too long *)
  END;

  IF VQFSMGDOS() THEN
    intin[0]:= ORD(Replace);
    i:= 0;
    LOOP
      IF FileName[i] # EOS THEN
        intin[i + 1]:= ORD(FileName[i]);
      ELSE
        EXIT;
      END;
      INC(i);
      IF i > HIGH(FileName) THEN
        EXIT;
      END;
    END;
    CallVDI(250,0,i + 1,Handle);
    RETURN intout[0];
  END;
#endif
  RETURN -1;
END VLoadCache;

PROCEDURE VFlushCache(Handle: UNSIGNEDWORD): SIGNEDWORD;
BEGIN
#if ST
  IF VQFSMGDOS() THEN
    CallVDI(251,0,0,Handle);
    RETURN intout[0];
  END;
#endif
  RETURN -1;
END VFlushCache;

PROCEDURE VGetOutline(    Handle  : UNSIGNEDWORD;
                          Char    : CHAR;
                      VAR XYArray : ARRAY OF XY;
                      VAR BezArray: ARRAY OF ANYBYTE;
                          MaxVerts: UNSIGNEDWORD;
                      VAR NumVerts: UNSIGNEDWORD);

VAR P: POINTER TO ARRAY[0..1] OF ANYPOINTER;

BEGIN
  intin[0]:= ORD(Char);
  intin[1]:= MaxVerts;
  P:= ADR(intin[2]);
  P^[0]:= ADR(XYArray);
  P^[1]:= ADR(BezArray);
  contrl.c[2]:= 0;
  contrl.c[4]:= 1;
  CallVDI(243,0,6,Handle);
  NumVerts:= intout[0];
END VGetOutline;

(* with SpeedoGDOS no longer documented
PROCEDURE VKillOutline(Handle: UNSIGNEDWORD; Outline: ...);
BEGIN
  ...
  CallVDI(242,0,1,Handle);
END VKillOutline;
*)

PROCEDURE VSTScratch(Handle: UNSIGNEDWORD; Mode: UNSIGNEDWORD);
BEGIN
  intin[0]:= Mode;
  CallVDI(244,0,1,Handle);
END VSTScratch;

PROCEDURE VSTError(    Handle  : UNSIGNEDWORD;
                       Mode    : BOOLEAN;
                   VAR ErrorVar: SIGNEDWORD);

VAR P: POINTER TO SIGNEDWORD;

BEGIN
  intin[0]:= ORD(Mode);
  P:= ADR(intin[1]);
  P^:= ErrorVar;
  CallVDI(245,0,3,Handle);
END VSTError;

PROCEDURE VSTCharMap(Handle: UNSIGNEDWORD; Mode: BOOLEAN);
BEGIN
#if ST
  intin[0]:= ORD(Mode);
  CallVDI(236,0,1,Handle);
#endif
END VSTCharMap;

PROCEDURE VQTDevInfo(    Handle: UNSIGNEDWORD;
                         Device: UNSIGNEDWORD;
                     VAR Exists: SIGNEDWORD;
                     VAR DevStr: ARRAY OF CHAR);

VAR i: IntegerOutputRange;

BEGIN
#if ST
  intin[0]:= Device;
  CallVDI(248,0,1,Handle);
  Exists:= ptsout[0];
  i:= 0; (* ST-COMPUTER 6/1994 p. 32: i:= 1; *)
  IF Exists = 1 THEN
    WHILE i < contrl.c[4] DO
      DevStr[i]:= CHR(CAST(UNSIGNEDWORD,intout[i]));
      INC(i);
    END;
  END;
  DevStr[i]:= EOS;
#endif
END VQTDevInfo;

PROCEDURE VQScrnInfo(    Handle : UNSIGNEDWORD;
                     VAR WorkOut: ARRAY OF UNSIGNEDWORD);

#if ST
CONST EdDI = 045644449H;

VAR Value: CookieVal;
#endif

BEGIN
#if ST
  IF GetCookie(EdDI,Value) THEN
    v.iooff:= ADR(WorkOut);
    intin[0]:= 2; (* ? *)
    contrl.c[5]:= 1;
    CallVDI(102,0,1,Handle);
    v.iooff:= ADR(intout);
  ELSE
    intout[0]:= 0; (* error *)
  END;
#else
  intout[0]:= 0; (* error *)
#endif
END VQScrnInfo;

#if ST
BEGIN
  OffScreen:= 0;
#endif
END VControl.

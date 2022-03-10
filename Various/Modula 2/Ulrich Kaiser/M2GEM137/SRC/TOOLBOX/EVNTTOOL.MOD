IMPLEMENTATION MODULE EvntTool;

(*
Event Tools.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)
(*DRIVER*)

FROM EvntMgr  IMPORT MesagBlk,
                     Event,Events,MouseButton,MBLeft,MoEnter,
                     SpecialKey,Key,
                     MEvent;
FROM PORTAB   IMPORT ANYBYTE,ANYWORD,UNSIGNEDWORD,SIGNEDWORD,ANYTYPE,
                     UNSIGNEDLONG,ANYPOINTER;
FROM RcMgr    IMPORT GRect,GPnt;
FROM pSTORAGE IMPORT ALLOCATE,DEALLOCATE;
FROM SYSTEM   IMPORT ADR,ADDRESS;
CAST_IMPORT

IMPORT EvntMgr;

TYPE KeybdListPtr = POINTER TO KeybdList;

     KeybdList = RECORD
                   Next : KeybdListPtr;
                   Keybd: KeybdProc;
                 END;

     ButtonListPtr = POINTER TO ButtonList;

     ButtonList = RECORD
                    Next  : ButtonListPtr;
                    Button: ButtonProc;
                  END;

     M1ListPtr = POINTER TO M1List;

     M1List = RECORD
                Next: M1ListPtr;
                M1  : M1Proc;
              END;

     M2ListPtr = POINTER TO M2List;

     M2List = RECORD
                Next: M2ListPtr;
                M2  : M2Proc;
              END;

     MesagListPtr = POINTER TO MesagList;

     MesagList = RECORD
                   Next : MesagListPtr;
                   Mesag: MesagProc;
                 END;

     TimerListPtr = POINTER TO TimerList;

     TimerList = RECORD
                   Next : TimerListPtr;
                   Timer: TimerProc;
                 END;

VAR KeybdProcs : KeybdListPtr;
    ButtonProcs: ButtonListPtr;
    M1Procs    : M1ListPtr;
    M2Procs    : M2ListPtr;
    MesagProcs : MesagListPtr;
    TimerProcs : TimerListPtr;

    TheEventBlock: MEvent;

PROCEDURE AddKeybdProc(KeybdFunc: KeybdProc);

VAR Temp: KeybdListPtr;

BEGIN
  Temp:= KeybdProcs;
  IF Temp = NIL THEN
    RETURN;
  END;

  WHILE Temp^.Next # NIL DO
    Temp:= Temp^.Next;
  END;

  NEW(Temp^.Next);
  Temp:= Temp^.Next;
  IF Temp # NIL THEN
    WITH Temp^ DO
      Next:= NIL;
      Keybd:= KeybdFunc;
    END;
    INCL(TheEventBlock.EFlags,MuKeybd);
  END;
END AddKeybdProc;

PROCEDURE RemoveKeybdProc(KeybdFunc: KeybdProc);

VAR Temp: KeybdListPtr;
    Last: KeybdListPtr;

BEGIN
  Temp:= KeybdProcs;
  IF Temp = NIL THEN
    RETURN;
  END;

  IF Temp^.Next # NIL THEN (* list will contain some procs *)
    Last:= Temp; (* save last ptr *)
    Temp:= Temp^.Next; (* skip over *)
    WHILE (Temp^.Next # NIL) DO
#if proc_compare
      IF (Temp^.Keybd = KeybdFunc) THEN
#else
      IF CAST(ADDRESS,Temp^.Keybd) = CAST(ADDRESS,KeybdFunc) THEN
#endif
        Last^.Next:= Temp^.Next;
        DISPOSE(Temp);
        RETURN; (* exit *)
      END;
      Last:= Temp; (* Last^.Next is # NIL *)
      Temp:= Temp^.Next;
    END;
  END;
END RemoveKeybdProc;

PROCEDURE AddButtonProc(ButtonFunc: ButtonProc);

VAR Temp: ButtonListPtr;

BEGIN
  Temp:= ButtonProcs;
  IF Temp = NIL THEN
    RETURN;
  END;

  WHILE Temp^.Next # NIL DO
    Temp:= Temp^.Next;
  END;

  NEW(Temp^.Next);
  Temp:= Temp^.Next;
  IF Temp # NIL THEN
    WITH Temp^ DO
      Next:= NIL;
      Button:= ButtonFunc;
    END;
  END;
END AddButtonProc;

PROCEDURE RemoveButtonProc(ButtonFunc: ButtonProc);

VAR Temp: ButtonListPtr;
    Last: ButtonListPtr;

BEGIN
  Temp:= ButtonProcs;
  IF Temp = NIL THEN
    RETURN;
  END;

  IF Temp^.Next # NIL THEN (* list will contain some procs *)
    Last:= Temp; (* save last ptr *)
    Temp:= Temp^.Next; (* skip over *)
    WHILE (Temp^.Next # NIL) DO
#if proc_compare
      IF (Temp^.Button = ButtonFunc) THEN
#else
      IF CAST(ADDRESS,Temp^.Button) = CAST(ADDRESS,ButtonFunc) THEN
#endif
        Last^.Next:= Temp^.Next;
        DISPOSE(Temp);
        RETURN; (* exit *)
      END;
      Last:= Temp; (* Last^.Next is # NIL *)
      Temp:= Temp^.Next;
    END;
  END;
END RemoveButtonProc;

(*
PROCEDURE AddM1Proc
BEGIN

END

PROCEDURE RemoveM1Proc
BEGIN

END

PROCEDURE AddM2Proc
BEGIN

END

PROCEDURE RemoveM2Proc
BEGIN

END
*)

PROCEDURE AddMesagProc(MesagFunc: MesagProc);

VAR Temp: MesagListPtr;

BEGIN
  Temp:= MesagProcs;
  IF Temp = NIL THEN
    RETURN;
  END;

  WHILE Temp^.Next # NIL DO
    Temp:= Temp^.Next;
  END;

  NEW(Temp^.Next);
  Temp:= Temp^.Next;
  IF Temp # NIL THEN
    WITH Temp^ DO
      Next:= NIL;
      Mesag:= MesagFunc;
    END;
    INCL(TheEventBlock.EFlags,MuMesag);
  END;
END AddMesagProc;

PROCEDURE RemoveMesagProc(MesagFunc: MesagProc);

VAR Temp: MesagListPtr;
    Last: MesagListPtr;

BEGIN
  Temp:= MesagProcs;
  IF Temp = NIL THEN
    RETURN;
  END;

  IF Temp^.Next # NIL THEN (* list will contain some procs *)
    Last:= Temp; (* save last ptr *)
    Temp:= Temp^.Next; (* skip over *)
    WHILE (Temp^.Next # NIL) DO
#if proc_compare
      IF (Temp^.Mesag = MesagFunc) THEN
#else
      IF CAST(ADDRESS,Temp^.Mesag) = CAST(ADDRESS,MesagFunc) THEN
#endif
        Last^.Next:= Temp^.Next;
        DISPOSE(Temp);
        RETURN; (* exit *)
      END;
      Last:= Temp; (* Last^.Next is # NIL *)
      Temp:= Temp^.Next;
    END;
  END;
END RemoveMesagProc;

(*
PROCEDURE AddTimerProc

PROCEDURE RemoveTimerProc
*)

VAR TheMessage: MesagBlk;

PROCEDURE NextEvent;

VAR MyEvent   : Event;
    KeybdList : KeybdListPtr;
    ButtonList: ButtonListPtr;
    M1List    : M1ListPtr;
    M2List    : M2ListPtr;
    MesagList : MesagListPtr;
    TimerList : TimerListPtr;

BEGIN
  MyEvent:= EvntMgr.evntevent(TheEventBlock);

  WITH TheEventBlock DO

    IF MuMesag IN MyEvent THEN
      MesagList:= MesagProcs;
      IF MesagList # NIL THEN

        LOOP
          IF MesagList^.Next = NIL THEN
            EXIT;
          END;

          MesagList:= MesagList^.Next;
          IF NOT MesagList^.Mesag(EMePBuf) THEN
            EXIT;
          END;
        END;

      END;
    END;

    IF MuKeybd IN MyEvent THEN
      KeybdList:= KeybdProcs;
      IF KeybdList # NIL THEN

        LOOP
          IF KeybdList^.Next = NIL THEN
            EXIT;
          END;

          KeybdList:= KeybdList^.Next;
          IF NOT KeybdList^.Keybd(EKR,EKS) THEN
            EXIT;
          END;
        END;

      END;
    END;

    IF MuButton IN MyEvent THEN
      ButtonList:= ButtonProcs;
      IF ButtonList # NIL THEN

        LOOP
          IF ButtonList^.Next = NIL THEN
            EXIT;
          END;

          ButtonList:= ButtonList^.Next;
          IF NOT ButtonList^.Button(EBR,EMXY,EMB,EKS) THEN
            EXIT;
          END;
        END;

      END;
    END;

    IF MuM1 IN MyEvent THEN
      M1List:= M1Procs;
      IF M1List # NIL THEN

        LOOP
          IF M1List^.Next = NIL THEN
            EXIT;
          END;

          M1List:= M1List^.Next;
          IF NOT M1List^.M1(EM1) THEN
            EXIT;
          END;
        END;

      END;
    END;

    IF MuM2 IN MyEvent THEN
      M2List:= M2Procs;
      IF M1List # NIL THEN

        LOOP
          IF M2List^.Next = NIL THEN
            EXIT;
          END;

          M2List:= M2List^.Next;
          IF NOT M2List^.M2(EM2) THEN
            EXIT;
          END;
        END;

      END;
    END;

    IF MuTimer IN MyEvent THEN
      TimerList:= TimerProcs;
      IF TimerList # NIL THEN

        LOOP
          IF TimerList^.Next = NIL THEN
            EXIT;
          END;

          TimerList:= TimerList^.Next;
          IF NOT TimerList^.Timer() THEN
            EXIT;
          END;
        END;

      END;
    END;

  END;
END NextEvent;

PROCEDURE EventLoop;
BEGIN
  LOOP
    NextEvent;
  END;
END EventLoop;

BEGIN
  NEW(KeybdProcs);
  IF KeybdProcs # NIL THEN
    KeybdProcs^.Next:= NIL;
  END;

  NEW(ButtonProcs);
  IF ButtonProcs # NIL THEN
    ButtonProcs^.Next:= NIL;
  END;

  NEW(M1Procs);
  IF M1Procs # NIL THEN
    M1Procs^.Next:= NIL;
  END;

  NEW(M2Procs);
  IF M2Procs # NIL THEN
    M2Procs^.Next:= NIL;
  END;

  NEW(MesagProcs);
  IF MesagProcs # NIL THEN
    MesagProcs^.Next:= NIL;
  END;

  NEW(TimerProcs);
  IF TimerProcs # NIL THEN
    TimerProcs^.Next:= NIL;
  END;

  (* initialization of the event block *)

  WITH TheEventBlock DO
    EFlags:= Event{};
    EBClk:= 2;
    EBMsk:= MouseButton{MBLeft};
    EBSt:= MouseButton{MBLeft};
    EM1Flags:= MoEnter;
    EM2Flags:= MoEnter;
    ELoCount:= 250;
    EHiCount:= 0;
    EMePBuf:= ADR(TheMessage);
  END;

(*
  atexit(DisposeProcs);
*)
END EvntTool.
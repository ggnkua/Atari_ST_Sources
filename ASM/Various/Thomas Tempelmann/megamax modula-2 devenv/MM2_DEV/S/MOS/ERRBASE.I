IMPLEMENTATION MODULE ErrBase; (* V#119 *)
(*$X+,Y+,S-,R-*)
(* kein N+ einfÅgen! Runtime muû vor ErrBase importiert und init. werden,
 * damit Runtime u.U. in MOSConfig "CaughtExceptions" f.die FPU-Exc
 * erweitern kann! *)

(*
  01.12.88 TT  SysInstalExc verw.
  16.01.90 TT  CHK fÅhrt zu 'OutOfRange'
  23.02.90 TT  Install/Remove exportiert, um Exc-Handler bei Accessories
               von Auûen zu installieren;
               Wenn kein Handler installiert, wird SystemError bemÅht
  01.03.90 TT  Bei nicht installiertem Error-Handler wird kein normaler
               Pterm sondern die entspr. Exception ausgelîst.
  01.05.90 TT  'ExcInstalled' wird bei 'RemoveExc' wieder auf FALSE gesetzt
  03.07.90 TT  'raising'-Abfrage entfernt: RaiseError sollte wieder gehen
  29.07.90 TT  Korrektur in catchUser: RaiseError geht endlich wieder
  25.11.90 TT  Wenn Handler nicht installiert, wird nur 'ExcInstalled' auf
               FALSE gesetzt -> Aufrufer muû die Var prÅfen;
               Die FPU-Exceptions werden nun erkannt und die entspr. Laufzeit-
               fehlernummern an den Err-Handler Åbergeben, zudem wird das
               Bit 27 im BIU der FPU immer gesetzt, damit die FPU ggf. bei
               "continue" weiterlaufen kann; $S-.
  18.12.90 TT  FPU-Operand-Error fÅhrt zu 'OutOfRange'
  08.04.91 TT  Alle CaughtExceptions werden nun in MOSConfig gesetzt.
*)

FROM SYSTEM IMPORT ADR,ADDRESS,BYTE,LONGWORD,TSIZE, WORD, ASSEMBLER;

FROM Excepts IMPORT RaiseExc, SysInstallPreExc, DeInstallExc;

FROM SysTypes IMPORT ExcDesc, ZeroDivide, TRAP6, CHKExc, TRAPVExc, ExcSet,
        BSUnExc, FPZeroDivide, OpError, FPOverflow, NANExc;

FROM MOSConfig IMPORT CaughtExceptions, IgnoreExceptions;

FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;

IMPORT MOSGlobals;


VAR hdl2, hdl1:ADDRESS;
    gl_no: INTEGER;
    gl_cont: RtnCond;
    gl_resp: ErrResp;
    gl_msg: ARRAY [0..31] OF CHAR;

PROCEDURE catch (VAR info: ExcDesc): BOOLEAN;
  VAR no:INTEGER;
      zw: BOOLEAN;
      msg:ARRAY [0..31] OF CHAR;
      cont: RtnCond;
      resp: ErrResp;
  BEGIN
    msg:='';
    cont:= mayContinue;
    resp:= selfCaused;
    IF (LONGCARD(ErrHdl) = 0L) OR (info.excNo IN IgnoreExceptions) THEN
      RETURN TRUE
    ELSIF info.excNo=2 THEN
      cont:= mustAbort;
      no := MOSGlobals.BusFault
    ELSIF info.excNo=3 THEN
      cont:= mustAbort;
      no := MOSGlobals.OddBusAddr
    ELSIF info.excNo=4 THEN
      IF info.regPC^ = WORD ($4AFC) THEN
        RETURN TRUE (* Break zum Monitor immer durchlassen *)
      END;
      cont:= mustAbort;
      no := MOSGlobals.IllegalInstr
    ELSIF (info.excNo=NANExc) OR (info.excNo=BSUnExc) THEN
      no := MOSGlobals.GenFPErr
    ELSIF (info.excNo=ZeroDivide) OR (info.excNo=FPZeroDivide) THEN
      no := MOSGlobals.DivByZero
    ELSIF (info.excNo=FPOverflow) OR (info.excNo=TRAPVExc) THEN
      no := MOSGlobals.Overflow
    ELSIF (info.excNo=OpError) OR (info.excNo=CHKExc) THEN
      no := MOSGlobals.OutOfRange
    ELSIF info.excNo=TRAP6 THEN
      ASSEMBLER
        MOVE.L  info(A6),A0
        MOVE.L  ExcDesc.regPC(A0),A1
        MOVE.W  (A1)+,D0
        BMI     notxt
        
        LEA     msg(A6),A2
        MOVEQ   #31,D2
       loo:
        MOVE.B  (A1)+,(A2)+
        DBEQ    D2,loo
        BEQ     c2
       l2:
        TST.B   (A1)+
        BNE     l2
       c2:
        MOVE    A1,D1
        LSR     #1,D1
        BCC     c3
        ADDQ.L  #1,A1
       c3:
        
       notxt:
        MOVE.L  A1,ExcDesc.regPC(A0)
        MOVE    D0,D1
        LSL     #4,D1
        ASR     #4,D1
        MOVE    D1,no(A6)
        
        BTST    #14,D0
        SEQ     D1
        ANDI    #1,D1
        MOVE    D1,resp(A6)
        
        BTST    #13,D0
        SEQ     D1
        ANDI    #1,D1
        MOVE    D1,cont(A6)
      END
    ELSE
      no:= MOSGlobals.Exception
    END;
    ASSEMBLER
        ; bei FPU-Exceptions (48-54) diese bei der FPU bestÑtigen
        MOVE.L  info(A6),A0
        MOVE.W  ExcDesc.excNo(A0),D0
        CMPI    #48,D0
        BCS     noFPU
        CMPI    #54,D0
        BHI     noFPU
        
        ; Set Bit 27 in BIU
        CLR.L   -(A7)
        MOVE    #$20,-(A7)      ; Super (0)
        TRAP    #1
        MOVE.L  D0,2(A7)
        FSAVE   -(SP)
        TST.B   (SP)
        BEQ     nullFrame
        CLR     D0
        MOVE.B  1(SP),D0
        BSET    #3,(SP,D0.W)
      nullFrame
        FRESTORE (SP)+
        TRAP    #1
        ADDQ.L  #6,A7
        
      noFPU
        MOVE    no(A6),(A3)+
        LEA     msg(A6),A0
        MOVE.L  A0,(A3)+
        MOVE    #31,(A3)+
        MOVE    resp(A6),(A3)+
        MOVE    cont(A6),(A3)+
        MOVE.L  info(A6),(A3)+
        MOVE.L  ErrHdl,A0
        JSR     (A0)
    END;
    RETURN FALSE
  END catch;


PROCEDURE catchUser (VAR info:ExcDesc): BOOLEAN;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D1
        MOVE.L  ErrHdl,D0
        BEQ     retT
        MOVE.L  D0,A0
        MOVE    gl_no,(A3)+
        MOVE.L  #gl_msg,(A3)+
        MOVE    #31,(A3)+
        MOVE    gl_resp,(A3)+
        MOVE    gl_cont,(A3)+
        MOVE.L  D1,(A3)+
        JSR     (A0)
        CLR     (A3)+
        RTS
      retT:
        MOVE    #1,(A3)+
    END
  END catchUser;
  (*$L+*)

PROCEDURE RaiseError ( no    : INTEGER;
                       REF msg   : ARRAY OF CHAR;
                       causer: ErrResp;
                       cont  : RtnCond );
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE    -(A3),gl_cont
        MOVE    -(A3),gl_resp
        
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0
        LEA     gl_msg,A1
        MOVEQ   #31,D1
        BRA     y
     x: SUBQ    #1,D0
        BCS     o         ; Source-Ende, Dest. muss Endmarke bekommen
     y: MOVE.B  (A0)+,(A1)+
        DBEQ    D1,x
        BRA     e
     o: CLR.B   (A1)+
     
     e: MOVE    -(A3),gl_no
        
        MOVE    #$E0,(A3)+
        JMP     RaiseExc
    END
  END RaiseError;
  (*$L+*)


PROCEDURE RemoveExc;
  BEGIN
    IF ExcInstalled THEN
      DeInstallExc (hdl1);
      DeInstallExc (hdl2);
      ExcInstalled:= FALSE;
    END
  END RemoveExc;

VAR stk: ARRAY [1..500] OF WORD;
    wsp: MOSGlobals.MemArea;
    rHdl: RemovalCarrier;

PROCEDURE InstallExc;
  BEGIN
    IF NOT ExcInstalled THEN
      SysInstallPreExc (CaughtExceptions, catch, TRUE, wsp, hdl2 );
      IF hdl2 # NIL THEN
        SysInstallPreExc (ExcSet{$E0}, catchUser, TRUE, wsp, hdl1); (* reservierte Exc-Nr.*)
        IF hdl1 # NIL THEN
          ExcInstalled:= TRUE
        ELSE
          DeInstallExc (hdl2)
        END
      END
    END;
  END InstallExc;

BEGIN
  ExcInstalled:= FALSE;
  ErrHdl:= ErrHdlProc (0L);
  CatchRemoval (rHdl, RemoveExc, wsp);
  wsp.bottom:= ADR (stk);
  wsp.length:= SIZE (stk);
END ErrBase.

(* $00001455$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$00001122$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$FFFA73DA$000018B6Ä$0000057CT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000110$0000057E$0000053B$FFE489D2$00000AE4$FFE489D2$0000196B$0000197A$00000539$00000541$0000057C$0000054B$0000057C$0000006F$00000BC7$00000BEF∏ÄÅ*)

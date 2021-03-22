IMPLEMENTATION MODULE AESEvents; (*$L-, Y+*)


(*  Megamax Modula-2 GEM-Library :  Die AES Ereignisfunktionen
 *
 *  Autor: Manuel Chakravarty           Erstellt :  05.11.87
 *
 *  Version   2.2     V#0040
 *)
 
(*  05.11.87    | šbernahme von 'GEMBase' und 'GEMExt'
 *  15.05.88    | Stack wird bei 'TimerEvent' und 'MessageEvent' richtig
 *                berichtigt.
 *  27.06.89    | Sch”nheitskorrekturen (Keine Def. oder Impl. „nderungen)
 *  12.01.90 TT | ROL -> LSR teilw. ersetzt, weil bei Byte-Sets MSByte
 *                undefiniert ist
 *  11.02.90    | Anpassung auf Compilerversion 4.0 (angefangen)
 *  15.02.90    | A3-Stackbehandlung jetzt bei 'ButtonEvent' hoffentlich
 *                immer richtig + Anpassung auf Compilerversion 4.0 (beendet)
 *  02.04.90    | Anpassung auf public arrays
 *  23.11.90    | Def-Text: MessageBuffer um 'int' erweitert, Doku korrigiert.
 *  06.12.90    | Def-Text: MessageBuffer korrigiert.
 *  10.03.91 TT | A3-Stackbehandlung bei 'ButtonEvent' nochmal korrigiert.
 *)

FROM    SYSTEM          IMPORT ASSEMBLER;

FROM    GrafBase        IMPORT Point, Rectangle;
 
FROM    GEMGlobals      IMPORT GemChar, MButtonSet, SpecialKeySet;
 
IMPORT  GEMShare;


(*$I GEMOPS.ICL *)
 
PROCEDURE keyboardEvent (): GemChar;
  BEGIN
    ASSEMBLER
        MOVE.W  #EVNT_KEYBD,(A3)+
        JSR     aes_if
        MOVE.L  pubs,A0
        MOVE.W  pubArrays.aINTOUT(A0),(A3)+
    END;
  END keyboardEvent;

PROCEDURE KeyboardEvent (VAR ch: GemChar);

  VAR   keys: SpecialKeySet;

  (*$L+*)
  BEGIN
    ASSEMBLER
again
        JSR     keyboardEvent
        MOVE.L  ch(A6),A0
        MOVE.W  -(A3),(A0)
        
        TST.W   keyboardPlugActive      ; watch-dog plug
        BEQ     ende
        CLR.B   keys(A6)
        MOVE.L  ch(A6),(A3)+            ; 'ch' als VAR-Parm. bergeben
        LEA     keys(A6),A1
        MOVE.L  A1,(A3)+                ; 'keys' als VAR-Parm. bergeben
        MOVE.L  keyboardPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BEQ     again
ende
    END;
  END KeyboardEvent;
  (*$L=*)

PROCEDURE buttonEvent (    clicks     : CARDINAL;
                           mask, state: MButtonSet;
                       VAR mouseLoc   : Point;
                       VAR buttons    : MButtonSet;
                       VAR keyState   : SpecialKeySet): CARDINAL;
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        
        MOVE.L  pubs,A0
        LEA     pubArrays.aINTIN+6(A0),A0
        MOVEQ   #0, D0
        SUBQ.L  #2, A3
        MOVE.B  (A3), D0
        MOVE.W  D0, -(A0)
        SUBQ.L  #2, A3
        MOVE.B  (A3), D0
        MOVE.W  D0, -(A0)
        MOVE.W  -(A3),-(A0)
        
        MOVE.W  #EVNT_BUTTON,(A3)+
        JSR     aes_if
        
        MOVE.L  pubs,A0
        LEA     pubArrays.aINTOUT(A0),A0
        MOVE.W  (A0)+,(A3)+
        MOVE.L  (A7)+,A1
        MOVE.L  (A0)+,(A1)
        MOVE.L  (A7)+,A1
        MOVE.W  (A0)+,D0
        MOVE.B  D0,(A1)
        MOVE.L  (A7)+,A1
        MOVE.W  (A0)+,D0
        MOVE.B  D0,(A1)
    END;
  END buttonEvent;

PROCEDURE ButtonEvent (    clicks     : CARDINAL;
                           mask, state: MButtonSet;
                       VAR mouseLoc   : Point;
                       VAR buttons    : MButtonSet;
                       VAR keyState   : SpecialKeySet;
                       VAR doneClicks : CARDINAL);

  VAR   clickResult: CARDINAL;

  (*$L+*)
  BEGIN
    ASSEMBLER
again
        MOVE.W  clicks(A6), (A3)+
        MOVE.W  mask(A6), (A3)+
        MOVE.W  state(A6), (A3)+
        MOVE.L  mouseLoc(A6), (A3)+
        MOVE.L  buttons(A6), (A3)+
        MOVE.L  keyState(A6), (A3)+
        JSR     buttonEvent
        MOVE.W  -(A3),clickResult(A6)   ; clicks retten
        
        TST.W   buttonPlugActive        ; watch-dog plug
        BEQ     ende
        MOVE.W  clickResult(A6),(A3)+
        MOVE.L  mouseLoc(A6),A0
        MOVE.L  (A0),(A3)+
        MOVE.L  buttons(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  keyState(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  buttonPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BEQ     again
ende

        MOVE.L  doneClicks(A6),A0
        MOVE.W  clickResult(A6), (A0)
    END;
  END ButtonEvent;
  (*$L=*)

PROCEDURE mouseEvent (    moveDirec: RectEnterMode;
                          frame    : Rectangle;
                      VAR buttons  : MButtonSet;
                      VAR keyState : SpecialKeySet;
                      VAR loc      : Point): LONGCARD;

  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        
        MOVE.L  pubs,A0
        LEA     pubArrays.aINTIN+$A(A0),A0
        MOVE.L  -(A3),-(A0)
        MOVE.L  -(A3),-(A0)
        MOVE.W  -(A3),-(A0)
        MOVE.W  #EVNT_MOUSE,(A3)+
        JSR     aes_if
        
        MOVE.L  pubs,A0
        LEA     pubArrays.aINTOUT+2(A0),A0
        MOVE.L  (A0)+,(A3)+
        MOVE.L  (A7)+,A1
        MOVE.W  (A0)+,D0
        MOVE.B  D0,(A1)         ; SET belegt nur ein Byte
        MOVE.L  (A7)+,A1
        MOVE.W  (A0)+,D0
        MOVE.B  D0,(A1)         ; SET belegt nur ein Byte
    END;
  END mouseEvent;

PROCEDURE MouseEvent (    moveDirec: RectEnterMode;
                          frame    : Rectangle;
                      VAR buttons  : MButtonSet;
                      VAR keyState : SpecialKeySet;
                      VAR loc      : Point);

  VAR   locResult: Point;
                     
  (*$L+*)
  BEGIN
    ASSEMBLER
again
        MOVEQ   #3,D0
        LEA     moveDirec(A6),A0
loop    MOVE.L  (A0)+,(A3)+
        DBF     D0,loop
        MOVE.W  (A0),(A3)+
        JSR     mouseEvent
        MOVE.L  -(A3),locResult(A6)
        
        TST.W   firstRectPlug
        BEQ     cont
        MOVE.L  locResult(A6),(A3)+
        MOVE.L  buttons(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  keyState(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  firstRectPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BEQ     again
cont
        TST.W   secondRectPlug
        BEQ     cont2
        MOVE.L  locResult(A6),(A3)+
        MOVE.L  buttons(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  keyState(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  secondRectPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BEQ     again
cont2

        MOVE.L  loc(A6),A0
        MOVE.L  locResult(A6),(A0)      ;  loc:=locResult
    END;
  END MouseEvent;
  (*$L=*)

PROCEDURE TimerEvent (time: LONGCARD);

  BEGIN
    ASSEMBLER
again
        MOVE.L  A3,A1
        MOVE.L  pubs,A0
        MOVE.L  -(A1),D0
        SWAP    D0
        MOVE.L  D0,pubArrays.aINTIN(A0)
        MOVE.W  #EVNT_TIMER,(A3)+
        JSR     aes_if
        
        TST.W   timerPlugActive
        BEQ     cont
        MOVE.L  timerPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BEQ     again
cont
        SUBQ.L  #4,A3
    END;
  END TimerEvent;

PROCEDURE MessageEvent (VAR msg: MessageBuffer);

  BEGIN
    ASSEMBLER
again
        MOVE.L  A3,A1
        MOVE.L  pubs,A0
        MOVE.L  -(A1),pubArrays.ADDRIN(A0)
        MOVE.W  #EVNT_MESAG,(A3)+
        JSR     aes_if
        
        TST.W   messagePlugActive
        BEQ     cont
        MOVE.L  A3,A1
        MOVE.L  -(A1),A0
        MOVEQ   #3,D0
loop
        MOVE.L  (A0)+,(A3)+
        DBF     D0,loop
        MOVE.L  messagePlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BEQ     again
cont
        SUBQ.L  #4,A3
    END;
  END MessageEvent;

PROCEDURE multiEvent (    events       : EventSet;
                          noClicks     : CARDINAL;
                          butMask,
                          butState     : MButtonSet;
                          moveDirec1   : RectEnterMode; rect1Size: Rectangle;
                          moveDirec2   : RectEnterMode; rect2Size: Rectangle;
                      VAR msg          : MessageBuffer;
                          time         : LONGCARD;
                      VAR mouseLoc     : Point;
                      VAR buttons      : MButtonSet;
                      VAR keyState     : SpecialKeySet;
                      VAR key          : GemChar;
                      VAR doneClicks   : CARDINAL): EventSet;
  BEGIN
    ASSEMBLER
        MOVEQ   #4,D0
loop1
        MOVE.L  -(A3),-(A7)     ; 5 VAR-Parameter addr on the stack
        DBF     D0,loop1
        MOVE.L  pubs,A0
        LEA     pubArrays.aINTIN+32(A0),A1
        MOVE.L  -(A3),D0
        SWAP    D0
        MOVE.L  D0,-(A1)        ; 'time'
        MOVE.L  -(A3),pubArrays.ADDRIN(A0)     ; VAR address from 'msg'
        MOVEQ   #4,D0
loop2
        MOVE.L  -(A3),-(A1)     ; 5x2 words data from parm.stack -> aINTIN
        DBF     D0,loop2
        MOVEQ   #0, D0
        SUBQ.L  #1, A3
        MOVE.B  -(A3), D0
        MOVE.W  D0, -(A1)       ; 'butState' -> aINTIN
        SUBQ.L  #1, A3
        MOVE.B  -(A3), D0
        MOVE.W  D0, -(A1)       ; 'butMask' -> aINTIN
        MOVE.W  -(A3), -(A1)    ; 'noClicks' -> aINTIN
        MOVEQ   #0, D0
        SUBQ.L  #1, A3
        MOVE.B  -(A3), D0
        MOVE.W  D0, -(A1)       ; 'events' -> aINTIN
        MOVE.W  #EVNT_MULTI,(A3)+
        JSR     aes_if
        
        MOVE.L  pubs,A0
        LEA     pubArrays.aINTOUT(A0),A0
        MOVE.W  (A0)+,D0
        MOVE.B  D0,(A3)+
        ADDQ.L  #1, A3
        MOVE.L  (A7)+,A1
        MOVE.L  (A0)+,(A1)      ; 'mouseLoc.x/.y'
        MOVE.L  (A7)+,A1        ; 'buttons'
        MOVE.W  (A0)+,D0
        MOVE.B  D0,(A1)         ; SET belegt nur 1 Byte
        MOVE.L  (A7)+,A1        ; 'keyState'
        MOVE.W  (A0)+,D0
        MOVE.B  D0,(A1)         ; SET belegt nur 1 Byte
        MOVE.L  (A7)+,A1        ; 'key'
        MOVE.W  (A0)+,(A1)
        MOVE.L  (A7)+,A1        ; 'doneClicks'
        MOVE.W  (A0)+,(A1)
    END;
  END multiEvent;
                     
PROCEDURE MultiEvent (    events       : EventSet;
                          noClicks     : CARDINAL;
                          butMask,
                          butState     : MButtonSet;
                          moveDirec1   : RectEnterMode; rect1Size: Rectangle;
                          moveDirec2   : RectEnterMode; rect2Size: Rectangle;
                      VAR msg          : MessageBuffer;
                          time         : LONGCARD;
                      VAR mouseLoc     : Point;
                      VAR buttons      : MButtonSet;
                      VAR keyState     : SpecialKeySet;
                      VAR key          : GemChar;
                      VAR doneClicks   : CARDINAL;
                      VAR occuredEvents: EventSet);
                     
  VAR   eventResult: EventSet;
                     
  (*$L+*)
  BEGIN
    ASSEMBLER
again
        LEA     events(A6),A0
        MOVEQ   #13,D0
loop
        MOVE.L  (A0)+,(A3)+
        DBF     D0,loop
        JSR     multiEvent
        SUBQ.L  #1, A3
        MOVE.B  -(A3),eventResult(A6)
        
        TST.W   keyboardPlugActive      ; watch-dog plug
        BEQ     noKeyPlug
        BTST    #keyboard,eventResult(A6)
        BEQ     noKeyPlug
        MOVE.L  key(A6),(A3)+
        MOVE.L  keyState(A6),(A3)+
        MOVE.L  keyboardPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BNE     noKeyPlug
        BCLR    #keyboard,eventResult(A6)
noKeyPlug

        TST.W   buttonPlugActive        ; watch-dog plug
        BEQ     noButPlug
        BTST    #mouseButton,eventResult(A6)
        BEQ     noButPlug
        MOVE.L  doneClicks(A6),A0
        MOVE.W  (A0),(A3)+
        MOVE.L  mouseLoc(A6),A0
        MOVE.L  (A0),(A3)+
        MOVE.L  buttons(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  keyState(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  buttonPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BNE     noButPlug
        BCLR    #mouseButton,eventResult(A6)
noButPlug

        TST.W   firstRectPlugActive
        BEQ     noFirstPlug
        BTST    #firstRect,eventResult(A6)
        BEQ     noFirstPlug
        MOVE.L  mouseLoc(A6),A0
        MOVE.L  (A0),(A3)+
        MOVE.L  buttons(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  keyState(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  firstRectPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BNE     noFirstPlug
        BCLR    #firstRect,eventResult(A6)
noFirstPlug

        TST.W   secondRectPlugActive
        BEQ     noSecondPlug
        BTST    #secondRect,eventResult(A6)
        BEQ     noSecondPlug
        MOVE.L  mouseLoc(A6),A0
        MOVE.L  (A0),(A3)+
        MOVE.L  buttons(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  keyState(A6),A0
        MOVE.B  (A0),(A3)+
        ADDQ.L  #1, A3
        MOVE.L  secondRectPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BNE     noSecondPlug
        BCLR    #secondRect,eventResult(A6)
noSecondPlug

        TST.W   timerPlugActive
        BEQ     noTimerPlug
        BTST    #timer,eventResult(A6)
        BEQ     noTimerPlug
        MOVE.L  timerPlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BNE     noTimerPlug
        BCLR    #timer,eventResult(A6)
noTimerPlug

        TST.W   messagePlugActive
        BEQ     noMsgPlug
        BTST    #message,eventResult(A6)
        BEQ     noMsgPlug
        MOVE.L  msg(A6),A0
        MOVEQ   #3,D0
msgLoop
        MOVE.L  (A0)+,(A3)+
        DBF     D0,msgLoop
        MOVE.L  messagePlug,A0
        JSR     (A0)
        TST.W   -(A3)
        BNE     noMsgPlug
        BCLR    #message,eventResult(A6)
noMsgPlug

        MOVE.L  occuredEvents(A6),A0
        MOVE.B  eventResult(A6),(A0)
    END;
  END MultiEvent;
  (*$L=*)
                     
PROCEDURE SetDClickSpeed (speed: CARDINAL);

  BEGIN
    ASSEMBLER
        MOVE.L      pubs,A0
        MOVE.W      -(A3),pubArrays.aINTIN(A0)
        MOVE.W      #1,pubArrays.aINTIN+2(A0)       ; setzen
        MOVE.W      #EVNT_DCLICK,(A3)+
        JSR         aes_if
    END;
  END SetDClickSpeed;

PROCEDURE DClickSpeed (): CARDINAL;

  BEGIN
    ASSEMBLER
        MOVE.L      pubs,A0
        CLR.W       pubArrays.aINTIN+2(A0)          ; lesen
        MOVE.W      #EVNT_DCLICK,(A3)+
        JSR         aes_if
        MOVE.L      pubs,A0
        MOVE.W      pubArrays.aINTOUT(A0),(A3)+
    END;
  END DClickSpeed;


END AESEvents.

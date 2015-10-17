IMPLEMENTATION MODULE GEMShare;
(*$L-, N+, Y+*)


(*      Megamax Modula-2 GEM Library: Von allen GEM-Library-Modulen genutzte
 *                                    Definitionen und Routinen.
 *                                    (INTERNES MODUL)
 *
 *      Autor: Manuel Chakravarty       Erstellt: MÑrz-Dezember 1987
 *
 *      MS: Michael Seyfried
 *
 *      Version 2.1     V#0191
 *)
 
(*  28.12.87    | Switching der Prozeûkennung bei Accsessories
 *  02.01.88    | Die Vektorexchangeroutine benutzen nun das 'DeviceHandle'
 *                und nicht die VDI-GerÑtekennung
 *  22.01.88 TT | vdi_if lÑdt handle runter bei opcode = open_v_work
 *  07.02.88    | Process-switching bei 'aes_call' funktioniert nun korrekt
 *  04.05.88    | VorlÑufige Version ohne Process-switching (fÅr Dietmar
 *              | Rabich)
 *  02.06.88    | 'removeTimerVec' korrigiert
 *  08.04.89    | process switching ganz raus.
 *  28.06.89    | 'checkErrorTest' hat den Zeiger auf die Prozedurvariable
 *                beim Benutzen nicht dereferenziert.
 *  02.08.89    | No more 'suspendedID', 'startID'
 *  03.08.89    | LINK in 'selectFile'
 *  ???????? TT | REF-Parm.
 *  02.04.90    | Aufteilung in public und private Datenstrukturen
 *  13.06.90 TT | echantSuperMode gelîscht
 *  05.10.90    | 'shellRead' def. + impl.
 *  25.11.90 TT | Um Rekursion in GEMError zu verhindern, wird "error" schon
 *                VOR Aufruf des Error-Handlers gelîscht; 'errNum' wird in
 *                setINT0attribut & gemErrorOccured auf Null gesetzt, damit
 *                zumindest ein definierter Wert darin enthalten ist.
 *                'ptrToErrHdler' neu - wird bei Auftreten eines Fehlers
 *                indirekt Åber die GemEnv-Var. "ErrHdlProc" aufgerufen.
 *                öberhaupt: 'testINTOUT0' signalisiert nur einen Fehler,
 *                wenn 'errnum' Null ist. Wozu dann Åberhaupt eine Var dafÅr?
 *  04.12.90 TT | stringIntoCFormat: SUB D1,D0 nun als Long-Operation!
 *  25.02.91 TT | unloadFonts aus VDIControls Åbertragen
 *  20.05.91 MS | unloadFonts korrigiert
 *  21.08.91 TT | 'signalGemError' macht RTS statt Runtime-Error, wenn
 *                'ptrToErrHdler' = NIL ist.
 *  22.05.93 TT | 'signalGemError': LINK A5,#0
 *)


FROM SYSTEM     IMPORT ASSEMBLER, BYTE, WORD, ADR;

FROM MOSGlobals IMPORT OutOfStack, IllegalPointer, StringOverflow;

FROM GrafBase   IMPORT Point, Rectangle, PtrMouseFormDef;

(*$I GEMOPS.ICL *)
(*$I GEMCNF.ICL *)


FORWARD testErrorCheck;
FORWARD gemErrorOccured;


                (*  Misc. subroutines  *)
                (*  =================  *)

PROCEDURE getCalcedFrame(frame:Rectangle);

  BEGIN
    ASSEMBLER
        MOVE.L      -(A3),D0
        MOVE.L      -(A3),D1
        ADD.L       D1,D0
        SUBQ.W      #1,D0
        SUB.L       #$10000,D0
        MOVE.L      D0,-(A1)        ; x+w-1 -> ptsin(x+2), y+h-1 -> ptsin(x+3)
        MOVE.L      D1,-(A1)        ; x -> ptsin(x) , y -> ptsin(x+1)
    END;
  END getCalcedFrame;

PROCEDURE stringIntoINTIN(REF str:ARRAY OF CHAR):CARDINAL;

  BEGIN
    ASSEMBLER
        MOVE.W  #intinMax,D1
        SUB.W   D4,D1                   ; Anzahl benutzbarer Elem. -> D1
        MOVE.L  pubs,A0
        LEA     pubArrays.vINTIN(A0),A0  ; ADR(INTIN[0]) -> A0
        LSL.W   #1,D4                   ; 1 Element verbraucht 2 Byte
        ADDA.W  D4,A0                   ; Offset hinzuzÑhlen
        MOVE.W  -(A3),D0
        MOVE.L  -(A3),A1                ; ADR(str) -> A1
        CMP.W   D1,D0                   ; Wenn String zu lang, benutze nur
        BLS     cont                    ; den Teil, der noch ins Array paût
        MOVE.W  D1,D0
cont
        MOVE.W  D0,D2                   ; Store num. of max. chars to copy
        CLR.W   D1
loop                                    ; Kopiere bis 0C oder max. Arrayindex
        MOVE.B  (A1)+,D1
        MOVE.W  D1,(A0)+
        DBEQ    D0,loop
        SUB.W   D0,D2                   ; Anzahl kopierter Zeichen ermitteln
        MOVE.W  D2,(A3)+                ; und zurÅckgeben
    END;
  END stringIntoINTIN;

(*
PROCEDURE enchantSuperMode;

  BEGIN
    ASSEMBLER
        JMP     EnterSupervisorMode
    END;
  END enchantSuperMode;
 *)

PROCEDURE stringIntoCFormat (REF str: ARRAY OF CHAR);

  BEGIN
    ASSEMBLER
        MOVE.L  (A7)+,A2        ; Rette RÅckkehraddr.
        MOVEQ   #0,D1
        MOVE.W  -(A3),D1        ; HIGH(str) -> D1
        MOVE.L  A7,D0           ; Berechne neuen Top of Stack
        SUB.L   D1,D0
        SUBQ.L  #2,D0
        BCLR    #0,D0           ; nur gerade Stackaddr. erlaubt

        CMP.L   A3,D0
        BCC     cont2           ; springe, falls kein Stack Overflow
        TRAP    #noErrorTrap
        DC.W    OutOfStack
cont2
        MOVE.L  D0,A0           ; rette Zeiger auf Stringanfang
        EXG     D0,A7
        MOVE.L  D0,-(A7)        ; orginal Stackaddr. merken
        MOVE.L  -(A3),A1        ; ADR(str) -> A1
        MOVE.L  A0,D2           ; rette Zeiger auf Stringanfang
loop
        MOVE.B  (A1)+,(A0)+
        DBEQ    D1,loop         ; kopiere bis zum Stringende
        CLR.B   (A0)+           ; und hÑnge #0 als Endezeichen an
        MOVE.L  A2,-(A7)        ; RÅckkehraddr. fÅr RTS auf den Stack
    END;
  END stringIntoCFormat;


PROCEDURE setDevice(handle:p_device;VAR success:BOOLEAN);

  VAR     current                 :p_device;

  BEGIN
    ASSEMBLER
        JSR     testErrorCheck;
        MOVE.L  -(A3),A2
        MOVE.L  -(A3),D0
        AND.W   #-2,D0                  ; Addr. muû gerade sein
        MOVE.L  D0,A0
        CMPA.L  #NIL,A0
        BNE     cont
        JSR     gemErrorOccured
        MOVE.W  #FALSE,(A2)
        BRA     ende
cont
        MOVE.W  device.magic(A0),D0
        CMP.W   #deviceMagic,D0
        BEQ     cont2
        TRAP    #noErrorTrap
        DC.W    IllegalPointer
        MOVE.W  #FALSE,(A2)
        BRA     ende
cont2
        MOVE.L  our_cb,A1
        MOVE.L  A0,cb.CURDEVICE(A1)
        MOVE.W  #TRUE,(A2)
ende
    END;
  END setDevice;

                        (*  global error handling  *)
                        (*  =====================  *)
 
PROCEDURE signalGemError;
(*
 * Hier wird "error" auf TRUE gesetzt, so daû der User den Fehler
 * dann abfragen kann.
 * Falls aber mittels des Util-Moduls "GemErrLocator" der unmittelbare
 * Error-Handler installiert ist, wird sofort darÅber der Fehler
 * angezeigt, so daû ein Scanning auf den Verursacher mîglich ist.
 *)
  BEGIN
    ASSEMBLER
        MOVE.W  #TRUE,error
        
        MOVE.L  ptrToErrHdler,D0
        BEQ     ende
        
        LINK    A5,#0
        MOVE.L  D0,A0
        MOVE.L  (A0),A0
        JSR     (A0)
        UNLK    A5
ende
    END;
  END signalGemError;

PROCEDURE testINTOUT0;
(*
 * Aufzurufen nach einem AES-Call. INTOUT[0] wird geprÅft. Wenn Fehler
 * angezeigt, wird 'error'-Flag gesetzt.
 *)
  BEGIN
    ASSEMBLER
        MOVE.L  pubs,A0
        CLR.W   D0
        MOVE.W  pubArrays.aINTOUT(A0),errNum
        BNE     noError
        JMP     signalGemError
      noError
    END;
  END testINTOUT0;

PROCEDURE testErrorCheck;
(*
 * Aufzurufen zu Beginn einer GEM-Routine. Falls 'error'-Flag gesetzt,
 * wird GEM-Fehler gemeldet.
 *)
  BEGIN
    ASSEMBLER
        TST.W   error
        BEQ     ende            ; no error => branch
        
        CLR.W   error           ; verhindert Rekursion
        
        MOVE.L  errorProcPtr,D0
        BEQ     noProcInstalled
        
        MOVE.L  D0,A0
        MOVE.L  (A0),A0
        JSR     (A0)
        BRA     ende
        
noProcInstalled
        TRAP    #noErrorTrap
        DC.W    IllegalPointer - $4000
ende
    END;
  END testErrorCheck;

PROCEDURE gemErrorOccured;
(*
 * Aufzurufen, wenn Fehler auftrat. 'error'-Flag wird gesetzt.
 *)
  BEGIN
    ASSEMBLER
        CLR.W   errNum
        JMP     signalGemError
    END;
  END gemErrorOccured;


                                (*  A E S  *)
                                (*  =====  *)

PROCEDURE aes_call (pb: p_cb);

  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        LEA     cb.AESPB(A0),A0
        MOVE.L  A0,D1
        MOVE.W  #AESCode,D0
        TRAP    #GEMTrap
    END
  END aes_call;

PROCEDURE ctrl_cnts;

  BEGIN
    ASSEMBLER
    ;                             Dummies
        DC.B    0, 0, 0            ; func 000
        DC.B    0, 0, 0            ; func 001
        DC.B    0, 0, 0            ; func 002
        DC.B    0, 0, 0            ; func 003
        DC.B    0, 0, 0            ; func 004
        DC.B    0, 0, 0            ; func 005
        DC.B    0, 0, 0            ; func 006
        DC.B    0, 0, 0            ; func 007
        DC.B    0, 0, 0            ; func 008
        DC.B    0, 0, 0            ; func 009
    ;                             Application Manager
        DC.B    0, 1, 0            ; func 010  init
        DC.B    2, 1, 1            ; func 011  read
        DC.B    2, 1, 1            ; func 012  write
        DC.B    0, 1, 1            ; func 013  find
        DC.B    2, 1, 1            ; func 014  tplay
        DC.B    1, 1, 1            ; func 015  trec
        DC.B    0, 0, 0            ; func 016
        DC.B    0, 0, 0            ; func 017
        DC.B    0, 0, 0            ; func 008
        DC.B    0, 1, 0            ; func 019  exit
    ;                             Event Manager
        DC.B    0, 1, 0            ; func 020  evnt keybd
        DC.B    3, 5, 0            ; func 021  evnt but
        DC.B    5, 5, 0            ; func 022  e mouse
        DC.B    0, 1, 1            ; func 023  e msg
        DC.B    2, 1, 0            ; func 024  e timer
        DC.B    16, 7, 1           ; func 025  e multi
        DC.B    2, 1, 0            ; func 026
        DC.B    0, 0, 0            ; func 027
        DC.B    0, 0, 0            ; func 028
        DC.B    0, 0, 0            ; func 009
    ;                             Menu Manager
        DC.B    1, 1, 1            ; func 030  bar
        DC.B    2, 1, 1            ; func 031  icheck
        DC.B    2, 1, 1            ; func 032  ienable
        DC.B    2, 1, 1            ; func 033  tnormal
        DC.B    1, 1, 2            ; func 034  text
        DC.B    1, 1, 1            ; func 005  register
        DC.B    0, 0, 0            ; func 006
        DC.B    0, 0, 0            ; func 007
        DC.B    0, 0, 0            ; func 008
        DC.B    0, 0, 0            ; func 009
    ;                             Object Manager
        DC.B    2, 1, 1            ; func 040  add
        DC.B    1, 1, 1            ; func 041  del
        DC.B    6, 1, 1            ; func 042  draw
        DC.B    4, 1, 1            ; func 043  find
        DC.B    1, 3, 1            ; func 044  offset
        DC.B    2, 1, 1            ; func 045  order
        DC.B    4, 2, 1            ; func 046  edit
        DC.B    8, 1, 1            ; func 047  change
        DC.B    0, 0, 0            ; func 048
        DC.B    0, 0, 0            ; func 049
    ;                             Form Manager
        DC.B    1, 1, 1            ; func 050  do
        DC.B    9, 1, 1            ; func 051  dial
        DC.B    1, 1, 1            ; func 002  alert
        DC.B    1, 1, 0            ; func 003  error
        DC.B    0, 5, 1            ; func 004  center
        DC.B    3, 3, 1            ; func 005  keyboard
        DC.B    2, 2, 1            ; func 006  button
        DC.B    0, 0, 0            ; func 007
        DC.B    0, 0, 0            ; func 008
        DC.B    0, 0, 0            ; func 009
    ;                             Dialog Manager
        DC.B    0, 0, 0            ; func 060
        DC.B    0, 0, 0            ; func 061
        DC.B    0, 0, 0            ; func 062
        DC.B    0, 0, 0            ; func 003
        DC.B    0, 0, 0            ; func 004
        DC.B    0, 0, 0            ; func 005
        DC.B    0, 0, 0            ; func 006
        DC.B    0, 0, 0            ; func 007
        DC.B    0, 0, 0            ; func 008
        DC.B    0, 0, 0            ; func 009
    ;                            Graphics Manager
        DC.B    4, 3, 0            ; func 070  rubber
        DC.B    8, 3, 0            ; func 071  drag
        DC.B    6, 1, 0            ; func 072  move
        DC.B    8, 1, 0            ; func 073  grow
        DC.B    8, 1, 0            ; func 074  shrink
        DC.B    4, 1, 1            ; func 075  watch
        DC.B    3, 1, 1            ; func 076  slide
        DC.B    0, 5, 0            ; func 077  handle
        DC.B    1, 1, 1            ; func 078  mouse
        DC.B    0, 5, 0            ; func 009  mkstate
    ;                            Scrap Manager
        DC.B    0, 1, 1            ; func 080  read
        DC.B    0, 1, 1            ; func 081  write
        DC.B    0, 0, 0            ; func 082
        DC.B    0, 0, 0            ; func 083
        DC.B    0, 0, 0            ; func 084
        DC.B    0, 0, 0            ; func 005
        DC.B    0, 0, 0            ; func 006
        DC.B    0, 0, 0            ; func 007
        DC.B    0, 0, 0            ; func 008
        DC.B    0, 0, 0            ; func 009
    ;                            fseler Manager
        DC.B    0, 2, 2            ; func 090  input
        DC.B    0, 2, 3            ; func 091           (*  Ab TOS 1.4  *)
        DC.B    0, 0, 0            ; func 092
        DC.B    0, 0, 0            ; func 003
        DC.B    0, 0, 0            ; func 004
        DC.B    0, 0, 0            ; func 005
        DC.B    0, 0, 0            ; func 006
        DC.B    0, 0, 0            ; func 007
        DC.B    0, 0, 0            ; func 008
        DC.B    0, 0, 0            ; func 009
    ;                            Window Manager
        DC.B    5, 1, 0            ; func 100
        DC.B    5, 1, 0            ; func 101
        DC.B    1, 1, 0            ; func 102
        DC.B    1, 1, 0            ; func 103
        DC.B    2, 5, 0            ; func 104
        DC.B    6, 1, 0            ; func 105
        DC.B    2, 1, 0            ; func 106
        DC.B    1, 1, 0            ; func 107
        DC.B    6, 5, 0            ; func 108
        DC.B    0, 0, 0            ; func 109           (*  Ab TOS 1.4  *)
    ;                            Resource Manger
        DC.B    0, 1, 1            ; func 110  load
        DC.B    0, 1, 0            ; func 111  free
        DC.B    2, 1, 0            ; func 112  gaddr
        DC.B    2, 1, 1            ; func 113  saddr
        DC.B    1, 1, 1            ; func 114  obfix
        DC.B    0, 0, 0            ; func 115
        DC.B    0, 0, 0            ; func 006
        DC.B    0, 0, 0            ; func 007
        DC.B    0, 0, 0            ; func 008
        DC.B    0, 0, 0            ; func 009
    ;                            Shell Manager
        DC.B    0, 1, 2            ; func 120  read
        DC.B    3, 1, 2            ; func 121  write
        DC.B    1, 1, 1            ; func 122  get
        DC.B    1, 1, 1            ; func 123  put
        DC.B    0, 1, 1            ; func 124  find
        DC.B    0, 1, 2            ; func 125  envrn
    END
  END ctrl_cnts;

PROCEDURE aes_if (Opcode: CARDINAL);

  BEGIN
    ASSEMBLER
        JSR         testErrorCheck
        MOVE.L      pubs,A0
        CLR.W       pubArrays.aINTOUT(A0)
        MOVE.L      our_cb,A0
        LEA         cb.A_CONTRL(A0),A0
        MOVE.W      -(A3),D0
        MOVE.W      D0,(A0)+
        LEA         ctrl_cnts,A1
        ADDA.W      D0,A1
        ADD.W       D0,D0
        ADDA.W      D0,A1
        CLR.W       D0
        MOVE.B      (A1)+,D0
        MOVE.W      D0,(A0)+
        MOVE.B      (A1)+,D0
        MOVE.W      D0,(A0)+
        MOVE.B      (A1)+,D0
        MOVE.W      D0,(A0)+
        MOVE.L      our_cb,(A3)+
        JSR         aes_call
    END;
  END aes_if;


                                (*  V D I  *)
                                (*  =====  *)

PROCEDURE vdi_call (para: p_cb);

  BEGIN
    ASSEMBLER
      MOVE.L  -(A3),A0
      LEA     cb.VDIPB(A0),A0
      MOVE.L  A0,D1
      MOVE.L  #VDICode,D0
      TRAP    #GEMTrap
    END
  END vdi_call;

PROCEDURE ctrl_cnts2;
                       (* Only sptsin, sintin; no sintout, sptsout *)
  BEGIN
    ASSEMBLER
    ;       PTSIN, INTIN
        DC.B    0, 0         ; func 000
        DC.B    0, 0         ; func 001
        DC.B    0, 0         ; func 002
        DC.B    0, 0         ; func 003 clear workstation
        DC.B    0, 0         ; func 004 update works.
        DC.B    0, 0         ; func 005 escape funktions
        DC.B    0, 0         ; func 006 polyline(ruft vdi_call direkt auf)
        DC.B    0, 0         ; func 007 polymarker(ruft vdi_call direkt auf)
        DC.B    0, 0         ; func 008 graftext(ruft vdi_call direkt auf)
        DC.B    0, 0         ; func 009 filled polygon(ruft vdi_call direkt)
    ;
        DC.B    0, 0         ; func 010  cell array(ruft vdi_call direkt auf)
        DC.B    0, 0         ; func 011   (* Graf.Grundfkten *)
        DC.B    1, 0         ; func 012  text height abs.
        DC.B    0, 1         ; func 013  baseline
        DC.B    0, 4         ; func 014  color rep
        DC.B    0, 1         ; func 015  line type
        DC.B    1, 0         ; func 016  line width
        DC.B    0, 1         ; func 017  line color
        DC.B    0, 1         ; func 008  marker type
        DC.B    1, 0         ; func 019  marker height
    ;
        DC.B    0, 1         ; func 020  marker color
        DC.B    0, 1         ; func 021  text face
        DC.B    0, 1         ; func 022  text color
        DC.B    0, 1         ; func 023  fill interior
        DC.B    0, 1         ; func 024  fill index
        DC.B    0, 1         ; func 025  fill color
        DC.B    0, 2         ; func 026  inq. color
        DC.B    2, 0         ; func 027  inq. cell array
        DC.B    1, 0         ; func 028  inp loc
        DC.B    0, 1         ; func 009  inp val
    ;
        DC.B    0, 0         ; func 030  inp choice ( vdi_call direkt )
        DC.B    1, 2         ; func 031  inp str
        DC.B    0, 1         ; func 032  writing mode
        DC.B    0, 2         ; func 033  set_input_mode
        DC.B    2, 0         ; func 034
        DC.B    0, 0         ; func 005  inq. line
        DC.B    0, 0         ; func 006  inq. mark
        DC.B    0, 0         ; func 007  inq. fill
        DC.B    0, 0         ; func 008  inq. text
        DC.B    0, 2         ; func 009  text alig
    ;
        DC.B    1, 0         ; func 040
        DC.B    1, 0         ; func 041
        DC.B    1, 0         ; func 042
        DC.B    1, 0         ; func 043
        DC.B    1, 0         ; func 044
        DC.B    1, 0         ; func 045
        DC.B    1, 0         ; func 046
        DC.B    1, 0         ; func 047
        DC.B    0, 0         ; func 048
        DC.B    0, 0         ; func 049
    ;
        DC.B    1, 0         ; func 050
        DC.B    1, 0         ; func 051
        DC.B    1, 0         ; func 002
        DC.B    0, 0         ; func 003
        DC.B    1, 0         ; func 004
        DC.B    1, 0         ; func 005
        DC.B    1, 0         ; func 006
        DC.B    0, 0         ; func 007
        DC.B    0, 0         ; func 008
        DC.B    0, 0         ; func 009
    ;
        DC.B    0, 0         ; func 060
        DC.B    0, 0         ; func 061
        DC.B    0, 0         ; func 062
        DC.B    0, 0         ; func 003
        DC.B    1, 0         ; func 004
        DC.B    1, 0         ; func 005
        DC.B    1, 0         ; func 006
        DC.B    0, 0         ; func 007
        DC.B    0, 0         ; func 008
        DC.B    0, 0         ; func 009
    ;
        DC.B    0, 0         ; func 070
        DC.B    0, 0         ; func 071
        DC.B    0, 0         ; func 072
        DC.B    0, 0         ; func 073
        DC.B    0, 0         ; func 074
        DC.B    1, 0         ; func 075
        DC.B    1, 0         ; func 076
        DC.B    0, 0         ; func 077
        DC.B    1, 0         ; func 078
        DC.B    0, 0         ; func 009
    ;
        DC.B    1, 0         ; func 080
        DC.B    1, 0         ; func 081
        DC.B    0, 0         ; func 082
        DC.B    0, 0         ; func 083
        DC.B    0, 0         ; func 084
        DC.B    1, 0         ; func 005
        DC.B    1, 0         ; func 006
        DC.B    0, 0         ; func 007
        DC.B    0, 0         ; func 008
        DC.B    0, 0         ; func 009
    ;
        DC.B    2, 0         ; func 090
        DC.B    0, 0         ; func 091
        DC.B    0, 0         ; func 092
        DC.B    0, 0         ; func 003
        DC.B    0, 0         ; func 004
        DC.B    1, 0         ; func 005
        DC.B    1, 0         ; func 006
        DC.B    0, 0         ; func 007
        DC.B    0, 0         ; func 008
        DC.B    0, 0         ; func 009
    ;
        DC.B    0, 11        ; func 100  open work
        DC.B    0, 0         ; func 101  close work
        DC.B    0, 1         ; func 102  ext. inquire
        DC.B    1, 1         ; func 103  contour fill
        DC.B    0, 1         ; func 104  fill perim.
        DC.B    1, 0         ; func 105  get pixel
        DC.B    0, 1         ; func 106  text effect
        DC.B    0, 1         ; func 107  text height pts
        DC.B    0, 2         ; func 108  line end
        DC.B    4, 1         ; func 009  copy opaque
    ;
        DC.B    0, 0         ; func 110  transform form
        DC.B    0, 37        ; func 111  mouse form
        DC.B    0, 0         ; func 112  user fill( ruft vdi_call direkt )
        DC.B    0, 1         ; func 113  user line
        DC.B    2, 0         ; func 114  fill rect
        DC.B    0, 1         ; func 115  inq. input
        DC.B    0, 0         ; func 006  text ext.( ruft vdi_call direkt )
        DC.B    0, 1         ; func 007  inq. cell
        DC.B    0, 0         ; func 008  time inter
        DC.B    0, 1         ; func 009  load fonts
    ;
        DC.B    0, 1         ; func 120  unload fonts
        DC.B    4, 3         ; func 121  copy transp.
        DC.B    0, 1         ; func 122  show cursor
        DC.B    0, 0         ; func 123  hide cur.
        DC.B    0, 0         ; func 124  mouse buts
        DC.B    0, 0         ; func 125  but change
        DC.B    0, 0         ; func 126  mouse move
        DC.B    0, 0         ; func 127  mouse change
        DC.B    0, 0         ; func 128  key state
        DC.B    2, 1         ; func 129  clipping
     ;
        DC.B    0, 1         ; func 130  face name
        DC.B    0, 0         ; func 131  face info
    END
  END ctrl_cnts2;
  
  (* Control Array Parameter fÅr die Generalized Drawing Primitives (GDP) *)
  
PROCEDURE ctrl_cnts3;

  BEGIN
    ASSEMBLER
        DC.B        0, 0      ; *DUMMY*
        DC.B        2, 0      ; #1  Bar
        DC.B        4, 2      ; #2  Arc
        DC.B        4, 2      ; #3  Pie
        DC.B        3, 0      ; #4  Circle
        DC.B        2, 0      ; #5  Ellipse
        DC.B        2, 2      ; #6  ElliptArc
        DC.B        2, 2      ; #7  ElliptPie
        DC.B        2, 0      ; #8  RoundRect
        DC.B        2, 0      ; #9  FillRoundRect
        DC.B        0, 0      ; #10 JustText ( ruft vdi_call direkt auf )
    END;
  END ctrl_cnts3;

    (* Control Array Parameter fÅr die VDI-Escape-Funktionen *)
  
PROCEDURE ctrl_cnts4;

  BEGIN
    ASSEMBLER
        DC.B    0, 0    ; *DUMMY*
        DC.B    0, 0    ; #1  GetCharCells
        DC.B    0, 0    ; #2  ExitCur
        DC.B    0, 0    ; #3  EnterCur
        DC.B    0, 0    ; #4  CurUp
        DC.B    0, 0    ; #5  CurDown
        DC.B    0, 0    ; #6  CurRight
        DC.B    0, 0    ; #7  CurLeft
        DC.B    0, 0    ; #8  CurHome
        DC.B    0, 0    ; #9  EEOS
        DC.B    0, 0    ; #10 EEOL
        DC.B    0, 2    ; #11 SetCurAdr
        DC.B    0, 0    ; #12 CurText  (* ruft vdi_call direkt *)
        DC.B    0, 0    ; #13 RVOn
        DC.B    0, 0    ; #14 RVOff
        DC.B    0, 0    ; #15 GetCurAdr
        DC.B    0, 0    ; #16 TabStatus
        DC.B    0, 0    ; #17 Hardcopy
        DC.B    1, 0    ; #18 DspCur
        DC.B    0, 0    ; #19 RmCur
        DC.B    0, 0    ; #20 FormAdv
        DC.B    2, 0    ; #21 OutWind
        DC.B    0, 0    ; #22 ClrDispList
        DC.B    0, 0    ; #23 BitImg (direkt)
        
      ; DC.B    0, 1    ; #60 SelPalette (direkt)
        
    END;
  END ctrl_cnts4;

CONST   start_cnts5   = 91;     (*  Erste Subcmd-Nummer in 'ctrl_cnts5'  *)

PROCEDURE ctrl_cnts5;

  BEGIN
    ASSEMBLER
        DC.B    0, 0    ; #91 vqp_films
        DC.B    0, 0    ; #92 vqp_state
        DC.B    0, 21   ; #93 vsp_state
        DC.B    0, 0    ; #94 vsp_save
        DC.B    0, 0    ; #95 vsp_message
        DC.B    0, 0    ; #96 vsp_error
        DC.B    0, 0    ; #97
        DC.B    2, 0    ; #98 v_meta_extents
        DC.B    0, 0    ; #99 v_write_meta (direkt)
        DC.B    0, 0    ; #100vm_filename (direkt)
        DC.B    0, 1    ; #101v_offset
        DC.B    0, 2    ; #102v_fontinit
    END;
  END ctrl_cnts5;

PROCEDURE vdi_if (handle:p_device;Opcode,Subcmd:CARDINAL);

  BEGIN
    ASSEMBLER
        JSR         testErrorCheck;
        MOVE.L      our_cb,A0
        MOVE.L      -(A3),D0
        MOVE.W      D0,cb.V_CONTRL.subcmd(A0)       ; subcmd in ctrl-array
        SWAP        D0
        MOVE.W      D0,cb.V_CONTRL.opcode(A0)       ; Opcode in ctrl-array
        CMP.W       #V_OPNWK,D0
        BEQ         cont                            ; springe, falls OpenWorksta.
        CMP.W       #OPEN_V_WORK,D0
        BEQ         cont                            ; oder OpenVirt.Work.
        
        MOVE.L      D0,-(A7)
        SUBQ.L      #2,A7                           ; reserv. 1 Wort auf dem Stack
        MOVE.L      A7,(A3)+                        ; und Åbergib es als VAR-Parm.
        JSR         setDevice
        MOVE.W      (A7)+,D1
        MOVE.L      (A7)+,D0
        TST.W       D1
        BEQ         ende                            ; falsches 'handle' => RETURN
        
        MOVE.L      our_cb,A0
        MOVE.L      cb.CURDEVICE(A0),A1             ; VDI device handle setzen
        MOVE.W      device.handle(A1),cb.V_CONTRL.handle(A0)
        CMP.W       #GRAF_STANDARD,D0               ; Sonderbehandlung fÅr GRAF_S.
        BEQ         gsCmd
        CMP.W       #ESCAPE,D0                      ; Sonderbehandlung fÅr ESCAPE
        BEQ         escCmd
        LEA         ctrl_cnts2,A1   ; kein graf_standard Befehl
        BRA         cont2
cont
        SUBQ.L      #4,A3           ; !TT 22.01.88
        LEA         ctrl_cnts2,A1   ; kein graf_standard Befehl
        BRA         cont2
gsCmd                               ; GENERALIZED DRAWING PRIMITIVE Befehl
        SWAP        D0              ; Tabellenzeiger ist 'SubCmd'
        LEA         ctrl_cnts3,A1   ; Tabelle ist 'ctrl_cnts3'
        BRA         cont2
escCmd                              ; ESCAPE Befehl
        SWAP        D0
        CMP.W       #start_cnts5,D0
        BCC         escCnts5
        LEA         ctrl_cnts4,A1
        BRA         cont2
escCnts5                            ; erweiterter ESCAPE Befehl
        SUB.W       #start_cnts5,D0
        LEA         ctrl_cnts5,A1
cont2
        ADD.W       D0,D0           ; Tabellenbreite 2 Byte
        ADDA.W      D0,A1           ; ctrl_cnts?+???cmd*2 -> A1
        CLR.W       D0              ; Anzahl Eingabeparam. -> ctrl-array
        MOVE.B      (A1)+,D0
        MOVE.W      D0,cb.V_CONTRL.sptsin(A0)
        MOVE.B      (A1),D0
        MOVE.W      D0,cb.V_CONTRL.sintin(A0)
        MOVE.L      A0,(A3)+
        JSR         vdi_call
ende
    END;
  END vdi_if;


PROCEDURE setINT0attribut(handle:p_device);

  BEGIN
    ASSEMBLER
        MOVE.L      pubs,A0
        MOVE.W      D0,pubArrays.vINTIN(A0)
        MOVE.W      D0,-(A7)
        MOVE.W      D1,(A3)+
        CLR.W       (A3)+
        JSR         vdi_if
        MOVE.W      (A7)+,D0
        MOVE.L      pubs,A0
        CMP.W       pubArrays.vINTOUT(A0),D0
        BEQ         cont            ; error:=(INTOUT[0]#Attributwert)
        CLR.W       errNum
        JMP         signalGemError
cont
    END;
  END setINT0attribut;


PROCEDURE selectFile0 (VAR path, name: ARRAY OF CHAR;
                       VAR ok        : BOOLEAN;
                           opcode    : CARDINAL);

  BEGIN
    ASSEMBLER
        LINK    A5, #0
        MOVEM.L D3/A4-A5,-(A7)
        MOVE.W  -(A3), D3
        
        MOVE.L  -(A3),-(A7)
        MOVE.L  A3,A1
        MOVE.L  -(A1),-(A7)
        MOVE.L  -(A1),-(A7)
        MOVE.L  -(A1),-(A7)
        CMPI.W  #11,-2   (A3)
        BCC     ok1
        TRAP    #noErrorTrap
        DC.W    StringOverflow
        MOVE.W  #11,-2   (A3)
ok1
        CMPI.W  #31,-8(A3)
        BCC     ok2
        TRAP    #noErrorTrap
        DC.W    StringOverflow
        MOVE.W  #31,-8(A3)
ok2
        JSR     stringIntoCFormat   ; ADR(name) -> D2
        MOVE.L  pubs,A0
        MOVE.L  D2,pubArrays.ADDRIN+4(A0)
        MOVE.L  D2,A4               ; ADR(path) -> A4
        JSR     stringIntoCFormat   ; ADR(path) -> D2
        MOVE.L  pubs,A0
        MOVE.L  D2,pubArrays.ADDRIN(A0)
        MOVE.L  D2,A5               ; ADR(path) -> A5
        MOVE.W  D3,(A3)+
        JSR     aes_if
        
        MOVE.L  (A7),A0
        MOVE.L  (A0),A0
        MOVE.L  (A0)+,A1
        MOVE.W  (A0)+,D0
loop1
        MOVE.B  (A5)+,(A1)+
        DBF     D0,loop1
        MOVE.L  (A0)+,A1
        MOVE.W  (A0)+,D0
loop2
        MOVE.B  (A4)+,(A1)+
        DBF     D0,loop2
        MOVE.L  (A7),A7             ; Strings wieder vom Stack lîschen
        MOVE.L  (A7),A7
        ADDA.W  #12,A7
        
        MOVE.L  pubs,A0
        MOVE.L  (A7)+,A1
        MOVE.W  pubArrays.aINTOUT+2(A0),(A1)
        JSR     testINTOUT0
        
        MOVEM.L (A7)+,D3/A4-A5
        UNLK    A5
    END;
  END selectFile0;

PROCEDURE selectFile (VAR path, name: ARRAY OF CHAR; VAR ok: BOOLEAN);

  BEGIN
    ASSEMBLER
        MOVE.W  #FSEL_INPUT,(A3)+
        JMP     selectFile0
    END;
  END selectFile;

PROCEDURE selectFileExtended (REF label     : ARRAY OF CHAR;
                              VAR path, name: ARRAY OF CHAR;
                              VAR ok        : BOOLEAN);

  BEGIN
    ASSEMBLER
        MOVE.L  -22(A3), (A3)+
        MOVE.W  -22(A3), (A3)+          ;  don't forget the 4 byte of the prev.
        JSR     stringIntoCFormat
        MOVE.L  pubs, A0
        MOVE.L  D2, pubArrays.ADDRIN+8(A0)     ; 'label' an AES
        
        MOVE.W  #FSEL_EX_INPUT,(A3)+
        JSR     selectFile0
        
        MOVE.L  (A7), A7
        SUBQ.L  #6, A3
    END;
  END selectFileExtended;

PROCEDURE shellRead (VAR cmd, tail: ARRAY OF CHAR);

  BEGIN
    ASSEMBLER
        LINK    A5,#0
        SUBA.W  #$200,A7
        MOVE.L  pubs,A0
        MOVE.L  A7,pubArrays.ADDRIN+4(A0)
        LEA     $100(A7),A1
        MOVE.L  A1,pubArrays.ADDRIN(A0)
        MOVE.W  #SHEL_READ,(A3)+
        CMPA.L  A3,A7
        BLS     ovrflow
        JSR     aes_if
        JSR     testINTOUT0
        LEA     -12(A3),A2

        ; TAIL kopieren
        MOVE.L  A7,A0
        MOVE    -(A3),D1
        MOVE.L  -(A3),A1
        MOVE.B  (A0)+,D2        ; LÑnge von TAIL
      lup2:
        SUBQ.B  #1,D2
        BCS     endtail
        MOVE.B  (A0)+,(A1)+
        DBRA    D1,lup2
        BSR     strovr
        BRA     tocmd
      endtail:
        CLR.B   (A1)+

      tocmd:
        ; CMD kopieren
        LEA     $100(A7),A0
        MOVE    -(A3),D1
        MOVE.L  -(A3),A1
      lup:
        MOVE.B  (A0)+,(A1)+
        DBEQ    D1,lup
        BEQ     bye
        BSR     strovr
      bye:

        MOVE.L  A2,A3
        UNLK    A5
        RTS
      strovr
        TRAP    #noErrorTrap
        DC.W    StringOverflow
        RTS
      ovrflow:
        ADDA.W  #$200,A7
        SUBA.W  #14,A3
        TRAP    #noErrorTrap
        DC.W    OutOfStack
        UNLK    A5
    END;
  END shellRead;



                (*  Von mehreren GEM Moduln benutzte GEM-Calls  *)
                (*  ==========================================  *)
                
PROCEDURE grafMouse(form:WORD(* ~ AESGraphics.MouseForm*);
                    mFormDefPtr:PtrMouseFormDef);
                    
                    
(* !!!!!!!!! Muû 'AESGraphics.MouseForm' entsprechen !!!!!!!!!! *)

TYPE    MouseForm       = (arrow, textCursor, bee, pointHand, flatHand,
                           thinCross, thickCross, outlineCross, userCursor,
                           mouseOff, mouseOn);
       
  BEGIN
    ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.L  our_cb, A1
        MOVE.L  -(A3),pubArrays.ADDRIN(A0)
        MOVE.W  -(A3),D0
        CMP.W   #mouseOff,D0
        BNE     cont2
        
        ADDQ.W  #1,cb.SUPERVISION.noGrafMouse(A1)
        BRA     noSuper
cont2
        CMP.W   #mouseOn,D0
        BNE     noSuper
        SUBQ.W  #1,cb.SUPERVISION.noGrafMouse(A1)
        BPL     noSuper
        CLR.W   cb.SUPERVISION.noGrafMouse(A1)
        (*$? doSupervision:
        BRA     ende
        *)
noSuper
        CMP.W   #userCursor,D0
        BLT     cont
        ADD.W   #$FF,D0
        SUB.W   #userCursor,D0
cont
        MOVE.L  pubs, A0
        MOVE.W  D0,pubArrays.aINTIN(A0)
        MOVE.W  #GRAF_MOUSE,(A3)+
        JSR     aes_if
        JSR     testINTOUT0
ende
    END;
  END grafMouse;

PROCEDURE showCursor (handle:p_device; force:BOOLEAN);

  BEGIN
    ASSEMBLER
        MOVE.L  -6(A3),(A3)+
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BNE     devOk
        SUBQ.L  #6,A3
        BRA     ende

devOk
        MOVE.L  our_cb,A0
        MOVE.W  -(A3),D0
        MOVE.L  cb.CURDEVICE(A0),A1
        TST.W   D0
        BNE     forceShow
        SUBQ.W  #1,device.noHdCurs(A1)
        BPL     noSuper
        CLR.W   device.noHdCurs(A1)
        BRA     ende
forceShow
        CLR.W   device.noHdCurs(A1)
noSuper

        EORI.W  #1,D0
        MOVE.L  pubs, A0
        MOVE.W  D0,pubArrays.vINTIN(A0)
        MOVE.W  #SHOW_CURSOR,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
ende
    END;
  END showCursor;

PROCEDURE hideCursor (device:p_device);

  BEGIN
    ASSEMBLER
        MOVE.L  -4(A3),(A3)+
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BNE     devOk
        SUBQ.L  #4,A3
        BRA     ende

devOk
        MOVE.L  our_cb,A0
        MOVE.L  cb.CURDEVICE(A0),A1
        ADDQ.W  #1,device.noHdCurs(A1)

        MOVE.W  #HIDE_CURSOR,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
ende
    END;
  END hideCursor;


PROCEDURE unloadFonts(handle:p_device;select:WORD);

BEGIN
  ASSEMBLER
        MOVE.L  pubs,A0
        MOVE.W  -(A3),pubArrays.vINTIN(A0)
        MOVE.L  -4(A3), (A3)+           ; !MS 'handle' retten

        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     setDevice
        TST.W   (A7)+
        BNE     ok
        SUBQ.L  #4,A3                     ; !MS 'handle' wegwerfen
        BRA     ende
ok      MOVE.W  #UNLOAD_FONTS,(A3)+       ; !MS hier steht 'handle' auf A3-Stk.
        CLR.W   (A3)+
        JSR     vdi_if

        MOVE.L  our_cb,A0
        MOVE.L  cb.CURDEVICE(A0),A1
        CLR     device.fontsLoaded(A1)
ende
  END;
END unloadFonts;


PROCEDURE updateWindow (update:WORD);

  BEGIN
    ASSEMBLER
        MOVE.L  our_cb,A0
        MOVE.W  -(A3),D0
        
        BTST    #0,D0
        BNE     addOne
        MOVEQ   #-1,D1
        BRA     cont
addOne
        MOVEQ   #1,D1
cont
        BTST    #1,D0
        BNE     mCtrl
        ADD.W   D1,cb.SUPERVISION.noUpWind(A0)
        BPL     noSuper
        CLR.W   cb.SUPERVISION.noUpWind(A0)
        (*$? doSupervision:
        BRA     ende
        *)
mCtrl
        ADD.W   D1,cb.SUPERVISION.noMouseCtrl(A0)
        BPL     noSuper
        CLR.W   cb.SUPERVISION.noMouseCtrl(A0)
        (*$? doSupervision:
        BRA     ende
        *)
noSuper
    
        MOVE.L  pubs, A0
        MOVE.W  D0,pubArrays.aINTIN(A0)
        MOVE.W  #WIND_UPDATE,(A3)+
        JSR     aes_if
        JSR     testINTOUT0
ende
    END;
  END updateWindow;

PROCEDURE closeWindow(handle:CARDINAL);

  BEGIN
    ASSEMBLER
        MOVE.L  our_cb,A0
        MOVE.W  -(A3),D0
        
        CMP.W   #31,D0
        BHI     noSuper                 ; springe, falls 'handle' zu groû
        MOVE.L  cb.SUPERVISION.openWinds(A0),D1
        BCLR    D0,D1                   ; delete handle out of OpenWind-list
        MOVE.L  D1,cb.SUPERVISION.openWinds(A0)
noSuper

        MOVE.L  pubs, A0
        MOVE.W  D0,pubArrays.aINTIN(A0)
        MOVE.W  #WIND_CLOSE,(A3)+
        JSR     aes_if
        JSR     testINTOUT0
    END;
  END closeWindow;

PROCEDURE deleteWindow(handle:CARDINAL);

  BEGIN
    ASSEMBLER
        MOVE.L  our_cb,A0
        MOVE.W  -(A3),D0
        
        CMP.W   #31,D0
        BHI     noSuper                 ; springe, falls 'handle' zu groû
        MOVE.L  cb.SUPERVISION.createWinds(A0),D1
        BCLR    D0,D1                   ; delete handle out of CreateWind-list
        MOVE.L  D1,cb.SUPERVISION.createWinds(A0)
noSuper

        MOVE.L  pubs, A0
        MOVE.W  D0,pubArrays.aINTIN(A0)
        MOVE.W  #WIND_DELETE,(A3)+
        JSR     aes_if
        JSR     testINTOUT0
    END;
  END deleteWindow;


                (* IR-Vector routines (must be global for supervision) *)

PROCEDURE exchangeTimerVec(new:PROC;VAR time:CARDINAL):PROC;

  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)     ; VAR-Zeiger retten
        MOVE.L  our_cb,A0
        MOVE.L  -(A3),cb.V_CONTRL.multi1(A0)
        MOVE.L  cb.CURDEVICE(A0),(A3)+
        MOVE.W  #EX_TIMER_INTER,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  pubs,A0
        MOVE.L  (A7)+,A1
        MOVE.W  pubArrays.vINTOUT(A0),(A1)
        MOVE.L  our_cb,A0
        MOVE.L  cb.V_CONTRL.multi3(A0),(A3)+
    END;
  END exchangeTimerVec;

PROCEDURE exchangeMouseVec (opcode:CARDINAL;new:PROC) :PROC;

  BEGIN
    ASSEMBLER
        MOVE.L  our_cb,A0
        MOVE.L  -(A3),cb.V_CONTRL.multi1(A0)
        MOVE.W  -(A3),D0
        MOVE.L  cb.CURDEVICE(A0),(A3)+
        MOVE.W  D0,(A3)+
        CLR.W   (A3)+
        JSR     vdi_if
        MOVE.L  our_cb,A0
        MOVE.L  cb.V_CONTRL.multi3(A0),(A3)+
    END;
  END exchangeMouseVec;

PROCEDURE removeTimerVector(VAR hdl:vecListElem);

  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A1
        LEA     timerVecList,A0         ; ADR(TimerVecList) -> A0
loop
        MOVE.L  (A0),A2                 ; Ptr. to cur. 'vecListElem' -> A2
        CMPA.L  #NIL,A2
        BEQ     ready                   ; jump, if NIL
        CMPA.L  A1,A2
        BNE     noMatch                 ; jump, if element not found
        MOVE.L  vecListElem.next(A2),(A0) ; ausketten
        MOVE.L  timerVecList,D0
        BNE     ready                   ; springe, falls 'TimerVecList#NIL'
        MOVE.L  orgTimerVec,(A3)+       ; Setze Vector wieder in Normalzustand
        SUBQ.L  #2,A7
        MOVE.L  A7,(A3)+
        JSR     exchangeTimerVec        ; exchangeTimerVec(orgTimerVec,<VoidC>)
        ADDQ.L  #2,A7
        SUBQ.L  #4,A3                   ; Ergebnis ist irrelevant
        BRA     ready                   ; fertig!
noMatch
        LEA     vecListElem.next(A2),A0 ; ADR(vecListElem.next) -> A0
        BRA     loop
ready
        MOVE.L  our_cb,A0
        LEA     cb.SUPERVISION(A0),A0
        MOVE.L  timerVecList,D0
        CMP.L   superData.timerPrev(A0),D0
        BNE     cont                    ; bra, if vec's of this level remain
        CLR.W   superData.timerChgd(A0) ; Set flag to 'no timervec'
cont
    END;
  END removeTimerVector;

PROCEDURE removeButChgVector(VAR hdl:vecListElem);

  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A1
        LEA     butChgVecList,A0        ; ADR(ButChgVecList) -> A0
loop
        MOVE.L  (A0),A2                 ; Ptr. to cur. 'vecListElem' -> A2
        CMPA.L  #NIL,A2
        BEQ     ready                   ; jump, if NIL
        CMPA.L  A1,A2
        BNE     noMatch                 ; jump, if element not found
        MOVE.L  vecListElem.next(A2),(A0) ; ausketten
        MOVE.L  butChgVecList,D0
        BNE     ready                   ; springe, falls 'ButChgVecList#NIL'
        MOVE.W  #EX_BUT_CHANGE,(A3)+    ; Setze Vector wieder in Normalzustand
        MOVE.L  orgButChgVec,(A3)+      ; exchangeMouseVec(EX_BUT_CHANGE,
        JSR     exchangeMouseVec        ;                  orgButChgVec,deltaT)
        TST.L   -(A3)                   ; Ergebnis ist irrelevant
        BRA     ready                   ; fertig!
noMatch
        LEA     vecListElem.next(A2),A0 ; ADR(vecListElem.next) -> A0
        BRA     loop
ready
        MOVE.L  our_cb,A0
        LEA     cb.SUPERVISION(A0),A0
        MOVE.L  butChgVecList,D0
        CMP.L   superData.butChgPrev(A0),D0
        BNE     cont                    ; bra, if vec's of this level remain
        CLR.W   superData.butChgChgd(A0); Set flag to 'no butChgvec'
cont
    END;
  END removeButChgVector;

PROCEDURE removeMsMoveVector(VAR hdl:vecListElem);

  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A1
        LEA     msMoveVecList,A0        ; ADR(msMoveVecList) -> A0
loop
        MOVE.L  (A0),A2                 ; Ptr. to cur. 'vecListElem' -> A2
        CMPA.L  #NIL,A2
        BEQ     ready                   ; jump, if NIL
        CMPA.L  A1,A2
        BNE     noMatch                 ; jump, if element not found
        MOVE.L  vecListElem.next(A2),(A0) ; ausketten
        MOVE.L  msMoveVecList,D0
        BNE     ready                   ; springe, falls 'msMoveVecList#NIL'
        MOVE.W  #EX_MOUSE_MOVE,(A3)+    ; Setze Vector wieder in Normalzustand
        MOVE.L  orgMsMoveVec,(A3)+      ; exchangeMouseVec(EX_MOUSE_MOVE,
        JSR     exchangeMouseVec        ;                  orgMsMoveVec,deltaT)
        TST.L   -(A3)                   ; Ergebnis ist irrelevant
        BRA     ready                   ; fertig!
noMatch
        LEA     vecListElem.next(A2),A0 ; ADR(vecListElem.next) -> A0
        BRA     loop
ready
        MOVE.L  our_cb,A0
        LEA     cb.SUPERVISION(A0),A0
        MOVE.L  msMoveVecList,D0
        CMP.L   superData.msMovePrev(A0),D0
        BNE     cont                    ; bra, if vec's of this level remain
        CLR.W   superData.msMoveChgd(A0); Set flag to 'no msMovevec'
cont
    END;
  END removeMsMoveVector;

PROCEDURE removeCurChgVector(VAR hdl:vecListElem);

  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A1
        LEA     curChgVecList,A0        ; ADR(curChgVecList) -> A0
loop
        MOVE.L  (A0),A2                 ; Ptr. to cur. 'vecListElem' -> A2
        CMPA.L  #NIL,A2
        BEQ     ready                   ; jump, if NIL
        CMPA.L  A1,A2
        BNE     noMatch                 ; jump, if element not found
        MOVE.L  vecListElem.next(A2),(A0) ; ausketten
        MOVE.L  curChgVecList,D0
        BNE     ready                   ; springe, falls 'curChgVecList#NIL'
        MOVE.W  #EX_MOUSE_CHANGE,(A3)+    ; Setze Vector wieder in Normalzustand
        MOVE.L  orgCurChgVec,(A3)+      ; exchangeMouseVec(EX_MOUSE_CHANGE,
        JSR     exchangeMouseVec        ;                  orgCurChgVec,deltaT)
        TST.L   -(A3)                   ; Ergebnis ist irrelevant
        BRA     ready                   ; fertig!
noMatch
        LEA     vecListElem.next(A2),A0 ; ADR(vecListElem.next) -> A0
        BRA     loop
ready
        MOVE.L  our_cb,A0
        LEA     cb.SUPERVISION(A0),A0
        MOVE.L  curChgVecList,D0
        CMP.L   superData.curChgPrev(A0),D0
        BNE     cont                    ; bra, if vec's of this level remain
        CLR.W   superData.curChgChgd(A0); Set flag to 'no curChgvec'
cont
    END;
  END removeCurChgVector;

BEGIN

  (*  Liste initalisieren
   *)
  root_cb := NIL;
  our_cb := root_cb;
  
  pubs := NIL;
  
  error := FALSE;         (*  Kein Fehler aufgetretten  *)
  errorProcPtr := NIL;    (*  Keine Fehlerroutine angemeldet  *)
  ptrToErrHdler := NIL;
  
                (*  'Plugs' zurÅcksetzen  *)
  
  keyboardPlugActive := FALSE;
  buttonPlugActive := FALSE;
  firstRectPlugActive := FALSE;
  secondRectPlugActive := FALSE;
  messagePlugActive := FALSE;
  timerPlugActive := FALSE;
  
END GEMShare.

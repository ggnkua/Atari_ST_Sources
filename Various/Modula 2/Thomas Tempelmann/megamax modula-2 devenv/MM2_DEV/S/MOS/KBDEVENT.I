IMPLEMENTATION MODULE KbdEvents;
(*$R-,S- StackÅberprÅfung muû ausgeschaltet sein !!*)
(*$Y+*)

(*------------------------------------------------------------------------------
 * Version 2.6  (fÅr MEGAMAX MOS 2.2)
 *------------------------------------------------------------------------------
 * Copyright (c) 1989, 90, 91 by Michael Seyfried
 *------------------------------------------------------------------------------
 *                              Implementierungshinweise
 *
 * Die Routinen 'afterTrap2','Trap2Handler','IKBDHandler' und 'EtvTimerHandler'
 * muûten wegen besonderer Anforderungen in Assembler codiert werden. Ich habe
 * mich bemÅht, die Routinen so gut wie mîglich zu kommentieren.
 * Damit der Fehler beim AES behoben werden kann wird 'Trap2Handler' auf den
 * TRAP2-Vektor installiert. Diese Routine sorgt dann dafÅr, daû nach einem
 * Aufruf von 'evnt_keyboard' oder 'evnt_multi' vor der RÅckkehr zum Aufrufer
 * 'afterTrap2' aufgerufen wird.
 * 'OverflowHandler' verhindert ein TastaturÅberlauf Åber 'BufferKeyPtr' hinaus.
 * Dazu wird er Åber die Vektoren 'IKBD' und 'etv_timer' angesprungen.
 *------------------------------------------------------------------------------
 * 11.08.89   2.0   Fertigstellung der Version 2.0
 * 13.08.89   2.1   Falls ein Prozeû 'evnt_multi' ruft, wird nur dann
 *                  'Trap2Handler' angesprungen, wenn auch auf ein Tastatur-
 *                  ereignis gewartet wird.
 * 14.08.89   2.1a  Bug in Trap2Handler behoben. 'evnt_multi' wurde nur
 *                  behandelt, wenn man auf ein MAUSEREIGNIS wartete.
 * 15.08.89   2.1b  Es werden nun alle Register gerettet, weil der Orginal-
 *                  dispatcher das auch macht.
 * 15.08.89   2.2   WriteToAppl gestrichen, weil unnîtig, wenn dieses Modul
 *                  sich mit SysInitGem anmeldet und vor ExitGem die Vektoren
 *                  restauriert.
 * 19.08.89   2.2a  Die Vektoren werden nun nicht mehr mit den Prozeduren aus
 *                  dem Modul 'XBRA' verÑndert. Es ist nun ein lokales Modul
 *                  'xbra' vorhanden, das spezielle Prozeduren fÅr (Assembler-)
 *                  Routinen enthÑlt, die schon einen XBRA-Header haben.
 * 01.09.89   2.3   'LookAESKeys' und 'AESShift' wurden entfernt. Fehler bei der
 *                  Syncronisation behoben. Modul installiert sich nun nicht
 *                  mehr automatisch.
 * 17.09.89   2.4   Syncronisation korrigiert. Rechner 'hÑngt' nicht mehr bei
 *                  öberlauf des Puffers Åber BufferKeyPtr.
 * 02.05.90         Anpassung an Compiler 3.8, $Y+ vorn eingefÅgt
 * 25.11.90   2.5   TT: InitApplication statt InitGem-Aufruf, TRAP #6 statt
 *                  RaiseError-Aufruf
 * 15.02.91   2.6   Fehler bei der Tastatursyncronisation behoben.
 *------------------------------------------------------------------------------
 *)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, ADR, WORD;

FROM MOSGlobals IMPORT MemArea, OutOfMemory;

FROM XBIOS IMPORT IORECPTR, IORec, Keyboard;

FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;

FROM SysUtil2 IMPORT ModeBuf, EnterSupervisorMode, LeaveSupervisorMode;

FROM SysTypes IMPORT AnyLongType, BBS;

FROM SysVars IMPORT etv_timer, conterm;

FROM GEMEnv IMPORT GemHandle, SysInitApplication, ExitGem, CurrGemHandle;

IMPORT GEMShare;


CONST KbShiftBit        = 3;      (* wichtige Bits in Conterm               *)
      KbRepeatBit       = 1;      (*           "                            *)
      HighTrap2PBList   = 25;     (* "BeschrÑnkung" auf 25 Prozesse         *)
      XBRAID            = "KbEv"; (* öbereinstimmung mit den Prozeduren !!  *)
      TRAP2             = $088L;  (* Adresse des TRAP2-Vektors              *)
      IKBD              = $118L;  (* Adresse des IKBD-Vektors               *)
      JMPInstr          = $4EF9;  (* Code fÅr JMP     $xxxxxxxx             *)
      MOVEToStackInstr  = $2F3C;  (* Code fÅr MOVE.L  #$xxxxxxxx, -(SP)     *)

TYPE  PtrAnyLongType  = POINTER TO AnyLongType;

      (* Trap2 Parameter Block *)
      PtrTrap2PB      = POINTER TO Trap2PB;
      Trap2PB         = RECORD
                          AESNo: CARDINAL;          (* AES-Funktionsnummer *)
                          AddrINTOUT: ADDRESS;      (* Adr. von IntOut *)
                          ReturnAddr: ADDRESS;      (* Returnadr. nach TRAP2 *)
                          moveToStackInstr: WORD;   (* MOVE.L #PBAddr, -(SP) *)
                          PBAddr: ADDRESS;          (* Adr. auf dieses Feld *)
                          jmpInstr: WORD;           (* JMP afterTrap2 *)
                          AfterTrap2Addr: ADDRESS;  (* Adr. von afterTrap2 *)
                        END;

VAR   IoRecPtr: IORECPTR;           (* Zeiger auf IOREC-Struktur der Tastatur *)
      IbufPlusIbufsize: ADDRESS;    (* IoRec.ibuf + IoRec.ibufsize *)
      BufferKeyPtr: PtrAnyLongType; (* Ptr. auf akt. AES-Zeichen im Kbd-Buffer*)
      BufferKeyValid: BOOLEAN;      (* TRUE, wenn BufferKeyPtr gÅltig *)

      rCarrier: RemovalCarrier;     (* FÅr ordentliche Prozeûbeendingung *)

      (* Systemvariablen *)
      Conterm   [conterm]   : BBS;

      (* Speicher fÅr alte und neue Werte *)
      oldConterm: BBS;

      (* In dieser Liste werden fÅr jeden Prozeû, der 'evnt_timer' oder
       * 'evnt_keyboard' gerufen hat, wichtige Daten zwischengespeichert.
       * Die nicht belegten ListeneintrÑge werden Åber 'Trap2PBFree' und
       * untereinander Åber 'AddrINTOUT' verkettet.
       *)
      Trap2PBList     : ARRAY [0..HighTrap2PBList] OF Trap2PB;
      Trap2PBFree     : PtrTrap2PB;     (* Zeiger auf unbenutzte Elemente *)

      (* Flags, die anzeigen, welche Vektoren DIESES Modul installiert hat *)
      TRAP2VecInstalled    : BOOLEAN;
      IKBDVecInstalled     : BOOLEAN;
      EtvTimerVecInstalled : BOOLEAN;

      (* GEM-Handle dieses Moduls *)
      GEMHandle: GemHandle;


MODULE xbra;
(*
 * Dieses Modul enthÑlt Prozeduren, mit deren Hilfe man (Assembler-) Routinen,
 * die bereits einen XBRA-Header enthalten, auf Vektoren installieren, bzw.
 * installierte Routinen entfernen kann.
 * Alle Prozeduren dÅrfen nur im Supervisor-Mode aufgerufen werden !!
 * Nach VorschlÑgen von Thomas Tempelmann.
 *)

IMPORT ASSEMBLER, ADDRESS;

EXPORT  ID, install, installed, remove;


TYPE ID = ARRAY [0..3] OF CHAR;   (* Typ fÅr xb_id *)


(*$L- Parameter linking aus fÅr das ganze lokale Modul*)

  PROCEDURE install( xbraProc: PROC; vec: ADDRESS);
  (*
   * Eingabe: (Assembler-) Routine mit XBRA-Header und Vektor
   * Effekt:  Die Routine wird auf den angegebenen Vektor installiert. Dabei
   *          wird der alte Vektor gemÑû XBRA-Standard in den XBRA-Header der
   *          Prozedur xbraProc gerettet.
   * Beachte: Diese Routine ÅberprÅft nicht, ob xbraProc bereits auf den Vektor
   *          installiert ist. Dazu dient die folgende Prozedur 'installed'.
   *)
    BEGIN
      ASSEMBLER
          MOVE    SR,D2
          ORI     #$0700,SR
          MOVE.L  -(A3), A0       ; Vektoradresse vom Param.-Stack holen
          MOVE.L  -(A3), A1       ; Adresse von xbraProc vom Param.-Stack holen
          LEA     12(A1), A1      ; entry berechnen
          MOVE.L  (A0),-4(A1)     ; alten Vektor retten (in XBRA-Struktur)
          MOVE.L  A1,(A0)         ; Vektor auf entry verbiegen
          MOVE    D2,SR
      END
    END install;

  PROCEDURE installed( name: ID; vec: ADDRESS): BOOLEAN;
  (*
   * Eingabe: XBRA-Kennung und Vektor
   * Wert:    TRUE, genau dann wenn auf den Vektor eine Routine mit der ange-
   *          gebenen XBRA-Kennung installiert ist.
   *)
    BEGIN
      ASSEMBLER
              MOVE    SR,D2
              ORI     #$0700,SR
              MOVE.L  -(A3), A0             ; Vektoradresse nach A0
              MOVE.L  -(A3), A2             ; XBRA-Kennung nach A2
           l: MOVE.L  (A0),A1
              CMPI.L  #$58425241,-12(A1)    ; Ist dies ein XBRA-Eintrag?
              BNE     n                     ; Nein -> nicht gefunden
              CMPA.L  -8(A1), A2            ; Kennung gleich ?
              BEQ     f                     ; Ja -> gefunden
              LEA     -4(A1),A0             ; Vorige Vektoradr. nach A0
              BRA     l
           n: MOVE.W  #FALSE, (A3)+
              BRA     fin
           f: MOVE.W  #TRUE, (A3)+
         fin: MOVE    D2,SR
      END
    END installed;

  PROCEDURE remove( xbraProc: PROC; vec: ADDRESS);
  (*
   * Eingabe: XBRA-Routine und Vektor
   * Effekt:  Die angegebene Routine wird, falls installiert, aus der auf vec
   *          installierten Vektorenkette ausgeklinkt. Der alte Vektor wird
   *          restauriert.
   * Beachte: Diese Routine darf nur aufgerufen werden, wenn man sicher ist,
   *          daû die Routine xbraProc auf dem angegebenen Vektor installiert
   *          war (ist), weil auf jeden Fall der alte Vektor (im XBRA-Header
   *          von xbraProc) restauriert wird. Dies wird deshalb so gehandhabt,
   *          da es immer noch viele Programme gibt, die Vektoren nicht nach
   *          dem XBRA-Verfahren verbiegen.
   *)
    BEGIN
      ASSEMBLER
          MOVE    SR,D2
          ORI     #$0700,SR
          MOVE.L  -(A3), A0             ; Vektoradresse holen
          MOVE.L  -(A3), A2             ; Adresse von xbraProc holen
          LEA     12(A2), A2            ; entry berechnen
       l: MOVE.L  (A0),A1
          CMPA.L  A2,A1                 ; 'entry' gefunden?
          BEQ     f
          CMPI.L  #$58425241,-12(A1)    ; Ist dies ein XBRA-Eintrag?
          BNE     n                     ; Nein -> entry hier trotzdem austragen
          LEA     -4(A1),A0             ; Vorige Vektoradr. nach A0
          BRA     l
       n: MOVE.L  A2,A1
       f: MOVE.L  -4(A1),(A0)           ; Entry.old eintragen
          MOVE    D2,SR
      END
    END remove;

(*$L= Parameter linking wieder ein*)

END xbra;


PROCEDURE FlushKbd;
(*
 * Effekt: Der AES-Puffer und Tastaturpuffer werden gelîscht.
 *)
  BEGIN
    pubs^.aINTIN[0]:= 33;          (* ev_mflags:= {keyboard, timer} *)
    pubs^.aINTIN[14]:= 0;          (* ev_mtlocount:= 0              *)
    pubs^.aINTIN[15]:= 0;          (* ev_mthicount:= 0              *)
    REPEAT
      aes_if( 25)                 (* evnt_multi                    *)
    UNTIL pubs^.aINTOUT[0] = 32    (* UNTIL ev_mwhich = {timer}     *)
  END FlushKbd;

PROCEDURE SyncBuffer;
(*
 * Effekt:  BufferKeyPtr und HighBufferKey werden mit dem AES-Puffer
 *          syncronisiert. Dazu wird der AES-Buffer gelîscht.
 *)
  BEGIN
    WITH IoRecPtr^ DO
      BufferKeyPtr:= ibuf + LONG (ibuftl);
      BufferKeyValid:= TRUE;
    END;
  END SyncBuffer;

(*$L- Parameter linking aus*)
PROCEDURE afterTrap2;
(*
 * Diese Routine wird bei der RÅckkehr aus einer der Routinen 'evnt_keyboard'
 * bzw. 'evnt_multi' aufgerufen. Sie setzt dann 'BufferKeyPtr' auf das richtige
 * Zeichen im Tastaturpuffer und kehrt zum Aufrufer, i.A. dem Anwenderprogramm,
 * zurÅck.
 * Der letzte Punkt ist aber gar nicht so einfach, wie man glaubt. Denn auch
 * Accessorys rufen 'evnt_multi'. Es reicht also bei weitem nicht aus, die
 * RÅcksprungadresse in einer globalen Variablen zwischenzuspeichern. Auch die
 * Verwendung eines Stacks zum Ablegen dieser Adressen ist unmîglich, da beim
 * Pseudo-Multitasking die Reihenfolge der Aufrufe von evnt_multi nicht immer
 * mit der Reihenfolge der RÅcksprÅnge aus diesen Routinen Åbereinstimmt.
 * Zur Lîsung diese Problems wird von 'Trap2Handler' fÅr jeden Prozeû, der
 * 'evnt_keyboard' oder 'evnt_multi' aufruft, ein Parameterblock angelegt, in
 * dem einige Daten und die RÅcksprungadresse abgelegt werden. Auûerdem steht
 * in diesem Parameterblock eine JMP-Anweisung auf 'afterTrap2'. Vor dieser JMP-
 * Anweisung steht ein Befehl, der die Adresse dieses PB in Register A0
 * schreibt. 'Trap2Handler' sorgt dafÅr, daû bei der RÅckkehr aus einer AES-
 * Routine Åber diese Anweisungen 'afterTrap2' aufgerufen wird. Durch die
 * Adresse des PB in A0 erhÑlt diese Routine so alle Daten und die richtige
 * RÅcksprungadresse.
 * Vor dem RÅcksprung zum Aufrufer wird in 'int_out[ 4] der Tastaturzustand bei
 * Tastendruck geschrieben. So liefert nun 'AESEvents.MultiEvent' den Status
 * der Sondertasten richtig zurÅck.
 *
 * Es werden alle Register gerettet !
 *)
  BEGIN
    ASSEMBLER
                      ; Bei Eintritt steht auf dem Stack die Adresse des
                      ; zugehîrigen Parameter Blocks

                      ; Erstmal die benîtigten Register retten:
                      MOVEM.L D0-D2/A0-A2, -(SP)

                      ; Parameter holen:
                      MOVE.L  24(SP), A0              ; Adresse des PB holen
                      MOVE.W  (A0), D0                ; AES-Fktnr. nach D0
                      MOVE.L  2(A0), A1               ; Adresse INTIN
                      MOVE.L  6(A0), 24(SP)           ; RÅckadr. auf Stack

                      ; PB in Free-Liste einfÅgen
                      MOVE.L  Trap2PBFree, 2(A0)      ; Åber 'AddrINTOUT' verk.
                      MOVE.L  A0, Trap2PBFree

                      TST.W   BufferKeyValid          ; BufferKeyPtr gÅltig ?
                      BEQ     return                  ; Nein->Nichts veranlassen

                      ; Falls vorhanden, Zeichen in D1 ermitteln
                      MOVE.W  (A1), D1                ; D1:= int_out[ 0]
                      CMPI.W  #20, D0                 ; evnt_keyboard ?
                      BEQ     lookKey                 ; => Zeichen in D1

                      ; bei evnt_multi schauen, ob Taste ansteht
                      ; => ev_mwhich in D1
                      BTST    #0, D1                  ; Tastaturereignis ?
                      BEQ     return                  ; falls nicht => ret
                      MOVE.W  10(A1), D1              ; sonst Zeichen aus
                                                      ; int_out[ 5] nach D1

                      ; entsprechendes Zeichen im Tastaturpuffer "suchen"
                      ; Initialisierungen:
        lookKey:      MOVE.L  IoRecPtr, A0            ; Adr IoRec nach A0
                      MOVE.W  8(A0), D0               ; D0:= ibuftl
                      EXT.L   D0
                      ADD.L   (A0), D0                ; D0 = ibuf + ibuftl
                      ADDQ.L  #4, D0                  ; INC( D0, 4)
                      MOVE.L  IbufPlusIbufsize, A2    ; hîchster Wert+1 nach A2
                      CMP.L   A2, D0                  ; D0 >= A2 ?
                      BLT     lookBuffer              ; falls nein, ok
                      MOVE.L  (A0), D0                ; sonst korrigieren

        lookBuffer:   MOVE.L  BufferKeyPtr, A0        ; Zeiger auf Puffer holen

        nextKey:      ; A0:= (A0 + 4) MOD A2
                      ADDQ.L  #4, A0                  ; BufferKeyPtr erhîhen
                      CMPA.L  A2, A0                  ; A0 >= A2 ?
                      BLT     getKey                  ; nein
                      MOVE.L  IoRecPtr, A0            ; Adr IoRec holen
                      MOVE.L  (A0), A0                ; A0:= ibuf

        getKey        CMPA.L  D0, A0                  ; BufferKeyPtr = ibuftl+4?
                      BEQ     notFound                ; falls ja nicht gefunden
                      MOVE.L  (A0), D2                ; Taste aus Puffer holen
                      CMP.B   D1, D2                  ; ASCII-Codes gleich ?
                      BNE     nextKey                 ; wenn nein nochmal
                      SWAP    D2                      ; scan-Code in low-Byte
                      ROR.W   #8, D1                  ; scan-Code in low-Byte
                      CMP.B   D1, D2                  ; Scan-Codes gleich ?
                      BEQ     found                   ; wenn ja, dann fertig
                      ROR.W   #8, D1                  ; wieder scan,ascii
                      BRA     nextKey                 ; nochmal

                      ; Zeichen wegen PufferÅberlauf nicht mehr im Puffer
        notFound:     CLR.W   BufferKeyValid          ;BufferKeyPtr nicht gÅltig
                      BRA     return

                      ; Zeichen gefunden => Kbshift in int_out[ 4] schreiben
        found:        MOVE.L  A0, BufferKeyPtr        ; BufferKeyPtr sichern
                      LSR.W   #8, D2                  ; Kbshift in low-Byte
                      MOVE.W  D2, 8(A1)               ; nach int_out[ 4]

        return:       ; Zum Aufrufer der AES-Routine (TRAP2) zurÅckkehren
                      MOVEM.L (SP)+, D0-D2/A0-A2      ; Regs restaurieren

                      ; nun steht die RÅcksprungadresse auf dem Stack und
                      ; RTS kehrt zurÅck.
    END
  END afterTrap2;
(*$L=*)

(*$L- Parameter linking aus*)
PROCEDURE Trap2Handler;
(*
 * Diese Routine ist auf den TRAP2-Vektor installiert und wird daher bei
 * jedem AES oder VDI-Aufruf angesprungen. ZunÑchst wird dann getestet,
 * ob ein AES-Aufruf (D0 = 200) vorliegt. Ist dies der Fall, dann wird
 * nachgefragt, ob evnt_keyboard (AES 20) oder evnt_multi (AES 25) auf-
 * gerufen wurde. Falls nicht, wird nichts weiter veranlasst und die vorher-
 * gehende TRAP2-Routine wird ausgefÅhrt.
 * Im anderen Fall wird ein Parameter Block angelegt, der die AES-Funktions-
 * nummer, die Adresse des int_in-Arrays und die RÅcksprungadresse enthÑlt.
 * Bei Modulinitialisierung wurden Anweisungen in diesen PB geschrieben, die
 * 'afterTrap2' mit der Adresse dieses PB als Parameter in A0 aufrufen.
 * Der Wert des PC auf dem SSP-Stack wird dann so verÑndert, daû nach RÅckkehr
 * aus dem AES Åber diese Anweisungen 'afterTrap2' aufgerufen wird.
 *
 * Es werden alle Register gerettet !
 *)
  BEGIN
    ASSEMBLER
                      ; XBRA-Header
                      ASC     "XBRA"              ; xb_magic
                      ASC     "KbEv"              ; xb_id
      xb_oldvec:      DC.L    0                   ; wird von install gesetzt

                      ; hier ist die Einsprungadresse
                      ; feststellen, ob evnt_keyboard oder evnt_multi
                      ; aufgerufen wurde:
      entry:          CMPI.W  #200, D0            ; AES-Aufruf ?
                      BNE.W   callPreviousV

                      ; AES-Aufruf => erstmal die benîtigten Register retten
                      MOVEM.L D2/A1-A3, -(SP)
                      EXG.L   D1, A0              ; AESPB nach A0

                      MOVE.L  (A0), A1            ; Adresse von control([0])
                      MOVE.W  (A1), A2            ; Opcode fÅr AES nach A2
                      CMPA.W  #20, A2             ; evnt_keyboard ?
                      BEQ     useAfterTrap2
                      CMPA.W  #25, A2             ; evnt_multi ?
                      BNE     restore

                      ; falls evnt_multi, feststellen, ob Åberhaupt auf ein
                      ; Tastaturereignis gewartet wird.
                      MOVE.L  8(A0), A1           ; Adresse von int_in([0])
                      MOVE.W  (A1), D2            ; D2:= ev_mflags
                      BTST    #0, D2              ; keyboard IN ev_mflags ?
                      BEQ     restore             ; nein => alte Rotine

                      ; falls BufferKeyPtr nicht gÅltig, Puffer syncronisieren
      useAfterTrap2:  TST.W   BufferKeyValid      ; BufferKeyPtr gÅltig ?
                      BNE     createPB            ; Ja -> weiter

                      ; BufferKeyPtr ist nicht gÅltig => neu syncronisieren
                      LEA     stack(PC), A3         ; A3-Stack anlegen
                      MOVEM.L D0-D1/A0/A2, -(SP)    ; benîtigte Register retten
                      JSR     SyncBuffer            ; Puffer leeren u. sync.
                      MOVEM.L (SP)+, D0-D1/A0/A2    ; Register restaurieren
                      MOVE.W  #TRUE, BufferKeyValid ; BufferKeyValid:= TRUE

                      ; Trap2PB anlegen
      createPB:       MOVE.L  Trap2PBFree, A1     ; Adr. vom freien Listenel.
                      MOVE.L  2(A1), Trap2PBFree  ; aus FreeList ausketten
                      MOVE.W  A2, (A1)+           ; AES-Nr. ablegen
                      MOVE.L  12(A0), (A1)+       ; Adr. INTOUT ablegen
                      MOVE.L  18(SP), (A1)+       ; Return-Adresse ablegen
                      MOVE.L  A1, 18(SP)          ; n. ret. Åber PB afterTrap2

                      ; Register restaurieren
      restore:        MOVEM.L (SP)+, D2/A1-A3
                      EXG.L   A0, D1

                      ; alte Trap2-Routine aufrufen
      callPreviousV:  MOVE.L  xb_oldvec(PC), -(SP)  ; alten Vektor auf Stack

                      ; Auf dem Stack steht nun der alte Vektor. Dieser wird
                      ; durch RTS angesprungen.
                      RTS

      stack:          DS      2000                   ; 500 Bytes Stack
    END
  END Trap2Handler;
(*$L=*)

(*$L- Parameter linking aus*)
PROCEDURE OverflowHandler;
(*
 * Diese Routine Åberwacht, ob 'IoRec.ibuf' + 'IoRec.head' 'BufferKeyPtr'
 * "Åberholt".
 *
 * Es werden alle Register gerettet !!
 *)
  BEGIN
    ASSEMBLER
                      ; Einsprungadresse
                      ; Alter Vektor steht bei Eintritt auf dem Stack

                      ; Testen, ob Puffer Åbergelaufen war
                      TST.W   BufferKeyValid
                      BEQ     callPreviousV         ; JA->alte Routine

                      MOVEM.L A0-A1/D0-D1, -(SP)    ; benîtigte Register retten

                      ; D0:= ibuf + ((ibufhd + 4L) MOD ibufsize)
                      MOVE.L  IoRecPtr, A0          ; Adr. IoRec holen
                      MOVE.W  6(A0), D0             ; D0:= ibufhd
                      EXT.L   D0                    ; Longword daraus machen
                      ADD.L   (A0), D0              ; D0:= ibuf + ibufhd
                      ADDQ.L  #4, D0                ; INC( D0, 4)
                      MOVE.L  IbufPlusIbufsize, D1  ; D1:= ibuf + ibufsize
                      CMP.L   D1, D0                ; D0 < D1?
                      BLT     compare1
                      MOVE.L  (A0), D0              ; evt. korrigieren D0=ibuf

                      ; hat head+4 den BufferKeyPtr erreicht ?
      compare1:       CMP.L   BufferKeyPtr, D0      ; D0 = BufferKeyPtr ?
                      BEQ     BufferOverflow        ; JA->öberlauf

                      ; D0:= ibuf + ((ibufhd + 8L) MOD ibufsize)
                      ADDQ.L  #4, D0
                      CMP.L   D1, D0                ; D0 < D1?
                      BLT     compare2
                      MOVE.L  (A0), D0              ; evt. korrigieren D0=ibuf

                      ; hat head+8 den BufferKeyPtr erreicht ? (wegen Protos)
      compare2:       CMP.L   BufferKeyPtr, D0      ; D0 = BufferKeyPtr?
                      BNE     restore               ; Nein->alte Routine

      BufferOverflow: CLR.W   BufferKeyValid        ; BufferKeyPtr nicht gÅltig

                      ; alte Routine aufrufen
      restore:        MOVEM.L (SP)+, A0-A1/D0-D1    ; Register restaurieren

                      ;nun wird Åber RTS der alte Vektor angesprungen !!!
      callPreviousV:  RTS
    END
  END OverflowHandler;
(*$L=*)

(*$L- Parameter linking aus*)
PROCEDURE IKBDHeader;
(*
 * XBRA-Header fÅr IKBD-Routine
 *)
  BEGIN
    ASSEMBLER
                      ; XBRA-Header
                      ASC     "XBRA"                ; xb_magic
                      ASC     "KbEv"                ; xb_id
      xb_oldvec:      DC.L    0                     ; wird von install gesetzt

                      ; Einsprungadresse
                      MOVE.L  xb_oldvec(PC), -(SP)  ; Alter Vektor auf Stack
                      JMP     OverflowHandler       ; OverflowHandler rufen
    END
  END IKBDHeader;
(*$L=*)

(*$L- Parameter linking aus*)
PROCEDURE EtvTimerHeader;
(*
 * XBRA-Header fÅr IKBD-Routine
 *)
  BEGIN
    ASSEMBLER
                      ; XBRA-Header
                      ASC     "XBRA"                ; xb_magic
                      ASC     "KbEv"                ; xb_id
      xb_oldvec:      DC.L    0                     ; wird von install gesetzt

                      ; Einsprungadresse
                      MOVE.L  xb_oldvec(PC), -(SP)  ; Alter Vektor auf Stack
                      JMP     OverflowHandler       ; OverflowHandler rufen
    END
  END EtvTimerHeader;
(*$L=*)

PROCEDURE KbdEventsInstalled(): BOOLEAN;
  BEGIN
    RETURN IKBDVecInstalled OR EtvTimerVecInstalled OR TRAP2VecInstalled;
  END KbdEventsInstalled;

PROCEDURE DeInstallKbdEvents;

  VAR SupvHdl: ModeBuf;

  BEGIN
    EnterSupervisorMode( SupvHdl);           (* Supervisormodus, da SysVars *)

    (* alte Vektoren restaurieren *)
    (* nur restaurieren, wenn DIESES Modul die Vektoren gesetzt hat !!! *)
    IF TRAP2VecInstalled THEN
      remove( Trap2Handler, TRAP2);
      TRAP2VecInstalled:= FALSE;
    END;
    IF IKBDVecInstalled THEN
      remove( IKBDHeader, IKBD);
      IKBDVecInstalled:= FALSE;
    END;
    IF EtvTimerVecInstalled THEN
      remove( EtvTimerHeader, etv_timer);
      EtvTimerVecInstalled:= FALSE;
    END; (* IF *)

    (* Conterm zurÅcksetzen *)
    Conterm:= oldConterm;               (* alten Wert zurÅckschreiben *)

    LeaveSupervisorMode( SupvHdl);                 (* wieder in Usermodus schalten *)
  END DeInstallKbdEvents;

PROCEDURE InstallKbdEvents;

  VAR SupvHdl: ModeBuf;
      wait: CHAR;

  BEGIN
    (* Puffer syncronisieren *)
    SyncBuffer;
    FlushKbd;

    EnterSupervisorMode( SupvHdl);           (* Supervisormodus, da SysVars *)

    (* Trap2Handler initialisieren *)
    IF NOT installed( XBRAID, TRAP2) THEN
      install( Trap2Handler, TRAP2);
      TRAP2VecInstalled:= TRUE;
    END;

    IF TRAP2VecInstalled THEN
      (* restliche Initialisierungen nur, wenn Trap2Handler installiert *)

      (* Conterm setzen *)
      INCL( Conterm, KbShiftBit);         (* Kbshift-Bit setzen *)

      (* öberlauf des Tastaturpuffers Åber BufferKeyPtr verhindern *)
      IF NOT installed( XBRAID, IKBD) THEN
        (* Dazu OverflowHandler Åber IKBD und... *)
        install( IKBDHeader, IKBD);
        IKBDVecInstalled:= TRUE;
      END;
      IF NOT installed( XBRAID, etv_timer) THEN
        (* etv_timer aufrufen lassen. *)
        install( EtvTimerHeader, etv_timer);
        EtvTimerVecInstalled:= TRUE;
      END;
    END;
    LeaveSupervisorMode( SupvHdl);         (* wieder in Usermodus schalten *)
  END InstallKbdEvents;

PROCEDURE Removal;
(*
 * Diese Routine meldet das Modul beim GEM ab. Zuvor mÅssen die Register
 * restauriert werden.
 *)
  BEGIN
    (* Vektoren restaurieren *)
    DeInstallKbdEvents;

    (* Nun zuletzt beim GEM abmelden. Dabei wird jedem Accessory, das auf
     * Message-Events wartet die Nachricht accClose geschickt. Weil die
     * Vektoren restauriert sind, klinken sich die Acc's aus dem Modul aus.
     * Daher kann nun das Modul terminieren.
     *)
    ExitGem (GEMHandle);

  END Removal;

PROCEDURE InitModule;
(*
 * Modul initialisieren.
 *)
  PROCEDURE InitTrap2PBList;
  (*
   * Initialisiert die PB-Liste. Dazu werden alle PB's Åber 'Trap2PBFree'
   * verkettet. Auûerdem werden die richtigen Anweisungen zum Aufruf von
   * 'afterTrap2' in den PB eingetragen.
   *)
    VAR ListPtr: CARDINAL;

    BEGIN
      Trap2PBFree:= ADR( Trap2PBList);  (* Trap2PBFree zeigt auf erstes El. *)
      FOR ListPtr:= 0 TO HighTrap2PBList DO
        WITH Trap2PBList[ ListPtr] DO
          (* Liste Åber AddrIntOut verketten *)
          AESNo:= 0;                           (* Kennung fÅr freies Element *)
          IF ListPtr < HighTrap2PBList THEN
            AddrINTOUT:= ADR( Trap2PBList[ ListPtr+1])
          ELSE
            AddrINTOUT:= NIL
          END;
          moveToStackInstr:= WORD( MOVEToStackInstr);
          PBAddr:= ADR( Trap2PBList[ ListPtr]);
          jmpInstr:= WORD( JMPInstr);
          AfterTrap2Addr:= ADDRESS( afterTrap2);
        END (* WITH *)
      END; (* FOR *)
    END InitTrap2PBList;

  VAR wsp: MemArea;
      SupvHdl: ModeBuf;
      success: BOOLEAN;

  BEGIN
    (* zunÑchst beim GEM anmelden *)
    SysInitApplication ( success);
    IF NOT success THEN
      ASSEMBLER
        TRAP    #6
        DC.W    OutOfMemory
      END;
    END;
    (* GEM-Handle fÅr's abmelden merken *)
    GEMHandle:= CurrGemHandle();

    (* Zeiger auf IOREC-Struktur der Tastatur ermitteln *)
    IoRecPtr:= IORec( Keyboard);

    (* IbufPlusIbufsize errechnen *)
    WITH IoRecPtr^ DO
      IbufPlusIbufsize:= ibuf + LONG (ibufsize);
    END;

    (* Flags fÅr Vektoren initialisieren *)
    TRAP2VecInstalled:= FALSE;
    IKBDVecInstalled:= FALSE;
    EtvTimerVecInstalled:= FALSE;

    (* oldConterm initialisieren *)
    EnterSupervisorMode( SupvHdl);               (* Supervisormodus, da SysVar *)
    oldConterm:= Conterm;
    LeaveSupervisorMode( SupvHdl);                     (* wieder User-Modus *)

    (* Bei Terminierung deinitialisieren *)
    wsp.bottom:= 0L;
    CatchRemoval( rCarrier, Removal, wsp);

    (* Trap2PBList initialisieren *)
    InitTrap2PBList;
  END InitModule;

BEGIN
  (* Modul wird nun nicht mehr automatisch aktiv gesetzt !!! *)
  InitModule;
END KbdEvents.

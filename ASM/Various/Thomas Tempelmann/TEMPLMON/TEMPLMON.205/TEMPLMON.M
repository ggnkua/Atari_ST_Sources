(* Atari monitor   12.06.86  Th.Tempelmann V#0836  *)

MODULE TEMPLMON;
(*$C-,N+,L-,R-,Q+,V+,P-,X+*)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS;

CONST
  MAC = TRUE;
  INITMAC = FALSE;
  German = FALSE; English = TRUE;
  ADC = FALSE; (* erw. Tastatur-Routinen v. Andi Cambeis *)
  ExtendedKeys = FALSE; (* erw. Tastenabfrage? *)
  AltHelp = TRUE;  (* ALT/HELP-Aufruf? *)
  Debug   = FALSE; (* TempleMon-debugging Version zum Debugging von TempleMon
                      erzeugen. In dem zu debuggenden TempleMon muû an
                      entsprechender Stelle in den Patchvariablen ein Bit
                      gelîscht sein, dann kann man auch die Exeptionverarbeitung
                      debuggen. Standard: FALSE *)
  Test    = FALSE;  (* Auf Debugging TempleMon testen? Standard: TRUE *)


  Buserror_Bit                    =  0;
  Adresserror_Bit                 =  1;
  Illegal_Instruction_Bit         =  2;
  Division_by_Zero_Bit            =  3;
  CHK_Bit                         =  4;
  TRAPV_Bit                       =  5;
  Privilege_Violation_Bit         =  6;
  Trace_Bit                       =  7;
  Line_F_Bit                      =  8;
  Coprocessor_Protocol_Error_Bit  =  9;
  Format_Error_Bit                = 10;
  Uninitialized_Interrupt_Bit     = 11;
  Spurios_Interrupt_Bit           = 12;
  unused_TRAP_Bit                 = 13;
  Unordered_Condition_Bit         = 14;
  Inexact_Result_Bit              = 15;
  Divide_by_Zero_Bit              = 16;
  Underflow_Bit                   = 17;
  Operand_Error_Bit               = 18;
  Overflow_Bit                    = 19;
  Signaling_NAN_Bit               = 20;
  Unassigned_Bit                  = 21;
  MMU_Configuration_Error_Bit     = 22;

(*----------------------------------------------------------------------------
12.06.86  1.0  öbernahme des Gepardmonitors V2.9; Alle Zugriffe relativ
15.06.86  1.0  erste Tests auf Atari; Code an HHH
19.06.86  1.1  Trace-Abbruch mit ALT/HELP, Monitor-Screen
20.06.86  1.1  Test auf öberlauf d. Eing.zeile; 8*16-DispChar linear;
               Backspace impl.; Key-Brk testet PC, ob im Mon.;
               Code an OJO
21.06.86  1.2  Traceroutine: TrcStat in D7.B;
22.06.86  1.2  Deutsche Texte, Vorbereitung als public domain-Version
23.06.86  1.2  ConIn/Stat: Trap#13 wird neuer Hilfs-Speicher zugewiesen;
               EyRTU/EyRTN ok.
24.06.86  1.2  User-Trace verbessert
25.06.86  1.2  Engl. Version fertig, Deutsche und Engl. als Public domain an
               OJO und HHH
29.07.86  1.3  Save impl., 2 Fehler in Dism20 beh., bei NMI wird Int-maske
               zurÅck auf 3 gesetzt, Protokoll-Funktion impl.;
               Amerikanischen Text verbessert (Dank an Niels Jaeckel !)
20.09.86  1.4  Zeile wird bei "R:", "C" und "V" nicht mehr gelîscht; "M", ":",
               "C" und "V" arbeiten byteweise, Texte erweitert am Ende;
               Offset-Var geht mit z.B."~A0"; "0", "1", "D", "S", "F" und "B"
               bei TrcCtrl; ShortBPs mit "," bei "G"-Funktion; Statt '~' jetzt
               'R'; GetByteX; Errortest bei BP setzen; 'O' und "'" auf unger.
               Adr.; Farbausgabe (80 Zeichen); BP-setzen nur auf gerage Adr.;
               Tracing beschleunigt; BPs werden bei 'Q' gelîscht; "RS" u. "RR";
               BP #1-7 gehen auch; "VI";
               Fertigstellung 14.10.86.
13.01.87  1.5  Protocol: Keine Ctrl-Zeichen (auûer CR,LF,FF) an Drucker, LF
               wird trotz Screen-UnterdrÅckung an Drucker gesendet. Load neu,
               bei S/L Angabe der rel. Fileadr. mîglich, wenn keine Adr. bei L,
               dann wird Speicher angefordert. BP-Anzeige: Nur benutzte BPs.
               F erkennt wieder, daû nicht 2 Adr. anggeben wurden. GetAdr lÑût
               Expr. mit '+' und '-' zu. Dism2: BTST # richtiger. Bei vielen
               GetEA-Aufrufen ungerade Adr. erlaubt.
14.02.87  1.6  HKom: kein CAPS mehr; RgPC: MSByte wird gelîscht, dadurch Fehler
               beseitigt, daû BPs zeitweise (im ROM) nicht erkannt werden.
23.06.87  1.7  "VI" setzt BEV/AEV richtig; Protokoll unterdrÅckt endlich Ctrl-
               Zeichen richtig; von "GS" und "R" ohne Supervisor-State wird
               wieder korrekt zurÅckgekehrt.
23.06.87  1.8  Keine Farbschatten mehr.
23.08.87  1.9  IR-Freigabe, wenn Tastatur gesperrt
18.09.87  1.10 SHIFT-Abfrage bei ALT/HELP
09.11.87  1.11 ALT/HELP ohne Shift, Harcopy mit.
06.02.88  1.12 Kein Install bei zweitem Aufruf, meine Adr. neu, Tastatur-
               abfrage bei IR-Sperrung verbessert, nur noch TRAP #6 umgeleitet,
               Msg bei Installation, Anleitung (dtsch) raus.
08.03.88       Anleitung (engl) raus, conditional Compiling fÅr Sprache.
22.12.88  1.13 ADC: TEMPLMON auf ATARI-Megamax-Modula 2 angepasst;
               Neue Tastatur-Abfrage
02.01.89       XBRA-Kennungen; Bei Quit wird Mon-SP verwendet; Kein HÑnger mehr
               bei Bus/Addr-Error wÑhrend Single Step; Patch-Vars fÅr Cursor-
               blinken und Stacksize; Direktaufruf Åber IRQ#1 ($64).
14.01.89  1.14 VI zeigt geÑnderte Vektoren an.
01.04.89  1.15 Trace Bit nicht mehr an bei Q (in 1.14 drin gewesen).
16.06.89  1.16 "Q" korrigiert (SSP und USP durften sich nicht Åberlagern)
14.07.89  1.17 Beim Start werden wieder alle Traps abgefangen, bei VI nur
               Trap 6; MSBytes von geretteten Bus-/Addr-Error-Vektoren werden
               nicht mehr auf 2 bzw. 3 gesetzt (in ResetMon).
26.04.90       68020-Anpassung;
               EyKBD: Bei ALT/HELP wird die Alt-Taste ausdrÅcklich abgefragt,
               damit kein TMon-Aufruf bei Hardcopy Åber MenÅ passiert;
               Norm/MonScrn: $FF8260-Reg wird nun (hoffentlich) TT-kompatibel
               angesprochen; Format Error $38 f. 68020 abgefangen.
08.09.90 1.17c engl. Version zum Testen an GEnie
09.09.90 1.17d VBL-Routine zum Tastenabfrage raus, weil Probleme mit TT;
               Stattdessen direkter Abfang auf IR6-Vektor.
               IR-Maske kann in PatchVars bestimmt werden.
10.09.90 1.17e Warteschleife bei M & I, wenn 68020; $FF8260 mit 7 maskiert.
04.10.90 1.19O Editierbare Kommandozeile, History Funktion, OverScan Anpassung,
               Befehle mw,ml,:w,:l,p Adressierung, Abbruch wenn bei S Befehl
               zweite Adreûangabe fehlt, Abbruch wenn bei Installation Shift
               Taste gedrÅckt.
11.10.90 1.19P HyperScreen video_modus gesetzt.
11.10.90 1.19Q TT Shift Mode Register richtig ausmaskiert. STE und TT wird anhand
               von CookieJar getestet, nicht mehr nach Prozessor und Buserror bei
               Zugriff auf STE Register.
12.10.90 1.19R Malloc fÅr Bildschirm :=> lÑuft jetzt auch mit TT Fast Ram
22.10.90 1.19S Korrektur von Bildschirmspeichergrîûe & ComdQ, Korrektur der OverScan
               Umschaltroutinen.
06.11.90 1.19T Fullscreeneditor (bis auf blÑttern).
15.11.90 1.19U Fullscreeneditor mit blÑttern, etwas schnelleres restore.
15.11.90 1.20A
20.11.90 1.20B
05.12.90 1.20C
28.01.91 1.20F Ausgabe von ComdM nach ComdDopp
08.02.91 1.20G Register auf 68030 angepasst
05.03.91 1.20H Registerein/ausgabe auf 68030/(68882) angepaût.
06.03.91 1.20I Privilege violation exeption kann MOVE von SR ausfÅhren.
02.04.91 1.20K Trace on Flow Control, CheckKeyboard bei Eintritt in Kommandoschleife
               Division by Zero abschaltbar.
25.04.91 1.20L Protokollfileausgabe korrigiert.
21.05.91 1.20M Buserrorformat fÅr 68010, Realzahlen Input/Output, SysMon Aufruf Åber
               F10, symbolische Register Ein/Ausgabe. Filevariablen s, n, l.
22.05.91 1.20N Tastaturcheck auch beim Tracen. Ist jedoch Åber Patchvars abschaltbar.
               Name des Includefiles nun DISM30.ICL.
28.05.91 1.20O Nochmals Korrektur beim BlÑttern. In den Patchvars kann die
               BetriebssystemlÑnge eingestellt werden (fÅr KAOS).
06.06.91 1.20P Schneller Screenausgaben fÅr TT Hoch, schnelle ScreenRestoreroutine
               Korrektur der Registereingabe von TC, FPCR und FPSR
               LÑuft jetzt auch mit dem Masterstack.
11.07.91 1.20Q SysMon Interface verbessert, Init gekÅrzt, Faststring korrigiert.
18.07.91 1.20R Erste 68040 Anpassungen, Fehler bei ComdM mit Kommentar am Ende
               raus.
30.07.91 1.20S Neue Registerausgabe mit Tabulatoren. Buserrortest fÅr MMU
               fÅr 68030 und 68040 vollstÑndig implementiert.
27.08.91 1.20T Korrektur des Disassemblers.
02.09.91 1.20U Korrekturen am Disassembler.
04.09.91 1.20V Korrekturen am Disassembler und Trace Routine, neu ist C wÑhrend
               des Tracens und die Befehle K+ und K-
10.09.91 1.20W Disassemblerkorrekturen, ScancodeausfÅgen bei ComdG und ComdQ
18.09.91 1.20X Disassemblerkorrekturen
02.10.91 1.20Y Weitere Korrekturen
14.10.91 1.20Z Vorbereitung zur Freigabe als Version 2.0
16.10.91       Schnittstelle zur OnLine Hilfe
17.10.91       OnLine Hilfe Aufruf mit Zugriff auf Eingabezeilenpuffer
18.10.91       OnLine Hilfe Aufruf mit zusÑtzlichen Parametern: Zugriff auf
               aktuelle Cursorposition. Returnwert in D0: <>0 Kommandozeile
               wird ausgefÅhrt!
21.10.91 2.00  Ein Fehler beim Disassembler raus, Neue Funktion fÅr Makros
               bei RETURN rein.
23.10.91 2.00  Dies ist die neue Version. West Germany gegen Germany im
               Copyright ersetzt.
28.10.91 2.01  Ein Fehler in TestMMUBuserror bei 68000 Prozessor
15.11.91 2.01  Ein paar kleine Fehler bei GETAE und optische Korrekturen,
               Modulfunktionen fÅr Tasten HELP und RETURN.
03.12.91 2.01  Beim Parsen Spaces vor X,L und Z raus. ESC/CLR Funktion
               vertauscht und UNDO mîglich, Kein Parsen, wenn ! nicht an
               erster Stelle, History einfÅgen nur mit !, Memory Dump ASC
               Anzeige aus Puffer.
10.12.91 2.01  Fehler bei IKBDSYS Aufwecken raus.
               Fehler bei OverScan TT raus.
               Breakpoints setzen auch nach Aufruf von SysMon.
11.12.91 2.01  Fehler bei $xx(PC,Dx.x) Adressierungsart raus.
               Interrupt Level von 7 auf 5 runter wenn Monitorschirm durch
               MonScrnUpdate geupdated wird.
14.2.92 2.02·A Korrektur der TestMMU Routine, getrenntes Ein- und Ausschalten
               der MMU Buserror abhÑngig ob TempleMon aktiv oder inaktiv.
19.2.92 2.02·B Protokoll der Buserror durch MMU falls TempleMon inaktiv.
24.2.92 2.02ûC NMI und Spurious Interrupt auf interne Vektoren falls
               TempleMon aktiv
11.3.92 2.02ûD Symbole fÅr TempleMon
24.3.92 2.02ûE Korrekturen der Symbole
22.4.92 2.02ûF Korrektur von PTEST
25.4.92 2.02ûG Umschaltung auf MiNT Translation Tree
19.6.92 2.02ûH Kleine Korrektur bei A7 relativer Adreûangabe, Symbole dÅrfen
               nun nicht mehr einen Punkt enthalten, da dies als das Ende
               betrachtet wird
29.6.92 2.02ûJ Umschaltung statt auf MiNT translation tree auf einen eigenen,
               der aber nur nachtrÑglich eingehÑngt werden kann!
15.7.92 2.02ûK Umschaltung auf eigene Video Routinen!
04.8.92 2.02ûL Korrektur der Copy Routine
15.10.92 2.02ûM nachtrÑgliches Starten des Symboltreiber fÅr nicht zum Default
               Disassemblie ohne Symbole. Neuer Befehl M-/M+.
28.10.92 2.02ûN Eigene 118 MFP Interruptroutine mit Sprung auf TOS
               IKBDSYS/MIDISYS falls MonActive.
06.01.93 2.02ûO CookieRoutine24 verÑndert! Korrekturen beim Anspringen der
               Routinen deren Zeiger mit CookieRoutine 24 Åbergeben werden.
20.01.93 2.02ûP Aufruf der Funktionen SwitchTMonScreen, SwitchOrgScreen,                AskVideoAddress korrigiert; Korrektur des 'D' Befehls beim
               Tracen; Korrektur des Protokolls wenn mehr als 80 Zeichen pro
               Zeile.
17.02.93 2.02Q Korrektur beim Disassembler (FMOVEM.X), Einbau der FALCON030
               UnterstÅtzung, Aufbau einer 68030 Tabelle ohne Memory Protection
               fÅr MultiTOS 1.0
21.02.93 2.02R Korrektur der FALCON Anpassung - noch keine Farbmanipulation                bei FALCON030
24.02.93 2.02S Korrektur der FALCON Anpassung - mit Farbmanipulation
26.02.93 2.02T énderungen an der Synchronisation bei FALCON030 Umschaltung
13.04.93 2.02U Bei nicht TT Rechner wird zunÑchst ein Mxalloc bei der
               Bildschirmspeicherplatzanforderung versucht.
15.06.93 2.02  Letze Betaversion herausgegen.
15.04.95 2.03  (TT) Mac-Version eingebunden.
14.07.95 2.04  AUTO-Ordner-Mac-Version released.
14.06.96 2.05  LÑuft nun auch im 256 Farb-Modus
----------------------------------------------------------------------------*)
(* Traceroutine: wenn Abbruch, wird z.Zt. D7 nicht nach TrcStat zurÅck-
   gespeichert ! *)
(* Hinter TrcCtC2 wird SR getestet, aber ist es denn immer schon richtig ge-
   setzt, oder wird es bei CGo nochmal vielleicht verÑndert ??? *)


(* Registerverwendung innerhalb der Prozedur MONITOR:

   D0: Enthaelt meist das letzte geholte Zeichen aus dem Eingabepuffer.

   D3: COU: enthÑlt Registerauswahl, die in Eingabepuffer steht. Bit 31 gibt
         dabei an, daû das SR mit 'F..' gewÑhlt wurde.

   A5: Enthaelt ^ auf Ende der Zeichen im Eingabepuffer.

   A6: Enthaelt ^ in Eingabepuffer auf letztes geholtes Zeichen.

   D7: in den Traceroutinen enthÑlt es die Variable TrcStat,
       sonst nur Flags ( ganzes Longword ); Wirkung bei gesetzten Flags:
       Bit 0: Bei PRTREG (Ausgabe der Register) sollen nur die Registernamen
              ausgegeben werden.
       Bit 1: Wird von GETAE (holen von Anf./End-Adr.) gesetzt, wenn keine
              Endadr., sondern eine Zeilenanzahl gewaehlt wurde.
       Bit 2: Bei GETAE (s.o.):
                In A2 steht die Anf.-Adr.
              Bei PRTREG (gibt Reg. aus, Nummer (TNr..) in D2):
                SR als Flags anzeigen
              Bei BERREGNR (bestimmt ausgewaehltes Register z.B. 'A2'
              und schreibt Tabellennummer nach D2 ):
                Es wurde ein Flag (mit z.B. 'FC') gewaehlt und die
                entsprechende Flagnummer steht in D2.
       Bit 3: Bei GETAE (s.o.):
                In A3 steht die End-Adr.
              Bei BERREGNR:
                Es wurde 'REG.EXT=' als Register statt 'REG=' eingegeben.
       Bit 4: Bei BERREGNR (s.o.):
                Auf Zuweisung der Register abfragen und evtl. zuweisen.
              Bei GETFNDBF (legt Suchstring byteweise in FindBuf ab):
                wird nur intern benutzt.
       Bit 5: Bei CheckRegNr
                A7 wurde in entsprechend aktives Stapelregister umgesetzt.
       Bit 6: Bei PRTREG/CRU:
                Letzte Registerausgabe war 'Registername : Bitbezeichnungen'
                Bei nÑchster Ausgabe von normalen Registern muû eine neue
                Zeile erzeugt werden.
       Bit 7: Bei ComdG ( 'G'-Kommando ):
                Nur interne Benutzung.
              Bei COU:
                Unterscheidung der Registereingabe zwischen '.' (0) und
                ':' (1).
       Bit 8: Bei PRTREG/PRTSRBIN (SR anzeigen):
                Nur T-Flag anzeigen.
       Bit 9: Bei CRU (Reg-Ausgabe - Upro ):
                Nur interne Benutzung.
       Bit 10:Bei PRTREG/CRU:
                Nur interne Benutzung (ob tabellarische Ausgabe von D0-A7).
       Bit 11:Bei Aufruf von PRTCRLF soll kein LF ausgeben werden.
       Bit 12:Bei Aufruf von GETADRG / GETAE soll nicht auf gerade
                Zahlen gerundet werden.
       Bit 13:PRT: nÑchstes Ascii-Zeichen soll nicht als Controlzeichen
                ausgegeben werden
       Bit 14:Wird von GETNGRKL / GETLGRKL gesetzt, wenn
                letztes geholtes Zeichen ein COMMENT ist.
       Bit 15:Wird von GETNGRKL / GETLGRKL gesetzt, wenn
                letztes geholtes Zeichen ein CR oder ein COMMENT ist.
       Bit 16: PRT: Das nÑchste CR wird bei Druckerausgabe unterdrÅckt.
       Bit 17
          -26:Nicht benutzt.
       Bit 27
          -31:Interne Verwendung beim Disassembler.


   Aufbau des Bildschirmspeichers zur Speicherung der Character:

   bMonScreenTop   ---->           +----------------------------+
   (zeigt auf das erste nicht      |                            |
    mehr zum Speicherbereich       |                            |
    gehîrende Byte)                |                            |
   bMonScreenEnd   ---->           +----------------------------+
                                   | 25.Zeile         S         |
                                   | 24.Zeile         i         |
                                   | 23.Zeile         c         |
                                   |    .             h         |
                                   |    .             t         |
                                   |    .             b         |
                                   |    .             a         |
                                   |  1.Zeile         r         |
   bMonScreen      ---->           +----------------------------+
                                   |                            |
                                   |                            |
   bMonScreenBase  ---->           +----------------------------+
   (zeigt auf das erste zum
    Speicherbereich gehîrende
    Byte)

   Befindet sich der sichtbare Bereich am Anfang des Speichers, ist
              bMonScreenStop == bMonScreen,
   Befindet sich der sichtbare Bereich am Ende des Speichers, ist
              bMonScreenStop == bMonScreenEnd.

   bMonScreenUsed zeigt auf das Ende des genutzten Pufferbereiches.

   Eine Zeile enthÑlt Rows-Anzahl an Bytes fÅr die Zeichen, sonst nichts.
   Die jeweils nÑchste/letzte Zeile wird durch addieren/subtrahieren von Rows
   zum jeweiligen Zeilenbeginn erreicht. Das Scrollen des Bildes wird durch
   Umsetzen der Pointer bMonScreen/bMonScreenEnd nach dem Ringpufferprinzip
   realisiert.
*)


TYPE Rect = RECORD
        top, left, bottom, right: CARDINAL;
END;

TYPE PixMap = RECORD
        baseAddr: ADDRESS;
        rowBytes: CARDINAL;
        bounds: Rect;
END;

TYPE PtrPixMap = POINTER TO PixMap;

TYPE MgMcCookie = RECORD
        vers: CARDINAL;
        size: CARDINAL;
        flags1: LONGCARD;
        scrnPMPtr: PtrPixMap;
        updatePalette: POINTER TO CHAR;
        modeMac: PROC;
        modeAtari: PROC;
        getBaseMode: PROC;
        getIntrCount: PROC;
        intrLock: PROC;
        intrUnlock: PROC;
        callMacContext: PROC;
        atariZeroPage: ADDRESS;
        macA5: ADDRESS;
        macAppSwitch: PROC;
        controlSwitch: PROC;
        hwAttr1: LONGCARD;
        hwAttr2: LONGCARD;
        magiC_BP: ADDRESS;
        auxOutName: ADDRESS;
        auxInName: ADDRESS;
        auxControl: PROC;
END;

(* globale Variablen *)
(* ***************** *)


PROCEDURE MONITOR;

(* LAGE ALLER WICHTIGEN EXCEPTION-VEKTOREN IM SYSTEMRAM *)

CONST
(*$? NOT Debug: magic    = 'TMon'; *)
(*$?     Debug: magic    = 'tmON'; *)

         TMonVersion = $00000203L;
         TMonDatum   = $04111995L;  (* Format : Monat Tag Jahr *)

         Tabulator   = 8;
         SR_TAB      = 6;
         RegPos      = 7;
         FP1TAB      = 7;
         FP2TAB      = 39;

         BUSERRV  = $08L;
         ADRERRV  = $0CL;
         ILLCMDV  = $10L;
         DIVZV    = $14L;
         CHKV     = $18L;
         TRAPVV   = $1CL;
         PRIVV    = $20L;
         TRACEV   = $24L;
         EM1010V  = $28L;
         EM1111V  = $2CL;
         COPPROV  = $34L;
         FRMERRV  = $38L;
         UNININTV = $3CL;
         ILLIRQV  = $60L;
         IRQ1V    = $64L; (* wird f. Mon-Direkteinsprung benutzt *)
         IRQ2V    = $68L;
         IRQ3V    = $6CL;
         IRQ4V    = $70L;
         IRQ5V    = $74L;
         IRQ6V    = $78L;
         IRQ7V    = $7CL;
         Trap0V   = $80L;
         Trap3V   = $8CL;
         Trap6V   = $98L;
         UCONDV   = $C0L;
         INEXACTV = $C4L;
         FPUDIVZV = $C8L;
         UFLOWV   = $CCL;
         OPERRV   = $D0L;
         OFLOWV   = $D4L;
         NANV     = $D8L;
         UNIMDAV  = $DCL;
         MMUCONFV = $E0L;

         MidiKeyV = $118L; (* ADC: Keyboard/ Midi IRQ-Vector *)
(*       USRBPV   = $41CL; *)

         MacNMIFlag = $C2C; (* Byte auf Mac-Seite *)
         MacCPUFlag = $12F; (* Byte auf Mac-Seite *)
         
         etv_critic = $404L;
         end_os     = $4FAL;

CONST    codelen  = 12;
         datalen  = 20;
         bsslen   = 28;

         PROMPT   = '!';
         ASCPRMPT = $27;
         COMMENT  = '|';
         JOKER    = '?';
         OFFSCHAR = 'O';
         ZEILLEN  = 80; (* LéNGE EINER BILDSCHIRMZEILE *)
         HDUMPANZ = 16; (* ANZAHL Bytes BEI HEX-DUMP *)
         ADUMPANZ = 64; (* ANZAHL BYTES BEI ASCII-DUMP *)
         ASCDUMPX = 0;  (* ANZAHL SPACES NACH HEX-DUMP BIS ASCII-ANZEIGE *)

         CARRY    = 1;
         OVERFLOW = 2;
         ZERO     = 4;
         NEGZERO  = -4;
         MINUS    = 8;
         NEGMINUS = -8;
         EXTEND   = 16;

         BSKey    = 8;    (* Tastencodes fÅr editierbare Kommandozeile *)
         DelKey   = 127;

(*$? ~MAC:
         CurRKey  = $15;
         CurLKey  = $14;
         InsKey   = $16;
         HomeKey  = $10;
         EndKey   = $11;
         WordRKey = $13;
         WordLKey = $12;
         WordHome = $17;
         WordEnd  = $18;
         StartKey = $19;
         ClearKey = $F0;
         BStartKey= $F1;
         AHomeKey = $F2;
         BEndeKey = $F3;
         PgUpKey  = $F4;
         PgDnKey  = $F5;
*)

(*$? MAC:
         CurRKey  =  29;
         CurLKey  =  28;
         InsKey   =   5;
         HomeKey  =   1;
         EndKey   =   4;
         WordRKey = $F6;
         WordLKey = $F7;
         WordHome = $F8;
         WordEnd  = $F9;
         StartKey = $FA;
         ClearKey = $F0;
         BStartKey= $F1;
         AHomeKey = $F2;
         BEndeKey = $F3;        (* last line of buffer *)
         PgUpKey  =  11;
         PgDnKey  =  12;
*)

         ESCKey   = 27;
         SysMonKey = 98;
         SysMonMask = 2;
         UndoKey  = 97;

         CR       = $D;
         LF       = $A;
         FF       = $C;
         BS       = $8;
         ClEol    = $1;
         ClEoS    = $2;
         Con      = $4;
         Coff     = $5;
         SPC      = ' ';
         relFchr  = '@';

         BEFJMP   = $4EF9;
         BEFBRK   = $4AFC;
         BEFRTS   = $4E75;
         BEFRTE   = $4E73;
         BEFRTR   = $4E77;

  (* Tabellennummern der Reg. fuer Anzeige, es reicht aber nicht,
     nur diese zu aendern. (Siehe Kommentare - nach den Variablen suchen! ) *)
         TNRSR    = 0;
         TNRD0    = 1;
         TNRA0    = 9;
         TNRA7    = 16;
         TNRPC    = 17;
         TNRUSP   = 18;
         TNRSSP   = 19;
         TNRBER   = 20;
         TNRAER   = 21;

         TNRLAST00 = 21;

         TNRSFC   = 22;
         TNRDFC   = 23;
         TNRVBR   = 24;

         TNRLAST10 = 24;

         TNRMSP   = 25;
         TNRISP   = 26;
         TNRCAAR  = 27;
         TNRCACR  = 28;

         TNRLAST20 = 28;

         TNRTT0   = 29;            (* bei 68040 ITT0 *)
         TNRTT1   = 30;            (* bei 68040 ITT1 *)
         TNRTC    = 31;


         TNRPSR   = 32;            (* bei 68030 nur 16 Bit groû *)
         TNRCRP   = 33;            (* 64 Bit groû; bei 68040 URP *)
         TNRSRP   = 34;            (* 64 Bit groû, bei 68040 32 Bits *)

         TNRLast30 = 34;

         TNrFirstFPU = 35;

         TNRFP0   = 35;            (* 64 Bit gross *)
         TNRFP1   = 36;
         TNRFP2   = 37;
         TNRFP3   = 38;
         TNRFP4   = 39;
         TNRFP5   = 40;
         TNRFP6   = 41;
         TNRFP7   = 42;
         TNRFPCR  = 43;            (* 32 Bit gross *)
         TNRFPSR  = 44;
         TNRFPIAR = 45;

         TNrLastFPU = 45;

         TNRDTT0 = 46;
         TNRDTT1 = 47;
         TNrITT0 = 48;
         TNrITT1 = 49;
         TNrURP  = 50;

         TNrLast40 = 50;

         RegSaveSize = $116;  (* 504 *)

(*$ ? ExtendedKeys:
CONST     iorec           = $e;     (* XBios Funktionen *)
          kbdvbase        = 34;
          xbios           = 14;
          memvalid        = $420;   (* Systemvariablen *)
          resvalid        = $426;
          memval2         = $43a;
          _sysbase        = $4f2;
          memval3         = $51a;
*)

VAR
      LBLBEG         : CARDINAL;                 (* Dummy - Wort, nicht loeschen ! *)

      DBuffer        : ARRAY [0..169] OF CHAR;    (* zehn Zeichen zur Sicherheit *)
      DBufLong       : CARDINAL;
      DTemp          : LONGCARD;
      DReturn        : LONGCARD;
      DCursorX       : CARDINAL;
      DCode          : CARDINAL;

      TMON_debug     : LONGCARD;
      ResetDebug     : CARDINAL;
      inTMonBUSerr   : CARDINAL;
      oldNMI         : LONGCARD;
      oldSpur        : LONGCARD;
      OSTT           : LONGCARD;
      SYMB           : LONGCARD;
      MiNT_Cookie    : LONGCARD;
      Symbolic       : CARDINAL;
      GetSymbolName,
      GetSymbolValue : LONGCARD;
      OnLineHelp     : LONGCARD;
      Makros         : LONGCARD;
      HelpBasePage   : LONGCARD;

      ADRsemaphor               : CARDINAL;
      onlyTOSvec                : CARDINAL;
(* Farbpaletten : *)
      farbe                     : ARRAY [0..3] OF LONGCARD;
      farbe2                    : ARRAY [0..3] OF LONGCARD;

      video_plane               : CARDINAL; (* Mon-Bittiefe, Mac: 1 oder 8 *)
      video_rowbytes            : CARDINAL;
      orig_rowbytes             : CARDINAL;
      video_vischars            : CARDINAL;
      orig_visbytes             : CARDINAL;
      video_lines               : CARDINAL;
      video_memsize             : LONGCARD; (* grîûe des Screen-Puffers im monochrom-Modus *)
      orig_screen_size          : LONGCARD; (* grîûe des Screen-Puffers unter MagiCMac *)
      tmon_offset               : LONGCARD;
      share_screen              : CARDINAL;
      restore_screen_flag       : CARDINAL;
      video_size                : LONGCARD;
      pVisScreen                : LONGCARD;
      pOffScreen                : LONGCARD;

      TT_Shift_Mode             : CARDINAL; (* Shift Modus Register des TT *)
      entry_video_modus         : CARDINAL; (* OverScanModus beim Aufruf von TempleMon? *)
      entry_video_modus2        : CARDINAL; (* OverScanModus beim Aufruf von TempleMon? *)
      video_modus               : CARDINAL; (* OverScan oder Normal nutzen? Mac: $FF00 *)
      autoswitch                : CARDINAL; (* AutoSwitch Hardware ? Mac: $0000 *)

         IsMonScreen: CARDINAL; (* Flag *)
         currMacDepth: LONGCARD; (* Hi-Word: Mono/Color, Lo-Word: Depth *)
         origMacDepth: LONGCARD; (* Hi-Word: Mono/Color, Lo-Word: Depth *)
          
         old_sync  : CARDINAL;

         EditModus : CARDINAL;

         KEYBUF  : ARRAY [0..ZEILLEN] OF CHAR;
         KEYBUF2 : ARRAY [0..ZEILLEN] OF CHAR;
         DUMPBUF : ARRAY [0..8] OF CARDINAL;

         longREG : CARDINAL;

         originalA5, originalA7: LONGCARD;

         REGBEG  : CARDINAL; (* Leerwort fuer Ausgleich des Wortes f. d. SR *)

         (* Achtung : Reihenfolge nicht vertauschen ! *)
         RgSR    : ARRAY [1..1] OF CARDINAL;
         RgD0    : ARRAY [0..11] OF LONGCARD;
         RgA4    : ARRAY [4..5] OF LONGCARD;
         RgA6    : ARRAY [6..6] OF LONGCARD;
         RgA7    : ARRAY [7..7] OF LONGCARD; (* RgA7 unbenutzt, dummy f. SSP/USP *)
         RgPC    : ARRAY [1..1] OF LONGCARD;
         RgUSP   : ARRAY [1..1] OF LONGCARD;
         RgSSP   : ARRAY [1..1] OF LONGCARD;
         RgBEV   : ARRAY [1..1] OF LONGCARD;
         RgAEV   : ARRAY [1..1] OF LONGCARD;

         RgSFC   : ARRAY [1..1] OF LONGCARD;
         RgDFC   : ARRAY [1..1] OF LONGCARD;
         RgVBR   : ARRAY [1..1] OF LONGCARD;

         RgMSP   : ARRAY [1..1] OF LONGCARD;
         RgISP   : ARRAY [1..1] OF LONGCARD;
         RgCAAR  : ARRAY [1..1] OF LONGCARD;
         RgCACR  : ARRAY [1..1] OF LONGCARD;

         RgTT0   : ARRAY [1..1] OF LONGCARD;
         RgTT1   : ARRAY [1..1] OF LONGCARD;
         RgTC    : ARRAY [1..1] OF LONGCARD;
         RgPSR   : ARRAY [1..1] OF LONGCARD;
         RgCRP   : ARRAY [1..2] OF LONGCARD;
         RgSRP   : ARRAY [1..2] OF LONGCARD;

         RgFP0   : ARRAY [1..6] OF CARDINAL;
         RgFP1   : ARRAY [1..6] OF CARDINAL;
         RgFP2   : ARRAY [1..6] OF CARDINAL;
         RgFP3   : ARRAY [1..6] OF CARDINAL;
         RgFP4   : ARRAY [1..6] OF CARDINAL;
         RgFP5   : ARRAY [1..6] OF CARDINAL;
         RgFP6   : ARRAY [1..6] OF CARDINAL;
         RgFP7   : ARRAY [1..6] OF CARDINAL;
         RgFPCR  : ARRAY [1..1] OF LONGCARD;
         RgFPSR  : ARRAY [1..1] OF LONGCARD;
         RgFPIAR : ARRAY [1..1] OF LONGCARD;

         RgDTT0  : ARRAY [1..1] OF LONGCARD;
         RgDTT1  : ARRAY [1..1] OF LONGCARD;
         RgITT0  : ARRAY [1..1] OF LONGCARD;
         RgITT1  : ARRAY [1..1] OF LONGCARD;
         RgURP   : ARRAY [1..1] OF LONGCARD;

         RgSF    : CARDINAL;

         RgCEV   : LONGCARD;

         StFrame : ARRAY [0..55] OF LONGCARD;      (* 216+4 Bytes fÅr 68882 *)

         (* Achtung : Reihenfolge nicht vertauschen ! *)
         TRCSTAT : ARRAY [1..1] OF CARDINAL;
         TRCSVSP : ARRAY [1..1] OF LONGCARD;
         TRCSTAT2: ARRAY [1..1] OF CARDINAL;

         MonActive : CARDINAL;  (* nur 1.Byte *)

         UsrBP   : LONGCARD;

CONST    BPanz = 8;

VAR      (* Achtung : Reihenfolge nicht vertauschen ! *)
         BP      : ARRAY [0..7] OF LONGCARD;
         BPC     : ARRAY [0..0] OF CARDINAL;
         BPCA    : ARRAY [0..0] OF CARDINAL;
         BPDUMMY : ARRAY [1..7] OF LONGCARD;
         BPSV    : ARRAY [0..7] OF CARDINAL;
         BPSTAT  : ARRAY [0..0] OF CARDINAL;
         BPset   : CARDINAL;
         BPquest : CARDINAL;

CONST    ShBPanz = 9;

VAR      ShBPcnt : CARDINAL;
         ShBP    : ARRAY [1..ShBPanz] OF LONGCARD;
         ShBPsv  : ARRAY [1..ShBPanz] OF CARDINAL;
         ShBPFlg, (* Byte *)
         ShBPStat: CARDINAL;


         REGWAHL : LONGCARD;   (* Bit 31 : SR als Flags anzeigen (nur gÅltig,*)
                               (*  wenn auch SR-Bit gesetzt) *)
         REGWAHL2 : LONGCARD;

         RegSave : ARRAY [0..RegSaveSize+4] OF LONGCARD;


         (* Achtung : Reihenfolge nicht vertauschen ! *)
         ADOFFSET : LONGCARD;
         LASTMA   : LONGCARD;
         LASTME   : LONGCARD;
         LASTDA   : LONGCARD;
         LASTDE   : LONGCARD;
         LASTIA   : LONGCARD;
         LASTIE   : LONGCARD;
         Hilf1L   : LONGCARD;
         Hilf1LE  : LONGCARD;
         LASTLSA  : LONGCARD;
         LASTLSE  : LONGCARD;

         TestMMUTemp : LONGCARD;
         MMUMSG   : LONGCARD;

         RWhandle,
         Prhandle : CARDINAL;

         FileStart,
         FileLen,
         MemLen   : LONGCARD;
         MemAdr   : LONGCARD;  (* wenn # 0, dann Block angefordert *)
         OverWrite: CARDINAL; (* oberes Byte, bool *)

         ValExp   : CARDINAL; (* oberes Byte, bool *)

         DisPrt   : CARDINAL;

         isFALCON030,
         isSTE,               (* zusÑtzliche Videoregister bei STE *)
         isTT,                (* neue Grafik bei TT. Mac: 0 *)
         is10,                (* wenn 68010 oder hîher *)
         is20,                (* wenn 68020 oder hîher *)
         is30,                (* wenn 68030 (oder hîher) *)
         is40,                (* wenn 68040 *)
         isFPU,               (* wenn 68881/2 FPU *)
         Unknown,             (* unbekannte Videoauflîsung *)

         isD10, isD20, isD30, isD40, isDFPU,
         isCD10, isCD20, isCD30, isCD40, isCDFPU,
         noScrolling,
         HisClear,
         HisUsed: CARDINAL;

         SwitchTMonScreen, SwitchOrgScreen, AskVideoAddress : LONGCARD;

         origRes: CARDINAL;
         physAdr, logAdr: LONGCARD;

         macShift,
         NoScrDisp,
         ch       : CARDINAL;

         Rows,
         Lines,
         CharHeight,
         CharWidth,
         CursorX,
         CursorY     : CARDINAL;
         CursorState : BOOLEAN;
         CursorCnt   : LONGCARD;

         SUPSR   : CARDINAL;
         ERRADR  : LONGCARD;
         ERRBEF  : LONGCARD;

         ExcNo   : CARDINAL;
         ENTRYMSG: LONGCARD;
         EntryNr : CARDINAL;
         ENTRYMOD: CARDINAL; (* NUR 1.BYTE; BITS: 0:BUS-,ADRERR, 1:EntryNr. ausgeben *)

         FindBuf : ARRAY [0..32] OF CHAR;

         REALSTR   : ARRAY [0..24] OF CHAR;
         REALREAL  : ARRAY [0..6] OF CARDINAL;
         pendingA,
         pendingB,
         serviceA  : CARDINAL;

         savedKBDVec               : LONGCARD;
         savedKBDVec2              : LONGCARD;
         RestoreKBDVec             : CARDINAL;
         Restore2KBDVec            : CARDINAL;
         KBDState                  : CARDINAL;

         SysMonSemaphor            : LONGCARD;
         SysMonAdresse             : LONGCARD;
         SysMonStack               : LONGCARD;
         SysMonCall                : CARDINAL;  (* Aufruf durch SysMon *)
         TempleMonCall             : CARDINAL;  (* Aufruf von SysMon durch TempleMon *)
         KeyCall                   : CARDINAL;  (* Aufruf von Tastatur *)

         Response                  : CARDINAL;

         BusPC,BusFA               : LONGCARD;
         BusPR                     : CARDINAL;

         TMon_URP                  : ARRAY[0..1] OF LONGCARD;
         TMon_SRP                  : ARRAY[0..1] OF LONGCARD;
         TMon_TC                   : LONGCARD;
         TMon_DTT0                 : LONGCARD;
         TMon_DTT1                 : LONGCARD;
         TMon_ITT0                 : LONGCARD;
         TMon_ITT1                 : LONGCARD;
         TMon_Tree                 : CARDINAL;
         TMon_Get_Tree             : LONGCARD;

         Kbdv_base: LONGCARD;
         StkFrm   : CARDINAL; (* Stackframe: 0 bei 68000, 2 ab 68010 *)

         TOSMIDI, TOSIKBD : LONGCARD;

(*$ ? ExtendedKeys:
         CallFlag     : CARDINAL;
         LockFlag     : CARDINAL;
         IorecPointer : LONGCARD;
*)


         LBLEND  : CARDINAL;                 (* Dummy - Wort *)

         noUpdate  : CARDINAL;

         FALCON030MonitorType,FALCON030_VFT,FALCON030_VBB,FALCON030_VBE,
         FALCON030_VDB,FALCON030_VDE,FALCON030_VSS,FALCON030_HHT,FALCON030_HBB,
         FALCON030_HBE,FALCON030_HDB,FALCON030_HDE,FALCON030_HSS,FALCON030_HFS,
         FALCON030_HEE,FALCON030_VXX,FALCON030_VCO,FALCON030_VWRAP,FALCON030_VWR2,
         FALCON030_ST_SHIFT,FALCON030_SP_SHIFT,FALCON030_EXTCLK,FALCON030_dummy1,
         FALCON030ScreenVisible,FALCON030_dummy2 : CARDINAL;

         MonStackHi: LONGCARD;

LastLocalVar : CARDINAL;    (* muss immer am Ende der Vars stehen ! *)

BEGIN
ASSEMBLER
StartOfMon
          BRA.L   INITGMON

RoutinenPointer
          DC.W    3
          DC.W    PRT_Routinen
          DC.W    GET_Routinen
          DC.W    TST_Routinen
          DC.W    0
PRT_Routinen
          DC.W    36
          DC.W    PRTPRMPT
          DC.W    PRTPRMPT1
          DC.W    PRTNEWPRMPT
          DC.W    PRTNEWPRMPT1
          DC.W    PRTNEWLINE
          DC.W    PRT
          DC.W    PRTCR
          DC.W    PRTCRLF
          DC.W    PRTDCRLF
          DC.W    PRTSPC
          DC.W    PRTMSPC
          DC.W    PRTREAL
          DC.W    PRTSTR
          DC.W    PRTADR
          DC.W    PRTLONGXL
          DC.W    PRTLONG
          DC.W    PRTWORD
          DC.W    PRTBYTE
          DC.W    PRTNIBL
          DC.W    PrintErr
          DC.W    PRTREG
          DC.W    PRTREGBIN
          DC.W    PRTSRBIN
          DC.W    PRTCBIN
          DC.W    PRTPSRBIN
          DC.W    PRTTCBIN
          DC.W    PRTCRPBIN
          DC.W    PRTSRPBIN
          DC.W    PRTTT0BIN
          DC.W    PRTITT0BIN
          DC.W    PRTDTT0BIN
          DC.W    PRTTT1BIN
          DC.W    PRTITT1BIN
          DC.W    PRTDTT1BIN
          DC.W    PRTFPCRBIN
          DC.W    PRTFPSRBIN
          DC.W    0
GET_Routinen
          DC.W    17
          DC.W    GETNGRKL
          DC.W    GETLGRKL
          DC.W    SKIPSPC
          DC.W    SKIPSPCN
          DC.W    GETREAL
          DC.W    GETLONGXL
          DC.W    GETLONGX
          DC.W    GETLONGO
          DC.W    GETLONG
          DC.W    GETWORD
          DC.W    GETBYTE
          DC.W    GETADRG
          DC.W    GETADR0
          DC.W    GETADR
          DC.W    GETAE
          DC.W    GET3ADR
          DC.W    GETFNDBF
          DC.W    0
TST_Routinen
          DC.W    8
          DC.W    TSTHZIFF
          DC.W    TSTDZIFF
          DC.W    TSTRZIFF
          DC.W    TSTADR
          DC.W    TSTNCR
          DC.W    TSTKEY
          DC.W    WAITKEY
          DC.W    CAPS
          DC.W    0

(*$? MAC:
eventRecord:
ev_what:  dc.w      0
ev_msg:   dc.l      0
ev_when:  dc.l      0
ev_where: dc.l      0
ev_mod:   dc.w      0

!CONSTAT  move.l    a5,-(a7)
          move.l    originalA5(A4),A5
          bsr.w     mode_mac
          moveq     #3,d0       ; DebuggerPoll
          dc.w      $A08D       ; _DebugUtil
          move.w    #8,d0       ; eventMask = keyDownMask
          lea       eventRecord(PC),a0
          dc.w      $A030       ; _OSEventAvail
          bsr.w     mode_atari
          move.l    (a7)+,a5
          move.w    ev_what(PC),d0
          cmpi      #3,d0
          seq       d0
          ext.w     d0
          ext.l     d0
          ;moveq     #1,d0
          rts

!DIRCONIN move.l    a5,-(a7)
          move.l    originalA5(A4),A5
          BSR.W     mode_mac
          moveq     #3,d0       ; DebuggerPoll
          dc.w      $A08D       ; _DebugUtil
          move.w    #8,d0       ; eventMask = keyDownMask
          lea       eventRecord(PC),a0
          dc.w      $A031       ; _GetOSEvent
          BSR.W     mode_atari
          move.l    (a7)+,a5
          move.w    ev_what(PC),d0
          cmpi      #3,d0
          bne       DIRCONIN
          move.l    ev_msg(PC),d0
          rts

kbconvert dc.b      31,31,31,31,31,31,31,6,0,1,4,3,2
          SYNC

!KbShift  move      d1,-(a7)
          move      d2,-(a7)
          moveq     #12,d2
          clr       d0
kbconlup  move.w    ev_mod(PC),d1
          btst      d2,d1
          beq       kbconnxt
          move.b    kbconvert(pc,d2.w),d1
          bset      d1,d0
kbconnxt  dbra      d2,kbconlup
          move      (a7)+,d2
          move      (a7)+,d1
          rts
*)

(*$? ~MAC:
!CONSTAT  move.w    sr,-(sp)
          ori.w     #$0700,sr
          move.l    a0,-(sp)            ; ADC: {
          move.l    KeyIORcV(pc),a0     ; Adresse des Keyboard-Buffers,
          move.w    8(a0),d0            ; + offset = nÑchste leseposition
          cmp.w     6(a0),d0            ; Buffer gefÅllt worden ?
          sne       d0
          ext.w     d0
          ext.l     d0
          move.l    (sp)+,a0
          move.w    (sp)+,sr
          rts                           ; }

!DIRCONIN move.w    sr,-(sp)
          ori.w     #$0700,sr
          movem.l   a0/a1,-(sp)         ; ADC: {
          move.l    KeyIORcV(pc),a0     ; Adresse des Keyboard-Buffers,
          move.w    8(a0),d0            ; + offset = nÑchste leseposition
          move.l    (a0),a1             ; Bufferadresse nach a1
          move.l    0(a1,d0.w),d0       ; SCAN / ASCII - Kode holen
          move.w    8(a0),6(a0)         ; Zeichen fÅr TOS verschwundibus
          movem.l   (sp)+,a0/a1
          move.w    (sp)+,sr
          rts                           ; }

!KbShift  move.l    a0,-(sp)            ; ADC: {
          move.l    KbshiftV(pc),a0     ; Adresse des Shift-Status-Byte holen
          moveq     #0,d0               ; Bits 31-8 lîschen
          move.b    (a0),d0             ; Status in Bits 7-0
          move.l    (sp)+,a0
          rts                            ; }
*)

; *** Offset Tabelle fÅr nÑchste Zeile bei pMonScreen und bMonScreen ***
;     FÅr TT Hoch muû der Offset um ein Bit nach links geschoben werden

(*$? ~MAC:
DispTable DC.L        0,   0,  1280,  80,  2560, 160,  3840, 240,  5120, 320
          DC.L     6400, 400,  7680, 480,  8960, 560, 10240, 640, 11520, 720
          DC.L    12800, 800, 14080, 880, 15360, 960, 16640,1040, 17920,1120
          DC.L    19200,1200, 20480,1280, 21760,1360, 23040,1440, 24320,1520
          DC.L    25600,1600, 26880,1680, 28160,1760, 29440,1840, 30720,1920
          DC.L    32000,2000
          DC.L                33280,2080, 34560,2160, 35840,2240, 37120,2320
          DC.L    38400,2400, 39680,2480, 40960,2560, 42240,2640, 43520,2720
          DC.L    44800,2800, 46080,2880, 47360,2960, 48640,3040, 49920,3120
          DC.L    51200,3200, 52480,3280, 53760,3360, 55040,3440, 56320,3520
          DC.L    57600,3600, 58880,3680, 60160,3760, 61440,3840, 62720,3920
          DC.L    64000,4000
          DC.L                65280,4080, 66560,4160, 67840,4240, 69120,4320
          DC.L    70400,4400, 71680,4480, 72960,4560, 74240,4640, 75520,4720
          DC.L    76800,4800
*)

; *** Pointer auf öberschreiten des physikalischen Anfangs des Buffers checken ***

!CHKBase  CMP.L   bMonScreenBase(PC),D0
          BGE.S   CHKBaseE                  ; grîûer oder gleich
          SUB.L   bMonScreenBase(PC),D0
          ADD.L   bMonScreenTop(PC),D0
!CHKBaseE RTS

; *** Pointer auf öberschreiten des physikalischen Endes des Buffers checken ***

!CHKTop   CMP.L   bMonScreenTop(PC),D0
          BLT.S   CHKTopE                   ; kleiner ohne gleich
          SUB.L   bMonScreenTop(PC),D0
          ADD.L   bMonScreenBase(PC),D0
!CHKTopE  RTS

; *** Screen-buffer bMonScreenEnd nach bMonScreen setzen ***

!SetbMonScreenEnd
          MOVE.L  bMonScreen(PC),D0
          ADD.L   bMonScreenSize(PC),D0
          BSR.S   CHKTop
          LEA     bMonScreenEnd(PC),A0
          MOVE.L  D0,(A0)
          RTS

; *** Screen-buffer bMonScreen nach bMonScreenEnd setzen ***

!SetbMonScreen
          MOVE.L  bMonScreenEnd(PC),D0
          SUB.L   bMonScreenSize(PC),D0
          BSR.S   CHKBase
          LEA     bMonScreen(PC),A0
          MOVE.L  D0,(A0)
          RTS

; *** Screen-buffer um eine Zeile nach unten bewegen ***
; *** entspricht einem ScrollUp!                     ***

!MoveScrnBufDn
          MOVEM.L A0/D0/D1,-(SP)
          CLR.L   D1
          MOVE.W  Rows(A4),D1
!MoveScrnBufDn1
          MOVE.L  bMonScreen(PC),D0
          SUB.L   D1,D0
          BSR.S   CHKBase
          LEA     bMonScreen(PC),A0
          MOVE.L  D0,(A0)
          BSR.S   SetbMonScreenEnd
          MOVEM.L (SP)+,A0/D0/D1
          RTS

; *** Screen-buffer um eine Seite nach unten bewegen ***
; *** entspricht einem ScrollUp!                     ***

!ScrollScrnBufDn
          MOVEM.L A0/D0/D1,-(SP)
          MOVE.L  bMonScreenSize(PC),D1
          BRA.S   MoveScrnBufDn1


; *** Screen-buffer um eine Zeile nach oben bewegen ***
; *** entspricht einem ScrollDown!                  ***

!MoveScrnBufUp
          MOVEM.L A0/D0,-(SP)
          CLR.L   D0
          MOVE.W  Rows(A4),D0
!MoveScrnBufUp1
          ADD.L   bMonScreen(PC),D0
          BSR.S   CHKTop
          LEA     bMonScreen(PC),A0
          MOVE.L  D0,(A0)
          BSR.S   SetbMonScreenEnd
          MOVEM.L (SP)+,A0/D0
          RTS

; *** Screen-buffer um eine Seite nach oben bewegen ***
; *** entspricht einem ScrollDown!                  ***

!ScrollScrnBufUp
          MOVEM.L A0/D0,-(SP)
          MOVE.L  bMonScreenSize(PC),D0
          BRA.S   MoveScrnBufUp1

; *** sichtbaren Screen-buffer auf Anfang des Buffers setzen ***

!SetScrnBufTop
          MOVEM.L A0/D0,-(SP)
          MOVE.L  bMonScreenUsed(PC),D0
          LEA     bMonScreen(PC),A0
          MOVE.L  D0,(A0)
          BSR     SetbMonScreenEnd
          MOVEM.L (SP)+,A0/D0
          RTS

; *** sichtbaren Screen-buffer auf Ende des Buffers setzen ***

!SetScrnBufButtom
          MOVEM.L A0/D0,-(SP)
          MOVE.L  bMonScreenStop(PC),D0
          LEA     bMonScreenEnd(PC),A0
          MOVE.L  D0,(A0)
          BSR     SetbMonScreen
          MOVEM.L (SP)+,A0/D0
          RTS

; *** Test ob Screen-buffer am oberen Ende des Ringpuffers ist ***

!TestTop  MOVE.L  bMonScreen(PC),D0
!TestTop01 CMP.L   bMonScreenUsed(PC),D0
          BEQ.S   TestTop3
!TestTop2 MOVEQ   #-1,D0
          RTS
!TestTop3 MOVEQ   #0,D0
          RTS

; *** Test ob Screen-buffer am unteren Ende des Ringpuffers ist ***

!TestButtom
          MOVE.L  bMonScreenEnd(PC),D0
!TestTop1 CMP.L   bMonScreenStop(PC),D0
          BEQ.S   TestTop3
          BRA.S   TestTop2

; *** Test ob Screen-buffer beim Scrollen das obere Ende
;     Åberschreiten wÅrde                                ***

!TestUp   MOVE.L  bMonScreen(PC),D0
          CMP.L   bMonScreenUsed(PC),D0
          BEQ     TestTop3                ; D0 := 0
          BCC.S   TestUp1                 ; Sprung bei grîûer
          ADD.L   bMonScreenSpace(PC),D0
TestUp1   SUB.L   bMonScreenSize(PC),D0
          CMP.L   bMonScreenUsed(PC),D0
          BLS     TestTop3                ; kleiner gleich : Fehler! (D0 := 0)
          BRA     TestTop2                ; D0 := -1

; *** Test ob Screen-buffer beim Scrollen das untere Ende
;     Åberschreiten wÅrde                                 ***

!TestDn   MOVE.L  bMonScreenEnd(PC),D0
          CMP.L   bMonScreenStop(PC),D0
          BEQ     TestTop3                ; D0 := 0
          BCS.S   TestDn1                 ; Sprung bei kleiner
          SUB.L   bMonScreenSpace(PC),D0
TestDn1   ADD.L   bMonScreenSize(PC),D0
          CMP.L   bMonScreenStop(PC),D0
          BHI     TestTop3                ; grîûer gleich : Fehler (D0 := 0)
          BRA     TestTop2                ; D0 := -1

; *** Character aus Screen-buffer lesen ***

(*$? ~MAC:
!ScrnGet
          LEA     DispTable(PC),A0         ; Zeichen aus Puffer holen
          MOVE.W  CursorY(A4),D0
          ASL.W   #3,D0
          MOVE.L  4(A0,D0.w),D0            ; immer nur 16 Bit Offsetinformation!
                                           ; d.h. das Highword wird gleich mitgelîscht
          ADD.W   CursorX(A4),D0           ; es wird niemals ein öbertrag auftreten!
          MOVE.L  bMonScreen(PC),A0
          ADDA.L  D0,A0
          MOVE.L  A0,D0
          SUB.L   bMonScreenTop(PC),D0
          BCS     ScrnGet1
          MOVE.L  bMonScreenBase(PC),A0
          ADDA.L  D0,A0
ScrnGet1  MOVE.B  (A0),D0
          ANDI.W  #$FF,D0
          RTS
*)

(*$? MAC:
!ScrnGet  MOVE.W  CursorY(A4),D0
          MULU    Rows(A4),D0
          MOVE.L  bMonScreen(PC),A0
          ADDA.L  D0,A0
          ADDA.W  CursorX(A4),A0
          MOVE.L  A0,D0
          SUB.L   bMonScreenTop(PC),D0
          BCS     ScrnGet1
          MOVE.L  bMonScreenBase(PC),A0
          ADDA.L  D0,A0
ScrnGet1  MOVE.B  (A0),D0
          ANDI.W  #$FF,D0
          RTS
*)


; *** Character auf Monitor-Screen darstellen ***
; Char in D0.B, Invers-Maske in D1.L (0 o. -1)
; (D0-D5/A0/A1)

(*$? MAC:

BitToByte ds      2048   ; = 256 * 8 byte
Is256Cols ds      2      ; 1. byte: 0 oder ff

!DispChar
          MOVE.L  D2,-(SP)                 ; sonst geht R Befehl nicht!
          MOVE.W  CursorY(A4),D2
          MULU    Rows(A4),D2
          MOVE.L  bMonScreen(PC),A1
          ADDA.L  D2,A1
          ADDA.W  CursorX(A4),A1
          MOVE.L  A1,D2
          SUB.L   bMonScreenTop(PC),D2
          BCS     DispChar1
          MOVE.L  bMonScreenBase(PC),A1
          ADDA.L  D2,A1
DispChar1 MOVE.B  D0,(A1)
          MOVE.L  (SP)+,D2

DispChar2 ANDI.L  #$FF,D0

Disp8_8   MOVE.L  D2,-(SP)
          MOVE.L  pFont8_8(PC),A0

          ; Font-^ auf richtiges Zeichen bestimmen:
          ADDA.W  D0,A0
          
          tst.b   Is256Cols(pc)
          beq.w   dispbw

(*
 * Ausgabe fÅr 256 Farben-Modus:
 *)
          ; Screenoffset := CursorY * rowbytes * lines_per_char + CursorX * 1
          MOVE.W  CursorY(A4),D0
          MOVE.L  pMonScreen(PC),A1
          MULU    video_rowbytes(A4),D0
          ASL.L   #3,D0                 ; lines per char: 8
          ADDA.L  D0,A1
          MOVEQ   #0,D0
          MOVE.W  CursorX(A4),D0
          LSL.L   #3,D0                 ; bytes per char: 8
          ADDA.L  D0,A1
          ADDA.L  tmon_offset(A4),A1

          MOVE.W  video_rowbytes(A4),D0
          MOVEM.L D1/D3/A1/A2,-(A7)
          LEA     BitToByte(PC),A2
          MOVEQ   #7,D1
dsp256l:  MOVEQ   #0,D2
          MOVE.B  (A0),D2
          LSL.W   #3,D2
          MOVE.L  0(A2,D2.W),(A1)
          MOVE.L  4(A2,D2.W),4(A1)
          ADDA.W  D0,A1
          ADDA.W  #$0100,A0
          DBRA    D1,dsp256l
          MOVEM.L (A7)+,D1/D3/A1/A2
          
          TST     D1
          BEQ.W   Disp8_9E

          TST.W   EditModus(A4)
          BPL.W   Disp8_9O

          EORI.L  #-1,(A1)
          EORI.L  #-1,4(A1)
          ADDA.W  D0,A1
          EORI.L  #-1,(A1)
          EORI.L  #-1,4(A1)
          ADDA.W  D0,A1
          EORI.L  #-1,(A1)
          EORI.L  #-1,4(A1)
          ADDA.W  D0,A1
          EORI.L  #-1,(A1)
          EORI.L  #-1,4(A1)
          ADDA.W  D0,A1
          EORI.L  #-1,(A1)
          EORI.L  #-1,4(A1)
          ADDA.W  D0,A1
          EORI.L  #-1,(A1)
          EORI.L  #-1,4(A1)
          ADDA.W  D0,A1
          EORI.L  #-1,(A1)
          EORI.L  #-1,4(A1)
          ADDA.W  D0,A1
          EORI.L  #-1,(A1)
          EORI.L  #-1,4(A1)

Disp8_9E  MOVE.L  (SP)+,D2
          RTS

Disp8_9O
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          EORI.L  #-1,(A1)
          EORI.L  #-1,4(A1)
          MOVE.L  (SP)+,D2
          RTS

dispbw:
(*
 * orig. s/w-Lîsung:
 *)
          ; Screenoffset := CursorY * 80/160 * 8/16 + CursorX * 1/2
          MOVE.W  CursorY(A4),D0
          
          ; D0 * 8 * video_rowbytes + CursorX
          MOVE.L  pMonScreen(PC),A1
          MULU    video_rowbytes(A4),D0
          ASL.L   #3,D0
          ADDA.L  D0,A1
          ADDA.W  CursorX(A4),A1

          ADDA.L  tmon_offset(A4),A1
          MOVE.L  A1,D2

          MOVE.W  video_rowbytes(A4),D0

          MOVE.B  (A0),(A1)
          ADDA.W  D0,A1
          MOVE.B  $0100(A0),(A1)        ;          MOVE.B  $0100(A0),0160(A1)
          ADDA.W  D0,A1
          MOVE.B  $0200(A0),(A1)        ;          MOVE.B  $0200(A0),0320(A1)
          ADDA.W  D0,A1
          MOVE.B  $0300(A0),(A1)        ;          MOVE.B  $0300(A0),0480(A1)
          ADDA.W  D0,A1
          MOVE.B  $0400(A0),(A1)        ;          MOVE.B  $0400(A0),0640(A1)
          ADDA.W  D0,A1
          MOVE.B  $0500(A0),(A1)        ;          MOVE.B  $0500(A0),0800(A1)
          ADDA.W  D0,A1
          MOVE.B  $0600(A0),(A1)        ;          MOVE.B  $0600(A0),0960(A1)
          ADDA.W  D0,A1
          MOVE.B  $0700(A0),(A1)        ;          MOVE.B  $0700(A0),1120(A1)

          TST     D1
          BEQ     Disp8_8E

          TST.W   EditModus(A4)
          BPL     Disp8_8O

          MOVE.L  D2,A1
          EORI.B  #-1,(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0160(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0320(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0480(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0640(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0800(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0960(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,1120(A1)

Disp8_8E  MOVE.L  (SP)+,D2
          RTS

Disp8_8O
          MOVE.L  D2,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,1120(A1)
          MOVE.L  (SP)+,D2
          RTS

*)

(*$? ~MAC:
!DispChar
          MOVE.L  D2,-(SP)                 ; sonst geht R Befehl nicht!
          LEA     DispTable(PC),A1         ; Zeichen in Puffer ablegen
          MOVE.W  CursorY(A4),D2
          ASL.W   #3,D2
          MOVE.L  4(A1,D2.w),D2            ; immer nur 16 Bit Offset!
          ADD.W   CursorX(A4),D2           ; es wird niemals ein öbertrag auftreten!
          MOVE.L  bMonScreen(PC),A1
          ADDA.L  D2,A1
          MOVE.L  A1,D2
          SUB.L   bMonScreenTop(PC),D2
          BCS     DispChar1
          MOVE.L  bMonScreenBase(PC),A1
          ADDA.L  D2,A1
DispChar1 MOVE.B  D0,(A1)
          MOVE.L  (SP)+,D2

DispChar2 ANDI.L  #$FF,D0

          (* !!!
          MOVE.W  FontMode(PC),D2   ; TST.W geht nicht
          BNE.L   Disp6_6       ; 6*6-Font darstellen
          *)

          TST     Unknown(A4)
          BEQ     DispCharKnown
DispCharPlane
          CMPI.W  #1,video_plane(A4)
          BEQ     Z400
          BRA.L   Disp8_8
DispCharKnown
          TST     isFALCON030(A4)
          BNE.S   DispCharPlane
          TST     isTT(A4)
          BEQ.S   DispCharResTest
          TST     video_modus(A4)
          BNE.L   disp_tt_mono
          BRA.S   Z400
DispCharResTest
          MOVE.B  $FFFF8260,D5
          BTST.L  #1,D5
          BEQ.L   Disp8_8       ; -> 200 Zeilen
Z400
          ; Parameter f. 400 Zeilen-Auflîsung
          MOVE.L  pFont8_16(PC),A0

          ; Font-^ auf richtiges Zeichen bestimmen:
          ADDA.W  D0,A0
          ; Screenoffset := CursorY * 80/160 * 8/16 + CursorX * 1/2
          MOVE.W  CursorY(A4),D0
          TST     video_modus(A4)
          BEQ.L   disp_fast_mono
          ; D0 * 16 * video_rowbytes + CursorX
          ASL.W   #4,D0
          MULU    video_rowbytes(A4),D0
          MOVE.L  D2,-(SP)
          MOVE.W  CursorX(A4),D2
          EXT.L   D2
          ADD.L   D2,D0

          MOVE.L  pMonScreen(PC),A1
          ADDA.L  D0,A1

          ADDA.L  tmon_offset(A4),A1
          MOVE.L  A1,D2

          MOVE.W  video_rowbytes(A4),D0

          MOVE.B  (A0),(A1)
          ADDA.W  D0,A1
          MOVE.B  $0100(A0),(A1)       ;          MOVE.B  $0100(A0),0080(A1)
          ADDA.W  D0,A1
          MOVE.B  $0200(A0),(A1)       ;          MOVE.B  $0200(A0),0160(A1)
          ADDA.W  D0,A1
          MOVE.B  $0300(A0),(A1)       ;          MOVE.B  $0300(A0),0240(A1)
          ADDA.W  D0,A1
          MOVE.B  $0400(A0),(A1)       ;          MOVE.B  $0400(A0),0320(A1)
          ADDA.W  D0,A1
          MOVE.B  $0500(A0),(A1)       ;          MOVE.B  $0500(A0),0400(A1)
          ADDA.W  D0,A1
          MOVE.B  $0600(A0),(A1)       ;          MOVE.B  $0600(A0),0480(A1)
          ADDA.W  D0,A1
          MOVE.B  $0700(A0),(A1)       ;          MOVE.B  $0700(A0),0560(A1)
          ADDA.W  D0,A1
          MOVE.B  $0800(A0),(A1)       ;          MOVE.B  $0800(A0),0640(A1)
          ADDA.W  D0,A1
          MOVE.B  $0900(A0),(A1)       ;          MOVE.B  $0900(A0),0720(A1)
          ADDA.W  D0,A1
          MOVE.B  $0A00(A0),(A1)       ;          MOVE.B  $0A00(A0),0800(A1)
          ADDA.W  D0,A1
          MOVE.B  $0B00(A0),(A1)       ;          MOVE.B  $0B00(A0),0880(A1)
          ADDA.W  D0,A1
          MOVE.B  $0C00(A0),(A1)       ;          MOVE.B  $0C00(A0),0960(A1)
          ADDA.W  D0,A1
          MOVE.B  $0D00(A0),(A1)       ;          MOVE.B  $0D00(A0),1040(A1)
          ADDA.W  D0,A1
          MOVE.B  $0E00(A0),(A1)       ;          MOVE.B  $0E00(A0),1120(A1)
          ADDA.W  D0,A1
          MOVE.B  $0F00(A0),(A1)       ;          MOVE.B  $0F00(A0),1200(A1)

          TST     D1
          BEQ.L   Disp8_16E

          TST.W   EditModus(A4)
          BPL     Disp8_16O

          MOVE.L  D2,A1
          EORI.B  #-1,(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0080(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0160(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0240(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0320(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0400(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0480(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0560(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0640(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0720(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0800(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0880(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,0960(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,1040(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,1120(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,1200(A1)

Disp8_16E MOVE.L  (SP)+,D2
          RTS

Disp8_16O
          MOVE.L  D2,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,1120(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)            ;          EORI.B  #-1,1200(A1)
          MOVE.L  (SP)+,D2
          RTS

disp_fast_mono
          LEA     DispTable(PC),A1
          ASL.W   #3,D0
          MOVE.L  0(A1,D0.w),D0
          MOVE.L  pMonScreen(PC),A1
          ADDA.L  D0,A1
          ADDA.W  CursorX(A4),A1
          MOVE.B  (A0),(A1)
          MOVE.B  $100(A0),0080(A1)
          MOVE.B  $200(A0),0160(A1)
          MOVE.B  $300(A0),0240(A1)
          MOVE.B  $400(A0),0320(A1)
          MOVE.B  $500(A0),0400(A1)
          MOVE.B  $600(A0),0480(A1)
          MOVE.B  $700(A0),0560(A1)
          MOVE.B  $800(A0),0640(A1)
          MOVE.B  $900(A0),0720(A1)
          MOVE.B  $A00(A0),0800(A1)
          MOVE.B  $B00(A0),0880(A1)
          MOVE.B  $C00(A0),0960(A1)
          MOVE.B  $D00(A0),1040(A1)
          MOVE.B  $E00(A0),1120(A1)
          MOVE.B  $F00(A0),1200(A1)

          TST     D1
          BEQ     disp_fast_mono_E

          TST.W   EditModus(A4)
          BPL     disp_fast_mono_O

          EORI.B  #-1,(A1)
          EORI.B  #-1,0080(A1)
          EORI.B  #-1,0160(A1)
          EORI.B  #-1,0240(A1)
          EORI.B  #-1,0320(A1)
          EORI.B  #-1,0400(A1)
          EORI.B  #-1,0480(A1)
          EORI.B  #-1,0560(A1)
          EORI.B  #-1,0640(A1)
          EORI.B  #-1,0720(A1)
          EORI.B  #-1,0800(A1)
          EORI.B  #-1,0880(A1)
          EORI.B  #-1,0960(A1)
          EORI.B  #-1,1040(A1)
disp_fast_mono_O
          EORI.B  #-1,1120(A1)
          EORI.B  #-1,1200(A1)

disp_fast_mono_E
          RTS

disp_tt_mono
          MOVE.L  pFont8_16(PC),A0
          ADDA.W  D0,A0
          MOVE.W  CursorY(A4),D0
          LEA     DispTable(PC),A1
          ASL.W   #3,D0
          MOVE.L  0(A1,D0.w),D0
          ASL.L   #1,D0
          MOVE.L  pMonScreen(PC),A1
          ADDA.L  D0,A1
          ADDA.L  tmon_offset(A4),A1
          ADDA.W  CursorX(A4),A1
          MOVE.B  (A0),(A1)
          MOVE.B  $100(A0),0160(A1)
          MOVE.B  $200(A0),0320(A1)
          MOVE.B  $300(A0),0480(A1)
          MOVE.B  $400(A0),0640(A1)
          MOVE.B  $500(A0),0800(A1)
          MOVE.B  $600(A0),0960(A1)
          MOVE.B  $700(A0),1120(A1)
          MOVE.B  $800(A0),1280(A1)
          MOVE.B  $900(A0),1440(A1)
          MOVE.B  $A00(A0),1600(A1)
          MOVE.B  $B00(A0),1760(A1)
          MOVE.B  $C00(A0),1920(A1)
          MOVE.B  $D00(A0),2080(A1)
          MOVE.B  $E00(A0),2240(A1)
          MOVE.B  $F00(A0),2400(A1)

          TST     D1
          BEQ     disp_tt_mono_E

          TST.W   EditModus(A4)
          BPL     disp_tt_mono_O

          EORI.B  #-1,(A1)
          EORI.B  #-1,0160(A1)
          EORI.B  #-1,0320(A1)
          EORI.B  #-1,0480(A1)
          EORI.B  #-1,0640(A1)
          EORI.B  #-1,0800(A1)
          EORI.B  #-1,0960(A1)
          EORI.B  #-1,1120(A1)
          EORI.B  #-1,1280(A1)
          EORI.B  #-1,1440(A1)
          EORI.B  #-1,1600(A1)
          EORI.B  #-1,1760(A1)
          EORI.B  #-1,1920(A1)
          EORI.B  #-1,2080(A1)
disp_tt_mono_O
          EORI.B  #-1,2240(A1)
          EORI.B  #-1,2400(A1)

disp_tt_mono_E
          RTS


Disp8_8   ; Parameter f. 200 Zeilen-Auflîsung
          MOVE.L  pFont8_8(PC),A0

          ; Font-^ auf richtiges Zeichen bestimmen:
          ADDA.W  D0,A0
          ; Screenoffset := CursorY * 80/160 * 8/16 + CursorX * 1/2
          MOVE.W  CursorY(A4),D0
          TST     video_modus(A4)
          BEQ.L   disp_fast_col

          ; D0 * 8 * video_rowbytes + (((CursorX & $FE) * 2) + (CursorX & 1))
          ASL.W   #3,D0
          MULU    video_rowbytes(A4),D0
          MOVE.L  D2,-(SP)
          MOVE.W  CursorX(A4),D2
          ANDI.L  #$FE,D2
          ASL.L   #1,D2
          ADD.L   D2,D0
          MOVE.W  CursorX(A4),D2
          ANDI.L  #1,D2
          ADD.L   D2,D0
          MOVE.L  pMonScreen(PC),A1
          ADDA.L  D0,A1

          ADDA.L  tmon_offset(A4),A1
          MOVE.L  A1,D2

          MOVE.W  video_rowbytes(A4),D0

          MOVE.B  (A0),(A1)
          ADDA.W  D0,A1
          MOVE.B  $0100(A0),(A1)        ;          MOVE.B  $0100(A0),0160(A1)
          ADDA.W  D0,A1
          MOVE.B  $0200(A0),(A1)        ;          MOVE.B  $0200(A0),0320(A1)
          ADDA.W  D0,A1
          MOVE.B  $0300(A0),(A1)        ;          MOVE.B  $0300(A0),0480(A1)
          ADDA.W  D0,A1
          MOVE.B  $0400(A0),(A1)        ;          MOVE.B  $0400(A0),0640(A1)
          ADDA.W  D0,A1
          MOVE.B  $0500(A0),(A1)        ;          MOVE.B  $0500(A0),0800(A1)
          ADDA.W  D0,A1
          MOVE.B  $0600(A0),(A1)        ;          MOVE.B  $0600(A0),0960(A1)
          ADDA.W  D0,A1
          MOVE.B  $0700(A0),(A1)        ;          MOVE.B  $0700(A0),1120(A1)

          TST     D1
          BEQ     Disp8_8E

          TST.W   EditModus(A4)
          BPL     Disp8_8O

          MOVE.L  D2,A1
          EORI.B  #-1,(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0160(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0320(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0480(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0640(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0800(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,0960(A1)
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,1120(A1)

Disp8_8E  MOVE.L  (SP)+,D2
          RTS

Disp8_8O
          MOVE.L  D2,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          ADDA.W  D0,A1
          EORI.B  #-1,(A1)              ;          EORI.B  #-1,1120(A1)
          MOVE.L  (SP)+,D2
          RTS


disp_fast_col
          LSL.W   #8,D0
          MOVE.W  D0,D5
          LSL.W   #2,D0
          ADD.W   D5,D0
          MOVE.W  CursorX(A4),D4
          MOVE.W  D4,D5
          ANDI.W  #$FFFE,D4
          LSL.W   #1,D4
          ADD.W   D4,D0
          ANDI.W  #1,D5
          ADD.W   D5,D0
          MOVE.L  pMonScreen(PC),A1
          ADDA.W  D0,A1

          MOVE.B  (A0),(A1)
          MOVE.B  $100(A0),0160(A1)
          MOVE.B  $200(A0),0320(A1)
          MOVE.B  $300(A0),0480(A1)
          MOVE.B  $400(A0),0640(A1)
          MOVE.B  $500(A0),0800(A1)
          MOVE.B  $600(A0),0960(A1)
          MOVE.B  $700(A0),1120(A1)

          TST.W   D1
          BEQ     disp_fast_col_E

          TST.W   EditModus(A4)
          BPL     disp_fast_col_O

          EORI.B  #-1,(A1)
          EORI.B  #-1,0160(A1)
          EORI.B  #-1,0320(A1)
          EORI.B  #-1,0480(A1)
          EORI.B  #-1,0640(A1)
          EORI.B  #-1,0800(A1)
          EORI.B  #-1,0960(A1)
disp_fast_col_O
          EORI.B  #-1,1120(A1)

disp_fast_col_E
          rts
*)

(*$? ~MAC:
; FastString Routine : A1 Pointer auf String (muû unterhalb bMonScreenTop liegen!)
;                      A2 Pointer auf Ziel
;                      D0 Anzahl an Spalten
;                      D1 Anzahl an Zeilen-1
;                      D4 Anzahl Bytes pro Zeile

FastString16_8o
          BSET    #17,D7
          BRA.S   FastString16_8g
FastString16_8
          BCLR    #17,D7
FastString16_8g
          MOVEM.L A0-A6/D1-D3/D5/D6,-(SP)
          MOVE.W  D4,D5
          LSL.W   #4,D5
          MOVE.W  D5,D6
          MOVE.W  D0,D3
          ADDQ.W  #1,D3
          ASL.W   #2,D3
          SUB.W   D3,D6            ; 16 * D4 - 80
          SUB.W   D4,D5
          SUBQ    #4,D5            ; 15 * D4 - 4
          MOVE.L  pFont8_16(PC),A0
FastString16_8EineZ
          MOVE.W  D0,D3
FastString16_81
          MOVEQ   #0,D2
          MOVE.W  (A1)+,D2
          ROL.L   #8,D2
          ROR.W   #8,D2
          MOVE.L  A0,A3
          MOVE.L  A0,A4
          ADDA.W  D2,A4
          SWAP    D2
          ADDA.W  D2,A3
          MOVEQ   #0,D2
          MOVE.W  (A1)+,D2
          ROL.L   #8,D2
          ROR.W   #8,D2
          MOVE.L  A0,A5
          MOVE.L  A0,A6
          ADDA.W  D2,A6
          SWAP    D2
          ADDA.W  D2,A5
          MOVEQ   #0,D2

          MOVE.B  (A3),D2
          LSL.W   #8,D2
          MOVE.B  (A4),D2
          SWAP    D2
          MOVE.B  (A5),D2
          LSL.W   #8,D2
          MOVE.B  (A6),D2
          MOVE.L  D2,(A2)

          MOVE.B  $100(A3),D2
          LSL.W   #8,D2
          MOVE.B  $100(A4),D2
          SWAP    D2
          MOVE.B  $100(A5),D2
          LSL.W   #8,D2
          MOVE.B  $100(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $200(A3),D2
          LSL.W   #8,D2
          MOVE.B  $200(A4),D2
          SWAP    D2
          MOVE.B  $200(A5),D2
          LSL.W   #8,D2
          MOVE.B  $200(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $300(A3),D2
          LSL.W   #8,D2
          MOVE.B  $300(A4),D2
          SWAP    D2
          MOVE.B  $300(A5),D2
          LSL.W   #8,D2
          MOVE.B  $300(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $400(A3),D2
          LSL.W   #8,D2
          MOVE.B  $400(A4),D2
          SWAP    D2
          MOVE.B  $400(A5),D2
          LSL.W   #8,D2
          MOVE.B  $400(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $500(A3),D2
          LSL.W   #8,D2
          MOVE.B  $500(A4),D2
          SWAP    D2
          MOVE.B  $500(A5),D2
          LSL.W   #8,D2
          MOVE.B  $500(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $600(A3),D2
          LSL.W   #8,D2
          MOVE.B  $600(A4),D2
          SWAP    D2
          MOVE.B  $600(A5),D2
          LSL.W   #8,D2
          MOVE.B  $600(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $700(A3),D2
          LSL.W   #8,D2
          MOVE.B  $700(A4),D2
          SWAP    D2
          MOVE.B  $700(A5),D2
          LSL.W   #8,D2
          MOVE.B  $700(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $800(A3),D2
          LSL.W   #8,D2
          MOVE.B  $800(A4),D2
          SWAP    D2
          MOVE.B  $800(A5),D2
          LSL.W   #8,D2
          MOVE.B  $800(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $900(A3),D2
          LSL.W   #8,D2
          MOVE.B  $900(A4),D2
          SWAP    D2
          MOVE.B  $900(A5),D2
          LSL.W   #8,D2
          MOVE.B  $900(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $A00(A3),D2
          LSL.W   #8,D2
          MOVE.B  $A00(A4),D2
          SWAP    D2
          MOVE.B  $A00(A5),D2
          LSL.W   #8,D2
          MOVE.B  $A00(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $B00(A3),D2
          LSL.W   #8,D2
          MOVE.B  $B00(A4),D2
          SWAP    D2
          MOVE.B  $B00(A5),D2
          LSL.W   #8,D2
          MOVE.B  $B00(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $C00(A3),D2
          LSL.W   #8,D2
          MOVE.B  $C00(A4),D2
          SWAP    D2
          MOVE.B  $C00(A5),D2
          LSL.W   #8,D2
          MOVE.B  $C00(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $D00(A3),D2
          LSL.W   #8,D2
          MOVE.B  $D00(A4),D2
          SWAP    D2
          MOVE.B  $D00(A5),D2
          LSL.W   #8,D2
          MOVE.B  $D00(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $E00(A3),D2
          LSL.W   #8,D2
          MOVE.B  $E00(A4),D2
          SWAP    D2
          MOVE.B  $E00(A5),D2
          LSL.W   #8,D2
          MOVE.B  $E00(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          MOVE.B  $F00(A3),D2
          LSL.W   #8,D2
          MOVE.B  $F00(A4),D2
          SWAP    D2
          MOVE.B  $F00(A5),D2
          LSL.W   #8,D2
          MOVE.B  $F00(A6),D2
          ADDA.W  D4,A2
          MOVE.L  D2,(A2)

          SUBA.W  D5,A2
          DBRA    D3,FastString16_81
          BTST    #17,D7
          BNE.S   FastString16_8OK
          CMPA.L  bMonScreenTop(PC),A1
          BLT.S   FastString16_8Ok
          MOVE.L  bMonScreenBase(PC),A1
FastString16_8OK
          ADDA.W  D6,A2
          DBRA    D1,FastString16_8EineZ
          MOVEM.L (SP)+,A0-A6/D1-D3/D5/D6
          RTS

FastString8_8o
          BSET    #17,D7
          BRA.S   FastString8_8g
FastString8_8
          BCLR    #17,D7
FastString8_8g
          MOVEM.L A0-A6/D1-D3/D5/D6,-(SP)
          MOVE.W  D4,D5
          LSL.W   #3,D5
          MOVE.W  D5,D6
          MOVE.W  D0,D3
          ADDQ.W  #1,D3
          ASL.W   #3,D3
          SUB.W   D3,D6             ; 8 * D4 - 160
          SUB.W   D4,D5
          SUBQ    #8,D5             ; 7 * D4 - 8
          MOVE.L  pFont8_8(PC),A0
FastString8_8EineZ
          MOVE.W  D0,D3
FastString8_81
          MOVEQ   #0,D2
          MOVE.W  (A1)+,D2
          ROL.L   #8,D2
          ROR.W   #8,D2
          MOVE.L  A0,A3
          MOVE.L  A0,A4
          ADDA.W  D2,A4
          SWAP    D2
          ADDA.W  D2,A3
          MOVEQ   #0,D2
          MOVE.W  (A1)+,D2
          ROL.L   #8,D2
          ROR.W   #8,D2
          MOVE.L  A0,A5
          MOVE.L  A0,A6
          ADDA.W  D2,A6
          SWAP    D2
          ADDA.W  D2,A5

          MOVE.B  (A3),D2
          ROL.W   #8,D2
          MOVE.B  (A4),D2
          MOVE.W  D2,(A2)
          CLR.W   2(A2)
          MOVE.B  (A5),D2
          ROL.W   #8,D2
          MOVE.B  (A6),D2
          MOVE.W  D2,4(A2)
          CLR.W   6(A2)

          MOVE.B  $100(A3),D2
          ROL.W   #8,D2
          MOVE.B  $100(A4),D2
          ADDA.W  D4,A2
          MOVE.W  D2,(A2)
          CLR.W   2(A2)
          MOVE.B  $100(A5),D2
          ROL.W   #8,D2
          MOVE.B  $100(A6),D2
          MOVE.W  D2,4(A2)
          CLR.W   6(A2)

          MOVE.B  $200(A3),D2
          ROL.W   #8,D2
          MOVE.B  $200(A4),D2
          ADDA.W  D4,A2
          MOVE.W  D2,(A2)
          CLR.W   2(A2)
          MOVE.B  $200(A5),D2
          ROL.W   #8,D2
          MOVE.B  $200(A6),D2
          MOVE.W  D2,4(A2)
          CLR.W   6(A2)

          MOVE.B  $300(A3),D2
          ROL.W   #8,D2
          MOVE.B  $300(A4),D2
          ADDA.W  D4,A2
          MOVE.W  D2,(A2)
          CLR.W   2(A2)
          MOVE.B  $300(A5),D2
          ROL.W   #8,D2
          MOVE.B  $300(A6),D2
          MOVE.W  D2,4(A2)
          CLR.W   6(A2)

          MOVE.B  $400(A3),D2
          ROL.W   #8,D2
          MOVE.B  $400(A4),D2
          ADDA.W  D4,A2
          MOVE.W  D2,(A2)
          CLR.W   2(A2)
          MOVE.B  $400(A5),D2
          ROL.W   #8,D2
          MOVE.B  $400(A6),D2
          MOVE.W  D2,4(A2)
          CLR.W   6(A2)

          MOVE.B  $500(A3),D2
          ROL.W   #8,D2
          MOVE.B  $500(A4),D2
          ADDA.W  D4,A2
          MOVE.W  D2,(A2)
          CLR.W   2(A2)
          MOVE.B  $500(A5),D2
          ROL.W   #8,D2
          MOVE.B  $500(A6),D2
          MOVE.W  D2,4(A2)
          CLR.W   6(A2)

          MOVE.B  $600(A3),D2
          ROL.W   #8,D2
          MOVE.B  $600(A4),D2
          ADDA.W  D4,A2
          MOVE.W  D2,(A2)
          CLR.W   2(A2)
          MOVE.B  $600(A5),D2
          ROL.W   #8,D2
          MOVE.B  $600(A6),D2
          MOVE.W  D2,4(A2)
          CLR.W   6(A2)

          MOVE.B  $700(A3),D2
          ROL.W   #8,D2
          MOVE.B  $700(A4),D2
          ADDA.W  D4,A2
          MOVE.W  D2,(A2)
          CLR.W   2(A2)
          MOVE.B  $700(A5),D2
          ROL.W   #8,D2
          MOVE.B  $700(A6),D2
          MOVE.W  D2,4(A2)
          CLR.W   6(A2)

          SUBA.W  D5,A2
          DBRA    D3,FastString8_81
          BTST    #17,D7
          BNE     FastString8_8OK
          CMPA.L  bMonScreenTop(PC),A1
          BLT.S   FastString8_8Ok
          MOVE.L  bMonScreenBase(PC),A1
FastString8_8OK
          ADDA.W  D6,A2
          DBRA    D1,FastString8_8EineZ
          MOVEM.L (SP)+,A0-A6/D1-D3/D5/D6
          RTS
*)

(*$? MAC:

InitBitToByteTab:
          movem.l d0-d2/a0,-(a7)
          lea     BitToByte(PC),a0
          moveq   #0,d0
ibtbt1:   move.b  d0,d1
          moveq   #7,d2
ibtbt2:   lsl.b   #1,d1
          scs     (a0)+
          dbra    d2,ibtbt2
          addq.b  #1,d0
          bne     ibtbt1
          movem.l (a7)+,d0-d2/a0
          rts

; FastString Routine : A1 Pointer auf String (muû unterhalb bMonScreenTop liegen!)
;                      A2 Pointer auf Ziel
;                      D0 Anzahl an Spalten
;                      D1 Anzahl an Zeilen-1
;                      D4 Anzahl Bytes pro Zeile

FastString8_8o
FastString16_8o
          BSET    #17,D7
          BRA.S   FastString16_8g
FastString8_8
FastString16_8
          BCLR    #17,D7
FastString16_8g

          tst.b   Is256Cols(pc)
          beq.w   dispfbw

(*
 * Routine fÅr 256 Farb-Modus
 *)
          MOVEM.L A0-A6/D0-D3/D5/D6,-(SP)
          MOVEQ   #0,D5
          MOVE.W  D4,D5
          LSL.L   #3,D5         ; D5: Anzahl Bytes pro 8 Zeilen
          SUBQ.L  #1,D0
          MOVE.L  pFont8_8(PC),A0
          LEA     BitToByte(PC),A3

FastString8_9EineZ
          MOVE.L  D1,-(A7)
          MOVE.L  A2,-(A7)
          MOVE.W  D0,D3         ; Anzahl zu kopierender Zeichen pro Zeile

FastString8_91  ; nÑchster Character (8 Bytes nach A2+)
          MOVEQ   #0,D2
          MOVE.B  (A1)+,D2    ; der character
          MOVE.L  A0,A4
          ADDA.W  D2,A4       ; der offset des chars in der font-tabelle

          MOVEQ   #7,D6
FastString8_92  ; nÑchste Video-Zeile (von 8)
          MOVEQ   #0,D1
          MOVE.B  (A4),D1
          LSL.W   #3,D1
          MOVE.L  0(A3,D1.W),(A2)
          MOVE.L  4(A3,D1.W),4(A2)
          ADDA.W  D4,A2
          ADDA.W  #$0100,A4
          DBRA    D6,FastString8_92
          
          SUBA.L  D5,A2
          ADDQ.L  #8,A2
          DBRA    D3,FastString8_91

          BTST    #17,D7
          BNE.S   FastString8_9OK
          CMPA.L  bMonScreenTop(PC),A1
          BLT.S   FastString8_9OK
          MOVE.L  bMonScreenBase(PC),A1
FastString8_9OK
          MOVE.L  (A7)+,A2
          MOVE.L  (A7)+,D1
          ADDA.L  D5,A2
          DBRA    D1,FastString8_9EineZ
          
          MOVEM.L (SP)+,A0-A6/D0-D3/D5/D6
          RTS

(*
 * Original-Routine fÅr s/w-Modus
 *)
dispfbw:
          MOVEM.L A0-A6/D0-D3/D5,-(SP)
          MOVE.W  D4,D5
          LSL.W   #3,D5         ; D5: Anzahl Bytes pro 8 Video-Char-Zeilen
          LSR     #2,D0
          SUBQ    #1,D0
          MOVE.L  pFont8_8(PC),A0
FastString8_8EineZ
          MOVE.L  A2,-(A7)
          MOVE.W  D0,D3
FastString8_81
          MOVE.L  A2,-(A7)
          ; in dieser Schleife werden je 4 Zeichen (aus je 8 Pixels) in 8
          ; Zeilen auf einmal gesetzt.
          MOVEQ   #0,D2
          MOVE.W  (A1)+,D2
          ROL.L   #8,D2
          ROR.W   #8,D2
          MOVE.L  A0,A3
          MOVE.L  A0,A4
          ADDA.W  D2,A4
          SWAP    D2
          ADDA.W  D2,A3
          MOVEQ   #0,D2
          MOVE.W  (A1)+,D2
          ROL.L   #8,D2
          ROR.W   #8,D2
          MOVE.L  A0,A5
          MOVE.L  A0,A6
          ADDA.W  D2,A6
          SWAP    D2
          ADDA.W  D2,A5

          MOVE.B  (A3),D2
          LSL.W   #8,D2
          MOVE.B  (A4),D2
          SWAP    D2
          MOVE.B  (A5),D2
          LSL.W   #8,D2
          MOVE.B  (A6),D2
          MOVE.L  D2,(A2)
          ADDA.W  D4,A2

          MOVE.B  $100(A3),D2
          LSL.W   #8,D2
          MOVE.B  $100(A4),D2
          SWAP    D2
          MOVE.B  $100(A5),D2
          LSL.W   #8,D2
          MOVE.B  $100(A6),D2
          MOVE.L  D2,(A2)
          ADDA.W  D4,A2

          MOVE.B  $200(A3),D2
          LSL.W   #8,D2
          MOVE.B  $200(A4),D2
          SWAP    D2
          MOVE.B  $200(A5),D2
          LSL.W   #8,D2
          MOVE.B  $200(A6),D2
          MOVE.L  D2,(A2)
          ADDA.W  D4,A2

          MOVE.B  $300(A3),D2
          LSL.W   #8,D2
          MOVE.B  $300(A4),D2
          SWAP    D2
          MOVE.B  $300(A5),D2
          LSL.W   #8,D2
          MOVE.B  $300(A6),D2
          MOVE.L  D2,(A2)
          ADDA.W  D4,A2

          MOVE.B  $400(A3),D2
          LSL.W   #8,D2
          MOVE.B  $400(A4),D2
          SWAP    D2
          MOVE.B  $400(A5),D2
          LSL.W   #8,D2
          MOVE.B  $400(A6),D2
          MOVE.L  D2,(A2)
          ADDA.W  D4,A2

          MOVE.B  $500(A3),D2
          LSL.W   #8,D2
          MOVE.B  $500(A4),D2
          SWAP    D2
          MOVE.B  $500(A5),D2
          LSL.W   #8,D2
          MOVE.B  $500(A6),D2
          MOVE.L  D2,(A2)
          ADDA.W  D4,A2

          MOVE.B  $600(A3),D2
          LSL.W   #8,D2
          MOVE.B  $600(A4),D2
          SWAP    D2
          MOVE.B  $600(A5),D2
          LSL.W   #8,D2
          MOVE.B  $600(A6),D2
          MOVE.L  D2,(A2)
          ADDA.W  D4,A2

          MOVE.B  $700(A3),D2
          LSL.W   #8,D2
          MOVE.B  $700(A4),D2
          SWAP    D2
          MOVE.B  $700(A5),D2
          LSL.W   #8,D2
          MOVE.B  $700(A6),D2
          MOVE.L  D2,(A2)

          MOVE.L  (A7)+,A2
          ADDQ.L  #4,A2
          DBRA    D3,FastString8_81
          BTST    #17,D7
          BNE     FastString8_8OK
          CMPA.L  bMonScreenTop(PC),A1
          BLT.S   FastString8_8Ok
          MOVE.L  bMonScreenBase(PC),A1
FastString8_8OK
          MOVE.L  (A7)+,A2
          ADDA.W  D5,A2
          DBRA    D1,FastString8_8EineZ
          
          MOVEM.L (SP)+,A0-A6/D0-D3/D5
          RTS

*)

ClearEol  MOVE    CursorX(A4),-(A7)
ClrEolL0  MOVE    CursorX(A4),D0
          CMP     Rows(A4),D0
          BCS     ClEolC0
          MOVE    (A7)+,CursorX(A4)
          RTS
ClEolC0   MOVEQ   #0,D1
          MOVEQ   #' ',D0
          BSR     DispChar
          ADDQ.W  #1,CursorX(A4)
          BRA     ClrEolL0


(*$ ? German:
!BetaTitel ASC    "TempleMon Version 2.05 / 14.06.1996. "
          (*
          ASC     "TempleMon wurde mit Megamax Modula-2 entwickelt. "
          ASC     "Besorgen Sie sich doch mal den neuesten SysMon von "
          ASC     "Karsten Isakovic, Wilmersdorferstraûe 82, D-10629 Berlin. "
          ASC     "Starten Sie SysMon nach TempleMon. Beide Programme "
          ACZ     "ergÑnzen sich dann. Viel Spaû.  "
          *)
          DC.B    0,0,0
!PressKeyMsg  ACZ  ' --- SPACE-Taste druecken --- '
*)
(*$ ? English:
!BetaTitel ASC    "TempleMon version 2.05 Jun 14 1996. "
          (*
          ASC     "TempleMon has been developed with Megamax Modula-2. "
          ASC     "Try the newest version of SysMon in combination with "
          ASC     "TempleMon. Order SysMon from the author "
          ASC     "Karsten Isakovic, Wilmersdorferstraûe 82, D-10629 Berlin,"
          ASC     " Germany. "
          ASC     "Start SysMon after TempleMon. Both programs complete "
          ACZ     "each other. Have fun!  "
          *)
          DC.B    0,0,0
!PressKeyMsg  ACZ  ' --- press SPACE --- '
*)
          SYNC

(*$ ? German:
initMsg   DC.B     CR,LF,$1B,'p'
          ASC      ' TempleMon     Version 2.05    14. Juni 1996 '
          DC.B     $1B,'q',CR,LF
          ASC      ' Ω 1986-96 Johannes Hill & Thomas Tempelmann '
          DC.B     CR,LF,0
!CmdCmt
ACZ '                      TempleMon / Version 2.05 / 14.06.96'
ACZ '                    ----------------------------------------'
ACZ '          Copyright (C) [1986..1995], Thomas Tempelmann, Johannes Hill'
ACZ '         Thomas Tempelmann, TÅrkenstr. 31,    D-80799 MÅnchen,  Germany'
(*
ACZ '         Johannes Hill, Unteres Kirchfeld 23, D-68259 Mannheim, Germany'
*)
ACZ '-------------------------------------------------------------------------------'
*)
(*$ ? English:
initMsg   DC.B     CR,LF,$1B,'p'
          ASC      ' TempleMon       Release 2.05      June 14 1996 '
          DC.B     $1B,'q',CR,LF
          ASC      ' Ω 1986-96 by Johannes Hill & Thomas Tempelmann '
          DC.B     CR,LF,0
!CmdCmt
ACZ ' '
ACZ '------------------------------ TempleMon 2.05 ------------------ Jun 14 1996 --'
ACZ '          Copyright (C) [1986..1996], Thomas Tempelmann, Johannes Hill'
ACZ '           Thomas Tempelmann, TÅrkenstr. 31, D-80799 MÅnchen, Germany'
(*
ACZ '         Johannes Hill, Unteres Kirchfeld 23, D-68259 Mannheim, Germany'
*)
ACZ '-------------------------------------------------------------------------------'
*)
(*$ ? German:
ACZ 'TempleMon ist Freeware. Es dient zur Fehlersuche fÅr Programmentwickler.'
ACZ 'Bedienungsanleitung und Support kînnen die Autoren leider nicht mehr bieten.'
ACZ 'Sie kînnen uns zwar Post schicken, aber rechnen Sie nicht mit einer Antwort.'
ACZ 'Wenn Sie dennoch dringend Hilfe zu diesem Programm benîtigen, benutzen Sie'
ACZ 'bitte E-Mail:'
ACZ '  Internet: tt@muc.de oder tt@m.maus.de'
(*
ACZ 'Die Versionen 1.x und 2.x dieses Monitors sind frei kopierbar. Allerdings nur'
ACZ 'in der Originalversion, das schlieût ein, daû dieser Text inklusive der'
ACZ 'Urheberrechtsangabe nicht gelîscht werden darf und daû immer der ganze Ordner,'
ACZ 'in dem sich dieser Monitor befindet, kopiert wird (mit den Dateien LIESMICH,'
ACZ 'TEMPLMON.PRG und TMONINST.PRG)!'
*)
ACZ ' '
ACZ '    Mit freundlichen GrÅûen         Johannes Hill und Thomas Tempelmann'
ACZ '-------------------------------------------------------------------------------'
ACZ 'Die wichtigsten Befehle:'
(*$? MAC:
ACZ ' ES - bricht MagiCMac ab, RÅckkehr zum Finder'
*)
ACZ ' Q  - bricht unterbrochenes Programm unter MagiC ab'
ACZ ' G  - fÅhrt ProgrammausfÅhrung fort'
ACZ ' R  - Register-Dump'
ACZ ' M  - Speicher-Dump'
ACZ ' D  - Disassembly (D RPC-20 Z15 zeigt 15 Zeilen Code um den PC herum)'
ACZ '-------------------------------------------------------------------------------'
DC.B 0,0
*)

(*$ ? English:
ACZ 'TempleMon is freeware. It is a debugging tool for Atari developers.'
ASC 'We' dc.b 39 ACZ 're sorry, but we cannot support you with a manual or further help.'
ACZ 'If you need to contact us, please use e-mail.'
ACZ '  Internet: tt@muc.de or tt@m.maus.de'
(*
ACZ ' This release of TempleMon does support MultiTOS. The FALCON030 support is not'
ASC ' complete! Don' dc.b 39 ACZ 't ask for any information about this machine which were'
ASC ' necessary to implement FALCON support. It' dc.b 39 ASC 's not perfect now! You won' dc.b 39 ACZ 't get any'
ACZ ' information about it even if you threaten to shoot me!'
ACZ ' This TempleMon release is only available with english messages. It is'
ACZ ' published in this unfinished state because of heavy demand for symbol support.'
ACZ ' Better running releases will be available in the future also in german. Then'
ACZ ' a new program description will also be available. This relese can be'
ACZ ' considered FREEWARE.'
*)
(*
ACZ ' This is a beta version of TempleMon and is NOT to be considered FREEWARE! '
ASC ' It supports the FALCON030 machines but don' DC.B $27 ACZ 't ask for any information about'
ASC ' this machine which were necessary to implement FALCON support. You won' DC.B $27 ACZ 't get'
ACZ ' any information about any hidden registers even if you threaten to shoot me!'
*)
(*
ACZ '-------------------------------------------------------------------------------'
ACZ ' '
ACZ 'We hope that you will find TempleMon useful and that your bug-swatting problems'
ACZ 'are eased by this monitor.'
*)
ACZ ' '
ACZ 'The authors'
ACZ '  Johannes Hill and Thomas Tempelmann'
ACZ '-------------------------------------------------------------------------------'
ACZ 'Basic commands:'
(*$? MAC:
ACZ ' ES - aborts MagiCMac, returns to Finder'
*)
ACZ ' Q  - aborts interrupted program'
ACZ ' G  - continues program execution'
ACZ ' R  - register dump (R<reg>=<value> assigns a new value to a register)'
ACZ ' M  - memory dump (overwrite contents and press Return to change values)'
ACZ ' D  - disassembly (D RPC-20 Z15 shows 15 lines of code around current PC)'
ACZ '-------------------------------------------------------------------------------'
DC.B 0,0
*)

          SYNC
;

DrawTTBackGround
          MOVEM.L A0-A6/D0-D4,-(SP)
          MOVE.L  tmon_offset(A4),D0
          DIVU.W  #80,D0
          CLR.W   D0
          SWAP    D0
          MOVE.L  D0,tmon_offset(A4)
          LEA     -160(A7),A7                 ; Stapel als Puffer benutzen
          MOVE.L  A7,A5
          MOVE.L  pMonScreen(PC),A6
          LEA     BetaTitel(PC),A3            ; BetaTitel als Blockgrafik
          MOVE.W  #59,D2                      ; ZeilenzÑhler
DrawTTBackGround1
          MOVE.L  A5,A0
          MOVE.L  tmon_offset(A4),D0
          SUBQ.L  #1,D0
          BMI     DrawTTBackGround4
DrawTTBackGround2
          MOVE.B  (A3)+,(A0)+
          BNE.S   DrawTTBackGround3
          LEA     BetaTitel(PC),A3
          MOVE.B  (A3)+,-1(A0)
DrawTTBackGround3
          DBRA    D0,DrawTTBackGround2
DrawTTBackGround4
          MOVE.L  A5,A0                       ; genutzten Bereich mit Spaces
          ADDA.L  tmon_offset(A4),A0
          MOVE.L  #$20202020,D1
          MOVE.W  #19,D0
DrawTTBackGround5
          MOVE.L  D1,(A0)+
          DBRA    D0,DrawTTBackGround5
DrawTTBackGround01
          MOVEQ   #80,D0
          SUB.L   tmon_offset(A4),D0
          SUBQ.L  #1,D0
          BMI     DrawTTBackGround04
DrawTTBackGround02
          MOVE.B  (A3)+,(A0)+
          BNE.S   DrawTTBackGround03
          LEA     BetaTitel(PC),A3
          MOVE.B  (A3)+,-1(A0)
DrawTTBackGround03
          DBRA    D0,DrawTTBackGround02
DrawTTBackGround04
DrawTTBackGround6
          MOVE.L  A5,A1                       ; Blockgrafik auf Grafikschirm
          MOVE.L  A6,A2
          MOVE.L  #160,D4
          MOVEQ   #39,D0
          MOVEQ   #0,D1
          BSR     FastString16_8o
          LEA     2560(A6),A6
          DBRA    D2,DrawTTBackGround1
          LEA     160(A7),A7
          MOVEQ   #-1,D1
          MOVE.L  pMonScreen(PC),A0
          MOVE.L  tmon_offset(A4),D0
          BEQ     DrawTTBackGround8
          SUBQ.W  #1,D0
DrawTTBackGround7
          EOR.B   D1,(A0)+
          DBRA    D0,DrawTTBackGround7
DrawTTBackGround8
          MOVE.W  #80,D2
          MOVE.W  #958,D0
DrawTTBackGround9
          ADDA.W  D2,A0
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          EOR.L   D1,(A0)+
          DBRA    D0,DrawTTBackGround9
          ADDA.W  D2,A0
          MOVE.L  #80,D0
          SUB.L   tmon_offset(A4),D0
          BMI     DrawTTBackGround11
          BEQ     DrawTTBackGround11
          SUBQ.W  #1,D0
DrawTTBackGround10
          EOR.B   D1,(A0)+
          DBRA    D0,DrawTTBackGround10
DrawTTBackGround11
DrawTTBackGround12
          MOVEM.L (SP)+,A0-A6/D0-D4
          RTS

ClearBlockScrn
          MOVEM.L A0/A1/D0,-(SP)
          MOVE.L  bMonScreenBase(PC),A1
          MOVE.L  A1,D0
          LEA     bMonScreen(PC),A0
          MOVE.L  D0,(A0)
          LEA     bMonScreenUsed(PC),A0
          MOVE.L  D0,(A0)
          ADD.L   bMonScreenSize(PC),D0
          LEA     bMonScreenStop(PC),A0
          MOVE.L  D0,(A0)
          LEA     bMonScreenEnd(PC),A0
          MOVE.L  D0,(A0)
          MOVE.L  bMonScreenTop(PC),A0
          MOVE.L  #$20202020,D0
I_L       MOVE.L  D0,-(A0)
          CMPA.L  A1,A0
          BCC     I_L
          MOVEM.L (SP)+,A0/A1/D0
          RTS

ClearScrn1
(*$?~Mac:
          MOVEM.L A0-A2/D0-D4,-(A7)
          TST.B   share_screen(A4)       ; Bildschirm ist zu teilen?
          BNE.L   clrscrnweiseln         ; dann nur genutzten Bereich einweiûen
          TST     isTT(A4)               ; TT Groûbildschrim?
          BEQ     ClearScrn12            ; nein -> normale Routine
          TST     video_modus(A4)
          BEQ     ClearScrn12
          MOVEM.L (SP)+,A0-A2/D0-D4
          BRA     DrawTTBackGround
*)

ClearScrn ; BSR     SetScrnBufFirstLine    ; !MAC 11.04.95 (unsicher)
          CLR.W   CursorX(A4)
          CLR.W   CursorY(A4)
          TST.B   share_screen(A4)
          BNE.S   clrscrnshare
          TST     isTT(A4)
          BEQ.S   ClearScrn11
          TST     video_modus(A4)
          BEQ     ClearScrn11
          BSR     DrawTTBackGround
          BRA     ClearBlockScrn
ClearScrn11
(*$?~Mac:
          BSR     ClearBlockScrn
          MOVEM.L A0-A2/D0-D4,-(A7)
ClearScrn12
          MOVE.L  pMonScreen(PC),A0
          MOVE.L  video_memsize(A4),D0
          TST     video_modus(A4)
          BEQ.L   clrscrnweiseln
          SUBQ.L  #1,D0
          SWAP    D0
          MOVE.W  D0,D2
          SWAP    D0
          MOVEQ   #-1,D1              ; Bildschirm schwÑrzen
          CMPI.W  #1,video_plane(A4)
          BNE     clrScrnL0
          TST     isTT(A4)            ; TT Sonderbehandlung
          BNE     clrScrnL0
          SWAP    D2
          MOVE.B  mono_0(PC),D2
          ANDI.B  #1,D2
          BNE     clrScrnL01

          CLR.L   D1
clrScrnL01 SWAP   D2
clrScrnL0 MOVE.B  D1,(A0)+
          DBRA    D0,clrScrnL0
          DBRA    D2,clrScrnL0
          BRA.S   clrscrnweiseln
*)
clrscrnshare
          BSR     ClearBlockScrn
          MOVEM.L A0-A2/D0-D4,-(A7)

clrscrnweiseln                            ; dargestellten Bereich lîschen
                                          ; durch Beschreiben mit SPACEses
          MOVE.W  Rows(A4),D0
          SUBA.W  D0,A7
          MOVE.L  A7,A1
          MOVEQ   #$20,D1
          SUBQ    #1,D0
clrscrnweisln1
          MOVE.B  D1,(A1)+
          DBRA    D0,clrscrnweisln1
          MOVE.L  A7,A1
          MOVE.L  pMonScreen(PC),A2
          ADDA.L  tmon_offset(A4),A2
          MOVEQ   #0,D4
          MOVE.W  video_rowbytes(A4),D4
          MOVE.L  D4,D0
          MULU    CharHeight(A4),D0
          MOVE.L  D0,A0
          MOVE.W  Rows(A4),D0
          MOVEQ   #0,D1
          MOVE.W  Lines(A4),D2
          SUBQ.W  #1,D2
clrscrnweisln2
          CMPI.W  #1,video_plane(A4)
          BEQ     clrscrnweisln3
          BSR     FastString8_8
          BRA     clrscrnweisln4
clrscrnweisln3
          BSR     FastString16_8
clrscrnweisln4
          ADDA.L  A0,A2
          DBRA    D2,clrscrnweisln2
          ADDA.W  Rows(A4),A7
end_clrscr
          MOVEM.L (A7)+,A0-A2/D0-D4
          RTS

RestoreScrn
          MOVE.L  bMonScreen(PC),A1
          MOVE.L  pMonScreen(PC),A2
          ADDA.L  tmon_offset(A4),A2
          MOVE.W  video_rowbytes(A4),D4
          MOVE.W  Rows(A4),D0
          MOVE.W  Lines(A4),D1
          SUBQ.W  #1,D1
          CMPI.W  #1,video_plane(A4)
          BEQ.L   FastString16_8
          BRA.L   FastString8_8

ClearEoS  BSR     ClearEol
          MOVE    CursorX(A4),-(A7)
          MOVE    CursorY(A4),-(A7)
          CLR.W   CursorX(A4)
ClrEosL   ADDQ.W  #1,CursorY(A4)
          MOVE    CursorY(A4),D0
          CMP     Lines(A4),D0
          BCC     ClrEosE
          BSR     ClearEol
          BRA     ClrEosL
ClrEosE   MOVE    (A7)+,CursorY(A4)
          MOVE    (A7)+,CursorX(A4)
ScrnRTS   RTS

CopyLine  MOVEM.L D0/A2/A3,-(SP)      ; Eine Video-Zeile von A2 nach A3 kopieren
          TST     video_modus(A4)
          BEQ     copyL802
          
          ; hier bei Mac:
          MOVE    Rows(A4),D0
          MULU.W  video_plane(A4),D0
          LSR     #2,D0
          SUBQ    #1,D0
copyLin2  MOVE.L  (A2)+,(A3)+
          DBRA    D0,copyLin2
          MOVEM.L (SP)+,D0/A2/A3
          RTS
          
copyL802: ; 80 bzw. 160 byte kopiern
          BSR     copyL80
          CMPI.W  #1,video_plane(A4)
          BEQ     copyLE
          BSR     copyL80
copyLE:   MOVEM.L (SP)+,D0/A2/A3
          RTS

copyL80   ; 80 Byte auf einmal:
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          MOVE.L  (A2)+,(A3)+
          RTS


TextLine                                  ; Liefert in D0 Offset zur nÑch-
          MOVE.L  D2,-(SP)                ; sten Textzeile zurÅck,
          MOVEQ   #0,D1                   ; in D1 Bytes pro Videozeile,
          MOVE.W  video_rowbytes(A4),D1   ; in A0 Pointer auf Bildstart,
          MOVE.W  CharHeight(A4),D0       ; in A1 Pointer auf Bildende.
          MOVE.W  Lines(A4),D2
          MULU.W  D0,D2
          MULU.W  D1,D2
          MULU.W  D1,D0
          MOVE.L  pMonScreen(PC),A0
          ADDA.L  tmon_offset(A4),A0
          MOVE.L  A0,A1
          ADDA.L  D2,A1
          MOVE.L  (SP)+,D2
          RTS


ScrollUp
          BSR     MoveScrnBufUp
          TST     video_modus(A4)
          BEQ     FastScrollUp
          TST     isTT(A4)
          BNE.L   FastScrollTTUp
          ; dies bei Macs:
          MOVEM.L A0-A3/D0/D1,-(SP)
          BSR     TextLine
          MOVE.L  A0,A2
          MOVE.L  A0,A3
          ADDA.L  D0,A2
UpLoop    BSR     CopyLine         ; kopiert eine Video-Zeile (1/8 eines Chars)
          ADDA.L  D1,A2            ; rowBytes aufaddieren
          ADDA.L  D1,A3
          CMPA.L  A1,A2
          BCS     UpLoop
          MOVEM.L (SP)+,A0-A3/D0/D1
          RTS

FastScrollUp
          MOVEM.L A0-A6/D0-D7,-(SP)
          MOVE.L  pMonScreen(PC),A0
          MOVE.L  A0,A1
          ADDA.W  #1280,A1
          MOVEQ   #25,D0
FastScrollUpLoop
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,48(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,96(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,144(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,192(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,240(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,288(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,336(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,384(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,432(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,480(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,528(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,576(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,624(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,672(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,720(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,768(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,816(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,864(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,912(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,960(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,1008(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,1056(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,1104(A0)
          ADDA.W  #1152,A0
          DBRA    D0,FastScrollUpLoop
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,48(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,96(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,144(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,192(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,240(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,288(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,336(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,384(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,432(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,480(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,528(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,576(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,624(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,672(A0)
          MOVEM.L (A1)+,A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,720(A0)
          MOVEM.L (SP)+,A0-A6/D0-D7
          RTS

FastScrollTTUp
          MOVEM.L A0-A3/A5/D0-D7,-(SP)
          MOVE.L  pMonScreen(PC),A0
          ADDA.L  tmon_offset(A4),A0
          MOVE.L  A0,A1
          ADDA.W  #2560,A1
          MOVEQ   #58,D0
FastScrollTTUpLoop
          MOVEM.L (A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,(A0)
          MOVEM.L 40(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,40(A0)
          MOVEM.L 160(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,160(A0)
          MOVEM.L 200(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,200(A0)
          MOVEM.L 320(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,320(A0)
          MOVEM.L 360(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,360(A0)
          MOVEM.L 480(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,480(A0)
          MOVEM.L 520(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,520(A0)
          MOVEM.L 640(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,640(A0)
          MOVEM.L 680(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,680(A0)
          MOVEM.L 800(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,800(A0)
          MOVEM.L 840(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,840(A0)
          MOVEM.L 960(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,960(A0)
          MOVEM.L 1000(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1000(A0)
          MOVEM.L 1120(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1120(A0)
          MOVEM.L 1160(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1160(A0)
          MOVEM.L 1280(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1280(A0)
          MOVEM.L 1320(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1320(A0)
          MOVEM.L 1440(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1440(A0)
          MOVEM.L 1480(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1480(A0)
          MOVEM.L 1600(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1600(A0)
          MOVEM.L 1640(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1640(A0)
          MOVEM.L 1760(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1760(A0)
          MOVEM.L 1800(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1800(A0)
          MOVEM.L 1920(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1920(A0)
          MOVEM.L 1960(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,1960(A0)
          MOVEM.L 2080(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,2080(A0)
          MOVEM.L 2120(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,2120(A0)
          MOVEM.L 2240(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,2240(A0)
          MOVEM.L 2280(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,2280(A0)
          MOVEM.L 2400(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,2400(A0)
          MOVEM.L 2440(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,2440(A0)
          ADDA.W  #2560,A0
          ADDA.W  #2560,A1
          DBRA    D0,FastScrollTTUpLoop
          MOVEM.L (SP)+,A0-A3/A5/D0-D7
          RTS

ScrollDown
          BSR     MoveScrnBufDn
          TST     video_modus(A4)
          BEQ     FastScrollDown
          TST     isTT(A4)
          BNE.L   FastScrollTTDn
          MOVEM.L A0-A3/D0/D1,-(SP)
          BSR     TextLine
          SUBA.L  D1,A1            ; Anfang letzte Zeile
          MOVE.L  A1,A2
          MOVE.L  A1,A3
          SUBA.L  D0,A2
DownLoop  BSR     CopyLine
          SUBA.L  D1,A2
          SUBA.L  D1,A3
          CMPA.L  A0,A2
          BCC     DownLoop
          MOVEM.L (SP)+,A0-A3/D0/D1
          RTS

FastScrollDown
          MOVEM.L A0-A6/D0-D7,-(SP)
          MOVE.L  pMonScreen(PC),A0
          ADDA.W  #$7D00,A0
          MOVE.L  A0,A1
          SUBA.W  #1280+48,A1
          MOVEQ   #25,D0
FastScrollDownLoop
          MOVEM.L (A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -48(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -96(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -144(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -192(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -240(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -288(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -336(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -384(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -432(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -480(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -528(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -576(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -624(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -672(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -720(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -768(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -816(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -864(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -912(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -960(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -1008(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -1056(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -1104(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          SUBA.W  #1152,A1
          DBRA    D0,FastScrollDownLoop
          MOVEM.L (A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -48(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -96(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -144(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -192(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -240(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -288(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -336(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -384(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -432(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -480(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -528(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -576(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -624(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -672(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L -720(A1),A2-A6/D1-D7
          MOVEM.L A2-A6/D1-D7,-(A0)
          MOVEM.L (SP)+,A0-A6/D0-D7
          RTS

FastScrollTTDn
          MOVEM.L A0-A3/A5/D0-D7,-(SP)
          MOVE.L  pMonScreen(PC),A0
          ADDA.L  tmon_offset(A4),A0
          ADDA.L  #153600+40-160,A0
          MOVE.L  A0,A1
          SUBA.W  #2560,A1
          MOVEQ   #58,D0
FastScrollTTDnLoop
          MOVEM.L (A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,(A0)
          MOVEM.L -40(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-40(A0)
          MOVEM.L -160(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-160(A0)
          MOVEM.L -200(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-200(A0)
          MOVEM.L -320(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-320(A0)
          MOVEM.L -360(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-360(A0)
          MOVEM.L -480(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-480(A0)
          MOVEM.L -520(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-520(A0)
          MOVEM.L -640(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-640(A0)
          MOVEM.L -680(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-680(A0)
          MOVEM.L -800(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-800(A0)
          MOVEM.L -840(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-840(A0)
          MOVEM.L -960(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-960(A0)
          MOVEM.L -1000(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1000(A0)
          MOVEM.L -1120(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1120(A0)
          MOVEM.L -1160(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1160(A0)
          MOVEM.L -1280(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1280(A0)
          MOVEM.L -1320(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1320(A0)
          MOVEM.L -1440(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1440(A0)
          MOVEM.L -1480(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1480(A0)
          MOVEM.L -1600(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1600(A0)
          MOVEM.L -1640(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1640(A0)
          MOVEM.L -1760(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1760(A0)
          MOVEM.L -1800(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1800(A0)
          MOVEM.L -1920(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1920(A0)
          MOVEM.L -1960(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-1960(A0)
          MOVEM.L -2080(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-2080(A0)
          MOVEM.L -2120(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-2120(A0)
          MOVEM.L -2240(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-2240(A0)
          MOVEM.L -2280(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-2280(A0)
          MOVEM.L -2400(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-2400(A0)
          MOVEM.L -2440(A1),A2/A3/A5/D1-D7
          MOVEM.L A2/A3/A5/D1-D7,-2440(A0)
          SUBA.W  #2560,A0
          SUBA.W  #2560,A1
          DBRA    D0,FastScrollTTDnLoop
          MOVEM.L (SP)+,A0-A3/A5/D0-D7
          RTS

CursorDown
          MOVEM.L A0/D0-D2,-(SP)
          ADDQ.W  #1,CursorY(A4)
          MOVE    CursorY(A4),D0
          CMP     Lines(A4),D0
          BCS     CurDE
          MOVE.W  Lines(A4),D0            ; Ergebnis korrigieren
          SUBQ.W  #1,D0
          MOVE    D0,CursorY(A4)
          BSR     TestButtom
          TST     D0
          BEQ     CursorDown1
          BSR     ScrollUp
          BRA     CurDC
CursorDown1
          BSR     ScrollUp
          MOVE.L  bMonScreenUsed(PC),D1
          MOVE.L  bMonScreenEnd(PC),D0
          LEA     bMonScreenStop(PC),A0
          CMP.L   (A0),D1
          BNE     CursorDown2
          MOVE.L  D0,(A0)
          LEA     bMonSCreenUsed(PC),A0
CursorDown2
          MOVE.L  D0,(A0)                ; bMonScreenStop umsetzen
          MOVE    CursorX(A4),-(A7)
          CLR.W   CursorX(A4)
          BSR     ClearEOL
          MOVE.W  (A7)+,CursorX(A4)
          MOVEM.L (SP)+,A0/D0-D2
          RTS

CurDC     MOVE    CursorX(A4),-(A7)
          CLR.W   CursorX(A4)
          CLR.L   D1
          MOVE.W  Rows(A4),D2
          SUBQ.W  #1,D2
CurDI     MOVE.W  D2,-(SP)
          BSR     ScrnGet
          BSR     DispChar2
          ADDI.W  #1,CursorX(A4)
          MOVE.W  (SP)+,D2
          DBRA    D2,CurDI
          MOVE    (A7)+,CursorX(A4)
CurDE     MOVEM.L (SP)+,A0/D0-D2
          RTS

CursorUp  MOVEM.L A0/D0-D2,-(SP)
          SUBQ.W  #1,CursorY(A4)
          BPL     CurDE
          CLR     CursorY(A4)             ; Cursor am Bildschirmrand
          BSR     TestTop                 ; Cursor ganz oben?
          TST     D0
          BEQ     CurDE                   ; dann nichts unternehmen!
          BSR     ScrollDown
          BRA     CurDC

ChkCursor MOVE    CursorX(A4),D0
          CMP     Rows(A4),D0
          BCS     ScrnRTS
          CLR.W   CursorX(A4)
          BRA     CursorDown

IncCursor ADDQ.W  #1,CursorX(A4)
          MOVE    CursorX(A4),D0
          CMP     Rows(A4),D0
          BLS     ScrnRTS
          CLR.W   CursorX(A4)
          BRA     CursorDown

DecCursor SUBQ.W  #1,CursorX(A4)
          BCC     ScrnRTS
          MOVE    Rows(A4),CursorX(A4)
          SUBQ.W  #1,CursorX(A4)
          BRA     CursorUp

BackSpace BSR     DecCursor
          MOVEQ   #0,D1
          MOVEQ   #' ',D1
          BRA     DispChar

ScrnCurOn MOVE.L  BlinkRate(PC),CursorCnt(A4)
          BSR     ChkCursor
          TST     CursorState(A4)
          BNE     CurOnE
          BSR     ScrnGet
          MOVEQ   #-1,D1
          BSR     DispChar
          MOVE    #1,CursorState(A4)
CurOnE    RTS

ScrnCurOff
          MOVE.L  BlinkRate(PC),CursorCnt(A4)
          TST     CursorState(A4)
          BEQ     CurOffE
          MOVE    D0,-(A7)
          BSR     ScrnGet
          MOVEQ   #0,D1
          BSR     DispChar
          MOVE    (A7)+,D0
          CLR     CursorState(A4)
CurOffE   RTS

ScrnCR    CLR.W   CursorX(A4)
          RTS

!ScrnOut  BSR     ScrnCurOff
          BTST    #13,D7        ; DirConOut ?
          BNE     ScrnOutC0
          CMPI    #SPC,D0
          BCC     ScrnOutC0
          CMPI    #CR,D0
          BEQ     ScrnCR
          CMPI    #LF,D0
          BEQ     CursorDown
          CMPI    #BS,D0
          BEQ     BackSpace
          CMPI    #FF,D0
          BEQ     ClearScrn
          CMPI    #ClEol,D0
          BEQ     ClearEoL
          CMPI    #ClEoS,D0
          BEQ     ClearEoS
          CMPI    #Con,D0
          BEQ     ScrnCurOn
          CMPI    #Coff,D0
          BEQ     ScrnCurOff
          RTS

ScrnOutC0 MOVE    D0,-(A7)
          BSR     ChkCursor
          MOVE    (A7)+,D0
          MOVEQ   #0,D1
          BSR     DispChar
          BRA     IncCursor

!ScrnOutput                       ; Bildschirmausgabe ohne Controllzeichen!
          BSR     ScrnCurOff
          MOVE    D0,-(SP)
          BSR     ChkCursor
          MOVE    (SP)+,D0
          MOVEQ   #0,D1
          BRA     DispChar


!CursorOn MOVEM.L D0-D5/A0/A1,-(A7)
          BSR     ScrnCurOn
          MOVEM.L (A7)+,D0-D5/A0/A1
          RTS

!CursorOff
          MOVEM.L D0-D5/A0/A1,-(A7)
          BSR     ScrnCurOff
          MOVEM.L (A7)+,D0-D5/A0/A1
CurBlnkE  RTS

!CursorBlink
          TST.L   CursorCnt(A4)
          BEQ     CurBlnkE              ; kein Blinken, wenn Rate = 0
          SUBQ.L  #1,CursorCnt(A4)
          BNE     CurBlnkE
          TST     CursorState(A4)
          BEQ     CursorOn
          BRA     CursorOff

!ScrnPrt  MOVE.W  PrHandle(A4),-(SP)
          CLR.W   PrHandle(A4)
          BSR.S   Prt
          MOVE.W  (SP)+,PrHandle(A4)
          RTS

!Prt      ANDI.W  #$FF,D0
          MOVE.B  D0,ch(A4)
          MOVEM.L D0-D5/A0-A2,-(A7)

          TST.B   NoScrDisp(A4)
          BNE     noPrt
          BSR     ScrnOut
noPrt
          MOVE.B  ch(A4),D0
FPrt1     ;ANDI    #$7F,D0
          BCLR    #13,D7          ; Ctrl-Zeichen sichtbar ?
          BEQ     noPConv
          CMPI.B  #' ',D0
          BCC     noPConv
          MOVEQ   #'.',D0
noPConv   TST.W   PrHandle(A4)
          BEQ     PrtE
          CMPI.B  #32,D0
          BCC     chrOk
          CMPI.B  #FF,D0
          BEQ     chrOk           ; LF wird ignoriert, stattdessen immer bei CR:
          CMPI.B  #CR,D0
          BNE     PrtE
          BCLR    #16,D7          ; CR unterdrÅcken?
          BNE     PrtE
chrOk     MOVE.B  D0,ch(A4)
          LEA     ch(A4),A0
          MOVE.L  A0,-(A7)
          MOVE.L  #1,-(A7)
          MOVE    PrHandle(A4),-(A7)
          MOVE    #$40,-(A7)
          TRAP    #1
          ADDA.W  #12,A7
          TST.L   D0
          BMI     PrtE0
          CMPI.B  #CR,ch(A4)
          BNE     PrtE
          MOVE.B  #LF,D0
          BRA     chrOK
PrtE0     BSR.L   PrntCloseErr
PrtE      MOVEM.L (A7)+,D0-D5/A0-A2
          RTS

!NextSTAB TST     is20(A4)
          BEQ.L   NextTAB
          MOVEM.L D0/D1,-(SP)
          clr.l   d1
          MOVE.W  CursorX(A4),D1
          DIVU.W  #SR_TAB,D1
          SWAP    D1
          TST.W   D1
          BEQ     DOSTAB
          SWAP    D1
          ADDQ.W  #1,D1
          MULU.W  #SR_TAB,D1
DOSTAB    CMPI.W  #18,D1
          BNE     TABSLOOP
          MOVEQ   #16,D1
TABSLoop  BSR.L   PRTSPC
          CMP.W   CursorX(A4),D1
          BCC     TABSLoop
          MOVEM.L (SP)+,D0/D1
EndSTAB   RTS
!NextFPTAB
          BCLR    #6,D7
          CMPI.W  #FP1TAB,CursorX(A4)
          BEQ     EndTAB
          BCS     DoRegTAB
          MOVEM.L D0/D1,-(SP)
          MOVEQ   #FP2TAB,D1
          CMPI.W  #FP2TAB,CursorX(A4)
          BLS     DoTAB
          BSET    #6,D7
          MOVEM.L (SP)+,D0/D1
          RTS
!ChkFPTAB BCLR    #6,D7
          CMPI.W  #FP1TAB,CursorX(A4)
          BHI     EndTAB
          MOVEM.L D0/D1,-(SP)
          MOVEQ   #FP1TAB,D1
          BRA     DoTAB
!DoRegTAB MOVEM.L D0/D1,-(SP)
          MOVEQ   #RegPos,D1
          BRA     DoTAB
!NextTAB  MOVEM.L D0/D1,-(SP)
          clr.l   d1
          MOVE.W  CursorX(A4),D1
          DIVU.W  #Tabulator,D1
          SWAP    D1
          TST.W   D1
          BEQ     TABLoop
          SWAP    D1
          ADDQ.W  #1,D1
          MULU.W  #Tabulator,D1
TABLoop   BSR.L   PRTSPC
DoTAB     CMP.W   CursorX(A4),D1
          BCC     TABLoop
NoTAB     MOVEM.L (SP)+,D0/D1
EndTAB    RTS

!PRTPRMPT BSR     PRTCRLF
!PRTPRMPT1
          MOVEQ   #CR,D0                ; Cursor auf 1. Spalte setzen
          BSR     ScrnPrt
          MOVEQ   #PROMPT,D0
          BSR     Prt
          BRA     ClearEOL

!PRTNEWPRMPT
          BSR     PRTCRLF
!PRTNEWPRMPT1
          MOVEQ   #CR,D0                ; Cursor auf 1. Spalte setzen
          BSR     PRT
;          BSR     ScrnPrt
          BSR     ScrnGet               ; Inhalt der 1. Spalte holen
          CMPI.B  #PROMPT,D0            ; ist es der Prompt?
          BNE     PRTPRMPT1             ; nein: dann Zeile initialisieren
          BSR     Prt                   ; Cursor auf 2. Spalte setzen, beim
                                        ; Protokollfile PROMPT ausgeben
          BSR     ScrnGet               ; Inhalt der 2. Spalte holen
          BSR.L   CAPS
          CMPI.B  #',',D0               ; fÅr noch nicht enthaltenen , Befehl
          BEQ     PRTNEWPRMPT2
          CMPI.B  #'>',D0               ; fÅr noch nicht enthaltenen ,(>) Befehl
          BEQ     PRTNEWPRMPT2
          CMPI.B  #'^',D0               ; fÅr noch nicht enthaltenen ,(^) Befehl
          BEQ     PRTNEWPRMPT2
          CMPI.B  #'|',D0               ; Kommentar
          BEQ     PRTNEWPRMPT2
          LEA     CMDTBEG(PC),A0
          LEA     CMDTEND(PC),A1
PRTNEWPRMPTLOOP                         ; befindet sich darin ein gÅltiger
          CMP.B   (A0)+,D0              ; Befehlsmarker?
          BEQ     PRTNEWPRMPT2          ; ja: dann nicht Zeile initalisieren
          CMPA.L  A1,A0
          BLT     PRTNEWPRMPTLOOP
          BRA     PRTPRMPT1
PRTNEWPRMPT2
          BRA.L   GetKeyBuf             ; gÅltiges: Zeile in Keyboardpuffer holen

!PRTNEWLINE                             ; Zeilenrest hinter Cursor nicht lîschen
          MOVEQ   #CR,D0
          BSR     PRT
          MOVEQ   #LF,D0
          BRA     PRT

!PRTCR    MOVEQ   #CR,D0
          BRA     PRT

!PRTDCRLF BCLR    #11,D7
          BNE.L   PCRLFC0         ; KEIN LF AUSGEBEN
          MOVEQ   #CR,D0
          BSR     PRT
          BRA     PRTLF

!PRTCRLF  BCLR    #11,D7
          BNE.L   PCRLFC0         ; KEIN LF AUSGEBEN

          MOVEQ   #ClEol,D0       ; ZEILE AB CURSOR LOESCHEN
          BSR     PRT
          MOVEQ   #CR,D0
          BSR     PRT
!PRTLF    MOVEQ   #LF,D0
          BRA     PRT

PCRLFC0   MOVEQ   #CR,D0
          BSR     PRT
          MOVEQ   #ClEol,D0       ; ZEILE ganz LOESCHEN
          BRA     PRT

!PRTSPC   MOVEQ   #SPC,D0
          BRA     PRT

!PRTMSPCL BSR     PRTSPC
!PRTMSPC  DBF     D1,PRTMSPCL     ; (D1)+1 SPACES AUSGEBEN
          RTS

!CONVREAL TST     isFPU(A4)
          BNE.S   PRTREALOK
!NoCONVREAL
          CLR.B   REALSTR(A4)
          RTS
!PRTREALOK
          TST     isFPU(A4)
          BNE     NoCONVREAL
          CLR.L   D0
          LEA     REALREAL(A4),A0  ; Real muû im Extended Format vorliegen!
          MOVE.W  (A0),D0
          BSET    #15,D0
          NOT.W   D0               ; Infinity or NAN ?
          BEQ.L   NoREAL
          FMOVE.X (A0),FP0
          FMOVE.P FP0,(A0){17}
!CONVREAL1
          LEA     REALSTR(A4),A1
          MOVE.B  #SPC,D0
          BTST.B  #7,(A0)
          BEQ.S   PRTREAL1
          MOVE.B  #'-',D0
PRTREAL1  MOVE.B  D0,(A1)+
          MOVE.L  A0,A2
          ADDQ.L  #3,A2            ; erst mal Mantisse bearbeiten!
          MOVE.B  (A2)+,D0         ; 1. Stelle
          UNPK    D0,D0,#$0030
          MOVE.B  D0,(A1)+
          MOVE.B  #'.',(A1)+
          MOVEQ   #7,D1
PRTREAL2  MOVE.B  (A2)+,D0         ; alle Nachkommastellen
          UNPK    D0,D0,#$3030
          MOVE.W  D0,(A1)+
          DBRA    D1,PRTREAL2
          MOVE.B  #'E',(A1)+
          MOVE.B  #'+',D0
          BTST.B  #6,(A0)
          BEQ.S   PRTREAL3
          MOVE.B  #'-',D0
PRTREAL3  MOVE.B  D0,(A1)+
          MOVE.L  A0,A2
          MOVE.B  (A2)+,D0
          ANDI.B  #$F,D0
          UNPK    D0,D0,#$3030     ; die hîherwertige Ziffer ist immer Null!
          MOVE.W  D0,D1            ; sie fÑllt dann heraus, wenn eine 4. Stelle
          LSL.L   #8,D1            ; in der BCD Darstellung vorhanden ist
          LSL.L   #8,D1
          MOVE.B  (A2)+,D0
          UNPK    D0,D0,#$3030
          MOVE.W  D0,D1
          MOVE.B  (A2)+,D0
          ANDI.B  #$F0,D0
          BEQ.S   PRTREAL4         ; nur dreistelliger Exponent
          UNPK    D0,D0,#$3000
          LSR.W   #8,D0
          LSL.L   #8,D1
          MOVE.B  D0,D1
PRTREAL4  MOVE.L  D1,(A1)+
          CLR.B   (A1)
          RTS
PRTREAL   BSR     CONVREAL
          LEA     REALSTR(A4),A1
          BRA.S   PRTSTR

NoREAL    LEA     REALSTR(A4),A2
          MOVE.L  4(A0),D0
          BCLR    #31,D0              ; Mantissa : Sign
          TST.L   D0
          BNE.S   NoREALNAN
          TST.L   8(A0)
          BNE.S   NoREALNAN
          MOVE.B  #'+',D0
          BTST.B  #7,(A0)
          BEQ.S   NoREAL1
          MOVE.B  #'-',D0
NoREAL1   BSR     RPRT
          LEA     InfinityMsg(PC),A1
          BRA.S   RPRTSTR
NoREALNAN LEA     NSNANMsg(PC),A1
          MOVE.B  4(A0),D0
          ANDI.B  #$40,D0
          BNE.S   RPRTSTR
          LEA     SNANMsg(PC),A1
RPRTSTR   MOVE.B  (A1)+,(A2)+
          BNE     RPRTSTR
          RTS
RPRT      MOVE.B  D0,(A2)+
          RTS

!PRTSTR   MOVE.B  (A1)+,D0
          BNE     PRTSTRC0
          RTS
PRTSTRC0  BSR     PRT
          BRA     PRTSTR

!PRTADR   TST.W   is20(A4)
          BNE.S   PrtLong
          SWAP    D0
          BSR.S   PRTBYTE
          BRA.S   PRTLONG1

!PRTLONGXL MOVE.L D3,D0
          BSR.S   PRTLONG
          MOVE.L  D2,D0
          BSR.S   PRTLONG
          MOVE.L  D1,D0

!PRTLONG  SWAP    D0
          BSR.S   PRTWORD
!PRTLONG1 SWAP    D0

!PRTWORD  MOVE.W  D0,-(A7)
          LSR.W   #8,D0
          BSR.S   PRTBYTE
          MOVE.W  (A7)+,D0

!PRTBYTE  MOVE.B  D0,-(A7)
          LSR.B   #4,D0
          BSR.S   PRTNIBL
          MOVE.B  (A7)+,D0

!PRTNIBL  ANDI.B  #$F,D0
          ORI.B   #$30,D0
          CMPI.B  #'9',D0
          BLS.S   PRTNIBL1
          ADDQ.B  #7,D0
!PRTNIBL1 BRA     Prt

!Wvbl     ; Warten auf Vertical Blank
(*$? ~MAC:
          MOVEP.W 5(A1),D1
          CMP.W   D0,D1
          BEQ     Wvbl
Wvbl2     MOVEP.W 5(A1),D1
          CMP.W   D0,D1
          BNE     Wvbl2
*)
          RTS

pMonScreen
          DS      4             ; ^ Monitor-Screen
rMonScreen
          DS      2             ; ^ Monitor-Screen (nur Mid-Bytes!)
rNormScreen
          DS      4             ; ^ Normale Screen (nur Mid-Bytes!)

;*****************************************************************

; TempleMon Cookieteilfunktionen

!CookieRoutine0
          MOVE.L  A4,D0            ; Pointer auf lokale Variablen
          LEA     StackSize(PC),A0 ; Pointer auf Patchvariablen
          BSR.L   WhichCPU         ; CPU Typ nach D1
          RTS
!CookieRoutine4
          MOVE.L  pMonScreen(PC),A0
          MOVE.L  video_size(A4),D1
          MOVE.L  tmon_offset(A4),A1
          RTS
!CookieRoutine13
          LEA     OnLineHelp(A4),A3
          BSR.L   CookieR2S
          LEA     RoutinenPointer(PC),A1
          MOVE.L  A1,D1
          LEA     REGBEG(A4),A1
          RTS
!CookieRoutine17
          LEA     Makros(A4),A3
          BSR.L   CookieR2S
          LEA     RoutinenPointer(PC),A1
          MOVE.L  A1,D1
          LEA     REGBEG(A4),A1
          RTS
!Get_pMonScreen
          LEA     pMonScreen(PC),A3
          RTS

(*$? MAC:

(*
extern pascal OSErr SetDepth (GDHandle gd, short depth, short whichFlags, short flags)
 THREEWORDINLINE(0x303C, 0x0A13, 0xAAA2);
extern pascal short HasDepth (GDHandle gd, short depth, short whichFlags, short flags)
 THREEWORDINLINE(0x303C, 0x0A14, 0xAAA2);
*)

; static asm long getDeviceMode (GDHandle dev, short depth)
; input: depth = 1,2,4,8,16 o. 32
; return: 0: nicht einstellbar, sonst Wert ab $80, der an InitGDevice zu übergeben ist.
; Die Flags (z.B. Farbe o. Graustufen) sind über (**dev).gdFlags abzuwickeln
getDeviceMode:
        LINK       A6,#-60
        MOVEM.L    D3/A2,-(A7)
        MOVEA.L    8(A6),A0
        MOVEA.L    (A0),A1
        MOVEA.L    $11C,A0              ; UTableBase
        MOVE.W     (A1),D0
        NEG.W      D0
        SUBQ.W     #$1,D0
        LSL.W      #2,D0
        MOVEA.L    $00(A0,D0.W),A1
        MOVEA.L    (A1),A1
        LEA        -$0038(A6),A0
        MOVE.B     $0028(A1),$0031(A0)
        CLR.B      $0032(A0)
        MOVE.W     #$0003,$0028(A0)
        MOVE.W     #$0001,$002A(A0)
        MOVE.W     #$0001,$002C(A0)
        MOVE.B     #$01,$0030(A0)
        MOVEQ      #$15,D0
        dc.w       $A06E                ; _SNextTypeSRsrc
        BNE.S      e1
        MOVEA.L    $0004(A0),A2
        MOVE.W     #$007F,D3
l1:     ADDQ.W     #$1,D3
        MOVE.B     D3,$0032(A0)
        MOVE.L     A2,$0004(A0)
        MOVEQ      #$06,D0
        dc.w       $A06E                ; _SFindStruct
        BNE.S      e1
        MOVE.B     #$01,$0032(A0)
        MOVEQ      #$05,D0
        dc.w       $A06E                ; _SGetBlock
        BNE.S      e1
        MOVEA.L    (A0),A1
        MOVE.W     $0020(A1),D1
        MOVE.L     A0,-(A7)
        MOVEA.L    A1,A0
        dc.w       $A01F                ; _DisposePtr
        MOVEA.L    (A7)+,A0
        CMP.W      12(A6),D1
        BNE.S      l1
        MOVE.W     D3,D0
        BRA        e2
e1:     CLR        D0
e2:     MOVEM.L    (A7)+,D3/A2
        EXT.L      D0
        UNLK       A6
        RTS

; static pascal asm OSErr shortSetDepth
;   (short testOnly, GDHandle gdh, short depth, short whichFlags, short flags)
; diese Funktion ist eine Vereinfachung von SetDepth. Hierbei wird u.A. ein MenuBar-Aufruf unterlassen,
; der bei gesperrten Interrupts zu Hängern führen kann, weil Disk-Zugriffe dabei durchgeführt
; werden (vermutlich durch OSA Menu). Diese Funktion wird zwar hier nicht benötigt, weil
; beim Umschalten die Interrupts nicht gesperrt sind, jedoch beim Templemon.
shortSetDepth:
        link     a6,#0
        move.l   14(a6),a0        ; gdh
        move.l   (a0),a1
        tst.w    18(a6)           ; testOnly?
        bne      noFlags
        ; set flags
        move     10(a6),d0        ; whichFlags
        andi     #$ff,d0
        move     d0,d1
        and      8(a6),d1        ; flags
        not      d0
        and.w    20(a1),d0        ; (**gdh).gdFlags
        or       d1,d0
        move.w   d0,20(a1)        ; (**gdh).gdFlags
noFlags ; get driver mode
        move.w   12(a6),-(a7)    ; depth
        move.l   a0,-(a7)
        bsr      getDeviceMode
        move.l   (a7)+,a0
        addq.l   #2,a7
        beq      error
        tst.w    18(a6)           ; testOnly?
        bne      retZero
        move.l   (a0),a1
        move.w   (a1),-(a7)        ; (**gdh).gdRefNum
        move.l   d0,-(a7)        ; mode
        move.l   a0,-(a7)        ; gdh
        dc.w     $AA2E           ; _InitGDevice
retZero clr.w    d0
        bra      ende
error:  moveq    #-50,d0
ende:   unlk     a6
        move.l   (a7)+,a0
        adda.w   #12,a7
        jmp      (a0)

hasDepth: ; liefert 0 in D0.B, wenn Bit-Tiefe nicht einstellbar ist
          BSR.W     mode_mac
          move.l    d1,-(a7)
          move.l    d0,d1
          move.l    a5,-(a7)
          move.l    originalA5(A4),A5
          SUBQ.L    #4,A7
          DC.W      $AA2A               ; _GetMainDevice
          move.l    (a7)+,d0            ; GDHandle
          st        -(a7)               ; flag: check the depth
          move.l    d0,-(a7)
          move.w    d1,-(a7)
          move.w    #1,-(a7)
          swap      d1
          move.w    d1,-(a7)
          bsr       shortSetDepth
          move.l    (a7)+,a5
          move.l    (a7)+,d1
          tst.w     d0
          seq       d0
          BRA.W     mode_atari

getDepth: BSR.W     mode_mac
          move.l    a5,-(a7)
          move.l    originalA5(A4),A5
          SUBQ.L    #4,A7
          DC.W      $AA2A               ; _GetMainDevice
          MOVE.L    (A7),A0
          SUBQ.L    #2,A7
          move.l    a0,-(a7)
          clr.w     -(a7)
          DC.W      $AA2C               ; _TestDeviceAttribute (dev, 0)
          clr       d0
          MOVE.B    (A7)+,d0
          swap      d0
          MOVE.L    (A7)+,A0
          move.l    a0,a1
          MOVE.L    (A0),A0
          MOVE.L    22(A0),A0
          MOVE.L    (A0),A0
          MOVE.W    32(a0),D0           ; pixelSize
          move.l    (a7)+,a5
          BRA.W     mode_atari

setDepth: BSR.W     mode_mac
          move.l    d1,-(a7)
          move.l    d0,d1
          move.l    a5,-(a7)
          move.l    originalA5(A4),A5
          SUBQ.L    #4,A7
          DC.W      $AA2A               ; _GetMainDevice
          move.l    (a7),d0             ; GDHandle duplizieren
          clr.w     -(a7)               ; flag: check the depth
          move.l    d0,-(a7)
          move.w    d1,-(a7)
          move.w    #1,-(a7)
          swap      d1
          move.w    d1,-(a7)
          (* nicht gut, weil bei installiertem OSA Menu und gesperrten Intrs d. Rechner hÑngt:
          move.w    #$0A13,D0
          DC.W      $AAA2               ; _SetDepth
          MOVE.w    (A7)+,d0
          *)
          bsr       shortSetDepth       ; Dies ist besser
          move.l    (a7)+,a1            ; GDHandle
          MOVE.L    (A1),A0
          MOVE.L    22(A0),A0
          MOVE.L    (A0),A0
          MOVE.W    4(a0),D0            ; rowBytes
          ANDI      #$3FFF,D0
          move.l    (a7)+,a5
          move.l    (a7)+,d1
          BRA.W     mode_atari


!NormScrn ; Normale Screen anzeigen
          TST.B   IsMonScreen(A4)
          BEQ     NormScrn2             ; no change
          SF      IsMonScreen(A4)
          move.l  currMacDepth(a4),d0
          bsr     setDepth
          TST.L   pOffScreen(A4)
          BEQ     NormScrn2             ; there's no offscreen buffer
          ; swap both screen buffers
          MOVEM.L D0-D7/A0-A3,-(A7)
          MOVE.L  pOffScreen(A4),A0
          LEA     pMonScreen(PC),A1
          MOVE.L  A0,(A1)
          MOVE.L  pVisScreen(A4),A1
          MOVE.W  video_lines(A4),D2
          SUBQ    #1,D2
          MOVE.W  orig_rowbytes(A4),D3
          MOVE.W  orig_visbytes(A4),D1
          SUB.W   D1,D3
          LSR.W   #2,D1
          SUBQ    #1,D1
          MOVE    D1,D4
NormScrn1 MOVE.L  (A0)+,(A1)+
          DBRA    D1,NormScrn1
          ADDA.W  D3,A1
          MOVE    D4,D1
          DBRA    D2,NormScrn1
          
          ; set ColorsChanged flag
          move.l  #$4D674D63,D1       ; 'MgMc' cookie suchen
          movea.l $05A0,A0
search2:  cmp.l   (A0),D1
          beq     dotmon2
          addq.l  #8,A0
          tst.l   (A0)
          bne.s   search2
          bra     NormScrn3
dotmon2:  move.l  4(A0),a0
          move.l  MgMcCookie.updatePalette(a0),a0
          st      (a0)

NormScrn3 MOVEM.L (A7)+,D0-D7/A0-A3
NormScrn2 RTS


!MonScrn  ; Monitor-Screen anzeigen
          MOVEM.L D0-D7/A0-A3,-(A7)
          TST.B   IsMonScreen(A4)
          BNE     MonScrn4             ; no change
          ST      IsMonScreen(A4)
          TST.L   pOffScreen(A4)
          BEQ     MonScrn2             ; there's no offscreen buffer
          ; MagiC-Screen in pOffScreen sichern
          MOVE.L  pVisScreen(A4),A0
          LEA     pMonScreen(PC),A1
          MOVE.L  A0,(A1)
          MOVE.L  pOffScreen(A4),A1
          MOVE.W  video_lines(A4),D2
          SUBQ    #1,D2
          MOVE.W  orig_rowbytes(A4),D3
          MOVE.W  orig_visbytes(A4),D1
          SUB.W   D1,D3
          LSR.W   #2,D1
          SUBQ    #1,D1
          MOVE    D1,D4
MonScrn1  MOVE.L  (A0)+,(A1)+
          DBRA    D1,MonScrn1
          ADDA.W  D3,A0
          MOVE    D4,D1
          DBRA    D2,MonScrn1
MonScrn2  bsr     getDepth
          move.l  d0,currMacDepth(a4)
          moveq   #0,d0
          move.w  video_plane(A4),D0
          bsr     setDepth      ; liefert in D0 die akt. RowBytes
          move.w  d0,video_rowbytes(a4)
          BSR     RestoreScrn
MonScrn4  MOVEM.L (A7)+,D0-D7/A0-A3
          RTS

!ShowMonScrn  ; Monitor-Screen anzeigen
          RTS   ;!!!MAC: fehlt noch f. SysMon
*)

(*$? ~MAC:
!NormScrn ; Normale Screen anzeigen
          TST.W   Unknown(A4)
          BEQ     NormScrnOrgRoutine
          TST.L   SwitchOrgScreen(A4)
          BEQ     NormScrnOrgRoutine
          MOVE.B  SysMonCall(A4),D0
          ASL.W   #8,D0
          MOVE.B  TempleMonCall(A4),D0
          MOVE.L  SwitchOrgScreen(A4),-(SP)
          RTS
!NormScrnOrgRoutine
          TST     isFALCON030(A4)
          BEQ     MonScrSysMon2
          LEA     rNormScreen(PC),A0
          BRA.L   RestoreFALCON030ScreenMode
MonScrSysMon2
          MOVE    SR,-(A7)
          ORI     #$0700,SR
          MOVEM.L D0/A0/A1,-(A7)
          LEA     farbe2(A4),A0
          TST.B   SysMonCall(A4)
          BNE.L   MonScrSysMon
          TST.B   TempleMonCall(A4)
          BNE.L   MonScrSysMon
          LEA     $FFFF8200,A1
          MOVEP.W 1(A1),D0
          CMP.W   rMonScreen(PC),D0
          BNE.L   MonScrE0
          LEA     farbe(A4),A0                  ; Farben restaurieren
MonScrSysMon
          MOVE.W  (A0)+,$40(A1)
          TST     isTT(A4)
          BEQ     MonScrnormST
          MOVE.W  (A0)+,$FFFF85FC
          MOVE.W  (A0)+,$FFFF85FE
          BRA     MonScrC0
MonScrnormST
          MOVE.W  (A0)+,$42(A1)
          MOVE.W  (A0)+,$44(A1)
          MOVE.W  (A0),$46(A1)
MonScrC0
          TST.B   SysMonCall(A4)
          BNE.S   MonScrC01
          TST.B   TempleMonCall(A4)
          BNE.S   MonScrC01
          MOVE.B  rNormScreen+2(PC),$60(A1)     ; alte Auflîsung zurÅck
          TST     isTT(A4)
          BEQ     NormScrC1
          MOVE.W  TT_Shift_Mode(A4),$62(A1)
NormScrC1 MOVEP.W 1(A1),D0
          BSR     Wvbl
          MOVE.W  rNormScreen(PC),D0            ; Video Base zurÅck
          MOVEP.W D0,1(A1)
          TST     isTT(A4)
          BNE     NormScrC01
          TST     isSTE(A4)
          BEQ     MonScrC01                     ; normaler ST kein LOW v_base
NormScrC01
          MOVE.B  rNormScreen+3(PC),D0          ; LOW Video Base zurÅck
          MOVE.B  D0,$FFFF820D
          MOVE.B  Video_Base_Adress_Offset(PC),D0
          MOVE.B  D0,$FFFF820F
          MOVE.B  Video_Line_Adress_Offset(PC),D0
          MOVE.B  D0,$FFFF8265
MonScrC01
          TST.L   OSTT(A4)
          BNE     MonScrOSTest
          TST     isTT(A4)
          BNE     MonScrE0
          TST     isSTE(A4)
          BNE     MonScrE0
MonScrOSTest
          BSR.L   OverScanTest                  ; normaler ST: OverScan zurÅck?
          LEA     entry_video_modus2(A4),A0
          TST.B   SysMonCall(A4)
          BNE.S   MonScrC02
          TST.B   TempleMonCall(A4)
          BNE.S   MonScrC02
          LEA     entry_video_modus(A4),A0
MonScrC02
          CMP.W   (A0),D0                       ; gegebnenfalls befindet sich
          BEQ     MonScrE0                      ; TempleMon auch im OverScan Modus
          TST.W   (A0)                          ; vgl. HyperScreen!
          BEQ     MonScrNorm
          BSR.L   BigScreen
          BRA     MonScrE0
MonScrNorm
          BSR.L   SmallScreen
MonScrE0  MOVEM.L (A7)+,D0/A0/A1
          MOVE    (A7)+,SR
          RTS

!MonScrn  ; Monitor-Screen anzeigen
          MOVE    SR,-(A7)
          MOVEM.L D0/A0/A1,-(A7)
          MOVE.W  screensaver(PC),D0
          BEQ     MonScrnNI
          TST.B   KeyCall(A4)
          BNE     MonScrnNI
          MOVE.L  Kbdv_base(A4),D0
          BEQ     MonScrnNI
          MOVEM.L D1/D7/A6,-(SP)
          MOVE.L  SP,A6
          MOVE.W  SR,D7
          MOVE.L  ADRERRV,-(SP)
          MOVE.L  BUSERRV,-(SP)
          LEA     MonScrnBu(PC),A0
          MOVE.L  A0,BUSERRV
          LEA     MonScrnAd(PC),A0
          MOVE.L  A0,ADRERRV
          MOVE.L  D0,A0
          MOVE.L  32(A0),A0
          JSR     (A0)                  ; IKBDSYS anspringen, um Bildschirmschoner
          TST.W   Unknown(A4)
          BNE     MonScrnCT
          LEA     $FFFF8200,A1          ; aufzuwecken
          MOVEP.W 1(A1),D0
          BSR     Wvbl
          BSR     Wvbl
          BRA.S   MonScrnCT
MonScrnBu BSR.L   TestMMUBusError
MonScrnAd MOVE.L  A6,SP
          MOVE.W  D7,SR
MonScrnCT MOVE.L  (SP)+,BUSERRV
          MOVE.L  (SP)+,ADRERRV
          MOVEM.L (SP)+,D1/D7/A6
MonScrnNI BSR.L   MonScrUpdate
          SF      KeyCall(A4)
          BRA.S   MonScrnNI2

!ShowMonScrn  ; Monitor-Screen anzeigen
          MOVE    SR,-(A7)
          MOVEM.L D0/A0/A1,-(A7)
MonScrnNI2
          TST.W   Unknown(A4)
          BEQ     MonScrnOrgRoutine
          TST.L   SwitchTMonScreen(A4)
          BEQ     MonScrnOrgRoutine
          MOVE.B  SysMonCall(A4),D0
          ASL.W   #8,D0
          MOVE.B  TempleMonCall(A4),D0
          MOVEM.L (SP)+,D0/A0/A1
          MOVE.W  (SP)+,SR
          MOVE.L  SwitchTMonScreen(A4),-(SP)
          RTS
!MonScrnOrgRoutine
          TST     isFALCON030(A4)
          BEQ     MonScrnNotFALCON
          LEA     rNormScreen(PC),A0
          BSR.L   SaveFALCON030ScreenMode
          LEA     rMonScreen(PC),A0
          BSR.L   SetFALCON030ScreenMode
          BRA.L   MonScr12
!MonScrnNotFALCON
          ORI     #$0700,SR
          LEA     $FFFF8200,A1
          MOVEP.W 1(A1),D0
          TST.B   SysMonCall(A4)
          BNE.S   MonScrnSysMonActiv
          TST.B   TempleMonCall(A4)
          BNE.S   MonScrnSysMonActiv
          CMP.W   rMonScreen(PC),D0
          BEQ.L   MonScr12              ; aktueller Schirm gleich TempleMon Schirm
          LEA     rNormScreen(PC),A0
          MOVE    D0,(A0)               ; video_base sichern
MonScrnSysMonActiv
          TST.L   OSTT(A4)              ; OverScan TT?
          BNE     MonScrnSysDoOverScan
          TST     isTT(A4)              ; TT ?
          BNE     save_res1             ; dann kein OverScan
          TST     isSTE(A4)             ; STE ?
          BNE     save_res1             ; dann kein OverScan
MonScrnSysDoOverScan                    ; normaler ST: OverScan untersuchen
          MOVE.W  D0,-(SP)              ; D0 sichern
          BSR.L   OverScanTest          ; OverScan Modus ermitteln
          LEA     entry_video_modus2(A4),A0
          TST.B   SysMonCall(A4)
          BNE.S   MonScrnSysMonActiv1
          TST.B   TempleMonCall(A4)
          BNE.S   MonScrnSysMonActiv1
          LEA     entry_video_modus(A4),A0
MonScrnSysMonActiv1
          MOVE.W  D0,(A0)               ; und abspeichern
          MOVE.W  D0,video_modus(A4)
          BEQ.S   save_res              ; Small Screen ist aktiv -> zu reg.
          TST.W   autoswitch(A4)        ; AutoSwitchhardware ?
          BEQ.S   save_res              ; keine AutoSwitch Hardware ->reg.
          BSR.L   SmallScreen           ; AutoSwitch: auf kleinen Schirm schalten!
          CLR.W   video_modus(A4)       ; AutoSwitch: Standard Schirm nutzen!
save_res
          MOVE.W  (SP)+,D0
save_res1
          LEA     rNormScreen(PC),A0
          TST.B   SysMonCall(A4)
          BNE.S   MonScrnSysMonActiv2
          TST.B   TempleMonCall(A4)
          BNE.S   MonScrnSysMonActiv2
          MOVE.B  $60(A1),2(A0)         ; Auflîsung retten (wg. Farbe)
MonScrnSysMonActiv2
          TST     isTT(A4)
          BEQ     MonScrCSTE
          TST.B   SysMonCall(A4)
          BNE.S   MonScrC11
          TST.B   TempleMonCall(A4)
          BNE.S   MonScrC11
          MOVE.W  $62(A1),TT_Shift_Mode(A4)
          BRA     MonScrCTT             ; TT Schirm !!!
MonScrCSTE
          TST.W   isSTE(A4)
          BEQ     MonScrC11             ; kein tt & STE
MonScrCTT
          TST.B   SysMonCall(A4)
          BNE.S   MonScrC11
          TST.B   TempleMonCall(A4)
          BNE.S   MonScrC11
          MOVE.B  $FFFF820D,3(A0)       ; Video Base LOW des STE's & TT's auf 0!
          LEA     Video_Base_Adress_Offset(PC),A0
          MOVE.B  $FFFF820F,(A0)
          LEA     Video_Line_Adress_Offset(PC),A0
          MOVE.B  $FFFF8265,(A0)
MonScrC11
          TST     isTT(A4)
          BEQ     MonScrC12
          MOVE.W  $62(A1),D0
          ANDI.W  #$0700,D0
          CMPI.W  #$0600,D0             ; TT Hochauflîsend ?
          BNE     MonScrCTT1            ; nein: sonst bei TT immer 640 * 400
          MOVE.W  #16,CharHeight(A4)
          MOVE.W  #-1,video_modus(A4)
;          BSR.L   MonScrUpdate
          BRA     MonScrC1
MonScrC12
          MOVE.B  $60(A1),D0            ; Farbe od. Mono?
          BTST.L  #1,D0
          BNE     MonScrC2              ; Monochrom!
          MOVE.W  #8,CharHeight(A4)
;          BSR.L   MonScrUpdate
          MOVE.B  #1,$60(A1)            ; auf 640 * 200, falls Farbmodus
          BRA     MonScrC1
MonScrCTT1
          MOVE.W  #16,CharHeight(A4)
;          BSR.L   MonScrUpdate
          TST.W   video_modus(A4)
          BEQ     MonScrC21
          MOVE.W  $62(A1),D0            ; hier auf TT Hochauflîsend schalten
          ORI.W   #$0600,D0
          MOVE.W  D0,$62(A1)
          MOVE.W  D0,TT_Shift_Mode(A4)
          LEA     rNormScreen(PC),A0
          MOVE.B  $60(A1),2(A0)
          BRA.S   MonScrC1
MonScrC2  MOVE.W  #16,CharHeight(A4)
;          BSR.L   MonScrUpdate
MonScrC21 MOVE.B  #2,$60(A1)            ; sonst auf 640 * 400 schalten
          TST     isTT(A4)
          BEQ     MonScrC1
          MOVE.W  #$0200,$62(A1)
MonScrC1  MOVEP.W 1(A1),D0
          BSR     Wvbl
          MOVE.W  rMonScreen(PC),D0     ; TempleMon Schirm setzen
          MOVEP.W D0,1(A1)
          TST     isTT(A4)
          BNE     MonScrC3
          TST     isSTE(A4)
          BEQ     MonScrC4              ; nur ST dann zu Farbe setzen
MonScrC3  CLR.B   $0D(A1)               ; LOW des Video_Base des STE's & TT
          CLR.B   $0F(A1)
          CLR.B   $65(A1)
MonScrC4
          LEA     farbe2(A4),A0
          TST.B   SysMonCall(A4)
          BNE.S   MonScrC5
          TST.B   TempleMonCall(A4)
          BNE.S   MonScrC5
          LEA     farbe(A4),A0
MonScrC5  MOVE.W  $40(A1),(A0)         ; die ersten vier Farbregister retten
          MOVE.W  $42(A1),2(A0)
          MOVE.W  $44(A1),4(A0)
          MOVE.W  $46(A1),6(A0)
          TST     isTT(A4)
          BNE     MonScrC001TT         ; TT nur Monochrom Farbe!
          BTST    #1,$60(A1)
          BNE     MonScrC001           ; Monochrom bei ST od. STE
          LEA     color_0(PC),A0       ; Farben setzen
          MOVE.W  (A0),$40(A1)
          MOVE.W  2(A0),$42(A1)
          MOVE.W  4(A0),$44(A1)
          MOVE.W  6(A0),$46(A1)
          BRA     MonScr12
MonScrC001TT
          MOVE.W  $FFFF85FC,2(A0)       ; TT Farbreg 254 & 255 retten (Duochrome)
          MOVE.W  $FFFF85FE,4(A0)
          MOVE.W  tt_mono_0(PC),$FFFF85FC
          MOVE.W  tt_mono_1(PC),$FFFF85FE
          MOVE.W  mono_0(PC),D0
          ANDI.W  #1,D0
          ASL.W   #1,D0
          MOVE.W  D0,$40(A1)
          BRA     MonScr12
MonScrC001
          MOVE.W  mono_0(PC),D0
          ANDI.W  #1,D0
          MOVE.W  D0,$40(A1)
MonScr12  ; BSR     MonScrUpdate
          BRA     MonScrE0

MonScrUpdate
          TST.B   restore_screen_flag(A4)
          BEQ.S   MonScrUp1
          MOVEM.L D0-D7/A0-A6,-(SP)
          SF      restore_screen_flag(A4)
          MOVE.W  SR,D0
          ANDI.W  #$F8FF,D0
          ORI.W   #$0500,D0
          MOVE.W  D0,SR
          TST.B   share_screen(A4)
          BNE.S   MonScrUp2
          BSR     ClearScrn1
MonScrUp2 BSR     RestoreScrn
          MOVEM.L (SP)+,D0-D7/A0-A6
MonScrUp1 RTS
*)

;*** COMMAND TABLE

!CMDTBEG  ASC     'MIVCDBGR;O:'
          DC.B    $27
          ASC     'HFTPSQ&?LKE'
!CMDTEND
          SYNC

;*** COMMAND VECTORS

!CMDVEC   BRA.L ComdM
          BRA.L ComdI
          BRA.L ComdV
          BRA.L ComdC
          BRA.L ComdD
          BRA.L ComdB
          BRA.L ComdG
          BRA.L ComdR
          BRA.L ComdSEMK
          BRA.L ComdO
          BRA.L ComdDOPP
          BRA.L ComdHKOM
          BRA.L ComdH
          BRA.L ComdF
          BRA.L ComdT
          BRA.L ComdP
          BRA.L ComdS
          BRA.L ComdQ
          BRA.L ComdDEZ
          BRA.L ComdFRAG
          BRA.L ComdL
          BRA.L ComdK
          BRA.L ComdE
(*
!PRTSTFRAME
          BSR     PRTPRMPT
          MOVEQ   #'R',D0
          BSR     PRT
          MOVE.W  isFPU(A4),D0
          BNE.S   PRTSTFRAME1
          LEA     NoFPUMsg(PC),A1
          BSR     PRTSTR
          BRA     PRTCRLF
PRTSTFRAME1
          LEA     STFRAME(A4),A2
          MOVE.B  (A2),D3
          BNE.S   PRTSTFRAME2
          LEA     NullFrameMsg(PC),A1
          BSR     PRTSTR
          BRA     PRTCRLF
PRTSTFRAME2
          MOVE.W  (A2),D3
          MOVEQ   #$18,D1       ; LÑnge IDLE STFRAME 68881
          MOVE.B  #$B4,D2       ; LÑnge BUSY STFRAME 68881
          CMPI.W  #$1,D0
          BEQ.S   PRTSTFRAME3
          MOVEQ   #$38,D1       ; LÑnge IDLE STFRAME 68882
          MOVE.B  #$D4,D2       ; LÑnge BUSY STFRAME 68882
PRTSTFRAME3
          CMP.B   D1,D3
          BEQ     PRTSTIDLE
          CMP.B   D2,D3
          BEQ.S   PRTSTBUSY
          LEA     InvalidFrameMsg(PC),A1
          BSR     PRTSTR
          BRA     PRTCRLF
PRTSTBUSY LEA     BusyFrameMsg(PC),A1
PRTSTFR   BSR     PRTSTR
          MOVE.W  (A2),D0
          BSR     PRTBYTE
          BRA     PRTCRLF
PRTSTIDLE LEA     IdleFrameMsg(PC),A1
          BSR     PRTSTR
          MOVE.W  (A2),D0
          BSR     PRTBYTE
          BSR     PRTPRMPT
          MOVEQ   #'R',D0
          BSR     PRT
          LEA     ComCondMsg(PC),A1
          BSR     PRTSTR
          MOVE.W  4(A2),D0
          BSR     PRTWORD
          BSR     PRTPRMPT
          MOVEQ   #'R',D0
          BSR     PRT
          LEA     ExOpMsg(PC),A1
          BSR     PRTSTR
          MOVE.L  -$14(A2,D2.w),D0
          BSR     PRTLONG
          MOVEQ   #',',D0
          BSR     PRT
          MOVE.L  -$10(A2,D2.w),D0
          BSR     PRTLONG
          MOVEQ   #',',D0
          BSR     PRT
          MOVE.L  -$C(A2,D2.w),D0
          BSR     PRTLONG
          BSR     PRTPRMPT
          MOVEQ   #'R',D0
          BSR     PRT
          LEA     OpRegMsg(PC),A1
          BSR     PRTSTR
          MOVE.L  -$4(A2,D2.w),D0
          BSR     PRTLONG
          BTST    #15,D7                ; beim letzten Zeichen Zeilenende?
          BNE.S   PRTSTFRAME4
          BSR.L   GETNGRKL
          CMPI.B  #$30,D0
          BCS.S   PRTSTFRAME4
          CMPI.B  #$31,D0
          BHI.S   PRTSTFRAME4
          ANDI.B  #1,D0
          BEQ.S   PRTSTFRAMEBIUCLR
          BSET    #3,0(A2,D2.w)
          BRA.S   PRTSTFRAME4
PRTSTFRAMEBIUCLR
          BCLR    #3,0(A2,D2.w)
PRTSTFRAME4
          MOVE.L  0(A2,D2.w),D1
          MOVE.L  D1,-(SP)
          LEA     FPBIUTAB(PC),A2
          BSR.L   PRTREGBIN
          BSR     PRTPRMPT
          MOVEQ   #'R',D0
          BSR     PRT
          LEA     PTypeMsg(PC),A1
          BSR     PRTSTR
          MOVE.L  (SP)+,D1
          LSL.L   #4,D1
          ANDI.W  #$7,D1
          LEA     FPBIUTYPE(PC),A1
          MULU.W  -2(A1),D1
          ADDA.W   D1,A1
          BSR     PRTSTR
          BRA     PRTCRLF
*)
; Darf D3 und Bit 2 in D7 nicht Ñndern (wg. CRU):
!PRTREG   BTST    #0,D7
          BNE.S   PRTRC1        ; Nur Namen ausgeben
          BTST    #2,D7
          BEQ.S   PRTRC1        ; nicht Flags ausgeben

          CMPI.B  #TNrSR,D2
          BEQ.L   PRTSRBIN
          CMPI.B  #TNrCACR,D2
          BEQ.L   PRTCBIN
          CMPI.B  #TNrPSR,D2
          BEQ.L   PRTPSRBIN
          CMPI.B  #TNrTC,D2
          BEQ.L   PRTTCBIN
          TST     is40(A4)
          BNE     PRTRC0
          CMPI.B  #TNrCRP,D2
          BEQ.L   PRTCRPBIN
          CMPI.B  #TNrSRP,D2
          BEQ.L   PRTSRPBIN
PRTRC0    CMPI.B  #TNrTT0,D2
          BEQ.L   PRTTT0BIN
          CMPI.B  #TNrTT1,D2
          BEQ.L   PRTTT1BIN
          CMPI.B  #TNrITT0,D2
          BEQ.L   PRTITT0BIN
          CMPI.B  #TNrITT1,D2
          BEQ.L   PRTITT1BIN
          CMPI.B  #TNrDTT0,D2
          BEQ.L   PRTDTT0BIN
          CMPI.B  #TNrDTT1,D2
          BEQ.L   PRTDTT1BIN
          CMPI.B  #TNrFPCR,D2
          BEQ.L   PRTFPCRBIN
          CMPI.B  #TNrFPSR,D2
          BEQ.L   PRTFPSRBIN

!PRTRC1   BSR     PrtSPC
          LEA     REGTAB(PC),A1

          ; Test, ob tabellarische Ausgabe, dann nicht Regnamen ausgeben
          BTST    #10,D7
          BEQ.S   PRTRC6
          CMPI.B  #TNrD0,D2
          BCS.S   PRTRC6
          CMPI.B  #TNrA7,D2
          BLS.S   PRTRC5

!PRTRC6   ; Regnamen ausgeben
;          CMPI.B  #TNrCACR,D2     ; CACR ?
;          BEQ     PRTRC61
;          CMPI.B  #TNrSR,D2       ; SR ?
;          BNE     PrtRC2
;!PRTRC61  BTST    #2,D7           ; als Flags ausgeben ?
;          BNE.L   PRTRC4

!PRTRC2   MULU    #5,D2           ; Nur Name sollte ausgegeben werden.
          MOVE.B  0(A1,D2.W),D0   ; PRT REG.NAME
          BSR     Prt
          MOVE.B  1(A1,D2.W),D0
          BSR     Prt
          MOVE.B  2(A1,D2.W),D0
          CMPI.B  #' ',D0
          BEQ.S   PRTRC7
          BSR     Prt
          MOVE.B  3(A1,D2.W),D0
          CMPI.B  #' ',D0
          BEQ.S   PRTRC7
          BSR     PRT
          MOVE.B  4(A1,D2.W),D0
          CMPI.B  #' ',D0
          BEQ.S   PRTRC7
          BSR     PRT
!PRTRC7   DIVU    #5,D2

          BTST    #0,D7
          BNE.L   PRTRC4          ; Nur Namen ausgeben -> fertig

          BTST    #2,D7
          BEQ.S   PRTRC75
          CMPI.B  #TNrFP0,D2
          BCS.S   PRTRC75
          CMPI.B  #TNrFP7,D2
          BHI.S   PRTRC75
          BSR     CHKFPTAB
          TST     is40(A4)
          BNE     PRTRC75
          MOVEQ   #'.',D0
          BSR     PRT
          MOVEQ   #'E',D0
          BSR     PRT

PRTRC75   MOVEQ   #'=',D0
          BSR     Prt

!PRTRC5   LEA     REGBEG(A4),A1       ; REGISTERADR. BERECHNEN
          BSET    #4,D7
          BSR.L   ChkRegNo
          LSL.W   #2,D2
          MOVE.L  0(A1,D2.W),D0                  ; REG.INHALT LADEN
          CMPI.B  #TNRSR+TNRSR+TNRSR+TNRSR,D2    ; SR AUSGEBEN ?
          BEQ.L   PRTRW                          ; JA,DANN NUR 2 BYTE
          CMPI.B  #TNRPSR+TNRPSR+TNRPSR+TNRPSR,D2
          BEQ.L   PRTRW
          CMPI.B  #TNRCRP+TNRCRP+TNRCRP+TNRCRP,D2
          BNE.S   PRTRC51
          LEA     RgCRP(A4),A0
          TST     is40(A4)
          BEQ.S   PRTRC510
          LEA     RgURP(A4),A0
          BRA.S   PRTRC59
!PRTRC51  CMPI.B  #TNRSRP+TNRSRP+TNRSRP+TNRSRP,D2
          BNE.S   PRTRC52
          LEA     RgSRP(A4),A0
          TST     is40(A4)
          BNE.S   PRTRC59
!PRTRC510 MOVE.L  (A0)+,D0
          BSR     PrtLONG
          MOVE.L  (A0),D0
          BRA.S   PRTRC59
!PRTRC52  CMPI.B  #TNrFPCR+TNrFPCR+TNrFPCR+TNrFPCR,D2
          BNE.S   PRTRC53
          MOVE.L  RgFPCR(A4),D0
          BRA.S   PRTRW
!PRTRC53  CMPI.B  #TNrFPSR+TNrFPSR+TNrFPSR+TNrFPSR,D2
          BNE.S   PRTRC54
          MOVE.L  RgFPSR(A4),D0
          BRA.S   PRTRC59
!PRTRC54  CMPI.B  #TNrFPIAR+TNrFPIAR+TNrFPIAR+TNrFPIAR,D2
          BNE.S   PRTRC55
          MOVE.L  RgFPIAR(A4),D0
          BRA.S   PRTRC59
!PRTRC55  CMPI    #TNrFP0+TNrFP0+TNrFP0+TNrFP0,D2
          BCS.S   PRTRC59
          SUB.B   #TNrFP0+TNrFP0+TNrFP0+TNrFP0,D2
          MULU.W  #3,D2            ; insgesamt dann *12
          LEA     RgFP0(A4),A1
          ADDA.W  D2,A1
          BTST.L  #2,D7
          BEQ.S   PRTTRC56
          TST     is40(A4)
          BNE     PRTTRC56
          LEA     REALREAL(A4),A0
          MOVE.L  (A1)+,(A0)+
          MOVE.L  (A1)+,(A0)+
          MOVE.L  (A1)+,(A0)+
          BRA     PRTREAL
!PRTTRC56 MOVE.L  D3,-(SP)
          MOVE.L  (A1)+,D3
          MOVE.L  (A1)+,D2
          MOVE.L  (A1)+,D1
          BSR     PRTLONGXL
          MOVE.L  (SP)+,D3
          RTS
!PRTRC59  BSR     PrtLONG
          BRA.S   PRTRC4
!PRTRW    BSR     PrtWORD
!PRTRC4   RTS


!PRTREGBIN                           ; Register binÑr anzeigen
          MOVEM.L D7/D5/D4/D3/D1/D0/A1/A0,-(SP) ; D2: Register Nummer
          BSET    #0,D7              ; A2 : Pointer auf Tabelle
          CLR.L   D3                 ; D1 ; Registerwert
          BSET    #16,D7
          MOVE.L  D1,D5
          MOVE.W  CursorX(A4),D4
          BNE.S   PRTREGBG
          BSR     PRTNEWPRMPT1
          BRA.S   PRTREGBINLOOP
PRTREGBG  CMPI.W  #2,D4              ; was ist am Zeilenanfang ?
          BHI.S   PRTREGB
          CMPI.W  #1,D4
          BEQ.S   PRTREGG1
          MOVE.W  #1,CursorX(A4)
          BSR     ScrnGet
          CMPI.B  #'R',D0
          BNE.S   PRTREGBS
          CLR.W   CursorX(A4)
          BSR     ScrnGet
          CMPI.B  #'!',D0
          BNE.S   PRTREGBS
          MOVE.W  D4,CursorX(A4)
          BRA.S   PRTREGBI
PRTREGG1  CLR.W   CursorX(A4)
          BSR     ScrnGet
          CMPI.B  #'!',D0
          BNE     PRTREGBS
          MOVE.W  D4,CursorX(A4)
          BRA.S   PRTREGBB
PRTREGBS  MOVE.W  D4,CursorX(A4)
PRTREGB   BSR     PRTNEWPRMPT        ; aus GrÅnden der öbersichtlichkeit
PRTREGBB  MOVEQ   #'R',D0            ; immer am Zeilenanfang anfangen
          BSR     PRT
PRTREGBI  TST.B   -1(A2)
          BMI.S   PRTREGNOREG
          MOVE.W  D2,-(SP)           ; Registername ausgeben
          BSR     PRTREG
          MOVE.W  (SP)+,D2
          BSR     DoRegTAB
          MOVEQ   #':',D0
          BSR     PRT
          BRA.S   PRTREGBIN1
PRTREGBINLOOP
          CMPI.W  #TNrSR,D2
          BEQ     PRTREGBINLOOP1
          BSR     NextTAB
          BRA     PRTREGBIN1
PRTREGBINLOOP1
          BSR     NextSTAB
PRTREGBIN1
          MOVE.L  D5,D4
          CLR.L   D0
          MOVE.B  -4(A2),D0          ; passt das Register in die Zeile?
          ADD.W   CursorX(A4),D0
          ADDQ    #1,D0
          CMP.W   Rows(A4),D0
          BLT     PRTREGNOREG
          BSET    #16,D7
          BSR     PRTNEWPRMPT        ; Nein, Zeile initialisieren
          MOVEQ   #'R',D0
          BSR     PRT
          TST.B   -1(A2)
          BMI.S   PRTREGNOREG
          MOVE.W  D2,-(SP)           ; Registername ausgeben
          BSR     PRTREG
          BSR     DoRegTAB
          MOVE.W  (SP)+,D2
          MOVEQ   #':',D0
          BSR     PRT
PRTREGNOREG
          MOVE.W  D3,-(SP)           ; Anfang merken
PRTREGBIN2
          MOVE.B  0(A2,D3.w),D0      ; Bitbezeichnung ausgeben
          BEQ.S   PRTREGBIN3
          BSR     PRT
          ADDQ    #1,D3
          BRA.S   PRTREGBIN2
PRTREGBIN3
          MOVEQ   #'=',D0
          BSR     PRT
          MOVE.W  (SP)+,D3           ; Anfang holen
          CLR.L   D0
          MOVE.B  -3(A2),D0          ; Tabellen-Position Bitnummer
          ADD.W   D0,D3
          CLR.L   D0
          CLR.L   D1
          MOVE.B  0(A2,D3.w),D0      ; Bit-Position Bitnummer
          LSR.L   D0,D4
          ADDQ    #1,D3
          MOVE.B  0(A2,D3.w),D1      ; 1.Position Maske
          TST.B   -1(A2)             ; 16 Bit Maske?
          BEQ.S   PRTREGBIN4
          BMI.S   PRTREGBIN4
          ASL.W   #8,D1              ; ja, dann Low holen
          ADDQ    #1,D3
          MOVE.B  0(A2,D3.w),D1
PRTREGBIN4
          ADDQ    #1,D3              ; auf nÑchste Zeile in Tabelle positionieren
          AND.W   D1,D4
          MOVE.W  D4,D0
          CMPI.W  #$1000,D1          ; Maske grîûer als 12 Bit
          BLT     PRTREGBIN5         ; nein, dann nur 3 Nibls
          LSR.W   #8,D0
          LSR.W   #4,D0
          BSR     PrtNIBL
          MOVE.W  D4,D0
PRTREGBIN5
          CMPI.W  #$0100,D1          ; Maske grîûer als 8 Bit
          BLT     PRTREGBIN6         ; nein, dann nur 2 Nibls
          LSR.W   #8,D0
          BSR     PrtNIBL
          MOVE.W  D4,D0
PRTREGBIN6
          CMPI.W  #$0010,D1          ; Maske grîûer als 4 Bit
          BLT     PRTREGBIN7         ; nein, dann nur 1 Nibl
          LSR.W   #4,D0
          BSR     PrtNIBL
          MOVE.W  D4,D0
PRTREGBIN7
          BSR     PrtNIBL
          TST.B   0(A2,D3.w)         ; am Ende der Tabelle angelangt?
          BNE     PRTREGBINLOOP      ; nein!
PRTREGBIN8
          MOVEM.L (SP)+,A0/A1/D0/D1/D3/D4/D5/D7
          BSET    #6,D7
          RTS


!PRTMSG   BSR     PrtCRLF

          BTST    #2,EntryMod(A4)
          BEQ.S   PRTMSGC5

          ; 'Exception' ausgeben
          LEA     ExcMsg(PC),A1
          BSR     PrtSTR
          MOVE    ExcNo(A4),D0
          BSR     PrtBYTE
          LEA     Exc2Msg(PC),A1
          BSR     PrtSTR

!PRTMSGC5 MOVEA.L EntryMsg(A4),A1     ; PRT. ENTRY-MELDUNG
          BSR     PrtSTR

          BTST    #0,EntryMod(A4)
          BEQ.S   PRTMSGC1

          ; Werte v. Bus-/Addr-Error anzeigen
          MOVE.L  ErrAdr(A4),D0
          BSR     PrtLONG
          LEA     SSRMSG(PC),A1
          BSR     PrtSTR
          MOVE.W  SupSR(A4),D0
          BSR     PrtWORD
          LEA     EBFMSG(PC),A1
          BSR     PrtSTR
          MOVE.W  ErrBef(A4),D0
          BSR     PrtWORD
          CMPI    #2,ExcNo(A4)
          BNE     PRTMSGC1
          MOVE.L  MMUMSG(A4),D0
          BEQ     PRTMSGC1
          MOVE.L  D0,A1
          BSR     PrtSTR
(*        BSR     PrtSPC
          MOVE.W  TestMMUTemp(A4),D0
          BSR     PrtWORD *)

!PRTMSGC1 BTST    #1,EntryMod(A4)
          BEQ.S   PRTMSGC2

          ; Entry-Nummer anzeigen
          MOVE.W  EntryNr(A4),D0
          BSR     PrtBYTE

!PRTMSGC2 ;BTST    #0,TrcStat(A4)
          ;BNE     PRTMSGC4
          RTS

(*
!PRTMSGC4 BSR     PrtSPC
          MOVEQ   #'/',D0
          BSR     Prt
          BSR     PrtSPC
*)
;                                PRT TRACE MODUS (TRACE ON/OFF)
!PRTTRMOD LEA     TRMMSG(PC),A1
          BSR     PrtSTR
          BTST    #0,TrcStat(A4)
          BEQ.S   PRTTRMC1
          LEA     AKTMSG(PC),A1
          BRA.S   PRTTRMC2
!PRTTRMC1 LEA     NAKTMSG(PC),A1
!PRTTRMC2 BRA     PrtSTR


;*** REGISTER AUSGEBEN:PC,SP UND ENTRY

!PRTREGMI BSR     PrtMSG
          LEA     COPPROMsg(PC),A0
          CMPA.L  EntryMSG(A4),A0
          BNE     PRTREGMI_O
          BSR     PrtCRLF
          LEA     COPPROMsg1(PC),A1
          BSR     PrtSTR
          MOVE.W  Response(A4),D0
          BSR     PrtWORD
!PRTREGMI_O
          TST     longREG(A4)
          BEQ     PRTREGMI0
          MOVE.L  RegWahl(A4),D4
          MOVE.L  RegWahl2(A4),D5
          BSR.L   CRU             ; REG. OHNE PC ANZEIGEN
          BSET    #11,D7
          RTS
!PRTREGMI0
          BSR     PrtPRMPT
          MOVEQ   #'R',D0         ; PROMPT F. REGISTER - ANZEIGE
          BSR     Prt
          MOVEQ   #TNRPC,D2       ; PC
          BSR     PrtREG
          MOVEQ   #TNRUSP,D2      ; USP
          BSR     PrtREG
          TST     is20(A4)
          BEQ     PRTREGMI1
          MOVEQ   #TNRMSP,D2      ; MSP
          BSR     PrtREG
          MOVEQ   #TNRISP,D2      ; ISP
          BRA.S   PRTREGMI2
!PRTREGMI1
          MOVEQ   #TNRSSP,D2      ; SSP
!PRTREGMI2
          BSR     PrtREG

!PRTSRBIN MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrSR,D2          ; SR BINAER ANZEIGEN
          MOVEQ   #0,D1
          MOVE.W  RgSR(A4),D1
          BTST    #8,D7
          BNE.S   PRTSRBLK
          LEA     SRTAB(PC),A2
          TST     is20(A4)
          BEQ     PRTSRBL1
          LEA     SRTAB20(PC),A2
!PRTSRBL1 BSR     PrtRegBin
          MOVEM.L (SP)+,D1/D2/A2
          RTS

!PRTSRBLK LEA     SRTABK(PC),A2
          TST     is20(A4)
          BEQ     PRTSRBL1
          LEA     SRTAB20K(PC),A2
          BRA.S   PRTSRBL1


!PRTCBIN  MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrCACR,D2
          MOVE.L  RgCACR(A4),D1
          LEA     CACHETAB(PC),A2    ; CACR BINAER ANZEIGEN
          TST     is30(A4)
          BEQ     PRTSRBL1
          LEA     CACHETAB30(PC),A2
          TST     is40(A4)
          BEQ     PRTSRBL1
          LEA     CACHETAB40(PC),A2
          BRA.S   PRTSRBL1


!PRTPSRBIN
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrPSR,D2
          TST     is40(A4)
          BNE     PRTPSR40BIN
          MOVEQ   #0,D1
          MOVE.W  RgPSR(A4),D1
          LEA     MMUPSRTAB(PC),A2
          BRA.S   PRTSRBL1
!PRTPSR40BIN
          MOVE.L  RgPSR(A4),D1
          LEA     MMUPSR40TAB(PC),A2
          BRA     PRTSRBL1


!PRTTCBIN TST     is40(A4)
          BEQ     PRTTCBIN30
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrTC,D2
          MOVE.L  RgTC(A4),D1
          LEA     MMUTC40TAB(PC),A2
          BRA     PRTSRBL1
!PRTTCBIN30
          MOVEM.L D0-D2/A2,-(SP)
          MOVEQ   #TNrTC,D2
          MOVE.L  RgTC(A4),D1
          LEA     MMUTCTAB(PC),A2
          BSR     PrtRegBin
          MOVEQ   #0,D0             ; ergibt die Summe von PS,IS,TIA-TID 32?
          MOVE.L  D1,D2
          ANDI.L  #$F,D2            ; TID ausmaskieren
          ADD.L   D2,D0
          LSR.L   #4,D1
          MOVE.L  D1,D2
          ANDI.L  #$F,D2            ; TIC ausmaskieren
          BNE     PRTTCB1
          MOVEQ   #0,D0
PRTTCB1   ADD.L   D2,D0
          LSR.L   #4,D1
          MOVE.L  D1,D2
          ANDI.L  #$F,D2            ; TIB ausmaskieren
          BNE     PRTTCB2
          MOVEQ   #0,D0
PRTTCB2   ADD.L   D2,D0
          MOVE.L  D1,D2
          ANDI.L  #$F,D2            ; TIA ausmaskieren
          ADD.L   D2,D0
          LSR.L   #4,D1
          MOVE.L  D1,D2
          ANDI.L  #$F,D2            ; IS ausmaskieren
          ADD.L   D2,D0
          LSR.L   #4,D1
          MOVE.L  D1,D2
          ANDI.L  #$F,D2            ; PS ausmaskieren
          ADD.L   D2,D0
          CMP.W   #32,D0
          BNE     PRTTCBIN1         ; TC ungÅltig!
          BTST    #3,D2             ; PS mindestens 256?
          BNE     PRTTCBIN3
PRTTCBIN1 LEA     TCInvalidMsg(PC),A1
          MOVE.W  -2(A1),D0
          CMP.W   CursorX(A4),D0
          BCS.S   PRTTCBIN2
          SUBQ.L  #1,A1
          BSR     PRTNEWPRMPT
          LEA     TCInvalidMsg(PC),A1
PRTTCBIN2 BSR     PRTSTR
PRTTCBIN3 MOVEM.L (SP)+,D0-D2/A2
          RTS

!PRTCRPBIN
          MOVEM.L D2/A2/A3,-(SP)
          MOVEQ   #TNrCRP,D2
          LEA     RgCRP(A4),A3
PRTRPBIN1 MOVE.L  (A3),D1
          LEA     MMURPTAB(PC),A2
          BSR     PrtRegBin
          MOVE.W  CursorX(A4),D0
          ADDI.W  #21,D0
          CMP.W   Rows(A4),D0
          BLT.S   PRTRPBIN2
          BSR     PRTNEWPRMPT
          MOVEQ   #'R',D0
          BSR     PRT
          MOVE.L  D7,-(SP)
          BSET    #0,D7
          BSR     PRTREG
          MOVE.L  (SP)+,D7
          BSR     DoRegTAB
          LEA     MMURPTAB2(PC),A1
          BRA     PRTRPBIN3
PRTRPBIN2 LEA     MMURPTAB1(PC),A1
          BSR     PRTSTR
          LEA     MMURPTAB3(PC),A1
PRTRPBIN3 BSR     PRTSTR
          MOVE.L  4(A3),D0
          BSR     PRTLONG
          MOVEM.L (SP)+,D2/A2/A3
          BSET    #6,D7
          RTS

!PRTSRPBIN
          MOVEM.L D2/A2/A3,-(SP)
          MOVEQ   #TNrSRP,D2
          LEA     RgSRP(A4),A3
          BRA.S   PRTRPBIN1

!PRTTT0BIN
          TST     is40(A4)
          BNE     PRTITT0BIN
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrTT0,D2
          MOVE.L  RgTT0(A4),D1
          LEA     MMUTTTAB(PC),A2
          BRA     PRTSRBL1

!PRTITT0BIN
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrITT0,D2
          MOVE.L  RgITT0(A4),D1
          LEA     MMUTT40TAB(PC),A2
          BRA     PRTSRBL1

!PRTDTT0BIN
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrDTT0,D2
          MOVE.L  RgDTT0(A4),D1
          LEA     MMUTT40TAB(PC),A2
          BRA     PRTSRBL1

!PRTTT1BIN
          TST     is40(A4)
          BNE     PRTITT1BIN
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrTT1,D2
          MOVE.L  RgTT1(A4),D1
          LEA     MMUTTTAB(PC),A2
          BRA     PRTSRBL1

!PRTITT1BIN
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrITT1,D2
          MOVE.L  RgITT1(A4),D1
          LEA     MMUTT40TAB(PC),A2
          BRA     PRTSRBL1

!PRTDTT1BIN
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrDTT1,D2
          MOVE.L  RgDTT1(A4),D1
          LEA     MMUTT40TAB(PC),A2
          BRA     PRTSRBL1

!PRTFPCRBIN
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrFPCR,D2
          MOVEQ   #0,D1
          MOVE.L  RgFPCR(A4),D1
          LEA     FPCRTAB(PC),A2
          BRA     PRTSRBL1

!PRTFPSRBIN
          MOVEM.L D1/D2/A2,-(SP)
          MOVEQ   #TNrFPSR,D2
          MOVE.L  RgFPSR(A4),D1
          LEA     FPSRTAB(PC),A2
          BRA     PRTSRBL1


; TraceBit im SR setzen, je nachdem ob T1 oder T0

!SetTraceBit
          MOVE.L  A0,-(SP)
          LEA     TrcStat2(A4),A0
          BTST    #7,(A0)
          BEQ     SetTraceBitT1
          BSET    #6,RgSR(A4)
          BRA.S   SetTraceBitE
SetTraceBitT1
          BSET    #7,RgSR(A4)
SetTraceBitE
          MOVE.L  (SP)+,A0
          RTS


; MFP Interrupts fÅr Tastatur und hîhere Level prÅfen

!CheckKeyBoard
(*$? ~MAC:
          MOVEM.L D0-D2/A0/A1/A4,-(SP)
          MOVE.W  KeyCheck(PC),D0
          TST.W   D0
          BEQ.L   CHKKBA
          MOVE.W  SR,-(SP)
          ORI.W   #$0700,SR
          MOVEA.L LocVarP(PC),A4
          CLR.L   D2
CHKKB7    TST.B   RestoreKBDVec(A4)
          BNE.S   CHKKB8         ; da ist noch ein gÅltiger drinnen!
          LEA     $100+6*4,A1
          LEA     CHKKbdEntry(PC),A0
          MOVE.L  (A1),savedKBDVec(A4)
          BSR.L   SetKVec
          BEQ.S   CHKKB8
          ST      RestoreKBDVec(A4)
          BSET    #10,D2
CHKKB8    TST.B   RestoreKBDVec(A4)
          BNE.S   CHKKB9
          MOVEA.L Kbdv_base(A4),A0
          LEA     32(A0),A1
          MOVE.L  (A1),savedKBDVec2(A4)
          LEA     EyIKBDSYS(PC),A0
          BSR.L   SetKVec
          BEQ.S   CHKKB9
          ST      RestoreKBDVec(A4)
          BSET    #11,D2
CHKKB9    BCLR    #4,$FFFFFA03   ; Activ Edge
          BEQ.S   CHKKB01
          BSET    #0,D2
CHKKB01   BCLR    #4,$FFFFFA05   ; Data Direction
          BEQ.S   CHKKB02
          BSET    #1,D2
CHKKB02   CMPI.B  #$48,$FFFFFA17 ; Interrupt-Vector
          BEQ.S   CHKKB03
          MOVE.B  #$48,$FFFFFA17
CHKKB03   BSET    #6,$FFFFFA09   ; Interrupt Enable B
          BNE.S   CHKKB1
          BSET    #3,D2
CHKKB1    TST.B   $FFFFFA0B      ; Interrupt Pending A
          BEQ.S   CHKKB2
          MOVE.B  $FFFFFA0B,D0
          MOVE.B  D0,pendingA(A4)
          NOT.B   D0
          MOVE.B  D0,$FFFFFA0B
          BSET    #4,D2
CHKKB2    MOVE.B  $FFFFFA0D,D1   ; Interrupt Pending B
          ANDI.B  #$C0,D1
          BEQ.S   CHKKB3
          MOVE.B  $FFFFFA0D,pendingB(A4)
          NOT.B   D1
          MOVE.B  D1,$FFFFFA0D
          BSET    #5,D2
CHKKB3    BSET    #6,$FFFFFA15   ; Interupt Mask B
          BNE.S   CHKKB4
          BSET    #6,D2
CHKKB4    MOVE.B  $FFFFFA0F,D1   ; Interrupt in Service A
          BEQ.S   CHKKB5
          MOVE.B  D1,serviceA(A4)
          BSET    #7,D2
          NOT.B   D1
          MOVE.B  D1,$FFFFFA0F
CHKKB5    BTST    #7,$FFFFFA11   ; Interrupt in Service B
          BEQ.S   CHKKB6
          MOVE.B  #01111111%,$FFFFFA11
          BSET    #8,D2
CHKKB6    BTST    #6,$FFFFFA11
          BEQ.S   CHKKBEE1
;          MOVE.B  #$17,$FFFFFC00 ; Keyboard ACIA Master Reset
;          MOVE.B  #$96,$FFFFFC00 ; Keyboard ACIA initialisierung
          MOVE.B  $FFFFFC02,D1   ; ACIA Empfangsregister lesen (leeren)
          MOVE.B  #10111111%,$FFFFFA11
          BSET    #9,D2
CHKKBEE1  MOVE.W  D2,KBDState(A4)
          BSR.L   PRTKSTATE
CHKKBE    MOVE.W  (SP)+,SR
          BSR.L   Resume_IKBD    ; PAUSE IKBD aufheben
CHKKBA    MOVEM.L (SP)+,D0-D2/A0/A1/A4
*)
          RTS

SetKVec   MOVEM.L D1/D2/A2/A3/A5,-(SP)
          MOVE.L  BUSERRV,D2            ; alten Buserr
          LEA     CHKKBDBusErr(PC),A5   ; spezielle Buserrorroutine
          MOVE.L  A5,8                  ; einhÑngen
          MOVE.L  SP,A5                 ; und dafÅr SP merken (SR s.o.)
          CLR.L   D0
          MOVEA.L (A1),A2
          MOVE.L  (A1),D1               ; Input:
          BTST.L  #0,D1                 ; A0 : Adresse der TMon Routine
          BNE.S   CHKKBC1               ; A1 : Adresse des Pointers
CHKKBL    CMPI.L  #$58425241,-12(A2)    ; 'XBRA' ?
          BNE.S   CHKKBC1
          LEA     XBRATab(PC),A3
CHKKBL1   MOVE.L  (A3)+,D1
          BEQ.S   CHKKBN
          CMP.L   -8(A2),D1
          BEQ.S   CHKKBC2
          BRA.S   CHKKBL1
CHKKBN    MOVE.L  -4(A2),D1
          BTST.L  #0,D1            ; ungerade Adresse?
          BNE.S   CHKKBC1          ; dann TempleMon Routine eintragen
          MOVEA.L -4(A2),A2
          ADDQ.L  #1,D0
          BRA.S   CHKKBL
CHKKBDBusErr
          BSR.L   TestMMUBusError
          MOVE.L  A5,SP
CHKKBC1   MOVE.L  A0,A2            ; TempleMon Routine als gefundene deklarieren
          BRA.S   CHKKBC
CHKKBC2   TST.L   D0
          BEQ.S   CHKKBEE
CHKKBC    MOVE.L  A2,(A1)          ; gefundene Routine eintragen
          MOVEQ   #-1,D0
CHKKBEE   MOVE.L  D2,BUSERRV       ; Buserrorroutine restaurieren
          MOVEM.L (SP)+,D1/D2/A2/A3/A5
          TST.L   D0
          RTS


RestoreKeyBoard
          MOVE.L  A4,-(SP)
          MOVE.W  SR,-(SP)
          ORI.W   #$0700,SR
          MOVEA.L LocVarP(PC),A4
          TST.B   RestoreKBDVec(A4)
          BEQ     RKBD1
          MOVE.L  savedKBDVec(A4),$100+6*4
          SF      RestoreKBDVec(A4)
RKBD1     TST.B   RestoreKBDVec(A4)
          BEQ     RKBD2
          MOVE.L  Kbdv_base(A4),A0
          MOVE.L  savedKBDVec2(A4),32(A0)
          SF      RestoreKBDVec(A4)
RKBD2     MOVE.W  (SP)+,SR
          MOVE.L  (SP)+,A4
          RTS


!PRTKSTATE
          MOVE.W  KBDState(A4),D0
          BTST    #0,D0
          BEQ     PRTKSTATE01
          BSR     PRTNEWLINE
          LEA     Lck01MSG(PC),A1
          BSR     PrtSTR
PRTKSTATE01
          MOVE.W  KBDState(A4),D0
          BTST    #1,D0
          BEQ     PRTKSTATE02
          BSR     PRTNEWLINE
          LEA     Lck02MSG(PC),A1
          BSR     PrtSTR
PRTKSTATE02
          MOVE.W  KBDState(A4),D0
          BTST    #2,D0
          BEQ     PRTKSTATE03
          BSR     PRTNEWLINE
          LEA     Lck03MSG(PC),A1
          BSR     PrtSTR
PRTKSTATE03
          MOVE.W  KBDState(A4),D0
          BTST    #3,D0
          BEQ     PRTKSTATE1
          BSR     PRTNEWLINE
          LEA     Lock1MSG(PC),A1
          BSR     PrtSTR
PRTKSTATE1
          MOVE.W  KBDState(A4),D0
          BTST    #4,D0
          BEQ     PRTKSTATE2
          BSR     PRTNEWLINE
          LEA     Lock2MSG(PC),A1
          BSR     PrtSTR
          MOVE.B  pendingA(A4),D0
          BSR     PrtBYTE
PRTKSTATE2
          MOVE.W  KBDState(A4),D0
          BTST    #5,D0
          BEQ     PRTKSTATE3
          BSR     PRTNEWLINE
          LEA     Lock3MSG(PC),A1
          BSR     PrtSTR
          MOVE.B  pendingB(A4),D0
          BSR     PrtBYTE
PRTKSTATE3
          MOVE.W  KBDState(A4),D0
          BTST    #6,D0
          BEQ     PRTKSTATE4
          BSR     PRTNEWLINE
          LEA     Lock4MSG(PC),A1
          BSR     PrtSTR
PRTKSTATE4
          MOVE.W  KBDState(A4),D0
          BTST    #7,D0
          BEQ     PRTKSTATE5
          BSR     PRTNEWLINE
          LEA     Lock5MSG(PC),A1
          BSR     PrtSTR
          MOVE.B  serviceA(A4),D0
          BSR     PrtByte
PRTKSTATE5
          MOVE.W  KBDState(A4),D0
          BTST    #8,D0
          BEQ     PRTKSTATE6
          BSR     PRTNEWLINE
          LEA     Lock6MSG(PC),A1
          BSR     PrtSTR
PRTKSTATE6
          MOVE.W  KBDState(A4),D0
          BTST    #9,D0
          BEQ     PRTKSTATE7
          BSR     PRTNEWLINE
          LEA     Lock7MSG(PC),A1
          BSR     PrtSTR
PRTKSTATE7
          MOVE.W  KBDState(A4),D0
          BTST    #10,D0
          BEQ     PRTKSTATE8
          BSR     PRTNEWLINE
          LEA     Lock8MSG(PC),A1
          BSR     PRTSTR
PRTKSTATE8
          MOVE.W  KBDState(A4),D0
          BTST    #11,D0
          BEQ     PRTKSTATE9
          BSR     PRTNEWLINE
          LEA     Lock9MSG(PC),A1
          BSR     PRTSTR
PRTKSTATE9
          RTS

(*$?~Mac:
!GetMonoConst
          MOVE.L        D0,-(SP)
          MOVE.W        #16,CharHeight(A4)
          MOVE.W        #1,CharWidth(A4)
          MOVE.W        #1,video_plane(A4)
          MOVE.W        m_VideoBytes(PC),D0
          MOVE.W        D0,video_rowbytes(A4)
          MOVE.L        m_VideoMemory(PC),D0
          MOVE.L        D0,video_memsize(A4)
          MOVE.L        tmon_offset_mon(PC),D0
          BCLR          #0,D0
          MOVE.L        D0,tmon_offset(A4)
          ST            video_modus(A4)
          MOVE.L        (SP)+,D0
          RTS

!GetTTConst
          MOVE.L        D0,-(SP)
          MOVE.W        #16,CharHeight(A4)
          MOVE.W        #1,CharWidth(A4)
          MOVE.W        #1,video_plane(A4)
          MOVE.W        t_VideoBytes(PC),D0
          MOVE.W        D0,video_rowbytes(A4)
          MOVE.L        t_VideoMemory(PC),D0
          MOVE.L        D0,video_memsize(A4)
          MOVE.L        tmon_offset_tt(PC),D0
          BCLR          #0,D0
          MOVE.L        D0,tmon_offset(A4)
          ST            video_modus(A4)
          MOVE.L        (SP)+,D0
          RTS

!GetColorConst
          MOVE.L        D0,-(SP)
          MOVE.W        #16,CharHeight(A4)
          MOVE.W        #1,CharWidth(A4)
          MOVE.W        #2,video_plane(A4)
          MOVE.W        c_VideoBytes(PC),D0
          MOVE.W        D0,video_rowbytes(A4)
          MOVE.L        c_VideoMemory(PC),D0
          MOVE.L        D0,video_memsize(A4)
          MOVE.L        tmon_offset_col(PC),D0
          BCLR          #0,D0
          MOVE.L        D0,tmon_offset(A4)
          ST            video_modus(A4)
          MOVE.L        (SP)+,D0
          RTS
*)

(*$? MAC:
!SetMonoConst
          SF      IsMonScreen(A4)
          
          MOVE.W    #8,CharHeight(A4)
          MOVE.W    #1,CharWidth(A4)
          MOVE.W    #1,video_plane(A4)
          
          ; prÅfen, ob S/W-Modus mîglich ist (sonst 256 Bit-Modus verwenden)
          moveq   #1,d0
          bsr     hasDepth
          tst.b   d0
          lea     Is256Cols(pc),a0
          seq     (a0)
          bne     is2Cols
          MOVE.W  #8,video_plane(A4)
is2Cols:

          bsr     getDepth
          move.l  d0,origMacDepth(a4)   ; dies ist die Aufl., in der MagiCMac betrieben wird
          
          move.l    a5,-(a7)
          move.l    originalA5(A4),A5
          BSR.W     mode_mac
          SUBQ.L    #4,A7
          DC.W      $AA2A               ; _GetMainDevice
          MOVE.L    (A7)+,A0
          move.l    (a7)+,a5
          ; Mac-Mode noch halten, bis die Handles deref. sind (liegen unter $8000)
          MOVE.L    (A0),A0
          MOVE.L    22(A0),A0
          MOVE.L    (A0),A0
          MOVE.W    4(a0),D0            ; rowBytes
          ANDI      #$3FFF,D0
          MOVE.W    D0,orig_rowbytes(A4)
          ;MOVE.W    D0,video_rowbytes(A4)
          MOVE      10(a0),d0           ; rect.bottom
          sub       6(a0),d0            ; rect.top
          MOVE.W    D0,video_lines(A4)
          ext.l     d0
          divu      CharHeight(A4),d0
          move.w    d0,Lines(A4)
          
          moveq     #80,d0
          move.w    d0,Rows(A4)
          MOVE      12(a0),d0           ; rect.right
          sub       8(a0),d0            ; rect.left
          lsr       #3,d0               ; DIV 8
          MOVE.W    D0,video_vischars(A4)
          move      d0,-(a7)
          move.l    origMacDepth(a4),d1
          mulu      d1,d0
          MOVE.W    D0,orig_visbytes(A4)
          move      (a7)+,d0
          cmpi.w    #80,d0          ;!!! spÑter mal testen, ob auch mehr geht
          bcc       rows_ok
          move.w    d0,Rows(A4)         ; kann nur weniger als 80 rows
rows_ok:
          ; Screen-Puffergrîûen berechnen
          MOVE      video_vischars(A4),d0
          MULU      video_plane(A4),d0
          MULU      video_lines(A4),d0
          MOVE.L    d0,video_memsize(A4)        ; Screenbuf-Grîûe in Monitor
          MOVE      video_vischars(A4),d0
          move.l    origMacDepth(a4),d1
          mulu.l    d1,d0
          MULU      video_lines(A4),d0
          move.l    d0,orig_screen_size(a4)     ; Screenbuf-Grîûe unter MagiC
          
          ; Mon-Screen-Adr setzen
          LEA       pMonScreen(PC),A1
          MOVE.L    (a0),(A1)                   ; baseAddr
          MOVE.L    (a0),pVisScreen(A4)
          CLR.L     tmon_offset(A4)
          ST        video_modus(A4)
          CLR.W     autoswitch(A4)              ; erst mal mit keinem AutoSwitch belegen
          BRA.W     mode_atari
*)


end_debug: MOVEM.L D1/A0,-(SP)
          SUBA.L  A0,A0
          BRA     do_debug1
do_debug: MOVEM.L D1/A0,-(SP)
          MOVE.L  debugging(PC),D1
          BTST.L  D0,D1
          BEQ     no_debug
          MOVE.L  LocVarP(PC),A0
do_debug1 MOVE.L  TMON_DEBUG(A0),D1
          BEQ     no_debug
          PEA     do_debug_return(PC)
          MOVE.L  D1,-(SP)
          MOVE.L  D0,D1
          MOVEQ   #3,D0
          RTS
do_debug_return
          TST.L   D0
          BNE     no_debug
          MOVE.L  LocVarP(PC),A0
          ST      ResetDebug(A0)
          MOVEM.L (SP)+,D1/A0
          BREAK
          RTS
no_debug: MOVEM.L (SP)+,A0/D1
          RTS

test_symb:      clr.l   GetSymbolName(A4)
                clr.l   GetSymbolValue(A4)
                st      Symbolic(A4)
                lea     SYMB(A4),A1
                move.l  #$53594D42,D1
                bsr.s   cookie_s
                tst.l   (A1)
                beq     test_symb_e
                move.l  (A1),A0
                move.l  8(A0),GetSymbolName(A4)
                move.l  12(A0),GetSymbolValue(A4)
test_symb_e:    rts
test_MiNT:      lea     MiNT_Cookie(A4),A1
                move.l  #$4D694E54,D1
                bra.s   cookie_s
test_ostt:      lea     OSTT(A4),A1
                move.l  #$4F535454,D1       ; 'OSTT' cookie suchen
                bra.s   cookie_s
test_start:     lea     TMON_DEBUG(A4),A1
                move.l  debug_xbra(PC),D1   ; 'tmON' cookie suchen
cookie_s:       movea.l $05A0,A0
                clr.l   (A1)
                tst.l   $05A0
                beq     test_abort
search:         cmp.l   (A0),D1
                beq     dotmon
                addq.l  #8,A0
                tst.l   (A0)
                bne.s   search
                rts
dotmon:         move.l  4(A0),(A1)
test_abort:     rts


          ; EINSPRUNG ZUR CMD-EINGABE-SCHLEIFE MIT MSG.-AUSGABE

!CMDBEG   CLR.W   EntryMod(A4)
!CMDBEGOC CLR.L   D7
          BCLR    #5,TrcStat(A4)  ; TRACE-FLAG wieder an ?
          BEQ     Cmdst1          ; nein
          BSR     SetTraceBit     ; TRACE-FLAG setzen
cmdst1    MOVE.L  A1,EntryMsg(A4)
          BSR     PRTREGMI
          BRA.L   CmdStart1
;                                EINSPRUNG OHNE MSG.-AUSGABE fÅr SysMon
!CMDBEGOMOCRLF
          CLR.L   D7
          MOVE    SR,D1
          ANDI.W  #$F8FF,D1       ; !TT 11.04.95 vormals $FDFF
          OR.W    IRMask(PC),D1
          MOVE    D1,SR
          BCLR    #5,TrcStat(A4)  ; TRACE-FLAG aus
          BSR.L   ResetBPs
          BSR.L   ResetShortBPs
          BSR     MonScrn
          BSR     CheckKeyBoard
          BRA     CMDLOOP

;                                EINSPRUNG OHNE MSG.-AUSGABE
!CMDBEGOM

!CmdStart CLR.L   D7
          ; IR-Maske setzen
!CMDStart1
          MOVE    SR,D1
          ANDI.W  #$F8FF,D1       ; !TT 11.04.95 vormals $FDFF
          OR.W    IRMask(PC),D1
          MOVE    D1,SR

          BCLR    #5,TrcStat(A4)  ; TRACE-FLAG wieder an ?
          BEQ     Cmdst0          ; nein
          BSR     SetTraceBit     ; TRACE-FLAG setzen
cmdst0    BSR.L   ResetBPs
          BSR.L   ResetShortBPs
          BSR     MonScrn         ; Monitor-Screen an
          BSR     CheckKeyBoard
          BSR     PrtCRLF

;                                COMMAND - EINGABE - SCHLEIFE
!CMDLOOP
(*$ ? ExtendedKeys:
          st      LockFlag(A4)
*)
          MOVE.L  MonStackHi(A4),A7
          BSR.L   PRTNEWPRMPT1
          BSR.L   GETLINE
          CLR.L   D7
          SUBQ.L  #1,A6
!CMDL1    BSR.L   GETNGRKL
          BMI.S   CMDLOOP
          CMPI.B  #PROMPT,D0
          BEQ.S   CMDL1
          CMPI.B  #$20,D0
          BEQ.S   CMDL1

          LEA     CMDVEC(PC),A1
          MOVE.W  #CmdTEnd-CmdTBeg,D2
          LEA     CMDTBEG(PC),A0
!CMDL2    CMP.B   (A0)+,D0
          BEQ.S   CMDFND
          ADDQ.L  #4,A1
          DBF     D2,CMDL2
          BRA.S   ERR0

!CMDFND   ; BSR     PRTLF
          BSR.L   GETNGRKL
          BSET    #11,D7
          JSR     (A1)
          BRA.L   CMDLOOP

!ERR0     CLR.L   D6

!PRINTERR CLR.L   D7
          TST.W   RWhandle(A4)       ; War Load oder Save aktiv ?
          BEQ     PrtErrC0
          BSR.L   LSCloseErr    ; Ja : File schliessen
;          BRA     PrtErrC1
PrtErrC0 ; BSR     PrtCRLF
PrtErrC1  LEA     ERRMSG(PC),A1
          BSR     PrtSTR
          MOVE.B  D6,D0
          LEA     ErrorList(PC),A1
          BRA     PrtErrC2
PrtErrL0  TST.B   (A1)+
          BEQ     PrtErrE0
PrtErrL1  TST.B   (A1)+
          BNE     PrtErrL1
PrtErrC2  DBRA    D6,PrtErrL0
PrtErrE0  BSR     PrtStr
          BRA.L   CMDstart

!ERRFF    MOVEQ   #$FF,D6
          BRA     PrintErr
!ERR1     MOVEQ   #1,D6
          BRA     PrintErr
!ERR2     MOVEQ   #2,D6
          BRA     PrintErr
!ERR3     MOVEQ   #3,D6
          BRA     PrintErr
!ERR4     MOVEQ   #4,D6
          BRA     PrintErr
!ERR5     MOVEQ   #5,D6
          BRA     PrintErr
!ERR6     MOVEQ   #6,D6
          BRA     PrintErr
!ERR7     MOVEQ   #7,D6
          BRA     PrintErr
!ERR8     MOVEQ   #8,D6
          BRA     PrintErr
!ERR9     MOVEQ   #9,D6
          BRA     PrintErr
!ERR10    MOVEQ   #10,D6
          BRA     PrintErr
!ERR11    MOVEQ   #11,D6
          BRA     PrintErr


!TestMMUBusError
          MOVE.L  A4,-(SP)
          MOVEA.L LocVarP(PC),A4
          CLR.L   MMUMSG(A4)
          TST     is30(A4)            ; ist Åberhaupt eine PMMU vorhanden?
          BEQ.L   BEE
          TST.W   virtuell(PC)        ; ist Åberhaupt was zu testen?
          BEQ.L   BEE
          MOVEM.L D0/D1/A0-A2,-(SP)
          MOVEC   DFC,A0
          MOVE.L  A0,-(SP)            ; damit sind die Register A0-A2/D0/D1/A4/DFC
          MOVE.L  SP,A0               ; nutzbar
          LEA     32(A0),A0           ; ADDA.L  #32,A0
                                      ; A0 zeigt damit auf den Stack Frame
          CMPI.W  #$1008,6(A0)
          BNE     BEonISP
          MOVEC   MSP,A0
BEonISP
          MOVE.L  A0,A1
          MOVE.L  2(A0),BusPC(A4)
          TST     is40(A4)
          BNE.L   BE40
          MOVE.L  $10(A0),BusFA(A4)
          MOVE.W  $A(A0),D0           ; SSW holen
          MOVEC   D0,DFC              ; Functioncode ins DFC Register kopieren
          BTST    #7,D0               ; RM Bit des SSW testen
          BNE     BE_PTESTW30
          BTST    #6,D0               ; RW Bit des SSW testen
          BEQ     BE_PTESTW30
BE_PTESTR30
          DC.W    $F030,$9F41,$0161,$0010   ; PTESTR  DFC,([$10,A0]),#7,A2
          BRA.S   BE_PTEST30
BE_PTESTW30
          DC.W    $F030,$9D41,$0161,$0010   ; PTESTW  DFC,([$10,A0]),#7,A2
BE_PTEST30
          LEA     TestMMUTemp(A4),A0
          DC.W    $F010,$6200         ; PMOVE   PSR,(A0)
          MOVE.W  (A0),D1
          BTST    #10,D1              ; PSR INVALID Bit testen
          BNE     BE_invalid30
          BTST    #13,D1              ; PSR Supervisor Bit testen
          BEQ     BE_supervisor30
BE_supervisor
          LEA     MMU_supervisor_violation_MSG(PC),A0
          MOVEQ   #0,D0
          BRA     BE_out
BE_supervisor30
          BTST    #11,D1              ; PSR Write Protect Bit testen
          BEQ.L   BE_notMMU           ; nicht von MMU
          BTST    #7,D0               ; SSW RM Bit testen
          BEQ.L   BE_notMMU           ; nicht von MMU
          BTST    #6,D0               ; SSW RW Bit testen
          BEQ.L   BE_notMMU           ; nicht von MMU
BE_write  LEA     MMU_write_violation_MSG(PC),A0
          MOVEQ   #1,D0
          BRA     BE_out
BE_invalid30
          BTST    #14,D1              ; PSR Limit violation Bit testen
          BEQ     BE_no_limit30
BE_limit  LEA     MMU_limit_violation_MSG(PC),A0
          MOVEQ   #2,D0
          BRA     BE_out
BE_no_limit30
          BTST    #15,D1              ; PSR Bus Error Bit testen
          BNE     BE_bus
BE_invalid
          LEA     MMU_invalid_MSG(PC),A0
          MOVEQ   #3,D0
          BRA     BE_out
BE_bus    LEA     MMU_buserror_MSG(PC),A0
          MOVEQ   #4,D0
BE_out    MOVE.L  A0,MMUMSG(A4)
          MOVE.W  virtuell(PC),D1
          TST.B   inTMonBUSerr(A4)    ; TempleMon interne Buserrorroutine?
          BEQ     BE_out1             ; nein, dann Sprung
          ASR.W   #8,D1               ; Testbits verschieben
;         TST.B   inTMonBUSaccess(A4) ; Buserror beim Aufheben einer
;                                     ; ZugriffsbeschrÑnkung?
;         BNE     BE_out1             ; ja, dann Buserrorausgabe testen
;         BTST    #6,D1               ; ZugriffsbeschrÑnkung aufheben?
;         BEQ     BE_out1             ; nein, dann Buserrorausgabe testen
;         BTST    D0,D1               ; Buserror ausgeben?
;         BNE.L   BE_repair_access    ; nein, dann ZugriffsbeschrÑnkung aufheben
;         BRA     BETMon              ; sonst Buserror ausgeben
BE_out1   BTST    D0,D1               ; Buserror ausgeben?
          BEQ     BETMon              ; ja, zur Ausgabe
BEORG     TST.W   BusPR(A4)           ; nein, in der XBRA Kette weiterspringen
          BEQ     BEORG1
          MOVE.L  A1,-(SP)
          MOVE.L  MMUMSG(A4),A1
          BSR     PrtSTR
(*        MOVE.W  TestMMUTemp(A4),D0
          BSR     PrtWORD *)
          LEA     BE_outPC(PC),A1
          BSR     PrtSTR
          MOVE.L  BusPC(A4),D0
          BSR     PrtLONG
          LEA     BE_outFA(PC),A1
          BSR     PrtSTR
          MOVE.L  BusFA(A4),D0
          BSR     PrtLONG
          BSR     PrtCRLF
          MOVE.L  (SP)+,A1
BEORG1    MOVE.L  (SP)+,A0
          MOVEC   A0,DFC
          MOVEM.L (SP)+,D0/D1/A0-A2
          MOVE.L  (SP)+,A4
          MOVE.L  EyBUSold(PC),(SP)
          RTS
BE_outPC  ACZ     ' PC='
BE_outFA  ACZ     ' FA='
          SYNC
BE_notMMU CLR.L   MMUMSG(A4)
BETMon    MOVE.L  (SP)+,A0
          MOVEC   A0,DFC
          MOVEM.L (SP)+,D0/D1/A0-A2
BEE       MOVE.L  (SP)+,A4
BEEE      RTS
BE40      MOVE.L  $14(A0),BusFA(A4)
          MOVE.W  $C(A0),D0           ; SSW holen
          MOVEC   D0,DFC              ; Functioncode ins DFC Register kopieren
          MOVE.B  D0,D1               ; Functioncodes, fÅr die PTEST nicht
          ANDI.B  #7,D1               ; definiert ist, ausschliesen
          BEQ     BETMon
          CMPI.B  #3,D1
          BEQ     BETMon
          CMPI.B  #4,D1
          BEQ     BETMon
          CMPI.B  #7,D1
          BEQ     BETMon
          BTST    #11,D0              ; SSW MA Bit testen
          BNE     BE40_1
          BTST    #10,D0              ; SSW ATC Bit testen
          BEQ     BETMon
BE40_1    MOVE.L  $14(A0),A0          ; Faulting Adress holen
          BTST    #9,D0               ; SSW LK Bit testen (RWM Bus Zyklus)
          BNE     BE_PTESTW40
          BTST    #8,D0               ; SSW RW Bit testen
          BEQ     BE_PTESTW40
BE_PTESTR40
          DC.W    $F568               ; PTESTR (A0)
          BRA     BE_PTEST40
BE_PTESTW40
          DC.W    $F548               ; PTESTW (A0)
BE_PTEST40
          DC.W    $4E7A,$1805         ; MOVEC  PSR,D1
          MOVE.L  D1,TestMMUTemp(A4)
          BTST    #0,D1               ; PSR R Bit testen
          BNE     BE_resident40
          BTST    #11,D1              ; PSR B Bit testen
          BNE     BE_bus
          BRA     BE_invalid
BE_resident40
          BTST    #1,D1               ; PSR T Bit testen
          BNE     BE_transparent40
          BTST    #2,D0               ; SSW TM2 Bit testen (User Access?)
          BNE     BE_test_write40
          BTST    #7,D1               ; PSR S Bit testen
          BNE     BE_supervisor
BE_test_write40
          BTST    #2,D1               ; PSR W Bit testen
          BEQ     BE_notMMU
BE_test_RWM_write40
          BTST    #9,D0               ; SSW LK Bit testen (RWM Bus Zyklus)
          BNE     BE_write
          BRA     BE_notMMU
BE_transparent40
          BTST    #1,D0               ; SSW TM1 Bit testen (Code / Data?)
          BNE     BE_transparentcode40
BE_transparentdata40
          DC.W    $4E7A,$1006         ; MOVEC   DTT0,D1
          BSR     TestMatch
          BEQ     BE_test_RWM_write
          DC.W    $4E7A,$1007         ; MOVEC   DTT1,D1
          BSR     TestMatch
          BEQ     BE_test_RWM_write
          BRA     BE_notMMU
BE_transparentcode40
          DC.W    $4E7A,$1004         ; MOVEC   ITT0,D1
          BSR     TestMatch
          BEQ     BE_test_RWM_write
          DC.W    $4E7A,$1005         ; MOVEC   ITT1,D1
          BSR     TestMatch
          BNE     BE_notMMU
BE_test_RWM_write
          BTST    #2,D1               ; xTTx W Bit testen
          BEQ     BE_notMMU
          BRA     BE_test_RWM_write40
TestMatch
          MOVEM.L D2/D3,-(SP)
          BTST    #15,D1              ; xTTx E Bit testen
          BEQ     NotTestMatch
          MOVE.L  D1,D2               ; xTTx Base und Mask holen
          SWAP    D2
          MOVE.W  D2,D3
          ANDI.W  #$FF,D3
          EORI.B  #$FF,D3             ; ergibt Mask
          LSR.W   #8,D2               ; ergibt Base
          AND.W   D3,D2               ; Base maskieren
          SWAP    D2
          MOVE.W  D3,D2               ; beides in einem Register merken
          MOVE.L  A0,D3               ; Fault Adresse holen
          SWAP    D3
          LSR.W   #8,D3               ; High Byte holen
          AND.W   D2,D3               ; Fault Adresse High Byte maskieren
          SWAP    D2
          CMP.W   D2,D3               ; und mit Base maskieren
          BNE     NotTestMatch
TestMatch0
          BTST    #2,D1               ; xTTx W Bit testen
          BEQ     TestMatch1
          BTST    #9,D0               ; SSW LK Bit testen
          BNE     NotTestMatch
          BTST    #8,D0               ; SSW RW Bit testen
          BEQ     NotTestMatch
TestMatch1
          BTST    #14,D1              ; xTTx 2.Bit des S Feldes testen
          BNE     TestMatch2
          MOVE.L  D1,D3               ; xTTx 1.Bit des S Feldes gleich TM2?
          LSR.L   #8,D3
          LSR.L   #6,D3
          ANDI.B  #1,D3
          MOVE.L  D0,D2
          LSR.L   #2,D2
          ANDI.B  #1,D2
          CMP.B   D2,D3
          BNE     NotTestMatch
TestMatch2
          MOVE.L  D1,D3               ; CM ÅberprÅfen
          LSR.L   #5,D3
          ANDI.B  #3,D3
          MOVE.L  TestMMUTemp(A4),D2  ; statt DC.W $4E7A,$2805 = MOVEC  PSR,D2
          LSR.L   #5,D2
          ANDI.B  #3,D2
          CMP.B   D2,D3
          BNE     NotTestMatch
          MOVEM.L (SP)+,D2/D3
          ORI     #Zero,CCR
          RTS
NotTestMatch
          MOVEM.L (SP)+,D2/D3
          ANDI.B  #NegZero,CCR
          RTS

; !MAC-Version ist anders!
!MONBE    ST      inTMonBUSerr(A4)
          BSR     TestMMUBusError
          BSR.L   PULLEADR        ; HOLE ERROR - ADRESSE V. STACK
          BSR     PRTCRLF
          MOVE.L  MMUMSG(A4),D1
          BEQ     ERR12
          MOVE.L  D1,A1
          BSR     PrtSTR
(*        MOVE.W  TestMMUTemp(A4),D0
          BSR     PrtWORD *)
          BSR     PRTCRLF
!ERR12    MOVEQ   #12,D6
          BRA     PrintErr

!MONAE    BSR.L   PULLEADR        ; HOLE ERROR - ADRESSE V. STACK
          BSR     PRTCRLF
!ERR13    MOVEQ   #13,D6
          BRA     PrintErr

!MONIRQ7  BSR.L   PULLEADR
          BSR     PRTCRLF
          LEA     ERRMSG(PC),A1
          BSR     PRTSTR
          LEA     IRQMSG(PC),A1
          BSR     PRTSTR
          MOVEQ   #$7,D0
          BSR     PRTBYTE
          BRA.L   CMDstart

!MONILLIRQ
          BSR.L   PULLEADR
          BSR     PRTCRLF
          LEA     ERRMSG(PC),A1
          BSR     PRTSTR
          LEA     ILLIMSG(PC),A1
          BSR     PRTSTR
          BRA.L   CMDstart

!ERR14    MOVEQ   #14,D6
          BRA     PrintErr

!ERR15    MOVEQ   #15,D6
          BRA     PrintErr

!ERR16    MOVEQ   #16,D6          ; : Illegal register
          BRA     PrintErr

!ERR17    MOVEQ   #17,D6          ; : too many param.
          BRA     PrintErr

!ERR18    MOVEQ   #20,D6          ; : internal err #1
          BRA     PrintErr

!MONCE    BSR     PULLEADR        ; Coprocessor Protocol Violation
          BSR     PRTCRLF
!ERR19    MOVEQ   #18,D6
          BRA     PrintErr

!ERR20    MOVEQ   #19,D6
          BRA     PrintErr

!PULLEADR MOVEA.L (A7)+,A0        ; HOLE RTS-ADRESSE V. STACK

          TST     StkFrm(A4)
          BEQ.L   noFrame2

          ; *** BUS/ADR-Error bei 68020/030 behandeln ***
          MOVE.W  (A7)+,D5        ; HOLE SR V. STACK
          MOVEA.L (A7)+,A5        ; HOLE PC
          MOVE.W  (A7)+,D0        ; Hole Stack-Frame
          MOVE.W  D0,D3
          ANDI.W  #$F000,D3
          CMPI.W  #$8000,D3
          BEQ     STFORMAT8       ; Bus / Adresserror bei 68010
          MOVE.L  A7,A2
          MOVE.W  D3,D1
          CMPI.W  #$1000,D3       ; Throwaway Exeption Stack Frame?
          BNE     CPUinI
          MOVEC.L MSP,A2          ; Dann vom Master Stack holen
          MOVE.W  (A2)+,D5
          MOVEA.L (A2)+,A5
          MOVE.W  (A2)+,D0
          MOVE.W  D0,D1
          ANDI.W  #$F000,D1
          MOVEC.L A2,MSP
CPUinI    CMPI.W  #$7000,D1
          BEQ     STFORMAT7       ; Buserror bei 68040
          CMPI.W  #$2000,D1
          BEQ     STFORMAT2       ; Adresserror bei 68040
          MOVE.L  8(A2),D1        ; ADRESSE,AUF DIE ILLEGAL ZUGEGRIFFEN WURDE
          MOVE.W  2(A2),D6        ; HOLE SUPER-STATUS-WORT V. STACK
          BMI     takePipeC       ; Fehler war in Pipe C?
          MOVE.W  6(A2),D4        ; HOLE AUSGEFöHRTEN BEFEHLS-CODE
          BRA     wasPipeB
takePipeC MOVE.W  4(A2),D4        ; HOLE AUSGEFöHRTEN BEFEHLS-CODE
          BRA.S   wasPipeB

STFORMAT2                         ; Adresserror bei 68040
          MOVE.L  0(A2),D1        ; Adresse
(* !MAC: erzeugt Bus-Error
          MOVE.L  -4(A2),A2
          MOVE.W  (A2),D4         ; Befehlscode
*)
          CLR.L   D6
          BRA.S   wasPipeB

STFORMAT7                         ; Buserror bei 68040
          MOVE.W  4(A2),D6        ; Superstatuswort
          MOVE.L  12(A2),D1       ; Adresse, die Fehler auslîste
(* !MAC: erzeugt Bus-Error
          MOVE.L  -4(A2),A2
          MOVE.W  (A2),D4         ; Befehlscode
*)
          BRA.S   wasPipeB

STFORMAT8 ; *** BUS/ADR-Error bei 68010 behandeln ***
          MOVE.L  2(A7),D1
          CLR.L   D6
          MOVE.W  16(A7),D4

wasPipeB  ; Stack-Rest bei 68010/020/030/040 abrÑumen
          MOVE    D0,D2
          ROL     #5,D0
          ANDI    #$1E,D0
          LEA     SFTbl(PC),A1
          CMPI    #$1000,D3       ; Throwaway Exeption StackFrame ?
          BEQ     MasterStack     ; dann MasterStack aufrÑumen
          ADDA.W  0(A1,D0.W),A7
          MOVE.W  0(A1,D0.W),D0
          JMP     (A0)            ; RTS

MasterStack                       ; Masterstack aufrÑmen
          ADDA.W  0(A1,D0.W),A2   ; der Interrruptstack ist schon richtig
          MOVEC.L A2,MSP          ; abgerÑumt
          MOVE.W  0(A1,D0.W),D0
          JMP     (A0)

noFrame2  ; *** BUS/ADR-Error bei 68000 behandeln ***
          MOVE.W  (A7)+,D6        ; HOLE SUPER-STATUS-WORT V. STACK
          ANDI.W  #$1F,D6
          MOVE.L  (A7)+,D1        ; ADRESSE,AUF DIE ILLEGAL ZUGEGRIFFEN WURDE
          MOVE.W  (A7)+,D4        ; HOLE AUSGEFöHRTEN BEFEHLS-CODE
          MOVE.W  (A7)+,D5        ; HOLE SR V. STACK
          MOVEA.L (A7)+,A5        ; HOLE PC
          JMP     (A0)            ; RTS

; Warteschleife bei 68020

DelayIf20 TST     is20(A4)
          BEQ     noDelay
          MOVE.L  DumpDelay(PC),D0
          TST     video_modus(A4)
          BEQ     delay2
          MOVE.L  DumpDelay2(PC),D0
          BRA     delay2
delay1    SWAP    D0
delay2    NOP
          DBRA    D0,delay2
          SWAP    D0
          DBRA    D0,delay1
noDelay   RTS


WhichCPU  MOVEQ   #0,D1
          TST     is10(A4)
          BEQ     WhichCPU3
          MOVEQ   #1,D1
          TST     is20(A4)
          BEQ     WhichCPU3
          MOVEQ   #2,D1
          TST     is30(A4)
          BEQ     WhichCPU1
          MOVEQ   #3,D1
!WhichCPU1
          TST     isFPU(A4)
          BEQ     WhichCPU2
          BSET    #4,D1
!WhichCPU2
          TST     is40(A4)
          BEQ     WhichCPU3
          MOVEQ   #4,D1
!WhichCPU3
          RTS


!InitKeyBuf
          MOVEM.L D0/A0,-(SP)
          LEA     KEYBUF(A4),A0
          MOVE.B  #PROMPT,(A0)+
          MOVE.W  #79,D0
!InitKeyBufLoop
          MOVE.B  #SPC,(A0)+
          DBRA    D0,InitKeyBufLoop
          MOVEM.L (SP)+,D0/A0
          RTS


; Inhalt des Keyboard Puffers an aktuelle Zeile ausgeben
; Inklusive Prompt-Zeichen zum Beginn der Zeile

!DispKeyBuf
          MOVEM.L D0-D6/A0-A2,-(SP)
          MOVE.W  CursorX(A4),-(SP)
          CLR.W   CursorX(A4)
          CLR.L   D1
          LEA     KEYBUF(A4),A2
          MOVE.W  #79,D6
!DispKeyBufLoop
          MOVE.W  D6,CursorX(A4)
          MOVE.B  0(A2,D6.w),D0
          BSR     ScrnOutput
          DBRA    D6,DispKeyBufLoop
          MOVE.W  (SP)+,CursorX(A4)
          MOVEM.L (SP)+,D0-D6/A0-A2
          RTS


!GETLINE  MOVE.W  PrHandle(A4),-(A7)
          CLR.W   PrHandle(A4)
          BSR.L   GetKeyBuf
          BSR     CURSORON
          LEA     KEYBUF(A4),A6
          MOVEA.L A6,A5
          ADDA.W  Rows(A4),A5
          ADDQ.W  #1,A6               ;          MOVE.B  #PROMPT,(A6)+
!GETLN2
;         MOVEA.L A6,A5
!GETLN1   BSR.L   WAITKEY
          CMPI.B  #ESCKey,D0
          BEQ.L   GETLNESC
          CMPI.B  #CR,D0
          BEQ.L   GETLNEND
          CMPI.B  #BSKey,D0
          BEQ.L   GETLNBSP
          CMPI.B  #DelKey,D0
          BEQ.L   GETLNDEL
          CMPI.B  #InsKey,D0
          BEQ.L   GETLNINS
          CMPI.B  #CurLKey,D0
          BEQ.L   GETLNLE
          CMPI.B  #HomeKey,D0
          BEQ.L   GETLNHOMEKEY
          CMPI.B  #BStartKey,D0
          BEQ.L   GETLNBStartKey
          CMPI.B  #AHomeKey,D0
          BEQ.L   GETLNAHOMEKEY
          CMPI.B  #BEndeKey,D0
          BEQ.L   GETLNBEndeKey
          CMPI.B  #StartKey,D0
          BEQ.L   GETLNSTARTKEY
          CMPI.B  #ClearKey,D0
          BEQ.L   GETLNCLEARKEY
          CMPI.B  #EndKey,D0
          BEQ.L   GETLNENDKEY
          CMPI.B  #WordLKey,D0
          BEQ.L   SearchLastWord
          CMPI.B  #WordRKey,D0
          BEQ.L   SearchNextWord
          CMPI.B  #WordHome,D0
          BEQ.L   SearchWordStart
          CMPI.B  #WordEnd,D0
          BEQ.L   SearchWordEnd
          CMPI.B  #PgUpKey,D0
          BEQ.L   GETLNPGUPKEY
          CMPI.B  #PgDnKey,D0
          BEQ.L   GETLNPGDNKEY
          MOVE    CursorX(A4),D1
          ADDQ    #1,D1
          CMP.W   Rows(A4),D1
          BCC     GETLN1
          CMPI.B  #CurRKey,D0
          BEQ.L   GETLNRTP
          CMPI.B  #SPC,D0
          BCS.L   GETLN1
          TST.W   EditModus(A4)
          BPL     OverwriteChar
          MOVE.W  D0,-(SP)
          BSR.L   GETINSPROC
          MOVE.W  (SP)+,D0
OverwriteChar
          MOVE.B  D0,(A6)+
!GETLN3   BSR     Prt
          SF      HisUsed(A4)
;          CMPA.L  A5,A6
;          BHI     GETLN2
          BRA     GETLN1

!GETLNEND LEA     KEYBUF(A4),A6
          CMPI.B  #PROMPT,(A6)
          BNE     GETLNE3
          BSR.L   InsertHistory
          MOVE.L  Makros(A4),D0
          BEQ     GETLNENDC
          MOVE.W  (SP),PrHandle(A4)
          BSR.L   GETKEYCALL
          CLR.W   PrHandle(A4)
          TST.L   D0
          BEQ     GETLN1
GETLNENDC LEA     KEYBUF(A4),A6
          LEA     79(A6),A6
GETLNEND1 CMPI.B  #SPC,-(A6)
          BEQ.S   GETLNEND1
          CMPI.B  #0,(A6)
          BEQ.S   GETLNEND1
          ADDQ.L  #1,A6
          MOVE.B  #CR,(A6)
          MOVE.L  A6,D0
          LEA     KEYBUF(A4),A6
          SUB.L   A6,D0
          MOVE.W  D0,CursorX(A4)
          MOVE.W  (A7)+,PrHandle(A4)
          BEQ     GETLNE2
          ST      NoScrDisp(A4)
          ADDQ.L  #1,A6             ; erstes Zeichen (PROMPT) nicht ausdrucken
GETLNEL   MOVE.B  (A6)+,D0          ; eingegebene Zeile ins Protokollfile
          CMPI.B  #CR,D0
          BEQ     GETLNE1
          BSR     Prt
          BRA     GETLNEL
GETLNE1   SF      NoScrDisp(A4)
          LEA     KEYBUF(A4),A6
GETLNE2   BSR     PRTNEWLINE
          BRA.L   CURSOROFF
GETLNE3   BSR     PRTNEWLINE
          BSR.L   GetKeyBuf
          CMPI.B  #PROMPT,(A6)
          BNE     GETLN1
          ADDQ.L  #1,A6
          MOVE.W  #1,CursorX(A4)
          BRA     GETLN1

!GETLNLE  MOVE.W  CursorX(A4),D0
          SUBQ.W  #1,D0
          BMI     GETLNLE1
          MOVE.W  D0,CursorX(A4)
          SUBQ.L  #1,A6
GETLNLE1
          CLR.L   D0
          MOVE.B  (A6),D0
          BRA     GETLN1

!GETLNESC
          BSR.L   SaveKeyBuf
          MOVE.W  #1,CursorX(A4)
          LEA     KEYBUF(A4),A6
          ADDQ.L  #1,A6
          BSR     InitKeyBuf
          BSR     DispKeyBuf
          CLR.L   D0
          BRA     GETLN1

!GETLNBSP LEA     KEYBUF(A4),A0
          CMPA.L  A0,A6
          BLE     GETLN1
          MOVE.W  CursorX(A4),D0
          SUBQ.W  #1,D0
          BEQ     GETLN1
          MOVE.W  D0,CursorX(A4)
          SUBQ.L  #1,A6
;          SUBA.W  #1,A5
;          MOVE.W  CursorX(A4),D0
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
          SUB.W   CursorX(A4),D0
          ADDA.W  CursorX(A4),A0
GETLNBSPLOOP
          MOVE.B  1(A0),(A0)+
          DBRA    D0,GETLNBSPLOOP
          BSR     DispKeyBuf
          BRA     GETLN1

!GETLNDEL LEA     KEYBUF(A4),A0
          CMPA.L  A0,A6
          BLT     GETLN1
;          SUBA.W  #1,A5
;          MOVE.L  A0,A1
;          ADDA.W  CursorX(A4),A1
;          CMPA.L  A1,A5
;          BGE     GETLNDELOK
;          MOVE.L  A1,A5
GETLNDELOK
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
          SUB.W   CursorX(A4),D0
          ADDA.W  CursorX(A4),A0
GETLNDELPLOOP
          MOVE.B  1(A0),(A0)+
          DBRA    D0,GETLNDELPLOOP
          BSR     DispKeyBuf
          BRA     GETLN1

!GETLNINS
          TST.W   EditModus(A4)
          BEQ     SwitchIns0
          BMI     SwitchIns1
          BSR     GETINSPROC
          BRA     GETLN1
SwitchIns0
          MOVE.W  #$FFFF,EditModus(A4)
          BRA     GETLN1
SwitchIns1
          CLR.W   EditModus(A4)
          BRA     GETLN1

!GETINSPROC
          LEA     KEYBUF(A4),A0
          CMPA.L  A0,A6
          BLT     GETLN1
          ADDQ.L  #1,A5
          MOVE.W  Rows(A4),D0
          SUBQ.W  #2,D0
          SUB.W   CursorX(A4),D0
          ADDA.W  Rows(A4),A0
GETLNINSPLOOP
          MOVE.B  -2(A0),-(A0)
          DBRA    D0,GETLNINSPLOOP
          MOVE.B  #SPC,-(A0)
          BRA     DispKeyBuf

!GETLNHOMEKEY
          TST.W   CursorY(A4)
          BNE.S   GETLNHOMEKEY1
          CLR.W   CursorX(A4)
!GETLNHOMEKEY1
          CLR.W   CursorY(A4)
          BSR.L   GetKeyBuf
          SF      HisUsed(A4)
          SF      noScrolling(A4)
          BRA.L   GETLNSTARTKEY

!GETLNAHOMEKEY
          MOVE.W  Lines(A4),D0
          SUBQ.W  #1,D0
          CMP.W   CursorY(A4),D0
          BNE     GETLNAHOMEKEY1
          MOVE.W  D0,CursorY(A4)
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
          MOVE.W  D0,CursorX(A4)
          BRA.S   GETLNAHOMEKEY2
!GETLNAHOMEKEY1
          MOVE.W  D0,CursorY(A4)
!GETLNAHOMEKEY2
          BSR.L   GetKeyBuf
          SF      HisUsed(A4)
          SF      NoScrolling(A4)
          BRA.L   GETLNSTARTKEY

!GETLNBEndeKey
          BSR     TestButtom
          TST     D0
          BEQ     GETLNAHOMEKEY
          BSR     SetScrnBufButtom
          BSR     RestoreScrn
          SF      HisUsed(A4)
          BSR.L   GetKeyBuf
          BRA     GETLN1

!GETLNBStartKey
          BSR     TestTop
          TST     D0
          BEQ     GETLNHOMEKEY
          BSR     SetScrnBufTop
          BSR     RestoreScrn
          SF      HisUsed(A4)
          BSR.L   GetKeyBuf
          BRA     GETLN1

!GETLNPGUPKEY
          TST.B     noScrolling(A4)
          BNE       GETLN1
          ST        noScrolling(A4)
          BSR       TestTop
          TST       D0
          BEQ       GETLNHOMEKEY
          BSR       TestUp
          TST       D0
          BEQ       GETLNPGUPKEY1
          BSR       ScrollScrnBufDn
;          BSR       ScrollScrnBufUp
          BRA.S     GETLNPGUPKEY2
GETLNPGUPKEY1
          BSR       SetScrnBufTop
GETLNPGUPKEY2
          BSR       RestoreScrn
          SF        HisUsed(A4)
          BSR.L     GetKeyBuf
          MOVE.W    CursorX(A4),D0
          LEA       KeyBuf(A4),A6
          ADDA.W    D0,A6
          SF        noScrolling(A4)
          BRA       GETLN1

!GETLNPGDNKEY
          TST.B     noScrolling(A4)
          BNE       GETLN1
          ST        noScrolling(A4)
          BSR       TestButtom
          TST       D0
          BEQ       GETLNAHOMEKEY
          BSR       TestDn
          TST       D0
          BEQ       GETLNPGDNKEY1
          BSR       ScrollScrnBufUp
;          BSR       ScrollScrnBufDn
          BRA.S     GETLNPGDNKEY2
GETLNPGDNKEY1
          BSR       SetScrnBufButtom
GETLNPGDNKEY2
          BSR       RestoreScrn
          SF        HisUsed(A4)
          BSR.L     GetKeyBuf
          MOVE.W    CursorX(A4),D0
          LEA       KeyBuf(A4),A6
          ADDA.W    D0,A6
          SF        noScrolling(A4)
          BRA       GETLN1

!GETLNCLEARKEY
          BSR.L   SaveKeyBuf
          MOVE.W  CursorX(A4),D0
          LEA     KEYBUF(A4),A0
GETLNCLR1 CMPI.W  #80,D0
          BCC     GETLNCLR2
          CLR.B   0(A0,D0.W)
          ADDQ.W  #1,D0
          BRA     GETLNCLR1
GETLNCLR2 BSR     DispKeyBuf
          CLR.L   D0
          BRA     GETLN1

!GETLNSTARTKEY
          MOVE.W  #1,CursorX(A4)
          LEA     KEYBUF(A4),A6
          ADDQ.L  #1,A6
          BRA     GETLN1

; NÑchstes Wort suchen (A5 muss auf Eingabeende zeigen!)

SearchNextWord
          LEA     KEYBUF(A4),A1
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
SearchNextWordLoop                      ; Ende der Zeile suchen
          CMPI.B  #CR,0(A1,D0.w)
          BEQ     SearchNextWordLoop1
          CMPI.B  #SPC,0(A1,D0.w)
          BNE     SearchNextWordAbort
SearchNextWordLoop1
          DBRA    D0,SearchNextWordLoop
SearchNextWordAbort
          ADDQ.W  #1,D0
          CMP.W   Rows(A4),D0
          BLT     SearchNextWordLast
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
SearchNextWordLast
          ADDA.W  D0,A1
          LEA     KEYBUF(A4),A0
          ADDA.W  CursorX(A4),A0
          CMPI.B  #SPC,(A0)
          BEQ     SearchNextWord2
SearchNextWord1
          CMPA.L  A1,A0
          BGE     SearchNextWordE
          CMPI.B  #SPC,(A0)+
          BNE     SearchNextWord1
SearchNextWord2
          CMPA.L  A1,A0
          BGE     SearchNextWordE
          CMPI.B  #SPC,(A0)+
          BEQ     SearchNextWord2
          SUBQ.L  #1,A0
SearchNextWordE
          MOVE.L  A0,A6
          LEA     KEYBUF(A4),A0
          MOVE.L  A6,D0
          SUB.L   A0,D0
          MOVE.W  D0,CursorX(A4)
          BRA     GETLN1

; Letztes Wort suchen

SearchLastWord
          CMPI.W  #1,CursorX(A4)
          BEQ     SearchLastWordA
          LEA     KEYBUF(A4),A0
          MOVE.L  A0,A1
          ADDQ.L  #1,A1
          ADDA.W  CursorX(A4),A0
          CMPI.B  #SPC,-1(A0)
          BEQ     SearchLastWord2
          CMPI.B  #SPC,(A0)
          BNE     SearchLastWord1
          SUBQ.L  #1,A0
SearchLastWord1
          CMPA.L  A1,A0
          BLE     SearchLastWordE
          CMPI.B  #SPC,-(A0)
          BNE     SearchLastWord1
SearchLastWord2
          CMPA.L  A1,A0
          BLE     SearchLastWordE
          CMPI.B  #SPC,-(A0)
          BEQ     SearchLastWord2
          ADDQ.L  #1,A0
SearchLastWordE
          MOVE.L  A0,A6
          LEA     KEYBUF(A4),A0
          MOVE.L  A6,D0
          SUB.L   A0,D0
          MOVE.W  D0,CursorX(A4)
SearchLastWordA
          BRA     GETLN1

SearchWordEnd
          LEA     KEYBUF(A4),A1
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
SearchWordLoop                           ; Ende der Zeile suchen
          CMPI.B  #CR,0(A1,D0.w)
          BEQ     SearchWordLoop1
          CMPI.B  #SPC,0(A1,D0.w)
          BNE     SearchWordAbort
SearchWordLoop1
          DBRA    D0,SearchWordLoop
SearchWordAbort
          ADDQ.W  #1,D0
          CMP.W   Rows(A4),D0
          BLT     SearchWordLast
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
SearchWordLast
          ADDA.W  D0,A1
          LEA     KEYBUF(A4),A0
          ADDA.W  CursorX(A4),A0
          CMPI.B  #SPC,(A0)
          BEQ     SearchWordEndA
SearchWordEnd1
          CMPA.L  A1,A0
          BGE     SearchWordEndE
          CMPI.B  #SPC,(A0)+
          BNE     SearchWordEnd1
          SUBQ.L  #1,A0
SearchWordEndE
          MOVE.L  A0,A6
          LEA     KEYBUF(A4),A0
          MOVE.L  A6,D0
          SUB.L   A0,D0
          MOVE.W  D0,CursorX(A4)
          CMP.W   Rows(A4),D0
          BLT     SearchWordEndA
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
          MOVE.W  D0,CursorX(A4)
          ADDA.W  D0,A0
          MOVE.L  A0,A6
SearchWordEndA
          BRA     GETLN1


SearchWordStart
          LEA     KEYBUF(A4),A0
          MOVE.L  A0,A1
          ADDQ.L  #1,A1
          ADDA.W  CursorX(A4),A0
          CMPI.B  #SPC,(A0)
          BNE     SearchWordStart1
          CMPI.B  #SPC,-1(A0)
          BEQ     SearchWordStartA
SearchWordStart1
          CMPA.L  A1,A0
          BLE     SearchWordStartE
          CMPI.B  #SPC,-(A0)
          BNE     SearchWordStart1
          ADDQ.L  #1,A0
SearchWordStartE
          MOVE.L  A0,A6
          LEA     KEYBUF(A4),A0
          MOVE.L  A6,D0
          SUB.L   A0,D0
          MOVE.W  D0,CursorX(A4)
SearchWordStartA
          BRA     GETLN1

!GETLNENDKEY
          LEA     KEYBUF(A4),A0
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
GetLNEndKeyLoop                           ; Ende der Zeile suchen
          CMPI.B  #CR,0(A0,D0.w)
          BEQ     GetLNEndKeyLoop1
          CMPI.B  #SPC,0(A0,D0.w)
          BNE     GetLNEndKeyAbort
GetLNEndKeyLoop1
          DBRA    D0,GetLNEndKeyLoop
GetLNEndKeyAbort
          ADDQ.W  #1,D0
          CMP.W   Rows(A4),D0
          BLT     GetLNEndKeyLast
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
GetLNEndKeyLast
          ADDA.W  D0,A0
          MOVE.L  A0,A6
          MOVE.W  D0,CursorX(A4)
          BRA     GETLN1


!GETLNRTP CMPA.L  A5,A6
          BEQ     GETLN1
          MOVE.B  (A6)+,D0
          ADDQ.W  #1,CursorX(A4)
          BRA     GETLN1

!GETKEYCALL
          BSR     CursorOff
          MOVEM.L D1-D7/A0-A4,-(SP)
          MOVE.L  D0,A2
          MOVEQ   #0,D0
          BSR     KbShift
          LEA     CursorX(A4),A1
          LEA     KeyBuf(A4),A0
          BSR     WhichCPU
          JSR     (A2)
          MOVE.L  D0,-(SP)
          BNE     GETKEYCALLEND
          BSR     InitKeyBuf
          BSR     DispKeyBuf
          MOVE.W  #1,CursorX(A4)
!GETKEYCALLEND
          MOVE.L  (SP)+,D0
          MOVEM.L (SP)+,D1-D7/A0-A4
          LEA     KEYBUF(A4),A6
          MOVE.L  A6,A5
          ADDA.W  Rows(A4),A5
          ADDA.W  CursorX(A4),A6
          RTS
!GETKEY                         ; Holt Zeichen von Tastatur, wenn kein Zeichen
                                ; ansteht, wird D0.W = 0
          BSR     CONSTAT
          TST.L   D0
          BEQ.L   GETKEYE1
          BSR     DIRCONIN

(*$? ~MAC:
          SWAP    D0

          CMPI.B  #SysMonKey,D0 ; Help mit rechts-Shift?
          BNE.L   GETKEYC01
          BSR     KbShift
          CMPI.B  #SysMonMask,D0
          BEQ     GETKEYTestSysMon
GETKEYTestHelp
          MOVE.L  OnLineHelp(A4),D0
          BEQ.L   GETKEYE1
          BSR     GETKEYCALL
          TST.L   D0
          BEQ.L   GETKEYE1
          MOVE.L  #$000D001C,D0 ; Returntaste mit Scancode annehmen!
          BRA.L   GETKEYE0
GETKEYTestSysMon
          TST.B   SysMonCall(A4)
          BNE.L   to_CookieRoutine10Return
GETKCALLSYSMON
          MOVEM.L A0-A2/D1,-(SP)
          MOVE.L  BUSERRV,A0
          MOVE.L  SP,A1
          MOVE.W  SR,D1
          LEA     GETKBUSERR(PC),A2
          MOVE.L  A2,$8
          TST.L   SysMonAdresse(A4)
          BEQ     NOSYSMON
          TST.L   SysMonSemaphor(A4)
          BEQ     NOSYSMON
          MOVE.L  SysMonSemaphor(A4),A2
          TST.B   (A2)
          BNE     NOSYSMON
          MOVE.L  SysMonAdresse(A4),A2
          MOVE.L  A2,D0
          BTST.L  #0,D0        ; Adresserrorexeption verhindern
          BNE     NOSYSMON
          TST.W   (A2)         ; auf Buserror testen
          MOVE.L  A0,BUSERRV   ; Buserrorvektor restaurieren
          ST      TempleMonCall(A4)
          BSR     ScrnCurOff
          MOVEM.L D2-D7/A3-A6,-(SP)
          MOVE.W  SR,-(SP)
          JSR     (A2)
          MOVE.W  (SP)+,SR
          MOVEM.L (SP)+,D2-D7/A3-A6
          BSR     MonScrn
          BSR     ScrnCurOn
          SF      TempleMonCall(A4)
          BRA.S   NOSYSMON1
GETKBUSERR
          BSR     TestMMUBusError
          MOVE.L  A1,SP
          MOVE.W  D1,SR
NOSYSMON  MOVE.L  A0,$8
NOSYSMON1 MOVEM.L (SP)+,A0-A2/D1
          MOVEQ   #0,D0
          BRA.L   GETKEYE1

GETKEYC01 CMPI.B  #$3B,D0       ; F1 ?
          BNE     GETKEYC0

          BSR     MonScrn       ; Monitor-Screen einschalten
          BSR     ScrnCurOn
          MOVEQ   #0,D0

GETKEYC0  CMPI.B  #$3C,D0       ; F2 ?
          BNE     GETKEYC1
          TST.B   SysMonCall(A4)
          BNE     GETKEYC0Off
          TST.B   TempleMonCall(A4)
          BNE     GETKEYC0Off
          BSR     ScrnCurOff
          BSR     NormScrn      ; Monitor-Screen ausschalten
GETKEYC0Off
          MOVEQ   #0,D0

GETKEYC1  CMPI.B  #$4B,D0       ; Cursor left?
          BNE     GETKEYC11

          BSR     KbShift
          ANDI.B  #$f,D0
          BEQ     MoveLeft

          MOVEQ   #StartKey,D0
          RTS
MoveLeft
          MOVEQ   #CurLKey,D0
          RTS

GETKEYC11 CMPI.B  #$73,D0       ; Vdi Code CNTRL Cursor Left?
          BNE     GETKEYC2

          BSR     KbShift
          ANDI.B  #$3,D0
          BEQ     CLeft
          MOVEQ   #WordHome,D0
          RTS
CLEFT
          MOVEQ   #WordLKey,D0
          RTS

GETKEYC2  CMPI.B  #$4D,D0       ; Cursor right?
          BNE     GETKEYC22

          BSR     KbShift
          ANDI.B  #$f,D0
          BEQ     MoveRight

          MOVEQ   #EndKey,D0
          RTS
MoveRight
          MOVEQ   #CurRKey,D0
          RTS

GETKEYC22 CMPI.B  #$74,D0       ; VDI Code CNTRL Cursor right?
          BNE     GETKEYC3

          BSR     KbShift
          ANDI.B  #$3,D0
          BEQ     CRight
          MOVEQ   #WordEnd,D0
          RTS
CRight
          MOVEQ   #WordRKey,D0
          RTS

GETKEYC3  CMPI.B  #$47,D0       ; CLR HOME ?
          BNE     GETKEYC36

          BSR     KbShift
          ANDI.B  #$F,D0
          BNE     GETKEYC31
          MOVEQ   #HomeKey,D0
          RTS
GETKEYC31 CMPI.B  #3,D0
          BGT     GETKEYC32
          MOVEQ   #ClearKey,D0
          RTS
GETKEYC32 MOVEQ   #AHomeKey,D0
          RTS

GETKEYC36 CMPI.B  #79,D0        ; VDI Code END
          BNE     GETKEYC37
          MOVEQ   #AHomeKey,D0
          RTS

GETKEYC37 CMPI.B  #$77,D0       ; VDI Code CNTRL Home?
          BNE     GETKEYC4

          MOVEQ   #AHomeKey,D0
          RTS

GETKEYC4  CMPI.B  #$53,D0       ; Delete?
          BNE     GETKEYC5

          MOVEQ   #DelKey,D0
          RTS

GETKEYC5  CMPI.B  #$52,D0       ; Insert?
          BNE     GETKEYC6

          MOVEQ   #InsKey,D0
          RTS

GETKEYC6  CMPI.B  #$E,D0        ; Backspace?
          BNE     GETKEYC7

          MOVEQ   #8,D0
          RTS

GETKEYC7  CMPI.B  #$48,D0       ; Cursor Up?
          BNE     GETKEYC8

          BSR     KbShift
          LEA     edit_modus2(PC),A0
          ANDI.B  #$7,D0        ; Alternate wird nicht berÅcksichtigt
          BEQ     to_CursorUp
          CMPI.B  #$5,D0
          BCC     to_BSTA
          BTST.L  #2,D0
          BNE     to_PgUp
          CMPI.B  #3,D0
          BHI     to_CursorUp
          BTST    #7,(A0)
          BNE     to_PgUp1
to_SLHIS  BSR.L   SearchLastHistory
          BSR     CursorOn
          MOVEQ   #0,D0
          BRA.L   GETKEYE0
to_PgUp   BTST    #7,(A0)
          BNE     to_SLHIS
to_PgUp1  MOVEQ   #PgUpKey,D0
          RTS
to_BSTA   MOVEQ   #BStartKey,D0
          RTS
to_CursorUp
          BSR     CursorOff
          BSR     CursorUp
          BSR.L   GetKeyBuf
          BSR     DispKeyBuf
          SF      HisUsed(A4)
          BSR     CursorOn
          BRA.L   GETKEYE0

GETKEYC8  CMPI.B  #$50,D0       ; Cursor Down?
          BNE     GETKEYC9

          BSR     KbShift
          LEA     edit_modus2(PC),A0
          ANDI.B  #$7,D0        ; Alternate wird nicht berÅcksichtigt
          BEQ     to_CursorDown
          CMPI.B  #$5,D0
          BCC     to_BEND
          BTST.L  #2,D0
          BNE     to_PgDn
          CMPI.B  #3,D0
          BHI     to_CursorDown
          BTST    #7,(A0)
          BNE     to_PgDn1
to_SNHIS  BSR.L   SearchNextHistory
          BSR     CursorOn
          MOVEQ   #0,D0
          BRA.L   GETKEYE0
to_PgDn   BTST    #7,(A0)
          BNE     to_SNHIS
to_PgDn1  MOVEQ   #PgDnKey,D0
          RTS
to_BEND   MOVEQ   #BEndeKey,D0
          RTS
to_CursorDown
          BSR     CursorOff
          BSR     CursorDown
          BSR.L   GetKeyBuf
          BSR     DispKeyBuf
          SF      HisUsed(A4)
          BSR     CursorOn
          BRA.L   GETKEYE0

GETKEYC9  CMPI.B  #UndoKey,D0      ; UNDO ?
          BNE     GETKEYE0
          TST.B   HisUsed(A4)
          BEQ     GETKEYE0
          LEA     KEYBUF(A4),A1
          LEA     KEYBUF2(A4),A0
          MOVEQ   #19,D0
UndoLoop  MOVE.L  (A0)+,(A1)+
          DBRA    D0,UndoLoop
          BSR     DispKeyBuf
          BSR.L   AdjustBound
          BSR     CursorOn
          CLR.L   D0

GETKEYE0  SWAP    D0
          TST.W   D0
GETKEYE1  RTS
*)

(*$? MAC:
; Beginn Mac-Tastenabfrage (alles Åber ASCII-Codes statt Scan-Codes)

          MOVE.L  D0,-(A7)
          BSR     KbShift
          MOVE.B  D0,macShift(A4)
          MOVE.L  (A7)+,D0
          
          BTST    #0,macShift(A4)        ; Cmd-Key
          BEQ     GETKEYC01
          
          CMPI.B  #'1',D0       ; Cmd-1 oder Cmd-2?
          BEQ     GETKEYC02
          CMPI.B  #'2',D0
          BEQ     GETKEYC0
          
GETKEYC01 CMPI.B  #16,D0       ; F-Taste?
          BNE     GETKEYC1

          LSR     #8,D0
          CMPI.B  #120,D0       ; F2?
          BEQ     GETKEYC0
          CMPI.B  #122,D0       ; F1?
          BNE     GETKEYC1

GETKEYC02 BSR     MonScrn       ; Monitor-Screen einschalten
          BSR     ScrnCurOn
          MOVEQ   #0,D0
          RTS

GETKEYC0  TST.B   SysMonCall(A4)
          BNE     GETKEYC0Off
          TST.B   TempleMonCall(A4)
          BNE     GETKEYC0Off
          BSR     ScrnCurOff
          BSR     NormScrn      ; Monitor-Screen ausschalten
GETKEYC0Off
          MOVEQ   #0,D0
          RTS

GETKEYC1  CMPI.B  #28,D0       ; Cursor left?
          BNE     GETKEYC2

          MOVE.B  macShift(A4),D0
          BTST    #3,D0        ; Option-Key
          BNE     MoveWLeft
          BTST    #0,D0        ; Cmd-Key
          BNE     MoveSLeft
          BTST    #1,D0        ; Shift-Key
          BNE     MoveHome
          MOVEQ   #CurLKey,D0
          RTS
MoveSLeft MOVEQ   #WordHome,D0
          RTS
MoveHome  MOVEQ   #StartKey,D0
          RTS
MoveWLeft MOVEQ   #WordLKey,D0
          RTS

GETKEYC2  CMPI.B  #29,D0       ; Cursor right?
          BNE     GETKEYC3

          MOVE.B  macShift(A4),D0
          BTST    #3,D0        ; Option-Key
          BNE     MoveWEnd
          BTST    #0,D0        ; Cmd-Key
          BNE     CRight
          BTST    #1,D0        ; Shift-Key
          BNE     MoveEnd
          MOVEQ   #CurRKey,D0
          RTS
MoveEnd   MOVEQ   #EndKey,D0
          RTS
MoveWEnd  MOVEQ   #WordEnd,D0
          RTS
CRight    MOVEQ   #WordRKey,D0
          RTS

GETKEYC3  CMPI.B  #$01,D0       ; Home
          BNE     GETKEYC36
          MOVE.B  macShift(A4),D0
          ANDI.B  #$F,D0
          BNE     GETKEYC37
          MOVEQ   #HomeKey,D0
          RTS
GETKEYC37 MOVEQ   #BStartKey,D0
          RTS

GETKEYC36 CMPI.B  #04,D0        ; END
          BNE     GETKEYC35
          MOVE.B  macShift(A4),D0
          ANDI.B  #$F,D0
          BNE     GETKEYC39
          MOVEQ   #AHomeKey,D0
          RTS
GETKEYC39 MOVEQ   #BEndeKey,D0
          RTS

GETKEYC35 CMPI.B  #$18,D0       ; Ctrl-x
          BNE     GETKEYC7
          MOVEQ   #ClearKey,D0
          RTS

GETKEYC7  CMPI.B  #030,D0       ; Cursor Up?
          BNE     GETKEYC8

          MOVE.B  macShift(A4),D0
          ANDI.B  #$F,D0
          BEQ     to_CursorUp
          BTST.L  #2,D0
          BNE     to_PgUp
          CMPI.B  #3,D0
          BHI     to_CursorUp
          BSR.L   SearchLastHistory
          MOVEQ   #0,D0
          BRA.L   GETKEYE0
to_PgUp   MOVEQ   #PgUpKey,D0
          RTS
to_CursorUp
          BSR     CursorOff
          BSR     CursorUp
          BSR.L   GetKeyBuf
          BSR     DispKeyBuf
          SF      HisUsed(A4)
          BSR     CursorOn
          BRA.L   GETKEYE0

GETKEYC8
(*!!! TT: ClEoS/EoLKey gibt es leider noch nicht:
          CMPI.B  #127,D0       ; Delete?
          BNE     GETKEYC81
          
          MOVE.B  macShift(A4),D0
          AND     #10,D0        ; Shift+Option?
          BEQ     GETKEYC83
          CMP     #10,D0        ; Shift+Option?
          BEQ     GETKEYC82
          MOVEQ   #ClEoLKey,D0     ; nur Shift oder Option
          RTS
GETKEYC82 MOVEQ   #ClEoSKey,D0     ; beide gemeinsam
          RTS
GETKEYC83 MOVEQ   #127,D0
          RTS

GETKEYC81
*)
          CMPI.B  #031,D0       ; Cursor Down?
          BNE     GETKEYC9

          MOVE.B  macShift(A4),D0
          ANDI.B  #$F,D0
          BEQ     to_CursorDown
          BTST.L  #2,D0
          BNE     to_PgDn
          CMPI.B  #3,D0
          BHI     to_CursorDown
          BSR.L   SearchNextHistory
          MOVEQ   #0,D0
          BRA.L   GETKEYE0
to_PgDn   MOVEQ   #PgDnKey,D0
          RTS
to_CursorDown
          BSR     CursorOff
          BSR     CursorDown
          BSR.L   GetKeyBuf
          BSR     DispKeyBuf
          SF      HisUsed(A4)
          BSR     CursorOn
          BRA.L   GETKEYE0

GETKEYC9  CMPI.B  #25,D0      ; UNDO (ctrl-y)?
          BEQ     is_undo
          CMPI.B  #26,D0      ; UNDO (ctrl-z)?
          BNE     GETKEYE0
is_undo   TST.B   HisUsed(A4)
          BEQ     GETKEYE0
          LEA     KEYBUF(A4),A1
          LEA     KEYBUF2(A4),A0
          MOVEQ   #19,D0
UndoLoop  MOVE.L  (A0)+,(A1)+
          DBRA    D0,UndoLoop
          BSR     DispKeyBuf
          BSR.L   AdjustBound
          CLR.L   D0
GETKEYE0
          TST.W   D0
GETKEYE1  RTS
; Ende Mac-Tastenabfrage
*)

!WAITKEY  BSR     CursorOn
!WAITKEYL BSR     CursorBlink
          BSR     GETKEY
          BEQ     WAITKEYL
          BRA     CursorOff

!TSTKEY   BSR     GETKEY
          BEQ.S   TSTKEYE
          CMPI.B  #SPC,D0
          BNE.S   TSTKEYE         ; ENDE,WENN TASTE GEDRöCKT,UNGLEICH SPACE
          BSR     WAITKEY         ; BEI SPACE WARTEN AUF NEUE TASTE
          CMPI.B  #SPC,D0
!TSTKEYE  RTS

!GetKeyBuf
          MOVEM.L  A0/A1/D0,-(SP)
          MOVE.W   CursorY(A4),D0
          MULU     Rows(A4),D0
          MOVE.L   bMonScreen(PC),A1
          ADD.L    A1,D0
          BSR      CHKTop
          MOVE.L   D0,A1
          LEA      KEYBUF(A4),A0
          MOVE.W   Rows(A4),D0
          SUBQ.W   #1,D0
GetKBLoop MOVE.B   (A1)+,(A0)+
          DBRA     D0,GetKBLoop
          MOVEM.L  (SP)+,A0/A1/D0
          RTS


; History Funktionen


!InitHistory
          MOVEM.L A0/A1,-(SP)
          MOVE.L  HistoryStart(PC),A0
          MOVE.L  HistoryEnde(PC),A1
InitHistoryLoop
          MOVE.B  #SPC,(A0)+
          CMPA.L  A1,A0
          BCS     InitHistoryLoop
          MOVEM.L (SP)+,A0/A1
          RTS


!InsertHistory
          MOVE.L  HistoryEnde(PC),A0
          SUBA.L  HistoryStart(PC),A0
          CMPA.W  Rows(A4),A0
          BLT     InsertHistoryAbort            ; mindestens 80 Zeichen Puffer!
          MOVE.L  HistoryAktuell(PC),A0
          LEA     KEYBUF(A4),A1
          MOVE.W  Rows(A4),D0
          SUBQ.W  #2,D0
InsertHistoryTest
          TST.B   1(A1,D0.w)                    ; Prompt nicht abtesten
          BEQ     InsertHistoryTestNext
          CMPI.B  #SPC,1(A1,D0.w)
          BEQ     InsertHistoryTestNext
          CMPI.B  #CR,1(A1,D0.w)
          BNE     InsertHistoryTest1
InsertHistoryTestNext
          DBRA    D0,InsertHistoryTest
          BRA     InsertHistoryAbort
InsertHistoryTest1
          CMP.B   edit_minimum(PC),D0
          BLS     InsertHistoryAbort
          LEA     KEYBUF(A4),A1
          CMPI.B  #PROMPT,(A1)
          BNE     InsertHistoryAbort
          MOVE.W  Rows(A4),D0
          ASR.W   #2,D0
          SUBQ.W  #1,D0
InsertHistoryLoop
          MOVE.L  (A1)+,(A0)+
          DBRA    D0,InsertHistoryLoop
          CMPA.L  HistoryEnde(PC),A0
          BLT     InsertHistoryEnde
          MOVE.L  HistoryStart(PC),A0
InsertHistoryEnde
          MOVE.L  A0,D0
          LEA     HistoryAktuell(PC),A0
          MOVE.L  D0,(A0)
          LEA     HistorySuchen(PC),A0
          MOVE.L  D0,(A0)
          LEA     HistoryFill(PC),A0
          MOVE.L  (A0),D0
          CMP.L   HistoryEnde(PC),D0
          BGE     InsertHistoryAbort
          MOVEA.L D0,A1
          ADDA.W  Rows(A4),A1
          MOVE.L  A1,(A0)
InsertHistoryAbort
          RTS

!CopyFromHistory
          MOVE.L  HistoryFill(PC),A0
          SUBA.L  HistoryStart(PC),A0
          CMPA.W  Rows(A4),A0
          BLT     CopyFromHistoryAbort
          MOVE.L  HistorySuchen(PC),A0
          LEA     KEYBUF(A4),A1
          MOVE.W  Rows(A4),D0
          ASR.W   #2,D0
          SUBQ.W  #1,D0
CopyFromHistoryLoop
          MOVE.L  (A0)+,(A1)+
          DBRA    D0,CopyFromHistoryLoop
CopyFromHistoryAbort
          RTS

!SaveKeyBuf
          TST.B   HisUsed(A4)
          BNE     SaveKeyBufAbort
          LEA     KEYBUF(A4),A0
          LEA     KEYBUF2(A4),A1
          MOVE.W  Rows(A4),D0
          ASR.W   #2,D0
          SUBQ.W  #1,D0
SaveKeyBufLoop
          MOVE.L  (A0)+,(A1)+
          DBRA    D0,SaveKeyBufLoop
          ST      HisUsed(A4)
SaveKeyBufAbort
          RTS



!FPrt     ANDI.W  #$FF,D0
          MOVE.B  D0,ch(A4)
          MOVEM.L D0-D5/A0-A2,-(A7)
          BRA     FPrt1



mode_mac:   dc.w    $4ef0,$01e1,$00f0     ; jmp ([$F0])
mode_atari: dc.w    $4ef0,$01e1,$00f4     ; jmp ([$F4])


!SearchNextHistory
          MOVE.L  HistoryStart(PC),D0
          CMP.L   HistoryFill(PC),D0      ; Ist Åberhaupt schon was drin?
          BEQ     SearchNextHistoryAbort
          MOVE.L  HistorySuchen(PC),A0
          ADDA.W  Rows(A4),A0
          CMPA.L  HistoryAktuell(PC),A0
          BEQ     SearchNextHisClear0
          CMPA.L  HistoryFill(PC),A0      ; Obere Wassermarke erreicht?
          BLT     SearchNextHisTest
          MOVE.L  HistoryStart(PC),A0
!SearchNextHisTest
          CMPA.L  HistoryAktuell(PC),A0
          BEQ     SearchNextHisClear1
          MOVE.L  A0,D0
          LEA     HistorySuchen(PC),A1
          MOVE.L  D0,(A1)
          BSR     SaveKeyBuf
          BSR     CopyFromHistory
          BSR.L   AdjustBound
          ST      HisUsed(A4)
          BRA     DispKeyBuf
SearchNextHisClear0
          CMPA.L  HistoryFill(PC),A0      ; Obere Wassermarke erreicht?
          BLT     SearchNextHisClear1
          MOVE.L  HistoryStart(PC),A0
!SearchNextHisclear1
          MOVE.L  A0,D0
          LEA     HistorySuchen(PC),A1
;          MOVE.L  D0,(A1)
          BSR     SaveKeyBuf
          BSR     InitKeyBuf
          BSR.L   AdjustBound
          ST      HisClear(A4)
          ST      HisUsed(A4)
          BRA     DispKeyBuf
SearchNextHistoryAbort
          RTS

SearchLastHistory
          MOVE.L  HistoryStart(PC),D0
          CMP.L   HistoryFill(PC),D0      ; Ist Åberhaupt schon was drin?
          BEQ     SearchLastHistoryAbort
          MOVE.L  HistorySuchen(PC),A0
          TST.B   HisClear(A4)
          BEQ     SearchLastHistoryNormal
          SF      HisClear(A4)
          BRA     SearchLastHistoryCont
SearchLastHistoryNormal
          SUBA.W  Rows(A4),A0
SearchLastHistoryCont
          CMPA.L  HistoryStart(PC),A0     ; untere Wassermarke erreicht?
          BGE     SearchLastHisTest
          MOVE.L  HistoryFill(PC),A0
          CMPA.L  HistoryEnde(PC),A0
          BLT     SearchLastHisTest
          SUBA.W  Rows(A4),A0
SearchLastHisTest
          CMPA.L  HistoryAktuell(PC),A0
          BEQ     SearchLastHistoryAbort
          MOVE.L  A0,D0
          LEA     HistorySuchen(PC),A1
          MOVE.L  D0,(A1)
          BSR     SaveKeyBuf
          BSR     CopyFromHistory
          BSR     AdjustBound
          ST      HisUsed(A4)
          BRA     DispKeyBuf
SearchLastHistoryAbort
          RTS

AdjustBound
          LEA     KEYBUF(A4),A0
          MOVE.W  Rows(A4),D0
          SUBQ.W  #1,D0
AdjustBoundLoop                           ; Ende der Zeile suchen
          CMPI.B  #SPC,0(A0,D0.w)
          BNE     AdjustBound1
          DBRA    D0,AdjustBoundLoop
AdjustBound1
          ADDQ.W  #1,D0                   ; Vergleich mit aktueller Cursorpos.
          CMP.W   CursorX(A4),D0
          BCS     AdjustBound2
          MOVE.W  CursorX(A4),D0
AdjustBound2
          ADDA.W  D0,A0
          MOVE.W  D0,CursorX(A4)
          MOVE.L  A0,A6
          RTS

(*$? ~MAC:
!SetMon   ; D7 muû erhalten bleiben
          ; Register A1 nicht veraendern !
          MOVE    SR,-(A7)
          ORI     #$0700,SR
          BSR     SetMonVec
          LEA     EyCritic(PC),A5
          MOVE.L  etv_critic,-4(A5)
          MOVE.L  A5,etv_critic
(*$? ADC:
          LEA     OldMiKey(PC),A1                 ; alte Keyb.R. speichern.
          MOVE.L  MidiKeyV,(A1)
          LEA     NKeyMidi(PC),A1                 ; Neue Routine holen
          MOVE.L  A1,MidiKeyV                     ; und setzen
*)
          MOVE    (A7)+,SR
          RTS
*)



pBasePage DS      4             ; ^ Base page
pFont8_16 DS      4             ; ^ Font
pFont8_8  DS      4             ; ^ Font
;pFont6_6  DS      4             ; ^ Font

FontMode  DC.W    0             ; 0:Normaler Font, 1: 6*6-Font
ScrnMode  DC.W    0             ; 0:Monitor-Screen, 1:Normale Screen anzeigen

bMonScreen
          DS      4             ; Pointer auf Monitorscreen Buffer
bMonScreenEnd
          DS      4             ; Pointer auf Ende Monitorscreen Buffer
bMonScreenTop
          DS      4             ; physikalisches Ende Ringpuffer
bMonScreenBase
          DS      4             ; physikalischer Start Ringpuffer
bMonScreenStop
          DS      4             ; Topmargin des Ringpufers
bMonScreenUsed
          DS      4             ; Buttonmargin des Ringpuffers
bMonScreenSize
          DS      4             ; Grîûe des sichtbaren bMonScreens
bMonScreenSpace
          DS      4             ; Grîûe des gesamten bMonScreens
(* STE Register *)

Video_Base_Adress_Offset  DS  2 ; $FF8265
Video_Line_Adress_Offset  DS  2 ; $FF820F

(* Editierzeilen Variablen *)

HistoryStart    DS  4           ; ^ History Puffer Start
HistoryEnde     DS  4           ; ^ History Puffer Ende
HistoryAktuell  DS  4           ; ^ History Aktuelle Zeile zum EinfÅgen
HistorySuchen   DS  4           ; ^ History Suchzeile
HistoryFill     DS  4           ; ^ Pointer

flushCache:
   MOVEM.L    D0/D1/A0,-(A7)
   MOVE.B     MacCPUFlag,D0
   BEQ.S      noFlush
   CMPI.B     #$02,D0
   BEQ.S      fl20
   CMPI.B     #$03,D0
   BNE.S      chk40
fl20:
   MOVEC      CACR,D0
   ORI.L      #$00000808,D0
   MOVEC      D0,CACR
   BRA.S      noFlush
chk40:
   CMPI.B     #$04,D0
   BNE.S      noFlush
   NOP
   DC.W       $F4F8     ; CPUSHA     DC/IC
noFlush:
   MOVEM.L    (A7)+,D0/D1/A0
   RTS


TMonEnter:
          ORI     #$700,SR
          TST.B   MonActive(A4)
          BNE     TMonEnt2
          ST      MonActive(A4)
(*$? MAC:
          BSR.W   mode_mac
          ;dc.w $a9ff
          BSET    #7,MacNMIFlag
          moveq   #1,d0         ; DebuggerEnter
          dc.w    $A08D         ; _DebugUtil
          bsr     flushCache
          BSR.W   mode_atari
*)
TMonEnt2: RTS
TMonLeave:
          SF      MonActive(A4)
(*$? MAC:
          BSR.W   mode_mac
          moveq   #2,d0         ; DebuggerExit
          dc.w    $A08D         ; _DebugUtil
          CLR.B   MacNMIFlag
          ;dc.w $a9ff
          BSR.W   mode_atari
*)
          RTS

(*$? MAC:
!SetMon   ; D7 muû erhalten bleiben
          ; Register A1 nicht veraendern !
          ORI     #$700,SR
          LEA     EyCritic(PC),A5
          MOVE.L  etv_critic,-4(A5)
          MOVE.L  A5,etv_critic
*)
SetMonVec LEA     MONBE(PC),A5
          CMPA.L  BUSERRV,A5
          BEQ     notagain
          MOVE.L  BUSERRV,RgBEV(A4)   ; RETTE BUS-ERROR-VECTOR
          MOVE.L  ADRERRV,RGAEV(A4)   ; RETTE ADRESS-ERROR-VECTOR
          MOVE.L  COPPROV,RgCEV(A4)   ; RETTE COPROCESSOR-ERROR-VECTOR
          MOVE.L  IRQ7V,oldNMI(A4)    ; RETTE NMI
          MOVE.L  ILLIRQV,oldSpur(A4) ; RETTE SPUROIUS INTERRUPT
          TST.W   is20(A4)
          BNE     is20_1
          CLR.B   RgBEV(A4)
          CLR.B   RgAEV(A4)
is20_1    LEA     MONBE(PC),A5
          ST      inTMonBUSerr(A4)
          MOVE.L  A5,BUSERRV          ; BUS-ERROR VECTOR AUF MON-ERROR-AUSGABE
          LEA     MONAE(PC),A5
          MOVE.L  A5,ADRERRV          ; ADR-ERROR VECTOR AUF MON-ERROR-AUSGABE
          LEA     MONCE(PC),A5
          MOVE.L  A5,COPPROV
          LEA     MONIRQ7(PC),A5
          MOVE.L  A5,IRQ7V
          LEA     MONILLIRQ(PC),A5
          MOVE.L  A5,ILLIRQV
notagain: RTS


!ResetMon ORI     #$0700,SR
          SF      MonActive(A4)
(*$? ADC:
          MOVE.L  OldMiKey(PC),MidiKeyV           ; auf alte Keyb.R. umschal.
*)
          LEA     EyCritic(PC),A0
          MOVE.L  -4(A0),etv_critic

RstMonVec MOVE.L  RgBEV(A4),BUSERRV   ; HOLE BUS-ERROR-VECTOR ZURöCK
          SF      inTMonBUSerr(A4)
          MOVE.L  RgAEV(A4),ADRERRV   ; HOLE ADRESS-ERROR-VECTOR ZURöCK
          MOVE.L  RgCEV(A4),COPPROV
          MOVE.L  oldNMI(A4),IRQ7V
          MOVE.L  oldSpur(A4),ILLIRQV
          RTS


!CAPS     CMPI.B  #'z',D0
          BHI     NOTKL
          CMPI.B  #'a',D0
          BCS     NOTKL
          SUBI.B  #$20,D0
!NOTKL    RTS

!GETNGRKL ADDQ.L  #1,A6
!GETLGRKL BCLR    #14,D7
          MOVE.B  (A6),D0
          BSR     CAPS
          CMPI.B  #CR,D0
          BEQ.S   GETGKRE
          CMPI.B  #COMMENT,D0
          BNE.S   GETGKRET
          BSET    #14,D7
!GETGKRE  BSET    #15,D7
!GETGKRET TST.W   D7
          RTS

!GETNGK   ADDQ.L  #1,A6
!GETLGK   BCLR    #14,D7
          MOVE.B  (A6),D0
          CMPI.B  #CR,D0
          BEQ.S   GETGKE
          CMPI.B  #COMMENT,D0
          BNE.S   GETGKET
          BSET    #14,D7
!GETGKE   BSET    #15,D7
!GETGKET  TST.W   D7
          RTS

!TSTHZIFF CMPI.B  #'0',D0
          BCS.S   TSTHZER
          CMPI.B  #'9',D0
          BLS.S   TSTHZOK
          CMPI.B  #'A',D0
          BCS.S   TSTHZER
          CMPI.B  #'F',D0
          BHI.S   TSTHZER
          SUBI.B  #7,D0
!TSTHZOK  SUBI.B  #'0',D0
          ORI     #ZERO,CCR
          RTS
!TSTHZER  ANDI    #NEGZERO,CCR
          RTS

!TSTDZIFF CMPI.B  #'0',D0
          BCS.S   TSTHZER
          CMPI.B  #'9',D0
          BHI.S   TSTHZER
          BRA.S   TSTHZOK

!TSTRZIFF CMPI.B  #9,D0
          BLS.S   TSTRZIFFOK
          BSR.S   TSTDZIFF
          BEQ.S   TSTRZIFFOK
          CMPI.B  #'-',D0
          BEQ.S   TSTRZOK1
          CMPI.B  #'+',D0
          BEQ.S   TSTRZOK1
          CMPI.B  #'.',D0
          BEQ.S   TSTRZOK
          CMPI.B  #':',D0
          BEQ.S   TSTRZOK
          CMPI.B  #CR,D0
          BEQ.S   TSTRZOK
          CMPI.B  #',',D0
          BEQ.S   TSTRZOK
          CMPI.B  #'E',D0
          BNE.S   TSTHZER
          MOVE.W  #0,CCR
          ORI     #OVERFLOW,CCR
          RTS
!TSTRZOK1 MOVE.W  #0,CCR
          ORI     #MINUS,CCR
          RTS
!TSTRZOK  MOVE.W  #0,CCR
          ORI     #CARRY,CCR
!TSTRZE   RTS
!TSTRZIFFOK
          MOVE.W  #0,CCR
          ORI     #ZERO,CCR
          RTS

!TSTADR   CMPI.B  #OFFSCHAR,D0
          BEQ.S   TSTADRE
          CMPI.B  #'S',D0
          BEQ.S   TSTADRE
          CMPI.B  #'N',D0
          BEQ.S   TSTADRE
          CMPI.B  #'L',D0
          BEQ.S   TSTADRE
          CMPI.B  #'&',D0
          BEQ.S   TSTADRE
          CMPI.B  #'#',D0
          BEQ.S   TSTADRE
          CMPI.B  #'R',D0
          BEQ.S   TSTADRE
          CMPI.B  #'P',D0
          BEQ.S   TSTADRE
          CMPI.B  #'(',D0
          BEQ.S   TSTADRE
          CMPI.B  #COMMENT,D0
          BEQ.S   TSTADRE
          BSR.L   TSTHZIFF
          BNE.S   TSTADRE
          BSR.L   GETLGRKL
          ORI     #ZERO,CCR
!TSTADRE  RTS

!GETREAL  MOVEM.L D1-D4/A0/A2/A3,-(SP)
          TST     isFPU(A4)        ; keine FPU? Dann gibts auch keine
          BEQ.L   GETREALERR       ; Real-Zahlen!
          LEA     REALREAL(A4),A3
          CLR.L   (A3)
          CLR.L   4(A3)
          CLR.L   8(A3)            ; mit der Zahl +0.0E+0 vorfÅllen!
!GETREAL1 BSR.L   SKIPSPCN         ; fÅhrende Spaces raus
          BMI.L   GETREALERR       ; schon Zeilenende erreicht : Fehler!
          CLR.L   D1               ; hierin setzen wir die Zahl zusammen!
          CLR.L   D2               ; ZÑhler fÅr das Komma
          CLR.L   D4               ; Bitmerker: Bit0 = 1: Komma gefunden
                                   ;               1 = 0: auf fÅhrende Nullen untersuchen
                                   ;               2 = 0: zu schreibendes Byte (D1) halb
                                   ;                      besetzt
          MOVEQ   #3,D3            ; unser Zeiger in BCD Zahl
          BSR     TSTRZIFF         ; auf Vorzeichen und Exp. abtesten
          BPL.S   GETREAL3         ; kein Vorzeichen vorhanden!
          CMPI.B  #'-',D0
          BNE.S   GETREAL2
          BSET    #7,0(A3)         ; Vorzeichen Mantisse
!GETREAL2 BSR     GETNGRKL
          BMI.L   GETREALERR       ; Zeilenende : Fehler
          CMPI.B  #SPC,D0
          BEQ.L   GETREALERR
          BSR     TSTRZIFF
          BMI.L   GETREALERR       ; 2. Vorzeichen? => Fehler
!GETREAL3 BEQ.L   GETREAL4         ; eine Zahl
          LEA     SNANMsg(PC),A0   ; ab hier auf NAN,SNAN oder INFINITY testen
          BSR     GETREALCMP       ; hier braucht der Keyboardpufferzeiger (A6)
          BEQ     GETREALSNAN      ; nicht gesichert zu werden, da die drei zu
          LEA     NSNANMsg(PC),A0  ; untersuchenden Zeichenketten sich im ersten
          BSR     GETREALCMP       ; Buchstaben unterscheiden!
          BEQ     GETREALNAN
          LEA     InfinityMsg(PC),A0
          BSR     GETREALCMP
          BNE.L   GETREALERR
          MOVE.W  0(A3),D0
          ORI.W   #$7FFF,D0
          MOVE.W  D0,0(A3)
          CLR.L   8(A3)
          CLR.L   4(A3)
          CLR.W   2(A3)
          BRA.L   GETREALEND
!GETREALSNAN
          MOVEQ   #0,D0
          BRA.S   GETREALNAN1
!GETREALNAN
          MOVEQ   #-1,D0
!GETREALNAN1
          MOVEQ   #-1,D1
          MOVE.L  D1,8(A3)
          CLR.W   D1
          BCLR    #31,D1
          MOVE.L  D1,0(A3)
          MOVE.L  D0,4(A3)
          BRA.L   GETREALEND
!GETREALCMP
          BSR     GETLGRKL
          BRA.S   GETREALCMPNEXT
!GETREALCMPLOOP
          BSR     GETNGRKL
!GETREALCMPNEXT
          MOVE.B  (A0)+,D1
          BEQ     GETREALOK
          CMP.B   D0,D1
          BEQ.S   GETREALCMPLOOP
          ANDI    #NEGZERO,CCR
          RTS
!GETREALOK ORI     #ZERO,CCR
          RTS
!GETREAL4 BVC.S   GETREALV1        ; Exponent? nein, Mantisse auswerten
          MOVEQ   #1,D2            ; ja:es ist ja eine Ziffer schon drinnen
          ADDQ.B  #1,1(A3)         ; Mantisse mit 1.0 vorbesetzen
          BRA.L   GETREALE
!GETREALL1 BSR     GETNGRKL         ; nÑchstes Zeichen holen
          BMI.L   GETREALEE        ; Zeilenende : Zum Exponentenende
          CMPI.B  #SPC,D0
          BEQ.L   GETREALEE
!GETREALV1 BSR     TSTRZIFF
          BMI.L   GETREALERR       ; Vorzeichen : Fehler
          BVS.L   GETREALE         ; und schon zum Exponenten
          BCC.S   GETREALV2        ; kein Komma
          BSET    #0,D4            ; Komma gefunden
          BNE.L   GETREALERR       ; schon einmal Komma? => Fehler
          BRA.S   GETREALL1        ; nÑchstes Zeichen
!GETREALV2 BNE.L   GETREALERR       ; kein gÅltiges Zeichen
          BTST    #1,D4            ; Vergleich auf FÅhrende Nullen?
          BNE.S   GETREALV3        ; nein, jetzt nicht mehr
          TST.B   D0               ; isses Null?
          BNE.S   GETREALV3        ; nî!
          SWAP    D2
          BTST    #0,D4            ; schon mal n Komma gefunden?
          BNE     GETREALV21       ; ja
          CLR.W   D2               ; alle Nullen vor dem Komma gleich EXP(-1)
!GETREALV21
          ADDQ.W  #1,D2            ; VorkommastellenzÑhler(=0) erhîhen
          SWAP    D2
          BRA     GETREALL1        ; und neues Zeichen
!GETREALV3 BTST    #0,D4            ; schon mal ein Komma gefunden
          BNE.S   GETREALV31       ; ja
          ADDQ.W  #1,D2            ; KommazÑhler(<>0) eins hoch
!GETREALV31
          BSET    #$1,D4           ; nicht Null markieren
          BTST    #2,D4            ; im unteren Nibble von D1 was drinnen?
          BEQ.S   GETREALV4
          BCLR    #2,D4            ; nein!
          MOVE.B  D0,D1
          ASL.W   #8,D1
          BRA.S   GETREALL1
!GETREALV4 BSET    #2,D4            ; doch!
          MOVE.B  D0,D1
          PACK    D1,D0,#$0000     ; unsere Chars sind ja schon in Zahlen
          CMPI.W  #12,D3
          BCC     GETREALL1
          MOVE.B  D0,0(A3,D3.w)
          ADDQ.W  #1,D3
          BRA     GETREALL1
!GETREALE BTST    #2,D4            ; im unteren Nibble von D1 noch was drinnen?
          BNE.S   GETREALE1
          CMPI.W  #12,D3           ; schon 17 Stellen Mantisse?
          BCC     GETREALE1
          PACK    D1,D0,#$0000
          MOVE.B  D0,0(A3,D3.w)    ; letze Stelle eintragen
!GETREALE1 CLR.L   D1               ; hier wird nun Exponent zusammengesetzt
          BSR     GETNGRKL
          BMI.S   GETREALEE        ; Zeilenende
          CMP.B   #SPC,D0
          BEQ.S   GETREALEE
          BSR     TSTRZIFF
          BVS.L   GETREALERR       ; noch ein Exp.: Fehler
          BPL.S   GETREALE3        ; Vorzeichen? nein
          CMPI.B  #'-',D0          ; negatives Vorzeichen?
          BNE.S   GETREALE2
          BSET    #6,0(A3)         ; Vorzeichen Exponent eintragen
!GETREALE2 BSR     GETNGRKL         ; nÑchstes Zeichen holen
          BMI.L   GETREALERR       ; nix dahinter? dann Fehler
!GETREALE31 BSR     TSTRZIFF
!GETREALE3 BNE.L   GETREALERR       ; nur noch Zahlen erlaubt!
          ANDI.W  #$FF,D0
          ADD.W   D0,D1
          BSR     GETNGRKL
          BMI.S   GETREALE4        ; Zeilenende
          CMPI.B  #SPC,D0
          BEQ.S   GETREALE4
          MULU    #10,D1
          CMP.W   #1000,D1
          BCC.L   GETREALERR2
          BRA.S   GETREALE31
!GETREALEE CLR.L   D1               ; Exponent 0
!GETREALE4 MOVE.L  D2,D0            ; Exponentennormierung mit ZÑhler fÅr
          SWAP    D0
          TST.W   D2
          BEQ.S   GETREALE41
          SUBQ.W  #1,D2
!GETREALE41
          SUB.W   D0,D2
          BEQ     GETRDL           ; es gibt nichts zu tun!
          BTST    #6,0(A3)         ; Umwandlung in vorzeichenbehaftete
          BEQ.S   GETREALE5        ; Integerzahl
          NEG.W   D1
          MOVE.W  D1,D0
!GETREALE5 ADD.W   D2,D1            ; Kommaposition drauf
          BCC     GETRDL           ; hat sich das Vorzeichen jetzt umgedreht?
          BCHG    #6,(A3)          ; das Vorzeichen Bit umdrehen
          BEQ     GETRDL1
;         NEG.W   D1
          BRA.S   GETRDL1
!GETRDL   BTST    #6,(A3)
          BEQ.S   GETRDL1
          NEG.W   D1
!GETRDL1  CLR.L   D2
          ANDI.L  #$7FFF,D1        ; vorzeichenlose Zahl daraus machen
          CMPI.W  #1000,D1
          BCC.L   GETREALERR2
!GETRDL2  DIVU    #1000,D1         ; Integer nach BCD Konvertierung
          ASL.W   #8,D1
          ASL.W   #4,D1
          OR.W    D1,D2
          CLR.W   D1
          SWAP    D1
          DIVU    #100,D1
          ASL.W   #8,D1
          OR.W    D1,D2
          CLR.W   D1
          SWAP    D1
          DIVU    #10,D1
          ASL.W   #4,D1
          OR.W    D1,D2
          SWAP    D1
          OR.W    D1,D2
!GETREALES MOVE.B  0(A3),D0
          ANDI.B  #$F0,D0
          ASL.W   #8,D0
          OR.W    D0,D2
          MOVE.W  D2,0(A3)
!GETREALSET
          FMOVE.P (A3),FP0
          FMOVE.X FP0,(A3)
!GETREALEND
          MOVEM.L (SP)+,D1-D4/A0/A2/A3
          CLR.L   D0
          TST.W   D0
          RTS
!GETREALERR
          CLR.L   D0                ; fÅr Zahl erwartet
          NOT.W   D0
          BRA.S   GETREALERRE
!GETREALERR2
          MOVEQ   #-1,D0            ; fÅr Zahl zu gross
!GETREALERRE
          MOVEM.L (SP)+,D1-D4/A0/A2/A3
          TST.L   D0
          RTS

!GETLONGXL                         ; 96 Bits as Hex Darstellung holen
          CLR.L   D1               ; dabei wird in D1 das niederwertigste,
          CLR.L   D2               ; in D3 da hîchstwertige Langwort abgelegt
          CLR.L   D3
          MOVE.L  D4,-(SP)
          BSR.L   SKIPSPC
!GETLONGXL1
          BSR     TSTHZIFF
          BNE     GETLONGXLE
          MOVEQ   #3,D4
          LSL.B   #4,D0
!GETLONGXLS
          ROXL.B  #1,D0
          ROXL.L  #1,D1
          ROXL.L  #1,D2
          ROXL.L  #1,D3
          DBRA    D4,GETLONGXLS
          BSR     GETNGRKL
          BRA     GETLONGXL1
!GETLONGXLE
          MOVE.L  (SP)+,D4
          RTS

!GETLONGX MOVE.L  #$FFFFFFF,D6
          BRA.W   GetExpr0

!GETLONGO MOVE.L  #$FFFFFFF,D6
          BRA.W   GetExprU

!GETLONG  MOVE.L  #$FFFFFFF,D6
          BRA.W   GETADR2

!GETWORD  MOVE.L  #$FFF,D6
          BRA.W   GETADR2

!GETBYTE  MOVEQ   #$F,D6
          BRA.W   GETADR2

!GETADRG  BSR.S   GETADR0         ; GERADE ADR. HOLEN
          BTST    #12,D7
          BNE.S   GADGC1
          BCLR    #0,D1
!GADGC1   RTS

!GETADR0  BSR.L   SKIPSPC

!GETADR   CMPI.B  #'#',D0
          BEQ.L   GETSYMBOL
          CMPI.B  #'P',D0
          BNE.L   GETADR1
          MOVE.W  ADRsemaphor(A4),-(SP)
          ADDQ.W  #1,ADRsemaphor(A4)   ; +- Operation verbieten
          BSR     GETNGRKL
          BSR.L   SKIPSPC
          MOVE.W  D0,-(SP)
          CMPI.B  #'(',D0
          BNE     GETADRPPARSE
          CLR.W   ADRsemaphor(A4)
          BSR     GETNGRKL
!GETADRPPARSE
          BSR     GETADR0
          TST     is20(A4)      ; beim 68020 32 Bit Adresse, ungerade Adresse mîglich!
          BNE     GETADRPPARSE1
          ANDI.L  #$FFFFFE,D1
!GETADRPPARSE1
          MOVE.L  A0,-(SP)
          MOVEA.L D1,A0
          MOVE.L  (A0),D1
          MOVE.L  (SP)+,A0
          MOVE.W  (SP)+,D0
          MOVE.W  (SP)+,ADRsemaphor(A4)
          CMPI.B  #'(',D0
          BEQ     GETADRPKL
          BSR     GETLGRKL
          BRA.L   GETADRET
!GETADRPKL
          BSR     GETLGRKL
          CMPI.B  #')',D0
          BNE.L   GETADRET
          BSR     GETNGRKL
          BSR.L   SKIPSPC
          CMPI.B  #'+',D0
          BEQ     GETADRPPL
          CMPI.B  #'-',D0
          BNE.L   GETADRET
!GETADRPMI BSR     GETNGRKL
          MOVE.L  D1,-(SP)
          BSR     GETADR0
          SUB.L   D1,(SP)
          MOVE.L  (SP)+,D1
          BRA.L   GETADRET
!GETADRPPL BSR     GETNGRKL
          MOVE.L  D1,-(SP)
          BSR     GETADR0
          ADD.L   (SP)+,D1
          BRA.L   GETADRET

!GETADR1
          CMPI.B  #'(',D0
          BNE     GETADR12
          BSR     GETNGRKL
          BSR     GETADR0
          MOVE.L  D1,-(SP)
          BSR.L   SKIPSPC
          CMPI.B  #')',D0
          BEQ     GETADRNECH
          ADDQ.L  #4,SP
          BRA.L   GETADRET
!GETADRNECH
          BSR     GETNGRKL
          BSR.L   SKIPSPC
          MOVE.W  D0,-(SP)
          MOVE.L  A6,-(SP)
          CMPI.B  #'-',D0
          BEQ     GETADRNEXT
          CMPI.B  #'+',D0
          BEQ     GETADRNEXT
          MOVE.L  (SP)+,A6
          MOVE.W  (SP)+,D0
          MOVE.L  (SP)+,D1
          BRA.L   GETADRET
!GETADRNEXT
          BSR     GETNGRKL
          BSR     GETADR0
          CMPI.W  #'-',4(SP)
          BEQ     GETADRMINUS
          ADD.L   6(SP),D1
          BRA     GETADRREST
!GETADRMINUS
          SUB.L   D1,6(SP)
          MOVE.L  6(SP),D1
!GETADRREST
          LEA     10(SP),SP
          CMPI.B  #')',D0
          BNE.L   GETADRET
          BSR     GETNGRKL
          BRA.L   GETADRET

!GETADR12
          MOVE.L  #$FFFFFFF,D6
          TST     is20(A4)
          BNE     GetExpr0
          MOVE.L  #$FFFFF,D6
!GetExpr0 CLR.L   -(A7)
          MOVE    #1,-(A7)
          BRA.S   GexprC1
!GExprL1  MOVE    D0,-(A7)
          BSR.L   GETNGRKL
!GExprC1  BSR.W   GetExprU
          TST     (A7)+
          BEQ.S   GExprSub
          ADD.L   D1,(A7)
          BRA.S   GExprC0
!GExprSub SUB.L   D1,(A7)
!GExprC0  ; TST.W   ADRsemaphor(A4)
          ; BNE     GetAdRet2
          BSR     GETLGRKL
          CMPI.B  #'+',D0
          BEQ     GexprL1
          CMPI.B  #'-',D0
          BNE.S   GetAdRet2
          MOVEQ   #0,D0
          BRA     GexprL1
!GetAdRet2 MOVE.L  (A7)+,D1
          TST.W   D7
          RTS

!GetExprU CMPI.B  #'(',D0
          BNE     GetExprU1
          BSR     GETADR
          BRA.L   GETADRET
!GetExprU1 CMPI.B  #'P',D0
          BNE     GetExprU2
          BSR     GETADR
          BRA.L   GETADRET
!GetExprU2 CMPI.B  #OFFSCHAR,D0
          BNE.W   GetAdr2
          BSR.L   GETNGRKL
          SF      ValExp(A4)
          BSR     GetAdr3
          ADD.L   AdOffset(A4),D1
          TST.W   D7
          RTS

!GETADR2  ST      ValExp(A4)
!GetAdr3  CLR.L   D1
          CMPI.B  #COMMENT,D0
          BEQ.S   GETADRET
          CMPI.B  #'&',D0
          BEQ.S   GETDADR
          CMPI.B  #'#',D0
          BEQ.L   GETSYMBOL
          CMPI.B  #'R',D0
          BEQ.L   GETRGADR
          CMPI.B  #'S',D0
          BEQ.L   GetStartVar
          CMPI.B  #'N',D0
          BEQ.L   GetNextVar
          CMPI.B  #'L',D0
          BEQ.L   GetLengthVar
          BSR.L   TSTHZIFF
          BEQ.S   GETADL1
          TST.B   ValExp(A4)
          BEQ.S   GETADRET
          BRA     ERR1

!GETADL1  CMP.L   D6,D1
          BHI     ERR2
          LSL.L   #4,D1
          OR.B    D0,D1
          BSR.L   GETNGRKL
          BMI.S   GETADRET
          BSR.L   TSTHZIFF
          BEQ     GETADL1

!GETADRET TST.W   D7
          RTS


!GETDADR  BSR     GETNGRKL        ; NAECHSTES ZEICHEN HOLEN
!GETDEZ   BSR     TSTHZIFF        ; HEX-ZIFFER ?
          BNE     GETADRET        ; NEIN: ENDE
          CMPI.B  #9,D0           ; DEZ.-ZIFFER ?
          BHI.S   GETADRET        ; NEIN: ENDE
          CMP.L   D6,D1           ; ZAHL ZU GROSS ?
          BHI     ERR2            ; JA: ERROR
          EXT.W   D0
          EXT.L   D0              ; D0.L = ZIFFER
                                  ; NEIN: D1 MIT 10 MULTIPLIZIEREN:
          ASL.L   #1,D1           ; D1 MAL 2
          MOVE.L  D1,-(A7)        ; D1 AUF STACK ZWISCHENSPEICHERN
          ASL.L   #2,D1           ; D1 JETZT MAL 8
          ADD.L   (A7)+,D1        ; D1 MAL 2 DAZUADDIEREN
          ADD.L   D0,D1           ; D1 JETZT MAL 10, DEZ.ZIFFER ADDIEREN
          BRA     GETDADR         ; NAECHSTE ZIFFER

!GetSymbol
          MOVEM.L A0-A3/D0,-(SP)
          LEA     DBuffer(A4),A3
!GetSymbolL
          BSR     GETNGK
          TST.W   D7
          BMI     GetSymbolE
          CMPI.B  #SPC,D0
          BEQ     GetSymbolE
;          CMPI.B  #'.',D0
;          BEQ     GetSymbolE
          CMPI.B  #',',D0
          BEQ     GetSymbolE
          CMPI.B  #'+',D0
          BEQ     GetSymbolE
          CMPI.B  #'-',D0
          BEQ     GetSymbolE
          CMPI.B  #')',D0
          BEQ     GetSymbolE
          MOVE.B  D0,(A3)+
          BRA     GetSymbolL
!GetSymbolE
          LEA     DBuffer(A4),A0
          CMPA.L  A0,A3
          BEQ     GStoErr20
          CLR.B   (A3)+
          MOVE.L  GetSymbolValue(A4),D0
          BEQ     GStoErr20
          MOVE.L  D0,A2
;          LEA     DBuffer(A4),A0
          SUBA.L  A1,A1
          MOVEM.L A4-A6/D2-D7,-(SP)
          JSR     (A2)
          MOVEM.L (SP)+,A4-A6/D2-D7
          TST.L   D0
          BNE     GStoErr20
          MOVE.L  (A0),D1
          MOVEM.L (SP)+,A0-A3/D0
          BRA     GETADRET
!GStoErr20
          MOVEM.L (SP)+,A0-A3/D0
          BRA     Err20

!GetRgAdr MOVEM.L D2/A0-A1,-(A7)
          BSR.L   SkipSpcN
          MOVE.W  D7,-(A7)      ; Bit 15 nicht auf Stack !
          BSET    #4,D7
          BSR.L   BerRegNr
(*
          BTST    #2,D7
          BNE     ERR16
          BTST    #3,D7
          BNE     ERR16
*)
          CMPI.B  #TNrSRP,D2
          BEQ     GetRgAdr1
          CMPI.B  #TNrCRP,D2
          BEQ     GetRgAdr1
          CMPI.B  #TNrURP,D2
          BEQ     GetRgAdr2
          CMPI.B  #TNrSFC,D2
          BEQ     ERR16
          CMPI.B  #TNrDFC,D2
          BEQ     ERR16
          CMPI.B  #TNrFPIAR,D2
          BEQ     GetRgAdrF
          CMPI.B  #TNrCACR,D2
          BCC     ERR16
!GetRgAdr2 MOVE.W  (A7)+,D7
          LEA     RegBeg(A4),A0
          LSL     #2,D2
!GetRgAdr0 MOVE.L  0(A0,D2.W),D1
          MOVEM.L (A7)+,D2/A0-A1
          BRA     GETADRET
!GetRgAdr1 MOVE.W  (A7)+,D7
          LEA     RegBeg(A4),A0
          LSL     #2,D2
          MOVE.L  4(A0,D2.W),D1
          TST     is40(A4)
          BNE     GetRgAdr0
          MOVEM.L (A7)+,D2/A0-A1
          BRA     GETADRET
!GetRgAdrF MOVE.L  RgFPIAR(A4),D1
          MOVE.W  (A7)+,D7
          MOVEM.L (A7)+,D2/A0-A1
          BRA     GETADRET

!GetStartVar
          BSR     GETNGRKL
          MOVE.L  LastLSA(A4),D1
          BRA     GETADRET
!GetNextVar
          BSR     GETNGRKL
          MOVE.L  LastLSE(A4),D1
          BRA     GETADRET
!GetLengthVar
          BSR     GETNGRKL
          MOVE.L  LastLSE(A4),D1
          SUB.L   LastLSA(A4),D1
          BRA     GETADRET

!GETAE    BSR.L   SKIPSPC
          BMI.L   GETAEDFT
          BSR.L   TSTADR          ; ANGABE EINER ANF. ADR. ?
          BNE.L   GETADEFT        ; NEIN: DEFAULT-WERT HOLEN
          BSR.L   GETADRG
          MOVEA.L D1,A2
          BSET    #2,D7
          TST.W   D7
          BMI.L   GETAEEQU
!GETEC0   BSR.L   SKIPSPC
          BMI.L   GETAEEQU
          CMPI.B  #'.',D0
          BEQ.S   GETEC1
          CMPI.B  #'Z',D0         ; ANGABE DER ZEILENZAHL ?
          BEQ.S   GETEZ
          CMPI.B  #'L',D0         ; Angabe der Zeilenzahl mit L ?
          BEQ.S   GETEZ
          CMPI.B  #'X',D0         ; ANGABE BYTE-ANZAHL ?
          BNE.S   GETEC2
          BSR.L   SkipSpcN
          BMI.S   GETEDEFT
          BSR.L   TSTADR
          BNE.S   GETEDEFT        ; DEFAULT-ENDADR.,WENN KEINE ZAHL FOLGT
          BSR.L   GETLONGX        ; JA: ANZAHL HOLEN
          ADD.L   A2,D1           ; ANF.-ADR. ADDIEREN
          BCC.S   GETEC4
          MOVEQ   #-1,D1          ; BEI öBERTRAG MAX. WERT NEHMEN
!GETEC4   BTST    #12,D7
          BNE     GetEC5
          BCLR    #0,D1           ; ENDADR. BEGRADIGEN
          BRA.S   GETEC5
!GETEC1   BSR.L   SkipSpcN
          BMI     GETEDEFT
          BSR.L   TSTADR
          BNE.S   GETEDEFT        ; DEFAULT-ENDADR.,WENN KEINE ZAHL FOLGT
!GETEC2   BSR.L   GETADRG
!GETEC5   MOVEA.L D1,A3
          BSET    #3,D7
!GETAERET CMPA.L  A3,A2
          BHI     ERR3            ; ERROR: A2>A3
!GETAERT0 MOVE.L  A2,(A1)
          TST.W   D7              ; TEST AUF CR
          BTST    #2,D7           ; ANF. ADR. ANGEGEBEN ?
          BEQ.S   GETAERT2
          BTST    #3,D7           ; END ADR. ANGEGEBEN ?
!GETAERT2 RTS                     ; N=1:CR FOLGT / Z=0: BEIDE ADR. ANGEGEBEN

!GETADEFT MOVEA.L 4(A1),A2
          BRA.L   GETEC0

!GETAEDFT MOVEA.L (A1),A2         ; LAST*A - ADR. ALS ANF. ADR.

!GETEDEFT MOVEA.L #-1,A3
          BRA.L   GETAERET

!GETAEEQU MOVEA.L A2,A3
          BRA.L   GETAERET

!GETEZ    BSR.L   SkipSpcN
!GETEZ0   BPL.S   GETEZC1
          MOVEQ   #1,D1
          BRA.S   GETEZC2
!GETEZC1  BSR.L   GETLONG
!GETEZC2  MOVE.L  D1,D3
          BSET    #1,D7           ; : ZEILENANZ. GEWAEHLT
          BRA.L   GETAERT0

!SKIPSPC  BSR.L   GETLGRKL
          BMI.S   SKIPEND
!SKIPSPC2 CMPI.B  #SPC,D0
          BNE.S   SKIPEND
!SKIPSPCN BSR.L   GETNGRKL
          BPL.S   SKIPSPC2
!SKIPEND  TST.W   D7
          RTS
!SKIPSPC0N
          BSR.L   GETLGRKL
          BMI     SKIPEND
          CMPI.B  #SPC,1(A6)
          BNE     SKIPEND
          BSR.L   GETNGRKL
          BMI     SKIPEND
!SKIPSPC0 MOVE.L  A6,-(SP)
          BSR     SKIPSPC
          CMPA.L  (SP)+,A6
          BEQ     SKIPEND
          SUBQ.L  #1,A6
          BSR     GETLGRKL
          BRA     SKIPEND

!TSTNCR   BSR.L   GETNGRKL
          BPL     ERR4
          RTS

; MEMORY HEX-DUMP Byteweise

!CIU      MOVE.B  (A2)+,D0
          BSET    #13,D7          ; Controlchars als druckbare Zeichen darst.
          BSR     Prt
          DBF     D5,CIU
          RTS

!ComdM    CMPI.B  #'+',D0
          BNE     ComdM1
          CLR.W   noUpdate(A4)
          RTS
!ComdM1   CMPI.B  #'-',D0
          BNE     ComdM2
          ST      noUpdate(A4)
          RTS
!ComdM2   CMPI.B  #'B',D0
          BEQ     ComdMB
          CMPI.B  #'W',D0
          BEQ.L   ComdMW
          CMPI.B  #'L',D0
          BEQ.L   ComdML
          BRA.S   ComdMBy
!ComdMB   BSR.L   GETNGRKL
!ComdMBy  LEA     LastMA(A4),A1   ; LETZTE ANF.ADR. ALS DEFAULT-WERT-POINTER
          BSET    #12,D7          ; Ungerade Adr. erlaubt
          BSR.L   GETAE           ; ANF.-/END- ADR. NACH A2/A3 HOLEN
!CMC0     BPL     ERR4
!DUMPNXLN MOVEQ   #HDUMPANZ-1,D6  ; ANZ. bytes -1 PRO ZEILE
          BSR     PrtPRMPT
          MOVEQ   #':',D0
          BSR     Prt
          MOVE.L  A2,D0           ; PRINT ADRESSE
          BSR     PrtADR
          TST.W   is20(A4)
          BNE.S   DUMPLNL01
          BSR     PrtSPC
!DUMPLNL01
          CLR.W   D5
          LEA     DUMPBUF(A4),A1
!DUMPLNL1 BSR     PrtSPC
          MOVE.B  (A2)+,D0
          MOVE.B  D0,(A1)+
          BSR     PrtByte
          MOVE    A2,D0  ;MOVE.B D5,D0
          ANDI.B  #11%,D0
          BNE     CmdMC1
          BSR     PrtSPC
!CmdMc1   ADDQ.W  #1,D5
          BTST    #1,D7
          BNE.S   CMC1
          CMPA.L  A3,A2
          BCC.S   CMEND
!CMC1     DBRA    D6,DUMPLNL1

          BSR     ASCOUT

          BSR.L   TSTKEY
          BNE     CMEND1
          ; Warteschleife f. 68020
          BSR     DelayIf20
          BTST    #1,D7
          BEQ     DUMPNXLN
          SUBQ.L  #1,D3
          BNE     DUMPNXLN
          BRA     CMEND1

!CMEND    BSR     ASCOUT
!CMEND1   MOVE.L  A2,LastME(A4)
          BRA     PrtCRLF
;
!ASCOUT   TST.B   noUpdate(A4)
          BNE     ACIUEND
          CMPI.W  #62,CursorX(A4)
          BCC     ASCOUT2
          BSR     PRTSPC
          BRA     ASCOUT
!ASCOUT2  LEA     DUMPBUF(A4),A1
          MOVEQ   #ASCDUMPX,D1
          BSR     PRTMSPC
          MOVEQ   #COMMENT,D0     ; MOVEQ   #ASCPRMPT,D0
          BSR     PRT
          SUBQ.W  #1,D5
!ACIU     MOVE.B  (A1)+,D0
          BSET    #13,D7          ; Controlchars als druckbare Zeichen darst.
          BSR     Prt
          DBF     D5,ACIU
!ACIUEND  RTS

; MEMORY HEX-DUMP Wordweise

!ComdMW   BSR.L   GETNGRKL
          LEA     LastMA(A4),A1   ; LETZTE ANF.ADR. ALS DEFAULT-WERT-POINTER
          BCLR    #12,D7          ; Ungerade Adr. nicht erlaubt
          BSR.L   GETAE           ; ANF.-/END- ADR. NACH A2/A3 HOLEN
!CMC0W    BPL     ERR4
!DUMPNXLNW MOVEQ   #(HDUMPANZ DIV 2)-1,D6  ; ANZ. bytes -1 PRO ZEILE
          BSR     PrtPRMPT
          MOVEQ   #':',D0
          BSR     Prt
          MOVEQ   #'w',D0
          BSR     Prt
          MOVE.L  A2,D0           ; PRINT ADRESSE
          BSR     PrtADR
          MOVEQ   #3,D1
          TST.W   is20(A4)
          BEQ     DUMPLNL01W
          MOVEQ   #2,D1
!DUMPLNL01W
          BSR     PrtMSPC
          CLR.W   D5
          LEA     DUMPBUF(A4),A1
!DUMPLNL1W
          BSR     PrtSPC
          MOVE.W  (A2)+,D0
          MOVE.W  D0,(A1)+
          BSR     PrtWord
          MOVE    A2,D0  ;MOVE.B D5,D0
          ANDI.B  #11%,D0
          BNE     CmdMC1W
          BSR     PrtSPC
          BSR     PrtSPC
!CmdMc1W  ADDQ.W  #2,D5
          BTST    #1,D7
          BNE.S   CMC1W
          CMPA.L  A3,A2
          BHI.S   CMENDW
!CMC1W    DBRA    D6,DUMPLNL1W

          BSR     ASCOUT

          BSR.L   TSTKEY
          BNE     CMENDW1
          ; Warteschleife f. 68020
          BSR     DelayIf20
          BTST    #1,D7
          BEQ     DUMPNXLNW
          SUBQ.L  #1,D3
          BNE     DUMPNXLNW
          BRA     CMENDW1

!CMENDW   BSR     ASCOUT
!CMENDW1  MOVE.L  A2,LastME(A4)
          BRA     PrtCRLF
;          RTS

; MEMORY HEX-DUMP LongWordweise

!ComdML   BSR.L   GETNGRKL
          LEA     LastMA(A4),A1   ; LETZTE ANF.ADR. ALS DEFAULT-WERT-POINTER
          BCLR    #12,D7          ; Ungerade Adr. nicht erlaubt
          BSR.L   GETAE           ; ANF.-/END- ADR. NACH A2/A3 HOLEN
!CMC0L    BPL     ERR4
!DUMPNXLNL MOVEQ   #(HDUMPANZ DIV 4)-1,D6  ; ANZ. bytes -1 PRO ZEILE
          BSR     PrtPRMPT
          MOVEQ   #':',D0
          BSR     Prt
          MOVEQ   #'l',D0
          BSR     Prt
          MOVE.L  A2,D0           ; PRINT ADRESSE
          BSR     PrtADR
          MOVEQ   #2,D1
          TST.W   is20(A4)
          BEQ     DUMPLNL01L
          MOVEQ   #1,D1
DUMPLNL01L
          BSR     PrtMSPC
          CLR.W   D5
          LEA     DUMPBUF(A4),A1
!DUMPLNL1L
          BSR     PrtSPC
          BSR     PrtSPC
          MOVE.L  (A2)+,D0
          MOVE.L  D0,(A1)+
          BSR     PrtLONG
          MOVE    A2,D0  ;MOVE.B D5,D0
;          ANDI.B  #111%,D0
;          BNE     CmdMC1L
          BSR     PrtSPC
          BSR     PrtSPC
CmdMc1L   ADDQ.W  #4,D5
          BTST    #1,D7
          BNE.S   CMC1L
          CMPA.L  A3,A2
          BHI.S   CMENDL
!CMC1L    DBRA    D6,DUMPLNL1L

          BSR     ASCOUT

          BSR.L   TSTKEY
          BNE     CMENDL1
          ; Warteschleife f. 68020
          BSR     DelayIf20
          BTST    #1,D7
          BEQ     DUMPNXLNL
          SUBQ.L  #1,D3
          BNE     DUMPNXLNL
          BRA     CMENDL1

!CMENDL   BSR     ASCOUT
!CMENDL1  MOVE.L  A2,LastME(A4)
          BRA     PrtCRLF
;          RTS

; SPEICHERBEREICHE VERSCHIEBEN / VERGLEICHEN

!GET3ADR  LEA     Hilf1L(A4),A1
          BSET    #12,D7          ; Ungerade Adr. erlaubt
          BSR.L   GETAE
          BEQ     ERR1
          BSR.L   GETADRG
          BPL     ERR4
          RTS                     ; ADR. IN : A2 / A3 / D1

!ComdC    BCLR    #11,D7
          BSR.L   GET3ADR         ;COPY
          MOVEA.L D1,A5

!CTRF     CMPA.L  A2,A5           ; TRANSFER-UPRO: (A2) - (A3) => (A5)
          BLS     CTRFUP

          SUBA.L  A2,A5           ; VON OBEN NACH UNTEN VERSCHIEBEN
          ADDA.L  A3,A5           ; ZIEL-END-ADR. BESTIMMEN
          ADDQ.L  #1,A5
          ADDQ.L  #1,A3
!CTRFDWN  MOVE.B  -(A3),-(A5)
          CMPA.L  A2,A3
;          BCC     CTRFDWN
          BHI     CTRFDWN
          RTS

!CTRFUP   MOVE.B  (A2)+,(A5)+     ; VON UNTEN NACH OBEN VERSCHIEBEN
          CMPA.L  A3,A2
          BCS     CTRFUP
          RTS

!ComdV    BCLR    #11,D7
          CMPI.B  #CR,1(A6)
          BNE     CVC0
          CMPI.B  #'I',D0
          BNE     CVC0

; VI - Vector restore

!ComdVI   BSR     RstMonVec
          MOVEQ   #1,D0              ; InitVec: énderungen anzeigen
          MOVEQ   #0,D1              ; InitVec: von TRAPs nur Nr 6 setzen
          BSR.L   InitVec
          BRA     SetMonVec

; V - Verify

!CVC0     BSR.L   GET3ADR
          MOVEA.L D1,A5
          BSR     PrtCRLF
          BSR     PrtSPC
          MOVEQ   #7,D5

!CCMP     CMPM.B  (A2)+,(A5)+
          BNE.S   CCMPC1
!CCMPC2   CMPA.L  A3,A2
          BCS     CCMP
          BSR     PrtCRLF
          RTS

!CCMPC1   MOVEA.L A2,A1
          SUBQ.L  #1,A1
          BSR.L   CCMPU1
          MOVEQ   #'-',D0
          BSR     Prt
          MOVEA.L A5,A1
          SUBQ.L  #1,A1
          BSR.L   CCMPU1
          CMPI.B  #1,D5
          BEQ     CCMPC3
          MOVEQ   #4,D1
          BSR     PrtMSPC
!CCMPC3   BSR.L   TSTKEY
          BEQ     CCMPC2
          BSR     PrtCRLF
          RTS

!CCMPU1   SUBQ.B  #1,D5
          BNE     CCMPUC
          BSR     PrtCRLF
          BSR     PrtSPC
          MOVEQ   #6,D5
!CCMPUC   MOVE.L  A1,D0
          BSR     PrtADR
          MOVEQ   #':',D0
          BSR     Prt
          MOVE.B  (A1),D0
          BRA     PrtByte

; BREAKPOINT SETZEN / ANZEIGEN

!USERBRKP BSR.L   GETNGRKL
          BMI.S   SHOWUSR
          BSR.L   GETADRG
          BPL     ERR4
          MOVE.L  D1,UsrBP(A4)

!SHOWUSR  BSR     PRTPRMPT
          MOVEQ   #'B',D0
          BSR     PRT
          MOVEQ   #'U',D0
          BSR     PRT
          BSR     PRTSPC
          MOVE.L  UsrBP(A4),D0
          BSR     PRTADR
          BRA     PRTCRLF

!CBPCLR   BSR.L   TSTNCR
!ClrBPs   LEA     BP(A4),A1
          MOVEQ   #BPanz+BPanz-1,D0
!CBPCLRL  CLR.L   (A1)+
          DBF     D0,CBPCLRL
          BCLR    #11,D7
          SF      BPset(A4)
          RTS

!ComdB    CMPI.B  #':',D0
          BNE     ComdB5
          BSR     GETNGRKL
          CMPI.B  #'-',D0
          BEQ     ComdB1
          CMPI.B  #'+',D0
          BNE     ComdB2
          ST      BusPR(A4)
!ComdB2   RTS
!ComdB1   SF      BusPR(A4)
          RTS
!ComdB5   LEA     BP(A4),A1

          BSR.L   SKIPSPC
          BMI.L   SHOWBP0

          CMPI.B  #'U',D0
          BEQ     USERBRKP

          CMPI.B  #'-',D0
          BEQ     CBPCLR

          BSR.L   TSTHZIFF
          BNE     ERR1
          CMPI.B  #BPanz-1,D0
          BHI     ERR2
          MOVE.B  D0,D5
          EXT.W   D5
          MOVE    D5,D4
          ASL.B   #2,D4
          BSR.L   GETNGRKL
          BMI     SHOWBRKP
          CMPI.B  #SPC,D0
          BNE     Err6
          BSR     SkipSpcN
          MOVEQ   #1,D0
          MOVEA.W D0,A2
          MOVEA.W D0,A3
          BCLR    #12,D7          ; nur gerade Adr.
          BSR.L   GETADRG
          MOVE.L  D1,0(A1,D4.W)
          BNE     CBPC1
          MOVEA.W D1,A2
          MOVEA.W D1,A3
          BRA     CBPE1
!CBPC1    TST.W   D7
          BMI.S   CBPE1
          BSR.L   SKIPSPC
          BSR.L   GETWORD
          MOVEA.W D1,A2
          BPL.S   CBPC2
          MOVEA.W D1,A3
          BRA.S   CBPE1
!CBPC2    BSR.L   SKIPSPC
          BSR.L   GETWORD
          MOVEA.W D1,A3
!CBPE1    MOVE.W  A2,BPanz+BPanz+BPanz+BPanz(A1,D4.W)     ; BPC
          MOVE.W  A3,BPanz+BPanz+BPanz+BPanz+2(A1,D4.W)   ; BPCA

          ; Testen, ob irgendein BP gesetzt ist
          LEA     BP(A4),A0
          MOVEQ   #BPanz-1,D0
!CBPCLRL2 TST.L   (A0)+
          DBNE    D0,CBPCLRL2
          SNE     BPset(A4)

!SHOWBRKP MOVE.W  D5,-(SP)
          BSR     PrtPRMPT
          BRA.S   SHOWBRKP2
!SHOWBRKP1 MOVE.W  D5,-(SP)
          MOVEQ   #PROMPT,D0
          BSR     PRT
!SHOWBRKP2
          MOVEQ   #'B',D0
          BSR     Prt
          MOVE.W  (SP),D0
;          MOVE.B  D5,D0
          BSR     PrtNIBL
          BSR     PrtSPC
          MOVE.W  (SP),D4
;          MOVE.W  D5,D4
          LSL.W   #2,D4
          LEA     BP(A4),A1
          MOVE.L  0(A1,D4.W),D0
          MOVE.L  D4,-(SP)
          BSR     PrtADR
          BSR     PrtSPC
          MOVE.L  (SP),D4
          LEA     BP(A4),A1
          MOVE.W  BPanz+BPanz+BPanz+BPanz(A1,D4.W),D0    ;BPC
          BSR     PrtWORD
          BSR     PrtSPC
          MOVE.L  (SP)+,D4
          LEA     BP(A4),A1
          MOVE.W  BPanz+BPanz+BPanz+BPanz+2(A1,D4.W),D0  ;BPCA
          BSR     PrtWORD
          MOVE.W  (SP)+,D5
          BRA     PrtCRLF

!SHOWBP0  CLR.L   D5
          TST     BPset(A4)
          BEQ     noBPset
          BSR     PRTCRLF
!SHOWBPL  MOVE.W  D5,D4
          LSL.W   #2,D4
          TST.L   0(A1,D4.W)
          BEQ     BPnotSet
          BSR.S   SHOWBRKP1
!BPnotSet ADDQ.B  #1,D5
          CMPI.B  #BPanz,D5
          BCS.S   SHOWBPL
          RTS
!noBPSet  LEA     noBPsMsg(PC),A1
          BCLR    #11,D7
          BSR     PrtStr
          BRA     PrtCRLF

!ComdO    BMI.S   SHOWOFFS
          BSR.L   GETADR0
          BPL     ERR4
          MOVE.L  D1,AdOffset(A4)

!SHOWOFFS BSR     PrtPrmpt
          MOVEQ   #'O',D0
          BSR     Prt
          BSR     PrtSPC
          MOVE.L  AdOffset(A4),D0
          BSR     PrtADR
          BRA     PrtCRLF


; Alle cmds anzeigen

!PrComds  LEA     CmdCmt(PC),A1
          BSR     PrtCRLF
!PrCmdL1  MOVEQ   #23,D2
!PrCmdL0  BSR     PrtStr
          BSR     TstKey
          BNE     PrCmdE0
          TST.B   (A1)
          BEQ     PrCmdE0
          BSR     PrtCRLF
          DBRA    D2,PrCmdL0
          MOVE.L  A1,-(A7)
          MOVE.W  PrHandle(A4),-(A7)
          CLR.W   PrHandle(A4)
          LEA     PressKeyMsg(PC),A1
          BSR     PrtStr
          BSR     WaitKey
          MOVE    D0,D1
          BSR     PrtCRLF
          MOVE.W  (A7)+,PrHandle(A4)
          MOVE.L  (A7)+,A1
          CMPI.B  #' ',D1
          BEQ     PrCmdL1
!PrCmdE0  BRA     PrtCRLF

; Rechnen

!ComdFRAG BMI     PRCOMDS
          CMPI.B  #'K',D0
          BEQ     PRTKSTATE
          CMPI.B  #'M',D0
          BEQ.L   PRTTMONRPADR
(*
          CMPI.B  #'F',D0
          BEQ     PRTSTFRAME
*)
          BCLR    #11,D7
          BSR     SKIPSPC
          BSR     GETLONGO
          BMI     ERR15
          MOVE.L  D1,-(A7)
          BSR     SKIPSPC
          MOVE.B  D0,D2
          BSR     GETNGRKL
          BMI     ERR1
          BSR     SKIPSPC
          BSR     GETLONGO
          BPL     ERR4
          BSR     PRTSPC
          MOVEQ   #'=',D0
          BSR     PRT
          BSR     PRTSPC
          MOVE.L  (A7)+,D0
          CMPI.B  #'+',D2
          BEQ     CFPLUS
          CMPI.B  #'-',D2
          BEQ     CFMINUS
          CMPI.B  #'*',D2
          BEQ     CFMULT
          CMPI.B  #'/',D2
          BEQ     CFDIV
          CMPI.B  #'E',D2
          BEQ     CFEOR
          CMPI.B  #'O',D2
          BEQ     CFOR
          CMPI.B  #'A',D2
          BNE     ERR14
!CFAND    AND.L   D1,D0
          BRA     PrtLONG

!CFMINUS  SUB.L   D1,D0
          BRA.S   CFPLMI

!CFPLUS   ADD.L   D1,D0
!CFPLMI   MOVE    SR,-(A7)
          BSR     PrtLONG
          LEA     CFLMSG(PC),A1
          BSR     PrtSTR
          MOVE    (A7)+,D0
          ANDI.B  #1,D0
          BSR     PrtNIBL
          BRA     PrtCRLF

!CFMULT   MULU    D1,D0
          BSR     PrtLONG
          BRA     PrtCRLF

!CFDIV    TST.W   D1
          BEQ     ERR14           ; ERROR: DIV DURCH NULL
          DIVU    D1,D0
          MOVE.L  D0,-(A7)
          BSR     PrtWORD
          LEA     RMDMSG(PC),A1
          BSR     PrtSTR
          MOVE.L  (A7)+,D0
          SWAP    D0
          BSR     PrtWORD
          BRA     PrtCRLF

!CFEOR    EOR.L   D1,D0
          BSR     PrtLONG
          BRA     PrtCRLF

!CFOR     OR.L    D1,D0
          BSR     PrtLONG
          BRA     PrtCRLF


!ComdR    BMI.L   CRC5
          CMPI.B  #'-',D0
          BNE.L   CRC1

          ; Entry-Msg und Modulposition ausgeben

          BSR.L   TSTNCR

          BSR     PrtMSG
          BRA     PrtCRLF

!CRC4     BCLR    #11,D7
          CMPI.B  #'S',D0
          BNE     CRC6

          ; 'RS' - Reg save
          MOVEQ   #(RegSaveSize DIV 4)-1,D0
          LEA     RegBeg(A4),A0
          LEA     Regsave(A4),A1
!CRL4     MOVE.L  (A0)+,(A1)+
          DBRA    D0,CRL4
          RTS

!CRC6     CMPI.B  #'R',D0
(*          BEQ     CRCRR
            CMPI.B  #'?',D0 *)
          BNE     Err0
(*          BSR     PrtCRLF
            LEA     RegBeg(A4),A0
            LEA     StFrame(A4),A1
            SUBA.L  A0,A1
            MOVE.L  A1,D0
            BSR     PrtLONG
            BSR     PrtCRLF
            BRA     PrtCRLF

  !CRCRR *)
          ; 'RR' - Reg restore
          MOVE.L  RgBEV(A4),-(SP)
          MOVE.L  RgAEV(A4),-(SP)
          MOVEQ   #(RegSaveSize DIV 4)-1,D0
          LEA     RegBeg(A4),A1
          LEA     Regsave(A4),A0
!CRL5     MOVE.L  (A0)+,(A1)+
          DBRA    D0,CRL5
          MOVE.L  (SP)+,RgBEV(A4)
          MOVE.L  (SP)+,RgAEV(A4)
          RTS

!CRLW     ST      longREG(A4)
          RTS
!CRSW     SF      longREG(A4)
          RTS

!CRC1     CMPI.B  #'+',D0
          BEQ.S   CRC2
          CMPI.B  #':',D0
          BEQ.L   CRAW
          CMPI.B  #'W',D0
          BEQ     CRLW
          CMPI.B  #'D',D0
          BEQ     CRSW
          CMPI.B  #CR,1(A6)       ; folgen noch Zeichen ?
          BEQ     CRC4            ; Nein
          BSET    #4,D7           ; : Auf Reg.-Zuweisung in COU testen
          CLR.L   D3
          CLR.L   D4
          BSR.L   COU             ; Registerzuweisungen auswerten
          MOVE.L  D4,D5           ; Eingegebene Register wieder ausgeben
          MOVE.L  D3,D4
          BRA.S   CRC3
!CRC2     MOVEQ   #-1,D4          ; ALLE REG. ANZEIGEN
          MOVEQ   #-1,D5          ; RegisterWahl2!
          BTST    #7,RegWahl(A4)
          BNE.S   CRC3
          LSR.L   #1,D4           ; Clr Bit 31 : SR nicht als Flags anzeigen
          BRA.S   CRC3
!CRC5     BSR.L   TSTNCR          ; NUR REG.,DIE MIT 'O'-FUNKTION BESTIMMT
          MOVE.L  RegWahl(A4),D4
          MOVE.L  RegWahl2(A4),D5
!CRC3     BSET    #11,D7          ; : KEIN LF BEIM ERSTEN CR AUSGEBEN

; Gibt mehrere Register aus. Auswahl in D4/D5. Wenn nur Namen ausg.(#0 set in D7)
;  dann muû von Aufrufer CR und Prompt ausgegeben werden.

!CRU      TST.L   D4
          BPL     CRUC9
          BSET    #2,D7           ; : SR als Flags ausgeben
!CRUC9    CLR.W   D3              ; ZÑhler f. Registernummer (TNr..)
          BSET    #9,D7           ; : Anfang der Zeile
          BTST    #0,D7           ; Inhalte ausgeben ?
          BNE.S   CRUC1           ; Nein

          ;Test, ob D0-A7 angezeigt werden
          MOVEM.L D4/D5,-(A7)     ; REG.AUSWAHL RETTEN
          MOVE.L  #$1FFFE,D0      ; MASKE F. ALLE 16 D-/A- REG.
          AND.L   D0,D4
          CMP.L   D0,D4           ; ALLE 16 REG. ANZEIGEN ?
          BNE.S   CRUC0           ; NEIN

(*
          ; 0 .. 7 ausgeben
          BSR     PrtCRLF
          CLR.W   D3
!CRUL3    MOVEQ   #8,D1
          BSR     PrtMSPC
          MOVE.B  D3,D0
          BSR     PrtNIBL
          ADDQ.W  #1,D3
          CMPI.B  #8,D3
          BCS     CRUL3
*)
          MOVEQ   #TNRD0,D3
          BSET    #10,D7

!CRUC0    MOVEM.L (A7)+,D4/D5     ; REG.AUSWAHL WIEDER V. STACK

!CRUC1    ; Ausgabeschleife:

!CRL0     MOVE.W  D3,D2
          CMPI.B  #TNrLast20,D3
          BLS     CRL01
          MOVE.W  D3,D0
          SUBI.W  #TNrLast20,D0
          BTST    D0,D5           ; soll Reg.(D3) (68030 oder FPU-Reg)
          BEQ.L   CRUE
          BRA.S   CRL02
!CRL01    BTST    D3,D4           ; soll Reg.(D3) ausgegeben werden ?
          BEQ.L   CRUE

!CRL02    BTST    #0,D7           ; Nur Namen ausgeben ?
;          BNE.L   CRUC2
          BEQ.S   CRL03
          MOVEQ   #ZEILLEN-4,D0
          BRA.L   CRUC7

!CRL03    BCLR    #9,D7           ; Nein : Anfang der Zeile ?
          BNE.L   CRUC6           ; Ja

          ; Bestimme vorrausichtliche LÑnge der folg. Ausgabe
          BTST    #2,D7           ; Flags ausgeben?
          BEQ.L   CRUC70          ; nein!
          CMPI.B  #TNrSR,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrCACR,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrPSR,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrTC,D3
          BEQ.L   CRUC2
          TST     is40(A4)
          BNE     CRUC700
          CMPI.B  #TNrCRP,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrSRP,D3
          BEQ.L   CRUC2
!CRUC700  CMPI.B  #TNrTT0,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrTT1,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrITT0,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrITT1,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrDTT0,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrDTT1,D3
          BEQ.L   CRUC2
!CRUC701  CMPI.B  #TNrFPCR,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrFPSR,D3
          BEQ.L   CRUC2
          CMPI.B  #TNrFP0,D3     ; FP0 - FP7.E Sonderbehandlung
          BEQ.L   CRUC6
          BLT.S   CRUC70
          CMPI.B  #TNrFP7,D3
          BHI.S   CRUC70
          BSR     NextFPTAB
          MOVEQ   #ZEILLEN-16,D0
          CLR.L   D1
          MOVE.B  D3,D1
          SUB.B   #TNrFP0,D1
          MULU.W  #12,D1
          LEA     RgFP0(A4),A0
          MOVE.W  0(A0,D1.w),D1 ; Test auf (S)NAN und INFINITY
          BSET    #15,D1        ; SignBit soll nicht berÅcksichtigt werden
          NOT.W   D1            ; Ist Exponent Max?
          BEQ.S   CRUC7         ; dann keine Realzahl
          MOVEQ   #ZEILLEN-32,D0
          BRA.S   CRUC7
!CRUC70   MOVEQ   #ZEILLEN-14,D0
          CMPI    #TNrSR,D3      ; SR Register Sonderbehandlung
          BNE     CRUC71
          ADDQ.W  #4,D0          ; weil wordweise Ausgabe
          BRA.S   CRUC7
!CRUC71   CMPI    #TNrPSR,D3
          BNE     CRUC72
          TST     is40(A4)       ; 68040 32 Bit Register
          BNE     CRUC7
          ADDQ.W  #4,D0          ; weil wordweise Ausgabe
          BRA     CRUC7
!CRUC72   CMPI    #TNrCRP,D3
          BNE     CRUC73
          TST     is40(A4)
          BNE     CRUC7
          SUBQ.W  #4,D0          ; weil 64 Bit
          BRA     CRUC7
!CRUC73   CMPI    #TNrSRP,D3
          BNE     CRUC74
          TST     is40(A4)
          BNE     CRUC7
          SUBQ.W  #4,D0          ; weil 64 Bit
          BRA     CRUC7
!CRUC74   CMPI    #TNrFPCR,D3
          BNE     CRUC75
          MOVEQ   #ZEILLEN-11,D0
          BRA     CRUC7
!CRUC75   CMPI    #TNrFPIAR,D3
          BNE     CRUC76
          MOVEQ   #ZEILLEN-16,D0
          BRA     CRUC7
!CRUC76   CMPI    #TNrFPSR,D3
          BNE     CRUC77
          MOVEQ   #ZEILLEN-15,D0
          BRA     CRUC7
!CRUC77   CMPI    #TNrFP0,D3
          BEQ.S   CRUC6
          BLT.S   CRUC7
          CMPI    #TNrFP7,D3
          BHI.S   CRUC7
          MOVEQ   #ZEILLEN-29,D0
!CRUC7    BCLR    #6,D7
          BNE     CRUC6
          CMP     CursorX(A4),D0
          BCC     CRUC2          ; Reg. paût noch in Zeile

!CRUC6    ; Am Anfang der Zeile Kennungzeichen ausgeben
          MOVEM.L D4/D5,-(SP)
          BSR     PRTPRMPT
          MOVEM.L (SP)+,D4/D5
          BTST    #10,D7
          BEQ     CRUC3

          ; 'D' bzw. 'A' am Zeilenanfang ausgeben
          CMPI.B  #TNRD0,D2
          BNE.S   CRUC4
          MOVEQ   #'D',D1
          BRA.S   CRUC5
!CRUC4    CMPI.B  #TNRA0,D2
          BNE.S   CRUC3
          MOVEQ   #'A',D1
!CRUC5    MOVEQ   #';',D0
          BSR     Prt
          MOVE.B  D1,D0
          BSR     Prt
          BRA.S   CRUC2

!CRUC3    ; 'R' am Zeilenanfang ausgeben
          MOVEQ   #'R',D0
          BSR     Prt
          BTST    #0,D7
          BEQ.S   CRUC2
          MOVEQ   #':',D0
          BSR     Prt
          MOVEQ   #'+',D0
          BSR     Prt

!CRUC2    TST     is20(A4)
          BEQ     CRUC21
          CMPI.B  #TNrSSP,D2      ; es gibt kein SSP Register
          BEQ     CRUE2
!CRUC21   BSR     PrtREG          ; REG. (D2) ANZEIGEN

!CRUE     TST.W   D3
          BNE.S   CRUE2
          BCLR    #10,D7
          BNE.S   CRCE2

!CRUE2    ADDQ.W  #1,D3
          MOVEQ   #TNRLast00,D0
          TST     is10(A4)
          BEQ     CRCE3
          MOVEQ   #TNRLast10,D0
          TST     is20(A4)
          BEQ     CRCE3
          MOVEQ   #TNRLast20,D0
          TST     is30(A4)
          BEQ     CRCE3
          MOVEQ   #TNRLast30,D0
!CRCE3    CMP.B   D0,D3
          BLS     CRL0

          TST     isFPU(A4)
          BEQ     CRCE
          MOVEQ   #TNrLastFPU,D0
          CMP.B   D3,D0
          BCS.S   CRCE
          CMPI.B  #TNrFirstFPU,D3
          BCC     CRCE3
          MOVEQ   #TNrFirstFPU,D3
          BRA.S   CRCE3
!CRCE     CLR.W   D3
          BTST    #10,D7
          BNE     CRL0
!CRCE2    BRA     PrtCRLF
;         RTS

!ChkRegNo CMPI.B  #TNRA7,D2      ; A7 ?
          BNE.S   ChkRN1
          BTST    #4,D7          ; Aufruf von R:?
          BEQ     ChkRN1
          BSET    #5,D7
          BTST    #5,RgSR(A4)    ; S-Bit in SR gesetzt ?
          BEQ     BRGC4
          MOVEQ   #TnrSSP,D2     ; JA,DANN NR. F. SSP
          TST     is20(A4)       ; 68020 oder hîher ?
          BEQ     ChkRNE
          MOVEQ   #TnrISP,D2
          BTST    #4,RgSR(A4)    ; M-Bit in SR gesetzt ?
          BEQ     ChkRNE
          MOVEQ   #TnrMSP,D2
          BRA     ChkRNE
!BRGC4    MOVEQ   #TnrUSP,D2     ; sonst NR. F. USP
!ChkRNE   RTS
!ChkRN1   BCLR    #5,D7
          TST     is40(A4)
          BEQ     ChkRNE
(* !TT 11.04.95 dies nicht machen, weil sonst auch bei "R+" immer Fehler bei 68040 kÑme:
          CMPI.B  #TNrCRP,D2
          BEQ     ChkRNErr
!ChkRN2   CMPI.B  #TNrTT0,D2
          BEQ     ChkRNErr
!ChkRN3   CMPI.B  #TNrTT1,D2
          BNE     ChkRNErr
!ChkRN4   CMPI.B  #TNrCAAR,D2
*)
          BNE     ChkRNE
!ChkRNErr MOVE.L  (SP)+,D0      ; Returnadresse vom Stapel schmeiûen
          BRA.L   ERR7          ; ungÅltiges Register

!BERREGNR MOVEM.L A0-A2,-(SP)
          BCLR    #2,D7
          BCLR    #3,D7
          MOVEQ   #-1,D2
          TST     is40(A4)
          BEQ     BERREGNR1
          CLR.L   D2
!BERREGNR1 SWAP    D2
          CLR.W   D2
          MOVE.L  A6,A2          ; Pointer merken!
          LEA     REGTAB(PC),A1
          LEA     REGTABEND(PC),A0
          TST     is10(A4)
          BEQ     BRGL1
          LEA     REGTABEND10(PC),A0
          TST     is20(A4)
          BEQ     BRGL1
          LEA     REGTABEND20(PC),A0
          TST     is30(A4)
          BEQ     BRGL1
          LEA     REGTABEND30(PC),A0
          TST     is40(A4)
          BEQ     BRGL1
          LEA     REGTABEND40(PC),A0
!BRGL1    CMP.B   (A1),D0         ; SUCHE REG.NAME
          BEQ.S   BRGC1
!BRGC2    ADDQ.L  #5,A1
          MOVE.L  A2,A6
          BSR     GETLGRKL
          ADDQ.W  #1,D2
          CMPA.L  A0,A1
          BCS.S   BRGL1
          SWAP    D2
          TST     D2
          BEQ.L   ERR7
          TST     isFPU(A4)
          BEQ.L   ERR7            ; UNGöLTIGES REG
          CLR.W   D2
          SWAP    D2
          LEA     REGTABENDFPU(PC),A0
          LEA     REGTABFPU(PC),A1
          BRA.S   BRGL1

!BRGC1    BSR     GETNGRKL
          CMP.B   1(A1),D0
          BNE.S   BRGC2
          CMPI.B  #' ',2(A1)
          BEQ     BRGC5
          BSR     GETNGRKL
          CMP.B   2(A1),D0
          BNE.S   BRGC2
          CMPI.B  #' ',3(A1)
          BEQ     BRGC5
          BSR     GETNGRKL
          CMP.B   3(A1),D0
          BNE     BRGC2
          CMPI.B  #' ',4(A1)
          BEQ     BRGC5
          BSR     GETNGRKL
          CMP.B   4(A1),D0
          BNE     BRGC2
!BRGC5    BSR     ChkRegNo
          BSR     GETNGRKL
          BMI     BRGC3
          CMPI.B  #SPC,D0
          BEQ     BRGC3
          CMPI.B  #'.',D0
          BEQ     BRGC6
          CMPI.B  #':',D0
          BEQ     BRGC3
          CMPI.B  #'+',D0
          BEQ     BRGC3
          CMPI.B  #'-',D0
          BEQ     BRGC3
          CMPI.B  #')',D0
          BEQ     BRGC3
          CMPI.B  #'Z',D0
          BEQ     BRGC3
          CMPI.B  #'L',D0
          BEQ     BRGC3
          CMPI.B  #'X',D0
          BEQ     BRGC3
          CMPI.B  #CR,D0
          BEQ     BRGC3
          CMPI.B  #'=',D0
          BNE     BRGC2          ; scheinbar nicht das Ende des Registers erreicht!
          BRA.S   BRGC3
!BRGC6    BSET    #2,D7
          BSET    #3,D7
!BRGC3    MOVEM.L (SP)+,A0-A2
          RTS

!BERREGBIN
          MOVEM.L D0/D2/D3/A0/A1,-(SP) ; A2 : Pointer auf Tabelle
          MOVE.L  A2,A0           ; D1 : bisheriger Registerwert
          MOVE.L  A6,A1           ; Pointer auf Keyboardinput merken
!BERREGBINLT
          MOVE.L  A1,A6
          MOVEQ   #-1,D2
!BERREGBINL
          TST.B   1(A0,D2.w)      ; NÑchstes Zeichen Tabellenende?
          BEQ.S   BERREGBINOK     ; ja, dann gefunden
          BSR.L   GETNGRKL        ; nÑchstes Zeichen holen
          BPL     BERREGBINCMP    ; kein Zeilenende erreicht
          TST.L   D2              ; war Zeichen hinter Punkt?
          BMI.L   BERREGBINEND    ; nein, dann kein Fehler
          BRA     ERR7            ; sonst Fehler
!BERREGBINCMP
          ADDQ.L  #1,D2           ; ZeichenzÑhler inkrementiern
          MOVE.B  0(A0,D2.w),D3
          CMPI.B  #'z',D3
          BHI     BERREGBINNOTKL
          CMPI.B  #'a',D3
          BCS     BERREGBINNOTKL
          SUBI.B  #$20,D3
!BERREGBINNOTKL
          CMP.B   D3,D0           ; Zeichen mit Tabelle vergl.
          BEQ.S   BERREGBINL      ; gleich, dann nÑchstes Zeichen
!BERREGBINLTN
          ADDA.W  -6(A2),A0       ; nÑchste Tabellenzeile holen
          TST.B   (A0)            ; Tabellenende erreicht?
          BNE.S   BERREGBINLT
          BRA     ERR7            ; ja, dann Fehler
!BERREGBINOK
          BSR.L   GETNGRKL        ; nÑchstes Zeichen holen
          BMI     ERR7            ; Zeilenende? : dann Fehler
          CMPI.B  #'=',D0         ; Vergleich auf Zuweisung
          BNE     BERREGBINLTN    ; nein? dann neu in Tabelle
          MOVEM.L D1/A0/A2,-(SP)
          BSR     GETNGRKL
          BSR     GETLONGX        ; Wert holen
          MOVE.L  D1,D0
          MOVEM.L (SP)+,D1/A0/A2
          CLR.L   D2              ; Tabellenindex
          CLR.L   D3              ; Tabellenwert
          MOVE.B  -2(A2),D2       ; Tabelleneintrag Maske holen
          MOVE.B  0(A0,D2.w),D3   ; 8 Bit Maske holen
          TST.B   -1(A2)          ; 16 Bitmaske vorhanden?
          BEQ     BERREGBINMASK   ; nein, dann mit 8 Bit maskieren
          BMI     BERREGBINMASK   ; nein, dann mit 8 Bit maskieren
          CMPI.B  #127,-1(A2)
          BEQ     BigMask
          ASL.L   #8,D3           ; Hibyte schieben
          MOVE.B  -1(A2),D2       ; Tabelleneintrag 16 Bit Maske holen
          MOVE.B  0(A0,D2.w),D3   ; 16 Bit Maske zusammenbauen
          BRA     BERREGBINMASK
!BigMask  MOVE.L  0(A0,D2.w),D3   ; dieser Befehl darf erst ab 68020 ausgefÅhrt
                                  ; werden
!BERREGBINMASK
          AND.L   D3,D0           ; eingegebene Werte ausmaskieren
          MOVE.B  -3(A2),D2       ; Tabelleneintrag Bitnummer holen
          MOVE.B  0(A0,D2.w),D2   ; Bitnummer holen
          ASL.L   D2,D0           ; eingegebener Wert an Bitnummer schieben
          ASL.L   D2,D3           ; Maske an Bitnummer schieben
          NOT.L   D3
          AND.L   D3,D1           ; Bits aus altem Wert lîschen
          OR.L    D0,D1           ; eingegebene Bits einsetzen
!BERREGBINEND
          MOVEM.L (SP)+,D0/D2/D3/A0/A1
          RTS



; REGISTER-EINGABE 2

!ComdSEMK BCLR    #11,D7
          BSR.L   SKIPSPC
          MOVEQ   #TNRD0,D2
          CMPI.B  #'D',D0
          BEQ.S   CSCC1
          CMPI.B  #'A',D0
          BNE     ERR14
          MOVEQ   #TNRA0,D2
!CSCC1    MOVEQ   #7,D4
          LEA     REGBEG(A4),A1
          BSR.L   GETNGRKL
!CSCL1    BSR.L   SKIPSPC
          BMI.S   CSCE
          BSR.L   GETLONGX
          BSR     ChkRegNo
          MOVE    D2,D3
          LSL.W   #2,D3     ; TNR * 4
          MOVE.L  D1,0(A1,D3.W)
          ADDQ.W  #1,D2
          DBF     D4,CSCL1
!CSCE     RTS

; Register Ein- / Ausgabe


!COUB1    CMPI.B  #TNrSR,D2
          BNE     COUB2
          CLR.L   D1
          MOVE.W  RgSR(A4),D1
!COUBL1   LEA     SRTAB(PC),A2
          TST     is20(A4)
          BEQ     COUB11
          LEA     SRTAB20(PC),A2
!COUB11   BSR     BERREGBIN
          TST.W   D7
          BMI     COUB12
          TST.B   D7
          BPL     COUB12
          BSR     SKIPSPC0
          BRA     COUBL1
!COUB12   MOVE.W  D1,RgSR(A4)
          BRA.L   COUC7

!COUB2    CMPI.B  #TNrCACR,D2
          BNE     COUB3
          MOVE.L  RgCACR(A4),D1
!COUBL2   LEA     CACHETAB(PC),A2
          TST     is30(A4)
          BEQ     COUB21
          LEA     CACHETAB30(PC),A2
          TST     is40(A4)
          BEQ     COUB21
          LEA     CACHETAB40(PC),A2
!COUB21   BSR     BERREGBIN
          TST.W   D7
          BMI     COUB22
          TST.B   D7
          BPL     COUB22
          BSR     SKIPSPC0
          BRA     COUBL2
!COUB22   MOVE.L  D1,RgCACR(A4)
          BRA.L   COUC7

!COUB3    CMPI.B  #TNrPSR,D2
          BNE     COUB4
          TST     is40(A4)
          BNE     COUB32
          CLR.L   D1
          MOVE.W  RgPSR(A4),D1
!COUBL3   LEA     MMUPSRTAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI     COUB31
          TST.B   D7
          BPL     COUB31
          BSR     SKIPSPC0
          BRA     COUBL3
!COUB31   MOVE.W  D1,RgPSR(A4)
          BRA.L   COUC7
!COUB32   MOVE.L  RgPSR(A4),D1
!COUBL32  LEA     MMUPSR40TAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI     COUB33
          TST.B   D7
          BPL     COUB33
          BSR     SKIPSPC0
          BRA     COUBL32
!COUB33   MOVE.L  D1,RgPSR(A4)
          BRA.L   COUC7

!COUB4    CMPI.B  #TNrTC,D2
          BNE     COUB5
          MOVE.L  RgTC(A4),D1
!COUBL4   LEA     MMUTCTAB(PC),A2
          TST     is40(A4)
          BEQ     COUB41
          LEA     MMUTC40TAB(PC),A2
!COUB41   BSR     BERREGBIN
          TST.W   D7
          BMI     COUB42
          TST.B   D7
          BPL     COUB42
          BSR     SKIPSPC0
          BRA     COUBL4
!COUB42   MOVE.L  D1,RgTC(A4)
          BRA.L   COUC7

!COUB5    CMPI.B  #TNrSRP,D2
          BNE.L   COUB6
          TST     is40(A4)
          BNE.L   COUB6
          LEA     RgSRP(A4),A0
!COUBRP   MOVE.L  A6,A1
          BSR.L   GETLGRKL
          LEA     MMURPTAB3(PC),A2
!COUB51   BSR.L   GETNGRKL
!COUB52   MOVE.B  (A2)+,D1
          CMPI.B  #'=',D1
          BEQ     COUB53
          CMP.B   D1,D0
          BEQ.S   COUB51
          MOVE.L  A1,A6
          BSR.L   GETLGRKL
          MOVE.L  (A0),D1
          LEA     MMURPTAB(PC),A2
          MOVE.L  A0,-(SP)
          BSR     BERREGBIN
          MOVE.L  (SP)+,A0
          MOVE.L  D1,(A0)
          TST.W   D7
          BMI.L   COUC7
          TST.B   D7
          BPL.L   COUC7
          BSR     SKIPSPC0
          BRA     COUBRP
!COUB53   CMPI.B  #SPC,D0
          BNE.S   COUB54
          BSR     SKIPSPCN
!COUB54   CMPI.B  #'=',D0
          BNE.L   ERR7
          BSR     SKIPSPCN
          BSR     GETLONGX
          ANDI.B  #$F0,D1
          MOVE.L  D1,4(A0)
          TST.W   D7
          BMI.L   COUC7
          TST.B   D7
          BPL.L   COUC7
          BSR     SKIPSPC0
          BRA     COUBRP

!COUB6    CMPI.B  #TNrCRP,D2
          BNE     COUB7
          TST     is40(A4)
          BNE     COUB7
          LEA     RgCRP(A4),A0
          BRA     COUBRP

!COUB7    CMPI.B  #TNrTT0,D2
          BNE     COUB8
          TST     is40(A4)
          BEQ     COUB71
          MOVEQ   #TNrITT0,D2
          BRA     COUB8
!COUB71   MOVE.L  RgTT0(A4),D1
!COUBL7   LEA     MMUTTTAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI     COUB72
          TST.B   D7
          BPL     COUB72
          BSR     SKIPSPC0
          BRA     COUBL7
!COUB72   MOVE.L  D1,RgTT0(A4)
          BRA.L   COUC7

!COUB8    CMPI.B  #TNrTT1,D2
          BNE     COUB82
          TST     is40(A4)
          BEQ     COUB81
          MOVEQ   #TNrITT1,D2
          BRA     COUB82
!COUB81   MOVE.L  RgTT1(A4),D1
!COUBL8   LEA     MMUTTTAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI     COUB801
          TST.B   D7
          BPL     COUB801
          BSR     SKIPSPC0
          BRA     COUBL8
!COUB801  MOVE.L  D1,RgTT1(A4)
          BRA.L   COUC7
!COUB82   CMPI.B  #TNrITT0,D2
          BNE     COUB83
          MOVE.L  RgITT0(A4),D1
!COUBL82  LEA     MMUTT40TAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI     COUB802
          TST.B   D7
          BPL     COUB802
          BSR     SKIPSPC0
          BRA     COUBL82
!COUB802  MOVE.L  D1,RgITT0(A4)
          BRA.L   COUC7
!COUB83   CMPI.B  #TNrITT1,D2
          BNE     COUB84
          MOVE.L  RgITT1(A4),D1
!COUBL83  LEA     MMUTT40TAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI.L   COUB803
          TST.B   D7
          BPL     COUB803
          BSR     SKIPSPC0
          BRA     COUBL83
!COUB803  MOVE.L  D1,RgITT1(A4)
          BRA.L   COUC7
!COUB84   CMPI.B  #TNrDTT0,D2
          BNE     COUB85
          MOVE.L  RgDTT0(A4),D1
!COUBL84  LEA     MMUTT40TAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI     COUB804
          TST.B   D7
          BPL     COUB804
          BSR     SKIPSPC0
          BRA     COUBL84
!COUB804  MOVE.L  D1,RgDTT0(A4)
          BRA.L   COUC7
!COUB85   CMPI.B  #TNrDTT1,D2
          BNE     COUB9
          MOVE.L  RgDTT1(A4),D1
!COUBL85  LEA     MMUTT40TAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI     COUB805
          TST.B   D7
          BPL     COUB805
          BSR     SKIPSPC0
          BRA     COUBL85
!COUB805  MOVE.L  D1,RgDTT1(A4)
          BRA.L   COUC7

!COUB9    CMPI.B  #TNrFPCR,D2
          BNE     COUBA
          MOVE.L  RgFPCR(A4),D1
!COUBL9   LEA     FPCRTAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI     COUB91
          TST.B   D7
          BPL     COUB91
          BSR     SKIPSPC0
          BRA     COUBL9
!COUB91   MOVE.L  D1,RgFPCR(A4)
          BRA.L   COUC7

!COUBA    CMPI.B  #TNrFPSR,D2
          BNE     COUBB
          MOVE.L  RgFPSR(A4),D1
!COUBLA   LEA     FPSRTAB(PC),A2
          BSR     BERREGBIN
          TST.W   D7
          BMI     COUBA1
          TST.B   D7
          BPL     COUBA1
          BSR     SKIPSPC0
          BRA     COUBLA
!COUBA1   MOVE.L  D1,RgFPSR(A4)
          BRA.L   COUC7

!COUBB    CMPI.B  #TNrFP0,D2
          BCS     COUBC
          CMPI.B  #TNrFP7,D2
          BHI     COUBC
          BTST    #7,D7
          BNE.L   ERR7
          BSR     GETNGRKL
          CMPI.B  #'E',D0
          BNE.L   ERR7
          BSR     SKIPSPCN
          BMI.L   COUC7
          CMPI.B  #'=',D0
          BNE.L   ERR14
          MOVE.L  D2,-(SP)
          BSR     GETREAL
          BMI     ERR2
          BNE     ERR1
          MOVE.L  (SP),D2
          SUBI.W  #TNrFP0,D2
          MULU    #12,D2
          LEA     RgFP0(A4),A0
          LEA     REALREAL(A4),A1
          MOVE.L  0(A1),0(A0,D2.w)
          MOVE.L  4(A1),4(A0,D2.w)
          MOVE.L  8(A1),8(A0,D2.w)
          MOVE.L  (SP)+,D2
          BRA.L   COUC7

!COUBC    BRA.L   ERR7            ; alle anderen Register Fehler!


!COUL1    BSR.L   BERREGNR        ; Registernummer holen
          BTST    #4,D7           ; VON 'R:'-FUNKTION AUFGERUFEN ?
          BEQ.L   COUC3           ; Ja, nicht auf Zuweisung testen

          BSR.L   SKIPSPC
          CMPI.B  #'.',D0         ; Bitweise Zuweisung in Register ?
          BNE     COUL11
          MOVE.L  A6,A1
          BMI.L   COUC7           ; Register Flagweise ausgeben
          MOVE.L  A1,A6
          BSR     SKIPSPC0N
          BCLR    #7,D7
          BRA     COUB1
!COUL11   CMPI.B  #':',D0         ; Bitweise Zuweisung in Register bis Zeilenende?
          BNE     COUL12
          MOVE.L  A6,A1
          BMI.L   COUC7           ; Register Flagweise ausgeben
          MOVE.L  A1,A6
          BSR     SKIPSPC0N
          BSET    #7,D7
          BRA     COUB1
!COUL12   CMPI.B  #'=',D0         ; REG.-ZUWEISUNG ?
          BNE.L   COUC3
          BSR.L   SKIPSPCN
          CMPI.B  #TNRSR,D2       ; ZUW. IN SR ?
          BNE.S   COUC41
          BSR.L   GETWORD         ; JA,NUR 2 BYTE HOLEN
          BRA.L   COUC5
!COUC41   CMPI.B  #TNrPSR,D2
          BNE     COUC42
          BSR.L   GETWORD
          BRA.L   COUC5
!COUC42   CMPI.B  #TNrCRP,D2
          BNE     COUC43
          MOVEM.L D0-D3,-(SP)
          BSR.L   GETLONGXL
          LEA     RgCRP(A4),A1
          MOVE.L  D2,(A1)+
          MOVE.L  D1,(A1)+
          MOVEM.L (SP)+,D0-D3
          BRA.L   COUC3
!COUC43   CMPI.B  #TNrSRP,D2
          BNE     COUC44
          MOVEM.L D0-D3,-(SP)
          BSR.L   GETLONGXL
          LEA     RgSRP(A4),A1
          MOVE.L  D2,(A1)+
          MOVE.L  D1,(A1)+
          MOVEM.L (SP)+,D0-D3
          BRA.S   COUC3
!COUC44   CMPI.B  #TNrFP0,D2      ; FLOATING POINT Register
          BCS     COUC4
          CMPI.B  #TNrFPCR,D2
          BNE.S   COUC45
          BSR     GETWORD
          MOVE.L  D1,RgFPCR(A4)
          BRA.S   COUC3
!COUC45   CMPI.B  #TNrFPSR,D2
          BNE.S   COUC46
          BSR     GETLONGX
          MOVE.L  D1,RgFPSR(A4)
          BRA.S   COUC3
!COUC46   CMPI.B  #TNrFPIAR,D2
          BNE.S   COUC47
          BSR     GETLONGX
          MOVE.L  D1,RgFPIAR(A4)
          BRA.S   COUC3
!COUC47   MOVEM.L D2-D4,-(SP)
          MOVE.L  D2,-(SP)
          BSR     GETLONGXL
          MOVE.L  (SP)+,D4
          SUB.W   #TNrFP0,D4
          MULU    #12,D4
          LEA     RgFP0(A4),A0
          ADDA.W  D4,A0
          MOVE.L  D3,(A0)+
          MOVE.L  D2,(A0)+
          MOVE.L  D1,(A0)+
          MOVEM.L (SP)+,D2-D4
          BRA.S   COUC3
!COUC4    BSR.L   GETLONGX        ; SONST 4 BYTE HOLEN
!COUC5    LEA     REGBEG(A4),A1
          LSL.W   #2,D2
          MOVE.L  D1,0(A1,D2.W)    ; WERT SPEICHERN
          LSR.W   #2,D2
          BRA.S   COUC3
!COUC7    BSET    #3,D7
          BSET    #31,D3
!COUC3    BCLR    #2,D7

(*
!COUC3    BCLR    #3,D7
          BNE     COUC7
          BCLR    #2,D7
          BEQ     COUC1
!COUC7    BCLR    #5,D7
          BEQ.S   COUC71
          BSET    #TNrCACR,D3
          BRA.S   COUC72
!COUC71   BSET    #TNRSR,D3
!COUC72   BSET    #31,D3        ; Flag wurde einzeln zugegriffen
          CLR.L   D4
          BRA     COU
*)

!COUC1    CMPI    #TNrLast20,D2
          BHI     COUC11        ; C + Z = 0
          BSET    D2,D3
          BRA.S   COU
!COUC11   SUBI    #TNrLast20,D2
          BSET    D2,D4
          ADDI    #TNrLast20,D2
!COU      ;*** aus Eingabepuffer Registernamen holen und ggf. zuweisen
          BSR     SKIPSPC
          BPL     COUL1
          RTS

!CRAW     BCLR    #11,D7
          BSR.L   GETNGRKL
          BMI.L   COSHOW

          CMPI.B  #'.',D0
          BNE     CRAW01
          BCLR    #7,RegWahl(A4)
          BRA     CRAW
!CRAW01   CMPI.B  #'*',D0
          BNE     CRAW02
          BSET    #7,RegWahl(A4)
          BRA     CRAW
!CRAW02
          CMPI.B  #'-',D0
          BNE.S   COC1

          BSR.L   GETNGRKL
          BPL.S   COSUB
          ANDI.L  #$80000000,RegWahl(A4)
          CLR.L   RegWahl2(A4)
          RTS
!COSUB    CLR.L   D3
          CLR.L   D4
          BSR     COU
          NOT.L   D4
          NOT.L   D3
          BTST    #0,D3
          BNE     COSUBC0
;          BCLR    #31,D3
          BSET    #31,D3
!COSUBC0  AND.L   D3,RegWahl(A4)
          AND.L   D4,RegWahl2(A4)
          BRA.L   Test40CRAW

!COC1     CMPI.B  #'0',D0
          BEQ.L   CRAW0
          CMPI.B  #'1',D0
          BEQ.L   CRAW1
          CMPI.B  #'2',D0
          BEQ.L   CRAW2
          CMPI.B  #'3',D0
          BEQ.L   CRAW3
          CMPI.B  #'4',D0
          BEQ.L   CRAW4
          CMPI.B  #'8',D0
          BEQ.L   CRAW8
          CMPI.B  #'F',D0
          BEQ.L   CRAW8
          CMPI.B  #'B',D0
          BEQ     CRAWB
          CMPI.B  #'+',D0
          BNE.L   COSELCT
          BSR.L   GETNGRKL
          BPL.L   COADD
          ORI.L   #$7FFFFFFF,RegWahl(A4)
          MOVE.L  #-1,RegWahl2(A4)
          BRA.L   Test40CRAW

!CRAWB    TST.W   D7
          BMI     CRAWBE
          BSR     GETNGRKL
          CMPI.B  #'+',D0
          BNE     CRAWB1
          BSET    #7,RegWahl(A4)
          BRA     CRAWBE
!CRAWB1   CMPI.B  #'-',D0
          BNE     CRAWBE
          BCLR    #7,RegWahl(A4)
!CRAWBE   RTS

!CRAW0    ANDI.L  #$80000000,RegWahl(A4)
          ORI.L   #$060FFFFF,RegWahl(A4)
          CLR.L   RegWahl2(A4)
          BRA.L   Test40CRAW
!CRAW1    TST     is10(A4)
          BEQ     CRAW0
          ANDI.L  #$80000000,RegWahl(A4)
          ORI.L   #$07CFFFFF,RegWahl(A4)
          CLR.L   RegWahl2(A4)
          BRA.L   Test40CRAW
!CRAW2    TST     is20(A4)
          BEQ     CRAW1
          ANDI.L  #$80000000,RegWahl(A4)
          ORI.L   #$7FCFFFFF,RegWahl(A4)
          CLR.L   RegWahl2(A4)
          BRA.L   Test40CRAW
!CRAW3    TST     is30(A4)
          BEQ     CRAW2
          ANDI.L  #$80000000,RegWahl(A4)
          ORI.L   #$7FCFFFFF,RegWahl(A4)
          MOVE.L  #$7F,RegWahl2(A4)
          BRA.L   Test40CRAW
!CRAW4    TST     is40(A4)
          BEQ     CRAW3
          ANDI.L  #$80000000,RegWahl(A4)
          ORI.L   #$7FCFFFFF,RegWahl(A4)
          MOVE.L  #$FFFFFFFF,RegWahl2(A4)
          BRA.L   Test40CRAW
!CRAW8    TST     isFPU(A4)
          BEQ     CRAW4
          MOVE.L  RegWahl2(A4),D0
          ORI.L   #111111111110000000%,D0
          MOVE.L  D0,RegWahl2(A4)
          BRA.L   Test40CRAW
!COSELCT  ANDI.L  #$80000000,RegWahl(A4)
          CLR.L   RegWahl2(A4)
!COADD    CLR.L   D3
          CLR.L   D4
          BSR     COU
          BTST    #0,D3
          BEQ     COADDC0
          BCLR    #7,RegWahl(A4)
!COADDC0  OR.L    D3,RegWahl(A4)
          OR.L    D4,RegWahl2(A4)
          BRA.L   Test40CRAW

!COSHOW   BSR     PrtPRMPT1
          MOVEQ   #'R',D0
          BSR     Prt
          MOVEQ   #':',D0
          BSR     Prt
          BSET    #0,D7
          MOVE.L  RegWahl(A4),D4
          MOVE.L  RegWahl2(A4),D5
          BRA.L   CRU

; SPEICHER-EINGABE

!ComdDOPP CMPI.B  #'B',D0
          BEQ     ComdDOPPB
          CMPI.B  #'W',D0
          BEQ.L   ComdDOPPW
          CMPI.W  #'L',D0
          BEQ.L   ComdDOPPL
          BRA.S   ComdDOPPBy
!ComdDOPPB BSR.L  GETNGRKL
!ComdDOPPBy
          BCLR    #11,D7        ; LF nicht unterdrÅcken
          BSR.L   GETADR0       ; ungerade Zahlen erlaubt
          BMI     CCLNEND
          MOVEA.L D1,A1
          MOVE.L  A1,LastMA(A4)

!CCLNL1   BSR.S   GETByteX
          BTST    #14,D7
          BNE     CCLNL2
          MOVE.B  D1,(A1)+
          TST.W   D7
          BPL     CCLNL1

!CCLNL2   TST     noUpdate(A4)
          BNE     CCLNEND
          MOVEM.L A0-A6/D0-D7,-(SP)
          MOVE    #62,CursorX(A4)
          MOVE    CursorY(A4),D0
          MOVE.W  D0,-(SP)
          BEQ     CCLNL3
          CMP     Lines(A4),D0
          BCC     CCLNL3
          SUBQ.W  #1,CursorY(A4)
!CCLNL3   MOVEQ   #'|',D0
          BSR     Prt
          MOVE.L  LastMa(A4),A2
!CCLNL4   MOVE.B  (A2)+,D0
          MOVEQ.L #0,D1
          CMPA.L  A1,A2
          BHI.S   CCLNL5             ; C=0 und Z=0 !
          MOVEM.L A1/A2,-(SP)
          BSR     DispChar
          MOVEM.L (SP)+,A1/A2
          ADDQ.W  #1,CursorX(A4)
          MOVE.W  CursorX(A4),D0
          CMP.W   Rows(A4),D0
          BCS.S   CCLNL4
!CCLNL5   MOVE.W  (SP)+,CursorY(A4)
          MOVEM.L (SP)+,A0-A6/D0-D7
!CCLNEND  RTS

!GetByteX ; Liefert Byte, lÑût auch Regs zu
          BSR     SKIPSPC
          CMPI.B  #'R',D0
          BNE     GetByte
          BSR     GetLongX
          ROL.L   #8,D1
          MOVE.B  D1,(A1)+
          ROL.L   #8,D1
          MOVE.B  D1,(A1)+
          ROL.L   #8,D1
          MOVE.B  D1,(A1)+
          ROL.L   #8,D1
          RTS

; SPEICHER-EINGABE Word

!ComdDOPPW BSR.L  GETNGRKL
          BCLR    #11,D7        ; LF nicht unterdrÅcken
          BSR.L   GETADRG       ; ungerade Zahlen nicht erlaubt
          BMI     CCLNENDW
          MOVEA.L D1,A1
          MOVE.L  A1,LastMA(A4)

!CCLNL1W  BSR.S   GetWord_X
          BTST    #14,D7
          BNE     CCLNL2
          MOVE.W  D1,(A1)+
          TST.W   D7
          BPL     CCLNL1W
          BRA     CCLNL2

!CCLNENDW RTS

!GetWord_X ; Liefert Byte, lÑût auch Regs zu
          BSR     SKIPSPC
          CMPI.B  #'R',D0
          BNE     GetWord
          BSR     GetLongX
          ROL.L   #8,D1
          MOVE.B  D1,(A1)+
          ROL.L   #8,D1
          MOVE.B  D1,(A1)+
          ROL.L   #8,D1
          RTS

; SPEICHER-EINGABE LONG

!ComdDOPPL BSR.L  GETNGRKL
          BCLR    #11,D7        ; LF nicht unterdrÅcken
          BSR.L   GETADRG       ; ungerade Zahlen nicht erlaubt
          BMI     CCLNENDL
          MOVEA.L D1,A1
          MOVE.L  A1,LastMA(A4)

!CCLNL1L  BSR.S   GetLong_X
          BTST    #14,D7
          BNE     CCLNL2
          MOVE.L  D1,(A1)+
          TST.W   D7
          BPL     CCLNL1L
          BRA     CCLNL2

!CCLNENDL RTS

!GetLong_X ; Liefert Byte, lÑût auch Regs zu
          BSR     SKIPSPC
          CMPI.B  #'R',D0
          BNE     GetLong
          BSR     GetLongX
          RTS

!ComdT0   BSET    #7,TrcStat2(A4)
          BRA.S   ComdTn
!ComdT1   BCLR    #7,TrcStat2(A4)
!ComdTn   BSR     GETNGRKL
          BMI.S   CTC2
          CMPI.B  #'+',D0
          BEQ.S   ComdTP
          CMPI.B  #'-',D0
          BEQ.S   ComdTM
          BRA     ERR14

; TRACE / GO - FUNKTIONEN

!ComdT    BMI.S   CTC2
          TST.B   SysMonCall(A4)
          BNE     CMDBEGOM
          TST     is20(A4)
          BEQ     ComdT68
          CMPI.B  #'0',D0
          BEQ.S   ComdT0
          CMPI.B  #'1',D0
          BEQ.S   ComdT1
!ComdT68  CMPI.B  #'-',D0
          BNE.S   CTC1
!ComdTM   BSR.L   TSTNCR
          CLR.B   TrcStat(A4)
          CLR.B   TrcStat2(A4)
          BCLR    #7,RgSR(A4)         ; T-FLAG IM SR LOESCHEN
          BCLR    #6,RgSR(A4)
          BRA.S   CTC2
!CTC1     CMPI.B  #'+',D0
          BNE     ERR14
!ComdTP   BSR.L   TSTNCR
          LEA     EyTRC(PC),A0
          MOVE.L  A0,TRACEV          ; TRACE EXCEPTION VEKTOR neu setzen
          MOVE.B  #1,TrcStat(A4)
          BSR     SetTraceBit        ; T-FLAG IM SR SETZEN
!CTC2     BSR     PrtCRLF
          BSR     PrtTRMOD        ; STATUS DES BIT 0 IN TrcStat(A4) ANZEIGEN
          LEA     SRMSG(PC),A1
          BSR     PrtSTR
          BSET    #8,D7           ; : NUR T-FLAG DES SR ANZEIGEN
          BSR     PrtSRBIN        ; ZUR SR-AUSGABE
          BRA     PrtCRLF


; RTS - ENTRY ( NACH 'GS'-FUNKTION )

!EyRTN    BREAK
EyRTNE0   BSR     SetMon          ; hier nur Aufruf von Trace-Routine
EyRTNC0   CLR.L   RgPC(A4)        ; PC LOESCHEN,DA UNBRAUCHBARER INHALT
          LEA     RTNMSG(PC),A1
          BRA     CMDBEG

; Go - Funktion

!ComdG    TST.B   SysMonCall(A4)
          BEQ     ComdGC1
!to_CookieRoutine10Return
          ST      BPquest(A4)     ; Fehler beim Setzen der Breakpoints anzeigen
          BSR.L   SetBPs
          BNE.L   cgoTerm
          BRA.L   CookieRoutine10Return
!ComdGC1  BCLR    #11,D7
          MOVE.L  RgPC(A4),D1     ; NEIN: LETZTEN PC öBERNEHMEN
          TST.W   D7              ; ADR.ANGEGEBEN ?
          BMI.S   CGUE
!CGUC1    CMPI.B  #'S',D0         ; GS-BEFEHL ?
          BNE.S   CGUC2
          BSR.L   GETNGRKL        ; JA: TESTEN AUF FOLG. ADR.
          BMI     ERR1
          BSET    #7,D7           ; PEA AUSFöHREN
!CGUC2    BSR     skipspc
          CMPI.B  #',',D0
          BEQ     cmdgc0
          BCLR    #12,D7          ; nur gerade Adr.
          BSR     GETADRG         ; ADR.HOLEN
          BMI     cgue

          ; Short BPs auswerten
!cmdgl0   CMPI.B  #',',D0
          BNE     ERR4            ; ERROR, WENN KEIN CR oder ',' FOLGT
!cmdgc0   CMPI    #shbpanz-1,ShBPcnt(A4)
          BCC     ERR17
          BSR     GetNgrkl
          MOVE.L  D1,-(A7)
          BSR     GETADRG         ; ADR.HOLEN
          BSR.L   InitShortBP
          BSET    #0,ShBPFlg(A4)
          MOVE.L  (A7)+,D1
          BSR     Getlgrkl
          TST     D7
          BPL     cmdgl0

!CGUE     TST.L   D1
          BEQ     ERR8            ; ERROR, WENN ADR.=0

          MOVEA.L D1,A0
          TST.W   (A0)            ; EXISTIERT RAM/ROM AN DER STELLE ?
                                  ; WENN NICHT, WIRD BUSERROR ERZEUGT.
          MOVE.L  D1,RgPC(A4)     ; NEUEN PC öBERNEHMEN

          TST.B   D7              ; GOSUB-COMMAND ?
          BPL.S   CGC2

          ; JA: STACKPOINTER LADEN
          BTST    #5,RgSR(A4)
          BNE     CGC70
          LEA     RgUSP(A4),A1
          BRA     CGC71
!CGC70    LEA     RgSSP(A4),A1
          TST     is20(A4)
          BEQ.S   CGC71
          LEA     RgISP(A4),A1
          BTST    #4,RgSR(A4)
          BEQ.S   CGC71
          LEA     RgMSP(A4),A1
!CGC71    LEA     EyRTN(PC),A5
          MOVE.L  (A1),A0
          MOVE.L  A5,-(A0)        ; RETURN ADR. AUF STACK
          MOVE.L  A0,(A1)         ; NEUEN SP WIEDER SPEICHERN

!CGC2     ; BSR     PrtCRLF         ; CR AUSGEBEN

          ST      BPquest(A4)     ; Errors bei SetBPs anzeigen

          BSR.L   TSTBP           ; ERFOLGT SPRUNG AUF BP ?
          BEQ.S   CGC3            ; NEIN

          ADDQ.W  #1,BPanz+BPanz+BPanz+BPanz+2-4(A0)  ; ZAEHLER UM 1 ERHOEHEN

!CGC3     MOVE.B  TrcStat(A4),D7
          ANDI.B  #1,D7           ; BIT0: Tracemode
                                  ; BIT1: TRACE ANZEIGE AN
                                  ; BIT2: KEIN CTRL-BREAK ERFOLGT
                                  ; BIT3: KEIN TEST AUF 'RTS'
                                  ; BIT4: NICHT ANZEIGE WIEDER EIN
                                  ; BIT5: Nach RÅckkehr T-Bit wieder an
                                  ; BIT6: nicht Traceflag wieder lîschen
                                  ; BIT7: Tracebit immer an (alles tracen)

          BNE.L   TRCGO           ; ZUM TRACEN

          CLR.B   ShBPFlg(A4)

!CGO      TST.B   D7              ; alles tracen ?
          BPL     cgoc3           ; nein

          ; folg. Tests wo anders hin !!!!!!
          ; Test, ob Flp-VBL-Routine gesperrt
          TST.W   $43E
          BNE     cgoc2

          ; Test, ob SR =$27xx, sonst wird Tracebit gesetzt:
          MOVE.B  RgSR(A4),D0
          ANDI.B  #$27,D0
          CMPI.B  #$27,D0
          BNE     cgoc20
!cgoc2    BCLR    #7,RgSR(A4)     ; in Interrupt-gesperrten Routinen kein Trace
          BCLR    #6,RgSR(A4)     ; 2.Trace Bit ab 68020 auch lîschen
          BRA     cgoc3
!cgoc20   BSR     SetTraceBit
!cgoc3
          TST.B   RgSR(A4)        ; SOLL DIESER BEF. GETRACED WERDEN ?
          BMI     CGOC1           ; JA
          BTST.B  #6,RgSR(A4)     ; Trace on Flow Control?
          BNE     CGOC1

          BTST    #6,D7           ; soll aktueller Bef. Åbersprungen werden ?
          BEQ     cgoc0           ; nein

          BSR     SetTraceBit     ; TRACE-FLAG SETZEN
          BRA     CGoC4           ; BPs, zumindest den auf PC-Adr, nicht setzen

!cgoc0    BSR.L   SetBPs          ; BP IM RAM SETZEN
          BNE.L   cgoTerm         ; Abbruch, weil BPs nicht gesetzt
          BRA     CGoC4

!CGOC1    BCLR    #6,D7           ; kînnen wir vergessen, da T-Bit anbleiben soll
          ;!!! Reicht Abfrage, oder muû auch Bit 4 usw. berÅcksichtigt werden ??
          BTST    #1,D7           ; Erfolgt nach AusfÅhrung wieder Anzeige ?
          BEQ     CgoE0

          ; Nein: Monitor-Screen ausschalten
!cgoc4
(*$? ~MAC:
          TST.W   Unknown(A4)
          BEQ     tocgoc4
          TST.L   AskVideoAddress(A4)
          BEQ     tocgoc4
          PEA     cmcgoc4(PC)
          MOVE.L  AskVideoAddress(A4),-(SP)
          RTS
!tocgoc4  LEA     $FFFF8200,A1
          MOVEP.W 1(A1),D0
!cmcgoc4  CMP.W   rMonScreen(PC),D0
          BNE     CGoE0
*)
          BSR     NormScrn

!CGOE0    MOVE.B  D7,TrcStat(A4)
          SF      BPquest(A4)     ; Errors bei SetBPs nicht anzeigen
          BSR.L   kill_repeat
          BSR     RestoreKeyBoard
          BSR     ResetMon        ; VECTOREN WIEDERHERSTELLEN, Tracing aktiv
          TST.W   ResetDebug(A4)
          BEQ     CGOE01
          MOVEQ   #0,D0
          MOVEQ   #0,D1
          BSR.L   InitVec
          CLR.W   ResetDebug(A4)
!CGOE01   TST     is10(A4)
          BEQ.L   CGgoon
          MOVE.L  RgSFC(A4),D0
          MOVEC.L D0,SFC
          MOVE.L  RgDFC(A4),D0
          MOVEC.L D0,DFC
          MOVE.L  RgVBR(A4),D0
          MOVEC.L D0,VBR
          TST     is20(A4)
          BEQ.L   CGgoon
          MOVE.L  RgCACR(A4),D0
          MOVEC.L D0,CACR

          TST     is40(A4)
          BEQ     CGO30ER
          (*+++
          MOVE.L  RgITT0(A4),D0  ; 40er Code
          DC.W    $4E7B,$0004    ; MOVEC   D0,ITT0
          MOVE.L  RgITT1(A4),D0
          DC.W    $4E7B,$0005    ; MOVEC   D0,ITT1
          MOVE.L  RgDTT0(A4),D0
          DC.W    $4E7B,$0006    ; MOVEC   D0,DTT0
          MOVE.L  RgDTT1(A4),D0
          DC.W    $4E7B,$0007    ; MOVEC   D0,DTT1
          MOVE.L  RgPSR(A4),D0
          DC.W    $4E7B,$0805    ; MOVEC   D0,PSR
          MOVE.L  RgTC(A4),D0
          DC.W    $4E7B,$0003    ; MOVEC   D0,TC
          MOVE.L  RgURP(A4),D0
          DC.W    $4E7B,$0806    ; MOVEC   D0,URP
          MOVE.L  RgSRP(A4),D0
          DC.W    $4E7B,$0807    ; MOVEC   D0,SRP
          *)
          DC.W    $F518          ; PFLUSHA
          BRA     CGgoon

!CGO30ER                          ;20er und 30er Code

          MOVE.L  RgCAAR(A4),D0
          MOVEC.L D0,CAAR
          TST     is30(A4)
          BEQ.L   CGgoon

          LEA     RgTT0(A4),A0   ; 30er Code
          DC.W    $F010,$0800    ; PMOVE   (A0),TT0
          LEA     RgTT1(A4),A0
          DC.W    $F010,$0C00    ; PMOVE   (A0),TT1
          MOVE.L  $E0,-(SP)      ; Exeptionpointer #56 sichern
                                 ; PMMU Configuration Exeption
          MOVE.L  SP,A1
          MOVE.W  SR,D0
          LEA     newConfExep(PC),A0
          MOVE.L  A0,$E0
          LEA     CGTC(PC),A2
          LEA     RgTC(A4),A0
          DC.W    $F010,$4000    ; PMOVE   (A0),TC
!CGTC     LEA     CGPSR(PC),A2
          LEA     RgPSR(A4),A0
          DC.W    $F010,$6000    ; PMOVE   (A0),PSR
!CGPSR    LEA     CGCRP(PC),A2
          LEA     RgCRP(A4),A0
          DC.W    $F010,$4D00    ; PMOVE   (A0),CRP
!CGCRP    LEA     CGSRP(PC),A2
          LEA     RgSRP(A4),A0
          DC.W    $F010,$4900    ; PMOVE   (A0),SRP
!CGSRP    MOVE.L  (SP)+,$E0
          MOVE.W  D0,SR
          DC.W    $F010,$2400    ; PFLUSHA
!CGgoon
          TST     isFPU(A4)
          BEQ     CGgoon1
          TST     is40(A4)
          BNE     CGgotoFPU1
          LEA     StFrame(A4),A0
          TST.B   (A0)           ; Null State Frame?
          BEQ     CGgotoFPU1     ; ja, dann nix mehr
          MOVE.W  (A0),D0
          ANDI.W  #$F,D0
          CMPI.W  #8,D0          ; Idle State Frame?
          BNE     CGgotoFPU1     ; nein, dann nix mehr
          CLR.L   D0
          MOVE.B  1(A0),D0
          BSET    #3,(A0,D0.w)   ; Bit 27 des BIU setzen
!CGgotoFPU1
          (*+++
          FMOVEM.X  RgFP0(A4),FP0-FP7
          FMOVEM.L  RgFPCR(A4),FPCR/FPSR/FPIAR
          TST.B     (A0)           ; Null State Frame?
          BEQ       CGgoon1        ; dann nicht sichern!
          FRESTORE  (A0)
          *)

!CGgoon1  BSR     TMonLeave
          MOVE.L  RgUSP(A4),A0
          MOVE.L  A0,USP
          TST     is20(A4)
          BEQ     CGgoon20
          MOVE.L  RgISP(A4),A7
          MOVE.L  RgMSP(A4),A6
          MOVEC.L A6,MSP
          BRA.S   CGgoon2
!CGgoon20 MOVE.L  RgSSP(A4),A7
!CGgoon2  TST.W   StkFrm(A4)
          BEQ     noSFload
          BTST    #4,RgSR(A4)     ; Test auf M-Bit in RgSR
          BEQ     ISFload
          MOVE.W  SR,D0
          BTST    #12,D0          ; Test auf M-Bit jetzt
          BNE     ISFload         ; gleicher Stapel => kein Format 1
          MOVE    #$0010,-(A6)
          MOVE.L  RgPC(A4),-(A6)
          MOVE.W  RgSR(A4),-(A6)
          MOVEC.L A6,MSP
          MOVE    #$1010,-(A7)
          BRA.S   noSFload
!ISFload  MOVE    #$0010,-(A7)    ; Stackframe von Ill.Instr. laden
!noSFload MOVE.L  RgPC(A4),-(A7)
          MOVE.W  RgSR(A4),-(A7)
(*$ ? ExtendedKeys:
          sf      LockFlag(A4)
*)
          MOVEM.L RgD0(A4),D0-A6
          RTE

!newConfExep
          MOVE.L  A1,SP
          JMP     (A2)

!CGoTerm  CLR.W   EntryMod(A4)
          ANDI    #00100001%,D7
          MOVE.B  D7,TrcStat(A4)
          BRA     CMDBEGOM


!TSTBP    CLR.W   D0
          LEA     BP(A4),A0
          MOVE.L  RgPC(A4),D2
!TSTBPL   CMP.L   (A0)+,D2
          BEQ.S   TSTBPE
          ADDQ.W  #1,D0
          CMPI.W  #BPanz,D0
          BNE     TSTBPL
          RTS
!TSTBPE   CMPI.W  #BPanz,D0
          RTS

!TstShBP  MOVE    ShBPcnt(A4),D0
          LEA     ShBP(A4),A0
          MOVE.L  RgPC(A4),D2
          BRA     tbpc0
!tbpl0    CMP.L   (A0)+,D2
!tbpc0    DBEQ    D0,tbpl0
!tbpe0    RTS

; TRACE - ENTRY

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyTRC    ; REG. SAVEN (PullRegs)
          ORI     #$700,SR
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Trace_Bit,D0
          BSR.w   do_debug
          MOVE.L  (SP)+,D0
*)
          PEA     (A4)
          MOVEA.L LocVarP(PC),A4
          ST      MonActive(A4)
          MOVEM.L D0-A6,RgD0(A4)
          MOVE.L  (A7)+,RgA4(A4)
          MOVE.W  (A7)+,RgSR(A4)      ; SR VON STACK
          MOVE.L  (A7)+,RgPC(A4)      ; EXCEPTION-RETURN-ADR. VON STACK
          BSR.W   TMonEnter

          TST     is10(A4)
          BEQ.L   EyTRCLab01
          MOVEC.L SFC,D0
          MOVE.L  D0,RgSFC(A4)
          MOVEC.L DFC,D0
          MOVE.L  D0,RgDFC(A4)
          MOVEC.L VBR,D0
          MOVE.L  D0,RgVBR(A4)
          TST     is20(A4)
          BEQ.L   EyTRCLab01
          MOVEC.L CACR,D0
          MOVE.L  D0,RgCACR(A4)
          TST     is40(A4)
          BEQ     EyTRCLab20er
                                 ; 40er Code
          DC.W    $4E7A,$0003    ; MOVEC   TC,D0
          MOVE.L  D0,RgTC(A4)
          DC.W    $4E7A,$0004    ; MOVEC   ITT0,D0
          MOVE.L  D0,RgITT0(A4)
          DC.W    $4E7A,$0005    ; MOVEC   ITT1,D0
          MOVE.L  D0,RgITT1(A4)
          DC.W    $4E7A,$0006    ; MOVEC   DTT0,D0
          MOVE.L  D0,RgDTT0(A4)
          DC.W    $4E7B,$0007    ; MOVEC   DTT1,D0
          MOVE.L  D0,RgDTT1(A4)
          DC.W    $4E7A,$0805    ; MOVEC   PSR,D0
          MOVE.L  D0,RgPSR(A4)
          DC.W    $4E7A,$0806    ; MOVEC   URP,D0
          MOVE.L  D0,RgURP(A4)
          DC.W    $4E7A,$0807    ; MOVEC   SRP,D0
          BRA     EyTRCLab

!EyTRCLab20er
          MOVEC.L CAAR,D0        ; 20er und 30er Code
          MOVE.L  D0,RgCAAR(A4)

          TST     is30(A4)
          BEQ     EyTRCLab
!EyTRCLab30er                    ; 30er Code
          LEA     RgTT0(A4),A0
          DC.W    $F010,$0A00    ; PMOVE   TT0,(A0)
          LEA     RgTT1(A4),A0
          DC.W    $F010,$0E00    ; PMOVE   TT1,(A0)
          LEA     RgTC(A4),A0
          DC.W    $F010,$4200    ; PMOVE   TC,(A0)
          LEA     RgPSR(A4),A0
          DC.W    $F010,$6200    ; PMOVE   PSR,(A0)
          LEA     RgCRP(A4),A0
          DC.W    $F010,$4E00    ; PMOVE   CRP,(A0)
          LEA     RgSRP(A4),A0
          DC.W    $F010,$4A00    ; PMOVE   SRP,(A0)
          BSR.L   TMon_address_translation_tree

!EyTRCLab TST     isFPU(A4)
          BEQ     EyTRCLab01
          LEA     StFrame(A4),A0
          FSAVE   (A0)
          FMOVEM.L  FPCR/FPSR/FPIAR,RgFPCR(A4)
          CLR.L   D0
          MOVE.W  TMonFPCR(PC),D0
          FMOVE.L D0,FPCR
          FMOVEM.X  FP0-FP7,RgFP0(A4)
!EyTRCLab01
          TST.W   is10(A4)
          BEQ     not20_2
          MOVE.W  (A7)+,RgSF(A4)
          TST.W   is20(A4)
          BEQ     not20_2
          MOVE.L  (A7)+,D0            ; die Instruction Adress verwerfen wir
          MOVEC.L MSP,D0
          MOVE.L  D0,RgMSP(A4)
          MOVEC.L ISP,D0
          MOVE.L  D0,RgISP(A4)
          MOVE.W  RgSF(A4),D0         ; Stack Frame Word holen
          ANDI.W  #$F000,D0
          CMPI.W  #$1000,D0           ; Throwaway Exeption Stack Frame?
          BNE     is20_2
          ADDQ.L  #4,A7
          MOVE.L  A7,RgISP(A4)        ; der ISP ist jetzt richtig abgerÑumt
          MOVE.L  RgMSP(A4),A0
          MOVE.W  (A0)+,RgSR(A4)
          MOVE.L  (A0)+,RgPC(A4)
          MOVE.W  (A0)+,RgSF(A4)
          ADDA.W  #4,A0               ; Rest wegschmeiûen
          MOVE.L  A0,RgMSP(A4)
          BRA.S   is20_2
!not20_2  CLR.B   RgPC(A4)
!is20_2   MOVE.L  A7,RgSSP(A4)        ; SP SAVEN
          MOVE.L  USP,A0
          MOVE.L  A0,RgUSP(A4)
          MOVE.L  MonStackHi(A4),A7
          BSR     SetMon
          TST.B   BPstat(A4)
          BEQ     eytr0
          BSR.L   ResetBPs        ; BPs RöCKSETZEN
!eytr0
          MOVE.B  TrcStat(A4),D7  ; TRACE AKTIV ?
          BNE.S   TRCC1           ; JA

          BCLR    #7,RgSR(A4)     ; Tracebit im SR lîschen und Prg. wieder
          BCLR    #6,RgSR(A4)
          BRA     CGo             ; starten

; Upro f. EyRTU & EyDirC: holt RTS-Wert vom Programm-SP nach PC

!pullPC   BSR.W   TMonEnter
          BTST    #5,RgSR(A4)
          BEQ     EyRTUC1
          MOVE.L  RgSSP(A4),A0
          ADDQ.L  #4,RgSSP(A4)
          TST     is20(A4)
          BEQ     EyRTUC2
          BTST    #4,RgSR(A4)
          BNE     pullPCm
          MOVE.L  RgISP(A4),A0
          ADDQ.L  #4,RgISP(A4)
          BRA     EyRTUC2
!pullPCm  MOVE.L  RgMSP(A4),A0
          ADDQ.L  #4,RgMSP(A4)
          BRA     EyRTUC2
!EyRTUC1  MOVE.L  RgUSP(A4),A0
          ADDQ.L  #4,RgUSP(A4)
!EyRTUC2  MOVE.L  (A0),RgPC(A4)
          TST.W   is20(A4)
          BNE     is20_3
          CLR.B   RgPC(A4)
!is20_3   RTS

;                                RöCKKEHR V. 'R' - FUNKTION OHNE TRACE

!EyRTU    BREAK                 ; damit kommen wir in den Supervisormode
!EyRTUC0  BSR     pullPC
          BSR     SetTraceBit     ; TRACE-BIT IM SR WIEDER SETZEN
          MOVE.B  TrcStat(A4),D7
          BCLR    #1,D7           ; REG.ANZ. EINSCHALTEN

!TRCC1    BTST    #6,D7           ; TRACE-FLAG WIEDER LOESCHEN ?
          BEQ.S   TRCC0           ; NEIN
          BCLR    #7,RgSR(A4)     ; TRACE-FLAG LOESCHEN
          BCLR    #6,RgSR(A4)

!TRCC0    LEA     EyRTN(PC),A5
          CMPA.L  RgPC(A4),A5     ; ERFOLGTE RTS AUF EyRTN ?
          BEQ.L   EyRTNE0         ; JA: ZUR CMD-EINGABE

          BTST    #2,D7           ; TEST AUF CTRL-BREAK
          BNE.L   EntKbdE1

          MOVE.L  UsrBP(A4),D0    ; USER-BP(A4) VECTOR LADEN
          BEQ.S   TRCC4           ; öBERSPRINGEN,WENN NICHT INITIALISIERT

          BTST    #5,RgSR(A4)     ; Supervisor Modus?
          BEQ     TRCC6C0
          TST     is20(A4)
          BNE     TrcC6C01
          MOVE.L  RgSSP(A4),RgA7(A4)
          BRA     TrcC6C1
!TrcC6C01 BTST    #4,RgSR(A4)     ; Master Modus?
          BNE     TrcC6C02
          MOVE.L  RgISP(A4),RgA7(A4)
          BRA     TrcC6C1
!TrcC6C02 MOVE.L  RgMSP(A4),RgA7(A4)
          BRA     TrcC6C1
!TrcC6C0  MOVE.L  RgUSP(A4),RgA7(A4)
!TrcC6C1  LEA     REGBEG(A4),A0   ; REGISTER-POINTER NACH A0 LADEN
          MOVEA.L D0,A1
          BSR.L   WhichCPU
          MOVE.L  D1,D0
          MOVEM.L D7/A4,-(SP)
          JSR     (A1)
          MOVEM.L (SP)+,D7/A4
          TST.B   D0
          BEQ     TRCC4

          LEA     UsrBPMsg(PC),A1
          BRA     CMDBEG

!TRCC4    BCLR    #4,D7           ; REG.-ANZEIGE WIEDER EINSCHALTEN ?
          BEQ     TRCGO           ; NEIN
          BCLR    #1,D7           ; JA

!TRCGO    BSR.L   TstShBP         ; Short BP erreicht ?
          BNE     TrcGo00         ; Nein

TrcC50    BCLR    #1,D7           ; Anzeige wieder an
          BCLR    #5,D7           ; TRACE-FLAG wieder an ?
          BEQ.S   TRCC51          ; nein
          BSR     SetTraceBit     ; TRACE-FLAG setzen
!TRCC51   ; ResetShortBP wird automatisch bei TrcCtrl aufgerufen
          LEA     BPMSG(PC),A1
          TST.B   TrcStat(A4)
          BEQ     CMDBEG

!TrcGo00  TST.B   BPset(A4)
          BEQ     TrcC6
          BSR.L   TSTBP           ; TEST AUF BP:
          BEQ     TRCC6           ; Nein

!TRCC5    SUBQ.L  #4,A0           ; A0 auf BP-Vektor setzen
          SUBQ.W  #1,BPanz+BPanz+BPanz+BPanz+2(A0) ; ZAEHLER UM 1 VERMINDERN
          BNE.S   TRCC9
          ; ZAEHLER ABGELAUFEN: WIEDER NEU SETZEN
          MOVE.W  BPanz+BPanz+BPanz+BPanz(A0),BPanz+BPanz+BPanz+BPanz+2(A0)
          MOVE.W  D0,EntryNr(A4)
          LEA     BPNMSG(PC),A1
          MOVE.B  #2,EntryMod(A4)
          BRA.L   CMDBEGOC        ; ZUR CMD-EINGABE

!TRCC9    ; diese Instr. im Tracemode ohne Anzg. ausfÅhren, falls kein Trace
          BSET    #6,D7           ; T-FLAG setzen und beim FOLG. BEF. LOESCHEN
          BRA     TrcC60

!TRCC6    BCLR    #6,D7           ; WURDE TRACE-FLAG GELOESCHT ?
          BNE     CGO             ; JA

!TRCC60   BTST    #3,D7           ; AUF RTS TESTEN ?
          BEQ.S   TRCC3           ; NEIN

          BTST    #5,RgSR(A4)
          BNE     Trc70
          LEA     RgUSP(A4),A0
          BRA     Trc71
!Trc70    LEA     RgSSP(A4),A0
          TST     is20(A4)
          BEQ.S   Trc71
          LEA     RgISP(A4),A0
          BTST    #4,RgSR(A4)
          BEQ.S   Trc71
          LEA     RgMSP(A4),A0
!Trc71    MOVE.L  TrcSvSP(A4),D0
          CMP.L   (A0),D0         ; STIMMT SP ?
          BHI.S   TRCC3           ; NEIN: NOCH NICHT TESTEN
          MOVEA.L RgPC(A4),A0
          CMPI.W  #BEFRTS,(A0)    ; NAECHSTER BEF. 'RTS' ?
          BEQ.S   TRCC7
          CMPI.W  #BEFRTR,(A0)    ; NAECHSTER BEF. 'RTR' ?
          BEQ.S   TRCC7
          CMPI.W  #BEFRTE,(A0)    ; NAECHSTER BEF. 'RTE' ?
          BNE.S   TRCC3
!TRCC7    BSET    #4,D7           ; : AB NAECHSTEN BEF. WIEDER ANZEIGE EIN !
          BCLR    #3,D7

!TRCC3    BTST    #1,D7           ; REG. ANZEIGEN ?
          BNE     CGO             ; NEIN: BEF. SOFORT AUSFöHREN

!TrcCtrl  ; Trace Kommando Eingabe
          BCLR    #5,D7
          ST      BPquest(A4)     ; Errors bei SetBPs anzeigen
          BCLR    #0,ShBPFlg(A4)
          BNE     TrcCtrlL0       ; ShBPs wurden gerade bei 'G' gesetzt
          BSR.L   ResetShortBPs
!TrcCtrlL0 MOVE.W  D7,-(A7)
          CLR.L   D7
          BTST    #11-8,(A7)
          BEQ     TrcCtC0
          BSET    #11,D7
!TrcCtC0  MOVE.L  RegWahl(A4),D4
          BCLR    #TNRPC,D4       ; PC VON WAHL AUSSCHLIESSEN
          MOVE.L  RegWahl2(A4),D5
          BSR.L   CRU             ; REG. OHNE PC ANZEIGEN
          MOVEA.L RgPC(A4),A2
          BSR.L   DISASMLNTrace   ; DISASSEMBLIERE FOLG. BEFEHL
          MOVE.L  A2,D6
          MOVE.L  A2,A3
          BSR     PrtCRLF
          MOVE.W  (A7)+,D7
          BCLR    #11,D7

(*$? ~MAC:
          MOVE    SR,D1
          MOVE.W  D1,D0
          ANDI.W  #$0700,D0
          CMPI.W  #$0600,D0
          BCS     TRCMONSCRNON
          ANDI.W  #$FDFF,D1
          OR.W    IRMask(PC),D1
          MOVE    D1,SR
!TRCMONSCRNON
          BSR     CheckKeyBoard
*)
          BSR     MonScrn         ; Monitor-Screen einschalten

!TRCCTC1
          BTST    #6,TRCSTAT2(A4) ; Animate ?
          BEQ     TRCCTC1_11      ; Nein!
          BSR     CONSTAT         ; Taste in Puffer?
          TST.L   D0
          BEQ     CGO             ; nein, dann weiter animieren
!TRCCTC1_11
          BSR.L   WAITKEY
          BSR.L   CAPS
          BCLR    #6,TRCSTAT2(A4)
          BEQ     TRCCTC1_12
          CMPI.B  #SPC,D0
          BEQ     TRCCTC1_11
!TRCCTC1_12
          CMPI.B  #'C',D0
          BNE     TRCCTC11_3
          BSET    #6,TRCSTAT2(A4)
          BRA     CGO
!TRCCTC11_3
          CMPI.B  #ESCkey,D0
          BEQ     CMDBEGOM        ; ZUR EINGABE OHNE MSG.-AUSGABE

          CMPI.B  #'0',D0
          BNE.S   TRCCTC2

          BCLR    #7,RgSR(A4)     ; Lîsche TRACE-BIT IM SR
          BCLR    #6,RgSR(A4)

!TRCCTC20 BSET    #8,D7           ; nur T-Flag anzeigen
          BSR     PrtSRbin
          BSR     PrtCRLF
          BRA     TrcCtC1         ; UND WEITER AUF EINGABE WARTEN

!TRCCTC2  CMPI.B  #'1',D0
          BNE.S   TRCCTC22

          BSR     SetTraceBit     ; Setze TRACE-BIT IM SR
          BRA     TrcCtC20

!TRCCTC22 CMPI.B  #'F',D0
          BNE.S   TRCCTC21

          BCLR    #7,RgSR(A4)     ; Lîsche TRACE-BIT IM SR
          BCLR    #6,RgSR(A4)
          BSET    #5,D7           ; bei RÅckkehr wieder T-Bit im SR setzen
          BRA     CGO             ; und weiter (wie mit SPACE)

!TRCCTC21 CMPI.B  #'R',D0         ; OHNE TRACE BIS RTS ?
          BNE.L   TRCCTC4

          TST.B   RgSR(A4)        ; JA: TRACE-BIT IM SR GESETZT ?
          BMI.S   TRCCTC3         ; JA: MERKEN UND ANZGE. AUS BIS 'RTS'
          BTST    #6,RgSR(A4)
          BNE.S   TRCCTC3

          ; NEIN: STACKPOINTER LADEN
          BTST    #5,RgSR(A4)
          BNE     Trc72
          LEA     RgUSP(A4),A1
          BRA     Trc73
!Trc72    LEA     RgSSP(A4),A1
          TST     is20(A4)
          BEQ     Trc73
          LEA     RgISP(A4),A1
          BTST    #4,RgSR(A4)
          BEQ     Trc73
          LEA     RgMSP(A4),A1
!Trc73    MOVEA.L (A1),A0
          LEA     EyRTU(PC),A5
          MOVE.L  A5,-(A0)        ; RETURN ADR. AUF STACK
          MOVE.L  A0,(A1)         ; NEUEN SP WIEDER SPEICHERN
          BRA     CGO             ; PRG. AUFRUFEN

!TRCCTC3  BSET    #3,D7           ; : ANZEIGE AUS BIS RTS
          BTST    #5,RgSR(A4)
          BNE     Trc74
          MOVE.L  RgUSP(A4),TrcSvSP(A4)  ; SP MERKEN
          BRA     Trc75
!Trc74    MOVE.L  RgSSP(A4),TrcSvSP(A4)  ; SP MERKEN
          TST     is20(A4)
          BEQ     Trc75
          MOVE.L  RgISP(A4),TrcSvSP(A4)
          BTST    #4,RgSR(A4)
          BEQ     Trc75
          MOVE.L  RgMSP(A4),TrcSvSP(A4)
!Trc75                                   ; REG.-ANZEIGE AUS UND GO :

!TRCCTC5  BSET    #1,D7           ; REG.ANZ. AUSSCHALTEN
          BRA     CGO

!TRCCTC4  CMPI.B  #'O',D0         ; ANZEIGE AUS ?
          BEQ     TRCCTC5

!TRCCTC6  CMPI.B  #' ',D0         ; WEITER TRACEN ?
          BEQ     CGO

!TRCCTC7  CMPI.B  #'A',D0         ; Alles ohne Anzeige tracen ?
          BNE     TRCCTC9

          BSET    #7,D7
          BRA     TrcCtC5

!TRCCTC9  CMPI.B  #'D',D0         ; Dism next ?
          BNE     TRCCTC11
(*
          CLR.W   DCursorX(A4)
          MOVEQ   #PROMPT,D0
          BSR.L   DPrt
          MOVEQ   #',',D0
          BSR.L   DPrt
*)
          MOVE.L  D6,A2
          BSR.L   DoDISASMLN1
          BSR.L   DISASMTrace     ; DISASSEMBLIERE FOLG. BEFEHL
          MOVE.L  A2,D6

          BSR     PrtCRLF
          BRA     TrcCtC1

!TRCCTC11 CMPI.B  #'S',D0         ; Skip next ?
          BNE     TRCCTC10

          MOVE.L  A3,RgPC(A4)
          LEA     SkipMsg(PC),A1
          BSR     PrtStr
          BRA     TrcCtrlL0

!TRCCTC10 CMPI.B  #'B',D0         ; Breakpoint setzen ?
          BNE     TRCCTC1

          MOVE.L  D6,D1
          BSR     InitShortBP
          BEQ     TrcCtC1
          LEA     ShBPMsg(PC),A1
          BSR     PrtStr
          MOVE.L  D6,D0
          BSR     PrtLong
          BSR     PrtCRLF
          BRA     TRCCTC1

!InitShortBP
          MOVE    ShBPcnt(A4),D0
          CMPI    #ShBPanz,D0
          BEQ     initshbpe
          LEA     ShBP(A4),A0
          LSL     #2,D0
          MOVE.L  D1,0(A0,D0.W)
          ADDQ.W  #1,ShBPcnt(A4)
!initshbpe RTS


!SBrkErr  BSR     TestMMUBusError
          MOVE.L  A3,A7
          MOVE.W  D5,SR
          BRA     SBRKER2

!SetBRK   MOVE.W  (A1),(A2)
          MOVE.W  #BEFBRK,(A1)
          CMPI.W  #BEFBRK,(A1)
          BNE     SBrkEr2
          BSET    D4,D3
          RTS
!SBrkEr2  TST.B   BPquest(A4)
          BEQ     SBrkEr3
          MOVE    D0,-(A7)
          PEA     (A1)
          LEA     BPErrMsg(PC),A1
          BSR     PrtStr
          MOVE.L  (A7)+,D0
          BSR     PrtAdr
          BSR     PrtCRLF
          MOVE    (A7)+,D0
          MOVEQ   #1,D2
!SBrkEr3  RTS

!SETBPs   MOVE.L  BUSERRV,-(A7)
          MOVE.L  A7,A3
          MOVE.W  SR,D5
          LEA     SBRKErr(PC),A0
          MOVE.L  A0,BUSERRV
          SUBQ.L  #4,D5
          CLR     D2
          CLR     D4
          LEA     BP(A4),A0
          LEA     BPSV(A4),A2
          MOVE.B  BPstat(A4),D3
          BEQ     SBPL1
          MOVE.L  (A7)+,BusErrV
          BRA     Err18           ; Fehler !!! Darf nicht eintreten
!SBPL1    TST.L   (A0)+
          BEQ     SBPC1
          MOVEA.L -4(A0),A1
          BSR     SetBrk
!SBPC1    ADDQ    #2,A2
          ADDQ    #1,D4
          CMPI.B  #BPanz,D4
          BCS     SBPL1
          MOVE.B  D3,BPstat(A4)

          ; SetShBPs
          CLR     D3
          MOVE    ShBPcnt(A4),D0
          BEQ     sshbpe0
          CLR     D4
          LEA     ShBP(A4),A0
          LEA     ShBPsv(A4),A2
          BRA     sshbpc0
!sshbpl0  MOVEA.L (A0)+,A1
          BSR     SetBrk
          ADDQ    #2,A2
          ADDQ    #1,D4
!sshbpc0  DBRA    D0,sshbpl0
!sshbpe0  MOVE    D3,ShBPstat(A4)
          MOVE.L  (A7)+,BusErrV

          TST     D2
          BEQ     SBPTE0
          BSR     MonScrn
          LEA     PressKeyMsg(PC),A1
          BSR     PrtStr
!SBPTL    BSR     WaitKey
          CMP.B   #' ',D0
          BEQ     SBPTE0
          CMP.B   #ESCkey,D0
          BNE     SBPTL
          MOVEQ   #1,D2
!SBPTE0   RTS

!ResetBPs ; A0/D7 mÅssen erhalten bleiben !!!
          CLR.B   D0              ; BP(A4) LOESCHEN,ALTEN WERT WIEDERHERSTELLEN
          LEA     BP(A4),A3
          LEA     BPsv(A4),A2
!RBPL1    BCLR    D0,BPstat(A4)
          BEQ.S   RBPC1
          MOVEA.L (A3),A1
          CMPI.W  #BEFBRK,(A1)    ; STEHT BRK-BEF. NOCH IM SPEICHER ?
          BNE.S   RBPC1           ; NEIN: SPEICHERINHALT NICHT AENDERN
          MOVE.W  (A2),(A1)       ; ALTEN WERT ZURöCKSPEICHERN
!RBPC1    ADDQ.L  #4,A3
          ADDQ.L  #2,A2
          ADDQ.B  #1,D0
          CMPI.B  #BPanz,D0
          BCS     RBPL1
          RTS

!ResetShortBPs ; alle ShortBPs lîschen
          CLR.B   ShBPFlg(A4)
          MOVE    ShBPstat(A4),D3
          BEQ     rbpe0           ; nicht im RAM gesetzt -> OK. und Ende.
          CLR     ShBPstat(A4)
          MOVE    ShBPcnt(A4),D0
          CLR     D2
          LEA     ShBP(A4),A1
          LEA     ShBPsv(A4),A2
          BRA     rbpc2
!rbpl2    BTST    D2,D3
          BEQ     rbpc3           ; BP wurde nicht ins RAM gesetzt
          MOVE.L  (A1),A0         ; Adr. des BP laden
          CMPI.W  #BEFBRK,(A0)    ; STEHT BRK-BEF. NOCH IM SPEICHER ?
          BNE.S   RBPC3           ; NEIN: SPEICHERINHALT NICHT AENDERN
          MOVE.W  (A2),(A0)       ; ALTEN WERT ZURöCKSPEICHERN
!rbpc3    ADDQ    #4,A1
          ADDQ    #2,A2
          ADDQ    #1,D2
!rbpc2    DBRA    D0,rbpl2
!rbpe0    CLR     ShBPcnt(A4)
          RTS

; DISASSEMBLER

!ComdD    CMPI.B  #':',D0
          BEQ     ComdDDopp
          LEA     LastDA(A4),A1
          BCLR    #12,D7          ; nur gerade Adr.
          BSR.L   GETAE
          BPL     ERR4
!CDL1     BSR.L   DISASMLN
          BSR.L   TSTKEY
          BNE     CDE
          BTST    #1,D7
          BNE.S   CDC1
          CMPA.L  A3,A2
          BCS     CDL1
          BRA.S   CDE
!CDC1     SUBQ.L  #1,D3
          BNE     CDL1
!CDE      MOVE.L  A2,LastDE(A4)
          BRA     PrtDCRLF
!CDEE     RTS
!ComdDDopp BSR     GETNGRKL
          BMI     CDEE
          CMPI.B  #'0',D0
          BEQ     CDD0
          CMPI.B  #'1',D0
          BEQ     CDD1
          CMPI.B  #'2',D0
          BEQ     CDD2
          CMPI.B  #'3',D0
          BEQ     CDD3
          CMPI.B  #'4',D0
          BEQ     CDD4
          CMPI.B  #'8',D0
          BEQ     CDD8
          CMPI.B  #'F',D0
          BEQ     CDD8
          BRA     CDEE

!CDDFP    MOVE.W  isFPU(A4),isCDFPU(A4)
!CDDP     CLR.W   isCD10(A4)
          CLR.W   isCD20(A4)
          CLR.W   isCD30(A4)
          CLR.W   isCD40(A4)
          RTS

!CDD0     CLR.W   isCDFPU(A4)
          BRA     CDDP
!CDD1     CLR.W   isCDFPU(A4)
          BSR     CDDP
!CDD10    ST      isCD10(A4)
          RTS
!CDD2     BSR     CDDFP
!CDD20    ST      isCD20(A4)
          BRA     CDD10
!CDD3     BSR     CDDFP
!CDD30    ST      isCD30(A4)
          BRA     CDD20
!CDD4     BSR     CDDP
          ST      isCDFPU(A4)
          ST      isCD40(A4)
          BRA     CDD30
!CDD8     ST      isCDFPU(A4)
          RTS

; FöLL- UND SUCH- FUNKTIONEN

!GETFNDBF BSR.L   SKIPSPC
          BMI     ERR9
          MOVEQ   #-1,D2          ; ZAEHLER F. ANZAHL DER EINGEGEBENEN ZEICHEN
          CLR.L   D3              ; JOKER-MERKER
          LEA     FindBuf(A4),A1  ; ANF. DES BUFFERS F. ZEICHEN
          BSR.L   TSTHZIFF        ; HEX-BYTE-EINGABE ?
          BEQ     GETFBHC0        ; JA
          BSET    #4,D7           ; NEIN: STRING-EINGABE
          MOVE.B  D0,D4           ; DELIMITER MERKEN
          ADDQ.L  #1,A6
          MOVEA.L A6,A5           ; ADRESSE IM COMMAND-STRING MERKEN
!GETFBAL  MOVE.B  (A6)+,D0        ; NAECHSTES ZEICHEN LADEN
          CMP.B   D4,D0           ; 2. DELIMITER ?
          BEQ.S   GETFBE1         ; JA:ENDE
!GETFBHL  CMPI.B  #CR,D0          ; CR ?
          BEQ.S   GETFBE2         ; JA:ENDE
!GETFBHC0 ADDQ.W  #1,D2
          CMPI.B  #32,D2          ; SCHON MEHR ALS 32 ZEICHEN ?
          BEQ     ERR10           ; JA: ERROR
          CMPI.B  #JOKER,D0       ; JOKER ?
          BNE.S   GETFBAC1
          BSET    D2,D3           ; JA: JOKERFLAG SETZEN
          BTST    #4,D7
          BNE     GETFBAL
          ADDQ.L  #1,A6
          BRA.S   GETFBHC2
!GETFBAC1 BTST    #4,D7
          BEQ.S   GETFBHC1
          MOVE.B  D0,0(A1,D2.W)   ; ZEICHEN MERKEN
          BRA.L   GETFBAL
!GETFBHC1 BSR.L   GETLGRKL        ; LETZTES ZEICHEN WIEDER NACH D0
          BSR.L   GETBYTE         ; BYTE-WERT HOLEN
          MOVE.B  D1,0(A1,D2.W)   ; ZEICHEN MERKEN
!GETFBHC2 BSR.L   SKIPSPC
          BRA.L   GETFBHL

!GETFBE1  BSR.L   GETLGRKL        ; FOLGT CR ? NEIN: ERROR
          BPL     ERR4
!GETFBE2  TST.W   D2
          BMI     ERR9            ; ERROR: KEIN ZEICHEN EINGEGEBEN
          RTS

!ComdF    BCLR    #11,D7
          LEA     Hilf1L(A4),A1
          BSET    #12,D7          ; Ungerade Adr. erlaubt
          BSR.L   GETAE           ; HOLE ANF.- UND END - ADR.
          BEQ     ERR11           ; ERROR: BEIDE ADR. ANGEBEN !
          BSR.L   GETFNDBF        ; HOLE SUCH-/ FöLL-STRING
!CFL1     CLR.L   D4              ; ZAEHLER F. STRINGLAENGE
!CFL2     BTST    D4,D3           ; JOKER ?
          BNE.S   CFC1            ; JA: SPEICHERSTELLE NICHT FöLLEN
          MOVE.B  0(A1,D4.W),(A2) ; SPEICHERSTELLE FöLLEN
!CFC1     ADDQ.L  #1,A2
          CMPA.L  A3,A2           ; ENDADR. ERREICHT ?
          BCC.S   CFEND
          ADDQ.W  #1,D4
          CMP.W   D2,D4           ; GANZER STRING GESPEICHERT ?
          BLS     CFL2            ; NEIN: NAECHSTES ZEICHEN
          BRA.L   CFL1            ; JA: MIT STRING WIEDER VON VORN BEGINNEN

!CFEND    RTS

; "ES"
!ComdE    BMI     ERR0
          CMPI.B  #'S',D0
          BNE     Err0
(*$? MAC:
          BSR     NormScrn        ; Monitor-Screen ausschalten
          BSR.W   mode_mac
          move.l  originalA5(A4),a5
          move.l  originalA7(A4),a7
          dc.w    $a9f4         ; _ExitToShell
*)
          bra     Err0

; "Q"
!ComdQ    BPL     ERR4
          TST.B   SysMonCall(A4)  ; Quit nicht zulÑssig, wenn von SysMon aufgerufen
          BNE.L   to_CookieRoutine10Return
          BSR.L   PrntClose
          BSR.L   kill_repeat
          BSR     RestoreKeyBoard
          BSR     ResetMon        ; VECTOREN WIEDERHERSTELLEN
          TST.W   ResetDebug(A4)
          BEQ     CQE01
          MOVEQ   #0,D0
          MOVEQ   #0,D1
          BSR.L   InitVec
          CLR.W   ResetDebug(A4)
!CQE01    BSR     NormScrn        ; Monitor-Screen ausschalten
          BSR     ClrBPs          ; BPs lîschen
          BSR     TMonLeave
(*
          MOVE.L  RgUSP(A4),A0
          MOVE.L  A0,USP
*)
          MOVE.L  A7,USP          ; Bei Quit wird Mon-SP verwendet, damit
                                  ; nicht evtl. Buserror, wenn Orig-SP defekt
          MOVE.L  RgSSP(A4),A7    ; SSP und USP dÅrfen sich nicht Åberlagern!

          MOVE.W  RgSR(A4),D0
          ANDI    #$38FF,D0       ; IR-Level auf 3, Trace aus
(*$? ~MAC:
          ORI     #$0300,D0
*)
          MOVE.W  D0,SR

          ; TERM:

(*$ ? ExtendedKeys:
          sf      LockFlag(A4)
*)
          MOVE.W  #-1,-(A7)
          MOVE.W  #$4C,-(A7)
          TRAP    #1
          ; hier geht's weiter, wenn TERM nicht ging:
          BSR     MonScrn
          BSR     CheckKeyBoard
          BRA     CmdLoop

; "&"
!ComdDEZ  MOVE.L  #$FFFFFFF,D6
          CLR.L   D1
          BSR.L   GETDEZ
          BPL     ERR4
          BCLR    #11,D7
          MOVEQ   #'=',D0
          BSR     Prt
          MOVE.L  D1,D0
          BSR     PrtLONG
          BRA     PrtCRLF

; ADRESS / BUS-ERROR ENTRY

!STOEADR  MOVE.L  A4,-(A7)
          MOVEA.L LocVarP(PC),A4
          ST      MonActive(A4)
          MOVEM.L D0-A6,RgD0(A4)
          MOVE.L  (A7)+,RgA4(A4)
          BSR     TMonEnter

          TST     is10(A4)
          BEQ.L   STOEgoon01
          MOVEC.L SFC,D0
          MOVE.L  D0,RgSFC(A4)
          MOVEC.L DFC,D0
          MOVE.L  D0,RgDFC(A4)
          MOVEC.L VBR,D0
          MOVE.L  D0,RgVBR(A4)
          TST     is20(A4)
          BEQ.L   STOEgoon01
          MOVEC.L CACR,D0
          MOVE.L  D0,RgCACR(A4)
          TST     is40(A4)
          BEQ     STOEgoon20er
                                 ; 40er Code
          DC.W    $4E7A,$0003    ; MOVEC   TC,D0
          MOVE.L  D0,RgTC(A4)
          DC.W    $4E7A,$0004    ; MOVEC   ITT0,D0
          MOVE.L  D0,RgITT0(A4)
          DC.W    $4E7A,$0005    ; MOVEC   ITT1,D0
          MOVE.L  D0,RgITT1(A4)
          DC.W    $4E7A,$0006    ; MOVEC   DTT0,D0
          MOVE.L  D0,RgDTT0(A4)
          DC.W    $4E7B,$0007    ; MOVEC   DTT1,D0
          MOVE.L  D0,RgDTT1(A4)
          DC.W    $4E7A,$0805    ; MOVEC   PSR,D0
          MOVE.L  D0,RgPSR(A4)
          DC.W    $4E7A,$0806    ; MOVEC   URP,D0
          MOVE.L  D0,RgURP(A4)
          DC.W    $4E7A,$0807    ; MOVEC   SRP,D0
          BRA     STOEgoon

!STOEgoon20er
          MOVEC.L CAAR,D0        ; 20er und 30er Code
          MOVE.L  D0,RgCAAR(A4)

          TST     is30(A4)
          BEQ     STOEgoon
!STOEgoon30er                     ; 30er Code
          LEA     RgTT0(A4),A0
          DC.W    $F010,$0A00    ; PMOVE   TT0,(A0)
          LEA     RgTT1(A4),A0
          DC.W    $F010,$0E00    ; PMOVE   TT1,(A0)
          LEA     RgTC(A4),A0
          DC.W    $F010,$4200    ; PMOVE   TC,(A0)
          LEA     RgPSR(A4),A0
          DC.W    $F010,$6200    ; PMOVE   PSR,(A0)
          LEA     RgCRP(A4),A0
          DC.W    $F010,$4E00    ; PMOVE   CRP,(A0)
          LEA     RgSRP(A4),A0
          DC.W    $F010,$4A00    ; PMOVE   SRP,(A0)
          BSR.L   TMon_address_translation_tree

!STOEgoon TST     isFPU(A4)
          BEQ     STOEgoon01
          LEA     StFrame(A4),A0
          FSAVE   (A0)
        FMOVEM.L  FPCR/FPSR/FPIAR,RgFPCR(A4)
          CLR.L   D0
          MOVE.W  TMonFPCR(PC),D0
          FMOVE.L D0,FPCR
        FMOVEM.X  FP0-FP7,RgFP0(A4)


!STOEgoon01
          BSR     SetMon

          MOVEA.L (A7)+,A3        ; RTS-ADR. V. STACK HOLEN
          BSR.L   PULLEADR        ; SR,PC V. STACK HOLEN

          MOVE.L  A7,RgSSP(A4)    ; STACKPOINTER ABSPEICHERN
          MOVE.L  USP,A0
          MOVE.L  A0,RgUSP(A4)
          TST     is20(A4)
          BEQ     STOEgoon1
          MOVEC.L MSP,D0
          MOVE.L  D0,RgMSP(A4)
          MOVEC.L ISP,D0
          MOVE.L  D0,RgISP(A4)
!STOEgoon1
          MOVE.L  MonStackHi(A4),A7
          MOVE.W  D2,RgSF(A4)
          MOVE.L  D1,ErrAdr(A4)   ; ERROR-ADR. SPEICHERN
          MOVE.W  D6,SupSR(A4)    ; SUPER-STATUS-WORT SPEICHERN
          MOVE.W  D4,ErrBef(A4)   ; BEF.-CODE SPEICHERN
          MOVE.W  D5,RgSR(A4)     ; SR ABSPEICHERN
          ; BEF.WORT VOR PC-ADR. SUCHEN:
          TST     StkFrm(A4)
          BNE     STOEC2          ; bei 68020 nicht suchen
          MOVEQ   #-2,D0
!STOEL1   CMP.W   0(A5,D0.W),D4   ; VERGL. BEF.-CODE  A5: PC
          BEQ     STOEC1
          SUBQ.W  #2,D0
          CMPI.W  #-10,D0         ; SCHON MEHR ALS 10 BYTE ZURöCK ?
          BCC     STOEL1          ; NEIN: WEITER SUCHEN
          BRA     STOEC2          ; JA: BEF.-CODE NICHT GEFUNDEN
!STOEC1   ADDA.W  D0,A5
!STOEC2   MOVE.L  A5,RgPC(A4)     ; PC ABSPEICHERN
          TST.W   is20(A4)
          BNE     is20_4
          CLR.B   RgPC(A4)
!is20_4
          MOVE.B  #5,EntryMod(A4) ; 'Exception :' ausgeben
          JMP     (A3)            ; RTS


!teststatus DC.L   0

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
!EyBUSold DC.L    0
!EyBUS    ORI     #$700,SR
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Buserror_Bit,D0
          BSR.w   do_debug
          MOVE.L  (SP)+,D0 *)
          BSR     TestMMUBusError
          BSR     STOEADR
;         TST.L   MMUMSG(A4)
;         BEQ     EyBUS1
;         BSR     PrtCRLF
;         MOVE.L  MMUMSG(A4),A1
;         BSR     PrtSTR
;         MOVE.W  TestMMUTemp(A4),D0
;         BSR     PrtWORD
;!EyBUS1
          MOVE    #2,ExcNo(A4)
          LEA     BEMSG(PC),A1
          BRA     CMDBEGOC

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyADR    ORI     #$700,SR
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Adresserror_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR     STOEADR
          MOVE    #3,ExcNo(A4)
          LEA     AEMSG(PC),A1
          BRA     CMDBEGOC

!GetTMonFPCR
          MOVE.W  TMonFPCR(PC),D0
          RTS

; ILLEGAL CMD - ENTRY ( VEKTORNR.4 )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyILL
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Illegal_Instruction_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0
*)
          BSR.L   PULLREGS
          MOVEA.L RgPC(A4),A0
          CMPI.W  #BEFBRK,(A0)    ; WAR ILL.BEF. BREAK-BEFEHL ?
          BEQ     EILLBRK         ; JA
          LEA     ILLMSG(PC),A1
          BRA     CMDBEGOC

!EILLBRK  BSR.L   ResetBPs         ; BPs RöCKSETZEN
          LEA     EyRTN(PC),A1
          CMPA.L  A0,A1           ; Aufruf von EyRTN ?
          BEQ     EyRTNC0         ; JA
          LEA     EyRTU(PC),A1
          CMPA.L  A0,A1           ; Aufruf von EyRTU ?
          BEQ     EyRTUC0         ; JA
          LEA     EyDirC(PC),A1
          CMPA.L  A0,A1           ; Aufruf von EyDirC ?
          BEQ     EyDirCCo        ; JA

          MOVE.B  TrcStat(A4),D7
          BSET    #1,D7           ; Anzg. aus
          BSR     TSTBP           ; TEST AUF BP:
          BNE     TRCC5           ; Ja

          BSR     TstShBP         ; Short BP erreicht ?
          BEQ     TrcC50          ; ja

          ADDQ.L  #2,RgPC(A4)     ; PC HINTER BRK-BEF. SETZEN
          LEA     BRKMSG(PC),A1   ; ZUM WARMSTART
          BRA     CMDBEG

; Direct call entry (via $64, IRQ 1)

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyDirC   BREAK
!EyDirCCo BSR     pullPC
          LEA     DirCMSG(PC),A1
          BRA     CMDBEG

; Uninitialized Interrupt - Entry ( Vectornr.$15 )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyUNININT
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Uninitialized_Interrupt_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       UNINMSG(PC),A1
          BRA.L     EntryC0

; MMU Configuration Error - Entry ( Vectornr.$E0 )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyMMUCONF
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #MMU_Configuration_Error_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       MMUCONFMSG(PC),A1
          BRA.L     EntryC0

; Coprocessor Protocol Error - Entry ( Vectornr.$34 )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyCOPPRO
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Coprocessor_Protocol_Error_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          MOVEM.L D0/A4,-(SP)
          DC.W    $4E7A,$0000               ; MOVEC   SFC,D0
          MOVE.L  D0,-(SP)
          MOVEQ   #7,D0
          DC.W    $4E7B,$0000               ; MOVEC   D0,SFC
          DC.W    $0E79,$0000,$0002,$2000   ; MOVES.W $00022000,D0
          MOVEA.L LocVarP(PC),A4            ; Pointer fÅr lokale Variablen
          MOVE.W  D0,Response(A4)
          MOVE.L  (SP)+,D0
          DC.W    $4E7B,$0000               ; MOVEC   D0,SFC
          MOVEM.L (SP)+,D0/A4

          BSR.L     PULLREGS
          TST.W     Response(A4)
          BEQ       COPROVIOLA
          LEA       COPPROMsg(PC),A1
          BRA       EntryC0
!COPROVIOLA
          LEA       COPPROMsg2(PC),A1
          BRA       EntryC0

; Frame Error - Entry ( Vectornr.$38 )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyFrm
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Format_Error_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L   PULLREGS
          LEA     FrmErMSG(PC),A1
          BRA.L   CMDBEGOC

; Illegal Interrupt - Entry ( Vectornr.$18 )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyILLIRQ
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Spurios_Interrupt_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L   PULLREGS
          LEA     ILLIMSG(PC),A1
!EntryC0  BRA.L   CMDBEGOC

; Interrupt - Entry ( Vectornr.$19-$1F )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyIRQ
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Spurios_Interrupt_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0
*)
(*$? Mac:
          MOVE.L  A4,-(A7)
          MOVEA.L LocVarP(PC),A4
          TST.B   MonActive(A4)
          MOVE.L  (A7)+,A4
          BNE     doRTE
*)
          BSR.L   PULLREGS
          MOVE    ExcNo(A4),D0
          SUBI    #$60,D0
          ASR     #2,D0
          MOVE    D0,EntryNr(A4)
          BSET    #1,EntryMod(A4)
          LEA     IRQMSG(PC),A1
          BRA     EntryC0

doRTE:    RTE

; TRAP - Entries ( Vectornr.$20-$2F )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyTRAP0
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #unused_TRAP_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L   PULLREGS
          MOVE    ExcNo(A4),D0
          LSR.W   #2,D0
          SUBI.W  #$10,D0
          MOVE    D0,EntryNr(A4)
          BSET    #1,EntryMod(A4)
          LEA     TRAPMSG(PC),A1
          BRA     EntryC0

; TrapV - Entry ( Vectornr.$07 )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyTRAPV
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #TRAPV_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L   PULLREGS
          LEA     TRPVMSG(PC),A1
          BRA     EntryC0

; CHK - Entry ( Vectornr.$06 )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyCHK
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #CHK_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L   PULLREGS
          LEA     CHKMSG(PC),A1
          BRA     EntryC0

; Div by Zero - Entry ( Vectornr.$05 )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
!EyDIVV   DC.L    0
!EyDIV
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Division_by_Zero_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          MOVE.W  DIVZPatch(PC),-(SP)
          TST.W   (SP)+
          BEQ.S   EyDIVT
          MOVE.L  EyDIVV(PC),-(SP)
          RTS
!EyDIVT   BSR.L   PULLREGS
          LEA     DIVMSG(PC),A1
          BRA     EntryC0

; Privilegsverletzungs - Entry ( Vectornr.$08 )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
!EyPRIVV  DC.L    0
!EyPRIV
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Privilege_Violation_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          MOVEM.L A0/A4/D0,-(SP)       ; Register sichern
          MOVEA.L LocVarP(PC),A4       ; Pointer fÅr lokale Variablen
          TST     is10(A4)             ; 68010 CPU oder hîher?
          BEQ.S   EyPRIV1              ; NEIN, dann keine Untersuchung auf MOVE vom SR
          MOVE.L  14(A7),A0            ; PC holen (Default Stack Frame (0))
          MOVE.W  (A0),D0              ; Instruktion holen
          ANDI.W  #$FFC0,D0            ; EA ausmaskieren (verwerfen)
          CMPI.W  #$40C0,D0            ; ist es MOVE von SR?
          BNE.S   EyPRIV1              ; Nein, Dann TempleMon aktivieren!
          MOVE.W  SRPatch(PC),D0       ; soll TOS den Befehl ausfÅhren?
          BEQ.S   EyPRIV1              ; Nein, gehe in TempleMon!
          MOVEM.L (SP)+,A0/A4/D0
          MOVE.L  EyPRIVV(PC),-(SP)    ; alter Vektor aus XBRA Verkettung
          RTS

!EyPRIV1  MOVEM.L (SP)+,A0/A4/D0       ; Register restaurieren
          BSR.L   PULLREGS             ; Alle Register in TempleMon Datenstruktur
                                       ; eintragen
          LEA     PRIVMSG(PC),A1       ; BegrÅûungsmeldung ausgeben
          BRA     EntryC0              ; zur Kommandoeingabe



;*****************************************************************

; DISASSEMBLER F. EINE ZEILE, ADR. IN A2

!DISASMLN
          MOVE.W  isCD10(A4),isD10(A4)
          MOVE.W  isCD20(A4),isD20(A4)
          MOVE.W  isCD30(A4),isD30(A4)
          MOVE.W  isCD40(A4),isD40(A4)
          MOVE.W  isCDFPU(A4),isDFPU(A4)
          BSR     DoDISASMLN
          BRA.L   DISASM

!DISASMLNTrace
          MOVE.W  is10(A4),isD10(A4)
          MOVE.W  is20(A4),isD20(A4)
          MOVE.W  is30(A4),isD30(A4)
          MOVE.W  is40(A4),isD40(A4)
          MOVE.W  isFPU(A4),isDFPU(A4)
          BSR     PRTCR
          BSR     DoDISASMLN1
          BRA.L   DISASMTrace

!DoDISASMLN BSR     PRTCRLF
!DoDISASMLN1 CLR.W   DCursorX(A4)
          MOVEQ   #PROMPT,D0
          BSR.L   DPrt
          MOVEQ   #',',D0
          TST     isD20(A4)
          BNE     DISASML
          EXG     D0,A1
          ANDI.L  #$00FFFFFF,D0
          EXG     D0,A1
!DISASML  CMPA.L  RgPC(A4),A2
          BNE     DISASML2
          MOVEQ   #'>',D0
          BRA     DISASMP
!DISASML2 LEA     BP(A4),A1
          LEA     BPset(A4),A0
          MOVEQ   #BPanz,D0
          ASL.W   #2,D0
          ADDA.W  D0,A1
          MOVEQ   #BPanz-1,D1
!DISASML3 CMPA.L  -(A1),A2
          BNE     DISASML4
          BTST    D1,(A0)
          BNE     DISASMB
!DISASML4 DBRA    D1,DISASML3
          MOVEQ   #',',D0
          BRA     DISASMP
!DISASMB  MOVEQ   #'^',D0
!DISASMP  BRA.L   DPrt

!DISASM   MOVEM.L D0-A1/A3-A6,-(A7)
          MOVEA.L A2,A1
          MOVE.W  isCD10(A4),isD10(A4)
          MOVE.W  isCD20(A4),isD20(A4)
          MOVE.W  isCD30(A4),isD30(A4)
          MOVE.W  isCD40(A4),isD40(A4)
          MOVE.W  isCDFPU(A4),isDFPU(A4)
!DISASM_go
          BSR.L   DISMICL

          MOVEA.L A1,A2
          MOVEM.L (A7)+,D0-A1/A3-A6
          RTS

!DISASMTrace
          MOVEM.L D0-A1/A3-A6,-(A7)
          MOVEA.L A2,A1
          MOVE.W  is10(A4),isD10(A4)
          MOVE.W  is20(A4),isD20(A4)
          MOVE.W  is30(A4),isD30(A4)
          MOVE.W  is40(A4),isD40(A4)
          MOVE.W  isFPU(A4),isDFPU(A4)
          BRA     DISASM_go

!DSOUT    LEA     DBuffer(A4),A1
          TST.B   DBufLong(A4)
          BEQ     DSOUT0
          BSR     DSOUT0
          BSR     PrtLF
          LEA     DBuffer(A4),A1
          LEA     80(A1),A1
!DSOUT0   MOVE.L  A1,A0
          BSR.L   PutLine
          MOVE.L  pMonScreen(PC),A2
          ADDA.L  tmon_offset(A4),A2
          MOVE.W  CursorY(A4),D0
          MULU    CharHeight(A4),D0
          MOVE.W  video_rowbytes(A4),D4
          MULU.W  D4,D0
          ADDA.L  D0,A2
          MOVEQ   #80,D0
          MOVEQ   #0,D1
          CMPI.W  #1,video_plane(A4)
          BEQ.L   FastString16_8o
          BRA.L   FastString8_8o

!DISMCONVREAL
          MOVEM.L A0-A6,-(SP)
          BSR     CONVREAL
          MOVEM.L (SP)+,A0-A6
          RTS

;#################################################################

!INITGMON
(*$? INITMAC:
          MOVE.L  A0,A3                 ; Start of Code
*)
(*$? ~INITMAC:
          MOVE.L  4(A7),A5        ; Ptr auf base page laden
          ; Supervisormodus:
          CLR.L   -(A7)
          MOVE.W  #$20,-(A7)
          TRAP    #1
          ADDQ.L  #6,A7
          LEA     OldSP(PC),A0
          MOVE.L  D0,(A0)

          LEA     EyIRQ(PC),A0
          MOVE.L  -8(A0),D0     ; 'TMon' nach D0
          MOVE.L  IRQ7V,A0
          CMP.L   -8(A0),D0     ; steht 'TMon' in XBRA-Kennung?
          BNE     INITGMON1
          PEA     noInstallMsg1(PC)
          MOVE.W  #9,-(SP)
          TRAP    #1
          ADDQ.L  #6,SP
          BRA.W   noInstall1
*)
INITGMON1
(*$? ~INITMAC: ; tastenabfrage: nicht installieren?
          MOVE.W  #-1,-(SP)
          MOVE.W  #$B,-(SP)
          TRAP    #13
          ADDQ.L  #4,SP
          CMP.B   abort_key_mask(PC),D0
          BEQ.W   noInstall

          LEA     pBasePage(PC),A0
          MOVE.L  A5,(A0)

          MOVE.L  codelen(A5),D0
          ADDI.L  #256,D0               ; base page
          ADD.L   datalen(A5),D0
          ADD.L   bsslen(A5),D0         ; Platz f. globale Variable
          MOVE.L  D0,D1
          ADD.L   A5,D1
*)
(*$? INITMAC:
          LEA     EndOfMon(PC),A0
          MOVE.L  A0,D0
          SUB.L   A3,D0                 ; Length of Code
          MOVE.L  D0,D1
          ADD.L   A3,D1
*)
          LEA     LocVarP(PC),A0
          MOVE.L  D1,(A0)               ; bss liegt hinter code
          MOVE.L  D1,A4                 ; wird gleich noch gebraucht

          LEA     LBLBEG(A4),A0
          LEA     LblEnd(A4),A6
!ECLDL1   CLR.W   (A0)+           ; ALLE MON-VARIABLEN LOESCHEN
          CMPA.L  A6,A0
          BCS     ECLDL1

(*$? INITMAC:
          move.l  A5,originalA5(A4)
*)
(*$? ~INITMAC & MAC:
          bsr     mode_mac
          move.l  $0904,originalA5(A4)
          bsr     mode_atari
*)
          move.l  A7,originalA7(A4)

          MOVE.L  A4,AdOffset(A4)

          SF      MonActive(A4)
          BSR.L   MCH_Test

          ADDI.L  #LastLocalVar,D0      ; Platz f. lokale Variable
          ANDI.W  #$FFFE,D0
          ADDQ.L  #2,D0

          MOVE.L  D0,-(SP)
(*$? MAC:
          LEA     pFont8_8(PC),A2
          LEA     font8x8(PC),A0      ; f. System-Font 8*8
          MOVE.L  A0,(A2)
          bsr.l   InitBitToByteTab

          BSR     SetMonoConst
*)
(*$? ~MAC:
          ;*** ^ auf Fontdaten holen:
          DC.W    $A000
          ADDQ.L  #4,A1
          LEA     pFont8_8(PC),A2
          MOVE.L  (A1)+,A0      ; f. System-Font 8*8 (Farbe)
          MOVE.L  76(A0),(A2)
          LEA     pFont8_16(PC),A2
          MOVE.L  (A1)+,A0      ; f. System-Font 8*16 (S/W)
          MOVE.L  76(A0),(A2)

          MOVE    #080,Rows(A4)
          MOVE    #25,Lines(A4)
          CLR.W   video_modus(A4)
          TST     isFALCON030(A4)
          BNE     calcedit
          BSR.L   SetMonoConst
          TST     isTT(A4)
          BNE     settt
          BTST.B  #1,$FFFF8260          ; Farbe ?
          BNE     setmon1
          BSR.L   SetColorConst
!setmon1  TST     isTT(A4)
          BEQ     calcedit

!settt    MOVE.B  $FFFF8262,D0          ; TT Shift Mode Register
          ANDI.B  #7,D0
          CMPI.B  #6,D0
          BNE     calcedit
          MOVE    #60,Lines(A4)         ; TT Hochauflîsung mit 60 Zeilen
          MOVE.W  #-1,video_modus(A4)
          BSR     GetTTConst
*)

!calcedit
          MOVE.B  edit_modus(PC),D0
          EXT.W   D0
          MOVE.W  D0,EditModus(A4)
          CLR.W   autoswitch(A4)        ; erst mal mit keinem AutoSwitch belegen

          BSR.L   stackframe_Test       ; CPU-Test fÅr Stack Frame

          BSR.L   CPU_Test              ; CPU-Test ob 10er, 20er oder 30er CPU
          TST     is20(A4)
          BEQ     noNewRate
          LEA     BlinkRate(PC),A0
          MOVE.L  (A0),D0
          LSL.L   #2,D0
          MOVE.L  D0,(A0)               ; Cursor-Blinken vierfach langsamer
!noNewRate

(*$? ~MAC:
          TST     isFALCON030(A4)
          BNE     noAutoSwitch2
          BSR     test_ostt
          BNE     perform_test
          TST     isTT(A4)
          BNE     noAutoSwitch2
          TST     isSTE(A4)
          BNE     noAutoSwitch2
          BRA.S   perform_test1
!perform_test
          TST     isTT(A4)
          BEQ     perform_test1
          MOVE.B  $FFFF8262,D0          ; TT Shift Mode Register
          ANDI.B  #7,D0
          CMPI.B  #6,D0                 ; TT Hoch Auflîsend?
          BNE     perform_test1
          CLR.L   OSTT(A4)
          BRA     noAutoSwitch2         ; Dann kein OverScan!
!perform_test1
          BSR.L   OverScanTest
          MOVE.W  D0,entry_video_modus(A4)
          TST     isTT(A4)
          BNE     perform_test2
          MOVE.W  D0,video_modus(A4)
!perform_test2

          TST.W   D0
          BEQ     mustbeauto            ; kleiner Bildschirm, dann AutoSwitch OverScan
                                        ; oder normaler ST
          BSR.L   SmallScreen
          BSR.L   OverScanTest
          CMP.W   entry_video_modus(A4),D0
          BEQ     noAutoSwitch
          BSR.L   BigScreen
!mustbeauto
          NOT.W   autoswitch(A4)
          CLR.W   video_modus(A4)
          BRA.S   noAutoSwitch2
!noAutoSwitch
          BTST.B  #1,$FFFF8260          ; Farbe ?
          BNE     noAutoSwitch1
          BSR     GetColorConst
          BRA.S   noAutoSwitch2
!noAutoSwitch1
          BSR     GetMonoConst
!noAutoSwitch2
*)

          MOVE.L  (SP)+,D0
(*$? ~INITMAC:
          ADD.L   A5,D0
*)
(*$? INITMAC:
          ADD.L   A3,D0
*)

          LEA     HistoryStart(PC),A0              ; History Puffer anlegen
          MOVE.L  D0,(A0)           ; HistoryStart
          MOVE.L  D0,8(A0)          ; HistoryAktuell
          MOVE.L  D0,12(A0)         ; HistorySuchen
          MOVE.L  D0,16(A0)         ; HistoryFill
          CLR.L   D2
          MOVE.B  edit_lines(PC),D2
          MULU    Rows(A4),D2
          ADD.L   D2,D0
          LEA     HistoryEnde(PC),A0
          MOVE.L  D0,(A0)

          ADD.L   #256,D0                 ; zur Sicherheit...
          LEA     bMonScreenBase(PC),A0            ; Bildschirmpuffer anlegen
          MOVE.L  D0,(A0)
          MOVE.L  D0,A1
          LEA     bMonScreen(PC),A0
          MOVE.L  D0,(A0)
          LEA     bMonScreenUsed(PC),A0
          MOVE.L  D0,(A0)
          MOVE.W  Lines(A4),D1
          MULU    Rows(A4),D1
          LEA     bMonScreenSize(PC),A0
          MOVE.L  D1,(A0)
          ADD.L   D1,D0
          LEA     bMonScreenEnd(PC),A0
          MOVE.L  D0,(A0)
          LEA     bMonScreenStop(PC),A0
          MOVE.L  D0,(A0)
          MOVE    more_edit(PC),D1
          BEQ.S   no_more_edit
          MULU    Rows(A4),D1
          ADD.L   D1,D0
!no_more_edit
          LEA     bMonScreenTop(PC),A0
          MOVE.L  D0,(A0)
          MOVE.L  D0,D1
          SUB.L   A1,D1
          LEA     bMonScreenSpace(PC),A0
          MOVE.L  D1,(A0)
          ADD.L   #256,D0                 ; zur Sicherheit...

(*$? MAC:
          ; Puffer fÅr Screen-Inhalt anlegen
          LEA       pMonScreen(PC),A1
          MOVE.L    D0,pOffScreen(A4)
          MOVE.L    D0,(A1)
          ADD.L     orig_screen_size(a4),D0
          MOVE.L    video_memsize(A4),video_size(A4)
*)

(*$? Test:
          BSR.L   test_start       (* Cookie der Debugging TempleMon Version
                                      suchen *)
*)
          BSR.L   InstallCookie
!SetStack
          ; Stack-Bedarf dazurechnen (hinter Screen legen):
          ADD.L   StackSize(PC),D0
          MOVE.L  D0,MonStackHi(A4)
(*$? ~INITMAC:
          MOVE.L  D0,A7
          ; MOVE.L  A7,USP

          ; gesamte belegte Bytes des Programms sichern
          LEA     saveCodeLen(PC),A0
          SUB.L   A5,D0
          MOVE.L  D0,(A0)

          ; Speicherbereich verkÅrzen
          MOVE.L  D0,-(SP)              ; Mshrink
          MOVE.L  A5,-(SP)
          CLR.W   -(SP)
          MOVE.W  #$4A,-(SP)
          TRAP    #1
          LEA     $C(SP),SP
*)
(*$? INITMAC:
          LEA     saveCodeLen(PC),A0
          SUB.L   A3,D0
          MOVE.L  D0,(A0)
*)

(*$? ~MAC:
          ; Bereich f. Mon-Screen reservieren :
          MOVE.L  #32000,D0
          TST     isTT(A4)
          BEQ     Malloc
!Mxalloc  MOVE.W  $FFFF8262,D1
          ANDI.W  #$0700,D1
          CMPI.W  #$0600,D1
          BNE     Mxalloc_1
          MOVE.L  t_VideoMemory(PC),D0          ; TT Hochauflîsend!
!Mxalloc_1 MOVE.L  D0,video_size(A4)
          ADDI.L  #256,D0
          CLR.W   -(SP)                 ; ST Ram only!
          MOVE.L  D0,-(SP)              ; Mxalloc
          MOVE.W  #$44,-(SP)
          TRAP    #1
          ADDQ.L  #8,SP
          BRA     SetMallocReturn
!Malloc   TST     isSTE(A4)             ; Malloc
          BNE     ScreenAllocate
          TST     autoswitch(A4)
          BNE     ScreenAllocate
          TST     entry_video_modus(A4)
          BEQ     ScreenAllocate
          MOVE.L  video_memsize(A4),D0
          ST      video_modus(A4)
!ScreenAllocate
          MOVE.L  D0,video_size(A4)
          CLR.W   -(SP)                 ; ST Ram only!
          MOVE.L  D0,-(SP)              ; Mxalloc
          MOVE.W  #$44,-(SP)
          TRAP    #1
          ADDQ.L  #8,SP
          TST.L   D0
          BEQ.L   noInstall
          CMPI.L  #-32,D0
          BNE.S   SetMallocReturn
          MOVE.L  video_size(A4),D0
          ADDI.L  #256,D0
          MOVE.L  D0,-(SP)
          MOVE.W  #$48,-(SP)
          TRAP    #1
          ADDQ.L  #6,SP
!SetMallocReturn
          TST.L   D0
          BEQ.L   noInstall
          ADDI.L  #255,D0
          ANDI.W  #$FF00,D0
          LEA     pMonScreen(PC),A0
          MOVE.L  D0,(A0)
          LSR.L   #8,D0
          LEA     rMonScreen(PC),A0
          MOVE.W  D0,(A0)
*)

(*$ ? ExtendedKeys:
          move.w  #kbdvbase,-(sp)
          trap    #14
          addq.l  #2,sp
          move.l  d0,Kbdv_base(A4)
          move.l  d0,a0
          lea     $1C(A0),A1
          move.l  (A1),A0
          bsr.l   search_tos
          move.l  A0,TOSMIDI(A4)
          move.l  d0,a0
          lea     $20(A0),A1
          move.l  (A1),A0
          bsr.l   search_tos
          move.l  A0,TOSIKBD(A4)

          clr.w   CallFlag(A4)
          st      LockFlag(A4)

          move.w  #1,-(sp)
          move.w  #$e,-(sp)
          trap    #14
          addq.l  #4,sp
          move.l  d0,IorecPointer(A4)
*)

          MOVEQ   #0,D0              ; InitVec: énderungen nicht anzeigen
          MOVEQ   #1,D1              ; InitVec: alle TRAPs setzen
          BSR.L   InitVec

          CLR.L   UsrBP(A4)

          BSR     CRAW0           ; REG.AUSWAHL:ALLE REGS bis auf BEV u. AEV
          BSET    #7,RegWahl(A4)

          ; Adr. der KbShift-Var. ermitteln
          MOVE.L    $4F2,A1
          MOVE.W    #$E1B,A0
          CMPI.W    #$0100,2(A1)        ; tos 1.0 ?
          BEQ       takeE1B             ; dann kennen wir die Adr.
          MOVE.L    $24(A1),A0          ; sonst holen wir Adr. aus TOS-Header
!takeE1B  LEA       KbshiftV(PC),A1     ; Keyboard-Status-Adresse
          MOVE.L    A0,(A1)             ; sichern

          BSR     ClearScrn
          BSR     InitKeyBuf
          BSR     InitHistory

          ; Zeiger auf Tastatur-Puffer-Datensatz holen      ADC: {
          move.l    #$000e0001,-(sp)    ; Iorec
          trap      #14
          addq.l    #4,sp
          lea       KeyIORcV(pc),a0
          move.l    d0,(a0)      ; Zeiger auf Systemtastatur-Buf. speichern }

(*$ ? ExtendedKeys:
          ; Routine hinter Tastaturauswertung im IR-Level 6 hÑngen
          LEA       ChkKbdEntry(PC),A0
          MOVE.W    #$100+6*4,A1    ; MFP, Int-Nr. 6
          MOVE.L    (A1),-4(A0)     ; alten Vektor in XBRA merken
          MOVE.L    A0,(A1)
          ; Neuen IKBDSYS einbauen
          move.l    Kbdv_base(A4),a0        ; Keyboard Basisadresse
          lea       EyIKBDSYS(PC),a1
          move.l    32(a0),-4(a1)
          move.l    a1,32(a0)
*)

          BSR       PrComds
          BSR       test_symb
          BSR.L     install_68030_table
          BSR       test_MiNT
          MOVE.L    MiNT_Cookie(A4),D0
          CMPI.W    #$0100,D0
          BCS       back_to_user_mode
          ST        TMon_Tree(A4)
!back_to_user_mode

(*$? ~INITMAC:
          ; zurÅck in den User-Modus
          MOVE.L  OldSP(PC),-(A7)
          MOVE.W  #$20,-(A7)
          TRAP    #1
          ADDQ.L  #6,A7
*)

(*$? ADC:
          ; Adresse der TOS Tasten-Verarbeitungs Routine holen ADC: {
          move.w    #kbdvbase,-(sp)           ; Adresse der Vectortabelle holen
          trap      #14
          addq.l    #2,sp
          move.l    d0,a0
          lea       IKBDSYSV(pc),a1
          move.l    32(a0),(a1)         ; Keyboard-System-Routine sichern }
*)

(*$? ~INITMAC:
          ; Init-Msg ausgeben
          PEA     initMsg(PC)
          MOVE.W  #$09,-(A7)
          TRAP    #1
          ADDQ.L  #6,A7
*)

(*$? ExtendedKeys:
          sf      LockFlag(A4)
*)
          BRA.L   InitHelp

(*$? ~INITMAC:
!keepProcess
          ; Nun wird GEMDOS $31 aufgerufen (Keep process)
          CLR.W   -(A7)
          MOVE.L  saveCodeLen(PC),-(A7)
          MOVE.W  #$31,-(A7)
          TRAP    #1

!noInstall PEA     noInstallMsg(PC)
          MOVE.W  #9,-(SP)
          TRAP    #1
          ADDQ.L  #6,SP

!noInstall1 ; zurÅck in den User-Modus
          MOVE.L  OldSP(PC),-(A7)
          MOVE.W  #$20,-(A7)
          TRAP    #1
          ADDQ.L  #6,A7

          CLR     -(A7)
          TRAP    #1      ; Pterm0
          BRA.L   EndOfMon
*)

(*$? INITMAC:
!keepProcess
          MOVE.L    saveCodeLen(PC),D0
          RTS

noInstall1
          MOVEQ     #0,D0
          RTS
*)

(*$ ? ExtendedKeys:

; IKBDSYS

; **************************************************************************

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
!OldIKBDSYS
          DC.L    0
!EyIKBDSYS
          move.l    KeyIORcV(PC),a0
          move.w    8(a0),-(sp)         ; Tail Index merken
          move.l    OldIKBDSYS(PC),a0
          jsr       (a0)                ; alte Routine ausfÅhren
          move.l    KeyIORcV(PC),a0     ; Iorec Pointer holen
          move.w    8(a0),d1            ; Neuen Tailindex holen
          cmp.w     (sp)+,d1            ; mit altem vergleichen
          beq       nokey
          move.l    a4,-(a7)
          movea.l   LocVarP(PC),A4
          move.l    0(a0),a1            ; Zeiger auf IO Puffer
          move.l    0(a1,d1.w),d0       ; letzte Taste (ASC 0-7; Scan 16-23)
          swap      d0                  ; ScanCode nach 0-7
          cmp.b     tmon_scancode(PC),d0
          beq.s     war_help
          cmp.b     reset_scancode(PC),d0
          beq.l     war_del
          tst       isTT(A4)
          bne       return_ikbd
          cmp.b     sync_scancode(PC),d0
          beq.l     war_mal
          cmp.b     sync_on(PC),d0
          beq.l     switch_intern
          cmp.b     sync_off(PC),d0
          beq.l     switch_extern
!return_ikbd
          move.l    (a7)+,a4
!nokey
          rts
*)
!kill_key
(*$ ? ExtendedKeys:
          move.l    KeyIORcV(PC),a0     ; Iorec Pointer holen
          move.w    8(a0),d1            ; neuen Tailindex holen
          subq.w    #4,d1
          bpl.s     to_kill_repeat
          move.w    6(a0),d1
!to_kill_repeat
          move.w    d1,8(a0)
*)
!kill_repeat
(*$ ? ExtendedKeys:
          move.l    KbshiftV(PC),a0
          moveq     #0,d1
          move.b    d1,$1e(a0)          ; Repeat Taste
          move.b    d1,$1f(a0)          ; ZÑhler fÅr Startverzîgerung
          move.b    d1,$20(a0)          ; ZÑhler fÅr Repeat Rate
*)
          rts

;*************************************************************************

(*$ ? ExtendedKeys:

!war_help                             ; Tastendruck von Help auswerten
        movem.l   a0/d0,-(sp)         ; d0 sichern
        bsr       KbShift
        andi.b    #$f,d0
        cmp.b     tmon_shiftkeys(PC),d0
        bne       end_help
        tst.b     LockFlag(A4)        ; Monitor gerade aktiv
        bne       end_help            ; dann nicht nocheinmal aufrufen
        st        CallFlag(A4)
        movem.l   (sp)+,a0/d0
        bra       kill_key
!end_help
        movem.l   (sp)+,a0/d0
        bra.l     return_ikbd

!war_del            movem.l   d0/a2-a3,-(sp)      ; Registersicherung
                    bsr       KbShift
                    andi.b    #$f,d0
                    cmp.b     reset_warm_shiftkeys(PC),d0
                    beq.s     warmstart
                    cmp.b     reset_kalt_shiftkeys(PC),d0
                    beq.s     kaltstart           ; (Alt + Cntrl + Shift)
!reset_in_neuem_tos
                    movem.l   (sp)+,d0/a2-a3      ; war nix fÅr uns; Register-
                    bra       return_ikbd         ; restaurierung und zurÅck

!kaltstart          lea       $100+6*4,a2
                    lea       CHKKbdEntry(PC),a3
                    move.l    -4(a3),(a2)
                    movea.l   Kbdv_base(A4),a2
                    lea       32(a2),a2
                    lea       EyIKBDSYS(PC),a3
                    move.l    -4(a3),(a2)
                    movea.l   $4f2,a3             ; _sysbase
                    cmpi.w    #$0102,2(a3)
                    bhi       reset_in_neuem_tos
                    clr.l     $420                ; Lîsche alle memvalids
                    clr.l     $426                ; auch den fÅr'n Resetvektor
                    clr.l     $43a
                    clr.l     $51a
                    movea.l   4,a0
                    jmp       (a0)
!warmstart          lea       $100+6*4,a2
                    lea       CHKKbdEntry(PC),a3
                    move.l    -4(a3),(a2)
                    movea.l   Kbdv_base(A4),a2
                    lea       32(a2),a2
                    lea       EyIKBDSYS(PC),a3
                    move.l    -4(a3),(a2)
                    movea.l   $4f2,a3             ; _sysbase
                    cmpi.w    #$0102,2(a3)
                    bhi       reset_in_neuem_tos
                    movea.l   $4f2,a0             ; _sysbase
                    jmp       (a0)                ; Ab ins Betriebssystem

!war_mal            move.l    d0,-(sp)            ; Registersicherung
                    bsr       KbShift
                    andi.b    #$f,d0
                    cmp.b     sync_shiftkeys(PC),d0
                    bne.l     end_sync
                    movem.l   d1/a0,-(SP)
                    lea       $ffff820a,a0
                    move.b    video_sync_flag(PC),d0
                    beq       startresync
                    lea       video_sync_byte(PC),a0
!startresync        move.b    (a0),d0             ; Resynchronisation auslîsen
                    move.b    d0,old_sync(A4)
                    move.w    sync_time_mono(PC),d1
                    move.b    $ffff8260,d0
                    andi.b    #3,d0
                    cmpi.b    #2,d0
                    beq       starttoggle
                    tst.b     d0
                    beq       togglelowres
!togglemidres       btst.b    #1,(a0)             ; 50 od 60 Hertz
                    beq       togglemid60
!togglemid50        move.w    sync_time_mid50(PC),d1
                    bra       starttoggle
!togglemid60        move.w    sync_time_mid60(PC),d1
                    bra       starttoggle
!togglelowres       btst.b    #1,(a0)
                    beq       togglelow60
!togglelow50        move.w    sync_time_low50(PC),d1
                    bra       starttoggle
!togglelow60        move.w    sync_time_low60(PC),d1
!starttoggle
                    move.b    old_sync(A4),d0
                    eori.b    #1,d0               ; durch kurzfristiges in-
                    move.b    d0,$ffff820a        ; vertieren des Bits fÅr
                                                  ; interne bzw. externe
!do_nothing         dbra      d1,do_nothing       ; Synchronisation
                    move.b    old_sync(A4),d0
                    move.b    d0,$ffff820a
                    movem.l   (SP)+,d1/a0
                    move.l    (sp)+,d0
                    bra       kill_key

!end_sync           move.l    (sp)+,d0            ; Registerrestaurierung
                    bra       return_ikbd         ; und zurÅck

!switch_intern      move.l    d0,-(sp)            ; Registersicherung
                    bsr       KbShift
                    andi.b    #$f,d0
                    cmp.b     sync_on_shiftkeys(PC),d0
                    bne       end_sync_int
                    clr.w     d0
                    bclr      d0,$ffff820a
                    move.l    (sp)+,d0
                    bra       kill_key
!end_sync_int       move.l    (sp)+,d0
                    bra       return_ikbd

!switch_extern      move.l    d0,-(sp)            ; Registersicherung
                    bsr       KbShift
                    andi.b    #$f,d0
                    cmp.b     sync_off_shiftkeys(PC),d0
                    bne       end_sync_ext
                    clr.w     d0
                    bset      d0,$ffff820a
                    move.l    (sp)+,d0
                    bra       kill_key
!end_sync_ext       move.l    (sp)+,d0
                    bra       return_ikbd



; MFP-Int. Routine fÅr Keyboard-Entry


          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
!chkKbd0  DC.L    0
!ChkKbdEntry
          ; zuerst alten MFP-Handler aufrufen. Der wird mit RTE zurÅckkommen
          MOVE.L  A4,-(A7)
          MOVE.L  LocVarP(PC),A4
          TST.B   MonActive(A4)
          BNE     chkKbd1
          TST     StkFrm(A4)
          MOVEA.L (A7)+,A4
          BEQ     chkKbd3
          MOVE    #$0010,-(A7)    ; Stackframe von Ill.Instr. laden
!chkKbd3  pea     chkKbd2(PC)
          move    SR,-(A7)
          move.l  chkKbd0(PC),-(A7)
          RTS
!chkKbd1  MOVEA.L (A7)+,A4
          MOVEM.L D0-D3/A0-A3/A5,-(SP)
!chkKbdL  SUBA.L  A5,A5
          MOVE.L  A4,-(A7)
          MOVE.L  LocVarP(PC),A4
          MOVEA.L TOSMIDI(A4),A2
          MOVEA.L (A7)+,A4
          JSR     (A2)
          MOVE.L  A4,-(A7)
          MOVE.L  LocVarP(PC),A4
          MOVE.L  TOSIKBD(A4),A2
          MOVEA.L (A7)+,A4
          JSR     (A2)
          BTST    #4,$FFFFFA01
          BEQ     chkKbdL
          MOVE.B  #$BF,$FFFFFA11
          MOVEM.L (SP)+,D0-D3/A0-A3/A5
!chkKbd2  MOVE.L  A4,-(A7)
          MOVE.L  LocVarP(PC),A4
          tst.b   CallFlag(A4)        ; bin ich aufgerufen worden ?
          MOVEA.L (A7)+,A4
          beq     EndVBL
          MOVE.L  A4,-(A7)
          MOVE.L  LocVarP(PC),A4
          sf      CallFlag(A4)        ; und Flag gleich wieder lîschen
          TAS     MonActive(A4)
          MOVEA.L (A7)+,A4
          bpl     startmon
          ;Trace-Abort-Flag setzen
          MOVE.L  A6,-(A7)
          MOVE.L  LocVarP(PC),A6
          BSET    #2,TrcStat(A6)     ; !!! stattdessen erst test, ob
                                     ; Tracebit in SR gesetzt, und nur,
          MOVE.L  (A7)+,A6           ; wenn gesetzt, dieses Bit setzen
!EndVBL   RTE

!startmon BSR.L   PULLREGS

          ; Interruptlevel zurÅck und Semaphore freigeben
          MOVE    SR,D1
          ANDI.W  #$FDFF,D1
          OR.W    IRMask(PC),D1
          MOVE    D1,SR

          BTST    #1,TrcStat(A4)     ; TraceMode on ?
          BEQ     EntKBDE1
          TST     TrcStat(A4)        ; just tracing ?
          BPL     EntKBDE1

          BSR     ResetBPs         ; BPs RöCKSETZEN

          MOVE.B  TrcStat(A4),D7
          BSET    #2,D7
          BRA     TrcC1
*)

(*$? AltHelp:

; Keyboard-Entry ( mit ALT/HELP )

          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyKBD    BSR     KbShift            ; Shift oder Ctrl (Alt wird ja gedrÅckt) ?
          ANDI    #15,D0
          CMPI    #8,D0
          BNE     HardCopy

!noCtlAhl MOVE.L  LocVarP(PC),A6
          ;               BTST    #0,TrcStat(A6)
          BRA ENTKBDC0  ; BEQ     EntKBDC0 ; auf Tracebit d. SR testen

!EntKbdE  BSET    #2,TrcStat(A6)     ; !!! stattdessen erst test, ob
                                     ; Tracebit in SR gesetzt, und nur,
          RTS                        ; wenn gesetzt, dieses Bit setzen

!HardCopy MOVE.L  A0,D0
          LEA     EyKBD(PC),A0
          MOVE.L  -4(A0),-(A7)
          MOVE.L  D0,A0
          RTS

!EntKBDC0 TAS     MonActive(A6)
          BMI     EntKBDE

(* 26.6.96 alt:
          ADDQ.L  #8,A7
!startmon
          MOVEM.L (A7)+,D0-A5
          MOVEM.L D0-A5,RgD0(A6)
          MOVE.L  A6,A4
          MOVE.L  (A7)+,RgA6(A4)
          MOVE.W  (A7)+,RgSR(A4)      ; SR VON STACK
          MOVE.L  (A7)+,RgPC(A4)      ; EXCEPTION-RETURN-ADR. VON STACK

          TST     is10(A4)
          BEQ.L   is20_7_01
          MOVEC.L SFC,D0
          MOVE.L  D0,RgSFC(A4)
          MOVEC.L DFC,D0
          MOVE.L  D0,RgDFC(A4)
          MOVEC.L VBR,D0
          MOVE.L  D0,RgVBR(A4)
          TST     is20(A4)
          BEQ.L   is20_7_01
          MOVEC.L CACR,D0
          MOVE.L  D0,RgCACR(A4)
          MOVEC.L ISP,D0
          MOVE.L  D0,RgISP(A4)
          MOVEC.L MSP,D0
          MOVE.L  D0,RgMSP(A4)
          TST     is40(A4)
          BEQ     is20_7_20er
                                 ; 40er Code
          DC.W    $4E7A,$0003    ; MOVEC   TC,D0
          MOVE.L  D0,RgTC(A4)
          DC.W    $4E7A,$0004    ; MOVEC   ITT0,D0
          MOVE.L  D0,RgITT0(A4)
          DC.W    $4E7A,$0005    ; MOVEC   ITT1,D0
          MOVE.L  D0,RgITT1(A4)
          DC.W    $4E7A,$0006    ; MOVEC   DTT0,D0
          MOVE.L  D0,RgDTT0(A4)
          DC.W    $4E7B,$0007    ; MOVEC   DTT1,D0
          MOVE.L  D0,RgDTT1(A4)
          DC.W    $4E7A,$0805    ; MOVEC   PSR,D0
          MOVE.L  D0,RgPSR(A4)
          DC.W    $4E7A,$0806    ; MOVEC   URP,D0
          MOVE.L  D0,RgURP(A4)
          DC.W    $4E7A,$0807    ; MOVEC   SRP,D0
          BRA     is20_7_02
!is20_7_20er
          MOVEC.L CAAR,D0        ; 20er und 30er Code
          MOVE.L  D0,RgCAAR(A4)
          TST     is30(A4)
          BEQ     is20_7_02
!is20_7_30er                     ; 30er Code
          LEA     RgTT0(A4),A0
          DC.W    $F010,$0A00    ; PMOVE   TT0,(A0)
          LEA     RgTT1(A4),A0
          DC.W    $F010,$0E00    ; PMOVE   TT1,(A0)
          LEA     RgTC(A4),A0
          DC.W    $F010,$4200    ; PMOVE   TC,(A0)
          LEA     RgPSR(A4),A0
          DC.W    $F010,$6200    ; PMOVE   PSR,(A0)
          LEA     RgCRP(A4),A0
          DC.W    $F010,$4E00    ; PMOVE   CRP,(A0)
          LEA     RgSRP(A4),A0
          DC.W    $F010,$4A00    ; PMOVE   SRP,(A0)
          BSR.L   TMon_address_translation_tree

!is20_7_02 TST     isFPU(A4)
          BEQ     is20_7_01
          TST     StFr(A4)
          BNE     is20_7_toFPU1
          LEA     StFrame(A4),A0
          FSAVE   (A0)
!is20_7_toFPU1
          CLR.W   StFr(A4)
          FMOVEM.L  FPCR/FPSR/FPIAR,RgFPCR(A4)
          CLR.L   D0
          MOVE.W  TMonFPCR(PC),D0
          FMOVE.L D0,FPCR
          FMOVEM.X  FP0-FP7,RgFP0(A4)
!is20_7_01
          TST.W   is20(A4)
          BNE     is20_7
          CLR.B   RgPC(A4)
!is20_7
          MOVE.L  A7,RgSSP(A4)        ; SP SAVEN
          MOVE.L  USP,A0
          MOVE.L  A0,RgUSP(A4)
          MOVE.L  MonStackHi(A4),A7

          BSR     SETMON
*)
          ; neu:
          BSR.W   PullReg2

          ; Interruptlevel zurÅck und Semaphore freigeben
          SUBQ    #1,$4EE       ; _dumpflg rÅcksetzen
          MOVE.W  #1,$452

          MOVE    SR,D1
          ANDI.W  #$F8FF,D1       ; !TT 26.06.96 vormals $FDFF
          OR.W    IRMask(PC),D1
          MOVE    D1,SR

          BTST    #1,TrcStat(A4)     ; TraceMode on ?
          BEQ     EntKBDE1
          TST     TrcStat(A4)        ; just tracing ?
          BPL     EntKBDE1

          BSR     ResetBPs         ; BPs RöCKSETZEN

          MOVE.B  TrcStat(A4),D7
          BSET    #2,D7
          BRA     TrcC1
*)

!EntKbdE1 LEA     KBDEMSG(PC),A1
          ST      KeyCall(A4)
          BRA     CMDBEG

; ASCII SPEICHER-EINGABE

!ComdHKOM BCLR    #11,D7
          BSR.L   GETADR0
          BMI     CHKEND
          MOVE.L  D1,LastIA(A4)
          MOVEA.L D1,A1
          CMPI.B  #SPC,D0
          BNE     ERR6
!CHKL1    ADDQ.L  #1,A6
          MOVE.B  (A6),D0
          CMPI.B  #CR,D0
          BEQ     CHKEND
          MOVE.B  D0,(A1)+
          BRA.L   CHKL1

!CHKEND   RTS

; ASCII SPEICHER-ANZEIGE

!ComdI    LEA     LastIA(A4),A1   ; LETZTE ANF.ADR. ALS DEFAULT-WERT-POINTER
          BSET    #12,D7          ; Ungerade Adr. erlaubt
          BSR.L   GETAE           ; ANF.-/END- ADR. NACH A2/A3 HOLEN
          BPL     ERR4
          MOVEQ   #ADUMPANZ-1,D6  ; ANZ. bytes -1 PRO ZEILE
!CIL1     BSR     PrtPRMPT
          MOVEQ   #ASCPRMPT,D0
          BSR     Prt
          MOVE.L  A2,D0           ; PRINT ADRESSE
          BSR     PrtADR
          BSR     PrtSPC
          MOVE.W  D6,D5

          BSR.L   CIU

          BSR.L   TSTKEY
          BNE     CIEND
          ;Warteschleife f. 68020
          BSR     DelayIf20
          BTST    #1,D7
          BEQ     CIC1
          SUBQ.L  #1,D3
          BNE     CIL1
          BRA.S   CIEND
!CIC1     CMPA.L  A3,A2
          BCS     CIL1
!CIEND    MOVE.L  A2,LastIE(A4)
          BRA     PrtCRLF
;          RTS

; DRUCKER ANSTEUERUNG

!CmdPFF   MOVEQ   #FF,D0
          BRA     Prt

!PrOpE01  MOVE.W  NoScrDisp(A4),-(SP)
          ST      NoScrDisp(A4)
          BSR.S   CmdPFF
          MOVE.W  (SP)+,NoScrDisp(A4)
          RTS

!PrOpE0   BSR.L   PrntClose
          TST     D3
          BEQ     PrOpE1
          LEA     ProtMsg(PC),A1
          BSR     PrtStr
          LEA     ClosMsg(PC),A1
          BSR     PrtStr
          BRA     PrtCRLF
!PrOpE1   RTS

!ComdP    BSR     SkipSpc
          BMI     CmdPFF

          MOVE    D0,D2
          MOVE    PrHandle(A4),D3
;          BEQ     PrNotOp
;          BSR     PrtCRLF
!PrNotOp
;         BSR.L   PrntClose     ; Printerfile schlieûen
          BCLR    #11,D7
          BSR     GetNGRKL
          SUBQ.L  #1,A6
          BPL     PrOpC0
          CMPI.B  #'F',D2
          BEQ     PrOpE01
          CMPI.B  #'C',D2
          BEQ     PrOpE0        ; Ende
          CMPI.B  #'-',D2
          BEQ     PrOpE0
!PropC0   BSR.L   PrntClose     ; Printerfile schlieûen
!PropC01  CLR     -(A7)
          MOVE.L  A6,-(A7)
!PropL0   BSR.L   GETNGRKL
          BPL     PropL0
          CLR.B   (A6)       ; String mit Null abschliessen
          CMPA.L  (A7),A6
          BEQ     ERR9          ; ERROR: FEHLENDER NAME

          CMPI.B  #':',-1(A6)   ; Filename = 'xxx:' ?
          BEQ     PropC1
          MOVE    #$3C,-(A7)    ; Fcreate
          BRA     PropC2
!PrOpC1   MOVE    #$3D,-(A7)    ; Fopen
          MOVE    #1,6(A7)      ; mode = WriteOnly
!PrOpC2   TRAP    #1
          ADDQ.L  #8,A7
          TST.L   D0
          BMI     PrntCloseErr
          TST     D0
          BPL     PrOpC3
          NEG     D0
!PrOpC3   MOVE    D0,-(A7)
          LEA     ProtMsg(PC),A1
          BSR     PrtStr
          LEA     OpMSG(PC),A1
          BSR     PrtSTR
          BSR     PrtCRLF
          MOVE    (A7)+,PrHandle(A4)
          RTS

!LSCloseErr  ; in D0 steht Fehlernummer !
          MOVE.L  MemAdr(A4),D1
          BEQ     noMFree1
          CLR.L   MemAdr(A4)
          MOVE    D0,-(A7)
          MOVE.L  D1,-(A7)
          MOVE    #$49,-(A7)
          TRAP    #1                    ; MFREE
          ADDQ.L  #6,A7
          MOVE    (A7)+,D0
!noMFree1 MOVE    RWhandle(A4),D1
          CLR.W   RWhandle(A4)
          BRA     PLSClsErr

!PrntCloseErr  ; in D0 steht Fehlernummer !
          MOVE    Prhandle(A4),D1
          CLR.W   PrHandle(A4)

!PLSClsErr MOVE.W  D0,-(A7)
          BSR     PLSClose
          MOVE.W  (A7)+,D2
          BPL     PLSClsE0              ; kein Error, dann keine Ausgabe
          LEA     IOResMsg(PC),A1       ; (tritt auf, wenn von Printerror
          BSR     PrtSTR                ;  aufgerufen wird)
          MOVE.W  D2,D0
          NEG     D0
          BSR     PrtByte
!PLSClsE0 BRA     PrtCRLF

!LSClose  MOVE    RWhandle(A4),D1
          CLR.W   RWhandle(A4)
          BRA     PLSClose

!PrntClose MOVE    Prhandle(A4),D1
          CLR.W   PrHandle(A4)

!PLSClose CMPI    #5,D1
          BLS     PLSCLE1
          MOVEM.L D2-A6,-(A7)
          MOVE    D1,-(A7)
          MOVE    #$3E,-(A7)
          TRAP    #1
          ADDQ.L  #4,A7
          MOVEM.L (A7)+,D2-A6
!PLSCLE1  RTS


; LOAD / SAVE

!noLMem   LEA     noMemMsg(PC),A1
          BSR     PrtStr
          BSR     PrtCRLF
          BRA     LSClose

!LSOpen   BCLR    #11,D7
          BSR.L   SKIPSPC
          BMI     ERR9            ; ERROR: FEHLENDER NAME

          MOVE.L  A6,-(A7)
!LSopL0   CMPI.B  #',',D0
          BEQ.S   GETLSPC1
          BSR.L   GETNGRKL
          BMI.S   GETLSPC1
          CMPI.B  #' ',D0
          BNE     LSopL0
!GETLSPC1 CLR.B   (A6)       ; Strings mit Null abschliessen
          CMPA.L  (A7),A6
          BEQ     ERR9          ; ERROR: FEHLENDER NAME

          BSET    #12,D7          ; Ungerade Adr. erlaubt
          CLR.L   MemAdr(A4)
          CLR.L   FileStart(A4)
          SF      OverWrite(A4)

          BSR     GETNGRKL
          BSR.L   SKIPSPC
          BMI.L   LSopE0
          CMPI.B  #relFchr,D0
          BNE     LSopC2
          BSR     GETNGRKL
          BSR     GetLongX
          MOVE.L  D1,FileStart(A4)
          ST      OverWrite(A4)
          BSR.L   SKIPSPC
          BMI     LSopE0
          CMPI.B  #',',D0
          BNE     Err11
          BSR     GETNGRKL
!LSopC2   LEA     LASTLSA(A4),A1
          BSET    #12,D7
          BSR     GETAE
!LSopE0   MOVEA.L (A7)+,A1
          RTS

!LSeek    MOVE.L  A2,-(A7)
          MOVE    D0,-(A7)        ; mode (0:from begin, 2:from end)
          MOVE    RWhandle(A4),-(A7)
          MOVE.L  D1,-(A7)        ; pos.
          MOVE    #$42,-(A7)
          TRAP    #1
          ADDA.W  #10,A7
          MOVE.L  (A7)+,A2
          TST.L   D0
          BMI     LSCloseErr
          RTS

!ComdL    CMPI.B  #'-',D0
          BNE     CmdLC0
          BSR     GetNGrKl
          BCLR    #12,D7          ; nur gerade adr.
          BSR     GetAdrG
          BPL     ERR4
          MOVE.L  D1,-(A7)
          MOVE    #$49,-(A7)
          TRAP    #1                    ; MFREE
          ADDQ.L  #6,A7
          BCLR    #11,D7
          TST.L   D0
          BEQ     disposed
          LEA     notAllocMsg(PC),A1
          BSR     PrtStr
          BRA     PrtCRLF
!disposed LEA     OKMsg(PC),A1
          BSR     PrtStr
          BRA     PrtCRLF

!CmdLC0   BSR     LSOpen
          MOVE.L  A2,-(A7)
          CLR     -(A7)
          MOVE.L  A1,-(A7)
          MOVE    #$3D,-(A7)      ; Open
          TRAP    #1
          ADDQ.L  #8,A7
          MOVE.L  (A7)+,A2
          TST     D0
          BMI     LSCloseErr
          MOVE    D0,RWhandle(A4)

          ; DateilÑnge ermitteln:
          MOVEQ   #2,D0
          MOVEQ   #0,D1
          BSR     LSeek
          MOVE.L  D0,FileLen(A4)
          MOVEQ   #0,D0
          MOVE.L  FileStart(A4),D1
          BSR     LSeek

          MOVE.L  FileLen(A4),D1
          SUB.L   FileStart(A4),D1      ; D1:= zu lesende Menge
          MOVE.L  D1,MemLen(A4)

          BTST    #2,D7
          BNE     LhasAdr

          ; Wenn keine Anf.Adr, dann wird Speicher angefordert.
          MOVE.L  A2,-(A7)
          MOVE.L  D1,-(A7)
          MOVE    #$48,-(A7)
          TRAP    #1                    ; Malloc
          ADDQ.L  #6,A7
          MOVE.L  (A7)+,A2
          TST.L   D0
          BEQ     noLMem
          BMI     noLMem
          MOVE.L  D0,A2                 ; Anfangsadr. zum Laden
          MOVE.L  D0,MemAdr(A4)

!LhasAdr  BTST    #3,D7
          BNE     LhasAdr2              ; Endadr. angegeben ?
          MOVE.L  A2,A3
          ADDA.L  MemLen(A4),A3         ; A3 auf A2+LÑnge

!LhasAdr2 LEA     LoadMSG(PC),A1
          BSR     PrtSTR
          MOVE.L  A2,D0
          MOVE.L  D0,LastLSA(A4)
          BSR     Prtlong

          MOVE.L  A3,-(A7)
          MOVE.L  A2,-(A7)
          SUBA.L  A2,A3
          MOVE.L  A3,-(A7)
          MOVE    RWhandle(A4),-(A7)
          MOVE    #$3F,-(A7)            ; FREAD
          TRAP    #1
          ADDQ.L  #8,A7
          MOVE.L  (A7)+,A2
          MOVE.L  (A7)+,A3
          TST.L   D0
          BMI     LSCloseErr

;          CLR.L   MemAdr(A4)
          BSR     LSClose         ; Fehler kann nicht auftreten
          LEA     ENDMSG(PC),A1
          BSR     PrtSTR
          MOVE.L  A3,D0
          MOVE.L  D0,LastLSE(A4)
          BSR     Prtlong
          BRA     PrtCRLF

!ComdS    CMPI.B  #'+',D0
          BNE     ComdS_C
          ST      Symbolic(A4)
          RTS
!ComdS_C  CMPI.B  #'-',D0
          BNE     ComdS_O
          SF      Symbolic(A4)
          RTS
!ComdS_O  BSR     LSOpen
          BTST.L  #3,D7
          BEQ     ERR11           ; ERROR: BEIDE ADR. ANGEBEN !
          MOVE.L  A2,-(A7)
          TST     OverWrite(A4)
          BEQ.S   doCreate
          MOVE    #1,-(A7)
          MOVE.L  A1,-(A7)
          MOVE    #$3D,-(A7)      ; Open
          BRA.S   CmdSC0
!doCreate CLR     -(A7)
          MOVE.L  A1,-(A7)
          MOVE    #$3C,-(A7)      ; Create
!CmdSC0   TRAP    #1
          ADDQ.L  #8,A7
          MOVE.L  (A7)+,A2
          TST     D0
          BMI     LSCloseErr
          MOVE    D0,RWhandle(A4)

          MOVEQ   #0,D0
          MOVE.L  FileStart(A4),D1    ; an die Startposition seeken
          BSR     LSeek

          LEA     SAVEMSG(PC),A1
          BSR     PrtSTR
          MOVE.L  A2,D0
          BSR     Prtlong

          MOVE.L  A3,-(A7)              ; Endadr. retten
          MOVE.L  A2,-(A7)              ; Datenadr.
          SUBA.L  A2,A3
          MOVE.L  A3,-(A7)              ; Anzahl
          MOVE    RWhandle(A4),-(A7)
          MOVE    #$40,-(A7)            ; Write
          TRAP    #1
          ADDQ.L  #8,A7
          MOVE.L  (A7)+,A2
          MOVE.L  (A7)+,A3
          TST.L   D0
          BMI     LSCloseErr

          BSR     LSClose
          TST.W   D0
          BMI     LSCloseErr
          LEA     ENDMSG(PC),A1
          BSR     PrtSTR
          MOVE.L  A3,D0
          BSR     Prtlong
          BRA     PrtCRLF


          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!EyCritic MOVEQ   #-1,D0
          RTS

;         ****  Neue MIDI-KEYBOARD IRQ-ROUTINE  ****
(*$? ADC:
          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L    0
!NKeyMidi movem.l   d0-d3/a0-a3/a5,-(sp)
          suba.l    a5,a5               ; A5 lîschen
!keyirql0 move.l    IKBDSYSV(pc),a2     ; Adresse der alten Keyb.-Systemrout.
          jsr       (a2)                ; Taste abholen
          btst.b    #4,$FFFFFA01        ; Noch eine ?
          beq.s     keyirql0            ; Ja
          bclr      #6,$FFFFFA11
          movem.l   (sp)+,d0-d3/a0-a3/a5
          rte                           ; }
;-------------------
*)

;----------------------------------------------------------------------------

!GetFALCON030VGAColor
          LEA       tt_mono_0(PC),A0
          RTS
!GetFALCON030SC1224Color
!GetFALCON030TVColor
          LEA       color_0(PC),A0
          RTS
!GetFALCON030SM124Color
          LEA       mono_0(PC),A0
          RTS




          ; hier beginnen die Patch-Variablen
          ASC     'TemplemonVar'
(*$? ~MAC:
StackSize DC.L    768           ; Default-Stackgrîûe
BlinkRate DC.L    $2000         ; Wenn Null, dann kein Blinken
IRMask    DC.W    $0500         ; IR-Maske im Monitor
*)
(*$? MAC:
StackSize DC.L    4000          ; Default-Stackgrîûe
BlinkRate DC.L    $0500         ; Wenn Null, dann kein Blinken
IRMask    DC.W    $0700         ; IR-Maske im Monitor
*)
DumpDelay DC.L    2468          ; Wartezeit bei 68020 bei Cmds M, I
DumpDelay2 DC.L   1             ; Wartezeit wenn langsame Screenroutinen
ext_flag          DC.W      0   ; 0 = gucken ob neue Tastatur Routine in VBL
                                ; Queue paût, sonst gleich Hardcopy Vektor
                                ; verbiegen (Boole'scher Wert!)
(*$? NOT Debug:
tmon_shiftkeys    DC.B      4   ; Status der Umschalttasten fÅr Tastaturaufruf
*)
(*$? Debug:
tmon_shiftkeys    DC.B      6   ; Status der Umschalttasten fÅr Tastaturaufruf
*)
tmon_scancode     DC.B      $62 ; Scancode fÅr Tastaturaufruf
reset_kalt_shiftkeys  DC.B  $d  ; Status der Umschaltt. fÅr Kaltstart
reset_warm_shiftkeys  DC.B  $c  ; Status der Umschaltt. fÅr Warmstart
reset_scancode    DC.B      $53 ; Scancode fÅr Kalt und Warmstart
                  SYNC
m_VideoBytes      DC.W    100   ; Anzahl der Bytes pro Zeile monochrom
m_VideoMemory     DC.L  50000   ; Grîûe des Bildschirms monochrom
tmon_offset_mon   DC.L   5010   ; BildschirmOffset Monochrom falls Hyperscreen
                                ; Modus; wird in Bytes angegeben und zum
                                ; Bildschirmoffset addiert.
c_VideoBytes      DC.W    236   ; Anzahl der Bytes pro Zeile Farbe
c_VideoMemory     DC.L  73160   ; Grîûe des Bildschirms Farbe
tmon_offset_col   DC.L  13018   ; dito wie tmon_offset_mon nur fÅr Color-
                                ; betrieb
t_VideoBytes      DC.W    160   ; Anzahl der Bytes pro Zeile
t_VideoMemory     DC.L 153600   ; Grîûe des Bildschirms TT Hochauflîsend
tmon_offset_tt    DC.L     00   ;
sync_shiftkeys    DC.B      $c  ; Status der Umschaltt. fÅr Resynchronisation
sync_scancode     DC.B      $66 ; Scancode fÅr Resync.
                  SYNC
sync_time_mono    DC.W      $2000  ; Resynchronisationszeit in 10*Takt fÅr
                                   ; Monochrom Auflîsung
sync_time_mid50   DC.W      $3000  ; Resynchronisationszeit fÅr Mid 50 Hertz
sync_time_mid60   DC.W      $2500  ; Resynchronisationszeit fÅr Mid 60 Hertz
sync_time_low50   DC.W      $3000  ; Resynchronisationszeit fÅr Low 50 Hertz
sync_time_low60   DC.W      $2500  ; Resynchronisationszeit fÅr Low 60 Hertz
video_sync_flag   DC.B      0   ; <> 0 Video Sync Register mit video_sync_byte
                                ; fÅllen
video_sync_byte   DC.B      2   ; Inhalt des Video Sync Registers, wenn nicht
                                ; der ursprÅngliche Inhalt gesetzt werden soll
video_sync_intern DC.B      $FF ; zum Testen auf interne Synchronisation
                                ; schalten. 0 = externe Sync.
abort_key_mask    DC.B      1   ; Rechte Shift Taste Installationsabbruch
edit_lines        DC.B      20  ; Anzahl der zu puffernden Eingabezeilen
                  SYNC
mono_0            DC.W      0   ; Inhalt des Farbregisters 0 bei Mono
tt_mono_0         DC.W      0
tt_mono_1         DC.W      $FFFF
color_0           DC.W      $0000
color_1           DC.W      $FFFF
color_2           DC.W      $FFFF
color_3           DC.W      $FFFF
edit_modus        DC.B      $FF  ; $FF = Insert Modus, 0 = Overwrite Modus
                                 ; (Ins toggelt Mode)
                                 ; $7F = LeerzeicheneinfÅgemodus
                                 ; (generell Overwrite Modus, Ins fÅgt
                                 ;  Leerzeichen ein)
edit_modus2       DC.B      0    ; 0 TempleMon original Keyboard Umschaltbelegung
                  SYNC
edit_minimum      DC.B      3    ; MindestlÑnge einer Eingabezeile, die im
                                 ; Historypuffer gespeichert wird.
sync_on_shiftkeys DC.B      $c   ; Status der Umschaltt. fÅr interne Synchronisation
sync_on           DC.B      78   ; interne Synchronisation
sync_off_shiftkeys DC.B     $c   ; Status der Umschaltt. fÅr externe Synchronisation
sync_off          DC.B      74   ; externe Synchronisation
                  SYNC
more_edit         DC.W     300   ; zusÑtzlicher Bildschirmspeicher fÅr
                                 ; Fullscreeneditor in Bildschirmzeilen skaliert
SRPatch           DC.W      -1   ; soll ein MOVE vom SR durch TempleMon gestoppet
                                 ; werden, oder soll die TOS Routine angesprungen
                                 ; werden? (0=TempleMon Routine sonst TOS)
DIVZPatch         DC.W      -1   ; soll beim DIVZ eine Exeption ausgelîst werden?
                                 ; (0=TempleMon Routine sonst TOS)
KeyCheck          DC.W      -1   ; Keyboardcheck durchfÅhren? (0=Nein)
TMonFPCR          DC.W      0    ; Floating Point Control Register innerhalb
                                 ; TempleMons
XBRATab
(*$? NOT Debug:   ASC 'TMon' *)  ; Alle XBRA Kennungen, bei deren
(*$?     Debug:   ASC 'tmON' *)  ;
                  ASC 'MM2X'     ; vorhandensein die Suche nach dem
                  ASC 'SMon'     ; Tastaturvektoren abgebrochen wird
                  ASC 'KbEv'
                  ASC 'PROT'
                  ASC 'EUek'
                  ASC 'macc'
                  DC.L 0
                  DC.L 0
                  DC.L 0
                  DC.L 0         ; derhier muû immer Null sein (Endekennzeichen!)

no_Atari_OS       DC.W 0         ; <>0 nutze fÅr TOS Anfang/Ende die Vars
                                 ; OS_Start bzw. OS_Ende
OS_Start          DC.L $00FC0000 ; Betriebssystemstart
OS_Ende           DC.L $00FF0000 ; Betriebssystemende
virtuell          DC.W $8080     ; <> 0 : Virtuelle SpeicherunterstÅtzung
                                 ; die folgenden Bits bestimmen, ob TempleMon
                                 ; sich meldet (0), oder in den Speichermanager
                                 ; gesprungen (1) wird:
                                 ; Bit 0 : Supervisor violation
                                 ; Bit 1 : Write violation
                                 ; Bit 2 : Limit violation
                                 ; Bit 3 : Invalid descriptor or page fault
                                 ; Bit 4 : Bus error during table search
screensaver       DC.W -1        ; Screensaver (z.B.) Maccel durch anspringen
                                 ; des IKBDSYS aufwecken (<>0) oder nicht (=0)
debugging         DC.L $00000000 ; Finger weg von dieser Variablen!
debug_xbra                       ; Finger weg von dieser Variablen!
(*$? NOT Debug:   ASC 'tmON' *)
(*$?     Debug:   ASC 'TMon' *)

          ASC     'TemplemonVarEnd'
          DC.B    0
          DC.L    TMonVersion
          DC.L    TMonDatum

LocVarP   DS      4             ; ^ BSS  (A4)
KeyIORcV  ds      4             ; ADC
KbshiftV  ds      4             ; ADC
(*$? ADC:
IKBDSYSV  ds      4             ; ADC
OldMiKey  ds      4             ; ADC
;CtlAltHl  ds      2             ; ADC
*)

;*** MESSAGES

(*$ ? German:
!UsrBPMsg ACZ  'Stop durch User-Trace Routine'
!ExcMsg   ACZ  'Exception #'
!Exc2Msg  ACZ  ': '
!ERRMSG   ACZ  'Fehler: '
LOADMSG   ACZ  'Lade ab '
SAVEMSG   ACZ  'Speichere ab '
!ENDMSG   ACZ  ', erste unbenutzte Adresse: '
!RTNMSG   ACZ  'RÅckkehr von GS'
!Lck01MSG ACZ  'Tastaturflanke restauriert'
!Lck02MSG ACZ  'Tastaturdatenrichtung restauriert'
!Lck03MSG ACZ  'Interruptvektorregister restauriert'
!Lock1MSG ACZ  'Tastaturinterrupt gesperrt'
!Lock2MSG ACZ  'Interruptregister A schwebend: '
!Lock3MSG ACZ  'Interruptregister B schwebend: '
!Lock4MSG ACZ  'Tastaturinterrupt maskiert'
!Lock5MSG ACZ  'Interruptregister A in Bearbeitung: '
!Lock6MSG ACZ  'ACSI Bus Interrupt in Bearbeitung'
!Lock7MSG ACZ  'Tastaturinterrupt in Bearbeitung'
!Lock8MSG ACZ  'MFP-Tastaturinterruptvektor restauriert'
!Lock9MSG ACZ  'IKBDSYS-Tastaturinterruptvektor restauriert'
(*
!NoFPUMsg ACZ  'Keine FPU vorhanden'
!InvalidFrameMsg
          ACZ  'UngÅltiger State Frame'
!NullFrameMsg
          ACZ  'Null State Frame'
!BusyFrameMsg
          ACZ  'Busy State Frame, Version Nr.:'
!IdleFrameMsg
          ACZ  'Idle State Frame, Version Nr.:'
!ComCondMsg
          ACZ  'Command/Condition Register         ='
!ExOpMsg  ACZ  'Exeptional Operanden               :'
!OpRegMsg ACZ  'Operandregister                    ='
!PTypeMsg ACZ  'Pending Operand Typ                :'
*)
!MMUCONFMsg
          ACZ  'MMU Configuration Error'
!LINEFMsg ACZ  'Line F Code'
!COPPROMsg
          ACZ  'Coprocessor Protocol Error: CPU meldet Hardware Fehler'
!COPPROMsg1
          ACZ  'FPU Schnittstellenregisterinhalt RESPONSE: '
!COPPROMsg2
          ACZ  'Coprocessor Protocol Error: Unerwarteter Zugriff auf FPU'
!UCONDMsg ACZ  'FPU: Unordered Condition'
!FPUDIVZMsg
          ACZ  'FPU: Division durch Null'
!INEXACTMsg
          ACZ  'FPU: Ungenaues Ergebnis'
!UFLOWMsg ACZ  'FPU: Unterlauf'
!OFLOWMsg ACZ  'FPU: öberlauf'
!OPERRMsg ACZ  'FPU: Operanden Fehler'
!NANMsg   ACZ  'FPU: Keine reelle Zahl'
!UNIMDAMsg ACZ 'FPU: Nicht implementierter Datentyp'
!FrmErMsg ACZ  'Format Error'
!ILLMSG   ACZ  'Illegale Instruktion'
!ILLIMSG  ACZ  'Illegaler Interrupt'
!UNINMSG  ACZ  'Nicht initialisierter Interrupt'
!IRQMSG   ACZ  'Interrupt #'
!TRAPMSG  ACZ  'Trap #'
!TRPVMSG  ACZ  'TRAPV, TRAPcc, FTRAPcc - Instruktion'
!CHKMSG   ACZ  'CHK - Instruktion'
!BRKMSG   ACZ  'BREAK - Instruktion'
!BPMSG    ACZ  'Stop durch Breakpoint'
!DIVMSG   ACZ  'Division durch Null'
!PRIVMSG  ACZ  'Privilegs-Verletzung'
!KBDEMSG  ACZ  'Unterbrechung durch Tastatur'
!DirCMSG  ACZ  'Direktaufruf (JSR)'
!BPNMSG   ACZ  'Stop durch Breakpoint #'
!TRMMSG   ACZ  'Tracemodus '
NAKTMSG   ACZ  'nicht aktiv'
AKTMSG    ACZ  'aktiv'
!CFLMSG   ACZ  ' C:'
!RMDMSG   ACZ  ' R:'
!BEMSG    ACZ  'BUS ERROR bei '
!MMU_invalid_MSG
          DC.B CR,LF
          ACZ  'MMU: UngÅltiger Deskriptor oder Seitenfehler'
!MMU_buserror_MSG
          DC.B CR,LF
          ACZ  'MMU: BUS ERROR wÑhrend Tabellensuche'
!MMU_limit_violation_MSG
          DC.B CR,LF
          ACZ  'MMU: Bereichsverletzung'
!MMU_write_violation_MSG
          DC.B CR,LF
          ACZ  'MMU: Schreibschutzverletzung'
!MMU_supervisor_violation_MSG
          DC.B CR,LF
          ACZ  'MMU: Privilegsverletzung'
!AEMSG    ACZ  'ADDRESS ERROR bei '
!SRMSG    ACZ  ' - SR:'
!SSRMSG   ACZ  ' / Super-SR:'
!EBFMSG   ACZ  ' / Instruktion:'
ProtMsg   ACZ     'Protokolldatei ge'
OpMsg     ACZ     'oeffnet'
ClosMsg   ACZ     'schlossen'
IOResMsg  ACZ     'TOS-Error #'
ShBPMsg   ACZ     'Breakpoint gesetzt auf '
SkipMsg   ACZ     'Nicht ausgefuehrt.'
BPErrMsg  ACZ     'Breakpoint konnte nicht gesetzt werden auf '
noBPsMsg  DC.B    CR
          ACZ     'Keine Breakpoints gesetzt'
noMemMsg  ACZ     'Kein genÅgend grosser Speicherbereich frei'
OkMsg     ACZ     'OK.'
notAllocMsg ACZ     'Bereich war unbelegt'
noInstallMsg1 DC.B CR,LF
          ASC     'TempleMon ist schon installiert.'
          DC.B    CR,LF,7,0
noInstallMsg DC.B CR,LF
          ASC     'TempleMon nicht installiert.'
          DC.B    CR,LF,7,0
vecmsg1   ACZ      'Restauriere Vektor auf '
vecmsg2   ACZ      ' / alter Wert '
*)

(*$ ? English:
  !UsrBPMsg ACZ  'Break by user trace program'
  !ExcMsg   ACZ  'Exception #'
  !Exc2Msg  ACZ  ': '
  !ERRMSG   ACZ  'Error: '
  LOADMSG   DC.B CR,LF
            ACZ  'Loading from '
  SAVEMSG   DC.B CR,LF
            ACZ  'Saving from '
  !ENDMSG   ACZ  ', first unused address: '
  !RTNMSG   ACZ  'Return from GS'
  !Lck01MSG ACZ  'Keyboard active edge restored'
  !Lck02MSG ACZ  'Keyboard data direction restored'
  !Lck03MSG ACZ  'Interrupt vector register restored'
  !Lock1MSG ACZ  'Keyboardinterrupt disabled'
  !Lock2MSG ACZ  'Interruptregister A pending: '
  !Lock3MSG ACZ  'Interruptregister B pending: '
  !Lock4MSG ACZ  'Keyboardinterrupt masked'
  !Lock5MSG ACZ  'Interruptregister A in Service: '
  !Lock6MSG ACZ  'ACSI Bus Interrupt in Service'
  !Lock7MSG ACZ  'Keyboardinterrupt in Service'
  !Lock8MSG ACZ  'MFP-Keyboardinterruptvector restored to TempleMon'
  !Lock9MSG ACZ  'IKBDSYS-Keyboardinterruptvector restored to TempleMon'
  !TRCMSG   ACZ  'Trace'
(*
  !NoFPUMsg ACZ  'No FPU present'
  !InvalidFrameMsg
            ACZ  'Invalid State Frame'
  !NullFrameMsg
            ACZ  'Null State Frame'
  !BusyFrameMsg
            ACZ  'Busy State Frame, version num.:'
  !IdleFrameMsg
            ACZ  'Idle State Frame, version num.:'
  !ComCondMsg
            ACZ  'Command/Condition register='
  !ExOpMsg  ACZ  'Exeptional operands: '
  !OpRegMsg ACZ  'Operandregister='
  !PTypeMsg ACZ  'Pending operand type: '
*)
  !MMUCONFMsg
            ACZ  'MMU Configuration Error'
  !LINEFMsg ACZ  'Line F Code'
  !COPPROMsg
            ACZ  'Coprocessor Protocol Error: CPU detected hardware failure'
  !COPPROMsg1
            ACZ  'Contents of FPU Coprocessor Interface Register RESPONSE: '
  !COPPROMsg2
            ACZ  'Coprocessor Protocol Error: unexpected access to FPU'
  !UCONDMsg ACZ  'FPU: Unordered Condition'
  !FPUDIVZMsg
            ACZ  'FPU: Division by zero'
  !INEXACTMsg
            ACZ  'FPU: Inexact Result'
  !UFLOWMsg ACZ  'FPU: Underflow'
  !OFLOWMsg ACZ  'FPU: Overflow'
  !OPERRMsg ACZ  'FPU: Operand error'
  !NANMsg   ACZ  'FPU: Not a number'
  !UNIMDAMsg ACZ 'FPU: Unimplemented data type'
  !FrmErMsg ACZ  'Format Error'
  !ILLMSG   ACZ  'Illegal instruction'
  !UNINMSG  ACZ  'Uninitialized interrupt'
  !ILLIMSG  ACZ  'Illegal interrupt'
  !IRQMSG   ACZ  'Interrupt #'
  !TRAPMSG  ACZ  'Trap #'
  !TRPVMSG  ACZ  'TRAPV instruction'
  !CHKMSG   ACZ  'CHK instruction'
  !BRKMSG   ACZ  'BREAK instruction'
  !DIVMSG   ACZ  'Division by zero'
  !PRIVMSG  ACZ  'Privilege violation'
  !KBDEMSG  ACZ  'Keyboard break'
  !DirCMSG  ACZ  'Direct call (JSR)'
  !BPMSG    ACZ  'Entry by breakpoint'
  !BPNMSG   ACZ  'Entry by breakpoint #'
  !TRMMSG   ACZ  'Tracemode '
  NAKTMSG   ACZ  'not active'
  AKTMSG    ACZ  'active'
  !CFLMSG   ACZ  ' C:'
  !RMDMSG   ACZ  ' R:'
  !BEMSG    ACZ  'BUS ERROR at '
  !MMU_invalid_MSG
            DC.B CR,LF
            ACZ  'MMU: Invalid Descriptor or Page Fault'
  !MMU_buserror_MSG
            DC.B CR,LF
            ACZ  'MMU: BUS ERROR during table search'
  !MMU_limit_violation_MSG
            DC.B CR,LF
            ACZ  'MMU: Limit violation'
  !MMU_write_violation_MSG
            DC.B CR,LF
            ACZ  'MMU: Write violation'
  !MMU_supervisor_violation_MSG
            DC.B CR,LF
            ACZ  'MMU: Supervisor violation'
  !AEMSG    ACZ  'ADDRESS ERROR at '
  !SRMSG    ACZ  ' - SR:'
  !SSRMSG   ACZ  ' / super SR:'
  !EBFMSG   ACZ  ' / instruction:'
  ProtMsg   DC.B    CR,LF
            ACZ     'Protocol file '
  OpMsg     ACZ     'opened'
  ClosMsg   ACZ     'closed'
  IOResMsg  DC.B    CR,LF
            ACZ     'TOS error #'
  ShBPMsg   ACZ     'Breakpoint set at '
  SkipMsg   ACZ     'Skipped.'
  BPErrMsg  ACZ     'Unable to set breakpoint at '
  noBPsMsg  ACZ     'No breakpoints set'
  noMemMsg  DC.B  CR,LF
            ACZ     'No sufficient memory block available'
  OkMsg     DC.B  CR,LF
            ACZ     'OK.'
  notAllocMsg DC.B  CR,LF
            ACZ   "Block hasn't been allocated"
  noInstallMsg1 DC.B CR,LF
            ASC     'TempleMon is already installed.'
            DC.B    CR,LF,7,0
  noInstallMsg DC.B CR,LF
            ASC     'TempleMon not installed.'
            DC.B    CR,LF,7,0
  vecmsg1   ACZ      'Restore vector at '
  vecmsg2   ACZ      ' / old value '
*)


(*$ ? German:
ErrorList ACZ     "Unbekannte Funktion. '?' zeigt mehr..."
          ACZ     'Zahl erwartet'
          ACZ     'Zahl zu gross'
          ACZ     'Anfangsadr. ist groesser als Endadr.'
          ACZ     'Ueberfluessige Zeichen in Eingabe'
          ACZ     'Ungerade Adresse'
          ACZ     'SPACE erwartet'
          ACZ     'Falsche Registerbezeichnung'
          ACZ     'G-Funktion mit PC=0 nicht erlaubt'
          ACZ     'Leerstring nicht zulaessig'
          ACZ     'String zu lang'
          ACZ     'Fehlende Adresse / Parameter'
          ACZ     'BUS ERROR'
          ACZ     'ADDRESS ERROR'
          ACZ     'Allg. Syntax Fehler'
          ACZ     'Operator erwartet'
          ACZ     'Unzulaessiges Register'
          ACZ     'Zu viele Parameter'
          ACZ     'Koprozessor Protokoll Fehler'
          ACZ     'Unbekanntes Symbol'
          DC.B    0
          ACZ     'Undefinierter Fehler'
*)

(*$ ? English:
ErrorList ACZ     "Illegal command. Enter '?' for information"
          ACZ     'Number expected'
          ACZ     'Number too big'
          ACZ     'Start address exceeds end address'
          ACZ     'Illegal characters in command line'
          ACZ     'Odd address'
          ACZ     'SPACE expected'
          ACZ     'Wrong name for register'
          ACZ     'G-function with PC = 0 not allowed'
          ACZ     'Empty string is not allowed'
          ACZ     'String too long'
          ACZ     'Missing address / parameter'
          ACZ     'BUS ERROR'
          ACZ     'ADDRESS ERROR'
          ACZ     'Syntax error'
          ACZ     'Operator expected'
          ACZ     'Illegal register'
          ACZ     'Too many parameters'
          ACZ     'Coprocessor protocol violation'
          ACZ     'Unknown symbol'
          DC.B    0
          ACZ     'Undefined error'
*)

SNANMsg   ASC     'S'
NSNANMsg  ACZ     'NAN'
          SYNC
InfinityMsg ACZ   'INFINITY'
          SYNC

;----------------------------------------------------------------------------
;         ****  MONITOR-VECTOR INITIALISIERUNG  ****


!ChgVec   ; Vektor neu setzen und ggf. (wenn D0<>0) anzeigen
          ; A0: Entryadr. (mit XBRA-Vorsatz), A1: Vektoradr.
(*
          MOVE.L  (A1),-4(A0)        ; alten Vektor sichern
          MOVE.L  A0,(A1)
          RTS
*)
          TST.W   is20(A4)
          BNE     is20_8
          CLR.B   (A1)
!is20_8
          MOVEM.L A2/A3/A5/A6/D2/D3/D4,-(SP)
          MOVE.L  BUSERRV,D2
          MOVE.L  ADRERRV,D3
          MOVE.L  SP,A5
          MOVE.W  SR,D4
          LEA     ChgNoVecB(PC),A2
          MOVE.L  A2,BUSERRV
          LEA     ChgNoVecA(PC),A2
          MOVE.L  A2,ADRERRV
          CMPA.L  (A1),A0            ; ist noch Templemon-Vektor?
          BEQ.L   ChgNoVec
          TST.B   onlyTOSvec(A4)
          BEQ     ChgVec01
(*$? ~MAC:
          ; erkennen, ob Vektor ins TOS zeigt
          MOVE.W  D0,-(SP)
          MOVE.W  no_Atari_OS(PC),D0
          BEQ.S   isATARI_TOS
          MOVE.W  (SP)+,D0
          CMPA.L  OS_Start(PC),A3
          BCS.L   ChgNoVec
          CMPA.L  OS_Ende(PC),A3
          BHI.L   ChgNoVec
          BRA.S   ChgVec01
!isATARI_TOS
          MOVE.W  (SP)+,D0
          MOVE.L  $4F2,A2
          MOVE.L  (A1),A3
          CMPA.L  4(A2),A3
          BCS.L   ChgNoVec           ; Vektor unterhalb OS Start
          CMPA.L  $14(A2),A3
          BHI.L   ChgNoVec           ; Vektor Åberhalb OS Ende (Code)
*)
(*$? MAC:
          ; erkennen, ob Vektor bereits umgelekt ist.
          MOVE.L  (A1),A3
          CMPA.L  $FC,A3             ; $FC zeigt auf "MagiCException"
          BNE.L   ChgNoVec
*)
!ChgVec01
          TST.W   D0
          BEQ     ChgVec0
          MOVEM.L D0/A0/A1,-(A7)
          BSR     PrtCRLF
          LEA     vecmsg1(PC),A1
          BSR     PrtStr
          MOVE.L  8(A7),D0           ; A1
          BSR     PrtAdr             ; print Vektor-Adr
          LEA     vecmsg2(PC),A1
          BSR     PrtStr
          MOVE.L  8(A7),A0           ; A1
          MOVE.L  (A0),D0
          BSR     PrtAdr             ; print old vector value
          MOVEM.L (A7)+,D0/A0/A1
!ChgVec0  MOVEM.L D0-D2,-(SP)        ; XBRA Kette nach TempleMon Routine
          MOVE.L  ADRERRV,-(SP)
          MOVE.L  BUSERRV,-(SP)      ; absuchen, und aushÑngen; Buserror wird abgefangen
          MOVE.L  A0,D0              ; Adresse TempleMon Routine
          TST     is20(A4)
          BNE     ChgVec00_1
          ANDI.L  #$00FFFFFF,D0      ; nur 24 Bit Adressbus
!ChgVec00_1 MOVE.W  SR,D1
          LEA     ChgVec01_0(PC),A2
          MOVE.L  A2,BUSERRV
          LEA     ChgVec01_1(PC),A2
          MOVE.L  A2,ADRERRV
          MOVE.L  A7,A2
          MOVE.L  (A1),A3            ; Vektor holen
          CMPA.L  #BUSERRV,A1        ; Buserror Vektor?
          BNE     ChgVec00_12
          MOVEA.L D2,A3              ; ja: dann Buserror Kopie
          BRA     ChgVec00_13
!ChgVec00_12
          CMPA.L  #ADRERRV,A1        ; Adresserror Vektor?
          BNE     ChgVec00_13
          MOVEA.L D3,A3              ; ja: dann Adresserror Kopie
!ChgVec00_13
          MOVE.L  A1,D2
          TST     is20(A4)
          BNE     ChgVec00_T
          EXG     D0,A3
          ANDI.L  #$00FFFFFF,D0      ; nur 24 Bit Adressbus
          EXG     D0,A3
!ChgVec00_T CMP.L  A3,D0             ; Zeigt Vektor direkt auf TempleMon Routine?
          BNE     ChgVec00_L         ; nein, dann suchen
          MOVE.L  (SP)+,BUSERRV      ; ja, dann nichts unternehmen
          MOVE.L  (SP)+,ADRERRV
          MOVEM.L (SP)+,D0-D2
          BRA.L   ChgNoVec
!ChgVec00_L TST     is20(A4)
          BNE     ChgVec00_2
          EXG     D0,A3
          ANDI.L  #$00FFFFFF,D0
          EXG     D0,A3
!ChgVec00_2 CMP.L  A3,D0
          BEQ     ChgVec00_F
          CMPI.L  #$58425241,-12(A3) ; XBRA ?
          BNE     ChgVec02           ; nein, dann alten Vektor nicht herauslîsen
          MOVE.L  A3,D2              ; Vektor sichern
          MOVE.L  -4(A3),A3          ; nÑchste Ebene
          BRA     ChgVec00_L
!ChgVec00_F MOVEA.L D2,A6            ; TempleMon Routine aus Struktur ausklinken
          MOVE.L  -4(A3),D2
          MOVE.L  D2,-4(A6)
          BRA     ChgVec02
!ChgVec01_0 BSR    TestMMUBusError
!ChgVec01_1 MOVE.W  D1,SR
          MOVE.L  A2,A7
!ChgVec02 MOVE.L  (SP)+,BUSERRV
          MOVE.L  (SP)+,ADRERRV
          MOVEM.L (SP)+,D0-D2
          MOVE.L  (A1),-4(A0)        ; alten Vektor sichern
          MOVE.L  A0,(A1)
          CMPA.L  #BUSERRV,A1
          BNE     ChgVec1
          MOVE.L  D2,-4(A0)
          BRA     ChgVec2
!ChgVec1  MOVE.L  D2,BUSERRV
!ChgVec2  CMPA.L  #ADRERRV,A1
          BNE     ChgVec3
          MOVE.L  D3,-4(A0)
          BRA     ChgNoVec1
!ChgVec3  MOVE.L  D3,ADRERRV
          BRA     ChgNoVec1
!ChgNoVecB BSR     TestMMUBusError
!ChgNoVecA MOVE.L  A5,SP
          MOVE.W  D4,SR
!ChgNoVec MOVE.L  D2,BUSERRV
          MOVE.L  D3,ADRERRV
!ChgNoVec1 MOVEM.L (SP)+,A2/A3/A5/A6/D2/D3/D4
          RTS

; Parameter: D0: 1->énderungen anzeigen; D1: 1->alle Traps setzen
!InitVec  SF      onlyTOSvec(A4)
          LEA     EyBUS(PC),A0
          LEA     BUSERRV,A1
          BSR     ChgVec

          LEA     EyADR(PC),A0
          LEA     ADRERRV,A1
          BSR     ChgVec

          LEA     EyTRC(PC),A0
          LEA     TraceV,A1
          BSR     ChgVec

          LEA     EyPRIV(PC),A0
          LEA     PRIVV,A1
          BSR     ChgVec

          LEA     EyDIV(PC),A0
          LEA     DIVZV,A1
          BSR     ChgVec

          LEA     EyCHK(PC),A0
          LEA     CHKV,A1
          BSR     ChgVec

          LEA     EyTRAPV(PC),A0
          LEA     TRAPVV,A1
          BSR     ChgVec

          LEA     EyILL(PC),A0
          LEA     ILLCMDV,A1
          BSR     ChgVec

          TST     is10(A4)
          BEQ     InitVec10
          LEA     EyFrm(PC),A0
          LEA     FRMERRV,A1
          BSR     ChgVec
!InitVec10
          LEA     EyILLIRQ(PC),A0
          LEA     ILLIRQV,A1
          BSR     ChgVec

          ST      onlyTOSvec(A4)  ; nur wenn Vector ins TOS zeigt Ñndern!
          LEA     EyDirC(PC),A0
          LEA     IRQ1V,A1
          BSR     ChgVec

          LEA     EyIRQ(PC),A0
(*$?~Mac:
          LEA     IRQ3V,A1        ; IRQ NO.3 EXCEPTION VEKTOR
          BSR     ChgVec
          LEA     IRQ5V,A1        ; IRQ NO.5 EXCEPTION VEKTOR
          BSR     ChgVec
*)
          LEA     IRQ7V,A1        ; NMI
          BSR     ChgVec
          SF      onlyTOSvec(A4)

!InitVec20 TST     is20(A4)
          BEQ.L   InitVecTrap
          LEA     EyUNININT(PC),A0
          LEA     UNININTV,A1     ; Uninitialized Interrupt
          BSR     ChgVec
          ST      onlyTOSvec(A4)  ; nur wenn Vector ins TOS zeigt Ñndern!
          LEA     EyLINEF(PC),A0
          LEA     EM1111V,A1      ; LINE F Emulator
          BSR     ChgVec
          SF      onlyTOSvec(A4)

          TST     is40(A4)
          BNE     InitVec30
          LEA     EyCOPPRO(PC),A0
          LEA     COPPROV,A1      ; Coprocessor Protocol Error (Hardware)
          BSR     ChgVec

!InitVec30 TST     is30(A4)
          BEQ.S   InitVecFPU
          LEA     EyMMUCONF(PC),A0
          LEA     MMUCONFV,A1     ; PMMU Configuration Exeption
          BSR     ChgVec

!InitVecFPU
          TST     isFPU(A4)
          BEQ.S   InitVecTrap
          LEA     EyUCOND(PC),A0
          LEA     UCONDV,A1       ; FPU : Unordered Condition
          BSR     ChgVec
          LEA     EyFPUDIVZ(PC),A0
          LEA     FPUDIVZV,A1     ; FPU : Division by Zero
          BSR     ChgVec
          LEA     EyINEXACT(PC),A0
          LEA     INEXACTV,A1     ; FPU : Inexact Result
          BSR     ChgVec
          LEA     EyUFLOW(PC),A0
          LEA     UFLOWV,A1       ; FPU : Underflow
          BSR     ChgVec
          LEA     EyOFLOW(PC),A0
          LEA     OFLOWV,A1       ; FPU : Overflow
          BSR     CHGVEC
          LEA     EyOPERR(PC),A0
          LEA     OPERRV,A1       ; FPU : Operand Error
          BSR     ChgVec
          LEA     EyNAN(PC),A0
          LEA     NANV,A1         ; FPU : Not a Number
          BSR     ChgVec
          TST     is40(A4)
          BEQ     InitVecTrap
          LEA     EyUNIMDA(PC),A0
          LEA     UNIMDAV,A1      ; FPU : Unimplemented Data Typ
          BSR     ChgVec

!InitVecTrap
          ST      onlyTOSvec(A4)
          LEA     EyTRAP0(PC),A0     ; TRAP #6
          LEA     Trap6V,A1
          BSR     ChgVec

          TST.L   D1
          BEQ     noMoreTraps
          LEA     Trap0V,A1
          BSR     ChgVec
          LEA     Trap3V,A1
          BSR     ChgVec
          ADDQ.L  #4,A1
          BSR     ChgVec        ; 4
          ADDQ.L  #4,A1
          BSR     ChgVec        ; 5
          ADDQ.L  #8,A1
          BSR     ChgVec        ; 7
          ADDQ.L  #4,A1
          BSR     ChgVec        ; 8
          ADDQ.L  #4,A1
          BSR     ChgVec        ; 9
          ADDQ.L  #4,A1
          BSR     ChgVec        ; 10
          ADDQ.L  #4,A1
          BSR     ChgVec        ; 11
          ADDQ.L  #4,A1
          BSR     ChgVec        ; 12
          ADDA.W  #12,A1
          BSR     ChgVec        ; 15
!noMoreTraps
          SF      onlyTOSvec(A4)
(*$? AltHelp:
          LEA     EyKBD(PC),A0
          LEA     $502,A1
          BSR     ChgVec
*)
          TST     StkFrm(A4)
          BNE     noSetMSB
          ;MSBytes der Vektoren 2-63 (und MFP-Vektoren) neu setzen
!tteess   MOVE.L  A7,D1
          MOVE.W  SR,D2
          MOVEA.L BUSERRV,A2
          MOVEA.L ADRERRV,A3
          LEA     SETMSBY_B(PC),A0
          MOVE.L  A0,BUSERRV
          LEA     SETMSBY_A(PC),A0
          MOVE.L  A0,ADRERRV
          MOVEQ   #2,D0
!SETMSBY  MOVE.L  D0,A0
          ADDA.L  A0,A0
          ADDA.L  A0,A0
          MOVE.L  (A0),A1
          CMPI.L  #$58425241,-12(A1)     ; zeigt Vektor auf TempleMon Routine mit
          BNE     SETMSBY_1              ; XBRA Kennung?
(*$? NOT Debug:
          CMPI.L  #$544D6F6E,-8(A1) *)
(*$?     Debug:
          CMPI.L  #$746D4F4E,-8(A1) *)
          BNE     SETMSBY_1
!SETMSBY_0 MOVE.B  D0,(A0)
          BRA     SETMSBY_1
!SETMSBY_B BSR     TestMMUBusError
!SETMSBY_A MOVE.W  D2,SR
          MOVE.L  D1,A7
!SETMSBY_1 ADDQ.W  #1,D0
          CMPI    #64+16,D0
          BCS     SETMSBY
          MOVE.L  A2,BUSERRV
          MOVE.L  A3,ADRERRV
!noSetMSB RTS

;*****************************************************************

!saveCodeLen DS    4
!oldSP       DS    4

;*****************************************************************

!Test40CRAW                     ; Registerauswahl bei 68040auf 40er Register testen
          TST     is40(A4)
          BEQ     Test40CRAWE
          MOVE.L  RegWahl(A4),D0
          BCLR    #TNrCAAR,D0   ; CAAR Register lîschen
          MOVE.L  D0,RegWahl(A4)
          MOVE.L  RegWahl2(A4),D0
          BCLR    #(TNrTT0-TnrLast20),D0
          BCLR    #(TNrTT1-TnrLast20),D0
          BCLR    #(TNrCRP-TnrLast20),D0
          MOVE.L  D0,RegWahl2(A4)
!Test40CRAWE
          RTS

;#################################################################

!ComdH    BCLR    #11,D7
          LEA     Hilf1L(A4),A1
          BSET    #12,D7          ; Ungerade Adr. erlaubt
          BSR.L   GETAE           ; HOLE ANF.- UND END - ADR.
          BEQ     ERR11           ; ERROR: BEIDE ADR. ANGEBEN !
          BSR.L   GETFNDBF        ; HOLE SUCH-/ FöLL-STRING
;          BSR     PrtCRLF
          BSR     PrtSPC
          MOVEQ   #10,D5
          TST     is20(A4)
          BEQ     CHC7
          MOVEQ   #8,D5           ; bei Long-Adressen nur 8 Werte pro Zeile
!CHC7     MOVE    D5,-(A7)
!CHL1     CLR.L   D4              ; ZAEHLER F. STRINGLAENGE
!CHL2     BTST    D4,D3           ; JOKER ?
          BNE.S   CHC2            ; JA: NAECHSTES ZEICHEN VERGLEICHEN
          MOVE.B  0(A2,D4.W),D0   ; ZEICHEN AUS SPEICHER LADEN
          CMP.B   0(A1,D4.W),D0   ; MIT STRING IDENTISCH ?
          BEQ.S   CHC2            ; JA
!CHC3     ADDQ.L  #1,A2
          CMPA.L  A3,A2
          BCS     CHL1
!CHC6     ADDQ.L  #2,A7
          BRA     PrtCRLF
;          RTS

!CHC2     ADDQ.W  #1,D4
          CMP.B   D2,D4           ; GANZER STRING VERGLICHEN ?
          BLS     CHL2            ; NEIN: NAECHSTES ZEICHEN VERGLEICHEN
          LEA     FindBuf(A4),A0
          CMPA.L  A0,A2           ; ADR = SUCHSTRING-BUFFER ?
          BEQ     CHC3
          CMPA.L  A5,A2           ; ADR = EINGABE-BUFFER ?
          BEQ     CHC3

          ; STRING innerhalb von History?
          CMPA.L  HistoryStart(PC),A2
          BCS     CHCB1
          CMPA.L  HistoryEnde(PC),A2
          BLS     CHC3
          ;STRING innerhalb von bMonScreen?
!CHCB1    CMPA.L  bMonScreenBase(PC),A2
          BCS     CHCB2
          CMPA.L  bMonScreenTop(PC),A2
          BLS     CHC3
          ;STRING innerhalb von Keyboardpuffer?
!CHCB2    LEA     Keybuf(A4),A0
          BCS     CHCB3
          ADDA.W  #ZEILLEN,A0
          BLS     CHC3
          ;STRING innerhalb von Keyboardpuffer2?
!CHCB3    LEA     Keybuf2(A4),A0
          BCS     CHCB4
          ADDA.W  #ZEILLEN,A0
          BLS     CHC3
!CHCB4
          ; STRING GEFUNDEN -> ausgeben
          MOVE.L  A2,D0
          BSR     PrtADR          ; ADR. AUSGEBEN
          SUBQ.W  #1,D5
          BNE     CHC4
          BSR     PrtCRLF
          MOVE    (A7),D5
          BRA     CHC5
!CHC4     BSR     PrtSPC
!CHC5     BSR     PrtSPC
          BSR.L   TSTKEY          ; TASTE GEDRöCKT ?
          BEQ     CHC3            ; NEIN: WEITERE STRINGS SUCHEN
          BRA     CHC6            ; JA: ABBRUCH

;#################################################################

; Line F Emulator - Entry ( Vectornr.$2C )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
!OldLineF DC.L      0
!EyLINEF
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Line_F_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          MOVE.L    A4,-(SP)
          MOVEA.L   LocVarP(PC),A4
          TST       is40(A4)            ; ist Åberhaupt eine 68040 vorhanden?
          BEQ.L     EyLineF_E
          TST       isFPU(A4)            ; ist Åberhaupt eine 68040 mit FPU vorhanden?
          BEQ.L     EyLineF_E
;          MOVEM.L   D0-D5/A0-A2,-(SP)
;          MOVE.L    42(A7),A1           ; den PC holen; Offset = 9 Reg*4 + 2
;          MOVE.L    A1,A2
;          MOVE.W    (A1),D2
;          BSR.L     TEST_FPU_CODE
;          BEQ       EyLineF_Return      ; gÅltigen FPU Befehl gefunden.
;          MOVEM.L   (SP)+,D0-D5/A0-A2
          MOVE.L    D0,-(SP)
          MOVE.W    14(SP),D0           ; Stackframeword
          ANDI.W    #$F000,D0
          CMPI.W    #$2000,D0
          BEQ       EyLineF_Return
          MOVE.L    (SP)+,D0
!EyLineF_E MOVE.L    (SP)+,A4
          BSR.L     PULLREGS
          LEA       LINEFMsg(PC),A1
          BRA.L     EntryC0
!EyLineF_Return
;          MOVEM.L   (SP)+,D0-D5/A0-A2
          MOVE.L    (SP)+,D0
          MOVE.L    (SP)+,A4
          MOVE.L    OldLineF(PC),-(SP)
          RTS
;

; FPU : Unordered Condition - Entry ( Vectornr.$C0 )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyUCOND
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Unordered_Condition_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       UCONDMsg(PC),A1
          BRA       EntryC0

; FPU : Division by Zero - Entry ( Vectornr.$C8 )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyFPUDIVZ
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Divide_by_Zero_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       FPUDIVZMsg(PC),A1
          BRA       EntryC0

; FPU : Inexact Result - Entry ( Vectornr.$C4 )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyINEXACT
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Inexact_Result_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       INEXACTMsg(PC),A1
          BRA       EntryC0

; FPU : Underflow - Entry ( Vectornr.$CC )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyUFLOW
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Underflow_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       UFLOWMsg(PC),A1
          BRA       EntryC0

; FPU : Overflow - Entry ( Vectornr.$D4 )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyOFLOW
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Overflow_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       OFLOWMsg(PC),A1
          BRA       EntryC0

; FPU : Operand Error - Entry ( Vectornr. $D0 )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyOPERR
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Operand_Error_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       OPERRMsg(PC),A1
          BRA       EntryC0

; FPU : Signaling not a Number - Entry ( Vectornr.$D8 )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyNAN
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Signaling_NAN_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       NANMsg(PC),A1
          BRA       EntryC0

; FPU : Unimplemented data typ - Entry ( Vectornr.$DC )

          ASC       'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
          DC.L      0
!EyUNIMDA
(*$? Test:
          MOVE.L  D0,-(SP)
          MOVEQ   #Unassigned_Bit,D0
          BSR     do_debug
          MOVE.L  (SP)+,D0 *)
          BSR.L     PULLREGS
          LEA       UNIMDAMsg(PC),A1
          BRA       EntryC0

;*****************************************************************

!PullReg2 ; wie PULLREGS, erwartet jedoch RTS-Adr und keine RTE-Adr auf Stack
          SUBQ.L  #4,A7
          MOVE.L  4(A7),(A7)
          MOVE.L  8(A7),6(A7)
          MOVE    SR,4(A7)
          CLR.W   10(A7)
          
!PULLREGS ORI     #$700,SR
          MOVE.L  A4,-(A7)
          MOVEA.L LocVarP(PC),A4
          MOVEM.L D0-A6,RgD0(A4)
          MOVE.L  (A7)+,RgA4(A4)
          BSR     TMonEnter

          TST     is10(A4)
          BEQ.L   is20_5_01
          MOVEC.L SFC,D0
          MOVE.L  D0,RgSFC(A4)
          MOVEC.L DFC,D0
          MOVE.L  D0,RgDFC(A4)
          MOVEC.L VBR,D0
          MOVE.L  D0,RgVBR(A4)
          TST     is20(A4)
          BEQ.L   is20_5_01
          MOVEC.L CACR,D0
          MOVE.L  D0,RgCACR(A4)
          TST     is40(A4)
          BEQ     is20_5_20er
                                 ; 40er Code
          DC.W    $4E7A,$0003    ; MOVEC   TC,D0
          MOVE.L  D0,RgTC(A4)
          DC.W    $4E7A,$0004    ; MOVEC   ITT0,D0
          MOVE.L  D0,RgITT0(A4)
          DC.W    $4E7A,$0005    ; MOVEC   ITT1,D0
          MOVE.L  D0,RgITT1(A4)
          DC.W    $4E7A,$0006    ; MOVEC   DTT0,D0
          MOVE.L  D0,RgDTT0(A4)
          DC.W    $4E7B,$0007    ; MOVEC   DTT1,D0
          MOVE.L  D0,RgDTT1(A4)
          DC.W    $4E7A,$0805    ; MOVEC   PSR,D0
          MOVE.L  D0,RgPSR(A4)
          DC.W    $4E7A,$0806    ; MOVEC   URP,D0
          MOVE.L  D0,RgURP(A4)
          DC.W    $4E7A,$0807    ; MOVEC   SRP,D0
          BRA     is20_5_02
!is20_5_20er
          MOVEC.L CAAR,D0        ; 20er und 30er Code
          MOVE.L  D0,RgCAAR(A4)
          TST     is30(A4)
          BEQ     is20_5_02
!is20_5_30er                      ; 30er Code
          LEA     RgTT0(A4),A0
          DC.W    $F010,$0A00    ; PMOVE   TT0,(A0)
          LEA     RgTT1(A4),A0
          DC.W    $F010,$0E00    ; PMOVE   TT1,(A0)
          LEA     RgTC(A4),A0
          DC.W    $F010,$4200    ; PMOVE   TC,(A0)
          LEA     RgPSR(A4),A0
          DC.W    $F010,$6200    ; PMOVE   PSR,(A0)
          LEA     RgCRP(A4),A0
          DC.W    $F010,$4E00    ; PMOVE   CRP,(A0)
          LEA     RgSRP(A4),A0
          DC.W    $F010,$4A00    ; PMOVE   SRP,(A0)
          BSR.L   TMon_address_translation_tree

!is20_5_02 TST     isFPU(A4)
          BEQ     is20_5_01
          LEA     StFrame(A4),A0
          FSAVE   (A0)
        FMOVEM.L  FPCR/FPSR/FPIAR,RgFPCR(A4)
          CLR.L   D0
          BSR     GetTMonFPCR
          FMOVE.L D0,FPCR
        FMOVEM.X  FP0-FP7,RgFP0(A4)

!is20_5_01
          MOVEA.L (A7)+,A1            ; RETURN-ADR. VON STACK HOLEN
          MOVE.W  (A7)+,RgSR(A4)      ; SR VON STACK
          MOVE.L  (A7)+,RgPC(A4)      ; EXCEPTION-RETURN-ADR. VON STACK
          TST.W   is20(A4)
          BNE     is20_5
          CLR.B   RgPC(A4)
!is20_5
          TST     StkFrm(A4)
          BEQ     noFrame

          ; Stack-Rest bei 68020 abrÑumen
          MOVE.W  (A7)+,D0
          MOVE.W  D0,D1
          ANDI.W  #$F000,D0
          CMPI.W  #$1000,D0
          BEQ     isMasterStack
!noMasterStack
          MOVE    D1,RgSF(A4)
          ROL     #5,D0
          ANDI    #$1E,D0
          LEA     SFTbl(PC),A0
          ADDA.W  0(A0,D0.W),A7
          BRA     noFrame
!isMasterStack
          MOVEC.L MSP,A2              ; der ISP ist jetzt richtig abgerÑumt
          MOVE.W  (A2)+,RgSR(A4)
          MOVE.L  (A2)+,RgPC(A4)
          MOVE.W  (A2)+,D0
          MOVE.W  D0,RgSF(A4)
          ROL     #5,D0
          ANDI    #$1E,D0
          LEA     SFTbl(PC),A0
          ADDA.W  0(A0,D0.W),A2
          MOVE.L  A2,RgMSP(A4)
          MOVEC.L A2,MSP

!noFrame  MOVE.L  A7,RgSSP(A4)        ; SP SAVEN
          MOVE.L  USP,A0
          MOVE.L  A0,RgUSP(A4)
          TST     is20(A4)
          BEQ     noFrame1
          MOVEC.L MSP,D0
          MOVE.L  D0,RgMSP(A4)
          MOVEC.L ISP,D0
          MOVE.L  D0,RgISP(A4)
!noFrame1 MOVE.L  MonStackHi(A4),A7
          PEA     (A1)
          TST.W   is20(A4)
          BNE     is20_6
          CLR.B   (A7)
!is20_6

          TST     StkFrm(A4)
          BEQ     noFrame3
          CLR     D0
          MOVE.W  RgSF(A4),D0
          ANDI    #$FFF,D0
          MOVE    D0,ExcNo(A4)
          BRA     hadFrm2
!noFrame3 MOVE.L  A1,D0
          SWAP    D0
          LSR.W   #8,D0
          MOVE    D0,ExcNo(A4)
!hadFrm2  MOVE.B  #4,EntryMod(A4) ; 'Exception :' ausgeben
          BRA     SetMon

; Die SFTbl ist die Anzahl der Werte auf dem Stack - 8

!SFTbl    DC.W    0,0,4,4,0,0,0,52,50,12,24,84,0,0,0,0  ; Format 11 um 4 erhîht.

;***************************************************************************
; Routinen zum Unterbrechen und Wiederaufnahmen des Datentransportes zwischen
; ST und IKBD. Keine Interruptsperrung !!!, sonst gibt's nen HÑnger !!!,
; nur im Supervisormodus nutzen, sonst gibt's nen Buserror !!!.

!Wr_IKBD  MOVEM.L D2/A1,-(SP)             ; Write Char in D0 an IKBD
          LEA     $FFFFFC00,A1            ; Keyboard ACIA Control Register
!acia_status
          MOVE.B  (A1),D2                 ; ACIA Statusregister lesen
          BTST.L  #1,D2                   ; Sender bereit?
          BEQ     acia_status             ; nein warten
          MOVE.W  #950,D2
!verzoeger
          BSR.B   verzoeger_tail
          DBF     D2,verzoeger
          MOVE.B  D0,2(A1)
          MOVEM.L (SP)+,D2/A1
!verzoeger_tail
          RTS

!Pause_IKBD
          MOVE.B  #$13,D0
          BRA     Wr_IKBD

!Resume_IKBD
          MOVE.B  #$11,D0
          BRA     Wr_IKBD

;#################################################################

; Testet die gerade aktuelle Auflîsung. Das Ergebnis wird in D0 abgelegt.
; Overscanmodus : D0 = -1L
; Normalmodus   : D0 = 0L

!OverScanTest:
(*$? ~MAC:
              tst.l     OSTT(A4)
              bne       O_S_Test
              move.l    d1,-(SP)
              bsr       Pause_IKBD
              move.w    SR,-(Sp)
              ori.w     #$0700,SR
              move.b    $FFFF8203,d0
              move.b    d0,d1                   ; Overscan-Modus testen
              addi.b    #$7d,d1
!VWait1:      cmp.b     $FFFF8207,d1
              bne       VWait1
!VWait2:      cmp.b     $FFFF8207,d1
              beq       VWait2
              cmp.b     $FFFF8207,d0
              beq       ONot
              move.w    (SP)+,SR
              bsr       Resume_IKBD
              move.l    (SP)+,d1
!ONot0:       moveq.l   #-1,d0
              rts
!ONot:        move.w    (SP)+,SR
              bsr       Resume_IKBD
              move.l    (SP)+,d1
*)
              clr.l     d0
              rts

(*$? ~MAC:
!O_S_Test:
          MOVEM.L D1/D2/A0-A2,-(SP)
          MOVEQ   #4,D0
          MOVEQ   #-1,D1
          MOVE.L  OSTT(A4),A0
          JSR     (A0)
          MOVEM.L (SP)+,D1/D2/A0-A2
          TST.L   D0
          BNE     ONot0
          RTS
*)

;#################################################################

!search_tos:
            CMPI.L      #$58425241,-12(A0)
            BNE.S       found_tos
            LEA         -4(A0),A1
            MOVE.L      (A1),A0
            BRA.S       search_tos
found_tos:
            RTS


;#################################################################

!BigScreen
          TST.L   OSTT(A4)
          BNE     B_Screen
          MOVEM.L A1/D0,-(SP)
          MOVE.B  #$D6,$FFFFFC00
!W_Screen LEA     $FFFF8200,A1
          MOVEP.W 1(A1),D0
          BSR     Wvbl
          MOVEM.L (SP)+,A1/D0
          RTS
!B_Screen MOVEM.L D0-D2/A0-A2,-(SP)
          MOVEQ   #1,D1
!J_Screen MOVEQ   #4,D0
          MOVE.L  OSTT(A4),A0
          JSR     (A0)
          MOVEM.L (SP)+,D0-D2/A0-A2
          RTS

!SmallScreen
          TST.L   OSTT(A4)
          BNE     S_Screen
          MOVEM.L A1/D0,-(SP)
          MOVE.B  #$96,$FFFFFC00
          BRA.S   W_Screen
!S_Screen MOVEM.L D0-D2/A0-A2,-(SP)
          MOVEQ   #0,D1
          BRA.S   J_Screen

;************************************************************************

!PutLine  MOVEM.L A0/A1/D2,-(SP)           ; Eine ganze Zeile an
          MOVE.W  CursorY(A4),D2
          MULU    Rows(A4),D2
          MOVE.L  bMonScreen(PC),A1
          ADDA.L  D2,A1
          MOVE.L  A1,D2
          SUB.L   bMonScreenTop(PC),D2
          BCS     PutLine1
          MOVE.L  bMonScreenBase(PC),A1
          ADDA.L  D2,A1
!PutLine1 ; 80 Byte kopieren
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVE.L  (A0)+,(A1)+
          MOVEM.L (SP)+,A0/A1/D2
          RTS

;************************************************************************

; TempleMon Funktionshandler im CookieJar

!CookieTab
          BRA.L   CookieRoutine0  ; Patchvarpointer und LocVarP holen
          BRA.L   CookieRoutine1  ; TempleMon Versionsnummer + Datum holen
          BRA.L   CookieRoutine2  ; Usertrace-Routine holen/setzen
          BRA.L   CookieRoutine3  ; TempleMon Vektoren initialisieren
          BRA.L   CookieRoutine4  ; Bildschirmadresse und Grîûe holen
          BRA.L   CookieRoutine5  ; TempleMon Offset neu setzen
          BRA.L   CookieRoutine6  ; Screensharing mitteilen
          BRA.L   CookieRoutine7  ; Bildschirm restaurieren lassen
          BRA.L   CookieRoutine8  ; SysMon Semaphor-Adresse speichern
          BRA.L   CookieRoutine9  ; SysMon Aufruf-Adresse speichern
          BRA.L   CookieRoutine10 ; 2. TempleMon Einsprung fÅr SysMon; Soll
                                  ; rekursiven Aufruf zwischen SysMon und TempleMon
                                  ; mit F10 verhindern
          BRA.L   CookieRoutine11 ; neue TempleMon Fontpointer setzen
          BRA.L   CookieRoutine12 ; Disassembler aufrufen
          BRA.L   CookieRoutine13 ; Online Hilfe anmelden
          BRA.L   CookieRoutine14 ; Cursor Position setzen/holen
          BRA.L   CookieRoutine15 ; String an aktueller Cursorposition
                                  ; ausgeben
          BRA.L   CookieRoutine16 ; Bildschirm sofort restaurieren
          BRA.L   CookieRoutine17 ; Makrofunktion bei Eingabeauswertung anmelden
          BRA.L   CookieRoutine18 ; Keyboardpuffer initialisieren/darstellen
          BRA.L   CookieRoutine19 ; Tastendruck testen
          BRA.L   CookieRoutine20 ; Symbolfunktion anmelden
          BRA.L   CookieRoutine21 ; Disassembler symbolisch aufrufen
          BRA.L   CookieRoutine22 ; Adresse fÅr Direktaufruf zurÅckliefern
          BRA.L   CookieRoutine23 ; Adresse fÅr Translation Tree holen/setzen
          BRA.L   CookieRoutine24 ; Routinen und Parameter fÅr externe
                                  ; Videoroutinen
          BRA.L   CookieRoutine25 ; Adresse von Unknown(A4) in A0 liefern
          BRA.L   CookieRoutine26 ; Einsprung zum Ein-/Ausschalten von
                                  ; TempleMon Bildschirm
          BREAK                   ; wichtig fÅr Debuggingzwecke!
!CookieHandler
          MOVE.W  SR,-(SP)
          BTST    #5,(SP)         ; S Bit gesetzt?
          BEQ     CookieHandlerFalse
          CMPI.L  #26,D0
          BLE.S   CookieHandlerOK
!CookieHandlerFalse
          MOVEQ   #-1,D0
          MOVEQ   #0,D1
          MOVE.L  D1,D2
          MOVEA.L D1,A0
          MOVEA.L D1,A1
          MOVEA.L D1,A2
          MOVE.W  (SP)+,SR
          RTS
!CookieHandlerOK
          MOVEM.L A4/A5,-(SP)
          MOVE.L  A3,A5
          MOVE.L  LocVarP(PC),A4
          ASL.L   #2,D0
          LEA     CookieTab(PC),A3
          ADDA.L  D0,A3
          (*
          bsr.w   mode_mac
          dc.w    $a9ff
          bsr.w   mode_atari
          *)
          JSR     (A3)
          (*
          bsr.w   mode_mac
          dc.w    $a9ff
          bsr.w   mode_atari
          *)
          MOVE.L  A5,A3
          MOVEM.L (SP)+,A4/A5
          MOVE.W  (SP)+,SR
          RTS

!CookieRoutine1
          MOVE.L  #TMonVersion,D0
          MOVE.L  #TMonDatum,A0
          RTS
!CookieRoutine2
          LEA     UsrBP(A4),A3
!CookieR2S MOVE.L  A0,D0
          MOVEA.L (A3),A0
          CMPI.L  #-1,D0
          BEQ.S   CookieR2E
          MOVE.L  D0,(A3)
!CookieR2E RTS
!CookieRoutine3
          MOVEM.L D1/A0/A1,-(SP)
          MOVE.L  A0,D0
          BEQ     CookieRoutine3_1
          MOVE.L  A0,AdOffset(A4)
!CookieRoutine3_1
          BSR     test_start      ; Cookie vom anderen TempleMon suchen
          MOVEQ   #0,D0
          MOVEQ   #0,D1
          BSR     InitVec
          MOVEM.L (SP)+,D1/A0/A1
          MOVEQ   #0,D0
          RTS
!CookieRoutine5
          MOVEM.L D0-D7/A0-A6,-(SP)
          MOVE.L  A0,D0
          BCLR    #0,D0
          MOVE.L  D0,tmon_offset(A4)
          TST.B   share_screen(A4)
          BNE.S   CookieRoutine51
          BSR     ClearScrn1
!CookieRoutine51
          BSR     RestoreScrn
          MOVEM.L (SP)+,D0-D7/A0-A6
          RTS
!CookieRoutine6
          MOVE.B  D1,share_screen(A4)
          RTS
!CookieRoutine7
          ST      restore_screen_flag(A4)
          RTS
!CookieRoutine8
          MOVE.L  A0,SysMonSemaphor(A4)
          RTS
!CookieRoutine9
          MOVE.L  A0,SysMonAdresse(A4)
          RTS
!CookieRoutine10
          TST.B   TempleMonCall(A4)  ; ist der SysMon von TempleMon aufgerufen
          BNE.S   CookieRoutine10End ; worden? Dann darf dieser TempleMon hierrÅber
          ST      SysMonCall(A4)     ; nicht aufrufen, sonst gibt es rekursive
          MOVE.L  A7,SysMonStack(A4) ; Schachtelungen, die nicht mehr gelîst werden
          MOVE.L  MonStackHi(A4),A7  ; kînnen.
          BSR     SetMon
          ST      MonActive(A4)
(*$ ? ExtendedKeys:
          ST      LockFlag(A4)
*)
          BRA     CMDBEGOMOCRLF
!CookieRoutine10Return
          BSR     ScrnCurOff
          BSR     ResetMon
          SF      MonActive(A4)
(*$ ? ExtendedKeys:
          ST      LockFlag(A4)
*)
          SF      SysMonCall(A4)
          MOVE.L  SysMonStack(A4),A7
!CookieRoutine10End
          RTS
!CookieRoutine11
          MOVE.L  A0,D0
          MOVEA.L pFont8_16(PC),A0
          TST.L   D0
          BEQ.S   CookieR11
          LEA     pFont8_16(PC),A3
          MOVE.L  D0,(A3)
!CookieR11 MOVE.L  A1,D0
          MOVEA.L pFont8_8(PC),A1
          TST.L   D0
          BEQ.S   CookieR12
          LEA     pFont8_8(PC),A3
          MOVE.L  D0,(A3)
!CookieR12 RTS
!CookieRoutine12
          MOVE.W  Symbolic(A4),D0
          LSR.W   #8,D0
          MOVE.W  D0,Symbolic(A4)
!CookieRoutine12_1
          MOVEM.L D1-D7,-(SP)
          MOVE.L  A0,A1
          CLR.W   DCursorX(A4)
          CLR.W   isD10(A4)
          CLR.W   isD20(A4)
          CLR.W   isD30(A4)
          CLR.W   isD40(A4)
          CLR.W   isDFPU(A4)
          MOVE.W  D1,D0
          ANDI.W  #$F,D0
          TST.W   D0
          BEQ     CookieRoutine12_goon
          CMPI.W  #5,D0
          BCC     CookieRoutine12_goon
          CMPI.W  #1,D0
          BEQ     C_R_10
          CMPI.W  #$10,D0
          BCC     C_R_1
          ST      isDFPU(A4)
!C_R_1    CMPI.W  #2,D0
          BEQ     C_R_20
          CMPI.W  #3,D0
          BEQ     C_R_30
!C_R_40   ST      isD40(A4)
!C_R_30   ST      isD30(A4)
!C_R_20   ST      isD20(A4)
!C_R_10   ST      isD10(A4)
!CookieRoutine12_goon
          BSR.L   DISASM21
          TST.B   DBufLong(A4)
          BEQ     CookieRoutine12_goon1
          LEA     DBuffer(A4),A0
          MOVE.W  #$0D0A,80(A0)
!CookieRoutine12_goon1
          MOVE.L  A1,A0
          LEA     CODETAB(PC),A2
          MOVE.W  DCode(A4),D0
          MOVEQ   #0,D1
          MOVE.W  D0,D1
          ASL.L   #3,D1
          ADDA.L  D1,A2
          MOVE.W  DCursorX(A4),D1
          LEA     DBuffer(A4),A1
!CR12L    CLR.B   0(A1,D1.W)
          CMPI.B  #80,D1
          BCC     CR12E
          ADDQ.W  #1,D1
          BRA     CR12L
!CR12E    MOVEM.L (SP)+,D1-D7
          MOVE.W  Symbolic(A4),D0
          LSL.W   #8,D0
          MOVE.W  D0,Symbolic(A4)
          RTS
!CookieRoutine14
          MOVE.W  CursorY(A4),D0
          SWAP    D0
          MOVE.W  CursorX(A4),D0
          CMPI.W  #-1,D1
          BEQ     Cookie14E
          MOVE.L  CursorCnt(A4),-(SP)
          MOVE.W  CursorState(A4),-(SP)
          BEQ     Cookie14S
          BSR     CursorOff
!Cookie14S EXT.L   D1
          DIVU.W  Rows(A4),D1
          SWAP    D1
          MOVE.W  D1,CursorX(A4)
          TST.W   (SP)
          BEQ     Cookie14N
          BSR     CursorOn
!Cookie14N MOVE.W  (SP)+,CursorState(A4)
          MOVE.L  (SP)+,CursorCnt(A4)
!Cookie14E MOVE.W  Lines(A4),D1
          SWAP    D1
          MOVE.W  Rows(A4),D1
          RTS
!CookieRoutine15
          MOVE.L  CursorCnt(A4),-(SP)
          MOVE.W  CursorState(A4),-(SP)
          BEQ     Cookie15S
          BSR     CursorOff
!Cookie15S MOVEM.L D7/A1/A2,-(SP)
          MOVEQ   #0,D7
          MOVE.L  A0,A1
          BSR     PrtStr
          MOVEM.L (SP)+,D7/A1/A2
          TST.W   (SP)
          BEQ     Cookie15N
          BSR     CursorOn
!Cookie15N MOVE.W  (SP)+,CursorState(A4)
          MOVE.L  (SP)+,CursorCnt(A4)
!Cookie15E RTS
!CookieRoutine16
          MOVEM.L D3-D7/A5/A6,-(SP)
          TST.L   D1
          BEQ.S   CookieR16
          TST.B   share_screen(A4)
          BNE.S   CookieR16
          BSR     ClearScrn1
!CookieR16 BSR     RestoreScrn
          MOVEM.L (SP)+,D3-D7/A5/A6
          RTS
!CookieRoutine18
          TST.L   D1
          BEQ     InitKeyBuf
          BRA     DispKeyBuf
!CookieRoutine19
          BSR     TSTKEY
          ANDI.L  #$FF,D0
          RTS
!CookieRoutine20
          MOVE.L  A1,-(SP)
          LEA     GetSymbolName(A4),A3
          BSR.L   CookieR2S
          MOVE.L  (SP)+,A1
          MOVE.L  A0,-(SP)
          MOVEA.L A1,A0
          LEA     GetSymbolValue(A4),A3
          BSR.L   CookieR2S
          MOVE.L  A0,A1
          MOVE.L  (SP)+,A0
          RTS
!CookieRoutine21
          MOVE.B  Symbolic(A4),D0
          ORI.W   #$FF00,D0
          MOVE.W  D0,Symbolic(A4)
          BRA     CookieRoutine12_1
!CookieRoutine22
          LEA     EyDIRC(PC),A0
          RTS
!CookieRoutine23
          MOVE.W  TMon_Tree(A4),D0
          MOVE.W  D1,TMon_Tree(A4)
          MOVE.L  TMon_Get_Tree(A4),A1
          MOVE.L  A0,TMon_Get_Tree(A4)
          LEA     TMon_URP(A4),A0
          RTS
!CookieRoutine24
          LEA     SwitchTMonScreen(A4),A3
          BSR.L   CookieR2S
          MOVE.L  A0,-(SP)                    ; altes A0 sichern
          MOVEA.L A1,A0
          LEA     SwitchOrgScreen(A4),A3
          BSR.L   CookieR2S
          MOVE.L  A0,-(SP)                    ; altes A1 sichern
          MOVE.L  A2,A0
          LEA     AskVideoAddress(A4),A3
          BSR.L   CookieR2S
          MOVE.L  A0,A2
          MOVE.L  A5,A0                       ; neues A3 holen
          BSR.L   Get_pMonScreen
          BSR.L   CookieR2S
          MOVE.L  A0,-(SP)                    ; altes A3 sichern
          MOVEA.L D1,A0
          LEA     tmon_offset(A4),A3
          BSR.L   CookieR2S
          MOVE.L  A0,D1
          MOVE.W  #16,CharHeight(A4)
          MOVE.W  D2,D0
          CMPI.W  #1,D2
          BEQ.S   CookieRoutine24SetPlane
          MOVE.W  #8,CharHeight(A4)
!CookieRoutine24SetPlane
          LEA     video_plane(A4),A3
          BSR     CookieR24S
          MOVE.W  D0,D2
          MOVE.W  D3,D0
          LEA     video_rowbytes(A4),A3
          BSR     CookieR24S
          MOVE.W  D0,D3
          MOVE.W  D4,D0
          LEA     video_modus(A4),A3
          BSR     CookieR24S
          MOVE.W  D0,D4
          MOVEA.L D5,A0
          LEA     video_memsize(A4),A3
          BSR.L   CookieR2S
          MOVE.L  A0,D5
          CLR.L   D0
          MOVE.W  Unknown(A4),D0
          MOVE.L  (SP)+,A5
          MOVE.L  (SP)+,A1
          MOVE.L  (SP)+,A0
          RTS
CookieR24S
          MOVE.L  D1,-(SP)
          MOVE.W  (A3),D1
          CMPI.W  #-1,D0
          BEQ     CookieR24E
          MOVE.W  D0,(A3)
CookieR24E
          MOVE.W  D1,D0
          MOVE.L  (SP)+,D1
          RTS
!CookieRoutine25
          LEA     Unknown(A4),A0
          RTS
!CookieRoutine26
          MOVEM.L D1-D7/A0-A3/A6,-(SP)
          LEA     MonScrn(PC),A0
          TST.L   D1
          BEQ     CookieRoutine26J
          LEA     ShowMonScrn(PC),A0
          NOT.L   D1
          BEQ     CookieRoutine26J
          LEA     NormScrn(PC),A0
!CookieRoutine26J
          JSR     (A0)
          MOVEQ   #0,D0
          MOVE.W  video_plane(A4),D0
          MOVEM.L (SP)+,D1-D7/A0-A3/A6
          RTS
!valsave  DC.L    0
          ASC     'XBRA'
(*$? NOT Debug:
          ASC     'TMon' *)
(*$?     Debug:
          ASC     'tmON' *)
!vecsave  DC.L    0
!CookieReset
          CLR.L   $5A0
          MOVE.L  vecsave(PC),$42A
          MOVE.L  valsave(PC),$426
          JMP     (A6)

!InstallCookie                     (* eigenes Cookie installieren *)
          MOVEA.L $5A0,A0
          CMPA.L  #0,A0
          BEQ.L   NoCookie
          MOVEQ   #1,D1
          BRA.S   CoTest
!CoLoop   ADDQ.L  #1,D1
          LEA     8(A0),A0
!CoTest   TST.L   (A0)
          BNE.S   CoLoop
          CMP.L   4(A0),D1
          BGE     CopyCookie
          MOVE.L  4(A0),D1
          CLR.L   8(A0)
          MOVE.L  D1,12(A0)
          LEA     CookieHandler(PC),A1
          MOVE.L  A1,4(A0)
(*$? NOT Debug:
          MOVE.L  #$544D6F6E,(A0)+ *)
(*$?     Debug:
          MOVE.L  #$746D4F4E,(A0)+ *)
          BRA.L   ICookieEnde
!NoCookie
          MOVE.L  D0,A0
          MOVE.L  A0,$5A0
          ADDI.L  #8*8,D0
(*$? NOT Debug:
          MOVE.L  #$544D6F6E,(A0)+ *)
(*$?     Debug:
          MOVE.L  #$746D4F4E,(A0)+ *)
          LEA     CookieHandler(PC),A1
          MOVE.L  A1,(A0)+
          CLR.L   (A0)+
          MOVE.L  #8,(A0)
          LEA     valsave(PC),A0
          MOVE.L  $426,(A0)
          LEA     vecsave(PC),A0
          MOVE.L  $42A,(A0)
          LEA     CookieReset(PC),A0
          MOVE.L  A0,$42A
          MOVE.L  #$31415926,$426
          BRA     ICookieEnde
!CopyCookie
          MOVE.L  D0,A1       ; A0 zeigt auf MaxCookie
          MOVE.L  D1,D2
          ASL.L   #3,D2       ; mal 8; pro Eintrag 8 Bytes
          ADD.L   D2,D0
          ADDI.L  #8*8,D0     ; 8 neue EintrÑge fÅr den CookieJar
          MOVE.L  $5A0,A2
          MOVE.L  A1,$5A0
          ADDQ.L  #8,D1
!CopyCookieLoop
          MOVE.L  (A2)+,(A1)+
          MOVE.L  (A2)+,(A1)+
          CMPA.L  A2,A0
          BNE.S   CopyCookieLoop
          LEA     CookieHandler(PC),A0
(*$? NOT Debug:               ; TempleMon Cookie anlegen
          MOVE.L  #$544D6F6E,(A1)+ *)
(*$?     Debug:
          MOVE.L  #$746D4F4E,(A1)+ *)
          MOVE.L  A0,(A1)+
          CLR.L   (A1)+       ; MaxCookie anlegen
          MOVE.L  D1,(A1)+
!InitCookieLoop
          CMPA.L  D0,A1
          BCC     ICookieEnde
          CLR.L   (A1)+
          BRA.S   InitCookieLoop
!ICookieEnde
          RTS

;*****************************************************************

; ST,STE oder TT Mittels CookieJar abprÅfen


!MCH_Test MOVEM.L A0/D0,-(SP)
          CLR.W   isTT(A4)
          CLR.W   isSTE(A4)
          MOVE.L  $5A0,A0        ; CookiePointer
          MOVE.L  A0,D0
          BEQ     MCH_Unknown1   ; kein CookieJar
          BRA     MCH_Strt
!MCH_Loop ADDQ.L  #4,A0
!MCH_Strt TST.L   (A0)
          BEQ     MCH_Stop       ; Ende der Liste
          CMPI.L  #$5F56444F,(A0)+ ; Vergleich auf '_VDO'
          BNE     MCH_Loop
          MOVE.W  (A0),D0
          BEQ     MCH_Stop        ; ST gefunden
          CMPI.W  #$1,D0
          BEQ     STE_found       ; STE gefunden
          CMPI.W  #$2,D0
          BNE     MCH_Unknown     ; was unbekanntes gefunden: wie ST behandeln!
          MOVE.W  #2,isTT(A4)
          BRA     MCH_Stop
!MCH_Unknown
(*$? ~MAC:
          CMPI.W  #$3,D0
          BNE     MCH_Unknown1
          ST      isFALCON030(A4)
          BSR.L   SetMonoConst
          MOVE.B  $FFFF8006,D0    ; mon_type
          ASR.W   #6,D0
          AND.W   #3,D0
          MOVE.W  D0,FALCON030MonitorType(A4)
          BTST    #0,D0
          BEQ     MCH_Stop
          BSR.L   SetColorConst
          BRA     MCH_Stop
*)
!MCH_Unknown1
          ST      Unknown(A4)
          BRA     MCH_Stop
!STE_found ST     isSTE(A4)
!MCH_Stop MOVEM.L (SP)+,A0/D0
          RTS


!ComdK    CMPI.B  #'+',D0
          BNE     ComdK1
          TST.B   RestoreKBDVec(A4)
          BEQ     ComdK2
          MOVE.B  RestoreKBDVec(A4),Restore2KBDVec(A4)
          CLR.B   RestoreKBDVec(A4)
          BRA     ComdK2
!ComdK1   CMPI.B  #'-',D0
          BNE     ComdK3
          TST.B   Restore2KBDVec(A4)
          BEQ     ComdK2
          MOVE.B  Restore2KBDVec(A4),RestoreKBDVec(A4)
!ComdK2   RTS

!ComdK3   ; f. Mac: kurzzeitig Interrupts durchlassen
          MOVE    SR,-(A7)
          ANDI    #$F8FF,SR
          MOVE.L  #10000000,D0
!comdk4   NOP
          SUBQ.L  #1,D0
          BCC     comdk4
          MOVE    (A7)+,SR
          RTS

(*$? ~MAC:
!SetMonoConst
          MOVE.W        #16,CharHeight(A4)
          MOVE.W        #1,CharWidth(A4)
          MOVE.W        #1,video_plane(A4)
          MOVE.W        #80,video_rowbytes(A4)
          MOVE.L        #32000,video_memsize(A4)
          CLR.L         tmon_offset(A4)
          CLR.W         video_modus(A4)
          RTS

!SetColorConst
          MOVE.W        #8,CharHeight(A4)
          MOVE.W        #1,CharWidth(A4)
          MOVE.W        #2,video_plane(A4)
          MOVE.W        #160,video_rowbytes(A4)
          MOVE.L        #32000,video_memsize(A4)
          CLR.L         tmon_offset(A4)
          CLR.W         video_modus(A4)
          RTS
*)

!InitHelp PEA     ZPoint(PC)
          PEA     ZPoint(PC)
          PEA     sPath(PC)
          MOVE.W  #3,-(SP)
          MOVE.W  #$4B,-(SP)
          TRAP    #1
          LEA     $10(SP),SP
          TST.L   D0
          BPL     startHelp

          PEA     ZPoint(PC)
          PEA     ZPath(PC)
          PEA     lPath(PC)
          MOVE.W  #3,-(SP)
          MOVE.W  #$4B,-(SP)
          TRAP    #1
          LEA     $10(SP),SP
          TST.L   D0
          BMI     no_startHelp

!startHelp CLR.L   -(SP)
          MOVE.L  D0,-(SP)
          MOVE.L  D0,HelpBasePage(A4)
          CLR.L   -(SP)
          MOVE.W  #4,-(SP)
          MOVE.W  #$4B,-(SP)
          TRAP    #1
          LEA     $10(SP),SP
          TST.W   D0                ; Returnwert <> 0
          BEQ     no_startHelp
          CLR.L   UsrBP(A4)         ; Oh Scheiûe, da ging etwas schief
          CLR.L   OnLineHelp(A4)    ; Alle Vektoren, in dem das PRG drinhÑngen
          CLR.L   Makros(A4)        ; kînnte freigeben.
          MOVE.L  HelpBasePage(A4),A0 ; Environment freigeben
          MOVE.L  $2C(A0),-(SP)
          MOVE.W  #$49,-(SP)
          TRAP    #1
          ADDQ.L  #6,SP
          MOVE.L  HelpBasePage(A4),-(SP) ; Programm selber freigeben
          MOVE.W  #$49,-(SP)
          TRAP    #1
          ADDQ.L  #6,SP
!no_startHelp
          BRA     keepProcess

!ZPoint   DC.L    0
!ZPath    ACZ     '\\AUTO\'
!lPath    ASC     '\AUTO\'
!sPath    ACZ     'TMONHELP.EXE'
          SYNC

(*$? ~MAC:
!WvblFALCON030                       ; Warten auf Vertical Blank
          LEA     $FFFF8200,A1
          MOVEP.W 1(A1),D0
!WvblF    MOVEP.W 5(A1),D1
          CMP.W   D0,D1
          BEQ     WvblF
Wvbl2F    MOVEP.W 5(A1),D1
          CMP.W   D0,D1
          BNE     Wvbl2F
          RTS
;          move.w  sr,d0
;          andi.w  #$fbff,sr
;          move.l  $466,d1
;!ST_SyncLoop:
;          cmp.l   $466,d1
;          beq     ST_SyncLoop
;          move.w  sr,d0
;          rts

!RestoreFALCON030ScreenMode
          MOVE.W  SR,-(SP)
          ORI.W   #$0700,SR
          LEA     $FFFF8200,A1
          MOVE.W  (A0),D0
          MOVEP.W D0,$01(A1)
          MOVE.B  $03(A0),$0D(A1)
          BSR     WvblFALCON030
          MOVE.W  FALCON030_VFT(A4),$A2(A1)
          MOVE.W  FALCON030_VSS(A4),$AC(A1)
          MOVE.W  FALCON030_VBB(A4),$A4(A1)
          MOVE.W  FALCON030_VBE(A4),$A6(A1)
          MOVE.W  FALCON030_VDB(A4),$A8(A1)
          MOVE.W  FALCON030_VDE(A4),$AA(A1)
          MOVE.W  FALCON030_HHT(A4),$82(A1)
          MOVE.W  FALCON030_HSS(A4),$8C(A1)
          MOVE.W  FALCON030_HBB(A4),$84(A1)
          MOVE.W  FALCON030_HBE(A4),$86(A1)
          MOVE.W  FALCON030_HDB(A4),$88(A1)
          MOVE.W  FALCON030_HDE(A4),$8A(A1)
          MOVE.W  FALCON030_HFS(A4),$8E(A1)
          MOVE.W  FALCON030_HEE(A4),$90(A1)
          MOVE.W  FALCON030_SP_SHIFT(A4),$66(A1)
          MOVE.W  FALCON030_HHT(A4),D0
          CMP.W   #$64,D0
          BGE.S   restVCO
          MOVE.W  FALCON030_ST_SHIFT(A4),$60(A1)
!restVCO  MOVE.W  FALCON030_VCO(A4),$C2(A1)
          MOVE.W  FALCON030_VWRAP(A4),$10(A1)
          MOVE.W  FALCON030_VXX(A4),$C0(A1)
          MOVE.W  FALCON030_EXTCLK(A4),$0A(A1)
          MOVE.W  FALCON030_VWR2(A4),$0E(A1)
          LEA     farbe(A4),A0
          MOVE.B  TempleMonCall(A4),D0
          ASL.W   #8,D0
          MOVE.B  SysMonCall(A4),D0
          TST.W   D0
          BEQ     RestoreFALCON030Color
          LEA     farbe2(A4),A0
!RestoreFALCON030Color
          LEA     $FFFF8240,A2
          MOVE.B  $FFFF8006,D0            ; FALCON030 Monitor ID
          ASR.W   #6,D0
          ANDI.W  #$03,D0
          CMPI.W  #2,D0
          BCS     RestoreFALCON030Color2
          LEA     $FFFF9800,A2
!RestoreFALCON030Color2
          MOVE.L  (A0)+,(A2)+
          MOVE.L  (A0)+,(A2)+
          MOVE.L  (A0)+,(A2)+
          MOVE.L  (A0)+,(A2)+
          CLR.W   FALCON030ScreenVisible(A4)
          MOVE.W  (SP)+,SR
          RTS

!SaveFALCON030ScreenMode
          LEA     $FFFF8200,A1
          MOVEP.W $01(A1),D0
          CMP.W   (A0),D0
          BEQ.L   NothingToSet
          TST     FALCON030ScreenVisible(A4)
          BNE.L   NothingToSet
          MOVE.W  D0,(A0)
          MOVE.B  $0D(A1),3(A0)
          MOVE.W  $A2(A1),FALCON030_VFT(A4)
          MOVE.W  $AC(A1),FALCON030_VSS(A4)
          MOVE.W  $A4(A1),FALCON030_VBB(A4)
          MOVE.W  $A6(A1),FALCON030_VBE(A4)
          MOVE.W  $A8(A1),FALCON030_VDB(A4)
          MOVE.W  $AA(A1),FALCON030_VDE(A4)
          MOVE.W  $82(A1),FALCON030_HHT(A4)
          MOVE.W  $8C(A1),FALCON030_HSS(A4)
          MOVE.W  $84(A1),FALCON030_HBB(A4)
          MOVE.W  $86(A1),FALCON030_HBE(A4)
          MOVE.W  $88(A1),FALCON030_HDB(A4)
          MOVE.W  $8A(A1),FALCON030_HDE(A4)
          MOVE.W  $8E(A1),FALCON030_HFS(A4)
          MOVE.W  $90(A1),FALCON030_HEE(A4)
          MOVE.W  $66(A1),FALCON030_SP_SHIFT(A4)
          MOVE.W  $60(A1),FALCON030_ST_SHIFT(A4)
          MOVE.W  $C2(A1),FALCON030_VCO(A4)
          MOVE.W  $10(A1),FALCON030_VWRAP(A4)
          MOVE.W  $C0(A1),FALCON030_VXX(A4)
          MOVE.W  $0A(A1),FALCON030_EXTCLK(A4)
          MOVE.W  $0E(A1),FALCON030_VWR2(A4)
          LEA     farbe(A4),A0
          MOVE.B  TempleMonCall(A4),D0
          ASL.W   #8,D0
          MOVE.B  SysMonCall(A4),D0
          TST.W   D0
          BEQ     SaveFALCON030Color
          LEA     farbe2(A4),A0
!SaveFALCON030Color
          LEA     $FFFF8240,A2
          MOVE.B  $FFFF8006,D0            ; FALCON030 Monitor ID
          ASR.W   #6,D0
          ANDI.W  #$03,D0
          CMPI.W  #2,D0
          BCS     SaveFALCON030Color2
          LEA     $FFFF9800,A2
!SaveFALCON030Color2
          MOVE.L  (A2)+,(A0)+
          MOVE.L  (A2)+,(A0)+
          MOVE.L  (A2)+,(A0)+
          MOVE.L  (A2)+,(A0)+
!NothingToSet
          RTS

!SetFALCON030ScreenMode
          MOVE.W  SR,-(SP)
          ORI.W   #$0700,SR
          ST      FALCON030ScreenVisible(A4)
          LEA     $FFFF8200,A1
          MOVE.W  (A0),D0
          MOVEP.W D0,1(A1)
          CLR.B   $0D(A1)
          MOVE.B  $FFFF8006,D0            ; FALCON030 Monitor ID * 4 fÅr
                                          ; Sprungtabelle
          ASR.W   #4,D0
          ANDI.W  #$0C,D0
          LEA     setTab(PC,D0.W),A0
          ASR.W   #2,D0
          JMP     (A0)

!setTab   BRA.L   setSM124
          BRA.L   setSC1224
          BRA.L   setVGA
          BRA.L   setTV

!setVGA   BSR     WvblFALCON030
          move.w  #$0419,$A2(A1) ; VFT
          move.w  #$0415,$AC(A1) ; VSS
          move.w  #$03af,$A4(A1) ; VBB
          move.w  #$008f,$A6(A1) ; VBE
          move.w  #$008f,$A8(A1) ; VDB
          move.w  #$03af,$AA(A1) ; VDE
          move.w  #$00c6,$82(A1) ; HHT
          move.w  #$0096,$8C(A1) ; HSS
          move.w  #$008d,$84(A1) ; HBB
          move.w  #$0015,$86(A1) ; HBE
          move.w  #$0273,$88(A1) ; HDB
          move.w  #$0050,$8A(A1) ; HDE
          clr.w   $8E(A1)        ; HFS
          clr.w   $90(A1)        ; HEE
          move.w  #$0400,$66(A1) ; SP_SHIFT
          move.w  #$0008,$C2(A1) ; VCO
          move.w  #$0028,$10(A1) ; VWRAP
          move.w  #$0186,$C0(A1) ; VXX
          move.w  #$0200,$0A(A1) ; EXTCLK
          clr.w   $0E(A1)        ; VWR2
          MOVE.L  D0,-(SP)
          BSR     GetFALCON030VGAColor
          MOVE.W  (A0)+,D0
          BSR.L   ConvertSTEtoFALCON030
          MOVE.L  D0,$FFFF9800
          MOVE.W  (A0)+,D0
          BSR.L   ConvertSTEtoFALCON030
          MOVE.L  D0,$FFFF9804
          MOVE.L  D0,$FFFF9808
          MOVE.L  D0,$FFFF980C
          MOVE.L  (SP)+,D0
!SetFALCON030ScreenModeTest
          CMP.W   FALCON030MonitorType(A4),D0
          BEQ     SetFALCON030ScreenModeEnde
          MOVE.W  D0,FALCON030MonitorType(A4)
          BSR     SetMonoConst
!SetFALCON030ScreenModeEnde
          MOVE.W  (SP)+,SR
          rts

!setSM124 BSR     WvblFALCON030
          move.w  #$03e9,$A2(A1) ; VFT
          move.w  #$03e7,$AC(A1) ; VSS
          clr.w   $A4(A1)        ; VBB
          clr.w   $A6(A1)        ; VBE
          move.w  #$0043,$A8(A1) ; VDB
          move.w  #$0363,$AA(A1) ; VDE
          move.w  #$001a,$82(A1) ; HHT
          move.w  #$0014,$8C(A1) ; HSS
          clr.w   $84(A1)        ; HBB
          clr.w   $86(A1)        ; HBE
          move.w  #$020f,$88(A1) ; HDB
          move.w  #$000c,$8A(A1) ; HDE
          clr.w   $8E(A1)        ; HFS
          clr.w   $90(A1)        ; HEE
          clr.w   $66(A1)        ; SP_SHIFT
          move.w  #$0200,$60(A1) ; ST_SHIFT
          move.w  #$0008,$C2(A1) ; VCO
          move.w  #$0028,$10(A1) ; VWRAP
          move.w  #$0080,$C0(A1) ; VXX
          move.w  #$0200,$0A(A1) ; EXTCLK
          clr.w   $0E(A1)        ; VWR2
          BSR     GetFALCON030SM124Color
          MOVE.W  (A0),$FFFF8240
          BRA     SetFALCON030ScreenModeTest

!setTV                                    ;vorlÑufig??
          BSR.L   setTVSC1224
          BSR     GetFALCON030TVColor
          MOVE.W  (A0)+,D0
          BSR     ConvertSTEtoFALCON030
          MOVE.L  D0,$FFFF9800
          MOVE.W  (A0)+,D0
          BSR     ConvertSTEtoFALCON030
          MOVE.L  D0,$FFFF9804
          MOVE.W  (A0)+,D0
          BSR     ConvertSTEtoFALCON030
          MOVE.L  D0,$FFFF9808
          MOVE.W  (A0)+,D0
          BSR     ConvertSTEtoFALCON030
          MOVE.L  D0,$FFFF980C
          MOVE.W  (SP)+,SR
          RTS

!ConvertSTEtoFALCON030
          MOVEM.L D1-D3,-(SP)
          ROL.W   #8,D0
          MOVE.B  D0,D2
          ANDI.W  #$F,D2
          MOVE.W  D2,D1
          ASR.W   #3,D1
          ASL.B   #1,D2
          OR.B    D2,D1
          LSL.L   #8,D1

          ROL.W   #4,D0
          MOVE.B  D0,D2
          ANDI.W  #$F,D2
          MOVE.W  D2,D3
          ASR.W   #3,D3
          ASL.B   #1,D2
          OR.B    D2,D3
          OR.B    D3,D1
          LSL.L   #8,D1

          CLR.B   D1
          LSL.L   #8,D1

          ROL.W   #4,D0
          MOVE.B  D0,D2
          ANDI.W  #$F,D2
          MOVE.W  D2,D3
          ASR.W   #3,D3
          ASL.B   #1,D2
          OR.B    D2,D3
          OR.B    D3,D1
          LSL.L   #4,D1

          MOVE.L  D1,D0
          MOVEM.L (SP)+,D1-D3
          RTS

!setSC1224
          BSR.L   setTVSC1224
          BSR     GetFALCON030SC1224Color
          MOVE.W  (A0)+,$FFFF8240
          MOVE.W  (A0)+,$FFFF8242
          MOVE.W  (A0)+,$FFFF8244
          MOVE.W  (A0)+,$FFFF8246
          MOVE.W  (SP)+,SR
          RTS
*)

;*** REGISTER TABELLEN

; alle 5 Bytes beginnt ein neuer Registername

!REGTAB ASC 'SR   D0   D1   D2   D3   D4   D5   D6   D7   A0   A1   A2   A3   '
        ASC 'A4   A5   A6   A7   PC   USP  SSP  BEV  AEV  '
!REGTABEND                           ; Bis hierher 68000 Register
        ASC 'SFC  DFC  VBR  '
!REGTABEND10                         ; Bis hierher 68010 Register
        ASC 'MSP  ISP  CAAR CACR '
!REGTABEND20                         ; Bis hierher 68020 Register
        ASC 'TT0  TT1  TC   PSR  CRP  SRP  '
!REGTABEND30                         ; Bis hierher 68030 Register

!REGTABFPU                           ; Ab hier 68881/68882 Register
        ASC 'FP0  FP1  FP2  FP3  FP4  FP5  FP6  FP7  FPCR FPSR FPIAR'
!REGTABENDFPU

        ASC 'DTT0 DTT1 ITT0 ITT1 URP  '
!REGTABEND40

          SYNC
          DC.W 4 ; LÑnge eines Tabelleneintrages
          DC.B 6 ; max. LÑnge des Textes, aber mit Registername und dem '.'
                 ; und der maximalen Maske (ohne Nullterminator)
          DC.B 2 ; Position Bitnummer
          DC.B 3 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!SRTAB    DC.B 'T',0,15,1
          DC.B 'S',0,13,1
          DC.B 'I',0, 8,7
          DC.B 'X',0, 4,1
          DC.B 'N',0, 3,1
          DC.B 'Z',0, 2,1
          DC.B 'V',0, 1,1
          DC.B 'C',0, 0,1
          DC.B 0

          SYNC
          DC.W 4 ; LÑnge eines Tabelleneintrages
          DC.B 6 ; max. LÑnge des Textes, aber mit Registername und dem '.'
                 ; (ohne Nullterminator)
          DC.B 2 ; Position Bitnummer
          DC.B 3 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!SRTABK   DC.B 'T',0,15,1
          DC.B 0

          SYNC
          DC.W 5 ; LÑnge eines Tabelleneintrages
          DC.B 7 ; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 3 ; Position Bitnummer
          DC.B 4 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!SRTAB20  DC.B 'T','1',0,15,1
          DC.B 'T','0',0,14,1
          DC.B 'S', 0 ,0,13,1
          DC.B 'M', 0 ,0,12,1
          DC.B 'I', 0 ,0, 8,7
          DC.B 'X', 0 ,0, 4,1
          DC.B 'N', 0 ,0, 3,1
          DC.B 'Z', 0 ,0, 2,1
          DC.B 'V', 0 ,0, 1,1
          DC.B 'C', 0 ,0, 0,1
          DC.B 0

          SYNC
          DC.W 5 ; LÑnge eines Tabelleneintrages
          DC.B 7 ; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 3 ; Position Bitnummer
          DC.B 4 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!SRTAB20K DC.B 'T','1',0,15,1
          DC.B 'T','0',0,14,1
          DC.B 0

          SYNC
          DC.W 5 ; LÑnge eines Tabelleneintrages
          DC.B 9 ; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 3 ; Position Bitnummer
          DC.B 4 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!CACHETAB DC.B 'C', 0 ,0,3,1             ; CACR bei 68020
          DC.B 'C','E',0,2,1
          DC.B 'F', 0 ,0,1,1
          DC.B 'E', 0 ,0,0,1
          DC.B 0

          SYNC
          DC.W 6 ; LÑnge eines Tabelleneintrages
          DC.B 10; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 4 ; Position Bitnummer
          DC.B 5 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!CACHETAB30                              ; CACR bei 68030
          DC.B 'W','A', 0 ,0,13,1
          DC.B 'D','B','E',0,12,1
          DC.B 'C','D', 0 ,0,11,1
          DC.B 'C','E','D',0,10,1
          DC.B 'F','D', 0 ,0, 9,1
          DC.B 'E','D', 0 ,0, 8,1
          DC.B 'I','B','E',0, 4,1
          DC.B 'C','I', 0 ,0, 3,1
          DC.B 'C','E','I',0, 2,1
          DC.B 'F','I', 0 ,0, 1,1
          DC.B 'E','I', 0 ,0, 0,1
          DC.B 0

          SYNC
          DC.W 5 ; LÑnge eines Tabelleneintrages
          DC.B 9 ; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 3 ; Position Bitnummer
          DC.B 4 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!CACHETAB40
          DC.B 'D','E',0,31,1             ; CACR bei 68040
          DC.B 'I','E',0,15,1
          DC.B 0

          SYNC
          DC.W 4 ; LÑnge eines Tabelleneintrages
          DC.B 7 ; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 2 ; Position Bitnummer
          DC.B 3 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!MMUPSRTAB                               ; PSR bei 68030
          DC.B 'B',0,15,1
          DC.B 'L',0,14,1
          DC.B 'S',0,13,1
          DC.B 'A',0,12,1
          DC.B 'W',0,11,1
          DC.B 'I',0,10,1
          DC.B 'M',0, 9,1
          DC.B 'G',0, 8,1
          DC.B 'C',0, 7,1
          DC.B 'T',0, 6,1
          DC.B '#',0, 0,7
          DC.B 0

          SYNC
          DC.W 13  ; LÑnge einer Tabelleneintrages
          DC.B 11  ; max. LÑnge des Textes (ohne Nullterminator)
          DC.B  8  ; Position Bitnummer
          DC.B  9  ; Position Maske
          DC.B 127 ; Flag 32 Bit Maske

!MMUPSR40TAB                            ; PSR bei 68040
          DC.B 'A','D','D','R','E','S','S', 0 ,12,$FF,$FF,$FF,$FF
          DC.B 'B', 0 , 0 , 0 , 0 , 0 , 0 , 0 ,11,  0,  0,  0,  1
          DC.B 'G', 0 , 0 , 0 , 0 , 0 , 0 , 0 ,10,  0,  0,  0,  1
          DC.B 'U','1', 0 , 0 , 0 , 0 , 0 , 0 , 9,  0,  0,  0,  1
          DC.B 'U','0', 0 , 0 , 0 , 0 , 0 , 0 , 8,  0,  0,  0,  1
          DC.B 'S', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 7,  0,  0,  0,  1
          DC.B 'C','M', 0 , 0 , 0 , 0 , 0 , 0 , 5,  0,  0,  0,  1
          DC.B 'M', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 4,  0,  0,  0,  1
          DC.B 'O', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 3,  0,  0,  0,  1
          DC.B 'W', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 2,  0,  0,  0,  1
          DC.B 'T', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1,  0,  0,  0,  1
          DC.B 'R', 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0,  0,  0,  0,  1
          DC.B 0,0

          SYNC
          DC.W 6 ; LÑnge eines Tabelleneintrages
          DC.B 8 ; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 4 ; Position Bitnummer
          DC.B 5 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!MMUTCTAB                                ; TC bei 68030
          DC.B 'E', 0 , 0 ,0,31,1
          DC.B 'S','R','E',0,25,1
          DC.B 'F','C','L',0,24,1
          DC.B 'P','S', 0 ,0,20,15
          DC.B 'I','S', 0 ,0,16,15
          DC.B 'T','I','A',0,12,15
          DC.B 'T','I','B',0, 8,15
          DC.B 'T','I','C',0, 4,15
          DC.B 'T','I','D',0, 0,15
          DC.B 0,0

          SYNC
          DC.W 4 ; LÑnge eines Tabelleneintrages
          DC.B 4 ; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 2 ; Position Bitnummer
          DC.B 3 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!MMUTC40TAB                              ; TC bei 68040
          DC.B 'E', 0 ,15,1
          DC.B 'P', 0 ,20,15
          DC.B 0,0

          SYNC

!TCInvalidMsg
(*$ ? German:
          DC.W 65
          ACZ  ' | TC ungÅltig'
*)
(*$ ? English:
          DC.W 66
          ACZ  ' | TC invalid'
*)

          SYNC
          DC.W 9 ; LÑnge eines Tabelleneintrages
          DC.B 14; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 6 ; Position Bitnummer
          DC.B 7 ; Position Maske, bei 16 Bit Maske HIGH Byte
          DC.B 8 ; Flag: 0=8 Bit Maske, sonst 2. Position der 16 Bit Maske (LOW)

!MMURPTAB                               ; CRP & SRP bei 68030, jedoch nur
                                        ; die Bits 63 - 32, interpretiert
                                        ; als Bits 0 - 31!!!
          DC.B 'L','/','U', 0 , 0 ,0,31,  0,  1
          DC.B 'L','I','M','I','T',0,16,127,255   ; 15 Bit Maske!
          DC.B 'D','T', 0 , 0 , 0 ,0, 0,  0,  3
          DC.B 0

!MMURPTAB1 ACZ     '    '
!MMURPTAB2 ASC     '.'
!MMURPTAB3 ACZ     'ADDRESS='

          SYNC

          DC.W 6 ; LÑnge eines Tabelleneintrages
          DC.B 10; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 4 ; Position Bitnummer
          DC.B 5 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!MMUTTTAB                              ; TT0 & TT1 bei 68030
          DC.B 'L','A','B',0,24,255
          DC.B 'L','A','M',0,16,255
          DC.B 'E', 0 , 0 ,0,15,1
          DC.B 'C','I', 0 ,0,10,1
          DC.B 'R','/','W',0, 9,1
          DC.B 'R','W','M',0, 8,1
          DC.B 'F','C','B',0, 4,7
          DC.B 'F','C','M',0, 0,7
          DC.B 0

          SYNC

          DC.W 6 ; LÑnge eines Tabelleneintrages
          DC.B 11; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 4 ; Position Bitnummer
          DC.B 5 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!MMUTT40TAB                            ; TT0 & TT1 bei 68040
          DC.B 'L','A','B',0,24,255
          DC.B 'L','A','M',0,16,255
          DC.B 'E', 0 , 0 ,0,15,1
          DC.B 'S', 0 , 0 ,0,13,3
          DC.B 'U','1', 0 ,0, 9,1
          DC.B 'U','0', 0 ,0, 8,1
          DC.B 'C','M', 0 ,0, 5,3
          DC.B 'W', 0 , 0 ,0, 2,1
          DC.B 0

          SYNC
          DC.W 8 ; LÑnge eines Tabelleneintrages
          DC.B 12; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 6 ; Position Bitnummer
          DC.B 7 ; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!FPCRTAB  DC.B 'B','S','U','N', 0 ,0,15,1
          DC.B 'S','N','A','N', 0 ,0,14,1
          DC.B 'O','P','e','r','r',0,13,1
          DC.B 'O','V','F','L', 0 ,0,12,1
          DC.B 'U','N','F','L', 0 ,0,11,1
          DC.B 'D','Z', 0 , 0 , 0 ,0,10,1
          DC.B 'I','N','E','X','2',0, 9,1
          DC.B 'I','N','E','X','1',0, 8,1
          DC.B 'P','R','E','C', 0 ,0, 6,3
          DC.B 'R','N','D', 0 , 0 ,0, 4,3
          DC.B 0

          SYNC
          DC.W 13; LÑnge eines Tabelleneintrages
          DC.B 18; max. LÑnge des Textes (ohne Nullterminator)
          DC.B 11; Position Bitnummer
          DC.B 12; Position Maske
          DC.B 0 ; Flag: 0=8 Bit Maske, sonst 16 Bit Maske

!FPSRTAB  DC.B 'F','P','C','C','.','N', 0 , 0 , 0 , 0 ,0,27,1
          DC.B 'F','P','C','C','.','Z', 0 , 0 , 0 , 0 ,0,26,1
          DC.B 'F','P','C','C','.','I', 0 , 0 , 0 , 0 ,0,25,1
          DC.B 'F','P','C','C','.','N','A','N', 0 , 0 ,0,24,1
          DC.B 'Q','U','O','T','.','S','I','G','N', 0 ,0,23,1
          DC.B 'Q','U','O','T','.','Q','U','O','T', 0 ,0,16,127
          DC.B 'E','X','C','.','B','S','U','N', 0 , 0 ,0,15,1
          DC.B 'E','X','C','.','S','N','A','N', 0 , 0 ,0,14,1
          DC.B 'E','X','C','.','O','P','e','r','r', 0 ,0,13,1
          DC.B 'E','X','C','.','O','V','F','L', 0 , 0 ,0,12,1
          DC.B 'E','X','C','.','U','N','F','L', 0 , 0 ,0,11,1
          DC.B 'E','X','C','.','D','Z', 0 , 0 , 0 , 0 ,0,10,1
          DC.B 'E','X','C','.','I','N','E','X','2', 0 ,0, 9,1
          DC.B 'E','X','C','.','I','N','E','X','1', 0 ,0, 8,1
          DC.B 'A','E','X','C','.','I','O','P', 0 , 0 ,0, 7,1
          DC.B 'A','E','X','C','.','O','V','F','L', 0 ,0, 6,1
          DC.B 'A','E','X','C','.','U','N','F','L', 0 ,0, 5,1
          DC.B 'A','E','X','C','.','D','Z', 0 , 0 , 0 ,0, 4,1
          DC.B 'A','E','X','C','.','I','N','E','X', 0 ,0, 3,1
          DC.B 0

(*
          SYNC
          DC.W 40
          DC.B 39
          DC.B 38
          DC.B 39
          DC.B -1 ; Flag : keine Registerausgabe in Form von 'Register.'

!FPBIUTAB ACZ '| Operand Register Bits 24-31 Valid  '
          DC.B 20,1
          ACZ '| Operand Register Bits 16-23 Valid  '
          DC.B 21,1
          ACZ '| Operand Register Bits 15- 8 Valid  '
          DC.B 22,1
          ACZ '| Operand Register Bits  7- 0 Valid  '
          DC.B 23,1
          ACZ '| Operand to Memory Move Pending     '
          DC.B 26,1
          ACZ '| Floating Point Exeption Pending    '
          DC.B 27,1
          ACZ '| Access of Operand Register Expected'
          DC.B 28,1
          ACZ '| Pending Instruction or Access Type '
          DC.B 29,1
          ACZ '| Instruction Pending                '
          DC.B 30,1
          ACZ '| Protokoll Violation Pending        '
          DC.B 31,1
          DC.B 0

          SYNC
          DC.W 32
!FPBIUTYPE ACZ 'Undefined and Reserved         '
          ACZ 'Conditional Instruction Pending'
          ACZ 'Undefined and Reserved         '
          ACZ 'General Instruction Pending    '
          ACZ 'Write of Operand CIR Pending   '
          ACZ 'Undefined and Reserved         '
          ACZ 'Read of Operand CIR Pending    '
          ACZ 'No Pending Instruction or Operand CIR Access'
*)
          SYNC

(*$? ~MAC:
!setTVSC1224
          BSR     WvblFALCON030
          move.w  #$0271,$A2(A1) ; VFT
          move.w  #$026b,$AC(A1) ; VSS
          move.w  #$0265,$A4(A1) ; VBB
          move.w  #$002f,$A6(A1) ; VBE
          move.w  #$006f,$A8(A1) ; VDB
          move.w  #$01ff,$AA(A1) ; VDE
          move.w  #$003e,$82(A1) ; HHT
          move.w  #$0034,$8C(A1) ; HSS
          move.w  #$0032,$84(A1) ; HBB
          move.w  #$0009,$86(A1) ; HBE
          move.w  #$023f,$88(A1) ; HDB
          move.w  #$001c,$8A(A1) ; HDE
          clr.w   $8E(A1)        ; HFS
          clr.w   $90(A1)        ; HEE
          clr.w   $66(A1)        ; SP_SHIFT
          move.w  #$0100,$60(A1) ; ST_SHIFT
          move.w  #$0004,$C2(A1) ; VCO
          move.w  #$0050,$10(A1) ; VWRAP
          move.w  #$0081,$C0(A1) ; VXX
          move.w  #$0200,$0A(A1) ; EXTCLK
          clr.w   $0E(A1)        ; VWR2
          CMP.W   FALCON030MonitorType(A4),D0
          BEQ     SetFALCON030ScreenModeEndeCol
          MOVE.W  D0,FALCON030MonitorType(A4)
          BSR     SetColorConst
!SetFALCON030ScreenModeEndeCol
*)
          rts

!PrtTMONRPADR
          LEA     TMONURPADR(PC),A1
          BSR     PRTSTR
          LEA     TMon_URP(A4),A0
          MOVE.L  A0,D0
          BSR     PrtLONG
          LEA     TMONSRPADR(PC),A1
          BSR     PRTSTR
          LEA     TMon_SRP(A4),A0
          MOVE.L  A0,D0
          BSR     PrtLONG
          LEA     TMONTCADR(PC),A1
          BSR     PRTSTR
          LEA     TMon_TC(A4),A0
          MOVE.L  A0,D0
          BSR     PrtLong
          BSR     PrtLF
          BSR     PrtCR
          LEA     TMONDT0ADR(PC),A1
          BSR     PRTSTR
          LEA     TMon_DTT0(A4),A0
          MOVE.L  A0,D0
          BSR     PrtLong
          LEA     TMONDT1ADR(PC),A1
          BSR     PRTSTR
          LEA     TMon_DTT1(A4),A0
          MOVE.L  A0,D0
          BSR     PrtLong
          BSR     PrtLF
          BSR     PrtCR
          LEA     TMONIT0ADR(PC),A1
          BSR     PRTSTR
          LEA     TMon_ITT0(A4),A0
          MOVE.L  A0,D0
          BSR     PrtLong
          LEA     TMONIT1ADR(PC),A1
          BSR     PRTSTR
          LEA     TMon_ITT1(A4),A0
          MOVE.L  A0,D0
          BSR     PrtLong
          BRA     PrtLF

!TMon_address_translation_tree:
          LEA     TMon_Tree(A4),A0
          TST.W   (A0)
          BEQ.L   TMon_address_trans_ende
          LEA     TMon_Get_Tree(A4),A0
          TST.L   (A0)
          BEQ     TMon_address_do_trans
          MOVEM.L A0-A6/D0-D7,-(SP)
          MOVE.L  A0,A1
          LEA     TMon_URP(A4),A0
          MOVE.W  TMon_Tree(A4),D0
          JSR     (A1)
          MOVEM.L (SP)+,A0-A6/D0-D7
!TMon_address_do_trans
          MOVE.W  SR,-(SP)
          ORI.W   #$0700,SR
          MOVE.L  TMon_address_trans_ende(PC),D0 ; Routine in ATC laden!!!
          TST     is40(A4)
          BNE     TMon_address_trans_40
          LEA     TMon_URP(A4),A0
          DC.W    $F010,$4D00               ; PMOVEFD   (A0),CRP
          LEA     TMon_SRP(A4),A0
          DC.W    $F010,$4900               ; PMOVEFD   (A0),SRP
          LEA     TMon_DTT0(A4),A0
          DC.W    $F010,$0800               ; PMOVEFD   (A0),TT0
          LEA     TMon_DTT1(A4),A0
          DC.W    $F010,$0C00               ; PMOVEFD   (A0),TT1
          LEA     TMon_TC(A4),A0
          DC.W    $F010,$4000               ; PMOVEFD   (A0),TC
          DC.W    $F010,$2400               ; PFLUSHA
          BRA     TMon_address_trans_ende_pull
!TMon_address_trans_40:
          MOVE.L  TMon_URP(A4),D0
          DC.W    $4E7B,$0806               ; MOVEC     D0,URP
          MOVE.L  TMon_SRP(A4),D0
          DC.W    $4E7B,$0807               ; MOVEC     D0,SRP
          MOVE.L  TMon_DTT0(A4),D0
          DC.W    $4E7B,$0006               ; MOVEC     D0,DTT0
          MOVE.L  TMon_DTT1(A4),D0
          DC.W    $4E7B,$0007               ; MOVEC     D0,DTT1
          MOVE.L  TMon_ITT0(A4),D0
          DC.W    $4E7B,$0003               ; MOVEC     D0,ITT0
          MOVE.L  TMon_ITT1(A4),D0
          DC.W    $4E7B,$0004               ; MOVEC     D0,ITT1
          MOVE.L  TMon_TC(A4),D0
          DC.W    $4E7B,$0003               ; MOVEC     D0,TC
          DC.W    $F518                     ; PFLUSHA
!TMon_address_trans_ende_pull:
          MOVE.W  (SP)+,SR
!TMon_address_trans_ende:
          RTS

!stackframe_Test:
          MOVE.L  A7,D2
          MOVE.L  $10,D1  ; Illegal Instruction Exc-Vektor
          LEA     stackfrb(PC),A0
          MOVE.L  A0,$10
          DC.W    $4AFC   ; ILLEGAL
!stackfrb MOVE.L  A7,D0
          MOVE.L  D2,A7
          ADDQ.L  #6,D0
          CMP.L   D0,D2
          SNE     D0
          ANDI    #2,D0
          MOVE.W  D0,StkFrm(A4)   ; = 0 bei 68000, = 2 ab 68010
          MOVE.L  D1,$10
          RTS

!CPU_Test: MOVEQ   #0,D0
          MOVE.W  D0,is10(A4)
          MOVE.W  D0,is20(A4)
          MOVE.W  D0,is30(A4)
          MOVE.W  D0,isFPU(A4)
          MOVE.W  D0,isD10(A4)
          MOVE.W  D0,isD20(A4)
          MOVE.W  D0,isD30(A4)
          MOVE.W  D0,isDFPU(A4)
          MOVE.W  D0,isCD10(A4)
          MOVE.W  D0,isCD20(A4)
          MOVE.W  D0,isCD30(A4)
          MOVE.W  D0,isCDFPU(A4)
          MOVE.L  A7,D2
          MOVE.L  $10,D1        ; Illegal Instruction Exc-Vektor
          LEA     cpufrb(PC),A0
          MOVE.L  A0,$10
          MOVEC.L VBR,D0        ; ILLEGAL ? dann 68000 und nichts mehr.
          MOVEQ   #2,D0
          MOVE    D0,is10(A4)
          MOVE    D0,isD10(A4)
          MOVE    D0,isCD10(A4)
          MOVEC.L CACR,D5       ; ILLEGAL ? dann 68010 und nichts mehr!
          MOVEQ   #2,D0
          MOVE    D0,is20(A4)
          MOVE    D0,isD20(A4)
          MOVE    D0,isCD20(A4)
          LEA     cpu2030frb(PC),A0 ; auf 68040 testen
          MOVE.L  A0,$10
          DC.W    $4E7A,$3003   ; MOVEC   TC,D3  ; 68040 Code
!foundCPU40
          MOVEQ   #2,D0
          MOVE    D0,is30(A4)
          MOVE    D0,is40(A4)
          MOVE    D0,isD30(A4)
          MOVE    D0,isD40(A4)
          MOVE    D0,isCD30(A4)
          MOVE    D0,isCD40(A4)
          MOVE    D0,isDFPU(A4)
          MOVE    D0,isCDFPU(A4)
          MOVEQ   #0,D0         ; !MAC erstmal keine 040-FPU annehmen
          MOVE    D0,isFPU(A4)
          BRA.L   cpufrb
!cpu2030frb
          MOVE.L  D2,A7
          LEA     cpufrb(PC),A0
          MOVE.L  A0,$10
          CMPI.W  #255,D0
          BCC.S   foundCPU30
          MOVE.L  D0,D3
          BSET    #8,D3         ; 68030 : Enable Data Cache Bit im CACR
          BSET    #11,D3        ; 68030 : Clear Data Cache Bit im CACR
          MOVEC.L D3,CACR       ; Bits schreiben,
          MOVEC.L CACR,D3       ; und wieder lesen
          MOVEC.L D5,CACR       ; alten Inhalt herstellen
          BTST    #8,D3         ; Enable Data cache Bit gesetzt?
          BEQ.S   FPU_Test      ; nein, dann 68020
!foundCPU30
          MOVEQ   #2,D0
          MOVE    D0,is30(A4)
          MOVE    D0,isD30(A4)
          MOVE    D0,isCD30(A4)
!FPU_Test MOVE.L  $2C,D3
          MOVE.L  $34,D4
          LEA     fpufrb(PC),A0
          MOVE.L  A0,$2C
          MOVE.L  A0,$34
          LEA     StFrame(A4),A0
          FNOP                  ; tritt hier eine LINE F Exeption auf, gibts
                                ; keine FPU
          FSAVE   (A0)          ; jetzt kriegen wir den IDLE State Frame
          CLR.L   D0
          MOVE.B  1(A0),D0      ; $18 bei 68881, $38 bei 68882
          ADDQ.L  #8,D0
          DIVU    #$20,D0
          MOVE.W  D0,isFPU(A4)  ; ergibt 1 fÅr 68881 und 2 fÅr 68882
          MOVE.W  D0,isDFPU(A4)
          MOVE.W  D0,isCDFPU(A4)
          CLR.L   (A0)
          FRESTORE (A0)         ; Null-State-Frame : FPU reseten
!fpufrb   MOVE.L  D3,$2C
          MOVE.L  D4,$34
!cpufrb   MOVE.L  D2,A7
          MOVE.L  D1,$10
          RTS

(*$ ? German:
TMONURPADR ACZ     'Addr. URP/CRP = '
TMONSRPADR ACZ     '   Addr. SRP = '
TMONTCADR  ACZ     '   Addr. TC = '
TMONDT0ADR ACZ     'Addr. DTT0/TT0 = '
TMONDT1ADR ACZ     '   Addr. DTT1/TT1 = '
TMONIT0ADR ACZ     'Addr. ITT0 = '
TMONIT1ADR ACZ     '   Addr. ITT1 = '
*)
(*$ ? English:
TMONURPADR ACZ     'Adr. URP/CRP = '
TMONSRPADR ACZ     '   Adr. SRP = '
TMONTCADR  ACZ     '   Adr. TC = '
TMONDT0ADR ACZ     'Adr. DTT0/TT0 = '
TMONDT1ADR ACZ     '   Adr. DTT1/TT1 = '
TMONIT0ADR ACZ     'Adr. ITT0 = '
TMONIT1ADR ACZ     '   Adr. ITT1 = '
*)
          SYNC

; This table does only use three stages of address translation! All page
; descriptors are early termination desriptors!
; These leading words are necessary to move the table to a quad word beginning
; address! DO NOT remove them!

                dc.l    0
                dc.l    0
                dc.l    0
                dc.l    0
!table_main     dc.l    $00000002    ; short format table descriptor
                                     ; will point to label table_00_B
                dc.l    $10000001    ; short format early termination
                dc.l    $20000001    ; short format early termination
                dc.l    $30000001    ; short format early termination
                dc.l    $40000001    ; short format early termination
                dc.l    $50000001    ; short format early termination
                dc.l    $60000001    ; short format early termination
                dc.l    $70000001    ; short format early termination
                dc.l    $80000001    ; short format early termination
                dc.l    $90000001    ; short format early termination
                dc.l    $A0000001    ; short format early termination
                dc.l    $B0000001    ; short format early termination
                dc.l    $C0000001    ; short format early termination
                dc.l    $D0000001    ; short format early termination
                dc.l    $E0000001    ; short format early termination
                dc.l    $F0000001    ; short format early termination
                                     ; cache inhibit for I/O and VME via
                                     ; register TT0!

!table_00_B     dc.l    $00000002    ; short format table descriptor
                                     ; will point to label table_00_C
                dc.l    $01000001    ; short format early termination
                dc.l    $02000001    ; short format early termination
                dc.l    $03000001    ; short format early termination
                dc.l    $04000001    ; short format early termination
                dc.l    $05000001    ; short format early termination
                dc.l    $06000001    ; short format early termination
                dc.l    $07000001    ; short format early termination
                dc.l    $08000001    ; short format early termination
                dc.l    $09000001    ; short format early termination
                dc.l    $0A000001    ; short format early termination
                dc.l    $0B000001    ; short format early termination
                dc.l    $0C000001    ; short format early termination
                dc.l    $0D000001    ; short format early termination
                dc.l    $0E000001    ; short format early termination
                dc.l    $0F000001    ; short format early termination

!table_00_C     dc.l    $00000001    ; short format early termination
                dc.l    $00100001    ; short format early termination
                dc.l    $00200001    ; short format early termination
                dc.l    $00300001    ; short format early termination
                dc.l    $00400001    ; short format early termination
                dc.l    $00500001    ; short format early termination
                dc.l    $00600001    ; short format early termination
                dc.l    $00700001    ; short format early termination
                dc.l    $00800001    ; short format early termination
                dc.l    $00900001    ; short format early termination
                dc.l    $00A00001    ; short format early termination
                dc.l    $00B00001    ; short format early termination
                dc.l    $00C00001    ; short format early termination
                dc.l    $00D00001    ; short format early termination
                dc.l    $00E00001    ; short format early termination
                dc.l    $00F00041    ; short format early termination,
                                     ; with cache inhibit

!table_end
!install_68030_table
                movem.l A4/A5,-(SP)
                lea     TMon_URP(A4),A4    ; pointer to PMMU register structure
                lea     table_main(PC),A0  ; compute quad wird address
                move.l  A0,D0
                andi.w  #$FFF0,D0
                move.l  D0,A1
                move.l  A1,A2
                lea     table_end(PC),A5
!loop030        move.l  (A0)+,(A2)+  ; move table to quad word address
                cmpa.l  A5,A0
                bcs     loop030
                moveq   #64,D0       ;move.l  #table_00_B-table_main,D0
                add.l   A1,D0        ; install pointer to stage B in table
                or.l    D0,(A1)
                move.l  #128,D0      ;move.l  #table_00_C-table_main,D0
                add.l   A1,D0        ; install pointer to stage C in table
                or.l    D0,64(A1)    ;or.l    D0,table_00_B-table_main(A1)
                move.l  #$80000002,D0
                move.l  D0,(A4)           ; set High-long word of CRP
                move.l  A1,4(A4)          ; set table address of CRP
                move.l  D0,8(A4)          ; set High-long word of SRP
                move.l  A1,12(A4)         ; set table address of SRP
                move.l  #$80F04445,16(A4) ; set TC
                move.l  #$FE018707,20(A4) ; set TT0
                clr.l   24(A4)            ; set TT1
                movem.l (SP)+,A4/A5
                rts

!DISMICL
          (*$I .\DISM40.ICL *)
          RTS

font8x8:
(*$I dump8x8.fnt *)

!EndOfMon
END;                      (* ENDE ASSEMBLER *)
END MONITOR;


BEGIN
  ASSEMBLER
          JMP     MONITOR
  END;                    (* ENDE ASSEMBLER *)
END TEMPLMON.

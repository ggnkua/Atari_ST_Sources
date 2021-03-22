IMPLEMENTATION MODULE StorBase;
(*$Y+,C-,R-*)

(*-----------------------------------------------------------------------------
 * Copyright Januar 1987 Thomas Tempelmann, E.L.Kirchner Str.25, 29 Oldenburg
 *-----------------------------------------------------------------------------
 * Kurzbeschreibung : Zentrale Memoryverwaltung fÅr MOS
 *-----------------------------------------------------------------------------
 * Systemversion : MOS 1.1
 * Textversion   : V#0203
 *-----------------------------------------------------------------------------
 * Datum    Vers  Autor  Bemerkung (Arbeitsbericht)
 *-----------------------------------------------------------------------------
 * 09.01.87  0.0  TT     Erste theoretisch lauffÑhige Komplettversion
 * 04.02.87  1.0  TT     Erste Version unter MOS, Aufruf DeAllocAll bei Term.
 * 10.02.87  1.0  TT     Keine Imports mehr; @SetLevel impl.; alter Process-
 *                       Term-Vektor wird nach eigener Routine angesprungen.
 * 11.02.87  1.0  TT     processTerm: kein TRAP #1-Aufruf mehr
 * 18.02.87  1.1  TT     MDSt-Verwaltung TOS-Kompatibel. Leider keine Freigabe
 *                       der MDSts mehr, da nicht erkennbar, wann ein MDst
 *                       vollkommen frei ist.
 * 21.02.87  1.2  TT     MDSt wird mîglichst am Speicherende alloziert.
 *                       SysLevel katalogisiert mit TOS-owner.
 * 22.02.87  1.2  TT     Åber 408-Vektor wird aller userMemory freigegeben,
 *                       ungerade LÑngen werden dabei begradigt (Bit 31 in
 *                       owner wird gelîscht).
 * 25.05.87  1.3  TT     TOS-Variablen aus 'TOSPatch' importiert.
 * 14.06.87  1.4  TT     Available-Funktion neu
 * 22.06.87  1.5  TT     Infinite loop in allocU1 verhindert (bei 'notFnd')
 * 01.07.87  1.6  TT     @SetLevel raus, stattdessen SetEnvelope-Verwendung
 * 09.09.87  1.7  TT     Keep, Extend neu; Regs bei DeAllocATE, MemSize gerettet
 * 25.10.87  1.8  TT     Keep jetzt KeepAll; Keep f. einzl. Blocks; MemSize
 *                       liefert auch ungerade LÑngen; DeAllocAll prÅft auch
 *                       Prozeû-ID.
 * 24.11.87  1.9  TT     Levels raus, jeder Level hat eigene Prozeûkennung.
 * 07.01.88  1.10 TT     terminate ruft DeAllocAll nun korrekt auf
 * 24.01.88  1.11 TT     Bei Malloc wird oberes owner-Byte immer # 0 gesetzt
 * 27.01.88  1.12 TT     testMDSt reagiert bei 32 statt 10 freien EintrÑgen
 * 02.06.88  1.13 TT     Enlarge-Funktion bei 'Resize0'; allocU1 setzte owner
 *                       nicht, wenn amout = ganzem Freibereich war.
 * 17.06.88  1.14 TT     MD-Stack-Vars werden nicht mehr benîtigt.
 * 24.07.88  1.15 TT     MPBPtr wird generisch ermittelt.
 * 27.07.88       TT     LongStack wird wieder in getMD benutzt, damit
 *                       Accessories und AUTO-Prgs laufen.
 * 29.07.88       TT     GetMPBPtr korrigiert (Trace-Bit wurde nicht gelîscht)
 * 18.08.88  1.16 TT     LongStack-Vars werden f. TOS 1.0/1.2 hier konstant
 *                       verwendet, ab TOS 1.3 werden die MD nicht mehr selbst
 *                       angelegt/freigegeben, dadurch kein autom. LongStack-
 *                       Erweitern mehr mîglich.
 *                       D4 wird nun in ALLOCATE gerettet.
 * 23.08.88       TT     Enlarge f. TOS 1.4 korrig, TrailAvail neu
 * 24.08.88       TT     Register D5/D6 werden bei TrailAvail gerettet;
 *                       owner wird sicherheitshalber bei Enlarge mit vollem
 *                       folg. Freibereich neu gesetzt; In owner wird nicht
 *                       mehr eine eigene Prozeûkennung abgelegt.
 * 01.10.88       TT     SysAlloc macht Speicher nun dauerhaft resident und
 *                       gibt ihn nicht mehr bei Prozeûende des Moduls frei.
 * 23.10.88       TT     ProcessID aus MOSCtrl statt TOSPatch
 * 06.11.88       TT     testMDSt erweitert Pool nicht, wenn dieser noch
 *                       nicht benutzt wurde (wenn Liste leer) oder Stack
 *                       nocht groû genug ist.
 * 11.02.89       TT     Modul in StorBase umbenannt
 * 05.07.89       TT     Wenn MPBPtr nicht gefunden wird, sind die Funktionen
 *                       ALLOCATE, DEALLOCATE, SysAlloc (wie ALLOCATE),
 *                       MemAvail, Available, AllAvail (wie MemAvail)
 *                       weiterhin normal benutzbar. TrailAvail liefert immer
 *                       Null.
 *                       Die Funktionen MemSize, Keep, KeepAll, Enlarge und
 *                       DEALLOCATE mit size # 0L (korrekte Grîûe geht nicht!)
 *                       lîsen bei Aufruf einen Laufzeitfehler (-14,
 *                       IllegalCall) aus.
 *                       Es ist die Aufgabe des neuen Storage-Moduls, diese
 *                       Konventionen einzuhalten!
 * 16.07.90       TT     Enlarge macht keinen Fehler mehr mit ungeraden Werten
 * 29.08.90       TT     DEALLOCATE meldet keinen Fehler mehr, wenn LÑnge # 0
 *                       und kein MPB-Zugriff; Resize neu
 * 09.10.90       TT     AllAvail berÅcksichtigt TT-RAM
 * 28.03.91       TT     AllAvail belegt alle Bereiche > 1024, um auch ohne MPB-
 *                       Zugriff sinnvolle Ergebnisse zu liefern.
 * 25.04.91       TT     Neues Verfahren bei GetMPB, lÑuft nun mit Mega STE
 *                       und wahrscheinlich auch mit PAMs Net.
 * 03.05.91       TT     AllAvail Åbergibt Wert nicht mehr in D1, so daû GEMDOS
 *                       D1 ruhig zerstîren kann.
 * 18.06.91       TT     Enlarge liefert korrekten Ergebniswert.
 * 15.09.91       TT     GetMPBPtr findet offenbar auch auf dem TT den Ptr,
 *                       was aber keinen Sinn macht, da nicht alle Listen
 *                       oder so berÅcksichtigt werden. Damit da kein Scheiû
 *                       passiert, wird bei TOS 3.x nie nach dem MPB gesucht.
 * 19.01.94       TT     kein GetMPBPtr bei MiNT/MagX
 * 04.04.94       TT     AllAvail vermeidet nun StackÅberlauf
 *----------------------------------------------------------------------------*)

(*
 *
 * --> In der Free-List sind alle MD.start aufsteigend geordnet.
 *
 * D6: MPBPtr; D7: =0 -> allocMDSt aktiv.
 *
 * In owner steht im oberen Byte nur noch die Kennung f. ungerade LÑngen.
 * Wenn ein Programm mit Ptermres endet, passiert es, daû die Speicherblocks,
 * die zu der Zeit eine ungerade LÑnge haben, nicht dem Prozeû zugehîrig
 * erkannt werden und deshalb nicht resident gemacht werden. Zwar werden beim
 * Prozeûende durch 'DeAllocAll' alle owner bereinigt, aber leider wird der
 * Term-Vektor bei Ptermres erst nach Residentmachen des Speichers angesprungen,
 * sodaû 'DeAllocAll' zu spÑt zum Zuge kommt.
 * Mit diesem kleinen Fehler sollte sich leben lassen, vor Allem, da beim
 * Residentmachen durch 'InstallModule' dieses Problem nicht auftritt.
 *)


FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, LongWord, ADR, BYTE, WORD;

FROM MOSCtrl IMPORT ProcessID;

FROM MOSSupport IMPORT CallSuper;

FROM MOSGlobals IMPORT IllegalCall, MemArea, Date;

FROM MOSConfig IMPORT ExtendedMemoryAccess;

FROM PrgCtrl IMPORT EnvlpCarrier, TermCarrier, CatchProcessTerm, SetEnvelope;

FROM CookieJar IMPORT GetCookie;


VAR     MDRoot    : ADDRESS;
        LongStack : ADDRESS;
        LStackPtr : ADDRESS;
        LStackFree: ADDRESS;

CONST

  minMDs = 32; (* Soviel MDs mÅssen noch frei sein (s. testMDSt) *)

  ElemSize = $480; (* (64 * mdSize2) Um soviel wird der OS-Pool erweitert *)


TYPE P_MD = POINTER TO MD;
     
     MD = RECORD
            next: P_MD;
            start: Address;
            length: Longcard;
            owner: Longword    (* Bit 31: length ungerade *)
          END;
     
     P_MD2 = POINTER TO MD2;
     
     MD2 = RECORD
             mylen: Integer;  (* Immer = 1 *)
             next: P_MD;
             start: Address;
             length: Longcard;
             owner: Longword
          END;
     
CONST mdSize0 = 16;
      mdSize2 = 18;   (* Plus vorstehendes LÑngen-word (=1) *)

      m_alloc = $48;
      m_free  = $49;
      m_shrink= $4A;
      end_os  = $4FA;


TYPE P_MPB = POINTER TO MPB;
     
     MPB = RECORD
             free: P_MD;
             used: P_MD;
             boomer: P_MD
           END;
     

VAR MPBPtr: P_MPB;

VAR oldStorage: BYTE;


PROCEDURE GetMPBPtr;
  (*$L-*)
  BEGIN
    ASSEMBLER
        ; Malloc (2)
        MOVEQ   #2,D0
        MOVE.L  D0,-(A7)
        MOVE    #$48,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  D0,-(A7)
        
        CLR.L   -(A7)
        MOVE    #$20,-(A7)      ; Super (0)
        TRAP    #1
        MOVE.L  D0,2(A7)
        
        MOVE.L  $4F2,A0         ; ^TOS-Header
        MOVE.L  8(A0),A0        ; wg. altem AHDI
        CMPI.B  #$03,2(A0)
        BEQ.W   error           ; erstmal nicht bei TT wg. Fast-RAM
        
        LEA     $800,A0
        MOVE.L  end_os,D1
        SUB.L   A0,D1
        LSR     #1,D1           ; D1: Anzahl zu suchender Words
        
        ; *** nach dem MD suchen ***
        
        MOVE.L  6(A7),D0        ; zu suchender 'start'
        MOVE.L  ProcessID,A2
        MOVE.L  (A2),D2         ; zu suchender 'owner'
        
        CLR.L   -(A7)           ; Flag: bisher nix gefunden
        
    l1: CMP.W   (A0)+,D0
        DBEQ    D1,l1
        BNE     e1
        CMP.L   -4(A0),D0       ; stimmt 'start'?
        DBEQ    D1,l1
        BNE     e1
        CMPI.L  #2,(A0)         ; stimmt 'length'?
        DBEQ    D1,l1
        BNE     e1
        CMP.L   4(A0),D2        ; stimmt 'owner'?
        DBEQ    D1,l1
        BNE     e1
        
        ; *** MD gefunden ***
        
        TST.L   (A7)+
        BNE     error           ; mehrfach gefunden -> Abbruch
        
        LEA     -8(A0),A1
        MOVE.L  A1,-(A7)        ; Adr. des MD merken
        
        DBRA    D1,l1           ; weitersuchen

    e1: MOVE.L  (A7)+,A1
        MOVE.L  A1,D2
        BEQ     error           ; nicht gefunden
        
        ; *** nach mîglichen MPBs suchen ***
        
        LEA     $800,A0
        MOVE.L  end_os,D1
        SUB.L   A0,D1
        LSR     #1,D1           ; D1: Anzahl zu suchender Words
        
        CLR.L   -(A7)           ; Endmarke f. gefundene Adressen
        
    l2: CMP.W   (A0)+,D2
        DBEQ    D1,l2
        BNE     e2
        CMP.L   -4(A0),D2       ; steht ^MD in MPB.used?
        DBEQ    D1,l2
        BNE     e2
        ; einen haben wir...
        PEA     -8(A0)
        DBRA    D1,l2           ; weitersuchen
        
    e2:
        ; *** Bereich wieder freigeben. Dann ***
        ; *** steht in MPB.used der ^MD.next ***
        
        MOVE.L  (A1),-(A7)      ; MD.next merken
        MOVE.L  D0,-(A7)
        MOVE    #$49,-(A7)      ; Mfree()
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  (A7)+,D2        ; MD.next
        
        ; *** nochmal die mîgl. MPBs prÅfen ***
        
    l3: MOVE.L  (A7)+,D0        ; ^MD
        BEQ     e3
        MOVE.L  D0,A0
        CMP.L   4(A0),D2        ; MBP.used = MD.next?
        BNE     l3
        TST.L   MPBPtr
        BNE     err2            ; mehrfach gefunden -> Abbruch
        ; *** MPB gefunden ***
        MOVE.L  A0,MPBPtr
        BRA     l3              ; weitersuchen
        
  err2: TST.L   (A7)+
        BNE     err2
        CLR.L   MPBPtr

    e3: TRAP    #1              ; Super (SSP)
        ADDQ.L  #6,A7
        BRA     ende
        
 error: TRAP    #1              ; Super (SSP)
        ADDQ.L  #6,A7
        MOVE    #$49,-(A7)      ; Mfree()
        TRAP    #1
        ADDQ.L  #2,A7
        CLR.L   MPBPtr

  ende: ADDQ.L  #4,A7           ; Adr. vom angeforderten Block vom Stack
    END;
  END GetMPBPtr;

(* alt:
  PROCEDURE GetMPBPtr;
    (*$L-*)
    BEGIN
      ASSEMBLER
          ; MPB-Root suchen
          CLR.L   MPBPtr
  
          PEA     set_trc(PC)
          MOVE    #4,-(A7)
          MOVE    #5,-(A7)
          TRAP    #13             ; setexec (4, set_trc)
          ADDQ.L  #8,A7
          ILLEGAL
  
          MOVE.L  #-1,-(A7)
          MOVE.W  #$48,-(A7)
          TRAP    #1              ; malloc (-1L)
          ADDQ.L  #6,A7
  
          PEA     rst_trc(PC)
          MOVE    #4,-(A7)
          MOVE    #5,-(A7)
          TRAP    #13             ; setexec (4, rst_trc)
          ADDQ.L  #8,A7
          ILLEGAL
  
          RTS
  
        set_trc:
          MOVE.L  D0,$10          ; vektor #4 wiederherstellen
          LEA     sv_trc(PC),A0
          MOVE.L  $24,(A0)        ; vektor #9 (trace) retten
          LEA     trace(PC),A0
          MOVE.L  A0,$24          ; vektor #9 (trace) setzen
          ORI.W   #$8000,(A7)     ; Trace-Bit setzen
          ADDQ.L  #2,2(A7)        ; PC hinter ILLEGAL-Instr
          RTE
  
        rst_trc:
          MOVE.L  D0,$10          ; vektor #4 wiederherstellen
          MOVE.L  sv_trc(PC),$24  ; vektor #9 (trace) rÅcksetzen
          ANDI.W  #$3FFF,(A7)     ; Trace-Bit(s) lîschen
          ADDQ.L  #2,2(A7)        ; PC hinter ILLEGAL-Instr
          RTE
  
        sv_trc:
          DC.L    0
  
        trace:
          MOVE.L  A0,-(A7)
          MOVE.L  4+2(A7),A0
          CMPI.W  #$4E90,(A0)     ; JMP (A0) - Instr ?
          BEQ     trc2
        trc3
          MOVE.L  (A7)+,A0
          ORI.W   #$8000,(A7)     ; Trace-Bit erneut setzen
          RTE
        trc2:
          LEA     trace2(PC),A0
          MOVE.L  A0,$24          ; setexec (9, trace2)
          BRA     trc3
  
        trace2:
          MOVE.L  A0,-(A7)
          MOVE.L  4+2(A7),A0
          CMPI.W  #$6100,(A0)     ; JSR x.L - Instr ?
          BEQ     trc4
          MOVE.L  (A7)+,A0
          RTE
        trc4:
          CMPI.L  #-1,4+6(A7)     ; steht -1 (malloc-param) auf Stack ?
          BNE     trc_err         ; nicht gefunden
          TST.B   4+6+4(A7)       ; ist Adr. v. MPB < $1000000 ?
          BNE     trc_err         ; nicht gefunden
          MOVE.L  4+6+4(A7),MPBPtr ; auf Supervisor-Stack steht MPB-Pointer
        trc_err
          MOVE.L  (A7)+,A0
          ANDI.W  #$7FFF,(A7)     ; Trace-Bit lîschen
          RTE
      END
    END GetMPBPtr;
    (*$L=*)
*)


(*$L-*)
PROCEDURE IllCall;
  BEGIN
    ASSEMBLER
        TRAP    #6
        DC.W    IllegalCall-$C000       ; caller caused, Text folgt
        ACZ     'StorBase: no MPB!'
        SYNC
    END
  END IllCall;


(*$L-*)
PROCEDURE initMDSt;
BEGIN
ASSEMBLER
; D0: pMD
        MOVE.L  D0,A0
        MOVE.L  MD.length(A0),D5
        MOVE.L  MD.start(A0),A1
        
        ADDQ.L  #2,A1
        MOVEQ   #mdSize2,D2
        
        ; Ende der MD-Freiliste suchen
        MOVE.L  MDRoot,A0
l0      TST.L   (A0)
        BEQ     st0
        MOVE.L  (A0),A0
        BRA     l0
        
nxt     MOVE    #1,-2(A1)       ; MD.mylen
        MOVE.L  A1,(A0)         ; Adr. des MD dem VorgÑnger in MD.next zuweisen
        MOVE.L  A1,A0
        ADDA.L  D2,A1
st0     SUB.L   D2,D5
        BCC     nxt
        
        ; letztes Element mit NIL markieren
        CLR.L   (A0)            ; MD.next
END;
END initMDSt;


FORWARD allocU1;

(*$L-*)
PROCEDURE testMDSt;
  CONST lstsize = 32 * 9;
  BEGIN
    ASSEMBLER
        
        TST     D7
        BEQ     ende            ; Rekursionen mîgen wir nicht

        MOVE.L  MDRoot,A0
        MOVE.L  (A0),D0
        BEQ     ende            ; Keine Erweiterung, wenn noch kein Pool exist.

        MOVE.L  LStackFree,A0
        MOVE.W  (A0),D1
        DIVU    #9,D1           ; D1: Anz. freier MD-PlÑtze
        SUBI    #minMDs,D1      ; mind. benîtigte freie Anzahl
        BCC     ende            ; noch genug frei
        NEG     D1              ; -> fehlende Anzahl in Liste prÅfen
        SUBA.L  A0,A0
loop0   MOVE.L  0(A0,D0.L),D0
        DBEQ    D1,loop0
        BNE     ende
gotit
        ; Neuen MDSt anlegen
        
        ; Size v. elems*16 als amount
        MOVE.L  #ElemSize,D5
        MOVEQ   #0,D3
        CLR     D7
        MOVEQ   #0,D4           ; owner = 0L
        JSR     allocU1         ; D6 (MPBPtr) stimmt wohl noch
        MOVEQ   #1,D7
        
        TST.L   D0
        BEQ     ende
        
        JSR     initMDSt
ende
END;
END testMDSt;


(*$L-*)
PROCEDURE getMD;  (* Ergebnis in D0 *)
BEGIN
ASSEMBLER
        ; D3 erhalten !
        ; D4: owner
        
        MOVE.L  MDRoot,A0
        TST.L   (A0)
        BEQ     instack
        
        MOVE.L  (A0),A1
        MOVE.L  (A1),(A0)
        MOVE.L  A1,D0
        BRA     ende
        
instack MOVEQ   #0,D0
        MOVE.L  LStackFree,A0
        CMPI.W  #9,(A0)        ; noch Platz im Stack ?
        BLS     ende
        SUBI.W  #9,(A0)        ; freie Elemente in Stack
        MOVE.L  LStackPtr,A0
        MOVE.W  (A0),D0        ; Stackpointer
        ASL.W   #1,D0          ; *2
        EXT.L   D0
        MOVE.L  D0,A1
        ADDA.L  LongStack,A1
        ADDI.W  #9,(A0)        ; Stackpointer erhîhen
        MOVE.W  #1,(A1)        ; die LÑnge des Elements im Element ablegen
        ADDQ.L  #2,A1
        MOVE.L  A1,D0
        
ende    MOVE.L  D4,MD.owner(A1)
END
END getMD;


(*$L-*)
PROCEDURE linkFree; (* Linkt MD mit Nachfolger zusammen. *)
BEGIN
ASSEMBLER
        ; A0: ^vor-vorigen MD
        
        MOVE.L  (A0),A4                 ; (MD.next)  Adr. des vorigen MD
        MOVE.L  (A4),A1                 ; (MD.next)  Adr. des MD
        ; A1 auslinken
        MOVE.L  MD.length(A1),D0        ; LÑnge des Folgenden
        ADD.L   D0,MD.length(A4)        ; Auf LÑnge des MD aufaddieren
        MOVE.L  (A1),(A4)               ; Folgenden MD auslinken
        MOVE.L  D6,A0
        CMPA.L  MPB.boomer(A0),A1
        BNE     @FC8801
        MOVE.L  A4,MPB.boomer(A0)
@FC8801 ; MD aus TOS-Stack austragen
        MOVE.L  MDRoot,A0
        MOVE.L  (A0),(A1)
        MOVE.L  A1,(A0)
        SUBA.L  A1,A1
ende
END
END linkFree;


(*$L-*)
PROCEDURE insertFree;
BEGIN
ASSEMBLER
        ; TrÑgt einen ungelinkten MD in Freiliste ein
        ; pMD wird in D0 Åbergeben
        
        MOVE.L  A4,-(A7)
        MOVE.L  D0,A4
        MOVE.L  D6,A0
        LEA     (A0),A2
        MOVE.L  (A0),A1         ; MPB.free
        
        ; Wir suchen in Freelist die MDs, zw. die der neue MD paût.
        BRA     cont2
srch2   MOVE.L  MD.start(A4),D0 ; start des freizugebenden Bereichs
        CMP.L   MD.start(A1),D0 ; start aus Free-List
        BLE     fnd2            ; Hier paût er hin
        MOVE.L  A2,D1
        MOVE.L  A1,A2           ; VorgÑnger retten
        MOVE.L  (A2),A1         ; MD.next
cont2   MOVE.L  A1,D0
        BNE     srch2
fnd2
        ; Neuer Freibereich wird in Free-list eingelinkt:
        MOVE.L  A1,(A4)         ; MD.next des freizug. Bereichs setzen
        MOVE.L  A4,(A2)         ; Adr. des freizugebenden Bereichs einlinken
        
        ; boomer-^ setzen, falls er NIL ist
        MOVE.L  D6,A0
        TST.L   MPB.boomer(A0)
        BNE     exists
        MOVE.L  A4,MPB.boomer(A0)
exists
        ; Liegt hinter dem freigewordenen Bereich noch ein freier ?
        MOVE.L  A1,D0
        BEQ     noNext
        MOVE.L  MD.start(A4),D0         ; Start des neuen Freibereichs
        ADD.L   MD.length(A4),D0        ; Plus LÑnge des neuen Freibereichs
        CMP.L   MD.start(A1),D0         ; = Beginn des folgenden Freibereichs ?
        BNE     noNext                  ; Nî
        
        ; Die beiden Freibereiche verketten
        MOVE.L  A2,A0
        MOVEM.L A4/A2,-(A7)
        JSR     linkFree
        MOVEM.L (A7)+,A4/A2
        BRA     cont1
        
noNext  SUBA.L  A1,A1
cont1   ; Liegt vor dem freigewordenen Bereich noch ein freier ?
        CMP.L   A2,D6
        BEQ     ende                    ; kein voriger Bereich
        MOVE.L  MD.start(A2),D0         ; Start des Bereichs des VorgÑngers
        ADD.L   MD.length(A2),D0        ; Plus LÑnge des VorgÑngerbereichs
        CMP.L   MD.start(A4),D0         ; = Beginn des neuen Freibereichs ?
        BNE     ende                    ; Nî
        
        ; Die beiden Freibereiche verketten
        MOVE.L  D1,A0
        JSR     linkFree
        
ende    MOVE.L  (A7)+,A4
END
END insertFree;


(*$L-*)
PROCEDURE Resize1;  (* liefert in D0.W Boolean, ob alles geklappt *)
BEGIN
ASSEMBLER
        ; length in D4, ^block-Adr in D5
        ;MOVE    SR,-(A7)
        ;ORI     #$700,SR
        
        ; Neuer MDSt nîtig ?
        MOVEM.L D4/D5,-(A7)
        JSR     testMDSt
        MOVEM.L (A7)+,D4/D5
        
        MOVE.L  D5,A0
        MOVE.L  (A0),D3
        
        ; belegten Bereich suchen
        MOVE.L  D6,A2
        ADDQ.L  #MPB.used,A2    ; LEA MPB.used(A2),A2
        BRA     cont0
srch0   CMP.L   MD.start(A1),D3
        BEQ     found0
        MOVE.L  A1,A2
cont0   MOVE.L  (A2),A1         ; MD.next
        MOVE.L  A1,D0
        BNE     srch0
        
        ; Nicht gefunden in Free-Liste
        CLR.L   (A0)            ; Variable auf NIL
        BRA.L   ende
        
found0  TST.L   D4
        BEQ     freeAll
        MOVE.L  MD.length(A1),D1
        MOVE.B  MD.owner(A1),D0
        BPL     even
        SUBQ.L  #1,D1
even    TST.L   D4
        BMI     enlarg
        SUB.L   D4,D1           ; neuer User-amount
        BHI.W   shrink
        
freeAll MOVE.L  (A1),(A2)       ; MD auslinken
        CLR.L   (A0)            ; Variable auf NIL
        MOVE.L  A1,D0
        BRA.W   freeIt

endeOK2 MOVE.B  D0,MD.owner(A1)
        BRA.W   endeOK

ende2   MOVEQ   #0,D0
        BRA.W   ende

enlarg  ; amount vergrîûern
        SUB.L   D4,D1           ; neuer, vergrîûerter, User-amount
        ANDI    #$7F,D0
        BTST    #0,D1
        BEQ     even4
        ADDQ.L  #1,D1
        ORI     #$80,D0
even4   CMP.L   MD.length(A1),D1        ; Bleibt bisherige Wort-LÑnge gleich ?
        BEQ     endeOK2                 ; dann fertig
        MOVE.W  D0,-(A7)
        MOVE.L  MD.start(A1),D2
        ADD.L   MD.length(A1),D2        ; hier muû ein Freibereich stehen
        ; erstmal prÅfen, ob noch genÅgend Platz dahinter frei ist
        MOVE.L  D6,A0
        LEA     MPB.free(A0),A2
        MOVE.L  (A2),A0
        BRA     cont2
srch2   CMP.L   MD.start(A0),D2 ; start aus Free-List
        BEQ     fnd2            ; gefunden
        MOVE.L  A0,A2           ; VorgÑnger retten
        MOVE.L  (A2),A0         ; MD.next
cont2   MOVE.L  A0,D0
        BNE     srch2
        MOVE.W  (A7)+,D0
        BRA.W   ende2           ; war wohl nix
fnd2    MOVE.W  (A7)+,D0
        MOVE.L  MD.length(A0),D4 ; free-LÑnge
        MOVE.L  D4,D2
        ADD.L   MD.length(A1),D4 ; used-LÑnge
        SUB.L   D1,D4           ; ist Gesamtbereich > neue LÑnge ?
        BCS     ende2           ;   nein -> Ende
        BEQ     remfmd          ;   sogar gleich, dann free-MD lîschen
        MOVE.B  D0,MD.owner(A1) ; Byte-LÑnge setzen
        ; Used vergrîûern, Free verkleinern
        MOVE.L  D1,MD.length(A1) ; neue Used-Grîûe
        MOVE.L  D4,MD.length(A0) ; neue Free-Grîûe
        SUB.L   D4,D2            ; Diff zw. alter und neuer Used-LÑnge
        ADD.L   D2,MD.start(A0)  ; neuer Free-Start
        BRA     endeOK
remfmd  ; Freibereich wird ganz belegt -> Free-MD auslinken
        MOVE.B  D0,MD.owner(A1) ; Byte-LÑnge setzen
        MOVE.L  (A0),(A2)       ; Free-MD auslinken
        MOVE.L  D6,A1
        CMPA.L  MPB.boomer(A1),A0 ; zeigt boomer auf ausgelinkten MD ?
        BNE     @FC8801
        MOVE.L  A2,MPB.boomer(A1) ; dann auf VorgÑnger
@FC8801 ; MD aus TOS-Stack austragen
        MOVE.L  MDRoot,A1
        MOVE.L  (A1),(A0)       ; MD in MDStack einlinken
        MOVE.L  A0,(A1)
        BRA     endeOK

shrink  ; newSize in D1, ^used-MD in A1
        ANDI    #$7F,D0
        BTST    #0,D1
        BEQ     even2
        ADDQ.L  #1,D1
        ORI     #$80,D0
even2   MOVE.B  D0,MD.owner(A1)
        CMP.L   MD.length(A1),D1        ; Bleibt bisherige LÑnge gleich ?
        BEQ     endeOK                  ; dann bleibt's beim Alten
        MOVEM.L D1/A1,-(A7)
        MOVEQ   #0,D4
        JSR     getMD                   ; get new MD
        MOVEM.L (A7)+,D1/A1
        TST.L   D0                      ; Keinen MD bekommen ?
        BEQ     ende                    ; Macht nix.
        MOVE.L  D0,A2                   ; Adr. des neuen MD
        MOVE.L  MD.start(A1),D0         ; Start des belegten Bereichs
        ADD.L   D1,D0                   ; Plus neue Grîûe
        MOVE.L  D0,MD.start(A2)         ; Ergibt Start des neuen Freibereichs
        MOVE.L  MD.length(A1),D0        ; Bisherige Used-LÑnge
        SUB.L   D1,D0                   ; Minus neue Grîûe
        MOVE.L  D0,MD.length(A2)        ; Ergibt neue FreilÑnge
        BNE     qw1
        BREAK
      qw1:
        MOVE.L  D1,MD.length(A1)        ; Belegt-LÑnge korrigieren
        BNE     qw2
        BREAK
      qw2:
        MOVE.L  A2,D0
freeIt  JSR     insertFree

endeOK  MOVEQ   #1,D0

ende    ;MOVE    (A7)+,SR
END;
END Resize1;


(*$L-*)
PROCEDURE findMD; (* D6: MPBPtr, D5: start *)
BEGIN
ASSEMBLER
        MOVE.L  D6,A0
        MOVE.L  MPB.used(A0),A0
      s CMP.L   MD.start(A0),D5
        BEQ     f
        MOVE.L  (A0),A0
        MOVE.L  A0,D0
        BNE     s
      f MOVE.L  A0,D0
END
END findMD;


(*$L-*)
PROCEDURE resize2; (* D6: MPBPtr, D5: start, D3: ADR(p), D4: len *)
BEGIN
ASSEMBLER
        TST.L   D4
        BEQ     all
        
        JSR     findMD
        BEQ.W   endeClrF

        MOVE.L  MD.length(A0),D1
        MOVE.B  MD.owner(A0),D0
        BPL     even
        SUBQ.L  #1,D1
even    SUB.L   D4,D1           ; neuer User-amount
        BLE.W   all

        ANDI    #$7F,D0
        BTST    #0,D1
        BEQ     even2
        ADDQ.L  #1,D1
        ORI     #$80,D0
even2   CMP.L   MD.length(A0),D1        ; Bleibt bisherige LÑnge gleich ?
        BEQ     endeSet                 ; dann bleibt's beim Alten

        TST.L   D4
        BMI     enlarg

        ; Mshrink ausfÅhren
        MOVE.B  D0,MD.owner(A0)
        MOVE.L  D1,-(A7)        ; neue LÑnge
        MOVE.L  D5,-(A7)        ; start
        CLR     -(A7)
        MOVE    #m_shrink,-(A7)
        TRAP    #1              ; Mshrink (p)
        ADDA.W  #12,A7
        BRA.W   endeT

all     MOVE.L  D5,-(A7)
        MOVE    #m_free,-(A7)
        TRAP    #1              ; Mfree (p)
        ADDQ.L  #6,A7
        MOVE.L  D3,A0
        CLR.L   (A0)
        TST.L   D0
        BEQ.W   endeT
        BRA.W   endeF

enlarg  ; anschlieûenden Free-MD ermitteln
        MOVE.L  D1,D4                   ; neue gerundete LÑnge
        SUB.L   MD.length(A0),D4        ; D4: neue gerundete LÑngendiff. (pos.)
        MOVE    D0,-(A7)
        MOVE.L  MD.start(A0),D2
        ADD.L   MD.length(A0),D2        ; hier muû ein Freibereich stehen
        MOVE.L  D6,A2
        MOVE.L  MPB.free(A2),A2
        BRA     cont2
srch2   CMP.L   MD.start(A2),D2 ; start aus Free-List
        BEQ     fnd2            ; gefunden
        MOVE.L  (A2),A2         ; MD.next
cont2   MOVE.L  A2,D0
        BNE     srch2
        MOVE    (A7)+,D0
        BRA     endeF           ; dahinter nix mehr frei
fnd2    MOVE    (A7)+,D0
        MOVE.L  MD.length(A2),D2 ; free-LÑnge
        ADD.L   MD.length(A0),D2 ; plus used-LÑnge ergibt gesamte verfÅgb. LÑnge
        SUB.L   D1,D2           ; minus neue benîtigte LÑnge ist Rest-FreilÑnge
        BCS     endeF           ; reicht nicht aus
        BEQ     replace         ; da wird's schwierig...
        MOVE.L  D2,MD.length(A2) ; free-LÑnge korrigieren
        ADD.L   D4,MD.start(A2)  ; free-Start korrigieren
        MOVE.L  D1,MD.length(A0) ; used-LÑnge korrigieren

endeSet MOVE.B  D0,MD.owner(A0)
        BRA     endeT

replace ; der Frei-Bereich muû entfernt werden.
        ; dazu wird der Used-Bereich freigegeben und dann wieder in einen
        ; used-Bereich zurÅckverwandelt
        MOVE.L  D5,-(A7)
        MOVE    #m_free,-(A7)
        TRAP    #1              ; Mfree (p)
        ADDQ.L  #6,A7

        ; MD in Freibereich wiederfinden
        MOVE.L  D6,A0
      s MOVE.L  A0,A1           ; VorgÑnger retten
        MOVE.L  (A0),A0
        CMP.L   MD.start(A0),D5
        BNE     s
        ; MD aushÑngen und in Used-List einhÑngen
        MOVE.L  (A0),(A1)
        MOVE.L  D6,A2
        CMPA.L  MPB.boomer(A2),A0
        BNE     bok
        MOVE.L  A1,MPB.boomer(A2)
bok     MOVE.L  MPB.used(A2),MD.next(A0)
        MOVE.L  A0,MPB.used(A2)

endeT   MOVEQ   #1,D0
        RTS

endeClrF
        MOVE.L  D3,A0
        CLR.L   (A0)
endeF   MOVEQ   #0,D0
END
END resize2;


(*$L+*)
PROCEDURE Resize0 ( VAR p: Address; len: Longint ): Boolean;
VAR res:Boolean;
BEGIN
ASSEMBLER
        MOVEM.L D3-D7,-(A7)
        CLR     D0
        MOVE.L  p(A6),A0
        MOVE.L  A0,D3
        MOVE.L  (A0),D5
        BEQ     ende            ; 'p' ist NIL
        MOVE.L  MPBPtr,D6
        MOVE.L  len(A6),D4

        TST.B   oldStorage
        BEQ     newsto

        ; VerÑndern der Grîûe
        MOVEQ   #1,D7
        MOVE.L  D3,D5
        MOVE.L  #Resize1,-(A7)
        JSR     CallSuper
        ADDQ.L  #4,A7
        BRA     ende

newsto  ; VerÑndern der Grîûe
        PEA     Resize2
        JSR     CallSuper
        ADDQ.L  #4,A7

ende    MOVEM.L (A7)+,D3-D7
        MOVE    D0,res(A6)
END;
RETURN res
END Resize0;

(*$L-*)
PROCEDURE freeAll;
BEGIN
ASSEMBLER
        MOVE.L  (A3),D2
        MOVE.L  MPBPtr,A2
        ADDQ.L  #MPB.used,A2    ; LEA MPB.used(A2),A2
        BRA     cont0
srch0   MOVE.L  MD.owner(A2),D1
        ANDI.L  #$00FFFFFF,D1   ; oberes Byte ausblenden wg. Ungerade-Kennung
        CMP.L   D1,D2
        BNE     cont0
        CLR.B   MD.owner(A2)
cont0   MOVE.L  (A2),A2         ; MD.next
        MOVE.L  A2,D1
        BNE     srch0
END;
END freeAll;


(*$L-*)
PROCEDURE DeAllocAll ( owner: LONGWORD );
BEGIN
ASSEMBLER
        SUBQ.L  #4,A3
        MOVE.L  MPBPtr,D0
        BEQ     ende            ; Wenn kein MPBPtr, ist dies unnîtig
        MOVE.L  #freeAll,-(A7)
        JSR     CallSuper
        ADDQ.L  #4,A7
ende
END
END DeAllocAll;


(*$L-*)
PROCEDURE allocU1; (* D6:MPBPtr, D5:amount, D4:owner *)
BEGIN
ASSEMBLER
        ; A1: zeigt auf aktuellen Free-MD
        ; A2: zeigt auf VorgÑnger
        
        MOVE.L  D4,-(A7)
        
        ; Neuen MDSt anlegen ?
        MOVEM.L D3/D5,-(A7)
        JSR     testMDSt
        MOVEM.L (A7)+,D3/D5
        
        MOVE.L  D6,A0
        MOVE.L  MPB.boomer(A0),A2
        MOVE.L  A2,D0
        BEQ.L   ende                    ; keine Freiliste !?
        
        MOVE.L  (A2),A1                 ; ^ Root Freiliste
        CLR.L   D4                      ; hîchste Adr.
        
srch1   MOVE.L  A1,D0                   ; Ende der Freiliste ?
        BNE     srch2
        MOVE.L  D6,A2                   ; Ja
        MOVE.L  (A2),A1                 ; MPB.free
        
srch2   MOVE.L  MD.length(A1),D0
        CMP.L   D5,D0
        BEQ     isEqu
        BHI     isHi            ; Der Bereich ist grîûer
        BRA.L   notFnd          ; Der Freibereich ist zu klein

extrem  ; mîglichst hohe Adr. suchen
        CMP.L   MD.start(A1),D4
        BCC.L   notFnd
        MOVE.L  MD.start(A1),D4
        MOVE.L  A1,A3
        MOVE.L  A3,A4
        BRA.W   notFnd

isEqu   ; Der freie Bereich paût genau.
        TST     D7
        BEQ     extrem
isEqu0  MOVE.L  (A1),(A2)       ; MD aus Free-Liste auslinken
        MOVE.L  (A7),MD.owner(A1)
        BRA     found
        
isHi    TST     D7
        BEQ     extrem
        ; Eintrag des neuen Used-MD, A0: ^ auf neuen Used-MD
isHi0   MOVE.L  (A7),D4
        MOVEM.L D5/A1/A2,-(A7)
        JSR     getMD           ; Legt MD an, liefert Adr. in D0
        MOVEM.L (A7)+,D5/A1/A2
        TST.L   D0
        BEQ.L   ende
        MOVE.L  D0,A0
        
        TST     D7                      ; oberen Bereich abknapsen ?
        BNE     takeLow
        
        MOVE.L  MD.start(A1),D0         ; Used-start auf alten Freibereich
        ADD.L   MD.length(A1),D0        ; Used-start auf Ende des Bereichs
        SUB.L   D5,D0                   ; Minus BereichslÑnge
        MOVE.L  D0,MD.start(A0)         ; Als Used-Start
        SUB.L   D5,MD.length(A1)        ; Frei-LÑnge um belegten Bereich verkl.
        BNE     qw1
        BREAK
      qw1:
        MOVE.L  D5,MD.length(A0)        ; Used-Length setzen.
        BNE     qw2
        BREAK
      qw2:
        MOVE.L  A0,A1                   ; A1:=Adr (Used-MD)
        BRA     found
        
takeLow MOVE.L  MD.start(A1),MD.start(A0) ; Used-start auf alten Freibereich
        ADD.L   D5,MD.start(A1)         ; Frei-Beginn um bel. Bereich erhîhen
        SUB.L   D5,MD.length(A1)        ; Frei-LÑnge um belegten Bereich verkl.
        BNE     qw3
        BREAK
      qw3:
        MOVE.L  D5,MD.length(A0)        ; Used-Length setzen.
        BNE     qw4
        BREAK
      qw4:
        MOVE.L  D0,A1                   ; A1:=Adr (Used-MD)
        
found   MOVE.L  D6,A0
        MOVE.L  MPB.used(A0),(A1)       ; MD in Used-Liste einlinken
        MOVE.L  A1,MPB.used(A0)         ; Neuen Used-MD als Used-Listenbeginn
        
        ; Den boomer-^ korrigieren
        MOVE.L  D6,A0
        MOVE.L  A2,MPB.boomer(A0)
        
        MOVE.B  D3,MD.owner(A1)
        
        MOVE.L  A1,D0           ; Ergebnis
        BRA     ende            ; jetzt ham wir's
        
notFnd  MOVE.L  A1,A2
        MOVE.L  (A1),A1                 ; MD.next
        
        MOVE.L  D6,A0
        MOVE.L  MPB.boomer(A0),D0
        CMP.L   D0,D6
        BEQ     notFC2                  ; boomer zeigt auf eigenen MD / MPB
        
        CMP.L   A2,D0
        BNE     srch1
        BRA     srchEnd
        
notFC2  MOVE.L  A1,D0                   ; Ende der Freiliste ?
        BNE     rovnen2
        MOVE.L  D6,A2                   ; Ja
        MOVE.L  (A2),A1                 ; MPB.free
rovnen2 MOVE.L  D6,A0
        CMPA.L  MPB.boomer(A0),A2
        BNE     srch2
        
srchEnd TST     D7
        BNE     ende0
        TST.L   D4
        BEQ     ende0           ; kein Platz gef.
        MOVE.L  A3,A1
        MOVE.L  A4,A2
        MOVE.L  MD.length(A1),D0
        CMP.L   D5,D0
        BEQ     isEqu0
        BHI     isHi0           ; Der Bereich ist grîûer
        
ende0   CLR.L   D0              ; keinen Platz gefunden
ende    ADDQ.L  #4,A7
END
END allocU1;


(*$L-*)
PROCEDURE allocU2; (* D6:MPBPtr, D5: start, D4:owner *)
BEGIN
ASSEMBLER
END
END allocU2;

(*$L-*)
PROCEDURE Malloc ( amount: Longcard; prID: LONGWORD ): Address;
BEGIN
ASSEMBLER
        MOVEM.L D3-D7,-(A7)
        
        MOVE.L  -(A3),D4
        MOVE.L  -(A3),D5
        BLE     endeClr
        ADDQ.L  #1,D5
        BCLR    #0,D5           ; Sync; keine ungeraden Adr.
        SEQ     D3              ; D3 wird $FF, wenn amount ungerade war.
        AND     #$80,D3
        MOVE.L  MPBPtr,D6

        TST.B   oldStorage
        BEQ     newsto

        MOVEQ   #1,D7
        MOVE.L  #allocU1,-(A7)
        JSR     CallSuper
        ADDQ.L  #4,A7
        
        TST.L   D0              ; Adr. des alloz. Bereichs
        BEQ     ende
        MOVE.L  D0,A1
        MOVE.L  MD.start(A1),D0
        BRA     ende
endeClr CLR.L   D0
ende    MOVE.L  D0,(A3)+
        BRA     ende0

newsto  ; Malloc ohne LongStack-Zugriffe
        ; Dazu erst den Speicher Åber GEMDOS anfordern und dann
        ; den Owner und evtl. Markierung f. ungeraden Amount setzen
        MOVE.L  D5,-(A7)
        MOVE    #m_alloc,-(A7)
        TRAP    #1              ; Malloc (D5)
        ADDQ.L  #6,A7
        MOVE.L  D0,(A3)+
        BEQ     ende0           ; Kein Speicher mehr -> Ende

        TST.L   D6
        BEQ     ende0           ; Nicht Owner/Odd setzen, wenn MPBPtr fehlt

        MOVE.L  D0,D5
        PEA     findMD
        JSR     CallSuper
        ADDQ.L  #4,A7
        TST.L   D0
        BEQ     ende0
        MOVE.L  D4,MD.owner(A0)
        MOVE.B  D3,MD.owner(A0)

ende0:  MOVEM.L (A7)+,D3-D7
END;
END Malloc;


(*$L-*)
PROCEDURE ALLOCATE ( VAR addr: ADDRESS; len: LONGCARD );
  BEGIN
    ASSEMBLER
        MOVE.L  ProcessID,A0
        MOVE.L  (A0),(A3)+
        JSR     Malloc
        MOVE.L  -(A3),D0
        MOVEA.L -(A3),A0
        MOVE.L  D0,(A0)
    END
  END ALLOCATE;

(*$L-*)
PROCEDURE SysAlloc ( VAR addr: ADDRESS; len: LONGCARD );
  BEGIN
    ASSEMBLER
        CLR.L   (A3)+
        JSR     Malloc
        MOVE.L  -(A3),D0
        MOVEA.L -(A3),A0
        MOVE.L  D0,(A0)
    END
  END SysAlloc;


(*$L-*)
PROCEDURE DEALLOCATE ( VAR addr: ADDRESS; len: LONGCARD );
  BEGIN
    ASSEMBLER
        TST.L   MPBPtr
        BNE     ok
        CLR.L   -4(A3)          ; alles freigeben
     ok JSR     Resize0
        SUBQ.L  #2,A3
    END
  END DEALLOCATE;


(*$L-*)
PROCEDURE Enlarge ( VAR addr: ADDRESS; len: LONGCARD; VAR ok: BOOLEAN );
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        NEG.L   -4(A3)
        BPL     err
        TST.L   MPBPtr
        BEQ     err
        JSR     Resize0
        MOVE.L  (A7)+,A0
        MOVE.W  -(A3),(A0)
        RTS
      err
        SUBQ.L  #8,A3
        MOVE.L  (A7)+,A0
        CLR.W   (A0)
    END
  END Enlarge;


(*$L-*)
PROCEDURE trailAv1; (* D6: MPBPtr, D5: start *)
BEGIN
ASSEMBLER
        ; used-MD finden
        JSR     findMD
        BEQ.S   endeClr

        ; anschlieûenden Free-MD ermitteln
        MOVE.L  MD.start(A0),D2
        ADD.L   MD.length(A0),D2        ; hier muû ein Freibereich stehen
        MOVE.L  D6,A2
        MOVE.L  MPB.free(A2),A2
        BRA.S   cont2
srch2   CMP.L   MD.start(A2),D2 ; start aus Free-List
        BEQ.S   fnd2            ; gefunden
        MOVE.L  (A2),A2         ; MD.next
cont2   MOVE.L  A2,D0
        BNE     srch2
        BRA.S   endeClr         ; dahinter nix mehr frei
fnd2    MOVE.L  MD.length(A2),D0 ; free-LÑnge
        BRA.S   ende

endeClr MOVEQ   #0,D0
ende
END
END  trailAv1;

(*$L-*)
PROCEDURE TrailAvail (ad: ADDRESS): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVEM.L D5/D6,-(A7)
        MOVE.L  -(A3),D5
        MOVEQ   #0,D0
        MOVE.L  MPBPtr,D6
        BEQ.S   null
        PEA     trailAv1
        JSR     CallSuper
        ADDQ.L  #4,A7
      null
        MOVE.L  D0,(A3)+
        MOVEM.L (A7)+,D5/D6
    END
  END TrailAvail;


(*$L-*)
PROCEDURE MemSize ( addr: ADDRESS ): LONGCARD;
  BEGIN
    ASSEMBLER
        TST.L   MPBPtr
        BEQ.s   err

        MOVE.L  D5,-(A7)
        MOVE.L  -(A3),D5
        PEA     l(PC)
        JSR     CallSuper
        ADDQ.L  #4,A7
        MOVE.L  (A7)+,D5
        MOVE.L  D0,(A3)+
        RTS

err     SUBQ.L  #4,A3
        LINK    A5,#0
        JSR     IllCall
        UNLK    A5
        CLR.L   (A3)+
        RTS

      l MOVE    SR,-(A7)
        ORI     #$700,SR
        MOVE.L  D6,-(A7)
        MOVE.L  MPBPtr,D6
        JSR     findMD          ; zerstîrt D5
        BEQ.S   e
        MOVE.L  MD.length(A0),D0
        TST.B   MD.owner(A0)
        BPL.S   e
        SUBQ.L  #1,D0
      e MOVE.L  (A7)+,D6
        MOVE    (A7)+,SR
    END
  END MemSize;

(*$L-*)
PROCEDURE avail;
  BEGIN
    ASSEMBLER
        TST.L   MPBPtr
        BEQ     norm
        PEA     l(PC)
        JSR     CallSuper
        ADDQ.L  #4,A7
        RTS

norm    ; IN: D2: 1 -> AllAvail bestimmen
        TST.W   D2
        BNE     all
        
        MOVEQ   #-1,D0
        MOVE.L  D0,-(A7)
        MOVE    #$48,-(A7)      ; malloc (-1L)
        TRAP    #1
        ADDQ.L  #6,A7
        RTS
        
all     MOVE.L  D3,-(A7)
        MOVEQ   #0,D3           ; zÑhlt Gesamtmenge
        CLR.L   -(A7)           ; Endmarke fÅr gestackte Alloc-Adressen
luup    MOVEQ   #-1,D0
        MOVE.L  D0,-(A7)
        MOVE    #$48,-(A7)      ; malloc (-1L)
        TRAP    #1
        ADDQ.L  #6,A7
        ADD.L   D0,D3
        CMPI.L  #1024,D0        ; Bereiche < 1024 nicht berÅcksichtigen
        BCS     ende
        MOVE.L  D0,-(A7)
        MOVE    #$48,-(A7)      ; malloc ()
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  D0,-(A7)        ; Adr des Bereichs merken
        MOVE.L  A3,A0
        ADDA.W  #512,A0
        CMPA.L  A7,A0           ; Aufhîren bei drohendem StackÅberlauf
        BCS     luup
ende    TST.L   (A7)
        BEQ     ende2
        MOVE    #m_free,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        BRA     ende
ende2   ADDQ.L  #4,A7
        MOVE.L  D3,D0
        MOVE.L  (A7)+,D3
        RTS

        (*
        MOVEQ   #-1,D0
        MOVE.L  D0,-(A7)
        MOVE    #$48,-(A7)      ; malloc (-1L)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  D0,D1
        TST     gemdos1900
        BEQ     noMX
        MOVE.L  D0,-(A7)
        MOVE.W  #1,-(A7)
        MOVE.L  #-1,-(A7)
        MOVE    #$44,-(A7)      ; mxalloc (-1L, 1)
        TRAP    #1
        ADDQ.L  #8,A7
        MOVE.L  D0,D1
        MOVE.L  (A7)+,D0
        ADD.L   D1,D0
        RTS
        *)

      l ; MOVE    SR,-(A7)
        ; ORI     #$700,SR
        CLR.L   D0
        CLR.L   D1
        MOVE.L  MPBPtr,A0
        MOVE.L  (A0),A0
      s ADD.L   MD.length(A0),D1
        CMP.L   MD.length(A0),D0
        BCC     c
        MOVE.L  MD.length(A0),D0
      c MOVE.L  (A0),A0
        MOVE.L  A0,D2
        BNE     s
        TST.W   D2
        BEQ     single
        MOVE.L  D1,D0
      single
        ; MOVE    (A7)+,SR
    END
  END avail;

(*$L-*)
PROCEDURE MemAvail (): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVEQ   #0,D2
        JSR     avail
        MOVE.L  D0,(A3)+
    END
  END MemAvail;

(*$L-*)
PROCEDURE AllAvail (): LONGCARD;
  BEGIN
    ASSEMBLER
        MOVEQ   #1,D2
        JSR     avail
        MOVE.L  D0,(A3)+
    END
  END AllAvail;

(*$L-*)
PROCEDURE Available (l:LONGCARD):BOOLEAN;
  BEGIN
    ASSEMBLER
        MOVEQ   #0,D2
        JSR     avail
        CMP.L   -(A3),D0
        SCC     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END Available;

(*$L-*)
PROCEDURE Keep ( addr: ADDRESS );
  BEGIN
    ASSEMBLER
        TST.L   MPBPtr
        BEQ.S   err
        MOVE.L  D3,-(A7)
        MOVE.L  -(A3),D3
        PEA     l(PC)
        JSR     CallSuper
        ADDQ.L  #4,A7
        MOVE.L  (A7)+,D3
        RTS

err     SUBQ.L  #4,A3
        LINK    A5,#0
        JSR     IllCall
        UNLK    A5
        RTS

     l: MOVE    SR,-(A7)
        ORI     #$700,SR
        MOVE.L  MPBPtr,A0
        ADDQ.L  #MPB.used,A0    ; LEA MPB.used(A0),A0
        BRA     cont0
srch0   CMP.L   MD.start(A0),D3
        BEQ     found
cont0   MOVE.L  (A0),A0         ; MD.next
        MOVE.L  A0,D0
        BNE     srch0
        BRA     ende
found   MOVE.B  MD.owner(A0),D0
        CLR.L   MD.owner(A0)    ; Prozeû-ID lîschen
        MOVE.B  D0,MD.owner(A0)
ende    MOVE    (A7)+,SR
    END
  END Keep;


(*$L-*)
PROCEDURE KeepAll (processID:LONGWORD);
  BEGIN
    ASSEMBLER
        TST.L   MPBPtr
        BEQ.S   err
        MOVE.L  D3,-(A7)
        MOVE.L  -(A3),D3
        PEA     l(PC)
        JSR     CallSuper
        ADDQ.L  #4,A7
        MOVE.L  (A7)+,D3
        RTS

err     SUBQ.L  #4,A3
        LINK    A5,#0
        JSR     IllCall
        UNLK    A5
        RTS

     l: ; alle MD mit owner=D3 resident machen
        MOVE    SR,-(A7)
        ORI     #$700,SR
        MOVE.L  MPBPtr,A0
        ADDQ.L  #MPB.used,A0    ; LEA MPB.used(A0),A0
        BRA     cont0
srch0   MOVE.L  MD.owner(A0),D0
        ANDI.L  #$00FFFFFF,D0   ; oberes Byte ausblenden
        CMP.L   D0,D3
        BNE     cont0
        MOVE.B  MD.owner(A0),D0
        CLR.L   MD.owner(A0)    ; Prozeû-ID lîschen
        MOVE.B  D0,MD.owner(A0)
cont0   MOVE.L  (A0),A0         ; MD.next
        MOVE.L  A0,D0
        BNE     srch0
        MOVE    (A7)+,SR
    END
  END KeepAll;


(*$L-*)
PROCEDURE FullStorBaseAccess (): BOOLEAN;
  BEGIN
    ASSEMBLER
        TST.L   MPBPtr
        SNE     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END FullStorBaseAccess;


(*$L+*)
PROCEDURE Inconsistent (): BOOLEAN;
  BEGIN
    (*!!! noch ausprogrammieren *)
    RETURN FALSE
  END Inconsistent;


(*$L-*)
PROCEDURE Resize ( VAR addr: ADDRESS; newSize: LONGCARD; VAR ok: BOOLEAN);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        TST.L   -4(A3)
        BEQ     all
        TST.L   MPBPtr
        BEQ     noFull
        MOVE.L  -8(A3),A0
        MOVE.L  (A0),(A3)+
        JSR     MemSize
        MOVE.L  -(A3),D0
        SUB.L   -(A3),D0
        MOVE.L  D0,(A3)+
      all
        JSR     Resize0
        MOVE.L  (A7)+,A0
        MOVE.W  -(A3),(A0)
        RTS
      noFull
        MOVE.L  -(A3),-(A7)     ; neue LÑnge
        MOVE.L  -(A3),A0
        MOVE.L  (A0),-(A7)      ; start
        CLR     -(A7)
        MOVE    #m_shrink,-(A7)
        TRAP    #1              ; Mshrink ()
        ADDA.W  #12,A7
        MOVE.L  (A7)+,A0
        TST.L   D0
        SEQ     D0
        ANDI    #1,D0
        MOVE    D0,(A0)
    END
  END Resize;


(*$L-*)
PROCEDURE More (id:INTEGER;p:ADDRESS);
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A0
        MOVE.W  -(A3),D0
        CMPI.W  #$4EF1,D0
        BNE     trail
        MOVE.L  (A0)+,(A3)+
        MOVE.L  (A0)+,(A3)+
        MOVE.L  (A0)+,(A3)+
        ; Enlarge ( VAR addr: ADDRESS; len: LONGCARD; VAR ok: BOOLEAN );
        JMP     Enlarge
      trail
        CMPI.W  #$4EF2,D0
        BNE     ende
        MOVE.L  (A0)+,(A3)+
        MOVE.L  A0,-(A7)
        ; TrailAvail (ad: ADDRESS): LONGCARD;
        JSR     TrailAvail
        MOVE.L  (A7)+,A0
        MOVE.L  -(A3),(A0)
      ende
        TRAP    #6
        DC.W    IllegalCall
    END
  END More;


(*$L-*)
PROCEDURE terminate;
  BEGIN
    ASSEMBLER
        MOVE.L  ProcessID,A0
        MOVE.L  (A0),(A3)+
        JMP     DeAllocAll
    END
  END terminate;

(*$L-*)
PROCEDURE chgLevel ( doInc: BOOLEAN; child: BOOLEAN; VAR c: INTEGER );
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A3
        MOVE.L  -(A3),D0
        TST     D0
        BEQ     ende
        SWAP    D0
        TST     D0
        BNE     ende
        JMP     terminate
      ende
    END
  END chgLevel;


VAR ehdl: EnvlpCarrier;
    thdl: TermCarrier;
    wsp: MemArea;
    stack: ARRAY [1..200] OF WORD;
    v: CARDINAL; r: CARDINAL; d: Date;
    isTT: BOOLEAN;
    MiNTorMagXavail: BOOLEAN;

BEGIN (* main *)
  ASSEMBLER
        SF      oldStorage
        (* diese Methode ist nicht so gut, um mxalloc()-Vorhandensein zu
           prÅfen. Besser: mxalloc aufrufen und prÅfen, ob neg. Returncode
           ("ill.opcode") geliefert wird.
        MOVE    #$30,-(A7)      ; Sversion
        TRAP    #1
        ADDQ.L  #2,A7
        CMPI.W  #$1900,D0
        SCC     D0
        ANDI    #1,D0
        MOVE.W  D0,gemdos1900
        *)
        
        ; Ist MiNT installiert?
        MOVE.L  #$4D694E54,(A3)+
        SUBQ.L  #4,A7
        MOVE.L  A7,(A3)+
        JSR     GetCookie
        ADDQ.L  #4,A7           ; value ist uninteressant
        MOVE.W  -(A3),MiNTorMagXavail
        BNE     weiter
        ; Ist Mag!X installiert?
        MOVE.L  #$4D616758,(A3)+
        SUBQ.L  #4,A7
        MOVE.L  A7,(A3)+
        JSR     GetCookie
        ADDQ.L  #4,A7           ; value ist uninteressant
        MOVE.W  -(A3),MiNTorMagXavail
      weiter:

        PEA     g(PC)
        JSR     CallSuper
        ADDQ.L  #4,A7
        BRA     cont
      g MOVE.L  $4F2,A0           ; sysbase
        CMPI.B  #3,2(A0)
        SCC     D0              ; isTT:= TOS-Version >= 3
        ANDI    #1,D0
        MOVE    D0,isTT
        RTS
      cont:
  END;
  IF ExtendedMemoryAccess AND NOT isTT AND ~MiNTorMagXavail THEN
    GetMPBPtr;
  END;
  IF MPBPtr # NIL THEN
    ASSEMBLER
        ; Longstack bei TOS 1.0 / 1.2 ermitteln
        BRA     c
     t: MOVE.L  $4F2,A0         ; ^TOS-Header
        MOVE.L  8(A0),D0        ; wg. altem AHDI
        RTS
     c: PEA     t(PC)
        MOVE    #38,-(A7)
        TRAP    #14             ; Supexec
        ADDQ.L  #6,A7
        MOVE.L  D0,A0
        MOVE.W  2(A0),D1
        CMPI    #$0100,D1
        BNE     a
        MOVE.L  #$56FE,MDRoot
        MOVE.L  #$5FDE,LStackFree
        MOVE.L  #$414E,LStackPtr
        MOVE.L  #$29DC,LongStack
        BRA     o
     a: MOVE.L  $20(A0),D0
        ADDQ.L  #4,D0
        MOVE.L  D0,MDRoot
        CMPI    #$0102,D1
        BNE     e
        MOVE.L  #$8780,LStackFree
        MOVE.L  #$68F0,LStackPtr
        MOVE.L  #$2A6E,LongStack
     o: ST      oldStorage
     e: MOVE.L  #stack,wsp
    END
  END;
  wsp.length:= SIZE (stack);
  CatchProcessTerm (thdl,terminate,wsp);
  SetEnvelope (ehdl,chgLevel,wsp)
END StorBase.

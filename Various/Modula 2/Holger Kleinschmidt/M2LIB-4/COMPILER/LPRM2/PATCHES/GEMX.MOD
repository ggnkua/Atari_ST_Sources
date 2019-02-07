IMPLEMENTATION MODULE GEMX;

(* Rekompiliertes LPR-Originalmodul mit Ergaenzungen fuer Modulterminierung,
 * Meldung von Laufzeitfehlern und Programmierung von ACCs.
 *
 * Dieses Modul und die Modulterminierung in LPRTERMINATION werden nur bei
 * gelinkten Programmen ausgefuehrt, nicht jedoch bei Programmen, die unter
 * Kontrolle des Laders laufen!
 *
 * Die Programmierung von ACCs ist nur moeglich, wenn nach dem Linken
 * der RECORD vom Typ ExtInfo direkt hinter dem Programmheader
 * und die BSS-Laenge entsprechend gepatched werden, da der Stackpointer
 * gesetzt werden muss, bevor ein Initialisierungsteil eines Moduls
 * ausgefuehrt wird (bei einem ACC ist SP NICHT initialisiert!), und
 * beim Laden von ACCs automatisch aller Speicher freigegeben wird, so dass
 * Heap und Stack in der BSS beruecksichtigt werden muessen!
 * Es kann entweder der Linker direkt mit FIXLINK.TOS gepatched werden,
 * so dass keine weiteren Aenderungen an den Programmdateien notwendig
 * sind, oder mit FIXPRG.TOS die einzelne Programmdatei. Letzteres kann
 * auch erforderlich sein, wenn andere Werte fuer Stack- und Heapgroesse
 * benoetigt werden.
 *
 * Dateioffset:  Code:      Befehl:
 * $A                       DC.L <BssLen> := <heapSize> + <stackSize>
 *
 * $1C           600C       bra.s  tstacc
 * $1E           yyyy       DS.W 1               ; frei fuer weitere Patches
 * $20           xxxx xxxx  DC.L <stackSize>
 * $24           xxxx xxxx  DC.L <heapSize>
 * $28           yyyy       DS.W 1               ; frei fuer weitere Patches
 * $2A   tstacc: 2008       move.l A0,D0         ; ACC ?
 * $2C           670A       beq.s  init          ; B: nein, wie gehabt
 * $2E           4FE8 00FC  lea    256-4(A0),SP  ; vorl. Stack in Kommandozeile
 * $32           6004       bra.s  init
 * $34           xxxx xxxx  DC.L <modBase>
 * $38     init: ....
 *
 *
 * 27-Nov-93, Holger Kleinschmidt
 * 14-Feb-94, hk, boesen Fehler beseitigt: Heap griff auf fremden Speicher
 *            zu, da 'BssLen' nur im ACC-Fall auf Null gesetzt wurde...
 * 07-Jun-94, hk, Eigene HALT-Routine, die einige Laufzeitfehler beim
 *            Namen nennt, bevor das Programm (nach evtl. Terminierung)
 *            beendet wird. Unter MiNT wird der 'Salert'-Aufruf verwendet,
 *            so dass bei MultiTOS das ALERT.ACC die Ausgabe der
 *            Meldungen uebernehmen kann. Bei ACCs wird nur die Meldung
 *            ausgegeben, das Programm jedoch nicht terminiert.
 * 05-Okt-95, hk, BssLen wird hier nicht mehr geaendert, da MiNT den Wert
 *            evtl. noch benoetigt. Dafuer musste aber 'Heap' entsprechend
 *            angepasst werden.
 *            Mehr Sicherheitsbereich zwischen Stackende und dem Ende des
 *            reservierten Speichers.
 * 27-Aug-96, hk, Zeilenvorschub vor Laufzeitfehlermeldung.
 *)

FROM System IMPORT
(* VAR  *) HALTX0;

FROM SYSTEM IMPORT
(* TYPE *) ADDRESS,
(* PROC *) ADR, VAL, REG, SETREG, INLINE;

FROM LPRTERMINATION IMPORT
(* VAR  *) BasePageP,
(* PROC *) FINALIZE, IsAPP;

(*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*)

CONST
  MINFREE = 16384D; (* mindestens 16kB an TOS zurueckgeben *)

  ENSMEM = -39;

  PTERM   = 76D;
  MSHRINK = 74D;
  CCONWS  = 9D;
  SALERT  = 316D;

  d0 = 0;
  sp = 15;

  CR = 15C;
  LF = 12C;

PROCEDURE Pterm (p1,f:INTEGER); CODE(4E41H);
PROCEDURE Mshrink (p3:LONGINT;p2:ADDRESS;p1,f:CARDINAL); CODE(4E41H);
PROCEDURE Cconws (p:ADDRESS;f:CARDINAL); CODE(4E41H);
PROCEDURE Salert (p:ADDRESS;f:CARDINAL); CODE(4E41H);

VAR
  main : PROC;
  (* Der Inhalt von 'main' wird vom Linker eingesetzt, der hierbei mit
   * einem festen Offset arbeitet. Deswegen darf keine weitere Variable
   * im Definitionsmodul deklariert werden, und 'main' muss hier an erster
   * Stelle stehen, damit sich die Adresse der Variable nicht aendert.
   *)
  pEnd : LONGINT;
  pLen : LONGINT;
  Info : ExtInfoPtr;
  ret  : INTEGER;
  acc  : BOOLEAN;
  line : ARRAY [0..50] OF CHAR;
  nl   : ARRAY [0..2] OF CHAR;

(*===========================================================================*)

PROCEDURE RuntimeError;
(* Hier auf keinen Fall HALTX verwenden, sonst Endlosrekursion, da HALTX
 * (das auch bei einem HALT verwendet wird), die in HALTX0 gespeicherte
 * Prozedur ausfuehrt, und das ist ja wiederum RuntimeError
 *)
VAR err  : INTEGER;
    serr : ARRAY [0..50] OF CHAR;

BEGIN
 err := REG(0);
 CASE err OF
   0 : serr := "LPR-Laufzeitfehler: HALT-Befehl";
  |1 : serr := "LPR-Laufzeitfehler: UngÅltiger CASE-Index";
  |2 : serr := "LPR-Laufzeitfehler: Funktionsprozedur ohne RETURN";
  |3 : serr := "LPR-Laufzeitfehler: Arith. öberlauf IEEE-Format";
  |4 : serr := "LPR-Laufzeitfehler: Nicht implem. Systemfunktion";
  |5 : serr := "LPR-Laufzeitfehler: Process";
 ELSE  serr := "LPR-Laufzeitfehler: Unbekannter Laufzeitfehler";
 END;

 Salert(ADR(serr), SALERT);
 err := REG(0);
 IF err < 0 THEN
   (* 'Salert'-Aufruf wird nicht unterstuetzt, deshalb die Standardausgabe
    * (TOS-Bildschirm) verwenden.
    * Es ist keine explizite Stackkorrektur noetig, da entweder das Programm
    * beendet wird oder bei einem ACC das UNLK am Ende von 'RuntimeError'
    * die Stackkorrektur uebernimmt.
    *)
   Cconws(ADR(nl), CCONWS);
   Cconws(ADR(line), CCONWS);
   Cconws(ADR(nl), CCONWS);
   Cconws(ADR(serr), CCONWS);
   Cconws(ADR(nl), CCONWS);
   Cconws(ADR(line), CCONWS);
   Cconws(ADR(nl), CCONWS);
 END;

 (* Bei einem ACC keine Terminierung, nur die Meldung *)
 IF NOT acc THEN
   FINALIZE(ret);
   Pterm(ret, PTERM);
 END;
END RuntimeError;

(*===========================================================================*)

BEGIN (* GEMX *)
 line   := "*************************************************";
 nl[0]  := CR;
 nl[1]  := LF;
 nl[2]  := 0C;
 HALTX0 := RuntimeError; (* Neue HALT-Routine installieren *)

 acc := NOT IsAPP();
 IF acc THEN
   (* Die Basepage wird in 'LPRTERMINATION' ermittelt und hier gesetzt *)
   BasePagePtr := VAL(ADDRESS,BasePageP);
 ELSE
   (* Die Basepage wird hier ermittelt und in 'LPRTERMINATION' gesetzt *)
   INLINE(202FH, 12); (* move.l 12(SP),D0 *)
   BasePagePtr := VAL(ADDRESS,REG(d0));
   BasePageP   := VAL(ADDRESS,BasePagePtr);
 END;

 WITH BasePagePtr^ DO
   Info := VAL(ExtInfoPtr,CodeBase);
   pEnd := CodeBase + CodeLen + DataLen;
   (* BssLen ist Null, wenn weder FIXLINK noch FIXPRG benutzt wurde,
    * ansonsten gilt: BssLen == |heapSize| + |stackSize|.
    * Variablen werden nicht in der BSS, sondern im DATA-Segment abgelegt.
    *)
 END;
 WITH Info^ DO
   stackSize := ABS(stackSize);
   heapSize  := ABS(heapSize);
   INC(pEnd, heapSize + stackSize);
 END;
 IF ODD(pEnd) THEN
   INC(pEnd);
 END;

 IF acc THEN
   SETREG(sp, pEnd - 32D); (* Stack fast an's Ende der BSS setzen *)
   main; (* ACC ausfuehren; Aufruf kehrt nicht zurueck! *)
 END;

 IF pEnd < BasePagePtr^.HighTPA - MINFREE THEN
   (* Programm nur ausfuehren, wenn genuegend Platz *)
   pLen := pEnd - BasePagePtr^.LowTPA;
   SETREG(sp, pEnd - 32D); (* Stack fast an's Ende der BSS *)

   Mshrink(pLen, BasePagePtr, 0, MSHRINK);
   INLINE(4FEFH, 12); (* Stackkorrektur: lea 12(SP),SP *)

   BasePagePtr^.HighTPA := pEnd;

   main; (* Programm ausfuehren *)

   FINALIZE(ret); (* Terminierungsroutinen ausfuehren *)
   Pterm(ret, PTERM);
 ELSE
   Pterm(ENSMEM, PTERM); (* Fehler: zu wenig Speicher *)
 END;
END GEMX.

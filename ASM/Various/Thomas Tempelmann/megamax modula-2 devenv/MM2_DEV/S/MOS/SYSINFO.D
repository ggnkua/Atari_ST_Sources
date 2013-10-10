DEFINITION MODULE SysInfo;

(*
 * Liefert Informationen Åber den Rechner und seine Hardware:
 *   CPU (Hauptprozessor)
 *   FPU (Mathe-Koprozessor)
 *   Rechner (Atari ST/STE/TT)
 *   TOS-Version
 *)

FROM MOSGlobals IMPORT Date;


PROCEDURE CPU (): LONGCARD;
  (*
   * Informiert Åber den Hauptprozessor (CPU) im Rechner:
   * Zur Zeit werden folgende Werte geliefert:
   *  68000  bei der CPU, die in den 520 ST, 1024 ST, Mega ST enthalten ist;
   *  68020  wenn z.B. die PAK-Karte vom Heise-Verlag eingebaut ist;
   *  68030  beim Atari TT (die 68030 enthÑlt eine 68020, sowie eine MMU).
   * Eine 68010 wird hier nicht erkannt (dann wird 68000 geliefert!)
   *
   * Die Erkennung erfolgt durch Testen der CPU-Befehle und nicht Åber einen
   * evtl. vorhandenen Cookie (s. Modul CookieJar).
   *)

PROCEDURE UseStackFrame (): BOOLEAN;
  (*
   * Liefert TRUE, wenn eine 68010, 68020 oder hîher, verwendet wird.
   * Das bedeutet dann, daû bei Exception-Routinen ein extra Stackframe-
   * Word auf dem Stack liegt.
   *
   * Diese Routine ist daher fÅr solche Anwendungen der 'CPU()'-Funktion
   * vorzuziehen, weil 'CPU' beispielsweise bei einer 68010 '68000'
   * liefert, jedoch trotzdem das StackFrame-Word benutzt wird!
   *
   * Die Erkennung erfolgt durch Testen der CPU-Befehle und nicht Åber einen
   * evtl. vorhandenen Cookie (s. Modul CookieJar).
   *)

PROCEDURE Has020 (): BOOLEAN;
  (*
   * Liefert TRUE, wenn 'CPU () >= 68020' ist.
   *
   * Diese Abfrage sollte verwendet werden, um zu ermitteln, ob der
   * erweiterte Befehlssatz der 68020 / 68030 verwendet werden kann,
   * ohne, daû auf die speziellen MMU-Befehle/Register der 68030
   * zugegriffen wird.
   *
   * Die Erkennung erfolgt durch Testen der CPU-Befehle und nicht Åber einen
   * evtl. vorhandenen Cookie (s. Modul CookieJar).
   *)

TYPE FPUType = (noFPU, externalFPU, internalFPU);

PROCEDURE FPU (): FPUType;
  (*
   * Informiert Åber einen evtl. vorhandenen Mathe-Koprozessor.
   * 'noFPU': Kein Koprozessor vorhanden.
   * 'externalFPU': Es ist ein 68881/882 vorhanden, der Åber die von Atari
   *   definierten Peripherie-Adressen angesprochen wird (z.B. der
   *   Koprozessor SFP004 von Atari fÅr die Mega-ST Computer oder diverse
   *   68881 zum Einbau in alle STs von Fremdherstellern)
   * 'internalFPU': Es ist ein 68881/882 vorhanden, der direkt Åber erweiterte
   *   Maschineninstruktionen der 68020/30 angesprochen wird (z.B. der 68881
   *   als Erweiterung zur PAK 68020).
   *
   * Die Erkennung erfolgt durch Testen der CPU-Befehle und nicht Åber einen
   * evtl. vorhandenen Cookie (s. Modul CookieJar).
   *)

PROCEDURE FPUModel (): CARDINAL;
  (*
   * Liefert 1 fÅr 68881, 2 fÅr 68882.
   *
   * Die Erkennung erfolgt durch Testen der CPU-Befehle und nicht Åber einen
   * evtl. vorhandenen Cookie (s. Modul CookieJar).
   *)

PROCEDURE GetTOSVersion (VAR version, revision: CARDINAL;
                         VAR date: Date);
  (*
   * Beim Blitter-TOS (TOS 1.2) werden z.B. folgende Werte geliefert:
   *   version:  1
   *   revision: 2
   *   date:     22.4.1987
   *)

PROCEDURE Machine (): CARDINAL;
  (*
   * Liefert den Rechnertyp. Werte:   ST: 0, STe: 1, TT: 2.
   *
   * Die Erkennung erfolgt Åber den Cookie "_MCH". Ist er nicht vorhanden,
   * wird Null geliefert.
   *)

END SysInfo.

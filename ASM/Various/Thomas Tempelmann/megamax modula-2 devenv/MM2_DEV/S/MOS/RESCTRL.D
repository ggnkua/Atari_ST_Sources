DEFINITION MODULE ResCtrl;

FROM SYSTEM IMPORT BYTE, WORD;

FROM MOSGlobals IMPORT MemArea;

(*
 * Dies Modul bietet Funktionen fÅr Systemmodule, die Ressourcen verwalten
 * und sich dazu Sys-Funktionen bedienen (und mit $Y+ Åbersetzt werden).
 *
 * ProblemerlÑuterung:
 *   Ein Systemmodul, das 'Sys'-Funktionen bietet oder globale bzw. externe
 * Variablen oder Ressourcen kontrolliert (z.B. Interrupts) sollte sich selbst
 * auch der Sys-Funktionen bedienen.
 *   Beispielsweise kann ein Modul im Modulkîrper Speicher mit SysAlloc
 * anfordern oder einen Systemvektor des TOS verÑndern. Wird das Modul
 * nicht mehr gebraucht und aus dem Speicher entfernt, muû natÅrlich der
 * Speicher zurÅckgegeben bzw. der Vektor restauriert werden. WÅrde man
 * das mit Hilfe der Funktion 'PrgCtrl.CatchProcessTerm' tun, wÅrde es
 * normalerweise funktionieren.
 *  Das Problem entsteht erst, wenn das Modul, das dieses Systemmodul im-
 * portiert, sich resident macht. Wenn der Prozeû dann endet, wird ja
 * der vom Systemmodul geforderte 'CatchProcessTerm' aktiv und das
 * Systemmodul wÅrde seine Ressourcen schlieûen. Das darf es dann aber
 * noch gar nicht, weil es ja noch resident bleibt und weiterhin von
 * anderen Modulen benîtigt wird.
 *   Aus diesem Grund gibt es hier die Funktion 'CatchRemoval', die,
 * entgegen 'CatchProcessTerm', das Modul erst dann informiert, wenn
 * es nicht mehr benîtigt, sprich importiert, wird.
 *
 *   Deshalb ist immer dann, wenn man daran denkt, 'CatchProcessTerm' zu
 * verwenden, zu prÅfen, ob nicht der oben beschriebene Fall eintreten
 * kann und dann stattdessen 'CatchRemoval' einzusetzen ist.
 *   Als Faustregel gilt:
 *    - 'CatchRemoval' fÅr Freigabe von Sys-Ressourcen bei Ressource-
 *      verwaltenden Modulen.
 *    - 'CatchProcessTerm' bei Hauptmodulen (denn hier hat das Modul
 *      ja selbst die Kontrolle darÅber, wann es sich resident macht
 *      und wieder freigibt) und Freigabe von Ressourcen des untersten
 *      Levels bei Ressource-verwaltenden Modulen (ergÑnzend zu den
 *      "Envelopes").
 *)

TYPE  RemovalCarrier = ARRAY [0..15] OF WORD;

PROCEDURE CatchRemoval ( VAR hdl: RemovalCarrier; info: PROC; wsp: MemArea );
  (*
   * Meldet eine Prozedur an, die aufgerufen wird, wenn das Modul,
   * das die Prozedur enthÑlt, nicht mehr benîtigt wird und aus dem
   * Speicher entfernt werden kann.
   *
   * 'wsp' ist der Stack, der 'info' beim Aufruf zugeteilt wird. 'wsp.bottom'
   * darf NIL sein, dann wird der normale Programm-Stack verwendet.
   *
   * Diese Funktion (und nicht etwa 'CatchProcessTerm') ist deshalb
   * das exakte GegenstÅck zum Aufruf des Modulkîrpers.
   *
   * Dies ist der Fall, wenn
   *  a) das Modul in einem Programm eingelinkt ist und das Programm
   *     normal beendet;
   *  b) das Modul durch einen Import vom Loader (also durch Load-Time
   *     Link) dazugeladen und gestartet wurde und nun wieder freigegeben
   *     werden kann, da der Prozeû wieder endet;
   *  c) das Modul von einem Modul importiert wird, das sich mit
   *     'ModCtrl.InstallModule' resident gemacht hatte und nach
   *     einem Aufruf von 'ReleaseModule', wie unter b), entfert wird.
   *
   * Wird ein Modul lediglich vom Loader (mittels 'LoadModule') geladen,
   * aber nicht aufgerufen, zÑhlt das entsprechende Ausladen des Moduls
   * nicht zu den obigen FÑllen. Vielmehr wird bei geladenen Modulen
   * so verfahren, als wenn das Modul jedesmal neu geladen und wieder
   * entladen wird.
   *
   * Somit ist diese Funktion dann zu verwenden, wenn ein Modul Ressourcen
   * dynamisch bei seiner Initialisierung îffnet, die genau dann wieder
   * geschlossen werden dÅrfen, wenn das Modul nicht mehr benîtigt wird.
   * Normalerweise kînnte man das dann mit 'PrgCtrl.CatchProcessTerm'
   * bewerkstelligen. Nur ist es dann nicht mîglich, das Modul in Pro-
   * grammen zu verwenden, die sich mit 'InstallModule' resident machen.
   *
   * Wird also z.B. in einem Modul im Kîrper Speicher angefordert, sollte
   * dieser mit der Sys-Funktion (SysAlloc) angefordert werden und Åber
   * 'CatchRemoval' der Speicher wieder freigegeben werden.
   *
   * WICHTIG: Das benutzende Modul muû mit der Directive "$Y+" Åbersetzt
   *          werden!
   *)

PROCEDURE Resident (): BOOLEAN;
  (*
   * Liefert TRUE, wenn der akt. Prozeû z.Zt. resident ist.
   * Es ist zu beachten, daû dieser Zustand nicht im Modulkîrper schon
   * ermittelt werden soll, da das Hauptmodul, das sich evtl. resident
   * macht, dies erst spÑter durchfÅhren kann.
   *)


PROCEDURE Private ( n: CARDINAL; VAR d: ARRAY OF BYTE );
  (*
   * interne Systemfunktion
   *)

END ResCtrl.

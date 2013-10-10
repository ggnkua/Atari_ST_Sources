DEFINITION MODULE StorBase;

FROM SYSTEM IMPORT ADDRESS, LONGWORD;

(*
 * Dieses Modul bietet die Storage-Funktionen, die direkt die GEMDOS-Routinen
 * und deren Verwaltung benutzen. Das Modul 'Storage' setzt hierauf auf.
 *
 * Bei Erfolg einer Alloc-Funktion liefert 'addr' immer einen Zeiger auf
 * eine gerade Adresse, bei Miûerfolg ist 'addr'=NIL.
 *
 * Es ist auch mîglich, ungerade Mengen Bytes anzufordern oder freizugeben.
 *
 * Um bei DEALLOCATE den gesamten Block freizugeben, sollte der Wert
 * Null als 'size'-Argument Åbergeben werden.
 *
 * Diese Speicherverwaltung greift in die des GEMDOS direkt ein, falls
 * dies nicht durch Setzen von 'MOSConfig.ExtendedMemoryAccess' auf FALSE
 * verhindert wird. Dazu sucht sich dieses Modul die betreffenden internen
 * GEMDOS-Strukturen im System-RAM. Kînnen diese nicht gefunden werden,
 * weil sich beispielsweise das interne Format geÑndert hat oder ist
 * 'ExtendedMemoryAccess' FALSE, dann funktionieren einige der Funktionen
 * dieses Moduls nur eingeschrÑnkt:
 *
 *   'ALLOCATE', 'MemAvail' und 'Available' funktionieren weiterhin wie
 *   gewohnt. Resize kann nur Bereiche verkleinern, liefert sonst FALSE
 *   in 'ok'. 'AllAvail' liefert das Ergebnis von MemAvail, 'TrailAvail'
 *   liefert immer Null. 'SysAlloc' funktioniert wie ALLOCATE - das bedeutet,
 *   daû residente Programme damit nicht funktionieren; ansonsten sind
 *   in der Regel keine EinschrÑnkungen dadurch zu erwarten.
 *   'DEALLOCATE' gibt immer den gesamten belegten Bereich frei, unabhÑngig
 *   von der angegebenen Grîûe. Die Åbrigen Funktionen lîsen bei Aufruf
 *   Laufzeitfehler aus: 'MemSize', 'Keep', 'KeepAll' und 'Enlarge'.
 *   Der Laufzeitfehler hat die Nummer -14 (MOSGlobals.IllegalCall).
 *
 * Ob die GEMDOS-Strukturen fÅr dieses Modul erreichbar sind, kann Åber
 * die Funktion 'FullStorBaseAccess' ermittelt werden.
 *
 * Wollen Sie Software erstellen, die unbedingt auf jedem Rechner mit jeder
 * TOS-Version auch in Zukunft laufen soll, verzichten Sie auf alle
 * Sys-Funktionen, wie 'SysAlloc', und verwenden Sie nicht 'InstallModule'
 * aus 'ModCtrl' sondern die GEMDOS-Funktion 'Ptermres', wenn Sie residente
 * Programme erstellen wollen. Modifizieren Sie auûerdem das Implementations-
 * Modul von 'MOSConfig' so, daû ExtendedMemoryAccess auf FALSE gesetzt wird,
 * um die Software von vornherein nicht in Versuchung kommen zu lassen, denn
 * damit simulieren sie praktisch ein zukÅnftiges TOS, bei dem kein Zugriff
 * mehr auf die GEMDOS-Strukturen besteht.
 *)

(*
 * ---------------------------------------------------------------------------
 * Folgende Funktionen dÅrfen jederzeit aufgerufen werden,
 * unabhÑngig von 'FullStorBaseAccess':
 * ---------------------------------------------------------------------------
 *)

PROCEDURE ALLOCATE ( VAR addr: ADDRESS; size: LONGCARD );
  (*
   * Wie GEMDOS-Funktion Malloc().
   * Liefert die Anfangsadresse in 'addr'. Liefert NIL, wenn kein
   * Speicher frei.
   *)

PROCEDURE DEALLOCATE ( VAR addr: ADDRESS; size: LONGCARD );
  (*
   * Wie GEMDOS-Funktion Mfree().
   * Verkleinert Speicherblock um 'size'.
   * Ist 'size'=0, wird der gesamte Speicherblock freigegeben.
   * 'addr' wird NIL, wenn gesamter Platz freigegeben oder nicht
   * belegt, sonst unverÑndert.
   *)

PROCEDURE Resize ( VAR addr: ADDRESS; newSize: LONGCARD; VAR ok: BOOLEAN );
  (*
   * Wie GEMDOS-Funktion Mshrink().
   * Bestimmt neue Grîûe eines bereits allozierten Bereichs.
   * 'addr' bleibt unverÑndert, es sei denn, 'newSize' ist Null.
   * Kleinere Grîûen sind jederzeit mîglich; Vergrîûerungen nur, wenn
   * die GEMDOS-Strukturen erreichbar sind (s.o.). Kann die neue Grîûe
   * nicht gesetzt werden, liefert 'ok' FALSE, sonst TRUE.
   *)

PROCEDURE Available ( size: LONGCARD ): BOOLEAN;
  (* Liefert TRUE, wenn die gefragte Menge Bytes noch frei ist. *)

PROCEDURE MemAvail (): LONGCARD;
  (*
   * Wie GEMDOS-Funktion Malloc(-1L).
   * Liefert Anzahl in Bytes des im Augenblick grîûten belegbaren
   * Speicherbereichs.
   *)

PROCEDURE Inconsistent (): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Speicherverwaltung inkonsistent (fehlerhaft)
   * geworden ist. In diesem Fall kann es bei weiteren StorBase-Zugriffen
   * zu fatalen Fehler kommen. Deshalb ist dann so bald wie mîglich
   * das System neu zu starten.
   *)

PROCEDURE FullStorBaseAccess (): BOOLEAN;
  (*
   * Liefert TRUE, wenn auch alle StorBase-Funktionen uneingeschrÑnkt
   * verwendet werden kînnen.
   *)

(*
 * ---------------------------------------------------------------------------
 * Folgende Funktionen dÅrfen zwar aufgerufen werden, wenn
 * 'FullStorBaseAccess' FALSE ist, jedoch werden ihre Funktionen
 * intern durch die Obigen ersetzt:
 * ---------------------------------------------------------------------------
 *)

PROCEDURE AllAvail (): LONGCARD;
  (*
   * Liefert gesamten im Augenblick freien Speicherplatz, liefert
   * notfalls (s.o.) nur die LÑnge des grîûten freien Bereichs.
   *)

PROCEDURE SysAlloc ( VAR addr: ADDRESS; size: LONGCARD );
  (*
   * Wie ALLOCATE, jedoch wird der angeforderte Speicherbereich nicht bei
   * Beendigung des Programms, das aktiv war, wÑhrend der Speicher ange-
   * fordert wurde, freigegeben, sondern erst, wenn 'Storage' beendet
   * wird, also wenn z.B. die Shell verlassen wird.
   * Verwendet notfalls (s.o.) ALLOCATE, sodaû Speicher doch be Prozeûende
   * freigegeben wird.
   *)

PROCEDURE TrailAvail (ad: ADDRESS): LONGCARD;
  (*
   * Liefert den noch evtl. freien Bereich direkt hinter dem angegebenen
   * Block. Ist dieser grîûer als Null, kann der Block davor mittels
   * 'Enlarge' (s.u.) um diesen Betrag vergrîûert werden.
   * Liefert notfalls (s.o.) Null.
   *)

PROCEDURE Enlarge ( VAR addr: ADDRESS; add: LONGCARD; VAR ok: BOOLEAN );
  (*
   * Vergrîûert den Block um 'add' Bytes, falls direkt dahinter entsprechend
   * viel Speicher frei ist.
   * 'ok' liefert entsprechend 'TRUE', wenn dies mîglich war.
   * Notfalls (s.o.) wird diese Funktion ignoriert und 'ok' liefert FALSE.
   *)

(*
 * ---------------------------------------------------------------------------
 * Folgende Funktionen dÅrfen nicht aufgerufen werden, wenn
 * 'FullStorBaseAccess' FALSE ist, ansonsten tritt ein Laufzeitfehler
 * (IllegalCall) auf.
 * ---------------------------------------------------------------------------
 *)

PROCEDURE MemSize ( addr: ADDRESS ): LONGCARD;
  (* Liefert LÑnge des Speicherblocks. Liefert 0L, wenn Block unbelegt ist. *)

PROCEDURE Keep ( addr: ADDRESS );
  (*
   * Macht den angegebenen Speicherbereich dauerhaft resident, als wenn
   * er mit SysAlloc alloziert worden wÑre.
   * Er wird dann nur noch durch einen expliziten Aufruf von
   * 'DEALLOCATE (addr, 0L)' freigegeben.
   *)

PROCEDURE KeepAll ( process: LONGWORD );
  (* Systemfunktion ! *)

(*
 * ---------------------------------------------------------------------------
 *)

PROCEDURE More ( id: INTEGER; p: ADDRESS );
  (* Systemfunktion ! *)

END StorBase.

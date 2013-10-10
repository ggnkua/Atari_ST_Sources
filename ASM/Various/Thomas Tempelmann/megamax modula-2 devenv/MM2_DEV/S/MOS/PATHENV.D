DEFINITION MODULE PathEnv;

(*
 * Globale Variable zur Festlegung und Abfrage der Pfad-Umgebung:
 *
 *  - HomePath
 *  - SelectFile
 *)

FROM MOSGlobals IMPORT PathStr, FileStr;

CONST   HomeSymbol = '*';
          (*
           * Wird von 'SearchFile' und 'FullName' durch den 'HomePath'
           * ersetzt.
           *)

VAR     HomePath: PathStr;
  (*
   * Liefert den vollst. Pfadnamen, der zum Zeitpunkt des Programmstarts
   * aktiv war. Dies ist in der Regel auch der Pfad, von dem das Programm
   * gestartet wurde, und in dem sich normalerweise auch dessen Zusatz-
   * dateien, wie z.B. die Resource-Datei, befinden.
   *
   * Allerdings ist es auch mîglich, ein Programm so zu starten, daû
   * das aktuelle Verzeichnis nicht das ist, von dem das Programm stammt.
   * Beispielsweise kann dies im Desktop (ab TOS 1.4) erreicht werden,
   * indem das Programm in einem unten liegenden Fenster doppelt
   * angelickt wird, und dabei die rechte Maustaste festgehalten wird.
   * Damit die beim Programm befindlichen Dateien dann trotzdem noch
   * gefunden werden, ist entweder 'AESMisc.ShellFind' zu benutzen
   * oder dieser HomePath zu berÅcksichtigen. Soll beispielsweise
   * die Funktion 'Paths.SearchFile' verwendet werden, dÅrfen die
   * Pfade der Suchliste mit dem HomeSymbol ("*") beginnen - dies wird
   * dann automatisch durch den HomePath ersetzt.
   *
   * Bei GEM-Programmen wird der HomePath automatisch bei Aufruf von
   * 'GEMEnv.InitGem' initialisiert. Sonst muû er manuell, z.B. durch
   * 'Directory.GetDefaultPath (HomePath)', initialisiert werden.
   * Vorsicht beim manuellen Setzen: Der Pfad muû mit einem '\' oder ':'
   * abgeschlossen sein - ggf. Directory.ValidatePath anwenden!
   *
   * ACHTUNG:
   *   Bei InitGem kann u.U. der falsche Pfad eingesetzt werden: Wenn das
   * Programm, das InitGem aufruft, nicht vom Desktop sondern einem anderen
   * Prg. gestartet wurde, das dazu aber nicht 'ShellWrite' aufrief,
   * wird als HomePath der Pfad eingesetzt, von dem das aufrufende Programm
   * stammt, sofern dies vom Desktop gestartet wurde. Letztendlich heiût
   * das: Wer GEM-Programme startet, muû eigentlich mit ShellWrite Pfad
   * und Argumente Åbermitteln. Das aufgerufene GEM-Programm erfragt diese
   * Informationen ggf. dann mit ShellRead. Wird der ShellWrite-Aufruf
   * unterlassen, bleiben die Informationen vom vorigen Aufruf bestehen
   * und man erhÑlt bei ShellRead die falschen Daten. Da das Desktop auf
   * immer ShellWrite benutzt, sind es dann meist die Daten es dort gestar-
   * teten Programms. Das alternative Desktop-Programm "GEMINI" verhÑlt sich
   * korrekt, bisherige Neodesk-Versionen (auch ein Desktop) dagegen verwenden
   * nicht ShellWrite: Startet man von dort ein MM2-Programm, z.B. die
   * MM2Shell, findet sie ihre Dateien nicht auf den Pfaden, die mit dem
   * HomePath-Symbol ("*") versehen sind, weil sie dann den HomePath von
   * Neodesk verwendet.
   * Ob ein Programm ShellWrite korrekt verwendet, kann leicht geprÅft werden:
   * Man starte von dort die MM2Shell und sehe sich den Shell-Pfad (in den
   * Umgebungsinformationen) an. Wenn er den Pfad enthÑlt, in dem die Shell
   * auch steht, ist es korrekt. Wenn dort der Pfad des anderen Programms
   * steht, hat es ShellWrite nicht benutzt.
   * Wenn Sie diesen "Fehler" vermeiden wollen, setzen Sie den HomePath
   * mit 'Directory.GetDefaultPath (HomePath)' nach dem InitGem-Aufruf
   * neu. Dann wird immer der aktuelle Pfad verwendet, der zumindest von
   * fast jedem GEM-aufrufenden Programm auf den Pfad gesetzt wird, worin
   * das Prg steht.
   * Oder verwenden Sie nicht den HomePath (keine "*" in den Pfadlisten)!
   *)

PROCEDURE ReplaceHome ( VAR pathOrName: ARRAY OF CHAR );
PROCEDURE HomeReplaced ( REF pathOrName: ARRAY OF CHAR ): FileStr;
  (*
   * Wandeln einen Datei- oder Pfadnamen in Groûbuchstaben und setzen den
   * aktuellen 'HomePath' ein, falls das Zeichen 'HomeSymbol' an Anfang
   * enthalten ist.
   *
   * Wird ein vollstÑndiger Pfadname, incl. Laufwerk und Pfad vom Root-Dir
   * benîtigt, muû zusÑtzlich danach 'Directory.MakeFullPath' aufgerufen
   * werden.
   *)

                        (*  Dateiauswahlroutine  *)
                        (*  ===================  *)

(* Im Folgenden wird die Mîglichkeit geboten, eine beliebige
 * Dateiauswahlroutine systemweit zugÑnglich zu machen.
 *
 * Eine solche Routine bekommt einen Pfad ('path') und einen
 * Dateinamen ('name') Åbergeben und sollte dem Benutzer da-
 * raufhin die Gelegenheit bieten, beide zu verÑndern. Als Re-
 * sultat sollte sie die neuen Zeichenketten zurÅckgeben und
 * zusÑtzlich einen BOOLEAN-Wert ('ok') liefern, der angibt,
 * ob der Anwender seine Wahl erfolgreich getroffen hat.
 *
 * Die Prozedurvariable wird bei Aufruf von 'GEMEnv.InitGem'
 * automatisch mit der vom AES bereitgestellten Prozedur
 * 'AESMisc.FileSelect' bzw. 'AESMisc.FileSelectExtended'
 * (je nach GEM-/TOS-Version) initialisiert. In anderen FÑllen
 * muû sie gesondert initialisiert werden. Ansonsten geschieht
 * beim Aufruf nichts und 'ok' wird immer FALSE.
 *
 * ACHTUNG: 'path' muû mindestens 64 Zeichen und 'name' mindestens
 *   12 Zeichen fassen kînnen, sonst wird ein Laufzeitfehler
 *   ausgelîst.
 *
 * ACHTUNG: Die Definition wurde auf das TOS 1.4 angepaût.
 *   Dabei ist der Parameter 'title' hinzugekommen. Dort kann
 *   nun eine öberschrift fÅr die Dateiauswahlbox angegeben werden.
 *   Wird das Modula-System auf einem Rechner gestartet, der ein
 *   Ñlteres TOS besitzt, so wird die alte Dateiauswahlbox benutzt
 *   und 'title' bleibt ungenutzt.
 *)

TYPE  FileSelectProc = PROCEDURE ( REF (* title: *) ARRAY OF CHAR,
                                   VAR (* path:  *) ARRAY OF CHAR,
                                   VAR (* name:  *) ARRAY OF CHAR,
                                   VAR (* ok:    *) BOOLEAN );

VAR   SelectFile: FileSelectProc;
        (*
         * Die Datei-Auswahlroutine.
         *)

PROCEDURE NoSelect (REF d:ARRAY OF CHAR; VAR a,b:ARRAY OF CHAR; VAR c:BOOLEAN);
  (*
   * Diese Prozedur kann auf 'SelectFile' zugewiesen werden. Sie kehrt
   * immer sofort zurÅck und setzt 'ok' auf FALSE, so daû praktisch "?"
   * in Pathlisten ignoriert werden.
   *)

END PathEnv.

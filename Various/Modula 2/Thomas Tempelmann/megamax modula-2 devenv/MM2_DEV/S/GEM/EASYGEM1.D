DEFINITION MODULE EasyGEM1;

(*  Inhalt des Moduls:
 *
 *  - Bequeme Auswahl von Dateien mit Selektor (SelectFile)
 *  - Hilfsroutinen fÅr Klemmbrett-Funktionen (AESMisc.Read/WriteScrapDir).
 *
 *  System              : Megamax Modula-2 (MOS 2.0)
 *  Autor               : Thomas Tempelmann
 *  Vertrieb            : Application Systems Heidelberg
 *)

FROM MOSGlobals IMPORT FileStr, SfxStr;


VAR SelectMask: FileStr;
      (*
       * Speichert zuletzt verwendeten Pfad mit Maske (z.B. "C:\MM2\*.*")
       * Braucht normalerweise Åberhaupt nicht von auûen verÑndert werden,
       * es sei denn, eine bestimmte Maske oder Pfad ist erwÅnscht.
       * EnthÑlt 'SelectMask' nur die Maske oder nur den Pfad, wird der
       * fehlende Teil bei Bedarf durch "*.*" bzw. den akt. Pfad ersetzt.
       *)

PROCEDURE SelectFile (   titel: ARRAY OF CHAR;
                      VAR name: ARRAY OF CHAR; VAR ok: BOOLEAN);
      (*
       * Zeigt GEM-Datei-Auswahlbox an.
       *
       * Eingabewerte:
       *   'titel':  Ab TOS 1.4 wird dieser bis zu 30 Zeichen langer Text
       *             als öberschrift der Box angezeigt.
       *   'name':   Voreingestellter Name. Ist darin ein Pfad enthalten,
       *             wird dieser mit "*.*" als Maske angezeigt.
       *             Ist kein Pfad enthalten, wird 'SelectMask' verwendet.
       *             Ist ein einfacher Dateiname enthalten, wird dieser
       *             als Vorauswahl angezeigt, sonst wird nichts vorausgewÑhlt.
       *
       * RÅckgabewerte:
       *   'name':   EnthÑlt Dateiname inklusive vollst. Pfadnamen.
       *             Die Datei muû nicht zwangslÑufig existieren: Es wird
       *             das geliefert, was beim Verlassen im Namensfels steht.
       *             Vorsicht: Wenn kein Name angeklickt bzw. das Namensfeld
       *             leer blieb, liefert 'name' nur den Pfadnamen (mit einem
       *             Backslash abgeschlossen). Der Dateiname kann z.B. mit
       *             'FileNames.FileName()' ermittelt und dann auf Null-LÑnge
       *             ÅberprÅft werden.
       *   'ok':     Ist TRUE, wenn der OK-Knopf angeklickt oder <Return>
       *             gedrÅckt wurde. Ist FALSE, wenn <Abbruch> gewÑhlt
       *             wurde ('name' bleibt dann unverÑndert).
       *
       * Einfache Benutzungsregel:
       * -------------------------
       *    'SelectMask' braucht in der Regel gar nicht verÑndert werden,
       *    auf 'name' sollte vor dem Aufruf ein Leerstring zugewiesen werden.
       *
       * Beispiele:
       * ----------
       *
       * Beim Aufruf (Annahme: Der akt. Pfad sei "C:\MM2"):
       *
       *  Eingabe        Eingabe        Anzeige         Anzeige
       *  'SelectMask'   'name'         Pfad-Feld       Namensfeld
       *  ------------   ------------   -------------   ------------
       *  ""             ""             "C:\MM2\*.*"    leer
       *  "C:\*.*"       ""             "C:\*.*"        leer
       *  "D:\"          "DATEI"        "D:\*.*"        "DATEI"
       *  "*.TXT"        ""             "C:\MM2\*.TXT"  leer
       *  "C:\*.TXT"     "A:\"          "A:\*.*"        leer
       *  "C:\*.TXT"     "A:\T.T"       "A:\*.*"        "T.T"
       *
       * Nach dem Aufruf (bei "OK"-Wahl):
       *
       *  Anzeige         Anzeige       RÅckgabe
       *  Pfad-Feld       Namensfeld    'name'
       *  -------------   ------------  ------------
       *  "C:\*.*"        ""            ""
       *  "C:\*.TXT"      "A.DEF"       "C:\A.DEF"
       *)


PROCEDURE MakeScrapName (suffix: SfxStr; VAR name: ARRAY OF CHAR);
  (*
   * Erzeugt einen Klemmbrett-Dateinamen. Der Pfadname wird mittels
   * ReadScrapDir ermittelt - ist dieser nicht vorhanden, wird er
   * erst aus dem Environment-String "CLIPBRD" zu holen versucht,
   * schlÑgt auch dies fehl, wird ein Ordner namens CLIPBRD auf dem
   * ersten beschreibbaren Laufwerk von C: an angelegt, ansonsten
   * auf A:, auf jeden Fall wird dann der ermittelte Pfadname mit
   * WriteScrapDir zugewiesen.
   *
   * Eingabe:
   *   'suffix': Endung des gewÅnschten Scrap-Namens.
   * RÅckgabe:
   *   'name': VollstÑndiger Dateiname.
   *           Ist er leer, konnte kein Scrap-Ordner angelegt werden.
   *
   * Beispiel:
   *   MakeScrapName ('TXT', name);
   *    >> name = "C:\CLIPBRD\SCRAP.TXT"
   *   Nun kann entweder eine 'TXT'-Datei erzeugt werden oder das
   *   Vorhandensein einer solchen mit Directory.FileExists erfragt werden.
   *)

PROCEDURE ClearScrap;
  (*
   * Lîscht alle "SCRAP.*"-Dateien im Scrap-Ordner, falls dieser
   * existiert.
   *)


END EasyGEM1.

DEFINITION MODULE FileNames;

(*
 * ---------------------------------------------------------------
 *   Operationen auf Datei- und Ordnernamen (ohne Disk-Zugriffe)
 *      sowie Hinweise zur Benutzung des GEM-File-Selektors.
 * ---------------------------------------------------------------
 *
 * Namensverwendung und allg. Erkl„rungen:
 *
 * - Directories sind Verzeichnisse (Ordner) und werden auch mit "Dir"
 *   abgekrzt;
 *
 * - Das Hauptverzeichnis (Wurzel-) (z.B. "A:\") wird auch "Root"-Dir genannt;
 *
 * - Pfade (engl. "Path) sind "Wegbeschreibungen" zu bestimmten Ordnern und
 *   enthalten eine optionale Laufwerksangabe ("A:") sowie beliebige Ordner-
 *   namen. Beispiel: "A:\AUTO\";
 *
 * - Ordner in einem Pfadnamen sollten immer mit einem Backslash ("\")
 *   abgeschlossen sein (siehe auch Funktion 'ValidatePath');
 *
 * - Suffices (Suffix) sind die Namensendungen (Extensionen), z.B. "PRG"
 *   und werden in der Regel als 3-Zeichen-Strings ohne den Punkt angegeben.
 *   Im Gegensatz zum "Suffix" wird der Namensteil vor dem Punkt auch als
 *   "Prefix" bezeichnet;
 *
 * - Als Dateinamen sind, je nach Anwendung, entweder die Namen selbst in einem
 *   Ordner (oder Root-Dir) (z.B. "EDITOR.PRG") oder auch mitsamt ihrem Pfad
 *   (z.B. "A:\MODULA\EDITOR.PRG") gemeint;
 *
 * - Das Default- (aktuelle) Laufwerk ist das, welches angesprochen wird,
 *   wenn ein Pfadname keinen Laufwerkbuchstaben enth„lt (z.B. "\AUTO\");
 *
 * - Der Default- (aktuelle) Pfad/Dir ist derjenige, der angesprochen wird,
 *   wenn ein Pfad keinen Pfadnamen enth„lt (sondern h”chstens eine Lauf-
 *   werksbezeichnung). Es gibt fr jedes Laufwerk einen eigenen Default-Pfad.
 *   Teilweise wird auch zw. Default-Dir und Default-Pfad unterschieden. Dann
 *   ist mit Default-Dir der aktuelle Pfad auf einem bestimmten Laufwerk
 *   gemeint, mit Default-Pfad der aktuelle Pfad des aktuellen Laufwerks;
 *
 * - Wildcard (auch beliebt als "wildcats") sind Dateinamen mit Jokern.
 *   Joker sind "*" und "?". Joker drfen nicht im Pfad-Teil eines Dateinamens
 *   vorkommen (also nicht in Ordnernamen). Ist ein "*" vorhanden, wird es
 *   intern zuerst durch "?" ersetzt, und zwar vom ersten "*" an bis zum
 *   Ende des Prefix/Suffix (beide werden getrennt behandelt). Dann steht
 *   jedes "?" fr einen beliebiges Zeichen (oder auch keins). Bleiben
 *   Leerzeichen, haben diese keine Joker-Funktion - an ihrer Stelle drfen
 *   nur Leerzeichen oder gar keine vorkommen.
 *   Wildcards werden z.B. in 'DirQuery' (Listen von Dateien in einem Ordner)
 *   oder 'NameMatching' verwendet. Letztere Funktion enth„lt auch Beispiele
 *   fr Wildcards;
 *)

FROM MOSGlobals IMPORT FileStr, PathStr, DriveStr, NameStr, PfxStr, SfxStr,
                       Drive, DriveSet;


PROCEDURE ValidatePath ( VAR path: ARRAY OF CHAR );
PROCEDURE PathValidated ( REF path: ARRAY OF CHAR ): PathStr;
  (*
   * Fgen ggf. '\' an den Pfadnamen an, damit 'path' eindeutig als vollst.
   * Pfadname erkennbar ist. Zudem wird der Pfad ggf. in Grožbuchstaben
   * umgewandelt.
   *
   * Ein '\' wird genau dann angefgt, wenn der Pfad weder leer, noch das
   * letzte Zeichen ein ':' oder schon ein '\' ist.
   *
   * Bei 'ValidatePath' ist darauf zu achten, daž der String grož genug
   * ist (mind. 128 Zeichen, z.B. vom Type 'PathStr'), sonst tritt ggf.
   * ein "String overflow"-Fehler auf!
   *
   * Diese Funktion sollte nach allen Pfadeingaben von aužen angewandt
   * werden! (Die hiesigen Funktionen, die Pfade liefern, tun dies selbst).
   *
   * Beispiele:
   *   PathValidated ("A:")          = "A:"         (akt. Pfad auf A:)
   *   PathValidated ("A:ORDNER")    = "A:ORDNER\"
   *   PathValidated ("ORDNER")      = "ORDNER\"
   *   PathValidated ("")            = ""           (Default-Pfad)
   *   PathValidated ("\")           = "\"
   *)

PROCEDURE SplitPath ( REF fullname: ARRAY OF CHAR;
                      VAR path, name: ARRAY OF CHAR );
  (*
   * Spaltet einen vollst. Dateinamen in seinen Pfad und den "einfachen"
   * Dateinamen (ohne Pfad) auf.
   * 'name' sollte mind. 12 Zeichen fassen, 'path' sollte so grož wie
   * 'name' (oder mind. 128 Zeichen) sein, sonst kann ein Laufzeitfehler
   * (string overflow) auftreten.
   *)

PROCEDURE SplitName ( REF filename: ARRAY OF CHAR;
                      VAR prfx, sfx: ARRAY OF CHAR );
  (*
   * Spaltet einen "einfachen" Dateinamen (12 Zeichen, ohne Pfad) in Prefix
   * (8 Zeichen) und Suffix (3 Zeichen) auf.
   *)

PROCEDURE FileName   ( REF filename: ARRAY OF CHAR ): NameStr;
PROCEDURE FilePath   ( REF filename: ARRAY OF CHAR ): PathStr;
PROCEDURE FilePrefix ( REF filename: ARRAY OF CHAR ): PfxStr;
PROCEDURE FileSuffix ( REF filename: ARRAY OF CHAR ): SfxStr;
  (*
   * Liefern den Datei-Namen (Prefix & Suffix), den Pfad, den Prefix und
   * die Extension eines beliebigen Dateinamens.
   * Zur Ermittelung der Laufwerkskennung kann die Funktion 'StrToDrive'
   * verwendet werden.
   *)

PROCEDURE ConcatName ( REF prefix, suffix: ARRAY OF CHAR;
                       VAR name: ARRAY OF CHAR);
PROCEDURE NameConc ( REF prefix, suffix: ARRAY OF CHAR ): FileStr;
  (*
   * Setzt einen Dateinamen aus Prefix und Suffix zusammen.
   *
   * Sowohl 'prefix' als auch 'suffix' drfen den jeweils anderen Namensteil
   * enthalten (oder auch nur den Punkt) - sie werden ignoriert.
   * 'prefix' darf auch einen Pfadnamen voranstehen haben.
   * Ist 'suffix' leer, wird kein Punkt angefgt.
   *
   * Beispiel: NameConc ( 'd:\venus', 'mup' )   = 'd:\venus.mup'
   *           NameConc ( 'a:\b\c.txt', 'doc' ) = 'a:\b\c.doc'
   *           NameConc ( 'bla.txt', 'xx.doc' ) = 'bla.doc'
   *           NameConc ( 'bla.txt', '' )       = 'bla'
   *           NameConc ( 'bla.txt', 'nix.' )   = 'bla.'
   *)

PROCEDURE ConcatPath ( REF path, name: ARRAY OF CHAR;
                       VAR fullname: ARRAY OF CHAR);
PROCEDURE PathConc ( REF path, name: ARRAY OF CHAR ): FileStr;
  (*
   * Setzt einen vollst„ndigen Dateinamen aus Pfad und Namen zusammen.
   *
   * Sowohl 'path' als auch 'name' drfen den jeweils anderen Namensteil
   * enthalten - sie werden ignoriert. Allerdings muž 'path', wenn
   * nur ein Pfadname enthalten ist, ggf. mithilfe von 'ValidatePath' mit
   * einem '\' abgeschlossen sein, weil sonst der letzte Ordnername im
   * Pfad als Dateiname erkannt werden und abgeschnitten wrde.
   *
   * Beispiel: PathConc ( 'A:XXX.DAT', 'C:\MEIN.PA' ) = 'A:MEIN.PA'
   *           PathConc ( 'A:\DA\', 'C:\MEIN.PA' ) = 'A:\DA\MEIN.PA'
   *)


PROCEDURE NameUnique ( REF fileName: ARRAY OF CHAR ): BOOLEAN;
  (*
   * Liefert FALSE, wenn Wildcards ('?' oder '*') im Namen enthalten sind.
   * Liefert auch TRUE, wenn 'fileName' leer ist!
   *)

PROCEDURE NameMatching ( REF fileName, wildcard: ARRAY OF CHAR ): BOOLEAN;
  (*
   * šbergeben werden ein Dateiname in 'fileName' und ein Wildcard-Name
   * in 'wildcard'.
   * Es wird TRUE geliefert, wenn der Dateiname zum dem Wildcard pažt.
   * Ist 'fileName' leer, wird immer FALSE geliefert.
   * Es drfen keine Pfade in den Namen enthalten sein, sonst kann es
   * zu fehlerhaften Ergebnissen kommen!
   *
   * Solch eine Prfung wird auch beim 'wildcard'-Parameter bei 'DirQuery'
   * vorgenommen.
   *
   * Beispiele:
   *   auf Wildcard | passen folg. Dateinamen | passen folg. Dateinamen nicht
   *   ------------ | ----------------------- | -----------------------------
   *    "*.*"       |  Alle                   |  ""
   *    "ABC.*"     |  "ABC.A", "ABC"         |  "ABCD.A", "B.DEF"
   *    "A?"        |  "A", "AB"              |  "ABC", "A.B" (kein Suffix!)
   *    "?B*.?"     |  "AB", "AB.D", "ABCD"   |  "AB.DEF", "AC.D"
   *)

PROCEDURE DriveToStr ( driveNo: Drive ): DriveStr;
  (*
   * Liefert einen Leerstring, wenn 'driveNo' = 'defaultDrv', sonst
   * den gewnschten LW-Buchstaben mit einem Doppelpunkt.
   *
   * Beispiel: 'DriveToStr ( drvB )' = "B:"
   *)

PROCEDURE StrToDrive ( REF driveStr: ARRAY OF CHAR ): Drive;
  (*
   * Liefert die Laufwerkskennung eines beliebigen Datei- ode Pfadnamens.
   * Liefert immer 'defaultDrv', wenn kein Laufwerk (muž ':' enthalten!)
   * oder ein ungltiges Laufwerk angegeben ist.
   *
   * Beipiel: 'StrToDrive ("")' = 'defaultDrv'
   *          'StrToDrive ("C")' = 'defaultDrv' (* ':' fehlt! *)
   *          'StrToDrive ("C:")' = 'drvC'
   *          'StrToDrive ("C:SOURCES\TEST.M")' = 'drvC'
   *          'StrToDrive ("SOURCES\TEST.M")' = 'defaultDrv'
   *)

(*
 * Anwendung des GEM-File-Selektors (FS)
 * -------------------------------------
 *
 * Der FS erh„lt beim Aufruf zwei Strings. Der erste bestimmt den
 * anzuzeigenden Ordner mit der Auswahlmaske (normalerweise '*.*').
 * Der Andere gibt ggf. schon einen ausgew„hlten Dateinamen vor.
 * Bei der Rckkehr erh„lt man ebensolche zusammengesetzten Strings
 * wieder zurck.
 *
 * Beim ersten Aufruf des FS bietet es sich an, als Pfad den Aktuellen
 * einzusetzen und als Maske '*.*' zu verwenden. Dies wird folgender-
 * mažen erreicht:
 *   ordnerUndMaske:= PathConc ( DefaultPath (), '*.*' );
 * Der andere String fr den Aufruf wird meist leer sein, nennen wir
 * ihn 'name'.
 *   GEMEnv.SelectFile ( ordnerUndMaske, name, ok );
 * Bei der Rckkehr kann der dann gew„hlte Dateiname folgendenmažen
 * ermittelt werden:
 *   dateiName:= PathConc ( ordnerUndMaske, name );
 * Bei weiteren Aufrufen des FS ist es meist ratsam, dieselben Strings
 * 'ordnerUndMaske' und 'name' (global deklarieren!) wieder anzugeben
 * - so findet der Anwender immer seine Einstellungen vom vorigen Aufruf
 * wieder.
 *
 * >>> Allerdings kann auch bequemer die Routine 'SelectFile' aus dem
 *     Modul 'EasyGEM1' verwendet werden! Diese erledigt die gerade
 *     gezeigte Namens-/Pfadauswertung automatisch.
 *)

END FileNames.

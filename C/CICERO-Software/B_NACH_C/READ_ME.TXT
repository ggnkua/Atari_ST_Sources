***************************************************************************
* BASIC-KONVERTER NACH C - Test-Version 2.02 - READ_ME-Datei              *
* (C)-1990/91  CICERO-Software                                            *
*              Ballweilerstraûe 7                                         *
*              6676 Mandelbachtal 4                                       *
*              Tel.06803/2834                                             *
***************************************************************************

Achtung!
Diese Test-Version enthÑlt keine Bibliotheken fÅr die Feldverwaltung
und nur eingeschrÑnkte Bibliotheken der anderen GFA-BASIC-Funktionen.
(z.B. nur Teile der VDI/AES-Funktionen)
Header- und Makefiles sind diesen EinschrÑnkungen angepaût.
Auûerdem kann diese Version von 'B NACH C' nur Listings bis zur Grîûe
von 10 KByte bei einem Konverterdurchlauf bearbeiten.

Erst  die  offizielle  Version  'BASIC Konverter nach C Professional'
kann 98% aller GFA-BASIC-Befehle durch entsprechende Bibliotheksfunk-
tionen umsetzen. Hierzu geliefert wird auch ein  530 Seiten umfassen-
des Handbuch, das wichtige Tips und Tricks zu  GFA-BASIC und  Turbo C
neben  einer  ausfÅhrlicher Darstellung der Funktionen (Referenzteil)
und eine EinfÅhrung in C beinhaltet.

Die Version  PIONIER  bearbeitet GFA-BASIC zu ca. 50%. Auch zu dieser
Version wird das  530 Seiten starke  Handbuch  incl. dem Referenzteil
geliefert. Die Version PIONIER, die 189.- kostet, bearbeitet  Sourcen
bis zur Grîûe von 20 KByte.


Wenn Sie diese Diskette an die 

Firma CICERO-Software
Ballweilerstraûe 7
6676 Mandelbachtal 4

einsenden und die Versionen  PIONIER oder Professional bestellen, kîn-
nen Sie die in der  TOS  angekÅndigten gÅnstigen Programmversionen be-
ziehen.


Wir wÅnschen Ihnen viel Freude beim  Konvertieren und viel Erfolg  auf
dem schnellen Weg nach C.

CICERO-Software

MÑrz 1991

------------------------------------------------------------------

Wichtige Anmerkungen!!!

1. Fehler in Turbo C

  Aufgrund folgender Fehler in TC 2.0x kann es bei der Konvertierung der
  GFA-BASIC-Source zu Problemen bzw. zu InkompatibilitÑten kommen:
  
    1. Fehler bei setmatherr: Das Starten von grîûeren Programmen
       (vgl. morphos.lst) ist evnt. nicht mîglich, da TC Vektoren
       in den Data-Bereich das Benutzerprogramms einbindet. Dies
       fÅhrt zu Problemen bei Data-Bereichen > 32K. (In Version 2.03
       behoben)
       
    2. Fehler bei SIGNAL  : ON BREAK ist nicht mîglich.  Beim  Konvertieren
       kann nach dem Druck von Control D  keine Taste mehr gedrÅckt werden.
       Bei den Rechnern der TT-Klasse muû der Konverter sogar ganz die Mîg-
       lichkeit,  einen  Break  wÑhrend der Konvertierung machen zu kînnen,
       ausschlieûen.
    
    3. Fehler bei Typkonvertierungen (vor allem bei verschachtelten Makros)
    
    4. Fehler bei Ausgabe von printf("%G",xx).  Flieûkommazahlen werden mit
       vielen  sinnlosen Nullen nach dem  '.' ausgegeben.  Dieses Verhalten
       ist bei  Ausgaben von Strings und bei PRINT USING fÅr Fehler verant-
       wortlich.

  Die Firma Borland hat uns zugesichert, daû diese Fehler bald behoben sein
  werden. Bitte wenden Sie sich  direkt  an  Borland  MÅnchen, um eine neue
  Version von Turbo C zu erhalten.

----------------------------------------------------------------------------

2. Tips zu Turbo C:

----------------------------------------------------------------------------

Zur problemlosen Konvertierung und Compilierung sollten Sie folgende Com-
pilerschalter in Turbo C setzen:

  -Size optimations
  -Use absolute calls (bei kleineren Programmen nicht notwendig)

manchmal bei sehr groûen Programmen wegen eines Fehlers in Turbo C 
erforderlich:

  -no string merging

Bei Åberaus groûen Basicprogrammen, die konvertiert wurden (bis ca. 700 K)
hatte Turbo C bisweilen das Problem, daû Stringkonstanten ( z.B. printf()-
Formatstrings nicht korrekt Åbergeben wurden,  wobei  sich  herausstellte, 
daû im ausfÅhrbaren Programm falsche Pointer gesetzt waren(?). (Vielleicht
arbeitet der Codeerzeuger von Turbo C bei groûen Data-Bereichen nicht vîl-
lig korrekt).

Stacksize: ca. 4096 - 16384

(Bitte beachten Sie, daû Turbo Debugger nur Stackgrîûen in der Zweierpotenz
richtig bearbeiten kann, es ergibt sich sonst  die  nicht sehr aussagekrÑf-
tige Fehlermeldung: Sourcefile hat falsches Format.

----------------------------------------------------------------------------

3. Tips zu B NACH C

----------------------------------------------------------------------------

Geschwindigkeitssteigerungen unter Turbo C:


In den meisten FÑllen werden die ehem. Basicprogramme schneller - dies vor
allem bei  Rechnungen  im  Byte-Word-Long-Integerbereich oder  bei String-
operationen(Faktoren etwa zwischen 1.4 im Integerbereich bis 20 im String-
bereich).
Langsamer werden dagegen nahezu  alle  Flieûkommaoperationen,  da  Turbo C 
eine 10- , das Basic jedoch nur eine 8-Byte  Flieûkommaarithmetik  verwen-
den. Der Vorteil  der  C-Bibliothek liegt jedoch in der wesentlich hîheren
Genauigkeit.
Kommt es Ihnen auf hîchsten Datendurchsatz Ihres  Rechners an,  so  kînnen
Sie die UnterstÅtzung des Coprozessors durch  Turbo C  ausnutzen.  Hierbei
sind Geschwindigkeitssteigerungen bis zum Faktor 500 gemessen worden.
Immer empfiehlt es sich,  wenn  mîglich,  mit Integervariablen zu program-
mieren.


Programmgrîûe - Libraries


Da Turbo C beim Aufruf auch von nur einer Flieûkommafunktion die komplette
Library hinzulinkt, kann viel Code dadurch eingespart werden, wenn Sie auf
Flieûkommaoperationen verzichten kînnen. In diesem Fall mÅssen sie  die im
Ordner A:\LIBOFLT befindlichen Librarys statt der in A:\LIB sich befinden-
den hinzulinken. Beachten Sie, daû dann jedoch  keine  Flieûkommaoperation
stattfinden darf.


StringlÑngen


WÑhrend GFA-BASIC nur StringlÑngen bis 32767 Byte  Grîûe  erlaubt,  kînnen
mehrere Konverterstringroutinen bis zu 64 Kbyte StringlÑngen verarbeiten.
(vgl. hierzu: B_NACH_C.H oder Referenzliste)


Schnellanzeige


Die Schnellanzeige (BASIC-C-Referenz), die B NACH C direkt nach dem Konver-
tieren generiert, referenziert immer nur die 1. Zeile und hiervon der 1.in
einer Zeile zu wandelnde Ausdruck. Bei Umwandlungen, die fÅr  eine  Basic-
zeile mehrere C-Zeilen erforderlich machen (z.B. CASE "a","b","c") wird im
C-Bereich nur die Kovertierung des 1. Ausdrucks  angezeigt. Dies wurde we-
gen der grîûeren öbersichtlichkeit  so implementiert.  (Sind  Sie  an  der
kompletten  öbersetzung interessiert, so lassen  sich Basic- und C- Source
sowieso leicht in einem Texteditor vergleichen). Die mit 'Datei - Gehe zu'
oder Control G anzuspringende bzw. angezeigte Zeilennummer  entspricht  in
der Regel  NICHT!!!  der GFA-BASIC-Source-Zeile,  da  nicht konvertierbare
Zeilen oder Zeilen ohne direkte Referenz im 3. Pass nicht angezeigt werden.

Die Cursorsteuerung der Schnellreferenz ist:

Cursor up         : eine Zeile in Richtung kleinerer Basiczeilen
Cursor down       : eine Zeile in Richtung grîûerer  Basiczeilen
Shift-Cursor up   : eine Seite in Richtung kleinerer Basiczeilen
Shift-Cursor down : eine Seite in Richtung grîûerer  Basiczeilen
Home              : an den Anfang
Shift Home        : ans Ende
CONTRL G          : Gehe zu (Zeile)

Wurde durch CONTRL O oder 'Datei-Lesen' eine Basicdatei eingelesen, so er-
scheint eine ganzseitige  Anzeige,  in der man i.U.z.o.  zeilenweise durch
den Text scrollen kann

Da die Referenzanzeige fÅr jede Zeile 8  Byte  Speicherplatz  beansprucht,
kann sie unter dem MenÅpunkt 'Referenzieren' ganz ausgeschaltet werden- es
wird dann kein Speicher mehr angefordert, im Gegensatz zu dem  MenÅeintrag
'Umsetzung anzeigen', bei dem lediglich die Bildschirmanzeige aus- und an-
geschaltet werden kann. Dies empfiehlt sich besonders bei  sehr groûen An-
wendungen.


Neue Implementationen der Version 2.01/2


Neu ist der MenÅeintrag unter der Rubrik 'Konvertieren' 'C++ - Mode'.  Der
Konverter generiert C-Code fÅr C++ - Compiler, wenn vor diesem Eintrag ein
Haken ist.
Die Grîûe des freien Speichers lÑût sich unter dem Eintrag  'System-Freier
Speicher' erfragen.
Unter Datei-Errorfile ist es mîglich, statt Bildschirmausgaben von Fehler-
meldungen eine Fehlerdatei erstellen zu lassen.  Auch  diese  Ausgaben be-
rÅcksichtigen die weiter unten beschriebene  B NACH C  Compileroption '$W'
und die Einstellungen  der Warnungsstufen im MenÅ 'Parameter Ñndern'. Wird
ein Errorfile erstellt, schreibt B NACH C keine Warnungen in die C-Source.
Bitte beachten Sie, daû Fehler (z.B. nicht konvertierte Befehle) von Ihnen
nachtrÑglich bearbeitet werden mÅssen (PIONIER-Version).


Dynamische Stringverwaltung (in der Testversion nicht vorhanden!)


Mit Hilfe des Eintrages 'Optionen-Dyn./Stat. Strings' wird  der  Konverter
veranlasst, C-Code fÅr statische oder dynamische  Strings  zu  generieren.
Generiert der Konverter Code fÅr die dynamische Stringbehandlung, so Åber-
wachen alle Libraryfunktionen eventuelle StringÅberlÑufe und passen 'auto-
matisch' die Strings wie auch GFA-BASIC an.
Bei statischer Stringverwaltung erhalten  Sie  im Fall  eines  StringÅber-
laufs eine Fehlermeldung und mÅssen die erforderlichen Anpassungen wie  im
Handbuch unter 3.5 beschrieben selbst vornehmen.
Vorteil  und Nachteil der jeweiligen Methode  sind im gleichen Kapitel ge-
nannt.
Neu hinzugekommene Funktionen fÅr die dynamische Stringverwaltung in C ent-
nehmen Sie der unten angegebenen Referenzliste.


FÅr  diese neuen MenÅeintrÑge gibt es folgende Schalter fÅr die 'APP'-Ver-
sion bzw. fÅr das Konfigurationsfile:

                                          DEFAULT (ohne Schalter)
  -f:       Errorfile generieren          kein Errorfile
  -s:       dynamische                    statische Strings
  -m:       Auswahl der Zieldatei         automatische Generierung
            (<src>.LST -> <dest>.C)       der Zieldatei(<src>.LST -> <src>.C)
  -r:       keine Referenzierung          Referenzierung
  -+:       C++ - Mode                    ANSI - Mode

Die Einstellung der Option: 'Schreiben' wird nicht  im  Konfigurationsfile
abgespeichert.

Als neue Compileroption wurde $Wx eingefÅhrt, wobei 0<x<7. Die Warnung 'x'
wird nicht mehr angezeigt.
Syntax:

$Wx1,x2,...


ErgÑnzung zur Referenzliste


(Stringverwaltung - in der Testversion nicht vorhanden!)

void B_drealloc(str, max_l)

    char **str;          /* Adresse des Pointers auf den BNC-Stringbereich */
    unsigned int;        /* Puffergrîûe fÅr Reallozierung */

  Funktion:    Reserviert Speicherbereich fÅr BNC-Strings der Grîûe
               'max_l' (dynamische BNC-Strings).


char *B_ldrealloc(max_l)

  unsigned int max_l;  /* Puffergrîûe fÅr Reallozierung */

  Funktion:    Reserviert Speicherbereich fÅr BNC-Strings in Unterproze-
               duren der (Puffer-)Grîûe 'max_l'.
  RÅckgabe:    Pointer auf neuen BNC-String (dynamische BNC-Strings).


char *B_ndcpy(src)

  char *src;           /* Pointer des alten Strings */

  Funktion:    Rettet bei 'Call by value' den Inhalt der Stringvariablen
               'src' (dynamische BNC-Strings).
  RÅckgabe:    Pointer auf neuen String


void B_dsfree(str)

  char *src;           /* Pointer auf Stringvariable */

  Funktion:    Gibt temporÑren Speicherbereich der bei 'Call by value' an-
               gelegten Stringvariablen wieder frei(dynamische BNC-Strings).


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Die erfahrungsgemÑû hÑufigsten Ursachen von InkompatibilitÑt:

  - BereichsÅberschreitungen im Integer-Long-Bereich (vgl. 13.4)
    (treten oft bei Multiplikationen zweier Integervariablen auf -
    sind meist durch den Compilerschalter $*% zu beheben, sonst casten!)

  - Falsche Divisionsergebnisse infolge einer Ganzzahldivision des C-
    Compilers, bei der GFA-BASIC noch mit Flieûkommaarithmetik arbeitet
    (treten oft bei Divisionen zweier Integervariablen auf -
    sind meist durch den Compilerschalter $%0 zu beheben, sonst casten!)

  - verlassener Geltungsbereich von lokalen Variablen (vgl. 13.6)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Bitte  achten Sie beim Konvertieren immer auf diese nicht  pauschal  durch
B NACH C bearbeitbaren InkompatibilitÑten. Bei Åber 80% der Fehler  traten
diese Probleme auf.

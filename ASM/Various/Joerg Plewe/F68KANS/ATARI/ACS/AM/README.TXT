Nachladbare Module
==================
ACS liefert folgende nachladbare Module im Entwicklerpaket mit:

SHELL       Accessory zum Starten der Module
DIGI_UHR    Digital Uhr
EDIT        Texteditoren
IMGVIEW     IMG-Viewer, der auch das Ausschneiden erlaubt
IMGEDIT     IMG-Zeichenprogramm, der auch das Ausschneiden erlaubt
KEYS        Tastenkodes
LUPE        Eine Lupe
MEMWATCH    Speicherw„chter
RECHNER     Taschenrechner
VIEWKEY     Zeige Tastenkode


DITHER      Konfiguriert Dithermode
SYSFONT     Konfiguriert Fonts der Userdefs
SYSVAR      Zeigt die Variablen des ACSblk's an


SHELL
=====
Die Shell ist kein nachladbares Module. Sie ist hier aufgefhrt, da
ihr einziger Zweck das Starten von Modulen ist. So k”nnen aus jedem
sauberen GEM-Programm, und dazu geh”rt die Accessoryleiste zuzulassen,
Module, zum Beispiel ein Editor, gestartet werden.

Die Shell untersttzt VA_START des AV-Protokolls. So kann man
beispielsweise in GEMINI nachladbare Module direkt auf die SHELL-Ikone
ziehen. Ein Doppelklick auf die SHELL-Ikone ”ffnet die Dateiauswahlbox

Bitte beachten Sie, da Accessories durch fehlerhafte Applikation in
Mitleidenschaft gezogen werden. Daher sollten zum Beispiel Editorinhalte
m”glichst oft gesichert werden.



DIGI_UHR
========
Die Digitaluhr zeigt mit groen Ikonen die Zeit an. Drckt man
das Display ein, wird das Datum angezeigt.


EDIT
====
Nach Laden dieses Modules erscheint eine Editor-Ikone, die durch
Doppelklick Text-Editoren erzeugt. Damit k”nnen mehrere Texte 
gleichzeitig bearbeitet werden. Die Bedienung des Editors entnimmt
man dem entsprechende Kapitel des Handbuches.


IMGVIEW
=======
!Die Funktionalit„t wird durch den IMGEDIT bertroffen!
Analog zu EDIT erscheint eine Ikone, die auf Doppelklick weitere
Viewer anlegt. Dazu erscheint zun„chst die Dateiauswahlbox. Es k”nnen
nur IMG-Dateien (auch XIMG) gelesen werden. Das Bild wird angezeigt.
Es k”nnen Teile aus dem Bild ausgeschnitten werden, um zum Beispiel
auf den Ikoneditor des Builder gezogen zu werden.
Zu Begin ist das ganze Bild selektiert. Anklicken zieht sofort
das Bild. Um einen andere Ausschnitt zu w„hlen gibt es zwei M”glichkeiten.
Die erste ist mit der Maus und gedrckter SHIFT-Taste einen Bereich
aufzuziehen. Auerhalb des bisher ausgeschnittenen Bereiches kann
auf die SHIFT-Taste verzichtet werden.
Die zweite M”glichkeit ist ein Doppelklick in das Fenster. Dann
erscheint eine Dialogbox, die die Werte direkt entgegen nimmt.

Achtung: Ziehoperationen funktionieren nur innerhalb eines Programmes.
Von der SHELL kann nicht auf den Builder gezogen werden!


IMGEDIT
=======
Analog zu EDIT erscheint eine Ikone, die auf Doppelklick weitere
Painter anlegt. Dazu erscheint zun„chst die Dateiauswahlbox. Es k”nnen
IMG-Dateien (auch XIMG) gelesen werden. Das Bild wird angezeigt.
Es k”nnen Teile aus dem Bild ausgeschnitten werden, um zum Beispiel
auf den Ikoneditor des Builder gezogen zu werden.
Dazu w„hlt man Blockoperationen an (gepunkter Rahmen). Danach kann
ein Ausschnitt aufgezogen werden. Wird vor dem Verschieben die
Shifttaste gedrckt, kann der Ausschnitt auch auf andere Fenster
gezogen werden!

Achtung: Ziehoperationen funktionieren nur innerhalb eines Programmes.
Von der SHELL kann nicht auf den Builder gezogen werden!


KEYS
====
Dieses Module erlaubt den gesamten Zeichensatz anzuw„hlen. Dazu 
erscheint ein Fenster mit allen 256 Zeichen. Zun„chst sollte das
Fenster in welche ein Zeichen eingefgt werden soll getoppt werden.
Anschliessend drckt man mit RECHT-LINKS-Klick auf das gewnschte 
Zeichen. Innerhalb einen ACS-Programmes wird direkt die (wi-> key)
Routine aufgerufen. Zwischen verschiedenen Applikationen bzw. 
Accessories wird der Tastendruck per appl_tplay bertragen. Im 
letzteren Fall k”nnte der Tastendruck auch als ShortCut z.B. in Men
ausgewertet werden!

LUPE

====
Die Lupe l„uft in allen Aufl”sungen. Sie kann in 4 Gr”ssen konfiguriert
werden:
          16x16
          32x16
          16x32
          32x32

Dazu ist in die Lupe hineinzuklicken. Es erscheint dann ein Popup-Men
das die erw„hnten Gr”ssen anbietet.
Das Fadenkreuz ist ebenfalls durch Popupmenu steuerbar


MEMWATCH
========
Die Module zeigt die ersten 16 freie Speicherbl”cke an. Damit kann
die Zerstckelung des Speicher verfolgt werden. Es ist in der 
Entwicklungphase interessant den Speicherverbrauch zu analysieren.


RECHNER
=======
Dieser einfache Taschenrechner, der im Wesentlichen die 
Grundrechenarten beherrscht, erlaubt sein Display zu ziehen. Objekte,
die den Type AT_STRING akzeptieren, k”nnen somit den Wert empfangen.
Der Editor ist zum Beispiel darauf vorbereitet.


VIEWKEY
=======
Dieses kleine Programmierutility zeigt den Tastencode, der zuletzt
gedrckten Taste an (Scancode und ACSIIcode). 


DITHER
======
Diese Utility erlaubt den Dithermodus des 3D-Buttons zu konfigurieren.
Dies ist jedoch nur im 2 bzw. 4 Farbmodus sinnvoll. Die Wahlm”glichkeiten
sind im Vierfarbmodus natrlich gr”sser. Die Defaultwerte von ACS sind
jedoch wohl gut genug, so da dieses Utility selten zum Einsatz kommt.
Eine brauchbare Alternative im monochromen Mode, ist der Hintergrund
wei und den weien Rahmen gepunktet zu setzen


SYSFONT
=======
Die Fonts, die die Userdef 3Dbutton, Checkbox, Radiobutton und 
Innerframe verwenden, k”nnen mit diesem Module konfiguriert werden.
Es sind auch proportionale Fonts und andere Gr”ssen einstellbar.
Die Benutzeroberfl„che mu dies dann bercksichtigen.


SYSVAR
======
Hiermit kann man einfach die Variablen des ACSblk auflisten lassen.
Bei Programmieren kann dies sehr ntzlich sein. So kann oft recht
einfach die Fehlerursache ermittelt werden.

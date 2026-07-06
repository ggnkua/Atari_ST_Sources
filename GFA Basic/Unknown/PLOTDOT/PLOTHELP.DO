Diese Anleitung verzichtet auf Umlaute um unabhaengig von eventuell
vorhandenen Textverarbeitungsprogrammen zu sein.

Kurzanleitung zum Programm PLOTFIT (Version 4.0)
================================================

Das Programm ist in GFA Basic geschrieben und benoetigt daher den
GFA Basic Interpreter zb. GFABASRO.PGM (Version 2.0 !).
Das Programm ist sowohl mit dem Atari-Schwarz-Weiss Monitor als auch
mit einem Farbmonitor in mittlere Aufloesung verwendbar. Direkt nach dem
Programmstart wird je nach Monitor (Mono bzw. Farbe) eines der beiden
Files PLOTFIT.MON bzw. PLOTFIT.COL eingelesen. Anschliessend werden diese
Files nicht mehr benoetigt. Diese Files sollten sich im selben Ordner
bzw. auf dem gleichen Disk-Drive befinden wie der Interpreter.
 
Das Programm ist voll menuegesteuert.
 
PLOTFIT dient zur graphischen Darstellung beliebiger X,Y-Wertepaare,
wobei die Y-Werte mit einer optionalen Fehlerangabe versehen sein koennen.
Verschiedene Punktsymbole bzw Linienformen koennen zur Darstellung
benutzt werden (keine Tortengraphik). X- und Y-Achse werden automatisch
mit einer Skala versehen,deren Bereich waehlbar ist.
Beide Achsen koennen beschriftet werden. Ferner kann Text in die Graphik
an beliebiger Stelle in verschiedenen Schriftarten eingefuegt werden.
Logarithmische und lineare Darstellung beider Achsen ist moeglich.
Mehrere Graphen koennen in dasselbe Bild gezeichnet werden.
Linien und Symbole koennen kombiniert werden.
Mehrere Datensaetze koennen gleichzeitig gespeichert werden (<= 8).
Alle Attribute jedes Datensatzes (Skalenbereich,Achsenbeschriftung,
werden ebenfalls gespeichert und koennen separat veraendert werden.
 
groesster Zahlenbereich: -2000000 -> 2000000
kleinster Zahlenbereich: -0.01 -> 0.01
maximale Punkt-Anzahl: 250 bzw. 500 (nur ein bzw. letzter Datensatz)
 
Ein zweites Menu beinhaltet ein Fit-Paket.
Es ermoeglicht verschiedene Funktionen an die Daten anzupassen:
1) Polynome (zb. Ausgleichsgerade,Parabel, etc.)
2) Exponentialfunktionen (zb: Y= Hoehe*exp(const.*X), Gauss-Kurve etc.)
3) Potenz-funktionen( zb: Y=const.* X^Potenz, etc.)
4) mehrere ( <= 3) sich ueberlagernde Gausskurven
Gefittet werden maximal 10 Parameter.
Der Fit kann vorgegebene Fehler der Y-Werte beruecksichtigen oder
die absolute bzw relative Abweichung der Fit-kurve von den Y-Werten
minimieren. Der zu fittende Datenbereich kann durch Spezifikation
eines oder mehrerer X-Wertebereiche ("regions") mittels Maus vorgegeben
werden. Das Ergebnis des Fits kann anschliessend als Datensatz
abgespeichert werden.
 
Ein drittes Menu ermoeglicht die Manipulation von Datensaetzen:
1) Addition,Subtraktion,Division,Multiplikation der Y-Werte.
2) Kopieren,Aneinanderhaengen,Loeschen von Datensaetzen.
3) Invertieren der Y-Werte,Vertauschen von X und Y-Werten, Sortieren,
   Mittellung benachbarter Punkte, Kalibrieren der X- bzw. Y-Werte.
4) Ersetzen, Loeschen, Kalibrieren und Mittelung von Teilbereichen
   eines Datensatzes.
5) Transformation von kartesischen (X,Y) in Polarkoordinaten
   (Radius,Winkel) u. umgekehrt, sowie Rotation und Spiegelung
   der X,Y-Wertepaare.
  
Beispiele und moegliche Probleme am Ende der Anleitung.

Kurzbeschreibung der einzelnen PLOT-MENUES
------------------------------------------
DESK-Menu
=========
Rueckkehr zum Desktop bzw. Basic mit der Option EXIT.
Vor dem Aufruf von DESK Optionen gegebenenfalls den Bilschirm mit der
Option BUFFER im OUTPUT-Menu sichern und anschliessend restaurieren
(Option BUFFER im INPUT-Menu).
  
INPUT-Menue:
============
Die Dateneingabe kann via Datenfile, vom Keyboard oder mittels Maus
erfolgen.
Aequidistante X-Werte koennen vom Programm automatisch erzeugt werden.
Bei einer Eingabe via Maus muessen X- und Y-Skala entweder durch die
Optionen X-RANGE und Y-RANGE im Menue X- bzw. Y-SCALE definiert worden
sein oder durch vorhergehenden Input bereits festliegen.
Die Option COEFF. ermoeglicht die Eingabe von Koeffizienten eines
Polynoms (siehe FIT). Mit Hilfe dieser Koeffizienten kann anschliessend
ein Datensatz (X-,Y-Wertepaare) erzeugt werden.

Fehler fuer die Y-Werte koennen entweder als Absolut- oder als Relativ-
werte (in %) eingegeben werden. Letztere werden durch " % " bei der
Eingabe  gekennzeichnet. 
Die Option ERROR ermoeglicht Y-Fehler zu erzeugen, die durch Wurzel(Y)
gebildet werden (statistische Fehler).

Nachtraegliche Aenderungen sind durch die Option CHANGE im
INPUT Menue moeglich.
Nach Anwahl von CHANGE kann die Aenderung einzelner Datenpunkte via
Keyboard (Aendern,Einfuegen,Loeschen) oder mittels Maus (Aendern,Loeschen)
erfolgen.
Die Aenderung einzelner Koeffizienten ist durch Anwahl von COEFF. nach
Setzen der Option CHANGE moeglich.
Die Option CHANGE erlaubt es auch, durch anschliessende Anwahl von FILE
im INPUT Menue, Daten eines anderen Files an einen vorhandenen Datensatz
anzuhaengen (APPEND) bzw. in diesen einzusortieren (MERGE).
Die Option CHANGE wirkt auf den Datensatz, der durch Anwahl von DATA SET
nach Setzen von CHANGE spezifiziert wurde (Standardeinstelung: der
jeweils graphisch dargestellte Datensatz).

Die Option TEXT erlaubt es beliebigen Text in das Bild einzufuegen
(maximal 10 Zeilen).Diese Zeilen koennen geaendert bzw. geloescht
werden durch Setzen der Option CHANGE innerhalb des INPUT Menues
(Aendern des Textstrings mittels Backspace und Neueingabe,Aendern des
Layouts durch vorherige Anwahl der Option TEXT im Menue STYLE,Aendern der
Position mittels Maus.)
 
Die Option DATA SET waehlt den Datensatz aus, in den die Daten
gespeichert werden ( Anwahl der Datensatz Nr., Ueberschreiben des
letzten Datensatzes bzw automatisches Erzeugen eines neuen Datensatzes)
bzw. bestimmt den Datensatz, der via CHANGE geaendert werden soll
(s.oben).
 
OUTPUT-Menue:
============
Datenausgabe auf dem Bildschirm,dem Printer oder in ein File ist
ebenso moeglich,wie die Abfrage von Punktkoordinaten ueber die Maus.

Die  HARDCOPY Routine erzeugt um 90 Grad gedrehte Bildschirm-Kopien,
die ca. 1.8 mal so gross sind wie die normalen Hardcopies. Bei dem
ersten Aufruf von HARDCOPY muss der Printer-Typ spezifiziert werden
(EPSON oder IBM kompatibel). Bei mittlerer Aufloesung werden Farben
grau (Standardeinstellung = Rot) bzw punktiert (Standardeinstellung
 = Blau) dargestellt. Ueber ALTERNATE HELP kann in jedem Fall eine
normale Hardcopy ausgegeben werden.

Ferner enthaelt das OUTPUT Menue eine Integrations-Routine (SUM  Y bzw.
INTEGRATE). 
SUM Y summiert alle Y-werte innerhalb eines X-Bereichs auf
      und berechnet den Y-Mittelwert sowie den X-Schwerpunkt
      (Summe X(i)*Y(i) / Summe Y(i) ). Damit sind die einfachsten(!)
      Funktionen von Kalkulationsprogrammen, die mit Tabellen arbeiten ,
      graphisch realisiert.
INTEGRATE ist nuetzlich,falls die X-Werte nicht aequidistant sind. Diese
          Option dient zur Berechnung von Summe Y(i)*Delta-X(i) usw.

Mittels DATA SET kann der Modus ausgewaehlt werden nach dem der bzw. die
fuer alle OUTPUT Optionen aktiven Datensaetze bestimmt werden.
Standardeinstellung: der jeweils graphisch dargestellte Datensatz bzw.
die dargestellten Datensaetze.

Die Option FIT schaltet auf das FIT-Menu um (siehe unten).

Ein Puffer kann zur Zwischenspeicherung eines Bildes verwendet
werden (Option BUFFER im INPUT bzw OUTPUT Menue). Das eigentliche
Datenfeld wird dabei nicht (!) zwischengespeichert, wohl aber der
X-,Y-Skalenbereich. Durch das Menue DRAW koennen mittels der Option ADD
daher weitere Graphen in ein gepuffertes Bild eingegeben werden.

X-SCALE Menue
=============
RANGE ermoeglicht die Eingabe des Achsen-Wertebereichs via Keyboard
      bzw. Maus.
AUTO waehlt den Achsenbereich gemaess dem Wertebereich der Datenpunkte.
     Nach Abschalten von AUTO ist ein zuvor via RANGE eingegebener Werte-
     bereich wieder aktiv. Wurde via RANGE kein Wertebereich spezifiziert,
     so wird auch bei abgeschalteter AUTO-Funktion eine automatische Wahl
     des Achsenbereichs durchgefuehrt.
LOG schaltet die logarithmische Darstellung der Datenpunkte an bzw. ab.
CALIBRATE ermoeglicht gemaess X-neu = X-alt * Steigung + Offset
          die X-Werte umzurechnen.
          ( <Return> ohne Zahlenangabe : Steigung=1 Offset=0)
EXPAND erlaubt die Spreizung des Achsenbereichs mittels Maus. Der
       X-Wertebereich wird nicht gespeichert d.h. der ueber RANGE bzw.
       AUTO gewaehlte Bereich bleibt erhalten.
MARKER schaltet die Darstellung von senkrechten,gestrichelten
       Markierungslinien ein bzw. aus. Die Darstellung dieser Hilfslinien
       wird erst durch Anwahl von NEW bzw. FRAME im Menue DRAW aktiv.
 
Y-SCALE Menue
=============
siehe X-SCALE Menue.
statt EXPAND kann mit der Option ZOOM ein beliebiger Bildausschnitt
vergroessert werden. Definition des Bildschirm-Rechtecks durch kurzes
Druecken einer Maustaste. Danach ist noch ein Verschieben des
Ausschnittes - auch ueber den oberen Bildrand hinaus - moeglich.
Das Positionieren wird durch Druecken einer Maustaste beendet.

DRAW-Menue:
===========
NEW loescht das Bild und zeichnet einen Graphen wobei der Achsenbereich
    zuvor ueber die Menues X-Scale bzw. Y-Scale eingestellt werden kann.
ADD erlaubt es weitere Graphen in dasselbe Bild einzufuegen.
    Die Achsenbereiche bleiben unveraendert.
FRAME zeichnet nur die X- und Y-Achse.Das alte Bild wird geloescht.
FIT ermoeglicht, das Ergebnis des letzten Fits in das vorhandene Bild
    einzuzeichnen. Die Linienform der Fitkurve kann ueber die
    Option LINE im Menue STYLE festgelegt werden.
DATA SET waehlt den oder die darzustellenden Datensaetze aus.
NEXT     schaltet auf den naechsten Datensatz um. Nach dem letzten
         Datensatz wird auf den ersten zurueckgeschaltet.
PREVIOUS schaltet auf den vorhergehenden Datensatz um. Vom ersten wird
         dabei auf den letzten Datensatz umgeschaltet.
TEXT  erlaubt es die Darstellung von Text innerhalb der Graphik
      an- bzw. abzuschalten.
ERROR schaltet die Darstellung von Y-Fehlerbalken (sofern vorhanden)
      an bzw. ab.
 
STYLE-Menu:
===========
Die ueber die Option TEXT angewaehlte Textart ist nur fuer Label etc.
aktiv, welche mittels der Option TEXT im Menue INPUT irgendwo in das
Bild geschrieben werden koennen.
Linien und Symbole koennen kombiniert werden durch entsprechende Wahl
im Menue STYLE und anschliessendes Zeichnen durch die Option ADD im
Menue DRAW.
Die Option COLOR ermoeglicht die getrennte Farbwahl fuer Text und Linien.
 
 
Alle anderen Menuepunkte sind (vermutlich) selbsterklaerend.
 
Griechische Buchstaben und Sonderzeichen koennen durch Druecken von
CONTROL S und anschliessend einer beliebigen Taste erzeugt werden.
Z.B: K=delta, J=Omega, H=Phi, G=tau usw.  
 
 
Kurzbeschreibung der FIT Menues :
---------------------------------
 
FUNCTION
========
Waehlt die Fit-Funktion aus und erlaubt die Anzahl der Fit-Parameter
(<=10, Standard:2) festzulegen.
 
Gefittet wird ein Polynom (Option LINEAR,EXPONENTIAL,POWER LAW ).
Dabei koennen entweder die Y-Werte logarithmiert werden (Option
EXPONENTIAL) oder sowohl die X- als auch die Y-Werte (Option POWER LAW).
Fehler werden jeweils korrekt umgerechnet.
Achtung: Im Fall der Optionen POWER LAW werden negative Zahlen (X-X0)<0
         bei der Anpassung der Fitkuve nicht beruecksichtigt. Negative
         Y-Werte werden bei den Optionen EXPONENTIAL und POWER LAW
         durch das Maximum der Y-Achse/100000 ersetzt (lineare  Y-Achse)
         bzw. durch das Minimum der Y-Achse/10 (logarithmische Y-Achse)!
 
Im Fall einer Gauss-Kurve (Glockenkurve) werden die Hoehe,Position des
Maximums,Halbwertsbreite und Flaeche der Gauss-Kurve aus den Fit-
parametern berechnet (Option: EXPONENTIAL,3 Koeffizienten).
 
Mit der Option GAUSS-FUNCT. koennen eine oder mehrere Gauss-Kurven
angepasst werden. Dabei wird ein nichtlineares Gleichungs-System
sukzessive (iterativ) geloest. Dies erfordert die Vorgabe von
Anfangswerten (Position,Hoehe und Halbwertsbreite der Gauss-Kurve).
Diese Methode ist umstaendlicher aber genauer als ein Fit mittels der
Option EXPONENTIAL mit 3 Parametern. Sind die Anfangswerte zu weit
von den Optimal-Werten entfernt, kann das Loesungsverfahren
"in die Wueste laufen" und der Fit wird abgebrochen.
 
Die Option TEST-FUNCTION erlaubt es, eine zuvor gewaehlte Funktion in
ihrer Hoehe an die Daten anzupassen. Die Funktion selber kann entweder
durch Eingabe von Koeffizienten im INPUT-Menue oder durch Fit eines
anderen Datensatzes spezifiziert werden.
 
Die Option X-REFERENCE ermoeglicht die Wahl eines Bezugspunktes X0,
der als Referenz fuer die Fitparameter dient.
Achtung: Die Option POWER LAW erfordert positive Werte (X-X0) innerhalb
des Fitbereichs (s. oben).
 
Die Option FIT fuehrt die Anpassung der gewaehlten Funktion an die
Daten aus, wobei die mittlere quadratische Abweichung CHI**2 minimiert
wird. Wird der statistische Fehler der Datenpunkte explizit berueck-
sichtigt (siehe: Menu WEIGHT), wird eine Wahrschenlichkeit dafuer
berechnet, dass die gewaehlte Fitfunktion die Daten korrekt beschreibt
(Werte zwischen 5% und 95% sind vertretbar).
 
WEIGHT
======
Spezifiziert welches Gewicht den einzelnen Datenpunkten beigemessen wird.
Y-ERROR: Zuvor eingegebene Fehler der Y-Werte werden als Gewicht verwendet.
ABSOLUT: Die absolute Abweichung der Datenpunkten von der Fitkurve wird
         minimiert.
RELATIV: Die relative (prozentuale) Abweichung der Datenpunkte von der
         Fitkurve wird minimiert.
Achtung: Bei den Optionen ERROR und RELATIV ist der kleinstmoegliche
         Wichtungsfaktor (Y-Max - Y-Min)/10000 bei lineare Y-Achse bzw.
         Y-Min/1000 bei logarithmischer Y-Achse. Kleinere Wichtungs-
         faktoren werden durch diese Grenzwerte ersetzt ! 
 
REGION
======
Spezifiziert den Datenbereich an den die Fitkurve angepasst werden soll:
ALL:     Alle Datenpunkte.
DISPLAY: Gegenwaertig graphisch dargestellter Bereich.
NEW:     Auswahl eines X-Wertebereichs ("region") mittels Maus.
APPEND:  Hinzufuegen weiterer X-Wertebereiche (maximal 10).
SHOW:    zeigt mittels Markern die durch NEW bzw. APPEND ausgewaehlten
         X-Werebereiche. Gleichzeitig werden diese Wertebereiche wieder
         aktiviert falls zuvor die Option ALL oder DISPLAY aktiv war.
DATA SET:spezifiziert den Datensatz bzw. die Datensaetze,
         an die die Fitkurve angepasst werden soll. Standardeinstellung:
         graphisch dargestellter Datensatz bzw dargestellte Datensaetze.
 
STORE
=====
Erlaubt das Ergebnis des Fits als Datensatz mit X-,Y-Wertepaaren zu
speichern (Option REPLACE oder CREATE). Die Option CREATE ermoeglicht
die Wahl eines beliebigen X-Wertebereichs mit aequidistanter Punkt-
folge.
Die Option SUBSTRACT subtrahiert das Fitergebnis von den Datenpunkten.
Die Option DIVIDE teilt die Daten durch das Fit-Ergebnis.
Die Option DATA SET bestimmt den Datensatz, in den die  so entstandenen
Daten abgespeichert werden. Standardeinstellung: Ein neuer Datensatz
wird angelegt.
 
DRAW
====
siehe Hauptmenu.
Zusatzlich ist die Option BUFFER (siehe INPUT-Menu im Hauptmenu) in
dieses Menu aufgenommen.
 
OUTPUT
======
Ermoeglicht die Ausgabe der Fitparameter auf dem Printer (Option PRINT),
dem Bildschirm (Option SCREEN) oder einem Datenfile (Option FILE).

Ferner kann die mittlere Abweichung der Fitfunktion von den Daten
innerhalb eines vorgegebenen Intervalls bestimmt werden (Option
SUM-ERROR).
 
Die Option X -> Y berechnet fuer einen vorgegebenen X-Wert den Y-Fitwert.
Der Fehler des Y-Fitwertes wird ebenfalls berechnet. Dies ermoeglicht
die Abschaetzung der Unsicherheit einer Extrapolation ueber den Daten-
bereich hinaus.
 
Die Rueckkehr zum Hauptmenue ist durch die Option MAIN MENU moeglich.
 
Anmerkung:
----------
Die Menues STORE und OUTPUT sind auch aktiv wenn zuvor ein Satz von
Koeffizienten via Keyboard eingegeben wurde (Option Coeff. im INPUT
Menue). Die Fehler sind in diesem Fall auf Null gesetzt.
 
 
Kurzbeschreibung der Menupunkte von MENU III :
----------------------------------------------
 
CREATE
======
Der graphisch dargestellte Datensatz wird mit einem weiteren Datensatz
kombiniert (s. unten). Das Ergebnis wird je nach Wahl (Option DATA SET)
in einem neuen Datensatz abgespeichert oder es wird ein alter Datensatz
ueberschrieben.
ADD:      Addieren,subtrahieren der Y-Werte zweier Datensaetze.
          Die Y-Werte des zweiten Datensatzes koennen mit einem Faktor
          multipliziert werden.
DIVIDE:   Division der Y-Werte zweier Datensaetze.
MULTIPLY: Multiplikation der Y-Werte zweier Datensaetze.
 
In allen drei Faellen wird der Fehler der resultierenden Y-Werte durch
Fehlerfortpflanzung aus den Fehlern der Ausgangswerte berechnet.
Sind mehrere Datensaetze graphisch dargestellt, so wird nur der letzte
Datensatz beruecksichtigt !
Sind die X-Werte der beiden beteiligten Datensaetze nicht identisch, so
werden die Y-Werte des zweiten Datensatzes interpoliert !
 
COPY: Kopiert einen oder mehrere graphisch dargestellte Datensaetze in
      einen neuen Datensatz.
MERGE: Sortiert den Inhalt eines waehlbaren Datensatzes in den graphisch
       dargestellten Datensatz ein. Sortiert wird nach Groesse der
       X-Werte. Die relative Anordnung der Wertepaare innerhalb der
       beiden Untereinheiten entsprechend den urspruenglichen 2 Daten-
       saetzen bleibt unveraendert.
       Achtung: Die Nummerr des so neu erzeugten Datensatzes sollte
       nicht  identisch sein mit den Nummern der beiden Ausgangs-
       Datensaetze!  
 
DELETE:
=======
Loeschen von Datensaetzen bzw. des gesamten Textes eines Datensatzes.
 
CHANGE:
=======
Aendert den Inhalt eines Datensatzes.
INVERT:  Ersetzt die Y-Werte durch 1 / Y-Werte.
         Y-Fehler, Achsenbereiche, Text-Koordinaten werden ebenfalls
         umgerechnet.
SWAP X,Y: Vertauscht die X- und Y-Werte. Diese Option kann auch benutzt
          werden um Fehlerangaben fuer X-Werte darzustellen.
CALIBRATE X:lineare Eichung der X-Werte: X-neu = X-alt*Steigung + Offset.
CALIBRATE Y:lineare Eichung der Y-Werte.
AVERAGE: Bildet den Mittelwert von je zwei benachbarten Punkten.
         Sind die Y-Werte mit Fehlerangaben versehen wird eine
         gewichtete Mittelung durchgefuhrt, sodass der Fehler des 
         mittleren Y-Wertes minimiert ist. Bei einer ungeraden Anzahl
         von Datenpunkten wird der letzte Wert unveraendert uebernommen.
SMOOTH: Drei Punkte Mittelung der Y-Werte. Die Anzahl der Wertepaare
        bleibt dabei unveraendert. Y(i)=( Y(i-1) +2*Y(i) + Y(i+1) )/4
        Achtung: Die Datenpunkte sind nach der Operation SMOOTH nicht
        statistisch unabhaengig!
INTEGRATE:Numerische Integration der durch die X-,Y-Wertepaare
          festgelegten Funktion: Y-neu(n) = Summe(Y(i)*delta-X(i)), i=1-n
          Achtung: je nach den Abstaenden der Punkte auf der X-Achse
          koennen sehr grosse Y-Werte erreicht werden. Herunterskalieren
          dieser Werte durch die Option CALIBRATE Y ist dann sinnvoll.
 
REGION
======
Veraendert einen Datensatz nur innerhalb eines vorgegebenen Bereichs.
REPLACE: Ersetzt die Datenpunkte des dargestellten Datensatzes (der
         Datensaetze) durch die im gleichen Bereich befindlichen Werte
         eines anderen Datensatzes. Der markierte Bereich des
         dargestellten Datensatzes muss nicht notwendigerweise Punkte
         enthalten. In letzerem Fall werden die Punkte des zweiten
         Datensatzes eingefuegt bzw. angehaengt.
DELETE:  Loescht alle Punkte innerhalb eines vogewaehlten
         X-Wertebereichs.
CALIBRATE X: Ermoeglicht das Verschieben in X-Richtung von Datenpunkten
             innerhalb eines vorgewaehlten Bereichs (siehe X-SCALE).
CALIBRATE Y: siehe CALIBRATE X bzw. Y-SCALE.
AVERAGE: bildet Mittelwert von je zwei benachbarten Punkten innerhalb
         des spezifizierten Bereichs.
Ist mehr als ein Datensatz graphisch dargestellt,so werden obige
Operationen fuer alle (!) dargestellten Datensaetze durchgefuehrt. 
 
TRANSFORM:
==========
X-Y -> é-R: Wandelt kartesische Koordinaten (X,Y) in Polarkoordinaten
            (Winkel,Radius) um. Ein Kreis wird zb. zu einer horizon-
            talen Geraden. Winkel werden in Grad angegeben.
é,R -> X-Y: Wandelt Polarkoordinaten in kartesische Koordinaten um.
            Eine Gerade mit Steigung <> 0 wird zb. in eine Spirale
            transformiert. Zb.: Eingabe des kleinsten Radiusses (zb. 10)
            sowie der Radiusaenderung pro Grad (zb. 0.1) mittels der
            Option COEFF. (linear) im INPUT-Menue und Wahl der
            Theta-Werte X-Min=0, X-Max=1080 mit Incement=10.
ROTATE: Rotiert die Wertepaare im Uhrzeigersinn um einen vorzugebenden
        Winkel.
Mirror: Spiegelt die X- bzw. Y-Werte des (der) graphisch dargestellten
        Datensatzes (Datensaetze) an der durch X-Y CENTER vorwaehlbaren
        Linie.
X,Y-CENTER: Bestimmt den Ursprung um den rotiert oder gespiegelt werden
            soll bzw. von dem aus Winkel und Radius berechnet werden.
            ( Standardeinstellung: X=0, Y=0 )
Bei allen Transformationen werden Fehlerangaben fuer die Y-Werte
nicht (!) beruecksichtigt.
 
   
File-Struktur:
==============
Das Datenfile sollte die Kennung .DAT besitzen. Es koennen sowohl Ordner
als auch Ordner innerhalb von Ordnern benutzt werden.

Das Datenfile kann vor (!) dem eigentlichen Datensatz verschiedene
Optionen bzw. Kommentare enthalten.

Optionen sind durch Schluesselworte gekennzeichnet,gefolgt von der Option:

X-RANGE:X-min,X-max
Y-RANGE:Y-min,Y-max
X-TEXT:X-Achsen Beschriftung
Y-TEXT:Y-Achsen Beschriftung
STYLE:Symbol-Flag,Histogram-Flag,Stil-Nr,Linienbreite,Linienfarbe
LABEL:Label-Text                (Text irgendwo im Bild)
X-Position,Y-Position,Textstil (1-31), Textgroesse (4,6,13,32)

Alle Zeilen,die nicht mit einem Schluesselwort beginnen werden als
Kommentare betrachtet. Die erste Kommentarzeile wird gespeichert
und in das Output-File uebernommen, alle weiteren werden ueberlesen.

Der Beginn des Datenfeldes muss durch das Schluesselwort DATA:
gekennzeichnet werden ! Z.B.:

DATA:X,Y(,Y-ERROR bzw. X-ERROR)
 (Das optionale Schluesselwort X-ERROR besagt dass sich die Fehler-
 angaben (3 Zahl jeder Zeile) auf die X-Werte beziehen.
 Die folgenden Eingabezeilen werden automatisch auf eine Angabe des 
 Fehlers ueberprueft.)
X-Wert,Y-Wert,Y-Fehler       oder
X-Wert,Y-Wert                oder
X-Wert Y-Wert                oder
X-Wert, Y-Wert, X-Fehler
Eine spezielle Kennung fuer das Ende des Datensatzes ist nicht noetig.
Eine Leerzeile hinter dem Datensatz fuehrt zu einer Fehlermeldung.
 
END: dient der Trennung mehrerer Datensaetze innerhalb eines Files.
     (Es darf als einziges direkt hinter den Daten stehen. Weitere
      nachfogende Angaben sind moeglich. Sie werden ueberlesen)

Schluesselworte koennen gross oder klein geschrieben sein.
Die Option FILE im OUTPUT Menue erzeugt Files gemaess dieser Struktur.
 
Aenderung der Standardeinstellung der Programmparameter:
--------------------------------------------------------
Die Files PLOTFIT.MON bzw. PLOTFIT.COL enthalten in der ersten Zeile
die Voreinstellung des Disk-Drives sowie die Dimensionierungsvariablen
der Datenfelder (Anzahl,Laenge der Datensaetze ...).
In Zeile 2 werden die Koordinaten des fuer die Graphik verwendeten
Bildschirmbereichs und der Bildachsen festgelegt.
Es folgen die Dimensionierungs-Variablen sowie die Kennworte der
Menuleisten.
Die Symboltabelle der graphischen Symbole folgt am Schluss.

moegliche Probleme!!
====================
Ist die Menue-Leiste nach einem Befehl nicht mehr aktiv, so hilft
ein kurzes Klicken mit der Maus.
Mehrfacheingaben mittels Maus werden durch Druecken der rechten
Maustaste beendet.
Geht gar nichts hilft vielleicht das Druecken der RETURN Taste
(Im allgemeinen bleibt bei RETURN ohne Input der alte Wert erhalten;
 Ausnahme: X- Y-Achsenbeschriftung da sonst kein Loeschen moeglich).
Im Fall einer Fehlermeldung ist ein Ruecksprung zum Menu stets die
beste Loesung.Notfalls Daten sichern und von vorn anfangen.
Geht die Hardcopy nicht z.b. nach Druckunterbrechung wegen Papierende:
Drucker kurz Aus- und Einschalten.
Fitten eines Datensatzes mittels der Funktionen EXPONENTIAL oder
POWER LAW erfordert positive Y- bzw. X- und Y-Werte. (Notfalls mittels
EXPAND im X-SCALE Menue den dargestellten Wertebereich einschraenken).
Geht Ihnen das Programm auf die Nerven: Programm loeschen

Beispielprogramme:
==================
1) Laden Sie TEST2.DAT durch Anwahl von FILE im INPUT Menu.
   Zeicnen Sie die jaehrlichen Steuern von Hans Zahlemann durch
   Anwahl von NEW im DRAW Menue.
   Bilden Sie das jaehrliche Mittel ueber die Jahre 1978-1984 durch
   Anwahl von INTEGRATE im OUTPUT Menue. Dabei wird automatisch auch
   die gesamte Steuer fuer diesen Zeitraum berechnet.
   Waelen Sie FIT im OUTPUT Menu. Durch Anwahl von EXPONENTIAL im
   Menu FUNCTION (Anzahl der Fitparameter=2) und anschliessende Wahl
   von FIT bekommen Sie eine Ausgleichskurve ,die eine Extrapolation
   in die Zukunft bzw. Vergangenheit erlaubt (Option X -> Y).
 
   Waehlen Sie MAIN MENU und dort X-SCALE (1930-2030) sowie
   Y-SCALE (0-65000) um dem extrapolierten Verlauf Ihrer Steuer gerecht
   zu werden.Der Bildtext wird mitskaliert,aber mit der Option TEXT im
   DRAW Menue koennen Sie ihn loswerden.
   Die Option FIT im DRAW Menu zeigt den wahrscheinlichen Verlauf
   Ihrer Abgaben an Vater Staat. Die Option MAUSE im OUTPUT Menue
   gibt genauere Auskunft.
   Die Option CREATE im Menue STORE (zuvor FIT im OUTPUT Menue waehlen)
   erlaubt Ihnen diesen Verlauf als Datensatz abzuspeichern.  

2) Laden Sie TEST1.DAT und fitten Sie eine Gauss-kurve in den Peak.
   Dazu waelen Sie mittels der Option NEW im Menue WINDOW den Peak-
   bereich aus. Anshchliessend waehlen Sie die Option EXPONENTIAL im
   FUNCTION-Menue und spezifizieren die Anzahl der Fit-Koeffizienten
   # OF KOEFF. = 3.
   Die Hoehe,Breite und Position der Gausskurve erhalten Sie durch
   Anwahl der Option SCREEN bzw PRINT im OUTPUT Menue.
   Vergleichen Sie die mittlere quadratische Abweichung CHI mit dem
   Ergebnis bei Verwendung der Option GAUSS-FUNCT.
 

Viel Spass !
Wolfgang Koenig, Am Bruehl 1, 6101 Messel, Tel. 6159-1476, Dezember 86

PS. Die Anpassung der internen Hardcopy Routine an diverse Drucker
    ist sehr einfach (siehe Druckerhandbuch;Epson und IBM kompatible
    Drucker sollten problemlos funktionieren).

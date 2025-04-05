The MANDELBROT Set:




Ein Public-Domain-Programm von J. Loviscach
                               4800 Bielefeld 1
                               Tel. (0521) 88 97 81

Zweck:
Darstellung der Mandelbrot-Menge ("Apfelm„nnchen") auf dem Bild-
schirm bzw. Ausgabe auf dem Drucker NEC P6 (oder kompatiblen)
in einer Aufl”sung von 180 Punkten/Zoll. Neuer schneller Algorithmus.

Hardware:
1-MByte-Rechner/Monochrom-Monitor. Fr andere Speichergr”en mu
im Source-File die Bildschirmadresse angepat werden.




Folgende Files sind Bestandteil dieses Pakets:
          
MANDELBR.C          Quelltext (Megamax-C)
MANDELBR.PRG        compiliertes und gelinktes Programm
                    (lauff„hig)
MANDELBR.RSC        Resource-File
MANDELBR.DEF        Namensfile fr RCP
MANDELBR.H          Header mit Definitionen zum Resource
LIES.DAS            dieser Text




Die Bedienung des Programms erfolgt durch Klicken auf die am
rechten Bildschirmrand plazierten Buttons ->BUFFER, PRINT,
RECALC, ADD und EXIT. Buttons, die im momentanen Betriebszustand
nicht bet„tigt werden k”nnen, werden mit heller Beschriftung dar-
gestellt.

Durch den Button ->BUFFER werden die zwei Hauptbetriebszust„nde
des Programms umgeschaltet. Im Normalzustand ist dieser Button
ausgeschaltet; dann wird die Zeichnung direkt (und in hoher Ge-
schwindigkeit) auf dem Bildschirm erzeugt. Ist dieser Button
angeschaltet, erfolgt das Zeichnen mit hoher Aufl”sung (und 
entsprechend niedriger Geschwindigkeit) in einem Zwischenspeicher, 
dessen Inhalt aber gleichzeitig mastabgerecht auch auf dem Bild-
schirm dargestellt wird.

PRINT bewirkt das Ausdrucken des gerade im Zwischenspeicher be-
findlichen Bildes.

RECALC zeichnet nach L”schen des Bildspeichers die durch Bildaus-
schnitt, Zeichentiefe und Rahmenzahl (neu) festgelegte Figur.

ADD wirkt wie RECALC, l”scht aber den Bildspeicher nicht.

Ist der Zeichenvorgang beendet, wandelt sich der Schrifttyp der
READY-Box oben rechts von hell nach dunkel.

Der Zeichenvorgang kann jederzeit durch (ggf. l„ngeres) Drcken
der Tasten Control, Shift (links) und Alternate abgebrochen
werden.

EXIT bewirkt die Rckkehr zum Desktop.

Der Vergr”erungsausschnitt wird mit der GEM-Rubberbox gew„hlt,
d. h. man bewegt die Maus im dargestellten Bild zum linken oberen
Eckpunkt des Auschnitts, den man vergr”ern will; dann drckt man
die linke Maustaste, zieht nach rechts unten das dem gewnschten
Ausschnitt entsprechende Rechteck auf und l„t die Maustaste los.
Mit dem Button LARGE kann man auf die Maximalgr”e des Ausschnitts
zurckschalten.

Die Zeichentiefe DEPTH wird durch Anklicken der Pfeile rechts und
links neben der Anzeige des Zahlenwerts eingestellt.

Entsprechendes gilt fr die Anzahl der Rahmen # OF FRAMES. Diese 
gibt an, wieviele Umrilinien der Figur gezeichnet werden.




Anmerkungen:

Empfehlenswert ist, sich erst im normalen Modus eine Zeichnung
mit allen ihren Parametern (Tiefe etc.) zusammenzustellen, dann
auf ->BUFFER umzuschalten und RECALC auszufhren, um das Bild aus-
drucken zu k”nnen.

Der Ausdruck benutzt fast die gesamte Fl„che eines DIN-A4-Blattes,
daher sollte ein Einzelblatt sehr hoch eingespannt werden, um zu
gew„hrleisten, da die gesamte Zeichnung darauf Platz hat. Ggf.
l„t sich im Quelltext das Format des Ausdruck durch die beiden 
Konstanten ROWS und COLUMNS „ndern.

Zu Beginn des Zeichenprogramms wird zufallsgesteuert ein innerer
Punkt der Figur gesucht. Wird ein solcher nicht gefunden (z. B.
weil die Fl„che sehr klein ist), gibt das Programm eine ent-
sprechende Meldung. Die gewnschte Zeichenfunktion kann dann
noch einmal angew„hlt werden.

Der im Programm benutzte Algorithmus findet bei nicht einfach
zusammenh„ngenden Figuren nicht alle Umrilinien oder zeichnet
z. B. nur einen Punkt und bricht dann ab. In diesem Fall kann man
ADD benutzen, um das Bild zu erg„nzen. 
  
Durch kurzes Drcken von Control/Shift/Alternate kann man beim 
Zeichnen einzelne Umrilinien berspringen.  







Anleitung zum 
 

     III  FFF   SS        EEE  DD   III  TTT   O   RR
      I   F    S          E    D D   I    T   O O  R R       VERSION
      I   FFF   S    ===  EEE  D D   I    T   O O  RR
      I   F      S        E    D D   I    T   O O  R R        1 . 0
     III  F    SS         EEE  DD   III   T    O   R R


  Autoren:                   Rainer Urian
                             Manfred Bertuch
                             Michael Herrmann


Dieses Programm darf in der vorliegenden Form frei kopiert werden, es wird 
auf jegliche urheberrechtlichen Ansprche verzichtet.

Teile der nachfolgenden Erl„uterung wurden ( mit freundlicher  Genehmigung 
des  Heinz  Heise  Verlags )  einem  Artikel  der  "c`t"  11/88,S.166  ff. 
entnommen. 
__________________________________________________________________________

 S o   g e h t ' s   a u c h    ( von Rainer Urian, Manfred Bertuch, M.H.)
=============================

            Fraktale erzeugen mit iterierten Funktionssystemen

     Von  Zeit zu Zeit erweisen sich Ergebnisse aus den  Studierstuben 
     der Mathematiker als h”chst ntzlich und anwendbar, beispielswei- 
     se  in der Computergrafik.  Dort bemht man sich nach wie vor  um 
     m”glichst  echt und natrlich wirkende Darstellungen,  wofr sich 
     die von B.B.Mandelbrot erforschten Fraktale besonders gut eignen.
     Diese  Gebilde lassen sich auch mit iterierten  Funktionssystemen 
     erzeugen,  was  gegenber  der von Mandelbrot  benutzten  Methode 
     einen wichtigen Vorteil bietet.

Fraktale  Objekte  haben  sich  in  der  Computergrafik  bew„hrt,  um  die 
zahlreichen  Strukturen  der Natur nachzubilden.  In der Natur zeigt  sich 
n„mlich  ebenfalls  das  Prinzip der  Selbst„hnlichkeit,  das  auch  allen 
Fraktalen  gemein  ist.  Ein Farnblatt zeigt diese  Eigenschaft  besonders 
deutlich.  Oberfl„chlich betrachtet, besteht es aus einem leicht gebogenen 
Stiel, an dem links und rechts eine Reihe von "Bl„ttern" h„ngen. Nimmt man 
nun  ein  solches Blatt genauer unter die Lupe,  erkennt man,  da  dieses 
Blatt wiederum aus einem leicht gekrmmten Stil besteht,  an dem links und 
rechts  viele Bl„tter h„ngen...  Theoretisch kann man diesen Proze unend-
lich oft wiederholen,  jedoch stoppt die Natur aus praktischen Grnden bei 
einer bestimmten Rekursionstiefe. Auerdem wiederholt sie Struktuten nicht 
mit mathematischer Genauigkeit,  sondern baut kleine, zuf„llige Streuungen 
ein.

Diese Eigenschaft natrlicher Gebilde kann man sich zunutze machen, um sie 
mittels Computergrafik zu simulieren.  Man mu nun nicht mehr alle Details 
einzeln  eingeben,   sondern  kommt  mit  sehr  wenigen  Daten  und  einer 
besonderen Konstruktionsvorschrift aus. Mit dieser Methode brauchen Bilder 
nicht mehr Pixel fr Pixel beschrieben zu werden; es gengt, die implizite 
Form  der Selbst„hnlichkeit in eine mathematische Form zu bringen,  was zu 
einer gewaltigen Reduzierung an Rechenaufwand und Speicherplatz fhrt.

 M e t h o d e   M a n d e l b r o t

Benoit B.  Mandelbrot,  der bekannteste Fraktal-Forscher, bedient sich der 
Initiator-Generator-Methode,  um  Fraktale zu beschreiben und zu erzeugen. 
Dieses Verfahren wurde bereits in c`t 5/88 ausfhrlich vorgerstellt, daher 
folgt hier nur noch eine kurze Zusammenfassung.

Der  Generator  ist  in der Regel eine Vektorkette  aus  einer  bestimmten 
Anzahl  (n)  von  Teilstrecken,  die  in etwa die  Struktur  des  Fraktals 
bestimmt. Wichtig ist, da die einzelnen Teilstrecken kleiner sind als die 
Luftlinie  von Anfangs- und Endpunkt des Generators,  da das Fraktal sonst 
unendlich gro wrde.  Der Initiator ist im einfachsten Fall eine Strecke, 
die das Ganze in Gang bringt.

Im  ersten Schritt der Konstruktion ersetzt der Generator  den  Initiator. 
Der Generator wird dabei so skaliert,  rotiert und verschoben,  da Start- 
und  Endpunkt  des Generators mit dem Start- und Endpunkt  des  Initiators 
zusammenfallen. Es entstehen n neue Teilstrecken.

Im zweiten Schritt werden alle Teilstrecken des vorhergehenden  Generators 
wiederum durch den Generator ersetzt, als w„ren sie jetzt die Initiatoren. 
Diese  Rekursion wird theoretisch unendlich oft wiederholt.  In der Praxis 
bricht man den Proze ab,  wenn das Fraktal den gewnschten detailreichtum 
zeigt. 

Dieses Verfahren hat nun aber einen entscheidenden Nachteil; man sieht dem 
Initiator  und dem Generator nicht so ohne weiteres die Form des  Fraktals 
an.  Meist  bedient man sich seiner Intuition und eines "trial and error"-
Verfahrens, um ein gewnschtes Gebilde zu erhalten.

 F ra k t a l e   n a c h   M . F . B a r n s l e y

Die  Methode  der iterierten Funktionssysteme (IFS) l”st  dieses  Problem, 
indem sie einfach den umgekehrten Weg geht.  Hat man die Art und Weise der 
Selbst„hnlichkeit eines Gebildes festgestellt,  so kann man mit einem fast 
rein mechanischen Verfahren ein System von Funktionen bestimmen, das genau 
dieses Gebilde erzeugt.

Ein solches Funktionssystem besteht aus mehreren affinen  Transformationen 
T#1 ... T#n.  Unter  einer affinen Transformation versteht man eine Abbil-
dung,  die  irgendein  Gebilde  dreht,  staucht,  vergr”ert,  verschiebt, 
verzerrt oder eine beliebige Kombination aus diesen Vorg„ngen durchfhrt. 
Sechs Variablen ( a bis f ) legen eine solche Transformation im zweidimen-
sionalen  Raum eindeutig fest ( siehe unter "Affine  Transformationen"  ). 
Schlielich  bekommt jede Transformation des Funktionensystems  noch  eine 
Wahrscheinlichkeitszahl zugewiesen,  die von der relativen Gr”e der Figur 
abh„ngt  und damit bestimmt,  wie wichtig diese Transformation fr das  zu 
erzeugende Bild ist. Ab jetzt ist der Computer an der Reihe.

Der erste Schritt besteht in der Auswahl eines beliebigen Startpunktes und 
einer Transformation gem„ den vergebenen  Wahrscheinlichkeitszahlen.  Der 
Startpunkt  wird nun dieser Transformation unterworfen und gezeichnet.  Im 
zweiten  Schritt ist wieder eine Transformation zuf„llig  auszuw„hlen  und 
auf  den  neuen Punkt anzuwenden.  Dieser Proze wiederholt sich  beliebig 
oft.  Insgesamt  ist  dieser Vorgang eine Komposition oder  Iteration  von 
Transformationen.   Er  bewirkt,   da  sich  anfangs  scheinbar  zuf„llig 
verteilte  Punkte  immer  mehr verdichten und das  fraktale  Bild  langsam 
deutlich hervortritt. Es sieht so aus, als wrde das Gebilde "hergebeamt", 
und  wer  wei,  vielleicht  kann  eines  Tages  selbst  Materie  per  IFS 
beschrieben werden.

Je  mehr Iterationen durchgefhrt werden,  um so klarer wird das Bild.  Es 
ist allerdings ratsam, die ersten paar Iterationen (hier zwanzig) nicht zu 
zeichnen, da sich der Anfangspunkt eventuell nicht auf der Figur befindet. 
Weil  die  Transformationen  aus  kontraktiven  Transformationen  bestehen 
sollten,  wird jeder Startpunkt,  der auerhalb der Figur liegt, mit jeder 
Iteration  an diese herangezogen.  Nach einigen Iterationen liegt er  dann 
innerhalb  der  Figur.  Mittels IFS erzeugte Figuren heien  deshalb  auch 
Attraktoren (lat. "attrahere" = anziehen). 

 C o l l a g e n - T h e o r e m

Auf  den ersten Blick scheint es ziemlich kompliziert zu sein,  die  rich-
tigen Transformationen zu finden, um ein bestimmtes Bild zu approximieren. 
Doch glcklicherweise gibt es dafr einen systematischen Weg.

Man mu nur erkennen,  worin die Selbst„hnlichkeit besteht und wie es sich 
aus selbst„hnlichen Teilen zusammensetzt.  Das ist bei einfachen Fraktalen 
besonders leicht sichtbar,  beispielsweise bei der Sierpinsky-Pfeilspitze. 
Man kann sich vorstellen,  da dieses Fraktal aus der Vereinigung von drei 
Unterbildern,  eben  drei  kleineren Pfeilspitzen,  entstanden ist.  Jedes 
Unterbild  ist  nun  wiederum aus drei Unterbildern  entstanden,  und  so 
weiter...  Mit  drei  affinen  Transformationen kann man  die  Sierpinsky-
Pfeilspitze  auf  ihre  drei  unmittelbaren  Unterbilder  abbilden.  Diese 
Methode  funtioniert,  da  die Sierpinsky-Pfeilspitze praktisch aus  ihren 
drei  Unterbildern  zusammengekittet  ist.  Sie basiert auf  dem  Collage-
Theorem.

Auch sehr komplexe Bilder,  etwa Fotografien von Landschaften,  k”nnen als 
Fraktal oder als Zusammensetzung von Fraktalen aufgefat werden, wenn ihre 
Bestandteile  Selbst„hnlichkeit  aufweisen.  Da in den Parametern des  IFS 
nach wie vor die vollst„ndige Bildinformation enthalten ist, stellt dieser 
Parametersatz  eine Kodierung des Bildes dar.  Gemessen an der  Datenmenge 
des  Bildes  selbst,  ist  die IFS-Kodierung gleichzeitig  eine  gewaltige 
Komprimierung  - in Einzelf„llen um Faktoren bis zu 10.000 und  mehr  [1]. 
Dieses  Verfahren  bekommt  daher praktische Bedeutung,  wenn  es  um  die 
Archivierung oder šbertragung von Bildern geht.  Nachteilig ist allerdings 
der hohe Rechenzeitbedarf, besonders bei der Bestimmung der IFS-Parameter. 
Bei komplexen Szenen ben”tigt ein 68020-System Zeiten um 100 Stunden. M.F. 
Barnsley  hat inzwischen eine Firma gegrndet,  die Systeme mit spezieller 
Hardware fr die schnelle IFS-Kodierung auf den Markt bringen will.

 I F S - E d i t o r 

Das Programm erlaubt die Erzeugung beliebiger IFS-Bilder mit maximal zw”lf 
Transformationen, wurde in CCD Pascal Plus geschrieben und l„uft sowohl in 
hoher,  wie  auch in mittlerer Bildschirmaufl”sung.  Es gibt zwei M”glich-
keiten,  die Transformationen einzugeben. šber den Menpunkt "IFS-Daten" 
lassen  sich  die Koeffizienten a bis f direkt eingeben  oder  modifizieren. 
Durch "Reset" l„t sich die gesamte Transformationstabelle l”schen und die 
Default-Parameter   werden   wieder  hergestellt.   Unter  dem   Menpunkt 
"Fraktale"  sind fnf Beispiele anw„hlbar (die  entsprechenden  IFS-Trans-
formationen werden angezeigt und mssen mit "Okay" best„tigt werden).

Man   kann  sich  die  Transformationskoeffizienten  vom   Computer   ber 
"Koordinaten"  auch berechnen lassen.  Dazu sind zun„chst die  Koordinaten 
von drei Punkten in die erste Zeile (Nr.0) des Dialogs zu schreiben.  Aber 
Achtung,  die drei Punkte dieses Trippels drfen auf keinem Fall auf einer 
Geraden  liegen.  Der  Rechner ermittelt die Transformationen durch  L”sen 
eines  Gleichungssystems,  und dieses h„tte dann keine eindeutige  L”sung. 
Danach werden die korrespondierenden drei Punkte des ersten Unterbildes in 
die  zweite Zeile geschrieben.  Die drei Punkte des zweiten Unterbildes in 
die dritte Zeile und so fort...

Wenn  alle Transformationen auf diese Weise festgelegt wurden,  klickt man 
das "Okay"-Feld an.  Der Computer berechnet nun die Transformationskoeffi-
zienten  a bis f.  Diese k”nnen im bekannten Dialog,  der danach angezeigt 
wird,  noch  von  Hand ver„ndert werden.  Jetzt berechnet der ST die Wahr-
scheinlichkeitszahlen  fr die Transformationen.  Er sttzt sich dabei auf 
die Determinante aus den ersten vier Parametern,  was brauchbare Resultate 
liefert. 

Per Menpunkt "Grafik" wird das Zeichnen begonnen.  Um die Figur m”glichst 
ideal  auf dem Bildschirm zu plazieren,  kann sie mit den Angaben  X-Scale 
und  Y-Scale  in beiden Richtungen gedehnt oder gestaucht,  sowie  mit  X-
Offset  und  Y-Offset verschoben werden.  Nun mu nur noch die Anzahl  der 
Iterationen  (gleich Menge der Schleifendurchl„ufe) eingeben werden.  Wenn 
die  Wahrscheinlichkeiten fr alle Transformationen gleich sind,  ist auch 
eine  rekursive  Berechnung  des Bildes m”glich.  Dadurch  wird  das  Bild 
gleichm„iger  ausgefllt.  

Bei  der Eingabe der Rekursionstiefe sollte man bedenken,  da die  Anzahl 
der  Punkte  exponentiell mit der Tiefe w„chst  (Default  beachten).  Beim 
"Testen"  eigener Fraktale sollte man also mit einer geringen  Rekursions-
tiefe (z.B.fnf), bzw. wenigen Iterationen (z.B. dreitausend) beginnen, da 
aus  Geschwindigkeitsgrnden  auf  eine  Abbruchm”glichkeit  w„hrend   des 
Zeichnens  verzichtet  wurde.  Des weiteren ist noch zu beachten,  da  es 
manchmal bei eigenen Versuchen zu Programmabstrzen durch Fliekommafehler 
(o.„.)  kommen  kann.  Man sollte vor dem Ausprobieren besser  schon  eine 
gewisse  Vorstellung  davon  haben,  was  die  eigebenen  Transformationen 
bewirken  und  darauf  achten,  da das Fraktal  nicht  unendlich  w„chst, 
sondern sich aus Teilen zusammensetzt, deren Gr”e (siehe Beispiele) gegen 
Null geht.
__________________________________________________________________________

 A f f i n e   T r a n s f o r m a t i o n e n 

Geometrisch  betrachtet bildet eine affine Transformation eine  Punktmenge 
durch  eine beliebige Kombination aus Drehung,  Streckung und Verschiebung 
auf  eine andere Punktmenge ab.  Das Typische einer solchen Abbildung ist, 
da  sie  eine  Figur nicht bis  zur  Unkenntlichkeit  entstellt,  sondern 
„hnlich aussehende Abbilder erzeugt ( affin = verwandt,  „hnlich ). Grund-
eigenschaften bleiben erhalten,  ein Dreieck bleibt ein Dreieck.  Im zwei- 
dimensionalen  Raum  hat eine solche Transformation T(x,y) =  (x',y')  die 
Form                
          x' = ax + by + e
          y' = cx + dy + f .

Zur  Transformation  irgendeiner Figur ist im Prinzip jeder  ihrer  Punkte 
durch  die Abbildungsvorschrift zu schleusen.  Die Matrix mit den Werten a 
bis d bewirkt dabei eine Dehnung und eine Verzerrung,  die Koeffizienten e 
und f eine Verschiebung (Translation). Zur Abbildung eines Dreiecks gengt 
es bereits,  die drei Eckpunkte zu transformieren,  da diese das transfor-
mierte Dreieck eindeutig festlegen.

 U n b e k a n n t e   K o e f f i z i e n t e n

Wie  kann man nun aber die Koeffizienten a bis f bestimmen,  wenn man eine 
Figur  F  in  eine  Figur F' transformierne will?  An  den  beiden  vorher 
beschriebenen Dreiecken ist dies besonders anschaulich darstellbar.

Da   sechs   unbekannte  Parameter  gesucht  sind,   ben”tigt  man   sechs 
Gleichungen,  um zu einer eindeutigen L”sung zu gelangen.  Dazu greift man 
sich drei Kordinaten der Figur F und die drei korrespondierenden Koordina-
ten  der  Figur  F'  heraus.  Bei einem Dreieck bieten  sich  hierfr  die 
Eckpunkte PQR und P'Q'R' an. Die sechs Gleichungen lauten dann:

          P'x = Px*a + Py*b + e
          P'y = Px*c + Py*d + f
          Q'x = Qx*a + Qy*b + e
          Q'y = Qx*c + Qy*d + f
          R'x = Rx*a + Ry*b + e
          R'y = Ry*c + Ry*d + f

Dieses  Gleichungssystem  l„t sich nun  mit  dem  Determinanten-Verfahren 
bequem auf dem Rechner l”sen.  Mehr Punktepaare sind nicht n”tig,  da jede 
Transformation  durch drei Koordinaten und deren Bilder eindeutig  festge-
legt ist.

 W a h r s c h e i n l i c h k e i t s z a h l e n

Jeder  Transformation  Ti wird eine bestimmte  Wahrscheinlichkeitszahl  Pi 
zugeordnet.  Diese hat keinen Einflu auf die Gestalt des Bildes,  sondern 
auf  die  Geschwindigkeit und Gleichm„igkeit,  mit der es  erzeugt  wird. 
Jeder Wert pi sollte gleich dem Verh„ltnis aus der Gr”e des von der zuge-
h”rigen  Transformation erzeugten Unterbildes zur Gesamtgr”e  des  Bildes 
sein. Die Summe aller p-Werte ergibt dann 1.

Da  das Verh„ltnis der Fl„cheninhalte von Figur und  transformiertem  Bild 
gleich der Determinante der Transformationsmatrix ist,  lassen sich die pi 
einfach berechnen:

                [  a    b  ]
          det ( |          | )  =  a*d - b*c
                [  c    d  ]

                  det ( Ti )
          p  =  ------------- ,   k  î  { 1...n }
           i     ä |det(Tk)|

Wenn  die  Determinante den Wert 0 ergibt,  so ist es sinnvoll,  ihr einen 
kleinen Wert ungleich 0 (z.B. 0.01) zuzuweisen, da sonst die entsprechende 
Transformation  berhaupt  nich ausgefhrt wrde.  Dieser Fall tritt  dann 
auf,  wenn eine Transformation das Bild nur auf eine Gerade abbildet (z.B. 
beim Farnblatt).
__________________________________________________________________________

 L i t e r a t u r

[1] M.F.Barnsley, A.D.Sloan: "A better way to kompress images", Byte 1/88, 
    S.215
[2] M.F.Barnley,  V.Ervin,  D.Hardin, J.Lancaster: "Solution of an inverse 
    problem for fratals and other sets",  Proceedings of the National Aca-
    demy of Science, Vol.83, 1/86, S.1975-1977
[3] M.F.Barnley,  S.Demko:  "Iterated function systems and the global con-
    struction of fractals", The Proceedings of the Royal Society of London
    A399, 1985, S.243-275



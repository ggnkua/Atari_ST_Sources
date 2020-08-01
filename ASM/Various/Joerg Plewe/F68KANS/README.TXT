F68KANS
ein Forthsystem fr 680x0-Computer


* experimentelle Ausgabe *



Wichtiger Hinweis:

Bei F68KANS handelt es sich um ein Low-Cost-Produkt, das von versierten 
Entwicklern in Gemeinschaftarbeit erstellt wurde. Dabei wurde versucht, vor allem 
eine m”glichst groe Betriebsicherheit und Zuverl„ssigkeit zu erzielen. Sie als 
Anwender und Programmierer k”nnen sicher sein, trotz Low-Cost High-Tech zu 
bekommen.
Trotzdem: F68KANS ist in der Form, wie es vor Ihnen liegt, kein professionelles 
Produkt (im Sinne des Wortes, nicht im meist benutzten Sinne). Professionelle 
Produkte k”nnen (und sind auch manchmal) besser gepflegt und ausgereifter, besser 
dokumentiert und untersttzt sein. Professionelle Produkte dienen der Freude der 
Anwender, F68KANS der Freude seiner Entwickler.
Wenn Sie also etwas vermissen sollten, schieben Sie es nicht auf die Sprache Forth, 
sondern auf deren Implementation. Wenn Ihnen Support, eine durchg„ngige Linie und 
garantierte Best„ndigkeit wichtiger sind als niedriger Preis und eine paar freakige 
Features, sollten Sie sich an die Profis wenden, die auch hier in Deutschland 
vertreten sind.
Ich will hier keine Werbung fr bestimmte Unternehmen machen, aber wenn Sie mich 
kontaktieren, werde ich Ihnen mit den n”tigen Verbindungen aushelfen.



Kontaktadresse:

Dipl. Phys. J”rg Plewe
Haarzopfer Str. 32
4330 Mlheim an der Ruhr
0208/497068
joerg.plewe@mpi-dortmund.mpg.de



Um was geht's?

F68KANS ist ein zwischen 680x0-Rechnern bin„r portierbares Forthsystem der 
modernen Art.
Diese experimentelle Ausgabe fr Systementwickler enth„lt nur die Anbindung an die 
Rechner der Atari-Reihe, auf denen das System entstanden ist. Die Systemanbindung 
ist sehr weitreichend und weitgehend, aber wahrscheinlich nicht vollst„ndig, auf 
andere Maschinen bertragbar. Damit ergibt sich das Problem, da sich die 
Quelltexte nicht einfach nach ihrer Portierbarkeit einordnen lassen, da viele 
manchmal portierbar sind, und manchmal eben nicht. Die beschriebene Installation 
ergibt ein auf Atari-Rechnern lauff„higes und generierbares System, die fr weitere 
Implementationen als Modell dienen sollen.



Installation:

Kopieren Sie einfach das Verzeichnis F68KANS an eine beliebige Stelle in Ihren 
Dateibaum oder lassen Sie einfach alles auf der Diskette.



Was haben Sie bekommen?
Was sollten Sie haben?

Dieser Absatz besch„ftigt sich mit dem Lieferumfang und was wozu da ist. Im 
Basisverzeichnis F68KANS befinden sich nur wenige Dateien und einige weitere 
Verzeichnisse, die hier erl„utert werden sollen. In den jeweiligen Verzeichnissen 
befinden sich wiederum Dateien mit dem Namen README.TXT, die dann eine 
detailiertere Beschreibung enthalten.

Ich empfehle ausdrcklich, eigene Quelltexte NICHT im Verzeichnis F68KANS 
unterzubringen, damit sich dieses Verzeichnis mit einem neuen Systemrelease einfach 
auswechseln l„t. Diese Aussicht sollten Sie auch im Hinterkopf haben, wenn Sie 
erw„gen, Worte des Systems, die nicht dem Standard oder den ausgewiesen 
systemabh„ngigen Teilen zugeh”ren, in eigenen Applikationen zu benutzen.
DIESE WORTE SIND IM NCHSTEN RELEASE VIELLEICHT NICHT MEHR DABEI!



Dateien in F68KANS:

	README.TXT
Hallo, ich bin's!

	manchmal: F68KANS.IMG
Dies ist ein Systemimage. Es enth„lt das eigentliche Forthsystem 
in bin„rer Form. Meist ist es aus praktischen Grnden dort 
abgelegt, wo das System zum letzten mal generiert wurde, z.B. 
unter ATARI. Trotzdem ist diese Datei immer vollst„ndig 
systemunabh„ngig!


Verzeichnisse in F68KANS:

	KERNEL
Dieses Verzeichnis enth„lt alle Assemblerquelltexte, die zur 
Generierung eines Basisimagefile notwendig sind. Die bereits 
erw„hnte Datei f68kans.img ist daraus erstellt worden. Die 
Generierung kann systemabh„ngige Schritte enthalten!!
	
	SYSFTH
Hierin sind all die Forthquelltexte enthalten, die notwendig sind, 
um aus dem assemblergenerierten Kernelteil einen vollst„ndigen 
ANSI-Kernel zu erstellen. Es l„t sich nicht vermeiden, da 
innerhalb dieser Definitionen auch Nicht-ANSI-Worte erzeugt 
werden. Diese drfen aber unter KEINEN UMSTNDEN in 
eigenen Forth-Programmen benutzt werden, da dies unmittelbar 
dazu fhrt, da das Programm nicht mehr standardkonform ist.
Vorsicht: einige der Quelltexte k”nnen systemabh„ngig sein. Da es 
ich um Systemquellen handelt, bedeutet das, da solche Quellen 
bei einer SYSTEMPORTIERUNG bearbeitet werden mssen. Der 
Anwender portiert in der Regel aber nicht das System, sondern 
eine Anwendung auf ein anderes System.

	APPFTH
Hier stehen all die Quelltexte, die auf dem ANSI-Kernel, der aus 
den Verzeichnissen KERNEL und SYSFTH hervorgeht, basieren 
und noch dem System bzw. der Entwicklungsumgebung 
zuzuordnen sind (z.B. Anbindung von Grafikfunktionen). Diese 
Quellen sind natrlich z.T. systemabh„ngig. Hier hat der 
Programmierer zu entscheiden, ob er systemabh„ngige Worte in 
seiner Applikation benutzen m”chte, da diese ebenfalls 
systemabh„ngig ist.
Die nicht systemabh„ngigen Definitionen basieren direkt auf dem 
Standard und sollten deshalb bei einer Portierung auch auf 
anderen ANSI-Kerneln benutzbar sein.



	TST
Diese Quelltexte dienen dem Test von Forthworten des Systems 
(und nicht Ihrer Anwendung!). Damit sind sie auch sch”n als 
Anwendungsbeispiele oder Demos einzusetzen.

	ATARI
enth„lt die Programme, die fr die Rechner der Atari-Reihe 
spezifisch sind. Dies ist in erster Linie natrlich der Systemlader 
mit seinen Vorrichtungen zur Anbindung des Forthsystems an das 
Betriebsystem. Auerdem sind hier Generierungshilfen wie z.B. 
Projektbeschreibungsfiles oder Dateifilter abgelegt.






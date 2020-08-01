F68KANS
ein Forthsystem fr 680x0-Computer


* experimentelle Ausgabe *


Hinweise zur Atari-Installation:

Diese Datei bschreibt in groben Zgen die F68KANS-Implementation fr die Rechner 
der Atari-Reihe.
F68KANS wurde auf diesen Rechnern erstellt (zuletzt: Atari TT030). Dabei kamen 
Entwicklungstools zum Einsatz, die fr den Atari eine ungew”hnliche Qualit„t erreicht 
haben. Mein Dank gilt deshalb den Autoren des PureC Entwicklungssystems, die 
hervorragende Arbeit geleistet haben.


Das wichtigste: der Systemstart

Um F68KANS zu starten, tun Sie das Naheliegende: starten Sie das Programm 
F68KANS.TTP.
Es wird eine Dialogbox angezeigt, die Sie zur Angabe einer Kommandozeile animiert. 
Sie k”nnen dort verschiedene Dinge eintragen:

	Filenamen
Diese Filenamen bezeichnen Quelltextdateien. Findet der Lader 
(F68KANS.TTP) ein solches Argument, wird der Inhalt der 
entsprechenden Datei in die Standardeingabe von F68KANS 
'eingeh„ngt'. Das bewirkt, da diese Datei bereits beim 
Systemstart ausgefhrt wird.
Es k”nnen mehrere Filenamen in der Kommandozeile angegeben 
werden.

	-fFilename
Wenn viele Dateinamen angegeben werden sollen, kann es 
vorkommen, da der Platz, den TOS fr eine Kommandozeile zur 
Verfgung stellt, nicht ausreicht. Unbemerkte Fehlfunktion ist die 
direkte Folge, da die letzten Dateien dann schlichtweg nicht 
geladen werden.
Fr diesen Fall erm”glicht es die '-f' Option, die notwendigen 
Dateinamen in eine eigene Datei einzutragen. Diese Datei wird 
hinter '-f' (ohne Leerzeichen) angegeben. Beispiele fr solche 
Dateien sind SYSSRC und APPSRC.

	-cFilename
Der Lader (F68KANS.TTP) l„dt bei seinem Start eine 
Konfigurationsdatei, in der der Name des bin„ren Systemabbildes 
sowie die Speicherplatzgr”en fr Code und Daten angegeben 
werden. Wenn die '-c' Option nicht angegeben ist, sucht der 
Lader nach der Datei F68KANS.CFG.
Um andere Dateien zur Konfiguration heranziehen zu k”nnen, 
kann ihr Name hinter '-c' (ohne Leerzeichen) angegeben werden.

	-v
Normalerweise gibt F68KANS alle Eingaben, die durch den 
Anwender gemacht werden, direkt auf dem Bildschirm aus. Wenn 
Dateinamen in der Kommandozeile (oder in einer '-f' Datei) 
angegeben werden, so wrde, da F68KANS diese Dateien als 
ganz normale Eingabe auffat, deren gesamter Inhalt auf dem 
Bildschirm ausgegeben. Um diesen l„stigen Umstand zu 
unterbinden, h„ngt der Lader fr die Zeit des Lesens aus der 
Datei die Ausgabe vollst„ndig ab. Damit erscheinen natrlich auch 
Fehlermeldungen nicht. Normalerweise macht das nichts, da in der 
Kommandozeile nur getestete Quelltexte angegeben werden. In 
Ausnahmef„llen soll das Listing aber trotzdem ausgegeben 
werden. Dazu genau dient die '-v' Option.









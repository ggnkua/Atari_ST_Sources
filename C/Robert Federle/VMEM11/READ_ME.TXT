
                                  VMEM V1.1

               Virtuelle Speicherverwaltung fr alle Atari Rechner

                            ½ 1990 Robert Federle


Grunds„tzliches:
================

Was ist ein virtueller Speicher?
--------------------------------

Viele kennen das Problem: da besitzt man einen Rechner mit "nur" 512 KByte
und dennoch laufen einige Programme nur mit mindestens einem oder mehreren
MByte. Meistens liegt dies daran, da diese Programme s„mtliche Daten im
Speicher halten. So legen die meisten Zeichenprogramme einen UNDO-Puffer an,
der meist genau so gro ist wie die eigentliche Zeichenfl„che. Da eine DIN A4
Seite (ungepackt, einfarbig) 950 KByte gro ist, wird selbst bei einem Mega
ST 2 mit 2 MByte Speicher das Arbeiten verhindert. Zwar kann man inzwischen
bei den meisten Programmen diesen UNDO-Puffer weglassen, doch was macht man,
wenn man ihn einmal braucht?? Dauerndes Speichern auf der Platte ist auch
nicht sinnvoll, denn damit bernimmt man selbst die Arbeit, die eigentlich
der Computer machen sollte.

Aus diesem Grund wurde das Programm VMEM geschrieben. Mit VMEM ist es nun
m”glich, groe Datenmengen statt im Hauptspeicher auf der viel gr”eren Platte
zu speichern, wobei man mit speziellen Befehlen auf einfachste Art und Weise
darauf zugreifen kann. Vor der Benutzung des Speichers mu man ihn anfordern,
danach mu man ihn wieder freigeben. Dies ist beim normalen Speicher gleich.
Der einzige Unterschied besteht darin, da der Hauptspeicher immer am gleichen
Platz ist, wohingegen man auf den virtuellen Speicher nur durch ein "Fenster",
dem Datencache, zugreifen kann. Dieses "Fenster" mu vor dem Zugriff mittels
einer speziellen Funktion (VM_ADDRESS) auf den gewnschten Speicherbereich des
virtuellen Speichers eingestellt werden. Erst danach kann auf man die Daten,
die nun im Cache liegen, zugreifen und diese ver„ndern. Man mu diese Daten
jedoch nicht selbst zurckschreiben, da dies die "intelligente" Verwaltung
des Caches bernimmt.

Was ntzt mir ein virtueller Speicher?
--------------------------------------

Falls Sie ein Anwender sind und ein Programm bekommen, das VMEM untersttzt,
so sind Sie in der Lage, Datenmengen zu handhaben, die gr”er als Ihr Speicher
sind. Somit k”nnen selbst Besitzer von 1 MByte und weniger eine DIN A4-Seite
von 300 DPI bearbeiten.

Als Programmierer gibt es mehrere Einsatzgebiete fr VMEM. Den wohl sinnvoll-
sten Einsatz bieten wohl die Mal- und Zeichenprogramm, die in der Lage sind,
groe Vorlagen (z.B. von Scannern) zu bearbeiten. Man sollte aber nicht nur
den UNDO-Puffer in den virtuellen Speicher verlagern, denn dank der hohen
šbertragungsgeschwindigkeiten der meisten Platten kann man selbst groe Bilder
flieend scrollen (siehe VMEMDEMO).

Aber auch in Sound-Sampler kann man VMEM verwenden. Zwar kann man die Daten
nicht vom virtuellen Speicher lesen und gleichzeitig ausgeben, jedoch k”nnen
einmal aufgenommene Samples mit Hilfe von VMEM auf die Platte ausgelagert und
bei Bedarf wieder eingeladen werden. Da die meisten Platten mehr als 500 KByte
pro Sekunde bertragen, dauert dies im schlimmsten Fall  3-4 Sekunden.

Man mu VMEM aber nicht nur bei Datenmengen verwenden, die mehrere MByte be-
tragen. Selbst bei einem 100 KByte-Block, den man auf die Platte ausgelagert
hat, spart man wichtigen Hauptspeicher. Natrlich ist es in diesem Fall un-
sinnig, einen Cache anzulegen, der gr”er als 100 KByte ist. Hier wrde auch
ein 10 KByte-Cache reichen.

Das beigefgte VMEMDEMO zeigt eine einfache Anwendung. Hierbei wird eine zuvor
gew„hlte GEM-IMG-Datei in den Hauptspeicher eingelesen, in den virtuellen
Speicher entpackt und anschlieend gescrollt. Das Entpacken dauert ca. 10 mal
l„nger als blich. Das Scrollen hingegen, das waagrecht mit 16 Bit und senk-
recht mit 16 Zeilen erfolgt, ist nur um den Faktor 3 bis 4 langsamer als bei
vergleichbaren Programmen. Zudem ergibt sich bei dem horizontalen Scrolling
kein einziger Zugriff auf die Platte, obwohl jeweils 32 KByte aus dem "Fenster"
herauskopiert werden. Der Algorithmus, der in der Funktion VM_ADDRESS steckt,
ist soweit optimiert, da selbst bei groen "Sprngen" im virtuellen Speicher
nur die Seiten zurckgeschrieben werden, die ge„ndert wurden und auf die am
l„ngsten nicht mehr zugegriffen wurde (sog. LRU-Aging-Algorithmus).


******************************************************************************
* Ein Hinweis an Besitzer einer Wechselplatte:                               *
*                                                                            *
* Falls die tempor„re Datei auf der Wechselplatte angelegt wird, so darf sie *
* vor Programmbeendigung unter keinen Umst„nden herausgenommen werden!!!     *
******************************************************************************


Leistungsmerkmale von VMEM V1.1:
================================

 * Verwaltung von bis zu 2 Gigabyte an zus„tzlichem Speicher

 * lauff„hig auf allen Atari-Rechnern mit Fest-/Wechselplatte

 * VMEM erlaubt die Nutzung groer Datenmengen auch bei Rechnern, deren
   Hauptspeicher nur 512 KByte betr„gt

 * frei konfigurierbare Gr”e des Speichers und des Caches

 * Cache mit "intelligentem" Verwaltungsalgorithmus (modifizierter LRU-Aging)

 * einfache Programmierung („hnlich Malloc und Mfree des Betriebssystems)

 * spezielle Zugriffsbefehle erledigen den Datenaustausch zwischen dem
   virtuellen Speicher und dem physikalischen Speicher / Datentr„ger
   mit der gr”tm”glichen Geschwindigkeit

 * geringer Mehraufwand bei der Erweiterung bestehender Programme

 * einmalige Installation im Speicher

 * Updates von VMEM erfordern keine bersetzung bestehender Programme


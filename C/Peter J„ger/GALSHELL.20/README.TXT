 **      **     *        **     *  *    ****    *       *       
*       *  *    *       *  *    *  *    *       *       *       
*       *  *    *       *       *  *    *       *       *       
* **    ****    *        **     ****    ***     *       *       
*  *    *  *    *          *    *  *    *       *       *       
*  *    *  *    *       *  *    *  *    *       *       *       
 **     *  *    ****     **     *  *    ****    ****    ****    
                                                                

                      **              **     
                     *  *            *  *    
                        *            * **    
                       *             ** *    
                      *              *  *    
                     *               *  *    
                     ****      *      **     
                        

Dieses Programm stellt eine GEM-konforme Benutzeroberfl�che zum
GAL-Programmierger�t und dessen Tools aus dem GAL Buch von 
Ulrich Hack und Markus Hoffmann dar. Die GALSHELL erm�glicht den
Aufruf von Editor, GAL-Assembler und GAL-Programmier-Tool. Dabei
k�nnen Quell- und Zieldatei, Assembler- und Programmeroptionen
per GEM-Button gew�hlt werden.

In der Version 2.0 ist die GALSHELL an die Version 1.6 des
GAL-Prommers angepa�t, kann aber auch mit �lteren Versionen benutzt
werden. Man beachte die �nderung einiger Optionen.

Dieses Programm ist FairWare, was hei�en soll, ich w�re f�r Zuwendungen,
zB. DM 10,- an die unten genannte Adresse, bei h�ufiger Benutzung dankbar.


F�r Fehler die durch dieses Programm unmittelbar, mittelbar oder durch 
falsche Handhabung enstehen �bernehme ich keine Haftung. 
Ich bin aber dankbar f�r Fehlerberichte, die am besten an meine
MAUS-Adresse
                 Peter J�ger @ DU2
gerichtet werden. Dann kann ich sie schnellstm�glich beantworten.

Copyright 1993, 1994 Peter J�ger, Liebknechtstra�e 118, 46047 Oberhausen



Die Dateien der GALSHELL:
-------------------------
SOURCE         <DIR>  19-03-1994  13:05  Ordner mit den Quellen f�r Turbo/Pure C
GALSHELL PRG   18754  15-03-1994  22:27  Das Programm
README   TXT       0  19-03-1994  13:11  Diese Datei



Nach den Formalit�ten zur Benutzung:
Am besten kopiert man GALSHELL.PRG in das Verzeichnis, in dem sich auch
GAL_ASM.TTP und GAL_PROG.TTP befinden. Ansonsten mu� man beim Programmstart
mittels Fileselector diese beiden Programme angeben.
Anschlie�end erscheint die relativ �berf�llte Dialogbox. Man mu� sich wohl erst
einmal einen Augenblick Zeit nehmen.

Unter dem Titel findet man die Auswahlfelder f�r die Assembler-Datei (.GAL)
und die JEDEC-Datei (.JED). Einfaches Anklicken �ffnet eine Fileselector-Box
zur Auswahl der entsprechenden Datei.

Der Knopf 'EDIT' startet den Editor. Existiert EDITOR.PRG im aktuellen
Verzeichnis, wird dieses Programm gestartet. Ansonsten kann der Editor per
Fileselector beim ersten Aufruf ausgew�hlt werden. Bei weiteren Aufrufen wird
automatisch das selbe Programm gestartet. Der Aufruf des Editors macht die Auswahl
des JEDEC-Files ung�ltig.
'ASM' startet den GAL-Assembler. Bei Erfolg der Assemblierung wird die neuerzeugte
Datei als aktuelle JEDEC-Datei �bernommen. Unter 'Assembler-Options' k�nnen Optionen
des Assemblers ausgew�hlt werden.

Darunter kann unter 'GAL Type' der GAL-Typ ausgew�hlt werden.

'Options' sind die Optionen des GAL-Programmers, die einzeln an und abgeschaltet
werden k�nnen. Die dabei entstehenden Kombinationen werden nicht von der GALSHELL
�berpr�ft.

Die unterste Gruppe von Kn�pfen bestimmt die Funktion, die der GAL-Programmer
ausf�hren soll. Der Default-Button ist der EXIT-Knopf.


Vertr�glichkeit:
----------------
Ich habe die GALSHELL auf dem Falcon mit TOS 4.04 und auf einem 1040 mit TOS 1.04
getestet. Es sollte mindestens die Aufl�sung ST High gew�hlt werden.


Bekannte Probleme:
------------------
- Bei ST-High wird der untere Rand der Dialogbox nicht angezeigt. Das hat aber
  keine negativen Auswirkungen. Ansonsten: ich arbeite daran.
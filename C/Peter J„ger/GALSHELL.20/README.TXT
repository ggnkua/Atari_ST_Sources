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
                        

Dieses Programm stellt eine GEM-konforme BenutzeroberflÑche zum
GAL-ProgrammiergerÑt und dessen Tools aus dem GAL Buch von 
Ulrich Hack und Markus Hoffmann dar. Die GALSHELL ermîglicht den
Aufruf von Editor, GAL-Assembler und GAL-Programmier-Tool. Dabei
kînnen Quell- und Zieldatei, Assembler- und Programmeroptionen
per GEM-Button gewÑhlt werden.

In der Version 2.0 ist die GALSHELL an die Version 1.6 des
GAL-Prommers angepaût, kann aber auch mit Ñlteren Versionen benutzt
werden. Man beachte die énderung einiger Optionen.

Dieses Programm ist FairWare, was heiûen soll, ich wÑre fÅr Zuwendungen,
zB. DM 10,- an die unten genannte Adresse, bei hÑufiger Benutzung dankbar.


FÅr Fehler die durch dieses Programm unmittelbar, mittelbar oder durch 
falsche Handhabung enstehen Åbernehme ich keine Haftung. 
Ich bin aber dankbar fÅr Fehlerberichte, die am besten an meine
MAUS-Adresse
                 Peter JÑger @ DU2
gerichtet werden. Dann kann ich sie schnellstmîglich beantworten.

Copyright 1993, 1994 Peter JÑger, Liebknechtstraûe 118, 46047 Oberhausen



Die Dateien der GALSHELL:
-------------------------
SOURCE         <DIR>  19-03-1994  13:05  Ordner mit den Quellen fÅr Turbo/Pure C
GALSHELL PRG   18754  15-03-1994  22:27  Das Programm
README   TXT       0  19-03-1994  13:11  Diese Datei



Nach den FormalitÑten zur Benutzung:
Am besten kopiert man GALSHELL.PRG in das Verzeichnis, in dem sich auch
GAL_ASM.TTP und GAL_PROG.TTP befinden. Ansonsten muû man beim Programmstart
mittels Fileselector diese beiden Programme angeben.
Anschlieûend erscheint die relativ ÅberfÅllte Dialogbox. Man muû sich wohl erst
einmal einen Augenblick Zeit nehmen.

Unter dem Titel findet man die Auswahlfelder fÅr die Assembler-Datei (.GAL)
und die JEDEC-Datei (.JED). Einfaches Anklicken îffnet eine Fileselector-Box
zur Auswahl der entsprechenden Datei.

Der Knopf 'EDIT' startet den Editor. Existiert EDITOR.PRG im aktuellen
Verzeichnis, wird dieses Programm gestartet. Ansonsten kann der Editor per
Fileselector beim ersten Aufruf ausgewÑhlt werden. Bei weiteren Aufrufen wird
automatisch das selbe Programm gestartet. Der Aufruf des Editors macht die Auswahl
des JEDEC-Files ungÅltig.
'ASM' startet den GAL-Assembler. Bei Erfolg der Assemblierung wird die neuerzeugte
Datei als aktuelle JEDEC-Datei Åbernommen. Unter 'Assembler-Options' kînnen Optionen
des Assemblers ausgewÑhlt werden.

Darunter kann unter 'GAL Type' der GAL-Typ ausgewÑhlt werden.

'Options' sind die Optionen des GAL-Programmers, die einzeln an und abgeschaltet
werden kînnen. Die dabei entstehenden Kombinationen werden nicht von der GALSHELL
ÅberprÅft.

Die unterste Gruppe von Knîpfen bestimmt die Funktion, die der GAL-Programmer
ausfÅhren soll. Der Default-Button ist der EXIT-Knopf.


VertrÑglichkeit:
----------------
Ich habe die GALSHELL auf dem Falcon mit TOS 4.04 und auf einem 1040 mit TOS 1.04
getestet. Es sollte mindestens die Auflîsung ST High gewÑhlt werden.


Bekannte Probleme:
------------------
- Bei ST-High wird der untere Rand der Dialogbox nicht angezeigt. Das hat aber
  keine negativen Auswirkungen. Ansonsten: ich arbeite daran.
SWEpatch - Der TOS-Patch f�r Atapi- und IDE1-Boot,Bootsequencer,Memtest-Timeout und Boottext
--------------------------------------------------------------------------------------------

Hier ist die neue Atapipatch-Beta V1.00�.

Mit dem SWEpatcher kann man einige neue Funktionen,insbesondere f�r
Atapi- und IDE-Laufwerke in das TOS patchen.
Das TOS wird durch den SWEpatcher um folgende Features erweitert:

1. Booten von Atapi-Laufwerken

2. Booten von Laufwerken an IDE1

3. Die Bootreihenfolge ist �ber Tastatur steuerbar (F1-F7).
   Beliebige Bootlaufwerke k�nnen durch die Funktionstasten F1-F7
   aus der Bootsequenz entfernt werden.Dadurch ist sichergestellt,
   da� jederzeit das System von einem anderen Laufwerk gebootet
   werden kann.Es kann auch vom LS120-Superfloppy-Laufwerk oder
   ZIP (Atapi) gebootet werden.
   Dadurch kann man prinzipiell ohne Probleme jetzt auf die
   normale Floppy verzichten,da das LS120 auch normale HD-Disketten
   schreiben und lesen kann.
   Die �nderung der Bootsequenz kann sehr wichtig werden,wenn z.B.
   der Festplattentreiber durch ein "wildgewordenes" Programm zerst�rt wurde,
   und der Rechner dadurch in der Bootphase abst�rzt.
   Normalerweise hat man dann lediglich mit einer Floppy und Druck der
   ALT-Taste die M�glichkeit,auf den Desktop zur�ckzukehren und den Treiber
   zu erneuern.Ohne Floppy w�re man nun aufgeschmissen.
   �ndert man aber die Bootsequenz,indem man das defekte Laufwerk aus der
   Bootsequenz entfernt,kann man jederzeit von einem anderen bootf�higen
   Laufwerk starten.Bedingung hierf�r ist nat�rlich ein funktionst�chtiges
   Medium mit installiertem Festplattentreiber.

   Die Funktionstasten werden beim Speichertest ausgewertet.
   Wenn man den Speichertest durch RETURN abbricht,wird die
   Standard-Bootsequenz verwendet.
   Dr�ckt man stattdessen aber eine Funktionstaste,wird das entsprechende
   Laufwerk aus der Bootsequenz entfernt:
   
   RETURN: IDE0-1 SCSI0-6 ACSI0-6
       F1: SCSI1-6 ACSI0-6 IDE0-1
       F2: SCSI2-6,0 ACSI0-6 IDE0-1
       ...
       F6: SCSI6,0-4 ACSI0-6 IDE0-1
       F7: SCSI0-5 ACSI0-6 IDE0-1
       
 SHIFT F1: ACSI1-6 IDE0-1 SCSI0-6
 SHIFT F2: ACSI2-6,0 IDE0-1 SCSI0-6
 ...
 SHIFT F6: ACSI6,0-4 IDE0-1 SCSI0-6
 SHIFT F7: ACSI0-5 IDE0-1 SCSI0-6
 
  CTRL F1: IDE1 SCSI0-6 ACSI0-6
  CTRL F2: IDE0 SCSI0-6 ACSI0-6

Wenn nicht SCSI als auch ACSI auf dem Rechner verf�gbar ist,
wird keine Unterscheidung mittels der Shift-Taste vorgenommen.

4. Benutzerdefinierter Startup-Text in der Bootphase
   Diese M�glichkeit kann man z.B. daf�r nutzen,eine pers�nliche
   Begr��ung oder Werbebotschaft beim Einschalten anzeigen zu lassen.

5. Bildschirmausgabe von Bootsequenz und Bootdevice
   Die ausgew�hlte Bootsequenz und das Bootlaufwerk wird in der Bootphase
   im Klartext angezeigt.
   
6. Speichertest-Timeout f�r verk�rzte Autobootphase
   Der Speichertest kann durch eine einstellbare Timeout-Zeit automatisch
   abgebrochen werden (wichtig f�r Server-Autostart oder Mailbox-Systeme).
   Das ist vor allem dann n�tzlich,wenn man �ber sehr viel Speicher verf�gt,
   da der Speichertest sonst einige Minuten dauern kann.
   Wenn man diese M�glichkeit nutzen m�chte,sollte man die Option
   "memtest-timeout" ausw�hen,und im Zeitfeld den Timeout (in Sekunden)
   einstellen.
   
Das Patchprogramm kann eine Sicherheitskopie des Original-TOS schreiben
(Option TOS-Backup).Das Originaltos wird dann als OTOS.IMG gesichert.
Je nach TOS-Version werden die Images automatisch Epromgerecht aufgeteilt,
und die Pr�fsumme korrigiert.
Man sollte vorerst unbedingt HDDRIVER in einer relativ neuen Version ab 7.60
verwenden.Im Hades ist laut Meinung von Uwe Seimet der _MCH-Cookie mit einem
Wert von $20000 falsch gesetzt.Deshalb benutzt der HDDRIVER in diesem Fall
eigene IDE-Routinen,die mit Atapi nicht funktionieren.
Ich werde mich bem�hen,eine "saubere" L�sung mit Uwe zu vereinbaren.
Im Moment patcht mein Treiber das HDDRIVER-Bootprogramm "direkt" in der
Bootphase (also nicht auf dem Laufwerk direkt) und entfernt die Abfrage auf IDE.
Dadurch laufen dann alle Zugriffe korrekt �ber die XBIOS-Funktion DMAREAD/
DMAWRITE,die ich f�r Atapi neugeschrieben habe.

Daher l�uft der Patch derzeit nur mit HDDRIVER ab V7.60 zusammen!

Das Patchprogramm erkennt die TOS-Version automatisch!
Es werden bisher folgende Rechner mit den angegebenen TOS-Versionen unterst�tzt:

- Hades060 TOS 3.06,G55 vom 24.9.91
- MedusaT40 TOS 3.06 vom 24.9.91
- Atari ST,TOS 2.06 vom 14.11.91
- Atari TT,TOS 3.06 vom 24.9.91

Sollte die verwendete TOS-Version nicht aufgelistet sein,kann es trotzdem sein,
da� der Patch auch mit anderen TOS-Versionen funktioniert.Das Patchprogramm
�berpr�ft die TOS-Version sehr genau,um Fehlfunktionen zu vermeiden.
Bereits gepatchte TOS-Versionen werden nicht mehr als Original erkannt.
Das wird auch entsprechend im Reportfeld gemeldet.Man kann den Patch auf diese
Versionen aber trotzdem wiederholt anwenden,um weitere Kopien der IMG-Dateien
zu machen.Der Patch von unbekannten TOS-Versionen kann zu Fehlfunktionen f�hren,
oder wird vom Programm verweigert,falls Abweichungen im Code erkannt werden.
Man sollte daher immer eine Sicherheitskopie des Original-TOS machen !

Das Booten von Atapi und IDE1 wurde erfolgreich auf dem Hades060 und der
MedusaT40 getestet.Auf dem Atari ST und dem TT konnte es noch nicht getestet werden,
da ich keinen entsprechenden IDE-Adapter habe.
Ich glaube f�r den ST gab es da mal etwas,evtl. sogar als Bastell�sung.

F�r den TT gibt es meines Wissens nach nichts derartiges.
Trotzdem ist es sinnvoll,den Patch auf dem TT zu installieren,da man damit
wenigstens in den Genu� der anderen Patch-Features kommt,wie ausf�hrliche
Bootmeldungen,Bootsequencer,Begr��ungstext und Speichertest-Timeout.

Der Patch kann auch auf das Falcon-TOS 4.04 vom 8.3.93 angewendet werden.
Da ich momentan allerdings keinen passenden PLCC-Epromsockel habe um das Eprom zu 
brennen,konnte ich die Funktionsf�higkeit bisher nicht testen.
Das Programm l�uft derzeit auf dem Falcon nicht korrekt unter GEM,daher wird hier
auf GEM verzichtet,und einfach im Textmode konfiguriert.

Wer kann mir ein TOS4.06 (ist es da aktuellste Falcon-TOS ?) zum Testen geben ?
Wer den Patch am Falcon ausprobieren kann,bitte melden !
Wer positive oder negative Erfahrungen mit dem Patch gemacht hat,bitte melden !

Nur durch die Unterst�tzung der Anwender k�nnen evtl. bestehende Probleme behoben
werden.Insbesondere die Programmierer von MagiC sind hiermit freundlichst und mit
meiner vollen Unterst�tzung dazu aufgefordert,die neuen Features,insbesondere
Atapi-Boot,IDE1-Boot und den Bootsequencer in MagiC zu integrieren.
Die Sourcen sind frei und liegen dem Patch-Paket bei.

Ansonsten w�nsche ich viel Spa� mit den neuen Features.
Das Programm ist kostenlos,sollte aber immer komplett weitergegeben werden.
Ich �bernehme nat�rlich keinerlei Gew�hrleistung oder Haftung im Zusammenhang mit
der Anwendung des Patchprogramms.

SWEpatch ist eine Software von:
Stephan Wilhelm
Entwicklungsb�ro f�r Hard- und Software
Niehler Str.312
D-50735 K�ln
Tel: 0221-7127380
Fax: 0221-685184


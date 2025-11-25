Kurzanleitung ...

                 Letzte nderung des README.TXT am 16.08.1990

                                **************
                                * CHRONO.PRG *
                                **************

                      Copyright (c) 1990 by Jrgen Luers
                        Bekhauser Esch 47, 2902 Rastede

Dieses  Programm  liegt neuerdings im AUTO-Ordner dem Grafikpaket bei  und  ist 
Public Domain.  Mit diesem Programm k”nnen die System-Zeit und das System-Datum 
in der Boot-Phase eingestellt werden. Auerdem erlaubt 'CHRONO.PRG' die Auswahl 
der zu ladenden Accessories. Dabei werden die Extensionen der nicht angew„hlten 
Accessories  in  '.ACX' ge„ndert.  Beim Umbenennen wird brigens  dem  Anwender 
jeder  einzelne  zu „ndernde Accessory-Name angezeigt.  Das  Programm  ist  auf 
maximale  Geschwindigkeit  abgestimmt  und  in  der  Benutzerfhrung  m”glichst 
komfortabel  gehalten.  Das  'CHRONO.PRG'  ist  brigens  vollst„ndig  mit  dem 
'TURBO-ASS' (tolles Teil !!!!) von  Markus Fritze entstanden.

                          Braunschweig, den 11.06.90

                               Der Programmautor



                 *********************************************
                 * SNAP IMGAGE 1.0  (c) 1990 by Jrgen Luers *
                 *********************************************
                      Bekhauser Esch 47 , 2902 Rastede 2

Das Programm ist Public-Domain und l„uft mit allen(!) monochromen Monitoren !

Dieses  Accessory soll es Ihnen als Anwender erm”glichen aus  allen  Programmen 
Bilder zu gewinnen,  ohne da das Programm etwas davon merkt.  Das  '.ACC'-File 
ist 2812 Bytes lang und belegt intern 4196 Bytes.  Wird 'Snap IMG-File' im GEM-
Men angew„hlt, so erscheint zun„chst eine ALERT-Box mit folgenden Funktionen:
1.   'CANCEL'
     Das Accessory wird ohne weitere Aktion verlassen.
2.   'OK'
     Es wird vom Hauptspeicher ein Speicherblock (Gr”e abh„ngig von Aufl”sung)
     angefordert und reserviert.  Dann wird der Mauszeiger abgeschaltet und das 
     aktuelle Bild intern ins IMG-Format komprimiert.  In der darauf  folgenden 
     Fileselektorbox  kann nun der Dateiname und -suchpfad  eingegeben  werden, 
     unter dem das Image gespeichert werden soll.  Egal welcher Knopf  bet„tigt 
     wird;  der eingestellte Pfad und der eingestellte Name werden ausgewertet. 
     Wird  beim  Dateinamen keine Extension  eingegeben,  so  wird  automatisch 
     '.IMG'  angeh„ngt.   Wird  'ABBRUCH'  selektiert,   so  wird  danach   der 
     angeforderte  Speicher wieder freigegeben (Ausnahme siehe ALT-HELP !)  und 
     das  Accessory  verlassen.   Wird  'OK'  angew„hlt,   so  wird  die  Datei 
     abgespeichert  und dann wie bei 'ABBRUCH' fortgefahren.  Tritt ein  Fehler 
     bei  der  Dateiverwaltung  auf,  so  erscheint  im  Allgemeinen  nur  eine 
     Meldung,  da  berhaupt ein Fehler aufgetreten ist.  Bei Fehlern  in  der 
     Speicherverwaltung erscheint allerdings eine genauere Fehlermeldung.
3.   'ALT-HELP'
     Es erscheint eine weitere ALERT-Box,  in der die Ausl”sung des Accessories 
     ber   die  Tastenkombination  'Alternate-Help'  installiert  und   wieder 
     deinstalliert  werden  kann.  Wird  'ON' angew„hlt,  so  klinkt  sich  das 
     Accessory mit Hilfe des XBRA-Protokolls in der entsprechenden Vektor  ein. 
     Dies  fhrt dazu,  da ber diese Tastenkombination keine  weitere  Aktion 
     wie  z.B.  die Drucker-Hardcopy ausgel”st werden kann.  Auerdem wird  der 
     schon oben erw„hnte Speicherblock angefordert und reserviert.  Wird  'OFF' 
     selektiert,  so klinkt sich das Accessory vollst„ndig mit Hilfe des  XBRA-
     Protokolls   wieder  aus  den  Vektor  aus  und  gibt   den   reservierten 
     Speicherblock wieder frei. 
Bemerkungen:
1.   Der  durch  die  ALT-HELP-Installation  angeforderte  Speicher  wird  auch 
     w„hrend des normalen Accessory-Aufrufs ber die GEM-Menzeile benutzt. Ist 
     also ALT-HELP installiert, so wird kein weiterer Speicher angefordert.
2.   Wird gerade auf einen Massenspeicher zugegriffen,  so sollte das Accessory 
     nicht (!) ber ALT-HELP ausgel”st werden.  Zwar werden von der zust„ndigen 
     Routine  die GEMDOS-DTA und die Save-area des BIOS gesichert;  das  GEMDOS 
     ist  jedoch nicht reentrant.  Bei BIOS-Aufrufen sollte es  keine  Probleme 
     geben.
3.   Der aktuelle Suchpfad und das aktuelle Laufwerk werden bei ALT-HELP vorher 
     gesichert  und danach wieder hergestellt.  Dies erzeugt aber  beim  GEMDOS 
     nicht automatisch den Status des 'Diskette gewechselt'.  Dies fhrt  dazu, 
     da  bei  Benutzung eines Laufwerks aber zweier Disketten  und  schlechter 
     Fehlerabfangung  seitens  des Wirtsprogramms das Wirtsprogramm  sich  beim 
     n„chsten  Diskettenzugriff  mit  'Datei  nicht  gefunden'   verabschiedet. 
     Besitzt  man nur ein Laufwerk 'A' und m”chte die  '.IMG'-Dateien  trotzdem 
     auf eine andere Diskette haben,  so sollte man SNAP_IMG ber die Menzeile 
     aufrufen  und  in  der Fileselektorbox das  Laufwerk  'B'  anw„hlen.  Nach 
     'ABBRUCH'  merkt sich dieses Accessory bekanntlich  den  Suchpfad.  Dieser 
     Suchpfad wird nun auch von der ALT-HELP-Routine benutzt, so da das GEMDOS 
     die Verwaltung der Diskettenwechsel bernimmt. Selbstverst„ndlich kann man 
     auch  das  Wirtsprogramm  von 'B' starten und das  aktuelle  Laufwerk  von 
     SNAP_IMG auf 'A' stehen lassen, was zum selben Effekt fhrt.
4.   Bei  Bet„tigung  von  ALT-HELP werden  Dateien  mit  Namen  'IMAGExxx.IMG' 
     erzeugt.  'xxx' steht dabei fr eine 3-stellige Dezimalzahl.  Die  Z„hlung 
     beginnt  bei '001' und setzt sich zu gr”eren Zahlen hin  fort.  Ist  eine 
     Datei  mit  selben Namen schon vorhanden,  so wird  die  betreffende  Zahl 
     inkrementiert und dann mit dem neuen Namen fortgefahren.  Dies fhrt dazu, 
     da nach erneutem Booten des Systems zuerst Namen fehlender Zahlen benutzt 
     werden. Befinden sich z.B. nach dem Bootvorgang die Dateien 'IMAGE001.IMG' 
     und  'IMAGE003.IMG'  auf  dem Laufwerk,  so wird als  n„chstes  die  Datei 
     'IMAGE002.IMG'  erzeugt.   Diese  Regel  gilt  natrlich  nur  nach  einem 
     Bootvorgang.   Werden  zwischendurch  Dateien  gel”scht,  so  werden  ohne 
     erneutes Booten die fehlenden Namen nicht wieder benutzt.
5.   ALT-HELP  bernimmt  den  zuletzt  benutzten  Dateinamen  nicht  aus   der 
     Fileselektorbox.  Umgekehrt  aber bernimmt die Fileselektorbox den  Namen 
     der zuletzt ausgegebenen Datei als Default-Name.
6.   Die  aktuelle Speicherblockgr”e wird in der ALERT-Box fr  die  ALT-HELP-
     Installation angezeigt.  Diese Speicherblockgr”e errechnet sich nach  der 
     Formel: Rasterbreite[in Bytes]*(Rasterh”he[in Pixel]+1)+Rasterh”he*2+19
     Bei einer Aufl”sung von 640x400 Pixel ergibt dies eine Gr”e von 33KBytes.

Bleibt  zu  sagen,  da der Programmautor jede Haftung  ablehnen  mu,  die  in
Zusammenhang  mit diesem Programm steht.  W„ren Sie erfreut darber,  wenn  ein 
Benutzer von Ihnen Schadensersatz fr seine hopp's gegangenen Daten auf  seiner 
120  MByte  groen  Harddisc fordert ?  Auf jeden Fall  habe  ich  aber  gr”te 
Sorgfalt  bei  der Erstellung dieses Programmes walten lassen  (mehr  als  sein 
Preis von 0,- DM rechtfertigt!).


                         Braunschweig, den 04.07.1990

                               Der Programmautor



                             ********************
                             * GEM A4_GRAF 2.09 *
                             ********************


                    Copyright (c) 1989/1990 by Jrgen Luers
                        Bekhauser Esch 47, 2902 Rastede


                       Dieses Programmpaket ist FREEWARE! 

Vorwort:
========
Der  Begriff  'FREEWARE'  beinhaltet,   da  das  Programm  an  jeden   anderen 
interessierten   Benutzer  legal  weiter  gegeben  werden  darf.   Allein   der 
Programmautor ist berechtigt,  fr das Programm Zahlungsmittel zu fordern.  Das 
Programmpaket  darf nicht ver„ndert werden und mu vollst„ndig kopiert  werden. 
Es  drfen  weitere Dateien vom Benutzer zugefgt  werden.  Diese  sind  jedoch 
entsprechend kenntlich zu machen.
šber  das 'FREEWARE'-Konzept kann jeder Interessierte das betreffende  Programm 
in  Ruhe  legal  austesten  und  dann bei  Gefallen  sich  die  Anleitung  beim 
Programmautor  ber eine Schutzgebhr beschaffen.  So haben weder der  Anwender 
noch der Programmautor extreme Nachteile in Kauf zu nehmen.
Mein Dank gilt Herrn Ostrowski fr sein berragendes GFA-BASIC, mit dem es sehr 
einfach ist,  strukturierte,  bersichtliche und zugleich schnelle Programme zu 
schreiben sowie Markus Fritze fr seinen tollen TURBO-ASSEMBLER.
Mein Dank gilt auch all jenen,  die mir bei der Fehlersuche in meinem  Programm 
behilflich waren, insbesondere Josch, Michael, Peter und Uschi !
  
                           Bekhausen, den 07.04.1989

                               Der Programmautor 

An den Benutzer:
================
Ich bin Student an der TU-Braunschweig (Elektrotechnik) und tauche entsprechend 
selten zu Hause auf.  Dehalb kann es schon mal 3 bis 4 Wochen dauern,  bis ein 
Brief von mir beantwortet wird.  Ich habe trotzdem meine Heimadresse angegeben, 
damit  Ihre  Post nach einem Umzug meinerseits nicht  ins  'Nirwana'  geht.  Es 
bleibt zu sagen,  da natrlich mein Studium auf jeden Fall vorgeht. Sie k”nnen 
sich  aber darauf verlassen,  da (so bald wie m”glich) jede  Post  beantwortet 
wird. Ich kann allerdings Post ohne frankierten Rckumschlag nicht beantworten. 
Meine  Geldreserven sind (wie es sich fr einen ordentlichen Studenten  geh”rt) 
sehr gering.
Bei diesem Text handelt es sich brigens um eine Kurzanleitung.  Eine  wirklich 
umfassende Anleitung verbunden mit der neuesten Version des Programmpaketes auf 
Diskette  kann  fr 40,-DM (Verrechnungsscheck oder bar)  bei  mir  angefordert 
werden.  Sie  werden  damit (falls von Ihnen nicht anders gewnscht)  zu  einem 
registrierten Benutzer dieses Grafikpaketes.  Dies bedeutet fr Sie, da Sie im 
weiteren Verlauf nur noch 10,-DM fr ein Update des Programms und der Anleitung 
bezahlen mssen.  Zur Registrierung werden allerdings Ihr Name und Ihre Adresse 
auf  Datentr„ger  oder schriftlich  festgehalten.  Falls  Sie  wnschen,  nicht 
registriert  zu  werden (aus welchen Grnden auch  immer),  werden  meinerseits 
unmittelbar  nach Absenden des Updates alle Sie betreffenden Daten  vernichtet. 
Sie haben aber damit auch keinen Anspruch mehr auf verbilligte  Updates.  Legen 
Sie   bitte  jeder  Update-Anforderung  einen  adressierten  und   mit   3,20DM 
frankierten C5-Briefumschlag bei.
Viele  Features des A4_GRAF konnten einmal aus Platz- sowie aus Zeitmangel  von 
mir  in  diesem Rahmen gar nicht erw„hnt  bzw.  nur  unvollst„ndig  dargestellt 
werden.  Dies gilt insbesondere fr die  Block-,  Symbol-,  Rastungs-,  Lupen-, 
Zeichensatz-,  Fllmuster-  und  Zoom-Funktion  sowie fr  die  metrische  oder 
z”llige,  mast„bliche Koordinatenanzeige.  Auch fehlen in diesem  Zusammenhang 
weitere   Tip's   und  Trick's  sowie  der  interne  Aufbau   aller   benutzten 
Dateiformate.   Auf   diese  Dinge  wird  natrlich  in  der  Anleitung   genau 
eingegangen.  Dieses  Programm wird Ihnen aber auch schon so sehr gute  Dienste 
leisten.
Obwohl  ich  das  Endprodukt  sehr  sorgf„ltig  auf  Fehler   untersucht  habe, 
k”nnten immer noch  Fehler  vorhanden  sein.   Dies  ergibt  sich  schon   fast 
automatisch  aus der Komplexit„t eines solchen Programmes.  Sollten Sie  Fehler 
bemerken,  so  schreiben  Sie mir bitte.  Beschreiben Sie dabei den  Fehler  so 
genau,  da er von mir ebenfalls ausgel”st werden kann. Vergessen Sie in diesem 
Zusammenhang nicht, die Versionsnummer des Programmes sowie des Betriebssystems 
anzugeben.  Ich  werde  den  Fehler  beheben  und  Sie  dann  nach  M”glichkeit 
benachrichtigen.  Natrlich  sind  auch Verbesserungsvorschl„ge  gern  gesehen. 
Bitte legen Sie jeder Anfrage einen frankierten und an sich selbst adressierten 
Rckumschlag  bei. Ich kann sonst leider keine Rckantwort geben.
Obwohl  ich  alle  Sorgfalt  bei der  Programmerstellung  habe  walten  lassen, 
bernehme ich keine Gew„hr dafr,  da die beschriebenen  Verfahren,  Programme 
usw.  funktionsf„hig  sind.  Auch  bernehme  ich keine  Gew„hr  fr  jegliches 
zugeschicktes Material.


Hardware-Voraussetzungen:
=========================
'A4_GRAF':
Ihr   ATARI-ST   mu   ber   mindestens  1MByte   RAM   sowie   TOS   im   ROM 
verfgen.  Auerdem  wird der  ATARI-Standard-monochrom-Monitor  ben”tigt.  Das 
Programm arbeitet nicht mit anderen Monitoren bzw. Aufl”sungen zusammen. 


Einfhrung:
===========
Folgende Dateien geh”ren zum Hauptprogramm 'A4_GRAF.PRG': 
*  A4_GRAF.PAR  <=> Parameterdatei
* A4_PRINT.PRG  <=> Druckertreiber
* ZEI_EDIT.PRG  <=> 8*16-Zeichensatz-Editor
*  A4_DEMO.PRG  <=> Beispiel-Unterprogramm
*  A4_DEMO.LST  <=> ASCII-Quelltext des Beispiel-Unterprogramms
*   README.TXT  <=> Anleitung/Fehlerkorrekturen als ASCII-Datei
*  ELEKTRO.SYM  <=> Symboldatei mit Elektro-Schaltplansymbolen
*    NOTES.SYM  <=> Symboldatei mit Notensatz-Symbolen
*  PLATINE.SYM  <=> Symboldatei mit Platinen-Symbolen
*        *.FNT  <=> 8*16-Zeichensatz-Dateien
*  ELEKTRO.IMG  <=> Schaltplan-Demo
*    NOTES.IMG  <=> Notensatz-Demo
*  PLATINE.IMG  <=> Platinen-Demo
Beim A4_GRAF handelt es sich um einen pixelorientierten Grafikeditor,  mit  dem 
Zeichnungen  gr”er  als der sichtbare Bildschirm erstellt  werden  k”nnen.  Es 
steht  ein Gesamtbildschirm mit einer Aufl”sung von 1440 mal 1984  Punkten  zur 
Verfgung.  Diese  Punktanzahl ergibt bei einer Druckaufl”sung von  1/180  Zoll 
eine  Zeichenfl„che von 8 mal 11 Zoll;  also DIN-A4.  Diese Zeichenfl„che  l„t 
sich   in   4  gleich  groe  Unterbildschirme  zerlegen,   die   auch   wieder 
zusammengesetzt werden k”nnen. Damit stehen 4 DIN-A6-Bildschirme zur Verfgung, 
wenn von der gleichen Druckaufl”sung ausgegangen wird.  Da auf dem  monochromen 
Bildschirm  effektiv  nur  624  mal  368  Punkte  (wegen  Men  und   Fenster!) 
dargestellt  werden,  kann natrlich immer nur ein Ausschnitt des  betreffenden 
Bildes angezeigt werden.  Dieser Ausschnitt wird durch die Stellung der  beiden 
Schieberegler des Fensters bestimmt,  die im 16-Punkte-Abstand  einrasten.  Das 
Programm  merkt  sich  deren  Stellungen  fr  alle  Bildschirme,  so  da  die 
Bildschirme problemlos und schnell gewechselt werden k”nnen.  Auerdem kann mit 
Hilfe des Fensterteils ganz rechts unten der Ausschnitt schnell von ganz  links 
oben  nach  ganz rechts unten und umgekehrt gew„hlt werden.  Bei  Betreten  des 
Bildausschnittes   wird  der  Mauszeiger  automatisch  zu   einem   punktierten 
Fadenkreuz.  Auerdem wird dabei die aktuelle Grafikfunktion sowie der aktuelle 
Bildschirm (nur bei aktivem Unterbild!) in der Menzeile angezeigt. M”chten Sie 
Attribute fr die aktuelle Funktion „ndern, so mssen Sie die aktuelle Funktion 
nicht beenden,  sondern k”nnen direkt das Men betreten,  welches bei  Betreten 
der oberen Zeile erscheint.  Ist das Fadenkreuz sichtbar, so  k”nnen  Sie  ber  
bestimmte   Tastatur-Kommandos  verschiedene  Zusatz-Funktionen  erreichen.  Es 
gilt  fast  immer  das 'WYSIWYG'-Prinzip ( "What you see is what  you  get"  ). 
Auerdem  verfgt  das Programm noch ber  eine  umschaltende  'UNDO'-Funktion. 
Diese   'UNDO'-Funktion  funktioniert  aber  nicht  mehr  nach  Anklicken   von 
Meneintr„gen unter den Titeln 'System' und 'Bilder' sowie bei Ver„nderung  des 
Bildausschnittes.  Ausgangspunkt der Koordinatenberechnung ist die linke  obere 
Ecke  des jeweiligen Bildschirmes.  Sie sollten sich unbedingt  angew”hnen,  in 
dieser Ecke ihre Zeichnung zu beginnen.  S„mtliche Funktionen zur Sicherung der 
Daten gehen n„mlich von dieser Ecke aus. Beginnen Sie also z.B. unten rechts im 
Gesamtbildschirm,   so  h„tte  Ihr  Bild  die  maximal  m”gliche   Gr”e.   Der 
Speicherverbrauch   beim  Sichern  der  Datei  und  die   Ausdruckdauer   w„ren 
unverh„ltnism„ig gro.


Menzeile:
==========
'Accessories':
--------------
Wird  dieser  Punkt  angew„hlt,  so  wird  eine  GEM-Menzeile  mit  den  evtl. 
vorhandenen  Accessories  angezeigt.  Hier  k”nnen  die  Accessories  angew„hlt 
werden.  Wird hier 'GEM A4_GRAF-Info' selektiert, so wird der Ausschnitt danach 
neu  gezeichnet.  šber  den  Eintrag 'zurck ...'  kann  der  Acc-Modus  wieder 
verlassen  werden.   Hierbei  erfolgt  eine  Sicherheitsabfrage,  ob  noch  ein 
Accessory  aktiv ist.  Sollte ein Accessory aktiv sein und wird  der  Acc-Modus 
trotzdem verlassen,  so kann es evtl.  zur teilweisen Zerst”rung des  aktuellen 
Ausschnitts kommen. 

'Datei ...':
------------
In der erscheinenden Dialogbox k”nnen alle Zugriffe auf externe  Speichermedien 
erledigt werden. Dabei wird das Filesystem des GEMDOS verwendet.
'Dateiart':
Hier  kann gew„hlt werden,  was geladen bzw.   gesichert   werden   soll.   Die 
Dateiextension  ergibt  sich daraus.  Ist das 'Gesamtbild' oder  ein  Unterbild 
aktiv,   so  wirken  die  Lade-  und  Speicher-Funktionen  auf  den   aktuellen 
Bildschirm.  Das Format der Datei und damit auch deren (Backup-)Extension  wird 
in diesem Falle zus„tzlich durch das selektierte Bildformat (siehe  Bildformat) 
bestimmt.  Wurde  'Symbole'  ausgew„hlt,  so  wirken die  Lade-  und  Speicher-
Funktionen  dagegen  auf  einen  gesonderten  32KBytes-Symbole-Bildschirm   mit 
eigener Extension (siehe dazu Symbol-Funktion).  Wird 'Parameter'  gew„hlt,  so 
k”nnen alle wichtigen Grundeinstellungen geladen und gespeichert  werden.  Beim 
Laden der Parameter werden gegebenenfalls automatisch Dateien zugeladen  (siehe 
Anleitung).
'Bildformat':
Wurde  unter 'Dateiart' der Bildschirm angew„hlt,  so wird das in  diesem  Feld 
selektierte  Format  zur Speicherung und zum Laden  benutzt.  Folgende  Formate 
k”nnen benutzt werden:
1. IMG-Format:
     Komprimiertes  Format  (Image) nach Digital  Research.  Mit  Hilfe  dieses 
     Formates  k”nnen Hauptbildschirm oder dessen Unterbildschirme geladen  und 
     gespeichert werden.  Auerdem fhrt dieses Format zus„tzlich das Datum der 
     erstmaligen Erstellung und letztmaligen Ver„nderung mit sich. Im Gegensatz 
     zum   PIC-Format  wirkt  das  IMG-Format  auf  den  ganzen   Haupt-   bzw. 
     Unterbildschirm.
2. PIC-Format:
     32KByte-Bild  fr  Programme  wie SIGNUM!.  Beim Speichern  wird  aus  dem 
     aktuellen Bildschirm ein 32KBytes-Bild herauskopiert.  Beim Laden wird der 
     jeweilige Bildschirm nicht gel”scht,  sondern das sondern das Bild wird in 
     den Bildschirm eingefgt; und zwar an der Stelle, an der sich der aktuelle 
     Ausschnitt gerade befindet.
3. DOO-Format:
     Exakt wie 'PIC'-Format.
4. PI3-Format:
     32KByte-Format   mit   vorangestelltem  Erkennungscode   fr   DEGAS   und 
     DEGAS  ELITE.  Fr  das  Herausl”sen  und  Einfgen  des  Bildes  aus  dem 
     Bildschirm gelten dieselben Regeln, wie fr das 'PIC'-Format.
5. PAC-Format:
     STAD-Format, sonst wie 'PIC' behandelt
6. SEQ-Format:
     STAD-Format, wie 'PAC'
7. PCB-Format:
     Unkomprimiertes  Hochkant-Format  mit  180 Bytes  Rasterbreite  und  einer 
     maximalen H”he von 1704 Punkten fr den MPK-PCB-Editor. Dieses Format kann 
     damit nur bei aktiviertem Hochkant-Format geladen werden.
'LADEN':
Es  erscheint eine Fileselect-Box.  Hier kann die zu ladende  Datei  selektiert 
werden. Das Programm merkt sich den selektierten Suchpfad sowie den Dateinamen, 
wenn die Lade-Funktion ausgefhrt wird.
'SICHERN':
Es erscheint eine Fileselect-Box.  Hier kann die zu sichernde Datei  selektiert 
werden. Der Suchpfad sowie der Dateiname werden automatisch mit den bei 'LADEN' 
erhaltenen Daten voreingestellt. Existiert schon eine Datei gleichen Namens, so 
erscheint eine Sicherheitsabfrage. 'Abbruch' fhrt wieder zum Datei-Dialog.
'DISC-MEMORY':
Diese  Funktion  bestimmt  den  noch freien  Speicherplatz  auf  dem  aktuellen 
Laufwerk.  Dies  kann  im Zusammenhang mit einer Harddisk recht  lange  dauern. 
'FILE-INFO':
Es erscheint eine Fileselect-Box,  in der die interessierende Datei  selektiert 
werden kann. Daraufhin erscheint ein Dialog mit allen wichtigen Daten.

'ausdrucken ...':
-----------------
Wird  dieser Menpunkt angew„hlt,  so wird der externe Druckertreiber  geladen. 
Dieser   Druckertreiber  mu  'A4_PRINT.PRG'  heien  und  sich   entweder   im 
Suchpfad   des  Hauptprogramms  oder  im  darin   evtl.   befindlichen   Ordner 
'A4_GRAF' befinden. 

'ausfhren ...':
----------------
Bei   Anwahl  dieses  Punktes  erscheint  eine  Fileselect-Box,   in  der   das 
auszufhrende Unterprogramm selektiert werden kann.

'Neustart ...':
---------------
Wird  dieser Menpunkt bet„tigt,  so wird nach letzter  Sicherheitsabfrage  das 
Programm  ohne Sichern des aktuellen Bildes,  aktueller Symbole oder  Parameter 
neu gestartet. 

'Ende':
-------
Hier  wird  nach  letzter  Sicherheitsabfrage das  Programm  ohne  Sichern  des 
aktuellen Bildes, aktueller Symbole oder aktueller Parameter verlassen. 

'Zeichnen':
-----------
Generell  ist auch innerhalb einer Grafikfunktion das Betreten des  Men's  und 
der Fensterrahmenteile m”glich.  So kann z.B. innerhalb der Linien-Funktion das 
Aussehen der Linie ver„ndert werden.  Wird ein Fensterrahmenteil angeklickt, so 
wird die Grafikfunktion allerdings abgebrochen.  Ein 'UNDO' ist dann nicht mehr 
m”glich.  Die  Maustasten werden bei Positionierungen nur kurz  angeklickt.  So 
kann  die  genaue Positionierung der Grafikkoordinaten auch  ber  die  Cursor-
Tasten in  Verbindung  mit  'Alternate'  und  'Shift'  erfolgen.  Ein Bet„tigen 
der  rechten  Maustaste  bricht immer  die  aktuelle  Grafikfunktion  ab.  Alle 
Grafikfunktionen  k”nnen  durch Druck auf die 'Undo'-Taste  rckg„ngig  gemacht 
werden.  Die  Undo-Funktion  ist dabei im  Allgemeinen  umschaltend,  d.h.  ein 
weiterer  Druck  auf  die 'Undo'-Taste macht die  Undo-Funktion  selbst  wieder 
rckg„ngig.
Bei  der  Implementierung  der Grafikfunktionen  wurde  ganz  besonders  darauf 
geachtet,  da diese weitestgehend unabh„ngig zu den Hilfsfunktionen sind. Dies 
geht sogar soweit, da z.B. erst der Mittelpunkt eines Kreises definiert werden 
kann, dann bei aktivem Kreismodus ein Block oder Symbol (oder beides) definiert 
oder  gesetzt  werden  kann  ('UNDO' kann  natrlich  auch  noch  zwischendurch 
bet„tigt  werden ) und dann mit der Definition des Kreises fortgefahren  werden 
kann.

'Line':
-------
Nach Anw„hlen dieses Menpunktes befindet sich das Programm im Linienmodus. Ist 
das  Fadenkreuz  sichtbar,  so  kann  mit Druck auf  die  linke  Maustaste  der 
Linienanfangspunkt  gesetzt werden.  Wird die linke Maustaste ein weiteres  Mal 
bet„tigt,  so  wird die Linie gesetzt und der gesetzte Punkt als  Anfang  einer 
neuen Linie interpretiert. 

'Box':
------
Nach Anklicken dieses Menpunktes befindet das Programm sich im Rechteck-Modus. 
Durch  Druck  auf  die linke Maustaste k”nnen beide Ecken  des  zu  zeichnenden 
Kastens gesetzt werden. 

'Circle':
---------
Durch  Anklicken  dieses  Menpunktes  wird das  Programm  in  den  Kreis-Modus 
versetzt.  Mit  Hilfe  der  linken Maustaste kann nun der  Mittelpunkt  des  zu 
zeichnenden Kreises gesetzt werden.  Es erscheint an dieser Stelle eine  kleine 
Markierung,  die  den Umgang mit der Kreisfunktion erleichtern soll,  die  aber 
nicht mitgezeichnet wird.  Nachdem ein Kreismittelpunkt definiert wurde, bewegt 
sich der Fadenkreuz-Mittelpunkt auf dem Umfang des Kreises.  Ein zweiter  Klick  
auf   die   linke   Maustaste  fixiert  den   Kreis   -   die   Hilfsmarkierung 
verschwindet. 

'Ellipse':
----------
Mit  Hilfe dieses Menpunktes wird zum Ellipsen-Modus gewechselt.  Durch  linke 
Maustaste  kann  der Mittelpunkt bestimmt werden.  Anders als  bei  der  Kreis-
Funktion tangiert die zu zeichnende Ellipse das Fadenkreuz.  Die Markierung des 
Ellipsen-Mittelpunktes dient der Erleichterung des Zeichnens und  verschwindet, 
wenn die Ellipse mit linker Maustaste gesetzt wird. 

'Text':
-------
Diese Funktion erm”glicht das Setzen von Texten.  Ist das Fadenkreuz  sichtbar, 
so  kann  ber  die Tastatur eine Zeile Text  eingegeben  werden.  Dieser  Text 
erscheint  direkt am Fadenkreuz und kann frei bewegt  werden.  Zur  Texteingabe 
steht   der   gesamte  ATARI-Zeichensatz  mit   Sonderzeichen   zur   Verfgung 
(siehe Anleitung). Ein einmal eingegebener Text bleibt solange erhalten, bis er 
entweder  gesetzt  wird  oder bis die rechte  Maustaste  bet„tigt  wird.  Durch 
Bet„tigen  der  rechten  Maustaste wird der vom  Fadenkreuz  nachgezogene  Text 
gel”scht.
Wird  'Backspace'  gedrckt,   so  wird  nur  der  letzte  Buchstabe  des   vom 
Fadenkreuz  nachgezogenen Textes gel”scht.  Mit linker Maustaste kann der  Text 
gesetzt  werden.  Die  Undo-Funktion macht nicht nur das  Setzen  eines  Textes  
rckg„ngig,    sondern    merkt   sich   auch   noch   den    vom    Fadenkreuz 
nachgezogenen Text,  solange der Bildausschnitt nicht ver„ndert wird. Damit ist 
ein echtes Umschalten der Undo-Funktion erreicht.  Eine Alternative zum  Setzen 
des Textes stellt die 'Return'-Taste dar.  Dabei wird zus„tzlich das Fadenkreuz 
um Zeilenabstand nach "unten" bewegt.  Das Wort 'unten' bezieht sich dabei  auf 
die tats„chliche Textausrichtung !  So kann auch kopfber ein zusammenh„ngender 
Text geschrieben werden. Der Zeilenabstand variiert dabei mit der eingestellten 
Texth”he.  Das  Fadenkreuz schnappt brigens nicht ein,  um den Tatendrang  des 
Benutzers nicht zu hemmen.  Deshalb darf bei  zusammenh„ngenden Texten die Maus 
nicht bewegt werden.  Dies ist aber auch nicht n”tig, da die Maus komplett ber 
die Tastatur simuliert werden kann.
Die Textfunktion benutzt den gerade aktuellen Zeichensatz.  Dieser  Zeichensatz 
ist  im  Allgemeinen  der System-Zeichensatz.  Es kann aber  auch  ein  anderer 
Zeichensatz installiert we2den (siehe Anleitung).

'Fill':
-------
Ausgel”st  wird  sie mit linker Maustaste.  Innerhalb dieser Funktion  ist  die 
Rastung  immer inaktiv,  weil sie hier nur st”ren wrde.  Im ungnstigen  Fall, 
wenn  z.B.  auf  ein schon vorhandenes Fllmuster geklickt  wurde,  kann  diese 
Funktion  sehr  lange  dauern.   Hier  hilft  nur   Warten,   da   sich   diese 
Funktion  nicht unterbrechen l„t.  Wird innerhalb der Fllfunktion  auf  einen 
Punkt der unter 'Farbe' eingestellten Farbe geklickt,  so wird die Fllfunktion 
nicht ausgel”st. 

'Rubber':
---------
Wird  dieser Menpunkt bet„tigt,  so zieht das Fadenkreuz einen  Kasten  hinter 
sich  her,  mit  dem  Teile des Bildes durch  linke  Maustaste  gel”scht  (bzw. 
gesetzt) werden k”nnen.  Wird die rechte Maustaste bet„tigt,  so gelangt man in 
den Definitionsmodus. Hier l„t sich die Gr”e des Radierers einstellen und mit 
linker  Maustaste best„tigen.  Wird innerhalb des Definitionsmodus  die  rechte 
Maustaste  gedrckt,   so  wird  dieser  ohne  Ver„nderung  der  Radierer-Gr”e 
verlassen.

'RBox':
-------
Diese Funktion erzeugt Rechtecke mit abgerundeten Ecken.  Die Ecken haben dabei 
immer  denselben Radius.  Diese Funktion wird genauso bedient,  wie die  'Box'-
Funktion. 

'Spray':
--------
Mit dieser Funktion k”nnen kontinuierliche šberg„nge an Fllmustern  geschaffen 
werden. Wird die linke Maustaste gedrckt gehalten, so sprht diese Funktion in 
einem  kreisf”rmigen Gebiet um den Grafikcursor herum das  gerade  eingestellte 
Fllmuster (genaueres siehe Anleitung).

'QCircle':
----------
Diese  Funktion erzeugt Viertelstcke von Kreisen.  Hiermit k”nnen  z.B.  Ecken 
abgerundet  werden.  Diese  Funktion wird genauso bedient,  wie  die  'Circle'-
Funktion. 

'HCircle':
----------
Diese  Funktion  erzeugt halbe Kreisstcke und wird genauso  bedient,  wie  die 
'Circle'-Funktion. 

'PCircle':
----------
Mit  dieser Funktion k”nnen durch 3 Punkte definierte Kreise gezeichnet  werden 
(weiterfhrende Informationen siehe Anleitung).

'Curve1':
---------
Mit Hilfe dieser Funktion k”nnen Kurvenstcke gezeichnet werden.  Dazu wird mit 
den ersten beiden Mausklick's die Grundlinie des Kurvenstckes festgelegt. Dann 
werden mit zwei weiteren Mausklick's zwei Tangenten definiert und die  Funktion 
gezeichnet (genaueres siehe Anleitung).

'Curve2':
---------
Dieser   Funktion   liegt   dieselbe   Grafikfunktion   zugrunde,    wie    bei 
'Curve1'.  Die zu definierenden Punkte haben nur eine andere Reihenfolge.  Hier 
wirkt jeder neue Punkt als Tangentenrichtung zu den anderen Punkten. 

'Farbe':
--------
Wird  dieser  Menpunkt angew„hlt,  so werden  alle  Grafik-Funktionen  schwarz 
gezeichnet, sonst wei.

'Ersetzen,   Transparent,   Exklusiv   oder, ...':
--------------------------------------------------
Gibt fr alle Funktionen den Grafikmodus an.  Sie  sollten alle Effekte  einmal  
selbst  auf  weiem  und  schwarzem Untergrund ausprobieren (siehe Anleitung).

'Linientyp':
------------
In  dieser  Dialogbox   kann  der   Linienstil   fr   die  Linien-orientierten 
Grafik-Funktionen ausgew„hlt werden (siehe Anleitung).  Es kann hier auch  eine 
Linienfunktion korrekter Dicke selektiert werden.

'Gefllt':
----------
Wird  dieser  Punkt angew„hlt,  so werden fl„chige  Grafikfunktionen  wie  z.B. 
Kasten oder Kreis mit dem aktuellen Fllmuster gefllt. 

'Fllumrandung':
----------------
Wird  dieser  Eintrag  aktiviert,  so  werden  gefllte  Grafik-Funktionen  mit 
schwarzem Rand gezeichnet.

'Fllmuster':
-------------
Wird dieser Punkt angew„hlt,  so erscheint eine Dialogbox,  in der das aktuelle 
Fllmuster  selektiert  werden  kann.   Hier  kann  auch  das   Benutzer-eigene 
Fllmuster   selektiert   werden.   Es   kann  hier   jedoch   nicht   editiert  
werden (genaueres siehe Anleitung).

'Textaussehen':
---------------
Nach  Anklicken dieses Menpunktes erscheint eine Dialogbox,  in der die  Text-
Attribute ge„ndert werden k”nnen. Mit Hilfe der 5 Button's links kann das Text-
Aussehen ge„ndert werden.  Wird das obere oder das untere Pfeilfeld angeklickt, 
so  wird die Texth”he in 4 Schritten ver„ndert.  Wird das Pfeilfeld links  oder 
rechts angeklickt, so „ndert sich der Textwinkel in 90Grad-Schritten. 

'Rastung...':
-------------
Es  ist  m”glich,  innerhalb eines unsichtbaren Rasters zu  zeichnen.  Ist  die 
Rastung  eingeschaltet,  so bewegt sich das Fadenkreuz sprunghaft  entsprechend 
der eingestellten Rastweite.  Die Rastung kann durch Anklicken des  Menpunktes 
'Ein' oder durch Selektieren einer der 6 Rastweiten eingeschaltet  werden.  Die 
Rastweiten  k”nnen ver„ndert werden (siehe Anleitung).  Der  Ausgangspunkt  des 
unterlegten Rasters ist im Allgemeinen die Koordinate 0/0, also die linke obere 
Ecke  des Bildschirmes.  Der Ausgangspunkt des Rasters kann aber auch  beliebig 
ge„ndert werden (siehe Anleitung).

'Koordinaten...':
-----------------
Wird 'Abs.' selektiert,  so werden die absoluten Koordinaten gerechnet von  dem 
Koordinaten-Ursprung  des Bildes angezeigt.  Dieser Ursprung kann (wie bei  der 
Rast-Funktion auch) ver„ndert werden (siehe Anleitung).  Wird 'Rel.' angew„hlt, 
so  werden die relativen Koordinaten gerechnet vom letzten  angeklickten  Pixel 
angezeigt.  Bei Selektierung von 'Pol.' werden die Polarkoordinaten relativ zum 
letzten   gesetzten  Pixel  angezeigt.   Der  Koordinaten-Ursprung   wird   bei 
Bildwechsel  in  das  neue  Bild  hinein  transformiert,   d.h.  die  Lage  des 
Koordinaten-Ursprungs zur linken oberen Ecke des Bildes bleibt erhalten  (siehe 
Anleitung).  Eine  metrische  oder  z”llige  Koordinatenanzeige  ist  ebenfalls 
m”glich. 

'Lupe':
-------
Zur  schnelleren genauen Positionierung des Fadenkreuzes steht  eine  Hilfslupe 
variabler  Gr”e  (siehe Anleitung) zur Verfgung.  Diese  Hilfslupe  kann  mit 
diesem Meneintrag ein- und ausgeschaltet werden. 

'Symbol-Maske':
---------------
Wird dieser Menpunkt aktiviert, so erfolgt die Symbol-Funktion maskiert (siehe 
Anleitung). 

'Anleitung':
------------
Siehe unter 'An den Benutzer' am Anfang dieser Kurzanleitung. 

'Gesamtbildschirm':
-------------------
Mit Hilfe dieses Menpunktes kann halbautomatisch zwischen Gesamtbildschirm und 
Unterbildschirm gewechselt werden.  Ist der Gesamtbildschirm aktiv, so wird bei 
Anklicken  von  'Gesamtbildschirm'  der Unterbildschirm  gesucht,  in  den  der 
aktuelle  Bildausschnitt  haupts„chlich  f„llt.  Dann  wird  der  entsprechende 
Unterbildschirm aktiviert.  So entf„llt fr den Benutzer die  Entscheidung,  in 
welchen Unterbildschirm  der  aktuelle  Ausschnitt  f„llt.   Wird  bei  aktivem 
Unterbildschirm der Eintrag 'Gesamtbildschirm' angeklickt, so wird der aktuelle 
Ausschnitt beibehalten und auf Gesamtbild umgeschaltet. 

'Bild 1, Bild 2, Bild 3, Bild 4':
---------------------------------
šber  diese  4 Punkte k”nnen die 4 Unterbildschirme  direkt  angew„hlt  werden. 
Dabei merkt sich das Programm die jeweiligen Ausschnitte der  Unterbildschirme, 
damit schnell zwischen Ausschnitten gewechselt werden kann. 

'Bild kopieren':
----------------
Dieser Punkt ist nur innerhalb von Unterbildschirmen anw„hlbar.  Nach Bet„tigen 
des  Menpunktes erscheint eine Bedienungsbox.  Zum Kopieren bewegt   man   den 
Mauszeiger  ber das Feld des zu kopierenden Unterbildschirmes.  Dann wird  die 
linke  Maustaste gedrckt gehalten,  woraufhin eine gepunktete  Box  erscheint. 
Diese  Box schiebt man nun auf das Feld des Ziels der Kopierfunktion  und  l„t 
die  Maustaste  los.  Nun wird der Unterbildschirm in  einen  anderen  kopiert. 
K”nnten Daten verloren gehen, so erscheint vorher noch eine Sicherheitsabfrage. 

'Bild vergr”ern':
------------------
Dieser  Punkt  ist  nur  innerhalb  von  Unterbildschirmen  anw„hlbar.   Dieser 
Menpunkt  dient  dem  Vergr”ern  eines Unterbildschirmes  um  den  Faktor  2. 
šberschreitet  die Vergr”erung die Grenzen des  Unterbildschirmes,  so  werden 
alle anderen Unterbildschirme vorher gel”scht.  Dann wird zum  Gesamtbildschirm 
gewechselt.  Diese  Aktion  wird  aber  schon  in  der  Alert-Box,  die  vorher 
erscheint,  angekndigt.   Ist  z.B.  der Ausdruck eines  Unterbildschirmes  zu 
klein, so kann auf diese Weise ein gr”erer Ausdruck erreicht werden.

'Bild verkleinern':
-------------------
Wird  dieser  Menpunkt angew„hlt,  so wird nach einer  Sicherheitsabfrage  das 
aktuelle  Bild  um  den Faktor 2 in Richtung  beider  Achsen  verkleinert.  Die 
Grundhelligkeits-Verteilung des Bildes bleibt dabei erhalten.

'Bild l”schen':
---------------
Nach Anw„hlen dieses Menpunktes erscheint, wenn der Bildschirm nicht leer ist, 
eine  Sicherheitsabfrage.   Der  aktuelle  Bildschirm  wird  gel”scht  und  die 
Fensterschieberegler werden auf ihre Nullpositionen gesetzt.

'Bild-Statistik':
-----------------
Nach  Anw„hlen  dieses  Menpunktes erscheint eine  Informationsbox  mit  allen 
wichtigen  Kenndaten  der  Bilddatei.  Hier kann bei nicht leerem Bild auch der 
Name des Bildes eingegeben werden. Dieser Name wird jedoch gel”scht, sobald das 
betreffende  Bild  leer ist.  Die  Statistik-Box  kann  durch   Bet„tigen   des 
'OK'-Knopfes verlassen werden. 

'Hochkant-Format':
------------------
Mit   Hilfe   dieses  Menpunktes  kann  umgeschaltet   werden   zwischen   dem 
Hochkant-Format (Gesamtbild 1440 Punkte breit, 1984 Punkte hoch)/(Unterbild 720 
Punkte  breit,  992  Punkte hoch) und dem Quer-Format (Gesamtbild  1984  Punkte 
breit,  1440 Punkte hoch)/(Unterbild 992 Punkte breit,  720 Punkte  hoch).  Die 
Drucker-Ausgabe  erfolgt mit der Einstellung 'Quer' am  schnellsten.  Das  PCB-
Format  kann dann allerdings nicht benutzt werden.  Bei der Umschaltung  bleibt 
soviel   wie  m”glich  vom  aktuellen  Bild  erhalten.   Auerdem  werden   der 
Koordinaten-Ursprung sowie die relative Koordinatenanzeige zurck gesetzt.

Zoom-Funktion:
==============
Sie  wird ber die Funktionstasten angew„hlt und beinhaltet eine  ausgeklgelte 
Undo-Funktion (siehe Anleitung).

Block-Funktion:
===============
Ist  das  Fadenkreuz  sichtbar,  so  kann  die  Block-Funktion  mit  der  Taste 
'Esc' erreicht werden.  Daraufhin wird das Fadenkreuz durchgezogen dargestellt. 
Es  kann nun wie bei der Kasten-Funktion ein Rechteck  aufgezogen  werden.  Der 
Inhalt dieses Rechtecks bildet den aktuellen Block.  Wurde auf diese Weise  ein 
Block   definiert,   so  kann  dieser  mit  linkem  Maus-Klick  innerhalb   des 
Bildschirmes gesetzt werden.  In diesem Status kann auch der Bildausschnitt mit 
Hilfe  der  Fensterschieberegler  ver„ndert  werden,   ohne   da   der   Block 
verloren geht.  Mit rechter  Maustaste  wird  wieder  zur  vorherigen   Grafik-
Grundfunktion zurck gesprungen.  Wie bei den Grafik-Grundfunktionen k”nnen die 
Grafik-Attribute ver„ndert werden,  ohne die Block-Funktion zu  verlassen.  War 
schon einmal ein Block aktiv, so wird mit der 'Esc'-Taste wieder der alte Block 
aktiviert.  Erst ein zweiter Druck auf diese Taste l„t wieder eine neue Block-
Definition  zu.  Wird im Block-Definitionsmodus eine beliebige Taste  oder  die 
rechte Maustaste gedrckt,  so wird der aktuelle Block nicht ver„ndert.  Bl”cke 
k”nnen auch in Verbindung mit der Rastung sinnvoll eingesetzt sowie  gespiegelt 
und gedreht werden (siehe Anleitung).
In  Verbindung  mit  dem Symbol-Bildschirm l„t sich  die  Block-Funktion  auch 
anwenden.  So kann der Symbol-Bildschirm als Zwischenspeicher fr gerade  nicht 
ben”tigte Bl”cke genutzt werden. Auf diese Art k”nnen auch Bl”cke abgespeichert 
und geladen werden (siehe Anleitung).


Symbol-Funktion:
================
Die  Symbol-Funktion  soll das Erstellen von  Schaltpl„nen  und  Leiterplatten-
Layout's erleichtern.  Hier werden nur sehr kleine Symbole ben”tigt. Ein Symbol 
soll hier aus 31 mal 31 Punkten bestehen.  So passen auf einen normalen Grafik-
Bildschirm  240  Symbole.  Wird  der  Men-Eintrag  'Symbol-Maske' deaktiviert, 
so  stehen  alle  240 Symbole zur  Verfgung.  Speziell  beim  Erstellen  einer 
Leiterplatte wird zus„tzlich eine Maske ben”tigt, die unter dem Symbol vor  dem  
Setzen   genau  definierte  Punkte  l”scht.   Wird  der  Men-Eintrag  'Symbol-
Maske'  aktiviert,  so wird die letzte Symbole-Zeile im  Symbol-Bildschirm  als 
Maske fr die darber liegenden Symbole interpretiert.  Auf diese Weise  stehen 
dann 220 Symbole mit 20 Masken zur Verfgung.  Fr die Ansteuerung der  Symbole 
gilt im Prinzip dasselbe Verfahren,  welches auch fr Bl”cke gilt. Es mu jetzt 
allerdings statt der Taste 'Esc' die Taste 'Tab' gedrckt werden.  Jedes Symbol 
kann  editiert,  gedreht,  gespiegelt und auf dem  Symbolbildschirm  verschoben 
werden (siehe Anleitung).


Fehlerbehandlung:
=================
Zur  Sicherheit wurde eine Fehlerbehandlung implementiert,  die die  Daten  auf 
Diskettenlaufwerk  A  speichert,  wenn  ein  schwerer  Fehler  auftritt  (siehe 
Anleitung).


beseitigte Fehler:
==================
~ bei Wechsel von Hoch- zu Querformat sind erste Pixel-Zeilen falsch
~ weitreichender Fehler in Routine fr maximale Koordinate im Bild
~ Raster-Ursprung falsch bei Wechsel des aktuellen Bildes
~ 'OK' mit leerem Dateinamen verl„t File-Info-Selektorbox nicht
~ Fllmuster-Sprher funktioniert nicht bei Liniendicke > 1
~ eigene ALERT-Boxen w„hrend Aufbau Tastatur-Instabil
~ Fadenkreuz rastet auch beim Radieren
~ Fadenkreuz in Funktionstasten-Lupe flimmert beim Setzen/L”schen von Punkten
~ manchmal beim Betreten von Dialogboxen scheinbar Maustaste gedrckt


                             *********************
                             * GEM A4_PRINT 2.01 *
                             *********************

Hardware-Voraussetzungen:
=========================
Es  wird ein zum 'NEC P2200' kompatibler 24-Nadel-Drucker ben”tigt.  Der  'STAR 
LC24-10' sowie die 'NEC P6' und 'NEC P7' sind kompatibel. 


Einfhrung:
===========
Das  'A4_PRINT.PRG' ist ein Druckertreiber,  der nur von 'A4_GRAF.PRG'  benutzt 
werden  kann.  Dazu erh„lt er vom Hauptprogramm Adressen und Koordinaten  sowie 
Parameter.  'A4_PRINT'  wird zwar von 'A4_GRAF' aufgerufen,  hat aber  trotzdem 
fast   dieselben  Zugriffsrechte.   Ein  auszudruckendes  Bild  braucht   nicht 
abgespeichert  zu  werden,  weil  der Druckertreiber direkt  auf  den  Speicher 
zurckgreift.   Auch   ist   eine  extra  Parameterdatei  zur   Sicherung   der  
Voreinstellungen nicht n”tig.  Die Voreinstellungen des Druckertreibers  werden 
vom  Hauptprogramm  verwaltet  und  in  seiner  Parameterdatei    'A4_GRAF.PAR'  
abgespeichert.   Der   Druckertreiber   verfgt  brigens  zur   Erh”hung   der 
Datensicherheit  wie das Hauptprogramm ber eine Not-Sicherungs-Routine  (siehe 
Beschreibung des Hauptprogrammes !). 


'Initial.':
===========
Hier kann eingestellt werden, wann der Drucker einen Befehl zur Initialisierung 
bekommen soll.  Dieser Initialisierungsbefehl ist bei Einzelblatt-Benutzung fr 
den  Auswurf  des  Blattes  ntzlich.  Auerdem schafft  er  im  Drucker  klare 
Verh„ltnisse.  Ob allerdings der Druckpuffer des Druckers gel”scht wird, mu im 
Handbuch nachgelesen werden.  Beim 'NEC P2200' ist dies zum Beispiel nicht  der 
Fall.  Wird 'Vorher' selektiert,  so wird vor  Druckbeginn  ein   Drucker-Reset 
gesendet.  Wird 'Nachher' gew„hlt, so wird nach dem Druckende ein Drucker-Reset 
gesendet.  Nach der Drucker-Initialisierung wird auerdem noch ein 'Form  Feed' 
gesendet.


'Rand':
=======
Manchmal  soll das auszudruckende Bild nicht ganz links oben  auf 
dem Blatt erscheinen,  sondern weiter zur Blattmitte hin. Um dies 
zu  erm”glichen,   sind  die  Randeinstellungen  vorgesehen.  Der 
eingegebene Rand wird in 1/10 Zoll-Vorschben realisiert und  ist 
somit   vertikal   und   horizontal   gleichwertig.    Bei    der 
Randeinstellung  sind  nur  Werte  kleiner  als  die   Blattgr”e 
zul„ssig.  Ist das auszudruckende Bild fr die Randeinstellung zu 
gro, so wird es rechts abgeschnitten. 


'Blattgr.':
===========
Bei  verschiedenen Druckern ist der Ausdruckbereich nicht genau 8 mal  11  Zoll 
gro,  besonders wenn ein automatischer Einzelblatteinzug benutzt wird. Dehalb 
kann  hier  der tats„chliche Ausdruckbereich  eingegeben  werden.  Diese  Werte 
sollten  auf  keinen Fall zu gro gew„hlt werden,  da sonst die  Grafik  auf  2 
Bl„tter verteilt wird. Kleinere Werte k”nnen z.B. als 'Clipping' dienen.


'Qualit„t':
===========
Mit  Hilfe  der 4 m”glichen Qualit„ten sind schnelle bis  sehr  gute  Ausdrucke 
m”glich (siehe Anleitung).


'ABBRUCH':
==========
Bei Bet„tigen dieses Knopfes wird unverzglich das 'A4_PRINT.PRG' verlassen und  
zum  Hauptprogramm  zurck  gekehrt.   Die  im  Drucker-Dialog  evtl. gemachten 
Ver„nderungen werden ignoriert. 


'AUSDRUCKEN':
=============
Wird  'Ausdrucken' selektiert,  so erfolgt eine Sicherheitsabfrage mit  Anzeige 
der  Druckqualit„t sowie der grob berechneten Dauer des Ausdruckes in  Minuten. 
Sollten  Sie den NEC P2200  benutzen  und  Druckfehler  in  Form  von   kleinen  
Versetzungen  bemerken,  so  ist  dies nicht auf  einen  Fehler  des  Programms 
zurckzufhren.  Der  NEC  P2200 (zumindestens „ltere P2200)  ben”tigt  Strobe-
Impulse  einer L„nge,  die die interne BIOS-Routine des TOS vom ATARI-ST  nicht 
erzeugt.  Abhilfe  schafft   eine  kleine  Hardware-Schaltung,   die   in   die 
Strobe-Leitung eingefgt wird (siehe Anleitung).

'OK':
=====
Bei Bet„tigen dieses Knopfes wird unverzglich das 'A4_PRINT.PRG' verlassen und  
zum  Hauptprogramm  zurck  gekehrt.   Die  im  Drucker-Dialog  evtl. gemachten 
Ver„nderungen  werden  vom Hauptprogramm ausgewertet und stehen  beim  n„chsten 
Betreten des Drucker-Dialogs wieder zur Verfgung. 


Erg„nzende Hinweise:
====================
Wer z.B.  einen anderen nicht kompatiblen Drucker besitzt,  auf einen  Ausdruck 
aber nicht verzichten will, der sollte sich den speziellen Druckertreiber dafr 
selbst  schreiben.  Die  Anbindung an 'A4_GRAF' ist  dafr  schon  fertig.  Dem 
Hauptprogramm  liegt n„mlich ein Programm namens 'A4_DEMO' sowie dessen  ASCII-
Quelltext   'A4_DEMO.LST'   bei.   Dieses  Programm  kann   vom   Hauptprogramm 
aufgerufen werden (siehe Anleitung).
Sie mssen also "nur" noch die Druckeranpassung selbst schreiben. Wenn Sie noch 
eine  ganz  super-duper-tolle Funktion an 'A4_GRAF' vermissen,  so  k”nnen  Sie 
natrlich   mit   Hilfe   des  'A4_DEMO.LST'   diese   Funktion   auch   selbst 
implementieren. 


beseitigte Fehler:
==================
~ bei Querformat wird evtl. letzte auszudruckende Zeile verschluckt



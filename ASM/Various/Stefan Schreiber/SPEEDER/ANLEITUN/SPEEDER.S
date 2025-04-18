                              
                                        Stefan Schreiber
                                        Kesselweg 14
                                        8650 Kulmbach
                                        Tel.: 09221/75365


                           Speeder ST
  ( Beschleunigungszusatz f�r Diskettenzugriffe des Atari ST )

Das  Programm Speeder.prg darf frei kopiert werden,  sollte  aber 
nicht von den anderen Files im Ordner getrennt werden.
Sie sollten folgende Files auf der PD-Diskette vorfinden:
1. Speeder.prg: das eigentliche Programm
2. Speeder.q  : der dazugeh�rige Assembler-Quelltext
3. Speeder.doc: wenn dieses File  nicht vorhanden ist, k�nnen Sie   
   diesen Text nicht lesen / genie�en / in den Desktop-Papierkorb         
   werfen.

I. Einf�hrung
     Das      Programm      Speeder.prg      verdoppelt       die 
Schreib/Lesegeschwindigkeit  der  Diskettenlaufwerke   mit  allen 
TOS-Versionen,  sogar wenn dieses auf ROM(!) installiert ist.  Es 
arbeitet mit jeder Atari ST-Konfiguration zusammen.
Da�  diese reine Softwarel�sung auch mit  ROM-Betriebssystem  zu-
sammenarbeitet, ist eine kleine Sensation. Gerechterweise mu� ich 
aber zugeben, da� das Programm Fastload des Markt&Technik-Verlags 
dies ebenfalls erreicht,  was ich aber erst nach der  Fertigstel-
lung meines eigenen Programms "Speeder" erfahren habe.
"Speeder"   ist   v�llig  unabh�ngig  vom   Programm   "Fastload" 
entstanden,  das  mir keineswegs als Inspiration  gedient  hat. 
Folglich unterscheiden sich beide Programme auch  im  verwendeten 
Algorithmus. Insgesamt halte ich mein eigenes Programm aber sogar 
f�r etwas leistungsf�higer als das Konkurrenzprodukt Fastload, da
"Speeder"   weniger  Speicherplatz  reserviert  und   mit   jeder 
Betriebssystemsversion lauff�hig ist.


II. Theoretische Grundlagen des Projekts "Speeder"

     Ma�gebend f�r die Geschwindigkeit eines Computers ist  nicht 
nur  seine   Prozessorleistung,   sondern  vor  allem  auch   die 
Leistungsf�higkeit seiner Peripherie,  v.a. Diskettenlaufwerk und 
Drucker.  Der  Atari ST weist hier von Haus aus gute  F�higkeiten 
aus:    Beim    Lesen   ergibt   sich   eine    durchschnittliche 
Geschwindigkeit von 8 KByte/sec.  bzw. ungef�hr 4 KByte/sec. beim 
Schreiben.
Allerdings ist schon seit ca. einem Jahr in der ST-Szene bekannt, 
da� diese Geschwindigkeiten durch die Ausschaltung eines Verifys 
verdoppelt werden k�nnen.  Dies bringt so gut wie keine Nachteile 
mit sich,  wie ich sp�ter noch genauer erl�utern werde. Einer der 
ersten dazu einschl�gigen Tips stammte beispielsweise von  Oliver 
Joppich,  der  einen entsprechenden Betriebssystempatch in  einer 
"ST- Computer" beschrieb ( Ausgabe Mai 1986 ).  Allerdings sprach 
er  nur  von einer Verdopplung  der  Lesegeschwindigkeit,  obwohl 
durch diesen Patch ( direkte Ver�nderung in einem Programm,  hier 
im TOS ) sich auch die Schreibgeschwindigkeit verdoppeln mu�, wie 
man   theoretisch leicht begr�nden kann.
  Meines Wissens wird im vorliegenden Text zum erstenmal  detail-
liert  beschrieben,  was die Ausschaltung des  Track-Verifys  f�r 
Konsequenzen hat. Eine Warnung im voraus: Dies ist keine "leichte 
Materie".  Etwas  Aufmerksamkeit  wird durchaus  gefordert.  
Also:  Konzentration!  Spannung!  Aufwachen!!!!!  
(  Ich dementiere entschieden,  da� dieser Text  die  Demoversion 
des  ersten  deutschen  Infocom-Adventures  ist.   Er  ist   zwar 
"interaktiv",  ansonsten  fehlen  ihm jedoch  s�mtliche  Merkmale 
eines Spiels... )
 

Was  bewirkt das Programm "Speeder.prg" nun konkret und  ist  bei 
der Sache nicht doch ein Haken? Um evtl. �ngste der Skeptiker und 
Sicherheitsfanatiker  zu  zerstreuen,  m�chte  ich  einen  kurzen 
Ausflug  in die Theorie des Floppy Disc Controllers ( FDC  )  des 
Atari ST unternehmen.
Der FDC bietet unterschiedliche Vorkehrungen, die Datensicherheit 
zu erh�hen. Es existieren haupts�chlich drei Arten eines Verifys:

1. Lesen eines Sektors:  Der FDC arbeitet bereits  hardwarem��ig 
   mit Pr�fsummen.  Wenn ein Sektor auf die Diskette  geschrieben 
   wird,  f�gt der FDC automatisch eine 16-Bit Pr�fsumme an,  die 
   er    aus den �bertragenen Datenbytes berechnet.  Der Anwender 
   merkt von    diesem Vorgang �berhaupt nichts.  Diese Pr�fsumme 
   wird  auch  als     "Cyclic Redudancy  Check"  oder  kurz  CRC 
   bezeichnet.  Beim  Lesen    vergleicht der FDC  die  CRC-Pr�f-
   summe,  die er beim Lesen berechnet, mit der bereits abgespei-
   cherten.  Ein Lesefehler wird mit h�chster  Wahrscheinlichkeit 
   bemerkt.
   
2. Schreiben eines Sektors: Hier ist das Verifizieren nicht ganz
   so  einfach.   Der  FDC  kann  jedenfalls  nicht   unmittelbar 
   herausfinden, ob die Daten auf der Diskette richtig angekommen 
   sind.  Die Verify-Routine des TOS verwendet hier einen kleinen 
   Trick:
   Alle geschriebenen Sektoren werden nach dem Schreiben in einen 
   eigenen   1024  Byte-Puffer  eingelesen  (  512  Bytes   w�ren 
   mindestens  erforderlich  ).  Wenn beim Schreiben  ein  Fehler 
   aufgetreten  ist,  kann dies �ber die  CRC-Logik  festgestellt 
   werden,  da  logischerweise nun auch ein CRC-Fehler  auftreten 
   mu�.  Es ist so immerhin nicht notwendig,  da� alle  geschrie-
   benen  Daten  mit den im Speicher vorhandenen  Byte  f�r  Byte 
   verglichen werden m�ssen.
   Durch diese Methode halbiert sich im allgemeinen die Schreib-
   gegen�ber  der  Lesegeschwindigkeit,   da  jeder  geschriebene 
   Sektor noch einmal zum Verifizieren gelesen werden mu�. Dieses 
   Verify  kann  �ber das  Betriebssystem  ausgeschaltet  werden, 
   indem  die  Systemvariable  $444 auf  einen  Wert  ungleich  0 
   gesetzt  wird.  Dies ist aber aus Gr�nden der  Datensicherheit 
   wirklich riskant. 
 
3. Track-Verify nach Positionierung des Schreib/Lesekopfes: 
   Nach  einer Positionierung des Schreib/Lesekopfes durch  einen 
   SEEK-,  RESTORE oder STEP-Befehl des FDC besteht die  M�glich-
   keit,  zu �berpr�fen,  ob der logische Track mit dem physikal. 
   Track  auf  der  Diskette  �bereinstimmt.   Es  kann   n�mlich 
   vorkommen,  da�  der Schrittmotor des  Diskettenlaufwerks  den 
   Befehlsimpulsen zur Positionierung nicht folgen kann und  sich 
   dann auf einem falschen Track befindet. Zum Verifizieren liest 
   der FDC das ID-Feld des n�chsten Sektors, in dem Seite, Track, 
   Sektornummer und Gr��e als Informationen �ber den betreffenden 
   Sektor abgelegt sind.
   Die BIOS-Routine 4 ( "rwabs" ),  �ber die fast alle Disketten-
   zugriffe  laufen,  macht von diesem Verify beim  Positionieren 
   Gebrauch.  Die entsprechende Stelle liegt bei jeder  Betriebs-
   systemversion  nat�rlich woanders.  Bei der ROM-Version  liegt 
   sie an der Addresse $FC1B8A:
   $FC1B8A:    moveq.l   #14,d6    ; SEEK mit Verify
   $FC1B90:    bsr       $FC1BB6   ; an FDC schicken

   Im  "Atari  ST  INTERN" von Data Becker  -  gewisserma�en  die 
   Bibel  f�r  Systemprogrammierer  -  wird  die  Routine, in der 
   diese Sequenz enthalten ist, als "go2track" bezeichnet, aller-
   dings ist dieser Name nicht "offiziell". Sie dient dazu, einen 
   bestimmten Track anzusteuern.   

   Speeder schaltet dieses Verify aus,  indem der Befehl 14 durch 
   10  ( SEEK ohne Verify ) ersetzt wird.  Dies hat bei  l�ngeren 
   Files eine Verdopplung der Schreib und Lesegeschwindigkeit zur 
   Folge. Der Grund liegt in nutzloser Wartezeit des FDC:
   Nehmen  wir  einmal an,  da� 50KByte oder  100  Sektoren,  die 
   hintereinanderliegen,  gelesen werden sollen.  Nach 9 Sektoren 
   ( bzw. 10 bei einer FATDISK ) mu� der Schreib/Lesekopf auf den 
   n�chsten Track positioniert werden. Bei eingeschaltetem Verify 
   holt der FDC die physik. Tracknummer aus dem n�chsten ID-Feld, 
   das zu Sektor 1 des n�chsten Tracks geh�rt.  Sektor 1 ist aber 
   gleichzeitig der Sektor,  der als n�chster gelesen werden mu�. 
   Da dessen Beginn soeben am Lesekopf vorbeigerauscht  ist,  mu� 
   eine ganze Umdrehung abgewartet werden, bis er das n�chste Mal 
   gefunden  wird.  F�r das Lesen eines Tracks werden also  statt 
   einer Umdrehung jeweils zwei ben�tigt.  Die m�gliche  �bertra-
   gungsrate wird dadurch halbiert! 
 
Welche Nebenwirkungen treten bei der Ausschaltung dieses  Verifys 
auf?  �berhaupt keine!  Ein Track-Verify findet n�mlich auch  bei 
jedem  Schreib/Lesevorgang auf Diskette statt.  Der FDC pr�ft bei 
einem READ-SECTOR-Befehl ( bzw. WRITE-SECTOR ), ob die vorhandene 
Tracknummer  im  ID-Feld  mit der gew�nschten  Nummer  im  Track-
Register des FDC �bereinstimmt.  Ein Fehler wird �ber ein Status-
bit  erkannt ( "Record not found" ) und auch  vom  Betriebssystem 
registriert.  Wenn wirklich einmal ein falscher Track angesteuert 
ist,  sucht das Betriebssystem die betreffende Spur noch einmal ( 
ein "RESEEK"-Vorgang ). Technisch gelingt dies �ber ein RESTORE ( 
setzen  des  Lesekopfes auf Track 0 )  und  einem  anschlie�enden 
SEEK-Befehl an den FDC.  Damit wird die gew�nschte Spur auch  bei 
einem  Fehler  mit an  Sicherheit  grenzender  Wahrscheinlichkeit 
gefunden.   
      Beim  eingeschalteten  Track-Verify wird so  gut  wie  kein 
zus�tzlicher Sicherheitseffekt erreicht,  da im Prinzip bei einem 
Positionierungsfehler die gleichen Vorg�nge wie oben  beschrieben 
ablaufen.   �berschreiben  oder  fehlerhaftes  Lesen  von   Daten 
aufgrund  der  Ausschaltung dieser Sicherheitsvorkehrung  ist  in 
jedem  Fall so gut wie unm�glich.  Da ich die Routine 4 des  BIOS 
bereits  von vorne bis hinten zerlegt habe,  kann ich zwar  keine 
Haftung f�r evtl.  Sch�den �bernehmen ( h�h�h�... ), schlie�e sie 
aber  so gut wie aus.  In der Praxis arbeite ich seit einem  Jahr 
mit  einem  gepatchten Betriebssystem und konnte noch  nie  einen 
Fehler  entdecken,  der sich auf die Ausschaltung dieses  Verifys 
zur�ckf�hren lie�.
Um dennoch unvermeidlichen Morddrohungen vorzubeugen,  hier  noch 
ein paar allgemeine Fakten zur Diskettensicherheit:
Fehler bei der Arbeit mit Disketten sind durchaus  m�glich,  wenn 
von Diskettenlaufwerken unterschiedlicher Hersteller  aufeinander 
kopiert wird.  Es l��t sich z.B. immer wieder von Schwierigkeiten 
mit Fremdlaufwerken h�ren,  deren Disketten unter Umst�nden nicht 
von den ATARI-Laufwerken gelesen werden k�nnen.  Dies ist  nat�r-
lich kein allgemeiner Produktionsfehler,  aber ich selbst  erlebe 
obiges  Ph�nomen ab und zu.  Dieser Fehler h�ngt nat�rlich  nicht 
vom  Ausschalten  eines  Verifys ab,  da  die  Daten  einwandfrei 
gelesen  werden k�nnen,  solange nicht mit der Diskette  auf  dem 
anderen  Laufwerk gearbeitet wird.  Auch 1000 Verifys  k�nnen  an 
dieser Tatsache nichts �ndern.
     
         Von  der M�glichkeit,  sein Betriebssystem  durch  einen 
einfachen  Patch zu "frisieren",  haben leider bei  weitem  nicht 
alle  ST-Anwender Gebrauch gemacht,  obwohl dies mit einem  guten 
Diskettenmonitor kein Problem ist.  Dies hing meiner Meinung nach 
von mehreren Faktoren ab:  Zum einen existierten unterschiedliche 
TOS-Versionen,  die  jeweils  einen  anderen  Patch  erforderten. 
     Zweitens  galt dieser Eingriff f�r die  Datensicherheit  als 
"gef�hrlich",  weil  viele ST-Besitzer nicht wu�ten,  um was  f�r 
einen  Eingriff es sich genau handelte.  Dieses Verify  ist  aber 
nicht die einzige Sicherheitsvorkehrung im  Betriebssystem,  son-
dern eine eher nebens�chliche,  die sich allerdings fatal auf die 
�bertragungsrate  auswirkt.  Und drittens ist ein Patch in  einem 
ROM-Betriebssystem einfach unm�glich,  es sei denn,  man hat  die 
M�glichkeit, EPROMs zu brennen.
Als  Folge dieser Umst�nde macht nur eine offensichtlich  elit�re 
Minderheit  der  ST-Anwender von dieser Verbesserung  Gebrauch  ( 
entweder  mit EPROMs oder ge�nderten TOS.IMG-File  ).  F�r  diese 
Gruppe bringt "Speeder" nat�rlich keinen Nutzen.


III. Algorithmus von "Speeder.prg"
 
Nach  diesen theoretischen Vorbemerkungen k�nnen wir endlich  zum 
Prinzip der Betriebssystemserweiterung "Speeder" kommen.  Bei der 
Programmierung dieses Programms durfte,  damit es sowohl mit ROMs 
als auch mit den verschiedenen Versionen des RAM-TOS  zusammenar-
beitet,  kein direkter Patch ins Betriebssystem verwendet werden. 
Es  mu�te  folglich ein anderer Weg gefunden  werden.  Fast  alle 
Zugriffe auf das Diskettenlaufwerk laufen, wie schon gesagt, �ber 
die  Funktion 4 des BIOS,  in der nur ein einziges Byte  ge�ndert 
werden mu�.  Im ROM ist es allerdings unm�glich,  dieses Byte  zu 
�ndern  (  was nat�rlich �rgerlich ist ).  Zum Gl�ck  wird  diese 
Routine �ber einen Vektor angesprungen ( Addresse in $476 ),  der 
auf  eine  eigene  Routine  umgebogen  werden  kann.  Von  dieser 
Tatsache  machen  sowohl Ramdisks  als  auch  Festplatten-Treiber 
Gebrauch.  Die  Grundidee  des "Speeders" sah  so  aus,  da�  ein 
residentes Programm mit leichten Modifizierungen und  ausgeschal-
tetem   Positionierungs-Verify  die  neue  rwabs-Routine   bilden 
k�nnte.  Leider ist diese Routine mit ihren dazugeh�rigen  Unter-
programmen  zur DMA-Kontrolle,  Fehlerbehandlung  etc.  eine  der 
l�ngsten im Betriebssystem und zum simplen Abschreiben einfach zu 
lang.  Dies kann den wahren Assembler-Freak aber nicht schrecken, 
wenn er �ber entsprechend m�chtige Hilfsmittel verf�gt.  Mit  dem 
PROFIMAT von DATA BECKER ist es m�glich, Programme oder Teile des 
Betriebssystems zu reassemblieren.  Absolute Sprungaddressen wer-
den  dabei  zu  Labels ( symbolisch  )  umgewandelt.  Obwohl  der 
Reassembler   im  PROFIMAT  nicht  ganz  fehlerfrei  arbeitet   ( 
grrrrrrrrrrrr!!!!  ),  hat er dieses Projekt entscheidend verein-
facht.  Reine Abschreibungsarbeit war folglich meistens (!) nicht 
n�tig.  Da durch die Reassemblierung viele �berfl�ssige Teile der 
rwabs-Routine ausgelassen werden konnten,  ist ein sehr kompakter 
Code entstanden.
    Der reassemblierte Code basiert auf der ROM-Version des  TOS, 
l�uft aber auch mit jeder anderen Version.  Ob "Speeder" mit  dem 
Blitter-TOS  lauff�hig  ist,  das  beim  Erscheinungstermin  m�g-
licherweise  schon auf dem Markt sein wird,  kann ich noch  nicht 
beurteilen.  Falls  nicht,  wird  auf jeden Fall ein  Update  des 
Programms  herauskommen.   Wenn  Sie  dieses  Programm  verwenden 
k�nnen,  kopieren Sie es am besten in einen AUTO-Ordner, damit es 
beim  Booten  automatisch gestartet wird.  Es vertr�gt  sich  mit 
Ramdisks oder Harddisk-Treibern, egal, ob diese vor oder nach der 
Initialisierung gestartet werden.
"Speeder"  arbeitet  bis  jetzt  mit  jedem  getesteten  Programm 
zusammen,  was bei der kurzen Programml�nge auch kein Wunder ist. 
2.5  KByte sollten jedenfalls auch auf einem 260ST ohne  ROMs  zu 
entbehren sein.                                     

     Kulmbach, den 20.5.87
          Stephanos the Magician 


P.S.: 
"Speeder"  ist  ein �u�erst n�tzliches Utility und  steigert  die 
Leistungsf�higkeit Ihres Systems evtl.  ganz erheblich. Falls Sie 
dieses Programm st�ndig benutzen,  w�rde ich es f�r fair  halten, 
wenn Sie als Anerkennung f�r dieses Werk an mich einen Betrag von 
20.- DM �berweisen.
Sie tragen damit dazu bei,  das evtl.  noch mehr Programme dieser 
Klasse  als PD-Software ver�ffentlicht werden ( dies  ist   keine 
Floskel!!!  ).  Vielen  Dank  im voraus an  "zahlungswillige  ST-
Anwender"!  


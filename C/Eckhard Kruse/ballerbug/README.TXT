
        Was Sie Åber die Dateien auf dieser Diskette wissen sollten...

ZunÑchst  noch  einmal herzlichen Dank fÅr die 20 DM.  ( Sie kînnen stolz  auf 
sich  sein,  denn  so  haben  Sie quasi einen  eigenen  kleinen  Beitrag  dazu 
geleistet, daû sich das Prinzip der Public Domain-Programme weiter durchsetzen 
wird.  )  Doch  nun  zu den Dateien,  die ich Ihnen wie versprochen  auf  Ihre 
Diskette Åberspielt habe:
------------------------------------------------------------------------------
NEU: Es gibt mittlerweile eine '89er Version von Ballerburg, die ich Ihnen 
hiermit ebenfalls Åberspielt habe (BALLER.PRG...). Der Sourcecode bezieht sich 
auf diese erweiterte Version.  Die Verbesserungen zum VorgÑnger: 
- es gibt keine Probleme mehr mit dem Blitter-TOS oder TOS 1.4 (hoffe ich).  
- man  kann  in  einer Tabelle alle Ergebnisse  von   bis  zu  sechs  Spielern 
  speichern.   
- es gibt Spieloptionen,  wie z.B. Festlegung einer maximalen Rundenzahl, nach 
 der das Spiel beendet wird und der Sieger nach dem Spielstand ermittelt wird. 
------------------------------------------------------------------------------
Ich  habe Ihnen den gesamten Sourcecode von Ballerburg Åberspielt.  Er besteht 
aus  den Hauptteilen BALLER1.C und BALLER2.C sowie aus MUSIK.C,  den  Routinen 
zum   Abspielen  der  mit  dem  Musik-Editor  erstellten   Datei   BALLER.MUS. 
Schlieûlich  gehîrt  dazu noch BALLER.H,  die Header-Datei,  die die Namen der 
Objekte der Resource-Datei enthÑlt.
Die  Listings sind fÅr das Lattice C von Metacomco geschrieben.  Zum  besseren 
VerstÑndnis  des Programmes,  bzw.,  damit Sie das Programm auf Ihren Compiler 
anpassen kînnen, mîchte ich hier einige Punkte erlÑutern:
1.  Im Gegensatz zu den meisten anderen Compilern ist hier der Datentyp int 32 
Bit und der Datentyp short 16 Bit breit.
2.  Ein  mit  dem  Lattice  C  erstelltes Programm hat  die  (  unangenehme  ) 
Eigenschaft,   sich   nach  dem  Laden  fast  den  gesamten  Speicherplatz  zu 
reservieren.  (  Damit  man dann mit speziell implementierten  UNIX  Ñhnlichen 
Funktionen  die Speicherverwaltung vornehmen kann.  ) Dies hat aber zur Folge, 
daû  es bereits beim Laden von Resource-Dateien oder beim Aufruf  der  Gemdos-
Funktion Malloc zu Schwierigkeiten aufgrund mangelnden Speicherplatzes  kommen 
kann.  Daher  habe  ich  von  der Mîglichkeit  Gebrauch  gemacht,  durch  'int 
_mneed=20000;' den automatisch reservierten Speicherplatz zu verkleinern.  Die 
so  reservierten  20K werden teilweise von der  Routine  m_laden()  gebraucht. 
Ansonsten  wird  der  Speicher  wie gewohnt  mit  der  Gemdos-Funktion  Malloc 
reserviert.
3.  Ich habe von einigen Winkelfunktionen Gebrauch gemacht, die nicht in jedem 
C  implementiert  sind.  Sie arbeiten alle mit doppelt genauen  float  Werten. 
atan2(y,x) berechnet den Arcustangens von Y/X.
4.  Bei  Typumwandlungen  habe ich immer auf Korrektheit geachtet,  so daû ich 
auch  bei  Warnungen  ( im Gegensatz zu Fehlern  )  die  entsprechenden  casts 
verwendet habe.
So,  ich hoffe, diese Informationen und die Kommentare in den Listings reichen 
aus,  daû  Sie die interessanten Teile des Programmes verstehen kînnen und Sie 
so  vielleicht  ein  paar Anregungen fÅr Ihre  eigenen  Schîpfungen  bekommen. 
Sollten Sie im Besitz des Musik-Editors sein und wollen Sie in Ihre  Programme 
MusikstÅcke  einbauen,  so  mÅûten Sie alle notwendigen Informationen  in  der 
MUSIK.C Datei finden,  die Sie dann einfach nur zu Ihrem Programm dazuzulinken 
haben.

Neben  dem  Sourcecode habe ich Ihnen auch noch  eine  ausfÅhrliche  Anleitung 
Åberspielt,  die  unter anderem genau auf die Strategien der Computer  eingeht 
und vieles tiefergehend erlÑutert, als das die im Spiel 'eingebaute' Anleitung 
kann.  Sollten  Sie  1st  Word  besitzen,  so  steht  Ihnen  neben  der  Datei 
ANLEITNG.TXT, die Sie sich einfach vom Desktop aus anschauen kînnen, auch noch 
ANLEITNG.DOC  zur  VerfÅgung,  von  der Sie sich dann einen  schînen  Ausdruck 
anfertigen kînnen.

Schlieûlich  noch  zu den versprochenen Informationen,  wie man eigene  Burgen 
erstellen kann.  Ich habe Ihnen dazu eine BALLER.DAT Datei Åberspielt,  die im 
Gegensatz zu der normalen mit Bemerkungen regelrecht 'vollgestopft' ist.  Wenn 
Sie sich diese zu GemÅte gefÅhrt haben,  ist es ein leichtes,  Burgen zunÑchst 
auf  dem Millimeterpapier zu entwerfen und anschlieûend mit einem Editor  oder 
Textverarbeitungsprogramm  die  Burgendatei  um  die  nîtigen  Zahlenwerte  zu 
erweitern.

Ich hoffe,  Sie sind nun wunschlos glÅcklich mit all den schînen Dateien,  die 
sich   nun  auf  Ihrer  Diskette  befinden.   Sollten  dennoch  einmal  Fragen 
auftauchen, so kînnen Sie sich an mich wenden.



Schîne GrÅûe 

  Eckhard Kruse
  Reichenbergweg 7
  D-3302 Cremlingen-Weddel



                 *****************************************
                 *                                       *
                 *    HP-DeskJet(+) Hardcopy Treiber     *                          
                 *           Alman Development           *
                 *              Version 1.0              *
                 *                                       *
                 *   vom 05.05.1990                      *
                 *   geschrieben von   Arndt Weinmann    *
                 *                     Philosophenweg 79 *
                 *                     D-7400 TÅbingen   *
                 *                                       *
                 *****************************************


                      Dokumentation zu 'HP_DESK.PRG'
    
                             Inhaltsverzeichnis
    
    1.0       Public Domain
    1.1       WofÅr ist 'HP_DESK.PRG'
    1.2       Bedienung von 'HP_DESK.PRG'
    1.3       Aufruf an alle HP-DeskJet Besitzer
    1.4       UnzulÑnglichkeiten und Neuerungen
    1.5       Fehler

    2.0       Technische Informationen zum Programm
    2.1       Sourcecode


    Hinweis: Fast alle Soft- und Hardwarebezeichnungen, die
    in dieser Dokumentation erwÑhnt werden, sind eingetragene
    Warenzeichen und sollten als solche betrachtet werden.


    1.0 Public Domain

    Das Programm 'HP_DESK.PRG' ist Public-Domain-Software, d.h. jeder
    kann das Programm kopieren und benutzen, ohne dafÅr etwas
    bezahlen zu mÅssen. Voraussetzung dafÅr ist, daû keine VerÑnder-
    ungen am Programm oder an diesem Text vorgenommen, sowie daû das  
    Programm und dieser Text immer zusammen weitergegeben werden.


    1.1 WofÅr ist 'HP_DESK.PRG'

    Der ATARI ST besitzt eine eingebaute Hardcopy-Funktion, die nach
    DrÅcken von <Alternate-Help> eine Kopie des Bildschirminhaltes auf
    einem Drucker ausgibt. Leider ist diese Funktion fÅr 9-Nadel-Drucker
    ausgelegt, so daû sich auf einem HP-DeskJet keine vernÅnftigen
    Ergebnisse erzielen lassen. 'HP_DESK.PRG' ersetzt die 
    eingebaute Hardcopyroutine durch eine eigene, so daû damit ein 
    HP-DeskJet angesprochen werden kann. 


    1.2 Bedienung von 'HP_DESK.PRG'

    Hinweis: 'HP_DESK.PRG' funktioniert nur in der 640*400 Punkte
    monochromen Auflîsung, also nicht mit Farbmonitoren oder 
    Groûbildschirmen.
     
    Starten Sie das Programm 'HP_DESK.PRG' vom Desktop aus 
    durch einen Doppelklick oder aus dem AUTO-Ordner heraus. Es
    erscheint eine kurze Meldung, daû das Programm installiert 
    worden ist, dann beendet sich das Programm. 
    Nach der Installation ist die interne Hardcopy-Routine
    durch die Routine von 'HP_DESK.PRG' ersetzt worden. Wenn Sie 
    'HP_DESK.PRG' noch einmal starten, wird wieder die ursprÅngliche
    Hardcopy-Routine aktiviert und 'HP_DESK.PRG' entfernt sich wieder
    aus dem Speicher, d.h. je nach Situation haben Sie die Mîglichkeit
    das Programm zu installieren oder auch auch wieder zu entfernen,
    ohne den Rechner neu starten zu mÅssen.

    Aufgerufen wird eine Hardcopy mit <Alternate-Help>!

    Danach scheint erst einmal gar nichts zu passieren, 'HP_DESK.PRG'
    wird dadurch jedoch aktiviert und wartet auf einen Tastendruck:

     <ESCAPE>  : bricht die Hardcopy-Routine ab
     <UNDO>    : bricht die Hardcopy-Routine ab
     
     <H>       : schaltet hohe AusgabequalitÑt ein (Default)
                 (wartet weiter auf Tastendruck)
     <L>       : schaltet niedrige AusgabequalitÑt ein
                 (wartet weiter auf Tastendruck)

     <F1>      : sehr kleine Hardcopy  (300 dpi, d.h 300 Punkte
                 pro Zoll)
     <F2>      : kleine Hardcopy (150 dpi)
     <F3>      : mittlere Hardcopy (100 dpi)
     <F4>      : groûe, gedrehte, auf DIN A4 zentrierte Hardcopy (75 dpi)

     <F10>     : Seitenvorschub (wartet weiter auf Tastendruck)

     <S>       : speichert die Hardcopy in einer Datei namens
                 'SCREEN_X.IMG  im Wurzelverzeichnis des aktuellen 
                 Laufwerks im sogenannten Screen-Format oder auch
                 Doodle-Format, das von (fast) allen Programmen
                 eingelesen werden kann, die Hardcopies verarbeiten.
                 Das 'X' im Dateinamen bezeichnet einen ZÑhler, der
                 von 0 bis 9 lÑuft und dann wieder bei 0 anfÑngt, so
                 daû nach jeweils 10 Bildern das erste Bild wieder
                 Åberschrieben wird.

     Ist der Drucker nicht eingeschaltet oder nicht On-Line versucht
     das Programm eine Weile das Zeichen auszugeben. Bei Nichterfolg
     wird die Hardcopy-Routine verlassen. Dann kînnen Sie den Drucker
     einschalten und erneut eine Hardcopy aufrufen.

     WÑhrend des Druckens kann die Ausgabe jederzeit mit UNDO beendet
     werden.


     1.3  Aufruf an alle HP-DeskJet Benutzer

     Der HP-DeskJet ist ein sehr guter Drucker (leise, schnell), aber
     die tatsÑchliche LeistungsfÑhigkeit hÑngt natÅrlich von der
     SoftwareunterstÅtzung ab. 
     Deshalb meine Bitte: sollten sie PD-Programme zum HP-DeskJet
     besitzen, oder auch nur Druckeranpassungen oder Tips (z.B. zur
     besten Papiersorte), bitte kopieren sie diese auf eine Diskette
     (3 1/2 Zoll) und schicken Sie diese an die im Dokumentations-
     kopf angegebene Adresse.
     Sie erhalten Ihre Diskette selbstverstÑndlich zurÅck und zwar
     gefÅllt mit allen Programmen, Druckertreiber, Tips etc. was
     sich eventuell bis dahin bei mir angesammelt hat, sowie allen
     Versionen von 'HP_DESK.PRG', die es bis dahin gibt, sowie dem
     Sourcecode zur aktuellen 'HP_DESK.PRG'-Version. FÅr ihre MÅhe
     besten Dank im Voraus.


     1.4 UnzulÑnglichkeiten und Neuerungen

     Der Hardcopy-Treiber besitzt eine Reihe von UnzulÑnglichkeiten,
     die jedoch oftmals nur unter groûem Aufwand zu umgehen sind und
     damit stellt sich die Frage, ob der vergrîûerte Speicherbedarf
     die Umgehung dieser UnzulÑnglichkeiten rechtfertigt.
     Als Beispiel sei genannt, daû der Treiber nur in der monochromen
     640*400 Punkte Auflîsung arbeitet, dies ist z.B. ein Punkt, 
     der verbessert werden sollte. Wenn Sie selber VorschlÑge zur
     Verbesserung haben, bitte schreiben Sie mir.

    
     1.5 Fehler

     Bisher sind mir keine direkten Fehler bekannt geworden, wenn
     jedoch Probleme auftreten, bitte ich darum, diese Fehler
     mir mîglichst detailliert mitzuteilen, damit ich versuchen kann,
     sie zu beseitigen (mîglichst mit Angabe zur Betriebsversion,
     Speichergrîûe, anderen residenten Programmen etc.).
    



     2.0 Technische Informationen zum Programm

     Geschrieben wurde 'HP_DESK.PRG' in Assembler mit dem 
     GFA-Assembler Version 1.3. 

     ProgrammlÑnge: 1570 Bytes
     LÑnge des Programmteiles, der sich im Speicher installiert,
     (inklusive Basepage: 1218 Bytes 

     vektorisiert Åber long $502 'scr_dump' oder 'dump_vec'
     
     mit XBRA-Struktur, Kennung 'AlHP'


     2.1 Sourcecode

     Der Assembler-Sourcecode ist bei mir (Arndt Weinmann)
     zum Preis von DM 10.- (Schein) zu erhalten (Adresse im
     Dokumentationkopf).
     DafÅr erhalten Sie den Sourcecode, alle 'HP_DESK.PRG'-Versionen,
     die es bis dahin gibt, und soweit vorhanden Programme, Tips 
     und Druckertreiber zum HP-DeskJet auf einer 3 1/2-Zoll-Diskette
     (Absender nicht vergessen). 
     
     
          

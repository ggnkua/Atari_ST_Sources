



           G E M - M A N A G E R  Version 5.10 vom 30.11.1992
     ==============================================================










                Inhaltsverzeichnis
                ------------------
        
                1) Daten entpacken
                2) Was ist auf der Diskette drauf ?
                3) Das Handbuch
                4) énderungen zur Version 5.03
                5) Installationshinweise im Falle eines Updates


1) Daten entpacken
==================

Der GEM-Manager ist mit der Zeit umfangreich geworden. ZusÑtzlich wird
die Anleitung in in zwei Textverarbeitungsformaten und im ASCII-Format
mitgeliefert. Alles zusammen paût leider nicht mehr auf eine Diskette,
so daû die Daten gepackt werden mÅssen. Um sie zu entpacken, gehen Sie
bitte folgendermaûen vor:

a) Kopieren Sie die vorhandenen Dateien auf Festplatte (als ernsthafter
   Anwender haben Sie doch sowas??)

b) Starten Sie das Programm LHARC200.PRG mit folgenden Parametern:
                x -xm gem_510

c) Alle Dateien (und Ordnerhierarchien) werden jetzt extrahiert und 
   stehen Ihnen somit zur VerfÅgung

d) Die unten beschriebenen Dateien und Verzeichnisse sind im neuen
   Ordner "<laufwerk>:\GEM.510" enthalten


2) Was ist auf der Diskette drauf?
==================================

GEM.510 \DOKUMENT\T_WORD\MANAGER.TWD (Anleitung Tempus-Word)
                         MANAGER.TW  (Anleitung That's Write)
                 \ASCII \MANAGER.TXT (Anleitung ASCII)
                        
        \EXT_LIB.C\      README      (Bindings zu Betriebs-
                         EXFORMDO.C   systemfunktionen, die
                         F_BUTTON.C   nicht im Mark Williams C
                         F_KEYBD.C    implementiert sind)
                         CRYSTAL.O

        \MW_C\           AESBIND.H   (Headerdateien, wie sie im
                         GEMDEFS.H    Mark Williams C benutzt
                         OSBIND.H     werden)
                         STDIO.H
                         VDIBIND.H

        \SOURCES\GEM_LIB\BUTTON.H   (Sources zum GEM-Manager)
                         EVENT.H
                         GEMSYS.H
                         WINDOW.H
                         BUT_MNGE.C
                         EVNT_LIB.C
                         FKTPOOL.C
                         MENU_LIB.C
                         MOVEBOX.C
                         POP_LIB.C
                         RESOURCE.C

                \GERUEST\PRG_SKEL.C  (ProgrammgerÅst GEM-Programme)
                
                \SAMPLE1\ ...        (Beispielprogramm zum
                                      GEM-Manager)
                
				\SAMPLE2\ ...        (Das gleiche Beispielprogramm
				                      wie unter "SAMPLE1", aber noch
									  zusÑtzlich mit einer Dialogbox,
									  die in einem Fenster unterge-
									  bracht ist)




3) Das Handbuch
===============

Das Handbuch liegt in 3 Formaten vor:
        Tempus Word
        That's Write
        Ascii-Text.

Hinweise zum Tempus Word Dokument:
----------------------------------
Das Handbuch enthÑlt einige Grafiken IMG-Format, die in Ihr Verzeichnis
fÅr Bilder kopiert werden mÅssen. Das Dokument wurde mit einem  DIN A5-
Layout erstellt.

Hinweise zum That's Write Dokument:
-----------------------------------
Sollten Sie das TWRITE-Dokument benutzen, benîtigen Sie die Grafiken
nicht, da sie schon in den Text eingebunden sind. Das Handbuch hat
DIN A5-Format.

Hinweise zum Ascii Dokument:
----------------------------
Das ASCII-Format dient eigentlich nur zu öbernahme des Handbuchs in ein
anderes Textverarbeitungsprogramm. NatÅrlich sind alle Attribute und
sonstigen Einstellungen verlorengegangen. An den entsprechenen Stellen
wurden Hinweise auf den Dateinamen des Bildes eingebaut, das sie in Ihr
Textsystem Åbernehmen kînnen.

Der ASCII-Text ist als Flieûtext gespeichert, d.h. ein Absatz ist  e i n e
Zeile. Das Absatzende wird durch eine Leerzeile erkannt. So dÅrfte es
recht einfach sein, den Text absatzgerecht einzulesen und den Wortumbruch
durchzufÅhren.

Die Bilder zum Handbuch liegem im IMG-Formate bei. Im ASCII-File ist 
an den entsprechenden Stellen ein Vermerk - << Bild: ".." >> - mit
Dateinamen angegeben.




4) énderungen zur Version 5.03
==============================

Folgende énderungen wurden gegenÅber der alten Version vorgenommen:

a)  Allgemeine Funktionen:

    -   Es liegt ein ProgrammgerÅst bei, welches die Grundstruktur
        eines GEM-Programms unter Benutzung des GEM-Managers darstellt.

    -   Vom GEM-Manager wird das globales Feld "Prog_End" bereitgestellt.
        Durch die Funktion "gem_init()" wird dieses Feld auf FALSE ge-
        setzt. Es kann - muû aber nicht - genutzt werden, indem es auf
        TRUE gesetzt wird, wenn das Programm beendet werden soll (siehe
        Beispielprogramm und ProgrammgerÅst).

    -   Neue Funktion "rect_overlay" zum Feststellen, ob zwei Recht-
        ecke sich Åberschneiden und berechnen der SchnittflÑche.
    
    -   Neue Funktion "rect_equal" zum Feststellen, ob zwei Rechtecke
        identisch sind.
    
    -   Neue Funktion "is_cookie" zum Feststellen, ob ein bestimmtes
        Cookiejar installiert ist.
    
    -   neues Memberfeld in aktuell "multitsk"; ist TRUE, wenn ein 
        Multitasking-System vorliegt, ansonsten FALSE. Z.Zt. Wird
        vom Window-Manager genutzt.


b)  Window-Manager:

    -   Die "windows"-Tabelle wird jetzt dynamisch angelegt. Dadurch
        ergeben sich folgende énderungen:
        
        --  Die max. Anzahl Fenster muû mit "win_init()" Åbergeben
            werden. Anhand dieser Anzahl wird der Speicher reserviert.
            RÅckgabe: TRUE/FALSE

        --  Neues Memberfeld in aktuell "max_user_wind" enthÑlt die
            mit win_init() Åbergebene max. Fensteranzahl

        --  "open_window()" Åbergibt nicht mehr den Fensterhandle, 
            sondern den Index, unter dem die Daten des neuen Fensters
            abgelegt werden.
            ACHTUNG:    aktuell.handle enthÑlt immer die Handle-Nr.

        --  Neue Funktion zum Freigeben des reservierten Speichers:
            "win_exit()"

        --  neues Memberfeld in aktuell "max_user_wind"; enthÑlt
            die mit win_init() vorgegebene Maximalanzahl von Fenstern

        --  neue Funktion "int  handle_to_index(w_handle)" zum
            ermitteln des Index zum Fensterhandle
            
        --  Den Funktionen des Window-Managers (z.B. wm_call(),
            wind_info_set()) muû der von open_window() zurÅckgegebene
            Index Åbergeben werden (also nicht mehr das Fensterhandle)



        
    -   Fehlerbeseitigung beim Einsatz unter einem Multitasking-System.
        Ist ein Multitasking-System installiert, dann:

        --  wird kein automatischer Redraw durchgefÅhrt.

        --  werden Fensterausgaben nur noch Åber Rechteckliste 
            ausgefÅhrt (vorher wurden andere Fenster Åbermalt).

    -   GEM-Array global[12] eingefÅgt (globale Definition in
        gemprog.c), in restlichen Modulen muû dieses Array importiert
        werden.
    
    -   Konstante MAXWIND zwar noch vorhanden, wird aber nicht mehr
        vom Window-Manager unterstÅtzt
        ==> Kann AES kein Fenster mehr îffnen, bringt open_window()
            den RÅckgabewert -2

    -   Fehlerbeseitigung beim Clipping; Clipping wurde nach Full-
        Redraw nicht gelîscht
        
    -   wm_call() um WM_FREDRAW erweitert. Damit wird ein Full-Redraw
        erzwungen.


c)  MenÅ-Manager:

    -   Der Mauszeiger kann den Bereich des Popup-MenÅs nicht mehr 
        verlassen.
        
    -   Popup-MenÅ funktionierte nicht, wenn der Mauszeiger sich Åber
        Fensterelementen befand.

d)	Form-Manager:

	-	Dialogboxen kînnen jetzt in Fenster gelegt werden





5) Installationshinweise im Falle eines Updates
===============================================

Sollten Sie den GEM-Manager noch nicht besitzen, lesen Sie bitte nur
die Installationshinweise im Handbuch.

Zuerst sollten sie die neue Version des GEM-Managers installieren,
wie es im Handbuch beschrieben ist. Danach kommt leider etwas Arbeit
auf Sie zu, da die énderungen gerade beim Window-Manager umfangreich
waren und Modifikationen an den bestehenden Programmen erfordern.

a)  Die Fensterdaten zum Window-Manager werden jetzt in einem zu
    reservierenden Speicherbereich abgelegt. Daraus ergeben sich
    folgende programmtechnische énderungen:
    
    -   die "EXTERN"-Deklaration fÅr die Fensterdaten heiût jetzt:
            extern  WIND_DATA   *windows;
    
    -   Funktion win_init() wurde geÑndert:
            int win_init(max_window)
                int max_window;

        max_window =>   Max. Anzahl von Fenstern, die erlaubt sind.
                        Anhand dieses Wertes wird Speicher fÅr die
                        Fensterdaten reserviert.

        RÅckgabewerte:  TRUE  ==>   Speicher reserviert
                        FALSE ==>   kein Speicher vorhanden, Window-
                                    Manager kann nicht benutzt werden
    
    -   open_window() gibt nicht mehr den Fensterhandle, sondern den 
        Index mit, unter dem die Fensterdaten im reservierten 
        Speicher abgelegt sind, z.B. windows[w_index].doc_x. Da in 
        den vorigen Versionen der Handle auch als Index genutzt 
        wurde, dÅrften sich daraus keine énderungen ergeben. Trotzdem 
        sollten Sie prÅfen, ob sie den RÅckgabewert aus open_window() 
        nicht noch anderweitig nutzen. Auûerdem sollte Sie berÅck-
        sichtigen, daû jetzt der Index "0" vorkommen kann (ein Handle 
        "0" gab es ja bisher nicht).
    
    -   Den Funktionen den Window-Managers darf nicht der Fenster-
        handle, sondern der von open_window() bereitgestellte Index
        Åbergeben werden. Sollte nur der Fensterhandle bekannt sein,
        z.B. aktuell.handle, dann ist die Funktion handle_to_index()
        zu benutzen.

    -   Vor dem Aufruf von gem_exit() sollte die neu geschaffene 
        Funktion win_exit() aufgerufen werden, um so alle Fenster zu 
        schlieûen und den fÅr die Fensterdaten reservierten Speicher
        wieder freizugeben.
        
b)  LÑuft das Programm unter einem Multitasking-System, wird kein
    automatischer Redraw mehr durchgefÅhrt, egal was open_window()
    mitgegeben wurde. Dies ist notwendig, da im Multitasking Fenster-
    inhalte geÑndert werden kînnen, obwohl die Prozesse und damit
    die Fenster nicht aktuell sind. Ein automatischer Redraw wÅrde
    darÅberliegende Fenster "Åberklatschen", da es sich ja nur um
    KopiervorgÑnge aus gesichterten Fensterbereichen handelt.




c)  Die Strukturvariable "aktuell" wurde um die Felder multitsk und
    max_user_wind erweitert. Auûerdem wurden so ziemlich alle 
    Funktionen irgendwie geÑndert. Daher mÅssen alle Programme, die
    eine "EXTERN"-Deklaration auf "aktuell" haben oder den GEM-
    Manager aufrufen, neu compiliert werden.
    

d)	Die Strukturvariable "windows" wurde um eine Struktur bereichert, die
	das Bearbeiten von Dialogboxen in Fenstern ermîglichen (RSCDATA).
	Bitte beachten Sie in jedem Falle, daû diese Daten zur Zwischenspeicherung
	von Werten der Form_do()-Routine benîtigt wird und nur READONLY sind.
	Eine VerÑnderung der Werte wird mit ziemlicher Sicherheit einen System-
	stillstand hervorrufen! Alle Module, die den Window-Manager benîtigen oder
	durch externe Verweise auf dieses Datenfeld zugreifen, mÅssen neu kom-
	piliert werden.


----------------------------------------

Sollten Sie den GEM-Manager erweitert haben oder auf Fehler gestoûen 
sein, so schreiben Sie bitte an eine der unten aufgefÅhrten Adressen. 
Wir sind jederzeit bemÅht, soweit uns unser Job Zeit lÑût, den GEM-
Manager zu pflegen und zu erweitern.


          Michael Kovar                    Volker Nawrath
        Waldmannstraûe 17              Tirschenreuther Ring 72
         1000 Berlin 46                    1000 Berlin 48
MausNet: Michael Kovar @ B		 

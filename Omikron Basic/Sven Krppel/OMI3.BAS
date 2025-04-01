 '*****************************************************************************
 '*                                                                           *
 '* Implementierung des abstrakten Datentyps 'lineare Liste' zur Speicherung  *
 '* von Worten.                                                               *
 '*                                                                           *
 '* (c) Sven KrÅppel, 18.9.90                                                 *
 '*                                                                           *
 '*****************************************************************************
 '* Dieses Programm verwaltet vier Typen von linearen Listen und demonstriert *
 '* die zugehîrigen Grundoperationen:                                         *
 '*                                                                           *
 '*   Die Liste 'Keller' wird nach dem LIFO-Prinzip bearbeitet. (Stack)       *
 '*   Die Liste 'Schlange' wird nach dem FIFO-Prinzip bearbeitet. (Queue)     *
 '*   Die Liste 'Liste' ist eine geordnete lineare Liste.                     *
 '*   Die Freispeicherliste ist eine Menge, d.h. eine lineare Liste in der    *
 '*       keine doppelten Elemente vorkommen. Die Elemente der Freispeicher-  *
 '*       liste sind Cursor (keine Wîrter)                                    *
 '*                                                                           *
 '* Die Listen speichern jeweils ein Wort (String). Wir nennen sie Wortlisten.*
 '* Aufbau des Datentyps Wortliste:  (Modula 2-Schreibweise)                  *
 '*    TYPE WortPtr   = POINTER TO Wortliste                                  *
 '*         Wortliste = RECORD                                                *
 '*                       Wort : String;                                      *
 '*                       Next : WortPtr                                      *
 '*                     END;                                                  *
 '*                                                                           *
 '* Die drei Wortlisten speichern wir in OMIKRON.BASIC in den Feldern         *
 '* Wl_Wort$() und Wl_Next%() mittels Cursor-Realisierung. Die Freispeicher-  *
 '* liste arbeitet nur mit dem Feld Wl_Next%.                                 *
 '*****************************************************************************

 '***** Globale Variablen *****
 Wl_Groesse%=0' Groesse des Feldes zur Speicherung der Wortliste. Dieser Wert
             ' entspricht dem grîûten zugreifbaren Index, da das nullte-Feld-
             ' element nicht mitgezÑhlt ist.
 Wl_Fsp_L%=0'        Cursor auf den Anfang der Freispeicherliste
 Keller_Anfang%=0'   Cursor auf den Anfang der Liste 'Keller'
 Schlange_Anfang%=0' Cursor auf die Leseposition der Liste 'Schlange'
 Schlange_Ende%=0'   Cursor auf die Schreibposition der Liste 'Schlange'
 Liste_Anfang%=0'    Cursor auf den Anfang der geordneten Liste 'Liste'
 Liste_Ende%=0'      Cursor auf das Ende der geordneten Liste 'Liste'

 '***** Hauptprogramm *****
 Dimensioniere_Wl(10,Fehler%)' Feld zur Speicherung der Wortlisten erst einmal
                            ' fÅr 10 Elemente initialisieren.
 IF Fehler% THEN PRINT "Zu wenig Speicherplatz": END

 CLS
 PRINT "Test der Listen zur Speicherung von Worten": PRINT
 PRINT "Befehle:  SK : Speichern in Keller"
 PRINT "          LK : Lesen aus Keller"
 PRINT "          SS : Speichern in Schlange"
 PRINT "          LS : Lesen aus Schlange"
 PRINT "          SL : Speichern in Liste"
 PRINT "          LL : Lesen aus Liste"
 PRINT "          Q  : Programmende"
 PRINT
 REPEAT
   INPUT "Befehl :";A$:A$= UPPER$(A$)
   IF A$="SK" THEN INPUT "Wort :";W$:Speichern_In_Keller(W$)
   IF A$="LK" THEN Lesen_Aus_Keller(W$): PRINT "gelesenes Wort :";W$
   IF A$="SS" THEN INPUT "Wort :";W$:Speichern_In_Schlange(W$)
   IF A$="LS" THEN Lesen_Aus_Schlange(W$): PRINT "gelesenes Wort :";W$
   IF A$="SL" THEN INPUT "Wort :";W$:Liste_Einfuegen(W$)
   IF A$="LL" THEN INPUT "Wort :";W$:Liste_Loeschen(W$)
   Drucke_Wl
   PRINT "'Keller'   : ";:Drucke_Liste(Keller_Anfang%)
   PRINT "'Schlange' : ";:Drucke_Liste(Schlange_Anfang%)
   PRINT "'Liste'    : ";:Drucke_Liste(Liste_Anfang%)
   PRINT
 UNTIL A$="Q"
 END


 DEF PROC Drucke_Liste(Anfang%)
   ' Druckt die Liste ab Index Anfang%
   IF Anfang%=0 THEN PRINT "<leere Liste>";
   WHILE Anfang%<>0
     PRINT Wl_Wort$(Anfang%);" ";
     Anfang%=Wl_Next%(Anfang%)
   WEND
   PRINT
 RETURN ' Drucke_Liste


 '*****************************************************************************
 '*                                                                           *
 '*  Bearbeitung der Liste 'Keller' als Stapel nach dem LIFO-Prinzip          *
 '*       (LIFO = Last In First Out)                                          *
 '*  Operationen: EinfÅgen und Lîschen am Listenkopf                          *
 '*                                                                           *
 '*****************************************************************************

 '***** Element in 'Keller' speichern *****

 DEF PROC Speichern_In_Keller(Wort$)
   LOCAL P%' Cursor auf Listenelement

   Allocate_Wl(P%)' Speicherplatz fÅr neues Element anfordern
   IF P%<>0 THEN 'kein Fehler
      Wl_Wort$(P%)=Wort$' Infokomponente eintragen
      Wl_Next%(P%)=Keller_Anfang%' EinfÅgen am Listenkopf
      Keller_Anfang%=P%
   ELSE
      PRINT "Zu wenig Speicherplatz"
   ENDIF
 RETURN ' Speichern_In_Keller

 '***** Element aus 'Keller' lesen *****

 DEF PROC Lesen_Aus_Keller(R Wort$)
   LOCAL P%' Cursor auf Listenelement
   Wort$=""
   IF Keller_Anfang%<>0 THEN ' Keller noch nicht leer
      Wort$=Wl_Wort$(Keller_Anfang%)' Infokomponente lesen
      P%=Keller_Anfang%'               Lîschen am Listenkopf
      Keller_Anfang%=Wl_Next%(Keller_Anfang%)
      Deallocate_Wl(P%)'              Speicherplatz fÅr Element zurÅckgeben
   ENDIF
 RETURN ' Lesen_Aus_Keller


 '*****************************************************************************
 '*                                                                           *
 '*  Bearbeitung der Liste 'Schlange' nach dem FIFO-Prinzip                   *
 '*       (FIFO = First In First Out)                                         *
 '*  Operationen: EinfÅgen am Listenende, Lîschen am Listenkopf               *
 '*                                                                           *
 '*****************************************************************************

 '***** Element in 'Schlange' speichern *****

 DEF PROC Speichern_In_Schlange(Wort$)
   LOCAL P%' Cursor auf Listenelement

   Allocate_Wl(P%)' Speicherplatz fÅr neues Element anfordern
   IF P%<>0 THEN 'kein Fehler
      Wl_Wort$(P%)=Wort$' Infokomponente eintragen
      Wl_Next%(P%)=0' EinfÅgen am Listenende: neues Element als Ende markieren
      Wl_Next%(Schlange_Ende%)=P%
      Schlange_Ende%=P%
      IF Schlange_Anfang%=0 THEN Schlange_Anfang%=P%' Schlange war leer
   ELSE
      PRINT "Zu wenig Speicherplatz"
   ENDIF
 RETURN ' Speichern_In_Schlange

 '***** Element aus 'Schlange' lesen *****

 DEF PROC Lesen_Aus_Schlange(R Wort$)
   LOCAL P%' Cursor auf Listenelement
   Wort$=""
   IF Schlange_Anfang%<>0 THEN ' Schlange noch nicht leer
      Wort$=Wl_Wort$(Schlange_Anfang%)' Infokomponente lesen
      P%=Schlange_Anfang%'               Lîschen am Listenkopf
      Schlange_Anfang%=Wl_Next%(Schlange_Anfang%)
      Deallocate_Wl(P%)'                Speicherplatz fÅr Element zurÅckgeben
      IF P%=Schlange_Ende% THEN Schlange_Ende%=0' Schlange wurde geleert
   ENDIF
 RETURN ' Lesen_Aus_Schlange


 '*****************************************************************************
 '*                                                                           *
 '*  Bearbeitung der geordneten linearen Liste 'Liste'                        *
 '*  Operationen: Suchen, EinfÅgen, Lîschen                                   *
 '*                                                                           *
 '*****************************************************************************

 '***** Wort in 'Liste' suchen und einfÅgen, falls es nicht vorhanden ist *****

 DEF PROC Liste_Einfuegen(Wort$)
   LOCAL P%,Prev%' Cursor
   ' Suche initialisieren
   Wl_Next%(0)=Liste_Anfang%' leeren Listenkopf simulieren
   Wl_Wort$(0)=Wort$' WÑchter anhÑngen
   Prev%=0
   P%=Liste_Anfang%
   ' Suchen
   WHILE Wl_Wort$(P%)<Wort$' Liste durchlaufen
     Prev%=P%
     P%=Wl_Next%(P%)
   WEND
   ' P% zeigt nun auf ein Element mit Wort$>=Wl_Wort$(P%)
   ' Auûerdem gilt: Wl_Next%(Prev%)=P%, auch wenn Prev%=P%=0 (leere Liste)
   IF Wl_Wort$(P%)>Wort$ OR P%=0 THEN
      'Wort noch nicht vorhanden, also vor (!) P% in die Liste einfÅgen
      Allocate_Wl(P%)' P% wird Zeiger auf das neue Element
      Wl_Wort$(P%)=Wort$' Informationskomponenten kopieren
      Wl_Next%(P%)=Wl_Next%(Prev%)' Nachfolger umbiegen
      Wl_Next%(Prev%)=P%
      IF Prev%=0 THEN Liste_Anfang%=P%' Es wurde vor dem ersten Element eingefÅgt
      IF Liste_Ende%=Prev% THEN Liste_Ende%=P%' Es wurde ans Listenende angehÑngt,
              ' denn der WÑchter hat die Suche beendet
   ENDIF
 RETURN 'Liste_Einfuegen


 '***** Wort in 'Liste' suchen und Eintrag lîschen, falls er existiert *****

 DEF PROC Liste_Loeschen(Wort$)
   LOCAL P%,Prev%' Cursor
   ' Suche initialisieren
   Wl_Next%(0)=Liste_Anfang%' leeren Listenkopf simulieren
   Wl_Wort$(0)=Wort$' WÑchter anhÑngen
   Prev%=0
   P%=Liste_Anfang%
   ' Suchen
   WHILE Wl_Wort$(P%)<Wort$' Liste durchlaufen
     Prev%=P%
     P%=Wl_Next%(P%)
   WEND
   ' P% zeigt nun auf ein Element mit Wort$>=Wl_Wort$(P%)
   ' Auûerdem gilt: Wl_Next%(Prev%)=P%, auch wenn Prev%=P%=0 (leere Liste)
   IF P%<>0 AND Wl_Wort$(P%)=Wort$ THEN ' Wort vorhanden, also lîschen
      IF P%=Liste_Anfang% THEN Liste_Anfang%=Wl_Next%(P%)' Anfang lîschen
      Wl_Next%(Prev%)=Wl_Next%(P%)' VorgÑnger von P% zeigt auf Nachfolger von P%
      Deallocate_Wl(P%)
      IF P%=Liste_Ende% THEN Liste_Ende%=Prev%' Listenende wurde gelîscht
   ENDIF
 RETURN 'Liste_Loeschen


 '*****************************************************************************
 '*                                                                           *
 '*  Bearbeitung des Feldes Wl zur Speicherung der Listen incl.               *
 '*  Freispeicherverwaltung                                                   *
 '*                                                                           *
 '*****************************************************************************


 DEF PROC Drucke_Wl
   ' Druckt die Listen inclusive Cursor
   LOCAL I%
   PRINT TAB (38);"Index"; TAB (45);"Wl_Wort$()"; TAB (60);"Wl_Next%()"
   FOR I%=0 TO Wl_Groesse%
     IF I%<>0 THEN
        IF I%=Wl_Fsp_L% THEN PRINT "Anfang Freispeicherliste";
        IF I%=Liste_Anfang% THEN PRINT "Anfang 'Liste'  ";
        IF I%=Liste_Ende% THEN PRINT "Ende 'Liste'  ";
        IF I%=Schlange_Anfang% THEN PRINT "Anfang 'Schlange'  ";
        IF I%=Schlange_Ende% THEN PRINT "Ende 'Schlange'  ";
        IF I%=Keller_Anfang% THEN PRINT "Anfang 'Keller'";
     ENDIF
     PRINT TAB (40);I%; TAB (45);Wl_Wort$(I%); TAB (60);Wl_Next%(I%)
   NEXT I%
   PRINT
 RETURN


 '***** (Re-)dimensionieren des Feldes mit der Datenstruktur Wortliste *****

 DEF PROC Dimensioniere_Wl(Anzahl_Neue%,R Fehler%)
   ' Anzahl_Neue% gibt die Anzahl zusÑtzlicher (!) EintrÑge an.
   ' RÅckgabewert : 0 = kein Fehler, -1 = Fehler aufgetreten
   LOCAL I%,Fehler%
   Fehler%=0
   ' Felder dimensionieren.
   ON ERROR GOTO Dim_Error
   DIM Wl_Wort$(Wl_Groesse%+Anzahl_Neue%)' Feld mit der Komponente 'Wort'
   DIM Wl_Next%(Wl_Groesse%+Anzahl_Neue%)' Feld mit dem Cursor auf den Nachfolger
   ON ERROR GOTO 0
   IF NOT Fehler% THEN ' kein Fehler beim Dimensionieren aufgetreten
      'Freispeicherliste generieren, d.h. die neuen EintrÑge als frei markieren
      Wl_Fsp_L%=Wl_Groesse%+1' Neuer Anfang der Freispeicherliste
      Wl_Groesse%=Wl_Groesse%+Anzahl_Neue%
      FOR I%=Wl_Fsp_L% TO Wl_Groesse%-1
        Wl_Next%(I%)=I%+1
      NEXT I%
      Wl_Next%(Wl_Groesse%)=0' Ende der Freispeicherliste markieren
   ENDIF
 RETURN
-Dim_Error
   Fehler%=-1
   RESUME NEXT


 '***** Einen Cursor auf einen freien Eintrag im Feld wl liefern *****

 DEF PROC Allocate_Wl(R P%)
   ' P enthÑlt nach dem Aufruf den Cursor auf ein freies Element
   ' P=0, falls kein Speicherplatz mehr vorhanden
   LOCAL Fehler%=0
   IF Wl_Fsp_L%=0 THEN ' keine freien EintrÑge mehr vorhanden
      Dimensioniere_Wl(10,Fehler%)' Feld um 10 EintrÑge vergrîûern
   ENDIF
   IF Fehler% THEN
      P%=0' kein Speicherplatz mehr vorhanden
   ELSE
      ' Das erste freie Element entfernen wir mit der Operation
      ' Lîschen am Listenkopf aus der Freispeicherliste.
      P%=Wl_Fsp_L%' P% zeigt auf das erste freie Element
      Wl_Fsp_L%=Wl_Next%(Wl_Fsp_L%)' Das Kopfelement der Freispeicherliste zeigt
                                ' auf seinen Nachfolger
   ENDIF
 RETURN ' Allocate_Wl


 '***** Ein Feldelement als frei markieren *****

 DEF PROC Deallocate_Wl(P%)
   ' P ist der Cursor auf das freizugebende Element
   ' (!) Die Felder werden nicht durch Redimensionierung verkleinert
   ' Ein Feldelement darf nur als frei markiert werden, wenn es nicht schon
   ' frei ist => P% muû in der Freispeicherliste gesucht werden. Nur wenn
   ' P% nicht vorhanden ist, darf dieser Cursor aufgenommen werden.

   IF P%<>0 THEN
      ' Suche nach P% im Feld Wl_Next%()
      LOCAL Hilf%' Hilfscursor, der die Freispeicherliste durchlÑuft
      IF P%=Wl_Fsp_L% THEN 'P% ist der Anfang der Freispeicherliste
         Hilf%=1
      ELSE
         Hilf%=Wl_Fsp_L%' Suche am Listenanfang beginnen
         Wl_Next%(0)=P%' WÑchter ans Ende der Freispeicherliste hÑngen
         WHILE Wl_Next%(Hilf%)<>P%' Suchfeld: Wl_Next%()
           Hilf%=Wl_Next%(Hilf%)
         WEND
      ENDIF
      IF Hilf%=0 THEN 'P% ist noch nicht als frei markiert
        ' P% wird durch EinfÅgen am Listenkopf in die Freispeicherliste eingetragen
        Wl_Next%(P%)=Wl_Fsp_L%' der Nachfolger von P% zeigt auf den Kopf der Freisp.L.
        Wl_Fsp_L%=P%' der Kopf der Freispeicherliste wird nun umgebogen
      ENDIF
   ENDIF
 RETURN ' Deallocate_Wl


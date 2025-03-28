 '*********************************************
 '*               Listing 8                   *
 '*                                           *
 '*      RADIXSORT zur String-Sortierung      *
 '*         Sortierung rein nach ASCII        *
 '*                                           *
 '*     Endversion inklusive Testumgebung     *
 '*                                           *
 '* Sven KrÅppel, (c) MAXON Computer 1991     *
 '*********************************************
 '*                                           *
 '* Es wird mit Hilfe der linearen Wortliste  *
 '* 'Wl' sortiert. 'Wl' speichern wir in den  *
 '* Arrays                                    *
 '*   Wl_Wort$() fÅr die Worte (Strings) und  *
 '*   Wl_Next%() fÅr die Cursor (Zeiger)      *
 '* 'WL' wird als Schlange interpretiert.     *
 '*                                           *
 '*********************************************

 '*********************************************
 'Konstanten-Definition

 Max_N%=100' Anzahl max. zu sortierender Worte
 Max_Laenge%=15'maximale LÑnge eines Strings

 ' ZulÑssige Zeichen mittels ASCII-Codes fest-
 ' legen. Max_Ascii% gibt an, wieviele BehÑlter
 ' sioniert werden.
 Min_Ascii%= ASC("0")' kleinstes zu
                     ' sortierendes Zeichen
 Max_Ascii%= ASC("û")' grîûtes zu sortierendes
                     ' Zeichen

 '*********************************************
 'Globale Variablen: Dimensionierung und
 '                   Deklaration

 'Datenstruktur Wl fÅr Cursorrealisierung
 'dimensionieren
 DIM Wl_Wort$(Max_N%)' Feld fÅr Worte
 DIM Wl_Next%(Max_N%)' Feld mit Cursor zur Ver-
                     ' zeigerung der linearen
                     ' Liste Wl.
 'BehÑlter dimensionieren. Die BehÑlter werden
 'mit den ASCII-Codes der zu sortierenden
 'Zeichen indiziert. Es werden mehr BehÑlter
 'angefordert, als benîtigt werden.
 DIM B_Anfang%(Max_Ascii%)
 DIM B_Ende%(Max_Ascii%)

 'BehÑlter fÅr Sortierung nach WortlÑnge
 'dimensionieren. BehÑlter i zeigt auf eine
 'lineare Liste, die Worte der LÑnge i ent-
 'hÑlt.
 DIM L_Anfang%(Max_Laenge%)
 DIM L_Ende%(Max_Laenge%)

 'N% : Anzahl zu sortierender Worte
 'S_Anfang% : Cursor auf den Anfang der
            ' Wortliste
 'S_Ende%   : Cursor auf das Ende der
            ' Wortliste

 '*********************************************
 'Hauptprogramm

 Wl_Wort$(1)="Bruno"
 Wl_Wort$(2)="Anna"
 Wl_Wort$(3)="Klaus"
 Wl_Wort$(4)="Fritz"
 Wl_Wort$(5)="Kunigunde"
 Wl_Wort$(6)="Ira"
 Wl_Wort$(7)="Franz"
 Wl_Wort$(8)="Susanne"
 Wl_Wort$(9)="Bernd"
 Wl_Wort$(10)="Emil"

 N%=10' Anzahl zu sortierender Worte
 Generiere_Liste_Aus_Feld(N%,S_Anfang%,S_Ende%)
 Radixsort(S_Anfang%,S_Ende%)
 Ll_Ausgeben(S_Anfang%)
 Uebertrage_Liste_In_Feld(S_Anfang%,S_Ende%,N%)
 Wl_Wort_Ausgeben(N%)
 END

 '*********************************************
 ' Sortier-Prozeduren

 DEF PROC Radixsort(R S_Anfang%,R S_Ende%)
   'Radix-Sortierung der Schlange S

   LOCAL Char_Nr%' Nummer des Zeichens, das als
                 ' SchlÅssel benutzt wird.

   Laengen_Sort(S_Anfang%,S_Ende%)
   B_Init(Min_Ascii%,Max_Ascii%)
   'Sortieren
   FOR Char_Nr%=Max_Laenge% TO 1 STEP -1
     IF L_Anfang%(Char_Nr%)<>L_Ende%(Char_Nr%) THEN
        'nur sortieren, wenn mehr als ein Wort
        'in der Liste steht
        Binsort(L_Anfang%(Char_Nr%),L_Ende%(Char_Nr%),Char_Nr%)
     ENDIF
     Ll_Verbinden(L_Anfang%(Char_Nr%-1),L_Ende%(Char_Nr%-1),L_Anfang%(Char_Nr%),L_Ende%(Char_Nr%))
   NEXT Char_Nr%
   S_Anfang%=L_Anfang%(0)
   S_Ende%=L_Ende%(0)
 RETURN 'Radixsort


 DEF PROC Laengen_Sort(R S_Anfang%,R S_Ende%)
   'Die Prozedur sortiert die Schlange S in die
   'BehÑlter L(). Der SchlÅssel ist die Wort-
   'lÑnge. Die BehÑlter speichern nach dem Auf-
   'ruf die Schlangen der entsprechenden Wort-
   'lÑnge. Sie werden nicht aufgelîst.
   'S_Anfang% und S_Ende% sind nach dem Aufruf
   'undefiniert, da die Schlange S nicht mehr
   'existiert.
   LOCAL L%' WortlÑnge
   LOCAL I%' Laufvariable
   LOCAL P%' Hilfscursor

   'BehÑlter L lîschen
   FOR I%=0 TO Max_Laenge%
     L_Anfang%(I%)=0
     L_Ende%(I%)=0
   NEXT I%

   'S in BehÑlter sortieren
   WHILE S_Anfang%<>0
     P%=Wl_Next%(S_Anfang%)' Cursor auf das
               ' zweite Listenelement retten
     L%= LEN(Wl_Wort$(S_Anfang%))
     Ll_Anhaengen(L_Anfang%(L%),L_Ende%(L%),S_Anfang%)
     S_Anfang%=P%
   WEND
 RETURN 'Laengen_Sort


 DEF PROC B_Init(Min_Ch%,Max_Ch%)
   'BehÑlter B lîschen
   FOR I%=Min_Ch% TO Max_Ch%
     B_Anfang%(I%)=0
     B_Ende%(I%)=0
   NEXT I%
 RETURN 'B_Loeschen


 DEF PROC Binsort(R S_Anfang%,R S_Ende%,Char_Nr%)
   'Die Prozedur sortiert die Strings der
   'Schlange S in die BehÑlter.
   'Char_Nr% : Nummer des Zeichens im String,
   '           das als SchlÅssel benutzt wird

   LOCAL Wort$' Wort, das einsortiert wird
   LOCAL Ch%' ASCII-Wert des Zeichens, das
            ' einsortiert wird.
   LOCAL I%'  Laufvariable
   LOCAL Min_Ch%,Max_Ch%' ASCII-Werte des
                        ' kleinsten und grîûten
                        ' benutzten Zeichens

   'S in BehÑlter sortieren
   Min_Ch%=Max_Ascii%' beginne mit dem schlech-
   Max_Ch%=Min_Ascii%' testen Fall
   WHILE S_Anfang%<>0
     P%=Wl_Next%(S_Anfang%)' Cursor auf das
               ' zweite Listenelement retten
     Wort$=Wl_Wort$(S_Anfang%)
     Ch%= ASC( MID$(Wort$,Char_Nr%,1))
     Min_Ch%= MIN(Min_Ch%,Ch%)
     Max_Ch%= MAX(Max_Ch%,Ch%)
     Ll_Anhaengen(B_Anfang%(Ch%),B_Ende%(Ch%),S_Anfang%)
     S_Anfang%=P%
   WEND

   'BehÑlter auflîsen und sortierte Liste
   'generieren. Inklusive BehÑlter lîschen
   S_Anfang%=0
   S_Ende%=0
   FOR I%=Min_Ch% TO Max_Ch%
     IF B_Anfang%(I%)<>0 THEN
        'BehÑlter nicht leer
        Ll_Verbinden(S_Anfang%,S_Ende%,B_Anfang%(I%),B_Ende%(I%))
        B_Anfang%(I%)=0' BehÑlter lîschen
        B_Ende%(I%)=0
     ENDIF
   NEXT I%

 RETURN 'Binsort


 '*********************************************
 '  Prozeduren fÅr die Listenoperationen

 DEF PROC Ll_Anhaengen(R Anfang%,R Ende%,P%)
   'HÑngt das Element, auf das P% zeigt, an das
   'Ende der Liste an, die durch Anfang% und
   'Ende% charakterisiert ist.
   '(!) Die Prozedur enthÑlt keine Schutz-
   'Mechanismen gegen fehlerhafte öbergabe-
   'parameter
   IF Anfang%=0 THEN Anfang%=P%' Liste war
                               ' bislang leer
   Wl_Next%(P%)=0' Ende der verlÑngerten
                 ' Liste markieren
   Wl_Next%(Ende%)=P%' neues Element anhÑngen
   Ende%=P%'          Cursor auf das Listenende
                    ' umbiegen
 RETURN 'Ll_Anhaengen


 DEF PROC Ll_Verbinden(R Anfang1%,R Ende1%,Anfang2%,Ende2%)
   'HÑngt die durch Anfang2% und Ende2%
   'definierte Liste an die durch Anfang1% und
   'Ende1% definierte Liste.
   IF Anfang1%=0 THEN '   1. Liste ist leer.
      Anfang1%=Anfang2%' funktioniert auch,
      Ende1%=Ende2%'     wenn beide leer
   ELSE ' 1. Liste ist nicht leer
      IF Anfang2%<>0 THEN '2. Liste nicht leer
         Wl_Next%(Ende1%)=Anfang2%' verbinden
         Ende1%=Ende2%
      ENDIF
   ENDIF
 RETURN 'Ll_Verbinden


 DEF PROC Ll_Ausgeben(Anfang%)
   'Druckt die Liste ab Index Anfang%
   IF Anfang%=0 THEN PRINT "<leere Liste>";
   WHILE Anfang%<>0
     PRINT Wl_Wort$(Anfang%);"  ";
     Anfang%=Wl_Next%(Anfang%)
   WEND
   PRINT
 RETURN 'Ll_Ausgeben


 '*********************************************
 ' Konvertierung: Feld <-> Liste

 DEF PROC Generiere_Liste_Aus_Feld(N%,R S_Anfang%,R S_Ende%)
   ' Die Prozedur generiert eine lineare Liste,
   ' indem sie die Cursor in 'Wl_Next%()'
   ' initialisiert.
   FOR I%=1 TO N%-1
     Wl_Next%(I%)=I%+1' jeder zeigt auf seinen
   NEXT I%'             Nachfolger
   Wl_Next%(N%)=0' Listenende markieren
   S_Anfang%=1
   S_Ende%=N%
 RETURN 'Generiere_Liste_Aus_Feld


 DEF PROC Uebertrage_Liste_In_Feld(R S_Anfang%,R S_Ende%,R N%)
   ' Die Prozedur organisiert die Wîrter derart,
   ' daû sie sortiert im Feld stehen.
   ' In N% wird die Anzahl der Wîrter zurÅck-
   ' gegeben.
   ' Die Wîrter werden in die Elemente 1 bis
   ' N% von Wl_Wort$() geschrieben.
   ' Die Listenstruktur wird zerstîrt, da die
   ' Cursor in Wl_Next% Åberschrieben werden.
   ' S_Anfang% und S_Ende% werden gelîscht
 LOCAL N%' Anzahl
 LOCAL I%,J%' Hilfsvariablen

 ' Feld-Position der Listenelemente in Wl_Next%
 ' eintragen.
 N%=0
 I%=S_Anfang%' Cursor
 REPEAT
   N%=N%+1' Anzahl der Wîrter inkrementieren
   J%=Wl_Next%(I%)' Cursor auf den Nachfolger
                  ' retten
   Wl_Next%(I%)=N%' Feldposition eintragen
   I%=J%' Cursor auf das nÑchste Listenelement
 UNTIL I%=0' bis Listenende

 'alle Wîrter umspeichern
 I%=1' Position, bis zu der die Wîrter sortiert
     ' im Feld stehen.
 'nÑchstes fehlerhaft gespeichertes Wort suchen
 WHILE Wl_Next%(I%)=I%
   I%=I%+1
 WEND
 REPEAT
   WHILE Wl_Next%(I%)<>Wl_Next%(Wl_Next%(I%))
     'solange Wîrter vertauschen, bis an Pos.
     'I% das richtige Wort steht
     SWAP Wl_Wort$(I%),Wl_Wort$(Wl_Next%(I%))
     SWAP Wl_Next%(I%),Wl_Next%(Wl_Next%(I%))
   WEND
   I%=I%+1' mindestens ein Wort mehr steht nun
          ' an der richtigen Position
   'nÑchstes fehlerhaft gespeichertes Wort
   'suchen
   WHILE Wl_Next%(I%)=I%
     I%=I%+1
   WEND
 UNTIL I%>N%
 S_Anfang%=0:S_Ende%=0
 RETURN 'Uebertrage_Liste_In_Feld


 '*********************************************
 ' Testprozeduren

 DEF PROC B_Ausgeben(Min_Ch%,Max_Ch%)
 ' BehÑlterfeld B() ausgeben
   LOCAL I%

   FOR I%=Min_Ch% TO Max_Ch%
     Ll_Ausgeben(B_Anfang%(I%))
   NEXT I%
 RETURN 'B_Ausgeben

 DEF PROC L_Ausgeben
 ' Liste ausgeben
   LOCAL I%

   FOR I%=0 TO Max_Laenge%
     PRINT I%;"  ";:Ll_Ausgeben(L_Anfang%(I%))
   NEXT I%
 RETURN 'L_Ausgeben

 DEF PROC Wl_Wort_Ausgeben(N%)
 ' Wîrterfeld Wl_Wort$() ausgeben
   LOCAL I%

   FOR I%=0 TO N%
     PRINT Wl_Wort$(I%)
   NEXT I%
 RETURN 'Wl_Wort_Ausgeben





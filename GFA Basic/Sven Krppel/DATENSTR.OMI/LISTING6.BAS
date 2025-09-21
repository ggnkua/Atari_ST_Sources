 '*********************************************
 '*               Listing 6                   *
 '*                                           *
 '*      RADIXSORT zur String-Sortierung      *
 '*         Sortierung rein nach ASCII        *
 '* Version 1                                 *
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
 'mit den ASCII-Werten der zu sortierenden
 'Zeichen indiziert. Es werden mehr BehÑlter
 'angefordert, als benîtigt werden.
 DIM B_Anfang%(Max_Ascii%)
 DIM B_Ende%(Max_Ascii%)

 'N% : Anzahl zu sortierender Worte
 'S_Anfang% : Cursor auf den Anfang der
            ' Wortliste
 'S_Ende%   : Cursor auf das Ende der
            ' Wortliste

 '*********************************************
 ' Sortier-Prozeduren

 DEF PROC Radixsort(R S_Anfang%,R S_Ende%)
   'Radix-Sortierung der Schlange S

   LOCAL Char_Nr%' Nummer des Zeichens, das als
                 ' SchlÅssel benutzt wird.
   FOR Char_Nr%=Max_Laenge% TO 1 STEP -1
     Binsort(S_Anfang%,S_Ende%,Char_Nr%)
   NEXT Char_Nr%
 RETURN 'Radixsort


 DEF PROC Binsort(R S_Anfang%,R S_Ende%,Char_Nr%)
   'Die Prozedur sortiert die Strings der
   'Schlange S in die BehÑlter.
   'Char_Nr% : Nummer des Zeichens im String,
   '           das als SchlÅssel benutzt wird

   LOCAL Wort$' Wort, das einsortiert wird
   LOCAL Ch%' ASCII-Wert des Zeichens, das
            ' einsortiert wird.
   LOCAL I%'  Laufvariable

   'BehÑlter lîschen
   B_Anfang%(0)=0
   B_Ende%(0)=0
   FOR I%=Min_Ascii% TO Max_Ascii%
     B_Anfang%(I%)=0
     B_Ende%(I%)=0
   NEXT I%

   'S in BehÑlter sortieren
   WHILE S_Anfang%<>0
     P%=Wl_Next%(S_Anfang%)' Cursor auf das
               ' zweite Listenelement retten
     Wort$=Wl_Wort$(S_Anfang%)
     IF LEN(Wort$)>=Char_Nr% THEN
        Ch%= ASC( MID$(Wort$,Char_Nr%,1))
     ELSE '    zu kurze Worte kommen in den
        Ch%=0' BehÑlter Nr. 0
     ENDIF
     Ll_Anhaengen(B_Anfang%(Ch%),B_Ende%(Ch%),S_Anfang%)
     S_Anfang%=P%
   WEND

   'BehÑlter auflîsen und sortierte Liste
   'generieren
   S_Anfang%=B_Anfang%(0)
   S_Ende%=B_Ende%(0)
   FOR I%=Min_Ascii% TO Max_Ascii%
     IF B_Anfang%(I%)<>0 THEN ' Schlange in
        'BehÑlter B(I%) nicht leer => verbinden
        Ll_Verbinden(S_Anfang%,S_Ende%,B_Anfang%(I%),B_Ende%(I%))
     ENDIF
   NEXT I%

 RETURN 'Binsort




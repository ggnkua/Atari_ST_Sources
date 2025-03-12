* The Voice nr 2
*
*****************************************************************
*  Atari ST User Assembler Tutorial Series Program PROG0002.S   *
*  Program ten moze byc asemblowany na dysk jako PROG00002.PRG  *
*  lub PROG0002.TOS, i uruchamiany z DESK TOP'u.                *
*****************************************************************
*
* Redakcja The Voice dziekuje Grzegorzowi Mirkowi za udostepnienie
* dyskow ST User'em, gdzie mozna znalezc ten krotki kurs programowania
* w asemblerze.
*
start:
* Na poczatu wyszyscmy ekran.
        MOVE.L  #cls,-(SP)       ; Cls - patrz koniec programu 
        MOVE.W  #9,-(SP)         ; Przeslanie na stos komendy GEMDOS'a
        TRAP    #1               ; Wywolanie GEMDOS'u
        ADDQ.L  #6,SP            ; Uporzadkowanie stosu (przesuniecie o 6)
* Wyswietl greetings
        MOVE.L  #greet,-(SP)     ; Przesun na stos wszystkie dane z pod greet
        MOVE.W  #9,-(SP)         ; Komenda GEMDOS'u (wyswietl ciag znakow)
        TRAP    #1               ; Wywolanie GEMDOS'a
        ADDQ.L  #6,SP            ; Uporzadkuj stos
* Wprowadz wlasne nazwisko/imie
        MOVE.L  #name_in,-(SP)   ; Podajesz ile znakow (patrz koniec prg.)
        MOVE.W  #10,-(SP)        ; Wprowadz dane (komenda GEMDOS'a)
        TRAP    #1               ; Wywolaj
        ADDQ.L  #6,SP            ; Uporzadkuj stos
* Pisz dane z pod etykiety person
        MOVE.L  #person,-(SP)    ; Przesuwamy te dyne na stos
        MOVE.W  #9,-(SP)         ; Wyswietl
        TRAP    #1               ; Wywolaj GEMDOS
        ADDQ.L  #6,SP            ; Uporzadkuj stos
* Napisz wprowadzone nazwisko/imie
        MOVE.L  #name_out,-(SP)  ; Imie/Nazwisko na stos
        MOVE.W  #9,-(SP)         ; Wyswietl
        TRAP    #1               ; GEMDOS 
        ADDQ.L  #6,SP            ; Uporzadkuj stos
* Napisz good bye
        MOVE.L  #bye,-(SP)       ; Dane na stos
        MOVE.W  #9,-(SP)         ; Wyswietl
        TRAP    #1               ; Wywolanie GEMDOS'a
        ADDQ.L  #6,SP            ; Uporzadkuj stos
* Napisz 'Nacisnij klawisz'
        MOVE.L  #keyp,-(SP)      ; Dane na stos (patrz keyp koniec prg.)
        MOVE.W  #9,-(SP)         ; Wyswietl
        TRAP    #1               ; Wywolanie GEMDOS'a
        ADDQ.L  #6,SP            ; Uporzadkuj stos
* Czekaj na klawisz
        MOVE.W  #1,-(SP)         ; 1 na stos
        TRAP    #1               ; Wywolanie GEMDOS'a
        ADDQ.L  #2,SP            ; Uporzadkuj stos
*
* Wracamy do DESK
        CLR.W   -(SP)           ; Czysc stos
        TRAP    #1              ; Wywolanie GEMDOS'a
******************************************************************
* Sekcja danych .                                                *
* Te dane zostana zasemblowane wraz z programem.                 *
        SECTION DATA
*
cls:    DC.B    27,'E',0        ;Sekwencja ESC E czysci ekran
                                ;ASCII 27 to ESCAPE
                                ;ASCII 0 konczy ciag znakow
*
        EVEN
greet:  DC.B    10,10,10,10,10  ;Pierw przeskocz pare lini (ASCII 10 to
                                ;linia w dol).
        DC.B    'Hello, and welcome to',13,10
                                ;ASCII 13 to Return.
        DC.B    27,'p'          ;Sekwencja ESC p to tekst w invers.
        DC.B    "Atari ST User's",13,10
        DC.B    27,'q'          ;Sekwencja ESC q powraca do tekstu w normal
        DC.B    'Assembler Tutorial.',13,10,10
        DC.B    'Prosze wpisac swoje imie i nacisnac RETURN',13,10,10,0
*
        EVEN
person: DC.B    13,10,'Czesc ! ',0
        EVEN
name_in:        DC.B    20,0            ;zostanie wprowadzonych tylko 20 znakow
        EVEN
name_out:
        DS.B    20                      ; wyswietlenie 20 znakow wprowadzonych
*
        EVEN
bye:    DC.B    13,10,10,"Wystarczy na dzis zabawy - ",13,10
        DC.B    'z nauka asemblera...',0
*
        EVEN
keyp:   DC.B    13,10,10,10,10,10
        DC.B    '    Nacisnij klawisz ',0


        
*****************************************************************

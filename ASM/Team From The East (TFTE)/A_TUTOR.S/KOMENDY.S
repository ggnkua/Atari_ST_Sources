* The Voice II by T.F.T.E.
* Assembler Tutorial
* spis najwazniejszych komend asemblera
* oraz trybow adresowania
* plik nie nadaje sie do asemblacji


move a,b - przesuniecie wartosci a pod adres b
move.l - .l na koncu oznacza przesuniecie tzw slowa dlugiego, czyli
                 4 bajtow (tj. 32 bitowa dana)
move.w  - .w przesuwa tylko 16 bitowa dana
move.b  - .b przesyla 8 bitowa dana
moveq #1,a0 - przesuwa liczbe osmiobitowa (tu: 1) do rejestru a0 i 
                        rozciaga ja na pozostale 32 bity.
movem.l a0-a3/d0-d5,-(sp)
         .w
         .b - przepisuje dowolny podzbior wszystkich rejestrow do adresu
                  efektywnego, tu na stos(sp).
trap #1 - wywolanie gemdos'u
trap #14 - wywolanie xbios'u
trap #13 - wywolanie biosu
lea dane, a0 - przeslij adres pod ktorym znajduja sie dane oznaczone 
                        etykieta 'dane' do rejestru a0. Mozna przesylac te adresy
                        tylko pod rejestry a0,a1, ..., a7
pea dane(PC) - podobnie jak wyzej tylko adres przesylany jest na stos(sp)
cmp.l a,b
   .w
   .b - porownaj a z b
bne abc- jezeli nie, to idz do abc
beq abc- jezeli tak, to idz do abc
add a,b (add #1,a0)- dodaje a do b. Wynik w b
                tu 1 zostanie dodane do rejestru a0
rts -powrot z podprogramu
rte - powrot z obslugi przerwan
bra abc - przejscie bezwarunkowe do abc
bsr abc - przejscie do podprogramu
jsr abc - skok do podprogramu
jmp abc - skok do abc
sub #1,a0 - odejmij 1 do a0
clr.l abc
   .w
   .b - zeruje wszystkie bity argumentu abc

***     to chyba wszystkie instrukcje ktore zostaly uzyte w Tutorze ***

Teraz kilka sposobow adresowania.

(a0) - zapisz wartosc pod adres znajdujacy sie w a0.
        ASM: move.l #1,(a0), BASIC: lpoke 1,lpeek(a0)
(a0)+ - zapisz wartosc pod adres znajdujacy sie w a0 i dodaj 
            wartosc (zalezy od .l, .w czy .b)
        ASM: move.l #1,(a0)+, BASIC: lpoke lpeek(a0),1
                                                                 a0=a0+4  !dodaje 4 bo to 32 bity (.l)
-(a0) tak samo jak u gory tylko odejmowanie.
4(a0) - dodaj 4 do a0 i przesun wartosc z pod adresu ktory znajduje sie
                pod a0.
        ASM: move.l 4(a0),a1, BASIC: a0=a0+4
                                                                 lpoke a1,lpeek(a0)                                                      
a0 - wartosc rejestru a0
        ASM: move.l #1,a0,        BASIC: lpoke 1,a0     
        
To sa podstawowe tryby adresowania, a jesli nie podstawowe, to tylko
takie zobaczycie w Tutorze.
        

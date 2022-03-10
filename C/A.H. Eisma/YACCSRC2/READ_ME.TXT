YACC (Yet Another Compiler Compiler)

Dit is een programma waarmee men een parser kan genereren.  
Input is een file .Y met definitie van de te parsen taal, 
uitvoer is een .C file met C-source + tabellen van de gegenereerde 
parser. Tevens kan een .H (include voor andere files) en een .I
(de state tabel van de parser).

Meer info over het gebruik van YACC zie de voorbeelden. 
Er bestaat tevens een YACC handleiding als onderdeel van het 
UNIX programmer's Manual Volume 2B (mijn versie is van January 1979).

Deze versie van YACC is van het STER-BBS afgehaald als MS-DOS 
programma, aangepast voor de ATARI-ST. Zover ik heb kunnen testen 
komen er de goede tabellen uit. Tijdens testen heb ik wat extra debug
prints in de source gezet, deze heb ik laten staan, ze zijn net als
de overige debug statements ondergebracht in conditioneel te compileren
code (#ifdef debug).

=======================================================================

20 mei 1991, A.H. Eisma:

Klein foutje (een NULL-pointer dereference) gecorrigeerd.

Interne datastructuren op maximale grootte gezet om serieuze applicaties
met deze YACC te kunnen bouwen.

Vertaald met Turbo-C 2.0 op Atari-ST, en teruggeporteerd naar PC en daar
ook vertaald met Turbo-C 2.0. Om compileren van vergrootte datastructuren
mogelijk te maken op PC zijn de verschillende datastructuren anders
verdeeld over YMAIN en YDATA.

YACC is opgesplitst over 3 archives:

    YACC_SRC.ARC    - Source, make en project files voor YACC. Alleen nodig
                      als je een aangepaste versie van YACC wilt maken.
    YACC_PC.ARC     - De PC/MS-DOS configuratie van YACC.
                      YACC.EXE, voorbeelden en "documentatie".
    YACC_ST.ARC     - De Aari-ST configuratie van YACC.
                      YACC.TTP, voorbeelden en "documentatie".


=======================================================================

Voor voorgaande wijzigingsnotities, zie de file YACC.INF (in YACC_SRC.ARC).


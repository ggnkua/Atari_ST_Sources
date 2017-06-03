* Routine de d‚compactage d'image DEGAS, inclue … l'adresse IMAGE
SEPT        MACRO
            NOLIST
            ADDQ.B      #1,D3
            MOVE.L      A4,D5
            BTST        #0,D5
            BNE         \RETOUR
            ADD.L       A0,A4
\RETOUR.    SUBQ.B      #1,D0
            LIST
            ENDM

            MOVE.L      #IMAGE,A5     adresse image … d‚comp.

            MOVE.W      #3,-(SP)      cherche l'adresse de
            TRAP        #14           xbios(3) et la
            ADDQ.L      #2,SP         sauve dans A3
            MOVE.L      D0,A3

	 MOVE.L      #6,A0         offset de ligne
            MOVE.L      #199,D4
            MOVEQ       #4,D6
            MOVEQ       #40,D7

            CLR.B       D1            mise … 0 compteur plan de bits
            MOVE.L      A3,A4         xbios(3) dans A3 et dans A4
BOUT3       MOVE.L      A4,-(SP)      sauve adr plan de bit en cours
            CLR.B       D3            mise … 0 compteur oct par ligne
BOUT2       MOVE.B      (A5)+,D0      1 bit de l'image compress‚e
            TST.B       D0
            BMI         NEGA          si c'est n‚gatif
            ADDQ.B      #1,D0         si c'est positif
* on recopie les D0 octets dans le plan de bit en cours
TITI        MOVE.B      (A5)+,(A4)+
            SEPT                      macro d‚finie au d‚but
            BNE         TITI
            BRA         SAUT

NEGA        NEG.B       D0            compl‚ment … 2
            ADDQ.B      #1,D0
            MOVE.B      (A5)+,D2

* on recopie D0 fois l'octet 2 dans le plan de bit en cours
TOTO        MOVE.B      D2,(A4)+
            SEPT
            BNE         TOTO

SAUT        CMP.B       D7,D3
            BNE         BOUT2         on boucle si le nbr
* d'octet par ligne n'est pas complet
            MOVE.L      (SP)+,A4      adr ancien plan de bit ds A4
            ADDQ.L      #2,A4         adr new plan de bit
            ADDQ.B      #1,D1
            CMP.B       D6,D1
            BNE         BOUT3
            ADD.L       #160,A3
            DBF         D4,SAUT1
            RTS

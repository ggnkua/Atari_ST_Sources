********************************************************
*           EXTRAIT DE LA BIBLIOTHEQUE TUBE GEM        *
*                  FICHIER "PRG_END.S"                 *
*              VERSION 4.01 (07 Mai 1991)              *
********************************************************
* Routine du protocole GEM. Cette routine doit ˆtre
* ex‚cut‚e … la fin des programmes, afin de remttre
* le tableau en ‚tat (retrait de l'APP_ID du programme).
* JY_SUIS a ‚t‚ ajout‚ le 14/5/91 simplement par
* commodit‚ (le N. de version reste le mˆme)
OFF_TUBE_PRG:
        MOVEM.L D0-D7/A0-A6,-(SP)
        CMP.W   #$FFFF,JY_SUIS
        BEQ     END_OFF_PRG
        MOVE.L  #"_TUB",COOKIE1
        MOVE.L  #0,COOKIE2
        MOVE.L  #0,COOKIE3
        MOVE.W  #0,COOKIE4
        MOVE.L  #COOKIE_JAR,-(SP)
        MOVE.W  #38,-(SP)
        TRAP    #14
        ADDQ.L  #6,SP
* En retour COOKIE2 contient l'adresse de la boite … gateaux.
        TST.L   COOKIE2 trouv‚ l'adresse ?
        BEQ     END_OFF_PRG     non donc bye bye...
* et COOKIE3 l'adresse du tableau protocole
        TST.L   COOKIE3 trouv‚ ce tableau ?
        BEQ     END_OFF_PRG     non donc bye bye...
* Nous allons v‚rifier que ce tableau contient bien
* les AP_ID et nous allons retirer le notre.
        MOVE.L  COOKIE3,A6              
        CMP.L   #"PROT",(A6)+  L'en-tˆte est bonne ?
        BNE     END_OFF_PRG    non donc bye bye...
* Continuons … avancer sur le tableau pour
* trouver notre AP_ID et le supprimer.
        MOVE.W  (A6)+,D5        nbr maxi d'APP_ID
.ICI    MOVE.W  (A6),D0 pr‚l‚ve cet AP_ID
        CMP.W   APP_ID,D0       compare avec notre AP_ID
        BEQ     FIND_IT
        CMP.W   #$FFFF,D0
        BEQ     END_OFF_PRG
        SUBQ.W  #1,D5   compte cet APP_ID
        ADDA.L  #2,A6   et pointe sur le suivant
        BRA.S   .ICI
* Notre AP_ID est trouv‚: remontons tout le bas du tableau d'un cran.
FIND_IT MOVE.L  A6,A5
        ADDA.L  #2,A5
        MOVE.W  (A5)+,D0
        MOVE.W  D0,(A6)+
        CMP.W   #$FFFF,D0
        BEQ     END_OFF_PRG
        SUBQ.W  #1,D5   compte cet APP_ID
        CMP.W   #1,D5
        BNE     FIND_IT
* D5=1 or c'est normalement impossible car je viens de retirer
* mon APP_ID, je vais donc forcer un flag de fin.
        MOVE.W  #$FFFF,(A6) 
END_OFF_PRG
        MOVEM.L (SP)+,D0-D7/A0-A6
        RTS
*--------------------------------------------------------------------------*    


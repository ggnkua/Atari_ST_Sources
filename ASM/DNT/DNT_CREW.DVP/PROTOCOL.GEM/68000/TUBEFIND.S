***************************************************************
*              EXTRAIT DE LA BIBLIOTHEQUE TUBE GEM            *
*                    FICHIER "TUBEFIND.S"                     *
*                  VERSION 5.01  (07 Mai 1991)                *
***************************************************************
* Routine appel‚e … chaque fois que l'on d‚sire envoyer quelque chose.
* Cette routine renvoi en A0 l'adresse du tableau contenant la liste des 
* APP_ID des applications actives en m‚moire. Si au retour A0=0 c'est que
* cette liste n'est pas accessible.
FIND_APID:      MOVEM.L D0-D7/A1-A6,-(SP)
        MOVE.L  #"_TUB",COOKIE1 identificateur … chercher
        MOVE.L  #0,COOKIE2              trop tard pour cr‚er new-box
        MOVE.L  #0,COOKIE3              je veux juste lire le cookie
        MOVE.W  #0,COOKIE4              et ne rien ‚craser      
        MOVE.L  #COOKIE_JAR,-(SP)
        MOVE.W  #38,-(SP)               
        TRAP    #14             
        ADDQ.L  #6,SP           
* COOKIE2 contient l'adresse de la boite ou 0 si pas trouv‚e
        TST.L   COOKIE2
        BEQ     .ICI
* En retour l'adresse correspond … mon COOKIE, et donnant donc
* l'adresse du tableau PROT, est en COOKIE3
        TST.L   COOKIE3 nous avons trouv‚ ce tableau ?
        BNE.S   FIND_APID_1   oui --> v‚rification
* Nous n'avons pas trouv‚ le tableau, alerte et bye bye...
.ICI    FORM_ALERT      #1,#ALERTE_TUB3
        MOVE.L  #0,A0          valeur de retour
        BRA     END_FINDAPID
* Nous avons trouv‚ le tableau. V‚rifions son en-tˆte.
FIND_APID_1
        MOVE.L  COOKIE3,A0
        CMP.L   #"PROT",(A0)
        BEQ     OK_FINDAPID
* C'est rat‚, il n'y a rien de correct...
ERREUR_APID
        FORM_ALERT      #1,#ALERTE_TUB1
        MOVE.L  #0,A0          valeur de retour
        BRA     END_FINDAPID
OK_FINDAPID
        MOVE.L  COOKIE3,A0      valeur de retour
END_FINDAPID
        MOVEM.L (SP)+,D0-D7/A1-A6
        RTS
*--------------------------------------------------------------------------*


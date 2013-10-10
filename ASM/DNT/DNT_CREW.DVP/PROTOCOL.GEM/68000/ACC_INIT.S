*******************************************************
*         EXTRAIT DE LA BIBLIOTHEQUE TUBE GEM         *
*                FICHIER "ACC_INIT.S"                 *
*             VERSION 4.01 (07 Mai 1991)              *
*              Routine pour accessoires               *
*******************************************************
INIT_TUBE_ACC:
        MOVEM.L D0-D7/A0-A6,-(SP)
        CLR.W   JY_SUIS    par d‚faut je suis dans la liste
        MOVE.W  #0,COOKIE4              Ne pas ‚craser!
INIT_TUBE0
        MOVE.L  #"_TUB",COOKIE1         gateaux … chercher
        LEA     NEW_JAR,A0              nouvelle boite,
        MOVE.L  A0,COOKIE2              au cas ou...
        LEA     TAB_TUBE,A0             adresse … mettre
        MOVE.L  A0,COOKIE3              si elle est introuvable...
        MOVE.L  #COOKIE_JAR,-(SP)       
        MOVE.W  #38,-(SP)               
        TRAP    #14             
        ADDQ.L  #6,SP
* En retour COOKIE2 contient l'adresse de la boite, ou 0
* si elle n'est pas disponible pour nous.
        TST.L   COOKIE2
        BEQ     BAD_INIT
* COOKIE3 contient l'adresse du tableau. Si c'est le notre nous
* le remplissons avec notre APP_ID, sinon nous v‚rifions sa validit‚
* (et ‚ventuellement nous l'‚crasons).
        LEA     TAB_TUBE,A5     adresse de notre liste
        CMP.L   COOKIE3,A5
        BNE.S   .ICI0
* Nous venons de placer notre liste, initialisons-l….
        MOVE.L  #"PROT",(A5)+ en-tˆte
        MOVE.W  #10,(A5)+          nbr d'APP_ID accept‚s
        MOVE.W  APP_ID,(A5)+  notre APP_ID
        MOVE.W  #$FFFF,(A5)+  puis le flag de fin
        BRA     INIT_TUBE_ACC_END  et bye bye...

* L'adresse trouv‚e dans COOKIE3 n'est pas la notre,
* nous v‚rifions donc la validit‚ de ce tableau.
.ICI0   MOVE.L  COOKIE3,A5
        MOVE.W  #1,COOKIE4      pr‚parons nous … l'‚craser...
        CMP.L   #"PROT",(A5)+   en-tete liste AP_ID
        BNE     INIT_TUBE0      pas valable, ‚crasement!
* Il y a un tableau en place, son en-tˆte est bonne,
* mais ce n'est pas le notre. Il faut donc le parcourir, y
* inscrire notre APP_ID, et le clore par $FFFF
        MOVE.W  (A5)+,D0        nbr maxi d'APP_ID du tableau
BOUCLE: MOVE.W  (A5),D1 pr‚l‚ve la valeur 
        CMP.W   #$FFFF,D1       c'est le flag de fin ?
        BEQ     .ICI
* Cas tr‚s sp‚cial des ACC lanc‚s par Multidesk ou Stuffer !!!
* Il faut donc pr‚voir le cas ou notre APP_ID est d‚ja pr‚sent!
        CMP.W   APP_ID,D1  d‚ja le notre ?
        BEQ     INIT_TUBE_ACC_END     oui donc bye bye...
        SUBQ.W  #1,D0   compte cet APP_ID
        TST.W   D0      est-il possible qu'il en reste ?
* Il n'y a plus de place dans le tableau, nous nous en allons.
* Il serait tout … fait possible de faire comme dans le cas
* du cookie jar, c'est … dire r‚server une liste plus grande,
* y recopier l'ancienne et recommencer.
        BEQ     BAD_INIT     plus de place, bye bye...
        ADDA.L  #2,A5   passe au word suivant
        BRA     BOUCLE  
        
* Nous avons trouv‚ la fin du tableau, nous pla‡ons 
* notre APP_ID ainsi que la marque de fin.
.ICI    MOVE.W  APP_ID,(A5)+    
        MOVE.W  #$FFFF,(A5)
        BRA     INIT_TUBE_ACC_END
BAD_INIT
        MOVE.W  #$FFFF,JY_SUIS  indique je ne suis pas dans la liste	
INIT_TUBE_ACC_END
        MOVEM.L (SP)+,D0-D7/A0-A6
        RTS             
*--------------------------------------------------------------------------*


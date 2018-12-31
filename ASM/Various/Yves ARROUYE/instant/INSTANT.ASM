*****************************************************************************
*****************************************************************************
**                                                                         **
**                   SAUVEGARDE D'êCRAN AU FORMAT DEGAS                    **
**                                                                         **
**                                                                         **
*****************************************************************************
*****************************************************************************


               TEXT


QUOTE          equ       $BA                           * Apostrophe "'"


AFFICHE        macro
               move.l    #\1,-(sp)                     * Texte Ö afficher
               move.w    #9,-(sp)                      * Cconws()
               trap      #1
               addq.l    #6,sp
               endm


debut          bra       depart


********************************************************************************
*                                                                              *
*                Routine de sauvegarde de l'Çcran au format DEGAS              *
*                                                                              *
********************************************************************************

sauver         move.w    #1,$4EE                       * Drapeau de Copie d'Ecran validÇ

               move.w    #$4,-(sp)                     * Getrez()
               trap      #14
               addq.l    #2,sp
               move.w    d0,Degas_Header
               add.b     #'1',d0
               move.b    d0,Resolution

               move.l    #$FF8240,a0                   * Adresse de la Palette
               lea       Palette,a1
               move.l    #15,d0
boucle         move.w    (a0)+,(a1)+
               dbra      d0,boucle

               move.w    #0,-(sp)
               move.l    #Nom,-(sp)
               move.w    #$3C,-(sp)                    * Fcreate()
               trap      #1
               addq.l    #8,sp

               move.w    d0,Id_Fichier

               pea       Degas_Header
               move.l    #34,-(sp)                     * 34 Octets d'en-tete pour Degas Elite
               move.w    Id_Fichier,-(sp)
               move.w    #$40,-(sp)                    * Fwrite()
               trap      #1
               add.l     #12,sp

               move.w    #$25,-(sp)                    * Synchro Graphique
               trap      #14
               addq.l    #2,sp

               move.w    #2,-(sp)                      * Physbase()
               trap      #14
               addq.l    #2,sp

               move.l    d0,-(sp)                      * Adresse Physique de l'Çcran
               move.l    #32000,-(sp)
               move.w    Id_Fichier,-(sp)
               move.w    #$40,-(sp)                    * Fwrite()
               trap      #1
               add.l     #12,sp

               move.w    Id_Fichier,-(sp)
               move.w    #$3E,-(sp)                    * Fclose()
               trap      #1
               addq.l    #4,sp

               move.l    #Numero,a0                    * IncrÇmente le numÇro de l'Image
               addq.l    #1,a0
               cmp.b     #'9',(a0)
               beq       dizaines
               add.b     #1,(a0)
               bra       fini
dizaines       move.b    #'0',(a0)
               add.b     #1,-(a0)

fini           move.w    #$FFFF,$4EE                   * Drapeau de Copie Ö -1

               rts                                     * Retour


********************************************************************************
*                                                                              *
*     Variables nÇcessaires au bon fonctionnement des deux routines qui prÇ-   *
* cädent. Elles sont insÇrÇes dans le code pour pouvoir etre gardÇes acces-    *
* sibles apräs retour au Bureau GEM.                                           *
*                                                                              *
********************************************************************************

               cnop      0,2

Id_Fichier     ds.w      1

Degas_Header   dc.w      2                             * RÇsolution
Palette        ds.l      8                             * Palette et infos

Nom            dc.b      "A:\ECRAN_"
Numero         dc.b      "00.PI"                       * Attention ! Adresse impaire...
Resolution     dc.b      "3"

Table          dc.b      0


********************************************************************************
*                                                                              *
*     Initialisation du programme et installation de la routine de sauvegarde  *
* des images au format DEGAS.                                                  *
*                                                                              *
********************************************************************************

depart         move.l    4(sp),a5
               move.l    $C(a5),d0
               add.l     $14(a5),d0
               add.l     $14(a5),d0
               add.l     #$100,d0
               move.l    d0,-(sp)
               move.l    a5,-(sp)
               move.l    d0,-(sp)
               move.w    #$4A,-(sp)                    * Mshrink()
               trap      #1
               add.l     #12,sp

installe       AFFICHE   Texte                         * Messages de pub !
               AFFICHE   Pub
               AFFICHE   Copyright

               clr.l     -(sp)
               move.w    #$20,-(sp)                    * Super()
               trap      #1                            * Passage en mode Superviseur
               addq.l    #6,sp

               move.l    #sauver,$502                  * Routine de Sauvegarde Ö la place de Copie d'Çcran
               move.w    #$FFFF,$4EE                   * Drapeau de Copie Ö -1

               move.l    d0,-(sp)                      * Pile Superviseur
               move.w    #$20,-(sp)                    * Super()
               trap      #1                            * Retour en mode Utilisateur
               addq.l    #6,sp

               move.w    #0,-(sp)                      * Code de Sortie
               move.l    #Table,d0
               sub.l     #sauver,d0
               add.l     #$104,d0
               move.l    d0,-(sp)                      * Nombre d'Octets Ö conserver
               move.w    #$31,-(sp)                    * Ptermres()
               trap      #1                            * Fin du programme


               DATA


Pile           dc.l      0

Texte          dc.b      $1B,$45,13,10
               dc.b      "SAUVEGARDE D",QUOTE,"ECRANS AU FORMAT DEGAS",13,10
               dc.b      "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",13,10,10,10,10
               dc.b      "  Appuyer simultan",$82,"ment sur <ALTERNATE>",13,10
               dc.b      "et <HELP> pour sauvegarder l",QUOTE,$82,"cran au",13,10
               dc.b      "format DEGAS...",13,10,10,10,10,0

Pub            dc.b      "Conception et Programmation",32,$3A,13,10,10
               dc.b      "  Yves ARROUYE",13,10
               dc.b      "  10, Avenue Eug",$8A,"ne de Mazenod",13,10
               dc.b      "      Val Saint Donat 1",13,10
               dc.b      "  13100 Aix-en-Provence",13,10,10
               dc.b      "  T",$82,"l",$82,"phone : 42 23 10 30",13,10,10,10,10,0

Copyright      dc.b      "CopyRight (C) 1987, SEVY SOFT.",0


               END


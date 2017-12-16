* Routine de point en 256 couleurs
* 640*400 en 256 couleurs

     section TEXT
* demande de r‚solution
     move.w #-1,-(sp)
     move.w #$58,-(sp)        * Vsetmode
     trap #14
     adda.l #4,sp
     move.w d0,ancien_mode
* adresse physique
     move.w #2,-(sp)          * Physbase
     trap #14
     adda.l #2,sp 
     move.l d0,ancien_phys
* adresse logique
     move.w #3,-(sp)          * Logbase
     trap #14
     adda.l #2,sp
     move.l d0,ancien_log

* Mise en place de la nouvelle r‚solution
* calcul de l'adresse ‚cran (qui doit ˆtre un mutiple de 4)
     move.l #ecran+4,d0
     andi.b #$FC,d0           * il  suffit d'annuler les 2  bits  de  poid 
                              * faible
     move.l d0,adr_ecran      * on stocke l'adresse ‚cran
     move.w #%0000000100101011,-(sp) * entrelac‚/80 colonnes/256 couleurs
                                     * TV/PAL/pas d'overscan
     move.w #3,-(sp)
     move.l d0,-(sp)          * ‚cran physique = ‚cran logique
     move.l d0,-(sp)
     move.w #5,-(sp)          * Setscreen
     trap #14
     adda.l #14,sp

     move.w #100,d3
     move.w #50,d4
     move.w #100,d5
* appel de la routine de point
* D0 : X
* D1 : Y
* D2 : couleur
affiche_pts
     move.w d3,d0
     move.w d4,d1
     move.w #100,d2   
     bsr point           * affiche le point de coordonn‚es (D3, D4)
     addq.w #1,d3        * passage au point (D3+1, D4+1)
     addq.w #1,d4        * ce qui nous trace une diagonale!!
     dbra d5,affiche_pts    

* fin du programme
* attente de touche
     move.w #7,-(sp)
     trap #1             * Fonction C_Rawcin du gemdos
     adda.w #2,sp        * Attenet d'une touche
     
* remise en place de la r‚solution
     move.w ancien_mode,-(sp)
     move.w #3,-(sp)
     move.l ancien_phys,-(sp)
     move.l ancien_log,-(sp)
     move.w #5,-(sp)
     trap #14
     adda.l #14,sp

* retour systŠme
     move.w #0,-(sp)
     trap #1

* routine de point en 256 couleurs, 640 points de large
point
* recoit en D0 : X, D1 : Y, D2 : couleur
* modifie D0, D1, D2, D6, D7, A0
* calcul de l'adresse de la ligne
     movea.l adr_ecran,a0
     mulu.w #640,d1      * r‚sultat sur un mot long !!
     adda.l d1,a0
* calcul de l'adresse du groupement de mot
*  Rq.  :  diviser par 16 puis remultiplier par 16,  reviens en entier  …
* effacer  les  4  bits  de poids faible  (astuce  valable  uniquement  256
* couleurs, sinon : une bonne divu bien bourrin ferat l'affaire)
     move.w d0,d1
     andi.w #$FFF0,d1
     adda.w d1,a0
* Calcul du No de bit … modifier dans les 8 mots
* le reste de la division est contenu dans les 4 bits de poids faible
* valable quelque soit le Nbre de couleurs
     andi.w #$00000F,d0
     eori.w #$00000F,d0       * c'est ‚quivalent … (ÝF-1)-d0
* A0 contient l'adresse du mot qui code le bit le plus faible
* D0 contient le num‚ro de bit
* modification plan par plan
     moveq.w #0,d6            * contient le num‚ro de plan
point_bc
     move.w (a0),d1
* test de la position du bit No D6 de D2 (couleur)
     btst.l d6,d2
     beq point_bit_nul
     * le bit est donc … 1
     * Mise … 1 du bit No D0 dans D1
     bset.l d0,d1
     bra point_s1
point_bit_nul
     bclr.l d0,d1
point_s1
     * remet le mot en m‚moire
     move.w d1,(a0)+
     addq.b #1,d6             * plan suivant
     cmpi.b #8,d6             * on s'arr‚te au 9iŠme plan!!
     bne point_bc
     rts

     section BSS
     EVEN
* variable
* initialisation
ancien_mode    ds.w 1   
ancien_phys    ds.l 1
ancien_log     ds.l 1
adr_ecran      ds.l 1
ecran          ds.b 640*400+4


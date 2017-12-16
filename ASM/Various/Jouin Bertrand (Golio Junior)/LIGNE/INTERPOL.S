* Routine de ligne en True Color (640*400)

wait_sys macro
     move.w sr,-(sp)
     andi.w #$fbff,sr
     move.l $466.w,d0
wait_sys\@
     cmp.l $466.w,d0
     beq.s wait_sys\@
     move.w (sp)+,sr
     endm


     section TEXT
* passage en superviseur
     clr.l -(sp)
     move.w #32,-(sp)
     trap #1
     addq.l #6,sp
     
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
     move.w #%0000000100101100,-(sp) * entrelac‚/80 colonnes/65536 couleurs
                                     * TV/PAL/pas d'overscan
     move.w #3,-(sp)
     move.l d0,-(sp)          * ‚cran physique = ‚cran logique
     move.l d0,-(sp)
     move.w #5,-(sp)          * Setscreen
     trap #14
     adda.l #14,sp

bouc
     wait_sys
     * permet d'obtenir le temps machine en bleu
     move.w #$0000,$ff9800
* appel de la routine de ligne
* D0 : X de d‚part
* D1 : Y de d‚part
* D2 : X de d'arriv‚
* D3 : Y de d'arriv‚
* D4 : couleur
     
     rept 10   	   * tracer de 10 ligne
     move.w #0,d0
     move.w #0,d1
     move.w #639,d2
     move.w #399,d3
     move.w #%0011000011000110,d4
     bsr ligne           * trace la ligne    
     endr

     move.w #$ffff,$ff9800
     * repetion tant que la touche espace
     * n'est pas frapp‚e
     
     cmp.b #$39,$fffffc02.w
     bne bouc
* fin du programme

* remise en place de la r‚solution
     move.w ancien_mode,-(sp)
     move.w #3,-(sp)
     move.l ancien_phys,-(sp)
     move.l ancien_log,-(sp)
     move.w #5,-(sp)
     trap #14
     adda.l #14,sp

* retour au mode utilisateur
     clr.l -(sp)
     move.w #32,-(sp)
     trap #1
     addq.l #6,sp

* retour systŠme
     move.w #0,-(sp)
     trap #1

* routine de ligne en 65536 couleurs, 640 points de large
ligne
* recoit en D0 : X, D1 : Y : de d‚part
*           D2 : X, D3 : Y : d'arriv‚e
* D4 : couleur sur 32 bits !!
* modifie D0, D1, A0
* stockage de yinc
     move.l #640*2,d7
* calcul de dx dans D5
     move.w d2,d5
     sub.w d0,d5
     beq rout5	
* si dx est nul, ligne verticale !!
     bpl xpasneg1			
* si dx negatif, donc d2<d0
* donc le premier point devient d2,d3
     neg.w d5
     exg.l d2,d0
     exg.l d3,d1
xpasneg1
* on trace toujours vers les x croissants
* calcul de dy
     move.w d3,d6
     sub.w d1,d6
     beq rout4			
* dy est nul, ligne horizontal	
     bpl ypasneg1
* dy n‚gatif, donc d4<d1
     neg.w d6
* trac‚ en montant vers la droite
* donc d7=-640*2
     neg.l d7
ypasneg1
     cmp.w d5,d6
* comparaison dx et dy
     bmi rout2     * <0
     beq rout3     * =0 : une diagonale !!!

* … la fin : d5 : dx
*            d6 : dy
* routine 1
* ici dx>0, dy>0 et dy>dx
* a pus besoin de d2, d3, et dx aprŠs division
rout1
* si dx = 1 : 2 pixels de large !!
* donc il faut rajouter 1 … chaque d
     addq.w #1,d5
     addq.w #1,d6
* d‚calage de 16 bits pour la division
     swap d5
     clr.w d5
     divu.w d6,d5		
* division de dx par dy + division par 16 bits
* d5 contient la pente : r‚sultat sur 16 bits
* boucle sur d6
     subq.w #1,d6
* calcul d'adresse du 1er point dans a0
     movea.l adr_ecran,a0
     add.w d0,d0
     adda.w d0,a0
     mulu.w #1280,d1
     adda.l d1,a0
* somme = 0
     moveq.l #0,d3	
     * d0 : 
     * d1 : 
     * d2 : 
     * d3 : somme
     * d4 : couleur
     * d5 : pente
     * d6 : delta y
     * d7 : offset pour changement de ligne 
ligneb1
     add.w d5,d3
     bcs lignenx1
* pas de d‚placement suivant x
     move.w d4,(a0)
     adda.l d7,a0
     dbra d6,ligneb1
     rts
lignenx1
     move.w d4,(a0)+
     adda.l d7,a0
     dbra d6,ligneb1
     rts

* routine 2
* ici dx>0, dy>0 et dy<dx
* a pus besoin de d2, d3, et dy aprŠs division
rout2
* correction de d
     addq.w #1,d5
     addq.w #1,d6
* d‚calage de 16 bits
     swap d6
     clr.w d6
     divu.w d5,d6		
* division de dy par dx + division par 16 bits
* d6 contient la pente : r‚sultat sur 16 bits
* boucle sur d5
     subq.w #1,d5
* calcul d'adresse du 1er point dans a0
     movea.l adr_ecran,a0
     add.w d0,d0
     adda.w d0,a0
     mulu.w #1280,d1
     adda.l d1,a0
* somme = 0
     moveq.l #0,d3
     * d0 : 
     * d1 : 
     * d2 : 
     * d3 : somme
     * d4 : couleur
     * d5 : delta x
     * d6 : pente
     * d7 : offset pour changement de ligne et de pixel
ligneb2
     move.w d4,(a0)+
     add.w d6,d3
     bcc ligneny2			
* pas de d‚placement suivant y 
     adda.l d7,a0
ligneny2
     dbra d5,ligneb2
     rts

* ici dx>0, dy>0 et dx=dy
* une diagonale!!
* OK
rout3
* calcul d'adresse du 1er point dans a0
     movea.l adr_ecran,a0
     add.w d0,d0
     adda.w d0,a0
     mulu.w #1280,d1
     adda.l d1,a0
* division par 2 de d5
     lsr.w #1,d5
     bcc ligneb3
* si retenue alors nombre impair
     move.w d4,(a0)
     adda.l d7,a0
* ce qui permet d'afficher 2 points par 2 points
ligneb3
     move.w d2,(a1)+
     adda.l d7,a1
     move.w d2,(a1)+
     adda.l d7,a1
     dbra d5,ligneb3
     rts

* ici dy est nul
* et dx positif
* ligne horizontale
* OK
rout4
* calcul d'adresse du 1er point dans a0
     movea.l adr_ecran,a0
     add.w d0,d0
     adda.w d0,a0
     mulu.w #1280,d1
     adda.l d1,a0
* division de d5 par 2
     lsr.w #1,d5
     bcc ligneb4
* d5 : nombre impaire
     move.w d4,(a0)+
ligneb4
     move.l d4,(a0)+
* 2 pixels d'un coup !
     dbra d5,ligneb4
     rts

* ici dx est nul
* et dy est inconnu
* ligne verticale
* OK
rout5
     move.w d3,d6
     sub.w d1,d6
     bmi rout5_yneg
     beq rout6
* calcul d'adresse du 1er point dans a0
     movea.l adr_ecran,a0
     add.w d0,d0
     adda.w d0,a0
     mulu.w #1280,d1
     adda.l d1,a0
* division par 2 de d6
     lsr.w #1,d6
     bcc ligneb5
* d6 : nombre impaire
     move.w d4,(a0)
     adda.l d7,a0
ligneb5
     move.w d4,(a0)
     adda.l d7,a0
     move.w d4,(a0)
     adda.l d7,a0
     dbra d6,ligneb5
     rts
rout5_yneg
     neg.w d6
* calcul d'adresse du 1er point dans a0
     movea.l adr_ecran,a0
     add.w d0,d0
     adda.w d0,a0
     mulu.w #1280,d1
     adda.l d1,a0
* division par deux de d6
     lsr.w #1,d6
     bcc ligneb5_yneg
* d6 : nombre impair
     move.w d4,(a0)
     adda.l d7,a1
ligneb5_yneg
     move.w d4,(a0)
     adda.l d7,a0
     move.w d4,(a0)
     adda.l d7,a0
     dbra d6,ligneb5_yneg
     rts

* deltax est nul
* deltay est nul
* c'est un point
* OK
rout6
* calcul d'adresse du 1er point dans a0
     movea.l adr_ecran,a0
     add.w d0,d0
     adda.w d0,a0
     mulu.w #1280,d1
     adda.l d1,a0
     move.w d4,(a0)
     rts

     section BSS
     EVEN
* variable
* initialisation
ancien_mode    ds.w 1   
ancien_phys    ds.l 1
ancien_log     ds.l 1
adr_ecran      ds.l 1
ecran          ds.b 640*2*400+4
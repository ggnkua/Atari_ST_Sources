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
* D4 : couleur
* modifie D0, D1, A0
* calcul de dx dans D5
     move.w d0,d5
     sub.w d2,d5
     bpl ligne_s1   * resultat poistif
     neg.w d5
ligne_s1
* calcul de dy dans d6
     move.w d1,d6
     sub.w d3,d6
     bpl ligne_s2
     neg.w d6
ligne_s2
* calcul de Xinc
     cmp.w d0,d2
     bmi ligne_s3
     * ici Xd < Xf donc Xinc = +1
     move.w #2,xinc
     bra ligne_s4
ligne_s3
     move.w #-2,xinc
ligne_s4
* calcul de Yinc
     cmp.w d1,d3
     bmi ligne_s5
     * ici Yd < Yf donc Yinc = +1
     move.w #1280,yinc
     bra ligne_s6
ligne_s5
     move.w #-1280,yinc
ligne_s6
* calcul de dx2
     move.w d5,dx2
     add.w d5,dx2
* calcul de dy2
     move.w d6,dy2
     add.w d6,dy2
* affichage du premier point
     movea.l adr_ecran,a0
     adda.w d0,a0
     adda.w d0,a0	* 2*X
     move.w d1,d7
     mulu.w #1280,d7	* + 1280*Y
     adda.l d7,a0
     move.w d4,(a0)	* affichage
* comparaison de dx et dy
     cmp.w d5,d6
     bmi ligne_s7
     * ici DX < DY
     * y change plus vite que x
     * d7 : S
* calcul de s
     move.w dx2,d7
     sub.w d6,d7
     * il n'y a plus besoin de dx
     * d5 : DXY
* calcul de DXY
     move.w dx2,d5
     sub.w dy2,d5
* debut de la boucle i
     subq.w #1,d6
ligne_b1
     tst.w d7
     bmi ligne_b1s1
     * ici s est positif
     * x=x+xinc
     adda.w xinc,a0
     * s=s+dxy
     add.w d5,d7
     bra ligne_b1s2
ligne_b1s1
     add.w dx2,d7
ligne_b1s2
     * y = yinc+y
     adda.w yinc,a0
     * affichage du point
     move.w d4,(a0)
     dbra d6,ligne_b1
     bra ligne_fin

ligne_s7
     * x change plus vite que y
     * d7 : S
* calcul de s
     move.w dy2,d7
     sub.w d5,d7
     * il n'y a plus besoin de dy
     * d6 : DXY
* calcul de DXY
     move.w dy2,d6
     sub.w dx2,d6
* debut de la boucle i
     subq.w #1,d5
ligne_b2
     tst.w d7
     bmi ligne_b2s1
     * ici s est positif
     * y=y+yinc
     adda.w yinc,a0
     * s=s+dxy
     add.w d6,d7
     bra ligne_b2s2
ligne_b2s1
     add.w dy2,d7
ligne_b2s2
     * x=xinc+x
     adda.w xinc,a0
     * affichage du point
     move.w d4,(a0)
     dbra d5,ligne_b2
ligne_fin
     rts

     section BSS
     EVEN
* variable
xinc	ds.w 1
yinc	ds.w 1
dx2	ds.w 1
dy2	ds.w 1

* initialisation
ancien_mode    ds.w 1   
ancien_phys    ds.l 1
ancien_log     ds.l 1
adr_ecran      ds.l 1
ecran          ds.b 640*2*400+4



*******************************
*	ALTERNATE-HELP     *
*    POUR SAUVER L'ECRAN!     *
*  PAR GILLUS LE 04/09/1989   *
*******************************

************************************************************
* pour des commentaires supplementaires reportez-vous au   *
* StMag nø35 p.114 - je suis sur 36.15 STMAG bal:GILLUS-ST *
************************************************************

TEXT

 
add:	EQU $200	      * ceci indique l'adresse ou 
			      * le programme va se reloger

      clr.l   -(sp)
      move.w  #$20,-(sp)
      trap    #1
      addq.l  #6,sp	      * passe en superviseur
      move.l  d0,userstack
      move.l  $70,mavariable  * ancienne VBL dans mavariable
  
      lea     fini,a3	      * adresse de la fin de la routine
      lea     ainter,a0	      * adresse de d‚but de la routine
      lea     add,a1	      * adresse de recopie routine
copi: move.w  (a0)+,(a1)+
      cmp.l   a0,a3
      bhi     copi

      move.w  sr,-(sp)	      * sauvegarde sr sur la pile   
      move.w  #$2700,sr       * coupe les interruptions
      move.l  #add,$70	      * notre routine comme VBL
      move.w  (sp)+,sr	      * je r‚tablis sr
      move.l  userstack,-(sp) 
      move.w  #$20,-(sp)
      trap    #1
      addq.w  #6,sp
      pea pre 
      move.w  #9,-(sp)
      trap    #1	      * affiche message de presentation
      addq.l  #6,sp
      move.w  #$07,-(sp)      * lecture clavier
      trap    #1	      * (pour attendre que l'utilisateur
      addq.l  #2,sp	      * appuie sur une touche)

      clr.w   -(sp)	      * FIN du programme
      trap    #1

ainter:

      tst.w   $4ee
      BEQ RAZ
      move.l  mavariable(pc),-(sp)     * voir article
      rts

RAZ:
      move.w  sr,-(sp)	     * on sauvegarde sr sur la pile
      move.w  #$2700,sr      * on coupe les interrups.
      MOVEM.L D0/D7-A0/A6,-(SP)        * on sauvegarde tous les 
				       * registres




      move.w  #2,-(sp)
      trap    #14
      addq.l  #2,sp	     * on prend l'adresse de l'‚cran
      move.l  d0,a6	     * on la met dans a6
      move.w  #4,-(sp)	     * on prend la r‚solution
      trap    #14
      addq.l  #2,sp
      lea head(pc),a3
      move.b  d0,1(A3)	     * on la met dans le header    
      lea car(pc),a3	     * RAZ de l'extension fichier
      add.b   d0,11(a3)      * on lui rajoute la r‚solution

      clr.w   -(sp)
      pea     car(pc)
      move.w  #$3c,-(sp)
      trap    #1	     * on cr‚e le fichier
      addq.l  #8,sp

      move.w  d0,a5
  
      PEA     head(pc)
      move.l  #2,-(sp)
      move.w  a5,-(sp)
      move.w  #$40,-(sp)
      trap    #1	     * on ‚crit le header
      addq.l  #8,sp

      move.w  d0,a5
  
      PEA     $ff8240
      move.l  #32,-(sp)
      move.w  a5,-(sp)
      move.w  #$40,-(sp)
      trap    #1	     * on sauvegarde les couleurs
      add.l   #15,sp

      move.l  a6,-(sp)
      move.l  #32000,-(sp)
      move.w  a5,-(sp)
      move.w  #$40,-(sp)
      trap    #1	     * on sauvegarde l'image
      add.l   #15,sp

      PEA     finim(pc)
      move.l  #32,-(sp)
      move.w  a5,-(sp)
      move.w  #$40,-(sp)
      trap    #1	     * on complete le fichier
      add.l   #12,sp
      move.w  a5,-(sp)
      move.w  #$3e,-(sp)
      trap    #1	     * on ferme le fichier
      addq.l  #4,sp

      lea car(pc),a3
      addq.b  #1,7(a3)	     * incr‚ment le nom de fichier
 
      MOVE.W #$FFFF,$4EE     * voir article 
     
      move.w  #-1,-(sp)
      move.w  #11,-(sp)
      trap    #13	     * ‚tat des touches sp‚ciales
      addq.l  #4,sp

      lea cla(pc),a3
      move.w  d0,(a3)
      addq.l  #1,a3
      bclr.b  #3,(a3)	     * on force a 0 le bit 3
      move.w  cla(pc),-(sp)
      move.w  #11,-(sp)
      trap    #13	     * on d‚sactive alternate
      addq.l  #4,sp

      MOVEM.L (SP)+,D0/D7-A0/A6   * on r‚tablit les registres

      move.w  (sp)+,sr	     * on r‚tablit les interruptinos
      move.l  mavariable(pc),-(sp)  * voir article
      rts

car:	      dc.b "a:\EKR_A.PI1",0,0,0
mavariable:   ds.l 1
cla:	      ds.w 1
head:	      dc.b 0,0
finim:	      dc.b 0,0,0,4,0,8,0,12,0,3,0,7,0,1,0,15,0,1,0
	      dc.b 1,0,1,0,1,0,128,0,84,0,42,0,0
fini:	      dc.b "THE END",0,0
userstack:    ds.l 1

pre:	      dc.b 27,"E",$a,$a
      dc.b "*************************************",$d,$a
      dc.b "* Alternate-Help to save the screen *",$d,$a
      dc.b "*					*",$d,$a
      dc.b "*	      Coded by GILLUS		*",$d,$a
      dc.b "*					*",$d,$a
      dc.b "*		 100% 68000		*",$d,$a
      dc.b "*					*",$d,$a
      dc.b "*					*",$d,$a
      dc.b "*	  PRESS A KEY - 02/09/1989	*",$d,$a
      dc.b "*************************************",$d,$a
      
      dc.b 0,0

END
       



		     

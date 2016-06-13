*************************************************************
**             Compacteur de digit a 20% de -              **
**               par METAL68 from M.D.K                    **
*************************************************************

	move.l	#debgit,a0
	move.l  #debgit,a2
	move.l	#fingit,a1
comp2	move.b	4(a0),d1
	moveq	#3,d2
comp3	move.b  (a0)+,d0
	and.b	#$FC,d0
	lsr.b	#2,d0
	and.b   #$0F,ccr		clear flag X
	asl.b	#1,d1
	roxl.b	#1,d0
	asl.b	#1,d1
	roxl.b  #1,d0
	move.b	d0,(a2)+
	dbra	d2,comp3
	addq.l  #1,a0
	cmpa.l  a0,a1
	bge	comp2
	

	LEA	nom,A0
	sub.l   #debgit,a2
	lea     debgit,a1
	

*-----------------------------------------------------       
*      a0: adresse du nom
*      a1: adresse du buffer
*      a2: longueur
*-----------------------------------------------------

Load  move.w  #0,-(sp)
      move.l  a0,-(sp)
      move.w  #$3C,-(sp)
      trap    #1
      lea     8(sp),sp
      
read  move.w  d0,d1
      move.l  a1,-(sp)
      move.l  a2,-(sp)
      move.w  d1,-(sp)
      move.w  #$40,-(sp)
      trap    #1
      lea     12(sp),sp

close move.w  d1,-(sp)
      move.w  #$3E,-(sp)
      trap    #1
      addq.l  #4,sp
      
      clr.w -(sp)
      trap #1
nom dc.b 'a:explose.mdk',0
 even
debgit	incbin  a:explose.spl
fingit
	
	
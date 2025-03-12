**********************************************
*                                            *
* Gen_cos :                                  *
* ---------                                  *
*                                            *
* This rout, gen the Cosinus and Sinus table *
*                                            *
*                                            *
*                   << Azrael (C.V.) >>      *
*                                            *
*                                            *
* Little note, the table are 4096 multiplied *
*                                            *
*                                            *
* HTTP://CEREBRAL-VORTEX.NET                 *
*                                            *
*                                            *
**********************************************


Gen_cos:	movem.l 	d0-d7/a0-a6,-(a7)

	moveq	#12,d5

	lea	Cosinus(pc),a0
 	lea 	Sinus(pc),a1

 	move.w 	#2896,90(a0)	* Cos 45*4096
 	move.w 	#2896,90(a1)	* Sin 45

 	moveq 	#44,d0
Boucle0:
 	move.w 	d0,d1
 	add.w	d1,d1
	move.w	2(a0,d1.w),d2
 	asl.l	d5,d2
	move.w	2(a1,d1.w),d3
 	muls 	#71,d3	* Sin 1
 	add.l 	d2,d3
	asr.l	d5,d3
	move.w	d3,0(a0,d1.w)
	move.w	2(a1,d1.w),d2
	asl.l	d5,d2
	move.w	2(a0,d1.w),d3
 	muls 	#71,d3	* Sin 1
 	sub.l 	d3,d2
	asr.l	d5,d2
	move.w	d2,0(a1,d1.w)
 	dbra 	d0,Boucle0
 
 	moveq 	#44,d0
Boucle1:
 	move.w 	d0,d2
 	add.w   	d2,d2
 	moveq 	#90,d1
 	sub.w 	d0,d1
 	add.w	d1,d1
 	move.w 	0(a0,d2.w),0(a1,d1.w)
 	move.w 	0(a1,d2.w),0(a0,d1.w)
 	dbra	d0,Boucle1 

 	moveq 	#89,d0
 	move.w 	#180,d1
Boucle2: 
 	move.w 	d1,d2
 	add.w	d2,d2
 	move.w 	#360,d3
 	sub.w 	d2,d3
 	move.w 	0(a1,d3.w),0(a1,d2.w)
 	move.w 	0(a0,d3.w),d4
 	neg.w 	d4
 	move.w 	d4,(a0,d2.w)
 	subq.w 	#1,d1
 	dbra	d0,Boucle2

 	move.w 	#178,d0
 	move.w 	#181,d1
Boucle3:
 	move.w 	d1,d2
 	add.w	d2,d2
 	move.w 	d2,d3
 	sub.w 	#360,d3
 	move.w 	0(a1,d3.w),d4
 	neg.w 	d4
 	move.w 	d4,(a1,d2.w)
 	move.w 	#720,d3
 	sub.w 	d2,d3
 	move.w 	0(a0,d3.w),0(a0,d2.w)
 	addq.w 	#1,d1
 	dbra	d0,Boucle3

 	movem.l 	(a7)+,d0-d7/a0-a6
 	rts

Cosinus:	ds.w	360
Sinus:	ds.w	360

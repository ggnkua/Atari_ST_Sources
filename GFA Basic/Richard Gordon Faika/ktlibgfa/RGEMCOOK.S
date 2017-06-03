*******************************************
* RGEM-Cookiejar-Routine
* (c) 1997-2002 RGF Software
* Teil der KTLIB fÅr "KEYTAB" von Martin ElsÑsser
*

rgem_cookie:		move.l	4(sp),d0
					movem.l	d1-d7/a0-a6,-(sp)
					move.l	d0,d3
					clr.l	-(sp)
					move 	#32,-(sp)		; super
					trap	#1
					move.l	d0,2(sp)
					movea.l	1440,a0
					beq.s	no_cjar
	c_loop:			move.l	(a0)+,d1
					move.l	(a0)+,d0
					cmp.l	d3,d1
					beq.s	c_end
					tst.l	d1
					bne.s	c_loop
	no_cjar:		moveq	#0,d0
	c_end:			move.l	d0,d3
					trap	#1				; und zurÅck in user
					addq.l	#6,a7
					move.l	d3,d0
					movem.l	(sp)+,d1-d7/a0-a6
					rts

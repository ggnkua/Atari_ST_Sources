****************************************************************
*                                                              *
* Here come the PC1 unpacking rout, this routine was written   *
* for gfa owners and lovers. If you want another rout for      *
* gfa (Sprite, etc...) please contact me on :                  *
*                                                              *
* ATARI-FORUM.COM        or on our website :                   *
*                                                              *
* CEREBRAL-VORTEX.NET                                          *
*                                                              *
* This routine only unpack low res picture, coz i wanted to    *
* do a little and faster routine than other, yes i know doing  *
* 3 resolution rout will only speed down a little bit the rout *
* but i think, this routine will be mainly used for demo or    *
* games. If you want med or high rout, you know what you do !! *
*                                                              *
*                                      GT Turbo (C.V.)         *
*                                                              *
* Fast greetings to : Tobe, Zorro2, Floopy (Mjj team)          *
*                     Orion, Napo (Yaronet crew)               *
*                     Atomus (No extra !)                      *
*                     All Atari forumers i know                *
*                     All Atari Legend team                    *
*                     Firecooler (Enjoy Gfa coding !)          *
*                                                              *
*                                                              *
****************************************************************

	opt	a+,d-

Depack_pc1:
*	movem.l	d0-d7/a0-a6,-(a7)

	move.w	#200-1,d4	* 200 lines
	moveq	#6,d7	*
	moveq	#40,d6	* 40 bytes per plane

All_lines:
	move.l	a1,a2	* Destination
	moveq	#3,d1	* 4 Bit planes

Debut_line:
	move.l	a2,a3
	moveq	#0,d3
	moveq	#1,d5

Recup_code:
	moveq	#0,d0
	move.b	(a0)+,d0
	bmi.s	Repete_code

Copy:
	move.b	(a0)+,(a2)
	addq.b	#1,d3
	add.w	d5,a2
	eor.w	d7,d5

	dbra	d0,Copy

	bra.s	End_line

Repete_code:
	neg.b	d0

	move.b	(a0)+,d2

Recopy_code:
	move.b	d2,(a2)
	addq.b	#1,d3

	add.w	d5,a2
	eor.w	d7,d5

	dbra	d0,Recopy_code

End_line:
	cmp.b	d6,d3
	bne.s	Recup_code	
	move.l	a3,a2

	addq.w	#2,a2	* Next plane

	dbra	d1,Debut_line

	lea	160(a1),a1	* Next line
	dbra	d4,All_lines

*	movem.l	(a7)+,d0-d7/a0-a6
	rts

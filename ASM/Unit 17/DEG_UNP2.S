* Degas Elite unpack source.
* By Niclas Pennskog (Jason/Unit #17)
* 02-02-91
*
* An example of the source-code...
*

	pea	picture+2		* Set palette
	move.w	#6,-(a7)
	trap	#14
	addq.l	#6,a7

	move.w	#2,-(a7)		* Get vram
	trap	#14
	addq.l	#2,a7
	move.l	d0,a1		* a1=vram
	lea	picture,a0	* a0=picture adr.

	bsr	unpack_degas

	move.w	#7,-(a7)		* Wait for key
	trap	#1
	addq.l	#2,a7

	clr.w	-(a7)		* Exit
	trap	#1

*** The unpack-rout:

unpack_degas
	add.l	#2+32,a0	* a0=picture
	lea	32000(a1),a2
unp_loop	move.b	(a0)+,d0		* a1=vram
	bpl.s	positive
not_127	cmp.b	#-128,d0
	beq.s	unp_loop
	neg	d0
	ext	d0
	move.b	(a0)+,d1
p_loop0	move.b	d1,(a1)+
	dbra	d0,p_loop0
	bra.s	check_end
positive	ext	d0
p_loop1	move.b	(a0)+,(a1)+
	dbra	d0,p_loop1
check_end	cmp.l	a2,a1
	bls.s	unp_loop
	rts
***

picture	incbin	e:\pictures\*.pc3	* Include your picture here...

	end

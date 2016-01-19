* Relocate Executable Program Routine
* Prepare a3 with address of program.
* Then jsr relocate

relocate	movem.l	d0-a6,-(sp)	save registers
		movea.l	a3,a0		a0->Start of Program Header
		move.l	2(a0),d0	d0->length of Program
		add.l	6(a0),d0	add length of data segment
		add.l	14(a0),d0	add length of Symbol Table
		adda.l	#28,a0		a0 now points to start of 
*					relocate table
		movea.l	a0,a1		backup in a1
		movea.l	a1,a2		backup in a2
		add.l	#28,a3		Offset
		move.l	a3,d1		This is the address the 
*					program will be relocated 
* 					to
		add.l	d0,a1		get address of relocate table
		move.l	(a1)+,d0	get first relocation longword
		add.l	d0,a2		set offset
		add.l	d1,(a2)		relocate
		clr.l	d0
do_relocate	move.b	(a1)+,d0	Get next relocate byte
		beq.s	end_relocate	If zero then relocated all
		cmp.b	#1,d0		if 1 it is a 254 jump
		beq.s	jump_relocate
		add.l	d0,a2		If not get next address
		add.l	d1,(a2)		relocate
		bra.s	do_relocate	do next bit....
jump_relocate	add.l	#254,a2		jump 254 bytes
		bra.s	do_relocate	do next bit....
end_relocate	movem.l	(sp)+,d0-a6	Restore Registers
		rts	
		
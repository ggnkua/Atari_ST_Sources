* Relocate Source. To use load a1 with the Start of the Program
* to be relocated and 'jsr relocate'

		jsr	relocate
		jmp	(program)

relocate:	move.l	a0,-(sp)		;x:program plus header
relocier_mich:	lea	(program)+28,a1		;A1 -> PRG-Start
		move.l	a1,d0
		lea	-28(a1),a3
		move.l	2(a3),a0		;Length of Text Segment
		add.l	6(a3),a0		;Length of Data Segment 
		add.l	14(a3),a0		;Length of Symbol Table
		add.l	a1,a0			;A0 ->Relocate Table
		move.l	(a0)+,d1
		beq.s	reloc_fertig
reloc_next:	add.l	d1,a1
		add.l	d0,(a1)
get_next_dist:	moveq	#0,d1
		move.b	(a0)+,d1
		beq.s	reloc_fertig
		cmp.b	#1,d1
		bne.s	reloc_next
		lea	$fe(a1),a1
		bra.s	get_next_dist
reloc_fertig:	move.l	(sp)+,a0
		rts
program		incbin	a:\qindex22.prg
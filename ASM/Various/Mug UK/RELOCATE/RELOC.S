* program relocator
* entry	in supervisor mode with irqs off

* NOTE: this routine MUST be position independent

reloc_buf equ $200			safe place for shift code

en_reloc
	move.l	#_reloc,d2		d2=relocation offset
	lea	env_ST(pc),a0		program address
	lea	-$1C(a0),a2		header address
	cmp.w	#-1,$1A(a2)		if no reloc. info then run
	beq	.shift
	move.l	a0,a1			a1=pointer to relocation info
	add.l	2(a2),a1		= TEXT	+ sizeof(TEXT)
	add.l	6(a2),a1			+ sizeof(DATA)
	add.l	14(a2),a1			+ sizeof(SYMBOLS)
	clr.l	d1
	move.l	(a1)+,d0		get long index to first addr
	beq	.shift			if 0 then run
.loop	add.l	d2,0(a0,d0.l)		add reloc. offset to address
.byte	move.b	(a1)+,d1		get byte
	beq	.shift			if 0 then end of list so run
	cmp.b	#1,d1			if 1 then add 254 to index
	bne	.small
	add.l	#254,d0
	bra	.byte
.small	add.l	d1,d0			else add byte 2..253 to index
	bra	.loop			and relocate address
.shift	lea	env_ST(pc),a0		source
	move.l	#_reloc,a1		dest
	move.l	2(a2),d0		size=text+data
	add.l	6(a2),d0
	lea	(a1,d0.l),a3		start of bss= dest+size
	move.l	10(a2),d1		size of bss
	lea	.copy(pc),a4
	lea	reloc_buf,a5
	move.w	#.copy_end-.copy-1,d7
.s2	move.b	(a4)+,(a5)+
	dbra	d7,.s2
	lea	_reloc+(env_3-env_ST),a4	return address
	jmp	reloc_buf			copy down

.copy	move.b	(a0)+,(a1)+		copy text,data
	subq.l	#1,d0
	bne.s	.copy
	tst.w	d1
	beq.s	.copy3
.copy2	clr.b	(a3)+			wipe bss
	subq.l	#1,d1
	bne.s	.copy2
.copy3	jmp	(a4)			return to program
.copy_end

end_of_file=$80000+8352

	lea	end_of_file,a0
	lea	$c0000,a1
	move.l	a0,READC
	move.l	a1,LOWWR
	bsr	Unkill
	illegal
debug:	dc.l	0		;comptient nb octets d‚compress‚s

;************************** DECRUNCHER ********************
; decruncher v1.1
READC:		DC.L 0		; ADR fin FICHIER COMPACTE
LOWWR:		DC.L 0		; ADR. DE DECOMPACTAGE

UnKill:
	MOVEM.L D0-D7/A0-A6,-(SP)
	MOVE.L READC,a0
	MOVE.L LOWWR,a1		; get end of write (rem. backward write)
	move.l -(a0),a2		; get offset from start of write
	add.l a1,a2		; and compute write address
	move.l	a2,debug
	move.l -(a0),d5		; get checksum
	move.l -(a0),d0		; init bit buffer
	eor.l d0,d5		; don't forget to update checksum

notfinished:
	lsr.l #1,d0
	bne.S notempty1
	bsr getnextlwd
notempty1:
	bcs.S bigone		; we found a big (jmp/dupl)

	moveq #8,d1	; assume it is a 2 bytes duplicate
	moveq #1,d3	; so prepare to load 8 bits and copy 2 bytes
	lsr.l #1,d0
	bne.S notempty2
	bsr getnextlwd
notempty2:
	bcs.S dodupl	; it is really a small duplicate

	moveq #3,d1	; shit, it's a jump
	clr.w d4	; but a small so clear offset and load 3 bits

dojmp:		; do a jump.d4 holds the offset to add to the length
		; d1 holds the length of the length
	bsr rdd1bits	; read number of bytes to skip
	move.w d2,d3	; save it into d3 (d3=#skip-1)
	add.w d4,d3	; add offset depending on jmp type

getd3chr:

	moveq #7,d1	; get a char (8 bits !!!)
get8bits:
	lsr.l #1,d0
	bne.S notempty3
	bsr getnextlwd
notempty3:
	roxl.l #1,d2
	dbf d1,get8bits	; ok there is now a byte in d2

	move.b d2,-(a2)
	dbf d3,getd3chr	; do it for D3 bytes
	bra nextcmd

bigjmp:
	moveq #8,d1	; we have a big skip so get an 8 bit offset 
	moveq #8,d4	; and init the offset
		; (REM:as we are shure a big jmp is always 10 or
		;  more chars why storing a number bigger than 9 ?
		;  so a JMP of 10 is stored 0,11 : 1 ... okay ?)
	bra dojmp

bigone:
	moveq #2,d1	; get 2 more bits to know what type this big one is
	bsr rdd1bits
	cmp.b #2,d2	; if 3 or 4 duplicate
	blt.S midjumps	; go handle it
	cmp.b #3,d2	; if bigjmp
	beq.S bigjmp	; go handle it too


	moveq #8,d1	; we have here a big duplicate (5 or more)
	bsr rdd1bits	; so read his length (a one byte length)
	move.w d2,d3	; and save it in D3
	move.w #12,d1	; prepare to get a 12 bits offset
	bra dodupl	; and get it

midjumps:
	move.w #9,d1	; 3 or 4 duplicate so compute offset's length
	add.w d2,d1
	addq #2,d2
	move.w d2,d3	; and add 2 to the number of byte to copy

dodupl:
	bsr rdd1bits	; reads d1 bits of offset then copy what is there
		; at the current write address
		; copy D3 bytes
copyd3bytes:
	subq #1,a2

	move.b (a2,d2.w),(a2)

	dbf d3,copyd3bytes

nextcmd:
	cmp.l a2,a1
	blt notfinished
;	tst.l d5
;	bne.S damage
	MOVEM.L (SP)+,D0-D7/A0-A6
	RTS

damage:
	move.w #$ffffffff,d0
damloop:
;move.w d0,$dff180
	subi.l #1,d0
	bne.S damloop
	ILLEGAL

getnextlwd:
	move.l -(a0),d0
	eor.l d0,d5
	move.w #$10,ccr
	roxr.l #1,d0
	rts

rdd1bits:	; reads d1 bits from d0 (or memory) to d2
	subq.w #1,d1
	clr.w d2

getbits:
	lsr.l #1,d0
	bne.S notempty
	move.l -(a0),d0
	eor.l d0,d5
	move.w #$10,ccr
	roxr.l #1,d0

notempty:
	roxl.l #1,d2
	dbf d1,getbits
return:	rts


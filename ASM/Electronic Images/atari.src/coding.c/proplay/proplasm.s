; Protracker Replay 3.0
; By Martin Griffiths
; Assembler module.

		IMPORT fix_tree

		EXPORT fix_resource,get_treeaddr
		EXPORT PP_Decrunch,start_music,stop_music,pause_music
		EXPORT forward_music,rewind_music
	
; Set a resource file in memory
; a0-> resource file.

rsh_vrsn	equ 0	; resource version no.
rsh_object	equ 2	; offset to object[] 
rsh_tedinfo	equ 4	; offset to tedinfo[]
rsh_iconblk	equ 6	; offset to iconblk[]
rsh_bitblk	equ 8	; offset to bitblk[] 
rsh_frstr	equ 10	; offset to free string index 
rsh_string	equ 12	; offset to first string 
rsh_imdata	equ 14	; offset to image data 
rsh_frimg	equ 16	; offset to free image index 
rsh_trindex	equ 18	; offset to object tree index
rsh_nobs	equ 20	; number of objects 
rsh_ntree	equ 22	; number of trees 
rsh_nted	equ 24	; number of tedinfos 
rsh_nib		equ 26	; number of icon blocks 
rsh_nbb		equ 28	; number of bitblk blocks
rsh_nstring	equ 30  ; number of free strings 
rsh_nimages	equ 32	; number of free images 
rsh_rssize	equ 34 	; total bytes in resource 

fix_resource:
			movem.l d0-d7/a0-a6,-(sp)
			move.l	a0,d4
			movea.l	a0,a1
			adda.w	$12(a0),a1
			move.w	$16(a0),d7
			beq.s	l12C9C4
			subq.w	#1,d7
l12C9BE:	add.l	d4,(a1)+
			dbf	d7,l12C9BE
l12C9C4:	movea.l	a0,a1
			adda.w	$A(a0),a1
			move.w	$1E(a0),d7
			beq.s	l12C9D8
			subq.w	#1,d7
l12C9D2:	add.l	d4,(a1)+
			dbf	d7,l12C9D2
l12C9D8:	move.w	$16(a0),d7
			beq	l12CA9C
			subq.w	#1,d7
			movea.l	a0,a1
			adda.w	$12(a0),a1
l12C9E8:	moveq	#0,d3
			movea.l	(a1)+,a2
			moveq	#0,d6
			moveq	#0,d5
			movea.l	a2,a3
l12C9F2:	tst.w	d6
			beq.s	l12CA00
			tst.w	0(a3)
			bge.s	l12CA00
			bra	l12CA7A
l12CA00:	tst.w	2(a3)
			blt.s	l12CA24
			cmp.w	4(a3),d6
			beq.s	l12CA24
			move.w	d5,d6
			move.w	2(a3),d5
			move.w	d5,d0
			mulu 	#24,d0
			lea 	(a2,d0.l),a3
			bra.s	l12CA00
l12CA24:	move.w	6(a3),d0
			subi.w	#$14,d0
			andi.w	#$F,d0
			lea	l12CA9E(pc),a4
			move.b	0(a4,d0.w),d1
			beq.s	l12CA5A
			add.l	d4,$C(a3)
			cmp.b	#1,d1
			beq.s	l12CA5A
			movea.l	$C(a3),a4
			add.l	d4,(a4)
			cmp.b	#2,d1	
			beq.s	l12CA5A
			add.l	d4,4(a4)
			add.l	d4,8(a4)
l12CA5A:	cmp.w	d5,d3
			bgt.s	l12CA60
			move.w	d5,d3
l12CA60:	move.w	d5,d6
			move.w	0(a3),d5
			move.w	d5,d0
			mulu 	#24,d0
			lea	(a2,d0.l),a3
			bra	l12C9F2
l12CA7A:	movem.l	d0-d7/a0-a6,-(a7)
			move.l a2,a0	; 
			move.w d3,d0	; no. of objects
;			bsr fix_tree
			movem.l	(a7)+,d0-d7/a0-a6
			dbf	d7,l12C9E8
l12CA9C:	movem.l (sp)+,d0-d7/a0-a6
			rts

l12CA9E:	DC.B 0,3,3,2,0,0,1,0
			DC.B 1,3,3,3,1,0,0,0

; Get the address of a tree (like RSRC_GADDR)
; A0-> resource data
; d0-> tree index address to get.

get_treeaddr:
			ext.l d0
			lsl.l #2,d0
			moveq #0,d1
			move.w rsh_trindex(a0),d1
			add.l d0,d1
			move.l (a0,d1.l),a0
			rts
		
;
;
;

forward_music:
		movem.l d0-d7/a0-a6,-(sp)
		movem.l (sp)+,d0-d7/a0-a6
		rts
rewind_music:
		movem.l d0-d7/a0-a6,-(sp)
		movem.l (sp)+,d0-d7/a0-a6
		rts
start_music:
		movem.l d0-d7/a0-a6,-(sp)
		movem.l (sp)+,d0-d7/a0-a6
		rts
stop_music:
		movem.l d0-d7/a0-a6,-(sp)
		movem.l (sp)+,d0-d7/a0-a6
		rts
pause_music:
		movem.l d0-d7/a0-a6,-(sp)
		movem.l (sp)+,d0-d7/a0-a6
		rts

; Power Packer Decrunch routine. 
; a0 -> Power packed file
; a1 -> Destination for unpack
; d0 -> Packed length	

PP_Decrunch:
	movem.l d0-d7/a0-a6,-(sp)
	lea 4(a0),a5			; -> efficiency longword
	move.l a1,a3			; a3 to destination
	add.l d0,a0				; a0-> lword after packed file	

	moveq #3,d6
	moveq #7,d7
	moveq #1,d5
	move.l a3,a2			; remember start of file
	move.l -(a0),d1			; get file length and empty bits
	tst.b d1
	beq.s NoEmptyBits
	bsr.s ReadBit			; this will always get the next long (D5 = 1)
	subq.b #1,d1
	lsr.l d1,d5			; get rid of empty bits
NoEmptyBits:
	lsr.l #8,d1
	add.l d1,a3			; a3 = endfile
LoopCheckCrunch:
	bsr.s ReadBit			; check if crunch or normal
	bcs.s CrunchedBytes
NormalBytes:
	moveq #0,d2
Read2BitsRow:
	moveq #1,d0
	bsr.s ReadD1
	add.w d1,d2
	cmp.w d6,d1
	beq.s Read2BitsRow
ReadNormalByte:
	moveq #7,d0
	bsr.s ReadD1
	move.b d1,-(a3)
	dbf d2,ReadNormalByte
	cmp.l a3,a2
	bcs.s CrunchedBytes
	movem.l (sp)+,d0-d7/a0-a6
	rts
ReadBit:
	lsr.l #1,d5			; this will also set X if d5 becomes zero
	beq.s GetNextLong
	rts
GetNextLong:
	move.l -(a0),d5
	roxr.l #1,d5			; X-bit set by lsr above
	rts
ReadD1sub:
	subq.w #1,d0
ReadD1:
	moveq #0,d1
ReadBits:
	lsr.l #1,d5			; this will also set X if d5 becomes zero
	beq.s GetNext
RotX:
	roxl.l #1,d1
	dbf d0,ReadBits
	rts
GetNext:
	move.l -(a0),d5
	roxr.l #1,d5			; X-bit set by lsr above
	bra.s RotX
CrunchedBytes:
	moveq #1,d0
	bsr.s ReadD1			; read code
	moveq #0,d0
	move.b 0(a5,d1.w),d0		; get number of bits of offset
	move.w d1,d2			; d2 = code = length-2
	cmp.w d6,d2			; if d2 = 3 check offset bit and read length
	bne.s ReadOffset
	bsr.s ReadBit			; read offset bit (long/short)
	bcs.s LongBlockOffset
	moveq #7,d0
LongBlockOffset:
	bsr.s ReadD1sub
	move.w d1,d3			; d3 = offset
Read3BitsRow:
	moveq #2,d0
	bsr.s ReadD1
	add.w d1,d2			; d2 = length-1
	cmp.w d7,d1			; cmp with #7
	beq.s Read3BitsRow
	bra.s DecrunchBlock
ReadOffset:
	bsr.s ReadD1sub			; read offset
	move.w d1,d3			; d3 = offset
DecrunchBlock:
	addq.w #1,d2
DecrunchBlockLoop:
	move.b 0(a3,d3.w),-(a3)
	dbf d2,DecrunchBlockLoop
EndOfLoop:
	cmp.l a3,a2
	bcs.s LoopCheckCrunch
	movem.l (sp)+,d0-d7/a0-a6
	rts
	
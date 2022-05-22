; 16 SPC to data and palette file convert

letsgo	clr.l -(sp)
	move #$20,-(sp)
	trap #1
	addq.l #6,sp

.doit	lea gfxout,a0
	lea palout,a1
	moveq #8,d7
.lp	move.w d7,-(sp)
.load1	lea infilename1(pc),a4
	lea spc(pc),a5
	move.l #1000000,d7
	bsr Load_file
	movem.l d0-a6,-(sp)
	bsr handle_spc		; call jose' crap depack rout
	movem.l (sp)+,d0-a6

	lea spc+(20*160),a2
	move.w #(180*160)/4-1,d0
.cp1	move.l (a2)+,(a0)+
 	dbf d0,.cp1
	lea pal+(20*96),a2
	move.w #((179*96)+32)/4-1,d0
.cp2	move.l (a2)+,(a1)+
 	dbf d0,.cp2
	
	
	lea infilename2(pc),a4
	lea spc(pc),a5
	move.l #1000000,d7
	bsr Load_file
	movem.l d0-a6,-(sp)
	bsr handle_spc		; call jose' crap depack rout
	movem.l (sp)+,d0-a6

	lea spc+(1*160),a2
	move.w #(76*160)/4-1,d0
.cp3	move.l (a2)+,(a0)+
 	dbf d0,.cp3

	lea -32(a1),a1
	lea pal,a2
	move.w #((77*96)+32)/4-1,d0
.cp4	move.l (a2)+,(a1)+
 	dbf d0,.cp4

	move.w (sp)+,d7
	addq.b #1,infilename1+3
	addq.b #1,infilename2+3
	subq.w #1,d7
	bne .lp

	lea outfilename1(pc),a4
	lea gfxout,a5
	move.l #256*160*8,d7
	bsr Save_file

	lea outfilename2(pc),a4
	lea palout,a5
	move.l #((256*96)+32)*8,d7
	bsr Save_file
	clr -(sp)
	trap #1

infilename1	DC.B "B:\1_1.SPC",0
		EVEN
infilename2	DC.B "B:\1_2.SPC",0
		EVEN
outfilename1
		DC.B "D:\RAY.GFX",0
		EVEN
outfilename2
		DC.B "D:\RAY.PAL",0
		EVEN


; Load a file of D7 bytes, Filename at A4 into address A5.

Load_file	MOVEM.L D0-A6,-(SP)
		MOVE #2,-(SP)
		MOVE.L A4,-(SP)
		MOVE #$3D,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		MOVE D0,D4
.read		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$3F,-(SP)
		TRAP #1
		LEA 12(SP),SP
.close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		MOVEM.L (SP)+,D0-A6
		RTS


; Save a file of D7 bytes, Filename at A4 at address A5.

Save_file	MOVEM.L D0-A6,-(SP)
		MOVE #0,-(SP)
		PEA (a4)
		MOVE #$3C,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		MOVE D0,D4
.write		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$40,-(SP)
		TRAP #1
		LEA 12(SP),SP
.close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1
		ADDQ.L #4,SP
		MOVEM.L (SP)+,D0-A6
		RTS

; Depack SPC

handle_spc:
	lea	spc(pc),a0
	move.l	a0,a1
	adda.l	#54000,a1
	move.l	a1,a2
	bsr	unpackspc

	move.l	a2,a0
	moveq	#4-1,d1
	moveq	#0,d2
dospc:	lea	spc(pc),a1
	lea	160(a1),a1
	adda.w	d2,a1
	move.w	#199-1,d0	; Number of lines -1.
	bsr	copy1plane
	addq.w	#2,d2
	dbra	d1,dospc
	lea	-6(a1),a1
	move.w	#1194-1,d0
copypln:move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,copypln
dont_moveit:
	rts


;
; SPC unpacker.
;
unpackspc:
	movem.l	(a0)+,d0-d2
	movem.l	d0-d2,spc_flag

itsspc:	move.l	a0,spc_addr

	move.w	#31840,d0

spc_next:
	moveq	#0,d1
	move.b	(a0)+,d1
	bpl.s	spc_norep

	ext.w	d1
	neg.w	d1
	addq.w	#1,d1	; (usually 2) -1 for DBRA
	move.w	d1,d2
	addq.w	#1,d2
	move.b	(a0)+,d3
spc_rep:move.b	d3,(a1)+
	dbra	d1,spc_rep
	sub.w	d2,d0
	ble.s	do_palette
	bra.s	spc_next

spc_norep:
	move.w	d1,d2
norep:	move.b	(a0)+,(a1)+
	dbra	d1,norep
	addq.w	#1,d2
	sub.w	d2,d0
	bgt.s	spc_next


do_palette:

	move.l	spc_addr(pc),a0
	add.l	spc_datalen(pc),a0

      MOVE.W  #$254,D7
      CLR.W   D0
L0043:MOVE.W  #$D,D6
      MOVE.W  (A0)+,D1
      LSR.W   #1,D1 
      MOVE.W  D0,(A1)+
L0044:LSR.W   #1,D1 
      BCC.S   L0045 
      MOVE.W  (A0)+,(A1)+ 
      DBF     D6,L0044
      BRA.S   L0046 
L0045:MOVE.W  D0,(A1)+
      DBF     D6,L0044
L0046:MOVE.W  D0,(A1)+
      DBF     D7,L0043
enduspc:
	rts	


spc_addr:
	ds.l	1
spc_flag:
	ds.w	1
spc_reserved:
	ds.w	1
spc_datalen:
	ds.l	1	
spc_collen:
	ds.l	1

	
copy1plane:
scoff	set	0
	rept	20
	move.w	(a0)+,scoff(a1)
scoff	set	scoff+8
	endr
	lea	160(a1),a1
	dbra	d0,copy1plane
	rts

	section bss

spc:		ds.b	54000
pal		EQU spc+32000
boo:		ds.b	60000

gfxout	ds.b 1000000
palout	ds.b 1000000

SPOOL	Lea	.Super(pc),a6
	Move.l	a6,$20.w
.Super	Move.w	#$2100,sr
	Lea	Stack_Area(pc),a7	; Setup the stack
	Jsr	Check_For_Pal_Ntsc
	Jsr	VideoInit
	Pea	Load_The_Raiden_File(pc)
	Move.l	(sp)+,$bc.w		; Trap 15 vector-Load in files
	Pea	Relocate_Raiden(pc)
	Move.l	(sp)+,$b0.w		; Trap 12 vector-Relocate executable file
	Jsr	Hi_Score_Check_Eeprom
	Bsr	Double_Prioritys
	Bsr	Adjustments_To_Flames
	Bsr	Make_Alien_Offset_Check
	Jmp	Start			; Stasrt my prog

Make_Alien_Offset_Check
	Lea	Alien_Offset_Check_Table,a0
	Lea	Enemy_Sprite_Offsets,a1
	Move.w	#1520-1,d0
.Loop	Moveq	#0,d1
	Or.w	(a1)+,d1
	Or.w	(a1)+,d1
	Sne	(a0)+
	Dbra	d0,.loop
	Rts

Adjustments_To_Flames
	Tst.w	.Init
	Bne.s	.Set
	St	.Init
	Lea	Flame_Offset_Table,a0
	MOve.w	#(Flame_Offset_Tablee-Flame_Offset_Table)/4-1,d0
.Loop	Tst.l	(a0)+
	Beq.s	.Noon
	Move.l	-4(a0),a1
	Move.w	(a1)+,d3
.loop1	Subq.w	#8,(a1)+
	Subq.w	#8,(a1)+
	Subq.w	#4,d3
	Bne.s	.Loop1	
.Noon	Dbra	d0,.Loop
.Set	Rts

.Init	Ds.w	1

Double_Prioritys
	Tst.w	.Init
	Bne.s	.Set
	St	.Init
	Move.w	#Enemy_Priorityse-Enemy_Prioritys,d0
	Lea	Enemy_Prioritys,a0
.Loop	Move.b	(a0),d1
	Add.b	d1,d1
	Move.b	d1,(A0)+
	Subq.w	#1,d0
	Bne.s	.Loop
.Set	Rts

.Init	Ds.w	1


Load_The_Raiden_File
	Jsr	File_LOAD
	Rte
Relocate_Raiden
	Include	D:\Raiden\68k\Relo.s

	Ds.b	1024*2
Stack_Area
 
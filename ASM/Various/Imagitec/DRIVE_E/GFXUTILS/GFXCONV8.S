; This prog takes the SPT file and covnerts it to
; The required format, only for the game RAIDEN

; Save format
; 500..
; .L Y offset on screen (needs to be multiplied within program)
; .L Offset into sprite data (needs to be absolute within program)
; .W Height of sprite
; .W Plane data
; .W Width in pixels
; .2B  Reserved !
; ..
; SPRITE DATA WITH MASKS

; Prints \1=Text
Print	Macro
	Move.l	#\1,-(sp)
	Move.w	#$9,-(sp)
	Trap	#1
	Addq.l	#6,sp
	Endm

Kill_Inp Macro
	Lea	TBuffer+1,a0
	Moveq	#0,d0
	Move.b	(a0)+,d0
	Clr.b	(a0,d0)
	Endm

	Move.l	a7,a5
	Move.l	#Ustack,a7
	Move.l	4(a5),a5
	Move.l	$c(a5),d0
	Move.l	$14(a5),d0
	Add.l	$1c(a5),d0
	Add.l	#$100,d0
	MOve.l	d0,-(sp)
	MOVE.L	A5,-(SP)
	MOVE.W	#0,-(SP)
	Move.w	#$4a,-(sp)
	Trap	#1
	Add.l	#12,sp
	Tst.l	d0

Start	Move.l	a7,Stacksave
	Print	Text1
	Bsr	Input
	Kill_Inp
	Lea	Tbuffer+2,a0
	Lea	Filebuffer,a1
	Bsr	Read_file
	Bsr	Get_Num_Sprites
	Print	Text2
	Print	Text3
	Bsr	Input
	Bsr	Convert_Bin
	Bsr	Make_Falcon_Sprites
	Bsr	Insert_Col
	Bsr	Save_Raw
	Bra	Exit

Insert_col
	Movem.l	d0-a6,-(sp)
	Lea	Color_buffer,a0
	Lea	Process_Buffer,a1
	Move.w	#399,d0
.Loop	Move.w	(a0)+,10(a1)
	Lea	16(a1),a1
	Dbra	d0,.Loop
	Movem.l	(sp)+,d0-a6
	Rts
Save_Raw
	Print	Text5
	Bsr	Input
	Kill_Inp
	Lea	Tbuffer+2,a0
	Move.l	#Process_buffer,d0
	Move.l	Lastaddr,d1
	Sub.l	d0,d1
	Move.l	d1,d0
	Lea	Process_Buffer,a1
	Bsr	Save_File
	Rts

Make_Falcon_Sprites
	Move.w	Filebuffer,d7
	Subq.w	#1,d7
	Lea	Filebuffer+1026,a0		; Start of table
	Lea	Process_Buffer,a5		Structure buffer
	Move.w	#7999,d0
.Loop0	St	(a5,d0)
	Dbra	d0,.Loop0
	Lea	8000(a5),a6			; Gfx list
.Loop	Move.l	(a0)+,a1
	Add.l	#Filebuffer,a1
	Movem.w	(a0)+,d0-d1
	Bsr	Copy_Sp_Buffer
	Bsr	Compress_Height
	Bsr	Convert_Bpx
	Bsr	Make_Max
	Lea	16(a5),a5
	Dbra	d7,.Loop
	Move.l	a6,Lastaddr
	Rts

Make_Max
	Movem.l	d0-a5,-(sp)
	Move.l	Mask_Save,a4
	Lea	Falcon_Buffer,a0
	Move.w	Bin_Val,d0
	Moveq	#7,d1
	Moveq	#0,d2
.Loop	Lsr.b	#1,d0
	Bcc.s	.Dec
	Addq.w	#1,d2
.Dec	Dbra	d1,.Loop
	Subq.w	#1,d2
	Bmi.s	.None
	Move.w	8(a5),d0
	Move.w	12(a5),d1
	Lsr.w	#4,d1
	Mulu	d1,d0
	Subq.w	#1,d0			Height*(Width/16)-1
	Bmi	.None

.Loop0	Move.w	d2,d3			Plane count
	Move.w	#16,-(sp)		16 pixels !
	Moveq	#0,d4			Clear work reg !
.Mloop	Addq.b	#1,(a4)+		1 to mask!
	Addx.w	d4,d4			If mask pixel set, Insert into word!
	Subq.w	#1,(sp)
	Bne.s	.Mloop			For 16 pixles
	Not.w	d4			Invert mask !
	Addq.l	#2,sp			Normal Stack
	Move.w	d4,(a6)+		Save mask !
.Loop1	Move.w	(a0)+,(a6)+
	Dbra	d3,.Loop1		Copy number of planes !
	Dbra	d0,.Loop0

.None	Movem.l	(sp)+,d0-a5
	Rts


Convert_Bpx
	Movem.l	d0-a6,-(sp)
	Lea	Falcon_Buffer,a1
	Mulu	d1,d0
	Subq.w	#1,d0
.Loop	Sf	(a1,d0)
	Dbra	d0,.Loop
	Move.l	Line_Save,a0
	Move.w	8(a5),d0		Height !
	Move.w	#$8000,d7
	Subq.w	#1,d0			Height !
	Bmi.s	.Nodata
.Loop0	Move.w	12(a5),d1		Width into d1 !
	Subq.w	#1,d1
.Loop1	Move.b	(a0)+,d2		Byte into d2
	Bsr.s	.Qconv
	Ror.w	#1,d7
	Bcc.s	.Nx
	Add.l	d4,a1
	Add.l	d4,a1
.Nx	Dbra	d1,.Loop1
	Dbra	d0,.Loop0
.Nodata	Movem.l	(sp)+,d0-a6
	Rts
	
.Qconv	Movem.l	a1,-(sp)
	Move.w	Bin_Val,d3
	Moveq	#7,d6
	Moveq	#0,d4
.QLoop	Lsr.b	#1,d3
	Bcc.s	.Dec
	Addq.w	#1,d4
	Btst	#0,d2
	Beq.s	.Dec2
	Or.w	d7,(a1)
.Dec2	Addq.l	#2,a1
.Dec	Lsr.b	#1,d2
	Dbra	d6,.QLoop
	Move.l	(sp)+,a1
	Rts
	
Compress_Height
	Movem.l	d0-a6,-(sp)
	Lea 	Mask,a4
	Lea	Copy_Sp_buff,a2		; Buffer
	Moveq	#0,d6			; Y offset
	Moveq	#0,d7			; Size
	Sf	d5			; Clear bit hit flag
	Subq.w	#1,d1
	Exg	d0,d1
.Loop0	Move.w	2(sp),d1		; 32 across
	Subq.w	#1,d1
	Move.l	a2,a3
	Move.l	a4,a0
.Loop1	Tst.b	(a2)+			; Check for a pixel
	Tst.b	(a4)+
	Bne.s	.Hit			; Hit ?, yes !
	Dbra	d1,.Loop1		; Check all 32 pixels
	Tst.b	d5			; Here if no gfx
	Bne.s	.Dec			; Dont add to offset if already hit on a prev. line
;	Bne.s	.Cont			; ONLY IF LOGOS!	
	Addq.w	#1,d6			; Add to offset if no bits hit !
	Bra.s	.Dec
.Hit	Tst.b	d5
	Bne.s	.Cont
	Move.l	a3,Line_Save
	Move.l	a0,Mask_Save
.Cont	St	d5			; Set hit line flag
	Add.l	d1,a2			; add remainder to pointer
	Add.l	d1,a4			; add remainder to pointer
	Addq.w	#1,d7			; Add to height 	
.Dec	Dbra	d0,.Loop0		; all lines
	Move.l	d6,(a5)			; Save y offset
	Sub.l	#Process_Buffer,a6
	Move.l	a6,4(a5)		; Save graphic offset
	Move.w	d7,8(a5)		; Save height
	Move.w	Bin_Val,10(a5)
	Movem.l	(sp)+,d0-a6
	Move.w	d0,12(a5)		; Save width
	Rts

Mask_Save	Ds.l	1

Copy_Sp_Buffer
	Movem.l	d0-a6,-(sp)
	Lea	Color_buffer,a6
.Col	Tst.w	(a6)+
	Bne.s	.Col
	Lea	Copy_Sp_buff,a2
	Lea	Mask,a4
	Move.w	d0,d6
	Mulu	d1,d6
	Subq.w	#1,d6
.Clrl	Clr.b	(a2,d6)
	Dbra	d6,.Clrl
	Subq.w	#1,d0
	Subq.w	#1,d1
	Move.w	Bin_Val,d6
	Moveq	#0,d4
.Loop	Move.w	d0,d2
.Loop2	Move.b	(a1)+,d5
	Sne	(a4)+
	Or.b	d5,d4
	And.b	d6,d5
	Move.b	d5,(a2)+
	Dbra	d2,.Loop2
	Dbra	d1,.Loop
.OOk	Clr.w	d4
	Move.w	d4,-(a6)
	Movem.l	(sp)+,d0-a6
	Rts

Convert_Bin
	Moveq	#0,d0
	Lea	Tbuffer+2,a0
	Moveq	#7,d7
.Loop	Sub.b	#"1",(a0)+
	Addx.b	d0,d0
	Dbra	d7,.Loop
	Not.b	d0
	Move.w	d0,Bin_Val
	Rts	
	

Get_Num_Sprites
	Moveq	#0,d0
	Move.w	Filebuffer,d0
	Lea	Tnums,a0
	Divu	#100,d0
	Move.b	d0,(a0)+
	Clr.w	d0
	Swap	d0
	Divu	#10,d0
	Move.b	d0,(a0)+
	Swap	d0
	Move.b	d0,(a0)+
	Lea	Tnums,a0
	Add.b	#"0",(a0)+
	Add.b	#"0",(a0)+
	Add.b	#"0",(a0)+
	Rts
	

Fileerror
	Move.l	Stacksave,a7
	Bra	Exit

Input	Movem.l	d0/a0,-(sp)
	Lea	Tbuffer,a0
	Moveq	#81,d0
.Loop	Sf	(a0,d0)
	Dbra	d0,.Loop
	Move.b	#80,(a0)
	Pea	(a0)
	Move.w	#$a,-(sp)
	Trap	#1
	Addq.l	#6,sp
	Movem.l	(sp)+,d0/a0
	Rts

; a0=Filename
; a1=Destination

Read_File
	Movem.l	a0-a1,-(sp)
	Clr.w	-(sp)
	Pea	(a0)
	Move.w	#$3d,-(sp)
	Trap	#1
	Addq.l	#8,sp
	Movem.l	(sp)+,a0-a1
	Tst.l	d0
	Bmi	Fileerror
	Move.w	d0,Handle
	Pea	(a1)
	Move.l	#$C00000,-(sp)
	Move.w	Handle,-(sp)
	Move.w	#$3f,-(sp)
	Trap	#1	
	Lea	12(sp),sp
	Tst.l	d0
	Bmi	Fileerror
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)
	Trap	#1
	Addq.l	#4,sp
	Bmi	Fileerror
	Rts

;a0=Filename
;a1=Data start
;d0=Length

Save_File
	Movem.l	d0/a0-a1,-(sp)
	Clr.w	-(sp)
	Pea	(a0)
	Move.w	#$3c,-(sp)
	Trap	#1
	Addq.l	#8,sp		
	Tst.l	d0			Create file 
	Bmi	Fileerror	
	Move.w	d0,Handle
	Movem.l	(sp)+,d0/a0-a1

	Pea	(a1)			Address
	Move.l	d0,-(sp)		Length
	Move.w	Handle,-(sp)	
	Move.w	#$40,-(sp)
	Trap	#1
	Lea	12(sp),sp
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)		Close !
	Trap	#1
	Addq.l	#4,sp
	Rts

Exit	move.l	#0,-(sp)
	trap	#1
	Rts

Copy_Sp_Buff	Ds.b	320*200
Mask	Ds.b	320*200

Falcon_Buffer
	Ds.b	320*200
	
Handle	Ds.l	1
Stacksave Ds.l	1
Tbuffer	Ds.b	82
Bin_Val	Ds.w	1
YOffset	Ds.l	1
Ysize	Ds.l	1		
Line_Save Ds.l	1
LastAddr Ds.l	1

Text1	Dc.b	27,"Y",32+07,32+0," Freddys VGA converter ! ",$0a
	Dc.b	27,"Y",32+08,32+0," Give me an .SPT file to read ! ",$0a,$0a
	Dc.b	0
	Even	

Text2	Dc.b	27,"E"," That file was cool ",$0a
	Dc.b	27,"Y",32+02,32+0," This file contains "
Tnums	Dc.b	"000"
	Dc.b	" defined sprites",$0a
	Dc.b	0
Text3	Dc.b	27,"Y",32+05,32+0," Give me a binary string, on which planes you want to turn off & on ",0
Text5	Dc.b	27,"Y",32+15,32+10," Give me a save name (.RAW)  ",0
	Dc.b	27,"Y",32+17,32+10
	Even

	Ds.l	200
Ustack

Color_Buffer
	Ds.w	500
 
Filebuffer
	Ds.l	256*400
	
Process_Buffer
	Ds.b	16*500
	Ds.b	(70000*4)/4
Process_Buffere
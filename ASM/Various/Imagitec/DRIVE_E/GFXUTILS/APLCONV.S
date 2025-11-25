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

Start	Move.l	a7,Stacksave
	Print	Text1
	Bsr	Input
	Kill_Inp
	Lea	Tbuffer,a0
	Lea	Tbuffer2,a1
	Moveq	#81,d0
.Loop0	Move.b	(a0)+,(a1)+
	Dbra	d0,.Loop0
	
	Lea	Tbuffer+2,a0
	Lea	Apl_Buffer,a1
	Bsr	Read_File
	MOVE.W	$31a(a1),d6
	Ror.w	#8,d6
	Addq.w	#1,d6
	Move.w	d6,Num_Sprites
	Lea	Apl_Buffer+24,a1
	Move.l	a1,-(sp)
	Print	Text2
	Bsr	Input
	Moveq	#0,d0
	Move.b	Tbuffer+2,d0		Planes ind 0
	Sub.b	#"0",d0
	Move.w	d0,Num_Planes
	Moveq	#1,d1
	Lsl.w	d0,d1
	Move.w	d1,Num_Cols
	Move.l	(sp),a1
	Move.w	Num_Cols,d0
	Lea	Pallete,a2
.Loop	Move.b	(a1)+,(a2)+
	Move.b	(a1)+,(a2)+
	Clr.b	(a2)+
	Move.b	(a1)+,(a2)+
	Move.l	-4(a2),d1
	Lsl.l	#2,d1
	Move.l	d1,-4(a2)
	Subq.w	#1,d0
	Bne.s	.Loop
	Print	Text3
	Move.l	(sp)+,a0
	Lea	$400(a0),a0
	Lea	-24(a0),a0
	Bsr	Conv_Bx
	Bsr.s	Saveit
	Bra	Exit

Saveit	
	Move.l	a1,-(sp)
	Bsr	Copytb
	Move.l	#".PAL",d0
	Bsr	Ins
	Moveq	#0,d0
	Move.w	Num_Cols,d0
	Lsl.w	#2,d0
	Lea	Tbuffer+2,a0
	Lea	Pallete,a1
	Bsr	Save_file
	Move.l	(sp)+,a1
	Bsr	Copytb
	Move.l	#".BLK",d0
	Bsr	Ins
	Move.l	a1,d0
	Lea	Tbuffer+2,a0
	Lea	Process_Buffer,a1
	Sub.l	#Process_Buffer,d0
	Bsr	Save_file
	Rts

Ins	Lea	Tbuffer+2,a6
.N	Cmp.b	#".",(a6)+
	Bne.s	.N
	Addq.l	#3,a6
	Clr.b	(a6)
	Rept	4
	Move.b	d0,-(a6)
	Lsr.l	#8,d0
	Endr
	Rts

Copytb
	Lea	Tbuffer2,a5
	Lea	Tbuffer,a6	
	Moveq	#81,d0
.Loop	Move.b	(a5)+,(a6)+
	Dbra	d0,.Loop
	Rts

Conv_Bx
	Move.w	#$8000,d7
	Lea	Process_Buffer,a1
.Loop	Moveq	#15,d0
.Loop0	Moveq	#15,d1
.Loop1	Move.w	Num_Planes,d6
	Subq.w	#1,d6
	Move.b	(a0)+,d2
.Loop2	Lsr.b	#1,d2
	Bcc.s	.Nx
	Or.w	d7,(a1)
.Nx	Addq.l	#2,a1	
	Dbra	d6,.Loop2
	Move.w	Num_Planes,d6
	Neg.w	d6
	Lea	(a1,d6),a1
	Lea	(a1,d6),a1
	Neg.w	d6
	Ror.w	#1,d7
	Dbra	d1,.Loop1
	Lea	(a1,d6),a1	
	Lea	(a1,d6),a1	
	Dbra	d0,.Loop0
	Subq.w	#1,Num_Sprites
	Bne	.Loop
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
	Move.l	#$20000,-(sp)
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

Handle	Ds.l	1
Stacksave Ds.l	1
Tbuffer	Ds.b	82
Tbuffer2	Ds.b	82
Num_Sprites	Ds.w	1
Num_Cols	Ds.w	1
Num_Planes	Ds.w	1
Num_Blocks	Ds.w	1
Pallete		Ds.l	256


Text1	Dc.b	27,"Y",32+0,32+0,"WELCOME TO FREDDYS APL CONVERTER !",$A
	DC.B	27,"Y",32+1,32+0,"GIVE ME A FILE NAME TO READ : ",$A
	DC.B 	0
	
TEXT2	DC.B	27,"Y",32+5,32+0,"FILE READING PHAZE O.K !  THE FILES WILL BE SAVED "
	DC.B	"AS A:*.BLK AND A:*.PAL"
	DC.B	27,"Y",32+7,32+0,"HOW MANY PLANES DO YOU WANT TO CONVERT TO ? ",$A
	DC.B	0

text3	Dc.b	27,"Y",32+9,32+0," WRITING FILES, FUCK OFF !",0
	Even
	
Apl_Buffer
	Ds.b	320*200*3
Process_Buffer
	Ds.b	320*200*3
Process_Bufferend 	
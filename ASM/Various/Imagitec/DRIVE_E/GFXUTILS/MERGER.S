; PROGRAM TO LINK 2 RAW FILES TOGETHER !

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
	Lea	Tbuffer+2,a0
	Lea	Filebuffer1,a1
	Bsr	Read_file
	Move.l	d0,Filelen1
	Print	Text3
	Bsr	Input
	Kill_Inp
	Lea	Tbuffer+2,a0
	Lea	Filebuffer2,a1
	Bsr	Read_file
	Move.l	d0,Filelen2
	Bsr	Merge_em
	Bsr	Save_It
	Bra	Exit


Merge_Em
	Lea	Filebuffer1,a0
	Move.l	#8000,d1
.Loop	Tst.b	(a0)			; Search for a -ive
	Bmi.s	.Ok
	Lea	16(a0),a0
	Sub.l	#16,d1
	Bra.s	.Loop
.Ok	Lea	Filebuffer2,a1
	Lsr.l	#4,d1
.Loop2	Move.l	(a1)+,(a0)+
	Move.l	(a1)+,(a0)
	Move.l	FileLen1,d2
	Sub.l	#8000,d2
	Add.l	d2,(a0)+
	Move.l	(a1)+,(a0)+
	Move.l	(a1)+,(a0)+
	Subq.l	#1,d1
	Bne.s	.Loop2
        
	Lea	Filebuffer1,a0
	Add.l	Filelen1,a0		; End of file
	Lea	Filebuffer2,a1
	Add.l	#8000,a1		; Into sprite raws
	Move.l	Filelen2,d0
	Sub.l	#8000,d0		; Copy less 8000 bytes
			
.Loop3	Move.b	(a1)+,(a0)+
	Subq.l	#1,d0
	Bne.s	.Loop3
	Move.l	a0,Lastaddr
	Rts

Save_It
	Print	Text2
	Bsr	Input
	Kill_Inp
	Move.l	#Filebuffer1,d0
	Move.l	Lastaddr,d1
	Sub.l	d0,d1
	Move.l	d1,d0
	Lea	Tbuffer+2,a0
	Lea	Filebuffer1,a1
	Bsr	Save_File
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
	Move.l	d0,-(sp)
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)
	Trap	#1
	Addq.l	#4,sp
	Bmi	Fileerror
	Move.l	(sp)+,d0
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

Copy_Sp_Buff
	Ds.b	32*32

Falcon_Buffer
	Ds.b	1152
	
Handle	Ds.l	1
Stacksave Ds.l	1
Tbuffer	Ds.b	82
Bin_Val	Ds.w	1
YOffset	Ds.l	1
Ysize	Ds.l	1		
Line_Save Ds.l	1
LastAddr Ds.l	1
Filelen1	Ds.l	1	
Filelen2	Ds.l	1	

Text1	Dc.b	27,"Y",32+07,32+0," Freddys RAW file merger ! ",$0a
	Dc.b	27,"Y",32+08,32+0," Give me 2 .Raw files to read ! ",$0a,$0a
	Dc.b	0
Text2	Dc.b	27,"Y",32+10,32+0," Give me an out file !",$0a,0
	Even
Text3	Dc.b	27,"Y",32+10,32+0," Another one tah! ",$0a,0
	Even

Filebuffer1
	Ds.l	(65536*6)/4
Filebuffer2
	Ds.l	(65536*6)/4

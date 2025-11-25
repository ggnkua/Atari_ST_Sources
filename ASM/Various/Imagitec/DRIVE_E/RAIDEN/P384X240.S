	Include	E:\Includes\SystRegs.Inc

Start	Clr.l	-(sp)
	Move.w	#$20,-(sp)
	Trap	#1			
	Move.l	$70.w,-(sp)
	Move.l	#New_Vbl,$70.w
	Bsr	Setup_Screen	
	Lea	This_Pic(pc),a0
	Lea	Decode_Screen,a1
	Lea	Pallete,a2
	Bsr	DecodeVGA
	Lea	Decode_Screen,a0
	Lea	Convert_Screen,a1
	Bsr	Convert_VGA
	Bsr	Wait_KEY
	Bsr	Restore_Screen	
	Move.l	(sp)+,$70.w
	Clr.w	-(sp)
	Trap	#1


New_Vbl	Rte

Restore_Screen	
	Move.w	Old_Mode(pc),d0
	Bsr	Setmode
	Rts
Setup_Screen
	Move.w	#-1,-(sp)
	Move.l	#Convert_Screen,-(sp)
	Move.l	(sp),-(sp)
	Move.w	#5,-(sp)
	Trap	#14
	Lea	12(sp),sp
	Moveq	#$63,d0
	Bsr	Setmode
	Pea	Convert_Screen
	Move.b	1(sp),Bp_Hi
	Move.b	2(sp),Bp_Md
	Move.b	3(sp),Bp_Lo+1
	Addq.l	#4,sp
	Rts

Setmode	Or.b	#$20,d0
	Move.w	d0,-(sp)
	Move.w	#88,-(sp)
	Trap	#14
	Addq.l	#4,sp
	Move.w	d0,Old_Mode
	rts

Old_Mode	Ds.w	1

Wait_KEY
	Move.w	#8,-(sp)
	Trap	#1
	Addq.l	#2,sp
	Tst.b	d0
	Beq.s	Wait_Key
	Rts

Convert_VGA
	Move.w	#239,d4
.Xloop	Move.w	#383,d0
	Move.w	#$8000,d7
.Loop	Move.b	(a0)+,d1
	Moveq	#7,d6				
.Loop2	Lsr.b	#1,d1
	Bcc.s	.Nx
	Or.w	d7,(a1)
.Nx	Addq.l	#2,a1
	Dbra	d6,.Loop2
	Lea	-16(a1),a1
	Ror.w	#1,d7
	Bcc.s	.Nx2
	Lea	16(a1),a1
.Nx2	Dbra	d0,.loop
	Dbra	d4,.Xloop
	Rts	
	
DecodeVGA
	Pea	(a0)
.SearchCMAP
 	Cmp.l	#"CMAP",(a0)		
 	Beq.s	.Cmapfound
 	Addq.l	#2,a0
 	Bra.s	.SearchCMAP
.Cmapfound
	Addq.l	#4,a0
	Move.l	(a0)+,d0		
	Sub.l	#3*32,d0		
	Lea	Pal256,a3
.Cloop	Move.b	(a0)+,(a2)+	
	Move.b	(a0)+,(a2)+
	Clr.b	(a2)+
	Move.b	(a0)+,(a2)+
	Move.l	-4(a2),(a3)+
	Subq.l	#3,d0
	Bne.s	.Cloop
	Move.l	#0,Pal256
	Move.l	(sp)+,a0
.Searchbody
	Cmp.l	#"BODY",(a0)
	Beq.s	.Bodyfound		
	Addq.l	#2,a0
	Bra.s	.Searchbody

.Bodyfound
	Addq.l	#4,a0
	Move.l	(a0)+,d0		
.ByterunLoop
	Move.b	(a0)+,d1		
	Bmi.s	.Run
	Moveq	#0,d3			
	Move.b	d1,d3			
	Addq.b	#2,d3			
.Copyloop
	Move.b	(a0)+,(a1)+		
	Subq.b	#1,d1
	Bge.s	.Copyloop		
	Sub.l	d3,d0			
	Bgt.s	.ByterunLoop	
	Bra.s	.Byterunexit	
.Run	Move.b	(a0)+,d2		
.Rloop	Move.b	d2,(a1)+		
	Addq.b	#1,d1			
	Ble.s	.RLoop
	Subq.l	#2,d0
	Bgt.s	.ByterunLoop
.Byterunexit
	Rts


This_Pic
	Incbin	F:\Temp\Credits.Lbm
Decode_Screen
	Ds.l	(384*240)/4

	Cnop	0,4
S
Pallete	Ds.l	256
Convert_Screen
	Ds.l	(384*240)/4
E



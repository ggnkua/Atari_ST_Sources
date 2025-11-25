

Start
	Move.l	#Text1,-(sp)
	Move.w	#$9,-(sp)
	Trap	#1
	Addq.l	#6,sp
	
	Bsr	Clearbuff
		
	Pea	Buffer
	Move.w	#$a,-(sp)
	Trap	#1
	Addq.l	#6,sp
	
	Lea	Buffer+1,a0
	Moveq	#0,d0
	Move.b	(a0)+,d0
	Clr.b	(a0,d0)

	Clr.w	-(sp)
	Pea	(a0)
	Move.w	#$3d,-(sp)
	Trap	#1
	Addq.l	#8,sp
	Tst.l	d0
	Bmi	.Exit
	Move.w	d0,Handle
	
	Pea	FileBuffer
	Move.l	#$20000,-(sp)
	Move.w	Handle,-(sp)
	Move.w	#$3f,-(sp)
	Trap	#1
	Lea	12(sp),sp
	Tst.l	d0
	Bmi	.Exit
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)
	Trap	#1
	Addq.l	#4,sp
	Bmi	.Exit	
	
	Move.l	#Text2,-(sp)
	Move.w	#$9,-(sp)
	Trap	#1
	Addq.l	#6,sp
	
	Bsr	Clearbuff
		
	Pea	Buffer
	Move.w	#$a,-(sp)
	Trap	#1
	Addq.l	#6,sp

	Lea	Buffer+1,a0
	Moveq	#0,d0
	Move.b	(a0)+,d0
	Clr.b	(a0,d0)
	
	Bsr	.Getnum
	Move.w	d0,Source
	Addq.l	#1,a0
	Bsr	.Getnum
	Move.w	d0,Dest
	Addq.l	#1,a0
	
	Move.l	a0,Fname
	Clr.w	-(sp)
	Pea	(a0)
	Move.w	#$3c,-(sp)
	Trap	#1
	Addq.l	#8,sp
	Tst.l	d0
	Bmi	.Exit
	Move.w	d0,Handle
	
	Lea	Filebuffer+2,a0
.Bk	Cmp.l	#"CMAP",(a0)
	Beq.s	.Found
	Addq.l	#2,a0
	Bra.s	.Bk
.Found	Addq.l	#8,a0
	Move.w	Source,d0
	Move.w	Dest,d1
	Mulu	#3,d0
	Lea	(a0,d0),a0
	Lea	Mybuff,a1
	Move.w	Source,d0
	Sub.w	d0,d1
.Floop	Move.b	(a0)+,(a1)+
	Move.b	(a0)+,(a1)+
	Clr.b	(a1)+
	Move.b	(a0)+,(a1)+
	Dbra	d1,.FLoop
	Lea	Mybuff,a0
	Move.w	Source,d0
	Move.w	Dest,d1
	Sub.w	d0,d1
	Addq.w	#1,d1
	Mulu	#4,d1
	Pea	(a0)
	Move.l	d1,-(sp)
	Move.w	Handle,-(sp)
	Move.w	#$40,-(sp)
	Trap	#1
	Lea	12(sp),sp
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)
	Trap	#1
	Addq.l	#4,sp


.Exit	move.l	#0,-(sp)
	trap	#1
	Rts

.Getnum
	Moveq	#0,d0
	Moveq	#0,d1
	Moveq	#0,d2
	Move.b	(a0)+,d0
	Sub.b	#"0",d0
	Move.b	(a0)+,d1
	Sub.b	#"0",d1
	Move.b	(a0)+,d2
	Sub.b	#"0",d2
	Mulu	#100,d0
	Mulu	#10,d1
	Add.w	d2,d1
	Add.w	d1,d0
	Rts
	
Clearbuff
	Lea	Buffer+1,a0
	Moveq	#80,d7
.Loop	Clr.b	(a0,d7)
	Dbra	d7,.Loop
	Rts	
	
Source	Ds.w	1	
Dest	Ds.w	1	
Handle	Ds.w	1
Fname	Ds.l	1
Mybuff	Ds.l	256
	
Buffer	Dc.b	80,0
	Ds.b	80
	Even
	
Text1	Dc.b	27,"Y",32+07,32+0," Freddys pallete ripper ! ",$0a

	Dc.b	27,"Y",32+08,32+0," Enter start of pallete ",$0a
	Dc.b	27,"Y",32+09,32+0," Followed by the end pallete number (Inclusive) ",$0a
	dc.b	27,"Y",32+10,32+0," In otherwords 0-255 for the pallete to be ripped.",$0a
	Dc.b	27,"Y",32+11,32+0," You need to rip from a CUT VGA file",$0a
	Dc.b	27,"Y",32+13,32+0," File to read (.LBM)  ",$0a
	Dc.b	0
	Even	
Text2	
	Dc.b	27,"Y",32+17,32+0," Enter start (XXX) and end (XXX)",$0a
	Dc.b	27,"Y",32+19,32+0
	Dc.b	0
	Even
	
Filebuffer
	Ds.b	65536*2
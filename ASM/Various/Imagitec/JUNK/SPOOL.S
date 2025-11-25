; Raiden loader spool
; Freddy and the dreamers

; Clear this when making disks !
;Install
	
SPOOL	Clr.l	-(sp)
	Move.w	#$20,-(sp)
	Trap	#1			Give me supervisor
	Lea	Stack_Area(pc),a7	Setup the stack
	Move.w	#-1,-(sp)
	Move.w	#88,-(sp)
	Trap	#14
	Addq.l	#4,sp
	Btst	#5,d0
	Sne	$7c.w
	Bsr	Setup_Traps
	Ifd	Install
	Bsr	Set_Decrunch	
	Jmp	Start(pc)
	Else
;	Lea	Intro_Name(pc),a0	Load in the presentation
;	Lea	Load_Area(pc),a1	At this address
;	Bsr	Set_Decrunch	
;	Trap	#15
;	Trap	#12
;	Jsr	(a1)
Load_Loop
	Lea	Stack_Area(pc),a7	Setup the stack
	Lea	Intro_Name(pc),a0	Load in the presentation
	Lea	Load_Area(pc),a1	At this address
	Bsr	Set_Decrunch	
	Trap	#15
	Trap	#12
	Jsr	(a1)
	Bsr.s	Fade_SysPal
	Move.l	$70.w,-(sp)
	Pea	Rteer(pc)
	Move.l	(sp)+,$70.w
	Lea	Game_Name(pc),a0	Load in intro
	Lea	Load_Area(pc),a1	At this address
	Bsr	Set_Decrunch	
	Trap	#15
	Trap	#12
	MOve.l	(sp)+,$70.w
	Jsr	(a1)
	Bra	Load_Loop
	Endc

Clr_Decrunch	
	Pea	(a6)
	Lea	Flag_For_Decrunch(pc),a6
	Sf	(a6)
	Move.l	(sp)+,a6
	Rts	
Set_Decrunch	
	Pea	(a6)
	Lea	Flag_For_Decrunch(pc),a6
	St	(a6)
	Move.l	(sp)+,a6
	Rts	

Fade_SysPal
	Movem.l	d0-a6,-(sp)
	Sf	Flag_For_Pallete_Copy
	Lea	$70.w,a6
	Move.l	(a6),-(sp)
	Pea	SYSPAL_Vbl(pc)
	Move.l	(sp)+,(a6)
	Sf	d7
.Back1	Tst.b	d7
	Beq.s	.Back1
	Lea	$ff9800.l,a0
	Lea	Dest_sysPal(pc),a1
	Move.w	#256-1,d0
.Cloop	Move.l	(a0)+,(a1)+
	Dbra	d0,.Cloop
	St	Flag_For_Pallete_Copy
	Sf	d7
.Back	Tst.b	d7
	Beq.s	.Back
	Lea	Dest_sysPal(pc),a0
	Move.w	#255,d0
	Move.w	#255,d5
	Moveq	#0,d1
.Loop	Move.b	(a0),d1
	Mulu	d5,d1
	Lsr.w	#8,d1
	Move.b	d1,(a0)+
	Move.b	(a0),d1
	Mulu	d5,d1
	Lsr.w	#8,d1
	Move.b	d1,(a0)+	
	Clr.b	(a0)+
	Move.b	(a0),d1
	Mulu	d5,d1
	Lsr.w	#8,d1
	Move.b	d1,(a0)+
	Dbra	d0,.Loop
	Sf	d7
	Tst.b	d2
	Bne.s	.Back
.Wt1	Tst.b	d7
	Bne.s	.Wt1
	Move.l	(sp)+,(a6)
	Movem.l	(sp)+,d0-a6
	Rts

Syspal_Vbl	
	Tst.b	Flag_For_Pallete_Copy
	Beq.s	.No
	Move.w	#256,-(sp)
	Lea	Dest_sysPal(pc),a2
	Lea	$ff9800.l,a3
	Sf	d2
.Loop	Move.l	(a2)+,(a3)+
	Sne	d3
	Or.b	d3,d2
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
.No	St	d7
	Rte

Load_The_Raiden_File
	Movem.l	d0-a6,-(sp)
	Clr.w	-(sp)			; Only read
	Pea	(a0)			; File name on stack !
	Move.w	#$3d,-(sp)		; Function
	Trap	#1			; Load it in
	Addq.l	#8,sp			; Re-align stack
	Move.w	d0,d6			; Save handle
	Bmi	File_Error		; -ive then error ! 
	Move.l	36(sp),-(SP)
	Move.l	#$c00000,-(sp)		; Read loadsa bytes
	Move.w	d6,-(sp)		; File handle
	Move.w	#$3f,-(sp)		; Read
	Trap	#1
	Lea	12(sp),sp		; Align stack
	Move.l	d0,(sp)			; Ready to return d0-length
	Bmi	File_Error
	Move.w	d6,-(sp)		; Handle
	Move.w	#$3e,-(sp)		; Close file
	Trap	#1
	Addq.l	#4,sp
	Lea	Flag_For_Decrunch(pc),a0
	Tst.b	(a0)
	Beq.s	.No_Decrunch
	Move.l	36(sp),a0
	Trap	#11
.No_Decrunch
	Movem.l	(sp)+,d0-a6
	Rte

File_Error
	Not.l	$ff8200.l
	Bra.s	File_Error

Ice_Decrunch
	Pea	Back(pc)
	Include	C:\Pack_Ice\Ice_Dcru.s
Back	Rte

Relocate_Raiden
	Movem.l	d0-a6,-(sp)
	Move.l	a1,a4
	LEA	$1C(A4),A3
	move.l	a3,a6
	MOVEM.L	-$1A(A3),D0-D3
	LEA	0(A3,D0.L),A0
	ADDA.L	D1,A0
	ADDA.L	D3,A0
	MOVE.L	A6,D0
	MOVE.L	(A0)+,D1
	BEQ.S	exit
	ADDA.L	D1,A3
	MOVEQ	#0,D1
L562F2	ADD.L	D0,(A3)
L562F4	MOVE.B	(A0)+,D1
	BEQ.S	exit
	CMPI.B	#1,D1
	BNE.S	L56304
	ADDA.W	#$FE,A3
	BRA.S	L562F4
L56304	ADDA.L	D1,A3
	BRA.S	L562F2
exit	Movem.l	(sp)+,d0-a6
RTEER	Rte

Intro_Name
	Dc.b	"Intro.PRG",0
Game_Name
	Dc.b	"Main.PRG",0
	Even

Flag_For_Decrunch
	Ds.b	1
Flag_For_Pallete_Copy
	Ds.b	1

Dest_sysPal
	Ds.b	1500
Stack_Area
Load_Area
Setup_Traps
	Pea	Load_The_Raiden_File(pc)
	Move.l	(sp)+,$bc.w		Trap 15 vector
	Pea	Relocate_Raiden(pc)
	Move.l	(sp)+,$b0.w		Trap 12 vector
	Pea	Ice_Decrunch(pc)
	Move.l	(sp)+,$ac.w		Trap 11 Vector
	Rts
 
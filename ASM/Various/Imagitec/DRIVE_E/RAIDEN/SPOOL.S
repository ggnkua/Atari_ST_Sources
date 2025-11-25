; Raiden loader spool
; Freddy and the dreamers

; Clear this when making disks !
	Opt	d-
Install
SPOOL	Clr.l	-(sp)
	Move.w	#$20,-(sp)
	Trap	#1			; Give me supervisor
	Lea	Stack_Area(pc),a7	; Setup the stack
	Move.w	#-1,-(sp)
	Move.w	#88,-(sp)
	Trap	#14			; Get back current video configuartion	
	Addq.l	#4,sp
	Btst	#5,d0			; Are we running PAL or NTSC
	Sne	$7c.w			; Set if running on PAL system
	Bsr	Setup_Traps		; Setup USER trap vectors
	Ifd	Install
	Bsr	Set_Decrunch		; Set decrunch if not installed
	Jmp	Start(pc)		; Stasrt my prog
	Else
	Lea	Presents_Name(pc),a0	; Load in the presentation
	Lea	Load_Area(pc),a1	; At this address
	Bsr	Set_Decrunch		; Set to decrunch executable
	Trap	#15			; Load & relocate
	Trap	#12
	Jsr	(a1)			; Execute program
	Bsr.s	Fade_SysPal		; Load in and fade pallete
Load_Loop
	Pea	Bollox_Vbl(pc)
	Move.l	(sp)+,$70.w
	Lea	Intro_Name(pc),a0	; Load in intro
	Lea	Load_Area(pc),a1	; At this address
	Bsr	Set_Decrunch		; Set to decrunch executable
	Trap	#15
	Trap	#12			; Relocate file
	Bsr.s	Fade_SysPal		; Load in and fade pallete
	Jsr	Load_Area(pc)
	Lea	Game_Name(pc),a0	Load in the game
	Lea	Load_Area(pc),a1	
	Bsr	Set_Decrunch		; Set to decrunch executable
	Trap	#15
	Trap	#12
	Bsr.s	Fade_SysPal
	Bsr	Set_Decrunch
	Jsr	Load_Area(pc)
	Bra.s	Load_Loop	
	Endc

Clr_Decrunch	
	Sf	Flag_For_Decrunch
	Rts	
Set_Decrunch	
	St	Flag_For_Decrunch
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
	Move.w	#3,-(sp)
.Back3	Lea	Dest_sysPal(pc),a0
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
	Subq.w	#1,(sp)
	Bne.s	.Back3
	Addq.l	#2,sp
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
	Ble.s	File_Error
	Move.w	d6,-(sp)		; Handle
	Move.w	#$3e,-(sp)		; Close file
	Trap	#1
	Addq.l	#4,sp
	Tst.b	Flag_For_Decrunch
	Beq.s	.No_Decrunch
	Move.l	36(sp),a0
	Move.l	(sp),d0
	Trap	#11
	Move.l	d0,(sp)
.No_Decrunch
	Addq.l	#2,(sp)
	And.l	#-2,(sp)
	Movem.l	(sp)+,d0-a6
Bollox_Vbl
	Rte

File_Error
	Not.l	$ff8200.l
	Bra.s	File_Error

Ice_Decrunch
	cmpi.L	#'ICE!',(A0)
	Bne	Back
	Move.l	8(a0),-(sp)
	Pea	Return_Length(pc)
	Include	C:\Pack_Ice\Ice_Dcru.s
Return_Length
	Move.l	(sp)+,d0
Back	Rte

Relocate_Raiden
	Include	E:\Raiden\Relo.s

Presents_Name
	Dc.b	"Presents.PRG",0
Intro_Name
	Dc.b	"Intro.PRG",0
Game_Name
	Dc.b	"Game.PRG",0
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
	Move.l	(sp)+,$bc.w		; Trap 15 vector-Load in files
	Pea	Relocate_Raiden(pc)
	Move.l	(sp)+,$b0.w		; Trap 12 vector-Relocate executable file
	Pea	Ice_Decrunch(pc)
	Move.l	(sp)+,$ac.w		; Trap 11 Vector-Decrunch file
	Rts
 
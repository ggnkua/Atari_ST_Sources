; Interpolation (Curve approxinmation) program.
; Coded by FrEdDy!

; Wrap=1 if curve will wrap back to its start, otherwise 0.
; Mouse buttons to plot0      points
; Any key to draw curve
; Mouse buttons again to quit.

Wrap		Equ	0

Blitterstuff 	Equ $ff8a00
Halftone	Equ $000000
Src_Xinc	Equ $000020
Src_Yinc	Equ $000022
Src_Addr	Equ $000024
Endmask1	Equ $000028
Endmask2	Equ $00002a
Endmask3	Equ $00002c
Dst_Xinc	Equ $00002e
Dst_Yinc	Equ $000030
Dst_Addr	Equ $000032
X_Count		Equ $000036
Y_Count		Equ $000038
Hop		Equ $00003a
Op		Equ $00003b
Line_Num	Equ $00003c
Skew		Equ $00003d
Procswitch	Equ $ff8007
Pal256		Equ $ff9800
Scr_mod		Equ $ff820e
Scr_del		Equ $ff8264
Bp_Hi		Equ $ff8201
Bp_Md		Equ $ff8203
Bp_Lo		Equ $ff820d
Vd_Hi		Equ $ff8204
Vd_Md		Equ $ff8206
Vd_Lo		Equ $ff8208
	
Frame_Rate	Equ	1
Byteswide	Equ	320


**********************************************************
; Give machine back some memory

Free_Mem
	Move.l	a7,a5
;	Lea	Ustack,a7
	Move.l	4(a5),a5
	Move.l	$c(a5),a0
	Add.l	$14(a5),a0
	Add.l	$1c(a5),a0
	Lea	$100(a0),a0
	Move.l	a0,-(sp)
	Move.l	a5,-(sp)
	Clr.w	-(sp)
	Move.w	#$4a,-(sp)
	Trap	#1
	Lea	12(sp),sp

Start	Bsr	Init			; Initialize
	Move.l	#$0,Pal256
	Move.l	#$ffff00ff,Pal256+4
	Move.l	#$ff0000ff,Pal256+8
	Move.l	#$ff0000ff,Pal256+12
	Bsr	Swap_screens

Main1	Bsr	Wait_vbl
	Bsr	Display_Mouse
	Bsr	KeyCheck
	Bsr	Check_Butt
	Bsr	Check_For_Key
	Beq.s	Main1

	Ifeq	Wrap	
	Move.l	Points_p(a4),a1
	Move.l	a1,Last_Curve(a4)
	Lea	-4(a0),a0
	Move.l	(a0),(a1)+
	Move.l	(a0),(a1)+
	Move.l	(a0),(a1)+
	Move.l	(a0),(a1)+
	Else
	Lea	Curve_Points(pc),a0
	Move.l	Points_p(a4),a1
	Move.l	a1,Last_Curve(a4)
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Endc
	Move.l	Maddr(a4),a6
	Move.w	Msave(a4),d0
	Move.w	d0,(a6)
	
	Bsr	Vars
	Clr.b	Key_Pressed(a4)
	
Main	Move.l	Last_Curve(a4),d0
	Cmp.l	Points_P(a4),d0
	Beq.s	.Nx
	Bsr	Calc_Curve
	Bsr	CLast_Point
	Bsr	Draw_Between
.Nx	Tst.w	Mbuts
	Beq.s	Main
;	Bsr	Check_For_Key
	Beq.s	Main
	Bra	Out

***********************************************************
Check_Butt
	Tst.w	Mbutsp
	Beq.s	.Chk
	Subq.w	#1,Mbutsp
	Rts
.Chk	Tst.w	MButs
	Beq.s	.No
	Move.w	#20,Mbutsp
	Move.l	Points_P(a4),a0
	Move.l	Mxdelta(pc),(a0)+
	Move.l	a0,Points_p(a4)
	Movem.w	Mxdelta(pc),d0-d1
	Moveq	#$f,d2
	And.w	d0,d2
	Sub.w	d2,d0
	Eor.w	#$f,d2
	Moveq	#1,d3
	Lsl.w	d2,d3
	Mulu	#Byteswide,d1
	Add.l	d1,d0
	Add.l	Screenp+4(a4),d0
	Addq.l	#2,d0
	Move.l	d0,a6
	Or.w	d3,(a6)
.No	Clr.w	Mbuts
	Rts	

***********************************************************
Display_Mouse
	Movem.w	Mxdelta(pc),d0-d1
	Tst.w	d0
	Bge.s	.Ok
	Moveq	#0,d0
.Ok	Tst.w	d1
	Bge.s	.Ok1
	Moveq	#0,d1
.Ok1	Cmp.w	#320,d0
	Blt.s	.Ok2
	Move.w	#319,d0
.Ok2	Cmp.w	#200,d1
	Blt.s	.Ok3
	Move.w	#199,d1
.Ok3	Movem.w	d0-d1,Mxdelta
	
	Tst.l	Maddr(a4)
	Bmi.s	.Nx
	Move.l	Maddr(a4),a6
	Move.w	Msave(a4),(a6)
.Nx	Movem.w	Mxdelta(pc),d0-d1
	Moveq	#$f,d2
	And.w	d0,d2
	Sub.w	d2,d0
	Eor.w	#$f,d2
	Moveq	#$1,d3
	Lsl.w	d2,d3
	Mulu	#Byteswide,d1
	Add.l	d1,d0
	Add.l	Screenp+4(a4),d0
	Move.l	d0,a6
	Move.l	a6,Maddr(a4)
	Move.w	(a6),Msave(a4)
	Or.w	d3,(a6)
	Rts

***********************************************************
Clast_Point
	Addq.w	#1,Acc(a4)
	Cmp.w	#$100,Acc(a4)
	Bne.s	.Nx
	Clr.w	Acc(a4)
	Add.l	#4,Points_p(a4)
.Nx	Rts

***********************************************************
Plot	Movem.w	Dest_Curves(a4),d0-d1
	Moveq	#$f,d2
	And.w	d0,d2
	Sub.w	d2,d0
	Moveq	#$1,d3
	Eor.w	#$f,d2
	Lsl.w	d2,d3
	Mulu	#Byteswide,d1
	Add.l	d1,d0
	Add.l	Screenp+4(a4),d0
	Move.l	d0,a6
	Or.w	d3,(a6)
	Rts

***********************************************************
Check_For_Space
	Cmp.b	#" ",Key_Pressed(a4)
	Rts

***********************************************************
Draw_Between
	Tst.l	Prev_Curves(a4)
	Bmi.s	.Nx
	Movem.w	Prev_Curves(a4),d2-d3
	Movem.w	Dest_Curves(a4),d0-d1
	Move.l	Screenp+4(a4),a6
	Bsr	Draw_a_Line
.Nx	Move.l	Dest_Curves(a4),Prev_Curves(a4)
	Rts
	
***********************************************************
Draw_A_Line
 	Cmp.w	d1,d3
	Bge.s	.Ok
	Exg	d0,d2			; Draw all lines DOWN!
	Exg	d1,d3			; Draw all lines DOWN!
.Ok	Sub.w	d0,d2
	Sub.w	d1,d3			; Get delta X/Y!
	Addq.w	#1,d3			; Make sure no zero!
	Mulu	#Byteswide,d1		; Get line !
	Moveq	#$f,d4			; Mask for first pixel !
	And.w	d0,d4			; Get it !
	Sub.w	d4,d0			; Delete from source
	Add.w	d0,d1			; Add to Line
	Add.l	d1,a6			; Add to address !
	Move.w	.Or_T(pc,d4*2),d4
	Moveq	#0,d5			; Work register
	Moveq	#1,d0			; Compare/Shifter
	Moveq	#16,d6			; ADD!
	Move.l	#Byteswide,d1		; For line !
	Tst.w	d2
	Bmi	Left_L
	Bra.s	Right_L

.Or_T	Dc.w	$8000,$4000,$2000,$1000
	Dc.w	$800,$400,$200,$100
	Dc.w	$80,$40,$20,$10
	Dc.w	$8,$4,$2,$1

Right_L	Cmp.w	d0,d3
	Bne.s	.No_Horizontal
	Swap	d2			; Straight length !
	Subq.w	#1,d3			; For dbra
	Bra.s	.Loop1	
.No_Horizontal
	Moveq	#1,d7
	Swap	d7
	Divu	d3,d7			; Get remainder !
	Mulu	d7,d2
	Subq.w	#1,d3
.Loop1	Add.l	d2,d5			; Add into accumalator
	Swap	d5
	Tst.w	d5			; Test hi-word
	Beq.s	.No_Shift1		; 0, No Shift!
	Subq.w	#1,d5			; Else DBRA
	Not.w	d4
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	Lea	-16(a6),a6
	Not.w	d4
.Loop2	Or.w	d4,(a6)			; Or into !
	Ror.w	d0,d4			; Shift it right!
	Bcc.s	.Nx1			; No out !
	Add.l	d6,a6			; Next word right!
.Nx1	Dbra	d5,.Loop2
	Clr.w	d5			; Clear hi-word
	Swap	d5			; Swap again
	Add.l	d1,a6
	Dbra	d3,.Loop1
	Rts			
.No_Shift1
	Swap	d5
	Not.w	d4
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	Lea	-16(a6),a6
	Not.w	d4
	Or.w	d4,(a6)
	Add.l	d1,a6
	Dbra	d3,.Loop1
	Rts			

Left_L	Neg.w	d2
	Cmp.w	d0,d3
	Bne.s	.No_Horizontal
	Swap	d2			; Straight length !
	Subq.w	#1,d3			; For dbra
	Bra.s	.Loop1	
.No_Horizontal
	Moveq	#1,d7
	Swap	d7
	Divu	d3,d7			; Get remainder !
	Mulu	d7,d2
	Subq.w	#1,d3
.Loop1	Add.l	d2,d5			; Add into accumalator
	Swap	d5
	Tst.w	d5			; Test hi-word
	Beq.s	.No_Shift1		; 0, No Shift!
	Subq.w	#1,d5			; Else DBRA
	Not.w	d4
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	Lea	-16(a6),a6
	Not.w	d4
.Loop2	Or.w	d4,(a6)			; Or into !
	Rol.w	d0,d4			; Shift it right!
	Bcc.s	.Nx1			; No out !
	Sub.l	d6,a6			; Next word right!
.Nx1	Dbra	d5,.Loop2
	Clr.w	d5			; Clear hi-word
	Swap	d5			; Swap again
	Add.l	d1,a6
	Dbra	d3,.Loop1
	Rts			
.No_Shift1
	Swap	d5
	Not.w	d4
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	And.w	d4,(a6)+
	Lea	-16(a6),a6
	Not.w	d4
	Or.w	d4,(a6)
	Add.l	d1,a6
	Dbra	d3,.Loop1
	Rts			


***********************************************************
Calc_Curve
	Move.w	#0,"u"*2+Algebra_Table
	Lea	B_Array(a4),a1
	Lea	Calculations(pc),a0
	Bsr	Do_Calc


	

***********************************************************
Jeq	Macro
	Cmp.b	#\1,d0
	Beq	\2
	Endm

Do_Calc
	Move.b	(a0)+,d0
	Jeq	0,.Calc_Done
	Pea	Do_Calc(pc)
	Jeq	"(",Open_Bracket
	Jeq	")",Close_Bracket
	Jeq	"+",Add_Op
	Jeq	"-",Sub_Op
	Jeq	"*",Mul_Op
	Jeq	"/",Div_Op

	Cmp.b	#"0",d0
	Bcs	.Calc_Done
	Cmp.b	#"9",d0
	Bls	.Calc_Done
	Bra	Number_Convert
	
	
.Calc_Done
	Rts

Add_Op	Move.b	#1,Operator(a4)
	Rts
Sub_Op	Move.b	#2,Operator(a4)
	Rts
Mul_Op	Move.b	#3,Operator(a4)
	Rts
Div_Op	Move.b	#4,Operator(a4)
	Rts

Number_Convert
	Sub.b	#"0",d0
	And.l	#$ff,d0
	Swap	d0
	Move.l	d0,Left_Equation(a4)
	Rts
	
Open_Bracket
	Addq.b	#1,Braces_Level(a4)
	Rts
Close_Bracket
	Subq.b	#1,Braces_Level(a4)
	Rts


***********************************************************

Swap_Screens
	Movem.l	Screenp(a4),d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenp(a4)
	Move.l	d1,a0
	Bsr	Write_Screen
	Rts

***********************************************************
; Address in a0
Write_Screen
	Pea	(a0)
	Move.b	1(sp),Bp_Hi
	Move.b	2(sp),Bp_Md
	Move.b	3(sp),Bp_Lo
	Addq.l	#4,sp
	Rts

***********************************************************
Check_for_Key
	Tst.b	Key_Pressed(a4)
	Rts

***********************************************************
Check_for_Q
	Cmp.b	#"Q",Key_Pressed(a4)
	Rts	

***********************************************************
Init	Lea	Data(pc),a4		; Globals
	Bsr	Cleardata		; Clear all globals
	Bsr	Setup_Screen_Mode	; 8 plane / overscan
	Bsr	Setup			; Supervisor + Shit
	Bsr	Set_Processor		; Set processor states
	Bsr	Savepal			; Save system pallete
	Bsr	Setup_Screens		; Clear both screens
	Bsr	Vars
	Bsr	Buildkeymap
	Bsr	Save_Vbl
	Bsr	Init_Joy
	Bsr	Set_vbl			; No set VBL interrupt
	Rts

**********************************************************
Buildkeymap
	Lea	Keymap,a0
	Move.w	#255,d0
.Loop	Move.b	d0,(a0,d0)
	Dbra	d0,.Loop
	Lea	$41(a0),a0
	Lea	$20(a0),a1
	Moveq	#25,d0
.Loop2	Move.b	(a0)+,(a1)+
	Dbra	d0,.Loop2
	Rts
**********************************************************
Vars	Lea	Curve_Points(pc),a0
	Move.l	a0,Points_P(a4)
	St	Prev_Curves(a4)
	Clr.w	Acc(a4)
	St	Maddr(a4)
	Rts

**********************************************************
; According to VGA monitor
Setup_Screen_Mode	
	Bsr	Mon_Type
	Cmp.b	#2,d0			; Using VGA monitor ?
	Seq	Vga_Flag(a4)		; Set if using VGA Monitor	
	Bne.s	.Not_Vga		; No !
	Move.w	#$64,Screen_Mode(a4)	; Set VGA monitor bit!
	Bra.s	.Skip			; set mode anyway!
.Not_Vga 
	Move.w	#$23,Screen_Mode(a4)	; Normal ST monitor 8 bpl,320x256
.Skip	Bsr	Setmode			; Set screen mode 8bps,PAL/OVERscan!
	Rts

**********************************************************
; Setup the processor!

Set_Processor
	Movec	Cacr,d0
	Move.w	d0,Cacr_Save(a4)	; Save Cache Control
	Movec	Caar,d0
	Move.w	d0,Caar_Save(a4)	; Save Cache Address
	Moveq	#$0,d0
	Movec	d0,Vbr			; Set Vector Base to 0!
	Rts
	
**********************************************************
; restore SYS state

Out	
	Bsr	No_Joy
	Lea	Data(pc),a4
	Move.w	Cacr_Save(a4),d0
	Movec	d0,Cacr
	Move.w	Caar_Save(a4),d0
	Movec	d0,Caar
	
	Move.w	Mod_Save(a4),Scr_Mod
	Move.w	Del_Save(a4),Scr_Del
	Bsr	Restorepal		; Get back pallete
	Move.w	#37,-(sp)
	Trap	#1
	Addq.l	#2,sp
	Move.b	Scr_save+1(a4),$fff8201.l
	Move.b	Scr_save+2(a4),$fff8203.l
	Move.b	Scr_save+3(a4),$fff820d.l	; Set back bitplane pointers
	Move.l	Vbl_save(a4),$70.w			; Set back VBL interrupt
	Move.l	super_save(a4),-(sp)
	Move.w	#$20,-(sp)
	Trap	#1
	Addq.l	#6,sp				; User mode!

;	Move.w	Old_Mode(a4),Screen_Mode(a4)	; Get back old mode
** NOTE THAT OLD MODE IS CURRENTLY NOT IMPLEMENTED ON THE CURRENT
** GENERATION OF FALCONS, SO WE DO THIS   ->..
	Move.w	#%0000000010001001,Screen_Mode(a4)
	Bsr	Setmode				; Set screen mode!

;	Movem.l	Screenp(a4),a5-a6
;	Pea	(a5)
;	Move.w	#$49,-(sp)
;	Trap	#1				; free memory !
;	Pea	(a6)
;	Move.w	#$49,-(sp)
;	Trap	#1				; free memory !
;	Lea	12(sp),sp	
	
	Clr.l	-(sp)
	trap	#1				; Exit prog!

**********************************************************
; supervisor + save sys state!

Setup	Clr.l	-(sp)
	Move.w	#$20,-(sp)
	Trap	#1
	Addq.l	#6,sp
	move.l	d0,super_save(A4)
	move	#37,-(sp)
	trap	#1
	addq.l	#2,sp
	move.b	$fff8201.l,scr_save+1(a4)
	move.b	$fff8203.l,scr_save+2(a4)		; Save screen addresses
	move.b	$fff820d.l,scr_save+3(a4)
	rts

**********************************************************
; Save/Set Vbl
Save_Vbl
	move.l	$70.w,Vbl_save(a4)	; Save vbl
	Rts
Set_Vbl	Lea	New_Vbl(pc),a0
	Move.l	a0,$70.w		; Set VBL
	Rts

**********************************************************
; All data exept SYSvars
Cleardata
	Move.l	#Varend-Sys_varse-1,d0
.Loop	Clr.b	(a4,d0.l)
	Subq.l	#1,d0
	Bpl.s	.Loop			; All data cleared
	Rts	

**********************************************************
; Calculate addresses for screens + clear em

Setup_Screens
;	Move.w	#$23,-(sp)	; Normal ST monitor 8 bpl,320x256
;	Move.w	#91,-(sp)	; Get size of screen in bytes !
;	Trap	#14
;	Addq.l	#4,sp		; in d0 !
;	Addq.l	#4,d0
;	Move.l	d0,a6		; Save it in a register

	Move.l	#64000,a6
	Move.l	a6,Screen_Size(a4)
;	Move.l	a6,-(sp)
;	Move.w	#$48,-(sp)
;	Trap	#1
;	Addq.l	#6,sp
;	Move.l	d0,Screenp(a4)	; Allocate block and save it
;	Move.l	a6,-(sp)
;	Move.w	#$48,-(sp)
;	Trap	#1
;	Addq.l	#6,sp
;	Move.l	d0,Screenp+4(a4) ; Second block !
	
;	Movem.l	Screenp(a4),d0-d1
	Move.l	#Screen1,d0	
	Move.l	#Screen2,d1
	Moveq	#-4,d2			; Mask long word boundry
	And.l	d2,d0
	And.l	d2,d1
	Movem.l	d0-d1,Screenp(a4)	; Save screen pointers
	Bsr	Clear_Screens
	Move.w	Scr_Del,Del_Save(a4)
	Move.w	Scr_Mod,MOD_Save(a4)
	Rts

**********************************************************
; Clear both screens

Clear_Screens
	Movem.l	Screenp(a4),a0-a1
	Move.l	Screen_Size(a4),d0
	Lsr.l	#2,d0
	Subq.w	#1,d0
.Loop	Clr.l	(a0)+
	Clr.l	(a1)+
	Dbra	d0,.Loop
	Rts

**********************************************************
; Setup screen mode in SCREEN_MODE(a4)
Setmode	Move.w	Screen_mode(a4),-(sp)
	Move.w	#88,-(sp)
	Trap	#14
	Addq.l	#4,sp
	Move.w	d0,Old_Mode(a4)			Save the old mode!
	rts
	
**********************************************************
; Return monitor type in d0
Mon_Type
	Move.w	#89,-(sp)
	Trap	#14
	Addq.l	#2,sp
	Rts

**********************************************************
; Key in d0/Key pressed
Keycheck
	Moveq	#0,d0
	Move.b	Key(pc),d0
;	Lea	Keymap(pc),a0
;	Move.b	(a0,d0),d0
	Cmp.b	#"a",d0
	Bcs.s	.Upper
	Cmp.b	#"z"+1,d0
	Bcc.s	.Upper
	Sub.b	#$20,d0
.Upper	Move.b	d0,Key_Pressed(a4)
	Clr.b	Key
	Rts

**********************************************************
; SAVE 256 pallete

Savepal	Lea	Pal256,a0
	Lea	Sys_Pal(a4),a1
	Move.w	#256,d0
	Bsr	Quick_Copy_Long
	Rts
	
	Pea	Sys_Pal(a4)
	Move.w	#256,-(sp)
	Clr.w	-(sp)
	Move.w	#94,-(sp)
	Trap	#14
	Lea	10(sp),sp
	Rts	

**********************************************************
; Restore 256 pallete
Restorepal
	Lea	Pal256,a0
	Lea	Sys_Pal(a4),a1
	Exg	a0,a1
	Move.w	#256,d0
	Bsr	Quick_Copy_Long
	Rts
	
	Pea	Sys_Pal(a4)
	Move.w	#256,-(sp)
	Clr.w	-(sp)
	Move.w	#930,-(sp)
	Trap	#14
	Lea	10(sp),sp
	Rts	

***********************************************************
; Add to Vbl_Count

New_Vbl	Movem.l	d0-a6,-(sp)
	Lea	Data(pc),a4
	Addq.b	#1,Vbl_Flag(a4)
	Movem.l	(sp)+,d0-a6
	Rte

***********************************************************
; Wait for framerate, then clear!
Wait_Vbl
	Cmp.b	#Frame_Rate,Vbl_Flag(a4)
	Bne.s	Wait_Vbl
	Sf	Vbl_Flag(a4)
	Rts

***********************************************************
; a0=File name a1=address to load!
Load_File
	Pea	(a1)
	Clr.w	-(sp)			; Only read
	Pea	(a0)			; File name on stack !
	Move.w	#$3d,-(sp)		; Function
	Trap	#1			; Load it in
	Addq.l	#8,sp			; Re-align stack
	Tst.l	d0
	Bmi.s	File_Error		; -ive then error ! 
	Lea	Data(pc),a4
	Move.w	d0,Handle(a4)		; Save handle
	Move.l	#$80000,-(sp)		; Read loadsa bytes
	Move.w	d0,-(sp)		; File handle
	Move.w	#$3f,-(sp)		; Read
	Trap	#1
	Lea	12(sp),sp		; Align stack
	Tst.l	d0
	Bmi.s	File_Error
	Move.w	Handle+Data(pc),-(sp)	; Handle
	Move.w	#$3e,-(sp)		; Close file
	Trap	#1
	Addq.l	#4,sp
	Bmi.s	File_Error
	Rts 

File_Error
	Eor.l	#$ffff0000,Pal256
	Bra.s	File_Error

**********************************************************
; a0=Decoded VGA pic, a1=DEST!
Convert_VGA
	Move.l	a1,a2
	Move.w	#(64000/4)-1,d0
.Loopx	Clr.l	(a1)+
	Dbra	d0,.Loopx
	Move.l	a2,a1

	Move.w	#199,d4
.Xloop	Move.w	#319,d0
	Move.l	a1,-(sp)
	Move.w	#$8000,d7
.Loop	Move.b	(a0)+,d1
	Moveq	#7,d6				; Convert from B/Pixel
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
	Move.l	(sp)+,a1
	Lea	Byteswide(a1),a1
	Dbra	d4,.Xloop
	Rts	
	
**********************************************************
; a0=Source pallete , a1=Dest pallete, d0= Intensity, d1=Number !
; Note pallete is in 3 byte RGB format , and throws out in 4 bytes !

Scale_Pallete
	Subq.w	#1,d1
.Loop	Movem.w	Clearr(a4),d2-d4
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3
	Move.b	(a0)+,d4
	Mulu	d0,d2
	Mulu	d0,d3
	Mulu	d0,d4
	Lsr.w	#8,d2
	Lsr.w	#8,d3
	Lsr.w	#8,d4
	Move.b	d2,(a1)+
	Move.b	d3,(a1)+
	Clr.b	(a1)+
	Move.b	d4,(a1)+
	Dbra	d1,.Loop
	Rts

**********************************************************
; a0=LBM VGA pic, a1=Dest, a2=Pointer to pallete (saves in 3 bytes!)
; Note DEST needs around 64,000 bytes !

Decode_VGA
	Move.l	a0,-(sp)
.SearchCMAP
 	Cmp.l	#"CMAP",(a0)		; Search for CMAP
 	Beq.s	.Cmapfound
 	Addq.l	#2,a0
 	Bra.s	.SearchCMAP
.Cmapfound
	Addq.l	#4,a0
	Move.l	(a0)+,d0		; Length of Color data !
.Cloop	Move.b	(a0)+,(a2)+	
	Move.b	(a0)+,(a2)+
	Move.b	(a0)+,(a2)+		; R/G/B
	Subq.l	#3,d0
	Bne.s	.Cloop

	Move.l	(sp)+,a0
.Searchbody
	Cmp.l	#"BODY",(a0)
	Beq.s	.Bodyfound		; Search for body !
	Addq.l	#2,a0
	Bra.s	.Searchbody

.Bodyfound
	Addq.l	#4,a0
	Move.l	(a0)+,d0		Length of byte-run
.ByterunLoop
	Move.b	(a0)+,d1		Byte in d1
	Bmi.s	.Run
	Moveq	#0,d3			Clear d3
	Move.b	d1,d3			Length in d3
	Addq.b	#2,d3			Add 1 for extra count byte
.Copyloop
	Move.b	(a0)+,(a1)+		Copy byte
	Subq.b	#1,d1
	Bge.s	.Copyloop		Decrement loop
	Sub.l	d3,d0			Away from total count
	Bgt.s	.ByterunLoop	
	Bra.s	.Byterunexit	
.Run	Move.b	(a0)+,d2		byte to repeat !
.Rloop	Move.b	d2,(a1)+		Byte in
	Addq.b	#1,d1			Decrement loop
	Ble.s	.RLoop
	Subq.l	#2,d0
	Bgt.s	.ByterunLoop
.Byterunexit
	Rts

**********************************************************
; a0=Source , a1=Dest, d0=Num longs
Quick_Copy_Long
	Movem.l	d0-a6,-(sp)
.Loop	Sub.w	#12,d0
	Ble.s	.Noon
	Movem.l	(a0)+,d1-d7/a2-a6
	Movem.l	d1-d7/a2-a6,(a1)
	Lea	48(a1),a1
	Bra.s	.Loop
.Noon	Beq.s	.Exit
	Add.w	#11,d0
.Loop1	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop1		
.Exit	Movem.l	(sp)+,d0-a6
	Rts

**********************************************************
init_joy
.cfoz
	move.b	$fffc00,d0
	btst	#0,d0
	beq	.ikbd_ok
.wait
	btst	#1,$fffc00
	beq	.wait
	move.b	$fffc02,d1
	bra	.cfoz
.ikbd_ok
	lea	ikbd_strt,a0
	move	#2,d7
	jsr	ikbd_send
	lea	ikbd_strm,a0
	move	#ikbd_strmL,d7
	jsr	ikbd_send
	move.l	$118,old_118
	move.l	#ikbd_int,$118
	or.b	#$40,$fffa09
	or.b	#$40,$fffa15
	bclr	#6,$fffa11
	rts
****************************************************************************
* Kill joystick				*
****************************************************************************
no_joy
	lea	off,a0
	moveq	#offl,d7
	jsr	ikbd_send
	move.l	old_118,$118
	rts
****************************************************************************
* Send a string to the ikbd				*
****************************************************************************
ikbd_send
	lea	$fffc00,a1
.loop
	move.b	(a0)+,d0
	bsr.s	send_ikbd
	dbf	d7,.loop
	rts
send_ikbd
.wait   
	btst	#1,(a1)
	beq.s	.wait
	move.b	d0,2(a1)
	rts
****************************************************************************
* Read a byte from the ikbd				*
****************************************************************************
read_ikbd
.wait   
	btst	#1,(a1)
	beq.s	.wait
	move.b	2(a1),d0
	rts
****************************************************************************
* The interrupt				*
****************************************************************************
ikbd_int
	movem.l	d0-d7/a0-a6,-(sp)
	move	sr,d0
	and	#$f8ff,d0
	or	#$500,d0
	move	d0,sr
	bclr	#6,$fffa11
	bsr	proc_key_int
	movem.l	(sp)+,d0-d7/a0-a6
	rte
proc_key_int
	lea	$fffc00,a1
	move.b	(a1),d6
	btst	#7,d6
	beq.s	.exit
	btst	#0,d6
	beq.s	.skip
	bsr.s	read_keyb
.skip
	and.b	#$20,d6
	beq.s	.exit
	move.b	2(a1),d0
.exit
	rts
read_keyb
	moveq	#0,d0
	bsr	read_ikbd
	tst.b	packet_bcnt
	bne.s	.get_packet
	cmp	#$f6,d0
	bge.s	.start_packet
	move.b	d0,key	  ;store raw keycode
	rts
.start_packet
	move.b	d0,packet_hd    ;packet type.
	sub	#$f6,d0
	lea	packet_lens,a0
	move.b	(a0,d0),packet_bcnt     ;store length.
	rts
.get_packet
	moveq	#0,d1
	move.b	packet_bcnt,d1
	lea	packet_hd,a0
	move.b	d0,(a0,d1)
	subq.b	#1,packet_bcnt
	beq.s	.do_packet
	rts
.do_packet
	moveq	#0,d0
	move.b	packet_hd,d0
	sub	#$f6,d0
	add	d0,d0
	add	d0,d0
	move.l	.jumper(pc,d0),a6
	lea	packet_hd,a0
	jmp	(a6)
.jumper 	
	dc.l	drts,damouse,drmouse,drmouse,drmouse,drmouse,dtime,djoy2,djoy0,djoy1
drmouse
	move.b	(a0),d0
	and	#3,d0
	move	d0,mbuts
	move.b	2(a0),d0
	ext	d0
	add	d0,mxdelta
	move.b	1(a0),d0
	ext	d0
	add	d0,mydelta
drts
	rts
damouse
	rts
djoy0
	move.b	1(a0),port0
	rts
djoy1
	move.b	1(a0),port1
	rts
djoy2
	move.b	1(a0),d2
	move.b	2(a0),d0

	move	d0,d1
	and	#$f,d1
	and	#$f0,d0
	lsr	#4,d0
	btst	#0,d2
	beq.s	.1
	bset	#7,d0
.1
	btst	#1,d2
	beq.s	.2
	bset	#7,d1
.2
	move.b	d0,port0
	move.b	d1,port1
	rts
dtime
	rts

port0		dc.b	0
port1		dc.b	0
packet_lens	dc.b	7,5,2,2,2,2,6,2,1,1
packet_hd  	ds.b	8
packet_bcnt	dc.b	0
key		ds.b	1
		even
old_118		ds.l	1
ikbd_strJ	dc.b    $12,$14         ;turn on joystick.
ikbd_strJL	equ	*-ikbd_strJ-1
ikbd_strm	dc.b	$08,$0b,1,1
ikbd_strml	equ	*-ikbd_strm-1
off		dc.b    $0a
;		dc	320,200
offl		equ	*-off-1
ikbd_strt	dc.b	$0b,$ff,$ff
		even
mxdelta		ds	1
mydelta		ds	1
Prev_MouseXy	Ds.w	2
mbuts		ds	1
mbutsp		ds	1
Keymap		Ds.b	256


**********************************************************


	Rsreset
Sys_Vars	Rs.w	0
Screenp		Rs.l	2
Screen_Size	Rs.l	1
Handle		Rs.w	1
Screen_Mode	Rs.w	1
Vga_Flag	Rs.b	1
Cacr_Save	Rs.w	1
Caar_Save	Rs.w	1
Mod_Save	Rs.w	1
Del_Save	Rs.w	1
Scr_Save	Rs.l	1
Vbl_Save	Rs.l	1
Super_Save	Rs.l	1
Sys_Pal		Rs.l	256
Old_Mode	Rs.w	1
My_Pal		Rs.b	256*3
Dest_Pal	Rs.l	256
Clearr		Rs.w	16
Sys_Varse	Rs.w	0
Maddr		Rs.l	1
Msave		Rs.w	1

Acc		Rs.w	1
Points_P	Rs.l	1
Last_Curve	Rs.l	1
B_Array		Rs.w	4
Dest_Curves	Rs.w	2
Prev_Curves	Rs.l	1

Left_Equation	Rs.l	1
Braces_Level	Rs.b	1
Operator	Rs.b	1

Vbl_Flag	Rs.b	1
Key_Pressed	Rs.b	1

Varend		Rs.b	0

Data	Ds.b	Varend
	Even
	

Curve_Points
	Ds.w	2*300

Atari_Name
	Dc.b	"Atari.LBM",0
	Even


Calculations
	Dc.b	"(1-u)!3/6",0
	Even


Algebra_Table
	Ds.l	256


	Ds.b	2
Screen1	Ds.b	64000
	Ds.b	2
Screen2	Ds.b	64000

	Ds.l	100
Ustack	

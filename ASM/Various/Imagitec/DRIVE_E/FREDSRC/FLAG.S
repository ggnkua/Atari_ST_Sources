X_Sin_Speed	Equ	70
Y_Sin_Speed	Equ	30
Z_Sin_Speed	Equ	40
X_Lin_Add	Equ	50
Y_Lin_Add	Equ	70
Z_Lin_Add	Equ	90
X_Sin_Add	Equ	10
Y_Sin_Add	Equ	40
Z_Sin_Add	Equ	90
X_Sin_Scale	Equ	700
Y_Sin_Scale	Equ	600
Z_Sin_Scale	Equ	400
                                                                                
Blitterstuff 	Equ $ff8a00
Halftone	Equ $000000
Src_Xinc	Equ $000020
Src_Yinc	Equ $000022
Src_Addr	Equ $000024
Endmask1	Equ $000028
Endmask2	Equ $0002a0
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
Bp_Lo		Equ $ff820c+1
Vd_Hi		Equ $ff8204
Vd_Md		Equ $ff8206
Vd_Lo		Equ $ff8208
	
Frame_Rate	Equ	4
Byteswide	Equ	320
Yes		Equ	1
No		Equ	0
Fill		Equ	1
Line		Equ	0
Circle		Equ	2

Num_Squares	Equ	15

**********************************************************
; Give machine back some memory

Free_Mem
	Move.l	a7,a5
	Lea	Ustack,a7
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

Main	Bsr	Wait_Vbl
	Bsr	Clear_Screen
	Bsr	Wave_Object3
	Bsr	Add_Z	
	Bsr	Sort_List
	Bsr	Draw_Objects
	Bsr	Light
	Bsr	Swap_Screens
	Tst.b	Key_code
	Beq.s	Main
	Bra	Out
	
***********************************************************
Light	Lea	Mypal,a0
	Lea	Colorvec,a1
	Lea	Destpal,a2
	Move.w	#255,d0
.Loop	Move.w	(a1)+,d1
	Smi	d7
	And.w	#$ff,d1
	Moveq	#0,d2
	Moveq	#0,d3
	Moveq	#0,d4
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3
	Move.b	(a0)+,d4
	Move.b	(a0)+,d4
	And.b	d7,d4
	Mulu	d1,d2
	Mulu	d1,d3
	Mulu	d1,d4
	Lsr.w	#8,d2
	Lsr.w	#8,d3
	Lsr.w	#8,d4
	Move.b	d2,(a2)+
	Move.b	d3,(a2)+
	Clr.b	(a2)+
	Move.b	d4,(a2)+
	Dbra	d0,.Loop
	St	Copycol
	Rts

***********************************************************

Wave_Object3
	Lea	Object3+2,a0
	Lea	Object4+2,a2
	Lea	Object32+2,a6
	Lea	Sine,a1
	Movem.w	WaveVal,d0-d2
	Movem.w	d0-d2,-(sp)
	Add.w	#X_Sin_Speed,Waveval
	Add.w	#Y_Sin_Speed,Waveval+2
	Add.w	#Z_Sin_Speed,Waveval+4
	Move.w	#Num_Squares,d0
.Loop0	Move.w	#Num_Squares,d1
	Movem.w	(sp),d2-d4
	Add.w	#X_Lin_Add,(sp)
	Add.w	#Y_Lin_Add,2(sp)
	Add.w	#Z_Lin_Add,4(sp)
.Loop	And.w	#$7fe,d2
	And.w	#$7fe,d3
	And.w	#$7fe,d4
	Move.w	(a1,d2),d5
	Move.w	(a1,d3),d6
	Move.w	(a1,d4),d7
	Muls	#X_Sin_Scale,d5
	Muls	#Y_Sin_Scale,d6
	Muls	#Z_Sin_Scale,d7
	Swap	d5
	Swap	d6
	Swap	d7
	Add.w	(a6)+,d5
	Add.w	(a6)+,d6
	Add.w	(a6)+,d7
	Move.w	d5,(a0)+
	Move.w	d6,(a0)+
	Move.w	d7,(a0)+
	Move.w	d5,(a2)+
	Move.w	d6,(a2)+
	Move.w	d7,(a2)+
	Sub.w	-(a6),d7
	Sub.w	-(a6),d6
	Sub.w	-(a6),d5
	Addq.l	#6,a6
	Add.w	#X_Sin_Add,d2
	Add.w	#Y_Sin_Add,d3
	Add.w	#Z_Sin_Add,d4
	Dbra	d1,.Loop
	Dbra	d0,.Loop0
	Addq.l	#6,sp
	Rts

Waveval	Ds.w	3

***********************************************************
Add_Z	Lea	Object_List+14+(0*64)(a4),a0
	Moveq	#1-1,d7
.Loop	Add.l	#$0,(a0)
	Cmp.l	#$7fff,(a0)
	Ble.s	.Ok
	Clr.l	(a0)
.Ok	Lea	64(a0),a0
	Dbra	d7,.Loop
	Rts

***********************************************************
Draw_Objects
	Move.l	Object_Sortp(a4),a0
.Loop	Tst.b	(a0)
	Bmi	.End
	Move.l	(a0)+,a2
	Pea	(a0)
	Lea	X_Rotation(a4),A1
	Btst	#0,Buttons
	Beq.s	.No_Rot
	Move.w	Mouse_X,d0	
	Move.w	Mouse_Y,d1	
	Add.w	d0,4(a2)	
	Add.w	d1,0(a2)	
.No_Rot	Move.w	Mouse_X,d0	
	Move.w	Mouse_Y,d1	
	Clr.w	Mouse_X
	Clr.w	Mouse_Y
	Add.w	d0,8(a2)
	Btst	#1,Buttons
	Beq.s	.No_Z	
	Asl.w	#6,d1
	Add.w	d1,16(a2)
	Bra.s	.Skipy
.No_Z	Add.w	d1,12(a2)
.Skipy	
	Add.w	#20,(a2)
	Add.w	#30,2(a2)
	Add.w	#40,4(a2)

	And.w	#$7fe,(a2)
	And.w	#$7fe,2(a2)
	And.w	#$7fe,4(a2)

	Move.l	(a2)+,(a1)+
	Move.l	(a2)+,(a1)+
	Move.l	(a2)+,(a1)+
	Move.l	(a2)+,(a1)+			X/Y/Z Angles . X/Y/Z Pivot . Object-Struct
	Move.l	(a2)+,(a1)+
	Move.w	(a2)+,(a1)+
	Bsr	Rotate_Object	
	Bsr	Perform_Perspective	
	Bsr	Get_Object_Types
	Bsr	Sort_Elements
	Bsr	Draw_The_Object
	Move.l	(sp)+,a0
	Bra	.Loop
.End	Rts
***********************************************************
Sort_Elements
	Lea	Object_Table(a4),a0		Table of colours/fills/addresses!
	Lea	Z_Coards(a4),a1			Tabke of calculated Zs
	Lea	Z_List(a4),a2			Destination for Address/avgs
	Moveq	#1,d0				Clear work reg.
.Loop	Tst.b	(a0)
	Bmi.s	Sort_The_Object			Last entry !
	Move.l	(a0)+,(a2)+
	Move.l	(a0)+,a3
	Move.l	a3,(a2)+
	Moveq	#0,d1				Clear accumalator
	Moveq	#0,d3				Divider !
	Cmp.w	#Circle,-2(a3)
	Bne.s	.Loop0
	Move.w	(a3)+,d2
	Lsr.w	#1,d2
	Move.w	(a1,d2),(a2)+
.Loopx	Tst.w	(a3)+
	Bpl.s	.Loopx
	Bra.s	.Loop
.Loop0	Move.w	(a3)+,d2			Offset in d2 !
	Bmi.s	.End
	Addq.w	#1,d3
	Lsr.w	#1,d2
	Move.w	(a1,d2),d0			Into work reg.
	Add.l	d0,d1				Add !
	Bra.s	.Loop0
.End	Divu	d3,d1				Get average !
	Move.w	d1,(a2)+
	Bra.s	.Loop

Sort_The_Object
	St	(a2)
.Loop0	Lea	Z_List(a4),a0
	Sf	d7
.Loop1	Tst.b	10(a0)
	Bmi.s	.Sorted
	Move.w	8(a0),d0
	Move.w	18(a0),d1
	Cmp.w	d0,d1
	Bge.s	.Nxt_Coard
	Movem.w	(a0),d0-d7/a2-a3
	Movem.w	d0-d4,10(a0)
	Movem.w	d5-d7/a2-a3,(a0)
	St	d7
.Nxt_Coard
	Lea	10(a0),a0
	Bra.s	.Loop1
.Sorted	Tst.b	d7
	Bne.s	.Loop0

	Lea	Z_List(a4),a0
	Lea	Object_Table(a4),a1
.Loop	Move.l	(a0)+,(a1)+
	Bmi.s	.Exit
	Move.l	(a0)+,(a1)+
	Addq.l	#2,a0
	Bra.s	.Loop
.Exit	Rts

***********************************************************
Draw_The_Object
	Lea	Object_Table(a4),a0
.Loop	Move.w	(a0)+,Poly_Color(a4)
	Bmi.s	.End
	Move.w	(a0)+,d0		Type !
	Pea	4(a0)
	Move.l	(a0)+,a0		Get address of structure
	Pea	.Ret(pc)
	Cmp.w	#Fill,d0
	Beq.s	Draw_Polygon
	Cmp.w	#Line,d0
	Beq	Draw_Line	
	Cmp.w	#Circle,d0
	Beq	Draw_Circle	
.Ret	Move.l	(sp)+,a0
	Bra.s	.Loop
.End	Rts
	

***********************************************************
Draw_Polygon
	Lea	Perspective_Coards(a4),a3	Pointer to list of coards !
	Lea	Line_Mask,a5
	Addq.l	#2,a0
	Move.l	a0,Min_Address(a4)

	Move.w	#$7fff,d1
	Moveq	#0,d3
.Loop2	Move.w	(a0)+,d0
	Bmi.s	.Stop
	Addq.w	#1,d3
	Move.w	2(a3,d0),d2
	Cmp.w	d1,d2
	Bge.s	.Loop2
	Move.w	d2,d1
	Lea	-2(a0),a1
	Bra.s	.Loop2

.Stop	Move.w	d3,Num_Verts(a4)
	Move.w	Poly_Color(a4),d7
	Add.w	d7,d7
	Lea	Poly_Color_Table,a2
	Movem.l	(a2,d7*8),d4-d7
	Movem.l	d4-d7,-(sp)
	
	
	Subq.l	#2,a0
	Move.l	a0,Max_Address(a4)
	Move.l	a1,a0
	Move.w	#-1,Clockwise_Flag(a4)		& Anti!
	Clr.w	Ready_To_Exit(a4)		& Boundry crossed
	Move.w	(a0),d0				Get Initial Offset
	Movem.w	(a3,d0),d0/d6			Get its X/Y
	Move.w	d6,YStart(a4)
	Muls	#Byteswide,d6
	Add.l	Screenp(a4),d6
	Move.l	d6,a6				Screen position !
	Move.w	d0,d1				Same X !
	Subq.l	#2,a0
	Addq.l	#2,a1
	
.Loop1	Tst.b	Ready_To_Exit(a4)
	Bne	.Exit_P
	Tst.b	Clockwise_Flag(a4)		Start filling clockwise ?
	Beq.s	.No_Clock			No !
	Sf	Clockwise_Flag(a4)
	Clr.l	Clock_Wise_Acc(a4)		Clear the accumalator
	Cmp.l	Min_Address(a4),a0
	Bge.s	.Pos1
	Move.l	Max_Address(a4),a0
	Subq.l	#2,a0
.Pos1	Move.w	(a0),d2
	Subq.l	#2,a0
	Movem.w	(a3,d2),d2-d3			Get Coards
	Sub.w	d0,d2
	Smi	d6				Set if drawing line left !
	Bpl.s	.Pos2
	Neg.w	d2
.Pos2	Sub.w	Ystart(a4),d3			Get difference from current line!
	Bge.s	.CC1
	Moveq	#0,d3
.Cc1	Addq.w	#1,d3				Make sure at least 1
	Move.w	d3,Ycount(a4)			And save it !
	Ext.l	d2
	Divu	d3,d2				Integer/y
	Swap	d2				Integer*65536
	Moveq	#0,d5				Clear work reg
	Move.w	d2,d5				Fraction in !
	Swap	d5				fraction*65536
	Divu	d3,d5				Fraction/Y
	Move.w	d5,d2				Save it in lo-Word !
	Tst.b	d6
	Beq.s	.No_N1
	Neg.l	d2
.No_N1	Move.l	d2,Clock_Wise_Add(a4)		New Add !
	Subq.w	#1,Num_Verts(a4)
	Sle	Ready_To_Exit(a4)

.No_Clock
	Tst.b	AntiClockWise_Flag(a4)
	Beq.s	.No_Anti
	Sf	AntiClockwise_Flag(a4)
	Clr.l	AntiClock_Wise_Acc(a4)		Same for Anticlockwise!
	Cmp.l	Max_Address(a4),a1
	Blt.s	.Pos3
	Move.l	Min_Address(a4),a1
.Pos3	Move.w	(a1)+,d2
	Movem.w	(a3,d2),d2-d3
	Sub.w	d1,d2
	Smi	d6				
	Bpl.s	.Pos4
	Neg.w	d2
.Pos4	Sub.w	Ystart(a4),d3
	Bge.s	.CC2
	Moveq	#0,d3
.Cc2	Addq.w	#1,d3
	Move.w	d3,Ycount+2(a4)
	Ext.l	d2
	Divu	d3,d2
	Swap	d2
	Moveq	#0,d5
	Move.w	d2,d5
	Swap	d5
	Divu	d3,d5
	Move.w	d5,d2
	Tst.b	d6
	Beq.s	.No_N2
	Neg.l	d2
.No_N2	Move.l	d2,AntiClock_Wise_Add(a4)
	Subq.w	#1,Num_Verts(a4)
	Sle	Ready_To_Exit(a4)
.No_Anti

.Fill_Loop
	Cmp.l	Screenpe(a4),a6
	Bge.s	.Exit_P
	Cmp.l	Screenp(a4),a6
	Bge.s	.Ok_Draw
	Lea	Byteswide(a6),a6
	Bra.s	.Skip
.Ok_Draw	
	Movem.l	(sp),d4-d7
	Bsr.s	Draw_Horizontal_Line
.Skip	Addq.w	#1,Ystart(a4)
	Movem.l	Clock_Wise_Add(a4),d4-d7
	Add.l	d4,d6
	Add.l	d5,d7
	Move.w	d6,Clock_Wise_Acc+2(a4)
	Move.w	d7,AntiClock_Wise_Acc+2(a4)
	Swap	d6
	Swap	d7
	Add.w	d6,d0
	Add.w	d7,d1
	Subq.w	#1,Ycount(a4)
	Seq	Clockwise_Flag(a4)
	Subq.w	#1,Ycount+2(a4)
	Seq	AntiClockwise_Flag(a4)
	Tst.b	Clockwise_Flag(a4)
	Bne	.Loop1
	Tst.b	AntiClockwise_Flag(a4)
	Beq.s	.Fill_Loop
	Bra	.Loop1
.Exit_P	Lea	16(sp),sp
	Rts


***********************************************************
;d0=Left X, d1=Right d4-d7=Fill pattern X a6=Line on screen !

Draw_Horizontal_Line
	Pea	Byteswide(a6)		Add and Place on stack !
	Movem.w	d0-d1,X1_Save(a4)
	Cmp.w	d0,d1
	Bge.s	.Ok0
	Exg	d0,d1
.Ok0	Move.w	#319,d2
	Tst.w	d0
	Bgt.s	.OK1
	Moveq	#0,d0
.Ok1	Cmp.w	d2,d0
	Ble.s	.Ok2
	Move.w	d2,d0
.Ok2	Tst.w	d1
	Bgt.s	.Ok3
	Moveq	#0,d1
.Ok3	Cmp.w	d2,d1
	Ble.s	.Ok4
	Move.w	d2,d1
.Ok4	Moveq	#-$10,d2
	Moveq	#-$10,d3
	And.w	d0,d2
	Lea	(a6,d2),a6		Start address !
	And.w	d1,d3
	Sub.w	d2,d3			Get difference !
	Bgt.s	.More_One_Word

.Only_One_Word
	Moveq	#$f,d2
	Moveq	#$f,d3
	And.w	d0,d2
	And.w	d1,d3
	Move.l	(a5,d2*4),d2
	Move.l	(a5,d3*4),d3
	Not.l	d2
	And.l	d3,d2
	And.l	d2,d4
	And.l	d2,d5
	And.l	d2,d6
	And.l	d2,d7
	Not.l	d2
	And.l	d2,(a6)	
	Or.l	d4,(a6)+
	And.l	d2,(a6)	
	Or.l	d5,(a6)+
	And.l	d2,(a6)	
	Or.l	d6,(a6)+
	And.l	d2,(a6)	
	Or.l	d7,(a6)+
	Movem.w	X1_Save(a4),d0-d1
	Move.l	(sp)+,a6
	Rts

.More_One_Word
	Lea	(a6,d3),a4		End address in a4 !
	Neg.w	d3			Get negated value
	Asr.w	#2,d3			Divide by 2
	
	Moveq	#$f,d2
	And.w	d0,d2
	Move.l	(a5,d2*4),d2		Left mask in d2
	Not.l	d2
	Movem.l	d4-d7,-(sp)
	And.l	d2,d4
	And.l	d2,d5
	And.l	d2,d6
	And.l	d2,d7
	Not.l	d2
	And.l	d2,(a6)
	Or.l	d4,(a6)+
	And.l	d2,(a6)
	Or.l	d5,(a6)+
	And.l	d2,(a6)
	Or.l	d6,(a6)+
	And.l	d2,(a6)
	Or.l	d7,(a6)+
	Movem.l	(sp)+,d4-d7
	Move.l	a4,a6			Save it !
	Jmp	.End_J+4(pc,d3)
	
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)
	Movem.l	d4-d7,-(a4)

.End_J	Moveq	#$f,d2
	And.w	d1,d2
	Move.l	(a5,d2*4),d2
	And.l	d2,d4
	And.l	d2,d5
	And.l	d2,d6
	And.l	d2,d7
	Not.l	d2
	And.l	d2,(a6)
	Or.l	d4,(a6)+
	And.l	d2,(a6)
	Or.l	d5,(a6)+
	And.l	d2,(a6)
	Or.l	d6,(a6)+
	And.l	d2,(a6)
	Or.l	d7,(a6)+
	Move.l	(sp)+,a6
	Lea	Data(pc),a4
	Movem.w	X1_Save(a4),d0-d1
	Rts

***********************************************************

Draw_Line
	Lea	Perspective_Coards(a4),a1
	Move.w	Poly_Color(a4),d7
.Loop1	Move.w	(a0)+,d0			Vertice in d0
	Move.w	(a0),d2				Vertice to in d2 !
	Bmi.s	.Done
	Movem.w	(a1,d0),d0-d1
	Movem.w	(a1,d2),d2-d3
	Move.l	Screenp(a4),a6
	Bsr.s	Draw_A_Line
	Bra.s	.Loop1
.Done	Rts

***********************************************************
; d0-d3 x1/y1/x2/y2  a6= Screen !  (8BPL 320 bytes!)	

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
Draw_Circle
	Lea	Line_Mask,a5
	Move.w	-4(a0),Poly_Color(a4)
	Movem.w	(a0)+,d0-d1/d6			Fill/Radius/Base coardinates
	Exg	d0,d1
	Exg	d1,d6
	Addq.l	#2,a0				Advance !
	Cmp.w	#Fill,d0
	Beq.s	.Filled_Circle
.Hold	Bra.s	.Hold

.Filled_Circle
	Lea	Z_Coards(a4),a2
	Lsr.w	#1,d6
	Add.w	d1,d1
	Mulu	(a2,d6),d1
	Swap	d1
	Move.w	d1,Circle_Radius(a4)
	Beq	.Exit
	Add.w	d1,d1
	Move.w	d1,Circle_Lines(a4)	
	Move.l	#1024,d0
	Divu	d1,d0
	Swap	d0
	Moveq	#0,d2
	Move.w	d0,d2
	Swap	d2
	Divu	d1,d2
	Move.w	d2,d0				d0=Sine table pointer accumalate !
	Move.l	d0,Circle_Add(a4)
	Clr.l	Circle_Acc(a4)
	Lea	Perspective_Coards(a4),a3
	Movem.w	(a3,d6*2),d5-d6			X/Y of this !
	Move.w	d5,CircleX(a4)
	Lsr.w	#1,d1
	Sub.w	d1,d6				Start Y
	Muls	#Byteswide,d6
	Add.l	Screenp(a4),d6
	Move.l	d6,a6				Get start address
	Move.w	Poly_Color(a4),d7
	Lea	Poly_Color_Table,a2
	Add.w	d7,d7
	Movem.l	(a2,d7*8),d4-d7
	Movem.l	d4-d7,-(sp)
	Lea	Circle_Sine,a1
.Loop1	Cmp.l	Screenp(a4),a6
	Bge.s	.Skip1
	Lea	Byteswide(a6),a6
	Bra.s	.Skip2
.Skip1	Cmp.l	Screenpe(a4),a6
	Bge.s	.Re_Stack
	Move.w	Circlex(a4),d0
	Move.w	d0,d1
	Move.w	Circle_Radius(a4),d2
	Mulu	(a1),d2
	Swap	d2
	Sub.w	d2,d0
	Add.w	d2,d1
	Movem.l	(sp),d4-d7
	Bsr	Draw_Horizontal_Line
.Skip2	Move.l	Circle_Add(a4),d0
	Move.l	Circle_Acc(a4),d1
	Add.l	d0,d1
	Move.w	d1,Circle_Acc+2(a4)
	Swap	d1
	Lea	(a1,d1*2),a1
	Subq.w	#1,Circle_Lines(a4)
	Bne.s	.Loop1
.Re_Stack
	Lea	16(sp),sp
.Exit	Rts
	
***********************************************************
Sort_List
	Lea	Object_List(a4),a0
	Lea	Object_Sort_List(a4),a1
	Move.l	a1,Object_Sortp(a4)
	Moveq	#64,d7
	Moveq	#100-1,d6
.Loop	Tst.b	(a0)
	Bmi.s	.Next_Object
	Move.l	a0,(a1)+
.Next_Object
	Add.l	d7,a0
	Dbra	d6,.Loop
	St	(a1)
	
.Loop1	Lea	Object_Sort_List(a4),a0
	Sf	d7
.Loop2	Tst.b	(a0)
	Bmi.s	.Sorted
	Move.l	(a0)+,a1
	Tst.b	(a0)
	Bmi.s	.Sorted
	Move.l	(a0),a2				Object pointers
	Move.l	14(a1),d0
	Move.l	14(a2),d1			Z pivots in
	Cmp.l	d0,d1
	Bge.s	.Loop2
	St	d7				Set for resort !
	Move.l	a1,(a0)
	Move.l	a2,-4(a0)
	Bra.s	.Loop2
.Sorted	Tst.b	d7
	Bne.s	.Loop1
	Rts

***********************************************************
Clear_Screen
	Move.l	Screenp(a4),a0
	Moveq	#99,d7
	Movem.w	Clearr(a4),d0-d6/a1-a6
.Loop	
	Rept	2
	Movem.l	d0-d6/a1-a6,(a0)
	Movem.l	d0-d6/a1-a6,52(a0)
	Movem.l	d0-d6/a1-a6,104(a0)
	Movem.l	d0-d6/a1-a6,156(a0)
	Movem.l	d0-d6/a1-a6,208(a0)
	Movem.l	d0-d6/a1-a6,260(a0)
	Movem.l	d0-d1,312(a0)
	Lea	320(a0),a0	
	Endr
	Dbra	d7,.Loop
	Lea	Data(pc),a4
	Rts

***********************************************************
Get_Object_Types
	Lea	Object_Table(a4),a3
	Lea	Perspective_Coards(a4),a1	Pointer for all relative stuff !
	Move.l	Surface_Pointer(a4),a0		Pointer to surface data !
	Lea	Colorvec(pc),a6
	Move.w	(a0)+,d7			Number of polygons/Lines to consider!
	Subq.w	#1,d7
	Bmi.s	.Exit
.Loop	Cmp.w	#Yes,(a0)+
	Bne.s	.No_Hid				This surface should be hidden !
	Movem.w	(a0)+,d0/d2/d4			Get triangle
	Movem.w	(a1,d0),d0-d1
	Movem.w	(a1,d2),d2-d3			
	Movem.w	(a1,d4),d4-d5			Collect traingle!
	Sub.w	d0,d2
	Sub.w	d0,d4				Get X deltas
	Sub.w	d1,d3
	Sub.w	d1,d5				Get Y deltas
	Muls	d2,d5				(X1-X0)*Y2
	Muls	d3,d4				(Y1-Y0)*X2
	Sub.l	d4,d5
;	Bmi.s	.Find_N
	Smi	d6
	Bpl.s	.Pos
	Neg.w	d5
.Pos	Mulu	#65535/1300,d5
	Lsr.w	#8,d5
	Move.w	(a0),d0
	Move.w	d5,(a6,d0*2)
	Or.b	d6,(a6,d0*2)
.No_Hid	Move.l	(a0)+,(a3)+			Color/Type
	Move.l	a0,(a3)+			Store address of structure
.Find_N	Tst.w	(a0)+
	Bpl.s	.Find_N				Find next entry in table
	Dbra	d7,.Loop
.Exit	St	(a3)
	Rts
	
Colorvec
	Ds.w	256	
Copycol	Ds.w	1
	
***********************************************************
Perform_Perspective
	Move.w	Num_Coards(a4),d7
	Subq.w	#1,d7
	Lea	Rotated_Coards(a4),a0
	Lea	Perspective_Coards(a4),a1
	Lea	Z_Coards(a4),a2
	Movem.l	X_Pivot(a4),d3-d5
.Loop	Movem.w	(a0)+,d0-d2			; x/y/z
	Add.w	#800,d2
	Mulu	#$7fff/1000,d2
	Mulu	d5,d2
	Swap	d2
	Add.l	d3,d0
	Add.l	d4,d1
	Add.w	d0,d0
	Add.w	d1,d1
	Muls	d2,d0
	Muls	d2,d1
	Swap	d0
	Swap	d1
	Add.w	#160,d0
	Add.w	#100,d1
	Move.w	d0,(a1)+	
	Move.w	d1,(a1)+			; And save em !
	Move.w	d2,(a2)+
	Dbra	d7,.Loop
	Rts

***********************************************************
Rotate_Object
	Move.l	Object_Use(a4),a0
	Move.w	(a0)+,d7			; Number of coardinates
	Move.w	d7,Num_Coards(a4)
	Subq.w	#1,d7
	Move.w	X_Rotation(a4),d1	
	Move.w	Y_Rotation(a4),d2
	Move.w	Z_Rotation(a4),d0	
	Move.w	#$7fe,d3
	And.w	d3,d0
	And.w	d3,d1
	And.w	d3,d2
	Lea	Sine,a1
	Lea	-12(sp),sp
	Move.w	(a1,d0),(sp)
	Move.w	(a1,d1),4(sp)		; Sin Alpha/Beta/Gamma
	Move.w	(a1,d2),8(sp)
	Lea	512(a1),a1
	Move.w	(a1,d0),2(sp)
	Move.w	(a1,d1),6(sp)		; Cos Alpha/Beta/Gamma
	Move.w	(a1,d2),10(sp)
	Lea	Rotated_Coards(a4),a1

.Loop	Movem.w	(a0),d0-d2			; x/y/z
	Movem.w	(a0)+,d3-d5			; Save again !
	
; Rotation around Z-Axis	
	Muls	2(sp),d0			; X1=X*Cos(a)-Y*Sin(a)
	Muls	(sp),d1
	Asl.l	#2,d0
	Asl.l	#2,d1
	Sub.l	d1,d0				; d0=X1
	Swap	d0
	Muls	2(sp),d4			; Y1=Y*Cos(a)+X*Sin(a)	
	Muls	(sp),d3
	Asl.l	#2,d4
	Asl.l	#2,d3
	Add.l	d3,d4
	Swap	d4				; d4=Y1
	Move.w	d4,d1				; Save !
	
; Rotation around X-Axis
	Muls	6(sp),d4			; Y2=Y1*Cos(b)-Z*Sin(b)
	Muls	4(sp),d5
	Asl.l	#2,d4	
	Asl.l	#2,d5
	Sub.l	d5,d4
	Swap	d4				; d4=Y2
	Muls	6(sp),d2			; Z1=Z*Cos(b)+Y1*Sin(b)
	Muls	4(sp),d1
	Asl.l	#2,d2
	Asl.l	#2,d1
	Add.l	d1,d2
	Swap	d2				; d2=Z1
	Move.w	d2,d5				; Save Z1
	Move.w	d0,d3				; Save X1

; Rotation around Y-Axis
	Muls	10(sp),d2			; Z2=Z1*Cos(g)-X1*Sin(g)
	Muls	8(sp),d0
	Asl.l	#2,d2
	Asl.l	#2,d0
	Sub.l	d0,d2
	Swap	d2				; d2=Z2
	Muls	10(sp),d3			;X2=X1*Cos(g)+Z1*Sin(g)	 
	Muls	8(sp),d5
	Asl.l	#2,d3
	Asl.l	#2,d5
	Add.l	d5,d3
	Swap	d3				; d3=X2
	
	Move.w	d3,(a1)+
	Move.w	d4,(a1)+
	Move.w	d2,(a1)+			; Save x/y/z
	Dbra	d7,.Loop
	Lea	12(sp),sp
	Move.l	a0,Surface_Pointer(a4)
	Rts

***********************************************************
Swap_Screens
	Movem.l	Screenpe(a4),d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenpe(a4)
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
	Bsr	Save_Vbl
	Bsr	Build_Surf
	Bsr	Vars1
	Bsr	SetPal
	Bsr	Make_Colors
	Bsr	Set_vbl			; No set  VBL interrupt
	Rts

**********************************************************
Build_Surf
	Lea	Object3,a0
	Lea	Object32,a1
	Move.w	#Num_Squares,d0
	Move.w	#Num_Squares,d1
	Addq.w	#1,d0
	Addq.w	#1,d1
	Mulu	d0,d1
	Move.w	d1,(a0)+
	Move.w	d1,(a1)+
	Move.w	d0,-(sp)			Number of ys
	Move.w	#Num_Squares,d0
	Lsr.w	#1,d0
	Mulu	#50,d0
	Neg.w	d0
.Loop0	Move.w	#Num_Squares,d1
	Move.w	#Num_Squares,d2
	Lsr.w	#1,d2
	Mulu	#50,d2
	Neg.w	d2
.Loop1	Move.w	d2,(a0)+
	Move.w	d0,(a0)+
	Clr.w	(a0)+
	Move.w	d2,(a1)+
	Move.w	d0,(a1)+
	Clr.w	(a1)+
	Add.w	#50,d2
	Dbra	d1,.Loop1
	Add.w	#50,d0
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp

	Move.w	#Num_Squares,d0
	Mulu	d0,d0
	Move.w	d0,(a0)+
	
	Move.w	#Num_Squares-1,d7
	Move.w	#1,-(sp)
	Moveq	#0,d0
.Xloop	Move.w	#Num_Squares-1,d6
.Loop	Move.w	#Yes,(a0)+
	Move.l	a0,a2
	Addq.l	#6,a0
	Move.w	(sp),(a0)+
	Addq.w	#1,(sp)
	And.w	#$ff,(sp)
	Move.w	#Fill,(a0)+
	Move.w	d0,-(sp)
	Move.l	a0,a3
	Move.w	d0,(a0)+
	Move.w	d0,(a0)
	Addq.w	#4,(a0)+
	Move.w	d0,d1
	Add.w	#((Num_Squares)+2)*4,d1
	Move.w	d1,(a0)+
	Move.w	d1,(a0)
	Subq.w	#4,(a0)+
	Move.w	(sp)+,(a0)+
	Move.w	#-1,(a0)+
	Addq.w	#4,d0
	Move.w	6(a3),(a2)+
	Move.w	0(a3),(a2)+
	Move.w	4(a3),(a2)+
	Dbra	d6,.Loop
	Addq.w	#4,d0
	Dbra	d7,.Xloop
	Addq.l	#2,sp
	Lea	Object3,a0
	Lea	Object4,a1
	Move.w	#6999,d0
.Loopf	Move.l	(a0)+,(A1)+
	DBRA	D0,.Loopf

	Lea	Object4,a0
	Move.w	(a0)+,d0
	Mulu	#6,d0
	Add.l	d0,a0
	Move.w	(a0)+,d0
	Subq.w	#1,d0
.Loopq	Addq.l	#8,a0
	Add.w	#$80,(a0)
.Src	Tst.w	(a0)+
	Bpl.s	.Src
	Dbra	d0,.Loopq
	Rts	


**********************************************************
Make_Colors
	Lea	Poly_Color_Table,a0
	Moveq	#0,d0
.Loop	Move.w	d0,d1
	Moveq	#7,d2	
.Loop2	Lsr.b	#1,d1
	Scs	(a0)+	
	Scs	(a0)+	
	Dbra	d2,.Loop2
	Addq.b	#1,d0
	Bcc.s	.Loop
	Rts


**********************************************************
SetPal
	Lea	Mypal,a0
	Lea	Pal256,a1
	Move.w	#255,d0
.Loop	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop
	Rts

**********************************************************
Vars1	Lea	Object_List(a4),a0
	Move.w	#64*100-1,d0
.Loop	St	(a0,d0)
	Dbra	d0,.Loop
	Pea	64(a0)
;	Move.w	#0,(a0)+			x angle
;	Move.w	#0,(a0)+			y angle
;	Move.w	#0,(a0)+			z angle
;	Move.l	#00,(a0)+			X pivot;
;	Move.l	#00,(a0)+			y Pivot
;	Move.l	#$3000,(a0)+			z pivot
;	Move.l	#Object1,(a0)+			Object number !
	Move.l	(sp)+,a0
	Pea	64(a0)
;	Move.w	#0,(a0)+			x angle
;	Move.w	#0,(a0)+			y angle
;	Move.w	#0,(a0)+			z angle
;	Move.l	#200,(a0)+			X pivot
;	Move.l	#00,(a0)+			y Pivot
;	Move.l	#$7000,(a0)+			z pivot
;	Move.l	#Object2,(a0)+			Object number !
	Move.l	(sp)+,a0
	Pea	64(a0)
	Move.w	#0,(a0)+			x angle
	Move.w	#0,(a0)+			y angle
	Move.w	#0,(a0)+			z angle
	Move.l	#00,(a0)+			X pivot
	Move.l	#00,(a0)+			y Pivot
	Move.l	#$7F00,(a0)+			z pivot
	Move.l	#Object3,(a0)+			Object number !
	Move.l	(sp)+,a0
;	Move.w	#$400,(a0)+			x angle
;	Move.w	#$600,(a0)+			y angle
;	Move.w	#$400,(a0)+			z angle
;	Move.l	#100,(a0)+			X pivot
;	Move.l	#100,(a0)+			y Pivot
;	Move.l	#$7f00,(a0)+			z pivot
;	Move.l	#Object4,(a0)+			Object number !
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

Out	Bsr	Hbloff
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
;	Move.l	a0,$70.w		; Set VBL
	Bsr	Hblon
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
	Movem.l	Screenp(a4),d0-d1
	Add.l	#64000,d0
	Add.l	#64000,d1
	Movem.l	d0-d1,Screenpe(a4)
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
	Move.w	#$ff,-(sp)
	Move.w	#6,-(sp)
	Trap	#1			; Read key > d0
	Addq.l	#4,sp
	Cmp.b	#"a",d0
	Bcs.s	.Upper
	Cmp.b	#"z"+1,d0
	Bcc.s	.Upper
	Sub.b	#$20,d0
.Upper	Move.b	d0,Key_Pressed(a4)
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

New4
New_Vbl	Movem.l	d0-a6,-(sp)
	Bsr	Read_Mouse
	Bsr	Get_Mouse	
	Tst.b	Copycol
	Beq.s	.Skip
	Bsr.s	Copyc
.Skip	Lea	Data(pc),a4
	Addq.b	#1,Vbl_Flag(a4)
	Movem.l	(sp)+,d0-a6
	Move.l	#-1,Pal256+1020
	Rte

***********************************************************
Copyc	Sf	Copycol
	Lea	Destpal,a0
	Lea	Pal256,a1
	Move.w	#255,d0
.Loop	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop
	Rts

***********************************************************
; Wait for framerate, then clear!
Wait_Vbl
	Cmp.b	#Frame_Rate,Vbl_Flag(a4)
	Blt.s	Wait_Vbl
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
	Include	E:\Includes\New_Key1.S

Newtb0	Rte

**********************************************************


	Rsreset
Sys_Vars		Rs.w	0
Screenp			Rs.l	2
Screenpe		Rs.l	2
Screen_Size		Rs.l	1
Handle			Rs.w	1
Screen_Mode		Rs.w	1
Vga_Flag		Rs.b	1
Cacr_Save		Rs.w	1
Caar_Save		Rs.w	1
Mod_Save		Rs.w	1
Del_Save		Rs.w	1
Scr_Save		Rs.l	1
Vbl_Save		Rs.l	1
Super_Save		Rs.l	1
Sys_Pal			Rs.l	256
Old_Mode		Rs.w	1
My_Pal			Rs.b	256*3
Dest_Pal		Rs.l	256
Clearr			Rs.w	16
Vbl_Flag		Rs.b	1
Key_Pressed		Rs.b	1
Sys_Varse		Rs.w	0

Object_List		Rs.b	64*300	; Infos about objects to be reckoned with
Object_Sortp		Rs.l	1	; Pointer for list pointer
Object_Sort_List	Rs.l	380	; The list of sorted 3d Objects in list
Z_List			Rs.l	380

Num_Coards		Rs.w	1	; Number of coardinates that make up the object
Num_Surfs		Rs.w	1	; Number of polys in object
Surface_Pointer		Rs.l	1	; Pointer to the surface data
X_Rotation		Rs.w	1
Y_Rotation		Rs.w	1	; Current angles of rotation
Z_Rotation		Rs.w	1
X_Pivot			Rs.l	1
Y_Pivot			Rs.l	1	; X/Y/Z in the 3d World
Z_Pivot			Rs.l	1
Object_Use		Rs.l	1	; Pointer for the object to manipulate.
Rotated_Coards		Rs.w	3*330	; 3d Rotated coardinates
Perspective_Coards 	Rs.w	2*330	; Perspective cacled x/ys
Z_Coards		Rs.w	1*330	; Perspective calced Zs
Object_Table		Rs.w	4*330	; List of Type/Color/Pointer of object to draw.

Poly_Color		Rs.w	1	; Save for the polygon colour
YCount			Rs.w	2	; Counter used for sides vertical size
Clock_Wise_Add		Rs.l	1	; Accumalator/modifiers
AntiClock_Wise_Add	Rs.l	1	; for the gradiants in all
Clock_Wise_ACC		Rs.l	1	; Poly-Sides
AntiClock_Wise_ACC	Rs.l	1
Ystart			Rs.w	1	; Current unit line for fill
Min_Address		Rs.l	1	; Both these used for table wrap rounds
Max_Address		Rs.l	1	; When drawing polygons
Num_Verts		Rs.w	1	; Number of vertices/sides in polygon
X1_Save			Rs.w	1	; Save x/y on horizontal line,
X2_Save			Rs.w	1	; In case of error.
ClockWise_Flag		Rs.b	1	; Flag to draw a new clockwise poly
AntiClockWise_Flag	Rs.b	1	; Flag to draw a new anti-clockwise poly
Circle_Add		Rs.l	1	; Accumalator modifier.
Circle_Acc		Rs.l	1	; Accumalator value for circle/sin
Circle_Lines		Rs.w	1	; Number of vertical lines for full circle
Circle_Radius		Rs.w	1	; Radius (units*2) of circle
Circlex			Rs.w	1	; Circles base X position	

Ready_To_Exit		Rs.b	1	; Flag set when all sides are drawn!

Varend			Rs.b	0

Data	Ds.b	Varend

	Even

Line_Mask
	Dc.l	$00000000,$80008000,$c000c000,$e000e000
	Dc.l	$f000f000,$f800f800,$fc00fc00,$fe00fe00
	Dc.l	$ff00ff00,$ff80ff80,$ffc0ffc0,$ffe0ffe0
	Dc.l	$fff0fff0,$fff8fff8,$fffcfffc,$fffefffe
	
MyPal	
	Dc.l	0
	REPT	64
	Dc.l	$ff0000ff
	Dc.l	$ffff0000
	ENDR
	REPT	64
	Dc.l	$ffff00ff
	Dc.l	$00ff00ff
	ENDR

Destpal	Ds.l	256


Poly_color_Table
	Ds.w	8*256

Sine	Include	Wx.inc			1024 VALUES + COS EXT.
Sinee	Even
Circle_Sine	Incbin	Circ.Sin
Circle_Sinee	Even
 


Object1	Dc.w	22			; Number of points
	Dc.w	-250,-60,+100		; x/y/z
	Dc.w	+250,-60,+100
	Dc.w	+250,+60,+100
	Dc.w	-250,+60,+100
	Dc.w	-250,-60,-100		
	Dc.w	+250,-60,-100
	Dc.w	+250,+60,-100
	Dc.w	-250,+60,-100
	
	Dc.w	-200,-200,+200		
	Dc.w	+200,-200,+200
	Dc.w	+200,+200,+200
	Dc.w	-200,+200,+200

	Dc.w	-200,-200,-200		
	Dc.w	+200,-200,-200
	Dc.w	+200,+200,-200
	Dc.w	-200,+200,-200
	
	Dc.w	-450,+000,+10
	Dc.w	-450,+000,-10
	
	Dc.w	0,0,-400
	Dc.w	0,0,+400
	Dc.w	0,-400,0
	Dc.w	0,+400,0
	
	Dc.w	26		; Number of surfaces

; Structure >>
; .W Hide Yes/no  Yes=3.w For triangle
; .W Color
; .W Fill ?]
; .W until -1 , Connections for vertices
	
	Dc.w	Yes,12,00,08
	Dc.w	01,Fill
	Dc.w	00,04,08,12,00,-1	

	Dc.w	Yes,00,16,04
	Dc.w	02,Fill
	Dc.w	16,20,04,00,16,-1

	Dc.w	Yes,16,28,20
	Dc.w	03,Fill
	Dc.w	28,24,20,16,28,-1
	
	Dc.w	Yes,28,12,24
	Dc.w	04,Fill
	Dc.w	12,08,24,28,12,-1
	
	Dc.w	Yes,28,16,12
	Dc.w	05,Fill
	Dc.w	16,00,12,28,16,-1
	
	Dc.w	Yes,08,04,24
	Dc.w	06,Fill
	Dc.w	04,20,24,08,04,-1

	Dc.w	No
	Dc.w	07,Fill
	Dc.w	32,36,40,44,32,-1

	Dc.w	No
	Dc.w	06,Fill
	Dc.w	48,52,56,60,48,-1

	Dc.w	No
	Dc.w	05,Fill
	Dc.w	32,36,52,48,32,-1

	Dc.w	No
	Dc.w	04,Fill
	Dc.w	32+8,36+8,52+8,48+8,32+8,-1
		
	Dc.w	No
	Dc.w	01,Line
	Dc.w	0,32,-1
	Dc.w	No
	Dc.w	01,Line
	Dc.w	4,36,-1
	Dc.w	No
	Dc.w	01,Line
	Dc.w	8,40,-1
	Dc.w	No
	Dc.w	01,Line
	Dc.w	12,44,-1
	Dc.w	No
	
	Dc.w	01,Line
	Dc.w	48,16,-1
	Dc.w	No
	Dc.w	01,Line
	Dc.w	52,20,-1
	Dc.w	No
	Dc.w	01,Line
	Dc.w	56,24,-1
	Dc.w	No
	Dc.w	01,Line
	Dc.w	60,28,-1

	Dc.w	No
	Dc.w	02,Fill
	Dc.w	0,64,12,0,-1

	Dc.w	No
	Dc.w	02,Fill
	Dc.w	16,68,28,16,-1

	Dc.w	No
	Dc.w	01,Fill
	Dc.w	0,64,68,16,0,-1

	Dc.w	No
	Dc.w	13,Fill
	Dc.w	28,68,64,12,28,-1

	Dc.w	No,09,Circle,72,Fill,100,-1	No hide, Color, filled circle, 50 radius from coards !
	Dc.w	No,10,Circle,76,Fill,100,-1	No hide, Color, filled circle, 50 radius from coards !
	Dc.w	No,13,Circle,80,Fill,220,-1	No hide, Color, filled circle, 50 radius from coards !
	Dc.w	No,14,Circle,84,Fill,220,-1	No hide, Color, filled circle, 50 radius from coards !

Object2	Dc.w	8			; Number of points
	Dc.w	-250,-250,+250		; x/y/z
	Dc.w	+250,-250,+250
	Dc.w	+250,+250,+250
	Dc.w	-250,+350,+250
	Dc.w	-250,-250,-250		; x/y/z
	Dc.w	+250,-250,-250
	Dc.w	+250,+250,-250
	Dc.w	-250,+350,-250

	Dc.w	6		; Number of surfaces
	
	Dc.w	Yes,12,00,08
	Dc.w	1,Fill
	Dc.w	00,04,08,12,00,-1	

	Dc.w	Yes,00,16,04
	Dc.w	12,Fill
	Dc.w	16,20,04,00,16,-1

	Dc.w	Yes,16,28,20
	Dc.w	13,Fill
	Dc.w	28,24,20,16,28,-1
	
	Dc.w	Yes,28,12,24
	Dc.w	14,Fill
	Dc.w	12,08,24,28,12,-1
	
	Dc.w	Yes,28,16,12
	Dc.w	15,Fill
	Dc.w	16,00,12,28,16,-1
	
	Dc.w	Yes,08,04,24
	Dc.w	16,Fill
	Dc.w	04,20,24,08,04,-1

Object3	Ds.l	7000
Object4	Ds.l	7000

Object32
	Ds.l	7000

	Ds.b	2
Screen1	Ds.b	64000
Screen2	Ds.b	64000

	Ds.l	100
Ustack	

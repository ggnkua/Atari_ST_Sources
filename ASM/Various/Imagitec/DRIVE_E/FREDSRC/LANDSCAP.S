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

Num_Squares	Equ	30
Space	Equ	32
Poly_Space	Equ	2500

**********************************************************

Start	Bsr	Init			; Initialize

Main	Bsr	Wait_Vbl
	Bsr	Clear_Screen
	Bsr	Generate_Landscape
	Bsr	Add_Z	
	Bsr	Sort_List
	Bsr	Draw_Objects
	Bsr	Draw_Map_Loc
	Bsr	Swap_Screens
;	Tst.b	Key_code
	Bra.s	Main
	Bra	Out

***********************************************************
Draw_Map_Loc
	Move.l	bp(pc),a0
	Move.l	Screenp+data,a6
	Move.w	#31,d7
.Loop0	Move.w	#31,d6
	Move.w	#$8000,d5
	Pea	320(a0)
	Pea	320(a6)
	Clr.l	(a6)
	Clr.l	4(a6)
	Clr.l	8(a6)
	Clr.l	12(a6)
.Loop1	Move.b	(a0)+,d0
	Moveq	#7,d1
.Loop	Lsr.b	#1,d0
	Bcc.s	.Nx
	Or.w	d5,(a6)
.Nx	Addq.l	#2,a6
	Dbra	d1,.Loop
	Lea	-16(a6),a6
	Ror.w	#1,d5
	Bcc.s	.Dec
	Lea	16(a6),a6
	Clr.l	(a6)
	Clr.l	4(a6)
	Clr.l	8(a6)
	Clr.l	12(a6)
.Dec	Dbra	d6,.Loop1
	Move.l	(sp)+,a6
	Move.l	(sp)+,a0
	Dbra	d7,.Loop0
	Rts

Bp	Ds.l	1

***********************************************************

Generate_Landscape
	Subq.w	#1,Landscape_Y+Data
	Bne.s	.Ok
	Move.w	#199-32,Landscape_Y+Data
.Ok	
;	Subq.w	#1,Landscape_x+Data
;	Bne.s	.Ok1
;	Move.w	#320-32,Landscape_X+Data
.Ok1	Movem.w	Landscape_X+Data,d0-d1
	Mulu	#320,d1
	Add.w	d0,d1
	Lea	Mypic,a6
	Add.l	d1,a6
	Move.l	a6,Bp
	Lea	Object3,a0
	Pea	(a6)
	Move.w	#Num_Squares,d0
	Move.w	#Num_Squares,d1
	Addq.w	#1,d0
	Addq.w	#1,d1
	Mulu	d0,d1
	Move.w	d1,(a0)+
	Move.w	d0,-(sp)			Number of ys
	Move.w	#Num_Squares,d0
	Lsr.w	#1,d0
	Mulu	#Space,d0
	Neg.w	d0
.Loop0	Move.w	#Num_Squares,d1
	Move.w	#Num_Squares,d2
	Lsr.w	#1,d2
	Mulu	#Space,d2
	Neg.w	d2
	Pea	320(a6)
.Loop1	Move.w	d2,(a0)+
	Move.w	d0,(a0)+
	Moveq	#0,d3
	Move.b	(a6)+,d3
	Asl.w	#1,d3
	Move.w	d3,(a0)+
	Add.w	#Space,d2
	Dbra	d1,.Loop1
	Move.l	(sp)+,a6
	Add.w	#Space,d0
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp

	Move.w	#Num_Squares,d0
	Mulu	d0,d0
	Move.w	d0,(a0)+
	Move.w	#Num_Squares-1,d7
	Move.l	(sp)+,a6
	Moveq	#0,d0
.Xloop	Move.w	#Num_Squares-1,d6
	Pea	320(a6)
.Loop	
	Move.w	#No,(a0)+
;	Move.w	#Yes,(a0)+
;	Move.l	a0,a2
;	Addq.l	#6,a0
	Clr.b	(a0)+
	Move.b	(a6)+,(a0)+
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
;	Move.w	6(a3),(a2)+
;	Move.w	0(a3),(a2)+
;	Move.w	4(a3),(a2)+
	Dbra	d6,.Loop
	Move.l	(sp)+,a6
	Addq.w	#4,d0
	Dbra	d7,.Xloop
	Rts	

***********************************************************
Add_Z	Lea	Object_List+14+(0*64)+Data,a0
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
	Move.l	Object_Sortp+Data,a0
.Loop	Tst.b	(a0)
	Bmi	.End
	Move.l	(a0)+,a2
	Pea	(a0)
	Lea	X_Rotation+Data,A1
;	Move.w	Mouse_X,d0	
;	Move.w	Mouse_Y,d1	
;	Btst	#0,Buttons
;	Beq.s	.Ok
;	Asl.w	#4,d1
;	Add.w	d1,16(a2)
;	Add.w	d1,14(a2)
;	Bra.s	.Skip
;.Ok	Add.w	d0,2(a2)


;.Skip	And.w	#$7fe,(a2)
;	And.w	#$7fe,2(a2)
;	And.w	#$7fe,4(a2)
;	Clr.w	Mouse_X
;	Clr.w	Mouse_Y
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
	Lea	Object_Table+Data,a0		Table of colours/fills/addresses!
	Lea	Z_Coards+Data,a1			Tabke of calculated Zs
	Lea	Z_List+Data,a2			Destination for Address/avgs
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
.Loop0	Lea	Z_List+Data,a0
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

	Lea	Z_List+Data,a0
	Lea	Object_Table+Data,a1
.Loop	Move.l	(a0)+,(a1)+
	Bmi.s	.Exit
	Move.l	(a0)+,(a1)+
	Addq.l	#2,a0
	Bra.s	.Loop
.Exit	Rts

***********************************************************
Draw_The_Object
	Lea	Object_Table+Data,a0
.Loop	Move.w	(a0)+,Poly_Color+Data
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
	Lea	Perspective_Coards+Data,a3	Pointer to list of coards !
	Lea	Line_Mask,a5
	Addq.l	#2,a0
	Move.l	a0,Min_Address+Data

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

.Stop	Move.w	d3,Num_Verts+Data
	Move.w	Poly_Color+Data,d7
	Add.w	d7,d7
	Lea	Poly_Color_Table,a2
	Movem.l	(a2,d7*8),d4-d7
	Movem.l	d4-d7,-(sp)
	
	
	Subq.l	#2,a0
	Move.l	a0,Max_Address+Data
	Move.l	a1,a0
	Move.w	#-1,Clockwise_Flag+Data		& Anti!
	Clr.w	Ready_To_Exit+Data		& Boundry crossed
	Move.w	(a0),d0				Get Initial Offset
	Movem.w	(a3,d0),d0/d6			Get its X/Y
	Move.w	d6,YStart+Data
	Muls	#Byteswide,d6
	Add.l	Screenp+Data,d6
	Move.l	d6,a6				Screen position !
	Move.w	d0,d1				Same X !
	Subq.l	#2,a0
	Addq.l	#2,a1
	
.Loop1	Tst.b	Ready_To_Exit+Data
	Bne	.Exit_P
	Tst.b	Clockwise_Flag+Data		Start filling clockwise ?
	Beq.s	.No_Clock			No !
	Sf	Clockwise_Flag+Data
	Clr.l	Clock_Wise_Acc+Data		Clear the accumalator
	Cmp.l	Min_Address+Data,a0
	Bge.s	.Pos1
	Move.l	Max_Address+Data,a0
	Subq.l	#2,a0
.Pos1	Move.w	(a0),d2
	Subq.l	#2,a0
	Movem.w	(a3,d2),d2-d3			Get Coards
	Sub.w	d0,d2
	Smi	d6				Set if drawing line left !
	Bpl.s	.Pos2
	Neg.w	d2
.Pos2	Sub.w	Ystart+Data,d3			Get difference from current line!
	Bge.s	.CC1
	Moveq	#0,d3
.Cc1	Addq.w	#1,d3				Make sure at least 1
	Move.w	d3,Ycount+Data			And save it !
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
.No_N1	Move.l	d2,Clock_Wise_Add+Data		New Add !
	Subq.w	#1,Num_Verts+Data
	Sle	Ready_To_Exit+Data

.No_Clock
	Tst.b	AntiClockWise_Flag+Data
	Beq.s	.No_Anti
	Sf	AntiClockwise_Flag+Data
	Clr.l	AntiClock_Wise_Acc+Data		Same for Anticlockwise!
	Cmp.l	Max_Address+Data,a1
	Blt.s	.Pos3
	Move.l	Min_Address+Data,a1
.Pos3	Move.w	(a1)+,d2
	Movem.w	(a3,d2),d2-d3
	Sub.w	d1,d2
	Smi	d6				
	Bpl.s	.Pos4
	Neg.w	d2
.Pos4	Sub.w	Ystart+Data,d3
	Bge.s	.CC2
	Moveq	#0,d3
.Cc2	Addq.w	#1,d3
	Move.w	d3,Ycount+2+Data
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
.No_N2	Move.l	d2,AntiClock_Wise_Add+Data
	Subq.w	#1,Num_Verts+Data
	Sle	Ready_To_Exit+Data
.No_Anti

.Fill_Loop
	Cmp.l	Screenpe+Data,a6
	Bge.s	.Exit_P
	Cmp.l	Screenp+Data,a6
	Bge.s	.Ok_Draw
	Lea	Byteswide(a6),a6
	Bra.s	.Skip
.Ok_Draw	
	Movem.l	(sp),d4-d7
	Bsr.s	Draw_Horizontal_Line
.Skip	Addq.w	#1,Ystart+Data
	Movem.l	Clock_Wise_Add+Data,d4-d7
	Add.l	d4,d6
	Add.l	d5,d7
	Move.w	d6,Clock_Wise_Acc+2+Data
	Move.w	d7,AntiClock_Wise_Acc+2+Data
	Swap	d6
	Swap	d7
	Add.w	d6,d0
	Add.w	d7,d1
	Subq.w	#1,Ycount+Data
	Seq	Clockwise_Flag+Data
	Subq.w	#1,Ycount+2+Data
	Seq	AntiClockwise_Flag+Data
	Tst.b	Clockwise_Flag+Data
	Bne	.Loop1
	Tst.b	AntiClockwise_Flag+Data
	Beq.s	.Fill_Loop
	Bra	.Loop1
.Exit_P	Lea	16(sp),sp
	Rts


***********************************************************
;d0=Left X, d1=Right d4-d7=Fill pattern X a6=Line on screen !

Draw_Horizontal_Line
	Pea	Byteswide(a6)		Add and Place on stack !
	Movem.w	d0-d1,X1_Save+Data
	Cmp.w	d0,d1
	Bge.s	.Ok0
	Exg	d0,d1
.Ok0	Addq.w	#1,d1
	Move.w	#319,d2
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
.Ok4	
	Moveq	#-$10,d2
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
	Movem.w	X1_Save+Data,d0-d1
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
	Movem.w	X1_Save+Data,d0-d1
	Rts

***********************************************************

Draw_Line
	Lea	Perspective_Coards+Data,a1
	Move.w	Poly_Color+Data,d7
.Loop1	Move.w	(a0)+,d0			Vertice in d0
	Move.w	(a0),d2				Vertice to in d2 !
	Bmi.s	.Done
	Movem.w	(a1,d0),d0-d1
	Movem.w	(a1,d2),d2-d3
	Move.l	Screenp+Data,a6
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
	Move.w	-4(a0),Poly_Color+Data
	Movem.w	(a0)+,d0-d1/d6			Fill/Radius/Base coardinates
	Exg	d0,d1
	Exg	d1,d6
	Addq.l	#2,a0				Advance !
	Cmp.w	#Fill,d0
	Beq.s	.Filled_Circle
.Hold	Bra.s	.Hold

.Filled_Circle
	Lea	Z_Coards+Data,a2
	Lsr.w	#1,d6
	Add.w	d1,d1
	Mulu	(a2,d6),d1
	Swap	d1
	Move.w	d1,Circle_Radius+Data
	Beq	.Exit
	Add.w	d1,d1
	Move.w	d1,Circle_Lines+Data	
	Move.l	#1024,d0
	Divu	d1,d0
	Swap	d0
	Moveq	#0,d2
	Move.w	d0,d2
	Swap	d2
	Divu	d1,d2
	Move.w	d2,d0				d0=Sine table pointer accumalate !
	Move.l	d0,Circle_Add+Data
	Clr.l	Circle_Acc+Data
	Lea	Perspective_Coards+Data,a3
	Movem.w	(a3,d6*2),d5-d6			X/Y of this !
	Move.w	d5,CircleX+Data
	Lsr.w	#1,d1
	Sub.w	d1,d6				Start Y
	Muls	#Byteswide,d6
	Add.l	Screenp+Data,d6
	Move.l	d6,a6				Get start address
	Move.w	Poly_Color+Data,d7
	Lea	Poly_Color_Table,a2
	Add.w	d7,d7
	Movem.l	(a2,d7*8),d4-d7
	Movem.l	d4-d7,-(sp)
	Lea	Circle_Sine,a1
.Loop1	Cmp.l	Screenp+Data,a6
	Bge.s	.Skip1
	Lea	Byteswide(a6),a6
	Bra.s	.Skip2
.Skip1	Cmp.l	Screenpe+Data,a6
	Bge.s	.Re_Stack
	Move.w	Circlex+Data,d0
	Move.w	d0,d1
	Move.w	Circle_Radius+Data,d2
	Mulu	(a1),d2
	Swap	d2
	Sub.w	d2,d0
	Add.w	d2,d1
	Movem.l	(sp),d4-d7
	Bsr	Draw_Horizontal_Line
.Skip2	Move.l	Circle_Add+Data,d0
	Move.l	Circle_Acc+Data,d1
	Add.l	d0,d1
	Move.w	d1,Circle_Acc+2+Data
	Swap	d1
	Lea	(a1,d1*2),a1
	Subq.w	#1,Circle_Lines+Data
	Bne.s	.Loop1
.Re_Stack
	Lea	16(sp),sp
.Exit	Rts
	
***********************************************************
Sort_List
	Lea	Object_List+Data,a0
	Lea	Object_Sort_List+Data,a1
	Move.l	a1,Object_Sortp+Data
	Moveq	#64,d7
	Moveq	#100-1,d6
.Loop	Tst.b	(a0)
	Bmi.s	.Next_Object
	Move.l	a0,(a1)+
.Next_Object
	Add.l	d7,a0
	Dbra	d6,.Loop
	St	(a1)
	
.Loop1	Lea	Object_Sort_List+Data,a0
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
	Move.l	Screenp+Data,a0
	Moveq	#99,d7
	Movem.w	Clearr+Data,d0-d6/a1-a6
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
	Lea	Object_Table+Data,a3
	Lea	Perspective_Coards+Data,a1	Pointer for all relative stuff !
	Move.l	Surface_Pointer+Data,a0		Pointer to surface data !
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
	Bmi.s	.Find_N
.No_Hid	Move.l	(a0)+,(a3)+			Color/Type
	Move.l	a0,(a3)+			Store address of structure
.Find_N	Tst.w	(a0)+
	Bpl.s	.Find_N				Find next entry in table
	Dbra	d7,.Loop
.Exit	St	(a3)
	Rts
	
***********************************************************
Perform_Perspective
	Move.w	Num_Coards+Data,d7
	Subq.w	#1,d7
	Lea	Rotated_Coards+Data,a0
	Lea	Perspective_Coards+Data,a1
	Lea	Z_Coards+Data,a2
	Movem.l	X_Pivot+Data,d3-d5
.Loop	Movem.w	(a0)+,d0-d2			; x/y/z
	Add.w	#990,d2
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
	Move.l	Object_Use+Data,a0
	Move.w	(a0)+,d7			; Number of coardinates
	Move.w	d7,Num_Coards+Data
	Subq.w	#1,d7
	Move.w	X_Rotation+Data,d1	
	Move.w	Y_Rotation+Data,d2
	Move.w	Z_Rotation+Data,d0	
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
	Lea	Rotated_Coards+Data,a1

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
	Move.l	a0,Surface_Pointer+Data
	Rts

***********************************************************
Swap_Screens
	Movem.l	Screenpe+Data,d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenpe+Data
	Movem.l	Screenp+Data,d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenp+Data
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
Init	Lea	Data(pc),a4		; Globals
	Move.w	#-1,-(sp)
	Move.l	#Screen1,-(sp)
	Move.l	(sp),-(sp)
	Move.w	#5,-(sp)
	Trap	#14
	Lea	12(sp),sp
	Bsr	Cleardata		; Clear all globals
	Bsr	Setup_Screen_Mode	; 8 plane / overscan
	Bsr	Setup			; Supervisor + Shit
	Bsr	Set_Processor		; Set processor states
	Bsr	Savepal			; Save system pallete
	Bsr	Setup_Screens		; Clear both screens
	Bsr	Save_Vbl
	bsr	Decode_Vga
	Bsr	Vars1
	Bsr	SetPal
	Bsr	Make_Colors
	Bsr	Set_vbl			; No set  VBL interrupt
	Rts

**********************************************************
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
SetPal	Lea	Mypal,a0
	Lea	Pal256,a2
	Move.w	#255,d7
.Loop	Moveq	#0,d0
	Move.b	(a0)+,d0
	Lsl.l	#8,d0
	Move.b	(a0)+,d0
	Lsl.l	#8,d0
	Lsl.l	#8,d0
	Move.b	(a0)+,d0
	Move.l	d0,(a2)+
	Dbra	d7,.Loop
	Rts

**********************************************************
Vars1	Move.w	#160,Landscape_X+Data
	Move.w	#170,Landscape_Y+Data
	Lea	Object_List+Data,a0
	Move.w	#64*100-1,d0
.Loop	St	(a0,d0)
	Dbra	d0,.Loop
	Move.w	#$18E,(a0)+			x angle
	Move.w	#0,(a0)+			y angle
	Move.w	#0,(a0)+			z angle
	Move.l	#00,(a0)+			X pivot
	Move.l	#480,(a0)+			y Pivot
	Move.l	#$5000,(a0)+			z pivot
	Move.l	#Object3,(a0)+			Object number !
	Rts
	
**********************************************************
; According to VGA monitor
Setup_Screen_Mode	
	Bsr	Mon_Type
	Cmp.b	#2,d0			; Using VGA monitor ?
	Seq	Vga_Flag+Data		; Set if using VGA Monitor	
	Bne.s	.Not_Vga		; No !
	Move.w	#$64,Screen_Mode+Data	; Set VGA monitor bit!
	Bra.s	.Skip			; set mode anyway!
.Not_Vga 
	Move.w	#$23,Screen_Mode+Data	; Normal ST monitor 8 bpl,320x256
.Skip	Bsr	Setmode			; Set screen mode 8bps,PAL/OVERscan!
	Rts

**********************************************************
; Setup the processor!

Set_Processor
	Movec	Cacr,d0
	Move.w	d0,Cacr_Save+Data	; Save Cache Control
	Movec	Caar,d0
	Move.w	d0,Caar_Save+Data	; Save Cache Address
	Moveq	#$0,d0
	Movec	d0,Vbr			; Set Vector Base to 0!
	Rts
	
**********************************************************
; restore SYS state

Out	
;	Bsr	Hbloff
	Lea	Data(pc),a4
	Move.w	Cacr_Save+Data,d0
	Movec	d0,Cacr
	Move.w	Caar_Save+Data,d0
	Movec	d0,Caar
	
	Move.w	Mod_Save+Data,Scr_Mod
	Move.w	Del_Save+Data,Scr_Del
	Bsr	Restorepal		; Get back pallete
	Move.w	#37,-(sp)
	Trap	#1
	Addq.l	#2,sp
	Move.b	Scr_save+1+Data,$fff8201.l
	Move.b	Scr_save+2+Data,$fff8203.l
	Move.b	Scr_save+3+Data,$fff820d.l	; Set back bitplane pointers
	Move.l	Vbl_save+Data,$70.w			; Set back VBL interrupt
	Move.l	super_save+Data,-(sp)
	Move.w	#$20,-(sp)
	Trap	#1
	Addq.l	#6,sp				; User mode!

	Move.w	#%0000000010001001,Screen_Mode+Data
	Bsr	Setmode				; Set screen mode!
	Clr.l	-(sp)
	trap	#1				; Exit prog!

**********************************************************
; supervisor + save sys state!

Setup	Clr.l	-(sp)
	Move.w	#$20,-(sp)
	Trap	#1
	Addq.l	#6,sp
	move.l	d0,super_save+Data
	move	#37,-(sp)
	trap	#1
	addq.l	#2,sp
	move.b	$fff8201.l,scr_save+1+Data
	move.b	$fff8203.l,scr_save+2+Data		; Save screen addresses
	move.b	$fff820d.l,scr_save+3+Data
	rts

**********************************************************
; Save/Set Vbl
Save_Vbl
	move.l	$70.w,Vbl_save+Data	; Save vbl
	Rts
Set_Vbl	Lea	New_Vbl(pc),a0
	Move.l	a0,$70.w		; Set VBL
;	Bsr	Hblon
	Rts

**********************************************************
; All data exept SYSvars
Cleardata
	Move.l	#Varend-Sys_varse-1,d0
	Lea	Data,a4
.Loop	Clr.b	(a4)+
	Subq.l	#1,d0
	Bpl.s	.Loop			; All data cleared
	Rts	

**********************************************************
; Calculate addresses for screens + clear em

Setup_Screens
	Move.l	#64000,a6
	Move.l	a6,Screen_Size+Data
	Move.l	#Screen1,d0	
	Move.l	#Screen2,d1
	Moveq	#-4,d2			; Mask long word boundry
	And.l	d2,d0
	And.l	d2,d1
	Movem.l	d0-d1,Screenp+Data	; Save screen pointers
	Bsr	Clear_Screens
	Movem.l	Screenp+Data,d0-d1
	Add.l	#64000,d0
	Add.l	#64000,d1
	Movem.l	d0-d1,Screenpe+Data
	Move.w	Scr_Del,Del_Save+Data
	Move.w	Scr_Mod,MOD_Save+Data
	Rts

**********************************************************
; Clear both screens

Clear_Screens
	Movem.l	Screenp+Data,a0-a1
	Move.l	Screen_Size+Data,d0
	Lsr.l	#2,d0
	Subq.w	#1,d0
.Loop	Clr.l	(a0)+
	Clr.l	(a1)+
	Dbra	d0,.Loop
	Rts

**********************************************************
; Setup screen mode in SCREEN_MODE+Data
Setmode	Move.w	Screen_mode+Data,-(sp)
	Move.w	#88,-(sp)
	Trap	#14
	Addq.l	#4,sp
	Move.w	d0,Old_Mode+Data			Save the old mode!
	rts
	
**********************************************************
; Return monitor type in d0
Mon_Type
	Move.w	#89,-(sp)
	Trap	#14
	Addq.l	#2,sp
	Rts

**********************************************************
; SAVE 256 pallete

Savepal	Lea	Pal256,a0
	Lea	Sys_Pal+Data,a1
	Move.w	#256,d0
	Bsr	Quick_Copy_Long
	Rts

**********************************************************
; Restore 256 pallete
Restorepal
	Lea	Pal256,a0
	Lea	Sys_Pal+Data,a1
	Exg	a0,a1
	Move.w	#256,d0
	Bsr	Quick_Copy_Long
	Rts

***********************************************************
; Add to Vbl_Count

New4
New_Vbl	Movem.l	d0-a6,-(sp)
	Move.l	Screenp+4+Data,a0
	Bsr	Write_Screen
;	Bsr	Read_Mouse
;	Bsr	Get_Mouse	
	Lea	Data(pc),a4
	Addq.b	#1,Vbl_Flag+Data
	Movem.l	(sp)+,d0-a6
	Rte

***********************************************************
; Wait for framerate, then clear!
Wait_Vbl
	Sf	Vbl_Flag+Data
.Wait_Vbl
	Tst.b	Vbl_Flag+Data
	Beq.s	.Wait_Vbl
	Sf	Vbl_Flag+Data
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
	Move.w	d0,Handle+Data		; Save handle
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
.Loop	Movem.w	Clearr+Data,d2-d4
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
	Lea	Lbmpic,a0
	Lea	Mypal,a2
	Lea	Mypic,a1
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
;	Include	E:\Mix\Sort_00t.S

Newtb0	Rte

**********************************************************


	Rsset		0
Varstart		Rs.b	0
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
Pad			Rs.b	1	; Flag set when all sides are drawn!
Landscape_X		Rs.w	1
Landscape_Y		Rs.w	1
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
Object_Sortp		Rs.l	1	; Pointer for list pointer

Object_Sort_List	Rs.l	Poly_Space	; The list of sorted 3d Objects in list
Z_List			Rs.l	Poly_Space

Rotated_Coards		Rs.w	3*Poly_Space	; 3d Rotated coardinates
Perspective_Coards 	Rs.w	2*Poly_Space	; Perspective cacled x/ys
Z_Coards		Rs.w	1*Poly_Space	; Perspective calced Zs
Object_Table		Rs.w	4*Poly_Space	; List of Type/Color/Pointer of object to draw.
Object_List		Rs.b	64*Poly_Space	; Infos about objects to be reckoned with

Varend			Rs.b	0

Data	Ds.b	Varend-Varstart

	Even

Line_Mask
	Dc.l	$00000000,$80008000,$c000c000,$e000e000
	Dc.l	$f000f000,$f800f800,$fc00fc00,$fe00fe00
	Dc.l	$ff00ff00,$ff80ff80,$ffc0ffc0,$ffe0ffe0
	Dc.l	$fff0fff0,$fff8fff8,$fffcfffc,$fffefffe
	
MyPal	Ds.b	3*256
	Even
Poly_color_Table
	Ds.w	8*256

Sine	Include	Wx.inc			1024 VALUES + COS EXT.
Sinee	Even
Circle_Sine	Incbin	Circ.Sin
Circle_Sinee	Even

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


LbmPic	Incbin	lbms\idl-Logo.Lbm
	even
MyPic	Ds.b	64000
	Even
Object3	Ds.l	29000
	
	Ds.b	2
Screen1	Ds.b	64000
Screen2	Ds.b	64000

 
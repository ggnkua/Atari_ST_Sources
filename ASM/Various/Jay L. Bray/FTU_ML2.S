	
	opt c-
	opt o+	; Optimise Code...
	
	Format

	xdef	Shrink_S
	xdef	Draw_Six
	xdef	Get_Usr
	xdef	Put_Usr
	xdef	ItoL
	xdef	LtoI
	xdef  Peek
	xdef	WPeek
	xdef	WPoke
	xdef	LPeek
	xdef	LPoke
	xdef	Save5
	xdef	Rest5
	xdef	Clear5
	xdef	B_Col
	xdef	T_Col
	xdef	Y_Pos
	xdef	X_Pos
	xdef  Fsel_In
	xdef	Get_BTD
	xdef	Set_BTD
	xdef	Mouse_On
	xdef	Mouse_Off
	xdef	Chk_CarrierP
	xdef	Get_TimerP
	xdef	Zero_TimerP
	xdef	PauseP
	xdef	Hang_UpP
	xdef	Bit_Test
	xdef	Bit_Set
	xdef	Bit_Clr
	xdef	Drive_Exist
	xdef	Turbo_On
	xdef	Turbo_Off

StVec		equ		12
ClkVec	equ		20
TimeOut equ		-1
Bksp    equ		8
Cr      equ		13
Lf      equ		10
Esc     equ		27
Bell    equ		7

Modem   equ		1
Console equ		2
		
	Text

Shrink_S:
	move.l		(a7)+,Pas_Save
	move.w		(a7)+,d5
	move.w		(a7)+,d4
	dc.w			$A000        ; get the important pointers
	cmp.w			#2,d5
	bne.s			SS0
	movea.l		8(a1),a1     ; a1 -> 8x16 Font header
	bra.s			SS1
SS0:	
	movea.l		4(a1),a1     ; a1 -> 8x8  Font header
SS1:
	clr.l			d0
	clr.l			d1
	move.w		82(a1),d0    ; Formheight, height of char
	move.w		d0,-46(a0)   ; cell height
	move.w		2(a0),d1		 ; bytes per screen line
	mulu			d0,d1        ; times height of char
	move.w		d1,-40(a0)   ; Yeilds bytes per char line
	moveq.l		#0,d1
	move.w		-4(a0),d1    ; # of raster lines on screen
	divu	 		d0,d1        ; divide by font height
	sub.w			d4,d1        ; Minus Lines to Shrink
	move.w		d1,-42(a0)   ; Yeilds Max Curs Line
	moveq.l		#0,d1
	move.w		-12(a0),d1   ; screen width in bytes
	divu	 		52(a1),d1    ; divide by max char width
	subq.w		#1,d1        ; Minus 1
	move.w		d1,-44(a0)   ; Yeilds Max Curs Column
	move.w		#6,80(a0)
	move.w		80(a1),-14(a0) ; Formwidth, width of font
	move.w		36(a1),-16(a0) ; Smallest Ascii code in font
	move.w		38(a1),-18(a0) ; Largest Ascii Code In Font
	move.l		76(a1),-22(a0) ; v-fnt_ad <- Pointer to Font Data
	move.l		72(a1),-10(a0) ; v_off_Ad <- Pointer to offset table addr
	move.w		#0,70(a0)
	move.l		Pas_Save,-(a7)
	rts

ItoL:
	clr.l			d0
	move.l		(a7)+,d6
	move.w		(a7)+,d0
	move.l		d6,-(a7)
	rts

LtoI:
	clr.l			d0
	move.l		(a7)+,d6
	move.l		(a7)+,d1
	move.l		d6,-(a7)
	move.w		d1,d0
	rts
		 
Draw_Six:
	 moveq.l	#0,d0
	 moveq.l	#0,d3
	 move.l		(a7)+,d6
	 move.l		(a7)+,a4    ; String
	 move.w		(a7)+,B_Col ; Background Color
	 move.w		(a7)+,T_Col ; Text Color
	 move.w		(a7)+,d1    ; Y - Offset
	 move.w		(a7)+,Y_Pos ; y
	 move			Y_Pos,d0
	 mulu	 		#6,d0
	 add.w		d1,d0
	 move.w		d0,Y_Pos
	 move.w		(a7)+,d0	; x
	 mulu	 		#6,d0
	 addq.w		#1,d0
	 move.w		d0,X_Pos
	 move.w		(a7)+,d5
	 move.l		d6,-(a7)
	 dc.w	 		$a000
	 move.l		a0,a5
	 movea.l	(a1),a2       ; a2 holds first fontheader address
	 move.l		76(a2),84(a5) ; move font data address into line A
	 move.w		80(a2),88(a5) ; move font width value
	 move.w		52(a2),80(a5)
	 move.w		82(a2),82(a5)
	 move.w		#1,102(a5)
	 move.w		#1,68(a5)     ; set text for enlargment
	 move.w		#$8000,64(a5) ; must be set for a textblt ?
	 move.w		d5,36(a5)     ; Set WRITE MODE if flag = 0
	 move.b		(a4)+,d3      ; Length Of String...
	 subq.b		#2,d3
doit:
	 move.w		X_Pos,76(a5)  ; select screen x-loc
	 move.w		Y_Pos,78(a5)  ; select screen y-loc
	 move.w		T_Col,106(a5) ; Text Color
	 move.w		B_Col,114(a5) ; Background Color
	 clr.l		d2
	 move.b		(a4)+,d2
	 mulu	 		#6,d2
	 move.w		d2,72(a5)
	 dc.w	 		$a008			; Do a textblt operation
	 addq.w		#6,X_Pos
	 dbra	 		d3,doit
done:
	 rts

Get_Screen:
	move.w	#3,-(a7)
	trap		#14
	addq.l	#2,a7
	move.l	d0,Screen
	rts

Screen:		dc.l	0
	
Get_Rez:
	move.w	#3,-(a7)
	trap		#14
	addq.l	#2,a7   ; D0 Returns:  0=Low, 1-Med, 2-High
	rts

Save5:
		move.l	(a7)+,d6
		bsr.s		Get_Screen
		move.l	d0,a0
		Add.l		#25600,a0
		move.l	#S_Five,a1
		move.w	#1599,d5
Sv5:
		move.l	(a0)+,(a1)+
		dbf			d5,Sv5
		move.l	d6,-(a7)
		rts

Rest5:
		move.l	(a7)+,d6
		bsr.s		Get_Screen
		move.l	d0,a1
		Add.l		#25600,a1
		move.l	#S_Five,a0
		move.w	#1599,d5
Rs5:
		move.l	(a0)+,(a1)+
		dbf			d5,Rs5
		move.l	#S_Five,a1
		move.l	d6,-(a7)
		rts

Clear5:
		move.l	(a7)+,d6
		bsr.s		Get_Screen
		move.l	d0,a0
		Add.l		#25600,a0
		move.w	#1599,d5
Cl5:
		move.l	#-1,(a0)+
		dbf			d5,Cl5
		move.l	d6,-(a7)
		rts

Peek:
		move.l	(a7)+,d6
		move.l	(a7)+,a4
		Clr.l		d0
		move.b	(a4),d0
		move.l	d6,-(a7)
		rts

WPeek:
		move.l	(a7)+,d6
		move.l	(a7)+,a4
		Clr.l		d0
		move.w	(a4),d0
		move.l	d6,-(a7)
		rts

WPoke:
		move.l	(a7)+,d6
		move.w	(a7)+,d0
		move.l	(a7)+,a4
		move.w	d0,(a4)
		move.l	d6,-(a7)
		rts

LPeek:
		move.l	(a7)+,d6
		move.l	(a7)+,a4
		Clr.l		d0
		move.l	(a4),d0
		move.l	d6,-(a7)
		rts
		
LPoke:
		move.l	(a7)+,d6
		move.l	(a7)+,d4
		move.l	(a7)+,a4
		move.l	d4,(a4)
		move.l	d6,-(a7)
		rts

Move_Long:
		move.l	(a7)+,d6
		move.l	(a7)+,d1	;	Size
		move.l	(a7)+,a2	;	Dest
		move.l	(a7)+,a1	;	Source
Mv_L1:
		move.l	(a1)+,(a2)+
		dbra		d1,Mv_L1
		move.l	d6,-(a7)
		rts

Get_Usr:
Put_Usr:
		move.l	(a7)+,d6
		move.l	(a7)+,d1	;	Size
		move.l	(a7)+,a1	;	Source
		move.l	(a7)+,a2	;	Dest
Gt_U1:
		move.b	(a1)+,(a2)+
		dbf			d1,Gt_U1
		move.l	d6,-(a7)
		rts

Fsel_In:
	move.l	(a7)+,Pas_Save
	move.l	(a7)+,Addr_In
	move.l	(a7)+,Addr_In+4
	move.w	#90,OpCode
	move.w	#0,OpCode+2
	move.w	#2,OpCode+4
	move.w	#2,OpCode+6
	bsr			Aes
	move.w	Int_Out+2,d0
	move.l		Pas_Save,-(a7)
	rts

Mouse_On:
	move.l	(a7)+,Pas_Save
	dc.w		$a000
	move.l	4(a0),a1
	move.w	#0,(a1)
	move.w	#1,6(a1)
	move.l	8(a0),a1
	move.w	#0,(a1)
	dc.w		$A009
	move.l		Pas_Save,-(a7)
	rts

Mouse_Off:
	move.l	(a7)+,Pas_Save
	dc.w		$A00A
	move.l	Pas_Save,-(a7)
	rts

Get_BTD:
	move.l	(a7)+,Pas_Save
	move.w	(a7)+,Mode
	bsr.b		Get_TD
	cmp.w		#1,Mode
	beq.b		Get_Time
	move.l	Date,d0
	bra.b		GExit
Get_Time:
	move.l	Time,d0
GExit:
	move.l	Pas_Save,-(a7)
	rts
		
Set_BTD:
	move.l	(a7)+,Pas_Save
	move.w	(a7)+,Mode
	cmp.w		#1,Mode
	beq.b		Set_Time
	move.l	(a7)+,Date
	move.l	#$ffffff,Time
	bra.b		SExit
Set_Time:
	move.l	(a7)+,Time
	move.l	#$ffffff,Date
SExit:
	bsr.b		Set_TD
	move.l		Pas_Save,-(a7)
	rts

Set_TD:
	move.b	#$1B,TBuf
	bsr			TD_TBuf
	bsr.b		Send_SCmd

Get_TD:
	move.b	#$1C,TBuf
	bsr.b		Init_TD
	bsr.b		Send_GCmd
	bsr			RBuf_TD
	rts

Init_TD:
	move.w	#34,-(a7)
	trap		#14
	addq.l	#2,a7
	move.l	#0,a0
	lea			KeyIn,a1
	move.l	d0,SaveA
	rts

Send_GCmd:
	move.l	ClkVec(a0,d0),Save
	move.l	a1,ClkVec(a0,d0)
	move.b	#-1,RBuf
	pea			TBuf
	move.w	#0,-(a7)
	move.w	#25,-(a7)
	trap		#14
	adda.l	#$8,a7
GWAIT:
	cmpi.b	#$FF,RBUF
	beq.b		GWAIT
	movea.l	SAVEA,a0
	move.l	SAVE,$14(a0)
	rts

Send_SCmd:
	pea			TBUF
	move.w	#6,-(a7)
	move.w	#25,-(a7)
	trap		#14
	adda.l	#8,a7
	rts

TD_TBUF:
	lea			TBuf,a0
	move.b	Time+3,d0
	bsr.s			BINBCD
	move.b	Time+2,d0
	bsr.s			BINBCD
	move.b	Time+1,d0
	bsr.s			BINBCD
	move.b	Date+3,d0
	bsr.s			BINBCD
	move.b	Date+2,d0
	bsr.s			BINBCD
	move.b	Date+1,d0
	bsr.s			BINBCD
	rts

RBUF_TD:
	lea			RBUF,a0
	bsr.s			BCDBIN
	move.b	d0,Date+1
	bsr.s			BCDBIN
	move.b	d0,Date+2
	bsr.s			BCDBIN
	move.b	d0,Date+3
	bsr.s			BCDBIN
	move.b	d0,Time+1
	bsr.s			BCDBIN
	move.b	d0,Time+2
	bsr.s			BCDBIN
	move.b	d0,Time+3
	rts

BINBCD:
	cmp.b		#$FF,d0
	beq.s			BB3
	moveq		#$0,d1
	moveq		#$A,d3
BB1:
	sub.b		d3,d0
	bmi.s			BB2
	addq.b	#1,d1
	bra.b		BB1
BB2:
	addi.b	#$A,d0
	asl.b		#4,d1
	add.b		d1,d0
BB3:
	move.b	d0,-(a0)
	rts

BCDBIN:
	moveq		#$0,d0
	move.b	(a0),d0
	lsr.b		#4,d0
	lsl.b		#1,d0
	move.b	d0,d1
	asl.b		#2,d0
	add.b		d1,d0
	move.b	(a0)+,d1
	andi.w	#$F,d1
	add.w		d1,d0
	rts

KEYIN:
	move.b	#$8,d0
	lea			RBUF,a1
REPIN:
	move.b	(a0)+,(a1)+
	subq.b	#1,d0
	bne.b		REPIN
	rts

Aes:
	move.l	#Aes_Parms,d1
	move.w	#200,d0
	trap		#2
	move.w	int_out,d0
	rts

Hang_UpP:
	move.l		(a7)+,Pas_Save
	bsr.s				Hang_Up
	move.l		Pas_Save,-(a7)
	rts

Hang_Up:
	move.w   #16,-(a7)
	move.w   #30,-(a7)
	trap     #14              ; Drop DTR Line...
	addq.l   #4,a7
Hang1:
	move.w   #1000,Jiffies
	bsr.s      Pause
	move.w   #6,-(a7)
	move.w   #29,-(a7)
	trap     #14              ; Raise DTR Line...
	addq.l   #4,a7
	rts

PauseP:
	 move.l		(a7)+,Pas_Save
	 move.w		(a7)+,Jiffies
	 bsr.b		Pause
	 move.l		Pas_Save,-(a7)
	 rts


Pause:
	bsr.s   Get_Timer
	move.l  Timer,d0
	clr.l   d1
	move.w  Jiffies,d1
	add.l   d1,d0
	move.l  d0,Max_Time
Pause2:
	bsr.s   Get_Timer
	move.l  Timer,d0
	cmp.l   Max_Time,d0
	blt.s   Pause2
	rts

Lower_C:
	move.w		Char,d0
  cmp.w   	#'Z',d0
  bgt.s     	Lc1
  cmp.w   	#'A',d0
  blt.s     	Lc1
  add.w   	#32,d0
  move.w  	d0,Char
Lc1:
	rts

Upper_C:
	move.w		Char,d0
	cmp.w			#'z',d0
	bgt.s				Uc1
	cmp.w			#'a',d0
	blt.s				Uc1
	sub.w			#32,d0
	move.w		d0,Char
Uc1:
	rts

Get_TimerP:
	move.l		(a7)+,Pas_Save
	bsr.b			Get_Timer
	move.l		Pas_Save,-(a7)
	move.l		Timer,d0
	rts

Get_Timer:
	bsr				Super_On
	move.l  	$4BA.w,Timer
	bsr				Super_Off
	rts

Zero_TimerP:
	move.l		(a7)+,Pas_Save
	bsr.b			Zero_Timer
	move.l		Pas_Save,-(a7)
	rts

Zero_Timer:
	bsr				Super_On
	move.l		#1,$4ba.w
	bsr				Super_Off
	rts

Chk_CarrierP:
	move.l		(a7)+,Pas_Save
	move.w		(a7)+,Local
	bsr.s			Chk_Carrier
	move.w		Carrier,d0
	move.l		Pas_Save,-(a7)
	rts

Chk_Carrier:
	move.w   #0,Carrier
	cmp.w    #1,Local         ; If We're in local mode
	beq.s    Carr_1           ;  We won't test for a carrier
	bsr			Super_On
  move.l   #$fffa01,a1
  move.b   (a1),d1
	bsr			Super_Off
  and.b    #2,d1
  cmp.b    #0,d1            ; 0 = Carrier Present
  bne.s    Carr_2
Carr_1:
  move.w   #1,Carrier       ; Say That We Have A Carrier
Carr_2:
  rts

Bit_Test:
	move.l		(a7)+,Pas_Save
	clr.l			d2
	move.w		(a7)+,d2
	move.l		(a7)+,d1
	move.w		#1,d0
	btst			d2,d1
	bne.b			Btt1
	move.w		#0,d0
Btt1:
	move.l		Pas_Save,-(a7)
	rts

Bit_Set:
	move.l		(a7)+,Pas_Save
	move.w		(a7)+,d2
	move.l		(a7)+,a1
	move.l		(a1),d1
	bset			d2,d1
	move.l		d1,(a1)
	move.l		Pas_Save,-(a7)
	rts

Bit_Clr:
	move.l		(a7)+,Pas_Save
	move.w		(a7)+,d2
	move.l		(a7)+,a1
	move.l		(a1),d1
	bclr			d2,d1
	move.l		d1,(a1)
	move.l		Pas_Save,-(a7)
	rts

Drive_Exist:
	move.l		(a7)+,Pas_Save
	move.w		(a7)+,Drv
	bsr				Super_On
	move.l		$4c2.w,d2          ; drvbits
	move.w		$4a6.w,d1          ; nflops
	bsr				Super_Off
	move.w		#0,Drv_Ok
	cmp.w			#0,Drv      ; Logical Drive 'A'
	blt.b			De3
	cmp.w			#15,Drv     ; Logical Drive 'P'
	bgt.b			De3
	cmp.w			#1,Drv      ; If Drv <=1 Then Check Actual Floppies
	bgt.b			De1         ;   Else we're checking hard drives...
	addq.w		#1,Drv
	cmp.w			Drv,d1
	blt.b			De3
	bra.b			De2
De1:
	move.w		Drv,d1
	btst			d1,d2
	beq.b			De3
De2:
	move.w		#1,Drv_Ok  ; Say Drive Exists
De3:
	move.l		Pas_Save,-(a7)
	move.w		Drv_Ok,d0
	rts

Turbo_On:
	move.l		(a7)+,Pas_Save
	bsr.s				Super_On
	bset			#7,$fffa29
	bsr.s				Super_Off
	move.l		Pas_Save,-(a7)
	rts

Turbo_Off:
	move.l		(a7)+,Pas_Save
	bsr.s				Super_On
	bclr			#7,$fffa29
	bsr.s				Super_Off
	move.l		Pas_Save,-(a7)
	rts

Supexec:
	movem.l		a1-a6/d1-d6,-(a7)
	move.l		a0,-(a7)         ; a0 points to routine
	move.w		#38,-(a7)
	trap			#14
	addq.l		#6,sp
	movem.l		(a7)+,a1-a6/d1-d6
	rts

Super_On:
	movem.l		a0-a6/d0-d7,-(a7)
	clr.l			-(a7)
	move.w		#$20,-(a7)
	trap			#1
	addq.l		#6,a7
	move.l		d0,Save_SSP
	movem.l		(a7)+,a0-a6/d0-d7
	rts

Super_Off:
	movem.l		a0-a6/d0-d7,-(a7)
	move.l		Save_SSP,-(a7)
	move.w		#$20,-(a7)
	trap			#1
	addq.l		#6,a7
	movem.l		(a7)+,a0-a6/d0-d7
	rts

Scan_Console:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   #0,Fnct_Key
     move.w   #2,-(a7)
     move.w   #1,-(a7)
     trap     #13
     addq.l   #4,a7
     movem.l  (a7)+,a0-a2/d1-d4
     tst.l    d0
     bpl.s    Skip_Con
Get_Console:
     movem.l  a0-a3/d1-d4,-(a7)
     move.w   #2,-(a7)
     move.w   #2,-(a7)
     trap     #13
     addq.l   #4,a7
     swap     d0
     move.w   d0,Fnct_Key
     swap     d0
     move.w   d0,Char
     movem.l  (a7)+,a0-a3/d1-d4
     rts

Skip_Con:
     move.w   #0,D0
     rts

Put_Console:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   Char,-(a7)
     move.w   #2,-(a7)
     move.w   #3,-(a7)
     trap     #13
     addq.l   #6,a7
     movem.l  (a7)+,a0-a2/d1-d4
     rts

Put_Modem:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   Char,-(a7)
     move.w   #1,-(a7)
     move.w   #3,-(a7)
     trap     #13
     addq.l   #6,a7
     movem.l  (a7)+,a0-a2/d1-d4
     rts

Scan_Modem:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   #1,-(a7)
     move.w   #1,-(a7)
     trap     #13
     addq.l   #4,a7
     movem.l  (a7)+,a0-a2/d1-d4
     tst.l    d0
     bpl.s    Skip_Modem
Get_Modem:
     movem.l  a0-a2/d1-d4,-(a7)
     move.w   #1,-(a7)
     move.w   #2,-(a7)
     trap     #13
     addq.l   #4,a7
     move.w   d0,Char
     movem.l  (a7)+,a0-a2/d1-d4
     rts

Skip_Modem:
     move.w   #0,d0
     move.w   d0,Char
     rts

Put_Char:
	bsr.b			Put_Console
	cmp.w			#1,Local
	beq.b			PC1
	bsr.b			Put_Modem
PC1:
	rts

CrLf:
	move.w		#Cr,Char
	bsr.b			Put_Char
	rts

Back_Space:
     move.w   #Bksp,Char
     bsr.b    Put_Char
     move.w   #32,Char
     bsr.b    Put_Char
     move.w   #Bksp,Char
     bsr.b    Put_Char
     rts

Line_In:
     movem.l  a4/a6/d5,-(a7)
     bsr      Flush_Inp
     move.l   #LineIn,a4        ; Clean up Text Area..
     moveq.l   #20,d5
LI1: move.l   #0,(a4)+
     dbra     d5,LI1

     move.l   #LineIn,a4
     move.l   Length,d5
     move.w   d5,Count
Lin_1:
     move.w   #0,Echo
     move.w   #1,No_Show
     bsr      Get_Char
     cmp.w    #0,Carrier
     beq.s      Lin_Xit
     cmp.w    #Cr,Char
     bne.s      Lin_2
     move.b   #Cr,(a4)+
     bra.s    Lin_Xit
Lin_2:
     cmp.w    #Bksp,Char
     bne.s      Lin_4
     cmp.w    Count,d5
     beq.b    Lin_1
     cmp.w    #1,Count
     beq.b    Lin_Xit
     bsr		Back_Space
     subq.l    #1,a4
     addq.w    #1,Count
     bra.s    Lin_1
Lin_4:
     cmp.w    #" ",Char
     bcs.b    Lin_1
     cmp.w    #"~",Char
     bhi.b    Lin_1
     bsr      Put_Char
     move.b   Char+1,(a4)+
     subq.w    #1,count
     cmp.w    #0,Count
     bne      Lin_1
Lin_Xit:
     move.w   #0,No_Show
     movem.l  (a7)+,a4/a6/d5
     rts

Line_Out:
     bsr.s      String_Out
     bsr      CrLf
     rts

String_Out:
     movem.l  a1/a6/d5,-(a7)
     move.l   Text_Adr,a6
So1: move.w   #0,Char
     move.b   (a6)+,Char+1
     cmp.w    #Cr,Char
     bne.s      So2
     bsr      CrLf
     move.b   (a6)+,d0         ; Get rid of Lf
     bra.s    So1
So2:
     cmp.w    #160,Char
     bne.s      So2a
     cmp.w    #40,Video_Width
     bne.s      So2a
     bsr      CrLf
     bra.s    So1
So2a:
     cmp.w    #Lf,Char
     beq.b    So1
     cmp.w    #0,Char
     beq.s      So_Xit
     bsr      Put_Char
     bra.b    So1
So_Xit:
     movem.l  (a7)+,a1/a6/d5
     rts

Call_Chat:
     move.l   d5,-(a7)
     move.l   #Call_Msg,Text_Adr
     bsr.b    String_Out
     moveq.l   #25,d5
Cl_Cht1:
     move.l   #Page_Msg,Text_Adr
     bsr.s      String_Out
     move.w   #50,Jiffies
     bsr      Pause
     bsr      Scan_Console
     cmp.w    #$3f,Fnct_Key    ; F5
     bne.s      Cl_Cht2
     bsr.s      Chat_Mode
     bra.s    Cl_Cht_Xit
Cl_Cht2:
     dbra     d5,Cl_Cht1
     move.l   #No_Ans_Msg,Text_Adr
     bsr      Line_Out
Cl_Cht_Xit:
     bsr      CrLf
     move.l   (a7)+,d5
     rts

Chat_Mode:
     move.w   #0,Echo
     move.w   #0,Caps
     move.l   #Chat_Entr_Msg,Text_Adr
     bsr      Line_Out
     bsr      Flush_Inp
Chat_0:
     cmp.w    #1,Word_Pending
     bne.s      Chat_1
     move.l   #Word_Temp,Text_Adr
     bsr      String_Out
     move.w   #0,Word_Pending
     move.w   Ky_Cnt,Char_No
     move.w   #0,Ky_Cnt
     move.l   #Word_Temp,a5
     bra.s    Chat_1a
Chat_1:
     move.l   #Word_Temp,a5
     move.w   #0,Ky_Cnt        ; # of Chars in Word
     move.w   #0,Char_No       ; # of Chars in Line
Chat_1a:
     bsr      Get_Chat_Char
     cmp.w    #0,Carrier
     beq      Chat_Xit
     cmp.w    #$3f,Fnct_Key    ; Norml - F5    Exit Chat
     beq      Chat_Xit
     cmp.w    #$5d,Fnct_Key    ; Shift - F10   Hang Up
     bne.s      Chat_2
     bsr      Hang_Up
     bra      Chat_Xit
Chat_2:
     cmp.w    #0,Carrier
     beq      Chat_Xit
     cmp.w    #Cr,Char
     beq      Chat_9
     cmp.w    #Bksp,Char
     bne.s      Chat_7
     cmp.w    #0,Char_No
     beq.b    Chat_1a
Chat_3:
     bsr      Back_Space
     subq.w    #1,Char_No
     subq.l    #1,a5
     subq.w    #1,Ky_Cnt
     bra.b    Chat_1a
Chat_7:
     cmp.w    #" ",Char
     bne.s      Chat_7a
     move.w   #0,Ky_Cnt
     move.l   #Word_Temp,a5
Chat_7a:
     move.b   Char+1,(a5)
     addq.l    #1,a5
     addq.w    #1,Ky_Cnt
     addq.w    #1,Char_No
     move.w   Video_Width,d0
     subq.w    #1,d0
     cmp.w    Ky_Cnt,d0
     beq.s      Chat_7b
     cmp.w    Char_No,d0
     beq.s      Chat_8
     bsr      Put_Char
     bra      Chat_1a
Chat_7b:
     move.b   #0,(a5)
     bra.s    Chat_9
Chat_8:
     move.b   #0,(a5)
     clr.l    d6
     move.w   Ky_Cnt,d6
     subq.w    #1,d6
Chat_8a:
     bsr      Back_Space
     dbra     d6,Chat_8a
     move.w   #1,Word_Pending
Chat_9:
     bsr      CrLf
     bra      Chat_0
Chat_Xit:
     move.l   #Chat_Exit_Msg,Text_Adr
     bsr      Line_Out
     rts

Get_Chat_Char:
     BSR      CHK_CARRIER
     cmp.w    #0,Carrier
     beq.s      Gt_CC_Xit
     bsr      Scan_Console
     cmp.w    #0,d0
     bne.s      Gt_CC_Xit
     cmp.w    #0,Fnct_Key
     bne.s     Gt_CC_Xit
     bsr      Scan_Modem
     cmp.w    #0,d0
     beq.b    Get_Chat_Char
Gt_CC_Xit:
     rts

Flush_Inp:
fl1: bsr      Scan_Modem
     cmp.w    #0,d0
     bne.b    fl1
fl2: bsr      Scan_Console
     cmp.w    #0,d0
     bne.b    fl2
fl3:
     rts

Get_Char:                      ; Registers a5-a6 saved...
     movem.l  a5-a6,-(a7)
     bsr.b    Flush_Inp
     bsr      Get_Timer
     move.l   Timer,a6
     add.l    #36000,a6
Get_Char1:
     bsr      Get_Timer
     move.l   Timer,a5
     cmp.l    a5,a6
     blt.s      Gt_Cto
     bsr      Chk_Carrier
     cmp.w    #1,Carrier
     beq.s      Gc00
     bra.s      Gc09
Gt_Cto:
     bsr      Hang_Up       ; Disconnect user if 3 minutes
     move.w   #0,Carrier    ; Has lapsed since last keystroke...
     move.w   #TimeOut,Char
     bra.s      Gc09
Gc00:
     bsr      Scan_Console
     cmp.w    #0,d0
     beq.b    Gc01
     cmp.w    #0,Fnct_Key
     bne.s 	    Gf_01
     beq.s      Gc03
Gc01:
     bsr      Scan_Modem
     cmp.w    #0,d0
     beq.b    Get_Char1
Gf_01:
     cmp.w    #$5d,Fnct_Key    ; Shift - F10
     bne.s      Gf_02
     bsr	    Hang_Up
     bra.s      Gc09
Gf_02:
     cmp.w    #$3f,Fnct_Key    ; F5
     bne.s      Gf_03
     bsr      Chat_Mode
     bra.s      Gc09
Gf_03:
     bra.s	    Get_Char1
Gc03:
     cmp.w    #1,Caps          ; Do we want Caps Only?
     bne.s      Gc06
     bsr      Upper_C
Gc06:
     move.w   Char,d0
Gc09:
;     bsr      Show_TD
     movem.l  (a7)+,a5-a6
     rts

	Data


TBuf:				dc.b	0,0,0,0,0,0,0,0
RBuf:				dc.b	0,0,0,0,0,0,0,0
Date:				dc.l	0
Time:				dc.l	0
Save:				dc.l	0
Savea:			dc.l	0
Pas_Save:		dc.l	0
Mode:				dc.w	0
Save_SSP:		dc.l	0
Drv:				dc.w	0
Drv_Ok:			dc.w	0
B_Col: 				dc.w	0
T_Col: 				dc.w	0
Y_Pos: 				dc.w	0
X_Pos: 				dc.w	0
Jiffies:			dc.w	0	
Local:				dc.w	0
Ring:					dc.w	0
Video_Width:	dc.w	80
No_Show:			dc.w	0
Echo:					dc.w	1
Carrier:			dc.w	0
Fnct_Key:			dc.w	0
Count:				dc.w	0
Word_Pending:	dc.w  0
Char_Cnt:			dc.w  0
Char_No:			dc.w  0
Char:					dc.w  0
Caps:					dc.w  0
Ky_Cnt:				dc.w  0
Timer:				dc.l	0
Max_Time:			dc.l	0
Length:				dc.l	0
Text_Adr:			dc.l	0
Word_Temp:		dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
LineIn:				dc.l  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

Call_Msg:			dc.b  Cr,Lf,"Paging SysOp ",0

No_Ans_Msg:		dc.b  Cr,Lf,"  Sorry! The SysOp Doesn't Answer,",160
              dc.b  "  Please Try Again Later...",0,0

Page_Msg:			dc.b  7,"*",0,0

Chat_Entr_Msg:	dc.b  Cr,Lf," SysOp Entering Chat Mode...",Cr,Lf,0,0
Chat_Exit_Msg:	dc.b  " You Are Now Back In Control...",Cr,Lf,0

Aes_Parms:	dc.l	Control,Global,Int_In,Int_Out,Addr_In,Addr_Out
Control:
OpCode:		dc.w	0
SIntIn:		dc.w	0
SIntOut:	dc.w	0
SAddrIn:	dc.w	0
SAddrOut:	dc.l	0
					dc.w	0,0,0,0,0

Global:			dc.w	14
ApVersion:	dc.w	0
ApCount:		dc.w	0
ApId:				dc.w	0
ApPrivate:	dc.l	0
AppTree:		dc.l	0
Ap1Resv:		dc.l	0
Ap2Resv:		dc.l	0
Ap3Resv:		dc.l	0
Ap4Resv:		dc.l	0
Int_in:			dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Int_out:		dc.w	0,0,0,0,0,0,0
Addr_in:		dc.l	0,0,0
Addr_out:		dc.l	0

	Bss
	
S_Five:			ds.b	6400

	End
		

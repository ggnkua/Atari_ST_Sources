  
	Rsreset
Spr_Use		Rs.w	1
Spr_Yadd	Rs.w	1
spr_Addr	Rs.l	1		; Weapon sprite structure
Spr_Height	Rs.w	1
Spr_Plane	Rs.w	1
Spr_Width	Rs.w	1
Rmask		Rs.w	1
Spr_E		Rs.w	0

Auto=1
Record=0

Wait	Macro
	Dc.w	0,\1		COMM+FRame count
	Endm
Special_Sequence	Macro
	Dc.w	1		Special anim !
	Dc.l	\1
	Endm
Exit_Script	Macro
	Dc.w	2
	Endm
Move_R	Macro
	Dc.w	3,\1,\2,\3
	Endm
Init_Sequence	Macro
	Dc.w	4
	Dc.l	\1
	Endm
Init_Randolf	Macro
	Dc.w	5
	Endm

Wait_Move	Macro
	Dc.w	6
	Endm

Spit_Do		Macro
	Dc.w	7
	Endm
Start_Billy	Macro
	Dc.w	8
	Endm

Do_Bird	Macro
	Dc.w	9
	Endm
Start_Walking_Towards_Door	Macro
	Dc.w	10
	Endm
Test_Exit_Script		Macro
	Dc.w	11
	Endm
Init_Rany		Macro
	Dc.w	12
	Endm


Rope_X_Pos=216
Rope_Y_Pos=4
Mask_Line=56
Mask_Height=65
Right_Max_Anim=6
Mask_Start=65
Panel_Width=336
Actual_Screen_Width=320
Width_Of_Randolf=48
Height_Of_Randolf=55
Randolf_Height=55
Byteswide=960
Screenwide=336

MakeDisk=0

Panel_Height=41
Display_Height=200-41
Split_Time=200-Panel_Height
Screen_Height=200-Panel_Height+8
Min_Map_X=124
Map_Height=200
Fire_Anim_Size=12288
Fire_X_Pos=756-16
Fire_Y_Pos=48


	Include	E:\INCLUDES\SYSTREGS.INC
	Include	MACROS.S
	Ifeq	Makedisk
	Include	Spool.s
	Endc
Frame_Rate	Equ	3

Start	
	Ifne	Makedisk
	Move.l	a7,Stacksave
	Endc
	Jsr	Go
	Clr.w	-(sp)
	Trap	#1
stacksave	Ds.l	1
	Include	E:\INCLUDES\AnimRepl.s
	Include	E:\INCLUDES\New_key1.s
Go	
	Ifeq	Makedisk
	Move.l	a7,Stacksave
	Endc

	Bsr	Init			; Initialize

Main	
;	Bra	Skipo

	Bsr	Wait_Vbl
	St	Fire_Anim_Flag(a4)
	Bsr	Go_Mouse
	st	Flag_For_Text(a4)

	Bsr	Init_Walkabout
	Bsr	Walk_About_Part1
	Bsr	Fade_Down_Screen
	Bsr	Terminal_Part1
	Bsr	Go_Mouse

	Bsr	Init_Walkabout
	Bsr	Walk_About_Part1
	Bsr	Fade_Down_Screen
	Bsr	Conv_Part
	Bsr	Go_Mouse

	Bsr	Init_Walkabout
	Bsr	Walk_About_Part1
	Bsr	Fade_Down_Screen
	Bsr	Conv_Part
	Bsr	Go_Mouse

	Bsr	Init_Walkabout
	Bsr	Walk_About_Part1
	Bsr	Fade_Down_Screen
	Bsr	Location2_Anim
	Bsr	Terminal_Part1
Skipo
	Bsr	Terminal_End
;	Bsr	Go_Mouse

	Bra	Quit
***********************************************************
Go_Mouse
	Clr.w	d6
	Clr.w	d7
	Movem.w	d6-d7,Mouse_X(a4)
	Jsr	Init_Mouse_Coards
	Jsr	Read_Mouse
	Rts


***********************************************************
***********************************************************
Conv_Part
	Push
	jsr	Conv_Main
	Pull
	Rts

***********************************************************
Location2_Anim
	Move.l	$70.w,-(sp)
	Move.l	#Avbl,$70.w
	Lea	Last_Anim,a0
	Lea	MyPal(a4),a1
	Movem.l	Screenp(a4),a2-a3
	Jsr	Init_Anim
	Bsr	Fade_Up_Screen
	Sf	Vbl_Flag(a4)

.Loop	Cmp.b	#6,Vbl_Flag(a4)
	Bne.s	.Loop
	Move.l	Screenp(a4),a1
	Jsr	Anim_Vbl
	Move.l	d0,-(sp)
	Movem.l	Screenp(a4),d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenp(a4)
	Move.l	d1,a0
	Bsr	Write_Screen
	Sf	Vbl_Flag(a4)
	Move.l	(sp)+,d0
	Tst.l	d0
	Beq.s	.Loop
	Bsr	Fade_Down_Screen
	Move.l	(sp)+,$70.w
	Rts

AVbl	Push
	Lea	DATA,a4
	MOve.w	#0,Scr_Del
	MOve.w	#0,Scr_Mod
	Addq.b	#1,Vbl_Flag(a4)
	Bsr	Copy_Dest
	Jsr	Nt_Vbl
	Tst.b	Fucker
	Bne	.Hold
	Move.b	Key_Code,d0
	Cmp.b	#$39,d0
	Beq.s	.Hold
	Movem.l	(sp)+,d0-a6
	Rte
.Hold	Movem.l	(sp)+,d0-a6
	Move.l	#Fuck,2(sp)
	Rte


***********************************************************
Init_Walkabout
	Bsr	Check_Key_Move
	Bsr	Clear_Current_Panel_P
	Bsr	Build_The_Screen
	Bsr	Draw_Fire_Frames
	Bsr	Draw_Walk_To_Door
	Bsr	Do_Rope_Anim
	Bsr	Draw_Rope_Frames
;
	Bsr	Animate_Randolf
	Bsr	Animate_Special_Randolf
;
	Bsr	Draw_Randolf
	Bsr	Draw_Spit
	Bsr	Mask_Randolf
	Bsr	Move_Mouse
	Bsr	Check_Mouse_Coardinates
	Bsr	Draw_Mouse_Pointer
	Bsr	Write_Pointer_Info
	Bsr	Swap_Screens
	Bsr	Fade_Up_Screen
	St	Rope_Anim_Flag(a4)
	Sf	Quit_Prog(a4)
	Rts
***********************************************************
Walk_About_Part1
	Bsr	Wait_Vbl
	Bsr	Clear_Current_Panel_P
	Bsr	Restore_Mouse_At_X
	Bsr	Check_Key_Move
	Bsr	Move_Map
	Bsr	Move_Randolf

	Bsr	Animate_Randolf
	Bsr	Animate_Special_Randolf

	Bsr	Build_The_Screen
	Bsr	Do_Fire_Anim
	Bsr	Do_Rope_Anim
	Bsr	Draw_Fire_Frames
	Bsr	Draw_Walk_To_Door
	Bsr	Draw_Rope_Frames
	Bsr	Draw_Randolf
	Bsr	Draw_Spit
	Bsr	Mask_Randolf
	Bsr	Move_Mouse
	Bsr	Check_Mouse_Coardinates
	Bsr	Do_Birdy
	Bsr	Draw_Mouse_Pointer
	Bsr	Write_Pointer_Info
.No	Tst.b	Panel_Split(a4)
	Beq.s	.No
	Bsr	Swap_Screens
	Bsr	Swap_Panels
	Tst.b	Quit_Prog(a4)
	Beq	Walk_About_Part1
	Rts

***********************************************************
Do_Birdy
	Tst.b	Doing_Bird(a4)
	Beq	.Exit
	Addq.b	#1,Bird_Del(a4)
	Cmp.b	#3,Bird_Del(a4)
	Bne	.Draw
	Clr.b	Bird_Del(a4)
	Addq.b	#1,Bird_Anim(a4)
	Cmp.b	#11,Bird_Anim(a4)
	Sne	Doing_Bird(a4)
	Beq	.Exit
.Draw	Lea	Bird_Gfx,a6
	
	Moveq	#0,d0
	Move.b	Bird_Anim(a4),d0
	Move.w	.Coard+2(pc,d0*4),-(sp)
	Move.w	.Coard+0(pc,d0*4),-(sp)	
	Lsl.w	#4,d0
	Move.w	#Screenwide,d4		
	Move.w	Spr_Height(a6,d0),D3
	Move.w	Spr_Width(a6,d0),D2
	Move.l	spr_Addr(a6,d0),a0
	Add.l	a6,a0
	Move.w	Spr_Yadd(a6,d0),d6
	Movem.w	(sp)+,d0-d1
	Move.w	Map_X(a4),d6
	And.w	#$f,d6
	Add.w	d6,d0
	Add.w	Map_Y(a4),d1
	Move.l	Screenp(a4),a1
	Add.w	d6,d1
	Move.w	#320,d5
	Bsr	Draw_A_Sprite
.Exit	Rts

.Coard	Dc.w	0,131
	Dc.w	0,105
	Dc.w	0,072
	Dc.w	33,48
	Dc.w	64,26
	Dc.w	124,16
	Dc.w	169,13
	Dc.w	203,25
	Dc.w	249,29
	Dc.w	264,45
	

***********************************************************
Clear_Current_Panel_P
	Move.l	Panel_P(a4),a6
	Lea	Panel_Width*11(a6),a6
	Move.w	#(Panel_Width*8)/(13*4),d7
	Movem.w	Clear(a4),d0-d6/a0-a5
.Loop	Movem.l	d0-d6/a0-a5,-(a6)
	Dbra	d7,.Loop
	Lea	DATA,a4
	Rts

***********************************************************
Terminal_Part1
	clr.w	scr_mod
	clr.w	scr_del
	clr.b	$fffffa1b.w
	Jsr	Term_Program
	;bsr	terminal_end
	Rts	
***********************************************************
Build_The_Screen
	Movem.w	Map_X(a4),d0-d1
	Lea	Playfield,a0
	Mulu	#Byteswide,d1
	And.w	#$fff0,d0
	Add.l	d0,d1
	Lea	(a0,d1.l),a0
	Move.l	Screenp(a4),a1
	Move.w	#200,-(sp)
	
.Loop	Pea	Byteswide(a0)
	Rept	6
	Movem.l	(a0)+,d0-d7/a2-a6
	Movem.l	d0-d7/a2-a6,(a1)
	Lea	52(a1),a1
	Endr
	Movem.l	(a0)+,d0-d5
	Movem.l	d0-d5,(a1)
	Lea	24(a1),a1
	Move.l	(sp)+,a0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Lea	DATA,a4
	Rts

***********************************************************

***********************************************************
Animate_Special_Randolf
	CLr.l	Special_Address(a4)
	Tst.b	Special_Anims(a4)
	Beq.s	.No
	Move.l	Special_Anims_Pointer(a4),a0
	Move.l	(a0),Special_Address(a4)
	Addq.b	#1,Special_Anim_Delay(a4)
	Move.b	Special_Anim_Delay(a4),d1
	Cmp.b	4(a0),d1
	Slt	d6
	Blt.s	.No1
	Clr.b	Special_Anim_Delay(a4)
.No1	Moveq	#0,d1
	Move.b	Special_Anim_Number(a4),d1
	Move.b	5(a0,d1),d2
	Bmi.s	.EXit
	Move.b	d2,Randolf_Anim(a4)
	Tst.b	Init_Animseq(a4)
	Bne.s	.Skip
	Tst.b	d6
	Bne.s	.Skip
	Addq.b	#1,Special_Anim_Number(a4)
.Skip	Rts
.Exit	Move.b	4(a0,d1),Randolf_Anim(a4)
	St	Special_Anim_Done(a4)
.No	Rts

***********************************************************
New_Text
	Tst.b	Flag_For_Text(a4)
	Beq.s	.No
	Sf	Flag_For_Text(a4)
	Move.l	Message_Base(a4),a0
	Lea	Panel_Message(a4),a1
.Loop	Move.b	(a0)+,(a1)+
	Bne.s	.Loop
	Move.l	a0,Message_Base(a4)
.No	Rts

***********************************************************
Write_Pointer_Info
	Push
	Bsr	New_Text
	Lea	Panel_Message(a4),a0
	Move.l	Panel_P(a4),a6
	Lea	Panel_Width*3(a6),a6
	clr.w	x_pos
.loop	moveq	#0,d0	
	move.b	(a0)+,d0
	bne.s	.not_eol
	Pull
	rts
.not_eol
	cmp.b	#" ",d0
	bne.s	.no_space
	addq.w	#6,x_pos
	bra.s	.loop
.no_space
	moveq	#9-1-1,d7
	Lea	Ascii_To_spr(pc),a5
	Move.b	(a5,d0),d0
	cmp.b	#-3,d0
	beq.s	.loop	invalid sprite
	lea	font,a2
	move.l	a2,a3
	add.l	(a3,d0.w*4),a2
	bsr	do_spr
	Lea	Fnt_Width(pc),a5
	Move.b	(a5,d0),d0
	and.w	#$ff,d0
	add.w	d0,x_pos	update x pos
	bra.s	.loop

do_spr	movem.l	d0-a6,-(sp)
	addq.l	#6,a2		skip header
	move.w	x_pos,d0
	move.w	d0,d1
	and.w	#$f,d0		shift
	and.w	#$fff0,d1
	lea	(a6,d1.w),a6	get x pos
.lp	moveq	#-1,d1
	move.w	(a2)+,d1
	ror.l	d0,d1
	and.w	d1,(a6)
	and.w	d1,2(a6)
	and.w	d1,4(a6)
	and.w	d1,6(a6)
	and.w	d1,8(a6)
	and.w	d1,10(a6)
	and.w	d1,12(a6)
	and.w	d1,14(a6)
	swap	d1
	and.w	d1,16(a6)
	and.w	d1,16+2(a6)
	and.w	d1,16+4(a6)
	and.w	d1,16+6(a6)
	and.w	d1,16+8(a6)
	and.w	d1,16+10(a6)
	and.w	d1,16+12(a6)
	and.w	d1,16+14(a6)
acid	set	0
	rept	8
	moveq	#0,d1
	move.w	(a2)+,d1
	ror.l	d0,d1
	or.w	d1,acid(a6)
	swap	d1
	or.w	d1,16+acid(a6)
acid	set	acid+2	
	endr
	lea	320+16(a6),a6
	dbf	d7,.lp
	
	movem.l	(sp)+,d0-a6
	rts
	

x_pos	ds.w	1
		****	00,01,02,03,04,05,06,07,08,09,0a,0b,0c,0d,0e,0f
ascii_to_spr	dc.b	-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3	000-015
		dc.b	-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3	016-031
		dc.b	-2,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,27,-3,26,-3	032-047
		dc.b	-3,-3,-3,-3,-3,-3,-3,-3,-3,-3,28,-3,-3,-3,-3,29	048-064
		dc.b	-3,00,01,02,03,04,05,06,07,08,09,10,11,12,13,14	065-079
		dc.b	15,16,17,18,19,20,21,22,23,24,25,-3,-3,-3,-3,-3	080-095
		dc.b	-3,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44	096-111
		dc.b	45,46,47,48,49,50,51,52,53,54,55,-3,-3,-3,-3,-3	112-127
		
	
		*	a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,.,,,:,?
Fnt_Width	dc.b	6,6,7,6,5,5,7,6,4,6,7,6,7,7,7,6,7,6,6,6,7,9,8,8,6,6,2,4,2,6
		dc.b	7,7,6,7,8,6,7,7,3,5,6,3,8,7,7,7,7,7,8,6,8,8,8,6,6,6,2,4,2,6
		

font		incbin	f:\Junk\Main\Terminal\font1.lib
		even		
	
***********************************************************
Mask_Randolf
	Movem.w	Randolf_X(a4),d0-d1
	Moveq	#0,d2
	Move.w	Map_X(a4),d2
	And.w	#$FFF0,D2
	Add.w	d0,d2
	And.w	#$fff0,d0
	Mulu	#Screenwide,d1	
	Add.l	d1,d0
	Add.l	Screenp(a4),d0
	Move.l	d0,a1
	Lea	Playfield_Mask,a0
	And.w	#$fff0,d2
	Add.l	d2,a0
	Move.w	#Randolf_Height-1,d7
	Move.w	Map_Y(a4),d6
;	MOVE.W	#0,D6
	ADD.w	Randolf_Y(a4),d6
	CMP.W	#MASK_LINE,D6
	BLT.S	.LOOP
	Move.w	d6,d5
	Sub.w	#Mask_Line,d5
	Mulu	#Byteswide,d5
	Add.l	d5,a0


.Loop	Cmp.w	#Mask_Line,d6
	Blt	.Skip
	Cmp.w	#Mask_Line+Mask_Height,d6
	Bge	.Thats_It
	Pea	Screenwide(a1)
	Pea	Byteswide(a0)
	Moveq	#3,d5
.Loop2	Move.w	(a0)+,d4
	Or.w	(a0)+,d4
	Or.w	(a0)+,d4
	Or.w	(a0)+,d4
	Or.w	(a0)+,d4
	Or.w	(a0)+,d4
	Or.w	(a0)+,d4
	Or.w	(a0)+,d4
	Beq.s	.SKip2
	Lea	-16(a0),a0
	Move.w	d4,d3
	Swap	d4
	Move.w	d3,d4
	Not.l	d4
	Movem.l	(a0)+,d0-d3
	And.l	d4,(a1)
	Or.l	d0,(a1)+
	And.l	d4,(a1)
	Or.l	d1,(a1)+
	And.l	d4,(a1)
	Or.l	d2,(a1)+
	And.l	d4,(a1)
	Or.l	d3,(a1)+
	Dbra	d5,.Loop2
	Movem.l	(sp)+,a0-a1
	Addq.w	#1,d6
	DBra	d7,.Loop
	Rts
.Skip2	Lea	16(a1),a1
	Dbra	d5,.Loop2
	
	Movem.l	(sp)+,a0-a1
	Addq.w	#1,d6
	DBra	d7,.Loop
	Rts
.Skip	Lea	Screenwide(a1),a1
	Addq.w	#1,d6
	DBra	d7,.Loop
.Thats_It
.Exit
	Rts

***********************************************************
Animate_Randolf
	Tst.b	Special_Anims(a4)
	Bne.s	.No_Move1
	Tst.w	Left(a4)
	Beq.s	.No_Move
.REINIT
	Subq.b	#1,Randolf_Anim_Delay(a4)
	Bgt.s	.No_Move
	Move.b	#2,Randolf_Anim_Delay(a4)
	Addq.b	#1,Randolf_Anim(a4)
	Cmp.b	#Right_Max_Anim,Randolf_Anim(a4)
	Bne.s	.No_Move1
	Clr.b	Randolf_Anim(a4)
.No_Move1
	Rts
.No_Move
	Sf	Left(a4)
	Sf	Right(a4)
	Sf	Up(a4)
	Sf	Down(a4)
	Rts

***********************************************************
Draw_Fire_Frames
	Move.w	#Fire_X_Pos,d0
	Move.w	Map_X(a4),d1
	Add.w	#320,d1
	Cmp.w	d1,d0
	BGE	.No_Move
	Move.b	Fire_Frame(a4),d0
	Ext.w	d0
	Lsl.w	#4,d0
	Lea	Fire_Gfx,a6
	Move.l	Spr_Addr(a6,d0),a0
	Add.l	a6,a0
	Move.l	#Fire_X_Pos,d0
	Move.w	Map_X(a4),d1
	And.w	#$fff0,d1
	And.w	#$fff0,d0
	Sub.w	d1,d0
	Move.w	d0,Fire_Width_Save(a4)
	Move.w	#Fire_Y_Pos,d1
	Sub.w	Map_Y(a4),d1
	Mulu	#Screenwide,d1
	Add.l	d0,d1
	Add.l	Screenp(a4),d1
	Move.l	d1,a1
;8Words wide + 1 Byte, ;96-High
	Move.w	#9,Fire_Block_Width(A4)
.Loop	Cmp.w	#336,Fire_Width_Save(a4)
	Bge	.No_Move
	Pea	16(a1)
	Pea	18(a0)
	Moveq	#96-1,d7
.Loop1	Addq.l	#2,a0
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Lea	8*18(a0),a0
	Lea	Screenwide-16(a1),a1
	Dbra	d7,.Loop1
	Movem.l	(sp)+,a0-a1
	Add.w	#16,Fire_Width_Save(a4)	
	Subq.w	#1,Fire_Block_Width(a4)
	Bne.s	.Loop
.No_Move
	Rts

Draw_Rope_Frames
	Move.w	#Rope_X_Pos,d0
	Move.w	Map_X(a4),d1
	Add.w	#320,d1
	Cmp.w	d1,d0
	BGE	.No_Move
	Add.w	#48,d0
	Cmp.w	Map_X(a4),d0
	Blt	.No_Move
	
	Move.b	Rope_Frame(a4),d0
	Ext.w	d0
	Mulu	#4224,d0
	Add.l	#Rope_Base,d0
	Move.l	d0,a0

	Move.l	#Rope_X_Pos,d0
	Move.w	Map_X(a4),d1
	And.w	#$fff0,d1
	And.w	#$fff0,d0
	Sub.w	d1,d0
	Ext.l	d0
	Move.w	d0,Fire_Width_Save(a4)
	Move.w	#Rope_Y_Pos,d1
	Sub.w	Map_Y(a4),d1
	Move.w	d1,d5
	Bpl.s	.Pos
	Clr.w	d1
.Pos	Mulu	#Screenwide,d1
	Add.l	d0,d1
	Add.l	Screenp(a4),d1
	Move.l	d1,a1
;4Words wide + 1 Byte, ;96-High
	Move.w	#4,Fire_Block_Width(A4)
	Move.w	#66-1,d6
	Tst.w	d5
	Bpl.s	.Loop
	Add.w	d5,d6
	Neg.w	d5
	Mulu	#16*4,d5
	Add.l	d5,a0


.Loop	Cmp.w	#336,Fire_Width_Save(a4)
	Bge	.No_Move
	Pea	16(a1)
	Pea	16(a0)
	Cmp.w	#-16,Fire_Width_Save(a4)
	Ble.s	.Skip
	Move.w	d6,d7
.Loop1	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Lea	3*16(a0),a0
	Lea	Screenwide-16(a1),a1
	Dbra	d7,.Loop1
.Skip	Movem.l	(sp)+,a0-a1
	Add.w	#16,Fire_Width_Save(a4)	
	Subq.w	#1,Fire_Block_Width(a4)
	Bne.s	.Loop
.No_Move
	Rts

***********************************************************
Do_Fire_Anim
	Tst.b	Fire_Anim_Flag(a4)
	Bpl.s	.Pos
	Beq.s	.No
	Subq.b	#1,Fire_Anim_Dec(a4)
	Bgt.s	.No
	Move.b	#3,Fire_Anim_Dec(a4)
	Addq.b	#1,Fire_Frame(a4)	
	And.b	#$3,Fire_Frame(a4)
.No	Rts
.Pos	Subq.b	#1,Fire_Anim_Dec(a4)
	Bgt.s	.No
	Move.b	#3,Fire_Anim_Dec(a4)
	Addq.b	#1,Fire_Frame(a4)	
	Cmp.b	#13,Fire_Frame(a4)
	Bne.s	.No
	Move.b	#$a,Fire_Frame(a4)
	Rts

***********************************************************
Do_Rope_Anim
	Tst.b	Rope_Anim_Flag(a4)
	Beq.s	.No
	Subq.b	#1,Rope_Anim_Dec(a4)
	Bgt.s	.No
	Move.b	#3,Rope_Anim_Dec(a4)
	Addq.b	#1,Rope_Frame(a4)	
	Cmp.b	#12,Rope_Frame(a4)
	Bne.s	.No
	Move.b	#$0,Rope_Frame(a4)
.No	Rts
	
***********************************************************
Move_Mouse
	Lea	Ikbd_Buffer,a0
	Btst	#2,(a0)
	Sne	Left_Button_Pressed(a4)
	Move.b	1(a0),d0
	Lsl.w	#8,d0
	Move.b	2(a0),d0
	Move.w	d0,Mouse_X(a4)
	Move.b	3(a0),d0
	Lsl.w	#8,d0
	Move.b	4(a0),d0
	Move.w	d0,Mouse_Y(a4)
	Jsr	read_mouse
	Move.b	Ikbd_Buffer,d0
	Btst	#0,d0
	seq	Right_Button_pressed(a4)
.Exit	Rts

***********************************************************
Move_Randolf
	Tst.b	Scroll_Left_Right(a4)
	Beq.s	.Lr
	Bmi.s	.Randolf_Left
	Addq.w	#2,Randolf_X(a4)
	Cmp.w	#Actual_Screen_Width-Width_Of_Randolf-1,Randolf_X(a4)
	Ble.s	.Ud
	Move.w	#Actual_Screen_Width-Width_Of_Randolf-1,Randolf_X(a4)
	Rts
.Randolf_Left
	Subq.w	#2,Randolf_X(a4)
	Bge.s	.Ud
	Clr.w	Randolf_X(a4)
	Rts
.Lr	Tst.b	Scroll_Up_Down(a4)
	Beq.s	.UD
	Bmi.s	.Randolf_Up
	Addq.w	#2,Randolf_Y(a4)
	Cmp.w	#Display_Height-Height_Of_Randolf-1,Randolf_Y(a4)
	Ble.s	.Ud
	Move.w	#Display_Height-Height_Of_Randolf-1,Randolf_Y(a4)
	Rts
.Randolf_Up
	Subq.w	#2,Randolf_Y(a4)
	Bge.s	.Ud
	Clr.w	Randolf_Y(a4)
.UD	Rts

***********************************************************
Draw_Spit
	Tst.b	Do_Spit(a4)
	Beq	.Exit
	Subq.b	#1,Spit_Del(a4)
	Bgt.s	.Nx
	Move.b	#$2,Spit_Del(a4)
	Addq.b	#1,Spit_Num(a4)
.Nx	Movem.w	Randolf_X(a4),d0-d1
	Add.w	#48,d0
	Moveq	#$f,d5
	And.w	Map_X(a4),d5
	Add.w	d5,d0
	Add.w	#320,d5
	Move.w	#48,d2		Width
	Move.w	#54,d3		Height
	Move.w	#Screenwide,d4		Modulous
	Moveq	#0,d7	
	Move.b	Spit_Num(a4),d7
	Lea	Spit_Anim,a6
	Cmp.b	#9,d7
	Blt.s	.Cont
	Move.w	#32+16,d2		Width
	Move.w	#14,d3			Height
	Add.w	#20,d0
	Add.w	#70,d1
.Cont	Move.l	(a6,d7*4),a0
	Add.l	a6,a0
	Addq.l	#6,a0
	Move.l	Screenp(a4),a1		Dest
	Bsr	Draw_A_Sprite
	Cmp.b	#11,Spit_Num(a4)
	Sne	Do_Spit(a4)
.Exit	Rts

***********************************************************
Draw_Walk_To_Door
	Tst.b	Do_Walk_To_Door(a4)
	Bne.s	.Go
	Rts
.Go	Move.b	Walk_Frame(a4),d0
	Ext.w	d0
	Lsl.w	#4,d0
	Lea	Walk_To_Gfx,a6
	Move.l	Spr_Addr(a6,d0),a0
	Add.l	a6,a0
	Move.l	#720,d0
	Move.w	Map_X(a4),d1
	And.w	#$fff0,d1
	And.w	#$fff0,d0
	Sub.w	d1,d0
	Move.w	d0,Fire_Width_Save(a4)
	Move.w	#Fire_Y_Pos+10,d1
	Sub.w	Map_Y(a4),d1
	Mulu	#Screenwide,d1
	Add.l	d0,d1
	Add.l	Screenp(a4),d1
	Move.l	d1,a1
;8Words wide + 1 Byte, ;96-High
	Move.w	#7,Fire_Block_Width(A4)

.Loop	Cmp.w	#336,Fire_Width_Save(a4)
	Bge	.No_Move
	Pea	16(a1)
	Pea	18(a0)
	Moveq	#64-1,d7
.Loop1	Addq.l	#2,a0
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Lea	6*18(a0),a0
	Lea	Screenwide-16(a1),a1
	Dbra	d7,.Loop1
	Movem.l	(sp)+,a0-a1
	Add.w	#16,Fire_Width_Save(a4)	
	Subq.w	#1,Fire_Block_Width(a4)
	Bne.s	.Loop
	
	Addq.b	#1,Walk_Frame_Del(a4)
	Cmp.b	#3,Walk_Frame_Del(a4)
	Bne.s	.Nx
	Clr.b	Walk_Frame_Del(a4)
	Addq.b	#1,Walk_Frame(a4)
	Cmp.b	#18,Walk_Frame(a4)
	Bne.s	.No_Move
	St	Exit_My_Demo(a4)	
	Move.b	#17,Walk_Frame(a4)
.NO_MOVE
.Nx	Rts

***********************************************************
Draw_Randolf
	Tst.b	No_Draw_Randolf(a4)
	Beq.s	.Iyes
	Rts
.IYes	Movem.w	Randolf_X(a4),d0-d1
	Moveq	#$f,d5
	And.w	Map_X(a4),d5
	Add.w	d5,d0
	Add.w	#320,d5
	Move.w	#Width_Of_Randolf,d2	Width
	Move.w	#Height_Of_Randolf,d3	Height
	Move.w	#Screenwide,d4		Modulous
	Moveq	#0,d7	
	Move.b	Randolf_Anim(a4),d7
	Lea	Randolf_Sprites,a6
	Tst.l	Special_Address(a4)
	Beq	.Yes
	Cmp.l	#Look_Anim,Special_Address(a4)
	Bne.s	.Not_Look
	MOve.l	Special_Address(a4),a6
	Move.w	#48,d2		Width
	Move.w	#54,d3		Height
	Bra.s	.Yes
.Not_Look
	Cmp.l	#Spit_Anim,Special_Address(a4)
	Bne.s	.Not_Spit
	MOve.l	Special_Address(a4),a6
	Move.w	#48,d2		Width
	Move.w	#54,d3		Height
	Addq.w	#1,d0
	Add.w	#1,d1
	Bra.s	.Yes
.Not_Spit
	MOve.l	Special_Address(a4),a6
	Move.w	#64,d2		Width
	Move.w	#64,d3		Height
	Sub.w	#8,d1
	Bra.s	.Yes
	Nop
.Yes	Move.l	(a6,d7*4),a0
	Add.l	a6,a0
	Addq.l	#6,a0
	Move.l	Screenp(a4),a1		Dest
	Bsr	Draw_A_Sprite
	Rts

***********************************************************
Draw_Mouse_Pointer
	Rts
 	Movem.w	Mouse_X(a4),d0-d1
	Moveq	#$f,d5
	And.w	Map_X(a4),d5
	Add.w	d5,d0
	Add.w	#320,d5
	Move.w	#16,d2			Width
	Move.w	#12,d3			Height
	Move.w	#Screenwide,d4		Modulous
	Lea	Mouse_Sprite,a0		Source address
	Addq.l	#6,a0
	Move.l	Screenp(a4),a1		Dest

	Move.w	d3,Mouse_Height_To_Draw(a4)
	Push
	Cmp.w	#Display_Height,Mouse_Y(a4)
	Bge.s	.No_Display_Sprite_On_Map
	Moveq	#32,d6
	Add.w	d1,d6
	Sub.w	#Display_Height,d6
	Move.w	d6,Mouse_Height_To_Draw(a4)
	Ble.s	.Skip_Sub
	Sub.w	d6,d3
.Skip_Sub
	Bsr	Draw_A_Sprite
.No_Display_Sprite_On_Map
	Pull
	Tst.w	Mouse_Height_To_Draw(a4)
	Ble.s	.Noon	
	Move.w	Mouse_Height_To_Draw(a4),d6
	Sub.w	#32,d6
	Neg.w	d6
	Mulu	#18*2,d6
	Lea	Mouse_Sprite,a0		Source address
	Lea	(a0,d6.w),a0
	Movem.w	Mouse_X(a4),d0-d1
	Sub.w	#Display_Height,d1
	Bpl.s	.Cont
	Clr.w	d1	
.Cont	Move.w	Mouse_Height_To_Draw(a4),d3
	Cmp.w	#32,d3
	Bne.s	.NNN
	Move.w	d3,d6
	Add.w	d1,d6
	Sub.w	#Panel_Height,d6
	Bmi.s	.NNN
	Sub.w	d6,d3
.NNN	Move.l	Panel_P(a4),a1
	Move.w	#336,d4
	Move.w	#336,d5
	Push
	Bsr	Save_Mouse_At_X
	Pull
	Bsr	Draw_A_Sprite
.Noon	Rts

***********************************************************
Restore_Mouse_At_X
	Move.l	Panel_PSave(a4),a0
	Tst.b	(a0)
	Bmi.s	.Set
	Move.l	(a0)+,a1
	Move.w	(a0)+,-(sp)
.Loop	Movem.l	(a0)+,d0-d7/a2-a5
	Movem.l	d0-d7/a2-a5,(a1)
	Lea	Panel_Width(a1),a1
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Lea	DATA,a4
.Set	Move.l	Panel_PSave(a4),a0
	St	(a0)
	Rts

***********************************************************
Save_Mouse_At_X
	Rts
	Move.l	#$ff,PAL256
	Mulu	#Panel_Width,d1
	And.w	#$fff0,d0
	Add.l	d0,d1
	Add.l	Panel_P(a4),a0
	Move.l	Panel_PSave(a4),a1
	Move.l	a0,(a1)+
	Move.w	d3,(a1)+
	Move.w	d3,-(sp)
.Loop	Movem.l	(a0),d0-d7/a2-a5
	Movem.l	d0-d7/a2-a5,(a1)
	Lea	48(a1),a1
	Lea	Panel_Width(a0),a0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Lea	DATA,a4
	Rts
***********************************************************
Check_Mouse_Coardinates
.No	Movem.w	Mouse_X(a4),d0-d1
	Tst.w	d0
	Bge.s	.Xok
	Clr.w	d0
.Xok	Tst.w	d1
	Bge.s	.Yok
	Clr.w	d1
.Yok	Cmp.w	#319,d0
	Ble.s	.Xok1
	Move.w	#319,d0
.Xok1	Cmp.w	#100,d1
	Ble.s	.Yok1
	Move.w	#140,d1
.Yok1	Movem.w	d0-d1,Mouse_X(a4)
	Rts

***********************************************************
; d0-d1 x/y
; d2- width in pixels (sprite)
; d3- Height in pixels (Height)
; d4- Screen width
; d5- Max visible x
; a0- Sprite Address
; a1- Destination screen


Draw_A_Sprite
;d5========!!!
	MOve.w	d5,Max_Visible_X(a4)
	Movem.w	d0-d1,Sprite_X_Save(a4)
	Move.w	d2,Sprite_Width(a4)
	Move.w	d2,Sprite_Width_Save(a4)
	Move.w	d2,Sprite_X_Count(a4)
	Move.w	d3,Sprite_Height(a4)
	Move.w	d4,Screen_Width+2(a4)
	Moveq	#$f,d2
	And.w	d0,d2
	Sub.w	d2,d0
	Ext.l	d0
	Mulu	d4,d1
	Add.l	d1,d0
	Add.l	d0,a1
	Move.w	d2,d0
.Next_Word
	Cmp.w	#-16,Sprite_X_Save(a4)
	Ble	.Skip_Minus	
	Move.w	Max_Visible_X(a4),d4
	Cmp.w	Sprite_X_Save(a4),d4
	Ble	.No_More_To_Draw
		
	Movem.l	a0-a1,-(sp)
	Move.w	Sprite_Height(a4),-(sp)
.Loop2	Pea	(a1)
	Move.l	Screen_Width(a4),d3
	Add.l	d3,(sp)
	Moveq	#-1,d3
	Moveq	#0,d4
	Moveq	#0,d5
	Moveq	#0,d6
	Moveq	#0,d7
	Move.w	(a0)+,d3
	Move.w	(a0)+,d4
	Move.w	(a0)+,d5
	Move.w	(a0)+,d6
	Move.w	(a0)+,d7
	Ror.l	d0,d3
	Ror.l	d0,d4
	Ror.l	d0,d5
	Ror.l	d0,d6
	Ror.l	d0,d7
	Move.w	d3,d2
	Swap	d2
	Move.w	d3,d2
	And.l	d2,(a1)
	Or.w	d4,(a1)+
	Or.w	d5,(a1)+
	And.l	d2,(a1)
	Or.w	d6,(a1)+
	Or.w	d7,(a1)+
	Swap	d4	
	Swap	d5	
	Swap	d6	
	Swap	d7
	Movem.w	d4-d7,Reg_Save1(a4)
	Moveq	#0,d4
	Moveq	#0,d5
	Moveq	#0,d6
	Moveq	#0,d7
	Move.w	(a0)+,d4
	Move.w	(a0)+,d5
	Move.w	(a0)+,d6
	Move.w	(a0)+,d7
	Ror.l	d0,d4
	Ror.l	d0,d5
	Ror.l	d0,d6
	Ror.l	d0,d7
	And.l	d2,(a1)
	Or.w	d4,(a1)+
	Or.w	d5,(a1)+
	And.l	d2,(a1)
	Or.w	d6,(a1)+
	Or.w	d7,(a1)+
	Swap	d4	
	Swap	d5	
	Swap	d6	
	Swap	d7
	Movem.w	d4-d7,Reg_Save2(a4)
	Movem.w	Reg_Save1(a4),d4-d7
	Swap	d3
	Move.w	d3,d2
	Swap	d3
	Move.w	d2,d3
	And.l	d3,(a1)
	Or.w	d4,(a1)+
	Or.w	d5,(a1)+
	And.l	d3,(a1)
	Or.w	d6,(a1)+
	Or.w	d7,(a1)+
	Movem.w	Reg_Save2(a4),d4-d7
	And.l	d3,(a1)
	Or.w	d4,(a1)+
	Or.w	d5,(a1)+
	And.l	d3,(a1)
	Or.w	d6,(a1)+
	Or.w	d7,(a1)+
	Move.l	(sp)+,a1
	Move.w	Sprite_Width_Save(a4),d3
	Lsr.w	#4,d3
	Subq.w	#1,d3
	Mulu	#18,d3
	Add.l	d3,a0
	Subq.w	#1,(sp)
	Bne	.Loop2
	Addq.l	#2,sp
	Movem.l	(sp)+,a0-a1
.Skip_Minus	
	Lea	18(a0),a0
	Lea	16(a1),a1
	Add.w	#16,Sprite_X_Save(a4)
	Sub.w	#16,Sprite_Width(a4)
	Bne	.Next_Word
.No_More_To_Draw
	Rts

***********************************************************
Move_Map
	Sf	Scroll_Left_Right(a4)
	Sf	Scroll_Up_Down(a4)

	Tst.b	Left(a4)
	Beq.s	.No_Left
	Cmp.w	#160,Randolf_X(a4)
	Bgt.s	.Mv_Left
	Subq.w	#2,Map_X(a4)
	Cmp.w	#Min_Map_X,Map_X(a4)
	Bge.s	.No_Left
	Move.w	#Min_Map_X,Map_X(a4)
.Mv_Left
	Move.b	#-1,Scroll_Left_Right(a4)
.No_Left
	Tst.b	Right(a4)
	Beq.s	.No_Right
	Cmp.w	#120,Randolf_X(a4)
	Blt.s	.Mv_Right
	Addq.w	#2,Map_X(a4)
	Cmp.w	#Byteswide-Screenwide-1,Map_X(a4)
	Ble.s	.No_Right
	Move.w	#Byteswide-Screenwide-1,Map_X(a4)
.Mv_Right
	Move.b	#1,Scroll_Left_Right(a4)
.No_Right
	Tst.b	Up(a4)
	Beq.s	.No_Up
	Subq.w	#2,Map_Y(a4)
	Bge.s	.No_Up
	Move.b	#-1,Scroll_Up_Down(a4)
	Clr.w	Map_Y(a4)
.No_Up
	Tst.b	Down(a4)
	Beq.s	.No_Down
	Addq.w	#2,Map_Y(a4)
	Cmp.w	#200-Screen_Height-1,Map_Y(a4)
	Ble.s	.No_Down
	Move.b	#1,Scroll_Up_Down(a4)
	Move.w	#200-Screen_Height-1,Map_Y(a4)
.No_Down
	Rts

***********************************************************
Check_Key_Move
	IFNE	AUTO
	Bsr	Do_Randolf_Script
	Endc
	MOve.b	Key_code,d0
	Ifeq	Auto
	Cmp.b	#$4b,d0
	Seq	Left(a4)
	Cmp.b	#$4d,d0
	Seq	Right(a4)
	Cmp.b	#$48,d0
	Seq	Up(a4)
	Cmp.b	#$50,d0
	Seq	Down(a4)
	Endc
	Cmp.b	#$01,d0
	Bne.s	.No
	St	Quit_Prog(a4)
.No
	Tst.b	Left_Button_Pressed(a4)
	Beq.s	.No1
	St	Flag_For_Text(a4)
.No1	Rts

Do_Randolf_Script
	Move.l	Randolf_Moves(a4),a0
	Move.w	(a0)+,d0
	Jmp	.T(pc,d0*4)
.T	Jmp	Wait_State(pc)
	Jmp	Special_Sequence(pc)
	Jmp	Exit_Scripty(pc)
	Jmp	Move_R(pc)
	Jmp	Init_Seq(pc)
	Jmp	Init_Ran(pc)
	Jmp	WM(pc)
	Jmp	Spit(pc)
	Jmp	Billy(pc)
	Jmp	Birdy(pc)
	Jmp	Walk_Towards(pc)
	Jmp	Check_Exit(pc)
	Jmp	Init_Ran2(pc)
		
Wait_State
	Move.w	Randolf_Wait(a4),d0
	Cmp.w	(a0)+,d0
	Bne.s	.Nx
	Clr.w	Randolf_Wait(a4)
	Move.l	a0,Randolf_Moves(a4)
	Rts
.Nx	Addq.w	#1,Randolf_Wait(a4)
	Rts
	
Check_Exit
	Tst.b	Exit_My_Demo(a4)	
	Bne	Exit_Scripty
	Rts

Special_Sequence
	Sf	Randolf_Anim(a4)
	Sf	Special_Anim_Number(a4)
	Sf	Randolf_Anim_Delay(a4)
	Sf	Special_Anim_Done(a4)
	Sf	Init_Animseq(a4)
	St	Special_Anims(a4)
	Move.l	(a0)+,Special_Anims_Pointer(a4)
	Move.l	a0,Randolf_Moves(a4)
.Yes	Rts

Exit_Scripty
	Move.l	a0,Randolf_Moves(a4)
	St	Quit_Prog(a4)
	Rts

Move_R	Movem.w	(a0)+,d0-d2
	Cmp.w	Randolf_Wait(a4),d2
	Beq.s	.Clear
	Addq.w	#1,Randolf_Wait(a4)
	Tst.w	d0
	Smi	Left(a4)
	Sgt	Right(a4)
	Tst.w	d1
	Smi	Up(a4)
	Smi	Down(a4)
	Rts	
	
.Clear	Clr.w	Randolf_Wait(a4)
	Move.l	a0,Randolf_Moves(a4)
	Rts

Init_Seq
	Sf	Special_Anim_Done(a4)
	Sf	Special_Anim_Number(a4)
	St	Special_Anims(a4)
	St	Init_Animseq(a4)
	Move.l	(a0)+,Special_Anims_Pointer(a4)
	Move.l	a0,Randolf_Moves(a4)
.Yes	Rts

Init_Ran2
	Sf	Randolf_Anim(a4)
	Sf	Randolf_Anim_Delay(a4)
	Move.l	a0,Randolf_Moves(a4)
.Yes	Rts
	
Init_Ran
	Sf	Special_Anim_Done(a4)
	Sf	Special_Anims(a4)
	Sf	Randolf_Anim(a4)
	Sf	Randolf_Anim_Delay(a4)
	Move.l	a0,Randolf_Moves(a4)
	Rts

WM	Tst.w	Randolf_Wait(a4)
	Bne.s	.Skip
	Move.l	a0,Randolf_Moves(a4)
.Skip	Rts

Spit	Tst.b	Special_Anim_Done(a4)
	Beq.s	.Not_Done
	Move.b	#2,Spit_Del(a4)
	Move.b	#4,Spit_Num(a4)
	St	Do_Spit(a4)
	Move.l	a0,Randolf_Moves(a4)
.Not_Done	Rts

Billy	Move.b	#1,Fire_Anim_Flag(a4)
	Move.l	a0,Randolf_Moves(a4)
	Rts

Birdy	Move.l	a0,Randolf_Moves(a4)
	St	Doing_Bird(a4)
	Clr.b	Bird_Del(a4)
	Clr.b	Bird_Anim(a4)
	Rts
Walk_Towards
	Cmp.b	#$a,Fire_Frame(a4)
	Bne.s	.Nx
	St	Do_Walk_To_Door(a4)
	St	No_Draw_Randolf(a4)
	Clr.b	Walk_Frame(a4)
	Clr.b	Walk_Frame_Del(a4)
	Move.l	a0,Randolf_Moves(a4)
.Nx	Rts
	
***********************************************************
Fade_Up_Screen
	Clr.w	Intens(a4)
.Loop	Bsr	Wait_1_Frame
	Bsr	Fade_Pal
	Addq.w	#8,Intens(a4)
	Cmp.w	#256,Intens(a4)
	Bne.s	.Loop
	Bsr	Wait_1_Frame
	Bsr	Fade_Pal
	Rts
***********************************************************
Fade_Down_Screen
	Move.w	#256,Intens(a4)
.Loop	Bsr	Wait_1_Frame
	Bsr	Fade_Pal
	Subq.w	#8,Intens(a4)
	Bne.s	.Loop
	Bsr	Wait_1_Frame
	Bsr	Fade_Pal
	Rts

***********************************************************
Wait_1_Frame
	Sf	Vbl_Flag(a4)
.Loop	Tst.b	Vbl_Flag(a4)
	Beq.s	.Loop
	Rts
***********************************************************
Walk_Around

***********************************************************
Four_Three
	Move.l	a0,a1
	Move.w	#255,d0
.Loop	Move.l	(a0)+,d1
	Rol.l	#8,d1
	Move.b	d1,(a1)+
	Rol.l	#8,d1
	Move.b	d1,(a1)+
	Rol.l	#8,d1
	Rol.l	#8,d1
	Move.b	d1,(a1)+
	Dbra	d0,.Loop
	Rts

***********************************************************
Fade_Pal
	Lea	Mypal(a4),a0
	Lea	Dest_pal(a4),a1
	Move.w	Intens(a4),d0
	Move.w	#256,d1
	Bsr	Scale_Pal
	Rts
***********************************************************

Swap_Screens
	Move.l	Map_X(a4),Map_X_Display(a4)
	Movem.l	Screenp(a4),d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenp(a4)
	Rts
Swap_Panels
	Movem.l	Panel_P(a4),d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Panel_P(a4)
	Movem.l	Panel_PSAVE(a4),d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Panel_PSAVE(a4)
	Rts

***********************************************************
; Address in a0
Write_Screen
	Pea	(a0)
	Move.b	1(sp),Bp_Hi
	Move.b	2(sp),Bp_Md
	Move.b	3(sp),Bp_Lo+1
	Addq.l	#4,sp
	Rts


***********************************************************
Init	Lea	DATA,a4		; Globals
	Bsr	Install_Screen		; Set logical screen base
	Bsr	Cleardata		; Clear all globals
	Bsr	Setup_Screen_Mode	; 8 plane / overscan
	Bsr	Setup			; Supervisor + Shit
	Bsr	Setup_Screens		; Clear both screens
	Bsr	Set_Main_Pallete
	Bsr	Setup_Game_Vars
	PUSH
	Jsr	_Init_Sound
	Lea	This_Mod,a0
	Jsr	_Pt_Mod_On
	PULL
	Jsr	Hbl_On
	Bsr	Save_Vbl		; Save vertical blank
	Rts

**********************************************************
Setup_Game_Vars
	Move.l	#Mouse_Script,Mouse_Moves(a4)
	Move.l	#Randolf_Script,Randolf_Moves(a4)
	Move.w	#10,Randolf_X(a4)
	Move.w	#66,Randolf_Y(a4)
	Move.w	#Min_Map_X,Map_X(a4)
	Move.l	#Panel1,d0
	Move.l	#Panel2,d1
	And.l	#-4,d0
	And.l	#-4,d1
	Move.l	d0,a0
	Move.l	d1,a2
	Move.l	d0,Panel_P(a4)
	Move.l	d1,Panel_P+4(a4)
	Lea	Panel1,a1
	Lea	Panel2,a3
	Move.w	#Panel2-Panel1-1,d3
.Loop	Move.b	(a1)+,(a0)+
	Move.b	(a3)+,(a2)+
	Dbra	d3,.Loop
	Move.l	#Panel_Buffer1,Panel_PSave(a4)
	Move.l	#Panel_Buffer2,Panel_PSave+4(a4)
	Movem.l	Panel_PSave(a4),a0-a1
	St	(a0)
	St	(a1)
;	Movem.l	Panel_P(a4),a0-a1
;	Move.w	#320-1,d0
;.Loop	Clr.b	(a0)+
;	Clr.b	(a1)+
;	Dbra	d0,.loop
	Move.l	#Intro_Text,Message_Base(a4)
	Rts

**********************************************************
Set_Main_Pallete
	Lea	Playfield_Pal,a0
	Clr.l	(a0)
	Lea	Mypal(a4),a1
	MOve.w	#256,d0
	Bsr	Copy_A_Pallete
	Lea	Mypal(a4),a0
	Rts

**********************************************************
Copy_A_Pallete
	Move.l	(a0)+,(a1)+
	Subq.w	#1,d0
	Bne.s	Copy_A_Pallete
	Rts


**********************************************************
Install_Screen
	Move.w	#-1,-(sp)
	Move.l	#SCREEN1,-(sp)
	Move.l	(sp),-(sp)
	Move.w	#5,-(sp)
	Trap	#14
	Lea	12(sp),sp
	Rts

**********************************************************
Setup_Screen_Mode	
	Bsr	Mon_Type
	Cmp.b	#2,d0			; Using VGA monitor ?
	Seq	Vga_Flag(a4)		; Set if using VGA Monitor	
	Bne.s	.Not_Vga		; No !
	Move.w	#$64,Screen_Mode(a4)	; Set VGA monitor bit!
	Bra.s	.Skip			; set mode anyway!
.Not_Vga 
	Move.w	#$3,Screen_Mode(a4)	; Normal ST monitor 8 bpl,320x256
.Skip	Bsr	Setmode			; Set screen mode 8bps,PAL/OVERscan!
	Rts

**********************************************************
Quit	
;	Jsr	Fade_Syspal
	Lea	DATA,a4
	Jsr	Hbl_Off
	Move.w	Mod_Save(a4),Scr_Mod
	Move.w	Del_Save(a4),Scr_Del
	Move.l	Vbl_save(a4),$70.w
	Move.w	Old_Mode(a4),Screen_Mode(a4)
	Push
	Jsr	_Pt_Mod_OFf
	Pull
	Move.l	Stacksave,a7
	Ifeq	Makedisk
	Bsr	Setmode
	Endc
	Rts
	
**********************************************************
; supervisor + save sys state!

Setup	move	#37,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

**********************************************************
; Save/Set Vbl
Save_Vbl
	move.l	$70.w,Vbl_save(a4)	; Save vbl
	Pea	New_Vbl(pc)
	Move.l	(sp)+,$70.w		; Set VBL
	Rts

**********************************************************
; All data exept SYSvars
Cleardata
	Move.w	#Varend-1,d0
.Loop	Clr.b	(a4,d0.w)
	Dbra	d0,.Loop
	Rts	

**********************************************************
; Calculate addresses for screens + clear em

Setup_Screens
	Move.l	#SCREEN1,d0	
	Move.l	#SCREEN2,d1
	Moveq	#-4,d2			; Mask long word boundry
	And.l	d2,d0
	And.l	d2,d1
	Movem.l	d0-d1,Screenp(a4)	; Save screen pointers
	Move.w	Scr_Del,Del_Save(a4)
	Move.w	Scr_Mod,MOD_Save(a4)
	Bsr	Swap_Screens
	Rts

**********************************************************
; Setup screen mode in SCREEN_MODE(a4)
Setmode	Move.w	Screen_mode(a4),d0
	Or.b	#$20,d0
	Tst.b	$7c.w
	Bne.s	.Pal
	And.b	#$df,d0
.Pal	Move.w	d0,-(sp)
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

***********************************************************
my_split_120
	or.w	#$0700,sr
	rept	148
	nop
	endr
	move.b	1+Panel_P+4+DATA,$ffff8205.w
	move.b	2+Panel_P+4+DATA,$ffff8207.w
	move.b	3+Panel_P+4+DATA,$ffff8209.w		;new screen addr
	Move.w	#8,Scr_Mod
	Move.w	#0,Scr_Del
	clr.b	$fffffa1b.w			;no more timer b
	St	Panel_Split+Data
	rte

***********************************************************
; Add to Vbl_Count

New_Vbl	clr.b	$fffffa1b.w
	move.l	#my_split_120,$120.w
	move.b	#split_time-1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	Movem.l	d0-a6,-(sp)
	Lea	DATA,a4
	Sf	Panel_Split(a4)
	Bsr	Calculate_Screen_address
	Bsr	Copy_Dest
	Addq.b	#1,Vbl_Flag(a4)
	Jsr	Nt_Vbl
	Tst.b	Fucker
	Bne	.Hold
	Move.b	Key_Code,d0
	Cmp.b	#$39,d0
	Beq.s	.Hold
	Movem.l	(sp)+,d0-a6
	Rte

.Hold	Movem.l	(sp)+,d0-a6
	Move.l	#Fuck,2(sp)
	Rte

***********************************************************
Fuck	St	Fucker
	Bra	Fuck

Fucker	Ds.w	1

***********************************************************
Calculate_Screen_address
	Move.w	sr,-(sp)
	Or.w	#$700,sr
	Move.w	Map_X_Display(a4),d0
	And.w	#$f,d0
	Move.w	#16,d3
	Move.w	d0,Scr_Del
	Beq.s	.MOD_IN
	Sub.w	#16,d3
.MOD_IN	Lsr.w	#1,d3
	Move.w	d3,Scr_Mod
	Move.l	Screenp+4(a4),a0
	BSR	WRITE_SCREEN
	Move.w	(sp)+,sr
	Rts

******************************************************
Copy_Dest
	Lea	Dest_Pal(a4),a0
	Lea	Pal256,a1
	Move.w	#256,d0
	Bsr	Quick_Copy_Long
	Rts

***********************************************************
; Wait for framerate, then clear!
Wait_Vbl
	Cmp.b	#Frame_Rate,Vbl_Flag(a4)
	Bge.s	Wait_Vbl2
	Bne.s	Wait_Vbl
	Sf	Vbl_Flag(a4)
	Rts
Wait_Vbl2
	Sf	Vbl_Flag(a4)
.Hold	Tst.b	Vbl_Flag(a4)
	Beq.s	.Hold
	Sf	Vbl_Flag(a4)
	Rts

**********************************************************
; a0=Decoded VGA pic, a1=DEST!
Convert_VGA
	Move.l	a1,a2
	Move.w	#(64000/4)-1,d0
.Loopx	Clr.l	(a1)+
	Dbra	d0,.Loopx
	Move.l	a2,a1

	Move.w	#199,d4
.Xloop	Move.w	#959,d0
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
	Lea	960(a1),a1
	Dbra	d4,.Xloop
	Rts	
	
**********************************************************
; a0=Source pallete , a1=Dest pallete, d0= Intensity, d1=Number !
; Note pallete is in 3 byte RGB format , and throws out in 4 bytes !

Scale_Pal
	Subq.w	#1,d1
.Loop	Movem.w	Clear(a4),d2-d4
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3
	Addq.l	#1,a0
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
	Pea	(a1)
	Move.w	#64000/4-1,d0
.Loop0	Clr.l	(a1)+
	Dbra	d0,.Loop0
	Move.l	(sp)+,a1

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
	Move.w	#320,d7
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
	Bsr	Check320
	Subq.b	#1,d1
	Bge.s	.Copyloop		Decrement loop
	Sub.l	d3,d0			Away from total count
	Bgt.s	.ByterunLoop	
	Bra.s	.Byterunexit	
.Run	Move.b	(a0)+,d2		byte to repeat !
.Rloop	Move.b	d2,(a1)+		Byte in
	Bsr	Check320
	Addq.b	#1,d1			Decrement loop
	Ble.s	.RLoop
	Subq.l	#2,d0
	Bgt.s	.ByterunLoop
.Byterunexit
	Rts

Check320
	Subq.w	#1,d7
	Bne.s	.Nx1
;	Lea	64(a1),a1
	Move.w	#320,d7
.Nx1	Rts

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
Intro_Text
	Dc.b	"Hello and welcome to Space Junk !",0
	Dc.b	"This is our hero Randolf",0
	Dc.b	"A planet data terminal",0
	Dc.b	"Pick up the data terminal",0
	Dc.b	"Richtoffen Bader A DROOG pilot",0
	Dc.b	"Talk to Ritchoffen Bader",0
	Even
;	opt	o+,ow-
anim_speed	equ	6
max_y_term	equ	20+6*18
wait_0	equ	100
wait_1	equ	100
wait_2	equ	80
wait_3	equ	200

inifite_loop	equ	1
flash_on	equ	1
title_offset	equ	320*8+16
window_offset	equ	320*8+16*14
main_high	equ	128
window_high	equ	64
atari_pal	equ	$ffff9800
static_colour	equ	atari_pal+255*4
new_mode	equ	$23


term_wait_vbl
	move.l	d0,-(sp)
	move.w	clock,d0
.lp	cmp.w	clock,d0
	beq.s	.lp
	move.l	(sp)+,d0
	rts

terminal_table
	dc.l	smaskp3,swamp_world_text
	dc.l	smaskp5,scene_6_text


clear_bss
	lea	term_clear_start,a0
	lea	term_clear_end,a1

.lp	clr.w	(a0)+
	cmp.l	a0,a1
	bne.s	.lp
	rts

term_program
	movem.l	d0-a6,-(sp)
	move.w	which_term,d0
	eor.w	#1,which_term
	bsr	clear_bss
	lea	terminal_table(pc),a0
	lea	(a0,d0.w*8),a0
	move.l	(a0)+,smaskp1
	move.l	(a0)+,terminal_text
	move.l	#$e00000,static_addr
	move.l	#col_pal,bar_base
	clr.w	clock
	move.l	$70.w,-(sp)
	move.l	#term_new4,$70.w
	bsr	term_main
	move.l	(sp)+,$70.w
	movem.l	(sp)+,d0-a6
	rts

terminal_end
	Move.w	#0,Scr_Mod
	Move.w	#0,Scr_Del
	Movem.l	d0-a6,-(sp)
	move.l	$70.w,-(sp)
	move.l	#term_new4,$70.w
	bsr	end_screen
	move.l	(sp)+,$70.w
	movem.l	(sp)+,d0-a6
	rts

	even
smaskp3	incbin	Terminal\bit3.spa
smaskp5	incbin	Terminal\bit5.spa

smaskp1		dc.l	0
terminal_text	dc.l	0
	even
termfont	incbin	Terminal\5x5font.dat
	ds.b	30
	even


	include	Terminal\bangfade.s


term_new4
	Move.w	#0,Scr_Mod	
	Move.w	#0,Scr_Del	
	addq.w	#1,clock
	movem.l	d0-a6,-(sp)
	move.l	tv_addr1,-(sp)
	move.b	1(sp),$ffff8201.w		tv set up
	move.b	2(sp),$ffff8203.w		tv set up
	move.b	3(sp),$ffff820d.w
	addq.l	#4,sp
	lea	new_pal,a0
	lea	(atari_pal).w,a1
	move.w	#256-1,d0
.lp	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	bsr	do_bars
	tst.b	static_display
	bne.s	.do_static
	move.l	#$004f000f,d0
	move.l	#$7f000000,d1
	move.l	#$7f7f0000,d2
	IFNE	flash_on
	addq.b	#1,fgcol
	and.b	#1,fgcol
	beq.s	.ok
	move.l	#$007f001f,d0
	move.l	#$cf000000,d1
	move.l	#$cfcf0000,d2
	ENDC
.ok	tst.b	flicker_on
	beq.s	.no_flicker
	move.l	d0,atari_pal+254*4
	move.l	d1,atari_pal+253*4
	move.l	d2,atari_pal+252*4
.no_flicker
	move.l	d0,col_pal+(254*4)
	move.l	d1,col_pal+(253*4)
	move.l	d2,col_pal+(252*4)
	bra.s	.no_static
.do_static
	bsr.s	static_colours
	bsr.s	static_picture
.no_static
	jsr	nt_vbl
	Tst.b	Fucker
	Bne	.Hold
	Move.b	Key_Code,d0
	Cmp.b	#$39,d0
	Beq.s	.Hold
	Movem.l	(sp)+,d0-a6
	Rte
.Hold	Movem.l	(sp)+,d0-a6
	Move.l	#Fuck,2(sp)
	Rte


static_colours
	move.w	fade_index,d0
	tst.b	static_fade_out
	bne.s	.fade_out
	cmp.b	#-1,d0
	beq.s	.ok
	addq.w	#1,d0
	bra.s	.ok
.fade_out
	cmp.w	#0,d0
	beq.s	.ok
	subq.w	#1,d0
.ok
	move.w	d0,fade_index
	rept	4
	move.b	d0,d1
	lsl.l	#8,d1
	endr
	move.l	d1,fade_index
	rts




static_picture
	move.l	tv_addr1,a0
	lea	title_offset(a0),a0
	moveq	#main_high-1,d7
	move.l	static_addr,a1
.lp	
acid	set	0
	rept	12
	move.w	(a1)+,d0
	move.w	d0,a6
	swap	d0
	move.w	a6,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	movem.l	d0-d3,acid(a0)
acid	set	acid+16
	endr
	lea	320(a0),a0
	dbf	d7,.lp
	add.l	#554,static_addr
	move.l	tv_addr1,a0
	lea	window_offset(a0),a0
	moveq	#window_high-1,d7

.lp1	
acid	set	0
	rept	5
	move.w	(a1)+,d0
	move.w	d0,a6
	swap	d0
	move.w	a6,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	movem.l	d0-d3,acid(a0)
acid	set	acid+16
	endr
	lea	320(a0),a0
	dbf	d7,.lp1
	rts



fade_out_terminal
	move.l	#col_pal,a6
	move.w	#atari_pal,a5
	moveq	#0,d7
	move.w	#128-1,d0		no times
	move.w	#255,d1			init value
	moveq	#-2,d2			increase
	bra.s	fader
fade_in_terminal
	move.l	#col_pal,a6
	move.w	#atari_pal,a5
	moveq	#0,d7			fade speed
	move.w	#128-1,d0		no times
	moveq	#0,d1			init value
	moveq	#2,d2			increase
fader	move.l	a6,bar_base
.lp	move.w	#256-1,d3		do all colours
	lea	col_pal,a0
	lea	new_pal,a1
.lp1	moveq	#0,d4
	move.b	(a0)+,d4
	mulu	d1,d4
	lsr.w	#8,d4
	move.b	d4,(a1)+		red
	move.b	(a0)+,d4
	mulu	d1,d4
	lsr.w	#8,d4
	move.b	d4,(a1)+		green
	clr.b	(a1)+
	addq.l	#1,a0			skip byte
	move.b	(a0)+,d4
	mulu	d1,d4
	lsr.w	#8,d4
	move.b	d4,(a1)+		blue
	dbf	d3,.lp1
	add.w	d2,d1
	move.w	d7,d4
.lp2	bsr	term_wait_vbl
	dbf	d4,.lp2
	dbf	d0,.lp
	move.l	a5,bar_base
	rts

end_vbl	addq.w	#1,clock
	Move.w	#0,Scr_Mod
	Move.w	#0,Scr_Del
	movem.l	d0-a6,-(sp)
	move.l	tv_addr1,-(sp)
	move.b	1(sp),$ffff8201.w		tv set up
	move.b	2(sp),$ffff8203.w		tv set up
	move.b	3(sp),$ffff820d.w
	addq.l	#4,sp
	lea	new_pal,a0
	lea	(atari_pal).w,a1
	move.w	#256-1,d0
.lp	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	jsr	nt_vbl
	movem.l	(sp)+,d0-a6
	rte


end_screen
	move.l	$70.w,-(sp)
	move.l	#end_vbl,$70.w
	bsr	copy_coming
	bsr	fade_in_terminal
	bsr	wait_end

;	IFNE	inifite_loop
;.lop	bra.s	.lop
;	ELSE
	bsr	fade_out_terminal
	move.l	(sp)+,$70.w
	rts
;	ENDC

copy_coming
	lea	coming_soon,a0
	bra.s	cont_copy
copy_term
	lea	term_pic,a0
cont_copy
	move.l	#term_tv,d0
	and.b	#%11111100,d0
	move.l	d0,tv_addr1
	move.l	d0,a1
	move.w	#64000/4-1,d0
.lp	move.l	(a0)+,(a1)+
	dbf	d0,.lp
	lea	col_pal,a1
	move.w	#256-1,d0
.lp1	move.l	(a0)+,(a1)+
	dbf	d0,.lp1
	rts


term_main	bsr.s	copy_term
	bsr	fade_in_terminal
	bsr.s	do_terminal
	bsr	fade_out_terminal
	rts

do_terminal
	clr.l	(static_colour).w
	st	static_display
	st	static_fade_in
	bsr.s	stat_wait_0
	st	static_fade_out
	bsr.s	stat_wait_1
	sf	static_display
	
	bsr	term_wait_vbl
	bsr.s	cls_page
	bsr	term_wait_vbl
	bsr.s	cls_page
	st	piccy_start
	bsr	bang_fade_in
	st	flicker_on
	bsr	print_term
	bsr.s	wait_a_while
	bsr	bang_fade_out
	sf	flicker_on
	rts
wait_end
	move.w	#wait_3,d0
.lp	bsr	term_wait_vbl
	dbf	d0,.lp
	rts
	
stat_wait_0
	move.w	#wait_0,d0
.lp	bsr	term_wait_vbl
	dbf	d0,.lp
	rts
stat_wait_1
	move.w	#wait_1,d0
.lp	bsr	term_wait_vbl
	dbf	d0,.lp
	rts
wait_a_while
	move.w	#wait_2,d0
.lp	bsr	term_wait_vbl
	dbf	d0,.lp
	rts
cls_page
	moveq	#0,d0	1
	moveq	#0,d1	2
	moveq	#0,d2	3
	moveq	#0,d3	4
	moveq	#0,d4	5
	moveq	#0,d5	6
	moveq	#0,d6	7
	move.l	d6,a1	8
	move.l	d6,a2	8
	move.l	d6,a3	9
	move.l	d6,a4	10
	move.l	d6,a5	11
	move.l	d6,a6	12
	
	move.l	tv_addr1,a0
	lea	title_offset(a0),a0
	moveq	#main_high-1,d7
.lp	movem.l	d0-d6/a1-a6,(a0)
	movem.l	d0-d6/a1-a6,12*4(a0)
	movem.l	d0-d6/a1-a6,12*4*2(a0)
	movem.l	d0-d6/a1-a5,12*4*3(a0)
	lea	320(a0),a0
	dbf	d7,.lp
	move.l	tv_addr1,a0
	lea	window_offset(a0),a0
	moveq	#window_high-1,d7
.lp1	movem.l	d0-d6/a1-a6,(a0)
	movem.l	d0-d6/a1,12*4(a0)
	lea	320(a0),a0
	dbf	d7,.lp1
	rts

*************************************************
* Print routine for 5x5 font			*
*************************************************
scroll_term
	movem.l	d0-a6,-(sp)
	move.l	tv_addr1,a0
	lea	title_offset(a0),a0
	move.w	#main_high-1-6,d0
.loop	lea	6*320(a0),a1
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48*2(a0)
	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,48*3(a0)
	lea	320(a0),a0
	dbf	d0,.loop
	movem.l	(sp)+,d0-a6
	subq.w	#6,d1
	bra.s	scr_ret

print_term
	move.l	terminal_text(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	move	d0,d2			;save xpos
term_loop
	cmp.w	#max_y_term,d1
	beq.s	scroll_term
scr_ret	move.b	(a0)+,d7
	beq	.next_line
	bmi	.exit
*********************************
* Special characters		*
*********************************
	cmp.b	#".",d7
	bne.s	.notdot
	moveq	#36,d7	
	bra.s	.print
.notdot
	cmp.b	#"-",d7
	bne.s	.notdash
	moveq	#37,d7	
	bra.s	.print
.notdash
	cmp.b	#"!",d7
	bne.s	.notexcl
	moveq	#38,d7	
	bra.s	.print
.notexcl
	cmp.b	#"?",d7
	bne.s	.notqm
	moveq	#39,d7	
	bra.s	.print
.notqm
*********************************
* Numbers			*
*********************************
	cmp.b	#"0",d7
	blt.s	.space
	cmp.b	#"9",d7
	bgt.s	.not_num
	sub	#"0",d7
	bra.s	.print
.not_num
*********************************
* Letters			*
*********************************
	cmp.b	#"a",d7
	blt.s	.space
	cmp.b	#"z",d7
	bgt.s	.space
	sub	#"a"-10,d7
	bra.s	.print
.space
	moveq	#41,d7
.print
	bsr	.print_it
	tst.b	(a0)
	beq.s	.skipc1
	movem.l	d0/d7,-(sp)
	moveq	#40,d7
	addq	#6,d0
	bsr	.print_it
	movem.l	(sp)+,d0/d7
.skipc1
	bsr	.print_it
	tst.b	(a0)
	beq.s	.skipc2
	movem.l	d0/d7,-(sp)
	moveq	#40,d7
	addq	#6,d0
	bsr	.print_it
	movem.l	(sp)+,d0/d7
.skipc2
	addq	#6,d0 
	bra	term_loop
.next_line
	move	d2,d0
	addq	#6,d1
	bra	term_loop
.exit
	cmp.b	#-2,d7
	bne.s	.not_colour
	move.b	(a0)+,colour
	move.b	(a0)+,colour+1
	bra	term_loop
.not_colour
	cmp.b	#-3,d7
	bne.s	.no_save_pointer
	move.b	d0,save_x
	move.b	d1,save_y
	bra	term_loop
.no_save_pointer
	cmp.b	#-4,d7
	bne.s	.no_restore
	move.b	save_x,d0
	move.b	save_y,d1
	bra	term_loop
.no_restore
	cmp.b	#-7,d7
	bne.s	.no_restore1
	move.b	save_x,d0
	move.b	save_y,d1
	subq.w	#6,d1
	bra	term_loop
.no_restore1
	cmp.b	#-5,d7
	bne.s	.no_pause
	move.l	d7,-(sp)
	move.b	(a0)+,d7
.llp	bsr	term_wait_vbl
	dbf	d7,.llp
	move.l	(sp)+,d7
	bra	term_loop
.no_pause
	cmp.b	#-6,d7
	bne.s	.no_anim_play
	moveq	#0,d7
	move.b	(a0)+,d7
	movem.l	d0-a6,-(sp)
	bsr	play_anim
	movem.l	(sp)+,d0-a6
	bra	term_loop
.no_anim_play
	rts
*************************************************
* Print the characters				*
* d0	-	xpos				*
* d1	-	ypos				*
* d7	-	char				*
*************************************************
.print_it
	movem.l	d0-a6,-(sp)
	lea	termfont,a2
	mulu	#5,d7
	add	d7,a2
	move.l	tv_addr1,a1
	mulu	#320,d1
	add.l	d1,a1
	move	d0,d1
	and	#$fff0,d1
	sub	d1,d0
	add	d1,a1
	move	colour,d3
	moveq	#5-1,d2
.hiloop
	move.l	#$ffff07ff,d1
	ror.l	d0,d1
	and	d1,(a1)
	and	d1,2(a1)
	and	d1,4(a1)
	and	d1,6(a1)
	and	d1,8(a1)
	and	d1,10(a1)
	and	d1,12(a1)
	and	d1,14(a1)
	swap	d1
	and	d1,16(a1)
	and	d1,18(a1)
	and	d1,20(a1)
	and	d1,22(a1)
	and	d1,24(a1)
	and	d1,26(a1)
	and	d1,28(a1)
	and	d1,30(a1)

	moveq	#0,d1
	move.b	(a2)+,d1
	lsl	#8,d1
	ror.l	d0,d1
	swap	d1
	move	d1,d4
	swap	d1
	btst	#0,d3
	beq.s	.nop0
	or	d1,(a1)
	or	d4,16(a1)
.nop0
	btst	#1,d3
	beq.s	.nop1
	or	d1,2(a1)
	or	d4,18(a1)
.nop1
	btst	#2,d3
	beq.s	.nop2
	or	d1,4(a1)
	or	d4,20(a1)
.nop2
	btst	#3,d3
	beq.s	.nop3
	or	d1,6(a1)
	or	d4,22(a1)
.nop3
	btst	#4,d3
	beq.s	.nop4
	or	d1,8(a1)
	or	d4,24(a1)
.nop4
	btst	#5,d3
	beq.s	.nop5
	or	d1,10(a1)
	or	d4,26(a1)
.nop5
	btst	#6,d3
	beq.s	.nop6
	or	d1,12(a1)
	or	d4,28(a1)
.nop6
	btst	#7,d3
	beq.s	.nop7
	or	d1,14(a1)
	or	d4,30(a1)
.nop7
	lea	320(a1),a1
	dbf	d2,.hiloop
	bsr	term_wait_vbl
	movem.l	(sp)+,d0-a6
	rts	

colour	dc.l	0
	dcb.l	10,0

do_bars
	cmp.w	#24,bar_val
	blt.s	.ok1
	move.w	#23,bar_val
	move.w	#-1,bar_vdir
.ok1
	tst.w	bar_val
	bpl.s	.ok2
	move.w	#0,bar_val
	move.w	#1,bar_vdir
.ok2
	move.w	bar_vdir,d0
	add.w	d0,bar_val


	move.w	bar_val,d0
	moveq	#24-1,d1
	lea	bar_colours(pc),a0
.loop
	move.l	(a0)+,a1
	add.l	bar_base,a1
	move.l	(a0)+,d2
	subq.w	#1,d0
	bpl.s	.ok3
	moveq	#0,d2
.ok3
	move.l	d2,(a1)
	dbf	d1,.loop
	rts
bar_vdir	
	dc.w	1
bar_val	
	dc.w	0
bar_colours
	dc.l	(80*4),$0f000000
	dc.l	(79*4),$1e000000
	dc.l	(78*4),$2d000000
	dc.l	(77*4),$3c000000
	dc.l	(76*4),$4b000000
	dc.l	(75*4),$58000000
	dc.l	(74*4),$69000000
	dc.l	(73*4),$78000000
	dc.l	(72*4),$87000000
	dc.l	(71*4),$96000000
	dc.l	(70*4),$a5000000
	dc.l	(69*4),$b4000000
	dc.l	(68*4),$c3000000
	dc.l	(67*4),$d2000000
	dc.l	(66*4),$e1000000
	dc.l	(65*4),$f0000000

	dc.l	(104*4),$d21f0000
	dc.l	(103*4),$b43e0000
	dc.l	(102*4),$965d0000
	dc.l	(101*4),$787c0000
	dc.l	(100*4),$589b0000
	dc.l	(99*4),$3cba0000
	dc.l	(98*4),$1ed90000
	dc.l	(97*4),$00f80000

play_anim
	sf	flicker_on
	move.w	d7,-(sp)
	bsr	fade_out_terminal
	move.w	(sp)+,d7
	lea	anim_addrs,a0
	move.l	(a0,d7.w*4),a0
	moveq	#0,d0
	bsr	hum_animplay
	bsr	fade_in_terminal
	st	flicker_on
	rts


	include	Terminal\decode.s

swamp_world_text
	dc.b	18,8,-2,0,$fc
	dc.b	"----- fed-net uplink on line   ",0
	dc.b	"point-counterpoint encyclopedia",0
	dc.b	"    of federation worlds       ",0
	dc.b	"entry no - 38g95-3554m4403d74  ",0
	dc.b	"system   - carrion             ",0
	dc.b	"world    - swampworld          ",0 
	dc.b	"-------------------------------",0
	dc.b	-3,-2,0,$fe
	dc.b	"ernie says - this valuable and ",0
	dc.b	"uninhabited world is a noted   ",0
	dc.b	"preserve for several species of",0
	dc.b	"rare wading birds. this is one ",0
	dc.b	"of the few unspoilt landscapes ",0
	dc.b	"of the federation and its      ",0
	dc.b	"beauty is unsurpassed.         ",0
	dc.b	-2,0,$fc
	dc.b	"----- click now.               ",0
	dc.b	-5,50
	dc.b	-4,-2,0,$fd
	dc.b	"wallace says - swampworld is a ",0
	dc.b	"disgusting stinking little hole",0
	dc.b	"with not one single redeeming  ",0
	dc.b	"feature. there are no bars. no ",0
	dc.b	"strip joints and the whole     ",0
	dc.b	"place is living evidence that  ",0
	dc.b	"mother nature is a bitch of the",0
	dc.b	"first degree.                  ",0
	dc.b	-2,0,$fc
	dc.b	"----- click now.               ",0
	dc.b	-5,50
	dc.b	-1
scene_6_text
	dc.b	18,8,-2,0,$fe
	dc.b	"    federation news service    ",0
	dc.b	"-------------------------------",0
	dc.b	"transmission 34-7785-t5-55-d367",0
	dc.b	"                               ",0
	dc.b	"subject - "
	dc.b	-3,-2,0,$fd
	dc.b	"spacejunk "
	dc.b	-2,0,$fe
	dc.b	"project....",0
	dc.b	"                               ",0
	dc.b	-3,-2,0,$fd
	dc.b	"spacejunk-",0
	dc.b	-2,0,$fe
	dc.b	"         what is it?           ",0
	dc.b	-2,0,$fc
	dc.b	"      where do i get it ?      ",0
	dc.b	-2,0,$fe
	dc.b	"      is it contagious ?       ",0
	dc.b	"                               ",0
	dc.b	"   these questions and others  ",0
	dc.b	" have been flying around the   ",0
	dc.b	"federation for months now......",0
	dc.b	"                               ",0
	dc.b	"but we at trans federation can ",0
	dc.b	"exclusively reveal to you the  ",0
	dc.b	"secret of this mysterious      ",0
	dc.b	"entity....                     ",0
	dc.b	"                               ",0
	dc.b	-3,-2,0,$fd
	dc.b	"spacejunk"
	dc.b	-2,0,$fe
	dc.b	" the game.           ",0
	dc.b	-2,0,$fc
	dc.b	"so good you will wet your pants",0
	dc.b	-2,0,$fe
	dc.b	"                               ",0
	dc.b	"  what more can we say. other  ",0
	dc.b	"than its                       ",0
	dc.b	-2,0,$fc
	dc.b	-3
	dc.b	"    a tale of treachary...     ",0
	dc.b	-6,0
	dc.b	"    a tale of revenge.....     ",0
	dc.b	-6,1
	dc.b	"    and a tale of exploding    ",0
	dc.b	"         jellyfish.....        ",0
	dc.b	-2,0,$fe
	dc.b	-6,2
	dc.b	"                               ",0
	dc.b	"so there you have it. "
	dc.b	-3,-2,0,$fd
	dc.b	"spacejunk",0
	dc.b	-2,0,$fe
	dc.b	" the game. better than sitting ",0
	dc.b	"  at home with your hand in a  ",0
	dc.b	"         blender....           ",0
	dc.b	-2,0,$fc
	dc.b	"----- click now.               ",0
	dc.b	-5,50
	dc.b	-1
	even
which_term	dc.w	0		;-----!!!!!!!!******
anim_addrs	dc.l	treachary_anim
		dc.l	revenge_anim
		dc.l	jellyfish_anim
**    Falcon ProTracker    **
** Martin Randall 30/11/92 **

buff_size	equ	(1024*2)	10k buffer

		include	E:\Includes\snd_falc.i

_init_sound	
		movem.l	d0-d7/a0-a6,-(sp)	Preserve the regs
		locksnd				Get the DMA
		sndstatus	#1
		devconnect	#0,#$8,#0,#9,#1	10kHz samples
		soundcmd	#0,#$0000	Set left volume
		soundcmd	#1,#$0000	Set right volume
		soundcmd	#4,#2
		setmode		#0		8 bit stereo
		settracks	#0,#0	  		Play 1 track
		setmontracks	#0
		movem.l	(a7)+,d0-d7/a0-a6
		rts
		
_free_sound	
		movem.l	d0-d7/a0-a6,-(sp)	Preserve the regs
		unlocksnd
		movem.l	(a7)+,d0-d7/a0-a6
		rts
		
** Call with a0, pointing to the start of the MOD file

_pt_mod_on	bsr	_init_sound
		bsr	init_mod
pt_insert	lea	play_buff,a0
		lea	play_buff_end,a1
		bsr	init_play
		rts

_pt_mod_off	
pt_restore	bclr.b	#0,$ff8901	Stop playing
		rts

	**************************
	* Protracker VBL routine *
	**************************

protracker_play
nt_vbl		Movem.l	d0-d7/a0-a6,-(sp)	Preserve the regs


*		move.w	#$2000,d0
*.loop2		dbf	d0,.loop2

*		not.w	$ffff8240
*						get current buffer pos
	
		bclr	#7,$ff8901		Select play register
		moveq	#0,d1
		move.b	$ff8909,d1
		asl.w	#8,d1
		move.b	$ff890b,d1
		asl.l	#8,d1
		move.b	$ff890d,d1

		tst.l	buff_ptr
		bne.s	ptr_ok
		add.l	#200,d1
		move.l	d1,buff_ptr
		bra.s	gap_ok
			
ptr_ok		move.l	buff_ptr,d2

		sub.l	d2,d1		Old buffer pointer
		bpl.s	nt_ok
		add.l	#buff_size,d1		Calculate offset

nt_ok		cmp.l	#(buff_size/2),d1
		ble	no_play
		
		bsr	ntplay
	
gap_ok		move.l	buff_ptr,a0		Get current buffer pointer
		lea	play_buff_end,a6
		
		move.l	a0,d0
		addi.l	#198*2,d0
		cmp.l	d0,a6
		bgt.s	nt_ok2
		sub.l	#buff_size,d0

nt_ok2		move.l	d0,buff_ptr		Restore pointer
		
		lea	channel1,a1		Channel pointer
		moveq	#0,d6			Clear reg
		moveq	#0,d5
		moveq	#1,d0			4 channels
nt_l4		move.l	a0,-(a7)
		move.l	ch_samstart(a1),a3	Sample data #1
		move.l	ch_sampitch(a1),d4	Modulation value #1
		move.l	22+ch_samstart(a1),a4	Sample data #2
		move.l	22+ch_sampitch(a1),d7	Modulation value #2
		lea	vols,a2			Point to volume tables
		lea	vols,a5
		move.w	ch_samvol(a1),d3	Volume #1
		asl.w	#8,d3			Times 256
		lea	(a2,d3.w),a2		Point to volume table #1
		move.w	22+ch_samvol(a1),d3	Volume #2
		asl.w	#8,d3			Times 256
		lea	(a5,d3.w),a5		Point to volume table #2
		move.w	22+ch_samlen(a1),d3	Sample length #2
		subq.w	#1,d3
		swap	d3
		move.w	ch_samlen(a1),d3	Sample length #1
		subq.w	#1,d3
		moveq	#0,d1			Modulation offset #1
		moveq	#0,d2			Modulation offset #2
		swap	d0
		move.w	#197,d0			Move 198 bytes
nt_l3		move.b	(a3,d1.w),d5		Get sample byte
		move.b	(a2,d5.w),d6		Transfer byte #1
		move.b	(a4,d2.w),d5
		add.b	(a5,d5.w),d6		Transfer byte #2
		move.b	d6,(a0)
		moveq	#0,d6
		
		addq.l	#2,a0			Point to next byte
		cmp.l	a0,a6
		bgt.s	nt_ok3
		lea	-buff_size(a0),a0
		
nt_ok3		add.l	d4,d1			Update offset #1
		addx.w	d6,d1
		cmp.w	d1,d3			End of sample ?
		bgt.s	mod_ok			
		move.l	ch_samrepst(a1),a3	Repeat start
		move.w	ch_samreplen(a1),d3	Repeat length
		moveq	#0,d1			Reset offset
		
mod_ok		swap	d3			Get length of sample #2
		add.l	d7,d2			Update offset #2
		addx.w	d6,d2
		cmp.w	d2,d3			End of sample ?
		bgt.s	mod_ok2
		move.l	22+ch_samrepst(a1),a4	Repeat start
		move.w	22+ch_samreplen(a1),d3	Repeat length
		moveq	#0,d2			Reset offset
		
mod_ok2		swap	d3			Get length of sample #1
		dbf	d0,nt_l3		Loop for 200 bytes

nt_4		move.l	(a7)+,a0
		addq.l	#1,a0
		lea	(a3,d1.w),a3		New start #1
		move.l	a3,ch_samstart(a1)	Update sample start
		sub.w	d1,d3			New length #1
		move.w	d3,ch_samlen(a1)	Update sample length

		swap	d3			Get length #2
		lea	(a4,d2.w),a4		New start #2
		move.l	a4,22+ch_samstart(a1)	Update sample start
		sub.w	d2,d3			New length #2
		move.w	d3,22+ch_samlen(a1)	Update sample length
		
		lea	44(a1),a1
		swap	d0
		dbf	d0,nt_l4
no_play		movem.l	(a7)+,d0-d7/a0-a6
		rts
			
* Start the DMA playing

init_play	lea	null_sam,a2
		moveq	#2,d0
		moveq	#3,d1
		lea	channel1,a3
ip_l1		move.l	a2,ch_samstart(a3)
		move.l	a2,ch_samrepst(a3)
		move.l	#1,ch_sampitch(a3)
		move.w	d0,ch_samlen(a3)
		move.w	d0,ch_samreplen(a3)
		move.w	#$40,ch_samvol(a3)
		lea	22(a3),a3
		dbf	d1,ip_l1

		move.l	a0,d0		Set sound frame base
		move.b	d0,$ff8907
		asr.l	#8,d0
		move.b	d0,$ff8905
		asr.w	#8,d0
		move.b	d0,$ff8903
	
		move.l	a1,d0		Set sound frame top
		move.b	d0,$ff8913
		asr.l	#8,d0
		move.b	d0,$ff8911
		asr.w	#8,d0
		move.b	d0,$ff890f
		or.w	#3,$ff8900	Play
		bsr.s	init_vol
		bsr.s	init_pit
		rts
		
init_vol	lea	vols+(256*64),a0
		moveq	#$40,d0		Maximum volume
iv_l1		move.l	#255,d1		Number of settings
iv_l2		move.l	d1,d2
		sub.b	#$80,d2		Convert signed to unsigned
		mulu.w	d0,d2		Scale down to currnet volume
		divu.w	#$40,d2
		add.b	#$80,d2
		asr.b	d2		Precalc for merging
 		move.b	d2,(a0,d1.w)	Enter byte into table
		dbf	d1,iv_l2
		lea	-256(a0),a0	Next table
		dbf	d0,iv_l1
		rts
		
init_pit	move.l	#428,d0		Base note
		swap	d0
		move.l	#800,d1		801 pitches
		moveq	#108,d2		Starting with 108
		lea	snd_table,a0
ip_l2		move.l	d0,d3
		divu.l	d2,d3		Get modulation value
		swap	d3
		move.l	d3,(a0)+
		addq.l	#1,d2		Next pitch
		dbf	d1,ip_l2
		rts
		
		even
		
null_sam	dc.l	0		Silence !	


	include E:\Includes\protrack.i

snd_table	ds.l	802	The pitches
 	

vols	ds.b	256*65

buff_ptr	ds.l	1

play_buff	dcb.l	buff_size/4,0	play buffer
play_buff_end
			
	Even

**********************************************************

	Rsreset
Mouse_X		Rs.w	1
Mouse_Y		Rs.w	1
Clear		Rs.w	16
Reg_Save1	Rs.l	16
Reg_Save2	Rs.l	16
Screen_Mode	Rs.w	1
Old_Mode	Rs.w	1
Mod_Save	Rs.w	1
Del_Save	Rs.w	1
Vbl_Save	Rs.l	1
Screenp		Rs.l	2
Panel_P		Rs.l	2
Text_Packet	Rs.l	10
Randolf_Wait	Rs.w	1

Panel_PSave	Rs.l	2
Panel_Buffer1	Ds.b	48*32
Panel_Buffer2	Ds.b	48*32
Special_Address	Rs.l	1

Intens		Rs.w	3
MAP_X		RS.W	1
MAP_Y		RS.W	1
Randolf_X	Rs.w	1
Randolf_Y	Rs.w	1
Map_X_Display	Rs.w	1
Map_Y_Display	Rs.w	1
Sprite_Height	Rs.w	1
Sprite_Width	Rs.w	1
Screen_Width	Rs.l	1
Num_Words	Rs.w	1
Sprite_X_Save	Rs.w	2
Sprite_X_Count	Rs.w	1
Max_Visible_X	Rs.w	1
Mouse_Height_To_Draw	Rs.w	1
Base_Text_Pointer	Rs.l	1
Pointer_To_Text_Packets	Rs.l	1
Fire_Width_Save	Rs.w	1
Fire_Block_Width	Rs.w	1
Sprite_Width_Save	Rs.w	1
Special_Anims_Pointer	Rs.l	1
Message_Base		Rs.l	1
Mouse_Moves		Rs.l	1
Randolf_Moves		Rs.l	1


Dest_Pal	Rs.l	256
Left_Button_Pressed	Rs.b	1
Right_Button_Pressed	Rs.b	1
Mypal		Rs.b	4*256
Init_Text	Rs.b	1
Special_Anim_Delay	Rs.b	1
Special_Anim_Number	Rs.b	1
Doing_Terminal	Rs.b	1
Vga_Flag	Rs.b	1
Vbl_Flag	Rs.b	1
Scroll_Left_Right	Rs.b	1
Panel_Split	Rs.b	1
Scroll_Up_Down		Rs.b	1
UP		RS.B	1
Down		RS.B	1
Left		RS.B	1
Right		RS.B	1
Rope_Anim_Flag	Rs.b	1
Rope_Anim_Dec	Rs.b	1
Rope_Frame	Rs.b	1
Scene		Rs.b	1
Fire_Anim_Flag	Rs.b	1
Flag_For_Text	Rs.b	1
Special_Anim_Done	Rs.b	1
Anim_Seq	Rs.b	1
Special_Anims	Rs.b	1
Do_Walk_To_Door	Rs.b	1
No_Draw_Randolf	Rs.b	1
Walk_Frame	Rs.b	1
Walk_Frame_Del	Rs.b	1
Exit_My_Demo	Rs.b	1
Fire_Anim_Dec	rs.b	1
Fire_Frame	Rs.b	1
Quit_Prog	Rs.b	1
Randolf_Anim	Rs.b	1
Init_Animseq	Rs.b	1
Randolf_Anim_Delay	Rs.b	1
Spit_Del	Rs.b	1
Spit_Num	Rs.b	1
Do_Spit		Rs.b	1
Doing_Bird	Rs.b	1
Bird_Del	Rs.b	1
Bird_Anim	Rs.b	1




Panel_Message	Rs.b	100
Varend		Rs.b	0


Data	Ds.b	Varend
	Even

Mouse_Script

	
Randolf_Script
	Init_Sequence		Terminal_Pickup
	Wait	90
	Special_Sequence	Terminal_Pickup
	Wait	100
	Exit_Script
	Init_Sequence		Terminal_Take
	Wait	20
	SPECIAL_Sequence	Terminal_Take
	Wait	7
	Init_Randolf
	Move_R	2,0,40
	Special_Sequence	Look_Seq
	Wait	100
	Exit_Script
	Special_Sequence	Look_Seq2
	Wait	30
	Init_Randolf
	Move_R	2,0,130
	Init_Randolf
	Wait	10
	Special_Sequence	Spit_Seq
	Spit_Do
	Init_Randolf
	Wait	30
	Move_R	2,0,20
	Init_Randolf
	Do_Bird	
	Wait	50
	Move_R	2,0,104
	Init_Rany		
	Start_Billy
	Wait	100
	Exit_Script
	Wait	30
	Special_Sequence	Turn_Round_Seq
	Wait	10
	Start_Walking_Towards_Door
	Test_Exit_Script
	Exit_Script
	

Randolf_Sprites	Incbin	F:\Junk\Main\Randolf\Randolf.Lib
MOUSE_SPRITE	Incbin	f:\Junk\Main\Terminal\Junk_Mou.Spr


PLAYFIELD_pal	Include	F:\Junk\Main\Walkbout\Scape.Pal
PLAYFIELD	Incbin	f:\Junk\Main\Walkbout\Scape.Bin
PLAYFIELD_MASK	Incbin	F:\Junk\Main\Walkbout\MASK.Bin
		Ds.w	1
		Cnop	0,4
Panel1		Incbin	F:\Junk\Main\Terminal\Panel.Img
		Ds.w	1
		Cnop	0,4
Panel2		Incbin	F:\Junk\Main\Terminal\Panel.Img
		even
This_Mod	Incbin	F:\Junk\Main\Main.Mod
		even
Fire_Gfx	Incbin	F:\Junk\Main\Walkbout\Bills.Bin
		even
Bird_Gfx	Incbin	f:\Junk\Main\Walkbout\Birds.Bin
		even
Walk_To_Gfx	Incbin	f:\Junk\Main\Walkbout\Walk.Bin
		even

Rope_Base	
	Incbin	f:\Junk\Main\Walkbout\Rope01.Img
	Incbin	f:\Junk\Main\Walkbout\Rope02.Img
	Incbin	f:\Junk\Main\Walkbout\Rope03.Img
	Incbin	f:\Junk\Main\Walkbout\Rope04.Img
	Incbin	f:\Junk\Main\Walkbout\Rope05.Img
	Incbin	f:\Junk\Main\Walkbout\Rope06.Img
	Incbin	f:\Junk\Main\Walkbout\Rope07.Img
	Incbin	f:\Junk\Main\Walkbout\Rope08.Img
	Incbin	f:\Junk\Main\Walkbout\Rope09.Img
	Incbin	f:\Junk\Main\Walkbout\Rope10.Img
	Incbin	f:\Junk\Main\Walkbout\Rope11.Img
	Incbin	f:\Junk\Main\Walkbout\Rope12.Img

Look_Anim	Incbin	f:\Junk\Main\Walkbout\Look.Lib
		even
Spit_Anim	Incbin	f:\Junk\Main\Walkbout\Spit.Lib
		even
Pickup_Terminal	Incbin	f:\Junk\Main\Walkbout\Pickterm.Lib
		even
term_pic	incbin	Terminal\terminal.spa
		even
coming_soon	incbin	Terminal\end.spa
		even
revenge_anim	incbin	Terminal\anims\revenge.exa
		even
jellyfish_anim	incbin	Terminal\anims\jelyfish.exa
		even
treachary_anim	incbin	Terminal\anims\treachry.exa
		even
Last_Anim	Incbin	f:\Junk\Main\Locate2\Andys.Fan
		Even
Turn_Round_Seq
	Dc.l	Look_Anim
	Dc.b	2,0,1,2
	Dc.b	-1
	Even
	
Look_Seq2
	Dc.l	Look_Anim
	Dc.b	3
	DC.B	4,3,2,1,0,-1
	Even
Look_Seq
	Dc.l	Look_Anim
	Dc.b	2,0,1,2,3,4,4,4,5,5,5,4,4,4,6,3,8,9
	Rept	2
	Dc.b	10,11,10,11
	Endr
	Dc.b	9,8,3,4
	Dc.b	-1
	Even

Terminal_Pickup
	Dc.l	Pickup_Terminal
	Dc.b	3,0,1,2,3,4,5,6,7,8,9,10,11,12,13
	DC.B	14,15
	DC.B	14,15
	DC.B	16,17
	DC.B	16,17
	DC.B	16,17,16,17,16
	DC.B	-1
	Even

Terminal_Take
	Dc.l	Pickup_Terminal
	Dc.b	3,16,17,18,-1
	Even

Spit_Seq
	Dc.l	Spit_Anim
	Dc.b	2,0,1,0,1,2,3,-1
	Even

	Include	Conversf.s
	Opt	C-
	SECTION	BSS
	DS.L	1000
Anim_Bufferr
	Ds.l	1200000/4
term_clear_start
piccy_start	ds.b	1
static_fade_out	ds.b	1
static_display	ds.b	1
static_fade_in	ds.b	1
save_x		ds.b	1
save_y		ds.b	1
fgcol		ds.b	1
flicker_on	ds.b	1
hum_answap:	ds.b	1			;frame swap flag
hum_antrigger:	ds.b	1			;next frame trigger
hum_ancopy:	ds.b	1			;copy bases flag
hum_anloop:	ds.b	1			;loop flag
hum_anfire:	ds.b	1			;fire pressed flag
hum_andelay	ds.b	1
	even
term_clock	ds.w	1
bar_base	ds.l	1
fade_index	ds.w	1
static_addr	ds.l	1
col_pal_term	ds.l	256
new_pal_term	ds.l	256
tv_addr1	ds.l	1
		ds.l	1
clock		ds.w	1
col_pal		ds.l	256
new_pal		ds.l	256
hum_loadarea	ds.l	1
hum_vclock:	ds.l	1			;clock
hum_antriggr:	ds.w	2			;next frame count/refresh
hum_ancomp:
hum_anlog:	ds.l	1			;logical anim address
hum_anphy:	ds.l	1			;physical anim address

hum_anframes:	ds.w	1			;number of frames in anim
hum_anframe:	ds.w	1			;current frame
hum_annumber:	ds.w	1			;number of anim playing

hum_paladdr	ds.l	1
hum_animpal	ds.l	256
hum_ancolours:	ds.b	256*4
running		ds.b	1
mouse_hide	ds.b	1
dialogue_on	ds.b	1
mouse_off	ds.b	1
mouse_on	ds.b	1
mouse_left_pressed	ds.b	1
	even
conv_mouse_x	ds.w	1
conv_mouse_y	ds.w	1
button		ds.w	1
anim_addr	ds.l	1
anim_timer	ds.w	1
reply_addr	ds.l	1
piccy_addr	ds.l	1
text_addr	ds.l	1
button_addrs	ds.l	4
anim_screens	ds.l	2
anim_pal	ds.l	256
mouse_hide_addr	ds.l	1+8*mouse_height
conversation_area	ds.b	320*(200-160)
conversation_area_end
answer_area	ds.b	320*(200-160)
answer_area_end


term_clear_end

term_tv
hum_anbuffers:	equ	term_tv+64000+8

	DS.W	2
tv_screen
SCREEN1		Ds.b	Screenwide*200
	DS.W	2
SCREEN2		Ds.b	Screenwide*200

 
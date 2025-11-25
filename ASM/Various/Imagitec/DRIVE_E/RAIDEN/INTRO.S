MakeDisk=0
	Include	E:\INCLUDES\SYSTREGS.INC
	Ifeq	Makedisk
	Include	Spool.s
	Endc

Height		Equ	240
Ship_Left	Equ	121
Ship_Mid	Equ	161
Ship_Right	Equ	200
Ship_y		Equ	150

	Rsreset
Spr_Use		Rs.w	1
Spr_Yadd	Rs.w	1
spr_Addr	Rs.l	1		; Weapon sprite structure
Spr_Height	Rs.w	1
Spr_Plane	Rs.w	1
Spr_Width	Rs.w	1
Rmask		Rs.w	1
Spr_E		Rs.w	0

Frame_Rate	Equ	1
Byteswide	Equ	384

Atari_Logo	Equ	1
Second_Screen	Equ	1



Start	
	Ifne	Makedisk
	Move.l	a7,Stacksave
	Endc
	Bsr	Go
	Clr.w	-(sp)
	Trap	#1
	Include	Keyboard.s
		
	OPT	D+
Go	
	Ifeq	Makedisk
	Move.l	a7,Stacksave
	Lea	Hi_score_Table,a0
	Move.l	#$00050000,d0
	Move.b	#1,d1
	Move.b	#3,d2
	Move.l	#$00150000,d3
	Move.b	#2,d4
	Move.b	#3,d5
	Endc
	Move.l	a0,Hiscore_table_Address
	Move.l	d0,What_Ya_Scored
	Move.b	d1,Level_Num
	Move.b	d2,Stage_Num
	Move.l	d3,What_Ya_Scored2
	Move.b	d4,Level_Num2
	Move.b	d5,Stage_Num2
	

	Bsr	Init			; Initialize

	Move.l	#Pl1_Mess,Pl_Messp
	Move.l	#Pl2_Mess,Pl_Messp+4
	Bsr	Check_New_Hi_Score
	Movem.l	Pl_Messp,d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Pl_Messp
	Move.l	What_Ya_Scored2,What_Ya_Scored
	Move.b	Level_Num2,Level_Num
	Move.b	Stage_Num2,Stage_Num
	St	P2_Flag(a4)
	Bsr	Check_New_Hi_Score
	Bsr	Pt_Vol_Slide_DN
	Moveq	#64,d1
	Bsr	Wait_Vbl

	Sf	Play_Mod(a4)
	Movem.l	d0-a6,-(sp)
	Bsr	pt_mod_off
	Movem.l	(sp)+,d0-a6

	Moveq	#64,d1
	Bsr	Wait_Vbl

	Lea	Intromod,a0
	Move.l	a0,a1
	Movem.l	d0-a6,-(sp)
	Bsr	pt_mod_on	
	Bsr	pt_Vol_on	
	Movem.l	(sp)+,d0-a6
	St	Play_Mod(a4)

Main	
	Ifne	Atari_Logo
	Sf	Can_Exit(a4)
	Bsr	Atari_Part
	Endc
	St	Can_Exit(a4)
	Bsr	Backdrop_Part
	Bsr	Hiscore_Displaypart
	Bsr	Scrollpart
	Bra.s	Main
Load_Here
	Bsr	Load_Part
	Bra	Quit		

***********************************************************
Check_New_Hi_Score
	Move.l	What_Ya_Scored,d0
	Move.l	Hiscore_table_Address,a0
	Moveq	#10-1,d6
.Loop	Moveq	#0,d1
	Lea	12(a0),a1
	Moveq	#7,d7
.Loopx	Lsl.l	#4,d1
	Move.b	(a1)+,d2
	Sub.b	#"0",d2
	Or.b	d2,d1
	Dbra	d7,.Loopx
	Cmp.l	d0,d1
	Blt.s	.Hi_Score_Found
	Lea	27(a0),a0
	Dbra	d6,.Loop
	Rts

.Hi_Score_Found
	Move.w	d6,-(sp)
	Pea	(a0)
	Subq.w	#1,d6
	Move.l	Hiscore_table_Address,a0
	Lea	27*10(a0),a0
	Lea	-27(a0),a1
.Insert_Score_Loop
	Moveq	#27-1,d7
.Insert_Loop
	Move.b	-(a1),-(a0)
	Dbra	d7,.Insert_Loop
	Dbra	d6,.Insert_Score_Loop
	Move.l	(sp)+,a0
	Move.l	a0,Name_Addr(a4)
	Move.l	#"    ",(a0)+
	Move.l	#"    ",(a0)+
	Move.l	#"    ",(a0)+
	Lea	What_Ya_Scored,a1
	Moveq	#3,d0
.Loop1	Move.b	(a1)+,d1
	Move.b	d1,d2
	Lsr.b	#4,d1
	And.w	#$f,d1
	And.w	#$f,d2
	Add.b	#"0",d1
	Add.b	#"0",d2
	Move.b	d1,(a0)+
	Move.b	d2,(a0)+
	Dbra	d0,.Loop1
	Addq.l	#3,a0
	Move.b	Level_Num,(a0)+
	Add.b	#"0",-1(a0)
	Addq.l	#1,a0
	Move.b	Stage_Num,(a0)+
	Add.b	#"0",-1(a0)

NEW_HI_SCORE
	Lea	Hiscore_Pack,a0
	Lea	Decrunch_Buffer,a1
	Bsr	ice_decrunchit
	Lea	Decrunch_Buffer,a0
	Move.l	Screenp(a4),a1
	Lea	Mypal(a4),a2
	Bsr	Decode_VGA
	Bsr	Build_Text_For_Hiscore
	Move.w	#130,d0
	Move.w	#14,d1
	Move.w	#54,d2
	Bsr	Blit_A_Sprite
	Move.w	#132,d0
	Move.w	#23,d1
	Move.w	#55,d2
	Bsr	Blit_A_Sprite
	Move.l	Pl_Messp,a0
	Move.w	#170,d0
	Move.w	#3,d1
.Tloop	Move.b	(a0)+,d2
	Bmi.s	.Exit_Txt
	Cmp.b	#" ",d2
	Beq.s	.Skip_TXT
	Move.l	Screenp(a4),a1
	Bsr	Ascii_To_Spritedata
	Bsr	Blit_A_Sprite
.Skip_TXT
	Addq.w	#8,d0
	Bra.s	.Tloop	

.Exit_Txt
	Bsr	Swap_Screens
	Movem.l	Screenp(a4),a0-a1
	Move.l	#384*240,d0
.Copy_Screens
	Move.b	(a1)+,(a0)+
	Subq.l	#1,d0
	Bne.s	.Copy_Screens
	Tst.b	Played_Hi_Intro_Mod(a4)
	Bne.s	.Yes
	St	Played_Hi_Intro_Mod(a4)
	Lea	Highmod,a0
	Move.l	a0,a1
	Movem.l	d0-a6,-(sp)
	Bsr	pt_mod_on	
	Bsr	Pt_Vol_Slide_UP
	Movem.l	(sp)+,d0-a6
	St	Play_Mod(a4)
.Yes	Move.w	(sp)+,d6
	Sub.w	#9,d6
	Neg.w	d6
	Mulu	#9,d6	
	Move.w	#112,d1
	Add.w	d6,d1
	Move.w	#106,d0
	Movem.w	d0-d1,Cursor_X(a4)	
	Move.b	#"A",Cursor_Val(a4)
	Clr.b	Cursor_Num(a4)

.Loop	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Copy_Line_Of_Text
	Bsr	Print_Cursor
	Bsr	Print_Cursor_Ascii
	Bsr	Full_Fadeup
	Bne.s	.Loop
	
Main_cursor
	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Copy_Line_Of_Text
	Bsr	Read_Joy
	Bsr	Get_New_Cursor_Num
	Bsr	Print_Cursor
	Bsr	Print_Cursor_Ascii
	Bsr	Save_Cursor
	Cmp.b	#11,Cursor_Num(a4)
	Bne.s	Main_Cursor

	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Copy_Line_Of_Text

.Loop	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Full_Fadedn
	Bne.s	.Loop
	
	Rts

***********************************************************


***********************************************************
Save_Cursor
	Tst.b	P2_Flag(a4)
	Beq.s	.Norm
	Bsr	Fire_A_Pressed_2
	Beq.s	.Pressed
	Bsr	Fire_B_Pressed_2
	Beq.s	.Pressed
	Bsr	Fire_C_Pressed_2
	Beq.s	.Pressed
	Sf	Fire_Pressed(a4)
	Rts
.Norm	Bsr	Fire_A_Pressed
	Beq.s	.Pressed
	Bsr	Fire_B_Pressed
	Beq.s	.Pressed
	Bsr	Fire_C_Pressed
	Beq.s	.Pressed
	Sf	Fire_Pressed(a4)
.Yes	Rts
.Pressed
	Tst.b	Fire_Pressed(a4)
	Bne.s	.Yes
	St	Fire_Pressed(a4)
	Movem.w	Cursor_X(a4),d0-d1
	Move.b	Cursor_Val(a4),d2
	Move.l	Name_Addr(a4),a3
	Move.b	d2,(a3)+
	Move.l	a3,Name_Addr(a4)
	Cmp.b	#" ",d2
	Beq.s	.No
	Bsr	Ascii_To_Spritedata
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite
.NO	Addq.w	#8,Cursor_X(a4)
	Addq.b	#1,Cursor_Num(a4)
	Rts

y***********************************************************
Print_Cursor
	Tst.b	Cursor_Count(a4)
	Bne.s	.No_Flip
	Not.b	Cursor_Blink(a4)
.No_Flip
	Tst.b	Cursor_Blink(a4)
	BEQ.S	.No_Print
	Movem.w	Cursor_X(a4),d0-d1
	Addq.w	#8,d0
	Move.w	#53,d2
	Move.l	Screenp+4(a4),a1
	Bra	Blit_A_Sprite
.No_Print
	Rts

************************************************************
	
Print_Cursor_Ascii
	Movem.w	Cursor_X(a4),d0-d1
	Move.b	Cursor_Val(a4),d2
	Cmp.b	#" ",d2
	Beq.s	.No
	Bsr	Ascii_To_Spritedata
	Move.l	Screenp+4(a4),a1
	Bra	Blit_A_Sprite
.No	Rts

***********************************************************
Copy_Line_Of_Text
	Movem.w	Cursor_x(a4),d0-d1
	Mulu	#Byteswide,d1
	Movem.l	Screenp(a4),a0-a1
	Add.l	d1,a0
	Add.l	d1,a1
	Move.w	#9,-(sp)
.Loop	
	Rept	7
	Movem.l	(a0)+,d0-d7/a2-a6
	Movem.l	d0-d7/a2-a6,(a1)
	Lea	52(a1),a1
	Endr
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Move.l	(a0)+,(a1)+
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Lea	Data(pc),a4
	Rts

***********************************************************
Get_New_Cursor_Num
	Cmp.b	#" ",Cursor_Val(a4)
	Bne.s	.Next
	Tst.b	Left_Pressed(a4)
	Beq.s	.No_Left
	Move.b	#"Z",Cursor_Val(a4)
	Bra.s	.Do_It
.No_Left
	Tst.b	Right_Pressed(a4)
	Beq.s	.Exit
	Move.b	#"A",Cursor_Val(a4)
	Bra.s	.Do_It
.Exit	Rts
.Next	Move.b	Left_Pressed(a4),d0
	Move.b	Right_Pressed(a4),d1
	And.b	#$1,d1
	Add.b	d1,d0
	Add.b	d0,Cursor_Val(a4)
.Do_It
	Move.b	Cursor_Val(a4),d0
	And.w	#$ff,d0
	Cmp.w	#"A",d0
	Bge.s	.GTA	
	Move.b	#" ",d0	
.GTA	Cmp.w	#"Z",d0
	Ble.s	.LEZ
	Move.b	#" ",d0	
.LEZ	Move.b	d0,Cursor_Val(a4)
	Rts

***********************************************************
Read_Joy
	Sf	Left_Pressed(a4)
	Sf	Right_Pressed(a4)
	Tst.b	Cursor_Count(a4)
	Bne.s	.No_Dir
	Bsr	Read_Joypad
	Bsr	Direction_Pressed
	Tst.b	P2_Flag(a4)
	Beq.s	.Pl1
	Bsr	Direction_Pressed_2
.Pl1	Btst	#2,d0
	Seq	Left_Pressed(a4)
	Btst	#3,d0
	Seq	Right_Pressed(a4)
.No_Dir	Rts

***********************************************************
Load_Carrier_Blocks
	Lea	MapCarrier_Name,a0
	Lea	Map,a1
	Trap	#15
	Lea	BlockCarrier_Name,a0
	Lea	Blocks,a1
	Trap	#15
	Lea	PalCarrier_Name,a0
	Lea	Mypal(a4),a1
	Trap	#15
	Rts

***********************************************************
Load_Part
	Moveq	#1,d1
	Bsr	Wait_Vbl
	Lea	Dest_pal(a4),a0
	Move.w	#255,d0
.Loopx	Clr.l	(a0)+
	Dbra	d0,.Loopx
	Clr.w	Intens(a4)	
	Lea	Load_Pack,a0
	Lea	Decrunch_Buffer,a1
	Bsr	ice_decrunchit
	Lea	Decrunch_Buffer,a0
	Move.l	Screenp(a4),a1
	Lea	Mypal(a4),a2
	Bsr	Decode_VGA
	St	Cycle_Load(a4)
	Bsr	Swap_Screens
.Loop	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Full_Fadeup
	Bne.s	.Loop
	Move.w	#199,d7
.Loop2	Moveq	#1,d1
	Bsr	Wait_Vbl
	Dbra	d7,.Loop2
	Rts

***********************************************************
Scrollpart
	Move.l	#Map+7396,Map_Address(a4)
	Bsr	Clear_Screens
	Bsr	Move_In_Scroll_Pallete
.Loop0	
	Moveq	#3,d1
	Bsr	Wait_Vbl
	Bsr	Scroll_Loop
	Bsr	Full_Fadeup
	Bne.s	.Loop0
	Move.w	#200,-(sp)
.Main	Moveq	#3,d1
	Bsr	Wait_Vbl
	Bsr	Scroll_Loop
	Subq.w	#1,(sp)
	Bne.s	.Main
	Addq.l	#2,sp
.Loop1	Moveq	#3,d1
	Bsr	Wait_Vbl
	Bsr	Scroll_Loop
	Bsr	Full_Fadedn
	Bne.s	.Loop1
	Rts
	

***********************************************************
Scroll_Loop
	Bsr	Buildmap
	Bsr	Draw_Some_Scrolly_Sprites
	Move.w	#276,d0
	Move.w	#20,d1
	Bsr	Print_Hiscore
	Bsr	Scroll_Up
	Bsr	Swap_Screens
	Rts

***********************************************************
Print_Hiscore
	Subq.b	#1,Hiscoredel(a4)
	Bgt.s	.No
	Move.b	#40,Hiscoredel(a4)
	Addq.b	#1,Hiscoretype(a4)
	Cmp.b	#3,Hiscoretype(a4)
	Bne.s	.No
	Clr.b	Hiscoretype(a4)
.No	Moveq	#0,d3
	Move.b	Hiscoretype(a4),d3
	Jmp	.Type(pc,d3*4)
	
.Type	
	JMP	Game_Over(pc)
	JMP	Print_Score(pc)
	JMP	Press_Fire(pc)


Game_Over
	Moveq	#43,d2
	Move.l	Screenp(a4),a1
	Bra	Blit_A_Sprite

Press_Fire
	Sub.w	#30,d0
	Moveq	#44,d2
	Move.l	Screenp(a4),a1
	Bra	Blit_A_Sprite
	

Print_Score
	Move.l	Hiscore_Table_Address,a0
	Lea	12(a0),a0
	Move.w	#8,-(sp)
.Loop	Move.b	(a0)+,d2
	Bsr	Ascii_To_Spritedata
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite
	Add.w	#9,d0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts
	
***********************************************************
Plate_Part
	Lea	Data(pc),a4
	Move.b	#3,Plat_Del(a4)
	St	Fire_1_Pressed(a4)
	St	Fire_2_Pressed(a4)
	Bsr	Copy_Appearance_Rom_To_Ram
.Loop	Moveq	#2,d1
	Bsr	Wait_Vbl
	Bsr	Put_On_Plates
	Tst.b	Plates_Done(a4)
	Beq.s	.Loop
	Bsr	Load_Carrier_Blocks
	Bsr	Format_Carrier_Blocks
	MOVE.L	#MAP+(60*28)+6,MAP_ADDRESS(A4)
	Move.w	#0,Pixel_Scroll_Offset(a4)
	Bsr	Buildmap
	Lea	Mypal(a4),a0
	Lea	Carrier_Sprite_Banks,a5
	Lea	208*4(A0),A6
	Moveq	#48-1,d7
.Cloop	Move.l	(a5)+,(a6)+
	Dbra	d7,.Cloop
	Clr.l	(a0)
	Lea	Dest_pal(a4),a1
	Move.w	Intens(a4),d0
	Move.w	#256,d1
	Bsr	Scale_Pal
	Lea	Ship_Coards(a4),a0
	Move.b	Fire_1_Pressed(a4),d3
	Move.b	Fire_2_Pressed(a4),d4
	Eor.b	d4,d3
	Beq.s	.Play2

	Tst.b	Fire_1_Pressed(a4)
	Beq.s	.Play_2_Only
	Move.w	#45,(a0)+
	Move.w	#Ship_Mid,(a0)+
	Move.w	#Ship_Y,(a0)+
.Play_2_Only
	Tst.b	Fire_2_Pressed(a4)
	Beq.s	.No_Pressed2
	Move.w	#46,(a0)+
	Move.w	#Ship_Mid,(a0)+
	Move.w	#Ship_Y,(a0)+
	Bra.s	.No_Pressed2
.Play2	Move.w	#45,(a0)+
	Move.w	#Ship_Left,(a0)+
	Move.w	#Ship_Y,(a0)+
	Move.w	#46,(a0)+
	Move.w	#Ship_Right,(a0)+
	Move.w	#Ship_Y,(a0)+
.No_Pressed2
	St	(a0)
	Bsr	DrawPlayer_Sprites
	Bsr	Animate_Boosters
	Bsr	Draw_Boosters_And_Platforms

	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Copy_Appearance_Rom_To_Ram
.Loop1	Moveq	#2,d1
	Bsr	Wait_Vbl
	Bsr	Take_Plates_Off
	Tst.b	Plates_Done(a4)
	Beq.s	.Loop1
	Pea	Accel_Table(pc)
	Move.l	(sp)+,Accel_P(a4)
.Loop2	Moveq	#3,d1
	Bsr	Wait_Vbl
	Bsr	Buildmap
	Bsr	Animate_Boosters
	Bsr	DrawPlayer_Sprites
	Bsr	Draw_Boosters_And_Platforms
	Bsr	Swap_Screens
	Bsr	Accelerate
	Tst.b	Ready_To_Quit_Carrier_Scroll(a4)
	Beq.s	.Loop2

.Loop3	Moveq	#3,d1
	Bsr	Wait_Vbl
	Bsr	Buildmap
	Bsr	Animate_Boosters
	Bsr	DrawPlayer_Sprites
	Bsr	Draw_Boosters_And_Platforms
	Lea	Ship_Coards(a4),a0
	Tst.b	Fire_1_Pressed(a4)
	Beq.s	.No_1_Fire
	Subq.w	#2,4(a0)
	Addq.l	#6,a0
.No_1_Fire
	Tst.b	Fire_2_Pressed(a4)
	Beq.s	.No_2_Fire
	Subq.w	#2,4(a0)
.No_2_Fire
	Bsr	Swap_Screens
	Move.w	Accel_Val(a4),-(sp)
.Loop4	Bsr	Scroll_Up
	Addq.w	#1,Scroll_Val_Add(a4)
	Subq.w	#1,(sp)
	Bne.s	.Loop4
	Addq.l	#2,sp
	Bsr	Full_Fadedn
	Bne.s	.Loop3
	Bra	Load_Here

***********************************************************
Animate_Boosters
	Cmp.w	#40,Booster_Del(a4)
	Bne	Animate_Platform
	Not.b	Boost_Flip(a4)
	Rts
Animate_Platform
	Addq.w	#1,Booster_Del(a4)
	Tst.w	Platform_Val(a4)
	Bne.s	.Already_Set
	Move.w	#49,Platform_Val(a4)
	Rts
.Already_Set
	Cmp.w	#52,Platform_Val(a4)
	Beq.s	.Exit
	Subq.b	#1,Plat_Del(a4)
	Ble.s	.Ok_Add
	Rts
.Ok_Add
	Move.b	#3,Plat_Del(a4)
	Addq.w	#1,Platform_Val(a4)
.Exit	Rts
***********************************************************
Draw_Boosters_And_Platforms
	Lea	Ship_Coards(a4),a0
.Loop	Tst.w	(a0)
	Bmi.s	.Done
	Move.w	0(a0),d2
	Move.w	2(a0),d0
	Move.w	4(a0),d1
	Move.w	Platform_Val(a4),d2
	Add.w	#40,d1
	Add.w	Scroll_Val_Add(a4),d1
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite

	Cmp.w	#40,Booster_Del(a4)
	Bne.s	.No_Boost
	Move.w	(a0)+,d2
	Move.w	(a0)+,d0
	Move.w	(a0)+,d1
	Subq.l	#6,a0
;*&*&
	Add.w	#26,d1
	Moveq	#47,d2
	Move.b	Boost_Flip(a4),d3
	And.w	#1,d3
	Add.w	d3,d2
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite
.No_Boost
	Addq.l	#6,a0
	Bra	.Loop
.Done	Rts

***********************************************************
DrawPlayer_Sprites
	Lea	Ship_Coards(a4),a0
.Loop	Move.w	(a0)+,d2	
	Bmi.s	.Exit
	Move.w	(a0)+,d0	
	Move.w	(a0)+,d1
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite
	Bra.s	.Loop
.Exit	Rts

***********************************************************
Accelerate
	Tst.w	Accel_Del(a4)
	Beq.s	.No_Del
.Accel_Anyway
	Move.w	Accel_Val(a4),-(sp)
	Beq.s	.No
.Loop	Bsr	Scroll_Up
	Addq.w	#1,Scroll_Val_Add(a4)
	Subq.w	#1,(sp)
	Bne.s	.Loop
.No	Addq.l	#2,sp
	Subq.w	#1,Accel_Del(a4)
.Exit	Rts
.No_Del	
	Move.l	Accel_P(a4),a0
	Move.w	(a0)+,Accel_DEl(a4)
	Smi	Ready_To_Quit_Carrier_Scroll(a4)
	Bmi.s	.Accel_Anyway
	Move.w	(a0)+,Accel_Val(a4)
	Move.l	a0,Accel_P(a4)
	Bra	Accelerate

Accel_Table
	Dc.w	50,0
	Dc.w	12,2
	Dc.w	13,3
	Dc.w	13,4
	Dc.w	12,5
	Dc.w	13,6
	Dc.w	13,7
	Dc.w	-1

***********************************************************
Format_Carrier_Blocks
	Lea	Map,a0
	Addq.l	#2,a0
	Move.w	(a0),-(sp)
	Move.w	(a0)+,-(sp)
	Addq.l	#4,a0
	Move.l	Screenp(a4),a1
.Loop	Clr.w	(a1)+
	Clr.w	(a1)+
	Clr.w	(a1)+
	Moveq	#23,d0
.Loop1	Move.w	(a0)+,(a1)+
	Dbra	d0,.Loop1
	Clr.w	(a1)+
	Clr.w	(a1)+
	Clr.w	(a1)+
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Lea	Map,a0
	Move.l	Screenp(a4),a1
.Loop2	Moveq	#29,d0
.Loop3	Move.w	(a1)+,(a0)+
	Dbra	d0,.Loop3
	Subq.w	#1,(sp)
	Bne.s	.Loop2
	Addq.l	#2,sp
	Rts	

***********************************************************
Put_On_Plates
	St	Plates_Done(a4)
	Lea	Plate_Appearance_Ram,a0
	Lea	Plate_Map,a1
	Addq.l	#8,a1
	Lea	Plate_Blocks,a2
	Move.l	Screenp+4(a4),a6
	Move.w	#15,-(sp)
.Loop0	Pea	Byteswide*16(a6)
	Move.w	#24,-(sp)
.Loop1	Pea	16(a6)
	Subq.b	#1,(a0)+
	BEQ.s	.No_Plates_Done
	Bmi.s	.Skip_Plate
	Sf	Plates_Done(a4)
	Bra.s	.Skip_Plate
.No_Plates_Done
	Moveq	#0,d0
	Move.b	(a1),d0
	Lsl.w	#8,d0
	Lea	(a2,d0.w),a3
	Moveq	#15,d0
.Loop2	Movem.l	(a3)+,d1-d4
	Movem.l	d1-d4,(a6)
	Lea	Byteswide(a6),a6
	Dbra	d0,.Loop2
.Skip_Plate
	Move.l	(sp)+,a6
	Addq.l	#1,a1
	Subq.w	#1,(sp)
	Bne.s	.Loop1
	Addq.l	#2,sp
	Move.l	(sp)+,a6
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp
	Rts	

***********************************************************
Take_Plates_Off
	St	Plates_Done(a4)
	Lea	Plate_Appearance_Ram,a0
	Movem.l	Screenp(a4),a5-a6
	Move.w	#15,-(sp)
.Loop0	
	Pea	Byteswide*16(a6)
	Pea	Byteswide*16(a5)
	Move.w	#24,-(sp)
.Loop1	Pea	16(a6)
	Pea	16(a5)
	Subq.b	#1,(a0)+
	BEQ.s	.No_Plates_Done
	Bmi.s	.Skip_Plate
	Sf	Plates_Done(a4)
	Bra.s	.Skip_Plate
.No_Plates_Done
	Moveq	#15,d0
.Loop2	Movem.l	(a5),d1-d4
	Movem.l	d1-d4,(a6)
	Lea	Byteswide(a5),a5
	Lea	Byteswide(a6),a6
	Dbra	d0,.Loop2
.Skip_Plate
	Movem.l	(sp)+,a5-a6
	Subq.w	#1,(sp)
	Bne.s	.Loop1
	Addq.l	#2,sp
	Movem.l	(sp)+,a5-a6
	Subq.w	#1,(sp)
	Bne.s	.Loop0
	Addq.l	#2,sp
	Rts	


***********************************************************
Scroll_Up
	Addq.w	#1,Pixel_Scroll_Offset(a4)
	And.w	#$f,Pixel_Scroll_Offset(a4)
	Bne.s	.Nx
	Sub.l	#60,Map_Address(a4)
.Nx	Rts

***********************************************************
Buildmap
	Lea	Blitterstuff,a6
.Wb	Btst	#7,Line_num(a6)
	Bne.s	.Wb
	Move.b	#02,Hop(a6)
	Move.b	#00,Skew(a6)
	Move.b	#$3,Op(a6)
	Move.w	#2,Src_Xinc(a6)
	Move.w	#0,Src_Yinc(a6)
	Move.w	#2,Dst_Xinc(a6)
	Move.w	#Byteswide-14,Dst_Yinc(a6)
	Move.w	#-1,Endmask1(a6)
	Move.w	#-1,Endmask2(a6)
	Move.w	#0,Endmask3(a6)
	Bsr	Clip_Top_Row
	
	Move.l	Map_Address(a4),a0
	Add.l	#60,a0
	Move.l	Screenp(a4),a5
	Move.w	Pixel_Scroll_Offset(a4),d0
	Mulu	#Byteswide,d0
	Add.l	d0,a5
	Lea	Blocks,a1
	Move.w	#14,-(sp)
.Loop1	Pea	Byteswide*16(a5)
	Pea	60(a0)
	Move.w	#24,-(sp)
.Loop2	Move.w	(a0)+,d0
	Ror.w	#8,d0
	Mulu	#14*16,d0
	Lea	(a1,d0.l),a2
	Move.l	a2,Src_Addr(a6)
	Move.l	a5,Dst_Addr(a6)
	Move.w	#8,X_Count(a6)
	Move.w	#16,Y_Count(a6)
	Move.b	#$c0,Line_Num(a6)
	Lea	16(a5),a5
	Subq.w	#1,(sp)
	Bne.s	.Loop2
	Addq.l	#2,sp
	Movem.l	(sp)+,a0/a5
	Subq.w	#1,(sp)
	Bne.s	.Loop1
	Addq.l	#2,sp
	Bsr	Clip_BotTom_Row
	Move.b	#0,Op(a6)
	Move.l	Screenp(a4),a1
.Wb2	Btst	#7,Line_num(a6)
	Bne.s	.Wb2
	Lea	14(a1),a1
	Move.l	a1,Src_Addr(a6)
	Move.l	a1,Dst_Addr(a6)
	Move.w	#0,Src_Xinc(a6)
	Move.w	#0,Src_Yinc(a6)
	Move.w	#0,Dst_Xinc(a6)
	Move.w	#16,Dst_Yinc(a6)
	Move.w	#1,X_Count(a6)
	Move.w	#240*(384/16),Y_Count(a6)
	Move.b	#$c0,Line_Num(a6)
	Rts
	
***********************************************************
Clip_BotTom_Row
	Move.l	Map_Address(a4),a0
	Add.l	#60*15,a0
	Move.l	Screenp(a4),a5
	Add.l	#Byteswide*16*14,a5
	Move.w	Pixel_Scroll_Offset(a4),d7
	Move.w	d7,d0
	Mulu	#Byteswide,d0
	Add.l	d0,a5
	Add.w	#16*14,d7
	Sub.w	#240,d7
	Neg.w	d7
	Beq.s	.Nobottomline
	Lea	Blocks,a1
	Move.w	#24,-(sp)
.Loop2	Move.w	(a0)+,d0
	Ror.w	#8,d0
	Mulu	#14*16,d0
	Lea	(a1,d0.l),a2
	Move.l	a2,Src_Addr(a6)
	Move.l	a5,Dst_Addr(a6)
	Move.w	#8,X_Count(a6)
	Move.w	d7,Y_Count(a6)
	Move.b	#$c0,Line_Num(a6)
	Lea	16(a5),a5
	Subq.w	#1,(sp)
	Bne.s	.Loop2
	Addq.l	#2,sp
.Nobottomline
	Rts

***********************************************************
Clip_Top_Row
	Move.l	Map_Address(a4),a0
	Move.l	Screenp(a4),a5
	Move.w	Pixel_Scroll_Offset(a4),d0
	Lea	Blocks,a1
	Move.w	d0,d7
	Beq.s	.No_Scroll
	Sub.w	#16,d0
	Neg.w	d0
	Mulu	#14,d0
	Add.l	d0,a1
	Move.w	#24,-(sp)
.Loop2	Move.w	(a0)+,d0
	Ror.w	#8,d0
	Mulu	#14*16,d0
	Lea	(a1,d0.l),a2
	Move.l	a2,Src_Addr(a6)
	Move.l	a5,Dst_Addr(a6)
	Move.w	#8,X_Count(a6)
	Move.w	d7,Y_Count(a6)
	Move.b	#$c0,Line_Num(a6)
	Lea	16(a5),a5
	Subq.w	#1,(sp)
	Bne.s	.Loop2
	Addq.l	#2,sp
.No_Scroll
	Rts
	
***********************************************************
Draw_Some_Scrolly_Sprites
	Move.w	#247,d0
	Add.w	#32,d0
	Move.w	#002,d1
	Move.w	#0,d2
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite
	Move.w	#061,d0
	Add.w	#32,d0
	Move.w	#062,d1
	Move.w	#1,d2
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite
	Move.w	#025,d0
	Add.w	#32,d0
	Move.w	#180,d1
	Move.w	#2,d2
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite
	Move.w	#074,d0
	Add.w	#32,d0
	Move.w	#192,d1
	Move.w	#3,d2
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite
	Rts
		
***********************************************************
Blit_A_Sprite
	Movem.l	d0-a6,-(sp)
	Lea	Blitterstuff,a6
Wb	Btst	#7,Line_num(a6)
	Bne.s	Wb
	Move.w	#18,Src_Xinc(a6)
	Move.w	#0,Src_Yinc(a6)
	Move.w	#16,Dst_Xinc(a6)
	Move.w	#-1,Endmask2(a6)
	Move.b	#02,Hop(a6)
	
	Lea	Intro_Sprites,a0
	Lsl.w	#4,d2
	Lea	(a0,d2),a0
	Add.w	Spr_Yadd(a0),d1
	Move.w	d1,-(sp)
	Moveq	#$f,d7
	And.w	d0,d7
	And.l	#$fff0,d0
	Move.b	d7,Skew(a6)
	Lea	Lfm,a3
	Move.w	00(a3,d7*2),Endmask1(a6)
	Move.w	32(a3,d7*2),Endmask3(a6)
	Mulu	#Byteswide,d1
	Add.l	d0,d1
	Add.l	a1,d1
	Move.l	Spr_Addr(a0),d0
	Move.w	Spr_Height(a0),d2
	Move.w	Spr_Width(a0),d3
	Move.w	d2,d4
	Add.w	(sp)+,d4
	Cmp.w	#Height,d4
	Ble.s	.No_Clip
	Sub.w	#Height,d4
	Sub.w	d4,d2
	Ble	.Dont_Draw_Sprite
.No_Clip
	Add.w	#$10,d3
	Move.w	#Byteswide+16,d4
	Sub.w	d3,d4
	Move.w	d4,Dst_Yinc(a6)
	Lsr.w	#4,d3
	Move.b	#$01,Op(a6)
	Moveq	#7,d7
.Loop	Move.l	d0,Src_Addr(a6)
	Move.l	d1,Dst_Addr(a6)
	Move.w	d2,Y_Count(a6)
	Move.w	d3,X_Count(a6)
	Move.b	#$c0,Line_Num(a6)
	Addq.l	#2,d1
	Dbra	d7,.Loop
	Move.b	#$07,Op(a6)
	Sub.l	#16,d1
	Addq.l	#2,d0
	Moveq	#7,d7
.Loop1	Move.l	d0,Src_Addr(a6)
	Move.l	d1,Dst_Addr(a6)
	Move.w	d2,Y_Count(a6)
	Move.w	d3,X_Count(a6)
	Move.b	#$c0,Line_Num(a6)
	Addq.l	#2,d1
	Addq.l	#2,d0
	Dbra	d7,.Loop1
.Dont_Draw_Sprite
	Movem.l	(sp)+,d0-a6
	Rts
	
***********************************************************
Atari_Part
	Lea	Atari_Pack,a0
	Lea	Decrunch_Buffer,a1
	Bsr	ice_decrunchit
	Lea	Decrunch_Buffer,a0
	Move.l	Screenp(a4),a1
	Lea	Mypal(a4),a2
	Bsr	Decode_VGA
	Bsr	Swap_Screens
.Loop	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Full_Fadeup
	Bne.s	.Loop
	Bsr	Wait4secs
.Loop5	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Full_Fadedn
	Bne.s	.Loop5
	Rts


***********************************************************
Hiscore_Displaypart
	Lea	Hiscore_Pack,a0
	Lea	Decrunch_Buffer,a1
	Bsr	ice_decrunchit
	Lea	Decrunch_Buffer,a0
	Move.l	Screenp(a4),a1
	Lea	Mypal(a4),a2
	Bsr	Decode_VGA
	Bsr	Build_Text_For_Hiscore
	Bsr	Swap_Screens
.Loop	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Full_Fadeup
	Bne.s	.Loop
	Bsr	Wait4secs
.Loop5	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Full_Fadedn
	Bne.s	.Loop5
	Rts

***********************************************************
Build_Text_For_Hiscore
	Move.l	Hiscore_Table_Address,a0
;	Lea	Hi_Score_Table,a0
	Move.w	#112,d1
.Loop	Move.w	#106,d0
.Loop1	Move.b	(a0)+,d2	
	Bmi.s	.Done_this_Line
	Cmp.b	#$20,d2
	Beq.s	.Skip_Blit
	Bsr	Ascii_To_Spritedata
	Move.l	Screenp(a4),a1
	Bsr	Blit_A_Sprite
.Skip_Blit
	Addq.w	#8,d0
	Bra.s	.Loop1
.Done_this_Line
	Add.w	#9,d1
	Tst.b	(a0)
	Bmi.s	.Exit
	Bra.s	.Loop
.Exit	Rts

***********************************************************
Ascii_To_Spritedata
	And.w	#$ff,d2
	Move.b	Ascii_Convert_Table(pc,d2),d2
	Rts

Ascii_Convert_Table
	Ds.b	$30
	Dc.b	4,5,6,7,8,9,10,11,12,13
	Ds.b	$41-$3a
	Dc.b	14,15,16,17,18,19,20,21,22,23,24,25,26
	Dc.b	27,28,29,30,31,32,33,34,35,36,37,38,39
	Ds.b	$61-$3a-26
	Dc.b	14,15,16,17,18,19,20,21,22,23,24,25,26
	Dc.b	27,28,29,30,31,32,33,34,35,36,37,38,39
	Ds.b	256-$61-26
	Even
	
***********************************************************
Backdrop_Part
	Bsr	Decrunch_Backdrop1
.Loop	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Full_Fadeup
	Bne.s	.Loop
	Bsr	Wait4secs
.Loop1	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Half_Fadedn
	Bne.s	.Loop1
	Ifne	Second_Screen
	Bsr	Decrunch_Backdrop2
.Loop2	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Half_Fadeup
	Bne.s	.Loop2
	Bsr	Wait4secs
.Loop3	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Half_Fadedn
	Bne.s	.Loop3
	Endc
	Bsr	Decrunch_Backdrop3
.Loop4	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Half_Fadeup
	Bne.s	.Loop4
	Bsr	Wait4secs
.Loop5	Moveq	#1,d1
	Bsr	Wait_Vbl
	Bsr	Full_Fadedn
	Bne.s	.Loop5
	Rts

***********************************************************
Wait4secs
	Move.w	#200,-(sp)
.Loop	Moveq	#1,d1
	Bsr	Wait_Vbl
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts

***********************************************************
Half_Fadeup
; a0=Source pallete , a1=Dest pallete, d0= Intensity, d1=Number !
	Lea	Mypal(a4),a0
	Lea	Dest_pal(a4),a1
	Move.w	Intens(a4),d0
	Move.w	#128,d1
	Bsr	Scale_Pal
	Addq.w	#8,Intens(a4)
	Cmp.w	#256,Intens(a4)
	Bgt.s	.Ok
	Moveq	#-1,d0
	Rts
.Ok	Moveq	#0,d0
	Rts

***********************************************************
Half_Fadedn
; a0=Source pallete , a1=Dest pallete, d0= Intensity, d1=Number !
	Lea	Mypal(a4),a0
	Lea	Dest_pal(a4),a1
	Move.w	Intens(a4),d0
	Move.w	#128,d1
	Bsr	Scale_Pal
	Sub.w	#4,Intens(a4)
	Blt.s	.Ok
	Moveq	#-1,d0
	Rts
.Ok	Moveq	#0,d0
	Rts


***********************************************************
Full_Fadeup
; a0=Source pallete , a1=Dest pallete, d0= Intensity, d1=Number !
	Lea	Mypal(a4),a0
	Lea	Dest_pal(a4),a1
	Move.w	Intens(a4),d0
	Move.w	#256,d1
	Bsr	Scale_Pal
	Addq.w	#8,Intens(a4)
	Cmp.w	#256,Intens(a4)
	Bgt.s	.Ok
	Moveq	#-1,d0
	Rts
.Ok	Moveq	#0,d0
	Rts

***********************************************************
Full_Fadedn
; a0=Source pallete , a1=Dest pallete, d0= Intensity, d1=Number !
	Lea	Mypal(a4),a0
	Lea	Dest_pal(a4),a1
	Move.w	Intens(a4),d0
	Move.w	#256,d1
	Bsr	Scale_Pal
	Sub.w	#4,Intens(a4)
	Blt.s	.Ok
	Moveq	#-1,d0
	Rts
.Ok	Moveq	#0,d0
	Rts

***********************************************************
Decrunch_Backdrop3
	Lea	Backdrop3,a0
	Bsr	Decrunch_Backdrop
	Rts
Decrunch_Backdrop2
	Lea	Backdrop2,a0
	Bsr	Decrunch_Backdrop
	Rts
Decrunch_Backdrop1
	Lea	Backdrop1,a0
	Bsr	Decrunch_Backdrop
	Rts
Decrunch_Backdrop
	Pea	(a0)
	Bsr	Clear_Screen
	Move.l	(sp)+,a0
	Lea	Decrunch_Buffer,a1
	Bsr	ice_decrunchit
	Bsr	Move_In_Backdrop_Pallete
	Bsr	Convert_Backdrop
	Bsr	Swap_Screens
	Rts

***********************************************************
Move_In_Backdrop_Pallete
	Moveq	#1,d1
	Bsr	Wait_Vbl
	Lea	Decrunch_Buffer+64000,a0
	Lea	Mypal(a4),a1
	Move.w	#256,d0
	Bra	Quick_Copy_Long

***********************************************************
Move_In_Scroll_Pallete
	Lea	Logo_Palette,a1
	Lea	Mylogo_Palette,a0
	Move.w	#128,d0
	Bsr	Quick_Copy_Long
	Moveq	#1,d1
	Bsr	Wait_Vbl
	Lea	Scroll_Pallete,a0
	Lea	Mypal(a4),a1
	Move.w	#256,d0
	Bra	Quick_Copy_Long
***********************************************************
Convert_Backdrop
	Lea	Decrunch_Buffer,a0
	Move.l	Screenp(a4),a1
	Move.w	#200-1,d0
.Loop	Lea	32(a1),a1
	Move.w	#320-1,d1
.Loop1	Move.b	(a0)+,(a1)+
	Dbra	d1,.Loop1
	Lea	32(a1),a1
	Dbra	d0,.Loop
	Rts

***********************************************************

Swap_Screens
	Movem.l	Screenp(a4),d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenp(a4)
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
Init	Lea	Data(pc),a4		; Globals
	Bsr	Install_Screen		; Set logical screen base
	Bsr	Cleardata		; Clear all globals
	Ifeq	Makedisk
	Bsr	Setup_Screen_Mode	; 8 plane / overscan
	Endc
	Bsr	Setup			; Supervisor + Shit
	Bsr	Setup_Screens		; Clear both screens
	Bsr	Make_Sprites
	Bsr	Make_Plate_Vals
	Bsr	Make_Title_Palette
	Bsr	Loadinmap
	Bsr	Save_Vbl		; Save vertical blank
	Rts

**********************************************************
Make_Plate_Vals
	Lea	Plate_Pos,a0
	Lea	Plate_Appearance_Rom,a1
	Moveq	#1,d7
.Loop	Tst.w	(a0)
	Bpl.s	.Pos
	Tst.w	2(a0)
	Bmi.s	.Done
	Addq.l	#2,a0
	Addq.w	#1,d7	
.Pos	Moveq	#0,d0
	Moveq	#0,d1
	Move.b	(a0)+,d0
	Move.b	(a0)+,d1
	Mulu	#24,d1
	Add.l	d1,d0
	Move.b	d7,(a1,d0.l)
	Bra.s	.Loop
.Done	Rts



**********************************************************
Make_Title_Palette
	Lea	Scroll_Pallete+128*4,a0
	Lea	Logo_Palette,a1
	Move.w	#128*4-1,d0
.Loop	Move.b	(a1)+,(a0)+
	Dbra	d0,.Loop
	Rts

**********************************************************
Loadinmap
	Lea	Blockname,a0
	Lea	Blocks,a1
	Trap	#15
	Lea	Mapname,a0
	Lea	Map,a1
	Trap	#15
	Rts
	
**********************************************************
Make_Sprites
	Lea	Intro_Sprites,a0
	Move.w	#499,d0
	Move.l	a0,d6
.Loop	Add.l	d6,Spr_Addr(a0)
	Lea	spr_E(a0),a0
	Dbra	d0,.Loop
	Rts

**********************************************************
Install_Screen
	Move.w	#-1,-(sp)
	Move.l	#Screen1,-(sp)
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
	Move.w	#$63,Screen_Mode(a4)	; Normal ST monitor 8 bpl,320x256
.Skip	Bsr	Setmode			; Set screen mode 8bps,PAL/OVERscan!
	Rts

**********************************************************
Quit	Move.l	Stacksave,a7
	Bsr	Pt_Mod_Off
	Ifeq	Makedisk
	Bsr	Fade_Syspal
	Endc
	Lea	Data(pc),a4
	Move.w	Mod_Save(a4),Scr_Mod
	Move.w	Del_Save(a4),Scr_Del
	Move.l	Vbl_save(a4),$70.w			
	Move.w	Old_Mode(a4),Screen_Mode(a4)	
	Ifeq	Makedisk
	Bsr	Setmode			
	Endc
	Rts
	
**********************************************************
; supervisor + save sys state!

Setup	Move.w	Scr_Del,Del_Save(a4)
	Move.w	Scr_Mod,MOD_Save(a4)
	move	#37,-(sp)
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
	Move.l	#Screen1,d0	
	Move.l	#Screen2,d1
	Moveq	#-4,d2			; Mask long word boundry
	And.l	d2,d0
	And.l	d2,d1
	Movem.l	d0-d1,Screenp(a4)	; Save screen pointers
	Bsr	Clear_Screens
	Rts

**********************************************************
Clear_Screen
	Move.l	Screenp(a4),a0
	Move.l	#384*240/4-1,d0
.Loop	Clr.l	(a0)+
	Dbra	d0,.Loop
	Rts

**********************************************************
; Clear both screens

Clear_Screens
	Movem.l	Screenp(a4),a0-a1
	Move.l	#384*240/4-1,d0
.Loop	Clr.l	(a0)+
	Clr.l	(a1)+
	Dbra	d0,.Loop
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
; Add to Vbl_Count

New_Vbl	
 	Movem.l	d0-a6,-(sp)
	Lea	Data(pc),a4
	Move.l	Screenp+4(a4),a0
	Bsr	Write_Screen
	Tst.b	Cycle_Load(a4)
	Beq.s	.No_Cycle2
	Bsr	Cycle_Load_routine
.No_Cycle2
	Bsr	Copy_Dest
	Addq.b	#1,Vbl_Flag(a4)
	Tst.b	Play_Mod(a4)
	Beq.s	.No_Mod
	Jsr	Pt_Vbl
.No_Mod	Addq.b	#1,Cursor_Count(a4)
	Cmp.b	#5,Cursor_Count(a4)
	Bne.s	.No_Curs
	Subq.b	#5,Cursor_Count(a4)
.No_Curs
	Tst.b	Can_Exit(a4)
	Beq.s	.No_Check
	Tst.b	Exit_Flag(a4)
	Bne.s	.No_Check
  	Cmp.w	#256,Intens(a4)
	Blt.s	.No_Check

	Tst.b	Fire_1_Pressed(a4)
	Bne.s	.Joy2
	Bsr	Read_Joypad
	Bsr	Fire_a_Pressed
	Beq.s	.Joy1Pressed
	Bsr	Fire_b_Pressed
	Beq.s	.Joy1Pressed
	Bsr	Fire_c_Pressed
	Beq.s	.Joy1Pressed
.Joy2	Tst.b	Fire_2_Pressed(a4)
	Bne.s	.Final_Check
	Bsr	Fire_a_Pressed_2
	Beq.s	.Joy2Pressed
	Bsr	Fire_b_Pressed_2
	Beq.s	.Joy2Pressed
	Bsr	Fire_c_Pressed_2
	Beq.s	.Joy2Pressed
.Final_Check
	Tst.b	Button_Del(a4)
	Beq.s	.No_Check
	Subq.b	#1,Button_Del(a4)
	Beq.s	.Exit_Prog

.No_Check
	Movem.l	(sp)+,d0-a6
	Rte

.Exit_Prog
	St	Exit_Flag(a4)
	Movem.l	(sp)+,d0-a6
	Move.l	#Plate_Part,2(sp)
	Rte

.Joy1Pressed
	St	Fire_1_Pressed(a4)
	Tst.b	Button_Del(a4)	
	Bne.s	.Exit_Prog
	Move.b	#100,Button_Del(a4)
	Bra.s	.Joy2

.Joy2Pressed
	St	Fire_2_Pressed(a4)
	Tst.b	Button_Del(a4)	
	Bne.s	.Exit_Prog
	Move.b	#100,Button_Del(a4)
	Bra.s	.No_Check

***********************************************************


***********************************************************
Cycle_Load_routine
	Lea	Dest_pal(a4),a0
	Lea	Mypal(a4),a2
	Lea	128*4(a0),a0
	Lea	128*4(a2),a2
	Move.l	a0,a1
	Move.l	a2,a3
	Move.l	(a0)+,-(sp)
	Move.l	(a2)+,-(sp)
	Move.w	#175-128,d0
.Loop	Move.l	(a0)+,(a1)+
	Move.l	(a2)+,(a3)+
	Dbra	d0,.Loop
	MOve.l	(sp)+,(a3)+
	Move.l	(sp)+,(a1)+
	Rts

***********************************************************
Copy_Dest
	Lea	Dest_Pal(a4),a0
	Lea	Pal256,a1
	Move.w	#256,d0
	Bsr	Quick_Copy_Long
	Rts

***********************************************************
; Wait for framerate, then clear!
Wait_Vbl
	Subq.b	#1,d1
	Move.b	Vbl_Flag(a4),d0
.Wait	Cmp.b	Vbl_Flag(a4),d0
	Beq.s	.Wait
.Skip	Cmp.b	Vbl_Flag(a4),d1
	Bcc.s	.Skip
	Sf	Vbl_Flag(a4)
	Rts

**********************************************************
; a0=Source pallete , a1=Dest pallete, d0= Intensity, d1=Number !
; Note pallete is in 3 byte RGB format , and throws out in 4 bytes !

Scale_Pal
	Tst.w	d0
	Bpl.s	.Pos
	Move.w	#0,d0
.Pos	Cmp.w	#256,d0
	Ble.s	.Ok
	Move.w	#256,d0
.Ok	Subq.w	#1,d1
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

0**********************************************************
; a0=LBM VGA pic, a1=Dest, a2=Pointer to pallete (saves in 3 bytes!)
; Note DEST needs around 64,000 bytes !

Decode_VGA
	Pea	(a1)
	Move.l	(sp),a1
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
	Clr.b	(a2)+
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
	Move.l	(sp)+,a1
	Move.l	a1,a0
	Move.w	#240-1,d0
.Loop1	Move.w	#384/16-1,d1
.Loop2	Move.w	#$8000,d3
	Clr.l	-(sp)
	Clr.l	-(sp)
	Clr.l	-(sp)
	Clr.l	-(sp)
.Loop4	Move.l	sp,a6
	Move.b	(a0)+,d2
	Moveq	#7,d4
.Loop3	Lsr.b	#1,d2
	Bcc.s	.Nocarry
	Or.w	d3,(a6)
.Nocarry
	Addq.l	#2,a6
	Dbra	d4,.Loop3
	Ror.w	#1,d3
	Bcc.s	.Loop4
	Move.l	(sp)+,(a1)+
	Move.l	(sp)+,(a1)+
	Move.l	(sp)+,(a1)+
	Move.l	(sp)+,(a1)+
	Dbra	d1,.Loop2
	Dbra	d0,.Loop1
	Rts

**********************************************************
Copy_Appearance_Rom_To_Ram
	Lea	Plate_Appearance_Rom,a0
	Lea	Plate_Appearance_Ram,a1
	Move.w	#24*15-1,d0
.Loop	Move.b	(a0)+,(a1)+
	Dbra	d0,.Loop
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
	Include	C:\Pack_Ice\Ice_Unpa.s
Hiscore_table_Address
	Ds.l	1
What_Ya_Scored
	Ds.l	1
Level_Num
	Ds.b	1
Stage_Num
	Ds.b	1
What_Ya_Scored2
	Ds.l	1
Level_Num2
	Ds.b	1
Stage_Num2
	Ds.b	1

**********************************************************

	Rsreset
Clear		Rs.w	16
Screen_Mode	Rs.w	1
Old_Mode	Rs.w	1
Mod_Save	Rs.w	1
Del_Save	Rs.w	1
Vbl_Save	Rs.l	1
Screenp		Rs.l	2
Intens		Rs.w	3
Accel_P		Rs.l	1
Accel_Del	Rs.w	1
Accel_Val	Rs.w	1
Cursor_X	Rs.w	2
Cursor_Val	Rs.b	1
Cursor_Num	Rs.b	1
Name_Addr	Rs.l	1

Dest_Pal	Rs.l	256
Mypal		Rs.b	4*256
Pixel_Scroll_Offset	Rs.w	1
Map_Address		Rs.l	1
Ship_Coards	Rs.w	3*10
Booster_Del	Rs.w	1
Platform_Val	Rs.w	1
Scroll_Val_Add	Rs.w	1



Can_Exit	Rs.b	1
Ready_To_Quit_Carrier_Scroll	Rs.b	1
Left_Pressed	Rs.b	1
Right_Pressed	Rs.b	1
Fire_Pressed	Rs.b	1
Cursor_Blink	Rs.b	1
Play_Mod	Rs.b	1
P2_Flag		Rs.b	1
Boost_Flip	Rs.b	1
Plat_Del	Rs.b	1
Cursor_Count	Rs.b	1
Played_Hi_Intro_Mod	Rs.b	1
Button_Del	Rs.b	1
Hiscoredel	Rs.b	1
Hiscoretype	Rs.b	1
Vga_Flag	Rs.b	1
Vbl_Flag	Rs.b	1
Exit_Flag	Rs.b	1
Plates_Done	Rs.b	1
Fire_1_Pressed	Rs.b	1
Fire_2_Pressed	Rs.b	1
Cycle_Load	Rs.b	1



Varend		Rs.b	0

Stacksave	Ds.l	1

Data	Ds.b	Varend
	Even

**********************************************************
	Ifeq	Makedisk
Hi_Score_Table
; 10 chars for name, 8 for score, 3 for level
;	Dc.b	"          ","        ","   ",-1
	Dc.b	"FREDDY      ","00200000","   8 1",-1
	Dc.b	"KEVNOS      ","00100000","   8 1",-1
	Dc.b	"SHAUN       ","00090000","   8 1",-1
	Dc.b	"ANDY        ","00080000","   8 1",-1
	Dc.b	"BIG MARV    ","00070000","   8 1",-1
	Dc.b	"BANANA      ","00060000","   8 1",-1
	Dc.b	"KICKBOXER   ","00050000","   8 1",-1
	Dc.b	"GREEN       ","00040000","   8 1",-1
	Dc.b	"BEEHIVE     ","00030000","   8 1",-1
	Dc.b	"HOWIE       ","00020000","   8 1",-1
	Dc.b	-1
	Even
	Endc

**********************************************************
Carrier_Sprite_Banks
	Incbin	E:\Raiden\Introdat\SPRITES\shipPAL.BIN

**********************************************************
	Include	E:\Protrack\Ptfalcon.s
Intromod
	Incbin	E:\Raiden\Introdat\Music\Mod.Rai
	Ds.l	100
Highmod
	Incbin	E:\Raiden\Introdat\Music\Mod.Nam
	Ds.l	100

Scroll_Pallete
	Incbin	E:\Raiden\Level_1\Pal.Bin
Logo_Palette=Scroll_Pallete+128*4
Mylogo_Palette
	Incbin	E:\Raiden\Introdat\Sprites\Scroll.Pal
	Even
**********************************************************
Backdrop1	Incbin	E:\Raiden\Introdat\Sprites\Back1.bin
	Even
;	Ifne	Second_Screen
Backdrop2	Incbin	E:\Raiden\Introdat\Sprites\Back2.bin
	Even
Backdrop3	Incbin	E:\Raiden\Introdat\Sprites\Back3.bin
	Even
Hiscore_Pack	Incbin	E:\Raiden\Introdat\Screens\Hiscore.bin
	Even
Atari_Pack	Incbin	E:\Raiden\Introdat\Screens\Fuji.bin
	Even
Load_Pack	Incbin	E:\Raiden\Introdat\Screens\Loading.Bin
	Even
Intro_Sprites
	Incbin	E:\Raiden\Introdat\Sprites\Sprites.bin
	Even
**********************************************************
LFM	Dc.w	-1
	Incbin	E:\Raiden\Raidmisc\Blmask.Bin
	
**********************************************************
Pl1_Mess
	Dc.b	"PLAYER 1",-1
Pl2_Mess
	Dc.b	"PLAYER 2",-1
	Even
Pl_Messp
	Ds.l	2


**********************************************************
Plate_Pos
	Dc.b	19,10,20,10,21,10,22,10,23,10,19,11,20,11,21,11
	Dc.b	22,11,23,11,21,12,22,12,23,12

	DC.W	-1
	Dc.b	22,0,23,0,22,1,23,1,22,2,23,2,22,3,23,3
	Dc.b	22,4,23,4

	DC.W	-1
	Dc.b	13,3,14,3,15,3,16,3,13,4,14,4,15,4,16,4
	Dc.b	12,5,13,5,14,5,15,5,16,5,12,6,13,6,14,6
	Dc.b	15,6,16,6
	DC.W	-1

	Dc.b	5,11,6,11,7,11,8,11,5,12,6,12,7,12,8,12
	Dc.b	9,12,10,12,4,13,5,13,6,13,7,13,8,13,9,13
	Dc.b	10,13,4,14,5,14,6,14,7,14,8,14,9,14,10,14

	DC.W	-1
	Dc.b	0,6,1,6,2,6,0,7,1,7,2,7,0,8,1,8
	Dc.b	0,9,1,9
	DC.W	-1

	Dc.b	6,0,7,0,8,0,9,0,10,0,6,1,7,1,8,1
	Dc.b	9,1,10,1,6,2,7,2,8,2,9,2,10,2,6,3
	Dc.b	7,3,8,3,9,3,10,3

	DC.W	-1
	Dc.b	21,13,22,13,23,13,21,14,22,14,23,14
	DC.W	-1

	Dc.b	22,5,23,5,22,6,23,6,20,7,21,7,22,7,23,7
	Dc.b	20,8,21,8,22,8,23,8,20,9,21,9,22,9,23,9

	DC.W	-1
	Dc.b	8,4,9,4,10,4,8,5,9,5,10,5,11,5,8,6
	Dc.b	9,6,10,6,11,6,8,7,9,7,10,7

	DC.W	-1
	Dc.b	3,7,4,7,2,8,3,8,4,8,2,9,3,9,4,9
	Dc.b	2,10,3,10,4,10,2,11,3,11,4,11,2,12,3,12
	Dc.b	4,12
	DC.W	-1

	Dc.b	15,7,16,7,15,8,16,8,15,9,16,9,15,10,16,10
	Dc.b	15,11,16,11

	DC.W	-1
	Dc.b	13,0,14,0,15,0,16,0,17,0,18,0,19,0,20,0
	Dc.b	21,0,13,1,14,1,15,1,16,1,17,1,18,1,19,1
	Dc.b	20,1,21,1,13,2,14,2,15,2,16,2,17,2,18,2

	DC.W	-1
	Dc.b	0,0,1,0,2,0,3,0,4,0,5,0,0,1,1,1
	Dc.b	2,1,3,1,4,1,5,1,0,2,1,2,2,2,3,2
	Dc.b	4,2,5,2

	DC.W	-1
	Dc.b	0,10,1,10,0,11,1,11,0,12,1,12,0,13,1,13
	Dc.b	2,13,3,13,0,14,1,14,2,14,3,14

	DC.W	-1
	Dc.b	17,10,18,10,17,11,18,11,16,12,17,12,18,12,19,12
	Dc.b	20,12,16,13,17,13,18,13,19,13,20,13,16,14,17,14
	Dc.b	18,14,19,14,20,14

	DC.W	-1
	Dc.b	13,7,14,7,9,8,10,8,13,8,14,8,9,9,10,9
	Dc.b	11,9,12,9,13,9,14,9,9,10,10,10,11,10,12,10
	Dc.b	13,10,14,10,9,11,10,11,11,11,12,11,13,11,14,11

	DC.W	-1
	Dc.b	3,3,4,3,5,3,3,4,4,4,5,4,6,4,7,4
	Dc.b	3,5,4,5,5,5,6,5,7,5,3,6,4,6,5,6
	Dc.b	6,6,7,6

	DC.W	-1
	Dc.b	19,2,20,2,21,2,17,3,18,3,19,3,20,3,21,3
	Dc.b	17,4,18,4,19,4,20,4,21,4,17,5,18,5,19,5
	Dc.b	20,5,21,5,17,6,18,6,19,6,20,6,21,6

	DC.W	-1
	Dc.b	0,3,1,3,2,3,0,4,1,4,2,4,0,5,1,5,2,5

	DC.W	-1
	Dc.b	11,12,12,12,13,12,14,12,15,12,11,13,12,13,13,13
	Dc.b	14,13,15,13,11,14,12,14,13,14,14,14,15,14

	DC.W	-1
	Dc.b	17,7,18,7,19,7,17,8,18,8,19,8,17,9,18,9
	Dc.b	19,9

	DC.W	-1
	Dc.b	5,7,6,7,7,7,5,8,6,8,7,8,8,8,5,9
	Dc.b	6,9,7,9,8,9,5,10,6,10,7,10,8,10

	DC.W	-1
	Dc.b	11,0,12,0,11,1,12,1,11,2,12,2,11,3,12,3
	Dc.b	11,4,12,4

	DC.W	-1
	Dc.b	11,7,12,7,11,8,12,8

	DC.W	-1
	DC.W	-1


**********************************************************
Plate_Appearance_Rom
	Ds.b	24*15
Plate_Appearance_Ram
	Ds.b	24*15
	Even


**********************************************************
Plate_Map
	Incbin	E:\Raiden\Introdat\Carrier\Plates.Map
Plate_Blocks
	Incbin	E:\Raiden\Introdat\Carrier\Plates.BLK
;Plate_Palette
;	Incbin	E:\Raiden\Introdat\Carrier\Plates.PAL


*********************************************************
Blockname	Dc.b	"Level_1\Blocks.Bin",0
Mapname		Dc.b	"Level_1\Map.Bin",0
MapCarrier_Name		Dc.b	"Gamedata\Seq_1.MAP",0
BlockCarrier_Name	Dc.b	"Gamedata\Seq_1.BLK",0
PalCarrier_Name		Dc.b	"Gamedata\Seq_1.PAL",0
		Even

Blocks
		Ds.l	130000/4
Map
		Ds.l	30000/4

Decrunch_Buffer
	Ds.l	384*250/4

	Ds.b	2	
Screen1	Ds.l	384*240/4
	Ds.b	2	
Screen2	 Ds.l	384*240/4

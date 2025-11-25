
Options_Menu
	Clr.w	Two_Player_Option
	Lea	Options_Palette,a0
	Lea	Mypal-2,a1
	Trap	#15
	Sf	Copy_The_Pallete(a4)
	Lea	Mypal,a0
	Lea	Destpal,a1
	Move.w	#256*2,d0
	Jsr	Copy_Bytes
	Lea	Options_Header,a0
	Lea	Stuff_to_Load,a1
	Move.l	a1,d0
	Addq.l	#8,d0
	And.l	#-8,d0
	Move.l	d0,a1
	Pea	(a1)
	Trap	#15
	Move.l	a1,Option_Header_Base(a4)
	Move.l	(sp)+,a1
	Lea	Options_Gfx,a0
	Move.l	a1,Option_Gfx_Base(a4)
	Trap	#15
	Move.w	#1,Cursor_Num
	Jsr	Setup_Mainloop_Vars
	Jsr	Swapscreens
	Jsr	Setup_Mainloop_Vars
	Jsr	Swapscreens
	St	Copy_The_Pallete(a4)


	Move.l	Joycur,d0
	Move.l	Joycur+4,d1
	Or.l	d1,d0
	Btst	#Fire_A,d0	
	Sne	d1
	Btst	#Fire_B,d0	
	Sne	d2
	Btst	#Fire_C,d0	
	Sne	d3
	Or.b	d1,d2
	Or.b	d2,d3
	Ext.w	d3
	Move.w	d3,-(sp)

.Loop	Moveq	#1,d0
	Jsr	Wait_Vbl
	Jsr	Setup_Mainloop_Vars
	Move.b	This_Level(a4),-(sp)
	Clr.b	This_Level(a4)
	Jsr	Level_Pallete_Stuff
	Move.b	(sp)+,This_Level(a4)
	Jsr	Readjoysticks
	Lea	Pl1,a3
	Move.l	Joycur,d0
	Move.l	Joycur+4,d1
	Or.l	d1,d0
	Move.l	d0,-(sp)
	Bsr	Up_Down_Options
	Bsr	Test_Cursor_Num
	Bsr	Lighten_Darken_Option
	Move.l	Option_Header_Base(a4),a3
	Move.l	Option_GFX_Base(a4),a5
	Move.w	#60,d0
	Move.w	#30,d1
	Add.w	X_Offset_Into_Map(a4),d0
	Moveq	#0,d2
	Pal_Add_Center
	Jsr	Blit_A_Sprite
	Jsr	Swapscreens
	Move.l	(sp)+,d0
	Btst	#Fire_A,d0	
	Sne	d1
	Btst	#Fire_B,d0	
	Sne	d2
	Btst	#Fire_C,d0	
	Sne	d3
	Or.b	d1,d2
	Or.b	d2,d3
	Bne.s	.Pressed
	Clr.w	(sp)
	Bra	.Loop
.Pressed
	Tst.w	(sp)
	Bne	.Loop
.Oki	Addq.l	#2,sp
	Move.l	Joycur,d0
	Btst	#Fire_A,d0	
	Sne	d1
	Btst	#Fire_B,d0	
	Sne	d2
	Btst	#Fire_C,d0	
	Sne	d3
	Or.b	d1,d2
	Or.b	d2,d3
	Sne	Red_player_Start(a4)
	
	Move.w	Cursor_Num,d0
	Move.b	.Tab(pc,d0),d1
	Add.b	d1,d1
	Move.b	d1,Num_Credits(a4)

	Jsr	Setup_Mainloop_Vars
	Jsr	Swapscreens
	Jsr	Setup_Mainloop_Vars
	Jsr	Swapscreens
	Lea	Clut+Hardware,a0
	Move.w	#256-1,d0
.Loopy	Move.w	#0,(a0)+
	Dbra	d0,.Loopy
	Move.w	Two_Player_Option(pc),d0
	Bne.s	.Two
	St	One_Player_Game(a4)
	Moveq	#1,d0
	Tst.b	Red_player_Start(a4)
	Bne.s	.Two
	Add.w	d0,d0
.Two	Rts

.Tab	Dc.b	2,5,8
	Even

Lighten_Darken_Option
	Lea	Clut+Hardware+250*2,a0
	Move.w	#$7788,(a0)+
	Move.w	#$7788,(a0)+
	Move.l	a0,a1
	Move.w	#$7788,(a1)+
	Move.w	#$7788,(a1)+
	Move.w	#$7788,(a1)+
	Move.w	Cursor_Num(pc),d0
	Add.w	d0,d0
	Move.w	#$77ff,(a0,d0)
	Tst.w	Two_Player_Option
	Sne	d1
	Subq.l	#4,a0
	And.w	#1,d1
	Add.w	d1,d1
	Move.w	#$ffff,(a0,d1)	
	Rts


Up_Down_Options
	Btst	#Joy_Up,d0
	Bne.s	.Joy_Up
	Btst	#Joy_Down,d0
	Bne.s	.Joy_down
	Btst	#Joy_Right,d0
	Bne.s	.Joy_R
	Btst	#Joy_Left,d0
	Bne.s	.Joy_L
	Clr.b	Button_Repeat(a3)
	Rts
.Joy_R
.Joy_L	Tst.b	Button_Repeat(a3)
	Bne.s	.Exit
	St	Button_Repeat(a3)
	Eor.w	#3,Two_Player_Option
	Rts

.Joy_Up	Tst.b	Button_Repeat(a3)
	Bne.s	.Exit
	St	Button_Repeat(a3)
	Subq.w	#1,Cursor_Num
	Rts
.Joy_Down
	Tst.b	Button_Repeat(a3)
	Bne.s	.Exit
	St	Button_Repeat(a3)
	Addq.w	#1,Cursor_Num
.Exit	Rts


Test_Cursor_Num
	Tst.w	Cursor_Num
	Bpl.s	.Pos
	Move.w	#2,Cursor_Num
	Rts
.Pos	Cmp.w	#2,Cursor_Num
	Ble.s	.Exit
	Clr.w	Cursor_Num
.Exit	Rts
	

Cursor_Num
	Ds.w	1	
Two_Player_Option
	Ds.w	1

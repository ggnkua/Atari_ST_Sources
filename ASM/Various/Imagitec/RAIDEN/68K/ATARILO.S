Atari_Logo_On
	Lea	Atari_Pal,a0
	Clr.b	Copy_The_Pallete(a4)
	Trap	#15
	Lea	2(a1),a0
	Lea	Destpal,a1
	Move.l	#512,d0
	Jsr	Copy_Bytes
	St	Copy_The_Pallete(a4)
	St	Atari_Logo_On_Vblank(a4)
	Rts
		
Vblank_Atari_Logo
	Tst.b	Atari_Logo_On_Vblank(a4)
	Beq	.No_Atari
	Push
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Move.w	#293,d2
	Move.w	d2,d3
	Lsl.w	#4,d3
	Move.l	Player_Sprite_Base(a4),a2
	Move.w	Spr_Pixel_Width(a2,d3),d4
	Move.w	Spr_Sheight(a2,d3),d5
	Move.w	#Screen_Width/2,d0
;	Move.w	#Screen_Height/2,d1
	Move.w	Height_Of_Screen(a4),d1
	Lsr.w	#1,d1
	Asr.w	#1,d4
	Asr.w	#1,d5
	Sub.w	d4,d0
	Sub.w	d5,d1
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Player_GFX_Base(a4),a5
	Add.w	X_Offset_Into_Map(a4),d0
	Jsr	Blit_A_Sprite
	Jsr	Swapscreens
	Pull
.No_Atari
	Rts


Atari_Logo_Off
	Tst.b	Atari_Logo_On_Vblank(a4)
	Beq.s	.No_Atari
	Clr.b	Atari_Logo_On_Vblank(a4)
	Jsr	Setup_Mainloop_Vars		; All pointers and stuff setup for main loop
	Jsr	Swapscreens
.No_Atari
	Rts
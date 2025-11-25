; RAiDEN MAIN GAME CODE
; Typed in by FREDDY, Imagitec Design 1993!
Bmask_Add	Equ	32
;**********************************************************

; Conditional Assembly!
MAKEDISK=0				; Assemble only if making disks
Makedisk=MAKEDISK
Mapoffset=0 160				; Offset into map/Event files
Bombdec=1				; !=0 if Bomb decs on drop
Load_Event=0				; Load Binary event
Level=4					; Initial level number
Max_Level=5				;  levl on exit
Collision=0				; Collision enabled if !=
SYS=1					; Setup my hardware
;**********************************************************
	Opt	w-			; Turn off all assembly warnings
 	Include	..\Includes\Systregs.Inc		;Falcon Hardware
	Include	Macros.s				;Some Code&Data macros
	Include	Equates.s				;Game Equates
	Include	Globvars.s				;Variables from 16bit displacements
;**********************************************************
	IFEQ	MAKEDISK 
	Include	Spool.s				; Only assemble if not making disk
	ENDC
	OPT	D+

; Parameters passed
; d0 - Bit 0 - Player 1 Active 
; d0 - Bit 1 - Player 2 Active 

Start	
	IFNE	MAKEDISK
	Move.l	a7,Stack_Save		; Save stack here if making disk (called prog using JSR!)
	ENDC
	Bsr	Go			; Go !
	Clr.w	-(sp)
	Trap	#1			; Falcon specific EXIT code
	Include	Keyboard.s		; Falcon Keyvboard code, courtesy ASEED!
	Include	Sample.s		; Falcon Sample code, Courtesy ASEED! THE MUDDY EYE FACE!
	Include	..\Protrack\Ptfalcon.s
Go	Move.w	#3,d0
	IFEQ	MAKEDISK
	Move.l	a7,Stack_Save		; Save stack here if not making disk !
	ENDC
	Bsr	Init			; Setup the game and Falcon Hardware

**********************************************************
** MAIN GAME LOOP
Main	
	Bsr	Wait_Main_Vbl			; Syncronize with a timed source!
	Move.b	#0,Frames_To_Consist(a4)		
	Move.w	#2,Offset_For_Saves(a4)
.Main	
	Bsr	Check_Consistancy		; Check if we need to restore/save/draw on this pass
	Bsr	Check_For_Pause			; Check if pause button pressed
	Bsr	Check_Bomb_Button		; Check if bomb button pressed
	Bsr	Check_Fire_Button		; Check if fire button pressed
	Bsr	Insert_Spit_Out_For_Ship	; Do spit out if ya dead
	Bsr	Can_I_Let_It_Loose		; Let a weapon go if ya pressed fire
	Bsr	Scroll_Lr			; Get line offsets, Play/Screen offsets
	Bsr	Scroll_Screen_Down		; Build another screen line
	Tst.b	Dont_Draw_Aliens(a4)
	Bne.s	.No_restore			; Only restore if this flag is cleared
	Bsr	Restore_Sprites			; Restore Sprite background
.No_Restore
	Bsr	Get_X_Screen_Bounds
	Bsr	Check_If_Dead			; Do what it says
	Bsr	Move_Weapons			; Move weapons around the play-area
	Bsr	Dec_Track_Amounts		; Global track values
	Bsr	Move_Aliens			; Move aliens around the play-area
	Bsr	Track_Sprites_To_Player		; Track sprites that auto track ya
	Bsr	Slow_Down_The_Trains		; When a train link gets hit, slow down the rest
	Bsr	Get_Aliens_To_Home		; Check aliens to which we can home into
	Bsr	Home_Into_Bastards		; Direct homing missiles
	Bsr	Build_Linked_Alien_Lists	; Linked sprites < Base sprites
	Tst.b	Dont_Draw_Aliens(a4)
	Bne.s	.No_Save_Or_Draw
	Bsr	Save_Txt			; Save score background
	Bsr	Save_Weapon_Sprites		; Save Weapon background
	Bsr	Sort_Aliens			; Draw aliens priority 0 first > priority 3 last
	Bsr	Save_Alien_Sprites		; Save backgrounds for aliens
	Bsr	Save_Bomb_Gfx			; Save background for bomb
	Bsr	Draw_Aliens			; Draw alien sprites
	Bsr	Do_Bomb_Gfx			; Draw bomb
	Bsr	Draw_weapons			; Draw Weapons
.No_Save_Or_Draw		
	Bsr	Alien_To_Ship			; Check if anything has hit the player ship
	Bsr	Weapons_To_Aliens		; Check if any weapons have hit the aliens
	
	Bsr	Kill_Aliens_If_Bomb		; Lower hitpoints when bomb active
	Tst.b	Dont_Draw_Aliens(a4)
	Bne.s	.No_Score_draw
	Bsr	Score_Stuff			; Do some score stuff
.No_Score_draw
	Bsr	Check_Event			; Check along event table
	Bsr	Make_End_Y_Mask			; Used to clip level1 end baddy
	Bsr	Check_Spit_Out			; Spit out for level 2 monster
	Bsr	Insert_Stuff			; Various insertions into the active sprite list

	Bsr	Disable_Ints			; Disable interrupts
	Bsr	Scroll_Down_Map
	Tst.b	Dont_Draw_Aliens(a4)
	Bne.s	.No_Screen_Swap
	Bsr	Swapscreens			; Swap buffers/screens
.No_Screen_Swap
	Bsr	Enable_Ints			; Enable interrupts
	Bsr	Seed_Rand			; Continually Generate a random number
;	Add.w	#1,Offset_For_Saves(a4)
	Tst.b	Dont_Draw_Aliens(a4)
	Bne	.Main
	Bsr	Check_End_Level			; Check if ya reached end of level
Skip_Pause
	Bsr	Check_Pause		; Check if pause button toggled
	Bsr	Check_Exit		; Check key for exit 

**********************************************************
; d0 - x
; d1 - y
; d2 - Sprite number

; a3 - Sprite table
; a4 - Data region
; a5 - Base address of screen
; a6 - Blitter registers

; Registers corrupted
Blit_A_Sprite
	Cmp.w	Sprite_Clip_Minx(a4),d0
	Ble	.Exit
	Cmp.w	Sprite_Clip_Maxx(a4),d0
	Bge	.Exit
	Add.w	d2,d2
	Lea	(a3,d2*8),a3
	Move.w	Spr_Height(a3),d6		; Height in d6
	Ble	.Exit
	Moveq	#0,d5				; Line of sprite to start from
	Add.w	Spr_Yadd(a3),d1			; Y line in d1
	Bpl.s	.No_Clipmin			; Positive, no y clipping
	Sub.w	d1,d5				; Y line starts at -ive this
	Add.w	d1,d6				; Subtract from height
	Ble	.Exit				; Height <=0 no draw
	Moveq	#0,d1				; Y line = 0
	Bra.s	.No_Clip	
.No_Clipmin
	Move.w	d1,d2				; Y into d2
	Add.w	d6,d2				; Add height
	Sub.w	#Height,d2			; Height from Y+Height
	Ble.s	.No_Clip			; <=0  No clip
	Sub.w	d2,d6				; Else subtract difference from screen height from height of sprite
	Ble	.Exit
.No_Clip
	Mulu	#Byteswide,d1
	Add.l	d1,a5			; Add y multiplied to base of screen
	Moveq	#$f,d2			; Mask for shift
	And.w	d0,d2			; Get shift
	Sub.w	d2,d0			; Word address of sprite
	Ext.l	d0
	Add.l	d0,a5			; Extend and add to base address of destination
	Move.b	d2,Skew(a6)
	Lea	.Shift_Mask(pc),a2
	Move.w	(a2,d2*2),Endmask1(a6)	 		
	Move.w	32(a2,d2*2),Endmask3(a6)	 		
	Move.w	#0,Src_Yinc(a6)
	Move.l	Spr_Addr(a3),a2			; Base Address of sprite
	Move.w	Spr_Width(a3),d4		; Width in d4
	Move.w	#Byteswide,d3
	Sub.w	d4,d3				; Difference in bytes for next line		
	Lsr.w	#4,d4				; Width /16
	Move.w	d4,d7				; Save
	Addq.w	#1,d4				; And another word
	Mulu	#10,d5				; Word mask + 4 words data
	Mulu	d5,d7				; Multiplied by words across
	Add.l	d7,a2				; Add to address of sprite	

	Move.w	d3,Dst_Yinc(a6)			; Set destination Inc
	Move.w	Spr_Plane(a3),d3		; Get Plane info

	Moveq	#7,d7
.Masklp	Move.b	#$01,Op(a6)		
	Lsr.b	#1,d3
	Bcc.s	.MaskOk
	Move.b	#$0d,Op(a6)		
.Maskok	Move.l	a2,Src_Addr(a6)
	Move.l	a5,Dst_Addr(a6)
	Move.w	d4,X_Count(a6)		
	Move.w	d6,Y_Count(a6)
	Move.b	#$c0,Line_Num(a6)
	Addq.l	#2,a5	
	Dbra	d7,.Masklp
	Lea	-16(a5),a5
	Addq.l	#2,a2

	Move.w	Spr_Use(a3),d3			; Get Planes used
	Moveq	#$f,d3
	
	Move.b	#$07,Op(a6)		
.Orloop	Lsr.w	#1,d3
	Bcc.s	.Skip_Plane
	Move.l	a2,Src_Addr(a6)	
	Move.l	a5,Dst_Addr(a6)
	Move.w	d4,X_Count(a6)		
	Move.w	d6,Y_Count(a6)
	Move.b	#$c0,Line_Num(a6)
.Skip_Plane
	Addq.l	#2,a2
	Addq.l	#2,a5
	Tst.w	d3
	Bne.s	.Orloop
.Exit	Rts

.Shift_Mask
	Dc.w	-1
	Incbin	Raidmisc\Blmask.Bin
LFM
	Dc.w	-1
	Incbin	Raidmisc\Blmask.Bin

**********************************************************
Get_X_Screen_Bounds
	Move.w	Ascreenxoffset(a4),Sprite_Clip_Minx(a4) ; Minimum X for no draws
	Move.w	Ascreenxoffset(a4),Sprite_Clip_Maxx(a4) ; Maximum X for no draws
	Sub.w	#64,Sprite_Clip_Minx(a4)
	Add.w	#384,Sprite_Clip_Maxx(a4)	; Get work coards
	Rts

**********************************************************
Scroll_Screen_Down
	Tst.b	No_More_Scrolling(a4)	; Only scroll if flag clear
	Bne.s	.No_Scroll
	Bsr	Getrealscreenp		; Adjust screen pointers
	Bsr	Buildmap		
	Bsr	Scrolldown		; Process scroll info
	Tst.b	Flag_To_Flip_Screens(a4)
	Beq.s	Scroll_Screen_Down	; you may need to do 2 scrolls
	Rts

.No_Scroll
	Movem.w	Lineoffset(a4),d0-d1
	Cmp.w	d0,d1
	Beq.s	.Ok
	Bsr	Getrealscreenp		; Adjust screen pointers
	Bsr	Buildmap		
	Bsr	Scrolldown		; Process scroll info
.Ok	Rts	

**********************************************************
Check_Consistancy
	Cmp.b	#1,Frames_To_Consist(a4)
	Sgt	Dont_Draw_Aliens(a4)		; If consistency is >=2, dont restore/save/draw sprites
	Ble.s	.Exit
	Subq.b	#2,Frames_To_Consist(a4)	; Subtract from consistency value
.Exit	Rts

**********************************************************
Insert_Stuff
	Bsr	Insert_Alien		
	Bsr	Check_Guardian_Is_Dead
	Bsr	Check_Lev3cannon
	Bsr	Insert_Crators
	Bsr	Insert_Explosion	
	Bsr	Insert_Power		
	Bsr	Insert_Bonus_Sprites
	Rts

**********************************************************
Check_Lev3cannon
	Tst.b	Turrets_Or_Cannons(a4)
	Beq.s	.Turret
	Cmp.b	#5,Number_Of_Turrets_Left3(a4)
	Bne	.Not_there
	Not.b	Turrets_Or_Cannons(a4)
	Clr.b	Number_Of_Turrets_Left3(a4)
	Lea	Alien_Table(a4),a0
	Moveq	#Aln_End,d0
.Loop2	Tst.w	Aln_Dmg(a0)
	Ble.s	.Nx1
	Cmp.w	#111,Aln_Anmset(a0)
	Beq.s	.Found_Base4
.Nx1	Add.l	d0,a0
	Bra.s	.Loop2
.Found_Base4
	Move.w	#500,Aln_Dmg(a0)
	Moveq	#17,d0
.Loopy	Move.l	Aln_Link(a0),a0
	Dbra	d0,.Loopy
	Clr.w	Aln_Seqdec(a0)
	Move.l	#MadLev3_Seq,Aln_Seqp(a0)
	Rts

.Turret	Cmp.b	#8,Number_Of_Turrets_Left3(a4)
	Bne	.Not_There
	Move.l	Enemy_Sprites_Base(a4),a0
	Lea	Lev3_Height_Save(a4),a1
	Move.w	(a1)+,Spr_Height+(365*16)(a0)
	Move.w	(a1)+,Spr_Height+(366*16)(a0)
	Move.w	(a1)+,Spr_Height+(367*16)(a0)
	Move.w	(a1)+,Spr_Height+(368*16)(a0)
	Clr.b	Number_Of_Turrets_Left3(a4)
	Not.b	Turrets_Or_Cannons(a4)
	Lea	Alien_Table(a4),a0
	Moveq	#Aln_End,d0
.Loop	Tst.w	Aln_Dmg(a0)
	Ble.s	.Nx
	Cmp.w	#111,Aln_Anmset(a0)
	Beq.s	.Found_Base3
.Nx	Add.l	d0,a0
	Bra.s	.Loop
.Found_Base3
	Move.l	a0,a1
	Move.l	Aln_X(a0),-(sp)
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Bsr	Void_It
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Moveq	#4,d0
	Moveq	#124,d1
	Lea	.Cannon_Fire_Table(pc),a2
.Loopx	Move.w	d1,Aln_Anmset(a1)
	Addq.l	#1,d1
	Move.w	#20,Aln_Dmg(a1)
	Clr.w	Aln_Anim(a1)
	Move.w	(a2)+,Aln_Seqdec(a1)
	Move.w	#-1,Aln_Wave(a1)
	Move.l	#Cannon_Fodder_Fireseq,Aln_Seqp(a1)
	St	Aln_Pauseflag(a1)
	Move.l	Aln_Link(a1),a1
	Dbra	d0,.Loopx
	Lea	Temp_Level3_Add+9*4(a4),a0
	Move.w	#12,(a0)+
	Move.w	#60,(a0)+
	Move.w	#26,(a0)+
	Move.w	#64,(a0)+

	Move.w	#44,(a0)+
	Move.w	#64,(a0)+
	Move.w	#62,(a0)+
	Move.w	#64,(a0)+

	Move.w	#76,(a0)+
	Move.w	#60,(a0)+
	Move.w	#x16-Dead_Alien_Jump_Table,Aln_Sprite_Save(a4)
	Lea	.Quadexplosion(pc),a2
	Moveq	#3,d7
.Xploop	Movem.w	(sp),d0-d1
	Add.w	(a2)+,d0
	Add.w	(a2)+,d1
	Add.w	#32,d0
	Add.w	#56,d1
	Movem.w	d0-d1,Aln_X_Save(a4)
	Bsr	Explosion64
	Dbra	d7,.Xploop
	Addq.l	#4,sp
.Not_There
	Rts	

.Cannon_Fire_Table
	Dc.w	0,30,60,30,0
.Quadexplosion
	Dc.w	0,-32,32,0,0,32,-32,0

**********************************************************
Score_Stuff
	Bsr	Add_Lives		
	Bsr	BCD_Ascii_Score
	Bsr	Display_Score		
	Bsr	Put_Icons		
	Bsr	Display_Bombs_And_Lives	
	Rts

**********************************************************
Insert_Spit_Out_For_Ship
	Tst.b	Flag_For_Random_Spit(a4)
	Bne.s	.Spit
	Rts
.Spit	Move.l	Player_Use(a4),a3
	St	We_Have_Fired(a3)
	Sf	Fire_Delay(a3)	
	St	Secondry_Weapon(a3)
	Move.b	#2,Weapon_In_Use(a3)
	Rts	

**********************************************************
Check_Spit_Out
	Tst.l	Flag_To_Spit_Out(a4)
	Beq	.No_Spit
	Move.w	#6,-(sp)
	Lea	.Flag_Offsets(pc),a0
.Loop	Movem.w	Flag_To_Spit_Out(a4),d0-d1
	Add.w	#18,d0
	Add.w	#-07,d1
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3
	Ext.w	d2
	Ext.w	d3
	Add.w	d2,d0
	Add.w	d3,d1
	Bsr	Search_Free_Alien_Slot  ; Search to insert !
	Move.w	#1,Aln_Dmg(a6)
	Clr.w	Aln_Anim(a6)
	Move.w	#Left_Transform_Anm_Set,Aln_Anmset(a6)
	Tst.w	(a0)
	Bmi.s	.Ok_Left
	Move.w	#Right_Transform_Anm_Set,Aln_Anmset(a6)
.Ok_Left
	Move.w	#0,Aln_Wave(a6)
	Movem.w	d0-d1,Aln_X(a6)
	Move.b	(a0)+,d0
	Ext.w	d0
	Move.w	d0,Aln_Shite(a6)
	Move.b	(a0)+,d0
	Ext.w	d0
	Move.w	d0,Aln_Shite+2(a6)
	Move.w	#10,Aln_SeqDec(a6)
	Move.l	#Spit_Home_Seq,Aln_seqp(a6)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp	
	Clr.l	Flag_To_Spit_Out(a4)
.No_Spit
	Rts

.Flag_Offsets
	Dc.b	-30,+30
	Dc.b	-8,-4
	Dc.b	-20,+20
	Dc.b	-6,-6
	Dc.b	-10,+10
	Dc.b	-4,-8
	Dc.b	+10,+10
	Dc.b	+4,-8
	Dc.b	+20,+20
	Dc.b	+6,-6
	Dc.b	+30,+30
	Dc.b	+8,-4

**********************************************************
Slow_Down_The_Trains
	Subq.b	#1,Flag_To_Slow_Down_Train(a4)
	Bgt.s	.Exit
	Move.b	#3,Flag_To_Slow_Down_Train(a4)
	Lea	Train_Slow_Down_Table(a4),a0
	Moveq	#7,d7
.Loop	Tst.l	(a0)+
	Beq.s	.Dec
	Move.l	-4(a0),a1
	Tst.w	Aln_Shite+4(a1)
	Beq.s	.Dec
	Subq.w	#1,Aln_Shite+4(a1)		
	Bgt.s	.Dec
	Clr.l	-4(a0)
.Dec	Dbra	d7,.Loop
.Exit	Rts


**********************************************************
Make_End_Y_Mask
	Lea	End_Level_Y_Mask(a4),a6
	Tst.w	(a6)
	Beq.s	.Exit
	Bpl.s	.Positive
	Move.w	#97,(a6)
.Positive
	Tst.b	No_More_Scrolling(a4)
	Bne.s	.Exit
	Addq.w	#1,(a6)
.Exit	Rts


**********************************************************
Check_For_Pause
	Tst.b	Pause_Flag(a4)
	Beq.s	.Skip_Pause
	Move.l	#Skip_Pause,(sp)
.Skip_Pause
	Rts
**********************************************************
Build_Linked_Alien_Lists
	Lea	Alien_Table(a4),a0
	Move.w	#Max_Aliens-1,d7		; Go through all sprites in list
.Loop	Tst.w	Aln_Dmg(a0)
	Ble.s	.Dec				; Check entry
	Move.l	Aln_Linkoffsets(a0),d0		; Pointer to link table
	Beq.s	.Dec				; if zero, no linking
	Bmi.s	.Neg				; Else special link
.Link	Move.l	d0,a1
	Move.l	a0,a2
	Movem.w	Aln_X(a2),d0-d1
.Link_Loop
	Tst.l	Aln_Link(a2)
	Ble.s	.Dec
	Move.l	Aln_Link(a2),a2
	Move.w	d0,d2
	Move.w	d1,d3
	Cmp.w	#67,Aln_Anmset(a2)
	Bne.s	.No_Cannon
	Lea	Cannon_Adj(pc),a3
	Moveq	#0,d6
	Move.b	Aln_Prevsprite(a2),d6
	Add.w	$0(a3,d6*4),d2
	Add.w	$2(a3,d6*4),d3
.No_Cannon
	Add.w	(a1)+,d2
	Add.w	(a1)+,d3
	Movem.w	d2-d3,Aln_X(a2)
	Bra.s	.Link_Loop
.Dec	Lea	Aln_End(a0),a0
	Dbra	d7,.LOOP
	Rts

.Neg	Tst.l	Aln_Link(a0)
	Ble.s	.Dec
	Move.l	Aln_Link(a0),a1
	Movem.w	Aln_X(a0),d0-d1
	Cmp.w	#7,Aln_Anmset(a0)
	Beq.s	.Tank
	Cmp.w	#66,Aln_Anmset(a0)
	Beq.s	.Cannon
	Cmp.w	#71,Aln_Anmset(a0)
	Blt.s	.Cannon
	Cmp.w	#74,Aln_Anmset(a0)
	Ble.s	.Boat_Link
	Bra.s	.Dec
.Cannon	
	Lea	Cannon_Adj(pc),a2
	Moveq	#0,d6
	Move.b	Aln_Prevsprite(a0),d6
	Add.w	$0(a2,d6*4),d0
	Add.w	$2(a2,d6*4),d1
	Movem.w	d0-d1,Aln_X(a1)
	Bra.s	.Dec
.Tank	Lea	Tank_Adj(pc),a2
	Moveq	#0,d6
	Move.b	Aln_Prevsprite(a0),d6
	Add.w	$0(a2,d6*4),d0
	Add.w	$2(a2,d6*4),d1
	Move.b	Aln_Prevsprite(a1),d6
	Lea	Turret_Adj(pc),a2
	Add.w	$0(a2,d6*4),d0
	Add.w	$2(a2,d6*4),d1
	Movem.w	d0-d1,Aln_X(a1)
	Bra	.Dec	
.Boat_Link
	Move.w	Aln_Anmset(a0),d6
	Sub.w	#71,d6
	Add.w	.Boat_Offset(pc,d6*4),d0
	Add.w	.Boat_Offset+2(pc,d6*4),d1
	Move.b	Aln_Prevsprite(a1),d6
	Lea	Turret_Adj(pc),a2
	Add.w	$0(a2,d6*4),d0
	Add.w	$2(a2,d6*4),d1
	Movem.w	d0-d1,Aln_X(a1)
	Bra	.Dec

.Boat_Offset
	Dc.w	0,0,2,0
	Dc.w	0,2,-2,0

**********************************************************
Build_Cannons
;	Lea	Cannon_Table(a4),a0
.Loop	Tst.b	(a0)
	Bmi.s	.Exit
	Move.l	(a0)+,a1
	Tst.l	Aln_Link(a1)
	Ble.s	.Loop
	Move.l	Aln_X(a1),-(sp)
	Move.l	Aln_Link(a1),a1
	Move.l	(sp)+,Aln_X(a1)
	Bsr.s	Offset_Cannon
	Bra.s	.Loop
.Exit	Rts

Offset_Cannon
	Pea	(a6)
	Movem.w	Aln_X(a1),d0-d1
	Move.w	Aln_Shite(a1),d7
	Lsr.w	#4,d7
	Moveq	#0,d2
	Moveq	#0,d3
	Lea	Cannon_Adj(pc),a6
	Move.b	(a6,d7),d2
	Move.b	d2,d3
	Lsr.b	#4,d2
	And.b	#$f,d3
	Add.w	d2,d0
	Add.w	d3,d1
	Movem.w	d0-d1,Aln_X(a1)
	Add.w	d7,Aln_Sprite(a1)
	Move.l	(sp)+,a6
	Rts

**********************************************************
Check_Guardian_Is_Dead
	Tst.b	Guardian_Is_Dead(a4)
	Beq.s	.Exit
	Cmp.b	#40,Guardian_Explosion_Count(a4)
	Beq.s	.Scroll_On
	Tst.b	No_More_Scrolling(a4)
	Seq	d1
	And.w	#1,d1
	Add.w	d1,Y_Off_For_Explosion(a4)
	Subq.b	#1,Guardian_Explosion_Delay(a4)
	Bgt.s	.Exit
	Movem.w	Guardians_Last_Position(a4),d0-d1
	Tst.b	Guardian_Explosion_Count(a4)
	Beq	.Crator
.No_Crator
	Lea	Explosion_Offsets(pc),a5
	Move.b	#Guardian_Xpl_delay,Guardian_Explosion_Delay(a4)
	Move.w	#201,Aln_Sprite_Save(a4)
	Moveq	#0,d2
	Move.b	Guardian_Explosion_Count(a4),d2
	Divu	#10,d2
	Swap	d2
	Move.b	$0(a5,d2),d3
	Move.b	$1(a5,d2),d4
	Ext.w	d3
	Ext.w	d4
	Add.w	d3,d0
	Add.w	d4,d1
	Sub.w	#24,d0
	Sub.w	#34,d1	
	Add.w	Y_Off_For_Explosion(a4),d1
	Movem.w	d0-d1,Aln_X_Save(a4)
	Bsr	Explosion64
	Addq.b	#1,Guardian_Explosion_Count(a4)
.Exit	Move.l	Explosion_Tabp(a4),a0
	St	(a0)
	Move.l	Crator_Tabp(a4),a0
	St	(a0)
	Rts

.Scroll_On
	Sf	No_More_Scrolling(a4)
	Sf	Guardian_Is_Dead(a4)
	Sf	Guardian_Explosion_Count(a4)
	Sf	Guardian_Explosion_Delay(a4)
	Clr.l	Guardians_Last_Position(a4)
	Rts	

.Crator	Cmp.b	#1,This_Level(a4)
	Beq.s	.Level1
	Bra	.No_Crator

.Level1	Bsr	Search_Free_Alien_Slot	
	Move.l	a6,Last_Crator_Address(a4)
	Clr.w	Aln_Wave(a6)
	Move.l	#1,Aln_Shite(a6)
	Move.w	#48,Aln_Anmset(a6)
	Move.w	#$7fff,Aln_Seqdec(a6)
	Movem.w	d0-d1,Aln_X(a6)
	Sub.w	#48,Aln_X(a6)
	Sub.w	#48,Aln_Y(a6)
	Bra	.No_Crator
	
**********************************************************
Check_Pause
	Tst.b	End_Level(a4)
	Bne.s	.Exit
	Bsr	Pause_Pressed
	Bne.s	.Exit
.Pressed
	Tst.b	Pause_Flag_Delay(a4)
	Beq.s	.Just_Pressed
	Rts
.Just_Pressed
	St	Pause_Flag_Delay(a4)
	Not.b	Pause_Flag(a4)
;	Bne.s	.Tune_Off
;	Bsr	Tune_On
;	Rts
;.Tune_Off
;	Bsr	Tune_Off
	Rts
.Ending	Sf	Pause_Flag(a4)
.Exit	Sf	Pause_Flag_Delay(a4)
	Rts
	
	
**********************************************************
Check_Exit
	Move.b	Key(pc),d0
	Cmp.b	#$1,d0
	Bne.s	.Nx
	Not.b	NoColl
	Bne.s	.Collision_Off
	Move.l	#$0,Pal256
	Bra.s	.Nx
.Collision_Off
	Move.l	#$ff000000,Pal256
.Nx	Lea	Main(pc),a0
	Move.l	a0,(sp)
	Move.b	Key(pc),d0
	Clr.b	Key
	Cmp.b	#$39,d0			; Space ?
	Bne.s	.Cont
	Lea	Out(pc),a0
	Move.l	a0,(sp)
.Cont	Rts

**********************************************************
Disable_Ints
	Move.w	SR,SR_Save(a4)		; Save status register
	And.w	#$f8ff,SR
	Or.w	#$0700,SR		; No interupts
	Rts
**********************************************************
Enable_Ints	
	Move.w	Sr_Save(a4),SR		; Restore status
;	Move.b	Timer_Stuff+0,$fffffa07.w
;	Move.b	Timer_Stuff+1,$fffffa09.w
	Rts	

**********************************************************
Timer_Stuff
	Ds.b	2

**********************************************************
Track_Sprites_To_Player
	Move.w	Sprites_To_Draw(a4),-(sp) ; Number of sprites on stack
	Ble	.Quit			; None to do
	Move.l	Player_Use(a4),a3
	Movem.w	Shipxy(a3),d0-d1	; Get players x/y
	Add.w	Ascreenxoffset(a4),d0	; Add base of screeb x
	Addq.w	#8,d0			; Add screen offset + 8 to ship
	Movem.w	d0-d1,Track_Shipxy(a4)	; Used for tracking coardinates
	Lea	Alien_Table(a4),a0
.Loop	Tst.w	Aln_Dmg(a0)
	Bgt.s	.Found_Alien
	Lea	Aln_End(a0),a0
	Bra.s	.Loop
.Found_Alien
	Tst.b	Aln_Track_val(a0)
	Beq.s	.No_Track
	Pea	.No_Track(pc)
	Cmp.b	#1,Aln_Track_Val(a0)
	Beq.s	Track_Coards
	Cmp.b	#2,Aln_Track_Val(a0)
	Beq.s	Angle_Track
.No_Track
	Lea	Aln_End(a0),a0
	Subq.w	#1,(sp)
	Bne.s	.Loop
.Quit	Addq.l	#2,sp
	Rts

Angle_Track
	Move.w	Aln_Shite(a0),d0
	Addq.b	#8,d0
	Lsr.w	#4,d0
	Move.b	d0,Aln_Prevsprite(a0)
	Add.w	d0,Aln_Sprite(a0)
	Rts

;	Move.b	Aln_PrevSprite(a0),d0
;	Add.w	d0,Aln_Sprite(a0)
;	Rts
;	Move.w	Aln_Shite(a0),d0
;	Addq.b	#8,d0
;	Lsr.w	#4,d0
;	Move.b	d0,Aln_Prevsprite(a0)
;	Add.w	d0,Aln_Sprite(a0)
;	Rts

Track_Coards
	Movem.w	Track_Shipxy(a4),d0-d1	; Ship x/y
	Movem.w	Aln_X(a0),d4-d5		; Collect Aliens x/y
	Tst.b	Track_Del1(a4)
	Bne.s	.No_Del
	Sub.w	d4,d0			; Get delta x (absolute)
	Smi	d6			; Set if negative
	Bpl.s	.Pos
	Neg.w	d0       
.Pos	Sub.w	d5,d1			; Same for delta Y
	Smi	d7
	Bpl.s	.Pos1
	Neg.w	d1
.Pos1	Cmp.w	d0,d1
	Sgt	d5			; Set if Y vector greater than
	Bgt.s	.Yvectg			; Y vector is Greater than
	Exg	d0,d1			; Exchange if X vector > Than!
.Yvectg	
	And.w	#$fffe,d1		; Mask most delta
	Move.w	d1,d2			; Save it !
	Lsr.w	#1,d2			; Divide save by 2!
	Bne.s	.Ok
	Moveq	#0,d0			; Make normal !
	Moveq	#4,d1
	Bra.s	.Notne1
.Ok	Divu	d2,d0			; Divide down 1
	Divu	d2,d1			; Divide down 1
	Tst.b	d5
	Bne.s	.No_Exg
	Exg	d0,d1			; Exchange Vectors!
.No_Exg	Tst.b	d6
	Beq.s	.Notne0			; Normalize X
	Neg.w	d0
.Notne0	Tst.b	d7
	Beq.s	.Notne1			; Same for Y
	Neg.w	d1		
.Notne1	Add.w	d0,d0
	Add.w	d1,d1			; double em !
	Lea	VectorTab(pc),a6	; Pointer
	Moveq	#0,d2			; Clear ship anim!
	Moveq	#15,d3			; Loop 16 times
.Loopx	Cmp.w	(a6)+,d0
	Bne.s	.Skip
	Cmp.w	(a6),d1			; Compare offsets ?
	Beq.s	.Out
.Skip	Addq.w	#1,d2			; Not equal, 1 to base
	Addq.l	#2,a6
	Dbra	d3,.Loopx
	Bra.s	.No_Del
.Out	Moveq	#0,d5
	Move.b	Aln_Prevsprite(a0),d5
	Cmp.b	d2,d5
	Beq.s	.No_Del
	Sub.w	d2,d5
	Bge.s	.Posy
	Add.w	#16,d5
.Posy	Addq.b	#1,Aln_Prevsprite(a0)
	Cmp.w	#8,d5
	Bge.s	.No_Del
	Subq.b	#2,Aln_Prevsprite(a0)
.No_Del	And.b	#$f,Aln_Prevsprite(a0)
	Moveq	#0,d5
	Move.b	Aln_Prevsprite(a0),d5
	Cmp.w	#119,Aln_Anmset(a0)
	Beq.s	.No_Track
	Add.w	d5,Aln_Sprite(a0)
.No_Track
	Rts

**********************************************************
Get_Aliens_To_Home
	Lea	Home_Table(a4),a6	
	Move.l	Enemy_Sprites_Base(a4),a5
	Move.w	Sprites_To_Draw(a4),d7	
	Ble.s	.None			
	Subq.w	 #1,d7			
	Lea	Home_Into,a3		
	Lea	Alien_Table(a4),a0	
	Moveq	#Aln_End,d6
	Moveq	#0,d5
.Loop	Tst.w	(a0)			
	Bgt.s	.Ok
	Add.l	d6,a0			
	Bra.s	.Loop
.Ok	Move.w	Aln_Sprite(a0),d5
	Tst.b	(a3,d5)			
	Beq.s	.Dec			
	Add.w	d5,d5			
	Movem.w	Aln_X(a0),d0-d1		
	Cmp.w	Sprite_Clip_Maxx(a4),d0
	Bge.s	.Dec
	Add.w	Spr_Yadd(a5,d5*8),d1
	Cmp.w	#240,d1
	Bge.s	.Dec
	Add.w	Spr_Height(a5,d5*8),d1
	Bmi.s	.Dec
	Add.w	Spr_Width(a5,d5*8),d0
	Cmp.w	Sprite_Clip_Minx(a4),d0
	Ble.s	.Dec
	Move.l	a0,(a6)+		
.Dec	Add.l	d6,a0
	Dbra	d7,.Loop		
.None	St	(a6)			
	Rts

**********************************************************
Home_Into_Bastards
	Lea	Home_Dir(a4),a6
	Lea	Wep_Anims,a5
	Move.l	Enemy_Sprites_Base(a4),a1
.Loop	Tst.b	(a6)
	Bmi	.End_Loop
	Lea	Home_Table(a4),a2	
	Move.l	(a6)+,a0		
	Movem.w	Wep_X(a0),d0-d1		
	Cmp.w	#-32,d0
	Blt.s	.Dim_Weapon
	Cmp.w	#-32,d1			
	Blt.s	.Dim_Weapon
	Cmp.w	#Byteswide,d0
	Bge.s	.Dim_Weapon
	Cmp.w	#240,d1
	Blt.s	.No_Boundrys
.Dim_Weapon
	Subq.b	#1,Num_Homes(a4)	
	Clr.w	(a0)			
	Bra.s	.Loop
.No_Boundrys
	Clr.l	-(sp)			
	Move.w	#$7fff,d6		
	
.Loopx	Tst.b	(a2)
	Bmi.s	.Done			
	Move.l	(a2)+,a3		
	Movem.w	Aln_X(a3),d2-d3		
	Move.w	Aln_Sprite(a3),d4
	Add.w	d4,d4
	Move.w	Spr_Width(a1,d4*8),d7
	Lsr.w	#1,d7
	Add.w	d7,d2
	Move.w	Spr_Height(a1,d4*8),d7
	Lsr.w	#1,d7
	Add.w	d7,d3
	Sub.w	d0,d2
	Bpl.s	.Pos1
	Neg.w	d2			
.Pos1	Sub.w	d1,d3			
	Bpl.s	.Pos2
	Neg.w	d3			
.Pos2	Add.w	d2,d3			
	Cmp.w	d6,d3			
	Bge.s	.Loopx			
	Move.w	d3,d6			
	Move.l	a3,(sp)			
	Bra.s	.Loopx			

.Done	Cmp.w	#$7fff,d6		
	Move.l	(sp)+,a3		
	Beq.s	.Loop			
	Movem.w	Aln_X(a3),d2-d3		
	Moveq	#0,d4			
	Sub.w	d0,d2			
	Addx.w	d4,d4
	Sub.w	d1,d3
	Addx.w	d4,d4			
	Tst.w	d2
	Bpl.s	.Pos3
	Neg.w	d2
.Pos3	Tst.w	d3			
	Bpl.s	.Pos4
	Neg.w	d3
.Pos4	Cmp.w	d2,d3			
	Addx.w	d4,d4
	Move.b	.Octant(pc,d4),d4	
	Moveq	#0,d6
	Move.b	Wep_Sprite(a0),d6
	Sub.w	#17,d6
	Move.b	.Manauv(pc,d6),d6
	
	Lea	9(a0),a0
	Sub.b	(a0),d4			
	Bpl.s	.Clock			
	Sub.b	d6,(a0)			
	Bra	.Loop
.Clock	Add.b	d6,(a0)			
	Bra	.Loop
.End_Loop
	Rts

.Octant	Dc.b	$60,$40,$00,$20,$80,$a0,$e0,$c0
.Manauv	Dc.b	4,6,8,9,11
	Even
***********************************************************
Seed_Rand
	Moveq	#0,d0			; Clear work reg.
	Move.b	$ff8209.l,d0
	Move.b	$ff8207.l,d1		; Read in video pointers
	Eor.b	d1,d0			; Mix `n` match
	Lsl.w	#8,d1
	Or.w	d1,d0			; Build word.
	Move.l	Realscreenp(a4),a0
	Add.w	$90(a0),d0		; Add some word from the screen
	Add.w	d0,Seed(a4)		; Do some more nonsense stuff.
	Rts
	
**********************************************************
;0-Shot
;1-Laser
;2-Rockets
;3-Homing missle
;4-Big Powerup
;5-Pig
;6-Medal
;7-Tree Fairy
;8-Bomb

Insert_Power
	Move.l	Power_Up_Posp(a4),a0
	St	(a0)
	Lea	Power_Up_Pos(a4),a0
.Loop	Tst.b	(a0)
	Bmi	.Quit
	Bsr	Search_Free_Alien_Slot
	Move.w	#$7fff,Aln_Dmg(a6)
	Moveq	#0,d6
	Move.b	(a0),d6
	Pea	.Loop(pc)
	Jmp	.Tab(pc,d6*4)
.Tab	Jmp	POWERSHOT(PC)
	Jmp	POWERLAZR(PC)
	Jmp	POWERROCK(PC)
	Jmp	POWERHOME(PC)
	Jmp	POWERBIGY(PC)
	Jmp	POWERPIGY(PC)
	Jmp	POWERMEDL(PC)
	Jmp	POWERTREE(PC)
	Jmp	POWERBOMB(PC)
.Quit	Rts

POWERSHOT
	Moveq	#3,d0
	Bra	Sine_In
POWERLAZR
	Moveq	#4,d0
	Bra	Sine_In
POWERROCK
	Moveq	#5,d0
	Bra	Sine_In
POWERHOME
	Moveq	#6,d0
	Bra	Sine_In
POWERBIGY
	Moveq	#38,d0
	Bra	Sine_In
	
Sine_In	Move.w	d0,Aln_Anmset(a6)
	Movem.w	2(a0),d0-d1
	Sub.l	#Byteswide/2,d0		
	Sub.l	#(240-16)/2,d1		
	Add.l	#32,d1			
	Tst.l	d0
	Slt	d6			
	Bge.s	.Ok1
	Neg.l	d0	
.Ok1	Tst.l	d1
	Slt	d7			
	Bge.s	.Ok2
	Neg.l	d1
.Ok2	Cmp.w	d0,d1
	Sgt	d5
	Ble.s	.Ok3			
	Exg	d0,d1
.Ok3	Movem.w	d0-d1,-(sp)		
	Swap	d1
	Tst.w	d0			
	Bne.s	.OkDIV
	Moveq	#1,d0
.OkDIV	Divu	d0,d1			
	Moveq	#-1,d3
	Moveq	#1,d0	
	Moveq	#1,d2
	Tst.b	d5
	Bne.s	.NxB
	Exg	d0,d2
	Exg	d1,d3	
.NxB	Tst.b	d6
	Bne.s	.NxA
	Neg.w	d0			
.NxA	Tst.b	d7
	Bne.s	.Nxc
	Neg.w	d2			
.NxC	
	St	Aln_AnimFlipFlg(a6)
	Move.b	#Pow_Del,Aln_AnimFlipdel(a6)
	Move.w	#9,Aln_Wave(a6)	
	Move.l	2(a0),Aln_X(a6)
	Sub.w	#16,Aln_X(a6)
	Lea	Aln_Shite(a6),a5
	Clr.l	(a5)+			
	Move.w	d1,(a5)+
	Move.w	d3,(a5)+		
	Move.w	d0,(a5)+
	Move.w	d2,(a5)+		
	Movem.w	(sp)+,d0-d1
	Movem.w	2(a0),d2-d3
	Cmp.w	d0,d1
	Bge.s	.OkX
	Exg	d0,d1
.OkX	Move.w	d1,(a5)+		
	Clr.b	(a5)+
	Move.b	#3,(a5)+		
	Move.w	#48,(a5)+		!!!!-SCALE!
	Move.w	#500,Aln_Seqdec(a6)
	Move.l	#Powerup_Down_Seq,Aln_Seqp(a6)
.Dec	Addq.l	#6,a0
	Rts

POWERBOMB
	Move.w	#$7fff,Aln_Seqdec(a6)
	Move.w	#36,Aln_Anmset(a6)
	Move.w	#8,Aln_Wave(a6)
	Or.l	#$00010001,2(a0)
	Movem.w	2(a0),d0-d1
	Cmp.w	#-10,d1
	Bge.s	.Xrt
	Moveq	#-10,d1
.Xrt	Cmp.w	#240,d1
	Blt.s	.XLt
	Move.w	#240,d1
.Xlt	Moveq	#-4,d2
	Moveq	#-4,d3			
	Cmp.w	#Byteswide/2,d0
	Bgt.s	.Okm
	Moveq	#4,d2
.Okm	Cmp.w	#120,d0			
	Bgt.s	.Okm2
	Moveq	#4,d3
.Okm2	Movem.w	d0-d1,Aln_X(a6)
	Moveq	#0,d4
	Moveq	#0,d5
	Moveq	#8,d6
	Movem.w	d2-d6,Aln_Shite(a6)
	Addq.l	#6,a0
	Rts

POWERPIGY
	Moveq	#50,d0
	Bra.s	Powerup_Straight_Dopwn
POWERMEDL
	Moveq	#37,d0

Powerup_Straight_Dopwn
	Move.w	d0,Aln_Anmset(a6)
	Move.l	#1,Aln_Shite(a6)
	Move.l	2(a0),Aln_X(a6)
	Addq.w	#6,Aln_X(a6)
	Addq.w	#6,Aln_Y(a6)
	Move.l	#Branch_Seq,Aln_Seqp(a6)
	Addq.l	#6,a0
	Rts	

POWERTREE
	Move.w	#43,Aln_Anmset(a6)
	Move.l	2(a0),Aln_X(a6)
	Move.l	#Angel_Seq,Aln_Seqp(a6)
	Addq.l	#6,a0
	Rts
	
**********************************************************
Add_Lives
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
.Do	Move.l	a7,a6			; Save stack address
	Move.l	Score(a3),-(sp)		; Score on stack
	Lea	Prevscore+4(a3),a5	; Ready to subtract BCD
	Move	#0,Ccr			; Clear eXtend flag
	Sbcd	-(a5),-(a6)
	Sbcd	-(a5),-(a6)		; 8 Nibbles
	Sbcd	-(a5),-(a6)
	Sbcd	-(a5),-(a6)
	Move.l	(sp)+,d0		; Difference in d0
	Cmp.l	#$00050000,d0		; Difference 1000 ?
	Blt.s	.No			; No, no add lives!
	Addq.l	#4,a5			; Start of previous score!
	Lea	Live_Add+4(pc),a6	; Start of add!
	Move	#0,Ccr			; Clear eXtend
	Abcd	-(a6),-(a5)
	Abcd	-(a6),-(a5)
	Abcd	-(a6),-(a5)		; Add to prev score!
	Abcd	-(a6),-(a5)
	Lea	Num_Lives(a3),a0
	Not.b	(a0)			; Trainer proof way of adding
	Neg.b	(a0)			; Lives
	Cmp.b	#9,(a0)
	Ble.s	.No			; Max lives is 9 !
	Move.b	#9,(a0)
.No	Rts

**********************************************************
Put_Icons
	Bsr	Setup_Blitter
	Lea	Pl1,a0
	Moveq	#0,d0
	Bsr.s	.Do
	Lea	Pl2,a0
	Move.w	#200,d0
	
.Do	Move.w	d0,-(sp)
	Move.w	#Txt_X1+32+10,d0
	Add.w	(sp),d0
	Moveq	#56,d2
	Bsr.s	.Print_Icon
	Move.w	#Txt_X1+120-30,d0
	Add.w	(sp)+,d0
	Moveq	#55,d2

.Print_Icon
	Add.w	Ascreenxoffset(a4),d0
	Move.w	#Txt_Line+9,d1
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	Realscreenp(a4),a5
	Bra	Blit_A_Sprite

**********************************************************
Check_End_Level
	Tst.b	End_Level(a4)
	Beq.s	.No
	Move.l	Player_Use(a4),a3
	St	No_Move(a3)		
	Lea	Shipxy(a3),a0		
	And.l	#$fffefffe,(a0)		
	Movem.w	(a0),d0-d1
	Cmp.w	#192-48,d0
	Beq.s	.X_Ok
	Bgt.s	.SubX
	Addq.w	#4,(a0)	
.SubX	Subq.w	#2,(a0)
.X_Ok	Cmp.w	#190,d1
	Beq.s	.Y_Ok
	Bgt.s	.SubY
	Addq.w	#4,2(a0)		; Move ship to bottom middle
.SubY	Subq.w	#2,2(a0)
.Y_Ok	Movem.w	(a0),d0-d1
	Cmp.w	#192-48,d0
	Bne.s	.No
	Cmp.w	#190,d1			; Compare coards with middle
	Bne.s	.No
	Tst.w	MapCount(a4)
	Beq.s	End_Level_Screen
.No	Rts

End_Level_Screen
	Bsr	Wait_Main_Vbl		; Syncronize with a timed source!
	Bsr	Restore_Sprites		; Restore sprites for this screen
	Bsr	Getrealscreenp		; Adjust screen pointers
	Bsr	Buildmap		; Build current line to buffer	
	Bsr	Scrolldown		; Process scroll info

	Lea	End_Screen_PalName,a0
	Lea	MyPal+128*4,a1
	Trap	#15
	Lea	End_Screen_Name,a0	
	Lea	Stuff_To_Load,a1
	Trap	#15
	Bsr	Mask_Bonus_Screen
	Move.l	Realscreenp(a4),-(sp)
	Bsr	SwapScreens
	Bsr	Restore_Sprites		; Restore sprites for this screen
	Lea	Mypal,a0
	Lea	Destpal(a4),a1
	Move.l	#1024,d0
	Bsr	Copy_Bytes
	St	Blue_Cycle(a4)		
	Move.w	#256,Intens(a4)
	St	Max_Pallete(a4)
	Move.l	(sp)+,Realscreenp+4(a4)
	Bsr	Save_Bonus_Txt
	Bsr	Print_Level_Num
	Bsr	Print_Numbers		

	Moveq	#99,d7
.Wait_2_Seconds
	Bsr	Wait_1_Frame
	Dbra	d7,.Wait_2_Seconds

Bonus_Screen_Main
	Bsr	Wait_4_Frames		
	Bsr	Restore_Bonus_TXT
	Bsr	Print_Numbers		
	Bsr	Add_To_Bonus		
	Tst.b	Next_Level(a4)
	Beq.s	Bonus_Screen_Main

	Bsr	Wait_4_Frames
	Bsr	Restore_Bonus_Txt
	Bsr	Print_Numbers

	Move.w	#199,d7
.Wait_4_Seconds
	Bsr	Wait_1_Frame
	Dbra	d7,.Wait_4_Seconds

	Addq.b	#1,This_Level(a4)	; Level INC
	Cmp.b	#Max_Level,This_Level(a4)	; If level > Max level, GAME COMPLETE
	Bgt	Out
	Bsr	Load_In_Level_Info	; Load in level info
	Sf	Blue_Cycle(a4)
	Move.l	Stack_Save(pc),a7	; Restore stack
	Pea	Main(pc)		; Push Main
	Pea	Re_Initialize(pc)	; And Re[initialize
	Bsr	SwapScreens
	Bsr	Wait_Main_Vbl		; Syncronize with a timed source!
	Clr.b	Frames_To_Consist(a4) 
	Bsr	Getrealscreenp
	Movem.l	Realscreenp(a4),a0-a1
	Exg	a0,a1
	Move.l	#(Height-40)*Byteswide,d0
	Bra	Copy_Bytes

	Move.w	#Height-1,LineOffset+0(a4)
	Move.w	#Height-1,LineOffset+2(a4)
	Move.w	#Height,-(sp)
.Scroll_Loop1
	Bsr	Scroll_Screen_Down
	Bsr	Scroll_Down_Map
	Subq.w	#1,(sp)			
	Bne.s	.Scroll_Loop1
	Bsr	SwapScreens
	Move.w	#Height,(sp)
	Move.w	#Height-1,LineOffset+0(a4)
	Move.w	#Height-1,LineOffset+2(a4)
.Scroll_Loop2
	Bsr	Scroll_Screen_Down
	Subq.w	#1,(sp)			
	Bne.s	.Scroll_Loop2
	Addq.l	#2,sp
	Rts

**********************************************************
Print_Level_Num
	Bsr	Setup_Blitter
	Move.w	#180,d0
	Move.w	#16,d1
	Clr.l	-(sp)
	Clr.l	-(sp)
	Clr.l	-(sp)
	Add.w	AscreenXoffset(a4),d0
	Lea	This_Level(a4),a5
	Movem.l	d0-d1/a0,-(sp)
	Move.l	a5,a0
	Lea	12(sp),a1
	Moveq	#1,d7
	Bsr	Bcd_Ascii
	Movem.l	(sp)+,d0-d1/a0
	Moveq	#0,d2
	Move.b	1(sp),d2
	Sub.b	#"0",d2
	Add.w	#88,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	RealScreenp(a4),a5
	Bra	Blit_A_Sprite

**********************************************************
Mask_Bonus_Screen
	Lea	Stuff_To_Load,a0
	Move.l	a0,d0
	Add.l	d0,Spr_Addr(a0)
	Move.l	Realscreenp(a4),a1
	Move.w	#110,d0	
	Move.w	#16,d1
	Add.w	AscreenXoffset(a4),d0
	Move.w	Spr_Width(a0),d2
	Move.w	Spr_Height(a0),d3
	Move.w	#Byteswide,d4
	Move.w	#Byteswide,d5
	Move.l	Spr_Addr(a0),a0

Draw_A_Sprite
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

**********************************************************
Add_To_Bonus
	Move.l	Player_Use(a4),a3
	Tst.b	Bomb_Or_Medal(a4)	; Bonus to act on!
	Beq.s	.Bomb
.Medal	Tst.b	Medals_Got(a3)
	Beq.s	.Notit			; Make sure <>0
	Subq.b	#1,Medals_Got(a3)	; 1 from count
	Lea	Medal_Bonus+4(pc),a0	; Bonus for medal!
	Bra.s	.Do_Sc			; Add it!
.Bomb	Tst.b	Bombs_Got(a3)
	Beq.s	.Notit
	Subq.b	#1,Bombs_Got(a3)	; Same for BOMB
	Lea	Bomb_Bonus+4(pc),a0
.Do_Sc	Lea	Score+4(a3),a3		; Players score
	Move	#0,Ccr			; Clear X flag
	Abcd	-(a0),-(a3)
	Abcd	-(a0),-(a3)
	Abcd	-(a0),-(a3)		; Add it down!
	Abcd	-(a0),-(a3)
	Rts
.Notit	Not.b	Bomb_Or_Medal(a4)	; Process medals if bombs done!
	Seq	Next_Level(a4)		; Set if medals done!
	Rts

**********************************************************
Print_Numbers
	Bsr	Setup_Blitter
	Lea	Bonus_Txt,a0
.Back	Move.b	(a0)+,d6		
	Bmi	.Exit
	Clr.l	-(sp)
	Clr.l	-(sp)
	Clr.l	-(sp)
	Movem.w	Clearr(a4),d0-d1
	Move.b	(a0)+,d0
	Move.b	(a0)+,d1		
	Add.w	AscreenXoffset(a4),d0
	Addq.l	#1,a0
	Move.l	(a0)+,a5		
	Movem.l	d0-d1/a0,-(sp)
	Move.l	a5,a0
	Lea	12(sp),a1
	Moveq	#0,d7
	Move.b	d6,d7
	Bsr	Bcd_Ascii
	Movem.l	(sp)+,d0-d1/a0
	Move.l	sp,a1
.Loop 	Tst.b	(a1)
	Beq.s	.Exit_Text_Loop
	Move.l	RealScreenp+4(a4),a5
	Move.l	Player_Sprite_Base(a4),a3
	Moveq	#0,d2
	Move.b	(a1)+,d2
	Sub.b	#"0",d2
	Add.w	#88,d2
	Movem.w	d0-d1,-(sp)
	Bsr	Blit_A_Sprite
	Movem.w	(sp)+,d0-d1
	Add.w	#16,d0
	Bra.s	.Loop
.Exit_Text_Loop
	Lea	12(sp),sp
	Bra	.Back
.Exit	Rts

**********************************************************
Save_Bonus_Txt
	Lea	Bonus_Txt+1,a6
	Move.l	Enemy_Sprites_Base(a4),a1
.Loop	Movem.w	Clearr(a4),d0-d1
	Move.b	(a6)+,d0
	Beq.s	.Exit
	Move.b	(a6)+,d1
	Mulu	#Byteswide,d1
	Add.w	Ascreenxoffset(a4),d0
	And.w	#$fff0,d0
	Add.l	d1,d0
	Add.l	RealScreenp+4(a4),d0
	Move.l	d0,(a1)+
	Move.l	d0,a0
	Move.w	#72,d0
	Move.w	#16,d1
	Move.w	#Byteswide,d2
	Move.w	#144,d3
	Bsr	Copy_Block
	Addq.l	#6,a6
	Lea	144*16(a1),a1
	Bra.s	.Loop
.Exit	St	(a1)
	Rts

**********************************************************
Restore_Bonus_Txt
	Move.l	Enemy_Sprites_Base(a4),a0
.Loop	Tst.b	(a0)
	Bmi.s	.Exit
	Move.l	(a0)+,a1
	Move.w	#72,d0
	Move.w	#16,d1
	Move.w	#144,d2
	Move.w	#Byteswide,d3
	Bsr	Copy_Block
	Lea	144*16(a0),a0
	Bra.s	.Loop
.Exit	Rts

**********************************************************
;a0-Source,a1-Dest
;d0-Width,d1-Height,d2-With of source block,d3-Width of dest block

Copy_Block
	Pea	(a6)
	Bsr	Setup_Blitter
	Move.w	#-1,Endmask1(a6)	
	Move.w	#-1,Endmask3(a6)	
	Move.b	#0,Skew(a6)
	Move.b	#$03,Op(a6)
	Move.w	#2,Src_XInc(a6)
	Move.w	#2,Dst_XInc(a6)
	Move.l	a0,Src_Addr(a6)
	Move.l	a1,Dst_Addr(a6)		
	Move.w	d0,d4
	Add.w	d4,d4
	Sub.w	d4,d2
	Addq.w	#2,d2
	Sub.w	d4,d3
	Addq.w	#2,d3
	Move.w	d2,Src_YInc(a6)
	Move.w	d3,Dst_YInc(a6)
	Move.w	d0,X_Count(a6)
	Move.w	d1,Y_Count(a6)
	Move.b	#$c0,Line_Num(a6)
	Move.l	(sp)+,a6
	Rts

**********************************************************
Check_If_Dead
	Move.l	Player_Use(a4),a3
	Tst.b	Just_Dead(a3)
	Beq.s	.Exit
	Bpl.s	.Dead_Routine	
	Subq.b	#2,Just_Dead(a3)
	Tst.w	Ship_Explosion_Num(a3)
	Bmi.s	.Exit
	St	Flag_For_Random_Spit(a4)
	Rts
.Dead_Routine	
	Tst.w	Game_Over_Delay(a4)	
	Bne.s	.Subdel
	Tst.b	Life_Taken_Flag(a3)
	Bne.s	.Life_Taken
	Neg.b	Num_Lives(a3)
	Not.b	Num_Lives(a3)
	Bne.s	.Continue
	Move.w	#100,Game_Over_Delay(a4)		
.Subdel	Subq.w	#1,Game_Over_Delay(a4)
	Bne.s	.Exit	
	St	Life_Taken_Flag(a3)
	St	Fade_Direction(a4)
	Sf	Fade_Flag(a4)
	Move.w	#256,Intens(a4)
.Life_Taken
	Tst.b	Fade_Flag(a4)
	Bne	Out
	Rts
.Continue
	Lea	Pl1,a3
	Bsr	Setup_Player
.Exit	Rts

**********************************************************

Kill_Aliens_If_Bomb
	Move.l	Player_Use(a4),a3
	Tst.b	Bomb_Active(a3)
	Beq.s	.No			
	Tst.b	Bomb_Kill_Count(a4)
	Ble.s	.Kill_Em
	Subq.b	#1,Bomb_Kill_Count(a4)
.No	Rts

.Kill_Em
	Move.b	#Bomb_Kill_Delay,Bomb_Kill_Count(a4)
	Lea	Alien_Table(a4),a0	; Pointer to alien structs.
	Move.w	#Max_Aliens,-(sp)	; Maximum number of checks

.Loop	Pea	Aln_End(a0)
	Tst.w	Aln_Dmg(a0)		; Test hit points, dec !
	Ble.s	.Dec
	Move.w	Aln_Sprite(a0),d5
	Move.l	Aln_X(a0),Aln_X_Save(a4)
	Move.w	#-1,Aln_Sprite_Save(a4)
	Lea	Bomb_Kill_Table,a6
	Tst.b	(a6,d5*2)			
	Beq.s	.Dec			
	Cmp.w	#7,Aln_Anmset(a0)
	Bne.s	.Not_Tank
	Tst.l	Aln_Link(a0)
	Bmi.s	.Not_Tank
	Move.l	Aln_Link(a0),a1
	Bra.s	.Skip
.Not_Tank
	Move.l	a0,a1
	Bsr	Search_Prev_Link
.Skip	Subq.w	#4,Aln_Dmg(a1)
	Bgt.s	.Dec
.Add	Bsr	Add_Score_For_Alien
	Push
	Bsr	Process_Dead_Alien
	Pull
.Dec	Move.l	(sp)+,a0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Move.l	Explosion_Tabp(a4),a0
	St	(a0)
	Move.l	Crator_Tabp(a4),a0
	St	(a0)
	Rts
 
**********************************************************

Check_Event
	Tst.b	Make_Event(a4)		
	Beq	.No_Event
	Tst.b	End_Level(a4)
	Bne	.No_Event
	Sf	Make_Event(a4)		
	Pea	Train_Links1(a4)
	Move.l	(sp)+,Train_Links1p(a4)
	Pea	Train_Links2(a4)
	Move.l	(sp)+,Train_Links2p

	Move.l	Event_Tablep(a4),a0	
	Tst.l	(a0)
	Beq	.No_Event
	Move.l	(a0),d0
	Bpl.s	.Pos
	
	Addq.l	#1,d0
	Seq	End_Level(a4)			; -1 ?
	Beq	.No_Event
	Addq.l	#1,d0
	Seq	No_Bombing(a4)
	Seq	No_Firing(a4)			; -2 ?
	Beq	.No_Event
	Addq.l	#1,d0
	Seq	Speedup(a4)
	Beq	.No_Event
	Addq.l	#1,d0
	Seq	No_More_Scrolling(a4)		; -4 ?
	Beq	.No_Event
.Pos	
;	Rts
	Move.l	d0,a0
.Loop	Tst.w	(a0)			
	Bmi	.No_Event
	Bsr	Fill_Entry
	Pea	(a0)
	Pea	.Restore_Pointer(pc)
	Move.w	Aln_Anmset(a6),d0	
	Cmp.w	#End_Level_Anm_Set,d0
	Seq	d1
	Or.b	d1,No_More_Scrolling(a4)
	Or.b	d1,Fuck_The_Guardian(a4)
	Or.b	d1,End_Level_Y_Mask(a4)
	Pea	Check_For_A_Link(pc)
	Cmp.w	#0,d0
	Seq	Aln_Track_Val(a6)
	And.b	#1,Aln_Track_Val(a6)
	Bne.s	.Ok
	Cmp.w	#7,d0
	Seq	Aln_Track_Val(a6)
	And.b	#2,Aln_Track_Val(a6)
 	Bne.s	.Ok
	Cmp.w	#Zooming_Anm_set,d0
	Seq	Aln_Track_Val(a6)
	And.b	#2,Aln_Track_Val(a6)
 	Bne.s	.Ok
	Cmp.w	#119,d0
	Seq	Aln_Track_Val(a6)
	And.b	#1,Aln_Track_Val(a6)
;  	Bne.s	.Ok 
.Ok	Cmp.w	#10,d0
	Beq.s	.Power_Up_Anim
	Cmp.w	#34,d0
	Beq.s	.Power_Up_Anim
	Cmp.w	#35,d0
	Beq.s	.Power_Up_Anim
	Cmp.w	#45,d0
	Beq.s	.Power_Up_Anim
	Cmp.w	#44,d0
	Beq.s	.Power_Up_Anim

	Cmp.w	#99,d0
	Beq.s	.Power_Up_Anim
	Cmp.w	#101,d0
	Beq.s	.Power_Up_Anim

	Cmp.w	#14,d0
	Beq.s	.Mid2
	Cmp.w	#111,d0
	Beq.s	.Lev3guard
	Cmp.w	#103,d0
	Beq.s	.Hover
	Cmp.w	#78,d0
	Beq.s	.Trn
	Cmp.w	#80,d0
	Beq.s	.Trn
	Cmp.w	#83,d0
	Beq.s	.Trn
	Cmp.w	#85,d0
	Beq.s	.Trn
.No_Event
	Rts

.Restore_Pointer
	Move.l	(sp)+,a0
	Bra	.Loop
	
.Power_Up_Anim
	Move.l	Power_Up_Event_Table_Pointer(a4),a3
	Move.b	(a3)+,Aln_POWNUM(a6)
	Move.l	a3,Power_Up_Event_Table_Pointer(a4)
	Rts

.Hover	Lea	TempTravel_Add(a4),a0
	Lea	Travel_Add(pc),a1
	Bra.s	.Check8000
.Lev3guard
	Lea	Temp_Level3_Add(a4),a0
	Lea	Level3_Add(pc),a1
	Bra.s	.Check8000
.Mid2	Lea	Temp_Mid2_Add(a4),a0
	Lea	Mid2_Add(pc),a1
.Check8000
	Cmp.w	#$8000,(a1)
	Beq.s	.Found8000
	Move.l	(a1)+,(a0)+
	Bra.s	.Check8000
.Found8000
	Rts

.Trn	Move.l	Train_Links1p(a4),a1
	Move.l	a6,(a1)+
	Move.l	a1,Train_Links1p(a4)
	Rts

Check_For_A_Link
	Move.w	Aln_Anmset(a6),d0
	Lea	Link_Offsets(pc),a1
	Move.l	(a1,d0*4),d0
	Beq.s	.No_Linking
	Move.l	d0,a0
	Move.l	(a0)+,Aln_Linkoffsets(a6)
.Loop	Move.l	a6,a1
	Bsr.s	Fill_Entry
	Cmp.w	#8,Aln_Anmset(a6)
	Seq	Aln_Track_Val(a6)
	And.b	#2,Aln_Track_Val(a6)
	Bne.s	.Ok
	Cmp.w	#67,Aln_Anmset(a6)
	Seq	Aln_Track_Val(a6)
	And.b	#2,Aln_Track_Val(a6)
	Bne.s	.Ok
	Cmp.w	#107,Aln_Anmset(a6)
	Seq	Aln_Track_Val(a6)
	And.b	#2,Aln_Track_Val(a6)
	;Bne.s	.Ok
.Ok	Move.l	a6,Aln_Link(a1)
	Move.l	a1,Aln_Prevlink(a6)
	Tst.w	(a0)
	Bpl.s	.Loop
.No_Linking
	Rts

Fill_Entry
	Bsr	Search_Free_Alien_Slot  
	Move.w	(a0)+,Aln_Dmg(a6)
	Move.w	(a0)+,Aln_Anmset(a6)
	Move.l	(a0)+,Aln_X(a6)	
	Move.l	(a0)+,Aln_Seqp(a6)
	Rts

**********************************************************
; Returns angle in d2!

Get_Angle_From_Alien_To_Ship
	Move.w	#$80,-(sp)
	Move.l	Player_Use(a4),a3
	Movem.w	Shipxy(a3),d0-d1
	Movem.w	Aln_X(a2),d4-d5
	Add.w	Ascreenxoffset(a4),d0
	Add.w	#16,d0
	Add.w	#16,d1
	Sub.w	d4,d0	
	Smi	d6
	Bpl.s	.Pos
	Neg.w	d0
.Pos	Sub.w	d5,d1			
	Smi	d7
	Bpl.s	.Pos1
	Neg.w	d1
.Pos1	Cmp.w	d0,d1
	Sgt	d5			; Set if Y vector greater than
	Bgt.s	.Yvectg			; Y vector is Greater than
	Exg	d0,d1			; Exchange if X vector > Than!
.Yvectg	And.w	#$fffe,d1
	Move.w	d1,d2
	Lsr.w	#1,d2
	Bne.s	.Ok
	Moveq	#0,d0
	Moveq	#4,d1
	Bra.s	.Notne1
.Ok	Divu	d2,d0			; Divide down 1
	Divu	d2,d1			; Divide down 1
	Tst.b	d5
	Bne.s	.No_Exg
	Exg	d0,d1			; Exchange Vectors!
.No_Exg	Tst.b	d6
	Beq.s	.Notne0
	Neg.w	d0
.Notne0	Tst.b	d7
	Beq.s	.Notne1
	Neg.w	d1		
.Notne1	Add.w	d0,d0
	Add.w	d1,d1
	Lea	VectorTab(pc),a3
	Moveq	#0,d2
	Moveq	#1,d3
	Moveq	#15,d4
.Loop	Cmp.w	(a3)+,d0
	Bne.s	.Skip
	Cmp.w	(a3),d1
	Beq.s	.Out
.Skip	Add.b	d3,d2
	Addq.l	#2,a3
	Dbra	d4,.Loop
	Bra.s	.Exitrk
.Out	Lsl.w	#4,d2
	Move.w	d2,(sp)
.Exitrk	Move.w	(sp)+,d2
	Rts

**********************************************************
; X/Y in d0/d1
; Angle in d2
; Scale in d3
; Initial Scale in d4
; Weapon animset in d5

Insert_Weapon
	Bsr	Search_Free_Alien_Slot	
	Move.w	#$1,Aln_Dmg(a6)
	And.w	#$ff,d2
	Move.w	#500,Aln_Seqdec(a6)	; 300 loops regardless
	Move.l	#Fuck_Seq,Aln_Seqp(a6)	; After done, quit !
	St	Aln_CoardKill(a6)
	Move.w	#6,Aln_Wave(a6)		; Vector move
	Move.w	d2,Aln_Shite(a6)	; Angle
	Move.w	d3,Aln_Shite+4(a6)	; Scale
	Move.w	d5,Aln_Anmset(a6)	; Animset to use
	Lea	Alien_Sine(pc),a3
	Move.w	(a3,d2*2),d6
	Add.w	#$40,d2
	And.w	#$ff,d2
	Move.w	(a3,d2*2),d7
	Add.w	d4,d4
	Muls	d4,d6			; X offset
	Muls	d4,d7			; y Offset
	Swap	d6
	Swap	d7
	Add.w	d6,d0
	Add.w	d7,d1
	Movem.w	d0-d1,Aln_X(a6)
	Rts

**********************************************************

Insert_Alien
	Move.l	Aliens_Insert_P(a4),a0
	St	(a0)
	Lea	Aliens_Insert_T(a4),a0  Pointer to insert structure!
.Loop	Move.w	(a0)+,d0		Insert number !
	Bmi.s	.Exit			-ive then end !
	Movem.l	(a0)+,a1/a2		Which player/ Alien structure
	Jsr	.Jt(pc,d0*4)		Go to it !
	Bra.s	.Loop			Next !
.Exit	Rts

.Jt	Bra	Ins0			Normal energy bolt
	Bra	Ins0			Direction missle!
	Bra	Ins2			Power up bolts
	Bra	Ins3			Track fire
	Bra	Ins4			Enlarged Alien
	
	Bra	Ins6
	Bra	Ins5
	Bra	Ins8			Cannons for end level !
	Bra	Ins7
	Bra	Ins9
	Bra	Ins10
	Bra	Ins11
	Bra	Ins12
	Bra	Ins13
	Bra	Ins14

	Bra	Ins15
	Bra	Ins16
	Bra	Ins17
	Bra	Ins18
	Bra	Ins19			; Tank fires
	Bra	Ins20
	Bra	Ins21
	Bra	Ins22

	Bra	Ins23			; Plane down fire !
	
	Bra	Ins24
	Bra	Ins25
	Bra	Ins26
	Bra	Ins27
	
	Bra	Ins28			; Bomb stuff !
	
	Bra	Ins29
	Bra	Ins30
	Bra	Ins31			; Plane up fire !
	Bra	Ins32
	
	Bra	Ins33
	Bra	Ins34
	Bra	Ins35
	Bra	Ins36
	Bra	Ins37			; Mid2Tank fires
	Bra	Ins38
	Bra	Ins39
	Bra	Ins40

	Bra	Ins41
	Bra	Ins42			;Plane fires
	
	Bra	Ins43			; Hovercraft fires
	
	Bra	Ins44			; Straight down fires
	
	Bra	Ins45			; Left wing fire
	Bra	Ins46			; Right wing fire
	
	BRA	Ins47
	BRA	Ins48
	BRA	Ins49			; Mid guardian fire
	
	Bra	Ins50
	Bra	Ins51			; Center bolts for mid2
	Bra	Ins52			; Center bolts for mid2
	Bra	Ins53
	
	Bra	Ins54			; 
	Bra	Ins55			; 
	Bra	Ins56			; Second level Mad! Bolts!
	Bra	Ins57			; 
	Bra	Ins58			; 
	Bra	Ins59			; 
	
	Bra	Ins60
	Bra	Ins61			; Shots for Backturretslev3
	Bra	Ins62

	Bra	Ins63
	Bra	Ins64
	Bra	Ins65
	Bra	Ins66
	
	Bra	Ins67			; Shots for Backturretslev3
	Bra	Ins68			; Shots for Backturretslev3
	Bra	Ins69			; Shots for Backturretslev3
	Bra	Ins70			; Shots for Backturretslev3

	Bra	Ins71			; Bolts for end lev baddy4
	Bra	Ins72			; Bolts for end lev baddy4
	Bra	Ins73			; Bolts for end lev baddy4
	
	Bra	Ins74			; Spinny bits 5
	Bra	Ins75			; Big gun 5
	Bra	Ins76			; Wing guns 
	Bra	Ins77			; Wing guns 

Ins77	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Addq.w	#4,d0
	Addq.w	#8,d1
	Bra	Insert_Weapon

Ins76	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Movem.w	(sp),d0-d5
	Addq.w	#4,d0
	Addq.w	#4,d1
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Add.w	#20,d0
	Addq.w	#4,d1
	Bra	Insert_Weapon
	
	

Ins75	Movem.w	Aln_X(a2),d0-d1
	Add.w	#10,d0
	Add.w	#32,d1
	Moveq	#$80,d2
	Moveq	#8,d3
	Moveq	#0,d4
	Moveq	#96,d5
	Bra	Insert_Weapon

Ins74	Movem.w	Aln_X(a2),d0-d1
	Add.w	#16,d0
	Add.w	#16,d1
	Moveq	#0,d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#12,-(sp)
.Loop	MOvem.w	2(sp),d0-d5
	Add.w	#21,6(sp)
	Bsr	Insert_Weapon
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Movem.w	(sp)+,d0-d5
	Rts

Ins71	Movem.w	Aln_X(a2),d0-d1
	Subq.w	#2,d0
	Moveq	#$80,d2
	Moveq	#$5,d3
	Moveq	#2,d4
	Move.w	#49,d5
	Bsr	Insert_Weapon
	Movem.w	Aln_X(a2),d0-d1
	Addq.w	#06,d0
	Moveq	#$80,d2
	Moveq	#$5,d3
	Moveq	#2,d4
	Move.w	#49,d5
	Bra	Insert_Weapon

Ins72	Movem.w	Aln_X(a2),d0-d1
	Moveq	#6,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#$20,-(sp)
	Move.w	#4,-(sp)
.Loop	Movem.w	4(sp),d0-d5
	Move.w	2(sp),d2
	Bsr	Insert_Weapon
	Add.w	#$40,2(SP)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	16(sp),sp
	Rts	

Ins73	Movem.w	Aln_X(a2),d0-d1
	Moveq	#0,d2
	Moveq	#6,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#$60,-(sp)
	Move.w	#3,-(sp)
.Loop	Movem.w	4(sp),d0-d5
	Move.w	2(sp),d2
	Bsr	Insert_Weapon
	Add.w	#$20,2(SP)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	16(sp),sp
	Rts	

Ins67	Movem.w	Aln_X(a2),d0-d1
	Moveq	#0,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#8,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$20,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts

Ins68	Movem.w	Aln_X(a2),d0-d1
	Moveq	#$20,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#4,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$40,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts

Ins69	Movem.w	Aln_X(a2),d0-d1
	Moveq	#$20,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#2,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$80,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts


Ins70	Movem.w	Aln_X(a2),d0-d1
	Moveq	#$60,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#2,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$80,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts


Ins63	Moveq	#0,d6
	Bra.s	Shoot_End3

Ins64	Moveq	#+$08,d6
	Bsr.s	Shoot_End3
	Moveq	#-$08,d6
	Bra.s	Shoot_End3

Ins65	Moveq	#$10,d6
	Bsr.s	Shoot_End3
	Moveq	#-$10,d6
	Bra.s	Shoot_End3

Ins66	Moveq	#$18,d6
	Bsr.s	Shoot_End3
	Moveq	#-$18,d6
;	Bra.s	Shoot_End3

Shoot_End3
	Movem.w	Aln_X(a2),d0-d1
	Addq.w	#6,d0
	Addq.w	#6,d1
	Moveq	#8,d3
	Moveq	#0,d4
	Move.w	#Trendy_Bolts_Anm_Set,d5
	Move.w	Aln_Shite(a2),d2
	Add.w	d6,d2
	Bra	Insert_Weapon
	
Ins62	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Anmset(a2),d2
	Sub.w	#124,d2
	Movem.w	.Offset(pc,d2*4),d3-d4
	Add.w	d3,d0
	Add.w	d4,d1
	Move.w	.Angle_Tab(pc,d2*2),d2
	Moveq	#9,d3
	Moveq	#0,d4
	Moveq	#Trendy_Bolts_Anm_Set,d5
	Movem.w	d0-d5,-(sp)
	Bsr	Insert_Weapon
	Move.w	#8,6(sp)
	Movem.w	(sp),d0-d5
	Addq.b	#8,d2
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d5
	Subq.b	#8,d2
	Bsr	Insert_Weapon
	Rts

.Angle_Tab	Dc.w	$a0,$90,$80,$70,$60
.Offset	Dc.w	$0,$0
	Dc.w	$0,$0
	Dc.w	$0,$0
	Dc.w	$0,$0
	Dc.w	$0,$0

Ins60	Movem.w	Aln_X(a2),d0-d1
	Move.w	Aln_Shite(a2),d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Movem.w	(sp),d0-d5
	Addq.w	#4,d0
	Bsr	Insert_Weapon
	Movem.w	(sp),d0-d5
	Add.w	#24,d0
	Bsr	Insert_Weapon
	Lea	12(sp),sp	
	Rts

Ins61	Movem.w	Aln_X(a2),d0-d1
	Moveq	#0,d2
	Moveq	#8,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#4,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$40,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts
	
Ins54	Moveq	#$38,d0
	Bra.s	SecondLev_Doubleshot
Ins55	Moveq	#$30,d0
	Bra.s	SecondLev_Doubleshot
Ins56	Moveq	#$28,d0
	Bra.s	SecondLev_Doubleshot
Ins57	Moveq	#$18,d0
	Bra.s	SecondLev_Doubleshot
Ins58	Moveq	#$10,d0
	Bra.s	SecondLev_Doubleshot
Ins59	Moveq	#$0,d0
;	Bra.s	SecondLev_Doubleshot

SecondLev_Doubleshot
	Move.w	d0,-(sp)
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#-16,d0
	Add.w	#16,d1
	Moveq	#$80,d2
	Sub.w	(sp),d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#32,d0
	Add.w	#16,d1
	Moveq	#$80,d2
	Sub.w	(sp),d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#-16,d0
	Add.w	#16,d1
	Moveq	#$80,d2
	Add.w	(sp),d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#32,d0
	Add.w	#16,d1
	Moveq	#$80,d2
	Add.w	(sp),d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Addq.l	#2,sp
	Rts
	
Ins50	Moveq	#$80,d0
	Moveq	#$c0,d1
	Moveq	#$00,d2
	Moveq	#$40,d3
	Moveq	#4,d4
	Bra.s	Do_Center_Mid2
Ins51	Moveq	#$a0,d0
	Moveq	#$e0,d1
	Moveq	#$20,d2
	Moveq	#$60,d3
	Moveq	#4,d4
	Bra.s	Do_Center_Mid2
Ins52	Moveq	#$10,d0
	Moveq	#$50,d1
	Moveq	#$90,d2
	Moveq	#$d0,d3
	Moveq	#4,d4
	Bra.s	Do_Center_Mid2
Ins53	Moveq	#$30,d0
	Moveq	#$70,d1
	Moveq	#$b0,d2
	Moveq	#$f0,d3
	Moveq	#4,d4
;	Bra.s	Do_Center_Mid2

Do_Center_Mid2
	Move.w	d4,d7
	Movem.w	d0-d3,-(sp)
.Loop	Move.w	(sp)+,d2
	Movem.w	Aln_X(a2),d0-d1
	Moveq	#8,d3
	Move.w	#0,d4
	Move.w	#96,d5
	MOve.w	d7,-(sp)
	Bsr	Insert_Weapon
	MOve.w	(sp)+,d7
	Subq.w	#1,d7
	Bne.s	.Loop
	Rts
	
Ins47	Moveq	#-20,d0
	Moveq	#40,d1
	Bra.s	Ins44
Ins48	Moveq	#-10,d0
	Moveq	#40,d1
	Bra.s	Ins44
Ins49	Moveq	#0,d0
	Moveq	#40,d1
	Bra.s	Ins44
	
	
Ins45	Moveq	#13,d0
	Moveq	#8,d1
	Bra.s	Ins44
Ins46	Moveq	#17,d0
	Moveq	#8,d1
;	Bra.s	Ins44
	
; Offsets for x/y in d0/d1 - Fire straight down
Ins44	Add.w	Aln_X(a2),d0
	Add.w	Aln_Y(a2),d1
	Moveq	#$80,d2
	Moveq	#12,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon
	
Ins41	Moveq	#0,d0
	Bra	Planeup_Shots
Ins42	Moveq	#$10,d0
	Bsr	Planeup_Shots
	Moveq	#$20,d0
	Bra	Planeup_Shots
	
Ins43	Movem.w	Aln_X(a2),d0-d1
	Add.w	#16,d0
	Add.w	#14,d1
	Move.l	Aln_Link(a2),a2
	Move.b	Aln_Prevsprite(a2),d2			; Hovercraft fires
	Lsl.w	#4,d2
	Moveq	#10,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Bra	Insert_Weapon
	
Ins23	Bsr	Get_Angle_From_Alien_To_Ship
	Subq.w	#4,d2
	Movem.w	Aln_X(a2),d0-d1
	Moveq	#7,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Bsr	Insert_Weapon
	Add.w	#48,Aln_X(a2)
	Bsr	Get_Angle_From_Alien_To_Ship
	Addq.w	#4,d2
	Movem.w	Aln_X(a2),d0-d1
	Sub.w	#48,Aln_X(a2)
	Moveq	#7,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Bra	Insert_Weapon

Ins15	Moveq	#0,d3
	Bra.s	Big_Tank_Fired
Ins16	Moveq	#$20,d3
	Bra.s	Big_Tank_Fired
Ins17	Moveq	#$40,d3
	Bra.s	Big_Tank_Fired
Ins18	Moveq	#$60,d3
	Bra.s	Big_Tank_Fired
Ins19	Moveq	#$80,d3
	Bra.s	Big_Tank_Fired
Ins20	Moveq	#$a0,d3
	Bra.s	Big_Tank_Fired
Ins21	Moveq	#$c0,d3
	Bra.s	Big_Tank_Fired
Ins22	Moveq	#$e0,d3

Big_Tank_Fired
	Move.w	d3,d2
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#16,d0
	Add.w	#16,d1
	Move.w	#10,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Bra	Insert_Weapon

Ins9	Moveq	#10,d0
	Moveq	#10,d1
	Bra.s	Ins_Second
Ins10	Moveq	#14,d0
	Moveq	#10,d1
	Bra.s	Ins_Second
Ins11	Moveq	#-14,d0
	Moveq	#20,d1
	Bra.s	Ins_Second
Ins12	Moveq	#2,d0
	Moveq	#20,d1
	Bra.s	Ins_Second
Ins13	Moveq	#-30,d0
	Moveq	#20,d1

;Straight down
Ins_Second
	Movem.w	Aln_X(a2),d2-d3
	Add.w	d0,d2
	Add.w	d1,d3
	Move.w	d2,d0
	Move.w	d3,d1
	Moveq	#$80,d2
	Moveq	#7,d3
	Moveq	#0,d4
	Moveq	#2,d5
	Bra	Insert_Weapon

Ins14	Movem.w	Aln_X(a2),d0-d1
	Move.b	Aln_Prevsprite(a2),d2
	Lsl.w	#4,d2
	Moveq	#10,d3
	Moveq	#4,d4
	Moveq	#Trendy_Bolts_Anm_Set,d5
	Bra	Insert_Weapon
	
Ins5	Moveq	#$c0,d2
	Bra.s	Do_Cannon_End_Level_Shot
Ins6	Moveq	#$a0,d2
	Bra.s	Do_Cannon_End_Level_Shot
Ins7	Moveq	#$60,d2
	Bra.s	Do_Cannon_End_Level_Shot
Ins8	Moveq	#$40,d2

Do_Cannon_End_Level_Shot
	Movem.w	Aln_X(a2),d0-d1
	Moveq	#10,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Bra	Insert_Weapon


Ins28	Movem.w	Aln_X(a2),d0-d1
	Moveq	#10,d2
	Moveq	#10,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Movem.w	d0-d5,-(sp)
	Move.w	#8,-(sp)
.Loop	Movem.w	2(sp),d0-d5
	Bsr	Insert_Weapon
	Add.w	#$20,6(sp)
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Lea	14(sp),sp
	Rts

Ins0	Movem.w	Aln_X(a2),d0-d1
	Move.b	Aln_Prevsprite(a2),d2
	Lsl.w	#4,d2
	Moveq	#10,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Bra	Insert_Weapon

Ins2	Bsr	Get_Angle_From_Alien_To_Ship
	Move.w	d2,-(sp)
	Moveq	#7,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	Aln_X(a2),d0-d1
	Bsr	Insert_Weapon
	Move.w	(sp),d2
	Sub.w	#$10,d2
	Moveq	#7,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	Aln_X(a2),d0-d1
	Bsr	Insert_Weapon
	Move.w	(sp)+,d2
	Add.w	#$10,d2
	Moveq	#7,d3
	Moveq	#2,d4
	Moveq	#2,d5
	Movem.w	Aln_X(a2),d0-d1
	Bra	Insert_Weapon

Ins33	Moveq	#0,d6
	Bra.s	Ins3
Ins34	Moveq	#4,d6
	Bra.s	Ins3
Ins35	Moveq	#2,d6
	Bra.s	Ins3
Ins36	Moveq	#-2,d6
	Bra.s	Ins3
Ins37	Moveq	#-6,d6
	Bra.s	Ins3
Ins38	Moveq	#-4,d6
	Bra.s	Ins3
Ins39	Moveq	#8,d6
	Bra.s	Ins3
Ins40	Moveq	#6,d6
;	Bra.s	Ins3

; Angle offset in d6
Ins3	Move.b	Aln_Prevsprite(a2),d2
	Lsl.w	#4,d2
	Add.w	d6,d2
.Find	Tst.l	Aln_Prevlink(a2)
	Bmi.s	.Found
	Move.l	Aln_Prevlink(a2),a2
	Bra.s	.Find
.Found	Movem.w	Aln_X(a2),d0-d1
	Add.w	#14,d0
	Add.w	#14,d1
	Moveq	#7,d3
	Moveq	#0,d4
	Move.w	#Trendy_Bolts_Anm_Set,d5
	Bra	Insert_Weapon

Ins4	Movem.w	Aln_X(a2),d0-d1
	Add.w	#10,d0
	Add.w	#32,d1
	Movem.w	d0-d1,-(sp)
	Move.w	#$80,d2
	Moveq	#8,d3
	Moveq	#0,d4
	Move.w	#Bolt_Anm_Set,d5
	Bsr	Insert_Weapon
	Move.w	#1,Aln_Dmg(a6)
	Movem.w	(sp)+,d0-d1
	Add.w	#20,d0
	Move.w	#$80,d2
	Moveq	#8,d3
	Moveq	#0,d4
	Move.w	#Bolt_Anm_Set,d5
	Bsr	Insert_Weapon
	Move.w	#1,Aln_Dmg(a6)
	Rts

Search_Free_Alien_Slot
	Lea	Alien_Table(a4),a6	
.Find	Tst.w	(a6)			
	Ble.s	.Found			
	Lea	Aln_End(a6),a6		
	Bra.s	.Find			
.Found	Movem.l	d0-d7,-(sp)
	Movem.w	Data+Clearr,d0-d7
	Movem.l	d0-d7,(a6)
	Movem.l	d0-d7,32(a6)
	Movem.l	d0-d2,64(a6)
	Movem.l	(sp)+,d0-d7
	Move.w	#$7fff,(a6)		
	St	Aln_Link(a6)		
	St	Aln_PrevLink(a6)	
	Rts

Ins24	Moveq	#$20,d0
	Bra.s	Two_Vector_Shots
Ins25	Moveq	#$18,d0
	Bra.s	Two_Vector_Shots
Ins26	Moveq	#$10,d0
	Bra.s	Two_Vector_Shots
Ins27	Moveq	#$08,d0
;	Bra.s	Two_Vector_Shots

Two_Vector_Shots
	Move.w	d0,d6
	Move.b	Aln_Prevsprite(a2),d2
	Lsl.w	#4,d2
	Movem.w	Aln_X(a2),d0-d1
	Moveq	#10,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Movem.w	d0-d6,-(sp)
	Sub.w	d6,d2
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d6
	Add.w	d6,d2
	Bra	Insert_Weapon

Ins29	Moveq	#$08,d0
	Bra.s	Planeup_Shots
Ins30	Moveq	#$18,d0
	Bra.s	Planeup_Shots
Ins31	Moveq	#$28,d0
	Bra.s	Planeup_Shots
Ins32	Moveq	#$30,d0
;	Bra.s	Planeup_Shots

Planeup_Shots
	Move.w	d0,d6
	Move.w	#$80,d2
	Movem.w	Aln_X(a2),d0-d1
	Add.w	#30,d1
	Moveq	#10,d3
	Moveq	#4,d4
	Moveq	#2,d5
	Movem.w	d0-d6,-(sp)
	Add.w	d6,d2
	Add.w	#10,d0
	Bsr	Insert_Weapon
	Movem.w	(sp)+,d0-d6
	Add.w	#50,d0
	Sub.w	d6,d2
	Bra	Insert_Weapon


	
**********************************************************
Weapons_To_Aliens
	Pea	Explosion_Tab(a4)
	Move.l	(sp)+,Explosion_Tabp(a4)
	Pea	Crator_Tab(a4)
	Move.l	(sp)+,Crator_Tabp(a4)
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do
	Move.l	a3,Player_Use(a4)
	Lea	Shots_To_Do(a3),a0	
	Move.w	#Max_Weapons,-(sp)
Weapon_Loop	
	Tst.b	(a0)
	Ble.s	.Dec_Weapon_Count
	Movem.w	Wep_X(a0),d0-d1		
	Movem.w	Wep_X(a0),d2-d3		
	Moveq	#0,d4			
	Move.b	Wep_Anim(a0),d4		
	Clr.b	Home_Flag(a4)
	Cmp.b	#22,d4
	Bcc.s	.NoHom
	Cmp.b	#17,d4
	Bcs.s	.Nohom
	St	Home_Flag(a4)
.Nohom	Lea	Wep_Coard_Adj_Tab(pc),a6	
	Movem.w	(a6,d4*8),d4-d7
	Add.w	d4,d0
	Add.w	d5,d1
	Add.w	d6,d2
	Add.w	d7,d3
	Bsr.s	Compare_This_Weapon
.Dec_Weapon_Count
	Lea	Wep_End(a0),a0
	Subq.w	#1,(sp)
	Bne.s	Weapon_Loop
	Addq.l	#2,sp
	Move.l	Crator_Tabp(a4),a0
	St	(a0)
	Move.l	Explosion_Tabp(a4),a0
	St	(a0)
	Rts

Compare_This_Weapon
	Move.w	Sprites_To_Draw(a4),-(sp)
	Ble.s	No_More_Aliens
	Lea	Alien_Table(a4),a1		
	Move.l	Enemy_Sprites_Base(a4),a5		
Alien_Loop	
	Tst.w	(a1)
	Bgt.s	.OktoCompare		
	Lea	Aln_End(a1),a1		
	Bra.s	Alien_Loop
.OktoCompare
	Pea	Aln_End(a1)
	Move.w	Aln_sprite(a1),d6
	Bsr	Check_Coards
	Bne.s	.Missed
	Movem.w	d0-d1,Aln_X_Save(a4)
	Move.w	#-1,Aln_Sprite_Save(a4)
	Bsr	Explosion16	
	Move.l	Player_Use(a4),a3
	Lea	Score+4(a3),a3
	Lea	Score_Added_When_Ya_Hit+4(pc),a2
	Move	#0,ccr
	Abcd	-(a2),-(a3)
	Abcd	-(a2),-(a3)
	Abcd	-(a2),-(a3)
	Abcd	-(a2),-(a3)
	Bsr	Process_Hit
	Bgt.s	.Did_Not_Die
	Addq.l	#4,sp
	Bsr	Add_Score_For_alien	
	Bsr	Process_Dead_Alien
	Lea	Explosion_Sfx,a6
	Bsr	Play_This_Sample
	Bra.s	No_More_Aliens
.Missed
.Did_Not_Die
	Move.l	(sp)+,a1
	Subq.w	#1,(sp)
	Bne.s	Alien_Loop
No_More_Aliens
	Addq.l	#2,sp
	Rts

Score_Added_When_Ya_Hit
	Dc.l	$00000010

Check_Coards	
	Lea	Wdo_Or_Die(pc),a6
	Tst.b	(a6,d6)			Check if you can hit !
	Beq.s	.Cant_Hit		0 - nope !

	Cmp.w	#7,Aln_Anmset(a1)
	Bne.s	.Not_Tank
	Tst.l	Aln_Link(a1)
	Bgt.s	.Cant_Hit
.Not_Tank
	Lea	Alien_Boxes(pc),a6
	Lea	(a6,d6*8),a6
	Movem.w	Aln_X(a1),d4-d5		
	Movem.w	Aln_X(a1),d6-d7		
	Add.w	(a6)+,d4
	Add.w	(a6)+,d5
	Add.w	(a6)+,d6
	Add.w	(a6)+,d7
	Cmp.w	d0,d6			
	Blt.s	.Cant_Hit		
	Cmp.w	d2,d4			
	Bgt.s	.Cant_Hit
	Cmp.w	d1,d7			
  	Blt.s	.Cant_Hit
	Cmp.w	d3,d5			
	Bgt.s	.Cant_Hit
	Moveq	#0,d7
	Rts
.Cant_hit
	Moveq	#-1,d7
	Rts

Process_Hit
	Move.b	Home_Flag(a4),d5
	Add.b	d5,Num_Homes(a4)
	Moveq	#0,d5
 	Move.b	(a0),d5			
	Clr.b	(a0)			
 	Bsr.s	Search_Prev_Link
	Sub.w	d5,(a1)			
	Rts

Search_Prev_Link
	Cmp.w	#124,Aln_Anmset(a1)
	Blt.s	.No_Cannon
	Cmp.w	#128,Aln_Anmset(a1)
	Ble.s	.No_More
.No_Cannon
	Cmp.w	#120,Aln_Anmset(a1)
	Blt.s	.No_Backturret
	Cmp.w	#122,Aln_Anmset(a1)
	Ble.s	.No_More
.No_Backturret
	Cmp.w	#89,Aln_Anmset(a1)
	Beq.s	.No_More
	Cmp.w	#90,Aln_Anmset(a1)
	Beq.s	.No_More
	Cmp.w	#8,Aln_Anmset(a1)
	Beq.s	.No_More
	Cmp.w	#175,Aln_Anmset(a1)
	Beq.s	.No_More
	Cmp.w	#Cannon_Anm_Set,Aln_Anmset(a1)
	Bne.s	.Search_First
	Move.l	Aln_Prevlink(a1),a2
	Cmp.w	#Cannon_Base_Anm_Set,Aln_Anmset(a2)
	Beq.s	.No_More
.Search_First
	Tst.l	Aln_Prevlink(a1)
	Ble.s	.No_More
	Move.l	Aln_Prevlink(a1),a1
	Bra.s	.Search_First
.No_More
	Rts

	
Add_Score_For_Alien
	Move.w	Aln_Sprite(a1),d0
	Lea	Scoretable(pc),a6	
	Lea	$4(a6,d0*4),a6		
	Move.l	Player_Use(a4),a3
	Lea	Score+4(a3),a3
	Move	#0,Ccr
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Rts

Process_Dead_Alien
	Move.l	Aln_X(a1),Aln_X_Save(a4)
	Move.w	Aln_Sprite(a1),d1
	Move.w	d1,Aln_Sprite_Save(a4)
	Lea	Explosion_And_Crator_Offset_Table(pc),a6
	Move.b	(a6,d1*2),d2
	Move.b	$1(a6,d1*2),d3
	Ext.w	d2
	Ext.w	d3
	Add.w	d2,Aln_X_Save(a4)
	Add.w	d3,Aln_X_Save+2(a4)
	Lea	Dead_Alien_Jump_Table(pc),a6
	Moveq	#0,d0
	Move.b	(a6,d1),d0
	Jmp	.Jt(pc,d0*4)

.Jt	Bra	DoExplosion32
	Bra	Explosion32_Crator32
	Bra	DoExplosion64
	Bra	Explosion64_Crator64
	Bra	Bolt
	Bra	Cannon
	Bra	Turret
	Bra	DoExplosion16
	Bra	Train_Carraige
	Bra	Second_Guardian
	Bra	Bomb8way
	Bra	Casket
	Bra	Bigpowup
	Bra	James_Brown_Is_Dead
	Bra	Tree_Is_Dead
	Bra	No_Effect
	Bra	Void_Sprite32
	Bra	Void_Sprite64
	Bra	Third_Guardian
	Bra	Scafhit
	Bra	Powmid4_Killed
;0-32*32 Explosion
;1-32*32 Explosion with 32*32 crator
;2-64*64 Explosion 
;3-64*64 Explosion with 64*64 Crator
;4- Bolt
;5- Cannon
;6- Turret
;7- 16x16 explosion
;8- Back train/Carraige
;9- Bits for second level guardian
;10-Bomb 8way
;11-Casket
;12-Big-power-up
;13-End Level 1 !
;14-Tree
;15-No effect
;16-Void it (32)!
;17-Void it (64)!
;18-Third Guardian
;19-SCAFOLDING LEFT/RIGHT!
;20-Pow_Mid4 killed

Powmid4_Killed
	Move.l	Power_Up_Posp(a4),a2
	Move.l	Aln_Link(a1),a3
	
	Move.w	#0,(a2)+
	Move.l	Aln_X(a3),(a2)
	Sub.w	#40,(a2)+	
	Add.w	#10,(a2)+	

	Move.l	Aln_Link(a3),a3
	Move.w	#$0200,(a2)+
	Move.l	Aln_X(a3),(a2)
	Add.w	#20,(a2)+	
	Add.w	#10,(a2)+	
 	Move.l	a2,Power_Up_PosP(a4)
	Bra	DoExplosion64

Tree_Is_Dead
	Move.l	Power_Up_Posp(a4),a2
	Move.b	ALN_POWNUM(a1),(a2)+
 	Addq.l	#1,a2
	Move.l	Aln_X(a1),(a2)+	
 	Move.l	a2,Power_Up_PosP(a4)
	Bra	DoExplosion32

Void_Sprite32
	Bsr	Void_It	
	Bra	Explosion32
	
Void_Sprite64
	Cmp.w	#89,Aln_Anmset(a1)
	Bne.s	.Check_If_Anm90
	Move.l	Aln_Link(a1),a2
	Tst.w	Aln_Anmset(a2)
	Bmi.s	.Double_Killed
	Bra.s	.Not_Anm90
.Check_If_Anm90
	Cmp.w	#90,Aln_Anmset(a1)
	Bne.s	.Not_Anm90
	Move.l	Aln_Prevlink(a1),a2
	Tst.w	Aln_Anmset(a2)
	Bmi.s	.Double_Killed
.Not_Anm90
	Cmp.w	#120,Aln_Anmset(a1)
	Beq.s	.Turret_Cannon_Add
	Cmp.w	#124,Aln_Anmset(a1)
	Blt.s	.Not_Anm120
	Cmp.w	#128,Aln_Anmset(a1)
	Bgt.s	.Not_Anm120
.Turret_Cannon_Add
	Addq.b	#1,Number_Of_Turrets_Left3(a4)
.Not_Anm120
	Bsr	Void_It	
	Bra	Explosion64
.Double_Killed
	Bsr	Void_It	
	Move.l	a1,a2
.Search	Tst.l	Aln_Prevlink(a2)
	Bmi.s	.There
	Move.l	Aln_Prevlink(a2),a2
	Bra.s	.Search	
.There	Move.w	#400,Aln_Dmg(a2)
	Bra	Explosion64
	
Void_It	Clr.b	Aln_Anim(a1)
	Move.w	#-1,Aln_Anmset(a1)
	Move.w	#-1,Aln_Sprite(a1)
	Move.w	#10,Aln_Dmg(a1)
	Move.l	#Do_Nothing_Seq,Aln_Seqp(a1)
	Rts


Train_Carraige
	Moveq	#0,d6
	Lea	Train_Links1(a4),a2
.Loop	Cmp.l	(a2)+,a1
	Beq.s	.Found_Link_In_Train	
	Addq.w	#1,d6
	Bra.s	.Loop
.Found_Link_In_Train	
	Clr.l	-4(a2)
.Loopx	Cmp.w	#2,d6
	Beq.s	.Thats_It
	Bsr.s	.Kill_Train	
	Addq.w	#1,d6
	Bra.s	.Loopx
.Thats_It
	Bsr	Kill_Link
	Bra	Explosion64

.Kill_Train
	Tst.l	(a2)+
	Beq.s	.No_Stop
	Move.l	-4(a2),a3
	Lea	Train_Slow_Down_Table(a4),a6
.Find	Tst.l	(a6)+
	Bne.s	.Find
	Move.l	a3,-(a6)
.No_Stop
	Rts

Third_Guardian
	Clr.b	Guardian_Explosion_Count(a4)
	St	Guardian_Is_Dead(a4)
	Move.l	Aln_X(a1),Guardians_Last_Position(a4)
	Add.w	#68,Guardians_Last_Position(a4)
	Add.w	#70,Guardians_Last_Position+2(a4)
	Bsr	Kill_Link
	Bra	Explosion64

Second_Guardian
	Clr.b	Guardian_Explosion_Count(a4)
	St	Guardian_Is_Dead(a4)
	Move.l	Aln_X(a1),Guardians_Last_Position(a4)
	Add.w	#38,Guardians_Last_Position(a4)
	Add.w	#10,Guardians_Last_Position+2(a4)
	Bsr	Kill_Link
	Bra	Explosion64

Turret	Move.l	Aln_Prevlink(a1),a3
	St	Aln_Link(a3)
	Bra	Explosion32

Cannon	Move.l	Aln_Prevlink(a1),a2
	St	Aln_Link(a2)
	Bsr	Kill_Link
 	Bra	Explosion32

James_Brown_Is_Dead
	Move.l	Aln_X(a1),Guardians_Last_Position(a4)
	Add.w	#56,Guardians_Last_Position(a4)
	Add.w	#60,Guardians_Last_Position+2(a4)
	St	Guardian_Is_Dead(a4)
	Bsr	Kill_Link
	Rts

Bolt	Bra	DoExplosion16

Bomb8way
	Move.l	Aliens_Insert_P(a4),a3
	Move.w	#28,(a3)+		; Weapon number !
	Move.l	Player_Use(a4),(a3)+
	Move.l	a1,(a3)+ 		; Start of this X/Y and shit !
	Move.l	a3,Aliens_Insert_P(a4)	; Restore pointer !
	Bsr	Kill_Link
	Bra	Explosion64

Scafhit	Move.l	Power_Up_Posp(a4),a2
	Move.b	ALN_POWNUM(a1),(a2)+
 	Addq.l	#1,a2
	Movem.w	Aln_X(a1),d3-d4
	Add.w	#11,d3
	Add.w	#11,d4
	Move.w	d3,(a2)+
	Move.w	d4,(a2)+
 	Move.l	a2,Power_Up_PosP(a4)
	Bra	DoExplosion64	

Casket	Move.l	Power_Up_Posp(a4),a2
	Move.b	ALN_POWNUM(a1),(a2)+
 	Addq.l	#1,a2
	Move.l	Aln_X(a1),(a2)+	
 	Move.l	a2,Power_Up_PosP(a4)
	Bra	Explosion32

Bigpowup
 	Move.l	Aln_X(a1),d4
	Add.l	#$00180018,d4
 	Move.l	Power_Up_PosP(a4),a2
 	Move.b	ALN_POWNUM(a1),(a2)+
 	Addq.l	#1,a2
 	Move.l	d4,(a2)+
 	Move.l	a2,Power_Up_PosP(a4)
	Bsr	Kill_Link
	Bra	Explosion64

No_Effect
	Rts

Kill_Link
	Move.l	a1,a6
.Kill_Link
	Tst.l	Aln_Link(a6)
	Ble.s	.Skip_Link
	Move.l	Aln_Link(a6),-(sp)
	St	(a6)
;	St	Aln_Prevlink(a6)
;	Clr.l	Aln_Link(a6)
	Move.l	(sp)+,a6
 	Subq.w	#1,Sprites_To_Draw(a4)	
	Bra.s	.Kill_Link
.Skip_Link
	Subq.w	#1,Sprites_To_Draw(a4)
	St	(a6)
;	Clr.l	Aln_Link(a6)
	Rts

DoExplosion16
	Bsr	Kill_Link	
Explosion16
	Move.l	Explosion_Tabp(a4),a6
	Move.w	#0,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Explosion_Tabp(a4)
	Rts
DoExplosion32
	Bsr	Kill_Link	
Explosion32
	Lea	Explosion_Sfx,a6
	Bsr	Play_This_Sample
	
	Move.l	Explosion_Tabp(a4),a6
	Move.w	#1,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Explosion_Tabp(a4)
	Rts
Crator32
	Move.l	Crator_Tabp(a4),a6
	Move.w	#1,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Crator_Tabp(a4)
	Rts
Explosion32_Crator32
	Bsr	Kill_Link
	Bsr	Explosion32
	Bra	Crator32
DoExplosion64
	Bsr	Kill_Link
Explosion64
	Lea	Explosion_Sfx,a6
	Bsr	Play_This_Sample
	Move.l	Explosion_Tabp(a4),a6
	Move.w	#3,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Explosion_Tabp(a4)
	Rts
Crator64
	Move.l	Crator_Tabp(a4),a6
	Move.w	#3,(a6)+
	Move.w	Aln_Sprite_Save(a4),(a6)+
	Move.l	Aln_X_Save(a4),(a6)+
	Move.l	a6,Crator_Tabp(a4)
	Rts
Explosion64_Crator64
	Bsr	Kill_Link
	Bsr	Explosion64
	Bra	Crator64
		
**********************************************************
Insert_Crators
	Move.l	Crator_Tabp(a4),a0
	St	(a0)
	Lea	Crator_Tab(a4),a0
.Loop	Tst.b	(a0)	
	Bmi.s	.Exit
	Movem.w	(a0)+,d0-d3		
	Move.w	#240,d4
	Sub.w	d3,d4
	Ble.s	.Loop
	Bsr	Search_Free_Alien_Slot		
	Movem.w	d2-d3,Aln_X(a6)
	Clr.w	Aln_Wave(a6)
	Move.l	#1,Aln_Shite(a6)
	Move.w	d4,Aln_Seqdec(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)
	Move.w	.Size(pc,d0*2),d4
	Cmp.w	#46,d4
	Bne.s	.Not_32
	Subq.b	#1,Diff_32Crator(a4)
	Bge.s	.Not_32
	Addq.w	#1,d4
	Addq.b	#2,Diff_32Crator(a4)
.Not_32	Move.w	d4,Aln_Anmset(a6)
	Bra.s	.Loop
.Exit	Rts
.Size	Dc.w	47,46,00,48

**********************************************************
Insert_Explosion
	Move.l	Explosion_Tabp(a4),a0
	St	(a0)
	Lea	Explosion_Tab(a4),a0
	Lea	Alien_Anim_Table,a3
.Loop	Tst.b	(a0)	
	Bmi.s	.Exit
	Movem.w	(a0)+,d0-d3		Size/Sprite/X/Y
	Bsr	Search_Free_Alien_Slot		
	Clr.w	Aln_Wave(a6)
	Movem.w	d2-d3,Aln_X(a6)
	Moveq	#2,d6
	Tst.b	No_More_Scrolling(a4)
	Seq	d7
	And.b	d7,d6
	Move.l	d6,Aln_Shite(a6)
	Move.l	#Fuck_Seq,Aln_Seqp(a6)
	Move.w	.Size(pc,d0*2),d2
	Move.w	d2,Aln_Anmset(a6)
	Move.l	(a3,d2*4),a2
	Move.w	(a2)+,d2
	Moveq	#-1,d3
.Muloop	Add.w	d2,d3
	Tst.w	(a2)+
	Bpl.s	.Muloop
	Sub.w	d2,d3
	Move.w	d3,Aln_Seqdec(a6)
	Bra.s	.Loop
.Exit	Rts
.Size	Dc.w	30,31,53,52

**********************************************************
Insert_Bonus_Sprites
	Move.l	Score_Bonus_Tablep(a4),a0
	St	(a0)
	Lea	Score_Bonus_Table(a4),a0
.Loop	Tst.b	(a0)
	Bmi.s	.Exit
	Movem.w	(a0)+,d0-d2			Type/X/Y
	Bsr	Search_Free_Alien_Slot		
	Movem.w	d1-d2,Aln_X(a6)
	Move.l	#Bonus_Sprite_Sequence,Aln_Seqp(a6)
	Add.w	#21,d0
	Move.w	d0,Aln_Anmset(a6)
	Bra.s	.Loop
.Exit	Rts

**********************************************************
Alien_To_Ship
	Pea	Score_Bonus_Table(a4)
	Move.l	(sp)+,Score_Bonus_Tablep(a4)
	Move.l	Player_Use(a4),a3
.Do	Tst.b	Just_Dead(a3)
	Beq.s	.Go
	Rts
.Go	Tst_Act
	Tst_Startup
	Tst.w	Sprites_To_Draw(a4)	; Test if we need to draw anything
	Beq	.Exit
	Move.l	Enemy_Sprites_Base(a4),a5
	Lea	Alien_Table(a4),a1	
	Lea	Test_Priority(pc),a6
	Movem.w	Shipxy(a3),d0-d1	
	Addq.w	#8,d1
	Add.w	AScreenXoffset(a4),d0	
	Tst.b	Vga_Flag(a4)
	Beq.s	.Mon
	Sub.w	#32,d0
.Mon	Add.w	#40,d0	
	Addq.w	#2,d1
	Move.w	d0,d2
	Move.w	d1,d3
	Add.w	#16,d2			
	Add.w	#16,d3
	Move.w	Sprites_To_Draw(a4),-(sp)
.Loop	Tst.w	(a1)			
	Bgt.s	.Ok_to_Compare		
	Lea	Aln_End(a1),a1		
	Bra.s	.Loop			
.Ok_To_Compare
	Movem.w	Aln_X(a1),d4-d5		
	Move.w	Aln_sprite(a1),d6
	Tst.b	(a6,d6)			
	Beq	.Nohit			
	Move.w	d6,Alien_Test(a4)
	Add.w	d6,d6
	Lea	Alien_Boxes(pc),a2
	Lea	(a2,d6*4),a2
	Move.w	d4,d6		
	Move.w	d5,d7		
	Add.w	(a2)+,d4
	Add.w	(a2)+,d5
	Add.w	(a2)+,d6
	Add.w	(a2)+,d7
.Compare_Coards	
	Cmp.w	d0,d6			
	Blt	.Nohit			
	Cmp.w	d2,d4			
	Bgt	.Nohit
	Cmp.w	d1,d7			
	Blt	.Nohit
	Cmp.w	d3,d5			
	Bgt	.Nohit

	Move.w	Alien_Test(a4),d6
	Bsr	Check_Power_Up

	Beq	.Play_Collect_Sfx
	Tst.b	NoColl
	Bne.s	.Nohit
	Ifeq	Collision	
	Bra.s	.Nohit
	Endc

	Tst.b	Dead_Count(a3)
	Bne.s	.Nohit
	Move.l	Power_Up_Posp(a4),a2
	Move.w	Seed(a4),d5
	And.w	#$1,d5
	Move.b	#0,(a2)+
	Add.b	d5,-1(a2)
	Addq.l	#1,a2
	Move.l	Shipxy(a3),d4
	Swap	d4
	Add.w	AscreenXoffset(a4),d4
	Swap	d4
	Move.l	d4,(a2)+
	Tst.b	Secondry_Weapon(a3)
	Bmi.s	.No_Second
	Tst.b	Weapon_Power2(a3)
	Beq.s	.No_Second
	Move.b	#2,(a2)+
	Add.b	d5,-1(a2)
	Addq.l	#1,a2
	Move.l	d4,(a2)+
.No_Second
	Move.l	a2,Power_Up_Posp(a4)
	St	No_Move(a3)		
	St	Just_Dead(a3)
	Move.w	#Player_Explosion_Delay,Ship_explosion_Dec(a3)
	Clr.w	Ship_Explosion_Num(a3)
	Push
	Lea	Explosion_Sfx,a6
	Bsr	Play_This_Sample
	Pull
	Bra.s	.Done

.Nohit	Lea	Aln_End(a1),a1		
	Subq.w	#1,(sp)
	Bne	.Loop
.Done	Addq.l	#2,sp
.Exit	
	Move.l	Crator_Tabp(a4),a0
	St	(a0)
	Move.l	Explosion_Tabp(a4),a0
	St	(a0)
	Rts		

.Play_Collect_Sfx
	Push
	Lea	Collect_Sfx,a6
	Bsr	Play_This_Sample
	Pull
	Bra.s	.Nohit

Check_Power_Up
	Cmp.w	#43,Aln_Anmset(a1)
	Beq	.Angel_Hit
	Cmp.w	#Pig_Anm_Set,Aln_Anmset(a1)
	Beq.s	.Hit_Pig
	Cmp.w	#37,Aln_Anmset(a1)
	Beq	.Hit_Medal
	Moveq	#0,d4
	Lea	.Power_Up_Collection_Table(pc),a6
	Move.w	Aln_Anmset(a1),d3
.Loop	Tst.w	(a6)
	Bmi.s	.Not_Found_Powerup
	Cmp.w	(a6)+,d3
	Beq.s	.Power_Up_Found
	Addq.w	#1,d4
	Bra.s	.Loop
.Not_Found_Powerup
	And.b	#$fb,Ccr		
	Rts

.Power_Up_Collection_Table
	Dc.w	3,4,5,6,36,38
	Dc.w	-1

;Routines for Hitpig,Tree Fairy,Medal,Bomb+Powerups

.Hit_Pig
	Movem.l	d5/a3/a6,-(sp)
	Move.l	Score_Bonus_Tablep(a4),a2
	Move.w	#0,(a2)+
	Move.l	Aln_X(a1),(a2)+
	Move.l	a2,Score_Bonus_Tablep(a4)
	Bsr	Kill_Link
	Moveq	#0,d5
	Move.b	d6,d5
	Bsr	Add_Score_For_Alien
	Movem.l	(sp)+,d5/a3/a6
	Bra	.No_Power		
.Angel_Hit
	Bsr.s	.Hit_Medal
	Move.l	Score_Bonus_Tablep(a4),a2
	Move.w	#1,(a2)+
	Move.l	Aln_X(a1),(a2)+
	Move.l	a2,Score_Bonus_Tablep(a4)
	Subq.b	#1,Medals_Got+Pl1	
	Bra	.No_Power		
.Hit_Medal
	Movem.l	d5/a3/a6,-(sp)
	Move.l	Player_Use(a4),a3	
	Addq.b	#1,Medals_Got(a3)	
	Moveq	#0,d5
	Move.b	d6,d5
	Bsr	Add_Score_For_Alien
	Bsr	Kill_Link
	Movem.l	(sp)+,d5/a3/a6
	Bra	.No_Power		

.Power_Up_Found
	Bsr	Kill_Link
	Cmp.w	#4,d4
	Beq.s	.Bomb_Got
	Cmp.w	#5,d4
	Bne.s	.Move_It
	Move.b	#4,Weapon_Power(a3)	
	Tst.b	Secondry_Weapon(a3)
	Bmi.s	.No_Power
	Move.b	#4,Weapon_Power2(a3)
	Bra.s	.No_Power
.Bomb_Got
	Moveq	#0,d5
	Move.b	d6,d5
	Bsr	Add_Score_For_Alien
	Move.l	Player_Use(a4),a3
	Addq.b	#1,Num_Bombs(a3)
	Addq.b	#1,Bombs_Got(a3)	
	Cmp.b	#9,Num_Bombs(a3)
	Ble.s	.No_Power		
	Move.b	#9,Num_Bombs(a3)
	Bra.s	.No_Power
.Move_It
	Moveq	#0,d5
	Move.b	d6,d5
	Movem.l	d5/a3/a6,-(sp)
	Bsr	Add_Score_For_Alien
	Movem.l	(sp)+,d5/a3/a6
	Move.w	d4,d6
	Cmp.w	#2,d6
	Blt.s	.Prime			
	Subq.b	#2,d6			
	Cmp.b	Secondry_Weapon(a3),d6
	Seq	d5
	Move.b	d6,Secondry_Weapon(a3)	
	Tst.b	d5
	Beq.s	.No_Power		
	Cmp.b	#4,Weapon_Power2(a3)	
	Beq.s	.Score_Add_For_Weapon
	Addq.b	#1,Weapon_Power2(a3)	
	Bra.s	.No_Power
.Prime	Cmp.b	Weapon_In_Use(a3),d6
	Seq	d5
	Move.b	d6,Weapon_In_Use(a3)	
	Tst.b	d5
	Beq.s	.No_Power
	Cmp.b	#4,Weapon_Power(a3)	
	Beq.s	.Score_Add_For_Weapon
	Addq.b	#1,Weapon_Power(a3)	
.No_Power	
	Or.b	#$4,Ccr			
	Rts
	
.Score_Add_For_Weapon
	Movem.l	d5/a3/a6,-(sp)
	Lea	.Bonus10000+4(pc),a6
	Move.l	Player_Use(a4),a3
	Lea	Score+4(a3),a3
	Move	#0,Ccr
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Abcd	-(a6),-(a3)	
	Move.l	Score_Bonus_Tablep(a4),a2
	Move.w	#1,(a2)+
	Move.l	Aln_X(a1),(a2)+
	Move.l	a2,Score_Bonus_Tablep(a4)
	Movem.l	(sp)+,d5/a3/a6
	Bra.s	.No_Power	
	
.Bonus10000
	Dc.l	$0010000

**********************************************************
Play_This_Sample
	Movem.l	d0/a5-a6,-(sp)
	Move.w	2(a6),d0
	Lea	-4(a6,d0),a5
	Move.w	(a6),d0
	Addq.l	#4,a6
	Tst.b	Sample_A_Finished
	Beq.s	.No1
	Clr.w	Chan1_Pri(a4)
	Clr.b	Sample_A_Finished
.No1	Tst.w	d0
	Bpl.s	.Compare1
	Neg.w	d0
	Cmp.w	Chan1_Pri(a4),d0
	Bgt.s	.Play_Cha1
	Bra.s	.Skip1
.Compare1
	Cmp.w	Chan1_Pri(a4),d0
	Bge.s	.Play_Cha1
.Skip1	Tst.b	Sample_B_Finished
	Beq.s	.No2
	Clr.w	Chan2_Pri(a4)
	Clr.b	Sample_B_Finished
.No2	Tst.w	d0
	Bpl.s	.Compare2
	Neg.w	d0
	Cmp.w	Chan2_Pri(a4),d0
	Bgt.s	.Play_Cha2
	Bra.s	.Exit
.Compare2
	Cmp.w	Chan2_Pri(a4),d0
	Bge.s	.Play_Cha2
.Exit	Movem.l	(sp)+,d0/a5-a6
	Rts
.Play_Cha1
	Move.w	d0,Chan1_Pri(a4)
	Move.l	a6,Sample_A_Start
	Move.l	a5,Sample_A_End
	Bra.s	.Exit
.Play_Cha2
	Move.w	d0,Chan2_Pri(a4)
	Move.l	a6,Sample_A_Start
	Move.l	a5,Sample_A_End
	Bra.s	.Exit
**********************************************************
Check_If_Moving_Power_Up
	Tst.b	Aln_AnimFlipFlg(a0)	; Does this anim flip at a given interval
	Beq.s	.No_Animflip		; NO!
	Subq.b	#1,Aln_AnimFlipdel(a0)
	Bcc.s	.No_Animflip		; 1 from flip-del, <0 indicates anim flip
	Move.b	#Pow_Del,Aln_Animflipdel(a0)	; Set delay
	Move.w	Aln_Anmset(a0),d0	; Get alien anim
	Cmp.w	#5,d0
	Bge.s	.FivSix			; If true flip between anims 5/6
	Eor.w	#%100,Aln_Anmset(a0)	; Swith between 3/4
.FivSix	Eor.w	#%011,Aln_Anmset(a0)	; Else between 5/6
.No_Animflip
	Rts

**********************************************************
Dec_Track_Amounts
	Subq.b	#1,Track_Del1(a4)
	Bpl.s	.Pos_Track_Del1
	Move.b	#Track_Amount1,Track_Del1(a4)
.Pos_Track_Del1
	Subq.b	#1,Track_Del2(a4)
	Bpl.s	.Pos_Track_Del2
	Move.b	#Track_Amount2,Track_Del2(a4)
.Pos_Track_Del2
	Rts

**********************************************************
Move_Aliens
	Pea	Power_Up_Pos(a4)
	Move.l	(sp)+,Power_Up_Posp(a4)	; Setup pointer to power up table
	Pea	Aliens_Insert_T(a4)
	Move.l	(sp)+,Aliens_Insert_P(a4)	; Setup pointer for alien insert
	Lea	Alien_Table(a4),a0		; Base pointer to alien list
	Clr.w	Sprites_To_Draw(a4)		; No sprites to draw
	Move.w	#Max_Aliens,-(sp)		; Counter on stack

.Loop	Tst.w	Aln_Dmg(a0)			; Valid sprite if DMG>0
	Ble	.Exit				; Else check next sprite
.No_Coardcheck
	Tst.b	Aln_CoardKill(a0)		; Check flag
	Beq.s	.Skip
	Bsr	Check_Coard_Out_Of_Range	; Kill alien if out of screen boundrys
	Bne	.Exit				; Alien was out of bounds if !=0
.Skip	Bsr	Check_If_Moving_Power_Up	; Moving powerup may mean you have to change its anim at any given time
	Moveq	#0,d0
	Moveq	#0,d1			
	Move.b	Aln_Delay(a0),d0	; Anim delay
	Move.b	Aln_Anim(a0),d1		; Anim number
	Move.w	Aln_Anmset(a0),d2	; Anim set number
	Lea	Alien_Anim_Table,a2	; Pointer to base
	Move.l	(a2,d2*4),a2		; Anim table to use
	Tst.b	Aln_Pauseflag(a0)
	Bne.s	.No_Anim_End		; If anim has been paused, Skip anim code
	Tst.b	Aln_Animflag(a0)
	Bne.s	.No_Anim_End		; Flag to restart anim,!= Skip
	Addq.w	#1,d0			; 1 to anim delay
	Cmp.w	(a2),d0
	Blt.s	.No_Anim_End		; if current anim delay < specified anim delay
	Moveq	#0,d0			; Reset delay
	Addq.w	#1,d1			; Bump anim number
.No_Anim_End
	Tst.w	2(a2,d1*2)		; If -IVE, then reached end of anim list
	Spl	d6			; Set register if positive
	And.b	d6,d1			; Mask anim number
	Tst.b	d6
	Bne.s	.Animnum_Notzero	; If mask exists
	Move.b	Aln_AnimCont(a0),Aln_Animflag(a0) ; Continue anim, or pause at frame 0
.Animnum_Notzero
	Move.w	2(a2,d1*2),Aln_Sprite(a0) ; Sprite number from anim table
	Move.b	d0,Aln_Delay(a0)	; Resave anim delay/anim number
	Move.b	d1,Aln_Anim(a0)
	Move.w	Aln_Wave(a0),d2		; Attack wave number
	Movem.w	Aln_X(a0),d0-d1		; Get XY
	Lea	Aln_Shite(a0),a5	; Pointer to variables pertaining to the way we move
	Jsr	Path_Jt(pc,d2*4)	; Get ready for return
	Movem.w	d0-d1,Aln_X(a0)		; Changed XY, RESTORE IT !
	Subq.w	#1,Aln_Seqdec(a0)	; Sequence decrement
	Bgt.s	.Nodecrement		; No new sequence, BRANCH
	Move.l	Aln_Seqp(a0),a2		; Sequence in order
	Lea	Aln_Wave(a0),a1		; Pointer to sprite wave number
	Lea	Aln_Shite(a0),a5	; Wave variable space
	Lea	Comm_Table(pc),a3	; Pointer to Jump table of new sequences
	Move.w	(a2)+,d2		; Command number
	Jsr	(a3,d2*4)		; Call appropriate routine
	Move.l	a2,Aln_Seqp(a0)		; Save pointer
.Nodecrement
	Addq.w	#1,Sprites_To_Draw(a4)	; 1 more sprite to draw
.Exit	Lea	Aln_End(a0),a0		; Next sprite
	Subq.w	#1,(sp)
	Bne	.Loop			; For all sprites
	Addq.l	#2,sp			; Align stack
	Rts

Check_Coard_Out_Of_Range
	Movem.w	Aln_X(a0),d0-d1		; Sprite coardianates
	Cmp.w	#-32,d0
	Ble.s	.Out_Of_Range
	Cmp.w	#-32,d1
	Ble.s	.Out_Of_Range
	Cmp.w	#Byteswide,d0		; Check if its out of range	
	Bge.s	.Out_Of_Range
	Cmp.w	#240,d1	
	Bge.s	.Out_Of_Range
	Moveq	#0,d0			; Zero, sprite has not escaped boundrys
	Rts
.Out_Of_Range
	Move.w	#-1,Aln_Dmg(a0)		; !=0, sprite has escaped, and kills its damage points
	Rts

	Rts
	Nop

Path_Jt	Jmp	Attack_Wave0(pc)	; X/Y ADD	
	Jmp	Attack_Wave1(pc)	; Left/right Sine
	Jmp	Attack_Wave2(pc)	; Up/Down Sine
	Jmp	Attack_Wave3(pc)	; X Swoop
	Jmp	Attack_Wave4(pc)	; Y Swoop
	Jmp	Attack_Wave5(pc)	; Some sort of sine
	Jmp	Attack_Wave6(pc)	; Vector Move
	Jmp	Attack_Wave7(pc)	; Track !
	Jmp	Attack_Wave8(pc)	; Bomb movements
	Jmp	Attack_Wave9(pc)	; Bounce
	Jmp	Attack_Wave0(pc)	
	Jmp	Attack_Wave11(pc)	; Spit-Out-home
	Jmp	Attack_Wave12(pc)	; Noop !
	Jmp	Attack_Wave13(pc)	; Accelerate towards


Attack_Wave0
	Add.w	(a5)+,d0		; Relative offset to X coardinate
	Add.w	(a5)+,d1		; Relative offset to Y coardinate
	Tst.b	No_More_Scrolling(a4)
	Beq.s	.Scrolling
	Cmp.w	#119,Aln_Anmset(a0)
	Beq.s	.Back1
	Cmp.w	#111,Aln_Anmset(a0)
	Beq.s	.Back1
	Cmp.w	#46,Aln_Anmset(a0)
	Beq.s	.Back1
	Cmp.w	#47,Aln_Anmset(a0)
	Beq.s	.Back1
	Cmp.w	#48,Aln_Anmset(a0)
	Bne.s	.Scrolling
.Back1	Subq.w	#1,d1
.Scrolling
	Rts

Attack_Wave1
	Bsr	Sprite_Sine_Routine
 	Sub.w	(a5),d0			; Subtract this val from X
	Move.w	d2,(a5)+		; Save Word wot we got !
	Add.w	d2,d0			; Add to X
	Bra.s	Attack_Wave0		; Add next 2 to X/Y

Attack_Wave2
	Bsr	Sprite_Sine_Routine
	Sub.w	(a5),d1			; Subtract this val from X
	Move.w	d2,(a5)+		; Save Word wot we got !
	Add.w	d2,d1			; Add to X
	Bra.s	Attack_Wave0		; Add next 2 to X/Y

Sprite_Sine_Routine
	Lea	Alien_Sine(pc),a2
	Movem.w	(a5)+,d2-d3		; Current sine / Speed in d2-d3
	Add.b	d3,d2			; Sine table is just 256 Words	
	Move.w	d2,-4(a5)		; Resave !
	Move.w	(a2,d2*2),d2		; Sine value in d2
	Muls	(a5)+,d2		; Scale it!
	Add.l	d2,d2
	Swap	d2
	Rts

Sprite_Half_Sine_Routine
	Lea	Alien_Sine(pc),a2
	Movem.w	(a5)+,d2-d3
	Add.b	d3,d2
	Move.w	d2,-4(a5)		; Same as sine calculation
	Lsr.w	#1,d2
	Move.w	(a2,d2*2),d2		; Only for a half-circle
	Muls	(a5)+,d2		; Scale it
	Add.l	d2,d2
	Swap	d2
	Rts

Attack_Wave3
	Bsr	Sprite_Half_Sine_Routine
	Sub.w	(a5),d0			; Previous value from x
	Move.w	d2,(a5)+		; O.k In !
	Add.w	d2,d0			; Add sine value to X
	Bra	Attack_Wave0		; Add next 2 words !

Attack_Wave4
	Sub.w	(a5),d1			; Previous value from Y
	Move.w	d2,(a5)+		; O.k In !
	Add.w	d2,d1			; Add sine value to Y
	Bra	Attack_Wave0		; Add next 2 words !

Attack_Wave5
	Lea	Alien_Sine(pc),a2
	Movem.w	(a5)+,d2-d5
	Add.b	d4,d2
	Add.b	d5,d3
	Movem.w	d2-d3,-8(a5)		; Save em !
	Move.w	(a2,d2*2),d2
	Move.w	(a2,d3*2),d3		Sine values !
	Muls	(a5)+,d2
	Muls	(a5)+,d3		Scale values 
	Add.l	d2,d2
	Add.l	d3,d3
	Swap	d2
	Swap	d3
	Sub.w	(a5),d0
	Move.w	d2,(a5)+
	Sub.w	(a5),d1			Subtract previous values !
	Move.w	d3,(a5)+
	Bsr	Attack_Wave0		Add x/y scale !
	Add.w	d2,d0
	Add.w	d3,d1			Get new x/y
	Rts

Attack_Wave6
	Lea	Alien_Sine(pC),a2
	Move.w	(a5)+,d2		Angle
	Add.w	(a5)+,d2		Adjust angle
	And.w	#$ff,d2			Mask for sine !
	Move.w	d2,-4(a5)		Resave angle
	Move.w	(a2,d2*2),d3		X offset !
	Add.b	#$40,d2
	Move.w	(a2,d2*2),d2		Y offset !
	Tst.w	d2
	Smi	d5
	Bpl.s	.PosA
	Neg.w	d2
.PosA	Tst.w	d3
	Smi	d6
	Bpl.s	.PosB
	Neg.w	d3
.PosB	Muls	(a5),d2	
	Muls	(a5)+,d3		Scale !
	Add.l	d2,d2
	Add.l	d3,d3
	Moveq	#0,d4
	Add.w	d2,(a5)
	Swap	d2
	Addx.w	d4,d2
	Add.w	d3,2(a5)
	Swap	d3
	Addx.w	d4,d3
	Tst.b	d5
	Beq.s	.MM1
	Neg.w	d2
.Mm1	Tst.b	d6
	Beq.s	.MM2
	Neg.w	d3
.Mm2	Add.w	d3,d0
	Sub.w	d2,d1
	Addq.w	#1,d1
	Rts

Attack_Wave7
	Movem.w	d0-d1,-(sp)
	Tst.b	Track_Del2(a4)
	Bne	.Exitrk
	Move.l	Player_Use(a4),a3
	Movem.w	Shipxy(a3),d0-d1
	Movem.w	Aln_X(a0),d4-d5
	Add.w	Ascreenxoffset(a4),d0
	Add.w	#16,d0
	Add.w	#16,d1
	Sub.w	d4,d0	
	Smi	d6
	Bpl.s	.Pos
	Neg.w	d0
.Pos	Sub.w	d5,d1			
	Smi	d7
	Bpl.s	.Pos1
	Neg.w	d1
.Pos1	Cmp.w	d0,d1
	Sgt	d5			; Set if Y vector greater than
	Bgt.s	.Yvectg			; Y vector is Greater than
	Exg	d0,d1			; Exchange if X vector > Than!
.Yvectg	And.w	#$fffe,d1
	Move.w	d1,d2
	Lsr.w	#1,d2
	Bne.s	.Ok
	Moveq	#0,d0
	Moveq	#4,d1
	Bra.s	.Notne1
.Ok	Divu	d2,d0			; Divide down 1
	Divu	d2,d1			; Divide down 1
	Tst.b	d5
	Bne.s	.No_Exg
	Exg	d0,d1			; Exchange Vectors!
.No_Exg	Tst.b	d6
	Beq.s	.Notne0
	Neg.w	d0
.Notne0	Tst.b	d7
	Beq.s	.Notne1
	Neg.w	d1		
.Notne1	Add.w	d0,d0
	Add.w	d1,d1
	Lea	VectorTab(pc),a3
	Moveq	#0,d2
	Moveq	#1,d3
	Moveq	#15,d4
.Loop	Cmp.w	(a3)+,d0
	Bne.s	.Skip
	Cmp.w	(a3),d1
	Beq.s	.Out
.Skip	Add.b	d3,d2
	Addq.l	#2,a3
	DBra	d4,.Loop
	Bra.s	.Exitrk
.Out	Move.w	(a5),d4
	Lsr.w	#4,d4
	Move.w	d4,(a5)
	Move.w	d2,d4
	Cmp.w	(a5),d4
	Beq.s	.Pos_C
	Sub.w	(a5),d2			; Get clockwise difference
	Bge.s	.Clock
	Add.w	#16,d2
.Clock	Move.w	(a5),d4
	Subq.w	#$1,d4
	Cmp.w	#8,d2
	Bge.s	.Pos_C
	Addq.w	#$2,d4
.Pos_C	And.w	#$f,d4
	Move.b	d4,Aln_Prevsprite(a0)
	Lsl.w	#4,d4
	Move.w	d4,(a5)			; Save value in structure !
.Exitrk	Movem.w	(sp)+,d0-d1
	Rts



Attack_Wave8
	Sf	6(a5)
	Sf	d5			; Flag to dec number of times ya bounced
	Sub.w	4(a5),d0
	Tst.w	8(a5)
	Ble.s	.Set
	Cmp.w	#-16,d0	
	Blt.s	.Set
	Cmp.w	#-16,d1
	Blt.s	.Set
	Cmp.w	#240,d1
	Bge.s	.Set
	Cmp.w	#384,d0
	Blt.s	.Noset
.Set	St	6(a5)
.Noset	Add.w	(a5)+,d0
	Add.w	(a5)+,d1			; x/y modifier
	Move.w	Screenxoffset(a4),(a5)		; Save it!
	Sub.w	#32,(a5)
	Tst.b	2(a5)
	Bne.s	.Nsy
	Cmp.w	#-16,d0
	Bge.s	.Psx
	St	d5			; Flag bounced
	Neg.w	-4(a5)
	Add.w	-4(a5),d0
.Psx	Cmp.w	#384,d0
	Blt.s	.Nsx
	St	d5			; Flag bounced
	Neg.w	-4(a5)
	Add.w	-4(a5),d0
.Nsx	Cmp.w	#-16,d1
	Bge.s	.Psy
	St	d5			; Flag bounced
	Neg.w	-2(a5)
	Add.w	-2(a5),d1
.Psy	Cmp.w	#240,d1
	Blt.s	.Nsy
	St	d5			; Flag bounced
	Neg.w	-2(a5)
	Add.w	-2(a5),d1
.Nsy	Add.w	(a5),d0
	Tst.b	d5
	Beq.s	.Not_Bounced
	Subq.w	#1,4(a5)
	Bne.s	.Not_Bounced
	Clr.w	Aln_Seqdec(a0)
	Move.l	#Fuck_Seq,Aln_Seqp(a0)
.Not_Bounced
	Rts	

Attack_Wave9
	Movem.w	(a5)+,d2-d5
	Add.w	d4,d2
	Bcc.s	.AAA
	Add.w	(a5),d0
.AAA	Add.w	d5,d3
	Bcc.s	.BBB
	Add.w	2(a5),d1
.BBB	Movem.w	d2-d3,-8(a5)
	Addq.l	#4,a5
	Subq.w	#1,(a5)+
	Bgt.s	.KKK
	Clr.l	-6(a5)
.KKK	Moveq	#0,d3
	Move.b	(a5)+,d3
	Add.b	(a5)+,d3
	Move.w	d3,-(sp)		; Save sine value on stack
	Move.b	d3,-2(a5)
	Lea	Alien_Sine(pc),a3
	Move.w	(a3,d3*2),d4
	Add.b	#$40,d3
	Move.w	(a3,d3*2),d3
	Muls	(a5),d3		
	Muls	(a5)+,d4		
	Add.l	d3,d3
	Add.l	d4,d4
	Swap	d3
	Swap	d4
	Sub.w	(a5),d0
	Sub.w	2(a5),d1
	Movem.w	d3-d4,(a5)
	Move.w	(sp)+,d5		; Retrieve Sine value
	Cmp.w	#1,Aln_Seqdec(a0)
	Bne.s	.No_Sine_Drop
	Move.w	#2,Aln_Seqdec(a0)
	Cmp.w	#$3c,d5
	Blt.s	.No_Sine_Drop
	Cmp.w	#$42,d5
	Bgt.s	.No_Sine_Drop
	Clr.w	Aln_Seqdec(a0)
.No_Sine_Drop
	Add.w	d3,d0
	Add.w	d4,d1
	Rts

Attack_Wave11
	Move.l	Player_Use(a4),a5
	Move.w	Shipxy(a5),d2
	Btst	#0,d2
	Beq.s	.Ship_Even
	Or.w	#1,d0
	Bra.s	.Skip_Even_Odd_Text	
.Ship_Even
	And.w	#$fffe,d0
.Skip_Even_Odd_Text	
	Add.w	AscreenXOffset(a4),d2
	Add.w	#16,d2
	Cmp.w	d0,d2
	Beq.s	.No_Add
	Bge.s	.Add
	Subq.w	#4,d0
.Add	Addq.w	#2,d0
.No_Add	Addq.w	#5,d1
	Rts

Attack_Wave12	
	Rts

Attack_Wave13
	Move.w	#$7fff,Aln_Seqdec(a0)	; Dont get out of this wave pattern
	Cmp.w	#-32,d0
	Ble.s	.Alien_Off_Screen	; Make sure the sprite is still on the playfield
	Cmp.w	#-32,d1
	Ble.s	.Alien_Off_Screen
	Cmp.w	#Byteswide,d0
	Bge.s	.Alien_Off_Screen
	Cmp.w	#240,d1
	Bge.s	.Alien_Off_Screen
	Move.l	Player_Use(a4),a3
	Movem.w	Shipxy(a3),d2-d3	; Get player coardinates
	Add.w	ScreenxOffset(a4),d2	; Add Playfield offset
	Add.w	#16,d2	
	Add.w	#16,d3			; Middle of players ship
	Movem.w	Aln_X(a0),d0-d1		; Collect Aliens coardinates
	Clr.w	d5			; Clear octant table index 
	Sub.w	d0,d2
	Addx.w	d5,d5			; Xtend set if player is to left
	Sub.w	d1,d3
	Addx.w	d5,d5			; Xtend Set if player is to up
	Tst.w	d2
	Bpl.s	.XPos
	Neg.w	d2			; Absolute of XDELTA
.XPos	Tst.w	d3
	Bpl.s	.YPos
	Neg.w	d3			; Absolute of YDELTA
.YPos	Cmp.w	d2,d3			; Compare deltas x,y
	Addx.w	d5,d5			; Xtend set if deltay<Deltax
	Move.b	.Octant_Table(pc,d5),d5 ; Angle to go to
	Clr.w	2(a5)			; Clear angle add
	Tst.b	Flip_Flag(a4)
	Beq.s	.None			; Only do this 1 every 2 game loops	
	Cmp.w	#6,4(a5)
	Beq.s	.None
	Addq.w	#1,4(a5)		; 1 to scale along angle
.None	Move.w	(a5),d6			; Current angle
	Move.w	d5,d7			; Save angle to go to
	Add.b	#$80,d7			; Add half a circle
	Sub.b	d6,d5			; Get difference (anti)
	Sub.b	d6,d7			; And clockwise
	Cmp.b	d5,d7			; Which difference is greater
	Bcc.s	.Clockwise_Is_Greater	; If clockwise is greater=
	Addq.w	#4,(a5)			; Spin it clockwise
.Clockwise_Is_Greater
	Subq.w	#2,(a5)			; Spin it anticlockwise
	Bra	Attack_Wave6		; Do a standard vector move
.Alien_Off_Screen
	Clr.w	Aln_Seqdec(a0)		; Else Execute the next command
	Rts

.Octant_Table
	Dc.b	$f0,$d0,$90,$b0
	Dc.b	$10,$30,$70,$50


Comm_Table
	Bra	.Comm0			; Abs Move
	Bra	.Comm1			; Sine Lr
	Bra	.Comm2			; Sine Ud
	Bra	.Comm3			; X Swoop
	Bra	.Comm4			; Y Swoop
	Bra	.Comm5			; Repeat
	Bra	.Comm6			; Repend
	Bra	.Comm7			; Gosub
	Bra	.Comm8			; Return
	Bra	.Comm9			; Branch
	Bra	.Comm10			; Fireship
	Bra	.Comm11			; End Sequence
	Bra	.Comm12			; Multi-Sine
	Bra	.Comm13			; Vector move
	Bra	.Comm14			; Track To player Ship
	Bra	.Comm15			; Bounce move!
	Bra	.Comm16			; Center move
	Bra	.Comm17			; No-operaration
	Bra	.Comm18			; Release power-ups
	Bra	.Comm19			; Zoom intto!
	Bra	.Comm20			; Start scrolling
	Bra	.Comm21			; Stop scrolling
	Bra	.Comm22			; Spit Out
	Bra	.Comm23			; Spit-out-Home
	Bra	.Comm24			; START mid2 split
	Bra	.Comm25			; Change power up ship anim
	Bra	.Comm26			; Tween between 2 vector moves
	Bra	.Comm27			; Plane home into !
	Bra	.Comm28			; Accelerate towards ship
	Bra	.Comm29			; Stop anim
	Bra	.Comm30			; One shot anim
	Bra	.Comm31			; Start anim
	Bra	.Comm32			; Only if moving !
	Bra	.Comm33			; hovercraft add up
	Bra	.Comm34			; hovercraft add down
	Bra	.Comm35			; Guardian2 reached center
	Bra	.Comm36			; Pause
	Bra	.Comm37			; Unpause
	Bra	.Comm38			; Do nothing !
	Bra	.Comm39			; Change anim
	
		
.Comm36	St	Aln_Pauseflag(a0)
	Rts
.Comm37	Sf	Aln_Pauseflag(a0)
	Rts
	
.Comm38	Move.w	#12,(a1)
	Move.w	(a2)+,Aln_Seqdec(a0)
	Rts			

.Comm35	Cmp.w	#250,Aln_Dmg(a0)
	Bgt.s	.Nothp100
	Move.l	Aln_Link(a0),a1
	Move.l	#Do_Nothing_Seq,Aln_Seqp(a1)
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	Aln_Link(a1),a1
	Move.l	#Center_Lev2seq,Aln_Seqp(a1)
	Lea	Mad_Guardian2Seq,a2
.Nothp100
	Rts

.Comm33	Lea	Temptravel_Add(a4),a6
	Subq.w	#1,2(a6)
	Cmp.w	#2,2(a6)
	Bne.s	.Not_Top
	Addq.l	#2,a2
.Not_Top
	Subq.l	#2,a2
	Rts	

.Comm34	Lea	Temptravel_Add(a4),a6
	Addq.w	#1,2(a6)
	Cmp.w	#14,2(a6)
	Bne.s	.Not_Bot
	Addq.l	#2,a2
.Not_Bot
	Subq.l	#2,a2
	Rts	
	
.Comm29	St	Aln_Animcont(a0)
	Rts
.Comm30	St	Aln_Animcont(a0)
	Sf	Aln_Animflag(a0)
	Rts
.Comm31	Sf	Aln_Animcont(a0)
	Sf	Aln_Animflag(a0)
	Rts

.Comm32	Move.l	a0,a3
.Search_Prev_Link
	Tst.l	Aln_Prevlink(a3)
	Bmi.s	.Found_Prevlink
	Move.l	Aln_Prevlink(a3),a3
	Bra.s	.Search_Prev_Link
.Found_Prevlink
	Cmp.l	#1,Aln_Shite(a3)
	Bne.s	.comm31
	Bra.s	.Comm29
			
.Comm0	Move.w	#0,(a1)+		; Abs Move
	Addq.l	#4,a1			; Get into alien shite
	Move.w	(a2)+,(a1)+		; X vector
	Move.w	(a2)+,(a1)+		; Y vector
	Move.w	(a2)+,Aln_Seqdec(a0)	; Decrement time
	Rts

.Comm1	Move.w	#1,(a1)+		; Left right sine
	Sf	d5			; Clear flag for half-circle
.Comm1b	Addq.l	#4,a1			; Skip x/y Coardinates
	Lea	Alien_Sine(pc),a3	; Sine table pointer
	Move.w	(a2)+,d4		; Get Sine value
	Move.w	d4,(a1)+		; Sine val -Saved
	Move.w	(a2)+,(a1)+		; Sine speed
	Move.w	(a2)+,(a1)+		; Scale factor
	Tst.b	d5			; Half circle flag ?
	Beq.s	.No_Shift
	Lsr.w	#1,d4			; /2 the angle (uses only half a sine table)
.No_Shift
	Move.w	(a3,d4*2),d4		; Previous sine value !
	Muls	-2(a1),d4		; Multilplied by scale
	Add.l	d4,d4
	Swap	d4
	Move.w	d4,(a1)+		; Divide by 32768, and save previous sine value
	Move.l	(a2)+,(a1)+		; x/y Add
	Move.w	(a2)+,Aln_Seqdec(a0)	; Decrement time
	Rts
	
.Comm2	Move.w	#2,(a1)+		; Up down sine
	Sf	d5			; Flag for full sine
	Bra.s	.Comm1b			; Same process for LR sine

.Comm3	Move.w	#3,(a1)+		; XSWOOP
	St	d5			; Half circle
	Bra.s	.Comm1b

.Comm4	Move.w	#4,(a1)+		; YSWOOP
	St	d5			; Half circle
	Bra.s	.Comm1b

.Comm5	Move.w	(a2)+,Aln_Repeat(a0)
	Move.l	a2,Aln_Replocate(a0)	; Repeat location starts at next macro
	Rts

.Comm6	Subq.w	#1,Aln_Repeat(a0)	; 1 from repeat !
	Beq.s	.Comm6E
	Move.l	Aln_Replocate(a0),a2	; Set repeat location
.Comm6E	Rts

.Comm7	Move.l	(a2)+,d0		; Goto !
	Move.l	a2,Aln_Stack(a0)	; Save return address
	Move.l	d0,a2			; Set new program counter
	Rts

.Comm8	Move.l	Aln_Stack(a0),a2	; Get return address off "STACK"!
	Rts

.Comm9 	Move.l	(a2),a2			; Set branch pointer
	Rts

.Comm10 
	Move.l	Aliens_Insert_P(a4),a3
	Move.w	(a2)+,(a3)+		; Weapon number !
	Move.l	Player_Use(a4),(a3)+
	Move.l	a0,(a3)+ 		; Start of this X/Y and shit !
	Move.l	a3,Aliens_Insert_P(a4)	; Restore pointer !
	Rts

.Comm11	Cmp.w	#Planedn_Anm_Set,Aln_Anmset(a0)
	Beq.s	.Plane_Up
	Move.l	a0,a1
	Subq.w	#1,Sprites_To_Draw(a4)
	Move.w	Sprites_To_Draw(a4),-(sp)
	Bsr	Kill_Link
	Move.w	(sp)+,Sprites_To_Draw(a4)
	Rts

.Plane_Up
	Move.w	#Planeup_Anm_set,Aln_Anmset(a0)
	Lea	Up_Plane_Seq(pc),A2
	Lea	Planeup_Link(pc),a3
	Move.l	(a3)+,Aln_LinkOffsets(a0)
	Move.l	Aln_Link(a0),a3
	Move.w	#12,Aln_Anmset(a3)
	Move.l	Aln_Link(a3),a3
	Move.w	#12,Aln_Anmset(a3)
	Rts

.Comm12	Move.w	#5,(a1)+
	Addq.l	#4,a1			Skip x/y
	Move.l	(a2)+,(a1)+
	Move.l	(a2)+,(a1)+
	Move.l	(a2)+,(a1)+
	Clr.l	(a1)+
	Move.l	(a2)+,(a1)+
	Move.w	(a2)+,Aln_Seqdec(a0)
	Rts

.Comm13	Move.w	#6,(a1)+		Attack Wave 7
	Addq.l	#4,a1
	Cmp.w	#$7fff,(a2)
	Bne.s	.Skip_Ang
	Cmp.w	(a2)+,(a1)+
	Move.w	(a2)+,(a1)+
	Bra.s	.Skip_Ang2
.Skip_Ang
	Move.l	(a2)+,(a1)+
.Skip_Ang2
	Move.w	(a2)+,(a1)+
	Clr.w	(a1)+
	Clr.w	(a1)+
	Move.w	(a2)+,Aln_Seqdec(a0)
	Rts

.Comm14	Move.w	#7,(a1)+		Attack wave 8 
	Move.w	(a2)+,Aln_Seqdec(a0)	Set delay for track !
	Rts

.Comm15	Move.w	#8,(a1)+		Attack wave 9
	Addq.l	#4,a1
	Move.l	(a2)+,(a1)+		Set vectors !
	Clr.w	(a1)+			Clear X offset !
	Move.w	#$6fff,Aln_Seqdec(a0)	Abs. Delay
	Rts

.Comm16	Move.w	#9,(a1)+		Attack wave 10
	Moveq	#0,d0
	Moveq	#0,d1
	Move.w	(a1)+,d0
	Move.w	(a1)+,d1		Get X/Y
	Clr.l	(a1)+			Fractions for X/Y!
	Sub.w	#Byteswide/2,d0
	Smi	d6			Set if negative
	Bpl.s	.Uk0
	Neg.w	d0
.Uk0	Sub.w	#120,d1			Get x/y vectors
	Smi	d7
	Bpl.s	.Uk2
	Neg.w	d1
.Uk2	Cmp.w	d0,d1
	Slt	d2			Set if d1 is Less than!
	Bge.s	.UK1
	Exg	d0,d1
.Uk1	Movem.w	(a0)+,d0-d3		x/y/xv/yv Fractions
	Add.w	d2,d0
	Add.w	d3,d1
.Comm17	Rts

.Comm18	Eor.l	#$ff,Pal256
	Bra.s	.Comm18

.Comm19	Move.w	#10,(a1)+			Attack wave 11
	Addq.l	#4,a1
	Move.w	(a2)+,d5			Vector scale!
	Move.w	(a2)+,Aln_Seqdec(a0)		Delay !
	Move.w	14+28(a0),d3			Angle in
	Pea	(a0)
	Lea	VectorTab(pc),a0
	Movem.w	(a0,d3*4),d3-d4
	Move.l	(sp)+,a0
	Asr.w	#1,d3
	Asr.w	#1,d4
	Muls	d5,d3
	Muls	d5,d4
	Movem.w	d3-d4,(a1)
	Rts
 
.Comm20	Sf	No_More_Scrolling(a4)
	Rts
 
.Comm21	St	No_More_Scrolling(a4)
	Rts

.Comm22	Move.l	Aln_X(a0),Flag_To_Spit_Out(a4)
	Rts

.Comm23	Move.w	#100,Aln_Seqdec(a0)
	Move.w	#Zoomer_Anm_Set,Aln_Anmset(a0)
	Clr.w	Aln_Anim(a0)
	Move.w	#11,(a1)+
	Rts

.Comm24	Tst.w	Mid2_Dec(a4)
	Bne.s	.No_Init
	Move.w	#10,Mid2_Dec(a4)
.No_Init
	Subq.l	#2,a2
	Move.w	#1,Aln_Seqdec(a4)	
	Subq.w	#1,Temp_Mid2_Add+00(a4)
	Subq.w	#1,Temp_Mid2_Add+08(a4)
	Addq.w	#1,Temp_Mid2_Add+04(a4)
	Addq.w	#1,Temp_Mid2_Add+12(a4)
	Tst.b	Flip_Flag(a4)
	Beq.s	.Noy_Modis
	Addq.w	#1,Temp_Mid2_Add+18(a4)
	Addq.w	#1,Temp_Mid2_Add+22(a4)
	Subq.w	#1,Temp_Mid2_Add+26(a4)
	Subq.w	#1,Temp_Mid2_Add+30(a4)
.Noy_Modis
	Subq.w	#1,Mid2_Dec(a4)
	Bne.s	.No_Exit_Mid2
	Addq.l	#2,a2
.No_Exit_Mid2
	Rts

.Comm25	Subq.l	#2,a2
	Tst.b	Flip_Flag(a4)
	Beq.s	.No_Flip_PUP_Ship
	Movem.l	a0,-(sp)
	Move.l	Aln_Link(a0),a0
	Move.l	Aln_Link(a0),a0
	Move.l	Aln_Link(a0),a0
	Move.l	Aln_Link(a0),a0
	Moveq	#3,d7
.Loop_Do_Anim
	Subq.w	#1,d7
	Beq.s	.Restore_Regs
	Cmp.w	#23,Aln_Anmset(a0)
	Beq.s	.Tween
	Move.w	#13,Aln_Anmset(a0)
	Move.l	Aln_Link(a0),a0
	Bra.s	.Loop_Do_Anim
.Tween	Move.w	#24,Aln_Anmset(a0)
	Move.l	Aln_Link(a0),a0
	Bra.s	.Loop_Do_Anim
.Restore_Regs
	Move.l	Aln_Prevlink(a0),a0
	Cmp.w	#13,Aln_Anmset(a0)
	Bne.s	.No_Next_Command
	Move.l	Aln_Link(a0),a3
	St	Aln_Link(a0)
	Move.l	Aln_Link(a3),a0
	Clr.w	Aln_Dmg(a3)
	Clr.l	Aln_Link(a3)
	Clr.w	Aln_Dmg(a0)
	Clr.l	Aln_Link(a0)
	Addq.l	#2,a2
.No_Next_Command
	Move.l	(sp)+,a0
.No_Flip_PUP_Ship
	Rts	

.Comm26	Addq.l	#2,a2
	Addq.l	#6,a1			; Pointer to sprite move data area
	Move.w	(a1),d3			; Current Angle
	Move.w	d3,d4			; Save current angle
	Add.b	#$80,d4			; Half a circle
	Sub.w	2(a2),d3		; Get anticlockwise difference
	Bpl.s	.Posok1
	Neg.w	d3
.PosOk1	Sub.w	2(a2),d4		; Get clockwise difference
	Bpl.s	.Posok2
	Neg.w	d4
.Posok2
	Moveq	#-2,d2			; Set to anti clockwise
	Cmp.w	d3,d4
	Bge.s	.AntiClock		; Its anticlockwise anyway!
	Move.w	d4,d3
	Moveq	#2,d2			
.AntiClock
	Subq.l	#6,a1			; Back to attack wave pointer number
	Move.w	#6,(a1)+		; Attack Wave 7	(Move along a vector)
	Addq.l	#4,a1			; Points to sprite data move area
	Addq.l	#2,a1			; Skip current sine value !
	Move.w	d2,(a1)+		; Set direction !
	Clr.w	(a1)+			; Sine Scale
	Clr.w	(a1)+			; Clear out remainder
	Clr.w	(a1)+
	Lsr.w	#1,d3
	Move.w	d3,Aln_Seqdec(a0)	; Set decrement for sine
	Rts

.Comm27	Move.l	Player_Use(a4),a3
	Move.w	Aln_X(a0),d0		; Get aliens X coardinate
	Move.w	Shipxy(a3),d1		; Get Players X coardinate
	Add.w	ScreenXOffset(a4),d1	; Add Base of playfield
	Move.w	d0,d2			; Save playerrs X coardinate
	Sub.w	#15,d0
	Add.w	#15,d2
	Move.w	#0,(a1)+		; Abs move
	Addq.l	#4,a1			; Skip x/y
	Moveq	#0,d4			; Set X vector to 0
	Moveq	#3,d5
	Cmp.w	d0,d1
	Blt.s	.Ship_Is_To_The_Left	; If ships X is less than plane X
	Cmp.w	d2,d1
	Ble.s	.Straight_Down
.Ship_Is_To_The_Right
	Addq.w	#4,d4			; Add 4 (Not subtracting 2, therefore move x +2)		
.Ship_Is_To_The_Left
	Subq.w	#2,d4			; Move x -2
.Straight_Down
	Movem.w	d4-d5,(a1)		; Set x/y Interger adds
	Move.w	#70,Aln_Seqdec(a0)	; Set decrement to fixed value (should go off screen)
	Rts
	
.Comm28
	Move.w	#13,(a1)+
	Addq.l	#4,a1
	Clr.w	12(a1)
	Move.w	#$7fff,Aln_Seqdec(a0)
	Rts

.Comm39	Clr.w	Aln_Anim(a0)
	Move.w	(a2)+,Aln_Anmset(a0)
	Rts

**********************************************************
Sort_Aliens
	Lea	Alien_Sort_Table(a4),a0
	Move.w	#(Alien_Sort_Tablee-Alien_Sort_Table)/4-1,d0
	Moveq	#-1,d7
.Loop0	Move.l	d7,(a0)+
	Dbra	d0,.Loop0

	Lea	Alien_Sort_Table(a4),a1
	Lea	Alien_Table(a4),a0
	Lea	Enemy_Prioritys,a6
	Moveq	#Aln_End,d1				; Give me the fast modulo
	Move.w	Sprites_to_Draw+Data(pc),d7	; Number to draw on stack
	Subq.w	#1,d7
	Blt.s	.Exit				; None to draw, exit !

.Loop	Tst.w	(a0)
	Bgt.s	.Ok				; Test hit points
	Add.l	d1,a0				; None, add modulo, find another!
	Bra.s	.Loop
	
.Ok	Move.w	Aln_Sprite(a0),d0
	Move.b	(a6,d0),d0			; Get its priority
	And.w	#$ff,d0
	Mulu	#Max_Aliens/2,d0
	Lea	(a1,d0*4),a2
.Find	Tst.l	(a2)+
	Bpl.s	.Find
	Move.l	a0,-(a2)
	Add.l	d1,a0
	Dbra	d7,.Loop
	Lea	Alien_Sort_Table(a4),a0
	Move.l	a0,a1
	Move.w	#(Alien_Sort_Tablee-Alien_Sort_Table)/4-1,d0
.Concate
	Tst.l	(a0)+
	Bmi.s	.Noinc
	Move.l	-4(a0),(a1)+
.Noinc	Dbra	d0,.Concate
.Exit	Rts

**********************************************************
Save_Alien_Sprites
	Move.w	Sprites_To_Draw(a4),d7
	Ble.s	.Exit				; None to draw !
	Lea	Alien_Save_Table(pc),a3		; Flags for alien saves
	Lea	Alien_Sort_Table(a4),a6		; Start of list of sprites
	Move.l	Enemy_Sprites_Base(a4),a2
	Subq.w	#1,d7	
.Loop	Move.l	(a6)+,a0			; Get sprite structure address
	Move.w	Aln_Sprite(a0),d0		; Get alien sprite number
	Tst.b	(a3,d0)				; Test if it needs saving
	Beq.s	.Dec				; 0, no !
	Add.w	d0,d0
	Move.w	Spr_Width(a2,d0*8),d2
	Move.w	Spr_Height(a2,d0*8),d3
	Move.w	Spr_Yadd(a2,d0*8),d1
	Move.w	Aln_X(a0),d0
	Add.w	Aln_Y(a0),d1
	Bsr	Save_A_Sprite_In_List
.Dec	Dbra	d7,.Loop
.Exit	Rts
	
**********************************************************
Setup_Blitter
	Lea	Blitterstuff,a6
	Move.w	#10,Src_Xinc(a6)
	Move.w	#16,Dst_Xinc(a6)
	Rts

**********************************************************
Draw_Aliens
	Move.w	Sprites_To_Draw(a4),-(sp)
	Beq	.Exit
	Bsr	Setup_Blitter
	Lea	Alien_Sort_Table(a4),a1
.Loop	Move.l	(a1)+,a0
	Move.w	Aln_Sprite(a0),d2
	Blt.s	.Dec
	Movem.w	Aln_X(a0),d0-d1
	Move.l	Enemy_Sprites_Base(a4),a3
	Move.l	RealScreenp(a4),a5
	Bsr	Blit_A_Sprite
.Dec	Subq.w	#1,(sp)
	Bne.s	.Loop
.Exit	Addq.l	#2,sp
	Rts

**********************************************************
Draw_Weapons
	Bsr	Setup_Blitter
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
.Do	Lea	Shots_To_Do(a3),a0
	Move.w	#Max_Weapons,-(sp)

; d0 - x
; d1 - y
; d2 - Sprite number

; a3 - Sprite table
; a4 - Data region
; a5 - Base address of screen
; a6 - Blitter registers

.Loop	Tst.b	(a0)
	Ble.s	.Dec
	Move.w	Wep_X(a0),d0	
	Move.w	Wep_Y(a0),d1	
	Moveq	#0,d2
	Move.b	Wep_Sprite_Num(a0),d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	RealScreenp(a4),a5
	Bsr	Blit_A_Sprite
.Dec	Lea	Wep_End(a0),a0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts
	
**********************************************************
Move_Weapons
	Pea	Home_Dir(a4)
	Move.l	(sp)+,Home_Dirp(a4)

	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
.Do	Lea	Shots_To_Do(a3),a0
	Sf	Homes_On_Screen_Flag(a4)
	Lea	Wep_Anims,a2
	Lea	Alien_Sine(pc),a5
	Moveq	#Max_Weapons-1,d7
.Loop	Tst.b	Wep_Dmg(a0)		; Test damage
	Ble	.Dec			; If 0, then exit !
	Movem.w	Clearr(a4),d0-d1/d6
	
	Lea	Wep_Anim(a0),a3
	Move.b	Wep_sprite(a0),d0	; Weapon number.
	Cmp.b	#17,d0			; Homing missle ?
	Bcs.s	.Not_Homing		; No!
	Cmp.b	#22,d0
	Bcc.s	.Not_Homing		; No
	
	St	Homes_On_Screen_Flag(a4)
	Move.l	Home_Dirp(a4),a6	; Pointer into table!
	Move.l	a0,(a6)+
	Move.l	a6,Home_Dirp(a4)	; save pointer !
	Movem.w	Wep_X(a0),d0/d2-d3/d5	; Collect x/y Sine val/Scale!
	Move.w	(a5,d3*2),d4		; X vector
	Add.b	#$40,d3
	Move.w	(a5,d3*2),d3		; y Vector
	Muls	d5,d4
	Neg.w	d5
	Muls	d5,d3
	Swap	d4
	Swap	d3			; To adder !
	Add.w	d4,d0
	Add.w	d3,d2			; Add em up
	Move.b	Wep_Sprite(a0),d6	; Sprite number
	Move.l	(a2,d6*4),a6		; Pointer to sprite anims !
	Move.w	Wep_Xv(a0),d6
	Lsr.b	#4,d6			; 0-15!
	Add.b	1(a6),d6		; Add to Base anim!
	Bra.s	.Not_Sidewinder		; Skip the shit !

.Not_Homing	
	Move.l	(a2,d0*4),a6		; Pointer into table
	Move.b	(a3)+,d1		; Current anim
	Move.b	(a3)+,d2		; Anim delay!
	Addq.b	#1,d2			; 1 to anim delay
	Cmp.b	(a6)+,d2		; compare max delay !
	Bne.s	.Nx			; Not equal, no add to anim
	Moveq	#0,d2
	Addq.b	#1,d1			; Add 1 to current anim
	Tst.b	(a6,d1)
	Bpl.s	.Nx
	Moveq	#0,d1			; Last in list was -ive, Clear anu
.Nx	Move.b	d2,-(a3)		; Save anim data !
	Move.b	d1,-(a3)
	Move.b	(a6,d1),Wep_Sprite_Num(a0)
	Movem.w	Wep_X(a0),d0/d2-d4	; Collect x/y/xv/yv
	Add.w	d3,d0
	Add.w	d4,d2			; Add em up

	Cmp.w	#-32,d0			; Check Left X boundry
	Ble.s	.Dim_Weapon
	Cmp.w	#-32,d2			; Check Y boundry
	Ble.s	.Dim_Weapon
	Cmp.w	#Byteswide,d0		; Check Right X boundry
	Bge.s	.Dim_Weapon
	Move.b	Wep_Sprite_Num(a0),d6
	Cmp.b	#17,d6
	Beq.s	.SideWinder
	Cmp.b	#18,d6
	Beq.s	.SideWinder
	Cmp.b	#78,d6
	Beq.s	.SideWinder
	Cmp.b	#79,d6
	Beq.s	.SideWinder
	Cmp.b	#80,d6
	Beq.s	.SideWinder
	Cmp.b	#81,d6
	Beq.s	.SideWinder
	Bra.s	.Not_Sidewinder
.Sidewinder	
	Bsr.s	.Dosine			; If sidewinder, then process!
.Not_Sidewinder	
	Movem.w	d0/d2,Wep_X(a0)		; Save X/Y!
.Dec	Lea	Wep_End(a0),a0
	Dbra	d7,.Loop
	Move.l	Home_Dirp(a4),a6
	St	(a6)
	Tst.b	Homes_On_Screen_Flag(a4)
	Sne	d0
	And.b	d0,Num_Homes(a4)
	Rts

.Dim_Weapon
	Clr.b	(a0)			; No slot n table !
	Bra.s	.Dec

.Dosine	
	Moveq	#0,d3
	Moveq	#0,d5
	Move.b	Wep_Sine_Val(a0),d3
	Move.b	Wep_Sine_Scale(a0),d5
	Add.b	Wep_Sine_Speed(a0),d3
	Scs	d4
	Or.b	d4,d3
	Move.b	d3,Wep_Sine_Val(a0)
	Lsr.w	#2,d3
	Mulu	(a5,d3*2),d5
	Add.l	d5,d5
	Swap	d5
	Sub.w	d5,d2
	Rts

**********************************************************
Save_Weapon_Sprites
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Lea	Shots_To_Do(a3),a0
	Move.l	Player_Sprite_Base(a4),a2
	Move.w	#Max_Weapons,-(sp)
.Loop	Tst.b	(a0)
	Ble.s	.Exit			; If damage = -1 then end !
	Move.w	Wep_X(a0),d0
	Move.w	Wep_y(a0),d1
	Moveq	#0,d2
	Move.b	Wep_Sprite_Num(a0),d2
	Add.w	d2,d2
	Move.w	Spr_Height(a2,d2*8),d3
	Move.w	Spr_Width(a2,d2*8),d2
	Bsr	Save_A_Sprite_In_List
.Exit	Lea	Wep_End(a0),a0
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts
 
**********************************************************
;d0 - x
;d1 - y
;d2 - Width
;d3 - Height

Save_A_Sprite_In_List
	Move.l	BgSaveP(a4),a1
	Cmp.w	Sprite_Clip_Maxx(a4),d0
	Bge.s	.No_Save
	Move.w	d0,d4
	Add.w	d2,d4
	Cmp.w	Sprite_Clip_Minx(a4),d4
	Ble.s	.No_Save
	Tst.w	d3
	Ble.s	.No_Save
	Move.w	d2,(a1)+
	Move.w	d3,(a1)+
	Move.w	d0,(a1)+
	Move.w	d1,(a1)+
	Move.l	a1,BgSaveP(a4)
.No_Save
	St	(a1)
	Rts

**********************************************************
Restore_Sprites
	MOVE.L	BGBufferp(a4),a0	; Background list to save
	Move.l	a0,BgSaveP(a4)		; Updated pointer to buffer saved 
	Lea	Blitterstuff,a5
	Move.l	#-1,Endmask1(a5)
	Move.w	#-1,Endmask3(a5)
	Move.b	#00,Skew(a5)
	Move.w	#2,Src_Xinc(a5)
	Move.w	#2,Src_Yinc(a5)
	Move.w	#2,Dst_Xinc(a5)

.Loop	Tst.w	(a0)
	Ble	.Stop_Restoring		; Width 
	Movem.w	(a0)+,d0-d3		; Width / Height / X / Y
	Move.w	d1,d4			; Save height
	Add.w	Offset_For_Saves(a4),d3	; Add offset to y coardinate
	Bge.s	.Y_Not_Off_Top		; Test if sprite is off top of screen
	Add.w	d3,d4			; Add Y to height
	Ble.s	.Loop			; No restore if above top screen limit
	Moveq	#0,d3			; Clear Y
	Bra.s	.Print_Blocks
.Y_Not_Off_Top
	Cmp.w	#Height,d3
	Bge.s	.Loop			; If sprite is below screen bounds, No restore
	Move.w	d1,d5
	Add.w	d3,d5			; Add Y to Sprite height
	Sub.w	#Height,d5		; Difference from bottom of screen
	Ble.s	.Print_Blocks
	Sub.w	d5,d4			; Subtract difference from height
.Print_Blocks
	Move.w	d3,d7			; Save Y
	Mulu	#Byteswide,d3
	Move.l	Realscreenp(a4),a2
	Add.l	d3,a2
	And.w	#$fff0,d2
	Lea	(a2,d2),a2
	
	Lsr.w	#4,d2			; X divided by 16
	Move.l	Mapdatap(a4),a1		; Screen mappointer
	Lea	(a1,d2*2),a1		; Base X block
	Lsr.w	#4,d0			; Width /16
	Move.w	d0,d2
	Move.w	Mapcount(a4),d6
;	Sub.w	Offset_For_Saves(a4),d6	; Add offset to y coardinate
	Bge.s	.No_16
	And.w	#$f,d6
	Lea	60(a1),a1
.No_16	Eor.w	#$f,d6			; Get offset into blockset
	Add.w	d6,d7			; Add map offset
	Move.w	d7,d6
	Lsr.w	#4,d6
	Mulu	#60,d6
	Lea	-60(a1,d6),a1
	And.w	#$f,d7
	Moveq	#16,d6
	Sub.w	d7,d6			; Get height for this line
;&*&*&
	Sub.w	d6,d4			; Subtract from total height
	Bgt.s	.No_Diff_Height_Line	; Positive line
	Add.w	d4,d6
	Bsr	Print_Line_Of_Blocks	
	Bra	.Loop
.No_Diff_Height_Line
	Bsr	Print_Line_Of_Blocks	
.Full_Line_Loop
	Moveq	#0,d7
	Moveq	#16,d6
	Sub.w	d6,d4
	Bgt.s	.Ok_Print_Full_Height
	Add.w	d4,d6
	Ble	.Loop
.Ok_Print_Full_Height
	Bsr	Print_Line_Of_Blocks	
	Bra.s	.Full_Line_Loop
.Stop_Restoring
	Rts

;d2 - Length of blocks
;d6 - Height of blocks
;d7 - Offset into blocks
;a1 - Pointer to map data
;a2 - Pointer to screen

Print_Line_Of_Blocks	
	Move.w	d6,d1
	Mulu	#Byteswide,d1
	Pea	(a2,d1.l)
	Pea	60(a1)			; Next line in map
	Move.w	d2,d5
	Move.l	Gfxblocks_Base(a4),a6	; Base of blockset
	Mulu	#14,d7
	Add.l	d7,a6
.Loop	Move.w	(a1)+,d0		; Get block number
	Ror.w	#8,d0			; 8086 -> 68K
	Mulu	#224,d0
	Lea	(a6,d0.l),a3
	Move.b	#3,Op(a5)
	Move.w	#Byteswide-12,Dst_Yinc(a5)
	Move.l	a3,Src_Addr(a5)
	Move.l	a2,Dst_Addr(a5)
	Move.w	#7,X_Count(a5)
	Move.w	d6,Y_Count(a5)
	Move.b	#$c0,Line_Num(a5)
	Lea	14(a2),a2
	Move.b	#0,Op(a5)
	Move.w	#Byteswide,Dst_Yinc(a5)
	Move.l	a2,Src_Addr(a5)
	Move.l	a2,Dst_Addr(a5)
	Move.w	#1,X_Count(a5)
	Move.w	d6,Y_Count(a5)
	Move.b	#$c0,Line_Num(a5)
	Addq.l	#2,a2
	Dbra	d5,.Loop
	Move.l	(sp)+,a1
	Move.l	(sp)+,a2
	Rts

**********************************************************

Copypal	Lea	Destpal(a4),a0		; Source pallete (intermediate pallete)
	Lea	Pal256,a1		; Colour registers
	Lea	32.w,a3			; Fast adder
	Moveq	#31,d0			; For 32 banks of colours
.Loop	Movem.l	(a0)+,d1-d7/a2		; Collect 8 colours
	Movem.l	d1-d7/a2,(a1)		; Into Colour registers
	Add.l	a3,a1			; Quick adder
	Dbra	d0,.Loop		; for 32 banks (32*8=256!)
	Rts
**********************************************************
Fade_Pal
	Tst.b	Fade_Flag(a4)
	Bne.s	.Exit
	Move.w	Intens(a4),d7
	Cmp.w	#256,d7
	Seq	Max_Pallete(a4)
	Sgt	Fade_Flag(a4)
	Bgt.s	.Exit
	Move.b	Fade_Direction(a4),d0
	Ext.w	d0
	Asl.w	#4,d0
	Add.w	d0,Intens(a4)
	Slt	Fade_Flag(a4)	
	Move.w	#256,d0
	Lea	Mypal,a0
	Lea	Destpal(a4),a1
	Bsr	Pallete_Fade
.Exit	Rts
**********************************************************
;d0-num colors,d7-Fade val,a0-Source,a1-Dest

Pallete_Fade
	Move.w	d0,-(sp)
	Moveq	#$8,d6
.Loop	Movem.w	Clearr(a4),d0-d2
	Move.b	(a0)+,d0
	Move.b	(a0)+,d1
	Addq.l	#1,a0
	Move.b	(a0)+,d2
	Mulu	d7,d0	
	Mulu	d7,d1	
	Mulu	d7,d2	
	Lsr.w	d6,d0
	Lsr.w	d6,d1
	Lsr.w	d6,d2
	Move.b	d0,(a1)+
	Move.b	d1,(a1)+
	Clr.b	(a1)+
	Move.b	d2,(a1)+
	Subq.w	#1,(sp)
	Bne.s	.Loop
	Addq.l	#2,sp
	Rts	
	
**********************************************************
BCD_Ascii_Score
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Lea	Score(a3),a0
	Lea	Ascii_Score(a3),a1
	Moveq	#4,d7
	Bra.s	BCD_Ascii
	Nop

**********************************************************
;a0 Source numbers
;a1 Dest numbers
;d7 Number of numbers to convert

BCD_Ascii
	Subq.w	#1,d7
	Move.b	#"0",d4			
	Moveq	#4,d6
.Loop	Move.b	(a0)+,d0		
	Moveq	#$f,d1
	And.w	d0,d1			
	Lsr.b	d6,d0
	Add.b	d4,d0
	Add.b	d4,d1			
	Move.b	d0,(a1)+
	Move.b	d1,(a1)+
	Dbra	d7,.Loop		; Store & Loop
	Rts
	
**********************************************************
Display_Score
	Bsr	Setup_Blitter
	Moveq	#0,d0
	Lea	Pl1,a3
	Bsr.s	.Do
	Move.w	#200,d0
	Lea	Pl2,a3

.Do	Lea	Ascii_Score(a3),a2
	Add.w	#34,d0
	Move.w	#11,d1
	Add.w	ScreenXOffset(a4),d0
	Moveq	#8-1,d6
.Loop	Moveq	#0,d2
	Move.b	(a2)+,d2
	Sub.b	#"0",d2
	Add.b	#112,d2
 	Move.l	Realscreenp(a4),a5
	Move.l	Player_Sprite_Base(a4),a3
	Movem.l	d0-d1/d6/a2,-(sp)
	Bsr	Blit_A_Sprite
	Movem.l	(sp)+,d0-d1/d6/a2
	Addq.w	#8,d0
	Dbra	d6,.Loop
	Rts

**********************************************************
Display_Bombs_And_Lives
	Bsr	Setup_Blitter
	Lea	Pl1,a3
	Moveq	#0,d0
	Bsr.s	.Do
	Move.w	#200,d0
	Lea	Pl2,a3

.Do	Pea	(a3)
	Move.w	d0,-(sp)
	Add.w	#Txt_X1+37+20,d0
	Add.w	AScreenXOffset(a4),d0
	Move.w	#22,d1
	Moveq	#0,d2
	Move.b	Num_Lives(a3),d2
	Add.b	#112,d2
	Move.l	Realscreenp(a4),a5
	Move.l	Player_Sprite_Base(a4),a3
	Bsr	Blit_A_Sprite
	Move.w	#Txt_X1+124-20,d0
	Add.w	(sp)+,d0
	Add.w	AScreenXOffset(a4),d0
	Move.w	#22,d1
	Moveq	#0,d2
	Move.l	(sp)+,a3
	Move.b	Num_Lives(a3),d2
	Add.b	#112,d2
	Move.l	Player_Sprite_Base(a4),a3
	Move.l	RealScreenp(a4),a5
	Bra	Blit_A_Sprite
	
**********************************************************
Save_Txt
	Moveq	#0,d0
	Lea	Pl1,a3
	Bsr.s	.Do
	Move.w	#200,d0
	Lea	Pl2,a3

.Do	Add.w	#16,d0
	Move.w	#10,d1
	Add.w	ScreenXoffset(a4),d0	; Screen X position !
	Moveq	#96,d2
	Moveq	#Text_Height,d3
	Bra	Save_A_Sprite_In_List

**********************************************************
Scroll_Lr
	Move.w	AScreenXoffset(a4),d0
	Move.l	Player_Use(a4),a3
	Tst.w	XDirection(a3)
	Beq.s	.No_Push_Lr
	Bpl.s	.Pushed_Right
	Subq.w	#2,d0
.Pushed_Right
	Addq.w	#1,d0
	Bge.s	.Screen_X_Gt0
	Moveq	#0,d0
.Screen_X_Gt0
	Cmp.w	#96,d0
	Ble.s	.Screen_X_Lt96
	Move.w	#96,d0	
.Screen_X_Lt96
	Move.w	d0,AScreenXoffset(a4)
	Add.w	#32,d0
	Move.w	d0,ScreenXoffset(a4)	
.No_Push_Lr
	Rts	
 
**********************************************************
Getrealscreenp
	Movem.l	Screenp(a4),a0-a1	; Base addresses of line zero
	Movem.w	LineOffset(a4),d0-d1	; Line offsets for both screens
	Mulu	#Byteswide,d0
	Mulu	#Byteswide,d1		; Multiply by line modulos
	Add.l	d0,a0
	Add.l	d0,a1			; Add to base of both screens
	Movem.l	a0-a1,Realscreenp(a4)	; Store base addresses of both screens
	Rts

**********************************************************
Scroll_Down_Map
	Tst.b	No_More_Scrolling(a4)
	Beq.s	.Scroll
	Rts
.Scroll	Addq.w	#1,MasterMapcount(a4)		; 1 to Y pixel
	And.w	#$f,MasterMapcount(a4)		; Mask it!
	Bne.s	.Exit				; if <>, no event
	Addq.l	#4,Event_Tablep(a4)		; Next event!
	St	Make_Event(a4)			; Proccess event
	Moveq	#60,d5
	Sub.l	d5,MasterMapdatap(a4)		; Next line in map
.Exit	Rts

**********************************************************
Buildmap
	Move.l	Mapdatap(a4),a0		; Pointer for this screens map pointer
	Move.w	Mapcount(a4),d0		; Value for this screens line offset into block
	Eor.w	#15,d0
	Mulu	#14,d0			; Get correct line of block
	Move.l	Gfxblocks_Base(a4),a1
	Add.l	d0,a1			; Add to base of blockset
	Move.l	RealScreenp(a4),a6	; Current screen line address
	Lea	Byteswide(a6),a6	; Advance pointer to end of line
	Move.l	a6,a5
	Add.l	#Byteswide*Height,a5	; Also build a line below visible screen
	Move.w	#14*16,d0		; Amount of bytes reserved for 1 GFX block
	
	Moveq	#8,d6			; Used for fast rotate
	Moveq	#30-1,d7		; Number of blocks to print ((30)*16=480 pixles)
.Loop	Move.w	-(a0),d1		; Get a block
	Ror.w	d6,d1			; Map files are stored in 8086 word form.  Reformat for 68K.
	Mulu	d0,d1			; Get offset into blockset
	Movem.l	(a1,d1.l),d2-d5		; Copy 16 pixels worth
	Clr.w	d5			; No plane 8 data, blocks are only 7 planes
	Movem.l	d2-d5,-(a6)
	Movem.l	d2-d5,-(a5)		; Copy string to each line
	Dbra	d7,.Loop		; For 30 blocks
	Rts

**********************************************************
Swapscreens
	Not.b	Bomb_Flip(a4)
	Not.b	Flip_Flag(a4)

	Movem.w	MapCount(a4),d0-d1
	Exg	d0,d1
	Movem.w	d0-d1,MapCount(a4)
	Movem.w	LineOffset(a4),d0-d1
	Exg	d0,d1
	Movem.w	d0-d1,LineOffset(a4)
	Move.w	Screen_Wrap_Round_Flag(a4),d0
	Ror.w	#8,d0
	Move.w	d0,Screen_Wrap_Round_Flag(a4)
	Swapem	Mapdatap(a4)
	Swapem	BGBufferp(a4)
	Swapem	Screenp(a4)
	Move.l	Realscreenp(a4),d0
	Move.l	d0,Ship_Draw(a4)
	Move.w	AScreenXoffset(a4),d1
	And.l	#$fff0,d1
	Add.l	d1,d0
	Move.l	d0,Display_At_This_Address(a4)
	Moveq	#$f,d2
	And.w	ScreenXoffset(a4),d2
	Move.w	#(Byteswide-384)/2,Scr_Mod_Save(a4)
	Move.w	d2,Scr_Del_Save(a4)
	Beq.s	.Exit
	Move.w	#((Byteswide-384)/2)-8,Scr_Mod_Save(a4)
.Exit	Swapem	RealScreenp(a4)
	Rts
	
***********************************************************
Load_In_Level_Info
	Load_Lev	Pallete_Name,Mypal	; Load in 256 pallete data
	Lea	Mypal,a1			; Pointer to pallete
	Clr.l	(a1)				; BLACK colour zero
	Lea	Player_Pallete,a0		; Pointer to source pallete
	Lea	240*4(a1),a1			; Player pallete
	Moveq	#16*4,d0
	Bsr	Copy_Bytes			; Copy player pallete to top 16 colours

	Ifne	Load_Event			; Assemble if your not sourcing your events
	Load_Lev	Event_Name,Stuff_To_Load ; Load in level data
	Move.l	d0,File_Len(a4)			; Save length of file
	Move.w	(a1),d0				; Get relative branch offset
	And.w	#$ff,d0				; Mask (get offset)
	Lea	6(a1,d0),a2			; Branch instruction+Offset
	Move.l	a2,Event_Base(a4)
	Move.l	a2,Event_Tablep(a4)		; Setup base event and pointer
	Trap	#12				; Relocate file
	Else
	Clr.l	File_Len(a4)			; No file loaded into area
	Move.l	#Event_Table,Event_Base(a4)
	Move.l	#Event_Table,Event_Tablep(a4)	; Setup pointers to sourc
	Endc

	Lea	Stuff_To_Load,a1		; Base pointer to load area
	Add.l	File_Len(a4),a1			; Next bit of load data
	Lea	Map_Name(pc),a0			
	Move.l	a1,Mapdata_Base(a4)		; Setup pointer to mapdata base
	Bsr	Load_Level_File			; Load in file
	Add.l	d0,File_Len(a4)			; Next offset into load area
	Lea	Stuff_To_Load,a0
	Add.l	File_Len(a4),a0			; End of map file
	Subq.l	#2,a0				; Back 2 bytes cause of word aligned read
	Move.l	a0,Mapdataend_Address(a4)	; Save end address of map
	Lea	-60(a0),a1
	Move.l	a1,Mapdatap(a4)			; Setup line pointer
	Move.l	a1,Mapdatap+4(a4)		; Setup line pointer
	Move.l	a1,MasterMapdatap(a4)		; Setup line pointer
	Move.l	a0,Gfxblocks_Base(a4)		; Load in blockset
	Move.l	a0,a1				; Pass parameter
	Lea	Blockset_Name(pc),a0
	Bsr	Load_Level_File			; Load in blockset
	Add.l	d0,File_Len(a4)			; Add offset
	Lea	Stuff_To_Load,a1
	Add.l	File_Len(a4),a1
	Move.l	a1,Enemy_Sprites_Base(a4)	; Base pointer for sprites
	Lea	Sprites_Name(pc),a0
	Bsr	Load_Level_File			; Load in sprite file
	Add.l	d0,File_Len(a4)
	Lea	Stuff_To_Load,a1
	Move.l	File_Len(a4),d0
	Add.l	d0,a1
	Move.l	a1,Mod_Address(a4)
	Lea	Music_Name,a0
	Bsr	Load_Level_File			; Load in sprite file
	Add.l	d0,File_Len(a4)
	Move.l	Enemy_Sprites_Base(a4),a2
	Move.w	(a2)+,Number_Of_Sprites_Loaded(a4)
	Move.l	a2,Enemy_Sprites_Base(a4)
	Cmp.l	#Load_Buff_Size,File_Len(a4)
	Blt.s	Build_Sprites_To_Anims
.Files_too_Big
	Eor.l	#$ffff00ff,Pal256
	Bra.s	.Files_Too_Big
Build_Sprites_To_Anims
	Lea	Anim_Convert_Table,a5	; Table for Sprites>Anims
	Move.l	Event_Base(a4),a0	; Base pointer for events
.Loop	Tst.l	(a0)			; Test event offset
	Beq.s	.Next			; Zero, no event
	Bgt.s	.Event			; >, Event happens !
	Cmp.l	#-1,(a0)		
	Beq.s	.Done			; If -1, end of event list
	Bra.s	.Next			; Else skip event
.Event	Move.l	(a0),a1			; Get address of sprites
.Make_Loop
	Tst.w	(a1)
	Bmi.s	.Next			; Check for end of sprite block
	Move.w	2(a1),d0		; Get sprite number
	Clr.b	2(a1)			; Anims only go from 0-255
	Move.b	(a5,d0),3(a1)		; Anim offset back in
	Lea	12(a1),a1		; Advance to next sprite
	Bra.s	.Make_Loop	
.Next	Addq.l	#4,a0			; Next event
	Bra.s	.Loop
.done	Rts

***********************************************************
Load_Level_File
	Lea	Level_Load_Num(pc),a6
	Move.b	This_Level(a4),d0
	Add.b	#"0",d0
	Move.b	d0,(a6)
	Addq.l	#2,a6
.Cont	Move.b	(a0)+,(a6)+
	Bne.s	.Cont
	Lea	Level_Dir_Name(pc),a0
	Trap	#15
	Rts

***********************************************************
Init	
	Move.w	d0,-(sp)
	Lea	Data,a4
	Bsr	Cleardata		; Clear variables, both data and player
	Bsr	Disable_Ints		; Disable Interrupts
	Ifeq	Makedisk
	IFNE	SYS			; Assemble only if not debugging!
	Bsr	Save_Falcon_Sys
	Bsr	Setup_Screen_Mode	; Setup 8 planes, overscan & screen frequency
	Bsr	Setup_Game_Sys		; Setup Some hardware
	ENDC
	ENDC
	Bsr	Setup_Screens
;	Bsr	Init_Sound		; Connect the Audio DMA
	Bsr	Copypal			; Initial Pallete is 0s, Clear colour registers
	Move.w	(sp)+,d7
	Bsr	Initial_Vars		; Setup the initial variables
	Tst.b	Restart
	Bne.s	.Nostuff		; If pressed restart key, no more absolute info
	Bsr	Abs_Player		; Change relative offsets to absolute for player sprites
.Nostuff
	IFNE	SYS			; Assemble only if not debugging
	Bsr	Init_Joy		; Setup Joystick & Keyboard
	ENDC
	Bsr	Load_In_Level_Info	; Load in the current level data
 	Bsr	Generate_Map		; Build 1 screen of mapdata before starting
	Bsr	Enable_Ints		; Re-enable interrupts
	IFNE	SYS			; Assemble only if not debugging
	Move.l	Mod_address(a4),a0
	Move.l	a0,a1
	Bsr	Pt_Mod_On
	Bsr	Pt_Vol_On
	ENDC
Re_Initialize				; Come back here when new level is to be loaded
	Bsr	Abs_Gfx			; Change relative offsets to absolute for other sprites
	Bsr	Make_Collision_Coard_Adjustments ; Based on Sizes of various sprites, make 2d collision boxes
	Bsr	Change_Height_ForLevel3Guard

	Cmp.b	#Level,This_Level(a4)	; If we are working with the current level
	Bne.s	.Skip	
	Add.l	#Mapoffset*4,Event_Tablep(a4)
	Sub.l	#Mapoffset*60,Mapdatap(a4) ; Add offset into map+Event table (used for testing!!!!)
	Sub.l	#Mapoffset*60,Mapdatap+4(a4) ; Add offset into map+Event table (used for testing!!!!)
	Sub.l	#Mapoffset*60,MasterMapdatap(a4) ; Add offset into map+Event table (used for testing!!!!)
.Skip	Bsr	Setup_Game_Loop_Vars	; Need to setup stuff for main loop
	Rts

**********************************************************
Change_Height_ForLevel3Guard
	Cmp.b	#3,This_Level(a4)
	Bne.s	.No_Height_Shrink_for_Lev3Guard	
	Move.l	Enemy_Sprites_Base(a4),a0
	Lea	Lev3_Height_Save(a4),a1
	Move.w	Spr_Height+(365*16)(a0),(a1)+
	Move.w	Spr_Height+(366*16)(a0),(a1)+
	Move.w	Spr_Height+(367*16)(a0),(a1)+
	Move.w	Spr_Height+(368*16)(a0),(a1)+
	Move.w	#32,Spr_Height+(365*16)(a0)
	Move.w	#32,Spr_Height+(366*16)(a0)
	Clr.w	Spr_Height+(367*16)(a0)
	Clr.w	Spr_Height+(368*16)(a0)
.No_Height_Shrink_for_Lev3Guard	
	Rts

**********************************************************
Make_Collision_Coard_Adjustments
	St	Col_Adj_Flag(a4)	; Set flag
	Move.l	Enemy_Sprites_Base(a4),a0	; Get base of alien sprites
	Lea	Alien_Boxes,a1		; Collision coardinates
	Bsr.s	.Run_Coard		; Make coardinates
	Sf	Col_Adj_Flag(a4)	; Clear flag
	Lea	Wep_Anims,a3		; Weapon anim table
	Lea	Wep_Coard_Adj_Tab,a1	; Weapon Coard table
.Loopx	Tst.w	(a3)			; -1, End of table
	Bmi.s	.Exit
	Move.l	(a3)+,a2		; Get address of anim structure
	Moveq	#0,d0			; Clear work register
	Move.b	1(a2),d0		; Get first sprite
	Move.l	Player_Sprite_Base(a4),a0
	Lsl.w	#4,d0
	Add.l	d0,a0			; Sprite * 16+Base coard
	Bsr.s	.Get			; Ok, get its collision coards
	Bra.s	.Loopx

.Exit	Lea	Alien_Boxes+(91*8),a0	; Tree sprite (number 91!)
	Subq.w	#6,(a0)+
	Subq.w	#6,(a0)+
	Addq.w	#6,(a0)+		; Make this box, that bit bigger!
	Addq.w	#6,(a0)+
	Rts	

.Run_Coard
	Move.w	Number_Of_Sprites_Loaded(a4),-(sp)
.RUNCOARD2
	Bsr.s	.Get			; Get collision adjustments
	Subq.w	#1,(sp)
	Bne.s	.Runcoard2
	Addq.l	#2,sp
	Bra	.Exit

.Get	Move.w	Spr_Yadd(a0),d1
	Move.w	Spr_Height(a0),d3	; Get Y adjustment and height
	Move.w	d3,d7
	Subq.w	#1,d7			; Save height-1
	Add.w	d1,d3			; Add Y adjustment
	Addq.w	#2,d1
	Subq.w	#2,d3			; add 2 to top y, and subtract 2 from bottom y
	Move.w	d1,2(a1)
	Move.w	d3,6(a1)		; Save them
	Tst.w	d7			; If height-1 is negative
	Bmi	.Get_Mask		; Dont worry about x adjsutments, coz they dont matter
	Move.w	Spr_Width(a0),d6	
	Sub.w	#16,d6			; Width of sprite-16
	Lsr.w	#3,d6			; /8
	Move.l	Spr_Addr(a0),a2		; address of Raw data
	Jmp	.Jp(pc,d6)		; Go to appropriate routine

.Jp	Bra.s	.Width16
	Bra.s	.Width32
	Bra.s	.Width48
	Bra.s	.Width64
	Bra	.Width80
	
.Width16
	Moveq	#-1,d0			; Make mask register
	Moveq	#16,d6			
.Loop1	And.w	(a2)+,d0		; Accumalate mask
	Addq.l	#8,a2
	Dbra	d7,.Loop1
	Move.w	d0,d1			; Left remainder=Right remainder
	Bra	.Get_Mask
	
.Width32
	Moveq	#-1,d0
	Moveq	#-1,d1
	Moveq	#32,d6
.Loop2	And.w	(a2)+,d0
	Addq.l	#8,a2
	And.w	(a2)+,d1
	Addq.l	#8,a2
	Dbra	d7,.Loop2
	Bra	.Get_Mask

.Width48
	Moveq	#-1,d0
	Moveq	#-1,d1
	Moveq	#48,d6
.Loop3	And.w	(a2)+,d0
	Addq.l	#8,a2
	Lea	10(a2),a2
	And.w	(a2)+,d1
	Addq.l	#8,a2
	Dbra	d7,.Loop3
	Bra	.Get_Mask

.Width64
	Moveq	#-1,d0
	Moveq	#-1,d1
	Moveq	#64,d6
.Loop4	And.w	(a2)+,d0
	Addq.l	#8,a2
	Lea	20(a2),a2
	And.w	(a2)+,d1
	Addq.l	#8,a2
	Dbra	d7,.Loop4
	Bra	.Get_Mask

.Width80
	Moveq	#-1,d0
	Moveq	#-1,d1
	Moveq	#80,d6
.Loop5	And.w	(a2)+,d0
	Addq.l	#8,a2
	Lea	30(a2),a2
	And.w	(a2)+,d1
	Addq.l	#8,a2
	Dbra	d7,.Loop5
	Bra	.Get_Mask
	
.Get_Mask	
	Moveq	#-1,d2
.Srch1	Addq.w	#1,d2
	Add.w	d0,d0
	Bcs.s	.Srch1
	Addq.w	#2,d2
	Move.w	d2,0(a1)		; Get the left X adjustment
	Moveq	#-1,d2
.Srch2	Addq.w	#1,d2
	Lsr.w	#1,d1
	Bcs.s	.Srch2
	Sub.w	d2,d6
	Subq.w	#2,d6
	Move.w	d6,4(a1)		; Get the Right shift adjustment
	Tst.b	Col_Adj_Flag(a4)	; If doing Weapons sprites
	Bne.s	.Advance
	Subq.w	#2,(a1)
	Addq.w	#2,4(a1)		; Beware of the width !!!
.Advance
	Addq.l	#8,a1			; Next set of coards
	Lea	Spr_E(a0),a0		; Nexit sprite
	Rts

**********************************************************
Abs_Player
	St	Restart
	Lea	Player_sprites,a0
	Move.w	(a0)+,Number_Of_Sprites_Loaded(a4)
	Move.l	a0,Player_Sprite_Base(a4)
	Bra.s	Make_Abs
Abs_Gfx	Move.l	Enemy_Sprites_Base(a4),a0


; Needs pointer to sprite list in a0
Make_Abs
	Move.l	a0,d6			; Save start of table address
	Move.w	Number_Of_Sprites_Loaded(a4),D0
	Subq.w	#1,d0
.Loop	Add.l	d6,Spr_Addr(a0)		; Add base of table to relative offset
	Subq.l	#2,Spr_addr(a0)
	Lea	Spr_E(a0),a0		; Next sprite
	Dbra	d0,.Loop		; All sprites
	Rts

**********************************************************
Setup_Game_Loop_Vars
	Sf	End_Level(a4)
	Sf	No_Bombing(a4)
	Sf	No_Firing(a4)			; -2 ?
	Sf	Speedup(a4)
	Sf	No_More_Scrolling(a4)		; -4 ?
	Sf	Vbl_Flag(a4)			; Clear VBL wait flag
	St	Vbl_Enabled(a4)
	Move.b	#1,Fade_Direction(a4)		; Fading positive (up!)
	Rts

**********************************************************
Setup_Screen_Mode	
	Move.w	#-1,-(sp)
	Move.l	#Screen1,-(sp)
	Move.l	(sp),-(sp)
	Move.w	#5,-(sp)
	Trap	#14
	Lea	12(sp),sp		; State LOGICAL/PHYSICAL Screen

	Move.w	#89,-(sp)
	Trap	#14			; BIOS Call to get monitor call
	Addq.l	#2,sp			; Returns in d0
	Cmp.b	#2,d0			; Using VGA monitor ?
	Seq	Vga_Flag(a4)		; Set if using VGA monitor
	Bne.s	.Not_Vga		; Branch if not using vga monitor
	Moveq	#$64,d0
	Bra	Setmode			; Set screen mode 8bps,PAL/OVERscan!
.Not_Vga 
	Moveq	#$63,d0
	Bra	Setmode			; Set screen mode 8bps,PAL/OVERscan!

**********************************************************
ScrollDown
	Sf	Flag_To_Flip_Screens(a4)	; Clear flag on start
	Movem.w	LineOffset(a4),d0-d1		; Get both screens line offsets
	Subq.w	#1,d0				; 1 from current line offset
	Bpl.s	.No_Wrp				; No wrap !
	Move.w	#Height-1,d0			; Set Wrap line offset
	St	Screen_Wrap_Round_Flag(a4)	; Set flag to say you wrapped
.No_Wrp	Move.w	d0,LineOffset(a4)		; Save line offset
	Tst.b	Screen_Wrap_Round_Flag(a4)	; Did we wrap ?
	Beq.s	.No_Flag_Clear			; No !
	Tst.b	Screen_Wrap_Round_Flag+1(a4)	; Has other screen wraped ?
	Bne.s	.No_Flag_Clear			; YES!
	Move.w	#Height,d1			; Test for flip will always be TRUE
.No_Flag_Clear	
	Tst.b	Screen_Wrap_Round_Flag(a4)
	Beq.s	.No_Clear_Wrap			; No WRAP for screen 1
	Tst.b	Screen_Wrap_Round_Flag+1(a4)
	Beq.s	.No_Clear_Wrap			; No WRAP for screen 2
	Clr.w	Screen_Wrap_Round_Flag(a4)	; Else clear both flags
.No_Clear_Wrap
	Cmp.w	d0,d1				; Is the second screens lineoffset > First ?
	Sgt	Flag_To_Flip_Screens(a4)	; Flip screens !
	Addq.w	#1,MapCount(a4)			; 1 to line offset into blocks
	And.w	#$f,MapCount(a4)		; Mask
	Bne.s	.No_Map_Adjust			; No new map line
	Moveq	#60,d0
	Sub.l	d0,Mapdatap(a4)			; 1 line up
.No_Map_Adjust
	Rts	

**********************************************************
Generate_Map
	Move.w	#Height-1,LineOffset(a4)	
	Move.w	#Height-1,LineOffset+2(a4)	
	Move.w	#Height,-(sp)		; For 240 lines (display height)
.Loop	Bsr	Scroll_Screen_Down
	Tst.b	Flag_To_Flip_Screens(a4)
	Beq.s	.Loop
	Bsr	Scroll_Down_Map
	Bsr	Swapscreens		; Swap buffers
	Subq.w	#1,(sp)			; For 240 frames (genrate 1 whole screen!)
	Bne.s	.Loop
	Addq.l	#2,sp			; Re-align stack
	Rts

**********************************************************
Out	Bsr	No_Joy			; Enable keyboard
	Bsr	Pt_Mod_Off
	Lea	Data(pc),a4		; Pointer to variable space, just in case of FUCK
	Bsr	Disable_Ints		; Disable interrupts
	Bsr	Quit_Sound		; No more sound
	Move.l	Vbl_save(a4),$70.w	; restore SYSVBL vector
	Move.w	Mod_Save(a4),Scr_Mod
	Move.w	DEL_Save(a4),Scr_Del	; Restore screen hardware shift/modulos
	Ifeq	Makedisk
	IFNE	SYS			; Assemle only if not debugging
	Move.w	Old_Mode(a4),d0	
	Bsr	Setmode			; Restore system screen mode
	Endc
	Endc
	Bsr	Enable_Ints		; Enable interrupts
	Move.l	Stack_Save(pc),a7	; Stack back !
	Lea	Pal256,a0
	Move.w	#255,d0
.Loop	Move.l	#0,(a0)+
	Dbra	d0,.Loop
;	Bra	Start
	Rts

**********************************************************
Save_Falcon_Sys
	move.l	$70.w,Vbl_save(a4)	; Save the VBL vector
	Move.w	Scr_Mod,Mod_Save(a4)
	Move.w	Scr_Del,Del_Save(a4)	; Save screen hardware
	rts

**********************************************************
Setup_Game_Sys
	Move.l	#New_Vbl,$70.w	; My VBL shite routine
	Lea	Blitterstuff,a6
	Move.w	#-1,Endmask2(a6)
	Move.b	#02,Hop(a6)	; Crap blitter constant regs
	Rts
	
**********************************************************
Initial_Vars
; Setup pointer to power-up event
	Bsr	Kill_Bgbuffers			; Clear some variable space and back ground buffers
	Move.l	#Bgbuffer1+Data,BGBufferp+0(a4)
	Move.l	#Bgbuffer2+Data,BGBufferp+4(a4)	; More double buffer pointers
	Move.l	#Bgbuffer1+Data,BGSAVEP(a4)	; More double buffer pointers
	Move.w	#(480-384)/2,d0
	Move.w	d0,AScreenXoffset(a4)
	Add.w	#32,d0
	Move.w	d0,ScreenXoffset(a4)	

	Move.l	#Power_Up_Event_Table,Power_Up_Event_Table_Pointer(a4)
	Move.b	#Level,This_Level(a4)		; Setup current level
	Cmp.b	#3,d7
	Seq	Player2_Startup(a4)

	Lea	Pl1,a0				
	Move.l	a0,Player_Use(a4)
	Lsr.w	#1,d7
	Bcc.s	.No_Pl1			
	Bsr	Init_Player
.No_Pl1			
	Lea	Pl2,a0				
	Lsr.w	#1,d7
	Bcc.s	.No_Pl2
	Bsr	Init_Player
.No_Pl2
	Sf	Player2_Startup(a4)
	Rts

Init_Player
	Move.b	#3,Num_Lives(a0)		; Set number of lives
	Move.l	a0,a3
Setup_Player
	Move.l	Score(a3),-(sp)
	Move.l	PrevScore(a3),-(sp)
	Move.b	Num_Lives(a3),-(sp)	
	Pea	(a3)
	Bsr	Clear_Player_data		; Save certain player variables and then clear all player data
	Move.l	(sp)+,a0
	Move.b	(sp)+,Num_Lives(a0)
	Move.l	(sp)+,PrevScore(a0)
	Move.l	(sp)+,Score(a0)			; Restore saved variables
	Move.b	#3,Num_Bombs(a0)
	Move.b	#3,Bombs_Got(a0)		; Setup number of bombs/bonus calculation value for bombs
	St	Shipbuffer(a0)			
	St	Player_Active(a0)		
	St	Startup(a0)			; No restore/Active/Startup routine
	Move.b	#1,Weapon_In_Use(a0)		; Using normal shot
	Move.b	#4,Weapon_Power(a0)		; At power-up level 4
	Move.b	#-1,Secondry_Weapon(a0)		; No secondry weapon
	Move.b	#0,Weapon_Power2(a0)		; Clear powerup for level
	Move.b	#Ded_Delay,Dead_Count(a0)	; Startup-delay
	Moveq	#0,d4
	Cmp.l	#Pl1,a0
	Beq.s	.Player1
	Moveq	#1*2,d4
.Player1
	Tst.b	Player2_Startup(a4)
	Bne.s	.Ok2
	Moveq	#2*2,d4
.Ok2	Move.w	.Player_Start_Coards(pc,d4),Shipxy(a0)
	Move.w	#Height,Shipxy+2(a0)
	Rts

.Player_Start_Coards
	Dc.w	(384/4)-16
	Dc.w	((384/4)*3)-16*3
	Dc.w	(384/2)-16

**********************************************************
; Clear an array of bytes
; a0-Start address
; d0.l-Number of bytes to clear

Clear_Bytes
	Clr.b	(a0)+
	Subq.l	#1,d0
	Bne.s	Clear_Bytes
	Rts

**********************************************************
; Copy an array of bytes
; a0-Start address
; a1-Dest address
; d0.l-Number of bytes to clear

Copy_Bytes
	Move.b	(a0)+,(a1)+
	Subq.l	#1,d0
	Bne.s	Copy_Bytes
	Rts


**********************************************************

Kill_Bgbuffers
	Lea	Var_Clear(a4),a0		; Variable space to clear
	Move.l	#Varend-Var_Clear,d0		; Count
	Bsr	Clear_Bytes			; Clear bytes
	Lea	BgBuffer1(a4),a0
	Move.l	#Varend-BgBuffer1,d0
	Bsr	Clear_Bytes			; Same for background buffer
	Rts

**********************************************************
Cleardata
	Move.l	a4,a0
	Move.l	#Varend,d0
	Bsr	Clear_Bytes
	Lea	Pl1,a0
	Bsr.s	Clear_Player_data			
	Lea	Pl2,a0

Clear_Player_data			
	Move.l	#Pvarend,d0
	Bra	Clear_Bytes

**********************************************************
Setup_Screens
	Move.l	#Screen1,d0
	Move.l	#Screen2,d1		; Load screen addresses
	Moveq	#-4,d2			; Mask long word boundry
	And.l	d2,d0
	And.l	d2,d1
	Movem.l	d0-d1,Screenp(a4)	; Save screen pointers
	Lea	Screenarea,a0
	Move.l	#(Screenareaend-Screenarea),d0
	Bra	Clear_Bytes

**********************************************************
Wait_Main_Vbl
	Illegal
	Moveq	#Frame_Rate,d0
	Bra.s	Wait_Vbl			; Current frame rate
Wait_1_Frame
	Moveq	#1,d0				; Appropriate frame rate
	Bra.s	Wait_Vbl
Wait_4_Frames
	Moveq	#4,d0
	Bra.s	Wait_Vbl
	Nop
**********************************************************
Wait_Vbl
	IFNE	SYS				; Only assemble if system
	Move.b	Vbl_Flag(a4),d1			; Current frame count in d1
.Wait1	Cmp.b	Vbl_Flag(a4),d1
	Beq.s	.Wait1				; Wait for tick over
.Wait	Cmp.b	Vbl_Flag(a4),d0			; Wait for Vblflag>=
	Bgt.s	.Wait
	Moveq	#Consistancy_Frame_Rate,d2	; Used for consistant speed
	Sub.b	Vbl_Flag(a4),d2			; Subtract from consistancy rate
	Sub.b	d2,Frames_To_Consist(a4)	; Save
	Clr.b	Vbl_Flag(a4)			; Clear vbl_Flag
	ENDC
	Rts

**********************************************************
Save_Blitter_Regs
	Lea	Blitter_Saves(a4),a1
	Lea	Blitterstuff,a6
	Move.w	Endmask1(a6),(a1)+
	Move.w	Endmask2(a6),(a1)+
	Move.w	Endmask3(a6),(a1)+
	Move.w	Src_Xinc(a6),(a1)+
	Move.w	Src_Yinc(a6),(a1)+
	Move.w	Dst_Xinc(a6),(a1)+
	Move.w	Dst_Yinc(a6),(a1)+
	Move.l	Src_Addr(a6),(a1)+
	Move.l	Dst_Addr(a6),(a1)+
	Move.w	X_Count(a6),(a1)+	
	Move.w	Y_Count(a6),(a1)+	
	Move.b	Op(a6),(a1)+
	Move.b	Skew(a6),(a1)+
	Rts


**********************************************************
Restore_Blitter_Regs
	Lea	Blitter_Saves(a4),a1
	Lea	Blitterstuff,a6
	Move.w	(a1)+,Endmask1(a6)
	Move.w	(a1)+,Endmask2(a6)
	Move.w	(a1)+,Endmask3(a6)
	Move.w	(a1)+,Src_Xinc(a6)
	Move.w	(a1)+,Src_Yinc(a6)
	Move.w	(a1)+,Dst_Xinc(a6)
	Move.w	(a1)+,Dst_Yinc(a6)
	Move.l	(a1)+,Src_Addr(a6)
	Move.l	(a1)+,Dst_Addr(a6)
	Move.w	(a1)+,X_Count(a6)
	Move.w	(a1)+,Y_Count(a6)
	Move.b	(a1)+,Op(a6)
	Move.b	(a1)+,Skew(a6)
	Rts

**********************************************************
** NEW VERTICAL BLANK !
New_Vbl Push					; Save all registers
	Lea	Data(pc),a4			; Setup pointer to dataspace
	Tst.b	Vbl_Enabled(a4)
	Beq	.No_Int
	Bsr	Save_Blitter_Regs
	Move.l	RealScreenp(a4),-(sp)		; Drawing into view screen
	Bsr	Process_Screen			; Set screen base/Screen hardware stuff
	Bsr	Pallete_Stuff_For_Vbl		; Fade colour pallete
	Bsr	Cycle_Level			; Cycle colours according to level
	Bsr	Do_Flash			; Copy flashed colour pallete to colour registers
	Bsr	Flash_Bomb			; Calculate Flash pallete
	Bsr	Wait_For_100			; Wait until ship has reached line 100 (startup)
	Bsr	Restoreshipback			; Restore ship background
	Bsr	Readjoy				; Read joystick
	Bsr	Adj_Speed			; Adjust Left/Right/Up/Down vectors
	Bsr	Chk_Speed			; Check maximum of vectors
	Bsr	Move_Ship			; Get new ship x/y Coardinates
	Bsr	Check_Ship_Bound		; Check screen coardinates of ship
	Bsr	Saveshipback			; Save background of ship
	Bsr	Dead_Count_Dec			; Decrement delay for collision on ship
	Bsr	Draw_Ship			; Draw ship to view screen
	Bsr	Save_Ship_Explosion		; Save ship explosion
	Bsr	Draw_Ship_Explosion		; Draw ship explosion
	Addq.b	#1,Vbl_flag(a4)			; INC VBL count
	Bsr	Restore_Blitter_Regs
	Move.l	(sp)+,RealScreenp(a4)		; Restore screen pointer
;	Bsr	Play_Sams			; play samples anyway
	Bsr	Pt_Vbl				; and also play tune
.No_Int	Pull					; Pull registers
	Rte					; Return from Exeption

**********************************************************
Cycle_Level
	Addq.b	#1,Level_Cycle_Dec(a4)
	Tst.b	Blue_Cycle(a4)		
	Beq.s	.No_Blue_Cycle			; Test flag for bonus cycle
	Lea	Blue_Cycle_Script(pc),a0
	Bsr.s	Do_Cycle
.No_Blue_Cycle				; Test flag for bonus cycle
	Moveq	#0,d0				; Clear work register
	Move.b	This_Level(a4),d0
	Move.l	.Cycle_Tab-4(pc,d0*4),a0
	Bra.s	Do_Cycle
.Cycle_Tab
	Dc.l	Level1_Cycle_Script
	Dc.l	Level2_Cycle_Script
	Dc.l	Level3_Cycle_Script
	Dc.l	Level4_Cycle_Script
	Dc.l	Level5_Cycle_Script
	Dc.l	Level6_Cycle_Script
	Dc.l	Level7_Cycle_Script
	Dc.l	Level8_Cycle_Script

Do_Cycle
	Move.w	(a0)+,d0			; Cycle every n/50 second
	Bmi.s	.No_More_Cycling
	Moveq	#0,d1
	Move.b	Level_Cycle_Dec(a4),d1
	Divu	d0,d1
	Swap	d1
	Tst.w	d1
	Bne.s	.No_Cycle
	Move.w	(a0)+,d0			; Number of colours to cycle
	Subq.w	#2,d0				; dbra
	Move.w	(a0)+,d1			; Starting from colour number
	Lea	Pal256,a1
	Lea	(a1,d1*4),a1
	Move.l	a1,a2
	Move.l	(a1)+,-(sp)
.Cycle_Loop
	Move.l	(a1)+,(a2)+
	Dbra	d0,.Cycle_Loop
	Move.l	(sp)+,(a2)
	Bra.s	Do_Cycle
.No_Cycle
	Addq.l	#4,a0	
	Bra.s	Do_Cycle
.No_More_Cycling
	Rts
Level1_Cycle_Script
	Dc.w	10,4,124
	Dc.w	-1
Level2_Cycle_Script
	Dc.w	-1
Level3_Cycle_Script
;	Dc.w	10,4,109
	Dc.w	5,6,109
	Dc.w	-1
Level4_Cycle_Script
	Dc.w	8,6,104
	Dc.w	8,4,110
	Dc.w	12,6,114
	Dc.w	12,8,120
	Dc.w	-1
Level5_Cycle_Script
	Dc.w	4,4,104
	Dc.w	8,4,108
	Dc.w	8,4,112
	Dc.w	8,4,116
	Dc.w	-1
Level6_Cycle_Script
	Dc.w	10,4,124
	Dc.w	5,4,120
	Dc.w	-1
Level7_Cycle_Script
Level8_Cycle_Script
Blue_Cycle_Script
	Dc.w	1,16,128+32
	Dc.w	1,16,128+48
	Dc.w	-1

**********************************************************
Pallete_Stuff_For_Vbl
	Tst.b	Max_Pallete(a4)
	Bne.s	.Just_Copy_Pal		; Just copy dest pallete if this flag true
	Cmp.w	#256,Intens(a4)			
	Bgt.s	.Pallete_Done		; If intens>256, No more calculating
	Tst.w	Intens(a4)			
	Blt.s	.Pallete_Done		; If intens<0, no more calculating
	Bsr	Copypal			; Copy destpal>Colour registers
	Bsr	Fade_pal		; Calcualte new pallete
.Pallete_Done
	Rts
.Just_Copy_Pal
	Sf	Max_Pallete(a4)		; Clear max_pallete flag
	Bsr	CopyPal			; Copy pallete anyway
	Rts
	
**********************************************************
Process_Screen
	Move.l	Ship_Draw(a4),RealScreenp(a4)	; Set new view screen pointer
	Move.w	Scr_Mod_Save(a4),Scr_Mod
	Move.w	Scr_Del_Save(a4),Scr_Del	; Set modulos/Pixel delay on VBL	
	Move.l	Display_At_This_Address(a4),-(sp)
	Move.b	1(sp),Bp_hi
	Move.b	2(sp),Bp_md			; Setup Screen address on VBL
	Move.b	3(sp),Bp_lo+1
	Addq.l	#4,sp
	Rts

**********************************************************
Save_Ship_Explosion
	Move.l	Player_Use(a4),a3
	Tst.b	Just_Dead(a3)
	Bne.s	.Do_Save			; Test flag for dead
	Rts
.Do_Save
	Move.w	Ship_Explosion_Num(a3),d0	; Number in d0
	Bmi	.Exit				; -ive, exit
	Lea	Shipbuffer(a3),a1		; Pointer to buffer
	St	(a1)				; Set it
	Lea	Ship_Dead_Anims,a0
	Move.w	(a0,d0*2),d0			; Get sprite number
	Move.l	Enemy_Sprites_Base(a4),a0	; Sprite base in a4
	Add.w	d0,d0
	Lea	(a0,d0*8),a0			; a0 points to current explosion sprite structure
	Movem.w	Shipxy(a3),d0-d1		; Get x/y coardinates of ship
	Add.w	ScreenXoffset(a4),d0		; Add Offset into screen
	Add.w	Spr_Yadd(a0),d1			; Add y offset
	Cmp.w	#240,d1	
	Bge.s	.Exit				; >=240, off sreen - no need to save
	Move.w	d1,-(sp)			; Save y coardinate
	Muls	#Byteswide,d1			; Get line address
	Moveq	#$f,d6				; Mask for sdhift
	And.w	d0,d6				; Mask x coardinate
	Sub.w	d6,d0				; Subtract remainder from x coardinate
	Add.l	d0,d1				; Add word address to screen line
	Add.l	Realscreenp(a4),d1		; Add screen base
	Move.l	d1,a6				; Save in address register
	Move.l	a6,(a1)+			; Save address in structure
	Move.w	Spr_Height(a0),d7		; Save height
	Move.w	d7,(a1)+
	Move.w	d7,d6				; Save height into another register
	Add.w	(sp)+,d6			; Add adjusted y coardinate
	Sub.w	#240,d6
	Ble.s	.Ok				; Clip height if needed
	Sub.w	d6,d7				; New height
	Move.w	d7,-2(a1)			; Save new height
.Ok	Subq.w	#1,d7				; 1 from height
	Move.l	a6,a0				; Save in a nice register
.Loop	Movem.l	(a0),d0-d6/a2-a6		; save 48 pixles
	Movem.l	d0-d6/a2-a6,(a1)
	Lea	Byteswide(a0),a0
	Lea	48(a1),a1
	Dbra	d7,.Loop			; For all height
	Lea	Data(pc),a4			; Variable Base
.Exit	Rts

**********************************************************
Draw_Ship_Explosion
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Move.l	a3,Player_Use(a4)
	Tst.b	Just_Dead(a3)
	Bne.s	.Do_Draw			; Only do if dead
	Rts
.Do_Draw
	Move.w	Ship_Explosion_Num(a3),d0
	Bmi	.No_Add	
	Lea	Ship_Dead_Anims,a0
	Move.w	(a0,d0*2),d0			; Get sprite num
	Move.l	Enemy_Sprites_Base(a4),a0
	Add.w	d0,d0
	Lea	(a0,d0*8),a0			; Setup pointer into sprite stucture
	Movem.w	Shipxy(a3),d0-d1		; Get shipx/y
	Add.w	ScreenXoffset(a4),d0		; X offset into screen
	Add.w	Spr_Yadd(a0),d1			; Add y offset
	Cmp.w	#240,d1
	Bge	.No_add				; >=250 no draw !
	Move.w	d1,-(sp)			; Save y
	Muls	#Byteswide,d1
	Moveq	#$f,d6
	And.w	d0,d6				; Shift in d6
	Sub.w	d6,d0
	Add.l	d0,d1
	Add.l	Realscreenp(a4),d1		; Screen address to draw to in d1
	Move.l	d1,a6				; Transfer to address register
	Move.l	Spr_Addr(a0),a1			; Sprite address in a1
	Move.w	Spr_Height(a0),d7
	Move.w	d7,d5				; Sprite height in 2 registers
	Add.w	(sp)+,d5			; Add y offset
	Sub.w	#240,d5
	Ble.s	.Okl
	Sub.w	d5,d7				; New height if over 240
.Okl	Move.w	d7,-(sp)			; Save height
	Move.w	Spr_Plane(a0),d7		; Get planes used
	Lsr.w	#4,d7
	Move.w	d7,Explosion_Plane(a4)		; Sav
	Move.l	a1,a0
	Move.l	a6,a1
	Lea	16(a1),a2			; Row2
	Lea	16(a2),a3			; Row3
	Move.w	d6,d0
	Move.l	#byteswide-8,d6			; Modulo !
.Loop	Moveq	#-1,d1
	Moveq	#-1,d2				; - for mask !
	Move.w	(a0)+,d1			; Mask1 in d1
	Lea	8(a0),a4			; Pointer to mask 2
	Move.w	(a4)+,d2			; Mask2
	Ror.l	d0,d1
	Ror.l	d0,d2
	Move.l	a1,a6
	Cmp.w	#-1,d1
	Beq.s	.Nmsk1
	And.w	d1,(a6)+
	And.w	d1,(a6)+
	And.w	d1,(a6)+
	And.w	d1,(a6)+
	Move.l	d6,-(sp)
	Move.w	Explosion_Plane+Data(pc),d6
	Rept	4
	PlaneDraw	d1			; Draw to approprtiate plane
	Endr
	Move.l	(sp)+,d6
	Bra.s	.Nmsk1+4
.Nmsk1	Lea	16(a6),a6
	Swap	d1
	And.w	d1,d2
	Cmp.w	#-1,d2
	Beq.s	.Nmsk2
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	Move.l	d6,-(sp)
	Move.w	Explosion_Plane+Data(pc),d6
	Rept	4
	PlaneDraw	d2				; Draw to appropriate plane
	Endr
	Move.l	(sp)+,d6
	Bra.s	.Nmsk2+4
.Nmsk2	Lea	16(a6),a6
	Swap	d2
	Cmp.w	#-1,d2
	Beq.s	.Nmsk3
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	Move.l	d6,-(sp)
	Move.w	Explosion_Plane+Data(pc),d6
	Rept	4
	PlaneDraw	d2
	Endr
	Move.l	(sp)+,d6
	Bra.s	.Nmsk3+4
.Nmsk3	Lea	16(a6),a6
	Rept	4
	Moveq	#0,d1
	Moveq	#0,d2
	Move.w	(a0)+,d1
	Move.w	(a4)+,d2
	Ror.l	d0,d1
	Ror.l	d0,d2
	Or.w	d1,(a1)+
	Swap	d1
	Or.w	d1,d2
	Or.w	d2,(a2)+
	Swap	d2
	Or.w	d2,(a3)+
	Endr
	Move.l	a4,a0
	Add.l	d6,a1
	Add.l	d6,a2
	Add.l	d6,a3
	Subq.w	#1,(sp)
	Bne	.Loop				; 1 from height
	Addq.l	#2,sp				; Align stack
	Lea	Data(pc),a4
	Move.l	Player_Use(a4),a3		; Setup data pointer, get player variables
	Subq.w	#1,Ship_Explosion_Dec(a3)
	Bgt.s	.No_Add				; 1 from Explosion dec,<=0 new number
	Move.w	#Player_Explosion_Delay,Ship_explosion_Dec(a3)		; Resore explosion dec
	Addq.w	#1,Ship_Explosion_Num(a3)	; 1 to sprite num
	Move.w	Ship_Explosion_Num(a3),d0	; get explosion num
	Lea	Ship_Dead_Anims,a0
	Tst.w	(a0,d0*2)			; Test anim
	Smi	Ship_Explosion_Num(a3)		; minus, set this flag
.No_Add	Rts

**********************************************************
Do_Flash
	Move.l	Player_Use(a4),a3
	Tst.b	Bomb_Active(a3)
	Beq.s	.No				; Only do if this flag set
	Lea	Destpal(a4),a0			; Pointer to source
	Lea	Pal256,a1			; Pointer to colour registers
	Moveq	#20,d7
.Loop	Movem.l	(a0)+,d0-d6/a2-a6
	Movem.l	d0-d6/a2-a6,(a1)
	Lea	48(a1),a1			; Copy 252 colour registers
	Dbra	d7,.Loop
	Movem.l	(a0)+,d0-d3
	Movem.l	d0-d3,(a1)			; Copy the remaining 4
	Lea	Data(pc),a4			; Setup pointer to variables
.No	Rts
**********************************************************
Flash_Bomb
	Move.l	Player_Use(a4),a3
	Bsr.s	.Do				; Pointer to player variables
.Exit	Rts		

.Do	Tst.b	Bomb_Active(a3)		
	Beq.s	.Exit				; Only do if this flag set	
	Tst.b	Bomb_Dec(a3)			
	Bne	Bdn				; Bomb down if this flag set 

Bup	Lea	Destpal(a4),a1			; Pointer to calculated pallete
	Move.w	#255,d0				; 256 colours
	Move.l	#$ffff00ff,d6			; Comparision (MAX R/G/B)
	Moveq	#16,d5				; Add value for each component
	Sf	d7				; Clear flag
.Loop0	Move.l	a1,a0				; Save pointer to pallete to be calculated
	Move.b	(a0)+,d1			; Red component
	Move.b	(a0)+,d2			; Green Component
	Move.w	(a0)+,d3			; Blue component
	Add.b	d5,d1				; Add to red component
	Bcc.s	.Nx
	Moveq	#-1,d1				; Carry generated, set to $ff
.Nx	Add.b	d5,d2
	Bcc.s	.Nx1
	Moveq	#-1,d2				; Same for green
.Nx1	Add.b	d5,d3
	Bcc.s	.Nx2
	Moveq	#-1,d3				; Same for blue
.Nx2	Move.b	d1,(a1)+
	Move.b	d2,(a1)+
	Move.w	d3,(a1)+			; Resave
	And.l	d6,-(a0)			; Mask Blank byte
	Cmp.l	(a0)+,d6			; Compare with white
	Beq.s	.Dec
	St	d7				; Set this flag if not done			
.Dec	Dbra	d0,.Loop0			; All colours
	Tst.b	d7				; Test flag
	Bne.s	.Exit				; Set, Flash up not done
	Not.b	Bomb_Dec(a3)			; Flash down
.Exit	Rts

	
Bdn	Lea	Mypal,a0		; Source pallete
	Lea	Destpal(a4),a1		; Dest pallete
	Move.w	#255,d0			; 256 colours
	Sf	d7			; Clear flag
	Moveq	#16,d5			; Value to subtract from components
.Loop0	Move.l	(a0),d3
	Move.l	(a1),d4			; Get source/Dest colour
	Cmp.l	d3,d4				
	Beq.s	.Ok			; Same, no need to calculate new colour
	St	d7			; Set flag for not done
	Sub.b	d5,(a1)			; Bring down Red component
	Bcc.s	.X1
	Clr.b	(a1)			; Clear component if carry generated
.X1	Sub.b	d5,1(a1)
	Bcc.s	.X2
	Clr.b	1(a1)			; Same for green
.X2	Sub.b	d5,3(a1)
	Bcc.s	.X3
	Clr.b	3(a1)			; Same for blue
.X3	Cmp.b	(a0)+,(a1)+
	Bcc.s	.Nx1			; Compare source red with dest red
	Move.b	-1(a0),-1(a1)		; Dest=Source if Less than
.Nx1	Cmp.b	(a0)+,(a1)+
	Bcc.s	.Nx2
	Move.b	-1(a0),-1(a1)		; Same for green
.Nx2	Move.b	(a0)+,(a1)+			
	Cmp.b	(a0)+,(a1)+
	Bcc.s	.Ok1
	Move.b	-1(a0),-1(a1)		; And same for blue
.Ok1	Dbra	d0,.Loop0		; All colours
	Bra.s	.Skip			; Test flag if counter 0
.Ok	Cmp.l	(a0)+,(a1)+		; Increment both source/dest pointers (COOL EH!)
	Dbra	d0,.Loop0		; All colours

.Skip	Tst.b	d7			; Test flag if flash hit ROCK BOTTOM
	Bne.s	.Exit			; It didnt!
	Clr.w	Bomb_Struct(a4)		; Clear various bomb variables
	Clr.b	Bomb_Active(a3)
	Clr.b	Bomb_Dec(a3)			
	Clr.b	Cant_Bomb(a3)
.Exit	Rts
	
**********************************************************
Check_Bomb_Button
	Move.l	Player_Use(a4),a3	; Pointer to active player
	Bsr.s	.Do			
.Exit	Rts
	
.Do	Tst_Act
	Tst_Startup			; Just make sure can use button anyway!
	Tst.b	Cant_Bomb(a3)
	Beq.s	.Oktobomb		; No releasing when already dropped!
	Rts	
.Oktobomb
	Tst.b	Just_Dead(a3)
	Bne.s	.Exit			; If you just been hit, cant do !
	Tst.b	Bomb_Active(a3)
	Bne.s	.Exit			; If already dropping/flashing bomb, cant do
	Tst.b	Bomb_Pressed_On_Read(a3)
	Beq.s	.Exit			; Check if you pressed this button anyway
	Tst.b	No_Bombing(a4)
	Bne.s	.Exit			; Also check this global flag
	Tst.b	Num_Bombs(a3)		; Cant bomb when you aint got any!
	Ble.s	.Exit
	Ifne	Bombdec			; Only assemble if bomb counter decrements
	Subq.b	#1,Num_Bombs(a3)	; 1 less bomb!
	Endc
	St	Cant_Bomb(a3)		; No bombing
	Clr.b	Bomb_Dec(a3)		; Clear delay
	Movem.w	Shipxy(a3),d0-d1	; Get X/Y of ship !
	Subq.w	#8,d1
	Add.w	Ascreenxoffset(a4),d0	; Add to X!
	Add.w	#40,d0			; Make X more realistic
	Movem.w	Clearr(a4),d2-d4	; Clear top values
	Movem.w	d0-d4,Bomb_Struct(a4)	; X/Y of bomb into structure
	Rts	
	
**********************************************************
Save_Bomb_Gfx
	Tst.w	Bomb_Struct(a4)
	Beq.s	.Exit				; No bomb active
	St	Bomb_Has_Been_Saved(a4)		; Set this flag
	St	Save_B(a4)			; Set to save
	Bsr.s	Do_Bomb_Gfx2			; Save it
	Sf	Save_B(a4)			; Clear to draw!
.Exit	Rts

**********************************************************
Do_bomb_Gfx
	Tst.b	Bomb_Has_Been_Saved(a4)		
	Bne.s	.Do_Bomb_Gfx2			; Only do if flag is set
	Rts
.Do_Bomb_Gfx2
	Sf	Bomb_Has_Been_Saved(a4)		; Clear flag

Do_Bomb_Gfx2
	Move.l	Player_Use(a4),a3	
	Tst.w	Bomb_Struct(a4)
	Beq.s	.Exit				; Check x in structure, 0 nowt!
	Tst.b	Bomb_Active(a3)
	Beq.s	.Ok1				; Only do if bomb active
.Exit	Rts

.Ok1	Lea	Bomb_Struct(a4),a0		; pointer to bomb strcuture
	Movem.w	(a0)+,d0-d2			; X/Y/ Sine value
	Lea	Alien_Sine(pc),a1		; Pointer to sine table
	Tst.b	Save_B(a4)
	Beq.s	.G				; Not saving !
	Sub.w	(a0)+,d0
	Sub.w	(a0)+,d1			; Adjust X/Y
	Addq.w	#4,d2
	And.w	#$7f,d2				; Mask !
	Bne.s	.NoGo				; Yo ! GO!
	St	Bomb_Active(a3)
	Rts
.NoGo	Move.w	d2,-6(a0)			; Save sine value !
.G	Lsr.w	#1,d2				; Shift for half circle
	Move.w	(a1,d2*2),d2			; Sine value into d2 !
	Move.w	d2,d3				; Save in d3
	Mulu	#6,d3
	Swap	d3				; Anim in d3
	Move.b	Bomb_Flip(a4),d4		; Bomb flip Flag
	And.w	#3,d4				; Get 0-2
	Add.w	d4,d3				; Add it to base sprite
	Move.b	.Bomb_Anms(pc,d3),d3		; Collect the appropriate sprite
	Bra.s	.Skip_Anms			; Skip data table
.Bomb_Anms
	Dc.b	51,52,53
	Dc.b	54,82,83
.Skip_Anms
	Tst.b	Save_B(a4)
	Beq.s	.H				; Not saving
	Mulu	#42,d2				; upto -42!
	Add.l	d2,d2
	Swap	d2
	Neg.w	d2				; Negate
	Move.w	d2,-2(a0)			; Save Y offset value
	Add.w	d2,d1				; Get normal Y
	Movem.w	d0-d1,-10(a0)			; Save x/y
.H	
	Move.l	Player_Sprite_Base(a4),a0
	Add.w	d3,d3				; Double anim !
	Add.w	Spr_Yadd(a0,d3*8),d1		; Add to Y offset !
	Move.l	Spr_Addr(a0,d3*8),d2		; Source sprite!
	Move.w	d3,d5
	Movem.w	Spr_Height(a0,d5*8),d3-d4	; Height/Plane data!
	Bsr	Setup_Blitter
	Move.w	#0,Src_Yinc(a6)
	Move.w	#Byteswide-16,Dst_Yinc(a6)	; Setup rest of blittr regs
	Moveq	#$f,d5
	And.w	d0,d5
	Move.b	d5,Skew(a6)			; Skew Value!
	Lea	Lfm,a5
	Move.w	(a5,d5*2),Endmask1(a6)
	Move.w	Bmask_Add(a5,d5*2),Endmask3(a6)
	
	Sub.w	d5,d0				; Subtract from X
	Mulu	#Byteswide,d1			; 1 line !
	Add.l	d0,d1				; Add X offset !
	Add.l	Realscreenp(a4),d1		; Get Screen pointer !
	
	Tst.b	Save_B(a4)
	Beq.s	.No	
	Push
	Move.l	BgSaveP(a4),a1	; Save if set !/ draw if clear!
	Move.l	d1,(a1)+
	Move.l	d1,a0
	Move.w	#16,(a1)+
	Move.w	d3,(a1)+
	Moveq	#32,d2
	Mulu	d3,d2
	Move.w	d2,(a1)+
	Subq.w	#1,d3
.Cloop	Movem.l	(a0),d0-d2/d4-d7/a2
	Movem.l	d0-d2/d4-d7/a2,(a1)
	Lea	Byteswide(a0),a0
	Lea	32(a1),a1	
	Dbra	d3,.Cloop
	Move.l	a1,BgSaveP(a4)
	St	(a1)
	Pull
	Rts
.No	
;Parameters
;d1-Source address of sprite
;d2-Height of sprite
;d3-Plane data for sprite
;d4-Destination Yinc
;d5-Xcount
;d6-Planes used
;a2-Screen destination
;a6-Pointer to blitter base address
	Move.l	d1,a2	
	Move.l	d2,d1
	Move.w	d3,d2
	Move.w	d4,d3
	Move.w	#Byteswide-16,d4
	Moveq	#2,d5
	Moveq	#$f,d6
.Hold	Eor.l	#$ff,Pal256
	Bra.s	.Hold
;	Bsr	Do_Blit
	Rts
	
**********************************************************
Can_I_Let_It_Loose
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
.Do	Move.l	a3,Player_Use(a4)
	Lea	Shots_To_Do(a3),a2	; Table of stuff for weapons
	Tst.b	Flag_For_Random_Spit(a4) ; Flag for dead bolts!
	Bne.s	.Oktf
	Tst.b	No_Move(a3)		; Can you move ?
	Beq.s	.Yes
	Clr.l	X_Speed(a3)		; Clear speed if not!
	Rts	
.Yes	Tst_Act
	Tst_Startup			; Test if active or startup
	Tst.b	No_Firing(a4)		; Can u Fire ?
	Beq.s	.Oktf
	Rts	
.Oktf	Clr.b	Flag_For_Random_Spit(a4)	; Clear flag for bolt spit
	Subq.b	#2,Fire_delay(a3)		; 2 From Fire delay
	Scc	d0				; Clear this reg if carry generated
	And.b	d0,Fire_Delay(a3)		; Mask delay
	Subq.b	#2,Fire_Delay2(a3)
	Scc	d0				; Same for secondry weapon
	And.b	d0,Fire_Delay2(a3)
	Tst.b	We_Have_Fired(a3)		; Have we pressed fire ?
	Beq.s	.Notfired			; No, Clear flag !
	Tst.b	Fire_Delay(a3)
	Bne.s	.Fire2				; Fire2 if no delay for 1!
	Pea	.Fire2(pc)			; Else set return address!
	Pea	Process_Fire(pc)		; Come back on this !
	St	Flash_Mussle(a3)		; Flag to flash mussle round ship
	Tst.b	Weapon_In_Use(a3)		; Test weapon in use
	Beq.s	.Shot				; 0, its not that fackin blue ting
	Cmp.b	#2,Weapon_In_Use(a3)		; Spitting out bolts ?
	Beq.s	.Notfired			; Yes !
	Lea	Laser_Sfx,a6
	Bsr	Play_This_Sample		; Play Lazer SFX
	Bra.s	.Notfired
.Shot	Lea	Shot_Sfx,a6			; Play SHOT SFX
	Bsr	Play_This_Sample
.Notfired
	Clr.b	We_Have_Fired(a3)			
	Rts	

.Fire2	Tst.b	Secondry_Weapon(a3)
	Bmi.s	.NotFired			; Secondry weapon not active (-1)
	Tst.b	Fire_Delay2(a3)			; Delay must be zero !
	Bne.s	.NotFired				
	Move.b	Weapon_In_Use(a3),-(sp)
	Move.b	Weapon_Power(a3),-(sp)		; Save primary weapon variables
	Move.b	Secondry_Weapon(a3),Weapon_In_Use(a3)	
	Addq.b	#3,Weapon_In_Use(a3)	; Save secondry weapon and add 3
	Move.b	Weapon_Power2(a3),Weapon_Power(a3) ; New weapon power
	Bsr.s	Process_Fire		; Fire it
	Move.b	(sp)+,Weapon_Power(a3)
	Move.b	(sp)+,Weapon_In_Use(a3)		; Restore primary variables
	Bra	.NotFired				

Process_Fire
	Movem.w	Clearr(a4),d2-d3		; Clear registers
	Move.b	Weapon_In_Use(a3),d2			
	Move.b	Weapon_Power(a3),d3		; Collect weaopon in use/Powrr
	Lea	Weapon_Jump_Table(pc),a0	; Jump to approprtiate routine
	Jmp	(a0,d2*2)

**********************************************************
Search_Shot_Table
	Tst.b	(a2)			
	Beq.s	.Weapon_Slot_Free
	Lea	Wep_End(a2),a2
	Bra.s	Search_Shot_Table
.Weapon_Slot_Free
	Rts
**********************************************************
Do_Fir3	Move.w	(a0)+,d6			; Compare number of homing missles on screenn with this number
	Cmp.b	Num_Homes(a4),d6
	Bge.s	.Nx				; Cant do if homes on screen >=nunmber
	Rts
.Nx	Add.b	d6,Num_Homes(a4)		; Add this value to number of homes
	Lea	Home_Sfx,a6
	Bsr	Play_This_Sample		; Play homing missle SFX
	Move.w	(a0)+,d6
	Move.b	d6,Fire_Delay2(a3)		; Set fire delay
	Bra.s	SkipF				; Fireit
**********************************************************
Do_Fir2	
	Move.w	(a0)+,d6
	Move.b	d6,Fire_Delay2(a3)		; Set fire delay for rocket
	Lea	Rocket_Sfx,a6
	Bsr	Play_This_Sample		; Play the rocket sample
	Bra.s	SkipF
Do_Fir1	Move.w	(a0)+,d6
	Move.b	d6,Fire_Delay(a3)		; Set fire delay
Skipf	Move.w	Screenxoffset(a4),d6		; Offset into game area
	Addq.w	#8,d6				; Add 8 to align
.Loop	Tst.w	(a0)				; Script for missles to be fired,-1= no more
	Bmi.s	.Exit
	Bsr	Search_Shot_Table		; Search in table
	Move.b	(a0)+,(a2)+			; Damage
	Addq.l	#1,a0				; Skip null byte
	Clr.b	(a2)+
	Clr.w	(a2)+				; Clear this word, cant remember what it does
	Move.l	Shipxy(a3),(a2)+		; Save x/y cardinate
	Add.w	d6,-4(a2)			; Add to x coard
	Subq.w	#2,-2(a2)			; Add to y coard
	Tst.b	Weapon_In_Use(a3)
	Bne.s	.Not_Splatter			; Dont process if not splatter
	Cmp.b	#1,Weapon_Power(a3)
	Bne.s	.Not_Splatter
	Not.b	Splatter_Flag(a3)		; Double shot if power up 2
	Bne.s	.Add
	Subq.w	#8,-4(a2)
.Add	Addq.w	#4,-4(a2)
.Not_Splatter	
	Move.l	(a0)+,(a2)+
	Move.l	(a0)+,(a2)+			; Move rest of shit
	Bra.s	.Loop
.Exit	Rts
	
**********************************************************
Dead_Count_Dec
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst.b	Pause_Flag(a4)
	Bne.s	.Pos1				; Pause flag active, dont do
	Subq.b	#1,Dead_Count(a3)		; 1 from dead count
	Scc	d0	
	And.b	d0,Dead_Count(a3)		; Mask zero if carry was generated
.Pos1	Rts

**********************************************************
Chk_Speed
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
.Do	Tst_Act				; Test if we are active first
	Movem.w	X_Speed(a3),d0-d1	; Collect x/y Speed vectors
	Cmp.w	#-2,d0			; If >-2, Ok
	Bge.s	.Ok1
	Moveq	#-2,d0			; Else Fix it to -2
.Ok1	Cmp.w	#-2,d1
	Bge.s	.Ok2
	Moveq	#-2,d1
.Ok2	Cmp.w	#2,d0			; Do rest of checks for x/y vectors
	Ble.s	.Ok3
	Moveq	#2,d0
.Ok3	Cmp.w	#2,d1
	Ble.s	.Ok4
	Moveq	#2,d1
.Ok4	Movem.w	d0-d1,X_Speed(a3)	; resave the speed

	Sf	Second_Sprite_Player(a3) ; Use type 1 player sprite !
	Move.l	Player_Sprite_Base(a4),a0
	Eor.w	#$1,Anim_Toggle(a3)	; Anim toggle for boosters
	Move.w	Anim_Toggle(a3),d1
	Add.w	#98,d1			; Anim toggle in register, added with base
	Cmp.w	#-2,d0
	Bne.s	.Not_Left
	Addq.w	#2,d1			; Add 2 if vector is -2
.Not_Left
	Cmp.w	#2,d0
	Bne.s	.Not_Right
	Addq.w	#2,d1			; And also if vector is +2
.Not_Right
	Add.w	d1,d1			; Double up sprite number, for 16 byte index
	Move.w	Spr_Height(a0,d1*8),Boost_Anim_Size(a3)	
	Move.l	Spr_Addr(a0,d1*8),Boost_Anim_Addr(a3)	
	Move.l	Spr_Use(a0,d1*8),Boost_Ship_Offset(a3)	
	Addq.w	#2,d0				
	Cmp.l	#Pl1,a3
	Beq.s	.Pl1_Ok
	Add.w	#124,d0
.Pl1_Ok
	Tst.b	Flash_Mussle(a3)
	Beq.s	.No_Weapon		; Check for a mussle flash, None if 0
	Move.w	d0,d6			; X vector in d6
	Cmp.l	#Pl1,a3
	Beq.s	.Pl1_Okc
	Sub.w	#124,d6
.Pl1_Okc
	Add.w	#107,d6			; Add base of mussles
	Tst.b	Weapon_In_Use(a3)	; Test weapon in use, if 0 -Shot!
	Bne.s	.Do_Weapon		; Ok its a missle
	Subq.w	#5,d6			; 5 from sprite number (shot-sprites!)
.Do_Weapon
	Add.w	d6,d6			; Double up foer 16byte index
	Move.w	Spr_Height(a0,d6*8),Fire_Anim_Size(a3)	
	Move.l	Spr_Addr(a0,d6*8),Fire_Anim_Addr(a3)	
	Move.l	Spr_Use(a0,d6*8),Fire_Ship_Offset(a3)	
.No_Weapon
	Cmp.b	#2,Weapon_Power(a3)	; If weapon power >=2
	Blt.s	.Check2
	St	Second_Sprite_Player(a3) ; Use type 2 Player
	Cmp.l	#Pl1,a3
	Beq.s	.Pl1_Oka
	Addq.w	#5,d0	
	Bra.s	.Skip
.Pl1_Oka
	Add.w	#57,d0
	Bra.s	.Skip
.Check2	Cmp.b	#2,Weapon_Power2(a3)	; If weapon power >=2
	Blt.s	.Skip
	Cmp.l	#Pl1,a3
	Beq.s	.Pl1_Okb
	Addq.w	#5,d0	
	Bra.s	.Skip
.Pl1_Okb
	Add.w	#57,d0			; Use type 2 player
	St	Second_Sprite_Player(a3)
.Skip	Add.w	d0,d0			; Double up ready for 16byte index
	Move.w	Spr_Height(a0,d0*8),Anim_Size(a3)	
	Move.l	Spr_Addr(a0,d0*8),Anim_Addr(a3)	
	Move.l	Spr_Use(a0,d0*8),Ship_Offset(a3)	
	Rts

**********************************************************
Adj_Speed
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst_Act
	Tst_Startup			; Test if active and startup
	Tst.b	No_Move(a3)
	Beq.s	.Can_Move
	Clr.l	X_Speed(a3)		; Clear X vector/Y vector
	Rts	
.Can_Move
	Tst.b	Pause_Flag(a4)
	Bne.s	.Xit			; Pause flag acvtive, cant move !
	Movem.w	XDirection(a3),d0-d1	; Get left/right/up/down movement flags
	Movem.w	X_Speed(a3),d2-d3	; Speeds into d2-d3
	Tst.w	d0			; if 0, lower the x vector
	Beq.s	.Subxit				
	Add.w	d0,d2			; Else add direction to X vector	
.Ret1	Tst.w	d1			; if 0, lower the Y vector
	Beq.s	.Subyit				
	Add.w	d1,d3			; Else add direction to y vector
.Ret2	Movem.w	d2-d3,X_Speed(a3)	; Save speeds
.Xit	Rts

.Subyit	Tst.w	d3			; Test Y vector
	Beq.s	.Ret2			; If 0, no need to modify
	Bpl.s	.Pos2
	Addq.w	#2,d3			; Else bring it towards zero
.Pos2	Subq.w	#1,d3
	Bra.s	.Ret1	

.Subxit	Tst.w	d2			; Test Y vector
	Beq.s	.Ret1			; If 0, no need to modify	
	Bpl.s	.Pos1
	Addq.w	#2,d2			; Else bring it towards zero
.Pos1	Subq.w	#1,d2
	Bra.s	.Ret1	

**********************************************************
Check_Fire_Button
	Move.l	Player_Use(a4),a3
	Tst_Act
	Tst_Startup				; Cant process if not active or starting up
	Tst.b	Fire_Pressed_On_read(a3)	; Test if fire button pressed
	Sne	We_Have_Fired(a3)		; Set flag if it was pressed
	Clr.b	Fire_Pressed_On_Read(a3)	; Clear fire button pressed flag
	Rts

**********************************************************
Check_ship_bound
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Move.l	Player_Use(a4),a3
	Tst_Act
	Tst_Startup			; No bound checking if not active or doing startup
	Tst.b	No_Move(a3)
	Beq.s	.Yes			; Cant move, no need to move
	Clr.l	X_Speed(a3)		; And clear x/y vector
	Rts	
.Yes	Movem.w	Shipxy(a3),d0-d1
	Cmp.w	#-32,d0
	Bge.s	.X_Not_Left_Bound
	Moveq	#-32,d0
.X_Not_Left_Bound
	Cmp.w	#320,d0
	Ble.s	.X_Not_Right_Bound
	Move.w	#320,d0
.X_Not_Right_Bound
	Cmp.w	#40,d1
	Bge.s	.Y_Not_Up_Bound
	Moveq	#40,d1
.Y_Not_Up_Bound
	Cmp.w	#239-48,d1
	Ble.s	.Y_Not_Dn_Bound
	Move.w	#239-48,d1
.Y_Not_Dn_Bound
	Movem.w	d0-d1,Shipxy(a3)	; Resave coardinates
	Rts

**********************************************************
Move_ship
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst_Act
	Tst_Startup				; Cant move !
	Tst.b	Pause_Flag(a4)
	Bne.s	.No_Move
	Tst.b	No_Move(a3)
	Beq.s	.Can_Move				; No moving if Flag set !
	Clr.l	X_Speed(a3)			; Also clear X/Y Vectors
	Rts	
.Can_Move
	Movem.w	X_speed(a3),d0-d1		; Collect speed vectors
	Add.w	d0,ShipXY(a3)
	Add.w	d1,ShipXY+2(a3)			; Add to X/Y
.No_Move
	Rts

**********************************************************
Readjoy	
	Bsr	Read_Joypad			; read the falcon joypad
	Bsr	Readjoy1
	Bsr	Readjoy2
	Rts
Readjoy1
	Lea	Pl1,a3
	Tst.b	No_Move(a3)
	Beq.s	.Yes				; Cant move, dont need to check
	Clr.l	X_Speed(a3)
	Clr.l	XDirection(a3)			; Clear vector/direction
	Rts	
.Yes	Tst_Act
	Tst_Startup				; Dont do anything if not active or in startup-mode
	Movem.w	Clearr(a4),d6-d7		; Clear work registers
	Sf	Fire_Pressed_On_Read(a3)
	Sf	Bomb_Pressed_On_Read(a3)	; Clear fire/bomb button flags
	Tst.b	Pause_Flag(a4)
	Bne	.Ok2				; Pause flag pressed, dont process
	Bsr	Fire_A_Pressed			; If ya pressed A
	Seq	Fire_Pressed_On_Read(a3)	; Set this flag
	Bsr	Fire_B_Pressed
	Bne.s	.Not_B
	St	Fire_Pressed_On_Read(a3)	; Same for fire button B
.Not_B	Bsr	Fire_C_Pressed			; Fire button C used as a bomb button
	Seq	Bomb_Pressed_On_Read(a3)	; Set if pressed
	Bsr	direction_pressed		; Get direction buttons
	Btst	#2,d0
	Seq	d6
	Btst	#3,d0
	Bne.s	.Ok1
	Moveq	#1,d6
.Ok1	Btst	#0,d0				; d6/d7 corrosponds to x/y direction you pushed
	Seq	d7
	Btst	#1,d0
	Bne.s	.Ok2
	Moveq	#1,d7
.Ok2	Ext.w	d6
	Ext.w	d7				; Extend to 16 bits
	Movem.w	d6-d7,Xdirection(a3)		; Move in the 16bit flags

Readjoy2
	Lea	Pl2,a3
	Tst.b	No_Move(a3)
	Beq.s	.Yes				; Cant move, dont need to check
	Clr.l	X_Speed(a3)
	Clr.l	XDirection(a3)			; Clear vector/direction
	Rts	
.Yes	Tst_Act
	Tst_Startup				; Dont do anything if not active or in startup-mode
	Movem.w	Clearr(a4),d6-d7		; Clear work registers
	Sf	Fire_Pressed_On_Read(a3)
	Sf	Bomb_Pressed_On_Read(a3)	; Clear fire/bomb button flags
	Tst.b	Pause_Flag(a4)
	Bne	.Ok2				; Pause flag pressed, dont process
	Bsr	Fire_A_Pressed_2		; If ya pressed A
	Seq	Fire_Pressed_On_Read(a3)	; Set this flag
	Bsr	Fire_B_Pressed_2
	Bne.s	.Not_B
	St	Fire_Pressed_On_Read(a3)	; Same for fire button B
.Not_B	Bsr	Fire_C_Pressed_2		; Fire button C used as a bomb button
	Seq	Bomb_Pressed_On_Read(a3)	; Set if pressed
	Bsr	direction_pressed_2		; Get direction buttons
	Btst	#2,d0
	Seq	d6
	Btst	#3,d0
	Bne.s	.Ok1
	Moveq	#1,d6
.Ok1	Btst	#0,d0				; d6/d7 corrosponds to x/y direction you pushed
	Seq	d7
	Btst	#1,d0
	Bne.s	.Ok2
	Moveq	#1,d7
.Ok2	Ext.w	d6
	Ext.w	d7				; Extend to 16 bits
	Movem.w	d6-d7,Xdirection(a3)		; Move in the 16bit flags
	Rts

**********************************************************
Draw_Ship
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
.Do	Move.l	a3,Player_Use(a4)
	Move.l	Player_Use(a4),a3

	Tst.b	Dont_Draw_Ship(a4)
	Bne.s	.Exit				; Dont draw if this flag set
	Tst.b	Dead_Count(a3)
	Beq.s	.Ok_Print			; Only draw if this is zero
	Subq.b	#1,Flash_Count(a3)		; Else decrement it
	Btst	#3,Flash_Count(a3)		; and flash on/off every 8loops
	Beq.s	.Ok_Print
.Exit	Rts
.Ok_Print	
	Tst_Act					; Not active, dont draw
	Tst.b	Just_Dead(a3)
	Beq.s	.Print				; Just dead flag set, dont draw
	Rts
.Print	
	Tst.b	Flash_Mussle(a3)
	Beq.s	.No_Draw_Fire
	Clr.b	Flash_Mussle(a3)		; If we must draw the mussle, clear the flag
	Move.w	Shipxy(a3),d0			
	Add.w	Screenxoffset(a4),d0		
	Move.l	Fire_Anim_Addr(a3),a0		
	Move.w	Fire_Anim_Size(a3),d7		; Load in appropriate values for draw routine
	Move.l	Shipaddr(a3),a1			
	Bsr.s	.Draw_It			; Call the draw routine
.No_Draw_Fire
	Move.l	Player_Use(a4),a3
	Move.w	Shipxy(a3),d0			
	Add.w	Screenxoffset(a4),d0		
	Move.l	Boost_Anim_Addr(a3),a0		; Draw the boost in any case !
	Move.w	Boost_Anim_Size(a3),d7		
	Move.l	Shipaddr(a3),a1			
	Lea	Byteswide*28(a1),a1		
	Tst.b	Second_Sprite_Player(a3)	; If drawing type 2 sprite
	Beq.s	.Nope
	Lea	Byteswide*2(a1),a1		; Increment destination address by 2 lines
.Nope	Bsr.s	.Draw_It
	Move.l	Player_Use(a4),a3
	Move.w	Shipxy(a3),d0			
	Add.w	Screenxoffset(a4),d0		
	Move.l	Anim_Addr(a3),a0		
	Move.w	Anim_Size(a3),d7		
	Move.l	Shipaddr(a3),a1			
	Lea	Byteswide*5(a1),a1		; And finally draw the player ship
	Bsr.s	.Draw_It
	Rts
;FALCON SPECIFIC DRAW ROUTINE, DO I HAVE TO FUCKIN EXPLAIN THIS
;ALL IT DOES IS DRAW A SPRITE !!!
;MAY BE INTERESTED IN SOME PARAMETERS
;D0=X COARDINATE
;A0=ADDRESS OF BASE SPRITE
;D7=HEIGHT OF SPITE (ASSUMES THE WIDTH TO BE 32)
;A1=POINTS TO DRAW BUFFR
.Draw_It
	Subq.w	#1,d7
	Bmi	.Error				
	And.w	#$f,d0
	Lea	16(a1),a2			
	Lea	16(a2),a3			
	Move.l	#Byteswide-8,d6			
.loop	Moveq	#-1,d1
	Moveq	#-1,d2				
	Move.w	(a0)+,d1			
	Lea	8(a0),a4			
	Move.w	(a4)+,d2			
	Ror.l	d0,d1
	Ror.l	d0,d2				
	Move.l	a1,a6				
	Cmp.w	#-1,d1
	Beq.s	.Nmsk1
	And.w	d1,(a6)+
	And.w	d1,(a6)+
	And.w	d1,(a6)+
	And.w	d1,(a6)+
	Not.w	d1
	Or.w	d1,(a6)+
	Or.w	d1,(a6)+
	Or.w	d1,(a6)+
	Or.w	d1,(a6)+
	Bra.s	.Nmsk1+4
.Nmsk1	Lea	16(a6),a6
	Swap	d1				
	And.w	d1,d2
	Cmp.w	#-1,d2
	Beq.s	.Nmsk2
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	Not.w	d2
	Or.w	d2,(a6)+
	Or.w	d2,(a6)+
	Or.w	d2,(a6)+
	Or.w	d2,(a6)+
	Bra.s	.Nmsk2+4
.Nmsk2	Lea	16(a6),a6
	Swap	d2
	Cmp.w	#-1,d2
	Beq.s	.Nmsk3
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	And.w	d2,(a6)+
	Not.w	d2
	Or.w	d2,(a6)+
	Or.w	d2,(a6)+
	Or.w	d2,(a6)+
	Or.w	d2,(a6)+
	Bra.s	.Nmsk3+4
.Nmsk3	Lea	16(a6),a6
	
	Rept	4
	Moveq	#0,d1
	Moveq	#0,d2
	Move.w	(a0)+,d1
	Move.w	(a4)+,d2
	Ror.l	d0,d1
	Ror.l	d0,d2
	Or.w	d1,(a1)+			
	Swap	d1
	Or.w	d1,d2
	Or.w	d2,(a2)+
	Swap	d2
	Or.w	d2,(a3)+
	Endr
	Move.l	a4,a0
	Add.l	d6,a1
	Add.l	d6,a2
	Add.l	d6,a3				; Add screen modulo !
	Dbra	d7,.loop			; All rows
	Lea	Data(pc),a4			; Fix data !
.Error	rts
	
**********************************************************
Saveshipback
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3
	
	
.Do	Tst.b	Just_Dead(a3)			; Only save background if this is zero
	Beq.s	.Print
	Rts
.Print	Tst.w	Ship_Explosion_Num(a3)		; And only if this is positive
	Bpl.s	.Ok
	Rts
.Ok	Movem.w	Shipxy(a3),d0-d1
	Add.l	Ship_Offset(a3),d1		; Get x/y coards and add offset
	Mulu	#Byteswide,d1			; Get screen line
	Add.w	ScreenXoffset(a4),d0
	And.w	#$fff0,d0
	Ext.l	d0
	Add.l	d0,d1
	Add.l	Realscreenp(a4),d1
	Move.l	d1,a0				; Get the address on screen in a0
	Lea	Shipbuffer(a3),a1		; Pointer to background buffer
	Move.l	a0,(a1)+			; Save on backghround buffer
	Move.w	Anim_Size(a3),d7
	Add.w	#9,d7				; Save an extra 9 pixles, due to boosts/mussle
	Move.w	d7,(a1)+			; Save height
.No	Move.l	a0,Shipaddr(a3)			; This address is used as a base for drawing routine for player sprite
.Loop	Movem.l	(a0),d0-d6/a2-a6		; Collect background bitmap (48 pixels)
	Movem.l	d0-d6/a2-a6,(a1)		; Save it
	Lea	Byteswide(a0),a0		; Next line
	Lea	48(a1),a1			; Next lot of save buffer
	Dbra	d7,.Loop			; All lines
	Lea	Data(pc),a4			; Data pointer loaded
	Rts
		
**********************************************************
Restoreshipback
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Lea	Shipbuffer(a3),a0	
	Tst.b	(a0)
	Bmi.s	.Exit
	Move.l	(a0)+,a1		; Address to restore to
	Move.w	(a0)+,d7		; Size in d7
	St	-6(a0)			; Set for no restore
	Subq.w	#1,d7			; For DBRA loop
.Loop	Movem.l	(a0)+,d0-d6/a2-a6	; Collect saved bitmap
	Movem.l	d0-d6/a2-a6,(a1)	; Print it back to screen
	Lea	Byteswide(a1),a1	; Next line
	Dbra	d7,.Loop		; All lines
	Lea	Data(pc),a4		; Global variable space
.Exit	Rts

**********************************************************
Wait_For_100
	Tst.b	Pause_Flag(a4)
	Bne.s	.No			; Dont check if paused
	Lea	Pl1,a3
	Bsr.s	.Do
	Lea	Pl2,a3

.Do	Tst_Act				; Test if active
	Tst.b	Startup(a3)		; If not starting up, dont do !
	Beq.s	.No
	Subq.w	#1,Shipxy+2(a3)		; 1 from y value of ship
	Cmp.w	#120,Shipxy+2(a3)	; Wait for this line (hmmm its not 100, not important ! dont fucking panic!)
	Sne	Startup(a3)		; Still in startup if not equal
.No	Rts

**********************************************************
Setmode	Tst.b	$7c.w			; Running on NTSC system ?
	Beq.s	.NTSC			; Yes
	Or.b	#$20,d0			; Set PAL bit
.NTSC	Move.w	d0,-(sp)		; Save modecode
	Move.w	#88,-(sp)		; Call setmode
	Trap	#14			; Call it ! (BIOS CALL!-Falcon is a heap of BBAABBAA!)
	Addq.l	#4,sp			; Align stack
	Move.w	d0,Old_Mode(a4)		; Save the old mode!
	rts
	
*********************************************************

**********************************************************
Weapon_Jump_Table
	Bra.s	.Twin_Shot
	Bra.s	.Big_Fuck_Off_Blaster
	Bra.s	.Special_Spit			; Jump to appropriate routine for weapon in use
	Bra.s	.Sidewinder
	Bra.s	.Homing_Missle

.Special_Spit
	Jmp	.Do_Special(pc)
	
.Sidewinder
	Lea	.Sw(pc),a0
	Jmp	(a0,d3*8)
.Homing_Missle
	Lea	.Hm(pc),a0
	Jmp	(a0,d3*8)
.Big_Fuck_Off_Blaster
	Lea	.Bl(pC),a0
	Jmp	(a0,d3*8)			; Jump to appropriate routine for power-up value
.Twin_Shot
	Lea	.Ts(pc),a0
	Jmp	(a0,d3*8)

.Spc	Dc.w	10
	Wep_Ent	3,0,0,22,0,0,0

.Ts	Lea	.Tst1(pc),a0
	Bra	Do_Fir1
	Lea	.Tst2(pc),a0
	Bra	Do_Fir1
	Lea	.Tst3(pc),a0
	Bra	Do_Fir1
	Lea	.Tst4(pc),a0
	Bra	Do_Fir1
	Lea	.Tst5(pc),a0
	Bra	Do_Fir1
.Bl	Lea	.Blt1(pc),a0
	Bra	Do_Fir1
	Lea	.Blt2(pc),a0
	Bra	Do_Fir1
	Lea	.Blt3(pc),a0
	Bra	Do_Fir1
	Lea	.Blt4(pc),a0
	Bra	Do_Fir1
	Lea	.Blt5(pc),a0
	Bra	Do_Fir1
.Sw	Lea	.Swt1(pc),a0
	Bra	Do_Fir2
	Lea	.Swt2(pc),a0
	Bra	Do_Fir2
	Lea	.Swt3(pc),a0
	Bra	Do_Fir2
	Lea	.Swt4(pc),a0
	Bra	Do_Fir2
	Lea	.Swt5(pc),a0
	Bra	Do_Fir2
.Hm	Lea	.Hmt1(pc),a0
	Bra	Do_Fir3
	Lea	.Hmt2(pc),a0
	Bra	Do_Fir3
	Lea	.Hmt3(pc),a0
	Bra	Do_Fir3
	Lea	.Hmt4(pc),a0
	Bra	Do_Fir3
	Lea	.Hmt5(pc),a0
	Bra	Do_Fir3

.Tst1	Dc.w	15				; DELAY
	Wep_Ent	1,0,-11,0,0,0,0			; X/Y Modifier !
	Dc.w	-1
.Tst2	Dc.w	15
	Wep_Ent	1,0,-11,0,0,0,0
	Wep_Ent	1,0,-11,0,0,0,0
	Dc.w	-1
.Tst3	Dc.w	15
	Wep_Ent	1,0,-11,0,0,0,0
	Wep_Ent	1,-3,-10,1,0,0,0
	Wep_Ent	1,+3,-10,3,0,0,0
	Dc.w	-1
.Tst4	Dc.w	15
	Wep_Ent	1,0,-11,0,0,0,0
	Wep_Ent	1,-3,-10,1,0,0,0
	Wep_Ent	1,+3,-10,3,0,0,0
	Wep_Ent	1,-5,-08,2,0,0,0
	Wep_Ent	1,+5,-08,4,0,0,0
	Dc.w	-1
.Tst5	Dc.w	15
	Wep_Ent	1,0,-11,0,0,0,0
	Wep_Ent	1,-3,-10,1,0,0,0
	Wep_Ent	1,+3,-10,3,0,0,0
	Wep_Ent	1,-5,-08,2,0,0,0
	Wep_Ent	1,+5,-08,4,0,0,0
	Wep_Ent	1,-7,-07,5,0,0,0
	Wep_Ent	1,+7,-07,6,0,0,0
	Dc.w	-1
.Swt1	Dc.w	35			; Delay for fire !
	Wep_Ent	3,-1,-1,12,0,12,10	; Damage/x modifier/y mod/Anmset/Sine val/Scale/Speed
	Wep_Ent	3,+1,-1,12,0,12,10
	Dc.w	-1
.Swt2	Dc.w	35
	Wep_Ent	3,-1,-1,13,0,12,10
	Wep_Ent	3,+1,-1,13,0,12,10
	Wep_Ent	3,+0,-1,13,0,12,10
	Dc.w	-1
.Swt3	Dc.w	35
	Wep_Ent	4,-2,-1,14,0,14,10	; Damage/x modifier/y mod/Anmset/Sine val/Scale/Speed
	Wep_Ent	4,+2,-1,14,0,14,10
	Wep_Ent	4,-1,-1,14,0,12,10
	Wep_Ent	4,+1,-1,14,0,12,10
	Dc.w	-1
.Swt4	Dc.w	30
	Wep_Ent	5,-2,-1,15,0,18,10	; Damage/x modifier/y mod/Anmset/Sine val/Scale/Speed
	Wep_Ent	5,+2,-1,15,0,18,10
	Wep_Ent	5,-1,-1,15,0,15,10
	Wep_Ent	5,+1,-1,15,0,15,10
	Dc.w	-1
.Swt5	Dc.w	35
	Wep_Ent	6,-2,-1,16,0,18,10	; Damage/x modifier/y mod/Anmset/Sine val/Scale/Speed
	Wep_Ent	6,+2,-1,16,0,18,10
	Wep_Ent	6,-1,-1,16,0,15,10
	Wep_Ent	6,+1,-1,16,0,15,10
	Wep_Ent	6,-3,-1,16,0,20,10
	Wep_Ent	6,+3,-1,16,0,20,10
	Dc.w	-1


.Hmt1	Dc.w	4			; Number of homes !
	Dc.w	30
	Wep_Ent	2,$e0,12,17,0,0,0	; dmg/Angle/Scale/Animation sequence
	Wep_Ent	2,$20,12,17,0,0,0
	Dc.w	-1
.Hmt2	Dc.w	4			; Number of homes !
	Dc.w	30
	Wep_Ent	2,$c0,14,18,0,0,0	; Angle/Scale value !
	Wep_Ent	2,$f0,14,18,0,0,0
	Wep_Ent	2,$10,14,18,0,0,0
	Wep_Ent	2,$40,14,18,0,0,0
	Dc.w	-1
.Hmt3	Dc.w	6
	Dc.w	40
	Wep_Ent	3,$c0,16,19,0,0,0	; Angle/Scale value !
	Wep_Ent	3,$f0,16,19,0,0,0
	Wep_Ent	3,$10,16,19,0,0,0
	Wep_Ent	3,$40,16,19,0,0,0
	Wep_Ent	3,$e0,16,19,0,0,0
	Wep_Ent	3,$20,16,19,0,0,0
	Dc.w	-1
.Hmt4	Dc.w	8
	Dc.w	25
	Wep_Ent	3,$c0,18,20,0,0,0	; Angle/Scale value !
	Wep_Ent	3,$f0,18,20,0,0,0
	Wep_Ent	3,$10,18,20,0,0,0
	Wep_Ent	3,$40,18,20,0,0,0
	Dc.w	-1
.Hmt5	Dc.w	8
	Dc.w	50
	Wep_Ent	4,$c0,20,21,0,0,0	; Angle/Scale value !
	Wep_Ent	4,$f0,20,21,0,0,0
	Wep_Ent	4,$10,20,21,0,0,0
	Wep_Ent	4,$40,20,21,0,0,0
	Wep_Ent	4,$e0,20,21,0,0,0
	Wep_Ent	4,$20,20,21,0,0,0
	Wep_Ent	4,$30,20,21,0,0,0
	Wep_Ent	4,$d0,20,21,0,0,0
	Dc.w	-1

.Blt1	Dc.w	8
	Wep_Ent	2,0,-14,7,0,0,0
	Dc.w	-1
.Blt2	Dc.w	8
	Wep_Ent	3,0,-14,8,0,0,0
	Dc.w	-1
.Blt3	Dc.w	7
	Wep_Ent	5,0,-14,9,0,0,0
	Dc.w	-1
.Blt4	Dc.w	6
	Wep_Ent	6,0,-14,10,0,0,0
	Dc.w	-1
.Blt5	Dc.w	5
	Wep_Ent	7,0,-14,11,0,0,0
	Dc.w	-1

.Do_Special
	Lea	.Spc(pc),a0
	Push
	Move.w	Seed(a4),d7
	Mulu	#16,d7
	Swap	d7
	Lea	Spit_Out_Use_Tab(a4),a1
	Moveq	#15,d2
.Sloop	Tst.b	(a1,d7)
	Beq.s	.Okf
	Addq.w	#1,d7
	And.w	#$f,d7
.No_Mask	
	Dbra	d2,.Sloop
	Clr.l	(a1)
	Clr.l	4(a1)
	Clr.l	8(a1)
	Clr.l	12(a1)
	
.Okf	St	(a1,d7)
	Lea	Vectortab(pc),a6
	Move.w	$0(a6,d7*4),d0
	Move.w	$2(a6,d7*4),d1
	Muls	#2,d0
	Muls	#2,d1
	Movem.w	d0-d1,4(a0)	
	Bsr	Seed_Rand
	Pull
	Bra	Do_Fir1

****************************************************************************
	Include	Dataz.S
		

; RAIDEN LIST,DATA AND CODE MACROS

Pal_Add		Equ		48
;-----------------
; RELATIVE X-ADD, RELATIVE Y-ADD, NUMBER OF GAME LOOPS
Abs_Move Macro
	Dc.w	0
	Dc.w	\1,\2,\3		
	Endm
;-----------------
; INITIAL SINE VALUE, SINE SPEED (left right), SCALE FOR SINE,
; X/Y RELATIVE, NUMBER OF GAME LOOPS
Sine_Lr	Macro
	Dc.w	$1
	Dc.w	\1,\2,\3,\4,\5,\6	; Sine speed/scale/x/y add
	Endm
;-----------------
; INITIAL SINE VALUE, SINE SPEED (up down), SCALE FOR SINE,
; X/Y RELATIVE, NUMBER OF GAME LOOPS

Sine_Ud	Macro
	Dc.w	$2
	Dc.w	\1,\2,\3,\4,\5,\6	
	Endm
;-----------------
; INITIAL SINE VALUE, SINE SPEED (left right), SCALE FOR SINE,
; X/Y RELATIVE, NUMBER OF GAME LOOPS (uses first 180 degrees of sine table)

X_Swoop	Macro
	Dc.w	$3
	Dc.w	\1,\2,\3,\4,\5,\6	; Sine speed/scale/x/y
	Endm
;-----------------
; INITIAL SINE VALUE, SINE SPEED (up down), SCALE FOR SINE,
; X/Y RELATIVE, NUMBER OF GAME LOOPS (uses first 180 degrees of sine table)

Y_Swoop	Macro
	Dc.w	$4
	Dc.w	\1,\2,\3,\4,\5,\6	; Sine Start/Sine speed/scale/x/y/Seqdec
	Endm

;-----------------
; Repeat number of times, address to repeat (terminated with Repend)

Rep	Macro
	Dc.w	$5
	Dc.w	\1			
	Endm	
;-----------------
; All REP blocks are terminated with this
Repend	Macro
	Dc.w	$6			
	Endm

;-----------------
; Gosubroutine (ADDRESS OF SUBROUTINE) (terminate with RETURN
Gosub	Macro
	Dc.w	$7			
	Dc.l	\1			
	Endm
;-----------------
; All GOSUB blocks are terminated with this

Return	Macro
	Dc.w	$8
	Endm
;-----------------
; change sequence pointer to ADDRESS

Branch	Macro
	Dc.w	$9
	Dc.l	\1
	Endm
;-----------------
; Fire weapon TYPE n
Fire_Ship Macro
	Dc.w	$a
	Dc.w	\1
	Endm
;-----------------
; Kills sprite from sprite list
End_Seq	Macro
	Dc.w	$b
	Endm
;-----------------
; NO NEED TO WORRY ABOUT THIS !!!!! ONLY USED FOR POWER-UP-SHIPS
; IMPLEMENTED IN CODE !!!!!

Sine_It	Macro
	Dc.w	$c
	Dc.w	\1,\2,\3,\4,\5,\6,\7,\8,\9
	Endm
;-----------------
; INITIAL VALUE ($7FFF - ASUME INTIAIL VALUE),
; ANGLE ,ADD, SCALE, NUMBER OF FRAMES

Vector_Move Macro
	Dc.w	$d
	Dc.w	\1,\2,\3,\4
	Endm
;-----------------
; Change "ANGLE" of sprite to match coardinates of player, other
; a NUMBER OF LOOPS

Track	Macro
	Dc.w	$e
	Dc.w	\1
	Endm
;-----------------
; NOT NEEDED !!
Bounce_Move	Macro
	Dc.w	$f
	Dc.w	\1,\2
	Endm
;-----------------
; NOT NEEDED, IMPLEMENTED IN CODE !!!!
Move_Center	Macro
	Dc.w	$10
	Endm
;-----------------
; DO NOTHING !?!?!?!

Noop	Macro
	Dc.w	$11
	Endm

;-----------------
; NOT USED ANYMORE !
Release_Power Macro
	Dc.w	$12
	Endm
;-----------------
; SCALE , NUMBER OF FRAMES
Zoom_Into Macro
	Dc.w	$13
	Dc.w	\1,\2
	Endm
;-----------------
; START SCROLLING MAP
Start_Scrolling	Macro
	Dc.w	$14
	Endm
;-----------------
; STOP SCROLLING MAP
Stop_Scrolling	Macro
	Dc.w	$15
	Endm
;-----------------
; MACRO USED FOR LEVEL 2 END - LEVEL BADIE (SPITS OUT ALIENS!) 
;Spit_Out	Macro
;	Dc.w	$16
;	Endm
;-----------------
; IMPLEMENTED IN CODE !!! DO NOT USE !!!
Spit_Home	Macro
	Dc.w	$17
	Endm
;-----------------
; Start operating middle second level baddie
Start_Mid_Tank	Macro
	Dc.w	$18
	Endm

;-----------------
; Macro to change the power-up ship linked sprites
Change_Power_Up_Ship_Anim	Macro
	Dc.w	$19
	Endm

;-----------------
; Tween between one vector move and another, Next value is not used, 
; just to compat with Marvs Attack wave editor
Tween	Macro
	Dc.w	$1a		
	Dc.w	\1
	Endm

;-----------------
; Macro to make plane home into player !
Plane_Zoom	Macro
	Dc.w	$1b		
	Endm

;-----------------
; Macro to make plane home into player !
Accelerate_Towards_Ship	Macro
	Dc.w	$1c		
	Endm

;-----------------
Stop_Anim	Macro
	Dc.w	$1d
	Endm
;-----------------
One_Shot_Anim	Macro
	Dc.w	$1e
	Endm

;-----------------
Start_Anim	Macro
	Dc.w	$1f
	Endm

;-----------------
Animate_Only_If_Moving	Macro
	Dc.w	$20
	Endm

;-----------------
Open_Hover	Macro
	Dc.w	$21
	Endm
;-----------------
Close_Hover	Macro
	Dc.w	$22
	Endm

;-----------------
Guardian2_Reached_Center	Macro
	Dc.w	$23
	Endm

;-----------------
Pause_Anim		Macro
	Dc.w	$24
	Endm

;-----------------
UnPause_Anim		Macro
	Dc.w	$25
	Endm

;-----------------
Wait			Macro
	Dc.w	$26
	Dc.w	\1
	Endm

;-----------------
Change_Anim		Macro
	Dc.w	$27
	Dc.w	\1
	Endm

;-----------------
Check_Screen_Bound	Macro
	Dc.w	$28
	Endm

;-----------------
; Overides hit flags
; 0 - Cant hit
; 1 - Can hit, default 1!

Hit	Macro
	Dc.w	$29
	Dc.w	\1
	Endm

;-----------------
Set_Guardian_Delay	Macro
	Dc.w	$2a
	Dc.w	\1
	Endm
	
;-----------------
Add_Guardians		Macro
	Dc.w	$2b
	Endm

;-----------------
Tank_Tween_Up		Macro
	Dc.w	$2c
	Endm

;-----------------
Tank_Tween_Left	Macro
	Dc.w	$2d
	Endm


;-----------------
Wait_Anim	Macro
	Dc.w	$2e
	Dc.w	\1
	Endm
;-----------------


Check_Y_Bound	Macro
	Dc.w	$2f
	Endm

;-----------------
Pause_Link_Anim	Macro
	Dc.w	$30
	Dc.w	\1
	Endm

;-----------------
UnPause_Link_Anim	Macro
	Dc.w	$31
	Dc.w	\1
	Endm
;-----------------

Change_Link_Anim	Macro
	Dc.w	$32
	Dc.w	\1		; Link number
	Dc.w	\2		; Anim set !
	Endm
	
;-----------------
	
Arrow_Home	Macro	; Home for 2nd level baddy arrows !
	Dc.w	$33
	Dc.w	\1,\2
	Endm
	
;-----------------
Paralax_Vector_Move	Macro	; Home for 2nd level baddy arrows !
	Dc.w	$34
	Dc.w	\1,\2,\3,\4
	Endm

;-----------------
Set_Angle		Macro
	Dc.w	$35
	Dc.w	\1
	Endm

;-----------------
Wait_Link_Anim		Macro
	Dc.w	$36
	Dc.w	\1			; Frame to wait
	Dc.w	\2			; Link number
	Endm

;-----------------
Check_An_Anim_And_Branch_IfNE		Macro
	Dc.w	$37
	Dc.w	\1			; Anim number
	Dc.l	\2			; Branch !
	Endm

;-----------------
;-----------------
Add_Train	Macro
	Dc.w	$38
	Endm

;-----------------
Change_Child_Offset	Macro
	Dc.w	$39
	Dc.w	\1,\2,\3
	Endm

;-----------------
Stop_Link_Anim	Macro
	Dc.w	$3a
	Dc.w	\1
	Endm

;-----------------
Move_Child	Macro
	Dc.w	$3b
	Dc.w	\1,\2,\3
	Endm

;-----------------
Start_Link_Anim	Macro
	Dc.w	$3c
	Dc.w	\1
	Endm

;-----------------
Add_Power_Up	Macro
	Dc.w	$3d
	Dc.w	\1
	Endm

;-----------------
Wings_Out_Level_5	Macro
	Dc.w	$3e
	Endm

;-----------------
Change_Seq	Macro
	Dc.w	$3f
	Dc.w	\1
	Dc.l	\2
	Endm

;-----------------
Change_Prev_Anim	Macro
	Dc.w	$40
	Dc.w	\1
	Dc.w	\2
	Endm

;-----------------
Legs_Up_Shadow_Out	Macro
	Dc.w	$41
	Endm

;-----------------
Pause_Multiple_Link_Anim	Macro
	Dc.w	$42
	Endm

;-----------------
unPause_Multiple_Link_Anim	Macro
	Dc.w	$43
	Endm

;-----------------
Set_Relative_Base	Macro
	Dc.w	$44
	Endm

;-----------------
Add_Spider		Macro
	Dc.w	$45
	Endm
;-----------------
Move_Relative		Macro
	Dc.w	$46
	Dc.w	\1,\2,\3
	Endm
;-----------------
Attach_Child		Macro
	Dc.w	$47
	Dc.w	\1,\2
	Endm

;-----------------
Set_Hp	Macro
	Dc.w	$48
	Dc.w	\1
	Endm
;-----------------
Add_Angle	Macro
	Dc.w	$49
	Dc.w	\1
	Endm

;-----------------
Set_Destruct	Macro
	Dc.w	$4a
	Dc.w	\1
	Endm

;-----------------
Two_Player	Macro
	Dc.w	$4b
	Endm
;-----------------
Bomb8OFF	Macro
	Dc.w	$4c
	Endm



;-----------------
Check_Guardian_4_Mad	Macro
	Dc.w	$4d
	Endm

;-----------------
Pal_Test	Macro
	Dc.w	$4e
	Endm

;-----------------
Ntsc_Test	Macro
	Dc.w	$4f
	Endm

;-----------------
; MAP ENTRY MACRO
; NUMBER OF HITPOINTS,ANIMSET,XCOARD/YCOARD RELATIVE TO SCREEN,SEQUENCE-POINTER

V_Ent	Macro
	Dc.w	\1,\2
	Dc.w	\3,\4			
	Dc.l	\5
	Endm
;-----------------
Wep_Ent	Macro
	Dc.b	\1,0			; Damage
	Dc.w	\2,\3			; x/y vector
	Dc.b	\4,\5,\6,\7		; Weapon num/sineval/scale/speed
	Dc.w	\8			; Anim done when weaon hits something, ITS A KIND OF EXPLOSION
	Endm
;-----------------
; Save all registers to stack
Push	Macro
	Movem.l	d0-a6,-(sp)
	Endm

;-----------------
; Restore all registers from stack
Pull	Macro
	Movem.l	(sp)+,d0-a6
	Endm

;-----------------
; Exchange 2 memory locations (used for screen swaps, etc)
Swapem	Macro
	Movem.l	\1,d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,\1
	Endm
;-----------------
; Check if player is active ($6602-BNE.S +2BYTES)
Tst_Act	Macro
	Tst.b	Player_Active(a3)
	Dc.w	$6602
	Rts
	Endm
;-----------------
; Check if player is in startup mode ($6702-BEQ.S +2BYTES)
Tst_Startup	Macro
	Tst.b	Startup(a3)
	Dc.w	$6702
	Rts
	Endm
	
;-----------------
; Explosion & Crator offset macro
; REPEATE/X/Y OFFSET
Excrt	Macro
	Rept	\1
	Dc.b	\2,\3
	Endr
	Endm

;-----------------
PHRASE_IT	Macro
	Move.l	\1,d0
	And.l	#-8,d0
	Move.l	d0,\2
	Endm

;-----------------
Pal_Add_Center	Macro
		Tst.b	Ntsc_Flag(a4)
		Bne.s	.\@1			; Ntsc screen
		Add.w	#Pal_Center,d1
.\@1		
		Endm

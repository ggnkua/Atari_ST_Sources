; RAIDEN LIST,DATA AND CODE MACROS

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
	Dc.w	\1,\2,\3,\4,\5,\6	; Sine speed/scale/x/y
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
	Dc.l	\2			
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
; ANGLE ADD, SCALE, NUMBER OF FRAMES

Vector_Move Macro
	Dc.w	$d
	Dc.w	\1,\2,\3,\4
	Endm
;-----------------
; Change "ANGLE" of sprite to match coardinates of player

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
Spit_Out	Macro
	Dc.w	$16
	Endm
;-----------------
; IMPLEMENTED IN CODE !!! DO NOT USE !!!
Spit_Home	Macro
	Dc.w	$17
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
S_Ent	Macro
	Dc.w	\1
	Bra	\2			
	Endm
;-----------------
KKK	Macro
	Dc.b	\1,\2,\3,0
	Dc.l	\4
	Endm	
;-----------------
Wep_Ent	Macro
	Dc.b	\1,0			; Damage
	Dc.w	\2,\3			; x/y vector
	Dc.b	\4,\5,\6,\7		; Weapon num/sineval/scale/speed
	Endm
;-----------------

Push	Macro
	Movem.l	d0-a6,-(sp)
	Endm

Pull	Macro
	Movem.l	(sp)+,d0-a6
	Endm

Swapem	Macro
	Movem.l	\1,d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,\1
	Endm

Tst_Act	Macro
	Tst.b	Player_Active(a3)
	Dc.w	$6602
	Rts
	Endm

Tst_Startup	Macro
	Tst.b	Startup(a3)
	Dc.w	$6702
	Rts
	Endm

PlaneDraw	Macro	
	Lsr.w	#1,d6
	Dc.w	$6408
	Not.w	\1
	Or.w	\1,(a6)+
	Not.w	\1
	Dc.w	$6002
	And.w	\1,(a6)+
	Endm

P_Add	Macro
	Move.w	d0,d2
	Move.w	d1,d3
	Add.w	#\1,d2
	Add.w	#\2,d3
	Movem.w	d2-d3,Aln_X\3
	Endm

Lnlst	Macro
	Dc.w	\1
	Dc.l	\2
	Endm
	
Nibble_Add	Macro
	Dc.b	\1<<4!\2
	Endm

Compare_Sidewinder	Macro
	Cmp.b	#\1,d6
	Beq.s	.SideWinder
	Endm

Load_Lev	Macro
	Lea	\1(pc),a0
	Lea	\2,a1
	Bsr	Load_Level_File
	Endm
	
Load_Tb	Macro
	Move.l	#\1+Data,\2(a4)
	Endm
Kill_Tb	Macro
	Move.l	\1(a4),a0
	St	(a0)
	Endm
	
Excrt	Macro
	Rept	\1
	Dc.b	\2,\3
	Endr
	Endm
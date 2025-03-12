COMMAND_TICKS0	EQU	4000/10
COMMAND_TICKS1	EQU	6000/10

COMMAND_TICKS2	EQU	2000/10
COMMAND_TICKS3	EQU	2000/10

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

command_init0:	move.w	#69,d0				; dst focus x
		move.w	#95,d1				; dst focus y
		move.w	#486,d2				; dst focus z
		move.w	#COMMAND_TICKS0,d3
		bsr.w	camera_init_rolling
		rts
		
command_init1:	move.w	#20,d0				; dst focus x
		move.w	#55,d1				; dst focus y
		move.w	#153,d2				; dst focus z
		move.w	#COMMAND_TICKS1,d3
		bsr.w	camera_init_rolling
		rts
		
command_init2:	move.w	#75,d0				; dst focus x
		move.w	#13,d1				; dst focus y
		move.w	#-57,d2				; dst focus z
		move.w	#COMMAND_TICKS2,d3
		bsr.w	camera_init_rolling
		rts
		
command_init3:	move.w	#35,d0				; dst focus x
		move.w	#13,d1				; dst focus y
		move.w	#52,d2				; dst focus z
		move.w	#COMMAND_TICKS3,d3
		bsr.w	camera_init_rolling
		rts
		
; ------------------------------------------------------
		SECTION	DATA
; ------------------------------------------------------

; dc.l	starting_tick, ticks, command

trajectory0_commands:
		dc.l	7000/10,1,command_init0
		dc.l	7000/10+1,COMMAND_TICKS0,camera_interpolate
		dc.l	28000/10,1,command_init1
		dc.l	28000/10+1,COMMAND_TICKS1,camera_interpolate
		dc.l	-1				; end of list

trajectory1_commands:
		dc.l	0,-1,dummy
		dc.l	-1				; end of list
		
trajectory2_commands:
		dc.l	0,-1,dummy
		dc.l	-1				; end of list
		
trajectory3_commands:
		dc.l	0,-1,dummy
		dc.l	-1				; end of list

trajectory4_commands:
		dc.l	0,-1,dummy
		dc.l	-1				; end of list

trajectory5_commands:
		dc.l	0,-1,dummy
		dc.l	-1				; end of list
		
trajectory6_commands:
		dc.l	0,-1,dummy
		dc.l	-1				; end of list

trajectory7_commands:
		dc.l	1500/10,1,command_init2
		dc.l	1500/10+1,COMMAND_TICKS2,camera_interpolate
		dc.l	4500/10,1,command_init3
		dc.l	4500/10+1,COMMAND_TICKS3,camera_interpolate
		dc.l	-1				; end of list

; ------------------------------------------------------
		SECTION	TEXT
; ------------------------------------------------------

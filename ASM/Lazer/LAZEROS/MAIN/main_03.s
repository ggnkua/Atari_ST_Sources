;--------------------------------------------------------
;           Multitasking Demo-operating-system
;           (c) 1995: Lazer / The Independent
;                              
;
;	Main coding: 		Photon
;	Additional coding: 	Energizer
;
; This source may only be used in non-commercial stuff.
; In case of commercial use contact:
; (Or in case you have questions)
; 
; Photon (Gerhard Seiler)
;                               gerhard.seiler@teleweb.at
; Energizer (Harald Riegler): 
;                             e9327376@stud1.tuwien.ac.at
;--------------------------------------------------------

;          READ THIS STUFF BEFORE STARTING!!!!

;--------------------------------------------------------
; 	This source was programmed using Devpac 3.   
;	I don't think this source will assemble to well
;	with Turboass, but if you've been using that one
;       then this is a opportunity to change to somthing
;	powerful now ;-). Who needs a debugger anyway...
;	(Do some clean coding and you won't need it - 
;	Hi Innovator, Lucky, pun intended!... hehe ;-))) )
;--------------------------------------------------------

;--------------------------------------------------------
; 	This is the demo-OS used in Lostblubb, demonstrated
;	with the dba intro for easier understanding.
;	Don't find it disturbing if this intro isn't exactly
;	the release version, I believe the finished version
;	got lost somewhere. So if the dister at the end doesn't
;	appear, that's ok, it's not here... ;-)
;	I understand that today with the existance of
;	accelerators and stuff the classic vbl-timer method
;	may not be the best. Nevertheless it should be easy
;	to modify this to a time-based timer. You can of
;	course modify this source as much as you like, just
;	refer to it in the credits. Don't forget to change 
;	the path names! And as always, the genius-parts were
;	done by us, but we were forced by aliens to do the 
;	lame rest ;-) I hope this is of use to someone.
;	
;	Cu Lazer, and watch for our stuff in the future, but
;	on other platforms...             
;				Energizer, EIL/99 Dresden
;--------------------------------------------------------


; To see how the effects are linked into this os, check out
; one of the parts of this intro. It is quite simple...
                                                       
; Also be sure to set the include paths of devpac
          
	output	C:\DBA_INTR\INTRO.PRG	;Output Filename


FASTEXIT				;Enable -Space- check

internal_speaker=0

	jmp	main

	include	demo.s			
;-----------------------------------------------------------
;  These are the offset values for the registers in the 
;  seperate demo-tasks
TASK_PTR	= 0		;  1L   
TASK_PRIOR	= 4		;  1W
TASK_FLAGS	= 6		;  1W
TASK_PC		= 8		;  1L
TASK_SR		= 12		;  1W
TASK_REGS	= 14		; 16L

                       	
VBL_ANZ=8               ; Max 8 Vbl-Tasks simultaneously
TASK_ANZ=8              ;  -"-  Non-Vbl-tasks -"-

STACK_SIZE=4000
                                                 

; Here are the macros used later on to add/remove tasks etc..
;-----------------------------------------------------------
ADD_TASK MACRO
	lea	\1,a0
	move.w	\2,d0
	bsr	add_task
	ENDM
;-----------------------------------------------------------
DELETE_TASK MACRO
	lea	\1,a0
	bsr	delete_task
	ENDM
;-----------------------------------------------------------
ADD_VBL MACRO
	lea	\1,a0
	move.w	\2,d0
	bsr	add_vbl
	ENDM
;-----------------------------------------------------------
DELETE_VBL MACRO
	lea	\1,a0
	bsr	delete_vbl
	ENDM
;-----------------------------------------------------------
save_sr MACRO
	move.w	sr,-(sp)
	ENDM
;-----------------------------------------------------------
restore_sr MACRO
	move.w	(sp)+,sr
	ENDM
;-----------------------------------------------------------

;-----------------------------------------------------------
	include startup.s
	include	packfire\fireunp3.s
	include	pack_ice.240\ice_unp2.s
;-----------------------------------------------------------

;----------------------------------------------------------- 
;  Choose which packer you prefer
depack_prg MACRO
	lea	\1,a0
	lea	\1_end,a2
	lea	buffer+\2+256-$1c,a1
	bsr	copy_prg
	lea	buffer+\2+256-$1c,a0
	jsr	fire_decrunch_3
	*jsr	ice_decrunch_2		;depack data
	ENDM

relocate_prg MACRO
	lea	buffer+\1,a0
	bsr	setup_basepage
	ENDM

init_prg MACRO
	move.l	#buffer+256+\1,a6

	lea	demo_param,a0
	jsr	6(a6)			; start program
	ENDM

do_prg MACRO
	move.l	#buffer+256+\1,a6
	lea	demo_param,a0
	jsr	8+6(a6)			; start program
	ENDM
;-----------------------------------------------------------


;-----------------------------------------------------------
check_keys
	cmp.b	#$4a,key
	bne.s	.not_vol_down
*	cmp.b	#$4a+128,key		; NUM -
*	bne.s	.not_vol_down

	sub.w	#$200,main_volume
	bpl.s	.1
	move.w	#0,main_volume
.1

	bsr	set_volume

	clr.b	key
	bra.s	.end
.not_vol_down

	cmp.b	#$4e,key
	bne.s	.not_vol_up
*	cmp.b	#$4e+128,key		; NUM +
*	bne.s	.not_vol_up

	add.w	#$200,main_volume
	cmp.w	#$7fff,main_volume
	blo.s	.2
	move.w	#$7fff,main_volume
.2

	bsr	set_volume

	clr.b	key
	bra.s	.end
.not_vol_up

	cmp.b	#$72,old_key
	bne.s	.not_speaker
	cmp.b	#$72+128,key		; NUM ENTER
	bne.s	.not_speaker
        move.b  #14,$ffff8800.w
        move.b  $ffff8800.w,d0
        bchg    #6,d0
        move.b  d0,$ffff8802.w

	clr.b	old_key
	bra.s	.end
.not_speaker


	nop
.end
	rts
;-----------------------------------------------------------
main
	shrink_memory

	bsr	init

	save_stack
	bsr	phoenix_init

	save_interrupts

	move.l	scr1,d0	
	setscreen

	bsr	rout_clear

	lea	demo_settings,a0
	move.w	4(a0),d0
	muls	#$e30,d0
	move.w	d0,main_volume		;set_main_volume


	set_interrupts
	move.w	#$2700,sr
	move.l	#vbl,$70.w
	move.w	#$2300,sr


*	bsr	load_module
	bsr	init_sound

	bsr	init_vbl_queue
	bsr	init_task_queue
	bsr	init_multitask_interrupt
	st	multitasking

	move.l	scr1,d0
	setscreen
	vsync


	lea	demo_param,a0
	move.l	scr1,SHOW_SCREEN(a0)   	;Give the task the 3 screen
	move.l	scr2,WORK_SCREEN(a0)	;adresses to work with
	move.l	scr3,EXTRA_SCREEN(a0)	;first...

	move.w	#$2700,sr
	ADD_TASK main_task,#20		;main task is first active 
					;task
	clr.w	-(sp)
	move.l	#main_task,-(sp)      	;Everything is on "Go" ;-)
	move.w	#$2300,-(sp)            ;so start everything!
	rte				; =jmp main_task

;-----------------------------------------------------------
demo_settings
	dc.w	1	;Speaker
	dc.w	0	;Lock 		;Disables space or esc...
	dc.w	3	;Volume	(9=max)
;-----------------------------------------------------------



;-----------------------------------------------------------
main_task
	move.w	#2300,vsync_count	;Demo has a constantly
					;running vsync counter
					;this is the start-val

.wait_until_next
	bsr	check_keys

	move.l	demo_listptr,a6
	move.l	(a6)+,d0
	cmp.w	vsync_count,d0
*	bgt.s	.wait_until_next  	;Check if there is a task
	ble.s	.next			;in the list to run now
	RETURN .wait_until_next

.next
	move.l	(a6)+,d0		;If yes, then do it
	move.l	(.routs,d0.w*4),a0
	jsr	(a0)

	move.l	a6,demo_listptr
	bra.s	.wait_until_next
	rts

.routs		dc.l	rout_endlist
		dc.l	rout_start
		dc.l	rout_addvbl
		dc.l	rout_delvbl
		dc.l	rout_startsound
		dc.l	rout_addtask
		dc.l	rout_deltask
		dc.l	rout_restart
		dc.l	rout_load
		dc.l	rout_exit
		dc.l	rout_clear
		dc.l	rout_stopsound
		dc.l	rout_loadmodule
		dc.l	rout_demo_locked
		dc.l	rout_repair_all


;-----------------------------------------------------------
rout_endlist
	bra.s	rout_endlist
;-----------------------------------------------------------
pos	dc.l	0
prio	dc.l	0
loadflag	dc.w	0
rout_start
*	move.l	(a6)+,a0	; program
	move.l	(a6)+,d1	; position
	move.l	(a6)+,d0	; priority

	move.l	d1,pos
	move.l	d0,prio

.1
	tst.w	loadflag
	beq.s	.ok
	add.l	#$12340056,$ffff9800.w
	bra.s	.1
.ok

	move.w	#1,loadflag
	lea	rout_start2,a0
	; d0 : priority
	pusha
	bsr	add_task
	popa
	rts


rout_start2
	move.l	pos,d1
	move.l	prio,d0

; ------------- Copy program to new position
	IFNE 0
	pusha
	move.l	-4(a0),d2
	move.l	a0,a2			; program end
	add.l	d2,a2
	lea	buffer+256-$1c,a1	; program position
	add.l	d1,a1
	bsr	copy_prg
	popa
	ENDC

; ------------- Depack Program
	pusha
	lea	buffer+256-$1c,a0	; program position
	add.l	d1,a0
	jsr	fire_decrunch_3
	popa

; ------------- Relocate Program
	pusha
	lea	buffer,a0	; program position
	add.l	d1,a0
	bsr	setup_basepage
	popa

; ------------- Init Program
	pusha
	lea	buffer+256,a6
	add.l	d1,a6
	lea	demo_param,a0
	jsr	6(a6)		; start program
	popa


	clr.w	loadflag
	lea	rout_start2,a0
	bsr	delete_task
.1	bra	.1
	rts
;-----------------------------------------------------------
rout_exit
	move.l	(a6)+,d1	; position

; ------------- Exit Program
	pusha
	lea	buffer+256,a6
	add.l	d1,a6
	lea	demo_param,a0
	jsr	6+4(a6)		; start program
	popa
	rts
;-----------------------------------------------------------
rout_clear

; ------------- Exit Program
	pusha
	lea	screens,a0
	lea	buffer_end,a6

	moveq	#0,d7
.1	
	move.l	d7,(a0)+
	move.l	d7,(a0)+
	move.l	d7,(a0)+
	move.l	d7,(a0)+
	cmp.l	a6,a0
	blt.s	.1

	popa
	rts
;-----------------------------------------------------------
rout_addvbl
	move.l	(a6)+,d1	; position
	move.l	(a6)+,d0	; priority

	pusha
	lea	buffer+256+14,a0
	add.l	d1,a0
	bsr	add_vbl
	popa
	rts
;-----------------------------------------------------------
rout_delvbl
	move.l	(a6)+,d1	; position

	pusha
	lea	buffer+256+14,a0
	add.l	d1,a0
	bsr	delete_vbl
	popa
	rts
;-----------------------------------------------------------
rout_startsound
	pusha
	bsr	start_sound
	popa
	rts
;-----------------------------------------------------------
rout_addtask
	move.l	(a6)+,d1	; position
	move.l	(a6)+,d0	; priority

	pusha
	lea	buffer+256+14,a0
	add.l	d1,a0
	bsr	add_task
	popa
	rts
;-----------------------------------------------------------
rout_deltask
	move.l	(a6)+,d1	; position

	pusha
	lea	buffer+256+14,a0
	add.l	d1,a0
	bsr	delete_task
	popa
	rts
;-----------------------------------------------------------
rout_restart
	move.l	(a6)+,d0
	move.l	(a6)+,d1

	move.l	d0,a6

	move.w	d1,vsync_count
	move.l	d1,counter_abs
	rts
;-----------------------------------------------------------
rout_load
	move.l	(a6)+,a0
	move.l	(a6)+,a1

**	lea	buffer+256-$1c,a1	; program position
	add.l	#buffer+256-$1c,a1

	pusha
	bsr	read_data
	popa
	move.l	len,-4(a1)
	rts
;-----------------------------------------------------------
rout_stopsound
	pusha
	bsr	stop_sound
	popa
	rts
;-----------------------------------------------------------
rout_loadmodule
	move.l	(a6)+,a0

	pusha
	lea	module,a0
	lea	module_end,a1
.1	clr.l	(a0)+
	cmp.l	a1,a0
	blt.s	.1
	popa
	

	lea	module,a1
	pusha
	bsr	read_data
	popa

	pusha
	lea	module,a0
	jsr	fire_decrunch_3
	popa

	rts
;-----------------------------------------------------------
rout_demo_locked
	tst.w	demo_settings+2
	bne.s	.ok
.blabla
	jmp	.blabla
.ok
	rts
;-----------------------------------------------------------
rout_repair_all
	pusha

	move.l	#screens+256,d0
	clr.b	d0
	move.l	d0,scr1
	add.l	#384*240*2,d0
	move.l	d0,scr2
	add.l	#384*240*2,d0
	move.l	d0,scr3

	move.w	#FALSE,palette_update
	move.w	#FALSE,scrmode_update
	move.w	#FALSE,screen_swap

	clr.l	counter_rel

	move.l	scr1,d0
	setscreen

	lea	rgb_320x200xtrue,a0
	set_resolution

	lea	$ffff9800,a0
	move.l	palette,a1
	moveq	#0,d1
	move.w	#255,d0
.1	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbf	d0,.1

	move.w	#2,screen_count

	popa

	rts
;-----------------------------------------------------------

dummy
	add.l	#4,$ffff9800.w
	bra	dummy
;-----------------------------------------------------------
main_exit
	move.l	#mystack,a7

	bsr	exit_sound

	restore_interrupts
	bsr	phoenix_exit
	restore_stack
	bsr	exit
	terminate
;-----------------------------------------------------------



;-----------------------------------------------------------
load_module
	lea	modname,a0
	lea	module,a1
	bsr	read_data

	lea	module,a0
	jsr	fire_decrunch_3

	rts
;-----------------------------------------------------------
read_data2				;read single files
	move.l	a1,-(sp)		;For demo-coding...
                                        ;In the final the function
					;read_data from a big file
					;is used...

	move.w	#0,-(sp)		; open file
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	lea	8(sp),sp
	move.w	d0,filehandle

; ------------------------- seek to the end
	move.w	#2,-(sp)
	move.w	filehandle,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp
	move.l	d0,len

; ------------------------- seek to the start
	move.w	#0,-(sp)
	move.w	filehandle,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp


	move.l	(sp)+,a1


	move.l	a1,-(sp)
	move.l	len,-(sp)		; read file
	move.w	filehandle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	filehandle,-(sp)	; close file
	move.w	#$3e,-(sp)
	trap	#1
	lea	4(sp),sp
	rts

filehandle	dc.w	0
len		dc.l	0
;-----------------------------------------------------------
read_data			;read data from a file generated
				;by onefile.gfa
				
	move.l	a1,-(sp)

	move.b	(a0),d0		;pos in file
	ext.w	d0
	addq	#1,a0		;Fname

	move.l	d0,-(sp)

	move.w	#0,-(sp)		; open file
	move.l	a0,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	lea	8(sp),sp
	move.w	d0,filehandle

; ------------------------- read file inventory

	pea	file_header
	move.l	#256,-(sp)		; read file
	move.w	filehandle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

; ------------------------- search for file

	move.l	(sp)+,d0

	lea	file_header,a0
	move.l	(a0,d0.w*8),d1		;pos in file
	move.l	4(a0,d0.w*8),d2		;length

	move.l	d2,-(sp)
	move.l	d1,-(sp)

; ------------------------- seek to the start

	move.w	#0,-(sp)
	move.w	filehandle,-(sp)
	move.l	#0,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp

; ------------------------- search to file
	move.l	(sp)+,d1

	move.w	#0,-(sp)
	move.w	filehandle,-(sp)
	move.l	d1,-(sp)
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp

; ------------------------- read file

	move.l	(sp)+,d2
	move.l	(sp)+,a1

	move.l	a1,-(sp)
	move.l	d2,-(sp)		; read file
	move.w	filehandle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	filehandle,-(sp)	; close file
	move.w	#$3e,-(sp)
	trap	#1
	lea	4(sp),sp
	rts

;-----------------------------------------------------------
copy_prg
.loop
	move.l	(a0)+,(a1)+
	cmp.l	a2,a0
	ble	.loop
	rts
;-----------------------------------------------------------
; -> A0: Program start-adress
setup_basepage
	move.l	a0,d6

	move.l	d6,d7
	add.l	#256,d7		; program start

	move.l	d7,d0
	sub.l	#$1c,d0
	move.l	d0,a1
	move.l	$02(a1),d0	;textlen
	move.l	$06(a1),d1	;datalen
	move.l	$0a(a1),d2	;bsslen
	move.l	$0e(a1),d3	;symlen

	move.l	d6,a1		; clr basapage
	move.w	#255,d4
clr	clr.b	(a1)+
	dbf	d4,clr

	move.l	d6,a0
	move.l	d6,(a0)		;low tpa
	move.l	$436,4(a0)	;high tpa+1
	sub.l	#2048,4(a0)
	move.l	d7,8(a0)	;text start
	move.l	d0,$c(a0)	;textlen
	move.l	d7,$10(a0)
	add.l	d0,$10(a0)	;data start
	move.l	d1,$14(a0)	;data len
	move.l	d7,$18(a0)
	add.l	d0,$18(a0)
	add.l	d1,$18(a0)	;bss start
	move.l	d2,$1c(a0)	;bss len

	move.l	d7,a1
	add.l	d0,a1		;textseg
	add.l	d1,a1		;dataseg
	add.l	d3,a1		;sym seg

	move.l	d7,a0
	move.l	a0,d1
	moveq.l	#0,d0

	move.l	(a1)+,d0	; relocate first address
	tst.l	d0
	beq.s	end
	add.l	d0,a0
	add.l	d1,(a0)

loop	move.b	(a1)+,d0	; relocate loop
	tst.b	d0
	beq.s	end
	cmp.b	#1,d0
	bne.s	rel
	add.l	#$fe,a0
	bra.s	weiter
rel	add.l	d0,a0
	add.l	d1,(a0)
weiter	bra.s	loop

end
	rts
;-----------------------------------------------------------
init_sound
	lea	vol_tab,a0
	move.w	main_volume,d0
	REPT 8
	move.w	d0,(a0)+
	ENDR

	jsr	player+28		;install

	lea	demo_settings,a0	;internal speaker y/n
	tst.w	(a0)
	bne.s	.int
        move.b  #14,$ffff8800.w
        move.b  $ffff8800.w,d0
        bset    #6,d0
        move.b  d0,$ffff8802.w
	bra.s	.ext
.int    move.b  #14,$ffff8800.w
        move.b  $ffff8800.w,d0
        bclr    #6,d0
        move.b  d0,$ffff8802.w
.ext

	rts
;-----------------------------------------------------------
exit_sound

	move.w	#0,do_play
					;disable vbl-sound-jmp 

	jsr	player+40		;off

	jsr	player+32		;deinstall
	

	rts
;-----------------------------------------------------------
start_sound
	lea	vol_tab,a0
	move.w	main_volume,d0
	REPT 8
	move.w	d0,(a0)+		;set volume
	ENDR

	lea	module,a0
	lea	vol_tab,a1
	jsr	player+36		;on

	move.w	#-1,do_play
					;vbl-jmp enable

	rts
;-----------------------------------------------------------
stop_sound


	jsr	player+40		;off

	rts
;-----------------------------------------------------------
;-----------------------------------------------------------
set_volume
	move.w	main_volume,d0
	move.l	player+68,a0
i set 0
	REPT 8
	move.w	d0,24+28*i(a0)
i set i+1
	ENDR
	rts
;-----------------------------------------------------------


;-----------------------------------------------------------
; ********************** TIME-SHARING **********************
;-----------------------------------------------------------
; -> a0 : pointer to rout
;    d0 : priority
add_task
	save_sr
	move.w	#$2700,sr
	lea	task_queue,a6

	moveq	#0,d6
	move.w	#TASK_ANZ-1,d7
.1	move.l	TASK_PTR(a6),d1
	beq.s	.found
	lea	128(a6),a6
	addq	#1,d6
	dbf	d7,.1
	restore_sr
	rts

.found
	move.l	a0,TASK_PC(a6)
	move.w	#$2300,TASK_SR(a6)
	move.l	a0,TASK_PTR(a6)
	move.b	d0,TASK_PRIOR(a6)

	lea	test_stack,a1
	muls	#STACK_SIZE,d6
	add.l	d6,a1
	add.l	#STACK_SIZE,a1

	move.l	TASK_PTR(a6),-(a1)
	move.l	#task_finished,-(a1)
	clr.w	-(a1)			; 4 word stack frame
	move.l	TASK_PC(a6),-(a1)
	move.w	TASK_SR(a6),-(a1)
	move.l	a1,TASK_REGS+15*4(a6)

	restore_sr
	rts
;-----------------------------------------------------------
task_finished
	move.l	(sp)+,a0
	bsr	delete_task
	rts
;-----------------------------------------------------------
; -> a0 : pointer to rout
delete_task
	save_sr
	move.w	#$2700,sr
	lea	task_queue,a6

	move.w	#TASK_ANZ-1,d7
.1	move.l	TASK_PTR(a6),a1
	cmp.l	a1,a0
	beq.s	.found
	lea	128(a6),a6
	dbf	d7,.1
	restore_sr
	rts

.found
	clr.l	TASK_PTR(a6)
	clr.w	TASK_PRIOR(a6)
	restore_sr
	rts
;-----------------------------------------------------------
init_task_queue
	lea	task_queue,a0

	lea	test_stack,a1
	add.l	#STACK_SIZE,a1
	
	move.w	#TASK_ANZ-1,d0
.1	clr.l	TASK_PTR(a0)		; pointer
	clr.w	TASK_PRIOR(a0)		; priority
	clr.w	TASK_FLAGS(a0)		; flags
	move.l	a1,TASK_REGS+15*4(a0)
	lea	128(a0),a0
	add.l	#STACK_SIZE,a1
	dbf	d0,.1
	rts
;-----------------------------------------------------------
init_multitask_interrupt
	move.w	#$2700,sr

	move.l	#task_switch,$120.w

	bset	#0,$fffffa07.w			; IERB
	bset	#0,$fffffa13.w			; IMRB

	clr.b	$fffffa1b.w
	move.b	#50,$fffffa21.w			; Timer B Data
	move.b	#7,$fffffa1b.w			; Timer B Control

	move.w	#$2300,sr
	rts
;-----------------------------------------------------------
task_switch
	clr.b	$fffffa1b.w
	tst.w	multitasking
	beq	.not_active

*	not.l	$ffff9800.w
	movem.l	d0-a7,save_regs

	move.w	active_task,d0
	lea	task_queue,a0
	lsl.w	#7,d0
	lea	(a0,d0.w),a0

	movem.l	d0-a7,TASK_REGS(a0)
	move.l	save_regs,TASK_REGS(a0)
	move.l	save_regs+8*4,TASK_REGS+8*4(a0)

	move.l	2(sp),TASK_PC(a0)
	move.w	(sp),TASK_SR(a0)

.find_active
	move.w	active_task,d0
	lea	task_queue,a0
	moveq	#7,d1
.loop	
	addq	#1,d0
	and.w	#7,d0

	move.w	d0,d2
	lsl.w	#7,d2
	lea	(a0,d2.w),a1
	cmp.l	#0,TASK_PTR(a1)
	bne.s	.found
	dbf	d1,.loop
	bra.s	.not_found
.found
	move.w	d0,active_task

	move.l	TASK_REGS+15*4(a1),a7

	move.b	TASK_PRIOR(a1),$fffffa21.w	; Timer B Data

	move.l	TASK_PC(a1),2(sp)
	move.w	TASK_SR(a1),(sp)

	movem.l	TASK_REGS(a1),d0-a7

	bra.s	.ok
.not_found
	movem.l	save_regs,d0-a7
.not_active
	move.b	#100,$fffffa21.w		;######??????

.ok

*	not.l	$ffff9800.w

	move.b	#7,$fffffa1b.w			; Timer B Control

	bclr	#0,$fffffa0f.w			; IPRB
	rte
;-----------------------------------------------------------
save_regs	ds.l	16
;-----------------------------------------------------------


;-----------------------------------------------------------
; ********************** VBL-HANDLING **********************
;-----------------------------------------------------------
; -> a0 : pointer to rout
;    d0 : priority
add_vbl
	lea	vbl_queue,a6

	move.w	#VBL_ANZ-1,d7
.1	move.l	(a6),d1
	beq.s	.found
	lea	8(a6),a6
	dbf	d7,.1
	rts

.found
	move.l	a0,(a6)
	move.l	d0,4(a6)
	rts
;-----------------------------------------------------------
; -> a0 : pointer to rout
;    d0 : priority
delete_vbl
	lea	vbl_queue,a6

	move.w	#VBL_ANZ-1,d7
.1	move.l	(a6),a1
	cmp.l	a1,a0
	beq.s	.found
	lea	8(a6),a6
	dbf	d7,.1
	rts

.found
	clr.l	(a6)
	clr.w	4(a6)
	rts
;-----------------------------------------------------------
handle_vbl_list
	bsr	clear_vbl_flags

	lea	vbl_queue,a0

	move.w	#VBL_ANZ-1,d0
.1	move.l	(a0),a6
	cmp.l	#0,a6
	beq.s	.no
	pusha
	jsr	(a6)
	popa
.no
	lea	8(a0),a0
	dbf	d0,.1
	
	rts
;-----------------------------------------------------------
clear_vbl_flags
	lea	vbl_queue,a0
	
	move.w	#VBL_ANZ-1,d0
.1	clr.w	6(a0)
	lea	8(a0),a0
	dbf	d0,.1
	rts
;-----------------------------------------------------------
init_vbl_queue
	lea	vbl_queue,a0
	
	move.w	#VBL_ANZ-1,d0
.1	clr.l	0(a0)		; pointer
	clr.w	4(a0)		; priority
	clr.w	6(a0)		; flags
	lea	8(a0),a0
	dbf	d0,.1
	rts
;-----------------------------------------------------------



;-----------------------------------------------------------
do_main_vbl
	lea	demo_param,a0
	tst.w	SCREEN_SWAP(a0)
	beq.s	.no_scrswap

	cmp.w	#3,SCREEN_COUNT(a0)
	bne.s	.swp1
	move.l	SHOW_SCREEN(a0),d0
	move.l	EXTRA_SCREEN(a0),SHOW_SCREEN(a0)
	move.l	WORK_SCREEN(a0),EXTRA_SCREEN(a0)
	move.l	d0,WORK_SCREEN(a0)
	bra.s	.swap_ok
.swp1
	move.l	SHOW_SCREEN(a0),d0
	move.l	WORK_SCREEN(a0),SHOW_SCREEN(a0)
	move.l	d0,WORK_SCREEN(a0)
.swap_ok
	clr.w	SCREEN_SWAP(a0)

	move.l	SHOW_SCREEN(a0),d0
	move.l	d0,d1
	move.w	d1,d2

	swap	d0
	lsr.w	#8,d1

	move.b	d0,$ffff8201.w
	move.b	d1,$ffff8203.w
	move.b	d2,$ffff820d.w
*	move.b	d0,$ffff8205.w
*	move.b	d1,$ffff8207.w
*	move.b	d2,$ffff8209.w

.no_scrswap

	tst.w	SCRMODE_UPDATE(a0)
	beq.s	.no_scrmode

	pusha
	move.l	SCRMODE(a0),a0
	set_resolution
	popa
	clr.w	SCRMODE_UPDATE(a0)
.no_scrmode


	tst.w	PALETTE_UPDATE(a0)
	beq.s	.no_palette

	move.l	PALETTE(a0),a1
	lea	$ffff9800.w,a2
	moveq	#256/16-1,d0
.1	REPT 16
	move.l	(a1)+,(a2)+
	ENDR
	clr.w	PALETTE_UPDATE(a0)
	dbf	d0,.1
.no_palette

	tst.w	do_play
	beq.s	.no_sound
	jsr	player+44		;play
.no_sound
	rts
;-----------------------------------------------------------
vbl
	sf	multitasking
	move.w	#$2500,sr
*	clr.b	$fffffa1b.w
	movem.l	d0-a7,vbl_regs


	bsr	do_main_vbl

	bsr	handle_vbl_list
	movem.l	vbl_regs,d0-a7

	move.b	key,old_key
	move.b	$fffffc02.w,key


	tst.w	demo_settings+2
	bne.s	.no_exit		;demo_lock

	tst.w	loadflag
	bne.s	.no_exit
	cmp.b	#$39,key
	bne.s	.no_exit
	move.w	#$2700,sr
	clr.w	do_play
	bra	main_exit
.no_exit

****************************************
**	pusha
**	not.l	$ffff9800.w
**	move.w	#200,d0
**.1	dbf	d0,.1
**	not.l	$ffff9800.w
**	popa
****************************************

	add.w	#1,vsync_count
	add.l	#1,counter_abs
	add.l	#1,counter_rel
	st	multitasking
*	move.b	#7,$fffffa1b.w			; Timer B Control
	move.w	#$2300,sr
	rte

old_vbl	jmp	$12345678

vbl_regs	ds.l	16
;-----------------------------------------------------------
; ********************** TIME-SHARING **********************
;-----------------------------------------------------------



;-----------------------------------------------------------
clrscr
	move.l	scr1,a5
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2

	move.w	#459,d7
.1	
	rept	10
	movem.l	d0-d6/a0-a2,(a5)
	lea	40(a5),a5
	endr
	dbf	d7,.1
	rts
;-----------------------------------------------------------
init
	clr_bss

	super_on
	mouse_off

	cache_on

        move.l  $44e.w,old_screen
	save_resolution

	move.l	#screens+256,d0
	clr.b	d0
	move.l	d0,scr1
	add.l	#384*240*2,d0
	move.l	d0,scr2
	add.l	#384*240*2,d0
	move.l	d0,scr3

	move.l	scr1,d0
	setscreen

	lea	rgb_320x200xtrue,a0
	set_resolution

	move.l	#0,$ffff9800.w
        rts
;-----------------------------------------------------------
exit
	
	move.l	old_screen,d0
	setscreen
	restore_resolution

	mouse_on
	super_off
	rts
;-----------------------------------------------------------



;-----------------------------------------------------------
scr1		dc.l	0
scr2		dc.l	0
scr3		dc.l	0
;-----------------------------------------------------------
;----------------------------------------------------------

;List of filenames: In case of usage of read_file2 just replace
;the filenames here with the original filenames of the single
;effects

credits		dc.b	1,"dba.dat",0
dba_3d		dc.b	2,"dba.dat",0
rotator		dc.b	3,"dba.dat",0
mag		dc.b	4,"dba.dat",0

modname 	dc.b	0,"dba.dat",0
endmodule 	*dc.b	1,"lostbl_4.dat",0 	
	even
;-----------------------------------------------------------

active_task	dc.w	0
multitasking	dc.w	0


ENDLIST		= 0
START		= 1
ADDVBL		= 2
DELVBL		= 3
STARTSOUND	= 4
ADDTASK		= 5
DELTASK		= 6
RESTART		= 7
LOAD		= 8
EXIT		= 9
CLEAR		= 10
STOPSOUND	= 11
LOADMODULE	= 12
DEMOLOCKED	= 13
REPAIR_ALL	= 14			;Commando list

                                                
;Which effect occupies what mem area?
					
_DBA_3D_	= 100000
_MAG_		= 1400000		
_ROTATOR_	= 600000
_CREDITS_	= 100000		;Memory occupation



demo_listptr	dc.l	demo_list

;-------------------------------------------- Refrain 1
demo_list
test                                   

; ***!!!*** Obviously there are differences between a vbl-task
; and a non-vbl task. Some effects like 3d-engines use 3 screens
; to look smoother and do not need calling from a classic vbl-rout.
; Whereas a normal scroller or bitplane effect (or whatever ;-) )
; would need such a thing. Refer to the endpart and the 3d-part
; to see the difference...
                          
; The first number is the vbl-counter where the action will take place
; and the last number you see somewhere is the priority...

demo_start
	dc.l	2310,REPAIR_ALL

	dc.l	2350,LOADMODULE,modname

	dc.l	2400,LOAD,dba_3d,_DBA_3D_
	dc.l	2450,START,_DBA_3D_,100
	dc.l	2500,STARTSOUND

	dc.l	2510,ADDTASK,_DBA_3D_,200
	dc.l	3010,LOAD,mag,_MAG_
	dc.l	3100,START,_MAG_,100
	dc.l	3209,DELTASK,_DBA_3D_

	dc.l	3211,ADDTASK,_MAG_,200
	dc.l	3410,DELTASK,_MAG_

	dc.l	3411,LOAD,rotator,_ROTATOR_
	dc.l	3450,START,_ROTATOR_,100

	dc.l	3470,ADDTASK,_ROTATOR_,200
	dc.l	3500,LOAD,credits,_CREDITS_
	dc.l	3570,START,_CREDITS_,50
	dc.l	3710,DELTASK,_ROTATOR_

	dc.l	3711,ADDTASK,_CREDITS_,200
	dc.l	3720,DELTASK,_CREDITS_

	dc.l	3721,ADDVBL,_CREDITS_+4,100
	dc.l	5250,DELVBL,_CREDITS_+4

	
end_of_demo
	dc.l	69500,DEMOLOCKED

	dc.l	69510,DELTASK,_CREDITS_
	dc.l	69520,STOPSOUND
	dc.l	69530,CLEAR
	dc.l	69750,RESTART,demo_start,2300
	

	dc.l	999999,ENDLIST



demo_param
show_screen	dc.l	0
work_screen	dc.l	0
extra_screen	dc.l	0
screen_count	dc.w	3
screen_swap	dc.w	0
palette		dc.l	pal_buffer
palette_update	dc.w	1
counter_abs	dc.l	0
counter_rel	dc.l	0
scrmode		dc.l	rgb_320x200xtrue
scrmode_update	dc.w	0

pal_buffer	ds.l	256



;-----------------------------------------------------------
	IFNE internal_speaker=0
main_volume	dc.w	$7fff
	ELSE
main_volume	dc.w	$1fff
	ENDC

do_play		dc.w	0		;Player running 0=off 1=on

vol_tab		dcb.w	8,0

player	incbin	dspmod\dspmod2.tce
	EVEN

	section bss
	ds.b	33000

	even

	ds.l	1000
mystack		ds.l	0

test_stack	ds.b	9*STACK_SIZE+100
vbl_queue	ds.b	8*VBL_ANZ
task_queue	ds.b	128*TASK_ANZ
file_header	ds.b	256

start_bss
module		ds.b	400000
module_end	ds.l	1

screens		ds.b	3*384*240*2+256		;Screenbuffer
end_bss

buffer		ds.b	1500000
buffer_end
 
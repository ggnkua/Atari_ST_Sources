
	ttl	'Title'	Program title

	include	A:\PATHNAME\GEMMACRO.I   amend pathname as reqd

;The program proper

start_of_pgm	move.l	4(sp),a3	base page
	move.l	#stack,sp	move SP
	move.l	12(a3),d0	text len
	add.l	20(a3),d0	data len
	add.l	28(a3),d0	BSS len
	add.l	#256,d0	basepage

	move.l	d0,-(sp)	shrink memory
	move.l	a3,-(sp)
	clr	-(sp)
	move	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

	appl_init		initialise application
	move	d0,ap_id	and store the app ident
	graf_handle		fetch graf handle code
	move	d0,current_handle  and store VDI handle

	lea	intin,a0	initialise intin array
	moveq	#10-1,d0	
shell1	move	#1,(a0)+	most params are 1
	dbra	d0,shell1
	move	#2,(a0)+	use RC system
	v_opnvwk		open work station
	v_hide_c		hide mouse
	v_clrwk		clr screen
	vs_clip	#1,#0,#0,#639,#399
	vsl_color	#1

;	rsrc_load	#rsc_file	load resource file (if reqd)
;	bne	shell2	branch if OK
;	v_show_c	#0	show mouse
;	form_alert	#1,#badrsc	can't find .RSC file ?
;	bra	shell3

shell2	bsr	main	run main program

;	rsrc_free		free RSC memory (if reqd)

	v_show_c	#0	show mouse
shell3	v_clsvwk		close workstation
	appl_exit		close application

	clr	-(sp)	status code
	move	#$4c,-(sp)	P_TERM
	trap	#1	exit pgm

;rsc_file	dc.b	'RESOURCE.RSC',0	
;badrsc	dc.b	'[3][Resource file error][Quit]',0
;	even

;--------------------- Main program sub-routine ------------------------

main	

; User code goes here

exit	rts	exit program

;             -------------- Program Sub-Routines -----------

;Program sub-routines go in here

;             -------------- Library Sub-Routines -----------

;Library sub-routines go in here
	
	SECTION	data	global constants

;Fixed data (look-up tables, messages, etc) go in here
	
	SECTION	bss	temporary data

ap_id	ds.w 	1	application ident

	ds.l	100	stack space (400 bytes)
stack	ds.w	1	(stacks go backwards)

	include	A:\PATHNAME\AESLIB.S  amend pathname as reqd	
	include	A:\PATHNAME\VDILIB.S  amend pathname as reqd

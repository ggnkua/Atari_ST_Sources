;Bezier curve demonstration program
;By Peter Hibbs  5-1-1997

	ttl	'Bezier test program'

	include	gemmacro.i

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
	vs_clip	#1,#0,#0,#639,#399
	vsl_color	#1

shell2	bsr	main	run main program

	v_show_c	#0	show mouse
shell3	v_clsvwk		close workstation
	appl_exit		close application

	clr	-(sp)	status code
	move	#$4c,-(sp)	P_TERM
	trap	#1	exit pgm

;--------------------- Main program sub-routine ------------------------

main	graf_mouse	#0
	vsm_type	#2	set marker to +
	vswr_mode	#1	set write mode
	
	v_hide_c		hide mouse
	v_clrwk		clr screen
	v_show_c	#1	show mouse
	
	v_gtext	#10,#18,#message1

main0	lea	bez_in,a5	locate bezier input array

main1	vq_mouse		wait for butn release
	tst	intout
	bne	main1

main2	vq_mouse		 wait for butn press
	tst	intout	 any butn pressed
	beq	main2
	cmp	#2,intout	 right button ?
	beq	exit

	move	ptsout,(a5)+	 store x co-ord
	move	ptsout+2,(a5)+	 store y co-ord

	move	ptsout,ptsin	 set x co-ord
	move	ptsout+2,ptsin+2 set y co-ord
	v_hide_c		 and
	v_pmarker	#1	 show + marker
	v_show_c	#1

	cmp.l	#bez_in+15,a5	 chk if 4 done
	blt	main1	 loop if not

	v_hide_c
	bsr	draw_bezier	 draw bez curve
	v_show_c	#1
	bra	main0	 loop
			
exit	rts		 exit program

;             -------------- Program Sub-Routines -----------

	include	bez_lib.s	bezier routines library
	
	SECTION	data	global constants

b_table	incbin	BEZ_TAB.DAT	bezier look up table
	even

message1	dc.b	'Click on four points on screen, right button to exit',0
	even
		
	SECTION	bss

bez_in	ds.w	8	bezier input array


ap_id	ds.w 	1	application ident
	ds.l	100	stack space 
stack	ds.w	1

	include	aeslib.s
	include	vdilib.s

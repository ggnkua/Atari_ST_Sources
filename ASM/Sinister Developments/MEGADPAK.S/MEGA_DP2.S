******* ******* ******* ******* 
** * ** **      **      **   **
** * ** ****    ** **** *******  DEPACK v2 (c) 1992 Sinister Developments
**   ** **      **   ** **   **
**   ** ******* ******* **   **

	opt	o+,w-
	include	aesmakro.s
	include	mega_dpk.i
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Make sure vars are clear ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
s
.x	lea	control(pc),a0
	lea	endx(pc),a1
	moveq	#0,d0
.1	move.w	d0,(a0)+
	cmp.l	a0,a1
	bge.s	.1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Are we running as an accessory? ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	lea	s-$100(pc),a3
	moveq	#0,d0
	tst.l	$24(a3)
	bne.s	not_acc
	move.w	#0,decide
	move.l	a7,old_stack
	move.l	#mystack,a7
	bsr	initialise
	menu_reg	app_id,acc_id,menu_item	; set up menu
	bsr	set_up_tables
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Loop around until selected ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
loop	evnt_mess	parms	
	cmp.w	#40,d0
	beq.s	main_prog
	bra.s	loop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Standard program init (we don't do this in accessories);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
not_acc	move.w	#-1,decide
	move.l	a7,a5
	move.l	a7,old_stack
	move.l	#mystack,a7
	move.l	4(a5),a5	
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	move	d0,-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	bsr	initialise
	bsr	set_up_tables

main_prog	bsr	mouse2pointer
	bsr	malloc	
	lea	null(pc),a1
	bsr	a1_2_packer
;
;;;;;;;;;;;;;;;;;;;;;
; Main program loop ;
;;;;;;;;;;;;;;;;;;;;;
;
again	lea	waiting(pc),a0
	bsr	update_status
	show_form	main_menu	; show menu
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return here if form is already displayed ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
not_again	form_do	0	; wait for mouse click
	ext.l	d0
	cmp.b	#loadandunpack,d0
	beq	load_unpack
	cmp.b	#save,d0
	beq	save_fil
	cmp.b	#batch,d0
	beq	batch_fil
	cmp.b	#help,d0
	beq	show_help
	cmp.b	#megadepackv2.0,d0
	beq	show_info
	cmp.b	#sinisterd1992,d0
	beq.s	show_info
	cmp.b	#codeanddesign,d0
	beq.s	show_info
	cmp.b	#inf_butt,d0
	beq.s	show_info
	cmp.b	#greetz_butt,d0
	beq	show_greetz

;
;;;;;;;;
; Exit ; 
;;;;;;;;
;
bye	kill_form	main_menu	; clear menu off screen
	lea	m_start(pc),a0	; free allocated ram
	bsr	m_free
	tst.w	decide
	bmi.s	.not_acc	; if its not an acc then get outta here 
	obj_chnge	save,8,0,main_menu	; reset button
	obj_chnge	quit,0,0,main_menu
	bra	loop
.not_acc	rsc_free
exit	move.l	old_stack(pc),a7
.1	clr.l	-(a7)
	trap	#1
;
;;;;;;;;;;;;;;;;;;;;;;;;
; Show info subroutine ; 
;;;;;;;;;;;;;;;;;;;;;;;;
;
show_info	bsr	kill_menu
	obj_chnge	megadepackv2.0,$30,0,main_menu	; reset button
	obj_chnge	sinisterd1992,0,0,main_menu	; reset button
	obj_chnge	codeanddesign,0,0,main_menu	; reset button
	obj_chnge	inf_butt,0,0,main_menu	; reset button
	show_form	info	; show info 
	form_do	0	; wait 
	kill_form	info	l clear it
	obj_chnge	info_ok,$30,0,info	; reset button
	jmp	again
;
;;;;;;;;;;;;;;;;;;;;;;;;;;
; Show greetz subroutine ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;
;
show_greetz
	bsr	kill_menu
	obj_chnge	greetz_butt,0,0,main_menu	; reset button
	show_form	greetings	; show info 
	form_do	0	; wait 
	kill_form	greetings	l clear it
	obj_chnge	greetz_cancel,$30,0,greetings	; reset button
	jmp	again

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display form allowing help to be chosen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
show_help	bsr	kill_menu
	obj_chnge	help,0,0,main_menu	; reset button
	show_form	help_select	; let user decide on help
	form_do	0
	cmp.b	#2,d0
	beq.s	.pkrs	; show packers
	cmp.b	#3,d0
	beq	.help	; show help
;
; cancel
;
	kill_form	help_select	; bye
	obj_chnge	sel_bye,0,0,help_select	; reset button
	jmp	again	; return to menu
;
; Show packers
;
.pkrs	kill_form	help_select
	obj_chnge	sel_pkrs,0,0,help_select
	show_form	packers
	form_do	0
	kill_form	packers
	obj_chnge	packers_bye,0,0,packers
	jmp	again
;
; show help
;
.help	kill_form	help_select
	obj_chnge	sel_help,0,0,help_select
	show_form	help1
	form_do	0
	cmp.b	#$b,d0
	beq.s	.exithe
	kill_form	help1
	obj_chnge	help_next,0,0,help1
	show_form	help2
	form_do	0
	kill_form	help2
	obj_chnge	help2_bye,0,0,help2
	jmp	again
;
; Exit help form one
;
.exithe	kill_form	help1
	obj_chnge	help_bye,0,0,help1
	lea	waiting(pc),a0
	bsr	update_status
	jmp	again
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code for loading and unpacking one file ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
load_unpack
	obj_chnge	save,8,0,main_menu	; reset button
	lea	fil_extend(PC),a3
	move.l	a3,save_extend
	bsr	file_select	; bring up file selector
	bmi	.cancel	; cancel pressed so quit
	bsr	mouse2bee
	lea	init_fil(pc),a0
	bsr	fil2frame	; put filename into frame
	clr.l	unpacked_length
	bsr	update_upl2
	obj_chnge	loadandunpack,0,0,main_menu	; reset button
	bsr	redraw_main	; redraw menu coz file select overwrote it 
	bsr	struct_file	; file to normal form
	lea	filename(pc),a0
	bsr	find_first	; does it exist? & get length as well
	tst.w	d0
	bmi	file_error	; ooops! error
	move.l	dta+26(pc),d0
	bsr	ram_alloc		; allocate ram for it
	tst.l	d0		
	beq	memory_error	; ooops! error	
	move.l	d0,load_here	; ok so store address
	lea	loading(pc),a0	
	bsr	update_status
	bsr	redraw_status	; put loading into frame and show it
	bsr	zap_ram
	lea	filename(pc),a0
	bsr	read_file		; load file
	tst.w	rw_error
	bmi	file_error	; ooops! error
	bsr	depack
	tst.l	not_packed
	beq.s	.packed	
	clr.l	unpacked_length
	bsr	update_upl2
	bra.s	.1
.packed	obj_chnge	save,0,0,main_menu	; reset button

.1	lea	load_here(pc),a0
	bsr	m_free		; free allocated ram
	
	bsr	mouse2pointer
	lea	waiting(pc),a0
	bsr	update_status
	bsr	update_upl
	bsr	redraw_main
	jmp	not_again		; back to menu
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code for a cancelled file select ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
.cancel	obj_chnge	loadandunpack,0,0,main_menu
	bsr	redraw_main
	jmp	not_again
;
;;;;;;;;;;;;;;;;;;;;;;;
; Code to save a file ;
;;;;;;;;;;;;;;;;;;;;;;;
;
save_fil	move.l	unpacked_length(pc),d0
	add.l	save_here(pc),d0
	sub.l	load_here(pc),d0
	add.l	#1000,d0
	bsr	ram_alloc2
	move.l	d0,oh_no

	lea	fil_extend(PC),a3
	move.l	a3,save_extend
	bsr	file_select
	bmi.s	.cancel
	bsr	mouse2bee
	bsr	struct_file	; file to normal form
	obj_chnge	save,0,0,main_menu
	lea	saving(pc),a0
	bsr	update_status
	bsr	redraw_main
	lea	filename(pc),a0
	bsr	write_file
	tst.w	rw_error
	bmi	file_error	; ooops! error
	lea	waiting(pc),a0
	bsr	update_status
	bsr	mouse2pointer
.cancel	lea	oh_no(pc),a0
	bsr	m_free		; free allocated ram
	obj_chnge	save,8,0,main_menu
	bsr	redraw_main
	jmp	not_again

batch_fil	obj_chnge	save,8,0,main_menu	; reset button
g_l_p	lea	fil_extend(PC),a3
	move.l	a3,save_extend
	bsr	file_select
	bmi	bcancel
	lea	init_dir(pc),a0
	lea	batch_dir(pc),a2
	lea	b_l_fname(pc),a1
.1	move.b	(a0)+,d0
	move.b	d0,(a2)+
	move.b	d0,(a1)+
	move.b	d0,d1
	beq.s	.2
	bra.s	.1
.2	move.b	#'*',-(a2)
	move.b	(a0)+,1(a2)
	move.b	(a0)+,2(a2)
	move.b	(a0)+,3(a2)
	move.b	(a0)+,4(a2)
	subq	#1,a1
	move.l	a1,fil2gh1
g_s_p	lea	fil_extend(PC),a3
	move.l	a3,save_extend
	bsr	file_select
	bmi	bcancel
	lea	init_dir(pc),a0
	lea	b_s_fname(pc),a1
.1	move.b	(a0)+,d0
	move.b	d0,(a1)+
	move.b	d0,d1
	beq.s	.2
	bra.s	.1
.2	subq	#1,a1
	move.l	a1,fil2gh2
	clr.l	unpacked_length
	bsr	update_upl2
	obj_chnge	batch,0,0,main_menu
	bsr	redraw_main
	bsr	mouse2bee
	lea	batch_dir(pc),a0
	bsr	find_first
	tst.l	d0
	bmi	bfin
bagain	lea	dta+30(pc),a0
	bsr	fil2frame
	lea	dta+30(pc),a0
	move.l	fil2gh1(pc),a1
	move.l	fil2gh2(pc),a2
.2	move.b	(a0)+,d0
	beq.s	.1
	move.b	d0,(a1)+
	move.b	d0,(a2)+
	bra.s	.2	
.1	clr.b	(a1)
	clr.b	(a2)
	move.l	dta+26(pc),d0
	bsr	ram_alloc		; allocate ram for it
	tst.l	d0		
	beq	memory_error	; ooops! error	
	move.l	d0,load_here	; ok so store address
	lea	loading(pc),a0	
	bsr	update_status
	bsr	redraw_status	; put loading into frame and show it
	clr.l	unpacked_length
	bsr	update_upl2
	bsr	zap_ram
	bsr	redraw_panel
	lea	b_l_fname(pc),a0
	bsr	read_file		; load file
	tst.w	rw_error
	bmi	file_error	; ooops! error
	bsr	depack
	bsr	update_upl
	lea	load_here(pc),a0
	bsr	m_free		; free allocated ram
	tst.l	not_packed
	bmi.s	.np
	lea	saving(pc),a0
	bsr	update_status
	bsr	redraw_status
	lea	b_s_fname(pc),a0
	bsr	write_file
	tst.w	rw_error
	bmi	file_error	; ooops! error

.np	clr.l	unpacked_length
	bsr	update_upl2


	move.w	#$4f,-(a7)
	trap	#1
	addq	#2,a7
	tst.l	d0
	bmi.s	bfin
	bra	bagain
bfin	lea	waiting(pc),a0
	bsr	update_status
	bsr	redraw_status
	obj_draw	6,0,form_coords
	bsr	mouse2pointer
	jmp	not_again
bcancel	obj_chnge	batch,0,0,main_menu
	bsr	redraw_main
	bsr	mouse2pointer
	jmp	not_again

file_error
	bsr	mouse2pointer
	bsr	redraw_main
	form_alrt	f_error,1
	move.l	form_tab(pc),addr_in	
	jmp	not_again

memory_error
	bsr	mouse2pointer
	bsr	redraw_main
	form_alrt	m_error,1
	move.l	form_tab(pc),addr_in	
	jmp	not_again

kill_menu	kill_form	main_menu	; remove menu from screen
	rts

redraw_panel
	zap_intin
	ctrlarray	42
	move.w	#status,int_in
	bsr	call_aes
	move.w	#file,int_in
	bsr	call_aes
	move.w	#packedsize,int_in
	bsr	call_aes
	move.w	#unpackedsize,int_in
	bsr	call_aes
	rts
redraw_status
	zap_intin
	ctrlarray	42
	move.w	#status,int_in
	bsr	call_aes
	rts

fil2frame	tedinfo	file,a1
	lea	7(a1),a1
	move.l	a1,a2
	moveq	#11,d0
	moveq	#$20,d1
.clear	move.b	d1,(a2)+
	dbf	d0,.clear
	
.2	move.b	(a0)+,d0
	beq.s	.1
	move.b	d0,(a1)+
	bra.s	.2		
.1	rts

update_status
	tedinfo	status,a1
	lea	9(a1),a1
.2	move.b	(a0)+,d0
	beq.s	.1
	move.b	d0,(a1)+
	bra.s	.2		
.1	rts
redraw_details
	zap_intin
	ctrlarray	42
	move.w	#file_info_1,int_in
	bsr	call_aes
	move.w	#file_info_2,int_in
	bsr	call_aes
	move.w	#file_info_3,int_in
	bsr	call_aes
	move.w	#filetype,int_in
	bsr	call_aes
	move.w	#status,int_in
	bsr	call_aes
	move.w	#packedsize,int_in
	bsr	call_aes
	move.w	#save,int_in
	bsr	call_aes

	rts

exec_dets	movem.l	d0-a6,-(a7)
	bsr.s	a1_2_packer
	lea	exec(pc),a1
	bsr	update_type
	lea	depacking(pc),a0
	bsr	update_status
	bsr	redraw_details
	movem.l	(a7)+,d0-a6
	rts	
data_dets	movem.l	d0-a6,-(a7)
	bsr.s	a1_2_packer
	lea	datafil(pc),a1
	bsr	update_type
	lea	depacking(pc),a0
	bsr	update_status
	bsr	redraw_details
	movem.l	(a7)+,d0-a6
	rts	
pic_dets	movem.l	d0-a6,-(a7)
	bsr.s	a1_2_packer
	lea	pic(pc),a1
	bsr	update_type
	lea	depacking(pc),a0
	bsr	update_status
	bsr	redraw_details
	movem.l	(a7)+,d0-a6
	rts	
archive_dets
	movem.l	d0-a6,-(a7)
	bsr.s	a1_2_packer
	lea	archive(pc),a1
	bsr.s	update_type
	lea	depacking(pc),a0
	bsr	update_status
	bsr	redraw_details
	movem.l	(a7)+,d0-a6
	rts	

a1_2_packer
line1	tedinfo	file_info_1,a2
	lea	12(a2),a2
	move.l	a2,a3
.3	move.b	(a3),d0
	beq.s	.2
	move.b	#'_',(a3)+
	bra.s	.3
.2	move.b	(a1)+,d0
	beq.s	line2
	move.b	d0,(a2)+
	bra.s	.2		
line2	tedinfo	file_info_2,a2
	move.l	a2,a3
.3	move.b	(a3),d0
	beq.s	.2
	move.b	#'_',(a3)+
	bra.s	.3
.2	move.b	(a1)+,d0
	beq.s	line3
	move.b	d0,(a2)+
	bra.s	.2		
line3	tedinfo	file_info_3,a2
	move.l	a2,a3
.3	move.b	(a3),d0
	beq.s	.2
	move.b	#'_',(a3)+
	bra.s	.3
.2	move.b	(a1)+,d0
	beq.s	.exit
	move.b	d0,(a2)+
	bra.s	.2		
.exit	rts

update_type
	tedinfo	filetype,a2
	lea	12(a2),a2
.2	move.b	(a1)+,d0
	beq.s	.1
	move.b	d0,(a2)+
	bra.s	.2		
.1	rts
update_upl
	tedinfo	unpackedsize,a0
	move.l	unpacked_length(pc),d0
	lea	15(a0),a0
	bsr	hex2dec
	zap_intin
	ctrlarray	42
	move.w	#unpackedsize,int_in
	bsr	call_aes
	rts
update_upl2
	tedinfo	unpackedsize,a0
	move.l	unpacked_length(pc),d0
	lea	15(a0),a0
	bsr	hex2dec
	rts

mouse2pointer
	grph_mse	0
	rts
mouse2bee	grph_mse	2
	rts
	
redraw_main
	obj_draw	0,14,form_coords
	rts

initialise
	hidemouse
	init_aes
	load_rsc	rsc_name
	rts

malloc	pea	$0.w
	move.w	#$48,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,m_start
	rts

m_free	move.l	(a0),-(a7)
	move.w	#$49,-(a7)
	trap	#1
	addq	#6,a7
	rts

find_first
	move.w	#0,-(a7)
	pea	(a0)
	pea	dta(pc)
	move.w	#$1a,-(a7)
	trap	#1
	addq	#6,a7
	move.w	#$4e,-(a7)
	trap	#1
	addq	#8,a7
	rts

ram_alloc	move.l	d0,-(a7)
	move.l	d0,file_length
	tedinfo	packedsize,a0
	lea	13(a0),a0
	bsr	hex2dec
	move.w	#$48,-(a7)
	trap	#1
	addq	#6,a7
	rts
ram_alloc2
	move.l	d0,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq	#6,a7
	rts

resource_missing
	showmouse
	form_alrt	rsc_missing,1
	bra	exit

set_up_ctrl
	move.l	a0,-(a7)
	move.w	d0,control
	sub.w	#10,d0
	lea	gem_ctrl_list(pc),a0
	lsl.w	#2,d0
	move.l	(a0,d0.w),d0
	lea	control(pc),a0
	movep.l	d0,3(a0)
	move.l	(a7)+,a0
	rts	

call_aes	lea	params(PC),a0
	move.l	a0,d1
	move.w	#$C8,d0
	trap	#2
	move.w	int_out(pc),d0
	rts

; misc subroutines

display_form
	move.l	(a0),a0
	form_cntr	a0,form_coords	
	form_dial	1,form_coords
	move.l	addr_in(pc),-(a7)
	ctrlarray	100
	zap_intin
	move.l	form_coords(pc),int_in+2	
	move.l	form_coords+4(pc),int_in+6
	bsr	call_aes
	move.w	d0,int_in
	move.w	d0,w_h
	ctrlarray	101
	bsr	call_aes
	move.l	(a7)+,addr_in
	obj_draw	0,20,form_coords
	showmouse
	rts

close_form
	move.l	(a0),a0
	form_cntr	a0,form_coords	
	form_dial	3,form_coords
	form_dial	2,form_coords
	ctrlarray	102
	zap_intin
	move.w	w_h(pc),int_in
	bsr	call_aes
	ctrlarray	103
	bsr	call_aes
	showmouse
	rts

object_change
	ctrlarray	47
	zap_intin
	move.w	a4,int_in+0
	move.w	a5,int_in+12
	move.w	a6,int_in+14
	move.l	(a0),addr_in
	bsr	call_aes
	rts

set_up_tables
	ctrlarray	112
	zap_intin
	moveq	#9,d7
	moveq	#0,d6
	lea	form_tab(pc),a6
.1	rsc_gaddr	0,d6,a5
	addq	#1,d6
	move.l	a5,(a6)+
	dbf	d7,.1

	moveq	#21,d7
	moveq	#0,d6
	lea	obj_tab(pc),a6
.2	rsc_gaddr	1,d6,a5
	addq	#1,d6
	cmp.w	#$15,6(a5)
	beq.s	.3
	cmp.w	#$16,6(a5)
	beq.s	.3
	cmp.w	#$1c,6(a5)
	beq.s	.33

	clr.l	(a6)+
	bra.s	.4
.33	move.l	12(a5),(a6)+
	bra.s	.4 
.3	move.l	12(a5),a5
	move.l	(a5),(a6)+
.4	dbf	d7,.2
	rts

file_select
	movem.l	a0-a2/D1-d3,-(a7)
	bsr.s	get_dir
	lea	init_dir(PC),a2
	tst.b	(a2)+
	beq.s	.2
.1	tst.b	(a2)+
	bne.s	.1
.2	move.b	#$5C,-1(a2)
.3	move.b	(a3)+,(a2)+
	bne.s	.3
	fsel	init_dir,init_fil
	tst.w	int_out+2
	beq.s	.4
	bsr.s	set_dir
	moveq	#0,d0
	bra.s	.5
.4	moveq	#-1,d0
.5	movem.l	(a7)+,a0-a2/D1-d3
	rts

; get directory

get_dir	movem.l	a0-a2,-(a7)
	lea	init_dir(PC),a1
	move.l	a1,a2
	moveq	#$40,d0
.1	clr.b	(a1)+
	dbf	d0,.1
	move.w	#$19,-(a7)
	trap	#1
	addq.w	#2,a7
	add.w	#$41,d0
	move.b	d0,(a2)+
	move.b	#$3A,(a2)+
	clr.w	-(a7)
	pea	(a2)
	move.w	#$47,-(a7)
	trap	#1
	addq.w	#8,a7
	movem.l	(a7)+,a0-a2
	rts

; set directory

set_dir	lea	init_dir(pc),a1
	move.l	a1,a2
	moveq	#0,d0
	move.b	(a1)+,d0
	pea	(a1)
	subi.w	#$41,d0
	move.w	d0,-(a7)
	move.w	#$E,-(a7)
	trap	#1
	addq.w	#4,a7
	move.l	(a7)+,a1
.1	move.b	(a1)+,d0
	beq.s	.2
	cmp.b	#$2A,d0
	bne.s	.1
	clr.b	-(a1)
.2	pea	init_dir(PC)
	move.w	#$3B,-(a7)
	trap	#1
	addq.w	#6,a7
	rts

struct_file
	lea	filename(PC),a0
	lea	init_dir(PC),a1
	bsr.s	get_dir
	move.b	(a1)+,(a0)+
	move.b	(a1)+,(a0)+
	tst.b	(a1)
	beq.s	.1
.2	move.b	(a1)+,(a0)+
	bne.s	.2
	subq.w	#1,a0
.1	move.b	#$5C,(a0)+
	lea	init_fil(PC),a1
.3	move.b	(a1)+,(a0)+
	bne.s	.3
	rts

read_file	sf	rw_error
	move.w	#0,-(a7)
	pea	(a0)
	move.w	#$3D,-(a7)
	trap	#1
	addq.w	#8,a7
	tst.w	d0
	bmi.s	.3
	move.w	d0,handle

	move.l	load_here(pc),-(a7)
	move.l	file_length(pc),d2
	move.l	d2,-(a7)
	move.w	d0,-(a7)
	move.w	#$3F,-(a7)
	trap	#1
	lea	$C(a7),a7
	tst.l	d0
	bmi.s	.1
	bra.s	.2
.1	st	rw_error
.2	bra.s	close
	rts
.3	st	rw_error
	rts

close	move.w	handle(PC),-(a7)
	move.w	#$3E,-(a7)
	trap	#1
	addq.w	#4,a7
	tst.w	d0
	bpl.s	.1
	st	rw_error
.1	rts

write_file
	sf	rw_error
	clr.w	-(a7)
	pea	(a0)
	move.w	#$3C,-(a7)
	trap	#1
	addq.w	#8,a7
	tst.w	d0
	bmi.s	.3
.1	move.w	d0,handle
	lea	save_here(pc),a0
	move.l	(a0),a0
	pea	(a0)
	move.l	unpacked_length(pc),-(a7)
	move.w	d0,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	$C(a7),a7
	tst.l	d0
	bpl.s	close
	st	rw_error
	bra.s	close
.3	st	rw_error
	rts

;
; HEX to DECIMAL conversion
;
hex2dec	moveq	#7,d1
	move.l	a0,a1
.setup	move.b	#'0',(a1)+
	dbf	d1,.setup
	moveq	#7,d4	; 8 digits in HEX number
	lea	table1+8(pc),a2	; end of 1st table entry
	move.l	a0,a3
.loop	moveq	#0,d1
	move.b	d0,d1	; get first nibble
	and.b	#$0f,d1	; mask out top nibble
	beq.s	.next	; blank so don't bother
	subq	#1,d1	; using in dbf so fix
.1	moveq	#7,d2	; 8 elements per table entry
	move.l	a2,a1	; move from a1
.2	move.b	-(a1),d3	; move number to be added
	bsr.s	add_dec	; add it
	dbf	d2,.2	; one number added			
	dbf	d1,.1	; d1 times number in table
.next	lsr.l	#4,d0	; get next nibble
	addq	#8,a2	; want to get from next table	
	dbf	d4,.loop
strip_leading_zeroes
	moveq	#0,d0
.1	move.b	(a0),d0
	sub.b	#$30,d0
	bne.s	.exit
	move.b	#$20,(a0)+
	bra.s	.1	
.exit	rts
;
; Add D3 to d2 offset of A0 in ascii format
;

add_dec	lea	(a3,d2.w),a0
.1	move.b	(a0),d5	; add to this
	add.b	d3,d5
.2	cmp.b	#':',d5	; overflow ?
	blt.s	.3	; nah
	sub.b	#$0a,d5	; we've added 10 so add the rest
	move.b	d5,(a0)	; store what we've added 
	subq.l	#1,a0	; add rest to this
	moveq	#1,d3	; rest is 1 
	bra.s	.1	; round again	
.3	move.b	d5,(a0)
	rts

zap_ram	move.l	load_here(pc),a0
	move.l	a0,a1
	move.l	file_length(pc),d0
	cmp.l	#700,d0
	bge.s	.1
	move.l	#700,d0
.1	add.l	d0,a1
	movem.l	blank(pc),d0-7
.clear	movem.l	d0-7,(a0)
	lea	32(a0),a0
	cmp.l	a0,a1
	bgt.s	.clear
	rts

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; All the depacking and stuff like that is done here ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
depack
	include	dp_dec.s
	include	dp_src.s

	data

acc_id	dc.b	'  Mega Depack 2',0
	even
table1	dc.b	0,0,0,0,0,0,0,1	; 16 tpo 0
	dc.b	0,0,0,0,0,0,1,6	; 16 tpo 1
	dc.b	0,0,0,0,0,2,5,6	; 16 tpo 2
	dc.b	0,0,0,0,4,0,9,6	; 16 tpo 3
	dc.b	0,0,0,6,5,5,3,6	; 16 tpo 4
	dc.b	0,1,0,4,8,5,7,6	; 16 tpo 5

rsc_name	dc.b	'mega_dp2.rsc',0
	even
rsc_missing
	dc.b	'[1]'
	dc.b	'[ | | Can''t find MEGA_DP2.RSC ]'
	dc.b	'[FIND IT!]',0
f_error
	dc.b	'[1]'
	dc.b	'[ | | OOPS! FILE ERROR]'
	dc.b	'[FIX IT!]',0
m_error
	dc.b	'[1]'
	dc.b	'[ | Sorry, there is not enough RAM'
	dc.b	' | to load this file.|]'
	dc.b	'[CANCEL]',0
loading	dc.b	'Loading  ',0
saving	dc.b	'Saving   ',0
waiting	dc.b	'Waiting  ',0
depacking	dc.b	'Depacking',0
fil_extend
	dc.b	'*.*',0
	even
save_extend
	dcb.w	2,0
dta	ds.b	44
	even
params	dc.l	control
	dc.l	global
	dc.l	int_in
	dc.l	int_out
	dc.l	addr_in
	dc.l	addr_out
	dc.l	bye

	include	p_info.s
	even
	include	g_list.s

	bss
control	ds.w	5
global	ds.w	16
int_in	ds.w	16
int_out	ds.w	7
addr_in	ds.l	2
addr_out	ds.l	1 
app_id	ds.w	1
menu_item	ds.w	1
w_h	ds.w	1
rw_error	ds.w	1
handle	ds.w	1
load_here	ds.l	1
save_here	ds.l	1
oh_no	ds.l	1
old_stack	ds.l	1
not_packed
	ds.l	1
filename	ds.w	33
b_l_fname	ds.w	33
b_s_fname	ds.w	33
file_length
	ds.l	1
unpacked_length
	ds.l	1
fil2gh1	ds.l	1
fil2gh2	ds.l	1
init_dir	ds.w	40
init_fil	ds.w	40
batch_dir	ds.w	40
parms	ds.b	16
decide	ds.w	1
m_start	ds.l	1
res	ds.w	1
form_address
	ds.l	1 
free_ram	ds.l	1
form_coords
	ds.l	8
form_tab	ds.l	20
obj_tab	ds.l	25
b_a_store	ds.l	1
freespace	ds.b	644
buf00	ds.b	1024+512
buf01	ds.l	0	
buffer	ds.l	160/4
blank	ds.l	8
endx
	ds.l	$2000/4
mystack	ds.l	1
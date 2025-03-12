***************************************************
* v.2.0 made in 91....                            *
* -TCB- SPèRARE AV -AN COOL- / DIGISHIT AV -NICK- *
***************************************************
over_buff equ 700

x:
	jmp	main
*********** init routs ************
save_ints:
	move.l	usp,a0
	move.l	a0,save_usp
	move.b	$fffffa07.w,mfpa07
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$118,save_ikbd
	move.l	$120.w,oldhbl
	move.l	$134,old134
	move.l	$70.w,oldvbl
	move.l	$68.w,oldhs
	bclr	#3,$fffffa17.w
	rts
init_ints:	
	move.w	#$2700,sr
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	clr.b	$fffffa13.w

	move.l	#ikbd,$118
	move.l	currir,$134
	move.b	mfpa1f2,$fffffa1f.w	;16	;32
	move.b	#2,$fffffa19.w
	bset	#5,$fffffa07.w	;09
	bset	#5,$fffffa13.w	;15
	bset	#6,$fffffa09.w	;09
	bset	#6,$fffffa15.w	;15
	move.l	#vbi,$70.w
	move.w	#$2300,sr
	rts
mfpa1f2:
	dc.b	24
	even

ret_ints:	
	move.w	#$2700,sr
	move.b	mfpa07,$fffffa07.w
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	save_ikbd,$118
	move.l	oldhbl,$120.w
	move.l	old134,$134
	move.l	oldvbl,$70.w
	move.l	oldhs,$68.w
	move.l	save_usp,a0
	move.l	a0,usp
	move.w	#$2300,sr
	rts


mfpa07:	dc.b	0
mfpa09:	dc.b	0
mfpa13:	dc.b	0
mfpa15:	dc.b	0
mfpa19:	dc.b	0
mfpa1f:	dc.b	0
oldhbl:	dc.l	0
old134:	dc.l	0
oldvbl:	dc.l	0
oldhs:	dc.l	0
save_ikbd:	dc.l	0
save_usp:	dc.l	0

shift_mouse:
	lea	mouse_shifts,a1
	moveq	#15,d0
shift_loop:
	lea	mouse,a0
	moveq	#15,d1
shift_loop2:
	moveq	#0,d2
	moveq	#0,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	lsl.l	d0,d2
	lsl.l	d0,d3
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	swap	d2
	swap	d3
	move.w	d2,(a1)+
	move.w	d3,(a1)+

	or.l	d3,d2
	not.l	d2
	swap	d2
	move.w	d2,(a1)+
	move.w	d2,(a1)+
	swap	d2
	move.w	d2,(a1)+
	move.w	d2,(a1)+


	dbra	d1,shift_loop2
	dbra	d0,shift_loop
	rts
shift_drift:
	lea	shifted_drift,a1
	moveq	#15,d0
shift_loop3:
	lea	drift,a0
	moveq	#15,d1
shift_loop4:
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	rol.w	d0,d2
	rol.w	d0,d3
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	dbra	d1,shift_loop4
	lea	drift,a0
	moveq	#15,d1
shift_loop5:
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	rol.w	d0,d2
	rol.w	d0,d3
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	dbra	d1,shift_loop5
	dbra	d0,shift_loop3
	rts
copy_pic:
	lea	backg,a0
	move.l	screen_start,a1
	move.w	#(4000)-1,d0	
copy_loop:
	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	dbra	d0,copy_loop
	rts
init_screen:
	move.l	screen_start,a1
	add.l	#(160*15)+120,a1
	move.b	currpatt,d1
	jsr	print_hex
	move.l	screen_start,a1
	add.l	#(160*27)+120,a1
	move.b	currposs,d1
	jsr	print_hex
	jsr	drumm_act
	move.l	screen_start,a1
	add.l	#(160*39)+120,a1
	move.b	currres,d1
	jsr	print_hex
	move.l	screen_start,a1
	add.l	#(160*51)+121,a1
	move.b	currsam,d1
	and.b	#$f,d1
	move.b	d1,currsam
	jsr	print_hex2
	move.l	screen_start,a1
	add.l	#(160*63)+120,a1
	move.b	currvol,d1
	jsr	print_hex
	move.l	screen_start,a1
	add.l	#(160*75)+112,a1
	move.w	currloop,d1
	jsr	print_hex3
	move.l	screen_start,a1
	add.l	#(160*87)+121,a1
	move.b	currspeed,d1
	and.b	#$f,d1
	move.b	d1,currspeed
	jsr	print_hex2
	move.l	screen_start,a1
	add.l	#(160*99)+121,a1
	move.b	currbonus,d1
	and.b	#$f,d1
	move.b	d1,currbonus
	jsr	print_hex2

	jsr	okfn

	move.l	screen_start,a1
	add.l	#(160*15)+(8*8),a1
	move.b	curroffs,d1
	jsr	print_hex

	move.l	curr_panel,a0
	move.l	screen_start,a1
	add.l	#(160*38)+(8*4),a1
	move.l	#66,d0
.loop:
	move.l	(a0)+,(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,16(a1)
	lea	160(a1),a1
	dbra	d0,.loop

	jsr	thru_ms_ch1
	jsr	thru_ms_ch2
	jsr	thru_ms_ch3
	jsr	thru_ms_ch4
	jsr	ut_bass
	jsr	ut_med_spec_val
	jsr	int_ext
	jsr	worm_int_ext
	jsr	offrahassa
	jsr	fix_play_status
	jsr	rec_hurru
	jsr	print_sizze
	jsr	calc_song
	jsr	print_currname
	jsr	print_currsongname
	jsr	print_curr_drive
	jsr	blarre_mode
	jsr	shift_status
	jsr	alternate_status
	jsr	mon_status
	jsr	tap_status
	jsr	moot_status
	jsr	ut_bass
	move.l	screen_start,a1
	add.l	#(160*163),a1
	moveq	#6,d0
lulle_loop:
	move.b	#-1,(8*0)(a1)
	move.b	#-1,(8*1)+1(a1)
	move.b	#-1,(8*5)(a1)
	move.b	#-1,(8*8)+1(a1)
	move.b	#-1,(8*12)(a1)
	move.b	#-1,(8*15)+1(a1)
	lea	160(a1),a1
	dbra	d0,lulle_loop
	jsr	fix_select

	cmp.w	#1,file_allert
	bne	go_no_ut_sele
	jsr	ut_med_sele
	jsr	print_files
go_no_ut_sele:
	rts
ms_offs:
	cmp.b	#$3f,curroffs
	beq	go_no_ut_sele
	moveq	#0,d1
	add.b	#1,curroffs
	move.l	screen_start,a1
	add.l	#(160*15)+(8*8),a1
	move.b	curroffs,d1
	jsr	print_hex
	rts
ms_clearoffs:
	moveq	#0,d1
	move.b	#1,curroffs
	move.l	screen_start,a1
	add.l	#(160*15)+(8*8),a1
	move.b	curroffs,d1
	jsr	print_hex
	rts
ms_offs2:
	cmp.b	#0,curroffs
	beq	go_no_ut_sele
	moveq	#0,d1
	sub.b	#1,curroffs
	move.l	screen_start,a1
	add.l	#(160*15)+(8*8),a1
	move.b	curroffs,d1
	jsr	print_hex
	rts
curroffs:
	dc.b	1,0
ms_restore_patt:
	moveq	#0,d0
	move.b	currposs,d0
	lea	patt_tab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*15)+120,a1
	clr.b	(a0)
	moveq	#0,d1
	move.b	d1,currpatt
	jsr	print_hex
	jsr	calc_song
	rts
ms_restore_pos:
	moveq	#0,d1 
	jsr	fuling
	rts
ms_restore_res:
	move.b	#0,currres
	moveq	#0,d1
	move.l	screen_start,a1
	add.l	#(160*39)+120,a1
	jsr	print_hex
	rts
ms_restore_spl:
	move.b	#0,currsam
	jsr	fuling2
	rts
ms_restore_vol:
	move.b	#$7f,d1
	jsr	fuling3
	rts
ms_restore_loop:
	move.w	#0,currloop
	jsr	fuling4
	rts
ms_restore_temp:
	move.b	#10,currspeed
	jsr	fuling5
	rts
ms_restore_spec:
	move.b	#0,currbonus
	jsr	fuling6
	rts
ms_restore_tran:
	move.b	#0,trans_no
	jsr	okfn
	rts

ms_tebas:
	move.w	#0,d0
	jsr	set_it_da(pc)
	rts
ms_tebas2:
	move.w	#1,d0
	jsr	set_it_da(pc)
	rts
ms_tebas3:
	move.w	#2,d0
	jsr	set_it_da(pc)
	rts
ms_tebas4:
	move.w	#3,d0
	jsr	set_it_da(pc)
	rts
ms_tebas5:
	move.w	#4,d0
	jsr	set_it_da(pc)
	rts
ms_tebas6:
	move.w	#5,d0
	jsr	set_it_da(pc)
	rts
ms_tebas7:
	move.w	#6,d0
	jsr	set_it_da(pc)
	rts
ms_tebas8:
	move.w	#7,d0
	jsr	set_it_da(pc)
	rts
ms_tebas9:
	move.w	#8,d0
	jsr	set_it_da(pc)
	rts
ms_tebas10:
	move.w	#9,d0
	jsr	set_it_da(pc)
	rts
ms_tebas11:
	move.w	#10,d0
	jsr	set_it_da(pc)
	rts
ms_tebas12:
	move.w	#11,d0
	jsr	set_it_da(pc)
	rts
ms_tebas13:
	move.w	#12,d0
	jsr	set_it_da(pc)
	rts
diskanten:
	move.w	#%0000010010000000,d1
	move.w	d0,curr_treb
	bra	ffff
set_it_da:
	cmp.w	#0,ste_flag
	beq.s	no_ste_on2
	cmp.w	#0,currcurr
	bne.s	diskanten
	move.w	#%0000010001000000,d1
	move.w	d0,xcurr_bass
ffff:
	add.w	d0,d0
	or.w	trettontab(pc,d0.w),d1
	move.w	#$7ff,$ff8924
xmwwrite:
	cmp.w	#$07ff,$ff8924
	bne.s	xmwwrite
	move.w	d1,$ff8922
	jsr	ut_bass(pc)
no_ste_on2:
	rts
ms_do_bass:
	move.w	#0,currcurr
	move.w	xcurr_bass(pc),d0
	jsr	set_it_da
	rts	
ms_do_treb:
	move.w	#1,currcurr
	move.w	curr_treb,d0
	jsr	set_it_da
	rts	
trettontab:
	dc.w	0,1,2,3,4,5,6,7,8,9,10,11,12
xcurr_bass:
	dc.w	6
curr_treb:
	dc.w	6
currcurr:
	dc.w	0
treble:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.l	screen_start,a1
	add.l	#(160*37)+(8*2)+6,a1
	jsr	slurkis
	move.w	#-1,d0
	move.b	#%00011111,d1
	move.b	#%11000000,d2
	move.l	screen_start,a1
	add.l	#(160*43)+(8*2)+6,a1
	jsr	slurkis
	moveq	#0,d0
	move.w	curr_treb,d0
	bra	cly
ut_bass:
	lea	tebas,a0
	cmp.w	#0,currcurr
	bne	treble
	move.w	#-1,d0
	move.b	#%00011111,d1
	move.b	#%11000000,d2
	move.l	screen_start,a1
	add.l	#(160*37)+(8*2)+6,a1
	jsr	slurkis
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.l	screen_start,a1
	add.l	#(160*43)+(8*2)+6,a1
	jsr	slurkis
	moveq	#0,d0
	move.w	xcurr_bass,d0
cly:
	mulu	#6,d0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*34)+(8*2),a1
	move.b	1(a0),1(a1)
	move.b	1(a0),161(a1)
	move.w	2(a0),8(a1)
	move.w	2(a0),168(a1)
	move.w	4(a0),16(a1)
	move.w	4(a0),176(a1)
	rts
slurkis:
	move.b	d1,1(a1)
	move.b	d1,161(a1)
	move.b	d1,321(a1)
	move.b	d1,481(a1)
	move.b	d1,641(a1)
	move.w	d0,8(a1)
	move.w	d0,168(a1)
	move.w	d0,328(a1)
	move.w	d0,488(a1)
	move.w	d0,648(a1)
	move.b	d2,16(a1)
	move.b	d2,176(a1)
	move.b	d2,336(a1)
	move.b	d2,496(a1)
	move.b	d2,656(a1)
	rts
tebas:
	dc.w	%0000000000011000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000110
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000001
	dc.w	%1000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0110000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0001100000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000011000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000110000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000001100000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000011000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000110
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000001
	dc.w	%1000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0110000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0001100000000000
ut_med_spec_val:
	moveq	#0,d0
	lea	spec_values,a0
	move.b	currbonus,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	move.l	screen_start,a1
	add.l	#(160*116)+72,a1
	jsr	print_hex3
	rts
ms_bonus_upp:
	moveq	#0,d0
	lea	spec_values,a0
	move.b	currbonus,d0
	add.w	d0,d0
	addq.w	#2,(a0,d0.w)
	jsr	ut_med_spec_val
	rts
ms_bonus_ner:
	moveq	#0,d0
	lea	spec_values,a0
	move.b	currbonus,d0
	add.w	d0,d0
	subq.w	#2,(a0,d0.w)
	jsr	ut_med_spec_val
	rts
ms_bonus_clr:
	lea	save_spec_values,a0
	lea	spec_values,a1
	moveq	#15,d0
ms_bonus_clr_loop:
	move.w	(a0)+,(a1)+
	dbra	d0,ms_bonus_clr_loop
	jsr	ut_med_spec_val
	rts
ruta1a:
	dc.w	0
	dc.l	(160*38)+(8*4)+6
ruta2a:
	dc.w	0
	dc.l	(160*55)+(8*4)+6
ruta3a:
	dc.w	0
	dc.l	(160*72)+(8*4)+6
ruta4a:
	dc.w	0
	dc.l	(160*89)+(8*4)+6
ruta5a:
	dc.w	0
	dc.l	(160*38)+(8*5)+6
ruta6a:
	dc.w	0
	dc.l	(160*55)+(8*5)+6
ruta7a:
	dc.w	0
	dc.l	(160*72)+(8*5)+6
ruta1b:
	dc.w	0
	dc.l	(160*38)+(8*4)+6
ruta2b:
	dc.w	0
	dc.l	(160*55)+(8*4)+6
ruta3b:
	dc.w	0
	dc.l	(160*72)+(8*4)+6
ruta4b:
	dc.w	0
	dc.l	(160*89)+(8*4)+6
ruta5b:
	dc.w	0
	dc.l	(160*38)+(8*5)+6
ruta6b:
	dc.w	0
	dc.l	(160*55)+(8*5)+6
ruta7b:
	dc.w	0
	dc.l	(160*72)+(8*5)+6

fix_select:
	cmp.w	#1,current_pannel
	beq	rutc
	lea	ruta1a,a0
	bra	contrut
rutc:
	lea	ruta1b,a0
contrut:
	move.w	#3,d2
select_loop:
	cmp.w	#0,(a0)+
	beq	no_ruta
	move.l	screen_start,a1
	add.l	(a0),a1
	move.w	#%0000000000111111,d1
	or.w	d1,(a1)
	or.w	d1,160*1(a1)
	or.w	d1,160*2(a1)
	or.w	d1,160*3(a1)
	or.w	d1,160*4(a1)
	or.w	d1,160*5(a1)
	or.w	d1,160*6(a1)
	or.w	d1,160*7(a1)
	or.w	d1,160*8(a1)
	or.w	d1,160*9(a1)
	or.w	d1,160*10(a1)
	or.w	d1,160*11(a1)
	or.w	d1,160*12(a1)
	or.w	d1,160*13(a1)
	or.w	d1,160*14(a1)
	or.w	d1,160*15(a1)

	cmp.w	#1,file_allert
	beq	no_right
	move.w	#%1111111111100000,d1
	bra	right2
no_right:
	moveq	#0,d1
right2:
	move.l	screen_start,a1
	add.l	(a0)+,a1
	addq.l	#8,a1
	move.w	d1,(a1)
	move.w	d1,160*1(a1)
	move.w	d1,160*2(a1)
	move.w	d1,160*3(a1)
	move.w	d1,160*4(a1)
	move.w	d1,160*5(a1)
	move.w	d1,160*6(a1)
	move.w	d1,160*7(a1)
	move.w	d1,160*8(a1)
	move.w	d1,160*9(a1)
	move.w	d1,160*10(a1)
	move.w	d1,160*11(a1)
	move.w	d1,160*12(a1)
	move.w	d1,160*13(a1)
	move.w	d1,160*14(a1)
	move.w	d1,160*15(a1)
on_select_loop:
	dbra	d2,select_loop
	jsr	right_ruta
	rts
right_ruta:
	move.w	#2,d2
select_loop2:
	cmp.w	#0,(a0)+
	beq	no_ruta2
	cmp.w	#1,file_allert
	beq	no_ruta2
	move.w	#%0000000000001111,d1
	move.l	screen_start,a1
	add.l	(a0),a1
	or.w	d1,(a1)
	or.w	d1,160*1(a1)
	or.w	d1,160*2(a1)
	or.w	d1,160*3(a1)
	or.w	d1,160*4(a1)
	or.w	d1,160*5(a1)
	or.w	d1,160*6(a1)
	or.w	d1,160*7(a1)
	or.w	d1,160*8(a1)
	or.w	d1,160*9(a1)
	or.w	d1,160*10(a1)
	or.w	d1,160*11(a1)
	or.w	d1,160*12(a1)
	or.w	d1,160*13(a1)
	or.w	d1,160*14(a1)
	or.w	d1,160*15(a1)

	move.w	#%1111111111110000,d1

	move.l	screen_start,a1
	add.l	(a0)+,a1
	addq.l	#8,a1
	move.w	d1,(a1)
	move.w	d1,160*1(a1)
	move.w	d1,160*2(a1)
	move.w	d1,160*3(a1)
	move.w	d1,160*4(a1)
	move.w	d1,160*5(a1)
	move.w	d1,160*6(a1)
	move.w	d1,160*7(a1)
	move.w	d1,160*8(a1)
	move.w	d1,160*9(a1)
	move.w	d1,160*10(a1)
	move.w	d1,160*11(a1)
	move.w	d1,160*12(a1)
	move.w	d1,160*13(a1)
	move.w	d1,160*14(a1)
	move.w	d1,160*15(a1)
on_select_loop2:
	dbra	d2,select_loop2
	rts

no_ruta:
	move.w	#%0000000000111111,d1
	not.w	d1
	move.l	screen_start,a1
	add.l	(a0),a1
	and.w	d1,(a1)
	and.w	d1,160*1(a1)
	and.w	d1,160*2(a1)
	and.w	d1,160*3(a1)
	and.w	d1,160*4(a1)
	and.w	d1,160*5(a1)
	and.w	d1,160*6(a1)
	and.w	d1,160*7(a1)
	and.w	d1,160*8(a1)
	and.w	d1,160*9(a1)
	and.w	d1,160*10(a1)
	and.w	d1,160*11(a1)
	and.w	d1,160*12(a1)
	and.w	d1,160*13(a1)
	and.w	d1,160*14(a1)
	and.w	d1,160*15(a1)

	move.w	#%0000000000001111,d1

	move.l	screen_start,a1
	add.l	(a0)+,a1
	addq.l	#8,a1
	and.w	d1,(a1)
	and.w	d1,160*1(a1)
	and.w	d1,160*2(a1)
	and.w	d1,160*3(a1)
	and.w	d1,160*4(a1)
	and.w	d1,160*5(a1)
	and.w	d1,160*6(a1)
	and.w	d1,160*7(a1)
	and.w	d1,160*8(a1)
	and.w	d1,160*9(a1)
	and.w	d1,160*10(a1)
	and.w	d1,160*11(a1)
	and.w	d1,160*12(a1)
	and.w	d1,160*13(a1)
	and.w	d1,160*14(a1)
	and.w	d1,160*15(a1)
	bra	on_select_loop
no_ruta2:
	move.w	#%1111111111110000,d1
	move.l	screen_start,a1
	add.l	(a0),a1
	and.w	d1,(a1)
	and.w	d1,160*1(a1)
	and.w	d1,160*2(a1)
	and.w	d1,160*3(a1)
	and.w	d1,160*4(a1)
	and.w	d1,160*5(a1)
	and.w	d1,160*6(a1)
	and.w	d1,160*7(a1)
	and.w	d1,160*8(a1)
	and.w	d1,160*9(a1)
	and.w	d1,160*10(a1)
	and.w	d1,160*11(a1)
	and.w	d1,160*12(a1)
	and.w	d1,160*13(a1)
	and.w	d1,160*14(a1)
	and.w	d1,160*15(a1)

	moveq	#0,d1

	move.l	screen_start,a1
	add.l	(a0)+,a1
	addq.l	#8,a1
	move.w	d1,(a1)
	move.w	d1,160*1(a1)
	move.w	d1,160*2(a1)
	move.w	d1,160*3(a1)
	move.w	d1,160*4(a1)
	move.w	d1,160*5(a1)
	move.w	d1,160*6(a1)
	move.w	d1,160*7(a1)
	move.w	d1,160*8(a1)
	move.w	d1,160*9(a1)
	move.w	d1,160*10(a1)
	move.w	d1,160*11(a1)
	move.w	d1,160*12(a1)
	move.w	d1,160*13(a1)
	move.w	d1,160*14(a1)
	move.w	d1,160*15(a1)
	bra	on_select_loop2
init_dta:
	pea	dta
	move.w	#$1a,-(sp)
	trap	#1
	add.l	#6,sp
	rts

makeytab:
	lea	ytab,a0
	move.l	screen_start,d1
	move.w	#199,d0
makey:	
	move.l	d1,(a0)+
	add.l	#160,d1
	dbra	d0,makey
	lea	ytab2,a0
	move.l	screen_start,d1
	add.l	#((33+31)*160),d1
	move.w	#31,d0
makey2:	
	move.l	d1,(a0)+
	add.l	#160,d1
	dbra	d0,makey2
	move.l	screen_start,d1
	add.l	#(33)*160),d1
	move.w	#50,d0
makey3:	
	move.l	d1,(a0)+
	add.l	#160,d1
	dbra	d0,makey3
	rts
makextab2:
	lea	xtab2,a6
	move.w	#320-1,d7
	move.w	#160,d1
makexloop2:
	and.w	#319,d1
	move.w	d1,d6
	add.w	#16*7,d6
	move.w	d6,d0
	move.w	d6,d2
	and.w	#15,d2
	move.w	#%1000000000000000,d3
	lsr.w	d2,d3
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.w	d3,(a6)+
	move.w	d0,(a6)+
	add.w	#1,d1
	dbra	d7,makexloop2
	rts


*********** main routs (AN Cool routs.)************

play_musaxx:
	cmp.w	#1,play_flag
	bne.s	no_uppdate

	cmp.w	#1,midi_flag
	beq	yes_midi
	addq.b	#1,polle
	move.b	currspeed,d0
	subq.b	#1,d0
	and.b	#$0f,d0
	eor.b	#$0f,d0
	cmp.b	polle,d0
	bne.s	no_uppdate
	clr.b	polle
yes_midi:

	addq.b	#1,minipek
	move.b	minipek,d0
	and.b	#%00111111,d0
	move.b	d0,minipek
	addq.b	#3,d0
	and.b	#%00111111,d0
	beq.s	next_patt

	jsr	play_line

no_uppdate:
	rts
next_patt:
	cmp.w	#1,rec_flag
	beq	forbi_pos
	jsr	ms_pos
	move.b	currposs,d0
	cmp.b	currres,d0
	blo.s	forbi_pos

	move.w	#1,loopch1
	move.w	#1,loopch2
	move.w	#1,loopch3
	move.w	#1,loopch4
	lea	emptysamp,a3
	move.l	#emptysamp,endchan1
	lea	emptysamp,a4
	move.l	#emptysamp,endchan2
	lea	emptysamp,a5
	move.l	#emptysamp,endchan3
	lea	emptysamp,a6
	move.l	#emptysamp,endchan4

	move.b	#-1,currposs
	jsr	ms_pos
forbi_pos:
	jsr	play_line
	rts

play_flag:
	dc.l	0
rec_flag:
	dc.l	0

start_digi:
	move.w	#$2700,sr
	lea	curr_tunes,a0
;-------------- channel 1
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	tst.b	d0
	beq	forbdv3
	lea	convtab(pc),a1
	move.b	(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	speedadds,a1
	move.l	(a1,d0.w),chan1bepos
	move.w	d1,d2
	and.w	#-16,d2
	lsr.w	#1,d2
	lea	samp_pet_buff,a1
	move.l	(a1,d2.w),a3
	add.l	#start_buff,a3
	move.l	4(a1,d2.w),endchan1
	move.l	a3,d0
	add.l	d0,endchan1
	sub.l	#over_buff,endchan1

	moveq	#0,d0
	lea	samtab,a1
	lsr.w	#1,d2
	move.w	2(a1,d2.w),d0
	cmp.w	#0,d0
	beq	no_loop
	move.l	endchan1,start_end
	move.l	endchan1,end_end
	sub.l	d0,start_end	
	clr.w	loopch1
	bra	forbdv3
no_loop:
	move.w	#1,loopch1
	move.l	#emptysamp,start_end
	move.l	#emptysamp,end_end
forbdv3:
	and.w	#15,d1
	move.w	d1,chan1special
;-------------- channel 2
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	tst.b	d0
	beq	forbdv4
	lea	convtab(pc),a1
	move.b	(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	speedadds,a1
	move.l	(a1,d0.w),chan2bepos
	move.w	d1,d2
	and.w	#-16,d2
	lsr.w	#1,d2
	lea	samp_pet_buff,a1
	move.l	(a1,d2.w),a4
	add.l	#start_buff,a4
	move.l	4(a1,d2.w),endchan2
	move.l	a4,d0
	add.l	d0,endchan2
	sub.l	#over_buff,endchan2

	moveq	#0,d0
	lea	samtab,a1
	lsr.w	#1,d2
	move.w	2(a1,d2.w),d0
	cmp.w	#0,d0
	beq	no_loop2
	move.l	endchan2,start_end2
	move.l	endchan2,end_end2
	sub.l	d0,start_end2
	clr.w	loopch2
	bra	forbdv4
no_loop2:
	move.w	#1,loopch2
	move.l	#emptysamp,start_end2
	move.l	#emptysamp,end_end2
forbdv4:
	and.w	#15,d1
	move.w	d1,chan2special
;-------------- channel 3
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	tst.b	d0
	beq	forbdv5
	lea	convtab(pc),a1
	move.b	(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	speedadds,a1
	move.l	(a1,d0.w),chan3bepos
	move.w	d1,d2
	and.w	#-16,d2
	lsr.w	#1,d2
	lea	samp_pet_buff,a1
	move.l	(a1,d2.w),a5
	add.l	#start_buff,a5
	move.l	4(a1,d2.w),endchan3
	move.l	a5,d0
	add.l	d0,endchan3
	sub.l	#over_buff,endchan3

	moveq	#0,d0
	lea	samtab,a1
	lsr.w	#1,d2
	move.w	2(a1,d2.w),d0
	cmp.w	#0,d0
	beq	no_loop3
	move.l	endchan3,start_end3
	move.l	endchan3,end_end3
	sub.l	d0,start_end3
	clr.w	loopch3
	bra	forbdv5
no_loop3:
	move.w	#1,loopch3
	move.l	#emptysamp,start_end3
	move.l	#emptysamp,end_end3
forbdv5:
	and.w	#15,d1
	move.w	d1,chan3special
;----------- channel 4 - drum-voice
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a0)+,d0
	move.b	(a0)+,d1
	tst.b	d0
	beq	forbdv6
	lea	convtab(pc),a1
	move.b	(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	speedadds,a1
	move.l	(a1,d0.w),chan4bepos
	move.w	d1,d2
	and.w	#-16,d2
	lsr.w	#1,d2
	lea	samp_pet_buff,a1
	move.l	(a1,d2.w),a6
	add.l	#start_buff,a6
	move.l	4(a1,d2.w),endchan4
	move.l	a6,d0
	add.l	d0,endchan4
	sub.l	#over_buff,endchan4

	moveq	#0,d0
	lea	samtab,a1
	lsr.w	#1,d2
	move.w	2(a1,d2.w),d0
	cmp.w	#0,d0
	beq	no_loop4
	move.l	endchan4,start_end4
	move.l	endchan4,end_end4
	sub.l	d0,start_end4
	clr.w	loopch4
	bra	forbdv6
no_loop4:
	move.w	#1,loopch4
	move.l	#emptysamp,start_end4
	move.l	#emptysamp,end_end4
forbdv6:
	and.w	#15,d1
	move.w	d1,chan4special

	move.l	chan2bepos(pc),d0
	sub.l	chan1bepos(pc),d0
	move.l	chan3bepos(pc),d1
	sub.l	chan1bepos(pc),d1
	move.l	chan4bepos(pc),d2
	sub.l	chan1bepos(pc),d2

	move.l	chann1,a0
	move.w	d0,2(a0)
	move.l	chann2,a0
	move.w	d1,2(a0)
	move.l	chann3,a0
	move.w	d2,2(a0)

	move.l	chan1bepos(pc),a2
;	cmp.l	oldchan1bepos(pc),d0
;	beq.s	forbdv19
;	move.l	d0,oldchan1bepos
;	move.l	d0,a2
;forbdv19:
;	add.l	#600,d0
;	move.l	d0,endspeedchan1
	move.w	#$2300,sr
	rts
chanbend:
	move.w	spec_values+2,d2
	jmp	(a0)
chanbend2:
	move.w	spec_values+4,d2
	jmp	(a0)
chanbend3:
	move.w	spec_values+6,d2
	jmp	(a0)
chanbend4:
	move.w	spec_values+8,d2
	jmp	(a0)
chanbend5:
	move.w	spec_values+10,d2
	jmp	(a0)
chanbend6:
	move.w	spec_values+12,d2
	jmp	(a0)
chanbend7:
	move.w	spec_values+14,d2
	jmp	(a0)
chanbend8:
	move.w	spec_values+16,d2
	jmp	(a0)
chanbend9:
	move.w	spec_values+18,d2
	jmp	(a0)
chanbend10:
	move.w	spec_values+20,d2
	jmp	(a0)
do_bend:
	ext.l	d2
	move.l	chan1bepos,d1
	sub.l	d2,d1
	cmp.l	#speedtabs,d1
	blo	xbjÑrk
	cmp.l	#emptysamp-1200,d1
	bge	xbjÑrk2
xbjÑrkare:
	move.l	d1,chan1bepos
	jsr	correct
	bra	frrb2
xbjÑrk:
	move.l	#speedtabs,d1
	bra	xbjÑrkare
xbjÑrk2:
	move.l	#emptysamp-1200,d1
	bra	xbjÑrkare
do_bend2:
	ext.l	d2
	move.l	chan2bepos,d1
	sub.l	d2,d1
	cmp.l	#speedtabs,d1
	blo	x2bjÑrk
	cmp.l	#emptysamp-1200,d1
	bge	x2bjÑrk2
x2bjÑrkare:
	move.l	d1,chan2bepos
	jsr	correct
	bra	frrb3
x2bjÑrk:
	move.l	#speedtabs,d1
	bra	x2bjÑrkare
x2bjÑrk2:
	move.l	#emptysamp-1200,d1
	bra	x2bjÑrkare
do_bend3:
	ext.l	d2
	move.l	chan3bepos,d1
	sub.l	d2,d1
	cmp.l	#speedtabs,d1
	blo	x3bjÑrk
	cmp.l	#emptysamp-1200,d1
	bge	x3bjÑrk2
x3bjÑrkare:
	move.l	d1,chan3bepos
	jsr	correct
	bra	frrb4
x3bjÑrk:
	move.l	#speedtabs,d1
	bra	x3bjÑrkare
x3bjÑrk2:
	move.l	#emptysamp-1200,d1
	bra	x3bjÑrkare
do_bend4:
	ext.l	d2
	move.l	chan4bepos,d1
	sub.l	d2,d1
	cmp.l	#speedtabs,d1
	blo	x4bjÑrk
	cmp.l	#emptysamp-1200,d1
	bge	x4bjÑrk2
x4bjÑrkare:
	move.l	d1,chan4bepos
	jsr	correct
	bra	frrb5
x4bjÑrk:
	move.l	#speedtabs,d1
	bra	x4bjÑrkare
x4bjÑrk2:
	move.l	#emptysamp-1200,d1
	bra	x4bjÑrkare
correct:
	move.l	chan2bepos(pc),d0
	sub.l	chan1bepos(pc),d0
	move.l	chan3bepos(pc),d1
	sub.l	chan1bepos(pc),d1
	move.l	chan4bepos(pc),d2
	sub.l	chan1bepos(pc),d2
	move.l	chann1,a0
	move.w	d0,2(a0)
	move.l	chann2,a0
	move.w	d1,2(a0)
	move.l	chann3,a0
	move.w	d2,2(a0)
	rts

chan1stop:
	move.l	a3,dump2
	move.l	endchan1,dump3
	move.l	start_end,dump4
	move.l	end_end,dump5
	move.w	loopch1,dump6
	cmp.w	#2,spec_values+22
	beq	frrb2
	move.l	#emptysamp,a3
	move.l	#emptysamp,endchan1
	move.w	#1,loopch1
	move.w	#0,chan1special
	bra	frrb2
chan1start:
	cmp.l	#0,dump2
	beq	frrb2
	move.l	dump2,a3
	move.l	dump3,endchan1
	move.l	dump4,start_end
	move.l	dump5,end_end
	move.w	dump6,loopch1
	move.w	#0,chan1special
	jsr	correct
	bra	frrb2
chan2stop:
	move.l	a4,dump22
	move.l	endchan2,dump32
	move.l	start_end2,dump42
	move.l	end_end2,dump52
	move.w	loopch2,dump62
	cmp.w	#2,spec_values+22
	beq	frrb3
	move.l	#emptysamp,a4
	move.l	#emptysamp,endchan2
	move.w	#1,loopch2
	move.w	#0,chan2special
	bra	frrb3
chan2start:
	cmp.l	#0,dump22
	beq	frrb3
	move.l	dump22,a4
	move.l	dump32,endchan2
	move.l	dump42,start_end2
	move.l	dump52,end_end2
	move.w	dump62,loopch2
	move.w	#0,chan2special
	jsr	correct
	bra	frrb3
chan3stop:
	move.l	a5,dump23
	move.l	endchan3,dump33
	move.l	start_end3,dump43
	move.l	end_end3,dump53
	move.w	loopch3,dump63
	cmp.w	#2,spec_values+22
	beq	frrb4
	move.l	#emptysamp,a5
	move.l	#emptysamp,endchan3
	move.w	#1,loopch3
	move.w	#0,chan3special
	bra	frrb4
chan3start:
	cmp.l	#0,dump23
	beq	frrb4
	move.l	dump23,a5
	move.l	dump33,endchan3
	move.l	dump43,start_end3
	move.l	dump53,end_end3
	move.w	dump63,loopch3
	move.w	#0,chan3special
	jsr	correct
	bra	frrb4
chan4stop:
	move.l	a6,dump24
	move.l	endchan4,dump34
	move.l	start_end4,dump44
	move.l	end_end4,dump54
	move.w	loopch4,dump64
	cmp.w	#2,spec_values+22
	beq	frrb5
	move.l	#emptysamp,a6
	move.l	#emptysamp,endchan4
	move.w	#1,loopch4
	move.w	#0,chan4special
	bra	frrb5
chan4start:
	cmp.l	#0,dump24
	beq	frrb5
	move.l	dump24,a6
	move.l	dump34,endchan4
	move.l	dump44,start_end4
	move.l	dump54,end_end4
	move.w	dump64,loopch4
	move.w	#0,chan4special
	jsr	correct
	bra	frrb5
dump2:	dc.l	0
dump3:	dc.l	0
dump4:	dc.l	0
dump5:	dc.l	0
dump6:	dc.l	0
dump22:	dc.l	0
dump32:	dc.l	0
dump42:	dc.l	0
dump52:	dc.l	0
dump62:	dc.l	0
dump23:	dc.l	0
dump33:	dc.l	0
dump43:	dc.l	0
dump53:	dc.l	0
dump63:	dc.l	0
dump24:	dc.l	0
dump34:	dc.l	0
dump44:	dc.l	0
dump54:	dc.l	0
dump64:	dc.l	0

save_spec_values:
	dc.w	0
	dc.w	10
	dc.w	30
	dc.w	50
	dc.w	70
	dc.w	90
	dc.w	-10
	dc.w	-30
	dc.w	-50
	dc.w	-70
	dc.w	-90
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
chan1_end:
	move.b	#$3c,minipek
	clr.w	chan1special
	bra	frrb2
chan2_end:
	move.b	#$3c,minipek
	clr.w	chan2special
	bra	frrb3
chan3_end:
	move.b	#$3c,minipek
	clr.w	chan3special
	bra	frrb4
chan4_end:
	move.b	#$3c,minipek
	clr.w	chan4special
	bra	frrb5
check_spes:
	tst.w	chan1special
	beq	frrb2
	lea	do_bend(pc),a0
	move.w	chan1special(pc),d0
	cmp.w	#1,d0
	beq	chanbend
	cmp.w	#2,d0
	beq	chanbend2
	cmp.w	#3,d0
	beq	chanbend3
	cmp.w	#4,d0
	beq	chanbend4
	cmp.w	#5,d0
	beq	chanbend5
	cmp.w	#6,d0
	beq	chanbend6
	cmp.w	#7,d0
	beq	chanbend7
	cmp.w	#8,d0
	beq	chanbend8
	cmp.w	#9,d0
	beq	chanbend9
	cmp.w	#10,d0
	beq	chanbend10
	cmp.w	#11,d0
	beq	chan1stop
	cmp.w	#12,d0
	beq	chan1start
	cmp.w	#13,d0
	beq	chan1_end
frrb2:
	tst.w	chan2special
	beq	frrb3
	lea	do_bend2(pc),a0
	move.w	chan2special(pc),d0
	cmp.w	#1,d0
	beq	chanbend
	cmp.w	#2,d0
	beq	chanbend2
	cmp.w	#3,d0
	beq	chanbend3
	cmp.w	#4,d0
	beq	chanbend4
	cmp.w	#5,d0
	beq	chanbend5
	cmp.w	#6,d0
	beq	chanbend6
	cmp.w	#7,d0
	beq	chanbend7
	cmp.w	#8,d0
	beq	chanbend8
	cmp.w	#9,d0
	beq	chanbend9
	cmp.w	#10,d0
	beq	chanbend10
	cmp.w	#11,d0
	beq	chan2stop
	cmp.w	#12,d0
	beq	chan2start
	cmp.w	#13,d0
	beq	chan2_end
frrb3:
	tst.w	chan3special
	beq	frrb4
	lea	do_bend3(pc),a0
	move.w	chan3special(pc),d0
	cmp.w	#1,d0
	beq	chanbend
	cmp.w	#2,d0
	beq	chanbend2
	cmp.w	#3,d0
	beq	chanbend3
	cmp.w	#4,d0
	beq	chanbend4
	cmp.w	#5,d0
	beq	chanbend5
	cmp.w	#6,d0
	beq	chanbend6
	cmp.w	#7,d0
	beq	chanbend7
	cmp.w	#8,d0
	beq	chanbend8
	cmp.w	#9,d0
	beq	chanbend9
	cmp.w	#10,d0
	beq	chanbend10
	cmp.w	#11,d0
	beq	chan3stop
	cmp.w	#12,d0
	beq	chan3start
	cmp.w	#13,d0
	beq	chan3_end
frrb4:
	tst.w	chan4special
	beq	frrb5
	lea	do_bend4(pc),a0
	move.w	chan4special(pc),d0
	cmp.w	#1,d0
	beq	chanbend
	cmp.w	#2,d0
	beq	chanbend2
	cmp.w	#3,d0
	beq	chanbend3
	cmp.w	#4,d0
	beq	chanbend4
	cmp.w	#5,d0
	beq	chanbend5
	cmp.w	#6,d0
	beq	chanbend6
	cmp.w	#7,d0
	beq	chanbend7
	cmp.w	#8,d0
	beq	chanbend8
	cmp.w	#9,d0
	beq	chanbend9
	cmp.w	#10,d0
	beq	chanbend10
	cmp.w	#11,d0
	beq	chan4stop
	cmp.w	#12,d0
	beq	chan4start
	cmp.w	#13,d0
	beq	chan4_end
frrb5:
	rts

forbdv:						********
************* well.. nick hummmm! ****************
	jsr	check_spes

;--------- bend channel 1?????????
;	cmp.l	endspeedchan1(pc),a2
;	blt.s	forbdv11
	move.l	chan1bepos(pc),a2
;forbdv11:

	cmp.l	endchan1(pc),a3
	blt.s	forbdv12
	cmp.w	#1,loopch1
	beq	noch1
	sub.l	endchan1,a3
	add.l	start_end,a3
	move.l	end_end,endchan1
	bra.s	forbdv12
noch1:
	move.l	#emptysamp,a3
	move.l	#emptysamp,endchan1
forbdv12:
	cmp.l	endchan2(pc),a4
	blt.s	forbdv13
	cmp.w	#1,loopch2
	beq	noch2
	sub.l	endchan2,a4
	add.l	start_end2,a4
	move.l	end_end2,endchan2
	bra.s	forbdv13
noch2:
	move.l	#emptysamp,a4
	move.l	#emptysamp,endchan2
forbdv13:
	cmp.l	endchan3(pc),a5
	blt.s	forbdv14
	cmp.w	#1,loopch3
	beq	noch3
	sub.l	endchan3,a5
	add.l	start_end3,a5
	move.l	end_end3,endchan3
	bra.s	forbdv14
noch3:
	move.l	#emptysamp,a5
	move.l	#emptysamp,endchan3
forbdv14:
	cmp.l	endchan4(pc),a6
	blt.s	forbdv15
	cmp.w	#1,loopch4
	beq	noch4
	sub.l	endchan4,a6
	add.l	start_end4,a6
	move.l	end_end4,endchan4
	bra.s	forbdv15
noch4:
	move.l	#emptysamp,a6
	move.l	#emptysamp,endchan4
forbdv15:
	rts
chann1:
	dc.l	vec11
chann2:
	dc.l	vec12
chann3:
	dc.l	vec13
start_end:
	dc.l	emptysamp
start_end2:
	dc.l	emptysamp
start_end3:
	dc.l	emptysamp
start_end4:
	dc.l	emptysamp
end_end:
	dc.l	emptysamp
end_end2:
	dc.l	emptysamp
end_end3:
	dc.l	emptysamp
end_end4:
	dc.l	emptysamp
loopch1:
	dc.w	1
loopch2:
	dc.w	1
loopch3:
	dc.w	1
loopch4:
	dc.w	1

convtab:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,0,0,0,0
	dc.b	12,13,14,15,16,17,18,19,20,21,22,23,0,0,0,0
	dc.b	24,25,26,27,28,29,30,31,32,33,34,35,0,0,0,0
	even

chan1bepos:	dc.l	speedtabs
oldchan1bepos:	dc.l	0
chan2bepos:	dc.l	speedtabs
chan3bepos:	dc.l	speedtabs
chan4bepos:	dc.l	speedtabs
endspeedchan1:	dc.l	speedtabs
chan1special:	dc.w	0
chan2special:	dc.w	0
chan3special:	dc.w	0
chan4special:	dc.w	0
endchan1:	dc.l	emptysamp
endchan2:	dc.l	emptysamp
endchan3:	dc.l	emptysamp
endchan4:	dc.l	emptysamp
speedadds:	ds.l	37
speedtabs:	ds.w	400*37
emptysamp:	dcb.b	1000,128

makespeedtabs:
	move.w	#36,d0
	lea	midspeeddata-12*4(pc),a0
	lea	speedtabs,a1
	lea	speedadds,a2
omsp:	move.l	(a0)+,d1
	move.l	a1,(a2)+
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	move.w	#399,d7
omsp2:	
	add.l	d1,d2
	move.l	d2,d3
	lsr.l	#8,d3
	lsr.l	#8,d3		;7 for 15khz samples and 7.5 rout!
	sub.w	d3,d4
	neg.w	d4
	move.w	d4,(a1)+
	move.w	d3,d4
	dbra	d7,omsp2
	dbra	d0,omsp
	rts		


speeddata:
 dc.l 8192,8679,9195,9741,10321,10935
 dc.l 11585,12274,13003,13777,14596,15464
 dc.l 16384,17358,18390,19483,20642,21870
 dc.l 23170,24548,26007,27554,29192,30928
 dc.l 32768,34716,36780,38967,41285,43740
 dc.l 46340,49096,52015,55108,58385,61857
midspeeddata:
 dc.l 65536,69432,73561,77935,82570,87480
 dc.l 92681,98193,104031,110217,116771,123715
 dc.l 131072,138865,147123,155871,165140,174960
 dc.l 185363,196386,208063,220435,233543,247430
 dc.l 262144,277731,294246,311743,330280,349920
 dc.l 370727,392772,416127,440871,467087,494861
 dc.l 524288


intsamp:
	move.w	#$2700,sr
	moveq	#10,d0
omis:	
	move.b	d0,$ffff8800.w
	clr.b	$ffff8802.w
	dbra	d0,omis
	move.b	#7,$ffff8800
	move.b	#%11111111,$ffff8802
	move.w	#$2300,sr
	rts


conv_imp:
	move.w	#255,d2
	lea	imptab+4(pc),a0
.loop:	move.b	(a0),d0
	move.b	1(a0),d1
	move.b	d0,(a0)+
	move.b	d0,(a0)+
	move.b	d1,(a0)+
	move.b	d1,(a0)+
	lea	4(a0),a0
	dbra	d2,.loop

;------ megafix imptab!!!!!!!!!!!!
	lea	imptab(pc),a0
	lea	384*8(a0),a1	;dont ask, believe!
	move.w	#255,d0
.loop2:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.loop2
;--- fill top of imp
	lea	imptab(pc),a0
	move.w	#384-1,d0
	move.l	(a0),d1
	move.l	4(a0),d2
.loop3:	move.l	d1,(a0)+
	move.l	d2,(a0)+
	dbra	d0,.loop3
;---- fill bottom
	move.w	#1024-384-256-1,d0
	move.l	-8(a1),d1
	move.l	-4(a1),d2
.loop4:	move.l	d1,(a1)+
	move.l	d2,(a1)+
	dbra	d0,.loop4
	rts

samp1ste2:
	nop
	nop
	nop
	move.l	d5,-(sp)
	moveq	#0,d7			;1
	moveq	#0,d6			;1
	move.b	(a6),d7		;2
	move.b	(a5),d6			;2
	add.w	d6,d7			;1
	move.b	(a4),d6			;2
	add.w	d6,d7			;1
	move.b	(a3),d6			;2
	add.w	d6,d7			;1
	move.w	d7,d5
	lsr.w	#2,d7
	sub.b	#$80,d7
	move.b	d7,left
	move.b	d7,right
	asl.w	#3,d5		
no_areg3:
	move.w	d5,freaky_brother
	addq.l	#2,no_areg3+2
vec11e2:
	add.w	0(a2),a4		;4
vec12e2:
	add.w	0(a2),a5		;4
vec13e2:
	add.w	0(a2),a6		;4
	add.w	(a2)+,a3		;3

	move.l	(sp)+,d5
	rte


samp1:
	*******************************************************
	move.l	a1,usp			;1
	moveq	#0,d7			;1
	moveq	#0,d6			;1
	move.b	(a6),d7		;2
	move.b	(a5),d6			;2
	add.w	d6,d7			;1
	move.b	(a4),d6			;2
	add.w	d6,d7			;1
	move.b	(a3),d6			;2
	add.w	d6,d7			;1
	asl.w	#3,d7			;3
*bulleballboll************************************

no_areg:
	move.w	d7,freaky_brother
	addq.l	#2,no_areg+2
	
**************************************************
	lea	$ffff8800.w,a1		;2
	move.l	imptab(pc,d7.w),d6	;4
	movep.l	d6,(a1)			;7
	move.l	imptab+4(pc,d7.w),(a1)	;6
vec11:	add.w	0(a2),a4		;4
vec12:	add.w	0(a2),a5		;4
vec13:	add.w	0(a2),a6		;4
	add.w	(a2)+,a3		;3
	move.l	usp,a1			;1
	* 48 nop (192 pellefjants) ****************************
	rte

samp1ste:
	move.l	d5,-(sp)
	moveq	#0,d7			;1
	moveq	#0,d6			;1
	move.b	(a3),d7		;2
	move.b	(a6),d6			;2
	add.w	d6,d7			;1
	move.w	d7,d5
	lsr.w	#1,d7
	sub.b	#$80,d7
	move.b	d7,left
	move.b	(a4),d7			;2
	move.b	(a5),d6			;2
	add.w	d6,d7			;1
	add.w	d7,d5
	lsr.w	#1,d7
	sub.b	#$80,d7
	move.b	d7,right
	asl.w	#3,d5		
no_areg2:
	move.w	d5,freaky_brother
	addq.l	#2,no_areg2+2

vec11e:	add.w	0(a2),a4		;4
vec12e:	add.w	0(a2),a5		;4
vec13e:	add.w	0(a2),a6		;4
	add.w	(a2)+,a3		;3
	move.l	(sp)+,d5
	rte

imptab: 	 ;this is the output from "IMPACT" it's not our own
	ds.l	512
 ds.w 4*256*3	;resterande bullshit

	* digi-rout end *********************************** 
imptab2:
 dc.w $80E,$90D,$A0C,$0,$80F,$903,$A00,$0,$80F,$903,$A00,$0,$80F,$903,$A00,0
 dc.w $80F,$903,$A00,$0,$80F,$903,$A00,$0,$80F,$903,$A00,$0,$80E,$90D,$A0B,0
 dc.w $80E,$90D,$A0B,$0,$80E,$90D,$A0B,$0,$80E,$90D,$A0B,$0,$80E,$90D,$A0B,0
 dc.w $80E,$90D,$A0B,$0,$80E,$90D,$A0B,$0,$80E,$90D,$A0A,$0,$80E,$90D,$A0A,0
 dc.w $80E,$90D,$A0A,$0,$80E,$90D,$A0A,$0,$80E,$90C,$A0C,$0,$80E,$90D,$A00,0
 dc.w $80D,$90D,$A0D,$0,$80D,$90D,$A0D,$0,$80D,$90D,$A0D,$0,$80D,$90D,$A0D,0
 dc.w $80D,$90D,$A0D,$0,$80D,$90D,$A0D,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0B,0
 dc.w $80E,$90C,$A0B,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0B,0
 dc.w $80E,$90C,$A0B,$0,$80E,$90C,$A0B,$0,$80E,$90C,$A0A,$0,$80E,$90C,$A0A,0
 dc.w $80E,$90C,$A0A,$0,$80E,$90C,$A0A,$0,$80D,$90D,$A0C,$0,$80D,$90D,$A0C,0
 dc.w $80E,$90C,$A09,$0,$80E,$90C,$A09,$0,$80E,$90C,$A05,$0,$80E,$90C,$A00,0
 dc.w $80E,$90C,$A00,$0,$80E,$90B,$A0B,$0,$80E,$90B,$A0B,$0,$80E,$90B,$A0B,0
 dc.w $80E,$90B,$A0B,$0,$80E,$90B,$A0A,$0,$80E,$90B,$A0A,$0,$80E,$90B,$A0A,0
 dc.w $80D,$90D,$A0B,$0,$80D,$90D,$A0B,$0,$80D,$90D,$A0B,$0,$80E,$90B,$A09,0
 dc.w $80E,$90B,$A09,$0,$80E,$90B,$A09,$0,$80D,$90C,$A0C,$0,$80D,$90D,$A0A,0
 dc.w $80E,$90B,$A07,$0,$80E,$90B,$A00,$0,$80E,$90B,$A00,$0,$80D,$90D,$A09,0
 dc.w $80D,$90D,$A09,$0,$80E,$90A,$A09,$0,$80D,$90D,$A08,$0,$80D,$90D,$A07,0
 dc.w $80D,$90D,$A04,$0,$80D,$90D,$A00,$0,$80E,$90A,$A04,$0,$80E,$909,$A09,0
 dc.w $80E,$909,$A09,$0,$80D,$90C,$A0B,$0,$80E,$909,$A08,$0,$80E,$909,$A08,0
 dc.w $80E,$909,$A07,$0,$80E,$908,$A08,$0,$80E,$909,$A01,$0,$80C,$90C,$A0C,0
 dc.w $80D,$90C,$A0A,$0,$80E,$908,$A06,$0,$80E,$907,$A07,$0,$80E,$908,$A00,0
 dc.w $80E,$907,$A05,$0,$80E,$906,$A06,$0,$80D,$90C,$A09,$0,$80E,$905,$A05,0
 dc.w $80E,$904,$A04,$0,$80D,$90C,$A08,$0,$80D,$90B,$A0B,$0,$80E,$900,$A00,0
 dc.w $80D,$90C,$A06,$0,$80D,$90C,$A05,$0,$80D,$90C,$A02,$0,$80C,$90C,$A0B,0
 dc.w $80C,$90C,$A0B,$0,$80D,$90B,$A0A,$0,$80D,$90B,$A0A,$0,$80D,$90B,$A0A,0
 dc.w $80D,$90B,$A0A,$0,$80C,$90C,$A0A,$0,$80C,$90C,$A0A,$0,$80C,$90C,$A0A,0
 dc.w $80D,$90B,$A09,$0,$80D,$90B,$A09,$0,$80D,$90A,$A0A,$0,$80D,$90A,$A0A,0
 dc.w $80D,$90A,$A0A,$0,$80C,$90C,$A09,$0,$80C,$90C,$A09,$0,$80C,$90C,$A09,0
 dc.w $80D,$90B,$A06,$0,$80C,$90B,$A0B,$0,$80C,$90C,$A08,$0,$80D,$90B,$A00,0
 dc.w $80D,$90B,$A00,$0,$80C,$90C,$A07,$0,$80C,$90C,$A06,$0,$80C,$90C,$A05,0
 dc.w $80C,$90C,$A03,$0,$80C,$90C,$A01,$0,$80C,$90B,$A0A,$0,$80D,$90A,$A05,0
 dc.w $80D,$90A,$A04,$0,$80D,$90A,$A02,$0,$80D,$909,$A08,$0,$80D,$909,$A08,0
 dc.w $80C,$90B,$A09,$0,$80C,$90B,$A09,$0,$80D,$908,$A08,$0,$80B,$90B,$A0B,0
 dc.w $80D,$909,$A05,$0,$80C,$90B,$A08,$0,$80D,$909,$A02,$0,$80D,$908,$A06,0
 dc.w $80C,$90B,$A07,$0,$80D,$907,$A07,$0,$80C,$90B,$A06,$0,$80C,$90A,$A09,0
 dc.w $80B,$90B,$A0A,$0,$80C,$90B,$A02,$0,$80C,$90B,$A00,$0,$80C,$90A,$A08,0
 dc.w $80D,$906,$A04,$0,$80D,$905,$A05,$0,$80D,$905,$A04,$0,$80C,$909,$A09,0
 dc.w $80D,$904,$A03,$0,$80B,$90B,$A09,$0,$80C,$90A,$A05,$0,$80B,$90A,$A0A,0
 dc.w $80C,$909,$A08,$0,$80B,$90B,$A08,$0,$80C,$90A,$A00,$0,$80C,$90A,$A00,0
 dc.w $80C,$909,$A07,$0,$80B,$90B,$A07,$0,$80C,$909,$A06,$0,$80B,$90B,$A06,0
 dc.w $80B,$90A,$A09,$0,$80B,$90B,$A05,$0,$80A,$90A,$A0A,$0,$80B,$90B,$A02,0
 dc.w $80B,$90A,$A08,$0,$80C,$907,$A07,$0,$80C,$908,$A04,$0,$80C,$907,$A06,0
 dc.w $80B,$909,$A09,$0,$80C,$906,$A06,$0,$80A,$90A,$A09,$0,$80C,$907,$A03,0
 dc.w $80B,$90A,$A05,$0,$80B,$909,$A08,$0,$80B,$90A,$A03,$0,$80A,$90A,$A08,0
 dc.w $80B,$90A,$A00,$0,$80B,$909,$A07,$0,$80B,$908,$A08,$0,$80A,$90A,$A07,0
 dc.w $80A,$909,$A09,$0,$80C,$901,$A01,$0,$80A,$90A,$A06,$0,$80B,$908,$A07,0
 dc.w $80A,$90A,$A05,$0,$80A,$909,$A08,$0,$80A,$90A,$A02,$0,$80A,$90A,$A01,0
 dc.w $80A,$90A,$A00,$0,$809,$909,$A09,$0,$80A,$908,$A08,$0,$80B,$908,$A01,0
 dc.w $80A,$909,$A06,$0,$80B,$907,$A04,$0,$80A,$909,$A05,$0,$809,$909,$A08,0
 dc.w $80A,$909,$A03,$0,$80A,$908,$A06,$0,$80A,$909,$A00,$0,$809,$909,$A07,0
 dc.w $809,$908,$A08,$0,$80A,$908,$A04,$0,$809,$909,$A06,$0,$80A,$908,$A01,0
 dc.w $809,$909,$A05,$0,$809,$908,$A07,$0,$808,$908,$A08,$0,$809,$909,$A02,0
 dc.w $809,$908,$A06,$0,$809,$909,$A00,$0,$809,$907,$A07,$0,$808,$908,$A07,0
 dc.w $809,$907,$A06,$0,$809,$908,$A02,$0,$808,$908,$A06,$0,$809,$906,$A06,0
 dc.w $808,$907,$A07,$0,$808,$908,$A04,$0,$808,$907,$A06,$0,$808,$908,$A02,0
 dc.w $807,$907,$A07,$0,$808,$906,$A06,$0,$808,$907,$A04,$0,$807,$907,$A06,0
 dc.w $808,$906,$A05,$0,$808,$906,$A04,$0,$807,$906,$A06,$0,$807,$907,$A04,0
 dc.w $808,$905,$A04,$0,$806,$906,$A06,$0,$807,$906,$A04,$0,$807,$905,$A05,0
 dc.w $806,$906,$A05,$0,$806,$906,$A04,$0,$806,$905,$A05,$0,$806,$906,$A02,0
 dc.w $806,$905,$A04,$0,$805,$905,$A05,$0,$806,$905,$A02,$0,$805,$905,$A04,0
 dc.w $805,$904,$A04,$0,$805,$905,$A02,$0,$804,$904,$A04,$0,$804,$904,$A03,0
 dc.w $804,$904,$A02,$0,$804,$903,$A03,$0,$803,$903,$A03,$0,$803,$903,$A02,0
 dc.w $803,$902,$A02,$0,$802,$902,$A02,$0,$802,$902,$A01,$0,$801,$901,$A01,0
 dc.w $802,$901,$A00,$0,$801,$901,$A00,$0,$801,$900,$A00,$0,$800,$900,$A00,0

imptab3:
	dc.b	$08,$01,$09,$00,$0A,$00,$00,$00
	dc.b	$08,$01,$09,$00,$0A,$00,$00,$00
	dc.b	$08,$01,$09,$01,$0A,$00,$00,$00
	dc.b	$08,$01,$09,$01,$0A,$00,$00,$00
	dc.b	$08,$01,$09,$01,$0A,$01,$00,$00
	dc.b	$08,$01,$09,$01,$0A,$01,$00,$00
	dc.b	$08,$01,$09,$01,$0A,$02,$00,$00
	dc.b	$08,$01,$09,$01,$0A,$02,$00,$00
	dc.b	$08,$01,$09,$02,$0A,$02,$00,$00
	dc.b	$08,$01,$09,$02,$0A,$02,$00,$00
	dc.b	$08,$02,$09,$02,$0A,$02,$00,$00
	dc.b	$08,$02,$09,$02,$0A,$02,$00,$00
	dc.b	$08,$01,$09,$03,$0A,$03,$00,$00
	dc.b	$08,$01,$09,$03,$0A,$03,$00,$00
	dc.b	$08,$02,$09,$03,$0A,$03,$00,$00
	dc.b	$08,$02,$09,$03,$0A,$03,$00,$00
	dc.b	$08,$03,$09,$03,$0A,$03,$00,$00
	dc.b	$08,$03,$09,$03,$0A,$03,$00,$00
	dc.b	$08,$02,$09,$03,$0A,$04,$00,$00
	dc.b	$08,$02,$09,$03,$0A,$04,$00,$00
	dc.b	$08,$03,$09,$03,$0A,$04,$00,$00
	dc.b	$08,$03,$09,$03,$0A,$04,$00,$00
	dc.b	$08,$02,$09,$04,$0A,$04,$00,$00
	dc.b	$08,$02,$09,$04,$0A,$04,$00,$00
	dc.b	$08,$03,$09,$04,$0A,$04,$00,$00
	dc.b	$08,$03,$09,$04,$0A,$04,$00,$00
	dc.b	$08,$02,$09,$04,$0A,$05,$00,$00
	dc.b	$08,$02,$09,$04,$0A,$05,$00,$00
	dc.b	$08,$03,$09,$04,$0A,$05,$00,$00
	dc.b	$08,$03,$09,$04,$0A,$05,$00,$00
	dc.b	$08,$02,$09,$05,$0A,$05,$00,$00
	dc.b	$08,$02,$09,$05,$0A,$05,$00,$00
	dc.b	$08,$03,$09,$05,$0A,$05,$00,$00
	dc.b	$08,$03,$09,$05,$0A,$05,$00,$00
	dc.b	$08,$01,$09,$05,$0A,$06,$00,$00
	dc.b	$08,$01,$09,$05,$0A,$06,$00,$00
	dc.b	$08,$02,$09,$05,$0A,$06,$00,$00
	dc.b	$08,$02,$09,$05,$0A,$06,$00,$00
	dc.b	$08,$03,$09,$05,$0A,$06,$00,$00
	dc.b	$08,$03,$09,$05,$0A,$06,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$06,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$06,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$06,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$06,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$06,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$06,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$07,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$07,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$07,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$07,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$07,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$07,$00,$00
	dc.b	$08,$00,$09,$07,$0A,$07,$00,$00
	dc.b	$08,$00,$09,$07,$0A,$07,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$07,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$07,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$07,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$07,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$07,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$07,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$08,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$08,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$08,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$08,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$08,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$08,$00,$00
	dc.b	$08,$00,$09,$07,$0A,$08,$00,$00
	dc.b	$08,$00,$09,$07,$0A,$08,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$08,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$08,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$08,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$08,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$08,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$08,$00,$00
	dc.b	$08,$00,$09,$06,$0A,$09,$00,$00
	dc.b	$08,$00,$09,$06,$0A,$09,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$09,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$09,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$09,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$09,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$09,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$09,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$09,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$09,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$09,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$09,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$09,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$09,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$09,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$09,$00,$00
	dc.b	$08,$00,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$00,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$09,$00,$00
	dc.b	$08,$00,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$00,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$0A,$00,$00
	dc.b	$08,$00,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$00,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$0A,$00,$00
	dc.b	$08,$00,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$00,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$04,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$04,$09,$06,$0A,$0B,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$0B,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$0B,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$0B,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$0B,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$0B,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$0B,$00,$00
	dc.b	$08,$00,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$00,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$0B,$00,$00
	dc.b	$08,$01,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$01,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$02,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$02,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$03,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$03,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$04,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$04,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$05,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$05,$09,$0A,$0A,$0A,$00,$00
	dc.b	$08,$04,$09,$09,$0A,$0B,$00,$00
	dc.b	$08,$04,$09,$09,$0A,$0B,$00,$00
	dc.b	$08,$05,$09,$09,$0A,$0B,$00,$00
	dc.b	$08,$05,$09,$09,$0A,$0B,$00,$00
	dc.b	$08,$00,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$00,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$04,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$05,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$05,$0A,$0C,$00,$00
	dc.b	$08,$05,$09,$05,$0A,$0C,$00,$00
	dc.b	$08,$05,$09,$05,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$05,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$05,$09,$07,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$05,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$05,$09,$08,$0A,$0C,$00,$00
	dc.b	$08,$00,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$00,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$05,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$05,$09,$09,$0A,$0C,$00,$00
	dc.b	$08,$06,$09,$0B,$0A,$0B,$00,$00
	dc.b	$08,$06,$09,$0B,$0A,$0B,$00,$00
	dc.b	$08,$07,$09,$0B,$0A,$0B,$00,$00
	dc.b	$08,$07,$09,$0B,$0A,$0B,$00,$00
	dc.b	$08,$00,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$00,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$02,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$03,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$04,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$05,$09,$0A,$0A,$0C,$00,$00
	dc.b	$08,$01,$09,$05,$0A,$0D,$00,$00
	dc.b	$08,$02,$09,$05,$0A,$0D,$00,$00
	dc.b	$08,$03,$09,$05,$0A,$0D,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$01,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$02,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$03,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$04,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$04,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$05,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$05,$09,$06,$0A,$0D,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$0D,$00,$00
	dc.b	$08,$04,$09,$07,$0A,$0D,$00,$00
	dc.b	$08,$05,$09,$07,$0A,$0D,$00,$00
	dc.b	$08,$05,$09,$07,$0A,$0D,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$01,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$02,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$03,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$04,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$05,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$05,$09,$08,$0A,$0D,$00,$00
	dc.b	$08,$00,$09,$09,$0A,$0D,$00,$00
	dc.b	$08,$00,$09,$09,$0A,$0D,$00,$00
	dc.b	$08,$01,$09,$09,$0A,$0D,$00,$00
	dc.b	$08,$01,$09,$09,$0A,$0D,$00,$00
	dc.b	$08,$02,$09,$09,$0A,$0D,$00,$00
	dc.b	$08,$02,$09,$09,$0A,$0D,$00,$00
	dc.b	$08,$03,$09,$09,$0A,$0D,$00,$00
	dc.b	$08,$03,$09,$09,$0A,$0D,$00,$00
proc_mouse:
	cmp.w	#1,mouse_flg
	beq	true_edit


	move.w	my,d0
	moveq	#0,d1
	move.b	mausmsg,d1
	clr.b	mausmsg
	ext.w	d1
	tst.w	turbo_m
	beq.s	no_turbo_m
	muls	#5,d1
	divs	#3,d1
no_turbo_m:
	add.w	d1,d0
	bpl.s	mausy0ok
	move.w	#0,d0
mausy0ok:
	cmp.w	#200-82,d0
	bmi.s	mausy1ok
	move.w	#199-82,d0
mausy1ok:
	move.w	d0,my
	move.w	mx,d0
	moveq	#0,d1
	move.b	mausmsg+1,d1
	clr.b	mausmsg+1
	ext.w	d1
	tst.w	turbo_m
	beq.s	no_turbo_m2
	muls	#5,d1
	divs	#3,d1
no_turbo_m2:
	add.w	d1,d0
	bpl.s	mausx0ok
	move.w	#319,d0
mausx0ok:
	cmp.w	#320,d0
	bmi.s	mausx1ok
	move.w	#0,d0
mausx1ok:
	move.w	d0,mx
ioio:
	cmp.w	#1,mouse_flg
	beq	true_edit

	moveq	#0,d0
	moveq	#0,d1
	move.l	screen_start,a0
	lea	mouse_shifts,a1

	moveq	#0,d0
	move.w	my,d0
	mulu	#160,d0
	add.l	d0,a0
	moveq	#0,d0
	move.w	mx,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	add.l	d0,a0

	moveq	#0,d0
	move.w	mx,d0
	and.l	#15,d0
	mulu	#256,d0
	add.l	d0,a1

	move.l	a1,-(sp)
	lea	save_buff,a1
	move.l	a0,save_olpos
num	set	0
	rept	16
	move.l	num(a0),(a1)+
	move.w	num+6(a0),(a1)+
	move.l	num+8(a0),(a1)+
	move.w	num+14(a0),(a1)+
num	set	num+160
	endr
	move.l	(sp)+,a1
num	set	0
	rept	16
	move.l	(a1)+,d0
	move.l	(a1)+,d1
	move.l	(a1)+,d2
	move.l	(a1)+,d3
	and.l	d3,num(a0)
	and.w	d3,num+6(a0)
	and.l	d2,num+8(a0)
	and.w	d2,num+14(a0)
	or.l	d1,num(a0)
	or.l	d0,num+8(a0)
num	set	num+160
	endr
	rts
restor_back:
	cmp.w	#1,mouse_flg
	beq	nono
	move.l	save_olpos,a0
	cmp.l	#0,a0
	beq	nono
	lea	save_buff,a1
num	set	0
	rept	16
	move.l	(a1)+,num(a0)
	move.w	(a1)+,num+6(a0)
	move.l	(a1)+,num+8(a0)
	move.w	(a1)+,num+14(a0)
num	set	num+160
	endr
nono:
	rts
agare:
	dc.w	0
bgare:
	dc.w	0
true_edit:
	move.w	agare,d1
	move.b	mausmsg,d0
	clr.b	mausmsg
	ext.w	d0
	add.w	d0,d1
	move.w	d1,agare
	lsr.w	#3,d1
	cmp.w	#0,d1
	beq	xkiller
	move.w	#4,agare
	moveq	#0,d2
	move.b	minipek,d2
	add.w	d1,d2
	and.w	#%0000000000111111,d2
	move.b	d2,minipek
	cmp.w	#1,play_flag
	beq	no_line_play
	cmp.w	#0,monon
	beq	no_line_play
	move.w	d1,-(sp)
	jsr	play_line
	move.w	(sp)+,d1
no_line_play:
xkiller:
	move.w	bgare,d1
	move.b	mausmsg+1,d0
	clr.b	mausmsg+1
	ext.w	d0
	add.w	d0,d1
	move.w	d1,bgare
	lsr.w	#5,d1
	and.w	#3,d1
	move.b	d1,miniminipek
	rts
norepeat:
	dc.w	0
xms_sam:
	cmp.w	#-1,repet_num
	beq	kesohead
	sub.w	#1,repet_num
	rts
kesohead:
	move.w	#10,repet_num
	bra	ms_sam
xms_sam2:
	cmp.w	#-1,repet_num
	beq	kesohead2
	sub.w	#1,repet_num
	rts
kesohead2:
	move.w	#5,repet_num
	bra	ms_sam2
mouse_event:
	cmp.b	#2,mbutton
	beq.s	chk_pos
	cmp.b	#1,mbutton
	beq	xms_sam
	cmp.b	#3,mbutton
	beq	xms_sam2
	move.w	#-1,repet_num
	rts
chk_pos:
	cmp.w	#1,select_allert
	bne	nejnej
	lea	select_postab,a0
	jsr	go_mous
	bra	ms_aexit
nejnej:
	move.w	repet_num,save_repet_num
	cmp.w	#1,file_allert
	bne	nejnejnej
	lea	file_postab,a0
	jsr	go_mous
	cmp.l	#-1,d0
	beq	ms_aexit
nejnejnej:
	lea	postab,a0
	move.w	save_repet_num,repet_num
	jsr	go_mous
	rts
save_repet_num:
	dc.w	0
go_mous:
	move.w	mx,d0
	move.w	my,d1
again:	
	tst.w	(a0)
	bmi.s	ms_aexit
	cmp.w	(a0),d0
	blt.s 	ms_nxtbox
	cmp.w	2(a0),d1
	blt.s	ms_nxtbox
	cmp.w	4(a0),d0
	bhi.s	ms_nxtbox
	cmp.w	6(a0),d1
	bhi.s	ms_nxtbox
	cmp.w	#-1,repet_num
	beq.s	first_repet
	sub.w	#1,repet_num
	bpl.s	ms_aexit2
	move.l	8(a0),a1
	jsr	(a1)
	move.w	#2,repet_num
	bra	ms_aexit2
ms_nxtbox:
	add.l	#12,a0
	bra	again
ms_aexit:	
	rts
ms_aexit2:
	moveq	#-1,d0
	rts
first_repet:
	move.w	#20,repet_num
	move.l	8(a0),a1
	jsr	(a1)
	moveq	#-1,d0
	rts
repet_num:
	dc.w	-1
blatt:
	move.b	0(a0,d0.w),160*0(a1)
	move.b	1(a0,d0.w),160*1(a1)
	move.b	2(a0,d0.w),160*2(a1)
	move.b	3(a0,d0.w),160*3(a1)
	move.b	4(a0,d0.w),160*4(a1)
	move.b	5(a0,d0.w),160*5(a1)
	move.b	6(a0,d0.w),160*6(a1)
	rts
ms_cords:
	eor.w	#1,cords_on
	rts
cords_on:
	dc.w	1
proc_hex:
	cmp.w	#1,cords_on
	beq	no_cord

	lea	hex_tab,a0
	moveq	#0,d0
	move.b	save_key,d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*48)+(9*8),a1
	jsr	blatt(pc)
	moveq	#0,d0
	move.b	save_key,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*48)+(9*8)+1,a1
	jsr	blatt(pc)

	move.w	my,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*80)+(8*8),a1
	jsr	blatt(pc)
	move.w	my,d0
	and.w	#$0f00,d0
	lsr.w	#8,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*80)+(8*8)+1,a1
	jsr	blatt(pc)
	move.w	my,d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*80)+(9*8),a1
	jsr	blatt(pc)
	move.w	my,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*80)+(9*8)+1,a1
	jsr	blatt(pc)

	move.w	mx,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*40)+(8*8),a1
	jsr	blatt(pc)
	move.w	mx,d0
	and.w	#$0f00,d0
	lsr.w	#8,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*40)+(8*8)+1,a1
	jsr	blatt(pc)
	move.w	mx,d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*40)+(9*8),a1
	jsr	blatt(pc)
	move.w	mx,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*40)+(9*8)+1,a1
	jsr	blatt(pc)

	move.w	midi_buf,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*56)+(8*8),a1
	jsr	blatt(pc)
	move.w	midi_buf,d0
	and.w	#$0f00,d0
	lsr.w	#8,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*56)+(8*8)+1,a1
	jsr	blatt(pc)
	move.w	midi_buf,d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*56)+(9*8),a1
	jsr	blatt(pc)
	move.w	midi_buf,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*56)+(9*8)+1,a1
	jsr	blatt(pc)

	move.w	midi_buf+2,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*64)+(8*8),a1
	jsr	blatt(pc)
	move.w	midi_buf+2,d0
	and.w	#$0f00,d0
	lsr.w	#8,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*64)+(8*8)+1,a1
	jsr	blatt(pc)
	move.w	midi_buf+2,d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*64)+(9*8),a1
	jsr	blatt(pc)
	move.w	midi_buf+2,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	move.l	screen_start,a1
	add.l	#(160*64)+(9*8)+1,a1
	jsr	blatt(pc)
no_cord:
	rts		
print_hex:
	lea	hex_tab,a0
	move.b	d1,d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	jsr	blatt(pc)
	move.b	d1,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	addq.l	#1,a1
	jsr	blatt(pc)
	rts
print_hex2:
	lea	hex_tab,a0
	move.b	d1,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	jsr	blatt(pc)
	rts
print_hex3:
	lea	hex_tab,a0
	move.w	d1,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	jsr	blatt(pc)
	move.w	d1,d0
	and.w	#$0f00,d0
	lsr.w	#8,d0
	lsl.w	#3,d0
	addq.l	#1,a1
	jsr	blatt(pc)
	move.w	d1,d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	lsl.w	#3,d0
	addq.w	#7,a1
	jsr	blatt(pc)
	move.w	d1,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	addq.l	#1,a1
	jsr	blatt(pc)
	rts
blarre_mode:
	move.w	load_save_flags,d0
	move.w	d0,d5
	lsl.w	#8,d5
	lsl.w	#2,d5
	move.w	load_save_flags+2,d1
	move.w	d1,d3
	lsl.w	#8,d3
	lsl.w	#2,d3
	move.w	load_save_flags+4,d2
	move.w	d2,d4
	lsl.w	#8,d4
	lsl.w	#2,d4
	move.l	screen_start,a0
	add.l	#(160*53)+6,a0
	move.w	d0,(a0)
	move.w	d0,160*1(a0)
	move.w	d0,160*2(a0)
	move.w	d0,160*3(a0)
	move.w	d0,160*4(a0)
	move.w	d0,160*5(a0)
	move.w	d0,8(a0)
	move.w	d0,8+160*1(a0)
	move.w	d0,8+160*2(a0)
	move.w	d0,8+160*3(a0)
	move.w	d0,8+160*4(a0)
	move.w	d0,8+160*5(a0)
	move.w	d5,16(a0)
	move.w	d5,16+160*1(a0)
	move.w	d5,16+160*2(a0)
	move.w	d5,16+160*3(a0)
	move.w	d5,16+160*4(a0)
	move.w	d5,16+160*5(a0)

	move.w	d1,160*7(a0)
	move.w	d1,160*8(a0)
	move.w	d1,160*9(a0)
	move.w	d1,160*10(a0)
	move.w	d1,160*11(a0)
	move.w	d1,160*12(a0)
	move.w	d1,8+160*7(a0)
	move.w	d1,8+160*8(a0)
	move.w	d1,8+160*9(a0)
	move.w	d1,8+160*10(a0)
	move.w	d1,8+160*11(a0)
	move.w	d1,8+160*12(a0)
	move.w	d3,16+160*7(a0)
	move.w	d3,16+160*8(a0)
	move.w	d3,16+160*9(a0)
	move.w	d3,16+160*10(a0)
	move.w	d3,16+160*11(a0)
	move.w	d3,16+160*12(a0)

	move.w	d2,160*14(a0)
	move.w	d2,160*15(a0)
	move.w	d2,160*16(a0)
	move.w	d2,160*17(a0)
	move.w	d2,160*18(a0)
	move.w	d2,160*19(a0)
	move.w	d2,8+160*14(a0)
	move.w	d2,8+160*15(a0)
	move.w	d2,8+160*16(a0)
	move.w	d2,8+160*17(a0)
	move.w	d2,8+160*18(a0)
	move.w	d2,8+160*19(a0)
	move.w	d4,16+160*14(a0)
	move.w	d4,16+160*15(a0)
	move.w	d4,16+160*16(a0)
	move.w	d4,16+160*17(a0)
	move.w	d4,16+160*18(a0)
	move.w	d4,16+160*19(a0)
	rts
ms_load_song:
	move.w	#-1,load_save_flags
	move.w	#0,load_save_flags+2
	move.w	#0,load_save_flags+4
	jsr	blarre_mode
	rts
ms_load_sam:
	move.w	#0,load_save_flags
	move.w	#-1,load_save_flags+2
	move.w	#0,load_save_flags+4
	jsr	blarre_mode
	rts
ms_load_module:
	move.w	#0,load_save_flags
	move.w	#0,load_save_flags+2
	move.w	#-1,load_save_flags+4
	jsr	blarre_mode
	rts
load_save_flags:
	dc.w	0
	dc.w	0
	dc.w	-1
ms_tryck_load:
	move.w	#0,save_lam
	jsr	megalam2
	cmp.w	#-1,load_save_flags
	beq	ms_load
	cmp.w	#-1,load_save_flags+2
	beq	ms_load2
	cmp.w	#-1,load_save_flags+4
	beq	ms_load3
	rts
save_lam:
	dc.w	0
ms_tryck_save:
	move.w	#1,save_lam
	jsr	megalam
	cmp.w	#-1,load_save_flags
	beq	ms_save
	cmp.w	#-1,load_save_flags+2
	beq	ms_save2
	cmp.w	#-1,load_save_flags+4
	beq	ms_save3
	rts
megalam:
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	#(160*74)+6,a0
	jsr	ut_med_play_box2

	move.w	#%0000001111111111,d1
	moveq	#-1,d2
	move.w	#%1111111110000000,d3
	move.l	#(160*74)+22,a0
	moveq	#10,d0
	add.l	screen_start,a0
xfix_playare:
	move.w	d1,(a0)
	move.w	d2,8(a0)
	or.w	d3,16(a0)
	lea	160(a0),a0
	dbra	d0,xfix_playare
	rts
megalam2:
	moveq	#0,d1
	moveq	#0,d2
	jsr	gedering
	move.l	#(160*74)+6,a0
	jsr	ut_med_play_box
	rts
gedering:
	move.w	#%0000001111111111,d1
	move.w	#%1111111110000000,d3
	not.w	d1
	not.w	d3
	move.l	#(160*74)+22,a0
	moveq	#10,d0
	add.l	screen_start,a0
xfix_playarex:
	and.w	d1,(a0)
	clr.w	8(a0)
	and.w	d3,16(a0)
	lea	160(a0),a0
	dbra	d0,xfix_playarex
	rts

ms_play:
	move.b	#$3d,minipek
	move.w	#1,play_flag
	clr.b	polle
	move.w	#1,loopch1
	move.w	#1,loopch2
	move.w	#1,loopch3
	move.w	#1,loopch4
	lea	emptysamp,a3
	move.l	#emptysamp,endchan1
	lea	emptysamp,a4
	move.l	#emptysamp,endchan2
	lea	emptysamp,a5
	move.l	#emptysamp,endchan3
	lea	emptysamp,a6
	move.l	#emptysamp,endchan4
	jsr	play_line(pc)
	jsr	fix_play_status
	rts

ms_rec:
	eor.w	#1,tap_onoff
	jsr	rec_hurru
	rts
ms_stop:
	eor.w	#1,play_flag
	move.w	#1,loopch1
	move.w	#1,loopch2
	move.w	#1,loopch3
	move.w	#1,loopch4
	lea	emptysamp,a3
	move.l	#emptysamp,endchan1
	lea	emptysamp,a4
	move.l	#emptysamp,endchan2
	lea	emptysamp,a5
	move.l	#emptysamp,endchan3
	lea	emptysamp,a6
	move.l	#emptysamp,endchan4
	jsr	fix_play_status
	rts
fix_play_status:
	cmp.w	#1,play_flag
	beq	play_on
	move.l	#(160*37)+6,a0
	jsr	ut_med_play_box
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	#(160*13)+6,a0
	jsr	ut_med_play_box2
	rts
play_on:
	move.l	#(160*13)+6,a0
	jsr	ut_med_play_box
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	#(160*37)+6,a0
	jsr	ut_med_play_box2
	rts
rec_hurru:
	cmp.w	#1,tap_onoff
	beq	rec_on
	move.l	#(160*25)+6,a0
	jsr	ut_med_play_box
	rts
rec_on:
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.l	#(160*25)+6,a0
	jsr	ut_med_play_box2
	rts
ut_med_play_box:
	move.w	#%0011111111111111,d1
	moveq	#-1,d2
	move.w	#%1111100000000000,d3
	moveq	#10,d0
	add.l	screen_start,a0
fix_playare:
	move.w	d1,(a0)
	move.w	d2,8(a0)
	or.w	d3,16(a0)
	lea	160(a0),a0
	dbra	d0,fix_playare
	rts
ut_med_play_box2:
	move.w	#%1111100000000000,d3
	not.w	d3
	moveq	#10,d0
	add.l	screen_start,a0
xxfix_playare:
	move.w	d1,(a0)
	move.w	d2,8(a0)
	and.w	d3,16(a0)
	lea	160(a0),a0
	dbra	d0,xxfix_playare
	rts
ms_load:
	lea	currext,a0
	move.b	#".",(a0)+
	move.b	#"S",(a0)+
	move.b	#"N",(a0)+
	move.b	#"G",(a0)
	clr.w	file_type
	jsr	get_name
	rts
file_allert:
	dc.w	0
ut_med_sele:
	move.w	#1,file_allert
	move.l	screen_start,d3
	add.l	#(8*5)+(160*15),d3
	lea	fileselect,a1
	move.l	#96,d0
big_file:
	move.l	d3,a0
	moveq	#8,d1
little_file:
	move.l	(a1)+,(a0)
	clr.w	6(a0)
	addq.l	#8,a0
	dbra	d1,little_file
	add.l	#160,d3
	dbra	d0,big_file

	move.l	screen_start,a0
	add.l	#(8*7)+(160*17),a0
	lea	mess_type,a1
	move.w	file_type,d0
	lsl.w	#2,d0
	move.l	(a1,d0.w),a1
	moveq	#6,d0
mess_loop:
	move.l	(a1)+,8*0(a0)
	move.l	(a1)+,8*1(a0)
	move.l	(a1)+,8*2(a0)
	move.l	(a1)+,8*3(a0)
	move.l	(a1)+,8*4(a0)
	move.l	(a1)+,8*5(a0)
	move.b	#-1,(8*5)+3(a0)
	lea	160(a0),a0
	dbra	d0,mess_loop

	jsr	print_file_c
	move.l	screen_start,a0
	add.l	#(8*6)+(160*28),a0
	move.w	#%0000000011000000,160*0(a0)
	move.w	#%0011100001100000,160*1(a0)
	move.w	#%0011100000110000,160*2(a0)
	move.w	#%0000000000011000,160*3(a0)
	move.w	#%0011100000001100,160*4(a0)
	move.w	#%0011100000000110,160*5(a0)
	move.w	#%0000000000000010,160*6(a0)
	rts
print_file_c:
	move.l	screen_start,a0
	add.l	#(8*5)+(160*28)+1,a0
	moveq	#0,d3
	move.b	curr_dir,d3
	lea	comfont,a1
	mulu	#8,d3
	add.w	d3,a1

	move.b	(a1)+,160*0(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	rts
get_name:
;	jsr	ioio
	clr.b	mbutton
	jsr	ret_ints
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	get_all_names
      	clr.w	fileoffs
	jsr	ut_med_sele
	jsr	print_files
	jsr	himladig
	movem.l	(sp)+,d0-d7/a0-a6
	cmp.w	#1,save_lam
	bne	another_lam
	jsr	megalam
another_lam:
;	jsr	restor_back
	jsr	init_ints
	rts
himladig:
	cmp.b	#"A",curr_dir
	beq	do_himladig
	cmp.b	#"B",curr_dir
	beq	do_himladig
	rts		
do_himladig:
	rts
	move.w	#1000,d0
disklamer:
	move.w	#1600,d1
disklamer2:
	dbra	d1,disklamer2
	dbra	d0,disklamer
	rts
true_pointer:
	dc.l	true_dir
curr_dir:
	dc.b	"A:"
mega_urrk:
	dc.b	"\"
true_dir:
	rept	20
	dc.b	"         "
	endr
	even
dir_restore:
	move.l	#true_dir,true_pointer
	clr.b	true_dir
	rts
set_dir:
	pea	mega_urrk
	move.w	#$3b,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.w	d0
	bmi	nono2
	moveq	#0,d0
	move.b	curr_dir,d0
	sub.b	#$41,d0
	move.w	d0,-(sp)
	move.w	#$e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi	nono2
	moveq	#0,d0
	rts	
ms_exit_dir:
	move.l	true_pointer,a0
	cmp.b	#":",-2(a0)
	beq	no_exit_dir
	clr.b	-(a0)
ms_exit_dir_loop:
	clr.b	-(a0)
	cmp.b	#"\",-1(a0)
	bne	ms_exit_dir_loop
	move.l	a0,true_pointer
	jsr	get_name
no_exit_dir:
	rts
get_all_names:
	move.l	#1,medflag
	jsr	set_dir

	move.l	#name_buff,name_pet
	move.l	#size_buff,size_pet
	move.l	#1,medflag
	move.w	#$10,-(sp)
	pea	extnam
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	xno_îken
îken_loop:
	cmp.b	#$10,dta+21
	bne	no_nesta
	jsr	fix_name
no_nesta:
	move.w	#$4f,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bpl	îken_loop
	cmp.w	#$ffcf,d0
	bne	nono2
no_îken:
	move.l	#1,medflag
	clr.w	-(sp)
	pea	extnam
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	xno_îken2
îken_loop2:
	jsr	fix_name2
	move.w	#$4f,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bpl	îken_loop2
	cmp.w	#$ffcf,d0
	bne	nono2
no_îken2:
	move.l	name_pet,a0
	move.l	#-1,(a0)
	moveq	#0,d0
	rts
xno_îken:
	cmp.w	#$ffdf,d0
	beq	no_îken
	bra	nono2
xno_îken2:
	cmp.w	#$ffdf,d0
	beq	no_îken2
	bra	nono2
fix_name:
	move.l	name_pet(pc),a0
	lea	dta+30,a1
	moveq	#7,d0
name_loop2:
	move.b	(a1)+,d1
	cmp.b	#".",d1
	beq.s	remov2
	cmp.b	#" ",d1
	beq.s	remov2
	cmp.b	#0,d1
	beq.s	remov2
	move.b	d1,(a0)+
	dbra	d0,name_loop2
	bra	forb_remov2
remov2:
	move.b	#$20,(a0)+
      	dbra	d0,remov2
forb_remov2:
	move.l	a0,name_pet
	move.l	size_pet(pc),a0
	move.l	#-1,(a0)+
	move.l	a0,size_pet
	rts
fix_name2:
	move.l	name_pet(pc),a0
	lea	dta+30,a1
	moveq	#7,d0
name_loop:
	move.b	(a1)+,d1
	cmp.b	#".",d1
	beq.s	remov
	cmp.b	#" ",d1
	beq.s	remov
	cmp.b	#0,d1
	beq.s	remov
	move.b	d1,(a0)+
	dbra	d0,name_loop
	bra	forb_remov
remov:
	move.b	#$20,(a0)+
      	dbra	d0,remov
forb_remov:
	move.l	a0,name_pet

	move.l	size_pet(pc),a0
	move.l	dta+26,(a0)+
	move.l	a0,size_pet
	rts
size_pet:
	dc.l	0
fileoffs:
	dc.w	0
print_files:
	move.l	#160*39,samypos

	moveq	#8,d5
	lea	name_buff,a0
	moveq	#0,d0
	move.w	fileoffs,d0
	bmi	no_files
	lsl.w	#3,d0
	add.l	d0,a0

	lea	file1_on,a1
	rept	9
	move.w	#-1,(a1)+
	endr

	cmp.l	#-1,(a0)
	beq	no_files2
	move.w	fileoffs,fileoffs2
	move.l	screen_start,d1
	add.l	#160*39,d1
	move.l	#file1_on,fileon_pek
print_samns2:
	move.b	#11,samxpos

	cmp.l	#-1,(a0)
	beq	no_files3

	move.l	fileon_pek(pc),a1
	move.w	#0,(a1)+
	move.l	a1,fileon_pek

	moveq	#7,d0
print_samns:
	moveq	#0,d2
	move.b	samxpos,d2
	move.l	d2,d3
	and.w	#1,d2
	lsr.w	#1,d3
	lsl.w	#3,d3
	add.l	d3,d2
	add.l	d1,d2

	moveq	#0,d3
	move.b	(a0)+,d3
	mulu	#8,d3
	lea	comfont,a1
	add.w	d3,a1

	move.l	a0,-(sp)
	move.l	d2,a0
	move.b	(a1)+,160*0(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	move.l	(sp)+,a0
	addq.b	#1,samxpos
	dbra	d0,print_samns

	movem.l	d0-d5/a0-a1,-(sp)
	lea	size_buff,a0
	moveq	#0,d0
	move.w	fileoffs2,d0
	lsl.w	#2,d0
	add.l	d0,a0
	move.l	(a0),d1
	bmi	dir_out
	add.l	#512,d1
	move.b	#21,samxpos
	jsr	yes_strul
no_more_dir:
	add.l	#160*8,samypos
	add.w	#1,fileoffs2
	movem.l	(sp)+,d0-d5/a0-a1

	add.l	#8*160,d1
	dbra	d5,print_samns2
	cmp.l	#-1,(a0)
	beq	no_files3
no_files:
	move.w	#0,dummdididumm
	rts
no_files2:
	move.w	#0,dummdididumm
	move.w	#-1,fileoffs
	jsr	print_files
	rts
no_files3:
	move.w	#1,dummdididumm
	rts
dir_out:
	lea	dir_font,a0
	move.l	screen_start,a1
	add.l	samypos,a1
	add.l	#11*8,a1
	move.w	#7,d0
dir_out_loop:
	move.b	(a0),1(a1)
	move.b	8(a0),8(a1)
	move.b	16(a0),9(a1)
	addq.l	#1,a0
	lea	160(a1),a1
	dbra	d0,dir_out_loop
	bra	no_more_dir
dir_font:
	dc.b	$76,$33,$33,$33,$33,$33,$76,$00	;d4
	dc.b	$3C,$18,$18,$18,$18,$18,$3C,$00	;i9
	dc.b	$76,$33,$33,$36,$34,$32,$7B,$00	;r18
fileon_pek:
	dc.l	0
dummdididumm:
	dc.w	0
fileoffs2:
	dc.w	0
name_pet:
	dc.l	0
file_type:
	dc.w	0
type_tab:
	dc.l	load_sng
	dc.l	save_sng
	dc.l	load_sam
	dc.l	save_sam
	dc.l	load_mod
	dc.l	save_mod
mess_type:
	dc.l	mess_load_song
	dc.l	mess_save_song
	dc.l	mess_load_sample
	dc.l	mess_save_sample
	dc.l	mess_load_module
	dc.l	mess_save_module
ms_save:
	lea	currext,a0
	move.b	#".",(a0)+
	move.b	#"S",(a0)+
	move.b	#"N",(a0)+
	move.b	#"G",(a0)
	move.w	#1,file_type
	jsr	get_name
	rts
ms_load2:
	lea	currext,a0
	move.b	#".",(a0)+
	move.b	#"S",(a0)+
	move.b	#"P",(a0)+
	move.b	#"L",(a0)
	move.w	#2,file_type
	jsr	get_name
	rts
ms_save2:
	lea	currext,a0
	move.b	#".",(a0)+
	move.b	#"S",(a0)+
	move.b	#"P",(a0)+
	move.b	#"L",(a0)
	move.w	#3,file_type
	jsr	get_name
	rts
ms_load3:
	lea	currext,a0
	move.b	#".",(a0)+
	move.b	#"M",(a0)+
	move.b	#"O",(a0)+
	move.b	#"D",(a0)
	move.w	#4,file_type
	jsr	get_name
	rts
ms_save3:
	lea	currext,a0
	move.b	#".",(a0)+
	move.b	#"M",(a0)+
	move.b	#"O",(a0)+
	move.b	#"D",(a0)
	move.w	#5,file_type
	jsr	get_name
	rts
ms_exit:
	cmp.w	#1,file_allert
	beq	no_exit
	move.w	#1,orse_flag
	move.w	#1,quit_flag
	move.w	#1,select_allert

	move.l	screen_start,a0
	moveq	#-1,d0
	move.b	#%11111100,d2
	moveq	#10,d1
quit_loop:
	move.b	d0,6(a0)
	move.b	d2,7(a0)
	lea	160(a0),a0
	dbra	d1,quit_loop
	jsr	ut_med_sure
no_exit:
	rts
quit_yes:
	move.w	#1,exit_flg
	jsr	ms_clearall
quit_no:
	move.w	#0,quit_flag
	move.w	#0,select_allert
	move.w	#0,orse_flag
	move.w	#0,file_allert
	jsr	copy_pic
	jsr	init_screen
	rts
quit_flag:
	dc.w	0
ms_patt:
	moveq	#0,d0
	move.b	currposs,d0
	lea	patt_tab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*15)+120,a1
	move.b	(a0),d1
	addq.b	#1,d1
	and.b	#%01111111,d1
	move.b	d1,(a0)
	move.b	d1,currpatt
	jsr	print_hex(pc)
	jsr	calc_song
	rts
ms_pos:
	move.b	currposs,d1
	addq.b	#1,d1
	and.b	#%01111111,d1
fuling:
	move.b	d1,currposs
	cmp.w	#1,help_alert
	beq	no_posse
	move.l	screen_start,a1
	add.l	#(160*27)+120,a1
	jsr	print_hex(pc)
no_posse:
	moveq	#0,d0
	move.b	currposs,d0
	lea	patt_tab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*15)+120,a1
	move.b	(a0),d1
	move.b	d1,currpatt
	cmp.w	#1,help_alert
	beq	no_posse2
	jsr	print_hex(pc)
no_posse2:
	rts
ms_res:
	move.l	screen_start,a1
	add.l	#(160*39)+120,a1
	move.b	currres,d1
	addq.b	#1,d1
	and.b	#%01111111,d1
	move.b	d1,currres	
	jsr	print_hex(pc)
	rts
ms_sam:
	addq.b	#1,currsam
fuling2:
	move.l	screen_start,a1
	add.l	#(160*51)+121,a1
	move.b	currsam,d1
	and.b	#$f,d1
	move.b	d1,currsam
	jsr	print_hex2(pc)

	moveq	#0,d0
	move.b	currsam,d0	
	lsl.l	#2,d0
	lea	samtab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*63)+120,a1
	move.b	(a0),d1
	move.b	(a0),currvol
	jsr	print_hex(pc)

	moveq	#0,d0
	move.b	currsam,d0	
	lsl.l	#2,d0
	lea	samtab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*75)+112,a1
	move.w	2(a0),d1
	move.w	2(a0),currloop
	jsr	print_hex3(pc)
	jsr	print_currname
	jsr	drumm_act
	rts
ms_vol:

	move.b	currvol,d1
	addq.b	#1,d1
fuling3:
	move.l	screen_start,a1
	add.l	#(160*63)+120,a1
	and.b	#%01111111,d1
	move.b	d1,currvol
	jsr	print_hex(pc)
	rts
ms_loop:
	addq.w	#1,currloop
fuling4:
	move.l	screen_start,a1
	add.l	#(160*75)+112,a1
	move.w	currloop,d1
	jsr	print_hex3(pc)
	rts
ms_speed:
	addq.b	#1,currspeed
fuling5:
	clr.b	polle
	move.l	screen_start,a1
	add.l	#(160*87)+121,a1
	move.b	currspeed,d1
	and.b	#$f,d1
	move.b	d1,currspeed
	jsr	print_hex2(pc)
	rts
ms_bonus:
	addq.b	#1,currbonus
fuling6:
	move.l	screen_start,a1
	add.l	#(160*99)+121,a1
	move.b	currbonus,d1
	and.b	#$f,d1
	move.b	d1,currbonus
	jsr	print_hex2(pc)
	jsr	ut_med_spec_val
	rts
ms_trans:
	moveq	#0,d1
	add.b	#1,trans_no
	cmp.b	#$d,trans_no
	bne	okfn
	subq.b	#1,trans_no
okfn:
	move.b	trans_no,d1
	tst.b	d1
	bpl.s	.loop
	neg.b	d1
.loop:
	move.l	screen_start,a1
	add.l	#(160*111)+121,a1
	jsr	print_hex2(pc)
	move.l	screen_start,a1
	add.l	#(160*111)+120,a1
	move.b	trans_no,d1
	tst.b	d1
	bpl.s	.loop2
	jmp	minus
.loop2:
	move.b	#%00011000,0(a1)
	move.b	#%00011000,160*1(a1)
	move.b	#%01111110,160*2(a1)
	move.b	#%01111110,160*3(a1)
	move.b	#%00011000,160*4(a1)
	move.b	#%00011000,160*5(a1)
	move.b	#%00000000,160*6(a1)
	move.b	#%00000000,160*7(a1)
	rts
minus:
	move.b	#0,(a1)
	move.b	#0,160*1(a1)
	move.b	#%00111100,160*2(a1)
	move.b	#%00111100,160*3(a1)
	move.b	#0,160*4(a1)
	move.b	#0,160*5(a1)
	move.b	#0,160*6(a1)
	move.b	#0,160*7(a1)
	rts
ms_patt2:
	moveq	#0,d0
	move.b	currposs,d0
	lea	patt_tab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*15)+120,a1
	move.b	(a0),d1
	subq.b	#1,d1
	and.b	#%01111111,d1
	move.b	d1,(a0)
	move.b	d1,currpatt
	jsr	print_hex(pc)
	jsr	calc_song
	rts
ms_proc_loop:
	moveq	#0,d1
	move.b	currsam,d1
	lsl.w	#3,d1
	lea	samp_pet_buff,a0
	move.l	(a0,d1.w),a1
	cmp.l	#1,4(a0,d1.w)
	beq	no_def_lamer
	add.l	4(a0,d1.w),a1
	sub.l	#over_buff,a1
	add.l	#start_buff,a1
	move.l	a1,a0

	moveq	#0,d0
	moveq	#0,d1
	move.b	currsam,d0	
	lsl.l	#2,d0
	lea	samtab,a1
	move.w	currloop,2(a1,d0.w)
	move.w	currloop,d1
	
	cmp.w	#0,d1
	beq	clear_samloop

	move.l	a0,a1
	sub.l	d1,a1
	move.w	#over_buff-1,d0
make_loop:
	move.b	(a1)+,(a0)+
	dbra	d0,make_loop
	rts
clear_samloop:
	move.w	#over_buff-1,d0
make_loop2:
	move.b	#$7f,(a0)+
	dbra	d0,make_loop2
	rts

ms_pos2:
	move.l	screen_start,a1
	add.l	#(160*27)+120,a1
	move.b	currposs,d1
	subq.b	#1,d1
	and.b	#%01111111,d1
	move.b	d1,currposs
	jsr	print_hex(pc)
	moveq	#0,d0
	move.b	currposs,d0
	lea	patt_tab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*15)+120,a1
	move.b	(a0),d1
	move.b	d1,currpatt
	jsr	print_hex(pc)
	rts
ms_res2:
	move.l	screen_start,a1
	add.l	#(160*39)+120,a1
	move.b	currres,d1
	subq.b	#1,d1
	and.b	#%01111111,d1
	move.b	d1,currres	
	jsr	print_hex(pc)
	rts
ms_sam2:
	subq.b	#1,currsam
	move.l	screen_start,a1
	add.l	#(160*51)+121,a1
	move.b	currsam,d1
	and.b	#$f,d1
	move.b	d1,currsam
	jsr	print_hex2(pc)

	moveq	#0,d0
	move.b	currsam,d0	
	lsl.l	#2,d0
	lea	samtab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*63)+120,a1
	move.b	(a0),d1
	move.b	(a0),currvol
	jsr	print_hex(pc)

	moveq	#0,d0
	move.b	currsam,d0	
	lsl.l	#2,d0
	lea	samtab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*75)+112,a1
	move.w	2(a0),d1
	move.w	2(a0),currloop
	jsr	print_hex3(pc)
	jsr	print_currname
	jsr	drumm_act
	rts

curr_panel:
	dc.l	shose_graff
curr_panelx:
	dc.l	shose_graff2
current_pannel:
	dc.w	0
ms_change_mod:
	move.l	curr_panel,d0
	move.l	curr_panelx,curr_panel
	move.l	d0,curr_panelx
	eor.w	#1,current_pannel
	move.l	curr_panel,a0
	move.l	screen_start,a1
	add.l	#(160*38)+(8*4),a1
	move.l	#66,d0
.loop:
	move.l	(a0)+,(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,16(a1)
	lea	160(a1),a1
	dbra	d0,.loop
	jsr	fix_select
	jsr	print_sizze
	jsr	calc_song
	rts
ms_vol2:
	moveq	#0,d0
	move.b	currsam,d0	
	lsl.l	#2,d0
	lea	samtab,a0
	add.l	d0,a0
	move.l	screen_start,a1
	add.l	#(160*63)+120,a1
	move.b	currvol,d1
	subq.b	#1,d1
	and.b	#%01111111,d1
	move.b	d1,currvol
	jsr	print_hex(pc)
	rts
ms_loop2:
	subq.w	#1,currloop
	move.l	screen_start,a1
	add.l	#(160*75)+112,a1
	move.w	currloop,d1
	jsr	print_hex3(pc)
	rts
ms_speed2:
	clr.b	polle
	subq.b	#1,currspeed
	move.l	screen_start,a1
	add.l	#(160*87)+121,a1
	move.b	currspeed,d1
	and.b	#$f,d1
	move.b	d1,currspeed
	jsr	print_hex2(pc)
	rts
ms_bonus2:
	subq.b	#1,currbonus
	move.l	screen_start,a1
	add.l	#(160*99)+121,a1
	move.b	currbonus,d1
	and.b	#$f,d1
	move.b	d1,currbonus
	jsr	print_hex2(pc)
	jsr	ut_med_spec_val
	rts
ms_trans2:
	moveq	#0,d1
	subq.b	#1,trans_no
	cmp.b	#$f3,trans_no
	bne	okfn2
	addq.b	#1,trans_no
okfn2:
	jmp	okfn
trans_no:
	dc.w	$0000
ms_int:
	clr.w	ors_flag
	jsr	int_ext
	rts
ms_ext:
	move.w	#1,ors_flag
	jsr	int_ext
	rts
int_ext:
	cmp.w	#1,file_allert
	beq	hubblabubbla
	cmp.w	#0,ors_flag
	beq	int_strul
	moveq	#0,d1
	moveq	#0,d2
	move.l	#(160*76)+22+(8*9),a0
	jsr	int_ext3
	move.l	#(160*88)+22+(8*9),a0
	jsr	int_ext2
hubblabubbla:
	rts
int_strul:
	moveq	#0,d1
	moveq	#0,d2
	move.l	#(160*88)+22+(8*9),a0
	jsr	int_ext3
	move.l	#(160*76)+22+(8*9),a0
	jsr	int_ext2
	rts
int_ext2:
	move.w	#%0000111111111111,d1
	move.w	#%1111111111111110,d2
int_ext3:
	moveq	#10,d0
	add.l	screen_start,a0
fix_int:
	move.w	d1,(a0)
	move.w	d2,8(a0)
	lea	160(a0),a0
	dbra	d0,fix_int
	rts

ms_ch1:
	eor.w	#1,chan1_active
thru_ms_ch1:
	cmp.w	#1,chan1_active
	beq	ch1_off
	move.l	screen_start,a0
	add.l	#(8*3)+(160*13)+6,a0
	move.w	#%1111111111100000,d0
	moveq	#10,d1
ms_ch1_loop:
	or.w	d0,(a0)
	lea	160(a0),a0
	dbra	d1,ms_ch1_loop
	rts
ch1_off:
	move.l	screen_start,a0
	add.l	#(8*3)+(160*13)+6,a0
	move.w	#%0000000000011111,d0
	moveq	#10,d1
xms_ch1_loop:
	and.w	d0,(a0)
	lea	160(a0),a0
	dbra	d1,xms_ch1_loop
	move.w	#1,loopch1
	lea	emptysamp,a3
	move.l	#emptysamp,endchan1
	rts
ms_ch2:
	eor.w	#1,chan2_active
thru_ms_ch2:
	cmp.w	#1,chan2_active
	beq	ch2_off
	move.l	screen_start,a0
	add.l	#(8*3)+(160*13)+6,a0
	move.w	#%0000000000001111,d0
	move.w	#%1111111000000000,d2
	moveq	#10,d1
ms_ch2_loop:
	or.w	d0,(a0)
	or.w	d2,8(a0)
	lea	160(a0),a0
	dbra	d1,ms_ch2_loop
	rts
ch2_off:
	move.l	screen_start,a0
	add.l	#(8*3)+(160*13)+6,a0
	move.w	#%1111111111110000,d0
	move.w	#%0000000111111111,d2
	moveq	#10,d1
xms_ch2_loop:
	and.w	d0,(a0)
	and.w	d2,8(a0)
	lea	160(a0),a0
	dbra	d1,xms_ch2_loop

	move.w	#1,loopch2
	lea	emptysamp,a4
	move.l	#emptysamp,endchan2
	rts
ms_ch3:
	cmp.w	#1,file_allert
	beq	no_ch1234
	eor.w	#1,chan3_active
thru_ms_ch3:
	cmp.w	#1,chan3_active
	beq	ch3_off
	move.l	screen_start,a0
	add.l	#(8*3)+(160*13)+14,a0
	move.w	#%0000000011111111,d0
	move.w	#%1110000000000000,d2
	moveq	#10,d1
ms_ch3_loop:
	or.w	d0,(a0)
	or.w	d2,8(a0)
	lea	160(a0),a0
	dbra	d1,ms_ch3_loop
	rts
ch3_off:
	move.l	screen_start,a0
	add.l	#(8*3)+(160*13)+14,a0
	move.w	#%0000000011111111,d0
	move.w	#%1110000000000000,d2
	not.w	d0
	not.w	d2
	moveq	#10,d1
xms_ch3_loop:
	and.w	d0,(a0)
	and.w	d2,8(a0)
	lea	160(a0),a0
	dbra	d1,xms_ch3_loop
	move.w	#1,loopch3
	lea	emptysamp,a5
	move.l	#emptysamp,endchan3
no_ch1234:
	rts
ms_ch4:
	cmp.w	#1,file_allert
	beq	no_ch1234
	eor.w	#1,chan4_active
thru_ms_ch4:
	cmp.w	#1,chan4_active
	beq	ch4_off
	move.l	screen_start,a0
	add.l	#(8*3)+(160*13)+22,a0
	move.w	#%0000111111111110,d0
	moveq	#10,d1
ms_ch4_loop:
	or.w	d0,(a0)
	lea	160(a0),a0
	dbra	d1,ms_ch4_loop
	rts
ch4_off:
	move.l	screen_start,a0
	add.l	#(8*3)+(160*13)+22,a0
	move.w	#%1111000000000001,d0
	moveq	#10,d1
xms_ch4_loop:
	and.w	d0,(a0)
	lea	160(a0),a0
	dbra	d1,xms_ch4_loop

	move.w	#1,loopch4
	lea	emptysamp,a6
	move.l	#emptysamp,endchan4
	rts
ms_clearsam:
	lea	big_patt_buff,a0
	move.w	#16384-1,d0
clear_patt:
	clr.l	(a0)+
	dbra	d0,clear_patt
	lea	patt_tab,a0
	move.w	#128-1,d0
clear_patt_pek:
	clr.b	(a0)+
	dbra	d0,clear_patt_pek
	clr.b	currres
	clr.b	currpatt
	clr.b	currposs
	lea	songname,a1
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	jsr	init_screen
	rts
ms_clearsng:
	clr.b	mbutton
	jsr	ret_ints
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	do_clrspl
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	init_ints
	rts
do_clrspl:
	jsr	flyttdown

	move.l	#1,d0
	moveq	#0,d1
	move.b	currsam,d1
	jsr	fixx_buff(pc)
	move.l	load_addr(pc),a0
	add.l	#1,a0
	move.w	#over_buff-1,d0
clear_loop2:
	move.b	#$7f,(a0)+
	dbra	d0,clear_loop2

	clr.w	currloop
	jsr	ms_proc_loop
	jsr	fix_the_loop
	jsr	flyttupp
	jsr	setvolume

	moveq	#0,d1
	move.b	currsam,d1
	lsl.w	#3,d1
	lea	samnames,a0
	add.l	d1,a0
	move.l	#$20202020,(a0)+
	move.l	#$20202020,(a0)

	moveq	#0,d1
	move.b	currsam,d1
	lsl.w	#2,d1
	lea	samtab,a1
	add.l	d1,a1
	move.l	#$7f000000,(a1)
	move.b	#$7f,currvol

	jsr	init_screen
	rts
ms_clearall:
	clr.l	curr_nopatt
	move.w	#$0500,currspeed
	lea	patt_tab,a0
	move.w	#127,d0
new_patts:
	clr.b	(a0)+
	dbra	d0,new_patts
	clr.w	currres
	lea	samnames,a0
	moveq	#15,d0
new_names:
	move.l	#$20202020,(a0)+
	move.l	#$20202020,(a0)+
	dbra	d0,new_names
	lea	big_patt_buff,a0
	move.w	#16383,d0
new_big_buff:
	clr.l	(a0)+
	dbra	d0,new_big_buff

	move.l	#end_buff-start_buff,end_b_pek
	lea	samtab,a0
	moveq	#15,d0
new_samtab:
	move.w	#$7f00,(a0)+
	clr.w	(a0)+
	dbra	d0,new_samtab
	lea	samp_pet_buff,a0
	lea	save_samp_pet_buff,a1
	moveq	#15,d0
new_sampet:
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,new_sampet
	lea	songname,a1
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	rts
	
save_samp_pet_buff:
	dc.l	samp_buff-start_buff	;1
	dc.l	1
	dc.l	samp_buff2-start_buff	;2
	dc.l	1
	dc.l	samp_buff3-start_buff	;3
	dc.l	1
	dc.l	samp_buff4-start_buff	;4
	dc.l	1
	dc.l	samp_buff5-start_buff	;5
	dc.l	1
	dc.l	samp_buff6-start_buff	;6
	dc.l	1
	dc.l	samp_buff7-start_buff	;7
	dc.l	1
	dc.l	samp_buff8-start_buff	;8
	dc.l	1
	dc.l	samp_buff9-start_buff	;9
	dc.l	1
	dc.l	samp_buff10-start_buff	;10
	dc.l	1
	dc.l	samp_buff11-start_buff	;11
	dc.l	1
	dc.l	samp_buff12-start_buff	;12
	dc.l	1
	dc.l	samp_buff13-start_buff	;13
	dc.l	1
	dc.l	samp_buff14-start_buff	;14
	dc.l	1
	dc.l	samp_buff15-start_buff	;15
	dc.l	1
	dc.l	samp_buff16-start_buff	;16
	dc.l	1
	dc.l	samp_buff17-start_buff	;16
	dc.l	1
	dc.l	-1
	dc.l	0
chan1_active:
	dc.w	0
chan2_active:
	dc.w	0
chan3_active:
	dc.w	0
chan4_active:
	dc.w	0
ms_proc_trans:
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	cutt_chann2,a1
	moveq	#63,d0
put_chann_loopzz:
	move.w	(a0),(a1)+
	addq.l	#8,a0
	dbra	d0,put_chann_loopzz

	lea	cutt_chann2,a0

	moveq	#63,d0
trans_loop:
	moveq	#0,d1
	move.b	(a0),d1
	cmp.b	#0,d1
	beq	no_trans
	lea	conv_tone(pc),a1
	move.b	(a1,d1.w),d1
	add.b	#12,d1
	add.b	trans_no,d1
	lea	trans_tab(pc),a1
	move.b	(a1,d1.w),(a0)
no_trans:
	addq.l	#2,a0
	dbra	d0,trans_loop

	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	cutt_chann2,a1
	moveq	#63,d0
put_chann_loopz:
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	dbra	d0,put_chann_loopz
	rts
trans_tab:
	dc.b	$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10,$10
	dc.b	$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b
	dc.b	$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2a,$2b
	dc.b	$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3a,$3b
	dc.b	$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b
conv_tone:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,0,0,0,0
	dc.b	12,13,14,15,16,17,18,19,20,21,22,23,0,0,0,0
	dc.b	24,25,26,27,28,29,30,31,32,33,34,35,0,0,0,0
drumm_stuff:
	dc.w	12,12,12,12,12,12,12,12
	dc.w	12,12,12,12,12,12,12,12
trans_tab2:
	dc.w	$1000,$1100,$1200,$1300,$1400,$1500,$1600,$1700,$1800,$1900,$1a00,$1b00
	dc.w	$2000,$2100,$2200,$2300,$2400,$2500,$2600,$2700,$2800,$2900,$2a00,$2b00
	dc.w	$3000,$3100,$3200,$3300,$3400,$3500,$3600,$3700,$3800,$3900,$3a00,$3b00
ms_drumm_down:
	moveq	#0,d0
	moveq	#0,d1
	lea	drumm_stuff,a0
	move.b	currsam,d0
	add.w	d0,d0
	cmp.w	#0,(a0,d0.w)
	beq	no_sub
	subq.w	#1,(a0,d0.w)
no_sub:
	jsr	drumm_act
	rts
ms_drumm_upp:
	moveq	#0,d0
	moveq	#0,d1
	lea	drumm_stuff,a0
	move.b	currsam,d0
	add.w	d0,d0
	cmp.w	#35,(a0,d0.w)
	beq	no_add
	addq.w	#1,(a0,d0.w)
no_add:
	jsr	drumm_act
	rts
drumm_act:
	cmp.w	#1,file_allert
	beq	no_act
	moveq	#0,d0
	moveq	#0,d1
	lea	drumm_stuff,a0
	move.b	currsam,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	add.w	d1,d1
	lea	trans_tab2,a0
	move.w	(a0,d1.w),d1
	move.w	d1,d2
	lea	tone_tab,a0
	and.w	#$0f00,d1
	lsr.w	#4,d1
	add.l	d1,a0
	jsr	print_drum_note
	move.l	screen_start,a1
	add.l	#(160*104)+(8*10)+1,a1
	and.w	#$f000,d2
	lsr.w	#8,d2
	lsr.w	#4,d2
	move.w	d2,d1
	jsr	print_hex2	
no_act:
	rts
ms_drumm_clr:
	lea	drumm_stuff,a0
	moveq	#15,d0
drumm_clr:
	move.w	#12,(a0)+
	dbra	d0,drumm_clr
	jsr	drumm_act
	rts
	
print_drum_note:
	move.l	screen_start,a1
	add.l	#(160*104)+(8*9),a1
	move.b	(a0)+,1(a1)
	move.b	(a0)+,8(a1)
	move.b	(a0)+,161(a1)
	move.b	(a0)+,168(a1)
	move.b	(a0)+,160*2+1(a1)
	move.b	(a0)+,160*2+8(a1)
	move.b	(a0)+,160*3+1(a1)
	move.b	(a0)+,160*3+8(a1)
	move.b	(a0)+,160*4+1(a1)
	move.b	(a0)+,160*4+8(a1)
	move.b	(a0)+,160*5+1(a1)
	move.b	(a0)+,160*5+8(a1)
	move.b	(a0)+,160*6+1(a1)
	move.b	(a0)+,160*6+8(a1)
	move.b	(a0)+,160*7+1(a1)
	move.b	(a0)+,160*7+8(a1)
	rts
ms_proc_vol:
	jsr	setcurrvol
	rts
ms_hidden:
	lea	hidden_an_cool,a0
	move.l	screen_start,a1
	add.l	#(8*3)+(33*160),a1
	moveq	#12,d0
copy_hidden:
	move.l	(a0)+,(a1)
	move.l	(a0)+,8(a1)
	move.l	(a0)+,16(a1)
	lea	160(a1),a1
	dbra	d0,copy_hidden
	move.w	#1,hidden_flg
	rts
hidden_flg:
	dc.w	0
nor4:
	move.w	#1,orse_flag
	move.w	#1,newsong_flag
	move.w	#1,select_allert
	jsr	ut_med_sure
	move.w	#1,ruta2b
	jsr	fix_select
	rts
newsong_yes:
	jsr	ms_clearsam
newsong_no:
	move.w	#0,newsong_flag
	move.w	#0,select_allert
	move.w	#0,orse_flag
	move.w	#0,file_allert
	jsr	copy_pic
	move.w	#0,ruta2b
	jsr	init_screen
	rts
newsong_flag:
	dc.w	0
ms_help:
	cmp.w	#1,current_pannel
	beq	nor4
key_help:
	move.w	#1,help_alert	
	move.w	#0,fjant

	move.l	screen_start,a0
	move.l	#7999,d0
clear_screen:
	clr.l	(a0)+
	dbra	d0,clear_screen
	
	move.l	#help_text,more+2
	jsr	more
	add.l	#24*40,more+2
	move.w	#0,spÑpp_flag
	move.w	$ffff8248.w,save_8240
	move.w	#$777,$ffff8248.w
dummy_shit:
	cmp.w	#1,wfnc
	bne	dummy_shit
	clr.w	wfnc
	
;	jsr	play_musaxx
;	jsr	proc_drift
	cmp.b	#$b9,save_key
	beq	slÑpp
	cmp.b	#$39,save_key
	beq	next_help
	cmp.b	#$1,save_key
	beq	no_more_help
	bra	dummy_shit
no_more_help:
	clr.b	save_key
	clr.w	help_alert
	clr.w	file_allert
	clr.w	edit_allert
	clr.w	select_allert
	move.w	save_8240,$ffff8248.w
	jsr	copy_pic
	jsr	init_screen
	rts
save_8240:
	dc.w	0
next_help:
	cmp.w	#1,spÑpp_flag
	beq	no_blÑpp
	add.w	#1,fjant
	cmp.w	#5,fjant
	beq	no_more_help
	jsr	more
	add.l	#24*40,more+2
no_blÑpp:
	bra	dummy_shit
slÑpp:
	move.w	#0,spÑpp_flag
	bra	dummy_shit
fjant:
	dc.w	0
more:
	lea	help_text,a0
	moveq	#23,d5
	move.l	#164,samypos
	move.b	#0,samxpos
print_help2:
	move.l	screen_start,d1
	add.l	samypos,d1
	moveq	#39,d0
print_help:
	moveq	#0,d2
	move.b	samxpos,d2
	move.l	d2,d3
	and.w	#1,d2
	lsr.w	#1,d3
	lsl.w	#3,d3
	add.l	d3,d2
	add.l	d1,d2

	moveq	#0,d3
	move.b	(a0)+,d3
	mulu	#8,d3
	lea	comfont,a1
	add.w	d3,a1

	move.l	a0,-(sp)
	move.l	d2,a0
	move.b	(a1)+,160*0(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	move.b	(a1)+,160*7(a0)
	move.l	(sp)+,a0
	addq.b	#1,samxpos
	dbra	d0,print_help
	add.l	#160*8,samypos
	move.b	#0,samxpos
	dbra	d5,print_help2
	move.w	#1,spÑpp_flag
	rts
spÑpp_flag:
	dc.w	0
;sinus:
;   dc.w    0,0,0,0,4,4,4,8,8,12,12,16,20,24,28
;   dc.w    32,36,40,44,48,52,60,0,4,12,20,24,32,36,44
;   dc.w    52,60,0,8,16,24,32,40,48,56,0,8,20,28,36
;   dc.w    44,52,60,8,16,24,32,40,52,60,4,12,20,28,40
;   dc.w    48,56,0,8,16,24,32,40,48,52,60,4,12,16,24
;   dc.w    28,36,44,48,52,60,0,4,8,12,16,20,24,28,32
;   dc.w    36,36,40,40,44,44,44,48,48,48,48,48,48,48,44
;   dc.w    44,44,40,40,36,36,32,28,24,20,16,12,8,4,0
;   dc.w    60,52,48,44,36,28,24,16,12,4,60,52,48,40,32
;   dc.w    24,16,8,0,56,48,40,28,20,12,4,60,52,40,32
;   dc.w    24,16,8,60,52,44,36,28,20,8,0,56,48,40,32
;   dc.w    24,16,8,0,60,52,44,36,32,24,20,12,4,0,60
;   dc.w    52,48,44,40,36,32,28,24,20,16,12,12,8,8,4
;   dc.w    4,4,0,0,0,0,-1
;sinus2:
;   dc.w    0,0,0,0,0,0,0,128,128,128,128,256,256,256,384
;   dc.w    384,384,512,512,640,640,768,768,896,1024,1024,1152,1152,1280,1408
;   dc.w    1536,1536,1664,1792,1920,0,128,128,256,384,512,640,768,896,1024
;   dc.w    1152,1280,1408,1536,1664,1792,0,128,256,384,512,640,896,1024,1152
;   dc.w    1280,1408,1664,1792,1920,0,256,384,512,640,896,1024,1152,1280,1536
;   dc.w    1664,1792,0,128,256,384,640,768,896,1024,1280,1408,1536,1664,1920
;   dc.w    0,128,256,384,640,768,896,1024,1152,1280,1408,1664,1792,1920,0
;   dc.w    128,256,384,512,640,768,896,1024,1152,1152,1280,1408,1536,1664,1792
;   dc.w    1792,1920,0,128,128,256,256,384,512,512,640,640,768,768,896
;   dc.w    896,896,1024,1024,1024,1152,1152,1152,1152,1280,1280,1280,1280,1280,1280
;   dc.w    1280,1280,1280,1280,1280,1280,1280,1152,1152,1152,1152,1024,1024,1024,896
;   dc.w    896,896,768,768,640,640,512,512,384,256,256,128,128,0,1920
;   dc.w    1792,1792,1664,1536,1408,1280,1152,1152,1024,896,768,640,512,384,256
;   dc.w    128,0,1920,1792,1664,1536,1280,1152,1024,896,768,640,384,256,128
;   dc.w    0,1920,1664,1536,1408,1280,1024,896,768,640,384,256,128,0,1792
;   dc.w    1664,1536,1280,1152,1024,896,640,512,384,256,0,1920,1792,1664,1408
;   dc.w    1280,1152,1024,896,640,512,384,256,128,0,1792,1664,1536,1408,1280
;   dc.w    1152,1024,896,768,640,512,384,256,128,128,0,1920,1792,1664,1536
;   dc.w    1536,1408,1280,1152,1152,1024,1024,896,768,768,640,640,512,512,384
;   dc.w    384,384,256,256,256,128,128,128,128,0,0,0,0,0,0,-1
;sinpek:
;	dc.l	sinus
;sinpek2:
;	dc.l	sinus2
;no_sin:
;	lea	sinus,a0
;	bra	go_sin
;no_sin2:
;	lea	sinus2,a0
;	bra	go_sin2
;proc_drift:
;	moveq	#0,d0
;	moveq	#0,d1
;	move.l	sinpek,a0
;go_sin:
;	move.w	(a0)+,d0
;	bmi	no_sin
;	move.l	a0,sinpek
;
;	move.l	sinpek2,a0
;go_sin2:
;	move.w	(a0)+,d1
;	bmi	no_sin2
;	move.l	a0,sinpek2
;
;	lea	shifted_drift,a0
;	add.l	d0,a0
;	add.l	d1,a0
;	move.l	a0,yes_fpne+2
;	move.l	screen_start,a1
;	move.w	#11,dÜre
;yes_fpne:
;	lea	0,a0
;	move.l	(a0)+,d0
;	move.l	(a0)+,d1
;	move.l	(a0)+,d2
;	move.l	(a0)+,d3
;	move.l	(a0)+,d4
;	move.l	(a0)+,d5
;num	set	0
;	rept	20
;	move.l	d0,(160*0)+num(a1)
;	move.l	d1,(160*1)+num(a1)
;	move.l	d2,(160*2)+num(a1)
;	move.l	d3,(160*3)+num(a1)
;	move.l	d4,(160*4)+num(a1)
;	move.l	d5,(160*5)++num(a1)
;num	set	num+8
;	endr
;	move.l	(a0)+,d0
;	move.l	(a0)+,d1
;	move.l	(a0)+,d2
;	move.l	(a0)+,d3
;	move.l	(a0)+,d4
;	move.l	(a0)+,d5
;num	set	0
;	rept	20
;	move.l	d0,(160*6)+num(a1)
;	move.l	d1,(160*7)+num(a1)
;	move.l	d2,(160*8)+num(a1)
;	move.l	d3,(160*9)+num(a1)
;	move.l	d4,(160*10)+num(a1)
;	move.l	d5,(160*11)++num(a1)
;num	set	num+8
;	endr
;	move.l	(a0)+,d0
;	move.l	(a0)+,d1
;	move.l	(a0)+,d2
;	move.l	(a0),d3
;num	set	0
;	rept	20
;	move.l	d0,(160*12)+num(a1)
;	move.l	d1,(160*13)+num(a1)
;	move.l	d2,(160*14)+num(a1)
;	move.l	d3,(160*15)+num(a1)
;num	set	num+8
;	endr
;	lea	16*160(a1),a1
;	subq.w	#1,dÜre
;	bpl	yes_fpne
;	rts
help_alert:
	dc.w	0
nor3:
	jsr	fix_select
	cmp.l	#2,mod_flg
	beq	start_st
	cmp.w	#0,ste_flag
	beq	no_ste_on
	jsr	start_ste2
no_ste_on:
	rts
ms_hidden2:
	cmp.w	#1,current_pannel
	beq	nor3
	cmp.l	#1,mod_flg
	beq	start_st
	cmp.w	#0,ste_flag
	beq	no_ste_on
	jsr	start_ste
	rts
ms_drumm:
	cmp.w	#1,current_pannel
	beq	nor5
	eor.w	#1,drumm_mode
	eor.w	#1,ruta5a
	jsr	fix_select
	rts
dÜre:
	dc.w	0
drumm_mode:
	dc.w	0
ms_midi:
	cmp.w	#1,current_pannel
	beq	nor6
	eor.w	#1,midi_flag
	eor.w	#1,ruta6a
	jsr	fix_select
	rts
midi_flag:
	dc.w	0
ms_tune:
	cmp.w	#1,current_pannel
	beq	nor7
	lea	disk_space,a0
	move.l	screen_start,a1
	add.l	#(160*40)+(8*6),a1
	move.l	#29,d0
space_loop:
	move.l	#5,d1
space_loop2:
	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	dbra	d1,space_loop2
	lea	160-(8*6)(a1),a1
	dbra	d0,space_loop

	clr.b	mbutton
	jsr	ret_ints
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#1,medflag
	move.b	curr_dir,d0
	sub.b	#$41,d0
	move.w	d0,-(sp)
	move.w	#$e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi	nono3
	move.l	#1,medflag
	move.w	#0,-(sp)
	pea	space_buffer
	move.w	#$36,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	nono3
	jsr	himladig
	move.l	pspal,d0
	move.l	freal,d1
	move.l	bps,d2
	mulu	d0,d1
	mulu	d2,d1
	add.l	#512,d1
	move.l	#160*52,samypos
	move.b	#18,samxpos
	jsr	yes_strul
	move.l	pspal,d0
	move.l	freal,d1
	move.l	bps,d2
	mulu	d0,d1
	mulu	d2,d1
	move.l	d1,d3
	move.l	pspal,d0
	move.l	total,d1
	move.l	bps,d2
	mulu	d0,d1
	mulu	d2,d1
	sub.l	d3,d1
	add.l	#512,d1
	move.l	#160*60,samypos
	move.b	#18,samxpos
	jsr	yes_strul
space_water:
	cmp.b	#185,$fffc02
	bne	space_water
	jsr	copy_pic
	jsr	init_screen
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	init_ints
	rts
nono3:
	jsr	nono2
	jsr	himladig
	jsr	copy_pic
	jsr	init_screen
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	init_ints
	rts
space_buffer:
freal:	dc.l	0
total:	dc.l	0
bps:	dc.l	0
pspal:	dc.l	0

nor5:
	clr.b	mbutton
	jsr	ret_ints
	movem.l	d0-d7/a0-a6,-(sp)
	lea	imptab,a1
	cmp.w	#1,ruta5b
	beq	no_tother
	lea	imptab2,a0
	bra	no_todes
no_tother:
	lea	imptab3,a0
no_todes:
	move.w	#511,d0
imptab_loop:
	move.l	(a0)+,(a1)+
	dbra	d0,imptab_loop
	jsr	conv_imp
	eor.w	#1,ruta5b
	jsr	fix_select
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	init_ints
	rts
nor6:
	eor.w	#1,ruta6b
	eor.w	#1,turbo_m
	jsr	fix_select
	rts
turbo_m:
	dc.w	0
nor7:
	eor.w	#1,ruta7b
	eor.w	#1,crypt
	jsr	fix_select
	rts
crypt:
	dc.w	0
ms_bass:
	cmp.w	#1,current_pannel
	beq	nor2

	eor.w	#1,curr_bass
	move.w	curr_bass,ruta3a
	jsr	fix_select
dumm_bass:
	cmp.w	#1,curr_bass
	beq	generera
	move.w	#0,delay1
	move.w	#90,no_dott
	move.b	#24,$fffffa1f.w
	move.b	#24,mfpa1f2
	rts
generera:
	move.w	#500,delay1
	move.w	#80,no_dott
	move.b	#30,$fffffa1f.w
	move.b	#30,mfpa1f2
	rts
nor2:
	move.w	#1,orse_flag
	move.w	#1,newsam_flag
	move.w	#1,select_allert
	jsr	ut_med_sure
	move.w	#1,ruta3b
	jsr	fix_select
	rts
newsam_yes:
	jsr	ms_clearsng
newsam_no:
	move.w	#0,newsam_flag
	move.w	#0,select_allert
	move.w	#0,orse_flag
	move.w	#0,file_allert
	jsr	copy_pic
	move.w	#0,ruta3b
	jsr	init_screen
	rts
newsam_flag:
	dc.w	0
	rts
no_dott:
	dc.w	90
delay1:
	dc.w	0
ms_insert:
	lea	patt_tab,a0
	lea	lame_pat_tab,a1
	move.w	#127,d0
lame_loop:
	move.b	(a0)+,(a1)+
	dbra	d0,lame_loop
	moveq	#0,d0
	move.b	currposs,d0
	lea	patt_tab,a0
	lea	lame_pat_tab,a1
	add.l	d0,a0
	clr.b	(a0)
	add.l	#1,a0
	add.l	d0,a1
	move.l	#127,d1
	sub.l	d0,d1
	sub.l	#1,d1
	cmp.l	#-1,d1
	beq	shitty_l
operheim:
	move.b	(a1)+,(a0)+
	dbra	d1,operheim
shitty_l:
	clr.b	currpatt
	jsr	init_screen
	rts
ms_mousetoggle:
	cmp.w	#1,current_pannel
	beq	nor1
	eor.w	#1,mouse_flg
	eor.w	#1,ruta1a
	jsr	fix_select
	rts
nor1:
	move.w	#1,orse_flag
	move.w	#1,new_flag
	move.w	#1,select_allert
	jsr	ut_med_sure
	move.w	#1,ruta1b
	jsr	fix_select
	rts
new_yes:
	jsr	ms_clearall
new_no:
	move.w	#0,new_flag
	move.w	#0,select_allert
	move.w	#0,orse_flag
	move.w	#0,file_allert
	jsr	copy_pic
	move.w	#0,ruta1b
	jsr	init_screen
	rts
new_flag:
	dc.w	0
mouse_flg:
	dc.w	0
ms_find_ledish:
	lea	patt_tab,a0
	move.w	#$7f,d0
	moveq	#0,d1
an_loop2:
	moveq	#0,d2
	move.b	(a0)+,d2
	cmp.b	d1,d2
	ble	no_new_val2
	move.b	d2,d1
no_new_val2:
	dbra	d0,an_loop2
	cmp.b	#$7f,d1
	beq	patt_full
	addq.b	#1,d1
	moveq	#0,d0
	lea	patt_tab,a0
	move.b	currposs,d0	
	add.l	d0,a0
	move.b	d1,(a0)
	move.b	d1,currpatt
	jsr	init_screen
patt_full:
	rts

ms_deleate:
	lea	patt_tab,a0
	lea	lame_pat_tab,a1
	move.w	#127,d0
lame_loop2:
	move.b	(a0)+,(a1)+
	dbra	d0,lame_loop2

	moveq	#0,d0
	move.b	currposs,d0
	lea	patt_tab,a0
	lea	lame_pat_tab,a1
	add.l	d0,a0
	add.l	d0,a1
	add.l	#1,a1
	move.l	#127,d1
	sub.l	d0,d1
	cmp.l	#-1,d1
	beq	shitty_l2
operheim2:
	move.b	(a1)+,(a0)+
	dbra	d1,operheim2
shitty_l2:
	lea	patt_tab,a0
	moveq	#0,d0
	move.b	currposs,d0
	add.l	d0,a0
	move.b	(a0),currpatt
	jsr	init_screen
	rts
lame_pat_tab:
	ds.b	128
	dc.b	0
	even
start_st:
	move.w	#0,ruta4a
	move.w	#0,ruta4b

	clr.w	$ff8900
	move.l	#samp1,$134
	move.l	#samp1,currir
	clr.l	mod_flg
	clr.w	vec11+2
	clr.w	vec12+2
	clr.w	vec13+2

	move.l	#vec11,chann1
	move.l	#vec12,chann2
	move.l	#vec13,chann3
	jsr	fix_select
	rts
drive_tab:
	dc.b	"ABCDEFGHIJ"
	DC.B	"KLMNOPQRST"
	DC.B	"UVWXYZAAAA"
	DC.B	"AA"
	EVEN
	dc.b	-2
druledrive_tab:
	ds.b	32
	even
drive_pek:
	dc.l	druledrive_tab
make_drive_tab:
	move.w	#10,-(sp)
	trap	#13
	addq.l	#2,sp
	lea	drive_tab,a0
	lea	druledrive_tab,a1
	moveq	#31,d1
drloop:
	btst	#0,d0
	beq	disk
	move.b	(a0),(a1)+
disk:
	addq.l	#1,a0
	lsr.l	#1,d0
	dbra	d1,drloop
	move.b	#-1,(a1)
	rts
ms_driva:
	moveq	#0,d0
	move.l	drive_pek,a0
	addq.l	#1,a0
	move.b	(a0),d0
	cmp.b	#-1,d0
	beq	no_driva
	move.l	a0,drive_pek
	move.b	d0,curr_dir
no_driva:
	jsr	print_curr_drive
	rts
ms_drivb:
	moveq	#0,d0
	move.l	drive_pek,a0
	subq.l	#1,a0
	move.b	(a0),d0
	cmp.b	#-2,d0
	beq	no_drivb
	move.l	a0,drive_pek
	move.b	d0,curr_dir
no_drivb:
	jsr	print_curr_drive
	rts
print_curr_drive:
	cmp.w	#0,file_allert
	beq	no_fukilame
	jsr	print_file_c
no_fukilame:
	moveq	#0,d0
	move.b	curr_dir,d0
	mulu	#8,d0
	lea	comfont,a1
	add.w	d0,a1
	move.l	screen_start,a0
	add.l	#(160*52)+(8*3)+1,a0
	move.b	(a1)+,160*0(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	rts
operator:
	clr.w	fileoffs
	beq	go_printf
ms_file_upp:

      	sub.w	#1,fileoffs
	cmp.w	#-1,fileoffs
	ble	operator
go_printf:
	jsr	print_files
	rts
ms_file_down:
	cmp.w	#1,dummdididumm
	beq	no_scroll
      	add.w	#1,fileoffs
	jsr	print_files
no_scroll:
	rts
ms_file_1:
	cmp.w	#-1,file1_on
	beq	no_scroll
	clr.w	file_no
	bra	ms_tryck_file
ms_file_2:
	cmp.w	#-1,file2_on
	beq	no_scroll
	move.w	#1,file_no
	bra	ms_tryck_file
ms_file_3:
	cmp.w	#-1,file3_on
	beq	no_scroll
	move.w	#2,file_no
	bra	ms_tryck_file
ms_file_4:
	cmp.w	#-1,file4_on
	beq	no_scroll
	move.w	#3,file_no
	bra	ms_tryck_file
ms_file_5:
	cmp.w	#-1,file5_on
	beq	no_scroll
	move.w	#4,file_no
	bra	ms_tryck_file
ms_file_6:
	cmp.w	#-1,file6_on
	beq	no_scroll
	move.w	#5,file_no
	bra	ms_tryck_file
ms_file_7:
	cmp.w	#-1,file7_on
	beq	no_scroll
	move.w	#6,file_no
	bra	ms_tryck_file
ms_file_8:
	cmp.w	#-1,file8_on
	beq	no_scroll
	move.w	#7,file_no
	bra	ms_tryck_file
ms_file_9:
	cmp.w	#-1,file9_on
	beq	no_scroll
	move.w	#8,file_no
	bra	ms_tryck_file
file1_on:
	dc.w	-1
file2_on:
	dc.w	-1
file3_on:
	dc.w	-1
file4_on:
	dc.w	-1
file5_on:
	dc.w	-1
file6_on:
	dc.w	-1
file7_on:
	dc.w	-1
file8_on:
	dc.w	-1
file9_on:
	dc.w	-1
	dc.w	0
ms_select_yes:
	cmp.w	#1,new_flag
	beq	new_yes
	cmp.w	#1,newsong_flag
	beq	newsong_yes
	cmp.w	#1,newsam_flag
	beq	newsam_yes
	cmp.w	#1,quit_flag
	beq	quit_yes
	jsr	yes_load
	clr.w	select_allert
	clr.w	edit_allert
	clr.w	sample_allert
	move.w	#$0e00,write_pos
	jsr	copy_pic
	jsr	init_screen
	jsr	ut_med_sele
	jsr	print_files
	jsr	helpme_deg
	rts
helpme_deg:
	cmp.w	#1,save_lam
	bne	xanother_lam
	jsr	megalam
	rts
xanother_lam:
	jsr	megalam2
	rts
ms_select_no:
	cmp.w	#1,new_flag
	beq	new_no
	cmp.w	#1,newsong_flag
	beq	newsong_no
	cmp.w	#1,newsam_flag
	beq	newsam_no
	cmp.w	#1,quit_flag
	beq	quit_no
	clr.w	select_allert
	clr.w	edit_allert
	clr.w	sample_allert
	move.w	#$0e00,write_pos
	jsr	copy_pic
	jsr	init_screen
	jsr	ut_med_sele
	jsr	print_files
	jsr	helpme_deg
	rts
file_no:
	dc.w	0
select_allert:
	dc.w	0
ms_tryck_file:
	moveq	#0,d0
	move.w	file_no,d0
	mulu	#160*8,d0
	add.l	screen_start,d0
	add.l	#(8*5)+(160*39),d0
	move.l	d0,a0
	moveq	#6,d0
nega_shitt:
	not.b	1(a0)
	not.w	8(a0)
	not.w	16(a0)
	not.w	24(a0)
	not.w	32(a0)
	not.w	40(a0)
	not.w	48(a0)
	not.w	56(a0)
	lea	160(a0),a0
	dbra	d0,nega_shitt

	lea	size_buff,a0
	moveq	#0,d0
	move.w	fileoffs,d0
	add.w	file_no,d0
	lsl.w	#2,d0
	add.l	d0,a0
	move.l	(a0),d1
	bmi	dirr_just_tryck

	move.w	#1,select_allert
	clr.w	edit_allert

ut_med_sure:
	move.l	screen_start,d3
	add.l	#(8*10)+(160*40),d3
	lea	sure_sign,a1
	move.l	#34,d0
big_file2:
	move.l	d3,a0
	moveq	#6,d1
little_file2:
	move.l	(a1)+,(a0)
	clr.w	6(a0)
	addq.l	#8,a0
	dbra	d1,little_file2
	add.l	#160,d3
	dbra	d0,big_file2
no_nottare:
	rts
dirr_just_tryck:
	lea	name_buff,a0
	moveq	#0,d0
	move.w	fileoffs,d0
	lsl.w	#3,d0
	add.l	d0,a0
	moveq	#0,d0
	move.w	file_no,d0
	lsl.w	#3,d0
	add.l	d0,a0
	cmp.l	#$20202020,(a0)
	beq	no_load
	move.l	true_pointer,a1
	moveq	#7,d0
xfix_real_name:
	move.b	(a0)+,d1
	cmp.b	#$20,d1
	beq	xfast_ext
	move.b	d1,(a1)+
	dbra	d0,xfix_real_name
xfast_ext:
	lea	currext,a0
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	#"\",(a1)+
	clr.b	(a1)
	move.l	a1,true_pointer
	jsr	get_name
	rts
yes_load:
	cmp.w	#1,sample_allert
	beq	yes_save_sample

	lea	name_buff,a0
	moveq	#0,d0
	move.w	fileoffs,d0
	lsl.w	#3,d0
	add.l	d0,a0
	moveq	#0,d0
	move.w	file_no,d0
	lsl.w	#3,d0
	add.l	d0,a0
	cmp.l	#$20202020,(a0)
	beq	no_load
	lea	filename,a1
	moveq	#7,d0
fix_real_name:
	move.b	(a0)+,d1
	cmp.b	#$20,d1
	beq	fast_ext
	move.b	d1,(a1)+
	dbra	d0,fix_real_name
fast_ext:
	lea	currext,a0
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	clr.b	(a1)

	jsr	ioio
	clr.b	mbutton
	jsr	ret_ints
	movem.l	d0-d7/a0-a6,-(sp)
	lea	type_tab,a0
	move.w	file_type,d0
	lsl.w	#2,d0
	move.l	(a0,d0.w),a0
	jsr	(a0)
	jsr	himladig
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	restor_back
	jsr	init_ints
	jsr	dumm_bass
no_load:	
	rts
ms_tryck_sam:
	move.w	#1,select_allert
	move.w	#1,sample_allert
	clr.w	edit_allert
	move.l	screen_start,a0
	add.l	#(8*4)+(160*116),a0
	moveq	#6,d0
nega_shitt2:
	not.b	1(a0)
	not.b	8(a0)
	not.b	9(a0)
	not.b	16(a0)
	not.b	17(a0)
	not.b	24(a0)
	not.b	25(a0)
	not.b	32(a0)
	lea	160(a0),a0
	dbra	d0,nega_shitt2


	move.l	screen_start,d3
	add.l	#(8*10)+(160*40),d3
	lea	sure_sign,a1
	move.l	#34,d0
big_file3:
	move.l	d3,a0
	moveq	#6,d1
little_file3:
	move.l	(a1)+,(a0)
	clr.w	6(a0)
	addq.l	#8,a0
	dbra	d1,little_file3
	add.l	#160,d3
	dbra	d0,big_file3
	rts
yes_save_sample:
	lea	samnames,a0
	moveq	#0,d0
	move.b	currsam,d0
	lsl.w	#3,d0
	add.l	d0,a0
	cmp.l	#$20202020,(a0)
	beq	no_load
	cmp.l	#0,(a0)
	beq	no_load
	lea	filename,a1
	moveq	#7,d0
fix_real_name2:
	move.b	(a0)+,d1
	cmp.b	#$20,d1
	beq	fast_ext2
	cmp.b	#0,d1
	beq	fast_ext2
	cmp.b	#".",d1
	beq	fast_ext2
	move.b	d1,(a1)+
	dbra	d0,fix_real_name2
fast_ext2:
	lea	currext,a0
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	clr.b	(a1)

	clr.b	mbutton
	jsr	ret_ints
	movem.l	d0-d7/a0-a6,-(sp)
	lea	type_tab,a0
	move.w	file_type,d0
	lsl.w	#2,d0
	move.l	(a0,d0.w),a0
	jsr	(a0)
	jsr	get_all_names
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	init_ints
	rts
sample_allert:
	dc.w	0
ms_file_exit:
	clr.w	file_allert
	clr.w	edit_allert
	clr.w	select_allert
	jsr	copy_pic
	jsr	init_screen
	rts
ms_edit_name:
	move.w	#1,edit_allert
	move.l	#$20202020,edit_buff
	move.l	#$20202020,edit_buff+4
	move.w	#$0e00,write_pos
	move.l	screen_start,a0
	add.l	#(160*28)+(8*7),a0
	rept	7
	clr.w	(a0)
	clr.w	8(a0)
	clr.w	16(a0)
	clr.w	24(a0)
	lea	160(a0),a0
	endr
nuffin:
	jsr	edit_cursor
	rts
ms_line:
	eor.w	#1,worm_flg
	jsr	offrahassa
	cmp.w	#0,worm_flg
	beq	wipe
	rts
offrahassa:
	cmp.w	#1,file_allert
	beq	xhubblabubbla
	cmp.w	#1,worm_flg
	beq	fanasso
	move.l	#(160*67)+22+(8*9),a0
	jsr	worm_off
	rts
fanasso:
	move.l	#(160*67)+22+(8*9),a0
	jsr	worm_on
	rts
worm_on:
	move.w	#%0000111111111111,d1
	move.w	#%1111110000000000,d2
	moveq	#7,d0
	add.l	screen_start,a0
line_on:
	or.w	d1,(a0)
	or.w	d2,8(a0)
	lea	160(a0),a0
	dbra	d0,line_on
	rts
worm_off:
	move.w	#%0000111111111111,d1
	move.w	#%1111110000000000,d2
	not.w	d1
	not.w	d2
	moveq	#7,d0
	add.l	screen_start,a0
line_on2:
	and.w	d1,(a0)
	and.w	d2,8(a0)
	lea	160(a0),a0
	dbra	d0,line_on2
	rts

ms_wormext:
	move.w	#1,wormmod_flg
	jsr	worm_int_ext
	rts
ms_wormint:
	move.w	#0,wormmod_flg
	jsr	worm_int_ext
	rts
worm_int_ext:
	cmp.w	#1,file_allert
	beq	xhubblabubbla
	cmp.w	#0,wormmod_flg
	beq	xint_strul
	move.l	#(160*67)+22+(8*10),a0
	jsr	xint_ext3x
	move.l	#(160*67)+22+(8*10),a0
	jsr	xint_ext2
xhubblabubbla:
	rts
xint_strul:
	move.l	#(160*67)+22+(8*10),a0
	jsr	xint_ext3
	move.l	#(160*67)+22+(8*10),a0
	jsr	xint_ext2x
	rts
xint_ext2:
	move.w	#%0000000111111100,d1
	moveq	#7,d0
	add.l	screen_start,a0
wormfix_int:
	or.w	d1,(a0)
	lea	160(a0),a0
	dbra	d0,wormfix_int
	rts
xint_ext3:
	move.w	#%0000000000000001,d1
	move.w	#%1111110000000000,d2
	moveq	#7,d0
	add.l	screen_start,a0
xwormfix_int:
	or.w	d1,(a0)
	or.w	d2,8(a0)
	lea	160(a0),a0
	dbra	d0,xwormfix_int
	rts
xint_ext2x:
	move.w	#%0000000111111100,d1
	not	d1
	moveq	#7,d0
	add.l	screen_start,a0
wormfix_intx:
	and.w	d1,(a0)
	lea	160(a0),a0
	dbra	d0,wormfix_intx
	rts
xint_ext3x:
	move.w	#%0000000000000001,d1
	move.w	#%1111110000000000,d2
	not	d1
	not	d2
	moveq	#7,d0
	add.l	screen_start,a0
xwormfix_intx:
	and.w	d1,(a0)
	and.w	d2,8(a0)
	lea	160(a0),a0
	dbra	d0,xwormfix_intx
	rts

wormmod_flg:
	dc.w	0
edit_allert:
	dc.w	0
edit_buff:
	dc.b	"        "
	dc.b	$20
	even
yes_key_a:
	move.b	#"A",d0
	jsr	edit_write
	rts
yes_key_b:
	move.b	#"B",d0
	jsr	edit_write
	rts
yes_key_c:
	move.b	#"C",d0
	jsr	edit_write
	rts
yes_key_d:
	move.b	#"D",d0
	jsr	edit_write
	rts
yes_key_e:
	move.b	#"E",d0
	jsr	edit_write
	rts
yes_key_f:
	move.b	#"F",d0
	jsr	edit_write
	rts
yes_key_g:
	move.b	#"G",d0
	jsr	edit_write
	rts
yes_key_h:
	move.b	#"H",d0
	jsr	edit_write
	rts
yes_key_i:
	move.b	#"I",d0
	jsr	edit_write
	rts
yes_key_j:
	move.b	#"J",d0
	jsr	edit_write
	rts
yes_key_k:
	move.b	#"K",d0
	jsr	edit_write
	rts
yes_key_l:
	move.b	#"L",d0
	jsr	edit_write
	rts
yes_key_m:
	move.b	#"M",d0
	jsr	edit_write
	rts
yes_key_n:
	move.b	#"N",d0
	jsr	edit_write
	rts
yes_key_o:
	move.b	#"O",d0
	jsr	edit_write
	rts
yes_key_p:
	move.b	#"P",d0
	jsr	edit_write
	rts
yes_key_q:
	move.b	#"Q",d0
	jsr	edit_write
	rts
yes_key_r:
	move.b	#"R",d0
	jsr	edit_write
	rts
yes_key_s:
	move.b	#"S",d0
	jsr	edit_write
	rts
yes_key_t:
	move.b	#"T",d0
	jsr	edit_write
	rts
yes_key_u:
	move.b	#"U",d0
	jsr	edit_write
	rts
yes_key_v:
	move.b	#"V",d0
	jsr	edit_write
	rts
yes_key_w:
	move.b	#"W",d0
	jsr	edit_write
	rts
yes_key_x:
	move.b	#"X",d0
	jsr	edit_write
	rts
yes_key_y:
	move.b	#"Y",d0
	jsr	edit_write
	rts
yes_key_z:
	move.b	#"Z",d0
	jsr	edit_write
	rts
yes_key_Ü:
	move.b	#"è",d0
	jsr	edit_write
	rts
yes_key_Ñ:
	move.b	#"é",d0
	jsr	edit_write
	rts
yes_key_î:
	move.b	#"ô",d0
	jsr	edit_write
	rts
yes_key_Å:
	move.b	#"ö",d0
	jsr	edit_write
	rts
yes_key_return:
	move.b	#"(",d0
	jsr	edit_write
	rts
yes_key_back:
	move.b	#")",d0
	jsr	edit_write
	rts
yes_key_0:
	move.b	#"0",d0
	jsr	edit_write
	rts
yes_key_1:
	move.b	#"1",d0
	jsr	edit_write
	rts
yes_key_2:
	move.b	#"2",d0
	jsr	edit_write
	rts
yes_key_3:
	move.b	#"3",d0
	jsr	edit_write
	rts
yes_key_4:
	move.b	#"4",d0
	jsr	edit_write
	rts
yes_key_5:
	move.b	#"5",d0
	jsr	edit_write
	rts
yes_key_6:
	move.b	#"6",d0
	jsr	edit_write
	rts
yes_key_7:
	move.b	#"7",d0
	jsr	edit_write
	rts
yes_key_8:
	move.b	#"8",d0
	jsr	edit_write
	rts
yes_key_9:
	move.b	#"9",d0
	jsr	edit_write
	rts
yes_underkey:
	cmp.w	#1,shift_allert
	beq	shifted_underkey
	move.b	#"-",d0
	jsr	edit_write
	rts
shifted_underkey:
	move.b	#"_",d0
	jsr	edit_write
	rts
xreturnx:
	lea	edit_buff,a0
	cmp.l	#$20202020,(a0)
	beq	spessare3
	lea	filename,a1
	moveq	#7,d0
downer:
	move.b	(a0)+,d1
	cmp.b	#$20,d1
	beq	downer2
	move.b	d1,(a1)+
	dbra	d0,downer
downer2:
	lea	currext,a0
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	clr.b	(a1)

	clr.b	save_key

	jsr	ret_ints
	movem.l	d0-d7/a0-a6,-(sp)
	lea	type_tab,a0
	move.w	file_type,d0
	lsl.w	#2,d0
	move.l	(a0,d0.w),a0
	jsr	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	init_ints
	jsr	get_name
spessare3:
	clr.w	edit_allert
	rts
back_space:
	move.b	#$20,d0
	cmp.b	#$e+8,write_pos
	beq	spessare
	cmp.b	#$e,write_pos
	beq	spessare2
	subq.b	#1,write_pos
spessare:
	jsr	edit_write
	subq.b	#2,write_pos
	jsr	edit_cursor2
	addq.b	#1,write_pos
spessare2:
	rts
	
edit_write:
	cmp.b	#")",d0
	beq	back_space
	cmp.b	#"(",d0
	beq	xreturnx
	cmp.b	#$e+8,write_pos
	bne	no_end_pos
	sub.b	#1,write_pos
no_end_pos:
	moveq	#0,d2
	move.b	write_pos,d2
	sub.w	#$e,d2
	lea	edit_buff,a1
	move.b	d0,(a1,d2.w)
	move.l	screen_start,d1
	add.l	#160*28,d1
	moveq	#0,d2
	move.b	write_pos,d2
	move.l	d2,d3
	and.w	#1,d2
	lsr.w	#1,d3
	lsl.w	#3,d3
	add.l	d3,d2
	add.l	d1,d2
	moveq	#0,d3
	move.b	d0,d3
	mulu	#8,d3
	lea	comfont,a1
	add.w	d3,a1

	move.l	d2,a0
	move.b	(a1)+,160*0(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	jsr	edit_cursor2
	addq.b	#1,write_pos
	rts
edit_cursor2:
	moveq	#0,d0
	move.b	write_pos,d0
	sub.b	#$e,d0
	bmi	edit_cursor
	lsl.w	#2,d0
	lea	curs_pos,a1
	move.l	(a1,d0.w),a0
	move.b	#-1,160*0(a0)
	move.b	#-1,160*1(a0)
	move.b	#-1,160*2(a0)
	move.b	#-1,160*3(a0)
	move.b	#-1,160*4(a0)
	move.b	#-1,160*5(a0)
	move.b	#-1,160*6(a0)
	move.l	4(a1,d0.w),a0
	clr.b	160*0(a0)
	clr.b	160*1(a0)
	clr.b	160*2(a0)
	clr.b	160*3(a0)
	clr.b	160*4(a0)
	clr.b	160*5(a0)
	clr.b	160*6(a0)
	rts
curs_pos:
	dc.l	(160*28)+(8*7)+1
	dc.l	(160*28)+(8*8)
	dc.l	(160*28)+(8*8)+1
	dc.l	(160*28)+(8*9)
	dc.l	(160*28)+(8*9)+1
	dc.l	(160*28)+(8*10)
	dc.l	(160*28)+(8*10)+1
	dc.l	(160*28)+(8*11)
	dc.l	(160*28)+(8*11)+1

edit_cursor:
	move.l	screen_start,a0
	add.l	#(160*28)+(8*7),a0
	move.b	#-1,160*0(a0)
	move.b	#-1,160*1(a0)
	move.b	#-1,160*2(a0)
	move.b	#-1,160*3(a0)
	move.b	#-1,160*4(a0)
	move.b	#-1,160*5(a0)
	move.b	#-1,160*6(a0)
	move.l	screen_start,a0
	add.l	#(160*28)+(8*7)+1,a0
	clr.b	160*0(a0)
	clr.b	160*1(a0)
	clr.b	160*2(a0)
	clr.b	160*3(a0)
	clr.b	160*4(a0)
	clr.b	160*5(a0)
	clr.b	160*6(a0)
	rts
write_pos:
	dc.w	$0e00
mess_save_song:
	dc.w	$7C38,$83C7,$C37F,$3C80
	dc.w	$003E,$FFC1,$3E63,$C19C
	dc.w	$3E00,$C1FF,$0000,$FF00
	dc.w	$C07C,$3F83,$C360,$3C9F
	dc.w	$0060,$FF9F,$6373,$9C8C
	dc.w	$6000,$9FFF,$0000,$FF00
	dc.w	$7CC6,$8339,$667C,$9983
	dc.w	$003E,$FFC1,$637B,$9C84
	dc.w	$6000,$9FFF,$0000,$FF00
	dc.w	$06FE,$F901,$6660,$999F
	dc.w	$0003,$FFFC,$636F,$9C90
	dc.w	$6E00,$91FF,$0000,$FF00
	dc.w	$06C6,$F939,$3C60,$C39F
	dc.w	$0003,$FFFC,$6367,$9C98
	dc.w	$6300,$9CFF,$0000,$FF00
	dc.w	$06C6,$F939,$3C60,$C39F
	dc.w	$0003,$FFFC,$6363,$9C9C
	dc.w	$6300,$9CFF,$0000,$FF00
	dc.w	$7CC6,$8339,$187F,$E780
	dc.w	$003E,$FFC1,$3E63,$C19C
	dc.w	$3E00,$C1FF,$0000,$FF00
mess_save_sample:
	dc.w	$7C38,$83C7,$C37F,$3C80
	dc.w	$003E,$FFC1,$1C63,$E39C
	dc.w	$7E60,$819F,$7F00,$8000
	dc.w	$C07C,$3F83,$C360,$3C9F
	dc.w	$0060,$FF9F,$3E77,$C188
	dc.w	$6360,$9C9F,$6000,$9F00
	dc.w	$7CC6,$8339,$667C,$9983
	dc.w	$003E,$FFC1,$637F,$9C80
	dc.w	$6360,$9C9F,$7C00,$8300
	dc.w	$06FE,$F901,$6660,$999F
	dc.w	$0003,$FFFC,$7F6B,$8094
	dc.w	$7E60,$819F,$6000,$9F00
	dc.w	$06C6,$F939,$3C60,$C39F
	dc.w	$0003,$FFFC,$6363,$9C9C
	dc.w	$6060,$9F9F,$6000,$9F00
	dc.w	$06C6,$F939,$3C60,$C39F
	dc.w	$0003,$FFFC,$6363,$9C9C
	dc.w	$6060,$9F9F,$6000,$9F00
	dc.w	$7CC6,$8339,$187F,$E780
	dc.w	$003E,$FFC1,$6363,$9C9C
	dc.w	$607F,$9F80,$7F00,$8000


mess_save_module:
	dc.w	$7C38,$83C7,$C37F,$3C80
	dc.w	$0063,$FF9C,$3E7E,$C181
	dc.w	$6360,$9C9F,$7F00,$8000
	dc.w	$C07C,$3F83,$C360,$3C9F
	dc.w	$0077,$FF88,$6363,$9C9C
	dc.w	$6360,$9C9F,$6000,$9F00
	dc.w	$7CC6,$8339,$667C,$9983
	dc.w	$007F,$FF80,$6363,$9C9C
	dc.w	$6360,$9C9F,$7C00,$8300
	dc.w	$06FE,$F901,$6660,$999F
	dc.w	$006B,$FF94,$6363,$9C9C
	dc.w	$6360,$9C9F,$6000,$9F00
	dc.w	$06C6,$F939,$3C60,$C39F
	dc.w	$0063,$FF9C,$6363,$9C9C
	dc.w	$6360,$9C9F,$6000,$9F00
	dc.w	$06C6,$F939,$3C60,$C39F
	dc.w	$0063,$FF9C,$6363,$9C9C
	dc.w	$6360,$9C9F,$6000,$9F00
	dc.w	$7CC6,$8339,$187F,$E780
	dc.w	$0063,$FF9C,$3E7E,$C181
	dc.w	$3E7F,$C180,$7F00,$8000


mess_load_song:
	dc.w	$C07C,$3F83,$38FC,$C703
	dc.w	$003E,$FFC1,$3E63,$C19C
	dc.w	$3E00,$C1FF,$0000,$FF00
	dc.w	$C0C6,$3F39,$7CC6,$8339
	dc.w	$0060,$FF9F,$6373,$9C8C
	dc.w	$6000,$9FFF,$0000,$FF00
	dc.w	$C0C6,$3F39,$C6C6,$3939
	dc.w	$003E,$FFC1,$637B,$9C84
	dc.w	$6000,$9FFF,$0000,$FF00
	dc.w	$C0C6,$3F39,$FEC6,$0139
	dc.w	$0003,$FFFC,$636F,$9C90
	dc.w	$6E00,$91FF,$0000,$FF00
	dc.w	$C0C6,$3F39,$C6C6,$3939
	dc.w	$0003,$FFFC,$6367,$9C98
	dc.w	$6300,$9CFF,$0000,$FF00
	dc.w	$C0C6,$3F39,$C6C6,$3939
	dc.w	$0003,$FFFC,$6363,$9C9C
	dc.w	$6300,$9CFF,$0000,$FF00
	dc.w	$FE7C,$0183,$C6FC,$3903
	dc.w	$003E,$FFC1,$3E63,$C19C
	dc.w	$3E00,$C1FF,$0000,$FF00


mess_load_sample:
	dc.w	$C07C,$3F83,$38FC,$C703
	dc.w	$003E,$FFC1,$1C63,$E39C
	dc.w	$7E60,$819F,$7F00,$8000
	dc.w	$C0C6,$3F39,$7CC6,$8339
	dc.w	$0060,$FF9F,$3E77,$C188
	dc.w	$6360,$9C9F,$6000,$9F00
	dc.w	$C0C6,$3F39,$C6C6,$3939
	dc.w	$003E,$FFC1,$637F,$9C80
	dc.w	$6360,$9C9F,$7C00,$8300
	dc.w	$C0C6,$3F39,$FEC6,$0139
	dc.w	$0003,$FFFC,$7F6B,$8094
	dc.w	$7E60,$819F,$6000,$9F00
	dc.w	$C0C6,$3F39,$C6C6,$3939
	dc.w	$0003,$FFFC,$6363,$9C9C
	dc.w	$6060,$9F9F,$6000,$9F00
	dc.w	$C0C6,$3F39,$C6C6,$3939
	dc.w	$0003,$FFFC,$6363,$9C9C
	dc.w	$6060,$9F9F,$6000,$9F00
	dc.w	$FE7C,$0183,$C6FC,$3903
	dc.w	$003E,$FFC1,$6363,$9C9C
	dc.w	$607F,$9F80,$7F00,$8000


mess_load_module:
	dc.w	$C07C,$3F83,$38FC,$C703
	dc.w	$0063,$FF9C,$3E7E,$C181
	dc.w	$6360,$9C9F,$7F00,$8080
	dc.w	$C0C6,$3F39,$7CC6,$8339
	dc.w	$0077,$FF88,$6363,$9C9C
	dc.w	$6360,$9C9F,$6000,$9F80
	dc.w	$C0C6,$3F39,$C6C6,$3939
	dc.w	$007F,$FF80,$6363,$9C9C
	dc.w	$6360,$9C9F,$7C00,$8380
	dc.w	$C0C6,$3F39,$FEC6,$0139
	dc.w	$006B,$FF94,$6363,$9C9C
	dc.w	$6360,$9C9F,$6000,$9F80
	dc.w	$C0C6,$3F39,$C6C6,$3939
	dc.w	$0063,$FF9C,$6363,$9C9C
	dc.w	$6360,$9C9F,$6000,$9F80
	dc.w	$C0C6,$3F39,$C6C6,$3939
	dc.w	$0063,$FF9C,$6363,$9C9C
	dc.w	$6360,$9C9F,$6000,$9F80
	dc.w	$FE7C,$0183,$C6FC,$3903
	dc.w	$0063,$FF9C,$3E7E,$C181
	dc.w	$3E7F,$C180,$7F00,$8080

chk_keys:
	cmp.w	#1,edit_allert
	bne	els
	lea	edit_key_list(pc),a0
	bra	els2
els:
	lea	key_list(pc),a0
els2:
	move.b	save_key,d0
key_again:
	cmp.b	(a0),d0
	beq.s	found
	addq.l	#6,a0
	cmp.b	#-1,(a0)
	bne.s	key_again
	bra.s	no_key
found:
	cmp.b	last_key,d0
	bne.s	start_repet	
	cmp.w	#1,repet_shit
	bne.s	start_repet	
go_on_with_key:
	subq.w	#1,repet_val
	bmi	yes_key
	rts
yes_key:
	move.w	#1,repet_val
	move.l	2(a0),a0
	jsr	(a0)
	rts
no_key:
	clr.w	repet_shit
	rts
start_repet:
	move.b	d0,last_key
	move.w	#1,repet_shit
	move.w	#20,repet_val
	move.l	2(a0),a0
	jsr	(a0)
	rts
last_key:
	dc.w	0
repet_shit:
	dc.w	0
repet_val:
	dc.w	0
edit_key_list:
	dc.b	$1e,0
	dc.l	yes_key_a
	dc.b	$30,0
	dc.l	yes_key_b
	dc.b	$2e,0
	dc.l	yes_key_c
	dc.b	$20,0
	dc.l	yes_key_d
	dc.b	$12,0
	dc.l	yes_key_e
	dc.b	$21,0
	dc.l	yes_key_f
	dc.b	$22,0
	dc.l	yes_key_g
	dc.b	$23,0
	dc.l	yes_key_h
	dc.b	$17,0
	dc.l	yes_key_i
	dc.b	$24,0
	dc.l	yes_key_j
	dc.b	$25,0
	dc.l	yes_key_k
	dc.b	$26,0
	dc.l	yes_key_l
	dc.b	$32,0
	dc.l	yes_key_m
	dc.b	$31,0
	dc.l	yes_key_n
	dc.b	$18,0
	dc.l	yes_key_o
	dc.b	$19,0
	dc.l	yes_key_p
	dc.b	$10,0
	dc.l	yes_key_q
	dc.b	$13,0
	dc.l	yes_key_r
	dc.b	$1f,0
	dc.l	yes_key_s
	dc.b	$14,0
	dc.l	yes_key_t
	dc.b	$16,0
	dc.l	yes_key_u
	dc.b	$2f,0
	dc.l	yes_key_v
	dc.b	$11,0
	dc.l	yes_key_w
	dc.b	$2d,0
	dc.l	yes_key_x
	dc.b	$15,0
	dc.l	yes_key_y
	dc.b	$2c,0
	dc.l	yes_key_z

	dc.b	$1b,0
	dc.l	yes_key_Å
	dc.b	$1a,0
	dc.l	yes_key_Ñ
	dc.b	$28,0
	dc.l	yes_key_Ü
	dc.b	$27,0
	dc.l	yes_key_î

	dc.b	$1c,0
	dc.l	yes_key_return
	dc.b	$e,0
	dc.l	yes_key_back
	dc.b	$b,0
	dc.l	yes_key_0
	dc.b	$2,0
	dc.l	yes_key_1
	dc.b	$3,0
	dc.l	yes_key_2
	dc.b	$4,0
	dc.l	yes_key_3
	dc.b	$5,0
	dc.l	yes_key_4
	dc.b	$6,0
	dc.l	yes_key_5
	dc.b	$7,0
	dc.l	yes_key_6
	dc.b	$8,0
	dc.l	yes_key_7
	dc.b	$9,0
	dc.l	yes_key_8
	dc.b	$a,0
	dc.l	yes_key_9
	dc.b	$35,0
	dc.l	yes_underkey
key_list:
	dc.b	$48,0
	dc.l	key_upp
	dc.b	$50,0
	dc.l	key_down
	dc.b	$4b,0
	dc.l	key_left
	dc.b	$4d,0
	dc.l	key_right

	dc.b	$3b,0
	dc.l	key_f1
	dc.b	$3c,0
	dc.l	key_f2
	dc.b	$3d,0
	dc.l	key_f3
	dc.b	$3e,0
	dc.l	key_f4
	dc.b	$3f,0
	dc.l	key_f5
	dc.b	$40,0
	dc.l	key_f6
	dc.b	$41,0
	dc.l	key_f7
	dc.b	$42,0
	dc.l	key_f8
	dc.b	$43,0
	dc.l	key_f9
	dc.b	$44,0
	dc.l	key_f10

	dc.b	$72,0
	dc.l	key_enter
	dc.b	$71,0
	dc.l	key_punkt
	dc.b	$70,0
	dc.l	key_null

	dc.b	$47,0
	dc.l	key_backspace
	dc.b	$e,0
	dc.l	key_backspace2

	dc.b	$2a,0
	dc.l	key_shifton
	dc.b	$36,0
	dc.l	key_shifton
	dc.b	$38,0
	dc.l	key_allternate
	dc.b	$53,0
	dc.l	key_delete
	dc.b	$52,0
	dc.l	key_insert
	dc.b	$63,0
	dc.l	key_lpara
	dc.b	$64,0
	dc.l	key_rpara

	dc.b	$39,0
	dc.l	key_spazz

	dc.b	$2c,0
	dc.l	key_z
	dc.b	$1f,0
	dc.l	key_s
	dc.b	$2d,0
	dc.l	key_x
	dc.b	$20,0
	dc.l	key_d
	dc.b	$2e,0
	dc.l	key_c
	dc.b	$2f,0
	dc.l	key_v
	dc.b	$22,0
	dc.l	key_g
	dc.b	$30,0
	dc.l	key_b
	dc.b	$23,0
	dc.l	key_h
	dc.b	$31,0
	dc.l	key_n
	dc.b	$24,0
	dc.l	key_j
	dc.b	$32,0
	dc.l	key_m

	dc.b	$33,0
	dc.l	key_komm
	dc.b	$26,0
	dc.l	key_l
	dc.b	$34,0
	dc.l	key_pun
	dc.b	$27,0
	dc.l	key_î
	dc.b	$35,0
	dc.l	key_under
	dc.b	$10,0
	dc.l	key_q
	dc.b	$3,0
	dc.l	key_2
	dc.b	$11,0
	dc.l	key_w
	dc.b	$4,0
	dc.l	key_3
	dc.b	$12,0
	dc.l	key_e
	dc.b	$5,0
	dc.l	key_4
	dc.b	$13,0
	dc.l	key_r

	dc.b	$14,0
	dc.l	key_t
	dc.b	$7,0
	dc.l	key_6
	dc.b	$15,0
	dc.l	key_y
	dc.b	$8,0
	dc.l	key_7
	dc.b	$16,0
	dc.l	key_u
	dc.b	$17,0
	dc.l	key_i
	dc.b	$a,0
	dc.l	key_9
	dc.b	$18,0
	dc.l	key_o
	dc.b	$b,0
	dc.l	key_0
	dc.b	$19,0
	dc.l	key_p
	dc.b	$c,0
	dc.l	key_plus
	dc.b	$1a,0
	dc.l	key_Ü

	dc.b	$61,0
	dc.l	key_undo

	dc.b	$1c,0
	dc.l	key_return

	dc.b	$6a,0
	dc.l	key_numpad_4
	dc.b	$6b,0
	dc.l	key_numpad_5
	dc.b	$6c,0
	dc.l	key_numpad_6
	dc.b	$67,0
	dc.l	key_numpad_7
	dc.b	$68,0
	dc.l	key_numpad_8
	dc.b	$69,0
	dc.l	key_numpad_9

	dc.b	$6d,0
	dc.l	key_numpad_1
	dc.b	$6e,0
	dc.l	key_numpad_2
	dc.b	$6f,0
	dc.l	key_numpad_3

	dc.b	$62,0
	dc.l	key_help
	dc.b	$60,0
	dc.l	key_colors
	dc.b	$1,0
	dc.l	ms_exit

	dc.b	-1,0
	dc.l	0
kolla_midi:
	cmp.w	#1,old_midi_allert
	bne	not_found_midi
	move.w	#0,old_midi_allert
	move.w	old_midi,d0
	lea	midi_stuff,a0
	move.b	midi_buf+1,d0
koll_loop:
	cmp.b	#-1,(a0)
	beq	not_found_midi
	cmp.b	(a0),d0
	beq	found_midi
	addq.l	#6,a0
	bra	koll_loop
not_found_midi:
	rts
found_midi:
	move.l	2(a0),a0
	jmp	(a0)
old_midi:
	dc.w	0
old_midi_allert:
	dc.w	0
midi_stuff:
	dc.b	$30,0
	dc.l	key_z
	dc.b	$31,0
	dc.l	key_s
	dc.b	$32,0
	dc.l	key_x
	dc.b	$33,0
	dc.l	key_d
	dc.b	$34,0
	dc.l	key_c
	dc.b	$35,0
	dc.l	key_v
	dc.b	$36,0
	dc.l	key_g
	dc.b	$37,0
	dc.l	key_b
	dc.b	$38,0
	dc.l	key_h
	dc.b	$39,0
	dc.l	key_n
	dc.b	$3a,0
	dc.l	key_j
	dc.b	$3b,0
	dc.l	key_m

	dc.b	$3c,0
	dc.l	key_komm
	dc.b	$3d,0
	dc.l	key_l
	dc.b	$3e,0
	dc.l	key_pun
	dc.b	$3f,0
	dc.l	key_î
	dc.b	$40,0
	dc.l	key_under
	dc.b	$41,0
	dc.l	key_q
	dc.b	$42,0
	dc.l	key_2
	dc.b	$43,0
	dc.l	key_w
	dc.b	$44,0
	dc.l	key_3
	dc.b	$45,0
	dc.l	key_e
	dc.b	$46,0
	dc.l	key_4
	dc.b	$47,0
	dc.l	key_r

	dc.b	$48,0
	dc.l	key_t
	dc.b	$49,0
	dc.l	key_6
	dc.b	$4a,0
	dc.l	key_y
	dc.b	$4b,0
	dc.l	key_7
	dc.b	$4c,0
	dc.l	key_u
	dc.b	$4d,0
	dc.l	key_i
	dc.b	$4e,0
	dc.l	key_9
	dc.b	$4f,0
	dc.l	key_o
	dc.b	$50,0
	dc.l	key_0
	dc.b	$51,0
	dc.l	key_p
	dc.b	$52,0
	dc.l	key_plus
	dc.b	$53,0
	dc.l	key_Ü
	dc.b	-1,0
	dc.l	0
key_backspace2:
	cmp.w	#1,select_allert
	beq	ms_select_no
	rts
key_return:
	cmp.w	#1,select_allert
	beq	ms_select_yes
	rts
key_numpad_1:
	clr.b	save_key
	clr.b	mbutton
	jsr	ret_ints
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	load_set
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	init_ints
	jsr	copy_pic
	jsr	init_screen
	rts
key_numpad_2:
	clr.b	save_key
	clr.b	mbutton
	jsr	ret_ints
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	save_set
	movem.l	(sp)+,d0-d7/a0-a6
	jsr	init_ints
	jsr	copy_pic
	jsr	init_screen
	rts

make_mask:
	lea	cut,a0
	lea	mask,a1
	move.w	#13,d0
.loop:
	moveq	#0,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	or.w	(a0)+,d1
	move.w	d1,(a1)+
	dbra	d0,.loop
	rts
endsin:
	move.l	#sinus,sinpek
boll1:
	move.l	sinpek(pc),a0
	move.w	(a0)+,d1
	bmi.s	endsin
	move.l	a0,sinpek
	jsr	sprite(pc)
	move.l	a1,bort
	rts
bort:
	dc.l	0
endsin2:
	move.l	#sinus,sinpek2
boll2:
	move.l	sinpek2(pc),a0
	move.w	(a0)+,d1
	bmi.s	endsin2
	move.l	a0,sinpek2
	jsr	sprite(pc)
	move.l	a1,bort2
	rts
bort2:
	dc.l	0
sprite:
	move.l	screen_start,a1
	add.w	d1,a1
	lea	mask(pc),a0
	move.l	d0,d1
	lsr.w	#4,d1
	lsl.w	#3,d1
	add.w	d1,a1
	and.w	#15,d0
	eor.b	#$0f,d0
	move.l	a1,-(sp)
	move.w	#13,d1
.loop2:
	moveq	#0,d2
	move.w	(a0)+,d2
	lsl.l	d0,d2
	not.l	d2
	and.w	d2,8(a1)
	and.w	d2,10(a1)
	and.w	d2,12(a1)
	and.w	d2,14(a1)
	swap	d2
	and.w	d2,(a1)
	and.w	d2,2(a1)
	and.w	d2,4(a1)
	and.w	d2,6(a1)
	lea	160(a1),a1
	dbra	d1,.loop2
	lea	cut(pc),a0
	move.l	(sp),a1
	move.w	#13,d1
.loop:

	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	move.w	(a0)+,d4
	move.w	(a0)+,d5
	lsl.l	d0,d2
	lsl.l	d0,d3
	lsl.l	d0,d4
	lsl.l	d0,d5
	or.w	d2,8(a1)
	or.w	d3,10(a1)
	or.w	d4,12(a1)
	or.w	d5,14(a1)
	swap	d2
	swap	d3
	swap	d4
	swap	d5
	or.w	d2,(a1)
	or.w	d3,2(a1)
	or.w	d4,4(a1)
	or.w	d5,6(a1)
	lea	160(a1),a1
	dbra	d1,.loop
	move.l	(sp)+,a1
	rts
koll_stdst:
	cmp.l	#320-16,dx
	bge.s	subber
	cmp.l	#0,dx
	ble.s	adder
	rts
subber:
	move.l	#-2,dxx
	rts
adder:
	move.l	#2,dxx
	rts
koll_stdst2:
	cmp.l	#320-16,dx2
	bge.s	subber2
	cmp.l	#0,dx2
	ble.s	adder2
	rts
subber2:
	move.l	#-1,dxx2
	rts
adder2:
	move.l	#1,dxx2
	rts
dxx:
	dc.l	2
dxx2:
	dc.l	1
slak:
	move.l	bort,a0
	moveq	#0,d1
	move.w	#13,d0
.loop:
	move.l	d1,(a0)
	move.l	d1,4(a0)
	move.l	d1,8(a0)
	move.l	d1,12(a0)
	lea	160(a0),a0
	dbra	d0,.loop
	move.l	bort2,a0
	move.w	#13,d0
.loop2:
	move.l	d1,(a0)
	move.l	d1,4(a0)
	move.l	d1,8(a0)
	move.l	d1,12(a0)
	lea	160(a0),a0
	dbra	d0,.loop2
	rts

dx:
	dc.l	0
dx2:
	dc.l	100
sinpek:
	dc.l	sinus
sinpek2:
	dc.l	sinus+(20*2)
sinus:
 dc.w 28800,28320,27840,27520,27040,26560,26080,25600,25120,24800,24320,23840,23360,22880,22560,22080
 dc.w 21600,21120,20800,20320,19840,19520,19040,18560,18240,17760,17280,16960,16480,16160,15680,15360
 dc.w 14880,14560,14080,13760,13280,12960,12640,12160,11840,11520,11200,10720,10400,10080,9760,9440
 dc.w 9120,8800,8480,8160,7840,7520,7200,6880,6560,6240,6080,5760,5440,5280,4960,4640
 dc.w 4480,4160,4000,3840,3520,3360,3200,2880,2720,2560,2400,2240,2080,1920,1760,1600
 dc.w 1440,1280,1120,960,960,800,640,640,480,480,320,320,160,160,160,160
 dc.w 0,0,0,0,0,0,0,0,0,160,160,160,160,320,320,480
 dc.w 480,640,640,800,960,960,1120,1280,1440,1600,1760,1920,2080,2240,2400,2560
 dc.w 2720,3040,3200,3360,3520,3840,4000,4320,4480,4800,4960,5280,5600,5760,6080,6400
 dc.w 6720,6880,7200,7520,7840,8160,8480,8800,9120,9440,9760,10240,10560,10880,11200,11520
 dc.w 12000,12320,12640,13120,13440,13760,14240,14560,15040,15360,15840,16160,16640,16960,17440,17920
 dc.w 18240,18720,19200,19520,20000,20480,20800,21280,21760,22240,22560,23040,23520,24000,24480,24800
 dc.w 25280,25760,26240,26720,27040,27520,28000,28480
	dc.w	-1	*endsign
palle:
	dc.w	$0000,$0200,$0310,$0420,$0530,$0641,$0752,$0763
	dc.w	$0774,$0775,$0777,$0005,$0017,$0037,$0157,$0467
cut:
		dc.w	$0BA0,$07C0,$0000,$0000,$0820,$1830,$07C0,$0000
		dc.w	$3A50,$0998,$07E0,$0000,$4EC8,$35EC,$03F0,$0000
		dc.w	$0766,$7AF4,$01F8,$0000,$FBB8,$7D72,$00FC,$0000
		dc.w	$4DD2,$CEBA,$307C,$0000,$42CA,$C352,$3C3C,$0000
		dc.w	$5D70,$C192,$3E0C,$0000,$52BA,$CCC4,$3F00,$0000
		dc.w	$514C,$4E70,$3F80,$0000,$29A0,$6638,$1FC0,$0000
		dc.w	$17A0,$3030,$0FC0,$0000,$04A0,$0CC0,$0300,$0000

mask:
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000


key_numpad_3:
	move.w	#1,help_alert
	clr.b	save_key
	movem.l	$ffff8240.w,d0-d3
	movem.l	d0-d3,ojoj_pal
	movem.l	$ffff8250.w,d0-d3
	movem.l	d0-d3,ojoj_pal+16

	move.l	screen_start,a0
	move.w	#7999,d0
.loop:
	clr.l	(a0)+
	dbra	d0,.loop
	movem.l	palle,d0-d7
	movem.l	d0-d7,$ffff8240.w
	jsr	make_mask

.demo_loop:
	cmp.w	#1,wfnc
	bne.s	.demo_loop
	move.w	#0,wfnc

	move.l	dxx,d0
	add.l	d0,dx
	move.l	dxx2,d0
	add.l	d0,dx2

	jsr	koll_stdst(pc)
	jsr	koll_stdst2(pc)

	cmp.l	#0,bort
	beq	.no_remove
	jsr	slak(pc)
.no_remove:
	move.l	dx,d0	*x
	jsr	boll1(pc)
	move.l	dx2,d0	*x
	jsr	boll2(pc)

	cmp.b	#$6f,save_key
	bne	.demo_loop
	movem.l	ojoj_pal(pc),d0-d3
	movem.l	d0-d3,$ffff8240.w
	movem.l	ojoj_pal+16(pc),d0-d3
	movem.l	d0-d3,$ffff8250.w
	jsr	copy_pic
	jsr	init_screen
	move.w	#0,help_alert
	rts
ojoj_pal:
	ds.w	16
key_numpad_4:
	clr.b	save_key
	move.w	#-1,load_save_flags
	move.w	#0,load_save_flags+2
	move.w	#0,load_save_flags+4
	jsr	blarre_mode
	bra	ms_tryck_save
key_numpad_5:
	clr.b	save_key
	move.w	#0,load_save_flags
	move.w	#-1,load_save_flags+2
	move.w	#0,load_save_flags+4
	jsr	blarre_mode
	bra	ms_tryck_save
key_numpad_6:
	clr.b	save_key
	move.w	#0,load_save_flags
	move.w	#0,load_save_flags+2
	move.w	#-1,load_save_flags+4
	jsr	blarre_mode
	bra	ms_tryck_save

key_numpad_7:
	clr.b	save_key
	move.w	#-1,load_save_flags
	move.w	#0,load_save_flags+2
	move.w	#0,load_save_flags+4
	jsr	blarre_mode
	bra	ms_tryck_load
key_numpad_8:
	clr.b	save_key
	move.w	#0,load_save_flags
	move.w	#-1,load_save_flags+2
	move.w	#0,load_save_flags+4
	jsr	blarre_mode
	bra	ms_tryck_load
key_numpad_9:
	clr.b	save_key
	move.w	#0,load_save_flags
	move.w	#0,load_save_flags+2
	move.w	#-1,load_save_flags+4
	jsr	blarre_mode
	bra	ms_tryck_load

key_backspace:
	moveq	#0,d1 
	jsr	fuling
	rts

key_undo2:
	cmp.l	#0,undo_pos
	beq	no_undo
	bra	yoyo_undo
key_undo3:
	cmp.l	#0,undo_pos
	beq	no_undo
	bra	yoyo_undo2
key_undo:
	cmp.w	#1,last_undo
	beq.s	key_undo2
	cmp.w	#2,last_undo
	beq.s	key_undo3
	cmp.l	#0,save_old_note_pos
	beq.s	no_undo
	move.l	save_old_note_pos,a0
	move.w	save_old_note,(a0)
no_undo:
	rts
save_old_note:
	dc.w	0
save_old_note_pos:
	dc.l	0
key_upp:
	subq.b	#1,minipek
	move.b	minipek,d0
	and.b	#%00111111,d0
	move.b	d0,minipek
	cmp.w	#1,monon
	bne	no_lglame
	jsr	play_line
no_lglame:
	rts
key_down:
	addq.b	#1,minipek
	move.b	minipek,d0
	and.b	#%00111111,d0
	move.b	d0,minipek
	cmp.w	#1,monon
	bne	no_lglame2
	jsr	play_line
no_lglame2:
	rts
key_left:
	subq.b	#1,miniminipek
	move.b	miniminipek,d0
	and.b	#3,d0
	move.b	d0,miniminipek
	rts
key_right:
	addq.b	#1,miniminipek
	move.b	miniminipek,d0
	and.b	#3,d0
	move.b	d0,miniminipek
	rts
save_the_chann:
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	undo_chann,a1
	moveq	#63,d0
	move.l	a0,undo_pos
save_undo_loop:
	move.w	(a0),(a1)+
	addq.l	#8,a0
	dbra	d0,save_undo_loop
	move.w	#1,last_undo
	rts	
save_the_patt:
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	lea	undo_patt,a1
	move.l	#255,d0
	move.l	a0,undo_pos
save_undo_loop3:
	move.w	(a0)+,(a1)+
	dbra	d0,save_undo_loop3
	move.w	#2,last_undo
	rts	
yoyo_undo:
	moveq	#63,d0
	move.l	undo_pos,a0
	lea	undo_chann,a1
save_undo_loop2:
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	dbra	d0,save_undo_loop2
	rts	
yoyo_undo2:
	move.l	#255,d0
	move.l	undo_pos,a0
	lea	undo_patt,a1
save_undo_loop22:
	move.w	(a1)+,(a0)+
	dbra	d0,save_undo_loop22
	rts	
last_undo:
	dc.w	0
undo_pos:
	dc.l	0
undo_chann:
	ds.w	64
undo_patt:
	ds.w	64*4
key_f1:
	cmp.w	#1,shift_allert
	beq	shift_f1
	cmp.w	#1,allternate_allert
	beq	allert_f1
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	cutt_chann,a1
	moveq	#63,d0
save_chann_loop:
	move.w	(a0),(a1)+
	clr.w	(a0)
	addq.l	#8,a0
	dbra	d0,save_chann_loop
	rts
key_f2:
	cmp.w	#1,shift_allert
	beq	shift_f2
	cmp.w	#1,allternate_allert
	beq	allert_f2
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	cutt_chann,a1
	moveq	#63,d0
put_chann_loop:
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	dbra	d0,put_chann_loop
	rts
key_f3:
	cmp.w	#1,shift_allert
	beq	shift_f3
	cmp.w	#1,allternate_allert
	beq	allert_f3
	jsr	save_the_patt
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	lea	cutt_patt,a1
	moveq	#63,d0
save_patt_loop:
	move.w	(a0),(a1)+
	clr.w	(a0)+
	move.w	(a0),(a1)+
	clr.w	(a0)+
	move.w	(a0),(a1)+
	clr.w	(a0)+
	move.w	(a0),(a1)+
	clr.w	(a0)+
	dbra	d0,save_patt_loop
	rts
key_f4:
	cmp.w	#1,shift_allert
	beq	shift_f4
	cmp.w	#1,allternate_allert
	beq	allert_f4
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	lea	cutt_patt,a1
	moveq	#63,d0
put_patt_loop:
	move.w	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	move.w	(a1)+,(a0)+
	dbra	d0,put_patt_loop
	rts
key_f5:
	cmp.w	#1,shift_allert
	beq	shift_f5
	cmp.w	#1,allternate_allert
	beq	allert_f5
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	cutt_chann,a1
	moveq	#63,d0
overlay:
	move.w	(a1)+,d1
	cmp.w	#0,d1
	beq	no_move
	move.w	d1,(a0)
no_move:
	addq.l	#8,a0
	dbra	d0,overlay
	rts
key_f6:
	cmp.w	#1,shift_allert
	beq	shift_f6

	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	cutt_chann,a1
	moveq	#63,d0
underlay:
	move.w	(a0),d1
	cmp.w	#0,d1
	bne	no_move2
	move.w	(a1),(a0)
no_move2:
	addq.l	#8,a0
	addq.l	#2,a1
	dbra	d0,underlay
	rts
mon_status:
	move.w	#%0000000000000001,d0
	cmp.w	#1,monon
	bne	no_monlight
	move.w	#%1111111100000001,d0
no_monlight:
	move.l	screen_start,a0
	add.l	#(160*155)+(8*19),a0
	move.w	d0,160*0(a0)
	move.w	d0,160*1(a0)
	move.w	d0,160*2(a0)
	move.w	d0,160*3(a0)
	move.w	d0,160*4(a0)
	move.w	d0,160*5(a0)
	move.w	d0,160*6(a0)
	rts
tap_status:
	move.w	#%0000000000000001,d0
	cmp.w	#1,rec_flag
	bne	no_taplight
	move.w	#%1111111100000001,d0
no_taplight:
	move.l	screen_start,a0
	add.l	#(160*163)+(8*19),a0
	move.w	d0,160*0(a0)
	move.w	d0,160*1(a0)
	move.w	d0,160*2(a0)
	move.w	d0,160*3(a0)
	move.w	d0,160*4(a0)
	move.w	d0,160*5(a0)
	move.w	d0,160*6(a0)
	rts
moot_status:
	move.w	#%0000000000000001,d0
	cmp.w	#1,spec_toggle
	bne	no_speclight
	move.w	#%1111111100000001,d0
no_speclight:
	move.l	screen_start,a0
	add.l	#(160*171)+(8*19),a0
	move.w	d0,160*0(a0)
	move.w	d0,160*1(a0)
	move.w	d0,160*2(a0)
	move.w	d0,160*3(a0)
	move.w	d0,160*4(a0)
	move.w	d0,160*5(a0)
	move.w	d0,160*6(a0)
	rts

tap_onoff:
	dc.w	1
monon:
	dc.w	0
key_f7:
	cmp.w	#1,shift_allert
	beq	shift_f7
	move.b	#$3d,minipek
	rts
key_f8:
	cmp.w	#1,shift_allert
	beq	shift_f8
	move.b	#$d,minipek
	rts
key_f9:
	cmp.w	#1,shift_allert
	beq	shift_f9
	move.b	#$1d,minipek
	rts
key_f10:
	cmp.w	#1,shift_allert
	beq	shift_f10
	move.b	#$2d,minipek
	rts
key_enter:
	jsr	ms_play
	rts
key_punkt:
	jsr	ms_rec
	rts
key_null:
	jsr	ms_stop
	rts
key_delete:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	moveq	#0,d1
	moveq	#0,d2
	move.b	minipek,d1
	add.b	#3,d1
	and.b	#%00111111,d1
	move.w	d1,d2
	lsl.w	#3,d2
	add.l	d2,a0
	moveq	#62,d0
	sub.w	d1,d0
	bmi	no_delete
delete_loop:
	move.w	8(a0),(a0)
	addq.l	#8,a0
	dbra	d0,delete_loop
no_delete:
	clr.w	(a0)
	rts
key_insert:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	moveq	#0,d1
	moveq	#0,d2
	move.b	minipek,d1
	add.b	#3,d1
	and.b	#%00111111,d1
	move.w	d1,d2
	lsl.w	#3,d2
	add.l	d2,a0
	moveq	#62,d0
	sub.w	d1,d0
	bmi	no_insert
	move.w	d0,d1
	moveq	#8,d2
	mulu	d1,d2
	add.l	d2,a0
insert_loop:
	move.w	(a0),8(a0)
	subq.l	#8,a0
	dbra	d0,insert_loop
	clr.w	8(a0)
	rts
no_insert:
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	add.l	#8*63,a0
	clr.w	(a0)
	rts
key_shifton:
	eor.w	#1,shift_allert
	jsr	shift_status
	rts
shift_status:
	move.w	#%0000000000000001,d0
	cmp.w	#1,shift_allert
	bne	no_light
	move.w	#%1111111100000001,d0
no_light:
	move.l	screen_start,a0
	add.l	#(160*136)+(8*19),a0
	move.w	d0,160*0(a0)
	move.w	d0,160*1(a0)
	move.w	d0,160*2(a0)
	move.w	d0,160*3(a0)
	move.w	d0,160*4(a0)
	move.w	d0,160*5(a0)
	move.w	d0,160*6(a0)
	rts

key_allternate:
	eor.w	#1,allternate_allert
	jsr	alternate_status
	rts
alternate_status:
	move.w	#%0000000000000001,d0
	cmp.w	#1,allternate_allert
	bne	no_light2
	move.w	#%1111111100000001,d0
no_light2:
	move.l	screen_start,a0
	add.l	#(160*144)+(8*19),a0
	move.w	d0,160*0(a0)
	move.w	d0,160*1(a0)
	move.w	d0,160*2(a0)
	move.w	d0,160*3(a0)
	move.w	d0,160*4(a0)
	move.w	d0,160*5(a0)
	move.w	d0,160*6(a0)
	rts
allternate_allert:
	dc.w	0
shift_allert:
	dc.w	0
start_addr:
	dc.l	0
start_currpatt:
	dc.b	0
start_minipek:
	dc.b	0
start_miniminipek:
	dc.b	0
start_length:
	dc.b	0
	even
yes_alowed:
	dc.w	0
shift_f1:
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	moveq	#0,d1
	move.b	minipek,d1
	add.b	#3,d1
	and.b	#%00111111,d1
	lsl.w	#3,d1
	add.l	d1,a0
	move.l	a0,start_addr
	move.b	miniminipek,start_miniminipek
	move.b	minipek,d1
	add.b	#3,d1
	and.b	#%00111111,d1
	move.b	d1,start_minipek
	move.b	currpatt,start_currpatt
	clr.b	yes_alowed
	rts
allert_f1:
	eor.w	#1,monon
	jsr	mon_status
	rts
spec_toggle:
	dc.w	0
shift_f2:
	move.b	start_miniminipek,d0
	cmp.b	miniminipek,d0
	bne	no_mark
	move.b	start_currpatt,d0
	cmp.b	currpatt,d0
	bne	no_mark
	move.b	minipek,d0
	add.b	#3,d0
	and.b	#%00111111,d0
	move.b	start_minipek,d1
	sub.b	d1,d0
	bmi	no_mark
	move.b	d0,start_length
	move.b	#1,yes_alowed
	rts
allert_f2:
	eor.w	#1,rec_flag
	jsr	tap_status
	rts
no_mark:
	clr.b	yes_alowed
	rts
shift_f3:
	cmp.b	#1,yes_alowed
	bne	no_copy2
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	start_length,d0
	move.l	start_addr,a1
	move.b	minipek,micropek
copy_cutt:
	move.l	a0,-(sp)
	moveq	#0,d1
	move.b	micropek,d1
	add.b	#3,d1
	cmp.b	#$3d,micropek
	beq	no_need
	and.b	#%00111111,d1
	beq.s	no_copy
	lsl.w	#3,d1
	add.l	d1,a0
no_need:
	move.w	(a1),(a0)
	addq.l	#8,a1
	move.l	(sp)+,a0
	add.b	#1,micropek
	dbra	d0,copy_cutt
	rts
no_copy:
	move.l	(sp)+,a0
	rts
no_copy2:
	rts
micropek:
	dc.w	0
allert_f3:
	eor.w	#1,spec_toggle
	jsr	moot_status
	rts
shift_f4:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	moveq	#0,d1
	move.b	minipek,d1
	add.b	#3,d1
	and.b	#%00111111,d1
	lsl.w	#3,d1
	add.l	d1,a0
	move.w	(a0),d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	move.b	d0,sokare	

	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	move.w	#63,d0
replace_loop:
	move.w	(a0),d1
	move.w	d1,d2
	and.w	#$ff00,d2
	tst.w	d2
	beq.s	go_in_space
	and.w	#$00f0,d1
	lsr.w	#4,d1
	cmp.b	sokare,d1
	beq	yes_man
go_in_space:
	addq.l	#8,a0
	dbra	d0,replace_loop	
	rts
allert_f4:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0

	lea	cutt_chann,a1
	moveq	#63,d0
save_chann_loop3:
	clr.w	(a1)+
	dbra	d0,save_chann_loop3

	lea	cutt_chann,a1
	moveq	#63,d0
	moveq	#0,d1
	moveq	#2,d2
	move.b	curroffs,d1
	tst.w	d1
	beq	save_chann_loop2
	addq.w	#1,d0
	divu	d1,d0
	subq.w	#1,d0
	move.w	d1,d2
	add.w	d2,d2
	mulu	#8,d1
save_chann_loop2:
	move.w	(a0),(a1)
	add.l	d1,a0
	add.l	d2,a1
	dbra	d0,save_chann_loop2
	rts
shift_f5:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	moveq	#0,d1
	move.b	minipek,d1
	add.b	#3,d1
	and.b	#%00111111,d1
	lsl.w	#3,d1
	add.l	d1,a0
	move.w	(a0),d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	move.b	d0,sokare	

	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	cutt_chann,a1
	move.w	#63,d0
nulla_loop2:
	move.w	(a0),d1
	and.w	#$00f0,d1
	lsr.w	#4,d1
	cmp.b	sokare,d1
	bne	nulla2
	move.w	(a0),(a1)+
	addq.l	#8,a0
	dbra	d0,nulla_loop2
	bra	no_future
nulla2:
	clr.w	(a1)+
	addq.l	#8,a0
	dbra	d0,nulla_loop2
no_future:
	rts
this_buff:
	ds.w	64
other_buff:
	ds.w	64
allert_f5:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0

	moveq	#63,d0
.loop:
	cmp.w	#0,(a0)
	beq.s	.opsops
	addq.l	#8,a0
	dbra	d0,.loop
	rts
.opsops:
	move.w	d0,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	lea	drumm_stuff,a1
	move.b	currsam,d0
	add.w	d0,d0
	move.w	(a1,d0.w),d1
	add.w	d1,d1
	lea	trans_tab2,a1
	move.w	(a1,d1.w),d1
	move.w	d1,(a0)
	move.b	currsam,d0
	lsl.b	#4,d0
	or.b	currbonus,d0
	move.b	d0,1(a0)
	addq.l	#8,a0
	move.w	(sp)+,d0
	dbra	d0,.loop
	rts
shift_f6:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0

	move.l	a0,a1
	moveq	#0,d1
	move.b	minipek,d1
	add.b	#3,d1
	and.b	#%00111111,d1
	lsl.w	#3,d1
	add.l	d1,a1
	move.w	(a1),d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	move.b	d0,sokare	
	
	moveq	#63,d0
trans_loopv:
	moveq	#0,d1
	move.b	(a0),d1
	cmp.b	#0,d1
	beq	no_transv
	move.b	1(a0),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	cmp.b	sokare,d2
	bne	no_transv
	lea	conv_tone(pc),a1
	move.b	(a1,d1.w),d1
	add.b	#12,d1
	add.b	trans_no,d1
	lea	trans_tab(pc),a1
	move.b	(a1,d1.w),(a0)
no_transv:
	addq.l	#8,a0
	dbra	d0,trans_loopv
	rts
yes_man:
	move.w	(a0),d1
	and.w	#$ff0f,d1
	moveq	#0,d2
	move.b	currsam,d2
	lsl.w	#4,d2
	or.w	d2,d1
	move.w	d1,(a0)
	bra	go_in_space
shift_f7:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	moveq	#0,d1
	move.b	minipek,d1
	add.b	#3,d1
	and.b	#%00111111,d1
	lsl.w	#3,d1
	add.l	d1,a0
	move.w	(a0),d0
	and.w	#$00f0,d0
	lsr.w	#4,d0
	move.b	d0,sokare	

	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	move.w	#63,d0
nulla_loop:
	move.w	(a0),d1
	and.w	#$00f0,d1
	lsr.w	#4,d1
	cmp.b	sokare,d1
	bne	nulla
	clr.w	(a0)
nulla:
	addq.l	#8,a0
	dbra	d0,nulla_loop	
	rts
shift_f8:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	this_buff,a1
	moveq	#63,d0
	move.l	a0,d1
make_32:
	move.w	(a0),(a1)+
	addq.l	#8,a0
	dbra	d0,make_32

	move.l	d1,a0
	lea	this_buff,a1
	moveq	#31,d0
make_322:
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	clr.w	(a0)
	addq.l	#8,a0
	dbra	d0,make_322

	lea	other_buff,a0

	moveq	#31,d0
make_323:
	move.w	(a1)+,(a0)+
	clr.w	(a0)+
	dbra	d0,make_323
	rts
sokare:
	dc.w	0
shift_f9:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0

	lea	other_buff,a1
	moveq	#63,d0
	move.l	a0,d1
make_324:
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	dbra	d0,make_324
	rts
shift_f10:
	jsr	save_the_chann
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	add.l	d0,d0
	add.l	d0,a0
	lea	cutt_chann+64*2,a1
	moveq	#63,d0
save_chann_loop4:
	move.w	(a0),-(a1)
	add.l	#8,a0
	dbra	d0,save_chann_loop4
	rts
key_lpara:
	add.w	#$100,currloop
	move.l	screen_start,a1
	add.l	#(160*75)+112,a1
	move.w	currloop,d1
	jsr	print_hex3(pc)
	rts
key_rpara:
	sub.w	#$100,currloop
	move.l	screen_start,a1
	add.l	#(160*75)+112,a1
	move.w	currloop,d1
	jsr	print_hex3(pc)
	rts
key_spazz:
	cmp.w	#1,tap_onoff
	beq	dont_dubble2
	moveq	#0,d0
	moveq	#0,d1
	move.b	minipek,d3
	add.b	#3,d3
	and.b	#%00111111,d3
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	move.b	d3,d1
	mulu	#8,d1
	add.l	d1,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	lsl.b	#1,d0
	add.l	d0,a0
	move.w	(a0),save_old_note
	move.l	a0,save_old_note_pos

	clr.w	(a0)
	cmp.w	#1,spec_toggle
	beq	no_bonus_here
	move.b	currbonus,1(a0)
no_bonus_here:
	move.w	#0,last_undo
	jsr	play_line(pc)
	cmp.w	#1,play_flag
	beq	dont_dubble2

	addq.b	#1,minipek
	move.b	minipek,d0
	and.b	#%00111111,d0
	move.b	d0,minipek
dont_dubble2:
	rts
dkey1:
	moveq	#0,d4
	jsr	get_my
	jsr	write2
	rts
dkey2:
	moveq	#1,d4
	jsr	get_my
	jsr	write2
	rts
dkey3:
	moveq	#2,d4
	jsr	get_my
	jsr	write2
	rts
dkey4:
	moveq	#3,d4
	jsr	get_my
	jsr	write2
	rts
dkey5:
	moveq	#4,d4
	jsr	get_my
	jsr	write2
	rts
dkey6:
	moveq	#5,d4
	jsr	get_my
	jsr	write2
	rts
dkey7:
	moveq	#6,d4
	jsr	get_my
	jsr	write2
	rts
dkey8:
	moveq	#7,d4
	jsr	get_my
	jsr	write2
	rts
dkey9:
	moveq	#8,d4
	jsr	get_my
	jsr	write2
	rts
dkey10:
	moveq	#9,d4
	jsr	get_my
	jsr	write2
	rts
dkey11:
	moveq	#10,d4
	jsr	get_my
	jsr	write2
	rts
dkey12:
	moveq	#11,d4
	jsr	get_my
	jsr	write2
	rts
dkey13:
	moveq	#12,d4
	jsr	get_my
	jsr	write2
	rts
dkey14:
	moveq	#13,d4
	jsr	get_my
	jsr	write2
	rts
dkey15:
	moveq	#14,d4
	jsr	get_my
	jsr	write2
	rts
dkey16:
	moveq	#15,d4
	jsr	get_my
	jsr	write2
	rts
get_my:
	moveq	#0,d0
	moveq	#0,d1
	lea	drumm_stuff,a0
	move.b	d4,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	add.w	d1,d1
	lea	trans_tab2,a0
	move.w	(a0,d1.w),d1
	lsr.w	#8,d1
	move.w	d1,d2
	rts
fool_you:
	rts
key_z:
	cmp.w	#1,drumm_mode
	beq	dkey1
	move.l	#$10,d2
	jsr	write(pc)
	rts
key_s:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$11,d2
	jsr	write(pc)
	rts
key_x:
	cmp.w	#1,drumm_mode
	beq	dkey2
	move.l	#$12,d2
	jsr	write(pc)
	rts
key_d:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$13,d2
	jsr	write(pc)
	rts
key_c:
	cmp.w	#1,drumm_mode
	beq	dkey3
	move.l	#$14,d2
	jsr	write(pc)
	rts
key_v:
	cmp.w	#1,drumm_mode
	beq	dkey4
	move.l	#$15,d2
	jsr	write(pc)
	rts
key_g:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$16,d2
	jsr	write(pc)
	rts
key_b:
	cmp.w	#1,drumm_mode
	beq	dkey5
	move.l	#$17,d2
	jsr	write(pc)
	rts
key_h:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$18,d2
	jsr	write(pc)
	rts
key_n:
	cmp.w	#1,drumm_mode
	beq	dkey6
	move.l	#$19,d2
	jsr	write(pc)
	rts
key_j:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$1a,d2
	jsr	write(pc)
	rts
key_m:
	cmp.w	#1,drumm_mode
	beq	dkey7
	move.l	#$1b,d2
	jsr	write(pc)
	rts
key_komm:
	cmp.w	#1,drumm_mode
	beq	dkey8
	move.l	#$20,d2
	jsr	write(pc)
	rts
key_l:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$21,d2
	jsr	write(pc)
	rts
key_pun:
	cmp.w	#1,drumm_mode
	beq	dkey9
	move.l	#$22,d2
	jsr	write(pc)
	rts
key_î:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$23,d2
	jsr	write(pc)
	rts
key_under:
	cmp.w	#1,drumm_mode
	beq	dkey10
	move.l	#$24,d2
	jsr	write(pc)
	rts
key_q:
	cmp.w	#1,drumm_mode
	beq	dkey11
	move.l	#$25,d2
	jsr	write(pc)
	rts
key_2:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$26,d2
	jsr	write(pc)
	rts
key_w:
	cmp.w	#1,drumm_mode
	beq	dkey12
	move.l	#$27,d2
	jsr	write(pc)
	rts
key_3:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$28,d2
	jsr	write(pc)
	rts
key_e:
	cmp.w	#1,drumm_mode
	beq	dkey13
	move.l	#$29,d2
	jsr	write(pc)
	rts
key_4:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$2a,d2
	jsr	write(pc)
	rts
key_r:
	cmp.w	#1,drumm_mode
	beq	dkey14
	move.l	#$2b,d2
	jsr	write(pc)
	rts

key_t:
	cmp.w	#1,drumm_mode
	beq	dkey15
	move.l	#$30,d2
	jsr	write(pc)
	rts
key_6:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$31,d2
	jsr	write(pc)
	rts
key_y:
	cmp.w	#1,drumm_mode
	beq	dkey16
	move.l	#$32,d2
	jsr	write(pc)
	rts
key_7:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$33,d2
	jsr	write(pc)
	rts
key_u:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$34,d2
	jsr	write(pc)
	rts
key_i:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$35,d2
	jsr	write(pc)
	rts
key_9:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$36,d2
	jsr	write(pc)
	rts
key_o:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$37,d2
	jsr	write(pc)
	rts
key_0:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$38,d2
	jsr	write(pc)
	rts
key_p:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$39,d2
	jsr	write(pc)
	rts
key_plus:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$3a,d2
	jsr	write(pc)
	rts
key_Ü:
	cmp.w	#1,drumm_mode
	beq	fool_you
	move.l	#$3b,d2
	jsr	write(pc)
	rts
key_colors:
	cmp.w	#1,shift_allert
	beq	do_line_colors

	cmp.w	#1,allternate_allert
	beq	do_over_colors

	move.l	panel_pet(pc),a0
	move.w	(a0),d0
	bmi.s	end_panel
go_panel:
	move.w	(a0)+,$ffff8242.w
	move.w	(a0)+,$ffff8244.w
	move.w	(a0)+,$ffff8246.w
	move.l	a0,panel_pet
	rts
end_panel:
	lea	panel_colors(pc),a0
	bra.s	go_panel
panel_pet:
	dc.l	panel_colors
panel_colors:
	dc.w	$777,$444,$222
	dc.w	$700,$400,$200
	dc.w	$070,$040,$020
	dc.w	$007,$004,$002
	dc.w	$770,$440,$220
	dc.w	$077,$044,$022
	dc.w	$707,$404,$202
	dc.w	$613,$413,$303
	dc.w	$742,$532,$322
	dc.w	$775,$335,$115
	dc.w	$744,$533,$323
	dc.w	$672,$542,$222
	dc.w	$004,$117,$257
	dc.w	$743,$521,$300
	dc.w	$750,$501,$300
	dc.w	$654,$432,$211
	dc.w	$770,$047,$003
	dc.w	$767,$434,$101
	dc.w	$675,$330,$110
	dc.w	$553,$442,$331
	dc.w	$533,$422,$311

	dc.w	-1
do_line_colors:
	move.l	line_pet(pc),a0
	move.w	(a0),d0
	bmi.s	line_panel
go_line_panel:
	move.w	(a0),$ffff824a.w
	move.w	(a0)+,$ffff825a.w
	move.w	(a0),$ffff824c.w
	move.w	(a0)+,$ffff825c.w
	move.w	(a0),$ffff824e.w
	move.w	(a0)+,$ffff825e.w
	move.w	(a0),$ffff8248.w
	move.w	(a0)+,$ffff8258.w
	move.l	a0,line_pet
	rts
line_panel:
	lea	line_colors(pc),a0
	bra.s	go_line_panel
line_pet:
	dc.l	line_colors
line_colors:
	dc.w	$777,$444,$222,$222
	dc.w	$700,$400,$200,$200
	dc.w	$070,$040,$020,$020
	dc.w	$007,$004,$002,$002
	dc.w	$770,$440,$220,$220
	dc.w	$077,$044,$022,$022
	dc.w	$707,$404,$202,$202
	dc.w	$613,$413,$303,$202
	dc.w	$742,$532,$322,$211
	dc.w	$775,$335,$115,$004
	dc.w	$744,$533,$323,$212
	dc.w	$672,$542,$222,$222
	dc.w	$004,$117,$257,$146
	dc.w	$743,$521,$300,$200
	dc.w	$750,$501,$300,$200
	dc.w	$654,$432,$211,$100
	dc.w	$770,$047,$003,$002
	dc.w	$767,$434,$101,$100
	dc.w	$675,$330,$110,$100
	dc.w	$553,$442,$331,$221
	dc.w	-1

do_over_colors:
	move.l	over_pet(pc),a0
	move.w	(a0),d0
	bmi.s	over_panel
go_over_panel:
	move.w	(a0)+,$ffff8250.w
	move.w	(a0)+,$ffff8252.w
	move.w	(a0)+,$ffff8254.w
	move.w	(a0)+,$ffff8256.w
	move.l	a0,over_pet
	rts
over_panel:
	lea	line_colors(pc),a0
	bra.s	go_over_panel
over_pet:
	dc.l	line_colors

just_play2:
	lea	curr_tunes,a0
	clr.w	(a0)
	clr.w	2(a0)
	clr.w	4(a0)
	clr.w	6(a0)
	moveq	#0,d0
	move.b	miniminipek,d0
	add.w	d0,d0
	add.l	d0,a0
	move.b	d2,(a0)
	move.b	d4,d0
	lsl.b	#4,d0
	move.b	currbonus,d1
	or.b	d0,d1
	move.b	d1,1(a0)
	jsr	start_digi
	rts
just_play:
	lea	curr_tunes,a0
	clr.w	(a0)
	clr.w	2(a0)
	clr.w	4(a0)
	clr.w	6(a0)
	moveq	#0,d0
	move.b	miniminipek,d0
	add.w	d0,d0
	add.l	d0,a0
	move.b	d2,(a0)
	move.b	currsam,d0
	lsl.b	#4,d0
	move.b	currbonus,d1
	or.b	d0,d1
	move.b	d1,1(a0)
	jsr	start_digi
	rts
write:
	cmp.w	#1,tap_onoff
	beq.s	just_play
	moveq	#0,d0
	moveq	#0,d1
	move.b	minipek,d3
	addq.b	#3,d3
	and.b	#%00111111,d3
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	move.b	d3,d1
	mulu	#8,d1
	add.l	d1,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	lsl.b	#1,d0
	add.l	d0,a0
	move.w	(a0),save_old_note
	move.l	a0,save_old_note_pos
	move.b	d2,(a0)
	move.b	currsam,d0
	lsl.b	#4,d0
	move.b	currbonus,d1
	or.b	d0,d1
	move.b	d1,1(a0)
	move.w	#0,last_undo
	jsr	play_line
	cmp.w	#1,play_flag
	beq.s	dont_dubble

	move.b	curroffs,d0
	add.b	d0,minipek
	move.b	minipek,d0
	and.b	#%00111111,d0
	move.b	d0,minipek
dont_dubble:
	rts
write2:
	cmp.w	#1,tap_onoff
	beq	just_play2
	moveq	#0,d0
	moveq	#0,d1
	move.b	minipek,d3
	addq.b	#3,d3
	and.b	#%00111111,d3
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	move.b	d3,d1
	mulu	#8,d1
	add.l	d1,d0
	add.l	d0,a0
	moveq	#0,d0
	move.b	miniminipek,d0
	lsl.b	#1,d0
	add.l	d0,a0
	move.w	(a0),save_old_note
	move.l	a0,save_old_note_pos
	move.b	d2,(a0)
	move.b	d4,d0
	lsl.b	#4,d0
	move.b	currbonus,d1
	or.b	d0,d1
	move.b	d1,1(a0)
	move.w	#0,last_undo
	jsr	play_line
	cmp.w	#1,play_flag
	beq	dont_dubble
	move.b	curroffs,d0
	add.b	d0,minipek
	move.b	minipek,d0
	and.b	#%00111111,d0
	move.b	d0,minipek
	rts
play_line:
	moveq	#0,d0
	moveq	#0,d1
	move.b	minipek,d3
	addq.b	#3,d3
	and.b	#%00111111,d3
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	move.b	d3,d1
	mulu	#8,d1
	add.l	d1,d0
	add.l	d0,a0
	lea	curr_tunes,a1

	cmp.w	#0,chan1_active
	bne	no_ch1
	move.w	(a0)+,(a1)+
	bra	forb_shit
no_ch1:
	clr.w	(a1)+
	addq.l	#2,a0
forb_shit:
	cmp.w	#0,chan2_active
	bne	no_ch2
	move.w	(a0)+,(a1)+
	bra	forb_shit2
no_ch2:
	clr.w	(a1)+
	addq.l	#2,a0
forb_shit2:
	cmp.w	#0,chan3_active
	bne	no_ch3
	move.w	(a0)+,(a1)+
	bra	forb_shit3
no_ch3:
	clr.w	(a1)+
	addq.l	#2,a0
forb_shit3:
	cmp.w	#0,chan4_active
	bne	no_ch4
	move.w	(a0)+,(a1)+
	bra	forb_shit4
no_ch4:
	clr.w	(a1)+
	addq.l	#2,a0
forb_shit4:
	jsr	start_digi
	rts

print_score:
	moveq	#0,d0
	moveq	#0,d1
	move.b	minipek,d3
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	move.b	d3,d1
	and.b	#%00111111,d3
	mulu	#8,d1
	add.l	d1,d0
	add.l	d0,a0
go_spessare:
	move.w	(a0)+,d1
	move.l	screen_start,a1
	add.l	#(160*139)+24,a1
	jsr	big_print(pc)
	moveq	#0,d1
	move.b	minipek,d1
	jsr	printmini(pc)
	rts
printmini:
	move.l	screen_start,a1
	add.l	#(160*139)+1,a1
	moveq	#6,d2
	lea	hex_tab,a0
print_mini_loop:
	and.b	#%00111111,d1
	move.b	d1,d0
	and.w	#$00f0,d0
	lsr.w	#1,d0
	jsr	blatt2(pc)
	move.b	d1,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	addq.l	#7,a1
	jsr	blatt2(pc)
	subq.l	#7,a1
	addq.w	#1,d1
	lea	160*8(a1),a1
	dbra	d2,print_mini_loop
	rts
big_print:
	moveq	#6,d2
big_print_loop:
	move.l	a0,-(sp)
	lea	hex_tab,a0
	move.w	d1,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$0f00,d0
	lsr.w	#5,d0
	addq.l	#1,a1
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$00f0,d0
	lsr.w	#1,d0
	addq.l	#7,a1
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	addq.l	#1,a1
	jsr	blatt2(pc)
	jsr	print_tone(pc)
	move.l	(sp)+,a0
	move.w	(a0)+,d1
	move.l	a0,-(sp)
	lea	hex_tab,a0
	move.w	d1,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	add.l	#8+8,a1
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$0f00,d0
	lsr.w	#5,d0
	addq.l	#7,a1
	jsr	blatt2
	move.w	d1,d0
	and.w	#$00f0,d0
	lsr.w	#1,d0
	addq.l	#1,a1
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	addq.l	#7,a1
	jsr	blatt2(pc)
	jsr	print_tone2(pc)
	move.l	(sp)+,a0
	move.w	(a0)+,d1
	add.l	#8+8,a1
	move.l	a0,-(sp)
	lea	hex_tab,a0
	move.w	d1,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	jsr	blatt2
	move.w	d1,d0
	and.w	#$0f00,d0
	lsr.w	#5,d0
	addq.l	#1,a1
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$00f0,d0
	lsr.w	#1,d0
	addq.l	#7,a1
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	addq.l	#1,a1
	jsr	blatt2(pc)
	jsr	print_tone(pc)
	move.l	(sp)+,a0
	move.w	(a0)+,d1
	move.l	a0,-(sp)
	lea	hex_tab,a0
	move.w	d1,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#1,d0
	add.l	#8+8,a1
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$0f00,d0
	lsr.w	#5,d0
	addq.l	#7,a1
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$00f0,d0
	lsr.w	#1,d0
	addq.l	#1,a1
	jsr	blatt2(pc)
	move.w	d1,d0
	and.w	#$000f,d0
	lsl.w	#3,d0
	addq.l	#7,a1
	jsr	blatt2
	jsr	print_tone2(pc)
	move.l	(sp)+,a0
	move.w	(a0)+,d1
	add.l	#(160*8)-(12*8),a1
	addq.b	#1,d3
	and.b	#%00111111,d3
	beq	begin
	dbra	d2,big_print_loop
	rts
begin:
	moveq	#0,d3
	moveq	#0,d0
	lea	big_patt_buff,a0	
	move.b	currpatt,d0
	mulu	#8*64,d0
	add.l	d0,a0
	move.w	(a0)+,d1
	dbra	d2,big_print_loop
	rts	
blatt2:
	move.l	a0,d5
	add.l	d0,a0
	move.b	(a0)+,160*0(a1)
	move.b	(a0)+,160*1(a1)
	move.b	(a0)+,160*2(a1)
	move.b	(a0)+,160*3(a1)
	move.b	(a0)+,160*4(a1)
	move.b	(a0)+,160*5(a1)
	move.b	(a0)+,160*6(a1)
	move.l	d5,a0
	rts
print_tone:
	movem.l	a0-a1,-(sp)
	sub.l	#17,a1
	lea	tone_tab,a0
	moveq	#0,d0
	move.w	d1,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	cmp.b	#0,d0
	beq.s	null
	cmp.b	#3,d0
	ble.s	goon
null:
	lea	empty_tone,a0
	bra.s	blatt_null
goon:
	moveq	#0,d0
	move.w	d1,d0
	and.w	#$0f00,d0
	lsr.w	#4,d0
	add.l	d0,a0
blatt_null:
	move.b	(a0)+,160*0(a1)
	move.b	(a0)+,160*0+1(a1)
	move.b	(a0)+,160*1(a1)
	move.b	(a0)+,160*1+1(a1)
	move.b	(a0)+,160*2(a1)
	move.b	(a0)+,160*2+1(a1)
	move.b	(a0)+,160*3(a1)
	move.b	(a0)+,160*3+1(a1)
	move.b	(a0)+,160*4(a1)
	move.b	(a0)+,160*4+1(a1)
	move.b	(a0)+,160*5(a1)
	move.b	(a0)+,160*5+1(a1)
	move.b	(a0)+,160*6(a1)
	move.b	(a0)+,160*6+1(a1)
	movem.l	(sp)+,a0-a1
	rts
print_tone2:
	movem.l	a0-a1,-(sp)
	sub.l	#23,a1
	lea	tone_tab,a0
	moveq	#0,d0
	move.w	d1,d0
	and.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	cmp.b	#0,d0
	beq.s	null2
	cmp.b	#3,d0
	ble.s	goon2
null2:
	lea	empty_tone,a0
	bra.s	blatt_null2
goon2:
	moveq	#0,d0
	move.w	d1,d0
	and.w	#$0f00,d0
	lsr.w	#4,d0
	add.l	d0,a0
blatt_null2:
	move.b	(a0)+,160*0(a1)
	move.b	(a0)+,160*0+7(a1)
	move.b	(a0)+,160*1(a1)
	move.b	(a0)+,160*1+7(a1)
	move.b	(a0)+,160*2(a1)
	move.b	(a0)+,160*2+7(a1)
	move.b	(a0)+,160*3(a1)
	move.b	(a0)+,160*3+7(a1)
	move.b	(a0)+,160*4(a1)
	move.b	(a0)+,160*4+7(a1)
	move.b	(a0)+,160*5(a1)
	move.b	(a0)+,160*5+7(a1)
	move.b	(a0)+,160*6(a1)
	move.b	(a0)+,160*6+7(a1)
	movem.l	(sp)+,a0-a1
	rts
nottare:
	move.l	screen_start,a1
	add.l	#(160*163),a1
	moveq	#6,d0
not_loop:
	not.b	(8*0)+1(a1)
	not.b	(8*1)(a1)
	not.w	(8*2)(a1)
	not.w	(8*3)(a1)
	not.w	(8*4)(a1)
	not.b	(8*5)+1(a1)
	not.w	(8*6)(a1)
	not.w	(8*7)(a1)
	not.b	(8*8)(a1)
	not.w	(8*9)(a1)
	not.w	(8*10)(a1)
	not.w	(8*11)(a1)
	not.b	(8*12)+1(a1)
	not.w	(8*13)(a1)
	not.w	(8*14)(a1)
	not.b	(8*15)(a1)
	lea	160(a1),a1
	dbra	d0,not_loop
	rts
cursor:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	cmp.b	#0,miniminipek
	bne	no_cursor1
	moveq	#-1,d0
	bra	do_cursor
no_cursor1:
	cmp.b	#1,miniminipek
	bne	no_cursor2
	moveq	#-1,d1
	bra	do_cursor
no_cursor2:
	cmp.b	#2,miniminipek
	bne	no_cursor3
	moveq	#-1,d2
	bra	do_cursor
no_cursor3:
	moveq	#-1,d3
do_cursor:
	move.l	screen_start,a1
	add.l	#(160*163)+20,a1
	move.w	d0,160*0(a1)
	move.w	d0,160*1(a1)
	move.w	d0,160*2(a1)
	move.w	d0,160*3(a1)
	move.w	d0,160*4(a1)
	move.w	d0,160*5(a1)
	move.w	d0,160*6(a1)
	move.w	d0,160*0+8(a1)
	move.w	d0,160*1+8(a1)
	move.w	d0,160*2+8(a1)
	move.w	d0,160*3+8(a1)
	move.w	d0,160*4+8(a1)
	move.w	d0,160*5+8(a1)
	move.w	d0,160*6+8(a1)
	move.w	d0,160*0+16(a1)
	move.w	d0,160*1+16(a1)
	move.w	d0,160*2+16(a1)
	move.w	d0,160*3+16(a1)
	move.w	d0,160*4+16(a1)
	move.w	d0,160*5+16(a1)
	move.w	d0,160*6+16(a1)
	move.l	screen_start,a1
	add.l	#(160*163)+16+29,a1
	move.b	d1,160*0(a1)
	move.b	d1,160*1(a1)
	move.b	d1,160*2(a1)
	move.b	d1,160*3(a1)
	move.b	d1,160*4(a1)
	move.b	d1,160*5(a1)
	move.b	d1,160*6(a1)
	move.w	d1,160*0+7(a1)
	move.w	d1,160*1+7(a1)
	move.w	d1,160*2+7(a1)
	move.w	d1,160*3+7(a1)
	move.w	d1,160*4+7(a1)
	move.w	d1,160*5+7(a1)
	move.w	d1,160*6+7(a1)
	move.w	d1,160*0+15(a1)
	move.w	d1,160*1+15(a1)
	move.w	d1,160*2+15(a1)
	move.w	d1,160*3+15(a1)
	move.w	d1,160*4+15(a1)
	move.w	d1,160*5+15(a1)
	move.w	d1,160*6+15(a1)
	move.b	d1,160*0+23(a1)
	move.b	d1,160*1+23(a1)
	move.b	d1,160*2+23(a1)
	move.b	d1,160*3+23(a1)
	move.b	d1,160*4+23(a1)
	move.b	d1,160*5+23(a1)
	move.b	d1,160*6+23(a1)
	move.l	screen_start,a1
	add.l	#(160*163)+16+60,a1
	move.w	d2,160*0(a1)
	move.w	d2,160*1(a1)
	move.w	d2,160*2(a1)
	move.w	d2,160*3(a1)
	move.w	d2,160*4(a1)
	move.w	d2,160*5(a1)
	move.w	d2,160*6(a1)
	move.w	d2,160*0+8(a1)
	move.w	d2,160*1+8(a1)
	move.w	d2,160*2+8(a1)
	move.w	d2,160*3+8(a1)
	move.w	d2,160*4+8(a1)
	move.w	d2,160*5+8(a1)
	move.w	d2,160*6+8(a1)
	move.w	d2,160*0+16(a1)
	move.w	d2,160*1+16(a1)
	move.w	d2,160*2+16(a1)
	move.w	d2,160*3+16(a1)
	move.w	d2,160*4+16(a1)
	move.w	d2,160*5+16(a1)
	move.w	d2,160*6+16(a1)
	move.l	screen_start,a1
	add.l	#(160*163)+16+56+29,a1
	move.b	d3,160*0(a1)
	move.b	d3,160*1(a1)
	move.b	d3,160*2(a1)
	move.b	d3,160*3(a1)
	move.b	d3,160*4(a1)
	move.b	d3,160*5(a1)
	move.b	d3,160*6(a1)
	move.w	d3,160*0+7(a1)
	move.w	d3,160*1+7(a1)
	move.w	d3,160*2+7(a1)
	move.w	d3,160*3+7(a1)
	move.w	d3,160*4+7(a1)
	move.w	d3,160*5+7(a1)
	move.w	d3,160*6+7(a1)
	move.w	d3,160*0+15(a1)
	move.w	d3,160*1+15(a1)
	move.w	d3,160*2+15(a1)
	move.w	d3,160*3+15(a1)
	move.w	d3,160*4+15(a1)
	move.w	d3,160*5+15(a1)
	move.w	d3,160*6+15(a1)
	move.b	d3,160*0+23(a1)
	move.b	d3,160*1+23(a1)
	move.b	d3,160*2+23(a1)
	move.b	d3,160*3+23(a1)
	move.b	d3,160*4+23(a1)
	move.b	d3,160*5+23(a1)
	move.b	d3,160*6+23(a1)
	rts
**************
* set        *
**************
*	dc.b	"TCBSETUP"	*0	
*	dS.W	16 *COLORS	*8
*	dc.b	0 *line on/off	*40	0=off
*	dc.b	0 *globe on/off	*41	0=internal
*	dc.b	0 *stereo	*42	0=st 1=ste s 2=ste m
*	dc.b	0 *reserved	*43	????
*	dc.b	0 *mouse	*44	0=off
*	ds.b	100 *reserved   *45	????
load_set:
	move.l	#"TCBS",filename
	move.l	#"ETUP",filename+4
	move.l	#".INF",filename+8
	move.l	#8,size
	move.l	#tcbsetup,load_addr
	jsr	load_file2(pc)
	cmp.l	#-1,d0
	beq	no_load_set
	cmp.l	#"TCBS",tcbsetup
	bne	error_format
	cmp.l	#"ETUP",tcbsetup+4
	bne	error_format
	move.l	#145,size
	move.l	#tcbsetup,load_addr
	jsr	load_file2(pc)

	moveq	#0,d0
	move.b	tcbsetup+40,d0
	move.w	d0,worm_flg

	moveq	#0,d0
	move.b	tcbsetup+41,d0
	move.w	d0,ors_flag
;	jsr	int_ext
	
	cmp.w	#0,ste_flag
	beq	xno_ste_on
	cmp.b	#0,tcbsetup+42
	beq	xstart_st
	cmp.b	#1,tcbsetup+42
	beq	xstart_ste
	cmp.b	#2,tcbsetup+42
	beq	xstart_ste2
xno_ste_on:
	moveq	#0,d0
	move.b	tcbsetup+44,d0
	move.w	d0,ruta6b
	move.w	d0,turbo_m

	movem.l	tcbsetup+8,d0-d7
	movem.l	d0-d7,$ffff8240.w
no_load_set:
	rts
save_set:
	move.l	#"TCBS",filename
	move.l	#"ETUP",filename+4
	move.l	#".INF",filename+8
	move.b	worm_flg+1,tcbsetup+40
	move.b	ors_flag+1,tcbsetup+41
	move.w	ruta4a,d0
	move.w	ruta4b,d1
	add.w	d1,d1
	or.w	d1,d0
	move.b	d0,tcbsetup+42
	move.b	turbo_m+1,tcbsetup+44
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,tcbsetup+8

	move.l	#145,size
	move.l	#tcbsetup,load_addr
	jsr	save_file(pc)
	rts
xstart_st:
	move.w	#0,ruta4a
	move.w	#0,ruta4b

	clr.w	$ff8900
	move.l	#samp1,$134
	move.l	#samp1,currir
	clr.l	mod_flg
	clr.w	vec11+2
	clr.w	vec12+2
	clr.w	vec13+2

	move.l	#vec11,chann1
	move.l	#vec12,chann2
	move.l	#vec13,chann3
	bra	xno_ste_on
xonce:
	lea	setsam_dat,a0
	move.w	#3,d0
.xmwwrite:
	move.w	#$7ff,$ff8924
.xmwwrite2:
	cmp.w	#$07ff,$ff8924
	bne.s	.xmwwrite2
	move.w	(a0)+,$ff8922
	dbra	d0,.xmwwrite
	move.w	#1,gurgelmuffe
xstart_ste:
	move.w	#1,ruta4a
	move.w	#0,ruta4b

	cmp.w	#0,gurgelmuffe
	beq	xonce
	move.l	#starte,temp
	move.b	temp+1,$ff8903
	move.b	temp+2,$ff8905
	move.b	temp+3,$ff8907

	move.l	#ende,temp
	move.b	temp+1,$ff890f
	move.b	temp+2,$ff8911
	move.b	temp+3,$ff8913

	move.w	#%0000000000000001,$ff8920

	move.w	#3,$ff8900
	move.l	#samp1ste,$134
	move.l	#samp1ste,currir
	clr.w	vec11e+2
	clr.w	vec12e+2
	clr.w	vec13e+2
	move.l	#vec11e,chann1
	move.l	#vec12e,chann2
	move.l	#vec13e,chann3
	move.l	#1,mod_flg
	bra	xno_ste_on
xonce2:
	lea	setsam_dat,a0
	move.w	#3,d0
xmwwrite3:
	move.w	#$7ff,$ff8924
xmwwrite4:
	cmp.w	#$07ff,$ff8924
	bne.s	xmwwrite4
	move.w	(a0)+,$ff8922
	dbra	d0,xmwwrite3
	move.w	#1,gurgelmuffe
xstart_ste2:
	move.w	#0,ruta4a
	move.w	#1,ruta4b
	cmp.w	#0,gurgelmuffe
	beq	xonce2
	move.l	#starte,temp
	move.b	temp+1,$ff8903
	move.b	temp+2,$ff8905
	move.b	temp+3,$ff8907

	move.l	#ende,temp
	move.b	temp+1,$ff890f
	move.b	temp+2,$ff8911
	move.b	temp+3,$ff8913

	move.w	#%0000000000000001,$ff8920

	move.w	#3,$ff8900
	move.l	#samp1ste2,$134
	move.l	#samp1ste2,currir
	clr.w	vec11e2+2
	clr.w	vec12e2+2
	clr.w	vec13e2+2
	move.l	#vec11e2,chann1
	move.l	#vec12e2,chann2
	move.l	#vec13e2,chann3
	move.l	#2,mod_flg
	bra	xno_ste_on
load_sam:
	jsr	get_size(pc)
	cmp.l	#-1,d0
	beq	no_load_sam
	move.l	dta+26,d0
	add.l	d0,d0
	add.l	#512,d0
	cmp.l	curr_mem_zize,d0
	bgt	nono4


;	jsr	get_size(pc)
;	cmp.l	#-1,d0
;	beq	no_load_sam

	jsr	flyttdown

	move.l	dta+26,size
	move.l	size(pc),d0
	moveq	#0,d1
	move.b	currsam,d1
	jsr	fixx_buff(pc)
	moveq	#0,d1
	move.b	currsam,d1
	lea	samnames,a0
	lsl.w	#3,d1
	add.l	d1,a0
	lea	filename,a1
	rept	8
	move.b	(a1)+,(a0)+
	endr
	jsr	load_file(pc)
	move.l	load_addr(pc),a0
	add.l	size(pc),a0
	move.w	#over_buff-1,d0
clear_loop:
	move.b	#$7f,(a0)+
	dbra	d0,clear_loop

	jsr	fix_the_loop
	jsr	flyttupp
	jsr	setvolume
	rts
save_sam:
	moveq	#0,d1
	move.b	currsam,d1
	lsl.w	#3,d1
	lea	samnames,a0
	add.l	d1,a0
	cmp.l	#$20202020,(a0)
	beq	no_def_lamer

	jsr	flyttdown

	moveq	#0,d1
	move.b	currsam,d1
	lsl.w	#3,d1
	lea	samp_pet_buff,a0
	move.l	(a0,d1.w),load_addr
	add.l	#start_buff,load_addr
	move.l	4(a0,d1.w),size
	sub.l	#over_buff,size

	jsr	save_file(pc)

	jsr	fix_the_loop
	jsr	flyttupp
	jsr	setvolume
	jsr	get_all_names
no_load_sam:
	rts
do_crypt:
	move.b	curroffs,d0
	lea	patt_tab,a0
	move.w	#127,d0
.loop:
	eor.b	d0,(a0)+
	dbra	d0,.loop
	rts
test_crypt:
	tst.w	crypt
	beq.s	no_crypt
	jsr	do_crypt
no_crypt:
	rts
save_sng:
	move.l	curr_nopatt,d0
	mulu	#512,d0
	add.l	#end_head-start_pattbuff,d0
	move.l	d0,size
	move.l	#start_pattbuff,load_addr
	jsr	test_crypt
	jsr	save_file(pc)
	jsr	test_crypt
	jsr	get_all_names
	rts
load_sng:
	jsr	get_size(pc)
	cmp.l	#-1,d0
	beq	no_load_sng
	move.l	dta+26,d0
	add.l	d0,d0
	add.l	#512,d0
	cmp.l	curr_mem_zize,d0
	bgt	nono4

	move.l	#8,size
	move.l	#start_pattbuff,load_addr
	jsr	load_file(pc)
	cmp.l	#-1,d0
	beq	no_load_sng
	cmp.l	#"AN C",start_pattbuff
	bne	error_format
	cmp.l	#"OOL.",start_pattbuff+4
	bne	error_format
	jsr	clear_all
	move.l	#12,size
	move.l	#start_pattbuff,load_addr
	jsr	load_file(pc)

	move.l	curr_nopatt,d0
	mulu	#512,d0
	add.l	#end_head-start_pattbuff,d0
	move.l	d0,size
	move.l	#start_pattbuff,load_addr
	jsr	load_file(pc)
	jsr	test_crypt
	lea	filename,a0
	lea	songname,a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.w	curr_bass,ruta3a
	rts
no_load_sng:
	lea	songname,a1
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	rts
save_mod:
	jsr	flyttdown
	move.l	curr_nopatt,d0
	mulu	#512,d0
	add.l	#end_head-start_pattbuff,d0
	move.l	d0,size
	move.l	#start_pattbuff,load_addr
	jsr	test_crypt
	jsr	save_first(pc)
	jsr	test_crypt
	cmp.l	#-1,d0
	beq	no_save_mod
	move.l	#start_buff,load_addr
	move.l	end_b_pek,size
	jsr	save_last(pc)
	jsr	fix_the_loop
	jsr	flyttupp
	jsr	setvolume
	jsr	get_all_names
no_save_mod:
	rts
load_mod:
	jsr	get_size(pc)
	cmp.l	#-1,d0
	beq	no_load_mod
	move.l	dta+26,d0
	add.l	d0,d0
	add.l	#512,d0
	cmp.l	curr_mem_zize,d0
	bgt	nono4

	move.l	#8,size
	move.l	#start_pattbuff,load_addr
	jsr	load_file(pc)
	cmp.l	#-1,d0
	beq	no_load_mod
	cmp.l	#"AN C",start_pattbuff
	bne	error_format
	cmp.l	#"OOL.",start_pattbuff+4
	bne	error_format

	jsr	clear_all

	move.l	#12,size
	move.l	#start_pattbuff,load_addr
	jsr	load_file(pc)
	move.l	curr_nopatt,d0
	mulu	#512,d0
	add.l	#end_head-start_pattbuff,d0
	move.l	d0,size
	move.l	#start_pattbuff,load_addr
	jsr	load_first(pc)
	jsr	test_crypt
	move.l	#4,size
	move.l	#start_buff,load_addr
	jsr	load_mid(pc)
	move.l	start_buff,size
	sub.l	#4,size
	move.l	#start_buff+4,load_addr
	jsr	load_last(pc)

	jsr	fix_the_loop
	jsr	flyttupp
	jsr	setvolume
	jsr	set_the_shit
	lea	filename,a0
	lea	songname,a1
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.w	curr_bass,ruta3a
	rts
no_load_mod:
	lea	songname,a1
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	rts
get_size:
	move.l	#1,medflag
	clr.w	-(sp)
	move.l	#filename,-(sp)
	move.w	#$4e,-(sp)
	trap	#1
	addq.l	#8,sp
	tst	d0
	bne	nono2
	rts
load_file:
	move.l	#1,medflag
	move.w	#2,-(sp)
	move.l	#filename,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	nono2
	move.w	d0,handle

	move.l	load_addr(pc),-(sp)
	move.l	size(pc),-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	nono2

	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	nono2
	rts
load_file2:
	move.l	#1,medflag
	move.w	#2,-(sp)
	move.l	#filename,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	nono5
	move.w	d0,handle

	move.l	load_addr(pc),-(sp)
	move.l	size(pc),-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	nono5

	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	nono5
	rts
save_file:
	move.l	#1,medflag
	clr.w	-(sp)
	move.l	#filename,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	nono2
	move.w	d0,handle

	move.l	load_addr(pc),-(sp)
	move.l	size(pc),-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	nono2
	cmp.l	size(pc),d0
	bne	save_not_equal
	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	nono2
	rts
save_first:
	move.l	#1,medflag
	clr.w	-(sp)
	move.l	#filename,-(sp)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	nono2
	move.w	d0,handle

	move.l	load_addr(pc),-(sp)
	move.l	size(pc),-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	nono2
	rts
save_last:

	move.l	load_addr(pc),-(sp)
	move.l	size(pc),-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	nono2
	cmp.l	size(pc),d0
	bne	save_not_equal
	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	nono2
	rts
load_first:
	move.l	#1,medflag
	move.w	#2,-(sp)
	move.l	#filename,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	nono2
	move.w	d0,handle

	move.l	load_addr(pc),-(sp)
	move.l	size(pc),-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	nono2
	rts
load_mid:
	move.l	load_addr(pc),-(sp)
	move.l	size(pc),-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	nono2
	rts
load_last:
	move.l	load_addr(pc),-(sp)
	move.l	size(pc),-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	nono2

	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	nono2
	rts
nono4:
	move.l	#-$27,d0
	bra	nono2
nono5:
	moveq	#-1,d0
	rts
detstora:
	dc.w	0
no_nono2:
	add.l	#4,sp
	rts
save_not_equal:
	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	bmi	nono2
	moveq	#-39,d0
nono2:
	cmp.w	#1,detstora
	beq	no_nono2
	move.w	#$700,$ff8240
	jsr	dir_restore
	lea	error_rutan,a0
	move.l	screen_start,a1
	add.l	#(160*65)+(8*8),a1
	moveq	#22,d1
error_loop:
	move.l	(a0)+,(a1)
  	clr.l	4(a1)
	move.l	(a0)+,8(a1)
	clr.l	4+8(a1)
	move.l	(a0)+,16(a1)
	clr.l	4+16(a1)
	move.l	(a0)+,24(a1)
	clr.l	4+24(a1)
	move.l	(a0)+,32(a1)
	clr.l	4+32(a1)
	lea	160(a1),a1
	dbra	d1,error_loop

	move.l	screen_start,a1
	add.l	#(160*78)+(8*10),a1
	move.w	d0,d1
	neg.w	d1
	jsr	print_hex
key_return_koll:
	cmp.b	#185,$fffc02
	bne	key_return_koll
	move.w	#$0,$ff8240
	moveq	#-1,d0
	rts
error_format:
	move.l	#"AN C",start_pattbuff
	move.l	#"OOL.",start_pattbuff+4
	move.l	#"TCBS",tcbsetup
	move.l	#"ETUP",tcbsetup+4
	move.w	#$700,$ff8240

	lea	file_format,a0
	move.l	screen_start,a1
	add.l	#(160*65)+(8*8),a1
	moveq	#20,d1
format_loop:
	move.l	(a0)+,(a1)
  	clr.l	4(a1)
	move.l	(a0)+,8(a1)
	clr.l	4+8(a1)
	move.l	(a0)+,16(a1)
	clr.l	4+16(a1)
	move.l	(a0)+,24(a1)
	clr.l	4+24(a1)
	move.l	(a0)+,32(a1)
	clr.l	4+32(a1)
	move.l	(a0)+,40(a1)
	clr.l	4+40(a1)
	lea	160(a1),a1
	dbra	d1,format_loop
key_urrk:
	cmp.b	#185,$fffc02
	bne	key_urrk
	move.w	#$0,$ff8240
	rts
filename:
	dc.b	"12345678.123",0
	even
extnam:
	dc.b	"*"
currext:
	dc.b	"    ",0
	even
handle:
	dc.w	0
load_addr:
	dc.l	0
size:
	dc.l	0
fixx_buff:
	add.l	#over_buff,d0			; addera till loop buff
	lea	samp_pet_buff,a0	; lÑs
	lsl.l	#3,d1			; mulu #8,d1
	move.l	(a0,d1.w),a1		; hÑmta samp pekare
	add.l	#start_buff,a1
	move.l	a1,load_addr		; hÑmta samp pekare till loader
	move.l	4(a0,d1.w),d2		; och storlek
	move.l	d0,4(a0,d1.w)		; flytta ny storlek
	sub.l	d0,d2			; delta storlek
	bmi.s	move_upp		; utvidga buffern
	move.l	8(a0,d1.w),a2		; flytta fîrsta nÑsta samplingen till a2
	add.l	#start_buff,a2
subtract_loop:
	addq.l	#8,d1			; 'scrolla' i tabellen
	move.l	(a0,d1.w),d3		; flytta sam pekare till d3
	cmp.l	#-1,d3			; tabell slut?
	beq.s	exit_loop		; jarru, hoppa ur lopen
	sub.l	d2,d3			; subba med delta storlek+400
	move.l	d3,(a0,d1.w)		; tillbaks
	bra.s	subtract_loop		; -"-
exit_loop:
	move.l	a2,a1
	sub.l	d2,a1
	move.l	end_b_pek,a3		; end mem pek
	add.l	#start_buff,a3
	sub.l	d2,end_b_pek		; subtrahera delta storlek med end mem
move_loop:			
	move.b	(a2)+,(a1)+		; flytta 
	cmp.l	a3,a2			; end mem 
	ble	move_loop		; nja?
	rts
move_upp:
	neg.l	d2			; om du inte fattar detta.......
subtract_loop2:
	addq.l	#8,d1			; 'scrolla' i tabellen
	move.l	(a0,d1.w),d3		; flytta sam pekare till d3
	cmp.l	#-1,d3			; tabell slut?
	beq.s	exit_loop2		; jarru, hoppa ur lopen
	add.l	d2,d3			; adda med delta storlek+400
	move.l	d3,(a0,d1.w)		; tillbaks
	bra.s	subtract_loop2		; -"-
exit_loop2:
	move.l	end_b_pek,a3		; end mem pek
	add.l	#start_buff,a3
	add.l	d2,end_b_pek		; subtrahera delta storlek med end mem
	move.l	end_b_pek,a2		; end mem pek
	add.l	#start_buff,a2
move_loop2:			
	move.b	-(a3),-(a2)		; flytta 
	cmp.l	a1,a3			; end mem 
	bge	move_loop2		; nja?
	rts
init_digishit:
	jsr	conv_imp
	jsr	makespeedtabs
	jsr	intsamp
	rts
print_sizze:
	move.l	end_b_pek,d0
	add.l	end_b_pek,d0
	sub.l	#end_head2-start_buff,d0

	add.l	#start_buff,d0
	move.l	end_mem(pc),d1
	sub.l	d0,d1
	add.l	#512,d1
	move.l	d1,curr_mem_zize
	move.l	#160*88,samypos
	move.b	#4,samxpos
	jsr	yes_strul
	rts
curr_mem_zize:
	dc.l	0
samypos:
	dc.l	0
yes_strul:
	divu	#1024,d1
	swap	d1
	clr.w	d1
	swap	d1
	move.l	d1,d2
	moveq	#-1,d4
	lea	num_buff,a0
	move.b	#-16,(a0)
	move.b	#-16,1(a0)
	move.b	#-16,2(a0)
make_num:
	move.l	d2,d3
	divu	#10000,d3
	mulu	#10000,d3
	sub.l	d3,d2
	move.l	d2,d3
	divu	#1000,d3
	tst.b	d3
	beq	yo_null
	move.b	d3,(a0)
	move.w	#0,d4
yo_null:
	add.b	#48,(a0)+

	move.l	d2,d3
	divu	#1000,d3
	mulu	#1000,d3
	sub.l	d3,d2
	move.l	d2,d3
	divu	#100,d3
	tst.w	d4
	beq	xyo_null
	tst.b	d3
	beq	yo_null2
xyo_null:
	move.b	d3,(a0)
	move.w	#0,d4
yo_null2:
	add.b	#48,(a0)+

	move.l	d2,d3
	divu	#100,d3
	mulu	#100,d3
	sub.l	d3,d2
	move.l	d2,d3
	divu	#10,d3
	tst.w	d4
	beq	xyo_null2
	tst.b	d3
	beq	yo_null3
xyo_null2:
	move.b	d3,(a0)
yo_null3:
	add.b	#48,(a0)+

	move.l	d2,d3
	divu	#10,d3
	mulu	#10,d3
	sub.l	d3,d2
	move.l	d2,d3
	divu	#1,d3
	move.b	d3,(a0)
	add.b	#48,(a0)+

	lea	num_buff,a0
	move.l	screen_start,d1
	add.l	samypos,d1
	moveq	#4,d0
print_samn2:
	moveq	#0,d2
	move.b	samxpos,d2
	move.l	d2,d3
	and.w	#1,d2
	lsr.w	#1,d3
	lsl.w	#3,d3
	add.l	d3,d2
	add.l	d1,d2
	moveq	#0,d3
	move.b	(a0)+,d3
	mulu	#8,d3
	lea	comfont,a1
	add.w	d3,a1
	move.l	a0,-(sp)
	move.l	d2,a0
	move.b	(a1)+,160*0(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	move.l	(sp)+,a0
	addq.b	#1,samxpos
	dbra	d0,print_samn2
	rts
num_buff:
	dc.b	0,0,0,0,"K"
	even
end_mem:
	dc.l	0
calc_song:
	lea	patt_tab,a0
	move.w	#$7f,d0
	moveq	#0,d1
an_loop:
	moveq	#0,d2
	move.b	(a0)+,d2
	cmp.b	d1,d2
	ble	no_new_val
	move.b	d2,d1
no_new_val:
	dbra	d0,an_loop

	add.l	#1,d1
	move.l	d1,curr_nopatt
	mulu	#512,d1
	add.l	end_b_pek,d1
	add.l	#512,d1
	move.l	#160*97,samypos
	move.b	#4,samxpos
	jsr	yes_strul
	rts
orse_flag:
	dc.w	0
no_shot:
	rts
put_shit:
	cmp.w	#1,orse_flag
	beq	no_shot
	cmp.w	#1,ors_flag
	beq	put_shit2

	moveq	#0,d2
	moveq	#0,d3

	moveq	#2,d5
	moveq	#3,d1
	lea	freaky_brother,a1

	move.w	(a1)+,d2
	lsr.w	d1,d2
	move.w	no_dott,d0
shitty:
	moveq	#0,d3
	moveq	#0,d4
	move.w	(a1)+,d3
	lsr.w	d1,d3
	sub.b	d3,d2
	move.b	d2,d3
	move.w	(a1)+,d2
	lsr.w	d1,d2
	move.b	d2,d4
	lsr.b	d5,d4
	add.b	d3,d3
	add.b	d3,d3
	add.b	d4,d4
	add.b	d4,d4
	lea	ytab2(pc),a0
	move.l	(a0,d4.w),a0
	move.l	xtab2(pc,d3.w),d3
	add.w	d3,a0
	swap	d3
	or	d3,(a0)
	dbra	d0,shitty
	rts
put_shit2:

	moveq	#0,d2
	moveq	#0,d3

	moveq	#2,d5
	lea	$fb0001,a1

	move.b	(a1),d2
	move.l	#90,d0
shitty2:
	moveq	#0,d3
	moveq	#0,d4
	move.b	(a1),d3
	sub.b	d3,d2
	move.b	d2,d3
	move.b	(a1),d2
	move.b	d2,d4
	lsr.b	d5,d4
	add.b	d3,d3
	add.b	d3,d3
	add.b	d4,d4
	add.b	d4,d4
	lea	ytab,a0
	add.l	#33*4,d4
	move.l	(a0,d4.w),a0
	move.l	xtab2(pc,d3.w),d3
	add.w	d3,a0
	swap	d3
	or	d3,(a0)
	dbra	d0,shitty2
	rts
xtab2:
	ds.l	320
ytab2:
	ds.l	200	

ors_flag:
	dc.w	0
rem_glob:	
	moveq	#0,d1
	move.l	screen_start,a0
	add.l	#(8*7)+(33*160),a0
	moveq	#63,d0
loopq:
	move.w	d1,(a0)
	move.w	d1,8(a0)
	move.w	d1,16(a0)
	move.w	d1,24(a0)
	lea	160(a0),a0
	dbra	d0,loopq
	rts
flyttdown:
	lea	start_buff,a0
	add.l	#end_head2-start_buff,a0

	lea	start_buff,a1
	add.l	end_b_pek,a1

	move.l	end_b_pek,d0
	sub.l	#end_head2-start_buff,d0
	sub.l	#1,d0
flyttdownloop:
	move.b	(a1)+,(a0)+
	subq.l	#1,d0
	bpl	flyttdownloop
	rts
flyttupp:
	lea	start_buff,a0
	add.l	#end_head2-start_buff,a0

	lea	start_buff,a1
	add.l	end_b_pek,a1

	move.l	end_b_pek,d0
	sub.l	#end_head2-start_buff,d0
	sub.l	#1,d0
flyttupploop:
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bpl	flyttupploop
	rts
setvolume:
	moveq	#15,d2
gnurfh:
	move.l	d2,d3
	lsl.l	#3,d3
	lea	samp_pet_buff,a1
	move.l	(a1,d3.w),a0
	add.l	#start_buff,a0
	move.l	a0,d4
	add.l	4(a1,d3.w),d4
	lea	samtab,a1
	move.l	d2,d3
	lsl.l	#2,d3
	moveq	#0,d0
	move.b	(a1,d3.w),d0
	move.l	d4,a1
	jsr	vol_vol	
	dbra	d2,gnurfh
	rts
	
*	d0=vol
*	a0=start
*	a1=end
vol_vol:
	moveq	#0,d3
	move.b	d0,d3
	not.b	d3
	and.b	#%01111111,d3
vol_loop:
	moveq	#0,d1	
	move.b	(a0),d1		
	mulu	d0,d1	
	asr.w	#7,d1
	add.b	d3,d1	
	move.b	d1,(a0)+
	cmp.l	a1,a0
	bne	vol_loop
no_def_lamer:
	rts
setcurrvol:
	moveq	#0,d0
	move.b	currsam(pc),d0	
	lsl.l	#2,d0
	lea	samtab,a0
	add.l	d0,a0
	move.b	currvol,(a0)

	moveq	#0,d0
	move.b	currsam,d0
	lsl.w	#3,d0
	lea	samp_pet_buff,a1
	move.l	(a1,d0.w),d2
	move.l	4(a1,d0.w),d4
	subq.l	#1,d4
	cmp.l	#0,d4
	beq	no_def_lamer
	move.l	d2,d3

	add.l	#start_buff,d2
	add.l	end_b_pek,d2
	sub.l	#end_head2-start_buff,d2
	add.l	#start_buff,d3

	move.l	d2,a0
	move.l	d3,a1
move_sam:
	move.b	(a0)+,(a1)+
	sub.l	#1,d4
	bpl	move_sam

	moveq	#0,d2
	move.b	currsam,d2
	move.l	d2,d3
	lsl.l	#3,d3
	lea	samp_pet_buff,a1
	move.l	(a1,d3.w),a0
	add.l	#start_buff,a0
	move.l	a0,d4
	add.l	4(a1,d3.w),d4
	lea	samtab,a1
	move.l	d2,d3
	lsl.l	#2,d3
	moveq	#0,d0
	move.b	(a1,d3.w),d0
	move.l	d4,a1
	jsr	vol_vol	
	rts
clear_all:
	lea	start_pattbuff,a0
	move.l	#start_buff-start_pattbuff,d0
	sub.l	#1,d0
clear_all_loop:
	clr.b	(a0)+
	subq.l	#1,d0
	bpl	clear_all_loop
	rts
set_the_shit:
	clr.b	currposs
	move.b	patt_tab,currpatt
	clr.b	currsam
	move.b	samtab,currvol
	move.w	samtab+2,currloop
	rts
fix_the_loop:
	moveq	#15,d7
fix_lopar:
	jsr	fast_eddie
	dbra	d7,fix_lopar
	rts
fast_eddie:
	moveq	#0,d1
	move.b	d7,d1
	lsl.w	#3,d1
	lea	samp_pet_buff,a0
	move.l	(a0,d1.w),a1
	add.l	4(a0,d1.w),a1
	sub.l	#over_buff,a1
	cmp.l	#-1,a1
	ble	no_make_loop
	add.l	#start_buff,a1
	move.l	a1,a0

	moveq	#0,d0
	moveq	#0,d1
	move.b	d7,d0	
	lsl.l	#2,d0
	lea	samtab,a1
	move.w	2(a1,d0.w),d1
	
	cmp.w	#0,d1
	beq	clear_samloop2

	move.l	a0,a1
	sub.l	d1,a1
	move.w	#over_buff-1,d0
make_loop3:
	move.b	(a1)+,(a0)+
	dbra	d0,make_loop3
no_make_loop:				* IF SAMPLING
	rts				* IS UNDER (OVER_BUFF)
clear_samloop2:
	move.w	#over_buff-1,d0
make_loop4:
	move.b	#$7f,(a0)+
	dbra	d0,make_loop4
	rts
print_currname:
	move.b	#9,samxpos
	lea	samnames,a0
	moveq	#0,d0
	move.b	currsam,d0
	lsl.w	#3,d0
	add.l	d0,a0
	move.l	screen_start,d1
	add.l	#(160*116),d1
	moveq	#7,d0
print_samn:
	moveq	#0,d2
	move.b	samxpos,d2
	move.l	d2,d3
	and.w	#1,d2
	lsr.w	#1,d3
	lsl.w	#3,d3
	add.l	d3,d2
	add.l	d1,d2
	moveq	#0,d3
	move.b	(a0)+,d3
	cmp.b	#".",d3
	beq	no_more_p
	mulu	#8,d3
	lea	comfont,a1
	add.w	d3,a1
	move.l	a0,-(sp)

	move.l	d2,a0
	move.b	(a1)+,160*0(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	move.l	(sp)+,a0
	addq.b	#1,samxpos
	dbra	d0,print_samn
	rts
no_more_p:
	moveq	#0,d2
	move.b	samxpos,d2
	move.l	d2,d3
	and.w	#1,d2
	lsr.w	#1,d3
	lsl.w	#3,d3
	add.l	d3,d2
	add.l	d1,d2
	move.l	d2,a0
	clr.b	160*0(a0)
	clr.b	160*1(a0)
	clr.b	160*2(a0)
	clr.b	160*3(a0)
	clr.b	160*4(a0)
	clr.b	160*5(a0)
	clr.b	160*6(a0)
	addq.b	#1,samxpos
	dbra	d0,no_more_p
	rts
print_currsongname:
	move.b	#9,samxpos
	lea	songname,a0
	move.l	screen_start,d1
	add.l	#(160*107),d1
	moveq	#7,d0
print_songn:
	moveq	#0,d2
	move.b	samxpos,d2
	move.l	d2,d3
	and.w	#1,d2
	lsr.w	#1,d3
	lsl.w	#3,d3
	add.l	d3,d2
	add.l	d1,d2
	moveq	#0,d3
	move.b	(a0)+,d3
	cmp.b	#".",d3
	beq	no_more_p2
	cmp.b	#0,d3
	beq	no_more_p2
	mulu	#8,d3
	lea	comfont,a1
	add.w	d3,a1
	move.l	a0,-(sp)

	move.l	d2,a0
	move.b	(a1)+,160*0(a0)
	move.b	(a1)+,160*1(a0)
	move.b	(a1)+,160*2(a0)
	move.b	(a1)+,160*3(a0)
	move.b	(a1)+,160*4(a0)
	move.b	(a1)+,160*5(a0)
	move.b	(a1)+,160*6(a0)
	move.l	(sp)+,a0
	addq.b	#1,samxpos
	dbra	d0,print_songn
	rts
no_more_p2:
	moveq	#0,d2
	move.b	samxpos,d2
	move.l	d2,d3
	and.w	#1,d2
	lsr.w	#1,d3
	lsl.w	#3,d3
	add.l	d3,d2
	add.l	d1,d2
	move.l	d2,a0
	clr.b	160*0(a0)
	clr.b	160*1(a0)
	clr.b	160*2(a0)
	clr.b	160*3(a0)
	clr.b	160*4(a0)
	clr.b	160*5(a0)
	clr.b	160*6(a0)
	addq.b	#1,samxpos
	dbra	d0,no_more_p2
	rts
songname:
	dc.b	"        "
samxpos:
	dc.w	0
gurgelmuffe:
	dc.l	0
once:
	lea	setsam_dat,a0
	move.w	#3,d0
mwwrite:
	move.w	#$7ff,$ff8924
mwwrite2:
	cmp.w	#$07ff,$ff8924
	bne.s	mwwrite2
	move.w	(a0)+,$ff8922
	dbra	d0,mwwrite
	move.w	#1,gurgelmuffe
start_ste:
	move.w	#1,ruta4a
	move.w	#0,ruta4b

	cmp.w	#0,gurgelmuffe
	beq	once
	move.l	#starte,temp
	move.b	temp+1,$ff8903
	move.b	temp+2,$ff8905
	move.b	temp+3,$ff8907

	move.l	#ende,temp
	move.b	temp+1,$ff890f
	move.b	temp+2,$ff8911
	move.b	temp+3,$ff8913

	move.w	#%0000000000000001,$ff8920

	move.w	#3,$ff8900
	move.l	#samp1ste,$134
	move.l	#samp1ste,currir
	clr.w	vec11e+2
	clr.w	vec12e+2
	clr.w	vec13e+2
	move.l	#vec11e,chann1
	move.l	#vec12e,chann2
	move.l	#vec13e,chann3
	move.l	#1,mod_flg
	jsr	fix_select
	rts
once2:
	lea	setsam_dat,a0
	move.w	#3,d0
mwwrite3:
	move.w	#$7ff,$ff8924
mwwrite4:
	cmp.w	#$07ff,$ff8924
	bne.s	mwwrite4
	move.w	(a0)+,$ff8922
	dbra	d0,mwwrite3
	move.w	#1,gurgelmuffe
start_ste2:
	move.w	#0,ruta4a
	move.w	#1,ruta4b
	cmp.w	#0,gurgelmuffe
	beq	once2
	move.l	#starte,temp
	move.b	temp+1,$ff8903
	move.b	temp+2,$ff8905
	move.b	temp+3,$ff8907

	move.l	#ende,temp
	move.b	temp+1,$ff890f
	move.b	temp+2,$ff8911
	move.b	temp+3,$ff8913

	move.w	#%0000000000000001,$ff8920

	move.w	#3,$ff8900
	move.l	#samp1ste2,$134
	move.l	#samp1ste2,currir
	clr.w	vec11e2+2
	clr.w	vec12e2+2
	clr.w	vec13e2+2
	move.l	#vec11e2,chann1
	move.l	#vec12e2,chann2
	move.l	#vec13e2,chann3
	move.l	#2,mod_flg
	jsr	fix_select
	rts
currir:
	dc.l	samp1
mod_flg:
	dc.l	0
temp:
	dc.l	0
setsam_dat:
	dc.w	%0000000011010100  ;mastervol
	dc.w	%0000010010000110  ;terble
	dc.w	%0000010001000110  ;bass
	dc.w	%0000000000000001  ;mixer
	dc.w	$0
	dc.w	$0
starte:
left:	dc.b	0
right:	dc.b	0
ende:
	dc.w	$ffff
init_reset:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,resolution

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,phys_base

	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,log_base

	lea	$fffa01,a0
	lea	save_mfp,a1
	moveq	#15,d0
save_mfp_loop:
	move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,save_mfp_loop

	lea	$28,a0
	lea	save_tex,a1
	move.l	#$200-1,d0
save_tex_loop:
	move.l	(a0)+,(a1)+
	dbra	d0,save_tex_loop

	move.l	#retvars,$42a
	move.l	#$31415926,$426
	rts
retvars:
	lea	nullstk,a7

	move.w	#$700,$ff8240

	lea	$28,a0
	lea	save_tex,a1
	move.l	#$200-1,d0
ret_tex_loop:
	move.l	(a1)+,(a0)+
	dbra	d0,ret_tex_loop

	move.w	#$030,$ff8240

	lea	$fffa01,a0
	lea	save_mfp,a1
	moveq	#15,d0
ret_mfp:
	move.b	(a1)+,(a0)
	addq.l	#2,a0
	dbra	d0,ret_mfp
	move.w	#$770,$ff8240

	move.l	#retvars,$42a
	move.l	#$31415926,$426

	move.w	#$070,$ff8240
	move.b	#2,$ff820a
	move.w	#$007,$ff8240

	move.w	#$770,$ff8240

	move.w	resolution,-(sp)
	move.l	phys_base,-(sp)
	move.l	log_base,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#$707,$ff8240

	move.l	#$707ffff,$ffff8800.w

	move.w	#$777,$ff8240

	dc.w	$a000

	move.w	#$444,$ff8240

	move.w	#1,d0
	andi.w	#3,d0
	lea	skumtab,a1
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a1,d0.w),(a0)
	move.b	#3,$fffffc04.w
	move.b	#$95,$fffffc04.w
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w
	move.w	#$c8,d0
tima	nop
	dbra	d0,tima

	move.w	#$000,$ff8240
	move.w	#$666,$ff8242
	move.w	#$666,$ff8244
	move.w	#$666,$ff8246
	move.w	#$666,$ff8248

	move.w	#$777,$ff8240
	move.w	#$2300,sr
	move.w	#$000,$ff8240
	move.w	#$666,$ff8242
	move.w	#$666,$ff8244
	move.w	#$666,$ff8246
	move.w	#$666,$ff8248

	move.l	save_med,$47e
	move.l	save_gem,$404

	move.w	#0,$ff8900

	clr.w	-(sp)
	trap	#1
save_stk:
	dc.l	0

skumtab:
	dc.w	$0004,$00a0
	dc.w	$0002,$00a0
	dc.w	$0001,$0050
	dc.w	$0001,$0050
	dc.w	$8001,$1214

save_mfp:
	ds.b	24
	even
resolution:
	dc.w	0
phys_base:
	dc.l	0
log_base:
	dc.l	0
save_tex:
	ds.l	$300
	ds.l	100
nullstk:
worm_flg:
	dc.w	0
worm:
	cmp.w	#1,worm_flg
	bne	no_worm
	jsr	wipe
	cmp.w	#0,wormmod_flg
	beq	int_worm
	move.l	screen_start,a0
	addq.l	#4,a0
	lea	yoyo_tab,a1
	moveq	#19,d1

	moveq	#0,d0
	move.b	$fb0001,d0
	lsr.w	#1,d0
	addq.w	#1,d0
	mulu	#160,d0
	add.l	a0,d0
	move.l	a0,-(sp)
	move.l	d0,a0
	clr.w	(a0)
	clr.w	160(a0)
	clr.w	160*2(a0)
	clr.w	160*3(a0)
	clr.w	160*4(a0)
	clr.w	160*5(a0)
	clr.w	160*6(a0)
	clr.w	160*7(a0)
	move.l	(sp)+,a0

worm_loop:
	moveq	#0,d0
	move.b	$fb0001,d0
	lsr.w	#1,d0
	addq.w	#1,d0
	mulu	#160,d0
	add.l	a0,d0
	move.l	a0,-(sp)
	move.l	d0,a0
	move.l	a0,(a1)+
	not.w	(a0)
	not.w	160(a0)
	not.w	160*2(a0)
	not.w	160*3(a0)
	not.w	160*4(a0)
	not.w	160*5(a0)
	not.w	160*6(a0)
	not.w	160*7(a0)
	move.l	(sp)+,a0
	addq.l	#8,a0
	dbra	d1,worm_loop
no_worm:
	rts
int_worm:
	move.l	screen_start,a0
	addq.l	#4,a0
	lea	yoyo_tab,a1
	moveq	#19,d1
	moveq	#0,d2
worm_loop2:
	moveq	#0,d0
	move.l	a1,-(sp)
	lea	freaky_brother,a1
	move.w	(a1,d2.w),d0
	move.l	(sp)+,a1
	lsr.w	#6,d0
	and.w	#$00ff,d0
	mulu	#160,d0
	add.l	a0,d0
	move.l	a0,-(sp)
	move.l	d0,a0
	move.l	a0,(a1)+
	not.w	(a0)
	not.w	160(a0)
	not.w	160*2(a0)
	not.w	160*3(a0)
	not.w	160*4(a0)
	not.w	160*5(a0)
	not.w	160*6(a0)
	not.w	160*7(a0)
	move.l	(sp)+,a0
	addq.l	#8,a0
	addq.w	#6,d2
	dbra	d1,worm_loop2
	rts
yoyo_tab:
	ds.l	20
wipe:
	lea	yoyo_tab,a1
	cmp.l	#0,(a1)
	beq	no_wipe
	move.w	#19,d0
	moveq	#0,d1
wipe_loop:
	move.l	(a1)+,a0
	move.w	d1,160*0(a0)
	move.w	d1,160*1(a0)
	move.w	d1,160*2(a0)
	move.w	d1,160*3(a0)
	move.w	d1,160*4(a0)
	move.w	d1,160*5(a0)
	move.w	d1,160*6(a0)
	move.w	d1,160*7(a0)
	dbra	d0,wipe_loop
no_wipe:
	rts
med:
	move.l	medflag,d0
	clr.l	medflag
	rts
medflag:
	dc.l	0
save_med:
	dc.l	0
save_gem:
	dc.l	0
gemare:
	rts
ms_colors:
	eor.w	#1,color_flag
	rts
color_flag:
	dc.w	0
ste_flag:
	dc.w	0
save_regs:
	ds.l	16
high_text:
	dc.b	$d,$a
	dc.b	"    This application does not     ",$d,$a
	dc.b	"    support monochrome monitor.   ",$d,$a
	dc.b	"    Please use color monitor      ",$d,$a
	dc.b	"                                  ",$d,$a
	dc.b	"          Any key to exit         ",$d,$a
	dc.b	"                                  ",$d,$a,0
	even
main:
	movem.l	d0-d7/a0-a7,save_regs
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	cmp.w	#2,d0
	bne	not_high
	pea	high_text
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	clr.w	-(sp)
	trap	#1
not_high:
	move.w	d0,save_res
	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ssave_stk

	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,save_pal
	clr.w	-(sp)
	pea	-1
	pea	-1
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.b	#2,$ff820a
	dc.w	$a00a
	bclr	#0,$484
	move.b	$484,save_cont
	cmp.w	#$00fc,$4.w
	beq.s	no_ste
	move.w	#1,ste_flag
no_ste:
	move.l	$47e,save_med
	move.l	#med,$47e
	move.l	$404,save_gem
	move.l	#gemare,$404

	move.l	$42e,screen_start
	sub.l	#32000,screen_start
	move.l	$42e,end_mem
	sub.l	#32000,end_mem

	clr.w	-(sp)
	move.l	screen_start,-(sp)
	move.l	screen_start,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	jsr	make_drive_tab

	movem.l	pal,d0-d7
	movem.l	d0-d7,$ff8240

	lea	curs_pos,a0
	moveq	#8,d0
	move.l	screen_start,d1
curs_fix:
	add.l	d1,(a0)+
	dbra	d0,curs_fix

;	jsr	init_reset	*only when coding
	jsr	init_dta
	jsr	makeytab
	jsr	makextab2
	jsr	shift_mouse
	jsr	shift_drift
	move.w	#1,detstora
	jsr	load_set	*only finished v.
	move.w	#0,detstora
	jsr	copy_pic
	jsr	init_screen

	lea	imptab,a1
	lea	imptab3,a0
	move.w	#511,d0
imptab_loop2:
	move.l	(a0)+,(a1)+
	dbra	d0,imptab_loop2

	bsr	init_digishit

	jsr	save_ints
	jsr	init_ints

	move.l	#emptysamp,a6
	move.l	#emptysamp,a5
	move.l	#emptysamp,a4
	move.l	#emptysamp,a3
	move.l	#speedtabs,a2

	clr.w	wfnc
demo_loop:
	cmp.w	#1,wfnc
	bne	demo_loop
	clr.w	wfnc
	move.w	#$0,$ff8240
	cmp.w	#1,file_allert
	beq	no_shit
	jsr	put_shit
no_shit:
	jsr	print_score
	jsr	cursor
	jsr	nottare
********************************
	cmp.w	#1,file_allert
	beq	no_rem
	cmp.w	#1,orse_flag
	beq	no_rem
	jsr	rem_glob
	bra	no_wait
no_rem:
	move.w	#1200,d0
dummy_loop:
	dbra	d0,dummy_loop
no_wait:
	cmp.w	#0,color_flag
	beq	nocol1
	move.w	#$700,$ff8240
nocol1:
	move.w	delay1,d0
wait_loop1:
	nop
	dbra	d0,wait_loop1

	jsr	restor_back
	jsr	kolla_midi
	jsr	chk_keys
 	jsr	mouse_event
	jsr	proc_mouse
	jsr	worm
********************************
	cmp.w	#0,color_flag
	beq	nocol2
	move.w	#$707,$ff8240
nocol2:
	jsr	proc_hex

	cmp.w	#0,color_flag
	beq	nocol3
	move.w	#$777,$ff8240
nocol3:
	cmp.w	#1,exit_flg
	bne	demo_loop
	cmp.w	#1,ste_flag
	bne	no_not_dis
	move.w	#0,$ff8900
no_not_dis:
	movem.l	save_pal,d0-d7
	movem.l	d0-d7,$ff8240
	move.l	save_med,$47e
	move.l	save_gem,$404
	move.b	save_cont(pc),$484
	jsr	ret_ints
	dc.w	$a009
	move.w	save_res,-(sp)
	move.l	$44e,-(sp)
	move.l	$44e,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

flush:
	btst.b	#0,$fffffc00.w
	beq.s	flush_done
	move.b	$fffffc02.w,d0
	bra.s	flush
flush_done:

	move.l	ssave_stk,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	save_regs,d0-d7/a0-a7
	clr.w	(sp)
	trap	#1
save_cont:
	dc.w	0
ssave_stk:
	dc.l	0
save_res:
	dc.l	0
yes_ste_mod:
	move.l	#freaky_brother,no_areg2+2
	bra	back_to_normal
yes_ste_mod2:
	move.l	#freaky_brother,no_areg3+2
	bra	back_to_normal
vbi:
	cmp.l	#1,mod_flg
	beq	yes_ste_mod
	cmp.l	#2,mod_flg
	beq	yes_ste_mod2
	move.l	#freaky_brother,no_areg+2
back_to_normal:
	move.w	#1,wfnc
	movem.l	d0-d5/a0-a1,-(sp)
	cmp.w	#1,midi_flag
	beq	no_internal
	jsr	play_musaxx
no_internal:
	jsr	forbdv
	movem.l	(sp)+,d0-d5/a0-a1
	rte
an_buf:
	dc.w	0
wfnc:
	dc.w	0
ikbd:	
	movem.l	d0-d1/a0-a1,-(a7)
ikbd2:
	btst	#0,$fffffc00.w
	beq	acia_midi
	
	move.b	$fffffc02.w,d0
	tst.w	mcnt
	beq.s	acia_key
	subq.w	#1,mcnt
	move.w	mcnt,d1
	lea	mausmsg,a0
	cmp.w	#2,d1
	beq	acia_nadd
	add.b	d0,(a0,d1.w)
	bra	acia_end
acia_nadd:
	move.b	d0,(a0,d1.w)
	bra	acia_end
acia_key:
	move.b	d0,d1
	and.w	#$f8,d1
	cmp.b	#$f8,d1
	bne	acia_noms
	move.w	#2,mcnt
	move.b	d0,mbutton
	and.b	#$3,mbutton
acia_noms:
	move.b	d0,save_key
acia_end:
	btst	#4,$fffa01
	beq	ikbd2
	movem.l	(a7)+,d0-d1/a0-a1
	move.w	#0,midi_buf
	rte

acia_midi
	btst	#0,$fffffc04.w
	beq	lf6c24
	move.b	$fffffc06.w,d0
	move.b	d0,d1
	andi.w	#$80,d1
	beq	lf6bba
	clr.w	ikbdvar13
	move.b	d0,midi_buf
	addq.w	#1,ikbdvar13
	andi.w	#3,ikbdvar13
	bra	lf6c24
lf6bba	lea	midi_buf,a0
	adda.w	ikbdvar13,a0
	addq.w	#1,ikbdvar13
	andi.w	#3,ikbdvar13
	move.b	d0,(a0)
	move.b	midi_buf,d1
	andi.w	#$f0,d1
	cmp.b	#$90,d1
	bne	lf6c12
	cmpi.w	#3,ikbdvar13
	bne	lf6c12
	tst.b	ikbdvar16
	beq	lf6c12
	move.b	ikbdvar15,ikbdvar19
	move.b	ikbdvar16,ikbdvar17
lf6c12	cmp.b	#$c0,d1
	bne	lf6c24
	move.b	ikbdvar15,ikbdvar18
lf6c24:
	btst	#4,$fffa01
	beq	ikbd2
	move.l	rre,a0
	move.l	midi_buf,(a0)+
	move.l	a0,rre
	jsr	fix_last_midi
	cmp.w	#1,midi_flag
	bne.s	nu_Ñr_det_inte_time
	jsr	nu_Ñr_det_time
nu_Ñr_det_inte_time:
	movem.l	(a7)+,d0-d1/a0-a1
	rte
rre:
	dc.l	$300000
nu_Ñr_det_time:
	cmp.b	#$fa,midi_buf
	beq	xms_play
	cmp.b	#$fb,midi_buf
	beq	xms_play
	cmp.b	#$fc,midi_buf
	beq	xms_stop
	cmp.b	#$f8,midi_buf
	bne	no_midi_clk
	addq.w	#1,step
	cmp.w	#5,step
	ble	no_midi_clk
	clr.w	step
	movem.l	d0-d5/a0-a1,-(sp)
	jsr	play_musaxx	
	movem.l	(sp)+,d0-d5/a0-a1
no_midi_clk:
	clr.l	midi_buf
	rts
xms_play:
	movem.l	d0-d5/a0-a1,-(sp)
	jsr	ms_play
	movem.l	(sp)+,d0-d5/a0-a1
	rts
xms_stop:
	movem.l	d0-d5/a0-a1,-(sp)
	jsr	ms_stop
	movem.l	(sp)+,d0-d5/a0-a1
	rts
step:
	dc.w	0
fix_last_midi:
	move.w	midi_buf(pc),d0
	cmp.w	old_midi(pc),d0
	beq.s	no_miidi
	cmp.b	#$8f,midi_buf
	beq.s	clear_midi
	cmp.b	#$0,midi_buf+2
	beq.s	clear_midi
	cmp.b	#$9f,midi_buf
	beq.s	new_key
no_miidi:
	rts
clear_midi:
	clr.w	old_midi
	rts
new_key:
	move.w	d0,old_midi
	move.w	#1,old_midi_allert
	rts
ikbdvar13:
	dc.w	0
ikbdvar15:
	dc.b	0
ikbdvar16:
	dc.b	0
ikbdvar17:
	dc.b	0
ikbdvar18:
	dc.b	0
ikbdvar19:
	dc.b	0
	even
midi_buf:
	dc.l	0
ms_big_fool:
	rts
screen_start:
	dc.l	0
select_postab:
	dc.w	$ce,$3e,$e9,$48
	dc.l	ms_select_yes
	dc.w	$f3,$3e,$106,$48
	dc.l	ms_select_no
	dc.w	$9f,$28,$10e,$4a
	dc.l	ms_big_fool
	dc.w	-1
file_postab:
	dc.w	$d3,$25,$de,$2f
	dc.l	ms_file_upp
	dc.w	$d3,$64,$de,$6f
	dc.l	ms_file_down

	dc.w	$50,$26,$d1,$2d
	dc.l	ms_file_1
	dc.w	$50,$2e,$d1,$35
	dc.l	ms_file_2
	dc.w	$50,$36,$d1,$3d
	dc.l	ms_file_3
	dc.w	$50,$3e,$d1,$45
	dc.l	ms_file_4
	dc.w	$50,$46,$d1,$4d
	dc.l	ms_file_5
	dc.w	$50,$4e,$d1,$55
	dc.l	ms_file_6
	dc.w	$50,$56,$d1,$5d
	dc.l	ms_file_7
	dc.w	$50,$5e,$d1,$65
	dc.l	ms_file_8
	dc.w	$50,$66,$d1,$6d
	dc.l	ms_file_9
	dc.w	$48,$74,$86,$75
	dc.l	ms_tryck_sam

	dc.w	$d3,$30,$de,$63
	dc.l	ms_file_exit
	dc.w	$4f,$1a,$de,$24
	dc.l	ms_edit_name
	dc.w	$4f,$f,$5a,$19
	dc.l	ms_exit_dir
	dc.w	$4f,$f,$de,$6f
	dc.l	ms_big_fool
	dc.w	-1
postab:
	dc.w	$1,$d,$23,$17
	dc.l	ms_play
	dc.w	$1,$19,$23,$23
	dc.l	ms_rec
	dc.w	$1,$25,$23,$2f
	dc.l	ms_stop

	dc.w	$0,$35,$23,$3b
	dc.l	ms_load_song
	dc.w	$0,$3c,$23,$42
	dc.l	ms_load_sam
	dc.w	$0,$43,$23,$49
	dc.l	ms_load_module

	dc.w	$1,$4a,$23,$54
	dc.l	ms_tryck_load
	dc.w	$25,$4a,$47,$54
	dc.l	ms_tryck_save

	dc.w	$102,$d,$10c,$17
	dc.l	ms_patt
	dc.w	$102,$19,$10c,$23
	dc.l	ms_pos
	dc.w	$102,$25,$10c,$2f
	dc.l	ms_res
	dc.w	$102,$31,$10c,$3b
	dc.l	ms_sam
	dc.w	$102,$3d,$10c,$47
	dc.l	ms_vol
	dc.w	$102,$49,$10c,$53
	dc.l	ms_loop
	dc.w	$102,$55,$10c,$5f
	dc.l	ms_speed
	dc.w	$102,$61,$10c,$6b
	dc.l	ms_bonus
	dc.w	$102,$6d,$10c,$75
	dc.l	ms_trans
	dc.w	$10e,$6d,$118,$75
	dc.l	ms_trans2
	dc.w	$b3,$2b,$d5,$35
	dc.l	ms_proc_trans
	dc.w	$b3,$37,$d5,$41
	dc.l	ms_proc_loop

;	dc.w	$7e,$02,$7e,$02
;	dc.l	ms_hidden
;	dc.w	$13d,$0,$13d,$0
;	dc.l	ms_colors
;	dc.w	$13c,$0,$13c,$0
;	dc.l	ms_cords

	dc.w	$b3,$1f,$d5,$29
	dc.l	ms_proc_vol
	dc.w	$10e,$d,$118,$17
	dc.l	ms_patt2
	dc.w	$10e,$19,$118,$23
	dc.l	ms_pos2
	dc.w	$10e,$25,$118,$2f
	dc.l	ms_res2
	dc.w	$10e,$31,$118,$3b
	dc.l	ms_sam2
	dc.w	$10e,$3d,$118,$47
	dc.l	ms_vol2
	dc.w	$10e,$49,$118,$53
	dc.l	ms_loop2
	dc.w	$10e,$55,$118,$5f
	dc.l	ms_speed2
	dc.w	$10e,$61,$118,$6b
	dc.l	ms_bonus2
	dc.w	$b3,$4c,$cd,$56
	dc.l	ms_int
	dc.w	$b3,$58,$cd,$62
	dc.l	ms_ext
	dc.w	$2f,$d,$39,$17
	dc.l	ms_ch1
	dc.w	$3b,$d,$45,$17
	dc.l	ms_ch2
	dc.w	$47,$d,$51,$17
	dc.l	ms_ch3
	dc.w	$53,$d,$5d,$17
	dc.l	ms_ch4
	dc.w	$30,$3e,$3a,$48
	dc.l	ms_driva
	dc.w	$3c,$3e,$46,$48
	dc.l	ms_drivb
	dc.w	$d9,$d,$ea,$15
	dc.l	ms_insert
	dc.w	$d9,$17,$fa,$1f
	dc.l	ms_deleate
	dc.w	$d9,$21,$ea,$29
	dc.l	ms_find_ledish
	dc.w	$b3,$43,$c4,$4a
	dc.l	ms_line
	dc.w	$c6,$43,$cc,$4a
	dc.l	ms_wormext
	dc.w	$ce,$43,$d4,$4a
	dc.l	ms_wormint

	dc.w	$b2,$66,$bc,$70
	dc.l	ms_drumm_upp
	dc.w	$be,$66,$c8,$70
	dc.l	ms_drumm_down
	dc.w	$ca,$66,$dc,$70
	dc.l	ms_drumm_clr

	dc.w	$b2,$72,$bc,$75
	dc.l	ms_bonus_upp
	dc.w	$be,$72,$c8,$75
	dc.l	ms_bonus_ner
	dc.w	$ca,$72,$dc,$75
	dc.l	ms_bonus_clr

	dc.w	$49,$26,$59,$35
	dc.l	ms_mousetoggle
	dc.w	$5b,$59,$6b,$68
	dc.l	ms_change_mod
	dc.w	$49,$48,$59,$57
	dc.l	ms_bass
	dc.w	$5b,$26,$6b,$35
	dc.l	ms_drumm
	dc.w	$49,$37,$59,$46
	dc.l	ms_help
	dc.w	$5b,$37,$6b,$46
	dc.l	ms_midi
	dc.w	$5b,$48,$6b,$57
	dc.l	ms_tune
	dc.w	$49,$59,$59,$68
	dc.l	ms_hidden2

	dc.w	$2a,$22,$2b,$23
	dc.l	ms_tebas
	dc.w	$2c,$22,$2d,$23
	dc.l	ms_tebas2
	dc.w	$2e,$22,$2f,$23
	dc.l	ms_tebas3
	dc.w	$30,$22,$31,$23
	dc.l	ms_tebas4
	dc.w	$32,$22,$33,$23
	dc.l	ms_tebas5
	dc.w	$34,$22,$35,$23
	dc.l	ms_tebas6
	dc.w	$36,$22,$37,$23
	dc.l	ms_tebas7
	dc.w	$38,$22,$39,$23
	dc.l	ms_tebas8
	dc.w	$3a,$22,$3b,$23
	dc.l	ms_tebas9
	dc.w	$3c,$22,$3d,$23
	dc.l	ms_tebas10
	dc.w	$3e,$22,$3f,$23
	dc.l	ms_tebas11
	dc.w	$40,$22,$41,$23
	dc.l	ms_tebas12
	dc.w	$42,$22,$43,$23
	dc.l	ms_tebas13

	dc.w	$2a,$25,$40,$29
	dc.l	ms_do_bass
	dc.w	$2a,$2b,$40,$2f
	dc.l	ms_do_treb

	dc.w	$11a,$d,$13c,$17
	dc.l	ms_restore_patt
	dc.w	$11a,$19,$13c,$23
	dc.l	ms_restore_pos
	dc.w	$11a,$25,$13c,$2f
	dc.l	ms_restore_res
	dc.w	$11a,$31,$13c,$3b
	dc.l	ms_restore_spl
	dc.w	$11a,$3d,$13c,$47
	dc.l	ms_restore_vol
	dc.w	$11a,$49,$13c,$53
	dc.l	ms_restore_loop
	dc.w	$11a,$55,$13c,$5f
	dc.l	ms_restore_temp
	dc.w	$11a,$61,$13c,$6b
	dc.l	ms_restore_spec
	dc.w	$11a,$6d,$13c,$75
	dc.l	ms_restore_tran

	dc.w	$71,$d,$7b,$17
	dc.l	ms_offs
	dc.w	$91,$d,$9b,$17
	dc.l	ms_offs2
	dc.w	$9d,$d,$af,$17
	dc.l	ms_clearoffs

	dc.w	$0,$0,$c,$a
	dc.l	ms_exit
	dc.w	-1
exit_flg:
	dc.w	0
help_text:
	DC.B	"       -TCB TRACKER- HJéLPSKéRM 1       "
	DC.B	"                                        "
	DC.B	"           FUNKTIONSTANGENTER           " 
	DC.B	"                                        "
	DC.B	" F1  - KLIPP UT SPèR                    "
	DC.B	" F2  - KLISTRA IN SPèR                  "
	DC.B	" F3  - KLIPP UT AVSNITT                 "
	DC.B	" F4  - KLISTRA IN AVSNITT               "
	DC.B	" F5  - LéGG ôVER SPèR                   "
	DC.B	" F6  - LéGG UNDER SPèR                  "
	DC.B	" F7  - HOPPA TILL STEG 00               "
	DC.B	" F8  - HOPPA TILL STEG 10               "
	DC.B	" F9  - HOPPA TILL STEG 20               "
	DC.B	" F10 - HOPPA TILL STEG 30               "
	DC.B	"                                        "
	DC.B	"    [MELLANSLAG SID 2. ESC AVSLUTA]     "
	DC.B	"                                        "
	dc.b	"----------------------------------------"
	dc.b	"                                        "
	DC.B	" -TCB TRACKER- AV                       "
	DC.B	"                                        "
	DC.B	" ANDERS [AN COOL] NILSSON               "
	DC.B	"                                        "
	dc.b	"----------------------------------------"
help_text2:
	DC.B	"       -TCB TRACKER- HJéLPSKéRM 2       "
	DC.B	"                                        "
	DC.B	"      FUNKTIONSTANGENTERNA + SHIFT      " 
	DC.B	"                                        "
	DC.B	" F1  - MARKERA BLOCKSTART               "
	DC.B	" F2  - MARKERA BLOCKSLUT                "
	DC.B	" F3  - KLISTRA IN BLOCK                 "
	DC.B	" F4  - BYT UT SPECIELL SAMPLING         "
	DC.B	" F5  - KOPIERA SPECIELL SAMPLING        "
	DC.B	" F6  - TRANSPONERA SPECIELL SAMPLING    "
	DC.B	" F7  - RADERA SPECIELL SAMPLING         "
	DC.B	" F8  - UTôKA SPèR                       "
	DC.B	" F9  - KLISTRA IN èTERSTèENDE NOTER     "
	DC.B	" F10 - KLIPP UT SPèR BAKLéNGES          "
	DC.B	"                                        "
	DC.B	"    [MELLANSLAG SID 3. ESC AVSLUTA]     "
	DC.B	"                                        "
	dc.b	"----------------------------------------"
	DC.B	"                                        "
	DC.B	" -TCB TRACKER- UTVECKLAD I              "
	DC.B	"                                        "
	DC.B	" SEABEAR STUDIOS, STOCKHOLM, SVERIGE    "
	DC.B	"                                        "
	dc.b	"----------------------------------------"
help_text3:
	DC.B	"       -TCB TRACKER- HJéLPSKéRM 3       "
	DC.B	"                                        "
	DC.B	"    FUNKTIONSTANGENTERNA + ALTERNATE    "
	DC.B	"                                        "
	DC.B	" F1  - MONITOR AV/Pè                    "
	DC.B	" F2  - CYCLE AV/Pè                      "
	DC.B	" F3  - MUTE AV/Pè                       "
	DC.B	" F4  - KOPIERA SPèR MED OFFSET          "
	DC.B	" F5  - RESERVERAD                       "
	DC.B	" F6  - RESERVERAD                       "
	DC.B	" F7  - RESERVERAD                       "
	DC.B	" F8  - RESERVERAD                       "
	DC.B	" F9  - RESERVERAD                       "
	DC.B	" F10 - RESERVERAD                       "
	DC.B	"                                        "
	DC.B	"    [MELLANSLAG SID 4. ESC AVSLUTA]     "
	DC.B	"                                        "
	dc.b	"----------------------------------------"
	dc.b	"                                        "
	DC.B	" -TCB TRACKER- COPYRIGHT 1991           "
	dc.b	"                                        "
	DC.B	" SEABEAR STUDIOS OCH  ATARI           "
	dc.b	"                                        "
	dc.b	"----------------------------------------"
help_text4:
	DC.B	"       -TCB TRACKER- HJéLPSKéRM 4       "
	DC.B	"                                        "
	DC.B	"             TANGENTBORDET              " 
	DC.B	"                                        "
	DC.B	" [<]         - éNDRA FéRG Pè BILDSKéRMEN"
	DC.B	" [SHIFT]-[<] - éNDRA FéRG Pè MARKôR     "
	DC.B	" [ALT-[<]    - éNDRA FéRG Pè KNAPPAR    "
	DC.B	" [RETURN]    - JA/OK                    "
	DC.B	" [UNDO]      - SISTA KOMMANDOT OGJORT   "
	DC.B	" [HELP]      - VISAR DESSA HJéLPSKéRMAR "
	DC.B	" [INS]       - SéTT IN ETT TOMT STEG    "
	DC.B	" [DEL]       - RADERA NOT               "
	DC.B	" [CLR HOME]  - HOPPA TILL SèNGSTART     "
	DC.B	" [ESC]       - AVSLUTA -TCB TRACKER-    "
	DC.B	"                                        "
	DC.B	"    [MELLANSLAG SID 5. ESC AVSLUTA]     "
	DC.B	"                                        "
	dc.b	"----------------------------------------"
	dc.b	"                                        "
	dc.b	" ATARI CORP. SCANDINAVIA AB             "
	dc.b	" BOX 552                                "
	dc.b	" 175 26 JéRFéLLA / TEL 08-7959120       "
	dc.b	"                                        "
	dc.b	"----------------------------------------"
help_text5:
	DC.B	"       -TCB TRACKER- HJéLPSKéRM 5       "
	DC.B	"                                        "
	DC.B	"      DET NUMERISKA TANGENTBORDET       " 
	DC.B	"                                        "
	DC.B	" [ENTER] - PLAY   (SPELA)               "
	DC.B	" [.]     - RECORD (SPELA IN)            "
	DC.B	" [0]     - STOPP                        "
	DC.B	" [1]     - LéS IN INSTéLLNINGAR         "
	DC.B	" [2]     - SPARA INSTéLLNINGAR          "
	DC.B	" [3]     - STéNG AV/SéTT Pè BILDSKéRMEN "
	DC.B	" [4]     - SPARA SèNG                   "
	DC.B	" [5]     - SPARA SAMPLING               "
	DC.B	" [6]     - SPARA MODUL                  "
	DC.B	" [7]     - LéS IN SèNG                  "
	DC.B	" [8]     - LéS IN SAMPLING              "
	DC.B	" [9]     - LéS IN MODUL                 "
	DC.B	" [(]     - ôKA LOOP-VéRDE SNABBT        "
	DC.B	" [)]     - MINSKA LOOP-VéRDE SNABBT     "
	DC.B	"                                        "
	DC.B	" [MELLANSLAG ELLER ESC FôR ATT AVSLUTA] "
	DC.B	"                                        "
	dc.b	"----------------------------------------"
	dc.b	" Copyright  ATARI 1991  Version 2.0 S "
	dc.b	"----------------------------------------"
drift:
	dc.w	$1E00,$FFFF,$6180,$FFFF
	dc.w	$4080,$FF7F,$8040,$FFBF
	dc.w	$8040,$FFBF,$8040,$FFBF
	dc.w	$4080,$FF7F,$6180,$9E7F
	dc.w	$1E00,$E1FF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
shifted_drift:
	ds.b	4*16*16*2
error_rutan:
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFE,$0001,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80FE,$7F01,$FCFC,$0303
	dc.w	$7CFC,$8303,$0C67,$F398
	dc.w	$C001,$3FFF,$80C0,$7F3F
	dc.w	$C6C6,$3939,$C6C6,$3939
	dc.w	$0E6C,$F193,$6001,$9FFF
	dc.w	$80F8,$7F07,$C6C6,$3939
	dc.w	$C6C6,$3939,$0F6C,$F093
	dc.w	$6001,$9FFF,$80C0,$7F3F
	dc.w	$FCFC,$0303,$C6FC,$3903
	dc.w	$0DEC,$F213,$6001,$9FFF
	dc.w	$80C0,$7F3F,$D8D8,$2727
	dc.w	$C6D8,$3927,$0CEC,$F313
	dc.w	$6001,$9FFF,$80C0,$7F3F
	dc.w	$CCCC,$3333,$C6CC,$3933
	dc.w	$0C6C,$F393,$6601,$99FF
	dc.w	$80FE,$7F01,$C6C6,$3939
	dc.w	$7CC6,$8339,$0C67,$F398
	dc.w	$C601,$39FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
fileselect:
	dc.w	$FFEF,$0010,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFE,$0001,$8018,$7FF7
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8F18,$70F7,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$9F98,$6077
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$B6D8,$4937,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$B9D8,$4637
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$B6D8,$4937,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$9F98,$6077
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8F18,$70F7,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8018,$7FF7
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$7FF7,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFE,$0001
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$7FFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$EFFE,$1001,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1841,$F7BF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$18E1,$F71F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$19F1,$F60F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1BF9,$F407
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$18E1,$F71F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$18E1,$F71F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$18E1,$F71F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$17FF,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1FFE,$F001
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$19F9,$F607,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1981,$F67F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$19F1,$F60F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1981,$F67F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1981,$F67F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1981,$F67F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$19F9,$F607,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1999,$F667,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1999,$F667
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$18F1,$F70F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1861,$F79F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$18F1,$F70F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1999,$F667
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1999,$F667,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$18F1,$F70F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1861,$F79F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1861,$F79F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1861,$F79F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1861,$F79F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1861,$F79F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$18F1,$F70F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$19F9,$F607,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1861,$F79F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1861,$F79F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1861,$F79F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1861,$F79F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1861,$F79F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1861,$F79F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$17FF,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1FFE,$F001
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$18E1,$F71F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$18E1,$F71F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$18E1,$F71F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1BF9,$F407,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$19F1,$F60F
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$18E1,$F71F,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1841,$F7BF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$1801,$F7FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$1801,$F7FF
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$F7FF,$FFFF


mufstask2:
	dc.w	0,0,0,0,0,0,0,0,0,0,0	
	dc.w	0,0,0,0,0,0,0,0,0,0	
	dc.w	0,0,0,0,0,0,0,0,0,0	
	dc.w	0,37*8,0,0,0,0,0,0,0,0	
	dc.w	0,0,42*8,43*8,38*8,44*8,0,27*8,28*8,29*8	
	dc.w	30*8,31*8,32*8,33*8,34*8,35*8,36*8,0,0,0	
	dc.w	0,0,0,0,1*8,2*8,3*8,4*8,5*8,6*8	
	dc.w	7*8,8*8,9*8,10*8,11*8,12*8,13*8,14*8,15*8,16*8	
	dc.w	17*8,18*8,19*8,20*8,21*8,22*8,23*8,24*8,25*8,26*8	
	dc.w	40*8,45*8,41*8,0,39*8,0,0,0,0,0	
	ds.w	256

comfont:
	DC.W	0,0,0,0
	DC.W	$183C,$66C3,$E724,$243C
	DC.W	$3C24,$24E7,$C366,$3C18
	DC.W	$181C,$F683,$83F6,$1C18
	DC.W	$1838,$6FC1,$C16F,$3818
	DC.W	$FF81,$BDA5,$A5BD,$81FF
	DC.W	$F88F,$89F9,$4141,$7F00
	DC.W	$FF89,$89F9,$8181,$81FF
	DC.W	$103,$68C,$D870,$2000
	DC.W	$7EC3,$D3D3,$DBC3,$C37E
	DC.W	$183C,$3C3C,$7E10,$3810
	DC.W	$181C,$1610,$1070,$F060
	DC.W	$F0C0,$FED8,$DE18,$1800
	DC.W	$F0C0,$DFDB,$FF1E,$1B00
	DC.W	$505,$50D,$D19,$7971
	DC.W	$A0A0,$A0B0,$B098,$9E8E
	DC.W	$7CC6,$C600,$C6C6,$7C00
	DC.W	$606,$600,$606,$600
	DC.W	$7C06,$67C,$C0C0,$7C00
	DC.W	$7C06,$67C,$606,$7C00
	DC.W	$C6C6,$C67C,$606,$600
	DC.W	$7CC0,$C07C,$606,$7C00
	DC.W	$7CC0,$C07C,$C6C6,$7C00
	DC.W	$7C06,$600,$606,$600
	DC.W	$7CC6,$C67C,$C6C6,$7C00
	DC.W	$7CC6,$C67C,$606,$7C00
	DC.W	0,$3C06,$7E66,$3C00
	DC.W	$7860,$7860,$7E18,$1E00
	DC.W	$70F,$1F18,$1810,$1E17
	DC.W	$F0F8,$EC04,$404,$3C54
	DC.W	$110B,$D06,$72E,$3938
	DC.W	$428,$D828,$D010,$E000
	DC.W	0,0,0,0
	DC.W	$1818,$1818,$1800,$1800
	DC.W	$6666,$6600,0,0
	DC.W	$6C,$FE6C,$6CFE,$6C00
	DC.W	$287E,$A87C,$2AFC,$2800
	DC.W	$6396,$6C18,$3669,$C600
	DC.W	$78CC,$61CE,$CCCC,$7800
	DC.W	$1818,$1000,0,0
	DC.W	$408,$1818,$1808,$400
	DC.W	$2010,$1818,$1810,$2000
	DC.W	$1054,$38FE,$3854,$1000
	DC.W	$18,$187E,$1818,0
	DC.W	0,0,$30,$3020
	DC.W	0,$7E,0,0
	DC.W	0,0,$18,$1800
	DC.W	$206,$C18,$3060,$4000
	DC.W	$3C66,$6E76,$6666,$3C00
	DC.W	$1838,$1818,$1818,$1800
	DC.W	$3C66,$60C,$1830,$7E00
	DC.W	$7E0C,$180C,$666,$3C00
	DC.W	$C1C,$3C6C,$7E0C,$C00
	DC.W	$7E60,$7C06,$666,$3C00
	DC.W	$3C60,$607C,$6666,$3C00
	DC.W	$7E06,$C18,$3030,$3000
	DC.W	$3C66,$663C,$6666,$3C00
	DC.W	$3C66,$663E,$60C,$3800
	DC.W	$18,$1800,$1818,0
	DC.W	$18,$1800,$1818,$1000
	DC.W	$60C,$1830,$180C,$600
	DC.W	0,$7E00,$7E,0
	DC.W	$6030,$180C,$1830,$6000
	DC.W	$3C66,$60C,$1800,$1800
	DC.W	$3C66,$6E6A,$6E60,$3E00
	DC.W	$3C66,$667E,$6666,$6600
	DC.W	$7C66,$667C,$6666,$7C00
	DC.W	$3C62,$6060,$6062,$3C00
	DC.W	$7C66,$6666,$6666,$7C00
	DC.W	$7E60,$607C,$6060,$7E00
	DC.W	$7E60,$607C,$6060,$6000
	DC.W	$3C62,$606E,$6666,$3E00
	DC.W	$6666,$667E,$6666,$6600
	DC.W	$1818,$1818,$1818,$1800
	DC.W	$606,$606,$646,$3C00
	DC.W	$666C,$7870,$786C,$6600
	DC.W	$6060,$6060,$6060,$7E00
	DC.W	$FEDB,$DBDB,$DBDB,$DB00
	DC.W	$6676,$7E7E,$6E66,$6600
	DC.W	$3C66,$6666,$6666,$3C00
	DC.W	$7C66,$667C,$6060,$6000
	DC.W	$3C66,$6666,$6666,$3C06
	DC.W	$7C66,$667C,$6666,$6600
	DC.W	$3C62,$703C,$E46,$3C00
	DC.W	$7E18,$1818,$1818,$1800
	DC.W	$6666,$6666,$6666,$3C00
	DC.W	$6666,$6666,$666C,$7800
	DC.W	$DBDB,$DBDB,$DBDA,$FC00
	DC.W	$6666,$663C,$6666,$6600
	DC.W	$6666,$663C,$1818,$1800
	DC.W	$7E06,$C18,$3060,$7E00
	DC.W	$1E18,$1818,$1818,$1E00
	DC.W	$4060,$3018,$C06,$200
	DC.W	$7818,$1818,$1818,$7800
	DC.W	$1038,$6CC6,0,0
	DC.W	0,0,0,$FE00
	DC.W	$C0,$6030,0,0
	DC.W	0,$3C46,$3E66,$3E00
	DC.W	$6060,$7C66,$6666,$7C00
	DC.W	0,$3C60,$6060,$3C00
	DC.W	$606,$3E66,$6666,$3E00
	DC.W	0,$3C66,$7E60,$3C00
	DC.W	$1E30,$7C30,$3030,$3000
	DC.W	0,$3E66,$663E,$463C
	DC.W	$6060,$7C66,$6666,$6600
	DC.W	$1800,$1818,$1818,$1800
	DC.W	$C00,$C0C,$C0C,$4C38
	DC.W	$6060,$666C,$786C,$6600
	DC.W	$3030,$3030,$3030,$3000
	DC.W	0,$FEDB,$DBDB,$DB00
	DC.W	0,$7C66,$6666,$6600
	DC.W	0,$3C66,$6666,$3C00
	DC.W	0,$7C66,$6666,$7C60
	DC.W	0,$3E66,$6666,$3E06
	DC.W	0,$6C70,$6060,$6000
	DC.W	0,$3E60,$3C06,$7C00
	DC.W	$18,$3C18,$1818,$C00
	DC.W	0,$6666,$6666,$3E00
	DC.W	0,$6666,$6664,$7800
	DC.W	0,$DBDB,$DBDA,$FC00
	DC.W	0,$6666,$3C66,$6600
	DC.W	0,$6666,$663E,$463C
	DC.W	0,$7E0C,$1830,$7E00
	DC.W	$E18,$1830,$1818,$E00
	DC.W	$1818,$1818,$1818,$1818
	DC.W	$7018,$180C,$1818,$7000
	DC.W	$60,$F29E,$C00,0
	DC.W	$18,$1834,$3462,$7E00
	DC.W	$3C,$6660,$663C,$838
	DC.W	$6600,$66,$6666,$3E00
	DC.W	$C18,$3C,$7E60,$3C00
	DC.W	$1866,$3C,$67E,$3E00
	DC.W	$6600,$3C06,$3E66,$3E00
	DC.W	$3018,$3C,$67E,$3E00
	DC.W	$1818,$3C,$67E,$3E00
	DC.W	0,$3C60,$603C,$818
	DC.W	$1866,$3C,$7E60,$3C00
	DC.W	$6600,$3C66,$7E60,$3C00
	DC.W	$3018,$3C,$7E60,$3C00
	DC.W	$6600,$38,$1818,$3C00
	DC.W	$1866,$38,$1818,$3C00
	DC.W	$6030,$38,$1818,$3C00
	DC.W	$6600,$183C,$667E,$6600
	DC.W	$1800,$183C,$667E,$6600
	DC.W	$C18,$7E60,$7C60,$7E00
	DC.W	0,$7E1B,$7FD8,$7E00
	DC.W	$3F78,$D8DE,$F8D8,$DF00
	DC.W	$1866,$3C,$6666,$3C00
	DC.W	$6600,$3C,$6666,$3C00
	DC.W	$3018,$3C,$6666,$3C00
	DC.W	$1866,$66,$6666,$3E00
	DC.W	$3018,$66,$6666,$3E00
	DC.W	$6600,$6666,$663E,$67C
	DC.W	$6600,$3C66,$6666,$3C00
	DC.W	$6600,$6666,$6666,$3E00
	DC.W	$1818,$3C60,$603C,$1818
	DC.W	$1C3A,$307C,$3030,$7E00
	DC.W	$6666,$3C18,$3C18,$1800
	DC.W	$1C36,$667C,$6666,$7C60
	DC.W	$1818,$1818,$1818,$1818
	DC.W	$C18,$3C,$67E,$3E00
	DC.W	$C18,$38,$1818,$3C00
	DC.W	$C18,$3C,$6666,$3C00
	DC.W	$C18,$66,$6666,$3E00
	DC.W	$3458,$7C,$6666,$6600
	DC.W	$3458,$66,$766E,$6600
	DC.W	$3C,$63E,$663E,$3C
	DC.W	$3C,$6666,$663C,$3C
	DC.W	$18,$18,$3060,$663C
	DC.W	0,$3E,$3030,$3000
	DC.W	0,$7C,$C0C,$C00
	DC.W	$C6CC,$D836,$6BC3,$860F
	DC.W	$C6CC,$D836,$6ED6,$9F06
	DC.W	$18,$18,$1818,$1818
	DC.W	$1B36,$6CD8,$6C36,$1B00
	DC.W	$D86C,$361B,$366C,$D800
	DC.W	$3458,$3C,$67E,$3E00
	DC.W	$3458,$3C,$6666,$3C00
	DC.W	$23C,$666E,$7666,$3C40
	DC.W	2,$3C6E,$7666,$3C40
	DC.W	$1818,$1818,$F818,$1818
	DC.W	$1818,$F818,$F818,$1818
	DC.W	$3636,$3636,$F636,$3636
	DC.W	0,$FE6C,$6C6C,$6C00
	DC.W	0,$F818,$F818,$1818
	DC.W	$3636,$F606,$F636,$3636
	DC.W	$3636,$3636,$3636,$3636
	DC.W	0,$FE06,$F636,$3636
	DC.W	$3636,$F606,$FE00,0
	DC.W	$1818,$F818,$F800,0
	DC.W	$1818,$F818,$F800,0
	DC.W	0,0,$F818,$1818
	DC.W	$1818,$1818,$1F00,0
	DC.W	$1818,$1818,$FF00,0
	DC.W	0,0,$FF18,$1818
	DC.W	$1818,$1818,$1F18,$1818
	DC.W	0,0,$FF00,0
	DC.W	$1818,$1818,$FF18,$1818
	DC.W	$1818,$1F18,$1F18,$1818
	DC.W	$3636,$3636,$3736,$3636
	DC.W	$3636,$3730,$3F00,0
	DC.W	0,$3F30,$3736,$3636
	DC.W	$3636,$F700,$FF00,0
	DC.W	0,$FF00,$F736,$3636
	DC.W	$3636,$3730,$3736,$3636
	DC.W	0,$FF00,$FF00,0
	DC.W	$3636,$F700,$F736,$3636
	DC.W	$1818,$FF00,$FF00,0
	DC.W	$3636,$3636,$FF00,0
	DC.W	0,$FF00,$FF18,$1818
	DC.W	0,0,$FF36,$3636
	DC.W	$3636,$3636,$3F00,0
	DC.W	$3030,$3F30,$3F00,0
	DC.W	0,$3F30,$3F30,$3030
	DC.W	0,0,$7F6C,$6C6C
	DC.W	$3636,$3636,$FF36,$3636
	DC.W	$1818,$FF18,$FF18,$1818
	DC.W	$1818,$1818,$F800,0
	DC.W	0,0,$1F18,$1818
	DC.W	$FF,$FFFF,$FFFF,$FF00
	DC.W	0,0,$FFFF,$FF00
	DC.W	$E1B,$3C66,$663C,$D870
	DC.W	$10,$386C,$C682,0
	DC.W	$66F7,$9999,$EF66,0
	DC.W	0,$76DC,$C8DC,$7600
	DC.W	$1C36,$667C,$6666,$7C60
	DC.W	$FE,$6662,$6060,$60F8
	DC.W	0,$FE6C,$6C6C,$6C48
	DC.W	$FE66,$3018,$3066,$FE00
	DC.W	$1E,$386C,$6C6C,$3800
	DC.W	0,$6C6C,$6C6C,$7FC0
	DC.W	0,$7E18,$1818,$1810
	DC.W	$3C18,$3C66,$663C,$183C
	DC.W	$3C,$667E,$6666,$3C00
	DC.W	$3C,$6666,$6624,$6600
	DC.W	$1C36,$78DC,$CCEC,$7800
	DC.W	$C18,$3854,$5438,$3060
	DC.W	$10,$7CD6,$D6D6,$7C10
	DC.W	$3E70,$607E,$6070,$3E00
	DC.W	$3C66,$6666,$6666,$6600
	DC.W	$7E,$7E,$7E,0
	DC.W	$1818,$7E18,$1800,$7E00
	DC.W	$3018,$C18,$3000,$7E00
	DC.W	$C18,$3018,$C00,$7E00
	DC.W	$E,$1B1B,$1818,$1818
	DC.W	$1818,$1818,$D8D8,$7000
	DC.W	$1818,$7E,$18,$1800
	DC.W	$32,$4C00,$324C,0
	DC.W	$386C,$3800,0,0
	DC.W	$387C,$3800,0,0
	DC.W	0,0,$1818,0
	DC.W	0,$F18,$D870,$3000
	DC.W	$386C,$6C6C,$6C00,0
	DC.W	$386C,$1830,$7C00,0
	DC.W	$780C,$380C,$7800,0
	DC.W	$FE,0,0,0

name_buff:
	rept	200
	dc.b	"        "
	endr
hidden_an_cool:
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFE,$0001,$8000,$7FFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8212,$7FFF
	dc.w	$0000,$FFFF,$0101,$FFFF
	dc.w	$831A,$7FFF,$03CC,$FFFF
	dc.w	$0101,$FFFF,$879A,$7FFF
	dc.w	$060E,$FFFF,$7901,$FFFF
	dc.w	$84DE,$7FFF,$0412,$FFFF
	dc.w	$4901,$FFFF,$87D6,$7FFF
	dc.w	$0412,$FFFF,$C901,$FFFF
	dc.w	$8C52,$7FFF,$0612,$FFFF
	dc.w	$8939,$FFFF,$8052,$7FFF
	dc.w	$03DE,$FFFF,$F9E1,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
size_buff:
	rept	200
	dc.l	0
	endr
disk_space:
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFE,$0001
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80FC,$7F03,$F3E3,$0C1C
	dc.w	$F007,$0FF8,$CFC1,$303E
	dc.w	$C3F7,$3C08,$F001,$0FFF
	dc.w	$80C6,$7F39,$6606,$99F9
	dc.w	$000C,$FFF3,$0C63,$F39C
	dc.w	$E606,$19F9,$0001,$FFFF
	dc.w	$80C6,$7F39,$63E6,$9C19
	dc.w	$0007,$FFF8,$CC66,$3399
	dc.w	$3607,$C9F8,$C001,$3FFF
	dc.w	$80C6,$7F39,$6036,$9FC9
	dc.w	$0000,$FFFF,$6FC7,$9038
	dc.w	$F606,$09F9,$0001,$FFFF
	dc.w	$80C6,$7F39,$6036,$9FC9
	dc.w	$0000,$FFFF,$6C06,$93F9
	dc.w	$3606,$C9F9,$0001,$FFFF
	dc.w	$80C6,$7F39,$6036,$9FC9
	dc.w	$0000,$FFFF,$6C06,$93F9
	dc.w	$3606,$C9F9,$0001,$FFFF
	dc.w	$80FC,$7F03,$F3E3,$0C1C
	dc.w	$F007,$0FF8,$CC06,$33F9
	dc.w	$33F7,$CC08,$F001,$0FFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80FE,$7F01,$FCFE,$0301
	dc.w	$FE00,$01FF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C0,$7F3F,$C6C0,$393F
	dc.w	$C060,$3F9F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80F8,$7F07,$C6F8,$3907
	dc.w	$F860,$079F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C0,$7F3F,$FCC0,$033F
	dc.w	$C000,$3FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C0,$7F3F,$D8C0,$273F
	dc.w	$C060,$3F9F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C0,$7F3F,$CCC0,$333F
	dc.w	$C060,$3F9F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C0,$7F3F,$C6FE,$3901
	dc.w	$FE00,$01FF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C6,$7F39,$7EFE,$8101
	dc.w	$FC00,$03FF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C6,$7F39,$C0C0,$3F3F
	dc.w	$C660,$399F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C6,$7F39,$7CF8,$8307
	dc.w	$C660,$399F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C6,$7F39,$06C0,$F93F
	dc.w	$C600,$39FF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C6,$7F39,$06C0,$F93F
	dc.w	$C660,$399F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80C6,$7F39,$06C0,$F93F
	dc.w	$C660,$399F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$807C,$7F83,$FCFE,$0301
	dc.w	$FC00,$03FF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
file_format:
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFE,$0001
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8319,$7CE6,$F3F0,$0C0F
	dc.w	$1F9F,$E060,$3F3F,$C0C0
	dc.w	$3F9F,$C060,$BF01,$40FF
	dc.w	$839B,$7C64,$18C0,$E73F
	dc.w	$3031,$CFCE,$B1B1,$4E4E
	dc.w	$B030,$4FCF,$0C01,$F3FF
	dc.w	$83DB,$7C24,$18C0,$E73F
	dc.w	$3031,$CFCE,$B1B1,$4E4E
	dc.w	$BE30,$41CF,$0C01,$F3FF
	dc.w	$837B,$7C84,$18C0,$E73F
	dc.w	$3031,$CFCE,$BF3F,$40C0
	dc.w	$3030,$CFCF,$0C01,$F3FF
	dc.w	$833B,$7CC4,$18C0,$E73F
	dc.w	$3031,$CFCE,$B636,$49C9
	dc.w	$3030,$CFCF,$0C01,$F3FF
	dc.w	$831B,$7CE4,$18C0,$E73F
	dc.w	$3031,$CFCE,$B333,$4CCC
	dc.w	$3030,$CFCF,$0C01,$F3FF
	dc.w	$8319,$7CE6,$F0C0,$0F3F
	dc.w	$1F9F,$E060,$31B1,$CE4E
	dc.w	$BF9F,$4060,$8C01,$73FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$83F9,$7C06,$E607,$19F8
	dc.w	$F03F,$0FC0,$9F3F,$60C0
	dc.w	$318E,$CE71,$3F01,$C0FF
	dc.w	$8300,$7CFF,$C606,$39F9
	dc.w	$0030,$FFCF,$31B1,$CE4E
	dc.w	$BB9F,$4460,$0C01,$F3FF
	dc.w	$83E0,$7C1F,$C607,$39F8
	dc.w	$C03E,$3FC1,$31B1,$CE4E
	dc.w	$BFB1,$404E,$8C01,$73FF
	dc.w	$8300,$7CFF,$C606,$39F9
	dc.w	$0030,$FFCF,$31BF,$CE40
	dc.w	$35BF,$CA40,$8C01,$73FF
	dc.w	$8300,$7CFF,$C606,$39F9
	dc.w	$0030,$FFCF,$31B6,$CE49
	dc.w	$31B1,$CE4E,$8C01,$73FF
	dc.w	$8300,$7CFF,$C606,$39F9
	dc.w	$0030,$FFCF,$31B3,$CE4C
	dc.w	$31B1,$CE4E,$8C01,$73FF
	dc.w	$8301,$7CFE,$E7F7,$1808
	dc.w	$F030,$0FCF,$1F31,$E0CE
	dc.w	$B1B1,$4E4E,$8C01,$73FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
sure_sign:
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFF,$0000,$FFFF,$0000
	dc.w	$FFFE,$0001,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$871F,$78E0
	dc.w	$9FC0,$603F,$0C33,$F3CC
	dc.w	$F30C,$0CF3,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8F98,$7067,$D800,$27FF
	dc.w	$0C36,$F3C9,$1B0C,$E4F3
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$98D8,$6727
	dc.w	$DF00,$20FF,$0C36,$F3C9
	dc.w	$1B0C,$E4F3,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$9FDF,$6020,$9800,$67FF
	dc.w	$07E6,$F819,$1B0C,$E4F3
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$98DB,$6724
	dc.w	$1800,$E7FF,$0186,$FE79
	dc.w	$1B0C,$E4F3,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$98D9,$6726,$9800,$67FF
	dc.w	$0186,$FE79,$1B0C,$E4F3
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$98D8,$6727
	dc.w	$DFC0,$203F,$0183,$FE7C
	dc.w	$F1F8,$0E07,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8F98,$7067
	dc.w	$6FCF,$9030,$E780,$187F
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$9818,$67E7,$6C6C,$9393
	dc.w	$0CC0,$F33F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8F98,$7067
	dc.w	$6C6F,$9390,$80C0,$7F3F
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80D8,$7F27,$6FCC,$9033
	dc.w	$0180,$FE7F,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$80D8,$7F27
	dc.w	$6D8C,$9273,$0300,$FCFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$80D8,$7F27,$6CCC,$9333
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8F8F,$7070
	dc.w	$CC6F,$3390,$E300,$1CFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0001,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0001,$FFFE,$FFFF,$0000
	dc.w	$FFC0,$003F,$0FFF,$F000
	dc.w	$FE01,$01FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0001,$FFFE
	dc.w	$0000,$FFFF,$0020,$FFFF
	dc.w	$0800,$F7FF,$0101,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0001,$FFFE,$61BF,$9E40
	dc.w	$9F20,$60FF,$0B19,$F4E6
	dc.w	$F901,$07FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0001,$FFFE
	dc.w	$61B0,$9E4F,$3020,$CFFF
	dc.w	$0B9B,$F464,$0D01,$F3FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0001,$FFFE,$61BE,$9E41
	dc.w	$1F20,$E0FF,$0BDB,$F424
	dc.w	$0D01,$F3FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0001,$FFFE
	dc.w	$3F30,$C0CF,$01A0,$FE7F
	dc.w	$0B7B,$F484,$0D01,$F3FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0001,$FFFE,$0C30,$F3CF
	dc.w	$01A0,$FE7F,$0B3B,$F4C4
	dc.w	$0D01,$F3FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0001,$FFFE
	dc.w	$0C30,$F3CF,$01A0,$FE7F
	dc.w	$0B1B,$F4E4,$0D01,$F3FF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0001,$FFFE,$0C3F,$F3C0
	dc.w	$9F20,$60FF,$0B19,$F4E6
	dc.w	$F901,$07FF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0001,$FFFE
	dc.w	$0000,$FFFF,$0020,$FFFF
	dc.w	$0800,$F7FF,$0101,$FFFF
	dc.w	$8000,$7FFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$FFFF,$FFFF
	dc.w	$FFE0,$FFFF,$07FF,$FFFF
	dc.w	$FF01,$FFFF,$8000,$7FFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0000,$FFFF,$0001,$FFFF
	dc.w	$7FFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$FFFF
shose_graff:
	dc.w	$003F,$FFC0,$FFCF,$0030
	dc.w	$FFF3,$000C,$0020,$FFDF
	dc.w	$0028,$FFF7,$000B,$FFFC
	dc.w	$0020,$FFDF,$0028,$FFF7
	dc.w	$000B,$FFFC,$0027,$FFD8
	dc.w	$C068,$3FB7,$008B,$FF7C
	dc.w	$0028,$FFD7,$20AA,$DF75
	dc.w	$010B,$FEFC,$C028,$FFD7
	dc.w	$2129,$DEF6,$820B,$7DFC
	dc.w	$0028,$FFD7,$2128,$DEF7
	dc.w	$640B,$9BFC,$802F,$FFD0
	dc.w	$E128,$1EF7,$1C0B,$E3FC
	dc.w	$0029,$FFD6,$2128,$DEF7
	dc.w	$370B,$C8FC,$C029,$FFD6
	dc.w	$2228,$DDF7,$61CB,$9E3C
	dc.w	$0029,$FFD6,$2228,$DDF7
	dc.w	$C0CB,$3F3C,$0027,$FFD8
	dc.w	$C229,$3DF6,$800B,$7FFC
	dc.w	$8021,$7FDE,$0C28,$F3F7
	dc.w	$000B,$FFFC,$4020,$FFDF
	dc.w	$F028,$0FF7,$000B,$FFFC
	dc.w	$4020,$FFDF,$0028,$FFF7
	dc.w	$000B,$FFFC,$401F,$FFFF
	dc.w	$FFE7,$FFFF,$FFFB,$FFFC
	dc.w	$4000,$FFFF,$0000,$FFFF
	dc.w	$0003,$FFFC,$403F,$FFC0
	dc.w	$FFCF,$0030,$FFF3,$000C
	dc.w	$4020,$FFDF,$0028,$FFF7
	dc.w	$000B,$FFFC,$4020,$FFDF
	dc.w	$F828,$07F7,$000B,$FFFC
	dc.w	$4023,$FFDC,$0628,$F9F7
	dc.w	$360B,$C9FC,$4024,$FFDB
	dc.w	$0128,$FEF7,$D58B,$2A7C
	dc.w	$C024,$FFDB,$8928,$76F7
	dc.w	$888B,$777C,$0028,$FFD7
	dc.w	$D8A9,$2776,$004B,$FFBC
	dc.w	$FE28,$01D7,$00A9,$FF76
	dc.w	$414B,$BEBC,$012A,$FFD5
	dc.w	$02A9,$FD76,$004B,$FFBC
	dc.w	$7129,$8FD6,$8CA9,$7376
	dc.w	$224B,$DDBC,$7124,$8FDB
	dc.w	$F928,$06F7,$888B,$777C
	dc.w	$7124,$8FDB,$7128,$8EF7
	dc.w	$C18B,$3E7C,$FD23,$03DC
	dc.w	$0628,$F9F7,$3E0B,$C1FC
	dc.w	$F920,$07DF,$F828,$07F7
	dc.w	$000B,$FFFC,$7120,$8FDF
	dc.w	$0028,$FFF7,$000B,$FFFC
	dc.w	$211F,$DFFF,$FFE7,$FFFF
	dc.w	$FFFB,$FFFC,$0100,$FFFF
	dc.w	$0000,$FFFF,$0003,$FFFC
	dc.w	$FF3F,$FFC0,$FFCF,$0030
	dc.w	$FFF3,$000C,$0020,$FFDF
	dc.w	$0028,$FFF7,$000B,$FFFC
	dc.w	$FF20,$00DF,$0129,$FEF6
	dc.w	$FFCB,$003C,$00A0,$FFDF
	dc.w	$032A,$FCF5,$002B,$FFDC
	dc.w	$FEA0,$01DF,$072A,$F8F5
	dc.w	$00AB,$FF5C,$C0A0,$3FDF
	dc.w	$0F2A,$F0F5,$002B,$FFDC
	dc.w	$F8A0,$07DF,$1F2A,$E0F5
	dc.w	$002B,$FFDC,$C0A0,$3FDF
	dc.w	$3B2A,$C4F5,$002B,$FFDC
	dc.w	$C0A0,$3FDF,$732A,$8CF5
	dc.w	$7E2B,$81DC,$C0A0,$3FDF
	dc.w	$FF2A,$00F5,$812B,$7EDC
	dc.w	$FEA1,$01DE,$C32A,$3CF5
	dc.w	$B12B,$4EDC,$00A3,$FFDC
	dc.w	$832A,$7CF5,$B12B,$4EDC
	dc.w	$FFA7,$FFD8,$032A,$FCF5
	dc.w	$B12B,$4EDC,$002F,$FFD0
	dc.w	$87A9,$7876,$FFCB,$003C
	dc.w	$0020,$FFDF,$0028,$FFF7
	dc.w	$000B,$FFFC,$001F,$FFFF
	dc.w	$FFE7,$FFFF,$FFFB,$FFFC
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0003,$FFFC,$003F,$FFC0
	dc.w	$FFCF,$0030,$FFF3,$000C
	dc.w	$0020,$FFDF,$0028,$FFF7
	dc.w	$001B,$FFEC,$0021,$FFDE
	dc.w	$DC28,$23F7,$003B,$FFCC
	dc.w	$0022,$FFDD,$2228,$DDF7
	dc.w	$007B,$FF8C,$0024,$FFDB
	dc.w	$1128,$EEF7,$00FB,$FF0C
	dc.w	$0024,$FFDB,$1128,$EEF7
	dc.w	$01FB,$FE0C,$0024,$FFDB
	dc.w	$1128,$EEF7,$03FB,$FC0C
	dc.w	$0022,$FFDD,$2228,$DDF7
	dc.w	$07FB,$F80C,$0021,$FFDE
	dc.w	$DC28,$23F7,$0FFB,$F00C
	dc.w	$0020,$FFDF,$0028,$FFF7
	dc.w	$1FFB,$E00D,$0023,$FFDC
	dc.w	$7728,$88F7,$3FF8,$C00F
	dc.w	$0026,$FFD9,$2628,$D9F7
	dc.w	$7FF8,$800F,$0021,$FFDE
	dc.w	$2428,$DBF7,$FFF8,$000F
	dc.w	$0026,$FFD9,$2729,$D8F6
	dc.w	$FFF8,$000F,$0020,$FFDF
	dc.w	$002B,$FFF4,$FFF8,$000F
	dc.w	$001F,$FFFF,$FFE7,$FFFF
	dc.w	$FFF8,$FFFF
shose_graff2:
	dc.w	$003F,$FFC0,$FFCF,$0030
	dc.w	$FFF3,$000C,$0020,$FFDF
	dc.w	$0028,$FFF7,$000B,$FFFC
	dc.w	$0020,$FFDF,$F828,$07F7
	dc.w	$800B,$7FFC,$0023,$FFDC
	dc.w	$0629,$F9F6,$000B,$FFFC
	dc.w	$002F,$FFD0,$FFA9,$0076
	dc.w	$110B,$EEFC,$C025,$FFDA
	dc.w	$252A,$DAF5,$218B,$DE7C
	dc.w	$0025,$FFDA,$252A,$DAF5
	dc.w	$25EB,$DA1C,$8025,$FFDA
	dc.w	$252A,$DAF5,$25EB,$DA1C
	dc.w	$0025,$FFDA,$252A,$DAF5
	dc.w	$25EB,$DA1C,$C025,$FFDA
	dc.w	$252A,$DAF5,$25EB,$DA1C
	dc.w	$0025,$FFDA,$252A,$DAF5
	dc.w	$218B,$DE7C,$0025,$FFDA
	dc.w	$2529,$DAF6,$110B,$EEFC
	dc.w	$8025,$7FDA,$2529,$DAF6
	dc.w	$000B,$FFFC,$4027,$FFD8
	dc.w	$FF28,$00F7,$800B,$7FFC
	dc.w	$4020,$FFDF,$0028,$FFF7
	dc.w	$000B,$FFFC,$401F,$FFFF
	dc.w	$FFE7,$FFFF,$FFFB,$FFFC
	dc.w	$4000,$FFFF,$0000,$FFFF
	dc.w	$0003,$FFFC,$403F,$FFC0
	dc.w	$FFCF,$0030,$FFF3,$000C
	dc.w	$4020,$FFDF,$0028,$FFF7
	dc.w	$000B,$FFFC,$4020,$FFDF
	dc.w	$F828,$07F7,$000B,$FFFC
	dc.w	$4023,$FFDC,$062B,$F9F4
	dc.w	$FCEB,$031C,$402F,$FFD0
	dc.w	$FFAB,$0074,$F80B,$07FC
	dc.w	$C024,$FFDB,$012B,$FEF4
	dc.w	$F3CB,$0C3C,$0024,$FFDB
	dc.w	$192B,$E6F4,$E00B,$1FFC
	dc.w	$FE24,$01DB,$112B,$EEF4
	dc.w	$F0EB,$0F1C,$0124,$FFDB
	dc.w	$112B,$EEF4,$B80B,$47FC
	dc.w	$7124,$8FDB,$712B,$8EF4
	dc.w	$1DEB,$E21C,$7124,$8FDB
	dc.w	$F12A,$0EF5,$0E0B,$F1FC
	dc.w	$7124,$8FDB,$6128,$9EF7
	dc.w	$06CB,$F93C,$FD24,$03DB
	dc.w	$0128,$FEF7,$000B,$FFFC
	dc.w	$F927,$07D8,$FF28,$00F7
	dc.w	$000B,$FFFC,$7120,$8FDF
	dc.w	$0028,$FFF7,$000B,$FFFC
	dc.w	$211F,$DFFF,$FFE7,$FFFF
	dc.w	$FFFB,$FFFC,$0100,$FFFF
	dc.w	$0000,$FFFF,$0003,$FFFC
	dc.w	$FF3F,$FFC0,$FFCF,$0030
	dc.w	$FFF3,$000C,$0020,$FFDF
	dc.w	$002C,$FFF3,$92AB,$6D5C
	dc.w	$FF20,$00DF,$F829,$07F6
	dc.w	$4A4B,$B5BC,$00A3,$FFDC
	dc.w	$062A,$F9F5,$55BB,$AA4C
	dc.w	$FEAF,$01D0,$FFA9,$0076
	dc.w	$2A6B,$D59C,$C0A4,$3FDB
	dc.w	$012E,$FEF1,$AAAB,$555C
	dc.w	$F8A4,$07DB,$012A,$FEF5
	dc.w	$555B,$AAAC,$C0A4,$3FDB
	dc.w	$0529,$FAF6,$2A2B,$D5DC
	dc.w	$C0A4,$3FDB,$AD2A,$52F5
	dc.w	$A95B,$56AC,$C0A5,$3FDA
	dc.w	$FD2C,$02F3,$DA2B,$25DC
	dc.w	$FEA4,$01DB,$8D29,$72F6
	dc.w	$A4CB,$5B3C,$00A4,$FFDB
	dc.w	$752A,$8AF5,$C94B,$36BC
	dc.w	$FFA4,$FFDB,$012D,$FEF2
	dc.w	$A29B,$5D6C,$0027,$FFD8
	dc.w	$FF2A,$00F5,$4A2B,$B5DC
	dc.w	$0020,$FFDF,$0028,$FFF7
	dc.w	$949B,$6B6C,$001F,$FFFF
	dc.w	$FFE7,$FFFF,$FFFB,$FFFC
	dc.w	$0000,$FFFF,$0000,$FFFF
	dc.w	$0003,$FFFC,$003F,$FFC0
	dc.w	$FFCF,$0030,$FFF3,$000C
	dc.w	$0020,$FFDF,$0028,$FFF7
	dc.w	$001B,$FFEC,$0020,$FFDF
	dc.w	$7028,$8FF7,$003B,$FFCC
	dc.w	$0020,$FFDF,$8828,$77F7
	dc.w	$007B,$FF8C,$0021,$FFDE
	dc.w	$0428,$FBF7,$00FB,$FF0C
	dc.w	$0021,$FFDE,$0428,$FBF7
	dc.w	$01FB,$FE0C,$0021,$FFDE
	dc.w	$0428,$FBF7,$03FB,$FC0C
	dc.w	$0020,$FFDF,$8828,$77F7
	dc.w	$07FB,$F80C,$0020,$FFDF
	dc.w	$7028,$8FF7,$0FFB,$F00C
	dc.w	$0020,$FFDF,$0028,$FFF7
	dc.w	$1FFB,$E00D,$0023,$FFDC
	dc.w	$7728,$88F7,$3FF8,$C00F
	dc.w	$0026,$FFD9,$2628,$D9F7
	dc.w	$7FF8,$800F,$0021,$FFDE
	dc.w	$2428,$DBF7,$FFF8,$000F
	dc.w	$0026,$FFD9,$2729,$D8F6
	dc.w	$FFF8,$000F,$0020,$FFDF
	dc.w	$002B,$FFF4,$FFF8,$000F
	dc.w	$001F,$FFFF,$FFE7,$FFFF
	dc.w	$FFF8,$FFFF
ytab:
	ds.l	200	
pal:
	dc.w	$000,$533,$422,$311
	dc.w	$533,$755,$644,$533
	dc.w	$422,$644,$533,$422
	dc.w	$533,$755,$644,$533
save_pal:
	ds.w	16
midi_ptr	dc.w	0
midi_key	dc.b	0
mausmsg		dcb.b	6,0
		dc.w	0
save_key	dc.b	0
mbutton		dc.b	0

mcnt		dc.w	0
mx		dc.w	100
my		dc.w	100
save_olpos:
	dc.l	0
currpatt:
	dc.w	0
currposs:
	dc.w	0
currsam:
	dc.w	0
currloop:
	dc.w	0
currvol:
	dc.w	$7f00
currbonus:
	dc.w	$0000
polle:
	dc.w	$0000
minipek:
	dc.w	$3d00
miniminipek:
	dc.w	0
mouse:
	dc.w	$FFFF,$FFFF,$8002,$FFFE
	dc.w	$BFF4,$C00C,$BFE8,$C018
	dc.w	$BFD0,$C030,$BFA0,$C060
	dc.w	$BFA0,$C060,$BFD0,$C030
	dc.w	$BFE8,$C018,$B9F4,$C60C
	dc.w	$B6FA,$CF06,$A97D,$D983
	dc.w	$90BD,$F0C3,$A05D,$E063
	dc.w	$C021,$C03F,$801F,$801F
hex_tab:
	dc.b	$7C,$C6,$CE,$D6,$E6,$C6,$7C,$00
	dc.b	$18,$38,$38,$18,$18,$18,$3C,$00
	dc.b	$7C,$C6,$06,$0C,$18,$70,$FE,$00
	dc.b	$7C,$C6,$06,$0C,$06,$C6,$7C,$00
	dc.b	$1C,$3C,$6C,$CC,$FE,$0C,$0C,$00
	dc.b	$FE,$C0,$FC,$06,$06,$06,$FC,$00
	dc.b	$1C,$30,$60,$FC,$C6,$C6,$7C,$00
	dc.b	$FE,$0C,$18,$78,$60,$C0,$80,$00
	dc.b	$7C,$C6,$7C,$C6,$C6,$C6,$7C,$00
	dc.b	$7C,$C6,$C6,$7E,$0C,$18,$70,$00
	dc.b	$38,$7C,$C6,$FE,$C6,$C6,$C6,$00
	dc.b	$FC,$C6,$FC,$C6,$C6,$C6,$FC,$00
	dc.b	$7E,$C0,$C0,$C0,$C0,$C0,$7E,$00
	dc.b	$FC,$C6,$C6,$C6,$C6,$C6,$FC,$00
	dc.b	$FE,$C0,$F8,$C0,$C0,$C0,$FE,$00
	dc.b	$FE,$C0,$F8,$C0,$C0,$C0,$C0,$00
	even
tone_tab:
	dc.w	$7E00,$C000,$C000,$C03c,$C03c,$C000,$7E00,$0000
	dc.w	$7E6C,$C0FE,$C06C,$C06C,$C06C,$C0FE,$7E6C,$0000
	dc.w	$FC00,$C600,$C600,$C63c,$C63c,$C600,$FC00,$0000
	dc.w	$FC6C,$C6FE,$C66C,$C66C,$C66C,$C6FE,$FC6C,$0000
	dc.w	$FE00,$C000,$F800,$C03c,$C03c,$C000,$FE00,$0000
	dc.w	$FE00,$C000,$F800,$C03c,$C03c,$C000,$C000,$0000
	dc.w	$FE6C,$C0FE,$F86C,$C06C,$C06C,$C0FE,$C06C,$0000
	dc.w	$7C00,$C000,$DC00,$C63c,$C63c,$C600,$7C00,$0000
	dc.w	$7C6C,$C0FE,$DC6C,$C66C,$C66C,$C6FE,$7C6C,$0000
	dc.w	$3800,$7C00,$C600,$FE3c,$C63c,$C600,$C600,$0000
	dc.w	$386C,$7CFE,$C66C,$FE6C,$C66C,$C6FE,$C66C,$0000
	dc.w	%1111110000000000
	dc.w	%1100011000000000
	dc.w	%1111110000000000
	dc.w	%1100011000111100
	dc.w	%1100011000111100
	dc.w	%1100011000000000
	dc.w	%1111110000000000
	dc.w	%0000000000000000

empty_tone:
	dc.w	0,0,0
	dc.w	%0011110000111100
	dc.w	%0011110000111100
	dc.w	0,0,0
freaky_brother:
	ds.w	400
mouse_shifts:
	ds.b	16*16*16
save_buff:
	ds.b	256
dta:
	ds.b	44
tcbsetup:
	dc.b	"TCBSETUP"		
	ds.w	16 *COLORS
	dc.b	0 *line on/off	
	dc.b	0 *globe on/off	
	dc.b	0 *stereo	
	dc.b	0 *other imptab	
	dc.b	0 *mouse	
	ds.b	100 *reserved   
	even
backg:
	incbin	d:\tcbtrk\stpic12.nex
cutt_chann:
	ds.w	64
cutt_chann2:
	ds.w	64
cutt_patt:
	ds.w	64
	ds.w	64
	ds.w	64
	ds.w	64
curr_tunes:
	dc.w	0,0,0,0
start_pattbuff:
	dc.b	"AN COOL." 
curr_nopatt:
	dc.l	0
currspeed:
	dc.w	$0a00
patt_tab:
	ds.b	128	
	even
currres:
	dc.w	0
curr_bass:
	dc.w	0
samnames:
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
	dc.b	"        "
spec_values:
	dc.w	0
	dc.w	10
	dc.w	30
	dc.w	50
	dc.w	70
	dc.w	90
	dc.w	-10
	dc.w	-30
	dc.w	-50
	dc.w	-70
	dc.w	-90
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
	dc.w	0
end_head:
big_patt_buff:
	ds.l	16384
start_buff:
end_b_pek:
	dc.l	end_buff-start_buff
samtab:
	rept	16
	dc.w	$7f00	;vol.b
	dc.w	$0000	;loop.w
	endr
samp_pet_buff:
	dc.l	samp_buff-start_buff	;1
	dc.l	1
	dc.l	samp_buff2-start_buff	;2
	dc.l	1
	dc.l	samp_buff3-start_buff	;3
	dc.l	1
	dc.l	samp_buff4-start_buff	;4
	dc.l	1
	dc.l	samp_buff5-start_buff	;5
	dc.l	1
	dc.l	samp_buff6-start_buff	;6
	dc.l	1
	dc.l	samp_buff7-start_buff	;7
	dc.l	1
	dc.l	samp_buff8-start_buff	;8
	dc.l	1
	dc.l	samp_buff9-start_buff	;9
	dc.l	1
	dc.l	samp_buff10-start_buff	;10
	dc.l	1
	dc.l	samp_buff11-start_buff	;11
	dc.l	1
	dc.l	samp_buff12-start_buff	;12
	dc.l	1
	dc.l	samp_buff13-start_buff	;13
	dc.l	1
	dc.l	samp_buff14-start_buff	;14
	dc.l	1
	dc.l	samp_buff15-start_buff	;15
	dc.l	1
	dc.l	samp_buff16-start_buff	;16
	dc.l	1
	dc.l	samp_buff17-start_buff	;16
	dc.l	1
	dc.l	-1
	dc.l	0
end_head2:
samp_buff	dcb.b	over_buff,128
samp_buff2	dcb.b	1,128
samp_buff3	dcb.b	1,128
samp_buff4	dcb.b	1,128
samp_buff5	dcb.b	1,128
samp_buff6	dcb.b	1,128
samp_buff7	dcb.b	1,128
samp_buff8	dcb.b	1,128
samp_buff9	dcb.b	1,128
samp_buff10	dcb.b	1,128
samp_buff11	dcb.b	1,128
samp_buff12	dcb.b	1,128
samp_buff13	dcb.b	1,128
samp_buff14	dcb.b	1,128
samp_buff15	dcb.b	1,128
samp_buff16	dcb.b	1,128
samp_buff17:
end_buff:
	dcb.b	over_buff,128
	even

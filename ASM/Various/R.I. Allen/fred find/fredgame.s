old_rock	equ		64
colours		equ		$ff8240
acia_con	equ		$fffc00
acia_dat	equ		$fffc02
escape		equ		$1
enter		equ		13
delete		equ		8
return		equ		$1c
z			equ		$2c
x			equ		$2d
quote		equ		$28
slash		equ		$35
space		equ		$39
m			equ		$32
p			equ		$19
d			equ		$20
k			equ		$25
j			equ		$24
l			equ		$26
quit		equ		$10
uarrow		equ		$48
darrow		equ		$50
num_errs	equ		9
			pea		0
			move.w	#$20,-(sp)			; supervisor mode
			trap	#1
			lea		6(sp),sp
			move.l	d0,old_ssp			; save old stack pointer
			lea		end_stack,a7		; point to my stack

* ST or STE ?
			move.b	$ffff820d.w,d0		; low screen reg address
			sub.b	#10,d0				; modify for check
			move.b	d0,$ffff820d.w		; won't program if ST
			cmp.b	$ffff820d.w,d0		; check it
			bne.s	st_machine			; skip if ST
			add.b	#10,d0
			move.b	d0,$ffff820d.w		; restore offset
			move.w	#-1,st_ste			; set STE flag
st_machine

			move.l	#screens+256,d0		; screen start
			and.l	#$ffffff00,d0		; 256 byte boundary
			move.l	d0,scr1				; screen start
			add.l	#38400,d0			; next screen start
			move.l	d0,scr2
			
			move.w	#3,-(sp)			; physbase call
			trap	#14
			lea		2(sp),sp
			move.l	d0,old_scr			; save old screen start
			
			move.w	#4,-(sp)			; get res call
			trap	#14
			lea		2(sp),sp
			move.w	d0,old_res			; save old screen resolution
			
			move.b	#$12,acia_dat		; mouse ints off

			move.w	#0,-(sp)			; low res screen
			move.l	scr2,-(sp)
			move.l	scr2,-(sp)			; screen start address
			move.w	#5,-(sp)			; set res & screen start
			trap	#14
			lea		12(sp),sp
			movem.l	colours,d0-d7
			movem.l	d0-d7,old_pal
			movem.l	d0-d7,color_buff
			jsr		create_fade

			jsr		offset_chars
			jsr		init_load
			
			move.w	#99,d7
start_wait	move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			dbra	d7,start_wait

* don't use d6-d7/a2-a6 from here

			jsr		save_ints				*save interrupts
			jsr		init_ints				*init. interrupts
			clr.w	wfnc
			jsr		fade_out
			jsr		main

			jsr		fade_out

			move.l	old_scr,d1				; restore old screen
			lsr.l	#8,d1
			move.b	d1,$ff8203				; set screen address
			lsr.w	#8,d1
			move.b	d1,$ff8201				; change screen
			movem.l	old_pal,d0-d5
			movem.l	d0-d5,color_buff
			movem.l	old_pal+24,d0-d1
			movem.l	d0-d1,color_buff+24
			jsr		create_fade
			jsr		fade_in
			jsr		ret_ints				*restore interrupts
			
			move.b	#$08,acia_dat		; mouse ints on
			
			movem.l	old_pal,d0-d7
			movem.l	d0-d7,colours

			move.w	old_res,-(sp)		; restore resolution
			move.l	old_scr,-(sp)
			move.l	old_scr,-(sp)		; screen start address
			move.w	#5,-(sp)			; set res & screen start
			trap	#14
			lea		12(sp),sp

			move.l	old_ssp,-(sp)		; back to user mode
			move.w	#$20,-(sp)
			trap	#1
			lea		6(sp),sp

			clr.w	-(sp)
			trap	#1					; end program


************************************************************************
* Replay routine that replays -TCB TRACKER- modules  in normal ST mode *
* Made by Anders Nilsson  10/8/90                                      *
* Uses d6-d7/a2-a6 and usp                                             *
************************************************************************
save_ints:	move.b	$fffffa07.w,mfpa07	*save interrupts
			move.b	$fffffa09.w,mfpa09
			move.b	$fffffa13.w,mfpa13
			move.b	$fffffa15.w,mfpa15
			move.b	$fffffa19.w,mfpa19
			move.b	$fffffa1f.w,mfpa1f
			move.l	$118,oldkey
			move.l	$134,old134
			move.l	$120,oldhbl
			move.l	$70.w,oldvbl
			rts
init_ints:	move.b	#64,$fffffa09.w		*init interrupts
			move.b	#64,$fffffa15.w
			move.b	#2,$fffffa19.w
			move.b	#1,$fffffa07.w		; timer b on
			move.b	#1,$fffffa13.w		; timer b on
			bclr	#3,$fffffa17.w
			move.l	#hsync,$120.w
			move.l	#vbi,$70.w
			move.l	#keyvec,$118
			rts
ret_ints:	move.b	mfpa07,$fffffa07.w	*restore interrupts
			move.b	mfpa09,$fffffa09.w
			move.b	mfpa13,$fffffa13.w
			move.b	mfpa15,$fffffa15.w
			move.b	mfpa19,$fffffa19.w
			move.b	mfpa1f,$fffffa1f.w
			move.l	old134,$134
			move.l	oldhbl,$120
			move.l	oldvbl,$70.w
			move.l	oldkey,$118
			rts

main:		jsr		calc_codes
			jsr		setup_menu
			move.w	#2,hilight			; need to display
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block
			lea		cont_char,a0
			jsr		print_text
			jsr		hi_light
			jsr		vsync_wait
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block			
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		copy_map
			movem.l	char_cols,d0-d5
			movem.l	d0-d5,color_buff
			movem.l	char_cols+24,d0-d1
			movem.l	d0-d1,color_buff+24
			jsr		create_fade
			jsr		fade_in

demo_loop:	jsr		vsync_wait
			jsr		main_scroll
			jsr		plot_scroll
			jsr		check_keys
* your routines here..... remember d0-d5/a0-a1 !!!!!!
			jsr		dhi_light
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		random
			tst.w	exit				
			beq.s	demo_loop				*yes/no
* now you're back to normal
			rts

vbi:		move.w	#1,wfnc					*set video flag
			move.b	#0,$fffffa1b.w			; timer b off
			move.b	#195,$fffffa21.w		; inturupt on line 198
			move.b	#8,$fffffa1b.w			; timer b on
			bset	#0,$fffffa07.w			; clear interupt flag
			move.w	flash,colours
			rte

vsync_wait	clr.w	wfnc
			movem.l	scr1,d0-d1				; swap screen starts
			exg		d0,d1
			movem.l	d0-d1,scr1
			lsr.l	#8,d1
			move.b	d1,$ff8203				; set screen address
			lsr.w	#8,d1
			move.b	d1,$ff8201				; change screen
vwait		cmp.w	#1,wfnc					; wait for video
			bne.s	vwait
			rts

vsync_wait2	
vwait2		cmp.w	#2,wfnc					; wait for video
			bne.s	vwait2
vwait3		cmp.w	#1,wfnc
			bne.s	vwait3
			rts

vsync_game	cmp.w	#1,wfnc
			bne.s	vsync_game
vg0000		cmp.w	#2,wfnc
			bne.s	vg0000
			movem.l	scr1,d0-d1				; swap screen starts
			exg		d0,d1
			movem.l	d0-d1,scr1
			lsr.l	#8,d1
			move.b	d1,$ff8203				; set screen address
			lsr.w	#8,d1
			move.b	d1,$ff8201				; change screen
			move.w	#$0000,d0				; assume black background
			move.w	game_time+2,d1			; get the current time
			cmp.w	#7*32,game_time+2		; time low ?
			bge.s	vg0010					; skip if not
			and.w	#$c,d1					; flash white ?
			bne.s	vg0010
			move.w	game_time+2,d1			; get the current time
			and.w	#$03,d1					; do a sound ?
			bne.s	vg0005
			nop
			
vg0005		move.w	#$333,d0
			tst.w	st_ste					; change for ste
			bpl.s	vg0010					; skip if st
			move.w	#$666,d0
vg0010		move.w	d0,flash
vg0020		tst.w	wfnc
			beq.s	vg0020
			rts

*************************************
*          HSync routine            *
*************************************


hsync		move	#$2700,sr			; interupts off
			movem.l	d0-d1/a0,-(sp)

			lea		$ff8207,a0
			move.b	$ff8203,d0
			add.w	#124,d0
			move.w	#55,d1
.lp1		subq.w	#1,d1
			beq.s	lp_quit
			cmp.b	(a0),d0
			bne.s	.lp1
lp_quit		lea		2(a0),a0

.lp2		tst.b	(a0)
			bne.s	.lp2
			move.b	(a0),d0
			lsr.w	d0,d0

			dcb.w	7,$4e71

			clr.b	$ffff820a.w
			dcb.w	10,$4e71
			move.b	#2,$ffff820a.w
		
			movem.l	(sp)+,d0-d1/a0
			bclr	#0,$fffffa0f.w		; clear int service flag
			bclr	#0,$fffffa07.w		; disable timer b ints
			move.w	#2,wfnc
			rte

**************************************************
* A version of Motleys keyboard interupt routine *
* Modified by Zaborak for his own needs          *
**************************************************
keyvec		movem.l	d0/d1/a0,-(sp)		; save registers used
re_check	lea		acia_con,a0			; point to keyboad acia
			move.b	(a0),d0				; get the control status
			move.b	d0,acia_stat		; save a copy of it
			btst	#7,d0				; interupt enabled ?
			beq		key_exit			; exit if not
			btst	#0,d0				; correct mode ?
			beq		key_exit			; exit if not
			move.b	2(a0),d1			; get the pending character
			tst.b	activity			; assembling a packet ?
			bmi.s	new_code			; skip if were not
			move.l	act_pntr,a0			; points to packet build-up
			move.b	d1,(a0)+			; add to the packet
			subq.b	#1,activity			; count the byte loaded
			bpl.s	more_data			; skip if packet in-complete
			move.l	a1,-(sp)			; save another register
			move.l	pkt_dest,a0			; where to put the data
			lea		build_pkt,a1		; the one we have just made
			clr.w	d0					; for loop
			move.b	build_len,d0		; number of bytes in packet
copy_pkt	move.b	(a1)+,(a0)+			; copy a byte at a time
			dbra	d0,copy_pkt			; copy out completed packet
			move.l	(sp)+,a1			; recover reg
			lea		build_pkt,a0		; reset build pointer
more_data	move.l	a0,act_pntr			; save the new pointer
			bra		key_exit			; exit, all done
new_code	cmp.b	#$f6,d1				; key scan code ?
			blo		key_code			; skip if it is
			lea		build_pkt,a0		; store code
			move.b	d1,(a0)+			; save the character
			move.l	a0,act_pntr			; save the packet pointer
			and.w	#$0f,d1				; to workout packet length
			subq.w	#6,d1				; normalise
			move.b	acia_len(pc,d1.w),d0; get the packet length
			move.b	d0,build_len		; save the build length
			subq.w	#1,d0				; count the first character
			move.b	d0,activity			; save for packet build-up
			lsl.w	#2,d1				; for long word offset
			move.l	acia_len+10(pc,d1),pkt_dest	; where to put finished packet
			bra		key_exit			; all done
acia_len	dc.b	7,5,2,2,2,2,6,2,1,1	; codes $f6 - $ff
			dc.l	misc_pkt
			dc.l	misc_pkt
			dc.l	mouse_pkt
			dc.l	mouse_pkt
			dc.l	mouse_pkt
			dc.l	mouse_pkt
			dc.l	misc_pkt
			dc.l	misc_pkt
			dc.l	stick0_pkt
			dc.l	stick1_pkt
key_code	cmp.b	#$80,d1				; pressed or released a key ?
			blo.s	pressed
released	lea		keys,a0				; key table data
			and.w	#$007f,d1			; limit range
			clr.b	(a0,d1.w)
			bra.s	key_exit			; all done
pressed		lea		keys,a0				; key table data
			and.w	#$00ff,d1			; limit range
			move.b	#1,(a0,d1.w)
			lea		letters,a0			; convert to asci
			move.b	(a0,d1.w),key_press	; save in buffer
key_exit	and.b	#$20,acia_stat		; ACIA error ?
			beq.s	no_error			; skip if not
			move.b	acia_dat,d0			; clear ACIA error
no_error	btst	#4,$fffffa01.w		; all finished ?
			beq		re_check			; loop if not
			bclr	#6,$fffffa11.w		; clear the int pending flag
			movem.l	(sp)+,d0/d1/a0		; recover registers
			rte
			
* print string routine.
* pointer to text supplied in a0, 1st byte is x start,2nd byte is
* y start. String terminated by null byte. No end of line wrap.
* writes to background screen and the hidden screen being updated.

print_text	move.l	scr1,a1			; screen start
			clr.w	d0				; x location
			clr.w	d1				; y location
			move.b	(a0)+,d0
			move.b	(a0)+,d1		; get print co-ords
			and.w	#$fffe,d0		; clear lsb
			lsl.w	#2,d0			; effective * 8
			mulu.w	#1280,d1		; y offset 8*160 per line down
			add.w	d0,d1			; total offset
			add.l	d1,a1			; make screen pointer
			clr.w	d0
			move.b	-2(a0),d0		; x location
			move.l	a0,-(sp)
pt010		move.l	(sp)+,a0
			clr.w	d1				; character buildup
			move.b	(a0)+,d1		; get a character 
			beq.s	pt_end			; exit if no more text
			move.l	a0,-(sp)
			lea		font,a0			; font start
			sub.b	#' ',d1			; normalise it
			lsl.w	#5,d1			; *32 to make character offset
			add.w	d1,a0			; pointer to character
			btst	#0,d0			; get odd/even bit in carry flag
			bne.s	pt020			; skip if in odd position
			jsr		plot_even		; plot the even character
			addq.w	#1,d0			; next x position
			bra.s	pt010			; and loop
pt020		jsr		plot_odd		; plot in odd position
			addq.w	#1,d0			; next x location
			bra.s	pt010			; and loop
pt_end		rts						; return,all done
print_icons	move.l	scr1,a1			; screen start
			clr.w	d0				; x location
			clr.w	d1				; y location
			move.b	(a0)+,d0
			move.b	(a0)+,d1		; get print co-ords
			and.w	#$fffe,d0		; clear lsb
			lsl.w	#2,d0			; effective * 8
			mulu.w	#1280,d1		; y offset 8*160 per line down
			add.w	d0,d1			; total offset
			add.l	d1,a1			; make screen pointer
			clr.w	d0
			move.b	-2(a0),d0		; x location
			move.l	a0,-(sp)
pi010		move.l	(sp)+,a0
			clr.w	d1				; character buildup
			move.b	(a0)+,d1		; get a character 
			cmp.b	#$ff,d1			; end of string ?
			beq.s	pi_end			; exit if no more icons
			cmp.b	#cursor,d1		; is it the cursor ?
			bne.s	pi015			; skip if not
			move.b	#cage,d1		; change to cage
pi015		move.l	a0,-(sp)
			lea		icons,a0		; icons start
			lsl.w	#5,d1			; *32 to make character offset
			add.w	d1,a0			; pointer to character
			btst	#0,d0			; get odd/even bit in carry flag
			bne.s	pi020			; skip if in odd position
			jsr		plot_even		; plot the even character
			addq.w	#1,d0			; next x position
			bra.s	pi010			; and loop
pi020		jsr		plot_odd		; plot in odd position
			addq.w	#1,d0			; next x location
			bra.s	pi010			; and loop
pi_end		rts						; return,all done

plot_even	movem.l	(a0)+,d1-d4
			movep.l	d1,(a1)
			movep.l	d2,160(a1)
			movep.l	d3,320(a1)
			movep.l	d4,480(a1)
			movem.l	(a0)+,d1-d4
			movep.l	d1,640(a1)
			movep.l	d2,800(a1)
			movep.l	d3,960(a1)
			movep.l	d4,1120(a1)
			rts						; return, all done

plot_odd	movem.l	(a0)+,d1-d4
			movep.l	d1,1(a1)
			movep.l	d2,161(a1)
			movep.l	d3,321(a1)
			movep.l	d4,481(a1)
			movem.l	(a0)+,d1-d4
			movep.l	d1,641(a1)
			movep.l	d2,801(a1)
			movep.l	d3,961(a1)
			movep.l	d4,1121(a1)
			lea		8(a1),a1
			rts
			
* call with pointer to block look up table in a1.
* 1st long word contains no of lines to be plotted
plot_block	move.l	(a1)+,d5			; number of lines to dbra+1
			subq.w	#1,d5
pb000		move.l	(a1)+,a0			; line pointer
			move.l	a1,-(sp)
			jsr		print_text			; print the line of text
			move.l	(sp)+,a1
			dbra	d5,pb000			; do them all
			rts

create_fade	lea		fade_data,a0		; point to fade data
			lea		fade_data+32,a1		; fade data
			movem.l	color_buff,d0-d5
			movem.l	d0-d5,(a0)			; level 1 data
			movem.l	color_buff+24,d0-d1
			movem.l	d0-d1,24(a0)
			move.w	#14,d5				; 15 levels to fade
cf000		move.w	#15,d4				; 16 colours to fade
cf005		move.w	#2,d3				; red,green & blue levels
			move.w	#$f00,d2
			move.w	#$100,d1			; modify amount
			clr.w	(a1)
cf010		move.w	(a0),d0				; get a colour
			and.w	d2,d0				; make colour level
			tst.w	d0					; level to modify ?
			beq.s	cf020				; skip if not
			sub.w	d1,d0				; modify colour level
cf020		or.w	d0,(a1)				; setup the data
			lsr.w	#4,d2				; move mask to next colour
			lsr.w	#4,d1				; move modify amount
			dbra	d3,cf010			; do all 3 colour levels
			lea		2(a0),a0			; next colour
			lea		2(a1),a1			; next colour in buffer
			dbra	d4,cf005			; do all 16 colours
			dbra	d5,cf000			; do all 7 fade levels
			rts
			
fade_out	lea		fade_data,a0		; point to fade data
			move.w	#15,d5
fo000		move.w	d5,-(sp)
			jsr		vsync_wait2
			movem.l	(a0)+,d0-d5		; colour data
			tst.w	st_ste
			bmi		fo010
			lsr.l	d0
			lsr.l	d1
			lsr.l	d2
			lsr.l	d3
			lsr.l	d4
			lsr.l	d5
			and.l	#$07770777,d0
			and.l	#$07770777,d1
			and.l	#$07770777,d2
			and.l	#$07770777,d3
			and.l	#$07770777,d4
			and.l	#$07770777,d5
fo010		movem.l	d0-d5,colours	; install
			swap	d0
			move.w	d0,flash
			movem.l	(a0)+,d0-d1		; colour data
			tst.w	st_ste
			bmi		fo020
			lsr.l	d0
			lsr.l	d1
			and.l	#$07770777,d0
			and.l	#$07770777,d1
fo020		movem.l	d0-d1,colours+24
			move.w	(sp)+,d5
			dbra	d5,fo000
			clr.w	flash
			rts

fade_out2	lea		fade_data,a0		; point to fade data
			move.w	#15,d5
fo0002		move.w	d5,-(sp)
			move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			movem.l	(a0)+,d0-d5		; colour data
			tst.w	st_ste
			bmi		fo0102
			lsr.l	d0
			lsr.l	d1
			lsr.l	d2
			lsr.l	d3
			lsr.l	d4
			lsr.l	d5
			and.l	#$07770777,d0
			and.l	#$07770777,d1
			and.l	#$07770777,d2
			and.l	#$07770777,d3
			and.l	#$07770777,d4
			and.l	#$07770777,d5
fo0102		movem.l	d0-d5,colours	; install
			swap	d0
			move.w	d0,flash
			movem.l	(a0)+,d0-d1		; colour data
			tst.w	st_ste
			bmi		fo0202
			lsr.l	d0
			lsr.l	d1
			and.l	#$07770777,d0
			and.l	#$07770777,d1
fo0202		movem.l	d0-d1,colours+24
			move.w	(sp)+,d5
			dbra	d5,fo0002
			clr.w	flash
			rts
			
fade_in		lea		fade_data+15*32,a0	; bottom of table
			move.w	#15,d5
fi000		move.w	d5,-(sp)
			jsr		vsync_wait2
			movem.l	(a0),d0-d5		; colour data
			tst.w	st_ste
			bmi		fi010
			lsr.l	d0
			lsr.l	d1
			lsr.l	d2
			lsr.l	d3
			lsr.l	d4
			lsr.l	d5
			and.l	#$07770777,d0
			and.l	#$07770777,d1
			and.l	#$07770777,d2
			and.l	#$07770777,d3
			and.l	#$07770777,d4
			and.l	#$07770777,d5
fi010		movem.l	d0-d5,colours		; install
			swap	d0
			move.w	d0,flash
			movem.l	24(a0),d0-d1		; colour data
			tst.w	st_ste
			bmi		fi020
			lsr.l	d0
			lsr.l	d1
			and.l	#$07770777,d0
			and.l	#$07770777,d1
fi020		movem.l	d0-d1,colours+24
			lea		-32(a0),a0			; next set of colours
			move.w	(sp)+,d5
			dbra	d5,fi000
			clr.w	flash
			rts

fade_in2	lea		fade_data+15*32,a0	; bottom of table
			move.w	#15,d5
fi0002		move.w	d5,-(sp)
			move.l	a0,-(sp)
			move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			move.l	(sp)+,a0
			movem.l	(a0),d0-d5		; colour data
			tst.w	st_ste
			bmi		fi0102
			lsr.l	d0
			lsr.l	d1
			lsr.l	d2
			lsr.l	d3
			lsr.l	d4
			lsr.l	d5
			and.l	#$07770777,d0
			and.l	#$07770777,d1
			and.l	#$07770777,d2
			and.l	#$07770777,d3
			and.l	#$07770777,d4
			and.l	#$07770777,d5
fi0102		movem.l	d0-d5,colours		; install
			swap	d0
			move.w	d0,flash
			movem.l	24(a0),d0-d1		; colour data
			tst.w	st_ste
			bmi		fi0202
			lsr.l	d0
			lsr.l	d1
			and.l	#$07770777,d0
			and.l	#$07770777,d1
fi0202		movem.l	d0-d1,colours+24
			lea		-32(a0),a0			; next set of colours
			move.w	(sp)+,d5
			dbra	d5,fi0002
			clr.w	flash
			rts

main_scroll	tst.w	scrolling			; moving the letters ?
			bne		move_lets			; skip if we are
			subq.w	#1,scroll_up		; time for an update ?
			bmi.s	ms000				; skip if it is
			rts
ms000		move.w	#250,scroll_up		; reset counter
			move.w	#38,scrolling		; set move letter flag
			clr.w	s_offset
			move.l	s1_lpntr,a0			; next in list
			move.l	(a0)+,d0			; new pntr
			bne.s	ms010				; skip if ok
			lea		s1_list,a0			; reset pntr
			move.l	(a0)+,d0			; new pntr
ms010		move.l	d0,s1_pntr			; update the pointer
			move.l	a0,s1_lpntr
			move.l	s2_lpntr,a0			; next in list
			move.l	(a0)+,d0			; new pntr
			bne.s	ms020				; skip if ok
			lea		s2_list,a0			; reset pntr
			move.l	(a0)+,d0			; new pntr
ms020		move.l	d0,s2_pntr			; update the pointer
			move.l	a0,s2_lpntr
			move.l	s3_lpntr,a0			; next in list
			move.l	(a0)+,d0			; new pntr
			bne.s	ms030				; skip if ok
			lea		s3_list,a0			; reset pntr
			move.l	(a0)+,d0			; new pntr
ms030		move.l	d0,s3_pntr			; update the pointer
			move.l	a0,s3_lpntr
			move.l	s4_lpntr,a0			; next in list
			move.l	(a0)+,d0			; new pntr
			bne.s	ms040				; skip if ok
			lea		s4_list,a0			; reset pntr
			move.l	(a0)+,d0			; new pntr
ms040		move.l	d0,s4_pntr			; update the pointer
			move.l	a0,s4_lpntr
*
move_lets	lea		i9+3,a0				; menu text structure
			move.l	s1_pntr,a1			; text pointer
			jsr		scroll_it
			lea		ib+3,a0				; menu text structure
			move.l	s2_pntr,a1			; text pointer
			jsr		scroll_it
			lea		id+3,a0				; menu text structure
			move.l	s3_pntr,a1			; text pointer
			jsr		scroll_it
			lea		if+3,a0				; menu text structure
			move.l	s4_pntr,a1			; text pointer
			jsr		scroll_it
			addq.w	#1,s_offset
			subq.w	#1,scrolling
			rts

plot_scroll	lea		scr_lu,a1			; scroller update
			jsr		plot_block
			rts

scroll_it	move.w	#36,d5
sci000		move.b	1(a0),(a0)			; scroll one letter
			lea		1(a0),a0
			dbra	d5,sci000
			add.w	s_offset,a1			; letter to insert
			move.b	(a1),(a0)			; new letter
			rts

check_keys	lea		keys,a0				; key table
			tst.b	quit(a0)			; quit key ?
			beq.s	ck0000				; skip if not
			move.w	#1,exit				; signal exit
			rts
ck0000		tst.b	m(a0)				; M key ?
			beq		ck0010				; skip if not
			cmp.w	#5,start			; maps f-g ?
			bge.s	ck0010				; skip if not allowed to view
			move.w	start,map
			jsr		copy_map
			jsr		view_map			; else do display
			move.w	#2,hilight			; need to display
			jsr		setup_menu
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		vsync_wait
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block			
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		fade_in
			rts
ck0010		tst.b	space(a0)			; play the game ?
			bne.s	ck0015				; skip if we do
			tst.b	controls			; using joystick ?
			beq.s	ck0020				; exit if not
			btst.b	#7,stick1_pkt+1		; pressed button ?
			beq.s	ck0020				; skip if not
ck0015		move.w	start,map
			jsr		play_game
			rts
ck0020		tst.b	d(a0)				; setup user keys ?
			beq.s	ck0030				; skip if not
			jsr		user_keys
			lea		menu_lu,a1			; main menu look up
			move.w	#2,hilight
			jsr		plot_block
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		vsync_wait
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block			
			lea		cont_char,a0
			jsr		print_text
			jsr		hi_light
			jsr		fade_in
			rts
ck0030		tst.b	uarrow(a0)			; change start map ?
			beq.s	ck0060				; skip if not
			tst.w	start				; map A already ?
			beq.s	ck0060				; skip if it is
			tst.w	key_delay			; time for a repeat ?
			bne.s	ck0055				; skip if not
*
* Find the first valid before the current map
*
			lea		pass_disp,a1		; valid password structure
			add.w	start,a1			; current selected map
			move.w	#-1,d5				; number above current
			add.w	start,d5			; make dbra loop value
			move.w	start,ostart		; for hilight routine
			subq.w	#1,start			; new password number
			lea		-1(a1),a1			; password before data
ck0040		tst.b	(a1)				; found a valid password ?
			bne.s	ck0050				; skip if we have
			lea		-1(a1),a1			; next one in table
			subq.w	#1,start			; next password number
			dbra	d5,ck0040			; find the correct one
ck0050		move.w	#2,hilight			; hilight routine active
			move.w	#11,key_delay		; auto key repeat counter
ck0055		subq.w	#1,key_delay		; count a 50th / sec
			rts
ck0060		tst.w	darrow(a0)			; increase map ?
			beq.s	ck0090				; skip if not
			cmp.w	#7,start			; map H already ?
			bge.s	ck0090				; skip if it is
			tst.w	key_delay
			bne.s	ck0055
*
* find the first valid password below the current one
*
			lea		pass_disp,a1		; password valid data
			add.w	start,a1			; current selected password
			move.w	#6,d5
			sub.w	start,d5			; dbra count
			move.w	start,ostart		; for hilight plotting
			lea		1(a1),a1			; first one to search
			addq.w	#1,start			; next password number
ck0070		tst.b	(a1)				; found a valid password ?
			bne.s	ck0080				; skip if we have
			lea		1(a1),a1			; next password to check
			addq.w	#1,start			; next password number
			dbra	d5,ck0070			; find the correct one
*
* if we get here then there are no valid passwords
*
			move.w	ostart,start		; restore current position
			rts
ck0080		move.w	#10,key_delay		; auto key repeat counter
			move.w	#2,hilight			; hilight routine active
			rts

ck0090		tst.b	p(a0)				; enter password ?
			beq.s	ck0100				; skip if not
			jsr		enter_pass
			move.w	#2,hilight			; need to display
			jsr		setup_menu
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		vsync_wait
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block			
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		fade_in
			rts
			
ck0100		tst.b	j(a0)				; selecting joystick control ?
			beq.s	ck0110				; skip if not
			tst.b	controls
			bne.s	ck0110
			move.b	#1,controls			; signal joystick control
			move.b	#'J',cont_char+2
			rts
ck0110		tst.b	k(a0)				; selecting keyboard control ?
			beq.s	ck0120
			tst.b	controls
			beq.s	ck0120
			clr.b	controls			; signal keyboard control
			move.b	#'K',cont_char+2
			rts
ck0120		tst.b	l(a0)				; load a map file ?
			beq.s	ck0130				; skip if not
			jsr		file_selector
			move.w	#2,hilight
			jsr		setup_menu
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		vsync_wait
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block			
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		fade_in
			rts
ck0130		clr.w	key_delay
			rts

user_keys	jsr		fade_out
			lea		keys_scr,a1
			jsr		plot_block
			jsr		vsync_wait
			lea		keys_scr,a1
			jsr		plot_block
			jsr		fade_in
uk0000		jsr		vsync_wait
			lea		keys,a0
			tst.b	space(a0)			; program the keys
			bne.s	uk0010				; skip if so
			tst.b	escape(a0)
			beq.s	uk0000
			jsr		fade_out
			rts
* erase the old key letters
uk0010		
			lea		key_pntrs,a0		; line pointers
			move.w	#5,d5				; 6 lines to erase
uk0020		move.l	(a0)+,a1			; get the pointer
			lea		23(a1),a1			; text start area
			move.w	#8,d4				; 9 character per line
uk0030		move.b	#' ',(a1)+			; change text to a space
			dbra	d4,uk0030
			dbra	d5,uk0020			; erase all the keys
			clr.w	left				; clear all the key codes
			clr.w	right
			clr.w	up
			clr.w	down
			clr.w	vmap
			clr.w	vstatus
			lea		keys_scr,a1
			jsr		plot_block
			jsr		vsync_wait
			lea		keys_scr,a1
			jsr		plot_block
* make sure space is unpressed
uk0040		tst.b	keys+space			; space still pressed ?
			bne.s	uk0040
			move.w	#5,d5				; 6 keys to program
			lea		left,a1				; point to define data
uk0045		lea		keys,a0				; key data
uk0050		move.w	#126,d4				; check all the key positions
uk0060		tst.b	(a0)+				; key pressed ?
			bne.s	uk0070				; check if it is
uk0065		dbra	d4,uk0060			; check them all
			lea		keys,a0				; reset the keys pointer
			bra.s	uk0050				; check until a key is pressed
uk0070		move.w	#126,d3				; make key number
			sub.w	d4,d3				; made key number
			cmp.w	left,d3				; already used ?
			beq.s	uk0065				; loop if it is
			cmp.w	right,d3
			beq.s	uk0065
			cmp.w	up,d3
			beq.s	uk0065
			cmp.w	down,d3
			beq.s	uk0065
			cmp.w	vstatus,d3
			beq.s	uk0065
			cmp.w	vmap,d3
			beq.s	uk0065
			cmp.w	#escape,d3			; not allowed escape
			beq.s	uk0065
* unused key
			move.w	d3,(a1)+			; store in buffer
			movem.l	d5/a1,-(sp)
			lea		key_pntrs,a0		; look up table
			move.w	#5,d0				; make key number
			sub.w	d5,d0				; made it
			lsl.w	#2,d0				; l_word offset
			move.l	(a0,d0.w),a0		; text pointer
			lea		key_text,a1			; for key description
			mulu.w	#9,d3				; make the offset
			add.w	d3,a1				; description pointer
			move.b	(a1)+,23(a0)		; 1st letter
			move.b	(a1)+,24(a0)
			move.b	(a1)+,25(a0)
			move.b	(a1)+,26(a0)
			move.b	(a1)+,27(a0)
			move.b	(a1)+,28(a0)
			move.b	(a1)+,29(a0)
			move.b	(a1)+,30(a0)
			move.b	(a1)+,31(a0)
			move.l	a0,-(sp)
			jsr		print_text			; print it
			jsr		vsync_wait
			move.l	(sp)+,a0
			jsr		print_text
			movem.l	(sp)+,d5/a1			; recover pointers
			dbra	d5,uk0045			; do the next key
			bra		uk0000
			
view_map	jsr		rep_in
			move.b	#'A',d0				; map letter
			add.w	map,d0				; map letter to plot
			move.b	d0,dm1+23			; insert into display
			jsr		fade_out
			lea		map_lu,a1
			jsr		plot_block
			jsr		plot_map
			jsr		vsync_wait
			lea		map_lu,a1
			jsr		plot_block
			jsr		plot_map
			jsr		fade_in
dm0000		lea		keys,a0				; point to key data
			tst.b	space(a0)			; space pressed ?
			bne.s	dm0010				; exit if pressed
			btst.b	#7,stick1_pkt+1		; pressed button ?
			beq.s	dm0000				; loop if not
dm0010		
			jsr		fade_out
			jsr		rep_out
			rts
			
enter_pass	jsr		fade_out
			lea		pass_scr,a1
			jsr		plot_block
			lea		pass_text,a0			; line of text
			jsr		print_text				; print it			
			jsr		vsync_wait
			lea		pass_scr,a1
			jsr		plot_block
			lea		pass_text,a0			; line of text
			jsr		print_text				; print it			
			jsr		vsync_wait
			jsr		fade_in
			clr.b	key_press
ep0000		jsr		vsync_wait		
			jsr		build_pass				; build the password
			lea		pass_text,a0			; line of text
			jsr		print_text				; print it			
			
			tst.w	exit
			beq.s	ep0000
			clr.w	exit
			jsr		fade_out
			rts	
			
build_pass	move.b	key_press,d0			; get a character
			bne.s	bp0000					; skip if we have got one
			bra		pass_do					; flash the cursor
			rts
bp0000		clr.b	key_press				; erase from buffer
			cmp.b	#delete,d0				; pressed delete ?
			beq		pass_del				; skip if we have
			cmp.b	#enter,d0				; pressed enter ?
			beq		pass_enter				; skip if we have
			cmp.b	#escape,d0				; pressed escape ?
			beq		pass_escape
* must be a letter
			cmp.w	#8,pass_pos				; space for another ?
			blo.s	bp0010					; skip if there is
			rts
bp0010		
			lea		pass_text+2,a0			; build area
			move.w	pass_pos,d1				; offset into display
			move.b	d0,(a0,d1.w)			; insert character
			addq.w	#1,pass_pos				; move the cursor along
			move.w	#25,pass_flash			; reset flash counter
			clr.w	pon_off					; turn the cursor on
pass_do		subq.w	#1,pass_flash			; change the cursor ?
			bne.s	bp0020					; skip if not
			move.w	#25,pass_flash			; reset the counter
			not.w	pon_off					; invert the cursor
bp0020		lea		pass_text+2,a0			; password data			
			move.w	pass_pos,d0				; offset into password
			move.b	#'*',(a0,d0.w)			; assume cursor on
			tst.w	pon_off					; cursor on ?
			beq.s	bp0030					; skip if it is
			move.b	#' ',(a0,d0.w)			; else it's off
bp0030		rts

pass_del	tst.w	pass_pos				; characters to delete ?
			bne.s	bp0040					; skip if there is
			rts
bp0040		
			subq.w	#1,pass_pos				; move the cursor
			clr.w	pon_off					; cursor on
			move.w	#25,pass_flash			; reset timer
			lea		pass_text+2,a0			; diaply area
			move.w	pass_pos,d0				; offset
			move.b	#' ',(a0,d0.w)			; erase old character
			move.b	#' ',1(a0,d0.w)			; erase possible cursor
			bra.s	bp0020					; do flash stuff
pass_enter	
			lea		pass_text+2,a0			; password text
			move.w	pass_pos,d0				; cusor position
			move.b	#' ',(a0,d0.w)			; erase possible password
			lea		maps+688*8,a1			; password data
			move.w	#7,d5					; 8 to search
pe0000		move.w	#7,d4					; 8 characters per password
pe0010		move.b	(a0)+,d0				; get a character
			cmp.b	(a1)+,d0				; is it correct ?
			bne.s	pe0020					; exit if not
			dbra	d4,pe0010				; check the whole password
* if we get here then the password is correct
			move.w	#7,d0					; make password number
			sub.w	d5,d0					; password number
			lea		pass_disp,a0			; display data
			move.b	#1,(a0,d0.w)			; set display flag
			move.w	#1,exit					; signal exit
			clr.w	pass_pos				; reset offset
			lea		pass_text+2,a0
			rept	8
			move.b	#' ',(a0)+				; clear away the password
			endr
			move.w	#25,pass_flash
			clr.w	pon_off
			rts
pe0020		add.w	d4,a1					; next password start
			lea		pass_text+2,a0			; reset pointer
			dbra	d5,pe0000				; check them all
			rts								; no match, exit

pass_escape	
			move.w	#1,exit
			rts
			
plot_map	lea		play_map+34*3+3,a1		; pointer to map data
			move.w	#23,d5					; 24 lines of icons
			move.w	#2,d4					; y start line
pm0000		lea		icon_line,a0			; area for icon print
			move.b	d4,1(a0)				; set y value
			lea		2(a0),a0
			move.w	#27,d3					; 28 chars per line
pm0010		move.b	(a1)+,(a0)+
			dbra	d3,pm0010
			lea		-30(a0),a0
			lea		-28(a1),a1
			movem.l	d4-d5/a1,-(sp)			; save registers
			jsr		print_icons				; print the icons
			movem.l	(sp)+,d4-d5/a1
			lea		34(a1),a1				; next line of icons
			addq.w	#1,d4					; next screen line
			dbra	d5,pm0000				; do all the lines
			rts			
			
copy_map	move.w	map,d0					; map number to copy
			mulu.w	#688,d0					; make the offset
			lea		maps,a0					; maps start address
			add.w	d0,a0					; make the pointer
			lea		play_map+34*3+3,a1		; empty part
			move.l	672(a0),play_tran		; transporter data
			move.l	676(a0),play_tran+4		; transporter data
			move.l	680(a0),play_tran+8		; transporter data
			move.l	684(a0),play_tran+12	; transporter data
			move.w	#23,d5					; 24 lines to copy
cm0000		move.w	#27,d4					; 28 per line
cm0010		move.b	(a0)+,(a1)+				; copy a line
			dbra	d4,cm0010
			lea		6(a1),a1				; apply necessary offset
			dbra	d5,cm0000				; do all the lines
			lea		maps+5568,a0			; time data
			add.w	map,a0
			add.w	map,a0					; points to time data
			move.w	(a0),reset_time+2
			move.w	(a0),game_time+2
*
* find and initialise all the spirits
* find and initalise repton
*
			move.w	#12,man_x				; default start
			move.w	#12,man_y
			lea		play_map+34*3+3,a1		; empty part
			lea		play_spir,a0			; spirit structure
			clr.w	spirits					; number of spirits in map
			move.w	#3,d0					; start x position
			move.w	#3,d1					; start y position
cm0020		cmp.b	#spirit1,(a1)			; found a spirit ?
			bne.s	cm0030					; skip if not
			lsl.w	#2,d0
			lsl.w	#2,d1
			move.w	d0,(a0)+				; save x start position
			move.w	d1,(a0)+				; save y start pos.
			clr.w	(a0)+					; assume start north
			clr.b	(a1)					; erase spirit from map
			addq.w	#1,spirits				; count the spirit
			lsr.w	#2,d0
			lsr.w	#2,d1
cm0030		cmp.b	#repton,(a1)			; found repton ?
			bne.s	cm0040					; skip if not
			lsl.w	#2,d0
			lsl.w	#2,d1
			movem.w	d0-d1,man_x				; set repton start co-ords
			movem.w	d0-d1,new_start
			lsr.w	#2,d0
			lsr.w	#2,d1
			clr.b	(a1)					; erase him from map
cm0040		lea		1(a1),a1				; next x position
			addq.w	#1,d0					; adjust x pos offset
			cmp.w	#31,d0					; end of a line ?
			ble.s	cm0020					; loop if not			
			move.w	#3,d0					; reset x position
			lea		5(a1),a1				; offset to next line of data
			addq.w	#1,d1					; next y position
			cmp.w	#27,d1					; done all the lines ?
			ble.s	cm0020					; do all the lines
*
* Find and initialise all the eggs
*
			lea		play_map+34*3+3,a1		; empty part
			lea		play_eggs,a0			; monster structure
			clr.l	monsters				; number of monsters in map
			move.w	#3,d0					; start x position
			move.w	#3,d1					; start y position
cm0050		cmp.b	#egg,(a1)				; found an egg ?
			bne.s	cm0060					; skip if not
			lsl.w	#2,d0
			lsl.w	#2,d1
			move.w	d0,(a0)+				; save x start position
			move.w	d1,(a0)+				; save y start pos.
			clr.w	(a0)+					; start as still
			addq.l	#1,monsters				; count the monster
			lsr.w	#2,d0
			lsr.w	#2,d1
cm0060		lea		1(a1),a1				; next x position
			addq.w	#1,d0					; adjust x pos offset
			cmp.w	#31,d0					; end of a line ?
			blo.s	cm0050					; loop if not			
			move.w	#3,d0					; reset x position
			lea		6(a1),a1				; offset to next line of data
			addq.w	#1,d1					; next y position
			cmp.w	#27,d1					; done all the lines ?
			ble.s	cm0050					; do all the lines
			move.l	monsters,mkilled		; for display
*
* Find and initialise all the rocks
* Search from bottom right of map
* to top left
*
			lea		play_map+34*3+3,a1		; last empty part
			lea		rock_table,a0			; rock structure
			clr.w	rocks					; number of rocks in map
			move.w	#3,d0					; start x position
			move.w	#3,d1					; start y position
cm0070		cmp.b	#rock,(a1)				; found a rock ?
			bne.s	cm0080					; skip if not
			move.w	d0,(a0)+				; save x start position
			move.w	d1,(a0)+				; save y start pos.
			clr.w	(a0)+					; start as still
			addq.w	#1,rocks				; count the rock
cm0080		lea		1(a1),a1				; next x position
			addq.w	#1,d0					; adjust x pos offset
			cmp.w	#31,d0					; end of a line ?
			blo.s	cm0070					; loop if not			
			move.w	#3,d0					; reset x position
			lea		6(a1),a1				; offset to next line of data
			addq.w	#1,d1					; next y position
			cmp.w	#27,d1					; done all the lines ?
			blo.s	cm0070					; do all the lines
			subq.w	#1,rocks				; one less for dbra
*
* Count the total diamonds on the level
*
			lea		play_map+34*3+3,a1		; empty part
			move.w	#3,d0					; start x position
			move.w	#3,d1					; start y position
			clr.l	diamonds
			move.w	spirits,diamonds+2		; start count of spirits
			addq.l	#1,diamonds				; count the crown
cm0090		cmp.b	#diamond,(a1)			; found a diamond ?
			beq.s	cm0100					; skip if we have
			cmp.b	#safe,(a1)				; found a safe ?
			beq.s	cm0100					; skip if we have
			bra.s	cm0110
cm0100		addq.l	#1,diamonds				; count the diamond
cm0110		lea		1(a1),a1				; next x position
			addq.w	#1,d0					; adjust x pos offset
			cmp.w	#31,d0					; end of a line ?
			blo.s	cm0090					; loop if not			
			move.w	#3,d0					; reset x position
			lea		6(a1),a1				; offset to next line of data
			addq.w	#1,d1					; next y position
			cmp.w	#27,d1					; done all the lines ?
			ble.s	cm0090					; do all the lines
*
* Find and initialise all the fungus
*
			lea		fun_table,a0			; fungus data table
			lea		play_map+34*3+3,a1		; map data
			clr.w	f_units					; no fungus yet
			move.w	#3,d0					; start x position
			move.w	#3,d1					; start y position
cm0120		cmp.b	#fungus,(a1)			; found some fungus ?
			bne.s	cm0130					; skip if not
			movem.w	d0-d1,(a0)				; fungus x,y position
			move.w	#-1,4(a0)				; fungus grow data
			lea		6(a0),a0				; next fungus unit
			addq.w	#1,f_units				; count the fungus
cm0130		lea		1(a1),a1				; next unit in map
			addq.w	#1,d0					; count the x position
			cmp.w	#31,d0					; done a line ?
			blo.s	cm0120					; loop if not
			move.w	#3,d0					; reset x position
			addq.w	#1,d1					; next y position
			lea		6(a1),a1				; adjust map pointer
			cmp.w	#27,d1					; done all the lines ?
			ble.s	cm0120					; loop if not
*
* Initialise the spirit start directions
*
			jsr		start_dir				; setup spirit start directions
			rts

play_game	move.w	#3,lives				; 3 lives for repton
			clr.l	score
			jsr		fade_out
			clr.w	dead
pgm0000		jsr		copy_map				; setup the data table
			jsr		play_a_map				; play the map
			tst.w	lives					; repton still alive ?
			beq.s	game_exit				; exit if not
			lea		pass_disp,a0			; password display
			move.w	map,d0					; offset
			move.b	#1,1(a0,d0.w)			; set password bit
			move.b	#1,9(a0,d0.w)			; set e-code bit
			addq.w	#1,map					; next map
			cmp.w	#8,map					; done them all ?
			beq		game_exit				; exit if we have
			jsr		copy_map				; setup the next map data
			jsr		status					; diaply repton status
			bra		pgm0000					; play the new map


game_exit	clr.w	map						; back to map A
			jsr		fade_out
			jsr		setup_menu
			move.w	#2,hilight			; need to display
			jsr		setup_menu
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		vsync_wait
			lea		menu_lu,a1			; main menu look up
			jsr		plot_block			
			jsr		hi_light
			lea		cont_char,a0
			jsr		print_text
			jsr		fade_in
			rts

status		jsr		fade_out
			jsr		game_stats
			lea		status_lu,a1
			jsr		plot_block
			jsr		vsync_wait
			lea		status_lu,a1
			jsr		plot_block
			jsr		vsync_wait
			jsr		fade_in
stat0000	jsr		vsync_wait
			lea		keys,a0
			tst.b	m(a0)				; view map ?
			beq.s	stat0010
			cmp.w	#5,map				; allowed ro view map ?
			bge.s	stat0010			; skip if not
			jsr		view_map
			lea		status_lu,a1
			jsr		plot_block
			jsr		vsync_wait
			lea		status_lu,a1
			jsr		plot_block
			jsr		vsync_wait
			jsr		fade_in
			bra.s	stat0000
stat0010	tst.b	escape(a0)				; end game ?
			beq.s	stat0020				; skip if not
			move.w	#1,lives
			move.w	#1,dead
			jsr		fade_out
			rts
stat0020	tst.b	space(a0)
			bne.s	stat_exit
			btst.b	#7,stick1_pkt+1			; pressed button ?
			beq		stat0000				; loop if not
stat_exit	
			jsr		fade_out
			rts

play_a_map	move.l	#lk_seq,seq_pntr		; repton start params
			move.l	#lk_seq+2+8*4,seq_pntr2
			move.w	#23,seq_count
			jsr		clear_buffer
			clr.w	direction
			clr.w	rep_action
			move.w	#150,rep_still
			jsr		sort_rocks
			jsr		plot_screen
			jsr		plot_repton
			jsr		vsync_wait
			jsr		plot_screen
			jsr		plot_repton
			jsr		fade_in
pg0000		jsr		vsync_game
			jsr		game_keys
			jsr		move_spirits
			jsr		sort_rocks
			jsr		grow_fun
			jsr		kill_mons
			jsr		rep_in
			jsr		move_rocks
			jsr		do_mons
			jsr		rep_out
			jsr		kill_mons
			jsr		plot_screen
			jsr		plot_spirits
			jsr		plot_mons
			jsr		plot_repton
			subq.l	#1,game_time
			bne.s	pg0005					; skip if time left
			move.w	#1,dead					; kill repton
pg0005		tst.w	finished				; finished the level ?
			bne.s	pg0010
			tst.w	lives					; repton still going ?
			bne		pg0000					; loop if he is
pg0010		clr.w	finished
			rts

plot_repton	tst.w	rep_still
			bne.s	pr0000
			add.l	#4,seq_pntr2			; animate repton
			subq.w	#1,seq_count			; loop the sequence ?
			bge.s	pr0000					; skip if not
			move.l	seq_pntr,seq_pntr2
			add.l	#2,seq_pntr2
			move.l	seq_pntr,a0
			move.w	(a0),seq_count
pr0000		move.l	seq_pntr2,a0			; pntr 2 pntr 2 character data
			move.l	(a0),a0					; get pointer to character
			move.l	scr1,a1					; screen pointer
			lea		15432(a1),a1			; plot position
			move.w	#31,d5					; 32 lines to plot
pr0010		clr.w	d4
			movem.w	(a0)+,d0-d3				; 16 pixels of data
			or.w	d0,d4					; make mask data
			or.w	d1,d4					; make mask data
			or.w	d2,d4
			or.w	d3,d4
			not.w	d4
			and.w	d4,(a1)
			and.w	d4,2(a1)
			and.w	d4,4(a1)
			and.w	d4,6(a1)
			or.w	d0,(a1)
			or.w	d1,2(a1)
			or.w	d2,4(a1)
			or.w	d3,6(a1)
			clr.w	d4
			movem.w	(a0)+,d0-d3				; 16 pixels of data
			or.w	d0,d4					; make mask data
			or.w	d1,d4					; make mask data
			or.w	d2,d4
			or.w	d3,d4
			not.w	d4
			and.w	d4,8(a1)
			and.w	d4,10(a1)
			and.w	d4,12(a1)
			and.w	d4,14(a1)
			or.w	d0,8(a1)
			or.w	d1,10(a1)
			or.w	d2,12(a1)
			or.w	d3,14(a1)
			lea		160(a1),a1				; next screen line
			dbra	d5,pr0010
			rts

game_keys	tst.w	dead					; repton been killed ?
			bne		cl0073					; skip if he has
			tst.w	direction				; moving ?
			beq.s	gk_go					; skip if not
			movem.w	man_x,d1-d2
			and.w	#$03,d1					; offset bits
			and.w	#$03,d2
			move.w	direction,d0
			lsl.w	#2,d0					; l_word offset
			lea		w_routes,a0				; table of routines
			move.l	(a0,d0.w),a0			; routine to use
			jmp		(a0)					; do the correct routine
w_routes	dc.l	w_north
			dc.l	w_north
			dc.l	w_east
			dc.l	w_south
			dc.l	w_west
gk_go		tst.b	controls				; joystick or keyboard ?
			bne		joystick				; skip if joystick
keyboard	lea		keys,a0					; keyboard table
			move.w	left,d0
			tst.b	(a0,d0.w)				; left pressed ?
			beq.s	gk0000					; skip if not
			cmp.w	#12,man_x
			ble.s	gk0000
			bra		move_left
gk0000		move.w	right,d0
			tst.b	(a0,d0.w)				; right pressed ?
			beq.s	gk0010					; skip if not
			cmp.w	#120,man_x
			bge.s	gk0010
			bra		move_right
gk0010		move.w	up,d0
			tst.b	(a0,d0.w)				; up pressed ?
			beq.s	gk0020
			cmp.w	#12,man_y
			ble.s	gk0020
			bra		move_up
gk0020		move.w	down,d0					; down pressed ?
			tst.b	(a0,d0.w)
			beq.s	gk0030
			cmp.w	#104,man_y
			bge.s	gk0030
			bra		move_down
gk0030		cmp.w	#4,rep_action			; still doing nothing ?
			bne.s	gk0040					; skip if we are
			clr.w	rep_action				; time stopped period
			move.w	#150,rep_still			; repton still counter
gk0040		move.w	vmap,d0					
			tst.b	(a0,d0.w)				; view the map ?
			beq.s	gk0050					; skip if not
			cmp.w	#5,map					; allwed to view map ?
			bge.s	gk0050					; skip if not
			jsr		view_map
			jsr		clear_buffer
			jsr		plot_screen
			jsr		plot_repton
			jsr		vsync_wait
			jsr		plot_screen
			jsr		plot_repton
			jsr		fade_in
			rts
gk0050		tst.b	escape(a0)				; kill yourself ?
			beq		gk0060
			bra		cl0073					; skip if you have
			rts
gk0055		jsr		clear_buffer
			jsr		plot_screen
			jsr		plot_spirits
			jsr		plot_mons
			jsr		plot_repton
			jsr		vsync_wait
			jsr		fade_out
			move.l	new_start,d0			; default start location
			move.l	d0,man_x				; reset start pos
			lea		lk_seq,a0				; new sequence
			move.l	a0,seq_pntr
			move.w	(a0)+,seq_count			; repton looking
			move.l	a0,seq_pntr2
			clr.w	rep_action
			clr.w	rep_still
			clr.w	direction
			jsr		plot_screen
			jsr		plot_spirits
			jsr		plot_mons
			jsr		plot_repton
			jsr		vsync_wait
			jsr		fade_in
			rts
gk0060		move.w	vstatus,d0
			tst.b	(a0,d0.w)				; status ?
			beq.s	gk0070					; skip if not
			jsr		status					; show status
			jsr		clear_buffer
			jsr		plot_screen
			jsr		plot_spirits
			jsr		plot_mons
			jsr		plot_repton
			jsr		vsync_wait
			jsr		plot_screen
			jsr		plot_spirits
			jsr		plot_mons
			jsr		plot_repton
			jsr		fade_in
			rts						
gk0070		tst.w	rep_still
			beq.s	gk0080
			subq.w	#1,rep_still
			bne.s	gk0080
			lea		lk_seq,a0				; new sequence
			move.l	a0,seq_pntr
			move.w	(a0)+,seq_count
			move.l	a0,seq_pntr2
			clr.w	direction
gk0080		bra		ch2000					; check location
			rts

joystick	btst	#2,stick1_pkt+1			; joystick left ?
			beq.s	jk0000					; skip if not
			cmp.w	#12,man_x
			ble.s	jk0000
			bra		move_left
jk0000		btst	#3,stick1_pkt+1			; joystick right ?
			beq.s	jk0010					; skip if not
			cmp.w	#120,man_x
			bge.s	jk0010
			bra		move_right
jk0010		btst	#0,stick1_pkt+1			; joystick up ?
			beq.s	jk0020
			cmp.w	#12,man_y
			ble.s	jk0020
			bra		move_up
jk0020		btst	#1,stick1_pkt+1			; joystick down ?
			beq.s	jk0030
			cmp.w	#104,man_y
			bge.s	jk0030
			bra		move_down
jk0030		lea		keys,a0					; need the pointer
			cmp.w	#4,rep_action			; still doing nothing ?
			bne		gk0040					; skip if we are
			clr.w	rep_action				; time stopped period
			move.w	#150,rep_still			; repton still counter
			bra		gk0040					; rest is keyboard

w_north		tst.b	d2						; end of walk up stage ?
			beq		gk_go					; skip if we have
			subq.w	#1,man_y				; moveing up
			subq.b	#1,d2
			beq		check_location			; check where repton now standing
			rts
w_east		tst.b	d1						; end of walk right stage ?
			beq		gk_go
			move.w	#1,d2					; offset in pushing
			addq.w	#1,man_x
			subq.b	#3,d1
			beq		check_location
			rts
w_south		tst.b	d2						; end of walk up stage ?
			beq		gk_go					; skip if we have
			addq.w	#1,man_y				; moveing up
			subq.b	#3,d2
			beq		check_location
			rts
w_west		tst.b	d1						; end of walk right stage ?
			beq		gk_go
			move.w	#-1,d2					; offset in pushing
			subq.w	#1,man_x
			subq.b	#1,d1
			beq		check_location
			rts
			
check_location
			lea		play_map,a0				; screen data
			movem.w	man_x,d0-d1				; man co-ords
			lsr.w	#2,d0					; normalise them
			lsr.w	#2,d1
			mulu.w	#34,d1					; total y offset
			add.w	d0,d1					; total offset
			add.w	d1,a0					; make pointer
			tst.w	pushing					; pushing an egg/rock ?
			beq.s	no_push					; skip if not
			move.b	#rock,d3				; assume rock
			cmp.w	#3,pushing				; is it an egg ?
			blo.s	np0000					; skip if not
			move.b	#egg,d3					; else egg character
np0000		clr.w	pushing
			move.b	d3,(a0,d2.w)			; restore position
no_push		cmp.b	#old_rock,(a0)			; need to clear the space ?
			bne		cl_start
			clr.b	(a0)					; erase it
cl_start	cmp.b	#diamond,(a0)			; taken a diamond ?
			bne.s	cl0000					; skip if not
			clr.b	(a0)					; erase from map
			subq.l	#1,diamonds				; count the diamond
			addq.l	#5,score				; do the score
			rts
cl0000		cmp.b	#earth,(a0)				; taken some earth ?
			bne.s	cl0010					; skip if not
			clr.b	(a0)					; erase from map
			rts
cl0010		cmp.b	#key,(a0)				; taken a key ?
			bne.s	cl0020
			clr.b	(a0)					; erase from map
			jsr		change_safes			; convert safes to diamonds
			rts
cl0020		cmp.b	#crown,(a0)				; taken the crown ?
			bne.s	cl0030
			subq.l	#1,diamonds				; count the diamond
			add.l	#50,score				; do the score
			clr.b	(a0)
			rts
cl0030		cmp.b	#trans,(a0)				; transporter ?
			bne		cl0060					; skip if not
			clr.b	(a0)
			lea		play_tran,a0			; transporter data
			movem.w	man_x,d0-d1				; man locations
			lsr.w	#2,d0
			lsr.w	#2,d1
			sub.w	#3,d0
			sub.w	#3,d1
			lsl.w	#8,d0					; x position upper byte
			add.b	d1,d0					; co-ordinate position
			move.w	#3,d5					; check them all
cl0040		cmp.w	(a0),d0					; correct transporter ?
			bne		cl0050					; skip if not
			clr.w	d0
			clr.w	d1
			move.b	2(a0),d0				; new location
			move.b	3(a0),d1				; new location
			addq.w	#3,d0					; normalise to play map
			addq.w	#3,d1					; normalise to play map
			lsl.w	#2,d0					; x position
			lsl.w	#2,d1					; y position
			movem.w	d0-d1,-(sp)
			jsr		plot_screen
			jsr		plot_spirits
			jsr		plot_mons
			jsr		plot_repton
			movem.w	(sp)+,d0-d1
			movem.w	d0-d1,man_x				; new man position
			movem.w	d0-d1,new_start			; new man position
			jsr		vsync_wait
			clr.w	direction
			lea		lk_seq,a0				; new sequence
			move.l	a0,seq_pntr
			move.w	(a0)+,seq_count			; repton looking
			move.l	a0,seq_pntr2
			clr.w	rep_action
			clr.w	rep_still
			jsr		fade_out
			jsr		plot_screen
			jsr		plot_spirits
			jsr		plot_mons
			jsr		plot_repton
			jsr		vsync_wait
			jsr		fade_in
			rts
cl0050		lea		4(a0),a0				; next trans data
			dbra	d5,cl0040
			rts
cl0060		cmp.b	#timebomb,(a0)			; finished the level ?
			bne.s	cl0070					; skip if not
			move.w	#1,finished				; signal level complete
			jsr		plot_screen
			jsr		plot_repton
			jsr		vsync_wait
			rts
cl0070		cmp.b	#skull,(a0)				; repton killed himself ?
			bne		cl0080					; skip if not
cl0073		clr.w	dead					; clear killed flag
			clr.w	flash
			move.l	reset_time,game_time
			subq.w	#1,lives				; lose a life
			beq		cl0075
*
* if pushing egg or rock then insert back into map
*
			tst.w	pushing					; pushing an egg/rock ?
			beq.s	cl0074					; skip if not
			move.w	#1,d3					; assume pushing right
			btst.b	#0,pushing+1			; pushing right ?
			bne.s	pr0						; skip if we are
			move.w	#-1,d3					; pushing left
pr0			lea		play_map,a0				; screen data
			movem.w	man_x,d0-d1				; man co-ords
			lsr.w	#2,d0					; normalise them
			lsr.w	#2,d1
			mulu.w	#34,d1					; total y offset
			add.w	d0,d1					; total offset
			add.w	d1,a0					; make pointer
			move.b	#rock,d3				; assume rock
			btst.b	#1,pushing+1			; is it an egg ?
			beq.s	pr1						; skip if not
			move.b	#egg,d3					; else egg character
pr1			clr.w	pushing
			move.b	d3,(a0,d2.w)			; restore position
			clr.b	(a0)

cl0074		jsr		plot_screen
			jsr		plot_spirits
			jsr		plot_mons
			jsr		plot_repton
			move.l	new_start,man_x
			clr.w	direction
			lea		lk_seq,a0				; new sequence
			move.l	a0,seq_pntr
			move.w	(a0)+,seq_count			; repton looking
			move.l	a0,seq_pntr2
			clr.w	rep_action
			clr.w	rep_still
			jsr		vsync_wait
			jsr		fade_out
			jsr		plot_screen
			jsr		plot_spirits
			jsr		plot_mons
			jsr		plot_repton
			jsr		vsync_wait
			jsr		fade_in
			clr.w	dead
cl0075		rts
ch2000		lea		play_map,a0
			movem.w	man_x,d0-d1
			lsr.w	#2,d0
			lsr.w	#2,d1
			mulu.w	#34,d1
			add.w	d0,d1
			add.w	d1,a0
cl0080		cmp.b	#tcapsule,(a0)			; taken a time capsule ?
			bne.s	cl0090					; skip if not
			clr.b	(a0)					; erase from map
			move.l	reset_time,game_time	; reset play time
			rts
cl0090		tst.b	(a0)					; on anything else ?
			beq.s	cl0100					; skip if not
			clr.b	(a0)					; empty the square
			bra		cl0073					; kill repton
cl0100		rts


change_safes	
			lea		play_map+34*3,a0		; map 
			move.w	#34*24,d5				; locations to check
cs0000		cmp.b	#safe,(a0)+
			bne.s	cs0010					; skip if no safe
			move.b	#diamond,-1(a0)			; change it
cs0010		dbra	d5,cs0000
			rts

move_up		lea		play_map,a1				; map pointer
			movem.w	man_x,d0-d1				; current co-ords * 4
			lsr.w	#2,d0					; normalise them
			lsr.w	#2,d1
			mulu.w	#34,d1					; make y offset
			add.w	d0,d1					; total offset
			add.w	d1,a1
* 
* check what character is above repton
*
			cmp.b	#empty,-34(a1)			; allowed to move ?
			beq		mu0010					; skip if we are
			cmp.b	#earth,-34(a1)			; allowed to move ?
			beq		mu0010					; skip if we are
			cmp.b	#diamond,-34(a1)		; allowed to move ?
			beq		mu0010					; skip if we are
			cmp.b	#skull,-34(a1)			; allowed to move ?
			beq		mu0010					; skip if we are
			cmp.b	#skull,-34(a1)			; allowed to move ?
			beq		mu0010					; skip if we are
			cmp.b	#key,-34(a1)			; allowed to move ?
			beq		mu0010					; skip if we are
			cmp.b	#crown,-34(a1)			; allowed to move ?
			beq		mu0010					; skip if we are
			cmp.b	#fungus,-34(a1)			; allowed to move ?
			beq		mu0010					; skip if we are
			cmp.b	#trans,-34(a1)			; allowed to move ?
			beq		mu0010					; skip if we are
			cmp.b	#tcapsule,-34(a1)		; allowed to move ?
			beq		mu0010					; skip if we are
			tst.w	diamonds+2				; all diamonds got ?
			bne.s	mu0000					; skip if not
			tst.w	mkilled+2				; killed all the monsters ?
			bne.s	mu0000
			cmp.b	#timebomb,-34(a1)		; allowed to move ?
			beq		mu0010					; skip if we are
mu0000		tst.w	rep_action
			beq.s	mu0005
			move.w	#150,rep_still
			clr.w	rep_action
mu0005		tst.b	controls
			beq		gk0020
			bra		jk0020
mu0010		subq.w	#1,man_y
			move.w	#4,rep_action
			clr.w	rep_still
			cmp.w	#1,direction			; up/down sequence ?
			bne.s	mu0020
			rts
mu0020		cmp.w	#3,direction
			beq.s	mu0015
			lea		wu_seq,a0				; new sequence
			move.l	a0,seq_pntr
			move.w	(a0)+,seq_count
			move.l	a0,seq_pntr2
mu0015		move.w	#1,direction			; set direction flag
			rts

move_down	lea		play_map,a1				; map pointer
			movem.w	man_x,d0-d1				; current co-ords * 4
			lsr.w	#2,d0					; normalise them
			lsr.w	#2,d1
			mulu.w	#34,d1					; make y offset
			add.w	d0,d1					; total offset
			add.w	d1,a1
* 
* check what character is below repton
*
			cmp.b	#empty,34(a1)			; allowed to move ?
			beq		md0010					; skip if we are
			cmp.b	#earth,34(a1)			; allowed to move ?
			beq		md0010					; skip if we are
			cmp.b	#diamond,34(a1)			; allowed to move ?
			beq		md0010					; skip if we are
			cmp.b	#skull,34(a1)			; allowed to move ?
			beq		md0010					; skip if we are
			cmp.b	#skull,34(a1)			; allowed to move ?
			beq		md0010					; skip if we are
			cmp.b	#key,34(a1)				; allowed to move ?
			beq		md0010					; skip if we are
			cmp.b	#crown,34(a1)			; allowed to move ?
			beq		md0010					; skip if we are
			cmp.b	#fungus,34(a1)			; allowed to move ?
			beq		md0010					; skip if we are
			cmp.b	#trans,34(a1)			; allowed to move ?
			beq		md0010					; skip if we are
			cmp.b	#tcapsule,34(a1)		; allowed to move ?
			beq		md0010					; skip if we are
			tst.w	diamonds+2				; all diamonds got ?
			bne.s	md0000					; skip if not
			tst.w	mkilled+2				; killed all the monsters ?
			bne.s	md0000
			cmp.b	#timebomb,34(a1)		; allowed to move ?
			beq		md0010					; skip if we are
md0000		tst.w	rep_action
			beq.s	md0005
			move.w	#150,rep_still
			clr.w	rep_action
md0005		tst.b	controls
			beq		gk0030
			bra		jk0030
md0010		addq.w	#1,man_y
			move.w	#4,rep_action
			clr.w	rep_still
			cmp.w	#3,direction			; up/down sequence ?
			bne.s	md0020					; skip if not
			rts
md0020		cmp.w	#1,direction			; up/down sequence ?
			beq.s	md0015
			lea		wu_seq,a0				; new sequence
			move.l	a0,seq_pntr
			move.w	(a0)+,seq_count
			move.l	a0,seq_pntr2
md0015		move.w	#3,direction			; set direction flag
			rts

move_left	lea		play_map,a1				; map pointer
			movem.w	man_x,d0-d1				; current co-ords * 4
			lsr.w	#2,d0					; normalise them
			lsr.w	#2,d1
			move.w	d1,d2					; keep copy for pushing
			mulu.w	#34,d1					; make y offset
			add.w	d0,d1					; total offset
			add.w	d1,a1
* 
* check what character to the left of repton
*
			cmp.b	#empty,-1(a1)			; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#earth,-1(a1)			; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#diamond,-1(a1)			; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#skull,-1(a1)			; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#skull,-1(a1)			; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#key,-1(a1)				; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#crown,-1(a1)			; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#fungus,-1(a1)			; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#trans,-1(a1)			; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#tcapsule,-1(a1)		; allowed to move ?
			beq		ml0010					; skip if we are
			cmp.b	#rock,-1(a1)			; pushing a rock ?
			beq		ml0030					; skip if we are
			cmp.b	#egg,-1(a1)				; pushin an egg ?
			beq		ml0040
			tst.w	diamonds+2				; all diamonds got ?
			bne.s	ml0000					; skip if not
			tst.w	mkilled+2				; killed all the monsters ?
			bne.s	ml0000
			cmp.b	#timebomb,-1(a1)		; allowed to move ?
			beq		ml0010					; skip if we are
ml0000		tst.w	rep_action
			beq.s	ml0005
			move.w	#150,rep_still
			clr.w	rep_action
ml0005		tst.b	controls
			beq		gk0000
			bra		jk0000
ml0010		clr.w	rep_still
			move.w	#4,rep_action
			subq.w	#1,man_x				; change x position
			cmp.w	#4,direction			; current direction ?
			bne.s	ml0020
			rts
ml0020		move.w	#4,direction			; set direction flag
			lea		wl_seq,a0				; new sequence
			move.l	a0,seq_pntr
			move.w	(a0)+,seq_count
			move.l	a0,seq_pntr2
			rts
* pushing a rock
ml0030		cmp.b	#empty,-2(a1)			; empty space to go into ?
			bne		ml0000					; skip if not
			move.w	#1,pushing				; signal to plot screen
			move.b	#old_rock,-1(a1)		; erase from map
			subq.w	#1,d0					; rock x position
			move.l	a0,-(sp)
			lea		rock_table,a0			; rock data table
			move.w	rocks,d4				; loop count
ml0035		cmp.w	(a0),d0					; found the right rock ?
			bne.s	ml0036					; skip if not
			cmp.w	2(a0),d2
			bne.s	ml0036					; skip if not
			subq.w	#1,(a0)					; modify rock table
			move.w	#2,4(a0)				; rock falling fast now
			move.l	(sp)+,a0
			bra		ml0010					; do correct stuff
ml0036		lea		6(a0),a0				; next rock in table
			dbra	d4,ml0035
			move.w	#$700,colours
			move.l	(sp)+,a0
			bra		ml0010
* pushing an egg
ml0040		cmp.b	#empty,-2(a1)			; empty space to go into ?
			bne		ml0000					; skip if not
			move.w	#3,pushing				; signal to plot screen
			move.b	#old_rock,-1(a1)		; erase from map
			subq.w	#1,d0					; egg x position
			lsl.w	#2,d0					; egg table is *4
			lsl.w	#2,d2
			swap	d0						; x in upper word
			move.w	d2,d0					; y in lower word
			move.l	a0,-(sp)
			lea		play_eggs,a0			; rgg data table
			move.w	monsters+2,d4			; loop count
			subq.w	#1,d4
ml0045		cmp.l	(a0),d0					; found the right egg ?
			bne.s	ml0046					; skip if not
			subq.w	#4,(a0)					; modify egg table
			move.l	(sp)+,a0
			bra		ml0010					; do correct stuff
ml0046		lea		6(a0),a0				; next rock in table
			dbra	d4,ml0045
			move.w	#$700,colours
			move.l	(sp)+,a0
			bra		ml0010					; do correct stuff

move_right	lea		play_map,a1				; map pointer
			movem.w	man_x,d0-d1				; current co-ords * 4
			lsr.w	#2,d0					; normalise them
			lsr.w	#2,d1
			move.w	d1,d2					; copy for pushing
			mulu.w	#34,d1					; make y offset
			add.w	d0,d1					; total offset
			add.w	d1,a1
* 
* check what character to the left of repton
*
			cmp.b	#empty,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#earth,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#diamond,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#skull,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#skull,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#key,1(a1)				; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#crown,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#fungus,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#trans,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#tcapsule,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
			cmp.b	#rock,1(a1)				; pushing a rock ?
			beq		mr0030					; skip if we are
			cmp.b	#egg,1(a1)				; pushin an egg ?
			beq		mr0040
			tst.w	diamonds+2				; all diamonds got ?
			bne.s	mr0000					; skip if not
			tst.w	mkilled+2				; killed all the monsters ?
			bne.s	mr0000
			cmp.b	#timebomb,1(a1)			; allowed to move ?
			beq		mr0010					; skip if we are
mr0000		tst.w	rep_action
			beq.s	mr0005
			move.w	#150,rep_still
			clr.w	rep_action
mr0005		tst.b	controls
			beq		gk0010
			bra		jk0010
mr0010		clr.w	rep_still
			move.w	#4,rep_action
			addq.w	#1,man_x
			cmp.w	#2,direction
			bne.s	mr0020
			rts
mr0020		lea		wr_seq,a0				; new sequence
			move.l	a0,seq_pntr
			move.w	(a0)+,seq_count
			move.l	a0,seq_pntr2
			move.w	#2,direction			; set direction flag
			rts
* pushing a rock
mr0030		cmp.b	#empty,2(a1)			; empty space to go into ?
			bne		mr0000					; skip if not
			move.w	#2,pushing				; signal to plot screen
			move.b	#old_rock,1(a1)			; erase from map
			addq.w	#1,d0					; rock x position
			move.l	a0,-(sp)
			lea		rock_table,a0			; rock data table
			move.w	rocks,d4
mr0035		cmp.w	(a0),d0					; found the right rock ?
			bne.s	mr0036					; skip if not
			cmp.w	2(a0),d2
			bne.s	mr0036					; skip if not
			addq.w	#1,(a0)					; modify rock table
			move.w	#2,4(a0)				; rock falling fast now
			move.l	(sp)+,a0
			bra		mr0010					; do correct stuff
mr0036		lea		6(a0),a0				; next rock in table
			dbra	d4,mr0035
			move.w	#$700,colours
			move.l	(sp)+,a0
			bra		mr0010
* pushing an egg
mr0040		cmp.b	#empty,2(a1)			; empty space to go into ?
			bne		mr0000					; skip if not
			move.w	#4,pushing				; signal to plot screen
			move.b	#old_rock,1(a1)			; erase from map
			addq.w	#1,d0					; egg x position
			lsl.w	#2,d0					; egg table is *4
			lsl.w	#2,d2	
			swap	d0						; x in upeer word
			move.w	d2,d0					; y in lower word
			move.l	a0,-(sp)
			lea		play_eggs,a0			; egg data table
			move.w	monsters+2,d4
			subq.w	#1,d4
mr0045		cmp.l	(a0),d0					; found the right egg ?
			bne.s	mr0046					; skip if not
			addq.w	#4,(a0)					; modify egg table
			move.l	(sp)+,a0
			bra		mr0010					; do correct stuff
mr0046		lea		6(a0),a0				; next rock in table
			dbra	d4,mr0045
			move.w	#$700,colours
			move.l	(sp)+,a0
			bra		mr0010					; do correct stuff


plot_screen	move.l	scr1,a0					; screen start address
			lea		24(a0),a0				; offset to screen
			lea		play_map,a1				; screen data
			movem.w	man_x,d0-d1				; get man positions
			move.w	d0,d2
			move.w	d1,d3
			and.w	#$03,d2					; get offset bits
			and.w	#$03,d3
			tst.b	d2						; offset in horizontal ?
			beq		ps0000					; skip if not
			cmp.b	#1,d2					; 1 byte offset ?
			beq		hz1						; skip if so
			cmp.b	#2,d2					; 1 word offset ?
			beq		hz2						; skip if so
			bra		hz3
ps0000		tst.b	d3						; vertical offset ?
			beq.s	hzz						; skip if none
			cmp.b	#1,d3					; byte offset ?
			beq		vt1
			cmp.b	#2,d3
			beq		vt2
			bra		vt3
ps0010		tst.w	pushing					; anything being pushed ?
			beq		ps_exit					; skip if not
* assume pushing left
			move.l	scr1,a1					; screen start
			lea		15416(a1),a1			; plot position
			btst.b	#0,pushing+1			; pushing left ?
			bne.s	ps0020					; skip if we are
			lea		32(a1),a1				; plot to right of repton
ps0020		lea		chars+(rock*512),a0		; charcter to plot
			cmp.w	#3,pushing				; is it a rock ?
			blo.s	ps0030					; skip if it is
			lea		chars+(egg*512),a0		; else egg character
ps0030		move.w	#31,d5					; 32 lines to plot
ps0040		movem.l	(a0)+,d0-d3				; 16 pixels of data
			movem.l	d0-d3,(a1)
			lea		160(a1),a1
			dbra	d5,ps0040
ps_exit		rts

hzz			lsr.w	#2,d1
			lsr.w	#2,d0
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			sub.w	#105,d1					; adjust
			add.w	d1,a1					; make pointer
			move.w	#6,d5					; y positions to do
hzz000		move.w	#6,d4					; x positions to do
hzz010		movem.l	d4-d5/a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_char
			movem.l	(sp)+,d4-d5/a0-a1
			lea		1(a1),a1
			lea		16(a0),a0				; next char position
			dbra	d4,hzz010				; do all seven
			lea		32*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			dbra	d5,hzz000				; do all seven lines
			bra		ps0010					; back to end of plot

hz1			lsr.w	#2,d1
			lsr.w	#2,d0
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			sub.w	#105,d1					; adjust
			add.w	d1,a1					; make pointer
			move.w	#6,d5					; y positions to do
hz1000		movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr2
			jsr		plot_r3q
			movem.l	(sp)+,d5/a0-a1
			lea		8(a0),a0
			lea		1(a1),a1
			rept	6
			movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr2
			jsr		plot_off1
			movem.l	(sp)+,d5/a0-a1
			lea		16(a0),a0				; next char position
			lea		1(a1),a1
			endr
			movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr2
			jsr		plot_lbyte
			movem.l	(sp)+,d5/a0-a1
			lea		8(a0),a0				; next char position
			lea		32*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			dbra	d5,hz1000				; do all seven lines
			bra		ps0010					; back to end of plot

hz2			lsr.w	#2,d1
			lsr.w	#2,d0
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			sub.w	#105,d1					; adjust
			add.w	d1,a1					; make pointer
			move.w	#6,d5					; y positions to do
hz2000		movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr
			lea		8(a1),a1
			jsr		plot_half
			movem.l	(sp)+,d5/a0-a1
			lea		8(a0),a0				; next char position
			lea		1(a1),a1
			rept	6
			movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_char
			movem.l	(sp)+,d5/a0-a1
			lea		16(a0),a0				; next char position
			lea		1(a1),a1
			endr
			movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_half
			movem.l	(sp)+,d5/a0-a1
			lea		8(a0),a0				; next char position
			lea		32*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			dbra	d5,hz2000				; do all seven lines
			bra		ps0010					; back to end of plot
			
hz3			lsr.w	#2,d1
			lsr.w	#2,d0
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			sub.w	#105,d1					; adjust
			add.w	d1,a1					; make pointer
			move.w	#6,d5					; y positions to do
hz3000		movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr2
			jsr		plot_rbyte
			movem.l	(sp)+,d5/a0-a1
			lea		1(a1),a1
			rept	6
			movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr2
			jsr		plot_off1
			movem.l	(sp)+,d5/a0-a1
			lea		16(a0),a0				; next char position
			lea		1(a1),a1
			endr
			movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr2
			jsr		plot_l3q
			movem.l	(sp)+,d5/a0-a1
			lea		16(a0),a0				; next char position
			lea		32*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			dbra	d5,hz3000				; do all seven lines
			bra		ps0010					; back to end of plot

vt1			lsr.w	#2,d1
			lsr.w	#2,d0
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			sub.w	#105,d1					; adjust
			add.w	d1,a1					; make pointer
			rept	7
			movem.l	a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_b3q
			movem.l	(sp)+,a0-a1
			lea		16(a0),a0
			lea		1(a1),a1
			endr
			lea		24*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			move.w	#5,d5					; y positions to do
vt1000		move.w	#6,d4					; x positions to do
vt1010		movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_char
			movem.l	(sp)+,d5/a0-a1
			lea		1(a1),a1
			lea		16(a0),a0				; next char position
			dbra	d4,vt1010				; do all seven
			lea		32*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			dbra	d5,vt1000				; do all seven lines
			rept	7
			movem.l	a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_tq
			movem.l	(sp)+,a0-a1
			lea		16(a0),a0
			lea		1(a1),a1
			endr
			bra		ps0010					; back to end of plot

vt2			lsr.w	#2,d1
			lsr.w	#2,d0
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			sub.w	#105,d1					; adjust
			add.w	d1,a1					; make pointer
			rept	7
			movem.l	a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_bh
			movem.l	(sp)+,a0-a1
			lea		16(a0),a0
			lea		1(a1),a1
			endr
			lea		16*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			move.w	#5,d5					; y positions to do
vt2000		move.w	#6,d4					; x positions to do
vt2010		movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_char
			movem.l	(sp)+,d5/a0-a1
			lea		1(a1),a1
			lea		16(a0),a0				; next char position
			dbra	d4,vt2010				; do all seven
			lea		32*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			dbra	d5,vt2000				; do all seven lines
			rept	7
			movem.l	a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_th
			movem.l	(sp)+,a0-a1
			lea		16(a0),a0
			lea		1(a1),a1
			endr
			bra		ps0010					; back to end of plot

vt3			lsr.w	#2,d1
			lsr.w	#2,d0
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			sub.w	#105,d1					; adjust
			add.w	d1,a1					; make pointer
			rept	7
			movem.l	a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_bb
			movem.l	(sp)+,a0-a1
			lea		16(a0),a0
			lea		1(a1),a1
			endr
			lea		8*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			move.w	#5,d5					; y positions to do
vt3000		move.w	#6,d4					; x positions to do
vt3010		movem.l	d5/a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_char
			movem.l	(sp)+,d5/a0-a1
			lea		1(a1),a1
			lea		16(a0),a0				; next char position
			dbra	d4,vt3010				; do all seven
			lea		32*160-7*16(a0),a0		; next line start position
			lea		34-7(a1),a1
			dbra	d5,vt3000				; do all seven lines
			rept	7
			movem.l	a0-a1,-(sp)
			jsr		char_pntr
			jsr		plot_t3q
			movem.l	(sp)+,a0-a1
			lea		16(a0),a0
			lea		1(a1),a1
			endr
			bra		ps0010					; back to end of plot

plot_b3q	move.w	#23,d5
			lea		8*16(a1),a1
			bra.s	pc0000

plot_t3q	move.w	#23,d5
			bra.s	pc0000
			
plot_tq		move.w	#7,d5
			bra.s	pc0000

plot_bb		move.w	#7,d5
			lea		24*16(a1),a1
			bra.s	pc0000
			
plot_th		move.w	#15,d5
			bra.s	pc0000

plot_bh		move.w	#15,d5
			lea		16*16(a1),a1
			bra.s	pc0000

plot_char	move.w	#31,d5					; 32 lines to plot
pc0000		movep.l	(a1),d0					; line of data
			movep.l	d0,(a0)					; plot it
			movep.l	1(a1),d0				; line of data
			movep.l	d0,1(a0)				; plot it
			movem.l	8(a1),d0-d1
			movem.l	d0-d1,8(a0)
			lea		16(a1),a1
			lea		160(a0),a0				; next screen line
			dbra	d5,pc0000				; do them all
			rts

plot_half	move.w	#31,d5					; 32 lines to plot
ph0000		movem.l	(a1),d0-d1				; line of data
			movem.l	d0-d1,(a0)				; plot it
			lea		16(a1),a1
			lea		160(a0),a0				; next screen line
			dbra	d5,ph0000				; do them all
			rts

plot_rbyte	move.w	#31,d5					; 32 linesd to plot
pb0000		move.l	12(a1),d0
			movep.l	d0,(a0)
			lea		16(a1),a1
			lea		160(a0),a0
			dbra	d5,pb0000
			rts

plot_lbyte	move.w	#31,d5					; 32 linesd to plot
plb0000		move.l	(a1),d0
			movep.l	d0,1(a0)
			lea		16(a1),a1
			lea		160(a0),a0
			dbra	d5,plb0000
			rts
			
plot_off1	move.w	#31,d5
po0000		move.l	(a1),d0
			movep.l	d0,1(a0)
			movem.l	4(a1),d0-d1
			movem.l	d0-d1,8(a0)
			move.l	12(a1),d0
			movep.l	d0,16(a0)
			lea		16(a1),a1
			lea		160(a0),a0
			dbra	d5,po0000
			rts

plot_r3q	move.w	#31,d5
pr30000		movem.l	4(a1),d0-d1
			movem.l	d0-d1,(a0)
			move.l	12(a1),d0
			movep.l	d0,8(a0)
			lea		16(a1),a1
			lea		160(a0),a0
			dbra	d5,pr30000
			rts

plot_l3q	move.w	#31,d5
pl30000		move.l	(a1),d0
			movep.l	d0,1(a0)
			movem.l	4(a1),d0-d1
			movem.l	d0-d1,8(a0)
			lea		16(a1),a1
			lea		160(a0),a0
			dbra	d5,pl30000
			rts
			
char_pntr	clr.l	d0						; build character
			move.b	(a1),d0					; character number
			cmp.b	#cursor,d0				; wrong character ?
			bne.s	cp0000
			move.b	#cage,d0
cp0000		cmp.b	#old_rock,d0			; wrong character ?
			bne.s	cp0010
			clr.b	d0
cp0010		lsl.l	#8,d0					; make offset
			lsl.l	#1,d0					; make offset
			lea		chars,a1				; character data
			add.l	d0,a1					; make character pointer
			rts

char_pntr2	clr.l	d0						; build character
			move.b	(a1),d0					; character number
			cmp.b	#cursor,d0				; wrong character ?
			bne.s	cp2000
			move.b	#cage,d0
cp2000		cmp.b	#old_rock,d0			; wrong character ?
			bne.s	cp2010
			clr.b	d0
cp2010		lsl.l	#8,d0					; make offset
			lsl.l	#1,d0					; make offset
			lea		off_chars,a1			; character data
			add.l	d0,a1					; make character pointer
			rts

game_stats	move.l	score,d0				; get score
			jsr		convert_num				; result in d0-d5
			move.b	d5,ste+24
			move.b	d4,ste+25
			move.b	d3,ste+26
			move.b	d2,ste+27
			move.b	d1,ste+28
			move.b	d0,ste+29
			move.l	diamonds,d0
			jsr		convert_num
			move.b	d5,stc+24
			move.b	d4,stc+25
			move.b	d3,stc+26
			move.b	d2,stc+27
			move.b	d1,stc+28
			move.b	d0,stc+29
			move.l	mkilled,d0
			jsr		convert_num
			move.b	d5,std+24
			move.b	d4,std+25
			move.b	d3,std+26
			move.b	d2,std+27
			move.b	d1,std+28
			move.b	d0,std+29
			move.l	hiscore,d0
			cmp.l	score,d0				; new high-score ?
			bge.s	gs0000					; skip if not
			move.l	score,d0
			move.l	d0,hiscore				; new hiscore
gs0000		jsr		convert_num				; result in d0-d5
			move.b	d5,stf+24
			move.b	d4,stf+25
			move.b	d3,stf+26
			move.b	d2,stf+27
			move.b	d1,stf+28
			move.b	d0,stf+29
			move.l	game_time,d0
			jsr		convert_num
			move.b	d5,stb+24
			move.b	d4,stb+25
			move.b	d3,stb+26
			move.b	d2,stb+27
			move.b	d1,stb+28
			move.b	d0,stb+29
			clr.l	d0
			move.w	lives,d0
			add.b	#'0',d0
			move.b	d0,sta+24
			rts
			
convert_num	clr.w	d1
			clr.w	d2
			clr.w	d3
			clr.w	d4
			clr.w	d5
cn0000		cmp.l	#100000,d0				; any hundred thous ?
			blo.s	cn0010					; skip if not
			addq.w	#1,d5					; count it
			sub.l	#100000,d0
			bra.s	cn0000
cn0010		cmp.l	#10000,d0				; any ten thous ?
			blo.s	cn0020					; skip if not
			addq.w	#1,d4					; count it
			sub.l	#10000,d0
			bra.s	cn0010
cn0020		cmp.w	#1000,d0				; any  thous ?
			blo.s	cn0030					; skip if not
			addq.w	#1,d3					; count it
			sub.w	#1000,d0
			bra.s	cn0020
cn0030		cmp.w	#100,d0					; any hundreds ?
			blo.s	cn0040					; skip if not
			addq.w	#1,d2					; count it
			sub.w	#100,d0
			bra.s	cn0030
cn0040		cmp.w	#10,d0					; any tens ?
			blo.s	cn0050					; skip if not
			addq.w	#1,d1					; count it
			sub.w	#10,d0
			bra.s	cn0040
cn0050		add.b	#'0',d0
			add.b	#'0',d1
			add.b	#'0',d2
			add.b	#'0',d3
			add.b	#'0',d4
			add.b	#'0',d5
			tst.w	conv_flag				; editor code ?
			bne.s	cn0070					; skip if it is
cn0060		cmp.b	#'0',d5					; leading zeroes ?
			bne.s	cn0070					; exit if not
			move.w	d4,d5
			move.w	d3,d4
			move.w	d2,d3
			move.w	d1,d2
			move.w	d0,d1
			move.b	#' ',d0
			bra.s	cn0060
cn0070		cmp.b	#' ',d5
			bne.s	cn0080
			move.b	#'0',d5
cn0080		rts
*
* sorts the rocks into right left order, highest to lowest
*
sort_rocks	move.w	rocks,d4			; number of rocks
			subq.w	#2,d4				; 2 less in sort loop
			bge.s	sr0000				; skip if rocks to sort
			rts
sr0000		clr.w	d5					; stays 0 if no rock swap
			lea		rock_table,a0		; structure table
sr0020		movem.w	(a0),d0-d2			; rock data
			cmp.w	8(a0),d1			; need to swap ?
			blo.s	sr0025				; skip if so
			bgt.s	sr0030				; skip if no swap
			cmp.w	6(a0),d0			; furthur to the right ?
			bge.s	sr0030				; skip if it isn't
sr0025		move.l	6(a0),(a0)			; swap rock position data
			move.w	10(a0),4(a0)
			movem.w	d0-d2,6(a0)
			moveq.w	#1,d5				; signal a swap
sr0030		lea		6(a0),a0			; next rock position
			dbra	d4,sr0020			; do all the rocks
			tst.w	d5					; swapped any rocks ?
			bne.s	sort_rocks			; do it again if we have
			rts
			
move_rocks	tst.w	rocks				; are there any rocks ?
			bge.s	mrk000				; skip if there are
			rts
mrk000		move.w	rocks,d5			; number of rocks to do
			lea		rock_table,a0		; rock data
mrk010		lea		play_map,a1			; map data
			movem.w	(a0),d0-d2			; rock x,y & counter data
			mulu.w	#34,d1				; y offset into map
			add.w	d0,d1				; rock offset in map
			add.w	d1,a1				; point at it 
			cmp.b	#rock,(a1)			; if 0 then being pushed
			beq.s	check_rock			; skip if to check rock
mrk020		lea		6(a0),a0			; next rock data
			dbra	d5,mrk010			; do the next rock
			rts
			
check_rock	tst.w	d2					; standing still ?
			beq.s	check_it			; skip if it is
			cmp.w	#2,d2				; chance to push it ?
			bge.s	check_it			; skip if not
			addq.w	#1,4(a0)			; inc the push chance counter
			bra		mrk020
check_it	tst.b	34(a1)				; can the rock go straight down ?
			beq		drop_down			; skip if it can
check_left	tst.b	-1(a1)				; can it fall left ?
			bne.s	check_right
			tst.b	33(a1)				; can it fall left ?
			beq		fall_left
check_right	tst.b	1(a1)				; can it fall right ?
			bne.s	no_drop				; skip if not
			tst.b	35(a1)				; can it fall right ?
			beq		fall_right			; skip if it can
no_drop		clr.w	4(a0)				; rock now standing still
			bra		mrk020
			
drop_down	addq.w	#1,4(a0)			; rock dropping flag
			clr.b	(a1)				; erase its current position
			move.b	#rock,34(a1)		; next position down
			addq.w	#1,2(a0)			; increment its y position
			cmp.b	#repton,68(a1)		; landed on repton ?
			bne		mrk020				; skip if not
			move.w	#1,dead				; signal repton dead
			bra		mrk020
			
fall_left	cmp.b	#diamond,34(a1)		; can roll of diamond
			beq		fl000				; skip if it can fall
			cmp.b	#rock,34(a1)
			beq		fl000				; skip if it can fall
			cmp.b	#crown,34(a1)
			beq		fl000				; skip if it can fall
			cmp.b	#skull,34(a1)
			beq		fl000				; skip if it can fall
			cmp.b	#key,34(a1)
			beq		fl000				; skip if it can fall
			cmp.b	#rleft,34(a1)
			beq		fl000				; skip if it can fall
			cmp.b	#rleft2,34(a1)
			beq		fl000				; skip if it can fall
			cmp.b	#timebomb,34(a1)
			beq		fl000				; skip if it can fall
			cmp.b	#tcapsule,34(a1)
			beq		fl000				; skip if it can fall
			cmp.b	#egg,34(a1)
			beq		fl000				; skip if it can fall
			bra		check_right			
fl000		subq.w	#1,(a0)				; modify x position
			addq.w	#1,2(a0)			; modify y position
			addq.w	#1,4(a0)			; rock dropping flag
			clr.b	(a1)				; erase the rock
			move.b	#rock,33(a1)		; plot in new position
			cmp.b	#repton,67(a1)		; landed on repton ?
			bne		mrk020				; skip if not
			move.w	#1,dead				; signal repton dead
			bra		mrk020				; all done
			
fall_right	cmp.b	#diamond,34(a1)		; can roll of diamond
			beq		fr000				; skip if it can fall
			cmp.b	#rock,34(a1)
			beq		fr000				; skip if it can fall
			cmp.b	#crown,34(a1)
			beq		fr000				; skip if it can fall
			cmp.b	#skull,34(a1)
			beq		fr000				; skip if it can fall
			cmp.b	#key,34(a1)
			beq		fr000				; skip if it can fall
			cmp.b	#rright,34(a1)
			beq		fr000				; skip if it can fall
			cmp.b	#rright2,34(a1)
			beq		fr000				; skip if it can fall
			cmp.b	#timebomb,34(a1)
			beq		fr000				; skip if it can fall
			cmp.b	#tcapsule,34(a1)
			beq		fr000				; skip if it can fall
			cmp.b	#egg,34(a1)
			beq		fr000				; skip if it can fall
			bra		no_drop
fr000		addq.w	#1,(a0)				; modify x position
			addq.w	#1,2(a0)			; modify y position
			addq.w	#1,4(a0)			; rock dropping flag
			clr.b	(a1)				; erase the rock
			move.b	#rock,35(a1)		; plot in new position
			cmp.b	#repton,69(a1)		; landed on repton ?
			bne		mrk020				; skip if not
			move.w	#1,dead				; signal repton dead
			bra		mrk020				; all done

rep_in		lea		play_map,a0			; play data
			movem.w	man_x,d0-d1			; repton co-ords
			movem.w	man_x,d2-d3			; copy data
			and.w	#$03,d2				; get offset bits
			and.w	#$03,d3
			lsr.w	#2,d0				; normalise reptons position
			lsr.w	#2,d1
			mulu.w	#34,d1				; y offset
			add.w	d0,d1				; total offset
			add.w	d1,a0				; pointer to locatioo
			move.l	a0,rep_pos			; save the pointer for rep_out
			tst.w	d2					; x offset ?
			bne.s	rep_x				; reton in x position
			tst.w	d3					; y offset ?
			bne.s	rep_y				; repton in y position
* repton in only one position
rep_one		move.b	(a0),rep1			; save old character
			move.b	#repton,(a0)		; install repton in map
			rts
rep_x		move.b	(a0),rep1
			move.b	1(a0),rep2
			move.b	#repton,(a0)		; install repton in map
			move.b	#repton,1(a0)		; install repton in map
			rts
rep_y		move.b	(a0),rep1
			move.b	34(a0),rep2
			move.b	#repton,(a0)		; install repton in map
			move.b	#repton,34(a0)		; install repton in map
			rts

rep_out		move.l	rep_pos,a0			; map pointer
			movem.w	man_x,d2-d3			; copy data
			and.w	#$03,d2				; get offset bits
			and.w	#$03,d3
			tst.w	d2					; x offset ?
			bne.s	rep_xo				; reton in x position
			tst.w	d3					; y offset ?
			bne.s	rep_yo				; repton in y position
rep_oneo	move.b	rep1,(a0)			; restore old character
			rts						
rep_xo		move.b	rep1,(a0)
			move.b	rep2,1(a0)
			rts
rep_yo		move.b	rep1,(a0)
			move.b	rep2,34(a0)
			rts

move_spirits	
			move.w	spirits,d5			; number of spirits on level
			bne.s	ms0000				; skip if at least 1
			rts							; no spirits on level
ms0000		subq.w	#1,d5				; one less for dbra
			lea		play_spir,a0		; spirit data
ms0010		movem.w	(a0),d0-d2			; x,y, direction data
			tst.w	d2					; spirit still alive ?
			bmi.s	ms0020				; skip if not
			and.w	#$03,d0				; make offset values
			and.w	#$03,d1
			add.w	d0,d1				; total offset
* if offset <> 0 then spirit cannot change direction
			tst.w	d1					; change direction ?
			bne.s	ms0030				; update spirit position instead
			movem.w	(a0),d0-d1			; recover x,y position
			jsr		change_direction	; do spirit direction change
ms0020		lea		6(a0),a0			; next spirit data
			dbra	d5,ms0010			; check all the spirits
			rts

ms0030		tst.w	d2					; moving north ?
			bne.s	ms0040				; skip if not
			subq.w	#1,2(a0)			; modify y position
			bra		ms0020				; next spirit
ms0040		cmp.w	#1,d2				; moving east ?
			bne.s	ms0050				; skip if not
			addq.w	#1,(a0)				; change x position 
			bra		ms0020
ms0050		cmp.w	#2,d2				; moving south ?
			bne.s	ms0060				; must be west then
			addq.w	#1,2(a0)			; modify y position
			bra		ms0020
ms0060		subq.w	#1,(a0)				; modify x psition
			bra		ms0020
			
change_direction
			lea		play_map,a1			; map data
			lsr.w	#2,d0				; normalise spirit pos
			lsr.w	#2,d1
			mulu.w	#34,d1				; y offset
			add.w	d0,d1				; total offset
			add.w	d1,a1				; spirit location
			cmp.b	#cursor,(a1)		; spirit been killed ?
			bne.s	cd0000				; skip if not
			move.w	#-1,4(a0)			; kill the spirit
			move.b	#diamond,(a1)		; change cage to diamond
			rts							; return, all done
cd0000		move.l	a1,-(sp)			; save spirit pointer
			lea		jump_table,a1		; table off addresses
			lsl.w	#2,d2				; offset into table
			move.l	(a1,d2.w),a1		; address of routine
			jmp		(a1)				; do correct routine
jump_table	dc.l	s_north,s_east,s_south,s_west

s_north		move.l	(sp)+,a1			; recover spirit pointer
* can the spirit turn left ?
			cmp.b	#empty,-1(a1)		; empty square ?
			beq		sn_left				; skip if it can
			cmp.b	#earth,-1(a1)		; earth ?
			beq		sn_left				; skip if it can
			cmp.b	#cage,-1(a1)		; cage ?
			beq		sn_left2			; skip if it can
* can the spirit go straigh on ?
			cmp.b	#empty,-34(a1)		; empty square ?
			beq		sn_straight			; skip if it can
			cmp.b	#earth,-34(a1)		; earth ?
			beq		sn_straight			; skip if it can
			cmp.b	#cage,-34(a1)		; cage ?
			beq		sn_straight2		; skip if it can
* can the spirit turn right ?
			cmp.b	#empty,1(a1)		; empty square ?
			beq		sn_right			; skip if it can
			cmp.b	#earth,1(a1)		; earth ?
			beq		sn_right			; skip if it can
			cmp.b	#cage,1(a1)			; cage ?
			beq		sn_right2			; skip if it can
* spirit must reverse direction
			move.w	#2,4(a0)			; spirit goes south
			addq.w	#1,2(a0)			; change y position
			rts							; all done
sn_left2	move.b	#cursor,-1(a1)
sn_left		move.w	#3,4(a0)			; spirit goes west
			subq.w	#1,(a0)				; change x position
			rts
sn_straight2	move.b	#cursor,-34(a1)
sn_straight	subq.w	#1,2(a0)			; change y position
			rts
sn_right2	move.b	#cursor,1(a1)
sn_right	move.w	#1,4(a0)			; spirit goes east
			addq.w	#1,(a0)				; change x position
			rts

s_east		move.l	(sp)+,a1			; recover spirit pointer
* can the spirit turn left ?
			cmp.b	#empty,-34(a1)		; empty square ?
			beq		se_left				; skip if it can
			cmp.b	#earth,-34(a1)		; earth ?
			beq		se_left				; skip if it can
			cmp.b	#cage,-34(a1)		; cage ?
			beq		se_left2			; skip if it can
* can the spirit go straigh on ?
			cmp.b	#empty,1(a1)		; empty square ?
			beq		se_straight			; skip if it can
			cmp.b	#earth,1(a1)		; earth ?
			beq		se_straight			; skip if it can
			cmp.b	#cage,1(a1)			; cage ?
			beq		se_straight2		; skip if it can
* can the spirit turn right ?
			cmp.b	#empty,34(a1)		; empty square ?
			beq		se_right			; skip if it can
			cmp.b	#earth,34(a1)		; earth ?
			beq		se_right			; skip if it can
			cmp.b	#cage,34(a1)		; cage ?
			beq		se_right2			; skip if it can
* spirit must reverse direction
			move.w	#3,4(a0)			; spirit goes west
			subq.w	#1,(a0)				; change x position
			rts							; all done
se_left2	move.b	#cursor,-34(a1)
se_left		move.w	#0,4(a0)			; spirit goes north
			subq.w	#1,2(a0)			; change y position
			rts
se_straight2	move.b	#cursor,1(a1)
se_straight	addq.w	#1,(a0)				; change x position
			rts
se_right2	move.b	#cursor,34(a1)
se_right	move.w	#2,4(a0)			; spirit goes south
			addq.w	#1,2(a0)			; change y position
			rts
			
s_south		move.l	(sp)+,a1			; recover spirit pointer
* can the spirit turn left ?
			cmp.b	#empty,1(a1)		; empty square ?
			beq		ss_left				; skip if it can
			cmp.b	#earth,1(a1)		; earth ?
			beq		ss_left				; skip if it can
			cmp.b	#cage,1(a1)			; cage ?
			beq		ss_left2			; skip if it can
* can the spirit go straigh on ?
			cmp.b	#empty,34(a1)		; empty square ?
			beq		ss_straight			; skip if it can
			cmp.b	#earth,34(a1)		; earth ?
			beq		ss_straight			; skip if it can
			cmp.b	#cage,34(a1)		; cage ?
			beq		ss_straight2		; skip if it can
* can the spirit turn right ?
			cmp.b	#empty,-1(a1)		; empty square ?
			beq		ss_right			; skip if it can
			cmp.b	#earth,-1(a1)		; earth ?
			beq		ss_right			; skip if it can
			cmp.b	#cage,-1(a1)		; cage ?
			beq		ss_right2			; skip if it can
* spirit must reverse direction
			move.w	#0,4(a0)			; spirit goes north
			subq.w	#1,2(a0)			; change y position
			rts							; all done
ss_left2	move.b	#cursor,1(a1)
ss_left		move.w	#1,4(a0)			; spirit goes east
			addq.w	#1,(a0)				; change x position
			rts
ss_straight2	move.b	#cursor,34(a1)
ss_straight	addq.w	#1,2(a0)			; change y position
			rts
ss_right2	move.b	#cursor,-1(a1)
ss_right	move.w	#3,4(a0)			; spirit goes west
			sub.w	#1,(a0)				; change x position
			rts

s_west		move.l	(sp)+,a1			; recover spirit pointer
* can the spirit turn left ?
			cmp.b	#empty,34(a1)		; empty square ?
			beq		sw_left				; skip if it can
			cmp.b	#earth,34(a1)		; earth ?
			beq		sw_left				; skip if it can
			cmp.b	#cage,34(a1)		; cage ?
			beq		sw_left2			; skip if it can
* can the spirit go straight on ?
			cmp.b	#empty,-1(a1)		; empty square ?
			beq		sw_straight			; skip if it can
			cmp.b	#earth,-1(a1)		; earth ?
			beq		sw_straight			; skip if it can
			cmp.b	#cage,-1(a1)		; cage ?
			beq		sw_straight2		; skip if it can
* can the spirit turn right ?
			cmp.b	#empty,-34(a1)		; empty square ?
			beq		sw_right			; skip if it can
			cmp.b	#earth,-34(a1)		; earth ?
			beq		sw_right			; skip if it can
			cmp.b	#cage,-34(a1)		; cage ?
			beq		sw_right2			; skip if it can
* spirit must reverse direction
			move.w	#1,4(a0)			; spirit goes east
			addq.w	#1,(a0)				; change x position
			rts							; all done
sw_left2	move.b	#cursor,34(a1)
sw_left		move.w	#2,4(a0)			; spirit goes south
			addq.w	#1,2(a0)			; change y position
			rts
sw_straight2	move.b	#cursor,-1(a1)
sw_straight	subq.w	#1,(a0)				; change x position
			rts
sw_right2	move.b	#cursor,-34(a1)
sw_right	move.w	#0,4(a0)			; spirit goes north
			subq.w	#1,2(a0)			; change y position
			rts
			
plot_spirits
			addq.w	#1,choice
			and.w	#$03,choice
			move.w	spirits,d5			; number to plot
			bne.s	pls0000				; skip if some to plot
			rts
pls0000		subq.w	#1,d5				; one less in dbra
			lea		play_spir,a0		; spirit data
pls0010		movem.w	(a0),d0-d2			; spirit x,y, direction
			tst.w	d2					; spirit dead ?
			bpl.s	spirit_plot			; plot the spirit
pls0020		lea		6(a0),a0			; next spirit data
			dbra	d5,pls0010			; do them all
			rts
			
spirit_plot	movem.w	d0-d1,-(sp)
			sub.w	man_x,d0			; x offset from screen centre
			bpl.s	sp1000
			neg.w	d0
sp1000		sub.w	man_y,d1			; y offset from screen centre
			bpl.s	sp1010
			neg.w	d1
sp1010		add.w	d0,d1				; distance from repton
			cmp.w	#4,d1				; repton dead ?
			bge.s	sp1020				; skip if not
			move.w	#1,dead
sp1020		movem.w	(sp)+,d0-d1
			sub.w	man_x,d0
			sub.w	man_y,d1
			add.w	#12,d0				; normalise
			bmi		min000				; off screen
			add.w	#12,d1
			bmi		min100				; off screen
			cmp.w	#24,d0
			bgt		min200				; off screen
			cmp.w	#24,d1
			bgt		min300				; off screen
			move.w	d0,d2				; copy x,y positions			
			move.w	d1,d3			
			lsr.w	#2,d0				; character offsets
			lsr.w	#2,d1
			and.w	#$03,d2
			and.w	#$03,d3				; byte offsets
			move.l	scr1,a1				; screen pointer
			lea		24(a1),a1
			mulu.w	#32*160,d1			; screen y offset
			mulu.w	#160*8,d3			; individual offset
			lsl.w	#4,d0				; screen x offset
			add.w	d0,d1				; total offset
			add.w	d3,d1
			add.w	d1,a1				; screen pointer
			tst.w	d2					; sitting in normal square ?
			beq		plot_norm			; skip if it is
			cmp.w	#1,d2				; offset by byte ?
			beq		plot_byte			; skip if it is
			lea		8(a1),a1			; offset the character
			cmp.w	#2,d2				; sitting in square ?
			beq		plot_norm
			bra		plot_byte

min000		neg.w	d0					; make it positive
			cmp.w	#4,d0				; partly visible on left side ?
			bge		pls0020				; exit if not
min010		move.l	a0,-(sp)
			move.w	d5,-(sp)
			lea		chars+spirit1*512,a0
			tst.w	choice
			beq.s	min020				; skip if corret character
			lea		chars+spirit2*512,a0
			btst.b	#0,choice+1
			bne.s	min020
			lea		chars+spirit3*512,a0; other character
min020		btst	#0,d0				; offset by a byte ?
			beq		min025
			lea		off_chars-chars(a0),a0
min025		move.l	scr1,a1				; screen pointer
			lea		24(a1),a1
			add.w	#12,d1				; y offset from centre
			bmi.s	min030				; check for partly visible
			cmp.w	#24,d1				; check for partly visible
			bgt.s	min040				; skip if partly/not visible
			move.w	#31,d5				; plot all 32 lines
			mulu.w	#160*8,d1			; screen y offset
			add.w	d1,a1				; screen pointer
			bra		min_plot			; plot the character
* character partly off the top of the screen
min030		neg.w	d1					; make it positive
			cmp.w	#4,d1				; is it visible ?
			bge		min050				; exit if not
			move.w	#4,d2
			sub.w	d1,d2				; offset into character
			move.w	d2,d5				; to make dbra count
			lsl.w	#3,d5				; * 8
			subq.w	#1,d5				; 1 less for dbra
			mulu.w	#16*8,d2			; offset into character data
			add.w	d2,a0				; modify the pointer
			bra		min_plot
* character off the bottom of the screen
min040		cmp.w	#28,d1				; is it still visible ?
			bge		min050				; exit if not
			move.w	#28,d5				; to make dbra count
			sub.w	d1,d5				; groups of 8 to plot
			lsl.w	#3,d5				; * 8
			subq.w	#1,d5				; 1 less for dbra
			lea		12800(a1),a1		; avoid overflow
			sub.w	#10,d1
			mulu.w	#160*8,d1			; y offset to screen
			add.w	d1,a1				; adjust screen pointer
			bra		min_plot
*
min050		move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover saved vars
			bra		pls0020				; exit plot
*
* character partly off screen top off screen, not left, possibly right
*
min100		neg.w	d1					; make it positive
			cmp.w	#4,d1				; is it visible
			bge		pls0020				; exit if not
			move.l	a0,-(sp)
			move.w	d5,-(sp)			; save vars
			lea		chars+spirit1*512,a0
			tst.w	choice
			beq.s	min110				; skip if corret character
			lea		chars+spirit2*512,a0
			btst.b	#0,choice+1
			bne.s	min110
			lea		chars+spirit3*512,a0; other character
min110		move.l	scr1,a1				; screen pointer
			lea		24(a1),a1
			move.w	#4,d5
			sub.w	d1,d5				; to make dbra
			lsl.w	#7,d1				; pointer adjust value
			add.w	d1,a0				; correct area
			lsl.w	#3,d5				; * 8
			subq.w	#1,d5				; 1 less for dbra
			cmp.w	#24,d0				; off the right of the screen ?
			ble		min190				; skip if not
			cmp.w	#28,d0				; is it visible ?
			bge		min050				; exit if not
			lea		16*6(a1),a1			; adjust pointer
			btst	#1,d0				; done correct offset ?
			beq.s	min120				; skip if we have
			lea		8(a1),a1			; adjust the pointer
min120		btst	#0,d0				; offset by 1 ?
			beq.s	min130				; skip if not
			lea		off_chars-chars(a0),a0
min130		bra		min_plot			; plot the character
			
min190		move.w	d0,d2				; copy x position
			bclr	#0,d2				; lose lsb
			lsl.w	#2,d2				; x offet to screen pointer
			add.w	d2,a1				; adjust
			lsr.w	#1,d0				; offset by a byte ?
			bcc		pn0000				; skip if not
			lea		off_chars-chars(a0),a0	; use offset characters
			bra		pby0010				; do offset by byte
			
min200		cmp.w	#28,d0				; not visible ?
			bge		pls0020				; exit if not visible
			move.l	scr1,a1
			lea		120(a1),a1
			btst	#1,d0				; done correct offset ?
			beq.s	min210				; skip if we have
			lea		8(a1),a1			; adjust pointer
min210		cmp.w	#28,d1				; visible ?
			bge		pls0020				; exit if not
			move.l	a0,-(sp)			; save regs
			lea		chars+spirit1*512,a0
			tst.w	choice
			beq.s	min215				; skip if corret character
			lea		chars+spirit2*512,a0
			btst.b	#0,choice+1
			bne.s	min215
			lea		chars+spirit3*512,a0; other character
min215		btst	#0,d0				; offset by a byte ?
			beq.s	min218
			lea		off_chars-chars(a0),a0
min218		move.w	d5,-(sp)
			move.w	#31,d5				; assume plot it all
			cmp.w	#24,d1				; is it all on screen ?
			ble.s	min220				; skip if it is
			move.w	#28,d5
			sub.w	d1,d5				
			lsl.w	#3,d5
			subq.w	#1,d5
			lea		12800(a1),a1		; avoid overflow
			sub.w	#10,d1
min220		mulu.w	#160*8,d1			; screen offset to pointer
			add.w	d1,a1				; make screen pointer
			bra		min_plot			; do plot routine
*
min300		cmp.w	#28,d1				; spirit visible ?
			bge		pls0020				; exit if not
			move.l	scr1,a1
			lea		24(a1),a1			; adjust pointer
			move.l	a0,-(sp)
			move.w	d5,-(sp)
			lea		chars+spirit1*512,a0
			tst.w	choice
			beq.s	min310				; skip if corret character
			lea		chars+spirit2*512,a0
			btst.b	#0,choice+1
			bne.s	min310
			lea		chars+spirit3*512,a0; other character
min310		move.w	#28,d5				; to make dbra count
			sub.w	d1,d5
			lsl.w	#3,d5
			subq.w	#1,d5
			lea		12800(a1),a1		; avoid overflow
			sub.w	#10,d1
			mulu.w	#160*8,d1			; offset to screen pointer
			add.w	d1,a1				; y offset to s p
			move.w	d0,d2				; copy x position
			bclr	#0,d2				; lose lsb
			lsl.w	#2,d2				; x offset to screen pntr
			add.w	d2,a1
			lsr.w	#1,d0				; get offset bit in carry
			bcc		pn0000				; do plot routine
			lea		off_chars-chars(a0),a0	; different characters
			bra		pby0010				; do offset characters
*
* This routine jumps to the correct routine to plot the spirit
*
min_plot	cmp.w	#1,d0				; plot r3q ?
			beq		sr3q				; skip if so
			cmp.w	#2,d0				; plot r1/2 ?
			beq		srh					; skip if so
			cmp.w	#3,d0				; plot rbyte /
			beq		srb					; skip if so
			cmp.w	#25,d0				; plot l3q ?
			beq		sl3q				; skip if so
			cmp.w	#26,d0				; plot l1/2
			beq		slh					; skip if so
			cmp.w	#27,d0				; plot lbyte ?
			beq		slb					; skip if so
			move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover vars
			move.w	#$700,colours		; show error
			bra		pls0020				; exit
*
sr3q		lea		4(a0),a0			; skip left part of char
			movem.l	(a0)+,d0-d1
			clr.l	d2
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			not.l	d2
			and.l	d2,(a1)
			and.l	d2,4(a1)
			or.l	d0,(a1)
			or.l	d1,4(a1)
			move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,8(a1)
			and.b	d1,10(a1)
			and.b	d1,12(a1)
			and.b	d1,14(a1)
			move.l	(a0)+,d0
			or.b	d0,14(a1)
			lsr.l	#8,d0
			or.b	d0,12(a1)
			lsr.l	#8,d0
			or.b	d0,10(a1)
			lsr.l	#8,d0
			or.b	d0,8(a1)
			lea		160(a1),a1
			dbra	d5,sr3q
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pls0020

srh			lea		8(a0),a0			; skip left half of character
			movem.l	(a0)+,d0-d1			; line of data
			clr.l	d4
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			not.l	d4
			and.l	d4,(a1)
			and.l	d4,4(a1)
			or.l	d0,(a1)
			or.l	d1,4(a1)
			lea		160(a1),a1			; next screen line
			dbra	d5,srh
			move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover reg
			bra		pls0020				; done

srb			lea		12(a0),a0			; skip left 3q of char
			move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,(a1)
			and.b	d1,2(a1)
			and.b	d1,4(a1)
			and.b	d1,6(a1)
			move.l	(a0)+,d0
			or.b	d0,6(a1)
			lsr.l	#8,d0
			or.b	d0,4(a1)
			lsr.l	#8,d0
			or.b	d0,2(a1)
			lsr.l	#8,d0
			or.b	d0,0(a1)
			lea		160(a1),a1
			dbra	d5,srb
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pls0020

sl3q		move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,1(a1)
			and.b	d1,3(a1)
			and.b	d1,5(a1)
			and.b	d1,7(a1)
			move.l	(a0)+,d0
			or.b	d0,7(a1)
			lsr.l	#8,d0
			or.b	d0,5(a1)
			lsr.l	#8,d0
			or.b	d0,3(a1)
			lsr.l	#8,d0
			or.b	d0,1(a1)
			movem.l	(a0)+,d0-d2
			clr.l	d2
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			not.l	d2
			and.l	d2,8(a1)
			and.l	d2,12(a1)
			or.l	d0,8(a1)
			or.l	d1,12(a1)
			lea		160(a1),a1
			dbra	d5,sl3q
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pls0020


slh			movem.l	(a0)+,d0-d3			; line of data
			clr.l	d4
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			not.l	d4
			and.l	d4,(a1)
			and.l	d4,4(a1)
			or.l	d0,(a1)
			or.l	d1,4(a1)
			lea		160(a1),a1			; next screen line
			dbra	d5,slh
			move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover reg
			bra		pls0020				; done

slb			move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,1(a1)
			and.b	d1,3(a1)
			and.b	d1,5(a1)
			and.b	d1,7(a1)
			move.l	(a0)+,d0
			or.b	d0,7(a1)
			lsr.l	#8,d0
			or.b	d0,5(a1)
			lsr.l	#8,d0
			or.b	d0,3(a1)
			lsr.l	#8,d0
			or.b	d0,1(a1)
			lea		160(a1),a1
			lea		12(a0),a0			; skip left 3q of char
			dbra	d5,slb
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pls0020

plot_norm	move.l	a0,-(sp)			; save register
			lea		chars+spirit1*512,a0
			tst.w	choice
			beq.s	pn_start			; skip if corret character
			lea		chars+spirit2*512,a0
			btst.b	#0,choice+1
			bne.s	pn_start
			lea		chars+spirit3*512,a0; other character
pn_start	move.w	d5,-(sp)
			move.w	#31,d5				; loop counter
pn0000		movem.l	(a0)+,d0-d3			; line of data
			clr.l	d4
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			not.l	d4
			and.l	d4,(a1)
			and.l	d4,4(a1)
			clr.l	d4
			or.l	d2,d4
			or.l	d3,d4
			swap	d2
			swap	d3
			or.l	d2,d4
			or.l	d3,d4
			swap	d2
			swap	d3
			not.l	d4
			and.l	d4,8(a1)
			and.l	d4,12(a1)
			or.l	d0,(a1)
			or.l	d1,4(a1)
			or.l	d2,8(a1)
			or.l	d3,12(a1)
			lea		160(a1),a1			; next screen line
			dbra	d5,pn0000
			move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover reg
			bra		pls0020				; done
			
plot_byte	move.l	a0,-(sp)
			lea		off_chars+spirit1*512,a0
			tst.w	choice
			beq.s	pby0000				; skip if corret character
			lea		off_chars+spirit2*512,a0
			btst.b	#0,choice+1
			bne.s	pby0000
			lea		off_chars+spirit3*512,a0; other character
pby0000		move.w	d5,-(sp)
			move.w	#31,d5				; loop counter
pby0010		move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,1(a1)
			and.b	d1,3(a1)
			and.b	d1,5(a1)
			and.b	d1,7(a1)
			move.l	(a0)+,d0
			or.b	d0,7(a1)
			lsr.l	#8,d0
			or.b	d0,5(a1)
			lsr.l	#8,d0
			or.b	d0,3(a1)
			lsr.l	#8,d0
			or.b	d0,1(a1)
			movem.l	(a0)+,d0-d1
			clr.l	d2
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			not.l	d2
			and.l	d2,8(a1)
			and.l	d2,12(a1)
			or.l	d0,8(a1)
			or.l	d1,12(a1)
			move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,16(a1)
			and.b	d1,18(a1)
			and.b	d1,20(a1)
			and.b	d1,22(a1)
			move.l	(a0)+,d0
			or.b	d0,22(a1)
			lsr.l	#8,d0
			or.b	d0,20(a1)
			lsr.l	#8,d0
			or.b	d0,18(a1)
			lsr.l	#8,d0
			or.b	d0,16(a1)
			lea		160(a1),a1
			dbra	d5,pby0010
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pls0020
			
offset_chars
			lea		chars,a0			; start characters
			lea		off_chars,a1		; destination characters
			move.w	#44,d5				; 45 character to convert
oc0000		move.w	#31,d4				; 32 lines per character
oc0010		movep.l	(a0),d0
			move.l	d0,(a1)
			movep.l	1(a0),d0
			movep.l	d0,4(a1)
			movep.l	8(a0),d0
			movep.l	d0,5(a1)
			movep.l	9(a0),d0
			move.l	d0,12(a1)
			lea		16(a0),a0
			lea		16(a1),a1
			dbra	d4,oc0010
			dbra	d5,oc0000
			rts

do_mons		move.w	monsters+2,d5			; number of monsters
			bne.s	dom0000					; skip if some in level
			rts
dom0000		subq.w	#1,d5					; one less in dbra
			lea		play_eggs,a0			; monster data
dom0010		tst.w	4(a0)					; monster dead ?
			bmi.s	dom0020					; skip if it is
			tst.w	4(a0)
			beq		egg_fall				; can the egg fall ?
			cmp.w	#2,4(a0)				; drop straight down ?
			beq		egg_down				; skip if it is
			cmp.w	#18,4(a0)				; finished cracking ?
			beq		hatch_it
			cmp.w	#34,4(a0)
			bge		dom0020					; else active monster
			addq.w	#1,4(a0)				; increment the status
dom0020		lea		6(a0),a0				; next monster data
			dbra	d5,dom0010				; do all the monsters
			rts
			
egg_fall	lea		play_map,a1				; map data
			movem.w	(a0),d0-d1				; xo-ordinates
			lsr.w	#2,d0					; normalise
			lsr.w	#2,d1
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			add.w	d1,a1
			cmp.b	#egg,(a1)				; being pushed ?
			beq.s	ef0000
			bra		dom0020					; skip if it is
* can it drop straight down ?
ef0000		cmp.b	#empty,34(a1)			; can the egg go straight down ?
			beq		e_drop					; skip if it can
			cmp.b	#empty,-1(a1)			; can it fall left ?
			bne.s	e_right
			cmp.b	#empty,33(a1)			; can it fall left ?
			beq		e_left					; skip if it can
e_right		cmp.b	#empty,1(a1)			; can it fall right ?
			bne.s	no_edrop				; skip if not
			cmp.b	#empty,35(a1)			; can it fall right ?
			beq		eg_right				; skip if it can
no_edrop	bra		dom0020					; do nothing

e_drop		addq.w	#1,4(a0)				; signal dropping
			addq.w	#4,2(a0)				; increment y position
			clr.b	(a1)					; erase egg
			move.b	#egg,34(a1)				; plot below
			cmp.b	#repton,68(a1)			; landed on repton ?
			bne		dom0020					; skip if not
			move.w	#1,dead					; signal repton dead
			bra		dom0020					; done
			
e_left		cmp.b	#diamond,34(a1)		; can roll of diamond
			beq		el000				; skip if it can fall
			cmp.b	#rock,34(a1)
			beq		el000				; skip if it can fall
			cmp.b	#crown,34(a1)
			beq		el000				; skip if it can fall
			cmp.b	#skull,34(a1)
			beq		el000				; skip if it can fall
			cmp.b	#key,34(a1)
			beq		el000				; skip if it can fall
			cmp.b	#rleft,34(a1)
			beq		el000				; skip if it can fall
			cmp.b	#rleft2,34(a1)
			beq		el000				; skip if it can fall
			cmp.b	#timebomb,34(a1)
			beq		el000				; skip if it can fall
			cmp.b	#tcapsule,34(a1)
			beq		el000				; skip if it can fall
			cmp.b	#egg,34(a1)
			beq		el000				; skip if it can fall
			bra		e_right				; check fall right
el000		move.w	#1,4(a0)				; signal dropping
			addq.w	#4,2(a0)				; egg falls by 1
			subq.w	#4,(a0)					; goes left by 1
			clr.b	(a1)					; erase egg
			move.b	#egg,33(a1)				; new position
			cmp.b	#repton,67(a1)			; landed on repton ?
			bne		dom0020					; skip if not
			move.w	#1,dead					; signal repton dead
			bra		dom0020					; done			

eg_right	cmp.b	#diamond,34(a1)		; can roll of diamond
			beq		er000				; skip if it can fall
			cmp.b	#rock,34(a1)
			beq		er000				; skip if it can fall
			cmp.b	#crown,34(a1)
			beq		er000				; skip if it can fall
			cmp.b	#skull,34(a1)
			beq		er000				; skip if it can fall
			cmp.b	#key,34(a1)
			beq		er000				; skip if it can fall
			cmp.b	#rright,34(a1)
			beq		er000				; skip if it can fall
			cmp.b	#rright2,34(a1)
			beq		er000				; skip if it can fall
			cmp.b	#timebomb,34(a1)
			beq		er000				; skip if it can fall
			cmp.b	#tcapsule,34(a1)
			beq		er000				; skip if it can fall
			cmp.b	#egg,34(a1)
			beq		er000				; skip if it can fall
			bra		dom0020
er000		move.w	#1,4(a0)				; signal dropping
			addq.w	#4,2(a0)				; egg falls by 1
			addq.w	#4,(a0)					; goes right by 1
			clr.b	(a1)					; erase egg
			move.b	#egg,35(a1)				; new position
			cmp.b	#repton,69(a1)			; landed on repton ?
			bne		dom0020					; skip if not
			move.w	#1,dead					; signal repton dead
			bra		dom0020					; done			

egg_down	lea		play_map,a1				; map data
			movem.w	(a0),d0-d1				; xo-ordinates
			lsr.w	#2,d0					; normalise
			lsr.w	#2,d1
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			add.w	d1,a1
			cmp.b	#egg,(a1)				; being pushed ?
			beq		ed0000					; skip if not
			bra		dom0020
ed0000		tst.b	34(a1)					; continue to drop ?
			beq.s	ed0010					; skip if it can
			addq.w	#1,4(a0)				; goes to cracked status
			move.b	#cracked,(a1)			; change the character
			bra		dom0020					; done
ed0010		clr.b	(a1)					; erase egg
			move.b	#egg,34(a1)				; new pos
			addq.w	#4,2(a0)				; change co-ord
			cmp.b	#repton,68(a1)			; landed on repton ?
			bne		dom0020					; skip if not
			move.w	#1,dead					; signal repton dead
			bra		dom0020					; done
			
hatch_it	lea		play_map,a1				; map data
			movem.w	(a0),d0-d1				; xo-ordinates
			lsr.w	#2,d0					; normalise
			lsr.w	#2,d1
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			add.w	d1,a1
			clr.b	(a1)					; erase the cracked egg
			addq.w	#1,4(a0)				; monster sits there...
			bra		dom0020					; done
			
move_monster
			movem.w	(a0),d0-d1				; moster co-ords
			and.w	#$03,d0					; offset positions
			and.w	#$03,d1
			add.w	d0,d1					; check both
			beq.s	mm0030					; skip if monster can move
			btst.b	#0,4(a0)				; already moving up ?
			beq.s	mm0000
			subq.w	#1,2(a0)				; change y pos
			bra		pmo0015					; done
mm0000		btst.b	#1,4(a0)				; already moving right ?
			beq.s	mm0010
			addq.w	#1,(a0)					; change x pos
			bra		pmo0015					; done
mm0010		btst.b	#2,4(a0)				; already moving down ?
			beq.s	mm0020
			addq.w	#1,2(a0)				; change y pos
			bra		pmo0015					; skip if not
mm0020		btst.b	#3,4(a0)				; already moving up ?
			beq		pmo0015					; exit if not
			subq.w	#1,(a0)					; change x pos
			bra		pmo0015					; skip if not
mm0030		movem.w	(a0),d0-d1				; get monster co-ords
			clr.w	moves					; number of directions
			lsr.w	#2,d0					; normalise			
			lsr.w	#2,d1			
			lea		play_map,a1				; map data
			mulu.w	#34,d1
			add.w	d0,d1
			add.w	d1,a1					; monster position
			movem.w	man_x,d0-d1				; reptons position
* can monster move right ?
			cmp.w	(a0),d0					; man to our right ?
			blo.s	mm0050					; skip if it can't
			cmp.b	#empty,1(a1)			; anything in the way
			beq.s	mm0040					; skip if not
			cmp.b	#earth,1(a1)			
			bne.s	mm0050
mm0040		or.w	#$02,moves				; set posible direction
* can the monster move down ?
mm0050		cmp.w	2(a0),d1				; man below monster ?
			blo.s	mm0070					; skip if it can't
			cmp.b	#empty,34(a1)			; anything in the way
			beq.s	mm0060					; skip if not
			cmp.b	#earth,34(a1)			
			bne.s	mm0070
mm0060		or.w	#$04,moves				; set posible direction
* can the monster move left ?
mm0070		cmp.w	(a0),d0					; man to left ?
			bge.s	mm0090					; skip if it can't
			cmp.b	#empty,-1(a1)			; anything in the way
			beq.s	mm0080					; skip if not
			cmp.b	#earth,-1(a1)			
			bne.s	mm0090
mm0080		or.w	#$08,moves				; set posible direction
* can the monster move up ?
mm0090		cmp.w	2(a0),d1				; man above ?
			bge.s	mm0110					; skip if it can't
			cmp.b	#empty,-34(a1)			; anything in the way
			beq.s	mm0100					; skip if not
			cmp.b	#earth,-34(a1)			
			bne.s	mm0110
mm0100		or.w	#$01,moves				; set posible direction
* new choose one at random
mm0110		tst.w	moves					; can the monster move ?
			beq		pmo0015					; exit if it can't
mm0120		jsr		random					; random number in d0
			and.w	#$03,d0					; limit range
			btst.b	d0,moves+1				; can we move that way
			beq.s	mm0120					; skip if we can't
mm0125		clr.b	4(a0)					; clear possible direction
			bset.b	d0,4(a0)				; set the direction flag
			tst.w	d0						; moving up ?
			bne.s	mm0130					; skip if not
			subq.w	#1,2(a0)				; start the monster moving
			bra		pmo0015
mm0130		cmp.w	#1,d0					; moving right ?
			bne.s	mm0140
			addq.w	#1,(a0)					; start the monster moving
			bra		pmo0015
mm0140		cmp.w	#2,d0					; moving down ?
			bne.s	mm0150
			addq.w	#1,2(a0)				; start the monster moving
			bra		pmo0015
mm0150		subq.w	#1,(a0)					; start the monster moving
			bra		pmo0015

kill_mons	move.w	monsters+2,d5			; number of monsters
			bne.s	km0000					; skip if there are some
			rts
km0000		subq.w	#1,d5					; 1 less for dbra
			lea		play_eggs,a0			; moster data
km0010		tst.w	4(a0)					; monster alive ?
			bmi		km0050					; skip if not
			cmp.w	#19,4(a0)				; monster hatched ?
			blo		km0050					; skip if not
* check to see if it is dead
			movem.w	(a0),d0-d1			; mon co-ords
			lea		play_map,a1			; map data
			lsr.w	#2,d0				; normalise
			lsr.w	#2,d1
			mulu.w	#34,d1
			add.w	d0,d1
			add.w	d1,a1				; monster location
			cmp.b	#empty,(a1)			; monster ok ?
			beq		km0020				; skip if it is
			cmp.b	#earth,(a1)			; monster ok ?
			beq		km0020				; skip if he is
			move.w	#-1,4(a0)			; kill it
			move.w	#-1,(a0)			; move monster off playfield
			subq.l	#1,mkilled			; one less monster
			add.l	#20,score			; 20 points for killing it
			bra.s	km0050
km0020		movem.w	(a0),d0-d1
			and.w	#$03,d0
			and.w	#$03,d1
			tst.w	d0					; offset in the x direction ?
			beq.s	km0030				; skip if we are
			cmp.b	#empty,1(a1)		; monster ok ?
			beq.s	km0050				; skip if it is
			cmp.b	#earth,1(a1)		; monster ok ?
			beq.s	km0050				; skip if ti is
			move.w	#-1,4(a0)			; kill it
			move.w	#-1,(a0)			; move monster off playfield
			subq.l	#1,mkilled			; one less monster
			add.l	#20,score			; 20 points for killing it
			bra.s	km0050
km0030		tst.w	d1					; offset in the y direction ?
			beq.s	km0050				; skip if not
			cmp.b	#empty,34(a1)		; monster ok ?
			beq.s	km0050				; skip if it is
			cmp.b	#earth,34(a1)		; monster ok ?
			beq.s	km0050				; skip if it is
			move.w	#-1,4(a0)			; kill it
			move.w	#-1,(a0)			; move monster off playfield
			subq.l	#1,mkilled			; one less monster
			add.l	#20,score			; 20 points for killing it
km0050		lea		6(a0),a0			; next monster data
			dbra	d5,km0010
			rts			

plot_mons	move.w	monsters+2,d5			; number of monsters
			bne.s	pmo0000					; skip if there are some
			rts
pmo0000		subq.w	#1,d5					; 1 less for dbra
			lea		play_eggs,a0			; moster data
pmo0010		tst.w	4(a0)					; monster alive ?
			bmi.s	pmo0020					; skip if not
			cmp.w	#19,4(a0)				; monster hatched ?
			blo.s	pmo0020					; skip if not
ph_do		cmp.w	#34,4(a0)				; monster moving ?
			bge		move_monster			; skip if it is
pmo0015		cmp.w	#19,4(a0)				; plotting the monster ?
			bge		plot_him				; skip if we are
pmo0020		lea		6(a0),a0				; next monster
			dbra	d5,pmo0010				; do them all
			rts

plot_him	movem.w	(a0),d0-d1			; monster co - ords
			sub.w	man_x,d0			; x offset from screen centre
			bpl.s	ph1000
			neg.w	d0
ph1000		sub.w	man_y,d1			; y offset from screen centre
			bpl.s	ph1010
			neg.w	d1
ph1010		add.w	d0,d1				; distance from repton
			cmp.w	#4,d1				; repton dead ?
			bge.s	ph1020				; skip if not
			move.w	#1,dead				; kill repton
ph1020		movem.w	(a0),d0-d1
			sub.w	man_x,d0
			sub.w	man_y,d1
			add.w	#12,d0				; normalise
			bmi		mon000				; off screen
			add.w	#12,d1
			bmi		mon100				; off screen
			cmp.w	#24,d0
			bgt		mon200				; off screen
			cmp.w	#24,d1
			bgt		mon300				; off screen
			move.w	d0,d2				; copy x,y positions			
			move.w	d1,d3			
			lsr.w	#2,d0				; character offsets
			lsr.w	#2,d1
			and.w	#$03,d2
			and.w	#$03,d3				; byte offsets
			move.l	scr1,a1				; screen pointer
			lea		24(a1),a1			; adjust pointer
			mulu.w	#32*160,d1			; screen y offset
			mulu.w	#160*8,d3			; individual offset
			lsl.w	#4,d0				; screen x offset
			add.w	d0,d1				; total offset
			add.w	d3,d1
			add.w	d1,a1				; screen pointer
			tst.w	d2					; sitting in normal square ?
			beq		mon_norm			; skip if it is
			cmp.w	#1,d2				; offset by byte ?
			beq		mon_byte			; skip if it is
			lea		8(a1),a1			; offset the character
			cmp.w	#2,d2				; sitting in square ?
			beq		mon_norm
			bra		mon_byte
			
mon000		neg.w	d0					; make it positive
			cmp.w	#4,d0				; partly visible on left side ?
			bge		pmo0020				; exit if not
mon010		move.l	a0,-(sp)
			move.w	d5,-(sp)
			lea		chars+mon1*512,a0
			tst.w	choice
			beq.s	mon020				; skip if corret character
			lea		chars+mon2*512,a0
			btst.b	#0,choice+1
			bne.s	mon020
			lea		chars+mon3*512,a0; other character
mon020		btst	#0,d0				; offset by a byte ?
			beq		mon025
			lea		off_chars-chars(a0),a0
mon025		move.l	scr1,a1				; screen pointer
			lea		24(a1),a1			; adjust pointer
			add.w	#12,d1				; y offset from centre
			bmi.s	mon030				; check for partly visible
			cmp.w	#24,d1				; check for partly visible
			bgt.s	mon040				; skip if partly/not visible
			move.w	#31,d5				; plot all 32 lines
			mulu.w	#160*8,d1			; screen y offset
			add.w	d1,a1				; screen pointer
			bra		mon_plot			; plot the character
* character partly off the top of the screen
mon030		neg.w	d1					; make it positive
			cmp.w	#4,d1				; is it visible ?
			bge		mon050				; exit if not
			move.w	#4,d2
			sub.w	d1,d2				; offset into character
			move.w	d2,d5				; to make dbra count
			lsl.w	#3,d5				; * 8
			subq.w	#1,d5				; 1 less for dbra
			mulu.w	#16*8,d2			; offset into character data
			add.w	d2,a0				; modify the pointer
			bra		mon_plot
* character off the bottom of the screen
mon040		cmp.w	#28,d1				; is it still visible ?
			bge		mon050				; exit if not
			move.w	#28,d5				; to make dbra count
			sub.w	d1,d5				; groups of 8 to plot
			lsl.w	#3,d5				; * 8
			subq.w	#1,d5				; 1 less for dbra
			lea		12800(a1),a1		; avoid overflow
			sub.w	#10,d1
			mulu.w	#160*8,d1			; y offset to screen
			add.w	d1,a1				; adjust screen pointer
			bra		mon_plot
*
mon050		move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover saved vars
			bra		pmo0020				; exit plot
*
* character partly off screen top off screen, not left, possibly right
*
mon100		neg.w	d1					; make it positive
			cmp.w	#4,d1				; is it visible
			bge		pmo0020				; exit if not
			move.l	a0,-(sp)
			move.w	d5,-(sp)			; save vars
			lea		chars+mon1*512,a0
			tst.w	choice
			beq.s	mon110				; skip if corret character
			lea		chars+mon2*512,a0
			btst.b	#0,choice+1
			bne.s	mon110
			lea		chars+mon3*512,a0; other character
mon110		move.l	scr1,a1				; screen pointer
			lea		24(a1),a1			; adjust pointer
			move.w	#4,d5
			sub.w	d1,d5				; to make dbra
			lsl.w	#7,d1				; pointer adjust value
			add.w	d1,a0				; correct area
			lsl.w	#3,d5				; * 8
			subq.w	#1,d5				; 1 less for dbra
			cmp.w	#24,d0				; off the right of the screen ?
			ble		mon190				; skip if not
			cmp.w	#28,d0				; is it visible ?
			bge		mon050				; exit if not
			lea		16*6(a1),a1			; adjust pointer
			btst	#1,d0				; done correct offset ?
			beq.s	mon120				; skip if we have
			lea		8(a1),a1			; adjust the pointer
mon120		btst	#0,d0				; character offset by 1 ?
			beq.s	mon130				; skip if not
			lea		off_chars-chars(a0),a0
mon130		bra		mon_plot			; plot the character
			
mon190		move.w	d0,d2				; copy x position
			bclr	#0,d2				; lose lsb
			lsl.w	#2,d2				; x offet to screen pointer
			add.w	d2,a1				; adjust
			lsr.w	#1,d0				; offset by a byte ?
			bcc		mn0000				; skip if not
			lea		off_chars-chars(a0),a0	; use offset characters
			bra		pby0010				; do offset by byte
			
mon200		cmp.w	#28,d0				; not visible ?
			bge		pmo0020				; exit if not visible
			move.l	scr1,a1
			lea		24(a1),a1			; adjust pointer
			lea		16*6(a1),a1			; adjust pointer
			btst	#1,d0				; done correct offset ?
			beq.s	mon210				; skip if we have
			lea		8(a1),a1			; adjust pointer
mon210		cmp.w	#28,d1				; visible ?
			bge		pmo0020				; exit if not
			move.l	a0,-(sp)			; save regs
			lea		chars+mon1*512,a0
			tst.w	choice
			beq.s	mon215				; skip if corret character
			lea		chars+mon2*512,a0
			btst.b	#0,choice+1
			bne.s	mon215
			lea		chars+mon3*512,a0; other character
mon215		btst	#0,d0				; offset by a byte ?
			beq.s	mon218
			lea		off_chars-chars(a0),a0
mon218		move.w	d5,-(sp)
			move.w	#31,d5				; assume plot it all
			cmp.w	#24,d1				; is it all on screen ?
			ble.s	mon220				; skip if it is
			move.w	#28,d5
			sub.w	d1,d5				
			lsl.w	#3,d5
			subq.w	#1,d5
			lea		12800(a1),a1		; avoid overflow
			sub.w	#10,d1
mon220		mulu.w	#160*8,d1			; screen offset to pointer
			add.w	d1,a1				; make screen pointer
			bra		mon_plot			; do plot routine
*
mon300		cmp.w	#28,d1				; spirit visible ?
			bge		pmo0020				; exit if not
			move.l	scr1,a1
			lea		24(a1),a1			; adjust pointer
			move.l	a0,-(sp)
			move.w	d5,-(sp)
			lea		chars+mon1*512,a0
			tst.w	choice
			beq.s	mon310				; skip if corret character
			lea		chars+mon2*512,a0
			btst.b	#0,choice+1
			bne.s	mon310
			lea		chars+mon3*512,a0; other character
mon310		move.w	#28,d5				; to make dbra count
			sub.w	d1,d5
			lsl.w	#3,d5
			subq.w	#1,d5
			lea		12800(a1),a1		; avoid overflow
			sub.w	#10,d1
			mulu.w	#160*8,d1			; offset to screen pointer
			add.w	d1,a1				; y offset to s p
			move.w	d0,d2				; copy x position
			bclr	#0,d2				; lose lsb
			lsl.w	#2,d2				; x offset to screen pntr
			add.w	d2,a1
			lsr.w	#1,d0				; get offset bit in carry
			bcc		mn0000				; do plot routine
			lea		off_chars-chars(a0),a0	; different characters
			bra		mb0010				; do offset characters
*
* This routine jumps to the correct routine to plot the spirit
*
mon_plot	cmp.w	#1,d0				; plot r3q ?
			beq		mr3q				; skip if so
			cmp.w	#2,d0				; plot r1/2 ?
			beq		mrh					; skip if so
			cmp.w	#3,d0				; plot rbyte /
			beq		mrb					; skip if so
			cmp.w	#25,d0				; plot l3q ?
			beq		ml3q				; skip if so
			cmp.w	#26,d0				; plot l1/2
			beq		mlh					; skip if so
			cmp.w	#27,d0				; plot lbyte ?
			beq		mlb					; skip if so
			move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover vars
			move.w	#$700,colours		; show error
			bra		pmo0020				; exit
*
mr3q		lea		4(a0),a0			; skip left part of char
			movem.l	(a0)+,d0-d1
			clr.l	d2
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			not.l	d2
			and.l	d2,(a1)
			and.l	d2,4(a1)
			or.l	d0,(a1)
			or.l	d1,4(a1)
			move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,8(a1)
			and.b	d1,10(a1)
			and.b	d1,12(a1)
			and.b	d1,14(a1)
			move.l	(a0)+,d0
			or.b	d0,14(a1)
			lsr.l	#8,d0
			or.b	d0,12(a1)
			lsr.l	#8,d0
			or.b	d0,10(a1)
			lsr.l	#8,d0
			or.b	d0,8(a1)
			lea		160(a1),a1
			dbra	d5,mr3q
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pmo0020

mrh			lea		8(a0),a0			; skip left half of character
			movem.l	(a0)+,d0-d1			; line of data
			clr.l	d4
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			not.l	d4
			and.l	d4,(a1)
			and.l	d4,4(a1)
			or.l	d0,(a1)
			or.l	d1,4(a1)
			lea		160(a1),a1			; next screen line
			dbra	d5,mrh
			move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover reg
			bra		pmo0020				; done

mrb			lea		12(a0),a0			; skip left 3q of char
			move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,(a1)
			and.b	d1,2(a1)
			and.b	d1,4(a1)
			and.b	d1,6(a1)
			move.l	(a0)+,d0
			or.b	d0,6(a1)
			lsr.l	#8,d0
			or.b	d0,4(a1)
			lsr.l	#8,d0
			or.b	d0,2(a1)
			lsr.l	#8,d0
			or.b	d0,0(a1)
			lea		160(a1),a1
			dbra	d5,mrb
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pmo0020

ml3q		move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,1(a1)
			and.b	d1,3(a1)
			and.b	d1,5(a1)
			and.b	d1,7(a1)
			move.l	(a0)+,d0
			or.b	d0,7(a1)
			lsr.l	#8,d0
			or.b	d0,5(a1)
			lsr.l	#8,d0
			or.b	d0,3(a1)
			lsr.l	#8,d0
			or.b	d0,1(a1)
			movem.l	(a0)+,d0-d2
			clr.l	d2
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			not.l	d2
			and.l	d2,8(a1)
			and.l	d2,12(a1)
			or.l	d0,8(a1)
			or.l	d1,12(a1)
			lea		160(a1),a1
			dbra	d5,ml3q
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pmo0020


mlh			movem.l	(a0)+,d0-d3			; line of data
			clr.l	d4
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			not.l	d4
			and.l	d4,(a1)
			and.l	d4,4(a1)
			or.l	d0,(a1)
			or.l	d1,4(a1)
			lea		160(a1),a1			; next screen line
			dbra	d5,mlh
			move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover reg
			bra		pmo0020				; done

mlb			move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,1(a1)
			and.b	d1,3(a1)
			and.b	d1,5(a1)
			and.b	d1,7(a1)
			move.l	(a0)+,d0
			or.b	d0,7(a1)
			lsr.l	#8,d0
			or.b	d0,5(a1)
			lsr.l	#8,d0
			or.b	d0,3(a1)
			lsr.l	#8,d0
			or.b	d0,1(a1)
			lea		160(a1),a1
			lea		12(a0),a0			; skip left 3q of char
			dbra	d5,mlb
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pmo0020


mon_norm	move.l	a0,-(sp)			; save register
			lea		chars+mon1*512,a0
			tst.w	choice
			beq.s	mn_start			; skip if corret character
			lea		chars+mon2*512,a0
			btst.b	#0,choice+1
			bne.s	mn_start
			lea		chars+mon3*512,a0; other character
mn_start	move.w	d5,-(sp)
			move.w	#31,d5				; loop counter
mn0000		movem.l	(a0)+,d0-d3			; line of data
			clr.l	d4
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			or.l	d0,d4
			or.l	d1,d4
			swap	d0
			swap	d1
			not.l	d4
			and.l	d4,(a1)
			and.l	d4,4(a1)
			clr.l	d4
			or.l	d2,d4
			or.l	d3,d4
			swap	d2
			swap	d3
			or.l	d2,d4
			or.l	d3,d4
			swap	d2
			swap	d3
			not.l	d4
			and.l	d4,8(a1)
			and.l	d4,12(a1)
			or.l	d0,(a1)
			or.l	d1,4(a1)
			or.l	d2,8(a1)
			or.l	d3,12(a1)
			lea		160(a1),a1			; next screen line
			dbra	d5,mn0000
			move.w	(sp)+,d5
			move.l	(sp)+,a0			; recover reg
			bra		pmo0020				; done
			
mon_byte	move.l	a0,-(sp)
			lea		off_chars+mon1*512,a0
			tst.w	choice
			beq.s	mb0000				; skip if corret character
			lea		off_chars+mon2*512,a0
			btst.b	#0,choice+1
			bne.s	mb0000
			lea		off_chars+mon3*512,a0; other character
mb0000		move.w	d5,-(sp)
			move.w	#31,d5				; loop counter
mb0010		move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,1(a1)
			and.b	d1,3(a1)
			and.b	d1,5(a1)
			and.b	d1,7(a1)
			move.l	(a0)+,d0
			or.b	d0,7(a1)
			lsr.l	#8,d0
			or.b	d0,5(a1)
			lsr.l	#8,d0
			or.b	d0,3(a1)
			lsr.l	#8,d0
			or.b	d0,1(a1)
			movem.l	(a0)+,d0-d1
			clr.l	d2
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			or.l	d0,d2
			or.l	d1,d2
			swap	d0
			swap	d1
			not.l	d2
			and.l	d2,8(a1)
			and.l	d2,12(a1)
			or.l	d0,8(a1)
			or.l	d1,12(a1)
			move.l	(a0),d0
			clr.w	d1
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			lsr.l	#8,d0
			or.b	d0,d1
			not.b	d1
			and.b	d1,16(a1)
			and.b	d1,18(a1)
			and.b	d1,20(a1)
			and.b	d1,22(a1)
			move.l	(a0)+,d0
			or.b	d0,22(a1)
			lsr.l	#8,d0
			or.b	d0,20(a1)
			lsr.l	#8,d0
			or.b	d0,18(a1)
			lsr.l	#8,d0
			or.b	d0,16(a1)
			lea		160(a1),a1
			dbra	d5,mb0010
			move.w	(sp)+,d5
			move.l	(sp)+,a0
			bra		pmo0020

random		movem.w	d1-d2,-(sp)			; random number
			move.w	rand_num,d0			; returns in d0
			clr.w	d1
			clr.w	d2
			btst	#7,d0
			beq.s	ran000
			moveq.w	#1,d1
ran000		btst	#10,d0
			beq.s	ran010
			moveq.w	#1,d2
ran010		eor.w	d2,d1
			lsl.w	#1,d0
			tst.w	d1
			beq.s	ran020
			bset	#0,d0
ran020		move.w	d0,rand_num
			subq.w	#1,rand_count			; change the seed ?
			bne.s	ran030					; skip if not
			move.w	#1023,rand_count		; reset counter
			addq.w	#1,rand_num				; change the seed
ran030		movem.w	(sp)+,d1-d2
			rts
			
start_dir	lea		play_spir,a0			; spirit data
			move.w	spirits,d5				; number of spirits
			bne.s	sd0000					; skip if at least 1 spirit
			rts
sd0000		subq.w	#1,d5					; one less for dbra
sd0010		lea		play_map,a1				; map data
			movem.w	(a0),d0-d1				; spirit location data
			lsr.w	#2,d0					; normalise
			lsr.w	#2,d1
			mulu.w	#34,d1					; y offset
			add.w	d0,d1					; total offset
			add.w	d1,a1					; spirit location pntr
*
* check each location directly around the spirit
* as long as it is not empty of earth then we set the relevant
* bit to 1 to indicate that area is solid
*
* The solid build-up is done in d0 with
* bit 0 - above left
* bit 1 - above
* bit 2 - above right
* bit 3 - left
* bit 4 - right
* bit 5 - below left
* bit 6 - below
* bit 7 - below right
*
			clr.w	d0						; build-up in d0
			cmp.b	#empty,-35(a1)
			beq.s	sd0020
			cmp.b	#earth,-35(a1)
			beq.s	sd0020
			or.w	#$01,d0					; set the solid bit
sd0020		cmp.b	#empty,-34(a1)
			beq.s	sd0030
			cmp.b	#earth,-34(a1)
			beq.s	sd0030
			or.w	#$02,d0					; set the solid bit
sd0030		cmp.b	#empty,-33(a1)
			beq.s	sd0040
			cmp.b	#earth,-33(a1)
			beq.s	sd0040
			or.w	#$04,d0					; set the solid bit
sd0040		cmp.b	#empty,-1(a1)
			beq.s	sd0050
			cmp.b	#earth,-1(a1)
			beq.s	sd0050
			or.w	#$08,d0					; set the solid bit
sd0050		cmp.b	#empty,1(a1)
			beq.s	sd0060
			cmp.b	#earth,1(a1)
			beq.s	sd0060
			or.w	#$10,d0					; set the solid bit
sd0060		cmp.b	#empty,33(a1)
			beq.s	sd0070
			cmp.b	#earth,33(a1)
			beq.s	sd0070
			or.w	#$20,d0					; set the solid bit
sd0070		cmp.b	#empty,34(a1)
			beq.s	sd0080
			cmp.b	#earth,34(a1)
			beq.s	sd0080
			or.w	#$40,d0					; set the solid bit
sd0080		cmp.b	#empty,35(a1)
			beq.s	sd0090
			cmp.b	#earth,35(a1)
			beq.s	sd0090
			or.w	#$80,d0					; set the solid bit
sd0090		lea		sp_starts,a1			; start direction data
			move.b	(a1,d0.w),d0			; get start direction
			move.b	d0,5(a0)				; set in spirit structure
			lea		6(a0),a0				; next spirit data
			dbra	d5,sd0010				; do all the spirits
			rts

*
* This routine handles the setup and growth of fungus
*
grow_fun	move.w	f_units,d5				; amount of fungus on level
			bne.s	fun000					; skip if there is fungus
			rts
fun000		subq.w	#1,d5					; 1 less for dbra
			lea		fun_table,a0			; fungus data
fun010		tst.b	4(a0)					; check posible directions ?
			bne		ch_dir					; skip if we can
fun020		tst.b	5(a0)					; definate chance to grow ?
			bne		grow_it					; skip if it can
fun030		lea		6(a0),a0				; next fungus unit
			dbra	d5,fun010				; do all the fungus
			rts
*
* This routine checks to see if the fungus can grow in any
* of the 4 cardinal directions
*
ch_dir		movem.w	(a0),d0-d1				; x,y data
			mulu.w	#34,d1					; y offset into map
			add.w	d0,d1					; x offset
			lea		play_map,a1				; map data
			add.w	d1,a1					; fungus pointer
			clr.w	4(a0)					; reset grow data
* check each location round the fungus
			lea		-34(a1),a1				; check above
			jsr		check_fun				; check it
			tst.w	d2						; possible to grow ?
			beq.s	cd0001					; skip if not
			or.b	#%00000001,4(a0)		; set grow north bit
			cmp.w	#2,d2					; definate grow ?
			blo.s	cd0001					; skip if not
			or.b	#%00000001,5(a0)		; set definate grow bit
*
cd0001		lea		35(a1),a1				; check right
			jsr		check_fun				; check it
			tst.w	d2						; possible to grow ?
			beq.s	cd0010					; skip if not
			or.b	#%00000010,4(a0)		; set grow east bit
			cmp.w	#2,d2					; definate grow ?
			blo.s	cd0010					; skip if not
			or.b	#%00000010,5(a0)		; set definate grow bit
*
cd0010		lea		33(a1),a1				; check below
			jsr		check_fun				; check it
			tst.w	d2						; possible to grow ?
			beq.s	cd0020					; skip if not
			or.b	#%00000100,4(a0)		; set grow south bit
			cmp.w	#2,d2					; definate grow ?
			blo.s	cd0020					; skip if not
			or.b	#%00000100,5(a0)		; set definate grow bit
*
cd0020		lea		-35(a1),a1				; check left
			jsr		check_fun				; check it
			tst.w	d2						; possible to grow ?
			beq.s	cd0030					; skip if not
			or.b	#%00001000,4(a0)		; set grow west bit
			cmp.w	#2,d2					; definate grow ?
			blo.s	cd0030					; skip if not
			or.b	#%00001000,5(a0)		; set definate grow bit
*
cd0030		bra		fun020					; all done
*
* this checks a location and return a value in d2 as follows :
* 0 - cannot grow ever
* 1 - could possibly grow in the future
* 2 - definately grow in the future
*
check_fun	clr.w	d2						; assume never grow
			cmp.b	#empty,(a1)				; definate grow ?
			beq		def_grow				; skip if so
			cmp.b	#earth,(a1)				; definate grow ?
			beq		def_grow				; skip if so
			cmp.b	#diamond,(a1)			; possible grow ?
			beq		pos_grow				; skip if so
			cmp.b	#key,(a1)				; possible grow ?
			beq		pos_grow				; skip if so
			cmp.b	#rock,(a1)				; possible grow ?
			beq		pos_grow				; skip if so
			cmp.b	#cage,(a1)				; possible grow ?
			beq		pos_grow				; skip if so
			cmp.b	#tcapsule,(a1)			; possible grow ?
			beq		pos_grow				; skip if so
			cmp.b	#egg,(a1)				; possible grow ?
			beq		pos_grow				; skip if so
			cmp.b	#trans,(a1)				; possible grow ?
			beq		pos_grow				; skip if so
			cmp.b	#crown,(a1)				; possible grow ?
			beq		pos_grow				; skip if so
			cmp.b	#safe,(a1)				; possible grow ?
			beq		pos_grow				; skip if so
			rts								; no chance to grow
def_grow	move.w	#2,d2
			rts
pos_grow	move.w	#1,d2
			rts
*
* This routine lets the fungus grow 
*
grow_it		jsr		random					; get random number in d0
			and.w	#$03ff,d0				; limit range
			cmp.w	#3,d0					; grow the fungus ?
			bgt		fun030					; return if not
			btst.b	d0,5(a0)				; can we grow that direction ?
			beq		fun030					; return if not
			lsl.w	#2,d0					; l_word offset
			move.l	a1,-(sp)				; points to left of orig fungus
			lea		fun_routes,a1			; fungus routines 
			move.l	(a1,d0.w),a1			; pointer to routine
			jmp		(a1)					; do it
*
fun_routes	dc.l	fun_north,fun_east,fun_south,fun_west
*
fun_north	move.l	(sp),a1
			cmp.b	#fungus,-33(a1)			; already grown in ?
			beq		fun_exit
			lea		fun_table,a1			; fungus table
			move.w	f_units,d0				; number of fungus units
			mulu.w	#6,d0					; offset to next empty slot
			add.w	d0,a1					; point to empty slot
			move.l	(a0),(a1)				; x,y data
			subq.w	#1,2(a1)				; different y position
			move.w	#-1,4(a1)				; assume grow all directions
			move.l	(sp)+,a1				; recover map pntr
			move.b	#fungus,-33(a1)			; insert fungus into map
			addq.w	#1,f_units				; count the few unit
			bra		fun030					; return, all done
*
fun_east	move.l	(sp),a1
			cmp.b	#fungus,2(a1)			; already grown in ?
			beq		fun_exit
			lea		fun_table,a1			; fungus table
			move.w	f_units,d0				; number of fungus units
			mulu.w	#6,d0					; offset to next empty slot
			add.w	d0,a1					; point to empty slot
			move.l	(a0),(a1)				; x,y data
			addq.w	#1,(a1)					; different x position
			move.w	#-1,4(a1)				; assume grow all directions
			move.l	(sp)+,a1				; recover map pntr
			move.b	#fungus,2(a1)			; insert fungus into map
			addq.w	#1,f_units				; count the few unit
			bra		fun030					; return, all done
*
fun_south	move.l	(sp),a1
			cmp.b	#fungus,35(a1)			; already grown in ?
			beq		fun_exit
			lea		fun_table,a1			; fungus table
			move.w	f_units,d0				; number of fungus units
			mulu.w	#6,d0					; offset to next empty slot
			add.w	d0,a1					; point to empty slot
			move.l	(a0),(a1)				; x,y data
			addq.w	#1,2(a1)				; different y position
			move.w	#-1,4(a1)				; assume grow all directions
			move.l	(sp)+,a1				; recover map pntr
			move.b	#fungus,35(a1)			; insert fungus into map
			addq.w	#1,f_units				; count the few unit
			bra		fun030					; return, all done
*
fun_west	move.l	(sp),a1
			cmp.b	#fungus,(a1)			; already grown in ?
			beq		fun_exit
			lea		fun_table,a1			; fungus table
			move.w	f_units,d0				; number of fungus units
			mulu.w	#6,d0					; offset to next empty slot
			add.w	d0,a1					; point to empty slot
			move.l	(a0),(a1)				; x,y data
			subq.w	#1,(a1)					; different x position
			move.w	#-1,4(a1)				; assume grow all directions
			move.l	(sp)+,a1				; recover map pntr
			move.b	#fungus,(a1)			; insert fungus into map
			addq.w	#1,f_units				; count the few unit
			bra		fun030					; return, all done
*
fun_exit	move.l	(sp)+,a1
			bra		fun030

setup_menu	lea		pass_lu,a0			; table of 8 pointers
			lea		pass_disp,a1		; display or not data
			clr.w	pass				; offset to plot correct password
			move.w	#7,d5				; 8 to do
sm0000		tst.b	(a1)				; display the password ?
			bne		pass_in				; put it in if we are
			bra		pass_out			; remove the password
sm0010		tst.b	9(a1)				; plot the editor code ?
			bne		edit_in				; put in if we are
			bra		edit_out			; ekip if not
sm0020		addq.w	#1,pass				; change the offset
			lea		4(a0),a0			; next text pointer
			lea		1(a1),a1			; next set bit
			dbra	d5,sm0000			; do them all
			rts
			
pass_in		movem.l	a0-a1,-(sp)			; save regs
			move.l	(a0),a0				; line pointer
			lea		maps+5504,a1		; start of passwords
			move.w	pass,d0				; offset to correct password
			lsl.w	#3,d0				; correct offset
			add.w	d0,a1				; points to data
			bra		pass_insert			; puts data in
pass_out	movem.l	a0-a1,-(sp)
			move.l	(a0),a0
			lea		dashes,a1			; data to plot
pass_insert	lea		14(a0),a0			; correct area of line
			rept	8
			move.b	(a1)+,(a0)+			; do a byte
			endr
			movem.l	(sp)+,a0-a1			; recover regs
			bra		sm0010				; do the rest

edit_in		movem.l	a0-a1,-(sp)			; save regs
			move.l	(a0),a0				; line pointer
			lea		edit_codes,a1		; start of edit codes
			move.w	pass,d0				; offset to correct e-code
			lsl.w	#3,d0				; correct offset
			add.w	d0,a1				; points to data
			bra		code_insert			; puts data in
edit_out	movem.l	a0-a1,-(sp)
			move.l	(a0),a0
			lea		dashes,a1			; data to plot
code_insert	lea		30(a0),a0			; correct area of line
			rept	5
			move.b	(a1)+,(a0)+			; do a byte
			endr
			movem.l	(sp)+,a0-a1			; recover regs
			bra		sm0020				; do the rest
			
*
* routine calulates the editor codes
*
calc_codes	move.w	#7,d5				; 8 maps to do
			lea		maps,a0				; map data
			lea		codes,a1			; store values here
cc0000		clr.l	d0					; build in d0.l
			move.w	#23,d4				; 24 lines in height
cc0010		move.w	#27,d3				; 28 chars per line
			clr.w	d1
cc0020		clr.w	d2
			move.b	(a0),d2				; get a position value
			mulu.w	d1,d2				; make a value
			add.l	d2,d0				; total it
			move.b	(a0)+,d1			; change mulu value
			dbra	d3,cc0020			; do all 28 in a line
			dbra	d4,cc0010			; do the whole line
			lea		16(a0),a0			; next map start
			tst.w	d0					; is it -ve ?
			bpl.s	cc0030				; skip if ok
			neg.w	d0					; make +ve
cc0030		cmp.w	#30000,d0			; in range ?
			blo.s	cc0040				; skip if ok
			sub.w	#30000,d0			; bring into range
			bra.s	cc0030				; do until ok
cc0040		move.w	d0,(a1)+			; save editor code
			dbra	d5,cc0000			; do them all
*
			move.w	#1,conv_flag
			lea		codes,a0			; code values
			lea		edit_codes,a1		; text values
			move.w	#7,d5				; 8 to do
cc0050		move.w	d5,-(sp)			; save reg
			clr.l	d0
			move.w	(a0)+,d0			; get value
			jsr		convert_num			; covert to text
			move.b	d4,(a1)
			move.b	d3,1(a1)
			move.b	d2,2(a1)
			move.b	d1,3(a1)
			move.b	d0,4(a1)
			move.w	(sp)+,d5			; recover reg
			lea		8(a1),a1			; next table entry
			dbra	d5,cc0050
			move.w	#0,conv_flag
			rts
			
hi_light	tst.w	hilight				; need to re-hilight ?
			bne.s	hl0000				; skip if we do
			rts
hl0000		move.l	scr1,a0				; screen pointer
			lea		24320(a0),a0		; password A line
			move.w	start,d0			; line number to hilight
			mulu.w	#1280,d0			; offset to pointer
			add.w	d0,a0				; correct screen pointer
			lea		buffer,a1			; wher to store de-hilight data
			subq.w	#1,hilight			; count the screen hilight
			bne.s	hl0015
			move.w	#7,d5				; 8 lines of data to copy
hl0010		move.w	(a0),(a1)+
			move.w	8(a0),(a1)+
			move.w	16(a0),(a1)+
			move.w	24(a0),(a1)+
			move.w	32(a0),(a1)+
			move.w	40(a0),(a1)+
			move.w	48(a0),(a1)+
			move.w	56(a0),(a1)+
			move.w	64(a0),(a1)+
			move.w	72(a0),(a1)+
			move.w	80(a0),(a1)+
			move.w	88(a0),(a1)+
			move.w	96(a0),(a1)+
			move.w	104(a0),(a1)+
			move.w	112(a0),(a1)+
			move.w	120(a0),(a1)+
			move.w	128(a0),(a1)+
			move.w	136(a0),(a1)+
			move.w	144(a0),(a1)+
			move.w	152(a0),(a1)+
			lea		160(a0),a0			; next screen line
			dbra	d5,hl0010			; get all the data
* 
* now hilight the line
*
			lea		-1280(a0),a0		; restore pointer
hl0015		move.w	#7,d5				; 8 lines to hilight
			move.w	#$ffff,d0			; data to insert
hl0020		move.w	d0,(a0)
			move.w	d0,8(a0)
			move.w	d0,16(a0)
			move.w	d0,24(a0)
			move.w	d0,32(a0)
			move.w	d0,40(a0)
			move.w	d0,48(a0)
			move.w	d0,56(a0)
			move.w	d0,64(a0)
			move.w	d0,72(a0)
			move.w	d0,80(a0)
			move.w	d0,88(a0)
			move.w	d0,96(a0)
			move.w	d0,104(a0)
			move.w	d0,112(a0)
			move.w	d0,120(a0)
			move.w	d0,128(a0)
			move.w	d0,136(a0)
			move.w	d0,144(a0)
			move.w	d0,152(a0)
			lea		160(a0),a0			; next screen line
			dbra	d5,hl0020			; get all the data
			rts

dhi_light	tst.w	hilight				; need to re-hilight ?
			bne.s	dhl0000				; skip if we do
			rts
dhl0000		move.l	scr1,a0				; screen pointer
			lea		24320(a0),a0		; password A line
			move.w	ostart,d0			; line number to hilight
			mulu.w	#1280,d0			; offset to pointer
			add.w	d0,a0				; correct screen pointer
			lea		buffer,a1			; wher to store de-hilight data
			move.w	#7,d5				; 8 lines of data to copy
dhl0010		move.w	(a1)+,(a0)
			move.w	(a1)+,8(a0)
			move.w	(a1)+,16(a0)
			move.w	(a1)+,24(a0)
			move.w	(a1)+,32(a0)
			move.w	(a1)+,40(a0)
			move.w	(a1)+,48(a0)
			move.w	(a1)+,56(a0)
			move.w	(a1)+,64(a0)
			move.w	(a1)+,72(a0)
			move.w	(a1)+,80(a0)
			move.w	(a1)+,88(a0)
			move.w	(a1)+,96(a0)
			move.w	(a1)+,104(a0)
			move.w	(a1)+,112(a0)
			move.w	(a1)+,120(a0)
			move.w	(a1)+,128(a0)
			move.w	(a1)+,136(a0)
			move.w	(a1)+,144(a0)
			move.w	(a1)+,152(a0)
			lea		160(a0),a0			; next screen line
			dbra	d5,dhl0010			; get all the data
			rts
*
* File selector code
*
file_selector
			jsr		fade_out
			jsr		ret_ints				*restore interrupts
			movem.l	d6-d7/a2-a6,-(sp)		; save tracker status
			jsr		init_file
			jsr		clear_buffer
			jsr		disk_operations			* do disk stuff
			jsr		restore_file
			movem.l	(sp)+,d6-d7/a2-a6		; recover tracker status
			jsr		init_ints				*init. interrupts
			clr.w	wfnc
			jsr		fade_out
			clr.w	exit
			rts
*
* init my mouse routine
*
init_file	move	#34,-(sp)				; get pointers to mouse details
			trap	#14
			lea		2(sp),sp
			move.l 	d0,a4					; points to mouse routine vectors
			lea		16(a4),a4				; mouse routine pointer
			move.l	(a4),old_mouse			; save old mouse routine pointer
			move.l	#my_mouse,(a4)			; point to my routine
			move.l	a4,mouse_rout			; save pointer
			move.b	#$08,acia_dat			; mouse ints on
			rts
			
restore_file
			move.l	mouse_rout,a4			; restore pointer to interupt vectors
			move.l	old_mouse,(a4)			; retore old int vector
			move.b	#$12,acia_dat			; mouse ints off
			rts
*
my_mouse	movem.l	d0/a0-a1,-(sp)			; a0 points to mouse package
			lea 	mouse_x,a1				; point to mouse data
			clr.w	d0				
			move.b	1(a0),d0				; get x offset
			ext.w	d0						; sign extend to 16 bits
			add.w	d0,(a1)+				; add on offset
			bpl.s	mm000					; skip if data valid
			move.w	#0,-2(a1)				; limit range
mm000		move.w	x_max,d0
			cmp.w	-2(a1),d0				; in x upper range ?
			bge.s	mm010					; skip if ok
			move.w	d0,-2(a1)				; limit range
mm010		clr.w	d0
			move.b	2(a0),d0				; get y offset
			ext.w	d0						; sign extend to 16 bits
			add.w	d0,(a1)+				; add on offset
			bpl.s	mm020					; skip if data valid
			move.w	#0,-2(a1)				; else limit range
mm020		move.w	y_max,d0
			cmp.w	-2(a1),d0				; in upper y range ?
			bge.s	mm030					; skip if ok
			move.w	d0,-2(a1)				; else limit range
mm030		move.b	(a0),d0					; get button status
			move.b	d0,(a1)					; button status byte
			move.w	-2(a1),d1
			cmp.w	y_min,d1				; min y value
			bge.s	plm_ok					; skip if ok
			move.w	y_min,-2(a1)			; set min value
plm_ok		movem.l	(sp)+,d0/a0-a1	
			rts				
*
*
erase_mouse	move.l	scr2,a0				; background acreen
			lea		mbuffer,a1			; restore data
			movem.w	old_x,d0-d1			; mouse erase co-ords
			mulu.w	#160,d1				; y offset
			and.w	#$fff0,d0			; multiples of 16
			lsr.w	#1,d0				; x offset
			add.w	d0,d1				; total offset
			add.l	d1,a0				; background screen pointer
			move.w	#7,d5				; 8 lines to do
clrm000		movem.l	(a1)+,d0-d3			; 32 bits of data
			movem.l	d0-d3,(a0)			; erase old mouse
			lea		160(a0),a0			; next line down
			dbra	d5,clrm000			; and loop
			rts
			
plot_mouse	movem.w	mouse_x,d0-d1		; get new mouse co-ords
			movem.w	d0-d1,old_x			; save for next erase
			lea		mbuffer,a0			; where to store old data
			move.l	scr1,a1				; screen pointer
			move.w	d0,d2
			and.w	#$fff0,d0			; mults of 16
			lsr.w	#1,d0				; x offset
			mulu.w	#160,d1				; y offset
			add.w	d0,d1				; total offset
			add.w	d1,a1				; correct graphics
			move.w	d2,-(sp)
			move.w	#7,d5				; 8 lines to plot
plm000		movem.l	(a1),d0-d3			; get a line
			movem.l	d0-d3,(a0)			; stor in buffer
			lea		16(a0),a0
			lea		160(a1),a1			; next screen line
			dbra	d5,plm000			; store all the data
			lea		-1280(a1),a1		; restore screen pointer
			sub.l	scr1,a1
			add.l	scr2,a1
			move.w	(sp)+,d2
			lea		mouse_ch,a0			; mouse data
			and.w	#$000f,d2			; offset into data
			lsl.w	#5,d2				; normalise
			add.w	d2,a0				; pointer to data
			move.w	#7,d5				; 8 lines to plot
plm010		movem.w	(a0),d0-d1			; get the data
			or.w	d0,(a1)				; plot 1st 16 bits
			or.w	d0,2(a1)			
			or.w	d0,4(a1)			
			or.w	d0,6(a1)			
			or.w	d1,8(a1)			; plot 2nd 16 bits
			or.w	d1,10(a1)		
			or.w	d1,12(a1)		
			or.w	d1,14(a1)		
			lea		160(a1),a1			; next screen line
			lea		4(a0),a0
			dbra	d5,plm010			; do all 8 lines
			rts
clear_buffer
			clr.l	mouse_x
			clr.l	old_x
			lea		mbuffer,a0
			move.w	#7,d5
cb0000		clr.l	(a0)+
			clr.l	(a0)+
			clr.l	(a0)+
			clr.l	(a0)+
			dbra	d5,cb0000
			movem.l	scr1,a0-a1			; screen pointers
			move.w	#8959,d5			; dbra count
cb0010		clr.l	(a0)+
			clr.l	(a1)+
			dbra	d5,cb0010
			rts
*
* Loads map files and character files if present
*
disk_operations
			jsr		find_files
			jsr		setup_table
			lea		ltable,a1			; point to load look up
			jsr		plot_block			; plot the table
			move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			movem.l	scr1,d0-d1				; swap screen starts
			exg		d0,d1
			movem.l	d0-d1,scr1
			lsr.l	#8,d1
			move.b	d1,$ff8203				; set screen address
			lsr.w	#8,d1
			move.b	d1,$ff8201				; change screen
			lea		ltable,a1
			jsr		plot_block
			jsr		plot_mouse
			jsr		fade_in2
load_operation
			clr.w	file_number			; assume no file
			clr.w	exit				; loop until not zero
lop000		move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			jsr		new_disk
			jsr		re_cat
			jsr		load_mouse
			jsr		erase_mouse
			jsr		plot_mouse
			tst.w	exit
			beq.s	lop000
			rts
			
re_cat		move.l	#$600ff,-(sp)		; RAWCONIO call
			trap	#1
			lea		4(sp),sp
			cmp.b	#' ',d0				; recatalog disk ?
			beq		nd010				; skip if we do
			rts
new_disk	cmp.b	#'C',drive			; drive A or B active ?
			blo.s	nd000				; skip if they are
			rts
nd000		clr.w	d0
			move.b	drive,d0
			sub.b	#'A',d0				; make drive number
			move.w	d0,-(sp)			; device number
			move.w	#9,-(sp)			; inquire media change
			trap	#13
			lea		4(sp),sp
			cmp.w	#2,d0				; definate diskette change ?
			bge.s	nd010				; skip if it was
			rts
nd010		jsr		find_files
			jsr		erase_mouse
			jsr		setup_table
			lea		ltable,a1			; point to load look up
			jsr		plot_block			; plot the table
			move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			movem.l	scr1,d0-d1				; swap screen starts
			exg		d0,d1
			movem.l	d0-d1,scr1
			lsr.l	#8,d1
			move.b	d1,$ff8203				; set screen address
			lsr.w	#8,d1
			move.b	d1,$ff8201				; change screen
			lea		ltable,a1
			jsr		plot_block
			jsr		plot_mouse
			rts
load_mouse	move.b	m_buttons,d0		; get button status
			lsr.w	#2,d0				; left button in carry
			bcs.s	ldm000				; skip if pressed
			rts
ldm000		movem.w	mouse_x,d0-d1		; get mouse co-ords
			lsr.w	#3,d0				; divide by 8
			lsr.w	#3,d1				; divide by 8
* check for scroll arrows first
			cmp.w	#17,d0				; correct x line ?
			beq		arrows_code			; same code for load/save
* check for cancel line
			cmp.w	#22,d1				; cancel y line ?
			beq		cancel_code			; same code for load/save
* check for change of drives
			cmp.w	#22,d0				; correct x distance
			bhs		drives_code			; same code for load/save
* check for change of directory
			cmp.w	#12,d1				; max y line
			bls		dir_code			; same code for load/save
* check for file selection
			cmp.w	#14,d1				; min y line
			bge.s	ldm010				; skip if ok
			rts
ldm010		move.w	#13,d2				; max y position
			add.w	files,d2			; make max y line
			cmp.w	d2,d1				; vaild line ?
			ble.s	ldm020				; skip if ok
			rts
ldm020		sub.w	#14,d1				; make file number
			add.w	file_offset,d1		; include window scroll
			cmp.w	#4,d0				; min x position
			bge.s	ldm030				; skip if ok
			rts
ldm030		cmp.w	#15,d0				; max x position
			ble.s	ldm040				; skip if ok
			rts
ldm040		move.w	#1,exit
			move.w	d1,file_number		; save filenumber to load
			mulu.w	#14,d1				; make offset
			lea		f_names,a0			; point to files
			add.w	d1,a0				; point to correct filename
			move.l	a0,file_pntr		; for character file
* first open the file
			move.w	#$0,-(sp)			; file read only
			move.l	a0,-(sp)			; filename pointer
			move.w	#$3d,-(sp)			; OPEN call
			trap	#1
			lea		8(sp),sp
			tst.l	d0					; error ?
			bmi		load_error			; skip if there is
			move.w	d0,handle			; save file handle
* now read the data
			pea		maps				; data destination
			move.l	#5585,-(sp)			; amount of data
			move.w	handle,-(sp)		; file handle
			move.w	#$3f,-(sp)			; READ call
			trap	#1
			lea		12(sp),sp
			tst.l	d0					; error ?
			bmi		load_error			; skip if ther is
* now close the file
			move.w	handle,-(sp)		; file handle
			move.w	#$3e,-(sp)			; CLOSE call
			trap	#1
			lea		4(sp),sp
			tst.l	d0					; error ?
			bmi		load_error			; skip if there is
*
* now load the character file if it is present
*
			move.l	file_pntr,a0		; get the filename pointer
lm0045		cmp.b	#'.',(a0)+			; found the period ?
			bne.s	lm0045				; loop if not
			move.b	#'C',(a0)+			; change to CHR
			move.b	#'H',(a0)+
			move.b	#'R',(a0)+
			move.l	file_pntr,a0		; recover pointer
* first open the file
			move.w	#$0,-(sp)			; file read only
			move.l	a0,-(sp)			; filename pointer
			move.w	#$3d,-(sp)			; OPEN call
			trap	#1
			lea		8(sp),sp
			tst.l	d0					; file exist ?
			bmi.s	lm048				; exit if it doesn't
			move.w	d0,handle			; save file handle
* now read the data
			pea		char_cols			; data destination
			move.l	#32288,-(sp)		; amount of data
			move.w	handle,-(sp)		; file handle
			move.w	#$3f,-(sp)			; READ call
			trap	#1
			lea		12(sp),sp
			tst.l	d0					; error ?
			bmi.s	lm048				; skip if ther is
* now close the file
			move.w	handle,-(sp)		; file handle
			move.w	#$3e,-(sp)			; CLOSE call
			trap	#1
			lea		4(sp),sp
			movem.l	char_cols,d0-d5		; new fade data
			movem.l	d0-d5,color_buff
			movem.l	d0-d5,colours
			movem.l	char_cols+24,d0-d1
			movem.l	d0-d1,color_buff+24
			movem.l	d0-d1,colours+24
			jsr		create_fade
			jsr		offset_chars

lm048		lea		pass_disp,a0
			move.b	#1,(a0)+			; reset password and
			clr.b	(a0)+				; editor code display
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.b	(a0)+
			clr.w	start					; hilight map A
			move.w	#50*3,d7				; load delay
ldm050		move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			dbra	d7,ldm050
			jsr		calc_codes				; calculate new editor codes
			rts
	
load_error	jsr		erase_mouse
			lea		unk_lu,a1			; assume unknown error
			move.w	#num_errs-1,d7		; loop count
			lea		err_lu,a0			; search table
lse000		cmp.w	2(a0),d0			; found right error ?
			bne.s	lse010				; skip if not
			move.l	4(a0),a1			; correct pointer
			bra.s	lse020				; display code
lse010		lea		8(a0),a0			; next table entry
			dbra	d7,lse000			; search tje whole table
lse020		move.l	a1,-(sp)			; save block pointer
			jsr		plot_block
			move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			movem.l	scr1,d0-d1				; swap screen starts
			exg		d0,d1
			movem.l	d0-d1,scr1
			lsr.l	#8,d1
			move.b	d1,$ff8203				; set screen address
			lsr.w	#8,d1
			move.b	d1,$ff8201				; change screen
			move.l	(sp)+,a1			; recover block pointer
			jsr		plot_block
			jsr		plot_mouse
			clr.w	exit
lse030		move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			jsr		erase_mouse
			jsr		plot_mouse
			jsr		lse_mouse
			tst.w	exit
			beq.s	lse030
			clr.w	exit
			jsr		erase_mouse
			jsr		setup_table
			lea		ltable,a1			; point to load look up
			jsr		plot_block			; plot the table
			move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			movem.l	scr1,d0-d1				; swap screen starts
			exg		d0,d1
			movem.l	d0-d1,scr1
			lsr.l	#8,d1
			move.b	d1,$ff8203				; set screen address
			lsr.w	#8,d1
			move.b	d1,$ff8201				; change screen
			lea		ltable,a1
			jsr		plot_block
			jsr		plot_mouse
			rts
			
lse_mouse	btst.b	#0,m_buttons		; right button pressed ?
			bne.s	lse_check
			btst.b	#1,m_buttons
			bne.s	lse_check
			rts
lse_check	movem.w	mouse_x,d0-d1		; mouse co-ords
			lsr.w	#3,d0				; scale position
			lsr.w	#3,d1				; scale position
			cmp.w	#10,d1				; cancle line ?
			beq.s	lsec000				; skip if it is
			rts
lsec000		cmp.w	#5,d0				; min x position
			bge.s	lsec010				; skip if ok
			rts
lsec010		cmp.w	#12,d0				; max x position
			ble.s	lsec020				; skip if ok
			rts
lsec020		move.w	#1,exit				; signal comformation
			rts
			
arrows_code	cmp.w	#7,d1				; directory up arrow ?
			beq.s	dir_ua				; skip if it is
			cmp.w	#12,d1				; directory down arrow ?
			beq.s	dir_da				; skip if it is
			cmp.w	#14,d1				; files up arrow ?
			beq.s	file_ua				; skip if it is
			cmp.w	#21,d1				; files down arrow ?
			beq.s	file_da				; skip if it is
			rts							; not an arrow
			
dir_ua		tst.w	dir_offset			; if zero, cannot scroll
			bne.s	dua000				; skip if scroll
			rts
dua000		subq.w	#1,dir_offset		; change the offset
			bra.s	disk_update			; update the screen
			
dir_da		move.w	dirs,d0				; number of dirs found
			sub.w	dir_offset,d0		; make amount left
			cmp.w	#6,d0				; able to scroll ?
			bhi.s	dda000				; skip if we can
			rts
dda000		addq.w	#1,dir_offset		; change the offset
			bra.s	disk_update			; update the screen
			
file_ua		tst.w	file_offset			; if zero, cannot scroll
			bne.s	fua000				; skip if scroll
			rts
fua000		subq.w	#1,file_offset		; change the offset
			bra.s	disk_update			; update the screen
			
file_da		move.w	files,d0			; number of files found
			sub.w	file_offset,d0		; make amount left
			cmp.w	#8,d0				; able to scroll ?
			bhi.s	fda000				; skip if we can
			rts
fda000		addq.w	#1,file_offset		; change the offset
			bra		disk_update			; update the screen
			
disk_update	jsr		erase_mouse
			jsr		setup_table			; re-draw names etc..
			lea		ltable,a1			; point to load look up
			jsr		plot_block			; plot the table
			move.w	#37,-(sp)
			trap	#14
			lea		2(sp),sp
			movem.l	scr1,d0-d1				; swap screen starts
			exg		d0,d1
			movem.l	d0-d1,scr1
			lsr.l	#8,d1
			move.b	d1,$ff8203				; set screen address
			lsr.w	#8,d1
			move.b	d1,$ff8201				; change screen
			lea		ltable,a1			; update 2nd screen
			jsr		plot_block
			jsr		plot_mouse
			rts
			
cancel_code	cmp.w	#8,d0				; beyond word ?
			bls.s	cc000				; skip if ok
			rts
cc000		cmp.w	#1,d0				; in range ?
			bhs.s	cc010				; skip if ok
			rts
cc010		move.w	#1,exit				; signal exit
			rts
			
drives_code	cmp.w	#24,d0				; drive letters ?
			bls.s	dc000				; skip if ok
			rts
dc000		cmp.w	#7,d1				; top line ?
			bhs.s	dc010				; skip if ok
			rts
dc010		sub.w	#6,d1				; make drive number
			cmp.w	drives,d1			; in range ?
			ble.s	dc020				; skip if ok
			rts
dc020		subq.w	#1,d1				; make drive number
			move.w	d1,-(sp)			; selected drive
			move.b	#'\',pathname		; back to root directory
			clr.b	pathname+1			; end the string
			pea		pathname			; buffer area
			move.w	#$3b,-(sp)			; CHDIR call
			trap	#1
			lea		6(sp),sp			; restore stack
			move.w	(sp),d1
			add.b	#'A',d1				; drive letter
			move.b	d1,drive			; set letter in string
			move.w	#$e,-(sp)			; SETDRV call
			trap	#1
			lea		4(sp),sp
			jsr		find_files
			bra		disk_update			; update the screen

dir_code	cmp.w	#4,d0				; start of file/dir name ?
			bhs.s	dcd000				; skip if ok
			rts
dcd000		cmp.w	#15,d0				; end of file/dir name ?
			bls.s	dcd010				; skip if ok
			rts
dcd010		cmp.w	#7,d1				; beggining of dirs ?
			bhs.s	dcd020				; skip if ok
			rts
dcd020		sub.w	#7,d1				; make directory number
			add.w	dir_offset,d1		; add scroll amount
			cmp.w	dirs,d1				; in range ?
			blo.s	dcd030				; skip if valid dir
			rts
dcd030		lea		pathname,a0			; point to path string
dcd040		move.b	(a0)+,d0			; end of string ?
			beq.s	dcd050				; skip if we are
			bra.s	dcd040				; else find end
dcd050		lea		-1(a0),a0			; adjust pointer
			cmp.b	#'\',-1(a0)			; backslash preceding ?
			beq.s	dcd060				; skip if thier is
			move.b	#'\',(a0)+			; else insert one
dcd060		lea		dir_names,a1		; point to directory names
			mulu.w	#14,d1				; offset for correct dir
			add.w	d1,a1				; make pointer
dcd070		move.b	(a1)+,d0			; get a character
			beq.s	dcd080				; skip if end of string
			move.b	d0,(a0)+			; copy a character
			bra.s	dcd070				; do them all
dcd080		move.b	d0,(a0)				; zero byte at end
			pea		pathname			
			move.w	#$3b,-(sp)			; CHDIR call
			trap	#1
			lea		6(sp),sp
			clr.w	-(sp)				; current drive
			pea		pathname			; buffer area
			move.w	#$47,-(sp)			; GETDIR call
			trap	#1
			lea		8(sp),sp			; restore stack
			tst.b	pathname			; top directory ?
			bne.s	dcd090				; skip if not
			move.b	#'\',pathname		; else insert a backslash
			clr.b	pathname+1			; end the string
dcd090		jsr		find_files			; new directory
			bra		disk_update			; update the screen

load_file	move.w	#1,exit				; signal exit
			rts
			
find_files	clr.w	files				; no files yet
			clr.w	dirs				; no directories yet
			clr.w	dir_offset			; no scrolling done
			clr.w	file_offset

* first find and log all the directories

* sfirst for directories

			lea		dir_names,a6		; directory name data area			
			move.w	#$10,-(sp)			; search for dirs with *.*
			pea		star_dot			; search string
			move.w	#$4e,-(sp)			; sfirst call
			trap	#1
			lea		8(sp),sp			; restore stack
			tst.w	d0					; sub-directory found ?
			bmi.s	do_files			; skip if none found
			
			move.l	dta,a0
			lea		21(a0),a0			; point to file attribute
			cmp.b	#$10,(a0)			; is it a sub-directory ?
			bne.s	nextdir2			; skip if it is not
			
			move.l	dta,a0
			lea		30(a0),a0			; point to sub-directory name
			clr.w	d1					; number of characters copied
copy_name	move.b	(a0)+,d0			; get a byte of name
			beq.s	next_dir			; skip if end of filename
			move.b	d0,(a6)+			; save character
			addq.w	#1,d1				; count a character copied
			bra.s	copy_name			; do all characters

next_dir	move.b	d0,(a6)				; zero byte at end or string
			sub.w	d1,a6				; back to start of name
			addq.w	#1,dirs				; count a directory
			lea		14(a6),a6			; next sub-directory data area

* snext call

nextdir2	move.w	#$4f,-(sp)			; snext call
			trap	#1
			lea		2(sp),sp			; restore stack
			tst.w	d0					; found a sub-directory ?
			bmi.s	do_files			; skip if no more
			
			move.l	dta,a0
			lea		21(a0),a0			; point to file attribute
			cmp.b	#$10,(a0)			; is it a sub-directory ?
			bne.s	nextdir2			; skip if not
			
			clr.w	d1					; number of characters copied
			move.l	dta,a0
			lea		30(a0),a0			; point to sub-directry name
copy_name2	move.b	(a0)+,d0			; get a character
			beq.s	next_dir			; skip if end on name
			move.b	d0,(a6)+			; insert into buffer
			addq.w	#1,d1				; count a character
			bra.s	copy_name2			; do all of string

* now find the map files.

do_files	move.w	#0,-(sp)			; normal files only
			pea		map_files			; pointer to *.MAP
			move.w	#$4e,-(sp)			; sfirst call
			trap	#1
			lea		8(sp),sp			; restore stack
			
			tst.w	d0					; found a file ?
			bmi.s	find_exit			; skip if not

			lea		f_names,a6			; file name data
			addq.w	#1,files			; count the file
			move.l	dta,a0
			lea		30(a0),a0			; point to file name
			move.w	#12,d7				; 13 chars to copy
ff000		move.b	(a0)+,(a6)+			; copy a byte
			dbra	d7,ff000			; copy all of it
			lea		-13(a6),a6			; start of filename			

* now find all the other files

ff010		move.w	#$4f,-(sp)			; snext call
			trap	#1
			lea		2(sp),sp			; restore stack
			tst.w	d0					; found a file
			bmi.s	find_exit			; skip if got all
			
			addq.w	#1,files			; count a file
			lea		14(a6),a6			; next filename buffer
			move.l	dta,a0
			lea		30(a0),a0			; point to file name
			move.w	#12,d7				; 13 chars to copy
ff020		move.b	(a0)+,(a6)+			; copy a byte
			dbra	d7,ff020
			lea		-13(a6),a6			; start of filename
			bra.s	ff010				; get the next filename
find_exit	move.w	files,d0			; number of files
			lea		f_names,a0			; data area
			jsr		sort_names
			move.w	dirs,d0
			lea		dir_names,a0
			jsr		sort_names
			rts
			
sort_names	cmp.w	#1,d0				; any names to sort ?
			bgt.s	srtn000				; skip if there is
			rts
srtn000		lea		0(a0),a1			; get pointer to data
			move.w	d0,d7				; loop counter
			subq.w	#2,d7				; 1 less for dbra, 2 at a time
			clr.w	d6					; sort flag
srtn010		lea		0(a1),a2			; first filename
			lea		14(a1),a3			; second filename
			jsr		sort_it
			lea		14(a1),a1			; next filename
			dbra	d7,srtn010			; do all the names
			tst.w	d6					; all in order ?
			bne.s	srtn000				; loop if not
			rts
			
sort_it		move.w	#11,d5				; 12 characters per filename
srti000		move.b	(a2)+,d1			; get a character
			move.b	(a3)+,d2			; get a character
			cmp.b	d1,d2				; need to swap names ?
			blo.s	swap_them			; skip if we do
			cmp.b	d1,d2				; need to swap names ?
			bne.s	srti010
			dbra	d5,srti000			; loop if not
srti010		rts
swap_them	lea		0(a1),a2
			lea		14(a1),a3			; point to beginning again
			move.w	#13,d5				; 13 characters to copy
swt000		move.b	(a2),d1				; get a character
			move.b	(a3),(a2)+
			move.b	d1,(a3)+			; swap 1 character
			dbra	d5,swt000
			move.w	#1,d6				; signal had a swap
			rts
			
* first copy in all the sub-directory names
setup_table	lea		ltable+28,a0		; load table of pointers
			lea		dir_names,a6		; directory names
			clr.w	d1					; number of names plotted
			move.w	dirs,d7				; number of directories found
			beq.s	plot_dashes			; skip if no directories
			subq.w	#1,d7				; one less for dbra
			move.w	dir_offset,d2		; window scroll amount
			mulu.w	#14,d2				; each name assigned 14 chars
			add.w	d2,a6				; point to correct name
stb000		move.l	(a0)+,a1			; get pointer to line data
			move.b	#'q',4(a1)			; directory character
			lea		6(a1),a1			; place for name
			clr.w	d2					; characters copied counter
stb010		addq.w	#1,d2				; count a character copied
			move.b	(a6)+,d0			; get a character of name
			beq.s	stb020				; skip if last character
			move.b	d0,(a1)+			; copy in a character
			bra.s	stb010				; copy until null byte found
stb020		move.w	d2,d3				; stop off counter
stb025		cmp.w	#13,d3				; filled all characters ?
			bge.s	stb027				; skip if we have
			move.b	#' ',(a1)+			; insert a space
			addq.w	#1,d3				; count a character
			bra.s	stb025
stb027		sub.w	d2,a6				; point to start of name
			lea		14(a6),a6			; next name in list
			addq.w	#1,d1				; count a name plotted
			cmp.w	#6,d1				; plotted all 6 lines ?
			bge.s	plot_dashes			; skip if we have
			dbra	d7,stb000			; do all 6 lines
			
plot_dashes	cmp.w	#6,d1				; any blank lines ?
			bge.s	stb050				; skip if not
			move.w	#5,d7				; assume 6 lines to fill
			sub.w	d1,d7				; dbra number of lines to fill
stb030		move.l	(a0)+,a1			; pointer to line
			move.b	#' ',4(a1)			; erase possible dir char
			lea		6(a1),a1			; place for name
			move.w	#11,d2				; characters to copy counter
			lea		dash_line,a6		; characters to copy in
stb040		move.b	(a6)+,(a1)+			; copy a character
			dbra	d2,stb040			; copy a line
			dbra	d7,stb030			; do all blank lines

* now plot the filenames

stb050		lea		ltable+56,a0		; line look up table
			lea		f_names,a6			; filenames to plot
			clr.w	d1					; number of filesnames plotted
			move.w	files,d7			; number of filenames
			beq.s	dash2				; skip if no filenames
			subq.w	#1,d7				; one less for dbra
			move.w	file_offset,d2		; window scroll amount
			mulu.w	#14,d2				; each name is 20 characters
			add.w	d2,a6				; point to correct name
stb060		move.l	(a0)+,a1			; get pointer to line data
			lea		6(a1),a1			; place for filename
			clr.w	d2					; characters copied counter
stb070		addq.w	#1,d2				; count a character copied
			move.b	(a6)+,d0			; get a character of name
			beq.s	stb100				; skip if end of filname
			cmp.b	#'.',d0				; found the period ?
			bne.s	stb090				; skip if not
			move.w	d2,d3				; intermediate counter
stb080		cmp.w	#8,d3				; filled in whole name area ?
			bgt.s	stb090				; skip if we have
			move.b	#' ',(a1)+			; plot a space
			addq.w	#1,d3				; count a character
			bra.s   stb080				; fill in all spaces
stb090		move.b	d0,(a1)+			; copy in a character
			bra.s	stb070				; copy until null byte found
stb100		sub.w	d2,a6				; point to start of filename
			lea		14(a6),a6			; next filename in list
			addq.w	#1,d1				; count a filename plotted
			cmp.w	#8,d1				; plotted all 8 lines ?
			bge.s	dash2				; skip if we have
			dbra	d7,stb060			; do all 8 lines
			
dash2		cmp.w	#8,d1				; any blank lines ?
			bge.s	stb130				; skip if not
			move.w	#7,d7				; assume 8 lines to fill
			sub.w	d1,d7				; dbra number of lines to fill
stb110		move.l	(a0)+,a1			; pointer to line
			lea		6(a1),a1			; place for name
			move.w	#11,d2				; characters to copy counter
			lea		dash_line,a6		; characters to copy in
stb120		move.b	(a6)+,(a1)+			; copy a character
			dbra	d2,stb120			; copy a line
			dbra	d7,stb110			; do all blank lines

* print the path and the number of files.

stb130		move.w	files,d2			; ones count
			clr.w	d0					; 100's count
			clr.w	d1					; 10's count
stb140		cmp.w	#100,d2				; count the 100's
			blo.s	stb150				; none left ?
			addq.w	#1,d0				; count a 100
			sub.w	#100,d2
			bra.s	stb140				; count them all
stb150		cmp.w	#10,d2				; count the 10's
			blo.s	stb160				; none left ?
			addq.w	#1,d1				; count a ten
			sub.w	#10,d2
			bra.s	stb150				; count them all
stb160		add.b	#'0',d2				; correct character
			add.b	#'0',d1
			add.b	#'0',d0
			cmp.b	#'0',d0				; change leading '0' to space
			bne.s	stb170				; skip if not a zero
			move.b	#' ',d0				; change to space
			cmp.b	#'0',d1				; check next character
			bne.s	stb170				; skip if no change
			move.b	#' ',d1				; change to space
stb170		lea		lt5,a0				; no. files line
			lea		12(a0),a0			; correct area of line
			move.b	d0,(a0)+			; 100's
			move.b	d1,(a0)+			; 10's
			move.b	d2,(a0)				; 1's

			move.w	#$19,-(sp)			; current disk call
			trap	#1
			lea		2(sp),sp			; restore stack
			add.b	#'A',d0				; convert to character
			move.b	d0,drive			; insert into string
			
			lea		lt4+13,a0			; pathname line
			lea		drive,a1			; point to drive letters
			move.b	(a1)+,(a0)+
			move.b	(a1)+,(a0)+			; copy in drive letter
			lea		pathname,a1			; point to pathname
			clr.w	d1
stb180		move.b	(a1)+,d0			; get a character
			beq.s	stb190				; skip if end of pathname
			addq.w	#1,d1				; count a character
			cmp.w	#11,d1				; filled all the space ?
			bhi.s	stb190				; skip if we have
			move.b	d0,(a0)+			; insert into table
			bra.s	stb180
stb190		cmp.w	#11,d1				; filled all the area ?
			bge.s	stb200				; skip if we ahve
			move.b	#' ',(a0)+			; insert a space
			addq.w	#1,d1
			bra.s	stb190
stb200		rts
*
init_load	move.w	#10,-(sp)			; DRVMAP call
			trap	#13
			lea		2(sp),sp			; restore stack
			lea		ltable+28,a0		; point to table
			move.b	#'A',d1				; drive character
			clr.w	d2					; drives count
il000		lsr.w	#1,d0				; get drive status bit
			bcc.s	il010				; skip if no more drives
			move.l	(a0)+,a1			; pointer to line
			move.b	#'b',24(a1)			; right arrow character
			move.b	d1,25(a1)			; drive character
			move.b	#'a',26(a1)			; left arrow character
			addq.w	#1,d1				; next drive letter
			addq.w	#1,d2				; count an attached drive
			bra.s	il000				; check all drives
il010		move.w	d2,drives			; save number of attached drives
			move.w	#$19,-(sp)			; get current drive
			trap	#1
			lea		2(sp),sp
			add.b	#'A',d0				; make drive letter
			move.b	d0,drive			; save current drive
			move.w	#$2f,-(sp)			; get DTA call
			trap	#1
			lea		2(sp),sp	
			move.l	d0,dta				; dta address start
			clr.w	-(sp)				; current drive
			pea		pathname			; buffer area
			move.w	#$47,-(sp)			; GETDIR call
			trap	#1
			lea		8(sp),sp			; restore stack
			tst.b	pathname			; top directory ?
			bne.s	il020				; skip if not
			move.b	#'\',pathname		; else insert a backslash
			clr.b	pathname+1			; end the string
il020		rts
**************************************************************************

map_pntr	dc.l	maps
cont_char	dc.b	1,01,'K',0
controls	dc.b	0
i1			dc.b	0,00,'eiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiif',0
i2			dc.b	0,01,'j                st                    j',0
i3			dc.b	0,02,'j swt swt swt wwt v swt  swt x swt wwt j',0
i4			dc.b	0,03,'j x   x v x   z z   x    x   x x z z z j',0
i5			dc.b	0,04,'j xww xw  xww z z   uwt  xww x x z z z j',0
i6			dc.b	0,05,'j x   x t x   z z     z  x   x x z z z j',0
i7			dc.b	0,06,'j x   x z uyv yyv   uyv  x   x x z yyv j',0
i8			dc.b	0,07,'j                                      j',0
i9			dc.b	0,08,'j                                      j',0
ia			dc.b	0,09,'j                                      j',0
ib			dc.b	0,10,'j                                      j',0
ic			dc.b	0,11,'j                                      j',0
id			dc.b	0,12,'j                                      j',0
ie			dc.b	0,13,'j                                      j',0
if			dc.b	0,14,'j                                      j',0
ig			dc.b	0,15,'j                                      j',0
ih			dc.b	0,16,'kiiiiiiiiniiiiiiiiiiiiniiiiiiiiiiiiiiiil',0
ii			dc.b	0,17,'j  MAP   j  PASSWORD  j  EDITOR  CODE  j',0
ij			dc.b	0,18,'kiiiiiiiioiiiiiiiiiiiioiiiiiiiiiiiiiiiil',0
ik			dc.b	0,19,'j   A    j  --------  j     -----      j',0
il			dc.b	0,20,'j   B    j  --------  j     -----      j',0
im			dc.b	0,21,'j   C    j  --------  j     -----      j',0
in			dc.b	0,22,'j   D    j  --------  j     -----      j',0
io			dc.b	0,23,'j   E    j  --------  j     -----      j',0
ip			dc.b	0,24,'j   F    j  --------  j     -----      j',0
iq			dc.b	0,25,'j   G    j  --------  j     -----      j',0
ir			dc.b	0,26,'j   H    j  --------  j     -----      j',0
is			dc.b	0,27,'giiiiiiiimiiiiiiiiiiiimiiiiiiiiiiiiiiiih',0
menu_lu		dc.l	28,i1,i2,i3,i4,i5,i6,i7,i8,i9,ia,ib,ic,id,ie
			dc.l	if,ig,ih,ii,ij,ik,il,im,in,io,ip,iq,ir,is
pass_lu		dc.l	ik,il,im,in,io,ip,iq,ir
scr_lu		dc.l	4,i9,ib,id,if
mfp_freqs:	dc.b	24			*10 and 8.3 Khz
			dc.b	29
s1_pntr		dc.l	s1a
s2_pntr		dc.l	s2a
s3_pntr		dc.l	s3a
s4_pntr		dc.l	s4a
s1_list		dc.l	s1a,s1b,s1c,s1d,s1e,s1f,s1g,s1h,s1i,s1j,s1k,s1l,0
s2_list		dc.l	s2a,s2b,s2c,s2d,s2e,s2f,s2g,s2h,s2i,s2j,s2k,s2l,0
s3_list		dc.l	s3a,s3b,s3c,s3d,s3e,s3f,s3g,s3h,s3i,s3j,s3k,s3l,0
s4_list		dc.l	s4a,s4b,s4c,s4d,s4e,s4f,s4g,s4h,s4i,s4j,s4k,s4l,0
s1_lpntr	dc.l	s1_list
s2_lpntr	dc.l	s2_list
s3_lpntr	dc.l	s3_list
s4_lpntr	dc.l	s4_list
s1a			dc.b	"             FRED'S FIND              "
s2a			dc.b	'         WRITTEN BY R.I.ALLEN         '
s3a			dc.b	'                                      '
s4a			dc.b	'      p RIGAMORTIS SOFTWARE 1992      '
s1b			dc.b	'  SOUND USING THE TCB TRACKER BY MPH  '
s2b			dc.b	'                                      '
s3b			dc.b	'                                      '
s4b			dc.b	'                                      '
s1c			dc.b	'             GAME CONTROLS            '
s2c			dc.b	'   P - PASSWORD      M - VIEW MAP     '
s3c			dc.b	'   D - DEFINE KEYS   L - LOAD MAPS    '
s4c			dc.b	'      SPACE / FIRE - START GAME       '
s1d			dc.b	'             GAME CONTROLS            '
s2d			dc.b	'        c/d - SELECT START MAP        '
s3d			dc.b	'          J - JOYSTICK CONTROL        '
s4d			dc.b	'          K - KEYBOARD CONTROL        '
s1e			dc.b	'             GAME CONTROLS            '
s2e			dc.b	'          Q - QUIT TO DESKTOP         '
s3e			dc.b	'        ESCAPE TO KILL YOURSELF       '
s4e			dc.b	'     ESCAPE IN STATUS TO END GAME!    '
s1f			dc.b	' GREETINGS GO TO MY FELLOW CYBERPUNKS '
s2f			dc.b	'  LAZARUS - YOU SHOULD EXERCISE MORE  '
s3f			dc.b	'     MOTLEY - THANKS FOR THE HELP!    '
s4f			dc.b	"     BARD - STILL HAVEN'T MET YOU.    "
s1g			dc.b	' GREETINGS GOTO :                     '
s2g			dc.b	'    MJK - THE R.G.P POSTS...          '
s3g			dc.b	"    TLB - NICE DEMO'S GUYS...         "
s4g			dc.b	'    PJS - TOODLEPIP OLD BEAN...       '
s1h			dc.b	' THANKS GOTO :                        '
s2h			dc.b	'    HISOFT - DEVPAC 2                 '
s3h			dc.b	'    ATARI  - FOR THE ATARI ST         '
s4h			dc.b	'    TCB    - FOR THE TRACKER          '
s1i			dc.b	' THANKS GOTO :                        '
s2i			dc.b	'    COCACOLA - FOR THE BROWN LIQUID   '
s3i			dc.b	'    ABACUS SOFTWARE - ST INTERNALS    '
s4i			dc.b	'                                      '
s1j			dc.b	'     bFACTS ABOUT THIS SOFTWAREa      '
s2j			dc.b	' THE GAME AND EDITOR TOOK TWO YEARS TO'
s3j			dc.b	' DEVELOP. I HOPE YOU ENJOY IT AS MUCH '
s4j			dc.b	'        AS I DID WRITING IT!!!        '
s1k			dc.b	' TAKE PITY ON A POOR STUDENT, SEND ME '
s2k			dc.b	'   MONEY OR ABUSE, BUT I PREFER THE   '
s3k			dc.b	'   FORMER.  YOU CAN REACH ME AT THE   '
s4k			dc.b	'         FOLLOWING ADDRESS.....       '
s1l			dc.b	'               R.I.ALLEN              '
s2l			dc.b	'              5 GREENWAYS             '
s3l			dc.b	'               STEVENAGE              '
s4l			dc.b	'             HERTS,SG1 3TE            '
scrolling	dc.w	0
scroll_up	dc.w	10
dm1			dc.b	0,00,'                 MAP A                  ',0
dm2			dc.b	0,01,'     swwwwwwwwwwwwwwwwwwwwwwwwwwwwt     ',0
dm3			dc.b	0,02,'     x                            z     ',0
dm4			dc.b	0,03,'     x                            z     ',0
dm5			dc.b	0,04,'     x                            z     ',0
dm6			dc.b	0,05,'     x                            z     ',0
dm7			dc.b	0,06,'     x                            z     ',0
dm8			dc.b	0,07,'     x                            z     ',0
dm9			dc.b	0,08,'     x                            z     ',0
dma			dc.b	0,09,'     x                            z     ',0
dmb			dc.b	0,10,'     x                            z     ',0
dmc			dc.b	0,11,'     x                            z     ',0
dmd			dc.b	0,12,'     x                            z     ',0
dme			dc.b	0,13,'     x                            z     ',0
dmf			dc.b	0,14,'     x                            z     ',0
dmg			dc.b	0,15,'     x                            z     ',0
dmh			dc.b	0,16,'     x                            z     ',0
dmi			dc.b	0,17,'     x                            z     ',0
dmj			dc.b	0,18,'     x                            z     ',0
dmk			dc.b	0,19,'     x                            z     ',0
dml			dc.b	0,20,'     x                            z     ',0
dmm			dc.b	0,21,'     x                            z     ',0
dmn			dc.b	0,22,'     x                            z     ',0
dmo			dc.b	0,23,'     x                            z     ',0
dmp			dc.b	0,24,'     x                            z     ',0
dmq			dc.b	0,25,'     x                            z     ',0
dmr			dc.b	0,26,'     uyyyyyyyyyyyyyyyyyyyyyyyyyyyyv     ',0
dms			dc.b	0,27,'       PRESS "SPACE" TO CONTINUE.       ',0
map_lu		dc.l	28,dm1,dm2,dm3,dm4,dm5,dm6,dm7,dm8,dm9,dma,dmb,dmc,dmd,dme
			dc.l	dmf,dmg,dmh,dmi,dmj,dmk,dml,dmm,dmn,dmo,dmp,dmq,dmr,dms
st1			dc.b	0,00,'eiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiif',0
st2			dc.b	0,01,'j                                      j',0
st3			dc.b	0,02,'j       swt www swt www s t swt        j',0
st4			dc.b	0,03,'j       x    z  x z  z  x z x          j',0
st5			dc.b	0,04,'j       uyt  z  xyz  z  x z uyt        j',0
st6			dc.b	0,05,'j         z  z  x z  z  x z   z        j',0
st7			dc.b	0,06,'j       uyv  z  x z  z  uyv uyv        j',0
st8			dc.b	0,07,'j                                      j',0
st9			dc.b	0,08,'j                                      j',0
sta			dc.b	0,09,'j             LIVES =                  j',0
stb			dc.b	0,10,'j              TIME =                  j',0
stc			dc.b	0,11,'j          DIAMONDS =                  j',0
std			dc.b	0,12,'j          MONSTERS =                  j',0
ste			dc.b	0,13,'j             SCORE =                  j',0
stf			dc.b	0,14,'j          HI-SCORE =                  j',0
stg			dc.b	0,15,'j                                      j',0
sth			dc.b	0,16,'j                                      j',0
sti			dc.b	0,17,'j       swt www swt www s t swt        j',0
stj			dc.b	0,18,'j       x    z  x z  z  x z x          j',0
stk			dc.b	0,19,'j       uyt  z  xyz  z  x z uyt        j',0
stl			dc.b	0,20,'j         z  z  x z  z  x z   z        j',0
stm			dc.b	0,21,'j       uyv  z  x z  z  uyv uyv        j',0
stn			dc.b	0,22,'j                                      j',0
sto			dc.b	0,23,'j                                      j',0
stp			dc.b	0,24,'j     PRESS "SPACE"  TO CONTINUE       j',0
stq			dc.b	0,25,'j     PRESS "ESCAPE" TO END GAME       j',0
str			dc.b	0,26,'j                                      j',0
sts			dc.b	0,27,'giiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiih',0
status_lu	dc.l	28,st1,st2,st3,st4,st5,st6,st7,st8,st9,sta,stb,stc,std,ste
			dc.l	stf,stg,sth,sti,stj,stk,stl,stm,stn,sto,stp,stq,str,sts
pt1			dc.b	0,00,'eiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiif',0
pt2			dc.b	0,01,'j                                      j',0
pt3			dc.b	0,02,'j         swt swt www swt swt          j',0
pt4			dc.b	0,03,'j         x   x z  z  x   x v          j',0
pt5			dc.b	0,04,'j         xww x z  z  xww xw           j',0
pt6			dc.b	0,05,'j         x   x z  z  x   x t          j',0
pt7			dc.b	0,06,'j         uyv x z  z  uyv x z          j',0
pt8			dc.b	0,07,'j                                      j',0
pt9			dc.b	0,08,'j   swt swt swt swt x z swt swt wwt    j',0
pta			dc.b	0,09,'j   x z x z x   x   x z x z x v z z    j',0
ptb			dc.b	0,10,'j   xyv xyz uyt uyt x z x z xw  z z    j',0
ptc			dc.b	0,11,'j   x   x z   z   z xwz x z x t z z    j',0
ptd			dc.b	0,12,'j   x   x z uyv uyv u v uyv x z yyv    j',0
pte			dc.b	0,13,'j                                      j',0
ptf			dc.b	0,14,'j                                      j',0
ptg			dc.b	0,15,'j                                      j',0
pth			dc.b	0,16,'j                                      j',0
pti			dc.b	0,17,'j         PASSWORD :                   j',0
ptj			dc.b	0,18,'j                                      j',0
ptk			dc.b	0,19,'j                                      j',0
ptl			dc.b	0,20,'j                                      j',0
ptm			dc.b	0,21,'j                                      j',0
ptn			dc.b	0,22,'j     PRESS "RETURN" WHEN CORRECT.     j',0
pto			dc.b	0,23,'j                                      j',0
ptp			dc.b	0,24,'j        PRESS "ESCAPE" TO EXIT        j',0
ptq			dc.b	0,25,'j                                      j',0
ptr			dc.b	0,26,'j                                      j',0
pts			dc.b	0,27,'giiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiih',0
pass_scr	dc.l	28,pt1,pt2,pt3,pt4,pt5,pt6,pt7,pt8,pt9,pta,ptb,ptc,ptd,pte
			dc.l	ptf,ptg,pth,pti,ptj,ptk,ptl,ptm,ptn,pto,ptp,ptq,ptr,pts
pass_text	dc.b	21,17,'          ',0
pass_flash	dc.w	25
pass_pos	dc.w	0
pon_off		dc.w	0
kt1			dc.b	0,00,'eiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiif',0
kt2			dc.b	0,01,'j                                      j',0
kt3			dc.b	0,02,'j        wwt swt swt swt swt swt       j',0
kt4			dc.b	0,03,'j        z z x   x    z  x z x         j',0
kt5			dc.b	0,04,'j        z z xww xww  z  x z xww       j',0
kt6			dc.b	0,05,'j        z z x   x    z  x z x         j',0
kt7			dc.b	0,06,'j        yyv uyv x   uyv x z uyv       j',0
kt8			dc.b	0,07,'j                                      j',0
kt9			dc.b	0,08,'j            x z swt x z swt           j',0
kta			dc.b	0,09,'j            x v x   u v x             j',0
ktb			dc.b	0,10,'j            xw  xww  x  uyt           j',0
ktc			dc.b	0,11,'j            x t x    x    z           j',0
ktd			dc.b	0,12,'j            x z uyv  x  uyv           j',0
kte			dc.b	0,13,'j                                      j',0
ktf			dc.b	0,14,"j                                      j",0
ktg			dc.b	0,15,'j                                      j',0
kth			dc.b	0,16,'j             LEFT : Z                 j',0
kti			dc.b	0,17,'j            RIGHT : X                 j',0
ktj			dc.b	0,18,"j               UP : '                 j",0
ktk			dc.b	0,19,'j             DOWN : /                 j',0
ktl			dc.b	0,20,'j           STATUS : RETURN            j',0
ktm			dc.b	0,21,'j              MAP : M                 j',0
ktn			dc.b	0,22,'j                                      j',0
kto			dc.b	0,23,'j                                      j',0
ktp			dc.b	0,24,'j                                      j',0
ktq			dc.b	0,25,'j     PRESS "SPACE" TO DEFINE KEYS     j',0
ktr			dc.b	0,26,'j        PRESS "ESCAPE" TO EXIT        j',0
kts			dc.b	0,27,'giiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiih',0
keys_scr	dc.l	28,kt1,kt2,kt3,kt4,kt5,kt6,kt7,kt8,kt9,kta,ktb,ktc,ktd,kte
			dc.l	ktf,ktg,kth,kti,ktj,ktk,ktl,ktm,ktn,kto,ktp,ktq,ktr,kts
key_pntrs	dc.l	kth,kti,ktj,ktk,ktl,ktm
left		dc.w	z
right		dc.w	x
up			dc.w	quote
down		dc.w	slash
vstatus		dc.w	return
vmap		dc.w	m
icon_line	dc.b	6,00,'                            ',$ff
play_map	rept	3*34
			dc.b	solid5
			endr
			rept	24
			dc.b	solid5,solid5,solid5
			ds.b	28
			dc.b	solid5,solid5,solid5
			endr
			rept	3*34
			dc.b	solid5
			endr
play_tran	ds.w	8
seq_pntr	dc.l	lk_seq
seq_pntr2	dc.l	lk_seq+2+8*4
seq_count	dc.w	23
rep_action	dc.w	0
rep_still	dc.w	150
wl_seq		dc.w	5
			dc.l	chars+wl1*512
			dc.l	chars+wl2*512
			dc.l	chars+wl3*512
			dc.l	chars+wl4*512
			dc.l	chars+wl5*512
			dc.l	chars+wl6*512
wr_seq		dc.w	5
			dc.l	chars+wr1*512
			dc.l	chars+wr2*512
			dc.l	chars+wr3*512
			dc.l	chars+wr4*512
			dc.l	chars+wr5*512
			dc.l	chars+wr6*512
wu_seq		dc.w	5
			dc.l	chars+up1*512
			dc.l	chars+up2*512
			dc.l	chars+up3*512
			dc.l	chars+up4*512
			dc.l	chars+up3*512
			dc.l	chars+up2*512
lk_seq		dc.w	31
			dc.l	chars+lookl*512
			dc.l	chars+lookl*512
			dc.l	chars+lookl*512
			dc.l	chars+lookl*512
			dc.l	chars+lookl*512
			dc.l	chars+lookl*512
			dc.l	chars+lookl*512
			dc.l	chars+lookl*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+lookr*512
			dc.l	chars+lookr*512
			dc.l	chars+lookr*512
			dc.l	chars+lookr*512
			dc.l	chars+lookr*512
			dc.l	chars+lookr*512
			dc.l	chars+lookr*512
			dc.l	chars+lookr*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
			dc.l	chars+repton*512
map			dc.w	0
sp_starts	dc.b	0,1,1,1,2,1,1,1,0,0,1,1,0,0,1,1
			dc.b	2,2,2,2,2,2,2,2,2,0,2,2,2,2,2,2
			dc.b	0,1,1,1,0,1,1,1,0,0,1,1,0,0,1,1
			dc.b	2,2,2,2,2,2,2,2,0,0,2,2,2,0,2,2
			dc.b	3,3,1,1,3,3,1,1,0,0,1,1,0,0,1,1
			dc.b	3,3,3,3,3,3,3,3,0,0,2,0,0,0,2,0
			dc.b	3,3,3,1,3,3,1,1,0,0,1,1,0,0,1,1
			dc.b	3,3,3,3,3,3,3,3,0,0,2,3,0,0,2,0
			dc.b	3,1,1,1,2,1,1,1,0,0,1,1,0,0,1,1
			dc.b	2,2,2,2,2,2,2,2,2,0,2,2,2,2,2,2
			dc.b	0,1,1,1,0,1,1,1,0,0,1,1,0,0,1,1
			dc.b	2,2,2,2,2,2,2,2,0,0,2,2,2,0,2,2
			dc.b	3,3,3,1,3,3,1,1,0,0,1,1,0,0,1,1
			dc.b	3,3,3,3,3,3,3,3,0,0,2,1,0,0,2,1
			dc.b	3,3,3,1,3,3,1,1,0,0,1,1,0,0,1,1
			dc.b	3,3,3,3,3,3,3,3,0,0,2,3,0,0,2,0
rand_num	dc.w	57
rand_count	dc.w	1000
pass_disp	dc.b	1,0,0,0,0,0,0,0,0
ecode_disp	dc.b	0,0,0,0,0,0,0,0
dashes		dc.b	'--------'
edit_codes	dc.b	'00000000'
			dc.b	'00000000'
			dc.b	'00000000'
			dc.b	'00000000'
			dc.b	'00000000'
			dc.b	'00000000'
			dc.b	'00000000'
			dc.b	'00000000'
codes		ds.w	8
activity	dc.b	$ff
key_press	dc.b	0
map_files	dc.b	'*.MAP',0
chr_files	dc.b	'*.CHR',0
star_dot	dc.b	'*.*',0
lt1			dc.b	0,01,'eiiiiiiiiiiiiiiiiiiiiiiiiiif',0
lt2			dc.b	0,02,'j LOAD MAP FILE.           j',0
lt3			dc.b	0,03,'kiiiiiiiiiiiiiiiiiiiiiiiiiil',0
lt4			dc.b	0,04,'j PATH   =                 j',0
lt5			dc.b	0,05,'j FILES  =                 j',0
lt6			dc.b	0,06,'kiiiiiiiiiiiiiiiiiiniiiiiiil',0
lt7			dc.b	0,07,'j   --------.--- c j       j',0
lt8			dc.b	0,08,'j   --------.--- | j       j',0
lt9			dc.b	0,09,'j   --------.--- | j       j',0
lta			dc.b	0,10,'j   --------.--- | j       j',0
ltb			dc.b	0,11,'j   --------.--- | j       j',0
ltc			dc.b	0,12,'j   --------.--- d j       j',0
ltd			dc.b	0,13,'kiiiiiiiiiiiiiiiiiil       j',0
lte			dc.b	0,14,'j   --------.--- c j       j',0
ltf			dc.b	0,15,'j   --------.--- | j       j',0
ltg			dc.b	0,16,'j   --------.--- | j       j',0
lth			dc.b	0,17,'j   --------.--- | j       j',0
lti			dc.b	0,18,'j   --------.--- | j       j',0
ltj			dc.b	0,19,'j   --------.--- | j       j',0
ltk			dc.b	0,20,'j   --------.--- | j       j',0
ltl			dc.b	0,21,'j   --------.--- d j       j',0
ltm			dc.b	0,22,'gbCANCELaiiiiiiiiiimiiiiiiih',0
ltable		dc.l	22,lt1,lt2,lt3,lt4,lt5,lt6,lt7,lt8,lt9,lta,ltb,ltc
			dc.l	ltd,lte,ltf,ltg,lth,lti,ltj,ltk,ltl,ltm
top_line	dc.b	4,06,'eiiiiiiiiiiiiiiiiiiif',0
unk01		dc.b	4,07,'j    DISK  ERROR    j',0
unk02		dc.b	4,08,'j AN UN-KNOWN ERROR j',0
unk03		dc.b	4,09,'j    HAS OCCURED    j',0
bot_line	dc.b	4,10,'gbCANCELaiiiiiiiiiiih',0
fnf02		dc.b	4,08,'j  FILE NOT FOUND.  j',0
fnf03		dc.b	4,09,'j                   j',0
pnf02		dc.b	4,08,'j INVALID  PATHNAME j',0
gen02		dc.b	4,08,'j   GENERAL ERROR   j',0
dnr02		dc.b	4,08,'j  DRIVE NOT READY  j',0
wri02		dc.b	4,08,'j WRITE DATA ERROR  j',0
rea02		dc.b	4,08,'j  READ DATA ERROR  j',0
drp02		dc.b	4,08,'j     DISK WRITE    j',0
drp03		dc.b	4,09,'j     PROTECTED!    j',0
nod02		dc.b	4,08,'j  DRIVE NOT READY  j',0
unk_lu		dc.l	5,top_line,unk01,unk02,unk03,bot_line
fnf_lu		dc.l	5,top_line,unk01,fnf02,fnf03,bot_line
pnf_lu		dc.l	5,top_line,unk01,pnf02,fnf03,bot_line
gen_lu		dc.l	5,top_line,unk01,gen02,fnf03,bot_line
dnr_lu		dc.l	5,top_line,unk01,dnr02,fnf03,bot_line
wri_lu		dc.l	5,top_line,unk01,wri02,fnf03,bot_line
rea_lu		dc.l	5,top_line,unk01,rea02,fnf03,bot_line
drp_lu		dc.l	5,top_line,unk01,drp02,drp03,bot_line
nod_lu		dc.l	5,top_line,unk01,nod02,fnf03,bot_line
err_lu		dc.l	-33,fnf_lu
			dc.l	-34,pnf_lu
			dc.l	-01,gen_lu
			dc.l	-02,dnr_lu
			dc.l	-10,wri_lu
			dc.l	-11,rea_lu
			dc.l	-12,gen_lu
			dc.l	-13,drp_lu
			dc.l	-17,nod_lu
mouse_rout	dc.l	0
old_mouse	dc.l	0
mouse_x		dc.w	160
mouse_y		dc.w	100
m_buttons	dc.b	0
old_x		dc.w	0
old_y		dc.w	0
old_buttons	dc.b	0
older_x		dc.w	0
older_y		dc.w	0
x_max		dc.w	312
x_min		dc.w	2
y_max		dc.w	191
y_min		dc.w	2
dash_line	dc.b	'--------.---',0
drive		dc.b	'A:',0
key_text	dc.b	'UNKNOWN  ','ESCAPE   ','1        ','2        '
			dc.b	'3        ','4        ','5        ','6        '
			dc.b	'7        ','8        ','9        ','0        '
			dc.b	'-        ','=        ','BACKSPACE','TAB      '
			dc.b	'Q        ','W        ','E        ','R        '
			dc.b	'T        ','Y        ','U        ','I        '
			dc.b	'O        ','P        ','[        ',']        '
			dc.b	'RETURN   ','CONTROL  ','A        ','S        '
			dc.b	'D        ','F        ','G        ','H        '
			dc.b	'J        ','K        ','L        ',';        '
			dc.b	"'        ",'`        ','L_SHIFT  ','#        '
			dc.b	'Z        ','X        ','C        ','V        '
			dc.b	'B        ','N        ','M        ',',        '
			dc.b	'.        ','/        ','R_SHIFT  ','UNKNOWN  '
			dc.b	'ALTERNATE','SPACE    ','CAPS-LOCK','F1       '
			dc.b	'F2       ','F3       ','F4       ','F5       '
			dc.b	'F6       ','F7       ','F8       ','F9       '
			dc.b	'F10      ','UNKNOWN  ','UNKNOWN  ','CLR-HOME '
			dc.b	'c ARROW  ','UNKNOWN  ','N_       ','a ARROW  '
			dc.b	'UNKNWON  ','b ARROW  ','N+       ','UNKNOWN  '
			dc.b	'd ARROW  ','UNKNOWN  ','INSERT   ','DELETE   '
			dc.b	'UNKNOWN  ','UNKNOWN  ','UNKNOWN  ','UNKNOWN  '
			dc.b	'UNKNOWN  ','UNKNOWN  ','UNKNOWN  ','UNKNOWN  '
			dc.b	'UNKNOWN  ','UNKNOWN  ','UNKNOWN  ','UNKNOWN  '
			dc.b	'\        ','UNDO     ','HELP     ','N(       '
			dc.b	'N)       ','N/       ','N*       ','N7       '
			dc.b	'N8       ','N9       ','N4       ','N5       '
			dc.b	'N6       ','N1       ','N2       ','N3       '
			dc.b	'N0       ','N.       ','ENTER    ','UNKNOWN  '
			dc.b	'UNKNOWN  ','UNKNOWN  ','UNKNOWN  ','UNKNOWN  '
			dc.b	'UNKNOWN  ','UNKNOWN  ','UNKNOWN  ','UNKNOWN  '
			dc.b	'UNKNOWN  ','UNKNOWN  ','UNKNOWN  '
letters		dc.b	0,1,"1234567890_",0,8,0
			dc.b	"QWERTYUIOP",0,0,13,0,"AS"
			dc.b	"DFGHJKL",0,0,0,0,0,"ZXCV"
			dc.b	"BNM",0,0,0,0,0,0,0,0,0,0,0,0,0
			dc.b	0,0,0,0,0,0,0,8,0,0,"_",8,0,0,0,0
			dc.b	0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0
			dc.b	0,8,0,0,0,0,0,"789456123"
			dc.b	"0",0,13,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
mouse_ch	incbin	mouse.bin
font		incbin	font.bin
icons		incbin	icons.bin
maps		incbin	set_one.map
char_cols	incbin	set_one.chr
chars		equ		char_cols+32
			section	bss
conv_flag	ds.w	1
off_chars	ds.w	256*45					; character offset
old_hsync	ds.l	1
mbuffer		ds.w	8*8
reset_time	ds.l	1
game_time	ds.l	1
key_delay	ds.w	1
ostart		ds.w	1
start		ds.w	1
hilight		ds.w	1
dead		ds.w	1
new_start	ds.l	1
lives		ds.w	1
finished	ds.w	1
choice		ds.w	1
rep_pos		ds.l	1
rep1		ds.b	1
rep2		ds.b	1
pushing		ds.w	1
direction	ds.w	1
s_offset	ds.w	1
wfnc:		ds.w	1
mfpa07:		ds.b	1			*vars for interrupt saving
mfpa09:		ds.b	1
mfpa13:		ds.b	1
mfpa15:		ds.b	1
mfpa19:		ds.b	1
mfpa1f:		ds.b	1
old134:		ds.l	1
oldvbl:		ds.l	1
oldhbl		ds.l	1
old_ssp		ds.l	1
old_scr		ds.l	1
old_res		ds.w	1
oldkey		ds.l	1
scr1		ds.l	1
scr2		ds.l	1
st_ste		ds.w	1
play_eggs	ds.w	3*8
play_spir	ds.w	3*12
rocks		ds.w	1
rock_table	ds.w	3*(28*24-3)
f_units		ds.w	1
fun_table	ds.w	3*24*28
play_time	ds.w	1
spirits		ds.w	1
monsters	ds.l	1
mkilled		ds.l	1
moves		ds.w	1
diamonds	ds.l	1
score		ds.l	1
hiscore		ds.l	1
man_x		ds.w	1
man_y		ds.w	1
exit		ds.w	1
pass		ds.w	1
keys		ds.b	128
pkt_dest	ds.l	1
act_pntr	ds.l	1
build_len	ds.b	1
build_pkt	ds.b	8
acia_stat	ds.b	1
misc_pkt	ds.b	8
mouse_pkt	ds.b	3
stick0_pkt	ds.b	2
stick1_pkt	ds.b	2
flash		ds.w	1
old_pal		ds.w	16
color_buff	ds.w	16
fade_data	ds.w	16*16
screens		ds.b	84480
buffer		ds.w	320
dta			ds.l	1				; pntr 2 disk transfer buffer
dir_offset	ds.w	1				; dir number scrolls
file_offset	ds.w	1				; file number scrolls
files		ds.w	1				; number of *.map's/*.chr's
file_num	ds.w	1				; filenumber to load
dirs		ds.w	1				; number of sub-directories
drives		ds.w	1				; number of attached drives
handle		ds.w	1
file_number	ds.w	1				; file to load
file_pntr	ds.l	1
pathname	ds.b	64				; current path
dir_names	ds.b	14*50			; directory names
f_names		ds.b	14*50			; filenames
my_stack	ds.b	6000
end_stack
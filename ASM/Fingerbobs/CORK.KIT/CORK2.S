***********************************
*  FINGERBOBS ST DEMO SCREEN #5   *
***********************************
*                                 *
*  Fingerbobs Corkscrew Scroller  *
*				  *
*              V2.0               *
*                                 *
*            20/09/89		  *
*                                 *
*           (c) Oberje            *                     
*                                 *
* Inspired by Vortex-42 Megademo2 *
* on the Amiga                    *
*                                 *
* A VERY MEGA scroll. Scroller    *
* actually corkscews!!!!          *
* Effect is achieved by barreling *
* a diagonal scroll.              *
* Scroller is 'wrapped round a    *
* central raster bar.		  *
*                                 *
* Music is RENEGADE by D.Whittakr *
* Runs from VBL                   *
*                                 *
***********************************

bar_line equ 85		;Line for scroller
bar_size equ 50		;Size of scroller ( Height )

	section	text

start	movea.l	a7,a5		; Keep old SP	
	lea	ustack,a7	; install our own stack
	movea.l	4(a5),a5	; Get Base Page address
	move.l	$c(a5),d0	; Find Text Section Size
	add.l	$14(a5),d0	; Add Data Section Size
	add.l	$1c(a5),d0	; Add BBS Section Size
	add.l	#$100,d0	; Add 256 bytes for safety!
	move.l	d0,-(a7)	;
	move.l	a5,-(a7)	; Call Mshrink, give area
	move.w	d0,-(a7)	; d0 long back to GEMDOS
	move.w	#$4a,-(a7)	;
	trap	#1
	lea	$c(a7),a7

	move.l	#bar2,do_cols2
	move.w	#3,wait
	
	bsr	super_on	;Set super mode
	bsr	music		;Initialse music module
	bsr	make_sets	;Generate Character Sets
	move.l	#scrolltext,scroll
	bsr	restart		;Set up Scroller variables
	
	bsr	new_vectors	;Install our vectors
	bsr	do_scroll	;DO IT!
	bsr	old_vectors	;Get back old vectors
	bsr	super_off	;Set user mode
	
	clr.w	-(a7)		;Pterm - Exit Program
	trap	#1
	
	
	***********************
	* The new VBL routine *
	***********************

new_vbl	
	addq.w	#1,$466.w	;Bump the frame count
	move.w	#0,$ffff8240.w	;Set Border colour to black
	move.b	#0,$fffffa1b.w	;Turn Timer B off
	move.b	#103,$fffffa21.w	
	move.l	#barcols,at	;Bar colours
	move.w	#15,lines	;Lines in bar
	move.l	#hbl,$120.w
	move.b	#8,$fffffa1b.w	;Turn Timer B on
	
	sub.w	#1,wait
	tst.w	wait
	beq	scroll_colours
	
call_music
	movem.l	d0-d7/a0-a6,-(a7)
	jsr	music50		;Call Music module
	movem.l (a7)+,d0-d7/a0-a6
	rte

scroll_colours
	move.w	#3,wait
	add.l	#2,do_cols2
	cmpi.l	#bar2_end,do_cols2
	bne	call_music
	move.l	#bar2,do_cols2
	bra	call_music		
		
		
hbl	move.l	a0,-(a7)	;Save Reg
	move.l	at,a0		;Get bar address
	move.w	(a0),$ffff8240	;Set Border to colour
	move.w	(a0),$ffff8244	;Set Back of scroll to this colour
	move.l	(a7)+,a0	;Restore reg
	addi.l	#2,at		;Point to next bar col
	subi.w	#1,lines	;Count down lines
	tst	lines
	beq	end_vbl		;Last line ?
	move.b	#0,$fffffa1b.w	;Turn Timer B off
	move.b	#1,$fffffa21.w	;1 line between HBLs
	move.b	#8,$fffffa1b.w
	bclr.b	#0,$fffffa0f.w	;Clear in-service bit
	rte
	
end_vbl move.w	#$322,$ffff8244	;Restore back of scroll colour
	move.l	#hbl_2,$120.w
	move.b	#1,$fffffa21.w	
	move.b	#8,$fffffa1b.w
	move.l	do_cols2,at2
	bclr.b	#0,$fffffa0f.w	;Clear in-service bit
	rte
	
hbl_2	move.l	a0,-(a7)
	move.l	at2,a0
	move.w	(a0),$ffff8250	;Colour8
	move.w	(a0),$ffff8252	;Colour9
	add.l	#2,at2
	move.l	(a7)+,a0
	move.b	#0,$fffffa1b.w
	move.b	#3,$fffffa21.w	
	move.b	#8,$fffffa1b.w
	bclr.b	#0,$fffffa0f.w	;Clear in-service bit
	rte
	
kybd	move.w	#$2300,sr	;Lower IPL to 3
goop	jmp	$80000		;Jump through old vector
 
	****************
	* HOUSEKEEPING *
	****************

super_on
	clr.l	-(a7)		;Set to SUPERVISOR mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_stack	;Save old SP
	
	lea	$ff8240,a0	;Copy current
	lea	old_palette,a1	;hardware palette
	move.w	#7,d0		;and then
savecol move.l	(a0),(a1)+	;blank it out
	clr.l	(a0)+
	dbra	d0,savecol

	move.w	#2,-(a7)	
	trap	#14
	addq.l	#2,a7
	move.l	d0,old_physbase	;Find and save physbase

	move.w	#4,-(a7)	
	trap	#14
	addq.l	#2,a7
	move.w	d0,old_res	;Find and save resolution

	move.l	#screen_area1,d0
	addi.l	#512,d0
	andi.l	#$ffffff00,d0
	move.l	d0,screen_1	;Set up Screen #1 pointer
	
	move.l	#screen_area2,d0
	addi.l	#512,d0
	andi.w	#$ffffff00,d0
	move.l	d0,screen_2	;Set up Screen #2 pointer
			
	clr.w	-(a7)	
	move.l	screen_1,-(a7)
	move.l	screen_2,-(a7)
	move.w	#5,-(a7)	;Change to Low resolution
	trap	#14		;and screen to correct
	lea	$c(a7),a7	;address
		
	bsr	switch_screen	;Swap Screens

	lea	picture,a0	;Copy background picture
	move.l	screen_1,a1	;to both screens
	move.l	screen_2,a2
	move.w	#7999,d0
picloop
	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbra	d0,picloop
	
	lea	$ff8240,a0	
	lea	cols,a2  	
	move.w	#7,d0		;Install
col_lp1	
	move.l	(a2)+,(a0)+	;New Palette
	dbra	d0,col_lp1
	
	rts
	
	
	
super_off
	move.l	old_physbase,d0	;Return screen to
	move.w	old_res,-(a7)	;old resolution
	move.l	d0,-(a7)	;and address
	move.l	d0,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	$c(a7),a7
	
	lea	$ff8240,a1	;Copy 
	lea	old_palette,a0	;old palette
	move.w	#7,d0		;to hardware
col_lp2	move.l	(a0)+,(a1)+	;palette
	dbra	d0,col_lp2
	
	move.l	old_stack,-(a7)	;Get back to USER mode
	move.w	#$20,-(a7)	;with old stack
	trap	#1
	addq.l	#6,a7

	rts
	
	
new_vectors	
	move	sr,-(a7)	;Save SR
	ori.w	#$700,sr	;Raise IPL to 7
	lea	vector_store,a0	;Save old MFP values here...
	move.b	$fffffa09,(a0)+	;MFP Enable B
	move.b	$fffffa07,(a0)+	;MFP Enable A
	move.b	$fffffa13,(a0)+	;MFP I-mask A
	adda.l	#1,a0
	move.l	$118.w,(a0)+	;Keybd
	move.l	$120.w,(a0)+	;HBL   - Timer B
	move.l	$70.w,(a0)+	;Vblank
	
	move.l	$118.w,goop+2	;Revector		
	move.l	#kybd,$118.w	;keyboard routine
	andi.b	#$fe,$fffffa07	;Enable A - Timer B off
	andi.b	#$df,$fffffa09	;Enable B - Timer C off
	move.l	#hbl,$120.w	;Install HBL
	ori.b	#1,$fffffa07.w	;Enable A - Timer B on	
	ori.b	#1,$fffffa13.w	;I-Mask A - Timer B on
	move.l	#new_vbl,$70.w	;Install VBL
		
	move.w	(a7)+,sr	;Restore SR
	rts
	

old_vectors
	move	sr,-(a7)	;Save SR
	ori.w	#$700,sr	;Raise IPL to 7
	lea	vector_store,a0	;Get vectors from here
	move.b	(a0)+,$fffffa09 ;MFP Enable B
	move.b	(a0)+,$fffffa07 ;MFP Enable A
	move.b	(a0)+,$fffffa13 ;MFP I-Mask A
	adda.l	#1,a0
	move.l	(a0)+,$118.w	;Keyboard
	move.l	(a0)+,$120.w	;HBL
	move.l	(a0)+,$70.w	;Vblank
	move.w	(a7)+,sr
	rts
	
	
	*****************************
	*			    *
	* THE MAIN PROGRAM ROUTINES *
	*			    *
	*****************************

;SCROLLER CONTROL LOOP
;> Scrolls 8 pixels of each character, prints
;  scroll"line" . Watches for end of scroller etc...
 
do_scroll
	move.l	set,a4		;Address of current char_set
	move.l	Table,a5	;Address of current Table
	move.l	scroll,a6	;Address of scroller data
	bsr	do_table	;Calculate the Diagonal scroll
	bsr	draw_bar	;Wrap it round a barrel
	bsr	switch_screen	;Now display it
	bsr	vbl

	move.l	Table,a5	;Clear out
	bsr	clear_screen	;The Diagonal Scroll data
	
	subi.l	#60*8*2,set	;Point to next set
	addi.l	#40*4,Table	;Pint to next Table
	addi.b	#1,count	;Count up pixels
	cmpi.b	#8,count	;Was Last pixel ?
	beq	remo		;Yes -> Branch
	
	move.w	#$ff,-(a7)	;Test for a key 
	move.w	#6,-(a7)
	trap	#1
	addq.l	#4,a7
	
	tst.w	d0
	beq	do_scroll
	
	rts			;Keypress = EXIT
	
	
	
remo	bsr	restart		;Last pix so set up for next char
	bra	do_scroll	;Back to main loop
	
restart
	move.l	#set_7,set	;Initial Set
	move.l	#Table_0,Table	;Initial Table
	move.b	#0,count	;Zero pixels
	addq.l	#1,scroll	;Next char
	cmpi.l	#scroll_end-39,scroll	
	beq	go_scroll	;End of message ?
	rts
	
; End of message -> Back to start of message

go_scroll
	move.l	#scrolltext,scroll
	rts
	
	
	*********************
	* Swap over Screens *
	*********************
	
switch_screen
	move.w	#-1,-(a7)	;Keep rez
	move.l	screen_1,-(a7)	;Use Screen #1
	move.l	screen_2,-(a7)	;Ignore Screen #2
	move.w	#5,-(a7)
	trap	#14
	lea	$c(a7),a7	;Swap Screens
	
;Swap over screen #1 and screen #2 so that
;Graphix are drawn on un-displayed screen

	move.l	screen_1,d0
	move.l	screen_2,screen_1
	move.l	d0,screen_2
	
	rts


;Wait for a VBL		
	
vbl	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	rts	


	
	************************
	* Draw Complete Barrel *
	************************
	
draw_bar
	lea	data,a0		;Print Front
	move.l	screen_1,a1	;Of Barrel
	adda.l	#(bar_line*$a0),a1
	bsr	show_barrel
	
	lea	data+($a0*80),a6	;Print Back
	move.l	screen_1,a1		;Of Barrel
	adda.l	#((bar_size+bar_line-1)*$a0),a1
	bsr	show_barrel2
	
	rts

;
;Display Front of Barrel
;

show_barrel
	lea	table,a2	;Point to Barrel Table
	move.w	#bar_size-1,d7	;No of line in Barrel
barrel_lp1
	move.l	a0,a3		;a3 = Data to barrel
	clr.l	d0
	move.b	(a2),d0		;Get Barrel Line Offset
	mulu	#$a0,d0		;Make into actual offset
	add.l	d0,a3		;Add for actual address of Data
	
	move.b	$0(a3),$99(a1)	;Copy a complete line of
	move.b	$1(a3),$0(a1)	;Data onto screen (a1)
	move.b	$8(a3),$1(a1)
	move.b	$9(a3),$8(a1)	
	move.b	$10(a3),$9(a1)	
	move.b	$11(a3),$10(a1)	
	move.b	$18(a3),$11(a1)	
	move.b	$19(a3),$18(a1)	
	move.b	$20(a3),$19(a1)	
	move.b	$21(a3),$20(a1)	
	move.b	$28(a3),$21(a1)	
	move.b	$29(a3),$28(a1)	
	move.b	$30(a3),$29(a1)	
	move.b	$31(a3),$30(a1)	
	move.b	$38(a3),$31(a1)	
	move.b	$39(a3),$38(a1)	
	move.b	$40(a3),$39(a1)	
	move.b	$41(a3),$40(a1)	
	move.b	$48(a3),$41(a1)	
	move.b	$49(a3),$48(a1)	
	move.b	$50(a3),$49(a1)	
	move.b	$51(a3),$50(a1)	
	move.b	$58(a3),$51(a1)	
	move.b	$59(a3),$58(a1)	
	move.b	$60(a3),$59(a1)	
	move.b	$61(a3),$60(a1)	
	move.b	$68(a3),$61(a1)	
	move.b	$69(a3),$68(a1)	
	move.b	$70(a3),$69(a1)	
	move.b	$71(a3),$70(a1)	
	move.b	$78(a3),$71(a1)	
	move.b	$79(a3),$78(a1)	
	move.b	$80(a3),$79(a1)	
	move.b	$81(a3),$80(a1)	
	move.b	$88(a3),$81(a1)	
	move.b	$89(a3),$88(a1)	
	move.b	$90(a3),$89(a1)	
	move.b	$91(a3),$90(a1)	
	move.b	$98(a3),$91(a1)	
	move.b	$99(a3),$98(a1)	

	addq.l	#1,a2		;Next Table entry
	adda.l	#$a0,a1		;Next screen line
	
	dbra	d7,barrel_lp1	;DO next line of Barrel
	rts


;
;Display Back of Barrel
;
;Same as front except screen addresses
;run backwards.
;

show_barrel2
	lea	table,a2
	move.w	#bar_size-1,d7
barrel_lp2
	move.l	a6,a3
	clr.l	d0
	move.b	(a2),d0
	mulu	#$a0,d0
	add.l	d0,a3
	
	*move.b	$0(a3),$99+2(a1)	;These two bytes
	*move.b	$1(a3),$0+2(a1)		;are usually garbage to don't print!
	move.b	$8(a3),$1+2(a1)
	move.b	$9(a3),$8+2(a1)	
	move.b	$10(a3),$9+2(a1)	
	move.b	$11(a3),$10+2(a1)	
	move.b	$18(a3),$11+2(a1)	
	move.b	$19(a3),$18+2(a1)	
	move.b	$20(a3),$19+2(a1)	
	move.b	$21(a3),$20+2(a1)	
	move.b	$28(a3),$21+2(a1)	
	move.b	$29(a3),$28+2(a1)	
	move.b	$30(a3),$29+2(a1)	
	move.b	$31(a3),$30+2(a1)	
	move.b	$38(a3),$31+2(a1)	
	move.b	$39(a3),$38+2(a1)	
	move.b	$40(a3),$39+2(a1)	
	move.b	$41(a3),$40+2(a1)	
	move.b	$48(a3),$41+2(a1)	
	move.b	$49(a3),$48+2(a1)	
	move.b	$50(a3),$49+2(a1)	
	move.b	$51(a3),$50+2(a1)	
	move.b	$58(a3),$51+2(a1)	
	move.b	$59(a3),$58+2(a1)	
	move.b	$60(a3),$59+2(a1)	
	move.b	$61(a3),$60+2(a1)	
	move.b	$68(a3),$61+2(a1)	
	move.b	$69(a3),$68+2(a1)	
	move.b	$70(a3),$69+2(a1)	
	move.b	$71(a3),$70+2(a1)	
	move.b	$78(a3),$71+2(a1)	
	move.b	$79(a3),$78+2(a1)	
	move.b	$80(a3),$79+2(a1)	
	move.b	$81(a3),$80+2(a1)	
	move.b	$88(a3),$81+2(a1)	
	move.b	$89(a3),$88+2(a1)	
	move.b	$90(a3),$89+2(a1)	
	move.b	$91(a3),$90+2(a1)	
	move.b	$98(a3),$91+2(a1)	
	move.b	$99(a3),$98+2(a1)	

	
	addq.l	#1,a2
	suba.l	#$a0,a1
	
	dbra	d7,barrel_lp2
	rts



;
;This routine clears the characters off the
;Diagonal scroll work area
;	
;a5 is appropriate table
;

clear_screen
	move.w	#39,d7		;40 chars to do!

round2
	move.l	(a5)+,a0	;Screen Address	
	move.w	a0,d0
	btst	#0,d0
	bne	second2		;If not even jump
	move.l	a4,a1
	
	clr.b	0*$a0+0(a0)	;Do blank for two
	clr.b	0*$a0+1(a0)	;Bytes in same word
	clr.b	1*$a0+0(a0)
	clr.b	1*$a0+1(a0)
	clr.b	2*$a0+0(a0)
	clr.b	2*$a0+1(a0)
	clr.b	3*$a0+0(a0)
	clr.b	3*$a0+1(a0)
	clr.b	4*$a0+0(a0)
	clr.b	4*$a0+1(a0)
	clr.b	5*$a0+0(a0)
	clr.b	5*$a0+1(a0)
	clr.b	6*$a0+0(a0)
	clr.b	6*$a0+1(a0)
	clr.b	7*$a0+0(a0)
	clr.b	7*$a0+1(a0)
	
	dbra	d7,round2
	
	rts
	
second2
	move.l	a4,a1
	
	clr.b	0*$a0+0(a0)	;Do blank
	clr.b	0*$a0+7(a0)	;for two bytes
	clr.b	1*$a0+0(a0)	;in different words
	clr.b	1*$a0+7(a0)
	clr.b	2*$a0+0(a0)
	clr.b	2*$a0+7(a0)
	clr.b	3*$a0+0(a0)
	clr.b	3*$a0+7(a0)
	clr.b	4*$a0+0(a0)
	clr.b	4*$a0+7(a0)
	clr.b	5*$a0+0(a0)
	clr.b	5*$a0+7(a0)
	clr.b	6*$a0+0(a0)
	clr.b	6*$a0+7(a0)
	clr.b	7*$a0+0(a0)
	clr.b	7*$a0+7(a0)
	
	dbra	d7,round2
	rts
	


;
;Prints Characters as specified by table
;Enter with Table address in a5
; and char_set address in a4
; and text address in a6
;

do_table
	move.w	#39,d7		;40 to do!

round
	move.l	(a5)+,a0	;Screen Address	
	move.w	a0,d0
	btst	#0,d0
	bne	second		;If not even then jump
	move.l	a4,a1
	clr.l	d0
	move.b	(a6)+,d0	;Get Letter
	subi.b	#32,d0		;Get Char offset
	bsr	print_character	;Print the character
	dbra	d7,round
	
	rts
	
second	move.l	a4,a1
	clr.l	d0
	move.b	(a6)+,d0
	subi.b	#32,d0
	mulu	#16,d0	;Char offset
	add.l	d0,a1	;Correct data
	
	move.b	0(a1),0*$a0+0(a0) ;Print char
	move.b	1(a1),0*$a0+7(a0) ;of 2 bytes
	move.b	2(a1),1*$a0+0(a0) ;in different words
	move.b	3(a1),1*$a0+7(a0)
	move.b	4(a1),2*$a0+0(a0)
	move.b	5(a1),2*$a0+7(a0)
	move.b	6(a1),3*$a0+0(a0)
	move.b	7(a1),3*$a0+7(a0)
	move.b	8(a1),4*$a0+0(a0)
	move.b	9(a1),4*$a0+7(a0)
	move.b	10(a1),5*$a0+0(a0)
	move.b	11(a1),5*$a0+7(a0)
	move.b	12(a1),6*$a0+0(a0)
	move.b	13(a1),6*$a0+7(a0)
	move.b	14(a1),7*$a0+0(a0)
	move.b	15(a1),7*$a0+7(a0)
	
	
	dbra	d7,round
	rts
	
	
	
;
;Prints a character at the address specified in a0
;Prints character d0, from set in a1
;

print_character
	mulu	#16,d0	;Char offset
	add.l	d0,a1	;Correct data
	
	move.b	0(a1),0*$a0+0(a0)
	move.b	1(a1),0*$a0+1(a0)
	move.b	2(a1),1*$a0+0(a0)
	move.b	3(a1),1*$a0+1(a0)
	move.b	4(a1),2*$a0+0(a0)
	move.b	5(a1),2*$a0+1(a0)
	move.b	6(a1),3*$a0+0(a0)
	move.b	7(a1),3*$a0+1(a0)
	move.b	8(a1),4*$a0+0(a0)
	move.b	9(a1),4*$a0+1(a0)
	move.b	10(a1),5*$a0+0(a0)
	move.b	11(a1),5*$a0+1(a0)
	move.b	12(a1),6*$a0+0(a0)
	move.b	13(a1),6*$a0+1(a0)
	move.b	14(a1),7*$a0+0(a0)
	move.b	15(a1),7*$a0+1(a0)
	
	rts


;
;Generates character sets required from
;a standard 8x8 font
;

make_sets
	lea	in_set,a0	;Basic Set
	lea	set_0,a1	;First New Set
	move.l	a1,a2		;Save a1
	
	move.w	#60-1,d7	;60 Characters
first_set	
	move.b	(a0),(a1)	;Create First Set
	move.b	1(a0),2(a1)
	move.b	2(a0),4(a1)
	move.b	3(a0),6(a1)
	move.b	4(a0),8(a1)
	move.b	5(a0),10(a1)
	move.b	6(a0),12(a1)
	move.b	7(a0),14(a1)
	
	add.l	#8,a0
	add.l	#16,a1
	
	dbra	d7,first_set

	move.w	#7-1,d7		;7 Set to do
next_set	
	move.l	a2,a0
	bsr	copy_set
	
        add.l	#60*2*8,a2	;Point next set
        move.l	a2,a0		
        bsr	shift_set	;Shift it
        
        dbra	d7,next_set
        
	rts

	
;Takes set at a0, for 60 characters and shifts each one place to
;the right

shift_set
	move.w	#60-1,d0	;60 chars
next_char
	lsr.w	(a0)	;Shift RIGHT 1 bit
	lsr.w	2(a0)
	lsr.w	4(a0)
	lsr.w	6(a0)
	lsr.w	8(a0)
	lsr.w	10(a0)
	lsr.w	12(a0)
	lsr.w	14(a0)
	
	add.l	#16,a0
	dbra	d0,next_char
	rts	
	
	
	
;Copys set 60*2*8 long from a0 to a0+60*2*8

copy_set
	move.l	a0,a1
	add.l	#60*2*8,a1
	move.w	#60*2*8-1,d0
copy_loop
	move.b	(a0)+,(a1)+
	dbra	d0,copy_loop
	rts
		


*****************************************
*					*
*      Music Module for 'RENEGADE'	* 
*					*
*          By Dave Whittaker		*
*					*
*          Hacked By Oberje'		*
*	       15/07/89			*
*					*
*      Thanks for the Labels Dave!	*
*      They really helped.		*
*					*
*****************************************


music	LEA	regs,A0
	PEA	initune
	MOVE.W	#$26,-(A7)
	TRAP	#14
	ADDQ.L	#6,A7
done	rts
	
	
	
bordb	MOVE.W	#0,$FF8240
	RTS
	
bordw	MOVE.W	#$777,$FF8240
	RTS
	
string	DC.B	$A,$A,$D,$27,$52,$45,$4E,$41
	DC.B	$47,$41,$44,$45,$27,$20,$4D,$55
	DC.B	$53,$49,$43,$20,$2D,$20,$41,$54
	DC.B	$41,$52,$49,$20,$53,$54,$20,$20
	DC.B	$56,$45,$52,$53,$49,$4F,$4E,$20
	DC.B	$31,$2E,$30,$A,$A,$D,$28,$43
	DC.B	$29,$20,$44,$61,$76,$69,$64,$20
	DC.B	$57,$68,$69,$74,$74,$61,$6B,$65
	DC.B	$72,$20,$20,$4D,$43,$4D,$4C,$58
	DC.B	$58,$58,$56,$31,$A,$D,0,0

initune	CLR.B	monoff	
	CLR.B	fonoff
	LEA	stads,A0
	LEA	chan_a,A1
	MOVEQ	#2,D7
initial	MOVE.B	#1,$1B(A1)
	CLR.B	0(A1)
	CLR.B	$2C(A1)
	MOVEA.L	(A0)+,A2
	MOVE.L	A2,6(A1)
	MOVE.L	#4,$A(A1)
	MOVE.L	(A2),2(A1)
	ADDA.L	#$2E,A1
	DBF	D7,initial
	MOVE.B	#1,no_tt
	MOVE.B	#1,monoff
	RTS

chan_a	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,9
chan_b	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,$12
chan_c	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,0,0,0
	DC.B	0,0,0,0,0,$24

no_tt	DC.B	0
no_t	dc.b	0
nz_f	DC.B	0
nz_ft	dc.b	0
reg_7	DC.B	$FF
finet	dc.b	6
	
ret	RTS

music50	BTST	#1,$FF820A
	BNE	not60
	SUBQ.B	#1,finet
	BNE	not60
	MOVE.B	#6,finet
	BRA	ret
	
not60	BSR	effects
	TST.B	monoff
	BEQ	ret
	MOVE.B	nz_f,nz_ft
	SUBQ.B	#1,no_tt
	BNE	walbol
	LEA	chan_a,A0
	BSR	mz_ch
	LEA	chan_b,A0
	BSR	mz_ch
	LEA	chan_c,A0
	BSR	mz_ch
	MOVE.B	no_t,no_tt
	
walbol	LEA	chan_a,A0
	BSR	mz_50
	MOVE.W	D0,tempd0
	MOVE.B	D0,regs
	MOVE.B	tempd0,regs+1
	MOVE.B	D1,regs+8
	LEA	chan_b,A0
	BSR	mz_50
	MOVE.W	D0,tempd0
	MOVE.B	D0,regs+2
	MOVE.B	tempd0,regs+3
	MOVE.B	D1,regs+9
	LEA	chan_c,A0
	BSR	mz_50
	MOVE.W	D0,tempd0
	MOVE.B	D0,regs+4
	MOVE.B	tempd0,regs+5
	MOVE.B	D1,regs+10
	MOVE.B	nz_ft,regs+6
	TST.B	fonoff
	BEQ	mz_out
	
mz_out	MOVE.B	#7,$FF8800
	MOVE.B	$FF8800,D0
	ANDI.B	#$C0,D0
	ANDI.B	#$3F,regs+7
	OR.B	D0,regs+7
	LEA	fregs,A0
	MOVE.W	#$C,D0
outer	MOVE.B	D0,$FF8800
	MOVE.B	-(A0),$FF8802
	DBF	D0,outer
	BRA	ret
	
turnoff	CLR.B	monoff
	CLR.B	fonoff
clr_reg	MOVE.B	#7,$FF8800
	MOVE.B	$FF8800,D1
	ORI.B	#$3F,D1
	MOVE.W	#$C,D0
clr_lp	MOVE.B	D0,$FF8800
	MOVE.B	#0,$FF8802
	DBF	D0,clr_lp
	MOVE.B	#7,$FF8800
	MOVE.B	D1,$FF8802
	RTS
	
toke_tab	DC.l	pause
		dc.l	vibe_0
		DC.l	vibe_1
		dc.l	vibe_2
		DC.l	slide
		dc.l	gl_dn
		DC.l	gl_up
		dc.l	ending
		DC.l	vibe_set
		dc.l	nz_freq
		DC.l	square
		dc.l	noise
		DC.l	both
		dc.l	toggle
		DC.l	cutt
	
cutt	ADDQ.L	#4,A7
	BRA	turnoff
	
ending	MOVE.L	$A(A0),D0
	MOVEA.L	6(A0),A2
	ADDA.L	D0,A2
	ADDQ.L	#4,D0
	MOVEA.L	(A2),A1
	TST.L	(A2)
	BNE	set_mem
	MOVEA.L	6(A0),A2
	MOVEQ	#4,D0
	MOVEA.L	(A2),A1
set_mem	MOVE.L	D0,$A(A0)
	BRA	read
	
noise	MOVE.B	$2D(A0),D0
	MOVE.B	D0,D1
	ANDI.B	#7,D0
	MOVE.B	reg_7,D2
	EOR.B	D2,D0
	AND.B	D1,D0
	EOR.B	D2,D0
	MOVE.B	D0,reg_7
	BRA	read
	
square	MOVE.B	$2D(A0),D0
	MOVE.B	D0,D1
	ANDI.B	#$38,D0
	MOVE.B	reg_7,D2
	EOR.B	D2,D0
	AND.B	D1,D0
	EOR.B	D2,D0
	MOVE.B	D0,reg_7
	BRA	read
	
both	MOVE.B	$2D(A0),D0
	EORI.B	#$FF,D0
	MOVE.B	reg_7,D2
	AND.B	D2,D0
	AND.B	D0,reg_7
	BRA	read
	
slide	CLR.W	$E(A0)
	BSET	#2,0(A0)
	MOVE.B	(A1)+,$18(A0)
	MOVE.B	(A1)+,$19(A0)
	BRA	read
	
nz_freq	MOVE.B	(A1)+,nz_f
	BRA	read
	
vibe_set	MOVE.B	(A1)+,$2A(A0)
		MOVE.B	(A1),$29(A0)
		MOVE.B	(A1)+,$2B(A0)
		BRA	read
		
gl_up	BSET	#7,0(A0)
gl_dn	BSET	#3,0(A0)
	BRA	read
	
vibe_0	CLR.B	$2C(A0)
	BRA	read
	
vibe_1	MOVE.B	#$40,$2C(A0)
	BRA	read
	
vibe_2	MOVE.B	#$C0,$2C(A0)
	BRA	read
	
toggle	BSET	#1,0(A0)
	BRA	read
	
pause	CLR.B	$1E(A0)
	BRA	valued
	
mz_ch	SUBQ.B	#1,$1B(A0)
	BNE	gliss_it
	CLR.B	0(A0)
	MOVEA.L	2(A0),A1
read	MOVEQ	#0,D0
	MOVE.B	(A1)+,D0
	BMI	extend
	MOVE.B	D0,$1D(A0)
	MOVEA.L	$24(A0),A2
	MOVE.L	A2,$20(A0)
	MOVE.B	(A2),$28(A0)
	MOVE.B	(A2),$1E(A0)
	MOVE.B	$1A(A0),$1F(A0)
	BSET	#5,0(A0)
valued	MOVE.B	$1C(A0),$1B(A0)
	MOVE.L	A1,2(A0)
	RTS
	
gliss_it	BTST	#3,0(A0)
		RTS
	
	BTST	#7,0(A0)
	BEQ	gl_down
	ADDQ.B	#1,$1D(A0)
	RTS

gl_down	SUBQ.B	#1,$1D(A0)
	RTS

extend	CMP.B	#$B8,D0
	BCS	tokens
	ADDI.B	#$20,D0
	BCS	length
	ADDI.B	#$10,D0
	BCS	envs
	ADDI.B	#$10,D0
	BCC	temps
	ASL.B	#2,D0
	LEA	ch_tab,A2
	ADDA.L	D0,A2
	MOVE.L	(A2),$14(A0)
	MOVE.L	(A2),$10(A0)
	BRA	read
	
temps	ADDI.B	#9,D0
	MOVE.B	D0,no_t
	BRA	read
	
length	ADDQ.B	#1,D0
	MOVE.B	D0,$1C(A0)
	BRA	read
	
envs	ASL.W	#2,D0
	LEA	ev_tab,A2
	MOVEA.L	0(A2,D0.W),A2
	MOVE.L	A2,$24(A0)
	MOVE.B	-1(A2),$1A(A0)
	BRA	read
	
tokens	ANDI.W	#$7F,D0
	ASL.W	#2,D0
	LEA	toke_tab,A2
	MOVEA.L	0(A2,D0.W),A2
	JMP	(A2)
	
mz_50	MOVEQ	#0,D7
	MOVE.B	0(A0),D7
	BTST	#5,D7
	BEQ	form
	SUBQ.B	#1,$1F(A0)
	BCC	ev_delay
	MOVE.B	$1A(A0),$1F(A0)
	MOVEA.L	$20(A0),A2
	CMPI.B	#$87,1(A2)
	BEQ	ev_delay
	ADDQ.L	#1,$20(A0)
	MOVE.B	1(A2),$28(A0)
ev_delay
	MOVE.B	$28(A0),$1E(A0)
	BNE	form
form	MOVE.B	$1D(A0),D0
	MOVEA.L	$14(A0),A1
	MOVE.B	(A1),D1
	CMP.B	#$87,D1
	BNE	ch_calc
	MOVEA.L	$10(A0),A1
	MOVE.B	(A1),D1
ch_calc	ADDQ.L	#1,A1
	MOVE.L	A1,$14(A0)
	ADD.B	D1,D0
produce	LEA	note_tab,A1
	ADD.B	D0,D0
	MOVEQ	#0,D1
	MOVE.B	D0,D1
	ADDA.L	D1,A1
	MOVE.W	(A1),D0
	MOVE.B	$2C(A0),D6
	BTST	#6,D6
	BEQ	twiggle
	MOVE.B	D1,D5
	MOVE.B	$29(A0),D4
	LSL.B	#1,D4
	MOVE.B	$2B(A0),D1
	BTST	#7,D6
	BEQ	vb_now
	BTST	#0,D7
	BNE	vb_same
vb_now	BTST	#5,D6
	BNE	vb_up
	SUB.B	$2A(A0),D1
	BCC	vb_reach
	BSET	#5,$2C(A0)
	MOVEQ	#0,D1
	BRA	vb_reach
	
vb_up	ADD.B	$2A(A0),D1
	CMP.B	D4,D1
	BCS	vb_reach
	BCLR	#5,$2C(A0)
	MOVE.B	D4,D1
vb_reach
	MOVE.B	D1,$2B(A0)
vb_same	LSR.B	#1,D4
	SUB.B	D4,D1
	BCC	warble
	SUBI.W	#$100,D1
warble	ADDI.B	#$A0,D5
	BCS	hi_vb
shift_vb
	LSL.W	#1,D1
	ADDI.B	#$18,D5
	BCC	shift_vb
hi_vb	ADD.W	D1,D0
twiggle	EORI.B	#1,D7
	MOVE.B	D7,0(A0)
	BTST	#2,D7
	BEQ	tg_form
	MOVE.B	$19(A0),D4
	SUBQ.B	#1,D4
	BNE	sl_cnt
	CLR.W	D6
	MOVE.B	$18(A0),D6
	BPL	sl_up
	ADDI.W	#$FF00,D6
sl_up	ADD.W	$E(A0),D6
	MOVE.W	D6,$E(A0)
	ADD.W	D6,D0
	BRA	tg_form
	
sl_cnt	MOVE.B	D4,$19(A0)
tg_form	EORI.B	#$FF,D7
	MOVE.B	reg_7,D3
	ANDI.B	#3,D7
	BNE	SET_7
	MOVE.B	nz_f,D3
	EORI.B	#8,D3
	MOVE.B	D3,nz_ft
	MOVE.B	#7,D3
SET_7	MOVE.B	regs+7,D2
	EOR.B	D2,D3
	AND.B	$2D(A0),D3
	EOR.B	D3,regs+7
	MOVE.B	$1E(A0),D1
	RTS


regs	DC.B	0,0,0,0,0,0,0,$3F
	DC.B	$F,$F,$F,0,0

fregs	dc.b	0,0,0
	DC.B	0,0,0,0,$3F,$10,0,$10
	DC.B	0,$FF

note_tab
	DC.W	$EEE,$E17,$D4D,$C8E
	DC.W	$BD9,$B2F,$A8E,$9F7
	DC.W	$967,$8E0,$861,$7E8
	DC.W	$777,$70B,$6A6,$647
	DC.W	$5EC,$597,$547,$4FB
	DC.W	$4B3,$470,$430,$3F4
	DC.W	$3BB,$385,$353,$323
	DC.W	$2F6,$2CB,$2A3,$27D
	DC.W	$259,$238,$218,$1FA
	DC.W	$1DD,$1C2,$1A9,$191
	DC.W	$17B,$165,$151,$13E
	DC.W	$12C,$11C,$10C,$FD
	DC.W	$EE,$E1,$D4,$C8
	DC.W	$BD,$B2,$A8,$9F
	DC.W	$96,$8E,$86,$7E
	DC.W	$77,$70,$6A,$64
	DC.W	$5E,$59,$54,$4F
	DC.W	$4B,$47,$43,$3F
	DC.W	$3B,$38,$35,$32
	DC.W	$2F,$2C,$2A,$27
	DC.W	$25,$23,$21,$1F
	DC.W	$1D,$1C,$1A,$19
	DC.W	$17,$16,$15,$13
	DC.W	$12,$11,$10,$F

ch_tab	DC.l	ch_0
	dc.l	ch_1
	DC.l	ch_2
	dc.l	ch_3
	DC.l	ch_4
	dc.l	ch_5
	DC.l	ch_6
	dc.l	ch_7
	DC.l	ch_8
	dc.l	ch_9
	DC.l	ch_10
	dc.l	ch_11
	DC.l	ch_12
	dc.l	ch_13
	DC.l	ch_14

ch_0	DC.B	0,$87
ch_1	dc.b	0,3,7,$87
ch_2	dc.b	0,4,7,$87
ch_3	dc.b	0,3,7,$C,$87
ch_4	dc.b	0,4,7,$C,$87
ch_5	dc.b	7,$C,$F,$87
ch_6	DC.B	7,$C,$10,$87
ch_7	dc.b	3,7,$C,$87
ch_8	DC.B	4,7,$C,$87
ch_9	dc.b	0,$C,$87
ch_10	dc.b	0,4,$87
ch_11	dc.b	0,3,$87
ch_12	dc.b	0,5,$87
ch_13	DC.B	0,7,$87
ch_14	dc.b	0,0,0,0,$c,$87,0

ev_tab	DC.l	ev_0
	dc.l	ev_1
	DC.l	ev_2
	dc.l	ev_3

	dc.b	$01
	
ev_0	dc.b	$0f,$0e,$0d,$0c,$0b,$0a,$87,$06
ev_1	dc.b	$0f,$0e,$0d,$0c,$0b,$0a,$87,$06
ev_2	dc.b	$0f,$0e,$0d,$0c,$0b,$0a,$87,$06
ev_3	dc.b	$0f,$0e,$0d,$0c,$0b,$0a,$0d,$0b
	dc.b	$09,$0c,$0a,$08,$0b,$87,$00
ev_4	dc.b	$00,$87,$00

	even

monoff	DC.B	0
fonoff	dc.b	0
tempo	DC.B	0,0
tempd0	DC.B	0,0

stads	DC.l	tunea1
	dc.l	tunea2
	DC.l	tunea3

tunea1	DC.l	a1p1
	DC.L	a1p2
	DC.l	a1p3
	DC.L	a1p4
	DC.l	a1p1
	DC.L	a1p2
	DC.l	a1p3
	DC.L	a1p3
	DC.l	00

tunea2	DC.l	a2p1
	DC.L	$00

tunea3	DC.l	a3p3
	DC.L	a3p1
	DC.l	a3p2
	DC.L	a3p2
	DC.l	a3p3
	DC.L	a3p1
	DC.l	a3p1
	DC.L	$00

a1p1	DC.B	$BC,$D0,$C0,$89,1,$E0,$8A,$10
	DC.B	$10,$10,$8C,$1C,$E1,$8B,$89,7
	DC.B	$8D,0,$E0,$8A,$10,$8C,$1C,$89
	DC.B	1,$E0,$8A,$10,$10,$10,$8C,$1C
	DC.B	$E1,$8B,$89,$1F,$8D,0,$E0,$8A
	DC.B	$10,$8C,$1C,$87

a1p2	DC.B	$D0,$C0,$89,1,$E0,$8A,$C,$C
	DC.B	$C,$8C,$18,$E1,$8B,$89,7,$8D
	DC.B	0,$E0,$8A,$C,$8C,$18,$89,1
	DC.B	$E0,$8A,$C,$C,$C,$8C,$18,$E1
	DC.B	$8B,$89,7,$8D,0,$E0,$8A,$C
	DC.B	$8C,$18,$87
	
a1p3	dc.b	$d0
	DC.B	$C0,$89,1,$E0,$8A,$E,$E,$E
	DC.B	$8C,$1A,$E1,$8B,$89,7,$8D,0
	DC.B	$E0,$8A,$E,$8C,$1A,$89,1,$E0
	DC.B	$8A,$E,$E,$E,$8C,$1A,$E1,$8B
	DC.B	$89,7,$8D,0,$E0,$8A,$E,$8C
	DC.B	$1A,$87
	
a1p4	DC.B	$D0,$C0,$89,1,$E0,$8A,$13,$13
	DC.B	$13,$8C,$1F,$E1,$8B,$89,7,$8D
	DC.B	0,$E0,$8A,$13,$8C,$1F,$89,1
	DC.B	$E0,$8A,$13,$13,$13,$8C,$1F,$E1
	DC.B	$8B,$89,7,$8D,0,$E0,$8A,$13
	DC.B	$8C,$1F,$87

a2p1	dc.b	$8a
	DC.B	$88,1,2,$82,$D1,$EF,$C1,$34
	DC.B	$C8,$30,$C2,$32,$C6,$2B,$C1,$34
	DC.B	$C8,$30,$FF,$C2,$32,$87
	
a3p1	DC.B	$8A,$88,2,4,$82,$D2,$C9,$E5
	DC.B	$28,$2A,$E3,$2B,$E5,$24,$2D,$E3
	DC.B	$2B,$E5,$2A,$2B,$E3,$2D,$E5,$2F
	DC.B	$2B,$E3,$2A,$E5,$28,$2A,$E3,$2B
	DC.B	$E5,$24,$23,$E3,$24,$ED,$26,$E0
	DC.B	$2D,$2A,$E0,$1A,$1E,$21,$26,$1E
	DC.B	$21,$26,$2A,$21,$26,$2A,$2D,$26
	DC.B	$2A,$2D,$32,$E5,$34,$36,$E3,$37
	DC.B	$E5,$30,$39,$E3,$37,$E5,$36,$37
	DC.B	$E3,$39,$E5,$3B,$37,$E3,$36,$E5
	DC.B	$34,$36,$E3,$37,$E5,$30,$2F,$E3
	DC.B	$30,$ED,$32,$E0,$39,$36,$E0,$26
	DC.B	$2A,$2D,$32,$2A,$2D,$32,$36,$2D
	DC.B	$32,$36,$39,$32,$36,$39,$3E,$87

a3p2	DC.B	$8A,$88,1,2,$82,$D3,$CE,$E5
	DC.B	$2B,$2B,$E3,$28,$E5,$2B,$28,$E3
	DC.B	$26,$E5,$2B,$E1,$2B,$2B,$E3,$2A
	DC.B	$2B,$ED,$2F,$E1,$2F,$2F,$E3,$2F
	DC.B	$2F,$E1,$2F,$2F,$2D,$E3,$2F,$E5
	DC.B	$2B,$E3,$2B,$E5,$2D,$E1,$2D,$32
	DC.B	$E3,$32,$F1,$36,$E5,$37,$34,$E3
	DC.B	$37,$D0,$E0,$34,$28,$1C,$34,$28
	DC.B	$1C,$34,$28,$1C,$34,$28,$1C,$D3
	DC.B	$E3,$37,$36,$E1,$36,$E3,$37,$E5
	DC.B	$39,$D0,$E0,$3B,$2F,$23,$3B,$2F
	DC.B	$23,$3B,$2F,$23,$3B,$2F,$23,$3B
	DC.B	$2F,$23,$3B,$D3,$E5,$2F,$E9,$2D
	DC.B	$E3,$2F,$E1,$2D,$E3,$2F,$E5,$2D
	DC.B	$E5,$2F,$E9,$2D,$E3,$2F,$E1,$2D
	DC.B	$E3,$2F,$E5,$2D,$87
	
a3p3	dc.b	$c0
	DC.B	$D0,$8C,$E0,$1C,$1C,$1C,$1C,$E1
	DC.B	$1C,$E0,$1C,$1C,$1C,$1C,$1C,$1C
	DC.B	$1C,$1C,$28,$34,$E0,$18,$18,$18
	DC.B	$18,$E1,$18,$E0,$18,$18,$18,$18
	DC.B	$18,$18,$18,$18,$24,$30,$E0,$1A
	DC.B	$1A,$1A,$1A,$E1,$1A,$E0,$1A,$1A
	DC.B	$1A,$1A,$1A,$1A,$1A,$1A,$26,$32
	DC.B	$E0,$1F,$1F,$1F,$1F,$E1,$1F,$E0
	DC.B	$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
	DC.B	$2B,$37,$E0,$1C,$1C,$1C,$1C,$E1
	DC.B	$1C,$E0,$1C,$1C,$1C,$1C,$1C,$1C
	DC.B	$1C,$1C,$28,$34,$E0,$18,$18,$18
	DC.B	$18,$E1,$18,$E0,$18,$18,$18,$18
	DC.B	$18,$18,$18,$18,$24,$30,$E0,$1A
	DC.B	$1A,$1A,$1A,$E1,$1A,$E0,$1A,$1A
	DC.B	$1A,$1A,$1A,$1A,$1A,$1A,$26,$32
	DC.B	$E0,$1A,$1A,$1A,$1A,$E1,$1A,$E0
	DC.B	$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	DC.B	$26,$32,$87,0

fret	RTS

effects	TST.B	fonoff
	BEQ	fret
	RTS
	
ZZZZ	*

***********************
* End of Music Module *
***********************

	even

in_set	incbin	"blocky8.tfb"	;8x8 Char Set ( 640 bytes )
	
	even
	
set_0	ds.b 60*2*8	;Storage for the
set_1	ds.b 60*2*8	;Character sets
set_2	ds.b 60*2*8
set_3	ds.b 60*2*8
set_4	ds.b 60*2*8
set_5	ds.b 60*2*8
set_6	ds.b 60*2*8
set_7	ds.b 60*2*8

	
	ds.b 8*$a0	;Blank area
data	ds.b 32000	;Diagonal Scroll workspace

	;
	;Table of addresses used to print characters
	;onto work area - Used for speed.
	;
	
top         set	data
data_bottom equ	data+159*$a0

bottom	set data_bottom

Table_0	dc.l bottom+-1*(8*$a0)+0*8+0
	dc.l top+00*(8*$a0)+0*8+1
	dc.l top+01*(8*$a0)+1*8+0
	dc.l top+02*(8*$a0)+1*8+1
	dc.l top+03*(8*$a0)+2*8+0
	dc.l top+04*(8*$a0)+2*8+1
	dc.l top+05*(8*$a0)+3*8+0
	dc.l top+06*(8*$a0)+3*8+1
	dc.l top+07*(8*$a0)+4*8+0
	dc.l top+08*(8*$a0)+4*8+1
	dc.l top+09*(8*$a0)+5*8+0
	dc.l top+10*(8*$a0)+5*8+1
	dc.l top+11*(8*$a0)+6*8+0
	dc.l top+12*(8*$a0)+6*8+1
	dc.l top+13*(8*$a0)+7*8+0
	dc.l top+14*(8*$a0)+7*8+1
	dc.l top+15*(8*$a0)+8*8+0
	dc.l top+16*(8*$a0)+8*8+1
	dc.l top+17*(8*$a0)+9*8+0
	dc.l top+18*(8*$a0)+9*8+1
	dc.l top+19*(8*$a0)+10*8+0
	dc.l top+00*(8*$a0)+10*8+1
	dc.l top+01*(8*$a0)+11*8+0
	dc.l top+02*(8*$a0)+11*8+1
	dc.l top+03*(8*$a0)+12*8+0
	dc.l top+04*(8*$a0)+12*8+1
	dc.l top+05*(8*$a0)+13*8+0
	dc.l top+06*(8*$a0)+13*8+1
	dc.l top+07*(8*$a0)+14*8+0
	dc.l top+08*(8*$a0)+14*8+1
	dc.l top+09*(8*$a0)+15*8+0
	dc.l top+10*(8*$a0)+15*8+1
	dc.l top+11*(8*$a0)+16*8+0
	dc.l top+12*(8*$a0)+16*8+1
	dc.l top+13*(8*$a0)+17*8+0
	dc.l top+14*(8*$a0)+17*8+1
	dc.l top+15*(8*$a0)+18*8+0
	dc.l top+16*(8*$a0)+18*8+1
	dc.l top+17*(8*$a0)+19*8+0
	dc.l top+18*(8*$a0)+19*8+1


bottom	set $a0+bottom
top	set top-$a0

Table_1	dc.l bottom+-1*(8*$a0)+0*8+0
	dc.l top+00*(8*$a0)+0*8+1
	dc.l top+01*(8*$a0)+1*8+0
	dc.l top+02*(8*$a0)+1*8+1
	dc.l top+03*(8*$a0)+2*8+0
	dc.l top+04*(8*$a0)+2*8+1
	dc.l top+05*(8*$a0)+3*8+0
	dc.l top+06*(8*$a0)+3*8+1
	dc.l top+07*(8*$a0)+4*8+0
	dc.l top+08*(8*$a0)+4*8+1
	dc.l top+09*(8*$a0)+5*8+0
	dc.l top+10*(8*$a0)+5*8+1
	dc.l top+11*(8*$a0)+6*8+0
	dc.l top+12*(8*$a0)+6*8+1
	dc.l top+13*(8*$a0)+7*8+0
	dc.l top+14*(8*$a0)+7*8+1
	dc.l top+15*(8*$a0)+8*8+0
	dc.l top+16*(8*$a0)+8*8+1
	dc.l top+17*(8*$a0)+9*8+0
	dc.l top+18*(8*$a0)+9*8+1
	dc.l top+19*(8*$a0)+10*8+0
	dc.l top+00*(8*$a0)+10*8+1
	dc.l top+01*(8*$a0)+11*8+0
	dc.l top+02*(8*$a0)+11*8+1
	dc.l top+03*(8*$a0)+12*8+0
	dc.l top+04*(8*$a0)+12*8+1
	dc.l top+05*(8*$a0)+13*8+0
	dc.l top+06*(8*$a0)+13*8+1
	dc.l top+07*(8*$a0)+14*8+0
	dc.l top+08*(8*$a0)+14*8+1
	dc.l top+09*(8*$a0)+15*8+0
	dc.l top+10*(8*$a0)+15*8+1
	dc.l top+11*(8*$a0)+16*8+0
	dc.l top+12*(8*$a0)+16*8+1
	dc.l top+13*(8*$a0)+17*8+0
	dc.l top+14*(8*$a0)+17*8+1
	dc.l top+15*(8*$a0)+18*8+0
	dc.l top+16*(8*$a0)+18*8+1
	dc.l top+17*(8*$a0)+19*8+0
	dc.l top+18*(8*$a0)+19*8+1

bottom	set $a0+bottom
top	set top-$a0

Table_2	dc.l bottom+-1*(8*$a0)+0*8+0
	dc.l top+00*(8*$a0)+0*8+1
	dc.l top+01*(8*$a0)+1*8+0
	dc.l top+02*(8*$a0)+1*8+1
	dc.l top+03*(8*$a0)+2*8+0
	dc.l top+04*(8*$a0)+2*8+1
	dc.l top+05*(8*$a0)+3*8+0
	dc.l top+06*(8*$a0)+3*8+1
	dc.l top+07*(8*$a0)+4*8+0
	dc.l top+08*(8*$a0)+4*8+1
	dc.l top+09*(8*$a0)+5*8+0
	dc.l top+10*(8*$a0)+5*8+1
	dc.l top+11*(8*$a0)+6*8+0
	dc.l top+12*(8*$a0)+6*8+1
	dc.l top+13*(8*$a0)+7*8+0
	dc.l top+14*(8*$a0)+7*8+1
	dc.l top+15*(8*$a0)+8*8+0
	dc.l top+16*(8*$a0)+8*8+1
	dc.l top+17*(8*$a0)+9*8+0
	dc.l top+18*(8*$a0)+9*8+1
	dc.l top+19*(8*$a0)+10*8+0
	dc.l top+00*(8*$a0)+10*8+1
	dc.l top+01*(8*$a0)+11*8+0
	dc.l top+02*(8*$a0)+11*8+1
	dc.l top+03*(8*$a0)+12*8+0
	dc.l top+04*(8*$a0)+12*8+1
	dc.l top+05*(8*$a0)+13*8+0
	dc.l top+06*(8*$a0)+13*8+1
	dc.l top+07*(8*$a0)+14*8+0
	dc.l top+08*(8*$a0)+14*8+1
	dc.l top+09*(8*$a0)+15*8+0
	dc.l top+10*(8*$a0)+15*8+1
	dc.l top+11*(8*$a0)+16*8+0
	dc.l top+12*(8*$a0)+16*8+1
	dc.l top+13*(8*$a0)+17*8+0
	dc.l top+14*(8*$a0)+17*8+1
	dc.l top+15*(8*$a0)+18*8+0
	dc.l top+16*(8*$a0)+18*8+1
	dc.l top+17*(8*$a0)+19*8+0
	dc.l top+18*(8*$a0)+19*8+1

bottom	set $a0+bottom
top	set top-$a0

Table_3	dc.l bottom+-1*(8*$a0)+0*8+0
	dc.l top+00*(8*$a0)+0*8+1
	dc.l top+01*(8*$a0)+1*8+0
	dc.l top+02*(8*$a0)+1*8+1
	dc.l top+03*(8*$a0)+2*8+0
	dc.l top+04*(8*$a0)+2*8+1
	dc.l top+05*(8*$a0)+3*8+0
	dc.l top+06*(8*$a0)+3*8+1
	dc.l top+07*(8*$a0)+4*8+0
	dc.l top+08*(8*$a0)+4*8+1
	dc.l top+09*(8*$a0)+5*8+0
	dc.l top+10*(8*$a0)+5*8+1
	dc.l top+11*(8*$a0)+6*8+0
	dc.l top+12*(8*$a0)+6*8+1
	dc.l top+13*(8*$a0)+7*8+0
	dc.l top+14*(8*$a0)+7*8+1
	dc.l top+15*(8*$a0)+8*8+0
	dc.l top+16*(8*$a0)+8*8+1
	dc.l top+17*(8*$a0)+9*8+0
	dc.l top+18*(8*$a0)+9*8+1
	dc.l top+19*(8*$a0)+10*8+0
	dc.l top+00*(8*$a0)+10*8+1
	dc.l top+01*(8*$a0)+11*8+0
	dc.l top+02*(8*$a0)+11*8+1
	dc.l top+03*(8*$a0)+12*8+0
	dc.l top+04*(8*$a0)+12*8+1
	dc.l top+05*(8*$a0)+13*8+0
	dc.l top+06*(8*$a0)+13*8+1
	dc.l top+07*(8*$a0)+14*8+0
	dc.l top+08*(8*$a0)+14*8+1
	dc.l top+09*(8*$a0)+15*8+0
	dc.l top+10*(8*$a0)+15*8+1
	dc.l top+11*(8*$a0)+16*8+0
	dc.l top+12*(8*$a0)+16*8+1
	dc.l top+13*(8*$a0)+17*8+0
	dc.l top+14*(8*$a0)+17*8+1
	dc.l top+15*(8*$a0)+18*8+0
	dc.l top+16*(8*$a0)+18*8+1
	dc.l top+17*(8*$a0)+19*8+0
	dc.l top+18*(8*$a0)+19*8+1

bottom	set $a0+bottom
top	set top-$a0

Table_4	dc.l bottom+-1*(8*$a0)+0*8+0
	dc.l top+00*(8*$a0)+0*8+1
	dc.l top+01*(8*$a0)+1*8+0
	dc.l top+02*(8*$a0)+1*8+1
	dc.l top+03*(8*$a0)+2*8+0
	dc.l top+04*(8*$a0)+2*8+1
	dc.l top+05*(8*$a0)+3*8+0
	dc.l top+06*(8*$a0)+3*8+1
	dc.l top+07*(8*$a0)+4*8+0
	dc.l top+08*(8*$a0)+4*8+1
	dc.l top+09*(8*$a0)+5*8+0
	dc.l top+10*(8*$a0)+5*8+1
	dc.l top+11*(8*$a0)+6*8+0
	dc.l top+12*(8*$a0)+6*8+1
	dc.l top+13*(8*$a0)+7*8+0
	dc.l top+14*(8*$a0)+7*8+1
	dc.l top+15*(8*$a0)+8*8+0
	dc.l top+16*(8*$a0)+8*8+1
	dc.l top+17*(8*$a0)+9*8+0
	dc.l top+18*(8*$a0)+9*8+1
	dc.l top+19*(8*$a0)+10*8+0
	dc.l top+00*(8*$a0)+10*8+1
	dc.l top+01*(8*$a0)+11*8+0
	dc.l top+02*(8*$a0)+11*8+1
	dc.l top+03*(8*$a0)+12*8+0
	dc.l top+04*(8*$a0)+12*8+1
	dc.l top+05*(8*$a0)+13*8+0
	dc.l top+06*(8*$a0)+13*8+1
	dc.l top+07*(8*$a0)+14*8+0
	dc.l top+08*(8*$a0)+14*8+1
	dc.l top+09*(8*$a0)+15*8+0
	dc.l top+10*(8*$a0)+15*8+1
	dc.l top+11*(8*$a0)+16*8+0
	dc.l top+12*(8*$a0)+16*8+1
	dc.l top+13*(8*$a0)+17*8+0
	dc.l top+14*(8*$a0)+17*8+1
	dc.l top+15*(8*$a0)+18*8+0
	dc.l top+16*(8*$a0)+18*8+1
	dc.l top+17*(8*$a0)+19*8+0
	dc.l top+18*(8*$a0)+19*8+1
	
bottom	set $a0+bottom
top	set top-$a0
	
Table_5	dc.l bottom+-1*(8*$a0)+0*8+0
	dc.l top+00*(8*$a0)+0*8+1
	dc.l top+01*(8*$a0)+1*8+0
	dc.l top+02*(8*$a0)+1*8+1
	dc.l top+03*(8*$a0)+2*8+0
	dc.l top+04*(8*$a0)+2*8+1
	dc.l top+05*(8*$a0)+3*8+0
	dc.l top+06*(8*$a0)+3*8+1
	dc.l top+07*(8*$a0)+4*8+0
	dc.l top+08*(8*$a0)+4*8+1
	dc.l top+09*(8*$a0)+5*8+0
	dc.l top+10*(8*$a0)+5*8+1
	dc.l top+11*(8*$a0)+6*8+0
	dc.l top+12*(8*$a0)+6*8+1
	dc.l top+13*(8*$a0)+7*8+0
	dc.l top+14*(8*$a0)+7*8+1
	dc.l top+15*(8*$a0)+8*8+0
	dc.l top+16*(8*$a0)+8*8+1
	dc.l top+17*(8*$a0)+9*8+0
	dc.l top+18*(8*$a0)+9*8+1
	dc.l top+19*(8*$a0)+10*8+0
	dc.l top+00*(8*$a0)+10*8+1
	dc.l top+01*(8*$a0)+11*8+0
	dc.l top+02*(8*$a0)+11*8+1
	dc.l top+03*(8*$a0)+12*8+0
	dc.l top+04*(8*$a0)+12*8+1
	dc.l top+05*(8*$a0)+13*8+0
	dc.l top+06*(8*$a0)+13*8+1
	dc.l top+07*(8*$a0)+14*8+0
	dc.l top+08*(8*$a0)+14*8+1
	dc.l top+09*(8*$a0)+15*8+0
	dc.l top+10*(8*$a0)+15*8+1
	dc.l top+11*(8*$a0)+16*8+0
	dc.l top+12*(8*$a0)+16*8+1
	dc.l top+13*(8*$a0)+17*8+0
	dc.l top+14*(8*$a0)+17*8+1
	dc.l top+15*(8*$a0)+18*8+0
	dc.l top+16*(8*$a0)+18*8+1
	dc.l top+17*(8*$a0)+19*8+0
	dc.l top+18*(8*$a0)+19*8+1
	
bottom	set $a0+bottom
top	set top-$a0
	
Table_6	dc.l bottom+-1*(8*$a0)+0*8+0
	dc.l top+00*(8*$a0)+0*8+1
	dc.l top+01*(8*$a0)+1*8+0
	dc.l top+02*(8*$a0)+1*8+1
	dc.l top+03*(8*$a0)+2*8+0
	dc.l top+04*(8*$a0)+2*8+1
	dc.l top+05*(8*$a0)+3*8+0
	dc.l top+06*(8*$a0)+3*8+1
	dc.l top+07*(8*$a0)+4*8+0
	dc.l top+08*(8*$a0)+4*8+1
	dc.l top+09*(8*$a0)+5*8+0
	dc.l top+10*(8*$a0)+5*8+1
	dc.l top+11*(8*$a0)+6*8+0
	dc.l top+12*(8*$a0)+6*8+1
	dc.l top+13*(8*$a0)+7*8+0
	dc.l top+14*(8*$a0)+7*8+1
	dc.l top+15*(8*$a0)+8*8+0
	dc.l top+16*(8*$a0)+8*8+1
	dc.l top+17*(8*$a0)+9*8+0
	dc.l top+18*(8*$a0)+9*8+1
	dc.l top+19*(8*$a0)+10*8+0
	dc.l top+00*(8*$a0)+10*8+1
	dc.l top+01*(8*$a0)+11*8+0
	dc.l top+02*(8*$a0)+11*8+1
	dc.l top+03*(8*$a0)+12*8+0
	dc.l top+04*(8*$a0)+12*8+1
	dc.l top+05*(8*$a0)+13*8+0
	dc.l top+06*(8*$a0)+13*8+1
	dc.l top+07*(8*$a0)+14*8+0
	dc.l top+08*(8*$a0)+14*8+1
	dc.l top+09*(8*$a0)+15*8+0
	dc.l top+10*(8*$a0)+15*8+1
	dc.l top+11*(8*$a0)+16*8+0
	dc.l top+12*(8*$a0)+16*8+1
	dc.l top+13*(8*$a0)+17*8+0
	dc.l top+14*(8*$a0)+17*8+1
	dc.l top+15*(8*$a0)+18*8+0
	dc.l top+16*(8*$a0)+18*8+1
	dc.l top+17*(8*$a0)+19*8+0
	dc.l top+18*(8*$a0)+19*8+1
	
bottom	set $a0+bottom
top	set top-$a0
	
Table_7	dc.l bottom+-1*(8*$a0)+0*8+0
	dc.l top+00*(8*$a0)+0*8+1
	dc.l top+01*(8*$a0)+1*8+0
	dc.l top+02*(8*$a0)+1*8+1
	dc.l top+03*(8*$a0)+2*8+0
	dc.l top+04*(8*$a0)+2*8+1
	dc.l top+05*(8*$a0)+3*8+0
	dc.l top+06*(8*$a0)+3*8+1
	dc.l top+07*(8*$a0)+4*8+0
	dc.l top+08*(8*$a0)+4*8+1
	dc.l top+09*(8*$a0)+5*8+0
	dc.l top+10*(8*$a0)+5*8+1
	dc.l top+11*(8*$a0)+6*8+0
	dc.l top+12*(8*$a0)+6*8+1
	dc.l top+13*(8*$a0)+7*8+0
	dc.l top+14*(8*$a0)+7*8+1
	dc.l top+15*(8*$a0)+8*8+0
	dc.l top+16*(8*$a0)+8*8+1
	dc.l top+17*(8*$a0)+9*8+0
	dc.l top+18*(8*$a0)+9*8+1
	dc.l top+19*(8*$a0)+10*8+0
	dc.l top+00*(8*$a0)+10*8+1
	dc.l top+01*(8*$a0)+11*8+0
	dc.l top+02*(8*$a0)+11*8+1
	dc.l top+03*(8*$a0)+12*8+0
	dc.l top+04*(8*$a0)+12*8+1
	dc.l top+05*(8*$a0)+13*8+0
	dc.l top+06*(8*$a0)+13*8+1
	dc.l top+07*(8*$a0)+14*8+0
	dc.l top+08*(8*$a0)+14*8+1
	dc.l top+09*(8*$a0)+15*8+0
	dc.l top+10*(8*$a0)+15*8+1
	dc.l top+11*(8*$a0)+16*8+0
	dc.l top+12*(8*$a0)+16*8+1
	dc.l top+13*(8*$a0)+17*8+0
	dc.l top+14*(8*$a0)+17*8+1
	dc.l top+15*(8*$a0)+18*8+0
	dc.l top+16*(8*$a0)+18*8+1
	dc.l top+17*(8*$a0)+19*8+0
	dc.l top+18*(8*$a0)+19*8+1
	
; The Scrolly message
; Ends at label : scroll_end

scrolltext dc.b "                                      "
	DC.B "             "
	dc.b " THE FINGERBOBS PRESENT......   THE ST CORKSCREW SCROLLER "
	DC.B "        CODED BY OBERJE ( ME! ).         INSPIRED BY THE CORKSCREW SCROLLER"
	DC.B " IN THE VORTEX 42 MEGADEMO 2 ON THE AMIGA!             PERSONAL GREETS TO"
	DC.B "       THE CAPED CRUSADER,       GRAHAME,       MATTHEW,        MARTIN,       ROZEL,       TIM,       ALAN,       HAXTON,      GORDON,"
	DC.B "     JOE 90,         BOOTS,      ETC ETC.......                     "
	DC.B " MEGA GREETS TO THE FOLLOWING GROUPS     TEX,        CAREBEARS,"
	DC.B "      ALL MEMBERS OF THE UNION,           "
	DC.B " THE LOST BOYS,           AND ALL OTHER MEGA DEMO WRITERS         "
	DC.B "          STOP PRESS    STOP PRESS    STOP PRESS      "
	DC.B "    THERE IS A 'CHEAT' MODE IN ST BASIC!       TO ENTER CHEAT"
	DC.B " MODE YOU MUST PRESS ALL FUNCTION KEYS ( F1 TO F10 ) WHEN"
	DC.B " THE 'LISTING' WINDOW IS ACTIVE. "
	DC.B "               THE CHEAT MODE OFFERS A SPEED INCREASE"
	DC.B " OF AROUND 65% AND GIVES A NEW MENU OPTION        > COMPILE !"
	DC.B "            THANX GO TO ROZEL FOR THAT INTERESTING TIP!      "
	DC.B "         AAAAAAAAAAARRRRRRRRRRRRRGGGGG!   "
	DC.B " JUST LIKE ALL OTHER DEMO SCREENS I HAVE CODED THIS ONE "
	DC.B " IS DEDICATED TO PATSY KENSIT. "
	DC.B "     COR BLIMEY.... DOESN'T SHE LOOK NICE IN LETHAL WEAPON 2 ? "
	DC.B "............ SHE CERTAINLY DOES!!!!              "
	DC.B "     WELL Y'KNOW SINCE I STARTED WRITING DEMOS I'VE HAD TO "
	DC.B " WRITE A LOT OF SCROLLTEXT!    AT FIRST I DIDN'T KNOW WHAT "
	DC.B " ON EARTH TO WRITE!       NOW HOWEVER , I REALISE YOU CAN "
	DC.B " WAFFLE WHATEVER YOU LIKE!!!!!!         FEW PEOPLE EVER READ "
	DC.B " PAST THE FIRST 5-6 KILOBYTES OF TEXT.   "
	DC.B "          TIPS FOR POTENTIAL SCROLLTEXT WRITERS       "
	DC.B "      1. GET DRUNK ( THIS IS PARTICULARLY EFFECTIVE AT LETTING "
	DC.B " YOUR LITERARY TALENT LOOSE! )         "
	DC.B "      2. GET SOMEONE ELSE TO WRITE IT! ( ANOTHER EXCELLENT SOLUTION "
	DC.B ", JUST SIT AT YOUR COMPUTER AND WAIT FOR YOUR DRUNK FRIENDS TO ARRIVE "
	DC.B " AND THEN LET THEM TYPE THE TEXT!!! )           "
	DC.B "      3. SPEAK BULL ( I.E AT BASIC CHEAT MODE!!!! )       "
	DC.B "      4. TRY NOT TO GET BORED HALF WAY THROUGH A SENTE.......ZZZZZZZZZ"
	DC.B "ZZZZZZZZZZZZZZZZZZZZZ OH OOPS        SORRY!          "
	DC.B "      5. DON'T FOLLOW ANYONES TIPS!!               "
	DC.B " WHO ARE THE FINGERBOBS ?             WELL THE FINGERBOBS ARE "
	DC.B "         OBERJE ( ME! ) , I DO JUST ABOUT ALL THE ST CODING/GRAPHIX/SOUND ETC "
	DC.B "        THE CREEPER , HE IS QUITE QUITE MAD, AND WRITES MOST OF THE "
	DC.B " AMIGA CODE, BUT DOES GRAPHICS AND SOUND TOO.          THE COUNT , "
	DC.B " DOES A BIT OF EVERYTHING.          ZEN , DOES SOME GRAPHIX AND SOUND"
	DC.B " ON AMIGA.               SHADES , DOES AMIGA MUSIC               "
	DC.B "            "
	DC.B "  OH WELL END OF SCROLLER, LETS JUST WATCH SOME DOTS BEFORE "
	DC.B "WE LOOP ................................."          
	DC.B ".........................................."
	dc.b "                                      "
scroll_end	DC.B 0
	
Table	ds.l	1	;Current Tables address
set	ds.l	1	;Current Sets address
count	ds.w	1	;Current pixel
scroll	ds.l	1	;Current position in scrolltext

table	dc.b	0,4,9,14,16	;Barrel Table of Offsets
	dc.b	18,20,22,23,24
	dc.b	25,26,27,28,29
	dc.b	30,31,32,33,34
	dc.b	35,36,37,38,39
	
	dc.b	40,41,42,43,44
	dc.b	45,46,47,48,49
	dc.b	50,51,52,53,54
	dc.b	55,56,57,59,61
	dc.b	63,65,68,73,79	

barcols	dc.w	$111,$222,$333,$444,$555,$666,$777
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$000
		
bar2		dc.w	$700,$710,$720,$730	Red -> Yellow
		dc.w	$740,$750,$760,$770
		dc.w	$671,$572,$473,$374	Yellow -> Cyan
		dc.w	$275,$176,$077
		dc.w	$067,$057,$047,$037	Cyan -> Blue
		dc.w	$027,$017,$007
		dc.w	$107,$207,$307,$407	Blue -> Purple
		dc.w	$507,$607,$707
		dc.w	$706,$705,$704,$703	Purple -> Red
		dc.w	$702,$701,$700
bar2_end	equ	*		
		dc.w	$700,$710,$720,$730	Red -> Yellow
		dc.w	$740,$750,$760,$770
		dc.w	$671,$572,$473,$374	Yellow -> Cyan
		dc.w	$275,$176,$077
		dc.w	$067,$057,$047,$037	Cyan -> Blue
		dc.w	$027,$017,$007
		dc.w	$107,$207,$307,$407	Blue -> Purple
		dc.w	$507,$607,$707
		dc.w	$706,$705,$704,$703	Purple -> Red
		dc.w	$702,$701,$700



	even
	
pic	incbin	"corkpic3.pi1"	;Picture
picture	equ	pic+34
cols	equ	pic+2
	
	section	bss

do_cols2	ds.l	1
do_cols3	ds.l	1
at2		ds.l	1
at3		ds.l	1

vector_store	ds.b	4	;Vector save area
		ds.l	3
old_physbase	ds.l	1	;
old_res		ds.w	1	;
old_palette	ds.w	16	;
old_stack	ds.l	1	;
		ds.l	100
ustack		ds.l	1	;My Stack!!!!!
		
lines	ds.w	1
at	ds.l	1
wait	ds.w	1
	
screen_1	ds.l	1	;Pointer to screen #1
screen_2	ds.l	1	;Pointer to screen #2
	
; The Screens

screen_area1	ds.b	1	
*screen_area1	ds.b	33000
*screen_area2	ds.b	33000
screen_area2	equ	screen_area1+33000


***********
* THE END *
***********

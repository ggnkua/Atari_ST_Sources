;
; Fingerbobs New Year Demo Source Code
; ------------------------------------
;
; From THE DEMO CLUB
;
; DO *NOT* COPY THIS, BUY IT FROM EITHER THE FINGERBOBS
; OR THE DEMO CLUB OR THE LOST BOYS PD LIBRARY!
;

*********************************************************
*							*
*             The Fingerbobs New Year Demo		*
*							*
*                    Version 1.7			*
*							*
*              (c)1989/90 The FingerBOBS		*
*							*
*                 Written by Oberje'			*
*							*
*                Released on 12/01/90			*
*		         and 23/01/90			*
*							*
*********************************************************
*
* NOTE:
* This source does NOT contain any of the music, as it
* was all hacked from games/Automation intros!
* If you want the music you will have to find some other way
* to get it!
* I don't think it is fair to the Musicians to make
* the music be freely available. If you disagree then tough
* 'cos this is my source and I'll do what I like!
*
* This demo will mean nothing if you do not have a reasonable
* understanding of 68000 assembly language.
*
* Many of the effects in this demo ( Most actually! ) rely
* on Bitplane tricks, so It would be advisable to read up
* on and understand, how the ST screen is organised.
*
* I tried ( as much as possible ) to write this demo, in
* a logical structured way, I am not sure I have succeeded!
*
* All of the demo screens are present in this listing, except
* for the loader, which can be found in the folder LOADER,
*
* ALTHOUGH I HAVE TRIED TO COMMENT THIS SOURCE TO A REASONABLE
* LEVEL THERE ARE CERTAIN THINGS I CANNOT EXPLAIN , AND SOME
* STUFF I CAN'T REMEMBER!
*
* Demo Stats:
* -----------
* This demo was developed mostly over my Xmas/New Year
* Holidays although many of the routines existed in
* semi-finished ( i.e Bugged ) forms previously
* ( I should have been doing research on AI, but y'know
* how it is.... )
*
* The following products were used during this demos 
* development.
*
*   Hisoft Devpac II
*   Degas Elite
*   Fast Basic ( For Sine Tables )
*   Russ Paynes Bytestomper v2.1
*   Mastersound sampler
*   ST Internals
*   The Concise Atari ST 68000 Programmers Reference Guide
*   VIDI-AMIGA Digitiser  - Amiga
*   James Dads Video camera!
*   Deluxe Paint III      - Amiga
*   DOS-2-DOS             - Amiga
*   Becks Bier
*   Peach Schapps
*   Smirnoff Vodka
*   Lots of Coffee
*   MUSIC - Propaganda  - The Secret Wish
*           Madonna     - Like a prayer
*           Duran Duran - Decade
*           Skin Games  - Blood Rush
*           Belinda Carlisle - Runaway Horses
*           Various assorted 12"s !!!
*   etc.............
*   ( I filled about 14 disks with stuff during the development of this! )
*
* Good luck!.............
*
* REMEMBER!
* You can contact the Fingerbobs by writing to
*
*  OBERJE'
*  6 CARRON TERRACE
*  STONEHAVEN
*  KINCARDINESHIRE
*  SCOTLAND
*  AB3 2HX
*
* or by leaving a message for the WIZOP of The Batcave BBS 
*
*  The Batcave
*  03586 89049
*  Most Speeds
*  Most times!
*   
*


nospr	equ	26	;Number of sprites 
plane	equ	0	;Scroller plane!
 
**********************
* 2 Bit scroll macro *
**********************
scr2	macro				;Macro for
	move.l	\1+(\2*2)(a0),d0	;Scroller routine
	move.w	\1+8+(\2*2)(a0),d0	;
	lsl.l	#2,d0			;
	swap	d0			;
	move.w	d0,\1+(\2*2)(a0)	;
	endm				;


***********************
* Nibble Scroll macro *
***********************
scr	macro
	move.l	\1+(plane*2)(a0),d0
	move.w	\1+8+(plane*2)(a0),d0
	lsl.l	#4,d0
	swap	d0
	move.w	d0,\1+(plane*2)(a0)
	endm

***************
* Nibble puts *
***************
nib1	macro
	move.b	plane*2(a0),d5
	andi.b	#$f,d5
	move.b	plane*2(a1),d6
	andi.b	#$f0,d6
	or.b	d5,d6
	move.b	d6,plane*2(a1)
	endm
		
nib2	macro
	move.b	plane*2(a0),d5
	lsr.b	#4,d5
	andi.b	#$f,d5
	move.b	plane*2(a1),d6
	andi.b	#$f0,d6
	or.b	d5,d6
	move.b	d6,plane*2(a1)
	endm
	

;MFP Register equates

iea	equ	$fffa07	;Interrupt Enable A
ieb	equ	$fffa09	;Interrupt Enable B
ipa	equ	$fffa0b	;Interrupt Pending A
ipb	equ	$fffa0d	;Interrupt Pending B
isa	equ	$fffa0f	;Interrupt In-service A
isb	equ	$fffa11	;Interrupt In-service B
ima	equ	$fffa13	;Interrupt Mask A
imb	equ	$fffa15	;Interrupt Mask B
vector	equ	$fffa17	;Vector Register
tacr	equ	$fffa19	;Timer A Control
tbcr	equ	$fffa1b	;Timer B Control
tadr	equ	$fffa1f	;Timer A Data
tbdr	equ	$fffa21	;Timer B Data


*********************************************************
*							*
*                  THE MAIN SCREEN                      *
*							*
*********************************************************

***************************
* Begin program Execution *
***************************

start	movea.l	a7,a5		;Keep old SP	
	lea	ustack,a7	;install our own stack
	movea.l	4(a5),a5	;Get Base Page address
	move.l	$c(a5),d0	;Find Text Section Size
	add.l	$14(a5),d0	;Add Data Section Size
	add.l	$1c(a5),d0	;Add BBS Section Size
	add.l	#$100,d0	;Add 256 bytes for Base Page
	move.l	d0,-(a7)	;
	move.l	a5,-(a7)	;Call Mshrink, give area
	move.w	d0,-(a7)	;d0 long back to GEMDOS
	move.w	#$4a,-(a7)	;
	trap	#1		;
	lea	$c(a7),a7	;
	move.w 	#$f,d0		;
p_pause	move.w 	#-1,d1		;Wait a bit.....
pauselp	dbra 	d1,pauselp	;To make sure drive stops spinning.
	dbra 	d0,p_pause	;
	dc.w	$a00a		;Hide Mouse
				
	move.l	#old_spr1,old_sprites
	move.l	#old_spr2,other	;Set Sprite save pointers
				
	move.l	#message,here	;Set up scroller
	move.b	#0,slice	;for main screen
				
	move.l	#bounce_tab1,curr_bounce
	move.l	#bar2,do_cols2	;Set up scroll bounce &
	move.w	#3,wait		;Colour Banding
	
	move.l	#scrolltext,crkscrl
	jsr	crk_restart	;Set up Corkscrew Scroller variables
	
	sf.b	stopped		;Scroller not stopped!
	
	jsr	super_on	;Enter Supervisor mode, set screens etc

	move.l	#$31415926,$426	;Reset Trap
	move.l	#codex,$42a
	
	move.w	#4,track	;Install music
	move.w	#4,playing	;Track 2
*	jsr	m6_init		;
*	move.l	#m6_int,mus_int	;Which is Renegade

	jsr	cut_table	;Create table for music screen
	jsr	make_sprites	;Create sprite data
	jsr	make_sets	;Generate Character Sets for corkscrew
	jsr	change_disp	;Initialise sprite variables
	jsr	do_sprites	;Set sprites
	jsr	screen_swap	;ready
	jsr	do_sprites	;to roll...
	jsr	screen_swap	;
	
	jsr	res_bounce	;Restart bounce
	move.l	scrollpos,a2	;
	jsr	display_scroll	;Restart Scroller

	move.l	#$31415926,$426	;Reset Trap
	move.l	#codex,$42a
	
	jsr	new_vectors	;Install our vectors
	jsr	main_loop	;Do whatever must be done	
	jsr	old_vectors	;Get back old vectors
	jsr	super_off	;Set user mode
	
	clr.w	-(a7)		;Pterm - Exit Program
	trap	#1
	
********************************
* The Demo Never Reaches Here! *
********************************
	
	
*****************************************
*                                       *
*  Demo Main Screen Interrupt Routines  *
*                                       *
*****************************************
	
***************************
* Main Screen VBL routine *
***************************
new_vbl	
	addq.w	#1,$466.w	;Bump the frame count
	clr.b   tbcr		;Timer B off
        move.b  #1,tbdr		;Wait 1 HBL
        move.b  #8,tbcr		;Timer B on
        move.w  #$0,$ff8240	;Border -> Black
        move.l  #killtop,$120	;First HBL address
        move.b  #0,$ffff820a.w 	;Set 60Hz
	move.l	#bar2,at2	;Set pointer for banding
	rte

	;Lower border must be killed at line 227!		

	;Kill the Top Border
killtop         
	move.b  #2,$ffff820a.w 	;Set 50Hz -> Top now gone!
        move.l  #hbl_2,$120	;
	clr.b	tbcr		;Timer B off
        move.b  #128,tbdr	;Wait until colour banding
        move.b  #8,tbcr		;Timer B on
        move.w	#24,nlines	;24 lines of colour
        bclr    #0,isa  	;end of interrupt
        rte			;
		

hbl_2	move.l	a0,-(a7)	;Do colours for scroller
	move.l	at2,a0		;Get pointer to colour table
	move.w	(a0),$ffff8242	;Colour 1 ( Scroller )
	adda.l	#2,a0		;
	move.l	a0,at2		;Advance colour table pointer
	subq.w	#1,nlines	;Decrement no of lines to do
	beq.s	end_hbl_2	;Last line ? Yes->
	move.b	#0,tbcr		;
	move.b	#3,tbdr		;Wait 3 lines
	move.b	#8,tbcr		;
	bclr.b	#0,isa		;Clear in-service bit
	move.l	(a7)+,a0
	rte
end_hbl_2	
        move.l  #killborder,$120	;Install border kill
	move.b	#0,tbcr		;Wait until line 227
	move.b	#227-128-72+3,tbdr	
	move.b	#8,tbcr
	bclr.b	#0,isa		;Clear in-service bit
	move.w	#$777,$ffff8242	;Colour 1 back to normal
	move.l	(a7)+,a0	;
        bsr	play
	rte			;
	
	
	;Kill the Lower Border
killborder
	clr.b   tbcr     	;Timer B off
        movem.l d0/a1,-(a7)	;Save regs
        move.w  #$fa21,a1	;Timer B Data Register
        move.b  #200,(a1)	;Make sure is enough lines!
        move.b  #8,tbcr		;Timer B on
        move.b  (a1),d0		;
time    cmp.b   (a1),d0		;Wait for Last Scanline
        beq     time		;
        clr.b   $ffff820a.w     ;Set 60 Hz
        moveq   #4,d0		;This Time delay is VERY exact
noploop nop			;Do NOT CHANGE
        dbra    d0,noploop	;
        move.b  #2,$ffff820a.w  ;Set 50 Hz
        movem.l (a7)+,d0/a1     ;Restore Regs
	clr.b   tbcr     	;Timer B off
        bclr    #0,isa  	;end of interrupt
        rte			;


*****************
* Null Routines *
*****************
; Used whilst between
; the various demo screens
;
null_vbl
        move.b  #2,$ffff820a.w  ;Set 50 Hz
	addq.w	#1,$466.w	;Bump the frame count
	clr.b   tbcr		;Timer B off
        move.l  #0,$ff8240	;Palette -> Black
        move.l	#0,$ff8244	;
        move.l	#0,$ff8248	;
        move.l	#0,$ff824c	;
        move.l	#0,$ff8250	;
        move.l	#0,$ff8254	;
        move.l	#0,$ff8258	;
        move.l	#0,$ff825c	;
	bsr	play		;Still play music
	rte			;
	
tween_vbl
        move.b  #2,$ffff820a.w  ;Set 50 Hz
	addq.w	#1,$466.w	;Bump the frame count
	clr.b   tbcr		;Timer B off
        move.l  #$00000777,$ff8240	
        move.l	#$07770777,$ff8244
        move.l	#$07770777,$ff8248
        move.l	#$07770777,$ff824c
        move.l	#$07770777,$ff8250
        move.l	#$07770777,$ff8254
        move.l	#$07770777,$ff8258
        move.l	#$07770777,$ff825c
	bsr	play		;Keep music going
	rte			;
	

*****************
* MUSIC ROUTINE *
*****************
; Calls current music routine
; and changes the drive light
; according to the volume of
; Channel C on the sound chip
;
; Drive light flash is created
; merely by selecting/deselecting
; the drive!
;
play	movem.l	d0-d7/a0-a6,-(a7)	;Save Regs
	move.b	#14,$ff8800		;
	ori.b	#%00000010,$ff8802	;Drive light off	
jump	jsr	no_int			;Call Music
	move.b	#$a,$ff8800		;
	move.b	$ff8800,d0		;Get Chan C Volume
	andi.b	#$f,d0			;
	cmpi.b	#$f,d0			;Is MAX ?
	bne	leave_light		;No ->
	move.b	#14,$ff8800		;
	andi.b	#%11111101,$ff8802	;Drive light on
leave_light
	movem.l	(a7)+,d0-d7/a0-a6	;Restore Regs
	rts				;Exit
	
mus_int	equ	jump+2	;Address of music interrupt

************
* No Music *
************
; Null Music Routine
;
no_int	rts

******************
* Keyboard patch *
******************
	
kybd	move.w	#$2300,sr	;Lower IPL to 3
goop	jmp	$80000		;Jump through old vector


********************************
* The Music Screen VBL routine *
********************************
;Alters colour banding
;Sets up HBL
;
mus_vbl	addq.w	#1,$466.w	;Bump the frame count
	move.w	#$77,$ffff8240.w
	move.l	#mus_hbl,$120.w	;Install HBL
	move.b	#0,$fffffa1b.w	;Turn Timer B off
	move.b	#1,$fffffa21.w	;1 line between HBLs
	move.b	#8,$fffffa1b.w	;Turn Timer B on
	move.l	do_cols,at3	;Letter colours
	subi.w	#1,wait
	tst.w	wait
	bne	end_vbl		
	move.w	#3,wait		;Only change cols every 4th frame
	addq.l	#2,do_cols
	cmpi.l	#end_cols,do_cols
	bne	end_vbl
	move.l	#letter_cols,do_cols
end_vbl	move.l	#sky_cols,at	;Colours for sky
	bsr	play		;Do music
	rte			;End of VBL

********************
* Music Screen HBL *
********************
;Colour banding, Bouncy Sprites
;And the VU Meter are all run from
;this interrupt 
;
mus_hbl	move.l	a0,-(a7)	;Save Reg
	move.l	at,a0		;Address of sky colour data
	move.w	(a0),$ffff8240	;Change border colour
	addq.l	#2,at		;Point to next sky colour
	move.l	at3,a0		;Letter colour data address
	move.w	(a0),$ffff8244	;Change appropriate colour
	addq.l	#2,at3		;Point to next letter colour
	move.l	(a7)+,a0	;Restore reg
	cmpi.l	#water,at	;All Bars displayed ?
	beq	hb2		;Yes -> safe to display letters
	move.b	#4,$fffffa21.w	;4 lines until next interrupt
	bclr.b	#0,$fffffa0f.w	;Clear in-service bit
	rte
hb2	movem.l	d0-d7/a0-a6,-(a7)
	move.w	#$777,$ffff8244	;Change Inside Letter colour to white
	bsr	delete_letters	;Remove old letters from screen
	bsr	display_letters	;Display new letters
	bsr	update_letters	;Calculate new position
	bsr	draw_meter	;Do VU Meter
	movem.l	(a7)+,d0-d7/a0-a6
	move.b	#0,$fffffa1b.w	;Turn HBLs off
	bclr.b	#0,$fffffa0f.w	
	rte


*****************************
* The CorkScrew VBL routine *
*****************************
;
crk_vbl	
	addq.w	#1,$466.w	;Bump the frame count
	move.w	#0,$ffff8240.w	;Set Border colour to black
	move.b	#0,$fffffa1b.w	;Turn Timer B off
	move.b	#103,$fffffa21.w	
	move.l	#barcols,at	;Bar colours
	move.w	#15,lines	;Lines in bar
	move.l	#crk_hbl,$120.w
	move.b	#8,$fffffa1b.w	;Turn Timer B on
	jsr	play
	sub.w	#1,wait
	tst.w	wait
	bne	gnome
	move.w	#3,wait
	add.l	#2,do_cols2
	cmpi.l	#bar2_end,do_cols2
	bne	gnome
	move.l	#bar2,do_cols2
gnome	rte

		
crk_hbl	move.l	a0,-(a7)	;Save Reg
	move.l	at,a0		;Get bar address
	move.w	(a0),$ffff8240	;Set Border to colour
	move.w	(a0),$ffff8244	;Set Back of scroll to this colour
	move.l	(a7)+,a0	;Restore reg
	addi.l	#2,at		;Point to next bar col
	subi.w	#1,lines	;Count down lines
	tst	lines
	beq	endcrkvbl		;Last line ?
	move.b	#0,$fffffa1b.w	;Turn Timer B off
	move.b	#1,$fffffa21.w	;1 line between crk_hbls
	move.b	#8,$fffffa1b.w
	bclr.b	#0,$fffffa0f.w	;Clear in-service bit
	rte
	
endcrkvbl 
	move.w	#$322,$ffff8244	;Restore back of scroll colour
	move.l	#crk_hbl_2,$120.w
	move.b	#1,$fffffa21.w	
	move.b	#8,$fffffa1b.w
	move.l	do_cols2,at2
	bclr.b	#0,$fffffa0f.w	;Clear in-service bit
	rte
	
crk_hbl_2	
	move.l	a0,-(a7)
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
	

***********************************
* Who Are Thes People? Screen VBL *
***********************************
;
who_vbl	addq.w	#1,$466.w	;Bump the frame count
	move.b	#0,$fffffa1b.w	;Turn Timer B off
	movem.l	d0-d7/a0-a6,-(a7)
	movem.l	p1pal,d0-d7	;Install correct palette
	movem.l	d0-d7,$ff8240
	bsr	p_scroll	;Call scroller
	jsr	play		;Call music
	movem.l	(a7)+,d0-d7/a0-a6
	rte			;End of VBL


**************************************
* The Extra Big Scroller VBL routine *
**************************************
;Kill borders!
;
big_vbl	
	addq.w	#1,$466.w	;Bump the frame count
	clr.b   tbcr		;Timer B off
        move.b  #1,tbdr		;Wait 1 HBL
        move.b  #8,tbcr		;Timer B on
        move.l  #bigtop,$120.w	;First HBL address
        move.b  #0,$ffff820a.w 	;Set 60Hz
        move.w  #$0,$ff8240	;Border -> Black

	move.l	do_cols2,at2
	move.b	#56,nlines
	
	sub.w	#1,wait
	tst.w	wait
	bne	harry
	move.w	#2,wait
	add.l	#2,do_cols2
	cmpi.l	#bar2_end,do_cols2
	bne	harry
	move.l	#bar2,do_cols2
harry
	rte

	;Lower border must be killed at line 227!		

bigtop         
	move.b  #2,$ffff820a.w 	;Set 50Hz -> Top now gone!
        move.l  #bands1,$120	;
	clr.b	tbcr		;Timer B off
        move.b  #4,tbdr		;Wait until colour banding
        move.b  #8,tbcr		;Timer B on
        bclr    #0,isa  	;end of interrupt
        rte			;
		
bands1	move.l	a0,-(a7)
	move.l	at2,a0
	move.w	(a0),$ff8242
	add.l	#2,at2
	move.l	(a7)+,a0
	sub.b	#1,nlines
	tst.b	nlines
	beq	end_bands1
        bclr    #0,isa  	;end of interrupt
	rte
end_bands1
	move.b	#0,tbcr
	move.b	#3,tbdr		;?
	move.b	#8,tbcr
	move.l	#killbig,$120.w	
        bclr    #0,isa  	;end of interrupt
	rte
		
killbig
	clr.b   tbcr     	;Timer B off
        movem.l d0/a1,-(a7)	;Save regs
	
	move.l	at2,a1
	move.w	(a1),$ff8242
	add.l	#2,at2
	
        move.w  #$fa21,a1	;Timer B Data Register
        move.b  #200,(a1)	;Make sure is enough lines!
        move.b  #8,tbcr		;Timer B on
        move.b  (a1),d0		;
timex   cmp.b   (a1),d0		;Wait for Last Scanline
        beq     timex		;
        clr.b   $ffff820a.w     ;Set 60 Hz
        moveq   #4,d0		;This Time delay is VERY exact
noplop  nop			;Do NOT CHANGE
        dbra    d0,noplop	;
        move.b  #2,$ffff820a.w  ;Set 50 Hz
        movem.l (a7)+,d0/a1     ;Restore Regs
	clr.b   tbcr     	;Timer B off
	move.b	#4,tbdr		;
	move.b	#8,tbcr		;
	move.b	#6,nlines	;
	move.l	#bands2,$120.w	;
        bclr    #0,isa  	;end of interrupt
        rte			;

	
bands2	move.l	a0,-(a7)
	move.l	at2,a0
	move.w	(a0),$ff8242
	add.l	#2,at2
	move.l	(a7)+,a0
	sub.b	#1,nlines
	tst.b	nlines
	beq	end_bands2
        bclr    #0,isa  	;end of interrupt
	rte
end_bands2
	move.b	#0,tbcr
        bclr    #0,isa  	;end of interrupt
	rte
	
	
**************
* Reset Trap *
**************
;
;Just hang
;
codex	bsr	hotblack	;Black
	move.b	#$2,$ffff820a
	move.b	#$8,$ff8800
	move.b	#$0,$ff8802	;PSG off
	move.b	#$9,$ff8800
	move.b	#$0,$ff8802
	move.b	#$a,$ff8800
	move.b	#$0,$ff8802
p_machinery
	bra	p_machinery
	

	even

**********************
*                    *
*  General Routines  *
*                    *
**********************

*********************************
* Print Out a message		*
* a0=text addr, a1=screen 	*
*********************************
;Prints a message to the screen
;using the 16x16 font
;
;This gives a screen size of 20x12 chars
;
printline
	moveq.l	#0,d0		;Clear
	move.b	(a0)+,d0	;Get Char
	cmpi.b	#0,d0		;End?
	beq	bog_off		;
	cmpi.b	#13,d0		;Newline?
	bne.s	checking1	;
	clr.l	d1		;Back to left hand side!
	bra.s	printline	;
checking1
	cmpi.b	#10,d0		;Linefeed?
	bne	wbk1		;
	add.l	#2560,a1	;Next line
	bra.s	printline	;
wbk1
	subi.b	#32,d0		;ASCII -> Char no.
sweet
	lea	sixteen,a2	;Base of char data
	lsl.l	#5,d0		;Offset ( 32 bytes per letter )
	adda.l	d0,a2		;a2=char data
	move.l	a1,a3		;Screen addr
	add.l	d1,a3		;Plus X offset
	move.w	#16-1,d3	;16 lines
printloop
	move.w	(a2),(a3)	;Copy character to bitplanes
	move.w	(a2),4(a3)
	move.w	(a2),6(a3)
	add.l	#2,a2		;Next line of char data
	add.l	#$a0,a3		;Next Screen line
	dbf	d3,printloop	;
	add.l	#8,d1		;Increase X offset 1 char
	bra	printline	;
bog_off
	rts			;
	

*****************
* Clear Screens *
*****************
;
hotclear
	clr.l	$24		;Trace vector demolish
	move.l	screen_2,a5	;
	move.l	screen_1,a6	;Clear screens
	move.w	#(50000/4)-1,d0	;to wipe out any
hotlp	move.l	#0,(a6)+	;garbage
	move.l	#0,(a5)+	;
	dbra	d0,hotlp	;
	rts


***************************************
* Copy Main Screen Picture to Screens *
***************************************
hotcopy
	lea	picture,a0	;Depack data onto
	move.l	screen_1,a1	;Screen1
	adda.l	#leave*$a0,a1
	bsr	undo_picture
	move.l	screen_1,a1
	adda.l	#leave*$a0,a1
	adda.l	#32000,a1
	lea	picture2,a0
	bsr	undo_picture
	
	move.l	screen_1,a0	;
	move.l	screen_2,a1	;
	adda.l	#leave*$a0,a0	;
	adda.l	#leave*$a0,a1	;
	move.w	#11000,d0	;
hotlp1	move.l	(a0)+,(a1)+	;
	dbra	d0,hotlp1	;
	
	rts			;


********************************************************* 
* Delay : Wait a few secs ( Used when changing screen )	*
*********************************************************
;
delay
	move.w	#40,d7	;Wait <1 sec
del	bsr	vbl	;
	dbf	d7,del	;
	rts		;


************************
* Set Palette to Black *
************************
;
hotblack
        move.l  #0,$ff8240	;Palette -> Black
        move.l	#0,$ff8244	
        move.l	#0,$ff8248	
        move.l	#0,$ff824c
        move.l	#0,$ff8250
        move.l	#0,$ff8254
        move.l	#0,$ff8258
        move.l	#0,$ff825c
desiado
	rts

	
**********************************
* Set Palette for credit screen  *
**********************************
;
hotcols
        move.l  #$00000777,$ff8240	;Palette -> Black
        move.l	#$07770777,$ff8244
        move.l	#$07770777,$ff8248
        move.l	#$07770777,$ff824c
        move.l	#$07770777,$ff8250
        move.l	#$07770777,$ff8254
        move.l	#$07770777,$ff8258	;Except col 15
        move.l	#$07770777,$ff825c
	rts

	
********************************************
* Display credits, wait 5 secs or keypress *
********************************************
* Enter, a0=addr of text
;
hotcredits
	bsr	hotblack	;Blank colours
	bsr	hotclear	;Clear Screens
	
	move.l	screen_1,a1	;
	clr.l	d1		;
	bsr	printline	;Print Credits/Instructions
	bsr	hotcols		;Text Colours
	move.w	#$2700,sr	;
	move.l	#tween_vbl,$70.w	
	move.w	#$2300,sr	;Install correct VBL
	bsr	vbl		;Wait

	move.w	#8,-(a7)	;Wait for a Keypress
	trap	#1		;
	addq.l	#2,a7		;
		
	bsr	hotblack	;Blank colours
	move.w	#$2700,sr	;
	move.l	#null_vbl,$70.w	;Blank VBL again
	move.w	#$2300,sr	;
	bsr	hotclear	;Clear Screens
	rts			;
	
	 
 
******************
*                *
*  HOUSEKEEPING  *
*                *
******************

leave	equ	10	;Unusable lines at top of screen

super_on
	clr.l	-(a7)		;Set to SUPERVISOR mode
	move.w	#$20,-(a7)	;
	trap	#1		;
	addq.l	#6,a7		;
	move.l	d0,old_stack	;Save old SP
	
	move.w	#2,-(a7)	;
	trap	#14		;
	addq.l	#2,a7		;
	move.l	d0,old_physbase	;Find and save physbase

	move.w	#4,-(a7)	;
	trap	#14		;
	addq.l	#2,a7		;
	move.w	d0,old_res	;Find and save resolution

	move.l	#screen_area1,d0
	addi.l	#512,d0		;
	andi.l	#$ffffff00,d0	;
	move.l	d0,screen_1	;Set pointer to screen 1
	
	move.l	#screen_area2,d0
	addi.l	#512,d0		;
	andi.w	#$ffffff00,d0	;
	move.l	d0,screen_2	;Set pointer to screen 2
	
	clr.w	-(a7)		;
	move.l	screen_1,-(a7)	;
	move.l	screen_2,-(a7)	;
	move.w	#5,-(a7)	;Change to Low resolution
	trap	#14		;and screen to correct
	lea	$c(a7),a7	;address
		
	lea	$ff8240,a0	;Copy current
	lea	old_palette,a1	;hardware palette
	move.w	#7,d0		;and install
col_lp1	move.l	(a0),(a1)+	;a black palette
	move.l	#0,(a0)+	;
	dbra	d0,col_lp1	;

	jsr	hotclear	;Clear both screens
	
	jsr	hotcopy		;Copy picture to both screens

	lea	$ff8240,a0	;
	lea	new_palette,a2  ;
	move.w	#7,d0		;Install
col_lpw	move.l	(a2)+,(a0)+	;main screen colours
	dbra	d0,col_lpw	;

	pea	m_off		;Mouse off
	move.w	#1,-(a7)	;
	move.w	#$19,-(a7)	;
	trap	#14		;
	addq.l	#8,a7		;
			
	move.l	#$31415926,$426	;Reset Trap
	move.l	#codex,$42a
	
	rts			;Exit routine
	
	
	
super_off
	move.l	old_physbase,d0	;Return screen to
	move.w	old_res,-(a7)	;old resolution
	move.l	d0,-(a7)	;and address
	move.l	d0,-(a7)	;
	move.w	#5,-(a7)	;
	trap	#14		;
	lea	$c(a7),a7	;
	
	lea	$ff8240,a1	;Copy 
	lea	old_palette,a0	;old palette
	move.w	#7,d0		;to hardware
col_lp2	move.l	(a0)+,(a1)+	;palette
	dbra	d0,col_lp2	;
	
	pea	m_on		;Mouse on
	move.w	#0,-(a7)	;
	move.w	#$19,-(a7)	;
	trap	#14		;
	addq.l	#8,a7		;
	
	move.l	old_stack,-(a7)	;Get back to USER mode
	move.w	#$20,-(a7)	;with old stack
	trap	#1		;
	addq.l	#6,a7		;

	rts			;
	
	
 
new_vectors	
	move	sr,-(a7)	;Save SR
	ori.w	#$700,sr	;Raise IPL to 7
	lea	vector_store,a0	;Save old MFP values here...
	move.b	ieb,(a0)+	;MFP Enable B
	move.b	iea,(a0)+	;MFP Enable A
	move.b	ima,(a0)+	;MFP I-mask A
	adda.l	#1,a0		;
	move.l	$118.w,(a0)+	;Keybd
	move.l	$120.w,(a0)+	;HBL   - Timer B
	move.l	$70.w,(a0)+	;Vblank
	move.l	$118.w,goop+2	;Revector 		
	move.l	#kybd,$118.w	;keyboard routine
	andi.b	#$fe,iea	;Enable A - Timer B off
	andi.b	#$df,ieb	;Enable B - Timer C off
	move.l	#killtop,$120.w	;Install HBL
	ori.b	#1,iea		;Enable A - Timer B on	
	ori.b	#1,ima		;I-Mask A - Timer B on
	move.l	#new_vbl,$70.w	;Install VBL
	move.w	(a7)+,sr	;Restore SR
	rts			;
	

old_vectors
	move	sr,-(a7)	;Save SR
	ori.w	#$700,sr	;Raise IPL to 7
	lea	vector_store,a0	;Get vectors from here
	move.b	(a0)+,ieb	;MFP Enable B
	move.b	(a0)+,iea	;MFP Enable A
	move.b	(a0)+,ima	;MFP I-Mask A
	adda.l	#1,a0		;
	move.l	(a0)+,$118.w	;Keyboard
	move.l	(a0)+,$120.w	;HBL
	move.l	(a0)+,$70.w	;Vblank
	move.w	(a7)+,sr	;
        move.b  #2,$ffff820a.w	;Make sure 50Hz 
	rts			;


*************************
*			*
* THE MAIN PROGRAM LOOP *
*			*
*************************
	
main_loop
	bsr	blank_out	;Delete old sprites
	bsr	do_sprites	;Draw new sprites
	bsr	screen_swap	;Swap screens

	bsr	display		;Update Scroll buffer
	move.l	oldpos,a2	;
	bsr	clear_scroll	;Delete old scroll
	move.l	scrollpos,a2	;
	bsr	display_scroll	;Show New Scroll
	tst.b	stopped		;Paused ?
	beq.s	running		;If not do scroll
	subq.b	#1,stopleft	;Dec wait var
	bne.s	obervb		;if still to wait do so
	sf	stopped		;Take pause off
running	bsr	check_char	;
	bsr	scroll		;Scroll the buffer
obervb	bsr	update_scroll	;Calculate Scroller Bounce

	move.w	#37,-(a7)	;Wait for Screen Switch
	trap	#14		;
	addq.l	#2,a7		;

	move.w	#$ff,-(a7)	;Check the Keyboard
	move.w	#6,-(a7)	;
	trap	#1		;
	addq.l	#4,a7		;
	
	tst.w	d0		;
	beq	main_loop	;No key then loop
	
	cmpi.b	#"m",d0		;M - Music
	bne	over1		;
	bsr	music_screen	;
	clr.l	d0		;
	bra.s	main_loop	;Round again
over1
	cmpi.b	#"w",d0		;W - Who are these people
	bne	over2		;
	jsr	person_screen	;
	clr.l	d0		;
	bra	main_loop	;
over2
	cmpi.b	#"c",d0		;C - Corkscrew
	bne	over3		;
	bsr	cork_screen	;
	clr.l	d0		;
	bra	main_loop	;
over3
	cmpi.b	#"e",d0		;E - Extra Big Scroller
	bne	main_loop	;
	bsr	big_screen	;
	clr.l	d0		;
	bra	main_loop	;
	
exit_lp	rts			;Leave main loop : Not Used


*********************************
*                               *
*  The SPRITE Service Routines  *
*                               *
*********************************	
;
;The sprite movement is determined by adding
;two sine waves together, each sine wave has
;a different amplitude and the frequencies can
;be varied. As can the separation along
;both waves between the sprites
;Although this sounds quite natural, some
;really wicked and un-natural looking waves can
;be defined in this way!
;
	
*****************
* Sprite MACROS *
*****************
;
;Takes a sprite and
;Places the sprite on screen at
;the correct X,Y position.
;
pon	macro			;Place sprite ON screen
 	clr.w	d0		;Zero regs
 	clr.w	d2		;
 	clr.w	d3		;
 	clr.w	d4		;
 	move.b	(a4),d0		;X offset
 	move.b	2(a4),d2	;Y offset
 	move.b	4(a4),d3	;X2 offset
 	move.b	6(a4),d4	;Y2 offset
 	add.w	#256,d3		;Make X2 and Y2
 	add.w	#256,d4		;Point to second table
 	addq.l	#8,a4		;Ready table for next sprite
 	move.b	(a6,d0.w),d0	;X coord
 	move.b	(a6,d2.w),d2	;Y coord
 	move.b	(a6,d3.w),d3	;X2 coord
 	move.b	(a6,d4.w),d4	;Y2 coord
 	add.b	d3,d0		;Final X coord
 	add.b	d4,d2		;Final Y coord

	lea	sprite_data,a0	;Base of Sprite data
	move.l	screen_2,a2	;Base os Screen data
	adda.l	#(leave+3)*$a0,a2	
				;Dont use top lines!
	move.w	d2,d3		\ This replaces mulu #$a0,d2
	lsl.w	#7,d2		| It may be faster,
	lsl.w	#5,d3		| I don't know....?
	add.w	d3,d2		/
	add.l	d2,a2		;address of y	
	
	addi.l	#40,d0		;Add X constant offset ( Center 'bobs')
	move.l	d0,d1		;X
	andi.l	#$f,d1		;0-15
	asl	#8,d1		;256 Bytes per sprite data
	add.l	d1,a0		;a0=sprite we want
	andi.b	#$f0,d0		;\ Equivalent to d0=d0/16
	asr.w	#1,d0		;/		 d0=d0*8
	add.l	d0,a2		;a2=screen address we want
		
	move.l	a0,a3		;Save a1
 	move.l	a2,(a5)+	;Save screen pos
	
	rept 	16		;16 Lines of Sprite Data
	move.l	(a3)+,d0	;Mask screen for sprite
	and.l	d0,4(a2)	;
	move.l	(a3)+,d0	;
	and.l	d0,12(a2)	;
	
	move.l	(a3)+,d0	;Put sprite on screen
	or.l	d0,4(a2)	;
	move.l	(a3)+,d0	;
	or.l	d0,12(a2)	;
	adda.l	#$a0,a2		;
	endr
	
 	endm
	
		 
blank	macro			;Blank out old sprites
	move.l	(a6)+,a4	;
	
cnt	set	4		;For some reason ( unexplained )
				;the REPT directive
	clr.l	cnt(a4)		;wouldn't work, so I had
	clr.l	cnt+8(a4)	;to type ALL this in!
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	clr.l	cnt(a4)
	clr.l	cnt+8(a4)
cnt	set	cnt+$a0
	
	endm

	
***************************
* The Main Sprite Routine *
***************************
;	
do_sprites
	clr.l	d0
 	lea	vertical,a6	;a6=base of sine table 1
 	move.w	Xinc,d0		;Get sprite wave
 	move.w	Yinc,d2		;variables
 	move.w	X2inc,d3	;
 	move.w	Y2inc,d4	;

	lea	x1,a0		;
	
cnt	set	0		;Update sprites
	rept	nospr		;All of 'em!
 	add.b	d0,cnt(a0)	;
 	add.b	d2,cnt+2(a0)	;
 	add.b	d3,cnt+4(a0)	;
 	add.b	d4,cnt+6(a0)	;
cnt	set	cnt+8		;
 	endr

 	move.l	old_sprites,a5	;Place all sprites on screen
	lea	x1,a4		;and save sprite positions for later
 	pon	1	;
 	pon	2	;
 	pon	3	;
 	pon	4	;
 	pon	6	;
 	pon	7	;
 	pon	8	;
 	pon	9	;
 	pon	10	;
 	pon	11	;
 	pon	12	;
 	pon	13	;
 	pon	14	;
 	pon	15	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	pon	16	;
 	
out 	rts		;Exit
 
 	
 	
;Remove Sprites from Screen
blank_out
	move.l	old_sprites,a6
	blank	16
	blank	16
	blank	16
	blank	16
	blank	16
	blank	16
	blank	16
	blank	16
	blank	16
	blank	16
	blank	16
	blank	15
	blank	14
	blank	13
	blank	12
	blank	11
	blank	10
	blank	9
	blank	8
	blank	7
	blank	6	
	blank	5	
	blank	4	
	blank	3
	blank	2
	blank	1
	
	rts
	
	
**********************************
* Change distance between 'BOBS' *
**********************************
; This routine recalculates
; The Table Pointers for each
; Sprite with The First Sprite
; Being used as a base value
;
change_disp
	lea	x1,a0		;Point to table pointers
	move.w	XDisp,d0	;Get displacement
	move.w	YDisp,d3	;
	move.b	(a0),d1		;Get Start X
	move.b	2(a0),d2	;Get Start Y
	
	rept	nospr		;26 Sprites
	move.b	d1,(a0)		;New X
	move.b	d2,2(a0)	;New Y
	add.b	d0,d1		;Calc Next X
	add.b	d3,d2		;Calc Next Y
	addq.l	#8,a0		;Next Pointers
	endr
	
	lea	x1,a0		;Point to table pointers
	move.w	X2Disp,d0	;Get displacement
	move.w	Y2Disp,d3	;
	move.b	4(a0),d1	;Get Start X
	move.b	6(a0),d2	;Get Start Y
	
arooga	rept	nospr		;32 Sprites
	move.b	d1,4(a0)	;New X
	move.b	d2,6(a0)	;New Y
	add.b	d0,d1		;Calc Next X
	add.b	d3,d2		;Calc Next Y
	addq.l	#8,a0		;Next Pointers
	endr
	rts
	
	
*****************************************
* Swap over Screens and Sprite pointers *
*****************************************
;
screen_swap
	move.w	#-1,-(a7)	;Display new screen
	move.l	screen_2,-(a7)	;
	move.l	screen_1,-(a7)	;
	move.w	#5,-(a7)	;
	trap	#14		;
	lea	$c(a7),a7	;
	
	move.l	screen_1,d0	;Swap screen pointers
	move.l	screen_2,screen_1
	move.l	d0,screen_2	;
	
	move.l	other,d0	;Swap sprite pointers
	move.l	old_sprites,other
	move.l	d0,old_sprites	;
	
	rts			;


***********************
*		      *
*  Main Screen Bouncy *
*  Scroller Routines  *
*		      *
***********************
;
;The scroller is scrolled in a buffer and
;copied to the screen each frame, at a position
;determined by the bounce tables
;
	
check_char	
	cmpi.b	#0,slice	;New char?
	bne	chk_xit		;Nope->
	addq.l	#1,here		;Get next char
chk_xit	rts			;Go
		
		
restart		
	move.l	#message,here	;Start of message
	move.b	#0,slice	;Zero slice
	bsr	display		;Show slice
	rts
		
		
scroll	lea	scroll_data,a0	;Buffer
	move.w	#16-1,d1	;16 lines
scloop	scr	$0
	scr	$8
	scr	$10
	scr	$18
	scr	$20
	scr	$28
	scr	$30
	scr	$38
	scr	$40
	scr	$48
	scr	$50
	scr	$58
	scr	$60
	scr	$68
	scr	$70
	scr	$78
	scr	$80
	scr	$88
	scr	$90
	scr	$98
	add.l	#$a0,a0
	dbra	d1,scloop
	rts
*
* Display : here = addr of char to print
* 	
display	lea	char_set,a0	;Base of Char Data	
	move.l	here,a1		;
	clr.l	d0		;
	move.b	(a1),d0		;Get Character
	cmpi.b	#0,d0		;Is End-of-text ?
	beq	restart		;
	cmp.b	#65,d0		;Is it alphabetic
	blt	symbols		;
	subi.b	#65,d0		;Turn from ASCII to char no.
trim	andi.l	#$ff,d0		;Mask off rubbish
	mulu.w	#(16*3),d0	;Get offset
	add.l	d0,a0		;a0=addr of chars pix data
	move.b	slice,d0	;
	andi.l	#%110,d0	;
	lsr.b	#1,d0		;Find which slice of the character
	adda.l	d0,a0		;is to be displayed
	btst	#0,slice	;
	beq	nibble2		;
nibble1	lea	put_data,a1	;
	move.w	#16-1,d0	;
nl1	nib1			;
	add.l	#$a0,a1		;
	addq.l	#$3,a0		;
	dbra	d0,nl1		;
nib_xit	addq.b	#1,slice	;
	cmpi.b	#6,slice	;
	beq	nib_xit2	;
	rts			;
nib_xit2
	move.b	#0,slice	;
	rts			;
nibble2	lea	put_data,a1	;
	move.w	#16-1,d0	;
nl2	nib2			;
	add.l	#$a0,a1		;
	addq.l	#$3,a0		;
	dbra	d0,nl2		;
	bra	nib_xit		;
symbols	cmpi.b	#13,d0		;
	beq	space		;
	cmpi.b	#" ",d0		;
	beq	space		;
	cmpi.b	#1,d0		;Next sprite wave
	beq	getsprwave	;
	cmpi.b	#21,d0		;Bounce #1
	beq	b1		;
	cmpi.b	#22,d0		;Bounce #2
	beq	b2		;
	cmpi.b	#23,d0		;Bounce #3
	beq	b3		;
	cmpi.b	#24,d0		;Bounce #4
	beq	b4		;
	cmpi.b	#25,d0		;Bounce #5
	beq	b5		;
	cmpi.b	#26,d0		;Bounce #6
	beq	b6		;
	cmpi.b	#9,d0		;Pause 1 sec
	beq	s1		;
	cmpi.b	#10,d0		;Pause 3 secs
	beq	s2		;
	cmpi.b	#"+",d0		;
	bgt	above		;
	subi.b	#32,d0		;
	addi.b	#26,d0		;
	bra	trim		;
space	move.b	#26,d0		;
	bra	trim		;
above	subi.b	#32,d0		;
	addi.b	#25,d0		;
	bra	trim
	
		
b1	move.l	#bounce_tab1,curr_bounce
	bra	except	
b2	move.l	#bounce_tab2,curr_bounce
	bra	except	
b3	move.l	#bounce_tab3,curr_bounce
	bra	except	
b4	move.l	#bounce_tab4,curr_bounce
	bra	except	
b5	move.l	#bounce_tab5,curr_bounce
	bra	except	
b6	move.l	#bounce_tab6,curr_bounce
	bra	except
s1	move.b	#50,stopleft	;( 1 second )
	st	stopped		;Pause
	bra	except		;
s2	move.b	#150,stopleft	;( 3 seconds )
	st	stopped		;Pause
	bra	except		;
res_wave
	move.l	#spr_wave_tab,spr_wave
;	
;Get the values for the next sprite wave in the list
;	
getsprwave	
	move.l	spr_wave,a0	;
	cmpi.w	#$ffff,(a0)	;
	beq.s	res_wave	;
	move.w	(a0)+,Xinc	;
	move.w	(a0)+,Yinc	;
	move.w	(a0)+,XDisp	;
	move.w	(a0)+,YDisp	;
	move.w	(a0)+,X2inc	;
	move.w	(a0)+,Y2inc	;
	move.w	(a0)+,X2Disp	;
	move.w	(a0)+,Y2Disp	;
	move.w	(a0)+,d0	;
	cmpi.w	#$ffff,d0	;If X coord is -1
	beq	noxy		;Then do not change
	move.b	d0,x1		;Bob coords, just
	move.w	(a0)+,d0	;its variables
	move.b	d0,y1		;
	move.w	(a0)+,d0	;
	move.b	d0,cx1		;
	move.w	(a0)+,d0	;
	move.b	d0,cy1		;
noxy	bsr	change_disp	;
	addi.l	#24,spr_wave	;
except	lea	char_set,a0	;
	addq.l	#1,here		;
	bra	space		;
	rts			;
	

* Bounce
;
;Get next scroller position from
;bounce list
;	
res_bounce
	move.l	curr_bounce,bounce_at
update_scroll
	move.l	bounce_at,a0	;
	clr.l	d0		;
	move.w	(a0)+,d0	;
	cmpi.w	#$ffff,d0	;
	beq	res_bounce	;
	move.l	screen_2,a1	;
	adda.l	#130*$a0,a1	;** Pos of scroll base!
	adda.l	d0,a1		;
	move.l	a1,scrollpos	;
	move.l	a0,bounce_at	;
	rts			;
	
* Routine to print scroll buffer
* to addr a2
display_scroll
	move.l	a2,oldpos	;
	lea	scroll_data,a0	;
	move.l	#16-1,d7	;16 lines
next_word1
	move.w	$0(a0),$0(a2)	;
	move.w	$8(a0),$8(a2)	;
	move.w	$10(a0),$10(a2)	;
	move.w	$18(a0),$18(a2)
	move.w	$20(a0),$20(a2)
	move.w	$28(a0),$28(a2)
	move.w	$30(a0),$30(a2)
	move.w	$38(a0),$38(a2)
	move.w	$40(a0),$40(a2)
	move.w	$48(a0),$48(a2)
	move.w	$50(a0),$50(a2)
	move.w	$58(a0),$58(a2)
	move.w	$60(a0),$60(a2)
	move.w	$68(a0),$68(a2)
	move.w	$70(a0),$70(a2)
	move.w	$78(a0),$78(a2)
	move.w	$80(a0),$80(a2)
	move.w	$88(a0),$88(a2)
	move.w	$90(a0),$90(a2)
	move.w	$98(a0),$98(a2)
	adda.l	#$a0,a2		;
	adda.l	#$a0,a0		;
	dbra	d7,next_word1	;
	rts			;

* Routine to clear screen of scroller data
* a2=screen address
clear_scroll
	move.l	#16-1,d7	;16 lines
next_word2
	clr.w	$0(a2)		;
	clr.w	$8(a2)		;
	clr.w	$10(a2)		;
	clr.w	$18(a2)
	clr.w	$20(a2)
	clr.w	$28(a2)
	clr.w	$30(a2)
	clr.w	$38(a2)
	clr.w	$40(a2)
	clr.w	$48(a2)
	clr.w	$50(a2)
	clr.w	$58(a2)
	clr.w	$60(a2)
	clr.w	$68(a2)
	clr.w	$70(a2)
	clr.w	$78(a2)
	clr.w	$80(a2)
	clr.w	$88(a2)
	clr.w	$90(a2)
	clr.w	$98(a2)
	adda.l	#$a0,a2		;
	dbra	d7,next_word2	;
	rts			;
		

*****************************************************************
*								*
*                     THE MUSIC SCREEN                          *
*								*
*****************************************************************
	
music_screen
        move.b  #2,$ffff820a.w  ;Set 50 Hz
	bsr	hotblack	;Blank colours
	move.w	#$2700,sr	;Put in duff interrupts
	move.l	#null_vbl,$70.w	;
	move.w	#$2300,sr	;
	jsr	vbl		;Wait a frame
	lea	music_credits,a0
	bsr	hotcredits	;Display credits
	
	move.w	#3,wait		;3 Frames before HBL scroll
	move.l	#letter_cols,do_cols
	bsr	display_letters	;Ensure display variables initialised

	lea	mus_picture+35*$a0,a0
	move.l	screen_1,a1	;
	adda.l	#125*$a0,a1	;
	move.w	#3400,d0	;
picloop				;
	move.l	(a0)+,(a1)+	;Copy some picture data to
	dbra	d0,picloop	;Screen e.g. "Instructions & VU Meter"

	bsr	delay		;*** WAIT ***

	move.w	#$2700,sr	;Put in music scrn interrupts
	move.l	#mus_vbl,$70.w	;
	move.l	#mus_hbl,$120.w ;
	move.w	#$2300,sr	;

	lea	$ff8240,a0	;Install new screens palette	
	lea	mus_palette,a2  ;
	move.w	#7,d0		;
col_lp4	move.l	(a2)+,(a0)+	;
	dbra	d0,col_lp4	;

	bsr	show_track	;Show Current track
	
*****************
* Music Handler *
*****************
;Acts on keyboard events,
;Screen bouncy sprites are
;run from the HBL routine!
;
readkey	move.w	#8,-(a7)	;Wait for a key
	trap	#1		;
	addq.l	#2,a7		;

	cmpi.b	#" ",d0		;" " : Exit screen
	beq	f10		;
	cmpi.b	#13,d0		;Enter : Change Tune
	beq	change_tune	;
	
	swap	d0		;Get Other Word
	
	cmpi.b	#$4b,d0		;"<-" : Track Down
	beq	track_down	;
	cmpi.b	#$4d,d0		;"->" : Track Up
	beq	track_up	;
	bra	readkey		;
	
top_track	equ	47+27

track_up
	addq.w	#1,track	;Increase Track no.
	cmpi.w	#top_track+1,track
	bne	back_to_loop
	move.w	#0,track
	bra	back_to_loop

track_down	
	subq.w	#1,track	;Decrease Track no.
	cmpi.w	#-1,track
	bne	back_to_loop
	move.w	#top_track,track
	bra	back_to_loop

	
back_to_loop
	bsr	show_track	;Display track no. & name.
	bra	readkey		;Back to loop....


change_tune
	move.w	track,d0	;Change
	move.w	d0,playing	;Track playing
	cmpi.w	#0,d0		;
	beq	cosmic1	
	cmpi.w	#1,d0
	beq	cosmic2
	cmpi.w	#2,d0
	beq	cosmic3
	cmpi.w	#3,d0
	beq	cosmic4
	cmpi.w	#4,d0
	beq	ren
	cmpi.w	#5,d0
	beq	heli1
	cmpi.w	#6,d0
	beq	heli2
	cmpi.w	#7,d0
	beq	heli3
	cmpi.w	#8,d0
	beq	heli4
	cmpi.w	#9,d0
	beq	heli5
	cmpi.w	#10,d0
	beq	cats
	cmpi.w	#11,d0
	beq	hawk
	cmpi.w	#12,d0
	beq	xen1
	cmpi.w	#13,d0
	beq	xen2
	cmpi.w	#14,d0
	beq	xen3
	cmpi.w	#15,d0
	beq	ramp1
	cmpi.w	#16,d0
	beq	ramp2
	cmpi.w	#17,d0
	beq	neck1
	cmpi.w	#18,d0
	beq	neck2
	cmpi.w	#19,d0
	beq	out1
	cmpi.w	#20,d0
	beq	out2
	cmpi.w	#21,d0
	beq	gold1
	cmpi.w	#22,d0
	beq	gold2
	cmpi.w	#23,d0
	beq	enduro1
	cmpi.w	#24,d0
	beq	enduro2
	cmpi.w	#25,d0
	beq	enduro3
	cmpi.w	#26,d0
	beq	retg
	cmpi.w	#27,d0
	beq	speed1
	cmpi.w	#28,d0
	beq	speed2
	cmpi.w	#29,d0
	beq	speed3
	cmpi.w	#30,d0
	beq	speed4
	cmpi.w	#31,d0
	beq	speed5
	cmpi.w	#32,d0
	beq	speed6
	cmpi.w	#33,d0
	beq	speed7
	cmpi.w	#34,d0
	beq	weird1
	cmpi.w	#35,d0
	beq	weird2
	cmpi.w	#36,d0
	beq	weird3
	cmpi.w	#37,d0
	beq	weird4
	cmpi.w	#38,d0
	beq	verm1
	cmpi.w	#39,d0
	beq	verm2
	cmpi.w	#40,d0
	beq	verm3
	cmpi.w	#41,d0
	beq	verm4
	cmpi.w	#42,d0
	beq	verm5
	cmpi.w	#43,d0
	beq	verm6
	cmpi.w	#44,d0
	beq	star1
	cmpi.w	#45,d0
	beq	star2
	cmpi.w	#46,d0
	beq	star3
	cmpi.w	#47,d0
	beq	star4
	cmpi.w	#48,d0
	beq	custo1
	cmpi.w	#49,d0
	beq	custo2
	cmpi.w	#50,d0
	beq	custo3
	cmpi.w	#51,d0
	beq	custo4
	cmpi.w	#52,d0
	beq	custo5
	cmpi.w	#53,d0
	beq	custo6
	cmpi.w	#54,d0
	beq	obli1
	cmpi.w	#55,d0
	beq	obli2
	cmpi.w	#56,d0
	beq	obli3
	cmpi.w	#57,d0
	beq	obli4
	cmpi.w	#58,d0
	beq	plat1
	cmpi.w	#59,d0
	beq	plat2
	cmpi.w	#60,d0
	beq	plat3
	cmpi.w	#61,d0
	beq	plat4
	cmpi.w	#62,d0
	beq	plat5
	cmpi.w	#63,d0
	beq	plat6
	cmpi.w	#64,d0
	beq	plat7
	cmpi.w	#65,d0
	beq	emp1
	cmpi.w	#66,d0
	beq	emp2
	cmpi.w	#67,d0
	beq	emp3
	cmpi.w	#68,d0
	beq	emp4
	cmpi.w	#69,d0
	beq	emp5
	cmpi.w	#70,d0
	beq	emp6
	cmpi.w	#71,d0
	beq	emp7
	cmpi.w	#72,d0
	beq	emp8
	cmpi.w	#73,d0
	beq	tune1
	cmpi.w	#74,d0
	beq	xen4
	
	
;The following routines stop the previous song
;playing, initialise the new tune and start it
;playing.
;
cosmic1	move.l	#no_int,mus_int
*	move.l	#0,d0
*	jsr	m4
*	move.l	#m4_int,mus_int
	bsr	show_track
	bra	readkey
	
cosmic2	move.l	#no_int,mus_int
*	move.l	#1,d0
*	jsr	m4
*	move.l	#m4_int,mus_int
	bsr	show_track	
	bra	readkey
	
cosmic3	move.l	#no_int,mus_int
*	move.l	#2,d0
*	jsr	m4
*	move.l	#m4_int,mus_int
	bsr	show_track	
	bra	readkey
	
cosmic4	move.l	#no_int,mus_int
*	move.l	#3,d0
*	jsr	m4
*	move.l	#m4_int,mus_int
	bsr	show_track	
	bra	readkey
	
ren	move.l	#no_int,mus_int
*	jsr	m6_init
*	move.l	#m6_int,mus_int
	bsr	show_track
	bra	readkey
	
heli1	move.l	#no_int,mus_int
*	move.l	#0,d0
*	jsr	m9
*	move.l	#m9_int,mus_int
	bsr	show_track
	bra	readkey
	
heli2	move.l	#no_int,mus_int
*	move.l	#1,d0
*	jsr	m9
*	move.l	#m9_int,mus_int
	bsr	show_track
	bra	readkey
	
heli3	move.l	#no_int,mus_int
*	move.l	#2,d0
*	jsr	m9
*	move.l	#m9_int,mus_int
	bsr	show_track
	bra	readkey
	
heli4	move.l	#no_int,mus_int
*	move.l	#3,d0
*	jsr	m9
*	move.l	#m9_int,mus_int
	bsr	show_track
	bra	readkey
	
heli5	move.l	#no_int,mus_int
*	move.l	#4,d0
*	jsr	m9
*	move.l	#m9_int,mus_int
	bsr	show_track
	bra	readkey
	
cats	move.l	#no_int,mus_int
*	jsr	mx+$0
*	move.l	#mx+$64,mus_int
	bsr	show_track
	bra	readkey
	
hawk	move.l	#no_int,mus_int
*	jsr	mx+$17be
*	move.l	#mx+$181e,mus_int
	bsr	show_track
	bra	readkey
	
thrust	move.l	#no_int,mus_int
*	jsr	mx+$2b9c
*	move.l	#mx+$2bfc,mus_int
	bsr	show_track
	bra	readkey

xen1	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	mx+$3e3c
*	move.l	#mx+$3f4e,mus_int
	bsr	show_track
	bra	readkey

xen2	move.l	#no_int,mus_int
*	move.w	#1,d0
*	jsr	mx+$3e3c
*	move.l	#mx+$3f4e,mus_int
	bsr	show_track
	bra	readkey

xen3	move.l	#no_int,mus_int
*	move.w	#2,d0
*	jsr	mx+$3e3c
*	move.l	#mx+$3f4e,mus_int
	bsr	show_track
	bra	readkey

ramp1	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	mx+$4d3c
*	move.l	#mx+$4e42,mus_int
	bsr	show_track
	bra	readkey

ramp2	move.l	#no_int,mus_int
*	move.w	#1,d0
*	jsr	mx+$4d3c
*	move.l	#mx+$4e42,mus_int
	bsr	show_track
	bra	readkey

neck1	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	mx+$5b02
*	move.l	#mx+$5c0c,mus_int
	bsr	show_track
	bra	readkey
	
neck2	move.l	#no_int,mus_int
*	move.w	#1,d0
*	jsr	mx+$5b02
*	move.l	#mx+$5c0c,mus_int
	bsr	show_track
	bra	readkey

out1	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	mx+$6bd8
*	move.l	#mx+$66ba,mus_int
	bsr	show_track
	bra	readkey
	
out2	move.l	#no_int,mus_int
*	move.w	#1,d0
*	jsr	mx+$6bd8
*	move.l	#mx+$66ba,mus_int
	bsr	show_track
	bra	readkey
	
gold1	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	mx+$7842
*	move.l	#mx+$794c,mus_int
	bsr	show_track
	bra	readkey
	
gold2	move.l	#no_int,mus_int
*	move.w	#2,d0
*	jsr	mx+$7842
*	move.l	#mx+$794c,mus_int
	bsr	show_track
	bra	readkey
	
enduro1	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	mx+$85da
*	move.l	#mx+$86f0,mus_int
	bsr	show_track
	bra	readkey
	
enduro2	move.l	#no_int,mus_int
*	move.w	#1,d0
*	jsr	mx+$85da
*	move.l	#mx+$86f0,mus_int
	bsr	show_track
	bra	readkey
	
enduro3	move.l	#no_int,mus_int
*	move.w	#2,d0
*	jsr	mx+$85da
*	move.l	#mx+$86f0,mus_int
	bsr	show_track
	bra	readkey
	
retg	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	mx+$970a
*	move.l	#mx+$9810,mus_int
	bsr	show_track
	bra	readkey
	
speed1	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	m10
*	move.l	#m10_int,mus_int
	bsr	show_track
	bra	readkey
	
speed2	move.l	#no_int,mus_int
*	move.w	#1,d0
*	jsr	m10
*	move.l	#m10_int,mus_int
	bsr	show_track
	bra	readkey
	
speed3	move.l	#no_int,mus_int
*	move.w	#2,d0
*	jsr	m10
*	move.l	#m10_int,mus_int
	bsr	show_track
	bra	readkey
	
speed4	move.l	#no_int,mus_int
*	move.w	#3,d0
*	jsr	m10
*	move.l	#m10_int,mus_int
	bsr	show_track
	bra	readkey
	
speed5	move.l	#no_int,mus_int
*	move.w	#4,d0
*	jsr	m10
*	move.l	#m10_int,mus_int
	bsr	show_track
	bra	readkey
	
speed6	move.l	#no_int,mus_int
*	move.w	#5,d0
*	jsr	m10
*	move.l	#m10_int,mus_int
	bsr	show_track
	bra	readkey
	
speed7	move.l	#no_int,mus_int
*	move.w	#6,d0
*	jsr	m10
*	move.l	#m10_int,mus_int
	bsr	show_track
	bra	readkey
	
weird1	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	m11
*	move.l	#m11_int,mus_int
	bsr	show_track
	bra	readkey
	
weird2	move.l	#no_int,mus_int
*	move.w	#1,d0
*	jsr	m11
*	move.l	#m11_int,mus_int
	bsr	show_track
	bra	readkey
	
weird3	move.l	#no_int,mus_int
*	move.w	#2,d0
*	jsr	m11
*	move.l	#m11_int,mus_int
	bsr	show_track
	bra	readkey
	
weird4	move.l	#no_int,mus_int
*	move.w	#3,d0
*	jsr	m11
*	move.l	#m11_int,mus_int
	bsr	show_track
	bra	readkey
	
verm1	move.l	#no_int,mus_int
*	move.w	#0,d0
*	jsr	m12
*	move.l	#m12_int,mus_int
	bsr	show_track
	bra	readkey
	
verm2	move.l	#no_int,mus_int
*	move.w	#1,d0
*	jsr	m12
*	move.l	#m12_int,mus_int
	bsr	show_track
	bra	readkey
	
verm3	move.l	#no_int,mus_int
*	move.w	#2,d0
*	jsr	m12
*	move.l	#m12_int,mus_int
	bsr	show_track
	bra	readkey
	
verm4	move.l	#no_int,mus_int
*	move.w	#3,d0
*	jsr	m12
*	move.l	#m12_int,mus_int
	bsr	show_track
	bra	readkey
	
verm5	move.l	#no_int,mus_int
*	move.w	#4,d0
*	jsr	m12
*	move.l	#m12_int,mus_int
	bsr	show_track
	bra	readkey
	
verm6	move.l	#no_int,mus_int
*	move.w	#5,d0
*	jsr	m12
*	move.l	#m12_int,mus_int
	bsr	show_track
	bra	readkey
	
star1	move.l	#no_int,mus_int
*	move.l	#0,d0
*	jsr	m13
*	move.l	#m13_int,mus_int
	bsr	show_track
	bra	readkey
	
star2	move.l	#no_int,mus_int
*	move.l	#1,d0
*	jsr	m13
*	move.l	#m13_int,mus_int
	bsr	show_track
	bra	readkey
	
star3	move.l	#no_int,mus_int
*	move.l	#2,d0
*	jsr	m13
*	move.l	#m13_int,mus_int
	bsr	show_track
	bra	readkey
	
star4	move.l	#no_int,mus_int
*	move.l	#3,d0
*	jsr	m13
*	move.l	#m13_int,mus_int
	bsr	show_track
	bra	readkey
	
custo1	move.l	#no_int,mus_int
*	move.l	#0,d0
*	jsr	m14
*	move.l	#m14_int,mus_int
	bsr	show_track
	bra	readkey
	
custo2	move.l	#no_int,mus_int
*	move.l	#1,d0
*	jsr	m14
*	move.l	#m14_int,mus_int
	bsr	show_track
	bra	readkey
	
custo3	move.l	#no_int,mus_int
*	move.l	#2,d0
*	jsr	m14
*	move.l	#m14_int,mus_int
	bsr	show_track
	bra	readkey
	
custo4	move.l	#no_int,mus_int
*	move.l	#3,d0
*	jsr	m14
*	move.l	#m14_int,mus_int
	bsr	show_track
	bra	readkey
	
custo5	move.l	#no_int,mus_int
*	move.l	#4,d0
*	jsr	m14
*	move.l	#m14_int,mus_int
	bsr	show_track
	bra	readkey
	
custo6	move.l	#no_int,mus_int
*	move.l	#5,d0
*	jsr	m14
*	move.l	#m14_int,mus_int
	bsr	show_track
	bra	readkey
	
obli1	move.l	#no_int,mus_int
*	move.l	#0,d0
*	jsr	m15
*	move.l	#m15_int,mus_int
	bsr	show_track
	bra	readkey
	
obli2	move.l	#no_int,mus_int
*	move.l	#1,d0
*	jsr	m15
*	move.l	#m15_int,mus_int
	bsr	show_track
	bra	readkey
	
obli3	move.l	#no_int,mus_int
*	move.l	#2,d0
*	jsr	m15
*	move.l	#m15_int,mus_int
	bsr	show_track
	bra	readkey
	
obli4	move.l	#no_int,mus_int
*	move.l	#3,d0
*	jsr	m15
*	move.l	#m15_int,mus_int
	bsr	show_track
	bra	readkey
	
plat1	move.l	#no_int,mus_int
*	move.l	#0,d0
*	jsr	m16
*	move.l	#m16_int,mus_int
	bsr	show_track
	bra	readkey
	
plat2	move.l	#no_int,mus_int
*	move.l	#1,d0
*	jsr	m16
*	move.l	#m16_int,mus_int
	bsr	show_track
	bra	readkey
	
plat3	move.l	#no_int,mus_int
*	move.l	#2,d0
*	jsr	m16
*	move.l	#m16_int,mus_int
	bsr	show_track
	bra	readkey
	
plat4	move.l	#no_int,mus_int
*	move.l	#3,d0
*	jsr	m16
*	move.l	#m16_int,mus_int
	bsr	show_track
	bra	readkey
	
plat5	move.l	#no_int,mus_int
*	move.l	#4,d0
*	jsr	m16
*	move.l	#m16_int,mus_int
	bsr	show_track
	bra	readkey
	
plat6	move.l	#no_int,mus_int
*	move.l	#5,d0
*	jsr	m16
*	move.l	#m16_int,mus_int
	bsr	show_track
	bra	readkey
	
plat7	move.l	#no_int,mus_int
*	move.l	#6,d0
*	jsr	m16
*	move.l	#m16_int,mus_int
	bsr	show_track
	bra	readkey
	
emp1	move.l	#no_int,mus_int
*	move.l	#0,d0
*	jsr	m17
*	move.l	#m17_int,mus_int
	bsr	show_track
	bra	readkey
	
emp2	move.l	#no_int,mus_int
*	move.l	#1,d0
*	jsr	m17
*	move.l	#m17_int,mus_int
	bsr	show_track
	bra	readkey
	
emp3	move.l	#no_int,mus_int
*	move.l	#2,d0
*	jsr	m17
*	move.l	#m17_int,mus_int
	bsr	show_track
	bra	readkey
	
emp4	move.l	#no_int,mus_int
*	move.l	#3,d0
*	jsr	m17
*	move.l	#m17_int,mus_int
	bsr	show_track
	bra	readkey
	
emp5	move.l	#no_int,mus_int
*	move.l	#4,d0
*	jsr	m17
*	move.l	#m17_int,mus_int
	bsr	show_track
	bra	readkey
	
emp6	move.l	#no_int,mus_int
*	move.l	#5,d0
*	jsr	m17
*	move.l	#m17_int,mus_int
	bsr	show_track
	bra	readkey
	
emp7	move.l	#no_int,mus_int
*	move.l	#6,d0
*	jsr	m17
*	move.l	#m17_int,mus_int
	bsr	show_track
	bra	readkey
	
emp8	move.l	#no_int,mus_int
*	move.l	#7,d0
*	jsr	m17
*	move.l	#m17_int,mus_int
	bsr	show_track
	bra	readkey
	
tune1	move.l	#no_int,mus_int
*	move.l	#0,d0
*	jsr	m18
*	move.l	#m18_int,mus_int
	bsr	show_track
	bra	readkey
	
xen4	move.l	#no_int,mus_int
*	move.l	#0,d0
*	jsr	m19
*	move.l	#m19_int,mus_int
	bsr	show_track
	bra	readkey
	
	
f10	nop		;Exit : Key not known!
	
;End of music screen, finish up
;and back to the main screen!
;
	move.w	#$2700,sr	;Put in duff interrupts
	move.l	#null_vbl,$70.w	;
	move.w	#$2300,sr	;

	bsr	delay		;*** WAIT ***
	
	jsr	hotcopy		;Copy main screen picture to screens
	
	move.w	#$2700,sr	;Put in main screen interrupts
	move.l	#new_vbl,$70.w	;
	move.l	#killtop,$120.w	;
	move.w	#$2300,sr	;

	lea	$ff8240,a0	;Install main screen palette	
	lea	new_palette,a2  ;
	move.w	#7,d0		;
col_lp3	move.l	(a2)+,(a0)+	;
	dbra	d0,col_lp3	;
	rts			;--->
	
	
************
* VU Meter *
************
; The VU meter is drawn on plane 3
;	
draw_meter
	move.b	#$8,$ff8800
	move.b	$ff8800,d0	;Channel A
	move.b	#$9,$ff8800
	move.b	$ff8800,d1	;Channel B
	move.b	#$a,$ff8800
	move.b	$ff8800,d2	;Channel C
	and.l	#$f,d0	
	and.l	#$f,d1	
	and.l	#$f,d2
	
	;Channel A
	lea	vol_data,a0	;Base of pixel data
	asl.l	#4,d0		;x16
	adda.l	d0,a0
	move.l	screen_1,a1
	adda.l	#172*$a0+4*18,a1	;Screen address
	bsr	print_level
	
	;Channel B
	lea	vol_data,a0	;Base of pixel data
	asl.l	#4,d1		;x16
	adda.l	d1,a0
	move.l	screen_1,a1
	adda.l	#178*$a0+4*18,a1	;Screen address
	bsr	print_level
	
	;Channel C
	lea	vol_data,a0	;Base of pixel data
	asl.l	#4,d2		;x16
	adda.l	d2,a0
	move.l	screen_1,a1
	adda.l	#184*$a0+4*18,a1	;Screen address
	bsr	print_level
		
	rts
	
; Print Strip ( 8 wide ) pointed at by a0
; At screen line a1, on plane 2

print_level
	move.w	#4,d7
pl_lp
	move.w	(a0),$0+6(a1)
	move.w	2(a0),$8+6(a1)
	move.w	4(a0),$10+6(a1)
	move.w	6(a0),$18+6(a1)
	move.w	8(a0),$20+6(a1)
	move.w	10(a0),$28+6(a1)
	move.w	12(a0),$30+6(a1)
	move.w	14(a0),$38+6(a1)
	adda.l	#$a0,a1
	
	dbf	d7,pl_lp
	rts
	
**************
* Show Track *
**************
; Displays current track
; on LED Display
;
show_track
	clr.l	d0		;Clean 'em!
	clr.l	d1
	clr.l	d2
	lea	mus_picture,a0	;Music Picture data
	adda.l	#113*$a0,a0	;First line of LED no.s
	move.l	screen_1,a1
	adda.l	#(168*$a0)+8,a1	;Where to put LEDs
	move.w	track,d0	;Get track!
	*
	move.w	d0,d1
	divu	#10,d1		;Divide by ten = d1 = tens
	move.w	d1,d2
	mulu	#10,d2
	sub	d2,d0		;Get Modulus = d0 = Units
	andi.l	#$ffff,d0	;Paranoid!
	andi.l	#$ffff,d1
	*
	* First Digit
	*
	move.l	a0,a4		;Src
	move.l	a1,a5		;Dest.
	asl.w	#3,d1		;Point to correct LED
	adda.l	d1,a4		;
	move.w	#21,d7		;20 lines
led_loop_a
	move.l	(a4),(a5)
	move.l	4(a4),4(a5)
	adda.l	#$a0,a4
	adda.l	#$a0,a5
	dbf	d7,led_loop_a
	*
	* Second Digit
	*
	move.l	a0,a4		;Src
	move.l	a1,a5		;Dest.
	adda.l	#8,a5		;Remeber is 2nd word
	asl.w	#3,d0		;Point to correct LED
	adda.l	d0,a4		;
	move.w	#21,d7		;20 lines
led_loop_b
	move.l	(a4),(a5)
	move.l	4(a4),4(a5)
	adda.l	#$a0,a4
	adda.l	#$a0,a5
	dbf	d7,led_loop_b
	
	***** rts **********
		
*******************
* Show Track Name *
*******************
; Prints name of <track>
; in name box,
; inverted if is current
; track!
;
show_track_name
	move.l	screen_1,a1	;Address of name box ?
	adda.l	#(148*$a0)+(9*8)+6,a1	
	move.w	track,d0	;Get track!
	mulu	#20,d0		;Point to description
	andi.l	#$ffff,d0	;
	lea	track_names,a0	;
	adda.l	d0,a0		;
	move.w	#7,d7		;Do 16 Chars worth	
name_loop
	clr.l	d5
	clr.l	d6
	move.b	(a0)+,d5	;Get 2 chars at a time
	move.b	(a0)+,d6
	subi.b	#32,d6
	subi.b	#32,d5
	asl.w	#3,d5	
	asl.w	#3,d6		;Get offset
	lea	in_set,a5	;	
	lea	in_set,a6	;
	adda.l	d5,a5		;a5=addr of first	
	adda.l	d6,a6		;a6=addr of second
	;Print!
	move.b	0(a5),(a1)	
	move.b	0(a6),1(a1)
	move.b	1(a5),1*$a0(a1)	
	move.b	1(a6),1*$a0+1(a1)	
	move.b	2(a5),2*$a0(a1)	
	move.b	2(a6),2*$a0+1(a1)	
	move.b	3(a5),3*$a0(a1)	
	move.b	3(a6),3*$a0+1(a1)	
	move.b	4(a5),4*$a0(a1)	
	move.b	4(a6),4*$a0+1(a1)	
	move.b	5(a5),5*$a0(a1)	
	move.b	5(a6),5*$a0+1(a1)	
	move.b	6(a5),6*$a0(a1)	
	move.b	6(a6),6*$a0+1(a1)	
	move.b	7(a5),7*$a0(a1)	
	move.b	7(a6),7*$a0+1(a1)
	adda.l	#8,a1	;Next word
	dbf	d7,name_loop	

	move.w	track,d0
	cmp.w	playing,d0
	bne	exit_name
	move.l	screen_1,a1	;Address of name box ?
	adda.l	#(148*$a0)+(9*8)+6,a1	
	move.w	#7,d7
inv_loop			;Invert songname
	not	0*$a0(a1)	;since is selected.
	not	1*$a0(a1)
	not	2*$a0(a1)
	not	3*$a0(a1)
	not	4*$a0(a1)
	not	5*$a0(a1)
	not	6*$a0(a1)
	not	7*$a0(a1)
	adda.l	#8,a1
	dbf	d7,inv_loop
	
exit_name
	rts
	
	
	
***********
* LETTERS *
***********
;
;The Letters ( FINGERBOBS ) are treated as
;four plane sprites and copied directly from
;a .PI1 file 'incbinned' into the code
;
update_letters
	lea	letter1,a2
	move.w	#9,d7
up_loop
	move.w	(a2),d0
	addq.w	#2,d0		;Update value
	andi.w	#$ff,d0
	move.w	d0,(a2)
	addq.l	#4,a2
	dbra	d7,up_loop
	rts
display_letters
	move.w	#9,d7		;10 Letters
	lea	sine_table,a3
	lea	letter1,a2
	lea	letter_save,a4
loop	clr.l	d1
	move.w	(a2)+,d0
	move.b	(a3,d0.w),d1	;Value from sine table
	addi.w	#21,d1		;Constant
	mulu	#$a0,d1		;Screen line
	movea.l	#0,a1
	move.w	(a2),a1
	adda.l	d1,a1
	adda.l	screen_1,a1	;Destination
	move.l	a1,(a4)+	;Save for Rubout!
	movea.l	#0,a0
	move.w	(a2)+,a0
	adda.l	#mus_picture,a0
cnt	set	0
door	rept	32		;PUT a complete letter
	move.l	cnt(a0),cnt(a1)
	move.l	cnt+4(a0),cnt+4(a1)
	move.l	cnt+8(a0),cnt+8(a1)
	move.l	cnt+12(a0),cnt+12(a1)
cnt	set	$a0+cnt
	endr
	dbra	d7,loop	
	rts
delete_letters
	move.w	#9,d7		;10 Letters
	lea	letter_save,a4	;to remove from screen
loop2	move.l	(a4)+,a0
cnt	set	0
door2	rept	32
	clr.l	cnt(a0)
	clr.l	cnt+4(a0)
	clr.l	cnt+8(a0)
	clr.l	cnt+12(a0)
cnt	set	$a0+cnt
	endr
	dbra	d7,loop2	
	rts

;Get the sine table and half its amplitute,
;This saved using Fast Basic to generate yet another
;table for me!
;
cut_table	
	lea	sine_table,a0
	move.w	#255,d0
cut_loop
	move.b	(a0),d1
	asr.l	#1,d1
	move.b	d1,(a0)+
	dbra	d0,cut_loop
	rts



*****************************************************************
*								*
*                 THE CORKSCREW SCREEN                          *
*								*
*****************************************************************
;
;This effect is achieved quite simply!
;It is done by doing a diagonal scroller into a buffer and
;then wrapping the buffer round an imaginary buffer by
;only copying certain lines of the buffer to the screen
;To save the complications of actually having to scroll
;the buffer, 8 copies of the character set are created,
;one for each of the 8 possible positions ( horizontaly ) a
;character can be.
;And 8 tables are used to give the exact positions for
;each of the letters on screen, ( there are 40 ) so that 
;practically no calculations need be done at run-time.
;
;The buffer is wrapped round a ( imaginary ) barrel twice
;first, the top half of the buffer is copied to the first
;bitplane, the correct way up, then the bottom half of the
;buffer is copied upside-down-ways to the next bitplane.
;
;By defining the colours correctly, the front of the scroller
;always shows where the front and back intersect!
;
cork_screen
        move.b  #2,$ffff820a.w  ;Set 50 Hz
	bsr	hotblack
	move.w	#$2700,sr	;Put in duff interrupts
	move.l	#null_vbl,$70.w	;
	move.w	#$2300,sr	;
	jsr	vbl		;Wait a frame

	lea	cork_credits,a0
	bsr	hotcredits	;
	
	move.l	#bar2,do_cols2	;Colour cycling variables
	move.w	#3,wait		;
	
	move.l	screen_1,a1	;Clear screen
	move.w	#(50000/4)-1,d0	;to wipe out any
plm	move.l	#0,(a1)+	;garbage
	dbra	d0,plm		;
	
	move.l	#data,a1	;Clear buffer area
	move.w	#(32000/4)-1,d0	;to wipe out any
plg	move.l	#0,(a1)+	;garbage
	dbra	d0,plg		;

	lea	crk_picture,a0	;Depack data onto
	move.l	screen_1,a1	;Screen1
	bsr	undo_picture
	move.l	screen_1,a0	;Copy Screen 1 to Screen 2
	move.l	screen_2,a1	;
	move.w	#(32000/4),d0	;
hotlp2	move.l	(a0)+,(a1)+	;
	dbra	d0,hotlp2	;
	
	bsr	delay		;*** WAIT ***

	move.w	#$2700,sr	;Put in music scrn interrupts
	move.l	#crk_vbl,$70.w	;
	move.l	#crk_hbl,$120.w
	move.w	#$2300,sr	;

	lea	$ff8240,a0	;Install new screens palette	
	lea	crk_cols,a2  ;
	move.w	#7,d0		;
col_lp6	move.l	(a2)+,(a0)+	;
	dbra	d0,col_lp6	;
	
	bsr	do_scroll	;DO IT!
	
	move.w	#$2700,sr	;Put in duff interrupts
	move.l	#null_vbl,$70.w	;

	move.w	#$2300,sr	;

	jsr	hotcopy		;Copy main screen pictures to screens

	lea	data,a0		;Clear out character set
	move.w	#(32000/4)-1,d0	;area.
carron				;
	move.l	#0,(a0)+
	dbf	d0,carron
	
	bsr	delay		;*** WAIT ***
	
	move.w	#$2700,sr	;Put in main screen interrupts
	move.l	#new_vbl,$70.w	;
	move.l	#killtop,$120.w	;
	move.w	#$2300,sr	;
	
	lea	$ff8240,a0	;Install main screen palette	
	lea	new_palette,a2  ;
	move.w	#7,d0		;
col_lp9	move.l	(a2)+,(a0)+	;
	dbra	d0,col_lp9	;

	rts			;--->
	
bar_line equ 85		;Line for scroller
bar_size equ 50		;Size of scroller ( Height )


*****************************
*			    *
* THE MAIN PROGRAM ROUTINES *
*			    *
*****************************
;SCROLLER CONTROL LOOP
;> Scrolls 8 pixels of each character, prints
;  scroll"line" . Watches for end of scroller etc...
; 
do_scroll
	move.l	set,a4		;Address of current char_set
	move.l	Table,a5	;Address of current Table
	move.l	crkscrl,a6	;Address of scroller data
	bsr	do_table	;Calculate the Diagonal scroll
	bsr	draw_bar	;Wrap it round a barrel
	bsr	screen_swap	;Now display it
	move.l	Table,a5	;Clear out
	bsr	clear_screen	;The Diagonal Scroll data
	subi.l	#60*8*2,set	;Point to next set
	addi.l	#40*4,Table	;Pint to next Table
	addi.b	#1,count	;Count up pixels
	cmpi.b	#8,count	;Was Last pixel ?
	bne.s	cont		;No -> Branch over
	bsr.s	crk_restart	;Last pix so set up for next char
cont	move.w	#$ff,-(a7)	;Test for a key 
	move.w	#6,-(a7)
	trap	#1
	addq.l	#4,a7
	tst.w	d0
	bne.s	cork_end
	bsr.s	vbl
	bra.s	do_scroll
	
cork_end
	rts			;Keypress = EXIT
	
	
crk_restart
	move.l	#set_7,set	;Initial Set
	move.l	#Table_0,Table	;Initial Table
	move.b	#0,count	;Zero pixels
	addq.l	#1,crkscrl	;Next char
	cmpi.l	#scroll_end-39,crkscrl	
	beq	go_scroll	;End of message ?
	rts
	
; End of message -> Back to start of message

go_scroll
	move.l	#scrolltext,crkscrl
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
	*move.b	$1(a3),$0+2(a1)		;are usually garbage so don't print!
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

	
*********************************************************************
*								    *
*                  DIGITISED FINGERBOBS SCREEN                      *
*								    *
*********************************************************************
;
;An unspectacular screen....
;
person_screen
        move.b  #2,$ffff820a.w  ;Set 50 Hz
	bsr	hotblack
	move.w	#$2700,sr	;Put in duff interrupts
	move.l	#null_vbl,$70.w	;
	move.w	#$2300,sr	;
	jsr	vbl		;Wait a frame

	lea	person_credits,a0
	bsr	hotcredits

	jsr	delay		;*** WAIT ***
	
	move.l	screen_1,a0	;Where to scroll
	adda.l	#175*$a0,a0
	move.l	a0,pscrl_data
	
	move.l	#ptext1,txt_addr
	move.b	#0,pslice	;Init scroller
	jsr	prestart
		
	move.w	#0,person	;Draw fist piccy
	bsr	oberje
	
	move.w	#$2700,sr	;Put in interrupts/scroller
	move.l	#who_vbl,$70.w	;
	move.w	#$2300,sr	;

	bsr	readkey2	;DO IT!
	
	move.w	#$2700,sr	;Put in duff interrupts
	move.l	#null_vbl,$70.w	;
	move.w	#$2300,sr	;

	bsr	hotclear
	
	jsr	hotcopy		;Copy main screen pictures to screens

	jsr	delay		;*** WAIT ***
	
	move.w	#$2700,sr	;Put in main screen interrupts
	move.l	#new_vbl,$70.w	;
	move.l	#killtop,$120.w	;
	move.w	#$2300,sr	;
	
	lea	$ff8240,a0	;Install main screen palette	
	lea	new_palette,a2  ;
	move.w	#7,d0		;
col_lpk	move.l	(a2)+,(a0)+	;
	dbra	d0,col_lpk	;

	rts			;--->


readkey2	
	move.w	#8,-(a7)	;Get key
	trap	#1
	addq.l	#2,a7
	
	cmpi.b	#" ",d0		;Space = Exit
	beq	p_end
	swap	d0		;Look at scancode
	cmpi.b	#$4d,d0		;-> = Up 1 person
	beq	up_person
	cmpi.b	#$4b,d0		;<- = Down 1 person
	beq	down_person
	bra	readkey2

up_person
	addq.w	#1,person
	cmpi.w  #5,person	
	bne	up1
	move.w	#0,person
up1
	bsr	do_person
	bra	readkey2
	
down_person
	subq.w	#1,person
	cmpi.w	#-1,person
	bne	down1
	move.w	#4,person
down1
	bsr	do_person
	bra	readkey2

do_person
	move.w	person,d0
	cmpi.w	#0,d0
	beq	oberje
	cmpi.w	#1,d0
	beq	creeper
	cmpi.w	#2,d0
	beq	the_count
	cmpi.w	#3,d0
	beq	zen
	cmpi.w	#4,d0
	beq	shades
	
	
oberje
	move.l	#null_vbl,$70.w
	bsr	clear_area
	move.l	#p1data,a0	;Address of .pc1 data
	move.l	screen_2,a1	;Address of buffer to decompress into
	bsr	undo_picture	;Decompact
	bsr	copy2screen
	move.l	#ptext1,txt_addr
	move.b	#0,pslice	
	jsr	prestart
	move.l	#who_vbl,$70.w
	rts

creeper
	move.l	#null_vbl,$70.w
	bsr	clear_area
	move.l	#p2data,a0	;Address of .pc1 data
	move.l	screen_2,a1	;Address of buffer to decompress into
	bsr	undo_picture	;Decompact
	bsr	copy2screen
	move.l	#ptext2,txt_addr
	move.b	#0,pslice	
	jsr	prestart
	move.l	#who_vbl,$70.w
	rts

the_count
	move.l	#null_vbl,$70.w
	bsr	clear_area
	move.l	#p3data,a0	;Address of .pc1 data
	move.l	screen_2,a1	;Address of buffer to decompress into
	bsr	undo_picture	;Decompact
	bsr	copy2screen
	move.l	#ptext3,txt_addr
	move.b	#0,pslice	
	jsr	prestart
	move.l	#who_vbl,$70.w
	rts

zen
	move.l	#null_vbl,$70.w
	bsr	clear_area
	move.l	#p4data,a0	;Address of .pc1 data
	move.l	screen_2,a1	;Address of buffer to decompress into
	bsr	undo_picture	;Decompact
	bsr	copy2screen
	move.l	#ptext4,txt_addr
	move.b	#0,pslice	
	jsr	prestart
	move.l	#who_vbl,$70.w
	rts

shades
	move.l	#null_vbl,$70.w
	bsr	clear_area
	move.l	#p5data,a0	;Address of .pc1 data
	move.l	screen_2,a1	;Address of buffer to decompress into
	bsr	undo_picture	;Decompact
	bsr	copy2screen
	move.l	#ptext5,txt_addr
	move.b	#0,pslice	
	jsr	prestart
	move.l	#who_vbl,$70.w
	rts


copy2screen
	move.l	screen_2,a0
	move.l	screen_1,a1
	adda.l	#5*$a0+(5*8),a1
	move.w	#127,d0
digi_loop
	rept	10
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	
	add.l	#(10*8),a0
	add.l	#(10*8),a1
	
	dbf	d0,digi_loop		
	rts

	****************
	* Exit Screen  *
	****************
p_end	rts
	 
	*********************************
	* Picture Decompression Routine *
	*********************************
; Uncompress a Degas Compressed Picture
; This routine is very slow, due to the method used to
; calculate the address of the next byte. 
; It does however work, so whos complaining ?
;
undo_picture
	move.l	a1,scween
	move.w	#0,finished
	move.w	#0,d3		;Byte currently on
	move.l	#0,a2		;Start Scan line
	move.w	#0,d4		;Plane 0
	move.w	#0,d5		;Which word ( when = 20 -> new plane )
				;a0=address of next byte
value	cmpi.w	#-1,finished	;
	beq	finish_undo	;
	clr.l	d0		;Clear reg
	move.b	(a0),d0		;Next value
	tst.b	d0		;Compare with 0
	bgt	copybytes	; 0...127 = Copy next n+1 bytes
	cmpi.b	#-128,d0	;  -128   = Ignore
	bne	repeatbyte	;-1..-127 = Copy next byte -n+1 times	
ignore	addq.l	#1,a0		;Add one to address
	bra	value		;Next value
	***********************
	* Copy next n+1 bytes *
	***********************
	;d0 not adjusted since a dbra must be n-1 anyway
copybytes
	addq.l	#1,a0		;Point to first data byte
	bsr	get_address	;Return address for byte in a1
	move.b	(a0),(a1)	;Copy byte to screen
	dbra	d0,copybytes	;Next byte to copy
	addq.l	#1,a0		;Update Pointer
	bra	value		;Next value
	*****************************
	* Copy next byte -n+1 times *
	*****************************
repeatbyte
	neg.b	d0		;Change sign
	addq.l	#1,a0		;Point to byte to repeat
	move.b	(a0),d1		;Put in d1
repeatloop
	bsr	get_address	;Return address for byte in a1
	move.b	d1,(a1)		;Copy byte to screen
	dbra	d0,repeatloop	;Next copy
	addq.l	#1,a0		;Update Pointer
	bra	value		;Next value
	***************
finish_undo
	rts
	***************
	* Get Address *
	***************
	;This routine returns in A1 the
	;screen address for the next byte
	;Addresses are genarated one scanline
	;at a time, plane 0 first then
	;plane 1,2 and finally 3, then on to
	;the next scanline.
get_address
	move.l	scween,a1	;Base of screen
	clr.l	d7		;Clear working regs
	clr.l	d2		;
	adda.l	a2,a1		;Correct screen line
	move.w	d5,d7		;Current Word (1 Plane offset)
	move.w	d4,d2		;Current Plane
	mulu	#8,d7		;Get actual word offset
	add.w	d2,d7		;Add on current plane
	add.w	d3,d7		;Add on current byte
	adda.l	d7,a1		;a1=Correct address of byte
	addq.w	#1,d3		;Update byte
	cmpi.w	#2,d3		;Last byte in word
	beq	next_word	;Yes ---->
	rts			;No -> Exit
next_word	
	move.w	#0,d3		;Point to first byte again
	addq.w	#1,d5		;Point to next word
	cmpi.w	#20,d5		;Last word in plane ?
	beq	next_plane	;Yes ---->
	rts			;No -> Exit
next_plane
	move.w	#0,d5		;Point to first word again
	addq.w	#2,d4		;Point to next plane
	cmpi.w	#8,d4		;Last Plane on scanline ?
	beq	nxt_line	;Yes ---->
	rts			;No -> Exit
nxt_line
	move.w	#0,d4		;Point to first plane again
	add.l	#$a0,a2		;Point to next scanline
	cmpa.l	#$a0*200,a2	;Last scanline ?
	beq	end_undo	;Yes ----> Exit decompression loop
	rts			;No -> Exit
end_undo
	move.w	#$ffff,finished
	rts
	

	************************
	* 8x8 2 Pixel Scroller *
	************************
p_scroll
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	#this_char,a1	;Point to character
	move.l	pscrl_data,a0	;Scroll scroll data
	move.w	#8-1,d7		;8 lines
p_sclp	scr2	$0,3		;Do all words in line
	scr2	$8,3		;except last one!
	scr2	$10,3
	scr2	$18,3
	scr2	$20,3
	scr2	$28,3		;Only working with
	scr2	$30,3		;Bitplane 0 this time
	scr2	$38,3
	scr2	$40,3
	scr2	$48,3
	scr2	$50,3
	scr2	$58,3
	scr2	$60,3
	scr2	$68,3
	scr2	$70,3
	scr2	$78,3
	scr2	$80,3
	scr2	$88,3
	scr2	$90,3
	move.w	$98+(2*3)(a0),d1	;Get last word
	move.b	(a1),d0
	roxl.b	d0			;Scroll on new bit
	roxl.w	d1
	roxl.b	d0			;Scroll on new bit
	roxl.w	d1
	move.w	d1,$98+(2*3)(a0)	;Save both
	move.b	d0,(a1)+		;values
	adda.l	#$a0,a0		;Next screen line
	dbra	d7,p_sclp
	addq.b	#1,pslice	;Increment slice
	andi.b	#%11,pslice	;Counter
	tst.b	pslice
	beq	next_letter	;8 slices in a letter
return	movem.l	(a7)+,d0-d7/a0-a6
	rts
	
next_letter
	bsr	do_letter	;Deal with letter
	bra	return		;back to scroller
		
prestart	
	move.l	txt_addr,phere	;Point to character before
	sub.l	#1,phere	;
do_letter
	addq.l	#1,phere	;Point to next char
	move.l	phere,a0	;
	clr.l	d0		;
	move.b	(a0),d0		;Get letter
	cmpi.b	#0,d0		;Is it Restart?
	beq	prestart	;Yes then restart!!
	cmpi.b	#13,d0		;CR
	beq	do_letter
	cmpi.b	#10,d0		;LF
	beq	do_letter
			
do_it	subi.w	#32,d0		;Take away ascii offset
	asl.w	#3,d0		;Multiply by 8 to get table offset
	lea	in_set,a0	;Get base of char data
	adda.l	d0,a0		;Find letter we want
	lea	this_char,a1	;Copy it to 
	move.l	(a0)+,(a1)+	;This_char
	move.l	(a0)+,(a1)+	;buffer
	rts

clear_area	;Clear out scroll area
	move.l	pscrl_data,a0
	move.w	#7,d0		;8 lines
arealoop
	clr.l	$00+6(a0)
	clr.l	$08+6(a0)
	clr.l	$10+6(a0)
	clr.l	$18+6(a0)
	clr.l	$20+6(a0)
	clr.l	$28+6(a0)
	clr.l	$30+6(a0)
	clr.l	$38+6(a0)
	clr.l	$40+6(a0)
	clr.l	$48+6(a0)
	clr.l	$50+6(a0)
	clr.l	$58+6(a0)
	clr.l	$60+6(a0)
	clr.l	$68+6(a0)
	clr.l	$70+6(a0)
	clr.l	$78+6(a0)
	clr.l	$80+6(a0)
	clr.l	$88+6(a0)
	clr.l	$90+6(a0)
	clr.l	$98+6(a0)
	adda.l	#$a0,a0
	dbf	d0,arealoop
	rts


*************************************************************
*							    *
*                  THE BIG SCROLLER SCREEN                  *
*							    *
*************************************************************
;
;This scroller really is BIG!
;Both Top and Bottom borders are used, the characters are
;256x256 however only 256x240 is actually printed since
;the bottom line was never used by the character set.
;
;The trick to this screen, is that the character set is enlarged
;to its final size ( from 16x16 ) horizontally, before the screen 
;begins. i.e set becomes 256x16
;The screen then just scrolls a 320x16 buffer, and just copies
;each line of the buffer to the screen 16 times, and thus the
;big scroller is done!
;
;It took me 45 minutes to code this!
;
big_screen
        move.b  #2,$ffff820a.w  ;Set 50 Hz
	bsr	hotblack
	move.w	#$2700,sr	;Put in duff interrupts
	move.l	#null_vbl,$70.w	;
	move.w	#$2300,sr	;
	jsr	vbl		;Wait a frame

	move.l	#bar2,do_cols2
	move.w	#2,wait
	
	lea	big_credits,a0
	bsr	hotcredits
	
	lea	buffer,a0	;Clear out scroll buffer
	move.w	#(40*16)-1,d0
bloop	move.b	#0,(a0)+
	dbf	d0,bloop
		
	bsr	delay		;*** WAIT ***

	move.w	#$2700,sr	;Put in music scrn interrupts
	move.l	#big_vbl,$70.w	;
	move.w	#$2300,sr	;

	lea	$ff8240,a0	;Install new screens palette	
	lea	big_cols,a2  ;
	move.w	#7,d0		;
col_lpr	move.l	(a2)+,(a0)+	;
	dbra	d0,col_lpr	;
	
	bsr	make_large_set
	bsr	start_scroll
	jsr	vbl
	bsr	bigscroll	
	
	move.w	#$2700,sr	;Put in duff interrupts
	move.l	#null_vbl,$70.w	;
	move.w	#$2300,sr	;

	jsr	hotclear	;Clear screens
	jsr	hotcopy		;Copy main screen pictures to screens

	lea	data,a0		;Clear out character set
	move.w	#(32000/4)-1,d0	;since same area is needed by
kim				;Corkscrew scroller
	move.l	#0,(a0)+
	dbf	d0,kim
	
	jsr	delay		;*** WAIT ***
	
	move.w	#$2700,sr	;Put in main screen interrupts
	move.l	#new_vbl,$70.w	;
	move.l	#killtop,$120.w	;
	move.w	#$2300,sr	;
	
	lea	$ff8240,a0	;Install main screen palette	
	lea	new_palette,a2  ;
	move.w	#7,d0		;
coldlp9	move.l	(a2)+,(a0)+	;
	dbra	d0,coldlp9	;

	rts			;--->
	
	
	********************
	* Restart Scroller *
	********************
start_scroll
	move.l	#bigtext,text_ptr
	move.w	#1,bslice
	rts
	
	************
	* Scroller *
	************
; Scrolling is by 8-pixels, no shifting is involved
;just losts of MOVE.B instructions!
;
scroll_it
	tst.w	bslice		;Need a new char?
	beq	new_character
go_on_then	
	lea	buffer,a0
	move.w	#16-1,d0	;16 lines of byte scroll
byte_it
	move.b	1(a0),0(a0)
	move.b	2(a0),1(a0)
	move.b	3(a0),2(a0)
	move.b	4(a0),3(a0)
	move.b	5(a0),4(a0)
	move.b	6(a0),5(a0)
	move.b	7(a0),6(a0)
	move.b	8(a0),7(a0)
	move.b	9(a0),8(a0)
	move.b	10(a0),9(a0)
	move.b	11(a0),10(a0)
	move.b	12(a0),11(a0)
	move.b	13(a0),12(a0)
	move.b	14(a0),13(a0)
	move.b	15(a0),14(a0)
	move.b	16(a0),15(a0)
	move.b	17(a0),16(a0)
	move.b	18(a0),17(a0)
	move.b	19(a0),18(a0)
	move.b	20(a0),19(a0)
	move.b	21(a0),20(a0)
	move.b	22(a0),21(a0)
	move.b	23(a0),22(a0)
	move.b	24(a0),23(a0)
	move.b	25(a0),24(a0)
	move.b	26(a0),25(a0)
	move.b	27(a0),26(a0)
	move.b	28(a0),27(a0)
	move.b	29(a0),28(a0)
	move.b	30(a0),29(a0)
	move.b	31(a0),30(a0)
	move.b	32(a0),31(a0)
	move.b	33(a0),32(a0)
	move.b	34(a0),33(a0)
	move.b	35(a0),34(a0)
	move.b	36(a0),35(a0)
	move.b	37(a0),36(a0)
	move.b	38(a0),37(a0)
	move.b	39(a0),38(a0)
	move.b	40(a0),39(a0)
	adda.l	#40,a0
	dbf	d0,byte_it
	
	; Now lets get character to print
	
	clr.l	d0
	move.l	text_ptr,a0
	move.b	(a0),d0
	subi.b	#32,d0	;
	
	asl.w	#4,d0
	asl.w	#5,d0	;Mulu #512
	
	lea	large_set,a0
	adda.l	d0,a0	;a0=addr of char data
	
	clr.l	d0
	move.w	bslice,d0
	subi.w	#1,d0	;Slice is always 1 more!
	adda.l	d0,a0	;a0=slice of char data
	add.l	#2,d0
	andi.w	#%11111,d0
	move.w	d0,bslice
	
	;Now put slice in scroll buffer
	 
	lea	buffer,a1
	move.b	0*32(a0),39+0*40(a1)	;All 16 lines
	move.b	1*32(a0),39+1*40(a1)
	move.b	2*32(a0),39+2*40(a1)
	move.b	3*32(a0),39+3*40(a1)
	move.b	4*32(a0),39+4*40(a1)
	move.b	5*32(a0),39+5*40(a1)
	move.b	6*32(a0),39+6*40(a1)
	move.b	7*32(a0),39+7*40(a1)
	move.b	8*32(a0),39+8*40(a1)
	move.b	9*32(a0),39+9*40(a1)
	move.b	10*32(a0),39+10*40(a1)
	move.b	11*32(a0),39+11*40(a1)
	move.b	12*32(a0),39+12*40(a1)
	move.b	13*32(a0),39+13*40(a1)
	move.b	14*32(a0),39+14*40(a1)
	move.b	15*32(a0),39+15*40(a1)
	
	rts		;All done!
	
new_character
	move.l	text_ptr,a0
	adda.l	#1,a0
	tst.b	(a0)
	beq	end_of
	move.l	a0,text_ptr
	move.w	#1,bslice
	bra	go_on_then	
end_of
	move.l	#bigtext,text_ptr
	move.w	#1,bslice
	bra	go_on_then
	
	
	***********************
	* Draw the Shit then! *
	***********************
draw_it	move.l	screen_2,a1
	adda.l	#(10*$a0),a1	;Put on plane 0
	lea	buffer,a0	
	
	;Set is 16 pixels high but last line
	;is always blank!
	;So we need only do 15, which is just as well
	;'cos time is pretty short on this screen!
	;
	rept	15
	bsr	draw_line	;1
	adda.l	#$a0,a1
	bsr	draw_line	;2
	adda.l	#$a0,a1
	bsr	draw_line	;3
	adda.l	#$a0,a1
	bsr	draw_line	;4
	adda.l	#$a0,a1
	bsr	draw_line	;5
	adda.l	#$a0,a1
	bsr	draw_line	;6
	adda.l	#$a0,a1
	bsr	draw_line	;7
	adda.l	#$a0,a1
	bsr	draw_line	;8
	adda.l	#$a0,a1
	bsr	draw_line	;9
	adda.l	#$a0,a1
	bsr	draw_line	;10
	adda.l	#$a0,a1
	bsr	draw_line	;11
	adda.l	#$a0,a1
	bsr	draw_line	;12
	adda.l	#$a0,a1
	bsr	draw_line	;13
	adda.l	#$a0,a1
	bsr	draw_line	;14
	adda.l	#$a0,a1
	bsr	draw_line	;15
	adda.l	#$a0,a1
	bsr	draw_line	;16
	adda.l	#$a0,a1
	adda.l	#40,a0
	endr
	
	rts


	******************
	* Make Large Set *
	******************
		
make_large_set		
	lea	orig_set,a0
	lea	large_set,a1
	move.w	#(16*60)-1,d6
this_line
	move.w	(a0)+,d0
	move.w	#16-1,d7
this_word
	rol.w	d0
	bcc	nofill
	move.w	#$ffff,(a1)+
pooka
	dbf	d7,this_word
	dbf	d6,this_line
	rts
	
nofill	move.w	#$0000,(a1)+
	bra	pooka
	
	
		
	*********************************
	* Draw 1 line of data to screen *
	*********************************
	
draw_line	; a0=data, a1=screen
	move.w	0(a0),$0(a1)
	move.w	2(a0),$8(a1)
	move.w	4(a0),$10(a1)
	move.w	6(a0),$18(a1)
	move.w	8(a0),$20(a1)
	move.w	10(a0),$28(a1)
	move.w	12(a0),$30(a1)
	move.w	14(a0),$38(a1)
	move.w	16(a0),$40(a1)
	move.w	18(a0),$48(a1)
	move.w	20(a0),$50(a1)
	move.w	22(a0),$58(a1)
	move.w	24(a0),$60(a1)
	move.w	26(a0),$68(a1)
	move.w	28(a0),$70(a1)
	move.w	30(a0),$78(a1)
	move.w	32(a0),$80(a1)
	move.w	34(a0),$88(a1)
	move.w	36(a0),$90(a1)
	move.w	38(a0),$98(a1)
	rts

	**************************
	* BIGSCROLL CONTROL LOOP *
	**************************
bigscroll
	bsr	scroll_it	;Scroll buffer
	bsr	draw_it		;Put onto screen
	bsr	switch_screens	;Give it to the public!
	jsr	play
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	
	move.w	#$ff,-(a7)	;Test keyboard
	move.w	#6,-(a7)
	trap	#1
	addq.l	#4,a7
	
	tst.w	d0
	beq	bigscroll	;Exit upon keypress
	
	rts
	
		
	***********************************
	* Swap round screens and pointers *
	***********************************
switch_screens
	move.l	screen_2,d0	;Write directly
	asr.l	#8,d0		;to hardware, screw
	move.b	d0,$ff8203	;the bios!
	asr.l	#8,d0
	move.b	d0,$ff8201

	move.l	screen_1,d0
	move.l	screen_2,screen_1
	move.l	d0,screen_2
	
	rts




*******************************************
* Create 16 preshifted copies of a sprite *
*******************************************
*
* Sprite is held in memory as 4 planes of 16x16 pixels
* i.e 1 word along by 16 lines ( 16 words ) x 4 planes
*     = 1 x 16 x 4 = 64 words = 128 bytes ( $80 )
* This is my standard 16x16 Character set format.
*
* The sprite data is stored at sprite_data 16 times
* one after another ( 4096 bytes ) each one shifted along
* one pixel to the right
*
* The actual sprite data and the mask are held together
* and are interleaved.
*
* The format is 1x.L First Word Mask
*		1x.L Second Word Mask
*		1x.L First Word Data
*		1x.L Second Word Data
*
* Because of this preshifting, the sprite routine does
* not have to shift every sprite it prints, but just
* refers to the preshifted sprite it requires.
*

make_sprites
	lea	sprite_data,a1	;Sprite area
	lea	char,a0		;Address of original sprite data
	lea	work,a3		;Work Area
	
	move.w	#16-1,d0	;Copy
copy_it				
	move.w	(a0)+,(a3)	;the sprite to
	move.w	(a0)+,2(a3)	;the sprite work
	move.w	(a0)+,4(a3)	;area
	move.w	(a0)+,6(a3)
	
	add.l	#16,a3
	dbra	d0,copy_it
	
	lea	work,a3		;Work Area
	move.w	#16-1,d7	;16 copies of sprite
next_sprite
	move.w	#16-1,d6	;16 lines per sprite
next_line
	move.w	(a3),d0		;Create mask 
	or.w	2(a3),d0	;By oring the two planes
	not.w	d0		;and taking the complement
	move.w	d0,(a1)+	;Store mask
	move.w	d0,(a1)+	;in sprite data
	move.w	8(a3),d0	;Get second words from work area
	or.w	10(a3),d0	;do the
	not.w	d0		;same
	move.w	d0,(a1)+	;
	move.w	d0,(a1)+	;Mask stored
	
	move.w	(a3),(a1)+	;Copy work sprite (32x16)
	move.w	2(a3),(a1)+	;into sprite area
	move.w	8(a3),(a1)+	;
	move.w	10(a3),(a1)+	;Sprite data stored

	add.l	#16,a3		;
	dbra	d6,next_line	;Next line of current sprite
	
	**************
	* Now shift! *
	**************
	
	lea	work,a3		;Work area
	move.w	#16-1,d6	;16 lines
shift
	move.l	(a3),d0		;Mask
	move.w	8(a3),d0	;d0 = Word1 Plane 1 | Word2 Plane 1
	lsr.l	#1,d0		;Shift
	move.w	d0,8(a3)	;Replace Word2 Plane 1
	swap	d0		;
	move.w	d0,(a3)		;Replace Word1 Plane 1
	
	move.l	2(a3),d0	;Mask
	move.w	10(a3),d0	;d0= Word1 Plane 2 | Word2 Plane 2
	lsr.l	#1,d0		;Shift
	move.w	d0,10(a3)	;Replace Word2 Plane 2
	swap	d0		;
	move.w	d0,2(a3)	;Replace Word1 Plane 2
	
	move.l	4(a3),d0	;Sprite
	move.w	12(a3),d0	;d0= Word1 Plane 1 | Word2 Plane 1
	lsr.l	#1,d0		;Shift
	move.w	d0,12(a3)	;Replace Word2 Plane 1
	swap	d0		;
	move.w	d0,4(a3)	;Replace Word1 Plane 1
	
	move.l	6(a3),d0	;Sprite
	move.w	14(a3),d0	;d0= Word1 Plane 2 | Word2 Plane 2
	lsr.l	#1,d0		;Shift
	move.w	d0,14(a3)	;Replace Word2 Plane 2
	swap	d0		;
	move.w	d0,6(a3)	;Replace Word1 Plane 2
	
	adda.l	#16,a3
	dbra	d6,shift	;Shift next line
	
	lea	work,a3		;
	dbra	d7,next_sprite	;Do next copy of sprite
	rts

****************************************
;
;Generates character sets required from
;a standard 8x8 font
;
****************************************
;Used for Corkscrew
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


		
		**************
		* The Sprite *
		**************

char		incbin	"\sprite.tec"	;Stored as a 16x16 Character Set!
		
		**************************
		* The background picture *; Main Screen
		**************************
		
		even
pic		incbin	"\pic_pt1.pc1"
picture		equ	pic+34
new_palette	equ	pic+2
pic2		incbin	"\pic_pt2.pc1"
picture2	equ	pic2+34

		********************************
		* The Two 256 byte Sine Tables *
		********************************

		even
				
vertical	incbin	"\table140.dat"
vertical2	incbin	"\table60.dat"

		
m_on		dc.b	$08	;Mouse on
m_off		dc.b	$12,$1a	;Mouse off
	
	
x1		dc.b	0,0	;X,Y Displacements for
y1		dc.b	64,0	;both tables
cx1		dc.b	0,0	;For each sprite
cy1		dc.b	64,0
		ds.w	(nospr-1)*4

Xinc		dc.w	2	;Wave control
Yinc		dc.w	2	;Variables
X2inc		dc.w	1
Y2inc		dc.w	2
XDisp		dc.w	8
YDisp		dc.w	8
X2Disp		dc.w	0
Y2Disp		dc.w	0

spr_wave	dc.l	spr_wave_tab	

*
* Xinc,Yinc,XDisp,YDisp,X2inc,Y2inc,X2Disp,Y2Disp,x1,y1,cx1,cy1
*
* If x1 = $ffff => Ignore x1,y1,cx1,cy1, use old values
*
spr_wave_tab dc.w $fffe,$fffe,$fffe,$fffe,$2,$2,$ffe6,$ffe6,$32,$7f,$4f,$91
 dc.w $0001,$0001,$0040,$0040,$0000,$0000,$0000,$0000,$fb,$3c,$ec,$7f
 dc.w $0001,$0001,$0020,$0020,$0000,$0000,$0000,$0000,$ffff,$0,$0,$0
 dc.w $0001,$0001,$0013,$0013,$0000,$0000,$0000,$0000,$ffff,$0,$0,$0
 dc.w $0001,$fffe,$0009,$0009,$0000,$fff8,$000b,$0013,$44,$18,$00,$58
 dc.w $0002,$fffe,$fffd,$0004,$0005,$fffa,$fffb,$fff6,$fa,$2b,$5f,$33
 dc.w $0003,$ffff,$fff2,$fffd,$0009,$fffd,$fffb,$fff6,$42,$e5,$f7,$c0
 dc.w $0000,$0000,$0000,$0000,$fff9,$0005,$fff9,$0005,$f9,$7c,$76,$e1
 dc.w $0000,$0000,$0000,$0000,$fffe,$fffe,$fff9,$0005,$ffff,$0,$0,$0
 dc.w $0000,$0000,$000a,$000a,$0000,$0000,$0000,$0000,$00,$40,$00,$40
 dc.w $0002,$0002,$000a,$000a,$0000,$0000,$0000,$0000,$ffff,$0,$0,$0
 dc.w $fffe,$fffe,$ffe7,$ffe8,$0002,$0002,$ffe6,$ffe6,$da,$09,$c5,$07
 dc.w $fffe,$fffe,$00e4,$00e3,$0003,$0002,$ffe6,$ffe6,$c0,$0d,$e1,$19
 dc.w $fffe,$fffe,$0068,$0067,$0002,$0002,$ffe6,$ffe6,$aa,$f7,$d7,$19
 dc.w $00fb,$00f9,$ffa8,$ffa6,$fff8,$fffd,$fffb,$fffc,$7f,$07,$09,$b7
 dc.w $fffc,$fffd,$0003,$0004,$fff8,$fffd,$fffb,$fffc,$81,$24,$a9,$f3
 dc.w $fffc,$ffff,$005d,$ffde,$0006,$fff9,$000d,$0011,$96,$1b,$42,$5f
 dc.w $0000,$0000,$0000,$0000,$fffe,$fffe,$fff9,$0005,$00,$75,$99,$ed
 dc.w $0000,$0000,$fffe,$0002,$fffe,$fffe,$fff9,$0005,$ffff,$0,$0,$0
 dc.w $fffd,$fffe,$fffe,$0002,$fffe,$fffe,$fff9,$0005,$ffff,$0,$0,$0
 dc.w $fffe,$fffe,$ffff,$ffff,$0000,$0000,$0000,$0000,$27,$cd,$00,$72 
 dc.w $0000,$0000,$fff2,$fffa,$0006,$fff8,$000d,$fff9,$44,$91,$5a,$17
 dc.w $0000,$0000,$000a,$000a,$0001,$0001,$000a,$000a,$57,$99,$83,$c7
 dc.w $0000,$0000,$000a,$000a,$fffd,$fffd,$000a,$000a,$ffff,0,0,0
 dc.w $0001,$0001,$000a,$000a,$ffff,$ffff,$000a,$000a,$ffff,0,0,0
 dc.w $0001,$0001,$000a,$000a,$fffe,$fffe,$0005,$0005,$25,$68,$ea,$31
 dc.w $fffe,$fffd,$0008,$0008,$0003,$fffc,$fff1,$fffe,$f9,$8f,$73,$e2
 dc.w $0002,$0002,$0008,$0008,$0003,$fffb,$0007,$0018,$5a,$e8,$41,$64
 dc.w $0000,$0004,$0153,$0152,$0000,$fff8,$0007,$0018,$de,$a3,$14,$15
 dc.w $fffd,$0000,$0153,$0152,$fff8,$0000,$0007,$0018,$4d,$7f,$ce,$e1
 dc.w $fffd,$fffc,$0008,$0003,$000a,$fffb,$ffff,$0004,$0c,$a7,$68,$53
 dc.w $0001,$0001,$000a,$000a,$ffff,$ffff,$0014,$0014,$31,$70,$2a,$70
 dc.w $0002,$fffe,$0008,$0008,$fffd,$fffd,$00ea,$00e9,$dd,$e9,$c9,$1c
 dc.w $fffe,$fffe,$0006,$fffc,$0008,$fffa,$ffe8,$0010,$36,$83,$70,$8f
 dc.w $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff

		
		*********************************************
		* Tables for Bounce scroller on main screen *
		*********************************************
		* Each table describe the shape & speed of
		* one bounce, by specifying the screen location
		* of the scroller for each frame.
		*

bounce_tab1	dc.w	0*$a0,0*$a0	
		dc.w	$ffff

bounce_tab2	dc.w	45*$a0,45*$a0	
		dc.w	$ffff

bounce_tab3	dc.w	0*$a0,1*$a0,2*$a0,4*$a0,6*$a0,8*$a0,11*$a0,15*$a0,20*$a0,26*$a0,33*$a0
		dc.w	38*$a0,45*$a0
		dc.w	38*$a0
		dc.w	26*$a0,20*$a0,15*$a0,11*$a0,8*$a0,6*$a0,4*$a0,2*$a0,1*$a0,0*$a0
		dc.w	$ffff

bounce_tab4	dc.w	0*$a0,1*$a0,2*$a0,4*$a0,6*$a0,8*$a0,11*$a0,15*$a0,20*$a0,26*$a0
		dc.w	38*$a0,45*$a0
		dc.w	38*$a0,36*$a0,30*$a0,25*$a0,21*$a0,18*$a0,16*$a0,14*$a0,12*$a0,11*$a0,10*$a0
		dc.w	10*$a0,11*$a0,12*$a0,14*$a0,16*$a0,18*$a0,21*$a0,25*$a0,30*$a0,36*$a0
		dc.w	38*$a0,45*$a0
		dc.w	38*$a0,26*$a0,20*$a0,15*$a0,11*$a0,8*$a0,6*$a0,4*$a0,2*$a0,1*$a0,0*$a0	
		dc.w	$ffff

		
bounce_tab5	dc.w	0*$a0,1*$a0,2*$a0,4*$a0,5*$a0,7*$a0,9*$a0,11*$a0,14*$a0,17*$a0,22*$a0
		dc.w	25*$a0,28*$a0,34*$a0
		dc.w	38*$a0,45*$a0,38*$a0
		dc.w	34*$a0,28*$a0,25*$a0
		dc.w	22*$a0,17*$a0,14*$a0,11*$a0,9*$a0,7*$a0,5*$a0,4*$a0,2*$a0,1*$a0,0*$a0
		dc.w	0*$a0,0*$a0,0*$a0,0*$a0
		dc.w	$ffff

bounce_tab6	dc.w	45*$a0,38*$a0
		dc.w	34*$a0,28*$a0,25*$a0
		dc.w	22*$a0,17*$a0,14*$a0,11*$a0,9*$a0,7*$a0,5*$a0,4*$a0,2*$a0,1*$a0,0*$a0
		dc.w	0*$a0,0*$a0,0*$a0,0*$a0
		dc.w	0*$a0,1*$a0,2*$a0,4*$a0,5*$a0,7*$a0,9*$a0,11*$a0,14*$a0,17*$a0,22*$a0
		dc.w	25*$a0,28*$a0,34*$a0
		dc.w	38*$a0
		dc.w	$ffff
		
		* Colour table used by Main Screen & 
		* Corkscrew scroller
		
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

**************************
* MAIN SCREEN SCROLLTEXT *
**************************

			;CONTROL CODES
nsw	equ	1	;Get next sprite wave
bn1	equ	21	;Bounce 1 : top
bn2	equ	22	;Bounce 2 : bottom
bn3	equ	23	;Bounce 3 : standard bounce
bn4	equ	24	;Bounce 4 : double bounce
bn5	equ	25	;Bounce 5 : glide bounce
bn6	equ	26	;Bounce 5 : glide bounce ( start at bottom )
p1	equ	9	;Pause 1 sec
p3	equ	10	;Pause 3 secs
			;
		
message		
 dc.b bn1,"         FINGERBOBS PRESENT               ",bn2,nsw,"  NEW YEAR DEMO               ",bn1,nsw
 dc.b " CODED BY               ",bn2," OBERJE    ",p1,bn6,p1,"                   ",nsw
 
 dc.b " THIS DEMOS HAS FOUR ADDITIONAL SCREENS....",nsw,bn5,"              1       ",p1,"             "
 dc.b "   THE MUSIC SELECTION SCREEN - "
 dc.b "PRESS 'M' TO ACCESS, USE CURSOR KEYS TO CHOOSE TUNE, AND RETURN TO PLAY IT, GO BACK TO THIS "
 dc.b "SCREEN BY PRESSING SPACE. ",nsw
 
 dc.b "              2       ",p1,"             "
 dc.b "   THE CORKSCREW SCROLLER SCREEN - "
 dc.b "PRESS 'C' TO ACCESS, SIT AND WATCH, PRESS ANY KEY TO RETURN TO THIS SCREEN ",nsw
 
 dc.b "              3       ",p1,"             "
 dc.b "   THE EXTRA BIG SCROLLER SCREEN - "
 dc.b "PRESS 'E' TO ACCESS, SIT AND WATCH, PRESS ANY KEY TO RETURN TO THIS SCREEN ",nsw
 dc.b "              OUR CONTACT ADDRESS IS IN THE BIG SCROLLER    ",nsw
 
 dc.b "              4       ",p1,"             "
 dc.b "   THE WHO ARE THESE PEOPLE SCREEN - "
 dc.b "PRESS 'W' TO ACCESS, USE CURSORS TO SELECT, AND SPACE TO RETURN TO THIS SCREEN ",nsw
 dc.b "              "
 
 dc.b "         "	
 dc.b "      WELL BEFORE I GO ANY FURTHER I'LL JUST WISH THE FOLLOWING PEOPLE A HAPPY NEW YEAR...                   ",nsw
 dc.b bn1," THE CAPED CRUSADER                  "
 dc.b bn2," BRUNO                 "
 dc.b bn1," ROZEL                 ",nsw
 dc.b bn2," TOM                 "
 dc.b bn1," MATTHEW MILES             "
 dc.b bn2," TIM                 "
 dc.b bn1," GORDON COULTER  ( SYSOP OF JUSAVO BB )                 "
 dc.b bn2," MARTIN                 ",nsw
 dc.b bn1," GRAHAME SUPREME OVERLORD OF THE UNIVERSE                 "
 dc.b bn2," FROSTY THE SNOWMAN                "
 dc.b bn1," ARKANGEL                "
 dc.b bn2," JOE 90                "
 dc.b bn1," BOOTS                ",nsw
 dc.b bn2," D.WATT                "
 dc.b bn1," FLASH                "
 dc.b bn2," ORM!                "
 dc.b bn1," ALAN OF THE TARTAN ARMY               "
 dc.b bn2," SPAZ,SPROG,MANIKIN AND SAMMY JOE (THE LOST BOYS)                "
 dc.b bn1," THE UNION                ",nsw
 dc.b bn2," THE EXCEPTIONS                "
 dc.b bn1," THE CAREBEARS               "
 dc.b bn2," AUTOMATION                 ",nsw,"  "
 dc.b bn1," AND EVERYONE ELSE!..........                      ",nsw,"  "
 dc.b bn4,"   "
 DC.B " WELL, WHY DON'T I TELL YOU A BIT ABOUT MYSELF ( OBERJE' )  "
 DC.B "   I AM 19 , INCREDIBLY HANDSOME , AND VERY VERY MODEST..... ",nsw
 DC.B " I HAVE HAD A COMPUTER SINCE I WAS 13, WHEN MY UNCLE ( BLESS HIS LITTLE HEART ) ",nsw
 DC.B " GAVE ME A ZX81 FOR MY BIRTHDAY!,   - THANKS UNCLE! -     I WAS HOOKED! "
 DC.B "     IT WAS A FAITHFUL LITTLE MACHINE, EVEN IF IT DID CRASH ON AVERAGE EVERY 10 MINUTES, "
 DC.B "AND TAKE 3 WEEKS TO TRY TO LOAD A PROGRAM AND THEN FAIL 3 SECONDS BEFORE THE END!  ",nsw
 DC.B "    NEXT ( PREDICTABLY ) CAME THE SPECTRUM, A 48K ONE! AND I ALSO HAD A LOAN OF A BBC B "
 DC.B "FOR A WHILE!   BUT AFTER SEVERAL YEARS, I.E IN 1988 I DECIDED MY SPECTRUM "
 DC.B "DESERVED ITS RETIREMENT, SO I WENT AND BOUGHT AN ST!  WOW  I WAS IMPRESSED! ",nsw
 DC.B " I STARTED PROGRAMMING THE ST IN FAST BASIC, AND THROUGH EXPERIMENTS WITH THE IN-LINE "
 DC.B "ASSEMBLER I CAME TO LEARN SOME 68000 ASSEMBLY CODE, SO I BOUGHT DEVPAC 2 AND THE REST, ",nsw
 DC.B "AS THEY SAY, IS HISTORY......      "
 DC.B "   HAVE YOU NOTICED THAT THIS SCROLLTEXT HAS NO STRUCTURE OR FORM, IT JUST APPEARS "
 DC.B "IN NO SPECIFIC ORDER AT ALL.... WELL ITS BECAUSE I AM JUST WAFFLING, ITS THE EASIEST WAY ",nsw
 DC.B "TO WRITE SCROLLTEXT, JUST START TYPING AND KEEP GOING......HOWEVER ITS 9.15 , AND I THINK "
 DC.B "I'LL JUST BREAK FOR COFFEE........................." ,nsw
 DC.B "BACK!    DAMN! I HAVE JUST REALISED I WILL HAVE TO DEVICE SOME MORE WAVES FOR "
 DC.B " THE SPRITES BECAUSE THIS AMOUNT OF TEXT IS BOUND TO USE UP ALL THE WAVES I HAVE DEFINED "
 DC.B "SO FAR!     OH WELL NEVER MIND........... ",nsw
 DC.B " OH THE BELINDA CARLISLE CD IS FINISHED NOW, I'LL JUST CHANGE IT FOR SOME PROPAGANDA!........"
 DC.B "....DONE!   ""THE MAN WITHOUT SHADOW, PROMISES YOU THE WORLD....""               "
 dc.b "- DR MABUSE -",p3,"                 ",bn1,"  A FAB SONG! "
 DC.B "      I THINK THAT I WILL LET YOU READ THE CAPED CRUSADERS SCROLLTEXT NOW.......        ",nsw
 
*
* Caped Crusader text here!
*

 dc.b " A BIG HAND PLEASE FOR THE CAPED CRUSADER..........                ",nsw   

*-----------------------------------------------*
* The Caped Crusader, Scroll Text for Oberjes...*
* New Year Demo..... (C) T.C.C. 01-01-90........*
*-----------------------------------------------*
 dc.b	bn4
 dc.b	" GREETS THANX TO OBERJE, FOR LETTING ME HAVE THIS SCROLL SPACE. RIGHT WHAT WILL I SAY THEN, WELL I'M LISTENING TO  THE WALL BY PINK FLOYD."
 dc.b	" AND ITS ABOUT 10 TO 8 AND NIGHT ON THE 1ST OF JANUARY 1990, HAPPY NEW YEAR EVERYONE... RIGHT THATS IT BYE............ NO BUT SERIOUSLY THOUGH",nsw
 dc.b	" WHAT AM I DOING, AT THE MOMENT CODING WISE, WELL I'M IN THE MIDDLE OF WRITTING MY NEW DEMO, NOT AS GOOD AS THIS BUT I LIKE IT, ITS CALLED THE"
 dc.b	" S******** DEMO AND HAS LOTS OF GRAFIX AND SOME NICE VERTICAL SCROLLING IT ALSO HAS A FEW SURPRISES IN THE SCROLLTEXT. OTHER THAN THAT ITS JUST A DEMO",nsw
 dc.b	"... WELL BEFORE I FORGET I HAD BETTER SAY HI TO MASTER, MATRIX AND THE LOST BOYZ, WHO HAVE HOPEFULLY FINISHED THEIR NEW YEAR DEMO, WHICH WAS BEING WRITTEN"
 dc.b	" AT THEIR COPY PARTY WHICH LASTED ABOUT 3 OR 4 DAYS. FROM LAST THURSDAY FRIDAY TILL TODAY... I HEARD VARIOUS REPORTS ABOUT IT FROM MATRIX, INSTEAD OF MASTER COZ HE",nsw
 dc.b	" WAS OUT OF HIS SKULL... I WOULD ALSO LIKE TO SAY THAT THE LOSTBOYS NEW DEMO IS GOING TO BE THE BEST WRITTEN THIS NEW YEAR, ITS GOT A FULL SCREEN DEMO,"
 dc.b	" I'M NOT TALKING ABOUT A DEMO LIKE THE CAREBEARS CUDDLY DEMO ONE, THIS ONE SCROLLS THE WHOLE SCREEN ALL THE BORDERS ARE GONE. AND ITS PARALLAX, THE BACKGROUND",nsw
 dc.b	" ISN'T THE SAME CHARACTERS DISPLAYED OVER AND OVER AGAIN. HOLD ON A SEC BACK IN A MO......................................SORRY ABOUT THAT HAD TO GO AND WASH THE"
 dc.b	" DISHES, ITS THE MOST I CAN DO FOR ME FOLKS AT NEW YEAR.... RIGHT HOLD ON WHILE I PUT PINK FLOYD OFF AND PUT THE TV SO I CAN WATCH ROWAN ATKINSON IN MR. BEAN....",nsw
 dc.b	".............MR. BEAN WAS TOTALLY BRILL, I LIKED THE BIT AT THE BEACH BEST.. WITH THE BLIND MAN.... RIGHT WHAT BACK ON WITH PINK FLOYD.....HELLO AGAIN, WHAT WILL I SAY "
 dc.b	" NOW, OH YEAH JUST A QUICK GREET TO THE GUYS ON HACKERNET, BAUDERLINE, MIKE BOURNE, BATMAN, THE JOKER, RUSS PAYNE, ACME AND THE OTHERS, OK.",nsw
 dc.b	" RIGHT LADS I HOPE YOU ENJOY THE DEMO, OK NOW WHAT I KNOW HOW ABOUT ME MENTIONING MY BBS               "
 dc.b	bn1,"  THE BATCAVE  ",p3,"               ",bn2
 dc.b	"   WHAT A NICE NAME EH, WELL ITS FOR ST, AMIGA AND PC OWNERS OUT"
 dc.b	" WHO ENJOY PROGRAMMING, DRAWING GRAFIX AND WRITTING MUSIC, ALSO FOR ALL THE LATEST SOFTWARE AND DEMOS, THERE IS ALSO A SHOP WHERE YOU CAN BUY ALL THE LATEST S/WARE AND",nsw
 dc.b	" HARDWARE, RIGHT,",bn6,"  WHATS THE NUMBER I HEAR YOU CRY, WELL ITS,"
 dc.b	"                 03586 89049  ",p3,"                  AND ITS TIMES ARE THE FOLLOWING, WEEKNIGHTS FROM 10:00 PM TO 8:45 NEXT DAY, EXCEPT ON"
 dc.b	" FRIDAYS WHEN IT RUNS FROM 7:30PM TO MONDAY 8:45AM... SO IF YA GOT A MODEM THEN GIVE US A BELL, IT RUNS AT 2400/1200 ALL SPEEDS...SO PLEASE PHONE... ANYWAY THATS",nsw
 dc.b	" ALL I CAN THINK OF JUST NOW SO I'LL POP OFF AND POP BACK LATER................I'M BACK JUST TO SAY THAT I AM A BIG HEADED SON OF A BITCH, COS I RIPPED MOST OF THE"
 dc.b	" OF THE MUSIC FOR THIS DEMO, IE. SPEEDBALL, MR HELI, PLATOON, WEIRD DREAMS, VERMINATOR, OBLITERATOR, THE EMPIRE STRIKES BACK, XENON II, THE TUNE, CUSTODIAN, STARRAY,",nsw
 dc.b	".                 ",bn3," ALSO SINCE I DID THE FIRST PART OF THE SCROLL TEXT I'VE SEEN MOST OF THE DEMO IT SELF AND WHAT CAN I SAY  "
 dc.b	"        OBERJE HAS EXCELED HIMSELF,          THE EXTRA BIG SCROLLER IS TOTALLY MEGA, AND BIG!!!!!        WHAT ELSE, THE MUSIC SELECTION SCREEN IS VERY NICE I LIKE THOSE BOBS (THE FINGER BOBS",nsw
 dc.b	" THAT IS) WHAT ELSE, WELL THERE IS A WHOLE LOT OF OTHER EXCITING THINGS. OH YEAH AND I'VE ALSO SEEN A DEMO TO THE LOST BOYS MINDBOMB DEMO AND WHAT CAN I SAY, BUT THOSE"
 dc.b	" VECTOR BALLS AR AMAZING. COME OBERJE, YOU CAN DO BETTER. (I THINK) NA OF COURSE HE CAN. RIGHT I HAD BETTER SIGN OFF ACTUALLY COS THATS ABOUT 4K I'VE JUST TYPED IN AND",nsw
 dc.b	" I'VE GOT SORE FINGERS. OH WELL I THINK OF ANY MORE I'LL BE BACK..........OH BEFORE I GO HAS ANYONE SEEN 'THE NINJA WARRIORS' YET IT IS PROBABLY THE BEST ARCADE CONVERSION"
 dc.b	" I'VE EVER SEEN IN MY WHOLE LIFE. WELL ABOUT THE SAME QUALITY AS SUPER HANG-ON. OK, I'M OFF...BYE... SE YA IN THE NEXT DEMO WHICH WILL PROBABLY BE MY SPEEDBALL DEMO.",nsw
 dc.b	" DUE FOR RELEASE WITHIN THE NEXT MONTH.. OK AND DON'T FORGET THAT THERE IS A MULTI-TUDE OF DEMOS COMING OUT THIS MONTH (JANUARY). SO THERE WILL BE PLENTY FOR YOU TO"
 dc.b	" READ, LISTEN TOO AND WATCH OVER THE COMING WEEKS..... TOOO DAAAA LOOOOOO..............THE ONE AND ONLY CAPED CRUSADER.....TIME IS 11:40 ON THE NIGHT OF THE 9TH OF",nsw
 dc.b	" JANUARY 1990......................."
  
*
*
*
 dc.b "                  ",bn5,"   "
 dc.b "YIPPE, THIS IS OBERJE BACK AT THE HELM, WELL TCC HAD QUITE A BIT TO SAY, RATHER MORE THAN I HAD ACTUALLY "
 dc.b "SUSPECTED, I JUST SAID WRITE SOME SCROLLTEXT....AND HE DID!       AMAZING......     ",nsw
 dc.b " AND NOW AS A SPECIAL TREAT I'M GOING TO SHOW YOU THE SCROLLTEXT I WROTE "
 dc.b "ON NEW YEARS WHEN I WAS DRUNK!................   ",nsw,bn3,"  "

 dc.b " YES!, HERE IT IS !..................OFFICIAL NEW YEAR SCROLLTEXT , I.E I'M JUST A LITTLE "
 DC.B "BIT PISSED!, WELL QUITE A BIT ACTUALLY, IN FACT THIS TYPING MALARKY IS PROVING TO BE DIFFICULT "
 DC.B "AND I HAVE MADE MANY CORRRECTIONS ALREADY!        PEACH SCHNAPS",p1,"  THATS WHAT IT IS MATEY, ITS BLOODY "
 DC.B "BRUTAL!  TASTES LIKE FRUIT JUICE, WASTES THE BRAIN PRETTY QUICK!..............",nsw
 DC.B "WELL THE TIME IS 1.56 ON 1/1/90 AND I'M IN MY BEDROOM WITH BRUNO WAITING FOR SOME "
 DC.B "OF MY FRIENDS TO APPEAR.......................WILL THEY COME ,  GOOD QUESTION...........WELL IT "
 DC.B "IS POSSIBLE, BUT SEVERAL PLANS FOR THE CELEBRATION HAVE FALLEN THROUGH ALREADY,   WHERE THE HELL IS "
 DC.B "MARK THATS WHAT I WANT TO KNOW, HE SAID HE'D BE HERE AT 10PM, HES PRETTY LATE, PROBABLY BOGGED OFF ",nsw
 DC.B "TO ABERDEEN INSTEAD THE COMPLETE POOP!  OH OH ITS 2 NOW!    GOSH, THAT MEANS THAT THE COUNT AND "
 DC.B "HIS FRIENDS ARE LATE!    LOOKS LIKE I'LL HAVE TO FINISH THE SCHNAPPS MEESELF!..............."
 DC.B "OH NOT FORGETTING BRUNO!....................             "
 DC.B "      OH OH ITS THE DOOR, ITS MY SISTER AND .............. SHE IS WASTED! , WHOA!           ",nsw
 DC.B "  SHE SAYS SHE HAS JUST BEEN PUKING UP AND FALLS ASLEEP ON MY BED,   THATS HANDY............."
 DC.B "       YEP,      SHES WASTED,  OH OH "
 DC.B " SHES WOKEN UP AGAIN............AND NOW SHES RUNNING FOR THE BATHROOM.........BRROOUGHAARGH!..."
 DC.B "     YUK!    ",nsw
 DC.B "RING RING, RING RING...........THAT WAS THE COUNT ON THE PHONE!,     HIS HOUSE 15 MINUTES - PARTY!"
 DC.B "       YEAHH!  GORRA GO, ILL FINISH THIS TEXT TOMORROW!          "
 DC.B "             1ST OF JANUARY 1990,   THE TIME IS NOW 3.15 ( IN THE AFTERNOON ), I HAVE JUST"
 DC.B " WOKEN UP, I DIDNT GET TO MY BED UNTIL 6.15 IN THE MORNING........ I FEEL FAIRLY OK,  "
 DC.B "A LITTLE BIT QUEEZY, BUT I THINK I COULD HANDLE SOME BREAKFAST!             THE PARTY!    "
 DC.B "WELL WE ALL DANCED ABOUT THE COUNTS BEDROOM TO THE SOUND OF DURAN DURAN RECORDS ( AND SOME ",nsw
 DC.B "PROPAGANDA AND SOME FRONT 242 ! ) AT ABOUT THREE QUARTERS OF HIS STEREOS 80 WATTS!   "
 DC.B "       HIS PARENTS CAME INTO THE ROOM AND MADE FOOLS OF THEMSELVES BY SAYING ARENT WE ULTRA "
 DC.B "TRENDY AND DANCING ABOUT TO ULTRA MODERN ELECTRONIC MUSIC, ESPECIALLY SINCE THEY USUALLY ONLY "
 DC.B "LISTEN TO CRAP LIKE 'WEE JEANIE MCCOL' !!!!   STILL WE GOT RID OF THEM PRETTY QUICK AND BACK ",nsw
 DC.B "TO SOME REAL CELEBRATION!"

 DC.B " HMMMMM    WELL, I WAS DRUNK!..........           "
 
 DC.B " WATCH OUT FOR MORE FINGERBOBS ST DEMOS, THERE ARE BOUND TO BE SOME!       "
 DC.B "     "
 
 dc.b "                  AND NOW I'M AFRAID WE MUST WRAP THE SCROLLER! BOO HOO , SOB , ETC....             "
 dc.b " BUT DON'T WORRY THERE IS SOME MORE TEXT IN THE OTHER SCREENS!                  "

 DC.B 0

	
	even
		
		***********************
		* 24x16 Character Set *
		***********************
		
char_set	incbin	"\1plane.ajb"

here		ds.l	1
slice		ds.b	1		

		even

		even
		
track		ds.l	1	;Track on display
playing		ds.l	1	;Current Track

*******************************************
* Letter Table for Music Selection Screen *
*******************************************

letter1		dc.w	000,0*16
		dc.w	025,1*16
		dc.w	050,2*16
		dc.w	075,3*16
		dc.w	100,4*16
		dc.w	125,5*16
		dc.w	150,6*16
		dc.w	175,7*16
		dc.w	200,8*16
		dc.w	225,9*16

letter_cols	dc.w	$700,$710,$720,$730	Red -> Yellow
		dc.w	$740,$750,$760,$770
		dc.w	$671,$572,$473,$374	Yellow -> Cyan
		dc.w	$275,$176,$077
		dc.w	$067,$057,$047,$037	Cyan -> Blue
		dc.w	$027,$017,$007
		dc.w	$107,$207,$307,$407	Blue -> Purple
		dc.w	$507,$607,$707
		dc.w	$706,$705,$704,$703	Purple -> Red
		dc.w	$702,$701,$700
end_cols	equ	*		
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

sky_cols	dc.w	$267
		dc.w	$267
		dc.w	$367
		dc.w	$367
		dc.w	$567
		dc.w	$567
		dc.w	$667
		dc.w	$667
		dc.w	$767
		dc.w	$767
		dc.w	$767
		dc.w	$667
		dc.w	$667
		dc.w	$567
		dc.w	$567
		dc.w	$367
		dc.w	$367
		dc.w	$267
		dc.w	$267
		dc.w	$077
		dc.w	$077
		dc.w	$166
		dc.w	$166
		dc.w	$165
		dc.w	$165
		dc.w	$265
		dc.w	$265
		dc.w	$264
		dc.w	$264
		dc.w	$363
		dc.w	$363
		dc.w	$226
water		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226
		dc.w	$226

mus_pic		incbin	"\loader.pi1"
mus_picture	equ	mus_pic+34
mus_palette	equ	mus_pic+2

	even
	
track_names	
	dc.b	"COSMIC PIRATE #1    "
	dc.b	"COSMIC PIRATE #2    "
	dc.b	"COSMIC PIRATE #3    "
	dc.b	"COSMIC PIRATE #4    "
	dc.b	"RENEGADE            "
	dc.b	"MR HELI #1          "
	dc.b	"MR HELI #2          "
	dc.b	"MR HELI #3          "
	dc.b	"MR HELI #4          "
	dc.b	"MR HELI #5          "
	dc.b	"THUNDERCATS         "
	dc.b	"WARHAWK             "
	dc.b	"XENON #1            "
	dc.b	"XENON #2            "
	dc.b	"XENON #3            "
	dc.b	"RAMPAGE #1          "
	dc.b	"RAMPAGE #2          "
	dc.b	"LEATHERNECK #1      "
	dc.b	"LEATHERNECK #2      "
	dc.b	"OUTRUN #1           "
	dc.b	"OUTRUN #2           "
	dc.b	"GOLDRUNNER II #1    "
	dc.b	"GOLDRUNNER II #2    "
	dc.b	"ENDURO RACER #1     "
	dc.b	"ENDURO RACER #2     "
	dc.b	"ENDURO RACER #3     "
	dc.b	"RETURN 2 GENESIS    " <-- Max Length ( 17 Chars! ) 
	dc.b	"SPEEDBALL #1        "
	dc.b	"SPEEDBALL #2        "
	dc.b	"SPEEDBALL #3        "
	dc.b	"SPEEDBALL #4        " 
	dc.b	"SPEEDBALL #5        " 
	dc.b	"SPEEDBALL #6        " 
	dc.b	"SPEEDBALL #7        " 
	dc.b	"WEIRD DREAMS #1     "
	dc.b	"WEIRD DREAMS #2     "
	dc.b	"WEIRD DREAMS #3     "
	dc.b	"WEIRD DREAMS #4     "
	dc.b	"VERMINATOR #1       "
	dc.b    "VERMINATOR #2       "
	dc.b    "VERMINATOR #3       "
	dc.b    "VERMINATOR #4       "
	dc.b    "VERMINATOR #5       "
	dc.b    "VERMINATOR #6       "
	dc.b    "STAR RAY #1         "
	dc.b    "STAR RAY #2         "
	dc.b    "STAR RAY #3         "
	dc.b    "STAR RAY #4         "
	dc.b	"CUSTODIAN #1        "
	dc.b	"CUSTODIAN #2        "
	dc.b	"CUSTODIAN #3        "
	dc.b	"CUSTODIAN #4        "
	dc.b	"CUSTODIAN #5        "
	dc.b	"CUSTODIAN #6        "
	dc.b	"OBLITERATOR #1      "
	dc.b	"OBLITERATOR #2      "
	dc.b	"OBLITERATOR #3      "
	dc.b	"OBLITERATOR #4      "
	dc.b	"PLATOON #1          "
	dc.b	"PLATOON #2          "
	dc.b	"PLATOON #3          "
	dc.b	"PLATOON #4          "
	dc.b	"PLATOON #5          "
	dc.b	"PLATOON #6          "
	dc.b	"PLATOON #7          "
	dc.b	"EMPIRE #1           "
	dc.b	"EMPIRE #2           "
	dc.b	"EMPIRE #3           "
	dc.b	"EMPIRE #4           "
	dc.b	"EMPIRE #5           "
	dc.b	"EMPIRE #6           "
	dc.b	"EMPIRE #7           "
	dc.b	"EMPIRE #8           "
	dc.b    "MILLENIUM 2.2       "
	dc.b	"XENON II            "
	dc.b	"-* THE END *-       "

	even
	
	*************************
	* Graphics for VU Meter *
	*************************	
vol_data	
	dc.w	$ff00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ff00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ff00,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ff00,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ff00,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$0000,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ff00,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$0000,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ff00,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$0000
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ff00
	dc.w	$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
	

sine_table	
	DC.B	$4B,$49,$47,$46,$44,$43,$41,$3F
	DC.B	$3E,$3C,$3B,$39,$38,$36,$35,$33
	DC.B	$32,$30,$2F,$2D,$2C,$2A,$29,$28
	DC.B	$26,$25,$24,$22,$21,$20,$1F,$1E
	DC.B	$1C,$1B,$1A,$19,$18,$17,$16,$15
	DC.B	$14,$13,$13,$12,$11,$10,$10,$F
	DC.B	$E,$E,$D,$D,$C,$C,$B,$B
	DC.B	$B,$A,$A,$A,$A,$A,$A,$A
	DC.B	$A,$A,$A,$A,$A,$A,$A,$B
	DC.B	$B,$B,$C,$C,$C,$D,$D,$E
	DC.B	$F,$F,$10,$11,$11,$12,$13,$14
	DC.B	$15,$16,$17,$18,$19,$1A,$1B,$1C
	DC.B	$1D,$1E,$1F,$21,$22,$23,$24,$26
	DC.B	$27,$28,$2A,$2B,$2C,$2E,$2F,$31
	DC.B	$32,$34,$35,$37,$38,$3A,$3B,$3D
	DC.B	$3F,$40,$42,$43,$45,$46,$48,$4A
	DC.B	$4B,$4D,$4F,$50,$52,$53,$55,$56
	DC.B	$58,$5A,$5B,$5D,$5E,$60,$61,$63
	DC.B	$64,$66,$67,$69,$6A,$6B,$6D,$6E
	DC.B	$6F,$71,$72,$73,$74,$76,$77,$78
	DC.B	$79,$7A,$7B,$7C,$7D,$7E,$7F,$80
	DC.B	$81,$82,$83,$84,$84,$85,$86,$86
	DC.B	$87,$88,$88,$89,$89,$89,$8A,$8A
	DC.B	$8A,$8B,$8B,$8B,$8B,$8B,$8B,$8B
	DC.B	$8B,$8B,$8B,$8B,$8B,$8B,$8B,$8A
	DC.B	$8A,$8A,$89,$89,$88,$88,$87,$87
	DC.B	$86,$85,$85,$84,$83,$82,$82,$81
	DC.B	$80,$7F,$7E,$7D,$7C,$7B,$7A,$79
	DC.B	$77,$76,$75,$74,$73,$71,$70,$6F
	DC.B	$6D,$6C,$6B,$69,$68,$66,$65,$63
	DC.B	$62,$60,$5F,$5D,$5C,$5A,$59,$57
	DC.B	$56,$54,$52,$51,$4F,$4E,$4C,$4B

*********************
* The Music Modules *
*********************
	
	even  
	
*m4	incbin	"b:\m4.dat"		;Pos Independant
*
*m4_int	equ	m4+$e

	even
	
*m9	incbin	"b:\m9.dat"		;Pos Independant
*
*m9_int	equ	m9+$e

	even

*m10	incbin	"\m10.dat"		; "
*
*m10_int	equ	m10+$e

	even
	
*m11	incbin	"\m11.dat"		; "
*
*m11_int	equ	m11+$e

	even
	
*m12	incbin	"\m12.dat"		; "
*
*m12_int	equ	m12+$e

	even

*m13	incbin	"\m13.dat"		; "
*	
*m13_int	equ	m13+$e

	even

*m14	incbin	"\m14.dat"		; "
*	
*m14_int	equ	m14+$e

	even

*m15	incbin	"\m15.dat"		; "
*	
*m15_int	equ	m15+$e

	even

*m16	incbin	"\m16.dat"		; "
*	
*m16_int	equ	m16+$e

	even

*m17	incbin	"\m17.dat"		; "
*	
*m17_int	equ	m17+$e

	even

*m18	incbin	"\m18.dat"		; "
*	
*m18_int	equ	m18+$e

	even

*m19	incbin	"\m19.dat"		; "
*	
*m19_int	equ	m19+$e

	even
	
*mx	incbin	"\tlb.dat"		; All the Power Demo tunes ! 
					; Hope you dont mind TLB !
	even

	****************************************
	* Character Set for Corkscrew Scroller *
	****************************************
		
in_set	incbin	"b:\blocky8.tfb"	;8x8 Char Set ( 640 bytes )
	
	
large_set	ds.b 8*$a0	;Blank area
data		ds.b 32000	;Diagonal Scroll workspace

; Bouncy Scroll
scroll_data	ds.b	$a0*17
put_data	equ	scroll_data+$99

		even
	
	******** CORKSCREW SCROLLER *********
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
	
;***** CORKSCREW ********
;
; The Scrolly message
; Ends at label : scroll_end
;
scrolltext 
	DC.B "                                              "
	dc.b " THE ST CORKSCREW SCROLLER              BY THE "
	dc.b "FINGERBOBS          "
	DC.B "        CODED BY OBERJE ( ME! ).         INSPIRED BY THE CORKSCREW SCROLLER"
	DC.B " IN THE VORTEX 42 MEGADEMO 2 ON THE AMIGA!             "
	
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
	DC.B "   SADLY I FAILED MISERABLY TO GET OTHER PEOPLE TO WRITE SCROLLTEXT IN "
	DC.B "THIS DEMO, THE CAPED CRUSADER DEMANDED ( YES, DEMANDED! ) SCROLLTEXT SPACE"
	DC.B " IN THIS DEMO, BUT NOBODY ELSE GIVES TWO JOTS OF A TURTLES WILLY!      "
	DC.B " WHO ARE THE FINGERBOBS ?             WELL THE FINGERBOBS ARE "
	DC.B "         OBERJE ( ME! ) , I DO JUST ABOUT ALL THE ST CODING/GRAPHIX/SOUND ETC "
	DC.B "        THE CREEPER , HE IS QUITE QUITE MAD, AND WRITES MOST OF THE "
	DC.B " AMIGA CODE, BUT DOES GRAPHICS AND SOUND TOO.          THE COUNT , "
	DC.B " DOES A BIT OF EVERYTHING.          ZEN , DOES SOME GRAPHIX AND SOUND"
	DC.B " ON AMIGA.               SHADES , DOES AMIGA MUSIC AND GRAPHICS AND WILL MOVE ONTO CODING WHEN HE CAN "
	DC.B "BE BOTHERED TO SIT DOWN AND LEARN 68000!              "
	DC.B "            IF YOU'VE GOT A REALLY STRONG STOMACH YOU CAN ACTUALLY SEE WHAT "
	DC.B "WE LOOK LIKE IN THE 'WHO ARE THESE PEOPLE?' SCREEN, EXCEPT FOR SHADES, 'COS WE"
	DC.B " COULDN'T FIND HIM WHILE WE HAD THE VIDEO CAMERA! SO WE DECIDED TO DIGITISE "
	DC.B "SOMETHING ON HIS BEHALF.....FIRST WE DID SOME TENNENTS LAGER CANS,      BUT THE"
	DC.B " RESEMBLENCE WAS MINIMAL, NEXT WE TRIED A SMIRNOFF BOTTLE, THAT LOOKED MORE LIKE HIM!, "
	DC.B "THEN THE CREEPERS ( FAMOUS ) OVERFLOWING ASHTRAY BUT ALAS IT TOO WAS NOT A GOOD LIKENESS, "
	DC.B "FINALLY WE DIGITISED A LITTLE BUST THINGY, IT STILL WASN'T A GOOD MATCH , BUT AT LEAST "
	DC.B "THEY BOTH LOOK STUPID.................OOPS!   I DIDN'T SAY THAT!       I DON'T SLAG OFF "
	DC.B "MEMBERS OF MY OWN GROUP!      HMMMMM      OH MY LOVE, ITS YOU THAT I DREAM OF, OH MY LOVE, "
	DC.B "SINCE THAT DAY, SOMEWHERE IN MY HEART I'M ALWAYS, DANCING WITH YOU IN THE SUMMER RAIN......"
	DC.B "    OH SORRY,   CAN'T HELP SINGING ALONG WITH BELINDA CARLISLE!    IT IS 9.00PM EXACTLY ON "
	DC.B " THE NIGHT BEFORE THIS DEMOS RELEASE DATE!   JUST SOME TWEAKING TO DO, AND MASSES OF SCROLLTEXT "
	DC.B " I THINK THERE IS ENOUGH TEXT FOR THIS SCREEN, I JUST HAVE TO DO SOME MORE TEXT FOR THE "
	DC.B "MAIN SCREEN BOUNCY SCROLLER        HERE IS OUR CONTACT ADDRESS AGAIN     OBERJE,  6 CARRON TERRACE, "
	DC.B "STONEHAVEN, AB3 2HX,        WRITE TO SWAP DEMOS, CHAT , WHATEVER!       "
	DC.B "  OH WELL END OF SCROLLER, LETS JUST WATCH SOME DOTS BEFORE "
	DC.B "WE LOOP ................................."          
	DC.B ".........................................."
	dc.b "                                      "
scroll_end	DC.B 0
	
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


	even
	
crk_pic		incbin	"b:\corkpic3.pc1"	;Picture
crk_picture	equ	crk_pic+34
crk_cols	equ	crk_pic+2
	

letter_save	ds.l	10
do_cols		ds.l	1
at3		ds.l	1
at		ds.l	1
	
stopped		ds.b	1
stopleft	ds.b	1

		even


do_cols2	ds.l	1
at2		ds.l	1
wait		ds.w	1
nlines		ds.w	1

curr_bounce	ds.l	1	;Address of current bounce table
bounce_at	ds.l	1	
at_sprite	ds.l	1
	
work		ds.b	8*32	;Work Area
sprite_data	ds.b	4096	;Sprite Data

old_spr1	ds.l	nospr
old_spr2	ds.l	nospr

old_sprites	ds.l	1	;Addresses of old sprites 1
other		ds.l	1	;Addresses of old sprites 2

oldpos		ds.l	1
scrollpos	ds.l	1

screen_1	ds.l	1
screen_2	ds.l	1

set_0	ds.b 60*2*8	;Storage for the  \
set_1	ds.b 60*2*8	;Character sets   / CORKSCREW
set_2	ds.b 60*2*8
set_3	ds.b 60*2*8
set_4	ds.b 60*2*8
set_5	ds.b 60*2*8
set_6	ds.b 60*2*8
set_7	ds.b 60*2*8

Table	ds.l	1	;Current Tables address
set	ds.l	1	;Current Sets address
count	ds.w	1	;Current pixel
crkscrl	ds.l	1	;Current position in scrolltext
lines	ds.w	1
	
	even
	
	**************
	* 16x16 Font *
	**************
	
sixteen	incbin	"\single16.tfb"
orig_set	equ	sixteen	;For big scroller
	
	even
	
music_credits dc.b "                    ",13,10
 dc.b "  THE MUSIC SCREEN  ",13,10
 dc.b "                    ",13,10
 dc.b "   MUSIC HACKS BY   ",13,10
 dc.b "      OBERJE        ",13,10
 dc.b "   CAPED CRUSADER   ",13,10
 dc.b "                    ",13,10
 dc.b " READ MAIN SCROLLING",13,10
 dc.b " MESSAGE FOR KEYS   ",13,10
 dc.b "                    ",13,10
 dc.b "                    ",13,10
 dc.b "   PRESS ANY KEY    ",13,10
	
	even
	
cork_credits dc.b "                    ",13,10
 dc.b " CORKSCREW SCROLLER ",13,10
 dc.b "                    ",13,10
 dc.b "     BY OBERJE      ",13,10
 dc.b "                    ",13,10
 dc.b "                    ",13,10
 dc.b "INSPIRED BY SCROLLER",13,10
 dc.b "ON AMIGA IN THE DEMO",13,10
 dc.b "BY VORTEX 42        ",13,10
 dc.b "                    ",13,10
 dc.b "                    ",13,10
 dc.b "   PRESS ANY KEY    ",0
	
	even
	
person_credits dc.b "                    ",13,10
 dc.b "WHO ARE THESE PEOPLE",13,10
 dc.b "                    ",13,10
 DC.B "                    ",13,10
 dc.b "THEY ARE FINGERBOBS ",13,10
 dc.b "LOOKING SEXY,  THEY ",13,10
 dc.b "ALWAYS DO!          ",13,10
 dc.b "                    ",13,10
 dc.b "  USE CURSOR KEYS   ",13,10
 dc.b "   SPACE TO EXIT    ",13,10
 dc.b "                    ",13,10
 dc.b "   PRESS ANY KEY    ",0
	
	even
		
big_credits dc.b "                    ",13,10
 dc.b "       EXTRA        ",13,10
 dc.b "    BIG SCROLLER    ",13,10
 dc.b "                    ",13,10
 dc.b "     BY OBERJE      ",13,10
 dc.b "                    ",13,10
 dc.b "                    ",13,10
 dc.b "                    ",13,10
 dc.b "                    ",13,10
 dc.b "                    ",13,10
 dc.b "                    ",13,10
 dc.b "   PRESS ANY KEY    ",0
	
	even
	
finished dc.l	1	
scween	ds.l	1
person	ds.w	1

	even
	
pic1	incbin	"b:\andrew.pc1"		;Picture File
p1data	equ	pic1+34			;Picture Data
p1pal	equ	pic1+2			;Palette info.

	even
		
ppic2	incbin	"b:\paul.pc1"		;Picture File
p2data	equ	ppic2+34		;Picture Data
p2pal	equ	ppic2+2			;Palette info.

	even
		
pic3	incbin	"b:\graham.pc1"		;Picture File
p3data	equ	pic3+34			;Picture Data
p3pal	equ	pic3+2			;Palette info.

	even
		
pic4	incbin	"b:\colin.pc1"		;Picture File
p4data	equ	pic4+34			;Picture Data
p4pal	equ	pic4+2			;Palette info.

	even
		
pic5	incbin	"b:\dave.pc1"		;Picture File
p5data	equ	pic5+34			;Picture Data
p5pal	equ	pic5+2			;Palette info.

	even
	
	***************************************
	* The Digi-picture Scrolling Captions *
	***************************************
	
ptext1	dc.b " OBERJE                       THE MAN WITH THE HAT!              ST MEGA-CODING, GRAPHIX, SAMPLING,  ETC.....          "
	dc.b "        HI!, WELL AS YOU HAVE VERY PROBABLY FIGURED OUT, WE MANAGED TO GET HOLD OF A VIDEO CAMERA! WHAT A WASTE OF TIME "
	DC.B " THAT WAS, WE SPENT MOST OF THE TIME VIDEO-ING FAG PACKETS, AND BEER CANS.  THE PICTURES WE DIGITISED ON THE CREEPERS "
	DC.B " AMIGA USING VIDI-AMIGA ( OR SOMETHING?! )  , THE CAMERAMAN WAS OUR GOOD FRIEND ..... JAMES!      "
	DC.B "       THEY MADE ME TAKE THE TINSEL OFF MY HAT            B*****DS!         I'M NOT SWEARING SINCE I DECIDED "
	DC.B "TO WRITE THIS DEMO USING 'NUTRASWEAR' WHICH WAS INVENTED BY FLASH! THE EDITOR OF 'THE SCUMDAY SPORT' ON MY COLLEGES "
	DC.B "SUN MINI-COMPUTER! WELL FLASH! I WISH YOU ALL THE BEST RESURRECTING 'SCUMDAY SPORT' AFTER ITS HURRIED ABOLITION, "
	DC.B " DURING THE 'OBSCENE E-MAIL SCANDAL' OF '89 !!!         "
	DC.B " A MESSAGE TO D.WATT IF YOU ARE READING THIS!         'GET YOURSELF A HANDLE SO I DON'T HAVE TO GREET YOU AS D.WATT IN DEMOS!'   "
	DC.B "       AND THE SAME APPLIES TO YOU M.MILES!!!!         "
	dc.b "                                     ",0

	even

ptext2  dc.b " THE CREEPER                  'I SMOKE TABS, ME!'           AMIGA CODING, GRAPHIX, MUSIC ETC.....              "
	DC.B "            I.M IN LIVERPOOL RIGHT NOW, SO I CAN'T WRITE ANYTHING.... NOT EVEN THIS!.............   "
	dc.b "                                     ",0

	even
	
ptext3  dc.b " THE COUNT                     '1...2...3...4... EHHH?!!           SHIT!!!!!               AMIGA CODING,GRAPHIX, MUSIC ETC.......           "   
	DC.B "                        YIBBLE!               "
	dc.b "                                     ",0
	
	even
	
ptext4	dc.b " ZEN                        NOTHING TO DO WITH BUDDA!               AMIGA GRAPHIX, MUSIC ETC......         "
	DC.B "           GEE, DOSEN'T HE LOOK FOREIGN, GERMAN OR SWEDISH, OR MAYBE EVEN DUTCH!                "
	DC.B "      BUT NO, HE ISN'T"         "
	dc.b "                                     ",0

	even
	
ptext5  dc.b " SHADES                     GOOD LIKENESS     PAH!                    AMIGA MUSIC MASTER, GRAPHICS WIZARD AND PROGRAMMER TO BE..........          "
	dc.b "                                     ",0

	even
	
txt_addr	ds.l	1	;Start address of message
phere		ds.l	1	;Pointer to current char in message
this_char	ds.b	8	;Copy of current char ( Bit-map )
pslice		ds.w	1	;Count of pixels in current char shown
pscrl_data	ds.l	1	;Address of start of scroll area

bslice		ds.w	1	;Slice counter for Big scroller
	
	even
	
	*************************
	* Big Scroll Scrolltext *
	*************************
	
bigtext dc.b "   "
	dc.b "FINGERBOBS BIG SCROLLER SCREEN    "
	dc.b "    TO CONTACT FINGERBOBS WRITE TO  "
	DC.B "OBERJE, 6 CARRON TERRACE,  STONEHAVEN,  AB3 2HX.   "
	dc.b " WELL ISN'T THIS SIMPLY THE BIGGEST SCROLLER YOU'VE "
	dc.b "SEEN ON THE HUMBLE 'OL ST ?....NO?..... WELL PERHAPS NOT, "
	dc.b "IT IS CERTAINLY THE BIGGEST I'VE EVER SEEN! ITS HUGE! ITS GINORMOUS! "
	DC.B "ITS LARGE!...  "
	DC.B "I SHOULD IMAGINE THAT YOUR EYES ARE QUITE SORE BY NOW, UNLESS YOU ARE"
	DC.B " STANDING ABOUT 4-5 METRES AWAY! "
	DC.B "......""FINGERBOBS, CHEWY-ER THAN A MULTI-STOREY BUILDING""...."
	DC.B "NOW A BULLETIN BOARD AD... JUSAVO - 0324 32414 - V21,V23 MNP PERHAPS?, "
	DC.B "V22? HE JUST CHANGED HIS MODEM! I DONT KNOW WHAT IT DOES! - 0324 32414 - "
	DC.B " CALL UP, LOOK AROUND, DOWNLOAD STUFF, THE USUAL THINGS!  "
	DC.B " HAVE YOU SEEN ""WHEN HARRY MET SALLY"" YET?, IT IS A FANTASTICALLY "
	DC.B "BRILLIANT FILM, IT IS EXCELLENT!, WATCH IT AT ONCE! "
	dc.b " I AM LISTENING TO ""DEF,DUMB AND BLONDE"" BY DEBBIE HARRY JUST NOW, "
	DC.B "ITS HURTING MY HEAD I THINK ILL CHANGE IT FOR SOMETHING ELSE...."
	DC.B "..AHH THATS BETTER BELINDA CARLISLE!.....WELL ITS THE EVE OF THIS "
	DC.B "DEMOS RELEASE, SO ID BETTER GO WRITE SOME SCROLLTEXT FOR THE OTHER "
	DC.B "SCROLLERS! "
	DC.B " I'M  DONE HERE SO I'LL JUST SAY   THE BLUE RONDO CREW ARE A BUNCH"
	DC.B " OF LAMER B*****DS!   THERE SAID IT! "
	dc.b "NOW LETS WRAP ( OR LOOP, IF YOU"
	DC.B " PREFER )..... ->     "
	dc.b 0  
	
	even
	
big_cols dc.w $0,$777,$777,$777
	dc.w $777,$777,$777,$777
	dc.w $777,$777,$777,$777
	dc.w $777,$777,$777,$777

	even

text_ptr	ds.l	1
buffer		ds.b	40*16

vector_store	ds.b	4
		ds.l	3
old_physbase	ds.l	1
old_res		ds.w	1	
old_palette	ds.w	16
old_stack	ds.l	1
colour		ds.w	1
		ds.l	100
ustack		ds.l	1

screen_area1	ds.b	1
screen_area2	equ	screen_area1+45000


***********
* THE END *
***********

; No doubt there will be more.................

		



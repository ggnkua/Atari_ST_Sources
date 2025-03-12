; THE NEW ORDER MENU SOURCE CODE
; ALL CODE IS COPYRIGHT 1990 BY THE CAMEL (KARL)
; CORE MEMBERS OF THE GROUP ARE :-
; THE CAMEL
; THE BALD EAGLE
; DEREK M.D. AND BECKY
; PLEASE NOTE THAT THIS CODE HAS A 32*32 SCROLLER FITTED
; THIS VERSION NOW USES MOVEP AND NO LONGER HAS THE SPEED UP/DOWN
; THIS IS RATHER LESS TIME INTENSIVE THAN BEFORE
; 50/60 Hz. NOW CHANGES BACKGROUND COLOUR ON RASTER BAR
; SCROLLER CAN CHANGE SPEED USING + & -
; SCROLLER CAN ALSO BE MADE TO PAUSE BY INSERTING A @ IN THE TEXT
; THE VARIABLE BELOW (PAUSETIME) IS USED TO CONTROL THE PAUSE LENGTH
; PLEASE ALSO NOTE THAT THE PAUSE LENGTH CHANGES DEPENDING ON HOW FAST
; THE SCROLLER IS GOING AT THAT TIME
; THE CODE ALSO ALLOWS A PROGRAM TO BE SET TO USE GEM
; A NEW VERSION WILL HOPEFULLY BE OUT SOON
; THAT AUTOMATICALLY RUNS THE PROGRAM
; I.E A VERSION OF STARTGEM (ETC.)
; THE VARIABLE BELOW DROPRATE DETERMINES THE SPEED OF
; THE DISPLAYING OF THE MAIN SCREEN
; THE TOP BORDER REMOVAL CODE HAS BEEN REMOVED TO ENABLE
; STE COMPATIBILITY
; THE MENU ALSO HAS ROLLING RASTER BARS THE HEIGHT AND START POSITION
; OF WHICH CAN EASILY BE ALTERED (SEE BELOW...)
; HOPEFULLY IN NEAR FUTURE + AND - WILL CHANGE STARTPOS OF RASTER
; AND POSSIBLY EVEN * AND / TO CHANGE THE SIZE OF THE RASTER
; PLEASE INFORM NEW ORDER OF ANY BUGS YOU MAY FIND IN THIS CODE
; OR ANY MODIFICATIONS YOU MAKE TO MAKE IT RUN BETTER/FASTER
; PLEASE NOTE THAT THE NEW CODE ENABLES MUSIC TO HAVE BEEN ACTIVE
; WHEN THE MENU WAS LOADED AND WILL ALLOW THE MUSIC TO BE RESTORED
; ON EXIT FROM THE MENU
; THE MENU ALSO NOW HAS THE SPACE BAR WIREDUP SO THAT IT CHAINS TO
; THE TEXT FILE DISPLAYER (WRITTEN BY THE C A M E L)
; ON RETURN FROM THE ABOVE IT WILL RESTART THE MENU
; THE MENU ALSO NOW HAS A SCREEN FADE ON EXIT TO RUN A PROGRAM
; THIS IS NOT ON THE TEXT FILE DISPLAYER EXIT
; IT ALSO NOW DISPLAYS A SECOND SCREEN WHEN YOU RUN A PROGRAM
; ANOTHER NEW FEATURE IS THAT THE MENU NOW ALSO HAS A RESET SCREEN
; SEE 'INSTALLRESET' TO SEE HOW TO CHANGE SCREEN ADDRESS FOR RESET SCREEN
; THIS RESET IS ONLY THERE FOR ONE RESET THE NEXT RESET DOES A NORMAL RESET
; A NEW CONSTANT CALL 'SCRADDR2' HAS APPEARED THIS SHOULD BE SET ON A 256
; BYTE BOUNDARY EQ. 68000, 78000
; PLEASE NOTE PLEASE SET AT LEAST 32000 BYTES LOWER THAN 'SCRADDR'
; PLEASE ALSO NOTE THAT ON RUNNING A PROGRAM THE SCROLLER SCROLLS
; BACKWARDS WHAT IS ON THE SCREEN AT THAT TIME
; THERE IS ALSO YET ANOTHER CONSTANT, THIS IS THE HIGH BYTE OF THE
; RESET SCREEN ADDRESS: SET THIS TO A 7 FOR A 512K COMPATIBLE MENU
; ALSO NOTE THAT THE CONSTANT 'RESETSCRPOS' IS THE POSITION FOR THE
; RESET SCREEN: THIS SHOULD BE SET TO $(HIGHBYTE)8000
; THIS MEANS IF HIGHBYTE IS A 7 THEN SET TO $78000
; IF IT IS A F THEN SET TO $F8000

****************************************************************
****                        NEW ORDER                       ****
****************************************************************

	opt	o+,w-
scraddr	equ	$70000	!change from $f0000 to 70000
scraddr2	equ	$60000	!change from $e0000 to 60000
highbyte	equ	$7	!change from $f to $7
resetscrpos	equ	$78000	!change from $f8000 to 78000
pausetime	equ	120
droprate	equ	9000
; The drop rate has to be in range 0-65535
startrast	equ	1
	;Set this for the number of pixel lines down from the top
	;Border. 50/60Hz. toggle is now in bottom border
	;This value can be between 1 and (195-rasthigh)
togglebarpos	equ	18
	;This sets how far below the bottom border the bar appears
	;Values 1-30 are valid.
	;(Values 31-35(approx.) may be visible
	;on some screens but not mine).
colournum	equ	8
	;Set this for colour pallette number 0-15.
rastpalpos	equ	$ff8240+(colournum*2)
rasthigh	equ	1
	;Set this value for the height of the raster bars
	;Make sure there is enough data in rolrasttable
	;For the height of the bar
; THE MAIN PROGRAM
start:
 	move.l	a7,a5
	move.l	#ustk,a7
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	#$100,d0
	move.l	d0,spacesave
	move.l	a5,possave
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	move.l	d0,space2save

restart
        clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1
        move.l  d0,savereg
        addq.l	#6,sp

	move.l	#4,a0
	move.l	#2,d0
	lsl.w	#4,d0
	move.l	4,0(a0,d0)
	jsr	installreset

        ;move.l  #scraddr,a7

        move.l  #moff,-(sp)
        clr.w   -(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        dc.w	$a00a               ;mouse off

        move.w  #4,-(sp)        
        trap    #14
        addq.l  #2,sp
        move.w  d0,oldrez
        move.l  $44e.w,oldscr
        move.l  #scraddr,screen3  ;new screen address

        movem.l $ffff8240.w,d0-d7
        movem.l d0-d7,oldpal
        move.b  #$02,$ffff820a.w

        bsr     prepare
	; SET UP 
	lea	scraddr,a0
	move.w	#($7d00*2)-1,d0
clear1	clr.w	(a0)+
	dbra	d0,clear1
; CLEAR ALL SCREEN RAM BEFORE INTERRUPTS

        bsr     hblon

; clear the screen AND AFTER
	lea	scraddr,a0
	move.w	#($7d00*2)-1,d0
clear	clr.w	(a0)+
	dbra	d0,clear

	lea	scraddr,a0
	lea	scraddr+$7d00-(5*$a0),a1
	lea	screen+34,a2
	lea	screen+34+32000-($a0*5),a3
;Set up the variables that the routine requires
	jsr	putpic
; PICTURE DISPLAY ROUTINE CALL

test
	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	bsr	lscroll

	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	beq	test

;	cmp.b	#' ',d0
;	beq	dumper
; THIS CHECK ENABLES THE TEXT FILE DUMPER TO BE CHAINED TO
	cmp.b	#'0',d0
	blt	test
	; get next keypress if key not in 0-2
	cmp.b	#'1',d0
	bgt	test
	cmp.b	#'0',d0
	beq	chertz60
	; toggle 60 hertz for when run prog
	; please insert this call first!!
	bra	runprog
	bra	test


exitreq
	jsr	deinstallreset
	jsr	antihscr
	lea	scraddr,a0

	move.w	#0,-(sp)
	move.l	#scraddr2,-(sp)
	move.l	#scraddr2,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	bsr	hbloff

	lea	screen+34,a0
	lea	scraddr2,a1
	move.l	#(32000/4)-1,d0
putter	move.l	(a0)+,(a1)+
	dbf	d0,putter


	move.l	#scraddr2,a6
; TELL ROUTINE WHERE TO FADE
	jsr	fadeit
;This enables the screen to be cleared first

        bsr	set_hertz

        move.w  #0,-(sp)
        move.l  #scraddr,-(sp)
        move.l  #scraddr,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

	movem.l	screen2+2,d0-d7
	movem.l	d0-d7,$ffff8240
	move.l	#scraddr,a0
	move.l	#scraddr,a1
	add.l	#$7d00-(5*$a0),a1
	lea	screen2+34,a2
	lea	screen2+34+32000-($a0*5),a3
;Set up the variables that the routine requires
	jsr	putpic

        movem.l oldpal,d0-d7
        movem.l d0-d7,$ffff8240.w
        move.w  oldrez,-(sp)
        move.l  oldscr,-(sp)
        move.l  oldscr,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        move.l  #mon,-(sp)
        clr.w   -(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        dc.w	$a009              ;mouse on
        move.l  savereg,-(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp

        clr.l   -(sp)
        trap    #1

chertz60	bsr	hertz60
	bra	test


runprog
        move.l	d0,d0store

	jsr	deinstallreset
	jsr	antihscr
	lea	scraddr,a0

	move.w	#0,-(sp)
	move.l	#scraddr2,-(sp)
	move.l	#scraddr2,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	bsr	hbloff

	lea	screen+34,a0
	lea	scraddr2,a1
	move.l	#(32000/4)-1,d0
.putter	move.l	(a0)+,(a1)+
	dbf	d0,.putter


	move.l	#scraddr2,a6
	bsr	clrsnd
; TELL ROUTINE WHERE TO FADE
	jsr	fadeit
;This enables the screen to be cleared first

        bsr	set_hertz

        move.w  #0,-(sp)
        move.l  #scraddr,-(sp)
        move.l  #scraddr,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

	movem.l	screen2+2,d0-d7
	movem.l	d0-d7,$ffff8240
	move.l	#scraddr,a0
	move.l	#scraddr,a1
	add.l	#$7d00-(5*$a0),a1
	lea	screen2+34,a2
	lea	screen2+34+32000-($a0*5),a3
;Set up the variables that the routine requires
	jsr	putpic
	
	
        move.l  #mon,-(sp)
        clr.w   -(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        dc.w	$a009              ;mouse on

	move.l	d0store,d0
	sub.w	#'1',d0
	asl.w	#2,d0
	lea	fnamelkp,a0
	add.w	d0,a0
	move.l	(a0),a0
	tst.w	(a0)
	beq	gemprog
	addq.w	#2,a0
	move.l	a0,d0store

        move.l  savereg,-(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l	#6,sp

	move.l	spacesave,-(sp)
	move.l	possave,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#$c,sp

	move.l	d0store,a0
	pea	env
	pea	com
	move.l	a0,-(sp)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
bra1
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$ff8240
	clr.l	-(sp)
	trap	#1

dumper
        bsr     hbloff

        movem.l oldpal,d0-d7
        movem.l d0-d7,$ffff8240.w
        move.w  oldrez,-(sp)
        move.l  oldscr,-(sp)
        move.l  oldscr,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp
       
        move.l  #mon,-(sp)
        clr.w   -(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        dc.w	$a009              ;mouse on

        bsr	set_hertz

        move.l  savereg,-(sp)
        move.w  #$20,-(sp)
        trap    #1
        addq.l	#6,sp

	move.l	space2save,-(sp)
	move.l	possave,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#$c,sp


	pea	env
	pea	com
;	pea	dumperfname
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	bra	restart

gemprog	
 bra.s    gstart
hires  equ 0		; 0 - Lowres/Medres boot  1 - Hires boot
keyclk equ 1		; 0 - No effect           1 - Keyclick turned off
althlp equ 1		; 0 - No effect           1 - Alt-Help disabled
syseng equ 0		; 0 - No escape route     1 - Escape option enabled
gfpath 	dc.b '\',0	; Path of program to GemStart
	even
gfname 	dc.b 'INTRO.tbe',0	; Filename of program to GemStart
gfname1
 even

gstart
 move.w   #4,-(sp)
 trap     #14
 addq.l   #2,sp
 cmp.b    #2,d0
 IFeq hires
 bne.s    execute
 ELSEIF
 beq.s    execute
 ENDc
 clr.w    -(sp)
 trap     #1
execute
 IFne keyclk
 bclr.b   #0,$484.w
 bclr.b   #2,$484.w
 ENDc
 IFne althlp
 move.w   #$4e75,$340
 move.l   #$340,502.w
 Endc
 Ifne syseng
 move.w   #-1,-(sp)
 move.w   #11,-(sp)
 trap     #13
 addq.l   #4,sp
 and.w    #15,d0
 cmp.w    #$e,d0
 beq      exit
 ENDc
exec1
 move.l   $84,noboot+2
 move.l   #$180,$84
 lea      code,a0	; From
 lea      $180,a1	; To
 move.w   #codee-code,d0	; Length
 subq.w   #1,d0
loop
 move.b   (a0)+,(a1)+
 dbra     d0,loop
 clr.l    $4ce
 clr.w    $280		; No command or enviroment
 lea      $282,a0
 lea      gfname(pc),a1
filecopy
 move.b   (a1)+,(a0)+
 cmp.l    #gfname1,a1
 blt      filecopy
 lea      $2c0,a0
 lea      gfpath(pc),a1
filepath
 move.b   (a1)+,(a0)+
 cmp.l    #gfname,a1
 blt      filepath
 move.w   #2,$300	; Counter
exit	
 clr.w    -(sp)
 trap     #1

code
 move.w   (sp),d0
 btst     #13,d0
 bne.s    trap_super
trap_user
 move.l   usp,a0
 bra.s    trap_hook1
trap_super
 move.l   sp,a0
 addq.l   #6,a0
trap_hook1
 tst.w    $4ce
 beq.s    noboot
 subq.w   #1,$300
 beq.s    loadngo
noboot
 jmp      $fc0000
loadngo
 move.l   noboot+$182-code,$84	; Release TRAP vector
 move.l   4,d0
 move.l   d0,$24
 move.l   d0,$10
 move.w   #$2300,sr	; Enable VBL
cdir
 move.l  #$2c0,d0
 lea     $2bf+gfname-gfpath,a0
 move.b  #0,(a0)
 move.l  d0,a0
 cmp.b   #':',1(a0)
 bne     cdir1a
 move.l  d0,-(sp)
 move.b  (a0),d0
 and.w   #$df,d0
 sub.b   #'A',d0
 move.w  d0,-(sp)
 move.w  #$e,-(sp)
 trap    #1
 addq.l  #4,sp
 move.l  (sp)+,d0
cdir1a
 move.l  d0,-(sp)
 move.w  #$3b,-(sp)
 trap    #1
 addq.l  #6,sp
dispmess
 pea      gmessage+$180-code
 move.w   #9,-(sp)
 trap     #1
 addq.l   #6,sp
 move.l   #$280,-(sp)	; Run program
 move.l   #$280,-(sp)
 move.l   #$282,-(sp)
 move.w   #0,-(sp)
 move.w   #$4b,-(sp)
 trap     #1
 move.l   4,a0
 jmp      (a0)
gmessage
 dc.b     27,'c2',27,'E','GEM LOADING INTRO CODE',27,'c0',0
codee
	even
hertz60
	not.w	hertz_flag
	btst	#0,hertz_flag
	beq	blackbar
	move.w	#$007,barcolour
	rts

blackbar	move.w	#0,barcolour
	rts

set_hertz
	btst	#0,hertz_flag
	beq	set_50
set_60	bclr	#1,$ff820a
	rts
set_50	bset	#1,$ff820a
	rts

spacesave	dc.l	0
space2save	dc.l	0
possave	dc.l	0
d0store	dc.l	0
hertz_flag
	dc.w	0
env	dc.l	0
com	dc.l	0
fnamelkp
	dc.l	fname1
fname1	dc.w	0
	; please not the word before the filename specifies
	; gem operation or autobbot
	; a 0 means gem
	; any other value means autoboot
	dc.b	'intro.tbe',0
	even
	; add extra file names as required always terminate
	; with a zero and put a 'even' command in!!!!!

;-----------------------------
hblon:
	bsr	checkque
        move.l  $120.w,oldtb    ;save vectors
        move.l	$118,newkeyb2+2
        move.l  $70.w,old4
        move.l  $70.w,new4b+2
        move.b	$484.w,old484
        bclr	#2,$484.w
        bclr	#1,$484.w
        bclr	#0,$484.w
        move.b  $fffffa07.w,old07
        move.b  $fffffa09.w,old09
        move.b  $fffffa0f.w,old0f
        move.b  $fffffa11.w,old11
        move.b  $fffffa1b.w,old1b
        and.b   #$df,$fffa09    ;disable Timer C
        and.b   #$fe,$fffa07    ;disable Timer B
        move.l  #newtb,$120.w
        move.l  #new4,$70.w
        move.l	#newkeyb,$118
        or.b    #1,$fffffa07.w  ;enable Timer B
        or.b    #1,$fffffa13.w
        rts

checkque
	move.l	$456,a0
	lea	oldque,a1
	move.w	#7,d0
.loop	move.l	(a0)+,(a1)+
	clr.l	-4(a0)
	dbra	d0,.loop
	rts

restoreque	move.l	$456,a0
	lea	oldque,a1
	move.w	#7,d0
.loop	move.l	(a1)+,(a0)+
	dbra	d0,.loop
	rts

hbloff:
        move.w  sr,-(sp)
        move.w  #$2700,sr
        bsr	clrsnd
        bsr	restoreque
        move.b  old07(pc),$fffffa07.w    ;restore all registers
        move.b  old09(pc),$fffffa09.w
        move.b  old0f(pc),$fffffa0f.w
        move.b  old11(pc),$fffffa11.w
        move.b  old1b(pc),$fffffa1b.w
        move.l  oldtb,$120.w             ;restore vectors
        move.l	newkeyb2+2,$118
        move.l  old4,$70.w
        move.l	$456,a0
        move.b	old484,$484.w
        move.w  (sp)+,sr
        rts

oldque ds.l 8
old484 dc.w 0
old4:  dc.l 0
oldtb: dc.l 0
old07: dc.b 0
old09: dc.b 0
old0f: dc.b 0
old11: dc.b 0
old1b: dc.b 0
	even

newkeyb	move.w	#$2100,sr
newkeyb2	jmp	0

new4:
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	sr,-(sp)
	lea	screen+2,a0
; SET PALLETTE FOR screen
	lea	$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	move.w	(sp)+,sr

	clr.b	$fffa1b
	move.l	#rollrast,$120
	move.b	#startrast,$fffa21
	move.b	#8,$fffa1b


	bsr	music+8	;change to +8 for MADMAX MUSIC

	move.l	pointer,a0
	addq.l	#2,a0
	cmp.l	#therepeat,a0
	bne	.cont
	move.l	#rolrasttable,a0

.cont	move.l	a0,pointer
	move.l	a0,rpointer
	move.w	#rasthigh,hightrast
	movem.l	(sp)+,d0-d7/a0-a6
.loop	btst	#1,$fffc00
	beq	.loop
	move.b	#$11,$fffc02
new4b:
        jmp     $000000


rollrast
	move.l	a0,-(sp)
	
	move.l	rpointer,a0	
	move.w	(a0),rastpalpos
	addq.l	#2,rpointer

	clr.b	$fffa1b

	sub.w	#1,hightrast
	tst.w	hightrast
	bne	okdokey
	move.l	#resetrast,$120
	bra	ccont

okdokey	move.l	#rollrast,$120
ccont	move.b	#1,$fffa21
	move.b	#8,$fffa1b

	move.l	(sp)+,a0
	bclr	#0,$fffa0f
	rte

resetrast
	move.w	screen+2+(rastpalpos-$ff8240),rastpalpos

	clr.b	$fffa1b
	move.l	#newtb,$120
	move.b	#199-rasthigh-startrast,$fffa21
	move.b	#8,$fffa1b

	bclr	#0,$fffa0f
	rte

; Set the bar colour to indacte 50/60 Hz.
startbar	move.w	barcolour,$ff8240
	clr.b	$fffa1b
	move.l	#endbar,$120
	move.b	#3,$fffa21
	move.b	#8,$fffa1b
	bclr	#0,$fffa0f
	rte

; Revert to old background coulour
endbar	move.w	screen+2,$ff8240
	bclr	#0,$fffa0f
	rte

; Set the pallette for the font
newtb:
	movem.l	a0-a1,-(sp)
	
	lea	fontpal,a0
	lea	$ff8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	
	movem.l (sp)+,a0-a1

.loop	btst	#1,$fffc00
	beq	.loop
	move.b	#$13,$fffc02

newtb1:
	movem.l	d0/a1,-(sp)
	
	movea.w	#$fa21,a1
	move.b	(a1),d0
.l1	cmp.b	(a1),d0
	beq	.l1

	clr.b	$ff820a
	moveq	#2,d0
.l2	nop
	dbra	d0,.l2
	move.b	#2,$ff820a

	clr.b	$fffa1b
	move.l	#startbar,$120
	move.b	#togglebarpos,$fffa21
	move.b	#8,$fffa1b
	bclr	#0,$fffa0f

	movem.l	(sp)+,d0/a1

        bclr    #0,$fffa0f  ;end of interrupt
        rte

;-----------------------------
prepare:

; setup for scroller
	clr.l	d6
	move.w	#0,lcurr
	move.l	#message,a6
	lea	buffer,a5
	move.w	lcurr,d6
	add.l	d6,a6
	move.b	(a6),d6
	and.l	#$ff,d6
	sub.b	#32,d6   ; convert space to zero
	asl.w	#7,d6    ; convert to 512 byte font size
	asl.w	#1,d6
; adjust the shift factor for new font
; d6 now holds font char
	lea	font,a4
	add.l	d6,a4
; a4 now holds pointer to char in font
	move.w	#4*2*32-1,d7   ; number of words per font char
loop1	move.w	(a4)+,(a5)+
                ; copy font char into scroll buffer
	dbra	d7,loop1
; copys font char into buffer

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,sav_phys

	clr.w	-(sp)
	move.l	screen3,-(sp)
	move.l	screen3,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#$c,sp
	
;save current palette
	lea	savpal,a1
	lea	$ff8240,a0
	move.w	#$f,d0
getcols	move.w	(a0)+,(a1)+
	dbra	d0,getcols
	lea	screen,a1
	add.l	#2,a1
	lea	$ff8240,a0
	move.w	#$f,d0
setpal	move.w	(a1)+,(a0)+
	dbra	d0,setpal
	

	move	#0,d0
	move	mus_c,d0		* loads music *
	jsr	mus

	rts
; exit prepare rountine

screendrop
loops	move.w	-(a4),-(a2)
	subq.l	#6,a4
	subq.l	#6,a2
	move.w	(a3)+,(a1)+
	addq.l	#6,a3
	addq.l	#6,a1
	move.l	#droprate,d3
loops2	dbra	d3,loops2
	dbra	d1,loops
	rts
sav_phys	ds.l	1
		
	
mus	
	move.w	#32,pixels
	;move.w	#0,d0
	bsr	music
	rts

; scroll control routine
lscontrol
	move.w	nooftimes,d0
nooftimes	dc.w	0

exitpauseit	sub.w	#1,pauseit
	rts
pauseit	dc.w	0
trans	macro
	movep.l	\1(a1),d1
	movep.l	d1,\1-7(a1)
	movep.l	\1+1(a1),d1
	movep.l	d1,\1(a1)
	endm

;   scroll routine
lscroll
	tst.w	pauseit
	bne	exitpauseit
	move.l	d0,-(sp)
	move.w	#31,d0
; adjust to pixel lines to scroll (vertical) minus 1
; adjust the font accordingly
	move.l	#scraddr+(201*$a0),a1
	; adjust the one hundred to
	; top pixel line to scroll
	move.l	#buffer,a2
scroll	
	move.l	#$24,a6
	move.l	#reset,(a6)

	cmp.w	#0,pixels
	beq	getnextchar
scrollit
	movep.l	1(a1),d1
	movep.l	d1,(a1)
	trans	8
	trans	16
	trans	24
	trans	32
	trans	40
	trans	48
	trans	56
	trans	64
	trans	72
	trans	80
	trans	88
	trans	96
	trans	104
	trans	112
	trans	120
	trans	128
	trans	136
	trans	144
	trans	152

	move.b	(a2),153(a1)
	move.b	4(a2),155(a1)
	move.b	8(a2),157(a1)
	move.b	12(a2),159(a1)
	move.b	1(a2),(a2)
	move.b	2(a2),1(a2)
	move.b	3(a2),2(a2)

	move.b	5(a2),4(a2)
	move.b	6(a2),5(a2)
	move.b	7(a2),6(a2)

	move.b	9(a2),8(a2)
	move.b	$a(a2),9(a2)
	move.b	$b(a2),$a(a2)

	move.b	$d(a2),$c(a2)
	move.b	$e(a2),$d(a2)
	move.b	$f(a2),$e(a2)

	add.l	#$a0,a1
	add.l	#16,a2
	dbra	d0,scrollit

	subq.w	#8,pixels

pauseexit	move.l	(sp)+,d0
	rts

getnextchar
	;transfer next char
	clr.w	d0
	addq.w	#1,lcurr
	lea	message,a0
	lea	buffer,a1
	move.w	lcurr,d0
	add.w	d0,a0
	cmp.b	#'@',(a0)
	beq	pauseit2
	clr.l	d0
	move.b	(a0),d0
	cmp.b	#$ff,d0
	beq	looper
	sub.b	#32,d0
	asl.w	#8,d0
	asl.w	#1,d0
; d6 now holds font char
	lea	font,a0
	add.l	d0,a0
; a4 now holds pointer to char in font
	rept	4*32
	move.l	(a0)+,(a1)+
	endr
; copys font char into buffer

; reset to proportional pixels to scroll
	move.w	lcurr,d0
	lea	message,a0
	add	d0,a0
	move.b	(a0),d0
	and.w	#$ff,d0
	sub.w	#' ',d0
	lsl.w	#1,d0
	lea	proportiontable,a0
	add.l	d0,a0
	move.w	(a0),pixels
;	move.w	#32,pixels

	move.l	#scraddr+(201*$a0),a1
	lea	buffer,a2
	move.w	#31,d0
	; reset to 32 pixel lines to scroll
	bra	scrollit

pauseit2	move.w	#pausetime,pauseit
	bra	pauseexit

looper
	move.w	#-1,lcurr
	bra	getnextchar

putpic
; scraddr+(32*$a0) for no movement
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#97,d0	
.loop2	move.l	#159,d1
.loop	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a1)+
	dbra	d1,.loop
	move.w	#droprate,d1
.loop3	dbra	d1,.loop3
	add.l	#$a0,a0
	add.l	#$a0,a2
	sub.l	#$a0*3,a1
	sub.l	#$a0*3,a3
	dbra	d0,.loop2

.cont	movem.l	(sp)+,d0-d7/a0-a6
	rts

deinstallreset
	; THIS IS THE CODE THAT REMOVES THE RESET PROOF SECTION
	clr.l	$426
	clr.l	$42a
	rts

installreset
	; THIS IS THE SETUP FOR THE RESET PROOF CODE
	move.l	#$24,a0
	move.l	#reset,(a0)
	; Kill the trace system for those debugging this

	move.l	#$31415926,$426
	move.l	#reset,$42a
	rts

reset
	; THIS IS THE RESET CODE
	clr.l	$426
	clr.l	$42a
	; CLEAR THE RESET VECTORS
	move.b	#0,$ff8260
	; LOW REZ
	move.b	#2,$ff820a
	; 50 Hz.
	move.b	#highbyte,$ff8201
	; SEE ABOVE FOR COMMENT ABOUT THIS CONSTANT
	; THIS SETS THE HIGHBYTE OF THE SCREEN ADDRESS
	move.b	#$80,$ff8203
	; THIS IS THE LOW BYTE OF THE SCREEN ADDRESS
	
;  The above initialises the reset code and sets the screen to the
;  correct address.
;  This assumes that machine has not crashed and sets low-res 50Hz
;  Control remains in supervisor mode.

	lea	screen4+2,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ff8240
; set the pallette FOR RESET SCREEN

	move.l	#(32000/4)-1,d0
	lea	screen4+34,a0
	lea	resetscrpos,a1
	; THIS CONSTANT SHOULD BE SET AS DETAILED AT TOP OF LISTING
displayit	move.l	(a0)+,(a1)+
	dbf	d0,displayit
; put the RESET piccy on screen
pause	bra	pause
	; LOCK THE MACHINE UNTIL A RESET

clrsnd	move.l	#$0000000,$4da
	move.l 	#$8080000,$ff8800
	move.l	#$9090000,$ff8800
	move.l 	#$a0a0000,$ff8800
	rts

oldpal	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


	ds.l      200
ustk	ds.l	1
	; MY STACK LEAVE AS ABOVE	

	include	\codes.tbe\source\fadeinc.s
	; THIS IS THE FADE ROUTINE
	include	\codes.tbe\source\antihinc.s
	; THIS IS THE ANTI-HORIZONTAL SCROLL INCLUDE

mus_c	dc.w	1          !tune number
	
	section	data
	
music	incbin	"\codes.tbe\muzak\max1.mus"
screen	incbin	"\codes.tbe\piccies.pi1\new_ripd.pi1"    !main picture
screen2	incbin	'\codes.tbe\piccies.pi1\loading.pi1"
	; THIS IS THE PICTURE DISPLAYED ON RUNNING A PROGRAM
screen4	incbin	'\codes.tbe\piccies.pi1\dmob.pi1'
	; THIS IS THE RESET PICTURE
savpal	ds.w	16
lcurr	dc.w	0
pixels	dc.w	32
	even

message
; all text must be in uppercase
; pause is on @ symbol
	DC.B	"   "
	dc.b	". . . . . . <= . . . . . . THE BALD EAGLE IN CONJUNCTION WITH RIPPED OFF           PRESENTS TO YOU:     RIPPED OFF MENU 64 @              "
	dc.b	" MUSIX BY THE ONE AND ONLY MADMAX,    MAIN SCREEN,   LOADING SCREEN GRAPHIX AND FONT PUT TOGETHER BY<=      RESET SCREEN GRAPHIX BY DMOB ON THE AMIGA.    "
	DC.B	"MANY THANX GO TO THEM AND TO EX-GUARDIANS OF LOGIK MEMBER:         WINNY        @ FOR RIPPING IT AND PASSING IT ON TO ME.   "
	DC.B	" THIS MENU CODE"
	DC.B	" IS NOW MEANT TO BE STE COMPATIBLE AND ALSO INCORPORATES THE ULTRA NEW #$%& GEM LOADER.    YES!,   NOW WE CAN LOAD GEM PROGRAMS DIRECT FROM A MENU WITHOUT THE USE OF"
	DC.B	" STARTGEM OR HAVING TO DROP BACK TO THE DESKTOP (LIKE OTHER UN-NAMEABLE GROUPS DO QUITE OFTEN).        "
	DC.B	" MENU COMPILED BY:       THE BALD EAGLE   @ AND CODING BY:      KARL (THE CAMEL)  @         GREETZ TO THE FOLLOWING (IN NO PARTICULAR ORDER): "
	DC.B	" DEREK M.D AND BECKY@         MERLIN       @      EL-SID       @      BRYAN        @       THE MONSTER    @      "
	DC.B	"    BILBO        @        LEE         @        KEI         @       GORDON       @       "
	DC.B	" M M M       @      BIRDY        @        THE EMPIRE     @        LAWZ        @        "
	DC.B	" SHAREZ JEK     @        SLEDGE FROM HOTLINE @          EDITMAN      @          AUTOMATION     @,          S.A.S.H       @"
	DC.B	" (ESPECIALLY THE WIZARD)       THE MOB ON ICELAND @ (HI OLY)        "
	DC.B	" TECHNO WIZARD    @        "
	DC.B	" THE ANIMI DUX    @         TEDDYSTACKER    @        WACKY JACKY    @       THE PRESIDENT   @           JOBIL       @        THE MEDWAY BOYS  @          M.C.A        @        SEWER SOFTWARE   @"
	DC.B	"        "
	DC.B	" WIZPOP       @        THE POMPEY PIRATES @         ST/AMIGOS     @(HI SHERI)          SPARKY       @          SCOTT (U.S.A)    @        KAM        @         ZODIAC       @(MARK H. SAY'S HI TO YOU)       "
	DC.B	" HOTLINE       @         THE REPLICANTS   @         DELIGHT      @         G-FORCE      @         ELECTRIC BLUE   @          THE CAREBEARS   @        "
	DC.B	"      HAL        @     "
	DC.B	"      ANDY THE 'ARFLING  @      THE PILOT      @      "
	DC.B	" THE MOB       @       "
	DC.B	" FAT VIC      @        "
	DC.B	" AND TO ALL GROUPS AND INDIVIDUALS WORLDWIDE.    MEGA THANX GO TO ALL GROUPS THAT HAVE CRACKED THE GAMES FOR THIS LATEST  <= / #$%&  MENU. "
	dc.b	"            WELL THAT'S YOUR LOT UNTIL NEXT TIME.        THE BALD EAGLE SIGNING OFF........BYE.......10.......9.......8.......7.......6.......5.......4.......3.......2.......1.......0......."
	DC.B	"LET'S WRAP       "
	DC.B	""
	DC.B	$FF

font	incbin	\codes.tbe\fonts\edfont.fnt
	; THIS IS THE FONT INCLUDE STATEMENT
	even
key	dc.w	0

;rolling raster data area
rpointer	dc.l	rolrasttable
pointer	dc.l	rolrasttable
rastcol	dc.w	$555
rolrasttable
	dc.w	$001,$002,$003,$004,$005,$006,$007
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$100,$200,$300,$400,$500,$600,$700
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$010,$020,$030,$040,$050,$060,$070
	dc.w	$070,$060,$050,$040,$030,$020,$010
	dc.w	$111,$222,$333,$444,$555,$666,$777
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$110,$220,$330,$440,$550,$660,$770
	dc.w	$770,$660,$550,$440,$330,$220,$100
	dc.w	$101,$202,$303,$404,$505,$606,$707
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$011,$022,$033,$044,$055,$066,$077
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$001,$002,$003,$004,$005,$006,$007
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$100,$200,$300,$400,$500,$600,$700
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$010,$020,$030,$040,$050,$060,$070
	dc.w	$070,$060,$050,$040,$030,$020,$010
	dc.w	$111,$222,$333,$444,$555,$666,$777
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$110,$220,$330,$440,$550,$660,$770
	dc.w	$770,$660,$550,$440,$330,$220,$100
	dc.w	$101,$202,$303,$404,$505,$606,$707
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$011,$022,$033,$044,$055,$066,$077
	dc.w	$077,$066,$055,$044,$033,$022,$011
	;dc.w	$001,$002,$003,$004,$005,$006,$007
	;dc.w	$007,$006,$005,$004,$003,$002,$001
therepeat
	dc.w	$001,$002,$003,$004,$005,$006,$007
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$100,$200,$300,$400,$500,$600,$700
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$010,$020,$030,$040,$050,$060,$070
	dc.w	$070,$060,$050,$040,$030,$020,$010
	dc.w	$111,$222,$333,$444,$555,$666,$777
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$110,$220,$330,$440,$550,$660,$770
	dc.w	$770,$660,$550,$440,$330,$220,$100
	dc.w	$101,$202,$303,$404,$505,$606,$707
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$011,$022,$033,$044,$055,$066,$077
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$001,$002,$003,$004,$005,$006,$007
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$100,$200,$300,$400,$500,$600,$700
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$010,$020,$030,$040,$050,$060,$070
	dc.w	$070,$060,$050,$040,$030,$020,$010
	dc.w	$111,$222,$333,$444,$555,$666,$777
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$110,$220,$330,$440,$550,$660,$770
	dc.w	$770,$660,$550,$440,$330,$220,$100
	dc.w	$101,$202,$303,$404,$505,$606,$707
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$011,$022,$033,$044,$055,$066,$077
	dc.w	$077,$066,$055,$044,$033,$022,$011
	;dc.w	$001,$002,$003,$004,$005,$006,$007
	;dc.w	$007,$006,$005,$004,$003,$002,$001
;end of rolling raster data area

oldrez:  dc.w 0
oldscr:  dc.l 0
savereg: dc.l 0
screen3: dc.l 0
fontpal
	dc.w	0,$777,$777,$777,$777,$114,$336,$667
	dc.w	$333,$700,$777,$777,$777,$777,$777,$777

barcolour	dc.w	0
hightrast	dc.w	rasthigh
me:	dc.b	'Programmed by KARL ( THE C A M E L )'
	dc.b	'NEW ORDER MENU 14 SOURCE CODE'
	DC.B	'NOT THE fourtennth MENU'
;  LEAVE THIS IN ON PAIN OF DEATH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	even
mon:  dc.b $08
moff: dc.b $12
	even
proportiontable
; starts with a space
	dc.w	16
	dc.w	8
	dc.w	32
	dc.w	32
	dc.w	32
	dc.w	32
	dc.w	32
	dc.w	8
	dc.w	8
	dc.w	8
	dc.w	16
	dc.w	16
	dc.w	8
	dc.w	16
	dc.w	8
	dc.w	16
	dc.w	16
	dc.w	8
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	8
	dc.w	8
	dc.w	32
	dc.w	32
	dc.w	16
	dc.w	16
	dc.w	32
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	8
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	32
	dc.w	32
	dc.w	32
	dc.w	32
	dc.w	32
	dc.w	32
	dcb.w	20,32
	; Extras just in case	
	
	even
	section	bss

buffer	ds.w	2*4*2*32


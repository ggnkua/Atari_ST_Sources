; The Micro Demo of Lazer
;
; Code by Photon, Grafix by ST-Ninja
;
;
; Hi Griff! I think you have found out already, that this is the source
; of the starwars scroller. I was very surprised, that you liked my
; starwars scroller so much. When you look at the sourcecode, you'll find
; out, that you could do many more things with this scroller!!
; However, I do not use many differently sized fonts because:
;   1.) It costs so much memory
;   2.) I was too lazy to write a program which shrinks the font
;   3.) I wanted to scroll logos, pictures ..
; You'll have noticed, that I am using an ugly 5*5 font.
; That means, for each line of a char there are 2^5=32 different
; bitpatterns. So I don't have to enlarge 30 Characters, each 5*5,
; I enlarge the 32 bitpatterns. Then I move them in the 16 positions
; that I don't have to use lsl during the scrolling.
; The data, how the scroller actually looks like, is computed by a
; basic program, which computes the movement for each char.
; The scroller is computed in memory just as an ordinary upscroll
; (You could scroll anything you like). I don't really scroll it,
; I only move a pointer on the data.
; The showrout takes the normal data, and puts it in the right
; size on the right position. That's all...
; I could imagine, that you haven't understood my explanation, but
; I was in a hurry, and didn't know how to explain this. If you
; haven't understood it, I will send you a full documented version
; of this. Sorry ...

	bra     main

*********************************
; only checks if the screen was started from the loader
check
	clr.l	$4d2

	clr.l	$100
	cmp.l	#$1f,$10c
	beq	.1
	illegal
.1	rts
*********************************
vbl     clr.b   $fffa1b                 ;Timer B l”schen
        movem.l d0-a6,-(sp)

	move.l	#music,a6
	jsr	8(a6)

	move.l	#coltab,col
	move.w	#$111,$ff8242
	move.w	#$0,$ff8240

	move.l	#timerb,$120
	move.w	#0,rascount

	move.b	#42,$fffa21
	move.b	#8,$fffa1b

        movem.l (sp)+,d0-a6

nv      jmp     $ffffffff
*********************************
noborder
        clr.b   $fffa1b

	movem.l	a0/d0,-(sp)

	move.b	#200,$fffa21
        move.b  #8,$fffa1b      ; weiter

	move.l	#$fffa21,a0
	move.b	(a0),d0
.1	cmp.b	(a0),d0
	beq	.1

	move.w	#38,d0
.2	dbf	d0,.2

	move.b	#0,$ff820a

	move.w	#5,d0
.3	dbf	d0,.3

	move.b	#2,$ff820a

	movem.l	(sp)+,a0/d0

        bclr    #0,$fffa0f      ; IR Flag l”schen
        rte
*********************************
timerb
        clr.b   $fffa1b

	move.l	a0,-(sp)
	move.l	col,a0
	move.w	(a0)+,$ff8242
	move.l	a0,col
	move.l	(sp)+,a0

	add.w	#1,rascount
	cmp.w	#12,rascount
	bne	.2
	move.l	#noborder,$120
.2
	move.b	#13,$fffa21
        move.b  #8,$fffa1b      ; weiter
        bclr    #0,$fffa0f      ; IR Flag l”schen
        rte
*********************************
main
        bsr     init            ; allgemeines init
	bsr	initchardata
	bsr	initintr
	bsr	setintr
	move.w	#$444,$ff8242
	move.w	#$0,$ff8240
.1
        move.w  #37,-(sp)       ; Vsync
        trap    #14
        addq.l  #2,sp

	move.w	#$0,$ff8240

	bsr	clrscr
	bsr	scroll
	bsr	showscroller

*	move.w	#$200,$ff8240

	move.w	#-1,-(sp)
	move.l	scr1,-(sp)
	move.l	scr1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.l	scr1,a0
	move.l	scr2,scr1
	move.l	a0,scr2

        move.b  $fffc02,d0      ; Space ?
        cmp.b   #$39,d0
        bne     .1              ; Weiter gehts

	bsr	clrintr
        bsr     exit            ; CIAO!
        illegal                 ; Kommt eh nicht vor
*********************************
scroll
	lea	textbuf,a0
	add.l	offset,a0
	lea	font,a1

	moveq.l	#0,d0
	move.w	skip,d0
	addq.w	#2,d0
	cmp.w	#12,d0
	bne	.1
	moveq.w	#0,d0
	add.l	#20,textc
	lea	text,a2
	add.l	textc,a2
	tst.b	(a2)
	bne	.1
	move.l	#0,textc
.1	move.w	d0,skip
	add.l	d0,a1
	lea 	text,a2
	add.l	textc,a2

	move.w	#19,d1
.2	moveq.l	#0,d0
	move.b	(a2)+,d0
	cmp.b	#2,d0
	bne	.3
	move.l	#move1,move
	move.b	#32,d0
.3	cmp.b	#1,d0
	bne	.4
	move.l	#move0,move
	move.b	#32,d0
.4	sub.b	#32,d0
	muls.w	#14,d0
	move.w	(a1,d0),(a0)
	move.w	(a1,d0),12000(a0)
	addq.l	#2,a0
	dbf	d1,.2

	add.l	#40,offset
	cmp.l	#12000,offset
	blt	.5
	move.l	#0,offset
.5	rts
*********************************
; This is, where the data is shown as an starwarsscroll
lines=189
showscroller
	move.l	move,a0
	move.l	scr1,a1
	add.l	#40*160,a1
	lea	chardat,a2
	lea	textbuf,a3
	add.l	offset,a3
	move.l	a3,a5
	lea	ycord,a4
	move.w	#18,d4
	move.w	#lines,d7
	moveq.l	#0,d2
.1	move.w	(a4)+,d2
	move.l	a5,a3
	add.l	d2,a3
	moveq.w	#19,d6
.2	move.w	(a3)+,d0
	add.w	(a0)+,d0
	move.w	(a0)+,d1
	move.l	(a2,d0.w),d3
	move.w	d3,8(a1,d1.w)
	swap	d3
	or.w	d3,(a1,d1.w)
	dbf	d6,.2
	subq.w	#1,d4
	bne	.3
	moveq.w	#19,d4
	add.l	#2048,a2
.3	dbf	d7,.1
	rts
*********************************
clrscr
	move.l	scr1,a0
	add.l	#40*160,a0
	moveq.l	#0,d0
	move.w	#lines*2,d1
.0	move.w	d0,(a0)
	move.w	d0,8(a0)
	move.w	d0,16(a0)
	move.w	d0,24(a0)
	move.w	d0,32(a0)
	move.w	d0,40(a0)
	move.w	d0,48(a0)
	move.w	d0,56(a0)
	move.w	d0,64(a0)
	move.w	d0,72(a0)
	lea.l	80(a0),a0
	dbf	d1,.0
	rts
*********************************
; only moves the scrolldata to the positions 0..15 in the word
initchardata
	lea	data,a0
	lea	chardat,a1
	move.w	#32*11-1,d0
.1	moveq.l	#0,d1
	move.w	(a0)+,d1
	swap 	d1
	move.w	#15,d2
.2	move.l	d1,(a1)+
	lsr.l	#1,d1
	dbf	d2,.2
	dbf	d0,.1
	rts
*********************************
initintr
        move.b  $fffa07,old7
        move.b  $fffa09,old9
        move.b  $fffa13,old13
        move.b  $fffa15,old15
        move.b  $fffa1b,old1b

        move.l  $70,old70
        move.l  $70,nv+2
        move.l  $120,old120

        rts
*********************************
setintr
        and.b   #$df,$fffa09
        and.b   #$fe,$fffa07
        move.l  #vbl,$70
        move.l  #noborder,$120
        move.b  #1,$fffa07
        move.b  #1,$fffa13

        rts
*********************************
clrintr
        move.w  #37,-(sp)
        trap    #14
        addq.l  #2,sp

        move.l  old120,$120
        move.l  old70,$70

        move.b  old7,$fffa07
        move.b  old9,$fffa09
        move.b  old13,$fffa13
        move.b  old15,$fffa15
        move.b  old1b,$fffa1b

        rts
*********************************
init
        bsr     superon

*	bsr	check

        bsr     mouseoff

        movem.l $ff8240,d0-d7
        movem.l d0-d7,oldcol

        move.l  $44e,oldscr

	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,oldres

	move.l	#screen1,d0
	add.l	#256,d0
	and.l	#$ffffff00,d0
	move.l	d0,scr1

	move.l	#screen2,d0
	add.l	#256,d0
	and.l	#$ffffff00,d0
	move.l	d0,scr2

        move.w  #0,-(sp)
        move.l  scr1,-(sp)
        move.l  scr1,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        move.l  scr1,a0
        move.l  scr2,a1
        move.w  #7999,d0
.1      clr.l   (a0)+
	clr.l	(a1)+
        dbf     d0,.1

	lea	music,a6
	move.l	#1,d0
	jsr	12(a6)

	lea	music,a6
	move.l	#1,d0
	jsr	(a6)

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp

        rts
*********************************
superon
        move.l  #0,-(sp)
        move.w  #32,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,ssp
        rts
*********************************
superoff
        move.l  ssp,-(sp)
        move.w  #32,-(sp)
        trap    #1
        addq.l  #6,sp
        rts
*********************************
mouseoff
        dc.w    $a00a

        pea     moff
        move.w  #0,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        rts
*********************************
mouseon
        pea     mon
        move.w  #0,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        
        dc.w    $a009
        rts
*********************************
exit
        movem.l oldcol,d0-d7
        movem.l d0-d7,$ff8240

        move.w  oldres,-(sp)
        move.l  oldscr,-(sp)
        move.l  oldscr,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp
 
        bsr     mouseon

        bsr     superoff

        move.w  #0,-(sp)
        trap    #1
*********************************
	section data
moff            dc.b    $12
mon             dc.b    $8

ssp             dc.l    0

old7            dc.b    0
old9            dc.b    0
old13           dc.b    0
old15           dc.b    0
old1b           dc.b    0
        even
old70           dc.l    0
old120          dc.l    0

oldscr          dc.l    0
oldcol          ds.l    8
oldres          ds.l    8

scr1		dc.l	0
scr2		dc.l	0

skip		dc.w	0
textc		dc.l	0
offset		dc.l	0

rascount	dc.w	0
col		dc.l	0
coltab		dc.w	$111,$999,$222,$aaa,$333,$bbb,$444
		dc.w	$ccc,$555,$ddd,$666,$eee,$777,$fff
		dc.w	$700	

text		
		dc.b	1,"                   "
		dc.b	"         H          "
		dc.b	"         I          "
		dc.b	"                    "
		dc.b	"         F          "
		dc.b	"         O          "
		dc.b	"         L          "
		dc.b	"         K          "
		dc.b	"         S          "
		dc.b	"                    "
		dc.b	"         !          "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"         A          "
		dc.b	"                    "
		dc.b	"         N          "
		dc.b	"         I          "
		dc.b	"         C          "
		dc.b	"         E          "
		dc.b	"                    "
		dc.b	"         S          "
		dc.b	"         C          "
		dc.b	"         R          "
		dc.b	"         O          "
		dc.b	"         L          "
		dc.b	"         L          "
		dc.b	"         E          "
		dc.b	"         R          "
		dc.b	"         ,          "
		dc.b	"                    "
		dc.b	"         I          "
		dc.b	"         S          "
		dc.b	"         N          "
		dc.b	"         '          "
		dc.b	"         T          "
		dc.b	"                    "
		dc.b	"         I          "
		dc.b	"         T          "
		dc.b	"         ?          "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"O                   "
		dc.b	" .                  "
		dc.b	"  K                 "
		dc.b	"   .                "
		dc.b	"                    "
		dc.b	"     I              "
		dc.b	"      T             "
		dc.b	"       '            "
		dc.b	"        S           "
		dc.b	"                    "
		dc.b	"          N         "
		dc.b	"           O        "
		dc.b	"            T       "
		dc.b	"             H      "
		dc.b	"              I     "
		dc.b	"               N    "
		dc.b	"                G   "
		dc.b	"                    "
		dc.b	"                   S"
		dc.b	"                  P "
		dc.b	"                 E  "
		dc.b	"                C   "
		dc.b	"               I    "
		dc.b	"              A     "
		dc.b	"             L      "
		dc.b	"            .       "
		dc.b	"                    "
		dc.b	"          T         "
		dc.b	"         I          "
		dc.b	"        L           "
		dc.b	"       L            "
		dc.b	"                    "
		dc.b	"     N              "
		dc.b	"    O               "
		dc.b	"   W                "
		dc.b	"  !                 "
		dc.b	" !                  "
		dc.b	"!                   "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"  THIS IS THE LAST  "
		dc.b	"                    "
		dc.b	"   SCREEN OF THIS   "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"     MICRO-DEMO     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"  NOW IT'S TIME FOR "
		dc.b	"                    "
		dc.b	"     THE CREDITS:   "
		dc.b	"                    "
		dc.b	"                    "
		DC.B	"    ALL CODE BY:    "
		dc.b	"                    "
		DC.B	"     P H O T O N    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		DC.B	"  ALL GRAPHIXX BY:  "
		dc.b	"                    "
		DC.B	"   S T - N I N J A  "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	" SOUNDTRACKER-SOUND:"
		dc.b	"                    "
		dc.b	"       S T A X      "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"  IMPOSSIBLE IDEAS: "
		dc.b	"                    "
		dc.b	"    C H A R L I E   "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	" AND NOW THEY COME: "
		dc.b	"   THE GREETINGS!   "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"  BEFORE THEY COME, "
		dc.b	"  LET'S CHANGE THE  "
		dc.b	"     WAVE FORM!     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	2,"                   "
		dc.b	"   THE GREETINGS IN "
		dc.b	"                    "
		dc.b	"     NO SPECIAL     "
		dc.b	"                    "
		dc.b	"       ORDER        "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"    THE CAREBEARS   "
		dc.b	"        (TCB)       "
		dc.b	"(HI AN COOL! THE TCB"
		dc.b	" -SOUNDTRACKER  IS  "
		dc.b	"     GREAT!!!!)     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"    THE LOST BOYS   "
		dc.b	"        (TLB)       "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"   THE MEDWAY BOYS  "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"       HOTLINE      "
		dc.b	"        (HTL)       "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	" MENACING  CRACKING "
		dc.b	"      ALLIANCE      "
		dc.b	"        (MCA)       "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"    INNER CIRCLE    "
		dc.b	" (GREAT DEMO GUYS!) "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"   THE EXEPTIONS    "
		dc.b	"        (TEX)       "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"   GIGABYTE CREW    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"     REPLICANTS     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"     THE  UNION     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"     THE EMPIRE     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"    ST CONNEXION    "
		dc.b	"      (ST-CNX)      "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"   THE BLACK CATS   "
		dc.b	"        (TBC)       "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"   ANTI AMIGA CREW  "
		dc.b	"        (AAC)       "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"        SYNC        "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"       OMEGA        "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"       VECTOR       "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"   FLEXIBLE FRONT   "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"     AUTOMATION     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"    THE ALLIANCE    "
		dc.b	"  (BOTH OF THEM!)   "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"   THE SPACEBALLS   "
		dc.b	"        (TSB)       "
		dc.b	"  (HI LONESTAR AND  "
		dc.b	"   DARYL!)          "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"       B.A.C.       "
		dc.b	"    (HI T'PAU!)     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"       VBL-TEAM     "
		dc.b	"  (NOW: LAZER-ST!!) "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	" THIS IS THE END MY "
		dc.b	"     FRIEND....     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	" WHAT?? WHAT DO YOU "
		dc.b	"  SAY? YOU ARE NOT  "
		dc.b	"     MENTIONED?     "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"  BUT I DON'T KNOW  "
		dc.b	"        YOU!        "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	" THERE ARE ONLY TWO "
		dc.b	"  CHANCES LEFT FOR  "
		dc.b	"        YOU:        "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"1ST: SEND US MONEY! "
		dc.b	"                    "
		dc.b	"2ND: SEND US A NEW  "
		dc.b	"     DEMO!!         "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"   AND IN THE NEXT  "
		dc.b	"RELEASE OF  LAZER-ST"
		dc.b	"  YOU'LL FIND YOUR  "
		dc.b	"NAME IN THE GREETS!!"
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"OKAY! THAT'S ALL FOR"
		dc.b	"        NOW.        "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"BYE, BYE..........  "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	"                    "
		dc.b	0
	even


move		dc.l	move0

move0		incbin	"stars1.dat"
move1		incbin	"stars5.dat"
data		incbin	"stars2.dat"
font		incbin	"stars3.dat"
ycord		incbin	"stars4.dat"
music		incbin	"repro3.rip"

	section bss

chardat		ds.l	32*16*11
textbuf		ds.w	600*20
screen1		ds.l	270*40+256
screen2		ds.l	270*40+256



	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

	IFEQ STANDALONE
WAITER_O	equ 	50
WAITER_T	equ		WAITER_O+20*1
WAITER_U	equ		WAITER_O+20*2
WAITER_S	equ		WAITER_O+20*3

TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1

	ENDC

	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	DATA

	include macro.s


	IFEQ	STANDALONE
			initAndRun	standalone_init

standalone_init


	jsr		init_effect
	move.w	#200,effect_vbl_counter
    jsr     init_title
    jsr		title_mainloop
    rts



init_effect
	move.w	#$0,$ffff8240
	move.l	#memBase+65536,d0			;2
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0					;3
	move.l	d0,screenpointer2
	move.l	d0,screen2
	add.l	#$10000,d0
	rts  

effect_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
    move.w  #$0,$ffff8240
	move.l	screenpointer2,$ffff8200
		    pushall
				IFNE	STANDALONE
					jsr		musicPlayer+8
				ENDC
            popall
    rte

	ENDC

title_mainloop
.w2
	tst.w   $466.w
    beq     .w2
    	move.w	#0,$466.w
    	subq.w	#1,effect_vbl_counter
    	blt		.next
    	jmp		.w2
.next
	rts


title_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
    pushall
    clr.b   $fffffa1b.w             
    bset    #0,$fffffa07.w          
    bset    #0,$fffffa13.w
    move.l  #timer_b_top_cinema,$120    ; schedule timer b to open lower
    move.b  #1+50-2,$fffffa21.w        
    bclr    #3,$fffffa17.w          
    move.b  #8,$fffffa1b.w          

    movem.l	motuspal,d0-d7
    movem.l	d0-d7,$ffff8240
    jsr		generateColorsCalced
    cmp.w	#$4e75,generateColorsCalced
    bne		.skipout
    	jsr		generateColorsCalcedFadeOut
.skipout

	tst.w	horSplitFadeOutDone
	bne		.kk
		move.w	#$2700,sr
		move.l	#title2_vbl,$70
		move.w	#$2300,sr
.kk

    move.l  screenpointer2,$ffff8200


    popall
    rte

title2_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	pushall
	    clr.b   $fffffa1b.w  
		movem.l	mpal,d0-d7
		movem.l	d0-d7,$ffff8240

		jsr		copyM
				IFNE	STANDALONE
					jsr		musicPlayer+8
				ENDC


	popall
	rte
;--------------
;DEMOPAL - palette used after otus has faded away
;--------------
mpal		dc.w	$000,$011,$111,$112,$211,$212,$311,$312,$214,$121,$222,$223,$322,$521,$655,$777
	

copyM
	move.l	screenpointer2,a6
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5

	add.w	#51*160,a6
	move.w	#100-1,d7
.lll
.x set 9*8
		movem.l	d0-d6/a0-a5,.x(a6)									;12*4 = 48
		movem.l	d0-d3,.x+48(a6)
		lea		160(a6),a6
	dbra	d7,.lll
	jsr		drawM

	move.w	#$4e75,copyM
	rts

copyMotus
;    lea     motus+128,a0
	move.l	motuspointer,a0
	add.w	#128,a0
    move.l  screenpointer2,a1
    move.w  #200-1,d7
.loop
    REPT 20
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
    ENDR
    dbra    d7,.loop

    movem.l motuspal,d0-d7
    movem.l d0-d7,$ffff8240
    rts




init_title
	move.l	screen2,d0
	add.l	#$10000,d0
	move.l	d0,letter_m_pointer
	add.l	#5400,d0
	move.l	d0,motuspointer

    move.w  #$2700,sr
    move.l  #.wvbl,$70
    move.w  #$2300,sr

    lea		mbuffer,a0    
    move.l	letter_m_pointer,a1
    jsr		cranker

    lea		motuspulse2,a0
    move.l	motuspointer,a1
    jsr		cranker

    jsr     copyMotus
    move.w  #$2700,sr
    move.l  #title_vbl,$70
    move.w  #$2300,sr
    rts
.vblwaiter	dc.w	20

.wvbl
    addq.w  #1,$466.w
    addq.w	#1,cummulativeCount
	IFNE	STANDALONE
			    pushall
		jsr		musicPlayer+8
				popall
	ENDC
    rte



	IFEQ	STANDALONE
letter_m_pointer	ds.l	1
drawM
;	lea		mbuffer,a0
	move.l	letter_m_pointer,a0
	move.l	screenpointer2,a1
	add.w	#33*160+40,a1
	move.w	#135-1,d7
.cp
		movem.l	(a0)+,d0-d6	
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.l	d3,(a1)+
		move.l	d4,(a1)+
		move.l	d5,(a1)+
		move.l	d6,(a1)+

		movem.l	(a0)+,d0-d2
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+

;		lea		160-40(a0),a0
		lea		160-40(a1),a1
	
	dbra	d7,.cp
	move.w	#$4e75,drawM
	rts

mbuffer		incbin	"data/smfxmotus/letter_m.crk"

	ENDC

    opt o-
timer_b_top_cinema
    clr.b   $fffffa1b.w             
    clr.b   $fffffa15.w    
    pusha0         
    pushd1         
    pushd2         
        move.w  #$2100,sr           ;Enable HBL
        stop    #$2100              ;Wait for HBL
        move.w  #$2700,sr           ;Stop all interrupts    lea $ffff8209.w,a0          ;Hardsync



    lea $ffff8209.w,a0          ;Hardsync
    moveq   #127,d1             ;
.sync:      
    tst.b   (a0)                ;
    beq.s   .sync               ;
    move.b  (a0),d2             ;
    sub.b   d2,d1               ;
    lsr.l   d1,d1               ;
   pushall
    movem.l motuspal(pc),d1-d7/a0     ;80         16
    move.l  #$07000707,a4
;    lea     $ffff8240+12*2,a4
;    lea     $ffff8240+14*2,a5

    move.l  #$0,a6

;    move.l  #$7700770,a1
;    move.l  #$7700770,a2

    dcb.w   63-29-32,$4e71
        move.w  #100-1,d0

        ; O a2,a1       14/12
        ; T a4,a5       yyyyyyyyyyyyyyyyy
        ; U
        ; S

.loopx
;       rept    197
;        movem.l motus+4,d1-d7/a0     ;80         16
        movem.l d1-d7/a0,$ffff8240
        movem.l colorsCalced(pc),d1-d7/a0

        dcb.w   40-19,$4e71
        move.l  d2,$ffff8240+12*2                        ; 
        move.l  d1,$ffff8240+14*2

        move.l  d3,$ffff8240+8*2
        move.l  d4,$ffff8240+10*2

        move.l  d6,$ffff8240+12*2 
        move.l  d5,$ffff8240+14*2 

        move.l  d7,$ffff8240+8*2
        move.l  a0,$ffff8240+10*2
        dcb.w   34-21,$4e71
        movem.l motuspal(pc),d1-d7/a0     ;80         16

;       endr

        dbra    d0,.loopx
        movem.l	d1-d7/a0,$ffff8240
;        move.w  #$300,$ffff8240
				IFNE	STANDALONE
					jsr		musicPlayer+8
				ENDC
				popd2
				popd1
				popa0
	popall
    rte
    opt o+

;--------------
;DEMOPAL - color palette for the horizontal letters during the hardsync
;--------------
colorsCalced   
	dc.l	$7000111		;		O
	dc.l	$6550777			
	dc.l	$7000707		;		T
	dc.l	$7700070
    dc.l    $5750575        ;   	U
    dc.l    $5750575
    dc.l	$7550755		;		S
    dc.l	$7550755		

;--------------
;DEMOPAL - color palette fade for the individual letters for the hardsync, that generate the above table
;--------------
fadePal
	; target:
	;		$655,$777,$322,$111
	dc.w	$000,$000,$000,$000
	dc.w	$000,$111,$000,$000
	dc.w	$100,$222,$000,$000
	dc.w	$211,$333,$000,$000
	dc.w	$322,$444,$000,$000
	dc.w	$433,$555,$100,$000
	dc.w	$544,$666,$211,$000
	dc.w	$655,$777,$322,$111
	dc.w	$655,$777,$322,$111

WAITERBASE	equ 50
WAITERDIFF	equ 10
WAITERCONST	equ 1

generateColorsCalcedFadeOut
	subq.w	#1,.waiter
	bge		.ks
	lea		fadePal,a6
	lea		colorsCalced,a1

	move.l	a6,a0
	add.w	offsetO,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	a6,a0
	add.w	offsetT,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	a6,a0
	add.w	offsetU,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	a6,a0
	add.w	offsetS,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	subq.w	#1,.www
	bge		.ks
		move.w	#1,.www
	subq.w	#8,offsetO
	bge		.ko
		move.w	#0,offsetO
.ko

	subq.w	#8,offsetT
	bge		.kt
		move.w	#0,offsetT
.kt

	subq.w	#8,offsetU
	bge		.ku
		move.w	#0,offsetU
.ku

	subq.w	#8,offsetS
	bge		.ks
		move.w	#0,offsetS
		move.w	#0,horSplitFadeOutDone
.ks




	rts
.waiter	dc.w	40
.www	dc.w	1

horSplitFadeOutDone	dc.w	-1


generateColorsCalced
	lea		fadePal,a6
	lea		colorsCalced,a1
	; first do O
	move.l	a6,a0
	add.w	offsetO,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	a6,a0
	add.w	offsetT,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	a6,a0
	add.w	offsetU,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	a6,a0
	add.w	offsetS,a0
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	subq.w	#1,.waiterO
	bge		.skipO
		move.w	#WAITERCONST,.waiterO
		add.w	#8,offsetO
		cmp.w	#7*8,offsetO
		ble		.skipO
			move.w	#7*8,offsetO
.skipO

	subq.w	#1,.waiterT
	bge		.skipT
		move.w	#WAITERCONST,.waiterT
		add.w	#8,offsetT
		cmp.w	#7*8,offsetT
		ble		.skipT
			move.w	#7*8,offsetT
.skipT

	subq.w	#1,.waiterU
	bge		.skipU
		move.w	#WAITERCONST,.waiterU
		add.w	#8,offsetU
		cmp.w	#7*8,offsetU
		ble		.skipU
			move.w	#7*8,offsetU
.skipU
		
	subq.w	#1,.waiterS
	bge		.skipS
		move.w	#WAITERCONST,.waiterS
		add.w	#8,offsetS
		cmp.w	#7*8,offsetS
		ble		.skipS
			move.w	#7*8,offsetS
			move.w	#$4e75,generateColorsCalced
.skipS
	rts
.waiterO	dc.w	WAITER_O
.waiterT	dc.w	WAITER_T
.waiterU	dc.w	WAITER_U
.waiterS	dc.w	WAITER_S
offsetO		dc.w	0
offsetT		dc.w	0
offsetU		dc.w	0
offsetS		dc.w	0

timer_b_bot_cinema
    move.w  #$0,$ffff8240

    rte

;--------------
;DEMOPAL - initial palette for when the M is drawn, different from the next part
;--------------
motuspal	
	dc.w	$000,$011,$112,$223,$211,$212,$311,$214,$655,$777,$322,$111,$700,$007,$121,$521

	section DATA
;motus       incbin  "data/title/motuspulse2.neo"
motuspulse2       incbin  "data/title/motuspulse2.crk"
	even
motuspointer	ds.l	1

    IFEQ    STANDALONE
        include     lib/lib.s
        include		lib/cranker.s
    ENDC


    IFEQ    STANDALONE
	section BSS
    rsreset
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
cummulativeCount	ds.w	1
    ENDC
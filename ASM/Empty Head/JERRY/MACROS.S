;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~	MACROS			~
;~ SETUP CODE, CHANGE SCR etc.		~
;~ BEGIN: 15.02.96	LAST UPDATE: 15.02.96	~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;include e:\devpac\incdir\CACHE.S

	ifd STE
	include BLITTER.S
	endc

	include gxb.s

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ SET GRAPHICS MODE			~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STlowon	macro
;DONTSWITCHRES ;no switching of resolution (testing)	
	move.w #15,d7 ;kopiruj vsech 15 barev
	lea SAVE_COLORS+32,a5
.BACK_UP	move.w #-1,-(a7)
	move.w d7,-(a7)
	move.w #7,-(a7)
	trap #14
	addq.l #6,a7
	move.w d0,-(a5)
	dbf d7,.BACK_UP
	
	section bss
SAVE_COLORS: ds.b 32 ;here save colors
SCRLOCAT:	ds.l 1 ;location of second screen
SAVE44E:	ds.l 1 ;scr ADDR backup
SCREEN1:	ds.l 1 ;TWO POINTERS TO SCREEN
SCREEN2:	ds.l 1
GEM_VIDEO:	ds.l 1 ;video mode
VGAPAL:	ds.w 1 ;flag of VGA or RGB and NTSC or PAL
	section text
	
	Mxalloc MX_STRAM,32256
	move.l d0,SCRLOCAT

	ifd TOS404
	ifD MhzST
	move.b #$0,$ffff8007.w
	;bsr CACHE_OFF
	elseif
	;bsr CACHE_ON
	endc
	endc

	ifnd DEBUG
	cmp.w #5,MACHINE  ;FALCON?
	bne.s .SET_CLASSIC_ST

	move.w #-1,-(a7)
	move.w #88,-(a7)
	trap #14
	addq #4,sp
	move.w d0,GEM_VIDEO
	and.w #$30,d0 ;VGA & PAL save
	move.w d0,VGAPAL	

	move.w VGAPAL,d0
	move.w d0,d1
	and.w #$20,d1 ;only VGA part of flags
	tst.w d1
	beq.s .START_FROM_TV
	add.w #$100,d0 ;double line

.START_FROM_TV:
	add.w #$80+2,d0
	move.w d0,-(a7)
	move.w #-1,-(a7)
	move.l #-1,-(a7)
	move.l #-1,-(a7)
	move.w #5,-(a7)
	ifnd DONTSWITCHRES
	trap #14
	endc
	add.l #12,a7
	move.w #88,-(a7)
	ifnd DONTSWITCHRES
	trap #14
	endc
	addq.l #4,a7
	bra.s .AFTER_SET_ST

.SET_CLASSIC_ST:
	move.w #-1,-(a7)
	move.l #-1,-(a7)
	move.l #-1,-(a7)
	move.w #5,-(a7)
	trap #14
	add.l #12,a7
	move.w d0,GEM_VIDEO

	move.w #0,-(a7) ;ST SLOW
	move.l #-1,-(a7)
	move.l #-1,-(a7)
	move.w #5,-(a7)
	ifnd DONTSWITCHRES
	trap #14
	endc
	add.l #12,a7

	
.AFTER_SET_ST:
	endc
	move.l $44e.w,SAVE44E

	move.l SCRLOCAT,d0
	add.l #255,d0
	and.l #$fffff00,d0
	 ifd DEBU
	move.l $44e.w,SCREEN2
	move.l $44e,a0
	bsr NEWFROM_A0
	  elseif
	move.l d0,SCREEN2 ;first screen
	move.l d0,a0
	bsr NEWFROM_A0
	 endc
	move.l $44e,SCREEN1
	endm

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ RESET GRAPHICS MODE			~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

STlowoff	macro

	ifd TOS404
	ifD MhzST
	move.b #65,$ffff8007.w
	bsr CACHE_ON
	endc
	endc
	
	move.w #15,d7 ;kopiruj vsech 15 barev
	lea SAVE_COLORS+32,a5

.BACK_DOWN:	
	move.w -(a5),-(a7)
	move.w d7,-(a7)
	move.w #7,-(a7)
	trap #14
	addq.l #6,a7
	dbf d7,.BACK_DOWN
	move.w #37,-(a7)
	trap #14
	addq.l #2,a7 ;vbl

	cmp.w #5,MACHINE  ;FALCON?
	bne.s .RESET_CLASSIC_ST

	move.w GEM_VIDEO,-(a7)
	move.w #-1,-(a7)
	move.l SAVE44E,-(a7)
	move.l SAVE44E,-(a7)
	move.w #5,-(a7)
	trap #14
	add.l #12,a7

	;move.w #-3,-(a7)
	;move.l #-1,-(a7)
	;move.l #-1,-(a7)
	;move.w #5,-(a7)
	;trap #14
	;add.l #12,a7

	move.w #88,-(a7)
	trap #14
	addq.l #4,a7
	bra.s .RES_CHANGED

.RESET_CLASSIC_ST:
	move.w GEM_VIDEO,-(a7)
	move.l SAVE44E,-(a7)
	move.l SAVE44E,-(a7)
	move.w #5,-(a7)
	trap #14
	add.l #12,a7
.RES_CHANGED:
	Mfree SCRLOCAT
	endm


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ CHANGE SCREEN SCREEN1 ACTUAL		~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CHANGE_SCR:
	movem.l SCREEN1,d0-d1
	exg d0,d1
	movem.l d0-d1,SCREEN1
	lea $ffff8201.w,a1
	lsr.l	#8,d0
	movep.w d0,(a1) ;the best method & fastest to switch scr
	move.l $466.w,D0 ;wait for wvbl
.VBL:
	cmp.l $466.w,D0
	beq.s .VBL

	rts

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ CLEAR 32 KB IN SCREEN2  (sometimes A0)	~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

NEW:	
	move.l SCREEN2,a0		;scr ADDR
NEWFROM_A0: ;if we want clear 32 kb from any other location, so put to a0 other adress & call here
	ifnd STE
	lea CLR_BUF,a1
	movem.l CLR_BUF,d1-d7/a2-a4	;mazaci buffer
	move.w #39,d0		;buffer kopirovat 45x
	lea 32000(a0),a0
CLR:	rept 20
	movem.l d1-d7/a2-a4,-(a0)	
	endr
	dbf d0,CLR
	else
	bsr BLITTER_CLR_32KB
	endc
	rts

	SECTION BSS
CLR_BUF:	ds.b 52    ;52 clear bytes
	SECTION TEXT

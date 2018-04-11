
;  
; 
;
; TalkTalk2 v1.1 - MegaSTE fixed by ggn
; 2015-11-03: Work started on rmac conversion
;
;


;
; ToDo, conversion to rmac
; -------------------------
; # Crash just after footsteps
; # Blitter "fadeout" after loading is trashed
;
; Done
; -----
;

macro fail
  print \1
  exit -1
  endm

macro break
  clr.b $ffffc123
  endm

enableggncredits equ 1

developerpath equ 0						; change to 0 for floppy version = path set to "tlktlk2.d8a\\"

skipaheadtobees equ 0					; 1 to skip to bees, i e test music
skipaheadtohalftempo equ 0		; 1 to skip to the "soft" part with half-tempo music
skipaheadtoend equ 0					; 1 to skip to end credits

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

enablerasters equ 0
enablemusic equ 1
enableice	equ 1
enableice1pos	equ 1
enablexp4 equ 1
enablepixels equ 0
enablemath equ 0
enablehbl equ 1

credits1doosize equ 1445
credits2doosize equ 5252
credits3doosize equ 5608
credits4doosize equ 3776
credits5doosize equ 8276
credits6doosize equ 4200
credits7doosize equ 1096

enableforcemediachange equ 1

startofcode:
	.text

	include "pushpop.s"

	include "i_macros.s"

	jmp gogogoforitgogogo
	dc.b "  Excellence In Art 2009-2010  "
	even
gogogoforitgogogo:

	lea smokescreen1,a0
	move.l a0,screenaddress
	lea smokescreen2,a0
	move.l a0,smokescreenaddress
	jsr clearsmokescreennoblitter
	jsr swapscreens
	jsr clearsmokescreennoblitter

	lea vblextrablank,a0
	move.l a0,vblextraaddress

	move.w #0,musicinvbl
	move.w #0,musicinvblextra
	lea maxiamiser,a0
	move.l a0,musicextra
	move.w #0,copperenabled

	if enablemusic
	lea loadermusic,a0
	move.l a0,musicinit
	add.l #4,a0
	move.l a0,musicexit
	add.l #4,a0
	move.l a0,musicvbl
	add.l #$b0,a0
	move.l a0,musicsyncbyte
	endif

	bsr setupcopperlist

	include "start.s"

	setpalette allblackpal

;///////////////////////////////////////////////////////////
;//
;// Let`s go!

	if enablemusic
  	pusha0
  	move.l musicinit,a0
  	jsr (a0)			; init music
  	popa0
  	move.w #1,musicinvbl ; every vbl, music is played
	endif

	jsr resetblitter

	jsr clearscreen

	setpalette allblackpal

;-----

;	bra doblitmask

;	bra doshiny
;	bra docluster
;	bra dochess
;	bra doposresp
;	bra doflips
;	bra dobees
;	bra dobars
;	bra dospin

;	bra loaddataerrormessage

	bsr loaddata

;//// MegaSTE trick by GGN, thanks for that!
	move.l $8,-(sp)
	move.l #ggntrap,$8
	clr.b $ffff8e21
ggntrap:
	move.l (sp)+,$8

	if skipaheadtoend
	move.w #$0070,currentpalette
		deicelealea threedeecuttbi,threedeecuttable
	move.w #$0060,currentpalette
		jsr SegmentedLineSetup
	move.w #$0050,currentpalette
		runtimeload credits1doo,credits1doosize,deiceme
	move.w #$0040,currentpalette
		runtimeload credits2doo,credits2doosize,deiceme
	move.w #$0030,currentpalette
		runtimeload credits3doo,credits3doosize,deiceme
	move.w #$0040,currentpalette
		runtimeload credits4doo,credits4doosize,deiceme
	move.w #$0050,currentpalette
		runtimeload credits5doo,credits5doosize,deiceme
	move.w #$0060,currentpalette
		runtimeload credits6doo,credits6doosize,deiceme
	move.w #$0070,currentpalette
		runtimeload credits7doo,credits7doosize,deiceme
	move.w #$0050,currentpalette
		runtimeload evilsintable,10240,dontdeiceme
	move.w #$0040,currentpalette
		runtimeload evilblobtable,2254,deiceme
	move.w #$0030,currentpalette
		lea threedeecuttable,a0
		lea threedeecuttablemirrored,a1
.oneframe:
		cmp.w #-1,(a0)
		beq .alldone
.oneline:
		cmp.w #-1,(a0)
		beq .endofframe
		move.l #0,d0
		move.l d0,d1
		move.l d0,d2
		move.l d0,d3
		move.w (a0)+,d0
		move.w (a0)+,d1
		move.w (a0)+,d2
		move.w (a0)+,d3
		move.l #319,d4
		sub.l d0,d4
		move.w d4,(a1)+
		move.l #199,d4
		sub.l d1,d4
		move.w d4,(a1)+
		move.l #319,d4
		sub.l d2,d4
		move.w d4,(a1)+
		move.l #199,d4
		sub.l d3,d4
		move.w d4,(a1)+
		bra .oneline
.endofframe:
		add.l #2,a0
		move.w #-1,(a1)+
		bra .oneframe
.alldone:
		move.w #-1,(a1)+
	move.w #$0040,currentpalette
		jsr blob_init
	move.w #$0050,currentpalette
		bra doendcredits
	endif


;	bsr dorotbars
;	bra endloop


	if skipaheadtohalftempo
		bra skiptohalftempo
	endif

	if skipaheadtobees
		bra skiptobees
	endif

;	move.w #$00f0,currentpalette

	jsr clearscreen
	jsr clearsmokescreen
	lea smokescreen2,a0
	move.l a0,screenaddress
	
	if enablemusic
  	move.w #0,musicinvbl
  	move.l musicexit,a0
  	jsr (a0)
  	lea intromusic,a0
  	move.l a0,musicinit
  	add.l #4,a0
  	move.l a0,musicexit
  	add.l #4,a0
  	move.l a0,musicvbl
  	add.l #$b0,a0
  	move.l a0,musicsyncbyte
  	move.l musicinit,a0
  	jsr (a0)
  	move.w #1,musicinvbl
	endif

	bsr introdointro
	;break
	bsr dohandsequence

skiptobees:
	bsr beesdobeesequence


;--- unpack stuff while bees keep everybody occupied

	lea postintrodata,a0
	move.l #627996/4-1,d7
.clearintroarea:
	move.l #0,(a0)+
	dbra d7,.clearintroarea

	lea talktalk2logoxi4,a0
	lea talktalk2logoxp4,a1
	jsr deice

	deicelealea labels1doi,labels
	deicelealea labels2doi,labels+32000
	deicelealea labels3doi,labels+64000
	deicelealea labels4doi,labels+96000

	deicelealea labeltextdoi,labeltextdoo

;-- everything unpacked, hopefully

	syncwait $ee

	bsr clearbeescopperlist

	vblinstall vblextrablank

	move.w #0,copperenabled
	setpalette allblackpal

	lea smokescreen1,a0
	jsr clear32000noblitter
	move.l a0,screenaddress
	lea smokescreen2,a0
	jsr clear32000noblitter
	move.l a0,smokescreenaddress

	bsr dotalktalk2logo

	bsr dochurchlogoandtopic

	bsr dolabeltext

	deicelealea kinseyxi4,kinseyxp4

.waitforlabeltext:
	cmp.l #-1,labeltextlinecounter
	bne .waitforlabeltext
	vblinstall vblextrablank

	bsr doposresp

	deicelealea acknowxi4,acknowxp4
	deicelealea urgayxi4,urgayxp4

.waitforposresp:
	jsr wait4vbl
	cmp.w #5,posrespframe
	bne .waitforposresp

	deicelealea otherurxi4,otherurxp4

	vblinstall vblextrablank

	bsr doacknow

	resetframecount
	deicelealea bull2xi4,bull2xp4
	waitforframecount 39+16

	vblinstall vblextrablank

	bsr dokinsey
	bsr dourgay

	resetframecount
	waitforframecount 40

	bsr dootherur

	resetframecount
	waitforframecount 45+16
	fade2palette allblackpal,1

	bsr doflips

	move.w #0,copperenabled

skiptohalftempo:
	if skipaheadtohalftempo
		bsr clearscreennoblitter
		move.w #$06f6,currentpalette
		deicelealea ifxi4,ifxp4
		move.w #$03f3,currentpalette
		deicelealea bull1xi4,bull1xp4
		move.w #$00f0,currentpalette
		deicelealea bull2xi4,bull2xp4
		move.w #$0,$ffff8240
		move.w #$0,currentpalette
	endif

	if skipaheadtohalftempo
		setpalette allwhitepal
  else
		fade2palette allwhitepal,3
	endif

	if skipaheadtohalftempo=0
		deicelealea bull1xi4,bull1xp4
	endif

	jsr clearscreennoblitter
	jsr clearsmokescreennoblitter
	setpalette wbpal

	bsr setupbullifbullvbl
	vblwait 1
	vblinstall dobullifbullvbl

	vblwait 2

	runtimeload clusterxp4,240362,deiceme

;	flashfromwhite

	deicelealea thesanxi4,thesanxp4
	deicelealea thesis1doi,thesis1doo
	deicelealea thesis2doi,thesis2doo
	deicelealea earthdoi,earthdoo
	deicelealea earthbwdoi,earthbwdoo
	deicelealea waterdroptableiced,waterdroptable
	bsr setupcopperlist

;	flashfromwhite

.waitforbibtobedone:
	cmp.w #1,biballdone
	bne .waitforbibtobedone

	resetframecount

	lea thesisanimarea,a0
	bsr clear32000noblitter

	lea thesanxp4,a0
	lea thesisanimarea,a1
	jsr unpackxp4
	move.l a0,a5
	lea thesisdoooffsettable,a6
	move.l #5-1,d7
.unpackthesis:
	lea thesisanimarea,a0
	add.l (a6)+,a0
	lea thesisanimarea,a1
	add.l (a6),a1
	bsr copy32000noblitter
	move.l a5,a0
	lea thesisanimarea,a1
	add.l (a6),a1
	jsr unpackxp4
	move.l a0,a5
	dbra d7,.unpackthesis

;	bra dospringbounce
	
	waitforframecount 85-8

	fade2palette allblackpal,1
	vblwait 8
	bsr clearscreennoblitter
	bsr clearsmokescreennoblitter

	bsr clearcopperlist
	move.l screenaddress,copperbottomscreenaddress
	move.w #1,copperenabled

	setpalette bwpal	

	if skipaheadtohalftempo=0
	syncwait $ee
	endif

	lea thesis1doo,a0
	bsr dohalvesbouncein

	vblwait 1
	copy2copperlea thesis1doo,0

	if skipaheadtohalftempo=0
	  syncwait $05
	endif
	setpalette allwhitepal
	fade2palette bwpal,1
	vblwait 8
	setpalette allwhitepal
	fade2palette bwpal,1
	vblwait 8

	copy2copperlea thesisanimarea,0
	lea thesisanimarea,a0
	move.l a0,copperbottomscreenaddress

	vblwait 23

	lea thesisanimarea,a0
	bsr dowaterdropsequence
	vblwait 22
	lea thesisanimarea,a0
	bsr spindospindown
	lea thesisanimarea+32000,a0
	bsr spindospinup
	vblwait 22
	lea thesisanimarea+32000,a0
	bsr dowaterdropsequence
	resetframecount
	lea thesisanimarea+32000,a0
	lea thesisanimarea+64000,a1
	bsr dobouncebetweencoppers
	waitforframecount 48

	lea thesisanimarea+64000,a0
	bsr dowaterdropsequence
	vblwait 22
	lea thesisanimarea+64000,a0
	bsr spindospindown
	lea thesisanimarea+96000,a0
	bsr spindospinup
	vblwait 22
	lea thesisanimarea+96000,a0
	bsr dowaterdropsequence
	resetframecount
	lea thesisanimarea+96000,a0
	lea thesisanimarea+128000,a1
	bsr dobouncebetweencoppers
	waitforframecount 48

	lea thesisanimarea+128000,a0
	bsr dowaterdropsequence
	vblwait 22
	lea thesisanimarea+128000,a0
	bsr spindospindown
	lea thesisanimarea+160000,a0
	bsr spindospinup
	vblwait 22
	lea thesisanimarea+160000,a0
	bsr dowaterdropsequence

	lea thesisanimarea+160000,a0
	bsr spindospindown

	bsr clearcopperlist
;	vblwait 10

	move.w #$0fff,currentpalette+2

	lea earthbwdoo,a0
	bsr spindospinup
	lea earthbwdoo,a0
	bsr spindospindown
	setpalette earthpal
	lea earthdoo,a0
	bsr spindospinup

	lea earthdoo,a0
	bsr spindospindown

	setpalette bwpal

	lea thesis2doo,a0
	bsr spindospinup

	lea thesis2doo,a0
	bsr copy2screennoblitter

	move.w #0,copperenabled

	vblwait 1
	jsr SegmentedLineSetup

	rept 0
	lea thesis2doo,a0
	bsr dohalvesbouncein
	copy2copperlea thesis2doo,0
	endr

	vblwait 40






	bsr dorotbars
	
	;break

	bsr barsdobarssequence

	bsr docluster

	bsr doshiny
	;break

	bra doendcredits





	bra endloop






doblitmask:
	rept 0
	setpalette earthpal
	deiceleasmokescreen earthdoipic
	move.l smokescreenaddress,a0
	add.l #160*25,a0
	move.l screenaddress,a1
	add.l #160*25,a1
	move.l #2,d0
	move.l #3,d1
	bsr copy24000maskedanimation
	bra endloop
	endr







doshiny:
	setpalette allblackpal
	vblwait 1
	move.w #0,copperenabled
	move.l screenaddress,a0
	bsr clearscreen
	vblwait 1
	setpalette kalmspal
	deiceleasmokescreen kalmsdoi
	move.l smokescreenaddress,a0
	move.l screenaddress,a1
	move.l #1,d0 ; animation
	move.l #2,d1 ; vbls between frames
	bsr copy32000maskedanimation

	lea threedeecuttable,a6
	move.l a6,shinyloada6
	move.l shinyloadwaiter,shinyloadcounter
	move.w #1,shinyloadactive
	vblinstall shinyloadvbl

	runtimeload shiny01,15084,deiceme
	runtimeload shiny02,15151,deiceme
	runtimeload shiny03,15153,deiceme
	runtimeload shiny04,15637,deiceme
	runtimeload shiny05,16670,deiceme
	runtimeload shiny06,16761,deiceme
	runtimeload shiny07,16426,deiceme
	runtimeload shiny08,16298,deiceme
	runtimeload shiny09,16396,deiceme
	runtimeload shiny10,16237,deiceme
	runtimeload shiny11,15841,deiceme
	runtimeload shiny12,15305,deiceme

.shinywait:
	cmp.w #0,shinyloadactive
	bne .shinywait

	setpalette allwhitepal

	lea shinypal,a0
	bsr fadepalettessetup

	bsr clearscreen
	bsr clearsmokescreen

	lea shiny01,a0
	move.l a0,shinya0
	resetframecount	
	vblinstall shinybubblesvbl

	deicelealea please00doi,please00doo
	deicelealea please01doi,please01doo
	deicelealea please02doi,please02doo
	deicelealea please03doi,please03doo
	deicelealea please04doi,please04doo
	deicelealea please05doi,please05doo
	deicelealea please06doi,please06doo
	deicelealea please07doi,please07doo
	deicelealea please08doi,please08doo
	deicelealea please09doi,please09doo
	deicelealea please10doi,please10doo
	deicelealea please11doi,please11doo
	deicelealea please12doi,please12doo

	resetframecount	
	vblinstall vblextrablank

.loop:
	vblwait 1
	bsr shinybubblesvbl

	framebsr 101,shinyplease00
	framebsr 170,shinyplease01
	framebsr 250,shinyplease02

	framebsr 490,shinyplease03
	framebsr 580,shinyplease04
	framebsr 660,shinyplease05

	framebsr 900,shinyplease06
	framebsr 980,shinyplease07
	framebsr 1100,shinyplease08

	framebsr 1250,shinyplease09
	framebsr 1350,shinyplease10
	framebsr 1420,shinyplease11

	framebsr 1600,shinyplease12a
	framebsr 1680,shinyplease12b

	cmp.l #1720,framecounter
	blt .loop

	vblinstall shinybubblesvbl

	runtimeload credits1doo,credits1doosize,deiceme
	runtimeload credits2doo,credits2doosize,deiceme
	runtimeload credits3doo,credits3doosize,deiceme
	runtimeload credits4doo,credits4doosize,deiceme
	runtimeload credits5doo,credits5doosize,deiceme
	runtimeload credits6doo,credits6doosize,deiceme
	runtimeload credits7doo,credits7doosize,deiceme

	runtimeload evilsintable,10240,dontdeiceme
	runtimeload evilblobtable,2254,deiceme

	lea threedeecuttable,a0
	lea threedeecuttablemirrored,a1
.oneframe:
	cmp.w #-1,(a0)
	beq .alldone
.oneline:
	cmp.w #-1,(a0)
	beq .endofframe
	move.l #0,d0
	move.l d0,d1
	move.l d0,d2
	move.l d0,d3
	move.w (a0)+,d0
	move.w (a0)+,d1
	move.w (a0)+,d2
	move.w (a0)+,d3
	move.l #319,d4
	sub.l d0,d4
	move.w d4,(a1)+
	move.l #199,d4
	sub.l d1,d4
	move.w d4,(a1)+
	move.l #319,d4
	sub.l d2,d4
	move.w d4,(a1)+
	move.l #199,d4
	sub.l d3,d4
	move.w d4,(a1)+
	bra .oneline
.endofframe:
	add.l #2,a0
	move.w #-1,(a1)+
	bra .oneframe
.alldone:
	move.w #-1,(a1)+

	jsr blob_init

	rept 0
	flashfromwhite
	endr

	fade2palette allwhitepal,3

	vblinstall vblextrablank
	rts



doendcredits:
	bsr clearscreen
	bsr clearsmokescreen

	lea creditspal,a0
	bsr fadepalettessetup

	lea threedeecuttable,a6
	lea threedeecuttablemirrored,a5
	lea credits1doo,a4

.creditsloop:
	vblwait 1
	bsr fadepalettesdoonefade

	pushall
	jsr blob_main
	popall

	move.l a4,a0
	move.l smokescreenaddress,a1
	add.l #160*25,a1
	bsr copy2bpls

	add.l #160,a4
	cmp.l #creditswrappoint,a4
	blt .nopes
	lea credits1doo,a4
.nopes:

;---
	pusha4
	move.l smokescreenaddress,a0
	add.l #(160*25)+4,a0
	bsr clearshinyloadlines

	cmp.w #-1,(a6)
	bne .lineloop
	lea threedeecuttable,a6
	lea threedeecuttablemirrored,a5
.lineloop:
	cmp.w #-1,(a6)
	beq .nextframe
	move.l a6,a0
	move.l smokescreenaddress,a1
	add.l #4,a1
	jsr SegmentedLine

	rept 1
  	move.l a5,a0
  	move.l smokescreenaddress,a1
  	add.l #4,a1
  	jsr SegmentedLine
	endr

	lea tempbuffer1,a0
	move.w (a5),(a0)+
	move.w 2(a6),(a0)+
	move.w 4(a5),(a0)+
	move.w 6(a6),(a0)+

	move.w (a6),(a0)+
	move.w 2(a5),(a0)+
	move.w 4(a6),(a0)+
	move.w 6(a5),(a0)

	lea tempbuffer1,a0
	move.l smokescreenaddress,a1
	add.l #4,a1
	jsr SegmentedLine

	lea tempbuffer2,a0
	move.l smokescreenaddress,a1
	add.l #4,a1
	jsr SegmentedLine

	add.l #8,a6
	add.l #8,a5
	bra .lineloop

.nextframe:
	add.l #2,a6
	add.l #2,a5
	popa4
;---

	bsr swapscreens

	bra .creditsloop





doendcredits_old:
	bsr clearscreen
	bsr clearsmokescreen

	setpalette creditspal

	lea threedeecuttable,a6
	lea threedeecuttablemirrored,a5
	lea credits1doo,a4

.creditsloop:

	vblwait 1

	pushall
	jsr blob_main
	popall

	move.l a4,a0
	move.l smokescreenaddress,a1
	add.l #160*25,a1
	bsr copy2bpls

	add.l #160,a4
	cmp.l #creditswrappoint,a4
	blt .nopes
	lea credits1doo,a4
.nopes:

;---
	pusha4
	move.l smokescreenaddress,a0
	add.l #(160*25)+4,a0
	bsr clearshinyloadlines

	cmp.w #-1,(a6)
	bne .lineloop
	lea threedeecuttable,a6
	lea threedeecuttablemirrored,a5
.lineloop:
	cmp.w #-1,(a6)
	beq .nextframe
	move.l a6,a0
	move.l smokescreenaddress,a1
	add.l #4,a1
	jsr SegmentedLine

	rept 1
	move.l a5,a0
	move.l smokescreenaddress,a1
	add.l #4,a1
	jsr SegmentedLine
	endr

	lea tempbuffer1,a0
	move.w (a5),(a0)+
	move.w 2(a6),(a0)+
	move.w 4(a5),(a0)+
	move.w 6(a6),(a0)+

	move.w (a6),(a0)+
	move.w 2(a5),(a0)+
	move.w 4(a6),(a0)+
	move.w 6(a5),(a0)

	lea tempbuffer1,a0
	move.l smokescreenaddress,a1
	add.l #4,a1
	jsr SegmentedLine

	lea tempbuffer2,a0
	move.l smokescreenaddress,a1
	add.l #4,a1
	jsr SegmentedLine

	add.l #8,a6
	add.l #8,a5
	bra .lineloop

.nextframe:
	add.l #2,a6
	add.l #2,a5
	popa4
;---

	bsr swapscreens

	bra .creditsloop


tempscreenaddress:
	dc.l 0

tempbuffer1: ; mirror x
	dcb.w 4,0
tempbuffer2: ; mirror y
	dcb.w 4,0

copy2bpls:
; In: a0 - source address
;     a1 - destination address
	move.w #2,$ffff8a20 ;source x inc
	move.w #6,$ffff8a22 ;source y inc
	move.l a0,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #6,$ffff8a30 ;dest y inc
	move.l a1,$ffff8a32 ;destination address
	move.w #2,$ffff8a36 ;x count (n words per line to copy)
	move.w #150*20,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000010,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000011,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	rts


shinyplease12b:
	move.l screenaddress,a6
	lea please12doo,a0
	move.l a0,screenaddress
	setpalette pleasepaltrash1
	vblwait 6
	sub.l #160*15,screenaddress
	setpalette pleasepalred
	vblwait 2
	setpalette shinypal
	vblwait 2
	add.l #160*15,screenaddress
	setpalette pleasepalgreen
	vblwait 8
	move.l a6,screenaddress
	setpalette shinypal
	rts

shinyplease12a:
	move.l screenaddress,a6
	lea please12doo,a0
	move.l a0,screenaddress
	setpalette pleasepaltrash1
	vblwait 6
	setpalette pleasepalred
	vblwait 14
	setpalette shinypal
	vblwait 4
	setpalette pleasepalgreen
	vblwait 8
	move.l a6,screenaddress
	rts

shinyplease11:
	move.l screenaddress,a6
	lea please11doo,a0
	move.l a0,screenaddress
	setpalette pleasepaltrash1
	vblwait 6
	setpalette bootpal
	vblwait 2
	setpalette pleasepalblue
	vblwait 20
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease10:
	move.l screenaddress,a6
	lea please10doo,a0
	move.l a0,screenaddress
	setpalette bwpal
	vblwait 10
	setpalette wbpal
	vblwait 3
	setpalette bwpal
	vblwait 20
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease09:
	move.l screenaddress,a6
	lea please09doo,a0
	move.l a0,screenaddress
	setpalette pleasepaltrash2
	vblwait 4
	setpalette pleasepaltrash1
	vblwait 2
	add.l #(160*10)+2,screenaddress
	vblwait 2
	sub.l #(160*10)+2,screenaddress
	vblwait 8
	add.l #(160*10)+2,screenaddress
	vblwait 2
	sub.l #(160*10)+2,screenaddress
	setpalette pleasepalgreen
	vblwait 25
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease08:
	move.l screenaddress,a6
	lea please08doo,a0
	move.l a0,screenaddress
	setpalette pleasepaltrash3
	vblwait 4
	setpalette bootpal
	vblwait 3
	setpalette pleasepalblue
	vblwait 24
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease07:
	move.l screenaddress,a6
	lea please07doo,a0
	move.l a0,screenaddress
	setpalette pleasepalgreen
	vblwait 10
	setpalette pleasepaltrash1
	vblwait 6
	add.l #(160*30)+24+2,screenaddress
	vblwait 6
	sub.l #(160*30)+24+2,screenaddress
	vblwait 6
	add.l #(160*30)+24+4,screenaddress
	vblwait 6
	sub.l #(160*30)+24+4,screenaddress
	setpalette pleasepalgreen
	vblwait 30
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease06:
	move.l screenaddress,a6
	lea please06doo,a0
	move.l a0,screenaddress
	setpalette bwpal
	vblwait 10
	setpalette wbpal
	vblwait 3
	setpalette bwpal
	vblwait 20
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease05:
	move.l screenaddress,a6
	lea please05doo,a0
	move.l a0,screenaddress
	setpalette pleasepaltrash1
	vblwait 6
	setpalette bootpal
	vblwait 2
	setpalette pleasepalblue
	vblwait 12
	setpalette pleasepalgreen
	vblwait 14
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease04:
	move.l screenaddress,a6
	lea please04doo,a0
	move.l a0,screenaddress
	setpalette pleasepalgreen
	vblwait 8
	setpalette pleasepaltrash1
	vblwait 4
	add.l #(160*30)+24+2,screenaddress
	vblwait 4
	sub.l #(160*30)+24+2,screenaddress
	vblwait 8
	add.l #(160*30)+24+4,screenaddress
	vblwait 4
	sub.l #(160*30)+24+4,screenaddress
	setpalette pleasepalgreen
	vblwait 25
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease03:
	move.l screenaddress,a6
	lea please03doo,a0
	move.l a0,screenaddress
	setpalette wbpal
	vblwait 6
	setpalette bwpal
	vblwait 3
	setpalette wbpal
	vblwait 20
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease02:
	move.l screenaddress,a6
	lea please02doo,a0
	move.l a0,screenaddress
	setpalette pleasepaltrash2
	vblwait 7
	setpalette pleasepaltrash1
	vblwait 2
	add.l #(160*30)+24,screenaddress
	vblwait 2
	sub.l #(160*30)+24,screenaddress
	vblwait 8
	add.l #(160*30)+24,screenaddress
	vblwait 2
	sub.l #(160*30)+24,screenaddress
	setpalette pleasepalgreen
	vblwait 25
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease01:
	move.l screenaddress,a6
	lea please01doo,a0
	move.l a0,screenaddress
	setpalette pleasepaltrash3
	vblwait 6
	setpalette bootpal
	vblwait 3
	setpalette pleasepalblue
	vblwait 20
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinyplease00:
	move.l screenaddress,a6
	lea please00doo,a0
	move.l a0,screenaddress
	setpalette pleasepaltrash1
	vblwait 6
	setpalette pleasepalred
	vblwait 14
	setpalette shinypal
	move.l a6,screenaddress
	rts

shinya0:
	dc.l 0
shinyframe:
	dc.l 0

shinybubblesvbl:
	pusha0
	pusha1
	pushd0
	move.l framecounter,d0
	and.l #1,d0
	cmp.l #0,d0
	bne .bye
	move.l shinya0,a0
	bsr fadepalettesdoonefade
	move.l smokescreenaddress,a1
	add.l #160*25,a1
	bsr copy24000
	add.l #24000,a0
	bsr swapscreens
	cmp.l #11,shinyframe
	beq .reset
	bra .dont
.reset:
	move.l #0,shinyframe
	lea shiny01,a0
	bra .goon
.dont:
	add.l #1,shinyframe
.goon:
	move.l a0,shinya0
.bye:
	popd0
	popa1
	popa0
	rts

shinyloadvbl:
	pushall
	move.l shinyloadcounter,d0
	cmp.l #0,d0
	beq .goahead
	sub.l #1,shinyloadcounter
	bra .bye
.goahead:
	cmp.l #0,shinyloadwaiter
	beq .okidoki
	sub.l #1,shinyloadwaiter
	move.l shinyloadwaiter,shinyloadcounter
.okidoki:
	move.l shinyloada6,a6
	cmp.w #-1,(a6)
	beq .uninstall

	move.l smokescreenaddress,a0
	add.l #(160*25)+6,a0
	bsr clearshinyloadlines

.lineloop:
	cmp.w #-1,(a6)
	beq .nextframe
	rept 1
	move.l a6,a0
	move.l smokescreenaddress,a1
	add.l #6,a1
	bsr SegmentedLine
	endr
	add.l #8,a6
	bra .lineloop

.nextframe:	
	add.l #2,a6

	rept 0
	eor.w #$0fff,$ffff8240
	endr

	bsr swapscreens

	move.l a6,shinyloada6
.bye:
	popall
	rts
.uninstall:
	vblinstall vblextrablank
	move.w #0,shinyloadactive
	bra .bye

clearshinyloadlines:
; In: a0 - address to bitplane
	pusha6
	pushd0
	move.l #$ffff8a00,a6 ;32 byte halftone ram
	rept 16/2
	clr.l (a6)+
	endr
	move.w #0,$ffff8a20 ;source x inc
	move.w #0,$ffff8a22 ;source y inc
	move.l copperemptyline,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #8,$ffff8a2e ;dest x inc
	move.w #8,$ffff8a30 ;dest y inc
	move.l a0,$ffff8a32 ;destination address
	move.w #20,$ffff8a36 ;x count (n words per line to copy)
	move.w #150,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000001,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000000,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popd0	
	popa6
	rts

shinyloada6:
	dc.l 0
shinyloadactive:
	dc.w 0
shinyloadwaiter:
	dc.l 28
shinyloadcounter:
	dc.l 0


	lea thesisanimarea,a0
	rept 6
	bsr copy2screen ;noblitter
	vblwait 150
	add.l #32000,a0
	endr

	setpalette allblackpal







dorotbars:

rotbarframes equ 75

	deicelealea rotbars1doi,rotbars1doo
	deicelealea rotbars2doi,rotbars2doo
	deicelealea rotbars3doi,rotbars3doo
	deicelealea rotbarstbi,rotbarstable
	deicelealea noabsdoi,noabsdoo

	lea rotbars2doo,a0
	lea rotbarsdoo,a1
	bsr copy32000

	fade2palette allblackpal,1

	bsr clearscreen ;noblitter
	move.l screenaddress,a0
	move.l a0,copperbottomscreenaddress
	move.w #1,copperenabled

	lea rotbarsdoo,a0
	move.l a0,rotbarsa0
	lea rotbarsrottable,a5
	move.l a5,rotbarsa5
	lea rotbarstable,a6
	move.l a6,rotbarsa6
	move.w #35,rotbarscounter
	move.w #0,rotbarsmode

	vblinstall rotbarsvbl

	fade2palette rotbars1pal,1

	move.l #50,d7
.w1:
	vblwait 1
	move.w #35,rotbarscounter
	dbra d7,.w1




	move.l #1-1,d6
	lea noabsdoo,a6
	move.l a6,a5
	add.l #160*43,a5
	move.l #21-1,d7
.text1in:
	vblwait 1
	move.w #35,rotbarscounter
	bsr rotbarsdotext
	add.l #1,d6
	dbra d7,.text1in

rotbarscoarsrotatewait equ 18
	move.l #2,d4

	move.l #150,d7
.text1wait:
	vblwait 1
	bsr rotbarscoarserotate
	move.w #35,rotbarscounter
	bsr rotbarsdotext
	dbra d7,.text1wait

	move.l #21,d6
	move.l #21-1,d7
.text1out:
	vblwait 1
	bsr rotbarscoarserotate
	move.w #35,rotbarscounter
	bsr rotbarsdotext
	sub.l #1,d6
	dbra d7,.text1out

	move.l #1-1,d6
	lea noabsdoo,a6
	add.l #160*45,a6
	move.l a6,a5
	add.l #160*43,a5
	move.l #21-1,d7
.text2in:
	vblwait 1
	bsr rotbarscoarserotate
	move.w #35,rotbarscounter
	bsr rotbarsdotext
	add.l #1,d6
	dbra d7,.text2in

	move.l #150,d7
.text2wait:
	vblwait 1
	bsr rotbarscoarserotate
	move.w #35,rotbarscounter
	bsr rotbarsdotext
	dbra d7,.text2wait

	move.l #21,d6
	move.l #21-1,d7
.text2out:
	vblwait 1
	bsr rotbarscoarserotate
	move.w #35,rotbarscounter
	bsr rotbarsdotext
	sub.l #1,d6
	dbra d7,.text2out

	move.l #1-1,d6
	lea noabsdoo,a6
	add.l #160*90,a6
	move.l a6,a5
	add.l #160*61,a5
	move.l #31-1,d7
.text3in:
	vblwait 1
	bsr rotbarscoarserotate
	move.w #135,rotbarscounter
	bsr rotbarsdotext
	add.l #1,d6
	dbra d7,.text3in

	move.w #1,rotbarsrotateenabled

	move.l #150,d7
.text3wait:
	vblwait 1
	bsr rotbarsdotext
	dbra d7,.text3wait

	move.l #31,d6
	move.l #32-1,d7
.text3out:
	vblwait 1
	bsr rotbarsdotext
	sub.l #1,d6
	dbra d7,.text3out



	vblwait 100
	fade2palettescrollleft allblackpal,1
	lea rotbars3doo,a0
	lea rotbarsdoo,a1
	bsr copy32000
	fade2palettescrollright rotbars3pal,1

	vblwait 300
	fade2palettescrollleft allblackpal,1
	lea rotbars1doo,a0
	lea rotbarsdoo,a1
	bsr copy32000
	fade2palettescrollright rotbars2pal,1

	vblwait 249

	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 20
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 16
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 12
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 8
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 6
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 4
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 3
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 2
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 1
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 1
	setpalette allblackpal
	vblwait 1
	setpalette rotbars2pal
	vblwait 1
	setpalette allblackpal
	vblwait 2
	setpalette rotbars2pal
	vblwait 1
	setpalette allblackpal
	vblwait 4
	setpalette rotbars2pal
	vblwait 1
	setpalette allblackpal
	vblwait 8
	setpalette rotbars2pal
	vblwait 1
	setpalette allblackpal
	vblwait 1

	vblinstall vblextrablank
	move.w #0,copperenabled
	rts





macro rotbarschecka0
.go\~:
	cmp.l #rotbarsdoo+32000,a0
	blt .exit\~
	sub.l #32000,a0
	bra .go\~
.exit\~:
	endm

rotbarscoarserotate:
	cmp.l #0,d4
	bne .nope
	move.l #rotbarscoarsrotatewait,d4
	move.l rotbarsa0,a0
	add.l #160*12,a0
	rotbarschecka0
	move.l a0,rotbarsa0
	bra .bye
.nope:
	sub.l #1,d4
.bye:
	rts

rotbarsdotext:
	move.l copperlistaddress,a0
	add.l #6*60,a0
	move.l a0,a1
	add.l #6*1,a0
	move.l a6,a2
	move.l a5,a3
	move.l d6,d5
.w2pre:
	sub.l #6,a0
	add.l #6,a1
	dbra d5,.w2pre
	move.l d6,d5
.w2line:
	move.l a2,(a0)
	add.l #6,a0
	move.l a3,(a1)
	sub.l #6,a1
	add.l #160,a2
	sub.l #160,a3
	dbra d5,.w2line
	rts

rotbarsrotate:
	move.l #0,d0
	move.b (a5)+,d0
	mulu #160,d0
	add.l d0,a0
	cmp.b #-1,(a5)
	bne .nope
	lea rotbarsrottable,a5
.nope:
	rotbarschecka0
	rts

rotbarsvbl:
	pushall
	move.l rotbarsa0,a0
	move.l rotbarsa5,a5
	move.l rotbarsa6,a6
.domodechecking:
	sub.w #1,rotbarscounter
	cmp.w #0,rotbarscounter
	bne .dontchangemode
	add.w #1,rotbarsmode
	cmp.w #0,rotbarsmode
	bne .not0
	move.w #35,rotbarscounter
	bra .modedone
.not0:
	cmp.w #1,rotbarsmode
	bne .not1
	lea rotbarstable,a6
	move.w #rotbarframes-1,rotbarscounter
	bra .modedone
.not1:
	cmp.w #2,rotbarsmode
	bne .not2
;	lea rotbarstable+22500,a6
	lea rotbarstable+45000,a6
	move.w #rotbarframes-1,rotbarscounter
	bra .modedone
.not2:
	cmp.w #3,rotbarsmode
	bne .not3
	move.w #35,rotbarscounter
	move.w #0,rotbarsmode ; i e will be 0 next loop
	add.l #149*160,a0
	rotbarschecka0
.not3:
.modedone:
.dontchangemode:
	move.l copperlistaddress,a1
	cmp.w #0,rotbarsmode
	beq .domode0loop
	cmp.w #1,rotbarsmode
	beq .domode1loop
	cmp.w #2,rotbarsmode
	beq .domode2loop
	bra .exit
.domode0loop:
	move.l #15-1,d7
.loop0:
	rept 10
	move.l a0,(a1)
	add.l #6,a1
	endr
	dbra d7,.loop0
	bra .exit
.domode1loop:
	pusha0
	move.l a0,a4
	move.l #15-1,d7
.loop1:
	rept 10
	move.l a4,a0
	move.l (a6)+,d0
	add.l d0,a0
	rotbarschecka0
	move.l a0,(a1)
	add.l #6,a1
	endr
	dbra d7,.loop1
	popa0
	bra .exit
.domode2loop:
	pusha0
	move.l a0,a4
	move.l #15-1,d7
.loop2:
	rept 10
  	move.l a4,a0
  	move.l #149*160,d0
  	sub.l -(a6),d0
  	add.l d0,a0
  	rotbarschecka0
  	move.l a0,(a1)
  	add.l #6,a1
	endr
	dbra d7,.loop2
	popa0
	bra .exit
.exit:
	rotbarschecka0
	cmp.w #0,rotbarsrotateenabled
	beq .dontrotate
	bsr rotbarsrotate
.dontrotate:
;	cmp.w #1,rotbarsmode
;	bne .doublenot1
;.doublenot1
;	cmp.w #2,rotbarsmode
;	bne .doublenot2
;.doublenot2
	move.l a6,rotbarsa6
	move.l a5,rotbarsa5
	move.l a0,rotbarsa0
	popall
	rts

rotbarscounter:
	dc.w 0
rotbarsmode:
	dc.w 0
rotbarsa0:
	dc.l 0
rotbarsa5:
	dc.l 0
rotbarsa6:
	dc.l 0
rotbarsrotateenabled:
	dc.w 0






	bra endloop







	setpalette bwpal

	vblinstall vblextrablank

	bsr barsdobarssequence

	bra endloop












docluster:
clusterframemax equ 1
	lea clusterpal,a0
	bsr fadepalettessetup
	bsr clearscreen
	move.w #0,clustercounter
	move.w #0,clusterframecounter
	lea clusterxp4,a0
	move.l a0,clustera0

	vblinstall clustervbl

	deicelealea threedeecuttbi,threedeecuttable
;	vblwait 200

	vblinstall vblextrablank
	fade2palette allblackpal,1
	rts

clustervbl:
	pushall
	bsr fadepalettesdoonefade
	cmp.w #clusterframemax,clusterframecounter
	beq .doit
	add.w #1,clusterframecounter
	bra .bye
.doit:
	move.w #0,clusterframecounter
	move.l clustera0,a0
	move.l screenaddress,a1
	bsr unpackxp4
	add.w #1,clustercounter
	cmp.w #75,clustercounter
	bne .goon
	move.w #0,clustercounter
	lea clusterxp4,a0
	bsr clearscreen
.goon:
	move.l a0,clustera0
.bye:
	popall
	rts

clustera0:
	dc.l 0
clustercounter:
	dc.w 0
clusterframecounter:
	dc.w 0
	
	bra endloop








	rept 0
dochess:
	lea chessdoi,a0
	lea chessdoo,a1
	bsr deice
	setpalette bwpal
	move.l screenaddress,a0
	move.l a0,copperbottomscreenaddress
	move.w #1,copperenabled

	lea chesssintable,a0
	move.l a0,chesssintablepos

	move.l #0,d6
.onego:
	vblwait 1

	move.l chesssintablepos,a0
	move.l #0,d6
	move.w (a0)+,d6
	cmp.w #-1,d6
	bne .donewithtablepos
	lea chesssintable,a0
	move.w (a0)+,d6
	bra .donewithtablepos
.donewithtablepos:
	move.l a0,chesssintablepos

	move.l copperlistaddress,a0
	add.l #74*6,a0
	move.l a0,a1
	add.l #6,a1
	lea chessdoo,a6
	move.l #0,d4 ; which version of the chessdoo?
	lea chesslinepointertable,a5
	add.l d6,a5
	move.l #0,d5 ; lines output
	move.l #0,d3

.draw:
	move.l #0,d0
	move.l d0,d1
	move.w (a5)+,d0 ; offset into doo
	move.w (a5)+,d1 ; number of lines in first bit, i e loops
	move.w (a5)+,d2 ; number of lines in second bit, i e loops
	lea chessdoo,a6
	cmp.l #1,d4
	beq .gozero
	move.l #1,d4
	bra .continue
.gozero:
	move.l #0,d4
	add.l #160*100,a6
.continue:
	add.l d0,a6

	cmp.l #1,d3
	beq .loop2
.loop1:
	move.l #1,d3
	move.l a6,(a0)
	move.l a6,(a1)
	sub.l #6,a0
	add.l #6,a1
	add.l #1,d5
	cmp.l #75,d5
	beq .done
	dbra d1,.loop1
	bra .draw
.loop2:
	move.l a6,(a0)
	move.l a6,(a1)
	sub.l #6,a0
	add.l #6,a1
	add.l #1,d5
	cmp.l #75,d5
	beq .done
	dbra d2,.loop2
	bra .draw
.done:
	endr

	rept 0
	add.l #6,d6
	cmp.l #147*6,d6
;	cmp.l #80*6,d6
	bne .nopes
	move.l #0,d6
.nopes:
	endr

	rept 0
	bra .onego
	endr

	bra endloop


	rept 0
chesssintable:
 dc.w 876,876,870,870,864,858,852,846,840,828,816,804
 dc.w 792,780,762,744,732,714,696,672,654,636,612,594
 dc.w 570,546,528,504,480,456,438,414,390,366,342,324
 dc.w 300,276,258,234,216,198,174,156,138,126,108,90
 dc.w 78,66,54,42,30,24,18,12,6,0,0,0
	endr
	rept 0
 dc.w 0,0,0,0
	endr
	rept 0
	dc.w 6,12,18,24,30,42,54,66
 dc.w 78,90,108,126,138,156,174,198,216,234,258,276
 dc.w 300,324,342,366,390,414,432,456,480,504,528,546
 dc.w 570,594,612,636,654,672,696,714,732,744,762,780
 dc.w 792,804,816,828,840,846,852,858,864,870,870,876
	dc.w -1
 dc.w 876
	dc.w -1
	endr

	rept 0
chesssintablepos:
	dc.l 0
	endr





;	lea filename1,a0 ; address to zero-terminated filename string
;	lea loadarea,a1 ; address to load data at
;	move.l #32000,d0	; number of bytes to load
;	bsr loadfile
;	cmp.l #0,d0
;	beq .loadingwentwell
;	move.w #$0f00,currentpalette
;	bra endloop
;.loadingwentwell

;/////////////////////////

	if enableforcemediachange
forcemediachange:
	include "force_mc.s"
	endif









;/////////////////////////


dospin:
;	lea testdoo,a0
;	move.l a0,screenaddress
;	add.l #160*175,a0
;	move.l a0,copperbottomscreenaddress

	move.w #1,copperenabled

	move.l copperlistaddress,a1
	lea testdoo,a0
	add.l #160*25,a0
	move.l #150-1,d7
.coppercopy:
	move.l a0,(a1)
	add.l #160,a0
	add.l #6,a1
;	vblwait 1
	dbra d7,.coppercopy

	lea testdoo,a0
	lea testdoo2,a1
	add.l #160*199,a0
	move.l #200-1,d7
.copyline:
;	rept 40
	move.l (a0)+,(a1)+
;	endr
	sub.l #160*2,a0
	dbra d7,.copyline

spinloop:
	setpalette bwpal
	lea testdoo,a0
	bsr spindospindown
	lea bwpal,a0
	add.l #32*10,a0
	bsr setpalettenextframe
	lea testdoo2,a0
	bsr spindospinup
	lea testdoo2,a0
	bsr spindospindown
	setpalette bwpal
	lea testdoo,a0
	bsr spindospinup
	bra spinloop

spindospindown:
	move.l a0,a6
	lea spintable,a0
	move.l #26-1,d7
.spin:
	vblwait 1
	move.l screenaddress,a2
	move.l copperlistaddress,a1
	move.l #150-1,d6
.clear:
	move.l a2,(a1)
	add.l #6,a1
	dbra d6,.clear
	move.l copperlistaddress,a1
	move.l #150-1,d6
.copy:
	move.l a6,a2
	move.w (a0)+,d0
	ext.l d0
	cmp.w #-1,d0
	beq .blankline
	add.l #160*25,a2
	add.l d0,a2	
	move.l a2,(a1)
.blankline:
	add.l #6,a1
	dbra d6,.copy
	dbra d7,.spin
	rts

spindospindownwithfade:
	move.l a0,a6
	lea spintable,a0
	move.l #26-1,d7
.spin:
	vblwait 1
	bsr fadepalettesdoonefade
	move.l screenaddress,a2
	move.l copperlistaddress,a1
	move.l #150-1,d6
.clear:
	move.l a2,(a1)
	add.l #6,a1
	dbra d6,.clear
	move.l copperlistaddress,a1
	move.l #150-1,d6
.copy:
	move.l a6,a2
	move.w (a0)+,d0
	ext.l d0
	cmp.w #-1,d0
	beq .blankline
	add.l #160*25,a2
	add.l d0,a2	
	move.l a2,(a1)
.blankline:
	add.l #6,a1
	dbra d6,.copy
	dbra d7,.spin
	rts

spindospinup:
	move.l a0,a6
	lea spintable,a0
	add.l #150*2*24,a0
	move.l #25-1,d7
.spin:
	vblwait 1
	move.l screenaddress,a2
	move.l copperlistaddress,a1
	move.l #150-1,d6
.clear:
	move.l a2,(a1)
	add.l #6,a1
	dbra d6,.clear
	move.l copperlistaddress,a1
	move.l #150-1,d6
.copy:
	move.l a6,a2
	move.w (a0)+,d0
	ext.l d0
	cmp.w #-1,d0
	beq .blankline
	add.l #160*25,a2
	add.l d0,a2	
	move.l a2,(a1)
.blankline:
	add.l #6,a1
	dbra d6,.copy
	sub.l #150*2*2,a0
	dbra d7,.spin
	rts

spindospinupwithfade:
	move.l a0,a6
	lea spintable,a0
	add.l #150*2*24,a0
	move.l #25-1,d7
.spin:
	vblwait 1
	bsr fadepalettesdoonefade
	move.l screenaddress,a2
	move.l copperlistaddress,a1
	move.l #150-1,d6
.clear:
	move.l a2,(a1)
	add.l #6,a1
	dbra d6,.clear
	move.l copperlistaddress,a1
	move.l #150-1,d6
.copy:
	move.l a6,a2
	move.w (a0)+,d0
	ext.l d0
	cmp.w #-1,d0
	beq .blankline
	add.l #160*25,a2
	add.l d0,a2	
	move.l a2,(a1)
.blankline:
	add.l #6,a1
	dbra d6,.copy
	sub.l #150*2*2,a0
	dbra d7,.spin
	rts




;////////////////////////////




;-----

endloop:
	vblwait 1
	bra endloop

;//
;///////////////////////////////////////////////////////////
	
exitall:

	if enablemusic
  	pusha0
  	move.l musicexit,a0
  	jsr (a0)			; de-init music
  	popa0
	endif

	include "end.s"
	even

;///////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////
;//
;// Subroutines

dorandomlinesin:
; In: a0 - address of image to present
;     a1 - address of 200 longwords of premultiplied offsets
	movem.l a2/d0-d3,-(sp)
	move.l a0,d2
	move.l #50-1,d0
.lines:
	bsr wait4vbl
	move.l #4-1,d1
.manyatonce:
	move.l d2,a0
	move.l screenaddress,a2
	move.l (a1)+,d3
	add.l d3,a0
	add.l d3,a2
	rept 40
	move.l (a0)+,(a2)+
	endr
	dbra d1,.manyatonce
	dbra d0,.lines
	movem.l (sp)+,a2/d0-d3
	rts

dohalvesbouncein:
	move.l a0,a5
	lea thesishalvesbouncetable,a6
	move.l #62-1,d7
.bounce:
	vblwait 1
	bsr clearcopperlist
	move.l copperlistaddress,a0
	move.l a0,a1
	add.l #6*149,a1
	move.l a5,a2
	add.l #160*99,a2
	move.l a2,a3
	add.l #160,a3
	move.l #0,d0
	move.w (a6)+,d0
	move.l d0,d1
	move.l d0,d2
	sub.l #1,d2
	mulu.w #6,d0
	mulu.w #160,d1
	sub.l d1,a2
	add.l d1,a3
.loop:
	move.l a2,(a0)
	move.l a3,(a1)
	add.l #160,a2
	sub.l #160,a3
	add.l #6,a0
	sub.l #6,a1
	dbra d2,.loop
	dbra d7,.bounce
	rts


dobouncebetweencoppers:
	pushall
	move.l a0,a5
	move.l a1,a6
	lea copperlist2,a0
	move.l a0,copperlistaddress
	move.l a5,a0
	copy2coppera0 0
	vblwait 1
	lea copperlist,a0
	move.l a0,smokecopperlistaddress
	move.l a6,a0
	copy2smokecoppera0 0
	bsr bouncefromcopper2copper
	lea copperlist,a0
	move.l a0,copperlistaddress
	move.l a6,a0
	copy2coppera0 0
	lea copperlist2,a0
	move.l a0,smokecopperlistaddress
	popall
	rts

bouncefromcopper2copper:
	pushall
	lea topicbouncetable,a5
	move.l #34-1,d7
.loop:
	lea copperlist2,a0
	move.l #0,d0
	move.w (a5)+,d0
	sub.l d0,a0
	vblwait 1
	move.l a0,copperlistaddress
	dbra d7,.loop
	popall
	rts

dowaterdropsequence:
	pushd7
	move.l #7-1,d7
.loop:
	bsr dowaterdrop
	vblwait 11
	dbra d7,.loop
	popd7
	rts

dowaterdrop:
	pushd7
	pusha0
	move.l a0,a5
	lea waterdroptable,a2
	move.l #37-1,d6
.bigloop:
	vblwait 1
;		move.w #$0333,$ffff8240
	move.l a5,a0
	copy2smokecoppera0 0
;		move.w #$0003,$ffff8240
	move.l smokecopperlistaddress,a0
	lea watercopper,a1
	move.l #0,d0
	move.l #150-1,d7
.testloop:
	move.l (a2)+,d1
	bsr watergetcopperoffset
	add.l #6,a0
	add.l #6,a1
	add.l #1,d0
	dbra d7,.testloop
;		move.w #$0337,$ffff8240
	copycopper2smokecopperlea watercopper
;		move.w #$0007,$ffff8240
;	wait4copperlistdone
	bsr swapcopperlists
;		move.w #$0000,$ffff8240
	dbra d6,.bigloop
	popa0
	popd7
	rts

watergetcopperoffset:
; In: a0 - address in copperlist
;     a1 - address in new copperlist
;     d0 - line number in copperlist
;     d1 - offset value
	pusha0
	pusha6
	move.l d0,d2
	move.l d1,d3
	add.l d3,d2
	cmp.l #0,d2
	blt .outsiderange
	cmp.l #149,d2 ; 149*6
	bgt .outsiderange
	add.l d1,a0
	bra .saveandexit
.outsiderange:
	lea copperemptyline,a6
	move.l a6,(a1)
	bra .exit
.saveandexit:
	move.l (a0),(a1)	
.exit:
	popa6
	popa0
	rts


setupbullifbullvbl:
	lea bibframetable,a0
	move.l (a0)+,d0
	move.l d0,bibframecounter
	move.l a0,bibframepos
	lea bull1xp4,a0
	move.l a0,bibxp4pos
	rts

dobullifbullvbl:
	pushall
	move.l bibframecounter,d0
	cmp.l #2,d0
	beq .timetocopyfirsthalf
	cmp.l #1,d0
	beq .timetocopysecondhalf
	cmp.l #0,d0
	beq .timetodepack
	cmp.l #10000,d0
	beq .justflipscreen
	bra .nothingthistime
.timetocopyfirsthalf:
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy16000
	bra .nothingthistime
.timetocopysecondhalf:
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	add.l #160*100,a0
	add.l #160*100,a1
	bsr copy16000
	bra .nothingthistime
.timetodepack:
	move.l bibxp4pos,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	move.l a0,bibxp4pos
	bsr swapscreens
	move.l bibframepos,a6
	move.l (a6)+,d0
	move.l a6,bibframepos
	cmp.l #-1,d0
	bne .dontshutmedown
	vblinstall vblextrablank
	move.w #1,biballdone
	bra .nothingthistime
.dontshutmedown:
	cmp.l #1001,d0
	bne	.dontgotoif
	lea ifxp4,a0
	move.l a0,bibxp4pos
		;vblinstall vblextrablank
		;bra .nothingthistime
	bra .getnewframevalueandexit
.dontgotoif:
	cmp.l #1002,d0
	bne	.dontgotobull2
	lea bull2xp4,a0
	move.l a0,bibxp4pos
	bra .getnewframevalueandexit
.dontgotobull2:
	bra .nothingthistime
.justflipscreen:
	bsr swapscreens
	sub.l #10000,d0
	bra .getnewframevalueandexit
.getnewframevalueandexit:
	move.l bibframepos,a6
	move.l (a6)+,d0
	move.l a6,bibframepos
	add.l #1,d0
.nothingthistime:
	sub.l #1,d0
	move.l d0,bibframecounter
	popall
	rts

bibframecounter:
	dc.l 0
bibframepos:
	dc.l 0
bibxp4pos:
	dc.l 0
biballdone:
	dc.w 0

bibbubblewait equ 12
bibswooshspeed equ 5
bibflashtimes equ 26

dootherur:
	fade2palette allblackpal,1
	bsr clearscreennoblitter
	lea otherurxp4,a0
	move.l #0,d6 ; framecounter
	move.l #37-1,d7
.unpack:
	resetframecount
	move.l smokescreenaddress,a1
	bsr unpackxp4
	cmp.l #1,d6
	beq .flash
	cmp.l #1+4*1,d6
	beq .flash
	cmp.l #1+4*2,d6
	beq .flash
	cmp.l #1+4*3,d6
	beq .flash
	cmp.l #1+4*4,d6
	beq .flash
	cmp.l #1+4*5,d6
	beq .flash
	cmp.l #1+4*6,d6
	beq .flash
	cmp.l #1+4*7,d6
	beq .flash
	bra .noflash
.flash:
	setpalette otherurflashpal
	pusha0
	lea otherurpal,a0
	bsr fadepalettessetup
	popa0
.noflash:
	bsr swapscreens
	pusha0
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy16000
	vblwaitwithpalettefade 1
	move.l screenaddress,a0
	add.l #160*100,a0
	move.l smokescreenaddress,a1
	add.l #160*100,a1
	bsr copy16000
	vblwaitwithpalettefade 1
	popa0
	cmp.l #37-1,d7
	bne .notfirstframe
	fade2palette otherurpal,2
	vblwaitwithpalettefade 66-10
	bra .donewithfirstframe
.notfirstframe:
	waitforframecountwithfade 12
.donewithfirstframe:
	add.l #1,d6
	dbra d7,.unpack
	rts


dourgay:
	fade2palette allblackpal,1
	bsr clearsmokescreennoblitter
	lea urgayframetable,a6
	lea urgayxp4,a0
	move.l #15-1,d7
.unpa:
	move.l smokescreenaddress,a1
	bsr unpackxp4
	bsr swapscreens
	setpalette urgaypal
	pusha0
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	popa0
	move.l #0,d6
	move.w (a6)+,d6
	sub.l #2,d6
.waiter:
	vblwait 1
	dbra d6,.waiter
	dbra d7,.unpa
	rts


dokinsey:
	fade2palette allblackpal,1
	bsr clearsmokescreen;noblitter
	lea kinseyframetable,a6
	lea kinseyxp4,a0
	move.l #37-1,d7
.unpa:
	move.l smokescreenaddress,a1
	bsr unpackxp4
	bsr swapscreens
	setpalette kinseypal
	pusha0
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	popa0
	move.l #0,d6
	move.w (a6)+,d6
	cmp.l #120,d6 ; just a high number, really
	bgt .unpackabit
	sub.l #2,d6
.waiter:
	vblwait 1
	dbra d6,.waiter
	bra .goon
.unpackabit:
	resetframecount
	deicelealea ifxi4,ifxp4
	waitforframecount 178
.goon:
	dbra d7,.unpa
	rts



doacknow:
	fade2palette allblackpal,1
	bsr clearscreennoblitter
	bsr clearsmokescreennoblitter
	setpalette acknowpal
	lea acknowxp4,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	bsr swapscreens
	pusha0
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	popa0
	vblwait 20	
	move.l #5-1,d7
.unp:
	move.l smokescreenaddress,a1
	bsr unpackxp4
	bsr swapscreens
	pusha0
	setpalette acknowburnpal
	lea acknowpal,a0
	bsr fadepalettessetup
	vblwaitwithpalettefade 16
	vblwait 31	
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	popa0
	dbra d7,.unp
	setpalette acknowburnpal
	lea acknowpal,a0
	bsr fadepalettessetup
	vblwaitwithpalettefade 48
	setpalette acknowburnpal
	lea acknowpal,a0
	bsr fadepalettessetup
	vblinstall fadepalettesdoonefade
;	vblwaitwithpalettefade 16
	rts


doposresp:
	vblwait 1
	move.w #0,copperenabled
	bsr clearcopperlist
	bsr clearscreennoblitter
	bsr clearsmokescreennoblitter

	lea posrespxp4,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	move.l a0,posrespxp4pos
	bsr swapscreens
	fade2palette posresppal,1
	move.w #84,posrespcounter
	move.w #0,posrespframe
	vblwait 1
	vblinstall posrespvbl
	rts

posrespvbl:
	add.w #1,posrespcounter
	bsr fadepalettesdoonefade
	cmp.w #5,posrespframe
	bne .stilldrawing
	move.w #1,posrespdopink
.stilldrawing:
	cmp.w #1,posrespdopink
	bne .drawingmode

	cmp.w #96,posrespcounter
	bne .done
	pusha0
	setpalette posresppinkpal
	lea posresppal,a0
	bsr fadepalettessetup
	move.w #48,posrespcounter
	popa0

	bra .done
.drawingmode:
	cmp.w #93,posrespcounter
	beq .copy1
	cmp.w #94,posrespcounter
	beq .copy2
	cmp.w #95,posrespcounter
	beq .unpack
	cmp.w #96,posrespcounter
	beq .swapscreens
	bra .done
.copy1:
	movem.l a0/a1,-(sp)
;	move.w #$0f00,$ffff8240
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy16000
;	move.w #0,$ffff8240
	movem.l (sp)+,a0/a1
	rts
.copy2:
	movem.l a0/a1,-(sp)
;	move.w #$0f00,$ffff8240
	move.l screenaddress,a0
	add.l #160*100,a0
	move.l smokescreenaddress,a1
	add.l #160*100,a1
	bsr copy16000
;	move.w #0,$ffff8240
	movem.l (sp)+,a0/a1
	rts
.unpack:
	movem.l a0/a1,-(sp)
	move.l posrespxp4pos,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	move.l a0,posrespxp4pos
	movem.l (sp)+,a0/a1
	rts
.swapscreens:
	pusha0
	setpalette posrespburnpal
	lea posresppal,a0
	bsr fadepalettessetup
	bsr swapscreens
	add.w #1,posrespframe
	move.w #48,posrespcounter
	popa0
	rts
.done:
	rts

posrespframe:
	dc.w 0
posrespcounter:
	dc.w 0
posrespxp4pos:
	dc.l 0
posrespdopink:
	dc.w 0

doflips:
	setpalette allblackpal
	move.w #0,copperenabled
	bsr clearscreennoblitter
	bsr clearsmokescreennoblitter
	move.l screenaddress,copperbottomscreenaddress
	lea flip1xp4,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	move.l a0,a6
	move.l copperlistaddress,a0
	move.l screenaddress,a1
	add.l #160*25,a1
	move.l #150-1,d7
.intocopper:
	move.l a1,(a0)+
	move.w  #0,(a0)+
	add.l #160,a1
	dbra d7,.intocopper
	vblwait 1
	setpalette sepiapal
	move.w #1,copperenabled
	move.l screenaddress,a1
	move.l smokescreenaddress,a0
	bsr flipsmoothreverse
	bsr swapscreens
	vblwait 11
	move.l #17-1,d7
.loop:
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	move.l a6,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	move.l a0,a6
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr flipaccel
	vblwait 9
	bsr swapscreens
	dbra d7,.loop
	rts


dolabeltext:
	setpalette allwhitepal
	lea labeltextpal,a0
	bsr fadepalettessetup
	lea labels,a0
	move.l a0,a5
	lea labelswingtable,a4
	lea labellinedoublingtable,a6
	move.l a4,labeltexta4	
	move.l a5,labeltexta5
	move.l a6,labeltexta6	
	move.l #64*6-1-16-6,labeltextlinecounter

	vblinstall dolabeltextvbl

	rts

dolabeltextvbl:
.oneframe:
	pushall
	move.l labeltexta4,a4
	move.l labeltexta5,a5
	move.l labeltexta6,a6
	cmp.l #16,labeltextlinecounter
	bne .dontsetupnewpalette
	lea allblackpal,a0
	bsr fadepalettessetup
.dontsetupnewpalette:
	move.l a5,a0
	bsr fadepalettesdoonefade
;	vblwait 1
	move.l copperlistaddress,a1
	move.l #0,d6 ; linecounter
.onego:
	bsr labeltextreadlinedoublingtable
	sub.l #1,d0
.oneline:
	move.l a0,(a1)
	add.l #6,a1
	add.l #1,d6
	cmp.l #149,d6
	beq .framedone
	dbra d0,.oneline
	add.l #160,a0
	bra .onego
.framedone:
	add.l #160,a5
	movem.l a0-a1/d6-d7,-(sp)
	lea labeltextdoo,a0
	add.l #160*78,a0
	move.l copperlistaddress,a1
	move.l #0,d6
	move.w (a4)+,d6
	cmp.w #-1,d6
	bne .dontresetswing
	lea labelswingtable,a4
	move.w (a4)+,d6
.dontresetswing:
	add.l d6,a1
	move.l #43-1,d7
.copylogo:
	move.l a0,(a1)
	add.l #160,a0
	add.l #6,a1
	dbra d7,.copylogo
	movem.l (sp)+,a0-a1/d6-d7
	sub.l #1,labeltextlinecounter
	move.l a4,labeltexta4	
	move.l a5,labeltexta5
	move.l a6,labeltexta6	
	popall
	rts

labeltextlinecounter:
	dc.l 0
labeltexta4:
	dc.l 0
labeltexta5:
	dc.l 0
labeltexta6:
	dc.l 0

labeltextreadlinedoublingtable:
	move.l #0,d0
	move.w (a6)+,d0
	cmp.w #-1,d0
	bne .noreset
	lea labellinedoublingtable,a6
	move.w (a6)+,d0
.noreset:
	rts


dochurchlogoandtopic:
	deiceleasmokescreen churchlogodoi
	move.l smokescreenaddress,a0
	move.l screenaddress,a1
	bsr copy32000noblitter
	copy2coppermove screenaddress,7
	syncwait $06
	setpalette wbpal
	move.w #1,copperenabled
	move.l copperlistaddress,a0
	move.l smokecopperlistaddress,a1
	move.l #150-1,d7
.copycopperlist:
	move.l (a0)+,(a1)+
	move.w (a0)+,(a1)+
	dbra d7,.copycopperlist
	bsr swapcopperlists

	syncwait $07
	lea churchlogodisttable,a0
	add.l #70,a0
	bsr copyscrollvalues2copperlist
	rept 8
	vblwait 2
	bsr softencopperlistscroll
	endr

	syncwait $0a
	lea churchlogodisttable,a0
	add.l #170,a0
	bsr copyscrollvalues2copperlist
	rept 8
	vblwait 1
	bsr softencopperlistscroll
	endr
	deiceleasmokescreen topicdoi

	syncwait $07
	lea churchlogodisttable,a0
	add.l #100,a0
	bsr copyscrollvalues2copperlist
	rept 8
	vblwait 2
	bsr softencopperlistscroll
	endr
	move.l smokescreenaddress,a0
	add.l #160*25,a0
	move.l smokecopperlistaddress,a1
	move.l #150-1,d7
.pic2:
	move.l a0,(a1)
	add.l #160,a0
	add.l #6,a1
	dbra d7,.pic2

	syncwait $0a
	lea churchlogodisttable,a0
	add.l #130,a0
	bsr copyscrollvalues2copperlist
	rept 8
	vblwait 1
	bsr softencopperlistscroll
	endr
	move.l copperlistaddress,a6
	lea topicbouncetable,a5
	move.l #34-1,d7
.moo:
	move.l a6,a0
	move.l #0,d0
	move.w (a5)+,d0
	sub.l d0,a0
	move.l a0,copperlistaddress
	vblwait 1
	dbra d7,.moo
	lea copperlist,a0
	move.l a0,copperlistaddress
	move.l a1,smokecopperlistaddress
	lea copperlist2,a1
	move.l #150-1,d7
.copytopic:
	move.l (a0)+,(a1)+
	move.w (a0)+,(a1)+
	dbra d7,.copytopic
	vblwait 1
	bsr swapcopperlists
	vblwait 1
	move.l smokecopperlistaddress,a0
	lea copperemptyline,a6
	move.l #150-1,d7
.clearothercopperlist:
	move.l a6,(a0)+
	move.w #0,(a0)+
	dbra d7,.clearothercopperlist
	syncwait $07
	move.l #30,d0
	bsr dotopiclinecopy
	syncwait $0a
	move.l #65,d0
	bsr dotopiclinecopy
	syncwait $07
	move.l #10,d0
	bsr dotopiclinecopy
	syncwait $0a
	move.l #95,d0
	bsr dotopiclinecopy
	rept 0
	syncwait $07
	move.l #60,d0
	bsr dotopiclinecopy
	syncwait $0a
	move.l #5,d0
	bsr dotopiclinecopy
	endr
	vblwait 12
	move.l copperlistaddress,a6
	lea topicbouncetable,a5
	move.l #16-1,d7
.moo2:
	move.l a6,a0
	move.l #0,d0
	move.w (a5)+,d0
	sub.l d0,a0
	move.l a0,copperlistaddress
	vblwait 1
	dbra d7,.moo2
	rts

dotalktalk2logo:
	lea talktalk2logoxp4,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	bsr swapscreens
	fade2palette talktalk2logopal,2
	lea talktalk2logowaittable,a6
	move.l #3-1,d7
.unpacklogo:
	movem.l a0-a1,-(sp)
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	movem.l (sp)+,a0-a1
	move.l smokescreenaddress,a1
	bsr unpackxp4
	move.b (a6)+,d0
	bsr wait4sync
	setpalette talktalk2logoburnpal
	bsr swapscreens
	fade2palette talktalk2logopal,1
	dbra d7,.unpacklogo
	fade2palette allblackpal,2
	rts

clearbeescopperlist:
	pushall
	move.l #1-1,d5
	move.l #75-1,d7
.loop:
	vblwait 1
	move.l copperlistaddress,a1
	move.l a1,a2
	add.l #150*6,a2
	lea copperemptyline,a0
	move.l d5,d6
.innerloop:
	move.l a0,(a1)+
	move.w #0,(a1)+
	add.l #6,a1
	move.w #0,-(a2)
	move.l a0,-(a2)
	sub.l #6,a2
	dbra d6,.innerloop
	add.l #1,d5
	dbra d7,.loop
	popall
	rts

dotopiclinecopy:
; In: d0 - number of lines into copperlist to start
	pushall
	move.l copperlistaddress,a0
	mulu.w #6,d0
	add.l d0,a0
	move.l a0,a6
	move.l #48,d6
	move.l #0,d5
	move.l #12-1,d7
.linecopy1:
	move.l a6,a0
	add.l d5,a0
	move.l a0,a1
	vblwait 1
	move.l d6,d4
.inner1:
	move.l (a0),(a1)
	add.l #6,a1
	dbra d4,.inner1
.copperwait1:
	cmp.w #1,copperlistdone	
	bne .copperwait1
	move.l copperlistaddress,a2
	move.l (a2),a3
	add.l #6,a2
	add.l #160,a3
	move.l #149-1,d4
.inner1a:
	move.l a3,(a2)
	add.l #6,a2
	add.l #160,a3
	dbra d4,.inner1a
	add.l #2*6,d5
	sub.l #4,d6
	dbra d7,.linecopy1
	popall
	rts

setcopperlistscrollvalue:
; In: d0 - scroll values to fill copperlistwith
	pusha0
	pushd7
	move.l copperlistaddress,a0
	add.l #4,a0
	move.l #15-1,d7
.loop:
	rept 10
	move.b d0,(a0)
	add.l #6,a0
	endr
	dbra d7,.loop
	popd7
	popa0
	rts

copyscrollvalues2copperlist:
; In: a0 - pointer to byte values to insert in copperlist
	movem.l a0-a1/d0,-(sp)
	move.l copperlistaddress,a1
	add.l #4,a1
	move.l #150-1,d0
.line:
	move.b (a0)+,(a1)
	add.l #6,a1
	dbra d0,.line
	movem.l (sp)+,a0-a1/d0
	rts

softencopperlistscroll:
	movem.l a0/d0-d1,-(sp)
	move.l copperlistaddress,a0
	move.l #0,d1
	add.l #4,a0
	move.l #150-1,d0
.line:
	move.b (a0),d1
	cmp.b #7,d1
	blt .add
	cmp.b #7,d1
	bgt .sub
	bra .done
.add:
	add.b #1,d1
	bra .done
.sub:
	sub.b #1,d1
	bra .done
.done:
	move.b d1,(a0)
	add.l #6,a0
	dbra d0,.line
	movem.l (sp)+,a0/d0-d1
	rts



loaddata:
	lea loadanimxp4,a0
	move.l a0,loaddataanimpointer
	lea loadgaugexp4,a0
	move.l #25-1,d7
.init:
	lea extraloadingscreen,a1
	bsr unpackxp4
	dbra d7,.init
	lea loadgaugexp4,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4

	if enableggncredits=1
  	pushall
  	lea v11message,a0
  	move.l smokescreenaddress,a1
  	add.l #32000-(160*6),a1
  	moveq #0,d0
  	move.l #(80*4)-1,d7
  .copywords:
  	move.w (a0)+,d0
  	move.w d0,(a1)+
  	move.w d0,(a1)+
  	move.w d0,(a1)
  	add.l #4,a1
  	dbra d7,.copywords
  	popall
	endif

	pushall
	move.l screenaddress,a0
	bsr clear32000

	setpalette bwpal

	move.l smokescreenaddress,a0
	move.l screenaddress,a1
	move.l #0,d0
	move.l #2,d1
	bsr copy32000maskedanimation
	popall

	pusha0
	vblwait 1

	vblinstall loaddatavbl
	popa0

	move.w #1,loaddatacurrentdisk

	dataload spintable,1766,deiceme
	dataload fliptable,2959,deiceme
	loadupdategauge ; 01

	dataload mychurchxp4,159715,deiceme
	loadupdategauge ; 02
	loadupdategauge ; 03

	dataload handsxp4,72260,deiceme
	loadupdategauge ; 04

	dataload ifyouthinkxp4,13772,deiceme
	dataload introxp4,51681,deiceme
	dataload beesdoo1,7747,deiceme
	dataload beesdoo2,7668,deiceme
	dataload beeslonelydoo,192,deiceme
	dataload labels1doi,5722,dontdeiceme
	loadupdategauge ; 05

	dataload labels2doi,4718,dontdeiceme
	dataload labels3doi,6959,dontdeiceme
	dataload labels4doi,6583,dontdeiceme
	dataload bars1doi,6530,dontdeiceme
	dataload bars2doi,9228,dontdeiceme
	dataload bars3doi,10716,dontdeiceme
	dataload bars4doi,9175,dontdeiceme
	loadupdategauge ; 06

	dataload flip1xp4,152493,deiceme
	loadupdategauge ; 07
	loadupdategauge ; 08

	dataload posrespxp4,32825,deiceme
	dataload rasters1doi,24191,dontdeiceme
	loadupdategauge ; 09

;;;;; disk 2

	dataload churchlogodoi,5755,dontdeiceme

;	include _i_ldmus.s ; 603250 bytes
	musload eks_zero,48320
	musload m_x1,24130
	musload x2,24130
	musload x3,24130
	musload x3b,24130
	loadupdategauge ; 10

	musload x4,24130
	musload a1,24130
	musload a2,24130
	musload a3,24130
	musload a3b,24130
	musload a4,24130
	loadupdategauge ; 11
	musload a4b,24130
	musload e1,24130
	musload e2,24130
	musload e3,24130
	musload e4,24130
	musload f1,24130
	loadupdategauge ; 12
	musload f2,24130
	musload f3,24130
	musload f4,24130
	musload g1,24130
	musload g2,24130
	musload g3,24130
	loadupdategauge ; 13
	musload g4,24130
	dataload labeltextdoi,4636,dontdeiceme
	dataload topicdoi,6545,dontdeiceme
	dataload talktalk2logoxi4,25621,dontdeiceme
	loadupdategauge ; 14

	dataload kinseyxi4,50819,dontdeiceme
	dataload rotbars1doi,10661,dontdeiceme
	loadupdategauge ; 15

;;;;; disk 3

	dataload rotbars2doi,4377,dontdeiceme
	dataload rotbars3doi,8557,dontdeiceme
	dataload rotbarstbi,3745,dontdeiceme
	dataload acknowxi4,38355,dontdeiceme
	loadupdategauge ; 16

	dataload otherurxi4,80863,dontdeiceme
	loadupdategauge ; 17

	dataload urgayxi4,78077,dontdeiceme
	loadupdategauge ; 18

	dataload bull1xi4,46118,dontdeiceme
	dataload bull2xi4,23202,dontdeiceme
	loadupdategauge ; 19

	dataload ifxi4,115796,dontdeiceme
 	loadupdategauge ; 20

	dataload earthdoi,7229,dontdeiceme
	dataload thesis1doi,4713,dontdeiceme
	dataload thesis2doi,6601,dontdeiceme
	dataload thesanxi4,85177,dontdeiceme
	loadupdategauge ; 21

	dataload noabsdoi,6349,dontdeiceme
	dataload please00doi,7478,dontdeiceme
	dataload please01doi,7356,dontdeiceme
	dataload please02doi,8430,dontdeiceme
	dataload please03doi,6265,dontdeiceme
	dataload please04doi,6945,dontdeiceme
	dataload please05doi,8611,dontdeiceme
	dataload please06doi,5887,dontdeiceme
	dataload please07doi,6035,dontdeiceme
	dataload please08doi,3340,dontdeiceme
	dataload please09doi,2862,dontdeiceme
	dataload please10doi,6064,dontdeiceme
	dataload please11doi,5388,dontdeiceme
	dataload please12doi,7828,dontdeiceme
	loadupdategauge ; 22

	dataload threedeecuttbi,86975,dontdeiceme
	dataload kalmsdoi,5237,dontdeiceme
	loadupdategauge ; 23

;;;;; disk 4

	dataload rasters2doi,23312,dontdeiceme
	dataload rasters3doi,22038,dontdeiceme
;EARTHBWDOI must be last file loaded, because it is what forces disk 4!!!
	dataload earthbwdoi,1824,dontdeiceme

	loadupdategauge ; 24

	vblwait 1
	vblinstall vblextrablank
	move.w #0,musicinvbl
	vblwait 1
	move.l musicexit,a0
	jsr (a0)	
	lea loadgaugexp4,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	pusha0
	lea extraloadingscreen,a0
	move.l screenaddress,a1
	bsr copy32000noblitter
	popa0
;	lea allblackpal,a0
;	bsr fadepalettessetup
	move.l #12-1,d7
.finish:
	bsr swapscreens
	vblwait 6
;	bsr fadepalettesdoonefade
	dbra d7,.finish
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000
	move.l smokescreenaddress,a0
	move.l screenaddress,a1
	move.l #2,d0
	move.l #2,d1
	;break
	bsr copy32000maskedanimationnegative
	rts

loaddatanextdisk:
	pushall
	vblwait 1
	move.l vblextraaddress,a5
	vblinstall vblextrablank
	move.l screenaddress,a6 ; save screenaddress
	move.l a6,a0
	lea loaddatamessagescreen,a1
	bsr copy32000 ;noblitter
	lea loaddatamessagescreen,a1
	move.l a1,screenaddress
	add.l #160*(100-23),a1
	cmp.w #2,loaddatacurrentdisk
	bne .not2
	move.l #loaddatadisk2,a0
	bra .decidedwhichdisk
.not2:
	cmp.w #3,loaddatacurrentdisk
	bne .not3
	move.l #loaddatadisk3,a0
	bra .decidedwhichdisk
.not3:
	move.l #loaddatadisk4,a0
.decidedwhichdisk:
	move.l #46-1,d7
.copyline:
	rept 40
	move.l (a0)+,(a1)+
	endr
	dbra d7,.copyline
.keyloop:
	bsr clearkeyboardbuffer
	cmp.b #$39,$fffffc02
	beq .goon
	bra .keyloop
.goon:
	vblwait 1
	move.l a5,vblextraaddress
	move.l a6,screenaddress
	popall
	rts

loaddataerrormessage:
	pushall
	vblwait 1
	move.w #0,copperenabled
	vblinstall vblextrablank
	move.w #0,musicinvbl
	move.l musicexit,a0
	jsr (a0)
	setpalette bwpal
	bsr clearscreen
	move.l screenaddress,a1
	add.l #160*(100-23),a1
	move.l #loaddataerror,a0
	move.l #46-1,d7
.copyline:
	rept 40
	move.l (a0)+,(a1)+
	endr
	dbra d7,.copyline
.death:
	vblwait 1
	bra .death
	vblwait 1
	move.l a5,vblextraaddress
	move.l a6,screenaddress
	popall
	rts

clearkeyboardbuffer:
	pushd0
.flush:
	BTST.B #0,$FFFFFC00.W		; any waiting?
	BEQ.S .flok			; exit if none waiting.
	MOVE.B $FFFFFC02.W,D0		; get next in queue
	BRA.S .flush			; and continue
.flok:
	popd0
	rts	

loaddataupdategauge:
	cmp.w #24,loaddatagaugecounter
	beq .exit
	move.l screenaddress,a1
	bsr unpackxp4
	add.w #1,loaddatagaugecounter
	vblwait 1
.exit:
	rts

loaddatavbl:
	movem.l a0-a1,-(sp)
	sub.w #1,loaddataanimwaiter
	cmp.w #0,loaddataanimwaiter
	bne .exit
	move.w #2,loaddataanimwaiter
	move.l loaddataanimpointer,a0
	move.l screenaddress,a1
	bsr unpackxp4
	move.l a0,loaddataanimpointer
	add.l #1,loaddataanimcounter
	cmp.l #61,loaddataanimcounter
	bne .exit
	lea loadanimxp4,a0
	move.l a0,loaddataanimpointer
	move.l #0,loaddataanimcounter
.exit:
	movem.l (sp)+,a0-a1
	rts

loaddataanimpointer:
	dc.l 0

loaddataanimcounter:
	dc.l 0

loaddataanimwaiter:
	dc.w 2

loaddatagaugecounter:
	dc.w 0

loaddatacurrentdisk:
	dc.w 0

loadfile:
; In: d0 - filesize
;     a0 - address of zero-terminated filename string
;     a1 - address to load data at
; Out: d0 - 0=ok, all other values means error
	move.l d0,filesize
	move.l #0,d0
	move.w #0,-(sp)
	pusha0
	move.w #$3d,-(sp)
	trap #1
	add.l #8,sp
	tst.l d0
	bmi	.fail
	move.w d0,filehandle
	bra .filefoundgoon
.fail:
	move.l #-1,d0
	rts
.filefoundgoon:
	pusha1
	move.l filesize,-(sp)
	move.w filehandle,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	tst.l d0
	bmi	loaddataerrormessage
	move.w filehandle,-(sp)
	move.w #$3e,-(sp)
	trap #1
	add.l #4,sp
	move.l #0,d0
	rts

dohandsequence:
	bsr clearsmokescreennoblitter
	lea handsxp4,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	syncwait $9 ; re-loop of midsomer theme
	setpalette allblackpal
	vblwait 1
	setpalette handspal
	bsr swapscreens
	lea handsequencetable,a6
	move.l #20-1,d7
.loop:
	pusha0
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	popa0 
	move.l smokescreenaddress,a1
	bsr unpackxp4
	move.l #0,d6
	move.b (a6)+,d6
	cmp.l #99,d6
	beq .flashback
	cmp.l #98,d6
	beq .flashback2
	cmp.l #0,d6
	beq .waitvbls
	sub.l #1,d6
.waitsync:
	bsr wait4syncchange
	dbra d6,.waitsync
	bra .goon
.waitvbls:
	vblwait 1
	bra .goon
.flashback:
	move.l #6-1,d6
.flashloop:
	bsr wait4syncchange
	bsr swapscreens
	dbra d6,.flashloop
	bra .goon
.flashback2:
	move.l #16-1,d6
.flashloop2:
	bsr wait4syncchange
	bsr swapscreens
	dbra d6,.flashloop2
	bra .goon
.goon:
	bsr swapscreens
	dbra d7,.loop
	rts


doifyouthink:
	setpalette ifyouthinkpal
	vblwait 1
	lea ifyouthinkxp4,a0
	move.l screenaddress,a1
	bsr unpackxp4
	move.l screenaddress,a6 ; just fixing ugly data, packer error
abc set (160*125)+(11*8)
	move.l #$ffff0000,abc(a6)
abc set abc+4
	move.l #$00000000,abc(a6)
	move.l #3-1,d7
.xp4loop1:
	pusha0
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	popa0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	pusha0
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	btst #0,d7
	bne .up
.down:
	bsr blockditherdown
	bra .done
.up:
	bsr blockditherup
.done:
	popa0
	vblwait 60
	dbra d7,.xp4loop1
	lea ifyouthinkxp4,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	move.l smokescreenaddress,a6 ; just fixing ugly data, packer error
offs set (160*125)+(11*8)
	;move.l #$ffff0000,(160*125+11*8)(a6)
	move.l #$ffff0000,offs(a6)
offs set offs+4
	;move.l #$00000000,(160*125+11*8+4)(a6)
	move.l #$00000000,offs(a6)
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr blockditherup
	rts


blockditherdown:
; In: a0 - address of screen
;     a1 - address of screen to dither in
	movem.l a0-a4/d0-d2,-(sp)
	lea blockdithertable,a2
	move.l #100-1,d0
.loop1:
	vblwait 1
	move.l #10-1,d2
.numblocks:
	move.l a1,a4
	move.l a0,a3
	move.l #0,d1
	move.w (a2)+,d1
	add.l d1,a3
	add.l d1,a4
	move.l #8-1,d1
.loop2:
	move.b (a4),(a3)
	move.b 2(a4),2(a3)
	move.b 4(a4),4(a3)
	move.b 6(a4),6(a3)
	add.l #160,a3
	add.l #160,a4
	dbra d1,.loop2
	dbra d2,.numblocks
	dbra d0,.loop1
	movem.l (sp)+,a0-a4/d0-d2
	rts

blockditherup:
; In: a0 - address of screen
;     a1 - address of screen to dither in
	movem.l a0-a4/d0-d2,-(sp)
	add.l #32000+1,a0
	add.l #32000+1,a1
	lea blockdithertable,a2
	move.l #100-1,d0
.loop1:
	vblwait 1
	move.l #10-1,d2
.numblocks:
	move.l a1,a4
	move.l a0,a3
	move.l #0,d1
	move.w (a2)+,d1
	sub.l d1,a3
	sub.l d1,a4
	move.l #8-1,d1
.loop2:
	move.b (a4),(a3)
	move.b 2(a4),2(a3)
	move.b 4(a4),4(a3)
	move.b 6(a4),6(a3)
	sub.l #160,a3
	sub.l #160,a4
	dbra d1,.loop2
	dbra d2,.numblocks
	dbra d0,.loop1
	movem.l (sp)+,a0-a4/d0-d2
	rts

playdma:
; In: a0 - start address of sample
;     a1 - end address of sample
;     d0 - 0: play once ; not 0: play looped
;	    d1 - 0=stereo, not 1=mono
;	    d2 - 0=6258Hz, 1=12517Hz, 2=25033Hz, 3=50066Hz
	movem.l d3-d5,-(sp)
	move.l a0,d3
	move.l d3,d4
	move.l d3,d5
	and.l #$000000ff,d3
	and.l #$0000ff00,d4
	and.l #$00ff0000,d5
	lsr.l #8,d4
	lsr.l #8,d5
	lsr.l #8,d5
	move.b d5,$ffff8903
	move.b d4,$ffff8905
	move.b d3,$ffff8907
	move.l a1,d3
	move.l d3,d4
	move.l d3,d5
	and.l #$000000ff,d3
	and.l #$0000ff00,d4
	and.l #$00ff0000,d5
	lsr.l #8,d4
	lsr.l #8,d5
	lsr.l #8,d5
	move.b d5,$ffff890f
	move.b d4,$ffff8911
	move.b d3,$ffff8913
	cmp.b #0,d1
	bne .notstereo
	bra .donestereo
.notstereo:
	add.b #128,d2
.donestereo:
	move.w d2,$ffff8920
	cmp.b #0,d0
	bne .notlooped
	move.w #1,$ffff8900 ; play once
	bra .donelooped
.notlooped:
	move.w #3,$ffff8900 ; play looped
.donelooped:
	movem.l (sp)+,d3-d5
	rts

playdmastop:
	move.w #0,$ffff8900 ; turn off DMA sound
	rts


introdointro:
	setpalette allblackpal
	lea introxp4,a0
	move.l smokescreenaddress,a1
	bsr unpackxp4
	bsr swapscreens
	movem.l a0-a1,-(sp)
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	movem.l (sp)+,a0-a1
	move.l smokescreenaddress,a1
	bsr unpackxp4
	fade2palette intropal,3
	move.l #0,d1
	move.l #1,d0
	move.l #6-1,d7
.introloop:
	bsr wait4sync
	add.l #1,d0
	bsr swapscreens
	movem.l a0-a1,-(sp)
	move.l screenaddress,a0
	move.l smokescreenaddress,a1
	bsr copy32000noblitter
	movem.l (sp)+,a0-a1
	move.l smokescreenaddress,a1
	cmp.l #5,d1
	bge .dontunpack
	bsr unpackxp4
.dontunpack:
	add.l #1,d1
	dbra d7,.introloop

  ;break

dochurchscroll:
	; init
	lea mychurchxp4,a0
	lea mychurchscroll,a1
	move.l a1,a2
	bsr unpackxp4
	move.l #14-1,d7
.onepic:
	movem.l a0-a1,-(sp)
	move.l a2,a0
	move.l a2,a1
	add.l #32000,a1
	bsr copy32000noblitter
	movem.l (sp)+,a0-a1
	move.l a2,a1
	add.l #32000,a1
	move.l a1,a2
	bsr unpackxp4
	dbra d7,.onepic
	lea bwpal,a0
	bsr fadepalettessetup
	
	;break
	
	syncwait $8
	
	;break

	; scroll
mychurchscrollwaitframes equ 2
	move.l #0,mychurchscrollcounter
	move.w #mychurchscrollwaitframes,mychurchscrollwaiter
	lea mychurchtableend,a0
	if 1=1
    v set 150*4
  	sub.l #v,a0
	else
	  sub.l #150*4,a0
	endif
	move.l a0,mychurchtablepos
	vblwait 1
	vblinstall mychurchscrollvbl
	;break
mychurchscrollfadeframes equ 4
	move.w #mychurchscrollfadeframes,mychurchscrollfadewaiter
mychurchscrollmain:
	vblwait 1
	;break
	cmp.w #0,mychurchscrollfadewaiter
	beq .fadezero
.fadenotzero:
	sub.w #1,mychurchscrollfadewaiter
	bra .fadeexit
.fadezero:
	move.w #mychurchscrollfadeframes,mychurchscrollfadewaiter
	bsr fadepalettesdoonefade
.fadeexit:
	cmp.l #30,mychurchscrollcounter
	bne .nope0 ; bne
	lea mychurchscroll,a1
	move.l #(32000*12)+(160*33),a1 ; start in pictures
	lea mychurchtablexia2010,a0 ; start in table
	add.l #33*4,a0
	move.l #66,d0 ; number of lines
	bsr mychurchdofadein
.nope0:
	cmp.l #30+115,mychurchscrollcounter
	bne .nope1 ; bne
	lea mychurchscroll,a1
	move.l #(32000*11)+(160*33),a1 ; start in pictures
	lea mychurchtablexia2010,a0 ; start in table
	add.l #33*4,a0
	move.l #66,d0 ; number of lines
	bsr mychurchdofadeout
	lea mychurchpal1,a0
	bsr fadepalettessetup
.nope1:
	cmp.l #180,mychurchscrollcounter
	bne .nope2 ; bne
	lea mychurchscroll,a1
	move.l #(32000*8)+(160*103),a1 ; start in pictures
	lea mychurchtablepresents,a0 ; start in table
	add.l #103*4,a0
	move.l #46,d0 ; number of lines
	bsr mychurchdofadein
.nope2:
	cmp.l #180+115,mychurchscrollcounter
	bne .nope3 ; bne
	lea mychurchscroll,a1
	move.l #(32000*7)+(160*103),a1 ; start in pictures
	lea mychurchtablepresents,a0 ; start in table
	add.l #103*4,a0
	move.l #46,d0 ; number of lines
	bsr mychurchdofadeout
	lea mychurchpal2,a0
	bsr fadepalettessetup
.nope3:
	cmp.l #320,mychurchscrollcounter
	bne .nope4 ; bne
	lea mychurchscroll,a1
	move.l #(32000*4)+(160*149),a1 ; start in pictures
	lea mychurchtabletalktalk2,a0 ; start in table
	add.l #149*4,a0
	move.l #47,d0 ; number of lines
	bsr mychurchdofadein
.nope4:
	cmp.l #320+115,mychurchscrollcounter
	bne .nope5 ; bne
	lea mychurchscroll,a1
	move.l #(32000*3)+(160*149),a1 ; start in pictures
	lea mychurchtabletalktalk2,a0 ; start in table
	add.l #149*4,a0
	move.l #47,d0 ; number of lines
	bsr mychurchdofadeout
	lea mychurchpal3,a0
	bsr fadepalettessetup
.nope5:
	cmp.l #460,mychurchscrollcounter
	bne .nope6 ; bne
	lea mychurchscroll,a1
	move.l #32000*4,a1 ; start in pictures
	lea mychurchtabletalktalk2,a0 ; start in table
	add.l #0*4,a0
	move.l #71,d0 ; number of lines
	bsr mychurchdofadein
.nope6:
	cmp.l #470+115,mychurchscrollcounter
	bne .nope7 ; bne
	lea mychurchscroll,a1
	move.l #32000*3,a1 ; start in pictures
	lea mychurchtabletalktalk2,a0 ; start in table
	add.l #0*4,a0
	move.l #71,d0 ; number of lines
	bsr mychurchdofadeout
.nope7:
	cmp.l #470+125+90,mychurchscrollcounter
	bne .nope8
	lea allblackpal,a0
	bsr fadepalettessetup
	move.l #0,framecounter
.nope8:
	cmp.l #16*6,framecounter
	bne .noexit
	vblinstall vblextrablank

	lea mychurchscroll,a0
	move.l #15-1,d7
.clearchurchscroll:
	pusha0
	move.l a0,screenaddress
	bsr clearscreennoblitter
	popa0
	add.l #32000,a0
	dbra d7,.clearchurchscroll
	bsr doifyouthink
	rts
.noexit:
	bra mychurchscrollmain

mychurchdofadein:
	movem.l d0-d7/a0-a6,-(sp)
	move.l a0,a2
	move.l a1,a3
	move.l #3-1,d5
.loop3:
	move.l d0,d7
	lsr.l #1,d7
.loop1:
	bsr wait4vblfourth
	move.l a1,(a0)
	add.l #160*2,a1
	add.l #4*2,a0
	dbra d7,.loop1
	add.l #160,a1
	add.l #4,a0
	move.l d0,d7
	lsr.l #1,d7
.loop1b:
	bsr wait4vblfourth
	move.l a1,(a0)
	sub.l #160*2,a1
	sub.l #4*2,a0
	dbra d7,.loop1b
	move.l a3,a1
	sub.l #32000,a1
	move.l a1,a3
	move.l a2,a0
	dbra d5,.loop3
	movem.l (sp)+,d0-d7/a0-a6
	rts

mychurchdofadeout:
	movem.l d0-d7/a0-a6,-(sp)
	move.l a0,a2
	move.l a1,a3
	move.l #3-1,d5
.loop3:
	move.l d0,d7
	lsr.l #1,d7
.loop1:
	bsr wait4vblfourth
	move.l a1,(a0)
	add.l #160*2,a1
	add.l #4*2,a0
	dbra d7,.loop1
	add.l #160,a1
	add.l #4,a0
	move.l d0,d7
	lsr.l #1,d7
.loop1b:
	bsr wait4vblfourth
	move.l a1,(a0)
	sub.l #160*2,a1
	sub.l #4*2,a0
	dbra d7,.loop1b
	move.l a3,a1
	add.l #32000,a1
	move.l a1,a3
	move.l a2,a0
	dbra d5,.loop3
	movem.l (sp)+,d0-d7/a0-a6
	rts

mychurchscrollvbl:
	movem.l d0-d7/a0-a6,-(sp)
	move.l mychurchtablepos,a0
	;break
	cmp.l #-1,(a0)
	beq	.done
	move.l smokescreenaddress,a2
	add.l #25*160,a2
	move.l #150-1,d7
.oneline:
	move.l (a0)+,d0
	lea mychurchscroll,a1
	add.l d0,a1
	;break
	rept 40
	  move.l (a1)+,(a2)+ ; crash!
	endr
	dbra d7,.oneline
	sub.l #151*4,a0
	sub.w #1,mychurchscrollwaiter
	cmp.w #0,mychurchscrollwaiter
	beq .nextline
	add.l #4,a0
	bra .done
.nextline:
	move.w #mychurchscrollwaitframes,mychurchscrollwaiter
	add.l #1,mychurchscrollcounter
	bra .done
.done:
	move.l a0,mychurchtablepos
	bsr swapscreens
	movem.l (sp)+,d0-d7/a0-a6
	rts


flipsmooth:
; In: a0 - address to shown pic (doo)
;     a1 - address to pic to flip in (doo)
	pushall
	move.l a0,a5 ; first pic
	move.l a1,a6 ; second pic
	lea fliptable,a0
	move.l #116-1,d7
.oneframe:
	vblwait 1
	move.l a6,a1
	add.l #160*25,a1
	move.l copperlistpointer,a2
	move.l a5,a3
	add.l #100*160,a3
	move.l a2,a4
	add.l #75*6,a4
	move.l #75-1,d6
.copper:
	move.l a1,(a2)
	add.l #160,a1
	add.l #6,a2
	move.l a3,(a4)
	add.l #160,a3
	add.l #6,a4
	dbra d6,.copper
	move.l copperlistpointer,a2
	move.l #150-1,d6
.line:
	move.w (a0)+,d0
	ext.l d0
	cmp.l #-1,d0
	beq .notthisone
	cmp.l #57,d7
	blt .bottomhalf
	move.l a5,a1
	bra .done
.bottomhalf:
	move.l a6,a1
.done:
	add.l #160*25,a1
	add.l d0,a1
	move.l a1,(a2)
.notthisone:
	add.l #6,a2
	dbra d6,.line
	dbra d7,.oneframe
	popall
	rts

flipsmoothreverse:
; In: a0 - address to shown pic (doo)
;     a1 - address to pic to flip in (doo)
	pushall
	move.l a0,a5 ; first pic
	move.l a1,a6 ; second pic
	lea fliptable,a0
	add.l #300*115,a0
	move.l #116-1,d7
.oneframe:
	vblwait 1
	move.l a6,a1
	add.l #160*25,a1
	move.l copperlistpointer,a2
	move.l a5,a3
	add.l #100*160,a3
	move.l a2,a4
	add.l #75*6,a4
	move.l #75-1,d6
.copper:
	move.l a1,(a2)
	add.l #160,a1
	add.l #6,a2
	move.l a3,(a4)
	add.l #160,a3
	add.l #6,a4
	dbra d6,.copper
	move.l copperlistpointer,a2
	move.l #150-1,d6
.line:
;	move.w -(a0),d0
	move.w (a0)+,d0
	ext.l d0
	cmp.l #-1,d0
	beq .notthisone
	cmp.l #57,d7
	bge .bottomhalf
	move.l a5,a1
	bra .done
.bottomhalf:
	move.l a6,a1
.done:
	add.l #160*25,a1
	add.l d0,a1
	move.l a1,(a2)
.notthisone:
	add.l #6,a2
	dbra d6,.line
	sub.l #300*2,a0
	dbra d7,.oneframe
	popall
	rts

flipaccel:
; In: a0 - address to shown pic (doo)
;     a1 - address to pic to flip in (doo)
	pushall
	move.l a0,a6 ; first pic
	move.l a1,a5 ; second pic
	move.l #0,d4 ; framecounter
	lea flipacceltable,a0
	move.l a0,d5
.oneflip:
;		move.w #$0000,$ffff8240
	vblwait 1
;		move.w #$000f,$ffff8240
	lea fliptable,a0
	move.l d5,a1
	move.l #0,d0
	move.w (a1)+,d0
	cmp.w #-1,d0
	beq .exit
	move.l a1,d5
	mulu #150*2,d0
	add.l d0,a0
	move.l a5,a1
	add.l #160*25,a1
	move.l copperlistpointer,a2
	move.l a6,a3
	add.l #100*160,a3
	move.l a2,a4
	add.l #75*6,a4
	move.l #75-1,d6
.copper:
	move.l a1,(a2)
	add.l #160,a1
	add.l #6,a2
	move.l a3,(a4)
	add.l #160,a3
	add.l #6,a4
	dbra d6,.copper
	move.l copperlistpointer,a2
	move.l #150-1,d6
.line:
	move.w (a0)+,d0
	ext.l d0
	cmp.l #-1,d0
	beq .notthisone
	cmp.l flipaccelflippos,d4
	blt .otherhalf
	move.l a5,a1
	bra .done
.otherhalf:
	move.l a6,a1
.done:
	add.l #160*25,a1
	add.l d0,a1
	move.l a1,(a2)
.notthisone:
	add.l #6,a2
	dbra d6,.line
	add.l #1,d4
	bra .oneflip
.exit:
	popall
	rts


fadepalettesaesthetic:
; In: a0 - address of target palette
;     d0 - number of vbls to wait between steps (routine will take this amount * 15 frames)
	pushd7
	bsr fadepalettessetup
	move.l #16-1,d7
.onefade:
	bsr fadepalettesdoonefade
	pushd0
	bsr wait4vbld0
	popd0
	dbra d7,.onefade
	popd7
	rts

fadepalettesaestheticandscrollleft:
; In: a0 - address of target palette
;     d0 - number of vbls to wait between steps (routine will take this amount * 15 frames)
	pushd7
	pushd6
	pushd5
	pushd0
	pusha0
	move.l #0,d6
	bsr fadepalettessetup
	move.l #16-1,d7
.onefade:
	bsr fadepalettesdoonefade
	pushd0
	move.l d6,d0
	bsr setcopperlistscrollvalue
	add.l #1,d0
	cmp.l #16,d0
	bne .nope
	sub.l #1,d0
.nope:
	move.l d0,d6
	popd0
	pushd0
	bsr wait4vbld0
	popd0
	dbra d7,.onefade
	move.l #0,d0
	bsr setcopperlistscrollvalue
	popa0
	popd0
	popd5
	popd6
	popd7
	rts

fadepalettesaestheticandscrollright:
; In: a0 - address of target palette
;     d0 - number of vbls to wait between steps (routine will take this amount * 15 frames)
	pushd7
	pushd6
	pushd5
	pushd0
	pusha0
	move.l #15,d6
	bsr fadepalettessetup
	move.l #16-1,d7
.onefade:
	bsr fadepalettesdoonefade
	pushd0
	move.l d6,d0
	bsr setcopperlistscrollvalue
	sub.l #1,d0
	cmp.l #0,d0
	bne .nope
	add.l #1,d0
.nope:
	move.l d0,d6
	popd0
	pushd0
	bsr wait4vbld0
	popd0
	dbra d7,.onefade
	move.l #0,d0
	bsr setcopperlistscrollvalue
	popa0
	popd0
	popd5
	popd6
	popd7
	rts


fadepalettessetup:
; In: a0 - address of target palette
	pushall
	lea currentpalette,a1
	lea fadecomponents,a2
	move.l #16-1,d7
.onecolor:
	move.l #0,d0
	move.w (a1)+,d0
	bsr fadeconvertste2normal
	bsr fadecolorsplit
	move.l d1,d4 ; R
	move.l d2,d5 ; G
	move.l d3,d6 ; B
	move.w (a0)+,d0
	bsr fadeconvertste2normal
	bsr fadecolorsplit
	; Now we have source RGB in d4/d5/d6 and target RGB in d0/d1/d2
	; R
	sub.l d4,d1
	tst.l d1
	bmi .Rneg
.Rpos:
	lea fadetableadd,a3
	bra .Rgoon
.Rneg:
	lea fadetablesub,a3
	neg.l d1
.Rgoon:
	lsl #4,d1
	add.l d1,a3
	move.l a3,(a2)+
	move.w d4,(a2)+
	; G
	sub.l d5,d2
	tst.l d2
	bmi .Gneg
.Gpos:
	lea fadetableadd,a3
	bra .Ggoon
.Gneg:
	lea fadetablesub,a3
	neg.l d2
.Ggoon:
	lsl #4,d2
	add.l d2,a3
	move.l a3,(a2)+
	move.w d5,(a2)+
	; B
	sub.l d6,d3
	tst.l d3
	bmi .Bneg
.Bpos:
	lea fadetableadd,a3
	bra .Bgoon
.Bneg:
	lea fadetablesub,a3
	neg.l d3
.Bgoon:
	lsl #4,d3
	add.l d3,a3
	move.l a3,(a2)+
	move.w d6,(a2)+
	dbra d7,.onecolor
	move.w #0,fadetablepos
	popall
	rts

fadepalettesdoonefade:
	cmp.w #16,fadetablepos
	bge .alldone
	pushall
	lea fadecomponents,a0
	lea currentpalette,a1
	move.l #16-1,d7
.onecomponent:
	move.l #0,d0
	; R
	move.l (a0),a2
	add.l #1,(a0)
	add.l #4,a0
	move.w (a0)+,d1
	add.b (a2),d1
	; G
	move.l (a0),a2
	add.l #1,(a0)
	add.l #4,a0
	move.w (a0)+,d2
	add.b (a2),d2
	; B
	move.l (a0),a2
	add.l #1,(a0)
	add.l #4,a0
	move.w (a0)+,d3
	add.b (a2),d3
	; Put it all together
	bsr fadecolormerge
	bsr fadeconvertnormal2ste
	move.w d0,(a1)+
	dbra d7,.onecomponent
	add.w #1,fadetablepos
	popall
.alldone:
	rts

fadecolorsplit:
; In: d0 - RGB word (normal)
; Out: d1 - R
;      d2 - G
;      d3 - B
; Destroys: nothing
	move.l d0,d1
	move.l d0,d2
	move.l d0,d3
	and.l #$f00,d1
	lsr.l #8,d1
	and.l #$0f0,d2
	lsr.l #4,d2
	and.l #$00f,d3
	rts

fadecolormerge:
; In: d1 - R
;     d2 - G
;     d3 - B
; Out: d0 - RGB word (normal)
; Destroys: d1, d2, d3
	lsl.l #8,d1
	move.l d1,d0
	lsl.l #4,d2
	add.l d2,d0
	add.l d3,d0
	rts

fadeconvertnormal2ste:
; In: d0 - RGB word (normal)
; Out: d0 - RGB word (STE)
; Destroys: nothing
	pushd1
	move.w	d0,d1
	and.w	#%0000000100010001,d1
	and.w	#%0000111011101110,d0
	lsl.w	#3,d1
	lsr.w	#1,d0
	add.w	d1,d0
	popd1
	rts

fadeconvertste2normal:
; In: d0 - RGB word (STE)
; Out: d0 - RGB word (normal)
; Destroys: nothing
	pushd1
	move.w	d0,d1
	and.w	#%0000100010001000,d1
	and.w	#%0000011101110111,d0
	lsr.w	#3,d1
	lsl.w	#1,d0
	add.w	d1,d0
	popd1
	rts


beesdobeesequence:
	bsr beessetup

	if enablemusic
  	move.w #0,musicinvbl
  	vblwait 1
  	pusha0
  	move.l musicexit,a0
  	jsr	(a0)			; de-init music
  	popa0
	endif

	if enablemusic
	lea mainmusic,a0
	move.l a0,musicinit
	add.l #4,a0
	move.l a0,musicexit
	add.l #4,a0
	move.l a0,musicvbl
	add.l #$b0,a0
	move.l a0,musicsyncbyte
	move.l musicinit,a0
	jsr (a0)
	vblwait 1
	endif

	move.l screenaddress,a0
	bsr clearscreennoblitter

	lea museks_zero,a0
	move.l a0,a1
	add.l #6,a1
	move.l #0,d0
	move.l #0,d1
	move.l #1,d2
	bsr playdma

	vblwait 1
	vblinstall beesresetflicker

	vblwait 8

	vblinstall vblextrablank

	vblwait 1
	setpalette bootpal
	vblwait 4
	move.l musicinit,a0
	move.l a0,screenaddress
	vblwait 12
	setpalette allwhitepal
	vblwait 8
	setpalette bootpal
	lea startofcode,a0
	move.l a0,screenaddress
	vblwait 2
	setpalette allwhitepal

	vblwait 20

	move.w #1,musicinvblextra
	move.w #1,musicinvbl

	vblwait 50

	lea beeslonelydoo,a0
	move.l a0,screenaddress
	add.l #160*174,a0
	move.l a0,copperbottomscreenaddress
	setpalette beespal
	move.w #$0fff,currentpalette

	vblwait 50

	lea beeslonelydoo,a0
	move.l copperlistpointer,a1
	add.l #160*25,a0
	move.l #150-1,d7
.copytocopper:
	move.l a0,(a1)+
	move.w #0,(a1)+
	add.l #160,a0
	dbra d7,.copytocopper
	lea smokescreen1,a0
	move.l a0,a1
	add.l #160*175,a1
	move.l #0,d0
	move.l #25-1,d7
.clear:
	rept 40
  	move.l d0,(a0)+	
  	move.l d0,(a1)+	
	endr
	dbra d7,.clear

	vblwait 1

	lea smokescreen1,a0
	move.l a0,screenaddress
	move.l a0,copperbottomscreenaddress

	move.w #1,copperenabled

	syncwait $ff

	vblinstall beesscrollarea

	move.l #67-1,d7
.waitbeforebeefade:
	vblwait 1
	dbra d7,.waitbeforebeefade

	lea bwpal,a1
	add.l #30,a1
	move.l #16-1,d7
.fadeoutbee:
	move.w (a1),currentpalette
	sub.l #2,a1
	vblwait 2
	dbra d7,.fadeoutbee

	setpalette allwhitepal
	fade2palette beespal,2
	rts

beesresetflicker:
	pushd7
	move.l #2800,d7
.loop:
	move.w #$0fff,$ffff8240
	rept 3
	nop
	endr
	move.w #0,$ffff8240
	dbra d7,.loop
	popd7
	rts

beessetup:
	lea beesdoo1,a0
	lea beesdoo2,a1
	lea beesscreen,a2
	move.l #200-1,d7
.lines:
	move.l #40-1,d6
.copy1:
	move.l (a0)+,(a2)+
	dbra d6,.copy1
	move.l #40-1,d6
.copy2:
	move.l (a1)+,(a2)+
	dbra d6,.copy2
	dbra d7,.lines
	lea beesyscrolltable,a0
	move.l a0,beesyscrolltablepos
	lea beesxscrolltable,a0
	move.l a0,beesxscrolltablepos
	lea beesswingcurvetable,a0
	move.l a0,beesswingcurvetablepos
	rts

beesscrollarea:
	pushall
	move.l beesxscrolltablepos,a5
	move.l beesyscrolltablepos,a6
	lea beescopper,a0
	lea beescopperlist,a1 ; copy temporarily to here, then copy this to actual copperlist
	move.w (a6)+,d0
	ext.l d0
	add.l d0,a0
	move.w (a5)+,d0
	ext.l d0
	move.w (a5)+,d1
	ext.l d1
	move.l #150-1,d7
.coppercopy:
	move.l (a0)+,d2
	add.l d0,d2
	move.l d2,(a1)+
	move.b d1,(a1)
	add.l #2,a0
	add.l #2,a1
	dbra d7,.coppercopy
	move.w (a6),d0
	ext.l d0
	cmp.l #-1,d0
	bne .yisfine
	lea beesyscrolltable,a6
.yisfine:
	move.w (a5),d0
	ext.l d0
	cmp.l #-1,d0
	bne .xisfine
	lea beesxscrolltable,a5
.xisfine:
	move.l a5,beesxscrolltablepos
	move.l a6,beesyscrolltablepos
	lea beescopperlist,a0
	move.l copperlistaddress,a1
	move.l #150-1,d7
.safetyblit:
	move.l (a0)+,(a1)+
	move.w (a0)+,(a1)+
	dbra d7,.safetyblit
	move.l beesswingcurvetablecounter,d0
	cmp.l #149,d0
	beq .alllinesdone
	add.l #1,beesswingcurvetablecounter
	move.l beesswingcurvetablepos,a0
	move.w (a0)+,d0
	ext.l d0
	move.w (a0)+,d1
	ext.l d1
	move.w (a0)+,d2
	ext.l d2
	move.w (a0)+,d3
	ext.l d3
	move.l a0,beesswingcurvetablepos
	cmp.l #-1,d0
	beq .alllinesdone
	move.l #0,d7 ; number of lines used in copperlist
	rept 1
	cmp.l #0,d1
	beq .noprecopper
	lea beeslonelydoo,a0
	add.l d0,a0
	move.l copperlistaddress,a1
.copybeelines:
	move.l a0,(a1)+
	move.w #0,(a1)+
	add.l #160,a0
	add.l #1,d7
	dbra d1,.copybeelines
	endr
.noprecopper:
	rept 1
	lea beescopperlist,a0
	move.l copperlistaddress,a1
	add.l d2,a1
;	add.l #1,d3
.copyarealines:
	move.l (a0)+,(a1)+
	move.w (a0)+,(a1)+
	add.l #1,d7
	cmp.l #151,d7
	beq .alllinesdone
	dbra d3,.copyarealines
	endr
	rept 1
	cmp.l #150,d7
	beq .alllinesdone
	lea beeslonelydoo,a0
	add.l #160*100,a0
	move.l #150-1,d0
	sub.l d7,d0
	add.l #1,d0
.copyremaininglines:
	move.l a0,(a1)+
	move.w #0,(a1)+
	add.l #160,a0
	dbra d0,.copyremaininglines
	endr
.alllinesdone:
	popall
	rts


barsdobarssequence:
	deiceleascreen rasters1doi
	fade2palette rasterspal,1
	deicelealea bars1doi,bars+(32000*0) ; parens around "32000*0" makes rmac crash
	deicelealea bars2doi,bars+(32000*1)
	deiceleasmokescreen rasters2doi
	move.l smokescreenaddress,a0
	lea randomlinestable1,a1
	bsr dorandomlinesin
	vblwait 325
	deicelealea bars3doi,bars+(32000*2)
	deicelealea bars4doi,bars+(32000*3)
	deiceleasmokescreen rasters3doi
	move.l smokescreenaddress,a0
	lea randomlinestable2,a1
	bsr dorandomlinesin
	vblwait 110
	fade2palette allgraypal,1

	vblwait 1
	move.l screenaddress,a0
	move.l a0,copperbottomscreenaddress
	move.l #0,barssinetablepos ; d0
	move.l #0,barscostablepos ; d2
	move.l #0,barssorttablepos ; d3
	move.w #1,barenabledbar1
	move.w #1,barsenablebars
	move.w #1,copperenabled  ; copper emulation on
	move.l #0,framecounter
	vblinstall barsonesingleframe


	fade2palette bwpal,1

	vblwait 670

	fade2palette allgraypal,1
	move.w #0,copperenabled
	vblwait 1
	rts

barsonesingleframe:
	pushall
	move.l barssinetablepos,d0
	move.l barscostablepos,d2
	move.l barssorttablepos,d3
	cmp.l #50,framecounter
	bne .notbar2
	move.w #1,barenabledbar2
.notbar2:
	cmp.l #180,framecounter
	bne .notbar3
	move.w #1,barenabledbar3
.notbar3:
	cmp.l #325,framecounter
	bne .notbar4
	move.w #1,barenabledbar4
.notbar4:
	move.l copperlistaddress,a0
	move.l #150-1,d7
.clearcopper:
	move.l screenaddress,(a0)+ ; screenaddress
	move.b #0,(a0) ; scroll
	add.l #2,a0
	dbra d7,.clearcopper
	move.l #4-1,d5
.output:
	lea barssorttable,a0
	add.l d3,a0
	move.b (a0),d6
	cmp.w #0,barenabledbar1
	beq .not1
	cmp.b #1,d6
	bne .not1
	bsr bardrawbar1
	bra .done
.not1:
	cmp.w #0,barenabledbar2
	beq .not2
	cmp.b #2,d6
	bne .not2
	bsr bardrawbar2
	bra .done
.not2:
	cmp.w #0,barenabledbar3
	beq .not3
	cmp.b #3,d6
	bne .not3
	bsr bardrawbar3
	bra .done
.not3:
	cmp.w #0,barenabledbar4
	beq .not4
	cmp.b #4,d6
	bne .not4
	bsr bardrawbar4
	bra .done
.not4:
.done:
	add.l #1,d3
	dbra d5,.output
	add.l #2,d0
	add.l #2,d2
;	add.l #4,d3
	cmp.l #bartablesize,d0
	bne .notyet
	move.l #0,d0
	move.l #0,d2
	move.l #0,d3
.notyet:
	cmp.w #0,barsenablebars
	bne .dontquit
	vblinstall vblextrablank
.dontquit:
	move.l d0,barssinetablepos
	move.l d2,barscostablepos
	move.l d3,barssorttablepos
	popall
	rts

bardrawbar1:
	lea bars,a0
	lea barscostable,a1
	add.l #bar1pos,a1
	add.l d2,a1
	move.w (a1),d1
	ext.l d1
	add.l d1,a0
	lea barssinetable,a1
	add.l #bar1pos,a1
	add.l d0,a1
	move.l copperlistaddress,a2
	move.w (a1),d1
	ext.l d1
	add.l d1,a2
	move.l #25-1,d7
.copy:
	move.l a0,(a2)
	add.l #160,a0
	add.l #6,a2
	dbra d7,.copy
	rts

bardrawbar2:
	lea bars,a0
	add.l #25*160*8,a0
	lea barscostable,a1
	add.l #bar2pos,a1
	add.l d2,a1
	move.w (a1),d1
	ext.l d1
	add.l d1,a0
	lea barssinetable,a1
	add.l #bar2pos,a1
	add.l d0,a1
	move.l copperlistaddress,a2
	move.w (a1),d1
	ext.l d1
	add.l d1,a2
	move.l #25-1,d7
.copy:
	move.l a0,(a2)
	add.l #160,a0
	add.l #6,a2
	dbra d7,.copy
	rts

bardrawbar3:
	lea bars,a0
	add.l #25*160*8*2,a0
	lea barscostable,a1
	add.l #bar3pos,a1
	add.l d2,a1
	move.w (a1),d1
	ext.l d1
	add.l d1,a0
	lea barssinetable,a1
	add.l #bar3pos,a1
	add.l d0,a1
	move.l copperlistaddress,a2
	move.w (a1),d1
	ext.l d1
	add.l d1,a2
	move.l #25-1,d7
.copy:
	move.l a0,(a2)
	add.l #160,a0
	add.l #6,a2
	dbra d7,.copy
	rts

bardrawbar4:
	lea bars,a0
	add.l #25*160*8*3,a0
	lea barscostable,a1
	add.l #bar4pos,a1
	add.l d2,a1
	move.w (a1),d1
	ext.l d1
	add.l d1,a0
	lea barssinetable,a1
	add.l #bar4pos,a1
	add.l d0,a1
	move.l copperlistaddress,a2
	move.w (a1),d1
	ext.l d1
	add.l d1,a2
	move.l #25-1,d7
.copy:
	move.l a0,(a2)
	add.l #160,a0
	add.l #6,a2
	dbra d7,.copy
	rts

clearcopperlist:
	movem.l a0-a1/d6-d7,-(sp)
	lea copperemptyline,a0
	move.l copperlistaddress,a1
	move.l #0,d6
	move.l #15-1,d7
.loop:
	rept 10
	move.l a0,(a1)+
	move.w d6,(a1)+
	endr
	dbra d7,.loop
	movem.l (sp)+,a0-a1/d6-d7
	rts

setupcopperlist:
;	move.b #0,copperlinewidth
	lea copperlist,a0
	move.l a0,copperlistaddress
	lea copperlist2,a0
	move.l a0,smokecopperlistaddress
	move.l screenaddress,a0
	move.l a0,d1
	move.l copperlistaddress,a1
	move.l #150-1,d7
.oneline:
	move.l d1,(a1)+
	move.w #00,(a1)+
	dbra d7,.oneline
	rts

copy150lines:
	movem.l a0-a1/d7,-(sp)
	move.l #150-1,d7
.copy1:
	rept 40
	move.l (a0)+,(a1)+
	endr
	dbra d7,.copy1
	movem.l (sp)+,a0-a1/d7
	rts

copycopperlist2smokecopperlist:
; In; a0 - address to new copperlist
	movem.l a0-a1/d7,-(sp)
	move.l smokecopperlistaddress,a1
	move.l #6-1,d7
.loop:
	rept 25
	move.l (a0)+,(a1)+
	move.w (a0)+,(a1)+
	endr
	dbra d7,.loop
	movem.l (sp)+,a0-a1/d7
	rts

copycopperlist2copperlist:
; In; a0 - address to new copperlist
	movem.l a0-a1/d7,-(sp)
	move.l copperlistaddress,a1
	move.l #6-1,d7
.loop:
	rept 25
	move.l (a0)+,(a1)+
	move.w (a0)+,(a1)+
	endr
	dbra d7,.loop
	movem.l (sp)+,a0-a1/d7
	rts

copydoolines2copper:
; In: a0 - address to doo
;     d0 - scroll value
	movem.l a0-a1/d1,-(sp)
	add.l #160*25,a0
	move.l copperlistaddress,a1
	move.l #15-1,d1
.oneline:
	rept 10
	move.l a0,(a1)+
	move.b d0,(a1)
	add.l #2,a1
	add.l #160,a0
	endr
	dbra d1,.oneline
	movem.l (sp)+,a0-a1/d1
	rts	

copydoolines2smokecopper:
; In: a0 - address to doo
;     d0 - scroll value
	movem.l a0-a1/d1,-(sp)
	add.l #160*25,a0
	move.l smokecopperlistaddress,a1
	move.l #15-1,d1
.oneline:
	rept 10
	move.l a0,(a1)+
	move.b d0,(a1)
	add.l #2,a1
	add.l #160,a0
	endr
	dbra d1,.oneline
	movem.l (sp)+,a0-a1/d1
	rts	

setpalettenextframe:
; In: a0 - point to address of palette
	movem.l a1/d0-d7,-(sp)
	movem.l (a0),d0-d7
	lea currentpalette,a1
	movem.l	d0-d7,(a1)
	movem.l (sp)+,a1/d0-d7
	rts

copy2screennoblitter:
; In: a0 - address of image
	movem.l a0-a1/d7,-(sp)
	move.l screenaddress,a1
	move.l #199-1,d7
.loop:
	rept 40
	move.l (a0)+,(a1)+
	endr
	dbra d7,.loop
	movem.l (sp)+,a0-a1/d7
	rts

copy2screen:
; In: a0 - address of image
	movem.l a0-a1/d7,-(sp)
	move.l screenaddress,a1
	bsr copy32000
	rts

copy2smokescreennoblitter:
; In: a0 - address of image
	movem.l a0-a1/d7,-(sp)
	move.l smokescreenaddress,a1
	move.l #199-1,d7
.loop:
	rept 40
	move.l (a0)+,(a1)+
	endr
	dbra d7,.loop
	movem.l (sp)+,a0-a1/d7
	rts

copy2smokescreen:
; In: a0 - address of image
	movem.l a0-a1/d7,-(sp)
	move.l smokescreenaddress,a1
	bsr copy32000
	rts

copy16000noblitter:
; In: a0 - address of image
;     a1 - address of destination
	movem.l a0-a1/d0,-(sp)
	move.l #40-1,d0
.loop:
	rept 100
	move.l (a0)+,(a1)+
	endr
	dbra d0,.loop
	movem.l (sp)+,a0-a1/d0
	rts

copy16000:
; In: a0 - source address
;     a1 - destination address
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
	rept 16/2
	clr.l (a6)+
	endr
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a0,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #2,$ffff8a30 ;dest y inc
	move.l a1,$ffff8a32 ;destination address
	move.w #80,$ffff8a36 ;x count (n words per line to copy)
	move.w #100,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000010,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000011,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts

copy32000noblitter:
; In: a0 - address of image
;     a1 - address of destination
	movem.l a0-a1/d0,-(sp)
	move.l #80-1,d0
.loop:
	rept 100
	move.l (a0)+,(a1)+
	endr
	dbra d0,.loop
	movem.l (sp)+,a0-a1/d0
	rts

copy32000:
; In: a0 - source address
;     a1 - destination address
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
	rept 16/2
	clr.l (a6)+
	endr
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a0,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #2,$ffff8a30 ;dest y inc
	move.l a1,$ffff8a32 ;destination address
	move.w #80,$ffff8a36 ;x count (n words per line to copy)
	move.w #200,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000010,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000011,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts

copy24000:
; In: a0 - source address
;     a1 - destination address
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
	rept 16/2
	clr.l (a6)+
	endr
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a0,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #2,$ffff8a30 ;dest y inc
	move.l a1,$ffff8a32 ;destination address
	move.w #80,$ffff8a36 ;x count (n words per line to copy)
	move.w #150,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000010,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000011,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts

copy24000maskedanimation:
; In: a0 - source address
;     a1 - destination address
;     d0 - mask animation (0-10)
;     d1 - frames between animation step
	lea blitmaskstable,a3
	lsl.l #3,d0
	add.l d0,a3
	move.l (a3)+,a4
	move.l (a3),d7
	sub.l #1,d7
.loop:
	move.l d1,d6
	sub.l #1,d6
.waitloop:
	bsr wait4vbl
	dbra d6,.waitloop
	move.l (a4)+,a2
	pusha0
	pusha1
	bsr copy24000masked
	popa1
	popa0
	dbra d7,.loop
	rts

copy24000masked:
; In: a0 - source address
;     a1 - destination address
;     a2 - address of mask, 160 bytes between lines
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
v set 0
	rept 16
	move.w v(a2),(a6)+
v set v+160
	endr
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a0,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #2,$ffff8a30 ;dest y inc
	move.l a1,$ffff8a32 ;destination address
	move.w #80,$ffff8a36 ;x count (n words per line to copy)
	move.w #150,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000011,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000011,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts

copy32000maskedanimation:
; In: a0 - source address
;     a1 - destination address
;     d0 - mask animation (0-10)
;     d1 - frames between animation step
	lea blitmaskstable,a3
	lsl.l #3,d0
	add.l d0,a3
	move.l (a3)+,a4
	move.l (a3),d7
	sub.l #1,d7
.loop:
	move.l d1,d6
	sub.l #1,d6
.waitloop:
	bsr wait4vbl
	dbra d6,.waitloop
	move.l (a4)+,a2
	pusha0
	pusha1
	bsr copy32000masked
	popa1
	popa0
	dbra d7,.loop
	rts

copy32000masked:
; In: a0 - source address
;     a1 - destination address
;     a2 - address of mask, 160 bytes between lines
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
v set 0
	rept 16
	move.w v(a2),(a6)+
v set v+160
	endr
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a0,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #2,$ffff8a30 ;dest y inc
	move.l a1,$ffff8a32 ;destination address
	move.w #80,$ffff8a36 ;x count (n words per line to copy)
	move.w #200,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000011,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000011,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts

copy32000maskedanimationnegative:
; In: a0 - source address
;     a1 - destination address
;     d0 - mask animation (0-10)
;     d1 - frames between animation step
	lea blitmaskstable,a3
	lsl.l #3,d0
	add.l d0,a3
	move.l (a3)+,a4
	move.l (a3),d7
	sub.l #1,d7
  .loop:
  	move.l d1,d6
  	sub.l #1,d6
    .waitloop:
    	bsr wait4vbl
    	dbra d6,.waitloop
  	move.l (a4)+,a2
  	pusha0
  	pusha1
  	bsr copy32000maskednegative
  	popa1
  	popa0
  	dbra d7,.loop
	rts

copy32000maskednegative:
; In: a0 - source address
;     a1 - destination address
;     a2 - address of mask, 160 bytes between lines
	pusha6
	pushd0
	move.l #$ffff8a00,a6 ;32 byte halftone ram
v set 0
	rept 16
  	move.w v(a2),d0
  	eor.w #$ffff,d0
  	move.w d0,(a6)+
    v set v+160
	endr
	move.w #2,$ffff8a20 ;source x inc
	move.w #2,$ffff8a22 ;source y inc
	move.l a0,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #2,$ffff8a30 ;dest y inc
	move.l a1,$ffff8a32 ;destination address
	move.w #80,$ffff8a36 ;x count (n words per line to copy)
	move.w #200,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000011,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000011,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popd0
	popa6
	rts


clear32000noblitter:
; In: a0 - address to clear at
	movem.l a0/d0-d1,-(sp)
	move.l #0,d1
	move.l #200-1,d0
.loop:
	rept 40
	move.l d1,(a0)+
	endr
	dbra d0,.loop
	movem.l (sp)+,a0/d0-d1
	rts

clear32000:
	pusha6
	move.l #$ffff8a00,a6 ;32 byte halftone ram
	rept 16/2
	clr.l (a6)+
	endr
	move.w #0,$ffff8a20 ;source x inc
	move.w #0,$ffff8a22 ;source y inc
	move.l copperemptyline,$ffff8a24 ;source address
	move.w #-1,$ffff8a28 ;endmask 1
	move.w #-1,$ffff8a2a ;endmask 2
	move.w #-1,$ffff8a2c ;endmask 3
	move.w #2,$ffff8a2e ;dest x inc
	move.w #2,$ffff8a30 ;dest y inc
	move.l a0,$ffff8a32 ;destination address
	move.w #80,$ffff8a36 ;x count (n words per line to copy)
	move.w #200,$ffff8a38 ;y count (n lines to copy)
	move.b #%00000001,$ffff8a3a ;blit hop (halftone mix)
	move.b #%00000000,$ffff8a3b ;blit op (logic op)
	move.b #%11000000,$ffff8a3c ;blitter control, start blitter
	popa6
	rts

clearsmokescreennoblitter:
	movem.l a0/d0-d1,-(sp)
	move.l smokescreenaddress,a0
	move.l #0,d1
	move.l #200-1,d0
.loop:
	rept 40
	move.l d1,(a0)+
	endr
	dbra d0,.loop
	movem.l (sp)+,a0/d0-d1
	rts

clearsmokescreen:
	pusha0
	move.l smokescreenaddress,a0
	bsr clear32000
	popa0
	rts

clearscreennoblitter:
	movem.l a0/d0-d1,-(sp)
	move.l screenaddress,a0
	move.l #0,d1
	move.l #200-1,d0
.loop:
	rept 40
	move.l d1,(a0)+
	endr
	dbra d0,.loop
	movem.l (sp)+,a0/d0-d1
	rts

clearscreen:
	pusha0
	move.l screenaddress,a0
	bsr clear32000
	popa0
	rts

resetblitter:
	pusha0
	pushd7
	move.l #$ffff8a00,a0
	move.l #$3d,d7
.loop:
	move.b #0,(a0)+
	dbra d7,.loop
	popd7
	popa0
	rts

swapscreens:
	pusha0
	move.l screenaddress,a0
	move.l smokescreenaddress,screenaddress
	move.l a0,smokescreenaddress
	popa0
	rts

swapcopperlists:
	pusha0
	move.l copperlistaddress,a0
	move.l smokecopperlistaddress,copperlistaddress
	move.l a0,smokecopperlistaddress
	popa0
	rts

wait4sync:
; In: d0 - syncvalue to wait for
	movem.l a0/d1,-(sp)
.wait:
	move.l musicsyncbyte,a0
	move.b (a0),d1
	cmp.b d0,d1
	beq .done
	bsr wait4vbl
	bra .wait
.done:
	movem.l (sp)+,a0/d1
	rts

wait4syncchange:
	movem.l a0/d1,-(sp)
	move.l musicsyncbyte,a0
	move.b (a0),d0
.wait:
	move.l musicsyncbyte,a0
	move.b (a0),d1
	cmp.b d0,d1
	bne .done
	bsr wait4vbl
	bra .wait
.done:
	movem.l (sp)+,a0/d1
	rts

wait4vblfourth:
	cmp.w #0,wait4vblcounter
	beq .zero
.notzero:
	sub.w #1,wait4vblcounter
	bra .exit
.zero:
	move.w #3,wait4vblcounter
	bsr wait4vbl
	bra .exit
.exit:
	rts

wait4vblthird:
	cmp.w #0,wait4vblcounter
	beq .zero
.notzero:
	sub.w #1,wait4vblcounter
	bra .exit
.zero:
	move.w #2,wait4vblcounter
	bsr wait4vbl
	bra .exit
.exit:
	rts

wait4vblhalf:
	cmp.w #0,wait4vblcounter
	beq .zero
.notzero:
	sub.w #1,wait4vblcounter
	bra .exit
.zero:
	move.w #1,wait4vblcounter
	bsr wait4vbl
	bra .exit
.exit:
	rts

wait4vblcounter:
	dc.w 0

wait4vbl:
	move.w #$1,vblflag
.loop:
	cmp.w #0,vblflag
	bne .loop
	rts


wait4vbld0withpalettefade:
; In: d0 - number of vbls to wait-1 (i e prepared for dbra)
; Destroys: d0
.onevbl:
	bsr wait4vbl
	bsr fadepalettesdoonefade
	dbra d0,.onevbl
	rts

wait4vbld0:
; In: d0 - number of vbls to wait-1 (i e prepared for dbra)
; Destroys: d0
.onevbl:
	bsr wait4vbl
	dbra d0,.onevbl
	rts


macro playdma25khzstereo
	lea \1,a0
	lea \1end,a1
	move.l #0,d0
	move.l #0,d1
	move.l #2,d2
	bsr playdma
	endm

macro playdma12khzstereo
	lea \1,a0
	lea \1end,a1
	move.l #0,d0
	move.l #0,d1
	move.l #1,d2
	bsr playdma
	endm

macro playdma6khzstereo
	lea \1,a0
	lea \1end,a1
	move.l #0,d0
	move.l #0,d1
	move.l #0,d2
	bsr playdma
	endm

macro valplay
	cmp.b #\1,d0
	bne .not\1
	bsr playdmastop
	playdma25khzstereo mus\2
	move.b d3,playdmanowplaying
	move.b #1,playdmatriggered
	bra .done
.not\1:
	endm

macro valplay12
	cmp.b #\1,d0
	bne .not\1
	bsr playdmastop
	playdma12khzstereo mus\2
	move.b d3,playdmanowplaying
	move.b #1,playdmatriggered
	bra .done
.not\1:
	endm

macro valplay6
	cmp.b #\1,d0
	bne .not\1
	bsr playdmastop
	playdma6khzstereo mus\2
	move.b d3,playdmanowplaying
	move.b #1,playdmatriggered
	bra .done
.not\1:
	endm

maxiamiser:
	movem.l a0-a1/d0-d3,-(sp)
	move.l #0,d0
	move.l d0,d1
	move.l musicsyncbyte,a0
	move.b (a0),d0
	cmp.b #0,d0
	bne .trigger
	move.b #0,playdmatriggered
	bra .done
.trigger:
	cmp.b #1,playdmatriggered
	beq .done
	move.l d0,d3

;	include _i_plmus.s

	valplay12 $ff,eks_zero
	valplay6 $fe,eks_zero
	valplay12 $fd,a4b
	valplay $f0,silentsample
	valplay $01,m_x1
	valplay $02,x2
	valplay $03,x3
	valplay $04,x3b
	valplay $05,x4
	valplay $06,a1
	valplay $07,a2
	valplay $08,a3
	valplay $09,a3b
	valplay $0a,a4
	valplay $0b,a4b
	valplay $0c,e1
	valplay $0d,e2
	valplay $0e,e3
	valplay $0f,e4
	valplay $10,f1
	valplay $11,f2
	valplay $12,f3
	valplay $13,f4
	valplay $14,g1
	valplay $15,g2
	valplay $16,g3
	valplay $17,g4
	valplay12 $18,m_x1
	valplay12 $19,x2
	valplay12 $1a,x3
	valplay12 $1b,x3b
	valplay12 $1c,x4



	move.b #0,playdmanowplaying
.done:
	movem.l (sp)+,a0-a1/d0-d3
	rts

playdmanowplaying:
	dc.b 0
playdmatriggered:
	dc.b 0
	even

vbl:
	;/// HBL
	cmp.w #0,copperenabled
	beq .nocopper
	clr.b	$fffffa1b				; Timer B is turned off
	move.l #firsthbl,$120
	move.b	#24,$fffffa21	; Timer B Data - hbl first triggers on line 24
	move.b	#8,$fffffa1b	; Timer B is set to Event Count Mode
	move.w #0,hblcounter
	move.w #0,copperlistdone
.nocopper:
	;///

	move.b #0,$ffff820f
	move.b #0,$ffff8265

	movem.l a0/d0-d7,-(sp)
	move.l copperlistaddress,a0
	move.l a0,copperlistpointer
	move.w #$0,vblflag
	lea currentpalette,a0
	movem.l (a0),d0-d7
	movem.l d0-d7,$ffff8240

	lea $ffff8203,a0
	move.l screenaddress,d0
	movep.l d0,(a0)

	movem.l (sp)+,a0/d0-d7
	add.l #1,framecounter
	if enablerasters
	move.w #$0333,$ffff8240
	endif

	pusha0

	if enablemusic
  	cmp.w #0,musicinvbl
  	beq .nomusic
  	move.l musicvbl,a0
  	jsr (a0)			; call music
  	cmp.w #0,musicinvblextra
  	beq .nomusic
  	move.l musicextra,a0
  	jsr (a0)
.nomusic:
	endif

	move.l vblextraaddress,a0
	jsr (a0)

	move.l  (sp)+,a0

	if enablerasters
	move.w #$0000,$ffff8240
	endif
	cmp.b #$2a,$fffffc02
	beq exitall
	rte
	move.l  oldvbl(pc),-(sp)	; go to old vector (system friendly ;) )
	rts

oldvbl:
  dc.l 0

vblextrablank:
	rts

firsthbl:
	pusha0
	move.l copperlistpointer,a0
	move.l (a0)+,hbladrbyte0
	move.b hbladrbyte1,hbl05
	move.b hbladrbyte2,hbl07
	move.b hbladrbyte3,hbl09
	move.b (a0),hbl65
	add.l #6,copperlistpointer
	popa0

	clr.b	$fffffa1b				; Timer B off
	move.l #hbl,$120			; All succeeding HBLs use other routine
	move.b	#1,$fffffa21	; Timer B Data
	move.b	#8,$fffffa1b	; Timer B set to Event Count Mode
	bclr	#0,$fffffa0f		; HBL done
	rte

hbl:
	;move.l a0,hblsavea0
	move.l a0,usp			;ggn

hbl65x:
	move.b #$d,$ffff8265
hbl05x:
	move.b #$a,$ffff8205
hbl07x:
	move.b #$b,$ffff8207
hbl09x:
	move.b #$c,$ffff8209

	move.l copperlistpointer,a0
;	move.l (a0)+,hbladrbyte0
	move.b 1(a0),hbl05		;ggn
;	move.b hbladrbyte1,hbl05
	move.b 2(a0),hbl07		;ggn
;	move.b hbladrbyte2,hbl07
	move.b 3(a0),hbl09		;ggn
;	move.b hbladrbyte3,hbl09
	move.b 4(a0),hbl65		;ggn
;	move.b (a0),hbl65
	add.l #6,copperlistpointer
;	move.l hblsavea0,a0
	move.l usp,a0			;ggn

	
	add.w #1,hblcounter
	cmp.w #150,hblcounter
	bne hbl_morehblstogo
	; Very last line, just wait a bit, then reset screenaddress and scroll register
	clr.b $fffffa1b				; Timer B off
	move.l copperbottomscreenaddress,hbladrbyte0
	move.b hbladrbyte1,lasthbl05
	move.b hbladrbyte2,lasthbl07
	move.b hbladrbyte3,lasthbl09
	rept 9
	nop
	endr
	move.b #$00,$ffff8265
lasthbl65x:
	move.b #$00,$ffff8265
lasthbl05x:
	move.b #$a,$ffff8205
lasthbl07x:
	move.b #$b,$ffff8207
lasthbl09x:
	move.b #$c,$ffff8209
	move.w #1,copperlistdone
	bclr	#0,$fffffa0f		; HBL done
	rte

hbl_morehblstogo:
	clr.b	$fffffa1b				; Timer B off
	move.b	#1,$fffffa21	; Timer B Data
	move.b	#8,$fffffa1b	; Timer B set to Event Count Mode
	bclr	#0,$fffffa0f		; HBL done
	rte

hbl05 equ hbl05x+3	; pointers to where to write immediate data
hbl07 equ hbl07x+3
hbl09 equ hbl09x+3
hbl65 equ hbl65x+3

lasthbl05 equ lasthbl05x+3
lasthbl07 equ lasthbl07x+3
lasthbl09 equ lasthbl09x+3
lasthbl65 equ lasthbl65x+3


	if enableice1pos
deice1pos:
; In: a0 - address of packed data
; Unpacks to same address
	include "ice1pos.s"
	endif

	if enableice
deice:
; In: a0 - address of packed data
;     a1 - address to unpack to
	include "ice.s"
	endif

	if enablexp4
dexp4:
; In: a0 - address of packed data
;     a1 - address to unpack to
	include "xp4.s"
	endif

	if enablepixels
;putpixel
; In: d0 - x
;     d1 - y
;     d2 - color
;     a0 - address to screen
;
;putpixeldontdark
; In: same as putpixel, but this one doesn't set pixel if color is lower than existing pixel
;
;getpixel
; In: d0 - x
;     d1 - y
;     a0 - address to screen
; Out:d2 - color
	include "putpixel.s"
	endif

	if enablemath
  	include "mth68000.s"
	endif

	include "seglinex.s"
; In: a0 - address to struct or words containing x1, y1, x2, y2
;     a1 - screen address
; Destroys:
;     everything
; No clipping!

;//
;///////////////////////////////////////////////////////////


	include "evilblob.s"


;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

	.data

musicinit:
	dc.l 0
musicvbl:
	dc.l 0
musicexit:
	dc.l 0
musicsyncbyte:
	dc.l 0
musicextra:
	dc.l 0

loadermusic:
	incbin "tlk2load.snd"
	even

intromusic:
	incbin "midsomer.snd"
	even

mainmusic:
	incbin "tlk2main.snd"
	even


beespal:
		dc.w	$0000,$03BB,$0000,$0FFF,$0000,$060D,$0605,$0605
		dc.w	$0605,$0605,$0605,$0605,$0605,$0605,$0605,$060D

bootpal:
		dc.w	$0777,$0700,$0070,$0770,$0007,$0707,$0077,$0555
		dc.w	$0333,$0733,$0373,$0773,$0337,$0737,$0377,$0000

sepiapal:
		dc.w	$0000,$0888,$0118,$0911,$0299,$0A29,$03A2,$0B3A
		dc.w	$04B3,$0C43,$055B,$0DD4,$066C,$0EED,$0776,$0FFE

posresppal:
		dc.w	$0800,$0218,$0391,$0421,$05B3,$0FB6,$0E6E,$0ECC
		dc.w	$0704,$0229,$03AA,$0BBB,$0444,$0CCC,$0DDD,$0FFF

posrespburnpal:
		dc.w	$0800,$043A,$05B3,$0643,$07D5,$0FDF,$0FFF,$0FEE
		dc.w	$0F26,$044B,$05CC,$0DDD,$0666,$0EEE,$0FFF,$0FFF

posresppinkpal:
		dc.w	$0800,$0888,$0988,$0A88,$0B29,$0F5F,$05C5,$0533
		dc.w	$0F5E,$0888,$0911,$0222,$0AAA,$0333,$0444,$0666

talktalk2logopal:
		dc.w	$0000,$0888,$0111,$0192,$092A,$02A3,$0B3A,$04B3
		dc.w	$0C4A,$0DCA,$0D5C,$06D5,$0E6D,$0EEE,$0777,$0FFF

talktalk2logoburnpal:
		dc.w	$0000,$0AAA,$0333,$03BB,$0BB4,$0B4C,$05C4,$0D5C
		dc.w	$06D4,$0764,$0E6D,$0EE6,$07EE,$077E,$0F77,$0FFF

labeltextpal:
		dc.w	$0FFF,$0FFE,$0776,$06ED,$0DDD,$0C55,$0CCC,$04B4
		dc.w	$043B,$04AA,$0B92,$0B19,$0A11,$0281,$0188,$0000

acknowpal:
		dc.w	$0000,$074B,$0D91,$0911,$0A29,$033A,$0443,$066D
		dc.w	$0554,$0FFF,$0EEE,$0BCD,$0CDE,$022A,$0A34,$0999

acknowburnpal:
		dc.w	$0000,$0F6D,$0FB3,$0B33,$0C4B,$055C,$0665,$0FFF
		dc.w	$0776,$0FFF,$0FFF,$0DEF,$0EFF,$044C,$0C56,$0BBB

kinseypal:
		dc.w	$0000,$0BBB,$0CCC,$0666,$0777,$0FFF,$0F00,$0F33
		dc.w	$0FDD,$0111,$00AB,$0D7F,$0945,$0057,$036F,$0AAA

otherurpal:
		dc.w	$0000,$0BBA,$0332,$0C4B,$0AA9,$055C,$0DDD,$0991
		dc.w	$0666,$0B4D,$066E,$0FFF,$05D6,$0A3C,$0812,$0923

otherurflashpal:
		dc.w	$0000,$0DDC,$0554,$0E6D,$0BBA,$077E,$0FFF,$0229
		dc.w	$0FFF,$0D6F,$0FFF,$0FFF,$07FF,$0C5E,$0923,$0B45

urgaypal:
		dc.w	$0000,$03A2,$0C4B,$076D,$0218,$0B21,$06DC,$0C39
		dc.w	$0D54,$0D43,$0FFF,$0349,$06EE,$0DDD,$0766,$0BBB

shinypal:
		dc.w	$0FFF,$0B4C,$0A3B,$04CC,$06EE,$0555,$0DDD,$07FF
		dc.w	$0D66,$07F7,$0EEE,$0777,$0BBB,$0A3A,$0991,$0EE6

rotbars1pal:
		dc.w	$0934,$02B4,$034C,$0199,$09A2,$0A3A,$03BB,$0B43
		dc.w	$0B44,$04C4,$04CC,$055C,$05D5,$066D,$0E7E,$0FF7

rotbars2pal:
		dc.w	$0349,$0B42,$04C3,$0991,$0A29,$03AA,$0BB3,$043B
		dc.w	$044B,$0C44,$0CC4,$05C5,$0D55,$06D6,$07EE,$0F7F

rotbars3pal:
		dc.w	$0493,$042B,$0C34,$0919,$029A,$0A3A,$0B3B,$03B4
		dc.w	$04B4,$04C4,$0CC4,$0C55,$05D5,$0D66,$0E7E,$07FF

earthpal:
		dc.w	$0000,$0329,$0D41,$0FD2,$077D,$0AB8,$045B,$08A1
		dc.w	$0ABB,$0012,$0824,$0247,$0CD7,$001E,$0009,$000B

kalmspal:
		dc.w	$0818,$0811,$0191,$0199,$02A2,$0A3A,$0ABA,$0343
		dc.w	$0D6C,$06E4,$0774,$0FFB,$0B4B,$0BCB,$0454,$0CDC

pleasepalred:
		dc.w	$0FFF,$0F77,$0777,$07EE,$0EEE,$0E66,$0666,$06DD
		dc.w	$0DDD,$0D55,$0555,$05CC,$0CCC,$0C44,$0444,$04BB

pleasepalgreen:
		dc.w	$0FFF,$07F7,$0777,$0E7E,$0EEE,$06E6,$0666,$0D6D
		dc.w	$0DDD,$05D5,$0555,$0C5C,$0CCC,$04C4,$0444,$0B4B

pleasepalblue:
		dc.w	$0FFF,$077F,$0777,$0EE7,$0EEE,$066E,$0666,$0DD6
		dc.w	$0DDD,$055D,$0555,$0CC5,$0CCC,$044C,$0444,$0BB4

pleasepaltrash1:
		dc.w	$0FFF,$0454,$0555,$05D5,$05D5,$0D6D,$0D6D,$0D6D
		dc.w	$0DDD,$05D5,$0555,$0C5C,$0B44,$0333,$022A,$033B

pleasepaltrash2:
		dc.w	$0FFF,$0300,$0A88,$0A99,$0222,$09AA,$01BB,$0144
		dc.w	$0855,$00DD,$0FD5,$06CC,$0CBC,$0324,$0914,$000B

pleasepaltrash3:
		dc.w	$0FFF,$0747,$0CAC,$0A9A,$0000,$0AB1,$0B41,$0558
		dc.w	$06D8,$0760,$0C11,$05F2,$0C11,$05AA,$0DCB,$0665

creditspal:
		dc.w	$0FFF,$0666,$0444,$0AAA,$076D,$0C4B,$0A22,$0000
		dc.w	$0EE7,$0CCC,$022A,$0000,$07C5,$0C3B,$0A99,$0000

clusterpal:
		dc.w	$0992,$022A,$0AAA,$0AA3,$033B,$0BB4,$0444,$0CCC
		dc.w	$0CC5,$055D,$0DDD,$0666,$0EEE,$0EE7,$0777,$0FFF

rasterspal:
		dc.w	$0000,$0188,$0C44,$0218,$0D5C,$0A99,$0BA2,$0CBA
		dc.w	$0777,$04C5,$0BB4,$0DD6,$0AAA,$0222,$0919,$0333

allgraypal:
	dcb.w 16,$0bbb

bwburnpal:
		dc.w	$0000,$0AAA,$0333,$0333,$0BBB,$0444,$0CCC,$0CCC
		dc.w	$0555,$0DDD,$0DDD,$0666,$0EEE,$0777,$0777,$0FFF

wbpal:
		dc.w	$0FFF,$0777,$0EEE,$0666,$0DDD,$0555,$0CCC,$0444
		dc.w	$0BBB,$0333,$0AAA,$0222,$0999,$0111,$0888,$0000

flashfromwhitepal: ; used by "flashfromwhite" macro
	dcb.w 16,0

allwhitepal:
	dc.w $0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff
	dc.w $0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff,$0fff

allblackpal:
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

bwpal:
		dc.w	$0000,$0888,$0111,$0999,$0222,$0AAA,$0333,$0BBB
		dc.w	$0444,$0CCC,$0555,$0DDD,$0666,$0EEE,$0777,$0FFF

copperemptyline:
	rept 44*2 ; two lines+some extra for scrolling
	dc.l 0
	endr


blockdithertable:
	incbin "blockin.tab" ; 2000


barssinetable: ; sin period*6
	incbin "bars_sin.tab"	; 384 bytes

barssinetablepos:
	dc.l 0

barscostable: ; cos period*25*160
	incbin "bars_cos.tab" ; 384 bytes

barscostablepos:
	dc.l 0

barssorttable:
	incbin "bars_srt.tab" ; 768 bytes
	even

barssorttablepos:
	dc.l 0



bartablesize equ 96*2
bar1pos equ 0*2
bar2pos equ 48*2
bar3pos equ 24*2
bar4pos equ 72*2

barenabledbar1:	dc.w 0
barenabledbar2:	dc.w 0
barenabledbar3:	dc.w 0
barenabledbar4:	dc.w 0

barsenablebars:	dc.w 0


fadecomponents: ; 288 bytes
	rept 16
	dc.l 0 ; address of fadetable
	dc.w 0 ; R
	dc.l 0 ; address of fadetable
	dc.w 0 ; G
	dc.l 0 ; address of fadetable
	dc.w 0 ; B
	endr

fadetableadd: ; 272 bytes
; fadetable positive values
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1
 dc.b 0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2
 dc.b 0,0,1,1,1,1,1,2,2,2,2,2,2,3,3,3
 dc.b 0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4
 dc.b 0,1,1,1,2,2,2,3,3,3,3,4,4,4,5,5
 dc.b 0,1,1,2,2,2,3,3,3,4,4,5,5,5,6,6
 dc.b 0,1,1,2,2,3,3,4,4,4,5,5,6,6,7,7
 dc.b 1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8
 dc.b 1,1,2,2,3,3,4,5,5,6,6,7,7,8,8,9
 dc.b 1,1,2,3,3,4,4,5,6,6,7,8,8,9,9,10
 dc.b 1,1,2,3,3,4,5,6,6,7,8,8,9,10,10,11
 dc.b 1,2,2,3,4,5,5,6,7,8,8,9,10,11,11,12
 dc.b 1,2,2,3,4,5,6,7,7,8,9,10,11,11,12,13
 dc.b 1,2,3,4,4,5,6,7,8,9,10,11,11,12,13,14
 dc.b 1,2,3,4,5,6,7,8,8,9,10,11,12,13,14,15
 dc.b 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
	even

fadetablesub: ; 272 bytes
; fadetable negative values
 dc.b -0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,-0,0
 dc.b -0,-0,-0,-0,-0,-0,-0,-1,-1,-1,-1,-1,-1,-1,-1,-1
 dc.b -0,-0,-0,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2
 dc.b -0,-0,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,-3,-3,-3
 dc.b -0,-1,-1,-1,-1,-2,-2,-2,-2,-3,-3,-3,-3,-4,-4,-4
 dc.b -0,-1,-1,-1,-2,-2,-2,-3,-3,-3,-3,-4,-4,-4,-5,-5
 dc.b -0,-1,-1,-2,-2,-2,-3,-3,-3,-4,-4,-5,-5,-5,-6,-6
 dc.b -0,-1,-1,-2,-2,-3,-3,-4,-4,-4,-5,-5,-6,-6,-7,-7
 dc.b -1,-1,-2,-2,-3,-3,-4,-4,-5,-5,-6,-6,-7,-7,-8,-8
 dc.b -1,-1,-2,-2,-3,-3,-4,-5,-5,-6,-6,-7,-7,-8,-8,-9
 dc.b -1,-1,-2,-3,-3,-4,-4,-5,-6,-6,-7,-8,-8,-9,-9,-10
 dc.b -1,-1,-2,-3,-3,-4,-5,-6,-6,-7,-8,-8,-9,-10,-10,-11
 dc.b -1,-2,-2,-3,-4,-5,-5,-6,-7,-8,-8,-9,-10,-11,-11,-12
 dc.b -1,-2,-2,-3,-4,-5,-6,-7,-7,-8,-9,-10,-11,-11,-12,-13
 dc.b -1,-2,-3,-4,-4,-5,-6,-7,-8,-9,-10,-11,-11,-12,-13,-14
 dc.b -1,-2,-3,-4,-5,-6,-7,-8,-8,-9,-10,-11,-12,-13,-14,-15
 dc.b -1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16
	even

fadetablepos:
	dc.w 0


flipacceltable: ; 72 bytes
; fall
	dc.w 0,1,2,3,4,5,6,7,8,10,12,15,18,22,26,31,36,43,50,58,64,73,82
	dc.w 92,102,112,115
; bounce
	dc.w 111,107,105,104,105,107,111,115
	dc.w -1

flipaccelflippos:
	dc.l 20

fliptablepos:
	dc.l 0


beescopper: ; 11 in total ; 14970 bytes
	include "bees_tab.s"

	even
beesyscrolltable:
; ycurve, 801 steps
	incbin "bees_ysc.tab" ; 1 604 bytes (including following word)
	dc.w -1

beesxscrolltable:
; xcurve, 181 steps
	incbin "bees_xsc.tab" ; 726 bytes (including following word)
	dc.w -1

beesyscrolltablepos:
	dc.l 0
beesxscrolltablepos:
	dc.l 0

	even
beescopperlist: ; 900 bytes
	rept 150*3
	dc.w 0
	endr

beesswingcurvetable:
; 1st value: offset into beeslonelydoo to start copying lines
; 2nd value: number of lines to copy into copperlist
; 3rd value: offset into copperlist to start blitting
; 4th value: number of copperlines to blit

; swingcurve 150 steps
	incbin "bees_swi.tab" ; 1 208 bytes (including the following words)
	dc.w -1,-1,-1,-1

beesswingcurvetablepos:
	dc.l 0

beesswingcurvetablecounter:
	dc.l 0


talktalk2logowaittable:
	dc.b $07,$04,$fd
	even


churchlogodisttable:
	dcb.b 100,7

	dc.b 07,07,07,07,07,07,09,11,12,13,13,09,14,12,11,02,03,04,01,05,06,06,03,07,07
	dc.b 07,07,07
	dc.b 09,11,13,15,01,03,05,01,11,09
	dc.b 07,07,07,07,15,15,15,15,03,03,03,02
	dc.b 02,01,01,11,12,13,04,04,07,07,07,07,07,07,06,05,04,07,07,07,07,07,07,07,07
	dc.b 02,02,02,03,02,02,07,07,07
	dc.b 15,14,13,12,01,02,03,04,13,12,11,10,02,03,04,05,03,15

	dc.b 07,07,07,07,07,01,02,03,01,05,06,07,01,09,10,11,13,13,13,15,07,07,11
	dc.b 11,11,07,07,07,07,07,07,06,06,06,07,07,07,07,07
	dc.b 14,01,13,12,11,03,02
	dc.b 07,07,03,13,03,14,02,13,04,13,05,14,14,14,07,07,07,07
	dc.b 13,15,14,02,12,03,04
	dc.b 07,07,02,03,04,15,14,13,12,12,12,12,12,11,03,07,07,07,07,07,07,09,09,08,11,03,02

	dcb.b 100,7
	even


topicbouncetable: ; 34 words
	dc.w 6*1,6*2,6*4,6*7,6*11,6*16,6*22,6*29,6*37,6*46,6*56,6*67,6*79,6*92,6*112,6*150
	dc.w 6*144,6*140,6*138,6*137,6*136,6*136,6*137,6*138,6*140,6*144,6*150
	dc.w 6*147,6*145,6*144,6*144,6*145,6*147,6*150


labellinedoublingtable:
	dc.w 1,1,1,1,2,1,2,1,2,2,3,2,3,2,3,3,4,3,4,3,4,4,5,4,5,4,5
	dc.w 5,4,5,4,5,4,4,3,4,3,4,3,3,2,3,2,3,2,2,1,2,1,2,1,1,1,1
	dc.w -1

labelswingtable:
 dc.w 636,636,636,630,630,630,624,618,618,612,606,600
 dc.w 588,582,576,564,558,546,540,528,516,504,492,480
 dc.w 468,456,444,432,414,402,390,372,360,348,330,318
 dc.w 306,288,276,264,246,234,222,204,192,180,168,156
 dc.w 144,132,120,108,96,90,78,72,60,54,48,36
 dc.w 30,24,18,18,12,6,6,6,0,0,0,0
 dc.w 0,6,6,6,12,18,18,24,30,36,48,54
 dc.w 60,72,78,90,96,108,120,132,144,156,168,180
 dc.w 192,204,222,234,246,264,276,288,306,318,330,348
 dc.w 360,372,390,402,414,432,444,456,468,480,492,504
 dc.w 516,528,540,546,558,564,576,582,588,600,606,612
 dc.w 618,618,624,630,630,630,636,636
	dc.w -1


waterdroptableiced:
;	include watrtab.s
;	dcb.l 150,0
	incbin "watrdrop.tbi"
	even

watercopper:
	dcb.w 150*3,0


thesishalvesbouncetable:
; ycurve, 62 steps
 dc.w 1,1,2,5,9,15,21,28,36,45,54,64
 dc.w 73,74,69,64,59,55,51,47,44,41,39,38
 dc.w 37,37,37,38,39,41,44,47,51,55,59,64
 dc.w 69,73,74,72,69,67,65,63,61,59,58,57
 dc.w 56,56,56,56,57,58,59,60,62,64,66,68
 dc.w 70,73


randomlinestable1:
	dc.l 22400,16960,18400,9120,9600,24800,480,24320,26240,22560
	dc.l 1600,13120,27680,25280,11680,30720,27840,1920,30240,11360
	dc.l 16320,24000,1760,18560,14560,8960,19680,20320,7840,8320
	dc.l 26560,26400,18080,31520,28960,6560,21440,31200,7040,16000
	dc.l 3360,31840,20800,320,17440,3200,3680,24960,8800,1440,9760
	dc.l 12320,9920,29760,30880,12800,8480,5120,5280,20480,13440
	dc.l 13600,22720,10560,19840,6240,5760,18720,2720,15040,28640
	dc.l 8000,25120,12480,9440,29120,20160,20000,14080,3040,17760
	dc.l 22240,28800,26720,800,16800,29280,13760,21600,15520,15840
	dc.l 14400,10880,12160,7360,2080,6880,31040,2240,12640,11520
	dc.l 16480,4640,16160,7520,21280,18240,4480,29600,22080,17120
	dc.l 12000,3520,25600,15200,24480,19520,27040,640,6080,2560,4000
	dc.l 11040,4800,0,19200,23200,19040,27360,3840,6720,23520,15360
	dc.l 12960,5600,24160,30080,18880,2880,25760,14240,16640,17600
	dc.l 7680,10720,4160,21920,6400,29920,4320,17280,10240,28320
	dc.l 26080,10080,23840,9280,2400,960,13920,27520,11840,10400
	dc.l 20960,11200,15680,1120,21760,8160,29440,23680,27200,30560
	dc.l 14880,23040,4960,25440,19360,31360,5440,30400,23360,14720
	dc.l 5920,21120,8640,31680,7200,160,20640,25920,28160,24640
	dc.l 17920,28000,26880,22880,13280,28480,1280

randomlinestable2:
	dc.l 23200,27520,11680,18240,15040,4960,4480,16800,1600,12960
	dc.l 23840,31200,6560,21600,31520,8640,15200,20640,30400,31360
	dc.l 21760,5920,1920,23040,18880,9920,11040,3360,28480,8480,4160
	dc.l 2080,13120,30240,24640,10080,14880,18080,24160,5280,24320
	dc.l 14560,1760,16320,4320,10400,23360,3040,29280,17280,20000
	dc.l 1280,9760,26560,19680,20800,2400,6880,26880,9280,16640,31040
	dc.l 8800,25760,22880,10880,19360,30560,29600,24000,9120,7680
	dc.l 11520,3520,27680,26400,28800,21120,17120,27840,22560,17600
	dc.l 1120,1440,12320,12480,21280,8960,19520,960,19200,25120,13760
	dc.l 2240,17920,8000,4640,24480,16960,18400,26720,31680,29120
	dc.l 10560,6720,4000,25920,31840,13920,640,19840,5600,10720,16480
	dc.l 28640,320,25280,5120,13280,6400,21920,21440,12640,19040,16160
	dc.l 24960,7200,30880,30720,29920,7520,5440,160,17440,25440,28160
	dc.l 24800,9600,15680,480,18720,20480,3840,14080,2880,8320,27200
	dc.l 30080,14240,11840,28960,26080,18560,25600,22400,23680,22240
	dc.l 11360,9440,14400,20960,26240,8160,22080,12000,20320,2560
	dc.l 14720,12800,10240,22720,29440,7360,27360,3680,7040,12160
	dc.l 13440,15520,29760,6080,6240,13600,27040,28000,5760,11200
	dc.l 15360,0,3200,2720,15840,20160,4800,17760,16000,28320,23520
	dc.l 7840,800





	rept 0
chessdoi:
	incbin "chesdata.doi"
	even
chessdoo:
	dcb.b 32000,0
	endr

chesslinepointertable:
val set 0
copies1 set 0
copies2 set 1
	rept 0 ;73
	dc.w val
	dc.w copies1
	dc.w copies2
val set val+160
copies1 set copies1+1
copies2 set copies2+2
	endr
	rept 0 ;73
	dc.w val
	dc.w copies1
	dc.w copies2
val set val-160
copies1 set copies1-1
copies2 set copies2-2
	endr
	rept 0 ;73
	dc.w val
	dc.w copies1
	dc.w copies2
val set val+160
copies1 set copies1+1
copies2 set copies2+2
	endr





rotbarsrottable:
	rept 0
	dcb.b 25,1
	dcb.b 24,2
	dcb.b 23,3
	endr
	dcb.b 22,4
	dcb.b 21,5
	dcb.b 20,6
	dcb.b 19,7
	dcb.b 18,8
	dcb.b 17,9
	dcb.b 18,8
	dcb.b 19,7
	dcb.b 20,6
	dcb.b 21,5
	rept 0
	dcb.b 22,4
	dcb.b 23,3
	dcb.b 24,2
	endr
	dc.b -1
	even

rotbarslowreztable:
val set 0
	rept 20
	dcb.b 10,val
val set val+10
	endr

blitmasksdoo:
	incbin "bltscrx.doo"

blitmaskstable:
	dc.l blitmasksoffsets+(4*0),16 ; pattern dither
	dc.l blitmasksoffsets+(4*16),32 ; diffusion dither
	dc.l blitmasksoffsets+(4*48),12 ; circle
	dc.l blitmasksoffsets+(4*60),8 ; X
	dc.l blitmasksoffsets+(4*68),16 ; nokia snake
	dc.l blitmasksoffsets+(4*84),16 ; vertical line
	dc.l blitmasksoffsets+(4*100),16 ; square bottom left corner
	dc.l blitmasksoffsets+(4*116),8 ; center square
	dc.l blitmasksoffsets+(4*124),31 ; top left corner diagonally
	dc.l blitmasksoffsets+(4*155),15 ; top left corner diagonally half size
	dc.l blitmasksoffsets+(4*170),7 ; top left corner diagonally quarter size

blitmasksoffsets:
mx set 0
my set 0
	rept 20
	dc.l blitmasksdoo+mx+my
mx set mx+8
	endr
mx set 0
my set my+(160*16)
	rept 20
	dc.l blitmasksdoo+mx+my
mx set mx+8
	endr
mx set 0
my set my+(160*16)
	rept 20
	dc.l blitmasksdoo+mx+my
mx set mx+8
	endr
mx set 0
my set my+(160*16)
	rept 20
	dc.l blitmasksdoo+mx+my
mx set mx+8
	endr
mx set 0
my set my+(160*16)
	rept 20
	dc.l blitmasksdoo+mx+my
mx set mx+8
	endr
mx set 0
my set my+(160*16)
	rept 20
	dc.l blitmasksdoo+mx+my
mx set mx+8
	endr
mx set 0
my set my+(160*16)
	rept 20
	dc.l blitmasksdoo+mx+my
mx set mx+8
	endr
mx set 0
my set my+(160*16)
	rept 20
	dc.l blitmasksdoo+mx+my
mx set mx+8
	endr
mx set 0
my set my+(160*16)
	rept 20
	dc.l blitmasksdoo+mx+my
mx set mx+8
	endr


thesisdoooffsettable:
	dc.l 0,64000,128000,32000,96000,160000

bibframetable:
	; bull1
	dc.l 0,40,bibbubblewait,bibbubblewait,bibbubblewait,80
	dc.l 30,bibbubblewait,bibbubblewait,bibbubblewait,80
	dc.l 30,bibbubblewait,bibbubblewait,bibbubblewait;,80
	; if
	dc.l 1001,80
	rept 4
	dcb.l 5,bibswooshspeed
	dc.l 10
	dcb.l bibflashtimes,10010
	dc.l 10
	dcb.l 5,bibswooshspeed
	endr
	dcb.l 6,bibswooshspeed
	dc.l 10
	dcb.l bibflashtimes+6,10010
	dc.l 10
	dcb.l 5,bibswooshspeed
	; bull2
	dc.l 1002,10,bibbubblewait,bibbubblewait,bibbubblewait,bibbubblewait;,80
	; end
	dc.l -1


urgayframetable:
	dc.w 16,48,48
	dc.w 3,3,3,39
	dc.w 3,3,3,39
	dc.w 3,3,3,39


kinseyframetable:
	dc.w 48,6,6,6,6
	dc.w 24,24,6,6,6,6,6,6,6
	dc.w 24,24,6,6,6,6,6,6,6
	dc.w 177
	dc.w 12,12,48,48,48,48,48
	dc.w 94,3,3,3,3,3


blob_listofs:	dc.w	0
blob_zoomlist:	dcb.l	400,0
blob_zoomlist2:	dcb.l	400,0
blob_pal:	dc.w	$0000
		dcb.w	15,$0fff









rasters1doifilename:
	addpath
	dc.b "tlk2_119.d8a",0
;	dc.b "rasters1.doi",0
	even
rasters2doifilename:
	addpath
	dc.b "tlk2_400.d8a",0
;	dc.b "rasters2.doi",0
	even
rasters3doifilename:
	addpath
	dc.b "tlk2_401.d8a",0
;	dc.b "rasters3.doi",0
	even

evilsintablefilename:
	addpath
	dc.b "tlk2_423.d8a",0
;	dc.b "evilsin.tab",0
	even
evilblobtablefilename:
	addpath
	dc.b "tlk2_424.d8a",0
;	dc.b "evilblob.dti",0
	even

credits1doofilename:
	addpath
	dc.b "tlk2_416.d8a",0
;	dc.b "credits1.doi",0
	even
credits2doofilename:
	addpath
	dc.b "tlk2_417.d8a",0
;	dc.b "credits2.doi",0
	even
credits3doofilename:
	addpath
	dc.b "tlk2_418.d8a",0
;	dc.b "credits3.doi",0
	even
credits4doofilename:
	addpath
	dc.b "tlk2_419.d8a",0
;	dc.b "credits4.doi",0
	even
credits5doofilename:
	addpath
	dc.b "tlk2_420.d8a",0
;	dc.b "credits5.doi",0
	even
credits6doofilename:
	addpath
	dc.b "tlk2_421.d8a",0
;	dc.b "credits6.doi",0
	even
credits7doofilename:
	addpath
	dc.b "tlk2_422.d8a",0
;	dc.b "credits7.doi",0
	even

kalmsdoifilename:
	addpath
	dc.b "tlk2_328.d8a",0
;	dc.b "kalms.doi",0
	even

threedeecuttbifilename:
	addpath
	dc.b "tlk2_327.d8a",0
;	dc.b "3dctab.tbi",0
	even

please00doifilename:
	addpath
	dc.b "tlk2_314.d8a",0
;	dc.b "pls4b00.doi",0
	even
please01doifilename:
	addpath
	dc.b "tlk2_315.d8a",0
;	dc.b "pls4b01.doi",0
	even
please02doifilename:
	addpath
	dc.b "tlk2_316.d8a",0
;	dc.b "pls4b02.doi",0
	even
please03doifilename:
	addpath
	dc.b "tlk2_317.d8a",0
;	dc.b "pls4b03.doi",0
	even
please04doifilename:
	addpath
	dc.b "tlk2_318.d8a",0
;	dc.b "pls4b04.doi",0
	even
please05doifilename:
	addpath
	dc.b "tlk2_319.d8a",0
;	dc.b "pls4b05.doi",0
	even
please06doifilename:
	addpath
	dc.b "tlk2_320.d8a",0
;	dc.b "pls4b06.doi",0
	even
please07doifilename:
	addpath
	dc.b "tlk2_321.d8a",0
;	dc.b "pls4b07.doi",0
	even
please08doifilename:
	addpath
	dc.b "tlk2_322.d8a",0
;	dc.b "pls4b08.doi",0
	even
please09doifilename:
	addpath
	dc.b "tlk2_323.d8a",0
;	dc.b "pls4b09.doi",0
	even
please10doifilename:
	addpath
	dc.b "tlk2_324.d8a",0
;	dc.b "pls4b10.doi",0
	even
please11doifilename:
	addpath
	dc.b "tlk2_325.d8a",0
;	dc.b "pls4b11.doi",0
	even
please12doifilename:
	addpath
	dc.b "tlk2_326.d8a",0
;	dc.b "pls4b12.doi",0
	even

noabsdoifilename:
	addpath
	dc.b "tlk2_313.d8a",0
;	dc.b "noabs.doi",0
	even

rotbars1doifilename:
	addpath
	dc.b "tlk2_229.d8a",0
;	dc.b "rotbrs13.doi",0
	even
rotbars2doifilename:
	addpath
	dc.b "tlk2_300.d8a",0
;	dc.b "rotbrs23.doi",0
	even
rotbars3doifilename:
	addpath
	dc.b "tlk2_301.d8a",0
;	dc.b "rotbrs33.doi",0
	even

rotbarstbifilename:
	addpath
	dc.b "tlk2_302.d8a",0
;	dc.b "rotbars.tbi",0
	even


shiny01filename:
	addpath
	dc.b "tlk2_404.d8a",0
;	dc.b "shiny00.imi",0
	even
shiny02filename:
	addpath
	dc.b "tlk2_405.d8a",0
;	dc.b "shiny01.imi",0
	even
shiny03filename:
	addpath
	dc.b "tlk2_406.d8a",0
;	dc.b "shiny02.imi",0
	even
shiny04filename:
	addpath
	dc.b "tlk2_407.d8a",0
;	dc.b "shiny03.imi",0
	even
shiny05filename:
	addpath
	dc.b "tlk2_408.d8a",0
;	dc.b "shiny04.imi",0
	even
shiny06filename:
	addpath
	dc.b "tlk2_409.d8a",0
;	dc.b "shiny05.imi",0
	even
shiny07filename:
	addpath
	dc.b "tlk2_410.d8a",0
;	dc.b "shiny06.imi",0
	even
shiny08filename:
	addpath
	dc.b "tlk2_411.d8a",0
;	dc.b "shiny07.imi",0
	even
shiny09filename:
	addpath
	dc.b "tlk2_412.d8a",0
;	dc.b "shiny08.imi",0
	even
shiny10filename:
	addpath
	dc.b "tlk2_413.d8a",0
;	dc.b "shiny09.imi",0
	even
shiny11filename:
	addpath
	dc.b "tlk2_414.d8a",0
;	dc.b "shiny10.imi",0
	even
shiny12filename:
	addpath
	dc.b "tlk2_415.d8a",0
;	dc.b "shiny11.imi",0
	even

thesis1doifilename:
	addpath
	dc.b "tlk2_310.d8a",0
;	dc.b "thesis1.doi",0
	even

thesis2doifilename:
	addpath
	dc.b "tlk2_311.d8a",0
;	dc.b "thesis2.doi",0
	even

thesanxi4filename:
	addpath
	dc.b "tlk2_312.d8a",0
;	dc.b "thesan.xi4",0
	even

earthdoifilename:
	addpath
	dc.b "tlk2_309.d8a",0
;	dc.b "earth.doi",0
	even

earthbwdoifilename:
	addpath
	dc.b "tlk2_402.d8a",0
;	dc.b "earth_bw.doi",0
	even

bull1xi4filename:
	addpath
	dc.b "tlk2_306.d8a",0
;	dc.b "bull1.xi4",0
	even

bull2xi4filename:
	addpath
	dc.b "tlk2_307.d8a",0
;	dc.b "bull2.xi4",0
	even

ifxi4filename:
	addpath
	dc.b "tlk2_308.d8a",0
;	dc.b "if.xi4",0
	even

clusterxp4filename:
	addpath
	dc.b "tlk2_403.d8a",0
;	dc.b "clust.xi4",0
	even

acknowxi4filename:
	addpath
	dc.b "tlk2_303.d8a",0
;	dc.b "acknow.xi4",0
	even

kinseyxi4filename:
	addpath
	dc.b "tlk2_228.d8a",0
;	dc.b "kinsey.xi4",0
	even

otherurxi4filename:
	addpath
	dc.b "tlk2_304.d8a",0
;	dc.b "other.xi4",0
	even

urgayxi4filename:
	addpath
	dc.b "tlk2_305.d8a",0
;	dc.b "urgay.xi4",0
	even


labeltextdoifilename:
	addpath
	dc.b "tlk2_225.d8a",0
;	dc.b "labeltxt.doi",0
	even

topicdoifilename:
	addpath
	dc.b "tlk2_226.d8a",0
;	dc.b "topic.doi",0
	even

talktalk2logoxi4filename:
	addpath
	dc.b "tlk2_227.d8a",0
;	dc.b "tlk2lg.xi4",0
	even

churchlogodoifilename:
	addpath
	dc.b "tlk2_200.d8a",0
;	dc.b "churlogo.doi",0
	even

spintablefilename:
	addpath
	dc.b "tlk2_100.d8a",0
;	dc.b "spin.tbi",0
	even

fliptablefilename:
	addpath
	dc.b "tlk2_101.d8a",0
;	dc.b "flip.tbi",0
	even

mychurchxp4filename:
	addpath
	dc.b "tlk2_102.d8a",0
;	dc.b "mychurch.xi4",0
	even

handsxp4filename:
	addpath
	dc.b "tlk2_103.d8a",0
;	dc.b "hands.xi4",0
	even

ifyouthinkxp4filename:
	addpath
	dc.b "tlk2_104.d8a",0
;	dc.b "ifuthnk.xi4",0
	even

introxp4filename:
	addpath
	dc.b "tlk2_105.d8a",0
;	dc.b "intro.xi4",0
	even

beesdoo1filename:
	addpath
	dc.b "tlk2_106.d8a",0
;	dc.b "bees1.doi",0
	even
beesdoo2filename:
	addpath
	dc.b "tlk2_107.d8a",0
;	dc.b "bees2.doi",0
	even
beeslonelydoofilename:
	addpath
	dc.b "tlk2_108.d8a",0
;	dc.b "lonely_b.doi",0
	even

labels1doifilename:
	addpath
	dc.b "tlk2_109.d8a",0
;	dc.b "labels1.doi",0
	even
labels2doifilename:
	addpath
	dc.b "tlk2_110.d8a",0
;	dc.b "labels2.doi",0
	even
labels3doifilename:
	addpath
	dc.b "tlk2_111.d8a",0
;	dc.b "labels3.doi",0
	even
labels4doifilename:
	addpath
	dc.b "tlk2_112.d8a",0
;	dc.b "labels4.doi",0
	even

bars1doifilename:
	addpath
	dc.b "tlk2_113.d8a",0
;	dc.b "finbar1.doi",0
	even
bars2doifilename:
	addpath
	dc.b "tlk2_114.d8a",0
;	dc.b "finbar2.doi",0
	even
bars3doifilename:
	addpath
	dc.b "tlk2_115.d8a",0
;	dc.b "finbar3.doi",0
	even
bars4doifilename:
	addpath
	dc.b "tlk2_116.d8a",0
;	dc.b "finbar4.doi",0
	even

flip1xp4filename:
	addpath
	dc.b "tlk2_117.d8a",0
;	dc.b "flipa.xi4",0
	even
posrespxp4filename:
	addpath
	dc.b "tlk2_118.d8a",0
;	dc.b "posresp.xi4",0
	even

museks_zerofilename:
	addpath
	dc.b "tlk2_201.d8a",0
;	dc.b "eks_zero.raw",0
	even
musm_x1filename:
	addpath
	dc.b "tlk2_202.d8a",0
;	dc.b "m_x1.raw",0
	even
musx2filename:
	addpath
	dc.b "tlk2_203.d8a",0
;	dc.b "x2.raw",0
	even
musx3filename:
	addpath
	dc.b "tlk2_204.d8a",0
;	dc.b "x3.raw",0
	even
musx3bfilename:
	addpath
	dc.b "tlk2_205.d8a",0
;	dc.b "x3b.raw",0
	even
musx4filename:
	addpath
	dc.b "tlk2_206.d8a",0
;	dc.b "x4.raw",0
	even
musa1filename:
	addpath
	dc.b "tlk2_207.d8a",0
;	dc.b "a1.raw",0
	even
musa2filename:
	addpath
	dc.b "tlk2_208.d8a",0
;	dc.b "a2.raw",0
	even
musa3filename:
	addpath
	dc.b "tlk2_209.d8a",0
;	dc.b "a3.raw",0
	even
musa3bfilename:
	addpath
	dc.b "tlk2_210.d8a",0
;	dc.b "a3b.raw",0
	even
musa4filename:
	addpath
	dc.b "tlk2_211.d8a",0
;	dc.b "a4.raw",0
	even
musa4bfilename:
	addpath
	dc.b "tlk2_212.d8a",0
;	dc.b "a4b.raw",0
	even
muse1filename:
	addpath
	dc.b "tlk2_213.d8a",0
;	dc.b "e1.raw",0
	even
muse2filename:
	addpath
	dc.b "tlk2_214.d8a",0
;	dc.b "e2.raw",0
	even
muse3filename:
	addpath
	dc.b "tlk2_215.d8a",0
;	dc.b "e3.raw",0
	even
muse4filename:
	addpath
	dc.b "tlk2_216.d8a",0
;	dc.b "e4.raw",0
	even
musf1filename:
	addpath
	dc.b "tlk2_217.d8a",0
;	dc.b "f1.raw",0
	even
musf2filename:
	addpath
	dc.b "tlk2_218.d8a",0
;	dc.b "f2.raw",0
	even
musf3filename:
	addpath
	dc.b "tlk2_219.d8a",0
;	dc.b "f3.raw",0
	even
musf4filename:
	addpath
	dc.b "tlk2_220.d8a",0
;	dc.b "f4.raw",0
	even
musg1filename:
	addpath
	dc.b "tlk2_221.d8a",0
;	dc.b "g1.raw",0
	even
musg2filename:
	addpath
	dc.b "tlk2_222.d8a",0
;	dc.b "g2.raw",0
	even
musg3filename:
	addpath
	dc.b "tlk2_223.d8a",0
;	dc.b "g3.raw",0
	even
musg4filename:
	addpath
	dc.b "tlk2_224.d8a",0
;	dc.b "g4.raw",0
	even

mussilentsample:
	dc.b 127,127
mussilentsampleend:



;///////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////
;///
;/// Data to replace after intro

postintrodata:

labels equ postintrodata+96006 ; label to unpack 4*32000 bytes
bars equ labels+128000 ; 4*32000 bytes
churchlogodoo equ bars+128000
labeltextdoo equ postintrodata
talktalk2logoxp4 equ churchlogodoo+32000 ; 34700 -- 386706
acknowxp4 equ postintrodata;+32000 ; 45304 -- 386706
kinseyxp4 equ talktalk2logoxp4+45304 ; 105692 -- 492398
otherurxp4 equ kinseyxp4+105692 ; 124792 -- 617190
urgayxp4 equ otherurxp4+124792 ; 99008 -- 716198

; 2nd round

bull1xp4 equ postintrodata ; 67416 --  67416
bull2xp4	equ postintrodata+67416 ; 32848 -- 100264
ifxp4 equ bull2xp4+32848 ; 154380 -- 254644
thesis1doo equ ifxp4+154380 ; 32000 -- 286644
thesis2doo equ thesis1doo+32000 ; 32000 -- 318644
thesanxp4 equ thesis2doo+32000 ; 109740 -- 428384
earthbwdoo equ thesanxp4+109740 ; 32000 -- 460384
earthdoo equ earthbwdoo+32000 ; 32000 -- 492384
waterdroptable equ earthdoo+32000 ; 22500 -- 524384

; 2nd round ends at 546884

; 3rd round

shiny01 equ postintrodata ; 12*24000 bytes = 288000 bytes
shiny02 equ shiny01+24000
shiny03 equ shiny02+24000
shiny04 equ shiny03+24000
shiny05 equ shiny04+24000
shiny06 equ shiny05+24000
shiny07 equ shiny06+24000
shiny08 equ shiny07+24000
shiny09 equ shiny08+24000
shiny10 equ shiny09+24000
shiny11 equ shiny10+24000
shiny12 equ shiny11+24000

rotbars1doo equ shiny12+24000 ; 32000 -- 320000
rotbars2doo equ rotbars1doo+32000 ; 32000 -- 352000
rotbars3doo equ rotbars2doo+32000 ; 32000 -- 384000
rotbarsdoo equ rotbars3doo+32000 ; 32000 -- 416000
rotbarstable equ rotbarsdoo+32000 ; 45000 -- 461000
noabsdoo equ rotbarstable+45000 ; 32000 -- 493000

threedeecuttable equ noabsdoo+32000 ; 312448 -- 805448

; 3rd round ends at 805448





postintrodataend equ urgayxp4+99008 ; -- 815206







;------------------------


filehandle: ; 2 bytes
	dc.w 0
filesize: ; 4 bytes
	dc.l 0

;-- 6 bytes

beesdoo1: ; 32 000  bytes
;	incbin bees1.doo
	dcb.b 32000,0
beesdoo2: ; 32 000 bytes
;	incbin bees2.doo
	dcb.b 32000,0
beeslonelydoo: ; 32 000 bytes
;	incbin lonely_b.doo
	dcb.b 32000,0

;-- 96006 bytes

intropal: ; 32 bytes
		dc.w	$0000,$0111,$0999,$0222,$0AA9,$033A,$0A3B,$04B3
		dc.w	$04BA,$0CC4,$05C3,$0D54,$06DC,$0665,$0EE6,$0FF7
introxp4:
;	incbin intro.xp4 ; 67 456 bytes
	dcb.b 67456,0

;-- 163 494 bytes

ifyouthinkxp4:
;	incbin ifuthnk.xp4 ; 22 420 bytes
	dcb.b 22420,0

;-- 185 914

handsxp4:
;	incbin hands.xp4 ; 120 388 bytes
	dcb.b 120388,0
handsequencetable: ; number of quarter notes to wait for each frame ; 20 bytes
	dc.b 3,3,3,3,3,1,1,1,3,0,0,0,0,0,3,99,1,1,98,2
	even

;-- 306 322

mychurchxp4:
;	incbin mychurch.xp4 ; 199 376 bytes
	dcb.b 199376,0
	even
mychurchscrollcounter: ; 4 bytes
	dc.l 0
mychurchscrollwaiter: ; 2 bytes
	dc.w 0
mychurchscrollfadewaiter: ; 2 bytes
	dc.w 0

	dc.l -1		; Must be just before "mychurchtable" label
mychurchtable: ; 4196 bytes (including precluding longword)
  v set 0
	rept 200
  	dc.l v
    v set v+160
	endr
mychurchtablethechurchofxia:
	rept 200
  	dc.l v
    v set v+160
	endr
  v set v+(32000*3)
mychurchtabletalktalk2:
	rept 200
  	dc.l v
    v set v+160
	endr
  v set v+(32000*3)
mychurchtablepresents:
	rept 200
  	dc.l v
    v set v+160
	endr
  v set v+(32000*3)
mychurchtablexia2010:
	rept 200
  	dc.l v
    v set v+160
	endr
	rept 48
  	dc.l v
    v set v+160
	endr
mychurchtableend:
mychurchtablepos:
	dc.l 0

;-- 509 902 bytes

loadgaugexp4:
	incbin "ldgaug.xp4" ; 32 608 bytes
loadanimxp4:
	incbin "ldanim.xp4" ; 53 324 bytes

;-- 595 834

handspal:
		dc.w	$0000,$064B,$07DC,$0FE6,$0555,$0DDD,$0EEE,$0FFF
		dc.w	$066D,$0222,$0111,$0AAA,$0BBB,$0C44,$0C99,$0F2A
ifyouthinkpal:
		dc.w	$0000,$0222,$0DDD,$0BBB,$02A3,$0111,$0192,$0981
		dc.w	$0219,$092A,$0AAA,$0CCC,$0292,$0444,$0888,$0333
mychurchpal2:
		dc.w	$0000,$0888,$0811,$0199,$0922,$02AA,$0233,$0ABB
		dc.w	$0344,$04C4,$0C5C,$05DC,$0D65,$0EED,$077D,$0FF6
mychurchpal3:
		dc.w	$0000,$0188,$0911,$0A19,$0392,$042A,$0CAA,$0533
		dc.w	$0DB3,$064B,$0ECB,$0E54,$07DC,$07D5,$0F6D,$0FE6
mychurchpal1:
		dc.w	$0000,$0888,$0111,$0199,$092A,$02A3,$0A3B,$03B4
		dc.w	$0B4C,$04C5,$0C5D,$0DDD,$0666,$0EEE,$0777,$0FFF

;-- 595 994



	dcb.b 88202,0 ; ...to get it up to 716198

	dcb.b 99008,0 ; ...to get it up to 815206

	dcb.b 2,0 ; to get a number divisible by 4

;-- 815 208


;///
;///////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////
;///////////////////////////////////////////////////////////////////////////////////

	dcb.b 32000,0

loadmessages:
	incbin "loadmsgs.doo"

loaddataerror equ loadmessages
loaddatadisk2 equ loadmessages+160*45
loaddatadisk3 equ loadmessages+160*45*2
loaddatadisk4 equ loadmessages+160*45*3

	if enableggncredits=1
v11message:
;	incbin v11fix.imi
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0018,$60DB
		dc.w	$60A1,$C733
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$06D8,$6870
		dc.w	$71F3,$0C3B
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$06DB,$6073
		dc.w	$78E3,$6DBF
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$0000,$0000
		dc.w	$079B,$68DB
		dc.w	$6C41,$E7B7
			endif

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;oldusp:	ds.l	1
;oldusp:	dc.l	0§
;oldvbl:	dc.l	0

	.bss

oldrez:	ds.w 1
;oldvbl:	ds.l	1
oldpal: ds.w 16
old8260: ds.l 1
old820a: ds.l 1
old8265:	ds.b 1
old820f:	ds.b 1
	even

physbase:	ds.l 1
old8203: ds.b 1
old8201: ds.b 1
old820d: ds.b 1
old484: ds.b 1

	if enablehbl
old07:	ds.b 1
old09:	ds.b 1
old13:	ds.b 1
old1b:	ds.b 1
old21:	ds.b 1
	even
oldhbl:	ds.l 1
	endif

	even
startupsp: ds.l 1



; switches
musicinvbl:	ds.w 1
musicinvblextra: ds.w 1
copperenabled:	ds.w 1

physscreen:	ds.l 1
framecounter:	ds.l	1
currentpalette:	ds.w	16
vblflag:	ds.w	1
vblextraaddress:	ds.l 1

; copper stuff
hblcounter:	ds.w 1
hbladrbyte0: ds.b 1
hbladrbyte1: ds.b 1
hbladrbyte2: ds.b 1
hbladrbyte3: ds.b 1
hblsavea0:	ds.l 1
copperbottomscreenaddress:	ds.l 1
copperlist:	ds.w (150*2)+150 ; 150 longwords (screenaddr) + 150 words (scroll reg)
copperlist2:	ds.w (150*2)+150
copperlistpointer:	ds.l 1
copperlistdone:	ds.w 1
copperlistaddress: ds.l 1
smokecopperlistaddress: ds.l 1

screenaddress:	ds.l 1
smokescreenaddress:	ds.l 1
smokescreen1: ds.b 32000
smokescreen2: ds.b 32000

thesisanimarea: ;6*32000
testdoo equ thesisanimarea+32000
testdoo2 equ thesisanimarea+64000
please00doo:
please01doo equ please00doo+(32000*1)
please02doo equ please00doo+(32000*2)
please03doo equ please00doo+(32000*3)
please04doo equ please00doo+(32000*4)
please05doo equ please00doo+(32000*5)
please06doo equ please00doo+(32000*6)
please07doo equ please00doo+(32000*7)
please08doo equ please00doo+(32000*8)
please09doo equ please00doo+(32000*9)
please10doo equ please00doo+(32000*10)
please11doo equ please00doo+(32000*11)
please12doo equ please00doo+(32000*12)
mychurchscroll:	; 15*32000
extraloadingscreen: ; 32000
talktalk2logodoo: ; 4*32000
threedeecuttablemirrored: ; 312448
	rept 6
	ds.b 32000
	endr
loaddatamessagescreen:
beesscreen:	; 32000*2
	rept 9
	ds.b 32000
	endr

	ds.b 8 ; ugly solution to the following data being corrupted 8-)








rasters1doi:
	ds.b 24191
	even
rasters2doi:
	ds.b 23312
	even
rasters3doi:
	ds.b 22038
	even

kalmsdoi:
	ds.b 5237
	even

threedeecuttbi:
	ds.b 86975
	even

please00doi:
	ds.b 7478
	even
please01doi:
	ds.b 7356
	even
please02doi:
	ds.b 8430
	even
please03doi:
	ds.b 6265
	even
please04doi:
	ds.b 6945
	even
please05doi:
	ds.b 8611
	even
please06doi:
	ds.b 5887
	even
please07doi:
	ds.b 6035
	even
please08doi:
	ds.b 3340
	even
please09doi:
	ds.b 2862
	even
please10doi:
	ds.b 6064
	even
please11doi:
	ds.b 5388
	even
please12doi:
	ds.b 7828
	even

noabsdoi:
	ds.b 6349
	even

thesis1doi:
	ds.b 4713
	even

thesis2doi:
	ds.b 6601
	even

SegmentedLine_GeneratedCodeBuffer:
thesanxi4:
	ds.b 85177
	even

earthdoi:
	ds.b 7229
	even

; by here, the SegmentedLine buffer is done

creditsblock:
credits1doo equ creditsblock
credits2doo equ credits1doo+32000
credits3doo equ credits2doo+32000
credits4doo equ credits3doo+32000
credits5doo equ credits4doo+32000
credits6doo equ credits5doo+32000
credits7doo equ credits6doo+32000
creditsblockend equ credits7doo+32000
creditswrappoint equ credits7doo+(160*49)

evilsintable equ creditsblockend
evilblobtable equ evilsintable+10240
blob_sincos equ evilsintable
blob_data equ evilblobtable


earthbwdoi:
	ds.b 1824
	even

bull1xi4:
	ds.b 46118
	even

bull2xi4:
	ds.b 23202
	even

ifxi4:
	ds.b 115796
	even

talktalk2logoxi4:
	ds.b 25621
	even

churchlogodoi:
	ds.b 5755
	even

spintable:
; 50 frames of 150 longwords each
	ds.b 7800

fliptable:
	ds.b 34800

bars1doi:
	ds.b 6530
	even
bars2doi:
	ds.b 9228
	even
bars3doi:
	ds.b 10716
	even
bars4doi:
	ds.b 9175
	even

rotbars1doi:
	ds.b 10661
	even
rotbars2doi:
	ds.b 4377
	even
rotbars3doi:
	ds.b 8557
	even

rotbarstbi:
	ds.b 3745
	even


;--- Area to use for other stuff


clusterxp4:
;	ds.b 404556
;	even

flip1xp4:
	ds.b 221196

posrespxp4:
	ds.b 42092

acknowxi4:
	ds.b 38355
	even

kinseyxi4:
	ds.b 50819
	even

otherurxi4:
	ds.b 80863
	even

urgayxi4:
	ds.b 78077
	even

labeltextdoi:
	ds.b 4636
	even

topicdoi:
	ds.b 6545
	even

labels1doi:
	ds.b 5722
	even
labels2doi:
	ds.b 4718
	even
labels3doi:
	ds.b 6959
	even
labels4doi:
	ds.b 6583
	even

;-- sum: 546 572 bytes (incl added "even" bytes)

;--- no crossing this boundary!!

;	include _i_remus.s

macro musreserve
mus\1:
	ds.b \2
mus\1end:
	even
	endm

	musreserve eks_zero,48320
	musreserve m_x1,24130
	musreserve x2,24130
	musreserve x3,24130
	musreserve x3b,24130
	musreserve x4,24130

	musreserve a1,24130
	musreserve a2,24130
	musreserve a3,24130
	musreserve a3b,24130
	musreserve a4,24130
	musreserve a4b,24130

	musreserve e1,24130
	musreserve e2,24130
	musreserve e3,24130
	musreserve e4,24130

	musreserve f1,24130
	musreserve f2,24130
	musreserve f3,24130
	musreserve f4,24130

	musreserve g1,24130
	musreserve g2,24130
	musreserve g3,24130
	musreserve g4,24130


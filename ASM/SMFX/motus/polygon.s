TEXTEST		equ	1
OBJECT_TYPE	equ	0				; 0 =	triangle - 		"gfx/lava4.neo"
								; 1 =	square -	"gfx/textmap/text_caltropa.neo"
								; 2 =	torus
								; 3 =	cube
								; 4 = 	caltrop


pOLSize	equ 30					; struct size
pOLItems equ 17					; nr of objects


POLYGON_PREP_PANELS	equ 1

DRAW_YLINES_OFFSET	equ 16

Z_ON		equ 0
SEP_UV		equ 0

; todo: 
;	- toggle for rotation code
;	- presentation
;

BENCHMARK		equ 1


ENVMAP_TT		equ 0 


	IFD DEMOSYSTEM
		IFD	STANDALONE
		ELSE
STANDALONE 					equ 1
		ENDC
	ELSE
STANDALONE					equ 0
	ENDC

	IFEQ STANDALONE
TRUE	equ	0
FALSE	equ 1
true	equ 0
false	equ 1
POLYGON_EFFECT_VBL		equ 500
POLYGON_TORUS_SELECT	equ 1
OUTTRO_CINEMASCOPE		equ 0
	ENDC


	incdir	gfx
	incdir	lib
	incdir	msx
	incdir	res/smfx

    section	DATA

	IFEQ	STANDALONE

			include macro.s
			initAndRun	init_effect



init_effect
	jsr		init_demo
	IFEQ	POLYGON_PREP_PANELS
	jsr		prepLogos
	ENDC
	jsr		init_polygons
	move.w	#32000,effect_vbl_counter
	jsr		polygons_mainloop

init_demo
	move.w	#$000,$ffff8240
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,screen1
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	move.l	d0,screen2
	rts

	ENDC

init_polygons
	; pointers
	move.l	screen1,d0
	move.l	d0,screenpointer
	move.l	screen2,d0
	move.l	d0,screenpointer2
	add.l	#$20000,d0
	move.l	d0,divtablepointer_polygon
	add.l	#$20000,d0
	move.l	d0,texturepointer_polygon
	add.l	#$20000,d0
	move.l	d0,texturepointer_polygon2
	add.l	#$20000,d0
	move.l	d0,texturepointer_polygon3
	move.l	d0,d1
	add.l	#$12000,d1


	move.l	d1,canvasPointer_text_polygon
	add.l	#128*128,d1

	move.l	d1,justDoItPointer
	add.l	#12800,d1
	move.l	d1,smfxPointer
	add.l	#6400,d1
	move.l	d1,motusPointer
	add.l	#8000,d1

	move.l	d1,currentSourceFacesPointer
	add.l	#6000,d1
	move.l	d1,currentVerticesPointer
	add.l	#6000,d1
	move.l	d1,currentNormalsPointer
	add.l	#6000,d1
	move.l	d1,currentPointsPointer
	add.l	#6000,d1
	move.l	d1,currentDestFacesPointer
	add.l	#6000,d1	
	move.l	d1,localListPointer
	add.l	#6*200,d1
	move.l	d1,textPtr
;	move.b	#0,$ffffc123
;f	move.l	#.xvbl,$70
	move.w	#$777,timer_b_open_curtain+2



	move.w	#pOLSize*OBJECT_TYPE,polygonObjectListOff

	lea		caltropTextcrk,a0
	move.l	textPtr,a1
;	lea		caltropText,a1
	jsr		cranker

;	move.w	#$777,$ffff8242
	move.l	screenpointer,$ffff8200


	IFNE	STANDALONE
	move.w	allYellow,timer_b_open1+2
	move.w	allBlue,timer_b_open2+2
	move.w	allRed,timer_b_open3+2
	move.w	allGreen,timer_b_open4+2
	move.w	allGrey,timer_b_open5+2
	ENDC

	move.l	#diagTrans,$70


;	lea		caltropText+128,a0
	move.l	textPtr,a0
	add.w	#128,a0
	move.l	texturepointer_polygon2,a1
	move.l	#180-1,d6
	jsr		planarToChunky_text_polygon_cube



	lea		cubeTextcrk,a0
	move.l	textPtr,a1
;	lea		cubeText,a1
	jsr		cranker




	move.l	textPtr,a0
	add.w	#128,a0
;	lea		cubeText+128,a0
	move.l	texturepointer_polygon,a1
	move.l	#160-1,d6
	jsr		planarToChunky_text_polygon_cube

	lea		cube1Pal,a0
	lea		cubeFade1,a2		; dest pal
	jsr		calcFade

	lea		cube2Pal,a0
	lea		cubeFade2,a2
	jsr		calcFade

	lea		cube3Pal,a0
	lea		cubeFade3,a2
	jsr		calcFade

	lea		cube4Pal,a0
	lea		cubeFade4,a2
	jsr		calcFade

	lea		cube5Pal,a0
	lea		cubeFade5,a2
	jsr		calcFade


	IFEQ	STANDALONE
	lea		torusText+128,a0
	move.l	texturepointer_polygon3,a1
	jsr		planarToChunky_text_polygon_torus

	lea		torusPal,a0
	lea		torusFade,a2		; dest pal
	jsr		calcFade

	ELSE

	lea		torusTextcrk,a0
;	lea		torusText,a1
	move.l	textPtr,a1
	jsr		cranker

;	lea		torusText+128,a0
	move.l	textPtr,a0
	add.w	#128,a0
	move.l	texturepointer_polygon3,a1
	jsr		planarToChunky_text_polygon_torus

	lea		torusPal,a0
	lea		torusFade,a2		; dest pal
	jsr		calcFade

	ENDC

	lea		justdoitcrk,a0
	move.l	justDoItPointer,a1
	jsr		cranker

	lea		smfxcrk,a0
	move.l	smfxPointer,a1
	jsr		cranker

	lea		motuscrk,a0
	move.l	motusPointer,a1
	jsr		cranker





	lea		caltrop1Pal,a0	; start pal
	lea		caltrop1Fade,a2		; dest pal
	jsr		calcFade

	lea		caltrop2Pal,a0	; start pal
	lea		caltrop2Fade,a2		; dest pal
	jsr		calcFade

	lea		caltrop3Pal,a0	; start pal
	lea		caltrop3Fade,a2		; dest pal
	jsr		calcFade

	lea		caltrop4Pal,a0
	lea		caltrop4Fade,a2
	jsr		calcFade

	lea		trianglePal,a0
	lea		triangleFade,a2
	jsr		calcFade

	lea		squarePal,a0
	lea		squareFade,a2
	jsr		calcFade

	jsr		setObject

	jsr		initDivTable_polygon
	jsr		initDivTable_polygon_pivot





	move.w	#0,yTopp
	move.w	#75,yBotp

	jsr		generateOptimizedTabs_polygon
	jsr		clearCanvas_polygon


;	move.b	#0,$ffffc123

	move.w	#0,effectcount
	move.w	#0,vblcount
	move.w	#6,d7
.ttt
	tst.w	$466.w
	beq		.ttt
		move.w	#0,$466.w
		dbra	d7,.ttt
;	cmp.w	#$4e75,removeDiagonalBlock
;	bne		.ttt

;	moveq	#0,d0
;	move.w	cummulativeCount,d0					; $00001164		
;	move.b	#0,$ffffc123

	move.w	#$777,d0
	lea		$ffff8240+2,a1
	REPT 15
		move.w	d0,(a1)+
	ENDR


	move.w	#$2700,sr
	move.l	#polygon_vbl,$70
	move.w	#$2300,sr

	rts
.xvbl
	addq.w	#1,$466.w
	rte
	IFEQ	STANDALONE
canvas_y_offset	dc.l	-70*160
	ENDC

textPtr	dc.l	0
breakOn	dc.w	0


screen1top	dc.w	0
screen1bot	dc.w	0

screen2top	dc.w	0
screen2bot	dc.w	0

currentFadePalPointer	dc.l	0
polygonObjectListOff	dc.w	0
polygonObjectList
	;1	envmap toggle 	(w)
	;2	nr of frames	(w)
	;3	nr of vbl
	;3	object_init		(l)
	;4	texture_pointer	(l)
	;5	color ramp



	;	envmap toggle,	nr_frames,	vbl_frames
	;	_current X,Y,Z
	;	_step	 X,Y,Z

;-------- part 1
	; thin triangle
	dc.w	0,185,3									;envmap?	nr_frames	vbl_effect										;140
	dc.w	0,0,0									;startx		starty		startz
	dc.w	7,0,0									;x rotate	y rotate	z rotate
		dc.l	init_Triangle						;object init rout
		dc.l	texturepointer_polygon3				;texture pointer
		dc.l	triangleFade							;fade palette

	; fatter square
	dc.w 0,185,3																											;320
	dc.w	0,0,0
	dc.w	7,-14,0
		dc.l	init_Square
		dc.l	texturepointer_polygon3
		dc.l	squareFade		

	; draw the SMFX
	dc.w	0,1,3
	dc.w	0,0,0
	dc.w	0,0,0
		dc.l	putJustDoItRight
		dc.l	texturepointer_polygon3
		dc.l	whiteFade

	; fat torus
	dc.w	0,380,3																											;620
	dc.w	0,0,0
	dc.w	-10,-14,18
		dc.l	init_Torus
		dc.l	texturepointer_polygon3
		dc.l	torusFade

	; clear the right part
	dc.w	0,1,3
	dc.w	0,0,0
	dc.w	0,0,0
		dc.l	clearRight
		dc.l	texturepointer_polygon3
		dc.l	whiteFade



;-------- part 2
	;2.1
	dc.w	-1,100,2								;envmap?	nr_frames	vbl_effect										;140
	dc.w	2,192,0								;startx		starty		startz
	dc.w	0,0,11									;x rotate	y rotate	z rotate
		dc.l	init_Caltrop2						;object init rout
		dc.l	texturepointer_polygon2				;texture pointer
		dc.l	caltrop4Fade							;fade palette

	;2.2
	dc.w	-1,95,2																											;320
	dc.w	0,0,0
	dc.w	0,14,0
		dc.l	init_Caltrop2
		dc.l	texturepointer_polygon2
		dc.l	caltrop3Fade		


	; draw the SMFX
	dc.w	0,1,2
	dc.w	0,0,0
	dc.w	0,0,0
		dc.l	putSMFXRight
		dc.l	texturepointer_polygon3
		dc.l	whiteFade


	dc.w	-1,205,2																										;1020
	dc.w	0,0,0
	dc.w	-12,-13,4
		dc.l	init_Caltrop2
		dc.l	texturepointer_polygon2
		dc.l	caltrop1Fade

	; clear the right part
	dc.w	0,1,2
	dc.w	0,0,0
	dc.w	0,0,0
		dc.l	clearRight
		dc.l	texturepointer_polygon3
		dc.l	whiteFade



;-------- part 3
	;2.1
	dc.w	-1,100,2									;envmap?	nr_frames	vbl_effect										;140
	dc.w	0,0,0									;startx		starty		startz
	dc.w	7,0,0									;x rotate	y rotate	z rotate
		dc.l	init_Cubewrap						;object init rout
		dc.l	texturepointer_polygon				;texture pointer
		dc.l	cubeFade1							;fade palette

	;2.2
	dc.w	-1,100,2																											;320
	dc.w	80,0,0
	dc.w	-7,0,0
		dc.l	init_Cubewrap
		dc.l	texturepointer_polygon
		dc.l	cubeFade2		

	;2.1
	dc.w	-1,98,2									;envmap?	nr_frames	vbl_effect										;140
	dc.w	0,0,0									;startx		starty		startz
	dc.w	7,0,0									;x rotate	y rotate	z rotate
		dc.l	init_Cubewrap						;object init rout
		dc.l	texturepointer_polygon				;texture pointer
		dc.l	cubeFade3							;fade palette

	;2.2
	dc.w	-1,94,2																											;320
	dc.w	512,0,-256
	dc.w	0,0,-6
		dc.l	init_Cubewrapfix
		dc.l	texturepointer_polygon
		dc.l	cubeFade4	


	; draw the SMFX
	dc.w	0,1,2
	dc.w	0,0,0
	dc.w	0,0,0
		dc.l	putMotusRight
		dc.l	texturepointer_polygon3
		dc.l	whiteFade

NR_CUBE_FRAMES equ 360+8
CUBE_ROT_X	equ 10
CUBE_ROT_Y	equ 15
CUBE_ROT_Z	equ 7

	dc.w	-1,NR_CUBE_FRAMES,2																										;1420
	dc.w	256*2-NR_CUBE_FRAMES/2*CUBE_ROT_X,256*3-NR_CUBE_FRAMES/2*CUBE_ROT_Y,256*2-NR_CUBE_FRAMES/2*CUBE_ROT_Z
;	dc.w	0,0,0
	dc.w	CUBE_ROT_X,CUBE_ROT_Y,7
		dc.l	initCubeEndFix
		dc.l	texturepointer_polygon
		dc.l	cubeFade5

;	dc.w	-1,900,2
;	dc.w	256*2,256*3,256*2
;	dc.w	0,0,0
;		dc.l	haxCubeParts
;		dc.l	texturepointer_polygon
;		dc.l	cubeHeartFade


	dc.w	-1,5000,2
	dc.w	256*2,256*3,256*2
	dc.w	0,0,0
		dc.l	dummyRout
		dc.l	texturepointer_polygon
		dc.l	cubeHeartFade2

;haxCubeParts
;	lea		destFaces_Cube,a6
;	movem.w	.heart,d0-d1
;	lea		.list,a5
;	movem.l	(a6,d0.w),d2/d3/d4
;	movem.l	(a6,d1.w),d5/d6/d7
;
;	REPT	5
;		move.w	(a5)+,d0
;		move.w	(a5)+,d1
;		movem.l	d2/d3/d4,(a6,d0.w)
;		movem.l	d5/d6/d7,(a6,d1.w)
;	ENDR
;	rts
;
;.heart
;	dc.w	9*26+14,3*26+14			; heart
;
;.list
;	dc.w	6*26+14,14
;	dc.w	7*26+14,1*26+14
;	dc.w	8*26+14,2*26+14
;	dc.w	10*26+14,4*26+14
;	dc.w	11*26+14,5*26+14
dummyRout
	rts

initCubeEndFix
	jsr		init_Cube
	move.w	#0,vblcount
	rts

init_Cubewrapfix
	lea		destFaces_Cube+26+14,a5				; dest 1
	lea		destFaces_Cube+7*26+14,a6			; dest 2

	movem.l	.res1,d0-d5
	movem.l	d0-d2,(a5)
	movem.l	d3-d5,(a6)
	jsr		init_Cube
	rts

.res1
	dc.w	55<<7,156<<7,104<<7,107<<7,104<<7,156<<7
.res2
	dc.w	55<<7,156<<7,55<<7,107<<7,104<<7,107<<7
init_Cubewrap
	jsr		init_Cube

		lea		.list,a2
		add.w	.listOff,a2
		add.w	#4,.listOff

		lea		destFaces_Cube,a0
		move.l	a0,a1
		add.w	(a2)+,a0
		add.w	(a2)+,a1


		lea		destFaces_Cube+26+14,a5				; dest 1
		lea		destFaces_Cube+7*26+14,a6			; dest 2

		REPT 3	
			move.l	(a0)+,(a6)+
			move.l	(a1)+,(a5)+
		ENDR
.skip
	rts
.w 	dc.w	1
.list
	dc.w	8*26+14,2*26+14			; heart
	dc.w	10*26+14,4*26+14		; diamond
	dc.w	9*26+14,3*26+14			; heart
	dc.w	6*26+14,14

.listOff
	dc.w	0

trianglePal
;	dc.w	$000,$200,$300,$400,$510,$520,$620,$630,$631,$731,$742,$753,$763,$764,$774,$775 ; orange (original)
;	dc.w 	$777,$013,$113,$123,$124,$224,$234,$235,$245,$345,$346,$356,$366,$367,$467,$567 ; metallic blue
;	dc.w 	$000,$013,$113,$123,$124,$235,$236,$245,$345,$355,$456,$466,$577,$677,$777,$707 ; metallic blue brighter
	dc.w 	$777,$011,$011,$012,$022,$123,$133,$234,$244,$345,$355,$456,$567,$777,$777,$777 ; FINAL (?)

squarePal
;	dc.w	$777,$002,$003,$004,$014,$024,$025,$035,$135,$136,$246,$356,$366,$466,$467,$567 ; orange (original)
;	dc.w	$777,$125,$126,$236,$336,$436,$426,$435,$545,$654,$753,$763,$773,$774,$775,$776 ; purple (original)
;	dc.w	$777,$003,$004,$104,$105,$106,$206,$216,$316,$317,$417,$427,$537,$647,$757,$767 ; purple (original)
;	dc.w	$777,$300,$400,$410,$420,$520,$620,$630,$631,$731,$742,$753,$763,$765,$766,$776 ; orange
;	dc.w    $777,$070,$070,$221,$233,$332,$433,$443,$544,$654,$655,$665,$766,$777,$777,$777 ; greyred
	dc.w 	$777,$070,$070,$110,$120,$230,$330,$341,$441,$452,$552,$563,$663,$674,$775,$777 ; green
;	dc.w 	$777,$070,$070,$230,$330,$340,$440,$451,$551,$562,$662,$673,$774,$775,$777,$777 ; green yellow

torusPal
	dc.w	$777,$111,$000,$111,$312,$323,$423,$523,$623,$733,$743,$753,$761,$773,$775,$777

caltrop1Pal
	dc.w	$777,$666,$555,$454,$444,$344,$234,$323,$223,$412,$122,$301,$211,$111,$000,$240

caltrop2Pal
	dc.w	$777,$676,$565,$464,$454,$354,$244,$333,$233,$422,$132,$311,$211,$121,$000,$240

caltrop3Pal
	dc.w	$777,$767,$656,$555,$545,$445,$335,$424,$324,$513,$223,$402,$312,$212,$000,$240

caltrop4Pal
	dc.w	$777,$754,$643,$542,$532,$432,$322,$411,$311,$500,$210,$400,$300,$200,$000,$240


cubeHeartFade
	REPT 9
	dc.w	$777,$777,$777,$777,$510,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$400
	ENDR

cubeHeartFade2
	IFEQ	OUTTRO_CINEMASCOPE
		dc.w	$111,$111,$111,$111,$400,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$510
		dc.w	$111,$111,$111,$111,$400,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$510
		dc.w	$111,$111,$111,$111,$400,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$510
	ELSE
		dc.w	$000,$000,$000,$000,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$510
		dc.w	$000,$000,$000,$000,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$510
		dc.w	$000,$000,$000,$000,$400,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$510
	ENDC
	dc.w	$111,$111,$111,$111,$400,$111,$111,$111,$111,$111,$111,$111,$111,$111,$111,$510
	dc.w	$222,$222,$222,$222,$510,$222,$222,$222,$222,$222,$222,$222,$222,$222,$222,$510
	dc.w	$333,$333,$333,$333,$610,$333,$333,$333,$333,$333,$333,$333,$333,$333,$333,$510
	dc.w	$444,$444,$444,$444,$721,$444,$444,$444,$444,$444,$444,$444,$444,$444,$444,$700
	dc.w	$555,$555,$555,$555,$720,$555,$555,$555,$555,$555,$555,$555,$555,$555,$555,$600
	dc.w	$666,$666,$666,$666,$610,$666,$666,$666,$666,$666,$666,$666,$666,$666,$666,$500
	dc.w	$777,$777,$777,$777,$510,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$400


cube1Pal
;	dc.w	$777,$442,$332,$552,$510,$220,$421,$321,$764,$653,$542,$320,$310,$210,$000,$400
;	dc.w	$777,$444,$333,$555,$222,$222,$333,$333,$777,$666,$444,$222,$222,$222,$000,$222 ; altpal grey
; 	dc.w 	$777,$344,$233,$455,$122,$122,$233,$233,$677,$566,$344,$122,$122,$122,$000,$122 ; greenblue
	dc.w 	$777,$432,$332,$443,$221,$221,$221,$221,$665,$554,$443,$221,$110,$110,$000,$110

cube2Pal
;	dc.w	$777,$442,$332,$552,$510,$220,$421,$321,$764,$653,$542,$320,$310,$210,$000,$400
;	dc.w	$777,$353,$243,$463,$421,$131,$332,$232,$675,$564,$453,$231,$220,$120,$000,$310 ; altpal
;   dc.w	$777,$444,$333,$555,$511,$222,$333,$333,$777,$666,$333,$222,$222,$222,$000,$400 ; altpal grey
;                                ***                           ***                      ***
;   dc.w 	$777,$345,$234,$456,$421,$123,$234,$234,$677,$567,$453,$123,$123,$123,$001,$400 ; metallic with red heart
	dc.w 	$777,$433,$333,$444,$421,$222,$222,$222,$666,$555,$444,$222,$111,$111,$001,$400
	

cube3Pal
;	dc.w	$777,$442,$332,$552,$510,$220,$421,$321,$764,$653,$542,$320,$310,$210,$000,$400
;	dc.w	$777,$344,$234,$454,$412,$122,$323,$223,$666,$555,$444,$222,$211,$111,$000,$301 ; altpal
	dc.w	$777,$444,$334,$554,$512,$222,$423,$323,$766,$655,$544,$322,$311,$211,$001,$401

cube4Pal
;	dc.w	$777,$442,$332,$552,$510,$220,$421,$321,$764,$653,$542,$320,$310,$210,$000,$400
;	dc.w	$777,$444,$334,$554,$512,$222,$423,$323,$766,$655,$544,$322,$311,$211,$001,$401 ; altpal
	dc.w	$777,$443,$333,$553,$511,$221,$422,$322,$765,$654,$543,$321,$310,$210,$000,$400 ; almost cube5pal 


cube5Pal
	dc.w	$777,$442,$332,$552,$510,$220,$421,$321,$764,$653,$542,$320,$310,$210,$000,$400



triangleFade		ds.b	32*9
squareFade			ds.b	32*9
cubeFade1			ds.b	32*9
cubeFade2			ds.b	32*9
cubeFade3			ds.b	32*9
cubeFade4			ds.b	32*9
cubeFade5			ds.b	32*9
caltrop1Fade		ds.b	32*9
caltrop2Fade		ds.b	32*9
caltrop3Fade		ds.b	32*9
caltrop4Fade		ds.b	32*9
torusFade			ds.b	32*9

;12*32*9

whiteFade
	REPT 9
		REPT 16
		dc.w	$777
		ENDR
	ENDR

putJustDoItRight
;	lea		justdoit_logo+128,a0
;	lea		justDoItBuffer,a0
	move.l	justDoItPointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.w	#96+160,a1
	add.w	#96+160,a2
	move.w	#199-1,d7
.cp
.x set 0
		REPT 8
			move.l	(a0)+,d0
			move.l	d0,(a1)+
			move.l	d0,(a2)+
			move.l	(a0)+,d0
			move.l	d0,(a1)+
			move.l	d0,(a2)+
.x set .x+8
		ENDR
	lea		96(a1),a1
	lea		96(a2),a2
	dbra	d7,.cp
	rts


putSMFXRight
;	lea		smfx_logo+128,a0
;	lea		smfxLogoBuffer,a0
	move.l	smfxPointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
;	add.w	#80+160,a0
	add.w	#120+160,a1
	add.w	#120+160,a2
	move.w	#199-1,d7
.cp
.x set 0
		REPT 4
			move.l	(a0)+,d0
			move.l	d0,(a1)+
			move.l	d0,(a2)+
			move.l	(a0)+,d0
			move.l	d0,(a1)+
			move.l	d0,(a2)+
.x set .x+8
		ENDR
	lea		128(a1),a1
	lea		128(a2),a2
	dbra	d7,.cp

	rts

putMotusRight
;	lea		motus_logo+128,a0
;	lea		motusLogoBuffer,a0
	move.l	motusPointer,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.w	#14*8+160,a1
	add.w	#14*8+160,a2
	move.w	#199-1,d7
.cp
.x set 0
		REPT 5
			move.l	(a0)+,d0
			move.l	d0,(a1)+
			move.l	d0,(a2)+
			move.l	(a0)+,d0
			move.l	d0,(a1)+
			move.l	d0,(a2)+
.x set .x+8
		ENDR
	lea		120(a1),a1
	lea		120(a2),a2
	dbra	d7,.cp

	rts

clearRightWrap
	move.w	#-1,polyTransOn
clearRight
;	moveq	#0,d0
;	move.w	vblcount,d0
;	move.b	#0,$ffffc123
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.w	#80,a1
	add.w	#80,a2
	move.w	#200-1,d7
	moveq	#0,d0
.cl
.x set 0
	REPT 10
		move.l	d0,.x(a1)
		move.l	d0,.x+4(a1)
		move.l	d0,.x(a2)
		move.l	d0,.x+4(a2)
.x set .x+8
	ENDR
	lea		160(a1),a1
	lea		160(a2),a2
	dbra	d7,.cl
	rts

polyTransOn	dc.w	0
setObject
	lea		polygonObjectList,a0
	add.w	polygonObjectListOff,a0
	move.w	(a0)+,envmap_toggle
	move.w	(a0)+,objectSwitchTimer
	move.w	(a0)+,mainloopsmc+2
	movem.w	(a0)+,d0-d2
	movem.w	d0-d2,_currentStepX_polygon
	movem.w	(a0)+,d0-d2
	move.w	d0,rot_smc1x+2
	move.w	d0,rot_smc2x+2
	move.w	d1,rot_smc1y+2
	move.w	d1,rot_smc2y+2
	move.w	d2,rot_smc1z+2
	move.w	d2,rot_smc2z+2
	IFEQ	TEXTEST
		move.w	#32000,objectSwitchTimer
	ENDC
	move.l	(a0)+,a1
	move.l	(a0)+,a2
	move.l	(a0)+,currentFadePalPointer
	move.l	(a2),current_texturePointer
	add.w	#pOLSize,polygonObjectListOff
	cmp.w	#pOLSize*pOLItems,polygonObjectListOff
	bne		.ok
		move.w	#0,polygonObjectListOff
.ok
	jsr		(a1)
	move.w	#5,polygonFadePalInWaiter
	move.w	objectSwitchTimer,d0
	sub.w	#30,d0
	move.w	d0,polygonFadePalOutWaiter
	rts




polygons_mainloop
	move.w	#0,$466.w
mainloopsmc
		cmp.w	#2,$466.w
		blt		mainloopsmc
;		cmp.w	#4,$466.w
;		bne		.ll
;			move.b	#0,$ffffc123
;.ll		


		move.w	#0,$466.w
		tst.w	polyTransOn
		bne		.skippidy


		tst.w	effect_vbl_counter
		blt		.end
		addq.w	#1,effectcount
		tst.w	switchObject
		beq		.ttt
			move.w	#0,switchObject
			jsr		setObject
.ttt

		tst.w	envmap_toggle
		bne		.doNormal
.doEnvmap
		jsr		doConcaveEnvmap
		jmp		.mapdone
.doNormal
		jsr		doConcave
.mapdone

.done

		jsr		c2p_2to4_optimized_polygon

		move.l	screenpointer2,$ffff8200

		move.l	screenpointer2,d0
		move.l	screenpointer,screenpointer2
		move.l	d0,screenpointer
.skippidy
	jmp		mainloopsmc
;	cmp.b 	#$39,$fffffc02.w								; spacebar to exit
;	bne		mainloopsmc									;
.end
	rts
.waiter		dc.w	0






doConvex
		jsr		clearCanvas_polygon_opt
		jsr		calculateRotatedProjection_polygon
		move.w	current_number_of_faces,d7
		subq.w	#1,d7

		move.w	#75,yTopp
		move.w	#0,yBotp

		move.l	currentDestFacesPointer,a6
.doFace
		subq.w	#1,(a6)+
		blt		.notvis
			move.l	a6,a0
			pusha6
			pushd7
				jsr		drawTrianglePoly
			popd7
			popa6
.notvis	
		lea		12(a6),a6
		dbra	d7,.doFace

		rts

envmap_toggle	dc.w	0

doConcaveEnvmap

		jsr		clearCanvas_polygon_opt
		jsr		calculateRotatedProjection_polygonEnvmap
		jsr		sortFaces
		jsr		doQuickSort

		move.w	#75,yTopp
		move.w	#0,yBotp

	move.w	nr_faces_to_draw,d7
	blt		.nofaces
;	lea		localList,a6
	move.l	localListPointer,a6
.doFace
		move.w	(a6)+,a0	
		move.l	(a6)+,a0
			pusha6
			pushd7
				jsr		drawTriangleEnvmap
			popd7
			popa6
.cont
		dbra	d7,.doFace
.nofaces

		rts
.uv1		dc.l	0
.uv2		dc.l	0
.uv3		dc.l	0



doConcave
		jsr		clearCanvas_polygon_opt
		jsr		calculateRotatedProjection_polygon
		jsr		sortFaces
		jsr		doQuickSort

		move.w	#75,yTopp
		move.w	#0,yBotp

	move.w	nr_faces_to_draw,d7
	blt		.nofaces
;	lea		localList,a6
	move.l	localListPointer,a6
.doFace
		move.w	(a6)+,a0	
		move.l	(a6)+,a0
			IFEQ	SEP_UV
			movem.l	12(a0),d0-d2
			ENDC
			movem.l	d0-d2/d7/a6,-(a7)
				jsr		drawTrianglePoly
			IFEQ	SEP_UV
			movem.l	(a7)+,d0-d2/d7/a6
			move.l	-4(a6),a0
			movem.l	d0-d2,12(a0)
			ENDC
.cont
		dbra	d7,.doFace
.nofaces
		rts
.uv1		dc.l	0
.uv2		dc.l	0
.uv3		dc.l	0


polygon_vbl
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	addq.w	#1,vblcount
	subq.w	#1,effect_vbl_counter


		;Start up Timer B each VBL
		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt

	sub.w	#1,objectSwitchTimer
	bne		.kkzx
		move.w	#-1,switchObject
.kkzx
	pushall

		move.l	currentFadePalPointer,a0
		add.w	polygonFadePalOff,a0
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240
		move.w	#0,$ffff8240
		swap	d0
		move.w	d0,timer_b_open_curtain_stable_col+2

		subq.w	#1,polygonFadePalInWaiter
		bge		.skip1
			move.w	#3,polygonFadePalInWaiter
			sub.w	#32,polygonFadePalOff
			bge		.skip1
				move.w	#0,polygonFadePalOff
				move.w	#32000,polygonFadePalInWaiter
				move.l	currentFadePalPointer,d0
				cmp.l	#cubeFade5,d0
				bne		.skip1
					jsr		patchCubePalette
.skip1
		subq.w	#1,polygonFadePalOutWaiter
		bge		.skip2
			move.w	#3,polygonFadePalOutWaiter
			add.w	#32,polygonFadePalOff
			cmp.w	#32*8,polygonFadePalOff
			blt		.skip2
				move.w	#32*8,polygonFadePalOff
				move.w	#32000,polygonFadePalOutWaiter
.skip2

	IFEQ	STANDALONE
		IFEQ	TEXTEST
	    cmp.w	#1000,vblcount
	    bne		.kk
	    	moveq	#0,d0
	    	moveq	#0,d1
	    	move.w	vblcount,d0
	    	move.w	effectcount,d1
		    	move.b	#0,$ffffc123
.kk
		ENDC
	ENDC

	IFNE	STANDALONE
		jsr		replayMymDump
	ENDC
	popall
	rte
.doIt	dc.w	2

patchCubePalette
	move.w	#$510,d0
	move.w	#$400,d1
	lea		cubeFade5,a0
.x set 8
	rept 9
		move.w	d0,.x(a0)
		move.w	d1,.x+22(a0)
.x set .x+32
	endr
	rts

polygonFadePalInWaiter	dc.w	5
polygonFadePalOutWaiter	dc.w	32000
polygonFadePalOff		dc.w	7*32
		IFEQ	TEXTEST

objectSwitchTimer	dc.w	32000
		ELSE
objectSwitchTimer	dc.w	500
		ENDC

switchObject	dc.w	0

	IFEQ	STANDALONE
timer_b_open_curtain
	move.w	#$777,$ffff8240
	move.b	#0,$fffffa1b.w			;Timer B control (stop)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l	#timer_b_close_curtain,$120.w
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	rte

timer_b_close_curtain
	move.w	#$0,$ffff8240
	rte


timer_b_open_curtain_stable
		movem.l	d1-d2/a0,-(sp)
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		dcb.w	59-6,$4e71
timer_b_open_curtain_stable_col
		move.w	#$777,$ffff8240.w


		movem.l	(sp)+,d1-d2/a0
		move.l	#timer_b_close_curtain_stable,$120.w
		move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte

timer_b_close_curtain_stable:	
		move.w	#$2700,sr
		movem.l	d0/a0,-(sp)

		moveq	#96,d0				;Hardsync with branch offset
		lea	$ffff8209.w,a0
.sync:		cmp.b	(a0),d0
		beq.s	.sync
		move.b	(a0),d0
		move.w	d0,.jump+2			;SMC bra.w below
.jump:		bra.w	timer_b_open_curtain_stable

.wait:		dcb.w	134,$4e71 

		move.w	#$000,$ffff8240.w

		movem.l	(sp)+,d0/a0
		rte

	ENDC



planarToChunky_text_polygon_torus
;	lea		text1+128,a0
;	move.l	texturepointer_polygon,a1
	move.l	a0,a6

	move.l	a1,a2
	sub.w	#$2000,a2
	move.w	#4096/4/4/4/4*2-1,d7
	move.l	#$06060606,d0
.ddd
	REPT 64
		move.l	d0,(a2)+
	ENDR
	dbra	d7,.ddd


	move.l	#128-1,d6

	move.l	a0,a3
.height
	move.l	#16/2-1,d7
.width
	movem.w	(a0)+,d0-d3		; 4 words
	REPT 16
		moveq	#0,d4
		moveq	#0,d5
		roxl.w	d5
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4
		lsl.w	#3,d4
		addq.w	#6,d4
		move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
	ENDR
	movem.w	(a3)+,d0-d3
	REPT 16
		moveq	#0,d4
		moveq	#0,d5
		roxl.w	d5
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4
		lsl.w	#3,d4
		addq.w	#6,d4
		move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
	ENDR
	dbra	d7,.width



	; 320 width is 160 bytes
	; 128 width is 64 bytes 
	; 160-64 added
	add.w	#160-64,a0
	add.w	#160-64,a3
	dbra	d6,.height						; 128 * ( 32*4 + 8*16 ) = 128 * (128+128) = 32768

	tst.w	.cont
	bne		.end
		move.w	#-1,.cont
		move.w	#128-1,d6
;		lea		text2+128,a0
		move.l	a6,a0
		move.l	a0,a3
		jmp		.height

.end
;	move.l	#$06060606,d0
;	move.w	#100-1,d7
;.xxx
;	REPT 32
;;		move.l	d0,(a1)+
;	ENDR
;	dbra	d7,.xxx


	rts
.cont	dc.w	0


planarToChunky_text_polygon_cube
;	lea		cubeText+128,a0
;	move.l	texturepointer_polygon,a1
	move.l	a0,a6

	move.l	a1,a2
	sub.w	#$2000,a2
	move.w	#4096/4/4/4/4*2-1,d7
	move.l	#$06060606,d0
.ddd
	REPT 64
		move.l	d0,(a2)+
	ENDR
	dbra	d7,.ddd


;	move.l	#200-1,d6

.height
	move.l	#16-1,d7
.width
	movem.w	(a0)+,d0-d3		; 4 words
	REPT 16
		moveq	#0,d4
		moveq	#0,d5
		roxl.w	d5
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4
		lsl.w	#3,d4
		addq.w	#6,d4
		move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
	ENDR
	dbra	d7,.width



	; 320 width is 160 bytes
	; 128 width is 64 bytes 
	; 160-64 added
	add.w	#160-128,a0
	dbra	d6,.height						; 128 * ( 32*4 + 8*16 ) = 128 * (128+128) = 32768

	tst.w	.cont
	bne		.end
		move.w	#-1,.cont
		move.w	#56-1,d6
		move.l	a6,a0
		jmp		.height

.end
;	move.l	#$06060606,d0
;	move.w	#100-1,d7
;.xxx
;	REPT 32
;;		move.l	d0,(a1)+
;	ENDR
;	dbra	d7,.xxx


	rts
.cont	dc.w	0



canvaswidth_polygon	equ 128

clearCanvas_polygon
	move.l	#$06060606,d0
;	move.l	#$0e0e0e0e,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5

;	lea		canvas,a6
	move.l	canvasPointer_text_polygon,a6
	; 128 x 128 bytes	= 16384			;d0-a5 = 14*4 = 56 = 16352
.off set 0
	REPT 292
	movem.l	d0-a5,.off(a6)
.off set .off+14*4
	ENDR
	;32 left
	movem.l	d0-d7,.off(a6)

	REPT 50
	movem.l	d0-d7,-(a6)
	ENDR
	rts

	rts

clearCanvas_polygon_opt
	move.l	canvasPointer_text_polygon,a6
	move.w	yBotp,d7
	move.w	yTopp,d0
	sub.w	d0,d7
	asl.w	#7,d0
	add.w	d0,a6
	move.w	d7,d0



;	move.l	#$0e0e0e0e,d1
	move.l	#$06060606,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	move.l	d1,a0
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5				; 14*4 = 56

;	lea		canvas,a6
	; 128 x 128 bytes	= 16384			;d0-a5 = 14*4 = 56 = 16352 128 bytes per line


.x set 0
;	REPT 75
.xx
	movem.l	d1-a5,.x(a6)			;56
	movem.l	d1-a5,.x+52(a6)			;112
	lea		128(a6),a6
	dbra	d0,.xx
;.x set .x+128
;	ENDR

	rts





;void DrawTextureTriangle(vertex * vtx, char * bitmap)
;    vertex * v1 = vtx;
;    vertex * v2 = vtx+1;
;    vertex * v3 = vtx+2;
;	// sort stuff
;    if(v1->y > v2->y) { vertex * v = v1; v1 = v2; v2 = v; }
;    if(v1->y > v3->y) { vertex * v = v1; v1 = v3; v3 = v; }
;    if(v2->y > v3->y) { vertex * v = v2; v2 = v3; v3 = v; }
;    // We start out by calculating the length of the longest scanline.
;    int height = v3->y - v1->y;
;    int temp = ((v2->y - v1->y) << 16) / height;
;    int longest = temp * (v3->x - v1->x) + ((v1->x - v2->x) << 16);
;    if(longest == 0)
;        return;
;
;    // Now that we have the length of the longest scanline we can use that 
;    // to tell us which is left and which is the right side of the triangle.
;
;    if(longest < 0)
;    {
;        // If longest is neg. we have the middle vertex on the right side.
;        // Store the pointers for the right and left edge of the triangle.
;        right_array[0] = v3;
;        right_array[1] = v2;
;        right_array[2] = v1;
;        right_section  = 2;
;        left_array[0]  = v3;
;        left_array[1]  = v1;
;        left_section   = 1;
;
;        // Calculate initial left and right parameters
;        if(LeftSection() <= 0)
;            return;
;        if(RightSection() <= 0)
;        {
;            // The first right section had zero height. Use the next section. 
;            right_section--;
;            if(RightSection() <= 0)
;                return;
;        }
;
;        // Ugly compensation so that the dudx,dvdx divides won't overflow
;        // if the longest scanline is very short.
;        if(longest > -0x1000)
;            longest = -0x1000;     
;    }
;    else
;    {
;        // If longest is pos. we have the middle vertex on the left side.
;        // Store the pointers for the left and right edge of the triangle.
;        left_array[0]  = v3;
;        left_array[1]  = v2;
;        left_array[2]  = v1;
;        left_section   = 2;
;        right_array[0] = v3;
;        right_array[1] = v1;
;        right_section  = 1;
;
;        // Calculate initial right and left parameters
;        if(RightSection() <= 0)
;            return;
;        if(LeftSection() <= 0)
;        {
;            // The first left section had zero height. Use the next section.
;            left_section--;
;            if(LeftSection() <= 0)
;                return;
;        }
;
;        // Ugly compensation so that the dudx,dvdx divides won't overflow
;        // if the longest scanline is very short.
;        if(longest < 0x1000)
;            longest = 0x1000;     
;    }
;
;    // Now we calculate the constant deltas for u and v (dudx, dvdx)
;
;    int dudx = shl10idiv(temp*(v3->u - v1->u)+((v1->u - v2->u)<<16),longest);
;    int dvdx = shl10idiv(temp*(v3->v - v1->v)+((v1->v - v2->v)<<16),longest);
;
;    char * destptr = (char *) (v1->y * 320 + 0xa0000);
;
;    // If you are using a table lookup inner loop you should setup the
;    // lookup table here.
;
;    // Here starts the outer loop (for each scanline)
;
;    for(;;)         
;    {
;        int x1 = left_x >> 16;
;        int width = (right_x >> 16) - x1;
;
;        if(width > 0)
;        {
;            // This is the inner loop setup and the actual inner loop.
;            // If you keep everything else in C that's up to you but at 
;            // least remove this inner loop in C and insert some of 
;            // the Assembly versions.
;
;            char * dest = destptr + x1;
;            int u  = left_u >> 8;
;            int v  = left_v >> 8;
;            int du = dudx   >> 8;            
;            int dv = dvdx   >> 8;
;
;            // Watcom C/C++ 10.0 can't get this inner loop any tighter 
;            // than about 10-12 clock ticks.
;
;            do
;            {
;                *dest++ = bitmap[ (v & 0xff00) + ((u & 0xff00) >> 8) ];
;                u += du;
;                v += dv;
;            }
;            while(--width);
;        }
;
;        destptr += 320;
;
;        // Interpolate along the left edge of the triangle
;        if(--left_section_height <= 0)  // At the bottom of this section?
;        {
;            if(--left_section <= 0)     // All sections done?
;                return;
;            if(LeftSection() <= 0)      // Nope, do the last section
;                return;
;        }
;        else
;        {
;            left_x += delta_left_x;
;            left_u += delta_left_u;
;            left_v += delta_left_v;
;        }
;
;        // Interpolate along the right edge of the triangle
;        if(--right_section_height <= 0) // At the bottom of this section?
;        {
;            if(--right_section <= 0)    // All sections done?
;                return;
;            if(RightSection() <= 0)     // Nope, do the last section
;                return;
;        }
;        else
;        {
;            right_x += delta_right_x;
;        }
;    }
;}

;equal equ 0											;					   .	10,30
;right equ 0											;
													;
													;
													;  \				 /
													;	2...............1
													;	.				.
													;	.				.
													;	.				.
													;	4...............3
													;  /				 \
; face normals	->


; fn(p1,p2,p3)
;	fx,fy,fz,p1*,p2*,p3*





; we have nonProjected and projected
; nonProjected:
;	face -> nonProjectedFaceNormal, nonProjectedVertex1,nonProjectedVertex2,nonProjectedVertex3
;
;	x	ds.w
;	y	ds.w
;	z	ds.w
;	v1	ds.l
;	v2	ds.l
;	v3	ds.l
;


;	projectedFace -> visibility, projectedVertex1, projectedVertex2, projectedVertex3

; nonProjectedVertex -> visibility,x,y,z
; projectedVertex -> x,y,u,v

; for rotation:
;	cull First
; a. create rotation matrix
; b. inverse rotation matrix for the face normals
; c. foreach facenormal
;	
;





yTopp	dc.w	0
yBotp	dc.w	75

yTopp2	dc.w	0
yBotp2	dc.w	75



;testtimes	dc.w	400
; optimization 1:	divs/muls gone
; optimization 2: 	innerloop construction smc using addx
; optimization 3:	order of registers, and using them smart
drawTriangleEnvmap
	move.l	current_texturePointer,d6
;	move.l	texturepointer_polygon,d6
	move.l	divtablepointer_polygon,a5			;20
	move.l	a5,usp	
	movem.l	(a0)+,a1-a3					;36		;a1,a2,a3							; get points
	move.l	a0,-(sp)
;;;;;;;;;;; sort points 	; determine order
	move.w	2(a2),d0					;12
	cmp.w	2(a1),d0					;12
	bge		.point1_lt_point2			;8
		exg		a1,a2					;8		*3
.point1_lt_point2
	move.w	2(a3),d0					
	cmp.w	2(a1),d0					
	bge		.point1_lt_point3
		exg		a1,a3
.point1_lt_point3
	move.w	2(a3),d0
	cmp.w	2(a2),d0
	bge		.point2_lt_point3
		exg		a2,a3
.point2_lt_point3
;;;;;;;;;;; done sorting
;;;;;;;;;;; determine max span
	; points sorted, top to bottom a1,a2,a3	
;------------------------------------------------------- determine y segments 
	move.w	2(a3),d5					;12		y3									move.w	(a3)+,d5		-4			;$39
	cmp.w	yBotp,d5
	ble		.noNewBot
		move.w	d5,yBotp
.noNewBot
	move.w	d5,d7						;4		
	move.w	2(a1),d4					;12		y1									move.w	(a1)+,d4		-4			;$06
	cmp.w	yTopp,d4
	bge		.noNewTop
		move.w	d4,yTopp
.noNewTop
	sub.w	d4,d7						;4		y3-y1																	;$33
	beq		.end						;		if 0, then quit
	move.w	d7,.y1_y3					;		save
	move.w	2(a2),d2					;12		y2									move.w	(a2)+,d2		-4			;$06
	move.w	d2,d3						;4		
	sub.w	d4,d2						;4		y2-y1
	move.w	d2,.y1_y2					;		save
	sub.w	d3,d5						;4		y3-y2
	move.w	d5,.y2_y3					;		save																	;$33
;------------------------------------------------------- determine max x span
	move.l	usp,a5

	ext.l	d2							;4
	asl.l	#7,d2						;20		
	or.w	d7,d2						;4
	add.l	d2,d2						;4
	add.l	d2,d2						;4
	move.l	(a5,d2.l),d2				;20											
	asr.l	#8,d2						;24	=> 80		y2-y1 / y3-y1													;0

	move.w	(a1),d0						;8		x1									move.w	(a1)+,d0		0			;$17 = 23
	move.w	(a3),d7						;8		x3									move.w	(a3)+.d7		0			;$68
	sub.w	d0,d7						;4		x3-x1																	;$51

	muls	d2,d7						;56		(x3-x1) * (y2-y1)/(y3-y1)
	asr.l	#8,d7						;24

	add.w	d0,d7						;4		(x3-x1) * (y2-y1)/(y3-y1) + x1
	sub.w	(a2),d7						;8		max span	((x3-x1) * (y2-y1)/(y3-y1)) + x1 - x2		sub.w	(a2)+,d7
	bne		.nozeromaxwidth
		move.w	#1,d7
.nozeromaxwidth
;------------------------------------------------------- determine uv stepping
	move.w	4(a1),d1					;12		u1									move.w	(a1)+,d1		-4
	move.w	4(a3),d0					;12		u3									move.w	(a3)+,d0		-4
	sub.w	d1,d0						;4		u3-u1
	add.w	d0,d0						;4
	muls	d2,d0						;56		((u3-u1) * (y2-y1)/(y3-y1)) 

	sub.w	4(a2),d1					;12		u1-u2								move.w	(a2)+,d1		-4
	asr.w	#7,d1						;20
	swap	d1							;4
	sub.w	d1,d1						;4

	add.l	d1,d0						;8		((u3-u1) * (y2-y1)/(y3-y1)) + (u1-u2)

	lea		divTablePivot_polygon,a4			;8
	add.w	d7,d7						;4
	move.w	(a4,d7.w),d6				;20		1/width
	swap	d0							;4
	muls	d6,d0						;56		8   ( (u3-u1) * (y2-y1)/(y3-y1)) + (u1-u2) / width

	move.w	6(a1),d4					;12		v1									move.w	(a1),d4			-4	
	move.w	6(a3),d1					;12		v3									move.w	(a3),d1			-4
	sub.w	d4,d1						;4		v3-v1
	add.w	d1,d1						;4		
	muls	d2,d1						;56		(v3-v1) * (y2-y1)/(y3-y1)

	sub.w	6(a2),d4					;12		v1-v2								sub.w	(a2),d4			-4
	asr.w	#7,d4						;20	

	swap	d1							;4
	add.w	d4,d1						;4		(((v3-v1) * (y2-y1)/(y3-y1)) + (v1-v2)) / width

	muls	d6,d1						;56
	asr.l	#7,d1						;20
;--------------------------------------------------------- smc unrolled innerloop code with stepping offsets
		add.l	d0,d0					;8		to correct from the <<7 from the 1/x muls
		swap	d0						;
		sub.w	d5,d5

	move.l	d0,d2		; local du
	move.l	d1,d3		; local dv
	moveq	#0,d4

smcLoopSize_tt	equ -14

	move.w	d7,d6
	bge		.noneg
		neg.w	d6
.noneg
;	muls	#smcLoopSize_t,d6
	move.w	d6,a6	
	asl.w	#3,d6
		sub.w	a6,d6
	neg.w	d6
.kkk
	lea		.doSMCLoopEnd+4*smcLoopSize_tt,a6	; 2 more than needed, because this way we prevent reading outside the texture, hax...
	lea		textMapp+2+127*4,a4				; first load the end of the canvas table
	sub.w	2(a6,d6.w),a4					; then we rectify the table offset
	jmp		(a6,d6.w)						; and we need to load the proper address to a4, combined with the offset of the width span
.y1_y3		dc.w	0
.y1_y2		dc.w	0
.y2_y3		dc.w	0


.doSMCLoop
.offset set 0								; offset into the unrolled loop of 		move.b textoff(a0),-(a1)
	REPT 128
			move.w	d4,.offset(a4)			;12
			move.w	d3,d4					;4			; 0.16 -> 0. 8.8 dv.du	
			move.b	d2,d4					;4			; 0.16 -> 0. 8.8 
			add.l	d0,d2		;8....8		;8
			addx.b	d5,d2					;4
			add.w	d1,d3		;... 8.8	;4
.offset set .offset-4						
	ENDR
.doSMCLoopEnd
;--------------------------------------------------------- time to draw triangles
;	lea		canvas,a6						;8 		load canvas
	move.l	canvasPointer_text_polygon,a6
	move.w	2(a1),d0						;8		get top y							move.w	-6(a1),d0
	asl.w	#7,d0							;18		canvas *128
	add.w	d0,a6							;8		add y offset to canvas
	tst.w	d7								;4		d7 is still span, but negative and positive determine where the 2nd point is
	blt		.middleRight
.middleLeft
	move.w	.y1_y2,d0		; y1_y2
	beq		.two_top_left		; if 0 ==> then p1 and p2 top
.first_slice_p1_p2_middle_left
		move.l	a2,-(sp)					;16		save a2
		move.l	a3,-(sp)					;16		save a3
		move.w	(a1),d1						;8		startx								move.w	-6(a1),d1			+4
		move.w	(a3),d7						;8 		x3									move.w	-6(a3),d7			+4

		move.w	4(a1),d5					;12		u1 global							move.w	-2(a1),d5			0
		move.w	4(a2),d2					;12		u2 									move.w	-2(a2),d2			0
		sub.w	d5,d2						;4		u2-u1
		ext.l	d2
		or.w	d0,d2						;4						
		add.w	d2,d2						;4
		add.w	d2,d2						;4		
		move.l	(a5,d2.l),a3				;20		a3 = du/dy	u2-u1 / y2-y1

		move.w	6(a1),d4					;12		v1 global							move.w	(a1),d4				-4
		move.w	6(a2),d2					;12		v2									move.w	(a2),d2				-4
		sub.w	d4,d2						;4		v2-v1
		ext.l	d2
		or.w	d0,d2						;4
		add.w	d2,d2						;4
		add.w	d2,d2						;4
		move.l	(a5,d2.l),d2				;20		v2-v1 / y2-y1
		asr.l	#8,d2						;24		>>8
		move.w	d2,a4						;4		a4 = dv/dy	

		asr.w	#7,d5						;20		>>7
		swap	d5							;4
		sub.w	d5,d5						;4		u1 global 16.16 format

		move.w	(a2),d3						;8		x2									move.w	-6(a2),d4			+4
		sub.w	d1,d3						;4 		x2-x1
		ext.l	d3
		asl.l	#7,d3						;20		>>7
		or.w	d0,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a5,d3.l),a1				;20		a1 = dx/dy left	x2-x1 / y2-y1 

		sub.w	d1,d7						;4		x3-x1
		ext.l	d7
		asl.l	#7,d7						;20		>> 7
		or.w	.y1_y3(pc),d7				;16		
		add.l	d7,d7						;4
		add.l	d7,d7						;4
		move.l	(a5,d7.l),a5				;20		a5 = dx/dy right x3-x1 / y3-y1

		add.w	d4,d4						;4
		swap	d1							;4
		sub.w	d1,d1						;4
		move.l	d1,d2						;4

		subq.w	#1,d0						;4			94 nop

		jsr		drawHLine_polygon
		; d0, loopvar					
		; d1, x_start
		; d2, x_end
		; d3, x_end LOCAL
		; d4, dv_global
		; d5, du_global
		; d6, texture_aligned_pointer
		; d7, addx
		; a0, texture
		; a1, dx_left
		; a2, --
		; a3, du/dy
		; a4, dv/dy
		; a5, dx_right
		; a6, canvas
		move.l	(sp)+,a3					;12
		move.l	(sp)+,a2					;12
.second_slice_p2_p3_middle_left
; p3.y - p2.y
		move.w	.y2_y3,d0					;12		y3-y2				height
		move.l	usp,a4
; sx
		move.w	(a2),d1						;8		x2 set x_start							move.w	-6(a2),d1			+4	
		move.w	(a3),d3						;8		x3										move.w	-6(a3),d3			+4
		sub.w	d1,d3						;4		x3-x2
		ext.l	d3
		asl.l	#7,d3						;20
		or.w	d0,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a4,d3.l),a1				;20		a1 = x3-x2 / y3-y2
; dv global
		move.w	6(a2),d4					;12		v2										move.w	(a2),d4				-4
		move.w	6(a3),d3					;12		v3										move.w	(a3),d3				-4
		sub.w	d4,d3						;4		v3-v2
		ext.l	d3
		or.w	d0,d3						;4
		add.w	d3,d3						;4
		add.w	d3,d3						;4
		move.l	(a4,d3.l),d3				;20		v3-v2  / y3-y2
		asr.l	#8,d3						;24
;; du/dy
		move.w	4(a2),d5					;12		u2										move.w	-2(a2),d5			0
		move.w	4(a3),d7					;12		u3										move.w	-2(a3),d7			0
		sub.w	d5,d7 						;4		u3-u2
		ext.l	d7
		or.w	d0,d7						;4
		add.w	d7,d7						;4
		add.w	d7,d7						;4
		move.l	(a4,d7.l),a3				;20		a3 = u3-u2 / y3-y2

		asr.w	#7,d5						;20
		swap	d5							;4
		sub.w	d5,d5						;4

		move.w	d3,a4						;4		a4 = v3-v2 / y3-y2

		swap	d1							;4
		sub.w	d1,d1						;4
		add.w	d4,d4						;4

		jsr		drawHLine_polygon
		; d0, loopvar					
		; d1, x_start
		; d2, x_end
		; d3, x_end LOCAL
		; d4, dv_global
		; d5, du_global
		; d6, texture_aligned_pointer
		; d7, addx
		; a0, texture
		; a1, dx_left
		; a2, --
		; a3, du/dy
		; a4, dv/dy
		; a5, dx_right
		; a6, canvas
		move.l	(sp)+,a0					;12
		rts
.two_top_left
; 2 ---------- 1
;   \        /
;    \.     / 
;     \.   /
;      \. /
;       \/
;       3
	move.w	(a2),d1							;8		x2 startx
	move.w	(a1),d2							;8		x1 endx

	move.w	(a3),d3							;8		x3 xleft
	move.w	d3,d7							;4		x3 xright

	move.w	.y2_y3,d0						;16		y3-y2. height

	sub.w	d1,d3							;4		x3-x1
	ext.l	d3
	asl.l	#7,d3							;20
	or.w	d0,d3							;4
	add.l	d3,d3							;4
	add.l	d3,d3							;4
	move.l	(a5,d3.l),a1					;20		a1 = x3-x1 / y3-y2 dx/dy left

	sub.w	d2,d7							;4
	ext.l	d7
	asl.l	#7,d7							;20
	or.w	d0,d7							;4
	add.l	d7,d7							;4
	add.l	d7,d7							;4

	move.w	6(a2),d4						;12		v2
	move.w	6(a3),d3						;12		v3
	sub.w	d4,d3							;4		v3-v2
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4
	move.l	(a5,d3.l),d3					;20		v3-v2 / y3-y2
	asr.l	#8,d3							;24 		<< 8
	move.l	d3,a4							;4		a4 = dv/dy

	move.w	4(a2),d5						;12		u2
	move.w	4(a3),d3						;12		u3
	sub.w	d5,d3							;4		u3-u2
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4
	move.l	(a5,d3.l),a3					;20		a3 = u3-u2 / y3-y2

	add.w	d4,d4							;4
	asr.w	#7,d5							;20	
	swap	d5								;4
	sub.w	d5,d5							;4
	move.l	(a5,d7.l),a5					;20		a5 = dx/dy right

	subq.w	#1,d0							;4
	swap	d1								;4
	swap	d2								;4
	sub.w	d1,d1							;4
	sub.w	d2,d2							;4

	jsr		drawHLine_polygon
	move.l	(sp)+,a0	
	; d0, loopvar					
	; d1, x_start
	; d2, x_end
	; d3, x_end LOCAL
	; d4, dv_global
	; d5, du_global
	; d6, texture_aligned_pointer
	; d7, addx
	; a0, texture
	; a1, dx_left
	; a2, --
	; a3, du/dy
	; a4, dv/dy
	; a5, dx_right
	; a6, screen	move.l	(sp)+,a0
	rts
.middleRight
	move.w	.y1_y2,d0						;16		y1_y2
	beq		.two_top_right					; if 0 ==> then p1 and p2 top
		move.l	a2,-(sp)					;16		save a2
		move.l	a3,-(sp)					;16		save a3

		move.w	.y1_y3,d7					;16		height y1_y3												;15
		move.w	(a1),d1						;8		x1, startx
		move.w	(a3),d3						;8		x3

		move.w	6(a1),d4					;12		v1
		move.w	6(a3),d2					;12		v3 p3.v
		sub.w	d4,d2						;4		v3-v1
		ext.l	d2
		or.w	d7,d2						;4
		add.w	d2,d2						;4
		add.w	d2,d2						;4
		move.l	(a5,d2.l),d2				;20		v3-v1 / y3-y1
		asr.l	#8,d2						;24
		move.w	d2,a4						;4
; du/dy
		move.w	4(a1),d5					;12		u1
		move.w	4(a3),d2					;12		u3
		sub.w	d5,d2						;4		u3-u1
		ext.l	d2
		or.w	d7,d2						;4
		add.w	d2,d2						;4
		add.w	d2,d2						;4
		move.l	(a5,d2.l),a3				;20		a3 = u3-u1 / y3-y1

		asr.w	#7,d5						;20
		swap	d5							;4
		sub.w	d5,d5						;4
;	d3 = dx_left / dy
		sub.w	d1,d3						;4		x3-x1
		ext.l	d3
		asl.l	#7,d3						;20
		or.w	d7,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a5,d3.l),a1				;20		a1 = x3-x1 / y3-y1

		move.w	(a2),d2						;8		x2
		sub.w	d1,d2						;4		x2-x1
		ext.l	d2
		asl.l	#7,d2						;20
		or.w	d0,d2						;4
		add.l	d2,d2						;4
		add.l	d2,d2						;4
		move.l	(a5,d2.l),a5				;20		a5 = x2-x1 / y2-y1

		add.w	d4,d4						;4
		subq.w	#1,d0						;4
		swap	d1							;4	
		sub.w	d1,d1						;4
		move.l	d1,d2						;4

		jsr		drawHLine_polygon
		; d0, loopvar					
		; d1, x_start
		; d2, x_end
		; d3, x_end LOCAL
		; d4, dv_global
		; d5, du_global
		; d6, texture_aligned_pointer
		; d7, addx
		; a0, texture
		; a1, dx_left
		; a2, --
		; a3, du/dy
		; a4, dv/dy
		; a5, dx_right
		; a6, screen		
		move.l	a3,d7						;4 		save a3
		move.l	(sp)+,a3					;12
		move.l	(sp)+,a2					;12
.middleRight_sliceTwo		
		move.w	(a2),d2						;8		x2	
		move.w	(a3),d3						;8		x3

		move.l	usp,a5

		move.w	.y2_y3,d0					;16		y3-y2
		sub.w	d2,d3						;4		x3-x2 determine new right dx x3-x2
		ext.l	d3
		asl.l	#7,d3						;20
		or.w	d0,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a5,d3.l),a5				;20		a5 = dx/dy right

		swap	d2							;4
		sub.w	d2,d2						;4
		move.l	d7,a3						;4		restore a3
		jsr		drawHLine_polygon
.end
		move.l	(sp)+,a0
	rts
.two_top_right
	move.w	(a1),d1							;8		x1	startx left
	move.w	(a2),d2							;8		x2	endx right
	move.w	(a3),d6							;8		x3	
	move.w	d6,d7							;8		save

	move.w	.y1_y3,d0						;16		y3-y1
	sub.w	d1,d6							;4		x3-x1

	asl.w	#7,d6							;20
	or.w	d0,d6							;4
;	add.l	d6,d6							;4
;	add.l	d6,d6							;4

	sub.w	d2,d7							;4		x3-x2
	ext.l	d7
	asl.l	#7,d7							;20
	or.w	d0,d7							;4
	add.l	d7,d7							;4
	add.l	d7,d7							;4

	move.w	6(a1),d4						;12 	v1



	move.w	6(a3),d3						;12		v3
	sub.w	d4,d3							;4		v3-v1
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4
	move.l	(a5,d3.l),d3					;20
	asr.l	#8,d3							;24
	move.l	d3,a4							;4		a4 = dv/dy

	add.w	d4,d4							;4

	move.w	4(a1),d5						;12		u1
	move.w	4(a3),d3						;12		u3
	sub.w	d5,d3							;4		u3-u1
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4	
	move.l	(a5,d3.l),a3					;20		a3 = du/dy

	asr.w	#7,d5							;20
	swap	d5								;4
	sub.w	d5,d5		

	move.w	d6,a1
	add.l	a1,a1
	add.l	a1,a1

						;4
	move.l	(a5,a1.l),a1					;20		a1 = dx/dy	left
	move.l	(a5,d7.l),a5					;20		a5 = dx/dy	right

	subq.w	#1,d0							;4
	swap	d1								;4
	swap	d2								;4
	sub.w	d1,d1							;4
	sub.w	d2,d2							;4

	jsr		drawHLine_polygon
	move.l	(sp)+,a0
	; d0, loopvar					
	; d1, x_start
	; d2, x_end
	; d3, x_end LOCAL
	; d4, dv_global
	; d5, du_global
	; d6, texture_aligned_pointer
	; d7, addx
	; a0, texture
	; a1, dx_left
	; a2, --
	; a3, du/dy
	; a4, dv/dy
	; a5, dx_right
	; a6, screen	
	rts


;testtimes	dc.w	400
; optimization 1:	divs/muls gone
; optimization 2: 	innerloop construction smc using addx
; optimization 3:	order of registers, and using them smart

u1		equ 0
v1		equ 2
u2		equ 4
v2		equ 6
u3		equ 8
v3		equ 10

drawTrianglePoly
;	move.l	texturepointer_polygon,d6
	move.l	current_texturePointer,d6
	move.l	divtablepointer_polygon,a5			;20
	move.l	a5,usp	
	IFEQ	SEP_UV
		movem.l	(a0)+,a1-a3
		move.l	a0,a5
	ELSE
		movem.l	(a0)+,a1-a3					;36		;a1,a2,a3							; get points
	ENDC
;;;;;;;;;;; sort points 	; determine order
	move.w	2(a2),d0					;12
	cmp.w	2(a1),d0					;12
	bge		.point1_lt_point2			;8
		exg		a1,a2					;8		*3	; so swap 1 and 2
		IFEQ	SEP_UV
			move.l	(a5),d5			;1			16
			move.l	4(a5),(a5)		;2->1		24
			move.l	d5,4(a5)		;1->2		16
		ENDC
.point1_lt_point2
	move.w	2(a3),d0					
	cmp.w	2(a1),d0					
	bge		.point1_lt_point3
		exg		a1,a3
		IFEQ	SEP_UV
			move.l	(a5),d5			;1
			move.l	8(a5),(a5)		;3->1
			move.l	d5,8(a5)		;1->3
		ENDC
.point1_lt_point3
	move.w	2(a3),d0
	cmp.w	2(a2),d0
	bge		.point2_lt_point3
		exg		a2,a3
		IFEQ	SEP_UV
			move.l	4(a5),d5		;2
			move.l	8(a5),4(a5)		;3->2
			move.l	d5,8(a5)		;2->3
		ENDC
.point2_lt_point3
;;;;;;;;;;; done sorting
;dt_determineSpanp
;;;;;;;;;;; determine max span
	; points sorted, top to bottom a1,a2,a3	
;------------------------------------------------------- determine y segments 
	move.w	2(a3),d5					;12		y3									move.w	(a3)+,d5		-4			;$39
	cmp.w	yBotp,d5
	ble		.noNewBot
		move.w	d5,yBotp
.noNewBot
	move.w	d5,d7						;4		
	move.w	2(a1),d4					;12		y1									move.w	(a1)+,d4		-4			;$06
	cmp.w	yTopp,d4
	bge		.noNewTop
		move.w	d4,yTopp
.noNewTop
	sub.w	d4,d7						;4		y3-y1																	;$33
	beq		.end						;		if 0, then quit
	move.w	d7,.y1_y3					;		save
	move.w	2(a2),d2					;12		y2									move.w	(a2)+,d2		-4			;$06
	move.w	d2,d3						;4		
	sub.w	d4,d2						;4		y2-y1
	move.w	d2,.y1_y2					;		save
	sub.w	d3,d5						;4		y3-y2
	move.w	d5,.y2_y3					;		save																	;$33
;------------------------------------------------------- determine max x span
	move.l	usp,a0

	ext.l	d2							;4
	asl.l	#7,d2						;20		
	or.w	d7,d2						;4
	add.l	d2,d2						;4
	add.l	d2,d2						;4
	move.l	(a0,d2.l),d2				;20											
	asr.l	#8,d2						;24	=> 80		y2-y1 / y3-y1													;0

	move.w	(a1),d0						;8		x1									move.w	(a1)+,d0		0			;$17 = 23
	move.w	(a3),d7						;8		x3									move.w	(a3)+.d7		0			;$68
	sub.w	d0,d7						;4		x3-x1																	;$51

	muls	d2,d7						;56		(x3-x1) * (y2-y1)/(y3-y1)
	asr.l	#8,d7						;24

	add.w	d0,d7						;4		(x3-x1) * (y2-y1)/(y3-y1) + x1
	sub.w	(a2),d7						;8		max span	((x3-x1) * (y2-y1)/(y3-y1)) + x1 - x2		sub.w	(a2)+,d7
	bne		.nozeromaxwidth
		move.w	#1,d7
.nozeromaxwidth
;------------------------------------------------------- determine uv stepping
	IFEQ	SEP_UV
		move.w	u1(a5),d1
		move.w	u3(a5),d0
	ELSE
		move.w	6(a1),d1					;12		u1									move.w	(a1)+,d1		-4
		move.w	6(a3),d0					;12		u3									move.w	(a3)+,d0		-4
	ENDC
	sub.w	d1,d0						;4		u3-u1
	add.w	d0,d0						;4
	muls	d2,d0						;56		((u3-u1) * (y2-y1)/(y3-y1)) 

	IFEQ	SEP_UV
		sub.w	u2(a5),d1
	ELSE
		sub.w	6(a2),d1					;12		u1-u2								move.w	(a2)+,d1		-4
	ENDC
	asr.w	#7,d1						;20
	swap	d1							;4
	sub.w	d1,d1						;4

	add.l	d1,d0						;8		((u3-u1) * (y2-y1)/(y3-y1)) + (u1-u2)

	lea		divTablePivot_polygon,a0			;8
	add.w	d7,d7						;4
	move.w	(a0,d7.w),d6				;20		1/width
	swap	d0							;4
	muls	d6,d0						;56		8   ( (u3-u1) * (y2-y1)/(y3-y1)) + (u1-u2) / width

	IFEQ	SEP_UV
		move.w	v1(a5),d4
		move.w	v3(a5),d1
	ELSE
		move.w	8(a1),d4					;12		v1									move.w	(a1),d4			-4	
		move.w	8(a3),d1					;12		v3									move.w	(a3),d1			-4
	ENDC
	sub.w	d4,d1						;4		v3-v1
	add.w	d1,d1						;4		
	muls	d2,d1						;56		(v3-v1) * (y2-y1)/(y3-y1)

	IFEQ	SEP_UV
		sub.w	v2(a5),d4
	ELSE
		sub.w	8(a2),d4					;12		v1-v2								sub.w	(a2),d4			-4
	ENDC
	asr.w	#7,d4						;20	

	swap	d1							;4
	add.w	d4,d1						;4		(((v3-v1) * (y2-y1)/(y3-y1)) + (v1-v2)) / width

	muls	d6,d1						;56
	asr.l	#7,d1						;20
;--------------------------------------------------------- smc unrolled innerloop code with stepping offsets
		add.l	d0,d0
		swap	d1

	move.l	d0,d2		; local du
	move.l	d1,d3		; local dv
	moveq	#0,d4

smcLoopSize_tp	equ -18

	move.w	d7,d6
	bge		.noneg
		neg.w	d6
.noneg
;	muls	#smcLoopSize_t,d6
	move.w	d6,a0	
	asl.w	#3,d6
		add.w	a0,d6
	neg.w	d6
.kkk
	lea		.doSMCLoopEnd+2*smcLoopSize_tp,a0	; 2 more than needed, because this way we prevent reading outside the texture, hax...
	lea		textMapp+2+127*4,a4				; first load the end of the canvas table
	sub.w	2(a0,d6.w),a4					; then we rectify the table offset
	jmp		(a0,d6.w)						; and we need to load the proper address to a4, combined with the offset of the width span
.y1_y3		dc.w	0
.y1_y2		dc.w	0
.y2_y3		dc.w	0


.doSMCLoop
.offset set 0								; offset into the unrolled loop of 		move.b textoff(a0),-(a1)
	REPT 128
			move.w	d4,.offset(a4)			;12	4	smc the offset into the writing to canvas code
			move.l	d3,d4					;4	2	local dv
			swap	d4						;4	2	int lower word
			swap	d2						;4	2	local du
			move.b	d2,d4					;4	2	move du in so that VVVV UUUU
			swap	d2						;4	2	swap back
			add.l	d0,d2					;8	2	increment							; if xxxx ---- ---- XXXX, then add.l	d0,d2  add.x DX,d2	move.b	d2,d4
			add.l	d1,d3					;8	2	increment
.offset set .offset-4						
	ENDR
.doSMCLoopEnd
;--------------------------------------------------------- time to draw triangles
;	lea		canvas,a6						;8 		load canvas
	move.l	canvasPointer_text_polygon,a6
	move.w	2(a1),d0						;8		get top y							move.w	-6(a1),d0
	asl.w	#7,d0							;18		canvas *128
	add.w	d0,a6							;8		add y offset to canvas
	tst.w	d7								;4		d7 is still span, but negative and positive determine where the 2nd point is
	blt		.middleRight
.middleLeft
	move.w	.y1_y2,d0		; y1_y2
	beq		.two_top_left		; if 0 ==> then p1 and p2 top
.first_slice_p1_p2_middle_left
		move.l	usp,a0

		IFEQ	SEP_UV
			move.l	a5,-(sp)
		ENDC
		move.l	a2,-(sp)					;16		save a2
		move.l	a3,-(sp)					;16		save a3

		move.w	(a1),d1						;8		startx								move.w	-6(a1),d1			+4
		move.w	(a3),d7						;8 		x3									move.w	-6(a3),d7			+4

		IFEQ	SEP_UV
			move.w	u1(a5),d5
			move.w	u2(a5),d2
		ELSE
			move.w	6(a1),d5					;12		u1 global							move.w	-2(a1),d5			0
			move.w	6(a2),d2					;12		u2 									move.w	-2(a2),d2			0
		ENDC
		sub.w	d5,d2						;4		u2-u1
		ext.l	d2
		or.w	d0,d2						;4						
		add.w	d2,d2						;4
		add.w	d2,d2						;4		
		move.l	(a0,d2.l),a3				;20		a3 = du/dy	u2-u1 / y2-y1

		IFEQ	SEP_UV
			move.w	v1(a5),d4
			move.w	v2(a5),d2
		ELSE
			move.w	8(a1),d4					;12		v1 global							move.w	(a1),d4				-4
			move.w	8(a2),d2					;12		v2									move.w	(a2),d2				-4
		ENDC
		sub.w	d4,d2						;4		v2-v1
		ext.l	d2
		or.w	d0,d2						;4
		add.w	d2,d2						;4
		add.w	d2,d2						;4
		move.l	(a0,d2.l),d2				;20		v2-v1 / y2-y1
		asr.l	#8,d2						;24		>>8
		move.w	d2,a4						;4		a4 = dv/dy	

		asr.w	#7,d5						;20		>>7
		swap	d5							;4
		sub.w	d5,d5						;4		u1 global 16.16 format

		move.w	(a2),d3						;8		x2									move.w	-6(a2),d4			+4
		sub.w	d1,d3						;4 		x2-x1
		ext.l	d3
		asl.l	#7,d3						;20		>>7
		or.w	d0,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a0,d3.l),a1				;20		a1 = dx/dy left	x2-x1 / y2-y1 

		sub.w	d1,d7						;4		x3-x1
		ext.l	d7
		asl.l	#7,d7						;20		>> 7
		or.w	.y1_y3(pc),d7				;16		
		add.l	d7,d7						;4
		add.l	d7,d7						;4

		move.l	(a0,d7.l),a5				;20		a5 = dx/dy right x3-x1 / y3-y1

		add.w	d4,d4						;4
		swap	d1							;4
		sub.w	d1,d1						;4
		move.l	d1,d2						;4

		subq.w	#1,d0						;4			94 nop

		jsr		drawHLine_polygon
		; d0, loopvar					
		; d1, x_start
		; d2, x_end
		; d3, x_end LOCAL
		; d4, dv_global
		; d5, du_global
		; d6, texture_aligned_pointer
		; d7, addx
		; a0, texture
		; a1, dx_left
		; a2, --
		; a3, du/dy
		; a4, dv/dy
		; a5, dx_right
		; a6, canvas
		move.l	(sp)+,a3					;12
		move.l	(sp)+,a2					;12
.second_slice_p2_p3_middle_left
; p3.y - p2.y
		move.w	.y2_y3,d0					;12		y3-y2				height
		move.l	usp,a0
; sx
		move.w	(a2),d1						;8		x2 set x_start							move.w	-6(a2),d1			+4	
		move.w	(a3),d3						;8		x3										move.w	-6(a3),d3			+4
		sub.w	d1,d3						;4		x3-x2

		IFEQ	SEP_UV
			move.l	a5,a3
			move.l	(sp)+,a5
		ENDC


		ext.l	d3
		asl.l	#7,d3						;20
		or.w	d0,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a0,d3.l),a1				;20		a1 = x3-x2 / y3-y2

; dv global
		IFEQ	SEP_UV
			move.w	v2(a5),d4
			move.w	v3(a5),d3
		ELSE
			move.w	8(a2),d4					;12		v2										move.w	(a2),d4				-4
			move.w	8(a3),d3					;12		v3										move.w	(a3),d3				-4
		ENDC
		sub.w	d4,d3						;4		v3-v2
		ext.l	d3
		or.w	d0,d3						;4
		add.w	d3,d3						;4
		add.w	d3,d3						;4
		move.l	(a0,d3.l),d3				;20		v3-v2  / y3-y2
		asr.l	#8,d3						;24
;; du/dy
		IFEQ	SEP_UV
			move.w	u2(a5),d5
			move.w	u3(a5),d7
			move.l	a3,a5
		ELSE
			move.w	6(a2),d5					;12		u2										move.w	-2(a2),d5			0
			move.w	6(a3),d7					;12		u3										move.w	-2(a3),d7			0
		ENDC
		sub.w	d5,d7 						;4		u3-u2
		ext.l	d7
		or.w	d0,d7						;4
		add.w	d7,d7						;4
		add.w	d7,d7						;4
		move.l	(a0,d7.l),a3				;20		a3 = u3-u2 / y3-y2

		asr.w	#7,d5						;20
		swap	d5							;4
		sub.w	d5,d5						;4

		move.w	d3,a4						;4		a4 = v3-v2 / y3-y2

		swap	d1							;4
		sub.w	d1,d1						;4
		add.w	d4,d4						;4

		jsr		drawHLine_polygon
		; d0, loopvar					
		; d1, x_start
		; d2, x_end
		; d3, x_end LOCAL
		; d4, dv_global
		; d5, du_global
		; d6, texture_aligned_pointer
		; d7, addx
		; a0, texture
		; a1, dx_left
		; a2, --
		; a3, du/dy
		; a4, dv/dy
		; a5, dx_right
		; a6, canvas
		rts
.two_top_left
	move.l	usp,a0
; 2 ---------- 1
;   \        /
;    \.     / 
;     \.   /
;      \. /
;       \/
;       3
	move.w	(a2),d1							;8		x2 startx
	move.w	(a1),d2							;8		x1 endx

	move.w	(a3),d3							;8		x3 xleft
	move.w	d3,d7							;4		x3 xright

	move.w	.y2_y3,d0						;16		y3-y2. height

	sub.w	d1,d3							;4		x3-x1
	ext.l	d3
	asl.l	#7,d3							;20
	or.w	d0,d3							;4
	add.l	d3,d3							;4
	add.l	d3,d3							;4
	move.l	(a0,d3.l),a1					;20		a1 = x3-x1 / y3-y2 dx/dy left


	sub.w	d2,d7							;4
	ext.l	d7
	asl.l	#7,d7							;20
	or.w	d0,d7							;4
	add.l	d7,d7							;4
	add.l	d7,d7							;4

	IFEQ	SEP_UV
		move.w	v2(a5),d4
		move.w	v3(a5),d3
	ELSE
		move.w	8(a2),d4						;12		v2
		move.w	8(a3),d3						;12		v3
	ENDC
	sub.w	d4,d3							;4		v3-v2
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4
	move.l	(a0,d3.l),d3					;20		v3-v2 / y3-y2
	asr.l	#8,d3							;24 		<< 8
	move.l	d3,a4							;4		a4 = dv/dy

	IFEQ	SEP_UV
		move.w	u2(a5),d5
		move.w	u3(a5),d3
	ELSE
		move.w	6(a2),d5						;12		u2
		move.w	6(a3),d3						;12		u3
	ENDC
	sub.w	d5,d3							;4		u3-u2
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4
	move.l	(a0,d3.l),a3					;20		a3 = u3-u2 / y3-y2

	add.w	d4,d4							;4
	asr.w	#7,d5							;20	
	swap	d5								;4
	sub.w	d5,d5							;4
	move.l	(a0,d7.l),a5					;20		a5 = dx/dy right

	subq.w	#1,d0							;4
	swap	d1								;4
	swap	d2								;4
	sub.w	d1,d1							;4
	sub.w	d2,d2							;4

	jsr		drawHLine_polygon
	; d0, loopvar					
	; d1, x_start
	; d2, x_end
	; d3, x_end LOCAL
	; d4, dv_global
	; d5, du_global
	; d6, texture_aligned_pointer
	; d7, addx
	; a0, texture
	; a1, dx_left
	; a2, --
	; a3, du/dy
	; a4, dv/dy
	; a5, dx_right
	; a6, screen	move.l	(sp)+,a0
	rts
.middleRight
	move.w	.y1_y2,d0						;16		y1_y2
	beq		.two_top_right					; if 0 ==> then p1 and p2 top
		move.l	usp,a0
		move.l	a2,-(sp)					;16		save a2
		move.l	a3,-(sp)					;16		save a3

		move.w	.y1_y3,d7					;16		height y1_y3												;15
		move.w	(a1),d1						;8		x1, startx
		move.w	(a3),d3						;8		x3

		IFEQ	SEP_UV
			move.w	v1(a5),d4
			move.w	v3(a5),d2
		ELSE
			move.w	8(a1),d4					;12		v1
			move.w	8(a3),d2					;12		v3 p3.v
		ENDC
		sub.w	d4,d2						;4		v3-v1
		ext.l	d2
		or.w	d7,d2						;4
		add.w	d2,d2						;4
		add.w	d2,d2						;4
		move.l	(a0,d2.l),d2				;20		v3-v1 / y3-y1
		asr.l	#8,d2						;24
		move.w	d2,a4						;4
; du/dy
		IFEQ	SEP_UV
			move.w	u1(a5),d5
			move.w	u3(a5),d2
		ELSE
			move.w	6(a1),d5					;12		u1
			move.w	6(a3),d2					;12		u3
		ENDC
		sub.w	d5,d2						;4		u3-u1
		ext.l	d2
		or.w	d7,d2						;4
		add.w	d2,d2						;4
		add.w	d2,d2						;4
		move.l	(a0,d2.l),a3				;20		a3 = u3-u1 / y3-y1

		asr.w	#7,d5						;20
		swap	d5							;4
		sub.w	d5,d5						;4
;	d3 = dx_left / dy
		sub.w	d1,d3						;4		x3-x1
		ext.l	d3
		asl.l	#7,d3						;20
		or.w	d7,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a0,d3.l),a1				;20		a1 = x3-x1 / y3-y1

		move.w	(a2),d2						;8		x2
		sub.w	d1,d2						;4		x2-x1
		ext.l	d2
		asl.l	#7,d2						;20
		or.w	d0,d2						;4
		add.l	d2,d2						;4
		add.l	d2,d2						;4
		move.l	(a0,d2.l),a5				;20		a5 = x2-x1 / y2-y1

		add.w	d4,d4						;4
		subq.w	#1,d0						;4
		swap	d1							;4	
		sub.w	d1,d1						;4
		move.l	d1,d2						;4

		jsr		drawHLine_polygon
		; d0, loopvar					
		; d1, x_start
		; d2, x_end
		; d3, x_end LOCAL
		; d4, dv_global
		; d5, du_global
		; d6, texture_aligned_pointer
		; d7, addx
		; a0, texture
		; a1, dx_left
		; a2, --
		; a3, du/dy
		; a4, dv/dy
		; a5, dx_right
		; a6, screen		
		move.l	a3,d7						;4 		save a3
		move.l	(sp)+,a3					;12
		move.l	(sp)+,a2					;12
.middleRight_sliceTwo		
		move.l	usp,a0

		move.w	(a2),d2						;8		x2	
		move.w	(a3),d3						;8		x3

		move.w	.y2_y3,d0					;16		y3-y2
		sub.w	d2,d3						;4		x3-x2 determine new right dx x3-x2
		ext.l	d3
		asl.l	#7,d3						;20
		or.w	d0,d3						;4
		add.l	d3,d3						;4
		add.l	d3,d3						;4
		move.l	(a0,d3.l),a5				;20		a5 = dx/dy right

		swap	d2							;4
		sub.w	d2,d2						;4
		move.l	d7,a3						;4		restore a3
		jsr		drawHLine_polygon
.end
	rts
.two_top_right
	move.l	usp,a0
	move.w	(a1),d1							;8		x1	startx left
	move.w	(a2),d2							;8		x2	endx right
	move.w	(a3),d6							;8		x3	
	move.w	d6,d7							;8		save

	move.w	.y1_y3,d0						;16		y3-y1
	sub.w	d1,d6							;4		x3-x1

	asl.w	#7,d6							;20
	or.w	d0,d6							;4

	sub.w	d2,d7							;4		x3-x2
	ext.l	d7
	asl.l	#7,d7							;20
	or.w	d0,d7							;4
	add.l	d7,d7							;4
	add.l	d7,d7							;4

	IFEQ	SEP_UV
		move.w	v1(a5),d4
		move.w	v3(a5),d3
	ELSE
		move.w	8(a1),d4						;12 	v1
		move.w	8(a3),d3						;12		v3
	ENDC
	sub.w	d4,d3							;4		v3-v1
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4
	move.l	(a0,d3.l),d3					;20
	asr.l	#8,d3							;24
	move.l	d3,a4							;4		a4 = dv/dy

	add.w	d4,d4							;4

	IFEQ	SEP_UV
		move.w	u1(a5),d5
		move.w	u3(a5),d3
	ELSE
		move.w	6(a1),d5						;12		u1
		move.w	6(a3),d3						;12		u3
	ENDC
	sub.w	d5,d3							;4		u3-u1
	ext.l	d3
	or.w	d0,d3							;4
	add.w	d3,d3							;4
	add.w	d3,d3							;4	
	move.l	(a0,d3.l),a3					;20		a3 = du/dy

	asr.w	#7,d5							;20
	swap	d5								;4
	sub.w	d5,d5		

	move.w	d6,a1
	add.l	a1,a1
	add.l	a1,a1

						;4
	move.l	(a0,a1.l),a1					;20		a1 = dx/dy	left
	move.l	(a0,d7.l),a5					;20		a5 = dx/dy	right

	subq.w	#1,d0							;4
	swap	d1								;4
	swap	d2								;4
	sub.w	d1,d1							;4
	sub.w	d2,d2							;4

	jsr		drawHLine_polygon
	; d0, loopvar					
	; d1, x_start
	; d2, x_end
	; d3, x_end LOCAL
	; d4, dv_global
	; d5, du_global
	; d6, texture_aligned_pointer
	; d7, addx
	; a0, texture
	; a1, dx_left
	; a2, --
	; a3, du/dy
	; a4, dv/dy
	; a5, dx_right
	; a6, screen	
	rts



;x_start			equr	d1
;x_end_global		equr	d2
;x_end_local		equr	d3
;dv_global			equr	d4
;du_global			equr	d5
;txtp				equr	d6
;
;txtr				equr	a0
;dx_l				equr	a1
;du_dy				equr	a3
;dv_dy				equr	a4
;dx_r				equr	a5
;cvs				equr	a6

drawHLine_polygon
	move.l	a6,d7													
	lea		textMapp+127*4,a2
loop_polygon
		move.w	d4,d6						;4		; dv local									
		swap	d5							;4		
		move.b	d5,d6						;4		; du local
		swap	d5							;4

		move.l	d7,a6						;4		canvas
		swap	d2							;4												
		move.l	d1,d3						;4		; x_start local							
		swap	d3							;4
		sub.w	d2,d3						;4		; x_start - x_end
		add.w	d2,a6						;8		
		swap	d2							;4												

		move.l	d6,a0						;4		; texture pointer
		add.w	d3,d3						;4		; 
		add.w	d3,d3						;4		; 	
		cmp.w	#4,d3
		jmp		(a2,d3.w)					;16
textMapp
		REPT 128
			move.b $1(a0),-(a6)
		ENDR
		add.w	#canvaswidth_polygon,d7				;8		
		add.l	a1,d1						;8		; 16.16 dx_left	
		add.l	a5,d2						;8		; 16.16 dx_right
		add.w	a4,d4						;4		; dv	x.8-8									
		add.l	a3,d5						;8		; dx	16.16			28 nop
	dbra	d0,loop_polygon
	move.l	d7,a6
	rts

; a0 table
; d0 x
; d1 1/x
;	lea		divTablePivot,a0
;	add.w	d0,d0
;	move.w	(a0,d0.w),d1
;	

initDivTable_polygon_pivot
	lea		divTablePivot_polygon,a0		;pos
	move.l	a0,a1					;neg
	moveq	#1,d0
	move.w	#-1,d1
	move.l	#$7fff,d6					;pos
	move.l	#-1,d5					;neg
	move.w	#256/2-1,d7
	move.w	d6,(a0)+
.loop
		; pos
		move.l	d6,d4
		divu	d0,d4
		move.w	d4,(a0)+
		; neg
		neg.w	d4
		move.w	d4,-(a1)

		addq.w	#1,d0
		subq.w	#1,d1

	dbra	d7,.loop
	rts



dodiv	macro
		moveq	#0,d1
		move.l	d7,d5	; x																			;	4
		cmp.w	d2,d6
		bgt.w	.skipdiv\@

		asl.l	#8,d5

		divu	d6,d5
		move.w	d5,d1		; whole
		clr.w	d5
		swap	d5
		asl.l	#8,d5
		divu	d6,d5
		swap	d1			
		asr.l	#8,d1
		or.w	d5,d1
;		asr.l	#8,d1

		move.l	d7,d5
		neg.l	d5
		asl.l	#7,d5
		or.w	d6,d5
		add.l	d5,d5
		add.l	d5,d5

.skipdiv\@
		move.l	d1,(a0)+
		neg.l	d1
		move.l	d1,(a1,d5.l)

		addq	#1,d6	
	endm
        

initDivTable_polygon
	move.l	divtablepointer_polygon,a0
	move.l	a0,a1
	moveq	#0,d1
	moveq	#0,d7
	moveq	#0,d6
	moveq	#0,d5
	moveq	#0,d4
	move.l	#128,d0
	move.w	#128,d2
; encoding: upper 8 bits is x
;			lower 8 bits is y
; offset is longword per item
.outerloop:
	moveq	#0,d6		; y
.innerloop:
	REPT 8
		dodiv
	ENDR
		cmp		d0,d6																				;	8
		blt		.innerloop																			; ----> +12 ==> 426

	addq	#1,d7																					;	4
	cmp		d2,d7																					;	8
	blt		.outerloop																				; ---> 256*256*426 + 256*16 = 3.5sec precalc

	rts







c2p_2to4_optimized_polygon												;16kbv

;	lea		canvas,a0
	move.l	canvasPointer_text_polygon,a0
	move.l	screenpointer2,a6




	move.l	screenpointer,d0
	cmp.l	screen2,d0
	beq		.screen2				; if screen == 2
.screen1							;	else, screen == 1 !
		move.w	yBotp,d7			;	
		cmp.w	screen1bot,d7		
		bge		.s1bot_ok
			move.w	screen1bot,d7
.s1bot_ok
		move.w	yTopp,d0
		cmp.w	screen1top,d0
		ble		.s1top_ok
			move.w	screen1top,d0
.s1top_ok
		jmp		.done

.screen2
		move.w	yBotp,d7
		cmp.w	screen2bot,d7
		bge		.s2bot_ok
			move.w	screen2bot,d7
.s2bot_ok
		move.w	yTopp,d0
		cmp.w	screen2top,d0
		ble		.s2top_ok
			move.w	screen2top,d0
.s2top_ok
.done

;	move.w	yBotp,d7
;	move.w	yTopp,d0
	sub.w	d0,d7
	move.w	d7,.counter
	move.w	d0,d1
	lsl.w	#7,d0
	muls	#320,d1
	add.w	d0,a0
	add.w	d1,a6
	lea		160*DRAW_YLINES_OFFSET(a6),a6


	move.l	a6,usp
;	move.w	#75,.counter
.loop
.off set 0
;	REPT 75															;17kb, generate!
			movem.w	(a0)+,a1-a6			;36				;6				;6 + 12 + 24. = 42 per 8 320 = 40 = 40*42*50		84000 cycles

			move.l	(a1),d0				;12
			or.l	-(a2),d0			;20		32

			move.l	(a3),d1				;12
			or.l	-(a4),d1			;20

			move.l	(a5),d2				;12
			or.l	-(a6),d2			;20				36 + 3*32

			movem.w	(a0)+,a1-a6			;36

			move.l	(a1),d3				;12
			or.l	-(a2),d3			;20

			move.l	(a3),d4				;12
			or.l	-(a4),d4			;20

			move.l	(a5),d5				;12	
			or.l	-(a6),d5			;20				36 + 3*32	--> 264

			movem.w	(a0)+,a1-a6			;36

			move.l	(a1),d6				;12
			or.l	-(a2),d6			;20

			move.l	(a3),d7				;12
			or.l	-(a4),d7			;20				;8*32 + 3*36 + 8*24 = 256+108+192=556 	--> 560 for 8*4 1:2 pixels 32

			move.l	usp,a1				;4								104

			movep.l	d0,.off+0(a1)		;24
			movep.l	d1,.off+1(a1)		;24
			movep.l	d2,.off+8(a1)		;24
			movep.l	d3,.off+9(a1)		;24
			movep.l	d4,.off+16(a1)		;24
			movep.l	d5,.off+17(a1)		;24
			movep.l	d6,.off+24(a1)		;24
			movep.l	d7,.off+25(a1)		;24				8*24 = 			192

			move.l	(a5),d0				;12
			or.l	-(a6),d0			;20				32
			movep.l	d0,.off+32(a1)		;24				24				56

			movem.w	(a0)+,a1-a6			;36

			move.l	(a1),d0				;12
			or.l	-(a2),d0			;20

			move.l	(a3),d1				;12
			or.l	-(a4),d1			;20

			move.l	(a5),d2				;12
			or.l	-(a6),d2			;20				36 + 3*32		132

			movem.w	(a0)+,a1-a6			;36

			move.l	(a1),d3				;12
			or.l	-(a2),d3			;20

			move.l	(a3),d4				;12
			or.l	-(a4),d4			;20

			move.l	(a5),d5				;12
			or.l	-(a6),d5			;20				36 + 3*32 		132

			move.w	(a0)+,a1			;8
			move.w	(a0)+,a2			;8

			move.l	(a1),d6				;12
			or.l	-(a2),d6			;20

			move.l	usp,a1				;4								52

			movep.l	d0,.off+33(a1)		;24
			movep.l	d1,.off+40(a1)		;24
			movep.l	d2,.off+41(a1)		;24		
			movep.l	d3,.off+48(a1)		;24
			movep.l	d4,.off+49(a1)		;24		
			movep.l	d5,.off+56(a1)		;24
			movep.l	d6,.off+57(a1)		;24				7*24			168		===> 1100 / 128 = 8,59375			68,75 per 8		

.off set .off+64
			movem.w	(a0)+,a1-a6			;36				;6				;6 + 12 + 24. = 42 per 8 320 = 40 = 40*42*50		8400
			move.l	(a1),d0				;12
			or.l	-(a2),d0			;20		32
			move.l	(a3),d1				;12
			or.l	-(a4),d1			;20
			move.l	(a5),d2				;12
			or.l	-(a6),d2			;20				36 + 3*32
			movem.w	(a0)+,a1-a4			;36
			move.l	(a1),d3				;12
			or.l	-(a2),d3			;20
			move.l	(a3),d4				;12
			or.l	-(a4),d4			;20
;			move.l	(a5),d5				;12	
;			or.l	-(a6),d5			;20				36 + 3*32	--> 264
;			movem.w	(a0)+,a1-a6			;36													
;			move.w	(a0)+,a1
;			move.w	(a0)+,a2
;			move.l	(a1),d6				;12
;			or.l	-(a2),d6			;20
;			move.l	(a3),d7				;12
;			or.l	-(a4),d7			;20		
			move.l	usp,a1				;4								104
			movep.l	d0,.off+0(a1)		;24
			movep.l	d1,.off+1(a1)		;24
			movep.l	d2,.off+8(a1)		;24
			movep.l	d3,.off+9(a1)		;24
			movep.l	d4,.off+16(a1)		;24
;			movep.l	d5,.off+17(a1)		;24
;			movep.l	d6,.off+24(a1)		;24
			lea		44(a0),a0

		movem.l	(a1)+,d0-d7/a2/a3/a4/a5		; 14 			;-4				;124
		movem.l	d0-d7/a2/a3/a4/a5,-48+160(a1)									;124
		movem.l	(a1)+,d0-d7/a2/a3		;60
		movem.l	d0-d7/a2/a3,-40+160(a1)		;60


.off set .off+160+160-64
;	ENDR
			add.w	#320-88,a1
			move.l	a1,usp
		subq.w	#1,.counter
		bge		.loop



	move.l	screenpointer,d0
	cmp.l	screen2,d0
	beq		.screen2x				; if screen == 2
.screen1x							;	else, screen == 1 !
		move.w	yBotp,screen1bot			;	
		move.w	yTopp,screen1top
		jmp		.done2

.screen2x
		move.w	yBotp,screen2bot
		move.w	yTopp,screen2top
.done2


	rts
.counter 	dc.w 	0


;96 read
; 3* 92 write ==> 96+3*92 = 372 per line and this *4 = 1488 per unique line and we got 50 of them 74400


copyLines_polygon
	move.l	screenpointer2,a6
	add.w	#160,a6
;	add.w	#16,a6
	REPT 	75																		;1.6k
		movem.l	(a6)+,d0-d6/a0-a5		; 14 			;-4				;124
		movem.l	d0-d6/a0-a5,-52+160(a6)									;124
		movem.l	(a6)+,d0-d7/a0		;60
		movem.l	d0-d7/a0,-36+160(a6)		;60
		lea		160+160-88(a6),a6										;8		304 * 64 = 19456
	ENDR
	rts


; this generates a table using $602 and up
;
;	
generateOptimizedTabs_polygon
	lea		$606,a0
	lea		TAB1,a1
	lea		TAB2,a2
	lea		TAB3,a3
	lea		TAB4,a4
	moveq	#0,d1
	move.w	#16-1,d7
.ol
		move.l	(a1,d1.w),d2
		move.l	(a3,d1.w),d3
		move.w	#16-1,d6
		moveq	#0,d0
.il
			move.l	d2,d4
			move.l	d3,d5

			or.l	(a2,d0.w),d4
			or.l	(a4,d0.w),d5

			move.l	d4,(a0)
			move.l	d5,-4(a0)

			lea		8(a0),a0				; 128 bytes each
			addq.w	#4,d0
		dbra	d6,.il
		addq.w	#4,d1
		lea     $0800-16*8(a0),a0				; $606 + 15*2048 = 31326
	dbra	d7,.ol
	rts


	; normal:
	;	|	cosBcosC		cosCsinAsinB - cosAsinC		cosAcosCsinB + sinAsinC
	;	|	cosBsinC		cosAcosC + sinAsinBsinC		cosAsinBsinC - cosCsinA
	;	|	-sinB			cosBsinA					cosAcosB 

calculateRotatedProjection_polygon
	lea		_sintable512,a0
	lea		_sintable512+(512*2/4),a1
rot_smc1x
	add.w	#100,_currentStepX_polygon
rot_smc1y
	add.w	#100,_currentStepY_polygon
rot_smc1z
	add.w	#100,_currentStepZ_polygon
   
	move.w	_currentStepX_polygon,d2
	move.w	_currentStepY_polygon,d4
	move.w	_currentStepZ_polygon,d6


;	move.w	#420,_currentStepX_polygon


	and.w	#%1111111110,d2
	and.w	#%1111111110,d4
	and.w	#%1111111110,d6


;	move.w	#$AC,_currentStepX
;	add.w	#2,_currentStepY
;	add.w	#6,_currentStepZ


	move.w	(a0,d2.w),d1					; sinA	;around z axis		16
	move.w	(a1,d2.w),d2					; cosA						16

	move.w	(a0,d4.w),d3					; sinB	;around y axis		16
	move.w	(a1,d4.w),d4					; cosB						16

	move.w	(a0,d6.w),d5					; sinC	;around x axis		16
	move.w	(a1,d6.w),d6					; cosC						16

_sinA_poly		equr d1
_cosA_poly		equr d2
_sinB_poly		equr d3
_cosB_poly		equr d4
_sinC_poly		equr d5
_cosC_poly		equr d6

;	xx = [cosA * cosB]
	move.w	_cosA_poly,d7
	muls	_cosB_poly,d7
	swap	d7
;	move.w	d7,a0
	move.w	d7,.smc_xx+2
;	xy = [sinA * cosB]
	move.w	_sinA_poly,d7
	muls	_cosB_poly,d7
;	lsl.l	#2,d7
	swap	d7
;	move.w	d7,_xy
;	move.w	d7,a1
	move.w	d7,.smc_xy+2

;	xz = [sinB]	
;	move.w	_sinB,_xz
	move.w	_sinB_poly,d7
	asr.w	#1,d7
;	move.w	d7,a2
	move.w	d7,.smc_xz+2

;	yx = [sinA * cosC + cosA * sinB * sinC]
	move.w	_sinA_poly,d7
	muls	_cosC_poly,d7
	move.w	_cosA_poly,d0
	muls	_sinB_poly,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_sinC_poly,d0
	add.l	d7,d0
;	lsl.l	#2,d0
	swap	d0
;	move.w	d0,_yx	; sinA * cosC + cosA * sinB * sinC
;	move.w	d0,a3
	move.w	d0,.smc_yx+2
;	yy = [-cosA * cosC + sinA * sinB * sinC]
	move.w	_cosA_poly,d7
	neg		d7
	muls	_cosC_poly,d7
	move.w	_sinA_poly,d0
	muls	_sinB_poly,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_sinC_poly,d0
	add.l	d7,d0
;	lsl.l	#2,d0
	swap	d0
;	move.w	d0,_yy
	move.w	d0,a4
		move.w	d0,.smc_yy+2

;	yz = [-cosB * sinC]
	move.w	_cosB_poly,d7
	neg.w	d7
	muls	_sinC_poly,d7
;	lsl.l	#2,d7
	swap	d7
		move.w	d7,.smc_yz+2

;;	zx = [sinA * sinC - cosA * sinB * cosC]
	move.w	_sinA_poly,d7
	muls	_sinC_poly,d7
	move.w	_cosA_poly,d0
	muls	_sinB_poly,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_cosC_poly,d0
	sub.l	d0,d7
	swap	d7
	move.w	d7,.smc_zx+2
	move.w	d7,_zx_polygon
;
;;	zy = [-cosA * sinC - sinA * sinB * cosC]
	move.w	_cosA_poly,d7
	muls	_sinC_poly,d7
	neg.l	d7
	move.w	_sinA_poly,d0
	muls	_sinB_poly,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_cosC_poly,d0
	sub.l	d0,d7
	swap	d7
	move.w	d7,.smc_zy+2
	move.w	d7,_zy_polygon
;
;;	zz = [cosB * cosC]
	move.w	_cosB_poly,d7
	muls	_cosC_poly,d7
	swap	d7
	move.w	d7,.smc_zz+2
	move.w	d7,_zz_polygon

	movem.l	a0-a4,_matrix_polygon
;	pushall
		jsr		cullFacesPolygon
;	popall
	movem.l	_matrix_polygon,a0-a4


;	IFEQ	ENVMAP_TT
;	move.w	(a4),.smc_text_y+2			; this is ussed to displace y offset
;	ENDC

	move.l	currentNormalsPointer,a4
;	lea		currentNormalsp,a4
;	lea		currentVerticesp,a5					;8	
	move.l	currentVerticesPointer,a5
;	lea		pointsPolygon,a6
	move.l	currentPointsPointer,a6

;	move.w	number_of_verticesp,d7
	move.w	current_number_of_vertices,d7
	subq.w	#1,d7
	move.w	#44,a0
	move.w	#45,a1




	; now determine the multiply value
	; a0	=	xoff
	; a1	=	yoff
	; a2	=	
	; a3	=	
	; a4	=	
	; a5	=	vertices
	; a6	=	projected vertices
	; d0	=	x
	; d1	=	y
	; d2	=	z
	; d3	=	local
	; d4	=	local
	; d5	=	
	; d6	=	
	; d7	=	loop counter
	lea		persTable,a4

.rotate
		subq.w	#1,(a5)+
		blt		.skipvertex
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2		;24									

;	z'' = x*zx + y*zy + z*zz
		move.w	d0,d5
.smc_zx
		muls	#$1234,d5
		move.w	d1,d6
.smc_zy
		muls	#$1234,d6
		add.l	d6,d5
		move.w	d2,d6
.smc_zz
		muls	#$1234,d6
		add.l	d6,d5
		swap	d5

		move.w	d5,d6
		add.w	d6,d6
		move.w	(a4,d6),d6			; multiplacation value


;	x'' = x * xx + y * xy + z * xz											
		move.w	d0,d3
.smc_xx	
		muls	#1234,d3
		move.w	d1,d4
.smc_xy
		muls	#1234,d4
		add.l	d4,d3			;8		xx * x + xy * y							add.l	d4,d3
		move.w	d2,d4
.smc_xz	
		muls	#1234,d4
		add.l	d4,d3			;8		x * xx + y * xy + z * xz				add.l	d4,d3
		asl.l	#4,d3
;		add.l	d3,d3
;		add.l	d3,d3
		swap	d3				;4		int to lower							swap	d3
		muls	d6,d3
		swap	d3
		asr.w	#3,d3
		add.w	a0,d3			;4		add y offset							add.w	d5,d3
		move.w	d3,(a6)+		;8		save									move.w	d3,(a6)+

;	y'' = x * yx + y * yy + z * yz
		move.w	d0,d3
.smc_yx
		muls	#1234,d3
		move	d1,d4
.smc_yy																;			muls	#$1234,d4
		muls	#$1234,d4		;50											;	add.l	d4,d3
		add.l	d4,d3
		move.w	d2,d4
.smc_yz																		;	move.w	d2,d4
		muls	#$1234,d4		;52											;	muls	
		add.l	d4,d3
		asl.l	#4,d3
;		add.l	d3,d3
;		add.l	d3,d3
		swap	d3				;4
		muls	d6,d3
		swap	d3
		asr.w	#3,d3
		add.w	a1,d3			;4
		move.w	d3,(a6)+		;8	--> 	188 --> 396


		move.w	d5,(a6)+

		lea		4(a6),a6
	dbra	d7,.rotate
	jmp		.cont
.skipvertex
		lea		10(a6),a6
		lea		6(a5),a5
	dbra	d7,.rotate
.cont
	rts
_zx_polygon						ds.l	1
_zy_polygon						ds.l	1
_zz_polygon						ds.l	1
_matrix_polygon							ds.l	5

.x set $7fff/2+$7fff/4+$7fff/8+$7fff/16+$7fff/32-18000
	REPT 100
		dc.w	.x
.x set .x+90
	ENDR
persTable
.x set $7fff/2+$7fff/4+$7fff/8+$7fff/16+$7fff/32-9000
	REPT 100
		dc.w	.x
.x set .x+90
	ENDR


calculateRotatedProjection_polygonEnvmap
	lea		_sintable512,a0
	lea		_sintable512+(512*2/4),a1

rot_smc2x
	add.w	#100,_currentStepX_polygon
rot_smc2y
	add.w	#100,_currentStepY_polygon
rot_smc2z
	add.w	#100,_currentStepZ_polygon
   
	move.w	_currentStepX_polygon,d2
	move.w	_currentStepY_polygon,d4
	move.w	_currentStepZ_polygon,d6


;	move.w	#420,_currentStepX_polygon


	and.w	#%1111111110,d2
	and.w	#%1111111110,d4
	and.w	#%1111111110,d6


;	move.w	#$AC,_currentStepX
;	add.w	#2,_currentStepY
;	add.w	#6,_currentStepZ


	move.w	(a0,d2.w),d1					; sinA	;around z axis		16
	move.w	(a1,d2.w),d2					; cosA						16

	move.w	(a0,d4.w),d3					; sinB	;around y axis		16
	move.w	(a1,d4.w),d4					; cosB						16

	move.w	(a0,d6.w),d5					; sinC	;around x axis		16
	move.w	(a1,d6.w),d6					; cosC						16

;	xx = [cosA * cosB]
	move.w	_cosA_poly,d7
	muls	_cosB_poly,d7
	swap	d7
	move.w	d7,a0
;	xy = [sinA * cosB]
	move.w	_sinA_poly,d7
	muls	_cosB_poly,d7
;	lsl.l	#2,d7
	swap	d7
;	move.w	d7,_xy
	move.w	d7,a1

;	xz = [sinB]	
;	move.w	_sinB,_xz
	move.w	_sinB_poly,d7
	asr.w	#1,d7
	move.w	d7,a2

;	yx = [sinA * cosC + cosA * sinB * sinC]
	move.w	_sinA_poly,d7
	muls	_cosC_poly,d7
	move.w	_cosA_poly,d0
	muls	_sinB_poly,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_sinC_poly,d0
	add.l	d7,d0
;	lsl.l	#2,d0
	swap	d0
;	move.w	d0,_yx	; sinA * cosC + cosA * sinB * sinC
	move.w	d0,a3
;	yy = [-cosA * cosC + sinA * sinB * sinC]
	move.w	_cosA_poly,d7
	neg		d7
	muls	_cosC_poly,d7
	move.w	_sinA_poly,d0
	muls	_sinB_poly,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_sinC_poly,d0
	add.l	d7,d0
;	lsl.l	#2,d0
	swap	d0
;	move.w	d0,_yy
	move.w	d0,a4
		move.w	d0,.smc_yy+2
		IFEQ	ENVMAP_TT
		move.w	d0,.smc_yy2+2
		ENDC

;	yz = [-cosB * sinC]
	move.w	_cosB_poly,d7
	neg.w	d7
	muls	_sinC_poly,d7
;	lsl.l	#2,d7
	swap	d7
		move.w	d7,.smc_yz+2
		IFEQ	ENVMAP_TT
		move.w	d7,.smc_yz2+2
		ENDC

;;	zx = [sinA * sinC - cosA * sinB * cosC]
	move.w	_sinA_poly,d7
	muls	_sinC_poly,d7
	move.w	_cosA_poly,d0
	muls	_sinB_poly,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_cosC_poly,d0
	sub.l	d0,d7
	swap	d7
	move.w	d7,.smc_zx+2
	move.w	d7,_zx_polygon
;
;;	zy = [-cosA * sinC - sinA * sinB * cosC]
	move.w	_cosA_poly,d7
	muls	_sinC_poly,d7
	neg.l	d7
	move.w	_sinA_poly,d0
	muls	_sinB_poly,d0
	add.l	d0,d0			;lsl 1
	swap	d0
	muls	_cosC_poly,d0
	sub.l	d0,d7
	swap	d7
	move.w	d7,.smc_zy+2
	move.w	d7,_zy_polygon
;
;;	zz = [cosB * cosC]
	move.w	_cosB_poly,d7
	muls	_cosC_poly,d7
	swap	d7
	move.w	d7,.smc_zz+2
	move.w	d7,_zz_polygon

	movem.l	a0-a4,_matrix_polygon
;	pushall
;		move.w	#$330,$ffff8240
		jsr		cullFacesPolygon
;		move.w	#$300,$ffff8240
;	popall
	movem.l	_matrix_polygon,a0-a3


;	IFEQ	ENVMAP_TT
;	move.w	(a4),.smc_text_y+2			; this is ussed to displace y offset
;	ENDC

	move.l	currentNormalsPointer,a4
;	lea		currentNormalsp,a4
;	lea		currentVerticesp,a5					;8	
	move.l	currentVerticesPointer,a5
;	lea		pointsPolygon,a6
	move.l	currentPointsPointer,a6

;	move.w	number_of_verticesp,d7
	move.w	current_number_of_vertices,d7
	subq.w	#1,d7
	move.w	#44,d5
	move.w	#42,d6




	; now determine the multiply value
	; a0	=	xx
	; a1	=	xy
	; a2	=	xz
	; a3	=	yx
	; a4	=	yy
	; _yz	=	yz
	; a5	=	vertices
	; a6	=	projected vertices
	; d0	=	x
	; d1	=	y
	; d2	=	z
	; d3	=	local
	; d4	=	local
	; d5	=	offsetx
	; d6	=	offsety
	; d7	=	loop counter

.rotate
		subq.w	#1,(a5)+
		blt		.skipvertex
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2		;24									

;	x'' = x * xx + y * xy + z * xz											
		move.w	a0,d3			;4		xx * x									move.w	d0,d3
		muls	d0,d3			;52												muls	#$1234,d3
		move.w	a1,d4			;4		xy * y									move.w	d1,d4
		muls	d1,d4			;52												muls	#$1234,d4				
		add.l	d4,d3			;8		xx * x + xy * y							add.l	d4,d3
		move.w	a2,d4			;4		xz										move.w	d2,d4
		muls	d2,d4			;60		xz * z									muls	#$1234,d4							
		add.l	d4,d3			;8		x * xx + y * xy + z * xz				add.l	d4,d3
		swap	d3				;4		int to lower							swap	d3
		add.w	d5,d3			;4		add y offset							add.w	d5,d3
		move.w	d3,(a6)+		;8		save									move.w	d3,(a6)+

;	y'' = x * yx + y * yy + z * yz
		move.w	a3,d3			;												move.w	d0,d3
		muls	d0,d3		;54													muls	#$1234,d3
;		move.w	a4,d3															move.w	d1,d4
		move	d1,d4
.smc_yy																;			muls	#$1234,d4
		muls	#$1234,d4		;50											;	add.l	d4,d3
		add.l	d4,d3
		move.w	d2,d4
.smc_yz																		;	move.w	d2,d4
		muls	#$1234,d4		;52											;	muls	
		add.l	d4,d3

		swap	d3				;4
		add.w	d6,d3			;4
		move.w	d3,(a6)+		;8	--> 	188 --> 396


;	z'' = x*zx + y*zy + z*zz
.smc_zx
		muls	#$1234,d0
.smc_zy
		muls	#$1234,d1
		add.l	d1,d0
.smc_zz
		muls	#$1234,d2
		add.l	d2,d0
		swap	d0
		move.w	d0,(a6)+


	IFEQ	ENVMAP_TT
;;;;;;; DO NORMALS NOW

		move.w	(a4)+,d0
		move.w	(a4)+,d1
		move.w	(a4)+,d2		;24									movem.w	(a5)+,d0-d2

;	x'' = x * xx + y * xy + z * xz									lea		xxtozz,a4
		move.w	a0,d3			;4
		muls	d0,d3		;52
		move.w	a1,d4			;4
		muls	d1,d4		;52
		add.l	d4,d3			;8
		move.w	a2,d4			;4
		muls	d2,d4		;60
		add.l	d4,d3			;8

;		asr.l	#1,d3
;		swap	d3				;4								; can be removed	
;		add.w	#45<<7,d3			;4							; can be removed
;		and.w	#%1111111110000000,d3
;		move.w	d3,(a6)+		;8			208					; can be removed

		swap	d3
		add.w	#45<<8,d3
		sub.b	d3,d3
		asr.w	d3
		move.w	d3,(a6)+


;	y'' = x * yx + y * yy + z * yz
		move.w	a3,d3
		muls	d3,d0		;54
.smc_yy2
		muls	#$1234,d1		;50
.smc_yz2
		muls	#$1234,d2		;52
		add.l	d1,d0			;8
		add.l	d2,d0			;8

;		asr.l	#1,d0
;		swap	d0				;4
;.smc_text_y
;		add.w	#45<<7,d0			;4
;		and.w	#%1111111110000000,d0
;		move.w	d0,(a6)+		;8	--> 	188 --> 396

		swap	d0
		add.w	#45<<8,d0
		sub.b	d0,d0
		asr.w	d0
		move.w	d0,(a6)+



	ELSE
			lea		4(a6),a6
	ENDC
	dbra	d7,.rotate
	jmp		.cont
.skipvertex
	IFEQ	ENVMAP_TT
		lea		6(a4),a4
	ENDC
		lea		10(a6),a6
		lea		6(a5),a5
	dbra	d7,.rotate

.cont
	rts

; this takes the rotation matrix, and inverts it, so we have an inverted camera matrix
	; normal:
	;	|	cosBcosC		cosCsinAsinB - cosAsinC		cosAcosCsinB + sinAsinC
	;	|	cosBsinC		cosAcosC + sinAsinBsinC		cosAsinBsinC - cosCsinA
	;	|	-sinB			cosBsinA					cosAcosB 

	; inverse:
	;	|	cosBcosC					cosBsinC					-sinB
	;	|	cosCsinAsinB - cosAsinC		cosAcosC + sinAsinBsinC		cosBsinA	
	;	|	cosAcosCsinB + sinAsinC		cosAsinBsinC - cosCsinA		cosAcosB 

	; thus now:
	;	x * xx + y * yx + z*zx
	;	x * xy + y * yy + z*zy
	;	x * xz + y * yz + z*zz

	; with:
	; a0	=	xx
	; a1	=	xy
	; a2	=	xz
	; a3	=	yx
	; a4	=	yy

	; camera can be modelled as -2048 = z

cullFacesPolygon
	move.w	#31*-1024,d5			;z
	move.w	_zx_polygon,d6
	muls.w	d5,d6
	swap	d6

	move.w	_zy_polygon,d4
	muls.w	d5,d4				;zy
	swap	d4
	move.w	d4,a5				; save

	move.w	_zz_polygon,d4
	muls.w	d5,d4				;zz
	swap	d4

	; d6 = z*zx
	; a5 = z*zy
	; d4 = z*zz
;	lea		sourceFacesp,a0
;	lea		destFacesp,a1
	move.l	currentSourceFacesPointer,a0
	move.l	currentDestFacesPointer,a1
	moveq	#1,d7
;	move.w	number_of_facesp,d3
	move.w	current_number_of_faces,d3
	subq.w	#1,d3
determineCull
	move.w	(a0)+,d0	;source x
	move.w	(a0)+,d1	;source y
	move.w	(a0)+,d2	;source z

	sub.w	d6,d0		;camera z*zx
	sub.w	a5,d1		;camera	z*zy
	sub.w	d4,d2		;camera z*zz

	muls	(a0)+,d0
	muls	(a0)+,d1
	muls	(a0)+,d2

	add.l	d1,d0
	add.l	d2,d0
	blt		.notVisible
.visible
		move.l	(a0)+,a2
		move.w	d7,(a2)
		move.l	(a0)+,a2
		move.w	d7,(a2)
		move.l	(a0)+,a2
		move.w	d7,(a2)
		move.w	d7,(a1)
		IFEQ	SEP_UV
		lea		26(a1),a1
		ELSE
		lea		14(a1),a1
		ENDC

		dbra	d3,determineCull
		rts

.notVisible
		lea		3*4(a0),a0
		IFEQ	SEP_UV
			lea		26(a1),a1
		ELSE
			lea		14(a1),a1
		ENDC
		dbra	d3,determineCull
		rts


; now that we have a list of faces, destFaces, we can sort them
sortFaces
	; destfaces: 
	;	dc.w	> 0 if visible
	;	dc.l	point1
	;	dc.l	point2
	;	dc.l	point3
;	lea		destFacesp,a0
	move.l	currentDestFacesPointer,a0
;	lea		localList,a6
	move.l	localListPointer,a6
;	move.w	number_of_facesp,d7
	move.w	current_number_of_faces,d7
	move.w	#-1,d6					;nr of faces
	subq.w	#1,d7
.next
	sub.w	#1,(a0)+
	blt		.skip
		; so its visible, get the z values
		movem.l	(a0),a1-a3				; a1,a2,a3 for the 3 points
		move.w	4(a1),d0			;z1
		add.w	4(a2),d0			;z2
		add.w	4(a3),d0			;z3
		move.w	d0,(a6)+			;store z
		move.l	a0,(a6)+			;store pointer
		addq.w	#1,d6				;add to face
.skip
	IFEQ	SEP_UV
		lea		24(a0),a0
	ELSE
		lea		12(a0),a0
	ENDC
	dbra	d7,.next
	move.w	d6,nr_faces_to_draw
	rts


nr_faces_to_draw	dc.w	0
localListPointer	ds.l	1
localList	ds.b	6*200



doQuickSort
	; make this list into a z,pointer list, for sorting
	lea		-6(a6),a1
	move.l	localListPointer,a0
;	lea		localList,a0			; head
	lea		quickSort,a3
	jsr		(a3)
	rts


quickSort
; partition
;	if lo < hi; ommitted, because is checked before calling quicksort
	; pivot := A[lo + (hi - lo) / 2]			;a0 is lo, a1 is hi, lo is 0
	move.l	a0,d0					
	add.l	a1,d0
	lsr.l	#1,d0				; if even, ok, if uneven, we're fucked
	btst	#0,d0				; test last bit, to check if uneven
	beq		.ok					; if we're 0, we're good
		subq.w	#3,d0			; go back 1 spot
.ok
	move.l	d0,a2
	move.w	(a2),d7				; pivot element!

	move.l	a0,d0				;	save pointers
	move.l	a1,d1				;

.loopForever
	subq.l	#6,a0				;    i := lo - 1
	addq.l	#6,a1				;    j := hi + 1

.loopi							;do
	addq.l	#6,a0				;		i:= i + 1
	cmp.w	(a0),d7				;while	pivot >= A[i]
	bgt		.loopi

.loopj							;do
	subq.l	#6,a1				;		j:= j--
	cmp.w	(a1),d7				;while	pivot <= A[i]
	blt		.loopj		

	cmp.l	a0,a1
	blt		.noSwap
	move.w	(a0),d6				; z						
	move.w	(a1),(a0)+			; replace z				
	move.w	d6,(a1)+									
	move.l	(a0),d6				; pointer				
	move.l	(a1),(a0)+			; replace pointer		
	move.l	d6,(a1)+									

	lea		-12(a1),a1			; restore ptr

.noSwap
	cmp.l	a0,a1				; optimized check
	bge		.loopForever

	cmp.l	d0,a1				; if lo < hi
	ble		.qsort_right

.qsort_left
	move.l	d1,-(sp)
	move.l	a0,-(sp)
	move.l	d0,a0
	jsr		(a3)				; quicksort(A, lo, p)
	move.l	(sp)+,a0
	move.l	(sp)+,d1

.qsort_right
	cmp.l	a0,d1
	ble		.end

	move.l	d1,a1
	jsr		(a3)
.end
	rts	



;number_of_faces		dc.w	2
;
;sourceFaces
;	dc.w	-40*4,-25*4,0		; vertex for comparison
;	dc.w	0,0,-32000			; face normal
;	dc.l	currentVertices		; source vertex for marking 1
;	dc.l	currentVertices+8	; source vertex for marking 1
;	dc.l	currentVertices+16	; source vertex for marking 1
;
;	dc.w	-40*4,-25*4,0		; vertex for comparison
;	dc.w	0,0,-32000			; face normal
;	dc.l	currentVertices+8	; source vertex for marking 1
;	dc.l	currentVertices+16	; source vertex for marking 1
;	dc.l	currentVertices+24	; source vertex for marking 1
;
;destFaces
;	dc.w	0
;	dc.l	point3,point2,point1		; --> proper order top-> bot = p3,p2,p1
;	dc.w	0
;	dc.l	point2,point3,point4		; --> proper order top-> bot = p3,p2,p1
;
;
;ddd equ	32768-1
;
;currentNormals	
;
;				dc.w	-ddd,-ddd,-ddd		;1
;				dc.w	ddd,-ddd,-ddd		;2
;				dc.w	-ddd,ddd,-ddd		;3
;				dc.w	ddd,ddd,-ddd		;4
;
;currentVertices	
;
;				dc.w	0,-40*4,-25*4,8				;  1.................2
;				dc.w	0,41*4,-25*4,8				;	 .....
;				dc.w	0,-40*4,26*4,8				;		  .....     .
;												;			   ......3
;
;				dc.w	0,41*4,26*4,8				;	1...
;													;	.  ......        
;													;	.        .......
;													;  4.................3
;
;
;points
;point1	dc.w	54,4,84<<7,115<<7
;point2	dc.w	4,4,175<<7,115<<7
;point3	dc.w	64,54,84<<7,64<<7
;point4	dc.w	4,54,175<<7,64<<7
;
;
;trianglePointers	dc.l	point3,point2,point1		; --> proper order top-> bot = p3,p2,p1
;					dc.l	point2,point3,point4		; --> proper order top-> bot = p3,p2,p1


;nr_of_vertices	dc.w	verticesnr
	include	gfx/textmap/triangle2.s		;2.6k
	include	gfx/textmap/square2.s
;	include	gfx/textmap/torus13.s

	IFEQ	POLYGON_TORUS_SELECT
	include	gfx/textmap/torus12.s
	ELSE
	include	gfx/textmap/torus14.s
;	include	gfx/textmap/torus15.s
	ENDC
	include gfx/textmap/cube5.s	
	include	gfx/textmap/caltrop10.s

;	include	gfx/textmap/triangle.s

;	include	gfx/textmap/square.s

;	include	gfx/textmap/weird.s
;	include	gfx/textmap/cube3.s



;	include	gfx/textmap/concave5b.s
;	include	gfx/textmap/concave3.s
;	include	gfx/textmap/object4.s
;	include	gfx/textmap/object2z.s


	SECTION DATA

	IFEQ	STANDALONE
_sintable512	
	include	"data/sintable_amp32768_steps512.s"
	ENDC

;tapetext incbin	"data/tape/tapetext.neo"

;text1	incbin	"gfx/omg!/omg!.neo"
;text2	incbin	"gfx/omg!/omg!.neo"

text1	
text2
;cubeText
;	incbin	"gfx/lava4.neo"
;	incbin	"gfx/textmap/square1.neo"
;	incbin	"gfx/textmap/square2.neo"
;	incbin	"gfx/textmap/text_caltropa.neo"
;	incbin	"gfx/textmap/testcube.neo"
;	incbin	"gfx/omg!/omg!.neo"

;caltropText
;	incbin	"gfx/textmap/caltrop/text_caltropa.neo"
	


	IFEQ	STANDALONE
torusText
	incbin	"gfx/c2p/hm_proper3.neo"				; modmate change palette here
	ENDC


torusTextcrk
heightmapcrk		
	incbin	"gfx/c2p/hm_proper3.crk"
	even

cubeTextcrk
	incbin	"gfx/textmap/lava4.crk"
	even

caltropTextcrk
	incbin	"gfx/textmap/caltrop/text_caltropa2.crk"
	even



; fill screen with 8x8 blocks, this is 40x25
; so basically we draw diagonals, so we should use unrolled loops, or not

xposTable
.x set 0
	REPT 20
		dc.w	.x
		dc.w	.x+1
.x set .x+8
	ENDR
	REPT 20
		dc.w	-1
	ENDR


currentX	dc.w	0

STATIC_WAIT	equ 24     ; orig. 32 NILS
STATIC_WAIT2	equ 16 ; orig. 32 CHECK DIS OUT


fd	macro
	subq.w	#1,polyTranswaiter\1
	bge		polyTransskip\@
		move.w	#1,polyTranswaiter\1
		add.w	#2,open\1Off
opensmc\1
		cmp.w	#16,open\1Off
		ble		.ok\@
			move.w	#16,open\1Off
			move.w	#0,open\1Done
.ok\@
		lea		open\1List,a0
		add.w	open\1Off,a0
		move.w	(a0),timer_b_open\1+2
polyTransskip\@
	endm

diagTrans
	pushall
	addq.w	#1,$466.w
    addq.w	#1,cummulativeCount
	addq.w	#1,vblcount
	subq.w	#1,effect_vbl_counter


		clr.b	$fffffa1b.w			;Timer B control (stop)
		bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
		bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
		move.l	#timer_b_open_curtain_stable_bars_poly,$120.w
		move.b	#188,$fffffa21.w		;Timer B data
		move.b	#4,$fffffa1b.w			;Timer B control (delay mode)
		bclr	#3,$fffffa17.w			;Automatic end of interrupt

	move.w	#0,$ffff8240

	IFNE	STANDALONE
		jsr		replayMymDump
	ENDC

			fd 1
			fd 2
			fd 3
			fd 4
			fd 5

			jsr		checkForstuff



	popall	

	rte
polyTranswaiter1	dc.w	STATIC_WAIT+13*1
polyTranswaiter2	dc.w	STATIC_WAIT+13*3
polyTranswaiter3	dc.w	STATIC_WAIT+13*0
polyTranswaiter4	dc.w	STATIC_WAIT+13*4
polyTranswaiter5	dc.w	STATIC_WAIT+13*2

open1Done	dc.w	1
open2Done	dc.w	1
open3Done	dc.w	1
open4Done	dc.w	1
open5Done	dc.w	1

open1Off	dc.w	0
open2Off	dc.w	0
open3Off	dc.w	0
open4Off	dc.w	0
open5Off	dc.w	0



checkForstuff
			move.w	open1Done,d0
			add.w	open2Done,d0
			add.w	open3Done,d0
			add.w	open4Done,d0
			add.w	open5Done,d0
			bne		.notDone
;				move.b	#0,$ffffc123			;; replace staticwait_2
				move.w	#STATIC_WAIT2+13*2,polyTranswaiter1
				move.w	#STATIC_WAIT2+13*4,polyTranswaiter2
				move.w	#STATIC_WAIT2+13*3,polyTranswaiter3
				move.w	#STATIC_WAIT2+13*0,polyTranswaiter4
				move.w	#STATIC_WAIT2+13*1,polyTranswaiter5
				move.w	#$4e75,checkForstuff
				move.w	#16+16,opensmc1+2
				move.w	#16+16,opensmc2+2
				move.w	#16+16,opensmc3+2
				move.w	#16+16,opensmc4+2
				move.w	#16+16,opensmc5+2
				move.w	#16+16,opensmc1+12
				move.w	#16+16,opensmc2+12
				move.w	#16+16,opensmc3+12
				move.w	#16+16,opensmc4+12
				move.w	#16+16,opensmc5+12
.notDone
	rts

open1List			;352 -> $222	
	dc.w	$352
	dc.w	$352
	dc.w	$342
	dc.w	$342
	dc.w	$343
	dc.w	$343
	dc.w	$343
	dc.w	$333
	dc.w	$333

	dc.w	$333
	dc.w	$444
	dc.w	$444
	dc.w	$555
	dc.w	$555
	dc.w	$666
	dc.w	$666
	dc.w	$777

open2List			; $314 -> 444
	dc.w	$573
	dc.w	$573
	dc.w	$564
	dc.w	$564
	dc.w	$564
	dc.w	$564
	dc.w	$554
	dc.w	$555
	dc.w	$555

	dc.w	$555
	dc.w	$555
	dc.w	$555
	dc.w	$555
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$777

open3List
	dc.w	$777	;$777 -> $333
	dc.w	$777
	dc.w	$666
	dc.w	$666
	dc.w	$555
	dc.w	$555
	dc.w	$444
	dc.w	$444
	dc.w	$444

	dc.w	$444
	dc.w	$444
	dc.w	$444
	dc.w	$555
	dc.w	$555
	dc.w	$666
	dc.w	$666
	dc.w	$777

open4List			; $240 -> $555
;	dc.w	$621
;	dc.w	$631
;	dc.w	$642
;	dc.w	$643
;	dc.w	$653
;	dc.w	$654
;	dc.w	$664
;	dc.w	$665
;	dc.w	$666

	dc.w 	$752
	dc.w 	$753
	dc.w 	$762
	dc.w 	$762
	dc.w 	$665
	dc.w 	$665
	dc.w 	$666
	dc.w 	$666
	dc.w  	$666

	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$777
	dc.w	$777
; $640,$134,$710,$240,$444
open5List			;$751 ->$444
	dc.w	$751
	dc.w	$752
	dc.w	$652
	dc.w	$653
	dc.w	$553
	dc.w	$554
	dc.w	$554
	dc.w	$555
	dc.w	$555

	dc.w	$555
	dc.w	$555
	dc.w	$555
	dc.w	$666
	dc.w	$666
	dc.w	$666
	dc.w	$777
	dc.w	$777



timer_b_open_curtain_stable_bars_poly

		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		movem.l	d1-d2/a0,-(sp)
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		move.l	a1,-(sp)
		dcb.w	59-6,$4e71
timer_b_open1
		move.w	#$640,$ffff8240

		move.l	(sp)+,a1
		movem.l	(sp)+,d1-d2/a0
		clr.b	$fffffa1b.w	
		move.l	#timer_b_open2a,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte

timer_b_open2a

		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		movem.l	d1-d2/a0,-(sp)
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		move.l	a1,-(sp)
		dcb.w	59-6,$4e71
timer_b_open2
		move.w	#$134,$ffff8240

		move.l	(sp)+,a1
		movem.l	(sp)+,d1-d2/a0
		clr.b	$fffffa1b.w	
		move.l	#timer_b_open3a,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte


timer_b_open3a

		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		movem.l	d1-d2/a0,-(sp)
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		move.l	a1,-(sp)
		dcb.w	59-6,$4e71
timer_b_open3
		move.w	#$710,$ffff8240

		move.l	(sp)+,a1
		movem.l	(sp)+,d1-d2/a0
		clr.b	$fffffa1b.w	
		move.l	#timer_b_open4a,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte

timer_b_open4a

		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		movem.l	d1-d2/a0,-(sp)
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		move.l	a1,-(sp)
		dcb.w	59-6,$4e71
timer_b_open4
		move.w	#$240,$ffff8240

		move.l	(sp)+,a1
		movem.l	(sp)+,d1-d2/a0
		clr.b	$fffffa1b.w	
		move.l	#timer_b_open5a,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte


timer_b_open5a
		movem.l	d1-d2/a0,-(sp)

		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
	
		lea	$ffff8209.w,a0			;Hardsync
		moveq	#127,d1
.sync:		tst.b	(a0)
		beq.s	.sync
		move.b	(a0),d2
		sub.b	d2,d1
		lsr.l	d1,d1
		clr.b	$fffffa1b.w			;Timer B control (stop)

		move.l	a1,-(sp)
		dcb.w	59-6,$4e71
timer_b_open5
		move.w	#$444,$ffff8240

		move.l	(sp)+,a1
		movem.l	(sp)+,d1-d2/a0
		clr.b	$fffffa1b.w	
		move.l	#timer_b_close_curtain_stable,$120.w
		move.b	#38,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
		move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
		rte



timer_b_close
	move.w	#$000,$ffff8240
	clr.b	$fffffa1b.w			;Timer B control (stop)
	rte







	IFEQ	STANDALONE
; if we want to be really anal, we can generate these things
TAB1:
	DC.B $00,$00,$00,$00		;0
	DC.B $C0,$00,$00,$00		;4
	DC.B $00,$C0,$00,$00		;8
	DC.B $C0,$C0,$00,$00		;12
	DC.B $00,$00,$C0,$00		;16
	DC.B $C0,$00,$C0,$00		;20
	DC.B $00,$C0,$C0,$00		;24
	DC.B $C0,$C0,$C0,$00		;28
	DC.B $00,$00,$00,$C0		;32
	DC.B $C0,$00,$00,$C0		;36
	DC.B $00,$C0,$00,$C0		;40
	DC.B $C0,$C0,$00,$C0		;44
	DC.B $00,$00,$C0,$C0		;48
	DC.B $C0,$00,$C0,$C0		;52
	DC.B $00,$C0,$C0,$C0		;56
	DC.B $C0,$C0,$C0,$C0		;60
TAB2:
	DC.B $00,$00,$00,$00		;0
	DC.B $30,$00,$00,$00		;4
	DC.B $00,$30,$00,$00		;8
	DC.B $30,$30,$00,$00		;12
	DC.B $00,$00,$30,$00		;16
	DC.B $30,$00,$30,$00		;20
	DC.B $00,$30,$30,$00		;24
	DC.B $30,$30,$30,$00		;28
	DC.B $00,$00,$00,$30		;32
	DC.B $30,$00,$00,$30		;36
	DC.B $00,$30,$00,$30		;40
	DC.B $30,$30,$00,$30		;44
	DC.B $00,$00,$30,$30		;48
	DC.B $30,$00,$30,$30		;52
	DC.B $00,$30,$30,$30		;56
	DC.B $30,$30,$30,$30		;60
TAB3:
	DC.B $00,$00,$00,$00		;0
	DC.B $0C,$00,$00,$00		;4
	DC.B $00,$0C,$00,$00		;8
	DC.B $0C,$0C,$00,$00		;12
	DC.B $00,$00,$0C,$00		;16
	DC.B $0C,$00,$0C,$00		;20
	DC.B $00,$0C,$0C,$00		;24
	DC.B $0C,$0C,$0C,$00		;28
	DC.B $00,$00,$00,$0C		;32
	DC.B $0C,$00,$00,$0C		;36
	DC.B $00,$0C,$00,$0C		;40
	DC.B $0C,$0C,$00,$0C		;44
	DC.B $00,$00,$0C,$0C		;48
	DC.B $0C,$00,$0C,$0C		;52
	DC.B $00,$0C,$0C,$0C		;56
	DC.B $0C,$0C,$0C,$0C		;60
TAB4:
	DC.B $00,$00,$00,$00		;0
	DC.B $03,$00,$00,$00		;4
	DC.B $00,$03,$00,$00		;8
	DC.B $03,$03,$00,$00		;12
	DC.B $00,$00,$03,$00		;16
	DC.B $03,$00,$03,$00		;20
	DC.B $00,$03,$03,$00		;24
	DC.B $03,$03,$03,$00		;28
	DC.B $00,$00,$00,$03		;32
	DC.B $03,$00,$00,$03		;36
	DC.B $00,$03,$00,$03		;40
	DC.B $03,$03,$00,$03		;44
	DC.B $00,$00,$03,$03		;48
	DC.B $03,$00,$03,$03		;52
	DC.B $00,$03,$03,$03		;56
	DC.B $03,$03,$03,$03		;60

	include	lib/cranker.s
	ENDC


calcFade
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a2)
	move.l	a2,a0
	lea		32(a2),a2
	move.w	#8-1,d7

.loop
		lea		whitePal,a1		; end pal
		move.w	#16,d0			; 16 colors
		jsr		fadePalzz
		lea		32(a0),a0
		lea		32(a2),a2
	dbra	d7,.loop
	rts

whitePal
	rept 16
		dc.w	$777
	endr

;(96)6 blocks in, 42 lines
;(256)-> 10 blocks, 166 end --> 124 lines

;============== ST palette fade 8-steps ================
;in:	a0.l	start palette
;	a1.l	end palette
;	a2.l	destination palette
;	d0.w	number of colours to fade
;out:	start palette overwritten one step closer to end palette
fadePalzz:		
		movem.l	d0-d6/a0-a2,-(sp)

		move.w	d0,d6
		subq.w	#1,d6
.loop:
		move.w	(a0)+,d0			;source
		move.w	(a1)+,d3			;dest
		move.w	d0,d1
		move.w	d0,d2
		move.w	d3,d4
		move.w	d3,d5

		and.w	#$0700,d0
		and.w	#$0700,d3
		and.w	#$0070,d1
		and.w	#$0070,d4
		and.w	#$0007,d2
		and.w	#$0007,d5

.red:		cmp.w	d0,d3
		beq.s	.green
		blt.s	.redsub
		add.w	#$0100,d0
		bra.s	.green
.redsub:	sub.w	#$0100,d0


.green:		cmp.w	d1,d4
		beq.s	.blue
		blt.s	.greensub
		add.w	#$0010,d1
		bra.s	.blue
.greensub:	sub.w	#$0010,d1


.blue:		cmp.w	d2,d5
		beq.s	.store
		blt.s	.bluesub
		addq.w	#$1,d2
		bra.s	.store
.bluesub:	subq.w	#$1,d2

.store:		or.w	d1,d0
		or.w	d2,d0
		move.w	d0,(a2)+

		dbra	d6,.loop

		movem.l	(sp)+,d0-d6/a0-a2
		rts

;pal_text
;	dc.w	$000,$776,$766,$765,$763,$763,$752,$741,$731,$722,$512,$501,$401,$301,$201,$100	
	IFEQ	STANDALONE
		include		lib/lib.s
	ENDC

justDoItPointer	ds.l	1
smfxPointer		ds.l	1
motusPointer	ds.l	1	

motuscrk		incbin	"data/texture/motus.crk"
	even
smfxcrk			incbin	"data/texture/smfx.crk"
	even
justdoitcrk		incbin	"data/texture/justdoit.crk"
	even

	IFEQ	POLYGON_PREP_PANELS
justDoItBuffer	ds.b	200*8*8	;12800
smfxLogoBuffer	ds.b	200*4*8 ;6400
motusLogoBuffer	ds.b	200*5*8	;8000

prepLogos
	lea		justdoit_logo+128+12*8,a0
	lea		justDoItBuffer,a1
	move.w	#200-1,d7
.cp
	REPT 8
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
	lea		12*8(a0),a0
	dbra	d7,.cp

	lea		smfx_logo+128+15*8,a0
	lea		smfxLogoBuffer,a1
	move.w	#200-1,d7
.cp2
		REPT 4
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
		ENDR
		lea		16*8(a0),a0
	
	dbra	d7,.cp2

	lea		motus_logo+128+14*8,a0
	lea		motusLogoBuffer,a1
	move.w	#200-1,d7
.cp3
		REPT 5
			move.l	(a0)+,(a1)+
			move.l	(a0)+,(a1)+
		ENDR
		lea		15*8(a0),a0
	dbra	d7,.cp3

	lea		justDoItBuffer,a0
	lea		smfxLogoBuffer,a1
	lea		motusLogoBuffer,a2
	move.b	#0,$ffffc123

	rts


motus_logo		incbin	"gfx/3d part logos/motuslogo.neo"
smfx_logo		incbin	"gfx/3d part logos/smfxlogo2.neo"
justdoit_logo	incbin	"gfx/3d part logos/justdoitlogo.neo"
	endc

current_texturePointer			ds.l	1
texturepointer_polygon			ds.l	1
texturepointer_polygon2			ds.l	1
texturepointer_polygon3			ds.l	1
divtablepointer_polygon			ds.l	1
canvasPointer_text_polygon		ds.l	1

_currentStepX_polygon			ds.w	1
_currentStepY_polygon			ds.w	1
_currentStepZ_polygon			ds.w	1



	ds.w	130
divTablePivot_polygon
	ds.w	130

current_number_of_faces			dc.w	0
current_number_of_vertices		dc.w	0

currentSourceFacesPointer		ds.l	1
currentVerticesPointer			ds.l	1
currentNormalsPointer			ds.l	1
currentPointsPointer			ds.l	1
currentDestFacesPointer			ds.l	1



; general stuff
    IFEQ	STANDALONE
	SECTION BSS
memBase             ds.b    1024*1024
screenpointer		ds.l	1
screenpointer2		ds.l	1
screen1             ds.l    1
screen2             ds.l    1
effect_vbl_counter	ds.w	1
vblcount			ds.w	1
effectcount			ds.w	1
cummulativeCount	ds.w	1
;currentVertices		ds.w	500
	ENDC


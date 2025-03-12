

;---------------------- LEVEL 1 -------------------  
;extern "dh1:toki/tblimagelevel1",tableinitlv1,64000
;extern "dh1:toki/initenemislv1.dcl",tblinitenemis,64000
;extern "dh1:toki/map/devant1.map",tablevignettepl1,64000
;extern "dh1:toki/map/devant1.blk",vignettepl1,64000
;extern "dh1:toki/map/fond1.blk",vignettepl2,64000
;extern "dh1:toki/map/fond1.map",tablevignettepl2,64000
;extern "dh1:toki/animlv1",GATE,190000

;---------------------- LEVEL 2 -------------------  
;extern "dh1:toki/tblimagelv2",tableinitlv1,64000
;extern "dh1:toki/map/devant2.map",tablevignettepl1,64000
;extern "dh1:toki/map/devant2.blk",vignettepl1,64000
;extern "dh1:toki/map/fond2.blk",vignettepl2,64000
;extern "dh1:toki/map/fond2.map",tablevignettepl2,64000
;extern "dh1:toki/animlv2",GATE,190000

;---------------------- LEVEL 3 -------------------  
;extern "dh1:toki/map/devant3.map",tablevignettepl1,64000
;extern "dh1:toki/map/devant3.blk",vignettepl1,64000
;extern "dh1:toki/map/fond3.blk",vignettepl2,64000
;extern "dh1:toki/map/fond3.map",tablevignettepl2,64000

;---------------------- LEVEL 4 -------------------  
;extern "dh1:toki/map/devant4.map",tablevignettepl1,64000
;extern "dh1:toki/map/devant4.blk",vignettepl1,64000
;extern "dh1:toki/map/fond4.blk",vignettepl2,64000
;extern "dh1:toki/map/fond4.map",tablevignettepl2,64000

;---------------------- LEVEL 5 -------------------  
>extern "dh1:toki/map/devant5.map",tablevignettepl1,64000
>extern "dh1:toki/map/devant5.blk",vignettepl1,64000
>extern "dh1:toki/map/fond5.blk",vignettepl2,64000
>extern "dh1:toki/map/fond5.map",tablevignettepl2,64000


;--------------------------------------------------
>extern "dh1:bande.map",BANDE,64000
>extern "dh1:toki/enemis/piece.map",PIECE,32000
>extern "dh1:toki/enemis/icon.map",ICONA,32000
>extern "dh1:toki/enemis/bulles.map",BULLES,32000

>extern "dh1:tokicor.map",CORPS,64000
>extern "dh1:mort.map",IMAGEMORT,64000
>extern "dh1:tetes2.map",TETES2,64000
>extern "dh1:tirtoki.map",TIRTOKI,64000


tailbpl=[240*176]/8			;tail plan ecran
tailbpb1=[240*368]/8			;tail plan buffer 1
tailbpb2=[240*368]/8			;tail plan buffer 2

GATE=$10000
STARTCODE=$2d680

CORPS=$38b00+4800			;50288
IMAGEMORT=CORPS+50288			;944
TETES2=IMAGEMORT+944			;9792
TIRTOKI=TETES2+9792			;1056
BANDE=TIRTOKI+1056			;2688
PIECE=BANDE+2688			;480
ICONA=PIECE+480				;928
ICONB=ICONA+928				;856
ICONC=ICONB+856				;1024
ICOND=ICONC+1024			;256
BULLES=ICOND+256			;120


;----- pour level 1 --------------------
;vignettepl1=tirtoki+1056		;vignettes 	= 40960
;vignettepl2=vignettepl1+40960		;vignettes 	= 24576
;tablevignettepl1=vignettepl2+24576	;3600
;tablevignettepl2=tablevignettepl1+3600	;3600

;----- pour level 2 --------------------
;vignettepl1=tirtoki+1056		;vignettes 	= 32320
;vignettepl2=vignettepl1+32320		;vignettes 	= 10560
;tablevignettepl1=vignettepl2+10560	;5082
;tablevignettepl2=tablevignettepl1+5082	;5082

;----- pour level 3 --------------------
;vignettepl1=tirtoki+1056		;vignettes= 21600
;vignettepl2=vignettepl1+21600		;vignettes= 14880
;tablevignettepl1=vignettepl2+14880	;13552
;tablevignettepl2=tablevignettepl1+13552;13552

;----- pour level 4 --------------------
;vignettepl1=tirtoki+1056		;vignettes= 25120
;vignettepl2=vignettepl1+25120		;vignettes= 15264
;tablevignettepl1=vignettepl2+15264	;3696
;tablevignettepl2=tablevignettepl1+3696	;3696

;----- pour level 5 --------------------
vignettepl1=BULLES+120			;vignettes= 40640
vignettepl2=vignettepl1+40640		;vignettes= 24288
tablevignettepl1=vignettepl2+24288	;17248
tablevignettepl2=tablevignettepl1+17248	;17248
bufferpl1=tablevignettepl2+17248+480	;buffer 2	= 57600
bufferpl2=bufferpl1+57600		;buffer 2	= 34560


;BITPLANE=bufferpl2+34560+2		;10 bp de 5280	= 52800
;fin=BITPLANE+52800

BITPLANE=$3000				;10 bp de 5280	= 52800

fin=bufferpl2+34560


;------------------------------------------------
	org STARTCODE
	load STARTCODE
debut:
;-----------------------------------------------
J:

;================================================
	move #$4000,$dff09a
	lea $330000,a1
	lea $1000,a0
	move.w #[$10000/4]-1,d0
	trasl:
	move.l (a0)+,(a1)+
	dbf d0,trasl


;================================================

	move #5,LEVEL

	bset #1,$bfe001

	move.l #vignettepl1,a0
	move #16-1,d0
aeff:	clr 0(a0)
	clr 32(a0)
	clr 64(a0)
	clr 96(a0)
	move.w #$ffff,128(a0)
	addq.l #2,a0	
	dbf d0,aeff

	JSR init			
	JSR INITENEMIS
	JSR INITLEVEL1
	BRA WAIT

INITLEVEL1:

	BSR INITPOSITIONENEMIS

	clr.b flagsaut
	clr.b flagtir
	clr.b flagmort
	clr.b flagmortt
	clr.b flagdiag
	clr.b floption
	clr.b option
	clr.w depx
	clr.w depy
	clr newpalette

	moveq #0,d0
	move posmapx,d0
	asr.l #3,d0
	move.l d0,posxb1
	asr #1,d0
	move.l d0,posxb2
	add d0,vposxb1
	asr #1,d0
	add d0,vposxb2
	clr.w xscrolplan1
	clr.w xscrolplan2
	clr.l yscrolplan1
	clr.l yscrolplan2
	JSR INITPLAN1			;initialiser buffer 1 et 2 

	jsr affichermap

	jsr flip
	clr upflag			;fondu vers palette
	move #$ff,downflag
	move #50,d0
pallop:	cmp.b #255,$dff006
	bne.s pallop
	lea newpal51,a1
	move d0,-(sp)
	jsr fondu
	move (sp)+,d0
	dbf d0,pallop
	rts

INITPOSITIONENEMIS:
	lea bobtirdebut,a0		;effacer tout les tirs
	lea bobtirfin,a1
effd:	clr.b (a0)+
	cmp.l a0,a1
	bne.s effd

	move level,d0			;INITIALISER ENEMIS/level
	subq #1,d0
	add d0,d0
	add d0,d0
	jmp tbl_initsp(pc,d0.w)

TBL_INITSP:
bra INTSPLV1
bra INTSPLV2
bra INTSPLV3
bra INTSPLV4
bra INTSPLV5
bra INTSPLV2
;--------
INTSPLV1:
	lea bobtoki,a0
	move #40,xmap(a0)
	move #880,ymap(a0)
	move.b #1,8(a0)
	lea bobbig1,a0
	move #640,xmap(a0)
	move #144,ymap(a0)

	lea bobicon,a0
	move.l #imageicon,20(a0)
	move.b #6,10(a0)		;tir 1 boulle
	move.b #1,9(a0)
	move.b #1,14(a0)		;no option
	move.l #$00fe0350,xmap(a0)

	lea 30(a0),a0
	move.l #imageicon,20(a0)
	move.b #1,10(a0)		;casque
	move.b #1,9(a0)
	move.l #$02c1037f,xmap(a0)
	move.b #0,14(a0)

	lea 30(a0),a0
	move.l #imageicon,20(a0)
	move.b #3,10(a0)		;flammes
	move.b #1,9(a0)
	move.l #$02c401a8,xmap(a0)
	move.b #2,14(a0)

	lea 30(a0),a0
	move.l #imageicon,20(a0)
	move.b #4,10(a0)		;3 boulles
	move.b #1,9(a0)
	move.l #$01420258,xmap(a0)
	move.b #4,14(a0)

	lea 30(a0),a0
	move.l #imageicon,20(a0)
	move.b #2,10(a0)		;nike
	move.b #1,9(a0)
	move.l #$002301c0,xmap(a0)
	move.b #0,14(a0)

	move #0,minposmapx
	move #736+2,maxposmapx
	move #0,minposmapy
	move #912,maxposmapy
	move.w #0+0,posmapx
	move.w #912,posmapy
	move #60,mapingx		;vignette en largeure
	move #57,mapingy		;vignette en hauteur
	move #[[57-11]*60]-1,vposxb1
	move #[[57-11]*60]-1,vposxb2
	move.l #480*11,posyb1
	move.l #480*11,posyb2
	lea bob2,a0

	lea tblinitenemis(pc),a1
	lea tblimage1(pc),a2
	move #60-1,d0			;60 bob
	bra INITSTRUCTURE
tblimage1:
 dc.l IMAGEGATE,IMAGEHERBAMO,IMAGEHERBAMO,IMAGEHERBAMO
 dc.l IMAGETORPEDO
 dc.l IMAGEKILLER,IMAGEKILLER,IMAGEKILLER,IMAGEKILLER
 dc.l IMAGEFLYING,IMAGEFLYING,IMAGEFLYING
 dc.l IMAGEGARNIGAR,IMAGEGARNIGAR,IMAGEGARNIGAR
 dc.l IMAGEWEBSTAMI,IMAGEWEBSTAMI,IMAGEWEBSTAMI
 dc.l IMAGEBLASTUM,IMAGEBLASTUM
 dc.l IMAGEKALGATRO,IMAGEKALGATRO,IMAGEKALGATRO,IMAGEKALGATRO
 dc.l IMAGEWOBALIN,IMAGEWOBALIN,IMAGEKALGATRO,IMAGEWOBALIN
 dc.l IMAGEGEES,IMAGEGEES,IMAGEGEES,IMAGEGEES
 dc.l IMAGEMONTANT,IMAGEROCHER,IMAGEREBORD
 dc.l IMAGEPIQUE,IMAGEPIQUE,IMAGEPIQUE
 dc.l IMAGETREMPLIN,IMAGETREMPLIN,IMAGETREMPLIN,IMAGETREMPLIN
 dc.l IMAGECASCADE,IMAGECASCADE
 dc.l IMAGEGATE,IMAGEGATE,IMAGEGATE,IMAGEGATE,IMAGEGATE,IMAGEGATE
 dc.l IMAGEGATE,IMAGEGATE,IMAGEGATE,IMAGEGATE,IMAGEGATE,IMAGEGATE
 dc.l IMAGEGATE,IMAGEGEES,IMAGEGEES,IMAGETIMAGON
;----------------------------------------------------------------
INTSPLV2:
	lea bobtoki,a0
	move #40,xmap(a0)
	move #512,ymap(a0)
	move.b #1,8(a0)

	move #0,minposmapx
	move #2464+2,maxposmapx
	move #0,minposmapy
	move #912,maxposmapy
	move.w #0,posmapx
	move.w #528,posmapy
	move #154,mapingx		;vignette en largeure
	move #33,mapingy		;vignette en hauteur
	move #[[33-11]*154]-1,vposxb1
	move #[[23-11]*154]-1,vposxb2
	move.l #480*11,posyb1
	move.l #480*11,posyb2

	lea bobicon,a0
	move.l #imageicon,20(a0)
	move.b #4,10(a0)		;tir 3 boulle
	move.b #1,9(a0)
	move.b #4,14(a0)
	move.l #$02420082,xmap(a0)

	lea 30(a0),a0
	move.l #imageicon,20(a0)
	move.b #4,10(a0)		;tir 2 boulle
	move.b #1,9(a0)
	move.b #3,14(a0)
	move.l #$02c40130,xmap(a0)

	lea 30(a0),a0
	move.l #imageicon,20(a0)
	move.b #4,10(a0)		;tir 3 boulle
	move.b #1,9(a0)
	move.b #4,14(a0)
	move.l #$04b6002e,xmap(a0)
	rts
;------------------------------------------------
INTSPLV3:
	lea bobtoki,a0
	move #270,xmap(a0)
	move #128,ymap(a0)
	move.b #1,8(a0)

	move #0,minposmapx
	move #2464+2,maxposmapx
	move #0,minposmapy
	move #1408,maxposmapy
	move.w #15*16,posmapx
	move.w #11*16,posmapy
	move #154,mapingx		;vignette en largeure
	move #88,mapingy		;vignette en hauteur
	move #[[0]*154]-1,vposxb1
	move #[[0]*154]-1,vposxb2
	move.l #480*11,posyb1
	move.l #480*11,posyb2

	rts
;------------------------------------------------
INTSPLV4:
	lea bobtoki,a0
	move #32,xmap(a0)
	move #480,ymap(a0)
	move.b #1,8(a0)

	move #0,minposmapx
	move #1792,maxposmapx
	move #0,minposmapy
	move #528,maxposmapy
	move.w #0*16,posmapx
	move.w #33*16,posmapy
	move #112,mapingx		;vignette en largeure
	move #33,mapingy		;vignette en hauteur
	move #[[33-11]*112]-1,vposxb1
	move #[[33-11]*112]-1,vposxb2
	move.l #480*11,posyb1
	move.l #480*11,posyb2
	rts
;------------------------------------------------
INTSPLV5:
	lea bobtoki,a0
	move #16*2,xmap(a0)
	move #$4b0,ymap(a0)
	move.b #1,8(a0)

	clr.b florage

	move #0,minposmapx
	move #3584,maxposmapx
	move #0,minposmapy
	move #1232,maxposmapy
	move.w #0*16,posmapx
	move.w #77*16,posmapy
	move #224,mapingx		;vignette en largeure
	move #77,mapingy		;vignette en hauteur
	move #[[77-11]*224]-1,vposxb1
	move #[[77-11]*224]-1+14,vposxb2
	move.l #480*11,posyb1
	move.l #480*11,posyb2
	rts
;------------------------------------------------
INITSTRUCTURE:
	movem.l (a1),d1-d3
	movem.l d1-d3,8(a0)
	move.l (a2),20(a0)
	move.l 12(a1),24(a0)
	move.w 16(a1),28(a0)
	lea 30(a0),a0
	lea 18(a1),a1
	addq.l #4,a2
	dbf d0,INITSTRUCTURE
	rts
tblinitenemis:	blk.b 1080,0

;================================================
;============= BOUCLE PRINCIPALE ================
;================================================
wait:

	clr.l addscore
	bsr testscrolling

	jsr testerchangement		;que pour level 1
	jsr afficherfont
	jsr affichermap

	bsr GEREROPTION
	bsr GERERICON

	tst.b flagmort
	bne.s pcolt
	bsr collision		;collision avec enemis/level
	bsr coltirbob		;collision avec tir toki/level
pcolt:
	clr depdecorx
	clr depdecory

	bsr ANIMENEMIS		;animation enemis

	bsr ANIMTOKI
	move depdecorx,d0
	add d0,depx
	move depdecory,d0
	add d0,depy
	tst.b flagmort
	bne.s prelief
	lea bobtoki,a0		;collision toki/relief
	bsr collisionrelief
prelief:
	bsr affichetoki
	bsr gerertirtoki

;	move #$f00,$dff180
	jsr debug
;	move #$000,$dff180

move #$000,$dff180

	tst flagsauver
	beq.s pasauver
	bsr sauver
pasauver:

pause:
	cmp.b #$40,touche
	bne.s paspause
	not.b flagpause
	clr.b touche
paspause:
	tst.b flagpause
	bne.s pause

	cmp.b #$50,touche
	bne.s pasf1
	clr.b option
	lea bobtirtoki,a0
	moveq #5-1,d0
rfa:
	clr.b 9(a0)
	lea 26(a0),a0
	dbf d0,rfa
pasf1:
	cmp.b #$51,touche
	bne.s pasf2
	move.b #1,option
	lea bobtirtoki,a0
	moveq #5-1,d0
rfb:
	clr.b 9(a0)
	lea 26(a0),a0
	dbf d0,rfb
pasf2:
	cmp.b #$52,touche
	bne.s pasf3
	move.b #2,option
	lea bobtirtoki,a0
	moveq #5-1,d0
rfc:
	clr.b 9(a0)
	lea 26(a0),a0
	dbf d0,rfc
pasf3:
	cmp.b #$53,touche
	bne.s pasf4
	move.b #3,option
	lea bobtirtoki,a0
	moveq #10-1,d0
rfd:
	clr.b 9(a0)
	lea 26(a0),a0
	dbf d0,rfd
pasf4:
	cmp.b #$54,touche
	bne.s pasf5
	move.b #4,option
	lea bobtirtoki,a0
	moveq #10-1,d0
rfe:
	clr.b 9(a0)
	lea 26(a0),a0
	dbf d0,rfe
pasf5:

cmp.b #$55,touche
bne.s pasralenti

cva:
cmp.b #200,$dff006
bne.s cva
cvb:
cmp.b #199,$dff006
bne.s cvb
cvc:
cmp.b #198,$dff006
bne.s cvc

pasralenti:

	jsr GERERSCORE

move #$000,$dff180
	jsr flip

	btst #6,$bfe001
	bne wait
end:
	jmp restorer 
toto:		 dc.b 0
flagpause:	 dc.b 0
next:		dc.b 1
 even

LEVEL:	dc.w 	0

;-----------------------------------------------
INITENEMIS:
	move level,d0
	subq #1,d0
	add d0,d0
	add d0,d0
	jmp tableinitenemis(pc,d0.w)
tableinitenemis: 
 bra enemislv1
 bra enemislv2
 bra enemislv3
 bra enemislv4
 bra enemislv5
 bra enemislv6

enemislv1:
	clr.b flagbig

	lea tableinitlv1,a1		;table adresse images
	lea imagegate,a0
	moveq #27-1,d0
	bsr initimage
	lea imageherbamo,a0
	moveq #10-1,d0
	bsr initimage
	lea imagetorpedo,a0
	moveq #6-1,d0
	bsr initimage
	lea imagekiller,a0
	moveq #12-1,d0
	bsr initimage
	lea imageflying,a0
	moveq #12-1,d0
	bsr initimage
	lea imagegarnigar,a0
	moveq #17-1,d0
	bsr initimage
	lea imagewebstami,a0
	moveq #8-1,d0
	bsr initimage
	lea imagetirwebstami,a0
	moveq #4-1,d0
	bsr initimage
	lea imageblastum,a0
	moveq #10-1,d0
	bsr initimage
	lea imagekalgatro,a0
	moveq #22-1,d0
	bsr initimage
	lea imagewobalin,a0
	moveq #8-1,d0
	bsr initimage
	lea imagegees,a0
	moveq #10-1,d0
	bsr initimage
	lea imagegees1,a0
	moveq #2-1,d0
	bsr initimage
	lea imageshartoes,a0
	moveq #16-1,d0
	bsr initimage
	lea imagemontant,a0
	moveq #1-1,d0
	bsr initimage
	lea imagerocher,a0
	moveq #1-1,d0
	bsr initimage
	lea imagerebord,a0
	moveq #1-1,d0
	bsr initimage
	lea imagepique,a0
	moveq #3-1,d0
	bsr initimage
	lea imageboule,a0
	moveq #2-1,d0
	bsr initimage
	lea imagetremplin,a0
	moveq #3-1,d0
	bsr initimage
	lea imagebigtete1,a0
	moveq #28-1,d0
	bsr initimage
	lea imagebigcorp1,a0
	moveq #22-1,d0
	bsr initimage
	lea imagecascade,a0
	moveq #9-1,d0
	bsr initimage
	lea imagetimagon,a0
	moveq #26-1,d0
	bsr initimage
	rts
;-------------------------------------------
enemislv2:
	lea tableinitlv1,a1		;table adresse images
	lea imagekiller,a0
	moveq #12-1,d0
	bsr initimage
	lea imageflying,a0
	moveq #12-1,d0
	bsr initimage
	lea imageshartoes,a0
	moveq #16-1,d0
	bsr initimage
	lea imagegees,a0
	moveq #10-1,d0
	bsr initimage
	lea imagewobalin,a0
	moveq #8-1,d0
	bsr initimage
	lea imagetorpedo,a0
	moveq #6-1,d0
	bsr initimage
	lea imagepoisson,a0
	moveq #6-1,d0
	bsr initimage
	lea imagegabana,a0
	moveq #12-1,d0
	bsr initimage
	lea imagecupper,a0
	moveq #15-1,d0
	bsr initimage
	lea imagerocher,a0
	moveq #1-1,d0
	bsr initimage
	lea imagegmotoi,a0
	moveq #18-1,d0
	bsr initimage
	lea imagebombe,a0
	moveq #4-1,d0
	bsr initimage
	lea imagepmotoi,a0
	moveq #6-1,d0
	bsr initimage
	rts
;-------------------------------------------
ENEMISLV3:
	rts
;-------------------------------------------
ENEMISLV4:
	rts
;-------------------------------------------
ENEMISLV5:
	rts
;-------------------------------------------
ENEMISLV6:
	rts

;-------------------------------------------
initimage:
	move.l (a1),d1
	add.l d1,(a0)
	addq.l #8,a0
	dbf d0,initimage
	lea 4(a1),a1
	rts
;-------------------------------------------
tableinitlv1:blk.b 110,0
;-------------------------------------------
ANIMOPTION:
	lea tbloption1(pc),a1	
	clr.w d1
	move.b 10(a0),d1
	move.b (a1,d1.w),d1
	bne.s ctanopt
	clr.b 10(a0)
	move.b (a1),d1
ctanopt:move.b d1,8(a0)
	addq.b #1,10(a0)

	tst.b 13(a0)			;fini rebond
	beq pasrelief

	movem.l d0-d7/a1-a6,-(a7)

	move.b 11(a0),d0		;DEP X
	ext d0
	move.b 12(a0),d1		;DEP Y
	ext d1
	bsr collisionreliefenemis

	btst #0,d3			;col x ?
	beq.s pcolopx			;non
	neg.b 11(a0)
pcolopx:
	btst #1,d3			;col y ?
	beq.s pcolopy			;non
	move.b 13(a0),12(a0)		;rebond
	addq.b #1,13(a0)		;rebond -1 
	add d2,d1
	move d1,ymap(a0)
pcolopy:
	move.b 11(a0),d1
	ext d1
	add d1,xmap(a0)
	move.b 12(a0),d1
	ext d1
	add d1,ymap(a0)

	move.b 12(a0),d1		;pesanteur
	addq.b #1,d1
	cmp.b #6,d1			;trop forte ?
	ble.s pasplushaut		;non
	move.b #6,d1			;oui
pasplushaut:
	move.b d1,12(a0)
	movem.l (sp)+,d0-d7/a1-a6
	rts
pasrelief:
	move.b 14(a0),d1
	subq.b #1,d1
	bne.s ppgero
	clr.b 24(a0)
	clr.b 9(a0)
ppgero:
	move.b d1,14(a0)
	ext d1
	cmp.b #30,d1
	bpl.s pppgero	
	btst #1,d1
	beq.s pppgero
	bset #6,24(a0)		;option qui flache
pppgero:
	rts
tbloption1:			;PIECES
 dc.b 1,1,1,2,2,2,3,3,3,4,4,4,0
 even
;-----------------------------------------------
GEREROPTION:
	lea boboption,a0
	moveq #10-1,d0
geroptl:tst.b 9(a0)
	beq.s pgero
	bsr animoption
	bsr collisionoption
	move d0,-(sp)
	jsr bob
	move (sp)+,d0
pgero:	lea 30(a0),a0
	dbf d0,geroptl
	rts
;-----------------------------------------------
INITOPTION:
	lea boboption,a1
	moveq #10-1,d7
optloop:
	tst.b 9(a1)			;libre ?
	bne.s pitopt			;non autre
	move.b #1,9(a1)			;ou init option selon d0.w
	move.b #1,8(a1)
	clr.b 10(a1)
	move.b #-1,11(a1)		;dep x	
	move.b #0,12(a1)		;dep y
	move.b #-7,13(a1)		;rebond
	move.b #1,24(a1)		;type
	move.b #50,14(a1)		;delay
	move.l #imagepiece,20(a1)	;image
	move.l xmap(a0),xmap(a1)	;position x,y
	rts
pitopt:	lea 30(a1),a1
	dbf d7,optloop
	rts				;pas d'options de libre
;===============================================
sauver:
ecran=$280000
ecranfin=ecran+40064
	move #$fff,$dff180

	lea $280000,a0
	move #[40064/4]-1,d0
effl:
	clr.l (a0)+
	dbf d0,effl

	lea palettedevant,a0
	lea $280000,a1
	move.w #32-1,d0
jpallop:move.w 2(a0),(a1)
	addq #4,a0
	addq #2,a1
	dbf d0,jpallop

	move.l physique,a0		;sources
	lea $280000+64,a1		;destination

	move #5-1,d0			;nb plan
savelop:move.l a0,a2
	move.l a1,a3
	move #176-1,d1			;nb lignes
savelop1:
	move.l (a2)+,(a3)+ 		;1 lignes
	move.l (a2)+,(a3)+ 
	move.l (a2)+,(a3)+ 
	move.l (a2)+,(a3)+ 
	move.l (a2)+,(a3)+ 
	move.l (a2)+,(a3)+ 
	move.l (a2)+,(a3)+ 

	add.l #12,a3
	addq.l #2,a2
	dbf d1,savelop1

	lea tailbpl(a0),a0
	lea 8000(a1),a1
	dbf d0,savelop

	move #$000,$dff180
	clr flagsauver
	clr nbvbl
	rts

;=======================================================
;=======         ANIMATION ENEMIS                   ====
;=======================================================
ANIMENEMIS:
	move LEVEL,d0		 
	subq #1,d0
	add d0,d0
	add d0,d0
	jmp TABLEAEN(pc,d0.w)
;=======
TABLEAEN:
	bra animlevel1
	bra animlevel2
	bra animlevel3
	bra animlevel4
	bra animlevel5
	bra animlevel6
;------------------------------------------------
ANIMLEVEL1:
	lea bob61,a0
	lea bobtirtimagon,a2
	bsr ANIMTIMAGON
	lea bobtirtimagon,a0
	bsr gerertirtimagon

	lea bob34,a0
	lea PTRANIMBOBDEC1(pc),a6
	bsr ANIMATIONDECORT1
	bsr bob

	lea bob35,a0
	lea PTRANIMBOBDEC2(pc),a6
	bsr ANIMATIONDECORT2
	bsr bob

	lea bob36,a0
	lea PTRANIMBOBDEC3(pc),a6
	bsr ANIMATIONDECORT3
	bsr bob
	lea bob37,a0		;pique 1
	lea bobtirpique1,a2
	bsr ANIMATIONDECORT4
	bsr bob
	lea bobtirpique1,a0
	bsr gerertirpique
	lea bob38,a0		;pique 2
	lea bobtirpique2,a2
	bsr ANIMATIONDECORT4
	bsr bob
	lea bobtirpique2,a0
	bsr gerertirpique
	lea bob39,a0		;pique 3
	lea bobtirpique3,a2
	bsr ANIMATIONDECORT4
	bsr bob
	lea bobtirpique3,a0
	bsr gerertirpique
	lea bob17,a0			;webstami 1
	lea bobtirwesbtami1,a2		;tir webstami 1
	lea PTRANIMBOB17(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bobtirwesbtami1,a0
	bsr gerertirwesbtami

	lea bob18,a0			;webstami 2
	lea bobtirwesbtami2,a2		;tir webstami 2
	lea PTRANIMBOB18(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bobtirwesbtami2,a0
	bsr gerertirwesbtami

	lea bob19,a0			;webstami 3
	lea bobtirwesbtami3,a2		;tir webstami 3
	lea PTRANIMBOB19(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bobtirwesbtami3,a0
	bsr gerertirwesbtami

	lea bob40,a0		;tremplin 1 
	lea bob41,a2		;poid
	bsr ANIMATIONDECORT5
	bsr bob
	lea bob41,a0
	bsr bob

	lea bob42,a0			;tremplin 2 
	lea bob43,a2			;poid
	bsr ANIMATIONDECORT5B
	bsr bob
	lea bob43,a0
	bsr bob

	lea bob44,a0			;jet d'eau 
	lea bob45,a2			;bas du jet d'eau
	lea PTRANIMBOBDEC6(pc),a6
	bsr ANIMATIONDECORT6
	bsr bob
	lea bob45,a0
	bsr bob
	lea bob1,a0
	move.l #imagecascade,20(a0)	;cache du bas
	move.b #9,8(a0)
	move.b #5,24(a0)
	move.l #$018000b1,xmap(a0)
	bsr bob

	lea bob3,a0			;herbamo1
	lea  PTRANIMBOB3(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob4,a0			;herbamo2	
	lea PTRANIMBOB4(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob5,a0			;herbamo3
	lea PTRANIMBOB5(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob6,a0			;torp 1
	lea PTRANIMBOB6(pc),a6
	bsr ANIMATIONTYPE2
	bsr bob

	lea bob7,a0			;killer 1
	lea PTRANIMBOB7(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob8,a0			;killer 2
	lea PTRANIMBOB8(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob9,a0			;killer 3
	lea PTRANIMBOB9(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob10,a0			;killer 4
	lea PTRANIMBOB10(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob11,a0			;flying 1
	lea PTRANIMBOB11(pc),a6
	bsr ANIMATIONTYPE3
	bsr bob

	lea bob12,a0			;flying 2
	lea PTRANIMBOB12(pc),a6
	bsr ANIMATIONTYPE3
	bsr bob

	lea bob13,a0			;flying 3
	lea PTRANIMBOB13(pc),a6
	bsr ANIMATIONTYPE3
	bsr bob

	lea bob14,a0			;garnigar 1
	lea PTRANIMBOB14(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob15,a0			;garnigar 2
	lea PTRANIMBOB15(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob16,a0			;garnigar 3
	lea PTRANIMBOB16(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob20,a0			;BLASTUMS 1
	lea PTRANIMBOB20(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob21,a0			;BLASTUMS 2
	lea PTRANIMBOB21(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob22,a0			;KALGATRO 1
	lea PTRANIMBOB22(pc),a6
	bsr ANIMATIONTYPE4
	bsr bob

	lea bob23,a0			;KALGATRO 2
	lea PTRANIMBOB23(pc),a6
	bsr ANIMATIONTYPE4
	bsr bob

	lea bob24,a0			;KALGATRO 3
	lea PTRANIMBOB24(pc),a6
	bsr ANIMATIONTYPE4
	bsr bob

	lea bob25,a0			;KALGATRO 4
	lea PTRANIMBOB25(pc),a6
	bsr ANIMATIONTYPE4
	bsr bob

	lea bob28,a0			;KALGATRO 5
	lea PTRANIMBOB28(pc),a6
	bsr ANIMATIONTYPE4
	bsr bob

	lea bob26,a0			;WOBALIN 1
	lea bobtir1,a2			;tir WOBALIN 1
	lea PTRANIMBOB26(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bobtir1,a0
	bsr bob

	lea bob27,a0			;WOBALIN 2
	lea bobtir2,a2			;tir WOBALIN 2
	lea PTRANIMBOB27(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bobtir2,a0
	bsr bob

	lea bob29,a0			;WOBALIN 3
	lea bobtir3,a2			;tir WOBALIN 3
	lea PTRANIMBOB29(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bobtir3,a0
	bsr bob

	lea bob33,a0			;GEES 1
	bsr ANIMATIONGEES
	bsr bob

	lea bob30,a0			;GEES 2
	bsr ANIMATIONGEES
	bsr bob

	lea bob31,a0			;GEES 3
	bsr ANIMATIONGEES
	bsr bob

	lea bob32,a0			;GEES 4
	bsr ANIMATIONGEES
	bsr bob

	lea bobshartoes1,a0		;SHARTOES 1
	lea tblshart1nv1(pc),a2
	bsr ANIMATIONSHARTOES

	lea bobshartoes2,a0		;SHARTOES 2
	lea tblshart2nv1(pc),a2
	bsr ANIMATIONSHARTOES

	bsr animationgate

	tst.b flagbig
	beq.s pbig
	bsr animationbig1
	bsr afficherbig
	bsr gerertirbig1
pbig:	tst.b flagbig
	bne.s pasbg
	lea bobtoki,a0
	cmp #540,xmap(a0)
	bmi.s pasbg
	cmp #145,ymap(a0)
	bpl.s pasbg
	move.b #1,flagbig
	move.b #30,bobbig1+25
pasbg:	rts


;------------------------------------------------
;------------------------------------------------
;------------------------------------------------
ANIMLEVEL2:
	lea bob3,a0			;killer 1
	lea PTRANIMBOB3LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob4,a0			;killer 2
	lea PTRANIMBOB4LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob5,a0			;killer 3
	lea PTRANIMBOB5LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob6,a0			;killer 4
	lea PTRANIMBOB6LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob7,a0			;killer 5
	lea PTRANIMBOB7LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob8,a0			;killer 6
	lea PTRANIMBOB8LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob9,a0			;flying 1
	lea PTRANIMBOB9LV2(pc),a6
	bsr ANIMATIONTYPE3
	bsr bob

	lea bob10,a0			;GEES 1
	bsr ANIMATIONGEES
	bsr bob

	lea bob11,a0			;WOBALIN 1
	lea bobtir1,a2			;tir WOBALIN 1
	lea PTRANIMBOB11LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bobtir1,a0
	bsr bob

	lea bob12,a0			;torpedo 1
	lea PTRANIMBOB12LV2(pc),a6
	bsr ANIMATIONTYPE2
	bsr bob

	lea bob13,a0			;torpedo 2
	lea PTRANIMBOB13LV2(pc),a6
	bsr ANIMATIONTYPE2
	bsr bob


	lea bob14,a0			;poisson1
	lea PTRANIMBOB14LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob15,a0			;poisson2
	lea PTRANIMBOB15LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob16,a0			;poisson3
	lea PTRANIMBOB16LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob17,a0			;poisson4
	lea PTRANIMBOB17LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob18,a0			;poisson5
	lea PTRANIMBOB18LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob19,a0			;poisson6
	lea PTRANIMBOB19LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob20,a0			;poisson6
	lea PTRANIMBOB20LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob21,a0			;poisson7
	lea PTRANIMBOB21LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob22,a0			;poisson8
	lea PTRANIMBOB22LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob23,a0			;poisson9
	lea PTRANIMBOB23LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob24,a0			;poisson10
	lea PTRANIMBOB24LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob25,a0			;poisson11
	lea PTRANIMBOB25LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob26,a0			;poisson12
	lea PTRANIMBOB26LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob27,a0			;poisson13
	lea PTRANIMBOB27LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob28,a0			;gabana 1
	bsr ANIMATIONGABANA
	lea bob29,a0			;gabana 2
	bsr ANIMATIONGABANA
	lea bob30,a0			;gabana 3
	bsr ANIMATIONGABANA

	lea bob31,a0			;cupper 1
	lea PTRANIMBOB31LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob32,a0			;cupper 2
	lea PTRANIMBOB31LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob
	lea bob33,a0			;cupper 3
	lea PTRANIMBOB31LV2(pc),a6
	bsr ANIMATIONTYPE1
	bsr bob

	lea bob34,a0
	lea PTRANIMBOB34LV2(pc),a6
	bsr ANIMATIONDECORT2
	bsr bob

	lea bob35,a0			;GMOTOI 1
	bsr ANIMATIONGMOTOI
	lea bob36,a0			;GMOTOI 2
	bsr ANIMATIONGMOTOI
	lea bob37,a0			;GMOTOI 3
	bsr ANIMATIONGMOTOI

	lea bob38,a0			;singe + bombes
	bsr ANIMATIONBOMBE
	bsr bob
	lea bobshartoes2,a0		;3 bombes
	bsr animbombe
	lea bobshartoes2,a0
	bsr bob
	lea 30(a0),a0			;
	bsr bob
	lea 30(a0),a0			;
	bsr bob

	bsr ANIMATIONPMOTOI


	lea bobshartoes1,a0		;SHARTOES
	lea tblshart1nv2(pc),a2
	bsr ANIMATIONSHARTOES

	rts
;-------------------------------------------------
;-------------------------------------------------
PTRANIMBOB3LV2:
 dc.w ga2+30,dr2+30,0
;---
PTRANIMBOB4LV2:
 dc.w ga2+36,dr2+36,0
;---
PTRANIMBOB5LV2:
 dc.w dr2+76,ga2+76,0
;---
PTRANIMBOB6LV2:
 dc.w ga2+30,dr2+30,0
;---
PTRANIMBOB7LV2:
 dc.w dr2+25,ga2+25,0
;---
PTRANIMBOB8LV2:
 dc.w dr2+36,ga2+36,0
;---
PTRANIMBOB9LV2:
 dc.w 0
;---
tblshart1nv2:
 dc.w 174,10
 dc.w 350,10,350-32,20,350+32,20,350,30,350-32,40,350+32,40
;---
PTRANIMBOB11LV2:
 dc.w ga1+5,ga2+10,ga1+5,dr1+5,dr2+10,dr1+5,0
;---
PTRANIMBOB12LV2:
 dc.w ga3+10,ga3+ha1+10,ga3+10,ga3+ba1+10,0
;---
PTRANIMBOB13LV2:
 dc.w ga3+10,ga3+ha1+10,ga3+10,ga3+ba1+10,0
;---
PTRANIMBOB14LV2:
 dc.w ga3+65,dr3+150,ga3+85,0
;---
PTRANIMBOB15LV2:
 dc.w ga3+67,dr3+150,ga3+83,0
;---
PTRANIMBOB16LV2:
 dc.w ga3+87,dr3+150,ga3+63,0
;---
PTRANIMBOB17LV2:
 dc.w ga3+97,dr3+150,ga3+53,0
;---
PTRANIMBOB18LV2:
 dc.w ga3+101,dr3+160,ga3+59,0
;---
PTRANIMBOB19LV2:
 dc.w ga3+111,dr3+160,ga3+49,0
;---
PTRANIMBOB20LV2:
 dc.w ga3+104,dr3+160,ga3+56,0
;---
PTRANIMBOB21LV2:
 dc.w ga3+42,dr3+147,ga3+105,0
;--
PTRANIMBOB22LV2:
 dc.w ga3+68,dr3+163,ga3+95,0
;--
PTRANIMBOB23LV2:
 dc.w ga3+73,dr3+143,ga3+70,0
;-
PTRANIMBOB24LV2:
 dc.w ga3+78,dr3+148,ga3+70,0
;-
PTRANIMBOB25LV2:
 dc.w ga3+113,dr3+156,ga3+43,0
;-
PTRANIMBOB26LV2:
 dc.w ga3+116,dr3+156,ga3+40,0
;-
PTRANIMBOB27LV2:
 dc.w ga3+131,dr3+156,ga3+25,0
;-
PTRANIMBOB31LV2:
 dc.w ga3+ha1+40,ga3+ba2+10,dr3+ba2+10,dr3+ha1+40
 dc.w dr3+ba2+10,ga3+ba2+10
 dc.w 0
;-
PTRANIMBOB34LV2:
 dc.w ga2+42,dr2+42,0
;-------------------------------------------------
;-------------------------------------------------
ANIMLEVEL3:

	rts
;-------------------------------------------------
;-------------------------------------------------
ANIMLEVEL4:
	rts
;-------------------------------------------------
;-------------------------------------------------
ANIMLEVEL5:
	rts
;-------------------------------------------------
;-------------------------------------------------
ANIMLEVEL6:
	rts
;-------------------------------------------------
;-------------------------------------------------



GERERICON:
	lea bobicon,a0
	moveq #6-1,d7
lopic:	tst.b 9(a0)
	beq.L noicon
;-- tester collision --
	lea bobtoki,a5
	move xmap(a5),d0
	move xmap(a0),d2
	move d0,d1
	add 4(a5),d1
	move d2,d3
	add 4(a0),d3
	cmp d0,d3	;xg
	ble.s fvb
	cmp d1,d2	;xd
	bge.s fvb

	move ymap(a5),d0
	move ymap(a0),d2
	move d0,d1
	sub 6(a5),d1
	move d2,d3
	sub 6(a0),d3
	cmp d0,d3	;yh
	bge.s fvb
	cmp d1,d2	;yb
	ble.s fvb

	clr.b 9(a0)
	lea bobtirtoki,a1
	clr.b [26*0]+9(a1)
	clr.b [26*1]+9(a1)
	clr.b [26*2]+9(a1)
	clr.b [26*3]+9(a1)
	clr.b [26*4]+9(a1)
	clr.b [26*5]+9(a1)
	clr.b [26*6]+9(a1)
	clr.b [26*7]+9(a1)
	clr.b [26*8]+9(a1)
	clr.b [26*9]+9(a1)
	move.b 14(a0),option
fvb:
	clr d0
	move.b 10(a0),d0
	add d0,d0
	add d0,d0
	jmp animicon(pc,d0.w)
cticon: 
	move.w d7,-(sp)
	bsr bob
	move.w (sp)+,d7
noicon:	lea 30(a0),a0
	dbf d7,lopic
	rts
animicon:
 bra aicon1	;? ne pas utiliser
 bra aicon1	;casque	
 bra aicon2	;nike
 bra aicon3	;flamme
 bra aicon4	;tir 3 boulles
 bra aicon5	;tir 2 boulles
 bra aicon6	;tir 1 boulles
;----------------
aicon1:		;de 1 a 4
	addq.b #1,12(a0)
	and.b #3,12(a0)
	bne.L cticon
	and.b #3,11(a0)
	addq.b #1,11(a0)
	move.b 11(a0),8(a0)
	move.b #3,24(a0)
	jmp cticon(pc)

aicon2:		;de 5 a 8
	addq.b #1,12(a0)
	and.b #3,12(a0)
	bne.L cticon
	and.b #3,11(a0)
	addq.b #1+4,11(a0)
	move.b 11(a0),8(a0)
	move.b #3,24(a0)
	jmp cticon(pc)

aicon3:		;de 9 a 10
	addq.b #1,12(a0)
	and.b #3,12(a0)
	bne cticon
	and.b #1,11(a0)
	add.b #9,11(a0)
	move.b 11(a0),8(a0)
	move.b #3,24(a0)
	jmp cticon(pc)

aicon4:		;de 11 a 12
	addq.b #1,12(a0)
	and.b #3,12(a0)
	bne cticon
	and.b #1,11(a0)
	add.b #11,11(a0)
	move.b 11(a0),8(a0)
	move.b #3,24(a0)
	jmp cticon(pc)

aicon5:		;de 13 a 14
	addq.b #1,12(a0)
	and.b #3,12(a0)
	bne cticon
	and.b #1,11(a0)
	add.b #13,11(a0)
	move.b 11(a0),8(a0)
	move.b #3,24(a0)
	jmp cticon(pc)

aicon6:		;de 15 a 16
	addq.b #1,12(a0)
	and.b #3,12(a0)
	bne cticon
	and.b #1,11(a0)
	add.b #15,11(a0)
	move.b 11(a0),8(a0)
	move.b #3,24(a0)
	jmp cticon(pc)
;-------------------------------------------------
MORTTIMAGON:
	tst.b 24(a0)		;il est mort
	beq.s vvbn		;oui
	lea tblmortig(pc),a1	;non il meur
	btst #6,25(a0)
	beq.s jko
	lea tblmortid(pc),a1
jko:	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s vbn
	clr.b 24(a0)
	clr.b [30*0]+9(a2)	;plus de tirs
	clr.b [30*1]+9(a2)
	clr.b [30*2]+9(a2)
	clr.b [30*0]+24(a2)
	clr.b [30*1]+24(a2)
	clr.b [30*2]+24(a2)
	move.b #1,[30*0]+28(a2)
	move.b #1,[30*1]+28(a2)
	move.b #1,[30*2]+28(a2)
	move.b #1,[30*1]+28(a0)	;coquille
	move.b #1,[30*2]+28(a0)
	rts
vbn:	move.b d0,8(a0)
	addq.b #1,10(a0)
	bsr bob
vvbn:	rts
tblmortig:
 dc.b 16,16,16,16,16,17,17,17,17,17,18,18,18,18,18,0
tblmortid:
 dc.b 7,7,7,7,7,8,8,8,8,8,9,9,9,9,9,0
 even
;----
ANIMTIMAGON:
	lea bobtoki,a5
	tst.b 28(a0)
	bne.L MORTTIMAGON
	btst #7,25(a0)		;deja eclos ?
	bne ptimoeuf		;oui

;-- tester si dans fenetre --	
	move xmap(a0),d0
	move d0,d2
	add 4(a0),d2
	move posmapx,d4
	cmp d2,d4
	bge pastimapp
	add #224,d4
	cmp d0,d4
	ble pastimapp
	move ymap(a0),d1
	move d1,d3
	sub 6(a0),d3
	move posmapy,d5
	cmp d3,d5
	ble pastimapp
	sub #176,d5
	cmp d1,d5
	bge pastimapp

	move.w xmap(a5),d0	;x toki
	move.w xmap(a0),d1	;x timagon
	sub d0,d1
	bpl.s dhj
	neg d1
dhj:
	move.b 13(a0),d0	;distance x
	ext d0
	cmp d0,d1		;tout pret ?
	bpl pastimapp 		;non 

	lea bob62,a1		;oui init coquille d
	move.l xmap(a0),xmap(a1)
	addq #4,xmap(a1)
	move.b #22,8(a1)
	move.b #1,9(a1)
	move.b #4,10(a1)	;dir x
	move.b #1,11(a1)	;dir y
	move.b #3,24(a1)
	move.l #imagetimagon,20(a1)
	lea bob63,a1		;oui init coquille g
	move.l xmap(a0),xmap(a1)
	move.b #21,8(a1)
	move.b #1,9(a1)
	move.b #-4,10(a1)	;dir x
	move.b #1,11(a1)	;y
	move.b #3,24(a1)

	move.l #imagetimagon,20(a1)
	move.b #11,8(a0)	;init pos timagon	
	clr.b 25(a0)		;appar vers <-
	bset #7,25(a0)		;il apparait
	sub #12,xmap(a0)	;ajuster xmap
	move.b 27(a0),26(a0)	;cpt deplacement
	clr.b 12(a0)		;cpt animation
	move xmap(a5),d0
	cmp xmap(a0),d0
	bmi.s eru
	bset #6,25(a0)
	move.b #1,8(a0)
eru:	bra.s ptimoeuf
pastimapp:
	bra bougeroeuf		;gerer oeuf

ptimoeuf:			;gerer timagon
	btst #5,25(a0)		;timagon tir ?
	beq ptimt		;oui
	bsr timagontir
	bra ctatim
ptimt:	move xmap(a5),d7
	move xmap(a0),d6
	add 4(a5),d7
	lea timagd(pc),a1
	btst #6,25(a0)		;vers droite ?
	bne.s abi		;oui

	lea timagg(pc),a1	;deplacer v gauche
	cmp d7,d6
	bpl.s abe
	subq #1,xmap(a0)
	subq.b 	#1,26(a0)
	beq.s abj
	subq #1,xmap(a0)
	subq.b #1,26(a0)
	beq.s abj
abe:
	subq #1,xmap(a0)
	subq.b #1,26(a0)
	bgt.s abh		;fin dir ?
abj:	bset #6,25(a0)		;chg direction
	move.b 27(a0),26(a0)
	bra.s abh
abi:
	sub 4(a5),d7
	add 4(a0),d6
	cmp d7,d6		;deplacer v droite
	bmi.s babe
	addq #1,xmap(a0)
	subq.b 	#1,26(a0)
	beq.s babj
	addq #1,xmap(a0)
	subq.b #1,26(a0)
	beq.s babj
babe:	addq #1,xmap(a0)	;deplacer v droite
	subq.b #1,26(a0)
	bgt.s abh		;fin dir ?
babj:	bclr #6,25(a0)		;chg direction
	move.b 27(a0),26(a0)

abh:					;animation timagon
	move xmap(a5),d0		;tester si il tir
	add 4(a5),d0
	move xmap(a0),d1
	sub d0,d1
	bmi.s htrtir
	btst #6,25(a0)
	bne.s htrtir
	cmp #145,d1
	bpl.s htrtir
	tst.b [30*2]+9(a2)
	bne.s htrtir
	bset #5,25(a0)
	clr.b 12(a0)
	bra.s ctatim
htrtir:
	btst #6,25(a0)
	beq.s bhtrtir
	move xmap(a5),d0
	move xmap(a0),d1
	add 4(a0),d1
	sub d1,d0
	bmi.s bhtrtir
	cmp #145,d0
	bpl.s bhtrtir
	tst.b [30*2]+9(a2)
	bne.s bhtrtir
	bset #5,25(a0)
	clr.b 12(a0)
	bra.s ctatim

bhtrtir:clr d0
	move.b 12(a0),d0
	move.b (a1,d0.w),d0
	bne.s dkl
	clr.b 12(a0)
	move.b (a1),d0
dkl:	move.b d0,8(a0)
	addq.b #1,12(a0)
ctatim:	bsr bob
	bsr bougeroeuftim
	rts

timagontir:				;TIR DE TIMAGOM
	lea timagtirg(pc),a1
	btst #6,25(a0)
	beq.s ptid
	lea timagtird(pc),a1
ptid:	clr d0
	move.b 12(a0),d0
	move.b (a1,d0.w),d0
	bne.s abr
	clr.b 12(a0)
	bclr #5,25(a0)
	rts
abr:	move.b d0,8(a0)
	addq.b #1,12(a0)
	move.b 12(a0),d0
	cmp.b #6,d0
	beq.s ddg
	cmp.b #16,d0
	beq.s ddg
	cmp.b #26,d0
	bne.s pintl
ddg:	bsr.s inittirtimagon
pintl:	rts
;-----
inittirtimagon:			;(a2)=ptr tir timagon
	moveq #3-1,d7
ittiml:	tst.b 9(a2)
	bne.s autti
	move.b #1,9(a2)
	move.b #3,24(a2)
	clr.w 28(a2)			;plus mort et energie
	move.l xmap(a0),xmap(a2)
	move.l #imagetimagon,20(a2)
	move.b d7,10(a2)		;dir x
	addq.b #3,10(a2)
	neg.b 10(a2)
	move.b #-3,11(a2)		;dir y
	clr.b 12(a2)
	move.b #40,13(a2)		;delay
	clr.b 14(a2)
	clr.b 15(a2)
	sub #14,ymap(a2)
	move.b #24,8(a2)
	btst #6,25(a0)			;tir vers droite ?
	beq.s tro			;non
	neg.b 10(a2)			;oui
	add #22,xmap(a2)
	move.b #23,8(a2)
tro:	rts
autti:	lea 30(a2),a2
	dbf d7,ittiml
	rts
 even
;------
gerertirtimagon:
	moveq #3-1,d7
gttiml:	tst.b 9(a0)		;active ?
	beq.s ptu		;non 
	tst.b 15(a0)		;sur le sol ?
	bne.s fltis		;oui
	move.b 10(a0),d0	;deplacer flamme x,y
	ext d0
	move.b 11(a0),d1
	ext d1
	add d0,xmap(a0)

	cmp.b #5,11(a0)		;pesanteur
	bpl.s abp
	addq.b #1,14(a0)	;delay pesanteur
	and.b #3,14(a0)
	bne.s abp
	addq.b #1,11(a0)
abp:	add d1,ymap(a0)
	move.w d7,-(sp)
	bsr collisionreliefenemis
	move.w (sp)+,d7
	and #1+2,d3
	tst.b d3			;collision ?
	beq.s pfu			;non
	move.b #1,15(a0)		;oui
	add d2,d1			;reajuster pos
	move d1,ymap(a0)
pfu:	move.w d7,-(sp)
	bsr bob
	move.w (sp)+,d7
ptu:	lea 30(a0),a0
	dbf d7,gttiml
	rts

fltis:	subq.b #1,13(a0)		;flamme au sol
	bpl.s fltiss
	clr.b 9(a0)
	clr.b 24(a0)
fltiss:	move.b #25,8(a0)
	btst #1,13(a0)
	beq.s fgk
	move.b #26,8(a0)
fgk:	move.w d7,-(sp)
	bsr bob
	move.w (sp)+,d7
	bra.s ptu
;--------
bougeroeuftim:
	lea bob62,a0
	tst.b 9(a0)
	beq.s poeuf1
	tst.b 28(a0)
	bne.s poeuf1

	move.b 10(a0),d0
	ext d0
	move.b 11(a0),d1
	ext d1
	bsr collisionreliefenemis
	btst #0,d3		;col x ?
	beq.s rat		;non
	neg.b 10(a0)

rat:	btst #1,d3		;col y ?
	beq.s rtu		;non
	add d2,d1
	move d1,ymap(a0)
	clr.b 11(a0)
	bra.s rttu
rtu:	add d1,ymap(a0)
rttu:	move.b 10(a0),d0
	ext d0
	add d0,xmap(a0)
	cmp.b #10,11(a0)
	bpl.s pcoqa
	addq.b #1,11(a0)
pcoqa:	bsr bob

poeuf1:
	lea bob63,a0
	tst.b 9(a0)
	beq.s poeuf2
	tst.b 28(a0)
	bne.s poeuf2
	move.b 10(a0),d0
	ext d0
	move.b 11(a0),d1
	ext d1
	bsr collisionreliefenemis
	btst #0,d3		;col x ?
	beq.s brat		;non
	neg.b 10(a0)
brat:
	btst #1,d3		;col y ?
	beq.s brtu		;non
	add d2,d1
	move d1,ymap(a0)
	clr.b 11(a0)
	bra.s brttu
brtu:	add d1,ymap(a0)
brttu:	move.b 10(a0),d0
	ext d0
	add d0,xmap(a0)
	cmp.b #10,11(a0)
	bpl.s bpcoqa
	addq.b #1,11(a0)
bpcoqa:	bsr bob
poeuf2:	rts

bougeroeuf:
	lea timagoeuf(pc),a1
	clr d0
	move.b 9(a0),d0
	move.b (a1,d0.w),d0
	bne.s ctoeuf
	clr.b 9(a0)
	move.b (a1),d0
ctoeuf:	move.b d0,8(a0)
	addq.b #1,9(a0)
	bsr bob
	rts
timagg:	dc.b 10,10,10,11,11,11,12,12,12,13,13,13,0
timagd:	dc.b 1,1,1,2,2,2,3,3,3,4,4,4,0 
timagoeuf:dc.b 20,20,20,20,19,19,19,20,20,20,20,19,19,19,20,20,20,20,0
timagtird:dc.b 5,5,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,0
timagtirg:dc.b 14,14,14,15,15,15,15,15,15
 dc.b 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,0
 even

;-------------------------------------------------
ANIMATIONBOMBE:
	tst.b 28(a0)
	bne mortgees
	addq.b #1,13(a0)
	and.b #15,13(a0)
	bne.s asy
	bsr initbombe
asy:	rts
;---------
animbombe:
	lea bobshartoes2,a2
	moveq #3-1,d7
assd:	tst.b 9(a2)
	beq.s asse
	tst.b 14(a2)
	bne explobombe
	move.b 11(a2),d0
	ext d0
	move.b 12(a2),d1
	ext d1
	move.w d7,-(sp)
	move.l a2,a0
	bsr collisionreliefenemis
	move.l a0,a2
	move.w (sp)+,d7
	and.b #3,d3
	beq.s assf
	move.b #1,14(a2)
	clr.b 10(a2)
;	bra.s asse
assf:	
	add d0,xmap(a2)
	add d1,ymap(a2)
	addq.b #1,12(a2)
asse:	lea 30(a2),a2
	dbf d7,assd
	rts
;----
explobombe:
	clr d0
	move.b 10(a2),d0
	lea tblexpb(pc),a1
	move.b (a1,d0.w),d0
	bne.s assg
	clr.b 9(a2)
	clr.b 24(a2)
	clr.b 14(a2)
	bra asse
assg:	move.b d0,8(a2)
	addq.b #1,10(a2)
	bra asse
tblexpb:
 dc.b 2,2,3,3,4,4,0
 even
;----
initbombe:
	lea bobshartoes2,a2
	moveq #3-1,d7
asa:	tst.b 9(a2)
	bne.s asb
	move.b #1,9(a2)
	move #58,xmap(a2)
	move #412,ymap(a2)
	move.b #1,8(a2)
	move.b #5,24(a2)
	move.l #IMAGEBOMBE,20(a2)
	addq.b #1,11(a0)
	and.b #7,11(a0)
	clr d0
	move.b 11(a0),d0
	asl #1,d0
	move.b coordb(pc,d0.w),11(a2)
	move.b coordb+1(pc,d0.w),12(a2)
	rts
asb:	lea 30(a2),a2
	dbf d7,asa
	rts
coordb:
 dc.b 6,-8,3,-7,7,-8,4,-7,2,-6,3,-5,4,-5,3,-3

;-------------------------------------------------
mortpmotoi:
	clr d0
	move.b 10(a0),d0
	lea tblptm(pc),a1
	move.b (a1,d0.w),d0
	bne.s bax
	clr.b 24(a0)
	bra ctpmotoi
bax:	move.b d0,8(a0)
	addq.b #1,10(a0)
	bra ctpmotoi

ANIMATIONPMOTOI:
	lea bob39,a0

	moveq #5-1,d7
baa:	tst.b 24(a0)
	beq.s ppmotoi
	tst.b 28(a0)
	bne.s mortpmotoi

	move.w 12(a0),d0
	move.b tblcercle(pc,d0.w),d1
	ext d1
	move.b tblcercle+1(pc,d0.w),d2
	ext d2
	addq #2,d0
	and #$fe,d0
	move d0,12(a0)
	
	lea tblptmg(pc),a1
	tst d1
	bmi.s daaa
	lea tblptmd(pc),a1
daaa:	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s daab 
	clr.b 10(a0)
	move.b (a1),d0
daab:	move.b d0,8(a0)
	addq.b #1,10(a0)

	move #970,d3
	add d1,d3
	move #224,d4
	add d2,d4
	move d3,xmap(a0)
	move d4,ymap(a0)

ctpmotoi:
	move.w d7,-(sp)
	bsr bob
	move.w (sp)+,d7

ppmotoi:lea 30(a0),a0
	dbf d7,baa
	rts

tblptmg:
 dc.b 1,1,1,1,2,2,2,2,0
tblptmd:
 dc.b 5,5,5,5,6,6,6,6,0
tblptm:
 dc.b 3,3,3,3,4,4,4,4,0

tblcercle:
dc.b 0,$40,$3,$3F,$6,$3F,$9,$3F,$C,$3E,$F,$3E,$12,$3D
dc.b $15,$3C,$18,$3B,$1B,$39,$1E,$38,$20,$36,$23,$35,$26,$33
dc.b $28,$31,$2A,$2F,$2D,$2D,$2F,$2A,$31,$28,$33,$26,$35,$23
dc.b $36,$20,$38,$1E,$39,$1B,$3B,$18,$3C,$15,$3D,$12,$3E,$F
dc.b $3E,$C,$3F,$9,$3F,$6,$3F,$3,$40,0,$3F,$FD,$3F,$FA
dc.b $3F,$F7,$3E,$F4,$3E,$F1,$3D,$EE,$3C,$EB,$3B,$E8,$39,$E5
dc.b $38,$E2,$36,$E0,$35,$DD,$33,$DA,$31,$D8,$2F,$D6,$2D,$D3
dc.b $2A,$D1,$28,$CF,$26,$CD,$23,$CB,$20,$CA,$1E,$C8,$1B,$C7
dc.b $18,$C5,$15,$C4,$12,$C3,$F,$C2,$C,$C2,$9,$C1,$6,$C1
dc.b $3,$C1,0,$C0,$FD,$C1,$FA,$C1,$F7,$C1,$F4,$C2,$F1,$C2
dc.b $EE,$C3,$EB,$C4,$E8,$C5,$E5,$C7,$E2,$C8,$E0,$CA,$DD,$CB
dc.b $DA,$CD,$D8,$CF,$D6,$D1,$D3,$D3,$D1,$D6,$CF,$D8,$CD,$DA
dc.b $CB,$DD,$CA,$E0,$C8,$E2,$C7,$E5,$C5,$E8,$C4,$EB,$C3,$EE
dc.b $C2,$F1,$C2,$F4,$C1,$F7,$C1,$FA,$C1,$FD,$C0,0,$C1,$3
dc.b $C1,$6,$C1,$9,$C2,$C,$C2,$F,$C3,$12,$C4,$15,$C5,$18
dc.b $C7,$1B,$C8,$1E,$CA,$20,$CB,$23,$CD,$26,$CF,$28,$D1,$2A
dc.b $D3,$2D,$D6,$2F,$D8,$31,$DA,$33,$DD,$35,$E0,$36,$E2,$38
dc.b $E5,$39,$E8,$3B,$EB,$3C,$EE,$3D,$F1,$3E,$F4,$3E,$F7,$3F
dc.b $FA,$3F,$FD,$3F

 even
;-------------------------------------------------
MORTGMOTOI:
	tst.b 24(a0)
	bne.s ctmgmo
	rts 
ctmgmo:	lea tblgmomg(pc),a1
	tst.b 12(a0)
	beq.s dvvx
	lea tblgmomd(pc),a1
dvvx:	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s dvvxx
	clr.b 24(a0)
	rts
dvvxx:	move.b d0,8(a0)
	addq.b #1,10(a0)
	bsr bob
	rts
;----------

ANIMATIONGMOTOI:
	lea bobtoki,a5
	tst.b 28(a0)
	bne.s MORTGMOTOI

;---- deplacer en x ----
	moveq #-2,d0
	lea tblgmog(pc),a1
	tst.b 12(a0)		;v gauche ?
	beq.s dvva
	lea tblgmod(pc),a1
	moveq #2,d0
dvva:	move.w xmap(a0),d1
	add d0,d1	
	cmp #1132,d1		;GAUCHE ?
	bpl.s dvvb
	clr d0
	not.b 12(a0)
dvvb:	cmp #1540,d1		;DROITE ?
	ble.s dvvc
	clr d0
	not.b 12(a0)
dvvc:
	move.b 13(a0),d1
	or.b 14(a0),d1
	or.b 15(a0),d1
	bne.s dvvd

	add d0,xmap(a0)
dvvd:
	
;-- tester si passe au desus --
	move.b 13(a0),d0
	or.b 14(a0),d0
	or.b 15(a0),d0
	bne.s dvve

	move.w xmap(a5),d0
	move.w xmap(a0),d2
	move d2,d3
	add 4(a0),d3
	cmp d3,d0
	bge.s dvve
	move d0,d1
	add 4(a5),d1
	cmp d2,d1
	ble.s dvve

	move.w ymap(a5),d0	;au dessus ?
	move.w ymap(a0),d1
	sub 6(a5),d0
	cmp d0,d1
	bge.s dvvu
	move.b #1,13(a0)	;ver bas
dvvu:
	sub 6(a0),d1
	move.w ymap(a5),d0
	cmp d0,d1
	ble.s dvve
	move.b #1,15(a0)	;vers haut
dvve:
	tst.b 13(a0)
	beq.s dvvf
	bsr gmotoibas
dvvf:	tst.b 14(a0)
	beq.s dvvv
	bsr gmotoihaut
dvvv:

;------- animation --------
	tst.b 15(a0)		;il se transform ?
	bne.s dvvmm
	tst.b 14(a0)		;il tourne ?
	beq.s dvvm
	lea tblgmotourn(pc),a1
dvvm:	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s ctgmo
	clr.b 10(a0)
	move.b (a1),d0
ctgmo:	move.b d0,8(a0)
	addq.b #1,10(a0)
	bra.s dvvkk

;----------- animation transform --------
dvvmm:
	lea tblgmotg(pc),a1
	tst.b 12(a0)
	beq.s dvvdd	
	lea tblgmotd(pc),a1
dvvdd:	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s bctgmo
	clr.b 10(a0)
	move.b #1,14(a0)	;active monter
	clr.b 15(a0)		;desactiv transform
	bra.s dvvkk
bctgmo:	move.b d0,8(a0)
	addq.b #1,10(a0)
;-------------
dvvkk:	clr d0
	move.b 11(a0),d0
	addq.b #1,d0
	and.b #15,d0
	move.b d0,11(a0)
	lea tblgmotoi(pc),a2
	move.b (a2,d0.w),d0
	ext d0
	tst.b 14(a0)			;si mine
	bne.s dvvj			;pas sin y
	tst.b 15(a0)			;si transform aussi
	bne.s dvvj

	cmp #112,ymap(a0)
	ble.s dvvj
	add d0,ymap(a0)			;dir y
dvvj:	bsr bob
	rts
;---- 
gmotoibas:
	addq #2,ymap(a0)
	move.w ymap(a5),d0
	move.w ymap(a0),d1
	sub 6(a5),d0
	cmp d0,d1
	ble.s dvvg
	clr.b 13(a0)
dvvg:	rts
;----
gmotoihaut:
	cmp #110,ymap(a0)
	ble.s dvvh 
	subq #2,ymap(a0)
	cmp #112,ymap(a0)
	bge.s dvvh
	clr.b 14(a0)
	move #112,ymap(a0)
dvvh:	rts
;----

tblgmotoi:
 dc.b 1,1,2,3,3,2,1,1,-1,-1,-2,-3,-3,-2,-1,-1
tblgmog:
 dc.b 1,1,1,1,2,2,2,2,3,3,3,3,0
tblgmod:
 dc.b 14,14,14,14,15,15,15,15,16,16,16,16,0
tblgmomg:
 dc.b 4,4,4,4,4,5,5,5,5,5,6,6,6,6,6,0
tblgmomd:
 dc.b 17,17,17,17,17,5,5,5,5,5,6,6,6,6,6,0
tblgmotg:
 dc.b 7,7,7,7,7,7,8,8,8,8,8,8,9,9,9,9,9,9,0
tblgmotd:
 dc.b 18,18,18,18,18,18,8,8,8,8,8,8,9,9,9,9,9,9,0
tblgmotourn:
 dc.b 10,10,10,11,11,11,12,12,12,13,13,13,0
 even
;-------------------------------------------------
mortgabana:
	tst.b 24(a0)
	beq.s plusgabana
	lea angam(pc),a1
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s ctmgab
	clr.b 24(a0)
	rts
ctmgab:	move.b d0,8(a0)
	addq.b #1,10(a0)
	bsr bob
plusgabana:
	rts
;----
ANIMATIONGABANA:
	tst.b 28(a0)
	bne.s mortgabana
	lea bobtoki,a5

	tst.b 14(a0)
	bne.s okga
	move.w xmap(a5),d0
	move.w xmap(a0),d1
	sub d0,d1
	bpl.s wt
	neg d1
wt:	cmp #150,d1
	bpl pgabana
	move.b #1,14(a0)

okga:	addq.b #1,13(a0)	;delay
	and.b #63,13(a0)
	bne.s ptstg

	movem.w xmap(a5),d0-d1
	movem.w xmap(a0),d2-d3

	move.b #1,d6		;dir x
	move.b #0,d7		;dir y

	cmp d2,d0		;a droite ?
	bge.s jka
	neg.b d6
jka:	sub #24,d3
	cmp d3,d1		;en desous ?
	bge.s jkb
	move.b #-1,d7
jkb:	add #24,d3
	sub #24,d1
	cmp d3,d1		;au dessus ?
	ble.s jkc
	move.b #1,d7
jkc:
	move.b d6,10(a0)	;dir x
	move.b d7,11(a0)	;dir y

ptstg:	move.b 10(a0),d6	;dir x
	move.b 11(a0),d7	;dir y

	move ymap(a0),d0	;tst d
	move.b d7,d1
	ext d1
	add d1,d0
	cmp #138,d0
	bpl.s qwt
	neg.b 11(a0)
	neg.b d7
qwt:
	cmp #302,d0
	ble.s qwtb
	neg.b 11(a0)
	neg.b d7

qwtb:	move xmap(a0),d0		;tst g
	move.b d6,d1
	ext d1
	add d1,d0
	cmp #576,d0
	bge.s qwtg
	neg.b 10(a0)
	neg.b d6
qwtg:
	cmp #1028,d0
	ble.s qwtgd
	neg.b 10(a0)
	neg.b d6
qwtgd:

;-- tester anim --
	tst.b  d6		;x
	bmi.s animouest
	lea angae(pc),a1
	tst.b d7
	beq.s ctanga
	bmi.s agne
	lea angase(pc),a1
	bra.s ctanga
agne:	lea angane(pc),a1
	bra.s ctanga
animouest:
	lea angao(pc),a1
	tst.b d7
	beq.s ctanga
	bmi.s agno
	lea angaso(pc),a1
	bra.s ctanga
agno:	lea angano(pc),a1

ctanga:	clr d0
	move.b 12(a0),d0
	move.b (a1,d0.w),d1
	bne.s ujl
	clr.b 12(a0)
	move.b (a1),d1
ujl:	move.b d1,8(a0)
	addq.b #1,12(a0)

	ext d6
	add d6,xmap(a0)
	ext d7
	add d7,ymap(a0)

	bsr bob
pgabana:rts
angae:	dc.b 7,7,7,7,8,8,8,8,0
angane:	dc.b 10,10,10,10,10,10,10,10,0
angase:	dc.b 9,9,9,9,9,9,9,9,0
angao:	dc.b 1,1,1,1,2,2,2,2,0
angano:	dc.b 11,11,11,11,11,11,11,11,0
angaso:	dc.b 12,12,12,12,12,12,12,12,0
angam:	dc.b 3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,0
 even
;-------------------------------------------------
tblshart1nv1:
 dc.w 332-192,750
 dc.w 324,750,300,760,348,760,324,770,300,780,348,780

tblshart2nv1:
 dc.w 332-192,10
 dc.w 324,10,300,20,348,20,324,30,300,40,348,40
;-----------------
ANIMATIONSHARTOES:
	tst.b 9(a0)
	bne.s okapparu

	lea bobtoki,a5
	move xmap(a5),d0
	move (a2),d1
	cmp d1,d0
	ble pshar
	move ymap(a5),d0	;ytoki < yshartoes ?
	move 2(a2),d1
	cmp d0,d1
	bge pshar
	add #170,d1		;y toki > yb shartoes ?
	cmp d0,d1
	ble pshar

	move.l a0,a1
	move.b #1,9(a0)			;ok apparu
	move.b #4,11(a1)		;nb de vas et vient
	move.b #64,12(a1)		;deplacement total

	lea 4(a2),a2			;sauter entete pour init
	moveq #6-1,d0
sharloop:
	move.l #IMAGESHARTOES,20(a1)
	move.b #3,24(a1)
	move.b #1,8(a1)	
	move.l (a2)+,xmap(a1)
	move.b #-4,13(a1)		;depx
	clr.b 10(a1)
	lea 30(a1),a1
	dbf d0,sharloop
okapparu:
	addq.b #1,12(a0)
	and.b #127,12(a0)
	bne.s pol

	neg.b 13(a0)
	addq #8,ymap(a0)

	neg.b [30*1]+13(a0)
	addq #8,[30*1]+ymap(a0)

	neg.b [30*2]+13(a0)
	addq #8,[30*2]+ymap(a0)

	neg.b [30*3]+13(a0)
	addq #8,[30*3]+ymap(a0)

	neg.b [30*4]+13(a0)
	addq #8,[30*4]+ymap(a0)

	neg.b [30*5]+13(a0)
	addq #8,[30*5]+ymap(a0)

	subq.b #1,11(a0)		;deja fini ?
	bne.s pol			;non

	move.b #1,28(a0)	
	clr.b [30*0]+10(a0)	
	move.b #1,[30*1]+28(a0)	
	clr.b [30*1]+10(a0)	
	move.b #1,[30*2]+28(a0)	
	clr.b [30*2]+10(a0)	
	move.b #1,[30*3]+28(a0)	
	clr.b [30*3]+10(a0)	
	move.b #1,[30*4]+28(a0)	
	clr.b [30*4]+10(a0)	
	move.b #1,[30*5]+28(a0)	
	clr.b [30*5]+10(a0)	
	rts
pol:
	tst.b 24(a0)
	beq.s pss1
	bsr animsharto
	bsr bob
pss1:	lea 30(a0),a0
	tst.b 24(a0)
	beq.s pss2
	bsr.s animsharto
	bsr bob
pss2:	lea 30(a0),a0
	tst.b 24(a0)
	beq.s pss3
	bsr.s animsharto
	bsr bob
pss3:	lea 30(a0),a0
	tst.b 24(a0)
	beq.s pss4
	bsr.s animsharto
	bsr bob
pss4:	lea 30(a0),a0
	tst.b 24(a0)
	beq.s pss5
	bsr.s animsharto
	bsr bob
pss5:	lea 30(a0),a0
	tst.b 24(a0)
	beq.s pshar
	bsr.s animsharto
	bsr bob
pshar:	rts

;-------  animation des shartoes  -------------
animsharto:
	tst.b 28(a0)		;mort
	bne.s mortshartoes
	bsr bcolltirbob
	tst.b 28(a0)
	beq.s pasmm

	move #1,d0
	bsr initoption
	clr.b 10(a0)
	bra mortshartoes

pasmm:	move.b 13(a0),d0
	ext d0
	add d0,xmap(a0)

	lea tbldepd(pc),a1	
	tst.b 13(a0)		;dir 
	bpl.s pasgsg
	lea tbldepg(pc),a1	
pasgsg: clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0	
	bne.s ctgsg
	clr.b 10(a0)
	move.b (a1),d0
ctgsg:	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts
;-------------------------
mortshartoes:
	lea tblmsd(pc),a1
	tst.b 13(a0)		;dir
	bpl.s pmsd		
	lea tblmsg(pc),a1
pmsd:	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s ctms
	clr.b 24(a0)
	clr.b 13(a0)
	rts
ctms:	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts
;-------------------------
tbldepd:dc.b 9,9,9,10,10,10,11,11,11,12,12,12,13,13,13,14,14,14,0
tbldepg:dc.b 1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,0
tblmsd:dc.b 15,15,16,16,0
tblmsg:dc.b 7,7,8,8,0
 even
;-------------------------------------------------
ANIMATIONGATE:
	lea bob2,a0			;gros carre
	lea PTRANIMBOB2,a6
	bsr ANIMATIONTYPE1

	lea bob46,a1
	movem.w xmap(a0),d0-d1		;tetes g
	sub #13,d0
	subq #2,d1
	movem.w d0-d1,[30*0]+xmap(a1)
	sub #28,d1
	movem.w d0-d1,[30*1]+xmap(a1)
	sub #28,d1
	movem.w d0-d1,[30*2]+xmap(a1)

	movem.w xmap(a0),d0-d1		;tete d
	add #100,d0
	subq #2,d1
	movem.w d0-d1,[30*3]+xmap(a1)
	sub #28,d1
	movem.w d0-d1,[30*4]+xmap(a1)
	sub #28,d1
	movem.w d0-d1,[30*5]+xmap(a1)

	lea [30*6](a1),a1		;point
	movem.w xmap(a0),d0-d1
	add #24,d0
	add #62,d1
	move d1,d2
	bsr poing
	movem.w d0-d1,xmap(a1)		 

	add #15,d0
	lea 30(a1),a1
	move d2,d1
	bsr poing
	movem.w d0-d1,xmap(a1)

	add #15,d0
	lea 30(a1),a1
	move d2,d1
	bsr poing
	movem.w d0-d1,xmap(a1)

	add #15,d0
	lea 30(a1),a1
	move d2,d1
	bsr poing
	movem.w d0-d1,xmap(a1)

	lea 30(a1),a1
	movem.w xmap(a0),d0-d1
	add #24,d0
	sub #112,d1
	movem.w d0-d1,xmap(a1)		;balancoire

	lea bob46+[30*6],a0		;poing 1
	bsr bob
	bsr colgatep
	bsr coltirenemis

	lea 30(a0),a0			;2
	bsr bob
	bsr colgatep
	bsr coltirenemis

	lea 30(a0),a0
	bsr bob				;3
	bsr colgatep
	bsr coltirenemis

	lea 30(a0),a0
	bsr bob				;4
	bsr colgatep
	bsr coltirenemis

	lea bob2,a0			;gros carre
	bsr bob

	lea bob46,a0			;tetes
	bsr bob
	bsr colgatet
	lea 30(a0),a0
	bsr bob
	bsr colgatet
	lea 30(a0),a0
	bsr bob
	bsr colgatet
	lea 30(a0),a0
	bsr bob
	bsr colgatet
	lea 30(a0),a0
	bsr bob
	bsr colgatet
	lea 30(a0),a0
	bsr bob
	bsr colgatet

	lea [30*5](a0),a0		;balancoire
	bsr bob
	bsr animbal
	bsr coltirenemis

	bsr animteteggate
	bsr animtetedgate

	lea bob59,a0		;singe d
	bsr animsingegate
	bsr bob
	bsr coltirenemis
	lea bob60,a0		;singe g
	bsr animsingegate
	bsr bob
	bsr coltirenemis

	rts
;--------------------------
colgatep:
	tst.b 29(a0)
	bne.s mortp

	move.w xmap(a0),d0

	lea bobtirtoki,a1
	tst.b floption
	beq.s paspl
	lea [26*5](a1),a1
paspl:
	move #5-1,d7		;nb tir
colgatel:
	tst.b 9(a1)
	beq.s pcgate

	move.w xmap(a0),d0
	move.w xmap(a1),d1

	addq #4+4,d1
	cmp d1,d0		;xg ?
	bge.s pcgate
	add 4(a0),d0
	cmp d1,d0		;xd ?
	ble.s pcgate
	
	move ymap(a0),d0
	move ymap(a1),d1
	cmp d0,d1		;yb ?
	bge.s pcgate

	subq #8,d1		;yh ?
	sub #16+16,d0
	cmp d0,d1		
	ble.s pcgate

	move.b #1,29(a0)
	move.b #20,10(a0)
	clr.b 9(a1)		;plus de tir

pcgate:	lea 26(a1),a1
	dbf d7,colgatel	
plcgate:
	rts
;------------
mortp:
	tst.b 28(a0)
	bne.s pmortp

	eor.b #1,24(a0)
pasrp:
	subq.b #1,10(a0)
	bne.s pmortp
	clr.b 24(a0)
	move.b #1,28(a0)
pmortp:	rts
;------------------------
colgatet:
	tst.b 29(a0)
	bne.s mortt

ccolgatet:
	move.w xmap(a0),d0

	lea bobtirtoki,a1
	tst.b floption
	bne.s pdf
	lea [26*5](a1),a1
pdf:
	move #5-1,d7		;nb tir
colgatelt:
	tst.b 9(a1)
	beq.s tpcgate

	move.w xmap(a0),d0
	move.w xmap(a1),d1

	addq #4+4,d1
	cmp d1,d0		;xg ?
	bge.s tpcgate
	add 4(a0),d0
	cmp d1,d0		;xd ?
	ble.s tpcgate
	
	move ymap(a0),d0
	move ymap(a1),d1
	cmp d0,d1		;yb ?
	bge.s tpcgate

	subq #8,d1		;yh ?
	sub 6(a0),d0
	cmp d0,d1		
	ble.s tpcgate

	move.b #1,29(a0)
	clr.b 10(a0)
	clr.b 9(a1)		;plus de tir

tpcgate:lea 26(a1),a1
	dbf d7,colgatelt	
tplcgate:
	rts
;------------
mortt:
	tst.b 28(a0)
	bne.s pmortpt
	eor.b #1,24(a0)
	addq.b #1,10(a0)
	cmp.b #20,10(a0)
	bne.s pmortpt
	clr.b 24(a0)
	move.b #1,28(a0)
pmortpt:rts
;------------------------
poing:
	tst.b 29(a0)
	bne.s ppoing

	move.b 14(a1),d7
	cmp.b #24,d7
	bmi.s psdfg
	clr.b d7
	neg.b 12(a1)	
psdfg:
	addq.b #1,d7
	move.b d7,14(a1)
	move.b 12(a1),d7
	add.b d7,13(a1)
	move.b 13(a1),d7
	ext d7
	add d7,d1
ppoing:	rts

;---------------------------------
animbal:
	moveq #0,d0
	move.b 10(a0),d0
	lea tblbal(pc),a1
	move.b (a1,d0.w),d0
	bne.s canb
	clr.b 10(a0)
	move.b (a1),d0
canb:	move.b d0,8(a0)
	addq.b #1,10(a0)

	lea bob59,a0
	lea bob60,a1

	move.b #1,8(a0)
	move.b #11,8(a1)
	cmp.b #4,d0
	bne.s paschgs
	move.b #12,8(a0)
	move.b #7,8(a1)
paschgs:rts

tblbal:dc.b 2,2,2,2,3,3,3,3,4,4,4,4,3,3,3,3,0
even
;--------------------------
ANIMTETEGGATE:
	lea addrtg(pc),a3
	tst.l (a3)
	bne.s pastirgate
	move.l (a3),a2
	clr.b 26(a2)			;pour flamme
	lea  randomteteg(pc),a2
	move.b cpttgg,d1
	ext d1
	moveq #0,d2
	move.b (a2,d1.w),d2
	bpl.s conttgt			;fin ?
	move.b (a2),d2			;oui
	clr.b d1
conttgt:
	add.l #bob46,d2		;non
	move.l d2,(a3)
	addq.b #1,d1
	move.b d1,cpttgg	
pastirgate:
;-- animation tete --
	move.l (a3),a3
	moveq #0,d0
	move.b 15(a3),d0
	lea tableanimtg(pc),a2
	move.b (a2,d0.w),d0
	bne.s pse			;fin ?
	clr.b 15(a3)			;oui
	clr.b 26(a3)
	clr.l addrtg
	rts
pse:	move.b d0,8(a3)			;non
	addq.b #1,15(a3)

;--- tester si flamme ---
	tst.b 29(a3)
	bne.s pasflameg
	cmp.b #7,d0			;flamme ?
	bne.s pasflameg	
	lea bob57,a0
	lea tableflammeg(pc),a1
	moveq #0,d0
	move.b 26(a3),d0
	move.b (a1,d0.w),d0
	bne.s okflammeg
	clr.b 26(a3)
	clr.b 24(a0)
	rts
okflammeg:
	move.b d0,8(a0)
	move.b #1,24(a0)
	addq.b #1,26(a3)
	movem.w xmap(a3),d0-d1
	sub #26,d0
	subq #2,d1
	movem.w d0-d1,xmap(a0)
	bsr bob
	bsr coltirenemis
pasflameg:
	rts
tableanimtg:
 dc.b 5,6,6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,5,0
 even
tableflammeg:
 dc.b 8,8,9,9,9,10,10,10,11,11,12,12,12,13,13,14,14,15,15,0
 even
randomteteg:
 dc.b 00,60,30,60,30,60,00,60,00,30,-1
 even
;---------------------------------
ANIMTETEDGATE:
	lea addrtd(pc),a3
	tst.l (a3)
	bne.s dpastirgate
	move.l (a3),a2
	clr.b 26(a2)			;pour flamme
	lea  randomteted(pc),a2
	move.b cpttgd,d1
	ext d1
	moveq #0,d2
	move.b (a2,d1.w),d2
	bne.s dconttgt			;fin ?
	move.b (a2),d2			;oui
	clr.b d1
dconttgt:
	add.l #bob46,d2		;non
	move.l d2,(a3)
	addq.b #1,d1
	move.b d1,cpttgd	
dpastirgate:

;-- animation tete --
	move.l (a3),a3
	moveq #0,d0
	move.b 15(a3),d0
	lea tableanimtd(pc),a2
	move.b (a2,d0.w),d0
	bne.s dpse			;fin ?
	clr.b 15(a3)			;oui
	clr.b 26(a3)
	clr.l addrtd
	rts
dpse:	move.b d0,8(a3)			;non
	addq.b #1,15(a3)

;--- tester si flamme ---
	tst.b 29(a3)
	bne.s dpasflameg

	cmp.b #18,d0
	bne.s dpasflameg	
	lea bob58,a0
	lea tableflammed(pc),a1
	moveq #0,d0
	move.b 26(a3),d0
	move.b (a1,d0.w),d0
	bne.s dokflammeg
	clr.b 26(a3)
	clr.b 24(a0)
	rts
dokflammeg:
	move.b d0,8(a0)
	move.b #1,24(a0)
	addq.b #1,26(a3)
	movem.w xmap(a3),d0-d1
	add #12,d0
	subq #2,d1
	movem.w d0-d1,xmap(a0)
	bsr bob
	bsr coltirenemis
dpasflameg:
	rts
tableanimtd:
 dc.b 16,17,17,17,17,17,17,17
 dc.b 18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,16,0
 even
tableflammed:
 dc.b 19,19,20,20,20,21,21,21,22,22,23,23,23,24,24,25,25,26,26,0
 even
 randomteted:
 dc.b 150,120,90,150,120,90,150,120,90,150,90,120,0
 even

addrtd:		dc.l 0
addrtg:		dc.l 0
cpttgd:		dc.b 0
cpttgg:		dc.b 0
 even
;-------------------------------------------------
animsingegate:
	tst.b 24(a0)			
	beq.s pasg
	tst.b 29(a0)
	bne.s mortgees

	bsr ccolgatet
	lea bob2,a1
	movem.w xmap(a1),d0-d1
	tst.b 25(a0)			;singe g ?
	bne.s animsingegateg		;oui
	add #76,d0
	sub #112,d1
	movem.w d0-d1,xmap(a0)
pasg:	rts

animsingegateg:
	addq #4,d0
	sub #112,d1
	movem.w d0-d1,xmap(a0)
	rts
;-------------------------------------------------
MORTGEES:
	lea tablemtg(pc),a1
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s pasfmg
	clr.b 24(a0)		;plus de gees
	clr.b 9(a0)		;pour big1
	rts			;et casse toi
pasfmg:	ext d0
	add d0,ymap(a0)
	addq.b #1,10(a0)
	move.b #6,8(a0)
	tst.b 12(a0)
	bne.s pimgg
	move.b #5,8(a0)
pimgg:	rts

tablemtg:
 dc.b -7,-6,-5,-4,-3,-2,-1,1,2,3,4,5,6,7,8,8,8,8,8,8,8,8,8,8
 dc.b 8,8,8,8,8,8,8,8,8,8,0
 even
;---------
ANIMATIONGEES:
	tst.b 24(a0)
	beq plusaig

	tst.b 28(a0)		
	bne.s mortgees

	move.w xmap(a0),d0	;xg
	move d0,d2
	add 4(a0),d2		;xd
	move posmapx,d4
	cmp d2,d4		;gauche ?
	bge plusaig
	add #224,d4
	cmp d0,d4		;droite ?
	ble plusaig
	move.w ymap(a0),d1
	move d1,d3
	sub 6(a0),d3		;yh
	move posmapy,d5
	cmp d3,d5		;bas ?
	ble plusaig
	sub #176,d5	
	cmp d1,d5		;haut ?
	bge plusaig

	tst.b 13(a0)			;pt delay ?
	bmi.s okgeregees		;oui gerer
	subq.b #1,13(a0)		;non
	bra gerim			;pas gerer

okgeregees:
	move.b  10(a0),d0		;depl x
	ext d0
	move.b  11(a0),d1		;depl y
	ext d1
	bsr collisionreliefenemis

	btst #0,d3			;col x ?
	beq.s passxx			;non
	neg.b 10(a0)
passxx:
	btst #1,d3			;col y ?
	beq.s pcgy			;non
	tst.b 11(a0)			;collision y haut ?
	bpl.s okpcgy			;non
	clr.b 11(a0)			;oui 
	bra.s dokpcgy
okpcgy:
	add d2,d1			;reajuster pos y
	move d2,ymap(a0)		;si au sol
	move.b 14(a0),11(a0)		;hauteur du rebond
dokpcgy:
	lea bobtoki,a5
	movem.w xmap(a5),d2-d3		
	movem.w xmap(a0),d0-d1

	move.b #-2,10(a0)		;dir x singe
	move.b #0,12(a0)		;vers gauche
	move.b #1,8(a0)
	cmp d0,d2
	bmi.s nomu
	move.b #2,10(a0)		;vers droite
	move.b #1,12(a0)
	move.b #7,8(a0)
nomu:	moveq #0,d4
	move.b 26(a0),d4		;dist x
	sub d2,d0
	tst d0
	bpl.s noma
	neg d0
noma:	cmp d0,d4
	bpl.s passyy	
	move.b #0,10(a0)		;direction
passyy:	move.b #3,13(a0)		;petit delay
	bra.s gerim
pcgy:	move.b 10(a0),d0
	ext d0
	add d0,xmap(a0)

	move.b 11(a0),d0		;pesanteur
	addq.b #1,d0
	cmp.b #10,d0			;> 10 ?
	ble.s nonp			;non
	move.b #10,d0			;oui
nonp:	move.b d0,11(a0)
	ext d0
	add d0,ymap(a0)			;deplacer en y
;-- gerer image --
gerim:	tst.b 10(a0)		;il y a un direction ??
	bne.s okdirg
	tst.b 12(a0)
	bne.s vdroite
	bra.s vgauche
okdirg:	tst.b 10(a0)			;dir x
	bpl.s vdroite
vgauche:cmp.b #-7,11(a0)
	bne.s pasi2
	move.b #2,8(a0)
pasi2:	cmp.b #-5,11(a0)
	bne.s pasi3
	move.b #3,8(a0)
pasi3:	cmp.b #-3,11(a0)
	bne.s pasi4
	move.b #4,8(a0)
pasi4:	cmp.b #0,11(a0)
	bne.s pasi5
	move.b #1,8(a0)
pasi5:	bra.s plusaig
vdroite:cmp.b #-7,11(a0)
	bne.s bpasi2
	move.b #8,8(a0)
bpasi2:	cmp.b #-5,11(a0)
	bne.s bpasi3
	move.b #9,8(a0)
bpasi3:	cmp.b #-3,11(a0)
	bne.s bpasi4
	move.b #10,8(a0)
bpasi4:	cmp.b #0,11(a0)
	bne.s plusaig
	move.b #7,8(a0)
plusaig:rts
;---------------------------------------------
ANIMATIONTYPE2:
	tst.b 24(a0)		;si type = 0 
	beq.s pasanimtype2	;pas d'animation
	bpl.s animtype2

	lea bobtoki,a5
	move xmap(a5),d0
	add #176,d0
	cmp xmap(a0),d0
	ble.s pasanimtype2
	bclr #7,24(a0)
animtype2:
	bra ANIMATIONTYPE1
pasanimtype2:
	rts
;==========================================
ANIMATIONTYPE3:
	tst.b 28(a0)
	bne contanimt3
	tst.b 24(a0)		;si type = 0 
	beq pasanimtype3	;pas d'animation
	bpl.s animtype3

	lea bobtoki,a5
	move xmap(a5),d0	;tester sur x droite
	add #130,d0
	cmp xmap(a0),d0
	ble pasanimtype3
	move xmap(a5),d0	;tester sur x gauche
	sub #130,d0
	cmp xmap(a0),d0
	bge pasanimtype3
	move ymap(a5),d0	;tester sur y
	sub #120,d0
	cmp ymap(a0),d0
	bge pasanimtype3
	bclr #7,24(a0)
animtype3:
	move.b 14(a0),d0	;depl X
	ext d0
	move.b 15(a0),d1	;depl y
	ext d1
	clr.b flagliane2
	bsr collisionreliefenemis
;	move d1,d3
;	addq #1,d3
;	cmp #10,d3
;	ble.s enomag
;	moveq #10,d3

enomag:	moveq #0,d2
	move.b 14(a0),d7		;d7 = depl X
	ext d7
	move.b 15(a0),d6		;d6 = depl y
	ext d6
	tst.b flagdiag
	bne.s negbx
	tst.b flagliane2
	bne.s negbx
	tst d0
	bne.s pasexx
negbx:	neg.b 14(a0)		;neg x
	neg d7
	st d2
pasexx:	tst.b flagdiag
	bne.s negby
	tst.b flagliane2
	bne.s negby
	tst d1
	bne.s pasexy
negby:	neg.b 15(a0)		;neg y
	neg d6
	st d2

pasexy:	tst d2
	bne.s pasrevd
	movem xmap(a0),d0-d1
	sub posmapx,d0
	sub posmapy,d1
	add #176,d1
	add d7,d0
	add d6,d1
	cmp #224,d0		;ecran droite ?
	ble.s pasreva
	neg.b 14(a0)		;x
	neg d7
pasreva:
	cmp #-32,d0		;ecran gauche ?
	bge.s pasrevb
	neg.b 14(a0)		;x
	neg d7
pasrevb:
	cmp #2,d1		;ecran haut ?
	bge.s pasrevc
	neg.b 15(a0)		;y
	neg d6
pasrevc:
	cmp #176,d1		;ecran bas ?
	ble.s pasrevd
	neg.b 15(a0)		;y
	neg d6
pasrevd:
	add d7,16(a0)		;dep x
	add d6,18(a0)		;dep y
contanimt3:
	bra ANIMATIONTYPE
pasanimtype3:
	rts
;----------------------------------------
ANIMATIONTYPE4:
	move ymap(a0),d6	;pour y
	move xmap(a0),d5	;pour x

	btst #3,25(a0)		;fin de table
	bne.s contianimen4	;non conti anim

	btst #5,25(a0)		;si apparaition
	beq.s contianimen4	;pas de deplacement
	tst.b 11(a0)		;
	bne.s contianimen4	;
	tst.b 28(a0)		;il meurt ?
	bne.s contianimen4	;oui 

	move 12(a0),d7
	tst.b d7
	bne.s noreset4
	move 14(a0),d7
	move (a6,d7.w),d7
	bne.s noreset14
	bset #3,25(a0)		;flag fin  de table
	clr.b 10(a0)
	rts
noreset14:
	addq #2,14(a0)
noreset4:
	subq.b #1,d7
	move.w d7,12(a0)
	rol #2,d7
	moveq #%11,d0
	and d7,d0
	add d0,d5		;depl x droite
;--
	rol #2,d7
	moveq #%11,d0
	and d7,d0
	sub d0,d5		;depl x gauche
;--
	rol #2,d7
	moveq #%11,d0
	and d7,d0
	sub d0,d6		;depl y haut
;--
	rol #2,d7
	and.w #%11,d7
	add d7,d6		;depl y bas
;--
	move d5,xmap(a0)
	move d6,ymap(a0)
contianimen4:
	bsr.s ANIMATIONTYPE
	rts
;================================================
ANIMATIONTYPE1:
	tst.b 28(a0)		;il meur ?
	bne.s contianimen	;oui 
	tst.b 11(a0)		;il tir ?
	bne.s contianimen	;oui 

	movem.w xmap(a0),d5-d6

	move 12(a0),d7
	tst.b d7
	bne.s noreset
	move 14(a0),d7
	move (a6,d7.w),d7
	bne.s noreset1
	clr 14(a0)
	move (a6),d7
noreset1:
	addq #2,14(a0)
noreset:
	subq.b #1,d7
	move.w d7,12(a0)
	rol #2,d7
	moveq #%11,d0
	and d7,d0
	add d0,d5		;depl x droite
;--
	rol #2,d7
	moveq #%11,d0
	and d7,d0
	sub d0,d5		;depl x gauche
;--
	rol #2,d7
	moveq #%11,d0
	and d7,d0
	sub d0,d6		;depl y haut
;--
	rol #2,d7
	and.w #%11,d7
	add d7,d6		;depl y bas
;--
	movem.w d5-d6,xmap(a0)
	add 4(a0),d5		;xmap + tail x du sprite
	bpl.s contianimen	;xmap negatif ? non continuer
	clr.b 24(a0)		;oui  type = 0
contianimen:
	bra.s ANIMATIONTYPE
	rts
;-----------------------------------------------
;================================================
;=====  gerer les animation selon leur type   ===
;================================================
ANIMATIONTYPE:
	clr d0
	move.b 9(a0),d0		;type d'animation
	add d0,d0
	add d0,d0
	jmp routinetype(pc,d0.w)
routinetype:
	bra rttype0
	bra rttype1
	bra rttype2
	bra rttype3
	bra rttype4
	bra rttype5
	bra rttype6
	bra rttype7
	bra rttype8
	bra rttype9
	bra rttype10
	bra rttype11
	bra rttype9
	bra rttype9
;=================================================
RTTYPE0:
	move.b #1,8(a0)
	rts
;=================================================
RTTYPE1:
	tst.b 24(a0)			;gerer ?
	beq.s pasgertype1		;non
	tst.b 28(a0)			;il meur ?
	bne.s type1mort			;oui le gerer
	lea ANIMD_HERBAMO(pc),a1
	move 12(a0),d0			;direction
	and #DR3,d0
	bne.s pastype1D
	lea ANIMG_HERBAMO(pc),a1
pastype1d:
	clr d0
	move.b 10(a0),d0		;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s prestype1
	clr.b 10(a0)
	move.b (a1),d0
prestype1:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts
type1mort:
	lea ANIMMD_HERBAMO(pc),a1		;image selon mort
	move 12(a0),d0	
	and #DR3,d0
	bne.s pastype1MD
	lea ANIMMG_HERBAMO(pc),a1
pastype1MD:
	move.b (a1),8(a0)
	lea TABLEM_HERBAMO,a1
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s contmort1
	clr.b 24(a0)		;plus le gerer 
	rts
contmort1:
	ext d0
	add d0,ymap(a0)
	add.b #1,10(a0)
pasgertype1:
	rts
ANIMD_HERBAMO:
 dc.b 7,7,7,8,8,8,9,9,9,10,10,10,0
ANIMG_HERBAMO:
 dc.b 1,1,1,2,2,2,3,3,3,4,4,4,0
ANIMMD_HERBAMO:
 dc.b 6,0
ANIMMG_HERBAMO:
 dc.b 5,0
TABLEM_HERBAMO:
 dc.b -6,-5,-4,-2,-1,1,2,4,5,6,7,8,9,9,9,0
even
;================================================
RTTYPE2:			;TORPEDO
	tst.b 24(a0)
	beq.s pasgerertype2
	tst.b 28(a0)
	bne.s morttopedo
	lea ANIM_TORP(pc),a1
	clr d0
	move.b 10(a0),d0		;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s prestype2
	clr.b 10(a0)
	move.b (a1),d0
prestype2:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts
morttopedo:
	lea ANIMM_TORP(pc),a1
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s premtype2
	clr.b 24(a0)		;plus de torpedo
	rts
premtype2:
	move.b d0,8(a0)
	addq.b #1,10(a0)
pasgerertype2:
	rts

ANIM_TORP:
 dc.b 1,1,1,2,2,2,3,3,3,2,2,2,0
ANIMM_TORP:
 dc.b 4,4,4,4,4,5,5,5,5,6,6,6,0 
 even
;================================================
RTTYPE3:
	tst.b 24(a0)
	beq.s pastype3
	tst.b 28(a0)
	bne.s morttype3

	lea ANIMD_KILLER(pc),a1
	move 12(a0),d0			;direction
	and #DR3,d0
	bne.s pastype3D
	lea ANIMG_KILLER(pc),a1
pastype3d:
	clr d0
	move.b 10(a0),d0			;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s prestype3
	clr.b 10(a0)
	move.b (a1),d0
prestype3:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts
morttype3:
	lea ANIMMD_KILLER(pc),a1
	move 12(a0),d0			;direction
	and #DR3,d0
	bne.s paMtype3D
	lea ANIMMG_KILLER(pc),a1
paMtype3d:
	clr d0
	move.b 10(a0),d0		;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s premtype3
	clr.b 24(a0)
	rts
premtype3:
	move.b d0,8(a0)
	addq.b #1,10(a0)
pastype3:
	rts

ANIMD_KILLER:
 dc.b 1,1,2,2,3,3,2,2,0
ANIMG_KILLER:
 dc.b 8,8,9,9,10,10,9,9,0
ANIMMG_KILLER:
 dc.b 11,11,11,11,11,12,12,12,12,12,6,6,6,6,6,7,7,7,7,7,0
ANIMMD_KILLER:
 dc.b 4,4,4,4,4,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7,0
even
;----------------------------
RTTYPE4:	;==- FLYING -==
	tst.b 24(a0)
	beq.s pasgertype4
	tst.b 28(a0)
	bne.s mortype4

	lea ANIMD_FLYING(pc),a1
	tst.b 14(a0)
	bpl.s pastype4d
	lea ANIMG_FLYING(pc),a1
pastype4d:
	clr d0
	move.b 10(a0),d0		;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s prestype4
	clr.b 10(a0)
	move.b (a1),d0
prestype4:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts
mortype4:
	lea ANIMM_FLYING(pc),a1
	clr d0
	move.b 10(a0),d0		;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s premtype4
	clr.b 24(a0)
	rts
premtype4:
	move.b d0,8(a0)
	addq.b #1,10(a0)
pasgertype4:
	rts

ANIMD_FLYING:
 dc.b 7,7,8,8,9,9,10,10,9,9,8,8,0
ANIMG_FLYING:
 dc.b 1,1,2,2,3,3,4,4,3,3,2,2,0
ANIMM_FLYING:
 dc.b 5,5,5,5,5,6,6,6,6,6,0
even
;================================================
RTTYPE5:	;-------- GARNIGAR
	tst.b 24(a0)			;gerer ?
	beq pasgertype5
	tst.b 28(a0)			;il meur ?
	bne morttype5

	move 12(a0),d0			;direction
	move d0,d1
	and #%0000111100000000,d1	;and (dr3+ga3)
	bne.s pastype5D

	tst.b 26(a0)
	beq.s pasplush
	move.b #0,26(a0)
	sub #20,18(a0)
pasplush:
	lea ANIMD_GARNIGAR(pc),a1
	and #DR3,d0
	bne.s pastype5B
	lea ANIMG_GARNIGAR(pc),a1
	bra.s pastype5B
pastype5D:
	tst.b 25(a0)			;descendre vers droite ?
	bne.s descvb			;oui
	lea ANIMHG_GARNIGAR(pc),a1
	move 12(a0),d0			;direction
	and #HA3,d0
	bne.s pastype5B
	lea ANIMBG_GARNIGAR(pc),a1
	tst.b 26(a0)
	bne.s pastype5b
	add #20,18(a0)
	move.b #1,26(a0)
pastype5B:
	bra.s contdect
descvb:
	lea ANIMHD_GARNIGAR(pc),a1
	move 12(a0),d0			;direction
	and #HA3,d0
	bne.s pastype5BB
	lea ANIMBD_GARNIGAR(pc),a1
	tst.b 26(a0)
	bne.s pastype5bb
	add #20,18(a0)
	move.b #1,26(a0)
pastype5BB:

contdect:
	clr d0
	move.b 10(a0),d0		;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s prestype5
	clr.b 10(a0)
	move.b (a1),d0
prestype5:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts

morttype5:
	lea TABLEM_GARNIGAR,a1
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s contmort5
	clr.b 24(a0) 
	rts
contmort5:
	ext d0
	add d0,ymap(a0)
	add.b #1,10(a0)

	lea ANIMM_GARNIGAR,a1
 	move.b (a1),8(a0)
	tst d0
	bmi.s pasanimvb
 	move.b 1(a1),8(a0)
pasanimvb:
pasgertype5:
	rts


ANIMD_GARNIGAR:
 dc.b 5,5,5,4,4,3,3,3,2,2,1,1,1,0
ANIMG_GARNIGAR:
 dc.b 1,1,1,2,2,3,3,3,4,4,5,5,5,0
ANIMBG_GARNIGAR:
 dc.b 8,8,9,9,9,10,10,10,11,11,12,12,8,0
ANIMHG_GARNIGAR:
 dc.b 8,8,12,12,11,11,10,10,10,9,9,9,8,0
ANIMHD_GARNIGAR:
 dc.b 13,13,14,14,15,15,16,16,16,17,17,17,13,0
ANIMBD_GARNIGAR:
 dc.b 13,13,17,17,16,16,15,15,15,14,14,14,13,0
ANIMM_GARNIGAR:
 dc.b 6,7
TABLEM_GARNIGAR:
 dc.b -6,-5,-4,-3,-2,-1,1,2,3,4,5,6,7,8,8,8,8,8,8,8,8,8,0
even
;--------------------------------------------
RTTYPE6:;----- ANIMATION WESBTAMITE -----
	tst.b 24(a0)			;le gerer ?
	beq.L pasgeretype6		;non  
	tst.b 28(a0)			;mort ??
	bne.L morttype6			;oui 

;---- gerer le tir ----
	addq.b #1,26(a0)
	cmp.b #50,26(a0)
	bmi.s pastirt6
	lea ANIMTIR_WEBSTAMI(pc),a1
	clr d0
	move.b 11(a0),d0		;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s ptirtype6
	clr.b 11(a0)
	clr.b 26(a0)

;-- initialiser les tir --
	move #6-1,d7
	lea tabledirtir,a3
inttw:	move.l #IMAGETIRWEBSTAMI,20(a2)
	move.b #1,8(a2)			;no anim
	move.b #1,9(a2)			;1 = activ les tir normal
	move.b #4,24(a2)		;type
	move.l xmap(a0),xmap(a2)
	add #14,xmap(a2)
	addq #2,ymap(a2)		
	move.w (a3)+,10(a2)		;dir x,y
	lea 26(a2),a2
	dbf d7,inttw
	lea -[6*26](a2),a2
	rts
ptirtype6:
	move.b d0,8(a0)
	addq.b #1,11(a0)
	rts
pastirt6:
	lea ANIMH_WEBSTAMI(pc),a1
	move 12(a0),d0			;dir
	and #HA3,d0
	bne.s pastype6D
	lea ANIMB_WEBSTAMI(pc),a1
pastype6d:
	clr d0
	move.b 10(a0),d0		;cpt
	move.b (a1,d0.w),d0		;no animation
	bne.s prestype6
	clr.b 10(a0)
	move.b (a1),d0
prestype6:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts

morttype6:
	lea ANIMM_WEBSTAMI(pc),a1
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s premtype6
	clr.b 24(a0)
;-- initialiser les tir quand mort --
	lea tabledirtirm,a3
	clr.b 25(a2)
	move #4-1,d7
minttw:
	move.l #IMAGETIRWEBSTAMI,20(a2)
	move.b #1,8(a2)			
	move.b #2,9(a2)		;2 = tir mort
	move.b #4,24(a2)		
	move.l xmap(a0),xmap(a2)
	add #14,xmap(a2)
	addq #2,ymap(a2)
	move.b (a3)+,10(a2)	
	lea 26(a2),a2
	dbf d7,minttw
	clr.b 9(a2)
	clr.b 26+9(a2)
	rts
premtype6:
	move.b d0,8(a0)
	addq.b #1,10(a0)
pasgeretype6:
	rts
ANIMH_WEBSTAMI:
 dc.b 1,1,1,1,3,3,3,3,1,1,1,1,4,4,4,4,0
ANIMB_WEBSTAMI:
 dc.b 1,1,1,1,3,3,3,3,1,1,1,1,4,4,4,4,0
ANIMM_WEBSTAMI:
 dc.b 5,5,5,5,6,6,6,6,7,7,7,7,0
ANIMTIR_WEBSTAMI:
 dc.b 1,1,2,2,0
tabledirtir:
 dc.b 2,-2,3,0,2,2,-2,2,-3,0,-2,-2
tabledirtirm:
 dc.b 4,3,-3,-4
even
;-------------------------------------------------
MORTBLASTUM:
	lea mblastumd(pc),a1
	btst #7,25(a0)
	beq.s ghk
	lea mblastumg(pc),a1
ghk:	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s dhh
	clr.b 24(a0)
	rts
dhh:	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts

RTTYPE7:	;-- BLASTUM ---
	tst.b 24(a0)
	bne.s conrtype7
	rts
conrtype7:
	tst.b 28(a0)
	bne.s MORTBLASTUM
	btst #7,24(a0)			;bit de deplacement rapide  ?
	beq.s deplacertype7		;oui 
	lea bobtoki,a5
	move 16(a5),d0			;cmp sur X
	btst #7,25(a0)			;bit pour gauche ?
	bne.s tsttype7g			;oui
	cmp 16(a0),d0			;non cmp pour X 
	bmi.s okrttype7
	move 18(a5),d0			;cmp pour Y
	cmp 18(a0),d0
	bne.s okrttype7
	bclr #7,24(a0)			;si ok deplacer
	rts
tsttype7g:
	cmp 16(a0),d0			;cmp pour X
	bpl.s okrttype7
	move 18(a5),d0			;cmp pour Y
	cmp 18(a0),d0
	bne.s okrttype7
	bclr #7,24(a0)			;si ok deplacer
	rts
okrttype7:
	lea ANIMD_BLASTUM(pc),a1
	btst #7,25(a0)			;tst direction 
	beq.s pastype7D
	lea ANIMG_BLASTUM(pc),a1
pastype7D:
	clr d0
	move.b 10(a0),d0		;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s prestype7			;pas fin de table
	clr.b 10(a0)			;fin de table
	move.b (a1),d0
prestype7:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts
deplacertype7:
	move.b 25(a0),d0
	moveq #6,d1			;vitesse de deplacement
	move.b #3,d2			;image par default
	btst #7,d0			;dep sur gauche ?
	beq.s pasnegd1			;non droite
	neg d1				;oui inv depl
	move.b #8,d2			;no image	
pasnegd1:
	bclr #7,d0			;int(depl)
	tst.b d0			;deja tout deplacer
	beq.s ctdeptype7		;oui on se casse
	move.b d2,8(a0)			;non on continu
	add d1,16(a0)
	subq.b #1,25(a0)
	rts
ctdeptype7:
	clr.b 24(a0)			;ne plus gerer le sprite 
	rts
ANIMD_BLASTUM:
 dc.b 1,1,1,2,2,2,2,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,0
ANIMG_BLASTUM:
 dc.b 6,6,6,7,7,7,7,6,6,6,7,7,7,7,7,7,7,7,7,7,7,7,0
mblastumd:
 dc.b 4,4,4,4,4,5,5,5,5,5,0
mblastumg:
 dc.b 9,9,9,9,9,10,10,10,10,10,0
even
;-------------------------------------------------
RTTYPE8:
	btst #2,25(a0)			;le gerer ??
	beq.s okgertype8
	rts
okgertype8:
	lea bobtoki,a5			;bob toki
	tst.b 24(a0)			;deja apparu ?
	bne.s okappartype8		;oui pas gerer test

	move.w xmap(a5),d0
	move.w xmap(a0),d1
	clr d2
	move.b 26(a0),d2
	sub d1,d0
;	tst d0
	bpl.s nonot
	neg d0
nonot:
	cmp d2,d0	
	bge.s noncc

	move ymap(a5),d0		;ymap toki
	move ymap(a0),d1
	sub d0,d1
	bmi.s noncc
	move.b 27(a0),d0
	ext d0
	cmp d1,d0
	bmi.s noncc 
	bra.s okappartype8
noncc:	rts				;non casse toi

okappartype8:
	or.b #3,24(a0)			;definir type 
	btst #5,25(a0)			;deja apparu
	bne.s oktype8			;oui casse toi

	lea ANIMAPPG_KALGATRO(pc),a1	;il apparait
	btst #7,25(a0)			;vers gauche ?
	bne.s apptype8versg		;oui
	lea ANIMAPPD_KALGATRO(pc),a1	;non alors droite
apptype8versg:				;non
	moveq #0,d0
	move.b 10(a0),d0		;cpt table apparaition 
	move.b (a1,d0.w),d0		;fin de table ?	
	bne.s ctappt8			;non
	bset #5,25(a0)			;flag deja apparu
	clr.b 10(a0)			;et reset cpt pour anim
	rts				;et casse toi
ctappt8:
	move.b d0,8(a0)			;no animation
	addq.b #1,10(a0)		;anim suivante
	rts

oktype8:
	tst.b 28(a0)			;il meur ?
	bne.s oktype8m			;oui alors mort 
	btst #3,25(a0)			;il disparait ?
	beq.s pasdisptype8		;non 
oktype8m:
	lea ANIMDISPG_KALGATRO(pc),a1	;oui le gerer
	btst #7,25(a0)			;vers gauche ?
	bne.s pasdisvg			;oui
	lea ANIMDISPD_KALGATRO(pc),a1	;non
pasdisvg:
	moveq #0,d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s prstdist8
	bset #2,25(a0)
	clr.b 24(a0)
	rts
prstdist8:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts

pasdisptype8:
	btst #4,25(a0)			;il peu tirer
	beq.s pastirtype8		;non casse toi
	move 16(a5),d0			;toki xmap
	sub 16(a0),d0			;enemi xmap
	bpl.s pasnegty8			;negatif ?
	neg d0				;oui inverse
	add #12,d0
pasnegty8:
	cmp #44,d0			;distance abs enemis <= 48 ?
	bge.s pastirtype8		;non il ne tir pas
	clr.b 10(a0)			;reset cpt animation
	lea ANIMTIRG_KALGATRO(pc),a1	;oui il tir
	btst #7,25(a0)			;vers gauche ?
	bne.s pastirvgt8		;oui
	lea ANIMTIRD_KALGATRO(pc),a1	;non
pastirvgt8:
	moveq #0,d0
	move.b 11(a0),d0		;cpt tir
	move.b (a1,d0.w),8(a0)		;no animation
	bne.s prty8			;fin de table
	clr.b 11(a0)			;oui boucle
	move.b -1(a1,d0.w),8(a0)
	bchg #4,25(a0)			;inv autoris tir
prty8:
;	move.b d0,8(a0)			;non continu
	addq.b #1,11(a0)		;anim suivante
	rts

pastirtype8:
	lea ANIMD_KALGATRO(pc),a1
	clr.b 11(a0)			;cpt tir a zero
	move 12(a0),d0			;direction
	and #DR3,d0
	bne.s pastype8D
	lea ANIMG_KALGATRO(pc),a1
pastype8d:
	moveq #0,d0
	move.b 10(a0),d0		;cpt
	move.b (a1,d0.w),d0		;charger no animation
	bne.s prestype8
	clr.b 10(a0)
	move.b (a1),d0
prestype8:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	bchg #4,25(a0)			;invers autoris tir
	rts

ANIMTIRG_KALGATRO:
 dc.b 4,4,5,5,6,6,2,2,2,0
ANIMTIRD_KALGATRO:
 dc.b 15,15,16,16,17,17,13,13,13,0
ANIMAPPG_KALGATRO:
 dc.b 11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,0
ANIMAPPD_KALGATRO:
 dc.b 22,22,22,21,21,21,20,20,20,19,19,19,18,18,18,0
ANIMDISPG_KALGATRO:
 dc.b 7,7,7,7,8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,0
ANIMDISPD_KALGATRO:
 dc.b 18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,21,22,22,22,22,0
ANIMG_KALGATRO:
 dc.b 2,2,2,2,3,3,3,3,2,2,2,2,1,1,1,1,0
ANIMD_KALGATRO:
 dc.b 13,13,13,13,14,14,14,14,13,13,13,13,12,12,12,12,0
even
;-------------------------------------------------
RTTYPE9:	;---- WOBALIN 
		;A2= ptr sur bobtir

	btst #6,25(a0)			;deja apparu ?
	bne.s dappt9			;oui
	lea bobtoki,a5			;gerer si apparait
	move.w xmap(a5),d0
	clr d2
	move.b 26(a0),d2
	sub xmap(a0),d0
	bpl.s nonot9
	neg d0
nonot9:
	cmp d2,d0			;tester pour x
	bge.s dappt9

	move ymap(a5),d0
	clr d2
	move.b 27(a0),d2
	sub ymap(a0),d0
	bpl.s nonott9
	neg d0
nonott9:
	cmp d2,d0		;tester pour Y
	bge.s dappt9

	bset #6,25(a0)
	move.b #5,24(a0)
	clr.b 10(a0)
dappt9:

;---- tester si animation apparaitre ----
	btst #5,25(a0)
	bne.s dejaappt9
	btst #6,25(a0)
	beq.s dejaappt9

	lea ANIMAPP_WOBALIN(pc),a1
	clr d0
	move.b 10(a0),d0			
	move.b (a1,d0.w),d0		
	bne.s praat9
	clr.b 10(a0)
	clr.b 11(a0)
	bset #5,25(a0)
	rts
praat9:	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts
dejaappt9:
;----------------------------------------
	tst.b 24(a2)			;gerer le tir de wobalin
	beq.s pasgtitt9
	bsr gtirwobalin
pasgtitt9:
	tst.b 24(a0)			;gerer ?
	beq pasgeretype9		;non casse toi

	tst.b 28(a0)			;il meur
	bne morttype9			;oui 
	btst #7,25(a0)			;il tir :
	bne tirtype9			;oui
	tst.b 24(a2)			;tir pas fini
	bne pts9			;oui anim 

;-- tester si wobalin tir sur toki --
	lea bobtoki,a5
	movem.w xmap(a5),d0-d1
	movem.w xmap(a0),d2-d3
	cmp d0,d2
	bge.s pts9	
	add 4(a0),d2
	cmp d0,d2
	ble.s pts9

	bset #7,25(a0)
	clr.b 11(a0)		;cpt tir 
	rts
pts9:
	lea ANIMD_WOBALIN(pc),a1
	move 12(a0),d0			;direction
	and #DR3,d0
	bne.s pastype9G
	lea ANIMG_WOBALIN(pc),a1
pastype9G:
	clr d0
	move.b 10(a0),d0			
	move.b (a1,d0.w),d0		
	bne.s prestype9
	clr.b 10(a0)
	move.b (a1),d0
prestype9:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts

morttype9:
	lea ANIMM_WOBALIN(pc),a1
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s premtype9
	clr.b 24(a0)
	rts
premtype9:
	move.b d0,8(a0)
	addq.b #1,10(a0)
pasgeretype9: 
	rts

tirtype9:
	lea ANITIR_WOBALIN(pc),a1
	clr d0
	move.b 11(a0),d0
	move.b (a1,d0.w),d0
	bne.s prettype9
	clr.b 10(a0)		;clr cpt anim
	clr.b 11(a0)		;clr cpt tir
	bclr #7,25(a0)		;plus de tir
	rts
prettype9:
	move.b d0,8(a0)
	addq.b #1,11(a0)

	cmp.b #10,11(a0)
	bne.s paft
	move.b #5,24(a2)
	move.b #8,8(a2)
	clr.b 10(a2)
	move.l xmap(a0),xmap(a2)
;	move.w ymap(a0),ymap(a2)
	add #30,16(a2) 
	add #16,18(a2) 
	move.l #imagewobalin,20(a2)
paft:	rts

gtirwobalin:
	cmp.b #20,10(a2)
	bmi.s conttirw
	clr.b 24(a2)
	rts
conttirw:
	addq #6,18(a2)
	addq.b #1,10(a2)
	rts

ANIMG_WOBALIN:
 dc.b 4,4,4,4,5,5,5,5,0
ANIMD_WOBALIN:
 dc.b 4,4,4,4,5,5,5,5,0
ANIMM_WOBALIN:
 dc.b 6,6,6,6,7,7,7,7,0
ANIMAPP_WOBALIN:
 dc.b 1,1,1,2,2,2,0
ANITIR_WOBALIN:
 dc.b 4,4,4,4,4,4,4,4,3,3,3,3,3,3,3,3,0
 even
;-------------------------------------------------
RTTYPE11:				;CUPPER
	tst.b 24(a0)			;gerer ?
	beq.s pasgertype11
	tst.b 28(a0)
	bne.s type11mort
	lea ADCUPPER(pc),a1
	move 12(a0),d0
	and #DR3,d0
	bne.s pastype11D
	lea AGCUPPER(pc),a1
pastype11d:
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s prestype11
	clr.b 10(a0)
	move.b (a1),d0
prestype11:
	move.b d0,8(a0)
	addq.b #1,10(a0)
	rts
type11mort:
	lea AMDCUPPER(pc),a1
	move 12(a0),d0	
	and #DR3,d0
	bne.s pastype11MD
	lea AMGCUPPER(pc),a1
pastype11MD:
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s contmort11
	clr.b 24(a0) 
	rts
contmort11:
	move.b d0,8(a0)
	add.b #1,10(a0)
pasgertype11:
	rts
AGCUPPER: dc.b 12,12,12,13,13,13,14,14,14,15,15,15,0
ADCUPPER: dc.b 1,1,1,2,2,2,3,3,3,4,4,4,0
AMDCUPPER:dc.b 5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8,0
AMGCUPPER:dc.b 11,11,11,11,10,10,10,10,9,9,9,9,8,8,8,8,0
 even
;---------------------------------------------------
RTTYPE10:			;PETIT POISSON ROUGE
	tst.b 24(a0)
	beq.s pasgertype10
	tst.b 28(a0)
	bne.s type10mort

	tst.b 11(a0)		;actif ? (0=actif)
	beq.s vnj		;oui 
	lea bobtoki,a5
	move.w xmap(a5),d0
	move xmap(a0),d1
	sub d0,d1
;	tst d1
	bpl.s dcbn
	neg d1
dcbn:	cmp #170,d1
	bpl.s cttype10		;pas activer
	clr.b 11(a0)

vnj:	lea ANIMD_POISSON(pc),a1
	move 12(a0),d0
	and #DR3,d0
	bne.s pastype10D
	lea ANIMG_POISSON(pc),a1
pastype10d:
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s prestype10
	clr.b 10(a0)
	move.b (a1),d0
prestype10:
	move.b d0,8(a0)
	addq.b #1,10(a0)
cttype10:
	rts

type10mort:
	lea ANIMM_POISSON(pc),a1
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s contmort10
	clr.b 24(a0) 
	rts
contmort10:
	move.b d0,8(a0)
	addq.b #1,10(a0)
pasgertype10:
	rts
ANIMD_POISSON:
 dc.b 5,5,5,5,6,6,6,6,0
ANIMG_POISSON:
 dc.b 1,1,1,1,2,2,2,2,0
ANIMM_POISSON:
 dc.b 3,3,3,3,3,4,4,4,4,4,0
 even
;================================================
STOP=%0000000000000000
TIR=%1111111100000000
DR1=%0100000000000000
DR2=%1000000000000000
DR3=%1100000000000000
GA1=%0001000000000000
GA2=%0010000000000000
GA3=%0011000000000000
HA1=%0000010000000000
HA2=%0000100000000000
HA3=%0000110000000000
BA1=%0000000100000000
BA2=%0000001000000000
BA3=%0000001100000000
;------------------------------------------------
;------------------------------------------------
ANIMATIONDECORT1:		;MONTANT
	tst.b flagsaut
	beq.s pasccla
	clr.b fltdec1
pasccla:

	tst.b fltdec1
	bne.s aokflt

;-- reajuster montant vers haut --
	tst.b 11(a0)
	beq.s pasvhh
	subq.b #1,11(a0)
	subq #2,ymap(a0)
pasvhh:
	bsr testerxx
	tst d0
	beq.s appcolm

	cmp #1,pesanteur	;pes <1 ? 
	ble.s appcolm		;oui 

	move ymap(a5),d0
	add depy,d0
	move ymap(a0),d1
	sub 6(a0),d1
	cmp d0,d1
	bge.s appcolm
	add #14,d1
	cmp d0,d1
	ble.s appcolm
aokflt:
	bsr testerx
	tst d0
	bne.s aenccolm
	move.b #0,fltdec1
	rts

aenccolm:
	tst.b flagmort
	bne.s appcolm

	move ymap(a0),d0
	sub 6(a0),d0
	move d0,ymap(a5)
	move.b #1,fltdec1
	move #1,pesanteur
	clr.b flagsaut
	clr depy
	addq #2,ymap(a0)
	addq.b #1,11(a0)		;cpt
	move ymap(a0),d0
	sub 6(a0),d0
	move d0,ymap(a5)
appcolm:rts
;-------------------------------
ANIMATIONDECORT2:
	bsr animdecortt1

	tst.b flagsaut
	beq.s pascclb
	clr.b fltdec2
pascclb:
	tst.b fltdec2
	bne.s okflt

	bsr testerx
	tst d0
	beq.s ppcolm

	cmp #1,pesanteur	;pes <1 ? 
	ble.s ppcolm		;oui 

	move ymap(a5),d0
	add depy,d0
	move ymap(a0),d1
	sub 6(a0),d1
	cmp d0,d1
	bge.s ppcolm
	add #14,d1
	cmp d0,d1
	ble.s ppcolm
okflt:
	bsr testerx
	tst d0
	bne.s enccolm
	move.b #0,fltdec2
	rts
enccolm:
	move ymap(a0),d0
	sub 6(a0),d0
	move d0,ymap(a5)
	move.b #1,fltdec2
	move #1,pesanteur
	clr.b flagsaut
	clr depy

	move.b 25(a0),d0
	ext d0
	move d0,depdecorx
ppcolm:	rts
;---------------------------------------------
ANIMATIONDECORT3:		;REBORD
	tst.b 24(a0)
	beq.s ppcolm

	tst.b flagsaut
	beq.s pascclc
	clr.b fltdec3
pascclc:
	tst.b 25(a0)
	beq.s pasget
	bsr gerertombe
pasget:
	tst.b fltdec3
	bne.s cokflt

	bsr testerx
	tst d0
	beq.s cppcolm

	cmp #1,pesanteur	;pes <1 ? 
	ble.s cppcolm		;oui 

	move ymap(a5),d0
	add depy,d0
	move ymap(a0),d1
	sub 6(a0),d1
	cmp d0,d1
	bge.s cppcolm
	add #14,d1
	cmp d0,d1
	ble.s cppcolm
cokflt:
	bsr testerx
	tst d0
	bne.s cenccolm
	clr.b fltdec3
	rts
cenccolm:
	move ymap(a0),d0
	sub 6(a0),d0
	move d0,ymap(a5)
	move.b #1,fltdec3
	move #1,pesanteur
	clr.b flagsaut
	clr depy
	move.b #1,25(a0)
cppcolm:
	rts
gerertombe:
	addq.b #1,11(a0)		;cpt
	move.b 11(a0),d1
	cmp.b #25,d1
	bmi.s colm
	cmp.b #40,d1
	bpl.s bcolm
	neg.b 27(a0)
	move.b 27(a0),d0	
	ext d0
	add d0,ymap(a0)
	bra.s colm

bcolm:	cmp.b #40,d1
	bmi.s colm
	moveq #0,d0
	move.b 12(a0),d0
	add d0,ymap(a0)
	addq.b #1,12(a0)
	cmp.b #50,d1		;encore le gerer
	bmi.s colm		;oui
	clr.b 24(a0)		;non
colm:	rts

;-----------
 fltdec1:dc.b 0
 fltdec2:dc.b 0
 fltdec3:dc.b 0
 fltdec6:dc.b 0
 even
;-------------------------------
ANIMATIONDECORT4:
	tst.b 24(a0)
	beq.s pdecort4
	tst.b 28(a0)
	bne.s mortdecort4
	bsr bcolltirbob
pdecort4:
	rts
mortdecort4:
	lea tmdecort4(pc),a1
	clr d0
	move.b 10(a0),d0
	move.b (a1,d0.w),d0
	bne.s cmde4
	clr.b 24(a0)
	rts
cmde4:	move.b d0,8(a0)
	addq.b #1,10(a0)

	cmp.b #1,10(a0)
	bne.s pinittp
;-- initialiser tir (a2) --
	lea tdirboule(pc),a3
	moveq #5-1,d0
inttploop:
	move.b #1,8(a2)
	move.w (a3)+,10(a2)		;dir x,y
	move.l #imageboule,20(a2)
	move.b #3,24(a2)
	movem.w xmap(a0),d1-d2
	addq #8,d1
	subq #8,d2
	movem.w d1-d2,xmap(a2)
	lea 26(a2),a2
	dbf d0,inttploop
pinittp:rts

tmdecort4:
 dc.b 1,2,2,2,2,3,3,3,3,0
 even
tdirboule:
 dc.b -4,0,-3,-3,0,-4,3,-3,4,0
;-------------------------------
ANIMATIONDECORT5:	;TREMPLIN poid droite

	lea bobtoki,a5
	tst.b 9(a0)
	bne.s okpoid

	move.w xmap(a5),d0
	move.w xmap(a0),d1

	cmp #1,pesanteur
	beq.s pcoltre
	bmi.s pcoltre 

	move d0,d2		;xg ?
	add 4(a5),d0
	cmp d0,d1
	bge.s pcoltre

	add #16,d1		;xd ?
	cmp d2,d1
	ble.s pcoltre
	move ymap(a5),d0
	move ymap(a0),d1
	cmp d0,d1		;yb ?
	ble.s pcoltre
	sub #13,d1		;yh ?
	cmp d0,d1
	bge.s pcoltre

	move.b #2,8(a0)
	move.b #1,9(a0)		;flag pour premplin
	clr.b 10(a2)
pcoltre:rts

okpoid:	tst.b 9(a0)		;poid ?
	beq paspoid
	lea tblpoid(pc),a1
	clr d0
	move.b 10(a2),d0
	move.b (a1,d0.w),d0
	bne.s cttre
	clr.b 9(a0)
	move.b #3,8(a0)

	move.w xmap(a5),d0
	move.w xmap(a0),d1
	move d0,d2		;xg ?
	add 4(a5),d0
	cmp d0,d1
	bge.s pasrebond
	add #16,d1		;xd ?
	cmp d2,d1
	ble.s pasrebond
	move ymap(a5),d0	;yh ?
	move ymap(a0),d1
	sub #13,d1
	cmp d0,d1
	bge.s pasrebond

	move.b #1,flagsaut

	clr d0
	move.b 12(a0),d0
	move.b 10(a0,d0.w),d0
	ext d0
	move d0,pesanteur	;force 1 ou 2
	eor.b #1,12(a0)

	move.b #14,8(a5)
	tst.b oldposition
	beq.s nodf
	move.b #13,8(a5)	
nodf:	rts

cttre:	ext d0
	add d0,ymap(a2)
	addq.b #1,10(a2)	
paspoid:rts

pasrebond:
	move.b #0,12(a0)
	rts

tblpoid:
 dc.b -11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,1,2,3,4,5,6,7,8,9,10,11,0
 even
;------------------------------
ANIMATIONDECORT5B:	;TREMPLIN poid gauche
	lea bobtoki,a5
	tst.b 9(a0)
	bne.s bokpoid

	move.w xmap(a5),d0
	move.w xmap(a0),d1

	cmp #1,pesanteur
	beq.s bpcoltre
	bmi.s bpcoltre 

	add 4(a0),d1
	addq #8,d0
	cmp d0,d1
	ble.s bpcoltre
	sub #30,d1		;xd ?
	cmp d0,d1
	bge.s bpcoltre
	move ymap(a5),d0
	move ymap(a0),d1
	cmp d0,d1		;yb ?
	ble.s bpcoltre
	sub #13,d1		;yh ?
	cmp d0,d1
	bge.s bpcoltre

	move.b #3,8(a0)
	move.b #1,9(a0)		;flag pour premplin
	clr.b 10(a2)
bpcoltre:
	rts

bokpoid:
	tst.b 9(a0)		;poid ?
	beq bpaspoid
	lea tblpoid(pc),a1
	moveq #0,d0
	move.b 10(a2),d0
	move.b (a1,d0.w),d0
	bne.s bcttre
	clr.b 9(a0)
	move.b #2,8(a0)

	move.w xmap(a5),d0
	move.w xmap(a0),d1

	add 4(a0),d1
	addq #8,d0
	cmp d0,d1
	ble.s bpasrebond
	sub #30,d1		;xd ?
	cmp d0,d1
	bge.s bpasrebond
	move ymap(a5),d0	;yh ?
	move ymap(a0),d1
	sub #13,d1
	cmp d0,d1
	bge.s bpasrebond

	move.b #1,flagsaut

	clr d0
	move.b 12(a0),d0
	move.b 10(a0,d0.w),d0
	ext d0
	move d0,pesanteur	;force 1 ou 2
	eor.b #1,12(a0)

	move.b #14,8(a5)
	tst.b oldposition
	beq.s dffg
	move.b #13,8(a5)	
dffg:	rts
bcttre:	ext d0
	add d0,ymap(a2)
	addq.b #1,10(a2)	
bpaspoid:
	rts
bpasrebond:
	move.b #0,12(a0)
	rts
;--------------------
ANIMATIONDECORT6:		;JET D'ESAU
	clr.b 26(a0)
	clr.b 25(a0)
	bsr animdecortt1

	bchg #0,27(a0)
	beq.s noflp
	and.b #3,8(a0)
	addq.b #1,8(a0)
noflp:	bchg #0,27(a2)
	beq.s noflpb
	and.b #3,8(a2)
	addq.b #5,8(a2)
noflpb:	tst.b flagsaut
	beq.s pascclb6
	clr.b fltdec6
pascclb6:
	tst.b fltdec6
	bne.s okflt6

	bsr testerx
	tst d0
	beq ppcolm6

	cmp #1,pesanteur	;pes <1 ? 
	ble ppcolm6		;oui 

	move ymap(a5),d0
	add depy,d0
	move ymap(a0),d1
	sub 6(a0),d1
	add #16,d1
	cmp d0,d1
	bge ppcolm6
	add #14,d1
	cmp d0,d1
	ble.s ppcolm6
okflt6:
	bsr testerx
	tst d0
	bne.s enccolm6
	move.b #0,fltdec6
	rts

enccolm6:
	move ymap(a5),d0
	move ymap(a0),d1
	sub 6(a0),d1
	add #38,d1
	cmp d0,d1
	ble.s ppcolm6

	move.b #1,fltdec6
	move #1,pesanteur
	clr.b flagsaut
	clr depy

	move.b 26(a0),d0
	ext d0
	move d0,depdecory

	and.b #2,25(a0)
	addq.b #1,25(a0)
	move.b 25(a0),d0
	ext d0
	move xmap(a5),d1	;tester si glisse d/g
	move xmap(a0),d2
	add #29,d2
	add #16,d1
	cmp d1,d2
	ble.s nnegd
	neg d0	
nnegd:	move d0,depdecorx
ppcolm6:
	rts
;-------------------------
testerx:lea bobtoki,a5		;test collision
	move.w xmap(a5),d0
	move.w xmap(a0),d2	
	move d0,d1
	move d2,d3
	add 4(a5),d1
	cmp d1,d2
	bge.s notx
	add 4(a0),d3
	cmp d0,d3
	ble.s notx
	moveq #1,d0
	rts	
notx:	moveq #0,d0
	rts
testerxx:
	lea bobtoki,a5			;test collision
	move.w xmap(a5),d0
	move.w xmap(a0),d2	
addq #8,d0
	cmp d0,d2
	bge.s notxx
sub #12,d0
	add 4(a5),d0
	add 4(a0),d2
	cmp d0,d2
	ble.s notxx
	moveq #1,d0
	rts	
notxx:	moveq #0,d0
	rts
;------------------------------------------------
animdecortt1:
	move ymap(a0),d6	;pour y
	move xmap(a0),d5	;pour x
	move 12(a0),d7
	tst.b d7
	bne.s denoreset
	move 14(a0),d7
	move (a6,d7.w),d7
	bne.s denoreset1
	clr 14(a0)
	move (a6),d7
denoreset1:
	addq #2,14(a0)
denoreset:
	subq.b #1,d7
	move.w d7,12(a0)

	rol #2,d7
	moveq #%11,d0
	and d7,d0
	add d0,d5		;droite

	tst d0
	beq.s pplus
	move.b d0,25(a0)		;ofset x
pplus:
;--
	rol #2,d7
	moveq #%11,d0
	and d7,d0
	sub d0,d5			;gauche

	tst d0
	beq.s pmoins
	ror #1,d0
	not.b d0
	move.b d0,25(a0)		;ofset x
pmoins:
;--
	rol #2,d7
	moveq #%11,d0
	and d7,d0
	sub d0,d6			;haut
	tst d0
	beq.s pmoiny
	neg.b d0
	move.b d0,26(a0)
pmoiny:
;--
	rol #2,d7
	and.w #%11,d7
	add d7,d6			;bas
tst d7
beq.s bpmoiny
ror #1,d7
move.b d7,26(a0)
bpmoiny:
;--
	move d5,xmap(a0)
	move d6,ymap(a0)
decontianimen:
	rts
;================================================
;================================================
PTRANIMBOBDEC1:
 dc.w 0
;-------
PTRANIMBOBDEC2:
 dc.w ga2+50,dr2+50,0
;-------
PTRANIMBOBDEC3:
 dc.w 0
;-------
PTRANIMBOBDEC6:
 dc.w BA2+30,STOP+20,HA2+30,STOP+20,0

;================================================
PTRANIMBOB2:
 dc.w dr1+20,ba1+20,ga1+20,ha1+20,0
;-------------------------------------------------
PTRANIMBOB3:
 dc.w ga2+96,dr2+96,0
;------------------------------------------------
PTRANIMBOB4:
 dc.w ga2+26,dr2+26,0
;------------------------------------------------
PTRANIMBOB5:
 dc.w ga2+50,dr2+50,0
;------------------------------------------------
PTRANIMBOB6:
 dc.w ga3+ha1+10,ga3+ha2+10,ga3+ha1+10,ga3+10
 dc.w ga3+ba1+10,ga3+ba2+10,ga3+ba1+10,ga3+10
 dc.w 0
;-------------------------------------------------
PTRANIMBOB7:
 dc.w ga2+ba1+15,ga2+ha1+15,ba2+7
 dc.w dr2+ha1+15,dr2+ba1+15,ha2+7,0
;-------------------------------------------------
PTRANIMBOB8:
 dc.w ga2+38,dr2+38,0
;-------------------------------------------------
PTRANIMBOB9:
 dc.w ga2+ha1+30,ga2+ba1+30
 dc.w dr2+ha1+30,dr2+ba1+30,0
;-------------------------------------------------
PTRANIMBOB10:
 dc.w ga2+ba1+10,ga2+ha1+10
 dc.w dr2+ba1+10,dr2+ha1+10,0
;-------------------------------------------------
PTRANIMBOB11:
 dc.w 0
;-------------------------------------------------
PTRANIMBOB12:
 dc.w 0
;-------------------------------------------------
PTRANIMBOB13:
 dc.w 0
;-------------------------------------------------
PTRANIMBOB14:
 dc.w ga1+84,ba1+60,ha1+60,ba1+60,ha1+60,dr1+84,0
;-------------------------------------------------
PTRANIMBOB15:
 dc.w ba1+90,ha1+90,0
;----------------------------
PTRANIMBOB16:
 dc.w ba1+50,ha1+90,ba1+40,0
;-------------------------------------------------
PTRANIMBOB17:
 dc.w ba1+5,ba2+5,ba3+18,ba2+5,ba1+5
 dc.w ha1+5,ha2+5,ha3+18,ha2+5,ha1+5
;-------------------------------------------------
PTRANIMBOB18:
 dc.w ba1+4,ba2+4,ba3+10,ba2+4,ba1+4
 dc.w ha1+4,ha2+4,ha3+10,ha2+4,ha1+4
;-------------------------------------------------
PTRANIMBOB19:
 dc.w ba1+4,ba2+4,ba3+10,ba2+4,ba1+4
 dc.w ha1+4,ha2+4,ha3+10,ha2+4,ha1+4
;-------------------------------------------------
PTRANIMBOB20:
 dc.w stop+1,0
;-------------------------------------------------
PTRANIMBOB21:
 dc.w stop+1,0
;-------------------------------------------------
PTRANIMBOB22:
 dc.w ga3+32,0
;-------------------------------------------------
PTRANIMBOB23:
 dc.w dr3+74,0
;-------------------------------------------------
PTRANIMBOB24:
 dc.w dr3+30,0
;-------------------------------------------------
PTRANIMBOB25:
 dc.w ga3+53,0
;-------------------------------------------------
PTRANIMBOB26:
 dc.w ga1+5,ga2+10,ga3+20,ga2+10,ga1+5
 dc.w dr1+5,dr2+10,dr3+20,dr2+10,dr1+5,0
;-------------------------------------------------
PTRANIMBOB27:
 dc.w ga1+5,ga2+10,ga3+20,ga2+10,ga1+5
 dc.w dr1+5,dr2+10,dr3+20,dr2+10,dr1+5,0
;------------
PTRANIMBOB28:
 dc.w ga1+100,0
;------------------
PTRANIMBOB29:
 dc.w dr1+5,dr2+10,dr3+10,dr2+10,dr1+5
 dc.w ga1+5,ga2+10,ga3+10,ga2+10,ga1+5,0

;-------------------------------------------------------
;-------------------------------------------------------
;------- collision avec le relief JCM ------------------
;-------------------------------------------------------
;-------------------------------------------------------
COLLISIONRELIEFENEMIS:
	move	xmap(a0),a1
	move	ymap(a0),a2

	clr	d3
	move	a2,d2
	add	d0,a1		;dep x
	add	d1,a2		;dep y

	move	a2,a4
	sub	6(a0),a4
	move	a1,a3
	add	4(a0),a3

	clr.b	flagdiag

	bsr.s	gere_relief2
	rts		;SORTIE
			;d0=depx
			;d1=depy
			;d2=y sol
			;d3=collision
;d3 :
;	bit 0=collision en X
;	bit 1=collision en Y
;	bit 2=flag liane
;	bit 3=flag eau
;	bit 7=flag mort
;
; etat des registres :
;
; d4=X1,d5=Y1-h1,d6=X1+d1,d7=Y1
;
ENDRE:	MACRO
	move	(a6)+,d4
	bpl	loop_rel2
	rts
	ENDM

eno_relief:rts

gere_relief2:
;	lea	relief0(pc),a6
	lea tblrelief(pc),a6
	move level,d4
	subq #1,d4
	add d4,d4
	add d4,d4
	move.l 	(a6,d4.w),a6

	move	(a6)+,d4
	bmi.s	eno_relief

loop_rel2:
	jmp	erel1(pc,d4.w)
erel1:	bra	ecolrel0
	bra	ecolrel1	;diagonale bas-droite
	bra	ecolrel2	;liane verticale gauche
	bra	ecolrel3	;liane horizontale
	bra	ecolrel4	;mort
	bra	ecolrel5	;dfinition de zone
	bra	ecolrel6	;liane verticale milieu
	bra	ecolrel7	;liane verticale droite
	bra	ecolrel8	;eau
	bra	ecolrel9	;diag bas-gauche

enocol:	ENDRE

ecolrel0:
	movem	(a6)+,d4-d7
erescan0:
	cmp	a3,d4
	bge.s	enocol
	cmp	d6,a1
	bge.s	enocol
	cmp	a2,d5
	bge.s	enocol
	cmp	d7,a4
	bge.s	enocol

	cmp	d4,a1
	blt.s	notint
	cmp	a3,d6
	blt.s	notint
	cmp	d5,a4
	blt.s	notint
	cmp	a2,d7
	blt.s	notint

	clr	d0
	or	#%11,d3
	tst	d1
	bmi.s	erentry3
	cmp	d2,d5
	blo.s	erentry3
	move	d5,d2
	clr.b	flagsaut2
erentry3:
	clr	d1
	bra.s	enocol

notint:
	btst	#0,d3
	bne.s	erentrx2

movem d3-d4,-(sp)
sub a1,d4
eor d0,d4
movem (sp)+,d3-d4
bmi.s erentrx2

	movem	d4/d6,-(sp)
	sub	a1,d4
	sub	a3,d6
	eor	d4,d6
	movem	(sp)+,d4/d6
	bmi.s	erentrx2

;	sub	d0,a1
;	sub	d0,a3
	clr	d0
	bset	#0,d3

	cmp	a2,d5
	bge.s	enocol
	cmp	d7,a4
	bge.s	enocol

erentrx2:
	btst	#1,d3
	bne.s	erentry2

movem d4-d5,-(sp)
sub a4,d5
eor d1,d5
movem (sp)+,d4-d5
bmi.s erentry2

	movem	d5/d7,-(sp)
	sub	a4,d5
	sub	a2,d7
	eor	d5,d7
	movem	(sp)+,d5/d7
	bmi.s	erentry2

	tst	d1
	bmi.s	erentry1

	cmp	d2,d5
	blo.s	erentry1
	move	d5,d2
	clr.b	flagsaut2
erentry1:
	clr	d1
	bset	#1,d3
erentry2:
	ENDRE
ecolrel2:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	enocol2
	cmp	d6,a1
	bge.s	enocol2

	cmp	a2,d5
	bge.s	enocol2
	cmp	d7,a4
	bge.s	enocol2
	move.b	#1,flagliane2
	bset	#2,d3
enocol2:ENDRE
ecolrel6:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	enocol6
	cmp	d6,a1
	bge.s	enocol6

	cmp	a2,d5
	bge.s	enocol6
	cmp	d7,a4
	bge.s	enocol6
	move.b	#2,flagliane2
	bset	#2,d3

enocol6:ENDRE

ecolrel7:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	enocol7
	cmp	d6,a1
	bge.s	enocol7

	cmp	a2,d5
	bge.s	enocol7
	cmp	d7,a4
	bge.s	enocol7

	move.b	#3,flagliane2
	bset	#2,d3

enocol7:ENDRE

ecolrel3:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	enocol3
	cmp	d6,a1
	bge.s	enocol3

	cmp	a2,d5
	bge.s	enocol3
	cmp	d7,a4
	bge.s	enocol3

	st	flagliane2
	bset	#2,d3

enocol3:ENDRE

ecolrel1:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	enocol1
	cmp	d6,a1
	bge.s	enocol1

	cmp	a2,d5
	bge.s	enocol1
	cmp	d7,a4
	bge.s	enocol1

	cmp	d6,a3
	bgt.s	enocol1

	sub	d0,d1
	sub	d0,a2
	sub	d0,a4

	move	d7,d5
	add	d4,d5
	sub	a3,d5

	cmp	d5,a2
	blt.s	enocol1

	move.b	#1,flagdiag
	move	d5,d2
	clr	d1
	or	#%11,d3
enocol1:
	ENDRE

ecolrel5:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	enocol5
	cmp	d6,a1
	bge.s	enocol5

	cmp	a2,d5
	bge.s	enocol5
	cmp	d7,a4
	bge.s	enocol5
	addq	#2,a6
	ENDRE
enocol5:add	(a6),a6
	ENDRE

ecolrel4:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	enocol4
	cmp	d6,a1
	bge.s	enocol4

	cmp	a2,d5
	bge.s	enocol4
	cmp	d7,a4
	bge.s	enocol4
	clr	d1
	move	d5,d2
	st	flagmort2
	tas	d7
enocol4:
	ENDRE

ecolrel8:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	enocol8
	cmp	d6,a1
	bge.s	enocol8

	cmp	a2,d5
	bge.s	enocol8
	cmp	d7,a4
	bge.s	enocol8
	clr	d1
	move	d5,d2
	bset	#3,d3
enocol8:
	ENDRE


ecolrel9:
	movem	(a6)+,d4-d7


	ENDRE

flagdiag:	dc.b	0
flagliane2:	dc.b	0
flagsaut2:	dc.b	0
flagmort2:	dc.b	0
	even

;-------------------------------------------------------
;------- collision avec le relief JCM ------------------
;-------------------------------------------------------
COLLISIONRELIEF:

	move	depx,d0
	move	depy,d1

	move	xmap(a0),a1
	move	ymap(a0),a2
	move	a2,d2

	add	d0,a1
	add	d1,a2

	move	a2,a4
	sub	6(a0),a4
	move	a1,a3
	lea 32(a3),a3		;tailx toki fix pour collision
tst.b flageau
beq.s dwl
lea 10(a3),a3
dwl:
	lea	6(a1),a1	;marge
	lea	-14(a3),a3	;marge

	addq	#8,a4

	clr.b	flagliane
	clr.b	flagdi
	clr.b flageau
	move.b	flagsol,latchsol
	clr.b	flagsol

	bsr.s	gere_relief

	clr d4
	tst.b	flagsol
 	bne.s	noflagsol
	move	d1,d4
;	move.b #1,flagsaut
noflagsol:
	addq	#1,d4
	cmp	#10,d4
	ble.s	nomag
	moveq	#10,d4
nomag:
	move	d4,pesanteur
	add	d0,xmap(a0)
	add	d2,d1
	move	d1,ymap(a0)
	rts
flagsol:dc.b	0
latchsol:dc.b	0

;	d0=depx
;	d1=depy
;	d2=ysol
;	a1=Xgauche
;	a2=Ybas
;	a3=Xdroite
;	a4=Yhaut

ENDREL:	MACRO
	move	(a6)+,d4
	bpl	loop_rel
	rts
	ENDM

no_relief:rts

gere_relief:
	lea tblrelief(pc),a6
	move level,d4
	subq #1,d4
	add d4,d4
	add d4,d4
	move.l 	(a6,d4.w),a6
	move	(a6)+,d4
	bmi.s	no_relief

loop_rel:
	jmp	rel1(pc,d4.w)
rel1:	bra	colrel0		;bloc normal
	bra	colrel1		;diagonale bas-droite
	bra	colrel2		;liane verticale gauche
	bra	colrel3		;liane horizontale
	bra	colrel4		;mort
	bra	colrel5		;dfinition de zone
	bra	colrel6		;liane verticale milieu
	bra	colrel7		;liane verticale droite
	bra	colrel8		;eau
	bra	colrel9		;diag bas-gauche

nocol:	ENDREL

colrel0:
	movem	(a6)+,d4-d7
rescan0:
	cmp	a3,d4
	bge.s	nocol
	cmp	d6,a1
	bge.s	nocol
	cmp	a2,d5
	bge.s	nocol
	cmp	d7,a4
	bge.s	nocol
tst.b flagdi
bne.s rentrx2

	tst	d0
	beq.s	rentrx2
	bmi.s	rentrx1
	cmp	d4,a1
	bge.s	rentrx2

	cmp	ymap(a0),d5
	beq.s	rentrx2
	sub	d0,a1
	sub	d0,a3
	clr	d0
	bra.s	rescan0
rentrx1:
	cmp	a3,d6
	bge.s	rentrx2
	cmp	ymap(a0),d5
	beq.s	rentrx2
	sub	d0,a1
	sub	d0,a3
	clr	d0
	bra.s	rescan0
rentrx2:
	tst	d1
	beq.s	rentry2
	bmi.s	rentry1

	cmp	d5,a4
	bge.s	rentry2

	clr	d1
	cmp	d2,d5
	blo.s	rentry2
	move	d5,d2
	clr.b	flagsaut
	st	flagsol
	bra.s	rentry2
rentry1:
	cmp	a2,d7
	bge.s	rentry2
	clr	d1
rentry2:
	ENDREL
colrel2:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	nocol2
	cmp	d6,a1
	bge.s	nocol2

	subq #1,d5
	cmp	a2,d5
	bge.s	nocol2
	cmp	d7,a4
	bge.s	nocol2

	clr.b flagsaut
	ori.b #2,flagliane
	addq #1,d5
	move d5,lianey
	move d4,lianex
	subq #6,lianex
nocol2:	ENDREL

colrel6:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	nocol6
	cmp	d6,a1
	bge.s	nocol6

	subq #1,d5
	cmp	a2,d5
	bge.s	nocol6
	cmp	d7,a4
	bge.s	nocol6

	clr.b flagsaut
	ori.b #8,flagliane
	addq #1,d5
	move d5,lianey
	move d4,lianex
	subq #6,lianex
nocol6:	ENDREL

colrel7:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	nocol7
	cmp	d6,a1
	bge.s	nocol7

	subq #1,d5
	cmp	a2,d5
	bge.s	nocol7
	cmp	d7,a4
	bge.s	nocol7

	clr.b flagsaut
	ori.b #4,flagliane
	addq #1,d5
	move d5,lianey
	move d4,lianex
	subq #6,lianex
nocol7:	ENDREL


colrel3:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	nocol3
	cmp	d6,a1
	bge.s	nocol3

	subq	#1,d5
	cmp	a2,d5
	bge.s	nocol3
sub #16,d7
	cmp	d7,a4
	bge.s	nocol3

	clr.b  flagsaut
	or.b	#1,flagliane
	addq	#1,d5
	move	d5,lianey
nocol3:	ENDREL

colrel1:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	nocol1
;	cmp	d6,a1
;	bge.s	nocol1
	cmp	d6,a3
	bgt.s	nocol1

	cmp	a2,d5
	bge.s	nocol1
	cmp	d7,a4
	bge.s	nocol1

;	move	d7,d5
;	add	d4,d5
;	sub	a3,d5

	move d4,d6
add d7,d4
sub a3,d4

	cmp	#1,d1
	bne.s	isthere1

	sub a1,d6
	addq #4,d6
	cmp #8,d6
	bhs.s tovj

	move a2,d6
	sub d5,d6
	addq #4,d6
	cmp #8,d6
	blo.s isthere1
tovj:
	tst.b	latchsol
	bne.s	alwayssol
isthere1:
	cmp	d4,a2
	blt.s	nocol1
alwayssol:
	sub	d0,a2
	sub	d0,a4

	clr	d1
	st	flagdi
	st	flagsol
	clr.b	flagsaut
	move	d4,d2

	subq	#4,d7
	cmp	d7,d4
	ble.s	verifx
	move	d7,d2
	clr.b flagdi
verifx:
	addq #4,d5
	cmp d5,d4
	bge.s nocol1
	move d5,d2
	clr.b flagdi
nocol1:
	ENDREL

colrel5:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	nocol5
	cmp	d6,a1
	bge.s	nocol5

	cmp	a2,d5
	bge.s	nocol5
	cmp	d7,a4
	bge.s	nocol5
	addq	#2,a6
	ENDREL
nocol5:	add	(a6),a6
	ENDREL

colrel4:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	nocol4
	cmp	d6,a1
	bge.s	nocol4

	cmp	a2,d5
	bge.s	nocol4
	cmp	d7,a4
	bge.s	nocol4
	clr	d1
	move	d5,d2
	st	flagsol

cmp.b #$46,touche
bne.s pmortc
	st	flagmort
pmortc:

	clr.b flagsaut
nocol4:
	ENDREL

colrel8:
	movem	(a6)+,d4-d7
	cmp	a3,d4
	bge.s	nocol8
	cmp	d6,a1
	bge.s	nocol8

	cmp	a2,d5
	bge.s	nocol8
	cmp	d7,a4
	bge.s	nocol8
;	clr	d1
;	move	d5,d2
	st	flageau
	clr.b flagsaut
nocol8:
	ENDREL


colrel9:
	movem	(a6)+,d4-d7

	ENDREL

;;-------------------------------------
depx:		dc.w	0	;deplacement en X
depy:		dc.w	0	;deplacement en Y
depdecorx:	dc.w 	0
depdecory:	dc.w 	0
lianey:		dc.w 	0
lianex:		dc.w 	0
	even

;==============================================
;==========       collision     ===============
;==============================================
COLLISION:
	lea bobtoki,a0
	movem.w xmap(a0),d0-d1
	movem.w 4(a0),d2-d3
	add d0,d2
	sub d1,d3
	neg d3
	addq #8,d0
	subq #4,d2
	lea collisionbob(pc),a1

	move.b flageau,d7
	move level,d6
	subq #1,d6
	add d6,d6
	add d6,d6
	jmp tblcol(pc,d6.w)

tblcol:
 bra collv1
 bra collv2
 bra collv3
 bra collv4
 bra collv5
 bra collv6

collv1:
	lea bob3-30,a0
	jsr (a1)	;3
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	;10	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)
	jsr (a1)	
	jsr (a1)	;20	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)
	jsr (a1)
	jsr (a1)	;30	
	jsr (a1)	
	jsr (a1)	
	jsr (a1)	

	lea bobshartoes1-30,a0
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)

	lea bobshartoes2-30,a0
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)

	lea bobtirbig1-30,a0		;BIG MONSTER 1
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)

	lea bob61-30,a0		;timagon
	jsr (a1)	;col
	jsr (a1)	;col cocq
	jsr (a1)	;col cocq

	lea bobtirtimagon-30,a0		;tir timagon	
	jsr (a1)
	jsr (a1)
	jsr (a1)
	rts
;------------------------------------------------
collv2:
	lea bob3-30,a0
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)	;10
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)	;20
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)	;30
	jsr (a1)
	jsr (a1)
	jsr (a1)

	lea bob35-30,a0	;GMOTOI
	jsr (a1)
	jsr (a1)
	jsr (a1)

	jsr (a1)	;38

	jsr (a1)	;39 pmotoi
	jsr (a1)
	jsr (a1)
	jsr (a1)
	jsr (a1)	

	lea bobshartoes2-30,a0
	jsr (a1)
	jsr (a1)
	jsr (a1)

	rts
;------------------------------------------------
COLLV3:
	rts
;------------------------------------------------
COLLV4:
	rts
;------------------------------------------------
COLLV5:
	rts
;------------------------------------------------
COLLV6:
	rts
;------------------------------------------------

collisionbob:
	lea 30(a0),a0
	tst.b 24(a0)		;type 0 ?
	beq.s nonc		;oui pas collision 
	tst.b 28(a0)		;mort ?
	bne.s nonc
	move.w xmap(a0),d4
	cmp d4,d2
	ble.s nonc
	add 4(a0),d4
	cmp d0,d4
	ble.s nonc
	move.w ymap(a0),d5
	cmp d3,d5
	ble.s nonc
	sub 6(a0),d5
	cmp d5,d1
	ble.s nonc 

	tst.b d7
	bne.s pcoleau

	add #10,d5		;tester collision si saut
	add depy,d5
	cmp d5,d1
	ble.s colhaut 
pcoleau:

	cmp.b #$46,touche
	bne.s pmorta
	move.b #1,flagmort
pmorta:

nonc:	rts
colhaut:
	cmp #1,pesanteur
	beq.s pascolhaut
	tst.b 28(a0)		;flag mort 
	bne.s pascolhaut	;oui plus collision
	move #-8,pesanteur
	move.w #-8,depy
	move.b #1,flagsaut
add.l #$00000100,addscore
	subq.b #2,29(a0)	;decrementer energie
	bpl.s pascolhaut	;nul ? non continuer
	move.b #1,28(a0)	;oui sprite touche meurt
	clr.b 10(a0)		;cpt pour mort
pascolhaut:
	rts
;==========================================================
coltirenemis:
	lea bobtoki,a1
	movem.w xmap(a1),d0-d1
	movem.w 4(a1),d2-d3
	add d0,d2
	sub d1,d3
	neg d3
;	addq #8,d0
;	subq #8,d2
;addq #8,d2

	tst.b 24(a0)		;type 0 ?
	beq.s enonc		;oui pas collision 
	tst.b 28(a0)
	bne.s enonc

	move.w xmap(a0),d4
	cmp d4,d2
	ble.s enonc
	add 4(a0),d4
	cmp d0,d4
	ble.s enonc
	move.w ymap(a0),d5
	cmp d3,d5
	ble.s enonc
	sub 6(a0),d5
	cmp d5,d1
	ble.s enonc 
cmp.b #$46,touche
bne.s pmortb
	move.b #1,flagmort
pmortb:

enonc:	rts

;==================================================
COLLISIONOPTION:
	movem.l d0-d5/a1,-(sp) 
	lea bobtoki,a1
	movem.w xmap(a1),d0-d1
	movem.w 4(a1),d2-d3
	add d0,d2
	sub d1,d3
	neg d3
	addq #8,d0
	subq #8,d2
	addq #8,d3
	tst.b 24(a0)		;type 0 ?
	beq.s fnonc		;oui pas collision 
	move.w xmap(a0),d4
	cmp d4,d2
	ble.s fnonc
	add 4(a0),d4
	cmp d0,d4
	ble.s fnonc
	move.w ymap(a0),d5
	cmp d3,d5
	ble.s fnonc
	sub 6(a0),d5
	cmp d5,d1
	ble.s fnonc 
	clr.b 24(a0)
	clr.b 9(a0)
	add.l #$00000010,addscore
fnonc:	movem.l (sp)+,d0-d5/a1 
	rts


;==========================================================
coltirbob:
	move level,d0
	subq #1,d0
	add d0,d0
	add d0,d0
	jmp tblcoltirbob(pc,d0.w)

tblcoltirbob:
 bra coltirboblv1
 bra coltirboblv2
 bra coltirboblv2
 bra coltirboblv2
 bra coltirboblv2
 bra coltirboblv2
;----------------------------
coltirboblv1:
	lea colltirbob(pc),a2
	lea ccolltirbob(pc),a3
	lea bob3-30,a0
	jsr (a2)	;3
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)	;10
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)	;20
	jsr (a2)
	jsr (a3)	;22 kalgatro	
	jsr (a3)	;
	jsr (a3)	;
	jsr (a3)	;
	jsr (a3)	;
	jsr (a3)	;
	jsr (a3)	;
	jsr (a2)	;29
	jsr (a2)	;30
	jsr (a2)
	jsr (a2)
	jsr (a2)

	lea bob61-30,a0	;timagon
	jsr (a2)
	not.b floption
plusctb:rts

;------------------------------
coltirboblv2:
	lea colltirbob(pc),a2
	lea ccolltirbob(pc),a3

	lea bob3-30,a0
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)		;14
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)

	jsr (a2)	;31	
	jsr (a2)
	jsr (a2)

	lea bob35-30,a0	;GMOTOI
	jsr (a2)
	jsr (a2)
	jsr (a2)

	jsr (a2)	;38

	jsr (a2)	;39 pmotoi
	jsr (a2)
	jsr (a2)
	jsr (a2)
	jsr (a2)

	rts

;------------------------------
ccolltirbob:
	lea 30(a0),a0		;pour kalgatrod
	btst #5,25(a0)
	beq.s plusctb
	bra.s bcolltirbob
colltirbob:
	lea 30(a0),a0
bcolltirbob:
	tst.b 24(a0)		;bob actif ??
	beq.s plusctb		;non casse toi
	tst.b 28(a0)		;flag mort 
	bne.L plusctb		;oui plus collision

move.b option,d7
	lea bobtirtoki(pc),a1	 
	cmp.b #4,d7		;option 4 ?
	beq ecolltirbob 
	cmp.b #3,d7		;option 3 ?
	bne.s pascolopt3
	tst.b floption
	bne.s pascolopt3
	lea [26*5](a1),a1
pascolopt3:
	movem.w xmap(a0),d4-d5
	move d4,d3
	add 4(a0),d3
	move d5,d6
	sub 6(a0),d6

	moveq #5-1,d7		;5 tir maxi
tttir:	tst.b 9(a1)		;tir actif ??
	beq.s nonct		;non tester pour tir suivant
	move xmap(a1),d0
	cmp d0,d3
	ble.s nonct
	add 4(a1),d0
	cmp d4,d0
	ble.s nonct
	move ymap(a1),d1
	cmp d6,d1
	ble.s nonct 
	sub 6(a1),d1
	cmp d1,d5
	ble.s nonct

	add.l #$00000050,addscore
	clr.b 9(a1)		;degager le tir
	bset #6,24(a0)		;faire flacher le sprite touche
	subq.b #1,29(a0)	;decrementer energie
	bpl.s nonct		;nul ? non continuer
	move.b #1,28(a0)	;oui set flag mort
	clr.b 10(a0)		;cpt pour mort sprite
	rts
nonct:	lea 26(a1),a1		;tout les tir ?	
	dbf d7,tttir		;non boucle
	rts
;--------------------------------------------
ecolltirbob:
	tst.b floption
	beq.s pasflopt
	lea [26*5](a1),a1
pasflopt:
	movem.w xmap(a0),d4-d5
	move d4,d3
	add 4(a0),d3
	move d5,d6
	sub 6(a0),d6
	moveq #5-1,d7		;5 tir maxi
etttir:
	tst.b 9(a1)		;tir actif ??
	beq.s enonct		;non tester pour tir suivant

	move xmap(a1),d0
	cmp d0,d3
	ble.s enonct
;	add 4(a1),d0
	addq #8,d0
	cmp d4,d0
	ble.s enonct
	move ymap(a1),d1
	cmp d6,d1
	ble.s enonct 
;	sub 6(a1),d1
	subq #8,d1
	cmp d1,d5
	ble.s enonct

	add.l #$00000010,addscore
	clr.b 9(a1)		;degager le tir
	bset #6,24(a0)		;faire flacher le sprite touche
	subq.b #1,29(a0)	;decrementer energie
	bpl.s enonct		;nul ? non continuer
	move.b #1,28(a0)	;oui set flag mort
	clr.b 10(a0)		;cpt pour mort sprite
	rts
enonct:	lea 26(a1),a1
	dbf d7,etttir
	rts
floption:	dc.b 0
 even

;==========================================================
Droite=2
Gauche=8
Haut=1
Bas=4
Centrenul=0
CentreBG =4
CentreBD =8
CentreHG =12
CentreHD =16
CentreCG =20
CentreHHD =24

tablescrolnv1:	;FORMAT x,y,x1,y1,mask
 dc.w 480,0,672+16,176,[droite+gauche]			,8,CentreBG
 dc.w 000,000,672,112,[droite+gauche+haut]		,7,CentreBG
 dc.w 000,112,224,736,[bas+haut+droite+gauche]		,6,CentreHG
 dc.w 160,560,684,736,[droite+gauche+bas+haut]		,5,CentreBD
 dc.w 432,384,684,608,[haut+bas]			,4,CentreHD
 dc.w 684-224,384,960,432,[droite+gauche]		,3,CentreBD
 dc.w 780-16,384,960,912,[haut+bas+droite+gauche]	,2,CentreHD
 dc.w 000,736,800-16+96,912,[droite+gauche+bas]		,1,CentreBG
 dc.l -1

tablescrolnv2:
 dc.w 2000,00,2448,146-24,[droite+gauche+haut+bas],4,Centrebg
 dc.w 391,0,2160,352,[droite+gauche+haut+bas],3,Centrecg
 dc.w 128,000,390+144,112,[droite+gauche+haut+bas],2,Centrebg
 dc.w 000,000,224,528,[haut+bas+droite+gauche],1,CentreHHD
 dc.l -1
;----------------------------------------------
tablescrolnv3:
 dc.w $e0+$80,$4d0,$9a0,$580,[droite+gauche],8,centrebg
 dc.w $e0,$420+$a0,$1c0,$580,[haut+bas+droite],7,centrebd
 dc.w $70,$420,$1c0,$4d0,[droite+gauche+bas],6,centrebg
 dc.w $0,$2c0,$e0,$4d0,[haut+bas+droite],5,centrehg
 dc.w $00,$210,$140,$2c0,[droite+gauche+bas+haut],4,centrebg
 dc.w $70,$210,$380,$2c0,[gauche+droite+bas],3,centrebd
 dc.w $2a0,$a0,$380,$210,[bas+haut],2,centrehd
 dc.w $110,0,$380,$b0,[droite+gauche],1,centrebg
 dc.l -1
;----------------------------------------------
tablescrolnv4:
 dc.w $5d0,$b0,$6f0,$160-48,[droite+gauche],8,centrebg

 dc.w $550,$b0,$580+128,$1d0,[droite+gauche+bas+haut],7,centrecg
 dc.w $290,$168,$580+128,$210,[droite+gauche+haut+bas],6,centrecg

 dc.w $290,$f0,$340,$210,[bas+haut],5,centrehd
 dc.w $290,$b0,$540,$160,[droite+gauche+bas],4,centrebd
 dc.w $1c0,$0,$540,$b0-8,[droite+gauche+haut],3,centrebg
 dc.w $1d0,$0,$2a0,$160,[haut+bas+gauche+droite],2,centrehhd
 dc.w $0,$160,$2a0,$210,[droite+gauche+bas],1,centrebg
 dc.l -1
;----------------------------------------------
tablescrolnv5:
 dc.w $b30,$000,$e00,$0b0,[droite+gauche+bas+haut],5,centrebg

 dc.w $a80,$060,$b60,$3b0,[droite+gauche+haut+bas],4,centrehg
 dc.w $9a0,$370,$b60,$420,[droite+gauche+haut+bas],3,centrebg
 dc.w $9a0,$370,$a80,$450,[haut+bas],2,centrehd
 dc.w 0,$420,$a80,$4d0,[droite+gauche+bas],1,centrebg
 dc.l -1
;----------------------------------------------
tablescrolnv6:
 dc.l -1
;----------------------------------------------
tablescrol:
 dc.l tablescrolnv1,tablescrolnv2,tablescrolnv3,tablescrolnv4
 dc.l tablescrolnv5,tablescrolnv6,
;========== TEST POUR DIRECTION SCROLLING =====
testscrolling:
	lea bobtoki,a6
	clr zone
	clr direction
	clr maskscrolling

	move level,d0
	subq #1,d0
	add d0,d0
	add d0,d0
	move.l tablescrol(pc,d0.w),a0
autretest:
	move.l (a0),d0		;charger zones
	bmi.s oktest		;tester fin de table
	move.w xmap(a6),d0	;xtoki
	move.w ymap(a6),d1	;ytoki
	sub 6(a6),d1		;tail y
	move d0,d2
	move d1,d3
	add 4(a6),d2		;tail x
	add 6(a6),d3		;tail y	

	movem.w (a0),d4-d7	;x1,y1,x2,y2
	cmp d2,d4		;test X
	bge.s non
	cmp d0,d6
	ble.s non
	cmp d3,d5		;test Y
	bge.s non
	cmp d1,d7
	ble.s non 

	move 8(a0),maskscrolling
	move 10(a0),zone
	move 12(a0),d0
	tst.b flagmort
	bne.s precentre
tst.b flagbig
beq.s nobig
clr maskscrolling
nobig:
	jmp tablerecentrage(pc,d0.w)		;Recentrer scrolling
precentre:
	rts
non:	lea 14(a0),a0
	bra.s autretest
oktest:	rts

;==============================================
;----- routines de recentrage du scrolling ----
;==============================================
tablerecentrage:
	bra recentrenul
	bra recentrebg
	bra recentrebd
	bra recentrehg
	bra recentrehd
	bra recentrecg
	bra recentrehhd
;--------------------------
maskscrolling:	dc.w 0	;1=haut , 2= droite , 4=bas , 8=gauche 
direction:	dc.w 0  ;direction du scrolling
zone:		dc.w 0
recentrenul:
	rts
;--------------------------
recentrebg:
	move xmap(a6),d0
	move xmap(a6),d1
	move posmapx,d2
	move posmapy,d3		

	add #64,d2
	sub d2,d0
	bmi.s cbga

;	move 4(a0),d2
;	cmp posmapx,d2		;deja bord droit ??	
;	ble.s cbga	

	move 4(a0),d0
	add #160,d2
	cmp d0,d2
	bge.s cbga
	or #2,direction	
cbga:	

	move xmap(a6),d0
	move posmapx,d2
	add #32,d2
	sub d0,d2
	bmi.s cbgb
	move posmapx,d2		;bord gauche ?
	cmp 0(a0),d2
	ble.s cbgb
	or #8,direction
cbgb:	
	move posmapy,d3		
	sub #176,d3	
	cmp 2(a0),d3
	ble.s cbgc
	or #1,direction		;vers le haut	
cbgc:
	move posmapy,d3
	cmp 6(a0),d3
	bge.s cbgd
	or #4,direction		;vers le bas 
cbgd:
	rts

;--------------------------
recentrecg:
	move xmap(a6),d0
	move xmap(a6),d1
	move posmapx,d2
	move posmapy,d3		

	add #64,d2
	sub d2,d0
	bmi.s vcbga
	add #224-64,d2
	cmp 4(a0),d2		;deja bord droit ??	
	bge.s vcbga	
	or #2,direction	

vcbga:	
	move xmap(a6),d0
	move posmapx,d2
	add #32,d2
	sub d0,d2
	bmi.s vcbgb
	or #8,direction
;	tst d2			;deja bord gauche ???
;	beq.s vcbgb		;oui plus de deplacement
vcbgb:	
	move posmapy,d3		
	move ymap(a6),d2
	sub #87,d3
	cmp d2,d3
	bge.s vcbgc
	move posmapy,d3
	cmp 6(a0),d3
	bge.s vcbgc
	or #4,direction		;vers le bas
vcbgc:

	move posmapy,d3		
	move ymap(a6),d2
	sub #88,d3
	cmp d2,d3
	ble.s vcbgd
	move posmapy,d3
	sub #176,d3
	cmp 2(a0),d3
	ble.s vcbgd
	or #1,direction		;vers le haut
vcbgd:
	rts
;--------------------------
recentrebd:
	move xmap(a6),d0
	move ymap(a6),d1
	move posmapx,d2
	move posmapy,d3		

	add #224-48,d2
	sub d2,d0
	bmi.s cbda

	or #2,direction	
;	cmp maxposmapx,d2	;deja bord droit ??	
;	bge.s cbda	

cbda:	
	move posmapx,d2
	move d2,d3
	move xmap(a6),d0
	add #224-64,d2
	sub d2,d0
	bpl.s cdbb

	cmp (a0),d3		;deja bord gauche ???
	ble.s cdbb		;oui plus de deplacement
	or #8,direction
cdbb:
	move posmapy,d3		
	cmp 6(a0),d3
	bge.s cbdc
	or #4,direction		;vers le bas	
cbdc:		
	rts
;--------------------------
recentrehd:
	bsr centreh
	move posmapx,d3		
	move 4(a0),d2
	cmp d2,d3
	bge.s nonhdc
	or #2,direction		;vers la droite
nonhdc:	rts

recentrehhd:
	bsr centreh 
	move posmapx,d3		
	move 0(a0),d2
	cmp d2,d3
	ble.s nongf
	or #8,direction		;vers la gauche
nongf:rts
;-----------------------
centreh:move xmap(a6),d0
	move ymap(a6),d1
	move posmapx,d2
	move posmapy,d3		
;	add #[176-96],d1	
	add #[176-128],d1	
	sub d3,d1
	bpl.s nonhda
	sub #176,d3
	cmp 2(a0),d3
	ble.s nonhda	
	or #1,direction		;vers le haut	
	bra.s nonhdb
nonhda:	move ymap(a6),d1
	move posmapy,d3		
;	add #[176-144],d1	
	add #[176-160],d1	
	sub d3,d1
	bmi.s nonhdb
	cmp 6(a0),d3		;bord bas ?
	beq.s nonhdb
	or #4,direction		;vers le bas
nonhdb:	rts
;--------------------------
recentrehg:
	move xmap(a6),d0
	move ymap(a6),d1
	move posmapx,d2
	move posmapy,d3		

	add #[176-96],d1	
	sub d3,d1
	bpl.s nonhga
	cmp 2(a0),d3
	ble.s nonhga	
	or #1,direction		;vers le haut	
	bra.s nonhgb
nonhga:	
	move ymap(a6),d1
	move posmapy,d3		
	add #[176-144],d1	
	sub d3,d1
	bmi.s nonhgb
	cmp 6(a0),d3		;deja bord bas ???
	beq.s nonhgb		;oui plus de deplacement
	or #4,direction		;vers le bas
nonhgb:
;	move xmap(a6),d1
	move posmapx,d3		
	cmp (a0),d3
	ble.s nonhgc
	cmp 6(a0),d3		;deja bord gauche ???
	beq.s nonhgc		;oui plus de deplacement
	or #8,direction		;vers la gauche
nonhgc:
	rts

;-----------------------------------------------------------
;---------------- animation big monster level 1 ------------
;-----------------------------------------------------------

inithdtirbig1:
	moveq #4-1,d0
initeb1:tst.b 9(a2)
	bne.s dinittb1
;	addq #1,tempo
;	and #7,tempo
;	tst tempo
;	bne.s ptempo
addq #1,tempo
cmp #5,tempo
bmi.s ptempo
clr tempo
	move.b #1,9(a2)		;init
	move.b d1,11(a2)	;vitesse x
	clr.w 28(a2)		;pas mort,et energie
	move.l d2,xmap(a2)	;position x,y
	move.b #1,8(a2)		;image
	move.b #1,24(a2)
	move.l #IMAGEGEES,20(a2)	
	move.b #-4,10(a2)	;pesanteur
	move.b #50,12(a2)	;tempo
dinittb1:
	lea 30(a2),a2
	dbf d0,initeb1
ptempo:	rts
tempo:dc.w 0
;------------------------------------------------
gerertirbig1:
	lea bobtirbig1,a0
	moveq #8-1,d0
geb1loop:
	tst.b 24(a0)
	beq.s pgertb1
	tst.b 9(a0)
	beq.s pgertb1

	tst.b 28(a0)		;mort ?
	beq.s pmtb1
	move.l d0,-(sp)
	bsr mortgees
	move.l (sp)+,d0
	bra morttirbig1
pmtb1:  subq.b #1,12(a0)
	bne.s okencore
	clr.b 24(a0)
	clr.b 9(a0)
okencore:
	move.b 10(a0),d1
	ext d1		
	add d1,ymap(a0)
	cmp #144,ymap(a0)
	bmi.s passoltb1
	move.b #-9,10(a0)
	move #144,ymap(a0)
passoltb1:
	addq.b #1,10(a0)
	move.b 11(a0),d1
	ext d1
	add d1,xmap(a0)

	move.l d0,-(sp)
	bsr bcolltirbob
	move.l (sp)+,d0 
morttirbig1:
	move.l d0,-(sp)
	bsr bob
	move.l (sp)+,d0 
pgertb1:
	lea 30(a0),a0
	dbf d0,geb1loop
pgtirb1:rts
;------------------------------------------------
;------------------------------------------------

tblanimationbig1:
; dc.b 1,1,1,2,1,2,1,5,7,5,1,4,15,3,9,9,6,1
; dc.b 3,1,2,8,16,6,7,5
; dc.b 0

 dc.b 13,13,13,11,9,9,12,1,1,4,15,3,13,2,7,8,16,5,14,6
 dc.b 13,3,13,6,13,2,13,2,13,2,14,5,14,5,14,5,13
 dc.b 0

; dc.b 13,1,4,15,2,13,2,13,2,7,8,16,5,14,5,14,5,13
; dc.b 11,9,9,12,1,4,15,3,13,2,14,6,14,5,13
; dc.b 0

 dc.b 1,4,15,3,13,2,7,8,16,5,14,6,13,1,4,15,2,13,5,1,4,15
 dc.b 3,13,2,14,6,14,5,13
 dc.b 0
 even

ANIMATIONBIG1:
	lea bobbig1,a0
;tst.b 25(a0)
;bne.s panimbig1

	lea tblanimationbig1(pc),a1
	clr d0
	move.b 9(a0),d0
	move.b (a1,d0.w),d0
	bne.s okabig1
	clr.b 9(a0)
	move.b (a1),d0
okabig1:
	subq.b #1,d0
	asl #2,d0
	jmp tbabig1(pc,d0.w)	
panimbig1:
	rts
flagbig:	dc.b 0
 even
	
tbabig1:
bra abig1		;rire
bra abig2		;saute <-
bra abig3		;saut  <--
bra abig4		;tir   <-
bra abig5		;saut  ->
bra abig6		;saut  -->
bra abig7		;rire  ->
bra abig8		;tir   ->
bra abig9		;guili <-
bra abig10		;guili ->
bra abig11		;avance <-
bra abig12		;avance ->
bra abig13		;saut sol <-
bra abig14		;saut sol ->
bra abig15		;tir bas <-
bra abig16		;tir bas ->


abig1:			;TIRE <
	lea tblrireg(pc),a2
	bra animbig1
	rts
tblrireg:
 dc.b 1,1,1,2,2,2,2,1,1,1,2,2,2,2,0
 even
;-------------------------------------
abig2:			;petit saut <-
	cmp.b #5,8(a0)
	beq.s okdeja
	move.b #5,8(a0)
	move.b #-10,11(a0)		;pesanteur
okdeja:
	addq.b #1,11(a0)
	move.b 11(a0),d0
	ext d0
	add d0,ymap(a0)
	sub #3,xmap(a0)
	cmp #144,ymap(a0)		;sol ?
	bmi.s psolbig1
	move #144,ymap(a0)		;sol ?
	addq.b #1,9(a0)
psolbig1:
	rts
;-----------------------------------
abig3:			;grand saut <-
	cmp.b #5,8(a0)
	beq.s cokdeja
	move.b #5,8(a0)
	move.b #-15,11(a0)		;pesanteur
cokdeja:
	addq.b #1,11(a0)
	move.b 11(a0),d0
	ext d0
	add d0,ymap(a0)
	sub #4,xmap(a0)
	cmp #144,ymap(a0)		;sol ?
	bmi.s cpsolbig1
	move #144,ymap(a0)
	addq.b #1,9(a0)
cpsolbig1:
	rts
;-----------------------------------
abig4:			;TIR G
	lea bobtirbig1,a2
	move.b #-5,d1
	move.l #$02a40040,d2
	bsr inithdtirbig1
	lea tbltirgbig1(pc),a2
	bra animbig1
	rts
tbltirgbig1:
 dc.b 9,9,9,9,8,8,8,8,7,7,7,7,9,9,9,9,8,8,8,8,7,7,7,7
 dc.b 9,9,9,9,8,8,8,8,7,7,7,7,0
 even
;-----------------------------------
abig5:			;petit saut ->
	cmp.b #5+11,8(a0)
	beq.s bokdeja
	move.b #5+11,8(a0)
	move.b #-10,11(a0)		;pesanteur
bokdeja:
	addq.b #1,11(a0)
	move.b 11(a0),d0
	ext d0
	add d0,ymap(a0)
	add #3,xmap(a0)
	cmp #144,ymap(a0)		;sol ?
	bmi.s bpsolbig1
	move #144,ymap(a0)		;sol ?
	addq.b #1,9(a0)
bpsolbig1:
	rts
;------------------------------------------------
abig6:			;grand saut ->
	cmp.b #5+11,8(a0)
	beq.s ebokdeja
	move.b #5+11,8(a0)
	move.b #-15,11(a0)		;pesanteur
ebokdeja:
	addq.b #1,11(a0)
	move.b 11(a0),d0
	ext d0
	add d0,ymap(a0)
	add #4,xmap(a0)
	cmp #144,ymap(a0)		;sol ?
	bmi.s ebpsolbig1
	move #144,ymap(a0)
	addq.b #1,9(a0)
ebpsolbig1:
	rts
;------------------------------------------------
abig7:			;RIRE ->
	lea tblrired(pc),a2
	bra animbig1
	rts
tblrired:
 dc.b 12,12,12,13,13,13,13,12,12,12,13,13,13,13,0
 even
;------------------------------------------------
abig8:			;TIR D
	lea bobtirbig1,a2
	move.b #5,d1
	move.l #$01ba0040,d2
	bsr inithdtirbig1
	lea tbltirdbig1(pc),a2
	bra animbig1
	rts
tbltirdbig1:
 dc.b 20,20,20,20,19,19,19,19,18,18,18,18
 dc.b 20,20,20,20,19,19,19,19,18,18,18,18
 dc.b 20,20,20,20,19,19,19,19,18,18,18,18,0
  
 even
	rts

;-----------------------------------------
abig9:			;GUILI <-
	lea tblguilig(pc),a2
	bra animbig1
	rts
tblguilig:
 dc.b 10,10,10,6,6,6,11,11,11,11,11,10,10,10,6,6,6,11,11,11,11
 dc.b 10,10,10,6,6,6,11,11,11,11,11,0
 even
;--------------------------------------------------
abig10:			;GULI ->
	rts

;--------------------------------------------------
abig11:			;avance <-
	tst.b 13(a0)
	bne.s pasil
	move.b #1,13(a0)
	move.b #3,8(a0)
	move.b #22,12(a0)
pasil:	subq.b #1,12(a0)
	bpl.s poll
	addq.b #1,9(a0)
	clr.b 13(a0)
poll:	subq #6,xmap(a0)
	rts
;--------------------------------------------------
abig12:			;avance ->
	tst.b 13(a0)
	bne.s bpasil
	move.b #1,13(a0)
	move.b #3,8(a0)
	move.b #22,12(a0)
bpasil:	subq.b #1,12(a0)
	bpl.s bpol
	addq.b #1,9(a0)
	clr.b 13(a0)
bpol:	addq #6,xmap(a0)
	rts
;-------------------------------------------------
abig13:				;saut sol <-
	lea tblstsg(pc),a2
	bra animbig1
	rts
tblstsg:
 dc.b 6,6,6,6,4,4,4,4,6,6,6,6,4,4,4,0
 even
;-------------------------------------------------
abig14:				;saut sol ->
	lea tblstsd(pc),a2
	bra animbig1
	rts
tblstsd:
 dc.b 17,17,17,17,15,15,15,15,17,17,17,17,15,15,15,0
	rts
;-------------------------------------------------
abig15:			;TIR bas <-
	lea bobtirbig1+[30*4],a2
	move.b #-5,d1
	move.l #$02a4007c,d2
	bsr inithdtirbig1
	lea tbltirbgbig1(pc),a2
	bra animbig1
	rts
tbltirbgbig1:
 dc.b 10,10,10,6,6,6,11,11,11,11,11,10,10,10,6,6,6,11,11,11,11
 dc.b 10,10,10,6,6,6,11,11,11,0	
 even
;-------------------------------------------------
abig16:			;TIR BAS ->
	lea bobtirbig1+[30*4],a2
	move.b #5,d1
	move.l #$01ba02a4,d2
	bsr inithdtirbig1
	lea tbltbd(pc),a2
	bra animbig1
	rts
tbltbd:
dc.b 21,21,21,17,17,17,22,22,22,22,22,21,21,21,17,17,17,22,22,22,22
dc.b 21,21,21,17,17,17,22,22,22,22,0
 even

	rts
;-------------------------------------------------
animbig1:
	clr d0
	move.b 10(a0),d0
	move.b (a2,d0.w),d1
	bne.s bigok
	clr.b 10(a0)
	addq.b #1,9(a0)
	rts
bigok:	move.b d1,8(a0)
	addq.b #1,d0
	move.b d0,10(a0)
	rts
;--------------- affichage big-monster -------------
afficherbig:
	lea bobbig1,a0

;tst.b 25(a0)
;beq.s okctad 
;subq.b #1,25(a0)
;move.b #5,bobbig1+24
;move.b #1,bobbig1+24
;btst #0,25(a0)
;bne.s okctad
;move.b #0,bobbig1+24
;move.b #0,bobbig1+24
;okctad:

	movem.w xmap(a0),d0-d1
	sub posmapx,d0
	sub posmapy,d1
	add #176,d1
	movem.w d0-d1,(a0)
	move.l	(a0),savcoord

	clr.l	4(a0)

	clr	d0
	move.b	8(a0),d0
	subq.b #1,d0
	mulu	#13,d0

	lea	POSITIONSBIG1,a5
	add	d0,a5

	move.b	(a5)+,pushd0

	lea	bobbig2,a0
	move.l	savcoord,(a0)
	clr	d0
	move.b	(a5)+,d0
	asl	#3,d0
	lea	imagebigcorp1-8,a1
	add	d0,a1
	move.l	(a1)+,a2
	move.b	(a1)+,5(a0)
	move.b	(a1)+,7(a0)

	move.b	(a5)+,d0
	ext	d0
	add	d0,(a0)
	move.b	(a5)+,d0
	ext	d0
	add	d0,2(a0)

	pea	(a5)
	move	6(a0),d0
	sub	d0,2(a0)	;correction en Y
	bsr	aff_bob2	;affichage du corps
	move.l	(sp)+,a5

	lea	bobbig1,a0
	move.l	savcoord,(a0)
	clr	d0
	move.b	pushd0,d0
	asl	#3,d0
	lea	imagebigtete1-8,a1
	add	d0,a1
	move.l	(a1)+,a2
	move.b	(a1)+,5(a0)
	move.b	(a1)+,7(a0)
	pea	(a5)
	move	6(a0),d0
	sub	d0,2(a0)		;correction en Y
	bsr	aff_bob2		;affichage des pieds
	move.l	(sp)+,a5

	lea	bobbig1,a0
	move.l	savcoord,(a0)
	clr	d0
	move.b	(a5)+,d0
	asl	#3,d0
	lea	imagebigtete1-8,a1
	add	d0,a1
	move.l	(a1)+,a2
	move.b	(a1)+,5(a0)
	move.b	(a1)+,7(a0)

	move.b	(a5)+,d0
	ext	d0
	add	d0,(a0)
	move.b	(a5)+,d0
	ext	d0
	add	d0,2(a0)

	pea	(a5)
	move	6(a0),d0
	sub	d0,2(a0)	;correction en Y
	bsr	aff_bob2		;affichage tete
	move.l	(sp)+,a5

	clr	d0
	move.b	(a5)+,d0
	beq	nobras

	lea	bobbig2,a0
	move.l	savcoord,(a0)
	asl	#3,d0
	lea	imagebigcorp1-8,a1
	add	d0,a1
	move.l	(a1)+,a2
	move.b	(a1)+,5(a0)
	move.b	(a1)+,7(a0)

	move.b	(a5)+,d0
	ext	d0
	add	d0,(a0)
	move.b	(a5)+,d0
	ext	d0
	add	d0,2(a0)

	pea	(a5)
	move	6(a0),d0
	sub	d0,2(a0)		;correction en Y
	bsr	aff_bob2		;bras
	move.l	(sp)+,a5

	lea	bobbig1,a0
	move.l	savcoord,(a0)
	clr	d0
	move.b	(a5)+,d0
	asl	#3,d0
	lea	imagebigtete1-8,a1
	add	d0,a1
	move.l	(a1)+,a2
	move.b	(a1)+,5(a0)
	move.b	(a1)+,7(a0)

	move.b	(a5)+,d0
	ext	d0
	add	d0,(a0)
	move.b	(a5)+,d0
	ext	d0
	add	d0,2(a0)

	pea	(a5)
	move	6(a0),d0
	sub	d0,2(a0)	;correction en Y
	bsr	aff_bob2	;affichage main
	move.l	(sp)+,a5
nobras:
	rts

savcoord:	dc.l 0
pushd0:		dc.b 0
	even

POSITIONSBIG1:
; positions gauche
; 1=rire 1
; 2=rire 2
; 3=mort
; 4=saut 1 (sol)
; 5=saut 2 (air)
; 6=rotation 1 (=repos)
; 7=rot 2
; 8=rot 3
; 9=rot 4
; 10=rot 5
; 11=guili-guili


POSITIONSBIG01:
;1 OK
	dc.b	11		;pied
	dc.b	1,-5,-3		;corps
	dc.b	2,-15,-29	;tete
	dc.b	9,6,-16		;bras
	dc.b	13,8,-12	;main
;2 OK
	dc.b	11
	dc.b	1,-5,-3
	dc.b	3,-16+1,-29
	dc.b	9,6,-16
	dc.b	13,8,-12
;3 OK
	dc.b	25
	dc.b	7,-7,3
	dc.b	1,1,-20
	dc.b	0,0,0
	dc.b	0,0,0
;4 OK
	dc.b	9
	dc.b	5,-4,-3
	dc.b	3,-15,-31
	dc.b	17,2,-17
	dc.b	19,-3,-11
;5 OK
	dc.b	7
	dc.b	3,-7,-9
	dc.b	3,-18,-40
	dc.b	17,-1,-26
	dc.b	19,-5,-19
;6
	dc.b	11
	dc.b	1,-5,-3
	dc.b	3,-16,-29
	dc.b	17,1,-15
	dc.b	19,-3,-8
;7
	dc.b	11
	dc.b	1,-5,-3
	dc.b	3,-16,-29
	dc.b	15,-14,-26
	dc.b	21,-24,-35
;8
	dc.b	11
	dc.b	1,-5,-3
	dc.b	3,-16,-29
	dc.b	13,-8,-26
	dc.b	17,-15,-45
;9
	dc.b	11
	dc.b	1,-5,-3
	dc.b	3,-16,-29
	dc.b	11,5,-25
	dc.b	15,26,-44
;10
	dc.b	11
	dc.b	1,-5,-3
	dc.b	3,-16,-29
	dc.b	19,6,-14
	dc.b	27,24,-8
;11
	dc.b	11
	dc.b	1,-5,-3
	dc.b	3,-16,-29
	dc.b	21,-10,-14
	dc.b	23,-20,-15
;
; positions vers la droite
;
;1 OK
	dc.b	12		;pied
	dc.b	2,-1,-3		;corps
	dc.b	5,-1,-29	;tete
	dc.b	10,0,-16	;bras
	dc.b	14,8,-12	;main
;2 OK
	dc.b	12
	dc.b	2,-1,-3
	dc.b	4,-1-1,-29
	dc.b	10,0,-16
	dc.b	14,8,-12
;3 OK
	dc.b	26
	dc.b	8,-17,3
	dc.b	6,-20,-20
	dc.b	0,0,0
	dc.b	0,0,0
;4 OK
	dc.b	10
	dc.b	6,0,-3
	dc.b	4,0,-31
	dc.b	18,7,-17
	dc.b	20,21,-11
;5 OK
	dc.b	8
	dc.b	4,-9,-9
	dc.b	4,-9,-40
	dc.b	18,-2,-26
	dc.b	20,11,-19
;6 OK
	dc.b	12
	dc.b	2,-1,-3
	dc.b	4,-1,-29
	dc.b	18,6,-15
	dc.b	20,18,-8
;7 OK
	dc.b	12
	dc.b	2,-1,-3
	dc.b	4,-1,-29
	dc.b	16,8,-26
	dc.b	22,37,-35
;8 OK
	dc.b	12
	dc.b	2,-1,-3
	dc.b	4,-1,-29
	dc.b	14,6,-26
	dc.b	18,28,-45
;9 OK
	dc.b	12
	dc.b	2,-1,-3
	dc.b	4,-1,-29
	dc.b	12,-6,-25	;ok
	dc.b	16,-11,-44
;10 OK
	dc.b	12
	dc.b	2,-1,-3
	dc.b	4,-1,-29
	dc.b	20,-3,-14
	dc.b	28,-10,-8
;11 OK
	dc.b	12
	dc.b	2,-1,-3
	dc.b	4,-1,-29
	dc.b	22,6,-14
	dc.b	24,33,-15
	even

bobbig1:
 dc.w 0,0,0,0
 dc.b 1,0
 dc.w 0,0,0
dc.w 640,144 
; dc.w 188,880
 blk.b 24-20,0
 dc.b 5,0	

bobbig2:
 dc.w 0,0,0,0
 blk.b 24-8,0
 dc.b 1,0	

;-----------------------------------------
;---------- animation toki ---------------
;-----------------------------------------
MORTTOKI:
;clr.b flagmort
;rts

	tst.b flagmortt
	bne.s dinitmort
	move.b #1,flagmortt
	move #-12,pesanteur
	move.b #59,8(a0)

dinitmort:
	move pesanteur,d0
	ext d0
	add d0,ymap(a0)
	addq #1,pesanteur
	cmp #22,pesanteur
	bmi.s ctmort
	move #0,pesanteur	

	move #$ff,upflag
	clr downflag
	move #100,d0
fgh:
	cmp.b #255,$dff006
	bne.s fgh
	lea tocol,a1
	move d0,-(sp)
	bsr fondu
	move (sp)+,d0
	dbf d0,fgh

	bsr INITLEVEL1

ctmort:	rts

ANIMTOKI:
	lea bobtoki,a0
	sub.l a1,a1

	tst.b flagmort
	beq.s canimtoki
	bra MORTTOKI

canimtoki:
	tst.b flagliane
	bne ANIMTOKILIANE 

	tst.b flageau
	bne ANIMTOKIEAU

	move.b #8,delayeau
	clr depx		;pas du deplacement x
	move pesanteur,depy	;pas du deplacement y

	move.b port_1+1,d0	;port_1	(TOKI)
	move.b flagtir,d2
	move.b flagsaut,d3

	cmp.b #$4c,touche
	bne.s pasvershaut
	move #-2,depy
	pasvershaut:

	tst.b d2
	bne.s pastirtoki
	btst #4,d0		;tir ??
	beq pastirtoki		;oui 
	bsr tirdetoki

pastirtoki:
	tst.b d3		;il saute deja
	bne.s passaut		;oui continuer
	btst #4,d0		;si bouton 
	bne.s passaut		;alors ne saute pas
	btst #0,d0		;joy en haut
	beq.s passaut		;oui saute
	bsr animsaut
passaut:
	btst #3,d0		;GAUCHE ?
	beq.s ppanimg
	bsr animgauche
ppanimg:
	btst #1,d0		;DROITE ?
	beq.s ppanimd	
	bsr animdroite	
ppanimd:
	tst.b d2
	bne.s pasoldg
	tst.b d3
	bne.s pasoldg
	cmp #1,pesanteur	;si toki au sol		???
	beq.s imagerepos	;image au repos
	move.b #14,8(a0)	;ajuster droite ou gauche
	tst.b oldposition
	beq.s ppassd
	move.b #13,8(a0)
ppassd:	bra.s pasoldg

imagerepos:
	move.b #1,8(A0)		;repos droite 
	tst.b flagdi
	beq.s cbv
	move.b #80,8(a0)	;repos diag droite
cbv:
	btst #2,d0		;vers bas ?
	beq.s pasbvd 		;non
	lea tablebdroite(pc),a1
pasbvd:
	tst.b oldposition	;selon ancienne direction
	beq.s pasoldg
	move.b #7,8(A0)		;repos gauche
	tst.b flagdi
	beq.s cbu
	move.b #83,8(a0)	;repos diag gauche
cbu:
	btst #2,d0		;vers bas ?
	beq.s pasbvg 		;non
	lea tablebgauche(pc),a1
pasbvg:
pasoldg:
	tst.b d2
	bne.s pasanimbas
	btst #2,d0		;TOKI VERS LE BAS ?
	beq.s pasanimbas
	bsr animbas
pasanimbas:
	tst.b d2		;flag tir ?
	bne.s pasanimtoki	;oui
	tst.b d3		;
	bne.s pasanimtoki 
	tst.b d0		;une action joystique ?
	beq.s pasanimtoki 	;non alors pas d'anim

cmp.b #4,d0
beq.s pasanimtoki
	cmp #1,pesanteur
	bne pasanimtoki
move.l a1,d1
beq bug
	cmp.b #18,12(a0)	;eviter debordement
	bmi.s okdp
	clr.b 12(a0)
okdp:	move 12(a0),d7
	move.b (a1,d7.w),d1	;fin de table
	bne.s contanim		;non continuer
	clr d7			;oui reset pointeur anim
	move.b (a1),d1		;et reprendre a la premiere
contanim:
	move.b d1,8(a0)		;stoker animation 
	addq #1,d7		;preparer image suivante
	move d7,12(a0)
pasanimtoki:
	tst.b d2		;tir de toki ?
	beq.s pastirdetoki	;non
	bsr tokitir
pastirdetoki:
	rts			;non on se casse 
bug:	move #32000,d1
bugl:	move d1,$dff180
	dbf d1,bugl
	rts
;------------------------------------------------
animfinliane:
	btst #0,d0			;vers le haut
	beq.s ccpflh			;non

	subq.b #1,12(a0)		;delay -1
	bpl.s cpflh			;fin delay ?
	move.b #6,12(a0)		;et init prochain delay 
	bra.s neefin
pflh:	clr.b 12(a0)
cpflh:	rts 

ccpflh:
	btst #2,d0			;vers le bas ?
	beq.s bpflh			;non
	subq.b #1,12(a0)		;delay -1
	bpl.s bcpflh			;fin delay ?
	move.b #6,12(a0)		;et init prochain delay 
	bra.s bneefin
bpflh:	clr.b 12(a0)
bcpflh:	rts 

neefin:	clr d0
	move.b 13(a0),d0
	asl #2,d0
	jmp tblfinliane(pc,d0.w)
bneefin:clr d0
	move.b 14(a0),d0
	asl #2,d0
	jmp btblfinliane(pc,d0.w)

finfin:	rts

tblfinliane:
	bra finli1
	bra finli2
	bra finli3
btblfinliane:
	bra finli4
	bra finli5
	bra finli6
;----
finli1:	move.b #57,8(a0)
	move lianey,ymap(a0)
	add #19,ymap(a0)
	addq.b #1,13(a0)
	subq.b #1,14(a0)
st antirebondh
	rts
finli2:	move.b #58,8(a0)
	move lianey,ymap(a0)
	addq #1,ymap(a0)
	addq.b #1,13(a0)
	subq.b #1,14(a0)
st antirebondh
	rts
finli3:	move lianey,ymap(a0)
	clr.b flagfinliane
	clr.b 12(a0)
	move.b #1,8(a0)
	tst.b oldposition
	beq.s poil
	move.b #7,8(a0)
st antirebondh
poil:	rts

finli4:	move.b #58,8(a0)
	move lianey,ymap(a0)
	add #2-2,ymap(a0)
	addq.b #1,14(a0)
	subq.b #1,13(a0)
	rts
finli5:	move.b #57,8(a0)
	move lianey,ymap(a0)
	add #19,ymap(a0)
	addq.b #1,14(a0)
	subq.b #1,13(a0)
	rts
finli6:	clr.b flagfinliane
	move lianey,ymap(a0)
	add #40,ymap(a0)
	clr.b 12(a0)
	move.b #49,8(a0)	
	rts
;-----------------------------------------------------------
ANIMTOKIEAU:
	clr depx
	clr depy
	clr.b flagtir

	move.b port_1+1,d0
	lea tblnaged(pc),a1
	tst.b oldposition
	beq.s pnag
	lea tblnageg(pc),a1
pnag:	btst #1,d0		;droite
	beq.s pnagd
	move.b #0,oldposition
	move.w #2,depx
pnagd:	btst #3,d0		;droite
	beq.s pnagg
	move.b #1,oldposition
	move.w #-2,depx
pnagg:
	btst #0,d0		;haut
	beq.s pnagh
	move.w #-2,depy
pnagh:	btst #2,d0		;bas
	beq.s pnagb
	move.w #2,depy
pnagb:
	cmp.b #-6,delayeau
	beq.s pdelayeau
	move.b delayeau,d2
	ext d2
	move d2,depy
	tst.b delayeau
	ble.s trrp
	asr #1,d2
	tst.b oldposition
	beq.s trp
	neg d2
trp:	move d2,depx
trrp:
	subq.b #1,delayeau
pdelayeau:

	btst #4,d0		;tir
	beq.s ptireau
	st flagtir
	lea tbltirngd(pc),a1
	move.b #7,d2
	clr.b d3
	tst.b oldposition
	beq.s ptireau
	lea tbltirngg(pc),a1
	move.b #-7,d2
	clr.b d3
ptireau:
	move 12(a0),d7
	cmp #16,d7		;test debordement
	bmi.s fkm
	clr d7
fkm:	tst.b flagtir
	beq.s jgb
	cmp.b #2,option
	bne.s dsa
	move #2,d7
	bra.s jgb
dsa:	cmp #7,d7
	bmi.s jgb
	clr d7

jgb:	move.b (a1,d7.w),d1
	bne.s ctnag
	clr d7
	move.b (a1),d1
ctnag:	move.b d1,8(a0) 
	addq #1,d7
	move d7,12(a0)

	tst.b flagtir
	beq.s dvb
	cmp #3,d7
	bne.s dvb
	bsr deptirtokieau
dvb:
	bsr gererbulles
	rts

;-- gerer les bulles --
gererbulles:
	move.b port_1+1,d7

	lea bobtirtimagon,a2
	move.b 10(a2),d0
	addq.b #1,d0
	and.b #31,d0
	move.b d0,10(a2)

	cmp.b #8,d0
	bne.s pbulle1
	bsr.L initbulle
pbulle1:
	tst.b d7		;action ?
	beq.s pbulle3		;non moins de bulles
	cmp.b #17,d0
	bne.s pbulle2
	lea bobtirtimagon+30,a2
	bsr.s initbulle
pbulle2:cmp.b #26,d0
	bne.s pbulle3
	lea bobtirtimagon+60,a2
	bsr.s initbulle
pbulle3:
	lea bobtirtimagon,a0
	moveq #3-1,d7
gerbl:	tst.b 9(a0)
	beq.s pgerbl	

	subq #1,ymap(a0)

	cmp #2,level
	bne.s pblh
	cmp #1900,xmap(a0)
	bpl.s bulza
	cmp #94,ymap(a0)
	bpl.s pblh
	clr.b 9(a0)
	bra.s pgerbl
bulza:	cmp #158,ymap(a0)
	bpl.s pblh
	clr.b 9(a0)
	bra.s pgerbl

pblh:	move d7,-(sp)
	bsr bob
	move (sp)+,d7

	addq.b #1,11(a0)
	and.b #3,11(a0)
	bne.s pgerbl
	and.b #3,8(a0)
	addq.b #1,8(a0)
pgerbl:	lea 30(a0),a0
	dbf d7,gerbl
	rts
;----------------
initbulle:
	move.b #1,9(a2)
	move.l xmap(a0),xmap(a2)
	add #24,xmap(a2)
	subq #8,ymap(a2)
	tst.b oldposition
	beq.s jlm
	sub #32,xmap(a2)
jlm:
	move.b #8,24(a2)
	move.l #IMAGEBULLES,20(a2)
	move.b #2,8(a2)
	rts

tblnaged:
 dc.b 97,97,97,97,98,98,98,98,99,99,99,99,100,100,100,100,0
tblnageg:
 dc.b 101,101,101,101,102,102,102,102,103,103,103,103
 dc.b 104,104,104,104,0
tbltirngd:
 dc.b 105,105,106,106,106,100,100,0
tbltirngg:
 dc.b 107,107,108,108,108,101,101,0

delayeau:	dc.b 0
 even

;-----------------------------------------------------
;-------- initialisation des tir de toki s eau   -----
deptirtokieau:
	lea bobtirtoki,a1
	moveq #5-1,d0
edtlop:	tst.b 9(a1)
	bne epdttk
	clr.b 25(a1)

	cmp.b #2,option
	bne.s epasrd
	bsr random
	and.b #1,d1
	move.b d1,25(a1)
epasrd:	move.b #4,24(a1)
	move.b #4,[26*5]+24(a1)
	move.b #4,[26*10]+24(a1)
	move.l xmap(a0),xmap(a1)


;-- reajuster tir --
	cmp.b #2,option
	bne.s pkl
	move.b #28,d4
	move.b #-2,d5
	tst.b oldposition
	beq.s dxc
	move.b #-24,d4
	move.b #0,d5
	bra.s dxc
pkl:
	move.b #33,d4
	move.b #-2,d5
	tst.b oldposition
	beq.s dxc
	move.b #-8,d4
	move.b #-1,d5
dxc:

	ext d4
	ext d5
	add d4,xmap(a1)
	add d5,ymap(a1)
	move.l xmap(a1),[26*5]+xmap(a1)
	move.l xmap(a1),[26*10]+xmap(a1)

	cmp.b #2,option			;flamme ?
	bne.s eplfmli			;non
	bsr random			;oui x=rnd
	and.b #3,d1
	addq #5,d1
	tst.b d2
	bpl.s enokl
	neg.b d1
enokl:	move.b d1,d2

eplfmli:move.b d2,10(a1)
	move.b d3,11(a1)
	move.b d2,[26*5]+10(a1)
	move.b d3,[26*5]+11(a1)
	move.b d2,[26*10]+10(a1)
	move.b d3,[26*10]+11(a1)

	move.b #1,9(a1)
	move.b #1,[26*5]+9(a1)
	move.b #1,[26*10]+9(a1)
	move.l #imagetirtoki,20(a1)
	move.l #imagetirtoki,[26*5]+20(a1)
	move.l #imagetirtoki,[26*10]+20(a1)

	move.b #1,8(a1)
	move.b #1,[26*5]+8(a1)
	move.b #1,[26*10]+8(a1)
	cmp.b #1,option
	bne.s epasoptt1
	move.b #3,8(a1)
epasoptt1:
	bra.s eendr 
epdttk:	lea 26(a1),a1
	dbf d0,edtlop
eendr:	rts

;-----------------------------------------------------------
ANIMTOKILIANE:
	lea tablelianerhd,a1		;repos liane gauche

	clr depx
	clr depy
	clr.b flagtir

	move.b port_1+1,d0		;JOY

	tst.b flagfinliane
	beq.s pafinl
	bra animfinliane
pafinl:	cmp.b #1,flagliane
	bne.s paslianehr
	move.b #25,8(a0)		;image repos horizontal
	tst.b oldposition
	beq.s prepg
	move.b #29,8(a0)		;image repos horizontal
prepg:	bra.L nlianebas

paslianehr:
;	tst.b flagsaut
;	beq.s oklianex

	move.b flagliane,d7
	cmp.b #2,d7
	beq.s uip
	cmp.b #4,d7
	beq.s uip
	cmp.b #8,d7
	bne.s oklianex
uip:	move lianex,d7
	cmp xmap(a0),d7
	beq.s oklianex
	move lianex,xmap(a0)
	st antirebondgd
	clr.b flagsaut
oklianex:
	move.b #51,8(a0)		;repos liane gauche
	cmp.b #4,flagliane
	bne.s hkl
	move.b #53,8(a0)		;liane droite
hkl:	btst #4,d0
	bne.s nlianehaut
	btst #0,d0			;HAUT ?	
	beq.s nlianehaut
	bsr animhautliane
	tst.b flagfinliane
	beq.s nlianehaut
	bra animfinliane
nlianehaut:
	btst #4,d0
	bne.s nlianebas
	btst #2,d0			;BAS ??
	beq.s nlianebas
	bsr animbasliane
	tst.b flagfinliane
	beq.s nlianebas
	bra animfinliane
nlianebas:
	cmp.b #1,flagliane
	bne.s nlgauche

	btst #4,d0
	bne.s nldroite
	btst #1,d0			;DROITE ?
	beq.s nldroite
	bsr animdroiteliane
	bra.s nldgauche
nldroite:
	btst #4,d0
	bne.s nnlgauche
	btst #3,d0			;GAUCHE?
	beq.s nnlgauche
	bsr animgaucheliane
nnlgauche:
	bra.s nldgauche
nlgauche:
	move lianey,d1
	cmp ymap(a0),d1
	bne.s pasrdd
	move.b #1,8(a0)			;image repos debout liane
	tst.b oldposition
	beq.s pasrdd
	move.b #7,8(a0)
pasrdd:
	btst #0,flagliane
	beq.s nldgauche

	btst #1,d0			;droite debout ?
	beq.s nlddroite
	bsr animdroitedliane
	nlddroite:
	btst #3,d0			;droite gauche ?
	beq.s nldgauche
	bsr animgauchedliane
nldgauche:


	tst.b antirebondh
	beq.s okkl
	bclr #0,d0
okkl:	btst #0,d0			;SAUTE DE LA LIANE
	beq.s paslst
	move lianey,d1
	cmp ymap(a0),d1
	bne.s paslst
	move #-10,pesanteur
	move #-10,depy
okkll:	move.b #1,flagsaut
	move.b #14,8(a0)		;image saut
	tst.b oldposition
	beq.s npaslst
	move.b #13,8(a0)
npaslst:rts

paslst:	tst.b d0		;action ?
	beq panliane		;non

	move.b flagliane,d1
	tst.b antirebondgd
	bne pob	
	cmp.b #2,d1
	beq.s poaa
	cmp.b #8,d1
	bne.s poa

poaa:	btst #4,d0		;bouton ?
	bne.s poa		;oui pas sauter
	btst #1,d0		;vers droite
	beq.s poa
	move.w lianex,xmap(a0)
	add #16,xmap(a0)
	move.b #0,oldposition
	move #-5,pesanteur
	move #-5,depy
	bra.s okkll
poa:
	cmp.b #4,d1
	beq.s pobb
	cmp.b #8,d1
	bne.s pob
pobb:
	btst #4,d0		;bouton ?
	bne.s pob		;oui pas sauter
	btst #3,d0		;vers gauche
	beq.s pob
	move.w lianex,xmap(a0)
	sub #16,xmap(a0)
	move.b #1,oldposition
	move #-5,pesanteur
	move #-5,depy
	bra okkll
pob:
	btst #4,d0		;il tir ?
	beq.s pastirliane
	bsr tirliane
pastirliane:
	move.b d0,d1		;action ?
	and.b #%00001111,d1
	beq.s panliane		;non

	move 12(a0),d7		;test si debordement
	cmp.b #16,d7		
	bmi.s okl

	clr.b d7
;tst.b flagtir
;beq.s okl
;cmp.b #2,option
;bne.s okl
;move.w #2,d7
okl:	move.b (a1,d7.w),d1
	bne.s contaniml
	clr d7
	move.b (a1),d1
contaniml:
	move.b d1,8(a0) 
	addq #1,d7
	move d7,12(a0)

	tst.b flagtir
	beq.s panliane
cmp.b #2,option
bne.s upl
move.w #3,12(a0)
upl:	cmp.b #4,d7
	bne.s panliane
	bsr deptirtokiliane
panliane:rts

;-----------------------------------------------------
;-------- initialisation des tir de toki s liane -----
deptirtokiliane:
	lea bobtirtoki,a1
	moveq #5-1,d0			;5 tir maxi
odtlop:	tst.b 9(a1)			;est-il libre ?
	bne opdttk			;non tester suivant
	clr.b 25(a1)
	cmp.b #2,option			;flamme ?
	bne.s opasrd			;non
	bsr random
	and.b #1,d1
	move.b d1,25(a1)
opasrd:	move.b #4,24(a1)		;type
	move.b #4,[26*5]+24(a1)
	move.b #4,[26*10]+24(a1)
	move.l xmap(a0),xmap(a1)	;xmap,ymap

bsr dirtirliane

	lea tblrectil(pc),a2
	cmp.b #2,option			;flamme ? 
	bne.s dcv			;non
	lea tblrectilfl(pc),a2
dcv:
	clr d1				;et ajuster selon direction
	move.b dirtir,d1
	subq.b #1,d1
	asl #1,d1
	move.b (a2,d1.w),d4
	move.b 1(a2,d1.w),d5
	ext d4
	ext d5
	add d4,xmap(a1)
	add d5,ymap(a1)
	move.l xmap(a1),[26*5]+xmap(a1)
	move.l xmap(a1),[26*10]+xmap(a1)

	cmp.b #2,option			;flamme ?
	bne.s plfmli			;non
	tst.b d2
	beq.s plfmli
	bsr random			;oui x=rnd
	and.b #3,d1
	addq #5,d1
	move.b d1,d4
	tst.b d2
	bpl.s nokl
	neg.b d1
nokl:	move.b d1,d2
	tst.b d3
	bpl.s plfmli
	neg.b d4
	move.b d4,d3
plfmli:
	move.b d2,10(a1)		;dir x
	move.b d3,11(a1)		;dir y
	move.b d2,[26*5]+10(a1)
	move.b d3,[26*5]+11(a1)
	move.b d2,[26*10]+10(a1)
	move.b d3,[26*10]+11(a1)

	move.b #1,9(a1)			;ok c'est init
	move.b #1,[26*5]+9(a1)
	move.b #1,[26*10]+9(a1)
	move.l #imagetirtoki,20(a1)
	move.l #imagetirtoki,[26*5]+20(a1)
	move.l #imagetirtoki,[26*10]+20(a1)

	move.b #1,8(a1)			;tir normal
	move.b #1,[26*5]+8(a1)		;tir normal
	move.b #1,[26*10]+8(a1)		;tir normal
	cmp.b #1,option
	bne.s opasoptt1
	move.b #3,8(a1)			;tir boullet
opasoptt1:
	bra.s oendr 
opdttk:	lea 26(a1),a1			;suivant ?
	dbf d0,odtlop			;oui boucle
oendr:	rts				;non aucun tir de libre

tblrectil:
 dc.b 20,-26
 dc.b -4,-27
 dc.b 2,-38
 dc.b 16,-38
 dc.b 8,-16
 dc.b 12,-16
 dc.b 18,-34
 dc.b -1,-35
 dc.b 16,-18
 dc.b 4,-20

tblrectilfl:
 dc.b 16,-26
 dc.b -18,-27
 dc.b -8,-46
 dc.b 7,-46
 dc.b -2,-10
 dc.b 4,-8
 dc.b 12,-36
 dc.b -13,-38
 dc.b 9,-17
 dc.b -10,-17
;------------------------------------------------
dirtirliane:
tst.b dirtir
bne.s okjp
move #32000,d1
mnb:
move d1,$dff180
dbf d1,mnb
rts
okjp:
	clr d1
	move.b dirtir,d1
	subq.b #1,d1
	asl #2,d1
	jmp rotirliane(pc,d1.w)

rotirliane:
 bra rot1
 bra rot2
 bra rot3
 bra rot4
 bra rot5
 bra rot6
 bra rot7
 bra rot8
 bra rot9
 bra rot10
;-------
rot1:	move.b #7,d2
	clr.b d3
	rts
rot2:	move.b #-7,d2
	clr.b d3
	rts
rot3:	move.b #-7,d3
	clr.b d2
	rts
rot4:	move.b #-7,d3
	clr.b d2
	rts
rot5:	move.b #7,d3
	clr.b d2
	rts
rot6:	move.b #7,d3
	clr.b d2
	rts
rot7:	move.b #7,d2
	move.b #-7,d3
	rts
rot8:	move.b #-7,d2
	move.b #-7,d3
	rts
rot9:	move.b #7,d2
	move.b #7,d3
	rts
rot10:	move.b #-7,d2
	move.b #7,d3
	rts
	
;------------------------------------------------
;------------------------------------------------
tirliane:
clr.b dirtir
	cmp.w #7,12(a0)
	bmi.s fko
	clr.w 12(a0)
fko:
	cmp.b #2,flagliane
	beq.s paslitga
	btst #3,d0		;gauche ?
	beq.s paslitga
	btst #0,d0		;vers-h ?
	beq.s paslidg
	lea tbltirlihg(pc),a1
	move.b #0,oldliane
st flagtir
move.b #8,dirtir
	bra.s paslitga
paslidg:
	btst #2,d0		;vers-b ?
	beq.s paslidgg
	lea tbltirlibg(pc),a1
	move.b #0,oldliane
st flagtir
move.b #10,dirtir
	bra.s paslitga
paslidgg:
	lea tbltirlig(pc),a1
	move.b #0,oldliane
st flagtir
move.b #2,dirtir

paslitga:
	cmp.b #4,flagliane
	beq.s paslitdr
	btst #1,d0		;droite ?
	beq.s paslitdr
	btst #0,d0		;vers-h ?
	beq.s fkl
	lea tbltirlihd(pc),a1
	move.b #1,oldliane
st flagtir
move.b #7,dirtir
	bra.s paslitdr
fkl:	btst #2,d0		;vers-b ?
	beq.s ffkl
	lea tbltirlibd(pc),a1
	move.b #1,oldliane
st flagtir
move.b #9,dirtir
	bra.s paslitdr

ffkl:	lea tbltirlid(pc),a1
	move.b #1,oldliane
st flagtir
move.b #1,dirtir
paslitdr:
	btst #0,d0		;haut ?
	beq.s paslith
	btst #1,d0
	bne.s paslith
	btst #3,d0
	bne.s paslith
	lea tbltirlidh(pc),a1
st flagtir
move.b #4,dirtir
	cmp.b #4,flagliane
	bne.L dvn
	lea tbltirligh(pc),a1
st flagtir
move.b #3,dirtir
	bra.s paslith
dvn:	tst.b oldliane
	bne.s paslith
	cmp.b #2,flagliane
	bne.s dun
	lea tbltirlidh(pc),a1
st flagtir
move.b #4,dirtir
	bra.s paslith
dun:	lea tbltirligh(pc),a1
st flagtir
move.b #3,dirtir
paslith:
	btst #2,d0		;bas ?
	beq.s paslitb
	btst #1,d0
	bne.s paslitb
	btst #3,d0
	bne.s paslitb
	lea tbltirlidb(pc),a1
st flagtir
move.b #6,dirtir
	cmp.b #4,flagliane
	bne.s jmk
	lea tbltirligb(pc),a1
st flagtir
move.b #5,dirtir
	bra.s paslitb
jmk:	tst.b oldliane
	bne.s paslitb
	cmp.b #2,flagliane
	bne.s jhk
	lea tbltirlidb(pc),a1
st flagtir
move.b #6,dirtir
	bra.s paslitb
jhk:	lea tbltirligb(pc),a1
st flagtir
move.b #5,dirtir
paslitb:
	rts

tbltirlig:
 dc.b 61,61,61,62,62,62,0
tbltirlid:
 dc.b 63,63,63,64,64,64,0
tbltirlidh:
 dc.b 67,67,67,68,68,68,0
tbltirligh:
 dc.b 65,65,65,66,66,66,0
tbltirlidb:
 dc.b 69,69,69,70,70,70,0
tbltirligb:
 dc.b 72,72,72,71,71,71,0
tbltirlibg:
 dc.b 76,76,76,75,75,75,0
tbltirlibd:
 dc.b 73,73,73,74,74,74,0
tbltirlihg:
 dc.b 93,93,93,94,94,94,0
tbltirlihd:
 dc.b 95,95,95,96,96,96,0

oldliane:	dc.b 0
 even


;------------------------------
animhautliane:
	lea tablelianehd(pc),a1
	cmp.b #4,flagliane
	bne.s pasldd
	lea tablelianehg(pc),a1

pasldd:	cmp.b #1,flagliane
	beq.s pfinlianeh
	move lianey,d7
	cmp ymap(a0),d7
	beq.s pfinlianeh

	move.b flagliane,d1
	cmp.b #3,d1
	beq.s nl1a
	cmp.b #5,d1
	beq.s nl1a
	cmp.b #9,d1
	beq.s nl1a
	move #-2,depy 
	move lianex,xmap(a0)
	bra.s pfinlianeh
nl1a:	move.b #1,flagfinliane
	clr.b 12(a0)			;tempo 
	clr.b 13(a0)			;prt anim
	move.b #2,14(a0)
pfinlianeh:
	rts
;--------------
animbasliane:
	lea tablelianebd(pc),a1
	cmp.b #4,flagliane
	bne.s ertu
	lea tablelianebg(pc),a1
ertu:	cmp.b #1,flagliane	
	beq.s nl1b
	move #2,depy 
	move lianex,xmap(a0)
nl1b:
	move lianey,d1
	cmp ymap(a0),d1
	bne.s pdecs
	move.b #7,12(a0)
	move.b #1,flagfinliane
	clr.b 12(a0)
	clr.b 14(a0)
	move.b #2,13(a0)
pdecs:	rts

animdroiteliane:
	clr.b oldposition
	lea tablebdroite(pc),a1
	move #2,depx 
	move lianey,ymap(a0)
	rts

animgaucheliane:
	move.b #1,oldposition
	lea tablebgauche(pc),a1
	move #-2,depx 
	move lianey,ymap(a0)
	rts

animdroitedliane:
	clr.b oldposition
	lea tabledroite(pc),a1
	move #2,depx 
	move lianey,ymap(a0)
	rts
animgauchedliane:
	move.b #1,oldposition
	lea tablegauche(pc),a1
	move #-2,depx 
	move lianey,ymap(a0)
	rts
;------------------------------------------------

flagfinliane:dc.b 0

tablelianerhd:
 dc.b 51,51,51,51,51,51,51,51,51,51,51,51,51,49,49,49,0
tablelianehd:
 dc.b 49,49,49,49,50,50,50,50,51,51,51,51,52,52,52,52,0
 tablelianehg:
 dc.b 53,53,53,53,54,54,54,54,55,55,55,55,56,56,56,56,0
tablelianebd:
 dc.b 52,52,52,52,51,51,51,51,50,50,50,50,49,49,49,49,0
tablelianebg:
 dc.b 56,56,56,56,55,55,55,55,54,54,54,54,53,53,53,53,0
 even

;------------------------------------------------
;------------------------------------------------

ANIMGAUCHE:
	move.b #1,oldposition
	tst.b d2
	bne.s contaga
	tst.b d3
	beq.s contaga
	move.b #13,8(a0)		;image repos
contaga:
	lea tablegauche(pc),a1
	tst.b flagdi
	beq.s ujk
	lea tablegauchedi(pc),a1
ujk:	cmp #10,xbob(a0)		;limite ecran gauche ??
	ble.s paanimg			;oui casse toi
	move gdep3,d1			;swaper deplacement
	move gdep2,gdep3
	move d1,gdep2
	tst.b flagsaut
	bne.s panimg
	tst.b d2
	beq.s panimg
	moveq #0,d1
panimg:
	move d1,depx	
paanimg:
	rts
;---------
ANIMDROITE:
	clr.b oldposition
	tst.b d2
	bne.s contada
	tst.b d3
	beq.s contada
	move.b #14,8(a0)
contada:
	lea tabledroite(pc),a1
	tst.b flagdi
	beq.s pgdia
	lea tabledroitedi(pc),a1	
pgdia:	cmp #190,xbob(a0)		;limite ecran droite ??
	bge.s paanimd			;oui casse toi
	move ddep3,d1			;swaper deplacement
	move ddep2,ddep3
	move d1,ddep2
	tst.b flagsaut
	bne.s panimd
	tst.b d2
	beq.s panimd
	moveq #0,d1
panimd:
	move d1,depx
paanimd:
	rts

;-----------------------------------------------
ANIMBAS:
	tst.b d3
	bne.s pasbas
	cmp #1,pesanteur
	bne.s pasbas	
	move.b #15,8(a0)
	tst.b flagdi
	beq.s jio
	move.b #89,8(a0)
jio:	tst.b oldposition
	bne.s pasbas
	move.b #16,8(a0)
	tst.b flagdi
	beq.s pasbas
	move.b #90,8(a0)
pasbas:	rts
LIANEANIMBAS:
	rts
;-----------
ANIMSAUT:
	cmp #1,pesanteur
	bne passd
	tst.b d2
	bne passd
	move #-10,pesanteur
	move #-10,depy
	move.b #1,flagsaut
	moveq #1,d3
	move.b #14,8(a0)
	tst.b oldposition
	beq.s passd
	move.b #13,8(a0)
passd:	rts
;---------
tirdetoki:
	move.b #1,flagtir
	move.b #1,d2
	move.b #0,14(a0)
	rts
;---------
tokitir:
	lea tabletirga,a2
	move.b #2,dirtir	
	tst.b oldposition
	bne pastirdr
	lea tabletirdr,a2
	move.b #1,dirtir	
pastirdr:
	tst.b flagsaut		;il tir en sautant ?
	beq.s httst		;non 
	lea tabletirsga,a2
	move.b #12,dirtir	
	tst.b oldposition
	bne.s pastirsdr
	lea tabletirsdr,a2
	move.b #11,dirtir	
pastirsdr:
	bra cttir
httst:
	cmp #1,pesanteur	;il tir en tombant ?
	beq.s pastirtdr		;non 
	lea tabletirsga,a2
	move.b #12,dirtir	
	tst.b oldposition
	bne.s pastirtdr
	lea tabletirsdr,a2
	move.b #11,dirtir	
pastirtdr:
	move.b d0,d7
	and.b #$0f,d7
	cmp.b #4,d7		;il tir assis ?
	bne.s tsttacc
	lea tabletirassga,a2
	move.b #8,dirtir	
	tst.b oldposition
	bne.s pastirass
	lea tabletirassdr,a2
	move.b #7,dirtir	
pastirass:
	bra cttir
tsttacc:
	btst #2,d0		;il tir accroupi ?
	beq.s pastiracc
	lea tabletiraccga,a2
	move.b #10,dirtir	
	tst.b oldposition
	bne.s pastiracc
	lea tabletiraccdr,a2
	move.b #9,dirtir	
pastiracc:
	move.b d0,d7
	and.b #$0f,d7
	cmp.b #1,d7		;il tir debout g vers haut ?
	bne.s tsttgvh		;non 
	lea tabletirgvhdr,a2
	move.b #5,dirtir	
	tst.b oldposition
	bne.s pastirgvh
	lea tabletirgvhga,a2
	move.b #4,dirtir	
pastirgvh:
	bra.s cttir
tsttgvh:
	btst #0,d0		;il tir debout nord est  ?
	beq.s pastirheo
	lea tabletirhedr,a2
	move.b #6,dirtir	
	tst.b oldposition
	bne.s pastirheo
	lea tabletirhoga,a2
	move.b #3,dirtir	
pastirheo:

cttir:
	moveq #0,d1 
	move.b 14(a0),d1
	move.b (a2,d1.w),d1
	bne.s conttir
	clr.b flagtir
	clr.b d2
	bra.s ty
conttir:
	move.b d1,8(a0)
	addq.b #1,14(a0)
	cmp.b #2,option
	bne.s ty
	move.b 3(a2),8(a0)
ty:
	cmp.b #2,option
	bne.s ppasdept2
	bsr deptirtoki
	bra.s pasdeptir
ppasdept2:
	cmp.b #4,14(a0)
	bne.s pasdeptir
	bsr.s deptirtoki
pasdeptir:
	rts
;-------- initialisation depart des tir de toki -----
deptirtoki:
	lea tblajustertir,a2
	cmp.b #2,option
	bne.s pasajfl
	lea tblajustertirf,a2
pasajfl:
	lea bobtirtoki,a1
	moveq #5-1,d0			;5 tir maxi
dtlop:	tst.b 9(a1)			;est-il libre ?
	bne pdttk			;non tester suivant
okopt2:	clr.b 25(a1)
	cmp.b #2,option
	bne.s pasrd
	bsr random
	and.b #1,d1
	move.b d1,25(a1)
pasrd:	move.b #4,24(a1)		;type
	move.b #4,[26*5]+24(a1)
	move.b #4,[26*10]+24(a1)
	move.l xmap(a0),xmap(a1)	;xmap,ymap
	clr d1
	move.b dirtir,d1
	asl #1,d1
	move.b (a2,d1.w),d2
	move.b 1(a2,d1.w),d3
	ext d2
	ext d3
	add d2,xmap(a1)
	add d3,ymap(a1)
	move.l xmap(a1),[26*5]+xmap(a1)
	move.l xmap(a1),[26*10]+xmap(a1)
	move.b #7,d2			;deplacer en x 
	cmp.b #2,option
	bne.s pasopp2
	bsr random
	and.b #3,d1
	addq #5,d1
	move.b d1,d2			;dep x
pasopp2:move.b #0,d3			;dep y 
	move.b oldposition,d1
	beq.s ptepx
	neg.b d2
ptepx:	tst.b flagsaut			;il saut
	bne.s sanss			;oui alors tir droit
	move.b port_1+1,d1
	btst #0,d1
	beq.s ptepy
	move.b #-7,d3			;deplacer en y
	cmp.b #2,option			;flamme ?
	bne.s pasopp3
	move.b d2,d3
	tst.b d2
	bmi.s pasopp3
	neg.b d3
pasopp3:
ptepy:	and.b #$000f,d1
	cmp.b #1,d1
	bne.s pteph
	moveq #0,d2			;dep x
pteph:
sanss:	move.b d2,10(a1)		;direction x
	move.b d3,11(a1)		;direction y
	move.b d2,[26*5]+10(a1)
	move.b d3,[26*5]+11(a1)
	move.b d2,[26*10]+10(a1)
	move.b d3,[26*10]+11(a1)
	move.b #1,9(a1)			;ok c'est init
	move.b #1,[26*5]+9(a1)
	move.b #1,[26*10]+9(a1)
	move.l #imagetirtoki,20(a1)
	move.l #imagetirtoki,[26*5]+20(a1)
	move.l #imagetirtoki,[26*10]+20(a1)

	move.b #1,8(a1)			;tir normal
	move.b #1,[26*5]+8(a1)		;tir normal
	move.b #1,[26*10]+8(a1)		;tir normal

	cmp.b #1,option
	bne.s pasoptt1
	move.b #3,8(a1)			;tir boullet
pasoptt1:
	bra.s endr 
pdttk:	lea 26(a1),a1			;suivant ?
	dbf d0,dtlop			;oui boucle
endr:	rts				;non aucun tir de libre

;----------------------------------
random:
	move.l a0,-(sp)
	move.l trandom,a0
	move.b (a0)+,d1
	cmp.l #finrand,a0
	blt.s randoma
	lea debrand,a0
randoma:move.l a0,trandom
	move.l (sp)+,a0
	rts
trandom:	dc.l debrand
debrand:
; dc.b 0,2,4,0,6,8,4,3,9,2,1,6,8,9,5,5,2,0,4,5,2,3,0,0,4,1,5,2,2
 dc.b 0,1,2,3,2,1,0,1,2,3,2,1,0,1,2,3,2
finrand:
;----------------------------------
tblajustertir:
 dc.b 0,0
 dc.b 22,-16
 dc.b -8,-16
 dc.b 16,-29
 dc.b 14,-40
   dc.b 4,-40
   dc.b 0,-29
 dc.b 28,-6
 dc.b -2,-6
 dc.b 38,-5
 dc.b -8,-5
 dc.b 24,-16
 dc.b -10,-16
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0

tblajustertirf:
 dc.b 0,0
 dc.b 14,-16
 dc.b -20,-16
 dc.b 07,-30
 dc.b 04,-40
   dc.b -4,-40	
   dc.b -8,-30	
 dc.b 18,-6	
 dc.b -12,-6
 dc.b 28,-5	
 dc.b -16,-5
 dc.b 16,-16
 dc.b -20,-16
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0


dirtir:	dc.b 0
option:	dc.b 0
even
;--------- gestion des tir de toki ------------------
gerertirtoki:
	lea bobtirtoki,a0
	cmp.b #3,option
	beq gerertirtoki3
	cmp.b #2,option
	beq gerertirtoki2
	cmp.b #4,option
	beq gerertirtoki4

	moveq #5-1,d5			;gerer 5 tir maxi
ctirlop:
	tst.b 9(a0)			;actif ?
	beq pasgtt

; ==- collision aver relief -==
	move.b 10(a0),d0		
	ext d0
	move.b 11(a0),d1		
	ext d1
	move.w d5,-(sp)
	bsr collisionreliefenemis
	move.w (sp)+,d5
	and #1+2,d3		;col x ou y
	beq.s pcolttr		;non
	clr.b 9(a0)		;oui
pcolttr:
	tst.b 9(a0)
	beq pasgtt

	movem xmap(a0),d6-d7		;test limite ecran d.g.h.b
	sub posmapx,d6
	sub posmapy,d7
	add #176,d7
	add d0,d6
	add d1,d7
	cmp #224,d6			;ecran droite ?
	ble.s prva			;non
	clr.b 9(a0)
	bra.s pasgtt
prva:	cmp #-2,d6			;ecran gauche ?
	bge.s prvb
	clr.b 9(a0)
	bra.s pasgtt
prvb:	cmp #2,d7			;ecran haut ?
	bge.s prvc
	clr.b 9(a0)
	bra.s pasgtt
prvc:	cmp #176,d7			;ecran bas ?
	ble.s prvd
	clr.b 9(a0)
	bra.s pasgtt
prvd:	add d0,16(a0)
	add d1,18(a0)

	cmp.b #1,option
	bne.s optnul
	eor.b #4~3,8(a0)
	bra.s pasoptnul
optnul:	eor.b #2~1,8(a0)
pasoptnul:
	move.w d5,-(sp)
	bsr bob
	move.w (sp)+,d5
pasgtt:	lea 26(a0),a0
	dbf d5,ctirlop
	rts
;--------- gestion des flammes ------
gerertirtoki2:
	moveq #5-1,d5
bctirlop:
	tst.b 9(a0)
	beq bpasgtt

; ==- collision aver relief -==
	move.b 10(a0),d0		
	ext d0
	move.b 11(a0),d1		
	ext d1
	move.w d5,-(sp)
	bsr collisionreliefenemis
	move.w (sp)+,d5
and #1+2,d3
	move.b d3,temp
	tst.b 9(a0)
	beq bpasgtt

	cmp.b #4,25(a0)
	bmi.s pasdepp
	clr.b 9(a0)
	clr.b 24(a0)
	clr.b 25(a0)
	bra bpasgtt
pasdepp:
	moveq #8,d0
	sub.b 25(a0),d0
	move.b d0,8(a0)

	move.b 10(a0),d0
	ext d0
	move.b 11(a0),d1
	ext d1
	add d0,xmap(a0)
	add d1,ymap(a0)
	asr.b #1,d0
	asr.b #1,d1
	add.b d0,10(a0)
	add.b d1,11(a0)
	addq.b #1,25(a0)

	move.w d5,-(sp)
	jsr bob
	move.w (sp)+,d5
	tst.b temp
	beq.s bpasgtt
	clr.b 9(a0)
bpasgtt:lea 26(a0),a0
	dbf d5,bctirlop
	rts

;---------- gestion tir option 3 ------------
gerertirtoki3:
	moveq #5-1,d5
cctirlop:
	move d5,-(sp)
	move.b 10(a0),d0
	ext d0
	move.b 11(a0),d1
	ext d1
	add d0,xmap(a0)
	add d1,ymap(a0)
	add d0,[26*5]+xmap(a0)
	add d1,[26*5]+ymap(a0)

	clr d2
	move.b 25(a0),d2
	lea tblsin(pc),a1
	move.b (a1,d2.w),d2
	cmp.b #80,d2			;fin de table ?
	bne.s prestbl			;non
	clr.b 25(a0)			;oui
	move.b (a1),d2
prestbl:ext d2
	tst.b d0
	beq.s paddx
	add d2,ymap(a0)
	sub d2,[26*5]+ymap(a0)
paddx:	tst.b d1
	beq.s paddy
	tst.b d0 
	bpl.s pasnegg
	neg d2
pasnegg:add d2,xmap(a0)
	sub d2,[26*5]+xmap(a0)
paddy:	addq.b #1,25(a0)

	tst.b 9(a0)
	beq.s pastb1
	bsr bob
pastb1:
	tst.b [26*5]+9(a0)
	beq.s pastb2
	lea [26*5](a0),a0
	bsr bob
	lea -[26*5](a0),a0
pastb2: eor.b #2~1,8(a0)
	eor.b #2~1,[26*5]+8(a0)
cpasgtt:move.w (sp)+,d5
	lea 26(a0),a0
	dbf d5,cctirlop

;----- collision avec relief ---------
	lea bobtirtoki,a0
	moveq #10-1,d5
gttok3:
	move d5,-(sp)
	tst.b 9(a0)
	beq cprvd
; ==- collision avec relief -==
	move.b 10(a0),d0		
	ext d0
	move.b 11(a0),d1		
	ext d1
	bsr collisionreliefenemis
	and #1+2,d3
	tst.b d3				;collision relief ?
	beq.s bfh				;non
	clr.b 9(a0)
	bra.s cprvd
bfh:
;-- collision avec l'ecran --
	move.b 10(a0),d6
	ext d6
	move.b 11(a0),d7
	ext d7
	movem.w xmap(a0),d0-d1
	sub posmapx,d0
	add d6,d0
	cmp #224,d0			;droite ?
	ble.s cprva
	clr.b 9(a0)
	bra.s cprvd
cprva:	cmp #-2,d0			;gauche ?
	bge.s cprvb
	clr.b 9(a0)
	bra.s cprvd
cprvb:
	sub posmapy,d1
	add #176,d1
	add d7,d1
	cmp #2,d1			;haut ?
	bge.s cprvc
	clr.b 9(a0)
	bra.s cprvd
cprvc:	cmp #176,d1			;bas ?
	ble.s cprvd
	clr.b 9(a0)
cprvd:
	move.w (sp)+,d5
	lea 26(a0),a0
	dbf d5,gttok3
	rts
;--
tblsin:
 dc.b 0,-8,-5,-3,3,5,8,80
 even

;---------- gestion tir option 4 ------------
gerertirtoki4:
	moveq #3-1,d5
dtirlop:
; ==- collision aver relief -==
	move.l a0,-(sp)

	tst.b 9(a0)
	beq nonpta
	move.b 10(a0),d0
	ext d0
	move.b 11(a0),d1
	ext d1
	move.w d5,-(sp)
	bsr collisionreliefenemis
	move.w (sp)+,d5
and #1+2,d3
	move.b d3,temp
	tst.b d3			;collision relief ?
	beq.s naptemp			;non
	clr.b 9(a0)			;oui
	clr.b 24(a0)
naptemp:
	move.b 10(a0),d0		;dir x
	ext d0
	move.b 11(a0),d1		;dir y
	ext d1
	add d0,xmap(a0)
	add d1,ymap(a0)

	eor.b #2~1,8(a0)
	move.w d5,-(sp)
	bsr bob
	move.w (sp)+,d5
nonpta:
;-------
	lea [26*5](a0),a0
	tst.b 9(a0)
	beq nonptb
	move.b 10(a0),d0
	ext d0
	move.b 11(a0),d1
	ext d1
	move.w d5,-(sp)
	bsr collisionreliefenemis
	move.w (sp)+,d5
and #1+2,d3
	move.b d3,temp1
	tst.b d3			;collision relief ?
	beq.s nbptemp			;non
	clr.b 9(a0)			;oui
	clr.b 24(a0)
nbptemp:
	eor.b #2~1,8(a0)
	move.b 10(a0),d0
	ext d0
	move.b 11(a0),d1
	ext d1
	add d0,xmap(a0)
	add d1,ymap(a0)

	move.w d5,-(sp)
	jsr bob
	move.w (sp)+,d5
nonptb:
	move.l (sp)+,a0

	move.b 10(a0),d0	;dir x
	ext d0
	move.b 11(a0),d1	;dir y
	ext d1
	moveq #1,d2		;offset x
	moveq #1,d3		;offset y

	tst d0
	bpl.s pasd1
	neg d2
pasd1:	tst d0
	bne.s dfa
	moveq #0,d3
dfa:	tst d1
	bne.s dfb
	moveq #0,d2
dfb:	add d2,xmap(a0)
	sub d2,[26*5]+xmap(a0)
	add d3,ymap(a0)
	sub d3,[26*5]+ymap(a0)

dpasgtt:lea 26(a0),a0
	dbf d5,dtirlop
	rts
;----------------------------------------
pesanteur:	dc.w 0
ddep2:		dc.w 2
ddep3:		dc.w 3
gdep2:		dc.w -2
gdep3:		dc.w -3
oldposition:	dc.b 0
flagtir:	dc.b 0
flagsaut:	dc.b 0
flagdi:		dc.b 0
flagliane:	dc.b 0
flagmort:	dc.b 0
flagmortt:	dc.b 0
flageau:	dc.b 0
temp:		dc.b 0
temp1:		dc.b 0
even

tabletirga:
 dc.b 18,18,17,17,7,0
 even
tabletirdr:
 dc.b 19,19,20,20,1,0
 even
tabletirsdr:
 dc.b 21,21,22,22,14,0
tabletirsga:
 dc.b 23,23,24,24,13,0
tabletirassdr:
 dc.b 34,34,33,33,16,0
tabletirassga:
 dc.b 35,35,36,36,15,0
tabletiraccdr:
 dc.b 37,37,38,38,27,0
tabletiraccga:
 dc.b 39,39,40,40,31,0
tabletirgvhdr:
 dc.b 42,42,41,41,41,0
tabletirgvhga:
 dc.b 43,43,44,44,44,0
tabletirhedr:
 dc.b 46,46,45,45,45,0
tabletirhoga:
 dc.b 47,47,48,48,48,0
tabledroite:
 dc.b 1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,0
tabledroitedi:
 dc.b 77,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,0
tablegauche:
 dc.b 7,7,7,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,0
tablegauchedi:
 dc.b 83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,0
tablebdroite:
 dc.b 25,25,25,25,26,26,26,26,27,27,27,25,25,25,28,28,28,28,0
tablebgauche:
 dc.b 32,32,32,32,31,31,31,31,30,30,30,32,32,32,29,29,29,29,0

tablelianeh1:
 dc.b 0
 even

;---------   gestion des tir piques      ------------------
gerertirpique:
	moveq #5-1,d7
gtpl:	tst.b 24(a0)
	beq pgtp

	tst.b flagmort
	bne.s ppcoltr
	bsr coltirenemis

	move.b 10(a0),d0
	ext d0
	move.b 11(a0),d1
	ext d1
	move.w d7,-(sp)
	bsr collisionreliefenemis
	move.w (sp)+,d7
	tst.b d3
	beq.s ppcoltr
	clr.b 24(a0)
	bra.s pgtp
ppcoltr:
	movem xmap(a0),d0-d1		;test lmt ecr d.g.h.b
	sub posmapx,d0
	sub posmapy,d1
	add #176,d1
	cmp #224,d0			;droite ?
	ble.s pwprva
	clr.b 24(a0)
	bra.s pgtp
pwprva:	cmp #-32,d0			;gauche ?
	bge.s pwprvb
	clr.b 24(a0)
	bra.s pgtp
pwprvb:	cmp #2,d1			;haut ?
	bge.s pwprvc
	clr.b 24(a0)
	bra.s pgtp
pwprvc:	cmp #176,d1			;bas ?
	ble.s pwprvd
	clr.b 24(a0)
	bra.s pgtp

pwprvd:	move.b 10(a0),d0
	ext d0
	move.b 11(a0),d1
	ext d1
	add d0,xmap(a0)
	add d1,ymap(a0)
	eor.b #2,8(a0)
	eor.b #1,8(a0)

	move.w d7,-(sp)
	bsr bob
	move.w (sp)+,d7

pgtp:	lea 26(a0),a0
	dbf d7,gtpl
	rts

;--------- gestion des tir de wesbtami ------------------
gerertirwesbtami:
	lea tbltwm,a1
	moveq #0,d5
	move.b 25(a0),d5
	add d5,a1
	addq.b #1,25(a0)

	moveq #6-1,d5			;gerer 6 tir
wctirlop:
	tst.b 9(a0)			;actif ?
	beq wpasgtt

movem.l d5/a1,-(sp)
bsr coltirenemis
movem.l (sp)+,d5/a1

pascoltwr:
	tst.b 9(a0)			;actif ?
	beq wpasgtt
	cmp.b #2,9(a0)			;tir mort ?
	beq tirwesbtamimort
	moveq #0,d6
	moveq #0,d7
	move.b 10(a0),d6		;dir x
	ext d6
	move.b 11(a0),d7		;dir y
	ext d7
ctwctirlop:
	movem xmap(a0),d0-d1		;test lmt ecr d.g.h.b
	sub posmapx,d0
	sub posmapy,d1
	add #176,d1
	add d6,d0
	add d7,d1
	cmp #224,d0			;ecran droite ?
	ble.s wprva			;non
	clr.b 9(a0)
	bra.s wpasgtt
wprva:	cmp #-32,d0			;ecran gauche ?
	bge.s wprvb
	clr.b 9(a0)
	bra.s wpasgtt
wprvb:	cmp #2,d1			;ecran haut ?
	bge.s wprvc
	clr.b 9(a0)
	bra.s wpasgtt
wprvc:	cmp #176,d1			;ecran bas ?
	ble.s wprvd
	clr.b 9(a0)
	bra.s wpasgtt
wprvd:	add d6,xmap(a0)
	add d7,ymap(a0)
	and.b #3,8(a0)
	addq.b #1,8(a0)

	moveq #0,d0
	moveq #0,d1
	move.b 10(a0),d0		;dir x
	ext d0
	move.b 11(a0),d1		;dir y
	ext d1
	movem.l d5/a0-a1,-(sp)
	bsr collisionreliefenemis
	movem.l (sp)+,d5/a0-a1
	tst.b d3
	beq.s okwpasgtt
	clr.b 9(a0)
	bra.s wpasgtt
	
okwpasgtt:
	movem.l d5/a0-a6,-(sp)
	jsr bob
	movem.l (sp)+,d5/a0-a6
wpasgtt:
	lea 26(a0),a0
	dbf d5,wctirlop
	rts
;---------------------------------------------
tirwesbtamimort:
	moveq #0,d6
	moveq #0,d7
	move.b 10(a0),d6
	ext d6
	move.b (a1),d7
	ext d7
	bra.L ctwctirlop
tbltwm:
 dc.b -6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7
 dc.b 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
 dc.b 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
 even

;================================================
;======= AFFICHER TOKI  JCM =====================
;================================================
affichetoki:
	lea	bobtoki,a0
	movem.w	xmap(a0),d0-d1
	sub	posmapx,d0	;pour X
	sub	posmapy,d1
	add	#176,d1
	movem.w	d0-d1,(a0)

	clr	d0
	move.b	8(a0),d0	;numero anim
	add	d0,d0
	add	d0,d0
	lea	positionstoki-4,a5
	add	d0,a5

	clr	d0
	move.b	(a5)+,d0	;numero corps
	asl	#3,d0
	lea	imagecorps-8,a6
	add	d0,a6
	move.l	(a6),localvar1	;ptr bitmap sprite
	clr.l 4(a0)
	move.b 4(a6),5(a0)
	move.b 5(a6),7(a0)

;	clr d0
	move.b 6(a6),d0
ext d0
	add d0,(a0)
;clr d0
move.b 7(a6),d0
ext d0
add d0,2(a0)

	clr	d2
	move.b	(a5)+,d2	;numero de la tete
	move.b	d2,localvar2

	beq.s	affnotete

	add.b	d2,d2
	add	d2,d2
	add	d2,d2
	lea	imagetetes-8,a4
	add	d2,a4
	move.l	(a4),localvar3
	move.l	4(a4),bobtete+4

	lea	bobtoki,a0
	move	(a0),d0		;X ecran
	move.b	(a5)+,d1
	ext	d1
	add	d1,d0		;+decalage->X gauche de la tete
	move	d0,bobtete+0
	move	2(a0),d0	;Y ecran
	sub	6(a0),d0	;-taille Y
	move.b	(a5)+,d1
	ext	d1
	add	d1,d0		;+decalage->Y haut de la tete
	add	6(a4),d0	;+hauteur de la tete
	move	d0,bobtete+2	;->Y bas de la tete

affnotete:
;
; affiche la tete avant le corps si bit 7=1
;
	tst.b	localvar2
	bpl.s	notete1
	lea	bobtete,a0
	move.l	localvar3,a2	;adresse image
;move centrage,d7
;add d7,xmap(a0)
	bsr	aff_bob
notete1:
;
; affiche corps de Toki
;
	lea	bobtoki,a0
	move.l	localvar1,a2	;adresse image
;move centrage,d7
;add d7,xmap(a0)
	bsr	aff_bob
;
; affiche la tete aprs le corps si bit 7=0 et si <>0
;
	tst.b	localvar2
	ble.s	notete2
	lea	bobtete,a0
	move.l	localvar3,a2	;adresse image
	bsr	aff_bob
notete2:

	tst.b	localvar2
	beq.s	notete3
	move	bobtoki+2,d0
	sub	bobtete+2,d0
	add	bobtoki+6,d0
	cmp	bobtoki+6,d0
	ble.s	petitete1
	move	d0,bobtoki+6

petitete1:
notete3:
;	lea bobtruc,a0
;	move.l bobtoki+16,xmap(a0)
;	move bobtoki+6,d0
;	sub d0,18(a0)
;	addq.w #8,16(a0)
;	move.b #9,8(a0)
;	move.l #imagecascade,20(a0)
;	move.b #5,24(a0)
;	bsr bob
	rts

;bobtruc:
;blk.b 30,0

bobtete:dc.w	0	;X
	dc.w	0	;Y
	dc.w	0	;taille X
	dc.w	0	;taille Y
blk.b 24-8,0
	dc.b 1
	even

localvar1:dc.l	0
localvar3:dc.l	0
localvar2:dc.b	0
	even

;
; ANIMATIONS DE TOKI
;
;	dc.b	corps,tete,dx,dy
;
;	corps :	numero du corps
;	tete  : numero de la tete
;		$00=pas de tete
;		+$80=tete affichee apres corps
;	dx,dy : ajustement de la tete par rapport au corps
;
;
; positions de marche
;
positionstoki:
	dc.b	1,12,8,-6	;1 repos marche droite
	dc.b	2,12,7,-6	;2 marche droite 2
	dc.b	3,12,5,-6	;3 marche droite 3
	dc.b	4,12,7,-6	;4 marche droite 4
	dc.b	5,12,5,-6	;5 marche droite 5
	dc.b	6,12,5,-6	;6 marche droite 6
	dc.b	12,11,-8,-6	;7 repos marche gauche
	dc.b	11,11,-10,-6	;12 marche gauche 6
	dc.b	10,11,-7,-6	;11 marche gauche 5
	dc.b	9,11,-5,-6	;10 marche gauche 4
	dc.b	8,11,-10,-6	;9 marche gauche 3
	dc.b	7,11,-5,-6	;8 marche gauche 2
	dc.b	14,11,-8,1	;14 repos saut gauche
	dc.b	13,12,11,1	;13 repos saut droite
	dc.b	87,0,0,0	;16 repos assis gauche
	dc.b	92,0,0,0	;15 repos assis droite
	dc.b	12,9,-13+1,-5	;17 tir marche gauche vers gauche
	dc.b	12,10,-9+1,-5	;18
	dc.b	1,1+12,7,-5	;19 tir marche droite vers droite
	dc.b	1,14,7,-5	;20
	dc.b	13,1+12,8,0	;21 tir saut droite vers droite
	dc.b	13,14,8,0	;22
	dc.b	14,10,-7,0	;23 tir saut gauche vers gauche
	dc.b	14,9,-10,0	;24
	dc.b	27,12,15,0	;25 marche accroupi droite
	dc.b	28,$80+12,17,-3
	dc.b	29,12+$80,19,-3
	dc.b	30,12,16,-3
	dc.b	31,11,-7,-3	;29 marche accroupi gauche
	dc.b	32,11+$80,-8,-3
	dc.b	33,11+$80,-8,-3
	dc.b	34,11,-7,0
	dc.b	90,0,0,0	;33 tir assis gauche vers gauche
	dc.b	91,0,0,0
	dc.b	88,0,0,0	;35 tir assis droite vers droite
	dc.b	89,0,0,0
	dc.b	26,1+12,18,0	;37 tir accroupi droite vers droite
	dc.b	26,14,18+1,0
	dc.b	35,10,-6-4-1+4,0;39 tir accroupi gauche vers gauche
	dc.b	35,9,-9-1,0
	dc.b	12,$80+2,-4,-16	;41 tir marche gauche vers haut
	dc.b	12,$80+3,-5,-12	; 
	dc.b	1,4+$80,1,-12-1	;43 tir marche droite vers haut
	dc.b	1,5+$80,1,-16-1	;
	dc.b	12,$80+29,-8,-9-1;45 tir m gauche vers haut-gauche
	dc.b	12,$80+7,-4+1,-8-1
	dc.b	1,8+$80,2,-8-1	 ;47 tir m droite vers haut droite
	dc.b	1,30+$80,3-1,-9-1

	dc.b	42,6,3,5+2	;49 monte sur liane droite
	dc.b	104,6,0+4-1,-3	;
	dc.b	44,6,3-2,5	;
	dc.b	104,6,4-1,-4+1	;
	dc.b	42,1,0+1,5+2	;53 monte sur liane gauche
	dc.b	43,1,1+1,-4+1	;
	dc.b	44,1,1-1,-5+11	;
	dc.b	43,1,4-2,-4+1	;
	dc.b	45,0,0,0	;57 fin monte liane
	dc.b	46,0,0,0
	dc.b 	105,0,0,0	;59 mort gauche
	dc.b 	106,0,0,0	;60 mort droite

	dc.b	55,10,1,5-1	;61 tir liane  vers gauche
	dc.b	55,9,-2-1,5-1	
	dc.b	56,13,4,4	;63 tir liane  vers droite
	dc.b	56,14,6-1,6-1
	dc.b	42,3,0,5-1	;65 tir liane droite vers haut
	dc.b	42,2,1,1-1
	dc.b	44,4,1,4	;67 tir liane gauche vers haut
	dc.b	44,5,1,0
	dc.b	47,0,0,0	;69 tir liane gauche vers bas
	dc.b	48,0,0,0
	dc.b	49,0,0,0	;71 tir liane droite vers bas
	dc.b	50,0,0,0
	dc.b	51,0,0,0	;73 tir liane gauche vers bas-droite
	dc.b	52,0,0,0
	dc.b	53,0,0,0	;75 tir liane droite vers bas-gauche
	dc.b	54,0,0,0

	dc.b	21,12,7,-6	;77 monte droite
	dc.b	21,12,7,-6
	dc.b	22,12,6,-6
	dc.b	23,12,6,-6
	dc.b	24,12,8,-6
	dc.b	25,12,7,-6
	dc.b	15,11,-10,-6	;83 descend gauche
	dc.b	16,11,-12,-6
	dc.b	17,11,-8,-6
	dc.b	18,11,-9,-6
	dc.b	19,11,-11,-6
	dc.b	20,11,-9,-6
	dc.b	86,0,0,0	;89 repos assis descend gauche
	dc.b	80,0,0,0	;90 repos assis monte droite
	dc.b	81,0,0,0	;91 repos assis descend droite
	dc.b	75,0,0,0	;92 repos assis monte gauch


	dc.b	55,$80+7,1,4	;93 tir liane haut-gauche
	dc.b 	55,$80+$1d,-2,5	;
	dc.b 	56,$80+8,5,4	;95 tir liane haut-droite
	dc.b 	56,$80+$1e,5,5

	dc.b	67,$80+26,19,-5	;97 nage droite
	dc.b	68,26,24-1,-5
	dc.b	69,26,33,-5
	dc.b	70,26+$80,19,-5
	dc.b	71,25+$80,-11,-5;101 nage gauche
	dc.b	72,25,-12,-5
	dc.b	73,25,-13+1,-5
	dc.b	74,25+$80,3,-5
	dc.b	68,27,21,-5	;105 tir nage droite
	dc.b	68,28,22-1,-5
	dc.b	73,24,-13+1,-5	;107 tir nage gauche
	dc.b	73,23,-16,-4

michel:
; anim inutilisees (pour l'instant...)
	dc.b	76,0,0,0	;tir assis monte gauch vers ht-gauch
	dc.b	77,0,0,0
	dc.b	78,0,0,0	;tir assis monte droite
	dc.b	79,0,0,0
	dc.b	82,0,0,0	;tir assis descend drt vers bas-drt
	dc.b	83,0,0,0
	dc.b	84,0,0,0	;tir ass descend gauche v bas-gauche
	dc.b	85,0,0,0

	dc.b	93,11,-11,-6	;monte gauche
	dc.b	94,11,-7,-6
	dc.b	95,11,-10,-6
	dc.b	96,11,-11,-6
	dc.b	97,11,-9,-6
	dc.b	98,12,6,-6	;descend droite
	dc.b	99,12,6,-6
	dc.b	100,12,10,-6
	dc.b	101,12,6,-6
	dc.b	102,12,7,-6
	dc.b	103,12,9,-6	;repos descend droite
	dc.b	97,11,-9,-6	;repos monte gauche

	dc.b	15,2+$80,-6,-16-2+1;tir descend gauche v haut
	dc.b	15,3+$80,-7,-12-2+1
	dc.b	15,29+$80,-10+1,-9;tir descend gauche v haut gauche
	dc.b	15,7+$80,-6,-8-1
	dc.b	15,9,-13,-5	;tir descend gauche vers gauche
	dc.b	15,10,-10,-5
	dc.b	21,1+12,5,-5	;tir monte droite vers droite
	dc.b	21,14,5,-5
	dc.b	21,8+$80,1-1,-9	;tir monte droite vers haut droite
	dc.b	21,30+$80,1,-11+1
	dc.b	21,4+$80,-2,-12-2+1	;tir monte droite vers haut
	dc.b	21,5+$80,-2,-15-1
	dc.b	97,10,-9,-5	;tir monte gauche vers gauche
	dc.b	97,9,-12,-5
	dc.b	97,7+$80,-5,-9	;tir monte gauche vers haut gauche
	dc.b	97,29+$80,-8,-11+1
	dc.b	97,3+$80,-4,-12	;tir monte gauche vers haut
	dc.b	97,2+$80,-3,-15-1
	dc.b	103,1+12,7,-5	;tir descend droite vers gauche
	dc.b	103,14,7,-5
	dc.b	103,8+$80,3,-8	;tir descend droite vers haut gauche
	dc.b	103,30+$80,3,-9	;103,10 19/04/90
	dc.b	103,4+$80,2,-12+1-2;tir descend droite vers haut
	dc.b	103,5+$80,2,-16-2+1
	dc.b	26,12,19,0	;repos accroupi droite
	dc.b	35,11,-5-2,0	;repos accroupi gauche
	dc.b	26,4,16-1,-8-1	;tir accroupi droite vers haut
	dc.b	26,5,15,-13
	dc.b	35,3,-7+2,-9+1	;tir accroupi gauche vers haut
	dc.b	35,2,-4,-13+1
	dc.b	36,23-2,18,2	;tir accroupi droite vers bas
	dc.b	36,22,21-1,3
	dc.b	37,20,-6-2,2	;tir accroupi gauche vers bas
	dc.b	37,19,-7+1,3




	dc.b	38,0,0,0	;tir accroupi droite vers haut-droite
	dc.b	39,0,0,0
;88
	dc.b	40,0,0,0	;tir accroupi gauche vers haut-gauche
	dc.b	41,0,0,0
;
;
; positions sur la corde
;
	dc.b	63,0,0,0	;quitte corde saut droite
	dc.b	64,0,0,0
	dc.b	65,0,0,0	;quitte corde saut gauche
	dc.b	66,0,0,0
;a0
	dc.b	57,12+$80,16,4+1;pos 1 : repos corde droite
	dc.b	57,13+$80,14,5	;pos 1 : tir corde droite vers droite
	dc.b	57,14+$80,14,5
	dc.b	58,12+$80,7,4	;pos 2 : repos corde droite
	dc.b	58,13+$80,5,4	;pos 2 : tir corde droite vers droite
	dc.b	58,14+$80,5,5-1
	dc.b	59,12+$80,5,4	;pos 3 : repos corde droite
	dc.b	59,13+$80,4,4	;pos 3 : tir corde droite vers droite
;a8
	dc.b	59,14+$80,4,4
	dc.b	62,11+$80,-7+1,6	;pos 1 :repos corde g
	dc.b	62,10+$80,-7+1,7-1	;pos 1 :tir corde g vers gauche
	dc.b	62,9+$80,-9,5
	dc.b	61,11+$80,-8-1,4	;pos 2 : repos corde gauche
	dc.b	61,10+$80,-9,4	;pos 2 : tir corde gauche vers gauche
	dc.b	61,9+$80,-12,5-1
	dc.b	60,11+$80,4-2-2,4	;pos 3 : repos corde gauche
;b0
	dc.b	60,10+$80,-1,4	;pos 3 : tir corde gauche vers gauche
	dc.b	60,9+$80,-4,4
;
; rajouts 19/04/90
;
;b8
	dc.b	36,17,21,0	;tir accrpi droite vers bas-droite
	dc.b	36,18,20,0
	dc.b	35,15,-6,0	;tir accrpi gauche vers bas-gauche
	dc.b	35,16,-6,0

;------------------------------------------------
SPR1=CORPS
SPR42=SPR1+16752
SPR67=SPR42+18272
SPR75=SPR67+3104
SPR93=SPR75+7776
SPR105=SPR93+4384

IMAGECORPS:

	DC.L	SPR1+$0,$121E0000
	DC.L	SPR1+$1E0,$E1F0100
	DC.L	SPR1+$2D8,$10200200
	DC.L	SPR1+$3D8,$131E0000
	DC.L	SPR1+$5B8,$D200200
	DC.L	SPR1+$6B8,$12200200
	DC.L	SPR1+$8B8,$12200600
	DC.L	SPR1+$AB8,$D200B00
	DC.L	SPR1+$BB8,$131E0700
	DC.L	SPR1+$D98,$10200800
	DC.L	SPR1+$E98,$E1F0B00
	DC.L	SPR1+$F90,$121E0800
	DC.L	SPR1+$1170,$15250000
	DC.L	SPR1+$13C0,$15250000
	DC.L	SPR1+$1610,$11220200+12
	DC.L	SPR1+$1830,$D240400+10
	DC.L	SPR1+$1950,$10210000+8
	DC.L	SPR1+$1A58,$13230100+13
	DC.L	SPR1+$1C88,$D260300+10
	DC.L	SPR1+$1DB8,$F230100+7
	DC.L	SPR1+$1ED0,$101F0100+7
	DC.L	SPR1+$1FC8,$D1F0200+9
	DC.L	SPR1+$20C0,$E1F0200+12
	DC.L	SPR1+$21B8,$131F0000+12
	DC.L	SPR1+$23A8,$E1F0100+9
	DC.L	SPR1+$24A0,$1F180300
	DC.L	SPR1+$2620,$1A1A0800
	DC.L	SPR1+$27C0,$1B170500
	DC.L	SPR1+$2930,$1E160300
	DC.L	SPR1+$2A90,$1B170700
	DC.L	SPR1+$2C00,$1B170600
	DC.L	SPR1+$2D70,$1E160700
	DC.L	SPR1+$2ED0,$1B170800
	DC.L	SPR1+$3040,$1A1A0600
	DC.L	SPR1+$31E0,$1F180600
	DC.L	SPR1+$3360,$20180300
	DC.L	SPR1+$34E0,$20180500
	DC.L	SPR1+$3660,$281D0000
	DC.L	SPR1+$3918,$2B1E0000
	DC.L	SPR1+$3BE8,$2B1E0000
	DC.L	SPR1+$3EB8,$281D0300

	DC.L	SPR42+$0,$17330000
	DC.L	SPR42+$330,$1B280000+$ff00
	DC.L	SPR42+$5B0,$17330000+$0202
	DC.L	SPR42+$8E0,$1D250000
	DC.L	SPR42+$B30,$19140000
	DC.L	SPR42+$C70,$1B360000+$0400+2
	DC.L	SPR42+$FD0,$1A360000+$0400+2
	DC.L	SPR42+$1330,$1A360000+$fb00
	DC.L	SPR42+$1690,$1B360000+$fa00
	DC.L	SPR42+$19F0,$1B330000+$0100+2
	DC.L	SPR42+$1D20,$1A330000+$0100+2
	DC.L	SPR42+$2050,$1A330000+$fe00
	DC.L	SPR42+$2380,$1B330000+$fd00
	DC.L	SPR42+$26B0,$1A330000+$fe00
	DC.L	SPR42+$29E0,$1A330000+$0100+2
	DC.L	SPR42+$2D10,$1C2E0000
	DC.L	SPR42+$2FF0,$10310C00
	DC.L	SPR42+$3178,$17301000
	DC.L	SPR42+$3478,$17300200
	DC.L	SPR42+$3778,$10310D00
	DC.L	SPR42+$3900,$1C2E0D00
	DC.L	SPR42+$3BE0,$202F0000
	DC.L	SPR42+$3ED0,$202D0000
	DC.L	SPR42+$41A0,$202D0000
	DC.L	SPR42+$4470,$202F0000
	DC.L	SPR67+$0,$28140003
	DC.L	SPR67+$1E0,$1D16fb05
	DC.L	SPR67+$340,$2610f200
	DC.L	SPR67+$4C0,$1A150004
	DC.L	SPR67+$610,$1A150604
	DC.L	SPR67+$760,$26100800
	DC.L	SPR67+$8E0,$1D160805
	DC.L	SPR67+$A40,$2814f803
	DC.L	SPR75+$0,$161C0300
	DC.L	SPR75+$1C0,$151C0400
	DC.L	SPR75+$380,$191C0000
	DC.L	SPR75+$540,$191C0000+8+$fa06
	DC.L	SPR75+$700,$151C0000+8+$fa06
	DC.L	SPR75+$8C0,$161C0000+8+$fa06
	DC.L	SPR75+$A80,$1E1B0000
	DC.L	SPR75+$C30,$1E1C0000
	DC.L	SPR75+$DF0,$1E1B0000
	DC.L	SPR75+$FA0,$1E1B0200+$f20a
	DC.L	SPR75+$1150,$1E1C0200+$f20a
	DC.L	SPR75+$1310,$1E1B0200+$f20a
	DC.L	SPR75+$14C0,$1C190000+$0000
	DC.L	SPR75+$1650,$1C1A0000+$0000
	DC.L	SPR75+$17F0,$201A0000+$fc00
	DC.L	SPR75+$1990,$201A0000
	DC.L	SPR75+$1B30,$1C1A0000
	DC.L	SPR75+$1CD0,$1C190000
	DC.L	SPR93+$0,$E1F0400
	DC.L	SPR93+$F8,$131F0000
	DC.L	SPR93+$2E8,$E1F0300
	DC.L	SPR93+$3E0,$D1F0400
	DC.L	SPR93+$4D8,$101F0200
	DC.L	SPR93+$5D0,$F230400
	DC.L	SPR93+$6E8,$D260400
	DC.L	SPR93+$818,$13230000
	DC.L	SPR93+$A48,$10230400
	DC.L	SPR93+$B60,$D240300
	DC.L	SPR93+$C80,$11220100
	DC.L	SPR93+$EA0,$1B280000+$ffff

	DC.L	IMAGEMORT+$0,$201B0000		;mort 105
	DC.L	IMAGEMORT+$1B0,$20200000	;     106
IMAGETETES:
	DC.L	TETES2+$0,$200011
	DC.L	TETES2+$110,$200017
	DC.L	TETES2+$280,$200014
	DC.L	TETES2+$3C0,$200014
	DC.L	TETES2+$500,$200017
	DC.L	TETES2+$670,$200011
	DC.L	TETES2+$780,$200011
	DC.L	TETES2+$890,$200011
	DC.L	TETES2+$9A0,$200015
	DC.L	TETES2+$AF0,$200016
	DC.L	TETES2+$C50,$200014
	DC.L	TETES2+$D90,$200014
	DC.L	TETES2+$ED0,$200016
	DC.L	TETES2+$1030,$200015
	DC.L	TETES2+$1180,$200017
	DC.L	TETES2+$12F0,$200014
	DC.L	TETES2+$1430,$200014
	DC.L	TETES2+$1570,$200017
	DC.L	TETES2+$16E0,$200017
	DC.L	TETES2+$1850,$200013
	DC.L	TETES2+$1980,$200013
	DC.L	TETES2+$1AB0,$200017
	DC.L	TETES2+$1C20,$200015
	DC.L	TETES2+$1D70,$200016
	DC.L	TETES2+$1ED0,$200014
	DC.L	TETES2+$2010,$200014
	DC.L	TETES2+$2150,$200016
	DC.L	TETES2+$22B0,$200015
	DC.L	TETES2+$2400,$200012
	DC.L	TETES2+$2520,$200012

;================================================
;---- IMAGE ENEMIS ------------------------------

IMAGEGATE:
	DC.L	0
	DC.b 	112,112,0,0
	DC.L	6272,$40230000
	DC.L	$460+6272,$40230000
	DC.L	$8C0+6272,$40230000
	DC.L	$D20+6272,$201A0000
	DC.L	$EC0+6272,$201A0000
	DC.L	$1060+6272,$201A0000
	DC.L	$1200+6272,$30080000
	DC.L	$12C0+6272,$30090000
	DC.L	$1398+6272,$300C0000
	DC.L	$14B8+6272,$300A0000
	DC.L	$15A8+6272,$300B0000
	DC.L	$16B0+6272,$300A0000
	DC.L	$17A0+6272,$20080000
	DC.L	$1820+6272,$20050000
	DC.L	$1870+6272,$201A0000
	DC.L	$1A10+6272,$201A0000
	DC.L	$1BB0+6272,$201A0000
	DC.L	$1D50+6272,$10080000
	DC.L	$1D90+6272,$20090000
	DC.L	$1E20+6272,$300C0000
	DC.L	$1F40+6272,$300A0000
	DC.L	$2030+6272,$300B0000
	DC.L	$2138+6272,$300A0000
	DC.L	$2228+6272,$30080000
	DC.L	$22E8+6272,$30050000
	DC.L	$2360+6272,$103E0000
IMAGEHERBAMO:
	DC.L	$0,$20160000
	DC.L	$160,$20170000
	DC.L	$2D0,$20160000
	DC.L	$430,$20170000
	DC.L	$5A0,$20160000
	DC.L	$700,$20160000
	DC.L	$860,$20160000
	DC.L	$9C0,$20170000
	DC.L	$B30,$20160000
	DC.L	$C90,$20170000
IMAGETORPEDO:
	DC.L	$0,$301A0007
	DC.L	$270,$30130000
	DC.L	$438,$301A0000
	DC.L	$6A8,$30220000
	DC.L	$9D8,$30180000
	DC.L	$C18,$30100000

IMAGEKILLER:
	DC.L	$0,$1E1B0002
	DC.L	$1B0,$1D0E0000
	DC.L	$290,$1E110003
	DC.L	$3A0,$1D170000
	DC.L	$510,$18180200
	DC.L	$690,$17160200
	DC.L	$7F0,$16140300
	DC.L	$930,$1E1B0002
	DC.L	$AE0,$1D0E0100
	DC.L	$BC0,$1E110003
	DC.L	$CD0,$1D170100
	DC.L	$E40,$18180100
IMAGEFLYING:
	DC.L	$0,$201E0000
	DC.L	$1E0,$200D0000
	DC.L	$2B0,$20120005
	DC.L	$3D0,$201E0011
	DC.L	$5B0,$30170000
	DC.L	$7D8,$30170000
	DC.L	$A00,$201E0000
	DC.L	$BE0,$200D0000
	DC.L	$CB0,$20120005
	DC.L	$DD0,$201E0011
	DC.L	$FB0,$30170000
	DC.L	$11D8,$30170000
IMAGEGARNIGAR:
	DC.L	$0,$30170000
	DC.L	$228,$30170000
	DC.L	$450,$30160000
	DC.L	$660,$30160000
	DC.L	$870,$30170000
	DC.L	$A98,$30170000
	DC.L	$CC0,$301B0000
	DC.L	$F48,$201F0000
	DC.L	$1138,$201F0000
	DC.L	$1328,$20240000
	DC.L	$1568,$20250000
	DC.L	$17B8,$201F0000
	DC.L	$19A8,$201F0000
	DC.L	$1B98,$201F0000
	DC.L	$1D88,$20240000
	DC.L	$1FC8,$20250000
	DC.L	$2218,$201F0000
IMAGEWEBSTAMI:
	DC.L	$0,$20170000
	DC.L	$170,$20170000
	DC.L	$2E0,$20180000
	DC.L	$460,$20180000
	DC.L	$5E0,$20180000
	DC.L	$760,$30160000
	DC.L	$970,$200C0000
	DC.L	$A30,$40170000
IMAGETIRWEBSTAMI:
	DC.L	$00,$08080000
	DC.L	$30,$08080000
	DC.L	$60,$08080000
	DC.L	$90,$08080000
IMAGEBLASTUM:
	DC.L	$0,$20170000
	DC.L	$170,$20170000
	DC.L	$2E0,$20190000
	DC.L	$470,$20180000
	DC.L	$5F0,$20150000
	DC.L	$740,$20170000
	DC.L	$8B0,$20170000
	DC.L	$A20,$20190000
	DC.L	$BB0,$20180000
	DC.L	$D30,$20150000
IMAGEKALGATRO:
	DC.L	$0,$30250000
	DC.L	$378,$30260000
	DC.L	$708,$30250000
	DC.L	$A80,$30300000
	DC.L	$F00,$30270000
	DC.L	$12A8,$30260000
	DC.L	$1638,$30240000
	DC.L	$1998,$30200000
	DC.L	$1C98,$30170000
	DC.L	$1EC0,$30100000
	DC.L	$2040,$30050000
	DC.L	$20B8,$20250000
	DC.L	$2308,$20260000
	DC.L	$2568,$20250000
	DC.L	$27B8,$20300000
	DC.L	$2AB8,$30270000
	DC.L	$2E60,$30260000
	DC.L	$31F0,$20240000
	DC.L	$3430,$20200000
	DC.L	$3630,$20170000
	DC.L	$37A0,$20100000
	DC.L	$38A0,$20050000
IMAGEWOBALIN:
	DC.L	$0,$20100000
	DC.L	$100,$20180000
	DC.L	$280,$301C0000
	DC.L	$520,$30210000
	DC.L	$838,$301B0000
	DC.L	$AC0,$20180000
	DC.L	$C40,$20160000
	DC.L	$DA0,$10150000
IMAGEGEES:
	DC.L	$0,$201C0000
	DC.L	$1C0,$20180000
	DC.L	$340,$201C0000
	DC.L	$500,$20180000
	DC.L	$680,$301B0000
	DC.L	$908,$201B0000
	DC.L	$AB8,$201C0000
	DC.L	$C78,$20180000
	DC.L	$DF8,$201C0000
	DC.L	$FB8,$20180000
IMAGEGEES1:
	DC.L	$0,$201C0000
	DC.L	$1C0,$201C0000

IMAGESHARTOES:
	DC.L	$0,$20070005
	DC.L	$70,$200E0006
	DC.L	$150,$200E0006
	DC.L	$230,$20070003
	DC.L	$2A0,$200D0006
	DC.L	$370,$200E0006
	DC.L	$450,$200E0000
	DC.L	$530,$200E0000
	DC.L	$610,$20070005
	DC.L	$680,$200E0006
	DC.L	$760,$200E0006
	DC.L	$840,$20070003
	DC.L	$8B0,$200D0006
	DC.L	$980,$200E0006
	DC.L	$A60,$200E0000
	DC.L	$B40,$200E0000
IMAGEMONTANT:
	DC.L	$0,$30300000
IMAGEROCHER:
	DC.L	$0,$201C0000
IMAGEREBORD:
	DC.L	$0,$200F0000
IMAGEPIQUE:
	DC.L	$0,$20300000
	DC.L	$300,$202D0000
	DC.L	$5D0,$202C0000
IMAGEBOULE:
	DC.L	$0,$080F0000
	DC.L	$78,$080D0000
IMAGETREMPLIN:
	DC.L	$0,$20160000
	DC.L	$160,$400D0000
	DC.L	$300,$400D0000
IMAGEBIGTETE1:
	DC.L	$0,$272D0000
	DC.L	$438,$282B0000
	DC.L	$840,$292B0000
	DC.L	$C48,$292B0000
	DC.L	$1050,$282B0000
	DC.L	$1458,$272D0000
	DC.L	$1890,$E0C0000
	DC.L	$18F0,$E0C0000
	DC.L	$1950,$1A080000
	DC.L	$19D0,$1A080000
	DC.L	$1A50,$18080000
	DC.L	$1AD0,$18080000
	DC.L	$1B50,$08080000
	DC.L	$1B90,$08080000
	DC.L	$1BD0,$09090000
	DC.L	$1C18,$09090000
	DC.L	$1C60,$0B090000
	DC.L	$1CA8,$0B090000
	DC.L	$1CF0,$08080000
	DC.L	$1D30,$08080000
	DC.L	$1D70,$0B050000
	DC.L	$1D98,$0B050000
	DC.L	$1DC0,$0B050000
	DC.L	$1DE8,$0B050000
	DC.L	$1E10,$10150000
	DC.L	$1EB8,$10150000
	DC.L	$1F60,$0F060000
	DC.L	$1F90,$0F060000
IMAGEBIGCORP1:
	DC.L	$0,$1E2B0000
	DC.L	$2B0,$1E2B0000
	DC.L	$560,$1E300000
	DC.L	$860,$1E300000
	DC.L	$B60,$1E2D0000
	DC.L	$E30,$1E2D0000
	DC.L	$1100,$2C310000
	DC.L	$1598,$2C310000
	DC.L	$1A30,$12140000
	DC.L	$1B70,$12140000
	DC.L	$1CB0,$19160000
	DC.L	$1E10,$19160000
	DC.L	$1F70,$1A160000
	DC.L	$20D0,$1A160000
	DC.L	$2230,$1E0F0000
	DC.L	$2320,$1E0F0000
	DC.L	$2410,$11150000
	DC.L	$2560,$11150000
	DC.L	$26B0,$15160000
	DC.L	$2810,$15160000
	DC.L	$2970,$1C160000
	DC.L	$2AD0,$1C160000
IMAGECASCADE:
	dc.l	0,$30590000
	dc.l	$858,$30590000
	dc.l	$10B0,$30580000
	dc.l	$18F0,$30590000
	dc.l	$2148,$30070000
	dc.l	$21F0,$30090000
	dc.l	$22C8,$30070000
	dc.l	$2370,$30080000
	dc.l	$2430,$30200000
IMAGETIMAGON:
	DC.L	$0,$1F1D0000
	DC.L	$1D0,$1F1C0000
	DC.L	$390,$1F1B0000
	DC.L	$540,$1F1D0000
	DC.L	$710,$1C1E0000
	DC.L	$8F0,$271C0000
	DC.L	$B90,$1F1C0000
	DC.L	$D50,$1E1C0000
	DC.L	$F10,$161E0000
	DC.L	$10F0,$1F1D0800
	DC.L	$12C0,$1F1D0800
	DC.L	$1490,$1F1C0800
	DC.L	$1650,$1F1B0800
	DC.L	$1800,$1C1E0B00
	DC.L	$19E0,$271C0000
	DC.L	$1C80,$1F1C0900
	DC.L	$1E40,$1E1C0A00
	DC.L	$2000,$161E1200
	DC.L	$21E0,$15190100
	DC.L	$2370,$17170000
	DC.L	$24E0,$F170000
	DC.L	$2598,$11160000
	DC.L	$26F8,$E0A0000
	DC.L	$2748,$E0A0000
	DC.L	$2798,$C100300
	DC.L	$2818,$B0E0200
IMAGEPOISSON:
	DC.L	$0,$0F0F0000
	DC.L	$78,$100D00ff
	DC.L	$E0,$F0A0000
	DC.L	$130,$D0A0000
	DC.L	$180,$F0F0000
	DC.L	$1F8,$100D00ff
;------------------------------------------------
IMAGEPIECE:
	DC.L	PIECE+$0,$100F0000
	DC.L	PIECE+$78,$100F0000
	DC.L	PIECE+$F0,$100F0000
	DC.L	PIECE+$168,$100F0000
IMAGEICON:
	DC.L	ICONA+$0,$0D1D0300		;CASQUE
	DC.L	ICONA+$E8,$101D0100
	DC.L	ICONA+$1D0,$101D0000
	DC.L	ICONA+$2B8,$0D1D0300
	DC.L	ICONB+$0,$F1B0000		;NIKE
	DC.L	ICONB+$D8,$101B0000
	DC.L	ICONB+$1B0,$0D1B0000
	DC.L	ICONB+$288,$0D1A0000
	DC.L	ICONC+$0,$20100000		;boulle 1
	DC.L	ICONC+$100,$20100000
	DC.L	ICONC+$200,$10100000		;boulle 2
	DC.L	ICONC+$280,$10100000
	DC.L	ICONC+$300,$10100000		;boulle 3
	DC.L	ICONC+$380,$10100000
	DC.L	ICOND+$0,$10100000		;boulle bleux
	DC.L	ICOND+$80,$10100000
IMAGEBULLES:
	DC.L	BULLES+$00,$0E0A0100+$fb
	DC.L	BULLES+$14,$0C0E0100+$ff
	DC.L	BULLES+$30,$0E0E0000
	DC.L	BULLES+$4C,$110B0000+$fd
IMAGEGABANA:
	DC.L	$0,$1D170200
	DC.L	$170,$1D190202
	DC.L	$300,$1F1B0100
	DC.L	$4B0,$1B180000
	DC.L	$630,$130F0500
	DC.L	$720,$D0A0600
	DC.L	$770,$1D190002
	DC.L	$900,$1D170000
	DC.L	$A70,$1C1B0000
	DC.L	$C20,$1B1C0000
	DC.L	$DE0,$1B1C0000
	DC.L	$FA0,$1C1B0000
IMAGECUPPER:
	DC.L	$0,$361B0100
	DC.L	$360,$2F1706ff
	DC.L	$588,$32180500
	DC.L	$888,$351801fd
	DC.L	$B88,$331700ff
	DC.L	$E68,$301700ff
	DC.L	$1090,$291600fe
	DC.L	$12A0,$1C1100fb
	DC.L	$13B0,$29160Efe
	DC.L	$15C0,$301707ff
	DC.L	$17E8,$331704ff
	DC.L	$1AC8,$351801fd
	DC.L	$1DC8,$32180000
	DC.L	$20C8,$2F1702ff
	DC.L	$22F0,$361B0000

IMAGEGMOTOI:
	DC.L	$0,$241302ff
	DC.L	$1C8,$26140100
	DC.L	$3A8,$271000fc
	DC.L	$528,$221B0604
	DC.L	$7B0,$1E1108fc
	DC.L	$8C0,$170D0Af9
	DC.L	$990,$20160602
	DC.L	$AF0,$1F0E07fa
	DC.L	$BD0,$1E1107fb
	DC.L	$CE0,$1F1607fe
	DC.L	$E40,$21180400
	DC.L	$1080,$1F190701
	DC.L	$1210,$21180700
	DC.L	$1450,$241301ff
	DC.L	$1618,$26140000
	DC.L	$17F8,$271000fc
	DC.L	$1978,$211B0004
	DC.L	$1C00,$20160602

IMAGEBOMBE:
	DC.L	$0,$00D0D06ff
	DC.L	$68,$0E0E0500
	DC.L	$D8,$0F0E0500
	DC.L	$148,$19150003

IMAGEPMOTOI:
	DC.L	$0,$130A0100
	DC.L	$A0,$150800fe
	DC.L	$120,$100A0300
	DC.L	$170,$D0704fe
	DC.L	$1A8,$130A0000
	DC.L	$248,$150801fe

;-------------------------------------------------
IMAGETIRTOKI:
	DC.L	TIRTOKI+$0,$08070000
	DC.L	TIRTOKI+$2A,$08070000
	DC.L	TIRTOKI+$54,$0b0b0000
	DC.L	TIRTOKI+$96,$0b0b0000
	DC.L	TIRTOKI+$D8,$201a0006
	DC.L	TIRTOKI+$210,$20130004
	DC.L	TIRTOKI+$2F4,$20100002
	DC.L	TIRTOKI+$3B4,$20090000
;--------------------------------------------------
;-----   sauver et initialiser le system       ----
;--------------------------------------------------
INIT:

	lea $dff000,a6
	move $2(a6),dmaconr
	move $1c(a6),intenar
	move #$7fff,$96(a6)
	move #$7fff,$9a(a6)
	move.l $6c,ancvbl
	move.l $68,ancclav
	move.l #irq,$6c
	move.l #INT2,$68

	move.l #bitplane,logique
	move.l #bitplane+[tailbpl*5],physique

;-- init bande --
	move.l #BANDE,d0
	lea PBANDE,a1
	move.w d0,6(a1)
	swap d0
	move.w d0,2(a1)
	swap d0
	add.l #672,d0
	move.w d0,14(a1)
	swap d0
	move.w d0,10(a1)
	swap d0
	add.l #672,d0
	move.w d0,22(a1)
	swap d0
	move.w d0,18(a1)
	swap d0
	add.l #672,d0
	move.w d0,30(a1)
	swap d0
	move.w d0,26(a1)

	move.l #spritenul,d0
	lea sspr1,a0
	move.w d0,6(a0)
	swap d0
	move.w d0,2(a0)

	move d0,10(a0)
	swap d0
	move d0,14(a0)

	move d0,22(a0)
	swap d0
	move d0,18(a0)

	move d0,26(a0)
	swap d0
	move d0,30(a0)

	move d0,38(a0)
	swap d0
	move d0,34(a0)

	move d0,42(a0)
	swap d0
	move d0,46(a0)

	move d0,54(a0)
	swap d0
	move d0,50(a0)

	move d0,58(a0)
	swap d0
	move d0,62(a0)

attendrevbl:
	cmp.b #255,$6(a6)
	bne.s attendrevbl
	move.l #copper,$80(a6)
	clr $88(a6)
	move.w #%1000011111000000,$96(a6)
	move #$c028,$9a(a6)
	rts

intenar:	dc.w 0
dmaconr:	dc.w 0
ancvbl:		dc.l 0
ancclav:	dc.l 0
;============= restorer le system ==================
RESTORER:
	move #$4000,$dff09a
	lea $330000,a0
	lea $1000,a1
	move.w #[$10000/4]-1,d0
	btrasl:
	move.l (a0)+,(a1)+
	dbf d0,btrasl


	move.l ancvbl,$6c
	move.l ancclav,$68
	move dmaconr,d0
	or #$8000,d0
	move d0,$dff096
	move intenar,d0
	or #$8000,d0
	move d0,$dff09a

	MOVE.L 4,A6
	LEA NAME,A1
	MOVEQ #0,D0
	JSR -552(A6)
	MOVE.L D0,A0
	MOVE.L 38(A0),$DFF080		;ancien copper liste
	CLR.W $DFF088			;et start copper-list
	MOVE.L D0,A1
	JSR -414(A6)
	JSR -138(A6)
	RTS
NAME:	DC.B "graphics.library",0
	even
;==============================================================
FLIP:
	move.l logique(pc),d0
	move.l physique,logique
	move.l d0,physique

waitvbl:
	cmp #2,nbvbl
	bmi.s waitvbl
	clr nbvbl

	lea plan1,a1
	move.w d0,6(a1)
	swap d0
	move d0,2(a1)
	swap d0
	add.l #tailbpl,d0
;	lea 8(a1),a1
	move.w d0,6+8(a1)
	swap d0
	move d0,2+8(a1)
	swap d0
	add.l #tailbpl,d0
;	lea 8(a1),a1
	move.w d0,6+16(a1)
	swap d0
	move d0,2+16(a1)
	swap d0	
	add.l #tailbpl,d0
;	lea 8(a1),a1
	move.w d0,6+24(a1)
	swap d0
	move d0,2+24(a1)
	swap d0
	add.l #tailbpl,d0
;	lea 8(a1),a1
	move.w d0,6+32(a1)
	swap d0
	move d0,2+32(a1)
	rts

physique:	dc.l 0
logique:	dc.l 0
nbvbl:		dc.w 0
;==============================================================
INT2: 
	move #$f00,$dff180
	MOVEM.L D0/A1,-(A7)
	LEA     $BFE001.L,A1
	MOVE.B  $0D00(A1),D0
	BTST    #$0003,D0
	BEQ.s     TOUCH1 
	MOVE.B  $0C00(A1),D0
	OR.B    #$0040,$0E00(A1)
	NOT.B   D0
	ROR.B   #1,d0
	MOVE.B  D0,TOUCHE
	MOVE.W  #50,D0
TOUCH2:	DBF     D0,TOUCH2 
	AND.B   #$00BF,$0E00(A1)
TOUCH1:	MOVE.W  #$0008,$dff09C
	MOVEM.L (A7)+,D0/A1
	move #$000,$dff180
	RTE     
TOUCHE:		DC.L 0

;=====================================
IRQ:	movem.l d0-d7/a0-a6,-(a7)
	move.w $dff01c,d0
	btst #5,d0
	beq irqfin

;btst #1,direction+1
;beq.s dgv
;move #$000,$dff102
;btst #0,nbvbl+1
;beq.s dgv
;move #$0011,$dff102
;bra.s ddgv
;dgv:
;btst #3,direction+1
;beq.s dddgv
;move #$0011,$dff102
;btst #0,nbvbl+1
;beq.s ddgv
;move #$0000,$dff102
;bra.s ddgv
;dddgv:
;move #0000,$dff102
;ddgv:

	add #1,nbvbl

cmp #1,level
bne.s pasrotation
;--- rotation palette level 1----
	cmp #1,newpalette
	bne.s pasrotation
	eor #1,vitrot
	tst vitrot
	bne.s pasrotation
	lea newpal1,a0
	lea palettedevant,a1
	movem.w 10(a0),d0-d2
	move d0,12(a0)	
	move d1,14(a0)	
	move d2,10(a0)	
	move.w d0,22(a1)
	move.w d1,26(a1)
	move.w d2,30(a1)

pasrotation:
;------ orage level 5 -----
	cmp #5,level
	bne.s pasorage

	tst.b florage
	bne.s okorage
	addq #1,temporage
	and #127,temporage
	bne.s pasorage
	move.b #1,florage

okorage:
	lea palettedevant+30,a0
	lea palorage(pc),a1
	move cptorage(pc),d0
	add d0,d0
	move.w (a1,d0.w),d0
	bne.s ctorage
	clr cptorage
	clr.b florage
	move.w (a1),d0
ctorage:move d0,(a0)
	addq #1,cptorage

pasorage:
;====== gestion port ========

	lea port_1(pc),a5
	clr.w (a5)
	move.w $dff00c,d0

	btst #1,d0
	beq.s pase
	ori #2,(a5)
pase:
	btst #9,d0
	beq.s paso
	ori #8,(a5)
paso:
	move d0,d1
	lsr #1,d1
	eor d0,d1
	btst #0,d1
	beq.s pass
	ori #4,(a5)
pass:
	btst #8,d1
	beq.s pasn
	ori #1,(a5)
pasn:

;--- gestion antirebond ---	
	tst.w (a5)
	bne.s ddty
	clr.b antirebondh
ddty:
	btst #1,1(a5)
	bne.s dtty
	btst #3,1(a5)
	bne.s dtty
	clr.b antirebondgd
;--------------------------
dtty:
	btst #7,$bfe001		;tir ?
	bne.s past
	ori  #16,(a5)
past:
	cmp.b #$4f,touche
	bne.s pasgg
	ori #8,(a5)
pasgg:
	cmp.b #$4e,touche
	bne.s pasdd
	ori #2,(a5)
pasdd:
	cmp.b #$4d,touche
	bne.s pasbb
	ori #4,(a5)
pasbb:

	cmp.b #$19,touche
	bne.s passauver
	move #1,flagsauver
passauver:


irqfin:
	movem.l (sp)+,d0-d7/a0-a6
	move.w #$0fff,$dff09c
	rte
port_1:		dc.w 0
vitrot:		dc.w 0
cptorage:	dc.w 0
temporage:	dc.w 0
flagsauver:	dc.w 0
antirebondh:	dc.b 0
antirebondgd:	dc.b 0
florage:	dc.b 0
 even 
palorage:
 dc.w $001,$001,$001,$001,$001,$001,$fff,$eef,$111,$555
 dc.w $aaf,$eef,$fff,$fff,$fff,$fff,$eee,$ddd,$bbb
 dc.w $aaa,$999,$888,$777,$eee,$555,$ddd,$333,$555,$111,0

;==============================================================

;--------------------------------------------
;---------- ROUTINE BOB ---------------------
pasaffbob:
	rts
bob:
	tst.b 24(a0)			;si type = 0
	beq.s pasaffbob			;pas afficher sprite


	move.l 20(a0),a5		;init source image
	clr d2
	move.b 8(a0),d2
	subq.b #1,d2
	lsl #3,d2			;*8
	add d2,a5
	move.l (a5),a2			;adresse image

	move.b 4(a5),5(a0)		;tail x
	move.b 5(a5),7(a0)		;tail y
	move.b 6(a5),d2			;ofset x
	move.b 7(a5),d3			;ofset y

	movem.w xmap(a0),d0-d1
	ext d2
	ext d3
	add d2,d0
	add d3,d1
	sub posmapx(pc),d0		;pour X
	sub posmapy(pc),d1
	add #176,d1
	movem.w d0-d1,(a0)


aff_bob:move 6(a0),d2
	sub d2,2(a0)			;y bas
aff_bob2:
	move (a0),d0			
	cmp #224,d0			;trop a droite ?
	bpl.s pasaffbob			;oui
	add 4(a0),d0			;trop gauche ?
	bmi.s pasaffbob			;oui

	move 2(a0),d0
	cmp #176,d0
	bpl.s pasaffbob
	add 6(a0),d0
	bmi.s pasaffbob

	lea $dff000,a5		
	move.l #$ffff0000,Firstmask	;first=$ffff , secon = 0

	move 4(a0),d0		;largeur
	add #15,d0
	and #$fff0,d0
	move d0,a3

	asr #3,d0
	move d0,d5		;stoker pour apres 
	mulu 6(a0),d0		;*auteur
;	asr #3,d0		;/8
	move.w d0,tailbp	;tail d'un plan bob (octet)
;	asr #4,d5		;tl x dv par 16  c'est ici APRES !!!!!
	asr #1,d5
	addq #1,d5		;D5=modulo bob +16


	moveq #30,d4		;preparer modulo ecran
	sub d5,d4		;
	sub d5,d4		;modulo ecran=30-2*modulo bob

	moveq #0,d7
	move d7,a6		;position image
	moveq #0,d2		;MOD a zero
	move 2(a0),a4		;charge val initial posy
	move.w 6(a0),d7		;tail y initial (ligne)

;----------- cliping haut ------------
	move a4,d0
	bpl.s pashaut
	neg d0
	move #0,a4		;clr posy
	sub d0,d7		;d7=nv hauteur bob

;----- calculer posimage  ----
	move a3,d1		;largeur
	asr #3,d1		;en word
	mulu d1,d0		;largeur en word * hauteur en moins
	move d0,a6		;stocker valeur
	bra.s clipgauche	;continuer 

;-===== cliping bas =====-
pashaut:
	move a4,d1		;pos y
	add 6(a0),d1
	cmp #176,d1	  	;>176 ??
	bmi.s clipgauche	;non pasclip bas 	
	move #176,d7
	sub a4,d7		;nv hauteur du bob
;----------------------- cliping gauche -------------------------
clipgauche:
	move (a0),d6		;D6=position x initial
	bpl.s clipdroit		;si x>0 pas de cliping
	move d6,d0		
	neg d0			;Abs(x)
	move d0,d1          
	lsr #4,d0		;p. fort   x
	and #15,d1		;p. Faible x
	sub d0,d5		;Larg=larg-p. fort x
	move d1,d6		;0+rotation 0>-15
	neg d6
	lsl #1,d0 
	add d0,d4
	add d0,a6		;ofset =x*2
	move d0,d2		;Modulo Source+x*2

	lea mask_tab(pc),a1
	add d1,d1
	move.w (a1,d1.w),Firstmask
	bra.s continuerbob
;-------------
clipdroit:
	move a3,d0		;largaur
	add d6,d0		;+posx
	sub.w #224,d0
	bmi.s continuerbob

	move #224,d0
	sub  d6,d0		;Largeur reste
	move.l d0,d1
	and #15,d1
	move a3,d3		;largeur image
	sub d0,d3		;-Largeur reste
	lsr #4,d3
	move d3,d2		;modulo
	add d3,d2
	addq #2,d2

	addq #1,d3
	sub d3,d5
	add d3,d4		;modulo D
	add d3,d4
	lea mask_tab2(pc),a1
	add d1,d1
	move.w (a1,d1.w),secondmask
;-------------------------------------------------
continuerbob:
	move.l logique,a1	;adresse de l'ecran actuel

	move a4,d0		;charger valeur y du bob
	move d0,d1		
	asl #5,d0		;*32
	sub d1,d0		;
	sub d1,d0		;d0*30

	move d6,d1
	asr #3,d6		;/8
	add d0,d6
	add d6,a1		;add ecran 
	and #$000f,d1
	ror #4,d1		;d1= shifting

;-- calculer size du bob --
	tst d7
	beq.s pasdebob
	asl #6,d7
	ori d5,d7

;--- afficher les 5 plans du bob ---
	move.l firstmask(pc),$44(a5)	;masquer bob pour shiffter
	move d2,d6		;+MOD
	subq #2,d6

	move.w d4,$60(a5)	;MODULO C=image dest
	move.w d6,$62(a5)	;MODULO B=image bob
	move.w d6,$64(a5)	;MODULO A=mask
	move.w d4,$66(a5)	;MODULO D=image dest
	move d1,$42(a5)		;shifting dans B	
	move d1,d2
	ori #$0FCA,d1		;D=(A+B).(notA+C)
	move d1,$40(a5)		;shifting dans A

	move.l a2,a3		;add du mask

	move a6,d0		;a6=posimage
	add d0,a2
	add d0,a3

	move tailbp(pc),d0

;-== add du mask = plan 4 ==-
	add d0,a3
	add d0,a3
	add d0,a3

	btst #6,24(a0)			;remap ??
	bne.s afficherremap		;oui vas-y

	moveq #$3f,d1
	and.b 24(a0),d1
	subq.b #1,d1
	add d1,d1
	add d1,d1
	jmp tbltype(pc,d1.w)
pasdebob:
	rts	

TBLTYPE:
	bra affichertype1
	bra affichertype1
	bra affichertype3
	bra affichertype4
	bra affichertype5
	bra affichertype6
	bra affichertype7
	bra affichertype8
	bra affichertype6
	bra affichertype6
	
;====== afficher en remap ==========
afficherremap:
	move d2,d3
	or #$0b0a,d2		;D=notA.C
	move d2,$40(a5)
	move.l a3,a2		;mask -> data bob
	move.l a1,a4
	movem.l a1-a4,$48(a5)	;passer C,B,A,D
	move.w d7,$58(a5)	;PLAN 1
	lea  tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 2
	or #$0bfa,d3		;D=A+C
	move d3,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 3
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 4
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 5
	bclr #6,24(a0)		;plus de remap 
	rts
;-========= TYPE 8 ===========-
affichertype8:
move d2,d3
or #$0b0a,d2
move d2,$40(a5)
	move.l a2,a3
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 1
	lea  tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 2
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 3

move d3,d2
or #$0bfa,d3
move d3,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 4


or #$0b0a,d2
move d2,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)
	rts
;-========= TYPE 1 ===========-
affichertype1:
	move.l a1,a4
	movem.l a1-a4,$48(a5)	;passer C,B,A,D
	move.w d7,$58(a5)	;PLAN 1
	add d0,a2
	lea  tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 2
	
	add d0,a2
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 3

	move d2,d3
	or #$0bfa,d2		;D=A+C
	move d2,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 4

	or #$0b0a,d3		;D=notA.C
	move d3,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 5
	rts

;-==== TYPE 3 ======-
affichertype3:
	move.l a1,a4
	movem.l a1-a4,$48(a5)	;passer C,B,A,D
	move.w d7,$58(a5)	;PLAN 1

	add d0,a2
	lea  tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 2
	
	add d0,a2
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 3

	or #$0bfa,d2		;D=A+C
	move d2,$40(a5)
	add d0,a2
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 4

	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 5
	rts

;-==== TYPE 4 ======-
affichertype4:
	sub d0,a3
	move.l a1,a4
	movem.l a1-a4,$48(a5)	;passer C,B,A,D
	move d7,$58(a5)	;PLAN 1
	add d0,a2
	lea  tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move d7,$58(a5)	;PLAN 2
	
	or #$0bfa,d2		;D=A+C
	move d2,$40(a5)
	move.l a3,a2
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move d7,$58(a5)	;PLAN 3
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move d7,$58(a5)	;PLAN 4
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move d7,$58(a5)	;PLAN 5
	rts

;-==== TYPE 5 ======-
affichertype5:
	move.l a1,a4
	movem.l a1-a4,$48(a5)	;passer C,B,A,D
	move.w d7,$58(a5)	;PLAN 1

	add d0,a2
	lea  tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 2
	

	move d2,d3
	or #$0bfa,d3		;D=A+C
	move d3,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 3

	move d2,d3
	or #$0fca,d3		
	move d3,$40(a5)
	add d0,a2
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 4

	move d2,d3
	or #$0bfa,d3		;D=A+C
	move d3,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 5
	rts

;-==== TYPE 6 ======-
affichertype6:

	move d2,d3
	or #$0bfa,d3
	move d3,$40(a5)
	move.l a1,a4
	move.l a1,$48(a5)	;c
	move.l a3,$4c(a5)	;b
	move.l a3,$50(a5)	;a
	move.l a4,$54(a5)	;d
	move.w d7,$58(a5)	;PLAN 1

	move d2,d3
	or #$0fca,d3
	move d3,$40(a5)
	lea  tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 2
	add d0,a2
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 3

	add d0,a2
	lea tailbpl(a1),a1
	move.l a1,a4	
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 4

	move d2,d3
	or #$0bfa,d3		;D=A+C
	move d3,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 5
	rts

;-==== TYPE 7 =====-
affichertype7:

	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 1	

	move d2,d3
	or #$0bfa,d3		;mask
	move d3,$40(a5)
	add d0,a2
	lea  tailbpl(a1),a1
	move.l a1,a4
	move.l a1,$48(a5)	;c
	move.l a3,$4c(a5)	;b
	move.l a3,$50(a5)	;a
	move.l a4,$54(a5)	;d
	move.w d7,$58(a5)	;PLAN 2

	move d2,d3
	or #$0fca,d3		;miterm
	move d3,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 3
	add d0,a2
	lea tailbpl(a1),a1
	move.l a1,a4
	movem.l a1-a4,$48(a5)
	move.w d7,$58(a5)	;PLAN 4

	move d2,d3
	or #$0bfa,d3		;mask
	move d3,$40(a5)
	lea tailbpl(a1),a1
	move.l a1,a4
	move.l a1,$48(a5)	;c
	move.l a3,$4c(a5)	;b
	move.l a3,$50(a5)	;a
	move.l a4,$54(a5)	;d
	move.w d7,$58(a5)	;PLAN 5
	rts


posimage:	dc.w 0
posy:		dc.w 0
tailbp:		dc.w 0
firstmask:	dc.w 0
secondmask:	dc.w 0

tableasl:
 dc.b 0,4,5,6,7,8,9,10,11,12,13,14
mask_tab:
 dc.w	%1111111111111111
 dc.w	%0111111111111111
 dc.w	%0011111111111111
 dc.w	%0001111111111111
 dc.w	%0000111111111111
 dc.w	%0000011111111111
 dc.w	%0000001111111111
 dc.w	%0000000111111111
 dc.w	%0000000011111111
 dc.w	%0000000001111111
 dc.w	%0000000000111111
 dc.w	%0000000000011111
 dc.w	%0000000000001111
 dc.w	%0000000000000111
 dc.w	%0000000000000011
 dc.w	%0000000000000001
mask_tab2:
 dc.w	%1111111111111111
 dc.w	%1000000000000000
 dc.w	%1100000000000000
 dc.w	%1110000000000000
 dc.w	%1111000000000000
 dc.w	%1111100000000000
 dc.w	%1111110000000000
 dc.w	%1111111000000000
 dc.w	%1111111100000000
 dc.w	%1111111110000000
 dc.w	%1111111111000000
 dc.w	%1111111111100000
 dc.w	%1111111111110000
 dc.w	%1111111111111000
 dc.w	%1111111111111100
 dc.w	%1111111111111110
 dc.w	%1111111111111111
;---------------------------
;==============================================================
Copper:
sspr1:	dc.l $01200000,$01220000
	dc.l $01240000,$01260000
	dc.l $01280000,$012a0000
	dc.l $012c0000,$012e0000
	dc.l $01300000,$01320000
	dc.l $01340000,$01360000
	dc.l $01380000,$013a0000
	dc.l $013c0000,$013e0000
	dc.w $3c01,$ff00

PLAN1:	DC.W $e0,$0005,$e2,tailbpl*0		;240*192
PLAN2:	DC.W $e4,$0005,$e6,tailbpl*1
PLAN3:	DC.W $e8,$0005,$ea,tailbpl*2
PLAN4:	DC.W $ec,$0005,$ee,tailbpl*3
PLAN5:	DC.W $f0,$0005,$f2,tailbpl*4
PLAN6:	DC.W $f4,$0007,$f6,$987c

	dc.w $0100,$5000
	DC.W    $0104,$0000
	DC.W	$0108,0
	DC.W	$010a,0
	DC.W	$0092,$0050	;ECRAN DE 240*176
	DC.W	$0094,$00c0
	DC.W	$008e,$3c91
	DC.W	$0090,$0490
	DC.W	$0102,$0000

palettedevant:
	dc.w    $180,0	
	dc.w    $182,0
	dc.w    $184,0
	dc.w    $186,0
	dc.w    $188,0
	dc.w    $18a,0
	dc.w    $18c,0
	dc.w    $18e,0

	dc.w    $190,0	;TOKI
	dc.w    $192,0
	dc.w    $194,0
	dc.w    $196,0
	dc.w    $198,0
	dc.w    $19a,0
	dc.w    $19c,0
	dc.w    $19e,0
	dc.w  	$1a0,0	;PLAN DEVANT
	dc.w  	$1a2,0
	dc.w  	$1a4,0
	dc.w  	$1a6,0
	dc.w  	$1a8,0
	dc.w  	$1aa,0
	dc.w  	$1ac,0
	dc.w  	$1ae,0
chg1:	dc.w  	$1b0,0	
	dc.w  	$1b2,0	
	dc.w  	$1b4,0	
	dc.w  	$1b6,0	
	dc.w  	$1b8,0
	dc.w  	$1ba,0
	dc.w  	$1bc,0
	dc.w  	$1be,0

	dc.w $ec01,$ff00
	dc.w $0100,$4200
	DC.W	$0108,-2
	DC.W	$010a,-2
	DC.W	$0102,0000

PBANDE:	DC.W $e0,$0000,$e2,0		;224*24
	DC.W $e4,$0000,$e6,0		
	DC.W $e8,$0000,$ea,0		
	DC.W $ec,$0000,$ee,0		
	DC.W	$008e,$3c91		
	DC.W	$0090,$0491
	dc.w    $182,$a84,$184,$c60,$186,$642,$188,$0ac
	dc.w    $18a,$864,$18c,$06c,$18e,$04a,$190,$ec0,$192,$ea0
	dc.w 	$194,$999,$196,$282,$198,$ccc,$19a,$c42
	dc.w 	$19c,$e82,$19e,$820
	dc.l 	$fffffffe
spritenul:	dc.l 0
;======================================
newpalette:dc.w 0

;----- level 1 -----
newpal0:dc.w 0,$eee,$dae,$84d,$40b,$05f,$39f,$8df
 dc.w $eee,$ff8,$fc0,$02e,$da6,$b73,$941,$710,0
 dc.w $ca5,$d60,$a42,$09f,$974,$05c,$039,$0d0
 dc.w $060,$642,$0a0,$dd9,$d30,$f80,$820
newpal1:dc.w 0,$310,$642,$975,$b97,$19f,$4bf,$8df	
 dc.w $eee,$ff8,$fc0,$02e,$da6,$b73,$941,$710,0
 dc.w $ca5,$d60,$a42,$09f,$974,$05c,$039,$0d0
 dc.w $060,$642,$0a0,$dd9,$d30,$f80,$820
newpal2:dc.w 0,$eee,$cae,$a6e,$82c,$28e,$4ae,$8ce	
 dc.w $eee,$ff8,$fc0,$02e,$da6,$b73,$941,$710,0
 dc.w $ca5,$d60,$a42,$09f,$974,$05c,$039,$0d0
 dc.w $060,$642,$0a0,$dd9,$d30,$f80,$820

;----- level 2 -----
newpal21:
 dc.w 0,$016,$02a,$02c,$04f,$06f,$0af,$8ee
 dc.w $fff,$ff8,$fc0,$02e,$da6,$b73,$941,$710
 dc.w 0,$a84,$c60,$a42,$07f,$861,$05d,$03a,$0a0
 dc.w $060,$0c0,$080,$cc8,$e00,$e82,$800
newpal22:
 dc.w 0,$fff,$ddd,$aaa,$888,$04e,$08f,$f00
 dc.w $eee,$ff8,$fc0,$02e,$da6,$b73,$941,$710
 dc.w 0,$a84,$c60,$a42,$07f,$861,$05d,$03a,$a80
 dc.w $420,$642,$860,$cc8,$e00,$e82,$800

;----- level 3 -----
newpal31:
 dc.w $000,$204,$406,$608,$80a,$c00,$a00,$800
 dc.w $eee,$ff8,$fc0,$02e,$da6,$b73,$941,$710
 dc.w $000,$a84,$6a8,$e60,$06c,$864,$04c,$02a
 dc.w $2a2,$264,$042,$486,$cc8,$e20,$ea0,$a00

;----- level 4 -----
newpal41:
 dc.w $000,$006,$208,$40c,$64e,$84e,$a6e,$c8e
 dc.w $eee,$ff8,$fc0,$02e,$da6,$b73,$941,$710
 dc.w $000,$ca6,$aee,$0ce,$0ae,$a86,$08e,$00c
 dc.w $2a2,$262,$262,$282,$eee,$e00,$e82,$820

;----- level 5 -----
newpal51:
 DC.W $000,$CCc,$aaa,$888,$ac0,$8a0,$680,$000
 DC.W $eee,$ff8,$fc0,$02e,$da6,$b73,$941,$710
 DC.W $000,$A84,$E00,$AAC,$88A,$864,$668,$446
 DC.W $0A0,$060,$040,$080,$CC8,$C00,$E82,$820

;--------------------------------------------
AFFICHERFONT:
	lea $dff000,a5
	moveq #-1,d0		;mask blitter a $ffffffff
	move.l d0,$44(a5)

	move direction,d0
	and.w maskscrolling,d0
	btst #1,d0		;DROITE ?
	beq.s pasdrte
	bsr scrollingdroite
pasdrte:move direction,d0
	and.w maskscrolling,d0
	btst #3,d0		;GAUCHE ?
	beq.s pasga
	bsr scrollinggauche

pasga:	move direction,d0
	and.w maskscrolling,d0
	btst #0,d0		;HAUT ?
	beq.s dpasht
	bsr scrollinghaut
	move pesanteur,d0
	not d0
	cmp #4,d0
	bmi.s dpashaut
	bsr scrollinghaut
	move pesanteur,d0
	not d0
	cmp #7,d0
	bmi.s dpashaut
	bsr scrollinghaut	
dpashaut:rts

dpasht:	move direction,d0
	and.w maskscrolling,d0
	btst #2,d0		;BAS ?
	beq.s dpasbas
	bsr scrollingbas

	cmp #4,pesanteur
	bmi.s dpasbas
	bsr scrollingbas
	cmp #7,pesanteur
	bmi.s dpasbas
	bsr scrollingbas	
dpasbas:rts


;=================================================
maxposmapx:	dc.w 0
maxposmapy:	dc.w 0
minposmapx:	dc.w 0
minposmapy:	dc.w 0

scrollingdroite:
	move maxposmapx,d0
	cmp.w posmapx,d0
	ble afffond
	addq.w #2,posmapx
	subq.w #1,xscrolplan2
	bpl.s pasfind
	move #15,xscrolplan2	
	addq.l #2,posxb2
	addq.w #1,vposxb2
	move.l #28,d0
	move.l #0,d1
	move vposxb2,d4
	add #14,d4
	bsr  afficherbande

pasfind:
	tst xscrolplan1
	bne.s dpasfind
	move #16,xscrolplan1	

	addq.l #2,posxb1
	addq.w #1,vposxb1
	move.l #28,d0
	move.l #0,d1
	move vposxb1,d4
	add #14,d4
	bsr  dafficherbande
dpasfind:
	subq.w #2,xscrolplan1
	bra.L afffond

scrollinggauche:
	tst posmapx
	beq afffond
	subq.w #2,posmapx
	addq.w #1,xscrolplan2
	cmp #16,xscrolplan2
	bmi.s pasfing
	move #0,xscrolplan2
	subq.l #2,posxb2
	moveq #0,d0
	subq.w #1,vposxb2
	move vposxb2,d4
	bsr  afficherbande
pasfing:addq.w #2,xscrolplan1
	cmp #16,xscrolplan1
	bmi.s dpasfing
	move #0,xscrolplan1
	subq.l #2,posxb1
	moveq #0,d0
	move.l #30,d1
	subq.w #1,vposxb1
	move vposxb1,d4
	bsr  dafficherbande
dpasfing:
	bra afffond

;------------------------------------------------
scrollinghaut:
	tst posmapy
	beq afffond
	subq #2,posmapy
	tst.l yscrolplan2
	bne.s pasfinh
	move.l #30*16,yscrolplan2
;-----------------------------------
;-- tester limite haute bufferpl2 --
;-----------------------------------
	tst.l posyb2
	bpl.s prtyb2
	add.l #480*12,posyb2	
	bsr recohvbb2
prtyb2:	sub.l #480,posyb2
	move mapingx,d0
	sub d0,vposxb2

	move vposxb2,d4
	moveq #0,d0
	move.l #480*12,d1
	bsr  afficherbandeh
pasfinh:;***** plan devant *****
	sub.l #30,yscrolplan2
cmp #2,level
bne.s yio
cmp #1,zone
beq.s yio
sub.l #30,yscrolplan2
yio:
	tst.l yscrolplan1
	bne.s dpasfinh
	move.l #60*8,yscrolplan1
;-----------------------------------
;-- tester limite haute bufferpl1 --
;-----------------------------------
	tst.l posyb1
	bpl.s prtyb1
	add.l #480*12,posyb1	
	bsr recohvbb1
prtyb1:	sub.l #480,posyb1
	move mapingx,d0
	sub d0,vposxb1

	move vposxb1,d4
	moveq #0,d0
	move.l #480*12,d1
	bsr  dafficherbandeh
dpasfinh:
	sub.l #30*2,yscrolplan1
	bra afffond

;============ SCROLLING BAS ==============
scrollingbas:

	move maxposmapy,d0
	cmp posmapy,d0
	beq afffond

	addq.w #2,posmapy

	add.l #30,yscrolplan2
cmp #2,level
bne.s yyio
cmp #1,zone
beq.s yyio
add.l #30,yscrolplan2
yyio:

	cmp.l #30*16,yscrolplan2
	bmi.s pasfinb
	clr.l yscrolplan2

;===== tester limite bas du bufferbp2 =====
	add.l #480,posyb2
	cmp.l #480*12,posyb2
	bne.s psrsbf2
	move.l #0,posyb2
	bsr recobvhb2
psrsbf2:
	move mapingx,d0
	add d0,vposxb2
	move vposxb2,d4
	mulu #11,d0
	add d0,d4
	move.l #[480*11],d0
	move.l #-[480*12],d1
	bsr  afficherbandeh


pasfinb:
	add.l #30*2,yscrolplan1
	cmp.l #60*8,yscrolplan1
	bmi.s dpasfinb
	clr.l yscrolplan1
;===== tester limite bas du bufferbp1 =====
	add.l #480,posyb1
	cmp.l #480*12,posyb1
	bne.s psrsbf
	move.l #0,posyb1
	bsr recobvhb1
psrsbf:
;	add.w #60,vposxb1
move mapingx,d0
add d0,vposxb1

	move vposxb1,d4
mulu #11,d0
add d0,d4
	move.l #[480*11],d0
	move.l #-[480*12],d1
	bsr  dafficherbandeh
dpasfinb:
	bra.s afffond

afffond:rts

posmapx:	dc.w 0
posmapy:	dc.w 0
;===============================================
affichermap:	
;---- transfere masque -----

	moveq #0,d0
	move.l posxb1,d2
	add.l posyb1,d2

	move yscrolplan1,d0
	add.l yscrolplan1,d2	
	add.l d0,d2	

	moveq #0,d0
	move.w #[64*176]+15,d3
	move.l d0,$60(a5)		;modulo c b
	move.l d0,$64(a5)		;modulo a d

	move xscrolplan1,d0
	ror #4,d0
	move d0,d1			;sauver shifter a
	or.w #$09f0,d0
	move.w d0,$40(a5)

	move.l #bufferpl1+[tailbpb1*4],a0
	add.l d2,a0
	move.l logique,a1
	add.l #[tailbpl*4]-2,a1
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		;plan mask 

;=====================================
;====== afficher 3 plans avec miterm = a.c+b
;=====================================
;A = buffer 2
;B = buffer 1
;C = not mask deja shifte

afficherdevant:
	move xscrolplan2,d0
	ror #4,d0
	or #$0fdc,d0			
	move d0,$40(a5)			;shift buff 2
	move d1,$42(a5)			;shift A dans shift B

	move.l logique,a0		;c = mask en plan 5 
	add.l #[tailbpl*4]-2,a0
	move.l #bufferpl1,a1		;b= buffb 1
	add.l d2,a1			 

	move.l #bufferpl2,a2		;a= buffb 2
	add.l posxb2,a2		 
	add.l posyb2,a2
	add.l yscrolplan2,a2

	move.l logique,a3			;destination
	subq.l #2,a3

	movem.l a0-a3,$48(a5)		 
	move d3,$58(a5)		;plan 2

	lea tailbpb1(a1),a1		
	lea tailbpb1(a2),a2		
	lea tailbpl(a3),a3		
	movem.l a0-a3,$48(a5)		 
	move d3,$58(a5)		;plan 3

	lea tailbpb1(a1),a1		
	lea tailbpb1(a2),a2		
	lea tailbpl(a3),a3		
	movem.l a0-a3,$48(a5)		 
	move d3,$58(a5)		;plan 4

;---- 1 passe d=a ---- 
	or #$09f0,d1				;d=a  
	move d1,$40(a5)				;shift A
	move.l #bufferpl1+[tailbpb1*3],a0	;a=map buff a1
	add.l d2,a0			
	move.l logique,a1			;D=destination
	add.l #[tailbpl*3]-2,a1
	movem.l a0-a1,$50(a5) 
	move d3,$58(a5)
	rts

xscrolplan1:	dc.w 0
yscrolplan1:	dc.l 0
xscrolplan2:	dc.w 0
yscrolplan2:	dc.l 0

;==================================================
;===    preparer band de 11*16*16 verticale      ==
;==================================================
afficherbande:
	move.l #$09f00000,$40(a5)
	move.l #$0000001c,$64(a5)	;MODULO A
	move.l #bufferpl2,a1
	add.l posxb2,a1
	add.l posyb2,a1
	add.l d0,a1
	move #[64*16]+1,d3		;BLT-SIZE
	move.w mapingx,d6		;largeur MAPING

	moveq #12-1,d7			;12 vignettes 
dvigla2:
;-- calculer vignette a afficher --
	moveq #0,d5
	move.w d4,d5
	move.l #tablevignettepl2,a2	;table des vignette
	move.b (a2,d5.w),d5		;prendre no de vignette
	move.l #vignettepl2,a0
	move #$00ff,d2
	and d2,d5
	move d5,d2
	asl #6,d5			;*64
	asl #5,d2			;*32
	add d2,d5			;*96
	add.l d5,a0

	move.l a0,a2
	move.l a1,a3

	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 1
	lea 32(a2),a2			
	lea tailbpb2(a3),a3		
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 2
	lea 32(a2),a2			
	lea tailbpb2(a3),a3		
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 3

	lea 30*16(a1),a1		;pos vgn suivt
	add d6,d4			;rechercher vgn suivante
	dbf d7,dvigla2			;si pas fini boucle
	rts

;==================================================
;===    preparer band de 30*16*16 horizontal     ==
;==================================================
afficherbandeh:
	move.l #-1,$44(a5)
	move.l #$09f00000,$40(a5)
	move.l #$0000001c,$64(a5)	;MODULO A D
	move.l #vignettepl2,a0
	move.l #bufferpl2,a1
	add.l posxb2,a1
	add.l posyb2,a1
	add.l d0,a1
	move #[64*16]+1,d3
	moveq #15-1,d7			;15 colones de vign / ligne
dviglah2:
;-- calculer vignette a afficher --
	moveq #0,d5
	move.w d4,d5
	move.l #tablevignettepl2,a2	;table des vignette
	move.b (a2,d5.w),d5		;prendre no de vignette
	move #$00ff,d2
	and d2,d5
	move.l #vignettepl2,a0
	move d5,d2
	asl #6,d5		;*64
	asl #5,d2		;*32
	add d2,d5		;*96
	add.l d5,a0

	move.l a0,a2
	move.l a1,a3

	movem.l a2-a3,$50(a5)		
	move d3,$58(a5)			;plan 1
	lea 32(a2),a2	
	lea tailbpb2(a3),a3
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 2
	lea 32(a2),a2	
	lea tailbpb2(a3),a3
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 3

	lea 2(a1),a1
	addq #1,d4			;vignette suivante
	dbf d7,dviglah2

;-- recopier band plus bas --	
	move.w #0,$66(a5)
	move.l #bufferpl2,a0
	add.l posxb2,a0
	add.l posyb2,a0
	add.l d0,a0
	move.l a0,a1
	add.l d1,a1
	move #[64*16]+15,d3
		
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		;bande pl1  
	lea tailbpb2(a0),a0
	lea tailbpb2(a1),a1	
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		;bande pl2 
	lea tailbpb2(a0),a0
	lea tailbpb2(a1),a1	
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		;bande pl3 
	rts

;==================================================
;==================================================
;===   preparer band de 11*16*16 verticale devant==
;==================================================
dafficherbande:

	move.l #$09f00000,$40(a5)
	move.l #$0000001c,$64(a5)	;MODULO A
	move.l #bufferpl1,a1
	add.l posxb1,a1
	add.l posyb1,a1
	add.l d0,a1
	move #[64*16]+1,d3		;vig 16*16
	move.w mapingx,d6

	moveq #12-1,d7			;12 vignettes 
dvigla:
;-- calculer vignette a afficher --
	moveq #0,d5
	move.w d4,d5
	move.l #tablevignettepl1,a2	;table des vignette
	move.b (a2,d5.w),d5		;prendre no de vignette
	move.l #vignettepl1,a0
	move #$00ff,d2
	and d2,d5
	move d5,d2
	asl.w #7,d5		;*128
	asl.w #5,d2		;*32
	add.w d2,d5		;*160
	add.l d5,a0

	move.l a0,a2
	move.l a1,a3

	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 1

	lea 32(a2),a2			 
	lea tailbpb1(a3),a3		
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 2

	lea 32(a2),a2
	lea tailbpb1(a3),a3
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 3

	lea 32(a2),a2
	lea tailbpb1(a3),a3
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 4

	lea 32(a2),a2
	lea tailbpb1(a3),a3
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 5

	lea 30*16(a1),a1		;afficher vgn suivt
	add d6,d4			;rechercher vgn suivante
	dbf d7,dvigla
	rts

posxb1:		dc.l 0
posyb1:		dc.l 0
vposxb1:	dc.w 0
posxb2:		dc.l 0
posyb2:		dc.l 0
vposxb2:	dc.w 0
mapingx:	dc.w 0		;LARGEUR MAPING (en vignettes)
mapingy:	dc.w 0		;HAUTEUR MAPING (en vignettes)

;==================================================
;===    preparer band de 30*16*16 horizontal     ==
;==================================================
dafficherbandeh:
	move.l #$09f00000,$40(a5)
	move.l #$0000001c,$64(a5)	;MODULO A D
	move.l #vignettepl1,a0
	move.l #bufferpl1,a1
	add.l posxb1,a1
	add.l posyb1,a1
	add.l d0,a1

	move #[64*16]+1,d3
	moveq #15-1,d7			;15 colones de vign / ligne
dviglah:
;-- calculer vignette a afficher --
	moveq #0,d5
	move.w d4,d5
	move.l #tablevignettepl1,a2	;table des vignette
	move.b (a2,d5.w),d5		;prendre no de vignette
	move #$00ff,d2
	and d2,d5
	move.l #vignettepl1,a0
	move d5,d2
	asl #7,d5		;*128
	asl #5,d2		;*32
	add d2,d5		;*160
	add.l d5,a0

	move.l a0,a2
	move.l a1,a3

	movem.l a2-a3,$50(a5)		
	move d3,$58(a5)			;plan 1
	lea 32(a2),a2	
	lea tailbpb1(a3),a3
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 2
	lea 32(a2),a2	
	lea tailbpb1(a3),a3
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 3
	lea 32(a2),a2	
	lea tailbpb1(a3),a3
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 4
	lea 32(a2),a2	
	lea tailbpb1(a3),a3
	movem.l a2-a3,$50(a5)
	move d3,$58(a5)			;plan 5

	lea 2(a1),a1
	addq #1,d4
	dbf d7,dviglah

;-- recopier band plus bas --	
	clr.w $66(a5)
	move.l #bufferpl1,a0
	add.l posxb1,a0
	add.l posyb1,a0
	add.l d0,a0
	move.l a0,a1
	add.l d1,a1
	move #[64*16]+15,d3
		
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		;bande pl1
	lea tailbpb1(a0),a0
	lea tailbpb1(a1),a1	
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		;bande pl2
	lea tailbpb1(a0),a0
	lea tailbpb1(a1),a1	
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		;bande pl3
	lea tailbpb1(a0),a0
	lea tailbpb1(a1),a1	
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		;bande pl4
	lea tailbpb1(a0),a0
	lea tailbpb1(a1),a1	
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		;bande pl5
	rts
;-------------------------------------------------------------
;------------------------------------------------------------
recohvbb1:	
	lea $dff000,a5
	move.l #$09f00000,$40(a5)
	move.l #-1,$44(a5)
	clr.l  $64(a5)
	move.l #bufferpl1,a0
	add.l posxb1,a0
	move.l a0,a1
	add.l #[12*480],a1
	move #[64*176]+15,d3		
	moveq #5-1,d7
recopierloop:
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		
	lea tailbpb1(a0),a0			
	lea tailbpb1(a1),a1	
	dbf d7,recopierloop
	rts

recobvhb1:	
	lea $dff000,a5
	move.l #$09f00000,$40(a5)
	move.l #-1,$44(a5)
	clr.l $64(a5)
	move.l #bufferpl1,a0
	add.l posxb1,a0
	move.l a0,a1
	add.l #[12*480],a0
	move #[64*176]+15,d3		
	move #5-1,d7
brecopierloop:
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		
	lea tailbpb1(a0),a0			
	lea tailbpb1(a1),a1	
	dbf d7,brecopierloop
	rts
;-------------------------------------------------------------
recohvbb2:	
	lea $dff000,a5
	move.l #$09f00000,$40(a5)
	move.l #$ffffffff,$44(a5)
	move.l #0,$64(a5)
	move.l #bufferpl2,a0
	add.l posxb2,a0
	move.l a0,a1
	add.l #[12*480],a1
	move #[64*176]+15,d3		
	move #3-1,d7
recopierloop2:
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		
	lea tailbpb2(a0),a0			
	lea tailbpb2(a1),a1	
	dbf d7,recopierloop2
	rts

recobvhb2:	
	lea $dff000,a5
	move.l #$09f00000,$40(a5)
	move.l #-1,$44(a5)
	move.l #0,$64(a5)
	move.l #bufferpl2,a0
	add.l posxb2,a0
	move.l a0,a1
	add.l #[12*480],a0
	move #[64*176]+15,d3		
	move #3-1,d7
brecopierloop2:
	movem.l a0-a1,$50(a5)
	move d3,$58(a5)		
	lea tailbpb2(a0),a0			
	lea tailbpb2(a1),a1	
	dbf d7,brecopierloop2
	rts


;-------------------------------------------------------------
INITPLAN1:;rafrechir map en hironzotal
;---= plan de devant =---
	lea $dff000,a5
	move.l #-1,$44(a5)
	moveq #15-1,d7
	moveq #0,d0
raffb1loop:
	move vposxb1,d4			
	movem.l d0/d7,-(sp)
	bsr dafficherbande
	movem.l (sp)+,d0/d7
	addq.w #1,vposxb1
	addq.l #2,posxb1		
	dbf d7,raffb1loop
	sub.l #15*2,posxb1
	sub.w #15,vposxb1
;---= plan du fond =---
INITPLAN2:
;	movem.l d0-d7,-(sp)
;	move posmap1init,vposxb2	;position vignette dans map
	moveq #15-1,d7
	moveq #0,d0
braffb1loop:
	move vposxb2,d4			
	movem.l d0/d7,-(sp)
	bsr afficherbande
	movem.l (sp)+,d0/d7
	addq.w #1,vposxb2
	addq.l #2,posxb2		
	dbf d7,braffb1loop
;	movem.l (sp)+,d0-d7
	sub.l #15*2,posxb2
	sub.w #15,vposxb2
	rts
posmap1init:	dc.w 0
;----------------------------------

;-------  tester changement palette -----------------
testerchangement:
	tst.b flagmort
	bne pasnpl3

	clr d0
	move level,d0
	subq #1,d0
	add d0,d0
	add d0,d0
	jmp changement(pc,d0.w)

changement:
 bra changlv1
 bra changlv2
 bra changlv3
 bra changlv4
 bra changlv5
 bra changlv6

changlv1:
	cmp #1,newpalette
	beq.s pasnpl
	cmp #2,zone
	bne.s pasnpl
	sub #[60*6],vposxb2
	lea newpal1,a0
	lea palettedevant,a1
	movem.w (a0),d0-d7	
	move d0,2(a1)
	move d1,6(a1)
	move d2,10(a1)
	move d3,14(a1)
	move d4,18(a1)
	move d5,22(a1)
	move d6,26(a1)
	move d7,30(a1)
	move #1,newpalette
	lea $dff000,a5
	move vposxb2,d4
	moveq #0,d0
	move.l #480*12,d1
	jsr afficherbandeh
pasnpl:	cmp #2,newpalette
	beq.s pasnpl2
	cmp #7,zone
	bne.s pasnpl2
	lea newpal2,a0
	lea palettedevant,a1
	movem.w (a0),d0-d7	
	move d0,2(a1)
	move d1,6(a1)
	move d2,10(a1)
	move d3,14(a1)
	move d4,18(a1)
	move d5,22(a1)
	move d6,26(a1)
	move d7,30(a1)
	move #2,newpalette
pasnpl2:cmp #1,newpalette
	beq.s pasnpl3
	cmp #6,zone
	bne.s pasnpl3
	lea newpal1,a0
	lea palettedevant,a1
	movem.w (a0),d0-d7	
	move d0,2(a1)
	move d1,6(a1)
	move d2,10(a1)
	move d3,14(a1)
	move d4,18(a1)
	move d5,22(a1)
	move d6,26(a1)
	move d7,30(a1)
	move #1,newpalette
pasnpl3:rts
;-------------------------
changlv2:
	lea bobtoki,a0
	cmp #1900,xmap(a0)
	bpl.s dxv

	lea palettedevant,a0
	lea newpal21,a1
	moveq #32-1,d0
bnul:	move.w (a1)+,2(a0)
	lea 4(a0),a0
	dbf d0,bnul
	bra.s svn

dxv:
	lea palettedevant,a0
	lea newpal22,a1
	moveq #32-1,d0
bbnul:	move.w (a1)+,2(a0)
	lea 4(a0),a0
	dbf d0,bbnul
svn:	rts
;-------------------------
changlv3:
	rts
;-------------------------
changlv4:
	rts
;-------------------------
changlv5:
	rts
;-------------------------
changlv6:
	rts
;-------------------------
xbob=0
ybob=2
tailx=4
taily=6
image=8
xmap=16
ymap=18

bobtoki:	
 dc.w 30			;pos x
 dc.w 106		;pos y
 dc.w 32			;tail x
 dc.w 38			;tail y
 dc.b 0,0,0,0		;no image corp,tete,decalx,decaly
 dc.w 0,0		;cpt animation
 dc.w 40,880		;xmap,ymap
 dc.l 0			;ptr sur animation 
 dc.b 1			;type de sprite
 even

;-------
bob1:	blk.b 30,0
bob2:	
 dc.w 100		;posx
 dc.w 400		;posy
 dc.w 112		;tailx
 dc.w 128		;taily
 dc.b 1			;no d'animation sprite a afficher
 dc.b 0			;no du sprite (nom du sprite)
 dc.b 0,0 		;??
 dc.w 0,0		;cpt 
 dc.w 774,530	 	;xmap,ymap
 dc.l imageGATE		;sources PTR image pour afficher
 dc.b 1			;type affichage		0=pas afficher
			;			1= type 1 
			;	+$80=gestion si dans ecran
			;	bit 7=0 gestion 
 dc.b 0
 dc.b 0,0
 dc.b 0,0		;flag mort ,
 even


;----
 bob3:			;killer1 nv2
 dc.l 0,0	
 dc.b 1,3,0,0 		
 dc.w 0,0,164,380	
 dc.l IMAGEKILLER
 dc.b 6,0
 dc.b 0,0
 dc.b 0,0
 even
;----
bob4:	
 dc.l 0,0	
 dc.b 1,3,0,0
 dc.w 0,0,106,350	
 dc.l IMAGEKILLER
 dc.b 6,0
 dc.b 0,0
 dc.b 0,0
 even
;----
bob5:	
 dc.l 0,0	
 dc.b 1,3,0,0
 dc.w 0,0,30,140	
 dc.l IMAGEKILLER
 dc.b 6,0
 dc.b 0,0
 dc.b 0,0
 even
;----
bob6:	
 dc.l 0,0	
 dc.b 1,3,0,0
 dc.w 0,0,96,116	
 dc.l IMAGEKILLER
 dc.b 6,0
 dc.b 0,0
 dc.b 0,0
 even
;----
bob7:	
 dc.l 0,0	
 dc.b 1,3,0,0
 dc.w 0,0,1187,68	
 dc.l IMAGEKILLER
 dc.b 6,0
 dc.b 0,0
 dc.b 0,0
 even
;----
bob8:	
 dc.l 0,0	
 dc.b 1,3,0,0
 dc.w 0,0,1982,26	
 dc.l IMAGEKILLER
 dc.b 6,0
 dc.b 0,0
 dc.b 0,0
 even
;----
bob9:	
 dc.l 0,0	
 dc.b 1,4,0,0
 dc.w DR3
 dc.b -3,2		;dir
 dc.w 26,316	
 dc.l IMAGEFLYING
 dc.b $80+3,0
 dc.b 0,0
 dc.b 0,1
;---
bob10:	
 dc.l 0,0	
 dc.b 1,10,0,-8
 dc.b 0,0
 dc.b -11,0
 dc.w 394,64
 dc.l IMAGEGEES
 dc.b 1,0,180,80,0,0
;---
bob11:	
 dc.l 0,0	
 dc.b 1,9,0,1
 dc.w 0
 dc.b 0,0
 dc.w 2160,38
 dc.l IMAGEWOBALIN
 dc.b 0,0
 dc.b 48,176
 dc.b 0,0
;-----
bob12:	
 dc.l 0,0	
 dc.b 1,2,0,0
 dc.w 0
 dc.b 0,0
 dc.w 390,48	
 dc.l IMAGETORPEDO
 dc.b $80+3,0
 dc.b 0,0
 dc.b 0,0
 even
;----
bob13:	
 dc.l 0,0	
 dc.b 1,2,0,0
 dc.w 0
 dc.b 0,0
 dc.w 1618,70	
 dc.l IMAGETORPEDO
 dc.b $80+3,0
 dc.b 0,0
 dc.b 0,0

bob14:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 784,128
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0
;---
bob15:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 789,140
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob16:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 849,168
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob17:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 880,155
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob18:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 780,290
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob19:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 810,280
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob20:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 790,270
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob21:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 1312,114
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob22:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 1342,134
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob23:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 1342,290
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob24:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 1357,255
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob25:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 1952,270
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob26:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 1962,260
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob27:	
 dc.l 0,0	
 dc.b 1,10,0,1
 dc.w 0
 dc.b 0,0
 dc.w 2007,240
 dc.l IMAGEPOISSON
 dc.b 5,0
 dc.b 0,0
 dc.b 0,0

bob28:	
 dc.l 0,0	
 dc.b 1,0,0,0
 dc.b 0,63
 dc.b 0,0
 dc.w 770,160
 dc.l IMAGEGABANA
 dc.b 5,0,0,0,0,2

bob29:	
 dc.l 0,0	
 dc.b 1,0,0,0
 dc.b 0,63
 dc.b 0,0
 dc.w 810,270
 dc.l IMAGEGABANA
 dc.b 5,0,0,0,0,2

bob30:	
 dc.l 0,0	
 dc.b 1,0,0,0
 dc.b 0,63
 dc.b 0,0
 dc.w 998,140
 dc.l IMAGEGABANA
 dc.b 5,0,0,0,0,2

bob31:	
 dc.l 0,0	
 dc.b 1,11,0,0
 dc.b 0,0
 dc.b 0,0
 dc.w 900,240
 dc.l IMAGECUPPER
 dc.b 3,0,0,0,0,2

bob32:	
 dc.l 0,0	
 dc.b 1,11,0,0
 dc.b 0,0
 dc.b 0,0
 dc.w 1280,240
 dc.l IMAGECUPPER
 dc.b 3,0,0,0,0,2

bob33:	
 dc.l 0,0	
 dc.b 1,11,0,0
 dc.b 0,0
 dc.b 0,0
 dc.w 1550,160
 dc.l IMAGECUPPER
 dc.b 3,0,0,0,0,2

bob34:				; DECORT ROCHER		
 dc.l 0,0	
 dc.b 1,1,0,0,0,0,0,0
 dc.w 2064,80
 dc.l IMAGEROCHER
 dc.b 7,0,0,0,0,0

bob35:	
 dc.l 0,0	
 dc.b 1,0,0,0,0,0,0,0
 dc.w 1300,316
 dc.l IMAGEGMOTOI
 dc.b 3,0,0,0,0,1

bob36:	
 dc.l 0,0	
 dc.b 1,0,0,0,0,0,0,0
 dc.w 1400,200
 dc.l IMAGEGMOTOI
 dc.b 3,0,0,0,0,1

bob37:	
 dc.l 0,0	
 dc.b 1,0,0,0,0,0,0,0
 dc.w 1200,250
 dc.l IMAGEGMOTOI
 dc.b 3,0,0,0,0,1

bob38:	
 dc.l 0,0	
 dc.b 7,0,0,0,0,0,0,0
 dc.w 29,432
 dc.l IMAGEGEES
 dc.b 1,0,0,0,0,0


bob39:
 dc.l 0,0	
 dc.b 1,0,0,0
 dc.w 0,0
 dc.w 60,500
 dc.l IMAGEPMOTOI
 dc.b 3,0,0,0,0,0
bob40:
 dc.l 0,0	
 dc.b 1,0,0,0
 dc.w 50,00
 dc.w 60,500
 dc.l IMAGEPMOTOI
 dc.b 3,0,0,0,0,0
bob41:
 dc.l 0,0	
 dc.b 1,0,0,0
 dc.w 100,00
 dc.w 60,500
 dc.l IMAGEPMOTOI
 dc.b 3,0,0,0,0,0
bob42:
 dc.l 0,0	
 dc.b 1,0,0,0
 dc.w 150,00
 dc.w 60,500
 dc.l IMAGEPMOTOI
 dc.b 3,0,0,0,0,0
bob43:
 dc.l 0,0	
 dc.b 1,0,0,0
 dc.w 200,00
 dc.w 60,500
 dc.l IMAGEPMOTOI
 dc.b 3,0,0,0,0,0

;-===================


bob44:	
 dc.l 0,0	
 dc.b 5,0,0,0,0,0,0,0
 dc.w 380,160
 dc.l IMAGECASCADE
 dc.b 5,0,0,0,0,0

bob45:	
 dc.l 0,0	
 dc.b 1,0,0,0,0,0,0,0
 dc.w 380,160
 dc.l IMAGECASCADE
 dc.b 5,0,0,0,0,0

;----------- GROS ENEMIS CARRE ---------
bob46:			;tete 1
 dc.l 0,0	
 dc.b 5,0,0,0,0,0,0,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob47:			;tete 2
 dc.l 0,0	
 dc.b 5,0,0,0,0,0,0,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob48:			;tete 3
 dc.l 0,0	
 dc.b 5,0,0,0,0,0,0,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob49:			;tete 4
 dc.l 0,0	
 dc.b 16,0,0,0,0,0,0,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob50:			;tete 5
 dc.l 0,0	
 dc.b 16,0,0,0,0,0,0,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob51:			;tete 6
 dc.l 0,0	
 dc.b 16,0,0,0,0,0,0,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob52:			;pg 1
 dc.l 0,0	
 dc.b 27,0,0,0,-2,0,0,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob53:			;pg 2
 dc.l 0,0	
 dc.b 27,0,0,0,2,-20,14,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob54:			;pg 3
 dc.l 0,0	
 dc.b 27,0,0,0,-2,-10,5,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob55:			;pg 4
 dc.l 0,0	
 dc.b 27,0,0,0,-2,-28,14,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob56:			;balancoire
 dc.l 0,0	
 dc.b 2,0,0,0,0,0,0,0
 dc.w 066,656
 dc.l IMAGEGATE
 dc.b 1,0,0,0,0,0
bob57:			;flamme gauche
 dc.l 0,0	
 dc.b 1,0,0,0,0,0,0,0
 dc.w 0,0
 dc.l IMAGEGATE
 dc.b 0,0,0,0,0,0
bob58:			;flamme droite
 dc.l 0,0	
 dc.b 1,0,0,0,0,0,0,0
 dc.w 0,0
 dc.l IMAGEGATE
 dc.b 0,0,0,0,0,0
bob59:			;singe droite
 dc.l 0,0	
 dc.b 1,0,0,0,0,0,0,0
 dc.w 0,0
 dc.l IMAGEGEES
 dc.b 1,0,0,0,0,0
bob60:			;singe gauche
 dc.l 0,0	
 dc.b 7,0,0,0,0,0,0,0
 dc.w 0,0
 dc.l IMAGEGEES
 dc.b 1,1,0,0,0,0

bob61:			;bob1  timagon
 dc.l 0,0	
 dc.b 1,0,0,0,0,100,0,0
; dc.w 400,864
dc.w 784,704
 dc.l IMAGETIMAGON
 dc.b 3,0,0,50,0,4
bob62:	blk.b 30,0
bob63:	blk.b 30,0

;------------- bob a effacer  -----------
bobtirdebut:
bobicon:		blk.b 30*6,0
bobshartoes1:		blk.b 30*6,0
bobshartoes2:		blk.b 30*6,0
bobtirtimagon:		blk.b 30*3,0
bobtirwesbtami1:	blk.b 26*6,0
bobtirwesbtami2:	blk.b 26*6,0
bobtirwesbtami3:	blk.b 26*6,0
bobtirpique1:		blk.b 26*5,0
bobtirpique2:		blk.b 26*5,0
bobtirpique3:		blk.b 26*5,0
bobtirtoki:		blk.b 15*26,0
bobtir1:		blk.b 30,0
bobtir2:		blk.b 30,0
bobtir3:		blk.b 30,0
boboption:		blk.b 30*10,0
bobtirbig1:		blk.b 30*10,0
bobtirfin:

;================================================
;============== gestion timer ===================
;================================================


GERERSCORE:
	lea	addscore+4(pc),a0
;---- bruitage ----
tst.l -4(a0)
beq.s peffetscore
;move.l #$50000,$dff0a0
;move #400/2,$dff0a4
;move #1200,$dff0a6
;move #64,$dff0a8
;move #$8001,$dff096
peffetscore:

	lea	score+4(pc),a1
	sub	d0,d0
	abcd	-(a0),-(a1)
	abcd	-(a0),-(a1)
	abcd	-(a0),-(a1)
	abcd	-(a0),-(a1)

	move.l	score(pc),d0
	lea	chiffres(pc),a0
	move.l	#$0f0f0f0f,d1
	and.l	d0,d1
	eor.l	d1,d0
	lsr.l	#1,d0
	asl.l	#3,d1
	movep.l	d0,0(a0)
	movep.l	d1,1(a0)

	move.l	#BANDE,a6
	lea	[24-6]*28+24(a6),a6
	moveq	#4-1,d7
	bsr	affichefast
	rts
affichefast:
	lea	minifonte4(pc),a4
	lea	minifonte0(pc),a5
	moveq	#0,d0
affchif:move.b	(a0)+,d0
	move.l	a4,a1
	add	d0,a1
	move.b	(a0)+,d0
	move.l	a5,a2
	add	d0,a2
	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,(a6)
	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,28(a6)
	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,28*2(a6)
	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,28*3(a6)
	move.b	(a1)+,d0
	or.b	(a2)+,d0
	move.b	d0,28*4(a6)

	addq	#1,a6
	dbra	d7,affchif
	rts

addscore:	dc.l 0
score:		dc.l 0
chiffres:DC.B	0,0,0,0,0,0,0,0
minifonte0:
 dc.b %111,%101,%101,%101,%111,0,0,0 ;0
 dc.b %010,%110,%010,%010,%111,0,0,0 ;1
 dc.b %111,%001,%111,%100,%111,0,0,0 ;2
 dc.b %111,%001,%111,%001,%111,0,0,0 ;3
 dc.b %100,%101,%111,%001,%001,0,0,0 ;4
 dc.b %111,%100,%111,%001,%111,0,0,0 ;5
 dc.b %111,%100,%111,%101,%111,0,0,0 ;6
 dc.b %111,%001,%001,%001,%001,0,0,0 ;7
 dc.b %111,%101,%111,%101,%111,0,0,0 ;8
 dc.b %111,%101,%111,%001,%111,0,0,0 ;9
minifonte4:
 dc.b %1110000,%1010000,%1010000,%1010000,%1110000,0,0,0 ;0
 dc.b %0100000,%1100000,%0100000,%0100000,%1110000,0,0,0 ;1
 dc.b %1110000,%0010000,%1110000,%1000000,%1110000,0,0,0 ;2
 dc.b %1110000,%0010000,%1110000,%0010000,%1110000,0,0,0 ;3
 dc.b %1000000,%1010000,%1110000,%0010000,%0010000,0,0,0 ;4
 dc.b %1110000,%1000000,%1110000,%0010000,%1110000,0,0,0 ;5
 dc.b %1110000,%1000000,%1110000,%1010000,%1110000,0,0,0 ;6
 dc.b %1110000,%0010000,%0010000,%0010000,%0010000,0,0,0 ;7
 dc.b %1110000,%1010000,%1110000,%1010000,%1110000,0,0,0 ;8
 dc.b %1110000,%1010000,%1110000,%0010000,%1110000,0,0,0 ;9
	rts
;================================================

;=====================================================
FONDU:
	tst.w	UpFlag
	bne.s	NoUp	
	bsr.s	TuneUp	
NoUp:	tst.w	DownFlag
	bne.s	loadnul				
	bsr.s	TuneDown
loadnul:rts

tocol:
	dc.w $0000,$0000,$0000,$0000,$0000,$000,$000,$000
	dc.w $0000,$0000,$0000,$0000,$0000,$000,$000,$000
	dc.w $0000,$0000,$0000,$0000,$0000,$000,$000,$000
	dc.w $0000,$0000,$0000,$0000,$0000,$000,$000,$000

TuneUp:	subq.w	#1,Dly
	bne.s	Return
	move.w	#2,Dly
	lea	palettedevant+2,a0
	moveq	#32-1,d7		;32 couleurs
tracols:move.w	(a1)+,(a0)
	lea 	4(a0),a0
	dbf	d7,tracols		;copier couleurs
	moveq	#15,d5
	sub.w	Count,d5
	bsr	UpDown
return:	rts
TuneDown:
	subq.w	#1,Dly
	bne.s	Return
	move.w	#2,Dly
	moveq	#1,d5
UpDown:	lea	palettedevant+2,a0
	moveq	#32-1,d7
DoCols:	moveq	#2,d6
	moveq	#15,d3
	move.w	d5,d4
DoDis:	move.w	(a0),d0
	and.w	d3,d0
	cmp.w	d4,d0
	bcs.s	Skip1
	sub.w	d4,(a0)
	bra.s	Skip2
Skip1:	not.w	d3
	and.w	d3,(a0)
	not.w	d3
Skip2:	asl.w	#4,d4
	asl.w	#4,d3
	dbf	d6,DoDis
	lea	4(a0),a0
	dbf	d7,DoCols
	addq.w	#1,Count
	cmp.w	#16,Count
	bne.s	Ret2
	clr.w	Count
	seq	UpFlag
	seq	DownFlag
ret2:	rts
Count:		dc.w	0
UpFlag:		dc.w	0
DownFlag:	dc.w	0
Dly:		dc.w 1


;=====================================================
;		type,X0,Y0,X1,Y1
y=33
;
; macro SEKA
;
REL:	MACRO
	dc.w	?1*4,?2*16,[y-?5]*16,?4*16,[y-?3]*16
	ENDM
;
; macro DEVPAC
;
;REL:	MACRO
;	dc.w	\1*4,\2*16,(y-\3)*16,\4*16,(y-\5)*16
;	ENDM

tblrelief:
 dc.l relief1,relief2,relief3,relief4,relief5,relief1

relief1:
zonecol1:
	dc.w	5*4,$000,$2E0,$3C0,$390
	dc.w	zonecol2-zonecol1-10
	dc.w	0*4,$000,$370,$0E0,$390
	dc.w	0*4,$0E0,$380,$130,$390
	dc.w	0*4,$130,$360,$1B0,$390
	dc.w	0*4,$1B0,$380,$230,$390
	dc.w	0*4,$230,$370,$260,$390
	dc.w	0*4,$260,$350,$290,$390
	dc.w	0*4,$290,$330,$2B0,$390
	dc.w	0*4,$2E0,$330,$330,$360
	dc.w	0*4,$2E0,$360,$300,$390
	dc.w	0*4,$2E0,$380,$3C0,$390
	dc.w	0*4,$000,$2E0,$2A0,$2F0
	dc.w	0*4,$3B0,$320,$3C0,$390
	dc.w	0*4,$3A0,$190,$3C0,$320
	dc.w	4*4,$2B0,$380,$2E0,$390
zonecol2:
	dc.w	5*4,$2E0,$180,$3C0,$2E0
	dc.w	zonecol3-zonecol2-10
	dc.w	0*4,$3A0,$190,$3C0,$320
	dc.w	0*4,$0F0,$2C0,$370,$2E0
	dc.w	0*4,$380,$240,$3C0,$260
	dc.w	0*4,$2E0,$240,$300,$2C0
	dc.w	0*4,$2B0,$1B0,$2F0,$260
	dc.w	2*4,$300,$240,$310,$290
	dc.w	3*4,$300,$240,$380,$250
	dc.w	7*4,$390,$1B0,$3A0,$200
	dc.w	3*4,$2F0,$1B0,$3A0,$1C0
	dc.w	0*4,$2E0,$180,$3C0,$190
zonecol3:
	dc.w	5*4,$200,$190,$2E0,$2E0
	dc.w	zonecol5-zonecol3-10
	dc.w	1*4,$210-4,$280-4,$250+4,$2C0+4
	dc.w	0*4,$0F0,$2C0,$370,$2E0
	dc.w	0*4,$2B0,$1B0,$2F0,$260

	dc.w	7*4,$2A0,$1B0,$2B0,$220
	dc.w	3*4,$2A0,$1b0,$2B0,$1c0

	dc.w	0*4,$200,$0B0,$250,$190
	dc.w	0*4,$200,$190,$240,$1D0
	dc.w	0*4,$250,$280,$2E0,$2C0
	dc.w	0*4,$200,$1D0,$230,$200
	dc.w	0*4,$200,$200,$220,$220
	dc.w	0*4,$240,$0B0,$3C0,$180
zonecol5:
	dc.w	5*4,$000,$230,$200,$2E0
	dc.w	zonecol6-zonecol5-10
	dc.w	0*4,$0F0,$2C0,$370,$2E0
	dc.w	0*4,$200,$220,$210,$230
	dc.w	0*4,$000,$2C0,$0A0,$2E0
	dc.w	0*4,$000,$290,$030,$2C0
	dc.w	0*4,$000,$020,$010,$290
	dc.w	0*4,$050,$260,$070,$280
	dc.w	0*4,$070,$250,$090,$270
	dc.w	0*4,$090,$230,$0B0,$250
	dc.w	0*4,$0D0,$070,$180,$240
	dc.w	0*4,$180,$0B0,$200,$240
	dc.w	4*4,$0A0,$2D0,$0F0,$2E0
zonecol6:
	dc.w	5*4,$000,$0B0,$0E0,$230
	dc.w	zonecol7-zonecol6-10
	dc.w	0*4,$000,$020,$010,$290
	dc.w	0*4,$0D0,$070,$180,$240
	dc.w	6*4,$070,$130,$080,$180
	dc.w	3*4,$070,$130,$0B0,$140
	dc.w	0*4,$0B0,$210,$0D0,$230
	dc.w	0*4,$010,$130,$020,$230
	dc.w	0*4,$020,$1C0,$030,$220
	dc.w	0*4,$030,$1C0,$040,$200
	dc.w	0*4,$020,$1C0,$080,$1E0
	dc.w	0*4,$020,$130,$030,$190
	dc.w	0*4,$030,$130,$040,$180
	dc.w	0*4,$010,$130,$070,$150
	dc.w	0*4,$0B0,$130,$0D0,$150
zonecol7:
	dc.w	5*4,$000,$000,$2B0,$0B0
	dc.w	zonecol8-zonecol7-10
	dc.w	0*4,$000,$020,$010,$290
	dc.w	0*4,$0D0,$070,$180,$240
	dc.w	0*4,$010,$070,$020,$0A0
	dc.w	0*4,$050,$070,$090,$090
	dc.w	0*4,$090,$060,$0D0,$080
	dc.w	0*4,$000,$000,$0E0,$020
	dc.w	0*4,$1B0,$090,$3C0,$0B0
	dc.w	4*4,$180,$0A0,$1B0,$0B0
	dc.w	0*4,$2B0,$000,$3C0,$0B0
zonecol8:
	dc.w	-1
;---------------------------------------

relief2:
zcol21:
	REL	5,0,0,$E,$21	;ZONE 1
	dc.w	zcol22-zcol21-10
	REL	0,0,0,2,$1C
	REL	0,0,0,$C,1
	REL	0,0,4,5,6
	REL	0,0,$F,5,$10
	REL	0,7,$C,$A,$E
	REL	0,$C,0,$E,$14
	REL	0,$A,5,$C,6
	REL	0,4,$1C,6,$1E
	REL	0,8,$1A,$C,$1C
	REL	0,$D,0,$1C,$18
	REL	1,5,1,$A,6	;diagonale
	REL	6,6,8,7,$E	;liane verticale
	REL	7,$B,9,$C,$14	;liane verticale
	REL	2,2,$13,3,$1C	;liane verticale
	REL	3,6,$D,7,$E	;liane horizontale
	REL	3,$B,$13,$C,$14	;liane horiz
	REL	3,1,$1B,3,$1C	;liane horiz
zcol22:
	REL	5,$D,0,$26,$21
	dc.w	zcol23-zcol22-10
	REL	0,$D,$16,$12,$18
	REL	0,$12,$17,$16,$19
	REL	0,$18,$1A,$26,$1D
	REL	0,$18,$16,$24,$1A
	REL	0,$1C,$B,$1E,$13
	REL	0,$1C,$12,$1F,$13
	REL	0,$1C,$13,$21,$14
	REL	0,$1C,$14,$22,$15
	REL	0,$1C,$15,$23,$16

	REL	0,$1C,$B,$3B,$D
	REL	1,$14,$19,$18,$1D	;diagonale
zcol23:
	REL	5,$1F,$B,$42,$21
	dc.w	zcol24-zcol23-10
	REL	0,$1F,$B,$42,$D
	REL	0,$29,$B,$2E,$E
	REL	0,$3B,$B,$42,$F
zcol24:
	REL	5,$42,$B,$63,$21
	dc.w	zcol25-zcol24-10
	REL	0,$42,$B,$46,$11
	REL	0,$42,$14,$47,$21
	REL	0,$42,$1A,$4A,$21
	REL	0,$42,$B,$63,$C
	REL	0,$4B,$B,$51,$D		;$52
	REL	0,$5A,$B,$63,$D		;$59
	REL	0,$60,$B,$63,$E
	REL	0,$62,$B,$63,$10
zcol25:
	REL	5,$63,$B,$71,$21
	dc.w	zcol26-zcol25-10
	REL	0,$63,$B,$65,$16
	REL	0,$67,$18,$71,$21
	REL	0,$6C,$17,$71,$21
	REL	0,$65,$B,$66,$E
	REL	0,$6F,$B,$71,$D
	REL	0,$70,$B,$85,$10
	REL	0,$63,$B,$71,$C

zcol26:
	REL	5,$71,$B,$87,$21
	dc.w	zcol27-zcol26-10

	REL	0,$70,$B,$85,$10
	REL	0,$71,$13,$7F,$1A
	REL	0,$71,$13,$7D,$1C	;BUG $1F
	REL	0,$71,$13,$7B,$21
	REL	0,$83,$B,$85,$1D
	REL	0,$83,$B,$87,$1B
zcol27:
	REL	0,$87,$B,$9F,$18	;BUG $21
	REL	8,$1C,$B,$73,$1A	;eau
	REL	8,$72,$B,$85,$18
	dc.w	-1

;----------------------------------------------------
;y	set	$58
REL3:	MACRO
	dc.w	?1*4,?2*16,[$58-?5]*16,?4*16,[$58-?3]*16
	ENDM

relief3:
zcol38:
	REL3	5,$8c,0,$9A,$B
	dc.w	zcol31-zcol38-10
	REL3	0,$7B,0,$9B,1		;sol
	REL3	0,$7B,$A,$9B,$B		;plafond
	REL3	0,$9A,0,$FF,$C		;limite droite
	DC.W	-1
zcol31:
	REL3	5,0,$4D,$38,$58		;ZONE 1
	dc.w	zcol32-zcol31-10
	REL3	0,0,$37,$E,$58		;empeche de tomber
	REL3	0,$e,$4d,$14,$50
	REL3	4,$14,$4d,$23,$4e	;mort
	REL3	0,$19,$50,$20,$52
	REL3	0,$23,$4d,$34,$50
	REL3	1,$2e,$50,$33,$55	;diagonale
	REL3	0,$33,$4C,$35,$55
	REL3	0,$37,$42,$38,$58
zcol32:
	REL3	5,$2a,$2c,$38,$4c	;zone2
	dc.w	zcol33-zcol32-10
	REL3	0,$2A,$32,$2B,$4E
	REL3	0,$37,$2C,$38,$4E
	REL3	0,$2A,$4C,$35,$4E
	REL3	0,$2A,$41,$2D,$43
	REL3	0,$2F,$41,$38,$43
	REL3	0,$34,$40,$38,$42
	REL3	0,$2F,$3B,$38,$3D
	REL3	0,$31,$3A,$38,$3B
	REL3	0,$34,$39,$35,$3A	;crete de lave
	REL3	0,$2A,$31,$2D,$38
	REL3	9,$2D,$30,$35,$38	;pente droite
	REL3	0,$31,$2F,$35,$30
	REL3	0,$2A,$2C,$38,$2D
zcol33:
	REL3	5,0,$2C,$2A,$37
	dc.w	zcol34-zcol33-10

	REL3	0,5,$2C,$38,$2D
	REL3	0,$17,$35,$2A,$37
	REL3	0,$1A,$32,$1D,$34
	REL3	9,8,$2D,$E,$33
	REL3	0,0,$B,1,$37
	REL3	0,0,$31,3,$33
	REL3	6,3,$2B,4,$33		;liane verticale milieu
	REL3	0,6,$31,8,$33
zcol34:
	REL3	5,0,$B,$E,$2C
	dc.w	zcol35-zcol34-10

	REL3	0,0,$B,1,$37
	REL3	0,5,$2B,$E,$2C
	REL3	0,6,$2A,$E,$2B
	REL3	0,$C,$29,$E,$2B
	REL3	0,$D,$16,$E,$2C
	REL3	0,0,$26,3,$27
	REL3	0,7,$26,9,$27
	REL3	4,1,$23,8,$25		;lave (mort)
	REL3	0,8,$23,9,$27
	REL3	0,0,$21,$A,$24
	REL3	6,$A,$1F,$B,$24		;liane verticale milieu
	REL3	0,0,$1F,8,$20
	REL3	0,0,$20,9,$21
	REL3	0,3,$1A,6,$1B
	REL3	0,$B,$1A,$E,$1B
	REL3	0,3,$16,4,$1B
	REL3	4,4,$17,$D,$19		;lave (mort)
	REL3	0,3,$14,$E,$16
	REL3	0,0,$B,$C,$C
	REL3	0,$C,$B,$F,$D

zcol35:
	REL3	5,$E,0,$1C,$17
	dc.w	zcol36-zcol35-10

	REL3	0,$E,0,$F,$D
	REL3	0,$E,$15,$1C,$17
	REL3	0,$12,$10,$16,$12
	REL3	0,$1A,$B,$1C,$17
	REL3	0,$18,$A,$1C,$D
	REL3	1,$11,6,$18,$D		;diagonale bas-droite
	REL3	4,$f,0,$26,1		;lave (mort)
	REL3	0,$11,5,$16,6
	REL3	0,$15,6,$19,8
	REL3	0,$18,8,$1C,$B
zcol36:
	REL3	5,$1C,0,$FF,$B		;infini pour la fin
	dc.w	zcol37-zcol36-10

	REL3	4,$F,0,$26,1		;lave (mort)
	REL3	0,$1C,$A,$9A,$B
	REL3	0,$26,0,$35,2
	REL3	1,$28,2,$2C,6		;diagonale bas-droite
	REL3	9,$2F,2,$33,6		;diagonale bas-gauche
	REL3	0,$2C,0,$2F,6
	REL3	4,$35,0,$3B,1		;lave (mort)
	REL3	0,$3B,0,$43,2
	REL3	0,$3D,0,$43,4
	REL3	0,$3F,0,$43,6
	REL3	4,$43,0,$45,1		;lave
	REL3	0,$45,0,$52,2
	REL3	0,$4A,0,$4D,5
	REL3	0,$4D,0,$4F,6
	REL3	4,$52,0,$64,1
	REL3	0,$64,0,$6D,2
	REL3	1,$68,2,$6A,4		;diagonale bas-droite
	REL3	0,$6A,0,$6D,4
	REL3	0,$6C,0,$9A,1
	REL3	0,$7A,0,$7C,4
zcol37:
	dc.w	-1

;------------------------------------------------------
RELIEF4:
;y	set	$21
REL4:	MACRO
	dc.w	?1*4,?2*16,[$21-?5]*16,?4*16,[$21-?3]*16
	ENDM

zcol41:
	REL4	5,0,0,$2A,$B
	dc.w	zcol42-zcol41-10

	REL4	0,0,0,$A,3
	REL4	0,0,0,$F,1
	REL4	4,$F,0,$1E,1	;mort
	REL4	0,$1E,0,$2B,1
	REL4	0,$22,0,$2B,2
	REL4	0,$24,0,$2B,4
	REL4	0,$26,0,$2B,6		;bug
	REL4	0,$28,0,$2B,$17

	REL4	0,0,9,8,$B
	REL4	0,0,$A,$1C,$B
	REL4	0,$14,9,$16,$B
	REL4	0,$1A,9,$1D,$B
	REL4	0,$1D,7,$21,$A
	REL4	0,$20,6,$24,8
zcol42:
	REL4	5,$1C,$B,$2A,$21
	dc.w	zcol43-zcol42-10

	REL4	0,$1C,$B,$1D,$21
	REL4	0,$28,$B,$2B,$17
	REL4	0,$28,$1A,$2B,$21
	REL4	0,$25,$B,$2B,$D
	REL4	0,$1D,$11,$22,$13
	REL4	0,$1F,$16,$24,$19
	REL4	0,$23,$15,$2B,$17
	REL4	0,$1C,$1F,$20,$21
	REL4	0,$1C,$20,$2B,$21
	REL4	0,$24,$1F,$2B,$21
zcol43:
	REL4	5,$2A,$16,$54,$21
	dc.w	zcol44-zcol43-10

	REL4	0,$2A,$16,$50,$17
	REL4	0,$28,$1A,$2B,$21
	REL4	0,$2A,$20,$54,$21

	REL4	0,$2E,$16,$2F,$1A
	REL4	0,$2E,$19,$31,$1A
	REL4	1,$34,$17,$38,$1B	;pente bas-droite
	REL4	0,$38,$19,$3A,$1B
	REL4	0,$45,$16,$4D,$18
	REL4	0,$47,$16,$4D,$19

;	REL4	0,$49,$16,$4D,$1A
	REL4	0,$49,$19,$50,$1A
	REL4	1,$49,$1A,$4A,$1B	;pente bas-droite
	REL4	0,$4A,$19,$50,$1B
	REL4	0,$4E,$19,$50,$1E
	REL4	0,$52,6,$54,$21
zcol44:
	REL4	5,$2A,$B,$54,$16
	dc.w	zcol45-zcol44-10
	REL4	0,$52,6,$54,$16
	REL4	0,$4E,$13,$50,$17
	REL4	0,$35,$B,$53,$C
	REL4	0,$28,$A,$2B,$16
	REL4	0,$2D,$A,$53,$B
	REL4	9,$35,$C,$3C,$13
	REL4	0,$2D,$12,$35,$13
	REL4	0,$30,$11,$35,$12
	REL4	0,$32,$F,$35,$12
zcol45:
	REL4	5,$2A,0,$62,$B
	dc.w	zcol46-zcol45-10

	REL4	0,$29,0,$2b,$b
	REL4	0,$29,0,$55,2
	REL4	0,$2D,9,$55,$C
	REL4	0,$51,0,$55,3
	REL4	0,$54,0,$55,4
	REL4	0,$4C,8,$55,$C
	REL4	0,$50,8,$55,$C
	REL4	0,$52,7,$55,$C		;bug
	REL4	0,$52,7,$59,8		;bug
	REL4	0,$55,0,$62,1
	REL4	0,$60,0,$62,$D
	REL4	0,$5D,4,$62,$D

zcol46:
	REL4	5,$54,$B,$70,$16
	dc.w	zcol47-zcol46-10
	REL4	0,$52,7,$55,$16
	REL4	0,$58,$C,$5A,$13
	REL4	0,$58,$C,$70,$D		;bug

	REL4	0,$5D,$A,$70,$D
	REL4	0,$53,$16,$71,$20
	REL4	9,$5A,$D,$60,$13	;pente bas-gauche
	REL4	0,$70,$A,$72,$21

zcol47:
	REL4	8,$29,$0,$60,$a
	REL4	8,$54,$7,$5e,$c
	REL4	8,$53,$c,$59,$11
	DC.W	-1

;------------------------------------------------------
RELIEF5:
;y	set	$21
REL5:	MACRO
	dc.w	?1*4,?2*16,[$4d-?5]*16,?4*16,[$4d-?3]*16
	ENDM

zcol51:
	REL5	5,0,0,$A8,$C
	dc.w	zcol52-zcol51-10

	REL5	0,0,0,9,2
	REL5	4,9,0,$E,1	;mort
	REL5	0,$E,0,$3E,2
	REL5	4,$3E,0,$42,1	;MORT
	REL5	0,$42,0,$4D,2
	REL5	4,$4D,0,$51,1	;MORT
	REL5	0,$51,0,$80,2
	REL5	4,$80,0,$8C,1	;MORT
	REL5	0,$8C,0,$A8,2
	REL5	0,$A6,0,$A8,$C
	REL5	0,$93,$A,$9B,$B
	REL5	0,$9A,$A,$9B,$16
	REL5	0,$A0,$A,$A2,$E

	REL5	0,$A0,$A,$B6,$C		;BUG

zcol52:
	REL5	5,$9A,$C,$B6,$16

	dc.w	zcol53-zcol52-10
	REL5	0,$9A,$D,$9D,$E

	REL5	0,$A0,$A,$A2,$E
	REL5	0,$A0,$A,$B6,$C		;BUG

	REL5	0,$9A,$A,$9B,$16
	REL5	0,$9A,$14,$B2,$16	;BUG

	REL5	0,$A4,$0F,$A6,$16	;BUG
	REL5	0,$A8,$0F,$AA,$16	;BUG
	REL5	0,$AC,$0F,$AE,$16	;BUG
	REL5	0,$B0,$0F,$B2,$16	;BUG

	REL5	0,$B4,$B,$B6,$F
	REL5	0,$B5,$B,$B6,$45
	REL5	7,$B4,$14,$B5,$1E	;liane verticale droite
zcol53:
	REL5	5,$A8,$16,$B6,$4D
	dc.w	zcol54-zcol53-10
	REL5	0,$A8,$14,$B2,$17
	REL5	0,$A8,$14,$AA,$1E
	REL5	0,$A9,$1D,$AC,$1E
	REL5	0,$A8,$17,$A9,$4D
	REL5	0,$B5,$C,$B6,$45
	REL5	7,$B4,$14,$B5,$1E	;liane verticale droite
	REL5	3,$AC,$1D,$B5,$1E	;liane horizontale
	REL5	0,$AB,$20,$AD,$22
	REL5	0,$AE,$23,$B0,$25
	REL5	0,$B2,$25,$B6,$26
	REL5	0,$A8,$29,$B2,$2B
	REL5	2,$B2,$29,$B3,$30	;liane vert gauche
	REL5	3,$B2,$2F,$B3,$30	;liane horizontale
	REL5	0,$A8,$29,$AA,$31
	REL5	0,$B0,$29,$B2,$30
	REL5	0,$AC,$2C,$AE,$2E
	REL5	0,$AD,$35,$B1,$36
	REL5	0,$B3,$37,$B5,$38
	REL5	0,$A8,$3A,$AD,$3C
	REL5	6,$B2,$3B,$B3,$41	;liane milieu
	REL5	3,$B2,$40,$B3,$41	;liane horizontale
	REL5	0,$AD,$3E,$B1,$3F
	REL5	0,$B3,$3F,$B6,$41
	REL5	0,$B0,$43,$B9,$45
	REL5	0,$A8,$46,$AB,$48
	REL5	0,$AD,$48,$AF,$49
	REL5	0,$B0,$47,$B2,$48
	REL5	0,$A9,$4B,$AB,$4D
	REL5	0,$B2,$4B,$B4,$4D
	REL5	0,$AB,$4C,$B2,$4D
zcol54:
	REL5	5,$B5,$42,$E0,$4D
	dc.w	zcol55-zcol54-10
	REL5	0,$B5,$44,$B9,$45
	REL5	4,$B7,$42,$BF,$43	;mort
	REL5	0,$BF,$42,$C5,$45
	REL5	0,$C3,$42,$C5,$48
	REL5	4,$C5,$42,$D1,$43	;mort
	REL5	0,$D1,$42,$FF,$45
	REL5	0,$E0,$42,$E2,$50
zcol55:
	DC.W	-1

;=====================================================
DEBUG:
	moveq #0,d0
move zone,d0
	bsr decoder
	
	move.l logique,a4		;bitplane 
	lea buffer,a5

	move #8-1,d7			;nb de caractere a afficher
loop:
	moveq #0,d1
	lea caractere(pc),a6		;generateur
	moveq #0,d1
	move.b (a5)+,d1			;prendre caractere 
	add d1,a6

	move.b 0*16(a6),0(a4)
	move.b 1*16(a6),30(a4)
	move.b 2*16(a6),60(a4)
	move.b 3*16(a6),90(a4)
	move.b 4*16(a6),120(a4)
	move.b 5*16(a6),150(a4)
	move.b 6*16(a6),180(a4)

	move.b 0*16(a6),5280+0(a4)
	move.b 1*16(a6),5280+30(a4)
	move.b 2*16(a6),5280+60(a4)
	move.b 3*16(a6),5280+90(a4)
	move.b 4*16(a6),5280+120(a4)
	move.b 5*16(a6),5280+150(a4)
	move.b 6*16(a6),5280+180(a4)

	move.b 0*16(a6),5280*2+0(a4)
	move.b 1*16(a6),5280*2+30(a4)
	move.b 2*16(a6),5280*2+60(a4)
	move.b 3*16(a6),5280*2+90(a4)
	move.b 4*16(a6),5280*2+120(a4)
	move.b 5*16(a6),5280*2+150(a4)
	move.b 6*16(a6),5280*2+180(a4)

	move.b 0*16(a6),5280*3+0(a4)
	move.b 1*16(a6),5280*3+30(a4)
	move.b 2*16(a6),5280*3+60(a4)
	move.b 3*16(a6),5280*3+90(a4)
	move.b 4*16(a6),5280*3+120(a4)
	move.b 5*16(a6),5280*3+150(a4)
	move.b 6*16(a6),5280*3+180(a4)

	move.b 0*16(a6),5280*4+0(a4)
	move.b 1*16(a6),5280*4+30(a4)
	move.b 2*16(a6),5280*4+60(a4)
	move.b 3*16(a6),5280*4+90(a4)
	move.b 4*16(a6),5280*4+120(a4)
	move.b 5*16(a6),5280*4+150(a4)
	move.b 6*16(a6),5280*4+180(a4)

	addq #1,a4			;colone suivante
	dbf d7,loop
	rts

decoder:
;d0.l en entree
	moveq #8-1,d7
	lea buffer(pc),a6
aloop:
	rol.l #4,d0
	move.l d0,d1
	and.l #$0000000f,d1

	move.b d1,(a6)+
	dbf d7,aloop
	rts
buffer:blk.b 8,0
;---------------
caractere:blk.b 112+7,0		;1carac= 7 octets
	even
>extern "dh1:a-f.map",caractere,3000

fini:




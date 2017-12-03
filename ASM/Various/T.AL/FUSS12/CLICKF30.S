; .F30 files viewer
; T.AL 94

;-----------------------------------------------
;vire NVDI du vecteur \1
;  sauve le gestionnaire nvdi en \2
;        l'adresse du pointeur … modifier en \3
clrnvdi	macro
	move.l \1.w,a0
	move.l #\1,a1		;adresse du pointeur
	move.l a0,\2		;adresse gestionnaire
	move.l a1,\3		;adresse du pointeur

xbra\@	move.l a0,d0
	beq.s notfound\@
	
	cmpi.l #'XBRA',-12(a0)
	bne.s notfound\@
	
	cmpi.l #'NVDI',-8(a0)
	beq.s found\@
	
	lea -4(a0),a1
	move.l -4(a0),a0
	bra.s xbra\@

found\@	move.l a0,\2
	move.l a1,\3
	lea -4(a0),a0
	move.l (a0),(a1)
notfound\@	
	endm

;-----------------------------------------------
	output .ttp
	text
	
	move.l 4(sp),a3		;base page pointer
	move.l $c(a3),d0	;p_tlen
	add.l $14(a3),d0	;+p_dlen
	add.l $1c(a3),d0	;+p_blen
	add.l #256,d0
	
	move.l d0,-(sp)
	pea (a3)
	clr.w -(sp)
	move.w #$4a,-(sp)
	trap #1		;mshrink
	add.w #12,sp

	pea view
	move.w #$26,-(sp)	;supexec view
	trap #14
	addq.w #6,sp
	
	clr.w -(sp)
	trap #1

;----------------------------------------------- 	
view	
savetrap	clrnvdi $b8,oldxbios,oldxbios+4
	clrnvdi $b4,oldbios,oldbios+4
	clrnvdi $84,oldgemdos,oldgemdos+4
	clrnvdi $88,oldgem,oldgem+4
	clrnvdi $70,oldvblq,oldvblq+4

	pea prompt
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp

	lea usage,a0	
	moveq #0,d0
	move.b $80(a3),d0
	beq put_err
	
	clr.b (a3,d0.w)		;null terminated
	
	pea infile
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	pea ($81.w,a3)
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	pea cr
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	clr.w -(sp)
	pea ($81.w,a3)
	move.w #$3d,-(sp)
	trap #1		;fopen
	addq.w #8,sp
	
	lea inerror,a0
	move.w d0,d3		;d3.w: handle
	bmi put_err

	lea $ffff8240.w,a0
	lea stpal,a1
	moveq #15,d0
	
.stpalcpy	move.w (a0)+,(a1)+
	dbf d0,.stpalcpy
	
	lea $ffff9800.w,a0
	lea pal,a1
	move.w #255,d0
	
.fpalcpy	move.l (a0)+,(a1)+
	dbf d0,.fpalcpy
		
	pea mode
	move.l #6,-(sp)
	move.w d3,-(sp)
	move.w #$3f,-(sp)
	trap #1		;fread vmode & size
	add.w #12,sp
	
	move.w mode,d4		;d4.w: vmode
	
	move.w #-1,-(sp)
	move.w #88,-(sp)
	trap #14		;vgetmode
	addq.w #4,sp
	
	move.w d0,oldmode

	move.w #2,-(sp)
	trap #14
	addq.w #2,sp
	move.l d0,oldphysbase
	
	move.w #3,-(sp)
	trap #14
	addq.w #2,sp
	move.l d0,oldlogbase

	move.w d4,-(sp)
	move.w #91,-(sp)
	trap #14		;vgetsize
	addq.w #4,sp

	move.l d0,d6		;d6.l: screen size
	
	addq.l #4,d0
	move.l d0,-(sp)
	move.w #$48,-(sp)
	trap #1		;malloc screen size
	addq.w #6,sp
	
	lea memerror,a0
	tst.l d0
	beq put_err
	
	and.w #~3,d0		;long align screen base
	move.l d0,a4		;a4.l: screen base
		
	move.w d4,-(sp)
	move.w #3,-(sp)
	move.l a4,-(sp)	
	move.l a4,-(sp)
	move.w #5,-(sp)
	trap #14		;setscreen
	add.w #14,sp

	btst #2,d4
	bne.s freadrawdata	;tc

	btst #7,d4		;st?
	beq.s f30mode

	lea $ffff8240.w,a5	;a5.l: palette registers address
	move.w #32,d5		;d5.w: palette size
	bra.s freadpal

f30mode	lea $ffff9800.w,a5
	move.w #1024,d5

freadpal	pea pal
	move.l d5,-(sp)
	move.w d3,-(sp)
	move.w #$3f,-(sp)
	trap #1		;fread colors
	add.w #12,sp

	lea pal,a0
	lsr.w #2,d5
	subq.w #1,d5
	
cpycolors	move.l (a0)+,(a5)+
	dbf d5,cpycolors

freadrawdata	pea (a4)
	move.l d6,-(sp)
	move.w d3,-(sp)
	move.w #$3f,-(sp)
	trap #1		;fread raw data
	add.w #12,sp

	move.w d3,-(sp)
	move.w #$3e,-(sp)
	trap #1		;fclose
	addq.w #4,sp
	
	bsr waitkey
		
	move.w oldmode,-(sp)
	move.w #3,-(sp)
	move.l oldphysbase,-(sp)
	move.l oldlogbase,-(sp)
	move.w #5,-(sp)
	trap #14
	add.w #14,sp
	
	pea (a4)
	move.w #$49,-(sp)
	trap #1		;mfree
	addq.w #6,sp

	lea $ffff8240.w,a0
	lea stpal,a1
	moveq #15,d0
	
.stpalcpy	move.w (a1)+,(a0)+
	dbf d0,.stpalcpy
	
	lea $ffff9800.w,a0
	lea pal,a1
	move.w #255,d0
	
.fpalcpy	move.l (a1)+,(a0)+
	dbf d0,.fpalcpy

restoretrap	move.l oldxbios+4,a0
	move.l oldxbios,(a0)
	move.l oldbios+4,a0
	move.l oldbios,(a0)
	move.l oldgem+4,a0
	move.l oldgem,(a0)
	move.l oldgemdos+4,a0
	move.l oldgemdos,(a0)
	move.l oldvblq+4,a0
	move.l oldvblq,(a0)
	rts
	
put_err	pea (a0)
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	bsr waitkey
	bra.s restoretrap

;-----------------------------------------------
waitkey	move.w #1,-(sp)
	trap #1
	addq.w #2,sp
	
	move.w #$b,-(sp)
	trap #1		;cconis
	addq.w #2,sp
	
	tst.w d0
	bne.s waitkey
	
	rts

;-----------------------------------------------
	data

prompt	dc.b $a,$d,'.F30 image file Viewer'
	dc.b $a,$d,'T.AL 94',$a,$d,0

usage	dc.b $a,$d,'usage: clickf30 imagefile.f30',$a,$d,0

infile	dc.b $a,$d,'  input file  : ',0
inerror	dc.b $a,$d,'FILE NOT FOUND',7,$a,$d,0

memerror	dc.b $a,$d,'NOT ENOUGH MEMORY',7,$a,$d,0
	
cr	dc.b $a,$d,0

;-----------------------------------------------
	bss

oldgemdos	ds.l 2
oldgem	ds.l 2
oldbios	ds.l 2
oldxbios	ds.l 2
oldvblq	ds.l 2

oldmode	ds.w 1
oldphysbase	ds.l 1
oldlogbase	ds.l 1

mode	ds.b 6
stpal	ds.w 16
pal	ds.b 1024

	end
	
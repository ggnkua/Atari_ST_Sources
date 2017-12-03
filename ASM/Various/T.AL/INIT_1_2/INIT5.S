
; init030.s
; T.AL Septembre 95
; Version +++
;tab 16

; supporte nvdi
; cartes graphiques
; resolutions etendues (falcon screen ...)
; erreur bus
; init programme (definir NOT_A_DEMO)
; init demo
; double buffering

	text
	
;-----------------------------------------------
; sauve le registre de controle et de donnees d'un timer
;
; \1: timer control register
; \2: save comtrol register
; \3: timer data register
; \4: save data register
; \5: decalage pour l'isolation du control register des timers c et d.
save_timer	macro 
	move.b \1,d0
	move.b d0,\2		;save control register

	ifeq NARG-5		;timer c ou d
	ifne \5
	lsr.b #\5,d0		;timer d
	endc
	andi.b #7,d0		;timer c ou d
	endc
	
	beq.s .next\@		;timer stoppe, suivant
	
	ifeq NARG-4		;timer a ou b
	cmpi.b #8,d0		;event count?
	bne.s .wtimer\@		;non, recupere data register

	move.b \3,d0		;data register = 0
	bra.s .next\@
	endc
		
.wtimer\@	move.b \3,d0		;data register
	cmpi.b #1,d0		;fin de cycle?
	bne.s .wtimer\@
	
.rtimer\@	move.b \3,d0
	cmp.b #1,d0
	beq.s .rtimer\@
	
.next\@	move.b d0,\4		;sauve compteur timer
	endm
	
;-----------------------------------------------
;recupere l'appel en rom du trap correspondant au vecteur \1
;en parcourant la chaine XBRA (si elle existe)
;sauve l'ancien vecteur en \2

;dis monsieur atari, pourquoi le gemdos a une id xbra _DOS et pas le xbios?
;et pas le bios?
save_trap	macro
	move.l \1.w,\2
	move.l \1,a0
	move.l a0,a1

xbra\@	move.l a0,d0
	beq.s svtrap\@
	
	cmpi.l #'XBRA',-12(a0)
	bne.s svtrap\@
		
nextxbra\@	move.l a0,a1
	move.l -4(a0),a0
	bra.s xbra\@
	
svtrap\@	bne.s endxbra\@
	
	move.l a1,a0
endxbra\@	move.l a0,\1
	endm
	
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
; attends que les routines vbl systeme soient executees
wait_sys	macro
	move.w sr,-(sp)
	andi.w #$fbff,sr

wait_sys\@	move.l $466.w,d0
	cmp.l $466.w,d0
	beq.s wait_sys\@
	
	move.w (sp)+,sr
	endm
	
;-----------------------------------------------
save	movem.l d0-a6,-(sp)
	move.w sr,oldsr		; sauve le sr

	movec vbr,d0
	move.l d0,oldvbr	;vbr
	moveq.l #0,d0
	movec d0,vbr 

	movec cacr,d0
	move.l d0,oldcacr	;cacr
	move.l #$3111,d0
	movec d0,cacr
	
	move.b $ffff8007.w,d0
	move.b d0,oldconf
	or.b #%101,d0
	move.b d0,$ffff8007.w	;16Mhz, 030, blitter
	
savetrap	ifd NOT_A_DEMO
	clrnvdi $b8,oldxbios,oldxbios+4
	else
	save_trap $b8,oldxbios
	endc
	
	clrnvdi $b4,oldbios,oldbios+4
	clrnvdi $84,oldgemdos,oldgemdos+4
	clrnvdi $88,oldgem,oldgem+4

	ifd NOT_A_DEMO
	clrnvdi $70,oldvblq,oldvblq+4
	endc
	
	lea $ffff8240.w,a0
	lea oldstpal,a1
	move.w #15,d0
savestpal	move.w (a0)+,(a1)+
	dbf d0,savestpal

	lea $ffff9800.w,a0
	lea oldfpal,a1
	move.w #255,d0
savefpal	move.l (a0)+,(a1)+
	dbf d0,savefpal

savevidel	move.w #2,-(sp)
	trap #14		;physbase
	addq.w #2,sp
	move.l d0,oldphysbase

	move.w #3,-(sp)
	trap #14		;logbase
	addq.w #2,sp
	move.l d0,oldlogbase
	
	move.w #-1,-(sp)
	move.w #88,-(sp)
	trap #14		;vsetmode(-1)
	addq.w #4,sp
	move.w d0,oldmode

initvidel	move.w #89,-(sp)
	trap #14
	addq.w #2,sp		;mon_type
	
	lea vmodes,a0
	move.w (a0,d0.w*2),d6	;video mode
	beq nomode
	
	move.b $ffff820a.w,d0	;recupere pal/ntsc
	and.w #2,d0
	lsl.w #4,d0
	or.w d0,d6		;fixe le bit pal
	
	lea scr+4,a0		;adresse du buffer
	move.l a0,d0	
	and.l #~3,d0		;d0.l: adresse multiple de 4
	move.l d0,screenbase	;on sauve

	ifnd NOT_A_DEMO
	lea scr2+4,a0		;adresse du buffer
	move.l a0,d1	
	and.l #~3,d1		;d1.l: adresse multiple de 4
	move.l d1,screenbase2	;on sauve
	endc
		
	move.w d6,-(sp)		;mode
	move.w #3,-(sp)
	move.l d0,-(sp)		;buffer ecran
	
	ifd NOT_A_DEMO
	move.l d0,-(sp)		;idem
	else
	move.l d1,-(sp)		;pas idem
	endc

	move.w #5,-(sp)	
	trap #14		;setscreen, installe le mode video de la demo
	add.w #14,sp

	wait_sys		;attente

savevec	ifnd NOT_A_DEMO
	move.w #$2700,sr	;on bloque toutes les it
	move.l 8.w,oldberr	;vecteur erreur bus

	move.l $70.w,oldvbl	;vecteur vbl
	move.l $134.w,oldtima	;vecteurs des timers
	move.l $120.w,oldtimb 
	move.l $114.w,oldtimc
	move.l $110.w,oldtimd	
		
savemfp	lea $fffffa00.w,a0	;registres du mfp
	lea mfpbuf,a1	
	move.b 7(a0),(a1)+	;iera
	move.b 9(a0),(a1)+	;ierb
	move.b $b(a0),(a1)+
	move.b $d(a0),(a1)+
	move.b $f(a0),(a1)+
	move.b $11(a0),(a1)+
	move.b $13(a0),(a1)+
	move.b $15(a0),(a1)+
	move.b $17(a0),(a1)+	;vr
	
	save_timer $19(a0),(a1)+,$1f(a0),(a1)+	;timer a
	save_timer $1b(a0),(a1)+,$21(a0),(a1)+	;timer b
	save_timer $1d(a0),(a1)+,$23(a0),(a1)+,0	;timer c
	save_timer $1d(a0),(a1)+,$25(a0),(a1)+,4	;timer d

	;move.w #$2300,sr
	endc

	movem.l (sp)+,d0-a6
	rts
	
;-----------------------------------------------
init	movem.l d0-a6,-(sp)	;nouveaux vecteurs

initvec	ifd BUS_ERROR
	move.l #exrestore,8.w	;erreur bus
	endc

	ifnd NOT_A_DEMO
	move.w #$2700,sr

	ifd vbl
	move.l #vbl,$70.w	;vbl
	else
	move.l #nullit,$70.w
	endc
	
maska	set 0
maskb	set 0

	ifd tima		;timer a
	move.l #tima,$134.w
maska	set maska or %00100000
	else
	move.l #nullit,$134.w
	endc

	ifd timb		;timer b
	move.l #timb,$120.w
maska	set maska or %00000001
	else
	move.l #nullit,$120.w
	endc

	ifd timc		;timer c
	move.l #timv,$114.w
maskb	set maskb or %00100000
	else
	move.l #nullit,$114.w
	endc

	ifd timd		;timer d
maskb	set maskb or %00010000
	move.l #timd,$110.w
	else
	move.l #nullit,$110.w
	endc
	
initmfp	lea $fffffa00.w,a0
	move.b #maska,7(a0)	;bloque les it du mfp
	move.b #maskb,9(a0)
	clr.b $b(a0)
	clr.b $d(a0)
	clr.b $f(a0)
	clr.b $11(a0)
	move.b #maska,$13(a0)
	move.b #maskb,$15(a0)
	bclr #3,$17(a0)		;automatic end

	endc ;NOT_A_DEMO
		
	move.w #$2300,sr	;debut de la demo
	movem.l (sp)+,d0-a6
	rts

;-----------------------------------------------
waitspace	move.l d0,-(sp)

	cmp.b #$39,$fffffc02.w	;attente espace
	bne.s waitspace

.clearkey	btst #0,$fffffc00.w	;vide le buffer clavier
	beq.s .nomorekey

	move.b $fffffc02.w,d0
	bra.s .clearkey

.nomorekey	move.l (sp)+,d0
	rts
	
;-----------------------------------------------
;reprise lors d'une erreur bus...
exrestore	bsr restore		;restore le systeme

	pea berr(pc)		;coucou ...
	move.w #9,-(sp)
	trap #1
	add.w #6,sp

	bsr waitspace		;attente clavier
	
	clr.w -(sp)		;cassos violent
	trap #1
	
;-----------------------------------------------
berr	dc.b 'Bus Error',$d,$a
	dc.b 'press the spacebar ...',$a,$d,0

;-----------------------------------------------
restore	movem.l d0-a6,-(sp)

clearkey	btst #0,$fffffc00.w	;vide le buffer clavier
	beq.s nomorekey
	move.b $fffffc02.w,d0
	bra.s clearkey
	
	move.w #$2700,sr

nomorekey	ifnd NOT_A_DEMO

restoremfp	lea mfpbuf,a0		;restore le mfp
	lea $fffffa00.w,a1
	move.b (a0)+,7(a1)	;iera
	move.b (a0)+,9(a1)	;ierb
	move.b (a0)+,$b(a1)
	move.b (a0)+,$d(a1)
	move.b (a0)+,$f(a1)
	move.b (a0)+,$11(a1)
	move.b (a0)+,$13(a1)
	move.b (a0)+,$15(a1)
	move.b (a0)+,$17(a1)	;vr

	move.b (a0)+,$19(a1)	;timer a, control register
	move.b (a0)+,$1f(a1)	;timer a, data register
	move.b (a0)+,$1b(a1)	;timer b, cr
	move.b (a0)+,$21(a1)	;timer b, dr
	move.b (a0)+,$1d(a1)	;timer c, cr
	move.b (a0)+,$23(a1)	;timer c, dr
	move.b (a0)+,$1d(a1)	;timer d, cr
	move.b (a0)+,$25(a1)	;timer d, dr
	endc ;NOT_A_DEMO
			
restorevec	ifnd NOT_A_DEMO
	move.l oldberr,8.w	;erreur bus 

	move.l oldvbl,$70.w	;ancien vecteurs, vbl
	move.l oldtima,$134.w	;timer a
	move.l oldtimb,$120.w	;timer b
	move.l oldtimc,$114.w	;timer c
	move.l oldtimd,$110.w	;timer d
	endc
	
	move.l oldvbr,d0
	movec d0,vbr		;vbr
	move.l oldcacr,d0
	movec d0,cacr		;cacr
	move.b oldconf,$ffff8007.w	;config falcon

	ifnd NOT_A_DEMO
	move.l oldxbios,$b8.w	;si demo, reinstaller le vecteur normal
	clrnvdi $b8,oldxbios,oldxbios+4	;et virer nvdi pour repasser dans la rez de boot
	endc
	
	move.w #$2300,sr	;appel xbios, ipl 3
	wait_sys		;attente 
		
	move.w oldmode,-(sp)
	move.w #3,-(sp)
	move.l oldphysbase,-(sp)
	move.l oldlogbase,-(sp)
	move.w #5,-(sp)
	trap #14		;setscreen, restitue le mode video
	add.w #14,sp

	lea $ffff8240.w,a1
	lea oldstpal,a0
	move.w #15,d0
restpal	move.w (a0)+,(a1)+
	dbf d0,restpal

	lea $ffff9800.w,a1
	lea oldfpal,a0
	move.w #255,d0
refpal	move.l (a0)+,(a1)+
	dbf d0,refpal
	
restoretrap	move.l oldxbios+4,a0
	move.l oldxbios,(a0)
	move.l oldbios+4,a0
	move.l oldbios,(a0)
	move.l oldgem+4,a0
	move.l oldgem,(a0)
	move.l oldgemdos+4,a0
	move.l oldgemdos,(a0)

	ifd NOT_A_DEMO
	move.l oldvblq+4,a0
	move.l oldvblq,(a0)
	endc		

	;move.w oldsr,sr
	movem.l (sp)+,d0-a6
	rts

;-----------------------------------------------
nomode	pea sorry
	move.w #9,-(sp)
	trap #1
	addq.w #6,sp
	
	move.w #1,-(sp)
	trap #1
	addq.w #2+4,sp		;+4: rts -> supexec

	rts
		
;-----------------------------------------------
nullit	rte

;-----------------------------------------------
swapscr	movem.l d0-d1,-(sp)

	move.l screenbase,d0
	move.l screenbase2,d1
	move.l d1,screenbase
	move.l d0,screenbase2	;permute les ecrans

	lsl.l #8,d1
	rol.l #8,d1
	move.b d1,$ffff8201.w
	rol.l #8,d1
	move.b d1,$ffff8203.w
	rol.l #8,d1
	move.b d1,$ffff820d.w
	
	movem.l (sp)+,d0-d1
	rts

swapscreen	bsr swapscr
	
	move.l d0,-(sp)
	
	move.w newvbl,d0
.waitvbl	cmp.w newvbl,d0
	beq.s .waitvbl		;attente effective
	
	clr.w newvbl
	move.l (sp)+,d0
	rts
	
;-----------------------------------------------
vblswap	add.w #1,newvbl
	rte
		
;-----------------------------------------------
	data

sorry	dc.b $1b,'E',$a,$d
	dc.b 'Sorry, but nothing can run on your SM124?!',$a,$d
	dc.b 'Connect your TV and enjoy ...',0

;-----------------------------------------------
	bss

mfpbuf	ds.b 32

oldsr	ds.w 1
oldvbr	ds.l 1
oldcacr	ds.l 1
oldconf	ds.w 1
oldberr	ds.l 1
oldvbl	ds.l 1

oldtima	ds.l 1
oldtimb	ds.l 1
oldtimc	ds.l 1
oldtimd	ds.l 1

oldgemdos	ds.l 2
oldgem	ds.l 2
oldbios	ds.l 2
oldxbios	ds.l 2

	ifd NOT_A_DEMO
oldvblq	ds.l 2
	endc

oldphysbase	ds.l 1
oldlogbase	ds.l 1
oldmode	ds.w 1
oldstpal	ds.w 16
oldfpal	ds.l 256

newvbl	ds.w 1
screenbase 	ds.l 1
screenbase2 	ds.l 1
scr	ds.w 320*240+2

	ifnd NOT_A_DEMO
scr2	ds.w 320*240+2
	endc

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*                            FalconScreen 2.0á                            *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*                                                                         *
*      (C)oderight 1993 by NulloS//DNT-Crew (V1.0 : Markus Gutschke)      *
*                                                                         *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷Vite fait sur le gaz, pour le DNT-Paper 6*


	include	tos_030.s
	include	hard_sys.s

stacksize	equ	1024	; Taille de la pile
ID	equ	'äFSC'	; Identificateur

	bra.w	start
_magic	dc.l	ID
_n	dc.w	-1
_type	dc.w	-1
_width	ds.w	1
_height	ds.w	1
_frq	ds.w	1
_planes	ds.w	1

_Horiz	ds.w	6
_Verti	ds.w	6
_Wide	ds.w	1
_Wrap	ds.w	1
_Mode	ds.w	1
_CO	ds.w	1
_SpShift	ds.w	1
_Shift	ds.w	1

_mask	ds.w	1
_value	ds.w	1
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
doold	movem.l	(sp)+,d0-d2/a0-a2	;
novdi	jmp	([vdivec.w,pc])	;
	dc.l	'XBRA'		;
	dc.l	ID		;
vdivec	ds.l	1		;
vdihdl	cmpi.w	#115,d0		;Appel VDI ?
	bne.s	novdi		;
	movem.l	d0-d2/a0-a2,-(sp)	;
	move.l	d1,a0		;
	move.l	(a0),a1		;
	cmpi.w	#1,(a1)		;v_opnwk du systŠme, en fin
	bne.s	doold		;de boot ?
	move.l	4(a0),a1		;
	cmpi.w	#11,(a1)		;Heu, c'est bien un ‚cran ?
	bhs.s	doold		;
	clr.w	-(sp)		;
	pea	vcont(pc)		;
	move.w	sr,-(sp)		;Ex‚cute l'appel..
	jmp	([vdivec.w,pc])	;
vcont	move.l	#$58ffff,-(sp)	;..mais v‚rifie la r‚solution.
	trap	#$e		;
	addq.l	#4,sp		;
	and.w	_mask(pc),d0	;
	cmp.w	_value(pc),d0	;
	bne.s	illres		;
	movea.l	([4.w,sp],$c.w),a1	;Si c'est la notre, alors on
	move.w	_width(pc),d0	;adapte certaines variables
	subq	#1,d0		;… notre sauce.
	move.w	d0,(a1)		;
	move.w	_height(pc),d0	;
	subq	#1,d0		;
	move.w	d0,2(a1)		;
	moveq	#1,d0		;
	move.w	_planes(pc),d1	;
	cmpi.w	#8,d1		;
	bls.s	*+4		;
	moveq	#8,d1		;
	lsl.w	d1,d0		;
	move.w	d0,26(a1)		;
	moveq	#1,d0		;Par s‚curit‚, met le Videl
	bsr	init		;dans le bon sens.
illres	movem.l	(sp)+,d0-d2/a0-a2	;
	rte			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	dc.l	'XBRA'		;
	dc.l	ID		;
xbvec	ds.l	1		;
xbhdl	move.l	usp,a0		;
	btst.b	#5,(sp)		;Pas de test de stackframe: des
	beq.s	xbstk		;Falcon avec 68000, ‡a ne court
	lea	8(sp),a0		;pas les rues !...
xbstk	move.w	(a0)+,d0		;
	cmpi.w	#5,d0		;Setscreen ?
	bne.s	nosetsc		;
	cmpi.w	#3,8(a0)		;R‚solution '‚tendue'
	bne.s	nosetsc		;
	move.w	10(a0),d1		;
	and.w	_mask(pc),d1	;
	cmp.w	_value(pc),d1	;C'est la notre ?
	bne.s	nosetsc		;
	bsr	setscreen		;Oui, vazymimil
	rte			;

nosetsc	cmpi.w	#$58,d0		; Vsetmode ?
	bne.s	novsmd		;
	move.w	(a0),d1		;
	bmi.s	novsmd		;
	and.w	_mask(pc),d1	;Idem...
	cmp.w	_value(pc),d1	;
	bne.s	novsmd		;
	bsr	vsetmode		;
	rte			;

novsmd	cmpi.w	#$5b,d0		; Vgetsize ?
	bne.s	oldxb		;
	move.l	#$0058ffff,-(sp)	;
	clr.w	-(sp)		;
	pea	.ok(pc)		;
	move.w	sr,-(sp)		;
oldxb	equ	*		;
	jmp	([xbvec.w,pc])	; Hoplaboum
.ok	addq.l	#4,sp		;
	and.w	_mask(pc),d0	;
	cmp.w	_value(pc),d0	;
	bne.s	oldxb		;
	bsr	vgetsize		;
	rte			;

	rsreset
width	rs.w	1
height	rs.w	1
frq	rs.w	1
planes	rs.w	1

Horiz	rs.w	6
Verti	rs.w	6
Wide	rs.w	1
Wrap	rs.w	1
Mode	rs.w	1
CO	rs.w	1
SpShift	rs.w	1
Shift	rs.w	1

mask	rs.w	1
value	rs.w	1

set_size	rs.b	0

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
GetSync	move.w	sr,-(sp)		;
	move.w	#$2300,sr		;Ben oui, on ne va appeler le
	move.l	_frclock.w,d1	;Vsync du systŠme pour si peu.
.gs_wait	cmp.l	_frclock.w,d1	;
	beq.s	.gs_wait		;
	move.w	(sp)+,sr		;
	rts			;
;;;;;;;;;;;
;A0=adresse de sauvegarde des paramŠtres du Videl
SetVidel	movem.l	d0-d2/a0-a3,-(sp)	;
	bsr.s	GetSync		;Synchro VBL (indispensable!)
	lea	VidelOrder(pc),a2	;
	moveq	#5-1,d1		;Laisser ffff8266
.sv_bcl	move.w	(a2)+,a3		;
	move.w	(a2)+,d2		;
	move.w	(a0)+,(a3)+	;
	dbf	d2,*-2		;
	dbf	d1,.sv_bcl		;
	move.w	(a2)+,a3		;R‚cupŠre ffff8266
	clr.w	(a3)		;EFFACER D'ABORD
	move.w	(a0)+,d1		;
	beq.s	.sv_1_2_4		;Vraiment nul ?
.sv_8_16	move.w	d1,(a3)		;Non, alors fixer
	bra.s	.sv_next		;
.sv_1_2_4	move.w	4(a0),d0		;R‚cupŠre le mode vid‚o
	moveq	#7,d1		;
	and.w	d0,d1		;Isole le nb de couleurs
	subq.w	#3,d1		;
	bge.s	.sv_next		;¨BUG?:8266=0 -> nb_coul<256 !!
	addq.w	#2,d1		;
	bgt.s	.sv_4		;
	beq.s	.sv_2		;
.sv_1	move.b	#2,$60-$66(a3)	;Ecran monochrome, ici...
	bra.s	.sv_next		;(mono en VGA/RGB -> 8266<>0)
.sv_2	move.b	#1,$60-$66(a3)	;
	andi.w	#$90,d0		;Si 2 bitplans, alors refixer
	cmpi.w	#$90,d0		;v_Mode, OR 1 si VGA&Comp.STE
	seq	d0		;
	andi.w	#1,d0		;
	or.w	-6(a0),d0		;
	move.w	d0,$c2-$66(a3)	;
	bra.s	.sv_next		;
.sv_4	tst.b	d0		;WARNING: le mode 16 couleurs
	bpl.s	.sv_next		;est totalement chiatique
	clr.b	$60-$66(a3)	;Si Comp.STE, annuler $8260,
	lsr.w	#5,d0		;et refixer v_Mode OR 1 si
	bcc.s	.sv_next		;c'est du VGA.
	ori.w	#1,$c2-$66(a3)	;
	;S‚curit‚: refixer Wide&Wrap, parfois effac‚ (en rgb 1280 p.ex)
.sv_next	move.l	-10(a0),$0e-$66(a3)	;
	move.b	1(a0),-(a3)	;Finalement, le d‚calage,
.sv_end	movem.l	(sp)+,d0-d2/a0-a3	;
	rts			;

VidelOrder
	dc.w	v_HHT,6-1		;6 reg. … partir de ffff8282
	dc.w	v_VFT,6-1		;
	dc.w	v_Wide,2-1		;etc..
	dc.w	v_Mode,1-1		;
	dc.w	v_CO,1-1		;
	dc.w	v_SpShift,1-1	;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
;En D0: -1 = r‚allouer l'‚cran
;        0 = fixer l'adresse ‚cran l'‚cran
;        1 = ne pas toucher l'adresse ‚cran
init	move.w	d0,-(sp)		;
	bsr.s	patchos		;Installe la LineA
	lea	_Horiz(pc),a0	;
	bsr	SetVidel		;et le Videl
	tst.w	(sp)+		;
	bgt.s	.ok		;
	beq.s	.v_ad		;
	bsr.s	realloc		;R‚allocation
	move.l	d0,d1		;
	move.l	d0,d2		;
.v_ad	tst.l	d1		;
	ble.s	.nolog		;
	move.l	d1,_v_bas_ad.w	;Si besoin est, et si leur
.nolog	tst.l	d2		;valeur est correcte, fixe
	ble.s	.ok		;les adresses ‚cran.
	move.b	d2,v_base_l.w	;
	lsr.w	#8,d2		;
	move.l	d2,v_base.w	;
.ok	rts			;

realloc	move.l	a0,-(sp)		;
	bsr.s	vgetsize		;
	move.l	d0,-(sp)		;
	Gemdos	Srealloc		;Le Gemdos va sympathiquement
	move.l	(sp)+,a0		;adapter le buffer ‚cran … la
	rts			;taille de notre r‚solution.

patchos	movem.l	d0-d3/a0-a2,-(sp)	;
	dc.w	$a000		;
	move.w	_width(pc),d0	;Corrige un certains nombre de
	move.w	_height(pc),d1	;variables de la LineA.
	move.w	_planes(pc),d2	;
	move.w	d0,V_REZ_HZ(a0)	;
	move.w	d1,V_REZ_VT(a0)	;
	move.w	d2,v_planes(a0)	;
	move.w	d0,d3		;
	lsr.w	#3,d3		;
	mulu.w	d3,d2		;
	move.w	d2,BYTES_LN(a0)	;
	move.w	d2,v_lin_wr(a0)	;
	mulu.w	V_CEL_HT(a0),d2	;
	move.w	d2,V_CEL_WR(a0)	;
	subq.w	#1,d3		;
	move.w	d3,V_CEL_MX(a0)	;
	move.w	d1,d3		;
	ext.l	d3		;
	divu.w	V_CEL_HT(a0),d3	;
	subq.w	#1,d3		;
	move.w	d3,V_CEL_MY(a0)	;
	subq.w	#1,d0		;
	subq.w	#1,d1		;
	movem.w	d0-d1,DEV_TAB(a0)	;
	movem.l	(sp)+,d0-d3/a0-a2	;
	rts			;

vgetsize	move.w	_width(pc),d0	;RAS...
	mulu.w	_planes(pc),d0	;
	lsr.l	#3,d0		;
	mulu.w	_height(pc),d0	;
	rts			;

setscreen	move.l	(a0)+,d1		;Si demande express pour r‚allouer
	sle	d0		;l'‚cran.. (… cause de NVDI, on
	move.l	(a0)+,d2		;r‚alloue aussi pour un paramŠtre
	ble.s	*+4		;-1... petite entorse … la normale,
	moveq	#0,d0		;sans cons‚quence en pratique).
	extb.l	d0		;
	movem.l	d0-d2/a0-a2,-(sp)	;
	move.l	(a0),-(sp)		;
	move.l	-(a0),-(sp)	;Transmet les paramŠtres
	move.l	-(a0),-(sp)	;
	move.w	-(a0),-(sp)	;
	clr.w	-(sp)		;
	pea	.ok(pc)		;
	move.w	sr,-(sp)		;Provoque un appel systŠme.
	bra	oldxb		;(principalement pour fixer
.ok	lea	14(sp),sp		;le mot de r‚solution)
	movem.l	(sp)+,d0-d2/a0-a2	;
	bsr	init		;Et hop, on vient par derriŠre.
	moveq	#5,d0		;
	rts			;

vsetmode	move.w	(a0),-(sp)		;
	move.w	-(a0),-(sp)	;Idem, mais en plus simple.
	clr.w	-(sp)		;
	pea	.ok(pc)		;
	move.w	sr,-(sp)		;
	bra	oldxb		;
.ok	addq.l	#4,sp		;
	moveq	#1,d0		;
	bsr	init		;
	moveq	#$58,d0		;
	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
start	lea	virus(pc),a1	;
	cmpi.l	#ID,_magic		;On est correct ?
	bne.s	abort		;Non:gasp !
	clr.l	-(sp)		;
	Gemdos	Super		;On roule en superviseur
	move.l	d0,Sys_SSP		;
	lea	deja_la(pc),a1	;
	move.l	$b8.w,a0		;
look	cmpi.l	#"XBRA",-12(a0)	;V‚rifie si on est d‚j… l….
	bne.s	valprg		;
	cmpi.l	#ID,-8(a0)		;
	move.l	-(a0),a0		;
	bne.s	look		;
abort	pea	(a1)		;
	Gemdos	Cconws		;
	Gemdos	Pterm0		;

valprg	move.l	4(sp),a0		;Adresse de la page de base.
	movea.l	12(a0),a1		;
	adda.l	20(a0),a1		;
	adda.l	28(a0),a1		;
	lea	stacksize+256(a1),a1	;->Taille du tout
	lea	0(a0,a1.l),sp	;
	pea	(a1)		;Mshrink
	pea	(a0)		;
	move.l	#$4a0000,-(sp)	;
	trap	#1		;
	lea	$c(sp),sp		;
	bsr.s	main		;Vroom: partie principale
	move.l	Sys_SSP(pc),-(sp)	;
	Gemdos	Super		;Repasse en user
	clr.w	-(sp)		;
	pea	start-(_magic-4)+256.w;
	Gemdos	Ptermres		;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
main	lea	SaveVidel(pc),a0	;
	bsr	GetVidel		;ParamŠtres vid‚o
	move.w	#-1,-(sp)		;
	Xbios	Vsetmode		;
	move.w	d0,SaveVidel+value	;Mode vid‚o courant
	Xbios	mon_type		;
	tst.w	_n		;
	bmi.s	clear		;S‚lection pas encore faite ?
	cmp.w	_type(pc),d0	;Moniteur incorrect ?
	bne.s	select		;
	move.w	#-1,-(sp)		;
	Bios	Kbshift		;
	lsr.w	#1,d0		;Ou alors, demande explicite
	bcs.s	.unpress		;avec shift droit?
	pea	present(pc)	;
	Gemdos	Cconws		;
	pea	nextime(pc)	;
	Gemdos	Cconws		;
	move.w	_type(pc),d0	;
	lea	([settings.w,pc,d0.w*4],2.w),a0;
	move.l	a0,ad_set		;
	bsr	out_reso		;
	bra	vector		;
.unpress	move.w	#-1,-(sp)		;
	Bios	Kbshift		;
	lsr.w	#1,d0		;
	bcs.s	.unpress		;
	move.w	_type(pc),d0	;
	bra.s	select		;

clear	clr.w	_n		;
select	move.w	d0,_type		;
	move.l	(settings.w,pc,d0.w*4),d0;
	bmi	breakout		;
	movea.l	d0,a0		;
	move.w	(a0)+,nb_set	;
	move.l	a0,ad_set		;

display	pea	present(pc)	;Donc menu et tutti quanti!
	Gemdos	Cconws		;
	bsr	out_reso		;
	pea	choice(pc)		;
	Gemdos	Cconws		;

.wait	Gemdos	Crawcin		;
	tst.b	d0		;
	beq.s	.wait		;
	move.w	_n(pc),d1		;
	cmpi.b	#'+',d0		;
	bne.s	.noplus		;
	addq.w	#1,d1		;
	bra.s	.nominus		;
.noplus	cmpi.b	#'-',d0		;
	bne.s	.nominus		;
	subq.w	#1,d1		;
.nominus	tst.w	d1		;
	bpl.s	.noneg		;
	clr.w	d1		;
	bra.s	.ok		;
.noneg	cmp.w	nb_set(pc),d1	;
	blo.s	.ok		;
	move.w	nb_set(pc),d1	;
	subq.w	#1,d1		;
.ok	ori.b	#$20,d0		;
	cmpi.b	#'s',d0		;
	beq.s	preset_fs		;
	cmp.w	_n(pc),d1		;
	beq.s	.wait		;
	move.w	d1,_n		;
	bra.s	display		;

preset_fs	pea	save_set(pc)	;
	Gemdos	Cconws		;
	Gemdos	Crawcin		;
	ori.b	#$20,d0		;
	cmpi.b	#'s',d0		;
	bne	set_fs		;
	move.w	#2,-(sp)		;
	pea	autoprg(pc)	;
	Gemdos	Fopen		;
	move.w	d0,d7		;
	bpl.s	.ok		;
	pea	progname(pc)	;
	Gemdos	Fopen		;
	move.w	d0,d7		;
	bmi	openerr		;
.ok	clr.w	-(sp)		;On s'ouvre, on se lit, et on
	move.w	d7,-(sp)		;s'‚crit...
	pea	$1c+4.w		;
	Gemdos	Fseek		;
	cmpi.w	#$1c+4,d0		;
	bne	badfile		;
	clr.l	-(sp)		;
	pea	(sp)		;
	pea	4.w		;
	move.w	d7,-(sp)		;
	Gemdos	Fread		;
	cmpi.l	#ID,(sp)+		;
	bne	badfile		;
	
	bsr.s	copy_set		;
	pea	_n(pc)		;
	pea	set_size+4.w	;
	move.w	d7,-(sp)		;
	Gemdos	Fwrite		;
	exg	d0,d7		;
	move.w	d0,-(sp)		;
	Gemdos	Fclose		;
	cmpi.w	#set_size+4,d7	;
	beq.s	vector		;
	bra	writerr		;

set_fs	bsr.s	copy_set		;

vector	lea	$88.w,a0		;
	lea	vdivec(pc),a1	;Installation tout en
	move.l	#vdihdl,d1		;douceur avec le 030.
.0	cas2.l	d0:d2,d1:d0,(a0):(a1)	;
	bne.s	.0		;
	lea	$b8.w,a0		;
	lea	xbvec(pc),a1	;
	move.l	#xbhdl,d1		;
.1	cas2.l	d0:d2,d1:d0,(a0):(a1)	;
	bne.s	.1		;
	rts			;

copy_set	movem.l	d0/a0-a1,-(sp)	;
	lea	_width(pc),a1	;
	move.w	_n(pc),d0		;
	mulu	#set_size,d0	;
	lea	([ad_set.w,pc],d0.w),a0;
	moveq	#set_size/2-1,d0	;
	move.w	(a0)+,(a1)+	;
	dbf	d0,*-2		;
	movem.l	(sp)+,d0/a0-a1	;
	rts

out_reso	move.w	_n(pc),d0		;
	mulu	#set_size,d0	;
	movem.w	([ad_set.w,pc],d0.w),d0-d3;
	lea	txt_resol(pc),a0	;
	lea	txt_trans(pc),a1	;
	moveq	#3,d4		;
.out	bsr.s	out_num		;
	move.b	(a1)+,(a0)+	;
	bne.s	*-2		;
	subq.l	#1,a0		;
	move.w	d1,d0		;
	move.w	d2,d1		;
	move.w	d3,d2		;
	dbf	d4,.out		;
	pea	txt_resol(pc)	;
	Gemdos	Cconws		;
	rts

out_num	move.l	d1,-(sp)		;Petite routine de sortie
	moveq	#3,d1		;de nombres d‚cimaux.
.bcl	ext.l	d0		;
	divu.w	#10,d0		;
	swap	d0		;
	move.w	d0,-(sp)		;
	swap	d0		;
	dbf	d1,.bcl		;
	moveq	#3,d1		;
	move.w	(sp)+,d0		;
	dbne	d1,*-2		;
	bne.s	.in		;
	addq.w	#1,d1		;
	bra.s	.in		;
.ok	move.w	(sp)+,d0		;
.in	addi.w	#'0',d0		;
	move.b	d0,(a0)+		;
	dbf	d1,.ok		;
	move.l	(sp)+,d1		;
	rts			;

breakout	pea	breakmes(pc)	;Erreurs en tout genre
	Gemdos	Cconws		;
	bra.s	cassos		;
openerr	pea	openmes(pc)	;
	bra.s	err		;
writerr	pea	writmes(pc)	;
	bra.s	err		;
badfile	pea	badfmes(pc)	;
err	Gemdos	Cconws		;
	Gemdos	Crawcin		;
cassos	move.l	Sys_SSP(pc),(sp)	;
	Gemdos	Super		;
	Gemdos	Pterm0		;
	

GetVidel	movem.l	d0-d2/a0-a3,-(sp)	;
	bsr	GetSync		;Attendre Vsync (superflu?)
	lea	VidelOrder(pc),a2	;
	moveq	#6-1,d1		;6 groupes
.gv_bcl	move.w	(a2)+,a3		;Adresse Videl
	move.w	(a2)+,d2		;Nombre de registres
	move.w	(a3)+,(a0)+	;Sauver bˆtement
	dbf	d2,*-2		;
	dbf	d1,.gv_bcl		;
	move.b	v_resol.w,(a0)+	;ffff8260 = 1 octet
.gv_end	movem.l	(sp)+,d0-d2/a0-a3	;
	rts			;
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	section	data
settings	dc.l	mono_settings,rgb_settings,vga_settings,rgb_settings
rgb_settings
	dc.w	18

	dc.w	1664,592,49,4
	dc.w	$1fd,$196,$50,$1,$173,$1b0
	dc.w	$27a,$270,$22,$20,$270,$26f
	dc.w	0,416,10,$182,$0000,$00<<8
	dc.w	$19F,$10a

	dc.w	1664,592,49,8
	dc.w	$1fd,$196,$50,$11,$183,$1b0
	dc.w	$27a,$270,$22,$20,$270,$26f
	dc.w	0,416,10,$182,$0010,$00<<8
	dc.w	$19F,$10a

	dc.w	1664,496,58,4
	dc.w	$1ff,$1cb,$60,$2f,$197,$1d4
	dc.w	$21e,$218,$24,$28,$218,$219
	dc.w	0,416,10,$182,$0000,$00<<8
	dc.w	$19F,$10a

	dc.w	1664,496,58,8
	dc.w	$1ff,$1cb,$60,$2f,$197,$1d4
	dc.w	$21e,$218,$24,$28,$218,$219
	dc.w	0,416,10,$182,$0010,$00<<8
	dc.w	$19F,$10a

	dc.w	1664,448,64,4
	dc.w	$1ff,$1cb,$60,$2f,$197,$1d4
	dc.w	$1e2,$1de,$24,$26,$1de,$1dd
	dc.w	0,416,10,$182,$0000,$00<<8
	dc.w	$19F,$10a


	dc.w	1664,448,64,8
	dc.w	$1ff,$1cb,$60,$2f,$197,$1d4
	dc.w	$1e2,$1de,$24,$26,$1de,$1dd
	dc.w	0,416,10,$182,$0010,$00<<8
	dc.w	$19F,$10a

	dc.w	832,592,49,4
	dc.w	$1fd,$196,$50,$1,$173,$1b0
	dc.w	$27a,$270,$22,$20,$270,$26f
	dc.w	0,208,06,$181,$0000,$00<<8
	dc.w	$19F,$10a

	dc.w	832,592,49,8
	dc.w	$1fd,$196,$50,$11,$183,$1b0
	dc.w	$27a,$270,$22,$20,$270,$26f
	dc.w	0,208,06,$181,$0010,$00<<8
	dc.w	$19F,$10a

	dc.w	832,592,49,16
	dc.w	$1fd,$196,$50,$23,$195,$1b0
	dc.w	$27a,$270,$22,$20,$270,$26f
	dc.w	0,208,06,$181,$0100,$00<<8
	dc.w	$19F,$10a

	dc.w	832,496,58,4
	dc.w	$1ff,$193,$50,$1,$171,$1b4
	dc.w	$21e,$218,$24,$28,$218,$219
	dc.w	0,208,06,$181,$0000,$00<<8
	dc.w	$19F,$10a

	dc.w	832,496,58,8
	dc.w	$1ff,$193,$50,$11,$181,$1b4
	dc.w	$21e,$218,$24,$28,$218,$219
	dc.w	0,416,06,$181,$0010,$00<<8
	dc.w	$19F,$10b

	dc.w	832,496,58,16
	dc.w	$1ff,$193,$50,$23,$193,$1b4
	dc.w	$21e,$218,$24,$28,$218,$219
	dc.w	0,832,06,$181,$0100,$00<<8
	dc.w	$19F,$10c

	dc.w	832,448,64,4
	dc.w	$1ff,$193,$50,$1,$171,$1b4
	dc.w	$1e2,$1de,$24,$26,$1de,$1dd
	dc.w	0,208,06,$181,$0000,$00<<8
	dc.w	$19F,$10a

	dc.w	832,448,64,8
	dc.w	$1ff,$193,$50,$11,$181,$1b4
	dc.w	$1e2,$1de,$24,$26,$1de,$1dd
	dc.w	0,416,06,$181,$0010,$00<<8
	dc.w	$19F,$10b

	dc.w	832,448,64,16
	dc.w	$1ff,$193,$50,$23,$193,$1b4
	dc.w	$1e2,$1de,$24,$26,$1de,$1dd
	dc.w	0,832,06,$181,$0100,$00<<8
	dc.w	$19F,$10c

	dc.w	832,296,49,4
	dc.w	$1fd,$196,$50,$1,$173,$1b0
	dc.w	$27b,$26f,$21,$20,$270,$26f
	dc.w	0,208,04,$181,$0000,$00<<8
	dc.w	$19F,$00a

	dc.w	832,296,49,8
	dc.w	$1fd,$196,$50,$11,$183,$1b0
	dc.w	$27b,$26f,$21,$20,$270,$26f
	dc.w	0,416,04,$181,$0010,$00<<8
	dc.w	$19F,$00b

	dc.w	832,296,49,16
	dc.w	$1fd,$196,$50,$23,$195,$1b0
	dc.w	$27b,$26f,$21,$20,$270,$26f
	dc.w	0,832,04,$181,$0100,$00<<8
	dc.w	$19F,$00c

mono_settings
	dc.w	4

	dc.w	640,400,70,1
	dc.w	$01a,$00,$00,$20f,$0c,$14
	dc.w	$3e9,$000,$00,$43,$363,$3e7
	dc.w	0,40,08,$080,$0000,$02<<8
	dc.w	$18F,$088

	dc.w	640,500,65,1
	dc.w	$01a,$00,$00,$20f,$0c,$14
	dc.w	$44b,$000,$00,$01,$3e9,$422
	dc.w	0,40,08,$080,$0000,$02<<8
	dc.w	$18F,$088

	dc.w	640,520,65,1
	dc.w	$01a,$00,$00,$20f,$0c,$14
	dc.w	$44b,$000,$00,$01,$420,$422
	dc.w	0,40,08,$080,$0000,$02<<8
	dc.w	$18F,$088

	dc.w	768,520,65,1
	dc.w	$01d,$00,$00,$211,$10,$18
	dc.w	$44b,$000,$00,$01,$420,$422
	dc.w	0,48,08,$0c8,$0000,$02<<8
	dc.w	$18F,$088

vga_settings
	dc.w	21

	dc.w	640,480,80,1
	dc.w	$0c6,$8d,$15,$273,$50,$96
	dc.w	$3e7,$3e3,$23,$23,$3eb,$3e4
	dc.w	0,40,08,$182,$0400,$00<<8
	dc.w	$19F,$018

	dc.w	672,512,72,1
	dc.w	$0ce,$8d,$0d,$273,$50,$96
	dc.w	$427,$423,$23,$23,$42b,$424
	dc.w	0,42,08,$182,$0400,$00<<8
	dc.w	$19F,$018

	dc.w	704,528,67,1
	dc.w	$0d6,$8d,$05,$273,$50,$96
	dc.w	$447,$443,$23,$23,$44b,$444
	dc.w	0,44,08,$182,$0400,$00<<8
	dc.w	$19F,$018

	dc.w	736,560,59,1
	dc.w	$0e6,$8d,$05,$283,$50,$96
	dc.w	$487,$483,$23,$23,$48b,$484
	dc.w	0,46,08,$182,$0400,$00<<8
	dc.w	$19F,$018

	dc.w	768,576,54,1
	dc.w	$0f6,$8d,$05,$293,$50,$96
	dc.w	$4a7,$4a3,$23,$23,$4ab,$4a4
	dc.w	0,48,08,$182,$0400,$00<<8
	dc.w	$19F,$018

	dc.w	800,608,48,1
	dc.w	$106,$8d,$05,$2a3,$50,$96
	dc.w	$4e7,$4e3,$23,$23,$4eb,$4e4
	dc.w	0,50,08,$182,$0400,$00<<8
	dc.w	$19F,$018

	dc.w	832,624,44,1
	dc.w	$116,$8d,$05,$2b3,$50,$96
	dc.w	$507,$503,$23,$23,$50b,$504
	dc.w	0,52,08,$182,$0400,$00<<8
	dc.w	$19F,$018

	dc.w	736,560,61,4
	dc.w	$0df,$b8,$29,$2d0,$a8,$b7
	dc.w	$487,$483,$23,$23,$48b,$484
	dc.w	0,184,08,$182,$0000,$00<<8
	dc.w	$19F,$01A

	dc.w	736,560,61,8
	dc.w	$0df,$b8,$29,$2d0,$a8,$b7
	dc.w	$487,$483,$23,$23,$48b,$484
	dc.w	0,368,08,$182,$0010,$00<<8
	dc.w	$19F,$01b

	dc.w	768,576,57,4
	dc.w	$0e7,$b8,$21,$2d0,$a8,$b7
	dc.w	$4a7,$4a3,$23,$23,$4ab,$4a4
	dc.w	0,192,08,$182,$0000,$00<<8
	dc.w	$19F,$01A

	dc.w	768,576,57,8
	dc.w	$0e7,$b8,$21,$2d0,$a8,$b7
	dc.w	$4a7,$4a3,$23,$23,$4ab,$4a4
	dc.w	0,384,08,$182,$0010,$00<<8
	dc.w	$19F,$01b

	dc.w	800,608,52,4
	dc.w	$0ef,$b8,$19,$2d0,$a8,$b7
	dc.w	$4e7,$4e3,$23,$23,$4eb,$4e4
	dc.w	0,200,08,$182,$0000,$00<<8
	dc.w	$19F,$01A

	dc.w	800,608,52,8
	dc.w	$0ef,$b8,$19,$2d0,$a8,$b7
	dc.w	$4e7,$4e3,$23,$23,$4eb,$4e4
	dc.w	0,400,08,$182,$0010,$00<<8
	dc.w	$19F,$01b

	dc.w	832,624,50,4
	dc.w	$0f7,$b8,$11,$2d0,$a8,$b7
	dc.w	$507,$503,$23,$23,$50b,$504
	dc.w	0,208,08,$182,$0000,$00<<8
	dc.w	$19F,$01A

	dc.w	832,624,50,8
	dc.w	$0f7,$b8,$11,$2d0,$a8,$b7
	dc.w	$507,$503,$23,$23,$50b,$504
	dc.w	0,416,08,$182,$0010,$00<<8
	dc.w	$19F,$01b

	dc.w	864,656,46,4
	dc.w	$0ff,$b8,$09,$2d0,$a8,$b7
	dc.w	$547,$543,$23,$23,$54b,$544
	dc.w	0,216,08,$182,$0000,$00<<8
	dc.w	$19F,$01A

	dc.w	864,656,46,8
	dc.w	$0ff,$b8,$09,$2d0,$a8,$b7
	dc.w	$547,$543,$23,$23,$54b,$544
	dc.w	0,432,08,$182,$0010,$00<<8
	dc.w	$19F,$01b

	dc.w	896,672,45,4
	dc.w	$0ff,$b8,$01,$2d0,$a8,$b7
	dc.w	$567,$563,$23,$23,$56b,$564
	dc.w	0,224,08,$182,$0000,$00<<8
	dc.w	$19F,$01A

	dc.w	896,672,45,8
	dc.w	$0ff,$b8,$01,$2d0,$a8,$b7
	dc.w	$567,$563,$23,$23,$56b,$564
	dc.w	0,448,08,$182,$0010,$00<<8
	dc.w	$19F,$01b

	dc.w	928,704,40,4
	dc.w	$10f,$b8,$01,$2e0,$a8,$b7
	dc.w	$5a7,$5a3,$23,$23,$5ab,$5a4
	dc.w	0,232,08,$182,$0000,$00<<8
	dc.w	$19F,$01A

	dc.w	928,704,40,8
	dc.w	$10f,$b8,$01,$2e0,$a8,$b7
	dc.w	$5a7,$5a3,$23,$23,$5ab,$5a4
	dc.w	0,464,08,$182,$0010,$00<<8
	dc.w	$19F,$01b
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
virus	dc.b	27,"EStructure de FS2.PRG erronn‚e: virus attack?",$d,$a,0
deja_la	dc.b	$d,$a,"FalconScreen 2.0á d‚j… activ‚...",$d,$a,0
present	dc.b	27,'E',$d,$a
	dc.b	"+---------",27,"p FalconScreen 2.0á ",27,"q---------+",$d,$a
	dc.b	"|                                     |",$d,$a
	dc.b	"|  (C)oderight NulloS/DNT-Crew, 1993  |",$d,$a
	dc.b	"|  (C)redits   Markus Gutschke (1.0)  |",$d,$a
	dc.b	"+-------------------------------------+",$d,$a
	dc.b	$d,$a
	dc.b	$d,$a,0
nextime	dc.b	"La prochaine fois, r‚glez la r‚solution",$d,$a
	dc.b	"en appuyant sur Shift droit...",$d,$a
	dc.b	"ParamŠtres pr‚-selectionn‚s :",$d,$a,27,'p',0
txt_trans	dc.b	"*",0
	dc.b	", en ",0
	dc.b	"Hz et ",0
	dc.b	" bitplan(s)...",27,'q ',$d,$a,$d,$a,0
choice	dc.b	"Changer de paramŠtres: + ou -",$d,$a
	dc.b	"Confirmer ce choix   : s ou S",$d,$a,0
save_set	dc.b	$d,$a,"(S)auver les paramŠtres"
	dc.b	$d,$a,"(C)ontinuer",$d,$a,0
autoprg	dc.b	"\AUTO\"
progname	dc.b	"FS2.PRG",0
openmes	dc.b	"Impossible d'ouvrir FS2.PRG !..",$d,$a,0
writmes	dc.b	"Impossible d'‚crire dans FS2.PRG !..",$d,$a,0
badfmes	dc.b	"FS2.PRG n'est pas FalconScreen 2.0á !..",$d,$a,$0
breakmes	dc.b	$d,$a,"Moniteur non g‚r‚ par FS2 !..",$d,$a,0


	section	bss
SaveVidel	ds.b	set_size
txt_resol	ds.b	128
nb_set	ds.w	1
ad_set	ds.l	1
Sys_SSP	ds.l	1

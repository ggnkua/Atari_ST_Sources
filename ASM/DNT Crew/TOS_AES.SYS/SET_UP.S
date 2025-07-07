	include	hard_sys.s
	include	tos_030.s
	output	.acc
	opt	o+

ap_id	EQUR	d6	;Variables globales: registres hauts.
menu_id	EQUR	d7	;
rint_in	EQUR	a5	;adresse int_in permanente (->base)

buffer	equ	*-128	;Buffer dans BasePage, pas de malaise !!

	StartUp			;D‚marre le programme.
	lea	int_in(pc),rint_in	;Fixe le registre rint_in
	move.l	#appl_init,d0	;
	bsr	AES		;D‚claration au Gem.
	move.w	d0,ap_id		;
	bmi.s	exit		;Arg, impossible !
	tst.l	d7		;Accessoire ?
	beq.s	prg_run		;
	bra.s	acc_run		;
	dcb.b	256-(*-buffer),$e5	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prg_run	bsr.s	do_setup		;
	move.l	#appl_exit,d0	;
	bsr	AES		;S‚quence PRG classique.
exit	clr.w	(sp)		;
	trap	#1		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
msg_buf	EQUR	a6		;d‚clare registre de message.

acc_run	move.w	ap_id,(rint_in)	;
	move.l	#titlebar,addr_in-int_in(rint_in);D‚claration
	move.l	#menu_register,d0	;comme accessoire.
	bsr	AES		;
	move.w	d0,menu_id		;No d'ordre de l'AES
	lea	buffer(pc),msg_buf	;Fixe le registre de message.
	moveq	#-1,d0		;Z=0->pas de boite d'alerte
	bsr.s	do_setup		;SetUp en arrivant au bureau

.acc_bcl	move.l	msg_buf,addr_in-int_in(rint_in);
	move.l	#evnt_mesag,d0	;
	bsr	AES		;Attend un message
	cmpi.w	#AC_OPEN,(msg_buf)	;Ouverture d'accessoire ?
	bne.s	.acc_bcl		;
	cmp.w	8(msg_buf),menu_id	;On est concern‚ (test inutile,
	bne.s	.acc_bcl		;mais prudence..)
	bsr.s	do_setup		;Z=1 -> boite d'alerte
	bra.s	.acc_bcl		;recommence
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
handle	EQUR	d5

;Entr‚e: Si Z=0 alors pas de boite d'alerte.
do_setup	movem.l	d0-d4/a0-a1,-(sp)	;
	bne.s	.ds_go		;
	move.w	#1,(rint_in)	;bouton par defaut
	move.l	#present,addr_in-int_in(rint_in);et l'adresse du
	move.l	#form_alert,d0	;message.fonction Form_Alert
	bsr	AES		;go!
	subq.w	#1,d0		;
	bne	.ds_quit		;

.ds_go	move.l	#graf_handle,d0	;Commence par ouvrir une
	bsr	AES		;station VDI.
	move.w	d0,handle		;en demandant le handle
	lea	(rint_in),a0	;physique d'abord,
	moveq	#11-1,d0		;pour le passer au VDI et
	move.w	#1,(a0)+		;lui demander un poste logique
	dbf	d0,*-4		;dessus.
	addq.w	#1,-(a0)		;
	move.l	#v_opnvwk,d0	;
	bsr	VDI		;
	move.w	control+12(pc),handle	;
	beq.s	.ds_quit		;arg, VDI indisponible.

.ds_get	lea	buffer(pc),a0	;
	move.l	a0,addr_in-int_in(rint_in);Puis demande les 256 1ers
	move.w	#256,d1		;octets du buffer AES contenant
	move.w	d1,(rint_in)	;le DESKTOP actif.
	move.l	#shel_get,d0	;
	bsr.s	AES		;
.ds_bcl	move.b	(a0)+,d0		;Scan ce desktop jusqu'…
	cmpi.b	#'#',d0		;trouver la ligne #c.....
.ds_nxt	dbeq	d1,.ds_bcl		;C'est elle qui contient
	bne.s	.ds_end		;notamment les couleurs.
	cmpi.b	#'c',(a0)+		;
	bne.s	.ds_nxt		;
.ds_found	moveq	#16-1,d3		;16 couleurs
	lea	(rint_in),a1	;
	clr.w	(a1)+		;
.ds_nxtcol	moveq	#3-1,d1		;
.ds_calc	moveq	#7,d2		;0..7 pour STF, par d‚faut
	moveq	#0,d0		;
	move.b	(a0)+,d0		;
	subi.b	#'0',d0		;
	cmp.b	d2,d0		;>7 ? (->STE !)
	ble.s	.ds_stf		;
	moveq	#15,d2		;Oui, alors 0..15
	subq.b	#7,d0		;et corrige la valeur.
.ds_stf	mulu	#1000,d0		;RŠgle de 3 pour passer
	divu	d2,d0		;… l'intervalle 0..1000
	move.w	d0,(a1)+		;
	dbf	d1,.ds_calc	;3 composantes
	move.l	#vs_color,d0	;
	bsr.s	VDI		;Demande poliment au VDI
	subq.l	#8,a1		;de se demerder avec la couleur.
	addq.w	#1,(a1)+		;
	dbf	d3,.ds_nxtcol	;
.ds_end	move.l	#v_clsvwk,d0	;
	bsr.s	VDI		;
.ds_quit	movem.l	(sp)+,d0-d4/a0-a1	;
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AC_OPEN	equ	40
AC_CLOSE	equ	41

appl_init		equ	$0A000100
appl_exit		equ	$13000100
evnt_mesag		equ	$17000101
menu_register	equ	$23010101
shel_get		equ	$7A010101
form_alert		equ	$34010101
graf_handle	equ	$4D000500

v_opnvwk		EQU	$640B0000
v_clsvwk		EQU	$65000000
vs_color		EQU	$0E040000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;En entr‚e D0=struct	{
;		le num‚ro de fonction voulu.b
;		nb d'entr‚es int_in.b
;		nb d'entr‚es addr_in.b
;		nb de sortie int_out.b
;		}
;En sortie: D0=int_out[0] r‚sultat de fonction
;	CCR selon D0
;
AES	movem.l	d1-a6,-(sp)	;
	lea	control(pc),a0	;
	clr.l	(a0)+		;S‚curit‚: clear le tableau
	clr.l	(a0)+		;avant usage
	clr.w	(a0)+		;
	movep.l	d0,-9(a0)		;Remplie avec le descripteur
	move.w	#$c8,d0		;Pas de test addr_out: tjs nul
	move.l	#AESPB,d1		;dans notre ACC.
	trap	#2		;hop
	moveq	#0,d0		;
	move.w	int_out(pc),d0	;valeur de sortie
	movem.l	(sp)+,d1-a6	;
	rts
AESPB	dc.l	control,global,int_in,int_out,addr_in,addr_out
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;En entr‚e D0=struct	{
;		code op‚ration.b
;		nb d'entr‚es intin.b
;		sous-opcode.b
;		nb d'entr‚es ptsin.b
;		}
;En sortie: D0.w=intout[0] r‚sultat de fonction
;	CCR selon D0
;
VDI	movem.l	d1-a6,-(sp)	;
	lea	control+12(pc),a0	;
	move.w	handle,(a0)	;handle de la station
	clr.l	-(a0)		;
	clr.l	-(a0)		;Efface tout le reste
	clr.w	-(a0)		;
	move.b	d0,1(a0)		;Nb de couples ptsin
	lsr.w	#8,d0		;
	move.w	d0,8(a0)		;Num‚ro de fonction (sous-opcode)
	swap	d0		;et taille intin
	move.b	d0,5(a0)		;
	lsr.w	#8,d0		;
	move.w	d0,-(a0)		;et finalement, stocke le
	move.l	#VDIPB,d1		;code op‚ration.
	moveq	#$73,d0		;et roulez jeunesse.
	trap	#2		;
	moveq	#0,d0		;
	move.w	int_out(pc),d0	;renvoyer int_out[0]
	movem.l	(sp)+,d1-a6	;
	rts
VDIPB	DC.L	control,int_in,ptsin,int_out,ptsout
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	DATA
present	dc.b	"[2][ (C)oderight DNT-Crew 1993| | SetUp des couleurs selon| le fichier DESKTOP actif ?..  | ][ Oui | Non ]",0
titlebar	dc.b	"  Mini-SetUp",0
	EVEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SECTION	BSS
;Tableaux du GEM.
control	ds.w	16
global	ds.w	15

ptsin	ds.w	1
addr_in	ds.l	1
int_in	ds.w	11

ptsout	ds.w	12
addr_out	ds.l	0
int_out	ds.w	45

;Zone de pile.
	EVEN
stack	ds.b	256

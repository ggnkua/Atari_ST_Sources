*----------------------------------------------*
* Program   : TRANSBEAUCE DEMO II BOOT SECTOR  *
* Code      : Mr.Bee                           *
* Team      : Overlanders                      *
* Date      : 5/26/91                          *
* Asm       : Devpac 2.20                      *
* Tabulation: 10                               *
*----------------------------------------------*

screen	=	$20000
code	=	$30000

* Salut J.C. voici quelques explications:
*
* attention quand le boot est genere certaines adresses
* sont fixes (c'est pas beau mais je sais, c'est du vite fait...)
* voir les labels:
* - adresse : adresse de chargement du 2eme secteur
*  (voir label loadsect:)
* - code    : adresse de la table de couleur pour la synchro
* - screen  : adresse de l'ecran
*
* le code fait 480 octets (donc on peut conserver toutes les infos)
*
* pour essayer depuis le devpac:
* - asembler avec code_text=0 et test=0
*
* pour generer le boot secteur:
* - assembler avec code_text=1 et test=1
* - alt-D
* - ctrl-R
* - puis sauver entre les labels boot et bootend
*
* Amitie, salut, Patrick

code_text	=	1	1 pour coder le texte

	IFNE	code_text
	lea	mess(pc),a0
	moveq	#nb_chr-4,d0
code_txt	not.b	(a0)+
	dbf	d0,code_txt
	illegal
	ENDC

boot:	move	#$8200,a4
	move	#$8240,a5
	move.l	(a4),-(sp)
	move.b	$fffffa15.w,-(sp)
	clr.b	$fffffa15.w

	move.l	a5,a0
	moveq	#8-1,d0
.fade0	clr.l	(a0)+
	dbra	d0,.fade0

	lea	mess(pc),a0
	pea	(a0)
	moveq	#nb_chr-4,d0
decode	not.b	(a0)+
	dbf	d0,decode
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

* construction de la table des couleurs a affiche

zoom_y	=	28

	moveq	#$002,d6
	moveq	#$000,d5
	move.l	$44e.w,a0
	lea	code,a1
	moveq	#8-1,d0		nb de ligne
mk_rout0	moveq	#zoom_y-1,d4	zoom en Y
mk_rout1	moveq	#nb_chr-1,d1	nb de char
	move.l	#$70001,d3
	move.l	d5,-(sp)
	move.l	a0,-(sp)
mk_rout2	moveq	#8-1,d2
mk_rout3	move	d6,(a1)
	btst	d2,(a0)
	beq.s	mk_rout4
	move	d5,(a1)
mk_rout4	addq	#2,a1
	dbf	d2,mk_rout3
	add	d3,a0
	swap	d3
	add	#$111,d5
	dbf	d1,mk_rout2
	move.l	(sp)+,a0
	move.l	(sp)+,d5
	add	#$010,d5
	dbf	d4,mk_rout1
	addq	#$001,d5
	lea	160(a0),a0
	dbf	d0,mk_rout0

* Efface l'ecran

	move.l	#screen,d0
	move.l	d0,a0
	lsr	#8,d0
	move.l	d0,(a4)
	move	#9999,d0
clr_scr	clr.l	(a0)+
	dbf	d0,clr_scr

	moveq	#0,d7
	moveq	#1,d6
	moveq	#0,d3
	move	#vmin,d4

	move.l	$70.w,-(sp)
	move.l	$68.w,-(sp)
	lea	vbl(pc),a0
	move.l	a0,$70.w
	lea	hbl(pc),a0
	move.l	a0,$68.w

bootsync	stop	#$2300
	lea	code,a6

vmax	=	40
vmin	=	-200

	add	d3,d4
	tst	d3
	beq.s	bs2
	cmp	#vmax,d3
	beq.s	bs2
	cmp	#-vmax,d3
	bne.s	bs3
bs2	neg	d3
	add	d3,d4
bs3	addq	#1,d3
bs4	move	d4,d2
	moveq	#0,d5
	asr	#3,d2
	bpl.s	bs5
	sub	d2,d5
	muls	#nb_chr*8*2,d2
	sub.l	d2,a6
	clr	d2
bs5

	moveq	#1,d0
	and	d7,d0
	eor	#1,d0
	mulu	#6,d0

	stop	#$2100
	move	#$2300,sr
	moveq	#80,d1
	add	d0,d1
	moveq	#0,d0
wait_scr	move.b	$ffff8209.w,d0
	beq.s	wait_scr
	sub	d0,d1
	lsr	d1,d1
	moveq	#21,d0
wt_ln	dbf	d0,wt_ln


wt_ln1	moveq	#41-1,d0		\
wt_ln2	dbf	d0,wt_ln2		| =128 nops
	dbf	d2,wt_ln1		/

	move	d7,d0
	and	#~$1,d0
	add	d0,a6
	move	#7*zoom_y,d0
	sub	d5,d0
draw	moveq	#20-1,d1
draw2	move	(a6)+,(a5)
	dbf	d1,draw2
	nop
	lea	(nb_chr*8-20)*2(a6),a6
	dbf	d0,draw
	clr	(a5)

	add	d6,d7
	beq.s	inv_dir
	cmp	#(nb_chr)*8+20*8,d7
	bne.s	no_inv
inv_dir	neg	d6
no_inv

tst_key	cmp.b	#$39,$fffffc02.w
	bne	bootsync

	move.l	(sp)+,$68.w
	move.l	(sp)+,$70.w
	move.b	(sp)+,$fffffa15.w
	move.l	(sp)+,(a4)

* ici chargement du secteur suivant:

;adresse	=	$10000

loadsect:
	move	#1,-(sp)		nb de secteur a lire
	clr.l	-(sp)		face 0
;	clr	-(sp)		piste 0
	move	#2,-(sp)		secteur 2
	move	$446.w,-(sp)	no de lecteur
	clr.l	-(sp)
	pea	adresse(pc)
	move	#8,-(sp)
	trap	#14
;	lea	20(sp),sp
adresse:

;	rts

vbl:
*-------- OVERSCAN HAUT ---------*
	moveq	#33,d0
vbl2	stop	#$2100
	dbf	d0,vbl2
	moveq	#23,d0
vbl3	dbf	d0,vbl3
	move.b	#0,$ffff820a.w	60 Hz
	moveq	#6,d0
vbl4	dbf	d0,vbl4
	move.b	#2,$ffff820a.w	Back to 50 Hz
hbl:	rte

mess:
*		 0         1         2
*		 01234567890123456789012345
mess2	dc.b	"  THE TRANSBEAUCE DEMO II"
mess3	dc.b	0,"MR.BEE CODE/OVR/91"
nb_chr	=	mess3-mess2+3

bootend

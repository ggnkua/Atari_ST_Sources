
*   speed intro for euroswap
*   coded by sademan

	opt	d+
	section	text

	move.l	a7,a5
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$200,d0
	move.l	d0,d1
	add.l	a5,d1
	and.l	#-2,d1
	move.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp
	pea	env
	pea	com
	pea	lance
	move.w	#3,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	move.l	d0,b_page
	lea	table,a6
	move.l	#player1,(a6)+	
	move.l	#player2,(a6)+	
	move.l	#player3,(a6)+	
	move.l	#player4,(a6)+
	move.l	#texte,(a6)+
	move.l	#no_cd,(a6)+
	move.l	#super,-(sp)
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	pea	env
	move.l	b_page,-(sp)
	pea	com
	move.w	#4,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
sorite	cmp.l	#0,d0
	bne.s	second
	move.l	#fil1,a0
	bra	go
second	cmp.l	#1,d0
	bne	troisieme
	move.l	#fil2,a0
	bra	go
troisieme	cmp.l	#2,d0
	bne	quatrieme
 	move.l	#fil3,a0
 	bra	go
quatrieme	move.l	#fil4,a0
go	pea	env
	pea	com
	move.l	a0,-(sp)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#16,sp
	move.l	#palet,-(sp)
	move.w	#6,-(sp)
	trap	#14
	add.l	#6,sp
	clr.w	-(sp)
	trap	#1
super	move.l	#table,$49e.w
	move.l	#$ffff8240,a1
	lea	palet,a0
	movem.l	(a1),d0-7
	movem.l	d0-7,(a0)
	move.l	#noire,a0
	movem.l	(a0),d0-d7
	movem.l	d0-7,(a1)
	move.l	$44e.w,a0
	move.w	#200*40-1,d0
net	clr.l	(a0)+
	dbf	d0,net
	move.b	#$12,$fffc02
	clr.b	$484.w
super3	move.l	$44e.w,a5
	lea	160*55(a5),a5
	lea	image1,a6
	move.w	#40*92-1,d0
.bcl1	move.l	(a6)+,(a5)+
	dbf	d0,.bcl1
	move.l	#$ffff8240,a6
	clr.l	d7
	clr.l	d6
	clr.l	d5
	clr.l	d4
	clr.l	d3
	clr.l	d2
	clr.l	d1
	clr.l	d0
	move.w	#7,cpt
.bcl	movem.l	d0-7,(a6)
	bsr	wait_vbl
	add.l	#$1110111,d7
	move.l	d7,d0
	move.l	d7,d1
	move.l	d7,d2
	move.l	d7,d3
	move.l	d7,d4
	move.l	d7,d5
	move.l	d7,d6
	subq.w	#1,cpt
	bpl.s	.bcl
	bsr	wait_vbl
	lea	cycle,a5
	move.w	#7,cpt
.bcl3	movem.l	(a5)+,d0-7
	movem.l	d0-7,(a6)
	bsr	wait_vbl
	subq.w	#1,cpt
	bpl.s	.bcl3
	move.w	#10,d7
pause	bsr	wait_vbl
	dbf	d7,pause
super_4	lea	cycle,a5
	lea	16*2*7(a5),a5
	lea	$ffff8240.w,a6
	move.w	#7,cpt
.bcl	movem.l	(a5),d0-d7
	movem.l	d0-7,(a6)
	lea	-16*2(a5),a5
	bsr	wait_vbl
	subq.w	#1,cpt
	bpl.s	.bcl
	move.l	#$7770777,d7
	move.l	d7,d6
	move.l	d7,d5
	move.l	d7,d4
	move.l	d7,d3
	move.l	d7,d2
	move.l	d7,d1
	move.l	d7,d0
	move.w	#7,cpt

.bcl2	movem.l	d0-7,(a6)
	sub.l	#$1110111,d0
	sub.l	#$1110111,d1
	sub.l	#$1110111,d2
	sub.l	#$1110111,d3
	sub.l	#$1110111,d4
	sub.l	#$1110111,d5
	sub.l	#$1110111,d6
	sub.l	#$1110111,d7
	movem.l	d0-7,-(sp)
	bsr	wait_vbl
	movem.l	(sp)+,d0-7
	subq.w	#1,cpt
	bpl.s	.bcl2
	rts
wait_vbl
	move.w	#$25,-(sp)
	trap	#14
	addq.w	#2,sp
	move.w	#$25,-(sp)
	trap	#14
	addq.w	#2,sp
	move.w	#$25,-(sp)
	trap	#14
	addq.w	#2,sp
	rts	

	section	data
cpt	dc.w	0
cycle	
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777
	dc.w	$666,$667,$667,$667,$667,$677,$677,$677,$777,$777,$777,$777,$766,$766,$766,$766
	dc.w	$555,$557,$557,$557,$557,$567,$567,$577,$777,$777,$777,$777,$755,$755,$755,$755
	dc.w	$444,$446,$447,$447,$447,$457,$457,$467,$777,$777,$777,$666,$744,$744,$744,$644
	dc.w	$333,$335,$336,$337,$337,$347,$347,$357,$777,$777,$666,$555,$733,$733,$633,$533
	dc.w	$222,$224,$225,$226,$227,$237,$237,$247,$777,$666,$555,$444,$722,$622,$522,$422
	dc.w	$111,$113,$114,$115,$116,$127,$127,$137,$666,$555,$444,$333,$611,$511,$411,$311
	dc.w	$000,$002,$003,$004,$005,$016,$017,$027,$555,$444,$333,$222,$500,$400,$300,$200

noire	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

lance	dc.b	'a:\auto\speed.int',0
	even
com	dc.w	0
env	dc.w	0
image1	incbin	a:\auto\boot.img


***************************************************
***************************************************
**                                               **
**                 PARAMETRAGE                   **
**                                               **
***************************************************
***************************************************

* fonte du nom des jeux
*fnt_play	dc.b	"ABCDEFGHIJKLMNOPQRST"
*	dc.b	"UVWXYZ1234567890.!?("
*	dc.b	")',+-_*:;/sky¹¹ "
	even
	
* titre des jeux a afficher
player1	dc.b    "F1 MAC DONALD LAND",-1
player2	dc.b    "F2 FRANKENSTEIN",-1
player3	dc.b    "F3 CIVILIZATION DOC",-1
player4	dc.b    "F4 CD LIST",-1
	even
	
* nom des jeux sur disk
fil1	dc.b	'a:\1.prg',0
fil2	dc.b	'a:\2.prg',0
fil3	dc.b	'a:\3.prg',0
fil4	dc.b	'a:\4.prg',0
	even
	
* numero de cd ( 3 chiffres obligatoirement )
* de 000 a 999
no_cd	dc.b	'962'
	even
	
	
* fonte du texte 	
*	dc.b	' ABCDEFGHIJKLMNOPQRS'
*	dc.b	'TUVWXYZ&%%.()%,!?><'
*	dc.b	'1234567890@:;*#=+-_'
*	even

texte	
*	maximum 20 carateres par ligne
*	chaque ligne se termine par -1

*	maximum 4 ligne par page affiche
*	chaque page se termine par -2

*	la fin du text se termine par -3

	dc.b	'        HELLO!      ',-1	
	dc.b	'   L A U R E N Z O  ',-1	
	dc.b	'    FROM EUROSWAP   ',-2	

	dc.b	'        VOICI       ',-1
	dc.b	'      LE MENU 2     ',-1	
	dc.b	'      DU NOM DE     ',-2	
	
	dc.b	'S P E E D  I N T R O',-1
	dc.b	'S P E E D  I N T R O',-1
	dc.b	'S P E E D  I N T R O',-1
	dc.b	'  SPEED  INTRO !!!  ',-2
	
	
	DC.B	'                    ',-1  ;  A METRE DANS LES CD,MERCI.
	DC.B	'     MESSAGE AUX    ',-1
	DC.B	'  A T A R I S T E S ',-1
	DC.B	'                    ',-2
	
	DC.B	'       E X O 7      ',-1
	DC.B	'    VOUS PREPARE    ',-1
	DC.B	'         UNE        ',-1
	DC.B	'   EXTRA MEGADEMO   ',-2
	
	DC.B	'    TOUT CA EN 1 !  ',-1
	DC.B	'CA SORTIE EST PREVUE',-1
	DC.B	'         POUR       ',-1
	DC.B	'   CETTE ETE ! ! !  ',-2
	
	DC.B	'   EN ATTENDANT,JE  ',-1
	DC.B	'      PASSE MES     ',-1
	DC.B	'    REMERCIEMENTS   ',-1
	DC.B	'          A :       ',-2
	
	DC.B	'        AXYLAN      ',-1
	DC.B	'      ZOMBI CREW    ',-1
	DC.B	'       LAURENZO     ',-1
	DC.B	'          SAD       ',-2
	
	DC.B	'        GUICHE      ',-1
	DC.B	'      ANTICHRIST    ',-1
	DC.B	'(FOR THE GREETS ZIK)',-1
	DC.B	'                    ',-2	
	
	DC.B	' ET SALUTATIONS A : ',-1
	DC.B	'       CELTIK       ',-1
	DC.B	'      DR TRAP       ',-1
	DC.B	'       R-BOY        ',-2
	
	DC.B	'       WINNER       ',-1
	DC.B	'     FACTOR  X      ',-1
	DC.B	'     TOM AWAUK      ',-2
	
	DC.B	'   AUX  GROUPES;    ',-1
	DC.B	'       LEGACY       ',-1
	DC.B	'        NEXT        ',-1
	DC.B	'      MISFITS       ',-2
	
	DC.B	'     OVERLANDERS    ',-1
	DC.B	'     HEMOROIDES     ',-1
	DC.B	'      HYSTERIA      ',-1
	DC.B	'      ULTIMATE      ',-2
	
	DC.B	'   ET BIEN SUR AUX  ',-1
	DC.B	'       MEMBRES      ',-1
	DC.B	'         DE         ',-1
	DC.B	'        EXO7        ',-2
	
	DC.B	'        SADE        ',-1
	DC.B	'   (ALIAS SADMAN)   ',-1
	DC.B	'       GOOFY        ',-1
	DC.B	'        DYNO        ',-2
	
	DC.B	'      A SAVOIR ;    ',-1
	DC.B	' NOUS NE RECHERCHONS',-1
	DC.B	'    PLUS DE CODERS  ',-1
	DC.B	'        MAIS:       ',-2
	                
	DC.B	'     UN MUSICIEN    ',-1
	DC.B	'      COMPETENT     ',-1
	DC.B	'       CAPABLE      ',-1
	DC.B	'      DE  CREER     ',-2
	
	DC.B	'DES MUSICS AMBIANTES',-1
	DC.B	'   AVEC DES SAMPLES ',-1
	DC.B	'*PROPRES*POUR ETRES ',-1
	DC.B	'  INSERES A DIVERS  ',-2
	
	DC.B	' PROJETS DE JEUX EN ',-1
	DC.B	'        COURS.      ',-1
	DC.B	'         SUR:       ',-2
	
	DC.B	'    ATARI STE/STF   ',-1
	DC.B	'        FALCON      ',-1
	DC.B	' AMIGA 500 (600...) ',-1
	DC.B	'        A-1200      ',-2
	
	DC.B	'     SI VOUS ETES   ',-1
	DC.B	'       COMPETENT    ',-1
	DC.B	' CONTACTEZ NOUS SUR ',-1
	DC.B	'     LE SERVEUR     ',-2
	
	DC.B	'     TEL : 36 15    ',-1
	DC.B	'     CODE: RTEL     ',-1
	DC.B	'      A BIENTOT.    ',-2
	
	DC.B	'ET QUE LA FORCE SOIT',-1
	DC.B	'      AVEC VOUS!    ',-2
	
	DC.B	'HERE IS LAURENZO... ',-1
	DC.B	'THANX SKYWALKER.... ',-1
	DC.B	'AND LOOK : PASSWORDS',-1
	DC.B	'RULES ALWAYS..SORRY!',-2
	
	DC.B	' THANX AT ALL OUR   ',-1
	DC.B	' FANS AND FRIENDS...',-1
	DC.B	' WE RULES ON ATARI  ',-1
	DC.B	' AMIGA AND SNES NOW ',-2
	
	DC.B	'CONTACT US ON 3615  ',-1
	DC.B	' RTEL CLUB NOTARIUS ',-1
	DC.B	' PASS : EURO....BYE ',-2
	
	dc.b	-3			; fin texte
	even

	section	bss
table	ds.l	10
palet	ds.l	8
b_page	ds.l	1
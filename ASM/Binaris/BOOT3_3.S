TEST?	equ 0	;si 0, le boot d‚finitif; si 1, test 
	;tail: if test : 508 else 486

	ifne TEST?
	pea	BEGIN(pc)
	move.w	#38,-(sp)
	trap	#14
	move.w	#7,-(sp)
	trap	#1
	addq.l	#8,sp
	clr.w	-(sp)
	trap	#1
	endc

;		Super-boot V3.3b
; Plus de code g‚n‚r‚ pour les processeurs ayant un cache
; Horloge r‚sistant au reset pour TOS<1.6
; Support de 2.5 Mo
; Suppression des pauses disque dur (1.6+) et configurations m‚moire (2.5+)
; Passage en 60 Hz automatique sauf si shift gauche enfonc‚
; Et r‚ciproque; suivant AUTOINSTALL
; Affichage ram totale, libre, vecteur reset, nø tos,HEURE et DATE ainsi
; qu'un petit message.

HEADER:	bra.s	BEGIN+6*4	; header du boot
	dc.b	'IBM'
BOOT:

machdec:	moveq	#0,d1
	move.b	d0,d1	;0000001c (28 en d‚cimal)
	divu	#10,d1	;00080002
	rol.l	#8,d1	;08000200
	ror.w	#8,d1	;08000002
	rol.l	#8,d1	;00000208
	add.w	#$3030,d1	;00003238 (28 en ASCII, yeah !)
	rts
	
BEGIN:	;horloge r‚sidente
	move.w	#23,-(sp)	;lecture de l'horloge du XBIOS
	trap	#14	;‡.….d celle du clavier.
	move.l	d0,d2	;contrairement … celle du GEMDOS,
	swap.w	d0	;elle n'est pas forc‚e au reset
	move.l	d0,-(sp)	;donc elle est exacte au reset!
	move.w	#$2d,-(sp)	;merci XBIOS !
	trap	#1
	move.l	d2,-(sp)
	move.w	#$2b,-(sp)
	trap	#1

	
	lea.l	AFFICHE(pc),a6
	lsr.l	#5,d2	;les secondes, on s'en branle
	move.b	d2,d0
	andi.b	#%111111,d0
	bsr.s	machdec
	move.w	d1,ETXT-AFFICHE+16(a6)
	lsr.l	#6,d2
	move.b	d2,d0
	andi.b	#%11111,d0
	bsr.s	machdec
	move.w	d1,ETXT-AFFICHE+12(a6)
	lsr.l	#5,d2
	move.b	d2,d0
	and.b	#%11111,d0
	bsr.s	machdec
	move.w	d1,ETXT-AFFICHE(a6)
	lsr.w	#5,d2
	move.b	d2,d0
	and.b	#%1111,d0
	bsr.s	machdec
	move.w	d1,ETXT-AFFICHE+4(a6)
	lsr.b	#4,d2
	move.b	d2,d0
	add.b	#80,d0
	bsr.s	machdec
	move.w	d1,ETXT-AFFICHE+8(a6)
	
	pea	$000bffff	;fonction Kbshift; permet de connaitre
	trap	#13	;(ou de fixer) l'‚tat des touches
	btst	#1,d0	;sp‚ciales.Shift gauche? si oui on 
CHG:	bne.s	.NOSWITCH	;continue, sinon on saute … NOSWITCH
	;Attention; le label CHG doit pointer sur un bxx pour pouvoir
	;etre exploit‚ par AUTOINSTALL (bne=60Hz,beq=50Hz) par d‚faut

;passage en 60 Hz
	clr.b	$ffff820a.w

.NOSWITCH:
	pea	(a6)
	move.w	#9,-(sp)
	trap	#1

	lea.l	50(a6),a6
	movea.w	#$400,a2	;offset des variables systemes

;suppression des pauses
	bset	#6,$bc(a2)	;$4ba contient le timer systeme. il n'a
	;aucun role dans le systeme et encore moins au reset; donc, on
	;peut se permettre de le modifier … chaque reset.

;2.5 Mo support‚s
	move.l	$2e(a2),d6	;phystop; limite de la m‚moire
	;btst	#22,d6	;si ce bit est mis, 4Mo (logique)
	cmpi.w	#$40,$2e(a2)
	bne.s	NOPROB	;sinon, pas de problŠme
	cmpi.b	#$9,$24(a2)	;le controlleur de m‚moire a-t-il
	bne.s	NOPROB	;d‚tect‚ 2.5 Mo? si non pas de probleme
	;r‚sumons; si on arrive ici, c'est que le controlleur a d‚tect‚
	;une configuration de m‚moire inconnue. Le tos l'assimile …
	;4 Mo. En fait, pour arriver … 4 Mo, les blocs au del… de
	;2,5 Mo sont confondus avec le bloc {2;2.5} Mo.
	move.w	#$28,$2e(a2)	;met 2,5Mo dans phystop
	move.l	$4.w,a6	;adresse de reset
	jmp	(a6)	;et hop, reset
	;le reset est n‚cessaire ppour r‚initialiser le systŠme
	;d'exploitation qui, lui, croit toujours qu'il est en pr‚sence
	;de 4Mo de par les valeurs systŠme interne au TOS. 
	
NOPROB:	;on saute ici si il n'y a pas eu de probleme de m‚moire
	;d6 devra pointer jusqu'… nouvel ordre sur la ram totale
;test appui shift gauche
;commence … preparer le nouveau texte
	bsr.s	MACHE	;ecrire d6, taille ram totale

;calcul ram libre
	move.l	$36(a2),d6	;limite superieure-limite inferieure
	sub.l	$32(a2),d6	;utilisateur=taille ram libre
	bsr.s	MACHE	;ecrit. On sort avec d6=0
	cmp.l	#$31415926,$26(a2)
	bne.s	noreset
	move.l	$2a(a2),d6
noreset:	bsr.s	MACHE

	;move.l	#$0a0d0909,(a6)+	;… la ligne et 2 TABs
	move.l	2+MACHE(pc),(a6)+

;Cette routine est assez difficile … expliquer; alors vous donne uniquement
;les r‚sultats; avec les tos	;  1.0	  1.62	  2.6 

	moveq	#$2e,d6	;0000002e	0000002e	0000002e
	ror.l	#8,d6	;2e000000	2e000000	2e000000
	move.w	$2.w,d6	;2e000100	2e000162	2e000206
	ror.w	#8,d6	;2e000001	2e006201	2e000602
	add.b	#$30,d6	;2e000031	2e006231	2e000632
	ror.l	#8,d6	;312e0000	312e0062	322e0006
	ror.w	#4,d6	;312e0000	312e2006	322e6000
	tst.b	d6
	bne.s	NOTZERO
	move.b	#$d1,d6	;312e00d1		322e60d1
NOTZERO:	add.b	#$30,d6	;312e0001	312e2036	322e6001
	ror.w	#8,d6	;312e0100	312e3620	322e0160
	ror.b	#4,d6	;312e0100	312e3602	322e0106
	add.b	#$30,d6	;312e0130	312e3632	322e0136
; r‚sultat ascii emulateur VT52:	;  1.0	  1.62	  2.6
; (01 n'a pas d'effet)
	move.l	d6,(a6)+	;et hop, dans buffer.

;affichage nouveau texte
	;pea	AFFICHE(pc)	;affiche le text que l'on a g‚n‚r‚
	;move.w	#9,-(sp)	
	add.w	#50,4(sp)
	move.b	#10,2(a6)
	trap	#1

;quit
	lea.l	24(sp),sp
	rts                    

;permet de macher le travail en empilant automatiquement la valeur d6
MACHE:	move.l	#$0a0d0909,(a6)+	;saut de ligne, 2 TAB
	moveq	#7,d0
	addq.l	#8,a6
DOONE:	move.l	d6,d4
	and.b	#$f,d4
	add.b	#$30,d4
	cmpi.b	#$3a,d4
	bcs.s	NEXT
	addq.b	#7,d4
NEXT:	move.b	d4,-(a6)
	lsr.l	#4,d6
	dbra	d0,DOONE

	addq.l	#8,a6
	rts
	
AFFICHE:	dc.b	27,'Y',32+5,32
	dc.b	"ARboot 3.3 by Megar for XTERMINE",10,13
	dc.b	"by Dmviolator.",27,"pBINARIS PRODUCTION",27,"q",10,13
ETXT:	dc.b	'18/',1,'03/',1,'93 ',1,'13:',1,'40'
	dc.b	27,"H",0
	
WOT:	DC.b 'Tail. RAM total',10,13
	DC.b 'Tail. RAM libre',10,13
	dc.b 'Vec. RESET?',10,13
	DC.b 'TOS version',0
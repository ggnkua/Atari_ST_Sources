;	reset screen
;
;debut:10/05/91
;fin  :14/05/91
;dure du scroll text:	~28'		
;taille en RAM      :	143582 octets
;fichier a inclure  :	syncdat .inc
;		tabpt   .inc
;		graphchr.inc
;		traject .inc
;		sprite  .inc
;		prehi   .
;
;
;
;
;
;
;	code de PrinST
;====================================
;	CONSTANTES...
;====================================
NBETOILE	= 156   ; max:156
TIMER	= 5    ; max:650
;====================================
;	MACROS...
;====================================
rastern	macro
	move	(a4),$ffff8248.w
	move	(a4),$ffff824a.w
	move	(a4)+,$ffff824c.w
	move.b	d1,$ffff8260.w
	move.b	d0,$ffff8260.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	d0,$ffff820a.w
	move.b	d1,$ffff820a.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	d1,$ffff8260.w
	move.b	d0,$ffff8260.w
	endm
SPRITE	macro
;	a1:adresse affiche sprite
;	d0:decalage
	add.l	#fullscr+6,a1	
	lea	sprite,a2
	add.l	d0,a2
	lea	(a1),a3
	add.l	#230*200,a3
	rept	16
	move	(a2)+,d0
	or	d0,(a1)
	or	d0,(a3)
	addq.l	#8,a1
	addq.l	#8,a3
	move	(a2)+,d0
	or	d0,(a1)
	or	d0,(a3)
 	lea	222(a1),a1
	lea	222(a3),a3
	endr
	endm
EFFACE	macro
;
;	effacer sprite
;	a1: adresse sur ecran
;
	lea	(a1),a2
	add.l	#200*230,a2
	rept	16
	clr	(a1)
	clr	(a2)
	addq.l	#8,a1
	addq.l	#8,a2	
	clr	(a1)
	clr	(a2)
	lea	222(a1),a1
	lea	222(a2),a2
	endr
	endm
;====================================
;	MACROS...
;====================================
INITMUS	macro
	moveq.l	#1,d0
	jsr	zic
	endm
PLAYMUS	macro
	movem.l	d0-a6,-(sp)
	jsr	zic+8
	movem.l	(sp)+,d0-a6
	endm
;====================================
	section	text
;====================================
	pea	reset
	move	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1
;====================================
;	programme superuser
;====================================	
;====================================
;	programme au reset
;====================================
reset	move 	#$2700,sr
	clr.l	$426.w
;====================================
;	init new ecran
;====================================
	move.l 	#datasync+1,possync
	move.l 	#fullscr,adrful
;====================================
;	init variables
;====================================
	INITMUS
	move.l	#trajec,adrpos
	move.b	#6,guide
	move.l	#text,adrtxt
	lea	chrcar,a0
	add.l	#('*'-32)*8,a0
	move.b	#%00010000,(a0)+
	move.b	#%00111000,(a0)+
	move.b	#%11111110,(a0)+
	move.b	#%01111100,(a0)+
	move.b	#%00111000,(a0)+
	move.b	#%01111100,(a0)+
	move.b	#%01101100,(a0)+
	move.b	#%10000010,(a0)+
	move.b	#%00000000,(a0)+
	lea	chrcar,a0
	add.l	#('#'-32)*8,a0
	move.b	#$ff,(a0)+
	move.b	#$ff,(a0)+
	move.b	#$ff,(a0)+
	move.b	#$ff,(a0)+
	move.b	#$ff,(a0)+
	move.b	#$ff,(a0)+
	move.b	#$ff,(a0)+
	move.b	#$ff,(a0)+
;====================================
;	boucle principale
;====================================
bigbcl
;====================================
;	synchro VBL
;====================================
	lea 	$ffff8209.w,a6
	move 	#183,d7
	move.b 	$ffff8203.w,d5
vsync1	cmp.b 	$ffff8207.w,d5
	bne.s 	vsync1
;====================================
;	init couleur a 0
;====================================
	clr.l	$ffff8240.w
	clr.l	$ffff8244.w
	clr.l	$ffff8248.w
	clr.l	$ffff824c.w
	clr.l	$ffff8250.w
	clr.l	$ffff8254.w
	clr.l	$ffff8258.w
	clr.l	$ffff825c.w
;====================================
;	deplacer les sprites
;====================================
	lea	table,a4
	moveq	#24,d0
	lea	fullscr+6,a1
	add.l	(a4),a1
	EFFACE
	add.l	d0,a4
	lea	fullscr+6,a1
	add.l	(a4),a1
	EFFACE
	add.l	d0,a4
	lea	fullscr+6,a1
	add.l	(a4),a1
	EFFACE
	add.l	d0,a4
	lea	fullscr+6,a1
	add.l	(a4),a1
	EFFACE
	add.l	d0,a4
	lea	fullscr+6,a1
	add.l	(a4),a1
	EFFACE
	add.l	d0,a4
	lea	fullscr+6,a1
	add.l	(a4),a1
	EFFACE
	lea	table,a2
	lea	6(a2),a3
	rept	23
	move.l	(a3)+,(a2)+
	move	(a3)+,(a2)+
	endr
	move.l	adrpos,a3
	addq.l	#6,adrpos
	cmp.l	#trajec+720*6,adrpos
	bne.s	puiss
	move.l	#trajec,adrpos
puiss	move.l	(a3)+,(a2)+
	move	(a3),(a2)

	moveq	#0,d1
	lea	table,a4
	
	move.l	(a4)+,a1
	move	(a4)+,d0
	lea	18(a4),a4
	SPRITE
	move.l	(a4)+,a1
	move	(a4)+,d0
	lea	18(a4),a4
	SPRITE
	move.l	(a4)+,a1
	move	(a4)+,d0
	lea	18(a4),a4
	SPRITE
	move.l	(a4)+,a1
	move	(a4)+,d0
	lea	18(a4),a4
	SPRITE
	move.l	(a4)+,a1
	move	(a4)+,d0
	lea	18(a4),a4
	SPRITE
	move.l	(a4)+,a1
	move	(a4)+,d0
	lea	18(a4),a4
	SPRITE
	cmp.l	#endpage,adrtxt
	bne.s	puiss2
	move.l	#text,adrtxt
puiss2	PLAYMUS
;====================================
;	routine de sync
;====================================
	moveq	#18,d6
vsync2	tst.b 	(a6)
	beq.s 	vsync2
	sub.b 	(a6),d6
	lsr.l 	d6,d6
	lea 	$ffff820a.w,a0
	lea 	$ffff8260.w,a1
	moveq 	#0,d0
	moveq 	#2,d1
	clr	$ffff8240.w ;(4nop)
	rept 47
	nop
	endr
	moveq 	#14,d6
	move.l 	possync,a2
sync	nop
	move.b 	(a2)+,(a0)
	nop
	move.b 	d1,(a0)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b 	(a2),(a1)
	nop
	move.b 	d0,(a1)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b 	(a2)+,(a1)
	nop
	nop
	move.b 	d0,(a1)
	rept 83
	nop
	endr
	dbra 	d6,sync
	lea	raster,a4
;====================================
;	routine  normal full
;====================================
	lea	new_pal,a0
	lea	$ffff8240.w,a1
	movem.l	(a0),d2/d3/d4/d5/d6/d7/a2/a3
	rept	105
	nop
	endr	
	movem.l	d2/d3/d4/d5/d6/d7/a2/a3,(a1)
;
;	c parti pour tout l'ecran!!!!
;
	rept	184
	rastern
	endr
	clr	$ffff8240.w
;====================================
;	fin du full... temps mort.
;====================================
;====================================
;	deplacer les points
;====================================
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move	#NBETOILE-1,d0
	lea	tabpt,a2
mvtpt1	
;====================================
;	effacer l'etoile
;====================================
	move	4(a2),d2
	move	6(a2),d3
	lea	fullscr,a1
	add.l	(a2),a1
	clr	(a1)
;====================================
;	deplacer l'etoile
;====================================
	add.l	d2,(a2)
	add.l	d2,a1
	cmp.l	#230*400,(a2)
	blt.s	mvtpt2
	sub.l	#230*400,(a2)
	sub.l	#230*400,a1	
;====================================
;	afficher l'etoile
;====================================
mvtpt2	or	d3,(a1)
	addq.l	#8,a2
	dbra	d0,mvtpt1
;====================================
;	autres actions "guider".
;====================================
	move.l	adrful,a0
guide1	cmp.b	#1,guide
	bne	guide2
;====================================
;	affiche text en bas
;====================================
	move.l	adrtxt,a3
	move.l	adrons,a1
	lea	chrcar,a2
	moveq	#0,d0
	move.b	(a3),d0
	sub.l	#32,d0
	lsl.l	#3,d0
	add.l	d0,a2
	move.b	(a2)+,(a1)
	move.b	(a2)+,230(a1)
	move.b	(a2)+,460(a1)
	move.b	(a2)+,690(a1)
	move.b	(a2)+,920(a1)
	move.b	(a2)+,1150(a1)
	move.b	(a2)+,1380(a1)
	move.b	(a2)+,1610(a1)
	addq.l	#1,adrtxt
	addq.l	#1,adrons
	move.l	adrtxt,a3
	move.l	adrons,a1
	lea	chrcar,a2
	moveq	#0,d0
	move.b	(a3),d0
	sub.l	#32,d0
	lsl.l	#3,d0
	add.l	d0,a2
	move.b	(a2)+,(a1)
	move.b	(a2)+,230(a1)
	move.b	(a2)+,460(a1)
	move.b	(a2)+,690(a1)
	move.b	(a2)+,920(a1)
	move.b	(a2)+,1150(a1)
	move.b	(a2)+,1380(a1)
	move.b	(a2)+,1610(a1)
	addq.l	#1,adrtxt
	addq.l	#7,adrons
	addq.b	#2,xco
	cmp.b	#48,xco
	bne	ste1
	clr.b	xco
	addq.b	#1,yco
	add.l	#230*8+38,adrons
	cmp.b	#20,yco
	bne	guide4
	move.b	#7,guide
	bra	ste1
guide2	cmp.b	#2,guide
	bne.s	guide3
;====================================
;	sync vers le bas.
;====================================
	lea	230(a0),a0
	cmp.l	#fullscr+200*230,a0
	bne	ste1
	move.b	#5,guide
	bra	ste1
guide3	cmp.b	#3,guide
	bne	guide4
;====================================
;	afficher text en haut 
;====================================
	move.l	adrtxt,a3
	move.l	adrons,a1
	lea	chrcar,a2
	moveq	#0,d0
	move.b	(a3),d0
	sub.l	#32,d0
	lsl.l	#3,d0
	add.l	d0,a2
	move.b	(a2)+,(a1)
	move.b	(a2)+,230(a1)
	move.b	(a2)+,460(a1)
	move.b	(a2)+,690(a1)
	move.b	(a2)+,920(a1)
	move.b	(a2)+,1150(a1)
	move.b	(a2)+,1380(a1)
	move.b	(a2)+,1610(a1)
	addq.l	#1,adrtxt
	addq.l	#1,adrons
	move.l	adrtxt,a3
	move.l	adrons,a1
	lea	chrcar,a2
	moveq	#0,d0
	move.b	(a3),d0
	sub.l	#32,d0
	lsl.l	#3,d0
	add.l	d0,a2
	move.b	(a2)+,(a1)
	move.b	(a2)+,230(a1)
	move.b	(a2)+,460(a1)
	move.b	(a2)+,690(a1)
	move.b	(a2)+,920(a1)
	move.b	(a2)+,1150(a1)
	move.b	(a2)+,1380(a1)
	move.b	(a2)+,1610(a1)
	addq.l	#1,adrtxt
	addq.l	#7,adrons
	addq.b	#2,xco
	cmp.b	#48,xco
	bne	ste1
	clr.b	xco
	addq.b	#1,yco
	add.l	#230*8+38,adrons
	cmp.b	#20,yco
	bne.s	guide4
	move.b	#8,guide
	bra	ste1
guide4	cmp.b	#4,guide
	bne.s	guide5
;====================================
;	sync vers le haut
;====================================
	lea	-230(a0),a0
	cmp.l	#fullscr,a0
	bne	ste1
	move.b	#6,guide
guide5	cmp.b	#5,guide
	bne.s	guide6
;====================================
;	init affiche vers le haut
;====================================
	move.l	#fullscr+28,adrons
	clr.b	yco
	clr.b	xco
	move.b	#3,guide
	bra	ste1
guide6	cmp.b	#6,guide
	bne.s	guide7
;====================================
;	init affiche vers le bas
;====================================
	move.l	#fullscr,a0
	move.l	#fullscr+230*200+28,adrons
	clr.b	yco
	clr.b	xco
	move.b	#1,guide
	bra	ste1
guide7	cmp.b	#7,guide
	bne.s	guide8
;====================================
;	press space pour haut
;====================================
	addq	#1,comp
	cmp	#TIMER*100,comp
	bne.s	ste1
	clr	comp
	move.b	#2,guide
	bra	ste1
guide8	cmp.b	#8,guide
	bne.s	ste1
;====================================
;	press space pour bas
;====================================
	addq	#1,comp
	cmp	#TIMER*100,comp
	bne.s	ste1
	clr	comp
	move.b	#4,guide
;====================================
;	routine de calcul du sync
;====================================
ste1	move.l 	a0,adrful
	move.l 	a0,d0
	sub.l	#2752-48,d0
	move.l 	d0,d1
	and.l 	#254,d1
	lsl 	#4,d1
	move.l 	#datasync,d2
	add.l 	d1,d2
	move.l 	d2,a0
	addq.l 	#1,d2
	move.l 	d2,possync
	moveq 	#0,d1
	move.b 	(a0),d1
	lsl 	#8,d1
	and.l 	#$ffff00,d0
	sub.l 	d1,d0
	lsr.l 	#8,d0
	move.b 	d0,$ffff8203.w
	lsr 	#8,d0
	move.b 	d0,$ffff8201.w
;====================================
;	sorti par mis a 2 de vbig 
;====================================
	jmp 	bigbcl
;====================================
	section	data
;====================================
	even
pal	dc.w 0,$444,$555,0,$666,0,0,0,$777,0,0,0,0,0,0,0,0
raster	
	rept	4
	dc.w	$167,$257,$347,$437,$527,$617,$707
	dc.w	$716,$725,$734,$743,$752,$761,$770
	dc.w	$661,$552,$443,$334,$225,$116,$007
	dc.w	$016,$025,$034,$043,$052,$061,$070
	dc.w	$061,$052,$043,$034,$025,$016,$007
	dc.w	$017,$027,$037,$047,$057,$067,$077
	dc.w	$176,$275,$374,$473,$572,$671,$770
	endr
datasync	incbin b:\syncdata.bin
tabpt	incbin b:\tabpt.inc
chrcar	incbin b:\graphchr.inc
sprite	incbin b:\sprite.inc
trajec	incbin b:\traject.inc
	even
zic	incbin	prehi
	even
new_pal	dc.l	$01110333,$07770777,$00770077,$00770077,$00570057,$00570057,$00570057,$00570057
text	dc.b "************************************************"
	dc.b "                                                "
	dc.b "      ### # # ###     ### #  # ##               "
	dc.b "       #  # # #       #   ## # # #              "
	dc.b "       #  ### ##      ##  # ## #  #             "
	dc.b "       #  # # #       #   #  # #  #             "
	dc.b "       #  # # ###     ### #  # ####             "
	dc.b "                                                "
	dc.b "          ### ###    ### # # ###                "
	dc.b "          # # #       #  ### ##                 "
	dc.b "          # # ##      #  # # #                  "
	dc.b "          ### #       #  # # ###                "
	dc.b "                                                "
	dc.b " #### #### #### #### ####   ###   ### #   # ####"
	dc.b " #    #  # #  # #    #       # #  #   ## ## #  #"
	dc.b " #### #### #### #    ##      #  # ##  # # # #  #"
	dc.b "    # #    #  # #    #       #  # #   #   # #  #"
	dc.b " #### #    #  # #### ####   ##### ### #   # ####"
	dc.b "                                                "
	dc.b "************************************************"
	
	dc.b "************************************************"
	dc.b "                                                "
	dc.b "  Wellcome in the Reset screen of the SPACE DEMO"
	dc.b "                                                "
	dc.b " I think you have liked this Demo.and we hope   "
	dc.b "  see you soon.For more information read all    "
	dc.b " Text.                                          "
	dc.b "                                                "
	dc.b "      In first time, THE GREETINGS:             "
	dc.b "                                                "
	dc.b "   THE CAREBEARS,THE OVERLANDERS,THE LOST BOYS  "
	dc.b "   PHOENIX(hello oxygen,sorry for the line rout "
	dc.b "   but mine is now better!!!),THE GUILD(but not "
	dc.b "   samos,you're not good, but your neighbour    "
	dc.b "   is M.CODER),specialy FIREHAWKS & TLZ(hello   "
	dc.b "   l'aventurier, do you like this demo?),TEX    "
	dc.b "   (and the etrenal BIG DEMO),thank for all     "
	dc.b "   THALION PROD.,and of course all MB members.  "
	dc.b "                                                "
	dc.b "************************************************"
	
	dc.b "************************************************"
	dc.b "                                                "
	dc.b "        Now some information about:             "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "#### #### #### #### ####   ##    #### #   # ####"
	dc.b "#    #  # #  # #    #      # #   #    ## ## #  #"
	dc.b "#    #  # #  # #    #      #  #  #    # # # #  #"
	dc.b "#### #### #  # #    ###    #   # ##   #   # #  #"
	dc.b "   # #    #### #    #      #   # #    #   # #  #"
	dc.b "   # #    #  # #    #      #   # #    #   # #  #"
	dc.b "#### #    #  # #### ####   ####  #### #   # ####"
	dc.b "                                                "
	dc.b "         (PrinST :- why space?                  "
	dc.b "          EverST :- for the space bar !! no?)   "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "        (A new production MegaBuSTers.)         "
	dc.b "                                                "
	dc.b "************************************************"
	
	
	dc.b "************************************************"
	dc.b "                                                "
	dc.b "                  MAGNIFIER                     "
	dc.b "          ______________________                "
	dc.b "                                                "
	dc.b "CODE     :DJAYBEE      SOUND: MAD MAX           "
	dc.b "GRAPHIXX :WANTED       THANK: WANTED            "
	dc.b "                                                "
	dc.b " start coding:05/02/91                          "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "  Thank to wanted, because ,for make the graphix"
	dc.b " with 32 color, he have make 2 16 color pictures"
	dc.b " and it was perfectly synchronised!!!!!         "
	dc.b "                                                "
	dc.b "         sorry for the hard read scroll..       "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "                MAIN MENU                       "
	dc.b "          ______________________                "
	dc.b "                                                "
	dc.b "CODE     :DJAYBEE      SOUND: MAD MAX           "
	dc.b "GRAPHIXX :GRIZZO       THANK: GUNSTICK          "
	dc.b "                                                "
	dc.b " start coding: 04/04/91                         "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "   Very long work but very good result!!!!      "
	dc.b " sorry Tronic,at the start you want make the    "
	dc.b " main menu,but mine is finish before!!!         "
	dc.b "                                                "
	dc.b "   thank to GUNSTICK and this friendship...     "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "           Stars-Scrolls-Screen                 "
	dc.b "          ______________________                "
	dc.b "                                                "
	dc.b "CODE     :JAILE        SOUND:MAD MAX            "
	dc.b "GRAPHIXX :JAILE        THANK:MY BROTHER         "
	dc.b "                                                "
	dc.b " start coding:18/04/91                          "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "       It isn't a new quick polyfill routine    "
	dc.b " for the vu-meter. But a great MOVE.W code...   "
	dc.b "                                                "
	dc.b "     That's my second screen.                   "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "               ROBOZOOM                         "
	dc.b "          ______________________                "
	dc.b "                                                "
	dc.b "CODE     :JAILE       SOUND:MAD MAX             "
	dc.b "GRAPHIXX :WASP,BINOUIT,MOBY DICK                "
	dc.b "THANK    :A GRAPHIST OF OCEAN                   "
	dc.b "                                                "
	dc.b " start coding:15/06/91                          "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "         Don't you regognize the good old face  "
	dc.b "  of ROBOCOP ??                                 "
	dc.b "         If not,open your eyes and your         "
	dc.b "  Imagination !!!!!                             "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                U B Y S S I                     "
	dc.b "          ______________________                "
	dc.b "                                                "
	dc.b "CODE     :OXWALD       SOUND:MAD MAX            "
	dc.b "GRAPHIXX :All MB gfx   THANK:My Imagination     "
	dc.b "                                                "
	dc.b " start coding: 01/03/90                         "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "      Original idea no?                         "
	dc.b "                                                "
	dc.b "       no?                                      "
	dc.b "                                                "
	dc.b "       no...                                    "
	dc.b "                                                "
	dc.b "       perhaps!!!!                              "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "              LOADING & DISK PACKAGE            "
	dc.b "              ______________________            "
	dc.b "                                                "
	dc.b "CODE     : PrinST & Tronic                      "
	dc.b "                                                "
	dc.b "                                                "
	dc.b " start coding: 15/03/91                         "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "  Sorry of this lamer loader...                 "
	dc.b "   at the start TRONIC make a realy greet loader"
	dc.b "  but it's so big and the space demo don't run  "
	dc.b "  on the 520 STF... so i have make this micro-  "
	dc.b "  loader. escuse me for the supression...       "
	dc.b "        (have you look the boot?)               "
	dc.b "      thank for your good routines TRONIC       "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "              MOVING LOGO VU                    "
	dc.b "          ______________________                "
	dc.b "                                                "
	dc.b "CODE     : Tronic      SOUND: MAD MAX           "
	dc.b "GRAPHIXX : Christo     THANK: Christo           "
	dc.b "                                                "
	dc.b " start coding: 10/09/90                         "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "    greating to christo for the original concept"
	dc.b "                                                "
	dc.b "  and computer !!!                              "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "              INTRO SCREEN                      "
	dc.b "           -------------------                  "
	dc.b "                                                "
	dc.b "CODE     :TRONIC       SOUND:MAD MAX            "
	dc.b "GRAPHIXX :CHRISTO      THANK:JAILE              "
	dc.b "                                                "
	dc.b "  start coding:07/06/91                         "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "       A big think to Mad Max music code,       "
	dc.b " half digit including in 2 full days of hard    "
	dc.b " work...                                        "
	dc.b "       The first sync-full-half digit screen.   "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "          ENJOY THE COKE SCREEN!!               "
	dc.b "          ______________________                "
	dc.b "                                                "
	dc.b "CODE     :EverST        SOUND: MAD MAX          "
	dc.b "GRAPHIXX :EverST        THANK: COCA COLA        "
	dc.b "                                                "
	dc.b " start coding: 30/04/91                         "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "   an other coproduction  EverST & PrinST...    "
	dc.b "      (after the screen for zombi crew)         "
	dc.b "                                                "
	dc.b "   we have make this screen for give you us     "
	dc.b "devotion of COKE,the best drink when we code.   "
	dc.b "so in normal time: COKE FOR CODE   but now      "
	dc.b "                   CODE FOR COKE   !!!!!        "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "             GREETING SCREEN                    "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "   CODE     : PrinST      SOUND: Mad Max        "
	dc.b "   GRAPHIXX : Wanted      THANK: L'aventurier   "
	dc.b "                                                "
	dc.b "  start coding:25/09/90                         "
	dc.b "                                                "
	dc.b "  Special note of creators:                     "
	dc.b "   That a very old creations of MB.In the text  "
	dc.b "   you cant read 3 different messages...        "
	dc.b "   a good resume of the MB life!                "
	dc.b "   But technicaly that a bad screen,b'cause     "
	dc.b "   that's the third demo that i have coded!!!   "
	dc.b "   thank to l'aventurier for the ripp of        "
	dc.b "   musixx...                                    "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "           THE TRIDI-BALLS                      "
	dc.b "          ______________________                "
	dc.b "                                                "
	dc.b "  CODE     :PrinST       SOUND:MAD MAX          "
	dc.b "  GRAPHIXX :Wanted       THANK:RED SECTOR       "
	dc.b "                                                "
	dc.b "  start coding:15/08/91                         "
	dc.b "                                                "
	dc.b "  Special note of creators:                     "
	dc.b "                                                "
	dc.b "    Very lamer TRIDI BALLS,that's my frist      "
	dc.b "  no precalculed tridi...                       "
	dc.b "  But now i'm better and i wan code a real tridi"
	dc.b "  screen,with line,polyfill,circle & balls!     "
	dc.b "                                                "
	dc.b "        I hope give you it,in the mext MB       "
	dc.b "                 creartion!!                    "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "              THE TRIDI SCROLL                  "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "CODE     : PrinST      SOUND: LAP               "
	dc.b "GRAPHIXX : Moby dick   THANK: TRONIC            "
	dc.b "                                                "
	dc.b " start coding: 11/02/91                         "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "   Have you press F1,F2,F3,F4,F5,F6,F7 ?        "
	dc.b "  b'cause the frist scroll is bad!!!            "
	dc.b "  this screen was so quicly coded,so i'm        "
	dc.b "  sorry for some bugg...(3 DAYS of hard work)   "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "                 MEGA-SCROLL                    "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "CODE     :PrinST     SOUND:MAD MAX (the alone)  "
	dc.b "GRAPHIXX :PrinST     THANK:Wanted,Tronic,Djaybee"
	dc.b "                                                "
	dc.b "  start coding:10/05/91                         "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "   Please don't say :<<good, but the random star"
	dc.b "   have a bad flashing!.>> no!!! they shine in  "
	dc.b "   in the sky, so, the shine in my screen!!!!   "
	dc.b "                                                "
	dc.b "   Excuse me for the graphix,but i'm not a greet"
	dc.b "   artist!!!                                    "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "             THE HIDDEN SCREEN                  "
	dc.b "          ______________________                "
	dc.b "                                                "
	dc.b "CODE     :PrinST       SOUND:NICE HIPPEL (M.M.) "
	dc.b "GRAPHIXX :MOBY DICK    THANK:Tronic             "
	dc.b "                                                "
	dc.b " start coding:05/07/91                          "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "                                                "
	dc.b "       Coded in 4 Hours!!!!                     "
	dc.b "  How to use this screen:                       "
	dc.b "      Help => go in random start draw.          "
	dc.b "      Space=> go in main menu!!!                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "                RESET SCREEN                    "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "CODE     : PrinST      SOUND: MadMax            "
	dc.b "GRAPHIXX : PrinST      THANK: Tronic & Djaybee  "
	dc.b "                                                "
	dc.b " start coding:05/05/91                          "
	dc.b "                                                "
	dc.b " Special note of creators:                      "
	dc.b "      my last screen for this demo.coding in 3  "
	dc.b "      days...                                   "
	dc.b "      One special think to my sister            "
	dc.b "       and this support...                      "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "################################################"
	dc.b "         now some information about:            "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                *** * * ***                     "
	dc.b "                 *  * * *                       "
	dc.b "                 *  *** **                      "
	dc.b "                 *  * * *                       "
	dc.b "                 *  * * ***                     "
	dc.b "                                                "
	dc.b "   *   * *** **** *** *** * * ****** *** *** ***"
	dc.b "   ** ** *   *    * * * * * * *   *  *   * * *  "
	dc.b "   * * * **  * ** *** **  * * *** *  **  **  ***"
	dc.b "   *   * *   *  * * * * * * *   * *  *   * *   *"
	dc.b "   *   * *   *  * * * * * * *   * *  *   * *   *"
	dc.b "   *   * *** **** * * *** *** *** *  *** * * ***"
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "################################################"

	dc.b "************************************************"
	dc.b "                                                "
	dc.b "  The actual members are:                       "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "    CODERS   : Djaybee(DJB),EverST,Jaile,Oxwald,"
	dc.b "                                                "
	dc.b "               Tronic & PrinST.                 "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "    GRAPHIXX : Binouit,Christo,Grizzo,Moby dick,"
	dc.b "                                                "
	dc.b "               Ultimazozor,Wanted,Wasp.         "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "    ZICOKS(?): The Ironside.                    "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "    MORAL SUP: OUTLAW(all other were suprimed.) "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "  The long story of my pseudo life(PrinST)      "
	dc.b "                                                "
	dc.b " start with a old and bad crew: EXCALIBUR crew  "
	dc.b "                                                "
	dc.b " In this crew we are 9 , 2GFA-CODERS & 2GRAPHS  "
	dc.b "                                                "
	dc.b " and 5 moral support(in reality lamers),but     "
	dc.b "                                                "
	dc.b " after some time, we dead b'cause of no         "
	dc.b "                                                "
	dc.b " productivity.                                  "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "  I make a other crew : EQUINOX (12 members)    "
	dc.b "                                                "
	dc.b " But an other crew ( the real EQUINOX )existed  "
	dc.b "                                                "
	dc.b " before.  So i created The MegaBuSTers          "
	dc.b "************************************************"
		
	dc.b "************************************************"
	dc.b "    ( or M.B. and not TMB,The Midway Boys )     "
	dc.b "                                                "
	dc.b " in this crew at the start we are 27.But        "
	dc.b "                                                "
	dc.b " a greet number of lamer were in the crew...    "
	dc.b "                                                "
	dc.b " we have integret the Flying Wales,and i        "
	dc.b "                                                "
	dc.b " supprime some lamers. after the first          "
	dc.b "                                                "
	dc.b " suppretion, we are 21. But Djaybee,in start    "
	dc.b "                                                "
	dc.b " a STOS CODER of Flying wales,and now a greet   "
	dc.b "                                                "
	dc.b " asm coder said:<<I WANT 0 LAMERS IN THE CREW >>"
	dc.b "                                                "
	dc.b "  and force only 15 members in crew.            "
	dc.b "                                                "
	dc.b "************************************************"

	dc.b "************************************************"
	dc.b "  they want no ' moral support ' that's good    "
	dc.b "                                                "
	dc.b " (b'cause they are lamers,and bad for the crew.)"
	dc.b "                                                "
	dc.b " But Outlaw was rested.That's a founder of the  "
	dc.b "                                                "
	dc.b " Crew and a greet helper of no technical        "
	dc.b "                                                "
	dc.b " problem. He make the taxi and organisater of   "
	dc.b "                                                "
	dc.b " the greet MB reunion.                          "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "  We are in all france and we have some problem "
	dc.b "                                                "
	dc.b " communication. The MB reunion are very         "
	dc.b "                                                "
	dc.b " important for link the crew...    PrinST of MB "
	dc.b "************************************************"

	dc.b "                                                "
	dc.b "                                                "
	dc.b "           Here is a list of persons            "
	dc.b "            (dead or alive) that i              "
	dc.b "             would like to thank                "
	dc.b "                for they work                   "
	dc.b "                   pictures                     "
	dc.b "                    musics                      "
	dc.b "                    humour                      "
	dc.b "                 and so on...                   "
	dc.b "              (no special order)                "
	dc.b "                                                "
	dc.b "  Coluche,R.Macdan,J.M.Jare,Vangelis,R.hubbard  "
	dc.b "   J.Hippel,J.R.R.Tolken,G.Gygax,P.& M.Currie   "
	dc.b "     A.Einstein,S.Spilberg,W.Disney,D.Lynch     "
	dc.b "                  S.Tramiel...                  "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	dc.b "                                                "
	
	dc.b "************************************************"
	dc.b " Some special think to ST CONNEXION:            "
	dc.b "                                                "
	dc.b " have you like this demo? thank for all...      "
	dc.b "                                                "
	dc.b "     I'm a english's lamer so escuse me for the "
	dc.b "                                                "
	dc.b " bad english TEXT ... We are FRENCH People !!!  "
	dc.b "                                                "
	dc.b "        (us next demo is surly realy better!)   "
	dc.b "                                                "
	dc.b "                                                "
	dc.b " thank for you attention and i hope see you soon"
	dc.b "                                                "
	dc.b "   PrinST of the #   #    ###                   "
	dc.b "                 ## ##    #  #                  "
	dc.b "                 # # # ** ###   crew.           "
	dc.b "                 #   # ** #  #                  "
	dc.b "                 #   #    ####                  "
	dc.b "************************************************"
endpage

;==============================	
	section	bss
;==============================
	even
adrful	ds.l 1
adrtxt	ds.l 1
adrons	ds.l 1
adrpos	ds.l 1
possync	ds.l 1
adrscr	ds.l 1
comp	ds.w 1
savpal	ds.w 16
table	ds.w 236
xco	ds.b 1
yco	ds.b 1
vff8201	ds.b 1
vff8203	ds.b 1
guide	ds.b 1
	even
fullscr	ds.b 230*400
endbss
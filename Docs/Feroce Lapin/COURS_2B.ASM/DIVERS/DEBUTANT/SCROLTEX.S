**********************************************************
*     SCROLLING DE TEXTES. METHODE UTILISEE PAR TEX      *
*  CETTE METHODE EST TRES DIFFERENTE DE CELLE DE KERMIT  *
**********************************************************

* Commentaires par Le F‚roce Lapin (from 44E)

* INITIALISATION
charset 	EQU  	$70000    adresse de d‚but de l'‚cran
* qui contient les caractŠres
     
HAUTEUR   	EQU	32      hauteur pour les lettres

CREATION:  MOVEQ   #5,D0          Il y a 6 lignes de caractŠres sur l'‚cran
     	LEA     TABLEAU,A0     tableau c'est 64 long word pour faire 
* des pointeurs sur les diff‚rents caractŠres.
     	MOVE.L  	#CHARSET,D2 adresse de l'‚cran des lettres
PARAMETrecolonne:    MOVE.W	#9,D1	et 10 paramŠtre colonnes (on est en 
basse r‚solution
* il y a donc 10 lettres c“te … c“te, donc 32 pixels de large)
LIGNE:     MOVE.L	D2,(A0)+    Nous allons d'abord cr‚er une table avec
* des pointeurs sur chaque caractŠres
	ADD.L      #16,D2     des pointeurs sur chaque caractŠre.
           DBF     	D1,LIGNE    ;(These are 32 pixels wide = $10)
     	ADD.L   	#HAUTEUR*160-160,d2  ;(and 32 pixels in height)
     	DBF	D0,paramŠtrecolonne

	MOVE.W  	#HAUTEUR,ZANZ     nombre de lignes


* Apr‚s l'initialisation il ne reste plus qu'… merger la routine
* interupt dans le syst‚me.

	MOVE.L	#IRQ,$4D2

* Maintenant le programme principal peux faire ce qu'il veux
* puisque le scrolling est en interupt.

**************************************************
*              LA ROUTINE EN VBL                 *
**************************************************

scrollbase=$f8000        ;Pointer to screen

block0=$30000            ;Pointers to buffers
block1=$32000            ;Necessary size: height*160
block2=$34000
block3=$36000
block4=$38000
block5=$3A000
block6=$3c000
block7=$3e000

puff0=$40000             ;Pointer to data-add-on buffer
puff1=$40100             ;Necessary size: height*8
puff2=$40200
puff3=$40300
puff4=$40400
puff5=$40500
puff6=$40600
puff7=$40700
		
irq:    	MOVE.W	NR,D2           nr, c'est un compteur
           ADDQ.W	#1,NR
           AND.W   	#$F,NR          ;that is used as buffer pointer
                              ;15, because of the 32 pixels width
* On va choisir la routine. On multiplie D2 par 4 car le tableau
* des routines est en long mots.
     	ASL.W	#2,D2
     	MOVE.L	#IRQTAB,A4
     	MOVE.L	(A4,D0.W),A2   une routine pour chaque buffer
     	JMP     	(A2)           et on y saute
*-------------------------------------------------------------------------*
* Les routines appel‚es par ce jump. Elles placent en A6 le block
* source puis vont vers SHOW qui l'affiche … l'‚cran

no109:                   ;Routine for buffer 1 and 9
     move.l #block0,a6   affiche le buffer 0
     bsr    show
     move.l #block1,a6   shift le buffer 1
     move.l #puff1,a5    Pointer to data-add-on buffer
     bra    linksw

no210:                   ;analog to no109
     move.l #block1,a6   affiche le buffer 1
     bsr    show
     move.l #block2,a6   et pr‚pare le 2
     move.l #puff2,a5
     bra    linksw

no311:
     move.l #block2,a6
     bsr    show
     move.l #block3,a6
     move.l #puff3,a5
     bra    linksw

no412:
     move.l #block3,a6
     bsr    show
     move.l #block4,a6
     move.l #puff4,a5
     bra    linksw

no513:
     move.l #block4,a6
     bsr    show
     move.l #block5,a6
     move.l #puff5,a5
     bra    linksw

no614:
     move.l #block5,a6
     bsr    show
     move.l #block6,a6
     move.l #puff6,a5
     bra    linksw

no715:
     move.l #block6,a6
     bsr    show
     move.l #block7,a6
     move.l #puff7,a5
     bra    linksw
*-------------------------------------------------------------------------*
no8: move.w #8,teil      ;Second half of the 32 pixels
     move.l #block7,a6
     bsr    show
     bsr    addpuff      ;Prepare data-add-on buffer
     move.l #block0,a6
     move.l #puff0,a5
     bra    linksw
*-------------------------------------------------------------------------*
* C'est la routine qui est appel‚e en premier. Elle est ensuite appel‚e
* une fois par cycle
no0:
     move.l #block7,a6        affichage du 7 ‚me block
     bsr    show
     move.l #text,A0          Pointer to text start
     move.l #TABLEAU,A1       Pointer to conversion table
     clr.w  teil              Left half of 32 pixels
nochmal:
     move.w zeiger,D0         ;Counter in the text
     move.b 0(A0,D0.w),D1     ;Next character
noeffect:
     cmp.b  #$3f,D1           ;End found
     bne    noch2
     clr.w  zeiger            ;Start from beginning again
     bra    nochmal
noch2:
     ext.w  D1                ;Else, get pointer to character
     asl.w  #2,D1
     move.l 0(A1,D1.w),zeichen1
     addq.w #1,zeiger
     move.w zeiger,D0         ;Pointer to next character
notex:
     move.b 0(A0,D0.w),D1
     cmp.b  #$3f,D1           ;End found
     bne    noch3
     move.b (A0),D1           ;Then scroll in first character
noch3:
     ext.w  D1
     asl.w  #2,D1             ;Else pointer to 2nd character
     move.l 0(A1,D1.w),zeichen2

     bsr    addpuff           ;Prepare data-add-on buffer
     move.l #block0,a6        ;Scroll block 1
     move.l #puff0,a5

linksw:
     move.w zanz,D0           ;Number of lines
     subq.w #1,D0             ;As dbf counter
LIGNEn:
     movem.l 8(a6),D1-d7/A0-a4     ;16 pixels to the left
     movem.l D1-d7/A0-a4,(a6)      ;scroll
     movem.l 56(a6),D1-d7/A0-a4
     movem.l D1-d7/A0-a4,48(a6)
     movem.l 104(a6),D1-d7/A0-a4
     movem.l D1-d7/A0-a4,96(a6)
     add.l  #144,a6
     move.l 8(a6),(a6)+
     move.l 8(a6),(a6)+
     move.l (a5)+,(a6)+            ;Merge data-add-on buffer
     move.l (a5)+,(a6)+
     dbf   D0,LIGNEn
     rts
*-----------------------------------------------*
* On affiche maintenant le buffer qui est pr‚t.
SHOW       MOVE.W	ZANZ,D0    hauteur en D0
     	SUBQ.W	#1,D0	car travaille en DBF
     	MOVE.L	#SCROLLBASE,A5
		
SLIGNEN    MOVEM.L    (A6),D1-D7/A0-A4      pr‚lŠve 48 bytes
           MOVEM.L    D1-D7/A0-A4,(A5)      et les recopie  
           MOVEM.L    48(A6),D1-D7/A0-A4	     idem
           MOVEM.L    D1-D7/A0-A4,48(A5)
           MOVEM.L    96(A6),D1-D7/A0-A4         idem
           MOVEM.L    D1-D7/A0-A4,96(a5)
           MOVEM.L    144(A6),D4-D7     	enfin les 16 bytes restants
           MOVEM.L    D4-D7,144(A5)         donc en tout 160 bytes
	ADD.L   	#160,A6
	ADD.L      #160,A5
     	DBF	D0,SLIGNEN       ligne suivante
	RTS
*--------------------------------------------*
;Prepare data-add-on buffer
addpuff:
     MOVEM.L D0-d7/A0/A1,-(sp)
     move.w  zanz,d7
     subq.w  #1,d7             ;Line number as dbf
     move.w  teil,d6
     MOVEQ   #8,d5
     move.l  zeichen1,d4
     cmp.w   #8,d6
     bne     puffer0
     move.l  zeichen2,d5
     sub.l   d4,d5
puffer0:                      ;buffer 0 is never shifted
     move.w d7,D0
     move.l #puff0,A0
     move.l d4,A1
puff0b:                       ;only left or right half of 32
     move.l 0(A1,d6.w),(A0)+  ;pixels copied
     move.l 4(A1,d6.w),(A0)+
     add.l  #160,A1
     dbf    D0,puff0b

     move.w #$e,d2            ;7 buffers, each 2 pixels
puff1a:
     move.w d2,D0
     move.w d2,d3
     asl.w #1,D0
     move.l #puffer,A0
     move.l 0(A0,D0.w),A0     ;Buffer address to A0
     move.l d4,A1             ;Character address to A1
     move.w d7,D0             ;Line number to D0

puff1b:
     move.w 0(A1,d5.l),D1     ;Shift plane 0
     swap   D1
     move.w 0(A1,d6.w),D1
     rol.l  d3,D1
     move.w D1,(A0)+

     move.w 2(A1,d5.l),D1     ;Shift plane 1
     swap   D1
     move.w 2(A1,d6.w),D1
     rol.l  d3,D1
     move.w D1,(A0)+

     move.w 4(A1,d5.l),D1     ;Shift plane 2
     swap   D1
     move.w 4(A1,d6.w),D1
     rol.l  d3,D1
     move.w D1,(A0)+

     move.w 6(A1,d5.l),D1     ;Shift plane 3
     swap   D1
     move.w 6(A1,d6.w),D1
     rol.l  d3,D1
     move.w D1,(A0)+

     add.l  #160,A1
     dbf    D0,puff1b         ;All lines

     subq.w #2,d2
     bne    puff1a            ;All 7 buffers

     MOVEM.L (sp)+,D0-d7/A0/A1
     rts
*--------------------------------------------------------*
;The following variables are needed
nr: 	dc.w 0
zanz: 	dc.l 0
teil: 	dc.l 0
zeiger: 	dc.w 0
zeichen1:	dc.l 0
zeichen2:	dc.l 0
TABLEAU: 	DS.L	64      Space for 64 pointers to the characters

puffer: 	dc.l puff0,puff1,puff2,puff3,puff4,puff5,puff6,puff7
     
irqtab: 	dc.l no0,no109,no210,no311,no412,no513,no614,no715
        	dc.l no8,no109,no210,no311,no412,no513,no614,no715

* 3F indique la fin du texte
text: 	dc.b 0,1,2,3,4,5,6,7,8,9,10,$3f
even


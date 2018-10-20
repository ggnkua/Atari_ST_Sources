
	SECTION 	TEXT

NOMBRE	EQU	2 		;vitesse scrolling couleurs
HAUTEUR	EQU	78		;hauteur du sprite
DONNE	EQU	5		;vitesse defilement
DIVISE	EQU	HAUTEUR/48+1

          move.l     a7,a5		;Initialise le TOS 
          lea        pile,a7
          move.l     4(a5),a5     
          move.l     $c(a5),d0    
          add.l      $14(a5),d0
          add.l      $1c(a5),d0
          add.l      #$100,d0
          move.l     d0,-(sp)
          move.l     a5,-(sp)
          move       #0,-(sp)
          move       #$4a,-(sp)		;SETBLOCK
          trap       #1
          add.l      #12,sp

	dc.w	$a00a

          move	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
          clr.l     -(sp)
          move      #$20,-(sp)
          trap      #1
          addq.l    #6,sp
	move.l	d0,SSP

	movem.l	$ff8240,d0-d7
	movem.l   d0-d7,couleurs

	move.l	#pal,$45a
		
	*** SAUVER et mettre vecteurs VBL,ACIA, enlever MFPs ***
		
          move.l    $70,vbl_anc
          move.l    #vbl_new,$70
          move.l    $118,clav_anc
          move.l    #clav_new,$118
          bsr       mfp_off


	*** ANIMATION SPRITE Hx48 ***
	
	move.l	#ecran+256,d0	;adresse LOG
	and.l	#$ffffff00,d0	;divisible par 256
	move.l	d0,log		

	
UNEFOIS	move	#270,valeur
	
	***dessine sur P***

	move.l	$44e,screen	
	move.l	#tampon,a2		;sauve COORD dans TAMPON
	move.l	#sprit,a0
	move	#hauteur,d2
	move	#3,d0
	move	valeur,d1
	jsr	aff_sprit
		
	***dessine sur L***
	
	move.l	log,screen	
	move.l	#rien,a2		;sauve COORD dans RIEN
	move.l	#sprit,a0
	move	#hauteur,d2
	move	#3,d0
	move	valeur,d1
	jsr	aff_sprit
	
	jsr	echange		;(2)

LAURENT	move.l	#tampon,a0
	jsr	del_sprit		;efface DROITE=P (3)

	move.l	$44e,screen	;dessine nouveau dans P: (4)
	move.l	#tampon,a2	;sauve COORD dans TAMPON 
	move.l	#sprit,a0
	move	#hauteur,d2
	move	#3,d0
	move	#donne,d1
	sub	d1,valeur	
	move	valeur,d1
	jsr	aff_sprit

	jsr	change2		;Change2  (5)
	
	move.l	#rien,a0
	jsr	del_sprit		;efface L (6)
	
	move.l	log,screen	;dessine nouveau dans L: (7)
	move.l	#rien,a2		;sauve COORD dans RIEN
	move.l	#sprit,a0
	move	#hauteur,d2
	move	#3,d0
	move	#donne,d1
	sub	d1,valeur
	cmpi.w	#2,valeur		;on teste ici car <0 dej… l…	
	bmi	REMET		;peut-Štre ...
	move	valeur,d1
	jsr	aff_sprit
	
	jsr	echange		;echange  (8)	

	move	#$ff,-(sp)
	move	#6,-(sp)
	trap	#1
	add.l	#4,sp
	tst	d0
	bne	FIN
	
	jmp	LAURENT
		
REMET	move	valeur,d1
	jsr	aff_sprit
	jsr	echange		;On dessine qd meme (sinon clign.)
	
	move.l	#tampon,a0
	jsr	del_sprit
	
LABA	move.l	#tampon,a0
	jsr	del_sprit		;efface DROITE=P (3)
          move.l	$44e,screen	;dessine nouveau dans P: (4)
	move.l	#tampon,a2	;sauve COORD dans TAMPON 
	move.l	#sprit,a0
	move	#hauteur,d2
	move	#3,d0
	move	#donne,d1
	add	d1,valeur	
	move	valeur,d1
	jsr	aff_sprit

	jsr	change2		;Change2  (5)
	
	move.l	#rien,a0
	jsr	del_sprit		;efface L (6)
	
		
	move.l	log,screen	;dessine nouveau dans L: (7)
	move.l	#rien,a2		;sauve COORD dans RIEN
	move.l	#sprit,a0
	move	#hauteur,d2
	move	#3,d0
	move	#donne,d1
	add	d1,valeur	
	move	valeur,d1
	jsr	aff_sprit

	jsr	echange		;echange  (8)	

	cmpi.w	#270,valeur	
	bge	DODO
	jmp	LABA
		
DODO 	move.l	#tampon,a0
	jsr	del_sprit		;efface DROITE=P (3)
	
	move	#$ff,-(sp)
	move	#6,-(sp)
	trap	#1
	add.l	#4,sp
	tst	d0
	bne	FIN
          jmp	LAURENT

aff_sprit mulu      #160,d0
          move      d1,d7
          lsr       #1,d1
          add       d1,d0
          add.l     screen,d0		
          and.l     #-8,d0
          move.l    d0,a1
          move.l    a1,(a2)+
          and.l     #15,d7
          subq      #1,d2
          move      d2,d6
 
_SP1      moveq     #0,d0
          moveq     #0,d1
          moveq     #0,d2
          moveq     #0,d3

          move      (a0)+,d0
          move      (a0)+,d1
          move      (a0)+,d2
          move      (a0)+,d3

          move.l    d0,d4
          or.l      d1,d4
          or.l      d2,d4
          or.l      d3,d4
          not.l     d4

          ror.l     d7,d0
          ror.l     d7,d1
          ror.l     d7,d2
          ror.l     d7,d3
          ror.l     d7,d4

          and       d4,(a1)
          or        d0,(a1)+
          and       d4,(a1)
          or        d1,(a1)+
          and       d4,(a1)
          or        d2,(a1)+
          and       d4,(a1)
          or        d3,(a1)+

          swap      d0
          swap      d1
          swap      d2
          swap      d3
          swap      d4

          and       d4,(a1)
          or        d0,(a1)+
          and       d4,(a1)
          or        d1,(a1)+
          and       d4,(a1)
          or        d2,(a1)+
          and       d4,(a1)
          or        d3,(a1)+
        	
          ****  suite du 2 eme block et dessin du 3 eme block **** 
          
          sub.l      #8,a1	;On revient au block 2 pour le 
          			;completer...
                    	   
          moveq     #0,d0
          moveq     #0,d1
          moveq     #0,d2
          moveq     #0,d3

          move      (a0)+,d0
          move      (a0)+,d1
          move      (a0)+,d2
          move      (a0)+,d3

          move.l    d0,d4
          or.l      d1,d4
          or.l      d2,d4
          or.l      d3,d4
          not.l     d4
	
          ror.l     d7,d0
          ror.l     d7,d1
          ror.l     d7,d2
          ror.l     d7,d3
          ror.l     d7,d4
	
          *** pas de sauvegarde dans tampon pour 2 eme block de ***
          *** 16 pixels :    On a deja dessin‚ sur ce block ... ***
          
          and       d4,(a1)
          or        d0,(a1)+
          and       d4,(a1)
          or        d1,(a1)+
          and       d4,(a1)
          or        d2,(a1)+
          and       d4,(a1)
          or        d3,(a1)+

          swap      d0
          swap      d1
          swap      d2
          swap      d3
          swap      d4

          and       d4,(a1)
          or        d0,(a1)+
          and       d4,(a1)
          or        d1,(a1)+
          and       d4,(a1)
          or        d2,(a1)+
          and       d4,(a1)
          or        d3,(a1)+
    	
          ****  suite du 3 eme block et dessin du 4 eme block **** 
          
          sub.l      #8,a1	;On revient au block 3 pour le 
          			;completer...
                    	   
          moveq     #0,d0
          moveq     #0,d1
          moveq     #0,d2
          moveq     #0,d3

          move      (a0)+,d0
          move      (a0)+,d1
          move      (a0)+,d2
          move      (a0)+,d3

          move.l    d0,d4
          or.l      d1,d4
          or.l      d2,d4
          or.l      d3,d4
          not.l     d4
	
          ror.l     d7,d0
          ror.l     d7,d1
          ror.l     d7,d2
          ror.l     d7,d3
          ror.l     d7,d4
	
          *** pas de sauvegarde dans tampon pour 3 eme block de ***
          *** 16 pixels :    On a deja dessin‚ sur ce block ... ***
          
          and       d4,(a1)
          or        d0,(a1)+
          and       d4,(a1)
          or        d1,(a1)+
          and       d4,(a1)
          or        d2,(a1)+
          and       d4,(a1)
          or        d3,(a1)+

          swap      d0
          swap      d1
          swap      d2
          swap      d3
          swap      d4

          and       d4,(a1)
          or        d0,(a1)+
          and       d4,(a1)
          or        d1,(a1)+
          and       d4,(a1)
          or        d2,(a1)+
          and       d4,(a1)
          or        d3,(a1)+

          add.l     #128,a1		;160-(4*8) :4*8=4*4 mots/block
          dbf       d6,_SP1
          rts
   
          ;a0=adresse du tampon: TAMPON ou RIEN

DEL_SPRIT  movem.l	a0,-(sp)
           move	#37,-(sp)
	 trap	#14
	 add.l	#2,sp
	 movem.l  (sp)+,a0
           move.l   (a0)+,a1
           move.w   #hauteur-1,d2	;Hauteur sprite en lignes

sp2        move.l   #0,(a1)+
           move.l   #0,(a1)+
           move.l   #0,(a1)+
           move.l   #0,(a1)+
           move.l   #0,(a1)+
           move.l   #0,(a1)+
           move.l   #0,(a1)+
           move.l   #0,(a1)+
           add.l    #128,a1
           dbf       d2,sp2
           rts
	
	*** On pose DROITE sur GAUCHE ***
		
echange	move.l	log,d5		;LOG
	lsr.l	#8,d5		;MMU --> ECHANGE
	move.b	d5,$ff8203
	lsr.l	#8,d5
	move.b	d5,$ff8201
	rts

	*** On pose GAUCHE sur DROITE ***
	
change2	move.l	$44e,d5		;PHYS
	lsr.l	#8,d5		;MMU --> ECHANGE
	move.b	d5,$ff8203
	lsr.l	#8,d5
	move.b	d5,$ff8201
	rts
							         
FIN	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	
	*** REMET ancien VBL,ACIA et MFPs ***
	
          bsr       mfp_on
          move.l    vbl_anc,$70
          move.l    clav_anc,$118

	dc.w	$a009
	
	movem.l	couleurs,d0-d7
	movem.l	d0-d7,$ff8240
	
          move.l	SSP,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	move	#0,-(sp)
	trap	#1


	*** Enlever les Timers A-D ***
	
mfp_off   move.b    $fffa07,save_iera
          clr.b     $fffa07
          move.b    $fffa09,save_ierb
          clr.b     $fffa09
          move.b    $fffa13,save_imra
          move.b    $fffa1b,save_tbcr
          move.b    $fffa21,save_tbdr
          move.l    $100+8*4,timb_anc
          clr.b     $fffa1b
          bset      #0,$fffa07
          bset      #0,$fffa13
          bset      #6,$fffa09
          move.l    #timb_new,$100+8*4
          rts

	*** Restaurer les Timers A-D ***
	
mfp_on    bclr      #0,$fffa07
          move.b    save_imra,$fffa13
          move.b    save_tbcr,$fffa1b
          move.b    save_tbdr,$fffa21
          move.l    timb_anc,$100+8*4
          move.b    save_iera,$fffa07
          move.b    save_ierb,$fffa09
          rts


	*** Nouveau TIMER B ***


timb_new  movem.l   d0/a1,-(sp)
          lea       colors,a1
          add.l	index,a1
          move      (a1)+,$ff8242	;empile ds 3 registres
          move      (a1)+,$ff8244
          move      (a1)+,$ff8246          
          add.l	#6,index  	
          movem.l   (sp)+,d0/a1
          bclr      #0,$fffa0f
          subq      #1,compteur
          bne       timb_fin
          clr.b     $fffa1b
timb_fin  rte

vbl_new   clr.b     $fffa1b
          add.l	#nombre,suivant
          move.l	suivant,index
          cmpi.l	#512*2,suivant
          blt	encore
          move.l	#0,suivant
	
encore    move      #64,compteur
          move.b    #3,$fffa21
          move.b    #8,$fffa1b
          move.l    vbl_anc,-(sp)
          rts

clav_new  move    d0,-(sp)
          move    sr,d0
          andi    #$f8ff,d0
          ori     #$0500,d0
          move    d0,sr
          move    (sp)+,d0
          move.l  clav_anc,-(sp)
          rts

	SECTION	DATA
   
PAL	dc.w      $0000,$0700,$0000,$0750,$000,$0470,$0070,$0075
          dc.w      $0077,$0057,$0027,$0007,$0507,$0707,$0704,$0777

SPRIT	REPT	DIVISE
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF,$0000,$0000,$FFFF,$FFFF,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000,$0000
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$0000,$FFFF,$0000,$0000,$0000,$FFFF,$0000,$0000
	dc.w	$FFFF,$FFFF HERESVILLE                                                     CITYMCRP       ˆ   ið    Ÿåä Ÿòi                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
 	                       	        
                                                                                                                                                                                                                                                                                           ( ( ( ( ( ( ( ( ( ( ( ( ' ( ( ( ( ( ( ( ( ' ( ( ( ( ( ( ' ( ( ( ( ' ( ) ) ) ) ( ) ) ) * * * * * * * * * * * * * * * * ) ( ( ( ( ( ( ( ) * + , . 0 0 0 1 2 3 5 6 6 6 6 6 5 4 3 2 0 - * &                                                       ( ( ( ) * ( 5 *                                                                                                                                                                                                                                 } } } } } } { { { { { { { { { {0,$241,$242,$243,$244,$245,$246,$247
          dc.w      $250,$251,$252,$253,$254,$255,$256,$257
          dc.w      $260,$261,$262,$263,$264,$265,$266,$267
          dc.w      $270,$271,$272,$373,$274,$275,$276,$277

          dc.w      $300,$301,$302,$303,$304,$305,$306,$307
          dc.w      $310,$311,$312,$313,$314,$315,$316,$317
          dc.w      $320,$321,$322,$323,$324,$325,$326,$327
          dc.w      $330,$331,$332,$333,$334,$335,$336,$337
          dc.w      $340,$341,$342,$343,$344,$345,$346,$347
          dc.w      $350,$351,$352,$353,$354,$355,$356,$357
          dc.w      $360,$361,$362,$363,$364,$365,$366,$367
          dc.w      $370,$371,$372,$373,$374,$375,$376,$377

          dc.w      $400,$401,$402,$403,$404,$405,$406,$407
          dc.w      $410,$411,$412,$413,$414,$415,$416,$417
          dc.w      $420,$421,$422,$423,$424,$425,$426,$427
          dc.w      $430,$431,$432,$433,$434,$435,$436,$437
          dc.w      $440,$441,$442,$443,$444,$445,$446,$447
          dc.w      $450,$451,$452,$453,$454,$455,$456,$457
          dc.w      $460,$461,$462,$463,$464,$465,$466,$467
          dc.w      $470,$471,$472,$473,$474,$475,$476,$477

          dc.w      $500,$501,$502,$503,$504,$505,$506,$507
          dc.w      $510,$511,$512,$513,$514,$515,$516,$517
          dc.w      $520,$521,$522,$523,$524,$525,$526,$527
          dc.w      $530,$531,$532,$533,$534,$535,$536,$537
          dc.w      $540,$541,$542,$543,$544,$545,$546,$547
          dc.w      $550,$551,$552,$553,$554,$555,$556,$557
          dc.w      $560,$561,$562,$563,$564,$565,$566,$567
          dc.w      $570,$571,$572,$573,$574,$575,$576,$577

          dc.w      $600,$601,$602,$603,$604,$605,$606,$607
          dc.w      $610,$611,$612,$613,$614,$615,$616,$617
          dc.w      $620,$621,$622,$623,$624,$625,$626,$627
          dc.w      $630,$631,$632,$633,$634,$635,$636,$637
          dc.w      $640,$641,$642,$643,$644,$645,$646,$647
          dc.w      $650,$651,$652,$653,$654,$655,$656,$657
          dc.w      $660,$661,$662,$663,$664,$665,$666,$667
          dc.w      $670,$671,$672,$673,$674,$675,$676,$677

          dc.w      $700,$701,$702,$703,$704,$705,$706,$707
          dc.w      $710,$711,$712,$713,$714,$715,$716,$717
          dc.w      $720,$721,$722,$723,$724,$725,$726,$727
          dc.w      $730,$731,$732,$733,$734,$735,$736,$737
          dc.w      $740,$741,$742,$743,$744,$745,$746,$747
          dc.w      $750,$751,$752,$753,$754,$755,$756,$757
          dc.w      $760,$761,$762,$763,$764,$765,$766,$767
          dc.w      $770,$771,$772,$773,$774,$775,$776,$777

	; suite pour remontage
	
	dc.w      $000,$001,$002,$003,$004,$005,$006,$007
          dc.w      $010,$011,$012,$013,$014,$015,$016,$017
          dc.w      $020,$021,$022,$023,$024,$025,$026,$027
          dc.w      $030,$031,$032,$033,$034,$035,$036,$037
          dc.w      $040,$041,$042,$043,$044,$045,$046,$047
          dc.w      $050,$051,$052,$053,$054,$055,$056,$057
          dc.w      $060,$061,$062,$063,$064,$065,$066,$067
          dc.w      $070,$071,$072,$073,$074,$075,$076,$077

          dc.w      $100,$101,$102,$103,$104,$105,$106,$107
          dc.w      $110,$111,$112,$113,$114,$115,$116,$117
          dc.w      $120,$121,$122,$123,$124,$125,$126,$127
          dc.w      $130,$131,$132,$133,$134,$135,$136,$137
          dc.w      $140,$141,$142,$143,$144,$145,$146,$147
          dc.w      $150,$151,$152,$153,$154,$155,$156,$157
          dc.w      $160,$161,$162,$163,$164,$165,$166,$167
          dc.w      $170,$171,$172,$173,$174,$175,$176,$177

          dc.w      $200,$201,$202,$203,$204,$205,$206,$207
          dc.w      $210,$211,$212,$213,$214,$215,$216,$217
          dc.w      $220,$221,$222,$223,$224,$225,$226,$227
          dc.w      $230,$231,$232,$233,$234,$235,$236,$237
          dc.w      $240,$241,$242,$243,$244,$245,$246,$247
          dc.w      $250,$251,$252,$253,$254,$255,$256,$257
          dc.w      $260,$261,$262,$263,$264,$265,$266,$267
          dc.w      $270,$271,$272,$373,$274,$275,$276,$277

	SECTION 	BSS
	
	ds.l	512
pile
ssp	ds.l	1

vbl_anc   ds.l      1
clav_anc  ds.l      1
timb_anc  ds.l      1
save_iera ds.b      1
save_ierb ds.b      1
save_imra ds.b      1
save_tbcr ds.b      1
save_tbdr ds.b      1
	EVEN
compteur  ds.w      1
index     ds.l      1
suivant	ds.l	1

couleurs  ds.l	8
tampon    ds.b      30*30+16
rien	ds.b      30*30+16
	EVEN
ecran	ds.b	32256
log	ds.l	1
valeur	ds.w	1
screen	ds.l	1

	END


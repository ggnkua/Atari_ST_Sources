;                        sorry for the french coments, 
;                        but i haven't time to translate it.
;                        
;                        i have see you first screens, and i think
;                        it's a good begining, i hope this sources
;                        from my CSF hidden screen, should help 
;                        you.
;
;                        it will be compiled with the GENST 2.23 
;                        develloper or more...
;
;                        
;
;
;
;
;
;


;
;               FIRST TRIDI POLYFILL...
;               =======================
;
;debut          : 30/07/92
;derniere modif : 30/07/92 
;
;fichiers a inclure     :-cosin   .inc
;
;remarque:      il est possible de connaitre la qualite du rafraichisement 
;(50 Hz/25 Hz/16 Hz...) en definissant VBLTIM egal a 1 
; VBLTIM juste ici dessous:
VBLTIM  =       0
; ainsi que le temps dans la VBL avec ONVBL egal a 1
ONVBL   =       0
;
; redig‚ avec GENST 2.23 D    buffer editeur:150000   Tabulation :12
;
;       code de PrinST pour the MegaBusters
;	opt     o+
;==========================================================================
;
;                  ici les "MACRO"
;       (ne pas oublier incbiner le fichier cosin.inc
;                 sous l'etiquette trigo...)
;
;==========================================================================
;====================================
;       rotation spaciales
;====================================
;
;       parametre:      d0: X spacial 
;               d1: Y spacial
;               d2: Z spacial
;               d3: Angle de rotation sur Z
;               d4: Angle de rotation sur Y
;               d5: Angle de rotation sur X
;
;       retour: d0: coordonne X apres rotation
;               d1: coordonne Y apres rotation
;               d2: coordonne Z apres rotation
;
rot_3d  macro
	lea     trigo,a2
	lea     trigo+180,a3
	add     d3,d3           ; ax*2
	add     d4,d4           ; ay*2
	add     d5,d5           ; az*2
;                       rotation sur les Z
	IFEQ    \3
	move    d1,d6           ; d6=Ys
	move    (a3,d3.w),d7    ; d7=256*sin(Ax)
	muls    d7,d6           ; d6=256*Ys*sin(Ax)
	move.l  d6,a0           ; a0=256*Ys*sin(Ax)
	move    d0,d6           ; d6=Xs
	move    (a2,d3.w),d7    ; d7=256*cos(Ax)
	muls    d7,d6           ; d6=256*Xs*cos(Ax)
	add.l   d6,a0   ; a0=256(Ys*sin(Ax)+Xs*cos(Ax))
	move    d1,d6           ; d6=Ys
	move    (a2,d3.w),d7    ; d7=256*cos(Ax)
	muls    d7,d6           ; d6=256*Ys*cos(Ax)
	move.l  d6,a1           ; a1=256*Ys*cos(Ax)
	move    d0,d6           ; d6=Xs
	move    (a3,d3.w),d7    ; d7=256*sin(Ax)
	muls    d7,d6           ; d6=256*Ys*sin(Ax) 
	sub.l   d6,a1   ;a1=256(Ys*cos(Ax)-Xs*sin(Ax))
	move.l  a0,d0   ;d0=256(Ys*sin(Ax)+Xs*cos(Ax)) 
	move.l  a1,d1   ;d1=256(Ys*cos(Ax)-Xs*sin(Ax))
	lsr.l   #8,d0   ;d0=(Ys*sin(Ax)+Xs*cos(Ax))
	lsr.l   #8,d1   ;d1=(Ys*cos(Ax)-Xs*sin(Ax))
	ENDC
;                       Pareil sur les Y
	IFEQ    \2
	sub.l   #\4,d2
	move    d2,d6
	move    (a3,d4.w),d7
	muls    d7,d6
	move.l  d6,a0
	move    d0,d6
	move    (a2,d4.w),d7
	muls    d7,d6
	add.l   d6,a0
	move    d2,d6
	move    (a2,d4.w),d7
	muls    d7,d6
	move.l  d6,a1
	move    d0,d6
	move    (a3,d4.w),d7
	muls    d7,d6 
	sub.l   d6,a1
	move.l  a0,d0
	move.l  a1,d2
	lsr.l   #8,d0
	lsr.l   #8,d2
	add.l   #\4,d2
	ENDC
;                       Pareil sur les X
	IFEQ    \1
	sub.l   #\4,d2
	move    d2,d6
	move    (a3,d4.w),d7
	muls    d7,d6
	move.l  d6,a0
	move    d1,d6
	move    (a2,d4.w),d7
	muls    d7,d6
	add.l   d6,a0
	move    d2,d6
	move    (a2,d4.w),d7
	muls    d7,d6
	move.l  d6,a1
	move    d1,d6
	move    (a3,d4.w),d7
	muls    d7,d6 
	sub.l   d6,a1
	move.l  a0,d1 
	move.l  a1,d2
	lsr.l   #8,d1
	lsr.l   #8,d2
	add.l   #\4,d2
	ENDC
	endm
;===================================
;       transformation 3D->2D
;===================================
;
;       parametre:      d0: coordonne X spaciale
;               d1: coordonne Y spaciale
;               d2: coordonne Z spaciale
;       
;       retour: d3: coordonne X plane
;               d4: coordonne Y plane
;
t3d2d   macro
	move    d0,d3
	move    d1,d4
	move    d2,d0
	add     #\3,d0
	muls    d2,d3   ;calcul de Xp
	divs    d0,d3
	add.l   #\1,d3
	muls    d2,d4   ;calcul de Yp
	divs    d0,d4
	add.l   #\2,d4
	endm
;====================================
;       afficher 1 sprite
;====================================
;
;       parametre:      d0:coordonnee X
;               d1:coordonnee y
;               a0:adresse ecran
;               a1:adresse sprite
;               a5:adresse sauve adr
;
;       remarque: a0/a1/a5 entierment modifier...
;
sprite  macro
	movem.l d0-d7,-(sp)
	mulu    #160,d1
	add     d1,a0
	move    d0,d1
	and     #$f,d1
	lsr     #4,d0
	lsl     #3,d0
	add     d0,a0
	move.l  a0,(a5)+
	lsl     #8,d1
	add     d1,a1
	rept    7
	movem.l (a1)+,d0-d7
	and.l   d0,(a0)
	or.l    d1,(a0)
	and.l   d2,8(a0)
	or.l    d3,8(a0)
	lea     160(a0),a0
	and.l   d4,(a0)
	or.l    d5,(a0)
	and.l   d6,8(a0)
	or.l    d7,8(a0)
	lea     160(a0),a0
	endr
	movem.l (a1),d0-d7
	and.l   d0,(a0)
	or.l    d1,(a0)
	and.l   d2,8(a0)
	or.l    d3,8(a0)
	lea     160(a0),a0
	and.l   d4,(a0)
	or.l    d5,(a0)
	and.l   d6,8(a0)
	or.l    d7,8(a0)
	movem.l (sp)+,d0-d7
	endm

;==========================================================================
;
;
	section text
;
;
;==========================================================================
;
;       programe user
;
	moveq   #-1,d0
b       mulu    #-1,d1
	dbra    d0,b
	
	move    #0,-(sp)
	move.l  #-1,-(sp)
	move.l  #-1,-(sp)
	move    #5,-(sp)
	trap    #14
	add.l   #12,sp
	
	pea     prog
	move    #$26,-(sp)
	trap    #14
	addq.l  #6,sp
	
	clr     -(sp)
	trap    #1
prog    
;
;       programe superuser
;
	move    #$2700,sr
	move.l  $70.w,-(sp)             ;init des IT:
	move.l  #vbl,$70.w              ;  VBL
	move.l  $fffffa06.w,-(sp)       ;   &
	clr.l   $fffffa06.w             ;  MFP
	move    #$2300,sr
;
;       init les 2 ecrans
;
	bsr     initscreen
AV1 = $52b9
AV2 = $54b9
AV3 = $56b9
AV4 = $58b9
AV5 = $5ab9
AV6 = $5cb9
AV8 = $50b9
;
;       appel des sous routines de chaque objets
;

;
;       zome de test
;

;       move.l  #objet8,adrobj
;       move.l  #link8,adrlnk
;       move    #500,timer
;       bsr     obj2
;       bra     end

;
;
;
	moveq.l #1,d0
	jsr     zic
	
*************************************************
*        01er  objet:PrinST             *
*************************************************
	move.l  #objet5,adrobj
	move.l  #link5,adrlnk
	move    #500,timer
	move    #AV1,o2xadd
	move    #AV1,o2yadd
	move    #AV4,o2zadd
	bsr     obj2
	bsr     initscreen

*************************************************
*       02eme objet:le cube             *
*************************************************

	move.l  #objet2,adrobj
	move.l  #link2,adrlnk
	move    #500,timer
	move    #AV1,o2xadd
	move    #AV2,o2yadd
	move    #AV3,o2zadd
	move    #1000,timer
	bsr     obj2
	bsr     initscreen

*************************************************
*       03eme objet:les lunettes        *
*************************************************

	move.l  #objet6,adrobj
	move.l  #link6,adrlnk
	move    #500,timer
	move    #AV1,o2xadd
	move    #AV1,o2yadd
	move    #AV1,o2zadd
	bsr     obj2
	bsr     initscreen

*************************************************
*       04eme objet:le velo             *
*************************************************

*       move.l  #objet8,adrobj
*       move.l  #link8,adrlnk
*       move    #AV1,o2xadd
*       move    #AV2,o2yadd
*       move    #AV1,o2zadd
*       move    #500,timer
*       bsr     obj2
*       bsr     initscreen

*************************************************
*       05eme objet:le bonhomme         *
*************************************************

	move    #$0,$ffff8240.w
	move.l  #objet4,adrobj
	clr     oblst
	move    #500,timer
	bsr     obj3
	bsr     initscreen
	
*************************************************
*       06eme objet:le "last object"    *
*************************************************
	
	move.l  #objet3,adrobj
	move    #$ffff,oblst
	move    #1000,timer
	bsr     obj3

*************************************************
*       07eme objet:le cube plein       *
*************************************************

	bsr     initscreen
	lea     teintes1,a0
	lea     o4teintes1,a1
	moveq   #3,d0
b1      moveq   #21,d1
b2      move    (a0)+,(a1)+
	dbra    d1,b2
	dbra    d0,b1
	move    #250,timer
	bsr     obj4

*************************************************
*       08eme objet:le cube shading     *
*************************************************

	lea     teintes2,a0
	lea     o4teintes1,a1
	moveq   #3,d0
b3      moveq   #21,d1
b4      move    (a0)+,(a1)+
	dbra    d1,b4
	lea     teintes2,a0
	dbra    d0,b3
	move    #250,timer
	bsr     obj4

*************************************************
*       09eme objet:le cube multi-shading       *
*************************************************

	lea     teintes2,a0
	lea     o4teintes1,a1
	moveq   #3,d0
b5      moveq   #21,d1
b6      move    (a0)+,(a1)+
	dbra    d1,b6
	dbra    d0,b5
	move    #500,timer
	bsr     obj4

*************************************************
*       10eme objet:le cube mou         *
*************************************************

	bsr     initscreen
	clr.l   Xmvt
	clr.l   Ymvt
	clr.l   Zmvt
	move    #1000,timer
	bsr     obj5
	
*************************************************
*       11eme objet:la balle multipolyfill      *
*************************************************

	bsr     obj1


;
;       programe fini ici
;
end     move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move    #$2700,sr
	move.l  (sp)+,$fffffa06.w       ; on rend les ITs...
	move.l  (sp)+,$70.w
	move.l  $44e.w,d0
	lsr     #8,d0
	move.l  d0,$ffff8200.w
	move    #$2300,sr
	lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a1)+,(a0)+
	endr
	move    #$0777,$ffff8240.w
	move.l  #$08000000,$ffff8800.w
	move.l  #$09000000,$ffff8800.w
	move.l  #$0a000000,$ffff8800.w
	rts
;
;       routines pour chaque objets ici
;

;
;       1er objet: la grosse boule
;
obj1
;
;       modification palette de couleur
;
	lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a0)+,(a1)+
	endr
	lea     $ffff8240.w,a0
	move.l  #$00000337,(a0)+
	move.l  #$07730773,(a0)+
	move.l  #$03730373,(a0)+
	move.l  #$03730373,(a0)+
	move.l  #$07550755,(a0)+
	move.l  #$07550755,(a0)+
	move.l  #$07550755,(a0)+
	move.l  #$07550755,(a0)+
;
;       initialisation de la 3d
;
	move    #22400,zoom
	move    #400,timer
	lea     objet1,a6
	lea     link1,a5
	lea     hide,a4
	
	move    (a5)+,d7
	addq    #2,a6
o1binit3d       move    (a5)+,d0
	mulu    #12,d0
	move.l  (a6,d0.w),d4
	move.l  4(a6,d0.w),d5
	move.l  8(a6,d0.w),d6
	rept    3
	move    (a5)+,d0
	mulu    #12,d0
	add.l   (a6,d0.w),d4
	add.l   4(a6,d0.w),d5
	add.l   8(a6,d0.w),d6
	endr
	asr.l   #2,d4
	asr.l   #2,d5
	asr.l   #2,d6
	move.l  d4,(a4)+
	move.l  d5,(a4)+
	move.l  d6,(a4)+
	addq    #6,a5
	dbra    d7,o1binit3d

;===================================
;       boucle principale
;===================================
o1boucle        
;
;       mouvement rotatif...
;
	cmp.b   #$1c,-$3fe.w
	beq.s   o1ok
o1zadd  addq.l  #1,Zmvt
	cmp.l   #360,Zmvt
	blt.s   o1yadd
	sub.l   #360,Zmvt
o1yadd  addq.l  #2,Ymvt
	cmp.l   #360,Ymvt
	blt.s   o1xadd
	sub.l   #360,Ymvt
o1xadd  addq.l  #3,Xmvt
	cmp.l   #360,Xmvt
	blt.s   o1ok
	sub.l   #360,Xmvt
o1ok
;
;       creer la nouvelle table avec rotation spaciale
;
	lea     objetok,a5
	lea     objet1,a6
	move    (a6)+,d7
o1rotations     move    d7,-(sp)
	move.l  (a6)+,d0
	move.l  (a6)+,d1
	move.l  (a6)+,d2
	move.l  Xmvt,d3
	move.l  Ymvt,d4
	move.l  Zmvt,d5
	rot_3d  0,0,0,1200
	move    d0,(a5)+
	move    d1,(a5)+
	move    d2,(a5)+
	move    (sp)+,d7
	dbra    d7,o1rotations
;
;       effacer l'ecran (logique)
;
	move.l  adrlog,a0
	bsr     cls
	IFNE    ONVBL
	move    $ffff8240.w,d0
	move    #$70,$ffff8240.w
	rept    130
	nop
	endr
	move    d0,$ffff8240.w
	ENDC

;
;       transformer les coordonne 3D en 2D
;
	move    objet1,d7
	lea     objetok,a0
	lea     objet2d,a1
	move    zoom,d5
o1btrans        moveq   #0,d0
	moveq   #0,d1
	moveq   #0,d2
	move    (a0)+,d0
	move    (a0)+,d1
	move    (a0)+,d2
	move    d0,d3
	move    d1,d4
	move    d2,d0
	add     d5,d0
	muls    d2,d3   ;calcul de Xp
	divs    d0,d3
	add.l   #160,d3
	muls    d2,d4   ;calcul de Yp
	divs    d0,d4
	add.l   #100,d4
	move    d3,(a1)+
	move    d4,(a1)+
	dbra    d7,o1btrans

o1am1   sub     #100,zoom
o1am2   cmp     #1400,zoom
o1am4   bgt.s   o1zoomon
o1am3   move    #1400,zoom
	subq    #1,timer
	bne.s   o1zoomon
	move    #$0679,o1am1
	move    #22400,o1am2+2
	move    #$4ef9,o1am3
	move.l  #o1fini,o1am3+2
	move.b  #$6d,o1am4
o1zoomon        
;
;       calcul du plan d'affichage des 4 premieres faces
;
	lea     hide,a4
	lea     link1,a5
	move    (a5)+,d7
	moveq   #35,d7
o1bhide 
	move.l  (a4)+,d0
	move.l  (a4)+,d1
	move.l  (a4)+,d2
	move.l  Xmvt,d3
	move.l  Ymvt,d4
	move.l  Zmvt,d5
	move    d7,-(sp)
	rot_3d  0,0,0,1200
	move    (sp)+,d7
	move    #0,8(a5)
	cmp     #1200,d2
	bmi.s   o1hideok
	move    #6,8(a5)
o1hideok        lea     14(a5),a5
	dbra    d7,o1bhide
;
;       afficher les polygones
;
	move.l  adrlog,a4
	lea     link1,a6
	lea     objet2d,a5
	lea     polyform1,a3
	move    (a6)+,d7
o1baffpl        move.l  a3,a1
	rept    4
	move    (a6)+,d0
	lsl     #2,d0
	move.l  (a5,d0.w),(a1)+
	endr
	move.l  a4,d0
	add     (a6)+,d0
	move.l  d0,a0   ;adresse de base
	move.l  (a6)+,a1        ;la polyfill demander
	movem.l d7/a3/a4/a5/a6,-(sp)
	bsr     DRAWER
	movem.l (sp)+,d7/a3/a4/a5/a6
	dbra    d7,o1baffpl
;
;       inverse ecran physique et logique
;
	move.l  adrlog,d0
	move.l  adrphy,adrlog
	move.l  d0,adrphy
	lsr     #8,d0
	move.l  d0,$ffff8200.w
	IFNE    ONVBL
	move    $ffff8240.w,d0
	move    #$700,$ffff8240.w
	rept    130
	nop
	endr
	move    d0,$ffff8240.w
	ENDC
;
;       attendre la synchro spot TV
;
	IFNE VBLTIM = 1
	move    nb2vbl,d0
	lsl     #4,d0
	move.l  adrphy,a0
	lea     vblcom,a1
	add     d0,a1
	move    (a1)+,(a0)
	move    (a1)+,160*1(a0)
	move    (a1)+,160*2(a0)
	move    (a1)+,160*3(a0)
	move    (a1)+,160*4(a0)
	move    (a1)+,160*5(a0)
	move    (a1)+,160*6(a0)
	move    (a1)+,160*7(a0)
	ENDC
	move.b  #$ff,vblflg
o1vsync tst.b   vblflg
	bne.s   o1vsync         
	IFNE VBLTIM     = 1
	clr     nb2vbl
	ENDC
;
;       espace? sinon on recomence!!!
;
	cmp.b   #$39,$fffffc02.w
	bne     o1boucle
o1fini  lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a1)+,(a0)+
	endr
	rts
;
;       2eme objet: le fil de fer
;
;
;       modification palette de couleur
;
obj2    lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a0)+,(a1)+
	endr
	lea     $ffff8240.w,a0
	move.l  #$00000777,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
;===================================
;       boucle principale
;===================================
o2boucle        
;
;       mouvement rotatif...
;
	cmp.b   #$1c,-$3fe.w
	beq.s   o2ok
o2zadd  addq.l  #1,Zmvt
	cmp.l   #360,Zmvt
	blt.s   o2yadd
	sub.l   #360,Zmvt
o2yadd  addq.l  #2,Ymvt
	cmp.l   #360,Ymvt
	blt.s   o2xadd
	sub.l   #360,Ymvt
o2xadd  addq.l  #3,Xmvt
	cmp.l   #360,Xmvt
	blt.s   o2ok
	sub.l   #360,Xmvt
o2ok
;
;       creer la nouvelle table avec rotation spaciale
;
	lea     objetok,a5
	move.l  adrobj,a6
	move    (a6)+,d7
o2rotations     move    d7,-(sp)
	move.l  (a6)+,d0
	move.l  (a6)+,d1
	move.l  (a6)+,d2
	move.l  Xmvt,d3
	move.l  Ymvt,d4
	move.l  Zmvt,d5
	rot_3d  0,0,0,400
	move    d0,(a5)+
	move    d1,(a5)+
	move    d2,(a5)+
	move    (sp)+,d7
	dbra    d7,o2rotations
;
;       effacer l'ecran (logique)
;
	move.l  adrlog,a0
	bsr     cls2
	IFNE    ONVBL
	move    $ffff8240.w,d0
	move    #$70,$ffff8240.w
	rept    130
	nop
	endr
	move    d0,$ffff8240.w
	ENDC

;
;       transformer les coordonne 3D en 2D
;
	move.l  adrobj,a0
	move    (a0),d7
	lea     objetok,a0
	lea     objet2d,a1
o2btrans        moveq   #0,d0
	moveq   #0,d1
	moveq   #0,d2
	move    (a0)+,d0
	move    (a0)+,d1
	move    (a0)+,d2
	t3d2d   160,100,800
	move    d3,(a1)+
	move    d4,(a1)+
	dbra    d7,o2btrans     
;
;       afficher les lignes
;
	move.l  adrlog,a4
	move.l  adrlnk,a6
	lea     objet2d,a5
	move    (a6)+,d7
o2baffln        move    (a6)+,d0
	move    (a6)+,d1
	lsl     #2,d0
	lsl     #2,d1
	lea     (a5,d0.w),a1
	lea     (a5,d1.w),a2
	moveq   #0,d0
	moveq   #0,d1
	moveq   #0,d2
	moveq   #0,d3
	move    (a1)+,polyform1
	move    (a1)+,polyform1+2
	move    (a2)+,polyform1+4
	move    (a2)+,polyform1+6
	move.l  a4,a0
	movem.l d0-a1,-(sp)
	bsr     line
	movem.l (sp)+,d0-a1
	dbra    d7,o2baffln
;
;       inverse ecran physique et logique
;
	move.l  adrlog,d0
	move.l  adrphy,adrlog
	move.l  d0,adrphy
	lsr     #8,d0
	move.l  d0,$ffff8200.w
	IFNE    ONVBL
	move    $ffff8240.w,d0
	move    #$700,$ffff8240.w
	rept    130
	nop
	endr
	move    d0,$ffff8240.w
	ENDC
;
;       attendre la synchro spot TV
;
	IFNE VBLTIM = 1
	move    nb2vbl,d0
	lsl     #4,d0
	move.l  adrphy,a0
	lea     vblcom,a1
	add     d0,a1
	move    (a1)+,(a0)
	move    (a1)+,160*1(a0)
	move    (a1)+,160*2(a0)
	move    (a1)+,160*3(a0)
	move    (a1)+,160*4(a0)
	move    (a1)+,160*5(a0)
	move    (a1)+,160*6(a0)
	move    (a1)+,160*7(a0)
	ENDC
	move.b  #$ff,vblflg
o2vsync tst.b   vblflg
	bne.s   o2vsync
	IFNE VBLTIM     = 1
	clr     nb2vbl
	ENDC
;
;       espace? sinon on recomence!!!
;
	subq    #1,timer
	beq.s   o2fini
	cmp.b   #$39,$fffffc02.w
	bne     o2boucle
;
;       programe fini ici
;
o2fini  lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a1)+,(a0)+
	endr
	rts
cls2    moveq   #0,d0
	move    d0,(a0)
Z       set     8
	rept    20*200-2
	move    d0,Z(a0)
Z       set     Z+8
	endr
	rts
;
;       3eme objet: le last de la tridi bal de la space
;
obj3    move.l  #last,adrmvt
	lea     eff1,a0
	move.l  adrphy,d0
	move    #512,d1
o3remp  move.l  d0,(a0)+
	dbra    d1,o3remp
	move.l  #eff1,adrefp
	move.l  #eff2,adrefl
;
;       modification palette de couleur
;
	lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a0)+,(a1)+
	endr
	lea     $ffff8240.w,a0
	move.l  #$00000700,(a0)+
	move.l  #$07330777,(a0)+
	move.l  #$00700070,(a0)+
	move.l  #$00700070,(a0)+
	move.l  #$00700070,(a0)+
	move.l  #$00700070,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move    #-160,xdec
	lea     o3am1,a0
	lea     o3data,a1
o3cpy   move    (a1)+,(a0)+
	cmp.l   #o3enddata,a1
	bne.s   o3cpy   
	bra.s   o3boucle

o3data  addq    #1,xdec
	cmp     #160,xdec
	blt.s   o3enddata
	move    #160,xdec
	subq    #1,timer
	bne.s   o3enddata
	move    #$5379,o3am1
	move    #-160,o3am2+2
	move.b  #$6e,o3am3
	move    #$4ef9,o3am4
	move.l  #o3fini,o3am4+2
o3enddata

;===================================
;       boucle principale
;===================================
o3boucle        
;
;       mouvement rotatif...
;
o3zadd  addq.l  #1,Zmvt
	cmp.l   #360,Zmvt
	blt.s   o3yadd
	sub.l   #360,Zmvt
o3yadd  addq.l  #2,Ymvt
	cmp.l   #360,Ymvt
	blt.s   o3xadd
	sub.l   #360,Ymvt
o3xadd  addq.l  #1,Xmvt
	cmp.l   #360,Xmvt
	blt.s   o3ok
	sub.l   #360,Xmvt
o3ok
;
;       cree la nouvelle table avec rotation spaciale
;
	lea     objetok,a5
	move.l  adrobj,a6
	move    (a6)+,d7
o3rotations     move    d7,-(sp)
	move.l  (a6)+,d0
	move.l  (a6)+,d1
	move.l  (a6)+,d2
	move.l  Xmvt,d3
	move.l  Ymvt,d4
	move.l  Zmvt,d5
	rot_3d  0,0,0,400
	move    d0,(a5)+
	move    d1,(a5)+
	move    d2,(a5)+
	move    (sp)+,d7
	dbra    d7,o3rotations
;
;       tri des boules
;
	move.l  adrobj,a0
	move    (a0),d7
	lea     objetok+4,a0
o3tri   lea     (a0),a1
	move    (a0),d0
	lea     (a0),a2
	move    d7,d6
o3tri2  move    (a1),d1
	cmp     d1,d0
	blt.s   o3tri3
	lea     (a1),a2
	move    (a1),d0
o3tri3  addq.l  #6,a1
	dbra    d6,o3tri2
	subq.l  #4,a0
	subq.l  #4,a2
	move    (a2),d0
	move    (a0),(a2)+
	move    d0,(a0)+
	move    (a2),d0
	move    (a0),(a2)+
	move    d0,(a0)+
	move    (a2),d0
	move    (a0),(a2)
	move    d0,(a0)
	addq.l  #6,a0
	dbra    d7,o3tri
;
;       affichage des boules
;
	lea     gfxboule,a2
	move.l  adrlog,a3
	lea     objetok,a4
	move.l  adrefl,a5
	move.l  adrobj,a0
	move    (a0),d7
	moveq   #0,d5
	move    xdec,d5
	ext.l   d5
o3affiche       move    (a4)+,d0
	move    (a4)+,d1
	move    (a4)+,d2

	move    d0,d3
	move    d1,d4
	move    d2,d0
	add     #800,d0
	muls    d2,d3   ;calcul de Xp
	divs    d0,d3
	add.l   d5,d3
	muls    d2,d4   ;calcul de Yp
	divs    d0,d4
	add.l   #92,d4

	move.l  d3,d0
	move.l  d4,d1
	lea     (a3),a0
	lea     (a2),a1
	tst     d0
	blt     o3pspr
	cmp     #319,d0
	bgt     o3pspr
	sprite
o3pspr  dbra    d7,o3affiche
	
o3am1   addq    #1,xdec
o3am2   cmp     #160,xdec
o3am3   blt.s   o3pastop
o3am4   move    #160,xdec
	subq    #1,timer
	bne.s   o3pastop
	move    #$5379,o3am1
	move    #-160,o3am2+2
	move.b  #$6e,o3am3
	move    #$4ef9,o3am4
	move.l  #o3fini,o3am4+2
o3pastop
;
;       inverse ecran physique et logique
;
	move.l  adrlog,d0
	move.l  adrphy,adrlog
	move.l  d0,adrphy
	lsr     #8,d0
	move.l  d0,$ffff8200.w
;
;       attendre la synchro spot TV
;
	IFNE VBLTIM = 1
	move    nb2vbl,d0
	lsl     #4,d0
	move.l  adrphy,a0
	lea     vblcom,a1
	add     d0,a1
	move    (a1)+,(a0)
	move    (a1)+,160*1(a0)
	move    (a1)+,160*2(a0)
	move    (a1)+,160*3(a0)
	move    (a1)+,160*4(a0)
	move    (a1)+,160*5(a0)
	move    (a1)+,160*6(a0)
	move    (a1)+,160*7(a0)
	ENDC
	move.b  #$ff,vblflg
o3vsync tst.b   vblflg
	bne.s   o3vsync         
	IFNE VBLTIM     = 1
	clr     nb2vbl
	ENDC
;
;       effacer les boules...
;
	moveq   #0,d0
	move.l  adrobj,a0
	move    (a0),d7
	move.l  adrefp,a0
o3effacer       move.l  (a0)+,a1
	move.l  d0,160(a1)
	move.l  d0,160*2(a1)
	move.l  d0,160*3(a1)
	move.l  d0,160*4(a1)
	move.l  d0,160*5(a1)
	move.l  d0,160*6(a1)
	move.l  d0,160*7(a1)
	move.l  d0,160*8(a1)
	move.l  d0,160*9(a1)
	move.l  d0,160*10(a1)
	move.l  d0,160*11(a1)
	move.l  d0,160*12(a1)
	move.l  d0,160*13(a1)
	move.l  d0,160*14(a1)
	move.l  d0,160*15(a1)
	move.l  d0,8(a1)
	move.l  d0,160+8(a1)
	move.l  d0,8+160*2(a1)
	move.l  d0,8+160*3(a1)
	move.l  d0,8+160*4(a1)
	move.l  d0,8+160*5(a1)
	move.l  d0,8+160*6(a1)
	move.l  d0,8+160*7(a1)
	move.l  d0,8+160*8(a1)
	move.l  d0,8+160*9(a1)
	move.l  d0,8+160*10(a1)
	move.l  d0,8+160*11(a1)
	move.l  d0,8+160*12(a1)
	move.l  d0,8+160*13(a1)
	move.l  d0,8+160*14(a1)
	move.l  d0,8+160*15(a1)
	dbra    d7,o3effacer
	move.l  adrefp,d0
	move.l  adrefl,adrefp
	move.l  d0,adrefl
;
;       on fait bouger l'objet
;
	tst     oblst
	beq.s   nomvt
	move.l  adrmvt,a0
	lea     objet3+2+9*12,a1
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	cmp.l   #endlast,a0
	bne.s   o3mvt6
	lea     last,a0
o3mvt6  move.l  a0,adrmvt

;
;       espace? sinon on recomence!!!
;
nomvt   cmp.b   #$39,$fffffc02.w
	bne     o3boucle
;
;       programe fini ici
;
o3fini  lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a1)+,(a0)+
	endr
	rts
obj4
;
;       modification palette de couleur
;
	lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a0)+,(a1)+
	endr
	lea     $ffff8240.w,a0
	move.l  #$03370000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	move.l  #$00000000,(a0)+
	clr     p1s2
;===================================
;       boucle principale
;===================================
o4boucle        
;
;       mouvement rotatif...
;
	cmp.b   #$1c,-$3fe.w
	beq.s   o4ok
o4zadd  addq.l  #1,Zmvt
	cmp.l   #360,Zmvt
	blt.s   o4yadd
	sub.l   #360,Zmvt
o4yadd  addq.l  #2,Ymvt
	cmp.l   #360,Ymvt
	blt.s   o4xadd
	sub.l   #360,Ymvt
o4xadd  addq.l  #3,Xmvt
	cmp.l   #360,Xmvt
	blt.s   o4ok
	sub.l   #360,Xmvt
o4ok
;       
;       creer la nouvelle table avec rotation spaciale
;
	lea     objetok,a5
	lea     o4objet1,a6
	move    (a6)+,d7
o4rotations     move    d7,-(sp)
	move.l  (a6)+,d0
	move.l  (a6)+,d1
	move.l  (a6)+,d2
	move.l  Xmvt,d3
	move.l  Ymvt,d4
	move.l  Zmvt,d5
	rot_3d  0,0,0,400
	move    d0,(a5)+
	move    d1,(a5)+
	move    d2,(a5)+
	move    (sp)+,d7
	dbra    d7,o4rotations
;
;       gestion des faces cachees
;
	lea     o4hide,a4
	lea     o4link1,a5
	lea     linkok,a6
	move    (a5)+,d7
	move    #-1,nbpoly
o4bhide move    d7,-(sp)
	move.l  (a4)+,d0
	move.l  (a4)+,d1
	move.l  (a4)+,d2
	move.l  Xmvt,d3
	move.l  Ymvt,d4
	move.l  Zmvt,d5
	rot_3d  0,0,0,400
	move    (sp)+,d7
	cmp     #430,d2
	bmi.s   o4hideok
	move    (a5),(a6)+
	move    2(a5),(a6)+
	move    4(a5),(a6)+
	move    6(a5),(a6)+
	move    8(a5),d0
	move    d0,(a6)+
	addq    #1,nbpoly
;
;       calcul de la teinte de la face...
;
	sub     #245,d2
	lsr     #4,d2
	add     d2,d2
	add     d0,d0
	tst     d0
	bne.s   o4pp1
	lea     o4teintes1,a0
	bra.s   o4okti
o4pp1   cmp     #4,d0
	bne.s   o4pp2
	lea     o4teintes2,a0
	bra.s   o4okti
o4pp2   cmp     #8,d0
	bne.s   o4pp3
	lea     o4teintes3,a0
	bra.s   o4okti
o4pp3   lea     o4teintes4,a0
o4okti  lea     o4color,a1
	move.l  (a1,d0.w),a1
	move    (a0,d2.w),(a1)
	
o4hideok        lea     10(a5),a5
	dbra    d7,o4bhide

;
;       effacer l'ecran (logique)
;
	move.l  adrlog,a0
	lea     160*29(a0),a0
	bsr     o4cls
	IFNE    ONVBL
	move    $ffff8240.w,d0
	move    #$70,$ffff8240.w
	rept    130
	nop
	endr
	move    d0,$ffff8240.w
	ENDC

;
;       transformer les coordonne 3D en 2D
;
	move    o4objet1,d7
	lea     objetok,a0
	lea     objet2d,a1
o4btrans        moveq   #0,d0
	moveq   #0,d1
	moveq   #0,d2
	move    (a0)+,d0
	move    (a0)+,d1
	move    (a0)+,d2
	t3d2d   160,100,800
	move    d3,(a1)+
	move    d4,(a1)+
	dbra    d7,o4btrans     
;
;       afficher les polygones
;
	move.l  adrlog,a4
	lea     linkok,a6
	lea     objet2d,a5
	lea     polyform1,a3
	move    nbpoly,d7
o4baffpl        move.l  a3,a1
	rept    4
	move    (a6)+,d0
	lsl     #2,d0
	move.l  (a5,d0.w),(a1)+
	endr
	move.l  a4,d0
	add     (a6)+,d0
	move.l  d0,(a1)
	movem.l d7/a3/a4/a5/a6,-(sp)
	bsr     o4POLYFILL
	movem.l (sp)+,d7/a3/a4/a5/a6
	dbra    d7,o4baffpl
;
;       inverse ecran physique et logique
;
	move.l  adrlog,d0
	move.l  adrphy,adrlog
	move.l  d0,adrphy
	lsr     #8,d0
	move.l  d0,$ffff8200.w
	IFNE    ONVBL
	move    $ffff8240.w,d0
	move    #$700,$ffff8240.w
	rept    130
	nop
	endr
	move    d0,$ffff8240.w
	ENDC
;
;       attendre la synchro spot TV
;
	IFNE VBLTIM = 1
	move    nb2vbl,d0
	lsl     #4,d0
	move.l  adrphy,a0
	lea     vblcom,a1
	add     d0,a1
	move    (a1)+,(a0)
	move    (a1)+,160*1(a0)
	move    (a1)+,160*2(a0)
	move    (a1)+,160*3(a0)
	move    (a1)+,160*4(a0)
	move    (a1)+,160*5(a0)
	move    (a1)+,160*6(a0)
	move    (a1)+,160*7(a0)
	ENDC
;
;       synchro vbl
;
	stop    #$2300
	IFNE VBLTIM     = 1
	clr     nb2vbl
	ENDC
;
;       espace? sinon on recomence!!!
;
	subq    #1,timer
	beq.s   o4fini
	cmp.b   #$39,$fffffc02.w
	bne     o4boucle
;
;       programe fini ici
;
o4fini  lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a1)+,(a0)+
	endr
	rts
obj5
;
;       modification palette de couleur
;
	lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a0)+,(a1)+
	endr
	lea     $ffff8240.w,a0
	move.l  #$03370777,(a0)+
	move.l  #$05550555,(a0)+
	move.l  #$03330333,(a0)+
	move.l  #$03330333,(a0)+
	move.l  #$07330733,(a0)+
	move.l  #$07330733,(a0)+
	move.l  #$07330733,(a0)+
	move.l  #$07330733,(a0)+
;
;       initialisation de la 3d
;
	move.l  #o5dsttab,adrdis
	lea     o5objet1,a6
	lea     o5link1,a5
	lea     hide,a4
	
	move    (a5)+,d7
	addq    #2,a6
o5binit3d       move    (a5)+,d0
	mulu    #12,d0
	move.l  (a6,d0.w),d4
	move.l  4(a6,d0.w),d5
	move.l  8(a6,d0.w),d6
	rept    3
	move    (a5)+,d0
	mulu    #12,d0
	add.l   (a6,d0.w),d4
	add.l   4(a6,d0.w),d5
	add.l   8(a6,d0.w),d6
	endr
	asr.l   #2,d4
	asr.l   #2,d5
	asr.l   #2,d6
	move.l  d4,(a4)+
	move.l  d5,(a4)+
	move.l  d6,(a4)+
	addq    #2,a5
	dbra    d7,o5binit3d

;===================================
;       boucle principale
;===================================
o5boucle        
;
;       mouvement rotatif...
;
	cmp.b   #$1c,-$3fe.w
	beq.s   o5ok
o5zadd  addq.l  #1,Zmvt
	cmp.l   #360,Zmvt
	blt.s   o5yadd
	sub.l   #360,Zmvt
o5yadd  addq.l  #2,Ymvt
	cmp.l   #360,Ymvt
	blt.s   o5xadd
	sub.l   #360,Ymvt
o5xadd  addq.l  #3,Xmvt
	cmp.l   #360,Xmvt
	blt.s   o5ok
	sub.l   #360,Xmvt
o5ok
;       
;       creer la nouvelle table avec rotation spaciale
;
	lea     objetok,a5
	lea     o5objet1,a6
	move    (a6)+,d7
o5rotations     move    d7,-(sp)
	move.l  (a6)+,d0
	move.l  (a6)+,d1
	move.l  (a6)+,d2
	move.l  Xmvt,d3
	move.l  Ymvt,d4
	move.l  Zmvt,d5
	rot_3d  0,0,0,400
	move    d0,(a5)+
	move    d1,(a5)+
	move    d2,(a5)+
	move    (sp)+,d7
	dbra    d7,o5rotations
;
;       effacer l'ecran (logique)
;
	move.l  adrlog,a0
	lea     160*28(a0),a0
	bsr     o5cls
	IFNE    ONVBL
	move    $ffff8240.w,d0
	move    #$70,$ffff8240.w
	rept    130
	nop
	endr
	move    d0,$ffff8240.w
	ENDC

;
;       transformer les coordonne 3D en 2D
;
	move    o5objet1,d7
	lea     objetok,a0
	lea     objet2d,a1
o5btrans        moveq   #0,d0
	moveq   #0,d1
	moveq   #0,d2
	move    (a0)+,d0
	move    (a0)+,d1
	move    (a0)+,d2
	t3d2d   160,100,800
	move    d3,(a1)+
	move    d4,(a1)+
	dbra    d7,o5btrans     
;
;       gestion des faces cachees
;
	lea     hide,a4
	lea     o5link1,a5
	lea     linkok,a6
	move    (a5)+,d7
	move    #-1,nbpoly
o5bhide move    d7,-(sp)
	move.l  (a4)+,d0
	move.l  (a4)+,d1
	move.l  (a4)+,d2
	move.l  Xmvt,d3
	move.l  Ymvt,d4
	move.l  Zmvt,d5
	rot_3d  0,0,0,400
	move    (sp)+,d7
	cmp     #420,d2
	bmi.s   o5hideok
	move    (a5),(a6)+
	move    2(a5),(a6)+
	move    4(a5),(a6)+
	move    6(a5),(a6)+
	move    8(a5),d0
	move    d0,(a6)+
	addq    #1,nbpoly
o5hideok        lea     10(a5),a5
	dbra    d7,o5bhide
;
;       afficher les polygones
;
	move.l  adrlog,a4
	lea     linkok,a6
	lea     objet2d,a5
	lea     polyform1,a3
	move    nbpoly,d7
o5baffpl        move.l  a3,a1
	rept    4
	move    (a6)+,d0
	lsl     #2,d0
	move.l  (a5,d0.w),(a1)+
	endr
	move.l  a4,d0
	add     (a6)+,d0
	move.l  d0,(a1)
	movem.l d7/a3/a4/a5/a6,-(sp)
	bsr     o5POLYFILL
	movem.l (sp)+,d7/a3/a4/a5/a6
	dbra    d7,o5baffpl
;
;       inverse ecran physique et logique
;
	move.l  adrlog,d0
	move.l  adrphy,adrlog
	move.l  d0,adrphy
	lsr     #8,d0
	move.l  d0,$ffff8200.w
	IFNE    ONVBL
	move    $ffff8240.w,d0
	move    #$700,$ffff8240.w
	rept    130
	nop
	endr
	move    d0,$ffff8240.w
	ENDC
;
;       attendre la synchro spot TV
;
	IFNE VBLTIM = 1
	move    nb2vbl,d0
	lsl     #4,d0
	move.l  adrphy,a0
	lea     vblcom,a1
	add     d0,a1
	move    (a1)+,(a0)
	move    (a1)+,160*1(a0)
	move    (a1)+,160*2(a0)
	move    (a1)+,160*3(a0)
	move    (a1)+,160*4(a0)
	move    (a1)+,160*5(a0)
	move    (a1)+,160*6(a0)
	move    (a1)+,160*7(a0)
	ENDC
	move.b  #$ff,vblflg
o5vsync tst.b   vblflg
	bne.s   o5vsync         
	IFNE VBLTIM     = 1
	clr     nb2vbl
	ENDC
	addq.l  #2,adrdis
	cmp.l   #o5dsttab+360*2,adrdis
	bne.s   o5bn
	move.l  #o5dsttab,adrdis
o5bn
;
;       espace? sinon on recomence!!!
;
	subq    #1,timer
	beq.s   o5fini
	cmp.b   #$39,$fffffc02.w
	bne     o5boucle
;
;       programe fini ici
;
o5fini  lea     $ffff8240.w,a0
	lea     palette,a1
	rept    8
	move.l  (a1)+,(a0)+
	endr
	rts
;
;       routines de traitement ici
;
initscreen      move.l  #screens,d0
	and     #$ff00,d0
	add.l   #256,d0
	move.l  d0,adrphy
	add.l   #32000,d0
	move.l  d0,adrlog
	move.l  adrphy,a0
	move    #7999,d0
efface  clr.l   (a0)+
	clr.l   (a0)+
	dbra    d0,efface
	rts

cls     moveq   #0,d0
	moveq   #0,d1
	moveq   #0,d2
	moveq   #0,d3
	moveq   #0,d4
	moveq   #0,d5
	moveq   #0,d6
	moveq   #0,d7
	move.l  d0,a1
	move.l  d0,a2
	move.l  d0,a3
	move.l  d0,a4
	move.l  d0,a5
	move.l  d0,a6
Z       set     0
	rept    200
	movem.l d0-d7/a1-a6,Z+32(a0)
	movem.l d0-d7/a1-a2,Z+88(a0)
Z       set     Z+160
	endr
	rts
o4cls   moveq   #0,d0
	moveq   #0,d1
	moveq   #0,d2
	moveq   #0,d3
	moveq   #0,d4
	moveq   #0,d5
	moveq   #0,d6
	moveq   #0,d7
	move.l  d0,a1
	move.l  d0,a2
	move.l  d0,a3
	move.l  d0,a4
	move.l  d0,a5
	move.l  d0,a6
	movem.l d0-d4,56(a0)
Z       set     160
	rept    138
	movem.l d0-d7/a1-a6,Z+40(a0)
	movem.l d0-d6,Z+92(a0)
Z       set     Z+160
	endr
	movem.l d0-d5,Z+64(a0)
	movem.l d0-d5,Z+160+64(a0)
	rts
o5cls   moveq   #0,d0
	moveq   #0,d1
	moveq   #0,d2
	moveq   #0,d3
	moveq   #0,d4
	moveq   #0,d5
	moveq   #0,d6
	moveq   #0,d7
	move.l  d0,a1
	move.l  d0,a2
	move.l  d0,a3
	move.l  d0,a4
	move.l  d0,a5
	move.l  d0,a6
	movem.l d0-d4,56(a0)
Z       set     160
	rept    140
	movem.l d0-d7/a1-a6,Z+48(a0)
	movem.l d0-d6,Z+100(a0)
Z       set     Z+160
	endr
	movem.l d0-d5,Z+64(a0)
	movem.l d0-d5,Z+160+64(a0)
	rts

;
;       routines de trace des elements graphiques de base...
;       ====================================================
;
;       routine de polygone 1 plan.     (code of PrinST form MB)
;
; parametres: dans polyfom1 , les 4 couples de coordonne en .w + l'adresse
; de l'ecran en.l
;
;
;         attention les registres sont modifie...
;
;
;
;
; remarque: optimise,mais je pense qu'elle est loin d'etre parfaite,
; sourtout le calcul des bordure(lin routine 1,2;2,4;1,3;3,4)
;
o4POLYFILL
;
;       ACTE 1:tri des coordonnees.
;
	lea     polyform1,a0
	movem   (a0),d0-d7
	cmp     d1,d3
	bgt.s   o4POLY_1
	exg     d1,d3
	exg     d0,d2
o4POLY_1        cmp     d1,d5
	bgt.s   o4POLY_2
	exg     d1,d5
	exg     d0,d4
o4POLY_2        cmp     d1,d7
	bgt.s   o4POLY_57
	exg     d1,d7
	exg     d0,d6
o4POLY_57       cmp     d3,d5
	bgt.s   o4POLY_3
	exg     d3,d5
	exg     d2,d4
o4POLY_3        cmp     d3,d7
	bgt.s   o4POLY_58       
	exg     d3,d7
	exg     d2,d6
o4POLY_58       cmp     d5,d7
	bgt.s   o4POLY_59
	exg     d5,d7
	exg     d4,d6
o4POLY_59       movem   d0-d7,(a0)
	move.l  d4,a0
	move    d7,d4
	sub     d1,d4
	move    d4,POLY_51
	move    d1,POLY_52
	move.l  a0,d4
;
;       ACTE 2 :tracer virutel
;
	sub     d0,d6   ;X1
	sub     d1,d7   ;Y1
	sub     d0,d4   ;X2
	sub     d1,d5   ;Y2
	sub     d0,d2   ;X3
	sub     d1,d3   ;Y3
	muls    d6,d5   ;X1*Y2
	muls    d7,d4   ;X2*Y1
	sub.l   d4,d5   ;X1*Y2-X2*Y1
	muls    d6,d3   ;X1*Y3
	muls    d7,d2   ;X3*Y1
	sub.l   d2,d3   ;X1*Y3-X3*Y1
	eor.l   d3,d5
	btst.l  #31,d5
	beq     o4POLYL_4


;
;          (ligne 1,2)
;
o4POLY_4        lea     polyform1,a0
	movem   (a0),d0-d3
	lea     POLY_56,a1
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o4POLY_10
	move    #$5240,o4POLY_29
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o4POLY_19
	move    d0,(a1)
	addq    #4,a1
	bra.s   o4POLY_23
o4POLY_19       tst     d4      ;sens sur les X?
	bgt.s   o4POLY_0
	move    #$5340,o4POLY_10
	move    #$5340,o4POLY_29
	neg     d4
o4POLY_0        move    d5,d6
	cmp     d5,d4
	blt.s   o4POLY_11
;       ligne hz
	move    d4,d6
	neg     d6
o4POLY_10       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o4POLY_10       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o4POLY_10       ;non => on boucle...
	bra.s   o4POLY_23       ;apres...
; ligne ve
o4POLY_11       move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o4POLY_12       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o4POLY_29       addq    #1,d0   ;X=X+1
o4POLY_12       cmp     d1,d3   ;on est arrive?
	bne.s   o4POLY_11       ;non on boucle...
o4POLY_23
;
;       (ligne 2,4)
;
	lea     polyform1+4,a0
	movem   (a0),d0-d5
	move    d4,d2
	move    d5,d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o4POLY_13
	move    #$5240,o4POLY_27
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o4POLY_22
	move    d0,(a1)
	addq    #4,a1
	bra.s   o4POLY_5
o4POLY_22       tst     d4      ;sens sur les X?
	bgt.s   o4POLY_24
	move    #$5340,o4POLY_13
	move    #$5340,o4POLY_27
	neg     d4
o4POLY_24       move    d5,d6
	cmp     d5,d4
	blt.s   o4POLY_14
	move    d4,d6
	neg     d6
;       ligne hz
o4POLY_13       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o4POLY_13       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o4POLY_13       ;non => on boucle...
	bra.s   o4POLY_5        ;apres...
; ligne ve
o4POLY_14       move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o4POLY_15       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o4POLY_27       addq    #1,d0   ;X=X+1
o4POLY_15       cmp     d1,d3   ;on est arrive?
	bne.s   o4POLY_14       ;non on boucle...
o4POLY_5
;
;       (ligne 1,3)
;
o4POLY_26       lea     POLY_56+2,a1
	lea     polyform1,a0
	movem   (a0)+,d0-d5
	move    d4,d2
	move    d5,d3
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o4POLY_16
	move    #$5240,o4POLY_28
	sub     d1,d5   ;Dy dans D5
	bne.s   o4POLY_25
	move    d0,(a1)+
	bra.s   o4POLY_8
o4POLY_25       tst     d4      ;sens sur les X?
	bgt.s   o4POLY_6
	move    #$5340,o4POLY_16
	move    #$5340,o4POLY_28
	neg     d4
o4POLY_6        move    d5,d6
	cmp     d5,d4
	blt.s   o4POLY_17
;       ligne hz
	move    d4,d6
	neg     d6
o4POLY_16       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o4POLY_16       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o4POLY_16       ;non => on boucle...
	bra.s   o4POLY_8        ;apres...
; ligne ve
o4POLY_17       move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o4POLY_18       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o4POLY_28       addq    #1,d0   ;X=X+1
o4POLY_18       cmp     d1,d3   ;on est arrive?
	bne.s   o4POLY_17       ;non on boucle...
;
;       (ligne 3,4)
;
o4POLY_8        lea     polyform1+8,a0
	movem   (a0),d0-d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o4POLY_63
	move    #$5240,o4POLY_65
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o4POLY_61
	move    d0,(a1)+
	bra     o4POLY_60
o4POLY_61       tst     d4      ;sens sur les X?
	bgt.s   o4POLY_62
	move    #$5340,o4POLY_63
	move    #$5340,o4POLY_65
	neg     d4
o4POLY_62       move    d5,d6
	cmp     d5,d4
	blt.s   o4POLY_64
;       ligne hz
	move    d4,d6
	neg     d6
o4POLY_63       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o4POLY_63       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o4POLY_63       ;non => on boucle...
	bra     o4POLY_60       ;apres...
; ligne ve
o4POLY_64       move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o4POLY_66       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o4POLY_65       addq    #1,d0   ;X=X+1
o4POLY_66       cmp     d1,d3   ;on est arrive?
	bne.s   o4POLY_64       ;non on boucle...
	bra     o4POLY_60
;
;       l'autre
;
o4POLYL_4       lea     polyform1,a0
	movem   (a0),d0-d3
	lea     POLY_56,a1
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o4POLYL_10
	move    #$5240,o4POLYL_29
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o4POLYL_19
	move    d0,(a1)
	addq    #4,a1
	bra.s   o4POLYL_23
o4POLYL_19      tst     d4      ;sens sur les X?
	bgt.s   o4POLYL_0
	move    #$5340,o4POLYL_10
	move    #$5340,o4POLYL_29
	neg     d4
o4POLYL_0       move    d5,d6
	cmp     d5,d4
	blt.s   o4POLYL_11
;       ligne hz
	move    d4,d6
	neg     d6
o4POLYL_10      addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o4POLYL_10      ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o4POLYL_10      ;non => on boucle...
	bra.s   o4POLYL_23      ;apres...
; ligne ve
o4POLYL_11      move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o4POLYL_12      ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o4POLYL_29      addq    #1,d0   ;X=X+1
o4POLYL_12      cmp     d1,d3   ;on est arrive?
	bne.s   o4POLYL_11      ;non on boucle...
o4POLYL_23
;
;       (ligne 2,3)
;
	lea     polyform1+4,a0
	movem   (a0),d0-d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o4POLYL_13
	move    #$5240,o4POLYL_27
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o4POLYL_22
	move    d0,(a1)
	addq    #4,a1
	bra.s   o4POLYL_5
o4POLYL_22      tst     d4      ;sens sur les X?
	bgt.s   o4POLYL_24
	move    #$5340,o4POLYL_13
	move    #$5340,o4POLYL_27
	neg     d4
o4POLYL_24      move    d5,d6
	cmp     d5,d4
	blt.s   o4POLYL_14
	move    d4,d6
	neg     d6
;       ligne hz
o4POLYL_13      addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o4POLYL_13      ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o4POLYL_13      ;non => on boucle...
	bra.s   o4POLYL_5       ;apres...
; ligne ve
o4POLYL_14      move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o4POLYL_15      ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o4POLYL_27      addq    #1,d0   ;X=X+1
o4POLYL_15      cmp     d1,d3   ;on est arrive?
	bne.s   o4POLYL_14      ;non on boucle...
o4POLYL_5
;
;       (ligne 3,4)
;
o4POLYL_26      lea     polyform1+8,a0
	movem   (a0)+,d0-d3
	move    d3,d5
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o4POLYL_16
	move    #$5240,o4POLYL_28
	sub     d1,d5   ;Dy dans D5
	bne.s   o4POLYL_25
	move    d0,(a1)+
	bra.s   o4POLYL_8
o4POLYL_25      tst     d4      ;sens sur les X?
	bgt.s   o4POLYL_6
	move    #$5340,o4POLYL_16
	move    #$5340,o4POLYL_28
	neg     d4
o4POLYL_6       move    d5,d6
	cmp     d5,d4
	blt.s   o4POLYL_17
;       ligne hz
	move    d4,d6
	neg     d6
o4POLYL_16      addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o4POLYL_16      ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o4POLYL_16      ;non => on boucle...
	bra.s   o4POLYL_8       ;apres...
; ligne ve
o4POLYL_17      move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o4POLYL_18      ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o4POLYL_28      addq    #1,d0   ;X=X+1
o4POLYL_18      cmp     d1,d3   ;on est arrive?
	bne.s   o4POLYL_17      ;non on boucle...
;
;       (ligne 1,4)
;
o4POLYL_8       lea     POLY_56+2,a1
	lea     polyform1,a0
	move    (a0),d0
	move    2(a0),d1
	move    12(a0),d2
	move    14(a0),d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o4POLYL_63
	move    #$5240,o4POLYL_65
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o4POLYL_61
	move    d0,(a1)+
	bra.s   o4POLY_60
o4POLYL_61      tst     d4      ;sens sur les X?
	bgt.s   o4POLYL_62
	move    #$5340,o4POLYL_63
	move    #$5340,o4POLYL_65
	neg     d4
o4POLYL_62      move    d5,d6
	cmp     d5,d4
	blt.s   o4POLYL_64
;       ligne hz
	move    d4,d6
	neg     d6
o4POLYL_63      addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o4POLYL_63      ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o4POLYL_63      ;non => on boucle...
	bra.s   o4POLY_60       ;apres...
; ligne ve
o4POLYL_64      move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o4POLYL_66      ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o4POLYL_65      addq    #1,d0   ;X=X+1
o4POLYL_66      cmp     d1,d3   ;on est arrive?
	bne.s   o4POLYL_64      ;non on boucle...


;
;       ACTE 3:tracer la polyfill.
;
o4POLY_60       lea     POLY_56,a1              ;table des coordonnes X
	move    POLY_52,d0              ;D0 = debut de la polyfill
	mulu    #160,d0         ;octet a sauter
	move.l  polyform1+16,a0         ;a0 de but de l'ecran
	add.l   d0,a0           ;a0 adresse de depart
	move    POLY_51,d4              ;D4 =nb de ligne hz a trace 
	subq    #1,d4           ;-1 pour le dbra
	moveq   #-1,d3          ;motif de remplissage
	lea     POLY_54,a4
	lea     POLY_55,a5

o4POLY_30       move    (a1)+,d0                ;coordonne droite dans D0
	move    (a1)+,d2                ;coordonne gauche dans D2
	cmp     d0,d2           ;dans le bon sens d0,d2?
	bgt.s   o4POLY_67               ;sinon
	exg     d0,d2           ;on renverse
o4POLY_67       lsl     #2,d0           ;Xd * 4
	lea     (a4,d0.w),a2    ;A2 sur le bon morceau
	move    (a2)+,d7                ;morceau droit a OR dans D7
	move    (a2)+,d1                ;octets a + au bord
	lsl     #2,d2           ;Xg * 4
	lea     (a5,d2.w),a2    ;A2 sur le bon morceau
	move    (a2)+,d6                ;le morceau dans D6
	move    (a2)+,d2                ;octets a + au bord
	move    d2,d0           ;D0 = D1
	sub     d1,d0           ;D0 = D1-D2
	lea     (a0,d1.w),a3    ;A3 = A0 + D2
	lea     160(a0),a0              ;A0 sur la ligne suivante
	lea     o4POLY_53,a2    ;A2 sur la table des saut
	lsr     d0              ;decalage D0 pour le jmp
	move.l  (a2,d0.w),a2    ;A2 sur le JMP a faire
	jmp     (a2)            ;JMP fait...

o4POLY_31       and     d7,d6
	or      d6,(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_32       or      d7,(a3)
	or      d6,8(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_33       or      d7,(a3)
	move    d3,8(a3)
	or      d6,16(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_34       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	or      d6,24(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_35       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	or      d6,32(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_36       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	or      d6,40(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_37       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	or      d6,48(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_38       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	or      d6,56(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_39       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	or      d6,64(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_40       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	or      d6,72(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_41       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	or      d6,80(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_42       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	or      d6,88(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_43       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	or      d6,96(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_44       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	or      d6,104(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_45       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	or      d6,112(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_46       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	or      d6,120(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_47       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	or      d6,128(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_48       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	or      d6,136(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_49       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	move    d3,136(a3)
	or      d6,144(a3)
	dbra    d4,o4POLY_30
	rts
o4POLY_50       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	move    d3,136(a3)
	move    d3,144(a3)
	or      d6,156(a3)
	dbra    d4,o4POLY_30
	rts
;       routine de polygone 1 plan mou. (code of PrinST form MB)
;
; parametres: dans polyfom1 , les 4 couples de coordonne en .w + l'adresse
; de l'ecran en.l
;
;
;         attention les registres sont modifie...
;
;
;
;
; remarque: optimise,mais je pense qu'elle est loin d'etre parfaite,
; sourtout le calcul des bordure(lin routine 1,2;2,4;1,3;3,4)
;
o5POLYFILL
;
;       ACTE 1:tri des coordonnees.
;
	lea     polyform1,a0
	movem   (a0),d0-d7
	cmp     d1,d3
	bgt.s   o5POLY_1
	exg     d1,d3
	exg     d0,d2
o5POLY_1        cmp     d1,d5
	bgt.s   o5POLY_2
	exg     d1,d5
	exg     d0,d4
o5POLY_2        cmp     d1,d7
	bgt.s   o5POLY_57
	exg     d1,d7
	exg     d0,d6
o5POLY_57       cmp     d3,d5
	bgt.s   o5POLY_3
	exg     d3,d5
	exg     d2,d4
o5POLY_3        cmp     d3,d7
	bgt.s   o5POLY_58       
	exg     d3,d7
	exg     d2,d6
o5POLY_58       cmp     d5,d7
	bgt.s   o5POLY_59
	exg     d5,d7
	exg     d4,d6
o5POLY_59       movem   d0-d7,(a0)
	move.l  d4,a0
	move    d7,d4
	sub     d1,d4
	move    d4,POLY_51
	move    d1,POLY_52
	move.l  a0,d4
;
;       ACTE 2 :tracer virutel
;
	sub     d0,d6   ;X1
	sub     d1,d7   ;Y1
	sub     d0,d4   ;X2
	sub     d1,d5   ;Y2
	sub     d0,d2   ;X3
	sub     d1,d3   ;Y3
	muls    d6,d5   ;X1*Y2
	muls    d7,d4   ;X2*Y1
	sub.l   d4,d5   ;X1*Y2-X2*Y1
	muls    d6,d3   ;X1*Y3
	muls    d7,d2   ;X3*Y1
	sub.l   d2,d3   ;X1*Y3-X3*Y1
	eor.l   d3,d5
	btst.l  #31,d5
	beq     o5POLYL_4


;
;          (ligne 1,2)
;
o5POLY_4        lea     polyform1,a0
	movem   (a0),d0-d3
	lea     POLY_56,a1
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o5POLY_10
	move    #$5240,o5POLY_29
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o5POLY_19
	move    d0,(a1)
	addq    #4,a1
	bra.s   o5POLY_23
o5POLY_19       tst     d4      ;sens sur les X?
	bgt.s   o5POLY_0
	move    #$5340,o5POLY_10
	move    #$5340,o5POLY_29
	neg     d4
o5POLY_0        move    d5,d6
	cmp     d5,d4
	blt.s   o5POLY_11
;       ligne hz
	move    d4,d6
	neg     d6
o5POLY_10       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o5POLY_10       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o5POLY_10       ;non => on boucle...
	bra.s   o5POLY_23       ;apres...
; ligne ve
o5POLY_11       move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o5POLY_12       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o5POLY_29       addq    #1,d0   ;X=X+1
o5POLY_12       cmp     d1,d3   ;on est arrive?
	bne.s   o5POLY_11       ;non on boucle...
o5POLY_23
;
;       (ligne 2,4)
;
	lea     polyform1+4,a0
	movem   (a0),d0-d5
	move    d4,d2
	move    d5,d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o5POLY_13
	move    #$5240,o5POLY_27
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o5POLY_22
	move    d0,(a1)
	addq    #4,a1
	bra.s   o5POLY_5
o5POLY_22       tst     d4      ;sens sur les X?
	bgt.s   o5POLY_24
	move    #$5340,o5POLY_13
	move    #$5340,o5POLY_27
	neg     d4
o5POLY_24       move    d5,d6
	cmp     d5,d4
	blt.s   o5POLY_14
	move    d4,d6
	neg     d6
;       ligne hz
o5POLY_13       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o5POLY_13       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o5POLY_13       ;non => on boucle...
	bra.s   o5POLY_5        ;apres...
; ligne ve
o5POLY_14       move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o5POLY_15       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o5POLY_27       addq    #1,d0   ;X=X+1
o5POLY_15       cmp     d1,d3   ;on est arrive?
	bne.s   o5POLY_14       ;non on boucle...
o5POLY_5
;
;       (ligne 1,3)
;
o5POLY_26       lea     POLY_56+2,a1
	lea     polyform1,a0
	movem   (a0)+,d0-d5
	move    d4,d2
	move    d5,d3
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o5POLY_16
	move    #$5240,o5POLY_28
	sub     d1,d5   ;Dy dans D5
	bne.s   o5POLY_25
	move    d0,(a1)+
	bra.s   o5POLY_8
o5POLY_25       tst     d4      ;sens sur les X?
	bgt.s   o5POLY_6
	move    #$5340,o5POLY_16
	move    #$5340,o5POLY_28
	neg     d4
o5POLY_6        move    d5,d6
	cmp     d5,d4
	blt.s   o5POLY_17
;       ligne hz
	move    d4,d6
	neg     d6
o5POLY_16       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o5POLY_16       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o5POLY_16       ;non => on boucle...
	bra.s   o5POLY_8        ;apres...
; ligne ve
o5POLY_17       move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o5POLY_18       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o5POLY_28       addq    #1,d0   ;X=X+1
o5POLY_18       cmp     d1,d3   ;on est arrive?
	bne.s   o5POLY_17       ;non on boucle...
;
;       (ligne 3,4)
;
o5POLY_8        lea     polyform1+8,a0
	movem   (a0),d0-d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o5POLY_63
	move    #$5240,o5POLY_65
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o5POLY_61
	move    d0,(a1)+
	bra     o5POLY_60
o5POLY_61       tst     d4      ;sens sur les X?
	bgt.s   o5POLY_62
	move    #$5340,o5POLY_63
	move    #$5340,o5POLY_65
	neg     d4
o5POLY_62       move    d5,d6
	cmp     d5,d4
	blt.s   o5POLY_64
;       ligne hz
	move    d4,d6
	neg     d6
o5POLY_63       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o5POLY_63       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o5POLY_63       ;non => on boucle...
	bra     o5POLY_60       ;apres...
; ligne ve
o5POLY_64       move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o5POLY_66       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o5POLY_65       addq    #1,d0   ;X=X+1
o5POLY_66       cmp     d1,d3   ;on est arrive?
	bne.s   o5POLY_64       ;non on boucle...
	bra     o5POLY_60
;
;       l'autre
;
o5POLYL_4       lea     polyform1,a0
	movem   (a0),d0-d3
	lea     POLY_56,a1
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o5POLYL_10
	move    #$5240,o5POLYL_29
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o5POLYL_19
	move    d0,(a1)
	addq    #4,a1
	bra.s   o5POLYL_23
o5POLYL_19      tst     d4      ;sens sur les X?
	bgt.s   o5POLYL_0
	move    #$5340,o5POLYL_10
	move    #$5340,o5POLYL_29
	neg     d4
o5POLYL_0       move    d5,d6
	cmp     d5,d4
	blt.s   o5POLYL_11
;       ligne hz
	move    d4,d6
	neg     d6
o5POLYL_10      addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o5POLYL_10      ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o5POLYL_10      ;non => on boucle...
	bra.s   o5POLYL_23      ;apres...
; ligne ve
o5POLYL_11      move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o5POLYL_12      ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o5POLYL_29      addq    #1,d0   ;X=X+1
o5POLYL_12      cmp     d1,d3   ;on est arrive?
	bne.s   o5POLYL_11      ;non on boucle...
o5POLYL_23
;
;       (ligne 2,3)
;
	lea     polyform1+4,a0
	movem   (a0),d0-d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o5POLYL_13
	move    #$5240,o5POLYL_27
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o5POLYL_22
	move    d0,(a1)
	addq    #4,a1
	bra.s   o5POLYL_5
o5POLYL_22      tst     d4      ;sens sur les X?
	bgt.s   o5POLYL_24
	move    #$5340,o5POLYL_13
	move    #$5340,o5POLYL_27
	neg     d4
o5POLYL_24      move    d5,d6
	cmp     d5,d4
	blt.s   o5POLYL_14
	move    d4,d6
	neg     d6
;       ligne hz
o5POLYL_13      addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o5POLYL_13      ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o5POLYL_13      ;non => on boucle...
	bra.s   o5POLYL_5       ;apres...
; ligne ve
o5POLYL_14      move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o5POLYL_15      ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o5POLYL_27      addq    #1,d0   ;X=X+1
o5POLYL_15      cmp     d1,d3   ;on est arrive?
	bne.s   o5POLYL_14      ;non on boucle...
o5POLYL_5
;
;       (ligne 3,4)
;
o5POLYL_26      lea     polyform1+8,a0
	movem   (a0)+,d0-d3
	move    d3,d5
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o5POLYL_16
	move    #$5240,o5POLYL_28
	sub     d1,d5   ;Dy dans D5
	bne.s   o5POLYL_25
	move    d0,(a1)+
	bra.s   o5POLYL_8
o5POLYL_25      tst     d4      ;sens sur les X?
	bgt.s   o5POLYL_6
	move    #$5340,o5POLYL_16
	move    #$5340,o5POLYL_28
	neg     d4
o5POLYL_6       move    d5,d6
	cmp     d5,d4
	blt.s   o5POLYL_17
;       ligne hz
	move    d4,d6
	neg     d6
o5POLYL_16      addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o5POLYL_16      ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o5POLYL_16      ;non => on boucle...
	bra.s   o5POLYL_8       ;apres...
; ligne ve
o5POLYL_17      move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o5POLYL_18      ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o5POLYL_28      addq    #1,d0   ;X=X+1
o5POLYL_18      cmp     d1,d3   ;on est arrive?
	bne.s   o5POLYL_17      ;non on boucle...
;
;       (ligne 1,4)
;
o5POLYL_8       lea     POLY_56+2,a1
	lea     polyform1,a0
	move    (a0),d0
	move    2(a0),d1
	move    12(a0),d2
	move    14(a0),d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,o5POLYL_63
	move    #$5240,o5POLYL_65
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   o5POLYL_61
	move    d0,(a1)+
	bra.s   o5POLY_60
o5POLYL_61      tst     d4      ;sens sur les X?
	bgt.s   o5POLYL_62
	move    #$5340,o5POLYL_63
	move    #$5340,o5POLYL_65
	neg     d4
o5POLYL_62      move    d5,d6
	cmp     d5,d4
	blt.s   o5POLYL_64
;       ligne hz
	move    d4,d6
	neg     d6
o5POLYL_63      addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   o5POLYL_63      ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   o5POLYL_63      ;non => on boucle...
	bra.s   o5POLY_60       ;apres...
; ligne ve
o5POLYL_64      move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   o5POLYL_66      ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
o5POLYL_65      addq    #1,d0   ;X=X+1
o5POLYL_66      cmp     d1,d3   ;on est arrive?
	bne.s   o5POLYL_64      ;non on boucle...


;
;       ACTE 3:tracer la polyfill.
;
o5POLY_60       lea     POLY_56,a1              ;table des coordonnes X
	move    POLY_52,d0              ;D0 = debut de la polyfill
	move.l  adrdis,a6
	add     d0,d0
	add     d0,a6
	mulu    #80,d0          ;octet a sauter
	move.l  polyform1+16,a0 ;a0 de but de l'ecran
	add.l   d0,a0           ;a0 adresse de depart
	move    POLY_51,d4              ;D4 =nb de ligne hz a trace 
	subq    #1,d4           ;-1 pour le dbra
	moveq   #-1,d3          ;motif de remplissage
	lea     POLY_54,a4
	lea     POLY_55,a5
	

o5POLY_30       move    (a1)+,d0                ;coordonne droite dans D0
	move    (a1)+,d2                ;coordonne gauche dans D2
	move    (a6)+,d1
	add     d1,d0
	add     d1,d2
	cmp     d0,d2           ;dans le bon sens d0,d2?
	bgt.s   o5POLY_67               ;sinon
	exg     d0,d2           ;on renverse
o5POLY_67       lsl     #2,d0           ;Xd * 4
	lea     (a4,d0.w),a2    ;A2 sur le bon morceau
	move    (a2)+,d7                ;morceau droit a OR dans D7
	move    (a2)+,d1                ;octets a + au bord
	lsl     #2,d2           ;Xg * 4
	lea     (a5,d2.w),a2    ;A2 sur le bon morceau
	move    (a2)+,d6                ;le morceau dans D6
	move    (a2)+,d2                ;octets a + au bord
	move    d2,d0           ;D0 = D1
	sub     d1,d0           ;D0 = D1-D2
	lea     (a0,d1.w),a3    ;A3 = A0 + D2
	lea     160(a0),a0              ;A0 sur la ligne suivante
	lea     o5POLY_53,a2            ;A2 sur la table des saut
	lsr     d0              ;decalage D0 pour le jmp
	move.l  (a2,d0.w),a2    ;A2 sur le JMP a faire
	jmp     (a2)            ;JMP fait...

o5POLY_31       and     d7,d6
	or      d6,(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_32       or      d7,(a3)
	or      d6,8(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_33       or      d7,(a3)
	move    d3,8(a3)
	or      d6,16(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_34       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	or      d6,24(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_35       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	or      d6,32(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_36       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	or      d6,40(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_37       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	or      d6,48(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_38       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	or      d6,56(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_39       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	or      d6,64(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_40       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	or      d6,72(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_41       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	or      d6,80(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_42       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	or      d6,88(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_43       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	or      d6,96(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_44       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	or      d6,104(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_45       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	or      d6,112(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_46       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	or      d6,120(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_47       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	or      d6,128(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_48       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	or      d6,136(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_49       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	move    d3,136(a3)
	or      d6,144(a3)
	dbra    d4,o5POLY_30
	rts
o5POLY_50       or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	move    d3,136(a3)
	move    d3,144(a3)
	or      d6,156(a3)
	dbra    d4,o5POLY_30
	rts


;
;       routines de trace des elements graphiques de base...
;       ====================================================
;
DRAWER
;
;
;       les parametres:
;       *dans polyform1 il y a en.w le ou les coordonnees necessaires
;       *l'adresse de base de l'ecran est dans a0
;       *a1 doit etre li‚ a l'une des etiquettes suivantes selon 
;       l'element graphique demande:
;       - pset   pour point
;       - line   pour ligne
;       - poly3  pour polyfill 3 points
;       - poly4  pour polyfill 4 points
;       - poly3t pour polyfill 3 points avec trames
;       - poly4t pour polyfill 4 points avec trames
;       - poly3m pour polyfill 3 points avec distort (3d mole)
;       - poly4m pour polyfill 4 points avec distort (3d mole)
;
;
	jmp     (a1)

pset    lea     polyform1,a1
	move    (a1)+,d0
	move    (a1)+,d1
	mulu    #160,d1
	add.l   d1,a0
	lsl     #2,d0
	lea     psettab,a1
	add     d0,a1
	move    (a1)+,d0
	move    (a1),d1
	add     d1,a0
	or      d0,(a0)
	rts
line    lea     polyform1,a1
	movem   (a1),d0-d3
	cmp     d0,d2
	bgt.s   line_1
	exg.l   d0,d2
	exg.l   d1,d3
line_1  move    d2,d4
	sub     d0,d4
	move    #160,d7
	moveq   #0,d6
	move    d3,d5
	sub     d1,d5
	bgt.s   line_2
	neg     d7
	neg     d5
line_2  cmp     d4,d5
	bgt     line_3
	mulu    #160,d1
	lea     (a0,d1.w),a0
	move    d0,d1
	and     #$fff0,d0
	lsr     d0
	lea     (a0,d0.w),a0
	move    #$8000,d0
	and     #$f,d1
	lsr     d1,d0
	move    #319,d1
	sub     d4,d1
	lsl     #4,d1
	jmp     line_4(pc,d1.w)
line_4  
	rept    319
	dc.l    $81509c45
	dc.l    $6e04dc44
	dc.l    $d0c7e258
	dc.l    $62025048
	endr
	rts
line_3  mulu    #160,d1
	lea     (a0,d1.w),a0
	move    d0,d1
	and     #$fff0,d0
	lsr     d0
	lea     (a0,d0.w),a0
	move    #$8000,d0
	and     #$f,d1
	lsr     d1,d0
	move    #199,d1
	sub     d5,d1
	lsl     #4,d1
	jmp     line_5(pc,d1.w)
line_5  
	rept    199
	dc.l    $8150d0c7
	dc.l    $dc446d08
	dc.l    $9c45e258
	dc.l    $6e025048
	endr
	rts
poly3t  move    #%1010101010101010,POLY_AM2+2
	move.l  #POLYT_53,POLY_AM1+2
	bsr.s   poly3
	move    #$ffff,POLY_AM2+2
	move.l  #POLY_53,POLY_AM1+2
	rts
poly4t  move    #%1010101010101010,POLY_AM2+2
	move.l  #POLYT_53,POLY_AM1+2
	bsr     poly4
	move    #$ffff,POLY_AM2+2
	move.l  #POLY_53,POLY_AM1+2
	rts
;
;       ACTE 1:tri des coordonnees.
;
poly3   move.l  a0,POLY_as
	lea     polyform1,a0
	movem   (a0),d0-d5
	cmp     d1,d3
	bgt.s   POLY3P_1
	exg     d1,d3
	exg     d0,d2
POLY3P_1        cmp     d1,d5
	bgt.s   POLY3P_2
	exg     d1,d5
	exg     d0,d4
POLY3P_2        cmp     d3,d5
	bgt.s   POLY3P_3
	exg     d3,d5
	exg     d2,d4
POLY3P_3        movem   d0-d5,(a0)
	cmp     d1,d5
	bne.s   POLY_PB
	rts
POLY_PB move    d1,POLY_52
	move.l  #POLY_56+2,POLY3P_4+2
	move.l  #POLY_56,POLY3P_26+2
	cmp     d2,d4
	blt.s   POLY3P_4
	move.l  #POLY_56,POLY3P_4+2
	move.l  #POLY_56+2,POLY3P_26+2
;
;       ACTE 2 :tracer virutel
;          (ligne 1,2)
;
POLY3P_4        lea     POLY_56,a1
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLY3P_10
	move    #$5240,POLY3P_29
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   POLY3P_19
	move    d0,(a1)
	addq    #4,a1
	bra.s   POLY3P_23
POLY3P_19       tst     d4      ;sens sur les X?
	bgt.s   POLY3P_0
	move    #$5340,POLY3P_10
	move    #$5340,POLY3P_29
	neg     d4
POLY3P_0        move    d5,d6
	cmp     d5,d4
	blt.s   POLY3P_11
;       ligne hz
	move    d4,d6
	neg     d6
POLY3P_10       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLY3P_10       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLY3P_10       ;non => on boucle...
	bra.s   POLY3P_23       ;apres...
; ligne ve
POLY3P_11       move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLY3P_12       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLY3P_29       addq    #1,d0   ;X=X+1
POLY3P_12       cmp     d1,d3   ;on est arrive?
	bne.s   POLY3P_11       ;non on boucle...
POLY3P_23
;
;       (ligne 2,3)
;
	lea     polyform1+4,a0
	movem   (a0),d0-d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLY3P_13
	move    #$5240,POLY3P_27
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   POLY3P_22
	move    d0,(a1)
	addq    #4,a1
	bra.s   POLY3P_5
POLY3P_22       tst     d4      ;sens sur les X?
	bgt.s   POLY3P_24
	move    #$5340,POLY3P_13
	move    #$5340,POLY3P_27
	neg     d4
POLY3P_24       move    d5,d6
	cmp     d5,d4
	blt.s   POLY3P_14
	move    d4,d6
	neg     d6
;       ligne hz
POLY3P_13       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLY3P_13       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la POLYfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLY3P_13       ;non => on boucle...
	bra.s   POLY3P_5        ;apres...
; ligne ve
POLY3P_14       move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLY3P_15       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLY3P_27       addq    #1,d0   ;X=X+1
POLY3P_15       cmp     d1,d3   ;on est arrive?
	bne.s   POLY3P_14       ;non on boucle...
POLY3P_5
;
;       (ligne 1,3)
;
POLY3P_26       lea     POLY_56,a1
	lea     polyform1,a0
	move    (a0)+,d0        ;Xd dans d0
	move    (a0)+,d1        ;Yd dans d1
	addq    #4,a0
	move    (a0)+,d2        ;Xf dans d2
	move    (a0)+,d3        ;Yf dans d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLY3P_16
	move    #$5240,POLY3P_28
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   POLY3P_25
	move    d5,POLY_51
	move    d0,(a1)+
	bra     POLY_60
POLY3P_25       move    d5,POLY_51
	tst     d4      ;sens sur les X?
	bgt.s   POLY3P_6
	move    #$5340,POLY3P_16
	move    #$5340,POLY3P_28
	neg     d4
POLY3P_6        move    d5,d6
	cmp     d5,d4
	blt.s   POLY3P_17
;       ligne hz
	move    d4,d6
	neg     d6
POLY3P_16       addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLY3P_16       ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLY3P_16       ;non => on boucle...
	bra     POLY_60 ;apres...
; ligne ve
POLY3P_17       move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLY3P_18       ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLY3P_28       addq    #1,d0   ;X=X+1
POLY3P_18       cmp     d1,d3   ;on est arrive?
	bne.s   POLY3P_17       ;non on boucle...
	bra     POLY_60
;
;       ACTE 1:tri des coordonnees.
;
poly4   move.l  a0,POLY_as
	lea     polyform1,a0
	movem   (a0),d0-d7
	cmp     d1,d3
	bgt.s   POLY_1
	exg     d1,d3
	exg     d0,d2
POLY_1  cmp     d1,d5
	bgt.s   POLY_2
	exg     d1,d5
	exg     d0,d4
POLY_2  cmp     d1,d7
	bgt.s   POLY_57
	exg     d1,d7
	exg     d0,d6
POLY_57 cmp     d3,d5
	bgt.s   POLY_3
	exg     d3,d5
	exg     d2,d4
POLY_3  cmp     d3,d7
	bgt.s   POLY_58 
	exg     d3,d7
	exg     d2,d6
POLY_58 cmp     d5,d7
	bgt.s   POLY_59
	exg     d5,d7
	exg     d4,d6
POLY_59 movem   d0-d7,(a0)
	cmp     d1,d7
	bne.s   POLY_PB2
	rts
POLY_PB2        move.l  d4,a0
	move    d7,d4
	sub     d1,d4
	move    d4,POLY_51
	move    d1,POLY_52
	move.l  a0,d4
;
;       ACTE 2 :tracer virutel
;          (ligne 1,2)
;
	sub     d0,d6   ;X1
	sub     d1,d7   ;Y1
	sub     d0,d4   ;X2
	sub     d1,d5   ;Y2
	sub     d0,d2   ;X3
	sub     d1,d3   ;Y3
	muls    d6,d5   ;X1*Y2
	muls    d7,d4   ;X2*Y1
	sub.l   d4,d5   ;X1*Y2-X2*Y1
	muls    d6,d3   ;X1*Y3
	muls    d7,d2   ;X3*Y1
	sub.l   d2,d3   ;X1*Y3-X3*Y1
	eor.l   d3,d5
	btst.l  #31,d5
	beq     POLYL_4

POLY_4  lea     polyform1,a0
	movem   (a0),d0-d3
	lea     POLY_56,a1
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLY_10
	move    #$5240,POLY_29
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   POLY_19
	move    d0,(a1)
	addq    #4,a1
	bra.s   POLY_23
POLY_19 tst     d4      ;sens sur les X?
	bgt.s   POLY_0
	move    #$5340,POLY_10
	move    #$5340,POLY_29
	neg     d4
POLY_0  move    d5,d6
	cmp     d5,d4
	blt.s   POLY_11
;       ligne hz
	move    d4,d6
	neg     d6
POLY_10 addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLY_10 ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLY_10 ;non => on boucle...
	bra.s   POLY_23 ;apres...
; ligne ve
POLY_11 move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLY_12 ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLY_29 addq    #1,d0   ;X=X+1
POLY_12 cmp     d1,d3   ;on est arrive?
	bne.s   POLY_11 ;non on boucle...
POLY_23
;
;       (ligne 2,4)
;
	lea     polyform1+4,a0
	movem   (a0),d0-d5
	move    d4,d2
	move    d5,d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLY_13
	move    #$5240,POLY_27
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   POLY_22
	move    d0,(a1)
	addq    #4,a1
	bra.s   POLY_5
POLY_22 tst     d4      ;sens sur les X?
	bgt.s   POLY_24
	move    #$5340,POLY_13
	move    #$5340,POLY_27
	neg     d4
POLY_24 move    d5,d6
	cmp     d5,d4
	blt.s   POLY_14
	move    d4,d6
	neg     d6
;       ligne hz
POLY_13 addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLY_13 ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLY_13 ;non => on boucle...
	bra.s   POLY_5  ;apres...
; ligne ve
POLY_14 move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLY_15 ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLY_27 addq    #1,d0   ;X=X+1
POLY_15 cmp     d1,d3   ;on est arrive?
	bne.s   POLY_14 ;non on boucle...
POLY_5
;
;       (ligne 1,3)
;
POLY_26 lea     POLY_56+2,a1
	lea     polyform1,a0
	movem   (a0)+,d0-d5
	move    d4,d2
	move    d5,d3
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLY_16
	move    #$5240,POLY_28
	sub     d1,d5   ;Dy dans D5
	bne.s   POLY_25
	move    d0,(a1)+
	bra.s   POLY_8
POLY_25 tst     d4      ;sens sur les X?
	bgt.s   POLY_6
	move    #$5340,POLY_16
	move    #$5340,POLY_28
	neg     d4
POLY_6  move    d5,d6
	cmp     d5,d4
	blt.s   POLY_17
;       ligne hz
	move    d4,d6
	neg     d6
POLY_16 addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLY_16 ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLY_16 ;non => on boucle...
	bra.s   POLY_8  ;apres...
; ligne ve
POLY_17 move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLY_18 ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLY_28 addq    #1,d0   ;X=X+1
POLY_18 cmp     d1,d3   ;on est arrive?
	bne.s   POLY_17 ;non on boucle...
;
;       (ligne 3,4)
;
POLY_8  lea     polyform1+8,a0
	movem   (a0),d0-d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLY_63
	move    #$5240,POLY_65
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   POLY_61
	move    d0,(a1)+
	bra     POLY_60
POLY_61 tst     d4      ;sens sur les X?
	bgt.s   POLY_62
	move    #$5340,POLY_63
	move    #$5340,POLY_65
	neg     d4
POLY_62 move    d5,d6
	cmp     d5,d4
	blt.s   POLY_64
;       ligne hz
	move    d4,d6
	neg     d6
POLY_63 addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLY_63 ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLY_63 ;non => on boucle...
	bra     POLY_60 ;apres...
; ligne ve
POLY_64 move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLY_66 ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLY_65 addq    #1,d0   ;X=X+1
POLY_66 cmp     d1,d3   ;on est arrive?
	bne.s   POLY_64 ;non on boucle...
	bra     POLY_60
;
;       l'autre
;
POLYL_4 lea     polyform1,a0
	movem   (a0),d0-d3      
	lea     POLY_56,a1
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLYL_10
	move    #$5240,POLYL_29
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   POLYL_19
	move    d0,(a1)
	addq    #4,a1
	bra.s   POLYL_23
POLYL_19        tst     d4      ;sens sur les X?
	bgt.s   POLYL_0
	move    #$5340,POLYL_10
	move    #$5340,POLYL_29
	neg     d4
POLYL_0 move    d5,d6
	cmp     d5,d4
	blt.s   POLYL_11
;       ligne hz
	move    d4,d6
	neg     d6
POLYL_10        addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLYL_10        ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLYL_10        ;non => on boucle...
	bra.s   POLYL_23        ;apres...
; ligne ve
POLYL_11        move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLYL_12        ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLYL_29        addq    #1,d0   ;X=X+1
POLYL_12        cmp     d1,d3   ;on est arrive?
	bne.s   POLYL_11        ;non on boucle...
POLYL_23
;
;       (ligne 2,3)
;
	lea     polyform1+4,a0
	movem   (a0),d0-d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLYL_13
	move    #$5240,POLYL_27
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   POLYL_22
	move    d0,(a1)
	addq    #4,a1
	bra.s   POLYL_5
POLYL_22        tst     d4      ;sens sur les X?
	bgt.s   POLYL_24
	move    #$5340,POLYL_13
	move    #$5340,POLYL_27
	neg     d4
POLYL_24        move    d5,d6
	cmp     d5,d4
	blt.s   POLYL_14
	move    d4,d6
	neg     d6
;       ligne hz
POLYL_13        addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLYL_13        ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLYL_13        ;non => on boucle...
	bra.s   POLYL_5 ;apres...
; ligne ve
POLYL_14        move    d0,(a1)
	addq    #4,a1
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLYL_15        ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLYL_27        addq    #1,d0   ;X=X+1
POLYL_15        cmp     d1,d3   ;on est arrive?
	bne.s   POLYL_14        ;non on boucle...
POLYL_5
;
;       (ligne 3,4)
;
POLYL_26        lea     polyform1+8,a0
	movem   (a0)+,d0-d3
	move    d3,d5
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLYL_16
	move    #$5240,POLYL_28
	sub     d1,d5   ;Dy dans D5
	bne.s   POLYL_25
	move    d0,(a1)+
	bra.s   POLYL_8
POLYL_25        tst     d4      ;sens sur les X?
	bgt.s   POLYL_6
	move    #$5340,POLYL_16
	move    #$5340,POLYL_28
	neg     d4
POLYL_6 move    d5,d6
	cmp     d5,d4
	blt.s   POLYL_17
;       ligne hz
	move    d4,d6
	neg     d6
POLYL_16        addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLYL_16        ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLYL_16        ;non => on boucle...
	bra.s   POLYL_8 ;apres...
; ligne ve
POLYL_17        move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLYL_18        ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLYL_28        addq    #1,d0   ;X=X+1
POLYL_18        cmp     d1,d3   ;on est arrive?
	bne.s   POLYL_17        ;non on boucle...
;
;       (ligne 1,4)
;
POLYL_8 lea     POLY_56+2,a1
	lea     polyform1,a0
	move    (a0),d0
	move    2(a0),d1
	move    12(a0),d2
	move    14(a0),d3
	move    d2,d4
	sub     d0,d4   ;Dx dans D4
	move    #$5240,POLYL_63
	move    #$5240,POLYL_65
	move    d3,d5
	sub     d1,d5   ;Dy dans D5
	bne.s   POLYL_61
	move    d0,(a1)+
	bra.s   POLY_60
POLYL_61        tst     d4      ;sens sur les X?
	bgt.s   POLYL_62
	move    #$5340,POLYL_63
	move    #$5340,POLYL_65
	neg     d4
POLYL_62        move    d5,d6
	cmp     d5,d4
	blt.s   POLYL_64
;       ligne hz
	move    d4,d6
	neg     d6
POLYL_63        addq    #1,d0   ;X=X+1
	add     d5,d6   ;correction erreur
	blt.s   POLYL_63        ;negative,on boucle...
	sub     d4,d6   ;correction erreur
	move    d0,(a1) ;sauver X dans la polyfill
	addq    #4,a1   ;deplacer la polyfill
	cmp     d0,d2   ;on a fini?
	bne.s   POLYL_63        ;non => on boucle...
	bra.s   POLY_60 ;apres...
; ligne ve
POLYL_64        move    d0,(a1) ;sauver X de la polyfill
	addq    #4,a1   ;deplacer la polyfill
	addq    #1,d1   ;Y=Y+1
	sub     d4,d6   ;correction erreur
	bgt.s   POLYL_66        ;positive alors on verifie =>P2
	add     d5,d6   ;correction erreur
POLYL_65        addq    #1,d0   ;X=X+1
POLYL_66        cmp     d1,d3   ;on est arrive?
	bne.s   POLYL_64        ;non on boucle...


;
;       ACTE 3:tracer la polyfill.
;
POLY_60 lea     POLY_56,a1              ;table des coordonnes X
	move    POLY_52,d0              ;D0 = debut de la polyfill
	mulu    #160,d0         ;octet a sauter
	move.l  POLY_as,a0              ;a0 de but de l'ecran
	add.l   d0,a0           ;a0 adresse de depart
	move    POLY_51,d4              ;D4 =nb de ligne hz a trace 
	subq    #1,d4           ;-1 pour le dbra
POLY_AM2        move    #$ffff,d3               ;motif de remplissage
	cmp     #-1,d3
	beq.s   POLY_PT
	btst    #0,POLY_52+1
	bne.s   POLY_PT
	rol     d3
POLY_PT lea     POLY_54,a4
	lea     POLY_55,a5

POLY_30 move    (a1)+,d0                ;coordonne droite dans D0
	move    (a1)+,d2                ;coordonne gauche dans D2
	cmp     d0,d2           ;dans le bon sens d0,d2?
	bgt.s   POLY_67         ;sinon
	exg     d0,d2           ;on renverse
POLY_67 lsl     #2,d0           ;Xd * 4
	lea     (a4,d0.w),a2    ;A2 sur le bon morceau
	move    (a2)+,d7                ;morceau droit a OR dans D7
	move    (a2)+,d1                ;octets a + au bord
	lsl     #2,d2           ;Xg * 4
	lea     (a5,d2.w),a2    ;A2 sur le bon morceau
	move    (a2)+,d6                ;le morceau dans D6
	move    (a2)+,d2                ;octets a + au bord
	move    d2,d0           ;D0 = D1
	sub     d1,d0           ;D0 = D1-D2
	lea     (a0,d1.w),a3    ;A3 = A0 + D2
	lea     160(a0),a0              ;A0 sur la ligne suivante
POLY_AM1        lea     POLY_53,a2              ;A2 sur la table des saut
	lsr     d0              ;decalage D0 pour le jmp
	add     d0,a2           ;A2 sur l'adresse du JMP
	move.l  (a2),a2         ;A2 sur le JMP a faire
	jmp     (a2)            ;JMP fait...
;
;       routines de remplissage sans trame
;
POLY_31 and     d7,d6
	or      d6,(a3)
	dbra    d4,POLY_30
	rts
POLY_32 or      d7,(a3)
	or      d6,8(a3)
	dbra    d4,POLY_30
	rts
POLY_33 or      d7,(a3)
	move    d3,8(a3)
	or      d6,16(a3)
	dbra    d4,POLY_30
	rts
POLY_34 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	or      d6,24(a3)
	dbra    d4,POLY_30
	rts
POLY_35 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	or      d6,32(a3)
	dbra    d4,POLY_30
	rts
POLY_36 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	or      d6,40(a3)
	dbra    d4,POLY_30
	rts
POLY_37 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	or      d6,48(a3)
	dbra    d4,POLY_30
	rts
POLY_38 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	or      d6,56(a3)
	dbra    d4,POLY_30
	rts
POLY_39 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	or      d6,64(a3)
	dbra    d4,POLY_30
	rts
POLY_40 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	or      d6,72(a3)
	dbra    d4,POLY_30
	rts
POLY_41 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	or      d6,80(a3)
	dbra    d4,POLY_30
	rts
POLY_42 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	or      d6,88(a3)
	dbra    d4,POLY_30
	rts
POLY_43 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	or      d6,96(a3)
	dbra    d4,POLY_30
	rts
POLY_44 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	or      d6,104(a3)
	dbra    d4,POLY_30
	rts
POLY_45 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	or      d6,112(a3)
	dbra    d4,POLY_30
	rts
POLY_46 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	or      d6,120(a3)
	dbra    d4,POLY_30
	rts
POLY_47 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	or      d6,128(a3)
	dbra    d4,POLY_30
	rts
POLY_48 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	or      d6,136(a3)
	dbra    d4,POLY_30
	rts
POLY_49 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	move    d3,136(a3)
	or      d6,144(a3)
	dbra    d4,POLY_30
	rts
POLY_50 or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	move    d3,136(a3)
	move    d3,144(a3)
	or      d6,156(a3)
	dbra    d4,POLY_30
	rts
;
;       routines de remplissage avec trame
;
POLYT_31        and     d7,d6
	and     d3,d6
	or      d6,(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_32        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	or      d6,8(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_33        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	or      d6,16(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_34        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	or      d6,24(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_35        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	or      d6,32(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_36        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	or      d6,40(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_37        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	or      d6,48(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_38        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	or      d6,56(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_39        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	or      d6,64(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_40        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	or      d6,72(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_41        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	or      d6,80(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_42        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	or      d6,88(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_43        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	or      d6,96(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_44        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	or      d6,104(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_45        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	or      d6,112(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_46        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	or      d6,120(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_47        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	or      d6,128(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_48        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	or      d6,136(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_49        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	move    d3,136(a3)
	or      d6,144(a3)
	rol     d3
	dbra    d4,POLY_30
	rts
POLYT_50        and     d3,d7
	and     d3,d6
	or      d7,(a3)
	move    d3,8(a3)
	move    d3,16(a3)
	move    d3,24(a3)
	move    d3,32(a3)
	move    d3,40(a3)
	move    d3,48(a3)
	move    d3,56(a3)
	move    d3,64(a3)
	move    d3,72(a3)
	move    d3,80(a3)
	move    d3,88(a3)
	move    d3,96(a3)
	move    d3,104(a3)
	move    d3,112(a3)
	move    d3,120(a3)
	move    d3,128(a3)
	move    d3,136(a3)
	move    d3,144(a3)
	or      d6,156(a3)
	rol     d3
	dbra    d4,POLY_30
	rts

;===================================
;       interruption VBL
;===================================
vbl     clr.b   vblflg
	IFNE VBLTIM     = 1
	addq    #1,nb2vbl
	ENDC
	movem.l d0-a6,-(sp)
	jsr     zic+8
	movem.l (sp)+,d0-a6
	rte

;==========================================================================
;
;
	section data
;
;
;===========================================================================
zic     incbin  e:\sources\SOURCES.S\TRIDI\zik.mai
	even
objet1  
;       definition d'un objet tridimentionnel
; la table est forme comme suit:        
;       dc.w  nombre de points -1
;       dc.l  X1,Y1,Z1 (premier point)
;       dc.l  X2,Y2,Z2 (deusieme point)
;       dc.l  ....
	dc.w    72-1

 dc.l 200,0,1200
 dc.l 173,0,1300
 dc.l 100,0,1373
 dc.l 0,0,1400
 dc.l -100,0,1373
 dc.l -174,0,1300
 dc.l -200,0,1200
 dc.l -174,0,1100
 dc.l -100,0,1026
 dc.l 0,0,1000
 dc.l 100,0,1026
 dc.l 173,0,1100
 dc.l 173,100,1200
 dc.l 149,86,1300
 dc.l 86,50,1373
 dc.l -87,-50,1373
 dc.l -150,-87,1300
 dc.l -174,-100,1200
 dc.l -150,-87,1100
 dc.l -87,-50,1026
 dc.l 86,50,1026
 dc.l 149,86,1100
 dc.l 100,173,1200
 dc.l 86,149,1300
 dc.l 50,86,1373
 dc.l -50,-87,1373
 dc.l -87,-150,1300
 dc.l -100,-174,1200
 dc.l -87,-150,1100
 dc.l -50,-87,1026
 dc.l 50,86,1026
 dc.l 86,149,1100
 dc.l 0,200,1200
 dc.l 0,173,1300
 dc.l 0,100,1373
 dc.l 0,-100,1373
 dc.l 0,-174,1300
 dc.l 0,-200,1200
 dc.l 0,-174,1100
 dc.l 0,-100,1026
 dc.l 0,100,1026
 dc.l 0,173,1100
 dc.l -100,173,1200
 dc.l -87,149,1300
 dc.l -50,86,1373
 dc.l 50,-87,1373
 dc.l 86,-150,1300
 dc.l 100,-174,1200
 dc.l 86,-150,1100
 dc.l 50,-87,1026
 dc.l -50,86,1026
 dc.l -87,149,1100
 dc.l -174,100,1200
 dc.l -150,86,1300
 dc.l -87,50,1373
 dc.l 86,-50,1373
 dc.l 149,-87,1300
 dc.l 173,-100,1200
 dc.l 149,-87,1100
 dc.l 86,-50,1026
 dc.l -87,50,1026
 dc.l -150,86,1100
 dc.l -120,-150,1200
 dc.l -90,150,1200
 dc.l -60,-50,1200
 dc.l 0,-150,1200
 dc.l -30,150,1200
 dc.l 10,150,1200
 dc.l 100,75,1200
 dc.l 10,-50,1200
 dc.l 70,-100,1200
 dc.l 10,-150,1200

link1   
;       dc.w nombre d'objets-1
;
;dc.w Pa,Pb,Pc,Pd,Pl (premier objet avec les pts a,b,c,d sur le plan Pl)
;       dc.l type de l'objet
	dc.w    40-1
Z       set     0

* couvercle d'en haut
	dc.w    3,4,15,3,0
	dc.l    poly3t
	dc.w    3,25,35,3,0
	dc.l    poly3
	dc.w    3,24,34,3,0
	dc.l    poly3t
	dc.w    3,2,14,3,0
	dc.l    poly3
	dc.w    3,54,44,3,0
	dc.l    poly3 
	dc.w    3,55,45,3,0
	dc.l    poly3t
*       permier anneau
	dc.w    15,25,16,26,0
	dc.l    poly4t
	dc.w    35,45,36,46,0
	dc.l    poly4
	dc.w    14,24,13,23,0
	dc.l    poly4
	dc.w    34,44,33,43,0
	dc.l    poly4t
	dc.w    4,54,5,53,0
	dc.l    poly4
	dc.w    55,2,56,1,0
	dc.l    poly4t
*       deuxieme anneau
	dc.w    26,36,27,37,0
	dc.l    poly4t
	dc.w    46,56,47,57,0
	dc.l    poly4
	dc.w    5,16,6,17,0
	dc.l    poly4 
	dc.w    23,33,22,32,0
	dc.l    poly4
	dc.w    43,53,42,52,0
	dc.l    poly4t
	dc.w    1,13,0,12,0
	dc.l    poly4t
*       troisieme anneau
	dc.w    37,47,38,48,0
	dc.l    poly4t
	dc.w    52,6,61,7,0
	dc.l    poly4t
	dc.w    32,42,41,51,0
	dc.l    poly4
	dc.w    12,22,21,31,0
	dc.l    poly4t
	dc.w    57,0,58,11,0
	dc.l    poly4
	dc.w    17,27,18,28,0
	dc.l    poly4
*       quatrieme anneau
	dc.w    30,40,31,41,0
	dc.l    poly4t
	dc.w    50,60,51,61,0
	dc.l    poly4
	dc.w    28,38,29,39,0
	dc.l    poly4
	dc.w    48,58,49,59,0
	dc.l    poly4t
	dc.w    10,20,11,21,0
	dc.l    poly4
	dc.w    8,19,7,18,0
	dc.l    poly4t
*       couvercle d'en bas
	dc.w    9,19,29,9,0
	dc.l    poly3t
	dc.w    9,39,49,9,0
	dc.l    poly3
	dc.w    9,8,60,9,0
	dc.l    poly3
	dc.w    9,10,59,9,0
	dc.l    poly3t
	dc.w    9,20,30,9,0
	dc.l    poly3
	dc.w    9,40,50,9,0
	dc.l    poly3t
*       les objets interrieurs
	dc.w    62,63,64,64,2
	dc.l    poly3
	dc.w    66,65,64,64,2
	dc.l    poly3
	dc.w    67,68,69,69,4
	dc.l    poly3
	dc.w    71,70,69,69,4
	dc.l    poly3
objet2  
;       definition d'un objet tridimentionnel
; la table est forme comme suit:        
;       dc.w  nombre de points -1
;       dc.l  X1,Y1,Z1 (premier point)
;       dc.l  X2,Y2,Z2 (deusieme point)
;       dc.l  ....
;       dc.w nombre de lignes -1
;       dc.w Pa,Pb (premiere ligne du point a au point b)
;       dc.w Pc,Pd (deusieme ligne du point c au point d)
;       dc.w Pe,Pf (troisieme ligne du point e au point f)
	dc.w    14-1
	dc.l    -150,-150,250
	dc.l    -150,150,250
	dc.l    150,-150,250
	dc.l    150,150,250
	dc.l    -150,-150,550
	dc.l    -150,150,550
	dc.l    150,-150,550
	dc.l    150,150,550
	dc.l    0,0,250
	dc.l    0,0,550
	dc.l    -150,0,400
	dc.l    150,0,400
	dc.l    0,-150,400
	dc.l    0,150,400
	
link2
;       dc.w nombre de lignes -1
;       dc.w Pa,Pb (premiere ligne du point a au point b)
;       dc.w Pc,Pd (deusieme ligne du point c au point d)
;       dc.w Pe,Pf (troisieme ligne du point e au point f)
	dc.w    20-1
	dc.w    0,1
	dc.w    1,3
	dc.w    2,3
	dc.w    2,0
	dc.w    4,5
	dc.w    5,7
	dc.w    6,7
	dc.w    6,4
	dc.w    0,4
	dc.w    1,5
	dc.w    2,6
	dc.w    3,7
	dc.w    8,10
	dc.w    10,9
	dc.w    9,11
	dc.w    11,8
	dc.w    8,12
	dc.w    12,9
	dc.w    9,13
	dc.w    13,8
;
;       objet 5: PRINST
;
objet5  dc.w    30-1
	dc.l    -200,-100,400
	dc.l    -200,0,400
	dc.l    -200,100,400
	dc.l    -160,-100,400
	dc.l    -160,0,400
	dc.l    -120,-100,400
	dc.l    -120,0,400
	dc.l    -120,100,400
	dc.l    -80,-100,400
	dc.l    -80,0,400
	dc.l    -80,100,400
	dc.l    -40,-100,400
	dc.l    -40,100,400
	dc.l    0,-100,400
	dc.l    0,100,400
	dc.l    40,-100,400
	dc.l    40,0,400
	dc.l    40,100,400
	dc.l    -200,120,400
	dc.l    120,120,400
	dc.l    120,0,400
	dc.l    80,0,400
	dc.l    80,-100,400
	dc.l    200,-100,400
	dc.l    160,-100,400
	dc.l    160,120,400
	dc.l    150,70,400
	dc.l    170,70,400
	dc.l    -150,110,400
	dc.l    -150,130,400

link5   dc.w    23-1
	dc.w    0,2
	dc.w    0,3
	dc.w    3,4
	dc.w    4,1
	dc.w    5,7
	dc.w    5,8
	dc.w    8,9
	dc.w    9,6
	dc.w    6,10
	dc.w    11,12
	dc.w    13,14
	dc.w    13,16
	dc.w    15,17
	dc.w    18,19
	dc.w    19,20
	dc.w    20,21
	dc.w    21,22
	dc.w    22,23
	dc.w    24,25
	dc.w    25,26
	dc.w    25,27
	dc.w    28,18
	dc.w    29,18
;
;       6eme objet: les lunettes
;
objet6  dc.w    12-1
	dc.l    200,100,300
	dc.l    200,0,300
	dc.l    50,100,300
	dc.l    50,0,300
	dc.l    -50,100,300
	dc.l    -50,0,300
	dc.l    -200,100,300
	dc.l    -200,0,300
	dc.l    200,100,550
	dc.l    -200,100,550
	dc.l    200,0,600
	dc.l    -200,0,600
link6   dc.w    13-1
	dc.w    0,2
	dc.w    2,4
	dc.w    4,6
	dc.w    0,1
	dc.w    2,3
	dc.w    1,3
	dc.w    4,5
	dc.w    6,7
	dc.w    5,7
	dc.w    0,8
	dc.w    6,9
	dc.w    8,10
	dc.w    9,11

objet3  
;       definition d'un objet tridimentionnel
; la table est forme comme suit:        
;       dc.w  nombre de boule -1
;       dc.l  X1,Y1,Z1 (premiere boule)
;       dc.l  X2,Y2,Z2 (deusieme boule)
;       dc.l  ....
;       dc.l  Xn,Yn,Zn (derniere boule)
;
	dc.w    21-1
	dc.l    30,-200,400
	dc.l    30,-150,400
	dc.l    30,-100,400
	dc.l    30,-50,400
	dc.l    30,0,400
	dc.l    30,50,400
	dc.l    30,100,400
	dc.l    30,150,400
	dc.l    30,200,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400
	dc.l    0,0,400

objet4  dc.w    22-1
	dc.l    0,-170,400
	dc.l    -40,-140,400
	dc.l    -40,-110,400
	dc.l    0,-80,400
	dc.l    40,-140,400
	dc.l    40,-110,400
	dc.l    0,-40,400
	dc.l    -40,-40,400
	dc.l    -60,-10,440
	dc.l    -80,20,480
	dc.l    40,-40,400
	dc.l    60,-10,360
	dc.l    80,20,320
	dc.l    0,0,400
	dc.l    0,40,400
	dc.l    0,80,400
	dc.l    -30,120,400
	dc.l    30,120,400
	dc.l    -60,160,400
	dc.l    60,160,400
	dc.l    -90,200,400
	dc.l    90,200,400

o5objet1        
;       definition d'un objet tridimentionnel
; la table est forme comme suit:        
;       dc.w  nombre de points -1
;       dc.l  X1,Y1,Z1 (premier point)
;       dc.l  X2,Y2,Z2 (deusieme point)
;       dc.l  ....
;       dc.w nombre de lignes -1
;       dc.w Pa,Pb (premiere ligne du point a au point b)
;       dc.w Pc,Pd (deusieme ligne du point c au point d)
;       dc.w Pe,Pf (troisieme ligne du point e au point f)
	dc.w    8-1
	dc.l    -109,-109,291
	dc.l    -109,109,291
	dc.l    109,-109,291
	dc.l    109,109,291
	dc.l    -109,-109,509
	dc.l    -109,109,509
	dc.l    109,-109,509
	dc.l    109,109,509

	dc.w    18-1
	dc.l    50,0,250
	dc.l    25,43,250
	dc.l    -25,43,250
	dc.l    -50,0,250
	dc.l    -25,-43,250
	dc.l    25,-43,250
	dc.l    100,0,400
	dc.l    50,86,400
	dc.l    -50,86,400
	dc.l    -100,0,400
	dc.l    -50,-86,400
	dc.l    50,-86,400
	dc.l    50,0,550
	dc.l    25,43,550
	dc.l    -25,43,550
	dc.l    -50,0,550
	dc.l    -25,-43,550
	dc.l    25,-43,550

o5link1 
;       dc.w nombre de polyfills -1
;dc.w Pa,Pb,Pc,Pd,Pl (premiere polyfil avec les pts a,b,c,d sur le plan Pl)
	dc.w    5
	dc.w    0,1,2,3,0
	dc.w    4,5,6,7,0
	dc.w    0,1,4,5,2
	dc.w    2,3,6,7,2
	dc.w    0,2,4,6,4
	dc.w    1,3,5,7,6

	dc.w    5
	dc.w    0,6,7,1,0
	dc.w    1,7,8,2,2
	dc.w    2,8,9,3,0
	dc.w    3,9,10,4,2
	dc.w    4,10,11,5,0
	dc.w    5,11,6,0,2

	
	IFNE VBLTIM = 1
vblcom  dc.w    %0000000000000000
	dc.w    %0111110001111100
	dc.w    %0100000010000010
	dc.w    %0100000010000010
	dc.w    %0111100010000010
	dc.w    %0000010010000010
	dc.w    %0000010010000010
	dc.w    %0111100001111100
	dc.w    %0000000000000000
	dc.w    %0111110001111110
	dc.w    %0000010001000000
	dc.w    %0000010001000000
	dc.w    %0111110001111100
	dc.w    %0100000000000010
	dc.w    %0100000000000010
	dc.w    %0111110001111100
	dc.w    %0000000000000000
	dc.w    %0001100001111110
	dc.w    %0010100001000000
	dc.w    %0100100001000000
	dc.w    %0000100001111110
	dc.w    %0000100001000010
	dc.w    %0000100001000010
	dc.w    %0000100001111110
	dc.w    %0000000000000000
	dc.w    %0001100001111110
	dc.w    %0010100000000010
	dc.w    %0010100000000010
	dc.w    %0100100001111110
	dc.w    %0000100001000000
	dc.w    %0000100001000000
	dc.w    %0000100001111110
	dc.w    %0000000000000000
	dc.w    %0001100001111110
	dc.w    %0010100001000010
	dc.w    %0100100001000010
	dc.w    %0000100001000010
	dc.w    %0000100001000010
	dc.w    %0000100001000010
	dc.w    %0000100001111110
	dc.w    %0000000000000000
	dc.w    %0000011111110000
	dc.w    %0000010000010000
	dc.w    %0000010000010000
	dc.w    %0000011111110000
	dc.w    %0000010000010000
	dc.w    %0000010000010000
	dc.w    %0000011111110000
	dc.w    %0000000000000000
	dc.w    %0000011111110000
	dc.w    %0000000000010000
	dc.w    %0000000000010000
	dc.w    %0000000111111100
	dc.w    %0000000000100000
	dc.w    %0000000001000000
	dc.w    %0000000001000000
	ENDC
gfxboule        incbin  gfxboule.inc
trigo   incbin  cosin.inc
last    incbin  last.inc
endlast
	even
Z       set     0
POLY_54 
	rept    20
	dc.w    %1111111111111111,Z
	dc.w    %0111111111111111,Z
	dc.w    %0011111111111111,Z
	dc.w    %0001111111111111,Z
	dc.w    %0000111111111111,Z
	dc.w    %0000011111111111,Z
	dc.w    %0000001111111111,Z
	dc.w    %0000000111111111,Z
	dc.w    %0000000011111111,Z
	dc.w    %0000000001111111,Z
	dc.w    %0000000000111111,Z
	dc.w    %0000000000011111,Z
	dc.w    %0000000000001111,Z
	dc.w    %0000000000000111,Z
	dc.w    %0000000000000011,Z
	dc.w    %0000000000000001,Z
Z       set     Z+8
	endr
Z       set     0
POLY_55 
	rept    20
	dc.w    %1000000000000000,Z
	dc.w    %1100000000000000,Z
	dc.w    %1110000000000000,Z
	dc.w    %1111000000000000,Z
	dc.w    %1111100000000000,Z
	dc.w    %1111110000000000,Z
	dc.w    %1111111000000000,Z
	dc.w    %1111111100000000,Z
	dc.w    %1111111110000000,Z
	dc.w    %1111111111000000,Z
	dc.w    %1111111111100000,Z
	dc.w    %1111111111110000,Z
	dc.w    %1111111111111000,Z
	dc.w    %1111111111111100,Z
	dc.w    %1111111111111110,Z
	dc.w    %1111111111111111,Z
Z       set     Z+8
	endr
Z       set     0
psettab 
	rept    20
	dc.w    %1000000000000000,Z
	dc.w    %0100000000000000,Z
	dc.w    %0010000000000000,Z
	dc.w    %0001000000000000,Z
	dc.w    %0000100000000000,Z
	dc.w    %0000010000000000,Z
	dc.w    %0000001000000000,Z
	dc.w    %0000000100000000,Z
	dc.w    %0000000010000000,Z
	dc.w    %0000000001000000,Z
	dc.w    %0000000000100000,Z
	dc.w    %0000000000010000,Z
	dc.w    %0000000000001000,Z
	dc.w    %0000000000000100,Z
	dc.w    %0000000000000010,Z
	dc.w    %0000000000000001,Z
Z       set     Z+8
	endr

POLY_53 dc.l    POLY_31,POLY_32,POLY_33,POLY_34,POLY_35
	dc.l    POLY_36,POLY_37,POLY_38,POLY_39,POLY_40
	dc.l    POLY_41,POLY_42,POLY_43,POLY_44,POLY_45
	dc.l    POLY_46,POLY_47,POLY_48,POLY_49,POLY_50

POLYT_53        dc.l    POLYT_31,POLYT_32,POLYT_33,POLYT_34,POLYT_35
	dc.l    POLYT_36,POLYT_37,POLYT_38,POLYT_39,POLYT_40
	dc.l    POLYT_41,POLYT_42,POLYT_43,POLYT_44,POLYT_45
	dc.l    POLYT_46,POLYT_47,POLYT_48,POLYT_49,POLYT_50

o5POLY_53       dc.l    o5POLY_31,o5POLY_32,o5POLY_33,o5POLY_34,o5POLY_35
	dc.l    o5POLY_36,o5POLY_37,o5POLY_38,o5POLY_39,o5POLY_40
	dc.l    o5POLY_41,o5POLY_42,o5POLY_43,o5POLY_44,o5POLY_45
	dc.l    o5POLY_46,o5POLY_47,o5POLY_48,o5POLY_49,o5POLY_50

o4POLY_53       dc.l    o4POLY_31,o4POLY_32,o4POLY_33,o4POLY_34,o4POLY_35
	dc.l    o4POLY_36,o4POLY_37,o4POLY_38,o4POLY_39,o4POLY_40
	dc.l    o4POLY_41,o4POLY_42,o4POLY_43,o4POLY_44,o4POLY_45
	dc.l    o4POLY_46,o4POLY_47,o4POLY_48,o4POLY_49,o4POLY_50


polyform1       
	dc.w    60,80
	dc.w    160,199
	dc.w    100,80
	dc.w    160,0
	dc.l    screens
o5dsttab        incbin  dsttab.inc

o4objet1        
;       definition d'un objet tridimentionnel
; la table est forme comme suit:        
;       dc.w  nombre de points -1
;       dc.l  X1,Y1,Z1 (premier point)
;       dc.l  X2,Y2,Z2 (deusieme point)
;       dc.l  ....
;       dc.w nombre de lignes -1
;       dc.w Pa,Pb (premiere ligne du point a au point b)
;       dc.w Pc,Pd (deusieme ligne du point c au point d)
;       dc.w Pe,Pf (troisieme ligne du point e au point f)
	dc.w    8-1
	dc.l    -115,-115,280
	dc.l    -115,115,280
	dc.l    115,-115,280
	dc.l    115,115,280
	dc.l    -115,-115,520
	dc.l    -115,115,520
	dc.l    115,-115,520
	dc.l    115,115,520

o4hide  dc.l    0,0,250
	dc.l    0,0,550
	dc.l    -150,0,400
	dc.l    150,0,400
	dc.l    0,-150,400
	dc.l    0,150,400

o4link1 
;       dc.w nombre de polyfills -1
;dc.w Pa,Pb,Pc,Pd,Pl (premiere polyfil avec les pts a,b,c,d sur le plan Pl)

	dc.w    5
	dc.w    0,1,2,3,0
	dc.w    4,5,6,7,0
	dc.w    0,1,4,5,2
	dc.w    2,3,6,7,2
	dc.w    0,2,4,6,4
	dc.w    1,3,5,7,6

o4color dc.l    $ffff8242
	dc.l    $ffff8244
	dc.l    $ffff8248
	dc.l    $ffff8250

o4teintes1      dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $110
	dc.w    $110
	dc.w    $221
	dc.w    $221
	dc.w    $332
	dc.w    $332
	dc.w    $442
	dc.w    $553
	dc.w    $663
	dc.w    $774
	dc.w    $774
	dc.w    $774
	dc.w    $774
o4teintes2      dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $011
	dc.w    $011
	dc.w    $122
	dc.w    $122
	dc.w    $233
	dc.w    $233
	dc.w    $244
	dc.w    $355
	dc.w    $366
	dc.w    $477
	dc.w    $477
	dc.w    $477
	dc.w    $477
o4teintes3      dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $101
	dc.w    $101
	dc.w    $212
	dc.w    $212
	dc.w    $323
	dc.w    $323
	dc.w    $424
	dc.w    $535
	dc.w    $636
	dc.w    $747
	dc.w    $747
	dc.w    $747
	dc.w    $747
o4teintes4      dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $111
	dc.w    $111
	dc.w    $222
	dc.w    $222
	dc.w    $333
	dc.w    $333
	dc.w    $444
	dc.w    $555
	dc.w    $666
	dc.w    $777
	dc.w    $777
	dc.w    $777
	dc.w    $777

teintes1        dcb.w   22,$333
	dcb.w   22,$555
	dcb.w   22,$777
	dcb.w   22,$733
	
teintes2        dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $110
	dc.w    $110
	dc.w    $221
	dc.w    $221
	dc.w    $332
	dc.w    $332
	dc.w    $442
	dc.w    $553
	dc.w    $663
	dc.w    $774
	dc.w    $774
	dc.w    $774
	dc.w    $774
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $011
	dc.w    $011
	dc.w    $122
	dc.w    $122
	dc.w    $233
	dc.w    $233
	dc.w    $244
	dc.w    $355
	dc.w    $366
	dc.w    $477
	dc.w    $477
	dc.w    $477
	dc.w    $477
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $101
	dc.w    $101
	dc.w    $212
	dc.w    $212
	dc.w    $323
	dc.w    $323
	dc.w    $424
	dc.w    $535
	dc.w    $636
	dc.w    $747
	dc.w    $747
	dc.w    $747
	dc.w    $747
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $000
	dc.w    $111
	dc.w    $111
	dc.w    $222
	dc.w    $222
	dc.w    $333
	dc.w    $333
	dc.w    $444
	dc.w    $555
	dc.w    $666
	dc.w    $777
	dc.w    $777
	dc.w    $777
	dc.w    $777

;
;
;
	section bss
;
;
;



adrlog  ds.l    1
adrphy  ds.l    1
adrdis  ds.l    1
adrobj  ds.l    1
adrlnk  ds.l    1
adrefp  ds.l    1
adrefl  ds.l    1
adrmvt  ds.l    1
POLY_as ds.l    1
Zmvt    ds.l    1
Ymvt    ds.l    1
Xmvt    ds.l    1
objetok ds.l    256*3
hide    ds.l    256*3
eff1    ds.l    256
eff2    ds.l    256

POLY_52 ds.w    1
POLY_51 ds.w    1
POLY_56 ds.w    1200
objet2d ds.w    256*2
linkok  ds.w    100*5
nbpoly  ds.w    1
compt   ds.w    1
nb2vbl  ds.w    1
p1s2    ds.w    1
palette ds.w    16
zoom    ds.w    1
timer   ds.w    1
xdec    ds.w    1
oblst   ds.w    1

vblflg  ds.b    1
h25     ds.b    1
;
;       les ecrans
;
screens ds.b    64256


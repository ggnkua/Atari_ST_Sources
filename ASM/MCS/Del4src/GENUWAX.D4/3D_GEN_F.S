* 18/03/92	2
	opt o+,o1+,o2+,ow-
test_p=0
nb_ligne=200
nb_ecran=3

nb_etoiles=500
nb_objet_max=10
nb_som_f_m=8
nb_face_max=60
nb_somm_max=(nb_face_max*nb_som_f_m*nb_objet_max)/6

;dos=1
;bios=13
;xbios=14
;esc=27 

;ecran=$44e
palette=$ffff8240
chipvideo=$ffff8205	* resolution = $ff8260 , 0:basse , 1:moyenne
chipsonore=$ffff8800
ctrlb=$fffffa1b
datab=$fffffa21
dma=$ffff8604
clavier=$fffffc02
vbl=$70
;vblqueue=$4ce+4
timerb=$120

save:	macro \1
	movem.l \1,-(sp)
	endm

load:	macro \1
	movem.l (sp)+,\1
	endm

save_w	macro \1
	movem.w \1,-(sp)
	endm

load_w:	macro \1
	movem.w (sp)+,\1
	endm

appel:	macro
	move.w #\2,-(sp)
	trap #\1
	add.l #\3,sp
	ifne '\4','save'
	load d0-d7/a0-a6
	endc
	endm

wait:	macro
	appel dos,7,2
	endm

resolut:	macro \1,\2
	save d0-d7/a0-a6
	move.w #\1,-(sp)
	move.l \2,-(sp)
	move.l \2,-(sp)
	appel xbios,5,12
	load d0-d7/a0-a6
	endm

init:	macro
 	bss
	ds.l 75
ma_pile:	ds.l 10
	text
	endm

supervisor: macro
	clr.l -(sp)
	appel dos,$20,6
	move.l d0,mpile
 BSS
mpile:	ds.l 1
 TEXT
	endm
 
user:	macro
	move.l mpile,-(sp)
	appel dos,$20,6
	endm

syncro:	macro
	appel xbios,$25,2		* syncro
	endm

mouseoff:	macro
	pea inhibe(pc)
	clr.w -(sp)
	appel xbios,25,8
 DATA
inhibe:	dc.b $12,0
 TEXT
	endm

mouseon:	macro
	pea default(pc)
	move.w #1,-(sp)
	appel xbios,25,8
 DATA
default:	dc.b $80,$01
 TEXT
	endm

clavoff:	macro
	bclr #6,$fffa09
	endm

clavon:	macro
	bset #6,$fffa09
	endm

clicoff:	macro
	bclr #0,$484
	endm

clicon:	macro
	bset #0,$484
	endm
	
write:	macro
	appel dos,9,6
	endm

 section TEXT
debut:	
	PEA	$0.W
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.W	#6,SP
	MOVE.W	#$2700,SR

	MOVE.B	#$7,$FFFF8201.W
	MOVE.B	#$0,$FFFF8203.W

	MOVE.L	$70.W,AD_70_MAG
	MOVE.L	#VBL_NULL,$70.W

	LEA	$70000,A0
	MOVEQ	#0,D0
	MOVE.W	#7999,D1
EFF_ECRAN_BY_ME
	MOVE.L	D0,(A0)+
	DBRA	D1,EFF_ECRAN_BY_ME

	MOVE.W	#0,$FFFF8240.W
	MOVE.W	#0,$FFFF8242.W
	MOVE.W	#0,$FFFF8244.W
	MOVE.W	#$7,$FFFF8246.W

	LEA	MESS,A0
	BSR	AFF_TXT

	LEA	TAB_D,A0
	MOVE.W	#319,D7
PREPARE
	BSR	RANDOM
	AND.L	#$F,D0
	MULU	#160,D0
	MOVE.W	2(A0),D1
	ADD.W	D0,D1
	MOVE.W	D1,2(A0)
	ADDQ	#4,A0
	DBRA	D7,PREPARE
	MOVE.W	#$2300,SR
WAIT
	TST.W	VBL_FLAG
	BEQ.S	WAIT
	MOVE.W	#0,VBL_FLAG
	LEA	$70000,A1
	MOVE.L	#TAB_D,A0
	MOVE.W	#319,D7
TOMBE
	MOVE.W	(A0),D0
	MOVE.W	2(A0),D1
	CMP.W	#200*160,D1
	BGE.S	PAS_PLOT
	OR.W	D0,(A1,D1.W)
	ADD.W	#160,D1
	MOVE.W	D1,2(A0)
PAS_PLOT
	ADDQ.W	#4,A0
	DBRA	D7,TOMBE

	CMP.B	#$39,$FFFC02
	BNE.S	WAIT

	MOVE.W	#$2700,SR
	MOVE.L	AD_70_MAG,$70.W

	JMP	DEBUT_DEMO

VBL_NULL
	MOVE.W	#1,VBL_FLAG
	RTE
VBL_FLAG
	DC.W	0
AD_70_MAG
	DS.L	1
RANDOM:
                tst.l   OLD_NB
                bne.s   PAS_NUL
                move.l  $FFFA20,D0
                moveq   #16,D1
                asl.l   D1,D0
                or.l    $FFFA20,D0
                move.l  D0,OLD_NB
PAS_NUL:
                move.l  #3141592621,D2
                move.l  OLD_NB,D3
                mulu    D2,D3
                move.l  D3,D0
                addq.l  #1,D0
                move.l  D0,OLD_NB
                asr.l   #8,D0
                and.l   #$FFFFFF,D0
                rts
	
AFF_TXT
;	LEA	ECRAN+2,A1	;****
	LEA	$70000+2,A1
	LEA	TAB_FNT,A2
	MOVE.L	A1,A4
LOOP_TXT
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BEQ.S	FIN_LIG
	CMP.B	#-1,D0
	BEQ.S	FIN_TXT
	SUB.B	#' ',D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.L	(A2,D0.W),A3
	BSR	AFF_CHAR
	ADDQ.W	#1,A4
	MOVEQ	#0,D0
	MOVE.B	(A0)+,D0
	BEQ.S	FIN_LIG
	CMP.B	#-1,D0
	BEQ.S	FIN_TXT
	SUB.B	#' ',D0
	ADD.W	D0,D0
	ADD.W	D0,D0
	MOVE.L	(A2,D0.W),A3
	BSR	AFF_CHAR
	ADDQ.W	#7,A4
	BRA.S	LOOP_TXT
FIN_LIG
	ADD.W	#160*8,A1
	MOVE.L	A1,A4
	BRA.S	LOOP_TXT
FIN_TXT
	RTS
AFF_CHAR
	MOVEQ	#7,D7
	MOVEQ	#0,D6
	MOVEQ	#0,D5
LOOP_CHAR
	MOVE.B	(A3,D5.W),(A4,D6.W)
	ADD.W	#160,D6
	ADD.W	#40,D5
	DBRA	D7,LOOP_CHAR
	RTS

OLD_NB
	DC.L	0
TAB_D
M	SET	0
	REPT	20
	DC.W	32768,M
	DC.W	16384,M
	DC.W	8192,M
	DC.W	4096,M
	DC.W	2048,M
	DC.W	1024,M
	DC.W	512,M
	DC.W	256,M
	DC.W	128,M
	DC.W	64,M
	DC.W	32,M
	DC.W	16,M
	DC.W	8,M
	DC.W	4,M
	DC.W	2,M
	DC.W	1,M
M	SET	M+8
	ENDR
MESS
	DC.B	0,0
	DC.B	'   WELCOME LEMMINGS FAN. YOU WILL SOON',0
	DC.B	'        SEE THE GENUWAX 3D SCREEN.',0
	DC.B	' BUT REMEMBER THIS : NOTHING IS PRECALC',0
	DC.B	' AND THIS IS ONLY A PREVIEW, I SAW LOTSA',0
	DC.B	'     MORE IMPRESSIVE 3D FROM THEM.',0,0
	DC.B	' THIS INTRO WAS FASTLY CODED BY MAGNUM.',0
	DC.B	'IT IS NOT A MASTER PIECE BUT WE HAVE TO',0
	DC.B	'  SEND THE SOURCES TO ALTAIR TOMORROW.',0
	DC.B	'     SORRY, NO TIME FOR BETTER CODE.',0
	DC.B	'  WHY DO PEOPLES CALL ME EVERY TIME THEY',0
	DC.B	'  NEED CODE VERY FASTLY. I AM SO TIRED.',0
	DC.B	'I WANNA SAY THANX AND HI TO ALL THE CREWS',0
	DC.B	'THAT PARTIPATED TO THIS DEMO. IT MEANS :',0
	DC.B	'    THE BLACK CATS, VERY COOL GUYS',0
	DC.B	'  THE STORM BROTHERS, I WAS TOO DRUNK TO',0
	DC.B	'  UNDERSTAND AKIRA, BUT IT LOOKS GREAT',0
	DC.B	'            DEFCON 4, HI TOM.',0
	DC.B	'         GENESIS, PLEASE CONTACT US',0
	DC.B	'       N.G.C. : VIPER, ALL ST MEMBERS',0
	DC.B	' RED DEVIL, I HOPE TO HEAR FROM YOU SOON',0
	DC.B	'   C. MAGNUM 1992. MCS. FRENCH ALLIANCE',0
	DC.B	'YOU CAN BASH SPACE OR TRY THE CHEAT CODE.',-1
	EVEN

TAB_FNT
	REPT	12
	DC.L	NILL_CHAR
	ENDR

	DC.L	FNT+37	* ,
	DC.L	NILL_CHAR
	DC.L	FNT+36	* .
	DC.L	NILL_CHAR

M	SET	26
	REPT	10
	DC.L	FNT+M	* 0-9
M	SET	M+1
	ENDR

	DC.L	FNT+39	* :
	DC.L	FNT+38	* ;

	DC.L	NILL_CHAR
	DC.L	NILL_CHAR
	DC.L	NILL_CHAR
	DC.L	NILL_CHAR
	DC.L	NILL_CHAR

M	SET	0
	REPT	26
	DC.L	FNT+M
M	SET	M+1
	ENDR
FNT
	INCBIN	FNTM.BIN

	EVEN
DEBUT_DEMO
	MOVE.L	A7,OLD_A7
	init

********** I N I T S **********

	move.l #phys1,d0	; multiple de 256
	and.l #$ffffff00,d0
	add.l #$100,d0
	lea ecrans_t,a0
	move.w #nb_ecran-1,d7
def_ecran:
	move.l d0,(a0)+
	add.l #160*nb_ligne,d0
	dbf d7,def_ecran

;	move.l ecran,oldscreen	; sauve ancien

	move.l ecrans_t,a0
	move.w #nb_ecran*160*nb_ligne/4-1,d7
efface_ecran:
	clr.l (a0)+
	dbf d7,efface_ecran

	MOVE.B	ECRANS_T+1,$FFFF8201.W
	MOVE.B	ECRANS_T+2,$FFFF8203.W

	jsr init_tabl(pc)
	jsr init_tabl_et(pc)
	jsr init_pos_obs(pc)
	jsr init_monde(pc)
	move.w #0,flag

	move.w #$2700,sr
	move.l vbl,oldvbl
	ifeq test_p
	movem.l colors,d0-d7
	movem.l d0-d7,palette
	move.l #newvbl,vbl
	jsr init_mouse(pc)
	moveq #2,d0
	move.w d0,mus
	jsr zik
	endc
	move.w #$2300,sr

************ Programme du monde *****************

recom_monde:	jsr mouvements_objet(pc)
	jsr mouvement_observateur(pc)
	jsr efface_ecr(pc)
	jsr traite_etoiles(pc)
	jsr trait_monde(pc)
	bra.s recom_monde

****************  THE  END  *********************

touche_app:
	move.w #$2700,sr
	move.l oldvbl,vbl
	move.l #ma_pile,a7
	jsr mouse_off(pc)

	ifeq test_p
	jsr zik+4
	endc
	move.w #$777,(palette).w
	move.w #$0,(palette+2*3).w

	move.w #$ffff,d0
wait_mfp:	nop
	dbra d0,wait_mfp

	MOVE.L	OLD_A7,A7

	ILLEGAL
OLD_A7
	DS.L	1
***********
a1=2
a2=4
init_mouse:
	move.l $118,old_clav
	move.l #mouse_driver,$118
	move.b #$08,clavier
	jsr wait_clav(pc)
	move.b #$0b,clavier
	jsr wait_clav(pc)
	move.b #1,clavier
	jsr wait_clav(pc)
	move.b #1,clavier
	jsr wait_clav(pc)
	move.b #$10,clavier
	move.b $fffffa17,fa17
	bclr #3,$fffffa17
	rts
wait_clav:	move.b $fffc00,d0
	btst #1,d0
	beq.s wait_clav
	rts
****
mouse_driver:	move.w #$2500,sr
	move.w d0,-(sp)
	move.b clavier,d0
	cmp.b #$f8,d0
	beq.s bouton
	cmp.b #$f9,d0
	beq.s bouton
	cmp.b #$fa,d0
	beq.s bouton
	cmp.b #$fb,d0
	beq.s bouton
	move.b d0,buffer_clav
	move.w (sp)+,d0
	rte
bouton:	and.w #3,d0
	move.w d0,boutons
	move.l #mouse_x,$118
	move.w (sp)+,d0
	rte
mouse_x:	move.b clavier,m_x
	move.l #mouse_y,$118
	rte
mouse_y:	move.b clavier,m_y
	move.l #mouse_driver,$118
	rte
**********
mouse_off:	move.l old_clav,$118
	move.b fa17,$fffffa17
	rts

 BSS
old_clav:	ds.l 1
fa17:	ds.w 1
buffer_clav:	ds.w 1
boutons:	ds.w 1
m_x:	ds.w 1
m_y:	ds.w 1
 TEXT
*********** My belle VBL *****************
newvbl:	move.l d0,-(sp)
	moveq #0,d0
	move.b (clavier).w,d0 
	cmp.b #$39,d0
	bne.s pas_sortie
	move.l #touche_app,2+4(sp)
pas_sortie:	move.l (sp)+,d0
	add.w #1,nb_vbl
	ifeq test_p
	save d0-d7/a0-a6
	jsr zik+2
	load d0-d7/a0-a6
	endc
	tst.w flag
	bne.s swap_ecran
	rte
swap_ecran:	move.w #0,flag
	rte
*********** Traitement du monde ***********
trait_monde:
	jsr visi_obj(pc)
	tst.w d6		* un objet visible ?
	beq.s pas_d_objet

	jsr trie_obj(pc)
	jsr rotation(pc)
	jsr rotation_obs(pc)
	jsr visibilite(pc)
	jsr trie(pc)
	jsr affich_face(pc)
pas_d_objet:
	move.w nb_vbl,d0
	
attend1:	tst.w flag
	ifeq test_p
	bne.s attend1
	endc
	mulu #6*2,d0
	lea chiffre,a0
	add.w d0,a0
	move.l ecrans_t,a1
	movem.w (a0),d0-d5
	move.w d0,(a1)
	add.w #160,a1
	move.w d1,(a1)
	add.w #160,a1
	move.w d2,(a1)
	add.w #160,a1
	move.w d3,(a1)
	add.w #160,a1
	move.w d4,(a1)
	add.w #160,a1
	move.w d5,(a1)
	add.w #160,a1
	move.w #0,nb_vbl

	ifeq test_p
	jsr swapage
	endc
	move.w #1,flag
	rts

	***************************
affich_face:	move.w f_visi,d7
	beq.s no_face
	move.w d7,d6
	subq #1,d7

	lea indice,a0
	lea affich+2,a1

next_face_aff:	move.w (a0)+,d0
	move.l (a1,d0.w),a2	; a2 = def face

	move.w (a2)+,d6	; nb sommet
	lea sommet,a4
	move.w #'p',(a4)+
	move.w d6,(a4)+
	move.w (a2)+,coul
	sub.w #1,d6

recop_sommets:	move.l (a2)+,a3
	move.l (a3),(a4)+
	dbf d6,recop_sommets
 
	movem.l d7/a0/a1,-(sp)
p:	jsr polygone(pc)	* test si affichable
	movem.l (sp)+,d7/a0/a1
	dbf d7,next_face_aff

no_face:	rts

	***************************
trie:	lea indice,a0
	lea affich,a1
	move.w f_visi,d7
	sub.w #2,d7
	bmi.s face_seul
	
	moveq #0,d5		* for i=1 to f_visi-1
next_i:	move.w d7,d6

	move.w d5,d3		* d3 = k
	move.w d5,d4
next_j:	add.w #2,d4		* for j=i+1 to f_visi

	move.w (a0,d4.w),d0	* d0=indice(j)
	move.w (a0,d3.w),d1	* d1=indice(k)
	move.w (a1,d0.w),d0	* d0=zmoyen(indice(j))

	cmp.w (a1,d1.w),d0	* d1=zmoyen(indice(k))
	ble.s pas_sup
	move.w d4,d3

pas_sup:	dbf d6,next_j
	cmp.w d5,d3
	beq.s egalite

	move.l a0,a2
	move.l a0,a3
	add.w d3,a2
	add.w d5,a3
	move.w (a2),d0
	move.w (a3),(a2)
	move.w d0,(a3)

egalite:	add.w #2,d5
	dbf d7,next_i
face_seul:	rts

	***************************
visibilite:	move.w nb_obj_visi,d7	* d7=nb objet visible
	subq #1,d7

	lea obj_visi,a0
	lea indice,a1
	lea affich,a2

	move.w #0,f_visi

next_objet:	move.l (a0)+,a6
	add.w #4,a6
	move.l (a6)+,a6	; a6 = def. faces

	move.w (a6)+,d6	; d6 = nb_face
	subq #1,d6

next_face:	move.w (a6)+,d5	; nb sommet de la face

	save_w d5-d7
	jsr calcul_norm(pc)
	load_w d5-d7

	tst.b flags_test
	bne.s face_cache

	lea -(2*2+4*3)(a6),a4	; sauve ad. face

	move.w d5,d0
	sub.w #3+1,d0
	bmi.s pas_div4
calcul_zm:	move.l (a6)+,a3
	add.w 4(a3),d4
	dbf d0,calcul_zm

	cmp.w #4,d5
	bne.s pas_div4
	asr.w #2,d4
	bra.s div_4
pas_div4:	divs d5,d4		; d4=zm
div_4:	move.w d4,(a2)+
	move.l a4,(a2)+
	move.w f_visi,(a1)+
	add.w #2+4,f_visi
	bra.s face_traite
face_cache:	sub.w #3,d5
	add.w d5,d5
	add.w d5,d5
	add.w d5,a6
face_traite:	dbf d6,next_face
	
	dbf d7,next_objet
	move.w f_visi,d7
	divu #4+2,d7
	move.w d7,f_visi
	rts

	****************
calcul_norm:	add.w #2,a6		; pour la couleur 

	movem.l (a6)+,a3-a5
	movem.w (a3),d0-d2
	movem.w (a4),d3-d5

	sub.w d0,d3		; vx1
	sub.w d1,d4		; vy1

	add.w d2,d5		; on en profite pour le zm
	movem.w (a5),d2/d6-d7

	sub.w d0,d2		; vx2
	sub.w d1,d6		; vy2

	add.w d7,d5		; zm

	muls d3,d6
	muls d4,d2
	sub.l d2,d6		; >=0 -> face non visible
	spl flags_test
	moveq #0,d4
	move.w d5,d4
	rts

	***************************
rotation_obs:	move.w nb_obj_visi,d7	; d7=nb objet visible
	subq #1,d7

	lea obj_visi,a0

rota_obj_obs:	move.l (a0)+,a1	; a1-> toutes adresses
	move.l (a1),a1		; dif_obj
	move.l 4(a1),a1

	move.w (a1)+,d6	; d6=nb_point
	subq #1,d6

rota_pt_obs:	movem.w (a1),d0-d2	; xw,yw,zw
	save d6-d7/a0/a1
	jsr transfo_obs2(pc)	; ->xs,ys,ze
	load d6-d7/a0/a1

	movem.w d0-d2,(a1)
	add.w #3*2,a1
	dbf d6,rota_pt_obs

	dbf d7,rota_obj_obs
	rts

	***************************
rotation:	move.w nb_obj_visi,d7
	subq #1,d7

	lea obj_visi,a0

rota_obj_point:move.l (a0)+,a1	; a1-> toutes adresses
	move.l (a1),a1		; dif_obj
	move.l 14(a1),a2	; posi_obj
	movem.w 3*2(a2),d0-d2	; angle
	move.w d2,d3
	or.w d1,d3
	or.w d0,d3
	sne.s f_rota_obj

	tst.b f_rota_obj
	beq.s pas_rota_ob1
	add.w d0,d0
	add.w d1,d1
	add.w d2,d2
	save d7/a0-a1
	lea mat_obj,a0
	jsr calcul_matrice(pc)
	load d7/a0-a1

pas_rota_ob1:	lea 8(a1),a2		; a2 = barycentre
	movem.w (a2),d3-d5

	move.l 14(a1),a4	; posi obj
	movem.w (a4),d0-d2	; xpos,ypos et zpos
	add.w d3,d0
	add.w d4,d1
	add.w d5,d2		; bary. obj. dans le monde
	movem.w d0-d2,transfer

	move.l (a1),a2
	move.l 4(a1),a3

	move.w (a2)+,d6
	move.w d6,(a3)+
	sub.w #1,d6		; d6 = nb. sommets

	tst.b f_rota_obj
	beq.s pas_rota_ob2

	save d7/a0
	lea mat_obj,a0
	lea transfer,a4

rota_point1:	movem.w (a2)+,d0-d2
	sub.w d3,d0
	sub.w d4,d1
	sub.w d5,d2
	save d3-d6/a0
	jsr multi_vect(pc)
	asl.l #2,d0
	asl.l #2,d1
	asl.l #2,d2
	swap d0
	swap d1
	swap d2
	movem.w (a4),d3-d5
	add.w d3,d0
	add.w d4,d1
	add.w d5,d2
	movem.w d0-d2,(a3)
	add.w #3*2,a3
	load d3-d6/a0
	dbf d6,rota_point1
	load d7/a0

	dbf d7,rota_obj_point
	rts
*********
pas_rota_ob2:	movem.w (a4),d3-d5	; xpos,ypos et zpos

rota_point2:	movem.w (a2)+,d0-d2
	add.w d3,d0
	add.w d4,d1
	add.w d5,d2
	movem.w d0-d2,(a3)
	add.w #3*2,a3
	dbf d6,rota_point2
	dbf d7,rota_obj_point
	rts

***************************
trie_obj:	lea obj_visi,a0
	move.w nb_obj_visi,d7
	sub.w #2,d7
	bmi.s obj_seul
	
	moveq #0,d5		* for i=1 to f_visi-1
next_i_obj:	move.w d7,d6

	move.w d5,d3		* d3 = k
	move.w d5,d4
next_j_obj:	add.w #6,d4		* for j=i+1 to f_visi

	move.w (a0,d4.w),d0	* d0=zmoyen(indice(j))

	cmp.w (a0,d3.w),d0	* d1=zmoyen(indice(k))
	ble.s pas_sup_obj
	move.w d4,d3

pas_sup_obj:	dbf d6,next_j_obj
	cmp.w d5,d3
	beq.s egalite_obj

	move.l a0,a2
	move.l a0,a3
	add.w d3,a2
	add.w d5,a3
	move.w (a2),d0
	move.l 2(a2),d1
	move.w (a3),(a2)+
	move.l 2(a3),(a2)
	move.w d0,(a3)+
	move.l d1,(a3)

egalite_obj:	add.w #6,d5
	dbf d7,next_i_obj
obj_seul:	move.w nb_obj_visi,d7
	sub.w #1,d7
	lea obj_visi+2,a0
	lea obj_visi,a1
compac_obj:	move.l (a0),(a1)+
	add.w #6,a0
	dbf d7,compac_obj
	rts

***************************
visi_obj:	lea obj_visi,a0
	lea add_objets,a1
	move.w def_monde,d7	; nb d'objet
	subq #1,d7
	moveq #0,d6		; nb objet visible

test_objet	move.l (a1),a2
	move.l 14(a2),a3	; a3 = obj_pos
	lea 8(a2),a2		; a2 = bary
	movem.w (a2)+,d0-d2	; xpos,ypos,zpos dans le repere
			; de l'objet
	movem.w (a3)+,d3-d5	; pos de l'objet dans le monde

	add.w d3,d0
	add.w d4,d1
	add.w d5,d2

	save d6/d7/a0/a1
	jsr transfo_obs(pc)
	load d6/d7/a0/a1

	move.w d0,d4
	move.w d1,d5
	muls #ptf/180,d0
	muls #ptf/120,d1
	lea flags_test,a3
	move.w d2,d3
	neg.w d3
	cmp.w #100,d2		* plan avant
	ble.s objet_derriere
	cmp.w d3,d0		* IF -ze<=xe*ptf/175
	sge (a3)
	cmp.w d2,d0		* AND xe<=ze
	sle 1(a3)
	cmp.w d3,d1		* AND -ze<=ye
	sge 2(a3)
	cmp.w d2,d1		* AND ye<=ze
	sle 3(a3)
	cmp.w #1100,d2		* plan arriere
	sle 4(a3)
	cmp.w #100,d2		* plan avant
	sge 5(a3)

	moveq #6-1,d5
	moveq #-1,d0
tst_condi:	and.b (a3)+,d0
	dbf d5,tst_condi

	tst.b d0
	bne.s obj_visible

obj_pas_v:	add.w #2*4,a1		; objet suivant
	dbf d7,test_objet
	move.w d6,nb_obj_visi
	rts
obj_visible:	move.w d2,(a0)+
	move.l a1,(a0)+	; adresse de l'objet
	add.w #1,d6
	add.w #2*4,a1		; objet suivant
	dbf d7,test_objet
	move.w d6,nb_obj_visi
	rts
objet_derriere:cmp.w #100,d0
	sge (a3)
	cmp.w #-100,d0
	sle 1(a3)
	cmp.w #100,d1
	sge 2(a3)
	cmp.w #-100,d1
	sle 3(a3)

	move.w #4-1,d5
	moveq #-1,d0
tst_condi2:	and.b (a3)+,d0
	dbf d5,tst_condi2
	tst.b d0
	bne.s obj_visible
	bra.s obj_pas_v	
	
*********** Mouvement de l'observateur ****
mouvement_observateur:		; MOUSE
	jsr deplacement(pc)	; deplacement de l'observateur
	jsr deplacement_mouse(pc)

	lea vis_x,a1		; deplacement sur axe ?
	lea flags_test,a2
	tst.w (a1)+
	sne (a2)
	tst.w (a1)+
	sne 1(a2)
	tst.w (a1)+
	sne 2(a2)

	moveq #0,d0
	move.b (a2),d0
	or.b 1(a2),d0
	or.b 2(a2),d0
	tst.w d0
	bne.s deplacement_visu

fin_depl_obs:	lea mat_obs,a0
	lea obs_a,a1
	movem.l (a1),d0-d2	; alpha,beta,gamma
	add.l d0,d0
	add.l d1,d1
	add.l d2,d2
	swap d0
	swap d1
	swap d2

	jsr calcul_matrice(pc)	; matrice observateur

	rts
deplacement_visu:
	lea mat_obs_i,a0
	lea obs_a,a1
	movem.l (a1),d0-d2
	add.l d0,d0
	add.l d1,d1
	add.l d2,d2
	swap d0
	swap d1
	swap d2
	neg.w d0
	neg.w d1
	neg.w d2

	jsr calcul_matrice_d(pc)	; matrice deplacement

	lea mat_obs_i,a0	; matrice
	lea vis_x,a1		; vecteur

	jsr multi_vect_mat(pc)
	asl.l #2,d0		; passe en multi precision
	asl.l #2,d1
	asl.l #2,d2

	lea obs_x,a0		; remet dans le repere mondial
	movem.l (a0),d3-d5
	sub.l d0,d3
	sub.l d1,d4
	sub.l d2,d5
	movem.l d3-d5,(a0)

	lea vis_x,a0
	clr.l (a0)+
	bra.s fin_depl_obs

deplacement:	moveq #0,d0
*	move.b (clavier).w,d0	; MOUSE
	move.b buffer_clav,d0
	lea touches,a0

	cmp.w (a0)+,d0
	beq reset
	cmp.w (a0)+,d0
	beq avancer
	cmp.w (a0)+,d0
	beq reculer
	cmp.w (a0)+,d0
	beq gauche
	cmp.w (a0)+,d0
	beq droite
	cmp.w (a0)+,d0
	beq haut
	cmp.w (a0)+,d0
	beq bas
	cmp.w (a0)+,d0
	beq regard_d
	cmp.w (a0)+,d0
	beq regard_g
	cmp.w (a0)+,d0
	beq regard_b
	cmp.w (a0)+,d0
	beq regard_h
	cmp.w (a0)+,d0
	beq regard_tg
	cmp.w (a0)+,d0
	beq regard_td
	cmp.w (a0)+,d0
	beq avancer_w
	cmp.w (a0)+,d0
	beq reculer_w
	cmp.w (a0)+,d0
	beq gauche_w
	cmp.w (a0)+,d0
	beq droite_w
	cmp.w (a0)+,d0
	beq haut_w
	cmp.w (a0)+,d0
	beq bas_w
	cmp.w (a0)+,d0
	beq music
	cmp.w (a0)+,d0
	beq derriere
cal_b:	lea obs_b,a0
	move.l obs_bi,d0
	cmp.l #10*$10000,d0
	ble.s beta_b1
	add.l #-pas_b*$10000,d0
	move.l d0,obs_bi
	clr.l obs_gi
beta_b1:	cmp.l #-10*$10000,d0
	bge.s beta_b2
	add.l #pas_b*$10000,d0
	move.l d0,obs_bi
	clr.l obs_gi
beta_b2:	jsr angle_commun(pc)
	lea obs_a,a0
	move.l obs_ai,d0
	jsr angle_commun(pc)
	lea obs_g,a0
	move.l obs_gi,d0
	jsr angle_commun(pc)
	clr.l obs_ai
	clr.l obs_gi
	move.w vis_zi,d0
	add.w d0,vis_z
	clr.w vis_zi
	rts
pas_z=1
pas_x=10
pas_y=10
pas_a=2
pas_b=1
pas_g=6
reset:	bra init_pos_obs
avancer:	move.w #-pas_z,vis_zi
	bra cal_b
reculer:	move.w #pas_z,vis_zi
	bra cal_b
droite:	move.w #-pas_x,vis_x
	bra cal_b
gauche:	move.w #pas_x,vis_x
	bra cal_b
bas:	move.w #-pas_y,vis_y
	bra cal_b
haut:	move.w #pas_y,vis_y
	bra cal_b
regard_d:	add.l #-pas_b*$10000,obs_bi
	add.l #pas_g*$10000,obs_gi
	bra cal_b
regard_g:	add.l #pas_b*$10000,obs_bi
	add.l #-pas_g*$10000,obs_gi
	bra cal_b
regard_h:	move.l #pas_a*$10000,obs_ai
	bra cal_b
regard_b:	move.l #-pas_a*$10000,obs_ai
	bra cal_b
regard_tg:	move.l #pas_g*$10000,obs_gi
	bra cal_b
regard_td:	move.l #-pas_g*$10000,obs_gi
	bra cal_b
avancer_w:	add.w #pas_z,obs_z
	bra cal_b
reculer_w:	sub.w #pas_z,obs_z
	bra cal_b
droite_w:	add.w #pas_x,obs_x
	bra cal_b
gauche_w:	sub.w #pas_x,obs_x
	bra cal_b
bas_w:	add.w #pas_y,obs_y
	bra cal_b
haut_w:	sub.w #pas_y,obs_y
	bra cal_b
music:	
	ifeq test_p
	moveq #0,d0
	move.w mus,d0
	addq #1,d0
	cmp.w #3,d0
	bne.s pas_sup_m
	moveq #0,d0
pas_sup_m:	move.w d0,mus
	jsr zik
	endc
	bra cal_b
derriere:	move.w #600,obs_z
	lea obs_b,a0
	move.l #180*$10000,d0
	bra angle_commun

angle_commun:	move.l (a0),d1
	add.l d0,d1
	cmp.l #360*$10000,d1
	blt.s angle_bon1
	sub.l #360*$10000,d1
angle_bon1:	tst.l d1
	bpl.s angle_bon2
	add.l #360*$10000,d1
angle_bon2:	move.l d1,(a0)
	rts

deplacement_mouse:
	move.w boutons,d0
	tst.w d0
	bne bout_actif

	moveq #0,d0
	move.b m_x,d0
	ext.w d0
	tst.w d0
	bpl.s d0_posi
	neg.w d0
	swap d0
	move.l d0,d2
	lsr.l #2,d0
	move.l d0,d1
	lsl.l #1,d2
	neg.l d0
	bra.s d0_nega
d0_posi:	swap d0
	move.l d0,d2
	lsr.l #2,d0
	move.l d0,d1
	lsl.l #1,d2
	neg.l d2
d0_nega:	add.l d0,obs_bi
	move.l d2,obs_gi
	clr.b m_x

	moveq #0,d0
	move.b m_y,d0
	ext.w d0
	neg.w d0
	swap d0
	move.l d0,d3
	asr.l #1,d0
	add.l d3,d0
	move.l d0,obs_ai
	clr.b m_y

	lea obs_b,a0
	move.l obs_bi,d0
	cmp.l #10*$10000,d0
	ble.s beta_b11
	sub.l d1,d0
	move.l d0,obs_bi
	clr.l obs_gi
beta_b11:	cmp.l #-10*$10000,d0
	bge.s beta_b21
	add.l d1,d0
	move.l d0,obs_bi
	clr.l obs_gi
beta_b21:	jsr angle_commun(pc)
	lea obs_a,a0
	move.l obs_ai,d0
	jsr angle_commun(pc)
	lea obs_g,a0
	move.l obs_gi,d0
	jsr angle_commun(pc)
	clr.l obs_ai
	clr.l obs_gi
	move.w vis_zi,d0
	add.w d0,vis_z
	clr.w vis_zi
	rts
bout_actif:	moveq #0,d0
	move.b m_y,d0
	ext.w d0
	add.w d0,vis_z
	clr.w vis_zi
	clr.b m_y
	rts
*********** Mouvement de l'objet ***********
mouvements_objet:
	lea add_objets,a1	; add obj
	move.w def_monde,d7	; nb objet
	subq #1,d7
mouvement_objet:
	move.l (a1),a2
	move.l 14(a2),a2	; a1 = posi obj
	jsr traite_mvt_obj(pc)
	add.w #8,a1
	dbf d7,mouvement_objet
	rts

	*** Mouvement des objets ***
modulo_360:	macro \1
	cmp.w #360,\1
	ble.s mod1\@
	sub.w #360,\1
mod1\@:	tst.w \1
	bpl.s mod2\@
	add.w #360,\1
mod2\@:	
	endm

traite_mvt_obj:movem.w (a2),d0-d5	; x,y,z a,b,g
	add.w #0,d0
	add.w #0,d1
	add.w #0,d2

*	add.w d7,d3
	modulo_360 d3
*	add.w #2,d4
	modulo_360 d4
*	add.w #3,d5
	modulo_360 d5
	movem.w d0-d5,(a2)
	rts

**** Calcul de la matrice de rotation ***
* mat(1,1)=0()
* mat(1,2)=4()
* mat(1,3)=8()
* mat(2,1)=12()
* mat(2,2)=16()
* mat(2,3)=20()
* mat(3,1)=24()
* mat(3,2)=28()
* mat(3,3)=32()
calcul_matrice:lea cosinus,a1		; cos en .l
	lea 90*4*2(a1),a2	; sin
			; matrice dans a0
			; angle d0,d1,d2

	move.w d2,a4
	sub.w d1,a4
	add.w d0,a4		; a5=a-b+g
	add.w a4,a4
	add.w a4,a4
	move.l 0(a2,a4.w),a6	* a6=-sin(a5)
	move.l 0(a1,a4.w),a4	* a4=cos(a5)

	move.w d2,d3
	add.w d1,d3
	sub.w d0,d3		; a6=b+g-a
	add.w d3,d3
	add.w d3,d3
	move.l 0(a2,d3.w),d4	* d4=-sin(a6)
	move.l 0(a1,d3.w),d3	* d3=cos(a6)

	move.w d2,d5
	sub.w d1,d5
	sub.w d0,d5		; a7=g-b-a
	add.w d5,d5
	add.w d5,d5
	move.l 0(a2,d5.w),d6	* d6=-sin(a7)
	move.l 0(a1,d5.w),d5	* d5=cos(a7)

	move.w d2,a5
	add.w d1,a5
	add.w d0,a5		; a8=g+b+a
	add.w a5,a5
	add.w a5,a5
	move.l 0(a2,a5.w),d7	* d7=-sin(a8)
	move.l 0(a1,a5.w),a5	* a5=cos(a8)

	lea (a0),a3
	move.l a6,(a3)
	add.l d4,(a3)
	sub.l d6,(a3)
	sub.l d7,(a3)

	lea 20(a0),a3
	move.l a6,(a3)
	add.l d7,(a3)
	sub.l d4,(a3)
	sub.l d6,(a3)

	lea 8(a0),a3
	move.l a5,(a3)
	move.l a4,d7
	add.l d7,(a3)
	sub.l d3,(a3)
	sub.l d5,(a3)

	lea 12(a0),a3
	move.l a5,(a3)
	sub.l d7,(a3)
	sub.l d3,(a3)
	add.l d5,(a3)

*****
	move.w d0,d3
	sub.w d1,d3		; a1=a-b
	add.w d3,d3
	add.w d3,d3
	move.l 0(a2,d3.w),d4	* d4=-sin(a1)
	move.l 0(a1,d3.w),d3	* d3=cos(a1)

	move.w d1,d5
	add.w d0,d5		; a2=a+b
	add.w d5,d5
	add.w d5,d5
	move.l 0(a2,d5.w),d6	* d6=-sin(a2)
	move.l 0(a1,d5.w),d5	* d5=cos(a2)

	sub.l d6,d4
	asr.l #1,d4
	move.l d4,24(a0)

	add.l d5,d3
	asr.l #1,d3
	move.l d3,32(a0)

	move.w d2,d3
	sub.w d0,d3		; a3=g-a
	add.w d3,d3
	add.w d3,d3
	move.l 0(a2,d3.w),d4	* d4=-sin(a3)
	move.l 0(a1,d3.w),d3	* d3=cos(a3)

	move.w d2,d5
	add.w d0,d5		; a4=a+g
	add.w d5,d5
	add.w d5,d5
	move.l 0(a2,d5.w),d6	* d6=-sin(a4)
	move.l 0(a1,d5.w),d5	* d5=cos(a4)

	add.l d6,d4
	asr.l #1,d4
	move.l d4,4(a0)

	add.l d5,d3
	asr.l #1,d3
	move.l d3,16(a0)
	
	move.w d1,d3
	sub.w d2,d3		; a9=b-g
	add.w d3,d3
	add.w d3,d3
	move.l 0(a2,d3.w),d4	* d4=-sin(a9)
	move.l 0(a1,d3.w),d3	* d3=cos(a9)

	move.w d2,d5
	add.w d1,d5		; a10=b+g
	add.w d5,d5
	add.w d5,d5
	move.l 0(a2,d5.w),d6	* d6=-sin(a10)
	move.l 0(a1,d5.w),d5	* d5=cos(a10)

	move.l (a0),d7
	neg.l d7
	asr.l #1,d7
	add.l d3,d7
	add.l d5,d7
	asr.l #1,d7
	move.l d7,(a0)

	lea 8(a0),a3
	move.l (a3),d1
	asr.l #1,d1
	sub.l d4,d1
	sub.l d6,d1
	asr.l #1,d1
	neg.l d1
	move.l d1,(a3)

	lea 12(a0),a3
	move.l (a3),d1
	neg.l d1
	asr.l #1,d1
	sub.l d4,d1
	add.l d6,d1
	asr.l #1,d1
	neg.l d1
	move.l d1,(a3)

	lea 20(a0),a3
	move.l (a3),d1
	asr.l #1,d1
	sub.l d3,d1
	add.l d5,d1
	asr.l #1,d1
	move.l d1,(a3)

	add.w d0,d0
	add.w d0,d0
	move.l 0(a2,d0.w),d0
	neg.l d0
	move.l d0,28(a0)

mat_com:	moveq #9-1,d7
	move.l a0,a3

trans_mat:	move.l (a0)+,d0
	asr.l #2,d0
	move.w d0,(a3)+
	dbf d7,trans_mat
	rts

calcul_matrice_d:
	lea cosinus,a1		; cos en .l
	lea 90*4*2(a1),a2	; sin
			; matrice dans a0
			; angle d0,d1,d2

	move.w d0,d3
	sub.w d1,d3		; a1=a-b
	add.w d3,d3
	add.w d3,d3
	move.l 0(a2,d3.w),d4	* d4=-sin(a1)
	move.l 0(a1,d3.w),d3	* d3=cos(a1)

	move.w d1,d5
	add.w d0,d5		; a2=a+b
	add.w d5,d5
	add.w d5,d5
	move.l 0(a2,d5.w),d6	* d6=-sin(a2)
	move.l 0(a1,d5.w),d5	* d5=cos(a2)

	add.w d0,d0
	add.w d0,d0
	move.l 0(a2,d0.w),d7	* d7=-sin(a)
	move.l 0(a1,d0.w),d0	* d0=cos(a)

	add.w d1,d1
	add.w d1,d1
	move.l 0(a2,d1.w),d2	* d2=sin(b)
	neg.l d2
	move.l 0(a1,d1.w),d1	* d1=cos(b)

	move.l a0,a3
	move.l d1,(a3)+

	move.l d5,d1
	sub.l d3,d1
	asr.l #1,d1
	move.l d1,(a3)+

	move.l d6,d1
	sub.l d4,d1
	asr.l #1,d1
	move.l d1,(a3)+

	clr.l (a3)+
	move.l d0,(a3)+
	move.l d7,(a3)+
	move.l d2,(a3)+

	move.l d6,d1
	sub.l d4,d1
	neg.l d1
	asr.l #1,d1
	move.l d1,(a3)+

	add.l d5,d3
	asr.l #1,d3
	move.l d3,(a3)+

	bra mat_com
	
*********** Multiplication d'un vecteur par une matrice ***********
multi_vect_mat:	* a0=matrice,a1=vecteur ->d0,d1,d2
	
	movem.w (a1)+,d0-d2	; x,y,z
multi_vect:	move.l d0,d5
	move.l d1,d6
	move.l d2,d7

	muls (a0)+,d0
	muls (a0)+,d1
	muls (a0)+,d2
	add.l d2,d0
	add.l d1,d0

	move.l d5,d1
	move.l d6,d2
	move.l d7,d3

	muls (a0)+,d1
	muls (a0)+,d2
	muls (a0)+,d3
	add.l d3,d1
	add.l d2,d1

	move.l d5,d2
	move.l d6,d3
	move.l d7,d4

	muls (a0)+,d2
	muls (a0)+,d3
	muls (a0)+,d4
	add.l d4,d2
	add.l d3,d2

	rts

*********** Transformation monde-observateur *******
transfo_obs:	;-> d0,d1,d2=xpos,ypos,zpos
	;<- d0,d1,d2=xe,ye,ze

	lea obs_x,a0
	lea transfer,a1
	movem.l (a0),d3-d5
	swap d3
	swap d4
	swap d5
	sub.w d3,d0
	sub.w d4,d1
	sub.w d5,d2
	movem.w d0-d2,(a1)

	lea mat_obs,a0
	jsr multi_vect_mat(pc)
	asl.l #2,d0		; revient en normal
	asl.l #2,d1
	asl.l #2,d2
	clr.w d0
	clr.w d1
	clr.w d2
	swap d0
	swap d1
	swap d2		; /16384
	rts

*********** Transformation monde-observateur 2  *******
transfo_obs2:	;-> d0,d1,d2=xpos,ypos,zpos
	;<- d0,d1,d2=xs,ys,zs

	lea obs_x,a0
	lea transfer,a1
	movem.l (a0),d3-d5
	swap d3
	swap d4
	swap d5
	sub.w d3,d0
	sub.w d4,d1
	sub.w d5,d2
	movem.w d0-d2,(a1)

	lea mat_obs,a0
	jsr multi_vect_mat(pc)
ptf=400
s=106
vsx=110
vsy=100
	asl.l #2,d2
	swap d2		; d2/16384
	tst.w d2
	beq.s z_egal_0
	divs d2,d0
	muls #(ptf*vsx)/s,d0
	asl.l #2,d0
	swap d0		; -> /16384
	add.w #160,d0		; xs=ptf*xe/ze+160

	divs d2,d1
	muls #(ptf*vsy)/s,d1
	asl.l #2,d1
	swap d1		; -> /16384
	add.w #100,d1		; ys=ptf*ye/ze+100

z_egal_0:	rts
** Initialisation des tableaux et paramŠtres **

init_pos_obs:	lea observateur,a0
	lea obs_x,a1
	movem.w (a0)+,d0-d2
	swap d0
	swap d1
	swap d2
	clr.w d0
	clr.w d1
	clr.w d2
	movem.l d0-d2,(a1)
	lea obs_a,a1
	movem.w (a0)+,d0-d2
	swap d0
	swap d1
	swap d2
	clr.w d0
	clr.w d1
	clr.w d2
	movem.l d0-d2,(a1)
	lea vis_x,a1
	clr.l (a1)+
	clr.w (a1)
	lea obs_ai,a1
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a1)
	clr.w m_x
	clr.w m_y
	clr.w boutons
	rts

init_monde:	lea dif_objets,a0
	lea def_monde,a1
	lea sommets_base,a2
	lea def_faces,a3
	lea add_objets,a4
	lea posi_objets,a5
	lea sommets_rota,a6
	move.l a6,add_som_lib
	move.w (a1)+,d7	; nb objet
	sub.w #1,d7
next_object:	move.l a0,(a4)+	; sauve add. dif_objet
	move.l a3,(a4)+	; sauve add. def_faces

	move.l a2,(a0)+	; sauve sommets de base
	move.w (a1)+,d0
	jsr get_def_obj(pc)
	move.w (a6)+,d6	; nb de sommets
	move.w d6,(a2)+
	move.w d6,d3		; sauve pour plus tard
	sub.w #1,d6
recop_som:	movem.w (a6)+,d0-d2	; les sommets
	movem.w d0-d2,(a2)
	add.w #3*2,a2
	dbf d6,recop_som

	move.l add_som_lib,(a0)+
	movem.w (a6)+,d0-d2	; barycentre
	movem.w d0-d2,(a0)
	add.w #3*2,a0
	move.l a5,(a0)+	; position de l'objet
	movem.l (a1)+,d0-d2
	movem.l d0-d2,(a5)	; initialise
	add.w #6*2,a5

	move.l add_som_lib,d0
	move.w (a6)+,d6	; nb de faces
	move.w d6,(a3)+
	sub.w #1,d6
recop_faces2:	move.w (a6)+,d5	; nb de sommets
	move.w d5,(a3)+
	subq #1,d5
	move.w (a6)+,(a3)+	; couleur
recop_faces1:	move.w (a6)+,d4	; nù du point
	sub.w #1,d4
	mulu #3*2,d4
	add.w #2,d4
	add.l d0,d4
	move.l d4,(a3)+
	dbf d5,recop_faces1
	dbf d6,recop_faces2
	mulu #3*2,d3		; d3 = nb de sommets*6
	add.w #2,d3
	add.l d3,add_som_lib
	
	dbf d7,next_object
	rts

get_def_obj:	save d1-d2
	lea objets,a6
	sub.w #2,d0
	bmi.s first
get_o2	move.w (a6)+,d1
	addq #1,d1
	mulu #6,d1
	add.w d1,a6
	move.w (a6)+,d1
	subq #1,d1
get_o1:	move.w (a6)+,d2
	add.w #2,a6
	add.w d2,d2
	add.w d2,a6
	dbf d1,get_o1
	dbf d0,get_o2
first:	load d1-d2
	rts

********************************************************************
* Module:				       *
* AFFICHAGE OBJET POUR MONDE : polygones, sphŠres.	       *
* M‚thode des pentes, 16 couleurs avec tramage.     ½ GEN 23-02-92 *
********************************************************************
	opt o+,o1+,o2+

init_tabl:	lea table_160,a0	; precalc table
	moveq #0,d0
	move.w #201,d7
rempl_160:	move.l d0,(a0)+
	add.l #160,d0
	dbf d7,rempl_160

	lea motif_g,a1
	move.w #20-1,d7
	moveq #0,d1
rempl_m12:	move.w #16-1,d6
	lea motif2(pc),a0
rempl_m11:	move.l (a0)+,d0
	add.w d1,d0
	move.l d0,(a1)+
	dbf d6,rempl_m11
	add.w #8,d1
	dbf d7,rempl_m12

	lea motif_d,a1
	move.w #20-1,d7
	moveq #0,d1		; on part en inverse
rempl_m22:	move.w #16-1,d6
	lea motif3(pc),a0
rempl_m21:	move.l (a0)+,d0
	add.w d1,d0
	move.l d0,(a1)+
	dbf d6,rempl_m21
	add.w #8,d1
	dbf d7,rempl_m22

	move.w #0,coul
	move.w #-1,oldcoul
	rts
*******************************************
efface_ecr:	move.l ecrans_t,a0
	add.l #nb_ligne*160,a0	; fin de l'ecran
	moveq #0,d0
	move.l d0,d1
	move.l d0,d2
	move.l d0,d3
	move.l d0,d4
	move.l d0,d5
	move.l d0,d6
	move.l d0,d7
	move.l d0,a1
	move.l d0,a2
	move.l d0,a3
	move.l d0,a4
	move.l d0,a5
	move.l d0,a6

	rept 190
	movem.l d0-d7/a1-a6,-(a0)
	movem.l d0-d7/a1-a6,-(a0)
	movem.l d0-d7/a1-a6,-(a0)
	endr
	movem.l d0-d7/a1-a6,-(a0)
	movem.l d0-d5,-(a0)
	rts
*******************************************
swapage:	move.l #ecrans_t,a0
	move.b 1(a0),$ffff8201	
	move.b 2(a0),$ffff8203
	move.l ecrans_t,a0	
	move.l ecrans_t+4,ecrans_t
	move.l ecrans_t+8,ecrans_t+4
	move.l a0,ecrans_t+8
	rts
*******************************************
polygone:	jsr couleur(pc)
	cmp.w #'s',sommet
	beq gene_sphere

	jsr trie_ymin(pc)
	jsr verifie_sortie(pc)	; en sortie si d0=0 on peut afficher
*	COLOR $70
	tst.w d0
	bne.s pas_dans_ecr
	jsr calcul_poly(pc)
*	COLOR $700
	jsr plein_ecran(pc)	; en sortie si d0=0, plein ecran
	tst.w d0
	bne.s depasse_ecr
	jsr table_xg_xd2(pc)
	clr.w hors_vue
	bra.s affiche_normal 

depasse_ecr:	jsr table_xg_xd(pc)
affiche_normal:tst.w hors_vue
	bne.s pas_dans_ecr

	move.w coul,d0
	and.w #$fff0,d0
	bne.s aff_tramer
	jsr affichage(pc)
pas_dans_ecr:	rts
aff_tramer:	jsr affich_trame(pc)
	rts

*** Determine le point d'ordonn‚e mini. du polygone ***

trie_ymin:	lea sommet+2,a0
	move.w (a0)+,d7	; nb sommets
	move.w d7,d6
	add.w d6,d6
	add.w d6,d6
	lea 0(a0,d6.w),a1	; pour copier apres

	sub.w #1,d7

	move.w #$0fff,d0	; d0=ymin depart

trie_c:	move.l (a0)+,d1
	cmp.w d1,d0
	ble.s rien1
	move.l d1,d0
	move.l a0,add_x_y
rien1:	move.l d1,(a1)+
	dbf d7,trie_c 
	subq.l #4,add_x_y
	rts

***** On verifie si le poly. est dans l'ecran *****

verifie_sortie:move.l add_x_y,a0
	move.w 2(a0),d0	; d0=ymin poly
	cmp.w #nb_ligne,d0
	bge.s hors_ecran
	
	move.w sommet+2,d7
	sub.w #1,d7
	
	move.w #$f000,d2	; ymax poly
	move.w #$0fff,d3	; xmin_max poly
	move.w d2,d4

verif_xy:	move.w (a0)+,d0	; x
	move.w (a0)+,d1	; y

	cmp.w d3,d0
	bge.s x_pasmin
	move.w d0,d3
x_pasmin:	cmp.w d4,d0
	ble.s x_pasmax
	move.w d0,d4
x_pasmax:	cmp.w d2,d1
	ble.s y_pasmax
	move.w d1,d2
y_pasmax:	dbf d7,verif_xy

	moveq #-1,d0		; par defaut erreur

	tst.w d2
	bmi.s hors_ecran
	cmp.w #320,d3
	bge.s hors_ecran
	tst.w d4
	bmi.s hors_ecran

	lea image_x+4,a0
	movem.w d2-d4,(a0)
	moveq #0,d0
hors_ecran:	rts

*** Calcul toutes les pentes des segments du polygone ****

calcul_poly:	move.l add_x_y,a0	; 1er sommet
	lea pente_g,a1
	lea pente_d,a2
	lea image_x,a4		; stockage

	move.w sommet+2,d7	; d7=nb segment du poly
	move.w d7,(a1)+	; stock nb_seg
	sub.w #1,d7

	move.w 2(a0),(a1)+	; ymin
	move.w 2(a0),(a4)
	moveq #1,d6
	swap d6

calc_pente:	movem.w (a0),d0-d3	; d2,d3=x2,y2
	add.w #4,a0

	move.w d2,d4		; sauvegarde x2
	sub.w d0,d2		; d2=dx
	beq.s dxnul

	sub.w d1,d3		; d3=dy
	bmi.s cote_droit	; a cause du sens de parcour
	beq.s pente_nule	; horizont. = rien

	move.l a1,a3		; dans pente_gauche
	add.w #8,a1		; car on stocke 1.l+2.w

stock_cote:	move.w d0,(a3)+ 	; sauve le x_dep
	move.w d3,(a3)+	; le dy du segment

	add.w #1,d3		; dy+1
	move.l d6,d4		* a changer -> table
	divu d3,d4		* d4=$10000/(dy+1)

	tst.w d2
	bpl.s dx_positif	; tout en positif
	neg.w d2		; -> on gagne 1 bit !!
	add.w #1,d2		; dx+1
	mulu d2,d4		; pente*$10000 -> precision
	neg.l d4		; faut remettre une pente < 0
	bra.s pente_nega
dx_positif:	add.w #1,d2
	mulu d2,d4
pente_nega:	lsl.l #2,d4
	move.l d4,(a3)+	; stock
	dbf d7,calc_pente
	rts

dxnul:	sub.w d1,d3
	bmi.s cote_droit1
	beq.s pente_nule
	move.w d0,(a1)+	; x
	move.w d3,(a1)+	; dy
	clr.l (a1)+		; pente
	dbf d7,calc_pente
	rts
cote_droit1:	move.w d4,(a2)+
	neg.w d3
	move.w d3,(a2)+
	clr.l (a2)+
	move.l a2,add_pente_d
	dbf d7,calc_pente
	rts

cote_droit:	neg.w d2		; si du cote droit
	neg.w d3
	move.w d4,d0		; d0=x2 : on inverse
	move.l a2,a3
	add.w #8,a2
	move.l a2,add_pente_d
	bra.s stock_cote

pente_nule:	sub.w #1,pente_g	; si horizontal
	dbf d7,calc_pente	; -> 1 segment en moins

	tst.w pente_g
	bne.s pas_que_horiz

	move.w #1,pente_g	; si que horizontal
	move.w image_x+6,(a1)+	; x_min du poly
	clr.w (a1)+		; dy
	clr.l (a1)+		; pente =0
	move.w image_x+8,(a2)+	; x_max
	clr.w (a2)+		; dy
	clr.l (a2)+		; pente
	move.l a2,add_pente_d
pas_que_horiz:	rts

**** Determine si le poly. est entierement dans l'ecran ****

plein_ecran:	lea image_x,a0
	movem.w (a0),d0-d4	; ymin,dy,ymax,xmin,xmax
	lea teste_flag,a1

	tst.w d0
	spl (a1)+
	tst.w d3
	sgt (a1)+
	cmp.w #nb_ligne,d2
	slt (a1)+
	cmp.w #320,d4
	slt (a1)+

	lea teste_flag,a1
	move.w (a1)+,d0
	and.w (a1),d0
	add.w #1,d0		; si d0=-1 -> d0=0
	rts

**** Effectue le pretracage du polygone en plein ecran ****

table_xg_xd2:	lea pente_g,a0		; a0=liste des pentes_g du polygone
	move.l add_pente_d,a1	; a1=pentes_d
	lea image_x,a2
	
	move.w (a0)+,-(a7)	; nb de segment
	move.w (a0)+,d1	; y de depar=y_min du poly

	move.w d1,(a2)+	; sauve
	add.w #10,a2

	move.w #nb_ligne,d3		; pour depassement ecran
	sub.w d1,d3

	add.w d1,d1
	add.w d1,d1		; y*4=offset
	add.w d1,a2		; position dans la table x_ecran

	moveq #0,d4
	moveq #0,d5

	move.w (a0)+,d4	; x_g dep
	move.w (a0)+,d6	; dy_g
	move.l (a0)+,a3	; pente g

	move.l -(a1),a4	; pente d
	move.w -(a1),d7	; dy_d
	move.w -(a1),d5	; x_d dep

	add.w d4,d4		; on multiplie
	add.w d4,d4		; par 4 pour l'affichage
	add.w d5,d5
	add.w d5,d5
	swap d4
	swap d5

parcours_x2:	move.l d4,d0		; d0=x_courant_g
	move.l d5,d1		; d1=x_courant_d
	add.l a3,d4		; x suivant
	add.l a4,d5
	swap d0		; recupere x
	swap d1
	move.w d0,(a2)+	; stock
	move.w d1,(a2)+
	sub.w #1,d3		; si sort de l'ecran en y
	beq.s fin_parcours_x2
	sub.w #1,d6
	bmi.s renouvelle_g2	; fin du segement_g ?
ret_renouv2:	sub.w #1,d7
	bmi.s renouvelle_d2
	bra.s parcours_x2
renouvelle_g2:	sub.w #1,(a7)		; 1 segment de moins
	beq.s fin_parcours_x2	; poly fini ?
	moveq #0,d4
	move.w (a0)+,d4
	add.w d4,d4		; on multiplie par 4 pour l'affichage
	add.w d4,d4
	swap d4
	move.w (a0)+,d6	; dy_g
	move.l (a0)+,a3	; nlle pente
	add.l a3,d4
	sub.w #1,d6
	bra.s ret_renouv2
renouvelle_d2:	sub.w #1,(a7)
	beq.s fin_parcours_x2
	move.l -(a1),a4
	move.w -(a1),d7
	moveq #0,d5
	move.w -(a1),d5
	add.w d5,d5		; on multiplie par 4 pour l'affichage
	add.w d5,d5
	swap d5
	sub.w #1,d7
	add.l a4,d5
	bra.s parcours_x2
fin_parcours_x2:
	add.w #2,a7
	sub.w #nb_ligne-1,d3
	neg.w d3
	lea image_x,a0
	move.w (a0)+,d1
	sub.w d1,d3
	move.w d3,(a0)		; stock dy du polygone
	add.w #8,a0
	move.w coul,(a0)
	rts

**** Effectue le pretracage du polygone ****

table_xg_xd:	lea pente_g,a0	; a0=liste des pentes_g du polygone
	move.l add_pente_d,a1	; a1=pentes_d
	lea image_x,a2
	move.w #1,hors_vue
	
	move.w (a0)+,-(a7)	; nb de segment
	move.w (a0)+,d1	; y de depar=y_min du poly
	bmi tourne_a_vide	; si negatif

	move.w d1,(a2)+	; sauve
	add.w #10,a2

	move.w #nb_ligne,d3		; pour depassement ecran
	sub.w d1,d3

	add.w d1,d1
	add.w d1,d1		; y*4=offset
	add.w d1,a2		; position dans la table x_ecran

	moveq #0,d4
	moveq #0,d5

	move.w (a0)+,d4	; x_g dep
	move.w (a0)+,d6	; dy_g
	move.l (a0)+,a3	; pente g

	move.l -(a1),a4	; pente d
	move.w -(a1),d7	; dy_d
	move.w -(a1),d5	; x_d dep

	move.w #320*4-1,d2	; depassement en x

	add.w d4,d4		; on multiplie
	add.w d4,d4		; par 4 pour l'affichage
	add.w d5,d5
	add.w d5,d5
	swap d4
	swap d5

	cmp.l #320*4*65536-1,d4	; si le polygone commence
	bgt tourn_2		; a droite ...
	tst.l d5
	bmi tourn_3		; a gauche de l'ecran

parcours_x:	move.l d4,d0		; d0=x_courant_g
	bpl.s xg_posi	; si cote gauche sort de l'ecran a gauche
	moveq #0,d0
	bra.s xg_i320
xg_posi:	swap d0		; recupere x_g
	cmp.w d2,d0	; si cote gauche sort de l'ecran a droite
	bgt.s fin_parcours_x	; =fin affichage
xg_i320:	add.l a3,d4		; x_g suivant

	move.l d5,d1		; d1=x_courant_d
	bmi.s fin_parcours_x	; =fin affichage
	add.l a4,d5
	swap d1
	cmp.w d2,d1	; si cote droit sort de l'ecran a droite
	ble.s xd_i320
	move.w d2,d1

xd_i320:	move.w d0,(a2)+	; stock
	move.w d1,(a2)+
	sub.w #1,d3		; si sort de l'ecran en y
	beq.s fin_parcours_x
	sub.w #1,d6
	bmi.s renouvelle_g	; fin du segement_g ?
ret_renouv:	sub.w #1,d7
	bmi.s renouvelle_d
	bra.s parcours_x
renouvelle_g:	sub.w #1,(a7)		; 1 segment de moins
	beq.s fin_parcours_x	; poly fini ?
	moveq #0,d4
	move.w (a0)+,d4
	add.w d4,d4		; on multiplie par 4 pour l'affichage
	add.w d4,d4
	swap d4
	move.w (a0)+,d6	; dy_g
	move.l (a0)+,a3	; nlle pente
	add.l a3,d4
	sub.w #1,d6
	bra.s ret_renouv
renouvelle_d:	sub.w #1,(a7)
	beq.s fin_parcours_x
	move.l -(a1),a4
	move.w -(a1),d7
	moveq #0,d5
	move.w -(a1),d5
	add.w d5,d5		; on multiplie par 4 pour l'affichage
	add.w d5,d5
	swap d5
	sub.w #1,d7
	add.l a4,d5
	bra.s parcours_x
fin_parcours_x:add.w #2,a7
	clr.w hors_vue
	sub.w #nb_ligne-1,d3
	neg.w d3
	lea image_x,a0
	move.w (a0)+,d1
	sub.w d1,d3
	move.w d3,(a0)		; stock dy du polygone
	add.w #8,a0
	move.w coul,(a0)
	rts

tourne_a_vide:	move.w #0,(a2)+	; sauve
	add.w #10,a2

	move.w #nb_ligne,d3
	move.w #320*4-1,d2	; x_max*4

	moveq #0,d4
	moveq #0,d5
	move.w (a0)+,d4	; x_gauche
	move.w (a0)+,d6	; dy_g
	move.l (a0)+,a3	; pente g
	move.l -(a1),a4	; pente d
	move.w -(a1),d7	; dy_d
	move.w -(a1),d5	; x_droit

	add.w d4,d4		; on multiplie par 4 pour l'affichage
	add.w d4,d4
	add.w d5,d5		; on multiplie par 4 pour l'affichage
	add.w d5,d5
	swap d4
	swap d5

parc_x:	add.l a3,d4		; x suivant
	add.l a4,d5
	sub.w #1,d6
	bmi.s renouv_g		; fin du segement_g ?
ret_ren:	sub.w #1,d7
	bmi.s renouv_d
ret_renb:	add.w #1,d1
	beq.s sur_ecran	; retourne a l'affichage
	bra.s parc_x
renouv_g:	sub.w #1,(a7)		; 1 segment de moins
	moveq #0,d4
	move.w (a0)+,d4
	add.w d4,d4
	add.w d4,d4
	swap d4
	move.w (a0)+,d6	; dy_g
	move.l (a0)+,a3	; nlle pente
	add.l a3,d4
	sub.w #1,d6
	bra.s ret_ren
renouv_d:	sub.w #1,(a7)
	move.l -(a1),a4
	move.w -(a1),d7
	moveq #0,d5
	move.w -(a1),d5
	add.w d5,d5		; on multiplie par 4 pour l'affichage
	add.w d5,d5
	swap d5
	sub.w #1,d7
	add.l a4,d5
	bra.s ret_renb

sur_ecran:	cmp.l #320*4*65536-5,d4
	bgt.s tourn_2		; si x_g>319
	sub.l #4,d5
	tst.l d5
	bmi.s tourn_3		; si x_d<0
	bra parcours_x

tourn_2:	lea image_x,a2
	move.w (a2),d1		; y_min pour x_g sup 320

parc_x2:	add.l a3,d4		; x suivant
	add.l a4,d5
	cmp.l #320*4*65536-5,d4
	ble.s sur_ecran2
	add.w #1,d1
	cmp.w #nb_ligne,d1
	beq hors_ecran2
	sub.w #1,d6
	bmi.s renouv_g2	; fin du segement_g ?
ret_ren2:	sub.w #1,d7
	bmi.s renouv_d2
	bra.s parc_x2
renouv_g2:	sub.w #1,(a7)		; 1 segment de moins
	beq hors_ecran2
	moveq #0,d4
	move.w (a0)+,d4
	add.w d4,d4
	add.w d4,d4
	swap d4
	move.w (a0)+,d6	; dy_g
	move.l (a0)+,a3	; nlle pente
	add.l a3,d4
	sub.w #1,d6
	bra.s ret_ren2
renouv_d2:	sub.w #1,(a7)
	beq.s hors_ecran2
	move.l -(a1),a4
	move.w -(a1),d7
	moveq #0,d5
	move.w -(a1),d5
	add.w d5,d5
	add.w d5,d5
	swap d5
	sub.w #1,d7
	add.l a4,d5
	bra.s parc_x2

sur_ecran2:	move.w d1,(a2)+
	add.w #10,a2
	move.w #nb_ligne,d3		; pour depassement ecran
	sub.w d1,d3
	add.w d1,d1
	add.w d1,d1		; y*4=offset
	add.w d1,a2		; position dans la table x_ecran
	bra parcours_x
	
tourn_3:	lea image_x,a2
	move.w (a2),d1		; y_min pour x_d<0

parc_x3:	add.l a3,d4		; x suivant
	add.l a4,d5
	sub.l #4,d5
	bpl.s sur_ecran2
	add.w #1,d1
	cmp.w #nb_ligne,d1
	beq.s hors_ecran2
	sub.w #1,d6
	bmi.s renouv_g3	; fin du segement_g ?
ret_ren3:	sub.w #1,d7
	bmi.s renouv_d3
	bra.s parc_x3
renouv_g3:	sub.w #1,(a7)		; 1 segment de moins
	beq.s hors_ecran2
	moveq #0,d4
	move.w (a0)+,d4
	add.w d4,d4
	add.w d4,d4
	swap d4
	move.w (a0)+,d6	; dy_g
	move.l (a0)+,a3	; nlle pente
	add.l a3,d4
	sub.w #1,d6
	bra.s ret_ren3
renouv_d3:	sub.w #1,(a7)
	beq.s hors_ecran2
	move.l -(a1),a4
	move.w -(a1),d7
	moveq #0,d5
	move.w -(a1),d5
	add.w d5,d5
	add.w d5,d5
	swap d5
	sub.w #1,d7
	add.l a4,d5
	bra.s parc_x3
hors_ecran2:	add.w #2,a7
	rts

**** Permet de choisir sa couleur parmis 16 !! ****

couleur:	move.w coul,d0
	cmp.w oldcoul,d0
	bne.s new_coul
	rts
new_coul:	move.w d0,oldcoul

	moveq #0,d0
	move.l d0,d1
	lea motif_ligne,a0
	movem.l d0-d1,(a0)
	lea motif_ligne+4*2,a0
	movem.l d0-d1,(a0)
	lea auto_mod1,a0
	movem.l d0-d1,(a0)
	lea auto_mod2,a0
	movem.l d0-d1,(a0)
	lea auto_mod3,a0
	movem.l d0-d1,(a0)

	move.w coul,d0
	move.w d0,d1
	and.w #$fff0,d1
	bne.s tramage

	lea motif_ligne+4*2,a0
	lea motif_plein,a1
	moveq #-1,d3
	jsr put_mot_inst(pc)
	
	lea auto_mod1+4*2,a0
	lea inst_couleur,a1
	jsr put_mot_inst(pc)
	lea auto_mod2+4*2,a0
	jsr put_mot_inst(pc)
	lea auto_mod3+4*2,a0
	lea inst_couleur+2*2,a1
	jsr put_mot_inst(pc)
	rts

tramage:	move.w coul,d0
	lea motif_ligne+4*2,a0
	lea motif_plein,a1
	move.w #%1010101010101010,d3
	and.w #$f,d0
	jsr put_mot_inst(pc)
	lea motif_ligne+4*2,a0
	lea motif_plein,a1
	not.w d3
	move.w coul,d0
	lsr.w #4,d0
	jsr put_mot_inst(pc)

	move.w coul,d0
	lea motif_ligne+4*2*2,a0
	lea motif_plein,a1
	and.w #$f,d0
	jsr put_mot_inst(pc)
	lea motif_ligne+4*2*2,a0
	lea motif_plein,a1
	not.w d3
	move.w coul,d0
	lsr.w #4,d0
	jsr put_mot_inst(pc)

	move.w coul,d0
	and.w #$f,d0
	lea auto_mod4+8*2-2,a0
	lea inst_couleur2,a1
	jsr put_inst(pc)
	lea auto_mod5+8*2-2,a0
	lea inst_couleur2,a1
	jsr put_inst(pc)
	lea auto_mod6+8*2-2,a0
	lea inst_couleur2+2*4,a1
	jsr put_inst(pc)

	move.w coul,d0
	lsr.w #4,d0
	lea auto_mod4+8*2,a0
	lea inst_couleur2+4,a1
	jsr put_inst(pc)
	lea auto_mod5+8*2,a0
	lea inst_couleur2+4,a1
	jsr put_inst(pc)
	lea auto_mod6+8*2,a0
	lea inst_couleur2+2*4+4,a1
	jsr put_inst(pc)
	rts

put_mot_inst:	moveq #4-1,d1
.deter_coul:	moveq #0,d4
	move.w d0,d2
	bset d1,d4
	and.w d4,d2
	add.w d2,d2
	lsr.w d1,d2
	move.w (a1,d2.w),d4
	and.w d3,d4
	or.w d4,-(a0)
	dbf d1,.deter_coul
	rts
put_inst:	moveq #4-1,d1
.deter_coul2:	moveq #0,d4
	move.w d0,d2
	bset d1,d4
	and.w d4,d2
	add.w d2,d2
	lsr.w d1,d2
	move.w (a1,d2.w),-(a0)
	sub.w #2,a0
	dbf d1,.deter_coul2
	rts
**** Affichage proprement dit du polygone ****

affichage:	move.l ecrans_t,a0
	lea table_160,a2
	lea image_x,a1

	move.w (a1)+,d1
	move.w (a1)+,d7
	add.w #8,a1

	add.w d1,d1
	add.w d1,d1
	add.l 0(a2,d1.w),a0	; position ecran
	add.w d1,a1		; position tableau

	lea motif_g,a2
	lea motif_d,a3
	lea l_suivante(pc),a5
	lea motif_ligne,a6
	move.l (a6)+,d3
	move.l (a6)+,d4
	moveq #-4,d5

polyg:	move.w (a1)+,d0
	move.w (a1)+,d1
	and.w d5,d0
	and.w d5,d1

	move.l (a2,d0.w),d0	; motif debut ligne
	move.l (a3,d1.w),d1	; motif fin de ligne

	move.l a0,a4
	add.w d0,a4

	sub.w d0,d1
	ble.s b_melange
	swap d0
	move.w d0,d2
	not.w d2
auto_mod1:	or.w d0,(a4)+
	and.w d2,(a4)+
	and.w d2,(a4)+
	and.w d2,(a4)+
	sub.w #8,d1
	lsr.w #1,d1	
	neg.w d1
	jmp (a5,d1.w)
b_melange:	bne.s l_suivant1
	and.l d1,d0
	swap d0
	move.w d0,d2
	not.w d2
auto_mod2	or.w d0,(a4)+ 
	and.w d2,(a4)+
	and.w d2,(a4)+
	and.w d2,(a4)+
l_suivant1:	lea 160(a0),a0
	dbf d7,polyg
	rts
	rept 18
	move.l d3,(a4)+
	move.l d4,(a4)+
	endr
l_suivante:	swap d1
	move.w d1,d0
	not.w d0
auto_mod3:	or.w d1,(a4)+
	and.w d0,(a4)+
	and.w d0,(a4)+
	and.w d0,(a4)+
	lea 160(a0),a0
	dbf d7,polyg
	rts
*************************
affich_trame:	move.l ecrans_t,a0
	lea table_160,a2
	lea image_x,a1

	move.w (a1)+,d1
	move.w (a1)+,d7
	add.w #8,a1

	add.w d1,d1
	add.w d1,d1
	add.l 0(a2,d1.w),a0	; position ecran
	add.w d1,a1		; position tableau

	lea motif_g,a2
	lea motif_d,a3
	lea l_suivante2(pc),a5
	lea motif_ligne,a6
	move.l (a6)+,d3
	move.l (a6)+,d4
	move.l #$aaaa5555,d6
	move.l d4,-(sp)
	move.l d3,-(sp)
	move.l 4(a6),-(sp)
	move.l (a6),-(sp)
	move.w #0,off_motif

polyg2:	moveq #-4,d5
	move.w (a1)+,d0
	move.w (a1)+,d1
	and.w d5,d0
	and.w d5,d1

	move.l (a2,d0.w),d0	; motif debut ligne
	move.l (a3,d1.w),d1	; motif fin de ligne

	move.l a0,a4
	add.w d0,a4

	sub.w d0,d1
	ble.s b_melange2
	move.l d0,d5
	swap d5
	and.l d6,d0		; trame %101010...
	and.w d6,d5		; trame %010101...
	swap d0
	move.w d1,a6
	move.w d0,d2
	not.w d2
	move.w d5,d1
	not.w d1
auto_mod4:	or.w d0,(a4)		; tramage de 1 avec 1
	or.w d5,(a4)+
	and.w d2,(a4)
	and.w d1,(a4)+
	and.w d2,(a4)
	and.w d1,(a4)+
	and.w d2,(a4)
	and.w d1,(a4)+
	move.w a6,d1
	sub.w #8,d1
	lsr.w #1,d1	
	neg.w d1
	*COLOR $700
l:	jmp (a5,d1.w)
b_melange2:	bne.s l_suivant3
	and.l d1,d0
	move.l d0,d5
	swap d5
	and.l d6,d0
	and.w d6,d5
	swap d0
	move.w d0,d2
	move.w d5,d1
	not.w d2
	not.w d1
auto_mod5:	or.w d0,(a4)		; tramage de 1 avec 1
	or.w d5,(a4)+
	and.w d2,(a4)
	and.w d1,(a4)+
	and.w d2,(a4)
	and.w d1,(a4)+
	and.w d2,(a4)
	and.w d1,(a4)+
l_suivant3:	lea 160(a0),a0
	swap d6
	move.w off_motif,d0
	movem.l (a7,d0.w),d3-d4
	eor.w #8,off_motif
	dbf d7,polyg2
	add.l #16,a7
	rts
	rept 18
	move.l d3,(a4)+
	move.l d4,(a4)+
	endr
l_suivante2:	move.l d1,d5
	*COLOR $7
	swap d5
	and.l d6,d1
	and.w d6,d5
	swap d1
	move.w d1,d0
	move.w d5,d2
	not.w d0
	not.w d2
auto_mod6:	or.w d1,(a4)
	or.w d5,(a4)+
	and.w d0,(a4)
	and.w d2,(a4)+
	and.w d0,(a4)
	and.w d2,(a4)+
	and.w d0,(a4)
	and.w d2,(a4)+
	lea 160(a0),a0
	swap d6
	move.w off_motif,d0
	movem.l (a7,d0.w),d3-d4
	eor.w #8,off_motif
	dbf d7,polyg2
	add.l #16,a7
	rts

************************************
pass_ecr:	rts
gene_sphere:	jsr vers_sortie(pc)	; en sortie si d0=0 on peut afficher
	tst.w d0
	bne.s pass_ecr
	jsr affv_sphere(pc)
	bra affiche_normal

vers_sortie:	moveq #-1,d0
	movem.w sommet+4,d0-d2
	move.w d0,d3
	move.w d1,d4
	add.w d2,d3
	add.w d2,d4
	sub.w d2,d0
	sub.w d2,d1
	tst.w d3
	bmi.s pas_sphere
	tst.w d4
	bmi.s pas_sphere
	cmp.w #320,d0
	bge.s pas_sphere
	cmp.w #nb_ligne,d1
	bge.s pas_sphere
	clr.w d0
pas_sphere:	rts
	
affv_sphere:	lea image_x,a0
	move.l a0,a2
	movem.w sommet+4,d0-d2	; d0=xc d1=yc d2=r
	move.w #1,hors_vue

	move.w d1,d3
	sub.w d2,d3		; d3=ymin
	move.w d2,d4
	add.w d4,d4
	add.w d3,d4		; d4=ymax
	
	move.w d4,d5		; d5=ymax reel
	cmp.w #nb_ligne,d4
	blt.s ymaxs_i200
	move.w #nb_ligne,d4
ymaxs_i200:	move.w d4,d6
	add.w d4,d4
	add.w d4,d4		; pour affichage
	lea 12(a0,d4.w),a1	; a1=bas du cercle
	move.w d3,d4		; d4=ymin reel
	bpl.s ymins_p
	clr.w d3
ymins_p:	move.w d3,d7
	add.w d3,d3
	add.w d3,d3		; pour affichage
	lea 12(a0,d3.w),a0	; a0=haut du cercle
	sub.w d7,d6
	sub.w #1,d6
	move.w d7,(a2)
	move.w d6,2(a2)

	add.w d0,d0
	add.w d0,d0		; d0= xc=xc*4 pour aff
	swap d0
	move.l d0,d6		; xg=xd=xc
	move.l #$46666,a6	; a6= 1.1*65536*4
*	move.l #$10000*4,a6	; a6= 1.1*65536*4

	add.w d2,d2
	sub.w #1,d2
	move.w d2,a3		; d3= y=2*r-1
	move.w #1,a2		; a2= x=1
	move.w a3,a4
	sub.w #1,a4		: a4= delta=y-1

	move.w #nb_ligne,d7
	sub.w d5,d7		; d7=nb_ligne-ymax
	move.w d4,d3		; d3=ymin

	tst.w d1		; yc<0 ?
	bmi tournes_1
	cmp.w #nb_ligne,d1	; yc>=nb_ligne ?
	bge tournes_2

	lea xgs_xdsb(pc),a5
	clr.w d1

ret_tournes:	tst.w d6		; xc<0
	bmi tournes_3
	cmp.l #320*4*65536,d6
	bge tournes_4

sphere:	cmp.w d1,a3
	blt.s fin_sphere
	move.w a4,d5
	add.w d5,d5		; d5= d=delta*2
	bpl.s else1		; si d<0
	add.w a2,d5		; d=d+x
	bpl.s else2		; si d<0
	sub.w #2,a3		; y=y-2
	add.w a3,a4		; delta=delta+y
	jmp (a5)

xgs_xdsb:	clr.w hors_vue
	lea xgs_xds(pc),a5

xgs_xds:	move.l d0,d2
	bpl.s xgs_posi
	moveq #0,d2	
xgs_posi:	swap d2
	move.l d6,d4
	swap d4
	cmp.w #320*4-1,d4
	ble.s xds_i320
	move.w #320*4-1,d4

xds_i320:	tst.w d3
	bmi.s sphere_h
	move.w d2,(a0)+
	move.w d4,(a0)+
sphere_h:	add.w #1,d3
	tst.w d7
	bmi.s sphere_b
	move.w d4,-(a1)
	move.w d2,-(a1)
sphere_b:	add.w #1,d7
	bra.s sphere

else2:	add.w #2,a2		; x=x+2
	sub.w #2,a3		; y=y-2
	add.w a3,a4
	sub.w a2,a4		; delta=delta+y-x
	sub.l a6,d0		; xg=xg-1.1
	add.l a6,d6		; xd=xd+1.1
	jmp (a5)
	
else1:	sub.w a3,d5		; d=d-y
	bmi.s else3		; si d>0
	add.w #2,a2		; x=x+2
	sub.w a2,a4		; delta=delta-x
	sub.l a6,d0		; xg ..
	add.l a6,d6		; xd ..
	bra.s sphere

else3:	add.w #2,a2
	sub.w #2,a3
	add.w a3,a4
	sub.w a2,a4
	sub.l a6,d0
	add.l a6,d6
	jmp (a5)
fin_sphere:	rts

tournes_1:	lea xgs_xdsb_t1(pc),a5
	neg.w d1
	add.w d1,d1
	bra ret_tournes
	
xgs_xdsb_t1:	clr.w hors_vue
	lea xgs_xds_t1(pc),a5
xgs_xds_t1:	move.l d0,d2
	bpl.s xgs_posi_t1
	moveq #0,d2	
xgs_posi_t1:	swap d2
	move.l d6,d4
	swap d4
	cmp.w #320*4-1,d4
	ble.s xds_i320_t1
	move.w #320*4-1,d4
xds_i320_t1:	tst.w d7
	bmi.s sphere_b1
	move.w d4,-(a1)
	move.w d2,-(a1)
sphere_b1:	add.w #1,d7
	bra sphere

tournes_2:	lea xgs_xdsb_t2(pc),a5
	sub.w #nb_ligne,d1
	add.w d1,d1
	bra ret_tournes
	
xgs_xdsb_t2:	clr.w hors_vue
	lea xgs_xds_t2(pc),a5
xgs_xds_t2:	move.l d0,d2
	bpl.s xgs_posi_t2
	moveq #0,d2	
xgs_posi_t2:	swap d2
	move.l d6,d4
	swap d4
	cmp.w #320*4-1,d4
	ble.s xds_i320_t2
	move.w #320*4-1,d4
xds_i320_t2:	tst.w d3
	bmi.s sphere_h1
	move.w d2,(a0)+
	move.w d4,(a0)+
sphere_h1:	add.w #1,d3
	bra sphere

tournes_3:	move.l a5,save_add_sph
	lea xgs_xds_t3(pc),a5
	bra sphere

xgs_xds_t3:	move.l d6,d4
	bpl.s ret_ecr_sph
	tst.w d3
	bmi.s sphere_h3
	add.w #4,a0
	add.w #1,image_x
	sub.w #1,2+image_x
sphere_h3:	add.w #1,d3
	tst.w d7
	bmi.s sphere_b3
	sub.w #4,a1
	sub.w #1,2+image_x
sphere_b3:	add.w #1,d7
	bra sphere
ret_ecr_sph:	move.l save_add_sph,a5
	jmp (a5)

tournes_4:	move.l a5,save_add_sph
	lea xgs_xds_t4(pc),a5
	bra sphere

xgs_xds_t4:	cmp.l #320*4*65536-1,d0
	ble.s ret_ecr_sph
	tst.w d3
	bmi.s sphere_h4
	add.w #4,a0
	add.w #1,image_x
	sub.w #1,2+image_x
sphere_h4:	add.w #1,d3
	tst.w d7
	bmi.s sphere_b4
	sub.w #4,a1
	sub.w #1,2+image_x
sphere_b4:	add.w #1,d7
	bra sphere

*********** D A T A **************** 

motif_plein:	dc.w 0,-1

a set $ffff
b set 0
motif2:	rept 16
	dc.w a>>b,0
b set b+1
	endr

a set $8000
b set $8000
motif3:	rept 16
	dc.w a,0
b set b/2
a set a+b
	endr
inst_couleur:
aff set $815c
eff set $c55c
	dc.w eff,aff
aff set $835c
eff set $c15c
	dc.w eff,aff
inst_couleur2:
aff set $8154
eff set $c554
	dc.w eff,aff
aff set $8b5c
eff set $c35c
	dc.w eff,aff
aff set $8354
eff set $c154
	dc.w eff,aff
aff set $8b5c
eff set $c55c
	dc.w eff,aff
***********
 BSS

coul:	ds.w 1
oldcoul:	ds.w 1
hors_vue:	ds.w 1
table_160:	ds.l 205		; table de multiplic
teste_flag:	ds.b 10

save_add_sph:	ds.l 1
add_x_y:	ds.l 1
sommet:	ds.w nb_som_f_m*2*2+2

pente_g:	ds.w 60
pente_d:	ds.w 60
add_pente_d:	ds.l 1

image_x:	ds.w 6+nb_ligne*2	; ymin_p+dy+ymax_p+xmin_xmax_poly+coul

motif_g:	ds.l 4*4*20
motif_d:	ds.l 4*4*20
motif_ligne:	ds.w 4*2
off_motif:	ds.w 1
 text

*************************************************************
* module:				*
* CALCUL - AFFICHAGE D' ETOILES EN 3D		*
* Les etoiles sont 1 plan (couleurs 1,2,4,8) ½ GEN 29-02-92 *
*************************************************************
	opt o+,o1+,o2+,ow-

**** Initialisation des tableaux ****

init_tabl_et:	lea motif_etoiles,a0
	move.w #20-1,d7
	moveq #0,d1
rempl_m_et12:	move.w #16-1,d6
	move.w #$8000,d0
rempl_m_et11:	move.w d0,(a0)+
	move.w d1,(a0)+
	lsr.w #1,d0
	dbf d6,rempl_m_et11
	add.w #8,d1
	dbf d7,rempl_m_et12

	move.w #0,coul_et
	move.w #-1,oldcoul_et
	rts

*********************************
traite_etoiles:
	jsr rot_etoiles_obs(pc)
	jsr put_etoiles(pc)
	rts

***** Rotation des etoiles *****
rot_etoiles_obs:
	lea coord_etoiles,a0
	lea etoiles_rota,a1
	move.w #nb_etoiles-1,d7

rotation_ob0:	movem.w (a0)+,d0-d3	; xw,yw,zw,ze
	save d3/d7/a0
	jsr transfo_etoiles(pc)	; ->xs,ys,ze
	load d3/d7/a0

	movem.w d0/d1/d3,(a1)
	add.w #3*2,a1
	dbf d7,rotation_ob0
	rts

*********** Transformation monde-observateur *******
transfo_etoiles:
	;-> d0,d1,d2=xpos,ypos,zpos
	;<- d0,d1,d2=xs,ys,zs

	lea mat_obs,a0
	jsr multi_vect(pc)


	asl.l #2,d2
	swap d2		; d2/16384
	move.w d2,d2
	ble.s depassement
	divs d2,d0
	bvs.s depassement
	muls #(ptf*vsx)/s,d0
	asl.l #2,d0
	swap d0		; d1/16384
	add.w #160,d0		; xs=ptf*xe/ze+160

depa_x0:	divs d2,d1
	bvs.s depassement
	muls #(ptf*vsy)/s,d1
	asl.l #2,d1
	swap d1		; d1/16384
	add.w #100,d1		; ys=ptf*ye/ze+100
	rts
depassement:	move.w #-1000,d0
	rts

***** Affichage des ‚toiles *****

put_etoiles:	lea etoiles_rota,a0
	lea motif_etoiles,a1
	lea table_160,a2
	move.l ecrans_t,a4

	move.w #nb_etoiles-1,d7
	move.w #320,d2
	move.w #200,d3
put_etdb0:	move.w (a0),d0
	bmi.s put_et0
	cmp.w d2,d0
	bge.s put_et0
	move.w 2(a0),d1
	bmi.s put_et0
	cmp.w d3,d1
	bge.s put_et0
	add.w d1,d1
	add.w d1,d1
	move.l a4,a3
	add.l (a2,d1.w),a3
	add.w d0,d0
	add.w d0,d0
	move.l (a1,d0.w),d0
	add.w d0,a3
	add.w 4(a0),a3
	swap d0
	or.w d0,(a3)
put_et0:	add.w #3*2,a0
	dbf d7,put_etdb0
	rts
*********** D A T A **************** 
 DATA

coord_etoiles:	incbin 500etsp4.dat

***********
 BSS
coul_et:	ds.w 1
oldcoul_et:	ds.w 1
motif_etoiles:	ds.l 16*20

*******
 even
etoiles_rota:	ds.w nb_etoiles*4
 text

************* Sections Data *************
 section data
 even
chiffre:	dc.w $0ff0,$f00f,$f00f,$f00f,$f00f,$0ff0
	dc.w $00f0,$0ff0,$00f0,$00f0,$00f0,$0fff
	dc.w $ffff,$000f,$00f0,$0f00,$f000,$ffff
	dc.w $ffff,$000f,$0fff,$0fff,$000f,$ffff
	dc.w $f000,$f000,$f0f0,$ffff,$00f0,$00f0
	dc.w $ffff,$f000,$ffff,$000f,$000f,$ffff
	dc.w $ffff,$f000,$ffff,$f00f,$f00f,$ffff
	dc.w $ffff,$000f,$0fff,$000f,$000f,$000f
	dc.w $0ff0,$f00f,$0ff0,$0ff0,$f00f,$0ff0
	dc.w $ffff,$f00f,$ffff,$000f,$000f,$ffff
	dc.w $0ff0,$f00f,$ffff,$ffff,$f00f,$f00f
	dc.w $fff0,$f00f,$fff0,$f00f,$f00f,$fff0
	dc.w $0ff0,$f00f,$f000,$f000,$f00f,$0ff0
	dc.w $fff0,$f00f,$f00f,$f00f,$f00f,$fff0
	dc.w $ffff,$f000,$fff0,$fff0,$f000,$ffff
	dc.w $ffff,$f000,$fff0,$fff0,$f000,$f000	* f
	dc.w $0fff,$f00f,$f000,$f0ff,$f00f,$0ff0
	dc.w $f00f,$f00f,$ffff,$ffff,$f00f,$f00f
	dc.w $ffff,$0ff0,$0ff0,$0ff0,$0ff0,$ffff
	dc.w $ffff,$00ff,$00ff,$00ff,$f0ff,$0ff0
	dc.w $f00f,$f0f0,$ff00,$ff00,$f0f0,$f00f

colors:	dc.w $000,$777,$667,$642,$545,$752,$445,$556,$444
	dc.w $334,$432,$700,$070,$007,$770,$707,$077,$757

zero:	dcb.l 8
zik:	incbin ziggy.mus
*******
 even
angle:	incbin angle_l3.dat
cosinus=angle+3*360*4*2
 even

*******
 even
objets:	incbin carre.obj
 even
	incbin incal.obj
 even
	incbin interpha.obj
 even
	incbin dark.obj
 even
	incbin hangar.obj
 even
*******
 even
observateur:	dc.w 0,0,-200
	dc.w 0,0,0		; angles de vis‚

*******
 even
def_monde:	dc.w 10		; nb_objet
	dc.w 1,0,100,200,0,0,0
	dc.w 2,0,0,200,0,0,0
	dc.w 1,0,-100,200,0,0,0
	dc.w 4,-200,0,300,0,0,0
	dc.w 4,-100,0,300,0,0,0
	dc.w 4,0,0,300,0,0,0
	dc.w 4,100,0,300,0,0,0
	dc.w 4,200,0,300,0,0,0
	dc.w 5,0,0,500,90,0,0
	dc.w 5,0,0,900,90,0,0
*******
 even
touches:	dc.w $01,$68,$6e,$6a,$6c,$48,$50,$67,$69,$4a,$4e
	dc.w $63,$65,$15,$30,$22,$23,$0f,$1d,$1c,$10

*************  Sections  Bss  ***********
 section bss
 even
oldscreen:	ds.l 1
oldvbl:	ds.l 1
nb_vbl:	ds.w 1
flag:	ds.w 1
ecrans_t:	ds.l nb_ecran
mus:	ds.w 1
flags_test:	ds.l 30
*******
 even
obs_x:	ds.l 1	; position en x,y,z de l'obs
obs_y:	ds.l 1
obs_z:	ds.l 1

obs_a:	ds.l 1	; angle de vis‚e
obs_b:	ds.l 1
obs_g:	ds.l 1
obs_ai:	ds.l 1
obs_bi:	ds.l 1
obs_gi:	ds.l 1

vis_x:	ds.w 1
vis_y:	ds.w 1
vis_z:	ds.w 1
vis_zi:	ds.w 1
*******
 even
mat_obs:	ds.l 3*3	; matrice de rotation
mat_obs_i:	ds.l 3*3	; et inverse
*******
 even
mat_obj:	ds.l 3*3
f_rota_obj	ds.w 1

sommets_rota:	ds.w nb_somm_max*3+nb_objet_max
sommets_base:	ds.w nb_somm_max*3+nb_objet_max
def_faces:	ds.w nb_objet_max*(nb_face_max*(nb_som_f_m*2+2)+1)
add_som_lib:	ds.l 1

posi_objets:	ds.w (3+3)*nb_objet_max	; x,y,z + al,be,ga
dif_objets:	ds.w (2+2+3+2)*nb_objet_max	; somm. base,somm. rota,bary,posi_obj

add_objets:	ds.l nb_objet_max*2	; ad. dif_objets,ad. face

nb_obj_visi:	ds.w nb_objet_max
obj_visi:	ds.w nb_objet_max*3	; 'add_objets' des obj. visibles
f_visi:	ds.w 1
indice:	ds.w nb_face_max*nb_objet_max
affich:	ds.w (1+2)*nb_face_max*nb_objet_max	
	; zmoyen + 2 add de la face

************
 even
transfer:	ds.l 20
NILL_CHAR
phys1:	ds.b 160*nb_ligne*nb_ecran+256
*phys1=$78400-nb_ligne*160*nb_ecran-256
*phys1=$80000-nb_ligne*160*nb_ecran-256
 END
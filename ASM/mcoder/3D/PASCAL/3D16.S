
	opt	o+
	output	e:\bin\3d16.tos

	 ;#[ Equates:
CPU_TIME	EQU	0
CLEAR_SCREEN	EQU	1
MUSIC	EQU	1
FRAME_COUNT	EQU	1
PCMSAMPLE	EQU	0
CLIPPING	EQU	1


VBL_COUNT	EQU	$465	;adresse du compteur vbl
NB_LINES	EQU	200
CLIPSIZE	EQU	4096
MUS_NB	EQU	1


NB_SCREEN	EQU	4
SWITCH_SCREEN	MACRO
	lea	Screen_list,a0
	movem.l	(a0),d0-d3
	move.l	d0,d4
	movem.l	d1-d4,(a0)
	lsr	#8,d3
	move.l	d3,$ffff8200.w
	ENDM
	 ;#] Equates:
	 ;#[ Initializations:
Start:	move.l	4(a7),a3	base page
	lea	Mystack,a7
	move.l	$c(a3),d0	text len
	add.l	$14(a3),d0	data len
	add.l	$1c(a3),d0	bss len
	add.l	#$100,d0	basepage
	move.l	d0,-(a7)
	move.l	a3,-(a7)
	clr	-(a7)
	move	#$4a,-(a7)
	trap	#1	shrink memory
	lea	12(a7),a7

	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,-(a7)

	IFNE	MUSIC
	bsr	Set_music
	ENDC

	IFNE	PCMSAMPLE
	jsr	InitPCM
	ENDC

	jsr	Initpoly(pc)
	jsr	Genfastcls(pc)
	jsr	Create_muls_table(pc)
	lea	Objects,a0
	move.l	a0,Current_object
	move.l	(a0)+,Current_anim
	move.l	(a0)+,Vrotx & Vroty
	move.l	(a0)+,Vrotz & Vdist
	move.l	(a0)+,Rotx & Roty
	move.l	(a0)+,Rotz & Dist
	move	(a0),Cptwaiting
	 ;#] Initializations:
	 ;#[ Save Contex:
	move.l	$14.w,Sys_zero
	move.l	#Zero_divide,$14.w

	move.b	$ffff8260.w,Sys_rez
.Synchronize:	move.b	$ffff8209.w,d0
	moveq	#$7f,d1
.Wait_sync:	cmp.b	$ffff8209.w,d0
	dbne	d1,.Wait_sync
	bne.s	.Synchronize
	clr.b	$ffff8260.w

	move.l	$ffff8200.w,d0
	move.l	d0,Sys_screen
	lsl	#8,d0
	and.l	#$ffff00,d0

Set_screens:	lea	Screen_list,a0
	move.l	d0,(a0)+		;Current_screen
	move.l	#Screen2,d0
	add.l	#256,d0
	clr.b	d0
	rept	NB_SCREEN-2
	move.l	d0,(a0)+
	add.l	#32000,d0
	endr
	move.l	d0,(a0)

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,Sys_palette
	movem.l	Palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.b	#$12,$fffffc02.w
	move.l	$fffffa06.w,Sys_mfp
	clr.l	$fffffa06.w
	move.l	$70.w,Sys_vbl
	move.l	#New_vbl,$70.w
	 ;#] Save Contex:
	 ;#[ Main:
Main:	move.l	usp,a0
	move.l	a0,-(a7)

Repeat:
	IFNE	CLEAR_SCREEN
	jsr	Ffastcls(pc)
	ENDC

	jsr	Calcproj(pc)

	move.l	Current_anim(pc),a3	;lire la prochaine animation
	move.l	(a3)+,d0		;adresse de l'objet
	bne.s	Cont_anim		;c'est la derniŠre image
	move.l	(a3),a3		;Return image boucle
	move.l	(a3)+,d0

Cont_anim:	move.l	a3,Current_anim
	move.l	d0,a2
	lea	Project(pc),a1
	jsr	Calcobj(pc)
	move.l	(a2),a2
	jsr	Traceobj(pc)

	SWITCH_SCREEN

	addq	#1,Frame_counter
	move.b	$fffffc02.w,d0
	cmp.b	#$4e,d0
	bne.s	.Not_plus
	addq	#4,Dist
	bra.s	Repeat
.Not_plus:	cmp.b	#$4a,d0
	bne.s	.Not_minus
	subq	#4,Dist
	bra.s	Repeat
.Not_minus:	cmp	#500,Dist
	bls.s	Test_keyboard
	move.l	Current_object(pc),a0	;passe objet suivant
	lea	STRUCT_SIZE(a0),a0
	tst.l	(a0)
	bne.s	.Not_object_end
	lea	Objects,a0

.Not_object_end:
	move.l	a0,Current_object
	move.l	(a0)+,Current_anim
	move.l	(a0)+,Vrotx	;& Vroty
	move.l	(a0)+,Vrotz	;& Vdist
	move.l	(a0)+,Rotx	;& Roty
	move.l	(a0)+,Rotz	;& Dist
	move	(a0),Cptwaiting
	bra	Repeat
		;#[ Keyboard manager:
Test_keyboard:	move.b	$fffffc02.w,d0
.Left_arrow:	cmp.b	#$4B,d0
	bne.s	.Right_arrow
	subq	#1,Vrotx
	bra	Repeat
.Right_arrow:	cmp.b	#$4D,d0
	bne.s	.Up_arrow
	addq	#1,Vrotx
	bra	Repeat
.Up_arrow:	cmp.b	#$48,d0
	bne.s	.Down_arrow
	addq	#1,Vroty
	bra	Repeat
.Down_arrow:	cmp.b	#$50,d0
	bne.s	.Insert
	subq	#1,Vroty
	bra	Repeat
.Insert:	cmp.b	#$52,d0
	bne.s	.Clr_home
	subq	#1,Vrotz
	bra	Repeat
.Clr_home:	cmp.b	#$47,d0
	bne.s	.Space
	addq	#1,Vrotz
	bra	Repeat
.Space:	cmp.b	#$39,d0
	bne	Repeat
	move.l	(a7)+,a0
	move.l	a0,usp
		;#] Keyboard manager:
	 ;#] Main:
	 ;#[ Restore Contex:
Restore:	move.l	Sys_vbl,$70.w
	move.l	Sys_zero,$14.w
	move.b	#8,$fffffc02.w
	move.b	Sys_mfp+1,$fffffa07.w
	move.b	Sys_mfp+3,$fffffa09.w

Sound_off:	lea	$ffff8800.w,a0
	moveq	#$a,d0
.Loop:	move.b	d0,(a0)
	sf	2(a0)
	dbf	d0,.Loop
	move.b	#7,(a0)
	st	2(a0)

.Synchronize:	move.b	$ffff8209.w,d0
	moveq	#$7f,d1
.Wait_sync:	cmp.b	$ffff8209.w,d0
	dbne	d1,.Wait_sync
	bne.s	.Synchronize

	move.b	Sys_rez,$ffff8260.w
	movem.l	Sys_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	Sys_screen,$ffff8200.w

	move	#$20,-(a7)
	trap	#1
	addq	#6,a7

	clr	-(a7)
	trap	#1
	 ;#] Restore Contex:
	 ;#[ Zero Divide handling:
Zero_divide:	rte
	 ;#] Zero Divide handling:
	 ;#[ VBL Manager:
New_vbl:	addq.b	#1,VBL_COUNT.w

	clr	$ffff8240.w

;	clr.b	$fffffa1b.w
;	move.b	#199-10,$fffffa21.w
;	move.b	#8,$fffffa1b.w

	movem.l	d0-d7/a0-a3/a6,-(a7)
	move	$ffff825e.w,d0
	and	#$777,d0
	addq	#1,d0
	move	d0,$ffff825e.w
	IFNE	FRAME_COUNT

	subq	#1,Vbl_counter
	bgt.s	.Not_50_frames
	move	#50,Vbl_counter
	move	Frame_counter(pc),Nb_frames
	clr	Frame_counter
.Not_50_frames:
	move.l	Work_screen,a0
	addq	#2,a0
	move	Nb_frames(pc),d0
	add	d0,d0
	add	d0,d0
	jsr	Zeroa99(pc,d0)

	lea	160*10(a0),a0
	move	Vrotx(pc),d0
	and	#$fc,d0
	jsr	Zeroa99(pc,d0)

	lea	160*10(a0),a0
	move	Vroty(pc),d0
	and	#$fc,d0
	jsr	Zeroa99(pc,d0)

	lea	160*10(a0),a0
	move	Vrotz(pc),d0
	and	#$fc,d0
	jsr	Zeroa99(pc,d0)

	bra	Skip_display
Zeroa99:	incbin	Zeroa99.bin
	rts
Skip_display:
	ENDC

	IFNE	MUSIC
	bsr	Play_music
	ENDC

	tst.b	Cptwaiting
	bgt.s	.Noincdist

;	move	Vdist(pc),d0
;	add	d0,Dist
	addq	#8,Dist

	bra.s	.Gescurseur
.Noincdist:	subq	#1,Cptwaiting
.Gescurseur:	movem.l	(a7)+,d0-d7/a0-a3/a6
	rte
	 ;#] VBL Manager:
	 ;#[ Draw Object:
		;#[ Compute line:
*****************************************************************
*routine d'affichage de polygones convexes
*avec CLIPPING et tramage
*	- calcul des droites dans une table
*	- remplissage par movem.l
*	- tramage 16 couleurs
*	- CLIPPING automatique en x
*
* appel : en mode superviseur obligatoire
*
*
* a6 -> adresse des datas	(des points projetes)
* d6 -> nombre de points	(du polygone)
* d7 -> couleurs * 8	(attention)
*****************************************************************

;------------- d‚finition des registres -------------------------

Miny	EQUR	d6	;r‚serv‚s dans tous le calcul
Maxy	EQUR	d7
Ptrtable	EQUR	a0	;pointeur table des minx-maxx
Ecran	EQUR	a1	;adresse ecran

;------------- registres pour calcul lignes ---------------------

Xa	EQUR	d0	;extremit‚s de la droite
Ya	EQUR	d1
Xb	EQUR	d2
Yb	EQUR	d3

Ptrsegment	EQUR	a6	;pointeur sur segment
Copptrsegment	EQUR	a0	;copie pointeur sur segment

Jmpline	EQUR	a3	;adresse routine de droite
Return	EQUR	a1	;adresse de Return droite

Ptry	EQUR	a2	;pointeur tabley
Dy	EQUR	d4
Regdata	EQUR	d5

Jmp	EQUR	a5	;adresse debut du saut
			;pour calcul des points


;-------------- calcul et CLIPPING d'une ligne verticale ---------------

	rept	NB_LINES
	move	Xa,(Ptry)+	;mise en place 2 nouveaux points
	endr
Returnvert:	jmp	(Return)	;ligne verticale invisible
Vertline:	cmp	#NB_LINES,Ya	;CLIPPING
	bcs.s	.Yasupzero
	bge.s	Returnvert
	moveq	#0,Ya
.Yasupzero:	cmp	#NB_LINES,Yb
	bcs.s	.Ybinfmax
	blt.s	Returnvert
	move	#NB_LINES-1,Yb
.Ybinfmax:	cmp	Maxy,Yb	;tester maximum
	ble.s	.Pasmaximum
	move	Yb,Maxy
.Pasmaximum:	cmp	Miny,Ya	;tester minimum
	bge.s	.Pasminimum
	move	Ya,Miny
.Pasminimum:
	sub	Ya,Yb	;Yb=Dy
	add	Ya,Ya
	add	Ya,Ptry	;debut table

	add	Yb,Yb	;Dy*2
	neg	Yb
	jmp	Returnvert-2(pc,Yb)

CalcReturn	;fin du calcul des points
	jmp	(Return)

;Lastx:	dc.w	0
;-------------- d‚but calcul des points d'une ligne -----------------

Calcline:
	lea	Tableymax(pc),Ptry
	cmp	Ya,Yb	;c'est un ligne montante ?
	beq.s	CalcReturn	;ligne horizontale -> fin

	bge.s	.Yb_sup_ya

	exg	Xa,Xb	;‚change les points
	exg	Ya,Yb
	lea	2*NB_LINES(Ptry),Ptry ;c'est une ligne montante

.Yb_sup_ya:	;move	Xb,Lastx
	sub	Xa,Xb	;dx
	beq.s	Vertline	;c'est une ligne verticale
	move	Yb,Regdata	;pr‚pare calcul du Dy
	sub	Ya,Regdata	;Dy
	ext.l	Xb	;calcul de la pente
	asl.l	#4,Xb	;dx*16 (et *8)
	DIVS	Regdata,Xb	;divise par Dy

;	bvc.s	.nodeborde	;controle d‚bordement
;	add	#$70,$ffff8240.w
;.nodeborde:

	ext.l	Xb	;extention du r‚sultat
	cmp	#NB_LINES,Ya	;CLIPPING haut
	bcs.s	.Yasup0
	bge.s	CalcReturn	;ligne invisible
	MULS	Xb,Ya	;CLIPPING
	lsr.l	#4,Ya	;divise par 16
	sub	Ya,Xa	;addition … Xa
	moveq	#0,Ya	;Ya=0
	move	Yb,Regdata	;nombre de ligne=Yb
.Yasup0:	cmp	#NB_LINES,Yb
	bcs.s	.Ybinfmax
	blt.s	CalcReturn
	move	#NB_LINES-1,Yb ;moins de lignes
	move	Yb,Regdata
	sub	Ya,Regdata	;calcul Dy
.Ybinfmax:


;------------ mise a jour des maximums et minimum ----------

	cmp	Maxy,Yb	;tester maximum
	ble.s	.Pasmaximum
	move	Yb,Maxy

.Pasmaximum:	cmp	Miny,Ya	;tester minimum
	bge.s	.Pasminimum
	move	Ya,Miny

.Pasminimum	add	Ya,Ya	 ;adresse tableau lignes
	add	Ya,Ptry

	add	Regdata,Regdata  ;Offset pour le saut
	add	Regdata,Regdata
	neg	Regdata

	swap	Xb
	swap	Xa
	asr.l	#4,Xb

	move	Xb,Xa
	beq.s	Interger_line	;coef de pente entier
;	add	#$8000,Xa	;ajout de 0.5
	swap	Xa
	swap	Xb

	addq	#4,Xa

	jmp	(Jmpline,Regdata)


;---------- cas d'une ligne … coefficient entier -----------

Interger_line:	swap	Xa
	swap	Xb
	add	#.Int_line2-.Int_line1,Regdata
	jmp	.Int_line1(pc,Regdata)
.Int_line1:
	rept	NB_LINES-1
	move	Xa,(Ptry)+	;stocke point
	add	Xb,Xa	;calcul avec coef entier
	endr
.Int_line2:
	move	Xa,(Ptry)	;plot dernier point
	jmp	(Return)	;fin de calcul

;-------------- cas d'une droite coeficient fractionnaire ----

	rept	NB_LINES-1
	move	Xa,(Ptry)+	;stocke point
	addx.l	Xb,Xa	;ajout pente
	endr

Ajmpline:	move	Xa,(Ptry)	;stocke dernier points
	jmp	(Return)	;fin calcul


Reg1	EQUR	d0
Reg2	EQUR	d1
Reg3	EQUR	d2
X1	EQUR	d3
Offgau	EQUR	d4
X0	EQUR	d5
Offdro	EQUR	d6

Reg4	EQUR	a2
Ptrtable2	EQUR	a2

Reg5	EQUR	a3
Reg6	EQUR	a4
X_clip_ptr	EQUR	a5
Lecran	EQUR	a6


Polygone:	swap	Maxy	;mise … l'ecart du nombre de
	swap	Miny	;points et couleur

	clr	Maxy	;Maxy=0
	move	#NB_LINES,Miny	;Miny=y maximum

	swap	Miny	;Miny est compteur de points

	move.l	Ptrsegment,Copptrsegment
	lea	Lretjmp(pc),Return	;adresse de Return
	lea	Calcline(pc),Jmp	;adresse du calcul de droite
	lea	Ajmpline(pc),Jmpline
	subq	#1,Miny		;un point en moins

Repline:	movem	(Ptrsegment),Xa/Ya/Xb/Yb ;lecture des points
	addq	#4,Ptrsegment	 ;passe droite suivante
	swap	Miny	 ;sauve compteur
	jmp	(Jmp)	 ;calcul des points

Lretjmp:	swap	Miny	 ;restore compteur
;	dbf	Miny,Repline
	subq	#1,Miny	 ;un point de moins
	bne.s	Repline	 ;repeter...
	move	(Ptrsegment)+,Xa	 ;derniŠre droite
	move	(Ptrsegment),Ya
	move	(Copptrsegment)+,Xb
	move	(Copptrsegment),Yb
	lea	Drawpoly16(pc),Return
	swap	Miny
	jmp	(Jmp)
		;#] Compute line:
		;#[ Four planes polygone:
LINE_END	MACRO
	move.l	-(Ecran),Offgau
	eor.l	Reg2,Offgau
	and.l	X1,Offgau
	eor.l	Offgau,(Ecran)
	move.l	-(Ecran),Offgau
	eor.l	Reg1,Offgau
	and.l	X1,Offgau
	eor.l	Offgau,(Ecran)
	ENDM

No_polygone:	rts
Drawpoly16:	sub	Miny,Maxy	;calcul hauteur du polyg
	ble.s	No_polygone	;si non affich‚ alors fin
	swap	Maxy	;lecture de la couleur
	tst	Maxy
	bmi	Drawoneplane	;routine 1 plan

	add	Maxy,Maxy
	bmi	Drawtrame16	;tramage 16 couleurs

	lea	Tableymax(pc),Ptrtable
	movem.l	Colors_code-Tableymax(Ptrtable,Maxy),Reg1/Reg2

	swap	Maxy
	add	Miny,Miny
	add	Miny,Ptrtable

	lea	Muls160(pc),X_clip_ptr
	move.l	Work_screen,Lecran
	add	(X_clip_ptr,Miny),Lecran

	move.l	Reg1,Reg3	;charge Reg couleur
	move.l	Reg2,Reg4
	move.l	Reg1,Reg5
	move.l	Reg2,Reg6

	lea	Mlimit,X_clip_ptr

	bra.s	Dlrep16bra2
Dlrep16:	LINE_END
Dlrep16bra:	lea	160(Lecran),Lecran	;place ici pour
Dlrep16bra2:	move.l	Lecran,Ecran	;reduire MACRO 22

	moveq	#-8,X0
	and	(Ptrtable)+,X0
	movem.l	0(X_clip_ptr,X0),X0/Offdro	;X0
	add	Offdro,Ecran

	moveq	#-8,X1
	and	2*(NB_LINES-1)(Ptrtable),X1	;X1
	movem.l	0(X_clip_ptr,X1),X1/Offgau

	sub	Offgau,Offdro
	ble.s	.Short_line

	move.l	(Ecran),Offgau		;masque 2 mots
	eor.l	Reg2,Offgau
	and.l	X0,Offgau
	eor.l	Reg2,Offgau
	move.l	Offgau,(Ecran)

	move.l	-(Ecran),Offgau	;masque 2 mots
	eor.l	Reg1,Offgau
	and.l	X0,Offgau
	eor.l	Reg1,Offgau
	move.l	Offgau,(Ecran)

	add	Offdro,Offdro
	add	Offdro,Offdro
	jmp	Filler0-32(pc,Offdro)	;appel transfert par movem

.Short_line:	bne.s	.Lsuiv		;a enlever
	eor.l	X0,X1
	move.l	-(Ecran),Offgau	;perte 2 cycles
	eor.l	Reg1,Offgau
	and.l	X1,Offgau
	eor.l	Offgau,(Ecran)+
	move.l	(Ecran),Offgau
	eor.l	Reg2,Offgau
	and.l	X1,Offgau
	eor.l	Offgau,(Ecran)
.Lsuiv:	dbf	Maxy,Dlrep16bra
	rts

Filler0:	dbf	Maxy,Dlrep16
	LINE_END
	rts
	dcb.w	5,$4e71

Filler1:	move.l	Reg2,-(Ecran)	;bof...
	move.l	Reg1,-(Ecran)
	dbf	Maxy,Dlrep16
	LINE_END
	rts
	dcb.w	3,$4e71

Filler2:	movem.l	Reg1/Reg2/Reg3/Reg4,-(Ecran)
	dbf	Maxy,Dlrep16
	LINE_END
	rts
	dcb.w	3,$4e71

Filler3:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	dbf	Maxy,Dlrep16
	LINE_END
	rts
	dcb.w	3,$4e71

Filler4:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2,-(Ecran)
	dbf	Maxy,Dlrep16
	LINE_END
	rts
	dcb.w	1,$4e71

Filler5:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4,-(Ecran)
	dbf	Maxy,Dlrep16
	LINE_END
	rts
	dcb.w	1,$4e71

Filler6:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	dbf	Maxy,Dlrep16
Filler6bra:
	LINE_END
	rts
	dcb.w	1,$4e71

Filler7:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2,-(Ecran)
	dbf	Maxy,Dlrep16
	bra.s	Filler6bra
	dcb.w	7,$4e71

Filler8:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4,-(Ecran)
	dbf	Maxy,Dlrep16
	bra.s	Filler6bra
	dcb.w	7,$4e71

Filler9:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	dbf	Maxy,Dlrep16
	bra.s	Filler6bra
	dcb.w	7,$4e71

Filler10:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l Reg1/Reg2,-(Ecran)
	dbf	Maxy,Dlrep16
	bra	Fillerfin
	dcb.w	4,$4e71

Filler11:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4,-(Ecran)
	dbf	Maxy,Dlrep16
	bra	Fillerfin
	dcb.w	4,$4e71

Filler12:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	dbf	Maxy,Dlrep16
	bra	Fillerfin
	dcb.w	4,$4e71

Filler13:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2,-(Ecran)
	dbf	Maxy,Dlrep16
	bra	Fillerfin
	dcb.w	2,$4e71

Filler14:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4,-(Ecran)
	dbf	Maxy,Dlrep16
	bra	Fillerfin
	dcb.w	2,$4e71

Filler15:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	dbf	Maxy,Dlrep16
	bra.s	Fillerfin
	dcb.w	3,$4e71

Filler16:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2,-(Ecran)
	dbf	Maxy,Dlrep16
	bra.s	Fillerfin
	dcb.w	1,$4e71

Filler17:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4,-(Ecran)
	dbf	Maxy,Dlrep16
	bra.s	Fillerfin
	dcb.w	1,$4e71

Filler18:	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	movem.l	Reg1/Reg2/Reg3/Reg4/Reg5/Reg6,-(Ecran)
	dbf	Maxy,Dlrep16
Fillerfin:	LINE_END
	rts
		;#] Four planes polygone:
		;#[ Four planes tramed polygone:
Drawtrame16:	rts
		;#] Four planes tramed polygone:
		;#[ One plane polygone:
Drawoneplane:	lea	Tableymax(pc),Ptrtable	;adresse table
	add	Miny,Miny
	add	Miny,Ptrtable		;pointe table des x
	lea	2*NB_LINES(Ptrtable),Ptrtable2

	lea	Muls160pl(pc),X_clip_ptr
	move.l	Work_screen,Lecran
	add	0(X_clip_ptr,Miny),Lecran	;pointe ligne Ecran
	moveq	#$f,Reg2		;decalage plan no
	and	Maxy,Reg2
	add	Reg2,Lecran

	add	Maxy,Maxy
	bvc	Oneplanetrame		;un plan tram‚
	swap	Maxy		;recupere nombre de lignes
	moveq	#-1,Reg1		;pattern $ffff
	lea	Mlimit+2,X_clip_ptr	;table CLIPPING x

Dlrep1:	moveq	#-8,X0
	and	(Ptrtable)+,X0
	move.l	(X_clip_ptr,X0),X0

	moveq	#-8,X1
	and	(Ptrtable2)+,X1
	move.l	(X_clip_ptr,X1),X1

	sub	X0,X1
	bge.s	.Onelong1

	move.l	Lecran,Ecran
	add	X0,X0
	add	X0,Ecran
	swap	X0
	not	X0
	or	X0,(Ecran)
	jmp	Fillerplan+4(pc,X1)
.Onelong1:	bne.s	.Lsuiv1
	add	X0,X0
	eor.l	X0,X1		;gain 2 swap
	swap	X1
	or	X1,(Lecran,X0)
.Lsuiv1:	lea	160(Lecran),Lecran
	dbf	Maxy,Dlrep1
	rts
n	set	-18*8
	rept	18
	move	Reg1,n(Ecran)
n	set	n+8
	endr
Fillerplan:	add	X1,X1
	add	X1,Ecran
	swap	X1
	or	X1,(Ecran)
	lea	160(Lecran),Lecran
	dbf	Maxy,Dlrep1
	rts
		;#] One plane polygone:
		;#[ One plane tramed polygone:
Oneplanetrame:	swap	Maxy		;recupere nombre de lignes
	move.l	#$bbbbeeee,Reg1
	btst	#1,Miny
	beq.s	Tramepair
	swap	Reg1

Tramepair:	lea	Mlimit+2,X_clip_ptr	;table CLIPPING x

Edlrep1:	moveq	#-8,X0
	and	(Ptrtable)+,X0
	move.l	(X_clip_ptr,X0),X0

	moveq	#-8,X1
	and	(Ptrtable2)+,X1
	move.l	(X_clip_ptr,X1),X1

	sub	X0,X1
	bge.s	.Eonelong1

	move.l	Lecran,Ecran
	add	X0,X0
	add	X0,Ecran
	swap	X0
	not	X0
	and	Reg1,X0
	or	X0,(Ecran)
	jmp	EFillerplan+4(pc,X1)
.Eonelong1:	bne.s	.Elsuiv1
	add	X0,X0
	eor.l	X0,X1	;gain 2 swap
	swap	X1
	and	Reg1,X1
	or	X1,(Lecran,X0)
.Elsuiv1:	swap	Reg1
	lea	160(Lecran),Lecran
	dbf	Maxy,Edlrep1
	rts

n	set	-18*8
	rept	18
	move	Reg1,n(Ecran)
n	set	n+8
	endr
EFillerplan:	add	X1,X1
	add	X1,Ecran
	swap	X1
	and	Reg1,X1
	or	X1,(Ecran)
	lea	160(Lecran),Lecran
	swap	Reg1
	dbf	Maxy,Edlrep1
	rts
		;#] One plane tramed polygone:
		;#[ Miscellaneous tables:
Muls160:
n	set	4
	rept	NB_LINES
	dc.w	n
n	set	n+160
	endr
Muls160pl:	incbin	muls160.bin

Colors_code:	dc.l	$00000000,$00000000
	dc.l	$ffff0000,$00000000
	dc.l	$0000ffff,$00000000
	dc.l	$ffffffff,$00000000
	dc.l	$00000000,$ffff0000
	dc.l	$ffff0000,$ffff0000
	dc.l	$0000ffff,$ffff0000
	dc.l	$ffffffff,$ffff0000
	dc.l	$00000000,$0000ffff
	dc.l	$ffff0000,$0000ffff
	dc.l	$0000ffff,$0000ffff
	dc.l	$ffffffff,$0000ffff
	dc.l	$00000000,$ffffffff
	dc.l	$ffff0000,$ffffffff
	dc.l	$0000ffff,$ffffffff
	dc.l	$ffffffff,$ffffffff
		;#] Miscellaneous tables:
		;#[ CLS Init:
Tableymax:
Genfastcls:	lea	Bfastcls,a0
	move.l	#$48e6fffc,d0
	move	#40*(NB_LINES)/14-1,d1
.Gfcrep:	move.l	d0,(a0)+		;genere les movem
	dbf	d1,.Gfcrep
CLS_MOD	EQU	40*NB_LINES-(40*NB_LINES/14)*14
	IFNE	CLS_MOD
	move.l	#$48e60000+1<<(CLS_MOD+2)-4,(a0)+	;dernier movem
	ENDC
	move	#$4e75,(a0)	;rts
	rts
		;#] CLS Init:
		;#[ Clipping Init:
Initpoly:	lea	Llimit,a0	;table limites gauches
	move	#CLIPSIZE-1,d0	;taille limite gauche

.Rrlimit:	move.l	#-1,(a0)+	;remplissage
	clr.l	(a0)+	;Offset=0
	dbf	d0,.Rrlimit	;dernier ?

	moveq	#0,d0	;compteur pixel
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move	#$ffff,d1	;masque droit

.Rclimit:	move	d1,(a0)+	;stocke trame1
	move	d1,(a0)+	;2 fois

	move	d3,(a0)+	;stocke Offset
	move	d2,(a0)+

	lsr.l	#1,d1	;decalage masque

	bne.s	.2
	move	#$ffff,d1	;mise en place masque
	addq	#4,d3	;decalage Offset 4
	addq	#8,d2	;decalage Offset 8

.2:	addq	#1,d0	;un pixel de plus
	cmp	#319,d0	;pixel 319 ?
	ble.s	.Rclimit	;non, continuer

	move	#CLIPSIZE-1,d0
.Rllimit:	clr.l	(a0)+	;init limite droite
	move.l	#$004c0098,(a0)+
	dbf	d0,.Rllimit
	rts
		;#] Clipping Init:
		;#[ Create MULS table:
Create_muls_table:
	lea	Rotate_table,a0
	move	#$ff,d0
	moveq	#-$80,d2
.Loop0:	moveq	#$7f,d1
	moveq	#0,d3
.Loop1:	move	d3,d4
	ext	d4
	muls	d2,d4
	move	d4,(a0)+
	addq	#2,d3
	dbf	d1,.Loop1
	addq	#1,d2
	dbf	d0,.Loop0
	rts
Ftableymax:	ds.b	4*NB_LINES-(Ftableymax-Tableymax)
		;#] Create MULS table:
		;#[ Compute 3D Matrix:
Calcproj:
	IFNE	CPU_TIME
	move	#7,$ffff8240.w
	ENDC
		;#[ No MULS Matrix:
Matrix_pointer	EQUR	a0
Trigo_table1	EQUR	a1
Trigo_table2	EQUR	a2

Save1	EQUR	a3
Save2	EQUR	a4
Save3	EQUR	a5
Save4	EQUR	a6
Save5	EQUR	d3
Save6	EQUR	a2 (!)

X_angle	EQUR	d4
Y_angle	EQUR	d5
Z_angle	EQUR	d6
Trigo_mask	EQUR	d7

	lea	Matrix(pc),Matrix_pointer
	lea	Sincos4(pc),Trigo_table1
	lea	$1000(Trigo_table1),Trigo_table2

	move	Vrotx(pc),d0
	add	d0,Rotx
	move	Vroty(pc),d0
	add	d0,Roty
	move	Vrotz(pc),d0
	add	d0,Rotz

	move	Rotx(pc),X_angle
	move	Roty(pc),Y_angle
	move	Rotz(pc),Z_angle
	move	#$3ff*4,Trigo_mask

	move	Y_angle,d0	;y
	move	d0,d1
	add	Z_angle,d1	;y+z
	sub	Z_angle,d0	;y-z
	and	Trigo_mask,d1
	and	Trigo_mask,d0
	move.l	0(Trigo_table1,d0),d0	;s(y-z)|c(y-z)/2
	move.l	0(Trigo_table1,d1),d1	;s(y+z)|c(y+z)/2

	add	d1,d0
	move	d0,(Matrix_pointer)+	;(c(y+z)+c(y-z))/2

	swap	d0
	swap	d1
	sub	d1,d0
	move	d0,(Matrix_pointer)+	;(s(y+z)-s(y-z))/2

	move	Y_angle,d0
	and	Trigo_mask,d0
	move	(Trigo_table1,d0),d0
	add	d0,d0
	neg	d0
	move	d0,(Matrix_pointer)+	;-s(y)

	move	X_angle,d0	;x+y
	add	Y_angle,d0	;x+y
	move	d0,d1
	add	Z_angle,d0	;x+y+z
	sub	Z_angle,d1	;x+y-z
	and	Trigo_mask,d0
	and	Trigo_mask,d1

	move.l	0(Trigo_table2,d0),d0	;s(x+y+z)/4|c(x+y+z)/4
	move.l	0(Trigo_table2,d1),d1	;s(x+y-z)/4|c(x+y-z)/4
	move.l	d0,Save1
	move.l	d1,Save2

	add	d1,d0	;cos	;c(x+y+z)+c(x+y-z)/4
	swap	d0
	swap	d1
	sub	d1,d0	;sin	;c(x+y+z)+c(x+y-z)|s(x+y+z)-s(x+y-z)/4

	move	X_angle,d1
	sub	Y_angle,d1
	move	d1,d2
	add	Z_angle,d1	;x-y+z
	sub	Z_angle,d2	;x-y-z
	and	Trigo_mask,d1
	and	Trigo_mask,d2
	move.l	0(Trigo_table2,d1),d1	;s(x-y+z)|c(x-y+z)/4
	move.l	0(Trigo_table2,d2),d2	;s(x-y-z)|c(x-y-z)/4
	move.l	d1,Save3
	move.l	d2,Save4

	add	d2,d1	;cos
	swap	d1
	swap	d2
	sub	d2,d1	;sin	;(c(x-y+z)+c(x-y-z))/4|(s(x-y+z)-s(x-y-z))/4

	sub	d1,d0	;sin
	swap	d0
	swap	d1
	sub	d1,d0	;cos

	move	X_angle,d1
	move	d1,d2
	add	Z_angle,d1	;x+z
	sub	Z_angle,d2	;x-z
	and	Trigo_mask,d1
	and	Trigo_mask,d2
	move.l	0(Trigo_table1,d1),d1	;s(x+z)|c(x+z)/2
	move.l	0(Trigo_table1,d2),d2	;s(x-z)|c(x-z)/2
	move.l	d1,Save5
	move.l	d2,Save6

	add	d2,d1	;cos	;(c(x+z)+c(x-z))/2
	swap	d1
	swap	d2
	sub	d2,d1	;sin	;(c(x+z)+c(x-z))/2|(s(x+z)-s(x-z))/2

	add	d0,d1	;cos
	swap	d0
	swap	d1

	sub	d0,d1	;sin

	move.l	d1,(Matrix_pointer)+

	move	X_angle,d0
	move	d0,d1
	add	Y_angle,d0
	sub	Y_angle,d1
	and	Trigo_mask,d0
	and	Trigo_mask,d1

	move	0(Trigo_table1,d0),d0
	add	0(Trigo_table1,d1),d0

	neg	d0
	move	d0,(Matrix_pointer)+

	move.l	Save1,d1
	move.l	Save2,d0
	sub	d1,d0
	swap	d0
	swap	d1
	add	d1,d0	;c(x+y-z)-c(x+y+z)/4|s(x+y-z)+s(x+y+z)/4

	move.l	Save3,d1
	move.l	Save4,d2
	sub	d2,d1
	swap	d1
	swap	d2
	add	d2,d1

	sub	d1,d0
	swap	d0
	swap	d1
	add	d1,d0
	neg	d0

	move.l	Save5,d1
	move.l	Save6,d2

	sub	d2,d1
	swap	d1
	swap	d2
	add	d2,d1

	add	d1,d0
	swap	d0
	swap	d1
	sub	d1,d0

	swap	d0
	move.l	d0,(Matrix_pointer)+

	move	X_angle,d0
	add	Y_angle,d0
	sub	Y_angle,X_angle
	and	Trigo_mask,d0
	and	Trigo_mask,X_angle
	move	2(Trigo_table1,d0),d0
	add	2(Trigo_table1,X_angle),d0
	move	d0,(Matrix_pointer)
		;#] No MULS Matrix:
	IFNE	CPU_TIME
	clr	$ffff8240.w
	ENDC
	rts
		;#] Compute 3D Matrix:
		;#[ Rotate Object:
; registres utilises :
;	a0-a6 sauf a1
;	a2 peut etre libere
;	d1-d7 sauf d4
;
; registres libres :
;	a1,d0,d4
;

Calcobj:
	IFNE	CPU_TIME
	move	#$70,$ffff8240.w
	ENDC
	lea	Matrix(pc),a6
	move	(a2)+,d5

; occupes :	d0/d1/d2/d3/d4/d6/d7
;	a1/a2/a4/a6
; libres :	d5
;	a0/a3/a5 translation x,y,z

	move	Obsx(pc),a0
	move	Obsy(pc),a3
	move	Obsz(pc),a5
	sub	Dist(pc),a5
	moveq	#-8,d4

	move.l	a6,usp
	lea	Rotate_table+$8000,a6
Rotate:	move.l	usp,a4
	movem	(a2)+,d1/d2/d3

	and	#-2,d1
	and	#-2,d2
	and	#-2,d3

	moveq	#0,d6
	moveq	#0,d7

	move	(a4)+,d6
	move.b	d1,d6
	move	0(a6,d6),d6
	move	(a4)+,d7
	move.b	d2,d7
	add	0(a6,d7),d6
	move	(a4)+,d7
	move.b	d3,d7
	add	0(a6,d7),d6
	add	a0,d6
	ext.l	d6
	lsl.l	#3,d6

	move	(a4)+,d7
	move.b	d1,d7
	move	0(a6,d7),d7
	move	(a4)+,d0
	move.b	d2,d0
	add	0(a6,d0),d7
	move	(a4)+,d0
	move.b	d3,d0
	add	0(a6,d0),d7
	add	a3,d7
	ext.l	d7

	move	(a4)+,d0
	move.b	d1,d0
	move	0(a6,d0),d1
	move	(a4)+,d0
	move.b	d2,d0
	add	0(a6,d0),d1
	move	(a4)+,d0
	move.b	d3,d0
	add	0(a6,d0),d1
	asr	#8,d1
	add	a5,d1

	DIVS	d1,d6
	DIVS	d1,d7

	and	d4,d6
	add	#NB_LINES/2,d7

	move	d7,(a1)+
	move	d6,(a1)+
	dbf	d5,Rotate

	IFNE	CPU_TIME
	clr	$ffff8240.w
	ENDC
	rts
		;#] Rotate Object:
		;#[ Vertices handling:
Hidefacette:	lea	16(a2),a2
Traceobj:
Rfacettes:	move	(a2)+,d0
	bmi	Ffacettes
Rfacette2:	lea	Project(pc),a1

	move.l	0(a1,d0),d0	;Xa/Ya
	move	(a2)+,d1
	move.l	0(a1,d1),d1	;Xb/Yb
	move	(a2)+,d2
	move.l	0(a1,d2),d2	;Xc/Yc

	move	d1,d5
	sub	d0,d5	;Xb-Xa
	move	d2,d6
	sub	d1,d6	;Xc-Xb

	swap	d0
	swap	d1
	swap	d2

	move	d0,d3
	sub	d1,d3	;Ya-Yb
	move	d2,d4
	sub	d1,d4	;Yc-Yb

	move	d5,d7
	eor	d4,d7
	bmi.s	.F1inf
.F1sup:	move	d6,d7	;determinant
	eor	d3,d7
	bmi.s	.Pcalcul
	bra.s	.Show
.F1inf:	move	d6,d7
	eor	d3,d7
	bmi.s	Hidefacette
.Pcalcul:	MULS	d4,d5
	MULS	d3,d6
	add.l	d5,d6
	bmi.s	Hidefacette
.Show:	move.l	a2,a5
	moveq	#3,d6
	lea	Segments(pc),a4
	move.l	a4,a6
	movem.l	d0/d1/d2,(a4)
	lea	12(a4),a4

	rept	4
	move	(a5)+,d0
	bmi.s	.Frpoint
	move.l	0(a1,d0),d1	;26
	swap	d1
	move.l	d1,(a4)+
	addq	#1,d6
	endr

	move	(a5)+,d0
	bmi.s	.Frpoint
	move.l	0(a1,d0),d1
	swap	d1
	move.l	d1,(a4)
	addq	#1,d6

.Frpoint:	lea	10(a2),a2
	move	(a2)+,d7
	move.l	a2,-(a7)
	jsr	Polygone(pc)
	move.l	(a7)+,a2
	move.l	(a2)+,d0
	bgt.s	Sousobjdraw
	move	(a2)+,d0
	bpl	Rfacette2
Ffacettes:	rts
		;#] Vertices handling:
		;#[ Child vertices:
Sousobjdraw:	move.l	a2,-(a7)
	move.l	d0,a2

	lea	Project2(pc),a1
	jsr	Calcobj(pc)

	move	(a2)+,d0
	blt.s	.End_child_object

.Child_object:	lea	Segments(pc),a4
	move.l	a4,a6
	lea	Project2(pc),a1

	move.l	0(a1,d0),(a4)+
	rept	2
	move	(a2)+,d0
	move.l	0(a1,d0),(a4)+
	endr
	moveq	#3,d6

	move.l	a2,a3
	rept	4
	move	(a3)+,d0
	bmi.s	.No_child_object
	move.l	0(a1,d0),(a4)+
	addq	#1,d6
	endr

	move	(a3),d0
	bmi.s	.End_child_object
	move.l	0(a1,d0),(a4)+
	addq	#1,d6
.No_child_object:
	lea	10(a2),a2
	move	(a2)+,d7
	move.l	a2,-(a7)
	jsr	Polygone(pc)
	move.l	(a7)+,a2
	move	(a2)+,d0
	bpl.s	.Child_object
.End_child_object:
	move.l	(a7)+,a2
	move	(a2)+,d0
	bge	Rfacette2
	rts
		;#] Child vertices:
		;#[ Anti-Vertices:
Antifacette:	rts
		;#] Anti-Vertices:
	 ;#] Draw Object:
	 ;#[ MAD MAX Music:
	IFNE	MUSIC

Set_music:	LEA	la2e,A0
	moveq	#MUS_NB,d0
	bsr.s	Initmus
	rts


Voicefin:	dc.w	0
Count:	dc.l	0
Endvoice:	dc.l	0

	rsreset

Off22 = 0	;rs.l	1	;ptr courant dans pattern
Off0 = 4	;rs.l	1	;ptr base patterns
Off34 = 8	;rs.l	1	;ptr fin musique

Off4 = 12	;rs.w	1	;ptr patterns (.W au lieu de .L)
Offa = 14	;rs.l	1	;ptr base modulation volume
Offe = 18	;rs.w	1	;ptr modulation volume (.W au lieu de .L)
Off12 = 20	;rs.l	1	;ptr base modulation fr‚quence
Off30 = 24	;rs.w	1	;ptr modulation fr‚quence (.W au lieu de .L)

Off38 = 26	;rs.l	1	;incr‚ment pour crescendo

Off8 = 30	;rs.b	1
Off9 = 31	;rs.b	1

Off16 = 32	;rs.b	1
Off17 = 33	;rs.b	1
Off18 = 34	;rs.b	1
Off19 = 35	;rs.b	1
Off1a = 36	;rs.b	1
Off1b = 37	;rs.b	1
Off1c = 38	;rs.b	1
Off1d = 39	;rs.b	1
Off1e = 40	;rs.b	1
Off1f = 41	;rs.b	1
Off21 = 42	;rs.b	1

Off26 = 43	;rs.b	1
Off27 = 44	;rs.b	1
Off28 = 45	;rs.b	1	;15-volume sonore de la voix
Off2a = 46	;rs.b	1	;0,1 ou 2=type de son
Off2b = 47	;rs.b	1
Off2c = 48	;rs.b	1
Off2d = 49	;rs.b	1	;volume sonore calcul‚
Off2e = 50	;rs.b	1
Off3c = 52	;EQU	(__RS+1)&-2

;
; init musique
;
; entr‚e :
;	A0=pointe sur le texte 'COSO'
;	D0=num‚ro de la musique … jouer
;

Initmus:	tst	d0	;musique=0 -> cut mus
	beq	lca
	subq	#1,d0

	lea	PSG_reg(pc),a6
	move.l	a0,l934-PSG_reg(a6)
	move.l	4(a0),a1
	add.l	a0,a1
	move.l	a1,l938-PSG_reg(a6)
	move.l	8(a0),a1
	add.l	a0,a1
	move.l	a1,l93c-PSG_reg(a6)
	move.l	$c(a0),a1
	add.l	a0,a1
	move.l	a1,l91a-PSG_reg(a6)
	move.l	$10(a0),a1
	add.l	a0,a1
	move.l	a1,l916-PSG_reg(a6)
	move.l	$14(a0),a1
	add.l	a0,a1
	move.l	a1,Endvoice
	add	d0,d0
	move	d0,d1
	add	d0,d0
	add	d1,d0
	add	d0,a1
	moveq	#$c,d7
	mulu	(a1)+,d7	;premier pattern
	move	(a1)+,d6
	addq	#1,d6
	mulu	#$c,d6	;dernier pattern
	move	(a1)+,d0
	move.b	d0,l810-PSG_reg(a6)

	moveq	#0,d0
	lea	Voice0(pc),a0
	lea	l7c6(pc),a1
l658:	move.l	a1,Offa(a0)
	clr	Offe(a0)
	clr.b	Off2d(a0)
	clr.b	Off8(a0)
	clr.b	Off9(a0)
	move.l	a1,Off12(a0)
	clr	Off30(a0)
	move.b	#1,Off17(a0)
	move.b	#1,Off18(a0)
	clr.b	Off19(a0)
	clr.b	Off1a(a0)
	clr.b	Off1b(a0)
	clr.b	Off1c(a0)
	clr.b	Off1d(a0)
	clr.b	Off1e(a0)
	clr.b	Off1f(a0)
	move.l	d0,d3
	move.b	d3,Off21(a0)
	add	d3,d3
	add	d3,d3
	move.l	l916(pc),d1
	add.l	d7,d1
	add.l	d3,d1
	move.l	d1,Off0(a0)
	move.l	d1,a3
	move.l	l916(pc),d1
	add.l	d6,d1
	add.l	d3,d1
	move.l	d1,Off34(a0)
	move	#$c,Off4(a0)
	moveq	#0,d1
	move.b	(a3)+,d1
	add	d1,d1
	move.l	l91a(pc),a4
	move	(a4,d1),a4
	add.l	l934(pc),a4
	move.l	a4,(a0)
	clr.b	Off26(a0)
	clr.b	Off27(a0)
	move.b	#2,Off2a(a0)
	move.b	(a3)+,Off2c(a0)
	clr.b	Off2b(a0)
	move.b	(a3)+,Off16(a0)
	moveq	#$10,d1
	add.b	(a3),d1
	bcs.s	l712
	moveq	#0,d1
l712:
	move.b	d1,Off28(a0)
	clr.l	Off38(a0)
	lea	Off3c(a0),a0
	addq	#1,d0
	cmp	#3,d0
	bcs	l658
	move.b	#1,l80e-PSG_reg(a6)
	clr	l812-PSG_reg(a6)

	clr.b	$22(a6)
	clr.b	$26(a6)
	clr.b	$2a(a6)
	movem.l	$1c(a6),d0-d3
	movem.l	d0-d3,$ffff8800.w
	rts
lca:	lea	l812(pc),a0
	st	(a0)

Play_music:
l12c:	lea	PSG_reg(pc),a6
	tst.b	l812-PSG_reg(a6)
	beq.s	l160
	tas	l813-PSG_reg(a6)
	bne.s	l15e
	clr.b	$22(a6)
	clr.b	$26(a6)
	clr.b	$2a(a6)
	movem.l	$1c(a6),d0-d3
	movem.l	d0-d3,$ffff8800.w
l15e:	rts
l160:	subq.b	#1,l80e-PSG_reg(a6)
	bne.s	l180
	move.b	l810-PSG_reg(a6),l80e-PSG_reg(a6)
	moveq	#0,d5
	lea	Voice0(pc),a0
	bsr.s	l25c
	lea	Voice1(pc),a0
	bsr.s	l25c
	lea	Voice2(pc),a0
	bsr.s	l25c
l180:	move.b	#$c0,$1e(a6)
	lea	Voice0(pc),a0
	bsr	l39a
	move	d0,6(a6)
	move.b	d0,2(a6)
	move.b	d1,$22(a6)
	lea	Voice1(pc),a0
	bsr	l39a
	move	d0,$e(a6)
	move.b	d0,$a(a6)
	move.b	d1,$26(a6)
	lea	Voice2(pc),a0
	bsr	l39a
	move	d0,$16(a6)
	move.b	d0,$12(a6)
	move.b	d1,$2a(a6)
	movem.l	(a6),d0-d7/a0-a2
	movem.l	d0-d7/a0-a2,$ffff8800.w
l25a:	rts

;
; calcule nouvelle note
;

l25c:	subq.b	#1,Off26(a0)
	bpl.s	l25a
	move.b	Off27(a0),Off26(a0)
	move.l	(a0),a1
l26c:	move.b	(a1)+,d0
	cmp.b	#$ff,d0
	bne.s	l2e2
	move.l	Off0(a0),a1
	add	Off4(a0),a1
	cmp.l	Off34(a0),a1
	bcs.s	l288
	addq	#1,Voicefin
	move	d5,Off4(a0)
	move.l	Off0(a0),a1
l288:	moveq	#0,d1
	move.b	(a1)+,d1
	move.b	(a1)+,Off2c(a0)
	move.b	(a1)+,Off16(a0)
	moveq	#$10,d0
	add.b	(a1)+,d0
	bcc.s	l2b4
	move.b	d0,Off28(a0)	;f0-ff=volume … soustraire
	bra.s	l2c4
l2b4:	add.b	#$10,d0
	bcc.s	l2c4
	move.b	d0,l810-PSG_reg(a6)	;e0-ef=vitesse
l2c4:	add	d1,d1
	move.l	l91a(pc),a1
	move	(a1,d1),a1
	add.l	l934(pc),a1
	move.l	a1,(a0)
	add	#$c,Off4(a0)
	bra.s	l26c
l2e2:	cmp.b	#$fe,d0
	bne.s	l2f4
	move.b	(a1)+,d0
	move.b	d0,Off27(a0)
	move.b	d0,Off26(a0)
	bra.s	l26c
l2f4:	cmp.b	#$fd,d0
	bne.s	l308
	move.b	(a1)+,d0
	move.b	d0,Off27(a0)
	move.b	d0,Off26(a0)
	move.l	a1,(a0)
	rts
l308:	move.b	d0,Off8(a0)
	move.b	(a1)+,d1
	move.b	d1,Off9(a0)
	and	#$e0,d1	;d1=Off9&$e0
	beq.s	l31c
	move.b	(a1)+,Off1f(a0)
l31c:	move.l	a1,(a0)
	move.l	d5,Off38(a0)
	tst.b	d0
	bmi.s	l398
	move.b	Off9(a0),d0
	eor.b	d0,d1	;d1=Off9&$1f
	add.b	Off16(a0),d1

	move.l	l93c(pc),a1
	add	d1,d1
	move	(a1,d1),a1
	add.l	l934(pc),a1
	move	d5,Offe(a0)
	move.b	(a1)+,d1
	move.b	d1,Off17(a0)
	move.b	d1,Off18(a0)
	moveq	#0,d1
	move.b	(a1)+,d1
	move.b	(a1)+,Off1b(a0)
;	move.b	#$40,Off2e(a0)
	clr.b	Off2e(a0)
	move.b	(a1)+,d2
	move.b	d2,Off1c(a0)
	move.b	d2,Off1d(a0)
	move.b	(a1)+,Off1e(a0)
	move.l	a1,Offa(a0)
	add.b	d0,d0	;test bit 6
	bpl.s	l37a
	move.b	Off1f(a0),d1
l37a:	move.l	l938(pc),a1
	add	d1,d1
	move	(a1,d1),a1
	add.l	l934(pc),a1
	move.l	a1,Off12(a0)
	move	d5,Off30(a0)
	move.b	d5,Off1a(a0)
	move.b	d5,Off19(a0)
l398:	rts

;
; calcul de la note … jouer
;

l39a:	moveq	#0,d7
	move	Off30(a0),d6
l3a0:	tst.b	Off1a(a0)
	beq.s	l3ae
	subq.b	#1,Off1a(a0)
	bra	l4c01
l3ae:	move.l	Off12(a0),a1
	add	d6,a1
l3b6:	move.b	(a1)+,d0
	cmp.b	#$e1,d0
	beq	l4c01
	cmp.b	#$e0,d0
	bne.s	l3d8
	moveq	#$3f,d6
	and.b	(a1),d6
	move.l	Off12(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
l3d8:	cmp.b	#$e2,d0
	bne.s	l3ee
	clr	Offe(a0)
	move.b	#1,Off17(a0)
	addq	#1,d6
	bra.s	l3b6
l3ee:	cmp.b	#$e9,d0
	bne.s	l422
	move.b	#$b,$ffff8800.w
	move.b	(a1)+,$ffff8802.w
	move.l	#$0c0c0000,$ffff8800.w
	move.l	#$0d0d0a0a,$ffff8800.w
	addq	#2,d6
	bra.s	l3b6
l422:	cmp.b	#$e7,d0
	bne.s	l44a
	clr	d0
	move.b	(a1),d0
	add	d0,d0
	move.l	l938(pc),a1
	move	(a1,d0),a1
	add.l	l934(pc),a1
	move.l	a1,Off12(a0)
	clr	d6
	bra.s	l3b6
l44a:	cmp.b	#$e8,d0
	bne.s	l45e
	move.b	(a1)+,Off1a(a0)
	addq	#2,d6
	bra	l3a0
l45e:	cmp.b	#$e4,d0
	bne.s	l474
	clr.b	Off2a(a0)
	move.b	(a1)+,d7
	addq	#2,d6
	bra.s	l4ae
l474:	cmp.b	#$e5,d0
	bne.s	l488
	move.b	#1,Off2a(a0)
	addq	#1,d6
	bra	l3b6
l488:	cmp.b	#$e6,d0
	bne.s	l49a
	move.b	#2,Off2a(a0)
	addq	#1,d6
	bra.s	l4ae
l49a:	cmp.b	#$e3,d0
	bne.s	l4b0
	addq	#3,d6
	move.b	(a1)+,Off1b(a0)
	move.b	(a1)+,Off1c(a0)
l4ae:	move.b	(a1)+,d0
l4b0:
	move.b	d0,Off2b(a0)
	addq	#1,d6
l4c01:	move	d6,Off30(a0)

	;modulation volume
	move	Offe(a0),d6
l4c0:	tst.b	Off19(a0)
	beq.s	l4cc
	subq.b	#1,Off19(a0)
	bra.s	l51a
l4cc:	subq.b	#1,Off17(a0)
	bne.s	l51a
	move.b	Off18(a0),Off17(a0)

	move.l	Offa(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
	cmp.b	#$e0,d0
	bne.s	l512
	moveq	#$3f,d6
	and.b	(a1),d6
	subq	#5,d6
	move.l	Offa(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
l512:
	cmp.b	#$e8,d0
	bne.s	l4f4
	addq	#2,d6
	move.b	(a1)+,Off19(a0)
	bra.s	l4c0
l4f4:	cmp.b	#$e1,d0
	beq.s	l51a
	move.b	d0,Off2d(a0)
	addq	#1,d6
l51a:	move	d6,Offe(a0)

	clr	d5
	move.b	Off2b(a0),d5
	bmi.s	l528
	add.b	Off8(a0),d5
	add.b	Off2c(a0),d5
l528:
	lea	l94e(pc),a1
	add.b	d5,d5
	move	(a1,d5),d0

	move.b	Off2a(a0),d2	;0,1 ou 2
	beq.s	l57e

	move.b	Off21(a0),d3
	addq	#3,d3

	subq.b	#1,d2
	bne.s	l578
	subq	#3,d3
	move.b	Off2b(a0),d7
	bclr	#7,d7
	bne.s	l578
	add.b	Off8(a0),d7
l578:	bset	d3,$1e(a6)
l57e:	tst.b	d7
	beq.s	l594
	not.b	d7
	and.b	#$1f,d7
	move.b	d7,$1a(a6)
l594:	move.b	Off2e(a0),d6
	tst.b	Off1e(a0)
	beq.s	l5a4
	subq.b	#1,Off1e(a0)
	bra.s	l5fa
l5a4:	clr	d4
	move.b	Off1c(a0),d4
	clr	d1
	move.b	Off1d(a0),d1
	tst.b	d6
	bmi.s	l5ce
	sub.b	Off1b(a0),d1
	bcc.s	l5dc
	tas	d6
	moveq	#0,d1
	bra.s	l5dc
l5ce:	add.b	Off1b(a0),d1
	add.b	d4,d4
	cmp.b	d4,d1
	bcs.s	l5da
	bclr	#7,d6
	move.b	d4,d1
l5da:	lsr.b	#1,d4
l5dc:	move.b	d1,Off1d(a0)
l5e0:	sub	d4,d1
	add.b	#$a0,d5
	bcs.s	l5f8
	moveq	#$18,d4
	add	d1,d1
	add.b	d4,d5
	bcs.s	l5f8
	add	d1,d1
	add.b	d4,d5
	bcs.s	l5f8
	add	d1,d1
	add.b	d4,d5
	bcs.s	l5f8
	add	d1,d1
l5f8:	add	d1,d0
l5fa:	eor.b	#1,d6
	move.b	d6,Off2e(a0)
	btst	#5,Off9(a0)
	beq.s	l628
	moveq	#0,d1
	move.b	Off1f(a0),d1
	ext	d1
	swap	d1
	lsr.l	#4,d1	;asr.l #4,d1 corrige bug ???
	add.l	d1,Off38(a0)
	sub	Off38(a0),d0
l628:	move.b	Off2d(a0),d1
	sub.b	Off28(a0),d1
	bpl.s	l634
	moveq	#0,d1
l634:	rts

l94e:	dc.w	$eee,$e17,$d4d,$c8e
	dc.w	$bd9,$b2f,$a8e,$9f7
	dc.w	$967,$8e0,$861,$7e8
	dc.w	$777,$70b,$6a6,$647
	dc.w	$5ec,$597,$547,$4fb
	dc.w	$4b3,$470,$430,$3f4
	dc.w	$3bb,$385,$353,$323
	dc.w	$2f6,$2cb,$2a3,$27d
	dc.w	$259,$238,$218,$1fa
	dc.w	$1dd,$1c2,$1a9,$191
	dc.w	$17b,$165,$151,$13e
	dc.w	$12c,$11c,$10c,$fd
	dc.w	$ee,$e1,$d4,$c8
	dc.w	$bd,$b2,$a8,$9f
	dc.w	$96,$8e,$86,$7e
	dc.w	$77,$70,$6a,$64
	dc.w	$5e,$59,$54,$4f
	dc.w	$4b,$47,$43,$3f
	dc.w	$3b,$38,$35,$32
	dc.w	$2f,$2c,$2a,$27
	dc.w	$25,$23,$21,$1f
	dc.w	$1d,$1c,$1a,$19
	dc.w	$17,$16,$15,$13
	dc.w	$12,$11,$10,$f
l7c6:	dc.b	1,0,0,0,0,0,0,$e1
PSG_reg:	dc.w	0,0,$101,0
	dc.w	$202,0,$303,0
	dc.w	$404,0,$505,0
	dc.w	$606,0,$707,$ffff
	dc.w	$808,0,$909,0
	dc.w	$a0a,0

l80e:	dc.b	4
l810:	dc.b	4
l812:	dc.b	-1
l813:	dc.b	0

Voice0:	ds.b	Off3c
Voice1:	ds.b	Off3c
Voice2:	ds.b	Off3c
l916:	dc.l	0
l91a:	dc.l	0
l934:	dc.l	0
l938:	dc.l	0
l93c:	dc.l	0
la2e:	incbin	d:\src\demos\musics\m_coder\tera61.img
	ENDC

	IFNE	PCMSAMPLE

	;Utilisation du processeur sonore PCM du STE
PCM_STARTA	EQU	$FFFF8903
PCM_STARTB	EQU	$FFFF8905
PCM_STARTC	EQU	$FFFF8907

PCM_ENDA	EQU	$FFFF890F
PCM_ENDB	EQU	$FFFF8911
PCM_ENDC	EQU	$FFFF8913


KHZ_6	EQU	0
KHZ_12	EQU	1
KHZ_25	EQU	2
KHZ_50	EQU	3

PCMMONO	EQU	$A0

PCM_FREQUENCY	EQU	$FFFF8920
PCM_MODE	EQU	$FFFF8900
PCM_VOLUME	EQU	$FFFF8922

;-------- Initialisation du PCM ----------------------------
;
InitPCM:	lea	Sample(PC),A0
	lea	Fsample,A1
	jsr	ConvertPCM(PC)

	move.l	#Sample,D0	;init adresse de depart
	swap	D0
	move.b	D0,PCM_STARTA
	swap	D0
	move.b	D0,PCM_STARTC
	lsr	#8,D0
	move.b	D0,PCM_STARTB

	move.l	#Fsample,D0	;init adresse de fin
	swap	D0
	move.b	D0,PCM_ENDA
	swap	D0
	move.b	D0,PCM_ENDC
	lsr	#8,D0
	move.b	D0,PCM_ENDB
	move.w	#$A1,PCM_FREQUENCY
	move.w	#$3,PCM_MODE
	rts

;------- Convertion au format PCM 8 bits sign‚s -----------
;
;	A0 = adresse de depart
;	D0 = longueur de l'‚chantillon

ConvertPCM:
.Crm:	sub.b	#128,(A0)+
	cmp.l	A0,A1
	bne.s	.Crm
	rts

	dc.l	0
Sample:	incbin	tout.spl
Fsample:
	EVEN


	ENDC
	 ;#] MAD MAX Music:
	 ;#[ CLS Header:
Ffastcls:	move.l	Work_screen(pc),a6
	lea	160*NB_LINES(a6),a6
	moveq	#0,d0
	moveq	#0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	move.l	d1,d7
	move.l	d0,a0
	move.l	d1,a1
	move.l	d0,a2
	move.l	d1,a3
	move.l	d0,a4
	move.l	d1,a5
	bra	Bfastcls
	 ;#] CLS Header:
	 ;#[ DATA Section:
		DATA
		;#[ Trigonometric Tables:
Sincos4:	incbin	Sincos4.bin
Sincos8:	incbin	Sincos8.bin
		;#] Trigonometric Tables:

		;#[ Objects Definitions:
RED	equ	0
GREEN	equ	5
BLUE	equ	10
FLASH	equ	15

FACE	MACRO
	dc.w	\1*4,\2*4,\3*4,\4*4,\5*4,\6*4,\7*4,\8*4
	ENDM
COLOR	MACRO
	dc.w	\1*4
	ENDM
COLOR_TRAME	MACRO
	dc.w	\1*64+\2*4+$4000
	ENDM
MONO	MACRO
	dc.w	\1*2+$8000
	ENDM
MONO_TRAME	MACRO
	dc.w	\1*2+$c000
	ENDM
		;#] Objects Definitions:
		;#[ Object Table:
STRUCT_SIZE	equ	22
Objects:	dc.l	A_letter		;Pointer
	dc.w	4*4,8*4,12*4,80	;dx,dy,dz,d(dist)
	dc.w	4*4,8*4,12*4,80	;x,y,z,dist
	dc.w	1000		;t

	dc.l	Cone
	dc.w	4*4,8*4,12*4,20
	dc.w	4*4,8*4,12*4,20
	dc.w	1000

	dc.l	Squares
	dc.w	4*4,8*4,12*4,40
	dc.w	4*4,8*4,12*4,40
	dc.w	1000

	dc.l	Tetraedron
	dc.w	4*4,8*4,12*4,30
	dc.w	4*4,8*4,12*4,30
	dc.w	1000

	dc.l	Space_ship
	dc.w	4*4,8*4,12*4,30
	dc.w	4*4,8*4,12*4,30
	dc.w	1000

	dc.l	Double_cubus
	dc.w	4*4,8*4,12*4,30
	dc.w	4*4,8*4,12*4,30
	dc.w	1000

	dc.l	Icosaedron
	dc.w	4*4,8*4,12*4,60
	dc.w	4*4,8*4,12*4,60
	dc.w	1000

	dc.l	Torus
	dc.w	4*4,8*4,12*4,30
	dc.w	4*4,8*4,12*4,30
	dc.w	1000

	dc.l	Cubus
	dc.w	4*4,8*4,12*4,50
	dc.w	4*4,8*4,12*4,50
	dc.w	1000

	dc.l	0
		;#] Object Table:

		;#[ Space Ship:
Space_ship:	dc.l	P_space_ship
	dc.l	0
	dc.l	Space_ship

P_space_ship:	dc.w	16
	dc.w	50,-30,0	;aile droite
	dc.w	-50,-50,-40
	dc.w	-50,-10,40
	dc.w	50,30,0	;aile gauche
	dc.w	-50,50,-40
	dc.w	-50,10,40
	dc.w	-50,-30,0	;reacteur droit
	dc.w	0,-30,0
	dc.w	-50,-15,10
	dc.w	0,-15,10
	dc.w	-50,0,-10	;dessous cockpit
	dc.w	0,0,-10
	dc.w	-50,30,0	;reacteur gauche
	dc.w	0,30,0
	dc.w	-50,15,10
	dc.w	0,15,10
	dc.w	70,0,0	;pointe
	dc.l	F_space_ship

F_space_ship:	;bouclier droit interne

	FACE	0,1,2,-1,-1,-1,-1,-1
	MONO_TRAME	1
	dc.l	0

	;bouclier gauche interne

	FACE	5,4,3,-1,-1,-1,-1,-1
	MONO_TRAME	1
	dc.l	0

	;entree d'air
	FACE	9,7,11,-1,-1,-1,-1,-1
	COLOR	(GREEN+0)
	dc.l	0
	FACE	13,15,11,-1,-1,-1,-1,-1
	COLOR	(GREEN+0)
	dc.l	0

	;pointe
	FACE	9,11,16,-1,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	15,16,11,-1,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0

	FACE	15,9,16,-1,-1,-1,-1,-1
	COLOR	(GREEN+4)
	dc.l	0

	;reacteur droit
	FACE	9,8,6,7,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0
	FACE	11,7,6,10,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0

	;reacteur gauche
	FACE	15,13,12,14,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0
	FACE	12,13,11,10,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0

	;dessus
	FACE	15,14,8,9,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0

	;arriere
	FACE	10,6,8,14,12,-1,-1,-1
	COLOR	FLASH
	dc.l	0

	;bouclier droit externe
	FACE	2,1,0,-1,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0

	;bouclier gauche externe
	FACE	3,4,5,-1,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0

	dc.w	-1
		;#] Space Ship:
		;#[ Cubus:
Cubus:	dc.l	P_cubus
	dc.l	0
	dc.l	Cubus

P_cubus:	dc.w	 7

	dc.w	 40,-40,-40
	dc.w	 40, 40,-40
	dc.w	-40, 40,-40
	dc.w	-40,-40,-40
	dc.w	 40,-40, 40
	dc.w	 40, 40, 40
	dc.w	-40, 40, 40
	dc.w	-40,-40, 40

	dc.l	F_cubus

F_cubus:	;faces externes

	FACE	1,0,3,2,-1,-1,-1,-1
	MONO	1
	dc.l	0

	FACE	5,6,7,4,-1,-1,-1,-1
	MONO	0
	dc.l	0

	FACE	5,4,0,1,-1,-1,-1,-1
	MONO_TRAME	1
	dc.l	0

	FACE	0,4,7,3,-1,-1,-1,-1
	MONO	1
	dc.l	0

	FACE	3,7,6,2,-1,-1,-1,-1
	MONO_TRAME	0
	dc.l	0

	FACE	2,6,5,1,-1,-1,-1,-1
	MONO	0
	dc.l	0

	dc.w	-1
		;#] Cubus:
		;#[ Torus:
Torus:	dc.l	P_torus
	dc.l	0
	dc.l	Torus

P_torus:	dc.w	24-1

	dc.w	-10,20,5
	dc.w	10,20,5
	dc.w	20,10,5
	dc.w	20,-10,5
	dc.w	10,-20,5
	dc.w	-10,-20,5
	dc.w	-20,-10,5
	dc.w	-20,10,5

	dc.w	-15,35,0
	dc.w	15,35,0
	dc.w	35,15,0
	dc.w	35,-15,0
	dc.w	15,-35,0
	dc.w	-15,-35,0
	dc.w	-35,-15,0
	dc.w	-35,15,0

	dc.w	-10,20,-5
	dc.w	10,20,-5
	dc.w	20,10,-5
	dc.w	20,-10,-5
	dc.w	10,-20,-5
	dc.w	-10,-20,-5
	dc.w	-20,-10,-5
	dc.w	-20,10,-5
	dc.l	F_torus

F_torus:	;faces internes

	FACE	16,0,7,23,-1,-1,-1,-1
	COLOR	(BLUE+4)
	dc.l	0
	FACE	17,1,0,16,-1,-1,-1,-1
	COLOR	(GREEN+4)
	dc.l	0
	FACE	18,2,1,17,-1,-1,-1,-1
	COLOR	(BLUE+4)
	dc.l	0
	FACE	19,3,2,18,-1,-1,-1,-1
	COLOR	(GREEN+4)
	dc.l	0
	FACE	20,4,3,19,-1,-1,-1,-1
	COLOR	(BLUE+4)
	dc.l	0
	FACE	21,5,4,20,-1,-1,-1,-1
	COLOR	(GREEN+4)
	dc.l	0
	FACE	22,6,5,21,-1,-1,-1,-1
	COLOR	(BLUE+4)
	dc.l	0
	FACE	23,7,6,22,-1,-1,-1,-1
	COLOR	(GREEN+4)
	dc.l	0

	;faces dessus

	FACE	0,1,09,08,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	1,2,10,09,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	2,3,11,10,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	3,4,12,11,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	4,5,13,12,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	5,6,14,13,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	6,7,15,14,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	7,0,08,15,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0

	;faces dessous
	FACE	09,17,16,08,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0
	FACE	10,18,17,09,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	11,19,18,10,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0
	FACE	12,20,19,11,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	13,21,20,12,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0
	FACE	14,22,21,13,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	15,23,22,14,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0
	FACE	08,16,23,15,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0

	dc.w	-1
		;#] Torus:
		;#[ Icosaedron:

Icosaedron:	dc.l	P_icosaedron
	dc.l	0
	dc.l	Icosaedron

P_icosaedron:	dc.w	11

	dc.w	89,0,44
	dc.w	27,85,44
	dc.w	-72,52,44
	dc.w	-72,-52,44
	dc.w	27,-85,44
	dc.w	0,0,100
	dc.w	0,0,-100
	dc.w	72,52,-44
	dc.w	-27,85,-44
	dc.w	-89,00,-44
	dc.w	-27,-85,-44
	dc.w	72,-52,-44

	dc.l	F_icosaedron

F_icosaedron:
	FACE	0,1,5,-1,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0
	FACE	1,2,5,-1,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0
	FACE	2,3,5,-1,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	3,4,5,-1,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	4,0,5,-1,-1,-1,-1,-1
	COLOR	(BLUE+4)
	dc.l	0

	FACE	11,0,4,-1,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	11,7,0,-1,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	7,1,0,-1,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	8,1,7,-1,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	8,2,1,-1,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	8,9,2,-1,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	9,3,2,-1,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	9,10,3,-1,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	10,4,3,-1,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	10,11,4,-1,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0

	FACE	6,7,11,-1,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0
	FACE	6,8,7,-1,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0
	FACE	6,9,8,-1,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	6,10,9,-1,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	6,11,10,-1,-1,-1,-1,-1
	COLOR	(BLUE+4)
	dc.l	0

	dc.w	-1
		;#] Icosaedron:
		;#[ Double Cubus:
Double_cubus:	dc.l	P_double_cubus
	dc.l	0
	dc.l	Double_cubus

P_double_cubus:dc.w	15

	dc.w	-40,40,15
	dc.w	-10,40,15
	dc.w	-10,10,15
	dc.w	-40,10,15
	dc.w	-40,40,-15
	dc.w	-10,40,-15
	dc.w	-10,10,-15
	dc.w	-40,10,-15

	dc.w	10,40,15
	dc.w	40,40,15
	dc.w	40,10,15
	dc.w	10,10,15
	dc.w	10,40,-15
	dc.w	40,40,-15
	dc.w	40,10,-15
	dc.w	10,10,-15

	dc.l	F_double_cubus

F_double_cubus:
	FACE	1,2,6,5,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	1,5,4,0,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0
	FACE	3,2,1,0,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	0,4,7,3,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	3,7,6,2,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0
	FACE	4,5,6,7,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0

	FACE	8,12,15,11,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0
	FACE	11,10,9,8,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	9,13,12,8,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	11,15,14,10,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	12,13,14,15,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	9,10,14,13,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0

	dc.w	-1
		;#] Double Cubus:
		;#[ Tetraedron:
Tetraedron:	dc.l	P_tetraedron
	dc.l	0
	dc.l	Tetraedron

P_tetraedron:	dc.w	12

	dc.w	-30,30,0
	dc.w	30,30,0
	dc.w	30,-30,0
	dc.w	-30,-30,0
	dc.w	-20,20,20
	dc.w	20,20,20
	dc.w	20,-20,20
	dc.w	-20,-20,20
	dc.w	-15,15,30
	dc.w	15,15,30
	dc.w	15,-15,30
	dc.w	-15,-15,30
	dc.w	0,0,60
	dc.l	F_tetraedron

F_tetraedron:
	FACE	7,6,5,4,-1,-1,-1,-1
	COLOR	(GREEN+4)
	dc.l	0
	FACE	8,9,10,11,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	0,1,2,3,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0

	FACE	12,9,8,-1,-1,-1,-1,-1
	COLOR	(BLUE+4)
	dc.l	0
	FACE	5,1,0,4,-1,-1,-1,-1
	COLOR	(BLUE+4)
	dc.l	0

	FACE	12,10,9,-1,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	6,2,1,5,-1,-1,-1,-1
	COLOR	(BLUE+3)

	dc.l	0
	FACE	12,11,10,-1,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	7,3,2,6,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0

	FACE	12,8,11,-1,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0
	FACE	4,0,3,7,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0

	dc.w	-1
		;#] Tetraedron:
		;#[ Squares:
Squares:	dc.l	P_squares
	dc.l	0
	dc.l	Squares

P_squares:	dc.w	27

	dc.w	-10,10,-30
	dc.w	10,10,-30
	dc.w	10,-10,-30
	dc.w	-10,-10,-30

	dc.w	-20,20,-20
	dc.w	20,20,-20
	dc.w	20,-20,-20
	dc.w	-20,-20,-20

	dc.w	-30,30,-10
	dc.w	30,30,-10
	dc.w	30,-30,-10
	dc.w	-30,-30,-10

	dc.w	-40,40,0
	dc.w	40,40,0
	dc.w	40,-40,0
	dc.w	-40,-40,0

	dc.w	-30,30,10
	dc.w	30,30,10
	dc.w	30,-30,10
	dc.w	-30,-30,10

	dc.w	-20,20,20
	dc.w	20,20,20
	dc.w	20,-20,20
	dc.w	-20,-20,20

	dc.w	-10,10,30
	dc.w	10,10,30
	dc.w	10,-10,30
	dc.w	-10,-10,30

	dc.l	F_squares

F_squares:	FACE	3,2,1,0,-1,-1,-1,-1
	COLOR	(GREEN+0)
	dc.l	0
	FACE	7,6,5,4,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	11,10,9,8,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0
	FACE	15,14,13,12,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	19,18,17,16,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0
	FACE	23,22,21,20,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	27,26,25,24,-1,-1,-1,-1
	COLOR	(GREEN+0)
	dc.l	0

	;faces autre cote

	FACE	24,25,26,27,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0
	FACE	20,21,22,23,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0
	FACE	16,17,18,19,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	12,13,14,15,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	8,9,10,11,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	4,5,6,7,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0
	FACE	0,1,2,3,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0

	dc.w	-1
		;#] Squares:
		;#[ Cone:
Cone:	dc.l	P_cone
	dc.l	0
	dc.l	Cone

P_cone:	dc.w	8
	dc.w	-10,20,0
	dc.w	10,20,0
	dc.w	20,10,0
	dc.w	20,-10,0
	dc.w	10,-20,0
	dc.w	-10,-20,0
	dc.w	-20,-10,0
	dc.w	-20,10,0
	dc.w	0,0,30

	dc.l	F_cone

F_cone:	FACE	0,1,8,-1,-1,-1,-1,-1
	COLOR	(GREEN+1)
	dc.l	0
	FACE	2,3,8,-1,-1,-1,-1,-1
	COLOR	(GREEN+2)
	dc.l	0
	FACE	4,5,8,-1,-1,-1,-1,-1
	COLOR	(GREEN+3)
	dc.l	0
	FACE	6,7,8,-1,-1,-1,-1,-1
	COLOR	(GREEN+4)
	dc.l	0
	FACE	0,8,1,-1,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0
	FACE	2,8,3,-1,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	4,8,5,-1,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	6,8,7,-1,-1,-1,-1,-1
	COLOR	(BLUE+4)
	dc.l	0

	dc.w	-1
		;#] Cone:
		;#[ A Letter:
A_letter:	dc.l	P_a_letter
	dc.l	0
	dc.l	A_letter

P_a_letter:	dc.w	21
	dc.w	-32,80,-32
	dc.w	-32,80,32
	dc.w	32,80,-32
	dc.w	32,80,32
	dc.w	112,-80,-32
	dc.w	112,-80,32
	dc.w	48,-80,-32
	dc.w	48,-80,32
	dc.w	32,-48,-32
	dc.w	32,-48,32
	dc.w	-32,-48,-32
	dc.w	-32,-48,32
	dc.w	-48,-80,-32
	dc.w	-48,-80,32
	dc.w	-112,-80,-32
	dc.w	-112,-80,32
	dc.w	-16,-16,-32
	dc.w	-16,-16,32
	dc.w	16,-16,-32
	dc.w	16,-16,32
	dc.w	0,16,-32
	dc.w	0,16,32

	dc.l	F_a_letter

F_a_letter:	;cote fenetre gauche
	FACE	19,21,20,18,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0

	;cote fenetre droit
	FACE	21,17,16,20,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0

	;dessus
	FACE	17,19,18,16,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0

	;dessus traverse
	FACE	1,3,2,0,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0

	;dessous traverse
	FACE	9,11,10,8,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0

	;cote exterieur gauche
	FACE	3,5,4,2,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0

	;cote interieur gauche
	FACE	7,9,8,6,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0

	;cote interieur droit
	FACE	11,13,12,10,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0

	;cote exterieur droit
	FACE	15,1,0,14,-1,-1,-1,-1
	COLOR	(BLUE+0)
	dc.l	0

	;dessous gauche
	FACE	5,7,6,4,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0

	;dessous droit
	FACE	13,15,14,12,-1,-1,-1,-1
	COLOR	(BLUE+1)
	dc.l	0

	;arriere
	FACE	16,18,8,10,-1,-1,-1,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	0,2,20,16,10,12,14,-1
	COLOR	(BLUE+2)
	dc.l	0
	FACE	2,4,6,8,18,20,-1,-1
	COLOR	(BLUE+2)
	dc.l	0


	;avant
	FACE	11,9,19,17,-1,-1,-1,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	1,15,13,11,17,21,3,-1
	COLOR	(BLUE+3)
	dc.l	0
	FACE	7,5,3,21,19,9,-1,-1
	COLOR	(BLUE+3)
	dc.l	0

	dc.w	-1
		;#] A Letter:

		;#[ Colors:
Palette:
.Red:	dc.w	$000,$400,$500,$600,$700
.Green:	dc.w	$332,$443,$554,$665,$776
.Blue:	dc.w	$233,$344,$455,$566,$677
.Flash:	dc.w	$777
		;#] Colors:
	 ;#] DATA Section:
	 ;#[ BSS Section:
		BSS
Obsx:		ds.w	1
Obsy:		ds.w	1
Obsz:		ds.w	1

Vrotx:		ds.w	1	;Consecutive
Vroty:		ds.w	1
Vrotz:		ds.w	1	;Consecutive
Vdist:		ds.w	1
Rotx:		ds.w	1	;Consecutive
Roty:		ds.w	1
Rotz:		ds.w	1	;Consecutive
Dist:		ds.w	1

Frame_counter:		ds.w	1
Vbl_counter:		ds.w	1
Cptwaiting:		ds.w	1
Nb_frames:		ds.w	1
Matrix:		ds.w	9

Current_object:	ds.l	1
Current_anim:		ds.l	1
Project:		ds.l	128
Project2:		ds.l	128
Segments:		ds.l	128

Sys_rez:		ds.w	1
Sys_vbl:		ds.l	1
Sys_mfp		ds.l	1
Sys_zero:		ds.l	1
Sys_screen:		ds.l	1
Sys_palette:		ds.w	16

Screen_list:		ds.l	NB_SCREEN-1
		LIST
Work_screen:		ds.l	1
Bfastcls:		ds.l	(40*NB_LINES/14)-(CLS_MOD>0)
		ds.w	1
		NOLIST
Rotate_table:		ds.w	$8000
Screen2:		ds.b	256+32000*(NB_SCREEN-1)

;----------- table de CLIPPING en x ---------------------
Llimit:		ds.l	CLIPSIZE*2
Tlimit:		ds.l	160*2
Mlimit:		ds.l	160*2
Rlimit:		ds.l	CLIPSIZE*2

Top_of_stack:		ds.l	1000
Mystack:
	 ;#] BSS Section:


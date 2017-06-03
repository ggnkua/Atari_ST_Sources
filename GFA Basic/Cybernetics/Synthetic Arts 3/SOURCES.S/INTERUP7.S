	output	e:\code\synthy.art\curent\fichiers.inl\inters2.inl
	
	opt 	o+

*-------------------------------------------------------------------------*
* - SYNTHETIC ARTS 3 -						- 1992 -  *
*									  *
*  Gestion souris & clavier avec gestion des types de touche 		  *
*  Routine Vbl (curseur-palette etendue)				  *
*  Gestion rasters							  *
*  Version inline							  *
*-------------------------------------------------------------------------*

;-------------------------------------------------------------------------;
; Renvoit :	posx      : position en X				  ;
;		posy      : position en Y				  ;
;		mouse_z	  : etat des boutons	0 : aucun 		  ;
;						1 : droit		  ;
;						2 : gauche		  ;
;						3 : les deux		  ;
;		scan_code : le scancode de la touche appuyee		  ;
;									  ;
; Parametres pris en compte :						  ;
;									  ;
;		flagx	  : validation des mouvements en x		  ;
;		flagy	  : validation des mouvements en y		  ;
;		sensx	  : sensibilite des mouvements en x		  ;
;		sensy	  : sensibilite des mouvements en y		  ;
;		clipping  : cx1 - cx2 - cy1 - cy2			  ;
;-------------------------------------------------------------------------;

	move.w	4(sp),d0
	
	move.l	sp,depadr
	
	cmp.w	#1,d0		* 1: Init
	bne.s	no1
	bsr.s	init
no1:	cmp.w	#2,d0		* 2: reinit 
	bne.s	no2
	bsr	reinit
no2:	cmp.w	#3,d0		* 3: Affmouse
	bne.s	no3		
	bsr	affmouse
no3:	cmp.w	#4,d0		* 4: Reaffiche le fond (pour hidecurs)
	bne.s	no4
	bsr	reafmouse
no4:
	move.l	depadr(pc),sp

	rts
		
error_clavier:
	moveq.l	#-96,d0
	and.b	$fffffc00.w,d0
	beq.s	endflush
	move.b	$fffffc02.w,d0
	bra.s	error_clavier
endflush:
	rts

		*     Reinits		
		*---------------------

init:	clr.l	-(sp)			* Superviseur
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,stack		

	move.w	#$2700,sr
	bsr.s	error_clavier
	move.l	$70.w,oldvbl
	move.l	$118.w,oldclv
	move.l	$120.w,oldtimerb
	move.l	#vbl,$70.w
	move.l	#new118,$118.w
	move.l	#timerb,$120.w
	move.b	$fffffa07.w,savtima
	move.b	$fffffa09.w,savtimb
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	bset.b	#0,$fffffa07.w
	bset.b	#6,$fffffa09.w
	btst.b	#7,savtimb
	beq.s	nodma
	bset.b	#7,$fffffa09.w
nodma:	bset.b	#0,$fffffa13.w
	bset.b	#6,$fffffa15.w
	bclr.b	#3,$fffffa17.w		* Automatic end of interrupt
	move.w	#$2300,sr

	move.l	stack(pc),-(sp)		* User mode
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	
	rts				* Return

		*     Reinits		
		*---------------------

reinit:	
	clr.l	-(sp)			* Superviseur
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,stack
	
	move.w	#$2700,sr		* Restaure les inters systeme 
	bsr	error_clavier
	move.l	oldclv(pc),$118.w
	move.l	oldvbl(pc),$70.w
	move.l	oldtimerb(pc),$120.w
	move.b	savtima(pc),$fffffa07.w	
	move.b	savtimb(pc),$fffffa09.w
	move.w	#$2300,sr

	move.l	stack(pc),-(sp)		* Utilisateur
	move.w	#32,-(sp)
	trap	#1
	addq.w	#6,sp
	
	rts				* Return

 
        *-------------------------------------------------------------*
        *	TRAITEMENTS VBL			                      *
	*	Affiche curseur (gere en vbl)		              *
        *-------------------------------------------------------------*

reafmouse:

	lea	mouse_save(pc),a0	* a0 = adresse buffer sauvg fond
	move.l	mouse_adr(pc),a1	* a1 = adresse du fond
	move.w	oldtyp(pc),d0		* d0 = affichage vbl precedente
	move.w	oldsize(pc),d1		* d1 = hauteur aff‡ichee vbl prec
	tst.w	d0
	blt.s	endreaf2		* Si oltyp<0 -> pas de reaffichage
	beq.s	noclipped2		* Si oltyp=0 -> not clipped

reaf12:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
 	lea	152(a1),a1

	dbra.w	d1,reaf12
	bra.s	endreaf2
	
noclipped2:
	
reaf22:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	144(a1),a1
	dbra.w	d1,reaf22
endreaf2:

	rts


affmouse:	

	movem.l		d0-d4/a0-a2,-(sp)	* Sauve les registres

	* Reaffiche le fond de la souris
	*--------------------------------*

	lea	mouse_save(pc),a0	* a0 = adresse buffer sauvg fond
	move.l	mouse_adr(pc),a1	* a1 = adresse du fond
	move.w	oldtyp(pc),d0		* d0 = affichage vbl precedente
	move.w	oldsize(pc),d1		* d1 = hauteur aff‡ichee vbl prec
	tst.w	d0
	blt.s	endreaf			* Si oltyp<0 -> pas de reaffichage
	beq.s	noclipped		* Si oltyp=0 -> not clipped

reaf1:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
 	lea	152(a1),a1

	dbra.w	d1,reaf1
	bra.s	endreaf
	
noclipped:
	
reaf2:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	144(a1),a1
	dbra.w	d1,reaf2
	
endreaf:

	* Affiche le sprite en sauvant le fond
	*--------------------------------------*

	move.l	ecran(pc),a1
	move.l	spr(pc),a0
	lea	mouse_save(pc),a2

	move.w	aff_rout(pc),d0
	cmp.w	#1,d0
	bne.s	not1
	move.w	posx(pc),d0
	move.w	posy(pc),d1
	bra.s	not2
not1:	
	*cmp.w	#2,d0
	*bne.s	not2
	move.w	fixx(pc),d0
	move.w	fixy(pc),d1
not2:

nogrid:	sub.w	xchaud(pc),d0
	sub.w	ychaud(pc),d1
	
	tst.w	d1
	bge.s	notopclip
	moveq.l	#15,d2
	add.w	d1,d2
	neg.w	d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,a0
	bra.s	endycalc
notopclip:
	cmp.w	#184,d1
	ble.s	nobottomclip
	move.w	#199,d2	
	sub.w	d1,d2
	bra.s	endycalc2
nobottomclip:	
	moveq.l	#15,d2
endycalc2:
	mulu.w	#160,d1
	add.l	d1,a1
endycalc:

	move.w	d2,oldsize
	
	tst.w	mode
	bne	mode2
	
	tst.W	d0			
	bge.s	noleftclip			

	and.w	#15,d0			* Clip gauche
	move.w	#1,oldtyp
	move.l	a1,mouse_adr

aff1:	moveq.l	#-1,d3
	move.w	(a0)+,d3
	ror.l	d0,d3
	swap	d3
	move.l	(a1),(a2)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	move.l	(a1),(a2)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	subq.l	#8,a1
	moveq.l	#0,d3
	move.w	(a0)+,d3
	ror.l	d0,d3
	swap	d3
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	lea	152(a1),a1
	dbra.w	d2,aff1
	bra	endaff
	
noleftclip:		
	
	cmp.w	#304,d0			* Clip droit
	ble.s	norightclip

	move.w	#2,oldtyp
	lea	152(a1),a1
	move.l	a1,mouse_adr
	and.w	#15,d0

aff2:	moveq.l	#-1,d3
	move.w	(a0)+,d3
	ror.l	d0,d3
	move.l	(a1),(a2)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	move.l	(a1),(a2)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	subq.l	#8,a1
	moveq.l	#0,d3
	move.w	(a0)+,d3
	ror.l	d0,d3
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	lea	152(a1),a1
	dbra.w	d2,aff2
	bra	endaff
	
norightclip:
	clr.w	oldtyp
	move.w	d0,d1
	and.w	#15,d0
	and.w	#$ff0,d1
	lsr.w	#1,d1
	add.w	d1,a1
	move.l	a1,mouse_adr

aff3:	moveq.l	#-1,d3
	move.w	(a0)+,d3
	ror.l	d0,d3
	move.l	(a1),(a2)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	move.l	(a1),(a2)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	swap	d3
	move.l	(a1),(a2)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	move.l	(a1),(a2)+
	and.w	d3,(a1)+
	and.w	d3,(a1)+
	lea	-16(a1),a1
	moveq.l	#0,d3
	move.w	(a0)+,d3
	ror.l	d0,d3
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	swap	d3
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	or.w	d3,(a1)+
	lea	144(a1),a1
	dbra.w	d2,aff3
	
	bra	endaff

mode2:				************* mode 2

	tst.W	d0			
	bge.s	noleftclip2			

	and.w	#15,d0			* Clip gauche
	move.w	#1,oldtyp
	move.l	a1,mouse_adr

aff12:	moveq.l	#-1,d3
	move.w	(a0)+,d3
	addq.w	#2,a0
	ror.l	d0,d3
	not.l	d3
	swap	d3
	move.l	(a1),(a2)+
	eor.w	d3,(a1)+
	eor.w	d3,(a1)+
	move.l	(a1),(a2)+
	eor.w	d3,(a1)+
	eor.w	d3,(a1)+
	lea	152(a1),a1
	dbra.w	d2,aff12
	bra	endaff
	
noleftclip2:		
	
	cmp.w	#304,d0			* Clip droit
	ble.s	norightclip2

	move.w	#2,oldtyp
	lea	152(a1),a1
	move.l	a1,mouse_adr
	and.w	#15,d0

aff22:	moveq.l	#-1,d3
	move.w	(a0)+,d3
	addq.w	#2,a0
	ror.l	d0,d3
	not.l	d3
	move.l	(a1),(a2)+
	eor.w	d3,(a1)+
	eor.w	d3,(a1)+
	move.l	(a1),(a2)+
	eor.w	d3,(a1)+
	eor.w	d3,(a1)+
	lea	152(a1),a1
	dbra.w	d2,aff22
	bra.s	endaff
	
norightclip2:
	clr.w	oldtyp
	move.w	d0,d1
	and.w	#15,d0
	and.w	#$ff0,d1
	lsr.w	#1,d1
	add.w	d1,a1
	move.l	a1,mouse_adr

aff32:	moveq.l	#-1,d3
	move.w	(a0)+,d3
	addq.w	#2,a0
	ror.l	d0,d3
	not.l	d3
	move.l	(a1),(a2)+
	eor.w	d3,(a1)+
	eor.w	d3,(a1)+
	move.l	(a1),(a2)+
	eor.w	d3,(a1)+
	eor.w	d3,(a1)+
	swap	d3
	move.l	(a1),(a2)+
	eor.w	d3,(a1)+
	eor.w	d3,(a1)+
	move.l	(a1),(a2)+
	eor.w	d3,(a1)+
	eor.w	d3,(a1)+
	lea	144(a1),a1
	dbra.w	d2,aff32
	
endaff:

	movem.l		(sp)+,d0-d4/a0-a2	* Restore les registres
	
	rts					* Return

*-------------------------------------------------------------------------*
	*-------------------------------------------------------------*
	*	INTERRUPTIONS			                      *
        *-------------------------------------------------------------*

        *-------------------------------------------------------------*
	*	ROUTINE CLAVIER  ($118)		                      *
        *-------------------------------------------------------------*

new118:	move.w	#$2500,sr
	move.w	d0,-(sp)		
	move.l	a0,-(sp)
	lea	modetch(pc),a0
        move.b  $fffffc02.w,d0		
	cmp.b	#$f8,d0			
	blt.s	clavier			
	cmp.b	#$fb,d0
	bgt.s	clavier
	sub.b	#$f8,d0			
	move.b	d0,mouse_z+1-modetch(a0)
	move.l	#mouse1,$118.w		
	bra.s	end
clavier:
	btst.l	#7,d0
	bne.s	bitoff
	and.w	#%1111111,d0
	cmp.b	#2,(a0,d0.w)
	beq.s	tch
	tst.b	(a0,d0.w)
	beq.s	control
	not.b	tabtch-modetch(a0,d0.w)
	bra.s	end
tch:	move.w	d0,scan_code-modetch(a0)
	bra.s	end	
control:move.b	#-1,tabtch-modetch(a0,d0.w)
	bra.s	end
bitoff:	and.w	#%1111111,d0
	tst.b	(a0,d0.w)
	bne.s	end
	clr.b	tabtch-modetch(a0,d0.w)
end:	move.l	(sp)+,a0
	move.w  (sp)+,d0		; Restaure d0
	rte				; Fin


mouse1:	move.w	#$2500,sr
	move.w	d0,-(sp)		; Sauve d0
	move.l	a0,-(sp)
	lea	table(pc),a0
	move.b	$fffffc02.w,d0		; Position X souris 
	subq.w	#1,cptx-table(a0)
	tst.w	cptx-table(a0)
	bne.s	ok4
	move.w	sensx-table(a0),cptx-table(a0)
	ext.w	d0
	and.w	flagx-table(a0),d0
	add.w	d0,posx-table(a0)		; En plus
	move.w	posx-table(a0),d0
	cmp.w	cx1-table(a0),d0
	bge.s	ok3
	move.w	cx1-table(a0),posx-table(a0)
	bra.s	ok4
ok3:	cmp.w	cx2-table(a0),d0
	ble.s	ok4
	move.w	cx2-table(a0),posx-table(a0)
ok4:
	move.l	#mouse2,$118.w		; Mouse2 remplace mouse1
	move.l 	(sp)+,a0		; Restaure d0
	move.w 	(sp)+,d0		; Restaure d0
	rte				; Fin

mouse2:	move.w	#$2500,sr
	move.w	d0,-(sp)		; Sauve d0
	move.l	a0,-(sp)
	lea	table(pc),a0
	move.b	$fffffc02.w,d0		; Position Y souris
	subq.w	#1,cpty-table(a0)
	tst.w	cpty-table(a0)
	bne.s	ok2
	move.w	sensy-table(a0),cpty-table(a0)
	ext.w	d0
	and.w	flagy-table(a0),d0	
	add.w	d0,posy-table(a0)	; En plus
	move.w	posy-table(a0),d0
	cmp.w	cy1-table(a0),d0
	bge.s	ok1
	move.w	cy1-table(a0),posy-table(a0)
	bra.s	ok2
ok1:	cmp.w	cy2-table(a0),d0
	ble.s	ok2
	move.w	cy2-table(a0),posy-table(a0)
ok2:	move.l	#new118,$118.w		; New118 remplace mouse2
	move.l 	(sp)+,a0		; Restaure d0
	move.w 	(sp)+,d0		; Restaure d0
	rte				; Fin
 
        *-------------------------------------------------------------*
        *	Timer B				                      *
	*			              			      *
        *-------------------------------------------------------------*

timerb:
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	move.l	rasterpos(pc),a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	lea	$fffffa1b.w,a1
	clr.b	(a1)
	move.w	(a0)+,$20-$1b(a1)
	move.b	#8,(a1)	
	move.l	a0,rasterpos
	move.l	(sp)+,a1
	move.l	(sp)+,a0
 	rte
      
        *-------------------------------------------------------------*
        *	VBL				                      *
	*			              			      *
        *-------------------------------------------------------------*

vbl:	
	move.l	a0,-(sp)		* Init rasters
	move.l	a1,-(sp)
	move.l	raster1(pc),rasterpos
	tst.w	extended		* Palette etendue ?
	beq.s	noflip
	not.w 	flippal
	beq.s	noflip
	move.l	raster2(pc),rasterpos
noflip:	move.l	rasterpos(pc),a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	lea	$fffffa1b.w,a1
	clr.b	(a1)
	move.w	(a0)+,$20-$1b(a1)
	move.b	#8,(a1)	
	move.l	a0,rasterpos			
	move.l	(sp)+,a1
	move.l	(sp)+,a0

	tst.w	hide			* Affichage curs souris en Vbl
	bne.s	nocurs
	bsr	affmouse		
nocurs:	
	clr.w	vsync				* Flag pour Vsync externes
	
	rte

*-------------------------------------------------------------------------*
      
        *-------------------------------------------------------------*
        *	VARIABLES			                      *
	*			              			      *
        *-------------------------------------------------------------*

depadr:		dc.l	0
stack:		dc.l	0
oldclv:		dc.l	0	
oldvbl:		dc.l	0
oldtimerb:	dc.l	0
savtima:	dc.w	0
savtimb:	dc.w	0

		dc.l	$abcdabcd	* Ident debut de table
Table:
posx:		dc.w	160	*0
posy:		dc.w	100	*2
scan_code:	dc.w	0	*4
aff_rout:	dc.w	1	*6
mouse_z:	dc.w	0	*8
ecran:		dc.l	0	*10
mouse_adr:	dc.l	0	*14
spr:		dc.l	0	*18
flagx:		dc.w	-1	*22
flagy:		dc.w	-1	*24
cx1:		dc.w	0	*26
cy1:		dc.w	0	*28
cx2:		dc.w	319	*30
cy2:		dc.w	199	*32
sensx:		dc.w	1	*34
sensy:		dc.w	1	*36
cptx:		dc.w	1	*38
cpty:		dc.w	1	*40

xchaud:		dc.w	10	*42   gestion affichage souris
ychaud:		dc.w	10	*44
oldtyp:		dc.w	-1	*46
oldsize:	dc.w	0	*48

vsync:		dc.w	0	*50   gestion vbl
extended:	dc.w	0	*52
flippal:	dc.w	0	*54
rasterpos:	dc.l	0	*56
raster1:	dc.l	0	*60
raster2:	dc.l	0	*64

hide:		dc.w	0	*68
ax:		dc.w	0	*70
ay:		dc.w	0	*72
fixx:		dc.w	0	*74
fixy:		dc.w	0	*76

adrtab1:	dc.l	modetch	*78
adrtab2:	dc.l	tabtch	*82
mode:		dc.w	0	*86
		
mouse_save:			*88   Buffer pour sauvegarde du fond
	rept	16
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	endr
		even
modetch:	rept	120
		dc.b	0
		endr	
		even
tabtch:		rept	120
		dc.b	0
		endr
		
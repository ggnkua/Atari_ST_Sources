**********************************
***** Initialisation AES/VDI *****
**********************************
	text
	include	aes.i
	include	vdi.i
	include	xbios.i
	include	structs.s
	XDEF	AESVDIinit_START,gem_exit,screen_mfdb
AESVDIinit_START
	bra	suitedesinits
	dc.b	"L O PtI ... cpobo dmaTER.KoMsa",0
	even
suitedesinits
	appl_init		; intialisation de station de travail AES
	move.w	int_out,ap_id

* ouverture d'une station VDI virtuel
* on cherche quelques info (taile de fonte systeme...) + le handle pour open_vw()
	graf_handle
	move.w		int_out+2,charw
	move.w		int_out+4,charh
	move.w		int_out+6,wbox
	move.w		int_out+8,hbox

	wind_get	#0,#4
	move.w		int_out+4,hauteur_menu

* on a besoin du device ecran pour open_vw()
;	move.w		#0,work_in		; le word machine-dependant que nous donne getrez... mais a koi ca sert ???

	move.w		#100,contrl		; l'op_code de v_opnvwk
	clr.w		contrl+2
	move.w		#12,contrl+4
	move.w		#11,contrl+6
	move.w		#45,contrl+8
	move.l		#vdi_virtual_pb,d1	; demander si work_out+45 est rempli par ptsout...
	move.w		#$73,d0
	trap		#2
	XREF		current_handle
	move.w		contrl+12,current_handle

* On en profite pour remplir une mfdb pour l'ecran
	lea	work_out,a0
	lea	screen_mfdb,a1
	clr.l	(a1)		; adresse ecran (tjrs 0)
	move.w	0*2(a0),d0
	move.w	1*2(a0),d3
	addq.w	#1,d0
	addq	#1,d3
	move	d0,mfdb_w(a1)
	move	d3,mfdb_h(a1)
	lsr	#4,d0
	move	d0,mfdb_wordw(a1)

* Un petit VQ_EXTEND pour connaitre plus d'info
	move.w		#102,contrl
	clr.w		contrl+2
	move.w		#6,contrl+4
	move.w		#1,contrl+6
	move.w		#45,contrl+8
	move.w		#1,intin
	move.l		#vdi_vqextend_pb,d1
	move.w		#$73,d0
	trap		#2	; vq_extend : demande des infos suplementaires sur la station VDI ouverte

* Mfdb_ecran suite !
	lea	screen_mfdb,a1
	move.w	planes,mfdb_planes(a1)
	clr.w	mfdb_format(a1)

* Si MiNT est la alors on fait un menu_register
	Supexec	#cookie_shearch

	XREF	global
	cmp.w	#1,global+2
	beq	.no_register
	tst.w	global+2
	beq	.no_register


;	tst.l	cookie_mint
;	beq	.no_register

	XREF	appl_name
	menu_register	ap_id,#appl_name
.no_register
	XREF	AESVDIinit_END
	jmp	AESVDIinit_END

cookie_shearch
	move.l	$5a0,cookie_start
	move.l	$5a0,a0
.loop
	cmp.l	#"MiNT",(a0)
	beq	.mint_is_here
	tst.l	(a0)
	beq	.sort
	addq.l	#8,a0
	bra	.loop
.sort	rts
.mint_is_here
	addq.l	#4,a0
	move.l	(a0),cookie_mint
	rts
gem_exit
	v_clsvwk

	appl_exit
	rts

	bss
	even
	XDEF	ap_id,cookie_start,cookie_mint,hauteur_menu
ap_id		ds.w	1
cookie_start	ds.l	1
cookie_mint	ds.l	1	; version de MiNT (si 0, pas sous MiNT...)
hauteur_menu	ds.w	1
	data
*******************************************
* tableau special d'appel v_opnvwk() pour *
* remplissage des tableau de depart et    *
* d'arrive : vdi_virtual_pb               *
*******************************************
	even
* On optimise en donnant dirrectement l'adresse du tableau de sortie *
	XREF	intin,ptsin,ptsout,contrl
vdi_virtual_pb
	dc.l	contrl
	dc.l	work_in
	dc.l	ptsin
	dc.l	work_out
	dc.l	ptsout
vdi_vqextend_pb
	dc.l	contrl
	dc.l	intin
	dc.l	ptsin
	dc.l	vqext_work_out
	dc.l	ptsout
*****************************************
* tableau d'initialiation VDI : work_in *
*****************************************
work_in:
	dc.w	1	; Device number : a chercher avec getrez() (voir compendium page 7.61)
	dc.w	1	; type de line 		par default
	dc.w	1	; couleur 		par default
	dc.w	0	; marker type		par default
	dc.w	1	; marker color		par default
	dc.w	0	; fonte 		par default
	dc.w	1	; text color 		par default
	dc.w	1	; fill interior 	par default
	dc.w	0	; fill style 		par default
	dc.w	1	; fill color 		par default
	dc.w	2	; 0 = Normalized Device Coordinates / 2 = raster Coordinates
	ds.w	50
	bss
*****************************************************
* MFDB ecran. Pratique parsque ne changeant jamais. *
*****************************************************
	XDEF	SCREEN_M
	XDEF	screen_mfdb
SCREEN_M
screen_mfdb	ds.w	10

*****************************************************
* tableau de retour de graf_handle +                *
* tableau de retour d'initialisation VDI : work_out *
*****************************************************
getrez_out_tab
charw		ds.w	1	; taille W en pixel de la fonte systeme
charh		ds.w	1	; taille H en pixel de la fonte systeme
wbox		ds.w	1	; largeur mini d'un BOX_CHAR
hbox		ds.w	1	; hauteur mini d'un BOX_CHAR
***********************************
*** Quelques variables globales ***
***********************************
	XDEF	x_max,y_max
work_out:
x_max		ds.w	1	; coordonne X maximane (nbr de pixel -1)
y_max		ds.w	1	; idem Y
noscale		ds.w	1	; 0 = Le device peut "scaler" une image / 1 = Il ne peut pas
wpixel		ds.w	1	; largeur d'un pixel en micron
hpixel		ds.w	1	; hauteur d'un pixel en micron
cheights	ds.w	1	; nombre de caractere height (0 = continuous scaling)
linetypes	ds.w	1	; nombre de types de lignes
linewidths	ds.w	1	; number of line width (0 = continuous scaling)
markertypes	ds.w	1	; nombre de types de markers
markersizes	ds.w	1	; nombre de tailles de markers (0 = continuous scaling)
faces		ds.w	1	; nombre de face du device
patterns	ds.w	1	; nombre de patterns utilisable
hatches		ds.w	1	; number of available hatches
colors		ds.w	1	; nombre de "crayon" utilisable (ST HIGHT = 2, ST Medium = 4, TT-Low = 256, True color = 256)
ngdps		ds.w	1	; nombre de GDP(s) supporte(s)
cangdps		ds.w	10	; Liste de GDP suporte : 1 = bar, 2 = arc, etc...
gdpattr		ds.w	10	; ...
cancolor	ds.w	1	; flag de couleur				0 = n&B 	/ 1 = couleur
cantextrot	ds.w	1	; flag de routation de texte	0 = non		/ 1 = oui
canfillarea	ds.w	1	;
cancellarry	ds.w	1	;
palette		ds.w	1	; nombre de couleur dans la palette : 0 = true color, 2 = monochrome, 3 = plan -> nb de couleur
locators	ds.w	1	; 1 = clavier seul / 2 = clavier plus autre...
valuators	ds.w	1	; 1 = clavier seul / 2 = clavier plus autre...
choicedevs	ds.w	1	; 1 = touche de fonction / 2 = touche de fonction + pave numerique
stringdevs	ds.w	1	; nombre de "string device" : 1 = keyboard
wstype		ds.w	1	; workstation type : 0 = output, 1 = input, 3 = In/Out, 4 = metafile
minwchar	ds.w	1	; W minimum d'un caractere
minhchar	ds.w	1	; H minimum d'un caractere
maxwchar	ds.w	1	; W maximum d'un caractere
maxhchar	ds.w	1	; H maximum d'un caractere
minwline	ds.w	1	; taille minimum de la largeur de ligne
zero5		ds.w	1	; reserve
maxwline	ds.w	1	; taille maximum de la largeur d'une ligne
zero7		ds.w	1	; reserve
minwmark	ds.w	1	; minimum W d'un marker
minhmark	ds.w	1	; minimum H d'un marker
maxwmark	ds.w	1	; maximum W d'un marker
maxhmark	ds.w	1	; maximum H d'un marker
		ds.w	128-56	; peut-etre la VDI aurat-elle plus de parametre un jour...

*** Quelques XDEF a rajouter selon la convenance de chacun
	XDEF planes
vqext_work_out:
screentype	ds.w	1	; type d'ecran...
bgcolors	ds.w	1	; nombre de couleur disponoble pour l'arriere plan
txtfx		ds.w	1	; text fx supportation
canscale	ds.w	1	; 0 = unsuported, 1 suported
planes		ds.w	1	; nombre de plan
lut		ds.w	1	; 0 = look up table not suported / 1 = suported
rops		ds.w	1	; 16*16 raster operation per second (perf factor...)
cancontourfill	ds.w	1	; 0 = non disponible, 1 = oui
textrot		ds.w	1	; 0 = non / 1 = 90 / 2 = angle quelconque
writemode	ds.w	1	; nombre de mode d'ecriture
inputmode	ds.w	1	; highest level of input modes : 0 = none / 1 = request / 2 = sample
textalign	ds.w	1	; 0 = not available / 1 = available
inking		ds.w	1	; 0 = device can't ink / 1 = device can ink
rubberbanding	ds.w	1	; 0 = no rubberbanding / 1 rubberbanded lines / 2  = rubberbanded lines and rectangle
maxvertices	ds.w	1	; nombre maxi de point pour polyline, polymaker, et filled area (-1 = no limit)
maxintin	ds.w	1	; taille maxi du tableau intin (-1 = pas de maxi)
mousebuttons	ds.w	1	; nombre de bouttons de la sourie
widestyles	ds.w	1	; style pour wide line : 0 = no / 1 = yes
widemodes	ds.w	1	; writing modes disponible pour wide line : 0 = no / 1 = oui
		ds.w	128-19
	text

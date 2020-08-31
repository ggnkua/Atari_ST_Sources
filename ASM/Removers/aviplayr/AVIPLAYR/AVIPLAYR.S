; AVI-Player v 0.30á
; By Seb & Stabylo/The REMOVERS 
; Parce que j'en avais marre du player de Dieter Fiebelkorn
; Parce que j'en avais assez que mes amis PC-Istes rigolent des ATARI
; Parce que beaucoup de Falcon-men se sentent frustr‚s de ne pouvoir les jouer
; J'ai d‚cid‚ en l'an de grace 1996 de faire un player de fichiers AVI
; hyper-rapide pour Falcon uniquement ( mode True Color oblige ! ) avec
; les sons s'il vous plait !!!
; Je remercie quand mˆme D. Fiebelkorn car sans lui, ce player ne serait
; jamais n‚ ( sauf si j'avais trouv‚ une bonne doc sur les fichiers AVI )
; 					Seb/The Removers
; Assembleur utilis‚ : le g‚nial ASSEMBLE de chez Brainstorm .

	MC68030
;	opt	y-,d+
;	opt	y-
	opt	y-,d-

VERSION	macro
	dc.b	'0.30á'
	endm

TEST_TIME_RESAMPLE:	equ	0
TEST_TIME_UNPACK:	equ	0
TIME_TAKEN		equ	0
TEST_TIME_INTER:	equ	0
MY_COMMAND	equ	0
RESAMPLE_SPD	equ	230	;226
BASE_FREQ	equ	49170
SET_CACHE_020	equ	$3111
SET_CACHE_040	equ	$80008000
STFA		equ	0
STFA_OUTPUT	equ	0
CYCLE_IT	equ	1
FIRST_TST	equ	0
INDEO		equ	1
NO_OPT		equ	0
LENGTH:		equ	12
IMA4		equ	1
MSADPCM		equ	1


TIMING		equ	5000	;4950
SYNCHRO_PLUS	equ	0
VIRGULE		equ	1

NEW_VER		equ	FIRST_TST|MY_COMMAND

	IFNE	MY_COMMAND
	opt	d+
my_cmd_line macro
; ordre des options : -*+/#~ (… vos souhaits)
; Plus maintenant petit scarab‚e, plus maintenant !!!
my_cmd
; asciil permet de d‚clarer une chaine de caractŠres au format Pascal
; n'est-ce pas Stabylo ?? ;-)
;	asciil	'~f:\\video\\avi\\car_race.avi'
;	asciil	'-#~f:\\video\\avi\\moon3.avi'
;	asciil	'~f:\\video\\avi\\intro.avi'
;	asciil	'#e:\\actuel\\zip\\bgpp0.avi'
;	asciil	'f:\\video\\avi\\et.avi'
;	asciil	'#e:\\actuel\\zip\\test.avi\\avicine.avi'
;	asciil	'#e:\\actuel\\zip\\vinzzz.avi\\testmoto.avi'
;	asciil	'e:\\actuel\\zip\\1st.avi'
;	asciil	'#e:\\ada_flc.avi'
;	asciil	'f:\\media\\videos\\avi\\rgb2.avi'	
;	asciil	'f:\\media\\videos\\avi\\clint2.avi'	
;	asciil	'f:\\media\\videos\\avi\\run_tst.avi\\test.avi'
;	asciil	'f:\\media\\videos\\avi\\flc.avi'
;	asciil	'e:\\zip_gig\\groger1.avi'
;	asciil	'e:\\actuel\\zip\\mslogo.avi'
;	asciil	'e:\\zip_gig\\8.avi'
;	asciil	'e:\\zip_gig\\a3.avi'
;	asciil	'e:\\actuel\\zip\\vinzzz.avi\\raw8_163.avi'
;	asciil	'f:\\media\\videos\\avi\\buggy\\bacha.avi'
;	asciil	'e:\\indeo.avi'
;	asciil	'g:\\zara1m.avi'
;	asciil	'+f:\\media\\*.avi'
;	asciil	'f:\\media\\ulysse31.avi'
;	asciil	'f:\\2forum.avi'
;	asciil	'i:\\media\\videos\\avi\\clive1.avi'
	asciil	'i:\\clive1.avi'
	dc.b	0
	even
	endm
	ENDC

	IFNE	NEW_VER
	output	avi_new.ttp
	ELSE
	output	.ttp
	ENDC

; Macro de conversion format Intel <-> Motorola
IM	macro
	rol.w	#8,\1
	IFC	'\0','l'
	swap	\1
	rol.w	#8,\1
	ELSE
	IFC	'\0','L'
	swap	\1
	rol.w	#8,\1
	ENDC
	ENDC
	endm

; Macro pour envoyer un octet au copro clavier
; Cette macro est loin d'ˆtre inutile car sinon, il se peut que lors
; d'un slide-show, certaines vid‚os n‚cessitant la souris n'en dispose
; pas et inversement !!!
send_kbd	macro
	btst	#1,$fffffc00.w
	beq.s	*-6
	move.b	\1,$fffffc02.w
	endm
	
	include	'gemdos.s'		; Utilise mes macros
	include	'bios.s'
	include	'xbios.s'

debut_text:
	bra	jump_header
	dc.b	'Enter here the complete file name of the file you want '
	dc.b	'to see once at the boot (128 char max. at the C format) :'
START_video:
	dcb.b	128,0	
	dc.b	0,'STOP here !!!',0
	even

	IFNE	INDEO
	even
indeo_iced:
	incbin	'indeo.ice'
	even
	ENDC

jump_header:


	include	'aes.s'

TV_MODE1:	equ	TC
TV_MODE2:	equ	ENTRELACE|COL80|TC
VGA_MODE1:	equ	DOUBLELIGNE|VGA|TC
VGA_MODE2:	equ	SIMPLELIGNE|VGA|TC
	
; Deux buffers de LENGTH secondes pour les sons ( si 22050 Hz ‚videmment !!! )
BUFFER1:	equ	13000*LENGTH
BUFFER2:	equ	26000*LENGTH

	BSS
debut_bss:
	TEXT
	
	bra.s	main
	IFNE	STFA&STFA_OUTPUT
	dc.b	'STFA output:'
STFA_output:
	dc.w	0
	ENDC
info_debug:
	dc.b	"Hey you, there's nothing to be ripped in this nice AVI-Player "
	dc.b	'by Seb/The Removers.'
	even
main:
	move.l	4(sp),a6
	move.l	12(a6),a5
	add.l	20(a6),a5
	add.l	28(a6),a5
	add.l	#$100+$400,a5
	move.l	a5,d1
	and.w	#$fffe,d1
	add.l	a6,d1
	move.l	d1,sp
	Mshrink	a6,a5

	move.l	#debut_bss,a0
	move.l	#fin_bss-debut_bss,d0
	lea	(a0,d0.l),a1
.clr_bss:
	clr.l	(a0)+
	clr.l	(a0)+
	cmp.l	a0,a1
	bgt.s	.clr_bss		

	dc.w	$a00a
	
	Cconws	active_curseur(pc)

;	move.l	32(a6),a6
	lea	$80(a6),a6
	
	move.l	a6,-(sp)	; on ne sait jamais !!!
	Appl_init
	move.w	global(pc),-(sp)
	Appl_exit
	move.w	(sp)+,d0
	movem.l	(sp)+,a6
	
	IF	MY_COMMAND
	bra	take_my_command
	ELSE
	tst.w	d0
	beq	auto_launch
	tst.b	(a6)
	bne	take_name
	ENDC
	
	Cconws	how_txt(pc)
	Cnecin
	Cconws	desactive_curseur(pc)
	dc.w	$a009
	Pterm0
how_txt:
	dc.b	'EpAVI-Player v '
	VERSION
	dc.b	'q',13,10
	dc.b	'Coded by Seb & Stabylo/The Removers',13,10
	dc.b	'Play some *.AVI on Falcon 030 & compatibles.',13,10
	dc.b	13,10
	dc.b	'Install me as an application TTP with',13,10
	dc.b	'full path for the file and me.',13,10
	dc.b	'How to use me :',13,10
	dc.b	'Put the icon of the video you want to',13,10
	dc.b	"see on mine and that's all !!!",13,10
	dc.b	13,10
	dc.b	'AVI-Player is a freeware ...',13,10
	dc.b	'Please spread it !!!',13,10
	dc.b	13,10
	dc.b	'Visit our website at :',13,10
	dc.b	'  http://removers.atari.org/',13,10,0
	even
	BSS
mode_tv:
	ds.w	1
mode_vga:
	ds.w	1
	even.l
	TEXT
	IFEQ	MY_COMMAND
auto_launch:
	move.l	#START_video,a0
	moveq	#127,d0
	moveq	#1,d1
	lea	1(a6),a1
	move.b	#'-',(a1)+
.copy_loop:
	addq.w	#1,d1
	move.b	(a0)+,(a1)+
	dbeq	d0,.copy_loop
	move.b	d1,(a6)
*	bra.s	take_name
	ENDC	
	IFNE	MY_COMMAND
	my_cmd_line
take_my_command
	lea	my_cmd(pc),a6
	ENDC
take_name:
	clr.w	slide_flag	; On ne scrute pas un dossier
	clr.w	play_once	; On joue les AVI une infinit‚ de fois
	move.w	#TV_MODE1,mode_tv
	move.w	#VGA_MODE1,mode_vga
	move.w	#$ffff,synchro
	clr.w	fast_resampling
	clr.w	STFA_default
	
	clr.w	d0
	move.b	(a6)+,d0
	move.w	d0,-(sp)	; Sauve D0 ( nbre de car. ) dans la pile
.tst_option01:
	cmp.b	#'-',(a6)	; On ne joue qu'une fois le AVI
	bne.s	.tst_option02
	subq.w	#1,(sp)
	addq.l	#1,a6	
	move.w	#1,play_once
	bra.s	.tst_option01
.tst_option02:
	cmp.b	#'*',(a6)	; On saute les informations SHAREWARE
	bne.s	.tst_option03
	subq.w	#1,(sp)
	addq.l	#1,a6
	bra.s	.tst_option01
.tst_option03:
	cmp.b	#'+',(a6)	; On scrute un directory
	bne.s	.tst_option04
	subq.w	#1,(sp)
	addq.l	#1,a6
	move.w	#1,slide_flag
	move.w	#1,play_once
	bra.s	.tst_option01
.tst_option04:
	cmp.b	#'/',(a6)	; On scrute et on ne joue qu'une fois chaque AVI
	bne.s	.tst_option05
	subq.w	#1,(sp)
	addq.l	#1,a6
	move.w	#1,slide_flag
	bra.s	.tst_option01
.tst_option05:
	cmp.b	#'#',(a6)
	bne.s	.tst_option06
	subq.w	#1,(sp)
	addq.l	#1,a6
	move.w	#TV_MODE2,mode_tv
	move.w	#VGA_MODE2,mode_vga
	bra.s	.tst_option01
.tst_option06:
	cmp.b	#'~',(a6)
	bne.s	.tst_option07
	subq.w	#1,(sp)
	addq.l	#1,a6
	clr.w	synchro
	bra.s	.tst_option01
.tst_option07:
	cmp.b	#'%',(a6)
	IFNE	STFA
	bne.s	.tst_option08
	ELSE
	bne.s	.tst_end
	ENDC
	subq.w	#1,(sp)
	addq.l	#1,a6
	move.w	#1,fast_resampling
	bra	.tst_option01
	IFNE	STFA
.tst_option08:
	cmp.b	#'œ',(a6)
	bne.s	.tst_end
	subq.w	#1,(sp)
	addq.l	#1,a6
	move.w	#1,STFA_default
	bra	.tst_option01
	ENDC
.tst_end:
	Cconws	desactive_curseur(pc)
	move.w	(sp)+,d0	; Reprend D0
	lea	nom_fichier(pc),a5
	subq.w	#1,d0
.copy_name:
	move.b	(a6)+,(a5)+	
	dbf	d0,.copy_name
	clr.b	(a5)+
	
	clr.l	buffer_size
	clr.l	real_adr_buffer
	
	Supers	#0
	move.l	d0,super
	send_kbd	#$12
	Kbdvbase
	move.l	d0,a0
	lea	16(a0),a0
	move.w	#$2700,sr
	move.l	(a0),old_mouse
	move.l	#scroll_mouse,(a0)
	move.l	$4ce.w,old_vbl_it
	move.l	#vbl_it,$4ce.w
	move.w	#$2300,sr
	
	bsr	init_nvdi
	
	move.l	($5a0.w),a0
	beq	fin_prg

	bsr	init_mint
	bsr	init_cacr
	tst.w	d1
	beq	fin_prg
	bsr	init_tveil

	Vsetmode	#-1
	move.w	d0,old_mode
	Vsync

	move.w	#1,sound_disabled
	clr.w	sound_lock_flag
	IFNE	STFA
	move.w	#1,stfa
	tst.w	STFA_default(pc)
	bne	.locked
	ENDC
	Locksnd				; Falcon, donne-moi ton son !!
	cmp.w	#1,d0
	bne	.locked
	IFNE	STFA
	clr.w	stfa
	ENDC
	
	bsr	precalcul_resampling
	IFNE	IMA4
	bsr	precalc_ima4
	ENDC
	IFNE	MSADPCM
	bsr	precalc_msadpcm
	ENDC

	move.w	#1,sound_lock_flag
	lea	mfp_save_buffer(pc),a0	; On sauve les registres MFP
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa0b.w,(a0)+
	move.b	$fffffa0f.w,(a0)+
	move.b	$fffffa03.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	move.b	$484.w,(a0)+
	and.b	#$fe,$484.w
	bclr.b	#7,$fffffa13.w
	bclr.b	#7,$fffffa07.w
	bclr.b	#7,$fffffa0b.w
	bclr.b	#7,$fffffa0f.w
	bset.b	#7,$fffffa03.w
	move.l	$120.w,timer_b			; Sauve le Timer B
	
	move.l	$13c.w,dma_it			; On va se servir du niveau 15 d'IT
						; pour les sons
	Setinterrupt	#0,#0
	Setinterrupt	#1,#0
	Buffoper	#0
	Settracks	#0,#0
	Soundcmd	#ADDERIN,#-1
	move.w	d0,sound_adderin
	Soundcmd	#ADDERIN,#%10
	Soundcmd	#ADCINPUT,#-1
	move.w	d0,sound_adcinput
	Soundcmd	#ADCINPUT,#%11
	Devconnect	#DMAPLAY,#DAC,#0,#0,#1
.locked:	
	IFNE	STFA
	tst.w	stfa(pc)
	beq.s	.no_stfa
.search_cookie:
	move.l	$5a0.w,d0
	moveq	#-1,d1
	tst.l	d0
	beq.s	.search_xbra	; pas de cookie jar
	move.l	d0,a0			
.search_it_cookie:
	move.l	(a0)+,d0
	beq.s	.end_search_it
	cmp.l	#'STFA',d0
	beq.s	.trouve_cookie
	addq.l	#4,a0
	bra.s	.search_it_cookie
.trouve_cookie:
	moveq	#0,d1
.end_search_it:
.search_xbra:
	tst.l	d1
	beq.s	.no_need
	move.l	$70.w,a0
.search_it_xbra:
	move.l	-12(a0),d0
	cmp.l	#'XBRA',d0
	bne.s	.no_stfa
	move.l	-8(a0),d0
	cmp.l	#'STFA',d0
	beq.s	.trouve_xbra
	move.l	-4(a0),a0
	bra.s	.search_it_xbra
.trouve_xbra:
	lea	-16(a0),a0	; on se place sur le paramŠtre
	moveq	#0,d1
.no_need:
	move.l	(a0),stfa_control
	move.w	#1,sound_lock_flag
	not.w	d1
	move.w	d1,stfa
.no_stfa:
	ENDC

	bsr	precalculs_uv_bgr
	bsr	precalculs_cram
	bsr	precalc_msvc16
	IFNE	INDEO
	move.l	#indeo_iced,a0
	move.l	#indeo_ice,a1
	bsr	ice_decrunch
	ENDC

	bsr	vide_clavier

	Fgetdta					; Est-ce que notre
	move.l	d0,old_dta			; fichier existe ???
	Fsetdta	new_dta(pc)
	tst.w	slide_flag
	bne.s	.no_tst_exist
	Fsfirst	nom_fichier(pc),#0
	tst.w	d0
	bne	fin_prg
	move.l	new_dta+26(pc),phys_size
.no_tst_exist:
	clr.l	offset_affichage
	Mon_type				; En fonction de l'‚cran
	tst.w	d0
	beq	fin_prg
	lea	bug+2(pc),a3
	lea	_bug+2(pc),a4
	cmp.w	#1,d0
	beq.s	ecran_st_or_tv
	cmp.w	#2,d0
	beq.s	ecran_vga
	cmp.w	#3,d0
	beq.s	ecran_st_or_tv
	bra	fin_prg
ecran_st_or_tv:
	lea	mode_tv(pc),a0
	lea	decompresse_cram8(pc),a1
	lea	decompresse_cram16(pc),a2
	bra.s	suite
ecran_vga:
	lea	mode_vga(pc),a0
	lea	decompresse_cram8_vga(pc),a1
	lea	decompresse_cram16_vga(pc),a2
suite:
	move.l	a1,(a3)
	move.l	a2,(a4)
	move.w	old_mode(pc),d0
	and.w	#PAL,d0
	bne.s	.pal
.ntsc:
	not.w	d0
	and.w	d0,(a0)
.pal:
	move.w	(a0),new_mode
cookie_jar:
	move.l	($5a0.w),a0
	beq	fin_prg
	move.w	old_mode(pc),d0
	and.w	#%111,d0
	cmp.w	#TC,d0
	beq.s	.no_setscreen_1
	Setscreen #0,#0,#3,new_mode(pc)
.no_setscreen_1:
	Vsync
	Logbase Physbase
	move.l	d0,my_adr_scr
	move.l	d0,adr_scr
	move.l	d0,old_adr_scr
	move.l	d0,phys_adr
	move.l	d0,log_adr
	move.l	d0,org_adr

	clr.l	virtual_screen	; on ne travaille pas dans un ‚cran virtuel
	moveq	#0,d0
	move.w	$ffff8210.w,d0	; Taille ligne en mots
	move.w	d0,max_x
	move.w	d0,phys_x
	lsl.w	d0		; Taille ligne en octets
	move.w	d0,size_one_line
	move.l	d0,d1
	addq.w	#6,d1
	move.w	d1,previous_line_6
	addq.w	#2,d1
	move.w	d1,previous_line_8
	lsr.l	#3,d0		; Divise par 8
	move.w	$ffff82aa.w,d2		; Fin de l'affichage graphique
	move.w	d2,vde_save
	move.w	$ffff82a8.w,d1		; D‚but de l'affichage graphique
	move.w	d1,vdb_save
	move.w	$ffff82a6.w,vbe_save
	move.w	$ffff82a4.w,vbb_save
	sub.w	d1,d2			; Nombre de demi-lignes graphiques
	lsr.w	#1,d2			; Nombre de lignes graphiques
	move.w	$ffff82c2.w,d3
	move.w	d3,vco_save
	move.w	mode_vga(pc),d1
	cmp.w	new_mode(pc),d1
	beq.s	.vga
.tv:
	btst.l	#1,d3		; entrelacement ?
	beq.s	.no_problem
	lsl.w	#1,d2
	bra.s	.no_problem
.vga:	
	btst.l	#0,d3		; double ligne ?
	beq.s	.no_problem
	lsr.w	#1,d2
.no_problem:
	move.w	d2,max_y
	move.w	d2,phys_y
	
	bsr	precalc_multiples
	bsr	cls

	clr.l	$ffff9800.w
	lea	adr_scr(pc),a0
	move.l	(a0),old_adr_scr

	tst.w	slide_flag
	beq.s	boucle_slide
	lea	nom_fichier(pc),a0
	lea	mask_fichier(pc),a1
.loop_copy_mask:
	move.b	(a0)+,(a1)+
	bne.s	.loop_copy_mask
	subq.l	#1,a1
.search_slash:
	move.b	-(a1),d0
	beq.s	.mask_vide
	cmp.b	#'\',d0
	bne.s	.search_slash
.mask_vide:
	move.b	#'\',(a1)+
	move.b	#'*',(a1)+
	move.b	#'.',(a1)+
	move.b	#'A',(a1)+
	move.b	#'V',(a1)+
	move.b	#'I',(a1)+
	clr.b	(a1)+	
boucle_slide:
	tst.w	slide_flag
	beq.s	un_seul_fichier

	bsr	cls

	tst.w	first_file
	bne.s	.other_files
.first_file:	
	Fsfirst	mask_fichier(pc),#0
	move.w	#1,first_file
	bra.s	.suite_slide
.other_files:
	Fsnext
.suite_slide:
	tst.w	d0
	bne	fin_prg
	lea	nom_fichier(pc),a0
.search_zero:
	tst.b	(a0)+
	bne.s	.search_zero
	subq.l	#1,a0
.search_slash:
	move.b	-(a0),d0
	beq.s	.nom_vide
	cmp.b	#'\',d0
	bne.s	.search_slash
.nom_vide:
	move.b	#'\',(a0)+
	lea	new_dta+26(pc),a1
	move.l	(a1)+,phys_size
.copy_nom:
	move.b	(a1)+,(a0)+
	bne.s	.copy_nom
un_seul_fichier:
	clr.w	palette_tc
	clr.w	save_palette_tc
	clr.w	auds_yet
	move.w	vde_save(pc),$ffff82aa.w
	move.w	vdb_save(pc),$ffff82a8.w
	move.w	vbb_save(pc),$ffff82a4.w
	move.w	vbe_save(pc),$ffff82a6.w
	move.w	#'00',vids_stream
	move.w	#'01',auds_stream
	Fopen	nom_fichier(pc),#0
	move.w	d0,handle
	Fread	handle(pc),#8,riff_header(pc)
	cmp.l	#'RIFF',riff_header		; Signature RIFF ???
	bne	no_avi_file
	move.l	riff_size(pc),d0		; Suivie de la taille
	IM.l	d0				; Mot long format INTEL
	move.l	d0,riff_size
	addq.l	#8,d0
	move.l	phys_size(pc),d1
	cmp.l	d0,d1
;	bne	no_avi_file
	Fread	handle(pc),#4,form_type(pc)
	cmp.l	#'AVI ',form_type		; Est-ce un fichier AVI ??
	bne	no_avi_file	
	move.l	d0,seek_counter
search_list_chunk:
	clr.l	chunk_size
.loop_search_list_chunk:
	Fseek	chunk_size(pc),handle(pc),#1
	tst.l	d0
	blt	no_avi_file
	Fread	handle(pc),#8,chunk_type(pc)
	move.l	d0,seek_counter
	move.l	chunk_size(pc),d0		; On remet la taille
	IM.l	d0				; au format MOTOROLA
	move.l	d0,chunk_size
	cmp.l	#'LIST',chunk_type		; A-t-on une LISTe ??
	bne.s	.loop_search_list_chunk	; Non => on continue de chercher !!
analyse_header:
	Fread	handle(pc),#4,list_type(pc)
	cmp.l	#'hdrl',list_type(pc)		; Est-ce le header ??
	bne	no_avi_file			; Non => Bye !!
	move.l	#4,list_counter			; D‚j… 4 octets de lus
.loop_header:
	move.l	chunk_size(pc),d0
	move.l	list_counter(pc),d1
	cmp.l	d0,d1				; A-t-on fini de lire la LISTe ??
	bge	.end_loop_header		; Oui => Bah alors on continue !!
	Fread	handle(pc),#8,id_type(pc)	; Sinon
	addq.l	#8,list_counter			; Relit nouveau bout de chunk
	move.l	id_size(pc),d0			; Recode la taille 
	IM.l	d0
	move.l	d0,id_size
	move.l	id_type(pc),d0
	cmp.l	#'avih',d0			; Est-ce avih ???
	bne	.no_avih
	move.l	id_size(pc),d0
	cmp.l	#$38,d0				; Taille minimale d'avih = $38
	blt	no_avi_file
	Fread	handle(pc),#$38,little_buffer(pc)
	sub.l	#$38,id_size
	add.l	#$38,list_counter
	lea	little_buffer(pc),a0
	moveq	#0,d0
	clr.w	nb_timer
	move.l	(a0),d0			; Speed en micro-secondes 
	IM.l	d0
	divu.w	#TIMING,d0
	IFNE	SYNCHRO_PLUS
	addq.w	#1,d0
	ENDC
.write_nb_timer:
	move.w	d0,synchro_th
	move.w	d0,nb_timer		; Nb de Vsync … faire entre chaque image
	IFNE	VIRGULE
	swap	d0
	move.w	d0,reste_timer
	ENDC
	move.l	32(a0),d0		; Largeur au format INTEL
	IM.l	d0
	move.w	d0,width
	move.l	36(a0),d0		; Hauteur au format INTEL
	IM.l	d0
	move.w	d0,height
	send_kbd	#$12
	move.w	width(pc),d0
	add.w	#15,d0
	and.w	#$fff0,d0
	cmp.w	max_x(pc),d0		; Pas plus grand que max_x
	bgt.s	.resize_screen
	move.w	height(pc),d0
	cmp.w	max_y(pc),d0		; Ni que max_y
	ble	.no_resize_screen
.resize_screen:
	movem.l	d0-d7/a0-a6,-(sp)
	tst.l	virtual_screen
	beq.s	.first_virtual
	Mfree	virtual_screen(pc)
	clr.l	virtual_screen
.first_virtual:
	move.w	width(pc),d0
	add.w	#15,d0
	and.w	#$fff0,d0
	cmp.w	phys_x(pc),d0	; on prend le max de phys_x et width
	bgt.s	.ok_x
	move.w	phys_x(pc),d0
	add.w	#15,d0
	and.w	#$fff0,d0
.ok_x:
	move.w	d0,max_x	; on remplit max_x
	move.w	height(pc),d1
	cmp.w	phys_y(pc),d1	; on prend le max de phys_y et height
	bgt.s	.ok_y
	move.w	phys_y(pc),d1
.ok_y:
	move.w	d1,max_y	; on remplit max_y
	lsl.w	d0			; largeur*2
	mulu.w	d1,d0			; taille_ecran
	Mxalloc	d0,#0			; ST Ram pour l'‚cran virtuel
	tst.l	d0
	ble.s	.no_virtual
.virtual:
	move.l	d0,virtual_screen
	move.l	d0,my_adr_scr
	move.l	d0,adr_scr
	move.l	d0,old_adr_scr
	move.l	d0,log_adr	
	move.l	d0,org_adr
	Setscreen	virtual_screen(pc),virtual_screen(pc),#-1
	move.w	max_x(pc),d0
	move.w	d0,d1
	sub.w	phys_x(pc),d1
	move.w	d1,$ffff820e.w	; offset de ligne
	lsl.w	d0		; taille en octets
	move.w	d0,size_one_line
	move.w	d0,d1
	addq.w	#6,d1
	move.w	d1,previous_line_6
	addq.w	#2,d1
	move.w	d1,previous_line_8
	bsr	precalc_multiples
	bsr	cls
	movem.l	(sp)+,d0-d7/a0-a6
	bra	.no_resize_screen
.no_virtual:
	move.l	phys_adr(pc),my_adr_scr
	move.l	phys_adr(pc),adr_scr
	move.l	phys_adr(pc),old_adr_scr
	move.l	phys_adr(pc),log_adr
	move.l	phys_adr(pc),org_adr
	Setscreen	phys_adr(pc),phys_adr(pc),#-1
	move.w	phys_x(pc),max_x
	move.w	phys_y(pc),max_y
	move.w	max_x(pc),d0
	clr.w	$ffff820e.w	; offset de ligne nul
	lsl.w	d0		; taille en octets
	move.w	d0,size_one_line
	move.w	d0,d1
	addq.w	#6,d1
	move.w	d1,previous_line_6
	addq.w	#2,d1
	move.w	d1,previous_line_8
	bsr	precalc_multiples
	bsr	cls
	movem.l	(sp)+,d0-d7/a0-a6
	bra	no_avi_file
.no_resize_screen:
	move.l	org_adr(pc),log_adr
	Setscreen	log_adr(pc),log_adr(pc),#-1
	clr.w	pos_scroll_x
	clr.w	pos_scroll_y
	clr.w	max_scroll_x
	clr.w	max_scroll_y
	clr.b	scroll_flag
	move.w	width(pc),d0
	sub.w	phys_x(pc),d0
	ble.s	.ok_max_scroll_x
	move.w	d0,max_scroll_x
	send_kbd	#$8
.ok_max_scroll_x:
	move.w	height(pc),d0
	sub.w	phys_y(pc),d0
	ble.s	.ok_max_scroll_y
	move.w	d0,max_scroll_y
	send_kbd	#$8
.ok_max_scroll_y:	
	move.l	16(a0),d0		; Nb d'images
	IM.l	d0
	move.l	d0,nb_frame			
	bra	.no_list2
.no_avih:
	cmp.l	#'LIST',d0		; Une autre LISTe alors ??
	bne	.no_list2		; Non
	Fread	handle(pc),#4,list_type2(pc)
	subq.l	#4,id_size
	addq.l	#4,list_counter
	cmp.l	#'strl',list_type2	; Une strl ??
	bne	.no_list2		; Non
	move.l	#4,list2_counter
..loop_strl:
	move.l	id_size(pc),d0
	move.l	list2_counter(pc),d1
	addq.l	#4,d0
	cmp.l	d0,d1
	bge	..end_loop_list2
	Fread	handle(pc),#8,id_type2(pc)
	addq.l	#8,list2_counter
	move.l	id_size2(pc),d0
	IM.l	d0
	move.l	d0,id_size2
	move.l	id_type2(pc),d0
	cmp.l	#'strh',d0
	bne	..no_strh
	move.l	id_size2(pc),d0
*	cmp.l	#$38,d0
*	blt	no_avi_file
	Fread	handle(pc),#$38,little_buffer(pc)
	sub.l	#$38,id_size2
	add.l	#$38,list2_counter
	clr.w	strf_flag_vids
	clr.w	strf_flag_auds
	cmp.l	#'vids',little_buffer
	bne.s	..no_vids
	move.w	#1,strf_flag_vids
	tst.w	auds_yet(pc)
	beq	..no_strf
	move.w	#'01',vids_stream
	move.w	#'00',auds_stream
	bra	..no_strf
..no_vids:
	cmp.l	#'auds',little_buffer
	bne.s	..no_auds
	move.w	#1,strf_flag_auds
	move.w	#1,auds_yet
	clr.w	sound_disabled
	bra	..no_strf
..no_auds:
	bra	..no_strf
..no_strh:
	cmp.l	#'strf',d0
	bne	..no_strf
..vids_strf
	tst.w	strf_flag_vids(pc)
	beq	..auds_strf
	clr.w	strf_flag_vids
	move.l	id_size2(pc),d0
	cmp.l	#40,d0
	blt	no_avi_file
	Fread	handle(pc),#40,little_buffer(pc)
	sub.l	#40,id_size2
	add.l	#40,list2_counter
	lea	little_buffer(pc),a0
	move.l	(a0),d0
	IM.l	d0
	cmp.l	#40,d0
	blt	no_avi_file
	move.l	d0,(a0)
	sub.l	#40,d0
	Fseek	d0,handle(pc),#1
	lea	little_buffer(pc),a0
	move.l	(a0),d0
	sub.l	#40,d0
	sub.l	d0,id_size2
	add.l	d0,list2_counter
	move.l	4(a0),d0
	IM.l	d0
	move.w	d0,width
	move.w	d0,d7
*	cmp.w	width,d0
*	bne	no_avi_file
	move.l	8(a0),d0
	IM.l	d0
	move.w	d0,height
	mulu.w	d0,d7
	move.l	d7,size_unpck
*	cmp.w	height(pc),d0
*	bne	no_avi_file
	move.w	12(a0),d0	; Nb plan
	IM.w	d0
	cmp.w	#1,d0
	bne	no_avi_file
	move.w	14(a0),d0	; Nb bits/pixel
	IM.w	d0
	move.w	d0,nb_bits
	clr.w	flag_2_bits
	clr.w	flag_4_bits
	clr.w	flag_16_bits
	clr.w	flag_24_bits
	clr.w	flag_32_bits
	cmp.w	#8,d0
	beq.s	...end_tst_nb_bits
	cmp.w	#1,d0
	seq	flag_2_bits
	beq.s	...end_tst_nb_bits
	cmp.w	#4,d0
	seq	flag_4_bits
	beq.s	...end_tst_nb_bits
	cmp.w	#16,d0
	seq	flag_16_bits
	beq.s	...end_tst_nb_bits
	cmp.w	#24,d0
	seq	flag_24_bits
	beq.s	...end_tst_nb_bits
	cmp.w	#32,d0
	seq	flag_32_bits
	bne	no_avi_file
...end_tst_nb_bits:
	move.l	16(a0),compressed
	move.l	20(a0),d0
	IM.l	d0
	move.l	d0,size_unpck2
	tst.w	flag_16_bits(pc)
	bne	..no_strf
	tst.w	flag_24_bits(pc)
	bne	..no_strf
	tst.w	flag_32_bits(pc)
	bne	..no_strf
	move.l	32(a0),d0
	IM.l	d0
	cmp.l	#256,d0
	bgt	no_avi_file
	move.w	d0,nb_color
;	move.l	36(a0),d1
;	IML	d1
;	cmp.l	#256,d1
;	bgt	no_avi_file
;	move.w	d1,start_color
	lea	palette_256(pc),a0
;	lea	(a0,d1.w*4),a0
	lsl.w	#2,d0
	Fread	handle(pc),d0,(a0)
	moveq	#0,d0
	move.w	nb_color(pc),d0
	lsl.w	#2,d0
	sub.l	d0,id_size2
	add.l	d0,list2_counter
	lea	palette_256(pc),a0
	lea	palette_tc(pc),a1
	lea	save_palette_tc(pc),a2
	move.w	#256-1,d6
..loop_color_convert:
	move.b	(a0)+,d3	; Attention : format Microsoft
	move.b	(a0)+,d2	; … la con
	move.b	(a0)+,d1	; B V R X ( 4 octets )
	addq.l	#1,a0		; Que l'on va convertir en True Color
	lsr.w	#3,d1
	lsr.w	#2,d2		
	lsr.w	#3,d3
	bfins	d1,d4{16:5}	; Eh oui, ces instructions existent !
	bfins	d2,d4{21:6}	; Dingue hein !!!
	bfins	d3,d4{27:5}
	move.w	d4,(a1)+
	move.w	d4,(a2)+
	dbf	d6,..loop_color_convert
	bra	..no_strf
..auds_strf:
	tst.w	strf_flag_auds(pc)
	beq	..no_strf
	clr.w	strf_flag_auds
	move.l	id_size2(pc),d0
	cmp.l	#16,d0
	blt	no_avi_file
	Fread	handle(pc),#16,little_buffer(pc)
	sub.l	#16,id_size2
	add.l	#16,list2_counter
	lea	little_buffer(pc),a0
	move.w	12(a0),d0
	IM.w	d0
	move.w	d0,block_align
	move.w	(a0),d0
	move.w	14(a0),d2
	lea	audio_compression_test(pc),a5
..loop_test:
	move.w	(a5)+,d1
	bmi.s	..not_recognized
	move.w	(a5)+,d3
	addq.w	#4,a5
	cmp.w	d0,d1
	bne.s	..loop_test
	cmp.w	d2,d3
	bne.s	..loop_test
	move.l	-4(a5),adr_resampling_routs
	bra.s	..not_packed
..not_recognized:
	move.w	#1,sound_disabled
..not_packed:
	move.w	2(a0),d0	; Nb canaux
	IM.w	d0
	moveq	#0,d2
	clr.w	stereo_flag
	IFNE	STFA
	tst.w	stfa(pc)
	beq.s	..no_stfa1
	move.l	stfa_control(pc),a6
	clr.w	2(a6)
	IFNE	STFA_OUTPUT
	cmp.w	#4,STFA_output	; Yamaha STF ??
	bne.s	..ok_stfa_output
	clr.w	STFA_output
..ok_stfa_output:
	move.w	STFA_output(pc),4(a6)
	ENDC
..no_stfa1:
	ENDC
	cmp.w	#1,d0
	beq.s	..okay_mono
	move.w	#1,stereo_flag
	move.b	#%10000000,d2
	IFNE	STFA
	tst.w	stfa(pc)
	beq.s	..no_stfa2
	or.w	#$4000,2(a6)
..no_stfa2:
	ENDC
	cmp.w	#2,d0
	beq.s	..okay_mono
	move.w	#1,sound_disabled
..okay_mono:
	move.l	4(a0),d0	; Frequence
	IM.l	d0
	IFNE	STFA
	tst.w	stfa(pc)
	beq.s	..no_stfa3
	move.b	#$05,2+1(a6)	; 11025 Hz
..no_stfa3:
	tst.w	stfa(pc)
	beq.s	..no_stfa4
	move.b	#$0a,2+1(a6)	; 22050 Hz
	move.b	#$05,2+1(a6)	; 11025 Hz
	or.w	#$0400,2(a6)	; 2X ( on gagne du temps !! )
..no_stfa4:
	tst.w	stfa(pc)
	beq.s	..no_stfa5
	move.b	#$0e,2+1(a6)	; 44100 Hz
	move.b	#$0a,2+1(a6)	; 22050 Hz
	or.w	#$0400,2(a6)	; 2X
..no_stfa5:
	tst.w	stfa(pc)
	beq.s	..no_stfa5bis
	move.w	#1,sound_disabled
	bra.s	..okay_freq
..no_stfa5bis:
	ENDC
	cmp.l	#BASE_FREQ,d0
	bgt.s	..disable_sound
	cmp.l	#BASE_FREQ/8,d0
	bgt.s	..calc_freq
..disable_sound:
	move.w	#1,sound_disabled
	bra.s	..okay_freq	
..calc_freq:
	move.l	#BASE_FREQ/4,d7	; 12500
	cmp.l	#BASE_FREQ/4,d0
	bgt.s	..next_freq
	move.b	#%10000001,d1	; Mono … 11025 Hz
	bra.s	..calc_resample_spd
..next_freq:
	add.l	d7,d7		; 25000
	cmp.l	#BASE_FREQ/2,d0
	bgt.s	..next_freq2
	move.b	#%10000010,d1	; Mono … 22050 Hz
	bra.s	..calc_resample_spd
..next_freq2:
	add.l	d7,d7		; 50000
	move.b	#%10000011,d1	; Mono … 44100 Hz
..calc_resample_spd:
	eor.b	d2,d1
	move.b	d1,dma_sound_control
	lsl.l	#8,d0		; freq*256
	divu.w	d7,d0		; freq/real_freq
	clr.l	d1
	swap	d0
	move.w	d0,d1		; le reste
	swap	d0
	add.l	d1,d1
	cmp.l	d7,d1
	blt.s	..no_carry
	addq.w	#1,d0
..no_carry:	
	cmp.w	#128,d0
	bge.s	..okay_resample_spd
	move.w	#128,d0
..okay_resample_spd:	
	move.w	d0,resample_speed
	move.w	#255,d1
	sub.w	d0,d1
	move.w	d1,resample_speed2	
..okay_freq:
	move.w	14(a0),d0	; Nb bits
	IM.w	d0
	clr.w	son_4_bits
	clr.w	son_16_bits
	cmp.w	#8,d0
	beq.s	..no_strf
;	IFNE	STFA
;	tst.w	stfa(pc)
;	beq.s	..no_stfa6
;	move.w	#1,sound_disabled
;..no_stfa6:
;	ENDC
	cmp.w	#4,d0
	seq	son_4_bits
	beq.s	..no_strf
	cmp.w	#16,d0
	seq	son_16_bits
	bne.s	..sound_error
	IFNE	STFA
	tst.w	stfa(pc)
	beq.s	..no_strf
	cmp.w	#$102,18(a6)	; test nø version STFA
;	bra.s	..sound_error
	blt.s	..sound_error
	or.w	#$a200,2(a6)	; 16 bits Intel sign‚ !!
	ENDC
	bra.s	..no_strf
..sound_error:
	move.w	#1,sound_disabled
..no_strf:
	Fseek	id_size2(pc),handle(pc),#1
	move.l	id_size2(pc),d0
	add.l	d0,list2_counter
	and.l	#1,d0
	add.l	d0,list_counter
	Fseek	d0,handle(pc),#1
	bra	..loop_strl
..end_loop_list2:
	move.l	list2_counter(pc),d0
	subq.l	#4,d0
	add.l	d0,list_counter
	sub.l	d0,id_size
.no_list2:
	tst.l	id_size(pc)
	bpl.s	..no_clr
	clr.l	id_size
..no_clr:
	Fseek	id_size(pc),handle(pc),#1
	move.l	id_size(pc),d0
	add.l	d0,list_counter
	and.l	#1,d0
	add.l	d0,list_counter
	Fseek	d0,handle(pc),#1
	bra	.loop_header
.end_loop_header:
	clr.l	chunk_size
search_movi_list:
	Fseek	#0,handle(pc),#1	;
	and.w	#1,d0			;
	beq.s	.add_nothing		;
	Fseek	#1,handle(pc),#1	;
.add_nothing:
	Fseek	chunk_size(pc),handle(pc),#1
	tst.l	d0
	blt	no_avi_file
	Fread	handle(pc),#8,chunk_type(pc)
	move.l	chunk_size(pc),d0
	IM.l	d0
	move.l	d0,chunk_size
	move.l	d0,movi_list_size
	cmp.l	#'LIST',chunk_type
	bne	search_movi_list
	Fread	handle(pc),#4,list_type(pc)
	subq.l	#4,chunk_size
	cmp.l	#'movi',list_type	; Gagn‚ !! On cherche la
	bne	search_movi_list	; vid‚o !!!
; on a trouv‚ la "movi list" :
	Fseek	#0,handle(pc),#1
	move.l	d0,offset_debut
	clr.l	offset_affichage
	move.w	width(pc),d0		; On joue centr‚e l'anim
	move.w	phys_x(pc),d1		; Sympa non ??
	clr.w	offset_x
	sub.w	d0,d1
	blt.s	.ok_offset_x
	and.w	#$fffc,d1
	move.w	d1,offset_x		; Offset x en octets
.ok_offset_x:
	move.w	height(pc),d0
	move.w	phys_y(pc),d1
	clr.w	offset_y
	sub.w	d0,d1
	ble.s	.ok_offset_y
	move.w	new_mode(pc),d7
	move.w	vco_save(pc),d6
	move.w	vdb_save(pc),d5
	move.w	vde_save(pc),d4
	moveq	#1,d3
	lsl.w	d0
	btst.l	#4,d7
	bne.s	.vga_offset
.tv_offset:
	btst.l	#1,d6
	beq.s	.centre_y
	lsr.w	d1
	lsr.w	d0
	clr.w	d3
	bra.s	.centre_y	
.vga_offset:
	btst.l	#0,d6
	beq.s	.centre_y
	lsl.w	d1
	lsl.w	d0
.centre_y:
	tst.w	d1
	beq.s	.ok_offset_y
	add.w	d1,d5
	subq.w	#1,d5
	and.w	#$fffe,d5
	add.w	d3,d5
	move.w	d5,d4
	add.w	d0,d4
	addq.w	#1,d4
	and.w	#$fffe,d4
	sub.w	d3,d4
	move.w	d5,$ffff82a8.w
	move.w	d5,$ffff82a6.w
	move.w	d4,$ffff82aa.w
	move.w	d4,$ffff82a4.w
;	lsr.w	#1,d1
;	move.w	d1,offset_y	
;	move.w	size_one_line(pc),d2
;	mulu.w	d2,d1			; Argh : un horrible MULU
;	move.l	d1,offset_affichage
.ok_offset_y:
	move.l	old_adr_scr(pc),adr_scr
	move.l	offset_affichage(pc),d1
	add.l	d1,adr_scr
	
	moveq	#0,d7
	move.l	adr_resampling_routs(pc),a6
	tst.w	fast_resampling(pc)
	beq.s	.cook_smp_routs
	addq.w	#8,a6
.cook_smp_routs:
	tst.w	son_16_bits(pc)
	beq.s	.ok_nb_bits
	bset.b	#6,dma_sound_control
	bclr.b	#7,dma_sound_control
.ok_nb_bits:
	tst.w	stereo_flag(pc)
	beq.s	.ok_nb_chn
	addq.w	#4,a6
.ok_nb_chn:
	move.l	(a6),resampling_sub
	
	move.l	#dummy_rout,d1
	move.l	compressed(pc),d0
	tst.w	flag_2_bits(pc)
	bne	.pck_all_2_bits
	tst.w	flag_4_bits(pc)
	bne	.pck_all_4_bits
	tst.w	flag_16_bits(pc)
	bne	.pck_all_16_bits
	tst.w	flag_24_bits(pc)
	bne	.pck_all_24_bits
	tst.w	flag_32_bits(pc)
	bne	.pck_all_32_bits
.pck_all_8_bits:
	cmp.l	#$01000000,d0
	bne.s	..no_rle8
	move.l	#rle8,d1
..no_rle8:
	tst.l	d0
	bne.s	..no_rgb8
	move.l	#switch_8_bits,d1
..no_rgb8:
	cmp.l	#'AFLC',d0
	bne.s	..no_aflc
	move.l	#autodesk,d1
..no_aflc:
	cmp.l	#'AFLI',d0
	bne.s	..no_afli
	move.l	#autodesk,d1
..no_afli:
	cmp.l	#'CRAM',d0
	bne.s	..no_cram8
	move.l	#microsoft_video_8,d1
..no_cram8:
	cmp.l	#'MSVC',d0
	bne.s	..no_msvc8
	move.l	#microsoft_video_8,d1
..no_msvc8:
	cmp.l	#'WHAM',d0
	bne.s	..no_wham8
	move.l	#microsoft_video_8,d1
..no_wham8:
	bra	.end_pck_all	
.pck_all_2_bits:
	tst.l	d0
	bne.s	..no_rgb2
	move.l	#rgb2,d1
..no_rgb2:
	bra	.end_pck_all
.pck_all_4_bits:
	tst.l	d0
	bne.s	..no_rgb4
	move.l	#rgb4,d1
..no_rgb4:
	bra	.end_pck_all
.pck_all_16_bits:
	tst.l	d0
	bne.s	..no_rgb16
	move.l	#rgb16,d1
..no_rgb16:
	cmp.l	#'CRAM',d0
	bne.s	..no_cram16
	move.l	#microsoft_video_16,d1
..no_cram16:
	cmp.l	#'MSVC',d0
	bne.s	..no_msvc16
	move.l	#microsoft_video_16,d1
..no_msvc16:
	cmp.l	#'WHAM',d0
	bne.s	..no_wham16
	move.l	#microsoft_video_16,d1
..no_wham16:
	bra	.end_pck_all
.pck_all_24_bits:
	tst.l	d0
	bne.s	..no_rgb24
	move.l	#rgb24,d1
..no_rgb24:
	cmp.l	#'cvid',d0
	bne.s	..no_cvid
	move.l	#cinepak,d1
..no_cvid:
	cmp.l	#'YVU9',d0
	beq.s	..yvu9
	cmp.l	#'yvu9',d0
	bne.s	..no_yvu9
..yvu9:
	move.l	#indeoraw,d1
..no_yvu9:
	
	IFNE	INDEO
	include	'modules.s'
	cmp.l	#'ir31',d0
	beq.s	..iv32
	cmp.l	#'IR31',d0
	beq.s	..iv32
	cmp.l	#'iv31',d0
	beq.s	..iv32
	cmp.l	#'IV31',d0
	beq.s	..iv32
	cmp.l	#'ir32',d0
	beq.s	..iv32
	cmp.l	#'IR32',d0
	beq.s	..iv32
	cmp.l	#'iv32',d0
	beq.s	..iv32
	cmp.l	#'IV32',d0
	bne.s	..no_iv32
..iv32
	movem.l	d0-d3/a0-a3,-(sp)
* place les paramŠtres pour le module
	lea	parametres_codec(pc),a3
	clr.l	info_init_codec.chemin_application(a3)
	clr.l	info_init_codec.adr_recherche_precalc(a3)
	clr.l	info_init_codec.adr_mem_alloc(a3)
	clr.l	info_init_codec.adr_libere_precalc(a3)
	clr.l	info_init_codec.adr_erreur_survenue(a3)
	clr.l	info_init_codec.type(a3)
	move.l	compressed(pc),info_init_codec.compression(a3)
	move.w	#24,info_init_codec.bits_par_pixel(a3)
	move.w	width(pc),info_init_codec.largeur(a3)
	move.w	height(pc),info_init_codec.hauteur(a3)
	move.l	adr_scr(pc),a0
	add.w	offset_x(pc),a0
	move.l	a0,info_init_codec.adr_ecran_centre(a3)
	move.w	max_x(pc),info_init_codec.x_ecran(a3)
	move.w	max_y(pc),info_init_codec.y_ecran(a3)
	clr.l	info_init_codec.adr_palette(a3)
	move.l	a3,a0
	moveq	#info_init_codec.video_sizeof,d0
	jsr	init_iv32
	tst.l	d0
	bmi.s	.pb_iv32
	movem.l	(sp)+,d0-d3/a0-a3
	move.l	#indeo_iv32,d1
	bra.s	.end_pck_all
.pb_iv32
	movem.l	(sp)+,d0-d3/a0-a3
	clr.l	d1
..no_iv32:
	ENDC

	bra.s	.end_pck_all
.pck_all_32_bits:
	tst.l	d0
	bne.s	..no_rgb32
	move.l	#rgb32,d1
..no_rgb32:

.end_pck_all:
	move.l	d1,decoding_rout
	
	clr.w	play_sound_flag
	move.w	sound_lock_flag(pc),d0
	beq.s	play_avi_loop
	not.w	play_sound_flag
play_avi_loop:
	tst.w	sound_lock_flag(pc)
	beq.s	.no_wait_sound
	IFNE	STFA
	tst.w	stfa(pc)
	bne.s	.stfa7
	ENDC
	clr.w	$ffff8900.w
	move.b	dma_sound_control(pc),$ffff8921.w
*	clr.w	d0
*	move.b	dma_sound_control(pc),d0
*	lsr.b	#6,d0
*	Setmode	d0
*	move.b	dma_sound_control(pc),d0
*	and.w	#%11,d0
*	Soundcmd	#6,d0
	IFNE	STFA
	bra.s	.no_stfa7
.stfa7:
	move.l	stfa_control(pc),a2
	clr.w	(a2)	
.no_stfa7:
	ENDC
	clr.w	play_flag
	lea	start_audio_buffer1(pc),a0
	move.l	(a0),4(a0)
	move.l	12(a0),16(a0)
	move.l	12(a0),24(a0)
	move.l	12(a0),28(a0)
;	move.l	(a0)+,(a0)+
;	addq.l	#4,a0
;	move.l	(a0)+,(a0)
;	move.l	-(a0),12(a0)
;	add.w	#12,a0
;	move.l	(a0)+,(a0)	; 16 octets au lieu de 22. Apprends, petit scarab‚ !
	IFNE	CYCLE_IT
	clr.l	it_warten+4
	clr.l	it_warten
	ENDC
.no_wait_sound:
	moveq	#0,d0
	move.w	nb_timer(pc),d0
	move.l	$4ba.w,d1
	add.l	d0,d1
	move.l	d1,until_timer
	IFNE	FIRST_TST
	clr.w	first_img
	ENDC
	bsr	play_avi
	tst.w	sound_lock_flag(pc)
	beq.s	.no_cut_sound
	IFNE	STFA
	tst.w	stfa(pc)
	bne.s	.stfa8
	ENDC
	tst.l	d0
	bne.s	.cut_sound_dma
	clr.w	play_flag
.wait_for_sound1
	nop
	tst.b	$ffff8901.w
	bne.s	.wait_for_sound1
.cut_sound_dma:
	clr.b	$ffff8900.w
	IFNE	STFA
	bra.s	.no_stfa8
	tst.l	d0
	bne.s	.cut_sound_stfa
.stfa8:
	move.l	stfa_control(pc),a2
	bclr.b	#1,1(a2)
.wait_for_sound:
	btst.b	#0,1(a2)
	bne.s	.wait_for_sound
.cut_sound_stfa:
	bclr.b	#0,1(a2)
.no_stfa8:
	ENDC
.no_cut_sound:
	tst.w	play_once(pc)
	bne.s	to_end
	tst.l	d0
	bge.s	.no_wait_sound
to_end:
no_avi_file:
	Fclose	handle(pc)
	tst.w	slide_flag(pc)
	bne	boucle_slide
fin_prg:

	bsr	restore_tveil

	tst.w	sound_lock_flag(pc)
	beq	.kein_unlock
	IFNE	STFA
	tst.w	stfa(pc)
	bne	.stfa9
	ENDC
	Setinterrupt	#0,#0
	Setinterrupt	#1,#0
	Buffoper	#0
	Soundcmd	#ADDERIN,sound_adderin
	Soundcmd	#ADCINPUT,sound_adcinput
	Unlocksnd
	lea	mfp_save_buffer(pc),a0
	bclr.b	#7,$fffffa13.w
	bclr.b	#7,$fffffa07.w
	bclr.b	#7,$fffffa0b.w
	bclr.b	#7,$fffffa0f.w
	move.l	dma_it(pc),$13c.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa0b.w
	move.b	(a0)+,$fffffa0f.w
	move.b	(a0)+,$fffffa03.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa21.w
	move.b	(a0)+,d0
	and.b	#$fe,d0
	or.b	d0,$484.w
	move.l	timer_b(pc),$120.w
	IFNE	STFA
	bra.s	.no_stfa9
.stfa9:
	move.l	stfa_control(pc),a1
	clr.w	(a1)
.no_stfa9:
	ENDC
.kein_unlock:
	move.w	vde_save(pc),$ffff82aa.w
	move.w	vdb_save(pc),$ffff82a8.w
	move.w	vbb_save(pc),$ffff82a4.w
	move.w	vbe_save(pc),$ffff82a6.w
	clr.w	$ffff820e.w
	move.w	#$2700,sr
	move.l	old_vbl_it(pc),$4ce.w
	move.w	#$2300,sr
	Setscreen	phys_adr(pc),phys_adr(pc),#-1
	tst.l	virtual_screen(pc)
	beq.s	.kein_virtual
	Mfree	virtual_screen(pc)	
.kein_virtual:
	move.w	old_mode(pc),d0
	and.w	#%111,d0
	cmp.w	#TC,d0
	beq.s	.no_setscreen_2
	Setscreen	#0,#0,#3,old_mode(pc)
.no_setscreen_2:
	Vsync
	move.l	#$fcfc00fc,$ffff9800.w
	Vsync
	Kbdvbase
	move.l	d0,a0
	move.w	#$2700,sr
	move.l	old_mouse(pc),16(a0)
	move.w	#$2300,sr
	send_kbd	#$8
	move.l	sauve_cache(pc),d0
	movec	d0,cacr

	bsr	restore_nvdi
	
	Supers	super(pc)
	lea	old_dta(pc),a0
	Fsetdta	(a0)
	dc.w	$a009
************************************
	IFNE	TIME_TAKEN
write_it
	move.l	time_used(pc),d0
	lea	micro_buffer(pc),a1
	lea	micro_buffer_nombres(pc),a2
	moveq	#-1,d2			; d2 contient la longueur-1
	bsr.b	.d0_en_base_10_ascii
	bsr.b	.copie_buffer_en_inverse
	move.b	#'/',(a1)+
	clr.l	d0
	move.w	nb_frame_displayed(pc),d0
	lea	micro_buffer_nombres(pc),a2
	moveq	#-1,d2			; d2 contient la longueur-1
	bsr.b	.d0_en_base_10_ascii
	bsr.b	.copie_buffer_en_inverse
	clr.b	(a1)
	Cconws	micro_buffer(pc)
	Cnecin
	Pterm0
.d0_en_base_10_ascii
	divu.w	#10,d0
	swap	d0			; reste de la division
	add.b	#48,d0			; mise au format ascii
	move.b	d0,(a2)+		; on le met dans le buffer
	clr.w	d0			; pour eviter un overflow du divu.w
	addq.w	#1,d2			; on incr‚mente la longueur
	swap	d0			; quotient nul ? non -> on recommence!
	bne.s	.d0_en_base_10_ascii
	clr.b	(a2)			; octet de fin
	rts
.copie_buffer_en_inverse
	move.b	-(a2),(a1)+
	dbf	d2,.copie_buffer_en_inverse
	rts
micro_buffer:
	dcb.b	20,0			; micro-buffer pour les print_line
	even
micro_buffer_nombres:
	dcb.b	12,0			; micro-buffer pour les nombres en base 10
	even
	ELSE
************************************
	Pterm0
	ENDC
	
	BSS
vde_save:
	ds.w	1
vdb_save:
	ds.w	1
vbb_save:
	ds.w	1
vbe_save:
	ds.w	1
vco_save:
	ds.w	1
max_x:
	ds.w	1
max_y:
	ds.w	1
phys_x:
	ds.w	1
phys_y:
	ds.w	1
phys_adr:
	ds.l	1
virtual_screen:
	ds.l	1
max_scroll_x:
	ds.w	1
max_scroll_y:
	ds.w	1
pos_scroll_x:
	ds.w	1
pos_scroll_y:
	ds.w	1
log_adr:
	ds.l	1
org_adr:
	ds.l	1
scroll_flag:
	ds.w	1
mfp_save_buffer:
	ds.b	64
	even
dma_it:
	ds.l	1
timer_b:
	ds.l	1
phys_size:
	ds.l	1
first_file:
	ds.w	1
slide_flag:
	ds.w	1
play_once:
	ds.w	1
fast_resampling:
	ds.w	1
STFA_default:
	ds.w	1
nb_timer:
	ds.w	1
synchro:
	ds.w	1
synchro_th:
	ds.w	1
	IFNE	VIRGULE
reste_timer:
	ds.w	1
virgule_timer:
	ds.w	1
	ENDC
until_timer:
	ds.l	1
	TEXT
play_avi:
; Copie de la premiŠre palette comme palette courante
	lea	save_palette_tc(pc),a1
	lea	palette_tc(pc),a2
	move.w	#255,d0
.copy_pal:
	move.w	(a1)+,(a2)+
	dbf	d0,.copy_pal
; AVI-Black !!	
	move.l	adr_scr(pc),a1
	move.w	offset_x(pc),d4
	lea	0(a1,d4.w),a1
	lea	palette_tc(pc),a2
	lea	multiples(pc),a3
	move.w	width(pc),d1
	move.w	height(pc),d3
	bsr	avi_black	
; on se recale au d‚but de la movi list...
	Fseek	offset_debut(pc),handle(pc),#0
	move.l	#4,movi_list_counter
loop_frame:
	Fseek	#0,handle(pc),#1
	and.w	#1,d0
	beq.s	.add_nothing
	Fseek	#1,handle(pc),#1
	addq.l	#1,movi_list_counter
.add_nothing:
	move.l	movi_list_size(pc),d0
	move.l	movi_list_counter(pc),d1
	cmp.l	d0,d1
	bge	end_play
test_clavier
	Cconis
	tst.w	d0
	beq	pas_de_touche
	Crawcin
	cmp.b	#' ',d0
	bne.s	fin_non_demandee
	moveq	#-1,d0			; -1 pour arrˆter de jouer
	rts
fin_non_demandee:
.debut:
	cmp.b	#'.',d0
	bne.s	.vitesse_moins
	moveq	#1,d0
	rts
.vitesse_moins:
	lea	nb_timer(pc),a2
	cmp.b	#'-',d0
	bne.s	.vitesse_plus
	addq.w	#1,(a2)
	bra.s	test_clavier
.vitesse_plus:
	cmp.b	#'+',d0
	bne.s	.pause
	tst.w	(a2)
	ble.s	test_clavier
	subq.w	#1,(a2)
	bra.s	test_clavier
.pause:
	cmp.b	#'*',d0
	bne.s	.scroll_right
	Crawcin
	move.l	$4ba.w,until_timer
	bra.s	test_clavier
.scroll_right:
	cmp.b	#'6',d0
	bne.s	.scroll_left
	move.w	pos_scroll_x,d0
	addq.w	#2,d0
	cmp.w	max_scroll_x,d0
	bgt.s	test_clavier
	addq.w	#2,pos_scroll_x
	st	scroll_flag
	bra	test_clavier	
.scroll_left:
	cmp.b	#'4',d0
	bne.s	.scroll_down
	move.w	pos_scroll_x,d0
	subq.w	#2,d0
	blt	test_clavier
	subq.w	#2,pos_scroll_x
	st	scroll_flag
	bra	test_clavier
.scroll_down:
	cmp.b	#'2',d0
	bne.s	.scroll_up
	move.w	pos_scroll_y,d0
	addq.w	#1,d0
	cmp.w	max_scroll_y,d0
	bgt	test_clavier
	addq.w	#1,pos_scroll_y
	st	scroll_flag
	bra	test_clavier	
.scroll_up:
	cmp.b	#'8',d0
	bne.s	.max_toggle
	move.w	pos_scroll_y,d0
	subq.w	#1,d0
	blt	test_clavier
	subq.w	#1,pos_scroll_y
	st	scroll_flag
	bra	test_clavier
.max_toggle:
	cmp.b	#'m',d0
	bne.s	.sound
	not.w	synchro
	beq	test_clavier	; ‚tait-on avant en max-speed ??
	move.l	$4ba.w,until_timer
	move.w	synchro_th(pc),nb_timer
	bra	test_clavier
.sound:
	cmp.b	#'s',d0
	bne	test_clavier
	tst.w	sound_lock_flag(pc)
	beq	test_clavier
	IFNE	STFA
	tst.w	stfa(pc)
	bne.s	.stfa_stop
	ENDC
	clr.w	play_flag
	clr.w	$ffff8900.w
	IFNE	CYCLE_IT
	clr.l	it_warten
	clr.l	it_warten+4
	ENDC
	IFNE	STFA
	bra.s	.ok_stop
.stfa_stop:
	move.l	stfa_control(pc),a6
	clr.w	(a6)
.ok_stop:
	ENDC
	not.w	play_sound_flag
	lea	start_audio_buffer1(pc),a0
;	move.l	(a0),4(a0)
	move.l	(a0)+,(a0)+
	addq.w	#4,a0
;	move.l	12(a0),16(a0)
	move.l	(a0)+,(a0)
;	move.l	12(a0),24(a0)
	move.l	-(a0),12(a0)	; 10 octets au lieu de 16. Apprends, petit scarab‚ !
pas_de_touche:
;	tst.b	scroll_flag(pc)
;	beq.s	no_scroll
;	sf	scroll_flag
;	move.w	pos_scroll_x(pc),d0
;	move.w	pos_scroll_y(pc),d1
;	lea	multiples(pc),a0
;	move.l	(a0,d1.w*4),d1
;	move.l	org_adr(pc),a0
;	lea	(a0,d0.w*2),a0
;	add.l	d1,a0
;	move.l	a0,log_adr
;	Setscreen	a0,a0,#-1
*	Setscreen	log_adr(pc),log_adr(pc),#-1
no_scroll:
	clr.l	chunk_size
.loop_search_list:
	move.l	chunk_size(pc),d0	; Faire gaffe : on ne doit
	moveq	#1,d1			; jamais avoir un enregistrement
	and.l	d0,d1
	add.l	d1,chunk_size		; … un offset impair !!!!!
	Fseek	chunk_size(pc),handle(pc),#1
	move.l	chunk_size(pc),d0
	add.l	d0,movi_list_counter
	Fread	handle(pc),#8,chunk_type(pc)
	addq.l	#8,movi_list_counter
	move.l	chunk_size(pc),d0
	IM.l	d0
	move.l	d0,chunk_size
	move.l	chunk_type(pc),d0
	cmp.l	#'LIST',d0		; Une LISTe ??
	beq.s	.okay_list_rec		; Oui => on continue
.tst_direct_record:
	; on n'a pas une liste. On teste donc si on a une image
	; directement ins‚r‚e dans la "movi LIST"
	tst.l	chunk_size(pc)
	beq	loop_analyse_record
	cmp.w	#'wb',d0
	bne.s	.no_wav
	swap	d0
	cmp.w	auds_stream(pc),d0
	beq.s	.okay_direct_record
	swap	d0
.no_wav:
	swap	d0
	cmp.w	vids_stream(pc),d0
	bne	.loop_search_list
.okay_direct_record:
	Fseek	#-8,handle(pc),#1
	clr.l	list_counter
	bra.s	analyse_record_list
.okay_list_rec:
	Fread	handle(pc),#4,list_type(pc)
	addq.l	#4,movi_list_counter
	cmp.l	#'rec ',list_type	; Un enregistrement ?
	beq.s	.ok_record
	moveq	#-1,d0			; Non -> On sort
	rts				; ( on sait d‚j… que c'est pas une image )
.ok_record:
	move.l	#4,list_counter
analyse_record_list:
	move.l	chunk_size(pc),d0	; est-on arriv‚ au bout de la LIST
	move.l	list_counter(pc),d1	; ( ou du chunk "direct record" de la
	cmp.l	d0,d1			; "movi" list )
	bge	end_analyse_record	; oui -> on se casse
	Fread	handle(pc),#8,id_type(pc)
	addq.l	#8,list_counter
	move.l	id_size(pc),d0		; La taille ( tjs INTEL )
	IM.l	d0
	move.l	d0,id_size
;	beq.s	loop_analyse_record
	addq.l	#8,d0
	add.l	d0,movi_list_counter
	move.l	id_type(pc),d0
	cmp.w	#'wb',d0
	bne.s	.no_wav
	swap	d0
	cmp.w	auds_stream(pc),d0
	beq	wave_sound
	swap	d0
.no_wav:
	move.l	d0,d7
	swap	d0
	cmp.w	vids_stream(pc),d0
	beq.s	pck_all
loop_analyse_record:
	move.l	id_size(pc),d0
	btst.l	#0,d0
	beq.s	no_impair
	addq.l	#1,d0
	addq.l	#1,movi_list_counter
	move.l	d0,id_size
no_impair:
	Fseek	id_size(pc),handle(pc),#1
	move.l	id_size(pc),d0
	add.l	d0,list_counter
	bra	analyse_record_list
end_analyse_record:
	bra	loop_frame
end_play:
	moveq	#0,d0			; 0 pour continuer de jouer
	rts
	
not_enough_memory:
	bra.s	loop_analyse_record

	BSS
real_adr_buffer:
	ds.l	1
buffer_size:
	ds.l	1
decoding_rout:
	ds.l	1
	TEXT

pck_all:
	move.l	id_size(pc),d1
	ble.s	loop_analyse_record
	addq.l	#4,d1
	cmp.l	buffer_size(pc),d1
	ble.s	.no_malloc
	move.l	d1,-(sp)
	move.l	real_adr_buffer(pc),d0
	beq.s	.no_mfree
	Mfree	d0
	clr.l	real_adr_buffer
.no_mfree:
	move.l	(sp),d1
	Mxalloc	d1,#3
	move.l	(sp)+,d1
	tst.l	d0
	beq.s	not_enough_memory
	move.l	d0,real_adr_buffer
.no_malloc:
	move.l	real_adr_buffer(pc),d0
	subq.l	#4,d1
	addq.l	#3,d0
	and.w	#$fffc,d0
	move.l	d0,adr_buffer
	move.l	d0,a0
	move.l	d1,-(sp)
	move.l	a0,-(sp)
	Fread	handle(pc),d1,(a0)
	cmp.l	4(sp),d0
	blt	to_end_play
; Temporisation
	cmp.w	#'pc',d7
	beq.s	.no_synchro
	IFNE	FIRST_TST
.tst_first_img:
	tst.w	first_img(pc)
	bne.s	.not_first
	not.w	first_img
	movem.l	d6-d7/a0/a6,-(sp)
	lea	dma_sound_control(pc),a0
	lea	$ffff8900.w,a6
	movem.l	24(a0),d6-d7
	cmp.l	d6,d7
	ble.s	.kein_first_sound
	movep.l	d6,$1(a6)
	movep.l	d7,$d(a6)
	move.l	d7,24(a0)
	move.w	#$ffff,play_flag
	move.w	#$0101,(a6)
.kein_first_sound:
	movem.l	(sp)+,d6-d7/a0/a6
	move.l	$4ba.w,until_timer
.not_first:		
	ENDC
	moveq	#0,d0
	move.w	nb_timer(pc),d0
	IFNE	VIRGULE
	move.w	reste_timer(pc),d2
	add.w	virgule_timer(pc),d2
.tst_carry:
	cmp.w	#TIMING,d2
	blt.s	.no_carry
	addq.l	#1,d0
	sub.w	#TIMING,d2
	bra.s	.tst_carry
.no_carry:
	move.w	d2,virgule_timer
	ENDC
	move.l	until_timer,d1
	tst.w	synchro(pc)
	beq.s	.no_wait
.wait:
	cmp.l	$4ba.w,d1
	bge.s	.wait
.no_wait:
	add.l	d0,d1
	move.l	d1,until_timer
.no_synchro:
	IFNE	TEST_TIME_UNPACK
	Vsync		; pas besoin de sauver les registres : ils le sont d‚j…
	move.w	#$ff0f,$ffff9800.w
	ENDC
	IFNE	TIME_TAKEN
	move.l	$4ba.w,d0
	sub.l	d0,time_used
	ENDC
	move.l	(sp)+,a2		; adr buffer o— qu'on a charg‚ le chunk
	move.l	(sp)+,d1		; taille de ce dernier
	add.l	d1,list_counter
	cmp.w	#'pc',d7
	beq	chunk_pc

	tst.l	decoding_rout
	beq.s	end_pck_all
	jsr	([decoding_rout])
	
end_pck_all:
	IFNE	TEST_TIME_UNPACK
	clr.w	$ffff9800.w
	ENDC
	IFNE	TIME_TAKEN
	move.l	$4ba.w,d0
	add.l	d0,time_used
	addq.w	#1,nb_frame_displayed
	ENDC
	move.l	id_size(pc),d0
	and.l	#1,d0
	add.l	d0,movi_list_counter
	add.l	d0,list_counter
	Fseek	d0,handle(pc),#1
	clr.l	id_size
	bra	loop_analyse_record

to_end_play:
	move.l	(sp)+,a2		; adr buffer o— qu'on a charg‚ le chunk
	move.l	(sp)+,d1		; taille de ce dernier
	bra	end_play

dummy_rout:
	rts

switch_8_bits:
	move.l	#rle8,decoding_rout
	cmp.w	#'dc',d7
	beq.s	rle8
	move.l	#rgb8,decoding_rout
	bra.s	rgb8
	
rle8:
	move.l	a2,a0
	move.l	adr_scr(pc),a1
	move.w	offset_x(pc),d4
	lea	0(a1,d4.w),a1
	lea	palette_tc(pc),a2
	lea	multiples(pc),a3
	move.l	id_size(pc),d0
	move.w	width(pc),d1
	move.w	height(pc),d3
	bra	decompresse_rle8
	
rgb8:
	move.l	a2,a0
	move.l	adr_scr(pc),a1
	move.w	offset_x(pc),d4
	lea	0(a1,d4.w),a1
	lea	palette_tc(pc),a2
	lea	multiples(pc),a3
	move.l	id_size(pc),d0
	move.w	width(pc),d1
	move.w	height(pc),d2
	bra	decompresse_rgb8
	
chunk_pc:
	move.l	a2,a0
	lea	palette_tc(pc),a2
	bsr	palette_change
	bra	end_pck_all

microsoft_video_8:
	move.w	size_one_line(pc),d0
	move.w	d0,d2
	lea	passe_ligne_cram+4(pc),a0
	move.w	d0,-(a0)	; taille ligne
	lsl.w	#2,d0
	move.w	width(pc),d3
	add.w	d3,d0
	add.w	d3,d0		; passe_ligne
	move.w	d0,-(a0)
	lsr.w	#2,d3
	move.w	d3,nb_blocs_par_ligne
	move.w	height(pc),d3
	subq.w	#1,d3
	mulu.w	d3,d2		; (height-1)*taille_ligne
	move.l	d2,a0
	add.l	adr_scr(pc),a0
	add.w	offset_x(pc),a0
	move.l	a0,fin_ecran
	move.l	a2,a0
	move.l	d1,d0
bug	jmp	decompresse_cram8

autodesk:
	move.l	a2,a0
	move.l	adr_scr(pc),a1
	move.w	offset_x(pc),d4
	lea	0(a1,d4.w),a1
	lea	palette_tc(pc),a2
	lea	multiples(pc),a3
	move.l	id_size(pc),d0
	move.w	width(pc),d1
	move.w	height(pc),d3
	bra	decompresse_flc

rgb2:
	move.l	a2,a0
	move.l	adr_scr(pc),a1
	move.w	offset_x(pc),d4
	lea	0(a1,d4.w),a1
	lea	palette_tc(pc),a2
	lea	multiples(pc),a3
	move.l	id_size(pc),d0
	move.w	width(pc),d1
	move.w	height(pc),d2
	bra	decompresse_rgb2
	
rgb4:
	move.l	a2,a0
	move.l	adr_scr(pc),a1
	move.w	offset_x(pc),d4
	lea	0(a1,d4.w),a1
	lea	palette_tc(pc),a2
	lea	multiples(pc),a3
	move.l	id_size(pc),d0
	move.w	width(pc),d1
	move.w	height(pc),d2
	bra	decompresse_rgb4
	
rgb16:
	move.l	a2,a0
	move.l	adr_scr(pc),a1
	move.w	offset_x(pc),d4
	lea	0(a1,d4.w),a1
	move.l	#precalc_cram16,a2
	lea	multiples(pc),a3
	move.l	size_unpck(pc),d0
	add.l	d0,d0
	cmp.l	id_size(pc),d0
	bgt.s	.end_rgb16
	move.w	width(pc),d1
	move.w	height(pc),d2
	bra	decompresse_rgb16
.end_rgb16:
	rts

microsoft_video_16:
	move.w	size_one_line(pc),d0
	move.w	d0,d2
	lea	passe_ligne_cram+4(pc),a0
	move.w	d0,-(a0)	; taille ligne
	lsl.w	#2,d0
	move.w	width(pc),d3
	add.w	d3,d0
	add.w	d3,d0		; passe_ligne (4*taille_ligne+2*largeur_anim)
	move.w	d0,-(a0)
	move.w	height(pc),d3
	subq.w	#1,d3
	mulu.w	d3,d2		; (height-1)*taille_ligne
	move.l	d2,a0
	add.l	adr_scr(pc),a0
	add.w	offset_x(pc),a0
	move.l	a0,fin_ecran
	move.l	a2,a0
	move.l	d1,d0
_bug	jmp	decompresse_cram16

rgb24:
	move.l	a2,a0
	move.l	adr_scr(pc),a1
	move.w	offset_x(pc),d4
	lea	0(a1,d4.w),a1
	lea	multiples(pc),a3
	move.l	size_unpck(pc),d0
	add.l	d0,d0
	add.l	size_unpck(pc),d0
	cmp.l	id_size(pc),d0
	bgt.s	.end_rgb24
	move.w	width(pc),d1
	move.w	height(pc),d2
	bra	decompresse_rgb24
.end_rgb24:
	rts
	
cinepak:
	move.w	size_one_line(pc),d0
	lea	taille_ligne+2(pc),a0
	move.w	d0,-(a0)
	lsl.w	#2,d0
	move.w	d0,-(a0)
	move.l	adr_scr(pc),a0
	add.w	offset_x(pc),a0
	move.l	a0,ecran
	move.l	a2,a0
	move.l	id_size(pc),d0
	bra	decompresse_cvid

indeoraw:
	move.w	size_one_line(pc),d0
	lea	taille_ligne(pc),a0
	move.w	d0,(a0)		; taille ligne
	lsl.w	#2,d0
	move.w	width(pc),d3
	sub.w	d3,d0
	sub.w	d3,d0		; passe_ligne
	move.w	d0,-(a0)
	move.w	height(pc),d2
	mulu.w	d3,d2		; height*width
	move.l	d2,taille_image_utile
	move.l	adr_scr(pc),a0
	add.w	offset_x(pc),a0
	move.l	a0,ecran
	move.l	a2,a0
	move.l	d1,d0
	bra	decompresse_yvu9

	IFNE	INDEO
indeo_iv32
	move.l	a2,a0
	move.l	d1,d0
	bra	decode_iv32
	ENDC

rgb32:
	move.l	a2,a0
	move.l	adr_scr(pc),a1
	move.w	offset_x(pc),d4
	lea	0(a1,d4.w),a1
	lea	palette_tc(pc),a2
	lea	multiples(pc),a3
	move.l	size_unpck(pc),d0
	add.l	d0,d0
	add.l	d0,d0
	cmp.l	id_size(pc),d0
	bgt.s	.end_rgb32
	move.w	width(pc),d1
	move.w	height(pc),d2
	bra	decompresse_rgb32
.end_rgb32:
	rts


	TEXT
	include	'avi_cram.vga'
	TEXT
	include	'avi_cram.rvb'
	TEXT
	include	'avi_cvid.s'
	TEXT
	include	'avi_yvu.s'
	TEXT
	include	'avi_pc.s'
	include	'avi_rle8.s'
	include	'avi_rgbx.s'
	include	'avi_aflc.s'
	include	'avi_blak.s'
	IFNE	INDEO
	include	'avi_iv32.s'
	ENDC
	BSS
ecran:
	ds.l	1
size_one_line:
	ds.w	1
previous_line_6:
	ds.w	1
previous_line_8:
	ds.w	1
	TEXT

	IFNE	FIRST_TST
	BSS
first_img:
	ds.w	1
	TEXT
	ENDC
	

sound_it:
	IFNE	TEST_TIME_INTER
	move.b	#$ff,$ffff9802.w
	ENDC
	tst.w	play_flag
	beq.s	.no_it
	movem.l	d0-d1/a0,-(sp)
	IFNE	CYCLE_IT
	lea	it_warten(pc),a0
	move.l	(a0)+,d0
	move.l	(a0),d1
	cmp.l	d0,d1
	bgt.s	.to_play_it
	ENDC
	lea	start_audio_buffer1+24(pc),a0
	move.l	(a0)+,d0
	move.l	(a0),d1	
	cmp.l	d0,d1
	IFNE	CYCLE_IT
	bgt.s	.play_it
	bra.s	.no_sound
.to_play_it:
.play_it:
	ELSE
	ble.s	.no_sound
	ENDC
	move.l	d1,-(a0)
	lea	$ffff8900.w,a0
	movep.l	d0,$1(a0)
	movep.l	d1,$d(a0)
	move.w	#$0101,(a0)
.no_sound:
	movem.l	(sp)+,d0-d1/a0
.no_it:
	bclr.b	#7,$fffffa0f.w
;	bset.b	#7,$fffffa03.w
	IFNE	TEST_TIME_INTER
	clr.b	$ffff9803.w
	ENDC
	rte
	IFNE	CYCLE_IT
it_warten:
	dc.l	0
	dc.l	0
	ENDC

	DATA

	IFNE	TIME_TAKEN
time_used	; j'ai besoin que ces variables soient initialis‚es … 0
	dc.l	0
nb_frame_displayed
	dc.w	0
	ENDC

audio_compression_test:
	dc.l	$01000800,pcm_8_bits	; PCM 8 bits
	dc.l	$01001000,pcm_16_bits	; PCM 16 bits
	IFNE	IMA4
	dc.l	$11000400,dvi_adpcm4	; IMA4/DVI ADPCM 4 bits
	ENDC
	IFNE	MSADPCM
	dc.l	$02000400,ms_adpcm4
	ENDC
	dc.w	-1		; Fin
	
adr_resampling_routs:
	dc.l	pcm_8_bits
pcm_8_bits:
	dc.l	mono_8_bits,stereo_8_bits
	dc.l	fmono_8_bits,fstereo_8_bits
pcm_16_bits:
	dc.l	mono_16_bits,stereo_16_bits
	dc.l	fmono_16_bits,fstereo_16_bits
	IFNE	IMA4
dvi_adpcm4:
	dc.l	mono_ima_4_bits,stereo_ima_4_bits
	dc.l	mono_ima_4_bits,stereo_ima_4_bits
	ENDC
	IFNE	MSADPCM
ms_adpcm4:
	dc.l	mono_msadpcm_4_bits,stereo_msadpcm_4_bits
	dc.l	mono_msadpcm_4_bits,stereo_msadpcm_4_bits
	ENDC
resampling_sub:
	dc.l	mono_8_bits
dma_sound_control:
	dc.b	%10000010
	dc.b	0
stereo_flag:
	dc.w	0
resample_speed:
	dc.w	0
resample_speed2:
	dc.w	0
block_align:
	dc.w	0
son_4_bits:
	dc.w	0
son_16_bits:
	dc.w	0
sound_disabled:
	dc.w	0
play_flag:
	dc.w	0
sound_lock_flag:
	dc.w	0
play_sound_flag:
	dc.w	0
start_audio_buffer1:
	dc.l	0
current_audio_buffer1:
	dc.l	0
end_audio_buffer1:
	dc.l	0
start_audio_buffer2:
	dc.l	0
current_audio_buffer2:
	dc.l	0
end_audio_buffer2:
	dc.l	0
current1:
	dc.l	0
current2:
	dc.l	0
	TEXT
wave_sound:
	tst.w	sound_disabled(pc)	; l'anim contient-elle du son ?
	bne	loop_analyse_record
	tst.w	play_sound_flag(pc)	; a-t-on demand‚ … le jouer ?
	beq	loop_analyse_record
	lea	start_audio_buffer1(pc),a0
	tst.l	(a0)
	IFEQ	STFA
	bne.s	.no_malloc
	ELSE
	bne	.no_malloc
	ENDC
	move.l	#sound_buffer1,d0
	move.l	d0,(a0)		; D‚but
	move.l	d0,4(a0)	; Adr courante
	add.l	#BUFFER1,d0
	move.l	d0,8(a0)	; Fin
	move.l	a0,-(sp)
	Mxalloc	#BUFFER2*2,#0	; ST Ram pour le son
	move.l	(sp)+,a0
	tst.l	d0
	beq	not_enough_memory
	move.l	d0,12(a0)	; Debut
	move.l	d0,16(a0)	; Adr courante
	move.l	d0,24(a0)
	move.l	d0,28(a0)
	add.l	#BUFFER2*2,d0
	move.l	d0,20(a0)	; Fin
	IFNE	STFA
	tst.w	stfa(pc)
	bne.s	.stfa10
	ENDC
	bclr.b	#7,$fffffa13.w
	bclr.b	#7,$fffffa07.w
	bclr.b	#7,$fffffa0b.w
	bclr.b	#7,$fffffa0f.w
	move.l	#sound_it,$13c.w
	bset.b	#7,$fffffa07.w
	bset.b	#7,$fffffa13.w
	bset.b	#7,$fffffa03.w
	IFNE	STFA
.stfa10:
	ENDC
.no_malloc:
	move.l	id_size(pc),d1
	cmp.l	#BUFFER1,d1		; son trop grand ??
	bgt	loop_analyse_record	; bingo !!
*	ble.s	.no_cut
*	move.l	#BUFFER1,d1		; On charge le maxi
.no_cut:
	move.l	4(a0),a1		; Adresse d‚part courante
	move.l	8(a0),a2		; Adresse fin buffer
	lea	(a1,d1.l),a3		; Adresse du prochain d‚part
	cmp.l	a2,a3			; Est-on arriv‚ … la fin du buffer
	IFEQ	STFA
	blt.s	.no_cycle		; Non => on ne cycle pas
	ELSE
	blt	.no_cycle
	ENDC
	IFEQ	CYCLE_IT
	clr.w	play_flag
	ENDC
	move.l	(a0),4(a0)		; Adresse d‚but -> adresse courante
	move.l	4(a0),a1
	move.l	12(a0),16(a0)		; Boucle 2eme buffer
	move.l	28(a0),d0
	cmp.l	24(a0),d0
	beq.s	.no_warten
	movem.l	d1/a0-a1,-(sp)
	Fread	handle(pc),d1,(a1)
	movem.l	(sp)+,d1/a0-a1
	cmp.l	d1,d0
	blt	end_play
	add.l	d1,list_counter
	IFNE	STFA
	tst.w	stfa(pc)
	bne.s	.stfa11	
	ENDC
	IFEQ	CYCLE_IT
	lea	$ffff8900.w,a6
	clr.b	(a6)
.warten_sound:
	btst.b	#0,1(a6)
	bne.s	.warten_sound
	move.l	$4ba.w,until_timer
	ENDC
	movem.l	24(a0),d6-d7
	IFNE	CYCLE_IT
	movem.l	d6-d7,it_warten
	ELSE
	movep.l	d6,$1(a6)
	movep.l	d7,$d(a6)
	move.w	#$0101,(a6)
	ENDC
	IFNE	STFA
	bra.s	.no_stfa11
.stfa11:
	move.l	stfa_control(pc),a2
	bclr.b	#1,1(a2)
.warten_sound_stfa:
	btst.b	#0,1(a2)
	bne.s	.warten_sound_stfa
	move.l	$4ba.w,until_timer
.no_stfa11:
	ENDC
	move.l	12(a0),28(a0)
	move.l	12(a0),24(a0)
	bra.s	.resample
.no_warten:
	move.l	12(a0),28(a0)
	move.l	12(a0),24(a0)
.no_cycle:
	movem.l	d1/a0-a1,-(sp)
	Fread	handle(pc),d1,(a1)
	movem.l	(sp)+,d1/a0-a1
	add.l	d1,list_counter
.resample:
; Traitement du son	
	IFNE	TEST_TIME_RESAMPLE
	movem.l	d1/a0-a1,-(sp)
	Vsync
	movem.l	(sp)+,d1/a0-a1
	move.w	#$ff,$ffff9800.w
	ENDC

	IFNE	STFA
	tst.w	stfa(pc)
	beq.s	.no_stfa12
	move.l	stfa_control(pc),a2
	clr.w	(a2)
	lea	(a1,d1.l),a3
	move.l	a1,6(a2)
	move.l	a3,14(a2)
	cmp.l	a1,a3
	ble.s	.no_stfa_launch
	move.w	#%11,(a2)
.no_stfa_launch:
	lea	(a1,d1.l),a2
	move.l	16(a0),a3
	lea	(a1),a4	
	bra.s	.end_resampling
.no_stfa12:
	ENDC
	move.l	a0,-(sp)
	jsr	([resampling_sub])
	move.l	(sp)+,a0
.end_resampling:
	IFNE	TEST_TIME_RESAMPLE
	clr.w	$ffff9800.w
	ENDC
;	subq.l	#1,a3
	move.l	a2,4(a0)
	move.l	a3,16(a0)
	move.l	a3,28(a0)
	IFNE	STFA
	tst.w	stfa(pc)
	bne.s	.stfa13
	ENDC
	IFNE	FIRST_TST
	tst.w	first_img
	beq.s	.kein_sound
	ENDC
	lea	$ffff8900.w,a6
	tst.b	1(a6)
	bne.s	.kein_sound
	movem.l	24(a0),d6-d7
	movep.l	d6,$1(a6)
	movep.l	d7,$d(a6)
	move.l	d7,24(a0)
	move.w	#$ffff,play_flag
	move.w	#$0101,(a6)
.kein_sound:
	IFNE	STFA
.stfa13:
	ENDC
	move.l	id_size(pc),d0
	move.l	d0,d1
	and.l	#1,d0
	add.l	d0,movi_list_counter
	add.l	d0,list_counter
	Fseek	d0,handle(pc),#1
	clr.l	id_size
	bra	loop_analyse_record

precalc_multiples:
	lea	multiples(pc),a0
	clr.l	d0
	move.w	size_one_line(pc),d0
	move.w	max_y,d1
	subq.w	#1,d1
	moveq	#0,d2
.bcl_multiple:
	move.l	d2,(a0)+
	add.l	d0,d2
	dbf	d1,.bcl_multiple
	rts

precalc_msvc16:
	move.l	#precalc_cram16,a0
	moveq	#-1,d0
.loop_precalc_cram_16:
; passe de  xrrrrrvvvvvbbbbb (au format intel)
; …         rrrrrvvvvv0bbbbb (au format motorola)
	bfextu	d0{16:16},d2	; il y a du Stabylo derriŠre une telle instruction !
	rol.w	#8,d2
	ror.l	#5,d2
	lsl.w	d2
	rol.l	#5,d2
	move.w	d2,0(a0,d0.w*2)	; l'adressage se fait sur un mot (donc sign‚)
	dbf	d0,.loop_precalc_cram_16
	rts

	include	'resample.s'
	IFNE	IMA4
	include	'ima4.s'
	ENDC
	IFNE	MSADPCM
	include	'msadpcm.s'
	ENDC

cls:
	move.l	my_adr_scr(pc),a0
	move.w	max_x(pc),d0
	move.w	max_y(pc),d2
	subq.w	#1,d2
	subq.w	#1,d0
.cls_line:
	move.w	d0,d1
.cls_one_line:
	clr.w	(a0)+
	dbf	d1,.cls_one_line
	dbf	d2,.cls_line
	rts

vide_clavier:
	Cconis
	tst.l	d0
	beq.s	.empty
	Crawcin
	bra.s	vide_clavier
.empty:
	rts

scroll_mouse:
	movem.l	d0-d1/a0,-(sp)
	move.b	(a0)+,d0
	and.b	#$f8,d0
	cmp.b	#$f8,d0
	bne.s	.end_scroll_mouse
	tst.w	(a0)
	beq.s	.end_scroll_mouse
	move.b	(a0)+,d0
	ext.w	d0
	and.w	#$fffe,d0
	move.w	pos_scroll_x(pc),d1
	add.w	d0,d1
	bge.s	.no_clip_min_x
	clr.w	d1
.no_clip_min_x:
	cmp.w	max_scroll_x(pc),d1
	ble.s	.no_clip_max_x
	move.w	max_scroll_x(pc),d1
.no_clip_max_x:
	move.w	d1,pos_scroll_x
	move.b	(a0)+,d0
	ext.w	d0
	move.w	pos_scroll_y(pc),d1
	add.w	d0,d1
	bge.s	.no_clip_min_y
	clr.w	d1
.no_clip_min_y:
	cmp.w	max_scroll_y(pc),d1
	ble.s	.no_clip_max_y
	move.w	max_scroll_y(pc),d1
.no_clip_max_y:
	move.w	d1,pos_scroll_y
	st	scroll_flag
.end_scroll_mouse:
	movem.l	(sp)+,d0-d1/a0
	rts

vbl_it:
	tst.b	scroll_flag(pc)
	beq.s	.no_scroll_vbl
	sf	scroll_flag
	movem.l	d0-d2/a0-a2,-(sp)
	move.w	pos_scroll_x(pc),d0
	move.w	pos_scroll_y(pc),d1
	lea	multiples(pc),a0
	move.l	(a0,d1.w*4),d1
	move.l	org_adr(pc),a0
	lea	(a0,d0.w*2),a0
	add.l	d1,a0
	move.l	a0,log_adr
	Setscreen	a0,a0,#-1
	movem.l	(sp)+,d0-d2/a0-a2
.no_scroll_vbl:
	tst.l	old_vbl_it(pc)
	beq.s	.end_vbl_it
	move.l	old_vbl_it(pc),-(sp)
.end_vbl_it:
	rts

	IFNE	INDEO
	include	'ice_unpa.s'
	ENDC

	include	'initcook.s'

	BSS
sound_adderin:
	ds.w	1
sound_adcinput:
	ds.w	1
	TEXT


	BSS
old_vbl_it:
	ds.l	1
old_mouse:
	ds.l	1
nb_bits:
	ds.w	1
flag_2_bits:
	ds.w	1
flag_4_bits:
	ds.w	1
flag_16_bits:
	ds.w	1
flag_24_bits:
	ds.w	1
flag_32_bits:
	ds.w	1
auds_yet:
	ds.w	1
vids_stream:
	ds.w	1
auds_stream:
	ds.w	1
strf_flag_vids:
	ds.w	1
strf_flag_auds:
	ds.w	1
counter_frame:
	ds.w	1
counter_chunk:
	ds.w	1
	DATA
info_txt:
	dc.b	'EpAVI-Player v '
	VERSION
	dc.b	'q',13,10
	dc.b	'Coded by Seb & Stabylo/The Removers',13,10
	dc.b	'Player of *.AVI for Falcon 030.',13,10
	dc.b	13,10
	dc.b	'AVI-Player is a freeware ...',13,10
	dc.b	'Please spread it !!!',13,10,0
	even
active_curseur:
	dc.b	27,'e',0
	even
desactive_curseur:
	dc.b	27,'f',0
	even
	BSS
movi_list_size:
	ds.l	1
movi_list_counter:
	ds.l	1
width:
	ds.w	1
height:
	ds.w	1
start_color:
	ds.w	1
nb_color:
	ds.w	1
dummy:
	ds.l	1
compressed:
	ds.l	1
size_unpck:
	ds.l	1
size_unpck2:
	ds.l	1
offset_debut:
	ds.l	1
offset_x:
	ds.w	1
offset_y:
	ds.w	1
nb_frame:
	ds.l	1
riff_header:
	ds.l	1
riff_size:
	ds.l	1
form_type:
	ds.l	1
chunk_type:
	ds.l	1
chunk_size:
	ds.l	1
list_type:
	ds.l	1
id_type:
	ds.l	1
id_size:
	ds.l	1
list_type2:
	ds.l	1
id_type2:
	ds.l	1 
id_size2:
	ds.l	1
seek_counter:
	ds.l	1
list_counter:
	ds.l	1
list2_counter:
	ds.l	1
	ds.l	1
little_buffer:
	ds.l	50
handle:
	ds.w	1
old_mode:
	ds.w	1
new_mode:
	ds.w	1
offset_affichage:
	ds.l	1
my_adr_scr:
	ds.l	1
old_adr_scr:
	ds.l	1
adr_scr:
	ds.l	1
adr_buffer:
	ds.l	1
palette_256:
	ds.b	256*4
palette_tc:
	ds.w	256
save_palette_tc:
	ds.w	256
sauve_cache:
	ds.l	1
super:
	ds.l	1
old_dta:
	ds.l	1
new_dta:
	ds.b	44
nom_fichier:
	ds.b	256
mask_fichier:
	ds.b	256
	even.l
	IFNE	STFA
stfa:
	ds.w	1
stfa_control:
	ds.l	1
	ENDC
	IFNE	INDEO
parametres_codec
	ds.b	info_init_codec.video_sizeof
	ENDC

;	CNOP	0,16
;	ds.w	1

multiples:
	ds.l	4000
resampling:
	ds.w	256*512
;resampling2:
;	ds.w	256*512

	ds.w	1<<15
precalc_cram16:
	ds.w	1<<15
	
	include	'avi_bss.s'

sound_buffer1:
	ds.b	BUFFER1
	
	IFNE	INDEO
	even
indeo_ice:
	ds.b	102282
	ENDC

	even
	BSS
	ds.b	8
fin_bss:
	ds.b	8

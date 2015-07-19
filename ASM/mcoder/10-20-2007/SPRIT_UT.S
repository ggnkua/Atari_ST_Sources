*------------------------------------------------------------------*
*--               "sprit_ut iliaires.S"                           -*
*-- #Load page Degas et sauve sprites sous format :        	   -*
*--   nb lignes-1.w / nb block 4 Word-1.w / larg reelle en pix .w -*
*--   ,puis datas						   -*
*-- #Creation position par sprites compos‚es			   -*
*-- #Creation animation des position			   -*
*-- #Sauvegarde des datas sous forme de fichiers sources ASCII	   -*
*-- by CLB mai 89						   -*
*------------------------------------------------------------------*

;reste:	
;	-load et save du .INF


flag_prg	equ	0	;0 si exec en mem ,1 si generation .prg

	IFNE	flag_prg
	  OUTPUT	  sprit_ut.prg
	ELSEIF
	  opt	  x+
	ENDC
	
print_rs232:	equ	0
	

clpl	equ	15	;coul plot sur cadre
long_entete	equ 8	;8 octets d'entete par fichier sprite

on	equ	1
off	equ	0

c_conws	equ	9
c_conin	equ	1

gemdos	equ	1
fopen	equ	$3d
fread	equ	$3f
create	equ	$3c
fwrite	equ	$40
fclose	equ	$3e
malloc	equ	$48

xbios	equ	14
getrez	equ	$4
setscr	equ	$5
setpal	equ	$6
vsync	equ	$25
supexec	equ	$26
bios	equ	13

setexec	equ	5

nb_name_lst	equ	100

	include	"\includes\control.s"

USER	macro			;definir mode: dc.l	0
	move.l	mode,-(sp)
	move.w	#$20,-(sp)
	trap	#gemdos
	addq.l	#6,sp
	endm

SUPER	macro
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#gemdos
	addq.l	#6,sp
	move.l	d0,mode
	endm
	
	
*----------------------------------- DEBUT CODE ---------------------*

	move.l	sp,adrpile
	move.l	sp,a5
	move.l	#stack,sp
	movea.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#gemdos
	add.l	#12,sp
	tst.l	d0
	beq	good1
	jsr	print
	dc.b	10,13,"Bug",0
	jsr	getch
	bra	bye

good1:
	jsr	init_vdi
	IFNE	flag_prg
	bsr	hide_m
	ENDC

	clr.b	etat_mouse	;ici,pas de mouse a l'ecran
	clr.b	inter_coul	;flag interruptions
	move.w	#clpl,col_pl	;couleur plot
	move.b	#1,flag_auto_name
	jsr	memo_pal
	move.w	#getrez,-(sp)
	trap	#xbios
	addq.l	#2,sp
	move.w	d0,anc_rez
	
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp
	
	move.w	#255,d0
	jsr	graf_mouse
	bsr	show_m
	
*------------ RESERVE MEMOIRE-----------*

	move.l	#debut_ram+260,d0
	and.l	#$ffffff00,d0
	move.l	d0,page2
	move.l	d0,ecrpts
	
	add.l	#33000,d0
	and.l	#$ffffff00,d0
	move.l	d0,page3
	add.l	#32100,d0
	move.l	d0,start_load_adr

	move.w	#3,-(sp)
	trap	#xbios
	addq.l	#2,sp
	move.l	d0,page1
	add.l	#long_entete,d0		;laisse place pour wordx.b et nblig.b et largpix.w
	move.l	d0,adbufspr
	move.l	page1,d0
	sub.l	#32000,d0
	move.l	d0,page_stock
	clr.b	flag_stock
	bsr	hide_m
	
main_menu:
	bsr	hide_m		;securit‚e
	move.l	#cool_col,-(sp)
	move.w	#setpal,-(sp)
	trap	#xbios
	addq.l	#6,sp
	move.l	page2,d3
	jsr	visu4
.loop:	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp
	CLS
	jsr	print
	dc.b	"<********   SPRITES UTILITAIRE   ********>",0
	LOCATE	0,3
	jsr	print
	dc.b	"1-SAISIE de sprites",13,10,13,10
	dc.b	"2-CONSTRUCTION des positions d'un personnage avec des sprites",13,10,13,10
	dc.b	"3-Reglage d'ANIMATIONS de personnages",13,10,13,10
	dc.b	"-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -",13,10
	dc.b	"4-Reuni Tous les fichiers d'un perso en .S",13,10,13,10
	DC.B	"5-Definir les palettes",13,10,13,10
	dc.b	"6-Sauvegarder l'environement .INF ( paths,palettes,etc)",13,10,13,10
	dc.b	"Q-QUITTER",13,10,13,10
	dc.b	">",0
	even
.wait_key:
	jsr	getch
	cmp.b	#"1",d0
	beq	SAISIE
	cmp.b	#"q",d0
	beq	bye
	cmp.b	#"Q",d0
	beq	bye
	cmp.b	#"2",d0
	beq	CONSTRUCT
	cmp.b	#"3",d0
	beq	def_ani_perso	;ANIMATION
	cmp.b	#"4",d0
	beq	REUNION_S
	cmp.b	#"5",d0
	beq	def_palettes
	cmp.b	#"6",d0
	beq	save_inf
	bra	.loop	;wait_key
	
SAISIE:	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp
	bsr	show_m
loop:	jsr	getinput	;retourne d0=0 ou code scan ou 201/202
				;et actualise xmouse,ymouse
	cmp.w	#1,d0		;ESC
	beq	end_saisie
	cmp.w	#$26,d0		;L
	bne	loop2
	jsr	loadecr
	clr.l	total_saisie
	bra	loop
	
loop2:	cmp.w	#201,d0		;Left Button
	bne	loop
	jsr	getspr
	bra	loop
	
end_saisie:
	bsr	hide_m
	bra	main_menu
* ------------

CONSTRUCT:
	bsr	hide_m		;securit‚e
	move.w	#150,limbas
	move.w	#24,limhaut
	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp
	CLS
	move.l	#cool_col,-(sp)
	move.w	#setpal,-(sp)
	trap	#xbios
	addq.l	#6,sp
	jsr	print
	dc.b	"--- DEFINITION DE PERSO ---",13,10,13,10
	dc.b	"(PATH=",0
	move.l	#path_data,d0
	jsr	outstr
	jsr	print
	dc.b	")",13,10,13,10
	dc.b	"1-Definition TABLE des sprites d'un perso (.TBL)",13,10,13,10
	dc.b	"2-Construction des POSITIONS d'un perso (.POS)",13,10,13,10
	dc.b	"3-Definir les ZONES de contact",13,10,13,10
	dc.b	"4-Definir sprites a fliper level x",13,10,13,10
	dc.b	13,10,"ESC-Retour Menu",13,10,13,10
	dc.b	">",0
	even
.wait_key:
	jsr	getch
	cmp.b	#27,d0
	beq	main_menu
	cmp.b	#"1",d0
	beq	def_tbl_perso
	cmp.b	#"2",d0
	beq	constr_pos
	cmp.b	#"3",d0
	beq	def_zone_perso
	cmp.b	#"4",d0
	beq	choix_flip
	bra	CONSTRUCT	;.wait_key


ANIMATION:
	bra	main_menu
	
	bsr	hide_m		;securit‚e
	move.w	#200,limbas
	move.w	#20,limhaut
	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp
	CLS
	move.l	#cool_col,-(sp)
	move.w	#setpal,-(sp)
	trap	#xbios
	addq.l	#6,sp
	jsr	print
	dc.b	"--- ANIMATION DE PERSO ---",13,10,13,10
	dc.b	"(PATH=",0
	move.l	#path_anim,d0
	jsr	outstr
	jsr	print
	dc.b	")",13,10,13,10
	dc.b	"1-Reglage des anims d'un perso (.ANI)",13,10,13,10
	dc.b	"2-SET PATH",13,10,13,10
	dc.b	13,10,"ESC-Retour Menu",13,10,13,10
	dc.b	">",0
	even
.wait_key:
	bsr	getch
	cmp.b	#27,d0
	beq	main_menu
	cmp.b	#"1",d0
	beq	def_ani_perso
	cmp.b	#"2",d0
	beq	input_anim_path
	bra	ANIMATION	;.wait_key
	
* and quit
bye:	jsr	int_off
	move.l	#cool_col,-(sp)
	move.w	#setpal,-(sp)
	trap	#xbios
	addq.l	#6,sp

	jsr	exit_vdi

	move.l	page1,d3
	jsr	visu4

	;dc.w	$a009			;reactive souris

	move.w	anc_rez,-(sp)
	move.l	page1,-(sp)
	move.l	page1,-(sp)
	move.w	#setscr,-(sp)		;setscreen
	trap	#xbios
	add.l	#12,sp

;	bsr	reset_pal
	
ok1:	
	move.l	adrpile,sp
	clr.w 	-(sp)			status code
	move.w 	#$4c,-(sp)		P_TERM
	trap #1				and go away


**************************** ROUTINES ******************************
def_palettes:
	CLS
	bsr	print
	dc.b	"   palette 1",13,10
	dc.b	"   palette 2",13,10
	dc.b	"   palette 3",13,10
	dc.b	"   palette 4",13,10
	dc.b	"   palette 5",13,10
	dc.b	"   palette 6",13,10
	dc.b	"   palette 7",13,10
	dc.b	"   palette 8",13,10
	dc.b	"   palette 9",13,10
	dc.b	"   palette 10",13,10,0
	bra	main_menu

	move.l	#loadecr_txt,a0
	bsr	file_select
	tst.l	d3
	beq	.return
	bsr	hide_m
	move.l	page2,d4
	sub.l	#34,d4
	jsr	load
	move.l	page2,d3
	jsr	visu4
	move.l	page2,a0
	sub.l	#32,a0
	move.l	a0,-(sp)
	move.w	#6,-(sp)		;setcolor
	trap	#xbios
	addq.l	#6,sp
	bsr	show_m
.return:	rts
	
save_inf:
	bra	main_menu


REUNION_S:
	bsr	get_name_and_taille
	cmp.l	#-1,d0
	beq	main_menu	;si nom=RETURN
	bra	main_menu

load_anim:	;entree:d3 =adr nom
	move.l	adr_anim_ascii,a0
	clr.b	(a0)		;fin du texte ascii
	move.l	d3,-(sp)
	bsr	getaille
	move.l	(sp)+,d3
	tst.l	d0
	beq	.rts
	move.l	adr_anim_ascii,d4
	move.l	d4,a0
	add.l	d0,a0
	clr.b	(a0)		;fin texte
	jsr	load
	bsr	kill_fliped_etapes
	bsr	recree_no_etap
	bsr	reset_info_name
.rts:	rts

recree_no_etap:
	;remet "etXXnnn:" si "        "
	move.l	adr_anim_ascii,a0
.loop:	tst.b	(a0)
	beq	.rts
	cmp.b	#" ",(a0)
	bne	.next
	move.b	#"e",(a0)+
	move.b	#"t",(a0)+
	move.b	perso_name,(a0)+
	move.b	perso_name+1,(a0)+
	move.b	no_eta+1,(a0)+		;sera actualis‚
	move.b	no_eta+2,(a0)+
	move.b	no_eta+3,(a0)+
	move.b	#":",(a0)+
.next:	bsr	find_end_string
	tst.b	(a0)
	beq	.rts
	addq.l	#1,a0
	bra	.loop
.rts:	rts

reset_info_name:
	movem.l	d0/a0-a1,-(sp)
	move.l	#no_name,a0
	move.l	#info_anim_name,a1
	move.w	#10,d0
.loop:	move.b	(a0)+,(a1)+
	dbra	d0,.loop
	movem.l	(sp)+,d0/a0-a1
	rts

getaille:
	; Entree:d3=nom
	; Sortie:d0=taille ou 0 si erreur
	move.l	#dta,-(a7)	;tampon dta de 44 octets
	move.w	#$1a,-(a7)	;setdta
	trap	#1
	addq.l	#6,a7
	move.w	#0,-(a7)	;valeur de l'attribut :0=fichier normal
	move.l	d3,-(a7)	;nom du fichier
	move.w	#$4e,-(a7)	;sfirst
	trap	#1
	addq.l	#8,a7
	tst	d0
	beq	.ok
	clr.l	d0
	rts
.ok:	move.l	#dta,a0
	move.l	26(a0),d0
	rts


	
		dc.b	8,0
perso_name:	ds.b	14
perso_tbl_name:	ds.b	40
perso_pos_name:	ds.b	40
perso_ani_name:	ds.b	40
perso_dcl_name:	ds.b	40
perso_inc_name:	ds.b	40
	even

test_xy	macro
	cmp.w	#\1,d1
	blt	.\@non
	cmp.w	#\2,d1
	bgt	.\@non
	cmp.w	#\3,d2
	blt	.\@non
	cmp.w	#\4,d2
	blt	\5
.\@non:	
	endm
	
input_data_path:
	LOCATE	6,2
	bsr	print
	dc.b	"                          ",0
	LOCATE	6,2
	move.l	#path_data-2,d0
	bsr	input_d0
	bra	CONSTRUCT

input_anim_path:
	LOCATE	6,2
	bsr	print
	dc.b	"                          ",0
	LOCATE	6,2
	move.l	#path_anim-2,d0
	bsr	input_d0
	bra	ANIMATION

get_name_and_taille:
	bsr	show_m
	move.l	#load_liste_txt,a0
	bsr	file_select
	tst.l	d3
	beq	.RETURN
	move.l	#name_select,a0
	move.b	(a0),lettre1
	move.b	1(a0),lettre2
	move.l	#perso_name,a1
.lop1:	cmp.b	#" ",(a0)
	beq	.fin_name
	cmp.b	#".",(a0)
	beq	.fin_name
	move.b	(a0)+,(a1)+
	bra	.lop1
.fin_name:
	clr.b	(a1)
	move.l	a1,a0

	move.l	a0,adr_ext
	move.b	#".",(a0)+
	move.b	#"T",(a0)+
	move.b	#"B",(a0)+
	move.b	#"L",(a0)+
	clr.b	(a0)
	move.l	#perso_tbl_name,a0
	move.l	#path_data,a1
	jsr	copy_path
	move.l	#perso_name,a1
	jsr	copy_to_0
	move.b	#0,(a0)+
	move.b	#0,(a0)+

	move.l	adr_ext,a0
	move.b	#".",(a0)+
	move.b	#"A",(a0)+
	move.b	#"N",(a0)+
	move.b	#"I",(a0)+
	clr.b	(a0)
	move.l	#perso_ani_name,a0
	move.l	#path_data,a1
	jsr	copy_path
	move.l	#perso_name,a1
	jsr	copy_to_0
	move.b	#0,(a0)+
	move.b	#0,(a0)+

	move.l	adr_ext,a0
	move.b	#".",(a0)+
	move.b	#"D",(a0)+
	move.b	#"C",(a0)+
	move.b	#"L",(a0)+
	clr.b	(a0)
	move.l	#perso_dcl_name,a0
	move.l	#path_data,a1
	jsr	copy_path
	move.l	#perso_name,a1
	jsr	copy_to_0
	move.b	#0,(a0)+
	move.b	#0,(a0)+

	move.l	adr_ext,a0
	move.b	#".",(a0)+
	move.b	#"I",(a0)+
	move.b	#"N",(a0)+
	move.b	#"C",(a0)+
	clr.b	(a0)
	move.l	#perso_inc_name,a0
	move.l	#path_data,a1
	jsr	copy_path
	move.l	#perso_name,a1
	jsr	copy_to_0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	
	bsr	hide_m
	move.l	#name_liste,a0	;liste des noms choisis
	move.l	#12*(nb_name_lst-1),d0	;50 noms max
.loop:	clr.b	(a0)+
	dbra	d0,.loop
	move.l	#name_liste,pt_next_liste	;si creation
	move.l	#perso_tbl_name,d3
	bsr	getaille
	rts
	
.RETURN:
	move.l	#-1,d0
	rts

aff_posxy:
	move.l	xmil,xmil2
	move.l	pt_pos,pt_pos2
	move.w	d0,xmil
	move.w	d3,ymil
	move.l	a2,pt_pos
	bsr	aff_pos
	move.l	xmil2,xmil
	move.l	pt_pos2,pt_pos
	rts

*---------- ROUTINES ANIMATION -----------
adr_anim_ascii:	dc.l	0
adr_start_anim:	dc.l	0
adr_ext:		dc.l	0
next_load_adr:	dc.l	0
adr_pos_took:	dc.l	0
e_travail:	dc.l	0
e_visu:		dc.l	0
sens_anim:	dc.w	0
x_start:		dc.w	0
y_start:		dc.w	0
adr_modif_etape	dc.l	0
adr_du_zero:	dc.l	0
adr_zero_pos:	dc.l	0
val_zero_pos	dc.b	0
lettre1:		dc.b	0
lettre2:		dc.b	0
		dc.b	":"
info_anim_name:	dc.b	"__________",0
no_name:		dc.b	"__________",0
	even
	
	dc.b	10,10
buffer_zob:ds.b	12
end_zob:


input_name_anim:
	NORMAL
	bsr	hide_m
	LOCATE	7,3
	move.l	#no_name,d0
	bsr	outstr
	LOCATE	7,3
	move.l	#buffer_zob,d0
	sub.l	#2,d0
	bsr	input_d0
.lop1:	move.b	#"_",(a0)+
	cmp.l	#end_zob,a0
	bne	.lop1
	move.l	#buffer_zob,a0
	move.l	#info_anim_name,a1
	move.w	#9,d0
.lop2:	move.b	(a0)+,(a1)+
	dbra	d0,.lop2
	bsr	show_m
	rts

model_1:	dc.b	";-----50,50",9,9,9,"----*  __________",13,10,0

rename_anim:
	bsr	input_name_anim
	move.l	pt_anim,a0
.lop:	cmp.b	#";",(a0)
	beq	.okdeb
	sub.l	#1,a0
	bra	.lop
.okdeb:	move.b	#"*",d0
	bsr	find_d0
	add.l	#2,a0
	move.w	#9,d0
	move.l	#info_anim_name,a1
.lop2:	move.b	(a1)+,(a0)+
	dbra	d0,.lop2
	bsr	hide_m
	bsr	raf_page21
	LOCATE	6,3
	move.l	#info_anim_name-1,d0
	bsr	outstr
	bsr	aff_info_anim
	bsr	memo_page21
	bsr	raf_all_anim
	;bsr	aff_pos
	bsr	show_m
	jsr	wait_no_clic
	bra	loop_anim


create_anim:
	move.l	adr_anim_ascii,a0
	tst.b	(a0)
	beq	.ok_cre
	clr.b	d0
	bsr	find_d0
	sub.l	#3,a0
.loop:	cmp.l	adr_anim_ascii,a0
	ble	loop_anim	;il n'y a pas de 10 ??
	cmp.b	#10,(a0)
	beq	.ok10
	sub.l	#1,a0
	bra	.loop
.ok10:	cmp.b	#";",1(a0)
	beq	loop_anim	;Il y a une anim vide
.ok_cre:
	clr.b	buffer_pos
	bsr	input_name_anim
	move.l	adr_anim_ascii,a0
	clr.l	d0
	bsr	find_d0
	sub.l	#1,a0
	move.l	a0,adr_start_anim
	move.l	a0,pt_anim
	move.l	#model_1,a1
.lop:	move.b	(a1)+,(a0)+
	tst.b	-1(a0)
	bne	.lop
	move.l	pt_anim,a0
	move.b	#"*",d0
	bsr	find_d0
	add.l	#2,a0
	move.w	#9,d0
	move.l	#info_anim_name,a1
.lop2:	move.b	(a1)+,(a0)+
	dbra	d0,.lop2
	bsr	find_start_anim
	bsr	hide_m
	bsr	raf_page21
	LOCATE	6,3
	move.l	#info_anim_name-1,d0
	bsr	outstr
	bsr	calc_no_eta
	move.l	#"    ",no_eta
	bsr	aff_info_anim
	bsr	memo_page22
	bsr	memo_page21
	bsr	raf_all_anim
	bsr	aff_pos
	bsr	show_m
	jsr	wait_no_clic
	bra	loop_anim
	

find_start_anim:
	movem.l	d0/a0-a1,-(sp)
	move.l	pt_anim,a0
	cmp.b	#";",(a0)
	bne	.loop
	add.l	#6,a0	;format: ';-----50,50/TAB/TAB/TAB----*  Marche____
	bsr	dec_a0_d0
	move.w	d0,x_start
	move.w	d0,x_pos_anc
	bsr	dec_a0_d0
	move.w	d0,y_start
	move.w	d0,y_pos_anc
	move.b	#"*",d0
	bsr	find_d0
	add.l	#2,a0
	move.w	#9,d0
	move.l	#info_anim_name,a1
.loop0:	move.b	(a0)+,(a1)+
	dbra	d0,.loop0
.loop:	tst.b	(a0)
	beq	.oka0
	cmp.b	#"e",(a0)
	bne	.next
	cmp.b	#"t",1(a0)
	bne	.next
.oka0:	move.l	a0,adr_start_anim
	move.l	a0,pt_anim
	movem.l	(sp)+,d0/a0-a1
	rts
.next:	add.l	#1,a0
	bra	.loop

play_anim:
	bsr	hide_m
	SUPER
	move.b	#2,flag_work
	move.w	#5,nb_vbl
	move.l	pt_anim,a0
.loop:	cmp.l	adr_anim_ascii,a0
	blt	end_play
	cmp.b	#";",(a0)
	beq	.end1		;remonte au debut de l'anim courante
	sub.l	#1,a0
	bra	.loop
.end1:	move.l	a0,var1
	move.w	#500,x_pos_anc
	
re_play:
	move.l	page2,e_travail
	move.l	page3,e_visu
	move.l	x_pos_anc,x_play		;x et y
	move.l	var1,pt_anim
 	bsr	find_start_anim
 	;cmp.w	#-10,x_play
 	;blt	loop_play
 	;cmp.w	#330,x_play
 	;bgt	loop_play
 	;cmp.w	#-10,y_play
 	;blt	loop_play
 	;cmp.w	#200,y_play
 	;bgt	loop_play
 	;move.l	x_play,x_pos_anc		;on garde le meme x
loop_play:
	cmp.b	#$39,$fffc02
	beq	end_play
	cmp.b	#$4a,$fffc02
	bne	.pas_m
	tst.w	nb_vbl
	beq	.pas_m
	sub.w	#1,nb_vbl
.pas_m:	cmp.b	#$4e,$fffc02
	bne	.pas_pl
	add.w	#1,nb_vbl
.pas_pl:	bsr	eff_trav
	move.l	pt_anim,a0
	bsr	find_data_anim
	add.w	x_pos_anc,d0
	add.w	y_pos_anc,d3
	bsr	find_def_pos_a0
	bsr	aff_posxy
	bsr	visu_trav_swap
	move.l	pt_anim,a0
	tst.b	(a0)
	beq	end_loop_play
	bsr	find_end_string
	tst.b	1(a0)
	beq	end_loop_play
	cmp.b	#";",1(a0)
	beq	end_loop_play
	add.l	#1,a0
	move.l	a0,pt_anim
	bsr	calc_pos_anc
	bra	loop_play
	
end_loop_play:
	bra	re_play
end_play:
	move.b	#1,flag_work
	USER
	;bsr	show_m
	;bsr	calc_no_eta
	move.l	page2,d3
	jsr	visu4
	bsr	raf_page21
	move.l	adr_start_anim,pt_anim
	bra	re_anim
	
print_ascii:
	move.w	d0,-(sp)
	move.w	#5,-(sp)
	move.w	#3,-(sp)
	trap	#bios
	addq.l	#6,sp
	rts
	
visu_trav_swap:
	move.l	#e_travail,a0
	move.l	(a0),d1
	move.l	4(a0),d2
	move.l	d2,(a0)+
	move.l	d1,(a0)
	move.l	d1,$44e
	move.b	$44f,$ff8201
	move.b	$450,$ff8203
	
	;move.w	#37,-(sp)	;vsync
	;trap	#14
	;addq.l	#02,sp
	move.w	nb_vbl,d0
.lop0:	move.l	$466,d1
.loop:	cmp.l	$466,d1
	beq	.loop
	dbra	d0,.lop0
	rts
nb_vbl:	dc.w	0
	
eff_trav:
	move.l	e_travail,a0
	move.w	#199,d0
.loop:	REPT	40
	clr.l	(a0)+
	ENDR
	dbra	d0,.loop
	rts
aff_ani_txt:
	move.l	page2,a0
	add.l	#150*160,a0
	move.w	#39,d0
.lop1:	move.l	#$ffffffff,(a0)+
	dbra	d0,.lop1
	LOCATE	0,0
	bsr	print
	dc.b	"Etape:",0
	LOCATE	6,3
	move.l	#info_anim_name-1,d0
	bsr	outstr
	INVERSE
	LOCATE	6,1
	bsr	print
	dc.b	"<-",0
	LOCATE	9,1
	bsr	print
	dc.b	"->",0
	LOCATE	13,0
	bsr	print
	dc.b	"PLAY",0
	LOCATE	20,0
	bsr	print
	dc.b	"SAVE",0
	LOCATE	20,3
	bsr	print
	dc.b	"Create",0
	LOCATE	30,0
	bsr	print
	dc.b	"<-",0
	LOCATE	33,0
	bsr	print
	dc.b	"->",0
	LOCATE	36,0
	bsr	print
	dc.b	"FLIP",0
	LOCATE	30,2
	bsr	print
	dc.b	"ADD",0
	LOCATE	30,4
	bsr	print
	dc.b	"REP",0
	LOCATE	34,4
	bsr	print
	dc.b	"DEL",0
	LOCATE	34,2
	bsr	print
	dc.b	"INS",0
	LOCATE	36,3
	bsr	print
	dc.b	"one",0
	LOCATE	0,3
	move.w	#1,d0
	bsr	print_ascii
	LOCATE	2,3
	move.w	#2,d0
	bsr	print_ascii
	LOCATE	4,3
	bsr	print
	dc.b	"Anim",0
	rts

aff_info_anim:
	NORMAL
	LOCATE	6,1
	bsr	print
no_eta:	dc.b	" 001",0
	rts

swap_sens_anim:
	LOCATE	5,5
	NORMAL
	bsr	hide_m
	tst.b	sens_anim
	beq	.inverse
	clr.b	sens_anim
	;move.w	#50,x_start
	;move.w	#50,y_start
	bsr	print
	dc.b	"Normal ",0
	bra	.return
.inverse:
	move.b	#1,sens_anim
	bsr	print
	dc.b	"Inverse",0
.return:	move.l	adr_anim_ascii,a0
	clr.b	d0		;flag "mettre f"
	bsr	flip_anim_ascii
	move.l	adr_anim_ascii,pt_anim
	bsr	find_start_anim
	move.l	#" 001",no_eta
	bsr	raf_all_anim
	bsr	show_m
	jsr	wait_no_clic
	bra	loop_anim


delete_anim:
	move.l	adr_start_anim,a0
.loop1	cmp.l	adr_anim_ascii,a0
	blt	loop_anim
	cmp.b	#";",-(a0)
	bne	.loop1
	move.l	a0,var1
	bsr	hide_m
	LOCATE	10,12
	bsr	print
	dc.b	"Confirmez DELETE (O/N)",0
	bsr	oui_non?
	bne	.return
	move.l	var1,a0
	add.l	#1,a0
.loop:	tst.b	(a0)
	beq	.return		;pas de ';' avant le 0
	cmp.b	#";",(a0)+
	bne	.loop
	move.l	var1,a1
	move.l	a1,pt_anim
	sub.l	a1,a0
	move.l	a0,d0
	move.l	a1,a0
	sub.l	#1,d0
	bsr	delete_d00
	bra	affiche_nom_anim
.return:	bsr	raf_all_anim
	bsr	show_m
	bra	loop_anim

debut_anim:

fin_anim:
	bra	loop_anim

next_anim_spe:
	move.l	pt_anim,a0
.loop:	bsr	find_end_string
	tst.b	(a0)
	beq	loop_anim
	add.l	#1,a0
	cmp.b	#";",(a0)
	bne	.loop
	move.l	a0,pt_anim
	bsr	find_start_anim
	;bsr	hide_m
	;bsr	raf_page21
	LOCATE	6,3
	move.l	#info_anim_name-1,d0
	bsr	outstr
	bsr	calc_no_eta
	;bsr	memo_page21
	;bsr	raf_all_anim
	;bsr	show_m
	jsr	wait_no_clic
	bra	loop_anim
prev_anim_spe:
	move.l	pt_anim,a0
.loop:	cmp.l	adr_anim_ascii,a0
	beq	loop_anim
	cmp.b	#";",(a0)
	beq	.end1		;remonte au debut de l'anim courante
	sub.l	#1,a0
	bra	.loop
.end1:	sub.l	#1,a0
.loop2:	cmp.b	#";",(a0)
	beq	.end2
	cmp.l	adr_anim_ascii,a0
	beq	loop_anim
	sub.l	#1,a0
	bra	.loop2
.end2:	move.l	a0,pt_anim
	bsr	find_start_anim
	;bsr	hide_m
	;bsr	raf_page21
	LOCATE	6,3
	move.l	#info_anim_name-1,d0
	bsr	outstr
	bsr	calc_no_eta
	;bsr	memo_page21
	;bsr	raf_all_anim
	;bsr	show_m
	jsr	wait_no_clic
	bra	loop_anim


next_anim:move.l	pt_anim,a0
.loop:	bsr	find_end_string
	tst.b	(a0)
	beq	loop_anim
	add.l	#1,a0
	cmp.b	#";",(a0)
	bne	.loop
	move.l	a0,pt_anim

affiche_nom_anim:
	bsr	find_start_anim
	bsr	hide_m
	bsr	raf_page21
	LOCATE	6,3
	move.l	#info_anim_name-1,d0
	bsr	outstr
	bsr	calc_no_eta
	bsr	memo_page21
	bsr	raf_all_anim
	bsr	show_m
	jsr	wait_no_clic
	bra	loop_anim

prev_anim:move.l	pt_anim,a0
.loop:	cmp.l	adr_anim_ascii,a0
	beq	loop_anim
	cmp.b	#";",(a0)
	beq	.end1		;remonte au debut de l'anim courante
	sub.l	#1,a0
	bra	.loop
.end1:	sub.l	#1,a0
.loop2:	cmp.b	#";",(a0)
	beq	.end2
	cmp.l	adr_anim_ascii,a0
	beq	loop_anim
	sub.l	#1,a0
	bra	.loop2
.end2:	move.l	a0,pt_anim
	bsr	find_start_anim
	bsr	hide_m
	bsr	raf_page21
	LOCATE	6,3
	move.l	#info_anim_name-1,d0
	bsr	outstr
	bsr	calc_no_eta
	bsr	memo_page21
	bsr	raf_all_anim
	bsr	show_m
	jsr	wait_no_clic
	bra	loop_anim
	
prev_eta:
	move.l	pt_anim,a0
	cmp.l	adr_start_anim,a0
	beq	loop_anim
	bsr	calc_pos_anc_prev
	move.l	pt_anim,a0
	sub.l	#2,a0		;pour eviter le premier 13,10 precedent
.lop1:	sub.l	#1,a0
	cmp.l	adr_start_anim,a0
	beq	.oka0
	cmp.b	#10,(a0)
	bne	.lop1
	add.l	#1,a0
.oka0:	cmp.b	#";",(a0)
	beq	loop_anim
	move.l	a0,pt_anim
	bsr	calc_no_eta
	bsr	raf_all_anim
	bsr	wait_no_clic
	bra	loop_anim
next_eta:
	move.l	pt_anim,a0
	tst.b	(a0)
	beq	loop_anim
	move.b	#10,d0
	bsr	find_d0
	tst.b	(a0)
	beq	loop_anim
	cmp.b	#";",(a0)
	beq	loop_anim
	move.l	a0,pt_anim
	bsr	calc_pos_anc
	bsr	calc_no_eta
	;bsr	memo_page21
	bsr	raf_all_anim
	bsr	wait_no_clic
	bra	loop_anim
	
swap_mode_fin:
	bra	loop_anim

flip_pos_anim:	;--- pointe sur la meme position,en flip‚
	bsr	hide_m
	move.l	pt_pos,a0
	tst.b	(a0)		;pourquoi un ZERO ?
	beq	.return
	move.l	#buffer_zob,a1
.lop1:	move.b	(a0)+,(a1)+
	cmp.b	#":",-1(a0)
	bne	.lop1
	cmp.b	#"f",-2(a0)
	beq	.set2p
	move.b	#"f",-1(a1)
	move.b	#":",(a1)
	clr.b	1(a1)
	bra	.okset
.set2p:	move.b	#":",-2(a1)
	clr.b	-1(a1)
.okset:	move.l	adr_tbl_pos,a1
	move.l	#buffer_zob,a0
	jsr	find_string
	cmp.l	#0,a0
	beq	.return
	move.l	a0,pt_pos
	bsr	raf_page22
	bsr	aff_pos
.return:	bsr	show_m
	bsr	wait_no_clic
	bra	loop_anim

next_pos_anim:
	bsr	hide_m
	move.l	pt_pos,a0
.loop:	tst.b	(a0)
	beq	.oka0
	cmp.b	#10,(a0)+
	bne	.loop
.oka0:	tst.b	(a0)
	beq	.anc_ok
	move.l	a0,pt_pos
.anc_ok:	bsr	raf_page22
	bsr	aff_pos
	bsr	show_m
	bsr	wait_no_clic
	bra	loop_anim

prev_pos_anim:
	bsr	hide_m
	move.l	pt_pos,a0
	cmp.l	adr_tbl_pos,a0
	beq	.rts
	move.l	pt_pos,a0
	sub.l	#1,a0
.loop:	cmp.l	adr_tbl_pos,a0
	beq	.oka0
	cmp.b	#10,-(a0)
	bne	.loop
	add.l	#1,a0
.oka0:	move.l	a0,pt_pos
	bsr	raf_page22
.rts:	bsr	aff_pos
	bsr	show_m
	bsr	wait_no_clic
	bra	loop_anim
	
add_pos_anim:
	bsr	hide_m
	bsr	memo_page22
	move.w	#22,d0		;point
	jsr	graf_mouse
	bsr	show_m
	move.l	pt_pos,pt_took
	bsr	wait_no_clic
	move.b	#1,put_mode
	bra	loop_anim

ins_pos_anim:
	move.l	pt_anim,a0
	tst.b	(a0)
	beq	loop_anim
	bsr	hide_m
	bsr	memo_page22
	move.w	#22,d0		;point
	jsr	graf_mouse
	bsr	show_m
	move.l	pt_pos,pt_took
	bsr	wait_no_clic
	move.b	#2,put_mode
	bra	loop_anim

rep_pos_anim:
	move.l	pt_anim,a0
	tst.b	(a0)
	beq	loop_anim
	bsr	hide_m
	bsr	memo_page22
	move.w	#22,d0		;point
	jsr	graf_mouse
	bsr	show_m
	move.l	pt_pos,pt_took
	bsr	wait_no_clic
	move.b	#3,put_mode
	bra	loop_anim

del_pos_anim:
	bsr	hide_m
	move.l	pt_anim,a0
	cmp.b	#"e",(a0)
	bne	.return
	cmp.l	adr_start_anim,a0	;1ere ligne de l'anim
	bne	.ok
	bsr	find_end_string
	tst.b	1(a0)		;et derniere ligne du fichier?
	beq	.return
	tst.b	(a0)		;et derniere ligne du fichier?
	beq	.return
	cmp.b	#";",1(a0)	;et derniere ligne de l'anim?
	beq	.return
.ok:	
	move.l	pt_anim,a0
	bsr	find_end_string
	move.w	#1000,x_modif
	cmp.b	#1,flag_one
	bne	.pas_one
	tst.b	(a0)
	beq	.pas_one
	tst.b	1(a0)
	beq	.pas_one
	cmp.b	#";",1(a0)
	beq	.pas_one
	move.l	x_pos_anc,x_modif
	add.l	#1,a0	
	bsr	find_data_anim	;d0=dx d3=dy next etape
	add.w	d0,x_modif
	add.w	d3,y_modif
	move.l	pt_anim,a0
	bsr	find_data_anim	;d0=dx d3=dy etape actuelle
	add.w	d0,x_modif
	add.w	d3,y_modif
.pas_one:move.l	pt_anim,a0
	move.l	a0,a1
	move.b	#10,d0
	bsr	find_d0
	sub.l	a1,a0
	move.l	a0,d0		;long ligne actuelle
	move.l	a1,a0
	bsr	delete_d00
	cmp.w	#1000,x_modif
	beq	._1000
	move.l	pt_anim,a0
	move.l	a0,adr_modif_etape
	bsr	find_data_anim
	move.l	x_pos_anc,x_modif2
	add.w	d0,x_modif2
	add.w	d3,y_modif2
	bsr	modif_data_etape
._1000:	bsr	calc_no_eta
	bsr	raf_all_anim
.return	bsr	show_m
	bsr	wait_no_clic
	bra	loop_anim


put_pos_anim:
	bsr	hide_m
	bsr	raf_page21
	move.l	pt_took,a2
	tst.b	flag_1616
	beq	.snap0
	and.w	#$fff0,xmouse
.snap0:
	move.w	xmouse,d0
	move.w	ymouse,d3
	bsr	aff_posxy
	cmp.b	#1,put_mode
	bne	.pas1
	bsr	add_anim_ascii	;---ADD
	cmp.w	#1000,x_modif
	beq	.okput
	move.l	pt_anim,a0
	bsr	find_data_anim
	move.l	x_pos_anc,x_modif2
	add.w	d0,x_modif2
	add.w	d3,y_modif2
	move.l	pt_anim,a0
	bsr	find_end_string
	add.l	#1,a0
	move.l	a0,adr_modif_etape
	bsr	find_data_anim
	add.w	d0,x_modif2
	add.w	d3,y_modif2
	bsr	modif_data_etape
	bra	.okput
.pas1:	cmp.b	#2,put_mode
	bne	.pas2
	bsr	ins_anim_ascii	;----INS
	cmp.w	#1000,x_modif
	beq	.okput
	move.l	pt_anim,a0
	bsr	find_data_anim
	move.l	x_pos_anc,x_modif2
	add.w	d0,x_modif2
	add.w	d3,y_modif2
	move.l	pt_anim,a0
	bsr	find_end_string
	add.l	#1,a0
	move.l	a0,adr_modif_etape
	bsr	find_data_anim
	add.w	d0,x_modif2
	add.w	d3,y_modif2
	bsr	modif_data_etape
	bra	.okput
.pas2:	cmp.b	#3,put_mode
	bne	.pas3
	bsr	rep_anim_ascii	;----REP
	cmp.w	#1000,x_modif
	beq	.okput
	move.l	pt_anim,a0
	bsr	find_data_anim
	move.l	x_pos_anc,x_modif2
	add.w	d0,x_modif2
	add.w	d3,y_modif2
	move.l	pt_anim,a0
	bsr	find_end_string
	add.l	#1,a0
	move.l	a0,adr_modif_etape
	bsr	find_data_anim
	add.w	d0,x_modif2
	add.w	d3,y_modif2
	bsr	modif_data_etape
.okput:	clr.l	pt_took
	bsr	calc_no_eta
	bsr	aff_info_anim
	bsr	memo_page22
	bsr	aff_pos
	move.w	#0,d0
	jsr	graf_mouse
	bsr	show_m
	bra	loop_anim
.pas3:	illegal


ins_anim_ascii
	move.l	pt_anim,a0
	move.w	#1000,x_modif
	cmp.b	#1,flag_one
	bne	.ok
	tst.b	(a0)
	beq	.ok
	move.l	x_pos_anc,x_modif
	bsr	find_data_anim	;d0=dx d3=dy etape actuelle
	add.w	d0,x_modif
	add.w	d3,y_modif
.ok:	move.l	pt_anim,a0
	move.b	#2,d0
	bsr	insert_d00
	move.b	#13,(a0)		;cree une nll etape
	move.b	#10,1(a0)
	bra	oka0_anim

rep_anim_ascii
	move.l	pt_anim,a0
	bsr	find_end_string
	move.w	#1000,x_modif
	cmp.b	#1,flag_one
	bne	.ok
	tst.b	(a0)
	beq	.ok
	tst.b	1(a0)
	beq	.ok
	cmp.b	#";",1(a0)
	beq	.ok
	add.l	#1,a0	
	move.l	x_pos_anc,x_modif
	bsr	find_data_anim	;d0=dx d3=dy next etape
	add.w	d0,x_modif
	add.w	d3,y_modif
	move.l	pt_anim,a0
	bsr	find_data_anim	;d0=dx d3=dy etape actuelle
	add.w	d0,x_modif
	add.w	d3,y_modif
.ok:	move.l	pt_anim,a0
	bra	oka0_anim
	
add_anim_ascii
	move.l	pt_anim,a0
	bsr	find_end_string
	move.w	#1000,x_modif
	cmp.b	#1,flag_one
	bne	.ok
	tst.b	(a0)
	beq	.ok
	tst.b	1(a0)
	beq	.ok
	cmp.b	#";",1(a0)
	beq	.ok
	move.l	x_pos_anc,x_modif
	add.l	#1,a0	
	bsr	find_data_anim	;d0=dx d3=dy next etape
	add.w	d0,x_modif
	add.w	d3,y_modif
	move.l	pt_anim,a0
	bsr	find_data_anim	;d0=dx d3=dy etape actuelle
	add.w	d0,x_modif
	add.w	d3,y_modif
.ok:	move.l	pt_anim,a0
	tst.b	(a0)
	beq	oka0_anim
	move.b	#10,d0
	bsr	find_d0
	tst.b	(a0)	;a0 pointe sur sur la prochaine annim
	beq	oka0_anim
	move.b	#2,d0
	bsr	insert_d00
	move.b	#13,(a0)		;cree une nll etape
	move.b	#10,1(a0)
oka0_anim:
	move.l	a0,pt_anim
	bsr	calc_pos_anc
	cmp.b	#1,d0		;premiere etape ?
	bne	.non
	move.l	xmouse,x_pos_anc	;---- met les coord de depart
	move.l	xmouse,x_start	; de l'anim dans le REM
	;move.l	pt_anim,var5
	move.l	pt_anim,a0
.lop0:	cmp.b	#";",(a0)
	beq	.ok_deb
	sub.l	#1,a0
	bra	.lop0
.ok_deb:	move.l	a0,pt_anim
	move.l	a0,var5
	bsr	copy_pt_to_buf
	move.l	#buffer_pos,a0
	move.l	a0,a4
	add.l	#6,a4
	move.w	xmouse,d0
	bsr	change_vala4
	move.b	#",",d0
	bsr	find_d0
	move.w	ymouse,d0
	move.l	a0,a4
	bsr	change_vala4
	bsr	copy_buf_to_pt
	move.l	var5,a0	;adr_start_anim,a0
	move.b	#10,d0
	bsr	find_d0
	move.l	a0,pt_anim
	move.l	a0,adr_start_anim
.non	bsr	copy_pt_to_buf
	move.l	#buffer_pos,a0
	move.b	#"e",(a0)+
	move.b	#"t",(a0)+
	move.b	perso_name,(a0)+
	move.b	perso_name+1,(a0)+
	move.b	no_eta+1,(a0)+		;sera actualis‚
	move.b	no_eta+2,(a0)+
	move.b	no_eta+3,(a0)+
	move.b	#":",(a0)+
	move.b	#9,(a0)+		;tab
	move.b	#"A",(a0)+
	move.b	#"N",(a0)+
	move.b	#"I",(a0)+
	move.b	#9,(a0)+		;tab
	move.l	pt_took,a1
.lop1:	cmp.b	#":",(a1)
	beq	.end1
	move.b	(a1)+,(a0)+
	bra	.lop1
.end1:	move.b	#",",(a0)+
	move.w	xmouse,d0
	sub.w	x_pos_anc,d0
	ext.l	d0
	bsr	decode_d0_ascii
	move.b	#",",(a0)+
	move.w	ymouse,d0
	sub.w	y_pos_anc,d0
	ext.l	d0
	bsr	decode_d0_ascii
	move.b	#",",(a0)+
	move.b	#"n",(a0)+
	move.b	#"e",(a0)+
	move.b	#"x",(a0)+
	move.b	#"t",(a0)+
	move.b	#13,(a0)+
	move.b	#10,(a0)+
	bsr	copy_buf_to_pt
	rts

modif_data_etape:
	move.l	pt_anim,var5
	move.l	adr_modif_etape,pt_anim
	bsr	copy_pt_to_buf
	move.w	x_modif2,d0
	sub.w	x_modif,d0
	move.l	#buffer_pos,a0
	move.b	#",",d0
	bsr	find_d0
	move.l	a0,a4
	bsr	dec_a0_d0	;d0.w=ancien dx
	move.w	x_modif2,d1
	sub.w	x_modif,d1
	sub.w	d1,d0		;nouv dx
	bsr	change_vala4
	move.l	#buffer_pos,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	move.l	a0,a4
	bsr	dec_a0_d0	;d0.w=ancien dx
	move.w	y_modif2,d1
	sub.w	y_modif,d1
	sub.w	d1,d0		;nouv dy
	bsr	change_vala4
	bsr	copy_buf_to_pt
	move.l	var5,pt_anim
	rts
	rts

swap_all_one:
	bsr	hide_m
	bsr	raf_page21
	INVERSE
	LOCATE	36,3
	tst.b	flag_one
	beq	.set_one
	clr.b	flag_one
	bsr	print
	dc.b	"all",0
	bra	.return
.set_one:move.b	#1,flag_one
	bsr	print
	dc.b	"one",0
.return:	bsr	memo_page21
	bsr	raf_all_anim
	NORMAL
	bsr	show_m
	bsr	wait_no_clic
	bra	loop_anim

save_anim:
	bsr	save_anim2
	bra	loop_anim
	
save_anim2:
	bsr	hide_m
	move.w	#2,d0
	jsr	graf_mouse
	bsr	show_m
	bsr	check_anim
	move.l	d0,init_check_anim
	bsr	add_anim_flip
	bsr	add_equ_anim
	move.l	adr_anim_ascii,a0
	clr.b	d0
	bsr	find_d0
	sub.l	adr_anim_ascii,a0
	move.l	a0,d5
	sub.l	#1,d5
	move.l	adr_anim_ascii,d4
	move.l	#perso_ani_name,d3
	jsr	save
	move.l	adr_du_zero,a0
	clr.b	(a0)
	bsr	recree_no_etap
	bsr	hide_m
	move.w	#0,d0
	jsr	graf_mouse
	bsr	show_m
	rts
	
adr_fliped_anim:	dc.l	0

add_equ_anim:
	move.l	adr_anim_ascii,a0
	move.l	a0,var1		;chercheur de ';'
	clr.b	d0
	bsr	find_d0
	sub.l	#1,a0
	move.l	a0,var3		;fin de fichier
	move.l	a0,var2		;ecriture des 'equ'
.loop1:	move.l	var1,a0
.loop2	cmp.l	var3,a0
	beq	.end1
	cmp.b	#"e",(a0)
	bne	.cont
	cmp.b	#"t",1(a0)
	bne	.cont
	cmp.b	#10,-1(a0)
	bne	.cont
	REPT	8
	move.b	#" ",(a0)+	;efface les labels inutiles
	ENDR
	cmp.l	adr_fliped_anim,a0
	blt	.cont
	move.b	#" ",(a0)+
.cont:	cmp.b	#";",(a0)+
	bne	.loop2
	sub.l	#1,a0		;sur le ';'
	move.b	#"*",d0
	bsr	find_d0
	add.l	#2,a0
	move.l	a0,var1
	move.l	var2,a1
	move.w	#9,d0		;10 lettres max
.loop3:	cmp.b	#"_",(a0)
	beq	.end3
	move.b	(a0)+,(a1)+
	dbra	d0,.loop3
.end3:	move.b	#"_",(a1)+
	move.b	lettre1,(a1)+
	move.b	lettre2,(a1)+
	move.l	var1,d0
	cmp.l	adr_fliped_anim,d0
	blt	.ok
	move.b	#"f",(a1)+
.ok:	move.b	#":",(a1)+
	move.b	#9,(a1)+
	move.b	#"e",(a1)+
	move.b	#"q",(a1)+
	move.b	#"u",(a1)+
	move.b	#9,(a1)+
	move.l	var1,a0
	move.b	#10,d0
	bsr	find_d0
	tst.b	(a0)		;??
	beq	.end1
	cmp.b	#";",(a0)
	beq	.saut_ligne	;pas de 'et' apres le ';---'
.loop4:	cmp.b	#':',(a0)
	beq	.fin_copy
	move.b	(a0)+,(a1)+
	bra	.loop4
.fin_copy:
	move.l	a0,var1
.saut_ligne:
	move.b	#13,(a1)+
	move.b	#10,(a1)+
	move.l	a1,var2
	bra	.loop1
.end1:	move.l	var2,a1
	clr.b	(a1)
	rts
	
calc_pos_anc:
	move.l	pt_anim,a0
	cmp.l	adr_start_anim,a0
	beq	.set_start_pos
	sub.l	#2,a0		;pour eviter le premier 13,10 precedent
.lop1:	sub.l	#1,a0
	cmp.l	adr_start_anim,a0
	beq	.oka0
	cmp.b	#";",(a0)
	beq	.set_start_pos
	cmp.b	#10,(a0)
	bne	.lop1
	add.l	#1,a0
.oka0:	;-- a0=adr anim precedente
	cmp.l	adr_start_anim,a0
	beq	.set_start_pos2
	bsr	find_data_anim
	add.w	d0,x_pos_anc
	add.w	d3,y_pos_anc
	clr.b	d0
	rts
.set_start_pos:
	move.w	x_start,x_pos_anc	;car et001
	move.w	y_start,y_pos_anc
	move.b	#1,d0
	rts
.set_start_pos2:
	move.w	x_start,x_pos_anc	;car et002
	move.w	y_start,y_pos_anc
	bsr	find_data_anim
	add.w	d0,x_pos_anc
	add.w	d3,y_pos_anc
	clr.b	d0
	rts

calc_pos_anc_prev:
	move.l	pt_anim,a0
	cmp.l	adr_anim_ascii,a0
	beq	.rts
	sub.l	#2,a0		;pour eviter le premier 13,10 precedent
.lop1:	sub.l	#1,a0
	cmp.b	#";",(a0)
	beq	.rts
	cmp.l	adr_anim_ascii,a0
	beq	.oka0
	cmp.b	#10,(a0)
	bne	.lop1
	add.l	#1,a0
.oka0:	;-- a0=adr anim precedente
	bsr	find_data_anim
	sub.w	d0,x_pos_anc
	sub.w	d3,y_pos_anc
.rts:	rts


raf_all_anim:
	bsr	hide_m
	bsr	raf_page21

	move.l	pt_anim,a0
	tst.b	(a0)
	beq	.rts
	bsr	find_data_anim

	add.w	x_pos_anc,d0
	add.w	y_pos_anc,d3
	bsr	find_def_pos_a0
	bsr	aff_posxy
	bsr	aff_info_anim
.rts:	bsr	memo_page22
	bsr	aff_pos
	bsr	show_m
	rts

find_data_anim:
	move.b	#":",d0
	bsr	find_d0
	add.l	#5,a0	;a0 pointe sur 'pos...'
	move.l	a0,a1
	move.b	#",",d0
	bsr	find_d0
	bsr	dec_a0_d0	;d0=dx.w
	move.w	d0,d5
	bsr	dec_a0_d0
	move.w	d0,d3		;d3=dy.w
	move.w	d5,d0
	move.l	a1,a0
	rts
	
find_def_pos_a0:	;trouve la chaine posiv...:sp..,.. a partir de a0 (,posiv...,dx,dy)
	move.l	adr_tbl_pos,a1
.loop:	move.l	a0,a2
	move.l	a1,a3
	bsr	test_def_pos
	beq	.ok
	add.l	#1,a1
	cmp.l	adr_anim_ascii,a1
	blt	.loop
	move.l	#0,a2
	rts	;position non trouv‚e
.ok:	move.l	a1,a2
	rts
	
test_def_pos:
	cmp.b	#",",(a2)
	beq	.yes
	cmp.b	(a2)+,(a3)+
	beq	test_def_pos
.yes:	rts

calc_no_eta:
	move.l	adr_anim_ascii,a0
	move.l	#" 000",no_eta
.loop:	cmp.b	#";",(a0)
	beq	.next
	tst.b	(a0)
	beq	.end1
	add.l	#4,a0
	bsr	add_no_eta
	move.b	no_eta+1,(a0)+
	move.b	no_eta+2,(a0)+
	move.b	no_eta+3,(a0)+
.next:	move.b	#10,d0
	bsr	find_d0
	bra	.loop

.end1:	move.l	adr_anim_ascii,a0
.loop2:	cmp.l	pt_anim,a0
	beq	.ok
	tst.b	(a0)
	beq	.rts
	move.b	#10,d0
	bsr	find_d0
	bra	.loop2
.ok:	add.l	#4,a0
	move.b	(a0)+,no_eta+1
	move.b	(a0)+,no_eta+2
	move.b	(a0)+,no_eta+3
.rts:	rts
	
flag_work:	dc.w	0
put_mode:	dc.w	0
x_pos_anc:	dc.w	50
y_pos_anc:	dc.w	50
x_play:		dc.w	50
y_play:		dc.w	50
x_modif		dc.w	0
y_modif		dc.w	0
x_modif2		dc.w	0
y_modif2		dc.w	0
flag_one:	dc.w	0
menuanim_name:	dc.b	"\ecrspr\menuanim.pi1",0
	even
*------------------------- DEF ANIMATION ------------------
def_ani_perso:
	move.b	#1,flag_work	;0=pos 1=anim
	bsr	get_name_and_taille
	cmp.l	#-1,d0
	beq	ANIMATION	;si nom=RETURN
	tst.l	d0
	bne	.ok
	bsr	print
	dc.b	13,10,"Il faut d'abord definir une table de sprites !",13,10
	dc.b	"Pressez une touche",0
	bsr	getch
	bra	ANIMATION
.oui:	clr.l	d0
	bra	ANIMATION

.ok:
	;--loader la liste des sprites		(.TBL)
	move.l	#perso_tbl_name,d3
	move.l	#name_liste,d4
	jsr	load
	
	;--loader tous les sprites de cette table	(.SPR)
	move.l	#name_liste,a0
	bsr	load_liste_sprites
	
	;--loader le fichier des positions		(.POS)
	move.b	#1,flag_load_anim
	move.l	var2,adr_tbl_pos
	move.l	var2,pt_pos
	move.l	var2,pt_anim	;car pt_pos->pt_anim
	bsr	load_pal_pi1
	clr.l	data_pos_1
	clr.l	data_pos_2
	clr.l	data_ani_1
	clr.l	data_ani_2
	bsr	load_pos_rts
	tst.l	d0
	bne	def_ani_perso2
	bsr	print
	dc.b	13,10,"Il faut d'abord construire les postions du perso!",13,10
	dc.b	"Pressez une touche",0
	bsr	getch
	bra	ANIMATION

def_ani_perso2:
	move.w	#320-64,xmil
	move.w	#110,ymil
	clr.w	limhaut
	move.w	#200,limbas
	move.b	#1,flag_work	;0=pos 1=anim
	;--loader la table des anims		(.ANI)
	move.l	next_load_adr,a0
	move.b	#0,(a0)+
	move.b	#"/",(a0)+
	move.b	#"/",(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)
	move.l	a0,adr_anim_ascii
	move.l	a0,pt_anim
	move.l	a0,next_load_adr
	tst.b	flag_load_anim
	bne	.ok_lod
	move.l	adr_anim_stock,a0
	move.l	next_load_adr,a1
.lopcop:	move.b	(a0)+,(a1)+
	tst.b	-1(a1)
	bne	.lopcop
	bra	.finlod
.ok_lod:	move.w	#1000,d0
.lop01:	move.b	#$11,(a0)+
	dbra	d0,.lop01
	clr.b	buffer_pos
	move.l	#perso_ani_name,d3
	bsr	load_anim		;si existante
	bsr	check_anim
	move.l	d0,init_check_anim
	;bsr	load_pal_pi1
.finlod:	;move.l	adr_anim_ascii,pt_anim
	tst.l	data_ani_1
	beq	.first
	move.l	data_ani_1,d0
	add.l	d0,pt_anim
	move.l	adr_anim_ascii,adr_start_anim
	move.l	data_ani_2,d0
	add.l	d0,adr_start_anim
	bra	.ok_dat

.first:	bsr	find_start_anim
	move.l	#" 001",no_eta
	
.ok_dat:	move.w	#0,-(sp)
	move.l	page2,-(sp)
	move.l	page2,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp

	bsr	hide_m		;;;;
	move.b	#1,flag_one
	move.l	page2,d4
	tst.b	flag_stock	;page en mem ?
	beq	.load
	move.l	page_stock,a0
	move.l	page2,a1
	jsr	copyecr
	bra	.pageok
.load:	sub.l	#34,d4
	move.l	#menuanim_name,d3
	jsr	load
	INVERSE
	LOCATE	36,3
	bsr	print
	dc.b	"one",0
	NORMAL
	move.l	page2,a0
	sub.l	#32,a0
	move.l	#palette_top,a1
	move.w	#15,d0
.lop_pal	move.w	(a0)+,(a1)+
	dbra	d0,.lop_pal
	move.l	page2,a0
	move.l	page_stock,a1
	jsr	copyecr
	move.b	#1,flag_stock
.pageok:	LOCATE	6,3
	move.l	#info_anim_name-1,d0
	bsr	outstr
	
	bsr	memo_page21	;page vide pas touch‚e par sprites
	bsr	memo_page22
	jsr	int_on
re_anim:	bsr	raf_page22
	bsr	raf_all_anim
	bsr	aff_pos

	clr.w	d0
	bsr	graf_mouse
	bsr	show_m
loop_anim:
	tst.l	pt_took
	beq	.normal

	move.w	xmouse,d0
	cmp.w	anc_xmouse,d0
	bne	.okraf
	move.w	ymouse,d0
	cmp.w	anc_ymouse,d0
	beq	.normal
.okraf:	bsr	hide_m
	bsr	raf_page22
	move.w	xmouse,d0
	move.w	ymouse,d3
	move.w	d0,anc_xmouse
	move.w	d3,anc_ymouse
	tst.b	flag_1616
	beq	.snap0
	and.w	#$fff0,d0
.snap0:
	move.l	xmil,xmil2
	move.l	pt_pos,pt_pos2
	move.w	d0,xmil
	move.w	d3,ymil
	move.l	pt_took,pt_pos
	cmp.w	#16,d3
	bge	.oksp
	move.w	#16,ymil
.oksp:	bsr	aff_pos
	move.l	xmil2,xmil
	move.l	pt_pos2,pt_pos
	bsr	show_m
.normal:		
	move.l	adr_anim_ascii,a0
	cmp.l	pt_anim,a0
	bne	.non1
	tst.b	(a0)
	beq	create_anim		;car rien en memoire

.non1:	move.w	xmouse,d0
	move.w	ymouse,d3
	move.w	d0,anc_xmouse
	move.w	d3,anc_ymouse
	ext.l	d0
	ext.l	d3

	jsr	getinput
	cmp.b	#1,d0		;ESC
	beq	quit_loop_ani
	move.w	xmouse,d1
	move.w	ymouse,d2
	cmp.b	#201,d0
	bne	.pas_clic1
	tst.l	pt_took
	beq	.vide
	;tst.b	flag_1616
	;beq	.snap0
	;and.w	#$fff0,d1
;.snap0:
	bra	put_pos_anim
.vide	test_xy	114,125,6,17,prev_eta
	test_xy	128,140,6,17,next_eta
	test_xy	142,190,38,49,play_anim
	test_xy	193,204,6,17,prev_pos_anim
	test_xy	207,218,6,17,next_pos_anim
	test_xy	222,248,6,17,add_pos_anim
	test_xy	254,281,6,17,ins_pos_anim
	test_xy	221,250,22,33,rep_pos_anim
	test_xy	254,281,22,33,del_pos_anim
	test_xy	286,317,22,33,swap_all_one
	test_xy	219,267,36,49,save_anim
	test_xy	140,158,22,33,prev_anim
	test_xy	161,179,22,33,next_anim
	test_xy	91,139,38,50,create_anim
	test_xy	285,318,6,17,flip_pos_anim
	test_xy	1,43,22,33,rename_anim
	test_xy	270,317,38,49,goto_constr
	test_xy	1,49,38,49,delete_anim
	;test_xy	,debut_anim
	;test_xy	,fin_anim
.pas_clic1:
	cmp.b	#202,d0
	bne	.pas_clic2
	test_xy	140,158,22,33,prev_anim_spe
	test_xy	161,179,22,33,next_anim_spe
	tst.l	pt_took
	beq	.pas_clic2
	clr.l	pt_took
	bsr	hide_m
	bsr	raf_all_anim
	move.w	#0,d0
	bsr	graf_mouse
	bsr	show_m
.pas_clic2:
	cmp.b	#$3b,d0
	blt	.pas_pal
	cmp.b	#$44,d0
	bgt	.pas_pal
	bsr	set_pal_fd0
.pas_pal	cmp.b	#$66,d0
	bne	.pas_1616
	eor.b	#1,flag_1616
.pas_1616:
	bra	loop_anim

quit_loop_ani:
	bsr	hide_m
	bsr	check_anim
	cmp.l	init_check_anim,d0
	beq	.ok		;deja sauv‚
	move.l	adr_anim_ascii,a0
	tst.b	(a0)
	beq	.ok		;rien en memoire
	clr.b	d0	;message normal
	bsr	quitter_sauver
	beq	.ok
	bsr	raf_all_anim
	bsr	show_m
	bra	loop_anim
.ok:	bsr	kill_fliped_pos
	bsr	check_pos
	move.l	adr_zero_pos,a0
	move.b	val_zero_pos,d1
	move.b	d1,(a0)
	cmp.l	init_check_pos,d0
	beq	.ok2
	move.l	adr_tbl_pos,a0
	tst.b	(a0)
	beq	.ok2
	move.b	#1,d0		;'les positions'
	bsr	quitter_sauver
	bne	goto_constr
.ok2:	jsr	int_off
	bra	ANIMATION

pt_took:	dc.l	0
pt_anim:	dc.l	0

*----------------------- DEF ZONE -------------------
x_sprz1:	equ	80-60
x_sprz2:	equ	160-60
x_sprz3:	equ	240-60
y_sprz:	equ	60

def_zone_perso:
	clr.b	flag_work	;0=pos 1=anim
	bsr	get_name_and_taille
	cmp.l	#-1,d0
	beq	CONSTRUCT
	tst.l	d0
	bne	.ok
	bsr	print
	dc.b	13,10,"Table du perso non definie !",13,10
	dc.b	"Voullez-vous la construire ? (O/N)",0
	bsr	oui_non?
	beq	.oui
	bra	CONSTRUCT
.oui:	clr.l	d0
	bra	def_tbl_perso2

.ok:
	;loader la liste des sprites	(.TBL)
	move.l	#perso_tbl_name,d3
	move.l	#name_liste,d4
	jsr	load
	
	;loader tous les sprites de cette table	(.SPR)
	move.l	#name_liste,a0
	bsr	load_liste_sprites

	bsr	load_pal_pi1
	
debut_zone:
	move.w	#0,-(sp)
	move.l	page2,-(sp)
	move.l	page2,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#180,limbas
	move.w	#32,limhaut

	clr.l	adr_took
	clr.b	flag_zone
	move.l	#" 001",no_pos
	move.l	adr_tbl_pos,pt_pos
	move.l	pt_pos,a0
	move.b	#0,(a0)
	bsr	copy_pt_to_buf
	bsr	load_pos_rts	;si deja existant
	bsr	hide_m		;si pas deja fait
	bsr	aff_txt_zone	;ou .PI1
	bsr	memo_pagez
	bsr	aff_pos_zone
	bsr	aff_info_zone
	clr.w	d0
	bsr	graf_mouse
	bsr	show_m
loop_zone:
	jsr	getinput
	move.l	xmouse,d1
	cmp.l	anc_xmouse,d1
	beq	.pas_aff
	tst.b	flag_defence_z
	beq	.padef
	bsr	aff_data_def
.padef:	tst.b	flag_zone
	beq	.pas_aff
	move.w	d0,-(sp)
	bsr	hide_m
	move.w	anc_xmouse,d0
	move.w	anc_ymouse,d1
	bsr	draw_box_zone	;efface ancien
	move.w	xmouse,d0
	move.w	ymouse,d1
	bsr	draw_box_zone	;affiche actuelle
	move.l	xmouse,anc_xmouse
	bsr	show_m
	move.w	(sp)+,d0
.pas_aff:cmp.b	#1,d0
	beq	quit_loop_zone
	cmp.b	#201,d0	;----- test si clic souris ----
	bne	.pas_clic
	move.w	xmouse,d1
	move.w	ymouse,d2
	test_xy	112,128,0,8,prev_pos_z
	test_xy	134,152,0,8,next_pos_z
	test_xy	224,231,0,8,add_force
	test_xy	240,248,0,8,sub_force
	test_xy	288,320,176,184,save_pos_z
	test_xy	144,199,175,183,swap_defence_z
	tst.b	flag_zone
	bne	.cont2
	test_xy	32,96,16,31,start_zone1
	test_xy	144,183,16,31,start_zone2
	test_xy	240,272,16,31,start_zone3
	bra	.cont1
.cont2:
	cmp.b	#40,flag_zone
	bge	.fin_box
	bsr	hide_m
	move.w	xmouse,d0
	move.w	ymouse,d1
	bsr	draw_box_zone	;efface ancien
	add.b	#40,flag_zone
	move.l	xmouse,x1_box_ok
	move.w	xmouse,d0
	move.w	ymouse,d1
	bsr	draw_box_zone	;affiche new
	bsr	show_m
	bsr	wait_no_clic
	bra	.cont1
.fin_box:
	move.l	xmouse,x2_box_ok
	bsr	fin_box
	clr.b	flag_zone
	bsr	hide_m
	bsr	eff_pagez
	bsr	aff_pos_zone
	bsr	aff_info_zone
	bsr	memo_pagez
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_zone
.pas_clic:
	cmp.w	#202,d0
	bne	.cont1
	bsr	hide_m
	tst.b	flag_zone
	beq	.pas_eff
	move.w	xmouse,d0
	move.w	ymouse,d1
	bsr	draw_box_zone	;efface ancien
	clr.b	flag_zone
.pas_eff:move.w	#0,d0
	bsr	graf_mouse
	bsr	show_m
.cont1:	bra	loop_zone

quit_loop_zone:
	bsr	hide_m
	bsr	copy_buf_to_pt
	bsr	check_pos
	cmp.l	init_check_pos,d0
	beq	.ok		;deja sauv‚
	move.l	adr_tbl_pos,a0
	tst.b	(a0)
	beq	.ok		;rien en memoire
	bsr	quitter_sauver
	beq	.ok
	bsr	raf_page2
	bsr	show_m
	bra	loop_pos
.ok:	;bsr	check_anim
	;cmp.l	init_check_anim,d0
	;beq	.ok2		;deja sauv‚
	;move.l	adr_anim_ascii,a0
	;tst.b	(a0)
	;beq	.ok2		;rien en memoire
	;move.b	#2,d0		;'les anim'
	;bsr	quitter_sauver
	;bne	goto_anim
.ok2:	bra	CONSTRUCT
	
flag_defence_z:	dc.b	0
xref_def:	dc.w	0
yref_def:	dc.w	0
swap_defence_z:	
	move.l	adr_zero_pos,a0		;permet les pos flip‚es
	move.b	val_zero_pos,d0
	move.b	d0,(a0)
	eor.b	#1,flag_defence_z
	tst.b	flag_defence_z
	bne	.return
	LOCATE	26,22
	bsr	print
	dc.b	"       ",0
.return:	jsr	wait_no_clic
	bra	loop_zone

aff_data_def:
	movem.l	d0-d7/a0-a6,-(sp)
	LOCATE	26,22
	move.w	xmouse,d0
	move.w	xref_def,d1
	sub.w	d1,d0
	ext.l	d0
	bsr	aff_d0_decim
	bsr	print
	dc.b	",",0
	move.w	ymouse,d0
	move.w	yref_def,d1
	sub.w	d1,d0
	ext.l	d0
	bsr	aff_d0_decim
	bsr	print
	dc.b	"  ",0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

aff_d0_decim:
	tst.l	d0
	bgt	.ok
	move.l	d0,-(sp)
	bsr	print
	dc.b	"-",0
	move.l	(sp)+,d0
	neg.l	d0
.ok:	move.l	#buffer,a0
	bsr	dec_d0_long
	clr.b	(a0)
	move.l	#buffer,d0
	bsr	outstr
.rts:	rts

flag_box2:	dc.w	0
fin_box:
	bsr	hide_m
	move.w	xmouse,d0
	move.w	ymouse,d1
	bsr	draw_box_zone	;efface ancien
	move.w	x1_box_ok,xg
	move.w	y1_box_ok,yh
	move.w	x2_box_ok,xd
	move.w	y2_box_ok,yb
	move.w	x2_box_ok,lxt
	move.w	x1_box_ok,d0
	sub.w	d0,lxt
	move.w	y2_box_ok,lyt
	move.w	y1_box_ok,d0
	sub.w	d0,lyt
	move.l	page2,ecrpts
	jsr	encadre
	move.w	#0,d0
	bsr	graf_mouse
	bsr	show_m
	sub.b	#40,flag_zone	;1,2,ou3
	;clr.b	flag_zone
	move.l	#adr_long,a0
	move.w	x1_box_ok,d0
	move.w	#x_sprz1,d1
	move.w	#y_sprz,d2
	cmp.b	#1,flag_zone
	beq	.ok
	move.w	#x_sprz2,d1
	cmp.b	#2,flag_zone
	beq	.ok
	move.w	#x_sprz3,d1
.ok:	bsr	d0x_in_a0
	move.w	y1_box_ok,d0
	bsr	d0y_in_a0
	move.w	x2_box_ok,d0
	bsr	d0x_in_a0
	move.w	y2_box_ok,d0
	bsr	d0y_in_a0
	;--- calcul de adr_long en hexa ,dans pt_pos
	bsr	copy_pt_to_buf
	move.l	#buffer_pos,a0
	move.b	#9,d0		;TAB
	bsr	find_d0
	bsr	find_d0
	cmp.b	#1,flag_zone
	beq	.oka0
	move.b	#",",d0
	bsr	find_d0
	cmp.b	#2,flag_zone
	beq	.oka0
	move.b	#",",d0
	bsr	find_d0
.oka0:	;--- a0=adr pour nombre .l = dx1,dy1,dx2,dy2 (adr_long)
	move.l	a0,a1
	move.b	#",",d0
	bsr	find_d0
	sub.l	a1,a0
	sub.l	#1,a0	;a0=long nombre actuel
	move.l	a0,d1
	move.l	a1,a0
	cmp.l	#9,d1
	beq	.a0_pret
	bgt	.del
	move.l	#9,d0
	sub.l	d1,d0
	move.l	a1,a0
	bsr	insert_d0
	bra	.a0_pret
.del:	sub.l	#9,d1
	move.l	d1,d0
	bsr	delete_d0
.a0_pret:
	move.l	adr_long,d0
	move.b	#"$",(a0)+
	bsr	code_d0_hex
	bsr	copy_buf_to_pt
	rts
	
d0x_in_a0:	
	sub.w	d1,d0	;d0=dx relatif au zero du sprite
	cmp.w	#128,d0
	bge	error_127
	cmp.w	#-127,d0
	blt	error_127
	move.b	d0,(a0)+
	rts


d0y_in_a0:
	sub.w	d2,d0	;d0=dy relatif au zero du sprite
	cmp.w	#128,d0
	bge	error_127
	cmp.w	#-127,d0
	blt	error_127
	move.b	d0,(a0)+
	rts
	
error_127:
	bsr	hide_m
	move.w	x1_box_ok,xg
	move.w	y1_box_ok,yh
	move.w	x2_box_ok,xd
	move.w	y2_box_ok,yb
	move.w	x2_box_ok,lxt
	move.w	x1_box_ok,d0
	sub.w	d0,lxt
	move.w	y2_box_ok,lyt
	move.w	y1_box_ok,d0
	sub.w	d0,lyt
	move.l	page2,ecrpts
	move.w	#15,col_pl
	bsr	encadre
	move.w	#clpl,col_pl
	clr.l	adr_long
	bsr	show_m
	move.l	(sp)+,d0		;depile le bsr	fin_box
	rts
	
adr_long:	dc.l	0
flag_load_pos:	dc.w	0
flag_1616:	dc.w	0


*********************** Choix_flip ********************
choix_flip:
	clr.l	adr_anim_ascii
	bsr	get_name_and_taille
	cmp.l	#-1,d0
	beq	CONSTRUCT
	tst.l	d0
	bne	.ok
	bsr	print
	dc.b	13,10,"Table du perso non definie !",13,10
	dc.b	"Voullez-vous la construire ? (O/N)",0
	bsr	oui_non?
	beq	.oui
	bra	CONSTRUCT
.oui:	clr.l	d0
	bra	def_tbl_perso2

.ok:
	;loader la liste des sprites	(.TBL)
	move.l	#perso_tbl_name,d3
	move.l	d3,a0
	move.b	lettre1,pref_flip_x
	move.b	lettre2,pref_flip_x+1
	move.l	#name_liste,d4
	jsr	load
	
	;loader tous les sprites de cette table	(.SPR)
	move.l	#name_liste,a0
	bsr	load_liste_sprites

	bsr	load_pal_pi1
	move.l	#name_liste,pt_spr_en_cours
	LOCATE	0,2
	bsr	print
	dc.b	"Level ?(0-9)",0
	bsr	getch
	move.b	d0,nb_lev_flip
	LOCATE	5,10
	bsr	print
	dc.b	"F=a fliper",0
	LOCATE	5,12
	bsr	print
	dc.b	"N=Ne pas fliper",0
	move.b	#7,no_bit
	move.l	#champ_bits,pt_bits
loop_ch_flip:
	move.l	pt_spr_en_cours,a0
	bsr	calc_adr_spr		;selon a0 sur 12 carac
	move.l	d0,adr_spr_en_cours
	jsr	aff_spr_en_cours
	jsr	aff_info
.key:	jsr	getch
	swap	d0
	move.b	#0,d1
	cmp.b	#$21,d0	;'f'
	beq	.ok_key
	move.b	#1,d1
	cmp.b	#$31,d0	;"n"
	beq	.ok_key
	bra	.key
.ok_key:	move.l	pt_bits,a0
	move.b	no_bit,d0
	bclr	d0,(a0)
	tst.b	d1
	beq	.next_bit
	bset	d0,(a0)
.next_bit:
	sub.b	#1,no_bit
	bge	.okbit
	move.b	#7,no_bit
	add.l	#1,pt_bits
.okbit:	move.l	pt_spr_en_cours,a0
	add.l	#12,a0
	tst.l	(a0)
	beq	.non
	move.l	a0,pt_spr_en_cours
	bra	loop_ch_flip
.non:	move.l	#name_flip_x,d3
	move.l	#champ_bits,d4
	move.l	pt_bits,d5
	sub.l	#champ_bits,d5
	add.l	#1,d5
	jsr	save
	bra	CONSTRUCT

name_flip_x:	dc.b	"\ivan_dat\set"
pref_flip_x:	dc.b	"XX_L"
nb_lev_flip:	dc.b	"Z.FLP",0
no_bit:		dc.b	0
pt_bits:		dc.l	0
champ_bits:	ds.b	32	;256 sprites max
*----------------------- DEF .TBL ----------------------------------
def_tbl_perso:
	bsr	get_name_and_taille
def_tbl_perso2:
	tst.l	d0
	beq	.no_lod
	cmp.l	#-1,d0
	beq	CONSTRUCT
	move.l	#perso_tbl_name,d3
	move.l	#name_liste,d4
	move.l	d4,a0
	add.l	d0,a0
	move.l	a0,pt_next_liste
	jsr	load
.no_lod:	
	move.w	#0,d0
	bsr	graf_mouse
	bsr	show_m
	move.l	#liste_txt,a0
	bsr	file_liste
	bsr	hide_m
	bra	CONSTRUCT

constr_pos:
	clr.l	adr_anim_ascii
	bsr	get_name_and_taille
	cmp.l	#-1,d0
	beq	CONSTRUCT
	tst.l	d0
	bne	.ok
	bsr	print
	dc.b	13,10,"Table du perso non definie !",13,10
	dc.b	"Voullez-vous la construire ? (O/N)",0
	bsr	oui_non?
	beq	.oui
	bra	CONSTRUCT
.oui:	clr.l	d0
	bra	def_tbl_perso2

.ok:
	;loader la liste des sprites	(.TBL)
	move.l	#perso_tbl_name,d3
	move.l	#name_liste,d4
	jsr	load
	
	;loader tous les sprites de cette table	(.SPR)
	move.l	#name_liste,a0
	bsr	load_liste_sprites

	bsr	load_pal_pi1
	move.b	#1,flag_load_pos
	move.b	#1,flag_load_anim
	clr.l	data_pos_1
	clr.l	data_ani_1
	clr.l	data_ani_2
debut_pos:
	move.l	data_pos_1,pt_pos
	move.l	data_pos_2,pt_spr_en_cours
	tst.l	data_pos_1
	bne	.okdat
	move.l	adr_tbl_pos,pt_pos
	move.l	#name_liste,pt_spr_en_cours
	move.l	#" 001",no_pos
.okdat:	move.w	#150,limbas
	move.w	#24,limhaut
	clr.b	flag_work	;0=pos 1=anim
	move.w	#$40,xmil
	move.w	#$40,ymil
	move.w	#0,-(sp)
	move.l	page2,-(sp)
	move.l	page2,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp

	clr.l	adr_took
	move.l	#" 000",nb_spr_pos

	move.l	pt_spr_en_cours,a0
	bsr	calc_adr_spr	;selon a0 sur 12 carac
	move.l	d0,adr_spr_en_cours
	tst.b	flag_load_pos
	beq	.palod1
	move.l	pt_pos,a0
	move.b	#0,(a0)
.palod1:	bsr	copy_pt_to_buf
	tst.b	flag_load_pos
	beq	.palod2
	bsr	load_pos_rts	;si deja existant
.palod2:	bsr	aff_txt_pos	;ou .PI1
	bsr	aff_all_pos
	clr.w	d0
	bsr	graf_mouse
	bsr	show_m
loop_pos:
	tst.l	adr_took
	beq	.normal
	move.w	xmouse,d0
	cmp.w	anc_xmouse,d0
	bne	.okraf
	move.w	ymouse,d0
	cmp.w	anc_ymouse,d0
	beq	.normal
.okraf:	bsr	hide_m
	bsr	raf_page2
	move.w	xmouse,d0
	move.w	ymouse,d3
	move.w	d0,anc_xmouse
	move.w	d3,anc_ymouse
	tst.b	flag_1616
	beq	.snap0
	and.w	#$fff0,d0
.snap0:	ext.l	d0
	ext.l	d3
	move.l	adr_took,a2
.oksp:	bsr	sprafxy
	bsr	show_m
.normal	bsr	getinput
	tst.b	d0
	beq	.pas_aff
	cmp.b	#202,d0
	beq	.pas_aff
	cmp.b	#$3b,d0
	blt	.pas_pal
	cmp.b	#$44,d0
	bgt	.pas_pal
	bsr	set_pal_fd0
.pas_pal	cmp.b	#$66,d0
	bne	.pas_1616
	eor.b	#1,flag_1616
.pas_1616:
	move.l	d0,-(sp)
	bsr	aff_all_pos
	move.l	(sp)+,d0
.pas_aff:cmp.b	#1,d0
	beq	quit_loop_pos
	cmp.b	#201,d0	;----- test si clic souris ----
	bne	.pas_clic
	move.w	xmouse,d1
	move.w	ymouse,d2
	test_xy	$d0,$e8,8,16,prev_spr
	test_xy	$f0,$108,8,16,next_spr
	test_xy	$118,$138,8,16,take_spr
	test_xy	$40,$50,8,16,prev_pos
	test_xy	$58,$68,8,16,next_pos
	test_xy	$30,$58,$b0,$b8,clear_pos
	test_xy	$120,$140,$b0,$b8,save_pos_ascii
	test_xy	$e8,$110,$b0,$b8,load_pos_ascii
	test_xy	$a0,$c0,8,16,flip_spr_pos
	test_xy	0,32,176,184,flip_pos
	test_xy	112,160,175,182,insert_pos
	test_xy	168,192,176,184,delete_pos
	test_xy	256,280,152,160,sur_spr
	test_xy	288,318,152,160,sous_spr
	test_xy	224,248,152,160,del_spr
	test_xy	288,320,191,199,goto_anim
	tst.l	adr_took
	beq	.pas_add
	tst.b	flag_1616
	beq	.snap02
	and.w	#$fff0,xmouse
.snap02:	
	test_xy	0,300,16,180,add_spr
.pas_add:
.pas_clic:
	cmp.w	#202,d0		;clic droite
	bne	.pas_clic2
	test_xy	$40,$50,8,16,prev_pos10
	test_xy	$58,$68,8,16,next_pos10
	tst.l	adr_took
	beq	.pas_notook
	bsr	hide_m
	bsr	raf_page2
	clr.l	adr_took
	move.w	#0,d0
	bsr	graf_mouse
	bsr	show_m
	bra	loop_pos
.pas_notook:
	move.w	xmouse,d1
	move.w	ymouse,d2
	test_xy	$d0,$e8,8,16,prev_spr_202
	test_xy	$f0,$108,8,16,next_spr_202
.pas_clic2
	tst.l	adr_pos_edit
	beq	.pas_depl
	cmp.b	#$4b,d0
	beq	depl_spr_gau
	cmp.b	#$4d,d0
	beq	depl_spr_dro
	cmp.b	#$48,d0
	beq	depl_spr_hau
	cmp.b	#$50,d0
	beq	depl_spr_bas
.pas_depl:
	bra	loop_pos

quit_loop_pos:
	bsr	hide_m
	bsr	copy_buf_to_pt
	bsr	check_pos
	cmp.l	init_check_pos,d0
	beq	.ok		;deja sauv‚
	move.l	adr_tbl_pos,a0
	tst.b	(a0)
	beq	.ok		;rien en memoire
	bsr	quitter_sauver
	beq	.ok
	bsr	eff_page2
	bsr	aff_all_pos
	bsr	show_m
	bra	loop_pos
.ok:	
	move.l	adr_anim_ascii,a0
	cmp.l	#0,a0
	beq	.ok2
	bsr	check_anim
	cmp.l	init_check_anim,d0
	beq	.ok2		;deja sauv‚
	tst.b	(a0)
	beq	.ok2		;rien en memoire
	move.b	#2,d0		;'les anim'
	bsr	quitter_sauver
	bne	goto_anim
.ok2:	bra	CONSTRUCT

goto_anim:
	bsr	copy_buf_to_pt
	bsr	create_pos_flip
	jsr	wait_no_clic
	move.l	adr_tbl_pos,a0
	clr.b	d0
	bsr	find_d0
	move.l	a0,next_load_adr
	move.l	pt_pos,data_pos_1
	move.l	pt_spr_en_cours,data_pos_2
	bra	def_ani_perso2

goto_constr:
	jsr	wait_no_clic
	jsr	int_off
	move.l	#palette2,-(sp)
	move.w	#setpal,-(sp)
	trap	#xbios
	addq.l	#6,sp
	bsr	kill_fliped_pos
	;bsr	check_pos
	;move.l	d0,init_check_pos
	clr.b	flag_load_pos
	bsr	hide_m
	move.l	adr_anim_ascii,a0
	move.l	a0,a2
	clr.b	d0
	bsr	find_d0
	sub.l	a2,a0	;a0=long ani ascii
	move.l	a0,d0
	add.w	#10,d0
	move.l	page_stock,a1
	sub.l	d0,a1
	move.l	a1,adr_anim_stock
.loop:	move.b	(a2)+,(a1)+
	dbra	d0,.loop
	move.b	#0,flag_load_anim
	move.l	pt_anim,data_ani_1
	move.l	adr_anim_ascii,d0
	sub.l	d0,data_ani_1		;offset de pt_anim
	move.l	adr_start_anim,data_ani_2
	sub.l	d0,data_ani_2		;offset de adr_start_anim
	bra	debut_pos

quitter_sauver:
	move.b	d0,-(sp)
	LOCATE	6,8
	INVERSE
	bsr	print
	dc.b	"                           ",0
	LOCATE	6,9
	bsr	print
	dc.b	" ! VOUS N'AVEZ PAS SAUVE ! ",0
	LOCATE	6,10
	bsr	print
	dc.b	"                           ",0
	LOCATE	13,10
	move.b	(sp)+,d0
	tst.b	d0
	beq	.normal
	cmp.b	#1,d0
	bne	.pas_pos
	bsr	print
	dc.b	"(les POSITIONS)",0
	bra	.normal
.pas_pos:cmp.b	#2,d0
	bne	.normal
	bsr	print
	dc.b	"(les ANIMATIONS)",0,0
.normal:	LOCATE	6,11
	bsr	print
	dc.b	"   VOULEZ-VOUS QUITTER ?   ",0
	LOCATE	6,12
	bsr	print
	dc.b	"                           ",0
	LOCATE	16,13
	bsr	print
	dc.b	"OUI / NON",0
	NORMAL
	bsr	oui_non?
	rts

*---------------------------------------------------------------------
aff_txt_zone:
	LOCATE	0,0
	bsr	print
	dc.b	"position"
	dc.b	" 001",0
	LOCATE	16,0
	bsr	print
	dc.b	"-",0
	LOCATE	0,24
	move.l	#perso_pos_name,d0
	bsr	outstr
	INVERSE
	LOCATE	14,0
	bsr	print
	dc.b	" <",0
	LOCATE	17,0
	bsr	print
	dc.b	"> ",0
	LOCATE	4,2
	bsr	print
	dc.b	"Colision",0
	LOCATE	4,3
	bsr	print
	dc.b	" Decors ",0
	LOCATE	18,22
	bsr	print
	dc.b	"Defence",0
	LOCATE	18,2
	bsr	print
	dc.b	"Zone ",0
	LOCATE	18,3
	bsr	print
	dc.b	"bless",0
	LOCATE	30,2
	bsr	print
	dc.b	"Zone",0
	LOCATE	30,3
	bsr	print
	dc.b	"Coup",0
	LOCATE	28,0
	bsr	print
	dc.b	"+",0
	LOCATE	30,0
	bsr	print
	dc.b	"-",0
	LOCATE	36,22
	bsr	print
	dc.b	"SAVE",0
	NORMAL
	LOCATE	22,0
	bsr	print
	dc.b	"Force"
	rts

aff_info_zone:
	bsr	aff_no_pos
	bsr	aff_force_coup
	rts

aff_force_coup:
	LOCATE	32,0
	move.l	pt_pos,a0
	tst.b	(a0)
	beq	.rts
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0		;a0 pointe sur $0100...
	bsr	dec_a0_hexa
	lsr.l	#8,d0
	lsr.l	#8,d0
	lsr.l	#8,d0		;1er octet de d0
	move.l	#buffer,a0
	bsr	dec_d0_long
	clr.b	(a0)
	move.l	#buffer,d0
	bsr	outstr
	bsr	print
	dc.b	"   ",0
.rts:	rts


add_force:
	bsr	copy_pt_to_buf
	move.l	#buffer_pos,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0		;a0 pointe sur $0100...
	move.l	a0,-(sp)
	bsr	dec_a0_hexa
	add.l	#$01000000,d0
	move.l	d0,adr_long
	move.l	(sp)+,a0
	bsr	put_in_a0_hex
	bsr	aff_force_coup
	bsr	wait_no_clic
	bra	loop_zone

sub_force:
	bsr	copy_pt_to_buf
	move.l	#buffer_pos,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0		;a0 pointe sur $0100...
	move.l	a0,-(sp)
	bsr	dec_a0_hexa
	cmp.l	#$00ffffff,d0
	ble	.return
	sub.l	#$01000000,d0
	move.l	d0,adr_long
	move.l	(sp)+,a0
	bsr	put_in_a0_hex
	bsr	hide_m
	bsr	aff_force_coup
	bsr	show_m
	bsr	wait_no_clic
.return:	bra	loop_zone


set_pal_fd0:
	;entree:d0=#3b a #44
	;sortie:set palette no 1 a 10
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d0,var1
	SUPER
	move.w	var1,d0
	sub.b	#$3b,d0		;d0 de 0 a 9
	ext.w	d0
	lsl.w	#5,d0		;d0*32
	move.l	#liste_palettes,a0
	add.l	d0,a0		;a0=adr nouvelle palette
	move.l	#palette2,a1
	move.l	#$ff8240,a2
	move.w	#15,d0
.loop:	move.w	(a0),(a2)+
	move.w	(a0)+,(a1)+
	dbra	d0,.loop
	USER
	movem.l	(sp)+,d0-d7/a0-a6
	rts


put_in_a0_hex:
	;--- a0=adr pour nombre .l (adr_long)
	move.l	a0,a1
	move.b	#",",d0
	bsr	find_d0
	sub.l	a1,a0
	sub.l	#1,a0	;a0=long nombre actuel
	move.l	a0,d1
	move.l	a1,a0
	cmp.l	#9,d1
	beq	.a0_pret
	bgt	.del
	move.l	#9,d0
	sub.l	d1,d0
	move.l	a1,a0
	bsr	insert_d0
	bra	.a0_pret
.del:	sub.l	#9,d1
	move.l	d1,d0
	bsr	delete_d0
.a0_pret:
	move.l	adr_long,d0
	move.b	#"$",(a0)+
	bsr	code_d0_hex
	bsr	copy_buf_to_pt
	rts

*--------------------------------------	
draw_box_zone:	;entree d0.w=x d1.w=y
	cmp.w	#319,d0
	ble	.ok
	move.w	#319,d0
.ok:	cmp.b	#40,flag_zone
	bge	.box2
	move.w	d0,x1_box
	move.w	d1,y1_box
	move.w	#319,x2_box
	move.w	#199,y2_box
	bsr	draw_box_hor
	add.w	#1,y1_box	;pour le coin haut gauche
	bsr	draw_box_ver
	rts
.box2:	cmp.w	x1_box_ok,d0
	ble	.rts
	cmp.w	y1_box_ok,d1
	ble	.rts
	movem.w	d0-d1,-(sp)
	move.w	x1_box_ok,x1_box	;x1
	move.w	d0,x2_box	;x2
	move.w	y1_box_ok,y1_box
	move.w	d1,y2_box
	sub.w	#1,y2_box
	bsr	draw_box_hor	;---- ligne haut
	add.w	#1,y1_box	;pour le coin haut gauche
	bsr	draw_box_ver
	move.w	y2_box,y1_box
	add.w	#1,y1_box
	move.w	x1_box_ok,x1_box	;---- ligne bas
	bsr	draw_box_hor
	movem.w	(sp)+,d0-d1
	move.w	d0,x1_box
	move.w	y1_box_ok,y1_box
	add.w	#1,y1_box
	bsr	draw_box_ver
.rts:	rts
	
draw_box_hor:	;x1,x2,y1
	move.w	x1_box,d0
	lsr.w	#4,d0		;x1/16
	lsl.w	#3,d0		;bloc *8
	ext.l	d0
	move.w	x2_box,d1
	lsr.w	#4,d1		;x1/16
	lsl.w	#3,d1		;bloc *8
	ext.l	d1
	move.w	y1_box,d2
	mulu	#160,d2
	move.l	page2,a0
	add.l	d2,a0
	add.l	a0,d1
	add.l	d0,a0

	move.w	x1_box,d0
	and.w	#$f,d0		;reste:0 a 15
	move.w	#$ffff,d4
	lsr.w	d0,d4
	move.w	(a0),d3
	eor.w	d4,d3
	move.w	d3,(a0)+
	move.w	(a0),d3
	eor.w	d4,d3
	move.w	d3,(a0)+
	move.w	(a0),d3
	eor.w	d4,d3
	move.w	d3,(a0)+
	move.w	(a0),d3
	eor.w	d4,d3
	move.w	d3,(a0)+
.loop:	cmp.l	a0,d1
	blt	.rts
	move.l	(a0),d3
	eor.l	#$ffffffff,d3
	move.l	d3,(a0)+
	move.l	(a0),d3
	eor.l	#$ffffffff,d3
	move.l	d3,(a0)+
	bra	.loop
.rts	rts
	
draw_box_ver:	;y1,y2,x1
	move.w	x1_box,d0
	lsr.w	#4,d0		;x1/16
	lsl.w	#3,d0		;bloc *8
	ext.l	d0
	move.w	y1_box,d1
	mulu	#160,d1
	move.w	y2_box,d2
	mulu	#160,d2
	move.l	page2,a0
	add.l	d0,a0
	add.l	a0,d2		;limite bas
	add.l	d1,a0		;depart
	move.w	x1_box,d0
	and.w	#$f,d0		;reste:0 a 15
	move.w	#$8000,d1
	lsr.w	d0,d1
	move.w	d1,d4
.loop:	cmp.l	a0,d2
	blt	.rts
	move.l	a0,a1
	move.w	(a0),d3
	eor.w	d1,d3	;inversion du bit actif
	move.w	d3,(a0)+
	move.w	(a0),d3
	eor.w	d1,d3	;inversion du bit actif
	move.w	d3,(a0)+
	move.w	(a0),d3
	eor.w	d1,d3	;inversion du bit actif
	move.w	d3,(a0)+
	move.w	(a0),d3
	eor.w	d1,d3	;inversion du bit actif
	move.w	d3,(a0)+
	move.l	a1,a0
	add.l	#160,a0
	bra	.loop
.rts:	rts


flag_zone:	dc.w	0
x1_box:		dc.w	0
y1_box:		dc.w	0
x2_box:		dc.w	0
y2_box:		dc.w	0
x1_box_ok:	dc.w	0
y1_box_ok:	dc.w	0
x2_box_ok:	dc.w	0
y2_box_ok:	dc.w	0
	
flip_spr_pos:
	tst.b	flag_fliped
	beq	.set
	clr.b	flag_fliped
	bra	.ok
.set:	move.b	#1,flag_fliped
.ok:	tst.l	adr_took
	beq	.ok1
	bsr	hide_m
	bsr	raf_page2
.ok1:	
	move.l	adr_spr_en_cours,a2
	;tst.b	flag_fliped
	;beq	.ok
	move.w	(a2),d2		;nb lignes
	move.w	2(a2),d1		;nb blocs
	add.w	#1,d1
	add.w	#1,d2
	mulu	d2,d1
	mulu	#8,d1	;8 octets par bloc
	add.l	#8,d1
	tst.b	flag_fliped
	beq	.sub
	add.l	d1,a2
	bra	.oka2
.sub:	sub.l	d1,a2
.oka2:	move.l	a2,adr_spr_en_cours
	bsr	aff_spr_en_cours
	;bsr	aff_info
	tst.l	adr_took
	beq	.ok2
	bsr	memo_page2
	bsr	show_m
.ok2:	bsr	wait_no_clic
.non:	bra	loop_pos
	
flag_fliped:	dc.w	0

flip_pos:move.l	#buffer_pos,a0
	bsr	flip_pos_ascii
	bsr	hide_m
	bsr	eff_page2
	bsr	aff_pos
	bsr	aff_spr_en_cours
	bsr	show_m
	bsr	wait_no_clic
	bra	loop_pos
	
flip_pos_ascii:	;entree:a0=adr chaine ascii pos
	move.l	a0,-(sp)
	move.b	#":",d0
	bsr	find_d0
	sub.l	#1,a0
	cmp.b	#"f",-1(a0)
	beq	.kill_f
	move.b	#1,d0
	bsr	insert_d0
	move.b	#"f",(a0)
	bra	.ok_f
.kill_f:	move.b	#1,d0
	sub.l	#1,a0	;a0 pointe sur le f
	bsr	delete_d0
.ok_f:	move.l	(sp)+,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0
.deb_nom:cmp.b	#"0",(a0)
	beq	.end_all
	move.l	a0,a3		;a3=adr nom sprite
	move.l	a0,a5
	bsr	set_plus1a3
	bsr	calc_adr_spr	;selon a0 sur 12 carac
	move.l	d0,a2
	tst.l	d0		;adr du sprite non trouv‚?
	beq	.end_all		;erreur ->quit
	add.l	#1,a0
	move.l	a0,a4		;a4=adr dx
	bsr	dec_a0_d0	;decode dx
	neg.w	d0		;-x gauche
	move.w	2(a2),d5		;lx
	add.w	#1,d5		;nb de blocs
	mulu	#16,d5		;larg totale en pixels
	sub.w	d5,d0		;nouveau x gauche
	bsr	change_vala4
	move.l	a5,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0		;a0=adr nom suivant
	bra	.deb_nom
.end_all:
	rts

add_anim_flip:
	move.l	adr_anim_ascii,a0
	clr.b	d0
	bsr	find_d0
	move.l	a0,adr_fliped_anim
	move.l	a0,a1
	sub.l	adr_anim_ascii,a0
	move.l	a0,d5
	sub.l	#2,d5	;d5=long sans flip-1
	move.l	adr_anim_ascii,a0
	sub.l	#1,a1
	move.l	a1,a2
	move.l	a1,adr_du_zero
.loop:	move.b	(a0)+,(a1)+
	dbra	d5,.loop
	clr.b	(a1)
	move.l	a2,a0
	move.b	#1,d0
	bsr	flip_anim_ascii
	move.l	adr_anim_ascii,pt_anim
	bsr	find_start_anim
	rts

flip_anim_ascii:
	;entree :a0=pt debut chaineS etapeS
	;	d0=flag mettre 'f' a etxxxf:
	move.l	a0,pt_anim
	move.b	d0,var4
.loop:	bsr	copy_pt_to_buf
	move.l	#buffer_pos,a0
	move.b	var4,d0
	bsr	flip_et_ascii
	bsr	copy_buf_to_pt
	move.l	pt_anim,a0
	bsr	find_end_string
	tst.b	(a0)
	beq	.return
	add.l	#1,a0
	move.l	a0,pt_anim
	bra	.loop
.return:	rts

flip_et_ascii:
	;entree :a0=pt debut chaine d'UNE etape et1F: ani pos1F,0,0,et2F
	;	d0=flag mettre 'f' a etxxxf:
	cmp.b	#";",(a0)
	beq	.rts
	move.l	a0,var1
	move.b	d0,var2
.loop:	tst.b	var2
	beq	.pas_f_et
	move.l	var1,a0
	move.b	#":",d0
	bsr	find_d0
	cmp.b	#"f",-2(a0)
	beq	.pas_f_et	;pas normal:deja un f
	sub.l	#1,a0
	move.b	#1,d0
	bsr	insert_d0
	move.b	#"f",(a0)
.pas_f_et:
	move.l	var1,a0
	move.b	#",",d0		;1ere virgule
	bsr	find_d0
	cmp.b	#"f",-2(a0)
	beq	.del_f
	sub.l	#1,a0
	move.b	#1,d0
	bsr	insert_d0
	move.b	#"f",(a0)
	bra	.ok_f
.del_f:	sub.l	#2,a0
	move.b	#1,d0
	bsr	delete_d0
.ok_f:	move.l	var1,a0
	move.b	#",",d0
	bsr	find_d0
	move.l	a0,a4
	bsr	dec_a0_d0	;d0.w=dx
	neg.w	d0
	ext.l	d0
	bsr	change_vala4
	;------------- si pas 'next',changer et000f
	move.l	var1,a0
	bsr	find_end_string	;a0 sur 10 ou 0
	tst.b	(a0)
	beq	.rts
	sub.l	#2,a0		;sur le 't' de 'next'
	cmp.b	#"t",(a0)
	beq	.rts
	cmp.b	#"f",(a0)	;------ pas next:etape------
	beq	.del_f2
	add.l	#1,a0
	move.b	#1,d0
	bsr	insert_d0
	move.b	#"f",(a0)
	bra	.ok_f2
.del_f2:	;sub.l	#2,a0
	move.b	#1,d0
	bsr	delete_d0
.ok_f2:	
.rts:	rts

change_vala4:
	movem.l	d1-d3/a0/a4,-(sp)
	move.l	a4,a0
	move.l	a0,d1
	move.l	a0,d2
	move.w	d0,d3
	 ; move.b	#",",d0
	 ; bsr	find_d0
	bsr	find_no_chiffre
	sub.l	d1,a0
	sub.l	#1,a0
	move.l	a0,d1		;d1=long nombre actuel
	move.l	#buffer2,a0
	move.w	d3,d0
	bsr	decode_d0_ascii
	sub.l	#buffer2,a0	;a0=long d0 ascii
	move.l	a0,d3
	sub.l	d1,a0
	cmp.l	#0,a0
	beq	.copy
	bgt	.insert
	move.l	a0,d0
	neg.l	d0
	move.l	d2,a0	;adr nombre actuel
	bsr	delete_d0
.copy:	sub.l	#1,d3
	move.l	#buffer2,a0
	move.l	d2,a1
.lop1:	move.b	(a0)+,(a1)+
	dbra	d3,.lop1
.return:	movem.l	(sp)+,d1-d3/a0/a4
	rts
.insert:	move.l	a0,d0
	move.l	d2,a0
	bsr	insert_d0
	bra	.copy
	
delete_d0:	;delete d0 octets de la chaine a0 finie par 10 ou 0
	movem.l	d1/a1,-(sp)
	move.l	a0,a1
	clr.l	d1
	move.b	d0,d1
	add.l	d1,a0
.lop:	move.b	(a0),(a1)
	tst.b	(a0)
	beq	.return
	cmp.b	#10,(a0)
	beq	.return
	add.l	#1,a0
	add.l	#1,a1
	bra	.lop
.return:	movem.l	(sp)+,d1/a1
	rts

delete_d00:	;delete d0.l octets de la chaine a0 finie par 0
	movem.l	d1/a1,-(sp)
	move.l	a0,a1
	clr.l	d1
	move.l	d0,d1
	add.l	d1,a0
.lop:	move.b	(a0),(a1)
	tst.b	(a0)
	beq	.return
	add.l	#1,a0
	add.l	#1,a1
	bra	.lop
.return:	movem.l	(sp)+,d1/a1
	rts

set_plus1a3:
	movem.l	d0/a0-a1,-(sp)
	move.l	a3,a0
	move.b	#",",d0
	bsr	find_d0
	sub.l	#1,a0
	move.l	a0,a1
	sub.l	#2,a1
	cmp.b	#"+",(a1)
	bne	.ins
	move.l	a1,a0
	move.b	#2,d0
	bsr	delete_d0
	bra	.return
	
.ins:	move.b	#2,d0
	bsr	insert_d0
	move.b	#"+",(a0)+
	move.b	#"1",(a0)+
.return:	movem.l	(sp)+,d0/a0-a1
	rts
	
insert_d0:	;decale la chaine point‚e par a0 de d0 octets
		;fin de chaine:10 ou 0
	movem.l	d1-d2/a0-a1,-(sp)
	move.l	a0,d2
	bsr	find_end_string	;a0
	clr.l	d1
	move.b	d0,d1
	move.l	a0,a1
	add.l	d1,a1
.loop:	move.b	(a0),(a1)
	cmp.l	d2,a0
	beq	.ret
	sub.l	#1,a0
	sub.l	#1,a1
	bra	.loop
.ret:	movem.l	(sp)+,d1-d2/a0-a1
	rts

insert_d00:	;decale la chaine point‚e par a0 de d0 octets
		;fin de chaine:0
	movem.l	d1-d2/a0-a1,-(sp)
	move.l	a0,d2
	clr.l	d1
	move.b	d0,d1
	clr.b	d0
	bsr	find_d0
	sub.l	#1,a0
	move.l	a0,a1
	add.l	d1,a1
.loop:	move.b	(a0),(a1)
	cmp.l	d2,a0
	beq	.ret
	sub.l	#1,a0
	sub.l	#1,a1
	bra	.loop
.ret:	movem.l	(sp)+,d1-d2/a0-a1
	rts
	

find_no_chiffre:
	cmp.b	#"-",(a0)
	beq	.next
.loop:	cmp.b	#"0",(a0)
	blt	.end
	cmp.b	#"9",(a0)
	bgt	.end
.next:	add.l	#1,a0
	bra	.loop
.end:	add.l	#1,a0
	rts

find_end_string:
	tst.b	(a0)
	beq	.rts
	cmp.b	#10,(a0)
	beq	.rts
	add.l	#1,a0
	bra	find_end_string
.rts:	rts

buffer2:	ds.b	80

aff_all_pos:
	bsr	aff_pos		;selon pt_pos
	bsr	aff_spr_en_cours
	bsr	aff_info
	rts

aff_pos_zone:
	move.w	#x_sprz1,xmil	;80
	move.w	#y_sprz,ymil	;100
	bsr	aff_pos
	clr.b	d6	;nb de virgules avant le 1er $
	bsr	aff_cadre_zone
	move.w	#x_sprz2,xmil	;150
	bsr	aff_pos
	move.b	#1,d6	;nb de virgules avant le 2em $
	bsr	aff_cadre_zone
	move.w	xg,xref_def
	move.w	yh,yref_def
	move.w	#x_sprz3,xmil	;240
	bsr	aff_pos
	move.b	#2,d6	;nb de virgules avant le 3em $
	bsr	aff_cadre_zone
	rts
	
aff_cadre_zone:
	move.l	#buffer_pos,a0
	move.b	#9,d0		;TAB
	bsr	find_d0
	bsr	find_d0
.lop_f:	tst.b	d6
	beq	.oka0
	move.b	#",",d0
	bsr	find_d0
	sub.b	#1,d6
	bra	.lop_f
.oka0:	cmp.b	#"$",(a0)
	bne	.rts		;rien
	add.l	#1,a0	;apres le '$'
	move.l	#adr_long,a1
	clr.l	(a1)
	move.w	#3,d2		;4 octets
.lop_dec:move.b	(a0)+,d0
	bsr	.decim
	lsl.b	#4,d0		;*16
	add.b	d0,(a1)
	move.b	(a0)+,d0
	bsr	.decim
	add.b	d0,(a1)+
	dbra	d2,.lop_dec

	move.w	xmil,xg
	move.w	ymil,yh
	move.w	xmil,xd
	move.w	ymil,yb
	move.l	#adr_long,a0
	move.b	(a0)+,d0
	ext.w	d0
	add.w	d0,xg
	move.b	(a0)+,d0
	ext.w	d0
	add.w	d0,yh
	move.b	(a0)+,d0
	ext.w	d0
	add.w	d0,xd
	move.b	(a0)+,d0
	ext.w	d0
	add.w	d0,yb

	move.w	xd,lxt
	move.w	xg,d0
	sub.w	d0,lxt
	move.w	yb,lyt
	move.w	yh,d0
	sub.w	d0,lyt
	move.l	page2,ecrpts
	bsr	encadre
.rts:	rts

.decim:	sub.b	#48,d0
	cmp.b	#10,d0
	blt	.rts
	sub.b	#7,d0
	rts

dec_a0_hexa:
*----------------decode (a0)+ en ascii hexa --> d0.l ---------------
	clr.l	d0
	cmp.b	#"$",(a0)
	bne	.rts		;rien
	add.l	#1,a0	;apres le '$'
	move.l	#adr_long,a1
	clr.l	(a1)
	move.w	#3,d2		;4 octets
.lop_dec:move.b	(a0)+,d0
	bsr	.decim
	lsl.b	#4,d0		;*16
	add.b	d0,(a1)
	move.b	(a0)+,d0
	bsr	.decim
	add.b	d0,(a1)+
	dbra	d2,.lop_dec
	move.l	adr_long,d0
.rts:	rts

.decim:	sub.b	#48,d0
	cmp.b	#10,d0
	blt	.rts
	sub.b	#7,d0
	rts


*---------------------------------
aff_pos:	;affiche tous les sprites d'une position
	;pt_pos=adr du texte ascii de la position
	move.l	#" 000",nb_spr_pos
	move.l	#buffer_pos,a0	;pt_pos,a0
	tst.b	flag_work
	beq	.tbl1
	move.l	pt_pos,a0
.tbl1:	tst.b	(a0)
	beq	.rts
	cmp.b	#13,(a0)
	beq	.rts
	cmp.b	#10,1(a0)
	beq	.rts
	move.l	a0,-(sp)
	cmp.b	#2,flag_work
	beq	.pas_hi
	;bsr	hide_m
.pas_hi:	tst.l	adr_took
	beq	.no1
	tst.b	flag_work
	bne	.no1
	bsr	raf_page2
.no1	move.l	(sp)+,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0		;a1=adr de la 4eme virgule +1
	;a0=nom du sprite

.deb_nom:cmp.b	#"0",(a0)
	beq	.end_all
	bsr	calc_adr_spr	;selon a0 sur 12 carac
	move.l	d0,a2
	add.l	#1,a0
	bsr	dec_a0_d0	;decode dx
	add.w	xmil,d0
	move.w	d0,d4
	bsr	dec_a0_d0	;decode dy
	add.w	ymil,d0
	move.w	d0,d3
	move.w	d4,d0
	ext.l	d0
	ext.l	d3
	move.l	a0,-(sp)
	bsr	sprafxy
	bsr	add_nb_spr
	move.l	(sp)+,a0
	bra	.deb_nom
	
.end_all:tst.l	adr_took
	beq	.no2
	tst.b	flag_work
	bne	.no2
	bsr	aff_info
	bsr	memo_page2
.no2:	cmp.b	#2,flag_work
	beq	.rts
	;bsr	show_m
.rts:	rts


find_d0:		;cherche d0 dans a0 ;sortie:a0 sur cara suivant
	cmp.b	(a0)+,d0
	bne	find_d0
	rts
	
find_d0_back:	;cherche d0 dans a0 en reculant (a0 sur cara)
	cmp.b	-(a0),d0
	bne	find_d0_back
	rts
	
dec_a0_d0:  ;decode nombre ascii point‚ par a0,termin‚ par autre chose qu'un chiffre
	   ;sortie:d0.w sign‚
	clr.b	d2
	cmp.b	#'-',(a0)
	bne	.ok0
	move.b	#1,d2
	add.l	#1,a0
.ok0	clr.l	d0
.loop:	bsr	.conv
	cmp.b	#10,d1
	bcc	.ok
	mulu	#10,d0
	add.l	d1,d0
	bra	.loop
.ok:	tst.b	d2
	beq	.rts
	neg.w	d0
.rts:	rts

.conv:	clr.l	d1
	move.b	(a0)+,d1
	sub.b	#"0",d1
	rts


copy_spr_ascii:	;a0=source a1=dest  ;copy 'ABCD,xx,yyy'
	clr.b	d0	;nb de virgules
.loop:	cmp.b	#",",(a0)
	bne	.ok
	cmp.b	#2,d0
	beq	.rts
	add.b	#1,d0
.ok:	move.b	(a0)+,(a1)+
	bra	.loop
.rts:	rts


start_zone1:
	move.b	#1,flag_zone
	bsr	hide_m
	move.w	#22,d0		;point
	bsr	graf_mouse
	move.l	xmouse,anc_xmouse
	move.w	xmouse,d0
	move.w	ymouse,d1
	bsr	draw_box_zone	;affiche actuelle
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_zone
start_zone2:
	move.b	#2,flag_zone
	bsr	hide_m
	move.w	#22,d0		;point
	bsr	graf_mouse
	move.l	xmouse,anc_xmouse
	move.w	xmouse,d0
	move.w	ymouse,d1
	bsr	draw_box_zone	;affiche actuelle
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_zone
start_zone3:
	move.b	#3,flag_zone
	bsr	hide_m
	move.w	#22,d0		;point
	bsr	graf_mouse
	move.l	xmouse,anc_xmouse
	move.w	xmouse,d0
	move.w	ymouse,d1
	bsr	draw_box_zone	;affiche actuelle
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_zone


*------------------------------------------------------------------------------
add_spr:	move.l	#buffer_pos,a0	;pt_pos,a0
	cmp.b	#13,(a0)		;ligne vide ?
	beq	.new
	cmp.b	#10,1(a0)
	beq	.new
	tst.b	(a0)
	bne	.add_deja
.new:	;----- creation d'une nouvelle position -----
	  ;posiv001:	POS	-12,-1,25,45,ivb1,0,0,ivb2,5,26,ivm2,-65,128,0
	  ;=definition de la position no 1 d'ivanoe: 
	  ;(taille du cadre pour tests=-12x,-1y a +25x,+45y) r(xiv,yiv)
	  ;+sprite ivb1.spr en 0,0 r(xiv,yiv) ,sprite ivb2 en 5,26 ,etc...
	move.b	#"p",(a0)+
	move.b	#"o",(a0)+
	move.b	#"s",(a0)+
	move.b	perso_name,(a0)+
	move.b	perso_name+1,(a0)+
	move.b	no_pos+1,(a0)+
	move.b	no_pos+2,(a0)+
	move.b	no_pos+3,(a0)+
	move.b	#":",(a0)+
	move.b	#9,(a0)+		;tab
	move.b	#"P",(a0)+
	move.b	#"O",(a0)+
	move.b	#"S",(a0)+
	move.b	#9,(a0)+		;tab
	move.b	#"0",(a0)+
	move.b	#",",(a0)+
	move.b	#"0",(a0)+
	move.b	#",",(a0)+
	move.b	#"0",(a0)+
	move.b	#",",(a0)+
	move.b	#"0",(a0)+
	move.b	#",",(a0)+
.deja:
	move.l	pt_spr_en_cours,a1	;--- copy nom sprite
.lop:	cmp.b	#" ",(a1)
	beq	.endlop
	cmp.b	#".",(a1)
	beq	.endlop
	move.b	(a1)+,(a0)+
	bra	.lop
.endlop:	
	tst.b	flag_fliped
	beq	.ok
	move.b	#"+",(a0)+
	move.b	#"1",(a0)+	;set bit 0 pour flip‚ ->impaire
.ok:	move.w	xmouse,d0
	sub.w	xmil,d0
	move.b	#",",(a0)+
	bsr	decode_d0_ascii
	move.b	#",",(a0)+
	move.w	ymouse,d0
	sub.w	ymil,d0
	bsr	decode_d0_ascii
	move.b	#",",(a0)+
	move.b	#"0",(a0)+	;fin de cette position
	move.b	#13,(a0)+
	move.b	#10,(a0)+
.trop:	bsr	aff_pos
	clr.l	adr_took
	bsr	aff_info
	bsr	hide_m
	move.w	#0,d0
	bsr	graf_mouse
	bsr	show_m
	bra	loop_pos

.add_deja:	;-- chercher le dernier 0
	move.b	#13,d0
	bsr	find_d0
	sub.l	#2,a0	;a0 pointe sur le 0
	cmp.l	#fin_buffer_pos,a0
	bge	.trop
	bra	.deja


prev_spr:
	clr.b	flag_fliped
	move.l	pt_spr_en_cours,a0
	sub.l	#12,a0
	cmp.l	#name_liste,a0
	blt	.non
	move.l	a0,pt_spr_en_cours
	bsr	calc_adr_spr
	move.l	d0,adr_spr_en_cours
	tst.l	adr_took
	beq	.ok1
	bsr	hide_m
	bsr	raf_page2
.ok1	bsr	aff_spr_en_cours
	bsr	aff_info
	tst.l	adr_took
	beq	.ok2
	bsr	memo_page2
	bsr	show_m
.ok2:	bsr	wait_no_clic
.non:	bra	loop_pos

next_spr_202:	;find le prochain sprite avec *
	move.l	pt_spr_en_cours,a0
.loop:	add.l	#12,a0
	tst.l	(a0)
	beq	loop_pos
	move.l	a0,a4
	bsr	copy_spr_buffer
	move.l	#buffer,a0
	bsr	contened_spr	;?
	bne	.next
	move.l	a4,a0
	bra	new_spr
.next:	move.l	a4,a0
	bra	.loop

prev_spr_202:	;find le precedent sprite avec *
	move.l	pt_spr_en_cours,a0
.loop:	cmp.l	#name_liste,a0
	beq	loop_pos
	sub.l	#12,a0
	move.l	a0,a4
	bsr	copy_spr_buffer
	move.l	#buffer,a0
	bsr	contened_spr	;?
	bne	.next
	move.l	a4,a0
	bra	new_spr
.next:	move.l	a4,a0
	bra	.loop

next_spr:
	clr.b	flag_fliped
	move.l	pt_spr_en_cours,a0
	add.l	#12,a0
new_spr:	tst.l	(a0)
	beq	.non
	move.l	a0,pt_spr_en_cours
	bsr	calc_adr_spr
	move.l	d0,adr_spr_en_cours
	tst.l	adr_took
	beq	.ok1
	bsr	hide_m
	bsr	raf_page2
.ok1	bsr	aff_spr_en_cours
	bsr	aff_info
	tst.l	adr_took
	beq	.ok2
	bsr	memo_page2
	bsr	show_m
.ok2:	bsr	wait_no_clic
.non:	bra	loop_pos

take_spr:
	bsr	hide_m
	tst.l	adr_took
	beq	.ok
	bsr	raf_page2
.ok:	move.l	adr_spr_en_cours,adr_took
	;move.l	adr_tbl_pos,a0
	bsr	memo_page2
	move.w	#22,d0		;point
	bsr	graf_mouse
	bsr	show_m
	bsr	wait_no_clic
	move.l	#buffer_pos,a0	;pt_pos,a0
	tst.b	(a0)
	beq	._1er
	cmp.b	#13,(a0)
	beq	._1er
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0
	cmp.b	#"0",(a0)
	bne	.no1er
	cmp.b	#13,1(a0)
	bne	.bug
	cmp.b	#10,2(a0)
	bne	.bug
._1er:	move.w	xmil,xmouse
	move.w	ymil,ymouse
	bra	add_spr
.no1er:	bra	loop_pos
.bug:	illegal

depl_spr_gau:
	move.w	#-1,d5
	clr.w	d6
	bra	depl_spr
depl_spr_dro:
	move.w	#1,d5
	clr.w	d6
	bra	depl_spr
depl_spr_hau:
	move.w	#-1,d6
	clr.w	d5
	bra	depl_spr
depl_spr_bas:
	move.w	#1,d6
	clr.w	d5

depl_spr:	;entree: d5=dx   d6=dy   adr_spr_edit=adr dans buffer_pos
	move.l	adr_pos_edit,a0
	move.b	#",",d0
	bsr	find_d0
	move.l	a0,a4
	bsr	dec_a0_d0	;d0.w=dx
	add.w	d5,d0
	bsr	change_vala4
	move.l	adr_pos_edit,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	move.l	a0,a4
	bsr	dec_a0_d0	;d0.w=dx
	add.w	d6,d0
	bsr	change_vala4
	bra	end_modif_pos

del_spr:	tst.l	adr_pos_edit
	beq	loop_pos		;pas ce sprite !
	move.l	adr_pos_edit,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0
	move.l	adr_pos_edit,d1
	sub.l	d1,a0
	move.l	a0,d0		;d0=long (spr,dx,dy)
	move.l	d1,a0
	bsr	delete_d0
end_modif_pos:
	bsr	copy_buf_to_pt
	bsr	eff_page2
	bsr	aff_pos
	bsr	memo_page2
	bsr	aff_spr_en_cours
	bsr	aff_info
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_pos

sous_spr:tst.l	adr_pos_edit
	beq	loop_pos		;pas ce sprite !
	move.l	#buffer_pos,a0	;pt_pos,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0		;a0=adr 1er sprite
	cmp.l	adr_pos_edit,a0
	bge	loop_pos
	move.l	adr_pos_edit,a0
	move.l	#buffer,a1
	bsr	copy_spr_ascii	;copy sprite edit ->buffer
	move.b	#",",(a1)
	move.l	adr_pos_edit,a0
	move.b	#",",d0
	bsr	find_d0_back
	bsr	find_d0_back
	bsr	find_d0_back
	bsr	find_d0_back
	add.l	#1,a0
	move.l	a0,a2
	move.l	#buffer2,a1
	bsr	copy_spr_ascii	;copy sprite preced ->buffer2
	move.b	#",",(a1)
	move.l	#buffer,a0
	move.l	a2,a1
	bsr	copy_spr_ascii	;copy buffer2 ->
	move.b	#",",(a1)+
	move.l	#buffer2,a0
	bsr	copy_spr_ascii	;copy buffer ->
	bra	end_modif_pos
	;bsr	copy_buf_to_pt
	;bsr	eff_page2
	;bsr	aff_pos
	;bsr	memo_page2
	;bsr	aff_spr_en_cours
	;bsr	aff_info
	;bsr	wait_no_clic
	;bsr	show_m
	;bra	loop_pos

sur_spr:tst.l	adr_pos_edit
	beq	loop_pos		;pas ce sprite !
	;bsr	copy_buf_to_pt
	move.l	adr_pos_edit,a0
	move.l	#buffer,a1
	bsr	copy_spr_ascii	;copy sprite edit ->buffer
	move.b	#",",(a1)
	move.l	adr_pos_edit,a0
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0
	cmp.b	#"0",(a0)
	beq	loop_pos
	move.l	#buffer2,a1
	bsr	copy_spr_ascii	;copy sprite suiv ->buffer2
	move.b	#",",(a1)
	move.l	#buffer2,a0
	move.l	adr_pos_edit,a1
	bsr	copy_spr_ascii	;copy buffer2 ->
	move.b	#",",(a1)+
	move.l	#buffer,a0
	bsr	copy_spr_ascii	;copy buffer ->
	;bsr	copy_pt_to_buf
	bsr	copy_buf_to_pt
	bsr	eff_page2
	bsr	aff_pos
	bsr	memo_page2
	bsr	aff_spr_en_cours
	bsr	aff_info
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_pos

next_pos_gener:
	bsr	copy_buf_to_pt
	move.l	pt_pos,a0
.loop:	tst.b	(a0)
	beq	.oka0
	cmp.b	#10,(a0)+
	bne	.loop
	move.l	a0,pt_pos
	bsr	add_no_pos
	bra	.cont
.oka0:	move.l	a0,pt_pos
.cont:	bra	copy_pt_to_buf
	rts

next_pos_z:
	bsr	hide_m
	bsr	next_pos_gener
	bsr	eff_pagez
	bsr	aff_pos_zone
	bsr	aff_info_zone
	bsr	memo_pagez
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_zone

prev_pos_z:
	bsr	hide_m
	bsr	prev_pos_gener
	bsr	eff_pagez
	bsr	aff_pos_zone
	bsr	aff_info_zone
	bsr	memo_pagez
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_zone

next_pos10:
	bsr	hide_m
	REPT	10
	bsr	next_pos_gener
	ENDR
	bra	next_pos_suite


next_pos:
	bsr	hide_m
	bsr	next_pos_gener
next_pos_suite:
	bsr	eff_page2
	bsr	aff_pos
	bsr	memo_page2
	bsr	aff_spr_en_cours
	bsr	aff_info
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_pos

prev_pos_gener:
	bsr	copy_buf_to_pt
	move.l	pt_pos,a0
	cmp.l	adr_tbl_pos,a0
	beq	.rts
	move.l	pt_pos,a0
	sub.l	#1,a0
.loop:	cmp.l	adr_tbl_pos,a0
	beq	.oka0
	cmp.b	#10,-(a0)
	bne	.loop
	add.l	#1,a0
.oka0:	move.l	a0,pt_pos
	bsr	sub_no_pos
.rts:	bsr	copy_pt_to_buf
	rts

prev_pos10:
	bsr	hide_m
	REPT	10
	bsr	prev_pos_gener
	ENDR
	bra	prev_pos_suite

prev_pos:
	bsr	hide_m
	bsr	prev_pos_gener
prev_pos_suite:
	bsr	eff_page2
	bsr	memo_page2
	bsr	aff_pos
	bsr	aff_info
	bsr	aff_spr_en_cours
	bsr	wait_no_clic
	bsr	show_m
	bra	loop_pos

insert_pos:
	move.l	pt_pos,a0
	tst.b	(a0)
	beq	loop_pos
	cmp.b	#13,(a0)
	beq	loop_pos
	cmp.b	#10,(a0)
	beq	loop_pos
	bsr	copy_pt_to_buf
	move.l	#buffer_pos,a0
	move.b	#2,d0
	bsr	insert_d0
	move.b	#"?",(a0)+
	move.b	#"?",(a0)+
	bsr	copy_buf_to_pt
	move.l	pt_pos,a0
	move.b	#13,(a0)+
	move.b	#10,(a0)+
	bsr	copy_pt_to_buf
	bsr	hide_m
	bsr	eff_page2
	bsr	memo_page2
	bsr	aff_pos
	bsr	aff_info
	bsr	aff_spr_en_cours
	bsr	calc_all_no_pos
	bsr	show_m
	bsr	wait_no_clic
	bra	loop_pos
	
	
delete_pos:
	move.l	pt_pos,a0
	tst.b	(a0)
	beq	loop_pos
	move.l	a0,a1
	bsr	find_end_string	;a0 pointe sur le 10
	sub.l	a1,a0
	move.l	a0,d0
	add.l	#1,d0
	move.l	a1,a0
	bsr	delete_d00
	bsr	copy_pt_to_buf
	bsr	hide_m
	bsr	eff_page2
	bsr	memo_page2
	bsr	aff_pos
	bsr	aff_info
	bsr	aff_spr_en_cours
	bsr	calc_all_no_pos
	bsr	show_m
	bsr	wait_no_clic
	bra	loop_pos

calc_all_no_pos:
	move.l	no_pos,buffer		;sauve no_pos actuel
	move.l	#" 001",no_pos
	move.l	adr_tbl_pos,a0
.loop1:	tst.b	(a0)
	beq	.return
	cmp.b	#":",(a0)+
	bne	.loop1
	sub.l	#4,a0
	move.b	no_pos+1,(a0)+
	move.b	no_pos+2,(a0)+
	move.b	no_pos+3,(a0)+
	move.l	a0,-(sp)
	bsr	add_no_pos
	move.l	(sp)+,a0
	add.l	#6,a0		;pour eviter le ':' deja trouv‚
	bra	.loop1
.return:	move.l	buffer,no_pos
	rts
	

clear_pos:
	move.l	#buffer_pos,a0
	tst.b	(a0)
	beq	loop_pos
	cmp.b	#"p",(a0)
	bne	.bug
	move.b	#",",d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0
	bsr	find_d0	;a0 pointe sur le nom du 1er sprite
	move.b	#"0",(a0)+
	move.b	#13,(a0)+
	move.b	#10,(a0)+
	bsr	copy_buf_to_pt
	bsr	hide_m
	bsr	eff_page2
	bsr	memo_page2
	move.l	#" 000",nb_spr_pos
	bsr	aff_info
	bsr	aff_spr_en_cours
	bsr	show_m
	bra	loop_pos
.bug:	illegal


edit_pos:
	bra	loop_pos

save_pos_ascii:
	bsr	calc_all_no_pos
	bsr	save_pos_gener
	move.l	adr_du_zero,a0
	clr.b	(a0)
	bra	loop_pos
save_pos_z:
	bsr	save_pos_gener
	move.l	adr_du_zero,a0
	clr.b	(a0)
	bra	loop_zone
	
save_pos_gener:
	bsr	hide_m
	move.w	#2,d0
	bsr	graf_mouse
	bsr	show_m
	bsr	copy_buf_to_pt
	bsr	check_pos
	move.l	d0,init_check_pos
	bsr	create_pos_flip
	move.l	adr_tbl_pos,a0
	move.l	a0,a1
	clr.b	d0
	bsr	find_d0
	sub.l	a1,a0
	move.l	a0,d5
	sub.l	#1,d5
	move.l	a1,d4
	move.l	#perso_pos_name,d3
	bsr	save
	bsr	hide_m
	move.w	#0,d0
	bsr	graf_mouse
	bsr	show_m
	rts
	

create_pos_flip:
	move.l	pt_pos,var2
	move.l	adr_tbl_pos,a0
	clr.b	d0
	bsr	find_d0
	sub.l	#1,a0		;a0 pointe sur le 0 final
	move.l	a0,adr_du_zero
	move.l	a0,var1			;pt des positions flip‚es
	move.l	a0,var3
	move.l	adr_tbl_pos,pt_pos	;pt des positions non flip‚es
.loop:	bsr	copy_pt_to_buf
	move.l	#buffer_pos,a0
	tst.b	(a0)
	beq	.fin
	bsr	flip_pos_ascii
	bsr	flip_zone_ascii
	move.l	#buffer_pos,a0
	move.l	var1,a1
.loop2:	move.b	(a0)+,(a1)+
	tst.b	-1(a0)
	beq	.fin
	cmp.b	#10,-1(a0)
	bne	.loop2
	move.l	a1,var1
	move.l	pt_pos,a0
	bsr	find_end_string	;next pos
	add.l	#1,a0
	move.l	a0,pt_pos
	cmp.l	var3,a0
	bne	.loop
.fin:	move.l	var1,a0
	clr.b	(a0)		;fin de fichier
	move.l	var2,pt_pos
	bsr	copy_pt_to_buf
	rts
	
flip_zone_ascii:
	move.l	#buffer_pos,a0
	move.b	#9,d0		;TAB
	bsr	find_d0
	bsr	find_d0
	cmp.b	#"$",(a0)
	bne	.zon2
	add.l	#1,a0
	bsr	flip_zone_a0
.zon2:	move.b	#",",d0
	bsr	find_d0
	cmp.b	#"$",(a0)
	bne	.zon3
	add.l	#1,a0
	bsr	flip_zone_a0
.zon3:	move.b	#",",d0
	bsr	find_d0
	cmp.b	#"$",(a0)
	bne	.rts
	add.l	#1,a0
	bsr	flip_zone_a0
.rts:	rts

flip_zone_a0:
	move.l	a0,-(sp)
	move.l	a0,a6
	move.l	#adr_long,a1
	clr.l	(a1)
	move.w	#3,d2		;4 octets
.lop_dec:move.b	(a0)+,d0
	bsr	.decim
	lsl.b	#4,d0		;*16
	add.b	d0,(a1)
	move.b	(a0)+,d0
	bsr	.decim
	add.b	d0,(a1)+
	dbra	d2,.lop_dec

	move.l	#adr_long,a0
	neg.b	(a0)		;dx1
	neg.b	2(a0)		;dx2
	move.b	(a0),d0		;swap les 2 dx pour que (a0)<2(a0)
	move.b	2(a0),d1
	move.b	d0,2(a0)
	move.b	d1,(a0)
	move.l	adr_long,d0
	move.l	a6,a0
	bsr	code_d0_hex
	move.l	(sp)+,a0
	rts

.decim:	sub.b	#48,d0
	cmp.b	#10,d0
	blt	.rts
	sub.b	#7,d0
.rts:	rts

memo_page2:
	move.l	page2,a0
	add.l	#16*160,a0
	move.l	page3,a1
	move.w	#21440/4+1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

raf_page2:
	move.l	page3,a0
	move.l	page2,a1
	add.l	#16*160,a1
	move.w	#21440/4+1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

eff_page2:
	move.l	page2,a0
	add.l	#16*160,a0
	move.w	#21440/4+1,d0
.loop	clr.l	(a0)+
	dbra	d0,.loop
	rts

eff_pagez:
	move.l	page2,a0
	add.l	#32*160,a0
	move.w	#21440/4+1,d0
.loop	clr.l	(a0)+
	dbra	d0,.loop
	rts
aff_pagez:
	move.l	page3,a0
	move.l	page2,a1
	add.l	#32*160,a1
	move.w	#21440/4+1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts
memo_pagez:
	move.l	page2,a0
	add.l	#32*160,a0
	move.l	page3,a1
	move.w	#21440/4+1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

memo_page22:
	move.l	page2,a0
	move.l	page3,a1
	move.w	#32000/4+1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

raf_page22:
	move.l	page3,a0
	move.l	page2,a1
	move.w	#32000/4+1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

eff_page22:
	move.l	page2,a0
	move.w	#32000/4+1,d0
.loop	clr.l	(a0)+
	dbra	d0,.loop
	rts


memo_page21:
	move.l	page2,a0
	move.l	page1,a1
	move.w	#32000/4+1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

raf_page21:
	move.l	page1,a0
	move.l	page2,a1
	move.w	#32000/4+1,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	rts

copy_pt_to_buf:
	move.l	pt_pos,a0
	tst.b	flag_work
	beq	.okpos
	move.l	pt_anim,a0
.okpos:	move.l	#buffer_pos,a1
.loop:	move.b	(a0)+,(a1)+
	tst.b	-1(a0)
	beq	.fin
	cmp.b	#10,(a0)
	bne	.loop
	move.b	(a0)+,(a1)+	;copy le #10
.fin:	rts
	
copy_buf_to_pt:
	clr.l	d1
	move.l	#buffer_pos,a0
.loop1	add.l	#1,d1
	tst.b	(a0)
	beq	.fin1
	cmp.b	#10,(a0)+
	bne	.loop1		;d1=long buffer ->10 ou 0
.fin1:	clr.l	d2
	move.l	pt_pos,a0
	tst.b	flag_work
	beq	.loop2
	move.l	pt_anim,a0
.loop2	add.l	#1,d2
	tst.b	(a0)
	beq	.fin2
	cmp.b	#10,(a0)+
	bne	.loop2		;d2=long pt_pos ->10
.fin2:	cmp.l	d1,d2
	beq	trans_buf_ok
	bgt	pos_gt
buf_gt:
	move.l	d1,d3
	sub.l	d2,d3		;d3=d1-d2
	move.l	pt_pos,a2
	tst.b	flag_work
	beq	.okpos
	move.l	pt_anim,a2
.okpos:	tst.b	(a2)		;fin de fichier
	bne	.add2
	add.l	#1,d3
	bra	.pasad
.add2:	add.l	d2,a2		;a2=adr debut ligne suivante pt_pos
.pasad:	clr.l	d4
.loop3:	add.l	#1,d4
	cmp.b	#0,(a2)+
	bne	.loop3		;d4=long de a2 a fin fichier
	sub.l	#1,a2		;a2=adr fin fichier
	move.l	a2,a3
	add.l	d3,a3	;et pas d1
	sub.l	#1,d4
.loop4:	move.b	(a2),(a3)	;decalage de la fin du fichier
	sub.l	#1,a2
	sub.l	#1,a3
	dbra	d4,.loop4
	bra	trans_buf_ok

pos_gt:
	move.l	d2,d3
	sub.l	d1,d3		;d3=d2-d1
	move.l	pt_pos,a0
	tst.b	flag_work
	beq	.okpos
	move.l	pt_anim,a0
.okpos:	move.l	a0,a2
	add.l	d2,a0
	move.l	a0,a1
	sub.l	d3,a1
	;move.l	pt_pos,a2
	clr.l	d4
.loop3:	add.l	#1,d4
	cmp.b	#0,(a2)+
	bne	.loop3		;d4=long de pt_pos a fin fichier
	move.l	a2,a3
	sub.l	d1,a3	;et pas d3
.loop4:	move.b	(a0)+,(a1)+
	dbra	d4,.loop4
	
trans_buf_ok:
	move.l	#buffer_pos,a0
	move.l	pt_pos,a1
	tst.b	flag_work
	beq	.okpos
	move.l	pt_anim,a1
.okpos:	sub.l	#1,d1
.loop:	move.b	(a0)+,(a1)+
	dbra	d1,.loop
	;illegal
	rts



pt_pos:		dc.l	0	;pointeur sur chaine ascii pos en cours
adr_tbl_pos:	dc.l	0	;adr debut 'pos' ascii
adr_took:	dc.l	0	;adr du sprite pris par 'take'
data_pos_1:	dc.l	0
data_pos_2:	dc.l	0
data_ani_1:	dc.l	0
data_ani_2:	dc.l	0
var1:		dc.l	0	;variables usage interne a routines
var2:		dc.l	0
var3:		dc.l	0
var4:		dc.l	0
var5:		dc.l	0
start_load_adr:	dc.l	0	;adr libre apres ecrans : pour sprites
pt_spr_en_cours:	dc.l	0	;pointe sur "ivm1    .spr" (etc..)
adr_spr_en_cours:	dc.l	0	;adr du sprite pour 'take'
anc_xmouse:	dc.w	0	;xy mouse pour test mvt
anc_ymouse:	dc.w	0
xmil:		dc.w	$40	;xy du 0 relatif pour les sprites des pos
ymil:		dc.w	$40
xmil2:		dc.w	0
ymil2:		dc.w	0
pt_pos2:		dc.l	0
buffer_pos:	ds.b	256	;zone de travail pour 'pos' ascii
fin_buffer_pos:	ds.b	40
init_check_anim:	dc.l	0	;somme fichier ascii pour test quit
init_check_pos:	dc.l	0	;somme fichier ascii pour test quit
*-------------------------------------
check_anim:
	move.l	adr_anim_ascii,a0
	bra	check_all
check_pos:
	move.l	adr_tbl_pos,a0
check_all:
	clr.l	d0
.loop	clr.l	d1
	move.b	(a0),d1
	add.l	d1,d0
	tst.b	(a0)+
	bne	.loop
	rts
	

dec_d0_long:
	; entree :d0.l=nombre non sign‚
	; 	 a0=adr ou mettre la chaine ascii
	; sortie=a0 pointe sur la fin de la chaine+1
	movem.l	d1-d5/a1-a4,-(sp)
	move.l	#"0000",result
	move.l	#"0000",result+4
	move.w	#"00",result+8
	move.l	#table_decimale,a2
	move.w	#31,d1			;32 bits
.loop:	btst	#0,d0
	beq	.next
	bsr	.add_to_result
.next:	lsr.l	d0
	add.l	#10,a2
	dbra	d1,.loop
	move.l	#result,a1
.loop3:	cmp.b	#"0",(a1)+
	beq	.loop3
	sub.l	#1,a1
.loop4:	tst.b	(a1)
	beq	.return
	move.b	(a1)+,(a0)+
	bra	.loop4
.return:	movem.l	(sp)+,d1-d5/a1-a4
	rts

.add_to_result:
	move.l	a2,a3
	add.l	#9,a3	;dernier chiffre de la table
	move.l	#result+9,a4
	clr.b	d5		;retenue
	move.w	#9,d3		;10 chiffres
.loop2:	clr.l	d4
	move.b	(a4),d4
	add.b	(a3),d4
	sub.b	#"0"+"0",d4	;en registre
	add.b	d5,d4
	divu	#10,d4	;d4.l=reste.w/quot.w
	swap	d4
	add.b	#"0",d4
	move.b	d4,(a4)
	swap	d4
	move.b	d4,d5
	sub.l	#1,a4
	sub.l	#1,a3
	dbra	d3,.loop2
	rts
	
	even
result:		dc.b	"0000000000",0
table_decimale:
	dc.b	"0000000001","0000000002","0000000004","0000000008"
	dc.b	"0000000016","0000000032","0000000064","0000000128"
	dc.b	"0000000256","0000000512","0000001024","0000002048"
	dc.b	"0000004096","0000008192","0000016384","0000032768"
	dc.b	"0000065536","0000131072","0000262144","0000524288"
	dc.b	"0001048576","0002097152","0004194304","0008388608"
	dc.b	"0016777216","0033554432","0067108864","0134217728"
	dc.b	"0268435456","0536870912","1073741824","2147483648"
	even

decode_d0_ascii:
	; entree :d0.w=nombre sign‚
	; 	 a0=adr ou mettre la chaine ascii
	; sortie=a0 pointe sur la fin de la chaine+1
	move.l	d1,-(sp)
	and.l	#$0000ffff,d0
	tst.w	d0
	bpl	.pos
	move.b	#"-",(a0)+
	neg.w	d0
.pos:	beq	.zero1
	clr.b	d1		;flag 0 devant
	divu	#10000,d0
	bsr	.chi
	divu	#1000,d0
	bsr	.chi
	divu	#100,d0
	bsr	.chi
	divu	#10,d0
	bsr	.chi
	bsr	.chi
.return:	move.l	(sp)+,d1
	rts
	
.chi:	tst.b	d0	;routine
	beq	.zero
	move.b	#1,d1
.oui:	add.w	#"0",d0
	move.b	d0,(a0)+
	clr.w	d0
	swap	d0
	rts
.zero:	tst.b	d1
	bne	.oui
	clr.w	d0
	swap	d0
	rts
	
.zero1:	move.b	#"0",(a0)+	;car d0=0
	bra	.return

calc_adr_spr:	;entree:a0 pointe sur 'ivm1    .spr',par exemple
		; ou'ivm1.spr' ou 'ivm1'
		;sortie:d0=adr du sprite
	move.l	#name_liste,a1
	move.l	#liste_adr_sprite,a4
	move.l	a0,a2
.loop0:	move.l	a1,a3
.loop:	tst.b	(a1)	;fin de liste ?
	beq	.not_found
	cmp.b	#"+",(a0)	;'+1' pour flip‚
	beq	.okflip
	cmp.b	#" ",(a0)
	beq	.ok
	cmp.b	#",",(a0)	;"," pour decodage data ascii
	beq	.ok
	cmp.b	#".",(a0)
	beq	.ok
	cmp.b	(a1)+,(a0)+
	bne	.next
	bra	.loop
	
.next:	move.l	a2,a0
	move.l	a3,a1
	add.l	#12,a1
	add.l	#4,a4
	bra	.loop0
.ok:	move.l	(a4),d0
	rts
.okflip:
	move.l	(a4),a2
	move.w	(a2),d2		;nb lignes
	move.w	2(a2),d1		;nb blocs
	add.w	#1,d1
	add.w	#1,d2
	mulu	d2,d1
	mulu	#8,d1	;8 octets par bloc
	add.l	#8,d1
	add.l	d1,a2
	move.l	a2,d0
	add.l	#2,a0
	rts
.not_found:
	clr.l	d0
	rts
	


aff_txt_pos:
	LOCATE	0,0
	bsr	print
	dc.b	"position"
	dc.b	" 001 :" 
	dc.b	" 000 sprites ",0
	LOCATE	10,1
	bsr	print
	dc.b	"-",0
	LOCATE	0,24
	move.l	#perso_pos_name,d0
	bsr	outstr
	INVERSE
	LOCATE	36,24
	bsr	print
	dc.b	"ANIM",0
	LOCATE	20,1
	bsr	print
	dc.b	"FLIP",0
	LOCATE	26,1
	bsr	print
	dc.b	"<- ",0
	LOCATE	30,1
	bsr	print
	dc.b	" ->",0
	LOCATE	35,1
	bsr	print
	dc.b	"TAKE",0
	LOCATE	8,1
	bsr	print
	dc.b	" <",0
	LOCATE	11,1
	bsr	print
	dc.b	"> ",0
	LOCATE	6,22
	bsr	print
	dc.b	"CLEAR",0
	LOCATE	0,22
	bsr	print
	dc.b	"FLIP",0
	LOCATE	14,22
	bsr	print
	dc.b	"INSERT",0
	LOCATE	21,22
	bsr	print
	dc.b	"DEL",0
	LOCATE	29,22
	bsr	print
	dc.b	"LOAD!",0
	LOCATE	36,22
	bsr	print
	dc.b	"SAVE",0
	LOCATE	28,19
	bsr	print
	dc.b	"DEL",0
	LOCATE	32,19
	bsr	print
	dc.b	"SUR",0
	LOCATE	36,19
	bsr	print
	dc.b	"SOUS",0
	NORMAL
	rts

aff_no_pos:
	LOCATE	8,0
	bsr	print
no_pos:	dc.b	" 000",0
	rts

aff_info:
	bsr	aff_no_pos
	LOCATE	14,0
	bsr	print
nb_spr_pos:
	dc.b	" 000",0
	LOCATE	40-8,0
	move.l	pt_spr_en_cours,a0
	move.l	#buffer,a1
	move.w	#7,d1
.loop:	move.b	(a0)+,(a1)+
	dbra	d1,.loop
	clr.b	(a1)
	move.l	#buffer,d0
	bsr	outstr
	LOCATE	40-10,0
	clr.l	adr_pos_edit
	move.l	#buffer,a0
	move.w	#7,d0
.loop2:	cmp.b	#' ',(a0)+
	bne	.next2
	clr.b	-1(a0)
.next2:	dbra	d0,.loop2

	move.l	#buffer,a0
	bsr	contened_spr
	bne	.non
	move.l	a3,adr_pos_edit
	bsr	print
	dc.b	"*",0
	rts
.non:	bsr	print
	dc.b	" ",0
	rts

contened_spr:	;test si sprite a0 est dans buffer_pos
		;retour: NE si non
		;	EQ si oui,a3=adr de a0 dans buffer_pos
	move.l	#buffer_pos,a1
	tst.b	(a1)
	beq	.non
	bsr	find_string
	cmp.l	#0,a0
	beq	.non
	cmp.b	#",",(a1)	suivi par ',' ou '+1,'
	beq	.ok
	cmp.b	#"+",(a1)
	bne	.non
	cmp.b	#"1",1(a1)
	bne	.non
	cmp.b	#",",2(a1)
	bne	.non
.ok:	move.l	a0,a3
	move.l	#buffer_pos,a0
	move.b	#10,d0
	bsr	find_d0
	cmp.l	a0,a3
	bge	.non
	cmp.b	d0,d0
	rts
.non:	cmp.l	#1,a1
	rts

copy_spr_buffer:	;entree a0="ivbn1   "
		;sortie #buffer="ivbn1",0,0,0  ,0
	move.l	a0,a2
	move.l	#buffer,a1
	move.w	#7,d1
.loop:	move.b	(a0)+,(a1)+
	cmp.b	#' ',-1(a1)
	bne	.next
	clr.b	-1(a1)
.next:	dbra	d1,.loop
	clr.b	(a1)
	move.l	a2,a0
	rts

adr_pos_edit:	dc.l	0

add_nb_spr:
	move.l	#nb_spr_pos+3,a0
.loop:	add.b	#1,(a0)
	cmp.b	#"9",(a0)
	ble	.ok
	move.b	#"0",(a0)
	sub.l	#1,a0
	bra	.loop
.ok:	rts

add_no_pos:
	move.l	#no_pos+3,a0
add_no_xxx
.loop:	add.b	#1,(a0)
	cmp.b	#"9",(a0)
	ble	.ok
	move.b	#"0",(a0)
	sub.l	#1,a0
	bra	.loop
.ok:	rts


sub_no_pos:
	move.l	#no_pos+3,a0
sub_no_xxx:
.loop:	sub.b	#1,(a0)
	cmp.b	#"0",(a0)
	bge	.ok
	move.b	#"9",(a0)
	sub.l	#1,a0
	bra	.loop
.ok:	rts

add_no_eta:
	move.l	a0,-(sp)
	move.l	#no_eta+3,a0
	bsr	add_no_xxx
	move.l	(sp)+,a0
	rts
	
sub_no_eta:
	move.l	a0,-(sp)
	move.l	#no_eta+3,a0
	bsr	sub_no_xxx
	move.l	(sp)+,a0
	rts
	
*--------------------------------------
aff_spr_en_cours:
	bsr	cls_droite
	move.l	adr_spr_en_cours,a2
	;tst.b	flag_fliped
	;beq	.ok
	bra	.ok
	move.w	(a2),d2		;nb lignes
	move.w	2(a2),d1		;nb blocs
	add.w	#1,d1
	add.w	#1,d2
	mulu	d2,d1
	mulu	#8,d1	;8 octets par bloc
	add.l	#8,d1
	add.l	d1,a2
.ok:	cmp.l	#debut_ram,a2
	blt	.rts
	move.l	page2,a1
	add.l	#4*160*8+96,a1
	move.l	#0,d0
	move.w	(a2),d2		;nb lignes
	move.w	2(a2),d1		;nb blocs
	add.l	#8,a2
	bsr	affspr
.rts	rts

cls_droite:
	move.l	page2,a1
	add.l	#4*160*8+96,a1
	move.w	#100,d0		;100 lignes
.loop1:	move.l	a1,a2
	move.w	#7,d1		;8 bloks
.loop2:	clr.l	(a1)+
	clr.l	(a1)+
	dbra	d1,.loop2
	move.l	a2,a1
	add.l	#160,a1
	dbra	d0,.loop1
	rts
	
	


liste_adr_sprite:	ds.b	12*nb_name_lst	;50 sprites

*----------------------
load_pal_pi1:
	move.l	#.nom,d3
	move.l	page3,d4
	bsr	load
	move.l	page3,d0
	add.l	#2,d0
	move.l	d0,-(sp)
	move.w	#setpal,-(sp)
	trap	#xbios
	addq.l	#6,sp
	move.l	page3,a0
	add.l	#2,a0
	move.l	#palette2,a1
	move.l	#liste_palettes,a2
	move.w	#15,d0
.loop:	move.w	(a0),(a1)+
	move.w	(a0)+,(a2)+
	dbra	d0,.loop
	rts
.nom:	dc.b	"\ecrspr\Palette.pal",0
	even
*------------------------------
load_liste_sprites:	;a0=adr de la liste
	move.l	a0,var1
	move.l	start_load_adr,var2	;adr 1er sprite
	move.l	#liste_adr_sprite,var3
	
.loop:	move.l	#path_sprites,a1
	move.l	#buffer,a0
	bsr	copy_path
	move.l	var1,a1
	tst.b	(a1)		;fin de liste ?
	beq	.rts
	move.l	a1,a5
	move.w	12(a1),-(sp)
	clr.b	12(a1)
	bsr	copy_to_0
	move.l	a5,a1
	move.w	(sp)+,12(a1)
	move.b	#0,(a0)+
	move.l	#buffer,a0
	bsr	kill_space_a0
	move.l	#buffer,d3
	bsr	getaille
	tst.l	d0
	beq	.pa_lod
	move.l	#buffer,d3
	move.l	var2,d4
	add.l	d0,var2
	move.l	var3,a0
	move.l	d4,(a0)+
	move.l	a0,var3
	move.l	d0,-(sp)
	bsr	load
	move.l	(sp)+,d0
	bsr	flip_var2
	add.l	#12,var1
	bra	.loop
.pa_lod:	add.l	#4,var3
	add.l	#12,var1
	bra	.loop
.rts:	move.l	var2,adr_tbl_pos
	rts

flip_var2:
	move.l	var2,a1		;source
	move.l	var2,a0		;dest
	sub.l	d0,a1
	add.l	d0,var2
	bsr	flip
	rts
	
	
	
*------------------------------------	
load_pos_rts:
	;format du fichier ascii:
	  ;posiv001:	POS	-12,-1,25,45,ivb1,0,0,ivb2,5,26,ivm2,-65,128,0
	  ;=definition de la position no 1 d'ivanoe: 
	  ;(taille du cadre pour tests=-12x,-1y a +25x,+45y) r(xiv,yiv)
	  ;+sprite ivb1.spr en 0,0 r(xiv,yiv) ,sprite ivb2 en 5,26 ,etc...
	  ;posiv002:	POS	0,0,30,40,ivb1,0,0,ivb4,8,42,0
	move.l	#perso_tbl_name,a0
	move.l	#perso_pos_name,a1
.lop1:	move.b	(a0)+,(a1)+
	cmp.b	#".",(a0)
	bne	.lop1
	move.b	#".",(a1)+
	move.b	#"P",(a1)+
	move.b	#"O",(a1)+
	move.b	#"S",(a1)+
	clr.b	(a1)

load_pos_rts2:
	bsr	hide_m
	move.w	#2,d0
	bsr	graf_mouse
	bsr	show_m
	move.l	adr_tbl_pos,a0
	clr.b	(a0)
	move.l	#perso_pos_name,d3
	bsr	getaille
	tst.l	d0
	beq	.rts
	move.l	#perso_pos_name,d3
	move.l	adr_tbl_pos,d4
	move.l	d4,a0
	add.l	d0,a0
	clr.b	(a0)+
	move.l	a0,next_load_adr
	bsr	load
	bsr	kill_fliped_pos
	bsr	check_pos
	move.l	d0,init_check_pos
	cmp.b	#0,flag_work	;pour anim ?
	beq	.no_flip
	move.l	adr_zero_pos,a0
	move.b	val_zero_pos,d0
	move.b	d0,(a0)
.no_flip:bsr	copy_pt_to_buf
	move.l	#1,d0	;flag fichier charg‚ ok
.rts	move.l	d0,-(sp)
	bsr	hide_m
	move.w	#0,d0
	bsr	graf_mouse
	bsr	show_m
	move.l	(sp)+,d0
	rts

load_pos_ascii:
	bsr	hide_m
	move.b	#1,flag_load_pos
	bra	debut_pos

kill_fliped_etapes:
	move.l	adr_anim_ascii,a0
	move.b	#1,flag_espaces
	bra	kill_flip

kill_fliped_pos:	;met un 0 pour eliminer les positions flip‚es
	move.l	adr_tbl_pos,a0
	clr.b	flag_espaces
	bsr	kill_flip
	move.l	var1,adr_zero_pos
	move.b	var2,val_zero_pos
	rts
kill_flip:
	movem.l	d0-d7/a1-a6,-(sp)
.loop:	tst.b	(a0)
	beq	.return
	move.l	a0,var1
.loop2:	tst.b	(a0)
	beq	.return
	tst.b	flag_espaces
	beq	.pas_pos
	cmp.b	#13,(a0)
	bne	.pas_pos
	cmp.b	#";",2(a0)
	bne	.pas_pos
	move.l	a0,var1
	add.l	#2,var1
.pas_pos:cmp.b	#":",(a0)+
	bne	.loop2
	cmp.b	#"f",-2(a0)
	bne	.next
	move.l	var1,a0
	move.b	(a0),var2
	clr.b	(a0)
.return:	movem.l	(sp)+,d0-d7/a1-a6
	rts
.next:	move.l	var1,a0
	bsr	find_end_string
	tst.b	(a0)
	beq	.return
	add.l	#1,a0
	bra	.loop

getch:	move.w	#c_conin,-(sp)
	trap	#gemdos
	addq.l	#2,sp
	rts


print:	; syntaxe : bsr print
	;	    bc.b "chaine",0       ;nombre d'octets indifferent !
	IFNE	print_rs232
	move.l	(sp),a0
	movem.l	d0-d7/a0-a7,-(sp)
	bsr	init_rs232
	bsr	send_rs232
	bsr	restore_rs232
	movem.l	(sp)+,d0-d7/a0-a7
	ENDC
	move.l	(sp),d0
	move.w	#c_conws,-(sp)
	trap	#gemdos
	addq.l	#2,sp
	move.l	(sp),a0
print2	move.b	(a0)+,d0
	tst.b	d0
	beq	print3
	bra	print2
print3	move.l	a0,d0
	btst	#0,d0
	beq	.ok
	add.l	#1,a0		;adresse retour etait impaire
.ok	move.l	a0,(sp)
	rts

outstr	; entree : d0 pointe sur la chaine a afficher
	IFNE	print_rs232
	movem.l	d0-d7/a0-a7,-(sp)
	move.l	d0,a0
	bsr	init_rs232
	bsr	send_rs232
	bsr	restore_rs232
	movem.l	(sp)+,d0-d7/a0-a7
	ENDC
	move.l	d0,-(sp)
	move.w	#c_conws,-(sp)
	trap	#gemdos
	addq.l	#6,sp
	rts

wait_no_clic:
	bsr	getinput
	cmp.w	#201,d0
	beq	wait_no_clic
	cmp.w	#202,d0
	beq	wait_no_clic
	rts


flip:
*======================================================================*/
*              flip vertical pour sprite en m‚moire   le 02.08.1988   */
*======================================================================*/
;a1=adr sprite source
;a0=adr sprite dest


	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3	
	move.w	(a1),d1
	move.w	(a1)+,(a0)+	;copie nb lignes
	move.w	(a1),d3
	move.w	d3,d2
;	add.w	#1,d2
	lsl.w	#3,d2
	move.w	(a1)+,(a0)+	;copie nb de Word
	move.w	(a1)+,(a0)+	;copie nb de pix de large
	move.w	(a1)+,(a0)+	;copie Word inutilis‚
	

	;a1=data spr source
	;a0=data spr dest

	;d1=nb de lignes
	;d2=largeur en nb d'octets (pour 1 plan)
	;d3=largeur en nb de Word -1(pour 1 plan)



bclhau:           
        adda.l  D2,A1           ; pointe sur 1er octect du der. 16 pix.  
        move.w  D3,D0           ; initialise compteur larg
bcllar: 
        adda.l  #1,A0
;	move.b	#$ff,(a0);;;1
	clr.b	(a0)
        btst.b  #0,(A1)
        beq     bit01
        bset.b  #7,(A0)
bit01:   
        btst.b  #1,(A1)
        beq     bit02
        bset.b  #6,(A0)
bit02:
        btst.b  #2,(A1)
        beq     bit03
        bset.b  #5,(A0)
bit03:
        btst.b  #3,(A1)
        beq     bit04
        bset.b  #4,(A0)
bit04: 
        btst.b  #4,(A1)
        beq     bit05
        bset.b  #3,(A0)
bit05:
        btst.b  #5,(A1)
        beq     bit06
        bset.b  #2,(A0)
bit06:
        btst.b  #6,(A1)
        beq     bit07
        bset.b  #1,(A0)
bit07:
        btst.b  #7,(A1)
        beq     bit08
        bset.b  #0,(A0)
bit08:
        sub.l  #1,A0
        adda.l  #1,A1
	clr.b	(a0);;;2
        btst.b  #0,(A1)
        beq     bit09
        bset.b  #7,(A0)
bit09:   
        btst.b  #1,(A1)
        beq     bit0A
        bset.b  #6,(A0)
bit0A:
        btst.b  #2,(A1)
        beq     bit0B
        bset.b  #5,(A0)
bit0B:
        btst.b  #3,(A1)
        beq     bit0C
        bset.b  #4,(A0)
bit0C: 
        btst.b  #4,(A1)
        beq     bit0D
        bset.b  #3,(A0)
bit0D:
        btst.b  #5,(A1)
        beq     bit0E
        bset.b  #2,(A0)
bit0E:
        btst.b  #6,(A1)
        beq     bit0F
        bset.b  #1,(A0)
bit0F:
        btst.b  #7,(A1)
        beq     second
        bset.b  #0,(A0)
     
second: 

        adda.l  #1,A1
        adda.l  #3,A0

;-------

;        adda.l  #1,A0
	clr.b	(a0);;;3
        btst.b  #0,(A1)
        beq     bit11
        bset.b  #7,(A0)
bit11:   
        btst.b  #1,(A1)
        beq     bit12
        bset.b  #6,(A0)
bit12:
        btst.b  #2,(A1)
        beq     bit13
        bset.b  #5,(A0)
bit13:
        btst.b  #3,(A1)
        beq     bit14
        bset.b  #4,(A0)
bit14: 
        btst.b  #4,(A1)
        beq     bit15
        bset.b  #3,(A0)
bit15:
        btst.b  #5,(A1)
        beq     bit16
        bset.b  #2,(A0)
bit16:
        btst.b  #6,(A1)
        beq     bit17
        bset.b  #1,(A0)
bit17:
        btst.b  #7,(A1)+
        beq     bit18
        bset.b  #0,(A0)
bit18:
        suba.l  #1,A0
;        adda.l  #1,A1
	clr.b	(a0);;;4
        btst.b  #0,(A1)
        beq     bit19
        bset.b  #7,(A0)
bit19:   
        btst.b  #1,(A1)
        beq     bit1A
        bset.b  #6,(A0)
bit1A:
        btst.b  #2,(A1)
        beq     bit1B
        bset.b  #5,(A0)
bit1B:
        btst.b  #3,(A1)
        beq     bit1C
        bset.b  #4,(A0)
bit1C: 
        btst.b  #4,(A1)
        beq     bit1D
        bset.b  #3,(A0)
bit1D:
        btst.b  #5,(A1)
        beq     bit1E
        bset.b  #2,(A0)
bit1E:
        btst.b  #6,(A1)
        beq     bit1F
        bset.b  #1,(A0)
bit1F:
        btst.b  #7,(A1)+
        beq     trois
        bset.b  #0,(A0)
     
trois:
;        adda.l  #1,A1
        adda.l  #3,A0

;        adda.l  #1,A0
	clr.b	(a0);;;5
        btst.b  #0,(A1)
        beq     bit21
        bset.b  #7,(A0)
bit21:   
        btst.b  #1,(A1)
        beq     bit22
        bset.b  #6,(A0)
bit22:
        btst.b  #2,(A1)
        beq     bit23
        bset.b  #5,(A0)
bit23:
        btst.b  #3,(A1)
        beq     bit24
        bset.b  #4,(A0)
bit24: 
        btst.b  #4,(A1)
        beq     bit25
        bset.b  #3,(A0)
bit25:
        btst.b  #5,(A1)
        beq     bit26
        bset.b  #2,(A0)
bit26:
        btst.b  #6,(A1)
        beq     bit27
        bset.b  #1,(A0)
bit27:
        btst.b  #7,(A1)+
        beq     bit28
        bset.b  #0,(A0)
bit28:
;---------------------
        suba.l  #1,A0
        
	clr.b	(a0);;;6
        btst.b  #0,(A1)
        beq     bit29
        bset.b  #7,(A0)
bit29:   
        btst.b  #1,(A1)
        beq     bit2A
        bset.b  #6,(A0)
bit2A:
        btst.b  #2,(A1)
        beq     bit2B
        bset.b  #5,(A0)
bit2B:
        btst.b  #3,(A1)
        beq     bit2C
        bset.b  #4,(A0)
bit2C: 
        btst.b  #4,(A1)
        beq     bit2D
        bset.b  #3,(A0)
bit2D:
        btst.b  #5,(A1)
        beq     bit2E
        bset.b  #2,(A0)
bit2E:
        btst.b  #6,(A1)
        beq     bit2F
        bset.b  #1,(A0)
bit2F:
        btst.b  #7,(A1)+
        beq     quatre
        bset.b  #0,(A0)
     
quatre:
;--------------------
        adda.l  #3,A0
        
	clr.b	(a0);;;7
        btst.b  #0,(A1)
        beq     bit31
        bset.b  #7,(A0)
bit31:   
        btst.b  #1,(A1)
        beq     bit32
        bset.b  #6,(A0)
bit32:
        btst.b  #2,(A1)
        beq     bit33
        bset.b  #5,(A0)
bit33:
        btst.b  #3,(A1)
        beq     bit34
        bset.b  #4,(A0)
bit34: 
        btst.b  #4,(A1)
        beq     bit35
        bset.b  #3,(A0)
bit35:
        btst.b  #5,(A1)
        beq     bit36
        bset.b  #2,(A0)
bit36:
        btst.b  #6,(A1)
        beq     bit37
        bset.b  #1,(A0)
bit37:
        btst.b  #7,(A1)+
        beq     bit38
        bset.b  #0,(A0)
bit38:
;----------------------
        suba.l  #1,A0
	
	clr.b	(a0);;;8
        btst.b  #0,(A1)
        beq     bit39
        bset.b  #7,(A0)
bit39:   
        btst.b  #1,(A1)
        beq     bit3A
        bset.b  #6,(A0)
bit3A:
        btst.b  #2,(A1)
        beq     bit3B
        bset.b  #5,(A0)
bit3B:
        btst.b  #3,(A1)
        beq     bit3C
        bset.b  #4,(A0)
bit3C: 
        btst.b  #4,(A1)
        beq     bit3D
        bset.b  #3,(A0)
bit3D:
        btst.b  #5,(A1)
        beq     bit3E
        bset.b  #2,(A0)
bit3E:
        btst.b  #6,(A1)
        beq     bit3F
        bset.b  #1,(A0)
bit3F:
        btst.b  #7,(A1)
        beq     fin
        bset.b  #0,(A0)
     
fin:
        adda.l  #2,A0

        suba.l  #15,A1

        dbf     D0,bcllar

	add.l	d2,a1
        add.l	#16,a1

        dbf     D1,bclhau
	rts
;        movem.l (A7)+,A0-A6/D0-D7
;      }
;}


*-------------------------------------
etat_mouse:	dc.w	0

show_m:	;move.w	#256,d0
	;bra	graf_mouse
	tst.b	etat_mouse
	bne	.rts
	move.b	#1,etat_mouse
	clr.w	intin		;intin(0)
	clr.w	sptsin		;control(1)
	move.w	#1,sintin	;control(3)
	dc.w	$a009		;show mouse
.rts:	rts
	
hide_m:	;move.w	#257,d0
	;bra	graf_mouse
	tst.b	etat_mouse
	beq	.rts
	clr.b	etat_mouse
	clr.w	intin		;intin(0)
	clr.w	sptsin		;control(1)
	move.w	#1,sintin	;control(3)
	dc.w	$a00a		;hide mouse
.rts	rts

oui_non?:bsr	getch
	cmp.b	#"o",d0
	beq	.rts
	cmp.b	#"O",d0
	beq	.rts
	cmp.b	#"n",d0
	beq	.non
	cmp.b	#"N",d0
	bne	oui_non?
.non:	tst.b	d0
.rts:	rts

selector:
	bsr	hide_m
	move.w	#1,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#cool_col,-(sp)
	move.w	#setpal,-(sp)
	trap	#xbios
	addq.l	#6,sp
	move.w	#2,d0		;abeille
	bsr	graf_mouse
	bsr	show_m
	bsr	aff_cadre_selector
	bsr	trie_new_selector
	rts

read_dossiers:
	move.l	adr_cata,a0
	move.l	#adr_cata_dos,a1
.loop:	move.b	(a0)+,(a1)+		;copy chaine
	tst.b	-1(a1)
	bne	.loop
	sub.l	#1,a1
.loop2:	cmp.l	#adr_cata_dos,a1
	beq	.pas_point
	cmp.b	#'\',(a1)
	beq	.pas_point
	cmp.b	#".",(a1)
	beq	.point
	sub.l	#1,a1
	bra	.loop2
.pas_point:
	move.l	#adr_cata,a0
	clr.b	d0
	bsr	find_d0
	sub.l	#1,a0
	move.l	a0,a1
.point:	add.l	#1,a1
	move.b	#"*",(a1)+
	clr.b	(a1)+
	

lab_dos:	move.w	#$10,-(sp)	;sous_dir + fich
	move.l	#adr_cata_dos,-(sp)
	move.w	#$4e,-(sp)	;sfirst
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bne	.return		;rien
	cmp.b	#$10,dta+21	;Dossier Previous ? (. , .. , ... etc)
	bne	.cont_cata
.lop2:	move.w	#$4f,-(sp)	;snext
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bne	.return
	cmp.b	#$10,dta+21
	bne	.cont_cata
	cmp.b	#".",dta+30
	beq	.lop2
	bra	.cont_cata

.loop_:	move.l	#dta+30,a0
	move.w	#11,d0
.lop5:	clr.b	(a0)+
	dbra	d0,.lop5
	move.w	#$4f,-(sp)	;snext
	trap	#1
	addq.l	#2,sp
.cont_cata:
	tst.l	d0
	bne	.return
	
.normal:	cmp.b	#$10,dta+21	;Dossier?
	bne	.loop_
	move.l	#dta+30,a0
	move.l	pt_cat,a1
	move.l	a1,a2
	add.l	#8,a2
	move.w	#11,d0
.loop:	cmp.b	#'.',(a0)
	bne	.ok
	move.b	#3,d0
.loop2:	move.b	#' ',(a1)
	cmp.l	a1,a2
	beq	.ok2
	add.l	#1,a1
	bra	.loop2
.ok2:	move.l	a2,a1
.ok:	move.b	(a0),(a1)+
	tst.b	-1(a1)
	bne	.pas0
	move.b	#" ",-1(a1)
.pas0:	clr.b	(a0)+
	dbra	d0,.loop
	move.l	pt_cat,a0
	add.l	#8,a0
	move.l	a0,a1
	sub.l	#1,a0
	move.w	#7,d0
.lop0:	move.b	(a0),(a1)
	sub.l	#1,a0
	sub.l	#1,a1
	dbra	d0,.lop0
	move.b	#7,(a1)
	add.l	#12,a1
.pas_dos:add.l	#12,pt_cat
	move.l	a1,last_cat
	add.w	#1,nb_files
	bra	.loop_
.return:	rts
adr_cata_dos:	ds.b	80
	
trie_new_selector:	;---------------------------------
	clr.w	nb_files
	move.l	#dta,-(sp)
	move.w	#$1a,-(sp)	;set dta
	trap	#1
	addq.l	#6,sp

	clr.l	last_cat
	move.l	#catalog,pt_cat
	move.l	#catalog,a0
	move.w	#500*12-1,d0
.loop:	clr.b	(a0)+
	dbra	d0,.loop
	move.l	#dta+30,a0
	move.w	#11,d0
.loop2:	clr.b	(a0)+
	dbra	d0,.loop2

	bsr	read_dossiers

	move.w	#$0,-(sp)	;fich only
	move.l	adr_cata,-(sp)
	move.w	#$4e,-(sp)	;sfirst
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bne	tri0		;rien
	cmp.b	#$10,dta+21	;Dossier Previous ? (. , .. , ... etc)
	bne	cont_cata
.lop2:	move.w	#$4f,-(sp)	;snext
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bne	tri0
	cmp.b	#$10,dta+21
	bne	cont_cata
	cmp.b	#".",dta+30
	beq	.lop2
	bra	cont_cata

loop_:	move.w	#$4f,-(sp)	;snext
	trap	#1
	addq.l	#2,sp
cont_cata:
	tst.l	d0
	bne	tri0
	
.normal:	move.l	#dta+30,a0
	move.l	pt_cat,a1
	move.l	a1,a2
	add.l	#8,a2
	move.w	#11,d0
.loop:	cmp.b	#'.',(a0)
	bne	.ok
	move.b	#3,d0
.loop2:	move.b	#' ',(a1)
	cmp.l	a1,a2
	beq	.ok2
	add.l	#1,a1
	bra	.loop2
.ok2:	move.l	a2,a1
.ok:	move.b	(a0),(a1)+
	tst.b	-1(a1)
	bne	.pas0
	move.b	#" ",-1(a1)
.pas0:	clr.b	(a0)+
	dbra	d0,.loop
	cmp.b	#$10,dta+21	;Dossier?
	bne	.pas_dos
	move.l	pt_cat,a0
	add.l	#8,a0
	move.l	a0,a1
	sub.l	#1,a0
	move.w	#7,d0
.lop0:	move.b	(a0),(a1)
	sub.l	#1,a0
	sub.l	#1,a1
	dbra	d0,.lop0
	move.b	#7,(a1)
	add.l	#12,a1
.pas_dos:add.l	#12,pt_cat
	move.l	a1,last_cat
	add.w	#1,nb_files
	bra	loop_

tri0:	;--------------- tri -----------
	;--- get free_disc
	move.w	#0,d0		;=drive courant
	move.l	adr_cata,a0
	cmp.b	#":",1(a0)
	bne	.ok
	move.w	#1,d0
	cmp.b	#"a",(a0)
	beq	.ok
	cmp.b	#"A",(a0)
	beq	.ok
	move.w	#2,d0
	cmp.b	#"b",(a0)
	beq	.ok
	cmp.b	#"B",(a0)
	beq	.ok
	move.w	#3,d0
	cmp.b	#"c",(a0)
	beq	.ok
	cmp.b	#"C",(a0)
	beq	.ok
	move.w	#4,d0
	cmp.b	#"d",(a0)
	beq	.ok
	cmp.b	#"D",(a0)
	beq	.ok
	clr.w	d0
.ok:	move.w	d0,-(sp)
	move.l	#buf_disc,-(sp)
	move.w	#$36,-(sp)
	trap	#1
	addq.l	#8,sp
	move.l	buf_disc,d0
	move.l	buf_disc+4,d1
	move.l	buf_disc+8,d2
	move.l	buf_disc+12,d3
	mulu	d3,d2		;nb octets par unit
	mulu	d2,d0
	move.l	d0,free_disc
	mulu	d2,d1
	move.l	d1,total_disc

*------------ debut tri --------------------	
	move.l	#catalog,pt_cat
	move.l	last_cat,a6
	move.l	pt_cat,a4
	sub.w	#1,nb_files
	ble	fin_tri
.loop1:	move.l	a4,a0
	lea	12(a0),a1
	clr.b	d7
	sub.w	#1,nb_files
	move.w	nb_files,d5
.loop2:	
	move.l	a0,a2
	move.l	a1,a3
	REPT	3
	cmp.l	(a2)+,(a3)+	;------ compare chaines de 12 carac ---
	bne	.fincmp
	ENDR
.fincmp:	
	bgt	.not_this
	move.l	a1,a5		;a1 le > trouv‚
	move.l	a1,a0
	moveq	#1,d7
.not_this:
	lea	12(a1),a1	;saute ce plus grand provisoir
	dbra	d5,.loop2
	tst.b	d7		;y a t-il eu un + grand trouv‚ ?
	beq	.pas_swap
	move.l	a4,a0
	REPT	3		;------ swap chaines de 12 carac -----
	move.l	(a0),d0
	move.l	(a5),(a0)+
	move.l	d0,(a5)+
	ENDR
.pas_swap:
	lea	12(a4),a4
	lea	12(a4),a2
	cmp.l	a6,a2
	blt	.loop1
	bra	fin_tri
	;----------------- le tri est fini 

fin_tri:
	NORMAL
	LOCATE	47,6
	move.l	free_disc,d0
	move.l	#buffer,a0
	bsr	dec_d0_long
	clr.b	(a0)
	move.l	#buffer,d0
	bsr	outstr
	bsr	print
	dc.b	"     ",0
	LOCATE	42,7
	move.l	total_disc,d0
	move.l	#buffer,a0
	bsr	dec_d0_long
	clr.b	(a0)
	move.l	#buffer,d0
	bsr	outstr
	bsr	print
	dc.b	"     ",0
	rts


aff_cadre_selector:
*------------- affichage noms et selection par souris -----------
	bsr	hide_m
	INVERSE
	move.l	adr_txt_info,d0
	bsr	outstr
	bsr	print
	dc.b	13,10," ",0
	NORMAL
	jsr	print
	dc.b	"Cat:",0
	move.l	adr_cata,d0
	jsr	outstr
	INVERSE
	LOCATE	34,1
	jsr	print
	dc.b	" ",13,10,"                                   "
	dc.b	13,10,"    ",0
	NORMAL
	jsr	print
	dc.b	"PREVIOUS",0
	INVERSE
	jsr	print
	dc.b	"    ",0
	NORMAL
	jsr	print
	dc.b	"CANCEL",0
	INVERSE
	jsr	print
	dc.b	"     ",0
	NORMAL
	jsr	print
	dc.b	" OK ",0
	INVERSE
	jsr	print
	dc.b	"    ",0
	jsr	print
	dc.b	13,10,"                                   ",0
	
	move.b	#5,ylign
loop_loc:
	move.b	ylign,yloc1
	move.b	ylign,yloc2
	add.b	#32,yloc1
	add.b	#32,yloc2
	;locate x,y (0,0 a 39,25)
	jsr	print
	dc.b	27,"Y"
yloc1:	dc.b	32
	dc.b	32," ",0
	
	jsr	print
	dc.b	27,"Y"
yloc2:	dc.b	32
	dc.b	32+34," ",0
	add.b	#1,ylign
	cmp.b	#24,ylign
	bne	loop_loc
	
	jsr	print
	dc.b	13,10,"                                   ",0
	
	LOCATE	34,5
	move.w	#1,-(sp)
	move.w	#5,-(sp)
	move.w	#3,-(sp)
	trap	#bios
	addq.l	#6,sp
	LOCATE	34,12
	move.w	#1,-(sp)
	move.w	#5,-(sp)
	move.w	#3,-(sp)
	trap	#bios
	addq.l	#6,sp
	
	LOCATE	34,14
	move.w	#2,-(sp)
	move.w	#5,-(sp)
	move.w	#3,-(sp)
	trap	#bios
	addq.l	#6,sp
	LOCATE	34,23
	move.w	#2,-(sp)
	move.w	#5,-(sp)
	move.w	#3,-(sp)
	trap	#bios
	addq.l	#6,sp
	LOCATE	36,2
	bsr	print
	dc.b	"     Name:    ",0
	LOCATE	36,4
	bsr	print
	dc.b	"              ",0
	LOCATE	36,3
	bsr	print
	dc.b	" ",0
	LOCATE	36+13,3
	bsr	print
	dc.b	" ",0
	
	LOCATE	36,6
	bsr	print
	dc.b	"free bytes:",0
	LOCATE	36,7
	bsr	print
	dc.b	"total:",0
	NORMAL
	;----------- le cadre est affich‚ -------------
	LOCATE	37,3
	move.l	#name_select,a0
	clr.b	d0		;pas d'espace avant
	bsr	aff_1_name
	;la souris est hide
	rts

*---------------------- FILE SELECT --------------------------------
file_select:
	;entree:	a0=txt d'info(35 octets)
	;	   + 2 + 30 octets pour le catalog
	;	!:souris active
	;sortie:	d3=adr du nom ou 0 si cancel ou fichier inexistant
	move.l	a0,adr_txt_info
	add.l	#36+2,a0
	move.l	a0,adr_cata

file_select2:
	bsr	selector
	move.w	#0,d0	;fleche
	bsr	graf_mouse
	bsr	show_m
	
	move.l	#catalog,pt_cat
select:	bsr	hide_m
	jsr	aff_names
	bsr	show_m
	
loop_sel:
	bsr	getinput
	cmp.b	#1,d0
	beq	.cancel
	bsr	test_d0_select
	cmp.b	#-1,d0
	beq	select
	cmp.b	#-2,d0
	beq	select		;file_select2
	move.w	xmouse,d1
	move.w	ymouse,d2
	cmp.w	#201,d0
	bne	loop_sel
	cmp.w	#$18,d2
	blt	loop_sel
	cmp.w	#$1f,d2
	bgt	loop_sel
	cmp.w	#$80,d1
	blt	loop_sel
	cmp.w	#$ae,d1
	bgt	.pas_m2
	;------------- cancel
.cancel:	bsr	hide_m
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp
	move.w	#255,d0
	bsr	graf_mouse
	bsr	show_m
.loop_wait0:
	bsr	getinput
	cmp.w	#201,d0
	beq	.loop_wait0
	clr.l	d3
	rts

.pas_m2:	cmp.w	#$d8,d1
	blt	loop_sel
	cmp.w	#$f7,d1
	bgt	loop_sel
	;--- ok ----
	move.l	#file_name,a0
	move.l	adr_cata,a1
	bsr	copy_path
	move.l	#name_select,a1
	bsr	copy_to_0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	bsr	hide_m
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#file_name,a0
	bsr	kill_space_a0
	move.w	#255,d0
	bsr	graf_mouse
	bsr	show_m
.loop_wait:
	bsr	getinput
	cmp.w	#201,d0
	beq	.loop_wait
	move.l	#file_name,d3
	rts

kill_space_a0:
.loop_space:
	tst.b	(a0)
	beq	.killed
	cmp.b	#' ',(a0)
	beq	.kill_space
	add.l	#1,a0
	bra	.loop_space
.kill_space:
	move.l	a0,a1
	move.l	a0,a2
	add.l	#1,a2
.loop_kill:
	move.b	(a2)+,(a1)+
	tst.b	-1(a1)
	beq	.loop_space
	bra	.loop_kill
.killed:	rts


add_to_liste:
	;a0=adr de la chaine a ajouter
	move.l	#name_liste,a1
	move.w	#nb_name_lst,d0
	move.l	#12,d1
	bsr	find_string12	;deja dans la liste ?
	cmp.l	#0,a1
	bne	return
	move.l	pt_next_liste,a1
	cmp.l	#end_name_liste,a1
	bge	return		;liste pleine
	move.w	#11,d0
.loop:	move.b	(a0)+,(a1)+	;copy du nom dans la liste
	dbra	d0,.loop
	move.l	a1,pt_next_liste
	move.l	pt_aff_liste,a0
	add.l	#24*12,a0
	cmp.l	a0,a1
	blt	.ok
	add.l	#12,pt_aff_liste
.ok:	bsr	hide_m
	bsr	aff_liste
	bsr	show_m
	rts

aff_liste:
	move.l	pt_aff_liste,d0
	sub.l	anc_pt_aff_liste,d0
	cmp.l	#12,d0
	bne	.may_dn
.may_dn:	cmp.l	#-12,d0
	bne	.ok
.ok:	move.l	pt_aff_liste,anc_pt_aff_liste

	move.w	#3,-(sp)
	trap	#xbios
	addq.l	#2,sp
	move.l	d0,a0
	add.l	#8*160+124,a0
	move.l	#-1,(a0)
	move.l	#-1,4(a0)
	move.w	#183,d0	;lignes
.lop_ef1	move.w	#5,d1	;
	move.l	a0,a1
.lop_ef2	clr.l	(a0)+
	dbra	d1,.lop_ef2
	move.l	a1,a0
	add.l	#160,a0
	dbra	d0,.lop_ef1
	
	move.l	pt_aff_liste,pt_cat2
	move.b	#1,ylign
.loop:	move.b	ylign,.yloc
	add.b	#32,.yloc
	
	;INVERSE
	jsr	print
	dc.b	27,"Y"
.yloc:	dc.b	32
	dc.b	32+62,0
	;NORMAL
	move.l	pt_cat2,a0
	cmp.l	pt_next_liste,a0
	bge	return
	move.l	#buffer,a1
	;move.b	#" ",(a1)+
	move.w	#11,d0
.loop2:	move.b	(a0)+,(a1)+
	dbra	d0,.loop2
	clr.b	(a1)
	move.l	#buffer,d0
	jsr	outstr
	add.b	#1,ylign
	cmp.b	#24,ylign
	beq	.rts
	add.l	#12,pt_cat2
	bra	.loop
.rts:	rts
	

name_liste:	ds.b	12*nb_name_lst
end_name_liste:
pt_liste:	dc.l	0
pt_next_liste:	dc.l	0
pt_aff_liste:	dc.l	0
anc_pt_aff_liste:	dc.l	0

*---------------------- FILE make LISTE --------------------------------
file_liste:
	;entree:	a0=txt d'info(35 octets)
	;	   + 2 + 30 octets pour le catalog
	;	!:souris active
	;sortie:	d3=adr des noms select‚s ou 0 si cancel ou fichier inexistant
	move.l	a0,adr_txt_info
	add.l	#36+2,a0
	move.l	a0,adr_cata
	move.l	#name_liste,a0	;liste des noms choisis
	move.l	a0,pt_liste
	;move.l	a0,pt_next_liste	;set avant appel
	move.l	a0,pt_aff_liste
	clr.l	anc_pt_aff_liste

file_liste2:
	bsr	selector
	INVERSE
	LOCATE	40,0
	bsr	print
	dc.b	" PERSO:",0
	move.l	#perso_name,d0
	bsr	outstr
	bsr	print
	dc.b	" ",0
	LOCATE	37,21
	bsr	print
	dc.b	"DELETE file from Liste",0
	LOCATE	37,23
	bsr	print
	dc.b	"SAVE Liste",0
	LOCATE	61,0
	bsr	print
	dc.b	"    Liste:    ",0
	move.b	#1,ylign
.loop_loc:
	move.b	ylign,.yloc1
	move.b	ylign,.yloc2
	add.b	#32,.yloc1
	add.b	#32,.yloc2
	;locate x,y (0,0 a 39,25)
	jsr	print
	dc.b	27,"Y"
.yloc1:	dc.b	32
	dc.b	32+61," ",0
	
	jsr	print
	dc.b	27,"Y"
.yloc2:	dc.b	32
	dc.b	32+61+13," ",0
	add.b	#1,ylign
	cmp.b	#24,ylign
	bne	.loop_loc
	LOCATE	61,24
	jsr	print
	dc.b	"              ",0
	NORMAL
	cmp.l	#name_liste,pt_next_liste
	beq	.pa_af
	bsr	aff_liste
.pa_af:	
	move.w	#0,d0	;fleche
	bsr	graf_mouse
	bsr	show_m
	
	move.l	#catalog,pt_cat
sel_liste:
	bsr	hide_m
	jsr	aff_names
	bsr	show_m
	
loop_liste:
	bsr	getinput
	cmp.b	#1,d0
	beq	.cancel
	cmp.b	#$1c,d0
	beq	.key_ok
	bsr	test_d0_select
	cmp.b	#-1,d0
	beq	sel_liste
	cmp.b	#-2,d0
	beq	sel_liste	;file_liste2
	move.w	xmouse,d1
	move.w	ymouse,d2
	cmp.w	#201,d0
	bne	loop_liste
	cmp.w	#$128,d1
	blt	.pas_del
	cmp.w	#$1d8,d1
	bgt	.pas_del
	cmp.w	#$a8,d2
	blt	.pas_del
	cmp.w	#$b0,d2
	bgt	.pas_del
	;------ delete 1 file de la liste ----
	move.l	#name_select,a0
	move.l	#name_liste,a1
	move.l	#nb_name_lst,d0
	move.l	#12,d1
	bsr	find_string12
	cmp.l	#0,a1
	beq	loop_liste
	move.l	a1,a0
	add.l	#12,a0
.lop_del:move.b	(a0)+,(a1)+
	cmp.l	#end_name_liste,a0
	blt	.lop_del
	sub.l	#12,pt_next_liste
	bsr	hide_m
	bsr	aff_liste
	bsr	show_m
	bra	loop_liste
	
.pas_del:
	cmp.w	#$b8,d2
	blt	.pas_sav
	cmp.w	#$c0,d2
	bgt	.pas_sav
	cmp.w	#$128,d1
	blt	.pas_sav
	cmp.w	#$178,d1
	bgt	.pas_sav
	;---- sauve la liste
	move.l	#perso_tbl_name,d3
	move.l	#name_liste,d4
	move.l	pt_next_liste,d5
	sub.l	#name_liste,d5
	bsr	save
	bsr	save_liste_dcl		;'abc:dc.l 0',13,10,...
	bsr	save_liste_inc		;'include "\ivan_dat\abc.prs"
	bra	.loop_wait0

.pas_sav	cmp.w	#$18,d2
	blt	loop_liste
	cmp.w	#$1f,d2
	bgt	loop_liste
	cmp.w	#$80,d1
	blt	loop_liste
	cmp.w	#$ae,d1
	bgt	.pas_m2
	;------------- cancel
.cancel:	bsr	hide_m
	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#setscr,-(sp)
	trap	#14
	add.l	#12,sp
	bsr	show_m
.loop_wait0:
	bsr	getinput
	cmp.w	#201,d0
	beq	.loop_wait0
	clr.l	d3
	rts
	
.pas_m2:	cmp.w	#$d8,d1
	blt	loop_liste
	cmp.w	#$f7,d1
	bgt	loop_liste
	;--- ok ----
.key_ok:	move.l	#name_select,a0
	bsr	add_to_liste
	bra	loop_liste


save_liste_dcl:
	move.l	#name_liste,a0
	move.l	start_load_adr,a1
.loop:	cmp.l	pt_next_liste,a0
	beq	.save
	move.l	a0,a2
.loop2:	cmp.b	#" ",(a0)
	beq	.end_name
	tst.b	(a0)
	beq	.end_name
	cmp.b	#".",(a0)
	beq	.end_name
	move.b	(a0)+,(a1)+
	bra	.loop2
.end_name:
	move.b	#":",(a1)+
	move.b	#9,(a1)+
	move.b	#"D",(a1)+
	move.b	#"C",(a1)+
	move.b	#"L",(a1)+
	move.b	#"M",(a1)+
	move.b	#9,(a1)+
	move.b	#"0",(a1)+
	move.b	#13,(a1)+
	move.b	#10,(a1)+
	move.l	a2,a0
	add.l	#12,a0
	bra	.loop
.save:	move.l	start_load_adr,d4
	move.l	a1,d5
	sub.l	d4,d5
	move.l	#perso_dcl_name,d3
	bsr	save
	rts


save_liste_inc:
	move.l	#name_liste,a0
	move.l	start_load_adr,a1
.loop:	cmp.l	pt_next_liste,a0
	beq	.save
	move.l	a0,a2
	move.b	#9,(a1)+
	move.b	#"i",(a1)+
	move.b	#"n",(a1)+
	move.b	#"c",(a1)+
	move.b	#"b",(a1)+
	move.b	#"i",(a1)+
	move.b	#"n",(a1)+
	move.b	#9,(a1)+
	move.b	#34,(a1)+
	move.b	#"\",(a1)+
	move.b	#"i",(a1)+
	move.b	#"v",(a1)+
	move.b	#"a",(a1)+
	move.b	#"n",(a1)+
	move.b	#"_",(a1)+
	move.b	#"s",(a1)+
	move.b	#"p",(a1)+
	move.b	#"r",(a1)+
	move.b	#"\",(a1)+
.loop2:	cmp.b	#" ",(a0)
	beq	.end_name
	tst.b	(a0)
	beq	.end_name
	cmp.b	#".",(a0)
	beq	.end_name
	move.b	(a0)+,(a1)+
	bra	.loop2
.end_name:
	move.b	#".",(a1)+
	move.b	#"s",(a1)+
	move.b	#"p",(a1)+
	move.b	#"r",(a1)+
	move.b	#34,(a1)+	;"
	move.b	#13,(a1)+
	move.b	#10,(a1)+
	move.l	a2,a0
	add.l	#12,a0
	bra	.loop
.save:	move.l	start_load_adr,d4
	move.l	a1,d5
	sub.l	d4,d5
	move.l	#perso_inc_name,d3
	bsr	save
	rts

*---------------------------------------------------------
test_d0_select:
	cmp.w	#201,d0
	bne	return
	clr.l	d2
	move.w	xmouse,d1
	move.w	ymouse,d2
	;----------------- Test clic sur un des noms -----------
	cmp.w	#$08,d1
	blt	.pas_noms
	cmp.w	#$f0,d1
	bgt	.pas_noms
	cmp.w	#$28,d2
	blt	.pas_noms
	cmp.w	#$be,d2
	bgt	.pas_noms
	sub.w	#$28,d2	;y-28
	lsr.w	#3,d2	;y/8
	mulu	#12,d2
	move.l	pt_cat,a0
	add.l	d2,a0
	cmp.l	last_cat,a0
	bge	.pas_noms
	move.l	a0,a2
	move.l	#name_select,a1
	move.w	#11,d0
.lop_03:	cmp.b	(a2)+,(a1)+
	bne	.difer
	dbra	d0,.lop_03
	clr.b	d0
	bra	return		;deja select
	
.difer:	move.l	#name_select,a1
	move.w	#11,d0
.lop_02:	move.b	(a0)+,(a1)+
	dbra	d0,.lop_02
	clr.b	(a1)
	bsr	hide_m
	LOCATE	37,3
	move.l	#name_select,a0
	cmp.b	#7,(a0)
	ble	.new_doss
	clr.b	d0		;pas d'espace avant
	bsr	aff_1_name
	bsr	show_m
	clr.b	d0
	rts
	
.new_doss:	;---- a0=adr nom dossier
	bsr	kkk
	move.l	a0,a5
	move.l	adr_cata,a0
	clr.b	d0
	bsr	find_d0
.nd_l1:	cmp.l	adr_cata,a0		;1em carac
	beq	.oka0
	cmp.b	#"\",-(a0)
	bne	.nd_l1
	add.l	#1,a0

.oka0:	add.l	#1,a5		;deb du dossier
	move.l	#buffer,a1
	move.w	#7,d0
.nd_l2:	cmp.b	#" ",(a5)
	beq	.nd_n2
	tst.b	(a5)
	beq	.nd_oka1
	move.b	(a5),(a1)+
.nd_n2:	add.l	#1,a5
	dbra	d0,.nd_l2
.nd_e2:	clr.b	(a1)
	cmp.b	#" ",(a5)	;extention ?
	beq	.nd_oka1
	tst.b	(a5)
	beq	.nd_oka1
	move.b	#".",(a1)+
	move.w	#2,d0
.nd_l3:	cmp.b	#" ",(a5)
	beq	.nd_n3
	tst.b	(a5)
	beq	.nd_oka1
	move.b	(a5),(a1)+
.nd_n3:	add.l	#1,a5
	dbra	d0,.nd_l3
	clr.b	(a1)
.nd_oka1:
	move.b	#"\",(a1)+
	clr.b	(a1)
	move.l	a0,a1
	move.l	#buffer,a0
	clr.b	d0
	bsr	find_d0
	sub.l	#buffer,a0
	move.l	a0,d0
	sub.l	#1,d0		;long nom avec \ apres ,sans 0
	move.l	a1,a0
	bsr	insert_d00
	move.l	#buffer,a1
.nd_l4:	move.b	(a1)+,(a0)+
	tst.b	(a1)
	bne	.nd_l4
	bsr	cls_cata
	move.l	adr_cata,d0
	bsr	outstr
	bsr	trie_new_selector
	move.l	#name_select,a1
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	LOCATE	37,3
	bsr	print
	dc.b	"            ",0
	move.l	#catalog,pt_cat
	;bsr	show_m
	move.b	#-2,d0
	rts

.pas_noms:
	;----------------- Test clic sur cadre nom -------------
	cmp.w	#$120,d1
	blt	.pas_name
	cmp.w	#$186,d1
	bgt	.pas_name
	cmp.w	#$10,d2
	blt	.pas_name
	cmp.w	#$27,d2
	bgt	.pas_name
	;-- entree du nom au clavier --
	bsr	hide_m
	bsr	print
	dc.b	27,"e",0
	LOCATE	37,3
	bsr	print
	dc.b	"            ",0
	move.l	#name_select,a0
	move.w	#11,d0
.lop_01:	clr.b	(a0)+
	dbra	d0,.lop_01
	LOCATE	37,3
	move.l	#name_select-2,-(sp)
	move.w	#10,-(sp)
	trap	#gemdos
	addq.l	#6,sp
.print_name:
	LOCATE	37,3
	bsr	print
	dc.b	"            ",0
	LOCATE	37,3
	move.l	#name_select,a5
.loop_raf:
	clr.w	d0
	move.b	(a5)+,d0
	tst.b	d0
	beq	.fin_name
	cmp.b	#'.',d0
	bne	.ok_raf
	LOCATE	37+8,3
	move.b	#'.',d0
.ok_raf:	move.w	d0,-(sp)
	move.w	#2,-(sp)
	trap	#gemdos
	addq.l	#4,sp
	bra	.loop_raf
.fin_name:
	bsr	print
	dc.b	27,"f",0
	bsr	show_m
	clr.b	d0
	rts	;bra	loop_sel
.pas_name:
	;----------------- Test clic sur ascenseur up/dn ---------
	cmp.w	#$10f,d1
	blt	.pas_asc
	cmp.w	#$118,d1
	bgt	.pas_asc
	cmp.w	#$28,d2
	blt	.pas_asc
	cmp.w	#$bf,d2
	bgt	.pas_asc
	cmp.w	#$60,d2
	blt	.up_19
	cmp.w	#$6a,d2
	blt	.up_1
	cmp.w	#$6f,d2
	blt	.pas_asc
	cmp.w	#$79,d2
	blt	.dn_1
	;--- dn 19 ----:
	move.l	pt_cat,a0
	add.l	#12*19,a0
	cmp.l	last_cat,a0
	blt	.select_a0
	move.l	last_cat,a0
	sub.l	#12*19,a0
	cmp.l	#catalog,a0
	bge	.select_a0
	move.l	#catalog,pt_cat
	move.b	#-1,d0
	rts	;bra	select
.select_a0:
	move.l	a0,pt_cat
	move.b	#-1,d0
	rts

.dn_1:	move.l	pt_cat,a0
	add.l	#12,a0
	move.l	a0,d0
	add.l	#12*19,d0
	cmp.l	last_cat,d0
	bgt	return	;loop_sel
	cmp.l	last_cat,a0
	bge	.resd1
	move.l	a0,pt_cat
	
	bsr	hide_m
	move.w	#3,-(sp)
	trap	#xbios
	addq.l	#2,sp
	move.l	d0,a0
	add.l	#40*160,a0	;+4,a0
	move.l	a0,a1
	add.l	#8*160,a0
	move.w	#150-8,d0	;lignes
.lop_scd	move.w	#15,d1	;
.lop22:	move.l	(a0)+,(a1)+
	dbra	d1,.lop22
	add.l	#160-4*16,a0
	add.l	#160-4*16,a1
	dbra	d0,.lop_scd
	LOCATE	1,23
	move.l	pt_cat,a0
	add.l	#18*12,a0
	move.b	#1,d0		;espace avant
	bsr	aff_1_name
	bsr	show_m
	clr.w	d0
	rts

.resd1:	move.l	last_cat,a0
	sub.l	#12,a0
	cmp.l	#catalog,a0
	bge	.select_a0
	move.l	#catalog,pt_cat
	move.b	#-1,d0
	rts	;bra	select

.up_19:	move.l	pt_cat,a0
	sub.l	#12*19,a0
	cmp.l	#catalog,a0
	bge	.select_a0
	move.l	#catalog,pt_cat
	move.b	#-1,d0
	rts	;bra	select

.up_1:	move.l	pt_cat,a0
	sub.l	#12,a0
	cmp.l	#catalog,a0
	blt	.resu1
	move.l	a0,pt_cat

	bsr	hide_m
	move.w	#3,-(sp)
	trap	#xbios
	addq.l	#2,sp
	move.l	d0,a0
	add.l	#40*160,a0	;+4,a0
	add.l	#150*160,a0
	move.l	a0,a1
	sub.l	#8*160,a0
	move.w	#150-8,d0	;lignes
.lop_scr	move.w	#15,d1	;
.lop2:	move.l	(a0)+,(a1)+
	dbra	d1,.lop2
	sub.l	#16*4+160,a0
	sub.l	#16*4+160,a1
	dbra	d0,.lop_scr

	LOCATE	1,5
	move.l	pt_cat,a0
	move.b	#1,d0		;espace avant
	bsr	aff_1_name
	bsr	show_m
	clr.w	d0
	rts

.resu1:	move.l	#catalog,pt_cat
	clr.b	d0
	rts	;	bra	select

.pas_asc:
	;--------------- Test clic sur une option du menu ----------
	cmp.w	#8,d2
	blt	.pas_cat
	cmp.w	#16,d2
	bgt	.pas_cat
	cmp.w	#8,d1
	blt	.pas_cat
	cmp.w	#272,d1
	ble	.set_cat
.pas_cat:
	cmp.w	#$18,d2
	blt	return	;.pas_menu
	cmp.w	#$1f,d2
	bgt	return	;.pas_menu
	cmp.w	#$20,d1
	blt	return	;.pas_menu
	cmp.w	#$56+8,d1
	bgt	.pas_m1
	;------------ previous directory -----
	move.l	adr_cata,a0
	;   c:\devpac2\ivanoe\data\*.abc	a:\*.abc
	;-->c:\devpac2\ivanoe\*.abc	a:\*.abc
	move.l	adr_cata,a0
	clr.b	d0	;nb de '\'
.pre_l1:	tst.b	(a0)
	beq	.pre_e1
	cmp.b	#"\",(a0)+
	bne	.pre_l1
	move.l	a0,a1
	add.b	#1,d0
	bra	.pre_l1
.pre_e1:	cmp.b	#2,d0
	blt	.pas_m1		;on ne peux pas descendre plus !
	move.l	a1,a0
	sub.l	#2,a0
.pre_l2:	cmp.b	#"\",(a0)
	beq	.pre_e2
	sub.l	#1,a0
	bra	.pre_l2
.pre_e2:	add.l	#1,a0		;apres le 1er '\'
	sub.l	a0,a1
	move.l	a1,d0		;nb d'octets a deleter
	bsr	delete_d00
	bsr	hide_m
	bsr	cls_cata
	move.l	adr_cata,d0
	bsr	outstr
	bsr	trie_new_selector
	bsr	show_m
	move.l	#name_select,a1
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	LOCATE	37,3
	bsr	print
	dc.b	"            ",0
	move.l	#catalog,pt_cat
	move.b	#-2,d0		;code recalcul catalog
	rts
	
.set_cat:
	;------------ set cat:
	bsr	hide_m
	bsr	cls_cata
	move.l	adr_cata,a0
	move.w	#30,d0
.loop_clr:
	clr.b	(a0)+
	dbra	d0,.loop_clr
	bsr	print
	dc.b	27,"e",0
	move.l	adr_cata,d0
	sub.l	#2,d0
	bsr	input_d0
	bsr	print
	dc.b	27,"f",0
	bsr	show_m		;elle sera hid‚e
	bsr	trie_new_selector
	move.l	#name_select,a1
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	LOCATE	37,3
	bsr	print
	dc.b	"            ",0
	move.l	#catalog,pt_cat
	move.b	#-2,d0
	rts	;bra	file_select2

.pas_m1:	rts
	
.pas_m2:	rts
*---------------------------------------------------------------------
kkk:	rts

cls_cata:
	LOCATE	5,1
	bsr	print
	dc.b	"                             ",0
	INVERSE
	bsr	print
	dc.b	" ",0
	NORMAL
	bsr	print
	dc.b	"                        ",0
	LOCATE	5,1
	rts

aff_1_name:
	move.l	#buffer,a1
	move.w	#11,d1
.lop0:	move.b	#" ",(a1)+
	dbra	d1,.lop0
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	cmp.b	#7,(a0)
	bne	.normal
	move.w	#7,d0
	move.l	a0,-(sp)
	bsr	print_ascii
	move.l	(sp)+,a0
	add.l	#1,a0
	move.l	#buffer,a1
	move.w	#7,d0
.lop:	move.b	(a0)+,(a1)+
	tst.b	-1(a1)
	bne	.next
	move.b	#" ",-1(a1)
.next:	dbra	d0,.lop
	cmp.b	#" ",(a0)
	beq	.afbuf
	tst.b	(a0)
	beq	.afbuf
	move.b	#".",(a1)+
	move.w	#2,d0
.lop2:	move.b	(a0)+,(a1)+
	tst.b	-1(a1)
	bne	.next2
	move.b	#" ",-1(a1)
.next2:	dbra	d0,.lop2
	clr.b	(a1)
	bra	.afbuf
	
.normal:	move.l	#buffer,a1
	clr.b	12(a1)
	tst.b	d0
	beq	.pas_spa
	move.b	#" ",(a1)+
.pas_spa:move.w	#11,d0
.lop3:	move.b	(a0)+,(a1)+
	tst.b	-1(a1)
	bne	.next3
	move.b	#" ",-1(a1)
.next3:	dbra	d0,.lop3
.afbuf:	move.l	#buffer,d0
	bra	outstr



aff_names:
	move.w	#3,-(sp)
	trap	#xbios
	addq.l	#2,sp
	move.l	d0,a0
	add.l	#40*160+4,a0
	move.w	#150,d0	;lignes
.lop_ef1	move.w	#15,d1	;
	move.l	a0,a1
	clr.b	-1(a0)
	clr.b	-3(a0)
.lop_ef2	clr.l	(a0)+
	dbra	d1,.lop_ef2
	move.l	a1,a0
	add.l	#160,a0
	dbra	d0,.lop_ef1
	
	move.l	pt_cat,pt_cat2
	move.b	#5,ylign
.loop:	move.b	ylign,.yloc
	add.b	#32,.yloc
	
	INVERSE
	jsr	print
	dc.b	27,"Y"
.yloc:	dc.b	32
	dc.b	32," ",0
	NORMAL
	move.l	pt_cat2,a0
;---------
	;move.l	#buffer,a1
	;move.b	#" ",(a1)+
	;move.w	#11,d0
;.loop2:	;move.b	(a0)+,(a1)+
	;dbra	d0,.loop2
	;clr.b	(a1)
	;move.l	#buffer,d0
	;jsr	outstr
	bsr	aff_1_name
;---------
	add.b	#1,ylign
	cmp.b	#24,ylign
	beq	.rts
	add.l	#12,pt_cat2
	bra	.loop
.rts:	rts
	
	
chaines_zero?:
	tst.b	(a0)
	bne	.tsta1
	rts
.tsta1:	tst.b	(a1)
	rts
	

;cmp_chain:	;compare chaine a1 et a0 se terminant par 0
;		;d0=nb d'octets max par chaine +1 ou 0
;		;gt si a1>a0
;		;lt si a1<a0
;		;eq si a1=a0
;
;	move.l	a0,a2
;	move.l	a1,a3
;.loop:	cmp.b	(a2)+,(a3)+
;	bne	.rts
;	dbra	d0,.loop
;.rts:	rts


;swap_chain:
;	REPT	3
;	move.l	(a0),d0
;	move.l	(a1),(a0)+
;	move.l	d0,(a1)+
;	ENDR
;	rts
	
input_d0:
	move.l	d0,-(sp)
	NORMAL
	bsr	print
	dc.b	27,"e",0		;curseur clignot
	move.l	(sp)+,d0
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#10,-(sp)
	trap	#gemdos
	addq.l	#6,sp
	bsr	print
	dc.b	27,"f",0		;curseur normal
	move.l	(sp)+,a0
	clr.l	d0
	move.b	1(a0),d0	;nb carac entr‚s
	add.l	#2,a0	;a0=debut chaine
	add.l	d0,a0	;a0=fin chaine
	clr.b	(a0)	;met le 0 de fin de chaine
	rts

flag_changed:	dc.b	0
flag_espaces:	dc.b	0
	even
dta:		ds.b	44
	even
		dc.b	30,0
cherch_name:	dc.b	"\*.*",0	;path
		ds.b	30
		even
		dc.b	12,0
name_select:	ds.b	13	;nom sur 12 caracteres
		ds.b	20
file_name:	ds.b	40	;nom entier= path$ + name_select$
	
		even
catalog:		ds.b	500*12	;500 noms
pt_cat:		dc.l	0	
pt_cat2:		dc.l	0	
last_cat:	dc.l	0
ylign:		dc.w	0
adr_txt_info:	dc.l	0
adr_cata:	dc.l	0
free_disc:	dc.l	0
total_disc:	dc.l	0
buf_disc:	ds.l	4

copy_to_0:
	;a1=source
	;a0=dest
	tst.b	(a1)
	beq	return
	move.b	(a1)+,(a0)+
	bra	copy_to_0
return	rts

copy_path:
	;a1=source
	;a0=dest
	cmp.b	#".",(a1)
	beq	delete_trop
	move.b	(a1)+,(a0)+
	bra	copy_path

delete_trop:
	;a1 pointe sur "." de "x:\xxx\xxx\xx.xx
	cmp.b	#"\",(a1)
	beq	plus_un
	sub.l	#1,a0
	sub.l	#1,a1
	bra	delete_trop
	
plus_un:
	add.l	#1,a0
	rts

load_path:	dc.b	"\*.P?1",0
		ds.b	80
load_file:	dc.b	0
		ds.b	40
load_name:	dc.b	"\pres2.pi1",0
		ds.w	40

****************************************
aff_d0:	move.l	#28,d1
	move.l	d0,d3
aff_d02	move.l	d3,d0
	lsr.l	d1,d0
	bsr	aff_d03
	subq.l	#4,d1
	bge	aff_d02
	rts
	
aff_d03	and.l	#$f,d0	;conversion
	cmp.b	#9,d0
	bgt	aff_d05	;lettre
	add.b	#$30,d0
aff_d04	move.w	d0,-(sp)
	move.w	#2,-(sp)	;outchar
	trap	#gemdos	
	addq.l	#4,sp
	rts
aff_d05	add.b	#$37,d0
	bra	aff_d04


code_d0_hex:	;entree:d0.l --> (a0)+ en ascii,sans $
.aff_d0:	move.l	#28,d1
	move.l	d0,d3
.aff_d02	move.l	d3,d0
	lsr.l	d1,d0
	bsr	.aff_d03
	subq.l	#4,d1
	bge	.aff_d02
	rts
	
.aff_d03	and.l	#$f,d0	;conversion
	cmp.b	#9,d0
	bgt	.aff_d05	;lettre
	add.b	#$30,d0
.aff_d04	;move.w	d0,-(sp)
	;move.w	#2,-(sp)	;outchar
	;trap	#gemdos	
	;addq.l	#4,sp
	move.b	d0,(a0)+
	rts
.aff_d05	add.b	#$37,d0
	bra	.aff_d04


used_plans:
	;in :a0=adr data sprite
	;out:d0.w=info plans
	move.w	nblig,d0
	move.w	wordx,d1
	add.w	#1,d0
	add.w	#1,d1
	mulu	d0,d1	;d1=long data sprite en blocs
	move.l	a0,a1
	clr.l	flag_plan0
	move.l	#flag_plan0,a3
	lea	0(a1),a2
	jsr	used?
	lea	2(a1),a2
	jsr	used?
	lea	4(a1),a2
	jsr	used?
	lea	6(a1),a2
	jsr	used?
	clr.b	d0
	cmp.l	#$01010101,flag_plan0
	beq	.rts
	LOCATE	0,18
	jsr	print
	dc.b	"Plans utilis‚s:",0
	move.b	#%11100000,d0
	move.l	#txt_pl123,d1
	tst.b	flag_plan0
	beq	.okd0
	move.b	#%11000000,d0
	move.l	#txt_pl023,d1
	tst.b	flag_plan1
	beq	.okd0
	move.b	#%10100000,d0
	move.l	#txt_pl013,d1
	tst.b	flag_plan2
	beq	.okd0
	move.b	#%10000000,d0
	move.l	#txt_pl012,d1
	tst.b	flag_plan3
	beq	.okd0
	move.b	#0,d0
	move.l	#txt_plbug,d1
.okd0:	move.w	d0,-(sp)
	move.l	d1,-(sp)
	move.w	#9,-(sp)
	trap	#gemdos
	addq.l	#6,sp
	move.w	(sp)+,d0
.rts:	lsl.w	#8,d0
	move.w	d0,data_plans
	rts

used?:	;a2=adr data
	;d1=nb blocs
	;a3=flag si used
	move.w	d1,d0
	sub.w	#1,d0
.loop:	tst.w	(a2)
	beq	.next
	move.b	#1,(a3)+
	rts
.next:	add.l	#8,a2
	dbra	d0,.loop
	add.l	#1,a3
	rts

txt_pl123:	dc.b	"1,2,3",0
txt_pl023:	dc.b	"0,2,3",0
txt_pl013:	dc.b	"0,1,3",0
txt_pl012:	dc.b	"0,1,2",0
txt_plbug:	dc.b	"?????",0

	even
flag_plan0:	dc.b	0
flag_plan1:	dc.b	0
flag_plan2:	dc.b	0
flag_plan3:	dc.b	0
data_plans:	dc.w	0
*--------------------------------------------
save_sprite:	; l'adresse des data du sprite est dans adbufspr
	move.l	adbufspr,a0
	move.l	a0,a1
	sub.l	#long_entete,a0	;a0=adr debut fichier
	
	move.w	nblig,(a0)	;
	move.w	wordx,2(a0)
	move.w	lxt,4(a0)
	move.w	data_plans,6(a0)
	move.l	#0,d1
	move.l	#0,d0
	move.w	(a0),d1
	add.w	#1,d1		;nb de lignes
	move.w	2(a0),d0
	add.w	#1,d0		;nb de bloc de 4 Word=8 oct
	lsl	#3,d0		;nb d'octets par ligne
	mulu	d1,d0		;nb d'octets de data du sprite
	add.l	#long_entete,d0	;long fichier
	
	move.l	a0,-(sp)
	move.l	#name_select,a0
	move.l	#path_sprites,a1
	bsr	copy_path
	move.l	#sprite_name,a1
	bsr	copy_to_0
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.l	(sp)+,a0

	move.l	#name_select,d3	;#adnom2,d3	;adr du nom
	move.l	a0,d4		;adr debut fichier
	move.l	d0,d5		;longeur fichier
	bsr	save
	rts
	

affspr2:; --- aff  sprite simple ---
	;entree: a1=adr ecr  a2=adr buffer sprite
	;	 d1=nb bloc de 4 Word -1
	;	 d2=nb de lignes
	move.w	d1,d3
	
afs21:	move.l	a1,a3
	move.w	d3,d1
afs22:	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	move.w	(a2)+,(a1)+
	dbra	d1,afs22
	move.l	a3,a1
	add.l	#160,a1
	dbra	d2,afs21
	rts
*------------------------------------------------------

memospr:; --- recuperation sprite ---
	;entree: a1=adr ecr  a2=adr buffer sprite
	;	 d1=nb bloc de 4 Word-1
	;	 d2=nb de lignes
	move.w	d1,d3
	
memos1:	move.l	a1,a3
	move.w	d3,d1
memos2:	move.w	(a1)+,(a2)+
	move.w	(a1)+,(a2)+
	move.w	(a1)+,(a2)+
	move.w	(a1)+,(a2)+
	dbra	d1,memos2
	move.l	a3,a1
	add.l	#160,a1
	dbra	d2,memos1
	rts
*------------------------------------------------------
sprafxy:
*=================================================================
*=								 =
*=		   ROUTINE D'AFFICHAGE DES SPRITES		 =
*=								 =
*=			   AVEC CLIPPING			 =
*=								 =
*= entete du sprite:
*   ;0(a2).w=nb de lignes
*   ;2(a2).w=nb de blocs de 16 pixels
*   ;4(a2).w=nb de pixels en largeur (inutile pour spraff)
*   ;6(a2).w: inutilis‚ pour spraff
*   
*   ;les data commencent en 8(a2)						 =
*=================================================================

* A2 = ADRESSE SPRITE

* D0 = COOR X
* D3 = COOR Y


	move.l	#0,d1
	tst.l	d3
	bmi	minus
	move.l	d3,d1	;y
	move.l	d3,d2
	lsl.l	#5,d1	;*32
	lsl.l	#7,d2	;*128  =*160
	add.l	d2,d1
minus:	move.l	d0,d2	;x
	lsr	#2,d2	;x/4
	move.l	page2,a1
	cmp.b	#2,flag_work
	bne	.ok
	move.l	e_travail,a1
.ok:	clr.l	d1
	clr.l	d2
	cmp.l	#debut_ram,a2
	blt	return
	move.w	(a2),d2 	;d2=nb de lignes-1
	move.w	2(a2),d1	;d1=nb de block de word-1
	add.l	#1,d1
	add.l	#1,d2
	add.l	#8,a2		;adr sprite
	
		;		    MOVEM.L A0-A6/D0-D7,-(SP)
		
		cmp.w	limhaut,d3
		bge	.ok2
		move.w	limhaut,d4
		   sub.w	d3,D4
		   CMP.W D2,D4
		   BGE SPRAFF8		;rts si trop haut
		move.w	limhaut,d4
		sub.w	d3,d4		;nb lignes a enlever
		move.w	d1,d5
		mulu	d4,d5		;delta a2
		mulu	#8,d5
		move.w	limhaut,d3
		sub.w	d4,d2
		add.l	d5,a2
		
.ok2:		   MOVEA.L #flag,A0
		   CLR.L D7
		   CLR.L D4
		   CLR.L D5
		   CLR.L D6
		   CLR.W 2(A0)
		   MOVE.L D6,A5
		   CMP.W #0,D3
		   BPL.S CLIPB
		   MOVEQ.L #1,D6
		   MOVE.W D6,A5
		   NEG D3
		   CMP.W D2,D3
		   BGE SPRAFF8		;rts si trop haut
		   MOVE.W D3,D7
		   CLR.L D3		;
		   BRA.S CALCUL1
CLIPB:
		   MOVE.W limbas,D4
		   CMP.W D4,D3
		   BGE SPRAFF8
		   MOVE.W D3,D6
		   ADD.W D2,D6
		   CMP.W D4,D6
		   BLE.S CALCUL1
		   SUB.W D4,D6
		   MOVE.W D6,D7
CALCUL1:
		   MOVE.W D2,D5
		   MOVE.W D7,D6
		   SUB.W D6,D5
		   MOVE.W D5,D2
		   MOVE.W D1,D4
		   LSL.W #3,D4
		   MULU D7,D4		;ha
		   MOVE.W A5,D6
		   MULU D6,D4		;ha
		   ADDA.L D4,A2
		   MOVE.W D3,D5
		   ;registres utilisables ici: d4,d6
		;move.l	d5,d4	;y
		;move.l	d5,d6
		;lsl.l	#5,d4	;*32
		;lsl.l	#7,d6	;*128  =*160
		;add.l	d4,d6
		;add.l	d6,d5
		 MULU #160,D5		;ha
		   ADDA.L D5,A1
		   MOVE.W D0,D6
		   BMI.S CLIPG
		   AND.L #$FFFF,D6
		   DIVU #16,D6		;ha
		   LSL.W #3,D6
		   ADDA.W D6,A1
		   SWAP D6
		   MOVE.W D6,D4
CLIPG:
		   CLR.W (A0)
		   CLR.W 4(A0)
		   CMP.W #0,D0
		   BEQ CLIPD
		   BPL CLIPD
		   NEG D0
		   MOVE.W D0,D4
		   SUBQ.W #1,D4
		   AND.W #$F,D4
		   EORI.W #$F,D4
		   MOVE.W D1,D5
		   LSL.W #4,D5
		   CMP.W D0,D5
		   BLT SPRAFF8
		   AND.L #$FFFF,D0
		   DIVU #16,D0		;ha
		   MOVE.L D0,D7
		   SWAP D7
		   TST.W D7
		   BEQ.S CLIPG1
		   ADDQ.W #1,D0
CLIPG1:
		   MOVE.W D0,2(A0)
		   BRA.S SPRAFF1
CLIPD:
		   CMP.W #320,D0
		   BGE SPRAFF8
		   MOVE.W D0,D5
		   MOVE.W D1,D6
		   LSL.W #4,D6
		   ADD.W D6,D5
		   CMP.W #320,D5
		   BLE.S SPRAFF1
		   MOVE.W #1,(A0)
		   SUB.W #320,D0
		   NEG D0
		   AND.L #$FFFF,D0
		   DIVU #16,D0		;ha
		   MOVE.L D0,D7
		   SWAP D7
		   TST.W D7
		   BEQ.S CLIPD1
		   ADDQ.W #1,D0
CLIPD1:
		   MOVE.W D0,2(A0)
SPRAFF1:
		   SUBQ.W #1,D1
		   SUBQ.W #1,D2
		   MOVE.W D4,D0
SPRAFF2:
		   MOVE.L A1,-(SP)
		   MOVE.W D1,-(SP)
		   CLR.L D5
		   CLR.L D6
		   MOVE.W 2(A0),D4
		   MOVE.W D4,4(A0)

SPRAFF3:
		   MOVEM.W D1-D2,-(SP)
		   MOVE.L D5,D1
		   MOVE.L D6,D3
		   SWAP D5
		   SWAP D6
		   MOVE.L D5,D2
		   MOVE.L D6,D4
		   MOVE.W (A2)+,D1
		   MOVE.W (A2)+,D2
		   MOVE.W (A2)+,D3
		   MOVE.W (A2)+,D4
		   MOVE.W D1,D5
		   MOVE.W D3,D6
		   SWAP D5
		   SWAP D6
		   MOVE.W D2,D5
		   MOVE.W D4,D6

		   TST.W (A0)
		   BEQ.S SPRAFF4
		   TST.W 4(A0)
		   BLE SPRAFF6
		   SUBQ.W #1,4(A0)
		   BRA.S SPRAFF5
SPRAFF4:
		   TST.W 4(A0)
		   BLE.S SPRAFF5
		   SUBQ.W #1,4(A0)
		   BPL SPRAFF6
SPRAFF5:
		   LSR.L D0,D1
		   LSR.L D0,D2
		   LSR.L D0,D3
		   LSR.L D0,D4

*				BRANCHEMENT DE LA ROUTINE DE REMAP

		   MOVE.W D1,D7
		   OR.W D2,D7
		   OR.W D3,D7
		   OR.W D4,D7
		   NOT.W D7
		   AND.W D7,(A1)
		   OR.W D1,(A1)+
		   AND.W D7,(A1)
		   OR.W D2,(A1)+
		   AND.W D7,(A1)
		   OR.W D3,(A1)+
		   AND.W D7,(A1)
		   OR.W D4,(A1)+
SPRAFF6:
		   MOVEM.W (SP)+,D1-D2
		   DBF D1,SPRAFF3
		   MOVE.W (SP)+,D1

		   TST.W (A0)
		   BNE SPRAFF7

		   MOVEM.W D1-D2,-(SP)
		   MOVE.L D5,D1
		   MOVE.L D6,D3
		   SWAP D5
		   SWAP D6
		   MOVE.L D5,D2
		   MOVE.L D6,D4
		   CLR.W D1
		   CLR.W D2
		   CLR.W D3
		   CLR.W D4
		   LSR.L D0,D1
		   LSR.L D0,D2
		   LSR.L D0,D3
		   LSR.L D0,D4

*				BRANCHEMENT DE LA ROUTINE DE REMAP

		   MOVE.W D1,D7
		   OR.W D2,D7
		   OR.W D3,D7
		   OR.W D4,D7
		   NOT.W D7
		   AND.W D7,(A1)
		   OR.W D1,(A1)+
		   AND.W D7,(A1)
		   OR.W D2,(A1)+
		   AND.W D7,(A1)
		   OR.W D3,(A1)+
		   AND.W D7,(A1)
		   OR.W D4,(A1)+
		   MOVEM.W (SP)+,D1-D2
SPRAFF7:
		   MOVE.L (SP)+,A1
		   ADD.L #160,A1
		   DBF D2,SPRAFF2
SPRAFF8:
		;		    MOVEM.L (SP)+,D0-D7/A0-A6
		   RTS

flag:	ds.l	10
limbas:	dc.w	150
limhaut	dc.w	50

*****************************************************************
*								*
*		ROUTINE DE REMAP DES SPRITES			*
*								*
*		ROUGES, VERTS, BLEUS & GRIS			*
*								*
*****************************************************************
;
;	Les sprites utilisent … l'origine la couleur 4.
;	Les couleurs 12 … 15 ne doivent pas etre utilis‚es dans le sprite.
;
;
;	GRIS	:	COULEUR 4
;	VERT	:	COULEUR 5
;	BLEU	:	COULEUR 6
;	ROUGE	:	COULEUR 7
;
;REMAPVERT:
;		TST.W	FLAGVERT
;		BNE.S	REMAPBLEU
;		OR.W	D3,D1
;		RTS
;REMAPBLEU:
;		TST.W	FLAGBLEU
;		BNE.S	REMAPROUGE
;		OR.W	D3,D2
;		RTS
;REMAPROUGE:
;		TST.W	FLAGROUGE
;		BNE.S	REMAPFIN
;		OR.W	D3,D1
;		OR.W	D3,D2
;REMAPFIN:
;		RTS



;=================================================================
;=                                                               =
;=                 ROUTINE D'AFFICHAGE DES SPRITES               =
;=                                                               =
;=================================================================

; A1 = ADRESSE ECRAN
; A2 = ADRESSE SPRITE

; D0 = INCREMENT DE ROTATION VERS LA GAUCHE
; D1 = NBRE DE block de 4 Word PAR LIGNE
; D2 = NBRE DE LIGNES

affspr:
                   MOVEM.L A0/A2-A6/D0-D7,-(SP)
SPRAFF1_2:
                   MOVEM.L A1/D1-D2,-(SP)
                   CLR.L D5
                   CLR.L D6
SPRAFF2_2:
                   MOVE.W D1,-(SP)
                   MOVE.W D5,D1
                   MOVE.W D6,D2
                   SWAP D5
                   SWAP D6
                   MOVE.W D5,D3
                   MOVE.W D6,D4
                   SWAP D1
                   SWAP D2
                   SWAP D3
                   SWAP D4
                   MOVE.W (A2)+,D1
                   MOVE.W (A2)+,D2
                   MOVE.W (A2)+,D3
                   MOVE.W (A2)+,D4
                   MOVE.W D3,D5
                   MOVE.W D4,D6
                   SWAP D5
                   SWAP D6
                   MOVE.W D1,D5
                   MOVE.W D2,D6
                   LSL.L D0,D1
                   LSL.L D0,D2
                   LSL.L D0,D3
                   LSL.L D0,D4
                   SWAP D1
                   SWAP D2
                   SWAP D3
                   SWAP D4
                   MOVE.W D1,D7
                   OR.W D2,D7
                   OR.W D3,D7
                   OR.W D4,D7
                   NOT.W D7
                   AND.W D7,(A1)
                   OR.W D1,(A1)+
                   AND.W D7,(A1)
                   OR.W D2,(A1)+
                   AND.W D7,(A1)
                   OR.W D3,(A1)+
                   AND.W D7,(A1)
                   OR.W D4,(A1)+
                   MOVE.W (SP)+,D1
                   DBF D1,SPRAFF2_2

                   CLR.L D1
                   CLR.L D2
                   CLR.L D3
                   CLR.L D4
                   MOVE.W D5,D1
                   MOVE.W D6,D2
                   SWAP D5
                   SWAP D6
                   MOVE.W D5,D3
                   MOVE.W D6,D4
                   LSL.L D0,D1
                   LSL.L D0,D2
                   LSL.L D0,D3
                   LSL.L D0,D4
                   MOVE.W D1,D7
                   OR.W D2,D7
                   OR.W D3,D7
                   OR.W D4,D7
                   NOT.W D7
                   AND.W D7,(A1)
                   OR.W D1,(A1)+
                   AND.W D7,(A1)
                   OR.W D2,(A1)+
                   AND.W D7,(A1)
                   OR.W D3,(A1)+
                   AND.W D7,(A1)
                   OR.W D4,(A1)+
                   MOVEM.L (SP)+,A1/D1-D2
                   ADD.L #160,A1
                   
                   DBF D2,SPRAFF1_2
                   MOVEM.L (SP)+,D0-D7/A0/A2-A6
                   RTS

*------------------------------------------------------------
cls_hard:;efface ecran a0
	move.w	#32000/4-1,d0
cls_h2:	clr.l	(a0)+
	dbra	d0,cls_h2
	rts
	

transmouse:
	move.w	#37,sintin
	move.l	#datamouse,a0
	move.l	#intin,a1
	move.w	#36,d0
transm2	move.w	(a0)+,(a1)+
	dbra	d0,transm2
	move.w	#111,opcode
	jsr	vdi
	rts


graf_mouse:	;entree :d0.w =forme souris
	move.w	#1,aintin
	move.w	#1,aintout
	move.w	#1,aaddrin
	move.w	d0,intin
	move.l	#datamouse,addrin
	move.w	#78,opcode
	cmp.w	#22,d0
	bne	.norm
	move.w	#255,intin
	move.l	#datamouse2,addrin
.norm:	jsr	aes
	move.w	intout,d0
	rts


init_vdi:	;et aes

	move.w	#10,opcode	;appl init
	clr.w	aintin
	clr.w	aaddrin
	clr.l	ap1resv
	clr.l	ap2resv
	clr.l	ap3resv
	clr.l	ap4resv
	jsr	aes

	move.w	#77,opcode	;graf handle
	clr.w	aintin
	clr.w	aaddrin
	move.w	#5,aintout
	jsr	aes
	move.w	intout,handle

	move.w	#100,opcode	;open Workstation
	clr.w	sptsin
	move.w	#11,sintin
	move.w	#1,intin
	move.w	#1,intin+2
	move.w	#1,intin+4
	move.w	#1,intin+6
	move.w	#1,intin+8
	move.w	#1,intin+10
	move.w	#1,intin+12
	move.w	#1,intin+14
	move.w	#1,intin+16
	move.w	#1,intin+18
	move.w	#2,intin+20
	jsr	vdi
	rts

*----------------
	
exit_vdi:
	move.w	#101,opcode
	clr.l	sptsin
	clr.l	sintin
	jsr	vdi
	
	move.w	#19,opcode
	clr.l	aintin
	clr.l	aaddrin
	jsr	aes
	rts
	
	
*---------------------------------

vdi:	movem.l	d0-d1,-(sp)
	move.l	#vdipb,d1
	move.w	#$73,d0
	trap	#2
	movem.l	(sp)+,d0-d1
	rts
	
aes:	movem.l	d0-d1,-(sp)
	move.l	#aespb,d1
	move.w	#$c8,d0
	trap	#2
	movem.l	(sp)+,d0-d1
	rts

************************ data pour .INF *********************************
loadecr_txt:	dc.b	"          Load screen              ",0
		dc.b	30,0
		dc.b	"\ECRSPR\*.P?1",0
		ds.b	30-16

liste_txt:	dc.b	"          Make files liste         ",0
		dc.b	30,0
		dc.b	"\IVAN_SPR\*.SPR",0
		ds.b	35-18


load_liste_txt:	dc.b	"            Select Perso           ",0
		dc.b	30,0
		dc.b	"\IVAN_DAT\*.TBL",0
		ds.b	35-18
		
		dc.b	30,0
path_sprites:	dc.b	"\IVAN_SPR\*.SPR",0
		ds.b	35-18
		
		dc.b	30,0
path_data:	dc.b	"\IVAN_DAT\*.*",0
		ds.b	30

		dc.b	30,0
path_anim:	dc.b	"\IVAN_DAT\*.ANI",0
		ds.b	30

	even
*************************************************************************
loadecr:
	move.l	#loadecr_txt,a0
	bsr	file_select
	tst.l	d3
	beq	return
	bsr	hide_m
	move.l	d3,a0
	clr.b	d0
	bsr	find_d0
	cmp.b	#"C",-3(a0)
	bne	.pi1
	move.l	page3,d4
	sub.l	#34,d4
	bsr	load
	move.l	page3,a0
	move.l	page2,a1
	sub.l	#34,a0
	jsr	decompc1
	move.l	page3,a0
	bra	.loaded
.pi1:	move.l	page2,d4
	sub.l	#34,d4
	bsr	load
	move.l	page2,a0
.loaded
	sub.l	#32,a0
	move.l	a0,-(sp)
	move.w	#6,-(sp)		;setcolor
	trap	#xbios
	addq.l	#6,sp
	move.l	page2,d3
	bsr	visu4
	bsr	show_m
	rts
	
		dc.b	2,0
perso_2name:	ds.b	3
	even

decompc1:
	include	"\includes\decompc1.s"


input_save:
	cmp.b	#1,flag_auto_name
	bne	.simple
	bsr	decode_name
 	move.l	#sprite_name,a0
	move.l	#perso_2name,a1
	bsr	add_string
	bsr	aff_n01
.simple:
	LOCATE	1,24
	bsr	print
	dc.b	"          "
	dc.b	"          "
	dc.b	"          "
	dc.b	"          ",0	;40 car
	LOCATE	1,22
	bsr	print
	dc.b	"NEW PATH",0
	LOCATE	11,22
	bsr	print
	dc.b	"CANCEL",0
	LOCATE	19,22
	bsr	print
	dc.b	"ENTER NAME",0
	LOCATE	32,22
	bsr	print
	dc.b	"SAVE",0
	LOCATE	0,24
	bsr	print
	dc.b	"Path=",0
	move.l	#path_sprites,d0
	bsr	outstr
	LOCATE	0,0
	bsr	print
	dc.b	"Perso:  ",0
	LOCATE	6,0
	move.l	#perso_2name,d0
	bsr	outstr
	
	
	move.w	#0,d0	;fleche
	bsr	graf_mouse
	bsr	show_m
loop_sav:
	bsr	getinput
	
	cmp.b	#$1,d0		;ESC = cancel
	beq	.cancel
	cmp.w	#201,d0
	bne	.pas_menu
	clr.l	d2
	move.w	xmouse,d1
	move.w	ymouse,d2
	cmp.w	#$40,d1
	bgt	.pas_pers
	cmp.w	#$8,d2
	bgt	.pas_pers
	bsr	hide_m
	LOCATE	6,0
	bsr	print
	dc.b	"  ",0
	LOCATE	6,0
	move.l	#perso_2name-2,d0
	bsr	input_d0
	move.l	#sprite_name,a0
	move.l	#perso_2name,a1
	bsr	add_string
	bsr	aff_n01
	bsr	show_m
.pas_pers:
	cmp.w	#$b0,d2
	blt	loop_sav
	cmp.w	#$b8,d2
	bgt	loop_sav
	cmp.w	#$08,d1
	blt	loop_sav
	cmp.w	#$48,d1
	ble	.enter_path
	cmp.w	#$58,d1
	blt	loop_sav
	cmp.w	#$88,d1
	ble	.cancel
	cmp.w	#$98,d1
	blt	loop_sav
	cmp.w	#$e8,d1
	ble	.enter_name
	cmp.w	#$100,d1
	blt	loop_sav
	cmp.w	#$120,d1
	ble	.save
	
.pas_menu:
	cmp.b	#$1c,d0		;ENTER=save
	beq	.save
	bra	loop_sav
	
.save:	move.l	#sprite_name,d0
	bsr	legal_name?
	bne	loop_sav
	bsr	save_sprite

.cancel:	move.w	#255,d0
	bsr	graf_mouse
	bsr	hide_m
	rts
	
.enter_path:
	bsr	hide_m
	LOCATE	5,24
	bsr	print
	dc.b	"          "
	dc.b	"          "
	dc.b	"               ",0	;35 car
	LOCATE	5,24
	move.l	#path_sprites-2,d0
	bsr	input_d0
	LOCATE	0,24
	bsr	print
	dc.b	"Path=",0
	move.l	#path_sprites,d0
	bsr	outstr
	bsr	show_m
	bra	loop_sav

.enter_name:
	bsr	hide_m
	LOCATE	0,1
	bsr	print
	dc.b	"Name:            ",0
	LOCATE	5,1
	move.l	#sprite_name-2,d0
	bsr	input_d0
	move.l	#sprite_name,a0
	move.l	#perso_2name,a1
	bsr	add_string
	LOCATE	0,1
	bsr	print
	dc.b	"                 ",0
	bsr	aff_n01
	bsr	show_m
	bra	loop_sav


add_string:	;a0=a1+a0
	move.l	a1,a2
	clr.w	d0
.loop:	tst.b	(a2)
	beq	.end
	add.l	#1,a2
	add.b	#1,d0
	bra	.loop
.end:	tst.b	d0
	beq	return
	bsr	insert_a0_d0	;d0=lenght(a1)
	sub.b	#1,d0		;car dbra
.loop2:	move.b	(a1)+,(a0)+
	dbra	d0,.loop2
	rts
	
insert_a0_d0:
	tst.b	d0
	beq	return
	move.l	a0,a2
	clr.l	d2
.lop:	tst.b	(a2)
	beq	.end
	add.l	#1,a2
	add.b	#1,d2
	bra	.lop
.end:	;d2=long a0
	clr.l	d1
	move.b	d0,d1
	move.l	a0,a3
	move.l	a0,a2
	add.l	d1,a2
	add.l	d2,a3
	add.l	d2,a2
.loop:	move.b	(a3),(a2)
	cmp.l	a3,a0
	beq	return
	sub.l	#1,a3
	sub.l	#1,a2
	bra	.loop

find_string:
	;entree:	a0=adr chaine a chercher (finie par 0)
	;	a1=adr chaine zone de recherche (finie par 0)
	;Sortie: a0=adr chaine dans a1  OU 0
	;	a1=carac suivant la chaine
	move.l	a0,a2
	move.l	a1,a3
.loop1:	cmp.b	(a0)+,(a1)+
	bne	.next_a1
	tst.b	(a0)		;carac fin de a0
	bne	.loop1
	move.l	a3,a0
	rts	;---- Trouved ----
.next_a1:
	move.l	a2,a0
	move.l	a3,a1
	add.l	#1,a1
	tst.b	(a1)		;carac fin de a1
	bne	find_string
	move.l	#0,a0
	rts	;---- Not Trouved ----
	

find_string12:
	;a0.l=adr de la chaine a chercher
	;a1.l=adr debut zone de recherche
	;d0.l=nb de recherches a faire
	;d1.l=increment de a1 apres chaque test
	;--- retour:a1=adr chaine dans zone OU 0 si pas trouv‚e
	move.l	a0,a2
	move.l	a1,a3
	move.w	#11,d2		;recherche sur 12 carac
.loop1:	cmp.b	(a0)+,(a1)+
	bne	.next_a1
	dbra	d2,.loop1
	move.l	a3,a1
	rts	;---- Trouved ----
.next_a1:
	move.l	a2,a0
	move.l	a3,a1
	add.l	d1,a1
	sub.w	#1,d0
	bne	find_string12
	move.l	#0,a1
	rts	;---- Not Trouved ----
*-----------------------------------------
	
inkey:	move.w	#7,-(sp)
	trap	#gemdos
	addq.l	#2,sp
	rts
	
	
calc_asci:	;entree: d0=nombre a coder
		; 	 a0=adr ou mettre la chaine (3 chiffres)
	move.b	#"0",d2
calc1	cmp.w	#100,d0
	blt	calc2
	add.b	#1,d2
	sub.w	#100,d0
	bra	calc1
calc2	move.b	d2,(a0)+
	move.b	#"0",d2
calc3	cmp.w	#10,d0
	blt	calc4
	add.b	#1,d2
	sub.w	#10,d0
	bra	calc3
calc4	move.b	d2,(a0)+
	move.b	#"0",d2
calc5	cmp.w	#1,d0
	blt	calc6
	add.b	#1,d2
	sub.w	#1,d0
	bra	calc5
calc6	move.b	d2,(a0)+
	rts
	
	
getinput:;-------- vq_mouse(handle,&status,&x,&y); = vdi 124 p810----------
	move.w	#$ff,-(sp)
	move.w	#6,-(sp)
	trap	#gemdos
	addq.l	#4,sp
	swap	d0		;d0.w=code scan
	cmp.w	#0,d0
	bne	getend
	
	move.w	$2842,xmouse
	move.w	$2844,ymouse
	clr.w	d0
	move.b	$283e,d0
	and.b	#3,d0
	tst.w	d0
	beq	getend
	add.b	#200,d0
getend:	cmp.b	#$19,d0		;"p"
	bne	.pas_s
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	init_rs232
	bsr	cls_vt52
	move.l	adr_tbl_pos,a0
	bsr	send_rs232
	move.l	#aff1_vt52,a0
	bsr	send_rs232
	move.l	pt_pos,a0
	bsr	send_rs232
	bsr	restore_rs232
	movem.l	(sp)+,d0-d7/a0-a6
.pas_s:	cmp.b	#$27,d0		;"m"
	bne	.pas_m
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	init_rs232
	move.l	#aff2_vt52,a0
	bsr	send_rs232
	move.w	xmouse,d0
	move.l	#buffer80,a0
	bsr	decode_d0_ascii
	move.b	#",",(a0)+
	move.w	ymouse,d0
	bsr	decode_d0_ascii
	move.b	#13,(a0)+
	move.b	#10,(a0)+
	clr.b	(a0)
	move.l	#buffer80,a0
	bsr	send_rs232
	bsr	restore_rs232
	movem.l	(sp)+,d0-d7/a0-a6
.pas_m:	cmp.b	#$10,d0		;"a"
	bne	.pas_a
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	init_rs232
	bsr	cls_vt52
	move.l	adr_anim_ascii,a0
	bsr	send_rs232
	move.l	#aff1_vt52,a0
	bsr	send_rs232
	move.l	pt_anim,a0
	bsr	send_rs232
	bsr	restore_rs232
	movem.l	(sp)+,d0-d7/a0-a6
.pas_a:
	rts
	
cls_vt52:
	move.l	#code_cls_vt52,a0
	bra	send_rs232
	
code_cls_vt52:	dc.b	27,"E",0
aff1_vt52:	dc.b	13,10,"pt_anim:",13,10,0
aff2_vt52:	dc.b	13,10,"xyMOUS:",0
buffer80:	ds.b	80
total_saisie:	dc.l	0

getspr:	bsr	hide_m	;dc.w	$a00a
	move.l	page2,ecrpts

	move.w	xmouse,d0
	move.w	ymouse,d1
	move.w	#1,a0
	bsr	getpix		;d0=coul a0=adr ecr
	move.w	d0,coulcadr
	move.w	xmouse,xg
	move.w	#1,nblig
	
	move.w	xg,xt
	move.w	ymouse,yt
	bsr	testup		;incremente nblig et trouve  yh

	move.w	xg,xt
	move.w	ymouse,yt
	bsr	testdown		;incremente nblig et trouve yb
	sub.w	#1,nblig
	
	move.w	xg,xt
	move.w	yh,yt
	bsr	testright	;trouve xd

	move.w	xg,d0
	move.w	yh,d1
	add.w	#1,d0
	add.w	#1,d1
	bsr	getpix
	move.l	a0,coinhg
		
	move.w	xd,d0
	move.w	yh,d1
	sub.w	#1,d0
	add.w	#1,d1
	bsr	getpix
	move.l	coinhg,a1
	sub.l	a1,a0
	move.l	a0,d0
	lsr	#1,d0
	add.l	#4,d0		;nb Word
	lsr	#2,d0		;nb block 4 Word
	sub.w	#1,d0		;-1
	move.w	d0,wordx


	move.w	yb,d0
	sub.w	yh,d0
	move.w	d0,lyt
	move.w	xd,d0
	sub.w	xg,d0
	move.w	d0,lxt
	
	cmp.w	#200,lyt
	bge	gets_end
	cmp.w	#320,lxt
	bge	gets_end
	cmp.w	#2,lxt
	bmi	gets_end
	cmp.w	#2,lyt
	bmi	gets_end
			
	cmp.w	#1,nblig
	bmi	gets_end
	cmp.w	#198,nblig
	bgt	gets_end
	;cmp.w	#1,wordx
	;bmi	gets_end
	cmp.w	#18,wordx
	bgt	gets_end

	bsr	encadre
	bsr	getspr1
	
	move.l	page3,a0
	bsr	cls_hard

	bsr	get_name		;prend 9*8 pixels sur 8 pix h pour nom
				;et le met en graphic_name bien cal‚
	move.l	page3,a0
	bsr	cls_hard
	
	move.l	page3,a1
	move.l	adbufspr,a2
	move.w	wordx,d1
	move.w	nblig,d2
	move.w	xg,d0
	add.w	#1,d0
	and.w	#$000f,d0
	bsr	affspr
	
	move.l	page3,a0
	move.w	#198,d0
gets2	move.l	#0,(a0)+
	move.l	#0,(a0)+
	add.l	#160-8,a0
	dbra	d0,gets2
	
	move.w	lxt,d0
	add.w	#15,d0
	move.w	d0,xt
	bsr	eff_droite
	bsr	getspr2
	move.w	#-1,-(sp)	;res
	move.l	#-1,-(sp)	;pys
	move.l	page3,-(sp)	;log
	move.w	#setscr,-(sp)
	trap	#xbios
	add.l	#12,sp
	move.l	page3,a0
	move.l	#32000/4-1,d0
gets4:	move.l	#$ffff0000,(a0)+
	dbra	d0,gets4
	
	move.l	page3,a1
	add.l	#20*160+8,a1
	move.l	adbufspr,a2
	move.w	nblig,d2
	move.w	wordx,d1
	bsr	affspr2

	;move.l	adbufspr,a2
	;clr.l	d0
	move.w	nblig,d0
	move.l	#hauteur,a0
	bsr	calc_asci	

	move.w	nblig,d2
	move.w	wordx,d1
	add.w	#1,d1
	add.w	#1,d2
	mulu	d2,d1
	lsl.l	#3,d1	;8 octets par blocs
	add.l	#8,d1	;+8=entete
	add.l	d1,total_saisie
	
	move.l	page3,d3
	bsr	visu4
	
	LOCATE	30,2
	bsr	print
	dc.b	"h="
hauteur:	dc.b	"000",0
	LOCATE	1,20
	bsr	print
	dc.b	"Total:",0
	move.l	total_saisie,d0
	move.l	#buffer,a0
	bsr	dec_d0_long
	clr.b	(a0)
	move.l	#buffer,d0
	bsr	outstr
	move.l	adbufspr,a0
	bsr	used_plans
	bsr	raf_name
	bsr	input_save
		
gets_end:
	move.l	page2,d3
	bsr	visu4
	bsr	show_m	;dc.w	$a009
gets3:	bsr	getinput
	cmp.w	#201,d0
	beq	gets3
	
	rts

*----------------
eff_droite:	; efface 16 colones de lyt-2 lignes a partir de xt ->xt+15 
	move.l	page3,ecrpts
	move.w	lyt,yt
	sub.w	#2,yt
	move.w	xt,xg
	
eff_d1:	move.w	xg,xt
	move.w	#16,ptr
eff_d2:	move.w	xt,d0
	move.w	yt,d1
	move.w	#0,a0
	bsr	plot
	add.w	#1,xt
	sub.w	#1,ptr
	bne	eff_d2
	sub.w	#1,yt
	bge	eff_d1
	
	rts

*----------------
encadre:	;trace un cadre xg,yh,xd,yb (et lxt,lyt)sur ecran ecrpts
	move.w	xg,xt
	move.w	yh,yt
	move.w	#1,dxt
	move.w	#0,dyt
	move.w	lxt,d0
	bsr	draw
	
	move.w	xg,xt
	move.w	yh,yt
	move.w	#0,dxt
	move.w	#1,dyt
	move.w	lyt,d0
	bsr	draw

	move.w	xd,xt
	move.w	yh,yt
	move.w	#0,dxt
	move.w	#1,dyt
	move.w	lyt,d0
	bsr	draw
	
	move.w	xg,xt
	move.w	yb,yt
	move.w	#1,dxt
	move.w	#0,dyt
	move.w	lxt,d0
	add.w	#1,d0	;correction ???
	bsr	draw
	rts
	
*------------

draw:	move.w	d0,ptr
	tst.w	d0
	ble	.bad
	cmp.w	#320,d0
	blt	draw2
.bad:	move.w	#1,ptr
draw2:	move.w	xt,d0
	move.w	yt,d1
	move.w	col_pl,a0
	bsr	plot
	move.w	dxt,d1
	move.w	dyt,d2
	add.w	d1,xt
	add.w	d2,yt
	sub.w	#1,ptr
	bne	draw2
	rts

*--------------
testup:	
	sub.w	#1,yt
	cmp.w	#-1,yt
	beq	t_up_end
	move.w	xt,d0
	move.w	yt,d1
	bsr	getpix
	cmp.w	coulcadr,d0
	bne	t_up_end
	add.w	#1,nblig
	add.l	#160,coinhg
	bra	testup
t_up_end:
	sub.w	#1,nblig
	sub.l	#160,coinhg
	add.w	#1,yt
	move.w	yt,yh
	rts
	
				
				
	
testdown:
	add.w	#1,yt
	cmp.w	#200,yt
	beq	t_dn_end
	move.w	xt,d0
	move.w	yt,d1
	bsr	getpix
	cmp.w	coulcadr,d0
	bne	t_dn_end
	add.w	#1,nblig
	bra	testdown
t_dn_end:
	sub.w	#1,nblig
	sub.w	#1,yt
	move.w	yt,yb
	rts
	
testright:
	add.w	#1,xt
	cmp.w	#320,xt
	bge	t_ri_end
	move.w	xt,d0
	move.w	yt,d1
	bsr	getpix
	cmp.w	coulcadr,d0
	bne	t_ri_end
	move.w	xt,d0
	move.w	yt,d1
	move.w	col_pl,a0
;	bsr	plot
	bra	testright
t_ri_end:
	sub.w	#1,xt
	move.w	xt,xd
	rts

col_pl:	dc.w	0	;couleur plot

getspr1:
	move.l	coinhg,a1
	move.l	adbufspr,a2
	move.w	wordx,d1
	move.w	nblig,d2
	bsr	memospr
	rts

getspr2:	move.l	page3,a1
	add.l	#8,a1
	move.l	adbufspr,a2
	move.w	nblig,d2
	move.w	lxt,d1
	sub.w	#2,d1		;d1=nb de pix x du sprite
	lsr	#2,d1
	and.w	#%1111111111111100,d1		;d1=nb de Word-4
	add.w	#4,d1
	lsr	#2,d1	
	sub.w	#1,d1				;d1=nb de block de 4 Word
	move.w	d1,wordx
	bsr	memospr
	rts



get_name:		;prend 9*8 pixels sur 8 pix h pour nom
			;et le met en graphic_name bien cal‚
;----------- get graphic name v1 -------------
	;entree=coinhg =adr debut sprite
	;nblig
	move.l	coinhg,a0
	move.w	xg,d0
	add.w	#1,d0
	and.w	#$000f,d0	;0 si x=47 par ex
	tst.w	d0
	bne	.ok
	tst.w	xg
	beq	.ok
	sub.l	#8,a0
.ok:	move.w	nblig,d0
	add.w	#2,d0
	mulu	#160,d0
	add.l	d0,a0
	move.l	#graphic_name,a1
	move.w	#7,d1	;8 lignes
.loop1:	move.w	#4,d0	;5 blok de 16 pix maxi
	move.l	a0,a2
.loop2:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.loop2
	move.l	a2,a0
	add.l	#160,a0
	dbra	d1,.loop1
	
	move.l	page3,a1
	move.l	#graphic_name,a2
	move.w	#4,d1
	move.w	#5,d2
	move.w	xg,d0
	move.w	d0,d3
	add.w	#1,d3
	and.w	#$000f,d3
	and.w	#$000f,d0	;0 si x=48
	tst.w	d0
	bne	.okk
	tst.w	xg
	beq	.okk
	cmp.w	#1,d3
	bne	.ok15
	clr.w	d0
	bra	.okk
.ok15:	move.w	#15,d0
.okk:	bsr	affspr
	
	;move.l	page3,d3
	;bsr	visu4
	;bsr	getch
	
;----------- get graphic name v2 -------------
zobi:	move.l	page3,a0
	move.l	#graphic_name,a1
	move.w	#5,d1	;6 lignes
.loop1:	move.w	#4,d0	;5 blok de 16 pix maxi
	move.l	a0,a2
.loop2:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.loop2
	move.l	a2,a0
	add.l	#160,a0
	dbra	d1,.loop1
	rts

raf_name:
	move.l	page3,a0
	add.l	#128,a0
	move.l	#graphic_name,a1
	move.w	#5,d1	;6 lignes
.loop1:	move.w	#3,d0	;4 blok de 16 pix maxi
	move.l	a0,a2
	add.l	#8,a1
.loop2:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d0,.loop2
	move.l	a2,a0
	add.l	#160,a0
	dbra	d1,.loop1

;---------- get graphic name ok ---------------
zobo:	move.l	page3,a0
	add.l	#128,a0
	move.l	#graphic_name,a1
	move.w	#5,d1	;6 lignes
.loop1:	move.w	#3,d0	;4 blok de 16 pix maxi
	move.l	a0,a2
.loop2:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,.loop2
	move.l	a2,a0
	add.l	#160,a0
	dbra	d1,.loop1
	rts


graphic_name:
		ds.b	8*5*8	;8 lignes de 5 block de 16 pixels
buf_decod:	ds.b	8*8
		dc.b	12,0
sprite_name:	ds.b	16

decode_name:	;met graphic_name en ascii
	move.l	#graphic_name,a0
	move.l	#sprite_name,a1
	clr.l	(a1)
	clr.l	4(a1)	;efface les 8 octets du nom
.loop:	bsr	decode_graph	;selon a0 ;retour=d0.b
	cmp.b	#37,d0
	beq	.fin
	tst.b	d0
	beq	.fin
	add.b	#$30-1,d0	;si chiffre
	cmp.b	#$39,d0
	ble	.ok
	add.b	#7,d0	;si lettre
.ok:	move.b	d0,(a1)+
	movem.l	a0-a1,-(sp)
	bsr	decale_graph
	movem.l	(sp)+,a0-a1
	bra	.loop
.fin:	move.b	#".",(a1)+
	move.b	#"S",(a1)+
	move.b	#"P",(a1)+
	move.b	#"R",(a1)+
	move.b	#0,(a1)+
	rts
	
aff_n01:	LOCATE	0,1
	move.l	#sprite_name,d0
	bsr	outstr

	move.l	#sprite_name,d0
	bsr	legal_name?
	beq	return
	bsr	print
	dc.b	" :ILLEGAL NAME!",0
	rts

decale_graph:	;--- decale de 6 pixels vers gauche sur 4 blok ---
	move.l	a0,a2
	bsr	.dec6	;plan 1
	move.l	a0,a2
	add.l	#2,a2
	bsr	.dec6	;plan 2
	move.l	a0,a2
	add.l	#4,a2
	bsr	.dec6	;plan 3
	move.l	a0,a2
	add.l	#6,a2
	bsr	.dec6	;plan 4
	rts


.dec6:	move.w	#5,d0	;6 lignes
.dec62	bsr	.dec_li
	add.l	#8*4,a2
	dbra	d0,.dec62
	rts
	
.dec_li:	;--- decale une ligne de 4 words de 6 pix (1 plan)
	move.w	#5,d3
.lop01:
	move.w	(a2),d1
	lsl.w	#1,d1
	move.w	d1,(a2)
	move.w	8(a2),d2
	btst	#15,d2
	beq	.ok1
	bset	#0,1(a2)
.ok1:	
	move.w	8(a2),d1
	lsl.w	#1,d1
	move.w	d1,8(a2)
	move.w	16(a2),d2
	btst	#15,d2
	beq	.ok2
	bset	#0,9(a2)
.ok2:	
	move.w	16(a2),d1
	lsl.w	#1,d1
	move.w	d1,16(a2)
	move.w	24(a2),d2
	btst	#15,d2
	beq	.ok3
	bset	#0,17(a2)
.ok3:	
	move.w	24(a2),d1
	lsl.w	#1,d1
	move.w	d1,24(a2)
	dbra	d3,.lop01
	rts
	
decode_graph:
	;--- met une lettre dans #buf_decod
	move.w	#5,d1	;6 lignes
	move.l	#buf_decod,a3
	move.l	a0,a2
.loop:	move.w	(a2)+,(a3)
	and.w	#$fc00,(a3)+
	move.w	(a2)+,(a3)
	and.w	#$fc00,(a3)+
	move.w	(a2)+,(a3)
	and.w	#$fc00,(a3)+
	move.w	(a2)+,(a3)
	and.w	#$fc00,(a3)+
	add.l	#3*8,a2	;4 blocs
	dbra	d1,.loop

	move.l	#police+8,a2
	move.w	#35,d1		;36 chiffres et lettres
	clr.b	nb_police
loop_tst:
	move.l	#buf_decod,a3
	move.l	a2,a4
	move.w	#5,d5	;6 lignes
loop_lign:
	move.w	(a3),d3
	or.w	2(a3),d3
	or.w	4(a3),d3
	or.w	6(a3),d3		;d3=mask ligne lettre a tester
	
	move.w	(a4),d4
	or.w	2(a4),d4
	or.w	4(a4),d4
	or.w	6(a4),d4		;d4=mask ligne lettre de police
	btst.b	#0,nb_police
	beq	.gauche
	and.w	#$00fc,d4	;6 pixels de large
	lsl.w	#8,d4
	bra	.ok
.gauche:	and.w	#$fc00,d4
.ok:	cmp.w	d3,d4
	bne	next_police
	
	add.l	#8,a3		;prochaine ligne lettre a tester
	add.l	#36/2*8,a4
	dbra	d5,loop_lign
	;---- toutes les lignes sont egales ----
	move.b	nb_police,d0
	add.b	#1,d0
	rts
next_police:
	btst.b	#0,nb_police
	beq	.pas8
	add.l	#8,a2
.pas8:	add.b	#1,nb_police
	dbra	d1,loop_tst
	;------- aucune lettre egale ------
	clr.b	d0
	rts
	
	

	IFNE	0
	movem.l	a0-a1,-(sp)
	move.w	#3,-(sp)
	trap	#xbios
	addq.l	#2,sp
	add.l	#160*160,d0
	move.l	d0,a0
	move.l	#buf_decod,a1
	move.w	#5,d0	;6 lignes
.lop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	add.l	#160-8,a0
	dbra	d0,.lop
	bsr	getch
	movem.l	(sp)+,a0-a1
	clr.w	d0
	rts
	ENDC
nb_police:	dc.w	0

*-----------------------------------------------------------------
legal_name?:	;d0=adr chaine du nom,0
	;caracteres autoris‚es: . 0-9 :  A-Z  _  a-z
	;sortie : EQ ou NE
	movem.l	d0-d1/a0,-(sp)
	move.l	d0,a0
	clr.b	d1	;compteur de carac
	cmp.b	#'.',(a0)
	beq	.illeg
	tst.b	(a0)
	beq	.illeg
.loop:	move.b	(a0),d0
	tst.b	d0
	beq	.fin
	cmp.b	#".",d0
	beq	.next
	cmp.b	#"0",d0
	blt	.illeg
	cmp.b	#"9",d0
	ble	.next
	cmp.b	#":",d0
	beq	.next
	cmp.b	#"_",d0
	beq	.next
	cmp.b	#"A",d0
	blt	.illeg
	cmp.b	#"Z",d0
	ble	.next
	cmp.b	#"a",d0
	blt	.illeg
	cmp.b	#"z",d0
	ble	.next
.illeg:
	movem.l	(sp)+,d0-d1/a0
	cmp.l	#0,sp	;NEQ
	rts
	
.next:	add.l	#1,a0
	add.b	#1,d1
	bra	.loop
	
.fin:	cmp.b	#12,d1
	bgt	.illeg
	movem.l	(sp)+,d0-d1/a0
	cmp.b	d0,d0	;EQ
	rts

plot:   ;plot (x,y,coul)
	;Entree:  d0=x  d1=y  a0=coul ;ecrpts=adr ecran
	
	cmp.w	#320,d0
	bge	plot_end
	cmp.w	#0,d0
	bmi	plot_end
	cmp.w	#200,d1
	bge	plot_end
	cmp.w	#0,d1
	bmi	plot_end
	
	and.l	#$0000ffff,d0
	and.l	#$0000ffff,d1
	move.w	a0,d2
	and.l	#$0000ffff,d2
	move.l	d2,a0
	

        move.l  d0,d3           ; x
        move.l  a0,d7           ;coul
        move.l  ecrpts,d4           ;adr base ecran
        mulu    #160,d1         ;y*160
        add.l   d1,d4           ;d4.l=adecr + y*160
        
        move.l  #16,d5
        move.l  d3,d0           ;x
        divu    d5,d0
        move.l  #0,d6
        move.w  d0,d6           ;d6.w=quotient
        swap    d0              ;d0.w=reste
        mulu    #8,d6
        add.l   d4,d6           ;d6.l=adecr + y*160 + int(x/16)*8
        
*---TRANSFORMATION DE a0=coul 0/15,d0=reste  -->  D2 ET D3------*
        move.l  d7,d4           ;d4=couleur 0000 a 1111
        move.l  #0,d2
        move.l  #0,d3
        move.w  #15,d1
        sub.w   d0,d1           ;d1=15-d0 : no du bit de 15 a 0
        
        btst    #3,d4           ;test bit 3
        beq     non_b0
        bset    d1,d3            ; set bit 
non_b0: btst    #2,d4           ;test bit 2
        beq     non_b1
        move.w  d1,d0
        add.w   #16,d0
        bset    d0,d3            ; set bit 
non_b1: btst    #1,d4           ;test bit 1
        beq     non_b2
        bset    d1,d2            ; set bit
non_b2: btst    #0,d4           ;test bit 0
        beq     non_b3
        move.w  d1,d0
        add.w   #16,d0
        bset    d0,d2            ; set bit
non_b3:
*----------------------- fin routine        
                        ; registres a garder pour la suite:
                        ; d6=adr ecran
                        ; d2,d3 = coul sur 2 long
                        ; d1=no du bit: 15 a 0
        move.l  d6,a1
        
        move.l  #0,d4
        bset    d1,d4
        add.l   #16,d1
        bset    d1,d4
        not.l   d4
        move.l  d4,d5   ;d4,d5=masque invers‚ 64 bits
        and.l   (a1)+,d4
        and.l   (a1)+,d5
        sub.l   #8,a1
        or.l    d4,d2
        or.l    d5,d3
        
        
        move.l  d2,(a1)+
        move.l  d3,(a1)+

plot_end: rts
        
*-----------------------------------------------------------------
getpix: ;c=getpix(x,y) 
	;entree: 
        ;	d0.w   ;x 0 a 319
        ;	d1.w   ;y 0 a 199
        ;sortie:
        ;	d0.w=couleur (0 a 15)
        ;	a0=adresse ecran
        
        and.l	#$0000ffff,d0
        and.l	#$0000ffff,d1
        
        
        move.l  d0,d3           ; x
        move.l	ecrpts,d4           ; d4=adr base ecran

	mulu    #160,d1         ;y*160
        add.l   d1,d4           ;d4.l=adecr + y*160
        
        move.l  #16,d5
        move.l  d3,d0           ;x
        divu    d5,d0
        move.l  #0,d6
        move.w  d0,d6           ;d6.w=quotient
        swap    d0              ;d0.w=reste
        mulu    #8,d6
        add.l   d4,d6           ;d6.l=adecr + y*160 + int(x/16)*8
        
*---TRANSFORMATION DE d6=adecr,d0=reste  -->  d4=coul 0 a 15 ------*
        move.l  #0,d4           ;d4=couleur 0000 a 1111
        move.l  d6,a0
        move.l  (a0)+,d2
        move.l  (a0)+,d3
        move.w  #15,d1
        sub.w   d0,d1           ;d1=15-d0 : no du bit de 15 a 0
        
        btst    d1,d3
        beq     no_b0
        bset    #3,d4           ;set bit 3
no_b0:  move.w  d1,d0
        add.w   #16,d0
        btst    d0,d3
        beq     no_b1
        bset    #2,d4           ;set bit 2
no_b1:  btst    d1,d2
        beq     no_b2
        bset    #1,d4           ;set bit 1
no_b2:  move.w  d1,d0
        add.w   #16,d0
        btst    d0,d2
        beq     no_b3
        bset    #0,d4           ;set bit 0
no_b3:
        
        move.l  #0,d0
        move.w  d4,d0
	move.l	d6,a0
        rts





visu:	;--------entree : d3=addresse de l'ecran a voir-----------
	;selectionne adresse ecran pour prochain vbl
	;
	move.l	#visu2,-(sp)
	move.w	#supexec,-(sp)
	trap	#xbios
	addq.l	#6,sp
	rts
	
visu2:	move.l	d3,$45e
	move.l	d3,$44e
	rts

copyecr	move.l	d2,-(sp)
	move.l	#32000/4-1,d2
.loop	move.l	(a0)+,(a1)+
	dbra	d2,.loop
	move.l	(sp)+,d2
	rts
	

*-----------------------------------
save:	;----- entree : d3=adr du nom		;resave
	;		d4=adr zone a sauver
	;		d5=longueur

	move.b	inter_coul,d0
	move.b	d0,memo_inter
	bsr	int_off
	move.w	#0,-(sp)	;fichier lecture et ecriture
	move.l	d3,-(sp)
	move.w	#create,-(sp)	;creation et ouverture
	trap	#gemdos
	addq.l	#8,sp
	
	move.w	d0,ident	;memo ident
	
	move.l	d4,-(sp)	;adr chargement	
	move.l	d5,-(sp)	;longeur
	move.w	d0,-(sp)	;push identificateur
   	move.w	#fwrite,-(sp)
	trap	#gemdos
	adda.l	#12,sp 
	
	move.w	ident,-(sp)
	move.w	#fclose,-(sp)
	trap	#gemdos
	addq.l	#4,sp		;
	tst.b	memo_inter
	beq	.rts		;il n'y avait pas d'inter
	bsr	int_on
.rts:	rts





*-----------------------------------
load:	;----- entree:  d3=adr du nom       ------------------------
	;		d4=adr de chargement
	move.b	inter_coul,d0
	move.b	d0,memo_inter
	bsr	int_off
	move.w	#0,-(sp)	;mode 0=lecture
	move.l	d3,-(sp)	;adr nom
	move.w	#fopen,-(sp)	;code file_open
	trap	#gemdos
	addq.l	#8,sp		;d0=n d'identificateur
	
	tst.l	d0
	bge	ok0		;si d0>=0
	bsr	print
	dc.b	1,13,"Fichier  ",0		;12 octets=paire
	move.l	d3,d0
	bsr	outstr
	bsr	print
	dc.b	" introuvable ",0	;14 = paire
	bsr	getch
ok0:	move.w	d0,ident	;memo ident
	
	move.l	d4,-(sp)	;adr chargement	
	move.l	#400000,-(sp)	;longeur
	move.w	d0,-(sp)	;push identificateur
   	move.w	#fread,-(sp)
	trap	#gemdos
	adda.l	#12,sp 
	
	move.w	ident,-(sp)
	move.w	#fclose,-(sp)
	trap	#gemdos
	addq.l	#4,sp		;
	tst.b	memo_inter
	beq	.rts		;il n'y avait pas d'inter
	bsr	int_on
.rts:	rts

memo_inter:	dc.w	0

visu4:	move.w	#-1,-(sp)
	move.l	d3,-(sp)
	move.l	d3,-(sp)
	move.w	#setscr,-(sp)
	trap	#xbios
	adda.l	#12,sp
	rts


memo_pal:
	move.l	#anc_pal,a3
	clr.l	d3
.loop	move.w	#-1,-(sp)
	move.w	d3,-(sp)
	move.w	#7,-(sp)	;set color
	trap	#xbios
	addq.l	#6,sp
	move.w	d0,(a3)+
	addq.w	#1,d3
	cmp.w	#16,d3
	bne	.loop
	rts

reset_pal:
	move.l	#anc_pal,a3
	clr.l	d3
.loop	move.w	(a3)+,-(sp)
	move.w	d3,-(sp)
	move.w	#7,-(sp)	;set color
	trap	#xbios
	addq.l	#6,sp
	add.w	#1,d3
	cmp.w	#16,d3
	bne	.loop
	rts

init_rs232:
	move.l	a0,SAVE_A0
	CLR.L -(SP)
	MOVE #$20,-(SP)		; SUPERVISEUR
	TRAP #1
	ADD.L #6,SP
	MOVE.L D0,SAVE_SSP
	
	MOVEQ #12,D1
	MOVE D1,-(SP)		; numero vecteur
	MOVE #26,-(SP)		; disable interrupt mfp
	TRAP #14
	ADD.L #4,SP
	move.l	SAVE_A0,a0
	rts

SAVE_SSP:dc.l	0
SAVE_A0:	dc.l	0

restore_rs232:
	MOVE #12,-(SP)		; vecteur 12
	MOVE #27,-(SP)		; enable interrupt mfp
	TRAP #14
	ADD.L #4,SP

	MOVE.L SAVE_SSP,-(SP)
	MOVE #$20,-(SP)		;USER
	TRAP #1
	ADD.L #6,SP
	rts

send_rs232:			;entree:a0=adr chaine a envoyer
	move.l	#$fffa01,a1
.loop:	CLR.L 	D0
	MOVE.B 	(A0)+,D0
.WAI_MFP	BTST 	#7,$2C(A1)	;
	BEQ 	.WAI_MFP
	MOVE.B 	D0,$2E(A1)
	TST.B 	D0		;octet de fin de chaine=0
	BEQ 	.rts
	BRA 	.loop
.rts	RTS


anc_pal		ds.w	20	;16 couleurs
anc_rez 	ds.w	1


nom:	dc.b	"\JUNGLE.PI1",0
	even
	
nom2:	dc.b	"\KIKO1.PI1",0


;Block parametres VDI:
vdipb:	dc.l	control_
	dc.l	intin
	dc.l	ptsin
	dc.l	intout
	dc.l	ptsout
	
aespb:	dc.l	control_
	dc.l	global_
	dc.l	intin
	dc.l	intout
	dc.l	addrin
	dc.l	addrout
	
	
;Tableaux de parametres VDI:
control_:
opcode:	ds.w	1	;control (0)

aintin:
sptsin:	ds.w	1	;control (1)

aintout:
sptsout:ds.w	1	;control (2)

aaddrin:
sintin:	ds.w	1	;control (3)

aaddrout:
sintout:ds.w	1	;control (4)

subcode:ds.w	1	;control (5)
handle:	ds.w	1	;control (6)
	ds.w	4

global_:
apvers:	ds.w	1
apcount:ds.w	1
apid:	ds.w	1
appriv:	ds.l	1
apptree:ds.l	1
ap1resv:ds.l	1
ap2resv:ds.l	1
ap3resv:ds.l	1
ap4resv:ds.l	1

	
intin:	ds.w	128
ptsin:	ds.w	256
intout:	ds.w	128
ptsout:	ds.w	128
addrin:	ds.w	128
addrout:	ds.w	256
	ds.w	50



ident:		dc.w	0	;identificateur pour gestion disc
larg:		dc.l	0
page1:		dc.l	0
page2:		dc.l	0
page3:		dc.l	0
ecrpts:		dc.l	0
page_stock:	dc.l	0
flag_stock:	dc.w	0
adr_anim_stock:	dc.l	0
flag_load_anim:	dc.w	0
adrpile:		dc.l	0
adpoke:		dc.l	0
coolcol:		dc.w	0,$555,0,$555,0,$555,0,$555,$555,0,$555,0,$555,0,$555,0

xt:		ds.w	1
yt:		ds.w	1
dxt:		ds.w	1
dyt:		ds.w	1
lxt:		ds.w	1
lyt:		ds.w	1
xg:		ds.w	1
xd:		ds.w	1
yh:		ds.w	1
yb:		ds.w	1
coinhg:		ds.l	1
wordx:		ds.l	1
coulcadr:	ds.w	1
nblig:		ds.w	1
adbufspr:	ds.l	1
ptr:		ds.l	1
mode:		dc.l	0

cool_col:	dc.w	0,$555,0,$555
		ds.w	10
		dc.w	0,$555

xmouse:		ds.w	1
ymouse:		ds.w	1
flag_auto_name:	dc.l	0
buffer:		ds.b	80
nb_files:	dc.w	0

*------------- fin nouvelles variables ----------*

*-------------------------------------------------------------------
lignes	equ	20		;hauteur de chaque bande en lignes
palette	equ	$ff8240		;adr registre couleur 0
vbl_vec	equ	28		;no du vecteur d'exception routine vbl
key_vec	equ	70		; -  -	-	   -		-  clavier et souris
tbvec	equ	$100+8*4		;adresse du vecteur du timer B
mpf	equ	$fffa00		;adr registres du mpf
iera	equ	mpf+$07		;Interupt enable register
isra	equ	mpf+$0f		;Interupt in Service Register pour les 16 sources
imra	equ	mpf+$13		;Interupt Mask Register	pour les 16 sources
tbcr	equ	mpf+$1b		;Timer B Control Register
tbdr	equ	mpf+$21		;Timer B Data Register

int_on:	;rts
	tst.b	inter_coul
	bne	.rts			;deja on !!!!
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	#1,inter_coul		;flag
	move.l	#palinit,adrpal		;premiere palette
	pea	intb_on			;desactive Timer B et
	move.w	#supexec,-(sp)		;place le nouveau vecteur Timer B
	trap	#xbios
	addq.l	#6,sp
	
	move.l	#vbl_ir,-(sp)		;place le nouveau vecteur VBL
	move.w	#vbl_vec,-(sp)
	move.w	#setexec,-(sp)
	trap	#bios
	addq.l	#8,sp
	move.l	d0,vbl_anc		;et stoque l'ancien
	
	move.l	#key_ir,-(sp)		;place le nouveau vecteur Clavier
	move.w	#key_vec,-(sp)
	move.w	#setexec,-(sp)
	trap	#bios
	addq.l	#8,sp
	move.l	d0,key_anc		;et stoque l'ancien

        move.w  #5,-(sp)        	;desactive MPF 200 Hz
        move.w  #26,-(sp)
        trap    #xbios
        addq.l  #4,sp
	movem.l	(sp)+,d0-d7/a0-a6
.rts:	rts
	
int_off:	;rts
	tst.b	inter_coul
	beq	.rts
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	#0,inter_coul
	pea	intb_off
	move.w	#supexec,-(sp)
	trap	#xbios
	addq.l	#6,sp
	
	move.l	vbl_anc,-(sp)
	move.w	#vbl_vec,-(sp)
	move.w	#setexec,-(sp)
	trap	#bios
	addq.l	#8,sp
	
	move.l	key_anc,-(sp)
	move.w	#key_vec,-(sp)
	move.w	#setexec,-(sp)
	trap	#bios
	addq.l	#8,sp
	
	move.w  #5,-(sp)        ; reactive MPF 200 Hz
	move.w  #27,-(sp)
	trap    #xbios
	adda.l  #4,sp
	movem.l	(sp)+,d0-d7/a0-a6
.rts:	rts

	
intb_on:move.b	iera,intr1b		;stoque registres timer A et B
	move.b	imra,intr2b
	move.b	tbcr,intr3b
	move.b	tbdr,intr4b
	move.l	tbvec,intr5l
	clr.b	tbcr			;desactive Timer B
	bset	#0,iera			;permet interuption Timer B (bit 0=timer B)
	bset	#0,imra			;masque du timer B=1 :solicitation directe autorisee (pas de mise en attente)
	move.l	#timer_ir,tbvec		;place nouveau vecteur timer B
	rts
	
	
intb_off:
	bclr	#0,iera			;interdit inter Timer B
	move.b	intr2b,imra		;remet en place les registres MPF
	move.b	intr3b,tbcr
	move.b	intr4b,tbdr
	move.l	intr5l,tbvec
	move.b	intr1b,iera
	rts
	
	
timer_ir:			;Nouvelle routine Timer B
				; (executee toutes les 'lignes' lignes)
				;rem:bit 0 de isra est mis a 1 des que
				; l'interuption est generee
	movem.l	a0-a1,-(sp)	;PUSH a0 a1
	move.l	adrpal,a0	;pointeur de palette
	move.l	#palette,a1	;registre couleur
	move.l	(a0)+,(a1)+	;copie des 16 couleurs
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	add.l	#32,adrpal	;pointeur sur prochaine palette
	move.l	adrlar,a0
	move.b	(a0),tbdr
	add.l	#1,adrlar
	movem.l	(sp)+,a0-a1	;POP a0 a1
	
	bclr	#0,isra		;Interupt in service register:timer B libre
	subq.w	#1,cmptr	;decremente compteur de bandes
	bne	tim_end
	clr.b	tbcr		;stope timer B si=0
tim_end	rte

vbl_ir:
	clr.b	tbcr		;stop timer b
	move.l	#palinit,adrpal	;remet le pointeur de palettes sur la 1ere
	move.l	#larinit,adrlar	;largeur 1ere bande
	move.w	#1,cmptr		;init du compteur de bandes
	movem.l	a0-a1,-(sp)	;PUSH a0 a1
	move.l	adrpal,a0	;pointeur de palette
	move.l	#palette,a1	;registre couleur
	move.l	(a0)+,(a1)+	;copie des 16 couleurs
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0),(a1)
	add.l	#32,adrpal	;pointeur sur prochaine palette
	move.l	adrlar,a0	;init de la largeur des bandes
	move.b	(a0),tbdr
	add.l	#1,adrlar
	move.b	#%00001000,tbcr	;mode comptage d'evenement

	movem.l	(sp)+,a0-a1	;POP a0 a1
	
	move.l	vbl_anc,-(sp)	;appel routine vbl systeme
	rts


key_ir:				;nouvelle routine clavier
	move.w	sr,-(sp)	;copie sr dans pile
	andi.w	#$f8ff,(sp)	;niveau d'inter=0
	ori.w	#$0500,(sp)	;autorise interupt niveau 5,6,7 ,donc le MPF (niveau 6)
	move.w	(sp)+,sr	;met en place sr
	move.l	key_anc,-(sp)	;appel routine clavier systeme
	rts
	

        move.w  #5,-(sp)        ; reactive MPF 200 Hz
        move.w  #27,-(sp)
        trap    #xbios
        adda.l  #4,sp

        rts
        
cmptr:  dc.w    1
vbl_anc	ds.l	1
key_anc	ds.l	1
hbl_old ds.l    1
vbl_old ds.l    1
mpf_old	ds.l	1

intr1b	ds.b	1
intr2b	ds.b	1
intr3b	ds.b	1
intr4b	ds.b	1
intr5l	ds.l	1

inter_coul	dc.w	0
adrpal:	dc.l	0
adrlar:	dc.l	0

larinit	dc.b	57,60

palette_top:
palinit	dc.w	$000,$111,$111,$222,$333,$555,$666,$777
	dc.w	$007,$005,$004,$700,$700,$700,$700,$777
		
palette2:
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207
	dc.w	$210,$211,$212,$213,$214,$215,$216,$217


liste_palettes:
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207,$210,$211,$212,$213,$214,$215,$216,$217
	dc.w	$333,$001,$012,$123,$234,$345,$456,$567,$545,$623,$700,$741,$743,$732,$500,$776
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207,$210,$211,$212,$213,$214,$215,$216,$217
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207,$210,$211,$212,$213,$214,$215,$216,$217
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207,$210,$211,$212,$213,$214,$215,$216,$217
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207,$210,$211,$212,$213,$214,$215,$216,$217
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207,$210,$211,$212,$213,$214,$215,$216,$217
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207,$210,$211,$212,$213,$214,$215,$216,$217
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207,$210,$211,$212,$213,$214,$215,$216,$217
	dc.w	$002,$201,$202,$203,$204,$205,$206,$207,$210,$211,$212,$213,$214,$215,$216,$217


datamouse:
	dc.w	7,7,1,0,1
	dc.w	%0000000000000000
	dc.w	%0000000100000000
	dc.w	%0000001010000000
	dc.w	%0000010001000000
	dc.w	%0000010001000000
	dc.w	%0000010001000000
	dc.w	%0001110001110000
	dc.w	%0010000000001000
	dc.w	%0001110001110000
	dc.w	%0000010001000000
	dc.w	%0000010001000000
	dc.w	%0000010001000000
	dc.w	%0000001010000000
	dc.w	%0000000100000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000100000000
	dc.w	%0000001110000000
	dc.w	%0000001010000000
	dc.w	%0000001010000000
	dc.w	%0000001010000000
	dc.w	%0001111011110000
	dc.w	%0000001010000000
	dc.w	%0000001010000000
	dc.w	%0000001010000000
	dc.w	%0000001110000000
	dc.w	%0000000100000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

datamouse2:
	dc.w	0,0,1,0,1
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000

police:	incbin	"\includes\spritek1.spr"

	even
	ds.l	128
stack:	ds.l	10
	even

	include	"\includes\aeslib.s"


debut_ram:	equ	*
	*---------------- resevation memoire a la fin du programme -------------*
	
	end	

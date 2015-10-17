	******************************
	*      ~ BLASTERS MEN ~      *
	*        Version 1.6a        *
	*                            *
	*  (C)1993 TMS Developments  *
	******************************
	*      Coding : EPSILON      *
	*      Gfx    : EPSILON      *
	*      Music  : EPIC         *
	******************************
	* First release : 08.10.1993 *
	* Last changes  : 12.10.1993 *
	******************************

	include d:\falcon.lib
	output e:\blasters.men\blasters.prg

debug	equ 1	0=off/1=on
nb_vies	equ 9

	rsreset
crd_x	rs.w 1	crd x player
crd_y	rs.w 1	crd y player
crd_bx	rs.w 1	crd x bombe
crd_by	rs.w 1	crd y bombe
num_b	rs.w 1	num sprite bombe
flag_b	rs.b 1	flag si bombe posee
dead	rs.b 1	flag si player mort
vie	rs.w 1	nb vies player
score	rs.w 1	score player
ad_rout	rs.l 1	routine deplacements (joy/kbd)
lg_play	= __rs

	ifeq debug
	opt o+,w-,d-
	elseif
	opt o+,w-,x+
	endc

	jsr load_map
	bmi.s the_end
	supexec main
the_end	pterm

main	jsr tst_falcon	C'est un falcon ?
	jsr clr_bss		clear bss
	jsr save_all		save rez,scrn,...
	jsr init_all		init var,scrn,...
	jsr menu_ctrl
	cmp.l #$05050505,c_type
	beq exit
	move.l #vbl2,$70.w
restart	jsr init_var		init les variables
next_tab	loadpal null
	move.w level,d0
	addq.w #1,d0		tableau suivant
	cmp.w levels,d0	tout les lvls finis ?
	blt.s mains1
	moveq #0,d0		alors tableau 1
mains1	move.w d0,level
	jsr init_var2		init flag perso.
	jsr init_map
	jsr aff_carte
	jsr copy_scrn		copy scrn1->scrn2
	jsr aff_perso
	jsr swap_screen
	jsr aff_perso
	jsr aff_bando
	loadpal decors+2
loop	jsr wait_vbl
	jsr wait_vbl
	jsr swap_screen	
	ifne debug
	eor.w #$004,$ffff8240.w
	endc
	jsr eff_boum		eff explosions
	jsr eff_perso		eff persos
	jsr eff_bomb		eff bombes
	jsr gere_dead		gere les tempos dead
	jsr tst_key		converti key->joy
	jsr move_perso	depl persos
	jsr gere_bomb		anim bombes
	jsr gere_boum		anim explosions
	jsr tst_col		tst col explo/perso
	jsr aff_bando		aff vies & scores
	jsr aff_bomb		aff spr bombes
	jsr aff_perso		aff spr persos
	jsr aff_boum		aff spr explosions
	ifne debug
	move.w #$000,$ffff8240.w
	endc
	tst.b flag_exit	ce tableau est fini ?
	bmi restart		non tous morts !
	bne next_tab		oui tableau suivant.
	cmp.b #$4e,pt_key	touche "+"
	beq next_tab		tableau suivant.
	cmp.b #$01,pt_key	touche ESC
	bne loop		non continu.
exit	jsr restore_all
	rts

	include e:\blasters.men\sources\routines\init_var.s
	include e:\blasters.men\sources\routines\init_its.s
	include e:\blasters.men\sources\routines\keyboard.s
	include e:\blasters.men\sources\routines\aff_map.s
	include e:\blasters.men\sources\routines\g_perso.s
	include e:\blasters.men\sources\routines\g_boum.s
	include e:\blasters.men\sources\routines\g_bomb.s
	include e:\blasters.men\sources\routines\g_dead.s
	include e:\blasters.men\sources\routines\i_boum.s
	include e:\blasters.men\sources\routines\tst_col.s
	include e:\blasters.men\sources\routines\aff_spr.s
	include e:\blasters.men\sources\routines\eff_spr.s
	include e:\blasters.men\sources\routines\af_bando.s
	include e:\blasters.men\sources\routines\aff_txt.s
	include e:\blasters.men\sources\routines\dec_asc.s
	include e:\blasters.men\sources\routines\divers.s
	include d:\sources\divers\tst_f030.s
	include d:\sources\acc_disk\load_fic.s
	include e:\blasters.men\sources\routines\menu2.s

	section data

	ifeq debug
nom_map	dc.b "all_lvl.map",0
nom_atb	dc.b "all_lvl.atb",0
	elseif
nom_map	dc.b "e:\blasters.men\all_lvl.map",0
nom_atb	dc.b "e:\blasters.men\all_lvl.atb",0
	endc

tno_map	dc.b $1b,"EEh ! Where is my ""all_lvl.map"" file ?",0
tno_atb	dc.b $1b,"EEh ! Where is my ""all_lvl.atb"" file ?",0

	*     0000000001111111111222222222233333333334
	*     1234567890123456789012345678901234567890
tbando	dc.b "1;0 0000  2;0 0000  3;0 0000  4;0 0000",0

	even

decors	incbin e:\blasters.men\levels.map\decors.pse
mecs	incbin e:\blasters.men\files\mecs.spr
bombes	incbin e:\blasters.men\files\bombes.spr
boum	incbin e:\blasters.men\files\boum.spr
rip	incbin e:\blasters.men\files\r_i_p.spr

musik	incbin e:\epic.zik\epic_015.zik

fonte	incbin e:\blasters.men\files\fontes_7.fnt
	even

	section bss

debut_bss	equ *

old_pal	ds.b 32
old_fpal	ds.l 256
old_rez	ds.w 1
old_mode	ds.w 1
old_phys	ds.l 1
old_vbl	ds.l 1
old_118	ds.l 1

screen1	ds.l 1
screen2	ds.l 1
ad_bpers1	ds.l 1
ad_bpers2	ds.l 1
ad_bbomb1	ds.l 1
ad_bbomb2	ds.l 1
ad_bboum1	ds.l 1
ad_bboum2	ds.l 1

back_p1	ds.l 4
back_p2	ds.l 4

back_b1	ds.l 4
back_b2	ds.l 4

back_e1	ds.w 1
	ds.l 4*13

back_e2	ds.w 1
	ds.l 4*13

tmp_boum	ds.l 4*14

pt_vbl	ds.b 1
pt_key	ds.b 1
pt_key2	ds.b 1
pt_joy0	ds.b 1
pt_joy1	ds.b 1
pt_joy2	ds.b 1
pt_joy3	ds.b 1
pt_joy4	ds.b 1
pt_null	ds.b 1
flag_exit	ds.b 1
	even

level	ds.w 1
ad_map	ds.l 1
ad_atb	ds.l 1

tmp_atb	ds.b 240

players	ds.b lg_play*4

nb_blk	ds.w 1

null	ds.w 16

	ds.b 256
ecran	ds.b 64000

end_bss	ds.l 2

levels	ds.b 2+(100*488)

attrib	ds.b 100*240

	end
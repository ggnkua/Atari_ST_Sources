	******************************
	* Fullscreen integrator V2.2 *
	*   (c) 1992 EPSILON & TMS   *
	******************************

OBJ_DO_IT	equ 4
OBJ_EXIT	equ 3
OBJ_ANFULL	equ 8
OBJ_NB_LINES	equ 7
TED_NB_LINES	equ 1
OBJ_B_INFILE	equ 5
OBJ_S_NBLINE	equ 28
TED_S_NBLINE	equ 14
OBJ_S_INTIME	equ 30
TED_S_INTIME	equ 15
OBJ_S_OSIZE	equ 32
TED_S_OSIZE	equ 16
OBJ_S_INSIZE	equ 35
TED_S_INSIZE	equ 18
OBJ_S_NBLSPR	equ 37
TED_S_NBLSPR	equ 19
OBJ_SPRITES	equ 9
OBJ_B_INFO	equ 1
TED_B_INFO	equ 0
OBJ_B_SAVE	equ 13
OBJ_B_MENU	equ 14
OBJ_B_YES	equ 5
OBJ_B_NO	equ 6
OBJ_TXT_PC	equ 49
OBJ_TXT_NAME	equ 54

	include d:\util.lib

	start
	move.b $37(a5),d0
	add.b #"A",d0
	move.b d0,path_select
	
	jsr rsrc_free
	jsr load_rsc
	bne retour
	jsr init_rsc
	jsr init_mouse
	jsr main
retour	jsr free_mem2
	jsr free_mem3
	pterm

main	move.l menu_box,addr_out2
	jsr draw_tree
mains2	jsr form_do
	move.w d0,option

	cmp.w #obj_anfull,d0
	bne.s mains4
	eor.b #1,flag_anfull
	jsr load_full
	bra.s mains2

mains4	cmp.w #obj_sprites,d0	option sprites
	bne.s mains5
	eor.b #1,flag_sprites
	jsr chg_spr
	bra.s mains2

mains5	move.w d0,obj_num
	move.w #$00,obj_cmd
	move.w #$00,obj_attrib
	jsr objc_change
	jsr undraw_tree
	move.w option,d0
	cmp.w #obj_b_info,d0	option info
	beq aff_info
	cmp.w #obj_do_it,d0	option do it !
	beq do_it
	cmp.w #obj_b_infile,d0	option info file
	beq aff_infof
	cmp.w #obj_exit,d0	option exit
	bne main
	
quit_prg	cmp.l #retour,(sp)
	beq.s quit_prgs1
	addq.l #2,sp
	bra.s quit_prg
quit_prgs1	rts

aff_info	move.l info_box,addr_out2
	jsr draw_tree
	jsr form_do
	move.w d0,obj_num
	move.w #$00,obj_cmd
	move.w #$00,obj_attrib
	jsr objc_change
	jsr undraw_tree
	jmp main
	
do_it	
	move.l menu_box,a0
	add.w #obj_b_infile*24+10,a0	option info file OFF
	move.w #8,(a0)
	jsr load
	bpl.s do_its1
do_its99	jmp main
do_its1	jsr get_lgnspr
	lea full,a0
	tst.b flag_anfull
	beq.s do_its2
	move.l ad_frout,a0
do_its2	move.l a0,pt_full
	move.l work_box,addr_out2
	jsr draw_tree
	supexec incrust
	jsr undraw_tree
	tst.w flag_error
	beq.s do_its3
	move.l pc_error,d0
	move.l ad_pc_ilg,a0
	moveq #5,d1
	jsr decascs1
	move.l badins_box,addr_out2
	jsr draw_tree
	jsr form_do
	move.w d0,obj_num
	move.w #$00,obj_cmd
	move.w #$00,obj_attrib
	jsr objc_change
	jsr undraw_tree
	jmp do_its99
do_its3	move.l ad_time,a0
	move.l temps,d0
	divu #50,d0
	and.l #$ffff,d0
	moveq #1,d1
	jsr decascs1
	move.l temps,d0
	divu #50,d0
	swap d0
	and.l #$ffff,d0
	move.l ad_time,a0
	addq.w #3,a0
	moveq #1,d1
	jsr decascs1
	moveq #0,d0
	move.w cpt_lgn,d0
	tst.b flag_sprites
	beq.s prints4
	move.b flag_pass+1,d0
	mulu #16,d0
prints4	move.l ad_fline,a0
	moveq #2,d1
	jsr decascs1
	moveq #0,d0
	move.b flag_pass+1,d0
	move.l ad_lspr,a0
	moveq #2,d1
	jsr decascs1
	move.l lg_file,d0
	move.l ad_osize,a0
	moveq #5,d1
	jsr decascs1
	move.l ad_insize,a0
	move.l lg_full,d0
	moveq #5,d1
	jsr decascs1
	move.l menu_box,a0
	add.w #obj_b_infile*24+10,a0	option info file ON
	move.w #0,(a0)
	jmp aff_infof

vbl	addq.l #1,temps
	rte

incrust	move.w #$2700,sr
	move.l $70.w,old_vbl
	move.l #vbl,$70.w
	clr.w cpt_lgn
	clr.l temps
	move.w $ffff8240.w,old_coul
	move.w #$2300,sr
	clr.w flag_pass
	clr.w flag_error
	tst.b flag_sprites
	beq.s inc_s1
	move.b #1,flag_pass
	jsr incrusteur
	clr.w cpt_lgn
	addq.b #1,flag_pass
	move.w nb_lgnspr,d0
	beq.s inc_s1
	cmp.b flag_pass+1,d0
	ble.s inc_s1
	move.b d0,flag_pass+1
inc_s1	jsr incrusteur
	move.w #$2700,sr
	move.w old_coul,$ffff8240.w
	move.l old_vbl,$70.w
	rts

incrusteur	lea tab_full,a0
	lea end_full,a1
	move.l ad_file,a2
	move.l ad_full,a3
	move.l ad_full,a5
	move.l a2,a4
	add.l lg_file,a4
	moveq #0,d5
	tst.b flag_sprites
	beq.s incrusts0
	addq.w #1,d5
	move.l (a2),(a5)+
	lea 16*4(a2),a2
	lea 16*4(a3),a3
incrusts0	cmp.w #-1,(a1)
	bne.s incrusts1
	move.l pt_full,a1
	addq.w #1,cpt_lgn
incrusts1	cmp.l #"NOP=",(a1)
	beq.s incrusts2
	move.w (a1)+,(a3)+
	eor.w #$007,$ffff8240.w
	bra.s incrusts0
incrusts2	moveq #0,d7
	move.w 4(a1),d7	nb de nops dispo.
	addq.w #6,a1
incrusts11	moveq #0,d0
	moveq #0,d1
	move.w (a2),d0
	jsr tst_rot
	bmi error
	cmp.w #$4e75,d0	rts
	bne incrusts12

	lea incrusts17,a6
	tst.w d7
	bne.s incrusts13
	lea incrusts7,a6
incrusts13	jsr (a6)

incrusts20	subq.l #4*2,a3
	cmp.w #$4e71,(a3)
	beq.s incrusts18
incrusts21	addq.l #4*2,a3
	move.l pt_full,a1
	moveq #0,d7
	jsr incrusts7
	bra.s incrusts20
incrusts18	cmp.b #2,flag_pass
	bne.s incrusts22
	moveq #0,d7
	move.w cpt_lgn,d7
	cmp.b flag_pass+1,d7
	blt.s incrusts21
	clr.w cpt_lgn
incrusts22	move.w (a2)+,(a3)+
	cmp.b #1,flag_pass
	bne.s incrusts26
	moveq #0,d6
	moveq #0,d7
	move.b flag_pass+1,d6
	move.w cpt_lgn,d7
	cmp.w d6,d7
	ble.s incrusts23
	move.b d7,flag_pass+1
incrusts23	clr.w cpt_lgn
incrusts26	tst.b flag_sprites
	beq.s incrusts16
	cmp.w #16,d5
	beq.s incrusts16
	addq.w #1,d5
	move.l a3,d7
	sub.l ad_full,d7
	move.l d7,(a5)+
incrusts16	lea end_full,a1
	moveq #0,d7
	bra.s incrusts14

incrusts12	jsr tst_movem
	bmi.s incrusts24
	bne.s incrusts25
	move.b (a0,d0.l),d1
incrusts24	beq error
	cmp.b #$ff,d1
	beq error
incrusts25	move.w d1,d2
	and.w #%00001111,d1	nb de mots
	lsr.w #4,d2		nb de nops=inst
	cmp.w d2,d7		d2>d7 ?
	bge.s incrusts4	oui -> suite1
	tst.w d7
	bmi incrusts0
	beq incrusts0
	subq.w #1,d7
incrusts3	move.w #$4e71,(a3)+
	eor.w #$007,$ffff8240.w
	dbra d7,incrusts3
	moveq #0,d7
	bra incrusts0
incrusts4	subq.w #1,d1
incrusts5	move.w (a2)+,(a3)+
	eor.w #$007,$ffff8240.w
	dbra d1,incrusts5
	sub.w d2,d7
incrusts14	cmp.l a4,a2
	blt incrusts11
	cmp.w #$4e75,-2(a3)
	beq.s incrusts10
	cmp.w #-1,(a1)
	beq.s incrusts10
	lea incrusts17,a6
	tst.w d7
	bne.s incrusts10_2
	lea incrusts7,a6
incrusts10_2	jsr (a6)
incrusts10	sub.l ad_full,a3
	move.l a3,lg_full
	moveq #0,d7
	bra errors1

incrusts7	cmp.w #-1,(a1)
	beq.s incrusts9_2
	cmp.l pt_full,a1
	bne.s incrusts19
	addq.w #1,cpt_lgn
incrusts19	cmp.l #"NOP=",(a1)
	bne.s incrusts9
	moveq #0,d7
	move.w 4(a1),d7
	addq.w #6,a1
incrusts17	subq.w #1,d7
incrusts8	move.w #$4e71,(a3)+
	eor.w #$007,$ffff8240.w
	dbra d7,incrusts8
	moveq #0,d7
	bra.s incrusts7
incrusts9	move.w (a1)+,(a3)+
	eor.w #$007,$ffff8240.w
	bra.s incrusts7
incrusts9_2	rts

tst_rot	movem.l d3-a6,-(sp)
	moveq #-1,d2
	move.w d0,d1
	and.w #%1111000000111000,d1
	cmp.w #%1110000000100000,d1		ASx Dn,Dn
	beq.s tst_rots1
	cmp.w #%1110000000101000,d1		LSx Dn,Dn
	beq.s tst_rots1
	cmp.w #%1110000000011000,d1		ROx Dn,Dn
	beq.s tst_rots1
	cmp.w #%1110000000010000,d1		ROXx Dn,Dn
	beq.s tst_rots1
	moveq #0,d2
tst_rots1	movem.l (sp)+,d3-a6
	moveq #0,d1
	tst.w d2
	rts

tst_movem	movem.l d2-a6,-(sp)
	moveq #0,d1
	move.w d0,d2
	and.w #%1111101110000000,d2
	cmp.w #%0100100010000000,d2
	bne.s not_mm
	move.w d0,d2
	moveq #0,d3
	btst #6,d2	movem.W ?
	beq.s calc_mms1
	moveq #1,d3	movem.L !
calc_mms1	lea tab_mm1,a0
	btst #10,d2
	beq.s calc_mms2
	lea tab_mm2,a0
calc_mms2	move.w d0,d2
	and.w #%0000000000111111,d2
	move.b (a0,d2.w),d1
	ext.w d1
	move.w 2(a2),d2
	moveq #0,d4
	moveq #15,d5
calc_mms3	btst d5,d2
	beq.s calc_mms4
	addq.w #1,d4
calc_mms4	dbra d5,calc_mms3
	lsl.w d3,d4
	lsl.w #4,d4
	add.w d4,d1
not_mm	movem.l (sp)+,d2-a6
	tst.w d1
	rts

error	moveq #-1,d7
	sub.l ad_file,a2
	move.l a2,pc_error
errors1	move.w d7,flag_error
	rts

aff_infof	move.l infof_box,addr_out2
	jsr draw_tree
	jsr form_do
	move.w d0,option
	move.w d0,obj_num
	move.w #$00,obj_cmd
	move.w #$00,obj_attrib
	jsr objc_change
	jsr undraw_tree
	cmp.w #obj_b_save,option	option save
	bne.s aff_infofs1
	jsr save
aff_infofs1	jmp main
	
chg_spr	move.w #obj_nb_lines,obj_num
	move.w #1,obj_cmd
	move.w #0,obj_attrib
	moveq #8,d7
	tst.b flag_sprites
	bne.s chg_sprs1
	moveq #0,d7
	move.w #8,obj_attrib
chg_sprs1	move.l menu_box,a0
	add.w #obj_nb_lines*24+8,a0
	move.w d7,(a0)
	jsr objc_change
	move.w #obj_sprites,obj_num
	move.w #1,obj_cmd
	moveq #0,d7
	move.b flag_sprites,d7
	move.w d7,obj_attrib
	jsr objc_change
	move.w #0,int_in
	rts

load_full	tst.b flag_anfull
	beq load_fulls1
	jsr undraw_tree
	jsr file_select
	tst.w d0
	beq ldf_s98
	jsr get_name
	jsr test_file
	bne.s ldf_s97
	jsr free_mem3
	move.l long_file,d0
	jsr get_memory
	bmi.s ldf_s96
	move.l d0,ad_file
	jsr load_file
	bra.s ldf_s99
ldf_s96	move.l #no_memory,addr_in
	move.w #01,int_in
	jsr form_alert
	bra.s ldf_s98
ldf_s97	move.l #no_file,addr_in
	move.w #01,int_in
	jsr form_alert
ldf_s98	sf.b flag_anfull
	jsr free_mem3
ldf_s99	move.l menu_box,addr_out2
	jsr draw_tree
load_fulls1	move.w #obj_anfull,obj_num
	move.w #1,obj_cmd
	moveq #0,d7
	move.b flag_anfull,d7
	move.w d7,obj_attrib
	jsr objc_change
	move.w #0,int_in
	rts

get_lgnspr	move.l ad_nblspr,a0
	moveq #0,d0
	moveq #0,d1
	moveq #2,d2
get_ls2	move.b (a0)+,d1
	beq.s get_ls1
	cmp.b #"_",d1
	beq.s get_ls1
	mulu #10,d0
	sub.b #"0",d1
	add.w d1,d0
get_ls1	dbra d2,get_ls2
	move.w d0,nb_lgnspr
	rts

load	jsr free_mem2
	jsr file_select
	tst.w d0
	beq loads98
	jsr get_name
	jsr test_file
	bne.s loads97
	move.l long_file,d0
	move.l d0,d7
	jsr get_memory
	bmi.s loads96
	move.l d0,ad_file
	lsl.l #1,d0
	jsr get_memory
	bmi.s loads96
	move.l d0,ad_full
	jsr load_file
	move.l long_file,d0
	btst #0,d0
	beq.s loads1
	subq.l #1,d0
loads1	move.l d0,lg_file
	moveq #0,d7
	bra.s loads99
loads97	move.l #no_file,addr_in
	move.w #01,int_in
	jsr form_alert
	bra.s loads98
loads96	move.l #no_memory,addr_in
	move.w #01,int_in
	jsr form_alert
loads98	jsr free_mem2
	moveq #-1,d7
loads99	tst.w d7
	rts

save	jsr file_select
	tst.w d0
	beq saves99
	jsr get_name
	jsr test_file
	bne.s saves98
	move.l ad_namef,a0
	lea name_select,a1
	moveq #11,d0
saves1	move.b (a1)+,d1
	beq.s saves3
	move.b d1,(a0)+
	dbra d0,saves1
	bra.s saves2
saves3	move.b #" ",(a0)+
	dbra d0,saves3
saves2	move.l overw_box,addr_out2
	jsr draw_tree
	jsr form_do
	move.w d0,option
	move.w d0,obj_num
	move.w #$00,obj_cmd
	move.w #$00,obj_attrib
	jsr objc_change
	jsr undraw_tree
	cmp.w #obj_b_no,option
	beq save
saves98	jsr save_file
saves99	rts

get_name	lea path_select,a0
	lea name_file,a1
get_names1	move.b (a0)+,d0
	beq.s get_names2
	move.b d0,(a1)+
	bra.s get_names1
get_names2	moveq #54,d0
	move.l a1,a2
get_names3	move.b -(a1),d1
	cmp.b #"\",d1
	beq.s get_names4
	dbra d0,get_names3
	move.l a2,a1
get_names4	move.b #"\",(a1)+
	lea name_select,a0
	moveq #11,d0
get_names5	tst.b (a0)
	bne.s get_names6
	clr.b (a1)+
	lea char_space,a0
get_names6	move.b (a0)+,(a1)+
	dbra d0,get_names5
	rts
	
char_space	dcb.b 12," "
	
dec_asc	moveq #2,d1
decascs1	move.b #"0",(a0)+
	dbra d1,decascs1
	tst.l d0
	beq.s decascs2
div	moveq #0,d3
	moveq #10,d1
	divu d1,d0
	bvc.s result
	move.l d0,d2
	clr d0
	swap d0
	divu d1,d0
	move d0,d3
	move d2,d0
	divu d1,d0
result	move.l d0,d1
	swap d1
	swap d0
	move d3,d0
	swap d0
	add #"0",d1
	move.b d1,-(a0)
	tst.l d0
	bne.s div
decascs2	rts

get_memory	move.l d0,-(sp)
	move.w #$48,-(sp)
	trap #1
	addq.l #6,sp
	tst.l d0
	rts
	
free_memory	move.l d0,-(sp)
	move.w #$49,-(sp)
	trap #1
	addq.l #6,sp
	rts

free_mem2	move.l ad_file,d0
	beq.s free_mem2s1
	jsr free_memory
free_mem2s1	move.l ad_full,d0
	beq.s free_mem2s2
	jsr free_memory
free_mem2s2	clr.l ad_file
	clr.l ad_full
	rts

free_mem3	move.l ad_frout,d0
	beq.s free_mem3s1
	jsr free_memory
free_mem3s1	clr.l ad_frout
	rts
	
test_file	pea dta
	move.w #$1a,-(sp)
	trap #1
	addq.l #6,sp
	clr.w -(sp)
	pea name_file
	move.w #$4e,-(sp)
	trap #1
	addq.l #8,sp
	move.l dta+26,long_file
	tst.w d0
	rts
	
load_file	move.l load_box,addr_out2
	jsr draw_tree
	clr.w -(sp)
	pea name_file
	move.w #$3d,-(sp)
	trap #1
	add.l #8,sp
	move.w d0,d7
	move.l ad_file,-(sp)
	move.l long_file,-(sp)
	move.w d7,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	move.l d0,d6
	move.w d7,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	jsr undraw_tree
	tst.l d6
	rts
	
save_file	move.l save_box,addr_out2
	jsr draw_tree
	jsr save_files5
	jsr undraw_tree
	rts
	
save_files5	clr.w -(sp)
	pea name_file
	move.w #$3c,-(sp)
	trap #1
	add.l #8,sp
	move.w d0,d7
	move.w d0,d6
	ext.l d6
	bmi.s save_files6
	move.l ad_full,-(sp)
	move.l lg_full,-(sp)
	move.w d7,-(sp)
	move.w #$40,-(sp)
	trap #1
	lea 12(sp),sp
	move.l d0,d6
	move.w d7,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
save_files6	rts
		
init_rsc	moveq #7,d6
	moveq #0,d7
	lea menu_box,a5
init_rscs1	move.w #0,int_in
	move.w d7,int_in+2
	jsr rsrc_gaddr
	move.l addr_out2,(a5)+
	addq.w #1,d7
	dbra d6,init_rscs1
	move.w #2,int_in
	move.w #ted_s_intime,int_in+2
	jsr rsrc_gaddr
	move.l addr_out2,a0
	move.l 4(a0),a0
	lea 14(a0),a0
	move.l a0,(a5)+	adr txt time
	move.w #2,int_in
	move.w #ted_s_nbline,int_in+2
	jsr rsrc_gaddr
	move.l addr_out2,a0
	move.l 4(a0),a0
	lea 14(a0),a0
	move.l a0,(a5)+	adr nb fullines
	move.w #2,int_in
	move.w #ted_s_nblspr,int_in+2
	jsr rsrc_gaddr
	move.l addr_out2,a0
	move.l 4(a0),a0
	move.l a0,(a5)+	adr nb lgn/spr
	move.w #2,int_in
	move.w #ted_s_osize,int_in+2
	jsr rsrc_gaddr
	move.l addr_out2,a0
	move.l 4(a0),a0
	lea 22(a0),a0
	move.l a0,(a5)+	adr txt osize
	move.w #2,int_in
	move.w #ted_s_insize,int_in+2
	jsr rsrc_gaddr
	move.l addr_out2,a0
	move.l 4(a0),a0
	lea 22(a0),a0
	move.l a0,(a5)+	adr txt insize
	move.l menu_box,a0
	add.w #obj_nb_lines*24+8,a0	adr txt nb lgn/spr
	move.w #0,(a0)
	move.l 4(a0),a0
	move.l (a0),a0
	clr.b (a0)
	clr.b 1(a0)
	clr.b 2(a0)
	move.l a0,(a5)+
	move.l menu_box,a0
	add.w #obj_txt_pc*24+12,a0	adr txt ilg inst
	move.l (a0),a0
	move.l (a0),a0
	lea 5(a0),a0
	move.l a0,(a5)+
	move.l menu_box,a0
	add.w #obj_txt_name*24+12,a0	adr txt ilg inst
	move.l (a0),a0
	move.l a0,(a5)+
	move.l menu_box,a0
	add.w #obj_b_infile*24+10,a0
	move.w #8,(a0)
	rts
	
init_mouse	move.w #$00,int_in
	jmp graf_mouse
	
call_aes	move.l #params,d1
	move.w #$c8,d0
	trap #2
	move.w int_out,d0
	rts

file_select	move.l #sel_params,d1
	move.w #$c8,d0
	trap #2
	move.w sel_int_out+2,d0
	tst.w d0
	rts

draw_tree	jsr form_center
	move.w #$00,int_in
	jsr form_dial
	move.w #$01,int_in
	jsr form_dial
	jsr objc_draw
	rts

undraw_tree	move.w #$03,int_in
	jsr form_dial
	move.w #$02,int_in
	jmp form_dial

graf_mouse	move.w #$4e,control
	move.w #$01,control+2
	move.w #$01,control+4
	move.w #$01,control+6
	move.w #$00,control+8
	jmp call_aes
	
rsrc_gaddr	move.w #$70,control
	move.w #$02,control+2
	move.w #$01,control+4
	move.w #$00,control+6
	move.w #$01,control+8
	jsr call_aes
	move.l addr_out,addr_out2
	rts
	
rsrc_free	move.w #$6f,control
	move.w #$00,control+2
	move.w #$01,control+4
	move.w #$00,control+6
	move.w #$00,control+8
	jmp call_aes
	
load_rsc	move.l #rsc_name,addr_in
	move.w #$6e,control
	move.w #$00,control+2
	move.w #$01,control+4
	move.w #$01,control+6
	move.w #$00,control+8
	jsr call_aes
	tst.w d0
	beq.s load_rscs1
	moveq #0,d0
load_rscs2	tst.w d0
	rts

load_rscs1	move.l #rsc_lose,addr_in
	move.w #01,int_in
	jsr form_alert
	moveq #-1,d0
	bra.s load_rscs2
	
form_alert	move.w #$34,control
	move.w #$01,control+2
	move.w #$01,control+4
	move.w #$01,control+6
	move.w #$00,control+8
	jmp call_aes
	
form_center	move.l addr_out2,addr_in
	move.w #$36,control
	move.w #$00,control+2
	move.w #$05,control+4
	move.w #$01,control+6
	move.w #$00,control+8
	jsr call_aes
	move.w int_out+2,int_out2+2
	move.w int_out+4,int_out2+4
	move.w int_out+6,int_out2+6
	move.w int_out+8,int_out2+8
	rts
	
form_dial	move.w #$00,int_in+2
	move.w #$00,int_in+4
	move.w #$00,int_in+6
	move.w #$00,int_in+8
	move.w int_out2+2,int_in+10
	move.w int_out2+4,int_in+12
	move.w int_out2+6,int_in+14
	move.w int_out2+8,int_in+16
	move.w #$33,control
	move.w #$09,control+2
	move.w #$01,control+4
	move.w #$00,control+6
	move.w #$00,control+8
	jmp call_aes
	
form_do	move.l addr_out2,addr_in
	move.w #$32,control
	move.w #$01,control+2
	move.w #$01,control+4
	move.w #$01,control+6
	move.w #$00,control+8
	jmp call_aes

objc_draw	move.w #$00,int_in
	move.w #$0a,int_in+2
	move.w int_out2+2,int_in+4
	move.w int_out2+4,int_in+6
	move.w int_out2+6,int_in+8
	move.w int_out2+8,int_in+10
	move.l addr_out2,addr_in
	move.w #$2a,control
	move.w #$06,control+2
	move.w #$01,control+4
	move.w #$01,control+6
	move.w #$00,control+8
	jmp call_aes
	
objc_change	move.w obj_num,int_in
	move.w #$00,int_in+2
	move.w int_out2+2,int_in+4
	move.w int_out2+4,int_in+6
	move.w int_out2+6,int_in+8
	move.w int_out2+8,int_in+10
	move.w obj_attrib,int_in+12
	move.w obj_cmd,int_in+14
	move.l addr_out2,addr_in
	move.w #$2f,control
	move.w #$08,control+2
	move.w #$01,control+4
	move.w #$01,control+6
	move.w #$00,control+8
	jmp call_aes
	
	section data
	
full	move.w a1,(a1)
	dc.l "NOP="
	dc.w 1
	move.b d0,(a1)
	dc.l "NOP="
	dc.w 89
	move.b d0,(a0)
	move.w a1,(a0)
	dc.l "NOP="
	dc.w 13
	move.w a1,(a1)
	dc.l "NOP="
	dc.w 1
	move.b d0,(a1)
	dc.l "NOP="
	dc.w 12
end_full	dc.w -1

tab_full	incbin d:\sources\integrat.ful\inc_tab.dat

tab_mm1	dcb.b 8,$ff	table R -> M
	dcb.b 8,$ff
	dcb.b 8,$32
	dcb.b 8,$ff
	dcb.b 8,$22
	dcb.b 8,$33
	dcb.b 8,$43
	dc.b $33,$44,$ff,$ff,$ff

tab_mm2	dcb.b 8,$ff	table M -> R
	dcb.b 8,$ff
	dcb.b 8,$32
	dcb.b 8,$32
	dcb.b 8,$ff
	dcb.b 8,$43
	dcb.b 8,$53
	dc.b $43,$54,$ff,$ff,$ff

rsc_lose	dc.b "[3][ | Can't find |     INCRUST.RSC !!!! ][ Abort ]",0
	even
no_file	dc.b "[1][ | Can't find | this file ! ][ Abort ]",0
	even
no_memory	dc.b "[3][ | Not enough memory ][ Abort ]",0
	even

rsc_name	dc.b "incrust.rsc",0
	even

path_select	dc.b "C:\*.*"
	ds.w 25
name_select	dc.b "FILENAME."
extd_select	dc.b "EXT",0
	even
	
sel_control	dc.w $5a,0,2,2,0
sel_global	ds.w 14
sel_int_in	ds.w 16
sel_int_out	ds.w 7
sel_addr_in	dc.l path_select
	dc.l name_select
	dc.l 0
sel_addr_out	dc.l 0

sel_params	dc.l sel_control
	dc.l sel_global
	dc.l sel_int_in
	dc.l sel_int_out
	dc.l sel_addr_in
	dc.l sel_addr_out
	
params	dc.l control
	dc.l global
	dc.l int_in
	dc.l int_out
	dc.l addr_in
	dc.l addr_out
	
	section bss

name_file	ds.w 28

dta	ds.b 44
	
flag_anfull	ds.b 1
flag_sprites	ds.b 1
flag_error	ds.w 1

old_vbl	ds.l 1
old_coul	ds.w 1

option	ds.w 1
obj_num	ds.w 1
obj_cmd	ds.w 1
obj_attrib	ds.w 1
	
menu_box	ds.l 1
info_box	ds.l 1
infof_box	ds.l 1
load_box	ds.l 1
save_box	ds.l 1
work_box	ds.l 1
badins_box	ds.l 1
overw_box	ds.l 1
ad_time	ds.l 1
ad_fline	ds.l 1
ad_lspr	ds.l 1
ad_osize	ds.l 1
ad_insize	ds.l 1
ad_nblspr	ds.l 1
ad_pc_ilg	ds.l 1
ad_namef	ds.l 1

long_file	ds.l 1
addr_file	ds.l 1

temps	ds.l 1
lg_file	ds.l 1
lg_full	ds.l 1
cpt_lgn	ds.w 1
flag_pass	ds.w 1
nb_lgnspr	ds.w 1
pt_full	ds.l 1

ad_file	ds.l 1
ad_full	ds.l 1
pc_error	ds.l 1
ad_frout	ds.l 1

control	ds.w 5
global	ds.w 14
int_in	ds.w 16
int_out	ds.w 7
addr_in	ds.l 3
addr_out	ds.l 1
int_out2	ds.w 7
addr_out2	ds.l 1

	end

MOD_BOX=0
MOD_BOX2=1
MOD_HEXA=0
MOD_DECI=1
MOD_WIND=0
MOD_MENU=1
MOD_ACC=0

WHO=0	; 0=wax, 1=gen, 2=roro

	ifeq WHO
	incdir d:\assemble\asources.wax\direct2d
	endc
	ifeq (WHO-1)
	incdir d:\assemble\sources.wax\direct2d
	endc
	ifeq (WHO-2)
	incdir d:\devpac\source\genuwax\direct2d
	endc

	include guw_mac3.s
	include direct2d.hs
	ifeq MOD_ACC
	ifeq WHO
	output d:\assemble\asources.wax\direct2d\wax2play.prg
	endc
	ifeq (WHO-1)
	output d:\assemble\sources.wax\direct2d\wax2play.prg
	endc
	ifeq (WHO-2)
	output d:\devpac\source\genuwax\direct2d\wax2play.prg
	endc
	else
	output c:\wax2play.acc
	endc

	; Direct to disk en lecture
	; NB buf variable, rattrape le retard, et d‚compression incluse
	; module externe utilisable par n'importe quel programme.
	; Passage de paramŠtres .TTP, et messages applications GEM.
	; 24 VII 93 / 27 VII 93 / 30 VII 93 / 07 VIII 93 / 16 VIII 93  / 30 VIII 93 / 25-IX-93
	; 18/II/94, 25/II/94, 02/IV/94, 04/IV/94, 15/IV/94, 23/IV 24/IV, 27/IV
	; 30/IV 29/V 30/V 1/VI 18/VI 24/VII
	; Gem version : 23/II/1994.

	section TEXT

debut:	init_prg 1024,#name_rsc

	shel_write #9,#1,#0,#0,#0

	clr sample_playing
	clr.l are_there_more
	clr.l play_list_ptr
	clr which_clock		; interne

	move.l #dec0,charge_octets	; routine par d‚faut

	tst acc_app
	bne.s .not_acc
	menu_register global+4,#string_acc	; C 1 ACC
	move d0,acc_number
	bmi fin

	bra boucle_gem_principale

.not_acc:	move #METHOD_1,d0		; C 1 PRG
	move d0,previous_check2
	moveq #1,d1
	bsr check_menu

	move #FREQUENCY_0,d0		; interne
	moveq #1,d1
	bsr check_menu

*	move #FREQUENCY_9,d0
*	move #0,d1
*	bsr grey_menu	

	tst copro
	bne.s .is_copro
	move #SPECIAL,d0
	move #0,d1
	bsr grey_menu	
.is_copro:

	move.b #freq8,frequency_for_play
	move #FREQUENCY_1,d0
	move d0,previous_check1
	moveq #1,d1
	bsr check_menu

*	move #1,loop
*	move #FILES_LOOP,d0
*	moveq #1,d1
*	bsr check_menu

	lea original_table_dvswax,a0
	lea table_dvswax,a1
	move #256-1,d0
.default:	move.w (a0)+,(a1)+
	dbf d0,.default

	save a5
	bsr show_menu
	load a5

	clr d0
	move.b $80(a5),d0
	beq.s boucle_gem_principale
	subq #1,d0
	lea $81(a5),a0
	lea name_2_load,a1
copy_name:	move.b (a0)+,(a1)+
	dbf d0,copy_name

	bra load_file2

boucle_gem_principale:
	clr d0
	tst acc_app
	beq.s .its_acc
	bset #EVNT_KEYBD,d0
.its_acc:	bset #EVNT_MESAG,d0
	bset #EVNT_TIMER,d0
	move #300,d1		; timer en ms
	bsr traite_evenement_gem

	btst #EVNT_KEYBD,d0
	bne keyboard

	btst #EVNT_TIMER,d0
	bne.s timer

	btst #EVNT_MESAG,d0
	bne message

	bra.s boucle_gem_principale


timer:	tst sample_playing
	beq.s .no
	tst loop
	bne.s .loop			; si loop pas de fin de fichier...
	tst end_of_file
	bne.s .wait
.loop:	clr end_of_file
	bsr check_d2d_load
.no:	bra boucle_gem_principale

.wait:	move semaphore,d0
	cmp.w #NB_BUFF-1,d0		; on laisse jouer les derniers
	blt boucle_gem_principale
	clr end_of_file
	bsr stop_if_running

	tst.l are_there_more
	bne load_file

	tst.l play_list_ptr
	bne load_file

	bra boucle_gem_principale

unknown_message:
	neg d1
	cmp.w #AP_TERM,d1		; AP_TERM
	beq fin

	cmp.w #ACC_OPEN,d1		; ACC_OPEN
	bne.s .not_open_acc

	move.w acc_number,d2	; store the application id
	cmp.w buffer_msg+4*2,d2
	bne boucle_gem_principale

	bsr stop_if_running
	clr.l are_there_more
	bra load_file
.not_open_acc:

	cmp.w #ACC_CLOSE,d1		; ACC_CLOSE
	bne.s .not_close_acc

	move.w acc_number,d2	; store the application id
	cmp.w buffer_msg+3*2,d2
	bne boucle_gem_principale

*	tst sample_playing
*	beq boucle_gem_principale

*	lea alert_accclose,a0
*	bsr alert_box

*	cmp.w #1,d0
*	beq boucle_gem_principale

	bsr stop_if_running
	bra boucle_gem_principale
.not_close_acc:

	cmp.w #224,d1		; on m'a envoye 1 msg
	bne.s pas_pour_moi

	*move buffer_msg+2,d0		; qui m'a anvoy‚ ‡a ?
	move buffer_msg+4,d0
	lea buffer_msg+2*3,a0
	lea store_msg,a1
	move #8-3-1,d1
.cp:	move.w (a0)+,(a1)+
	dbf d1,.cp

	tst d0
	beq.s .finish
	appl_read global+4,d0,a1
.finish:

	lea store_msg,a0

	cmp.l #'stop',(a0)		;'stop'
	bne.s .pastop 
	bsr stop_if_running
	bra boucle_gem_principale

.pastop:	cmp.l #'play',(a0)
	bne.s .pasplay

	lea 4+1(a0),a0		;'play='
	lea name_2_load,a1
.ccp:	move.b (a0)+,(a1)+
	tst.b -1(a1)
	bne.s .ccp

	bra load_file2

.pasplay:
	bra boucle_gem_principale

pas_pour_moi:
	bra boucle_gem_principale

keyboard:	lea conversion,a0
	bsr convert_key_in_event
	tst d7
	bne boucle_gem_principale

message:	tst d1
	bmi unknown_message

	cmp.b #FREQUENCY_1,d1
	bne.s pas_1
	move.b #freq8,frequency_for_play
	move #FREQUENCY_1,d6
	bsr menu_freq_check
pas_1:	cmp.b #FREQUENCY_2,d1
	bne.s pas_2
	move.b #freq10,frequency_for_play
	move #FREQUENCY_2,d6
	bsr menu_freq_check
pas_2:	cmp.b #FREQUENCY_3,d1
	bne.s pas_3
	move.b #freq12,frequency_for_play
	move #FREQUENCY_3,d6
	bsr menu_freq_check
pas_3:	cmp.b #FREQUENCY_4,d1
	bne.s pas_4
	move.b #freq16,frequency_for_play
	move #FREQUENCY_4,d6
	bsr menu_freq_check
pas_4:	cmp.b #FREQUENCY_5,d1
	bne.s pas_5
	move.b #freq20,frequency_for_play
	move #FREQUENCY_5,d6
	bsr menu_freq_check
pas_5:	cmp.b #FREQUENCY_6,d1
	bne.s pas_6
	move.b #freq25,frequency_for_play
	move #FREQUENCY_6,d6
	bsr menu_freq_check
pas_6:	cmp.b #FREQUENCY_7,d1
	bne.s pas_7
	move.b #freq33,frequency_for_play
	move #FREQUENCY_7,d6
	bsr menu_freq_check
pas_7:	cmp.b #FREQUENCY_8,d1
	bne.s pas_8
	move.b #freq49,frequency_for_play
	move #FREQUENCY_8,d6
	bsr menu_freq_check
pas_8:	cmp.b #FREQUENCY_9,d1
	bne.s pas_9

	move.w #1,which_clock
	tst sample_playing
	beq.s .not_set
	
	move.w #1,-(sp)		; no hand shaking
	clr d0
	move.b frequency_for_play,d0
	move.w d0,-(sp)
	move.w which_clock,-(sp)	; 1=externe
	move.w #8,-(sp)		; destination : DAC
	move.w #0,-(sp)		; source : DMA
	appel xbios,139,12
.not_set:	move.w #FREQUENCY_9,d0
	moveq #1,d1
	bsr check_menu
	move.w #FREQUENCY_0,d0
	moveq #0,d1
	bsr check_menu

pas_9:	cmp.b #FREQUENCY_0,d1
	bne.s pas_0

	move.w #0,which_clock
	tst sample_playing
	beq.s .not_set
	
	move.w #1,-(sp)		; no hand shaking
	clr d0
	move.b frequency_for_play,d0
	move.w d0,-(sp)
	move.w which_clock,-(sp)	; 0=interne
	move.w #8,-(sp)		; destination : DAC
	move.w #0,-(sp)		; source : DMA
	appel xbios,139,12

.not_set:	move.w #FREQUENCY_0,d0
	moveq #1,d1
	bsr check_menu
	move.w #FREQUENCY_9,d0
	moveq #0,d1
	bsr check_menu
pas_0:

	cmp.b #METHOD_1,d1
	bne.s pas_f1
	bsr check_method
	move.l #dec0,charge_octets
pas_f1:	cmp.b #METHOD_2,d1
	bne.s pas_f2
	bsr check_method
	move.l #dec1,charge_octets
pas_f2:	cmp.b #METHOD_3,d1
	bne.s pas_f3
	bsr check_method
	move.l #dec2,charge_octets
pas_f3:	cmp.b #METHOD_4,d1
	bne.s pas_f4
	bsr check_method
	move.l #dec3,charge_octets
pas_f4:	cmp.b #METHOD_5,d1
	bne.s pas_f5
	bsr check_method
	move.l #dec4,charge_octets
pas_f5:	cmp.b #METHOD_6,d1
	bne.s pas_f6
	bsr check_method
	move.l #dec5,charge_octets
pas_f6:	cmp.b #METHOD_7,d1
	bne.s pas_f7
	bsr check_method
	move.l #dec6,charge_octets
pas_f7:	cmp.b #METHOD_8,d1
	bne.s pas_f8
	bsr check_method
	move.l #dec7,charge_octets
pas_f8:	cmp.b #METHOD_9,d1
	bne.s pas_f9
	bsr check_method
	move.l #dec8,charge_octets
pas_f9:

	cmp.w #INFO_MENU,d1
	bne.s .pas1
	move.w #FORM_INFOS,d0
	bsr traite_formulaire
	bra boucle_gem_principale
	
.pas1:
	cmp.w #FILES_QUIT,d1
	beq fin

	cmp.w #FILES_STOP,d1
	bne.s .no1
	bsr stop_if_running
	bra boucle_gem_principale
.no1:
	cmp.w #FILES_LOAD,d1
	beq load_file

	cmp.w #FILES_LOOP,d1
	beq loop_file

	cmp.w #FILES_INFO,d1
	beq show_info_about_a_file	; infos sur 1 DVW

	cmp.w #CONVERSION_1,d1		; st‚r‚o -> mono
	beq conv1

	cmp.w #CONVERSION_2,d1
	beq conv2

	cmp.w #CONVERSION_3,d1		; mono -> st‚r‚o
	beq conv3

	cmp.w #CONVERSION_4,d1		; dvsm -> trk
	beq conv4

	cmp.w #CONVERSION_5,d1		; trk st‚r‚o -> DVSW
	beq conv5

	cmp.w #CONVERSION_6,d1		; trk mono -> DVSW
	beq conv6

	cmp.w #CONVERSION_7,d1		; dvsw -> TRK
	beq conv7

	cmp.w #SPECIAL_ANALYSE,d1
	beq analyse_trk

	cmp.w #CONVERSION_CHOOS,d1
	beq choose_table

	cmp.w #SPECIAL_DISTORS,d1
	beq analyse_distorsion

	bra boucle_gem_principale
************************************************************************************************
show_info_about_a_file:
	move.l #'*.DV',whato
	move.l #'W,*.',whato+4
	move.l #'LT'*65536,whato+8
	lea text_infodvw,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annn

	lea params_it,a0
.f:	tst.b (a0)+		; X X X 0 ptr
	bne.s .f

	cmp.l #'.LT'*256,-4(a0)
	beq its_list_of_track

	FS_FIRST #$23,params_it
	GET_DTA
	move.l d0,a0
	move.l 26(a0),taille_fich_dvw

	file_open read,params_it
	tst d0
	bmi annn
	move.w d0,handle1

	file_read #read_info_dvw,#4,handle1

	move.l read_info_dvw,d0
	cmp.l #'DVSW',d0
	bne annn2

	file_read #read_info_dvw,#4,handle1
	file_close handle1

	move.w #INFO_ON_FILE,d0
	lea add_tree,a0
	bsr get_addr_tree

	move.l add_tree,a0		; a0
	move.w #PACKED_YES_NO,d0
	bsr get_text_add		; a1
	move.l #'NO'*65536,(a1)
	tst.b read_info_dvw
	beq.s .no
	move.l #'YES'*256,(a1)
.no:
	move.l add_tree,a0		; a0
	move.w #LENGTH_PACK_CODE,d0
	bsr get_text_add		; a1
	clr.l d0
	move.b read_info_dvw+1,d0
	bsr deci2

	move.l add_tree,a0		; a0
	move.w #FREQUENZ,d0
	bsr get_text_add		; a1

	move.w #'??',(a1)
	clr.b 2(a1)
	move.l #33000,freq_dvw
	clr d0
	move.b read_info_dvw+3,d0
	beq.s .fin			; unknown
	lea table_cv_freq,a0
.recom:	tst.w (a0)
	beq.s .fin
	cmp.w 2(a0),d0
	beq.s .found
	lea 8(a0),a0
	bra.s .recom
.found:	move.w (a0),(a1)
	clr.l d0
	move.w 6(a0),d0
	move.l d0,freq_dvw
.fin:

	; 0=st‚r‚o,1=mono
	move.l add_tree,a0		; a0
	move.w #TYPE_OF_SOUND,d0
	bsr get_text_add		; a1

	move.l taille_fich_dvw,d7
	sub.l #16+256*2+4,d7

	move.l #'ster',(a1)
	move.w #'eo',4(a1)
	clr.b 6(a1)
	tst.b read_info_dvw+2
	beq.s .str
	move.l #'mono',(a1)
	clr.b 4(a1)
	add.l #2,d7
	mulu.l #2,d7
.str:	divu.l #2,d7

	divu.l freq_dvw,d7

same_as_before:			; le programme pour *.LT reprend ici

	divu #60,d7
	move.w d7,d6
	ext.l d6		; minutes
	swap d7
	ext.l d7		; secs
	save d6-d7

	move.l add_tree,a0		; a0
	move.w #MINUTES,d0
	bsr get_text_add		; a1
	load d6-d7
	move.l d6,d0
	save d7
	move.w #'??',(a1)
	clr.b 2(a1)
	tst.b read_info_dvw+3
	beq.s .ok
	bsr deci2
.ok:

	move.l add_tree,a0		; a0
	move.w #SECONDS,d0
	bsr get_text_add		; a1
	load d7
	move.l d7,d0
	move.w #'??',(a1)
	tst.b read_info_dvw+3
	beq.s .ok2
	bsr deci2
.ok2:

	move #INFO_ON_FILE,d0
	bsr traite_formulaire

annn:	bra boucle_gem_principale
annn2:	file_close handle1
	bra.s annn
				***************
its_list_of_track:
	file_open read,params_it
	move d0,d7
	bmi annn

	file_read #list_of_tracks,#4096,d7
	move.l d0,d6
	bmi.s annn

	file_close d7

	cmp.l #4096,d6		; liste trop grande
	beq.s annn

	lea list_of_tracks,a0
	clr.b (a0,d6.l)
	clr.l d1			; compte les secondes

treat_nxt:	tst.b (a0)
	beq dis_was_last

	cmp.b #' ',(a0)
	beq.s .zap_dis
	cmp.b #lf,(a0)
	beq.s .zap_dis
	cmp.b #rc,(a0)
	beq.s .zap_dis
	cmp.b #9,(a0)	; tab
	beq.s .zap_dis
	bra.s .cool
.zap_dis:	lea 1(a0),a0
	bra.s treat_nxt

.cool:	lea name_2_load,a1

.redo:	move.b (a0)+,d0
	beq.s .end_ofl
	cmp.b #' ',d0
	beq.s .last
	cmp.b #lf,d0
	beq.s .last
	cmp.b #rc,d0
	beq.s .last
	cmp.b #9,d0
	beq.s .last
	move.b d0,(a1)+
	bra.s .redo
.end_ofl:	lea -1(a0),a0	; pour pointer sur le 0

.last:	clr.b (a1)+

	save a0/d1

	FS_FIRST #$23,name_2_load
	GET_DTA
	move.l d0,a0
	move.l 26(a0),taille_fich_dvw

	file_open read,name_2_load
	load a0/d1

	move.w d0,d7
	bmi do_not_count

	save a0/d1

	file_read #read_info_dvw,#4,d7
	move.l read_info_dvw,d6
	file_read #read_info_dvw,#4,d7
	file_close d7

	load a0/d1

	cmp.l #'DVSW',d6
	bne do_not_count

	clr d0
	move.b read_info_dvw+3,d0
	beq.s do_not_count

	lea table_cv_freq,a1
.recom:	tst.w (a1)
	beq.s do_not_count
	cmp.w 2(a1),d0
	beq.s .found
	lea 8(a1),a1
	bra.s .recom
.found:	clr.l d0
	move.w 6(a1),d0

	move.l taille_fich_dvw,d7
	sub.l #16+256*2+4,d7

	tst.b read_info_dvw+2
	beq.s .str
	add.l #2,d7
	mulu.l #2,d7
.str:	divu.l #2,d7

	divu.l d0,d7

	add.l d7,d1

do_not_count:
	bra treat_nxt

dis_was_last:
	save d1
	move.w #INFO_ON_FILE,d0
	lea add_tree,a0
	bsr get_addr_tree

	move.l add_tree,a0		; a0
	move.w #PACKED_YES_NO,d0
	bsr get_text_add		; a1
	move.l #'YES'*256,(a1)

	move.l add_tree,a0		; a0
	move.w #TYPE_OF_SOUND,d0
	bsr get_text_add		; a1
	move.l #'???'*256,(a1)

	move.l add_tree,a0		; a0
	move.w #FREQUENZ,d0
	bsr get_text_add		; a1
	move.w #'?'*256,(a1)

	move.l add_tree,a0		; a0
	move.w #LENGTH_PACK_CODE,d0
	bsr get_text_add		; a1
	move.w #'8'*256,(a1)

	load d7
	move.b #1,read_info_dvw+3	: pour ruser et forcer la rout … afficher
	bra same_as_before

************************************************************************************************

choose_table:
	move.l #'*.TA',whato
	move.w #'B'*256,whato+4
	lea text_table,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq ann

	file_open read,params_it
	tst d0
	bmi ann
	move.w d0,handle1

	file_read #table_dvswax,#256*2,handle1
	move.l d0,d7

	file_close handle1
	cmp.l #256*2,d7
	bne .pas_c

	cmp.w #$8000,table_dvswax
	bne .pas_c
	cmp.w #$0000,table_dvswax+128*2
	bne .pas_c
	cmp.w #$7fff,table_dvswax+255*2
	bne .pas_c

	bra.s ann

.pas_c:	lea original_table_dvswax,a0
	lea table_dvswax,a1
	move #256-1,d0
.default:	move.w (a0)+,(a1)+
	dbf d0,.default

	lea alert_table,a0
	bsr alert_box

ann:	bra boucle_gem_principale
	
		********** Analyses **********
analyse_distorsion:
	move.l #'*.TR',whato		; Left/Right -> Left + Right
	move.w #'K'*256,whato+4
	lea text_dist1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule_dist

	bsr stop_if_running		; car je fais test_if_wax_info_present2

	lea params_it,a0
	bsr test_if_wax_info_present2
	file_open read,params_it
	move.w d0,handle1
	bmi .annule_dist
	file_seek #0,handle1,header

	lea text_dist2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule_dist1

	lea params_it,a0
	bsr test_if_wax_info_present2
	file_open read,params_it
	move.w d0,handle2
	bmi .annule_dist1
	file_seek #0,handle2,header

.analyse_again:
	file_read #load,#taille_buff*2,handle1
	cmp.l #taille_buff*2,d0
	bne .annule_dist2
	file_read #load+taille_buff*2,#taille_buff*2,handle2
	cmp.l #taille_buff*2,d0
	bne .annule_dist2

	lea load,a0
	lea load+taille_buff*2,a1
	fmove.w #0,fp0		; somme des deltas
	fmove.w #0,fp7		; compteur

.redo:	move.w (a0)+,d6
	move.w (a1)+,d7
	ext.l d6
	ext.l d7
	beq.s .zero

	sub.l d7,d6
	fmove.l d6,fp1
	fmove.l d7,fp2
	fabs.x fp1
	fabs.x fp2
	fdiv.x fp2,fp1
	fadd.x fp1,fp0
	fadd.x #1,fp7

.zero:	subq.l #2,d0
	bgt.s .redo

	fdiv.x fp7,fp0
	fmul.x #1000,fp0

	move.w #DISTORSION,d0
	lea add_tree,a0
	bsr get_addr_tree

	move.l add_tree,a0		; a0
	move.w #DIST_PER_MILE,d0
	bsr get_text_add		; a1
	fmove.l fp0,d0
	bsr deci2

	move #DISTORSION,d0
	bsr traite_formulaire

	cmp.w #DMORE,d0
	beq .analyse_again

.annule_dist2:
	file_close handle2
.annule_dist1:
	file_close handle1
.annule_dist:
	bra boucle_gem_principale

	
analyse_trk:move.l #'*.TR',whato		; st‚r‚o -> Mono
	move.w #'K'*256,whato+4
	lea text_analyse,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule_ana

	bsr stop_if_running

	file_open read,params_it
	move.w d0,handle1
	bmi annule_ana

analyse_again:
	file_read #load,#taille_buff*2,handle1
	cmp.l #taille_buff*2,d0
	bne pas_c

	lea load+taille_buff*2,a0
	move.l #taille_buff*2/4,d0
.clr:	clr.l (a0)+
	subq.l #1,d0
	bne.s .clr

	lea load,a0
	lea load+taille_buff*2,a1
	move.w (a0)+,d0
	ext.l d0
	move.w (a0)+,d1
	ext.l d1
.redo:	cmp.l #load+taille_buff*2,a0
	bge.s .fini
	move.l d0,d2
	move.w (a0)+,d0
	ext.l d0
	sub.l d0,d2
	bpl.s .pos1
	neg.l d2
.pos1:	move.l d1,d3
	move.w (a0)+,d1
	ext.l d1
	sub.l d1,d3
	bpl.s .pos2
	neg.l d3
.pos2:	addq.w #1,(a1,d2.l*2)
	addq.w #1,(a1,d3.l*2)
	bra.s .redo

.fini:

	move.w #ANALYSE,d0
	lea add_tree,a0
	bsr get_addr_tree
	move.l add_tree,a0		; a0

	move.w #ABS_MIN_DELTA,d0
	bsr get_text_add		; a1
	lea load+taille_buff*2,a2
.ze:	tst.w (a2)+
	beq.s .ze
	lea -2(a2),a2
	sub.l #load+taille_buff*2,a2
	move.l a2,d0
	lsr.l #1,d0
	bsr deci2

	move.w #ABS_MAX_DELTA,d0
	bsr get_text_add		; a1
	lea load+taille_buff*2+65536*2,a2
.ze0:	tst.w -(a2)
	beq.s .ze0
	sub.l #load+taille_buff*2,a2
	move.l a2,d0
	lsr.l #1,d0
	bsr deci2

	move.w #AVERAGE_DELTA,d0
	bsr get_text_add
	lea load+taille_buff*2,a2
	fmove.w #0,fp0		; index
	fmove.w #0,fp2		; somme
	clr.l d0

.redoo:	cmp.l #load+taille_buff*2+65536*2,a2
	beq.s .f
	move.w (a2)+,d0		; jusqu'… 65535
	fmove.l d0,fp1
	fmul.x fp0,fp1
	fadd.x fp1,fp2
	fadd.x #1,fp0
	bra.s .redoo
.f:	fmove.l #taille_buff*2/2,fp0	; nombre d'‚chantillons trait‚
	fdiv.x fp0,fp2
	fmove.l fp2,d0
	bsr deci2

	move.w #DELTA_VARIANCE,d0
	bsr get_text_add
	lea load+taille_buff*2,a2
	;fp2: moyenne
	fmove.w #0,fp0		; index (delta 0 -> 65535)
	fmove.w #0,fp3		; somme des carr‚s
	clr.l d0

.redooo:	cmp.l #load+taille_buff*2+65536*2,a2
	beq.s .ff
	move.w (a2)+,d0		; jusqu'… 65535
	fmove.l d0,fp1		; nombre
	
	fmove.x fp2,fp4		; moy
	fsub.x fp0,fp4		; -val actuelle
	fmul.x fp4,fp4		; ^2
	fmul.x fp1,fp4		; * nb val actuelle
	
	fadd.x fp4,fp3
	fadd.x #1,fp0
	bra.s .redooo
.ff:	fmove.l #taille_buff*2/2,fp0	; nombre d'‚chantillons trait‚s
	fdiv.x fp0,fp3
	fsqrt.x fp3
	fmove.l fp3,d0
	bsr deci2

	move #ANALYSE,d0
	bsr traite_formulaire

	cmp.w #MORE,d0
	beq analyse_again

pas_c:	file_close handle1
annule_ana:	bra boucle_gem_principale
	
		********** Conversions ************

conv1:	move.l #'*.TR',whato		; st‚r‚o -> Mono
	move.w #'K'*256,whato+4
	lea text_mono1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule1

	bsr check_d2d_load

	file_open read,params_it
	move.w d0,handle1
	bmi annule1

	lea text_mono2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule2

	file_open write,params_it
	move.w d0,handle2
	bmi .annule2

	bsr stop_if_running

.all_file:	file_read #load,#taille_buff*NB_BUFF/2,handle1
	tst.l d0
	beq.s .annule3

	lsr.l #1,d0		; /2
	move.l d0,d7
	lsr.l #1,d0		; /2 : combien de fois (1.w+1.w)=4 octets ?

	lea load,a0
	lea load+taille_buff*NB_BUFF/2,a1

.mono:	move.w (a0)+,d1	; 4 par 4
	ext.l d1
	move.w (a0)+,d2
	ext.l d2
	add.l d2,d1
	asr.l #1,d1
	move.w d1,(a1)+
	subq.l #1,d0
	bgt.s .mono

	file_write #load+taille_buff*NB_BUFF/2,d7,handle2
	cmp.l d7,d0			; ‚crit OK ?
	bne.s .annule3
	cmp.l #taille_buff*NB_BUFF/2/2,d7
	beq.s .all_file

.annule3:	file_close handle2
.annule2:	file_close handle1

annule1:	bra boucle_gem_principale

conv2:	move.l #'*.TR',whato		; Left/Right -> Left + Right
	move.w #'K'*256,whato+4
	lea text_two1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule2

	bsr check_d2d_load

	file_open read,params_it
	move.w d0,handle1
	bmi annule2

	lea text_two2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule2

	bsr check_d2d_load

	file_open write,params_it
	move.w d0,handle2
	bmi .annule2

	lea text_two3,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule3

	file_open write,params_it
	move.w d0,handle3
	bmi .annule3

	bsr stop_if_running

.all_file:	file_read #load,#taille_buff*NB_BUFF/2,handle1
	tst.l d0
	beq.s .annule4

	lsr.l #1,d0		; /2
	move.l d0,d7
	lsr.l #1,d0		; /2

	lea load,a0
	lea load+taille_buff*NB_BUFF/2,a1
	lea load+taille_buff*NB_BUFF*3/4,a2

.mono:	move.w (a0)+,(a1)+	; 4 par 4
	move.w (a0)+,(a2)+
	subq.l #1,d0
	bgt.s .mono

	file_write #load+taille_buff*NB_BUFF/2,d7,handle2
	cmp.l d7,d0			; ‚crit OK ?
	bne.s .annule4
	file_write #load+taille_buff*NB_BUFF*3/4,d7,handle3
	cmp.l d7,d0			; ‚crit OK ?
	bne.s .annule4
	cmp.l #taille_buff*NB_BUFF/2/2,d7
	beq.s .all_file

.annule4:	file_close handle3
.annule3:	file_close handle2
.annule2:	file_close handle1

annule2:	bra boucle_gem_principale

conv3:	move.l #'*.TR',whato		; Mono -> St‚r‚o
	move.w #'K'*256,whato+4
	lea text_stereo1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule3

	bsr check_d2d_load

	file_open read,params_it
	move.w d0,handle1
	bmi annule3

	lea text_stereo2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule2

	file_open write,params_it
	move.w d0,handle2
	bmi .annule2

	bsr stop_if_running

.all_file:	file_read #load,#taille_buff*NB_BUFF/2/2,handle1
	tst.l d0
	beq.s .annule3

	move.l d0,d7
	lsr.l #1,d0		; /2
	lsl.l #1,d7		; *2

	lea load,a0
	lea load+taille_buff*NB_BUFF/2,a1

.mono:	move.w (a0)+,d1	; 2 par 2
	move.w d1,(a1)+
	move.w d1,(a1)+
	subq.l #1,d0
	bgt.s .mono

	file_write #load+taille_buff*NB_BUFF/2,d7,handle2
	cmp.l d7,d0			; ‚crit OK ?
	bne.s .annule3
	cmp.l #taille_buff*NB_BUFF/2,d7
	beq.s .all_file

.annule3:	file_close handle2
.annule2:	file_close handle1

annule3:	bra boucle_gem_principale

conv4:	move.l #'*.DV',whato		; DVSM -> Track
	move.w #'S'*256,whato+4
	lea text_dvs1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule4

	bsr check_d2d_load

	file_open read,params_it
	move.w d0,handle1
	bmi annule4

	move.l #'*.TR',whato
	move.w #'K'*256,whato+4
	lea text_dvs2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule2

	file_open write,params_it
	move.w d0,handle2
	bmi .annule2

	bsr stop_if_running

	file_read #load,#8,handle1
	lea load,a0
	cmp.l #'DVSM',(a0)
	bne .annule3
	clr.l d0
	move.w 6(a0),d0	; header length
	sub.l #6+2,d0

	file_read #load,d0,handle1
	lea load,a0
	cmp.w #$0201,2(a0)	; packed/stereo 16 bit
	bne .annule3
	move.l 4(a0),save_blocklength

.redo:	file_read #load,#4,handle1
	cmp.l #4,d0
	bne .annule3
	lea load,a0
	move.w (a0),d6
	move.w 2(a0),d7

	move.l save_blocklength,d0
	subq.l #4,d0
	save d0
	file_read #load,d0,handle1
	tst.l d0
	beq .annule3
	load d1		; d1=what we wanted
	move.l d0,d2	; d2=what we have

	lea load,a0
	lea load+taille_buff,a1
	lea table_dvs+128*2,a2
	lsr.l #1,d0		; 2 par 2
	move d6,(a1)+
	move d7,(a1)+

	bra.s .x
.pb:	bmi.s .neg
	move.w #-32768,d6
	bra.s .g
.neg:	move.w #32767,d6
	bra.s .g
.pb2:	bmi.s .neg2
	move.w #-32768,d7
	bra.s .g2
.neg2:	move.w #32767,d7
	bra.s .g2

.x
.decomp:	move.b (a0)+,d3
	ext.w d3
	add.w (a2,d3.w*2),d6
	bvs.s .pb
.g:	move.b (a0)+,d3
	ext.w d3
	add.w (a2,d3.w*2),d7
	bvs.s .pb2
.g2:	move.w d6,(a1)+
	move.w d7,(a1)+
	subq.l #1,d0
	bgt.s .decomp
	
	addq.l #2,d1
	addq.l #2,d2
	lsl.l #1,d1
	lsl.l #1,d2
	save d1-d2
	file_write #load+taille_buff,d2,handle2
	load d1-d2
	cmp.l d2,d0			; ‚crit OK ?
	bne.s .annule3
	cmp.l d1,d2
	beq .redo

.annule3:	file_close handle2
.annule2:	file_close handle1

annule4:	bra boucle_gem_principale

		******* WAX conversions *********

treat:	macro		; don't touch d0 d6 d7
	move.w (a0)+,d1
	ext.l d1
	sub.l \1,d1
	bsr change_delta_in_byte
.\@red:	move.b d1,(a1)+
	move.w (a2,d1.w*2),d2
	ext.l d2
	add.l d2,\1
	cmp.l #32767,\1
	bgt.s .\@trop
	cmp.l #-32768,\1
	bge.s .\@coool

	lea -1(a1),a1
	sub.l d2,\1
	addq.w #1,d1
	bra.s .\@red
.\@trop:	lea -1(a1),a1
	sub.l d2,\1
	subq.w #1,d1
	bra.s .\@red
.\@coool:
	endm

conv6:	bsr stop_if_running
	move.w #1,mono_stereo_dvsw	; Mono Track -> DVSW
	bra.s conv6b

conv5:	bsr stop_if_running
	clr mono_stereo_dvsw		; Stereo Track -> DVSW

conv6b:	move.l #'*.TR',whato
	move.w #'K'*256,whato+4
	lea text_dvsw1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule5

	file_open read,params_it
	move.w d0,handle1
	bmi annule5

	move.l #'*.DV',whato
	move.w #'W'*256,whato+4
	lea text_dvsw2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule2

	file_open write,params_it
	move.w d0,handle2
	bmi .annule2

	lea load,a0
	move.l #'DVSW',(a0)+
	move.b #1,(a0)+		; 1=pack‚
	move.b #8,(a0)+		; 8bits pack code
	move.w mono_stereo_dvsw,d0
	move.b d0,(a0)+		; 0=st‚r‚o,1=mono

	move.b frequency_for_play,(a0)+

	move #16-8-1,d0
.clr:	clr.b (a0)+
	dbf d0,.clr

	file_write #load,#4+1+1+1+1+(16-8),handle2
	cmp.l #16,d0
	bne .annule3

	file_write #table_dvswax,#256*2,handle2
	cmp.l #256*2,d0
	bne .annule3

	move.l #4,d7
	tst mono_stereo_dvsw	
	beq.s .st
	move.l #2,d7
.st:	file_read #load,d7,handle1
	cmp.l d7,d0
	bne .annule3

	file_write #load,d7,handle2
	cmp.l d7,d0
	bne .annule3

	lea load,a0
	move.w (a0),d6
	move.w 2(a0),d7
	ext.l d6
	ext.l d7


.redo:	
	move.w  #-1,-(sp)	; Shift_Droit:1, SG:2 CTRL:4 ALT:8
	appel bios,11,4	; ‚tat des touches sp‚ciales
	and.w #3,d0
	cmp.w #3,d0
	beq .annule3	; d6 d7 INTACTS

	file_read #load,#taille_buff,handle1
	tst.l d0
	beq .annule3
	move.l d0,d5
	lea load,a0
	lea load+taille_buff,a1
	lea table_dvswax+128*2,a2

.traite:	move mono_stereo_dvsw,d3
.traite2:	save d3
	treat d6
	load d3

	tst mono_stereo_dvsw
	beq.s .continue
	dbf d3,.traite2	
	bra.s .mono

.continue:	treat d7

.mono:	subq.l #4,d0
	bgt .traite

	lsr.l #1,d5
	save d5
	file_write #load+taille_buff,d5,handle2
	load d1
	cmp.l d0,d1
	bne.s .annule3
	cmp.l #taille_buff/2,d1
	beq .redo

.annule3:	file_close handle2
.annule2:	file_close handle1

annule5:	bra boucle_gem_principale

change_delta_in_byte:
	cmp.l #32767,d1
	bge.s .sup
	cmp.l #-32768,d1
	ble.s .inf

	tst.l d1			; dichotomie de rang 2
	ble.s .inf0
	move.w table_dvswax+128*2+64*2,d2
	ext.l d2
	cmp.l d2,d1
	ble.s .34
.44:	lea table_dvswax+128*2+64*2,a3
	bra.s .zap
.34:	lea table_dvswax+128*2,a3
	bra.s .zap
.inf0:	move.w table_dvswax+64*2,d2
	ext.l d2
	cmp.l d2,d1
	ble.s .14
.24	lea table_dvswax+64*2,a3
	bra.s .zap
.14	lea table_dvswax,a3
.zap:

.sear:	lea 2(a3),a3
	move (a3),d2		; (a3) ; la 2Šme valeur
	ext.l d2
	cmp.l d2,d1
	bgt.s .sear
	beq.s .ok

	move.w -2(a3),d3
	ext.l d3
	neg.l d3
	add.l d1,d3			; gauche … milieu

	move.l d2,d4		; milieu … droite
	sub.l d1,d4

	cmp.l d3,d4
	ble.s .peti	
	lea -2(a3),a3
.peti:
.ok:	sub.l #table_dvswax,a3
	move.w a3,d1
	asr.w #1,d1
	add.w #-128,d1
	rts
.sup:	move.w #127,d1
	rts
.inf:	move.w #-128,d1
	rts


conv7:	move.l #'*.DV',whato		; DVSW -> Track
	move.w #'W'*256,whato+4
	lea text_dvsw3,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule7

	bsr check_d2d_load

	file_open read,params_it
	move.w d0,handle1
	bmi annule7

	move.l #'*.TR',whato
	move.w #'K'*256,whato+4
	lea text_dvsw4,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule2

	file_open write,params_it
	move.w d0,handle2
	bmi .annule2

	bsr stop_if_running

	file_read #load,#16,handle1
	cmp.l #16,d0
	bne .annule3

	lea load,a0
	cmp.l #'DVSW',(a0)+
	bne .annule3
	cmp.b #1,(a0)+		; 1=pack‚
	bne .annule3
	cmp.b #8,(a0)+		; 8bits pack code
	bne .annule3
	move.b (a0)+,mono_stereo_dvsw+1

	file_read #table_dec_dvsw,#256*2,handle1
	cmp.l #256*2,d0
	bne .annule3

	move.l #4,d5
	tst mono_stereo_dvsw	
	beq.s .st
	move.l #2,d5
.st:	file_read #load,d5,handle1
	cmp.l d5,d0
	bne .annule3
	move.w load,d6
	move.w load+2,d7

	file_write #load,d5,handle2
	cmp.l d5,d0
	bne .annule3

.redo:	file_read #load,#taille_buff,handle1
	tst.l d0
	beq.s .annule3
	move.l d0,d5
	lea load,a0
	lea load+taille_buff,a1

	lea table_dec_dvsw+128*2,a2
	lsr.l #1,d0		; 2 par 2

.trai:	move mono_stereo_dvsw,d3
.trai2:	move.b (a0)+,d1
	ext.w d1
	add.w (a2,d1.w*2),d6
	move.w d6,(a1)+

	tst mono_stereo_dvsw
	beq.s .continue
*	move.w d6,(a1)+	; on d‚compacte un DVSW mono -> track mono
	dbf d3,.trai2
	bra.s .mono

.continue:
	move.b (a0)+,d1
	ext.w d1
	add.w (a2,d1.w*2),d7
	move.w d7,(a1)+

.mono:	subq.l #1,d0
	bgt.s .trai

	lsl.l #1,d5
	save d5
	file_write #load+taille_buff,d5,handle2
	load d1
	cmp.l d0,d1			; ‚crit OK ?
	bne.s .annule3
	cmp.l #taille_buff*2,d0
	beq .redo

.annule3:	file_close handle2
.annule2:	file_close handle1

annule7:	bra boucle_gem_principale

		******** Loop mode ********
loop_file:	tst loop
	beq.s .null
	move #0,loop
	move #FILES_LOOP,d0
	moveq #0,d1
	bsr check_menu
	bra boucle_gem_principale
.null	move #1,loop
	move #FILES_LOOP,d0
	moveq #1,d1
	bsr check_menu
	bra boucle_gem_principale

		******* Load file s‚lectrix *********
load_file:
	tst.l play_list_ptr
	bne copy_next_in_list
ask_selctor:

	tst.l sltr_adress		; s‚lectrix is here ?
	beq.s no_trix

	tst.l are_there_more
	bne.s .more

	move.l sltr_communication_word,a0
	move.w #3,(a0)
	move.l sltr_out_counter,a0
	move.w #256,(a0)
	move.l sltr_out_pointer,a0
	move.l #return_more_names,(a0)
	bra.s no_trix

.more:	move.l are_there_more,a0
troc2:	lea params_it,a1
cpp:	move.b (a0)+,(a1)+
	tst.b -1(a1)
	beq.s .that_was_last
	cmp.b #' ',-1(a1)
	bne.s cpp
	clr.b -1(a1)
	move.l a0,are_there_more
	bra no_selector
.that_was_last:
	clr.l are_there_more
	bra.s no_selector
no_trix:


	move.l #'*.TR',whato
	tst.l sltr_adress
	beq.s .no_trix3
	move.l #'K,*.',whato+4
	move.l #'DVW,',whato+8		; *.TRK,*.DVW,*.LT 0
	move.l #'*.LT',whato+12
	move.b #0,whato+16
	bra.s .zap
.no_trix3:	move.w #'K'*256,whato+4
.zap:
	lea texte_fsel,a0		; 35 chars max.
	bsr copy_in2_select
	bsr fileselect
az:	cmp.w #1,d4
	bne.s f_i_n

	tst.l sltr_adress
	beq.s .no_trix2
	tst.b return_more_names
	beq.s .no_trix2		; aucune s‚lection (*.S par ex)
	move.l #return_more_names,a0
	bra troc2
.no_trix2:
	tst.b params_it		; le mec tappe enter
	beq.s f_i_n

no_selector:

	bsr stop_if_running

	lea params_it,a0
	lea name_2_load,a1
.cp:	move.b (a0)+,(a1)+
	tst.b -1(a1)
	bne.s .cp

load_file2:	bsr test_if_itsa_play_list
	tst d7
	bpl load_file
load_it_now:

	bsr test_if_wax_info_present
	bsr init_d2d
	tst d7
	bmi.s fuck
	bsr play_d2d

f_i_n:	bra boucle_gem_principale

fuck:	move #SOUND_SEMAPHORE,d0
	bsr traite_formulaire

	bra boucle_gem_principale


		******* List of Tracks *******
test_if_itsa_play_list:
	lea name_2_load,a0

	lea name_for_wax,a1
.cp:	move.b (a0)+,(a1)+
	tst.b -1(a1)
	bne.s .cp
	lea -1(a1),a1

	cmp.l #name_for_wax+4,a1
	ble .return

	cmp.l #'.LT'*256,-3(a1)
	bne.s .return

	file_open read,name_for_wax	; name for wax : sert aussi de buffer
	move d0,d7
	bmi .return

	file_read #list_of_tracks,#4096,d7
	move.l d0,d6

	file_close d7

	cmp.l #4096,d6		; liste trop grande
	beq.s .return

	lea list_of_tracks,a0
	clr.b (a0,d6.l)

	move.l a0,play_list_ptr

	clr d7
	rts	

.return:	moveq #-1,d7
	rts

	bra.s .return

copy_next_in_list:
	move.l play_list_ptr,a0

.next:	tst.b (a0)
	beq.s .fin

	cmp.b #' ',(a0)
	beq.s .zap_dis
	cmp.b #lf,(a0)
	beq.s .zap_dis
	cmp.b #rc,(a0)
	beq.s .zap_dis
	cmp.b #9,(a0)	; tab
	beq.s .zap_dis
	bra.s .cool
.zap_dis:	lea 1(a0),a0
	bra.s .next

.cool:	lea name_2_load,a1

.redo:	move.b (a0)+,d0
	beq.s .end_ofl
	cmp.b #' ',d0
	beq.s .last
	cmp.b #lf,d0
	beq.s .last
	cmp.b #rc,d0
	beq.s .last
	cmp.b #9,d0
	beq.s .last
	move.b d0,(a1)+
	bra.s .redo

.last:	clr.b (a1)+
	move.l a0,play_list_ptr
	bsr stop_if_running
	bra load_it_now

.end_ofl:	clr.l play_list_ptr
	bra load_it_now

.fin:	clr.l play_list_ptr
	bra ask_selctor
			******* Format WAX *******

test_if_wax_info_present:
	lea name_2_load,a0

test_if_wax_info_present2:
	clr wax_info_present
	clr.l header

	lea name_for_wax,a1
.cp:	move.b (a0)+,(a1)+
	tst.b -1(a1)
	bne.s .cp

.again:	move.b -(a1),d0
	cmp.b #'.',d0
	beq.s .foundp
	cmp.l #name_for_wax,a1
	beq.s .noa
	cmp.b #'\',d0
	bne.s .again
.noa:
.f0:	tst.b (a1)+
	bne.s .f0
	move.l #'.WAX',-1(a1)
	clr.b 3(a1)
	bra.s .got_name

.foundp:	move.l #'WAX'*256,1(a1)

.got_name:	file_open read,name_for_wax	; name for wax : set aussi de buffer
	move d0,d7
	bmi pacool

	file_read #name_for_wax,#256,d7
	lea name_for_wax,a1
	add.l d0,a1
	save a1
	file_close d7
	load a1

	lea name_for_wax,a0

redox:	cmp.l a0,a1
	ble pacool

	cmp.b #';',(a0)
	bne.s .paspv
.notf:	cmp.l a0,a1
	ble pacool
	move.b (a0)+,d0
	cmp.b #lf,d0
	bne.s .notf
	bra.s redox

.paspv:	cmp.l #'freq',(a0)		; Fr‚quence
	bne.s .pasfreq
	lea 5(a0),a0		; aprŠs le =
	
	lea table_cv_freq,a2
.f1:	tst.w (a2)
	beq redox 
	move.w (a0),d0
	cmp.w (a2),d0
	beq.s .f
	lea 8(a2),a2
	bra.s .f1
.f:	move.w 2(a2),d0
	move.b d0,frequency_for_play
	move.w 4(a2),d6		; menu check
	save a0/a1
	bsr menu_freq_check2
	load a0/a1
	move #1,wax_info_present
	bra redox

.pasfreq:	cmp.l #'form',(a0)		; Format
	bne.s .pasform
	lea 5(a0),a0		; aprŠs le =

	cmp.l #'16bs',(a0)
	bne.s .pa16bs
	move.l #dec0,d0
	move #METHOD_1,d1
	bra.s .set_it
.pa16bs:	cmp.l #'16bm',(a0)
	bne.s .pa16bm
	move.l #dec5,d0
	move #METHOD_6,d1
	bra.s .set_it
.pa16bm:	cmp.l #'dvsw',(a0)
	bne redox
	move.l #dec8,d0
	move #METHOD_9,d1
.set_it:	move.l d0,charge_octets
	save a0/a1
	bsr check_method
	load a0/a1
	move #1,wax_info_present
	bra redox

.pasform:	cmp.l #'head',(a0)		; Header length
	bne.s .pashead
	lea 5(a0),a0		; aprŠs le =

	clr.l d1
.redo:	clr d0
	move.b (a0)+,d0
	cmp.b #'0',d0
	blt.s .finihed
	cmp.b #'9',d0
	bgt.s .finihed
	mulu.l #10,d1
	sub.b #'0',d0
	ext.l d0
	add.l d0,d1
	bra.s .redo
	
.finihed:	move.l d1,header
	move #1,wax_info_present
	bra redox

.pashead:	lea 1(a0),a0
	bra redox

pacool:	rts
		******* Fin Format WAX *******

fin:	bsr stop_if_running
	restore_prg

menu_freq_check:
	tst sample_playing		; sera updat‚ de toute fa‡on
	beq.s menu_freq_check2		; … l'init 2 play

	save d1			; d6=menu
	move.w #1,-(sp)		; no hand shaking
	clr d0
	move.b frequency_for_play,d0
	move.w d0,-(sp)
	move.w which_clock,-(sp)	; 0=interne 25 HHz,1=externe
	move.w #8,-(sp)		; destination : DAC
	move.w #0,-(sp)		; source : DMA
	appel xbios,139,12
	load d1

menu_freq_check2:			; set menu but not dma freq
	save d1
	move previous_check1,d0
	move #0,d1
	bsr check_menu		; uncheck
	move d6,d0
	move d6,previous_check1
	move #1,d1
	bsr check_menu		; check

	load d1
	rts

check_method:
	save d1
	move previous_check2,d0
	move #0,d1
	bsr check_menu
	move.l (sp),d1
	move d1,d0
	move d0,previous_check2
	moveq #1,d1
	bsr check_menu
	load d1
	rts	
 BSS
frequ:	ds.b 1
 even
 TEXT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
taille_buff=128*1024	; mini >= max (65536,length block of DVSM)
NB_BUFF=4		; attention nombre minimal : 4 (pour conversions)!!
		; d‚compactage des donn‚es au chargement variable
SATURATION=0
	;move.b FREQ8,frequency_for_play
	;move.w #1,loop
	;clr.l header
	;clr.w mono_stereo_dvsw

	include mod_d2d4.s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	section DATA

text_mono1:		dc.b 'Stereo 16-bit file to convert mono :',0
text_mono2:		dc.b 'Select Mono destination file :',0

text_two1:		dc.b 'Stereo 16-bit file to convert L+R :',0
text_two2:		dc.b 'Mono 16-bit file for Left chanel :',0
text_two3:		dc.b 'Mono 16-bit file for Right chanel :',0

text_stereo1:	dc.b 'Select 16-bit Mono source file :',0
text_stereo2:	dc.b 'Select Stereo 16-bit file :',0

text_dvs1:		dc.b 'Select 16-bit DVSM source file :',0
text_dvs2:		dc.b 'Destination Stereo 16-bit file :',0
text_dvsw1:		dc.b 'Select 16-bit TRK source file :',0
text_dvsw2:		dc.b 'Destination file (16-bit DVS WAX):',0
text_dvsw3:		dc.b 'Source file (16-bit DVS WAX):',0
text_dvsw4:		dc.b 'Destination 16-bit TRK file :',0

text_analyse:	dc.b 'Select stereo file to analyse :',0
text_dist1:		dc.b 'Select first Track (TRK no header):',0
text_dist2:		dc.b 'Select track to compare to :',0
text_table:		dc.b 'Choose a 256*2 bytes table :',0
alert_table:	dc.b "[3][There is a|problem with|your table !|setting default][OK]",0
text_infodvw:	dc.b 'Choose DVW file to get info about :',0

*alert_accclose:	dc.b "[3][I've received an|ACC_CLOSE event,|shall I close|or continue to play ?][CONTINUE|STOP]",0
 even

table_dvs:	incbin dvsm.tab

original_table_dvswax:
	incbin dvswax2.tab

conversion:	dc.w $1709,FILES_INFO
	dc.w $1e11,FILES_QUIT
	dc.w $260c,FILES_LOAD
	dc.w $1f13,FILES_STOP
	dc.w $0001,SPECIAL_ANALYSE
	dc.w $0003,SPECIAL_DISTORS
	dc.w $6d31,FREQUENCY_1
	dc.w $6e32,FREQUENCY_2
	dc.w $6f33,FREQUENCY_3
	dc.w $6a34,FREQUENCY_4
	dc.w $6b35,FREQUENCY_5
	dc.w $6c36,FREQUENCY_6
	dc.w $6737,FREQUENCY_7
	dc.w $6838,FREQUENCY_8
	dc.w $6839,FREQUENCY_9
	dc.w $6830,FREQUENCY_0
	dc.w $3b00,METHOD_1
	dc.w $3c00,METHOD_2
	dc.w $3d00,METHOD_3
	dc.w $3e00,METHOD_4
	dc.w $3f00,METHOD_5
	dc.w $4000,METHOD_6
	dc.w $4100,METHOD_7
	dc.w $4200,METHOD_8
	dc.w $4300,METHOD_9
	dc.l 0

table_cv_freq:
	dc.w '8.',freq8,FREQUENCY_1,8195
	dc.w '10',freq10,FREQUENCY_2,9834
	dc.w '12',freq12,FREQUENCY_3,12292
	dc.w '16',freq16,FREQUENCY_4,16490
	dc.w '20',freq20,FREQUENCY_5,20770
	dc.w '25',freq25,FREQUENCY_6,24585
	dc.w '33',freq33,FREQUENCY_7,32880
	dc.w '49',freq49,FREQUENCY_8,49170
	dc.w 0

name_rsc:
	ifeq WHO
	dc.b 'd:\assemble\asources.wax\direct2d\direct2d.rsc',0
	endc
	ifeq (WHO-1)
	dc.b 'd:\assemble\sources.wax\direct2d\direct2d.rsc',0
	endc
	ifeq (WHO-2)
	dc.b 'd:\devpac\source\genuwax\direct2d\direct2d.rsc',0
	endc

texte_fsel:	dc.b 'Select a 16-bit track :',0

string_acc:	dc.b '  Wax Direct Player  ',0
 even

	section BSS
handle1:		ds.w 1
handle2:		ds.w 1
handle3:		ds.w 1
save_blocklength:	ds.l 1

flag_dvs:		ds.w 1
previous_check1:	ds.w 1		; frequency
previous_check2:	ds.w 1		; what method

wax_info_present:	ds.w 1
name_for_wax:	ds.b 256
table_dvswax:	ds.w 256

play_list_ptr:	ds.l 1		; pour la liste .TL
list_of_tracks:	ds.b 4096

read_info_dvw:	ds.l 1		; pour l'analyse d'un dvw
taille_fich_dvw:	ds.l 1
freq_dvw:		ds.l 1		; fr‚quence

are_there_more:	ds.l 1		; pour s‚lectrix
return_more_names:	ds.b (8+1+3+1)*256

acc_number:	ds.w 1			; ne sert … rien ... … priori
store_msg:	ds.b 256			; pour les messages envoy‚s par appl.
	END

MOD_BOX=0
MOD_BOX2=1
MOD_HEXA=0
MOD_DECI=1
MOD_WIND=0
MOD_MENU=1
MOD_ACC=0

WHO=0	; 0=wax, 1=gen, 2=roro

	ifeq WHO*(WHO-1)
	incdir d:\assemble\sources.wax\direct4d.pro
	endc
	ifeq (WHO-2)
	incdir d:\devpac\source\genuwax\direct4d
	endc

	include guw_mac3.s
	include wd2d_pro.hs
	ifeq MOD_ACC
	ifeq WHO*(WHO-1)
	output d:\assemble\sources.wax\direct4d.pro\wd2d_pro.app
	endc
	ifeq (WHO-2)
	output d:\devpac\source\genuwax\direct4d\wd2d_pro.app
	endc
	else
	output c:\wd2d_pro.acc
	endc

	; Direct to disk en lecture
	; NB buf variable, rattrape le retard, et d‚compression incluse
	; module externe utilisable par n'importe quel programme.
	; Passage de paramŠtres .TTP, et messages applications GEM.
	; 24/VII/93  27/VII 30/VII 07/VIII 16/VIII 30/VIII 25/IX
	; 18/II/94 25/II 02/IV 04/IV 15/IV 23/IV 24/IV, 27/IV
	; 30/IV 29/V 30/V 1/VI 18/VI 24/VII 5/X 14/X 15/X 16/X 1/XI
	; 2/XI 5/XI 6/XI 11/XI 13/XI
	; Gem version : 23/II/1994.

	section TEXT

debut:	init_prg 1024,#name_rsc

	shel_write #9,#1,#0,#0,#0

	clr sample_playing
	clr.l are_there_more
	clr.l play_list_ptr

	clr which_clock		; interne
	clr loop
	clr.l header
	clr replay_in_psst
	move.w #1,which_rout		; routine par d‚faut
	move #20,nb_ms		; 20 ms ps-st

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
	move.b $80(a5),d0		; ligne de commande ?
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
	move #1,d1			; timer en ms
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

	tst end_of_file
	bne.s .wait

	clr end_of_file
	bsr check_d2d_load

.no:	bra boucle_gem_principale

	; le problŠme est qu'il faut stopper le DMA qd il joue le d‚but
	; du buffer qu'il ne devrait pas jouer : jouer avec la valeur
	; du timer GEM
.wait:	move semaphore,d0
	cmp.w #NBR_BUFF,d0		; on laisse jouer les derniers
	blt boucle_gem_principale

	clr end_of_file

	tst loop
	bne.s .no

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

	cmp.w #224,d1		; on m'a envoy‚ 1 msg
	beq.s pour_moi

	bra boucle_gem_principale


pour_moi:
	*move buffer_msg+2,d0		; qui m'a anvoy‚ ‡a ?
	move buffer_msg+4,d0
	lea buffer_msg+2*3,a0
	lea store_msg,a1
	move #8-3-1,d1
.cp:	move.w (a0)+,(a1)+
	dbf d1,.cp

	lea store_msg+(8-3)*2,a6	; pointe sur la fin de buffer r‚cep

	tst d0
	beq.s .finish
	add.w d0,a6
	save a6
	appl_read global+4,d0,a1
	load a6
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

.pasplay:	cmp.l #'conv',(a0)		; 'conv=1,name1,name2,name3'
	beq.s conversions

	bra boucle_gem_principale

conversions:lea 5(a0),a0

	cmp.b #'1',(a0)
	bne.s .pas_1
	move #%10,d1		; 0=read 1=write
	move #2,d2			; nb. de fich attendus
	lea conv_auto1,a1
	bra .open_them

.pas_1:	cmp.b #'2',(a0)
	bne.s .pas_2
	move #%110,d1		; 0=read 1=write 1=write
	move #3,d2			; nb. de fich attendus
	lea conv_auto2,a1
	bra .open_them

.pas_2:	cmp.b #'3',(a0)
	bne.s .pas_3
	move #%10,d1		; 0=read 1=write
	move #2,d2			; nb. de fich attendus
	lea conv_auto3,a1
	bra.s .open_them

.pas_3:	cmp.b #'4',(a0)
	bne.s .pas_4
	move #%0,d1			; 0=read
	move #1,d2			; nb. de fich attendus
	lea conv_auto4,a1
	bra.s .open_them

.pas_4:	cmp.b #'5',(a0)
	bne.s .pas_5
	move #%10,d1		; 0=read 1=write
	move #2,d2			; nb. de fich attendus
	lea conv_auto56,a1
	move #1,type_a_sound		; Stereo Track -> DVS
	bra.s .open_them

.pas_5:	cmp.b #'6',(a0)
	bne.s .pas_6
	move #%10,d1		; 0=read 1=write
	move #2,d2			; nb. de fich attendus
	lea conv_auto56,a1
	move.w #3,type_a_sound		; Mono Track -> DVS
	bra.s .open_them

.pas_6:	cmp.b #'7',(a0)
	bne.s .pas_7
	move #%10,d1		; 0=read 1=write
	move #2,d2			; nb. de fich attendus
	lea conv_auto7,a1
	bra.s .open_them

.pas_7:	bra boucle_gem_principale	; mauvais message ?

.open_them:	lea 2(a0),a0		; "1,"
	lea handle1,a3
	clr.l (a3)
	clr.w 4(a3)			; pour 'le close'

.redo:	move.l a0,a2
.ser:	cmp.b #',',(a2)
	beq.s .found
	addq.l #1,a2
	cmp.l a6,a2
	blt.s .ser
	bra.s .plante

.found:	clr.b (a2)+

	save d1/d2/a1/a2/a3
	btst #0,d1
	beq.s .zero
	file_open write,(a0)
	bra.s .cont
.zero:	file_open read,(a0)
.cont:	load d1/d2/a1/a2/a3
	move.w d0,(a3)+
	ble.s .plante

	move.l a2,a0
	lsr.w #1,d1
	subq #1,d2
	bgt.s .redo
	
	save a1
	bsr stop_if_running
	load a1
	jmp (a1)

.plante:	file_close handle3
	file_close handle2
	file_close handle1
	bra boucle_gem_principale

;		--------------------------------

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

	tst sample_playing
	bne no_method_change

	cmp.b #METHOD_1,d1
	bne.s pas_f1
	bsr check_method
	move.w #1,which_rout
pas_f1:	cmp.b #METHOD_2,d1
	bne.s pas_f2
	bsr check_method
	move.w #2,which_rout	; 2 & 2bis sont pour le mono 16 bits
pas_f2:	cmp.b #METHOD_3,d1
	bne.s pas_f3
	bsr check_method
	move.w #3,which_rout
pas_f3:
no_method_change:

	cmp.b #METHOD_4,d1
	bne.s pas_f4

	tst replay_in_psst
	beq.s .ze
	clr replay_in_psst
	bra.s .noze
.ze:	move #1,replay_in_psst
.noze:	move #METHOD_4,d0
	move replay_in_psst,d1
	bsr check_menu
pas_f4:

	cmp.w #INFO_MENU,d1
	bne.s .pas1
	move.w #FORM_INFOS,d0
	bsr traite_formulaire
	move.w #DESCRIPTION,d0
	bsr traite_formulaire
	bra boucle_gem_principale

.pas1:
	cmp.w #SET_PARAMETER,d1
	bne.s .pas2

	move.w #ASK_MILISECONDS,d0
	bsr traite_formulaire

	move.w #ASK_MILISECONDS,d0
	lea add_tree,a0
	bsr get_addr_tree
	move.l add_tree,a0
	move.w #VALUE_IN_MS,d0
	bsr get_text_add
	move.l a1,a2	; sauve pour tester le moins '-'
.next:	tst.b (a1)
	beq.s .pas2
	clr d0
	move.b (a1)+,d0
	cmp.b #'-',d0
	beq.s .next
	sub.b #'0',d0
	tst.b (a1)
	beq.s .stock
	mulu #10,d0
	clr d1
	move.b (a1)+,d1
	sub.b #'0',d1
	add d1,d0

.stock:	cmp.b #'-',(a2)
	bne.s .pos
	neg d0
.pos:	cmp #99,d0
	bgt.s .pas2
	cmp #-99,d0
	blt.s .pas2
	move d0,nb_ms
	bra boucle_gem_principale

.pas2:
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
	beq show_info_about_a_file	; infos sur 1 DVS


	cmp.w #CONVERSION_1,d1		; st‚r‚o -> mono
	beq conv1

	cmp.w #CONVERSION_2,d1		; st‚r‚o -> G & D
	beq conv2

	cmp.w #CONVERSION_3,d1		; mono -> st‚r‚o
	beq conv3

	cmp.w #CONVERSION_4,d1		; choose compression table
	beq choose_table

	cmp.w #CONVERSION_5,d1		; TRK st‚r‚o -> DVS
	beq conv5

	cmp.w #CONVERSION_6,d1		; TRK mono -> DVS
	beq conv6

	cmp.w #CONVERSION_7,d1		; DVS -> TRK
	beq conv7


	cmp.w #SPECIAL_ANALYSE,d1
	beq analyse_trk


	cmp.w #SPECIAL_DISTORS,d1
	beq analyse_distorsion

	bra boucle_gem_principale
************************************************************************************************
show_info_about_a_file:
	move.l #'*.DV',whato
	move.l #'S,*.',whato+4
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

	file_read #read_info_dvw,#16,handle1
	cmp.l #16,d0
	bne annn2

	lea read_info_dvw,a0
	cmp.l #'DVSM',dvs_header(a0)
	bne annn2			; raw data : pas de fr‚quence

	tst.w dvs_header+4(a0)
	bne annn2			; not supported

	move.w dvs_length(a0),length_tetos+2

	move.w #INFO_ON_FILE,d0
	lea add_tree,a0
	bsr get_addr_tree

	move.l add_tree,a0		; a0
	move.w #INFO_TITLE,d0
	bsr get_text_add		; a1
	clr.b (a1)

	move.l add_tree,a0		; a0
	move.w #INFO_AUTHOR,d0
	bsr get_text_add		; a1
	clr.b (a1)

	move.l add_tree,a0		; a0
	move.w #ADD_PACKT_YES_NO,d0
	bsr get_text_add		; a1
	move.l #'NO.'*256,(a1)

	move.l #16,d7

.view_cookies:
	file_read #scan_cookies,#6,handle1
	cmp.l #6,d0
	bne annn2

	lea scan_cookies,a0

	cmp.l #'LPKC',cookie_identify(a0)
	beq.s .lpck
	cmp.l #'PACK',cookie_identify(a0)
	beq.s .pack
	cmp.l #'TITL',cookie_identify(a0)
	beq .titl
	cmp.l #'AUTH',cookie_identify(a0)
	beq .auth

	clr.l d0
	move.w cookie_length(a0),d0
	add.w d0,d7
	subq.l #6,d0
	file_seek #1,handle1,d0

.finish_cookie:
	cmp.l length_tetos,d7
	bne.s .view_cookies
	bra .fincookies

.lpck:	file_read #read_dvs_header,#2,handle1
	cmp.l #2,d0
	bne annn2
	add.l #8,d7
	move.w read_dvs_header,store_lpckc	; 8 bit pack-code
	bra.s .finish_cookie

.pack:	file_seek #1,handle1,#256*2
	add.l #4+2+256*2,d7
	move.l add_tree,a0		; a0
	move.w #ADD_PACKT_YES_NO,d0
	bsr get_text_add		; a1
	move.l #'YES'*256,(a1)
	bra.s .finish_cookie

.titl:	move.l add_tree,a0		; a0
	move.w #INFO_TITLE,d0
	bsr get_text_add		; a1
	file_read a1,#26,handle1
	add.l #4+2+26,d7
	bra .finish_cookie

.auth:	move.l add_tree,a0		; a0
	move.w #INFO_AUTHOR,d0
	bsr get_text_add		; a1
	file_read a1,#26,handle1
	add.l #4+2+26,d7
	bra .finish_cookie

.fincookies:
	file_close handle1

	lea read_info_dvw,a6

	move.l add_tree,a0		; a0
	move.w #PACKED_YES_NO,d0
	bsr get_text_add		; a1
	move.l #'NO'*65536,(a1)
	cmp.b #2,dvs_pack(a6)		; 2=pack‚
	bne.s .no
	move.l #'YES'*256,(a1)
.no:
	move.l add_tree,a0		; a0
	move.w #LENGTH_PACK_CODE,d0
	bsr get_text_add		; a1
	clr.l d0
	move.w store_lpckc,d0
	bsr deci2

	move.l add_tree,a0		; a0
	move.w #FREQUENZ,d0
	bsr get_text_add		; a1

	move.w dvs_freq(a6),d0
	lea table_cv_freq,a0
	move.w 6(a0,d0.w*8),freq_dvw+2
	move.w 0(a0,d0.w*8),(a1)	; ex. : 8.
	clr.b 2(a1)

	; 0=st‚r‚o,1=mono
	move.l add_tree,a0		; a0
	move.w #TYPE_OF_SOUND,d0
	bsr get_text_add		; a1

	move.l taille_fich_dvw,d7
	clr.l d6
	move.w dvs_length(a6),d6
	sub.l d6,d7			; approximation … 0.03 %

	cmp.b #1,dvs_mode(a6)		; 1=st‚r‚o
	beq.s .stereo
	move.l #'mono',(a1)
	clr.b 4(a1)
	mulu.l #2,d7
	bra.s .conti
.stereo:	move.l #'ster',(a1)
	move.w #'eo',4(a1)
	clr.b 6(a1)

.conti:	tst.b dvs_pack(a6)		; 2=pack‚, 0=non pack‚
	bne.s .cool
	divu.l #2,d7
.cool:	divu.l freq_dvw,d7

same_as_before:		; le programme pour *.LT reprend ici

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
	bsr deci2

	move.l add_tree,a0		; a0
	move.w #SECONDS,d0
	bsr get_text_add		; a1
	load d7
	move.l d7,d0
	bsr deci2

	move #INFO_ON_FILE,d0
	bsr traite_formulaire

annn:	bra boucle_gem_principale
annn2:	file_close handle1
	bra.s annn
			***************
its_list_of_track:
	bsr stop_if_running		; on utilise son buffer (.LT)

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

	file_read #read_info_dvw,#16,d7
	save d0
	file_close d7
	load d0

	load a0/d1
	cmp.l #16,d0
	bne do_not_count

	lea read_info_dvw,a6
	cmp.l #'DVSM',dvs_header(a6)
	bne do_not_count
	tst.w dvs_header+4(a6)
	bne do_not_count

	clr.l d0
	move.w dvs_freq(a6),d2
	lea table_cv_freq,a1
	move.w 6(a1,d2.w*8),d0

	move.l taille_fich_dvw,d7
	clr.l d6
	move.w dvs_length(a6),d6
	sub.w d6,d7

	cmp.b #1,dvs_mode(a6)		; 1=st‚r‚o
	beq.s .stereo
	mulu.l #2,d7
.stereo:	tst.b dvs_pack(a6)		; 2=pack‚, 0=non pack‚
	bne.s .pac
	divu.l #2,d7
.pac:	divu.l d0,d7

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
	move.w #INFO_TITLE,d0
	bsr get_text_add		; a1
	lea params_it,a0
	move #26-1,d0
.rcp:	move.b (a0)+,(a1)+
	dbf d0,.rcp

	move.l add_tree,a0		; a0
	move.w #INFO_AUTHOR,d0
	bsr get_text_add		; a1
	clr.b (a1)

	move.l add_tree,a0		; a0
	move.w #ADD_PACKT_YES_NO,d0
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
	bra same_as_before

 BSS
taille_fich_dvw:	ds.l 1
length_tetos:	ds.l 1
read_info_dvw:	ds.b 16		; pour l'analyse d'un dvw
scan_cookies:	ds.b 4+2
header_dvw:		ds.l 1
freq_dvw:		ds.l 1		; fr‚quence
store_lpckc:	ds.w 1		; 8 bit pack-code … priori
 TEXT
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

conv_auto4:	file_read #table_dvswax,#256*2,handle1
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
TAILLE_BUFF_TEMP=1024*128

analyse_distorsion:
	move.l #'*.TR',whato
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

	move.l #TAILLE_BUFF_TEMP,d0
	bsr allocate_dis_memory
	bmi .annule_dist2
	move.l d0,memory_pointer

.analyse_again:
	file_read memory_pointer,#TAILLE_BUFF_TEMP/2,handle1
	cmp.l #TAILLE_BUFF_TEMP/2,d0
	bne .annule_dist3
	move.l memory_pointer,d0
	add.l #TAILLE_BUFF_TEMP/2,d0
	file_read d0,#TAILLE_BUFF_TEMP/2,handle2
	cmp.l #TAILLE_BUFF_TEMP/2,d0
	bne .annule_dist3

	move.l memory_pointer,a0
	move.l memory_pointer,a1
	add.l #TAILLE_BUFF_TEMP/2,a1
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

.annule_dist3:
	move.l memory_pointer,d0
	bsr desallocate_dis_memory
.annule_dist2:
	file_close handle2
.annule_dist1:
	file_close handle1
.annule_dist:
	bra boucle_gem_principale
	

DEMI_TAILLE=65536*2

analyse_trk:move.l #'*.TR',whato
	move.w #'K'*256,whato+4
	lea text_analyse,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq .annule_ana

	bsr stop_if_running

	lea params_it,a0
	bsr test_if_wax_info_present2
	file_open read,params_it
	move.w d0,handle1
	bmi .annule_ana
	file_seek #0,handle1,header

	move.l #DEMI_TAILLE*2,d0
	bsr allocate_dis_memory
	bmi .annule_ana2
	move.l d0,memory_pointer

.analyse_again:
	file_read memory_pointer,#DEMI_TAILLE,handle1
	cmp.l #DEMI_TAILLE,d0
	bne .annule_ana3

	move.l memory_pointer,a0
	add.l #DEMI_TAILLE,a0
	move.l #DEMI_TAILLE/4,d0
.clr:	clr.l (a0)+
	subq.l #1,d0
	bne.s .clr

	move.l memory_pointer,a0
	move.l memory_pointer,a1
	add.l #DEMI_TAILLE,a1
	move.l a1,a6		; ptr + 1/2 buufer
	move.l a1,a5
	add.l #DEMI_TAILLE,a5		; ptr fin buffer
	move.w (a0)+,d0
	ext.l d0
	move.w (a0)+,d1
	ext.l d1
.redo:	cmp.l a6,a0
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
	move.l a6,a2
.ze:	tst.w (a2)+
	beq.s .ze
	lea -2(a2),a2
	sub.l a6,a2
	move.l a2,d0
	lsr.l #1,d0
	bsr deci2

	move.w #ABS_MAX_DELTA,d0
	bsr get_text_add		; a1
	move.l a5,a2
.ze0:	tst.w -(a2)
	beq.s .ze0
	sub.l a6,a2
	move.l a2,d0
	lsr.l #1,d0
	bsr deci2

	move.w #AVERAGE_DELTA,d0
	bsr get_text_add
	move.l a6,a2
	fmove.w #0,fp0		; index
	fmove.w #0,fp2		; somme
	clr.l d0

.redoo:	cmp.l a5,a2
	beq.s .f
	move.w (a2)+,d0		; jusqu'… 65535
	fmove.l d0,fp1
	fmul.x fp0,fp1
	fadd.x fp1,fp2
	fadd.x #1,fp0
	bra.s .redoo
.f:	fmove.l #DEMI_TAILLE/2,fp0	; nombre d'‚chantillons trait‚
	fdiv.x fp0,fp2
	fmove.l fp2,d0
	bsr deci2

	move.w #DELTA_VARIANCE,d0
	bsr get_text_add
	move.l a6,a2
	;fp2: moyenne
	fmove.w #0,fp0		; index (delta 0 -> 65535)
	fmove.w #0,fp3		; somme des carr‚s
	clr.l d0

.redooo:	cmp.l a5,a2
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
.ff:	fmove.l #DEMI_TAILLE/2,fp0	; nombre d'‚chantillons trait‚s
	fdiv.x fp0,fp3
	fsqrt.x fp3
	fmove.l fp3,d0
	bsr deci2

	move #ANALYSE,d0
	bsr traite_formulaire

	cmp.w #MORE,d0
	beq .analyse_again

.annule_ana3:
	move.l memory_pointer,d0
	bsr desallocate_dis_memory

.annule_ana2:
	file_close handle1

.annule_ana:bra boucle_gem_principale
	
		********** Conversions ************

conv1:	move.l #'*.TR',whato		; st‚r‚o -> Mono
	move.w #'K'*256,whato+4
	lea text_mono1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule11

	bsr stop_if_running

	file_open read,params_it
	move.w d0,handle1
	bmi annule11

	lea text_mono2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule12

	file_open write,params_it
	move.w d0,handle2
	bmi annule12

conv_auto1:	move.l #TAILLE_BUFF_TEMP,d0
	bsr allocate_dis_memory
	bmi annule13
	move.l d0,memory_pointer

.all_file:	file_read memory_pointer,#TAILLE_BUFF_TEMP/2,handle1
	tst.l d0
	beq.s annule14

	lsr.l #1,d0		; /2
	move.l d0,d7
	lsr.l #1,d0		; /2 : combien de fois (1.w+1.w)=4 octets ?

	move.l memory_pointer,a0
	move.l memory_pointer,a1
	add.l #TAILLE_BUFF_TEMP/2,a1

.mono:	move.w (a0)+,d1	; 4 par 4
	ext.l d1
	move.w (a0)+,d2
	ext.l d2
	add.l d2,d1
	asr.l #1,d1
	move.w d1,(a1)+
	subq.l #1,d0
	bgt.s .mono

	move.l memory_pointer,d0
	add.l #TAILLE_BUFF_TEMP/2,d0
	file_write d0,d7,handle2
	cmp.l d7,d0			; ‚crit OK ?
	bne.s annule14
	cmp.l #TAILLE_BUFF_TEMP/2/2,d7
	beq.s .all_file

annule14:	move.l memory_pointer,d0
	bsr desallocate_dis_memory

annule13:	file_close handle2

annule12:	file_close handle1

annule11:	bra boucle_gem_principale

	; ------------

conv2:	move.l #'*.TR',whato		; Left/Right -> Left + Right
	move.w #'K'*256,whato+4
	lea text_two1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule21

	bsr stop_if_running

	file_open read,params_it
	move.w d0,handle1
	bmi annule21

	lea text_two2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule22

	file_open write,params_it
	move.w d0,handle2
	bmi annule22

	lea text_two3,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule23

	file_open write,params_it
	move.w d0,handle3
	bmi annule23

conv_auto2:	move.l #TAILLE_BUFF_TEMP,d0
	bsr allocate_dis_memory
	bmi annule24
	move.l d0,memory_pointer

.all_file:	file_read memory_pointer,#TAILLE_BUFF_TEMP/2,handle1
	tst.l d0
	beq.s annule25

	lsr.l #1,d0		; /2
	move.l d0,d7
	lsr.l #1,d0		; /2

	move.l memory_pointer,a0
	move.l a0,a1
	add.l #TAILLE_BUFF_TEMP/2,a1
	move.l a0,a2
	add.l #TAILLE_BUFF_TEMP*3/4,a2

.mono:	move.w (a0)+,(a1)+	; 4 par 4
	move.w (a0)+,(a2)+
	subq.l #1,d0
	bgt.s .mono

	move.l memory_pointer,d0
	add.l #TAILLE_BUFF_TEMP/2,d0
	file_write d0,d7,handle2
	cmp.l d7,d0			; ‚crit OK ?
	bne.s annule25
	move.l memory_pointer,d0
	add.l #TAILLE_BUFF_TEMP*3/4,d0
	file_write d0,d7,handle3
	cmp.l d7,d0			; ‚crit OK ?
	bne.s annule25
	cmp.l #TAILLE_BUFF_TEMP/2/2,d7
	beq .all_file

annule25:	move.l memory_pointer,d0
	bsr desallocate_dis_memory

annule24:	file_close handle3
annule23:	file_close handle2
annule22:	file_close handle1

annule21:	bra boucle_gem_principale

	; ------------

conv3:	move.l #'*.TR',whato		; Mono -> St‚r‚o
	move.w #'K'*256,whato+4
	lea text_stereo1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule31

	bsr stop_if_running

	file_open read,params_it
	move.w d0,handle1
	bmi annule31

	lea text_stereo2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule32

	file_open write,params_it
	move.w d0,handle2
	bmi annule32

conv_auto3:	move.l #TAILLE_BUFF_TEMP,d0
	bsr allocate_dis_memory
	bmi annule33
	move.l d0,memory_pointer

.all_file:	file_read memory_pointer,#TAILLE_BUFF_TEMP/2/2,handle1
	tst.l d0
	beq.s annule34

	move.l d0,d7
	lsr.l #1,d0		; /2
	lsl.l #1,d7		; *2

	move.l memory_pointer,a0
	move.l a0,a1
	add.l #TAILLE_BUFF_TEMP/2,a1

.mono:	move.w (a0)+,d1	; 2 par 2
	move.w d1,(a1)+
	move.w d1,(a1)+
	subq.l #1,d0
	bgt.s .mono

	move.l memory_pointer,d0
	add.l #TAILLE_BUFF_TEMP/2,d0
	file_write d0,d7,handle2
	cmp.l d7,d0			; ‚crit OK ?
	bne.s annule34
	cmp.l #TAILLE_BUFF_TEMP/2,d7
	beq.s .all_file

annule34:	move.l memory_pointer,d0
	bsr desallocate_dis_memory

annule33:	file_close handle2
annule32:	file_close handle1

annule31:	bra boucle_gem_principale

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
	move.w #3,type_a_sound	; Mono Track -> DVS
	bra.s conv6b

	; ------------

conv5:	bsr stop_if_running
	move #1,type_a_sound	; Stereo Track -> DVS

conv6b:	move.l #'*.TR',whato
	move.w #'K'*256,whato+4
	lea text_dvsw1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule561

	file_open read,params_it	; open read
	move.w d0,handle1
	bmi annule561

	move.l #'*.DV',whato
	move.w #'S'*256,whato+4
	lea text_dvsw2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule562

	file_open write,params_it	; open write
	move.w d0,handle2
	bmi annule562

	move #ASK_TITLE_NAME,d0
	bsr traite_formulaire

conv_auto56:
	; 2+2+packed data(TAILLE_MAGIC) / read data (2*TAILLE_MAGIC)
	move.l #TAILLE_MAGIC*3+4,d0	; r‚serve m‚moire
	bsr allocate_dis_memory		; +2 si mono mais pas grave
	bmi annule564
	move.l d0,memory_pointer

	lea write_info_dvw,a0
	move.l #'DVSM',dvs_header(a0)
	move.w #0,dvs_header+4(a0)

	move.w #16+8+8+32+32+(4+2+256*2),dvs_length(a0)	; .w

	lea table_cv_freq,a1
	clr d0
	move.b frequency_for_play,d0
.find:	cmp.w 2(a1),d0
	beq.s .found
	lea 8(a1),a1
	bra.s .find
.found:	sub.l #table_cv_freq,a1
	move.l a1,d0
	lsr.l #3,d0
	move.w d0,dvs_freq(a0)

	move.b #2,dvs_pack(a0)
	move.b type_a_sound+1,dvs_mode(a0)

	move.l memory_pointer,a1
	cmp #1,type_a_sound
	bne.s .mono0
	move.l #TAILLE_MAGIC+4,d0	; st‚r‚o
	move.l #4,how_many_1st_values
	bra.s .go_on
.mono0:	move.l #TAILLE_MAGIC+2,d0
	move.l #2,how_many_1st_values
.go_on:	add.l d0,a1
	move.l a1,pointer_read_data
	move.l d0,dvs_block_length(a0)

	lea 16(a0),a0

	move.l #'LPKC',(a0)+
	move.w #8,(a0)+
	move.w #8,(a0)+		; 8-bit pack code

	move.l #'CLCK',(a0)+
	move.w #8,(a0)+
	move.w #0,(a0)+		; Clock Interne

	move.l #'TITL',(a0)+		; Titre : 4+2+26=32
	move.w #32,(a0)+
	save a0
	move.w #ASK_TITLE_NAME,d0
	lea add_tree,a0
	bsr get_addr_tree
	move.l add_tree,a0
	move.w #ASKED_TITLE,d0
	bsr get_text_add
	load a0
	move #26-1,d0
.rcp1:	move.b (a1)+,(a0)+
	dbf d0,.rcp1

	move.l #'AUTH',(a0)+		; Author : 4+2+26=32
	move.w #32,(a0)+
	save a0
	move.w #ASK_TITLE_NAME,d0
	lea add_tree,a0
	bsr get_addr_tree
	move.l add_tree,a0
	move.w #ASKED_AUTHOR,d0
	bsr get_text_add
	load a0
	move #26-1,d0
.rcp2:	move.b (a1)+,(a0)+
	dbf d0,.rcp2

	move.l #'PACK',(a0)+
	move.w #4+2+256*2,(a0)+

	sub.l #write_info_dvw,a0
	save a0
	file_write #write_info_dvw,a0,handle2
	load a0
	cmp.l d0,a0			; 16+8+8+32+32+4+2
	bne annule564

	file_write #table_dvswax,#256*2,handle2
	cmp.l #256*2,d0
	bne annule564

boucle_pack:
	move.w  #-1,-(sp)	; Shift_Droit:1, SG:2 CTRL:4 ALT:8
	appel bios,11,4	; ‚tat des touches sp‚ciales
	and.w #3,d0
	cmp.w #3,d0
	beq annule564	; d6 d7 INTACTS

	clr d0
	bset #EVNT_MESAG,d0
	bset #EVNT_TIMER,d0
	move #1,d1			; timer en ms
	bsr traite_evenement_gem

	btst #EVNT_MESAG,d0
	beq.s .no_message

	neg d1
	cmp.w #ACC_CLOSE,d1		; ACC_CLOSE
	beq annule564
	cmp.w #AP_TERM,d1		; AP_TERM
	beq fin

.no_message:file_read #read_first_values,how_many_1st_values,handle1
	cmp.l how_many_1st_values,d0
	bne annule564

	move.l #(TAILLE_MAGIC+4)/4-1,d0	; r‚serve m‚moire
	move.l memory_pointer,a0
.clr:	clr.l (a0)+
	dbf d0,.clr

	move.l memory_pointer,a0
	move.w read_first_values,d6
	move.w d6,(a0)+
	ext.l d6
	cmp.l #4,how_many_1st_values
	bne.s .mono1
	move.w read_first_values+2,d7
	move.w d7,(a0)+
	ext.l d7
.mono1:

	save a0
	file_read pointer_read_data,#TAILLE_MAGIC*2,handle1
	load a1
	move.l d0,d5
	beq annule565		; ‚crit les 2 ou 4 -> sort
	move.l pointer_read_data,a0	; a1 pointe sur destination
	lea table_dvswax+128*2,a2

	cmp.l #4,how_many_1st_values
	bne.s .mono2

.stereo2:	treat d6
	treat d7
	subq.l #4,d0	; si mono et non multiple de 4 : bug
	bgt.s .stereo2
	bra.s .finis

.mono2:	treat d6
	subq.l #2,d0
	bgt.s .mono2
.finis:

annule565:	lsr.l #1,d5
	add.l how_many_1st_values,d5
	save d5
	file_write memory_pointer,d5,handle2
	load d1
	cmp.l d0,d1
	bne.s annule564		; plus de place sur disque
	move.l #TAILLE_MAGIC,d0
	add.l how_many_1st_values,d0
	cmp.l d0,d1
	beq boucle_pack		; fin du fichier en lecture

annule564:	move.l memory_pointer,d0
	bsr desallocate_dis_memory

annule563:	file_close handle2
annule562:	file_close handle1

annule561:	bra boucle_gem_principale

 BSS
write_info_dvw:	ds.b 16+8+8+32+32+4+2
read_first_values:	ds.w 2
how_many_1st_values:	ds.l 1
type_a_sound:	ds.w 1
pointer_read_data:	ds.l 1	; pointe sur l'endroit ou charger les datas … packer
 TEXT

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

	; ------------

conv7:	move.l #'*.DV',whato		; DVSW -> Track
	move.w #'S'*256,whato+4
	lea text_dvsw3,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule71

	bsr stop_if_running

	file_open read,params_it
	move.w d0,handle1
	bmi annule71

	move.l #'*.TR',whato
	move.w #'K'*256,whato+4
	lea text_dvsw4,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule72

	file_open write,params_it
	move.w d0,handle2
	bmi annule72

conv_auto7:	file_read #read_dvs_header,#16,handle1
	cmp.l #16,d0
	bne annule73

	lea read_dvs_header,a0

	cmp.l #'DVSM',dvs_header(a0)
	bne annule73
	tst.w dvs_header+4(a0)
	bne annule73
	move.w dvs_length(a0),length_2_zap+2
	move.w dvs_freq(a0),frequency_dvs
	cmp.b #2,dvs_pack(a0)		; 2=pack‚
	bne annule73

	move.b dvs_mode(a0),d0
	cmp.b #1,d0
	bne.s .pas_st
	move.l #4,hmany_1st_bytes
	bra.s .cont
.pas_st:	cmp.b #3,d0
	bne annule73
	move.l #2,hmany_1st_bytes	; mono
.cont:
	move.l dvs_block_length(a0),which_blk_length

	lea table_dvsm,a0	; table DVSM par d‚faut
	lea table_depack,a1
	move #256-1,d0
.copy:	move.w (a0)+,(a1)+
	dbf d0,.copy

	move.l #16,d7

.view_cookies:
	file_read #read_dvs_header,#6,handle1
	cmp.l #6,d0
	bne annule73

	lea read_dvs_header,a0

	cmp.l #'LPKC',cookie_identify(a0)
	beq.s .lpck
	cmp.l #'PACK',cookie_identify(a0)
	beq.s .pack

	clr.l d0
	move.w cookie_length(a0),d0
	add.w d0,d7
	subq.l #6,d0
	file_seek #1,handle1,d0

.finish_cookie:
	cmp.l length_2_zap,d7
	bne.s .view_cookies
	bra.s .fincookies

.lpck:	file_read #read_dvs_header,#2,handle1
	cmp.l #2,d0
	bne annule73
	add.l #8,d7
	cmp.w #8,read_dvs_header	; 8 bit pack-code
	beq.s .finish_cookie
	bra annule73

.pack:	file_read #table_depack,#256*2,handle1
	cmp.l #256*2,d0
	bne annule73
	add.l #4+2+256*2,d7
	bra.s .finish_cookie

.fincookies:file_seek #0,handle1,length_2_zap	; pour ˆtre sur

	move.l which_blk_length,d0
	mulu.l #3,d0		; petite approximation
	bsr allocate_dis_memory		; +2 si mono mais pas grave
	bmi annule73
	move.l d0,memory_pointer
	add.l which_blk_length,d0
	move.l d0,ad_pointeur_depack

depack_routine:
	file_read memory_pointer,which_blk_length,handle1
	move.l d0,d5
	beq annule74

	move.l memory_pointer,a0
	move.l ad_pointeur_depack,a1
	lea table_depack+128*2,a2
	move.w (a0)+,d6
	move.w d6,(a1)+
	sub.l #2,d5
	cmp.l #4,hmany_1st_bytes
	bne.s .mono1

	move.w (a0)+,d7		; depack st‚r‚o
	move.w d7,(a1)+
	sub.l #2,d5
	beq.s annule75

	move.l d5,d0

.dpck_ste:	move.b (a0)+,d1
	ext.w d1
	add.w (a2,d1.w*2),d6
	move.w d6,(a1)+

	move.b (a0)+,d1
	ext.w d1
	add.w (a2,d1.w*2),d7
	move.w d7,(a1)+

	subq.l #2,d0
	bgt.s .dpck_ste
	bra.s .finis

.mono1:	move.l d5,d0
	beq.s annule75

.dpck_mono:	move.b (a0)+,d1
	ext.w d1
	add.w (a2,d1.w*2),d6
	move.w d6,(a1)+

	subq.l #1,d0
	bgt.s .dpck_mono
.finis:

annule75:	lsl.l #1,d5
	add.l hmany_1st_bytes,d5
	save d5
	file_write ad_pointeur_depack,d5,handle2
	load d1
	cmp.l d0,d1			; ‚crit OK ?
	bne.s annule74
	move.l which_blk_length,d1
	sub.l hmany_1st_bytes,d1
	lsl.l #1,d1
	add.l hmany_1st_bytes,d1
	cmp.l d0,d1
	beq depack_routine

annule74:	move.l memory_pointer,d0
	bsr desallocate_dis_memory

annule73:	file_close handle2
annule72:	file_close handle1

annule71:	bra boucle_gem_principale

 BSS
ad_pointeur_depack:	ds.l 1
hmany_1st_bytes:	ds.l 1	; 2=mono, 4=stereo
length_2_zap:	ds.l 1
which_blk_length:	ds.l 1
frequency_dvs:	ds.w 1
read_dvs_header:	ds.b 16
table_depack:	ds.w 256
 TEXT

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
	move.l #'DVS,',whato+8		; *.TRK,*.DVS,*.LT 0
	move.l #'*.LT',whato+12
	move.b #0,whato+16
	bra.s .zap
.no_trix3:	move.w #'K'*256,whato+4
.zap:
	lea texte_fsel,a0		; 35 chars max.
	bsr copy_in2_select
	clr.b return_more_names		; s'il choisi 14 seul fichier
	bsr fileselect
	cmp.w #1,d4
	bne.s f_i_n

	tst.l sltr_adress
	beq.s .no_trix2
	tst.b return_more_names
	beq.s .no_trix2		; aucune s‚lection multiple (*.S par ex)
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
	bmi.s error_occured_at_init
	bsr play_d2d

f_i_n:	bra boucle_gem_principale

		******

error_occured_at_init:
	move #SOUND_SEMAPHORE,d0

	cmp #NOT_ENOUGH_MEMORY,d7
	bne.s .pas1
	move #MEMORY_PROBLEM,d0
	bra.s .aff

.pas1:	cmp #BAD_DVW_HEADER,d7
	bne.s .aff
	move #BAD_DVS_HEADER,d0

.aff:	bsr traite_formulaire

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
	;move.w #1,which_rout	; routine par d‚faut: ne pas changer
	clr.l header	; si jamais le .WAX n'existe pas
	;move #1,replay_in_psst	; il faut garder les prefs en cours
	;move #20,nb_ms

	lea name_for_wax,a1	; met un .WAX … la fin du nom
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

	move #1,wax_info_present
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
	bra redox

.pasfreq:	cmp.l #'form',(a0)		; Format
	bne.s .pasform
	lea 5(a0),a0		; aprŠs le =

	cmp.l #'16bs',(a0)
	bne.s .pa16bs
	move.w #1,d0
	move #METHOD_1,d1
	bra.s .set_it
.pa16bs:	cmp.l #'16bm',(a0)
	bne.s .pa16bm
	move.w #2,d0
	move #METHOD_2,d1
	bra.s .set_it
.pa16bm:	cmp.l #'dvsm',(a0)
	bne redox
	move.w #3,d0
	move #METHOD_3,d1
.set_it:	move.w d0,which_rout
	save a0/a1
	bsr check_method
	load a0/a1
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
	bra redox

.pashead:	cmp.l #'dlay',(a0)		; Delay in ms
	bne.s .pasdlay
	lea 5(a0),a0		; aprŠs le =

	clr.l d1
	move.l a0,a2
.redoo:	clr d0
	move.b (a0)+,d0
	cmp.b #'-',d0
	beq.s .redoo
	cmp.b #'0',d0
	blt.s .finihedd
	cmp.b #'9',d0
	bgt.s .finihedd
	mulu.l #10,d1
	sub.b #'0',d0
	ext.l d0
	add.l d0,d1
	bra.s .redoo

.finihedd:	cmp.b #'-',(a2)
	bne.s .pos
	neg d1
.pos:	cmp.w #99,d1
	bgt.s .passtk
	cmp.w #-99,d1
	blt.s .passtk
	move.w d1,nb_ms
.passtk:	bra redox

.pasdlay:	cmp.l #'ster',(a0)		; Replay in ps-st if possible
	bne.s .passter
	lea 5(a0),a0		; aprŠs le =

	clr replay_in_psst
	cmp.l #'YES.',(a0)
	bne.s .past
	move #1,replay_in_psst
.past:	move #METHOD_4,d0
	move replay_in_psst,d1
	save a0/a1
	bsr check_menu
	load a0/a1

	bra redox

.passter:
	lea 1(a0),a0
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
TAILLE_MAGIC=5*6*7*8*2	; multiple de 5...8=3360 (1/10 s … 33KHz mono pack‚)
NBR_BUFF=4		; attention nombre minimal : 4 (pour conversions)!!
LENGTH_REPLAY=TAILLE_MAGIC*32	; 107520 octets

	include mod_dpro.s

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
text_dvsw2:		dc.b 'Destination file (16-bit DVS):',0
text_dvsw3:		dc.b 'Source file (16-bit DVS):',0
text_dvsw4:		dc.b 'Destination 16-bit TRK file :',0

text_analyse:	dc.b 'Select stereo file to analyse :',0
text_dist1:		dc.b 'Select first Track (TRK no header):',0
text_dist2:		dc.b 'Select track to compare to :',0
text_table:		dc.b 'Choose a 256*2 bytes table :',0
alert_table:	dc.b "[3][There is a|problem with|your table !|setting default][OK]",0
text_infodvw:	dc.b 'Choose DVS file to get info about :',0

*alert_accclose:	dc.b "[3][I've received an|ACC_CLOSE event,|shall I close|or continue to play ?][CONTINUE|STOP]",0
 even

original_table_dvswax:
	incbin dvswax2.tab

conversion:	dc.w $1709,FILES_INFO
	dc.w $1e11,FILES_QUIT
*	dc.w $260c,FILES_LOAD		; ^L
	dc.w $180f,FILES_LOAD		; ^O
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
	ifeq WHO*(WHO-1)
	dc.b 'd:\assemble\sources.wax\direct4d.pro\wd2d_pro.rsc',0
	endc
	ifeq (WHO-2)
	dc.b 'd:\devpac\source\genuwax\direct4d\wd2d_pro.rsc',0
	endc

texte_fsel:	dc.b 'Select a 16-bit track :',0

string_acc:	dc.b '  Wax Direct Player  ',0
 even

	section BSS
handle1:		ds.w 1
handle2:		ds.w 1
handle3:		ds.w 1		; ils doivent se suivre
memory_pointer:	ds.l 1		; pour toutes les conversions

previous_check1:	ds.w 1		; frequency
previous_check2:	ds.w 1		; what method

wax_info_present:	ds.w 1
name_for_wax:	ds.b 256
table_dvswax:	ds.w 256		; table qui sert pour packer

play_list_ptr:	ds.l 1		; pour la liste .LT
list_of_tracks:	ds.b 4096		; sert pour info & replay

are_there_more:	ds.l 1		; pour s‚lectrix
return_more_names:	ds.b (8+1+3+1)*256

acc_number:		ds.w 1		; ne sert … rien ... … priori
store_msg:		ds.b 256		; pour les messages envoy‚s par appl.

	rsreset
dvs_header:		rs.b 6	; DVSM\0\0
dvs_length:		rs.w 1	; distance of the sound data from the start of the file.
dvs_freq:		rs.w 1	; 0-7 : allowed CODEC frequencies (0: 8kHz ...  7: 49kHz)
dvs_pack:		rs.b 1	; 0=not packed,2=DVS pack,4=voice pack
dvs_mode:		rs.b 1	; 0=st‚r‚o 8bit / 1=st‚r‚o 16 bit / 2=mono 8bit / 3=mono 16 bit
dvs_block_length:	rs.l 1

	rsreset
cookie_identify:	rs.l 1
cookie_length:	rs.w 1
cookie_data:

	END

cookie	Lenght of the data	Usage
-----------------------------------------------------------------------------------------
'LPKC'	1 word		length of pack code in bits (8 -> 1)

'TITL'	26 bytes		Title of the song

'AUTH'	26 bytes		Author of the song

'CLCK'	1 word 		0: intern clock, 1: extern CD, 2: extern DAT

'PEAK'	4 byte		one word for the left and right channel containing the
			highest sample value

'DSPE'	x bytes		DSP program (soundeffect !!) in binary format

'PARA'	x bytes		x parameters for the sound effect. NOT before the 'DSPE'
			block!

'PACK'	128 or 8 bytes	Deltapack table for the distance values. Used instead of
			the standard table (see below).

'INFO'	x bytes		info text (e.g. full title)

Not use in WinRec (by now)

'KARA'	x Bytes		karaoke text (see below)


The maximal header length (all blocks together) is limited to 65535 Bytes.
Every programm should parse the blocks, and decide to use them or not.

karaoke text format
-------------------
	long cookie='KARA'
	int len
	int textlen

followed by the text ('textlen' bytes) in standard ASCII format. After this the extension included
a measure table, with a long word (4 byte) for every word in the text. The long word contains
the time distance to the next word in 1/sampling frequency

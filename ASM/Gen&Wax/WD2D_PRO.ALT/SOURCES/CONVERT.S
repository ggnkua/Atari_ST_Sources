***************************************************************************
* Sous-module du Wax D2D Pro * Routs Conversions de formats * 02/XII 1994 *
***************************************************************************

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
	; ------------

conv8:	move.l #'*.AV',whato		; AVR -> Track
	move.w #'R'*256,whato+4
	lea text_avr1,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule81

	bsr stop_if_running

	file_open read,params_it
	move.w d0,handle1
	bmi annule81

	move.l #'*.TR',whato
	move.w #'K'*256,whato+4
	lea text_avr2,a0
	bsr copy_in2_select
	bsr fileselect
	tst d4
	beq annule82

	file_open write,params_it
	move.w d0,handle2
	bmi annule82

conv_auto8:	move.l #TAILLE_BUFF_TEMP*3,d0
	bsr allocate_dis_memory
	bmi annule83

	move.l d0,memory_pointer

	file_read #read_avr_header,#128,handle1
	cmp.l #128,d0
	bne annule84

	lea read_avr_header,a0

	cmp.l #'2BIT',(a0)		; offset : 0
	bne annule84

	move.w 12(a0),d5		; 0=mono,1=st‚r‚o (sert … rien)
	move.w 14(a0),d6		; 8,12,16 bits
	move.w 16(a0),d7		; 0=non sign‚, 1=sign‚
	move.l #16,d4
	sub.w d6,d4			; nombre de d‚calages … faire

.redo:	save d4-d7
	file_read memory_pointer,#TAILLE_BUFF_TEMP,handle1
	load d4-d7
	move.l d0,d3
	beq annule84
	move.l d0,d2

	move.l memory_pointer,a0
	move.l a0,a1
	add.l #TAILLE_BUFF_TEMP,a1

	cmp.w #8,d6
	ble.s .less8

.redo1:	move.w (a0)+,d1
	lsl.w d4,d1
	tst d7
	bmi.s .signe1
	sub.w #16384,d1
.signe1:	move.w d1,(a1)+
	sub.l #2,d0
	bne.s .redo1
	bra.s .sauve

.less8:	lsl.l #1,d3

.redo2:	move.b (a0)+,d1
	lsl.w d4,d1
	tst d7
	bmi.s .signe2
	sub.w #16384,d1
.signe2:	move.w d1,(a1)+
	sub.l #1,d0
	bne.s .redo2

.sauve:	move.l memory_pointer,a0
	add.l #TAILLE_BUFF_TEMP,a0
	save d2-d7
	file_write a0,d3,handle2
	load d2-d7

	cmp.l d3,d0			; ‚crit ce qui se devait ?
	bne.s annule84

	cmp.l #TAILLE_BUFF_TEMP,d2	; fin fichier ?
	beq .redo

annule84:	move.l memory_pointer,d0
	bsr desallocate_dis_memory

annule83:	file_close handle2
annule82:	file_close handle1

annule81:	bra boucle_gem_principale

 BSS
read_avr_header:	ds.b 128
 TEXT

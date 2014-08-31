;	bsr init_d2d
;	bsr play_d2d
;
;check:	bsr check_d2d_load
;	bra check
;
;	bsr stop_d2d	(inutile car on restore)
;	bsr restore_d2d

********************************************************************************
* Module Direct to Disk avec prise de retard & d‚compactage * (c) Wax 13/XI/94 *
********************************************************************************
;TAILLE_MAGIC=5*6*7*8*2
;NBR_BUFF=4
;LENGTH_REPLAY=TAILLE_MAGIC*32

	;clr which_clock		; interne
	;clr loop			; pas de loop
	;clr replay_in_psst
	;move #20,nb_ms		; 20 ms ps-st

	; pour TRACK 16 bit
	;move.w #1,which_rout		; 1 ou 2
	;move.b #FREQ8,frequency_for_play
	;clr.l header		; pas de header

	; pour DVSW
	;move.w #3,which_rout		; routine par d‚faut


* Decompact=1 : ‚chantillon 16-bit st‚r‚o
* Decompact=2 : l'‚chantillon est jou‚ comme ‚tant mono-16 bits
* Decompact=2b: la meme chose avec retard x ms de a droite/gauche
* Decompact=3 : D‚compression DVS WAX D2D

; return errors
SEMAPHORE_LOCKED=-1
BAD_FILENAME=-2
BAD_DVW_HEADER=-3
NOT_ENOUGH_MEMORY=-4

allocate_dis_memory:
	move.w #0,-(sp)	; 0=ST, 1=TT, 2=ST->TT, 3=TT->ST
	move.l d0,-(sp)	; d0 = longueur to malloc
	appel dos,$44,8	; xmalloc
	clr d7
	tst.l d0
	bgt.s .ok
	moveq #NOT_ENOUGH_MEMORY,d7
.ok:	tst d7
	rts

desallocate_dis_memory:
	move.l d0,-(sp)
	appel dos,$49,6		; Mfree
	rts

init_d2d:	appel xbios,128,2		; sound lock
	moveq #SEMAPHORE_LOCKED,d7
	tst d0
	bpl.s not_locked
	rts

not_locked:
	file_open read,name_2_load	; ouverture du fichier
	moveq #BAD_FILENAME,d7
	tst d0
	ble erraru
	move.w d0,save_handle		; save handle

	clr end_of_file

	move.l #NBR_BUFF*LENGTH_REPLAY,d0
	bsr allocate_dis_memory
	bmi erraru2
	move.l d0,ad_main_buffer

	move.w which_rout,d0
	sub #1,d0
	mulu #4*3,d0
	lea table_routs,a0
	jsr ([a0,d0.w])		; init_routs
	tst d7
	bmi erraru3

	bsr load_first_buffs
	tst d7
	bmi erraru2

	bsr stop_timer_a

	bsr set_swap_buffs		; calcule les ad.
	bsr config_dma_replay		; init hard du DMA

	move #-1,semaphore		; init du s‚maphore
	move #1,semaphore_2		; init du s‚maphore 2

	move.l ad_main_buffer,a0
	add.l #LENGTH_REPLAY,a0
	move.l a0,-(sp)		; fin
	sub.l #LENGTH_REPLAY,a0
	move.l a0,-(sp)		; d‚but
	clr.w -(sp)
	appel xbios,131,12		; set dma replay buf
;	bsr set_dma_play_buff_ad	; adresse … jouer

	bsr set_timer_a		; routine timer A
	bsr start_timer_a

	clr d7
	rts

play_d2d:	move.w #%00000011,-(sp)
	appel xbios,136,4
	;move.b #%0x00xx11,$ffff8901	; DMA ctrl register
	move #1,sample_playing
	rts

stop_d2d:	move.w #%00000000,-(sp)
	appel xbios,136,4
	;move.b #%00000000,$ffff8901	; on arrete
	rts

restore_d2d:bsr stop_d2d

	move.w which_rout,d0
	sub #1,d0
	mulu #4*3,d0
	lea table_routs,a0
	jsr ([a0,d0.w,8])		; end_routs

	bsr restore_timera

erraru3:	move.l ad_main_buffer,d0
	bsr desallocate_dis_memory

erraru2:	file_close save_handle

erraru:	appel xbios,129,2		; sound unlock
	rts
****************************************************************************
check_d2d_load:
	tst semaphore
	ble nothing_2load

	save d0-a6
check_another:
	tst end_of_file	; si fin de fichier : revenir
	bne must_load0

.redo:	move semaphore,d0
	beq that_was_last

	cmp.w #NBR_BUFF,d0
	blt.s .rattrapable
	sub.w #NBR_BUFF,semaphore
	bra.s .redo			; on a boucl‚ : tant pis ...
.rattrapable:

	; il faut charger le plus ancien qd on a du retard
	; i.e. : le dernier (fini de jou‚ … l'instant si semaphore=1)

loadsome0:	move.l ptr_d2d_load+4*(NBR_BUFF-1),a0	; d‚but
	move.l #LENGTH_REPLAY,d0

	move.w which_rout,d1
	sub #1,d1
	mulu #4*3,d1
	lea table_routs,a1
	jsr ([a1,d1.w,4])		; load_routs

	lea ptr_d2d_load,a0
	move.l (a0),d0
	REPT NBR_BUFF-1
	move.l 4(a0),(a0)+		; swapping des adresses des buffers
	ENDR
	move.l d0,ptr_d2d_load+4*(NBR_BUFF-1)
*	move.l d0,(a0)

	tst end_of_file
	bne.s must_load0

	sub.w #1,semaphore
	bra check_another	; de tout rattraper sans gŠner Mr DMA

that_was_last:
	load d0-a6
nothing_2load:
	rts

	; dans le cas ou la fin de fichier est atteinte, il faut
	; charger tout buffer de retard avec des 000 mais pas
	; d‚cr‚menter le s‚maphore

must_load0:	move semaphore,d0
	ble.s that_was_last

	cmp semaphore_2,d0
	ble.s that_was_last

	add #1,semaphore_2
	bra loadsome0

****************************************************************************
load_first_buffs:

	move #NBR_BUFF-1,d1
	move.l ad_main_buffer,a0
	move.l #LENGTH_REPLAY,d0	; on charge la totalit‚

.load_all:
	save d0/d1/a0
	move.w which_rout,d1
	sub #1,d1
	mulu #4*3,d1
	lea table_routs,a1
	jsr ([a1,d1.w,4])		; load_routs
	load d0/d1/a0
	add.l #LENGTH_REPLAY,a0
	dbf d1,.load_all

	clr d7
	rts
		****************************

		; au d‚part on met le 1 … jouer
		; dŠs le d‚but une inter arrive
		; et le deux est mis en attente
		; on a donc le troisiŠme en tˆte
		; le prochain en fin et le courant en fin-1
set_swap_buffs:
	move.l ad_main_buffer,a0
	lea ptr_d2d_load,a1
	lea ptr_d2d_inter,a2
	move.l a0,4*(NBR_BUFF-1)(a1)	; on le joue (1)
	move.l a0,4*(NBR_BUFF-1)(a2)

	move #NBR_BUFF-1-1,d0		; ordre
.calc_swap:	add.l #LENGTH_REPLAY,a0		; 2.3.4.5.6.7.8.1
	move.l a0,(a1)+
	move.l a0,(a2)+
	dbf d0,.calc_swap
	rts

	BSS
ptr_d2d_load:ds.l NBR_BUFF
.safe1:	ds.l 2
ptr_d2d_inter:ds.l NBR_BUFF
.safe2:	ds.l 2
	TEXT
			******
config_dma_replay:
	move.w #2,-(sp)
	move.w #4,-(sp)
	appel xbios,130,6

	move.w #1,-(sp)
	appel xbios,132,4
	;move.b #%01xxxx00,$ffff8921	; sound mode ctrl : 16 bit/st‚r‚o

	move.w #0,-(sp)		; rec-trk
	move.w #0,-(sp)		; nr of play-trk
	appel xbios,133,6
	;move.b #%xx00xx00,$ffff8920 	; DAC -> Track 0, Play 1 trk

	move.w #1,-(sp)		; play
	move.w #0,-(sp)		; timera
	appel xbios,135,6
	;move.b #%00000100,$ffff8900	; buffer interrupts timer A at end

	move.w #1,-(sp)		; no hand shaking
	clr d0
	move.b frequency_for_play,d0
	move.w d0,-(sp)
	move.w which_clock,-(sp)	; interne 25 HHz=0, externe=1
	move.w #8,-(sp)		; destination : DAC
	move.w #0,-(sp)		; source : DMA
	appel xbios,139,12

	;move.w #%xxxx1100xxxxxxxx,$ffff8930; crossbar source
	;move.w #%0000100100000001,$ffff8930; hand-shake off 25Mhz
	;move.w #%xxxxxxxx1000xxxx,$ffff8932; crossbar destination
	;move.w #%0000000010011001,$ffff8932; connect, hand-shake off
	;move.b #%xxxx0100,$ffff8935	; 20 KHz (internal clock)
	;move.b #%00000010,$ffff8937	; source multiplexer
	rts
			******
set_timer_a:
	pea -1
	move.w #$134/4,-(sp)
	appel bios,5,8
	move.l d0,old_a

	pea direct_to_disk
	move.w #1,-(sp)		; data
	move.w #%1000,-(sp)		; control
	move.w #0,-(sp)		; timera
	appel xbios,31,12

	;move.b	#0,ctrla		; arrete TA
	;move.l	#direct_to_disk,timera
	;move.b	#1,dataa
	;move.b	#%00001000,ctrla
	;bclr	#3,$fffffa17	; automatic end of interrupt
	
	;bset #5,$fffffa07		; autorise le timer
	;bset #5,$fffffa13
	rts

start_timer_a:
	move.w #13,-(sp)
	appel xbios,$1b,4
	rts

stop_timer_a:
	move.w #13,-(sp)
	appel xbios,$1a,4
	rts

restore_timera:
	bsr stop_timer_a
	;move.b #0,ctrla		; arrete TA
	;bclr #5,$fffffa07
	;bclr #5,$fffffa13
	move.l old_a,-(sp)
	move.w #$134/4,-(sp)
	appel bios,5,8
	rts

	BSS
old_a:	ds.l 1
	TEXT
			*****************
set_dma_play_buff_ad:	; empilez d'abord la source puis la destination
		; on a d‚ja le PC de retour d'empil‚
;	movem.l d0-d1/a0-a1,-(sp)
;	movem.l 4+4*4(sp),a0/a1
;	pea (a0)		; fin
;	pea (a1)		; d‚but
;	clr.w -(sp)
;	appel xbios,131,12		; set dma replay buf
;	movem.l (sp)+,d0-d1/a0-a1

	move.b 1+8(a7),$ffff8903	; adresse source (high)
	move.b 2+8(a7),$ffff8905	; (mid)
	move.b 3+8(a7),$ffff8907	; (low)
	move.b 1+4(a7),$ffff890f	; adresse de fin
	move.b 2+4(a7),$ffff8911
	move.b 3+4(a7),$ffff8913
	rtd #8
			******

direct_to_disk:			; (ptr_d2d_inter)=prochain … jouer
	save d0/a0
	move.l ptr_d2d_inter,-(sp)	; d‚but … jouer

	move.l ptr_d2d_inter+4,d0	; si on joue le dernier buffer
	cmp.l ad_main_buffer,d0		; en terme de place en m‚moire
	bne.s .pas_cool		; alors la fin n'est pas #d‚but !
	move.l ad_main_buffer,d0
	add.l #NBR_BUFF*LENGTH_REPLAY,d0
.pas_cool:	move.l d0,-(sp)		; fin … jouer
	bsr set_dma_play_buff_ad

	lea ptr_d2d_inter,a0
	move.l (a0),d0
	REPT NBR_BUFF-1
	move.l 4(a0),(a0)+		; swapping des adresses des buffers
	ENDR
	move.l d0,ptr_d2d_inter+4*(NBR_BUFF-1)
*	move.l d0,(a0)
	addq.w #1,semaphore
	load d0/a0
	bclr #5,$fffffa0f.w		; software end of interrupt
	rte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; si end_of_file est mis : pas de lecture
	; mais le ptr_fichier est remis au d‚but, nb. octets lus = 0

load_d0_at_a0:
	tst end_of_file
	beq.s .notend
	clr.l d0
	rts

.notend:	save d0/a0
	file_read a0,d0,save_handle
	load d1/a0			; j'en voulais d1, j'en ai d0

	tst.l d0			; on sait jamais
	bpl.s .ok

	clr.l d0			; pb lecture

.finfich:	save d0/a0

	*file_seek #0,save_handle,header	; mode 0
	move.w which_rout,d0
	sub #1,d0
	mulu #4*3,d0
	lea table_routs,a0
	jsr ([a0,d0.w])		; init_routs

	load d0/a0
	move #1,end_of_file
	rts			; si d0=0 au retour : pb

.ok:	cmp.l d0,d1
	bne.s .finfich		; fin de fichier ?

	rts
		******************************
	; avec en a0 l'adresse ou charger et d0=nb.

init_rout1:	file_seek #0,save_handle,header
	clr d7
	rts

end_rout1:	rts

load_rout1:	save d0
	bsr load_d0_at_a0		; 16 bit/st‚r‚o
	load d1
	lea 0(a0,d1.l),a1		; fin buffer
	sub.l d0,d1
	beq.s .pas_pb
.fill0:	clr.l -(a1)
	subq.l #4,d1		; st‚r‚o
	bgt.s .fill0
.pas_pb:	rts
			**********
init_rout2:
	file_seek #0,save_handle,header

	tst.l ad_buff_unpack
	bne.s .fin_init_rout2

	move.l #LENGTH_REPLAY/2,d0
	bsr allocate_dis_memory
	bmi .plant
	move.l d0,ad_buff_unpack

.fin_init_rout2:
	tst replay_in_psst
	bne init_rout2bis

	clr d7
.plant:	rts

end_rout2:	move.l ad_buff_unpack,d0
	bsr desallocate_dis_memory
	clr.l ad_buff_unpack

	tst replay_in_psst
	bne end_rout2bis

	rts

load_rout2:	tst.l ad_buff_unpack
	beq.s findecomp2

	tst replay_in_psst
	bne load_rout2bis

nb_ms_equal_to_zero:
	lsr.l #1,d0			; 16 bit/mono
	save d0/a0
	move.l ad_buff_unpack,a0
	bsr load_d0_at_a0
	load d1/a0

	lea 0(a0,d1.l),a1		; fin buffer
	sub.l d0,d1
	beq.s .fullbuff

.fill0:	clr.l -(a1)
	subq.l #2,d1
	bgt.s .fill0
	tst.l d0
	beq.s findecomp2

.fullbuff:	move.l ad_buff_unpack,a1

	lsr.l #1,d0			; en tout /8 (2*.L)

decomp2:	move.w (a1)+,d1		; gauche=droite
	move.w d1,(a0)+
	move.w d1,(a0)+
	subq.l #1,d0
	bgt.s decomp2

findecomp2:	rts
			**********
init_rout2bis:
	move #NB_WORD_IN_BUF_PSST-1,d0
	lea buffer_psst,a0
.clr:	clr.w (a0)+
	dbf d0,.clr

	clr d7
	rts

end_rout2bis:
	rts

load_rout2bis:
	tst nb_ms
	beq nb_ms_equal_to_zero		; mono normal

	lsr.l #1,d0			; 16 bit/mono pseudo-st‚r‚o
	save d0/a0
	move.l ad_buff_unpack,a0
	bsr load_d0_at_a0
	load d1/a0

	lea 0(a0,d1.l),a1		; fin buffer
	sub.l d0,d1
	beq.s .fullbuff

.fill0:	clr.l -(a1)
	subq.l #2,d1
	bgt.s .fill0
	tst.l d0
	beq findecomp2bis

.fullbuff:

	move.l ad_buff_unpack,a1

	lsr.l #1,d0			; en tout /8 (2*.L)

*	move #20,nb_ms
	move nb_ms,d2
	bpl.s .pos
	neg d2
.pos:
	lea table_cv_freq,a2
	move.b frequency_for_play,d1
.redo:	cmp.b 3(a2),d1
	beq.s .found
	lea 8(a2),a2
	bra.s .redo
.found:	move.w 6(a2),d1
	mulu d2,d1			; d2=abs(nb. ms)
	divu #1000,d1		; en ms (10e-3)
	ext.l d1
	move d1,nb_valdecal

	; 11111122222222222222222 333333	; si nb_ms > 0
	; 22222222222222222333333

.copy_old:	move.w d1,d2
	lea buffer_psst,a2
	move.l a0,a3
	tst nb_ms
	bpl.s .pos2
	lea 2(a3),a3
.pos2:
.redo1:	move.w (a2)+,(a3)
	lea 4(a3),a3
	subq.w #1,d2
	bne.s .redo1

.copy_new:	move.l d0,d2
	sub.l d1,d2
	bmi planta
	move.l a0,a4
	tst nb_ms
	bmi.s .pos3
	lea 2(a4),a4
.pos3:
.redo2:	move.w (a1)+,d3
	move.w d3,(a3)	; a3 pointe la suite
	move.w d3,(a4)
	lea 4(a3),a3
	lea 4(a4),a4
	subq.l #1,d2
	bne.s .redo2

.copy_next:	move.w d1,d2
	lea buffer_psst,a2
.redo3:	move.w (a1)+,d3
	move.w d3,(a2)+
	move.w d3,(a4)	; a4 pointe la suite
	lea 4(a4),a4
	subq #1,d2
	bne.s .redo3

*decomp3:	move.w (a1)+,d1	; gauche=droite
*	move.w d1,(a0)+
*	move.w d1,(a0)+
*	subq.l #1,d0
*	bgt.s decomp3
findecomp2bis:
planta:	rts

 BSS
NB_WORD_IN_BUF_PSST=5000

replay_in_psst:	ds.w 1		; si possible : 0=non 1=oui
nb_ms:	ds.w 1			; compris entre -99 et 99
nb_valdecal:ds.w 1
buffer_psst:ds.w NB_WORD_IN_BUF_PSST	; 100e-3*50000
 TEXT
			**********
init_rout3:
	tst.l ad_buff_unpack
	bne .fin_init_rout3

	file_read #temporaire1,#16,save_handle
	cmp.l #16,d0
	bne .plant2

	lea temporaire1,a0

	cmp.l #'DVSM',dvs_header(a0)
	bne .plant2
	tst.w dvs_header+4(a0)
	bne .plant2
	move.w dvs_length(a0),length_tete+2
	move.w dvs_freq(a0),frequency_replay
	cmp.b #2,dvs_pack(a0)		; 2=pack‚
	bne .plant2

	move.b dvs_mode(a0),d0
	cmp.b #1,d0
	bne.s .pas_st
	move.l #4,how_many_1st_bytes
	bra.s .cont
.pas_st:	cmp.b #3,d0
	bne .plant2
	move.l #2,how_many_1st_bytes	; mono
.cont:	move d0,dvs_type_of_sound

	move.l dvs_block_length(a0),blk_length

	lea table_dvsm,a0	; table DVSM par d‚faut
	lea table_dec_dvsw,a1
	move #256-1,d0
.copy:	move.w (a0)+,(a1)+
	dbf d0,.copy

	move.l #16,d7

.view_cookies:
	file_read #temporaire1,#6,save_handle
	cmp.l #6,d0
	bne .plant2

	lea temporaire1,a0

	cmp.l #'LPKC',cookie_identify(a0)
	beq.s .lpck
	cmp.l #'PACK',cookie_identify(a0)
	beq.s .pack

	clr.l d0
	move.w cookie_length(a0),d0
	add.w d0,d7
	subq.l #6,d0
	file_seek #1,save_handle,d0

.finish_cookie:
	cmp.l length_tete,d7
	bne.s .view_cookies
	bra.s .fincookies

.lpck:	file_read #temporaire1,#2,save_handle
	cmp.l #2,d0
	bne .plant2
	add.l #8,d7
	cmp.w #8,temporaire1		; 8 bit pack-code
	beq.s .finish_cookie
	bra .plant2

.pack:	file_read #table_dec_dvsw,#256*2,save_handle
	cmp.l #256*2,d0
	bne .plant2
	add.l #4+2+256*2,d7
	bra.s .finish_cookie

.fincookies:

	clr.l d0
	clr d1
.find_ideal_size:
	add.l blk_length,d0
	addq #1,d1
	cmp.l #LENGTH_REPLAY,d0
	blt.s .find_ideal_size
	move.w d1,nbr_of_buffers_allocated

	bsr allocate_dis_memory
	bmi .plant2
	move.l d0,ad_buff_unpack

.fin_init_rout3:
	file_seek #0,save_handle,length_tete	; pour ˆtre sur

	clr.l octets_left_in_buff

	clr d7
	rts

.plant2:	moveq #BAD_DVW_HEADER,d7
	rts


end_rout3:	move.l ad_buff_unpack,d0
	bsr desallocate_dis_memory
	clr.l ad_buff_unpack

	rts


load_rout3:	tst.l ad_buff_unpack
	beq findecomp3

*	cmp #1,dvs_type_of_sound
*	beq.s .ste
*	lsr.l #1,d0
*.ste:
	; a0 = destination for data unpack
	; d0= nbr. bytes awaited
	move.l octets_left_in_buff,d1	; le ! registre important
	move.l progression,d2
	movem.w old_values,d3/d4
	move.l saved_pointer,a1
	lea table_dec_dvsw+128*2,a2

	tst.l d1
	bne.s gogo

reload:	save d0-d4/a0-a2
	clr.l d0
	move nbr_of_buffers_allocated,d0
	mulu.l blk_length,d0
	move.l ad_buff_unpack,a0
	bsr load_d0_at_a0
	move.l d0,d5
	load d0-d4/a0-a2
	move.l d5,d1
	beq fin_fichier
	blt findecomp3		; si 0 octets de lus
	move.l ad_buff_unpack,a1
	clr.l d2

gogo:	cmp #1,dvs_type_of_sound	; 0=st‚r‚o, 1=mono
	bne.s its_mono

its_stereo:	tst.l d2
	bne.s .redo
.remake:	move.w (a1)+,d3
	move.w (a1)+,d4
	move.w d3,(a0)+
	move.w d4,(a0)+
	sub.l #4,d1
	add.l #4,d2
	sub.l #4,d0
	beq.s fin_depack

.redo:	move.b (a1)+,d5
	ext.w d5
	add.w (a2,d5.w*2),d3
	move.w d3,(a0)+

	move.b (a1)+,d5
	ext.w d5
	add.w (a2,d5.w*2),d4
	move.w d4,(a0)+

	sub.l #2,d1
	add.l #2,d2
	sub.l #4,d0
	beq.s fin_depack
	tst.l d1
	beq.s reload
	cmp.l blk_length,d2
	bne.s .redo
	clr.l d2
	bra.s .remake

its_mono:	tst.l d2
	bne.s .redo
.remake:	move.w (a1)+,d3
	move.w d3,(a0)+
	move.w d3,(a0)+
	sub.l #2,d1
	add.l #2,d2
	sub.l #4,d0
	beq.s fin_depack

.redo:	move.b (a1)+,d5
	ext.w d5
	add.w (a2,d5.w*2),d3
	move.w d3,(a0)+
	move.w d3,(a0)+

	sub.l #1,d1
	add.l #1,d2
	sub.l #4,d0
	beq.s fin_depack
	tst.l d1
	beq reload
	cmp.l blk_length,d2
	bne.s .redo
	clr.l d2
	bra.s .remake

fin_fichier:			; d1 est nul
.fill0:	clr.l (a0)+
	subq.l #4,d0
	bgt.s .fill0

fin_depack:
	move.l d1,octets_left_in_buff
	move.l d2,progression
	movem.w d3/d4,old_values
	move.l a1,saved_pointer
findecomp3:	rts

	
 BSS
nbr_of_buffers_allocated:ds.w 1
octets_left_in_buff:	ds.l 1	; combien de donn‚es brutes non depack‚es
progression:	ds.l 1	; quel offset / taille 1 block (pour entete)
saved_pointer:	ds.l 1	; … quelle adresse dans les datas
old_values:		ds.w 2

length_tete:	ds.l 1
frequency_replay:	ds.w 1
how_many_1st_bytes:	ds.w 1
dvs_type_of_sound:	ds.w 1	; 0=st‚r‚o 8bit / 1=st‚r‚o 16 bit / 2=mono 8bit / 3=mono 16 bit
blk_length:		ds.l 1

temporaire1:	ds.b 16
table_dec_dvsw:	ds.w 256	; quand on fait une d‚compression
 TEXT

		*********************************
stop_if_running:
	tst sample_playing
	beq.s .no
	bsr restore_d2d		; & stop d2d & unlock
	clr sample_playing
.no:	rts
		*********************************

	DATA
table_dvsm:	incbin dvsm.tab

table_routs:dc.l init_rout1,load_rout1,end_rout1
	dc.l init_rout2,load_rout2,end_rout2
	dc.l init_rout3,load_rout3,end_rout3

	BSS

sample_playing:	ds.w 1		; 0=non, 1=oui.
semaphore:		ds.w 1
semaphore_2:	ds.w 1
save_handle:	ds.w 1
end_of_file:	ds.w 1		; 1=fin du fichier

name_2_load:	ds.b 256		; nom du track

ad_main_buffer:	ds.l 1		; le grand buffer tournant
ad_buff_unpack:	ds.l 1		; pour toutes les routines

loop:		ds.w 1
header:		ds.l 1		; longeur … sauter au d‚but
which_rout:		ds.w 1		; 1..3 = rout No 1..3
which_clock:	ds.w 1		; 0=interne; 1=externe
frequency_for_play:	ds.b 1
 even
	TEXT
****************************************************************************

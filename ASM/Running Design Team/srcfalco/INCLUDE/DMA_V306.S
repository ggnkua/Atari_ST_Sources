;**************************************

; dma-player version 3.06
; 28/08/97
; 09/10/97

;**************************************


;**************************************
;* init_sam_dist
;**************************************

; sample mit
; -> lautstaerkenanpassung
; -> nicht loopfaehig
; -> doppelt abspielbar

; d0 = x-position
; d1 = y-position
; d2 = samplenummer

init_sam_dist

		move	sr,-(sp)
		move.w	#$2300,sr
		movem.l	d2-d3/a0-a2,-(sp)

	; -------------------
	; freies sample bestimmen
	; a0 = freies sample

		bsr	is_get_next_free_sam

	; -------------------
	; welches sample:
	; intern oder extern
		
		lea	lev_samples,a1
		tst.w	d2
		bpl.s	isd_extern
		addi.w	#128,d2
		lea	samples,a1
isd_extern

	; -------------------
	; sampledaten uebernehmen

		mulu	#12,d2
		adda.l	d2,a1
		move.l	(a1)+,spl_address(a0)
		move.l	(a1)+,spl_length(a0)
		move.w	2(a1),spl_speed(a0)
		clr.l	spl_offset(a0)
		move.l	#$01000000,spl_info_pos(a0)

		movem.l	d0-d1,spl_x(a0)
		move.w	#1,spl_vol_counter

		movem.l	(sp)+,d2-d3/a0-a2
		move	(sp)+,sr

		rts


;**************************************
;* init_sam_dist_ndl
;**************************************

; sample mit
; -> lautstaerkenanpassung
; -> geloopt
; -> nicht doppelt abspielbar

; -> x/y-position muss upgedatet werden <-

; d0 = x-position
; d1 = y-position
; d2 = samplenummer

init_sam_dist_ndl

		move	sr,-(sp)
		move.w	#$2300,sr
		movem.l	d2-d3/a0-a2,-(sp)

	; -------------------
	; freies sample bestimmen
	; a0 = freies sample

		bsr	is_get_next_free_sam

	; -------------------
	; welches sample:
	; intern oder extern
		
		lea	lev_samples,a1
		tst.w	d2
		bpl.s	isdnd_extern
		addi.w	#128,d2
		lea	samples,a1
isdnd_extern

	; -------------------
	; sampledaten uebernehmen

		mulu	#12,d2
		adda.l	d2,a1
		move.l	(a1)+,d3

	; -------------------
	; ist diese sampleadresse
	; schon bei den bisherigen
	; abzuspielenden samples
	; vorhanden? Dazu alle
	; vier eintraege kontrollieren

		moveq	#3,d2
		lea	spl_dat,a2
isdnd_vorhanden	tst.l	spl_length(a2)
		beq.s	isdndv_no_sam
		cmp.l	spl_address(a2),d3
		bne.s	isdndv_no_sam
		movem.l	d0-d1,spl_x(a2)
		bra.s	isdnd_out
isdndv_no_sam	lea	spl_dat_length(a2),a2
		dbra	d2,isdnd_vorhanden	

		move.l	d3,spl_address(a0)
		move.l	(a1)+,spl_length(a0)
		move.w	2(a1),spl_speed(a0)
		clr.l	spl_offset(a0)
		move.l	#$01000001,spl_info_pos(a0)
		movem.l	d0-d1,spl_x(a0)
		move.w	#1,spl_vol_counter
isdnd_out

		movem.l	(sp)+,d2-d3/a0-a2
		move	(sp)+,sr

		rts


;**************************************
;* init_sam_nd
;**************************************

; sample mit
; -> keine lautstaerkenanpassung
; -> nicht geloopt
; -> nicht doppelt abspielbar

; d0 = samplenummer
; d1 = sampleinfo

init_sam_nd

		move	sr,-(sp)
		move.w	#$2300,sr
		movem.l	d2-d3/a0-a2,-(sp)

	; -------------------
	; freies sample bestimmen
	; a0 = freies sample

		bsr	is_get_next_free_sam

	; -------------------
	; welches sample: 
	; intern oder extern
		
		lea	lev_samples,a1
		tst.w	d0
		bpl.s	isnd_extern
		addi.w	#128,d0
		lea	samples,a1
isnd_extern

	; -------------------
	; sampledaten uebernehmen

		mulu	#12,d0
		adda.l	d0,a1
		move.l	(a1)+,d3

		moveq	#3,d2
		lea	spl_dat,a2
isnd_vorhanden	tst.l	spl_length(a2)
		beq.s	isndv_no_sam
		cmp.l	spl_address(a2),d3
		beq.s	isnd_out
isndv_no_sam	lea	spl_dat_length(a2),a2
		dbra	d2,isnd_vorhanden	

		move.l	d3,spl_address(a0)
		move.l	(a1)+,spl_length(a0)
		move.w	2(a1),spl_speed(a0)
		clr.l	spl_offset(a0)
		move.l	d1,spl_info_pos(a0)

isnd_out
		movem.l	(sp)+,d2-d3/a0-a2
		move	(sp)+,sr

		rts


;**************************************
;* init_sam
;**************************************

; sample mit
; -> keine lautstaerkenanpassung
; -> nicht geloopt
; -> doppelt abspielbar

; d0 = samplenummer
; d1 = sampleinfo

init_sam

		move	sr,-(sp)
		move.w	#$2300,sr
		movem.l	d2-d3/a0-a1,-(sp)

	; -------------------
	; freies sample bestimmen
	; a0 = freies sample

		bsr	is_get_next_free_sam

	; -------------------
	; welches sample:
	; intern oder extern
		
		lea	lev_samples,a1
		tst.w	d0
		bpl.s	is_extern
		addi.w	#128,d0
		lea	samples,a1	
is_extern

	; -------------------
	; sampledaten uebernehmen

		mulu	#12,d0
		adda.l	d0,a1
		move.l	(a1)+,spl_address(a0)
		move.l	(a1)+,spl_length(a0)
		move.w	2(a1),spl_speed(a0)
		clr.l	spl_offset(a0)
		move.l	d1,spl_info_pos(a0)

		movem.l	(sp)+,d2-d3/a0-a1
		move	(sp)+,sr

		rts


;**************************************
;* init_sam_delete_all
;**************************************

; loescht alle abzuspielenden samples
; keine uebergabeparameter

init_sam_delete_all

		move	sr,-(sp)
		move.w	#$2300,sr
		movem.l	d7/a0,-(sp)

		lea	spl_dat,a0
		moveq	#3,d7
isda_loop	clr.l	spl_length(a0)
		lea	spl_dat_length(a0),a0
		dbra	d7,isda_loop

		movem.l	(sp)+,d7/a0
		move.w	(sp)+,sr

		rts		


;**************************************
;* init_sam_delete
;**************************************

; loescht sample d0 aus der liste der
; abzuspielenden samples

; d0 = samplenummer

init_sam_delete

		move	sr,-(sp)
		move.w	#$2300,sr
		movem.l	d2-d3/a0-a1,-(sp)

	; -------------------
	; welches sample: 
	; intern oder extern
		
		lea	lev_samples,a1
		tst.w	d0
		bpl.s	isdel_extern
		addi.w	#128,d0
		lea	samples,a1	
isdel_extern

		mulu	#12,d0
		adda.l	d0,a1
		move.l	(a1),d0			; sampleadresse

		moveq	#3,d1
		lea	spl_dat,a1
isdel_loop	tst.l	spl_length(a1)
		beq.s	isdel_no_sam
		cmp.l	spl_address(a1),d0
		bne.s	isdel_no_sam
		clr.l	spl_length(a1)
isdel_no_sam	lea	spl_dat_length(a1),a1
		dbra	d1,isdel_loop

		movem.l	(sp)+,d2-d3/a0-a1
		move	(sp)+,sr

		rts


;**************************************
;* is_get_next_free_sam
;**************************************

; bestimmt einen der vier sampleslots
; zum abspielen eines samples

; rueckgabe:
; a0 = zeiger auf spl_dat slot

; alle register werden gerettet

is_get_next_free_sam

		movem.l	d1-d3,-(sp)

	; -------------------
	; 1. moeglichkeit: es ist
	; noch ein slot frei
	; dazu alle slots auf
	; ihren inhalt ueberpruefen

		moveq	#3,d2
		lea	spl_dat,a0
ignfs_loop	tst.l	spl_length(a0)
		beq.s	ignfs_found_free
		lea	spl_dat_length(a0),a0
		dbra	d2,ignfs_loop

	; -------------------
	; 2. moeglichkeit: das
	; kuerzeste sample
	; heraussuchen

		lea	spl_dat,a0
		move.l	#$7fffffff,d1		; zu vergleichende laenge
		moveq	#0,d3			; spl_dat slot -> anfangs ungueltig
		moveq	#3,d2
ignfs_loop2	cmp.l	spl_length(a0),d1
		blt.s	ignfs_no_short
		move.l	spl_length(a0),d1
		move.l	a0,d3
ignfs_no_short	dbra	d2,ignfs_loop2
		movea.l	d3,a0

ignfs_found_free

		movem.l	(sp)+,d1-d3

		rts


;**************************************
;* init_dma_play
;**************************************

; initialisierung des dma players
; mit 25 khz, mono, no surround

init_dma_play
		move.w	sr,-(sp)
		move.w	#$2700,sr	

		bsr	idp_vorinitialisieren

		move.l	#vga_play_buffer,d0
		tst.w	vga_monitor
		bne.s	idp_no_vga
		move.l	#rgb_play_buffer,d0
idp_no_vga	move.l	d0,spl_play_len
		move.l	d0,spl_play_len_25

		bset	#5,$fffffa07.w
		bset	#5,$fffffa13.w

		clr.b	$fffffa19.w
		move.b	#1,$fffffa1f.w
		move.b	#8,$fffffa19.w

		move.l	#dma_player,$134.w
		bsr 	init_sound_system

		move.b	#%00000011,$ffff8901.w

		lea	$ffff8907.w,a0
		move.l	spl_buffer1,d0
		move.l	d0,d1
		move.b	d0,(a0)
		lsr.w	#8,d0
		move.l	d0,-5(a0)
		add.l	spl_add_len,d1
		move.b	d1,12(a0)
		lsr.w	#8,d1
		move.l	d1,7(a0)

		move.w	(sp)+,sr

		rts

;---

idp_vorinitialisieren

		move.w	#$0500,$ffff8900.w
		move.w	#$0081,$ffff8920.w

		move.l	#$00010000,$ffff8930.w
		move.l	#$00000003,$ffff8934.w
		move.l	#$03000330,$ffff8938.w
		move.l	#$c401c100,$ffff893c.w
		move.l	#$00070000,$ffff8940.w

		rts


;**************************************
;* init_sound_system
;**************************************

; setzt die richtigen bits fuer
; frequenz bzw. kanalwahl (mono/stereo),
; liest spl_system aus

init_sound_system
		move.w	sr,-(sp)
		move.w	#$2300,sr

		lea	iss_values(pc),a0
		move.w	spl_system,d0
		move.b	(a0,d0.w),$ffff8921.w

		bsr	set_spl_add_len
		bsr	make_dma_tables

		move.w	(sp)+,sr
		rts

iss_values
		dc.b	%10000010
		dc.b	%10000001
		dc.b	%00000010
		dc.b	%00000001
		dc.b	%00000010
		dc.b	%00000001
		dc.b	%00000010
		dc.b	%00000001

;---

; bestimmt die laenge des 
; abzuspielenden buffers
; gemaess frequenz und modus

; spl_play_len ist die anzahl an
; bytes, die pro kanal berechnet
; werden mÅssen,
; spl_add_len ist die anzahl an
; bytes, die der abspielbuffer gross ist.
	
set_spl_add_len
		move.l	spl_play_len_25,d0
		lsr.l	#1,d0
		move.l	d0,d3
		lea	ssal_values(pc),a0
		move.w	spl_system,d1
		moveq	#0,d2
		move.b	(a0,d1.w),d2
		lsl.l	d2,d0	
		move.l	d0,spl_add_len

		move.b	8(a0,d1.w),d2
		lsl.l	d2,d3
		move.l	d3,spl_play_len

		rts

ssal_values	
		dc.b	1,0,2,1,2,1,2,1
sspl_values
		dc.b	1,0,1,0,1,0,1,0

;**************************************

stop_dma_play
		move.b	#%00000000,$ffff8901.w
		rts


;**************************************

; volume_table erstellen
; inter_mulu_tab erstellen

make_dma_tables

	; zuerst die vol_tab

		lea	vol_tab+256*17,a0
		moveq	#16,d0
mvt_loop_outer	moveq	#16,d3
		sub.w	d0,d3
		move.w	#255,d1
mvt_loop_inner	move.w	d1,d2
		ext.w	d2
		muls	d3,d2
		divs	#main_vol,d2
		move.b	d2,-(a0)
		dbra	d1,mvt_loop_inner
		dbra	d0,mvt_loop_outer

	; interpolate_tab anpassen

		lea	interpolate_tab_orig,a0
		lea	interpolate_tab,a1
		moveq	#24,d7
		move.w	spl_system,d0
		btst	#0,d0			; 12 oder 25 khz ?
		beq.s	inttab25_loop

inttab12_loop	move.l	(a0)+,d1
		add.l	d1,d1
		move.l	d1,(a1)+
		dbra	d7,inttab12_loop
		bra	inttab_ok

inttab25_loop	move.l	(a0)+,(a1)+
		dbra	d7,inttab25_loop

inttab_ok		

	; inter_mulu_tab erstellen

		lea	interpolate_tab,a0
		lea	inter_mulu_tab,a1
		moveq	#24,d0
		move.l	spl_play_len,d1
imt_loop	move.l	(a0)+,d2
		mulu.l	d1,d2
		clr.w	d2
		swap	d2
		move.l	d2,(a1)+
		dbra	d0,imt_loop

		rts		


;**************************************

; interrupt-routine: dma_player v3.0

dma_player
		movem.l	d0-a6,-(sp)

		ifne	dma_debug
		moveq	#3,d0
		lea	spl_dat,a0
		moveq	#20,d1
dd_loop		movem.l	d0-d1/a0,-(sp)
		movem.l	d1/a0,-(sp)
		movea.l	screen_2,a2
		adda.l	#640*10,a2
		adda.l	d1,a2
		moveq	#7,d7
		move.l	spl_length(a0),d0
		jsr	paint_hex
		movem.l	(sp)+,d1/a0
		movem.l	d1/a0,-(sp)
		movea.l	screen_2,a2
		adda.l	#640*20,a2
		adda.l	d1,a2
		moveq	#7,d7
		move.l	spl_info_pos(a0),d0
		jsr	paint_hex
		movem.l	(sp)+,d1/a0
		movem.l	d1/a0,-(sp)
		movea.l	screen_2,a2
		adda.l	#640*30,a2
		adda.l	d1,a2
		moveq	#7,d7
		move.l	spl_x(a0),d0
		jsr	paint_hex
		movem.l	(sp)+,d1/a0
		movem.l	d1/a0,-(sp)
		movea.l	screen_2,a2
		adda.l	#640*40,a2
		adda.l	d1,a2
		moveq	#7,d7
		move.l	spl_y(a0),d0
		jsr	paint_hex
		movem.l	(sp)+,d1/a0
		movem.l	(sp)+,d0-d1/a0
		addi.l	#100,d1
		lea	spl_dat_length(a0),a0
		dbra	d0,dd_loop
		endc

		bsr	dp_swap_buffers

		lea	spl_vol_counter,a0
		move.w	(a0),d0
		subq.w	#1,d0
		bpl.s	dpv_ok
		moveq	#dma_per_vbl*5,d0	; nur 10 mal in der sekunden
dpv_ok		move.w	d0,(a0)			; die volumetab neu errechnen

		lea	spl_dat,a0
		lea	interpolate_tab,a3
		lea	vol_tab,a4
		lea	inter_mulu_tab,a5
		lea	dp_ptr,a6

		move.l	#sam_leer,(a6)
		move.l	#sam_leer,4(a6)
		move.l	#sam_leer,8(a6)
		move.l	#sam_leer,12(a6)

		moveq	#0,d7
		bsr	dp_calc_sam
		bsr	dp_calc_sam
		bsr	dp_calc_sam
		bsr	dp_calc_sam

		tst.w	d7
		bne.s	dp_voices

		; es wird keine sample
		; abgespielt, also den
		; buffer loeschen

		movea.l	spl_buffer1,a6
		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
dp_clear_loop	clr.w	(a6)+
		dbra	d7,dp_clear_loop

		bra.s	dp_out

dp_voices
		lea	dp_mix_routines,a0
		move.w	spl_system,d0
		add.w	d0,d0
		andi.w	#%1100,d0
		subq.w	#1,d7
		add.w	d7,d0
		movea.l	(a0,d0.w*4),a0
		jsr	(a0)

dp_out
		movem.l	(sp)+,d0-a6
		rte

;---

; vertauscht die zwei pointer und
; setzt den neuen buffer zum
; abspielen

dp_swap_buffers

		lea	spl_buffer1,a0
		movem.l	(a0),d1-d2	; zwei bufferpointer
		exg	d1,d2
		movem.l	d1-d2,(a0)

		lea	$ffff8907.w,a0
		move.l	d1,d2
		move.b	d1,(a0)
		lsr.w	#8,d1
		move.l	d1,-5(a0)
		add.l	spl_add_len,d2
		move.b	d2,12(a0)
		lsr.w	#8,d2
		move.l	d2,7(a0)

		rts

;---

; uebergabe: 
;	a0: spl_dat
;	a3: interpolate_tab
;	a4: vol_tab
;	a5: inter_mulu_tab
;	a6: dp_ptr
;	d7: anzahl samples fuer dma_player

dp_calc_sam

		move.l	spl_length(a0),d1	; sample vorhanden ?
		beq.s	dpcs_out
		move.l	spl_offset(a0),d2	; offset holen
		move.l	d2,spl_play_offi(a0)	; ab hier abspielen
		move.w	spl_speed(a0),d4	; anzahl bytes addieren,
		add.l	(a5,d4.w*4),d2		; die abgespielt werden
		cmp.l	d2,d1
		bge.s	dpcs_length_ok
		
		; nicht mehr genuegend werte vorhanden:
		; muss es geloopt werden ?

		tst.b	spl_info_loop(a0)
		bne.s	dpcs_loop_spl

		; sample ist mit abspielen fertig,
		; also loeschen

		clr.l	spl_length(a0)
		bra.s	dpcs_out

dpcs_loop_spl
		clr.l	spl_play_offi(a0)
		clr.w	spl_frac(a0)
		move.l	0(a5,d4.w*4),d2

dpcs_length_ok
		move.l	d2,spl_offset(a0)	; neues offset abspeichern

		bsr	dpcs_vol_tab

		move.w	(a3,d4.w*4),d3
		ext.l	d3
		move.l	d3,spl_vorkomma(a0)	; vorkomma
		move.w	2(a3,d4.w*4),spl_nachkomma(a0)
		move.l	a0,(a6)+		; sample eintragen
		addq.w	#1,d7			; anzahl samples erhoehen
dpcs_out
		lea	spl_dat_length(a0),a0
		rts

;---

; address vol_tab bestimmen

; achtung: verschiedene register 
;          sind in gebrauch ...

dpcs_vol_tab
		tst.b	spl_info_pos(a0)	; muss samplelautstaerke
		beq	dpcsvt_no_loud		; der spielerposition angepasst werden ?

		tst.w	spl_vol_counter		; und das dann auch nicht
		bne	dpcsvt_no_loud		; bei jedem dma-irq

	; lautstaerke der spielerposition anpassen

		movem.l	spl_x(a0),d0-d1
		move.l	a6,-(sp)
		bsr	calc_dist_to_player
		movea.l	(sp)+,a6
                cmpi.l  #$00002000,d0
                blt.s   dpcsvt_dist_ok
                move.l  #$00002000,d0
dpcsvt_dist_ok	rol.w	#7,d0
                andi.b  #$1f,d0
		move.b	d0,spl_info_vol_r(a0)
		move.b	d0,spl_info_vol_l(a0)

		btst	#1,spl_system+1		; stereo ?
		beq	dpcsvt_no_loud

	; stereosystem

		movem.l	spl_x(a0),d0-d1
		move.l	a6,-(sp)
		bsr	calc_alpha_to_player
		movea.l	(sp)+,a6

		movea.l	play_dat_ptr,a1		; a1 ist hoffentlich frei
		sub.l	pd_alpha(a1),d0
		ext.w	d0
		bpl.s	dpcsvts_rechts_leiser

	; linker kanal muss abgeschwaecht werden
	; d0 ist zwischen -128 und -1

		neg.w	d0
		lsr.w	#2,d0
		cmpi.w	#16,d0
		blt.s	mpcsvtsl_ok
		moveq	#32,d1
		sub.w	d0,d1
		move.w	d1,d0
mpcsvtsl_ok
		moveq	#16,d1
		sub.b	spl_info_vol_r(a0),d1
		mulu	d0,d1
		lsr.w	#4,d1
		add.b	spl_info_vol_r(a0),d1	
		move.b	d1,spl_info_vol_r(a0)
		bra.s	dpcsvt_no_loud

dpcsvts_rechts_leiser

	; rechter kanal muss abgeschwaecht werden
	; d0 ist zwischen 0 und 127

		addq.w	#1,d0
		lsr.w	#2,d0
		cmpi.w	#16,d0
		blt.s	mpcsvtsr_ok
		moveq	#32,d1
		sub.w	d0,d1
		move.w	d1,d0
mpcsvtsr_ok
		moveq	#16,d1
		sub.b	spl_info_vol_l(a0),d1
		mulu	d0,d1
		lsr.w	#4,d1
		add.b	spl_info_vol_l(a0),d1
		move.b	d1,spl_info_vol_l(a0)


dpcsvts_calc_address
dpcsvt_no_loud

		moveq	#0,d1
		move.b	spl_info_vol_r(a0),d1
		lsl.w	#8,d1
		add.l	a4,d1
		move.l	d1,spl_voltab(a0)	

		moveq	#0,d1
		move.b	spl_info_vol_l(a0),d1
		lsl.w	#8,d1
		add.l	a4,d1
		move.l	d1,spl_voltab_left(a0)	

		rts

;---------------

; der dma mixer

mix_m_1		
		lea	dp_ptr,a6
		movea.l	(a6)+,a1

		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a6
mm1_loop
		add.w	a4,d1		; nachkomma addieren
		addx.l	d2,d0		; vorkomma addieren
		move.b	(a0,d0.l),d3	
		move.b	(a2,d3.w),(a6)+
		dbra	d7,mm1_loop

		lea	dp_ptr,a6
		movea.l	(a6)+,a1
		move.w	d1,spl_frac(a1)

		rts

mix_m_2
		lea	dp_ptr,a6
		movea.l	(a6)+,a1
		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2

		; sample 1:
		; a0: address
		; a2: voltab
		; a4: nachkomma
		; d0: offi
		; d1: frac
		; d2: vorkomma

		movea.l	(a6)+,a1	; naechstes sample
		move.l	spl_play_offi(a1),d4
		move.w	spl_frac(a1),d5
		move.l	spl_vorkomma(a1),d6
		move.w	spl_nachkomma(a1),a5
		movea.l	spl_voltab(a1),a3
		movea.l	spl_address(a1),a1

		; sample 2:
		; a1: address
		; a3: voltab
		; a5: nachkomma
		; d4: offi
		; d5: frac
		; d6: vorkomma

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a6
mm2_loop
		swap	d7
		add.w	a4,d1		; nachkomma addieren
		addx.l	d2,d0		; vorkomma addieren
		add.w	a5,d5
		addx.l	d6,d4
		move.b	(a0,d0.l),d3	
		move.b	(a2,d3.w),d7
		move.b	(a1,d4.l),d3
		add.b	(a3,d3.w),d7
		move.b	d7,(a6)+
		swap	d7
		dbra	d7,mm2_loop

		lea	dp_ptr,a6
		movea.l	(a6)+,a1
		move.w	d1,spl_frac(a1)
		movea.l	(a6)+,a1
		move.w	d5,spl_frac(a1)

		rts

mix_m_34
		bsr	mix_m_2
		bsr	add_m_2
		rts

add_m_2
		move.l	a6,-(sp)
		movea.l	(a6)+,a1
		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2

		movea.l	(a6)+,a1	; naechstes sample
		move.l	spl_play_offi(a1),d4
		move.w	spl_frac(a1),d5
		move.l	spl_vorkomma(a1),d6
		move.w	spl_nachkomma(a1),a5
		movea.l	spl_voltab(a1),a3
		movea.l	spl_address(a1),a1

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a6
am2_loop
		swap	d7
		add.w	a4,d1		; nachkomma addieren
		addx.l	d2,d0		; vorkomma addieren
		add.w	a5,d5
		addx.l	d6,d4
		move.b	(a0,d0.l),d3	
		move.b	(a2,d3.w),d7
		move.b	(a1,d4.l),d3
		add.b	(a3,d3.w),d7
		add.b	d7,(a6)+
		swap	d7
		dbra	d7,am2_loop

		movea.l	(sp)+,a6
		movea.l	(a6)+,a1
		move.w	d1,spl_frac(a1)
		movea.l	(a6)+,a1
		move.w	d5,spl_frac(a1)

		rts

;---

mix_s_1		
		lea	dp_ptr,a6
		movea.l	(a6)+,a1

		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2
		movea.l	spl_voltab_left(a1),a3

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a5
ms1_loop
		add.w	a4,d1		; nachkomma addieren
		addx.l	d2,d0		; vorkomma addieren
		move.b	(a0,d0.l),d3	
		move.b	(a3,d3.w),(a5)
		move.b	(a2,d3.w),1(a5)
		addq.l	#2,a5
		dbra	d7,ms1_loop

		move.w	d1,spl_frac(a1)

		rts

mix_s_2
		bsr	mix_s_1
		bsr	add_s_1
		rts

mix_s_3
		bsr	mix_s_1
		bsr	add_s_1
		bsr	add_s_1
		rts

mix_s_4
		bsr	mix_s_1
		bsr	add_s_1
		bsr	add_s_1
		bsr	add_s_1
		rts


add_s_1
		movea.l	(a6)+,a1

		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2
		movea.l	spl_voltab_left(a1),a3

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a5
as1_loop
		add.w	a4,d1		
		addx.l	d2,d0		
		move.b	(a0,d0.l),d3	
		move.b	(a3,d3.w),d4
		add.b	d4,(a5)
		move.b	(a2,d3.w),d4
		add.b	d4,1(a5)
		addq.l	#2,a5
		dbra	d7,as1_loop

		move.w	d1,spl_frac(a1)

		rts

;---

mix_ms_1		
		lea	dp_ptr,a6
		movea.l	(a6)+,a1

		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a6
mms1_loop
		add.w	a4,d1		; nachkomma addieren
		addx.l	d2,d0		; vorkomma addieren
		move.b	(a0,d0.l),d3	
		move.b	(a2,d3.w),d4
		move.b	d4,(a6)+	
		neg.b	d4
		move.b	d4,(a6)+
		dbra	d7,mms1_loop

		lea	dp_ptr,a6
		movea.l	(a6)+,a1
		move.w	d1,spl_frac(a1)

		rts

mix_ms_2
		lea	dp_ptr,a6
		movea.l	(a6)+,a1
		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2

		; sample 1:
		; a0: address
		; a2: voltab
		; a4: nachkomma
		; d0: offi
		; d1: frac
		; d2: vorkomma

		movea.l	(a6)+,a1	; naechstes sample
		move.l	spl_play_offi(a1),d4
		move.w	spl_frac(a1),d5
		move.l	spl_vorkomma(a1),d6
		move.w	spl_nachkomma(a1),a5
		movea.l	spl_voltab(a1),a3
		movea.l	spl_address(a1),a1

		; sample 2:
		; a1: address
		; a3: voltab
		; a5: nachkomma
		; d4: offi
		; d5: frac
		; d6: vorkomma

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a6
mms2_loop
		swap	d7
		add.w	a4,d1		; nachkomma addieren
		addx.l	d2,d0		; vorkomma addieren
		add.w	a5,d5
		addx.l	d6,d4
		move.b	(a0,d0.l),d3	
		move.b	(a2,d3.w),d7
		move.b	(a1,d4.l),d3
		add.b	(a3,d3.w),d7
		move.b	d7,(a6)+
		neg.b	d7
		move.b	d7,(a6)+
		swap	d7
		dbra	d7,mms2_loop

		lea	dp_ptr,a6
		movea.l	(a6)+,a1
		move.w	d1,spl_frac(a1)
		movea.l	(a6)+,a1
		move.w	d5,spl_frac(a1)

		rts

mix_ms_34
		bsr	mix_ms_2
		bsr	add_ms_2
		rts

add_ms_2
		move.l	a6,-(sp)
		movea.l	(a6)+,a1
		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2

		movea.l	(a6)+,a1	; naechstes sample
		move.l	spl_play_offi(a1),d4
		move.w	spl_frac(a1),d5
		move.l	spl_vorkomma(a1),d6
		move.w	spl_nachkomma(a1),a5
		movea.l	spl_voltab(a1),a3
		movea.l	spl_address(a1),a1

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a6
ams2_loop
		swap	d7
		add.w	a4,d1		; nachkomma addieren
		addx.l	d2,d0		; vorkomma addieren
		add.w	a5,d5
		addx.l	d6,d4
		move.b	(a0,d0.l),d3	
		move.b	(a2,d3.w),d7
		move.b	(a1,d4.l),d3
		add.b	(a3,d3.w),d7
		add.b	d7,(a6)+
		neg.b	d7
		add.b	d7,(a6)+
		swap	d7
		dbra	d7,ams2_loop

		movea.l	(sp)+,a6
		movea.l	(a6)+,a1
		move.w	d1,spl_frac(a1)
		movea.l	(a6)+,a1
		move.w	d5,spl_frac(a1)

		rts

;---

mix_ss_1		
		lea	dp_ptr,a6
		movea.l	(a6)+,a1

		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2
		movea.l	spl_voltab_left(a1),a3

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a5
mss1_loop
		add.w	a4,d1		; nachkomma addieren
		addx.l	d2,d0		; vorkomma addieren
		move.b	(a0,d0.l),d3	
		move.b	(a3,d3.w),(a5)
		move.b	(a2,d3.w),d4
		neg.b	d4
		move.b	d4,1(a5)
		addq.l	#2,a5
		dbra	d7,mss1_loop

		move.w	d1,spl_frac(a1)

		rts

mix_ss_2
		bsr	mix_ss_1
		bsr	add_ss_1
		rts

mix_ss_3
		bsr	mix_ss_1
		bsr	add_ss_1
		bsr	add_ss_1
		rts

mix_ss_4
		bsr	mix_ss_1
		bsr	add_ss_1
		bsr	add_ss_1
		bsr	add_ss_1
		rts


add_ss_1
		movea.l	(a6)+,a1

		movea.l	spl_address(a1),a0
		move.l	spl_play_offi(a1),d0
		move.w	spl_frac(a1),d1
		move.l	spl_vorkomma(a1),d2
		move.w	spl_nachkomma(a1),a4
		movea.l	spl_voltab(a1),a2
		movea.l	spl_voltab_left(a1),a3

		move.w	spl_play_len+2,d7
		subq.w	#1,d7
		moveq	#0,d3
		movea.l	spl_buffer1,a5
ass1_loop
		add.w	a4,d1		
		addx.l	d2,d0		
		move.b	(a0,d0.l),d3	
		move.b	(a3,d3.w),d4
		add.b	d4,(a5)
		add.b	(a2,d3.w),d4
		neg.b	d4
		move.b	d4,1(a5)
		addq.l	#2,a5
		dbra	d7,ass1_loop

		move.w	d1,spl_frac(a1)

		rts



;---------------		

dp_mix_routines

		dc.l	mix_m_1
		dc.l	mix_m_2
		dc.l	mix_m_34
		dc.l	mix_m_34

		dc.l	mix_s_1
		dc.l	mix_s_2
		dc.l	mix_s_3
		dc.l	mix_s_4

		dc.l	mix_ms_1
		dc.l	mix_ms_2
		dc.l	mix_ms_34
		dc.l	mix_ms_34

		dc.l	mix_ss_1
		dc.l	mix_ss_2
		dc.l	mix_ss_3
		dc.l	mix_ss_4

;---

; address - offset - voltab - vorkomma - nachkomma

dp_anz		dc.w	0
dp_ptr		ds.l	4

;---

vol_tab		ds.b	256*17

;---

spl_buffer1	dc.l	play_buffer1
spl_buffer2	dc.l	play_buffer2
spl_buffer_end	dc.l	play_buffer_end

;---

; offsets fuer einen samplewerte, jeweils vor- und nachkomma
; 25 werte (long)

interpolate_tab_orig

		dc.l	65536,61858,58386,55109,52016
		dc.l	49096,46340,43740,41285,38968
		dc.l	36780,34716,32768
		dc.l	61858/2,58386/2,55109/2
		dc.l	52016/2,49096/2,46340/2
		dc.l	43740/2,41285/2,38968/2
		dc.l	36780/2,34716/2,32768/2


interpolate_tab
		ds.l	25

inter_mulu_tab
		ds.l	25



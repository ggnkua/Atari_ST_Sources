; Quick Time, AVI, FLI/FLC player
; Original version (graphics only): Dieter Fiebelkorn
; ASM translation + DMA sound + NOVA graphics: Guillaume Tello

	opt P=68030,P=68882,w+

DBG = 0
SOURIS = 1
LAST_TREE = 21		; toujours le dialog STEP by STEP
STRING_TREE = LAST_TREE+1	; les chaines

VERSION = '4.20'
VER_STR macro
	dc.b "4.20"
	endm

;LOG macro	; 'xxxx',flag (flag=1 create file, =0append)
;	movem.l d0-d7/a0-a6,-(sp)
;	move.l #\1,d0
;	moveq #\2,d1
;	bsr.l _log
;	movem.l (sp)+,d0-d7/a0-a6
;	endm

	if DBG=1
DEBUGH MACRO
	move.l d0,-(sp)
	move.l \1,d0
	bsr.l _debug_hex
	move.l (sp)+,d0
	ENDM
DEBUGC MACRO
	move.b #\1-1,_debug_text+1
	bsr.l _debug
	ENDM
DEBUG MACRO
	bsr.l _debug
	ENDM
DEBUGSTRING MACRO
	move.l \1,_debug_adr
	bsr.l _debug_string
	ENDM
	endif


	OUTPUT "M_PLAYER.PRG"

; some useful Macros

FREE MACRO ; variable contenant l'adresse du bloc
	move.l \1,a2
	bsr.l mfree
	ENDM

XBIOS MACRO   ; fn,stack
   move #\1,-(sp)
   trap #14
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

BIOS MACRO    ; fn,stack
   move #\1,-(sp)
   trap #13
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEMDOS MACRO    ; fn,stack
   move #\1,-(sp)
   trap #1
   if \2<=8
      addq.l #\2,sp
   else
      add.w #\2,sp
   endif
   ENDM

GEM_AES MACRO
   move.l #\1,d1
   move.l #$c8,d0
   trap #2
   ENDM

GEM_VDI MACRO
   move.l #\1,a0
   move.l a0,d1
   move.l (a0),a0
   move i_handle,12(a0)
   moveq #$73,d0
   trap #2
   ENDM

; seeks into a file

SEEK MACRO	; size, mode (0=start, 1=current, 2=end)
	move #\2,-(sp)			; mode
	move mov_h,-(sp)		; handle
	move.l \1,-(sp)		; size (offset)
	move #66,-(sp)			; fseek
	trap #1
	lea 10(sp),sp
	ENDM

; converts an ugly Intel DWORD into a beautiful Motorola Long
INTEL MACRO ; a data register (long)
	rol #8,\1
	swap \1
	rol #8,\1
	ENDM

; converts a beautiful 16bit NOVA pixel into an ugly Falcon one (for cram)
FALC16 MACRO
	ror #5,\1
	lsr.b #1,\1
	roxr #2,\1
	ENDM

; converts an ugly Falcon pixel into a beautiful NOVA one (without byte swap)
NOVA16 MACRO
	ror.l #5,\1
	lsr #1,\1
	rol.l #5,\1
	ENDM


; converts a GGGBBBBB xRRRRRGG into a grey index (0 through 255)
TO_GREY MACRO
	ror #8,\1
	bclr #15,\1
	move.b (a1,\1.w),\1
	ENDM

RPZA	MACRO
	move.l (a2)+,d1
	if falc=2
		swap d1
		bclr #15,d1
		move.b (a1,d1.w),(a3)+
		swap d1
		bclr #15,d1
		move.b (a1,d1.w),(a3)+
	else
		if falc=0
			ror d3,d1
		endif
		if (falc=1)|(falc=3)
			ror #8,d1
			FALC16 d1
			if falc=3
				ror #8,d1
			endif
		endif
		swap d1
		if falc=0
			ror d3,d1
		endif
		if (falc=1)|(falc=3)
			ror #8,d1
			FALC16 d1
			if falc=3
				ror #8,d1
			endif
		endif
		swap d1
	move.l d1,(a3)+
	endif
	ENDM

splice	MACRO  ; data1,data2,mask,temp,imm
	move.l \2,\4
	lsr.l #\5,\4
	eor.l \1,\4
	and.l \3,\4
	eor.l \4,\1
	lsl.l #\5,\4
	eor.l \4,\2
	ENDM

sp_16 MACRO
	move.\0 \2,d7
	lsr.\0 #\3,d7
	eor.\0 \1,d7
	and.\0 d0,d7
	eor.\0 d7,\1
	lsl.\0 #\3,d7
	eor.\0 d7,\2
	ENDM

AUD_CALC_DVI MACRO
   ADD \2,\2
   AND #$1F,\2			;delta (magnitude)
   MOVE \3,D0
   ASL #5,D0
   OR \2,D0				;B4:signe B3:pas B2:1/2 pas B1:1/4 pas  +1/8 pas
   ADD (a1,D0),\1		;+ pas
   BVC.S *+14
   BPL.S *+8
   MOVE #32767,\1
   BRA.S *+6
	MOVE #-32768,\1	;‚crˆtage
	ADD (a0,\2),\3	;nouvelle valeur d'index
   BPL.S *+6
   CLR \3
	BRA.S *+12
	CMP #88,\3
   BLS.S *+6
   MOVE #88,\3
	ENDM

GADDR MACRO	; dn,flag   GADDR dn or GADDR dn,1 to save in tree
;	movem.l d0-d2/a0-a2,-(sp)
;	move.l \1,rg_int
;	GEM_AES rsrc_gaddr
;	movem.l (sp)+,d0-d2/a0-a2
;	move.l rg_int,\1
	move.l ([_dialog_table,\1.l*4]),a0
;	cmp.l tree,a0
;	beq.s *+4
;	illegal
	if \#=2
		move.l a0,tree
	endif
	ENDM
	
GETALERT MACRO ; n alert number
	moveq #\1,d0
	move.l ([alert_adr],d0.l*4),a0
	ENDM	

	text

GROSMPG equ $30000
	; **************** Several Initialisations **********************

	bra.l skip_iv32

real_freq_tab:
	dc.l 12584,25169,50352,0	; TT freq + delay = 0
	dc.l 12929,24585,49170,0	; Falcon freq + delay = 0
	dc.l 12300,24594,49165,0	; Aranym freq + delay = 0

IV_SIZE equ 94208		; size when decrunch
_iv32:
	INCBIN "IV32TAB.BIN"
	even.l

mpg_read_data:
	move.b Output_Type(pc),d1
	move.w #32767,d2
	cmp.b #3,d1
	beq.s .mode
	moveq #4,d2
	cmp.b #2,d1
	beq.s .mode
	moveq #0,d2
.mode:
	move.w d2,Full_Block_Sav
.again:
	lea temporal_reference_wrap(pc),a0
	moveq #0,d0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	moveq #-1,d0
	move.l d0,(a0)+
	moveq #0,d0
	move.l d0,(a0)+
	move.l d0,(a0)+
	bsr Init_Trapcs
	bsr Initialize_Buffer
	move.l Rdptr(pc),a5
	move.l Incnt(pc),d6
	bfextu (a5){d6:8},d0
	cmp.b #$47,d0
	beq .fin
	bsr next_start_code
	move.l Incnt(pc),d6
	bfextu (a5){d6:32},d0
	moveq #0,d1
	cmp.l #$1b3,d0
	beq.s .ok
	cmp.l #$1ba,d0
	bne.s .voir
.des_paquets:
	moveq #1,d1
	bra.s .ok
.voir:
	cmp.l #$1e0,d0
	beq.s .des_paquets
	bra.s .fin
.ok:
	move.b d1,System_Stream_Flag
	bsr Initialize_Buffer
	bsr Initialize_Decoder
	bsr.l install_traps
	trap #10
	move.l d0,start_time	; start for statistics
	move.l d0,timer_c		; current time for synchro
	bsr Decode_Bitstream
	trap #10
	move.l d0,end_time	; end for statistics
	bsr.l remove_traps
	bsr Restore_Trapcs
	btst #2,([kbshift])
	sne stopped
	bne.s .no_rep
	tst.b is_rep
	bne .again
.fin:
.no_rep:
	bclr #2,([kbshift])
	sf stopped
	move.l disp_frame,d0
	cmp.l sample_num,d0
	bmi.s .ok2
	move.l d0,sample_num
.ok2:
	tst.b is_tt
	beq.s .lb1
	clr.l buffer
.lb1:
	rts

	; even.q
next_start_code:
	lea Incnt+2(pc),a0
	addq.w #7,(a0)
	trapcs
	and.w #-8,(a0)
	move.l -2(a0),d0
	lsr.l #3,d0
	move.l Rdptr(pc),a1
	add.l d0,a1
.nsc2:
	tst.b (a1)+
	beq.s .nsc1
.nsc3:
	addq #8,(a0)
	bcc.s .nsc2
	trapcs
	move.l Rdptr(pc),a1
	bra.s .nsc2
.nsc1:
	tst.b (a1)
	bne.s .nsc3
	cmp.b #1,1(a1)
	bne.s .nsc3
	rts

Init_Trapcs:
	pea .inst(pc)
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp
	move.l #Rdbfr,d0
	add.l #255,d0
	and.l #$FFFFFF00,d0
	move.l d0,Rdptr
	rts
.inst:
	move.w #28,a0				; ‚tendu … LONG
	move.l (a0),Sauve_Vecteur
	move.l #vecteur,(a0)
	move.l $4f2.w,a0
	move.l 36(a0),kbshift	; address of the special keys
	rts

vecteur:
	tst.b System_Stream_Flag(pc)
	bne.s .v4	; cas de blocs entrelaces
	movem.l d0-d2/a0-a2,-(sp)
	move.l 26(sp),a0
	cmp #$55fc,(a0)
	bne.s .pas_bug
	addq.l #2,26(sp)
.pas_bug:
	move.l Rdptr(pc),a0
	move.l 8192(a0),(a0)+
	pea (a0)
	move.l #8192,-(sp)
	move.w mov_h,-(sp)
	move.w #63,-(sp)
	trap #1
	add.w #12,sp
	sub.l #8192,d0
	beq.s .v1
	neg.l d0
	lsr.l #2,d0
	move.l Rdptr(pc),a0
	lea 8196(a0),a0
	move.l #256+183,d1
	bra.s .v2
.v3:
	move.l d1,-(a0)
.v2:
	dbf d0,.v3
.v1:
	movem.l (sp)+,d0-d2/a0-a2
	rte
.v4:
	movem.l d0-d4/a0-a4,-(sp)
	move.l 42(sp),a0
	cmp #$55fc,(a0)
	bne.s .pas_bug2
	addq.l #2,42(sp)
.pas_bug2:
	move.l #.vecteur2,28.w   ; nouveau trap!
	move.l Rdptr(pc),a1
	move.l 8192(a1),(a1)+
	move #8191,d4
	lea Sas,a3
	move.l Sasptr(pc),d3
	add.l d3,a3
	move.l Sasflag(pc),a4
.ajoute:
	cmp.l a3,a4
	beq.s .boucle	  ; fin de copie
	move.b (a3)+,(a1)+
	addq.w #1,d3
	trapcs
	dbf d4,.ajoute
.sort:
	move.l a4,Sasflag
	sub.l #Sas,a3
	move.l a3,Sasptr
	move.l #vecteur,28.w	; ancien trap
	movem.l (sp)+,d0-d4/a0-a4
	rte
.boucle:
	move.l (a3)+,d0
	addq.w #4,d3
	trapcs
	move.l d0,d2
	moveq.l #-1,d1
	not.b d1
.np1:
	and.l d1,d0
	cmp.l #$100,d0
	beq.s .np2
	lsl.l #8,d2
	move.b (a3)+,d2
	addq.w #1,d3
	trapcs
	move.l d2,d0
	bra.s .np1
.np2:
	cmp.l #$1BA,d2
	bne.s .np3
	addq.l #8,a3
	addq.w #8,d3
	trapcs
	bra.s .boucle
.np3:
	cmp.l #$1E0,d2
	bne.s .np4
	moveq #0,d0
	move.w (a3)+,d0
	addq.w #2,d3
	trapcs
	lea 0(a3,d0.l),a4
	moveq #0,d0
	move.b (a3)+,d0
	addq.w #1,d3
	trapcs
	move.l d0,d2
	lsr.b #6,d0
	cmp.b #2,d0
	bne.s .np5
	moveq #0,d0
	move.b 1(a3),d0
	addq.w #2,d0
	add.l d0,a3
	add.w d0,d3
	trapcs
	bra .ajoute
.np5:
	cmp.b #255,d2
	bne.s .np6
	move.b (a3)+,d2
	addq.w #1,d3
	trapcs
	bra.s .np5
.np6:
	cmp #64,d2
	bmi.s .np7
	move.b 1(a3),d2
	addq.l #2,a3
	addq.w #2,d3
	trapcs
.np7:
	cmp #48,d2
	bmi.s .np8
	moveq.l #9,d0
	add.l d0,a3
	add.w d0,d3
	trapcs
	bra .ajoute
.np8:
	cmp #32,d2
	bmi .ajoute
	addq.l #4,a3
	addq.w #3,d3
	trapcs
	bra .ajoute
.np4:
	cmp #$1B9,d2
	bne.s .np9
.np10:
	move.l #$000001B7,(a1)+
	subq.w #4,d4
	bpl.s .np10
	bra .sort
.np9:
	moveq #0,d0
	move.w (a3)+,d0
	addq.w #2,d3
	trapcs
;	tst.b mpg_sound(pc)
;	beq.s .pas_chercher_son
;	cmp #$1C0,d2
;	bne.s .pas_chercher_son
;	bsr mpg_sound_infos
	sf mpg_sound
.pas_chercher_son:
	add.l d0,a3
	add.w d0,d3
	trapcs
	bra .boucle

	; even.q
.vecteur2:
	movem.l d0-d2/a0-a2,-(sp)
	move.l 26(sp),a0
	cmp #$55fc,(a0)
	bne.s .pas_bug3
	addq.l #2,26(sp)
.pas_bug3:
	lea Sas,a0
	move.l #65536,d0
	move.l 0(a0,d0.l),(a0)+
	sub.l d0,a3
	sub.l d0,a4
	pea (a0)
	move.l d0,-(sp)
	move.w mov_h,-(sp)
	move.w #63,-(sp)
	trap #1
	add.w #12,sp
	move.l d0,a0
	sub.l #65536,d0
	beq.s .fin_vect2
	add.l #Sas,a0
	neg.l d0
	lsr.l #2,d0		; paquets de 4
	move.l #$000001B9,d1
	bra.s .areu
.remplit_fin:
	move.l d1,(a0)+
.areu:
	dbf d0,.remplit_fin
.fin_vect2:
	movem.l (sp)+,d0-d2/a0-a2
	rte

Restore_Trapcs:
	pea .deinst(pc)
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp
	rts
.deinst:
	move.l Sauve_Vecteur,28.w
	rts

Decode_Bitstream:
	move.l sp,adresse_retour
	moveq #0,d0
	move.l d0,sample_num
debi0:
	bsr Get_Hdr
	cmp #1,d0
	bne debifin
	moveq #0,d0
	move.l d0,Sequence_Framenum
	move.l d0,disp_frame
	move.b progressive_sequence(pc),d0
	moveq #0,d1
	move.b chroma_format(pc),d1
	move.b MPEG2_Flag(pc),d2
	bne.s debi1
	moveq #1,d0
	move.b #3,picture_structure
	move.b d0,progressive_sequence
	moveq #1,d1
	move.l d0,frame_pred_frame_dct
	move.b d1,chroma_format
debi1:
	move.l horizontal_size(pc),d3
	add #15,d3
	lsr #4,d3
	move.l d3,mb_width
	move.l vertical_size(pc),d4
	tst.b d2
	beq.s debi2
	tst.b d0
	bne.s debi2
	add #31,d4
	lsr #5,d4
	add d4,d4
	bra.s debi3
	even.l
table_6_20: dc.b 0,6,8,12
debi2:
	add #15,d4
	lsr #4,d4
debi3:
	move.l d4,mb_height
	lsl #4,d3
	lsl #4,d4
	move.l d3,Coded_Picture_Width
	move.l d3,d0
	move.l d4,Coded_Picture_Height
	move.l d4,d2
	cmp.b #3,d1
	beq.s debi4
	lsr #1,d0
debi4:
	cmp.b #1,d1
	bne.s debi5
	lsr #1,d2
debi5:
	move.l d0,Chroma_Width
	move.l d2,Chroma_Height
	move.b table_6_20(pc,d1.l),d1
	move.l d1,block_count
	muls.l d4,d3 ; taille y
	tst.b is_tt
	beq.s .normal
	move.l d3,d0
	add.l d0,d0
	add.l d3,d0	; trois buffers Y
	add.l #153616,d0
	bra.s .alloue
.normal:
	muls.l d0,d2 ; taille chroma
	move.l d2,d0
	add.l d2,d0
	add.l d3,d0	; pour une image y + 2 chroma
	move.l d0,d1
	add.l d0,d0
	add.l d1,d0	; pour 3 images
.alloue:
	move #3,-(sp)
	move.l d0,-(sp)
	move.w #68,-(sp)
	trap #1       ; alloue les buffers
	addq.l #8,sp
	lea backward_reference_frame(pc),a0
	lea forward_reference_frame(pc),a1
	lea auxframe(pc),a2
	move.l d0,(a0)+
	add.l d3,d0
	move.l d0,(a1)+
	add.l d3,d0
	move.l d0,(a2)+
	add.l d3,d0		; trois blocs Y
	tst.b is_tt
	beq.s .pas_tt
	addq.l #7,d0
	addq.l #8,d0
	and.b #$F0,d0		; align‚ sur 16 (au cas ou...)
	move.l d0,a0		; vider un bloc comme buffer temporaire
	move.l d0,image
	move #9599,d3
	moveq #0,d1
.vide_temp:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d3,.vide_temp
	bra.s debi7
.pas_tt:
	move.l d0,(a0)+
	add.l d2,d0
	move.l d0,(a1)+
	add.l d2,d0
	move.l d0,(a2)+
	add.l d2,d0		; trois blocs U
	move.l d0,(a0)
	add.l d2,d0
	move.l d0,(a1)
	add.l d2,d0
	move.l d0,(a2)		; trois blocs V
	bra.s debi7
debi8:
	bsr Get_Hdr
	tst d0
	beq.s debi6
debi7:
	bsr Decode_Picture
	tst.b Second_Field(pc)
	bne.s debi8
;	addq.l #1,disp_frame
	addq.l #1,Sequence_Framenum
	bra.s debi8
debi6:
	tst.l Sequence_Framenum(pc)
	beq.s debi9
	tst.b Second_Field(pc)
	bne.s debi9
	move.l compression,a1
	lea backward_reference_frame(pc),a0
	tst.b step_mode
	bne.s .lb0
	move.l timer_c,d1
.lb1:
	trap #10
	cmp.l d0,d1
	bpl.s .lb1
	add.l _delay,d1
	move.l d1,timer_c
.lb0:	
	jsr (a1)
debi9:
	sf MPEG2_Flag
	move.l backward_reference_frame(pc),-(sp)
	move #73,-(sp)
	trap #1
	addq.l #6,sp
debifin:
	rts

mpg_tc_color_full:
	move.l (a0)+,a2 ; y
	move.l (a0)+,a1 ; u
	move.l (a0),a0  ; v
	move.l horizontal_size(pc),d2
	move.l vertical_size(pc),d3
	move.l image,a3
	move.b chroma_format(pc),d0
	moveq #0,d5
	move.l hc_cvid,a4
	move screenw,d5
	add d5,d5
	cmp.b #1,d0  ; seul le CHROMA420
	bne mpg_commun
.dic7:
	lea 0(a3,d5.l*2),a5
	move d2,d1
.dic6:
	moveq #0,d0
	move.b (a1)+,d0
	add.b #$80,d0
	lsl #5,d0
	move.b (a0)+,d0
	add.b #$80,d0
	lsl.l #5,d0
	move.b (a2,d2.l),d0
	move.w 0(a4,d0.l*2),0(a3,d5.l)
	move.b (a2)+,d0
	move.w 0(a4,d0.l*2),(a3)+
	move.b (a2,d2.l),d0
	move.w 0(a4,d0.l*2),0(a3,d5.l)
	move.b (a2)+,d0
	move.w 0(a4,d0.l*2),(a3)+
	subq #2,d1
	bgt.s .dic6
	move.l a5,a3
	add.l d2,a2
	subq #2,d3
	bgt.s .dic7
	bra mpg_commun

mpg_tc_color_half:
	move.l (a0)+,a2 ; y
	move.l (a0)+,a1 ; u
	move.l (a0),a0  ; v
	move.l horizontal_size(pc),d2
	move.l vertical_size(pc),d3
	move.l image,a3
	move.b chroma_format(pc),d0
	moveq #0,d5
	move.l hc_cvid,a4
	move screenw,d5
	add d5,d5
	cmp.b #1,d0  ; seul le CHROMA420
	bne mpg_commun
.dic4:
	lea 0(a3,d5.l),a5
	move d2,d1
.dic5:
	moveq #0,d0
	move.b (a1)+,d0
	add.b #$80,d0
	lsl #5,d0
	move.b (a0)+,d0
	add.b #$80,d0
	lsl.l #5,d0
	move.b (a2),d0
	addq.l #2,a2
	move.w 0(a4,d0.l*2),(a3)+
	subq #2,d1
	bgt.s .dic5
	move.l a5,a3
	add.l d2,a2
	subq #2,d3
	bgt.s .dic4
	bra.s mpg_commun

mpg_tc_grey_full:
	move.l (a0),a0 ; y
	move.l horizontal_size(pc),d2
	move.l vertical_size(pc),d3
	move.l image,a2
	moveq #0,d5
	lea cvid_fix0,a1
	move screenw,d5
	moveq #0,d0
	add d5,d5
	subq #1,d2
	subq #1,d3
.dg5:
	lea 0(a2,d5.l),a3
	move d2,d1
.dg6:
	move.b (a0)+,d0
	move.w 0(a1,d0.l*2),(a2)+
	dbf d1,.dg6
	move.l a3,a2
	dbf d3,.dg5
	bra.s mpg_commun

mpg_tc_grey_half:
	move.l (a0),a0 ; y
	move.l horizontal_size(pc),d2
	move.l vertical_size(pc),d3
	moveq #0,d5
	move.l image,a2
	move screenw,d5
	lea cvid_fix0,a1
	add d5,d5
	moveq #0,d0
.dg4:
	lea 0(a2,d5.l),a3
	move d2,d1
.dg7:
	addq.l #1,a0
	move.b (a0)+,d0
	move.w 0(a1,d0.l*2),(a2)+
	subq #2,d1
	bgt.s .dg7
	move.l a3,a2
	add.l d2,a0
	subq #2,d3
	bgt.s .dg4
	; suit dans mpg_commun

mpg_commun:
	tst.b is_vdi
	beq.s .no_vdi
	movem.l a0-a4/d0-d6,-(sp)
	jsr vdi_display
	movem.l (sp)+,a0-a4/d0-d6
.no_vdi:
	addq.l #1,disp_frame
	tst.b step_mode
	beq.s .suite
	bsr.l inc_frame
	beq.s .quit
	bpl.s .suite_step
	bsr.l save_frame
	bmi.s .quit
	bra.s .suite_step
.quit:
	bsr.l close_step_dialog
	bra sortie
.suite:
	btst #2,([kbshift])
	bne sortie
.suite_step:		; in step mode, Q to quit, not Control.
	rts


mpg_tc_color_dirty:
	move.l (a0)+,a2 ; y
	move.l (a0)+,a1 ; u
	move.l (a0),a0  ; v
	move.l horizontal_size(pc),d2
	move.l vertical_size(pc),d3
	move.l image,a3
	move.b chroma_format(pc),d0
	moveq #0,d5
	move.l hc_cvid,a4
	move screenw,d5
	add d5,d5
	cmp.b #1,d0  ; seul le CHROMA420
	bne.s mpg_commun
	lea block,a5
	moveq #0,d7
	moveq #15,d4
.dic8:
	move.l d7,(a5)+
	move.l d7,(a5)+
	move.l d7,(a5)+
	move.l d7,(a5)+
	dbf d4,.dic8
	moveq #0,d7
	move.l a6,-(sp)
.dic3:
	swap d3
	lea 0(a2,d2.l*8),a5
	move.l a5,d4
	lea 0(a1,d2.l*2),a5
	move.l a5,d6
	lea 0(a3,d5.l*2),a6
	lea block,a5
	move d2,d1
	swap d2
	move.b (a2),d3
.dic2:
	moveq #0,d7
	move.b (a1),d7
	addq.l #4,a1
	add.b #$80,d7
	lsl #5,d7
	move.b (a0),d7
	addq.l #4,a0
	add.b #$80,d7
	lsl.l #5,d7
	move.b d3,d7
	addq.l #8,a2
	move.b d7,d0
	move.w 0(a4,d7.l*2),0(a3,d5.l)
	move.b (a5),d3
	move.b d0,(a5)+
	add d0,d3
	lsr #1,d3
	move.b d3,d7
	move.w 0(a4,d7.l*2),(a3)+
	move.b (a2),d3
	add d3,d0
	lsr #1,d0
	move.b d0,d7
	move.w 0(a4,d7.l*2),0(a3,d5.l)
	move.b (a5),d2
	move.b d0,(a5)+
	add d2,d0
	lsr #1,d0
	move.b d0,d7
	move.w 0(a4,d7.l*2),(a3)+
	subq #8,d1
	bgt.s .dic2
	move.l a6,a3
	move.l d4,a2
	sub.l a1,d6
	add.l d6,a0
	add.l d6,a1
	clr d2
	swap d3
	swap d2
	subq #8,d3
	bgt .dic3
	move.l (sp)+,a6
	bra mpg_commun

mpg_tc_grey_dirty:
	move.l (a0),a0 ; y
	move.l horizontal_size(pc),d2
	move.l vertical_size(pc),d3
	move.l image,a2
	lea cvid_fix0,a1
	lea block,a5
	moveq #0,d5
	moveq #15,d4
.dg9:
	move.l d5,(a5)+
	move.l d5,(a5)+
	move.l d5,(a5)+
	move.l d5,(a5)+
	dbf d4,.dg9
	move screenw,d5
	moveq #0,d4
	moveq #0,d0
	add d5,d5
	moveq #0,d6
.dg8:
	lea block,a5
	lea 0(a2,d5.l*2),a3
	lea 0(a0,d2.l*8),a4
	move d2,d1
	move.b (a0),d4
.dg3:
	move.b d4,d0
	addq.l #8,a0
	move.w 0(a1,d0.l*2),0(a2,d5.l)
	move.b (a5),d4
	move.b d0,(a5)+
	add d0,d4
	lsr #1,d4
	move.w 0(a1,d4.l*2),(a2)+
	move.b (a0),d4
	add d4,d0
	lsr #1,d0
	move.w 0(a1,d0.l*2),0(a2,d5.l)
	move.b (a5),d6
	move.b d0,(a5)+
	add d6,d0
	lsr #1,d0
	move.w 0(a1,d0.l*2),(a2)+
	subq.w #8,d1
	bgt.s .dg3
	move.l a3,a2
	move.l a4,a0
	subq #8,d3
	bgt.s .dg8
	bra mpg_commun

mpg_256_grey_full:
	addq.l #1,disp_frame
	move.l (a0),a0 ; y
	move.l horizontal_size(pc),d2
	move.l vertical_size(pc),d3
	move.l image,a2
	moveq #0,d5
	move screenw,d5
	moveq #0,d0
	subq #1,d2
	subq #1,d3
.dg5:
	lea 0(a2,d5.l),a3
	move d2,d1
.dg6:
	move.b (a0)+,(a2)+
	dbf d1,.dg6
	move.l a3,a2
	dbf d3,.dg5
	btst #2,([kbshift])
	bne sortie
	rts


mpg_256_grey_half:
	addq.l #1,disp_frame
	move.l (a0),a0 ; y
	move.l horizontal_size(pc),d2
	move.l vertical_size(pc),d3
	moveq #0,d5
	move.l image,a2
	move screenw,d5
	moveq #0,d0
.dg4:
	lea 0(a2,d5.l),a3
	move d2,d1
.dg7:
	addq.l #1,a0
	move.b (a0)+,(a2)+
	subq #2,d1
	bgt.s .dg7
	move.l a3,a2
	add.l d2,a0
	subq #2,d3
	bgt.s .dg4
	btst #2,([kbshift])
	bne sortie
	rts

mpg_256_grey_dirty:
	;addq.l #1,disp_frame
	move screenw,d5
	; ici … 6 octets du d‚but
	addq.l #1,disp_frame
	move.l image,a2
	move.l (a0),a0 ; y
	ext.l d5
	move.l horizontal_size(pc),d2
	move.l vertical_size(pc),d3
	lea block,a5
	moveq #0,d6
	moveq #15,d4
.dg9:
	move.l d6,(a5)+
	move.l d6,(a5)+
	move.l d6,(a5)+
	move.l d6,(a5)+
	dbf d4,.dg9
	moveq #0,d4
	moveq #0,d6
.dg8:
	lea block,a5
	lea 0(a2,d5.l*2),a3
	lea 0(a0,d2.l*8),a4
	move d2,d1
	move.b (a0),d4
.dg3:
	move.b d4,d0
	addq.l #8,a0
	move.b d0,0(a2,d5.l)
	move.b (a5),d4
	move.b d0,(a5)+
	add d0,d4
	lsr #1,d4
	move.b d4,(a2)+
	move.b (a0),d4
	add d4,d0
	lsr #1,d0
	move.b d0,0(a2,d5.l)
	move.b (a5),d6
	move.b d0,(a5)+
	add d6,d0
	lsr #1,d0
	move.b d0,(a2)+
	subq.w #8,d1
	bgt.s .dg3
	move.l a3,a2
	move.l a4,a0
	subq #8,d3
	bgt.s .dg8
	btst #2,([kbshift])
	bne.s sortie
	rts

mpg_tt_normal:
	addq.l #1,disp_frame
	move.l (a0),image		; plan Y
	bsr.l planes_disp_double+8
	btst #2,([kbshift])
	bne.s sortie
	rts

mpg_tt_dirty:
;	addq.l #1,disp_frame
	move alignwidth,d5	; largeur dans le buffer!
	bsr mpg_256_grey_dirty+6
	bsr.l planes_disp_double+8
	btst #2,([kbshift])
	bne.s sortie
	rts

sortie:
	move.l adresse_retour,sp
	rts

mpg_tt_commun:
	addq.l #1,disp_frame
	bsr.l planes_display+8
	btst #2,([kbshift])
	bne.s sortie
	rts

mpg_tt_xmoins_ymoins:
	move.l (a0),a0			; plan Y
	move.l image,a2		; buffer temporaire
	move.l horizontal_size(pc),d0	; largeur
	move max_imagex,d1	; largeur voulue
	move d1,d2				; conserve
	move.l vertical_size(pc),d7
	move alignwidth,a5	; ben oui!
	move max_imagey,d6
	move d6,d5
	move d6,d3
	subq #1,d5
.saut_de_ligne:
	cmp d7,d3
	bpl.s .ligne
	add.l d0,a0
	add d6,d3
	bra.s .saut_de_ligne
.ligne:
	lea 0(a0,d0),a1		; ligne suivante dans source
	move.l a2,a3			; conserve dest pour dupliquer
	lea 0(a2,a5),a4		; ligne suivante dans dest
	moveq #-1,d4
	add d2,d4				; 319
.encore:
	cmp d0,d1
	bpl.s .prendre
	addq.l #1,a0
	add d2,d1
	bra.s .encore
.prendre:
	add d2,d1
	move.b (a0)+,(a2)+
	sub d0,d1
	dbf d4,.encore
	add d6,d3
	sub d7,d3
	move.l a1,a0
	move.l a4,a2
	dbf d5,.saut_de_ligne
	bra.s mpg_tt_commun


mpg_tt_xplus_ymoins:

mpg_tt_xmoins_yplus:
	move.l (a0),a0			; plan Y
	move.l image,a2		; buffer temporaire
	move.l horizontal_size(pc),d0	; largeur
	move max_imagex,d2	; largeur voulue
	move.l vertical_size(pc),d7
	move alignwidth,a5	; ben oui!
	moveq #0,d3
	move max_imagey,d6
	move d6,d5
	subq #1,d5
.ligne:
	lea 0(a0,d0),a1		; ligne suivante dans source
	move.l a2,a3			; conserve dest pour dupliquer
	lea 0(a2,a5),a4		; ligne suivante dans dest
	moveq #-1,d4
	add d2,d4				; 319
	move d2,d1
.encore:
	cmp d0,d1
	bpl.s .prendre
	addq.l #1,a0
	add d2,d1
	bra.s .encore
.prendre:
	add d2,d1
	move.b (a0)+,(a2)+
	sub d0,d1
	dbf d4,.encore
.voir_encore:
	add d7,d3
	cmp d6,d3
	bpl.s .autre_ligne
	move a5,d4
	lsr #4,d4		; paquets de 16
	move.l a2,d1
	move.l a4,a2
	lea 0(a2,a5),a4
	subq #1,d4		; dbf
.duplique_ligne:
	move.l (a3)+,(a2)+
	move.l (a3)+,(a2)+
	move.l (a3)+,(a2)+
	move.l (a3)+,(a2)+
	dbf d4,.duplique_ligne
	move.l d1,a3
	bra.s .voir_encore
.autre_ligne:
	move.l a1,a0
	move.l a4,a2
	sub d6,d3
	dbf d5,.ligne
	bra mpg_tt_commun

mpg_tt_xplus_yplus:




	; even.q
Decode_Picture:
	move.b picture_structure(pc),d2
	lea Second_Field(pc),a2
	subq.b #3,d2	; 0 si FRAME_PICTURE
	bne.s dp0
	tst.b (a2)
	beq.s dp0
	sf (a2)
dp0:
	bsr.s Update_Picture_Buffers
	bsr picture_data
	tst.l Sequence_Framenum(pc)
	beq.s dp1
	tst.b d2
	beq.s dp2
	tst.b (a2)
	beq.s dp1
dp2:
	lea auxframe(pc),a0
	cmp.b #3,picture_coding_type(pc)
	beq.s dp3
	lea forward_reference_frame(pc),a0
dp3:
	movem.l a2/d2,-(sp)
	move.l compression,a1
	tst.b step_mode
	bne.s .lb0
	move.l timer_c,d1
.lb1:
	trap #10
	cmp.l d0,d1
	bpl.s .lb1
	add.l _delay,d1
	move.l d1,timer_c
.lb0:		
	jsr (a1)
	movem.l (sp)+,a2/d2
dp1:
	tst.b d2
	beq.s dpfin
	not (a2)
dpfin:
	rts

	; even.q
Update_Picture_Buffers:
	lea current_frame(pc),a0
	cmp.b #2,picture_structure(pc)
	beq.s upb0
	cmp.b #3,picture_coding_type(pc)
	bne.s upb1
	lea auxframe(pc),a1
upb2:
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1),(a0)
	rts
upb1:
	lea backward_reference_frame(pc),a1
	tst.b (a2)
	bne.s upb2
	lea forward_reference_frame(pc),a3
	move.l (a3),d0
	move.l (a1),(a3)+
	move.l d0,(a1)+
	move.l d0,(a0)+
	move.l (a3),d0
	move.l (a1),(a3)+
	move.l d0,(a1)+
	move.l d0,(a0)+
	move.l (a3),d0
	move.l (a1),(a3)
	move.l d0,(a1)
	move.l d0,(a0)
	rts
upb0:
	cmp.b #3,picture_coding_type(pc)
	bne.s upb3
	lea auxframe(pc),a1
upb4:
	move.l Coded_Picture_Width(pc),d0
	add.l (a1)+,d0
	move.l d0,(a0)+
	move.l Chroma_Width(pc),d0
	move.l d0,d1
	add.l (a1)+,d0
	add.l (a1),d1
	move.l d0,(a0)+
	move.l d1,(a0)
	rts
upb3:
	lea backward_reference_frame(pc),a1
	tst.b (a2)
	bne.s upb4
	lea forward_reference_frame(pc),a3
	move.l (a3),d0
	move.l (a1),(a3)+
	move.l d0,(a1)+
	add.l Coded_Picture_Width(pc),d0
	move.l d0,(a0)+
	move.l (a3),d0
	move.l (a1),(a3)+
	move.l Chroma_Width(pc),d1
	move.l d0,(a1)+
	add.l d1,d0
	move.l d0,(a0)+
	move.l (a3),d0
	move.l (a1),(a3)
	move.l d0,(a1)
	add.l d1,d0
	move.l d0,(a0)
	rts

	; even.q
Get_Hdr:
gh0:
	bsr next_start_code
	move.l Incnt(pc),d1
	move.l Rdptr(pc),a1
	bfextu (a1){d1:32},d0
	add #32,d1
	trapcs
	cmp.l #$1b3,d0
	bne.s gh1
	bsr sequence_header
	bra.s gh0
gh1:
	cmp.l #$1b8,d0
	bne.s gh2
	bsr group_of_pictures_header
	bra.s gh0
gh2:
	cmp.l #$100,d0
	bne.s gh3
	bsr.s picture_header
	moveq #1,d0
	rts
gh3:
	move d1,Incnt+2
	cmp.l #$1b7,d0
	bne.s gh0
	moveq #0,d0
	rts

	; even.q
picture_header:
;	bfextu (a1){d1:32},d0
	sf pict_scal
	bfextu (a1){d1:13},d0
	add #29,d1
	trapcs
	move.l d0,d2
	lsr #3,d0
	move.l d0,temporal_reference
	and #7,d2
	move.b d2,picture_coding_type
	btst #1,d2		; 2 ou 3 pour P_TYPE ou B_TYPE
	beq.s ph1
	swap d2
	bfextu (a1){d1:4},d0
	move d0,d2
	lsr #3,d0
	and #7,d2
	move.b d0,full_pel_forward_vector
	subq #1,d2
	move.b d2,forward_f_code
	swap d2
	addq #4,d1
	trapcs
	cmp #3,d2
	bne.s ph1
	bfextu (a1){d1:4},d0
	move d0,d2
	lsr #3,d0
	and #7,d2
	move.b d0,full_pel_backward_vector
	subq #1,d2
	move.b d2,backward_f_code
	addq #4,d1
	trapcs
ph1:
	moveq #9,d2
ph3:
	bftst (a1){d1:1}
	beq.s ph2
	add d2,d1
	trapcs
	bra.s ph3
ph2:
	addq #1,d1
	trapcs
	move d1,Incnt+2
	bsr extension_and_user_data
	lea temporal_reference_wrap(pc),a0
	cmp.b #3,picture_coding_type(pc)
	beq.s utrtd1
	move.l temporal_reference(pc),d0
	move.l temporal_reference_old(pc),d1
	cmp.l d0,d1
	beq.s utrtd1
	tst.l (a0)
	beq.s utrtd4
	add.l #1024,Temporal_Reference_Base
	clr.l (a0)
utrtd4:
	lea Temporal_Reference_GOP_Reset(pc),a1
	cmp.l d1,d0
	bpl.s utrtd5
	tst.l (a1)
	bne.s utrtd5
	move #1,2(a0)
utrtd5:
	move.l d0,d1
	move.l d0,temporal_reference_old
	clr.l (a1)
utrtd1:
	move.l Temporal_Reference_Base(pc),d2
	add.l d0,d2
	tst.l temporal_reference_wrap(pc)
	beq.s utrtd2
	cmp.l d0,d1
	bmi.s utrtd2
	add.l #1024,d2
utrtd2:
	move.l d2,True_Framenum
	cmp.l True_Framenum_max,d2
	bmi.s utrtd3
	move.l d2,True_Framenum_max
utrtd3:
	rts
	even.l
temporal_reference_wrap: dc.l 0
temporal_reference_old:  dc.l 0
Temporal_Reference_Base: dc.l 0
True_Framenum_max:       dc.l -1
Temporal_Reference_GOP_Reset: dc.l 0
True_Framenum:           dc.l 0

	; even.q
group_of_pictures_header:
	moveq #1,d0
	move.l d0,Temporal_Reference_GOP_Reset
	add.l True_Framenum_max,d0
	move.l d0,Temporal_Reference_Base
	add #27,d1
	trapcs
	move d1,Incnt+2
	bsr extension_and_user_data
	rts

	; even.q
sequence_header:
	bfextu (a1){d1:12},d0
	add #12,d1
	trapcs
	move.l d0,horizontal_size
	bfextu (a1){d1:12},d0
	add #12,d1
	trapcs
	move.l d0,vertical_size
	bfextu (a1){d1:4},d0
	addq #4,d1
	trapcs
	move.b d0,aspect_ratio_information
	bfextu (a1){d1:4},d0
	add #34,d1
	trapcs
	move.b d0,frame_rate_code
	lea scan(pc),a0
	lea intra_quantizer_matrix,a2
	bftst (a1){d1:1}
	beq.s sh1
	addq #1,d1
	trapcs
	moveq #0,d4
	moveq #63,d2
	moveq #0,d3
sh0:
	move.b 0(a0,d4.l),d3
	bfextu (a1){d1:8},d0
	move.l d0,0(a2,d3.l*4)
	addq #8,d1
	trapcs
	addq #1,d4
	dbf d2,sh0
	bra.s sh2
sh1:
	addq #1,d1
	trapcs
	lea default_intra_quantizer_matrix(pc),a3
	moveq #15,d2
sh3:
	move.b (a3)+,d0
	move.l d0,(a2)+
	move.b (a3)+,d0
	move.l d0,(a2)+
	move.b (a3)+,d0
	move.l d0,(a2)+
	move.b (a3)+,d0
	move.l d0,(a2)+
	dbf d2,sh3
sh2:
	lea non_intra_quantizer_matrix,a2
	bftst (a1){d1:1}
	beq.s sh4
	addq #1,d1
	trapcs
	moveq #0,d4
	moveq #63,d2
	moveq #0,d3
sh5:
	move.b 0(a0,d4.l),d3
	bfextu (a1){d1:8},d0
	move.l d0,0(a2,d3.l*4)
	addq #8,d1
	trapcs
	addq #1,d4
	dbf d2,sh5
	bra.s sh6
sh4:
	addq #1,d1
	trapcs
	moveq #16,d0
	moveq #15,d2
sh7:
	move.l d0,(a2)+
	move.l d0,(a2)+
	move.l d0,(a2)+
	move.l d0,(a2)+
	dbf d2,sh7
sh6:
	move d1,Incnt+2
	lea chroma_intra_quantizer_matrix,a0
	lea intra_quantizer_matrix,a1
	lea chroma_non_intra_quantizer_matrix,a2
	lea non_intra_quantizer_matrix,a3
	moveq #15,d0
sh8:
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a3)+,(a2)+
	move.l (a3)+,(a2)+
	move.l (a3)+,(a2)+
	move.l (a3)+,(a2)+
	dbf d0,sh8
	bsr.s extension_and_user_data
	rts

	; even.q
extension_and_user_data:
eaud0:
 bsr next_start_code
	move.l Incnt(pc),d1
	move.l Rdptr(pc),a1
	bfextu (a1){d1:32},d0
	cmp.l #$1b5,d0
	beq.s eaud1
	cmp.l #$1b2,d0
	beq.s eaud12
	rts
eaud1:
	add #32,d1
	trapcs
	bfextu (a1){d1:4},d0
	addq #4,d1
	trapcs
	subq #1,d0
	bne.s eaud2
	bsr.s sequence_extension
	bra.s eaud11
eaud2:
	subq #2,d0
	bne.s eaud4
	bsr quant_matrix_extension
	bra.s eaud11
eaud4:
	subq #2,d0
	bne.s eaud7
	bsr sequence_scalable_extension
	bra.s eaud11
eaud7:
	subq #3,d0
	bne.s eaud9
	bsr picture_coding_extension
	bra.s eaud11
eaud9:
	subq #1,d0
	bne.s eaud10
	bsr picture_spatial_scalable_extension
	bra.s eaud11
eaud10:
	subq #1,d0
	bne.s eaud11
	nop
; 	bsr picture_temporal_scalable_extension
; erreur si temporal
eaud11:
	move d1,Incnt+2
	bra.s eaud0
eaud12:
	moveq #32,d0
	add d0,Incnt+2
	trapcs
	bra.s eaud0

	; even.q
sequence_extension:
	st MPEG2_Flag
	sf scalable_mode
	addq #8,d1
	trapcs
	bfextu (a1){d1:7},d0
	moveq #0,d2
	lsl.b #2,d0
	addx d2,d2
	move.b d2,progressive_sequence
	moveq #0,d2
	lsl.b #1,d0
	addx d2,d2
	lsl.b #1,d0
	addx d2,d2
	move.b d2,chroma_format
	moveq #0,d2
	lsl.b #1,d0
	addx d2,d2
	lsl.b #1,d0
	addx d2,d2
	lsl #6,d0
	or.l d0,vertical_size
	moveq #12,d0
	lsl d0,d2
	or.l d2,horizontal_size
	add #36,d1
	trapcs
	rts

	; even.q
quant_matrix_extension:
	lea scan(pc),a0
	bfextu (a1){d1:1},d0
	addq #1,d1
	trapcs
	tst d0
	beq.s qme1
	lea chroma_intra_quantizer_matrix,a2
	lea intra_quantizer_matrix,a3
	moveq #0,d4
	moveq #63,d2
	moveq #0,d3
qme0:
	move.b 0(a0,d4.l),d3
	bfextu (a1){d1:8},d0
	move.l d0,0(a2,d3.l*4)
	addq #8,d1
	trapcs
	move.l d0,0(a3,d3.l*4)
	addq #1,d4
	dbf d2,qme0
qme1:
	bfextu (a1){d1:1},d0
	addq #1,d1
	trapcs
	tst d0
	beq.s qme3
	lea chroma_non_intra_quantizer_matrix,a2
	lea non_intra_quantizer_matrix,a3
	moveq #0,d4
	moveq #63,d2
	moveq #0,d3
qme2:
	move.b 0(a0,d4.l),d3
	bfextu (a1){d1:8},d0
	move.l d0,0(a2,d3.l*4)
	addq #8,d1
	trapcs
	move.l d0,0(a3,d3.l*4)
	addq #1,d4
	dbf d2,qme2
qme3:
	bfextu (a1){d1:1},d0
	addq #1,d1
	trapcs
	tst d0
	beq.s qme5
	lea chroma_intra_quantizer_matrix,a2
	moveq #0,d4
	moveq #63,d2
	moveq #0,d3
qme4:
	move.b 0(a0,d4.l),d3
	bfextu (a1){d1:8},d0
	addq #8,d1
	trapcs
	move.l d0,0(a2,d3.l*4)
	addq #1,d4
	dbf d2,qme4
qme5:
	bfextu (a1){d1:1},d0
	addq #1,d1
	trapcs
	tst d0
	beq.s qme7
	lea chroma_non_intra_quantizer_matrix,a2
	moveq #0,d4
	moveq #63,d2
	moveq #0,d3
qme6:
	move.b 0(a0,d4.l),d3
	bfextu (a1){d1:8},d0
	addq #8,d1
	trapcs
	move.l d0,0(a2,d3.l*4)
	addq #1,d4
	dbf d2,qme6
qme7:
	rts

	; even.q
sequence_scalable_extension:
	bfextu (a1){d1:2},d0
	addq #1,d0
	move.b d0,scalable_mode
	addq #6,d1
	trapcs
	cmp #2,d0
	bne.s sse1
	add #49,d1
	trapcs
sse1:	; si d0=4, erreur (temporal non support‚)
	rts

	; even.q
picture_coding_extension:
	lea f_code(pc),a0
	bfextu (a1){d1:16},d0
	add #16,d1
	trapcs
	swap d0
	moveq #-1,d2
	rol.l #4,d0
	add d0,d2
	clr d0
	move d2,(a0)+
	moveq #-1,d2
	rol.l #4,d0
	add d0,d2
	clr d0
	move d2,(a0)+
	moveq #-1,d2
	rol.l #4,d0
	add d0,d2
	clr d0
	move d2,(a0)+
	rol.l #4,d0
	subq #1,d0
	move d0,(a0)+
	bfextu (a1){d1:14},d0
	add #14,d1
	trapcs
	swap d0
	moveq #3,d2
	rol.l #4,d0
	sub d0,d2
	clr d0
	move.b d2,intra_dc_precision
	rol.l #2,d0
	move.b d0,picture_structure
	clr d0
	rol.l #1,d0
	move.b d0,top_field_first
	clr d0
	rol.l #1,d0
	move d0,d2
	clr d0
	move.l d2,frame_pred_frame_dct
	rol.l #1,d0
	move.b d0,concealment_motion_vectors
	clr d0
	rol.l #1,d0
	move.b d0,q_scale_type
	clr d0
	rol.l #1,d0
	move.b d0,intra_vlc_format
	clr d0
	rol.l #1,d0
	move d0,d2
	clr d0
	lsl.l #6,d2
	lea (scan,pc,d2.l),a0
	move.l a0,alternate_scan
	rol.l #1,d0
	clr d0
	lsl.l #2,d0
	bpl.s pce1
	add #20,d1
	trapcs
pce1:
	rts

	; even.q
picture_spatial_scalable_extension:
	sf pict_scal
	add #42,d1
	trapcs
	bfextu (a1){d1:2},d0
	move.b d0,spatial_temporal_weight_code_table_index
	addq #4,d1
	trapcs
	rts

	; even.q
picture_data:
	move.l a2,-(sp)
	move.l mb_width(pc),d0
	move.l d2,-(sp)
	muls.l mb_height(pc),d0
	cmp.b #3,picture_structure(pc)
	beq.s pd1
	lsr.l #1,d0
pd1:
	move.l d0,MBAmax
pd0:
	moveq #0,d7
	move.l d7,MBA
	move.l d7,MBAinc
	bsr.s start_of_slice
	cmp #1,d0
	bne.s pdfin
	sf Fault_Flag
pd2:
	move.l MBA(pc),d0
	cmp.l MBAmax(pc),d0
	bpl.s pdfin
	tst.l MBAinc(pc)
	bne.s pd3
	tst.b Fault_Flag(pc)
	bne.s pd4
	move.l Rdptr(pc),a0
	move.l Incnt(pc),d0
	bftst (a0){d0:23}
	bne.s pd5
pd4:
	sf Fault_Flag
	bra.s pd0
pd5:
	bsr Get_macroblock_address_increment
	move.l d0,MBAinc
	tst.b Fault_Flag(pc)
	bne.s pd4
pd3:
	move.l MBAinc(pc),d0
	cmp #1,d0
	bne.s pd6
	bsr decode_macroblock
	tst.l d0
	bmi.s pdfin
	beq.s pd4
	bra.s pd7
pd6:
	bsr skipped_macroblock
pd7:
	bsr motion_compensation
	addq.l #1,MBA
	subq.l #1,MBAinc
	bra.s pd2
pdfin:
	movem.l (sp)+,d2/a2
	rts

	; even.q
start_of_slice:
	sf Fault_Flag
	cmp.b #1,scalable_mode(pc)
	seq d7
	bsr.s slice_header
	tst.b d7
	beq.s sos1
	bsr.s slice_header
sos1:
	bsr Get_macroblock_address_increment
	lsl.l #7,d3
	and.l #$ff,d4
	subq.l #1,d3
	add.l d4,d3
	muls.l mb_width(pc),d3
	subq.l #1,d0
	add.l d0,d3
	move.l d3,MBA
	moveq #0,d0
	lea.l dc_dct_pred(pc),a0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	lea.l PMV(pc),a0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	moveq #1,d0
	move.l d0,MBAinc
	rts

	; even.q
slice_header:
	bsr next_start_code
	move.l Rdptr(pc),a1
	move.l Incnt(pc),d1
	bfextu (a1){d1:32},d0
	move.l d0,d4
	add #$FFFFFEFF,d0
	cmp.l #$AE,d0
	bhi.s s_h_1
	add #32,d1
	trapcs
	moveq #0,d3
	move.b MPEG2_Flag(pc),d2
	beq.s s_h6
	move.l vertical_size(pc),d0
	cmp #2800,d0
	bmi.s s_h6
	bfextu (a1){d1:3},d3
	addq #3,d1
	trapcs
s_h6:
	tst.b d7
	beq.s s_h1
	addq #7,d1
	trapcs
s_h1:
	bfextu (a1){d1:5},d0
	addq #5,d1
	trapcs
	tst.b d2
	beq.s s_h2
	tst.b q_scale_type(pc)
	beq.s s_h3
	lea Non_Linear_quantizer_scale(pc),a0
	move.b 0(a0,d0.l),d0
	bra.s s_h2
s_h3:
	add d0,d0
s_h2:
	move.w d0,quantizer_scale
	bra.s s_h5
s_h4:
	addq #8,d1
	trapcs
s_h5:
	bfextu (a1){d1:1},d0
	addq #1,d1
	trapcs
	tst d0
	bne.s s_h4
	move.l d1,Incnt
	rts
s_h_1:
	addq.l #4,sp
	moveq #-1,d0
	rts

	; even.q
Get_macroblock_address_increment:
	moveq #0,d0
	move.l Incnt(pc),d2
	move.l Rdptr(pc),a0
gmai1:
	bfextu (a0){d2:11},d1
	cmp #24,d1
	bpl.s gmai2
	cmp #15,d1
	beq.s gmai3
	cmp #8,d1
	bne.s gmai4
	add.l #33,d0
gmai3:
	add #11,d2
	trapcs
	bra.s gmai1
gmai2:
	cmp #1024,d1
	bmi.s gmai5
	addq #1,d2
	trapcs
	addq.l #1,d0
	move d2,Incnt+2
	rts
gmai4:
	st Fault_Flag
	moveq #1,d0
	move d2,Incnt+2
	rts
	even.l
MBAtab1:
	dc.b -1,0,-1,0,7,5,6,5,5,4,5,4,4,4,4,4
	dc.b 3,3,3,3,3,3,3,3,2,3,2,3,2,3,2,3
gmai5:
	cmp #128,d1
	bmi gmai6
	lsr #6,d1
	lea MBAtab1(pc,d1.l*2),a1
	move.b 1(a1),d1
	add d1,d2
	trapcs
	move.b (a1),d1
	add.l d1,d0
	move d2,Incnt+2
	rts
	even.l
MBAtab2:
	dc.b 33,11,32,11,31,11,30,11,29,11,28,11,27,11,26,11
	dc.b 25,11,24,11,23,11,22,11,21,10,21,10,20,10,20,10
	dc.b 19,10,19,10,18,10,18,10,17,10,17,10,16,10,16,10
	dc.b 15,8,15,8,15,8,15,8,15,8,15,8,15,8,15,8
	dc.b 14,8,14,8,14,8,14,8,14,8,14,8,14,8,14,8
	dc.b 13,8,13,8,13,8,13,8,13,8,13,8,13,8,13,8
	dc.b 12,8,12,8,12,8,12,8,12,8,12,8,12,8,12,8
	dc.b 11,8,11,8,11,8,11,8,11,8,11,8,11,8,11,8
	dc.b 10,8,10,8,10,8,10,8,10,8,10,8,10,8,10,8
	dc.b 9,7,9,7,9,7,9,7,9,7,9,7,9,7,9,7
	dc.b 9,7,9,7,9,7,9,7,9,7,9,7,9,7,9,7
	dc.b 8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7
	dc.b 8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7
gmai6:
	sub #24,d1
	lea (MBAtab2,pc,d1.l*2),a1
	move.b 1(a1),d1
	add d1,d2
	trapcs
	move.b (a1),d1
	add.l d1,d0
	move d2,Incnt+2
	rts

	; even.q
skipped_macroblock:
	moveq #0,d1
	lea.l dc_dct_pred(pc),a1
	move.l d1,(a1)+
	move.l d1,(a1)+
	move.l d1,(a1)+
	move.b picture_coding_type(pc),d2
	cmp.b #2,d2
	bne.s sm1
	lea.l PMV(pc),a1
	move.l d1,(a1)+
	move.l d1,(a1)+
	addq.l #8,a1
	move.l d1,(a1)+
	move.l d1,(a1)
sm1:
	lea.l motion_type(pc),a1
	move.b picture_structure(pc),d1
	cmp.b #3,d1
	bne.s sm2
	moveq #2,d0
	move.l d0,(a1)
	bra.s sm3
sm2:
	moveq #1,d0
	move.l d0,(a1)
	lea.l motion_vertical_field_select(pc),a1
	cmp.b #2,d1
	beq.s sm4
	moveq #0,d0
sm4:
	move.l d0,(a1)+
	move.l d0,(a1)
sm3:
	moveq #0,d0
	cmp.b #1,d2
	bne.s sm5
	moveq #8,d0
sm5:
	move.b d0,stwtype
	moveq #-2,d0
	and.l d0,macroblock_type
	move.l block_count,d0
	lea block,a0
	lsl #3,d0
	moveq #0,d1
	bra.s sm6
sm7:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
sm6:
	dbf d0,sm7
	rts

	; even.q
decode_macroblock:
	move.l Incnt(pc),d6
	move.l Rdptr(pc),a5
; macroblock_modes()
; Get_macroblock_type()
	cmp.b #3,scalable_mode(pc)
	bne.s gmt1
	bfextu (a5){d6:3},d0    ; get_snr_m_t
	beq gmt0
	lea SNRMBtab(pc),a0
	bra gmt2
gmt1:
	move.b picture_coding_type(pc),d0
	subq.b #1,d0
	bne.s gmt3
	tst.b pict_scal(pc) 	     ; I_TYPE
	bne.s gmt4
	bfextu (a5){d6:1},d0    ; get_i_m_t
	bne.s gmt5
	addq #1,d6
	trapcs
	bfextu (a5){d6:1},d0
	bne.s gmt6
	st Fault_Flag
gmt6:
	addq #1,d6
	trapcs
	moveq #17,d0
	bra gmtfin
gmt5:
	addq #1,d6
	trapcs
	moveq #1,d0
	bra gmtfin
gmt4:
	bfextu (a5){d6:4},d0  ; get_i_spatial_m_t
	beq gmt0
	lea spIMBtab(pc),a0
	bra gmt2
gmt3:
	subq.b #1,d0
	bne.s gmt7
	tst.b pict_scal(pc)				; P_TYPE
	bne.s gmt8
	bfextu (a5){d6:6},d0    ; get_p_m_t
	beq gmt0
	cmp #8,d0
	bmi.s gmt9
	lsr #3,d0
	lea PMBtab0(pc),a0
	bra gmt2
gmt9:
	lea PMBtab1(pc),a0
	bra gmt2
gmt8:
	bfextu (a5){d6:7},d0  ; get_p_spatial_m_t
	cmp #2,d0
	bpl.s gmt10
	moveq #0,d0
	bra gmt0
gmt10:
	cmp #16,d0
	bmi.s gmt11
	lsr #3,d0
	lea spPMBtab0(pc),a0
	bra.s gmt2
gmt11:
	lea spPMBtab1(pc),a0
	bra.s gmt2
gmt7:
	subq.b #1,d0
	bne.s gmt12
	tst.b pict_scal(pc)				; B_TYPE
	bne.s gmt13
	bfextu (a5){d6:6},d0    ; get_b_m_t
	beq.s gmt0
	cmp #8,d0
	bmi.s gmt14
	lsr #2,d0
	lea BMBtab0(pc),a0
	bra.s gmt2
gmt14:
	lea BMBtab1(pc),a0
	bra.s gmt2
gmt13:
	bfextu (a5){d6:9},d0  ; get_b_spatial_m_t
	cmp #64,d0
	bmi.s gmt15
	lsr #5,d0
	lea spBMBtab0(pc),a0
	subq #2,d0
	bra.s gmt2
gmt15:
	cmp #16,d0
	bmi.s gmt16
	lsr #2,d0
	lea spBMBtab1(pc),a0
	subq #4,d0
	bra.s gmt2
gmt16:
	cmp #8,d0
	bmi.s gmt17
	lea spBMBtab2(pc),a0
	subq #8,d0
	bra.s gmt2
gmt17:
	moveq #0,d0
	bra.s gmt0
gmt12:
	subq.b #1,d0
	bne.s gmt18
	bfextu (a5){d6:1},d0    ; D_TYPE get_d_m_t
	bne.s gmt19
	st Fault_Flag
gmt19:
	addq #1,d6
	trapcs
	moveq #1,d0
	bra.s gmtfin
gmt18:
	moveq #0,d0
	bra.s gmtfin
gmt2:
	lea 0(a0,d0.l*2),a0	; bloc du tableau
	move.b 1(a0),d0			; len
	add d0,d6
	trapcs
	move.b (a0),d0				; val
	bra.s gmtfin
gmt0:
	st Fault_Flag
gmtfin:
	tst.b Fault_Flag(pc)
	bne mmfin
	move.l d0,macroblock_type
	btst #5,d0
	beq.s mm0
	moveq #0,d2
	move.b spatial_temporal_weight_code_table_index(pc),d2
	bne.s mm1
	moveq #4,d2
	bra.s mm2
	even.l
stwc_table: dc.b 6,3,7,4,2,1,5,4,2,5,7,4
stwclass_table: dc.b 0,1,2,1,1,2,3,3,4,0
mm1:
	bfextu (a5){d6:2},d3
	addq #2,d6
	trapcs
	lsl.l #2,d2
	add.l d3,d2
	move.b stwc_table-4(pc,d2),d2
	bra.s mm2
mm0:
	moveq #0,d2
	moveq #0,d3
	btst #7,d0
	beq.s mm2
	moveq #8,d2
mm2:
	move.b stwclass_table(pc,d2),d3
	move.b d2,stwtype
	move.l frame_pred_frame_dct(pc),a1
	move.b d3,stwclass
	cmp.b #3,picture_structure(pc)
	sne d4
	moveq #12,d2
	and d0,d2
	beq.s mm3
	tst.b d4
	bne.s mm4
	tst.l a1
	beq.s mm4
	moveq #2,d2
	bra.s mm5
mm4:
	bfextu (a5){d6:2},d2
	addq #2,d6
	trapcs
	bra.s mm5
mm3:
	moveq #0,d2
	btst #0,d0
	beq.s mm5
	tst.b concealment_motion_vectors(pc)
	beq.s mm5
	moveq #1,d2
	tst.b d4
	bne.s mm5
	moveq #2,d2
mm5:
	move.l d2,motion_type
	tst.b d4
	bne.s mm6
	cmp #1,d2
	bne.s mm7
	cmp #2,d3
	bpl.s mm7
	moveq #2,d3
	bra.s mm8
mm7:
	moveq #1,d3
mm8:
	cmp #2,d2
	seq d5
	neg.b d5
	bra.s mm9
mm6:
	moveq #1,d3
	moveq #0,d5
	cmp #2,d2
	bne.s mm9
	moveq #2,d3
mm9:
	subq.b #1,d3	; seule la comparaison avec 1 est utile!
	move.b d5,mv_format
	move.b d3,motion_vector_count
	cmp #3,d2
	seq d2
	neg.b d2
	move.b d2,dmv
	moveq #0,d2
	tst.b d4
	bne.s mm10
	tst.b d5
	bne.s mm10
	moveq #1,d2
mm10:
	move.b d2,mvscale
	moveq #0,d2
	tst.b d4
	bne.s mm11
	tst.l a1
	bne.s mm11
	and #3,d0
	beq.s mm11
	bfextu (a5){d6:1},d2
	addq #1,d6
	trapcs
mm11:
	move.l d2,dct_type
mmfin:
	tst.b Fault_Flag(pc)
	bne dm0
	lea PMV(pc),a2
	move.b MPEG2_Flag(pc),d3
	move.l macroblock_type(pc),d2
	btst #4,d2
	beq.s dm1
	bfextu (a5){d6:5},d0
	addq #5,d6
	trapcs
	tst.b d3
	beq.s dm2
	tst.b q_scale_type(pc)
	beq.s dm3
	lea Non_Linear_quantizer_scale(pc),a0
	move.b 0(a0,d0.l),d0
	bra.s dm2
dm3:
	add.l d0,d0
dm2:
	move.w d0,quantizer_scale
dm1:
	move.b concealment_motion_vectors(pc),d4
	beq.s dm4
	btst #0,d2
	bne.s dm6
dm4:
	btst #3,d2
	beq.s dm5
dm6:
	tst.b d3
	beq.s dm7
	moveq #0,d0
	bsr motion_vectors
	bra.s dm5
dm7:
	move.l d4,-(sp)
	moveq #0,d1
	move.l d3,-(sp)
	move.b forward_f_code(pc),d1
	move.l d2,-(sp)
	move.l d1,d4
	swap d4
	move.b full_pel_forward_vector(pc),d4
	move.l a2,a0
	bsr motion_vector
	movem.l (sp)+,d2-d4
dm5:
	tst.b Fault_Flag(pc)
	bne dm0
	btst #2,d2
	beq.s dm9
	tst.b d3
	beq.s dm10
	moveq #1,d0
	bsr motion_vectors
	bra.s dm9
dm10:
	move.l d4,-(sp)
	moveq #0,d1
	move.l d3,-(sp)
	move.b backward_f_code(pc),d1
	move.l d2,-(sp)
	move.l d1,d4
	swap d4
	move.b full_pel_backward_vector(pc),d4
	lea 8(a2),a0
	bsr motion_vector
	movem.l (sp)+,d2-d4
dm9:
	tst.b Fault_Flag(pc)
	bne dm0
	tst.b d4
	beq.s dm11
	btst #0,d2
	beq.s dm11
	addq #1,d6
	trapcs
dm11:
	btst #1,d2
	beq dm12
; Get_coded_block_pattern()
	bfextu (a5){d6:9},d1
	cmp #128,d1
	bmi.s gcbp1
	lsr #4,d1
	lea CBPtab0(pc),a0
	bra gcbp2
gcbp1:
	cmp #8,d1
	bmi.s gcbp3
	lsr #1,d1
	lea CBPtab1(pc),a0
	bra gcbp2
gcbp3:
	lea CBPtab2(pc),a0
	cmp #1,d1
	bpl gcbp2
	moveq #1,d1
	move.b d1,Fault_Flag
	moveq #0,d0
	bra gcbpfin
	even.l
CBPtab0:
	dc.b -1,0,-1,0,-1,0,-1,0
	dc.b -1,0,-1,0,-1,0,-1,0
	dc.b 62,5,2,5,61,5,1,5,56,5,52,5,44,5,28,5
	dc.b 40,5,20,5,48,5,12,5,32,4,32,4,16,4,16,4
	dc.b 8,4,8,4,4,4,4,4,60,3,60,3,60,3,60,3
	even.l
CBPtab1:
	dc.b -1,0,-1,0,-1,0,-1,0
	dc.b 58,8,54,8,46,8,30,8
	dc.b 57,8,53,8,45,8,29,8,38,8,26,8,37,8,25,8
	dc.b 43,8,23,8,51,8,15,8,42,8,22,8,50,8,14,8
	dc.b 41,8,21,8,49,8,13,8,35,8,19,8,11,8,7,8
	dc.b 34,7,34,7,18,7,18,7,10,7,10,7,6,7,6,7
	dc.b 33,7,33,7,17,7,17,7,9,7,9,7,5,7,5,7
	dc.b 63,6,63,6,63,6,63,6,3,6,3,6,3,6,3,6
	dc.b 36,6,36,6,36,6,36,6,24,6,24,6,24,6,24,6
	even.l
CBPtab2:
	dc.b -1,0,0,9,39,9,27,9,59,9,55,9,47,9,31,9
gcbp2:
	moveq #0,d0
	add.l d1,d1
	move.b 1(a0,d1.l),d0
	add d0,d6
	trapcs
	move.b 0(a0,d1.l),d0
gcbpfin:
	move.b chroma_format(pc),d1
	cmp.b #2,d1
	bne.s dm13
	bfextu (a5){d6:2},d1
	lsl.l #2,d0
	addq #2,d6
	trapcs
	or.l d1,d0
	bra.s dm14
dm13:
	cmp.b #3,d1
	bne.s dm14
	bfextu (a5){d6:6},d1
	lsl.l #6,d0
	addq #6,d6
	trapcs
	or.l d1,d0
	bra.s dm14
dm12:
	moveq #0,d0
	btst #0,d2
	beq.s dm14
	moveq #1,d0
	move.l block_count,d1
	lsl.l d1,d0
	subq.l #1,d0
dm14:
	tst.b Fault_Flag(pc)
	bne dm0
	move.w Full_Block_Sav(pc),Full_Block
	lea dc_dct_pred(pc),a1
	btst #0,d2
	beq.s dm15
	move.l d0,d5
	bsr Decode_MPEG1_MPEG2_Intra_Block
	moveq #0,d0
	bra.s dm16
dm15:
	move.l d0,d5
	bsr Decode_MPEG1_MPEG2_Non_Intra_Block
	lea dc_dct_pred(pc),a1
	moveq #0,d0
	move.l d0,(a1)+
	move.l d0,(a1)+
	move.l d0,(a1)
dm16:
	tst.b Fault_Flag(pc)
	bne dm0
	cmp.b #4,picture_coding_type(pc)
	bne.s dm17
	addq #1,d6
	trapcs
dm17:
	lea PMV(pc),a2
	cmp.b #4,stwclass(pc)
	beq.s dm19
	tst.b d4
	bne.s dm18
	btst #0,d2
	beq.s dm18
dm19:
	move.l a2,a0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)
dm18:
	cmp.b #2,picture_coding_type(pc)
	bne dm20
	btst #0,d2
	bne dm20
	btst #3,d2
	bne dm20
	move.l d0,(a2)+
	move.l d0,(a2)
	lea 12(a2),a2
	move.l d0,(a2)+
	move.l d0,(a2)
	move.b picture_structure(pc),d0
	cmp.b #3,d0
	bne.s dm21
	moveq #2,d0
	bra.s dm22
dm21:
	moveq #0,d1
	lea motion_vertical_field_select(pc),a2
	cmp.b #2,d0
	bne.s dm23
	moveq #1,d1
dm23:
	moveq #1,d0
	move.l d1,(a2)
dm22:
	move.l d0,motion_type
	bra dm20

	; even.q
Decode_MPEG1_MPEG2_Intra_Block:
	move.l d4,-(sp)
	swap d5
	move.l d2,-(sp)
	clr d5		; d5 = count et coded_block_pattern
	lea block,a2
dmmi0:
	subq #1,Full_Block
	bmi.s dmmi5
	moveq #0,d7
	moveq #7,d0
dmmi1:
	move.l d7,(a2)+
	move.l d7,(a2)+
	move.l d7,(a2)+
	move.l d7,(a2)+
	dbf d0,dmmi1
	lea -128(a2),a2	; block effac‚
dmmi5:
	moveq #15,d0
	add.l block_count,d0
	sub d5,d0
	btst d0,d5
	beq.s dmmi2
	move.l a1,-(sp)
	move.l a1,d7
	tst.b MPEG2_Flag(pc)
	beq.s dmmi3
	bsr Decode_MPEG2_Intra_Block
	bra.s dmmi4
dmmi3:
	bsr.s Decode_MPEG1_Intra_Block
dmmi4:
	move.l (sp)+,a1
	tst.b Fault_Flag(pc)
	bne.s dmmifin
dmmi2:
	addq #1,d5
	lea 128(a2),a2
	cmp block_count+2,d5
	bmi.s dmmi0
dmmifin:
	movem.l (sp)+,d2/d4
	rts

	; even.q
Decode_MPEG1_Intra_Block:
	tst Full_Block(pc)
	bmi FDecode_MPEG1_Intra_Block
	cmp #4,d5
	bgt.s m1i2
	beq.s m1i1
	bsr Get_Luma_DC_dct_diff
	move.l d7,a0
	add.l (a0),d0
	move.l d0,(a0)
	bra.s m1i3
m1i1:
	bsr Get_Chroma_DC_dct_diff
	move.l d7,a0
	add.l 4(a0),d0
	move.l d0,4(a0)
	bra.s m1i3
m1i2:
	bsr Get_Chroma_DC_dct_diff
	move.l d7,a0
	add.l 8(a0),d0
	move.l d0,8(a0)
m1i3:
	lsl #3,d0
	move d0,(a2)	; bp(0)
	tst.b Fault_Flag(pc)
	bne m1ifin
	cmp.b #4,picture_coding_type(pc)
	beq m1ifin
	moveq #1,d7
m1i4:
	bfextu (a5){d6:16},d0
	move.l (DCTptr,d0.l*4),d0   ; 4 octets: val.b run.b len.w
	bne.s m1i5
m1i10:
	st Fault_Flag
	rts
m1i5:
	add d0,d6   ; flush buffer (tab->len)
	trapcs
	swap d0	; val et run
	cmp.b #64,d0
	bcc.s m1ipart
m1i6:
	move d0,d2
	add.b d0,d7
	lsr #8,d2
	bfextu (a5){d6:1},d3
	addq #1,d6
	trapcs
m1i9:
	cmp #64,d7
	bpl.s m1i10
	moveq #0,d4
	move.b (scan,pc,d7.l),d4  ; j
	muls.w quantizer_scale(pc),d2
	muls.l (intra_quantizer_matrix,d4.l*4),d2
	asr.l #3,d2
	beq.s m1i11
	subq #1,d2
	or #1,d2
m1i11:
	tst.b d3
	bne.s m1i12
	cmp #2048,d2
	bmi.s m1i13
	move #2047,d2
	bra.s m1i13
m1i12:
	cmp #2049,d2
	bmi.s m1i14
	move #2048,d2
m1i14:
	neg d2
m1i13:
	move d2,0(a2,d4.l*2)  ; bp(j)
	addq #1,d7
	bra.s m1i4
m1ipart:
	beq.s m1ifin       ; end of block
	cmp.b #65,d0
	bne.s m1i6
	bfextu (a5){d6:14},d0
	add #14,d6
	trapcs
	move.l d0,d2
	lsr #8,d0
	add.b d0,d7
	and #$FF,d2     ; val
	bne.s m1i15
	bfextu (a5){d6:8},d2
	addq #8,d6
	trapcs
	bra.s m1i8
m1i15:
	cmp #128,d2
	bgt.s m1i7
	bne.s m1i8
	bfextu (a5){d6:8},d2
	addq #8,d6
	trapcs
m1i7:
	sub.l #256,d2
m1i8:
	tst d2
	smi d3
	bpl m1i9
	neg.l d2
	bra m1i9
m1ifin:
	rts

	; even.q
Decode_MPEG2_Intra_Block:
	tst Full_Block(pc)
	bmi FDecode_MPEG2_Intra_Block
	cmp #4,d5
	bmi.s m2i2
	moveq #1,d1
	cmp.b chroma_format(pc),d1
	beq.s m2i2
	lea chroma_intra_quantizer_matrix,a4
	bra.s m2i16
m2i2:
	lea intra_quantizer_matrix,a4
m2i16:
	cmp #4,d5
	bgt.s m2i7
	beq.s m2i8
	bsr Get_Luma_DC_dct_diff
	move.l d7,a0
	add.l (a0),d0
	move.l d0,(a0)
	bra.s m2i3
m2i8:
	bsr Get_Chroma_DC_dct_diff
	move.l d7,a0
	add.l 4(a0),d0
	move.l d0,4(a0)
	bra.s m2i3
m2i7:
	bsr Get_Chroma_DC_dct_diff
	move.l d7,a0
	add.l 8(a0),d0
	move.l d0,8(a0)
m2i3:
	tst.b Fault_Flag(pc)
	bne m2ifin
	move.b intra_dc_precision(pc),d1
	lsl d1,d0
	moveq #1,d7
	move d0,(a2)	; bp(0)
m2i4:
	bfextu (a5){d6:16},d0
	tst.b intra_vlc_format(pc)
	beq.s m2i1
	cmp.l #1024,d0
	bmi.s m2i11
	lsr.l #8,d0
	subq.l #4,d0
	move.l (DCTtab0a,d0.l*4),d0
	bra.s m2i5
m2i11:
	cmp.l #512,d0
	bmi.s m2i1
	lsr.l #6,d0
	subq.l #8,d0
	move.l (DCTtab1a,d0.l*4),d0
	bra.s m2i5
m2i1:
	move.l (DCTptr,d0.l*4),d0   ; val.b run.b len.w
	bne.s m2i5
m2i10:
	st Fault_Flag
	bra m2ifin
m2i5:
	add d0,d6   ; flush buffer (tab->len)
	trapcs
	swap d0
	cmp.b #64,d0
	bcc.s m2ipart
m2i6:
	move d0,d2
	add.b d0,d7
	lsr #8,d2
	bfextu (a5){d6:1},d3
	addq #1,d6
	trapcs
m2i9:
	cmp #64,d7
	bpl.s m2i10
	moveq #0,d4
	move.l alternate_scan(pc),a0
	muls.w quantizer_scale(pc),d2
	move.b 0(a0,d7.l),d4  ; j
	muls.l 0(a4,d4.l*4),d2
	asr.l #4,d2
	tst.b d3
	beq.s m2i12
	neg d2
m2i12:
	move d2,0(a2,d4.l*2)  ; bp(j)
	addq #1,d7
	bra m2i4
m2ipart:
	beq.s m2ifin       ; end of block
	cmp.b #65,d0
	bne.s m2i6
	bfextu (a5){d6:18},d0
	add #18,d6
	trapcs
	move.l d0,d2
	moveq #12,d1
	lsr.l d1,d0
	add.l d0,d7
	and.l #$FFF,d2     ; val
	bftst d2{21:11}
	beq.s m2i10
	cmp #2048,d2
	spl d3
	bmi.s m2i9
	sub.l #4096,d2
	neg.l d2
	bra.s m2i9
m2ifin:
	rts

	; even.q
FDecode_MPEG1_Intra_Block:   ; seulement coeff 0, autres saut‚s
	cmp #4,d5
	bgt.s fm1i2
	beq.s fm1i1
	bsr Get_Luma_DC_dct_diff
	move.l d7,a0
	add.l (a0),d0
	move.l d0,(a0)
	bra.s fm1i3
fm1i1:
	bsr Get_Chroma_DC_dct_diff
	move.l d7,a0
	add.l 4(a0),d0
	move.l d0,4(a0)
	bra.s fm1i3
fm1i2:
	bsr Get_Chroma_DC_dct_diff
	move.l d7,a0
	add.l 8(a0),d0
	move.l d0,8(a0)
fm1i3:
	lsl #3,d0
	move d0,(a2)	; bp(0)
	tst.b Fault_Flag(pc)
	bne.s fm1ifin
	cmp.b #4,picture_coding_type(pc)
	beq.s fm1ifin
	moveq #1,d7
fm1i4:
	bfextu (a5){d6:16},d0
	move.l (DCTptr,d0.l*4),d0   ; tab
	bne.s fm1i5
fm1i10:
	st Fault_Flag
	bra.s fm1ifin
fm1i5:
	add d0,d6   ; flush buffer (tab->len)
	trapcs
	swap d0
	cmp.b #64,d0
	bcc.s fm1ipart
fm1i6:
	add.b d0,d7
	addq #1,d6
	trapcs
fm1i9:
	cmp #64,d7
	bpl.s fm1i10
	addq #1,d7
	bra.s fm1i4
fm1ipart:
	beq.s fm1ifin       ; end of block
	cmp.b #65,d0
	bne.s fm1i6
	bfextu (a5){d6:14},d0
	add #14,d6
	trapcs
	move.l d0,d2
	lsr #8,d0
	add.b d0,d7
	and #$FF,d2     ; val
	bne.s fm1i15
	addq #8,d6
	trapcs
	bra.s fm1i9
fm1i15:
	cmp #128,d2
	bgt.s fm1i9
	bne.s fm1i9
	addq #8,d6
	trapcs
	bra.s fm1i9
fm1ifin:
	rts

	; even.q
FDecode_MPEG2_Intra_Block:	; seulement coeff 0, autres saut‚s
	cmp #4,d5
	bmi.s fm2i2
	moveq #1,d1
	cmp.b chroma_format(pc),d1
	beq.s fm2i2
	lea chroma_intra_quantizer_matrix,a4
	bra.s fm2i16
fm2i2:
	lea intra_quantizer_matrix,a4
fm2i16:
	cmp #4,d5
	bgt.s fm2i7
	beq.s fm2i8
	bsr Get_Luma_DC_dct_diff
	move.l d7,a0
	add.l (a0),d0
	move.l d0,(a0)
	bra.s fm2i3
fm2i8:
	bsr Get_Chroma_DC_dct_diff
	move.l d7,a0
	add.l 4(a0),d0
	move.l d0,4(a0)
	bra.s fm2i3
fm2i7:
	bsr Get_Chroma_DC_dct_diff
	move.l d7,a0
	add.l 8(a0),d0
	move.l d0,8(a0)
fm2i3:
	tst.b Fault_Flag(pc)
	bne fm2ifin
	move.b intra_dc_precision(pc),d1
	lsl d1,d0
	moveq #1,d7
	move d0,(a2)	; bp(0)
fm2i4:
	bfextu (a5){d6:16},d0
	tst.b intra_vlc_format(pc)
	beq.s fm2i1
	cmp.l #1024,d0
	bmi.s fm2i11
	lsr.l #8,d0
	subq.l #4,d0
	move.l (DCTtab0a,d0.l*4),d0
	bra.s fm2i5
fm2i11:
	cmp.l #512,d0
	bmi.s fm2i1
	lsr.l #6,d0
	subq.l #8,d0
	move.l (DCTtab1a,d0.l*4),d0
	bra.s fm2i5
fm2i1:
	move.l (DCTptr,d0.l*4),d0   ; tab
	bne.s fm2i5
fm2i10:
	st Fault_Flag
	bra.s fm2ifin
fm2i5:
	add d0,d6   ; flush buffer (tab->len)
	trapcs
	swap d0
	cmp.b #64,d0
	bcc.s fm2ipart
fm2i6:
	add.b d0,d7
	addq #1,d6
	trapcs
fm2i9:
	cmp #64,d7
	bpl.s fm2i10
	addq #1,d7
	bra.s fm2i4
fm2ipart:
	beq.s fm2ifin       ; end of block
	cmp.b #65,d0
	bne.s fm2i6
	bfextu (a5){d6:18},d0
	add #18,d6
	trapcs
	move.l d0,d2
	moveq #12,d1
	lsr.l d1,d0
	add.b d0,d7
	and.l #$FFF,d2     ; val
	bftst d2{21:11}
	beq.s fm2i10
	bra.s fm2i9
fm2ifin:
	rts
	even.l
DClumtab0:
	dc.b 1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2
	dc.b 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b 0,3,0,3,0,3,0,3,3,3,3,3,3,3,3,3
	dc.b 4,3,4,3,4,3,4,3,5,4,5,4,6,5,-1,0
DClumtab1:
	dc.b 7,6,7,6,7,6,7,6,7,6,7,6,7,6,7,6
	dc.b 8,7,8,7,8,7,8,7,9,8,9,8,10,9,11,9

	; even.q
Get_Luma_DC_dct_diff:
	move.l d2,-(sp)
	bfextu (a5){d6:5},d0
	cmp #31,d0
	beq.s gld1
	add d0,d0
	lea DClumtab0(pc),a0
	bra.s gld2
gld1:
	bfextu (a5){d6:9},d0
	add.l #$FFFFFE10,d0
	lea DClumtab1(pc),a0
	add d0,d0
gld2:
	moveq #0,d1
	move.b 0(a0,d0.l),d1
	move.b 1(a0,d0.l),d0
	add d0,d6
	trapcs
	move.l d1,d0
	beq.s gldfin
	bfextu (a5){d6:d1},d0
	add d1,d6
	trapcs
	subq #1,d1
	btst d1,d0
	bne.s gldfin
	moveq #0,d2
	addq #1,d1
	bset d1,d2
	sub.l d2,d0
	addq.l #1,d0
gldfin:
	move.l (sp)+,d2
	rts
	even.l
DCchromtab0:
	dc.b 0,2,0,2,0,2,0,2,0,2,0,2,0,2,0,2
	dc.b 1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2
	dc.b 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.b 3,3,3,3,3,3,3,3,4,4,4,4,5,5,-1,0
DCchromtab1:
	dc.b 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
	dc.b 6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6
	dc.b 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7
	dc.b 8,8,8,8,8,8,8,8,9,9,9,9,10,10,11,10

	; even.q
Get_Chroma_DC_dct_diff:
	move.l d2,-(sp)
	bfextu (a5){d6:5},d0
	cmp #31,d0
	beq.s gcd1
	add d0,d0
	lea DCchromtab0(pc),a0
	bra.s gcd2
gcd1:
	bfextu (a5){d6:10},d0
	add.l #$FFFFFC20,d0
	lea DCchromtab1(pc),a0
	add d0,d0
gcd2:
	moveq #0,d1
	move.b 0(a0,d0.l),d1
	move.b 1(a0,d0.l),d0
	add d0,d6
	trapcs
	move.l d1,d0
	beq.s gcdfin
	bfextu (a5){d6:d1},d0
	add d1,d6
	trapcs
	subq #1,d1
	btst d1,d0
	bne.s gcdfin
	moveq #0,d2
	addq #1,d1
	bset d1,d2
	sub.l d2,d0
	addq.l #1,d0
gcdfin:
	move.l (sp)+,d2
	rts
	even.l
DCTtabfirst:
  dc.l $02000004, $01020004, $01010003, $01010003
  dc.l $01000001, $01000001, $01000001, $01000001
  dc.l $01000001, $01000001, $01000001, $01000001
DCTtab0a:
  dc.l $00410006, $00410006, $00410006, $00410006
  dc.l $01070007, $01070007, $01080007, $01080007
  dc.l $01060007, $01060007, $02020007, $02020007
  dc.l $07000006, $07000006, $07000006, $07000006
  dc.l $06000006, $06000006, $06000006, $06000006
  dc.l $01040006, $01040006, $01040006, $01040006
  dc.l $01050006, $01050006, $01050006, $01050006
  dc.l $05010008, $010B0008, $0B000008, $0A000008
  dc.l $010D0008, $010C0008, $02030008, $04010008
  dc.l $01020005, $01020005, $01020005, $01020005
  dc.l $01020005, $01020005, $01020005, $01020005
  dc.l $02010005, $02010005, $02010005, $02010005
  dc.l $02010005, $02010005, $02010005, $02010005
  dc.l $01030005, $01030005, $01030005, $01030005
  dc.l $01030005, $01030005, $01030005, $01030005
  dc.l $01010003, $01010003, $01010003, $01010003
  dc.l $01010003, $01010003, $01010003, $01010003
  dc.l $01010003, $01010003, $01010003, $01010003
  dc.l $01010003, $01010003, $01010003, $01010003
  dc.l $01010003, $01010003, $01010003, $01010003
  dc.l $01010003, $01010003, $01010003, $01010003
  dc.l $01010003, $01010003, $01010003, $01010003
  dc.l $01010003, $01010003, $01010003, $01010003
  dc.l $00400004, $00400004, $00400004, $00400004
  dc.l $00400004, $00400004, $00400004, $00400004
  dc.l $00400004, $00400004, $00400004, $00400004
  dc.l $00400004, $00400004, $00400004, $00400004
  dc.l $03000004, $03000004, $03000004, $03000004
  dc.l $03000004, $03000004, $03000004, $03000004
  dc.l $03000004, $03000004, $03000004, $03000004
  dc.l $03000004, $03000004, $03000004, $03000004
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $01000002, $01000002, $01000002, $01000002
  dc.l $02000003, $02000003, $02000003, $02000003
  dc.l $02000003, $02000003, $02000003, $02000003
  dc.l $02000003, $02000003, $02000003, $02000003
  dc.l $02000003, $02000003, $02000003, $02000003
  dc.l $02000003, $02000003, $02000003, $02000003
  dc.l $02000003, $02000003, $02000003, $02000003
  dc.l $02000003, $02000003, $02000003, $02000003
  dc.l $02000003, $02000003, $02000003, $02000003
  dc.l $04000005, $04000005, $04000005, $04000005
  dc.l $04000005, $04000005, $04000005, $04000005
  dc.l $05000005, $05000005, $05000005, $05000005
  dc.l $05000005, $05000005, $05000005, $05000005
  dc.l $01090007, $01090007, $03010007, $03010007
  dc.l $010A0007, $010A0007, $08000007, $08000007
  dc.l $09000007, $09000007, $0C000008, $0D000008
  dc.l $03020008, $02040008, $0E000008, $0F000008
DCTtab1a:
  dc.l $02050009, $02050009, $010E0009, $010E0009
  dc.l $0402000A, $0110000A, $010F0009, $010F0009


	; even.q
Decode_MPEG1_MPEG2_Non_Intra_Block:
	move.l d4,-(sp)
	swap d5
	move.l d2,-(sp)
	clr d5		; d5 = count et coded_block_pattern
	lea block,a2
dmmni0:
	moveq #7,d0
	moveq #0,d7
	subq #1,Full_Block
	bmi.s dmmni5
dmmni1:
	move.l d7,(a2)+
	move.l d7,(a2)+
	move.l d7,(a2)+
	move.l d7,(a2)+
	dbf d0,dmmni1
	lea -128(a2),a2	; block effac‚
dmmni5:
	moveq #15,d0
	add.l block_count,d0
	sub d5,d0
	btst d0,d5
	beq.s dmmni2
	tst.b MPEG2_Flag(pc)
	beq.s dmmni3
	bsr Decode_MPEG2_Non_Intra_Block
	bra.s dmmni4
dmmni3:
	bsr.s Decode_MPEG1_Non_Intra_Block
dmmni4:
	tst.b Fault_Flag(pc)
	bne.s dmmnifin
dmmni2:
	addq #1,d5
	lea 128(a2),a2
	cmp block_count+2,d5
	bmi.s dmmni0
dmmnifin:
	movem.l (sp)+,d2/d4
	rts

	; even.q
Decode_MPEG1_Non_Intra_Block:
	moveq #0,d7
m1ni4:
	bfextu (a5){d6:16},d0
	cmp.l #16384,d0
	bmi.s m1ni1
	tst.l d7
	bne.s m1ni1
	moveq #12,d2
	lsr.l d2,d0
	subq.l #4,d0
	move.l (DCTtabfirst,d0.l*4),d0
	bra.s m1ni5
m1ni1:
	move.l (DCTptr,d0.l*4),d0   ; tab
	bne.s m1ni5
m1ni10:
	st Fault_Flag
	bra m1nifin
m1ni5:
	add d0,d6   ; flush buffer (tab->len)
	trapcs
	swap d0
	cmp.b #64,d0
	bcc m1nipart
m1ni6:
	move d0,d2
	add.b d0,d7
	lsr #8,d2
	bfextu (a5){d6:1},d3
	addq #1,d6
	trapcs
m1ni9:
	cmp #64,d7
	bpl.s m1ni10
	moveq #0,d4
	move.b (scan,pc,d7.l),d4  ; j
	add d2,d2
	addq #1,d2
	muls.w quantizer_scale(pc),d2
	muls.l (non_intra_quantizer_matrix,d4.l*4),d2
	asr.l #4,d2
	beq.s m1ni11
	subq #1,d2
	or #1,d2
m1ni11:
	tst.b d3
	bne.s m1ni12
	cmp #2048,d2
	bmi.s m1ni13
	move #2047,d2
	bra.s m1ni13
m1ni12:
	cmp #2049,d2
	bmi.s m1ni14
	move #2048,d2
m1ni14:
	neg d2
m1ni13:
	move d2,0(a2,d4.l*2)  ; bp(j)
	addq #1,d7
	tst Full_Block(pc)
	bpl m1ni4
fm1ni4:		; ici on saute tous les coeffs (mode petit ou gris)
	bfextu (a5){d6:16},d0
	cmp.l #16384,d0
	bmi.s fm1ni1
	tst.l d7
	bne.s fm1ni1
	moveq #12,d2
	lsr.l d2,d0
	subq.l #4,d0
	move.l (DCTtabfirst,d0.l*4),d0
	bra.s fm1ni5
fm1ni1:
	move.l (DCTptr,d0.l*4),d0   ; tab
	bne.s fm1ni5
fm1ni10:
	st Fault_Flag
	rts
fm1ni5:
	add d0,d6   ; flush buffer (tab->len)
	trapcs
	swap d0	; tab->run
	cmp.b #64,d0
	bcc.s fm1nipart
fm1ni6:
	add.b d0,d7
	addq #1,d6
	trapcs
fm1ni9:
	cmp #64,d7
	bpl.s fm1ni10
	addq #1,d7
	bra.s fm1ni4
m1nifin:
	rts
m1nipart:
	beq.s m1nifin       ; end of block
	cmp.b #65,d0
	bne m1ni6
	bfextu (a5){d6:14},d0
	add #14,d6
	trapcs
	move.l d0,d2
	lsr #8,d0
	add.l d0,d7
	and #$FF,d2     ; val
	bne.s m1ni15
	bfextu (a5){d6:8},d2
	addq #8,d6
	trapcs
	bra.s m1ni8
m1ni15:
	cmp #128,d2
	bgt.s m1ni7
	bne.s m1ni8
	bfextu (a5){d6:8},d2
	addq #8,d6
	trapcs
m1ni7:
	sub.l #256,d2
m1ni8:
	tst d2
	smi d3
	bpl m1ni9
	neg.l d2
	bra m1ni9
fm1nipart:
	beq.s m1nifin       ; end of block
	cmp.b #65,d0
	bne.s fm1ni6
	bfextu (a5){d6:14},d0
	add #14,d6
	trapcs
	move.l d0,d2
	lsr #8,d0
	add.b d0,d7
	and #$FF,d2     ; val
	bne.s fm1ni15
	addq #8,d6
	trapcs
	bra.s fm1ni9
fm1ni15:
	cmp #128,d2
	bgt fm1ni9
	bne fm1ni9
	addq #8,d6
	trapcs
	bra fm1ni9

	; even.q
Decode_MPEG2_Non_Intra_Block:
	cmp #4,d5
	bmi.s m2ni2
	moveq #1,d0
	cmp.b chroma_format(pc),d0
	beq.s m2ni2
	lea chroma_non_intra_quantizer_matrix,a4
	bra.s m2ni16
m2ni2:
	lea non_intra_quantizer_matrix,a4
m2ni16:
	moveq #0,d7
m2ni4:
	bfextu (a5){d6:16},d0
	cmp.l #16384,d0
	bmi.s m2ni1
	tst.l d7
	bne.s m2ni1
	moveq #12,d2
	lsr.l d2,d0
	subq.l #4,d0
	move.l (DCTtabfirst,d0.l*4),d0
	bra.s m2ni5
m2ni1:
	move.l (DCTptr,d0.l*4),d0   ; tab
	bne.s m2ni5
m2ni10:
	st Fault_Flag
	bra m2nifin
m2ni5:
	add d0,d6   ; flush buffer (tab->len)
	trapcs
	swap d0
	cmp.b #64,d0
	bcc m2nipart
m2ni6:
	move d0,d2
	add.b d0,d7
	lsr #8,d2
	bfextu (a5){d6:1},d3
	addq #1,d6
	trapcs
m2ni9:
	cmp #64,d7
	bpl.s m2ni10
	moveq #0,d4
	move.l alternate_scan(pc),a0
	move.b 0(a0,d7.l),d4  ; j
	add.w d2,d2
	addq.w #1,d2
	muls.w quantizer_scale(pc),d2
	muls.l 0(a4,d4.l*4),d2
	asr.l #5,d2
	tst.b d3
	beq.s m2ni12
	neg d2
m2ni12:
	move d2,0(a2,d4.l*2)  ; bp(j)
	addq #1,d7
	tst Full_Block(pc)
	bpl m2ni4
fm2ni4:		; ici on saute tous les coeffs (mode petit ou gris)
	bfextu (a5){d6:16},d0
	cmp.l #16384,d0
	bmi.s fm2ni1
	tst.l d7
	bne.s fm2ni1
	moveq #12,d2
	lsr.l d2,d0
	subq.l #4,d0
	move.l (DCTtabfirst,d0.l*4),d0
	bra.s fm2ni5
fm2ni1:
	move.l (DCTptr,d0.l*4),d0   ; tab
	bne.s fm2ni5
fm2ni10:
	st Fault_Flag
	bra m2nifin
fm2ni5:
	add d0,d6   ; flush buffer (tab->len)
	trapcs
	swap d0	; tab->run
	cmp.b #64,d0
	bcc.s fm2nipart
fm2ni6:
	add.b d0,d7
	addq #1,d6
	trapcs
fm2ni9:
	cmp #64,d7
	bpl.s fm2ni10
	addq #1,d7
	bra.s fm2ni4
m2nipart:
	beq.s m2nifin       ; end of block
	cmp.b #65,d0
	bne m2ni6
	bfextu (a5){d6:18},d0
	add #18,d6
	trapcs
	move.l d0,d2
	moveq #12,d1
	lsr d1,d0
	add.b d0,d7
	and #$FFF,d2     ; val
	bftst d2{21:11}
	beq m2ni10
	cmp #2048,d2
	spl d3
	bmi m2ni9
	sub.l #4096,d2
	neg.l d2
	bra m2ni9
fm2nipart:
	beq.s m2nifin       ; end of block
	cmp.b #65,d0
	bne.s fm2ni6
	bfextu (a5){d6:18},d0
	add #18,d6
	trapcs
	move.l d0,d2
	moveq #12,d1
	lsr d1,d0
	add.l d0,d7
	and #$FFF,d2     ; val
	bftst d2{21:11}
	beq fm2ni10
	bra.s fm2ni9
m2nifin:
	rts

	; even.q
motion_vectors:
	move.l d4,-(sp)
	lea f_code(pc),a0
	move.l d3,-(sp)
	moveq #0,d3
	move.l d2,-(sp)
	lea 0(a0,d0.l*4),a0
	tst d0
	bne.s mvs3
	move.b dmv(pc),d3
mvs3:
	moveq #0,d4
	movem.w (a0),d1/d4
	lea PMV(pc),a0
	swap d4
	lea 0(a0,d0.l*8),a4
	move.b mvscale(pc),d4
	lea motion_vertical_field_select(pc),a0
	add d4,d4
	lea 0(a0,d0.l*4),a2
;	add.b d3,d4
	add d3,d4
	add d4,d4
	tst.b motion_vector_count(pc)
	bne.s mvs1
	tst.b d3
	bne.s mvs2
	tst.b mv_format(pc)
	bne.s mvs2
	bfextu (a5){d6:1},d0
	addq #1,d6
	trapcs
	move.l d0,(a2)
	move.l d0,8(a2)
mvs2:
	move.l a4,a0	; d4 et d1 dj… charg‚s
	bsr.s motion_vector
	move.l (a4),16(a4)
	movem.l (sp)+,d2-d4
	move.l 4(a4),20(a4)
	rts
mvs1:
	bfextu (a5){d6:1},d0
	addq #1,d6
	trapcs
	move.l d4,-(sp)
	move.l a4,a0
	move.l d1,-(sp)
	move.l d0,(a2)
	bsr.s motion_vector
	bfextu (a5){d6:1},d0
	addq #1,d6
	trapcs
	movem.l (sp)+,d1/d4
	lea 16(a4),a0
	move.l d0,8(a2)
	bsr.s motion_vector
	movem.l (sp)+,d2-d4
	rts

	; even.q
motion_vector:
	lea dmvector(pc),a1
	bsr Get_motion_code  ; renvoy‚ dans d0
	moveq #0,d2
	tst d1
	beq.s mv1
	tst d0
	beq.s mv1
	move d1,d2
	bfextu (a5){d6:d2},d2
	add d1,d6
	trapcs
mv1:
	bsr.s decode_motion_vector
	btst #1,d4
	beq.s mv2
	bfextu (a5){d6:1},d0
	addq #1,d6
	trapcs
	tst d0
	beq.s mv6
	bftst (a5){d6:1}
	beq.s mv7
	neg.l d0
mv7:
	addq #1,d6
	trapcs
mv6:
	move.l d0,(a1)+
mv2:
	bsr Get_motion_code
	swap d4	; vrsize
	move d4,d1
	swap d4
	moveq #0,d2
	tst d1
	beq.s mv3
	tst d0
	beq.s mv3
	move d1,d2
	bfextu (a5){d6:d2},d2
	add d1,d6
	trapcs
mv3:
	addq.l #4,a0
	btst #2,d4
	beq.s mv4
	move.l (a0),d3
	asr.l #1,d3
	move.l d3,(a0)
mv4:
	bsr.s decode_motion_vector
	btst #2,d4
	beq.s mv5
	move.l (a0),d3
	asl.l #1,d3
	move.l d3,(a0)
mv5:
	btst #1,d4
	beq.s mvfin
	bfextu (a5){d6:1},d0
	addq #1,d6
	trapcs
	tst d0
	beq.s mv8
	bftst (a5){d6:1}
	beq.s mv9
	neg.l d0
mv9:
	addq #1,d6
	trapcs
mv8:
	move.l d0,(a1)
mvfin:
	rts

	; even.q
decode_motion_vector:
	move.l d6,a3
	moveq #16,d3
	lsl.l d1,d3
	move.l (a0),d6
	btst #0,d4
	beq.s dmv1
	asr.l #1,d6
dmv1:
	tst.l d0
	beq.s dmv2
	bmi.s dmv3
	add.l d2,d6
	addq.l #1,d6
	subq.l #1,d0
	asl.l d1,d0
	add.l d0,d6
	cmp.l d3,d6
	bmi.s dmv2
	sub.l d3,d6
	sub.l d3,d6
	bra.s dmv2
dmv3:
	sub.l d2,d6
	subq.l #1,d6
	neg.l d0
	subq.l #1,d0
	asl.l d1,d0
	neg.l d3
	sub.l d0,d6
	cmp.l d3,d6
	bpl.s dmv2
	sub.l d3,d6
	sub.l d3,d6
dmv2:
	btst #0,d4
	beq.s dmv4
	asl.l #1,d6
dmv4:
	move.l d6,(a0)
	move.l a3,d6
	rts

	; even.q
Get_motion_code:
	bfextu (a5){d6:1},d0
	addq #1,d6
	trapcs
	tst d0
	bne gmc0
	bfextu (a5){d6:9},d0
	cmp #64,d0
	bmi.s gmc1
	lsr #6,d0
	lea MVtab0(pc),a3
	bra.s gmc2
	even.l
MVtab0:
	dc.b -1,0,3,3,2,2,2,2,1,1,1,1,1,1,1,1
MVtab1:
	dc.b -1,0,-1,0,-1,0,7,6,6,6,5,6,4,5,4,5
gmc1:
	cmp #24,d0
	bmi.s gmc4
	lsr #3,d0
	lea MVtab1(pc),a3
	bra.s gmc2
	even.l
MVtab2:
	dc.b 16,9,15,9,14,9,13,9
	dc.b 12,9,11,9,10,8,10,8
	dc.b 9,8,9,8,8,8,8,8
gmc4:
	sub #12,d0
	bmi.s gmc5
	lea MVtab2(pc),a3
gmc2:
	lea 0(a3,d0.l*2),a3
	move.b 1(a3),d0
	add d0,d6
	trapcs
	move.b (a3),d0
	bftst (a5){d6:1}
	beq.s gmc3
	neg.l d0
gmc3:
	addq #1,d6
	trapcs
	rts
gmc5:
	st Fault_Flag
gmc0:
	moveq #0,d0
	rts

dm20:
	moveq #1,d0
	bra.s dmfin
dm0:
	moveq #0,d0
dmfin:
	move.w d6,Incnt+2
	rts

	; even.q
motion_compensation:
	move.l MBA(pc),d4
	divsl.l mb_width(pc),D6:D4
	lsl.l #4,d6
	lsl.l #4,d4
	move.l macroblock_type(pc),d0
	btst #0,d0
	bne.s mc2
	lea bx(pc),a0
	move.l d6,(a0)+
	move.l d4,(a0)+
	move.l d0,(a0)+
	move.l motion_type(pc),a5
	lea.l PMV(pc),a3
	moveq #0,d2
	lea.l motion_vertical_field_select(pc),a4
	move.b stwtype(pc),d2
	bsr.s form_predictions
	moveq #1,d0
	lea bx(pc),a0
	move.l dct_type(pc),a5
	move.l (a0)+,a3
	move.l (a0),a4
	bsr IDCT_And_Add_Blocks
	rts
	even.l
bx: dc.l 0
by: dc.l 0
macroblk_type: dc.l 0
mc2:
	moveq #0,d0
	move.l dct_type(pc),a5
	move.l d4,a4
	move.l d6,a3
	bsr IDCT_And_Add_Blocks
	rts

	; even.q
form_predictions:
	link a6,#-16
         move.l      D2,D0
         muls.l      #$55555556,D1:D0
         move.l      D2,D0
         add.l       D0,D0
         subx.l      D0,D0
         sub.l       D0,D1
         movea.l     D1,A0
         lea         0(A0,A0.l*2),A1
         sub.l       A1,D2
         move.l      A0,D3
         move.l      macroblk_type(pc),D0
         moveq       #8,D1
         and.l       D1,D0
         bne.b       T_F7E
         moveq       #2,D5
         cmp.b       picture_coding_type(pc),D5
         bne.w       T_13A4
T_F7E:     move.b      picture_structure(pc),D1
         moveq       #3,D5
         cmp.b       D1,D5
         bne.w       T_11EA
         moveq       #2,D1
T_F8E:     cmp.l       A5,D1
         beq.b       T_F98
         tst.l       D0
         bne.s       T_101C
T_F98:     moveq       #1,D5
         cmp.l       D2,D5
         blt.b       T_FDA
         moveq #0,d1
         move.l d1,-(sp)
         move.l d1,-(sp)
         move.l      D2,-(SP)
         move.l      4(A3),-(SP)
         move.l      (A3),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D1
         move.l      D1,D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D1,-(SP)
         pea         current_frame(pc)
         pea         forward_reference_frame(pc)
         bsr       form_prediction
         lea         $34(SP),SP
T_FDA:     moveq       #1,D0
         cmp.l       D3,D0
         blt.w       T_13A0
         pea         1.w
         pea         1.w
         move.l      D3,-(SP)
         move.l      4(A3),-(SP)
         move.l      (A3),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D1
         move.l      D1,D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D1,-(SP)
         pea         current_frame(pc)
         pea         forward_reference_frame(pc)
         bra.w       T_125C
T_101C:    moveq       #1,D1
         cmp.l       A5,D1
         bne.w       T_10B4
         cmp.l       D2,D1
         blt.b       T_106A
         clr.l       -(SP)
         move.l      (A4),-(SP)
         move.l      D2,-(SP)
         move.l      4(A3),D0
         asr.l       #1,D0
         move.l      D0,-(SP)
         move.l      (A3),-(SP)
         move.l      D4,D0
         asr.l       #1,D0
         move.l      D0,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         pea         forward_reference_frame(pc)
         bsr       form_prediction
         lea         $34(SP),SP
T_106A:    moveq       #1,D5
         cmp.l       D3,D5
         blt.w       T_13A0
         pea         1.w
         move.l      8(A4),-(SP)
         move.l      D3,-(SP)
         move.l      $14(A3),D0
         asr.l       #1,D0
         move.l      D0,-(SP)
         move.l      $10(A3),-(SP)
         move.l      D4,D0
         asr.l       #1,D0
         move.l      D0,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         pea         forward_reference_frame(pc)
         bra.w       T_125C
T_10B4:    moveq       #3,D0
         cmp.l       A5,D0
         bne.w       T_13A0
         move.l      4(A3),D0
         asr.l       #1,D0
         move.l      D0,a2
         bsr       Dual_Prime_Arithmetic
         moveq       #1,D1
         cmp.l       D2,D1
         blt.s       T_115E
         moveq #0,d0
         move.l d0,-(sp)
         move.l d0,-(sp)
         move.l d0,-(sp)
         move.l      4(A3),D0
         asr.l       #1,D0
         move.l      D0,-(SP)
         move.l      (A3),-(SP)
         move.l      D4,D2
         asr.l       #1,D2
         move.l      D2,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         pea         forward_reference_frame(pc)
         lea         form_prediction(pc),A2
         jsr         (A2)
         lea         $30(SP),SP
         clr.l       (SP)
         pea         1.w
         pea         1.w
         move.l      -$C(A6),-(SP)
         move.l      -$10(A6),-(SP)
         move.l      D2,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         pea         forward_reference_frame(pc)
         jsr         (A2)
         lea         $34(SP),SP
T_115E:    moveq       #1,D5
         cmp.l       D3,D5
         blt.w       T_13A0
         pea         1.w
         pea         1.w
         clr.l       -(SP)
         move.l      4(A3),D0
         asr.l       #1,D0
         move.l      D0,-(SP)
         move.l      (A3),-(SP)
         move.l      D4,D2
         asr.l       #1,D2
         move.l      D2,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         pea         forward_reference_frame(pc)
         lea         form_prediction(pc),A2
         jsr         (A2)
         lea         $30(SP),SP
         move.l      #1,(SP)
         clr.l       -(SP)
         pea         1.w
         move.l      -$4(A6),-(SP)
         move.l      -$8(A6),-(SP)
         move.l      D2,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         pea         forward_reference_frame(pc)
         bra.w       T_138C
T_11EA:    moveq       #2,D0
         cmp.b       D1,D0
         seq         D0
         move.b      D0,D3
         extb.l      D3
         neg.l       D3
         move.l      #forward_reference_frame,D5
         move.l      D5,D7
         moveq       #2,D1
         cmp.b       picture_coding_type(pc),D1
         bne.b       T_121A
         tst.b       Second_Field(pc)
         beq.b       T_121A
         cmp.l       (A4),D3
         beq.b       T_121A
         move.l      #backward_reference_frame,D5
T_121A:    moveq       #1,D0
         cmp.l       A5,D0
         beq.b       T_1228
         btst        #3,macroblk_type+3
         bne.b       T_126A
T_1228:    moveq       #1,D1
         cmp.l       D2,D1
         blt.w       T_13A0
         clr.l       -(SP)
         move.l      (A4),-(SP)
         move.l      D2,-(SP)
         move.l      4(A3),-(SP)
         move.l      (A3),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         16.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         move.l      D5,-(SP)
T_125C:    bsr       form_prediction
         lea         $34(SP),SP
         bra.w       T_13A0
T_126A:    moveq       #2,D0
         cmp.l       A5,D0
         bne.s       T_12F2
         moveq       #1,D1
         cmp.l       D2,D1
         blt.w       T_13A0
         clr.l       -(SP)
         move.l      (A4),-(SP)
         move.l      D2,-(SP)
         move.l      4(A3),-(SP)
         move.l      (A3),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         move.l      D5,-(SP)
         lea         form_prediction(pc),A2
         jsr         (A2)
         lea         $34(SP),SP
         move.l      D7,D5
         moveq       #2,D0
         cmp.b       picture_coding_type(pc),D0
         bne.b       T_12D2
         tst.b       Second_Field(pc)
         beq.b       T_12D2
         cmp.l       8(A4),D3
         beq.b       T_12D2
         move.l      #backward_reference_frame,D5
T_12D2:    clr.l       -(SP)
         move.l      8(A4),-(SP)
         move.l      D2,-(SP)
         move.l      $14(A3),-(SP)
         move.l      $10(A3),-(SP)
         movea.l     D4,A0
         pea         8(A0)
         move.l      D6,-(SP)
         pea         8.w
         bra.s       T_1374
T_12F2:    moveq       #3,D0
         cmp.l       A5,D0
         bne.w       T_13A0
         move.l      D7,D5
         tst.b       Second_Field(pc)
         beq.b       T_130A
         move.l      #backward_reference_frame,D5
T_130A:    move.l      4(A3),a2
         bsr       Dual_Prime_Arithmetic
         moveq #0,d0
         move.l d0,-(sp)
         move.l      D3,-(SP)
         move.l d0,-(sp)
         move.l      4(A3),-(SP)
         move.l      (A3),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         16.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         move.l      D7,-(SP)
         lea         form_prediction(pc),A2
         jsr         (A2)
         lea         $30(SP),SP
         clr.l       (SP)
         tst.l       D3
         seq         D0
         extb.l      D0
         neg.l       D0
         move.l      D0,-(SP)
         pea         1.w
         move.l      -$C(A6),-(SP)
         move.l      -$10(A6),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         16.w
T_1374:    pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         move.l      D5,-(SP)
T_138C:    jsr         (A2)
         lea         $34(SP),SP
T_13A0:    moveq       #1,D3
         moveq       #1,D2
T_13A4:    btst        #2,macroblk_type+3
         beq.w       T_1582
         moveq       #3,D1
         cmp.b       picture_structure(pc),D1
         bne.w       T_14B2
         moveq       #2,D5
         cmp.l       A5,D5
         bne.b       T_143C
         moveq       #1,D0
         cmp.l       D2,D0
         blt.b       T_1404
         moveq #0,d1
         move.l d1,-(sp)
         move.l d1,-(sp)
         move.l      D2,-(SP)
         move.l      12(A3),-(SP)
         move.l      8(A3),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D1
         move.l      D1,D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D1,-(SP)
         pea         current_frame(pc)
         pea         backward_reference_frame(pc)
         bsr       form_prediction
         lea         $34(SP),SP
T_1404:    moveq       #1,D1
         cmp.l       D3,D1
         blt.w       T_1582
         pea         1.w
         pea         1.w
         move.l      D3,-(SP)
         move.l      12(A3),-(SP)
         move.l      8(A3),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D1
         move.l      D1,D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D1,-(SP)
         bra.w       T_14E0
T_143C:    moveq       #1,D5
         cmp.l       D2,D5
         blt.b       T_1488
         clr.l       -(SP)
         move.l      4(A4),-(SP)
         move.l      D2,-(SP)
         move.l      12(A3),D0
         asr.l       #1,D0
         move.l      D0,-(SP)
         move.l      8(A3),-(SP)
         move.l      D4,D0
         asr.l       #1,D0
         move.l      D0,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         pea         backward_reference_frame(pc)
         bsr       form_prediction
         lea         $34(SP),SP
T_1488:    moveq       #1,D0
         cmp.l       D3,D0
         blt.w       T_1582
         pea         1.w
         move.l      12(A4),-(SP)
         move.l      D3,-(SP)
         move.l      $1C(A3),D0
         asr.l       #1,D0
         move.l      D0,-(SP)
         move.l      $18(A3),-(SP)
         asr.l       #1,D4
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         bra.b       T_14D0
T_14B2:    moveq       #1,D1
         cmp.l       A5,D1
         bne.b       T_14F6
         clr.l       -(SP)
         move.l      4(A4),-(SP)
         move.l      D2,-(SP)
         move.l      12(A3),-(SP)
         move.l      8(A3),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         16.w
T_14D0:    pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
T_14E0:    pea         current_frame(pc)
         pea         backward_reference_frame(pc)
         bsr       form_prediction
         bra.s       T_1582
T_14F6:    moveq       #2,D5
         cmp.l       A5,D5
         bne.b       T_1582
         clr.l       -(SP)
         move.l      4(A4),-(SP)
         move.l      D2,-(SP)
         move.l      12(A3),-(SP)
         move.l      8(A3),-(SP)
         move.l      D4,-(SP)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         pea         backward_reference_frame(pc)
         lea         form_prediction(pc),A2
         jsr         (A2)
         lea         $30(SP),SP
         clr.l       (SP)
         move.l      12(A4),-(SP)
         move.l      D2,-(SP)
         move.l      $1C(A3),-(SP)
         move.l      $18(A3),-(SP)
         movea.l     D4,A0
         pea         8(A0)
         move.l      D6,-(SP)
         pea         8.w
         pea         16.w
         move.l      Coded_Picture_Width(pc),D0
         add.l       D0,D0
         move.l      D0,-(SP)
         move.l      D0,-(SP)
         pea         current_frame(pc)
         pea         backward_reference_frame(pc)
         jsr         (A2)
T_1582:  unlk a6
	rts

	; even.q
IDCT_And_Add_Blocks:
	move.l a6,-(sp)
	move.l d0,a6
	moveq #0,d6	; comp
	move.b Output_Type(pc),d0
	move.w block_count+2,d1
	btst #0,d0
	bne.s iaab0
	moveq #4,d1
iaab0:
	lea block,a0
	move.w d1,maxb
	btst #1,d0
	beq.s iaab2
iaab1:
	movem.l d6/a0,-(sp)
	bsr.s Fast_IDCT
	movem.l (sp)+,d6/a0
	move.l d6,d0
	move.l a3,d1
	move.l a4,d2
	move.l a5,d3
	move.l a6,d4
	move.l a0,-(sp)
	bsr Add_Block
	move.l (sp)+,a0
	lea 128(a0),a0
	addq #1,d6
	cmp maxb,d6
	bmi.s iaab1
	move.l (sp)+,a6
	rts
iaab2:
	moveq #4,d0  	; False IDCT, seulement le premier coeff
	add (a0),d0
	asr #3,d0
	move d0,(a0)		; False IDCT fin
	move.l d6,d0
	move.l a3,d1
	move.l a4,d2
	move.l a5,d3
	move.l a6,d4
	move.l a0,-(sp)
	bsr FAdd_Block
	move.l (sp)+,a0
	lea 128(a0),a0
	addq #1,d6
	cmp maxb,d6
	bmi.s iaab2
	move.l (sp)+,a6
	rts
	even.l
maxb: dc.w 0

	; even.q
Fast_IDCT:
         moveq       #7,D7
T_3E30:    movem.l     (a0),D0-D3
         move.l      D1,D4
         or.l        D2,D4
         or.l        D3,D4
         or.w        D0,D4
         bne.b       T_3E58
         swap        D0
         asl.w       #3,D0
         move.w      D0,D1
         swap        D0
         move.w      D1,D0
         move.l      D0,(a0)+
         move.l      D0,(a0)+
         move.l      D0,(a0)+
         move.l      D0,(a0)+
         dbf         d7,T_3E30
         bra.w       T_3F4C
T_3E58:    move.w      D0,D5
         add.w       D3,D5
         muls        #$235,D5
         move.w      D0,D4
         muls        #$8E4,D4
         add.l       D5,D4
         move.w      D3,D6
         muls        #$D4E,D6
         sub.l       D6,D5
         move.w      D2,D6
         add.w       D1,D6
         muls        #$968,D6
         movea.l     D6,A1
         movea.l     D6,A2
         move.w      D2,D6
         muls        #$31F,D6
         suba.l      D6,A1
         move.w      D1,D6
         muls        #$FB1,D6
         suba.l      D6,A2
         swap        D0
         swap        D1
         swap        D2
         swap        D3
         moveq       #11,D6
         ext.l       D0
         ext.l       D2
         asl.l       D6,D0
         asl.l       D6,D2
         add.l       #$80,D0
         move.l      D0,D6
         add.l       D2,D6
         sub.l       D2,D0
         move.w      D3,D2
         add.w       D1,D2
         muls        #$454,D2
         muls        #$620,D1
         muls        #$EC8,D3
         add.l       D2,D1
         sub.l       D3,D2
         move.l      D4,D3
         add.l       A1,D3
         sub.l       A1,D4
         movea.l     D5,A1
         adda.l      A2,A1
         sub.l       A2,D5
         movea.l     D6,A2
         adda.l      D1,A2
         sub.l       D1,D6
         move.l      A2,D1
         sub.l       D3,D1
         add.l       A2,D3
         asr.l       #8,D1
         asr.l       #8,D3
         move.w      D1,14(a0)
         move.l      D0,D1
         move.w      D3,(a0)
         add.l       D2,D1
         sub.l       D2,D0
         move.l      D4,D2
         add.l       D5,D2
         muls.l      #$B5,D2
         add.l       #$80,D2
         asr.l       #8,D2
         sub.l       D5,D4
         muls.l      #$B5,D4
         add.l       #$80,D4
         asr.l       #8,D4
         move.l      D1,D3
         sub.l       D2,D3
         add.l       D2,D1
         asr.l       #8,D3
         asr.l       #8,D1
         move.w      D3,12(a0)
         move.l      D0,D3
         move.w      D1,2(a0)
         sub.l       D4,D3
         add.l       D4,D0
         asr.l       #8,D3
         asr.l       #8,D0
         move.w      D3,10(a0)
         move.l      D6,D1
         move.w      D0,4(a0)
         add.l       A1,D6
         sub.l       A1,D1
         asr.l       #8,D6
         asr.l       #8,D1
         move.w      D6,6(a0)
         addq.l      #8,a0
         move.w      D1,(a0)
         addq.l      #8,a0
         dbf         d7,T_3E30
T_3F4C:    suba.w      #$80,a0
         moveq       #7,D7
T_3F52:    move.w      $10(a0),D4
         move.w      D4,D5
         move.w      $70(a0),D6
         add.w       D6,D5
         muls        #$235,D5
         muls        #$8E4,D4
         muls        #$D4E,D6
         add.l       D5,D4
         sub.l       D6,D5
         asr.l       #3,D4
         asr.l       #3,D5
         move.w      $50(a0),D0
         move.w      $30(a0),D1
         move.w      D0,D6
         add.w       D1,D6
         muls        #$968,D6
         move.l      D6,D3
         muls        #$31F,D0
         sub.l       D0,D3
         asr.l       #3,D3
         movea.l     D3,A1
         muls        #$FB1,D1
         sub.l       D1,D6
         asr.l       #3,D6
         movea.l     D6,A2
         move.w      (a0),D0
         move.w      $40(a0),D2
         ext.l       D0
         ext.l       D2
         asl.l       #8,D0
         asl.l       #8,D2
         add.l       #$2000,D0
         move.l      D0,D6
         add.l       D2,D6
         sub.l       D2,D0
         move.w      $20(a0),D1
         move.w      $60(a0),D3
         move.w      D3,D2
         add.w       D1,D2
         muls        #$454,D2
         muls        #$620,D1
         add.l       D2,D1
         asr.l       #3,D1
         muls        #$EC8,D3
         sub.l       D3,D2
         asr.l       #3,D2
         move.l      D4,D3
         add.l       A1,D3
         sub.l       A1,D4
         movea.l     D5,A1
         adda.l      A2,A1
         sub.l       A2,D5
         movea.l     D6,A2
         adda.l      D1,A2
         sub.l       D1,D6
         move.l      A2,D1
         sub.l       D3,D1
         add.l       A2,D3
         asr.l       #8,D1
         asr.l       #8,D3
         asr.l       #6,D1
         asr.l       #6,D3
         move.w      D1,$70(a0)
         move.l      D0,D1
         move.w      D3,(a0)
         add.l       D2,D1
         sub.l       D2,D0
         move.l      D4,D2
         add.l       D5,D2
         muls.l      #$B5,D2
         add.l       #$80,D2
         asr.l       #8,D2
         sub.l       D5,D4
         muls.l      #$B5,D4
         add.l       #$80,D4
         asr.l       #8,D4
         move.l      D1,D3
         sub.l       D2,D3
         add.l       D2,D1
         asr.l       #8,D3
         asr.l       #8,D1
         asr.l       #6,D3
         asr.l       #6,D1
         move.w      D3,$60(a0)
         move.l      D0,D3
         move.w      D1,$10(a0)
         sub.l       D4,D3
         add.l       D4,D0
         asr.l       #8,D0
         asr.l       #8,D3
         asr.l       #6,D0
         asr.l       #6,D3
         move.w      D0,$20(a0)
         move.l      D6,D1
         move.w      D3,$50(a0)
         add.l       A1,D6
         sub.l       A1,D1
         asr.l       #8,D6
         asr.l       #8,D1
         asr.l       #6,D6
         asr.l       #6,D1
         move.w      D6,$30(a0)
         addq.l      #2,a0
         move.w      D1,$40-2(a0)
         dbf         d7,T_3F52
			rts

	; even.q
Add_Block:
	move.l a0,a2	; adresse block
	cmp #4,d0
	bpl.s ab1
	tst d0
	bne.s ab2
	move.l current_frame(pc),a0
	move.l Coded_Picture_Width(pc),d5
	add.l d1,a0
	muls.l d5,d2
	cmp.b #3,picture_structure(pc)
	beq.s ab3
	add.l d5,d5
	add.l d2,d2
	bra.s ab0
ab3:
	tst.l d3
	beq.s ab0
	lsl.l #1,d5
ab0:
	subq.l #8,d5
	add.l d2,a0
	move.l d5,rfp_inc
	bra.s ab4
ab2:
	move.l rfp_inc,d5
	move.l rfp,a0
	subq #1,d0
	bne.s ab5
ab6:
	addq.l #8,a0
	bra.s ab4
ab5:
	subq #1,d0
	bne.s ab6
	move.l Coded_Picture_Width(pc),d0
	cmp.b #3,picture_structure(pc)
	beq.s ab7
	lsl.l #4,d0
	bra.s ab8
ab7:
	tst.l d3
	bne.s ab8
	lsl.l #3,d0
ab8:
	lea -8(a0,d0.l),a0
ab4:
	move.l a0,rfp
	bra.s ab9
ab1:
	moveq #0,d5
	move.b chroma_format(pc),d5
	move.l Chroma_Width(pc),a1
	exg.l a1,d5
	cmp #3,a1
	beq.s ab16
	lsr #1,d1
ab16:
	cmp #1,a1
	bne.s ab17
	lsr #1,d2
ab17:
	lea current_frame+4(pc),a0
	btst #0,d0
	beq.s ab14
	addq.l #4,a0
ab14:
	move.l (a0),a0
	cmp #8,d0
	bmi.s ab15
	addq.l #8,a0
ab15:
	add.l d1,a0
	and #2,d0
	cmp.b #3,picture_structure(pc)
	bne.s ab18
	tst.l d3
	beq.s ab19
	cmp #1,a1
	beq.s ab19
	lsr #1,d0
	add.l d0,d2
	muls.l d5,d2
	lsl #1,d5
	bra.s ab20
ab19:
	lsl #2,d0
	add.l d0,d2
	muls.l d5,d2
	bra.s ab20
ab18:
	add.l d5,d5
	lsl #2,d0
	add.l d0,d2
	muls.l d5,d2
ab20:
	add.l d2,a0
	subq.l #8,d5
ab9:
	lea Clip+384,a1
	tst.l d4
	beq.s ab21
	moveq #7,d0
	moveq #0,d2
	moveq #0,d3
ab11:
	moveq #7,d1
ab12:
	move.b (a0),d2
	move.w (a2)+,d3
	add d2,d3
	move.b 0(a1,d3.w),(a0)+
	dbf d1,ab12
	add.l d5,a0
	dbf d0,ab11
	rts
	even.l
rfp: dc.l 0
rfp_inc: dc.l 0
ab21:
	moveq #7,d0
	moveq #64,d2
	moveq #0,d3
	add.l d2,d2
ab10:
	moveq #7,d1
ab13:
	move.w (a2)+,d3
	add d2,d3
	move.b 0(a1,d3),(a0)+
	dbf d1,ab13
	add.l d5,a0
	dbf d0,ab10
	rts

	; even.q
FAdd_Block:
	move.l a0,a2	; adresse block
	cmp #4,d0
	bpl.s fab1
	tst d0
	bne.s fab2
	move.l current_frame(pc),a0
	move.l Coded_Picture_Width(pc),d5
	add.l d1,a0
	muls.l d5,d2
	cmp.b #3,picture_structure(pc)
	beq.s fab3
	add.l d5,d5
	add.l d2,d2
	bra.s fab0
fab3:
	tst.l d3
	beq.s fab0
	lsl.l #1,d5
fab0:
	subq.l #8,d5
	add.l d2,a0
	move.l d5,rfp_inc
	bra.s fab4
fab2:
	move.l rfp_inc,d5
	move.l rfp,a0
	subq #1,d0
	bne.s fab5
fab6:
	addq.l #8,a0
	bra.s fab4
fab5:
	subq #1,d0
	bne.s fab6
	move.l Coded_Picture_Width(pc),d0
	cmp.b #3,picture_structure(pc)
	beq.s fab7
	lsl.l #4,d0
	bra.s fab8
fab7:
	tst.l d3
	bne.s fab8
	lsl.l #3,d0
fab8:
	lea -8(a0,d0.l),a0
fab4:
	move.l a0,rfp
	bra.s fab9
fab1:
	moveq #0,d5
	move.b chroma_format(pc),d5
	move.l Chroma_Width(pc),a1
	exg.l a1,d5
	cmp #3,a1
	beq.s fab16
	lsr #1,d1
fab16:
	cmp #1,a1
	bne.s fab17
	lsr #1,d2
fab17:
	lea current_frame+4(pc),a0
	btst #0,d0
	beq.s fab14
	addq.l #4,a0
fab14:
	move.l (a0),a0
	cmp #8,d0
	bmi.s fab15
	addq.l #8,a0
fab15:
	add.l d1,a0
	and #2,d0
	cmp.b #3,picture_structure(pc)
	bne.s fab18
	tst.l d3
	beq.s fab19
	cmp #1,a1
	beq.s fab19
	lsr #1,d0
	add.l d0,d2
	muls.l d5,d2
	lsl #1,d5
	bra.s fab20
fab19:
	lsl #2,d0
	add.l d0,d2
	muls.l d5,d2
	bra.s fab20
fab18:
	add.l d5,d5
	lsl #2,d0
	add.l d0,d2
	muls.l d5,d2
fab20:
	add.l d2,a0
	subq.l #8,d5
fab9:
	lea Clip+384,a1
	tst.l d4
	beq.s fab21
	moveq #7,d0
	add (a2),a1	; unique coeff
	moveq #0,d2
fab11:
	move.b (a0),d2
	move.b 0(a1,d2.l),(a0)+
	move.b (a0),d2
	move.b 0(a1,d2.l),(a0)+
	move.b (a0),d2
	move.b 0(a1,d2.l),(a0)+
	move.b (a0),d2
	move.b 0(a1,d2.l),(a0)+
	move.b (a0),d2
	move.b 0(a1,d2.l),(a0)+
	move.b (a0),d2
	move.b 0(a1,d2.l),(a0)+
	move.b (a0),d2
	move.b 0(a1,d2.l),(a0)+
	move.b (a0),d2
	move.b 0(a1,d2.l),(a0)+
	add.l d5,a0
	dbf d0,fab11
	rts
fab21:
	moveq #7,d0
	moveq #64,d4
	add.l d4,d4
	add (a2),d4	; unique coeff
	moveq #0,d3
	move.b 0(a1,d4),d4
	move.b d4,d3
	lsl #8,d4
	or d4,d3
	move d3,d4
	swap d3
	move d4,d3	; 4 coeffs dans un long!
fab10:
	move.l d3,(a0)+
	move.l d3,(a0)+
	add.l d5,a0
	dbf d0,fab10
	rts

	; even.q
Dual_Prime_Arithmetic:
	move.l d2,-(sp)
	cmp.b #3,picture_structure(pc)
	bne dpa1
	tst.b top_field_first(pc)
	beq.s dpa2
	moveq #0,d1
	move.l (a3),d0
	ble.s dpa3
	moveq #1,d1
dpa3:
	lea dmvector(pc),a0
	add.l d0,d1
	add.l d0,d0
	move.l d1,d2
	asr.l #1,d2
	lea -16(a6),a1
	add.l (a0),d2
	add.l d0,d1
	move.l d2,(a1)+
	asr.l #1,d1
	add.l (a0)+,d1
	move.l d1,4(a1)
	moveq #0,d1
	move.l a2,d0
	ble.s dpa4
	moveq #1,d1
dpa4:
	add.l d0,d1
	add.l d0,d0
	move.l d1,d2
	asr.l #1,d2
	add.l (a0),d2
	add.l d0,d1
	subq.l #1,d2
	asr.l #1,d1
	move.l d2,(a1)
	add.l (a0),d1
	addq.l #1,d1
	move.l d1,8(a1)
	move.l (sp)+,d2
	rts
dpa2:
	moveq #0,d1
	move.l (a3),d0
	ble.s dpa5
	moveq #1,d1
dpa5:
	lea dmvector(pc),a0
	add.l d0,d1
	add.l d0,d0
	move.l d1,d2
	asr.l #1,d2
	lea -16(a6),a1
	add.l (a0),d2
	add.l d0,d1
	move.l d2,8(a1)
	asr.l #1,d1
	add.l (a0)+,d1
	move.l d1,(a1)+
	moveq #0,d1
	move.l a2,d0
	ble.s dpa6
	moveq #1,d1
dpa6:
	add.l d0,d1
	add.l d0,d0
	move.l d1,d2
	asr.l #1,d2
	add.l (a0),d2
	add.l d0,d1
	addq.l #1,d2
	asr.l #1,d1
	move.l d2,8(a1)
	add.l (a0),d1
	subq.l #1,d1
	move.l d1,(a1)
	move.l (sp)+,d2
	rts
dpa1:
	move.l (a3),d0
	ble.s dpa7
	addq.l #1,d0
dpa7:
	move.l a2,d1
	ble.s dpa8
	addq.l #1,d1
dpa8:
	asr.l #1,d0
	lea dmvector(pc),a0
	asr.l #1,d1
	add.l (a0)+,d0
	lea -16(a6),a1
	add.l (a0),d1
	cmp.b #1,picture_structure(pc)
	bne.s dpa9
	subq.l #1,d1
	move.l d0,(a1)+
	bra.s dpa10
dpa9:
	move.l d0,(a1)+
	addq.l #1,d1
dpa10:
	move.l d1,(a1)
	move.l (sp)+,d2
	rts
form_prediction:
	link a6,#0
	movem.l d2-d7/a2/a3,-(sp)
	movem.l 8(a6),a2-a3
	movem.l	16(a6),d0-d7
	move.l (a2)+,a0
	lsr #1,d1
	tst 54(a6)
	beq.s formp1
	add.l d1,a0
formp1:
	move.l a0,8(a6)	; src0 + ds
	move.l (a3)+,a0
	tst 58(a6)
	beq.s formp2
	add.l d1,a0
formp2:
	move.l a0,12(a6)	; dst0 + dd
	movem.l d0-d7/a2-a3,-(sp)
	bsr form_component_prediction
	movem.l (sp)+,d0-d7/a2-a3
	btst #0,Output_Type(pc)
	beq formpfin				; pas de couleur!
	move.l d0,a0
	moveq #0,d0
	move.b chroma_format(pc),d0
	exg.l d0,a0
	cmp #3,a0
	beq.s formp4
	lsr #1,d0
	move.l d1,20(a6)
	lsr #1,d2
	move.l d0,16(a6)
	lsr #1,d4
	move.l d2,24(a6)
	move.l d6,d6
	bpl.s formp7
	addq.l #1,d6
formp7:
	asr.l #1,d6
	move.l d4,32(a6)
	lsr #1,d1
	move.l d6,40(a6)
formp3:
	cmp #1,a0
	bne.s formp4
	lsr #1,d3
	lsr #1,d5
	move.l d3,28(a6)
	move.l d7,d7
	bpl.s formp8
	addq.l #1,d7
formp8:
	asr.l #1,d7
	move.l d5,36(a6)
	move.l d7,44(a6)
formp4:
	move.l d1,d0
	tst 54(a6)
	bne.s formp5
	moveq #0,d1
formp5:
	move.l (a2)+,a0
	tst 58(a6)
	bne.s formp6
	moveq #0,d0
formp6:
	move.l (a3)+,a1
	add.l d1,a0
	add.l d0,a1
	move.l a0,8(a6)
	move.l a1,12(a6)
	movem.l d0-d1/a2-a3,-(sp)
	bsr.s form_component_prediction
	movem.l (sp)+,d0-d1/a2-a3
	move.l (a2),a0
	move.l (a3),a1
	add.l d1,a0
	add.l d0,a1
	move.l a0,8(a6)
	move.l a1,12(a6)
	bsr.s form_component_prediction
formpfin:
	movem.l (sp)+,d2-d7/a2/a3
	unlk a6
	rts

	; even.q
form_component_prediction:
	move.l 40(a6),d2		; dx
	move.l 44(a6),d3		; dy
	move.l d2,d0
	move.l 32(a6),d4		; x
	asr.l #1,d0
	move.l d3,d1
	add.l d4,d0
	asr.l #1,d1
	move.l 8(a6),a0		; src
	move.l 12(a6),a1		; dst
	add.l d0,a0
	add.l d4,a1
	move.l 16(a6),d4		; lx
	move.l 36(a6),d0  ; y
	muls.l d4,d0
	muls.l d4,d1
	add.l d0,a0
	add.l d0,a1
	add.l d1,a0
	moveq #0,d0
	moveq #0,d1
	btst #0,d2
	bne fcp1
	btst #0,d3
	bne.s fcp2
	tst 50(a6)		; average_flag+2, ici no v, no h half pel
	beq.s fcp1_0
	move.l 20(a6),d6		; lx2
	move.l 28(a6),d2		; h
	move.l 24(a6),d5		; w
	subq #1,d2
	subq #1,d5
fcp1_1:
	lea 0(a0,d6.l),a2
	lea 0(a1,d6.l),a3
	move d5,d3
fcp1_2:
	move.b (a1),d0
	move.b (a0)+,d1
	add d0,d1
	addq #1,d1			; d = (s + d + 1)>>1
	lsr #1,d1
	move.b d1,(a1)+
	dbf d3,fcp1_2
	move.l a2,a0
	move.l a3,a1
	dbf d2,fcp1_1
	rts
fcp1_0:
	move.l 20(a6),d6		; lx2
	move.l 28(a6),d2		; h
	move.l 24(a6),d5		; w
	subq #1,d2
	subq #1,d5
fcp1_3:
	lea 0(a0,d6.l),a2
	lea 0(a1,d6.l),a3
	move d5,d3
fcp1_4:
	move.b (a0)+,(a1)+		; d = s
	dbf d3,fcp1_4
	move.l a2,a0
	move.l a3,a1
	dbf d2,fcp1_3
	rts
fcp2:		; v half pel, not h
	tst 50(a6)		; average_flag+2
	beq.s fcp2_0
	move.l 20(a6),d6		; lx2
	move.l 28(a6),d2		; h
	move.l 24(a6),d5		; w
	subq #1,d2
	subq #1,d5
fcp2_1:
	lea 0(a0,d6.l),a2
	lea 0(a1,d6.l),a3
	move d5,d3
fcp2_2:
	move.b 0(a0,d4.l),d0
	move.b (a0)+,d1
	add d0,d1
	move.b (a1),d0
	addq #1,d1
	lsr #1,d1
	add d0,d1
	addq #1,d1
	lsr #1,d1
	move.b d1,(a1)+		; d = [d + 1 + (s + s+lx + 1)>>1 ]>>1
	dbf d3,fcp2_2
	move.l a2,a0
	move.l a3,a1
	dbf d2,fcp2_1
	rts
fcp2_0:
	move.l 20(a6),d6		; lx2
	move.l 28(a6),d2		; h
	move.l 24(a6),d5		; w
	subq #1,d2
	subq #1,d5
fcp2_3:
	lea 0(a0,d6.l),a2
	lea 0(a1,d6.l),a3
	move d5,d3
fcp2_4:
	move.b 0(a0,d4.l),d0
	move.b (a0)+,d1
	addq #1,d0
	add d1,d0
	lsr #1,d0
	move.b d0,(a1)+			; d =(s + s+lx + 1)>>1
	dbf d3,fcp2_4
	move.l a2,a0
	move.l a3,a1
	dbf d2,fcp2_3
	rts
fcp1:
	btst #0,d3
	bne.s fcp3
	tst 50(a6)		; average_flag+2, ici h half pel, no v
	beq.s fcp3_0
	move.l 20(a6),d6		; lx2
	move.l 28(a6),d2		; h
	move.l 24(a6),d5		; w
	subq #1,d2
	subq #1,d5
fcp3_1:
	lea 0(a0,d6.l),a2
	lea 0(a1,d6.l),a3
	move d5,d3
fcp3_2:
	move.b (a0)+,d0
	move.b (a0),d1
	add d0,d1
	move.b (a1),d0
	addq #1,d1
	lsr #1,d1
	add d0,d1
	addq #1,d1
	lsr #1,d1
	move.b d1,(a1)+		; d = [d + 1 + (s + s+1 + 1)>>1 ]>>1
	dbf d3,fcp3_2
	move.l a2,a0
	move.l a3,a1
	dbf d2,fcp3_1
	rts
fcp3_0:
	move.l 20(a6),d6		; lx2
	move.l 28(a6),d2		; h
	move.l 24(a6),d5		; w
	subq #1,d2
	subq #1,d5
fcp3_3:
	lea 0(a0,d6.l),a2
	lea 0(a1,d6.l),a3
	move d5,d3
fcp3_4:
	move.b (a0)+,d0
	move.b (a0),d1
	addq #1,d0
	add d1,d0
	lsr #1,d0
	move.b d0,(a1)+			; d =(s + s+1 + 1)>>1
	dbf d3,fcp3_4
	move.l a2,a0
	move.l a3,a1
	dbf d2,fcp3_3
	rts
fcp3:		; v & h half pel
	tst 50(a6)		; average_flag+2
	beq.s fcp4_0
	move.l 20(a6),d6		; lx2
	move.l 28(a6),d2		; h
	move.l 24(a6),d5		; w
	subq #1,d2
	subq #1,d5
fcp4_1:
	lea 0(a0,d6.l),a2
	lea 0(a1,d6.l),a3
	move d5,d3
fcp4_2:
	move.b 0(a0,d4.l),d0
	move.b (a0)+,d1
	add d1,d0
	move.b (a0),d1
	add d1,d0
	move.b 0(a0,d4.l),d1
	addq #2,d0
	add d1,d0
	lsr #2,d0
	move.b (a1),d1
	addq #1,d0
	add d1,d0
	lsr #1,d0
	move.b d0,(a1)+	; d = [ d + ( s + s+1 + s+lx + s+lx+1 +2)>>2 +1]>>1
	dbf d3,fcp4_2
	move.l a2,a0
	move.l a3,a1
	dbf d2,fcp4_1
	rts
fcp4_0:
	move.l 20(a6),d6		; lx2
	move.l 28(a6),d2		; h
	move.l 24(a6),d5		; w
	subq #1,d2
	subq #1,d5
fcp4_3:
	lea 0(a0,d6.l),a2
	lea 0(a1,d6.l),a3
	move d5,d3
fcp4_4:
	move.b 0(a0,d4.l),d0
	move.b (a0)+,d1
	add d1,d0
	move.b (a0),d1
	add d1,d0
	move.b 0(a0,d4.l),d1
	addq #2,d0
	add d1,d0
	lsr #2,d0
	move.b d0,(a1)+	; d = ( s + s+1 + s+lx + s+lx+1 +2)>>2
	dbf d3,fcp4_4
	move.l a2,a0
	move.l a3,a1
	dbf d2,fcp4_3
	rts

	even.l
PMBtab0:
	dc.b -1,0
	dc.b 8,3
	dc.b 2,2,2,2
	dc.b 8+2,1
	dc.b 8+2,1
	dc.b 8+2,1
	dc.b 8+2,1
PMBtab1:
	dc.b -1,0
	dc.b 16+1,6
	dc.b 16+2,5,16+2,5
	dc.b 16+8+2,5,16+8+2,5
	dc.b 1,5,1,5
BMBtab0:
	dc.b -1,0
	dc.b -1,0
	dc.b 8,4
	dc.b 8+2,4
	dc.b 4,3
	dc.b 4,3
	dc.b 4+2,3
	dc.b 4+2,3
	dc.b 8+4,2
	dc.b 8+4,2
	dc.b 8+4,2
	dc.b 8+4,2
	dc.b 8+4+2,2
	dc.b 8+4+2,2
	dc.b 8+4+2,2
	dc.b 8+4+2,2
BMBtab1:
	dc.b -1,0
	dc.b 16+1,6
	dc.b 16+4+2,6
	dc.b 16+8+2,6
	dc.b 16+8+4+2,5
	dc.b 16+8+4+2,5
	dc.b 1,5
	dc.b 1,5
spIMBtab:
	dc.b -1,0
	dc.b 64,4
	dc.b 16+1,4
	dc.b 1,4
	dc.b 64+16+2,2,64+16+2,2
	dc.b 64+16+2,2,64+16+2,2
	dc.b 64+2,1,64+2,1
	dc.b 64+2,1,64+2,1
	dc.b 64+2,1,64+2,1
	dc.b 64+2,1,64+2,1
spPMBtab0:
	dc.b -1,0
	dc.b -1,0
	dc.b 8,4
	dc.b 32+8,4
	dc.b 16+8+2,3,16+8+2,3
	dc.b 32+8+2,3,32+8+2,3
	dc.b 8+2,2
	dc.b 8+2,2
	dc.b 8+2,2
	dc.b 8+2,2
	dc.b 32+16+8+2,2
	dc.b 32+16+8+2,2
	dc.b 32+16+8+2,2
	dc.b 32+16+8+2,2
spPMBtab1:
	dc.b -1,0
	dc.b -1,0
	dc.b 64+16+2,7
	dc.b 64,7
	dc.b 2,7
	dc.b 64+2,7
	dc.b 16+1,7
	dc.b 1,7
	dc.b 16+2,6
	dc.b 16+2,6
	dc.b 32+16+2,6
	dc.b 32+16+2,6
	dc.b 32,6
	dc.b 32,6
	dc.b 32+2,6
	dc.b 32+2,6
spBMBtab0:
	dc.b 8,4
	dc.b 8+2,4
	dc.b 4,3
	dc.b 4,3
	dc.b 4+2,3
	dc.b 4+2,3
	dc.b 8+4,2
	dc.b 8+4,2
	dc.b 8+4,2
	dc.b 8+4,2
	dc.b 8+4+2,2
	dc.b 8+4+2,2
	dc.b 8+4+2,2
	dc.b 8+4+2,2
spBMBtab1:
	dc.b 16+8+2,7
	dc.b 16+4+2,7
	dc.b 1,7
	dc.b 16+8+4+2,7
	dc.b 32+8,6
	dc.b 32+8,6
	dc.b 32+8+2,6
	dc.b 32+8+2,6
	dc.b 32+4,6
	dc.b 32+4,6
	dc.b 32+4+2,6
	dc.b 32+4+2,6
spBMBtab2:
	dc.b 16+1,8
	dc.b 16+1,8
	dc.b 32+16+8+2,8
	dc.b 32+16+8+2,8
	dc.b 32+16+4+2,9
	dc.b 64+16+2,9
	dc.b 64,9
	dc.b 64+2,9
SNRMBtab:
	dc.b -1,0
	dc.b 0,3
	dc.b 16+2,2
	dc.b 16+2,2
	dc.b 2,1
	dc.b 2,1
	dc.b 2,1
	dc.b 2,1
scan:
	dc.b 0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5
	dc.b 12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28
	dc.b 35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51
	dc.b 58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63
	dc.b 0,8,16,24,1,9,2,10,17,25,32,40,48,56,57,49
	dc.b 41,33,26,18,3,11,4,12,19,27,34,42,50,58,35,43
	dc.b 51,59,20,28,5,13,6,14,21,29,36,44,52,60,37,45
	dc.b 53,61,22,30,7,15,23,31,38,46,54,62,39,47,55,63
default_intra_quantizer_matrix:
	dc.b 8, 16, 19, 22, 26, 27, 29, 34
	dc.b 16, 16, 22, 24, 27, 29, 34, 37
	dc.b 19, 22, 26, 27, 29, 34, 34, 38
	dc.b 22, 22, 26, 27, 29, 34, 37, 40
	dc.b 22, 26, 27, 29, 32, 35, 40, 48
	dc.b 26, 27, 29, 32, 35, 40, 48, 58
	dc.b 26, 27, 29, 34, 38, 46, 56, 69
	dc.b 27, 29, 35, 38, 46, 56, 69, 83
Non_Linear_quantizer_scale:
	dc.b  0, 1, 2, 3, 4, 5, 6, 7
	dc.b  8,10,12,14,16,18,20,22
	dc.b 24,28,32,36,40,44,48,52
	dc.b 56,64,72,80,88,96,104,112

	; d2,d3,d4,a2,a3,cc, memory

Initialize_Decoder:
	lea Clip,a0
	moveq #0,d1
	moveq #23,d0
id8:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d0,id8
	move.l #$00010203,d0
	move.l #$04040404,d1
	moveq #63,d2
id9:
	move.l d0,(a0)+
	add.l d1,d0
	dbf d2,id9
	moveq #-1,d0
	moveq #-1,d1
	moveq #47,d2
id10:
	move.l d0,(a0)+
	move.l d1,(a0)+
	dbf d2,id10
	lea DCTptr,a0
	moveq #15,d0
	moveq #0,d1
id7:
	move.l d1,(a0)+
	dbf d0,id7
	lea DCTtab6,a1
	moveq #15,d0
id6:
	move.l (a1)+,(a0)+
	dbf d0,id6
	moveq #15,d0
id5:
	move.l (a1)+,d1
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d0,id5
	moveq #15,d0
id4:
	move.l (a1)+,d1
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d0,id4
	moveq #15,d0
id3:
	move.l (a1)+,d1
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d0,id3
	moveq #15,d0
id2:
	move.l (a1)+,d1
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d0,id2
	moveq #7,d0
id1:
	move.l (a1)+,d1
	moveq #7,d2
id1a:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d2,id1a
	dbf d0,id1
	moveq #59,d0
id0:
	move.l (a1)+,d1
	moveq #31,d2
id0a:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d2,id0a
	dbf d0,id0
	moveq #11,d0
idnext:
	move.l (a1)+,d1
	move #511,d2
idnexta:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d2,idnexta
	dbf d0,idnext
	rts
	even.l
DCTtab6:
  dc.l $12010010, $11010010, $10010010, $0F010010
  dc.l $03060010, $02100010, $020F0010, $020E0010
  dc.l $020D0010, $020C0010, $020B0010, $011F0010
  dc.l $011E0010, $011D0010, $011C0010, $011B0010
DCTtab5:
  dc.l $2800000F, $2700000F, $2600000F, $2500000F
  dc.l $2400000F, $2300000F, $2200000F, $2100000F
  dc.l $2000000F, $0E01000F, $0D01000F, $0C01000F
  dc.l $0B01000F, $0A01000F, $0901000F, $0801000F
DCTtab4:
  dc.l $1F00000E, $1E00000E, $1D00000E, $1C00000E
  dc.l $1B00000E, $1A00000E, $1900000E, $1800000E
  dc.l $1700000E, $1600000E, $1500000E, $1400000E
  dc.l $1300000E, $1200000E, $1100000E, $1000000E
DCTtab3:
  dc.l $020A000D, $0209000D, $0305000D, $0403000D
  dc.l $0502000D, $0701000D, $0601000D, $0F00000D
  dc.l $0E00000D, $0D00000D, $0C00000D, $011A000D
  dc.l $0119000D, $0118000D, $0117000D, $0116000D
DCTtab2:
  dc.l $0B00000C, $0208000C, $0304000C, $0A00000C
  dc.l $0402000C, $0207000C, $0115000C, $0114000C
  dc.l $0900000C, $0113000C, $0112000C, $0501000C
  dc.l $0303000C, $0800000C, $0206000C, $0111000C
DCTtab1:
  dc.l $0110000A, $0205000A, $0700000A, $0302000A
  dc.l $0401000A, $010F000A, $010E000A, $0204000A
DCTtab0:
  dc.l $00410006, $00410006, $00410006, $00410006
  dc.l $02020007, $02020007, $01090007, $01090007
  dc.l $04000007, $04000007, $01080007, $01080007
  dc.l $01070006, $01070006, $01070006, $01070006
  dc.l $01060006, $01060006, $01060006, $01060006
  dc.l $02010006, $02010006, $02010006, $02010006
  dc.l $01050006, $01050006, $01050006, $01050006
  dc.l $010D0008, $06000008, $010C0008, $010B0008
  dc.l $02030008, $03010008, $05000008, $010A0008
  dc.l $03000005, $03000005, $03000005, $03000005
  dc.l $03000005, $03000005, $03000005, $03000005
  dc.l $01040005, $01040005, $01040005, $01040005
  dc.l $01040005, $01040005, $01040005, $01040005
  dc.l $01030005, $01030005, $01030005, $01030005
  dc.l $01030005, $01030005, $01030005, $01030005
DCTtabnext:
  dc.l $02000004, $01020004, $01010003, $01010003
  dc.l $00400002, $00400002, $00400002, $00400002
  dc.l $01000002, $01000002, $01000002, $01000002
idfin:
	rts
	; d2,cc, memory

Initialize_Buffer:
	SEEK #0,0
	tst.b System_Stream_Flag(pc)
	beq.s ib1
	lea Sas,a0
	move.l a0,Sasflag
	clr.l Sasptr
	pea (a0)
	move.l #65540,-(sp)
	move.w mov_h,-(sp)
	move.w #63,-(sp)
	trap #1
	add.w #12,sp
ib1:
	moveq #-1,d0
	addq #1,d0
	trapcs
	moveq #32,d0
	move.l d0,Incnt
	rts
	; d2,a2,cc, memory

	even.l
adresse_retour: dc.l 0
Sauve_Vecteur: dc.l 0

Full_Block: dc.w 0
Full_Block_Sav: dc.w 0

backward_reference_frame: dc.l 0,0,0
forward_reference_frame: dc.l 0,0,0
auxframe: dc.l 0,0,0
current_frame: dc.l 0,0,0

Coded_Picture_Width: dc.l 0
Coded_Picture_Height: dc.l 0
Chroma_Width: dc.l 0
Chroma_Height: dc.l 0
block_count: dc.l 0

horizontal_size: dc.l 0
vertical_size: dc.l 0
mb_width: dc.l 0
mb_height: dc.l 0

temporal_reference: dc.l 0

MBA: dc.l 0
MBAmax: dc.l 0
MBAinc: dc.l 0
macroblock_type: dc.l 0
motion_type: dc.l 0
dct_type: dc.l 0
dc_dct_pred: dc.l 0,0,0
PMV: dc.l 0,0,0,0,0,0,0,0
motion_vertical_field_select: dc.l 0,0,0,0
dmvector: dc.l 0,0

frame_pred_frame_dct: dc.l 0

	; les incompressibles
Sequence_Framenum: dc.l 0

Incnt: dc.l 0
Rdptr: dc.l 0

Sasptr: dc.l 0
Sasflag: dc.l 0 ; 0 rien en cours, -1 FIN, >0 taille restante

alternate_scan: dc.l 0  ; adr de la matrice scan
quantizer_scale: dc.w 0
f_code: dc.w 0,0,0,0
	; les souvent
motion_vector_count: dc.b 0
mv_format: dc.b 0
mvscale: dc.b 0
picture_coding_type: dc.b 0
MPEG2_Flag: dc.b 0
Fault_Flag: dc.b 0
picture_structure: dc.b 0
intra_vlc_format: dc.b 0
intra_dc_precision: dc.b 0
scalable_mode: dc.b 0
Second_Field: dc.b 0
full_pel_forward_vector: dc.b 0
forward_f_code: dc.b 0
full_pel_backward_vector: dc.b 0
backward_f_code: dc.b 0

	; les rares
dmv: dc.b 0
progressive_sequence: dc.b 0
chroma_format: dc.b 0
pict_scal: dc.b 0
q_scale_type: dc.b 0
concealment_motion_vectors: dc.b 0
System_Stream_Flag: dc.b 0
top_field_first: dc.b 0
spatial_temporal_weight_code_table_index: dc.b 0
stwtype: dc.b 0
stwclass: dc.b 0
aspect_ratio_information: dc.b 0
frame_rate_code: dc.b 0
Output_Type: dc.b 0
mpg_sound: dc.b 0
	even.l
fin_mpg_var:
	dc.l 0
mpg_big:	dc.l GROSMPG

_count_mpg_frames:
	movem.l d0-d7/a0-a6,-(sp)
	move.l tree,-(sp)
	moveq #11,d6
	GADDR d6					; a0 = address of 11th tree
	move.l 60(a0),a0		; tedinfo
	move.l (a0),a0			; text (enfin...
	clr.b (a0)				; chaine r‚initialis‚e
	moveq #0,d7
	bsr.l manage_tree
	move.l tree,a0
	move.l (sp)+,tree
	cmp #3,d6				; compter?
	bne.s .autre
	bsr.s __count			; d‚sactiv‚ pour l'instant...

;	lea mpg_big(pc),a0	; compter dans le fichier!
;	move.l #$3FFFFFFF,(a0)
;	move.b Output_Type,d0
;	move.l d0,-(sp)
;	bsr.s mpg_parse_bin
;	move.l (sp)+,d0
;	move.b d0,Output_Type
;	tst.l sample_num		; EQ si pb	
	
	movem.l (sp)+,d0-d7/a0-a6
	rts
.autre:
	cmp #5,d6				; accepter ma valeur?
	bne.s .autre2
	move.l 60(a0),a0		; tedinfo
	moveq #0,d1
	move.l (a0),a0			; text (enfin...
	moveq #0,d0
.txt_to_int:
	move.b (a0)+,d1
	beq.s .ok
	muls.l #10,d0
	sub.b #'0',d1
	add.l d1,d0
	bra.s .txt_to_int
.ok:
	move.l d0,sample_num	; si EQ, pas d'image.
	movem.l (sp)+,d0-d7/a0-a6
	rts
.autre2:
	moveq #0,d0				; EQ
	movem.l (sp)+,d0-d7/a0-a6
	rts						; ah! je ne veux plus convertir!

__count:
	if 1=0		; disabled
	
	SEEK #0,0
	move.l #65540,d6
	lea Sas,a3
	pea (a3)
	move.l d6,-(sp)
	move.w mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d0,d6
	sne d5
	subq.l #4,d6
	move.l d6,d0
.lb1:
	subq.l #1,d0
.lb0:
	tst.b (a3)+		; 00
	bne.s .loop
	tst.b (a3)		; 00
	bne.s .loop
	cmp.b #1,1(a3)	; 01
	bne.s .loop
	tst.b 2(a3)		; 00
	bne.s .loop
	addq.l #1,sample_num		; code 00 00 01 00 found = one frame!
.loop:
	dbf d0,.lb0
	tst.b d5
	bne.s .end
	move.l (a3),d0
	lea Sas,a3
	move.l d0,(a3)		; last 4 bytes at the beginning
	pea 4(a3)
	move.l d6,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d6,d0
	sne d5				; end of file !
	bra.s .lb1
.end:

	endif
	
	rts
	
	
mpg_parse_bin:
	lea adresse_retour(pc),a0
	move.l #(fin_mpg_var-adresse_retour)/4-1,d2
	moveq #0,d1
.erase:
	move.l d1,(a0)+
	dbf d2,.erase
	move.l #'mpg1',comp_txt
	moveq #0,d5
	tst.l frequency
	sne d5
	move.b d5,mpg_sound
	ext d5		; WORD negatif si il y a du son
	move.l total,d1
	cmp.l mpg_big(pc),d1		; grosse anim???
	smi d5		; non nul si petite anim
	bmi.s .aaa
	move.b ([kbshift]),d5	; sinon, voir SHIFT pour forcer comptage
	and.b #3,d5			; BYTE non nul si SHIFT
.aaa:
	move planes,d0
	tst.b res_switch
	beq.s .no_sw
	bmi.s .aab
	moveq #8,d0
	bra.s .no_sw
.aab:
	moveq #16,d0
.no_sw:
	cmp #16,d0
	seq can_fast
	st samp_sizes
	bsr Init_Trapcs
	bsr Initialize_Buffer
	move.l Rdptr(pc),a5
	move.l Incnt(pc),d6
	bfextu (a5){d6:8},d0
	cmp.b #$47,d0
	beq .fin
	bsr next_start_code
	move.l Incnt(pc),d6
	bfextu (a5){d6:32},d0
	moveq #0,d1
	cmp.l #$1b3,d0
	beq.s .ok
	cmp.l #$1ba,d0
	bne.s .voir
.des_paquets:
	moveq #1,d1
	bra.s .ok
.voir:
	cmp.l #$1e0,d0
	beq.s .des_paquets
	bra .fin
.ok:
	move.b d1,System_Stream_Flag
	bsr Initialize_Buffer
	bra.s .next
.gh0:
	move d1,Incnt+2
.next:
	bsr next_start_code
	move.l Incnt(pc),d1
	move.l Rdptr(pc),a1
	bfextu (a1){d1:32},d0
	add #32,d1
	trapcs
	cmp.l #$1b3,d0
	bne.s .gh1
	btst #16,d5
	bne.s .gh0	; d‚j… lu
	bsr sequence_header
	bset #16,d5
	bra.s .next
.gh1:
	cmp.l #$1b8,d0
	bne.s .gh2
	btst #17,d5
	bne.s .gh0
	bsr group_of_pictures_header
	bset #17,d5
	bra.s .next
.gh2:
	cmp.l #$100,d0
	bne.s .gh3
	addq.l #1,sample_num
	btst #18,d5
	bne.s .gh4
	bsr picture_header
	bset #18,d5
	tst.b d5
	bne.s .next
	bra.s .gh5
.gh4:
	tst.b d5
	bne.s .gh0		; continuer … compter
.gh5:
	st unknown					; nombre inconnu
	clr.l sample_num
	bra.s .fin_header
.gh3:
	cmp.l #$1b7,d0
	bne .gh0
.fin_header:
	move horizontal_size+2,max_imagex
	move vertical_size+2,max_imagey
	moveq #0,d0
	move.b frame_rate_code,d0
	move.b .temps(pc,d0.w),d0
	ext.l d0
	move.l d0,avi_rate		; images par seconde
	move.l #200,d1
	divs.l d0,d1				; number of 1/200 per image
	move.l d1,_delay
	tst.b mpg_sound(pc)
	beq.s .pas_son
.cherche_son:
	bsr next_start_code
	tst.b mpg_sound(pc)
	beq.s .pas_son				; finalement, trouv‚!
	move.l Incnt(pc),d1
	move.l Rdptr(pc),a1
	bfextu (a1){d1:32},d0
	add #32,d1
	trapcs
	move d1,Incnt+2
	cmp.l #$1b7,d0
	bne.s .cherche_son		; pas encore le code de fin
	moveq #0,d0
	move.l d0,frequency		; pas de son trouv‚, donc pas de son...
.pas_son:
	bsr Restore_Trapcs
	tst.b MPEG2_Flag(pc)
	beq.s .fin
	addq.b #1,comp_txt+3		; du mpeg 2 finalement
.fin:
	rts
.temps: dc.b 30,23,24,25,30,30,50,60,60,15,30,30,30,30,30,30

mpg_sound_infos:
	movem.l d3-d4/a1/a3-a4,-(sp)
	moveq #0,d4					; pas de lecture supplmentaire
	bsr .mpg_get_byte
	and #$ff,d0
	ror #6,d0
	cmp.b #2,d0
	bne.s .kautre
	bsr .mpg_get_byte
	bsr .mpg_get_byte
	and #$ff,d0
	subq #1,d0
	move d0,d6
	bra.s .ksauter
.kautre:
	rol #6,d0			; recupere
	cmp.b #$ff,d0
	bne.s .kautre2
.kouf:
	bsr .mpg_get_byte
	cmp.b #$ff,d0
	beq.s .kouf
.kautre2:
	cmp #$40,d0
	bmi.s .kautre3
	bsr .mpg_get_byte
	bsr .mpg_get_byte
.kautre3:
 	cmp #$30,d0
 	bmi.s .kautre4
 	moveq #8,d6		; sauter 9
 	bra.s .ksauter
.freq: dc.w 22050,24000,16000,0,44100,48000,32000,0
.kautre4:
	cmp #$20,d0
	bmi.s .kautre5
	moveq #3,d6		; sauter 4
.ksauter:
	bsr.s .mpg_get_byte
	dbf d6,.ksauter
.kautre5:
	bsr.s .mpg_get_byte	; inutile
	bsr.s .mpg_get_byte
	and #$8,d0
	lea .freq(pc,d0.w),a4
	bsr.s .mpg_get_byte
	and #$c,d0
	lsr #1,d0
	move 0(a4,d0.w),frequency+2
	bsr.s .mpg_get_byte
	ror #6,d0
	and #$C003,d0
	moveq #2,d1
	cmp.b #3,d0
	bne.s .ster
	moveq #1,d1
.ster:
	move d1,channels
	rol #2,d0
	and #3,d0
	addq #1,d0
	lsl #2,d0
	move d0,sound_bits
	tst.l d4
	beq.s .fin
	SEEK d4,1
.fin:
	movem.l (sp)+,d3-d4/a1/a3-a4
	rts
.mpg_get_byte:
	move.b (a3)+,d0
	addq #1,d3
	bcs.s .read_encore
	rts
.read_encore:
	move.l d0,-(sp)
	move.l #1024,d0
	sub.l d0,d4			; taille … reculer ensuite
	lea DVI_DELTA,a3	; zone temporaire
	sub d0,d3			; 65536-1024 pour simuler
	pea (a3)
	move.l d0,-(sp)
	move.w mov_h,-(sp)
	GEMDOS 63,12
	move.l (sp)+,d0
	rts

skip_iv32:
	move.l a0,d0
	bne.s accessory
	move.l  4(a7),a5
	move.l a5,basepage
   move.l $18(a5),d0
   add.l $1c(a5),d0
   add.l #$100,d0
   lea _pile,sp
   sub.l a5,d0
   move.l  d0,-(sp)
   move.l  a5,-(sp)
   clr -(sp)
   GEMDOS $4a,12              ; MSHRINK reduces space
   sf acc
   bra.s common

menu_reg: dc.l mr_cont,global,appl_id,menu_id,menu_nom,dum
mr_cont: dc.w 35,1,1,1,0
menu_nom: dc.l _menu_nom
menu_id: dc.w 0
_menu_nom: dc.b "  M_Player V"
			dc.l VERSION
			dc.b 0,0
	even

accessory:
	lea _pile,sp
	st acc

common:
	sf rsc
	sf step_vdi
   GEM_AES appl_init
	tst.b acc
	beq.s .lb0
   GEM_AES menu_reg				; the name of the accessory
.lb0:
	XBIOS 34,2
	move.l d0,kvdbbase			; used to intercept keyboard
	
   clr mf_int
   GEM_AES graf_mouse			; the arrow
   GEM_AES graf_hand
   move intout,aes_handle
   move intout+8,boxh			; height of one char

	sf nova							; default is not NOVA
	sf is_tt							; and no basic tt
	clr.l ed_adr					; no VDI extension
	pea cookie						; cookies+ kbshift address
	XBIOS 38,6						; supexec
	move.l ed_adr,ed_adr_sav	; in case of ACC to repeat

	moveq #0,d0	
	lea langue,a0
	move.b (a0)+,d0				; value found in OS-header or _AKP cookie
	move.b d0,d1					; par d‚faut, pas deux langues ‚gales
	bne.s .lg1
	moveq #3,d1						; si US=0 alors UK=3 ami
	bra.s .lgok
.lg1:
	cmp.b #1,d0
	bne.s .lg2
	moveq #8,d1						; si GE=1 alors suisse allemand=8 ami
	bra.s .lgok
.lg2:
	cmp.b #2,d0
	bne.s .lg3
	moveq #7,d1						; si FR=2 alors suisse fran‡ais=7 ami
	bra.s .lgok
.lg3:
	cmp #7,d0						; suisse france
	bne.s .lb2
	moveq #2,d0						; france
	move d0,d1
.lb2:
	cmp #8,d0						; suisse allemande
	bne.s .lb3
	moveq #1,d0						; allemagne
	move d0,d1
.lb3:
	cmp #3,d0						; uk?
	bne.s .lgok
	moveq #0,d0						; US
	move d0,d1
.lgok:
	move.b d1,(a0)					; langue amie
	moveq #1,d7						; marqueur "1er essai RSC"
.lb4:
	lea _name,a0
	move.l #'M_PL',(a0)+
	move.l #'AYER',(a0)+
	tst.b d7
	bpl.s .lb41						; 1st time, try with country code
	move.l #".RSC",(a0)+	
	bra.s .lb42						; 2nd time with RSC
.lb41:
	move #'.0',(a0)+
	divs #10,d0
	add.l #$00300030,d0
	move.b d0,(a0)+
	swap d0
	move.b d0,(a0)+
	move -2(a0),country_code	; for debug line !
.lb42:
	clr.b (a0)						; fabrique M_PLAYER.000 ->code pays
	
	tst.b acc
	beq.s .lb00
	pea _get_boot_drive
	XBIOS 38,6
	bra.s .lb01
.lb00:
	GEM_AES shel_find
	tst intout
	beq.s .lb03
.lb01:
	GEM_AES rsrc_load
	tst intout
	bne.s .lb1
.lb03:
	tst.b d7
	bmi.s .lb02			; RSC yest tested... error
	st d7
	bra .lb4			; back on shel find !
.lb02:
	move.l #no_rsc,d0		; alert no RSC found
	bsr.l alert
	tst.b acc
	beq end_end
.lb1:
	bsr.l free_strings			; pointers to free strings
	bsr.l alert_table				; pointers to alert strings
	bsr.l build_dialogue_table
	bsr.l load_options
	bsr.l set_easybat_path
   tst.b acc
   beq no_acc

acc_wait:
	tst.b repondre
	beq.s .lb1
	GEM_AES appl_write
	sf repondre
.lb1:
	bsr wait_message
	sf acc_command
	cmp #40,(a0)					; AC_OPEN?
	bne.s .lb0						; no, other message...
	move 8(a0),d0					; menu_id
	cmp menu_id,d0
	bne.s .lb1					; not my accessory
.go:
	move.l #intout,vq_extnd+12
	move #1,ve_int
	move.l ed_adr_sav,ed_adr	; as it is overwritten each time
	bra no_acc					; ok, open!
.lb0:
	cmp #'MP',(a0)
	bne.s .lb1
	tst 10(a0)						; 0: rien renvoyer a l'appelant
	beq.s .rien
	lea mp_buffer,a1
	move 10(a0),(a1)+				; le message voulu
	move 2(a0),mp_id				; l'ID de l'appelant
	move appl_id,(a1)+			; id m_player pour repondre
	clr (a1)+
	st repondre
.rien:
	move.l 6(a0),acc_cmd_adr	; command address?
	beq.s .go						; nothing, just open
	st acc_command					; one command line!
	bra.s .go
	
_get_boot_drive:
	lea _name+13,a0		; builds C:\M_PLAYER.RSC+0
	lea 3(a0),a1
	moveq #12,d0
.lb0:
	move.b -(a0),-(a1)
	dbf d0,.lb0
	move.b #'\',-(a1)
	move.b #':',-(a1)
	move $446.w,d0			; C drive or boot drive
	add.b #'A',d0
	move.b d0,-(a1)
	rts	

wait_message:
	lea em_buffer,a0
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	GEM_AES evnt_mesag
	lea em_buffer,a0
	rts

evnt_mesag: dc.l em_cont,global,dum,dum,em_add,dum
em_cont: dc.w 23,0,1,1,0
em_add: dc.l em_buffer			; the buffer

appl_write: dc.l aw_cont,global,mp_id,dum,aw_addr,dum
aw_cont: dc.w 12,2,1,1,0
mp_id: dc.w -1,16
aw_addr: dc.l mp_buffer

appl_find: dc.l af_cont,global,dum,mp_id,af_addrin,dum
af_cont: dc.w 13,0,1,1,0
af_addrin: dc.l acc_name
acc_name: dc.b "ACCMPLAY",0,0

no_acc:
	XBIOS 4,2						; get rez
	addq #2,d0
	move d0,ow_int             ; getrez+2
	move aes_handle,i_handle			; gets the AES handle
	GEM_VDI open_work          ; opens my virtual workstation
	move ow_cont+12,i_handle	; and saves my handle

	GEM_VDI show_mouse
	GEM_VDI vsf_interior			; one color
	GEM_VDI vsf_color				; and this color is black

	cmp #2,mch_value
	seq is_mw						; microwire interface on TT Only
	beq.s .microw					; is_mw = FF for the TT
	lea snd_value,a0
	btst #2,3(a0)
	beq.s .microw
	move.b #$1,is_mw				; is_mw = 01 for the Falcon/Xbios
	bsr.l adapt_sound_panel		; disable master, trebble, bass and mix
.microw:
	lea microwire,a4
	bsr.l set_microwire

	cmp #5,mch_value				; Aranym?
	bne.s .no_aranym
	move.l #3,snd_value			; yes, so forces DMA sound
	lea real_freq_tab,a0
	move.l 32(a0),(a0)+
	move.l 32(a0),(a0)+
	move.l 32(a0),(a0)+
	move.l 32(a0),(a0)

.no_aranym:
	move.l ed_adr,d0
	beq.s .no_Xvdi
	move.l d0,a0
	moveq #0,d0						; function 0
	jsr (a0)							; EdDI
	cmp #$101,d0
	spl ed_adr						; if +, Real X present
	bmi.s .try_mac					; else try something else...
	GEM_VDI vq_extnd2
	move cvid_fix0+10,ed_adr+2	; real X (in bytes)
	bra.s .no_Xvdi
.try_mac:
	tst.b magicmac
	beq.s .no_Xvdi					; not magic mac!
	dc.w $A000						; else, linea gives the info
	st ed_adr
	move -2(a0),ed_adr+2
.no_Xvdi:
	move.b ([kbshift]),d0
	and.b #3,d0						; one of the shift keys?
	beq.s .no_shift
	and.b #1,d0						; le droit?
	sne psnd_flag					; alors forcer la carte parallele!!!
	move.b #1,snd_value+3		; simulates only Yamaha
.no_shift:
	lea snd_value,a0
	btst #2,3(a0)
	beq.s .no_falc_snd
	lea real_freq_tab,a0
	move.l 16(a0),(a0)+
	move.l 16(a0),(a0)+
	move.l 16(a0),(a0)+
	move.l 16(a0),(a0)

	move.w	#$1,-(sp)			; FPATCH2
	clr.l	-(sp)
	move.w	#$8,-(sp)
	clr.w	-(sp)
	move.w	#139,-(sp)
	trap	#$E
	lea	$C(sp),sp

	clr.w	-(sp)
	move.w	#132,-(sp)
	trap	#$E
	addq.l	#4,sp

	move.w	#$40,-(sp)
	move.w	#$2,-(sp)
	move.w	#130,-(sp)
	trap	#$E

	move.w	#$3,$2(sp)
	trap	#$E
	addq.l	#6,sp

	move.w	#$3,-(sp)
	move.w	#$6,-(sp)
	move.w	#$130,-(sp)
	trap	#$E

	move.w	#$4,$2(sp)
	trap	#$E

	move.w	#$5,$2(sp)
	trap	#$E
	addq.l	#6,sp
	lea snd_value,a0

.no_falc_snd:
	btst #1,3(a0)					; dma sound?
	sne (a0)							; snd_value=FF for DMA, 0 for no DMA
	bne.s .found_sound
	btst #0,3(a0)					; else, Yamaha?
	beq.s .found_sound
	move.b #1,(a0)					; 1=Yamaha

.found_sound:
	XBIOS 3,2						; logbase
	tst.b albertt
	beq.s .alb0
	move.l albert_phys,d0		; if albert, use the real physical screen
.alb0:
	move.l d0,old_screen
	move.l d0,physbase			; to act like a TT for FLM (example)
	swap d0
	and #$FF00,d0					; the upper byte only
	cmp #$FE00,d0					; into the VME addressable area?
	bne.s .lb0
	st nova							; yes, consider it as a graphic card!
.lb0:

	sf res_switch					; default is no resolution switch allowed
	tst.b nova						; a graphic card?
	bne.s .lb1						; yes, no switch
	cmp.l #$30000,vdo_value
	bmi.s .lb2						; at least a falcon video unit?
	st res_switch					; everything is ok, switch allowed
	move #-1,-(sp)
	XBIOS 88,4
	move d0,old_video
	move d0,-(sp)
	XBIOS 91,4
	move.l d0,old_size
	bra.s .lb1

.lb2:
	cmp.l #$20000,vdo_value		; a TT video unit???
	bne.s .lb1						; no!
	XBIOS 4,2						; get rez
	move d0,old_video
	move.b #$7f,res_switch		; true but positive
	st is_tt

.lb1:
	move #-1,mov_h					; a negative handle if no file opened
	move.l #TM,vdi_compression	; defaut monochrome if planes<16
	GEM_VDI vq_extnd
	move.w intout+8,d0			; number of planes
	move d0,planes_vdi			; ****
	cmp #16,d0
	bmi .test_less_than			; 8 bits = write to physbase? or MONO ?
	bgt.s .passe_en_vdi			; more than 16bits = use VDI
; tentative pour 16 bits
	cmp #5,mch_value
	beq.s .passe_en_vdi			;if ARANYM, always VDI
	move d0,planes_vdi
	sf is_vdi
	bsr.l get_screen_encoding
	moveq #16,d0
	move (a0),d1
	add.w 6(a0),d1
	cmp #1,d1						; mode 65k Motorola (Falcon)
	bne.s .mode_a
	sf nova
	moveq #3,d2
	bra.s .mode_com
.mode_a:
	st nova
	cmp #3,d1						; mode 65k Intel (NOVA)
	bne.s .mode_b
	moveq #4,d2
	bra.s .mode_com
.mode_b:
	moveq #3,d2
	cmp #2,d1							;  pour 32k Motorola (Hades? Milan?)
	bne.s .mode_com
	move #0,bit_rot
.mode_com:
	move d2,is_65k
	bra.s .not_vdi_mode
;	tst.b magicmac					; magic mac??
;	beq.s .not_a_mac
;	move.l physbase,a0
;	move.w (a0),d1					; first pixel should be white...
;	cmp #$FF7F,d1
;	bne.s .not_little_endian
;	move #3,is_65k					; same as NOVA!
;	bra.s .not_vdi_mode
;.not_little_endian:
;	cmp #$7FFF,d1
;	bne.s .passe_en_vdi			; passe en VDI car pas NOVA...
;	move #0,bit_rot				; rotation=0 with big endian
;	bra.s .not_vdi_mode
;.not_a_mac:
;	cmp #4,mch_value				; Aranym or Milan? (if >=4)
;	bmi.s .not_vdi_mode			; no: write to physbase in standard 16bits
.passe_en_vdi:
	move #3,is_65k					; in mode3 = 32768 colors
	move d0,planes_vdi			; if 24/32 bits, then simulate 16 bits
	st is_vdi						; and VDI mode on !!
	st nova							; and force NOVA
	clr.l ed_adr					; no vdi extension requiered
	bsr.l get_screen_encoding		; distinguish RVB, BVR, etc...
	moveq #16,d0
	bra.s .not_vdi_mode
.test_less_than:
	cmp #5,mch_value				; aranym type?
	seq bad_card					; if <16 planes and Aranym : mono display!
.not_vdi_mode:
	move d0,planes
	moveq #0,d1
	move ed_adr+2,d1				; width in bytes or dum
	beq.s .nook
	bmi.s .nook
	lsl.l #3,d1						; number of bits
	divs d0,d1						; number of pixels
	move d1,ed_adr+2
	moveq #1,d2
	add work_out,d2				; vdi X
	cmp d2,d1
	bpl.s .ook
.nook:
	sf ed_adr
.ook:
	bsr.l window_use

	move planes,d0
	cmp #16,d0						; High color?
	bne.s .lb11
	cmp.b #3,is_65k+1
	sne is_65k						; $FF if high color and not mode=3
.lb11:

;	GEM_VDI hide_mouse

;	tst.b acc
;	beq.s .lb3

;	bsr.l save_menu					; saves the menu_bar if accessory

.lb3:
	move.l #work_out,vq_extnd+12
	clr ve_int

	move planes,d0
	cmp #15,d0						; 32768 colors
	beq.s good2
	cmp #16,d0						; 65536 colors
	bne not_tc

good2:
	sf res_switch					; if in TC, don't change!
	tst.b nova
	bne.s _nova
		bsr.l falcon_adapt					; hc maps for the Falcon
	bra next


appl_init: dc.l ai_cont,global,dum,appl_id,dum,dum
ai_cont: dc.w 10,0,1,0,0
appl_id: dc.w 0


_nova:
		bsr.l nova_adapt						; hc maps for the NOVA card
	bra next


form_dial: dc.l fd_cont,global,fd_int,dum,dum,dum
fd_cont: dc.w 51,9,0,1,0
fd_int: dc.w 0,0,0,0,0,0,0,640,480

graf_shrinkbox: dc.l gsb_cont,global,gsb_int,dum,dum,dum
gsb_cont: dc.w 74,8,1,0,0


not_tc:
	bsr.l save_256					; saves the desktop color registers

	cmp #8,planes
	bne.s other

	tst.b nova						; 256 colors only with a NOVA card
	bne.s good
other:
	tst.b res_switch
	bne.s good3						; or if we can switch to TC, that's ok
	st bad_card
	bra.s good
;	pea bad_card
;	bsr.l alert
;	bra end_end
good3:
	bpl.s good4						; if >0 TT video
	move planes,planes_sav		; if a Falcon (we can switch to TC
	move #16,planes				; prepares 16 bits
		bsr.l falcon_adapt
	move planes_sav,planes		; comes back
	bra.s next
good4:
	move planes,planes_sav		; for a TT, always 256 colors
	move #8,planes
	bsr.l adapt_256
	move planes_sav,planes
	bra.s next
good:
	bsr.l adapt_256

next:
	; ****************** loads the resource file ****************
	bsr.l validate_sound_option

	tst.b rsc
	bne.s .lb4

	moveq #15,d0
	GADDR d0					; options tree
	lea 24*26+11(a0),a0	; state de Set Sound
	bset #3,(a0)			; default is disabled
	tst.b is_mw
	beq.s .lb0
	bclr #3,(a0)			; enabled if microwire present
.lb0:
	moveq #LAST_TREE,d0
	GADDR d0					; arbre step by step
	lea 2*24+12(a0),a0	; obspec FRM00000.TGA to change filename
	move.l a0,tree_filename
	moveq #2,d0
	GADDR d0					; info box
	moveq #0,d0
	GADDR d0					; first tree
	move.l a0,a1
	bsr.l treat_w_button
	st can_step
	cmp #16,planes		; TC, ok for step mode
	beq.s .lb3
	tst.b res_switch	; or we can go into TC mode? Ok
	bmi.s .lb3
	sf can_step			; else, no step mode (256 colors on NOVA or TT)

	; ****************** looks for a command line upon entry ****

.lb3:
	cmp #4,planes						; monochrome or 4 colors?
	bpl.s .lb4
	bsr adapt_rsc_colors				; yes, change to B&W
.lb4:
	sf command							; the default is NO COMMAND LINE
	tst.b acc
	beq.s .lb5							; no acc, test command line
	tst.b acc_command
	beq normal							; accessory and no command line
	move.l acc_cmd_adr,a5
	bra.s .lb6

.lb5:
	move.l basepage,a5
	lea $80(a5),a5						; the command line
	moveq #0,d0
	move.b (a5)+,d0					; the lenght
	beq normal						; if 0, no command line
;	cmp.b #127,d0
;	beq normal						; 127 pour ligne ‚tendue non g‚r‚e!!
	clr.b 0(a5,d0.w)				; ends the command line
.lb6:
	lea cmd_dial,a0
	move.l #$ffffff00,(a0)+		; set the default four flags
	clr.w (a0)+						; and the fifth and sixth
	clr.w (a0)						; and 7th + 8th
	bsr.l parse_command_line

	lea cmd_coord,a0
	cmp.b #$FF,(a0)
	bne.s .clear_coord			; no coords (or just one)
	tst.b cmd_dial
	beq.s .keep_coord				; if no dialogs, coords allowed
.clear_coord:
	clr.b (a0)
.keep_coord:
	tst.b (a0)
	beq.s .no_change_win
	sf can_win						; if coords, don't add a window!!
	move.l DVI_DELTA,a0
	or.b #$08,(a0)					; disabled
	and.b #$0F,(a0)				; not selected
.no_change_win:
	tst.b cmd_dial
	bne verify
	tst.b cmd_inter
	beq verify						; jumps if dial or if no hard interrupt
	bsr.l install_vectors

	bra verify


graf_hand: dc.l gh_cont,global,dum,intout,dum,dum
gh_cont: dc.w 77,0,5,0,0

adapt_rsc_colors:
	moveq #1,d0
	GADDR d0
	lea 3*24+14(a0),a0
	move.w (a0),-(sp)
	move.l a0,-(sp)		; progress bar Loading sound
	moveq #12,d0
	GADDR d0
	lea 12*24+14(a0),a0
	move.w (a0),-(sp)
	move.l a0,-(sp)		; progress bar Creating animation
	moveq #LAST_TREE,d0	; this one is always in B&W
	GADDR d0
	move.l a0,d7			; end of objects
	moveq #0,d0
	GADDR d0
.lb0:
	move 6(a0),d0			; ob type
	lea 14(a0),a1
	cmp #20,d0
	beq.s .box
	cmp #25,d0
	beq.s .box
	cmp #27,d0
	beq.s .box
	cmp #21,d0
	beq.s .ted
	cmp #22,d0
	beq.s .ted
	cmp #29,d0
	beq.s .ted
	cmp #30,d0
	bne.s .next
.ted:
	move.l 12(a0),a1	; tedinfo
	lea 18(a1),a1		; color word
.box:
	move.b #$11,(a1)+	; black for border and text
	and.b #$F0,(a1)	; white for fill
.next:
	lea 24(a0),a0
	cmp.l d7,a0
	bmi.s .lb0
	move.l (sp)+,a0
	move.w (sp)+,(a0)	; restore bar Loading sound
	move.l (sp)+,a0
	move.w (sp)+,(a0)	; idem for Creating
	rts

normal:
	; *********************** the names *************************
	tst.b rsc			; an accesory ran 2 times, no display
	bne.s general_menu	; and no path change
	moveq #2,d6
	bsr.l _debug_line


	; *********************** prepares the fileselector *********
	st rsc
	lea path,a4
	moveq #0,d0				; option 0 = default path
	bsr.l get_path			; use parameter 0 or build current path in A4

	lea path,a4
	lea tga_path,a0
	lea avr_path,a1
	lea opt_path,a2
	lea out_path,a3
.aaa:
	move.b (a4)+,d0
	move.b d0,(a0)+
	move.b d0,(a2)+
	move.b d0,(a1)+
	move.b d0,(a3)+
	bne.s .aaa				; copies the path into the tga path and avr path

	; ********************* the file selector *******************

general_menu:
	bsr.l display_general
	move.b menu_flag,d0
	ble.s again				; -1 (load) 0 (convert)
	cmp.b #2,d0				; capture screen
	beq.s .create_anim
	cmp.b #1,d0				; images to video
	bne.s .lb1
	bsr.l manage_easybat	
	beq.s general_menu	; if EQ, nothing to do
.create_anim:				; else create
	bsr zero_variables	
	bsr.l save_menu			; in case of ACC
	bra force_bat	
.lb1:
	cmp.b #6,d0				; search disk
	beq.s again
	bra.s general_menu




again:
	move #3,wu_int
	GEM_AES wind_update
	lea fs_addrin,a0
	cmp.b #6,menu_flag
	bne.s .lb0
	lea fs_addrin_parse2,a0
.lb0:
	bsr.l get_file
	move.b ([kbshift]),etat_sav
	move d0,-(sp)						; get file result
	move #2,wu_int
	GEM_AES wind_update
	tst (sp)+							; 0 if abort/cancel
	beq general_menu				; if 0, quits to menu

	; ******************* builds the full pathname of the movie *********

;	bsr.l redraw

	lea path,a0
	lea full,a1							; full will contain path+file
	lea full2,a3
	move.l a1,a2						; will keep the last '\' position

lb1:
	move.b (a0)+,d0					; a byte from path...
	beq.s copy_name					; it's the end of the path
	move.b d0,(a1)+					; ...to full
	move.b d0,(a3)+					; and to full2
	cmp.b #'\',d0
	bne.s lb1
	move.l a1,a2						; if '\', updates A2
	bra.s lb1

copy_name:
	sub.l a2,a1
	sub.l a1,a3							; last '\' in full2
	move.l a3,fname_pos
	lea file,a0							; the file name (or the mask!)
lb2:
	move.b (a0)+,(a2)+				; copies after the last '\'
	bne.s lb2							; til the end of the string

	; ***************** verifies if this file exists and opens it **********
verify:
	st rsc							; did it once (at least)
	btst #3,etat_sav					; si CONTROL, c'est un "parse disk"
	bne.s .glue
	cmp.b #6,menu_flag			; from general menu
	beq.s .glue						; parse disk
	pea dta
	GEMDOS 26,6						; fixes my own DTA
	move #1,-(sp)						; normal+read_only files
	pea full
	GEMDOS 78,8							; search first
	tst d0
	bpl.s next_file
	moveq #25,d0						; alert file doesn't exist
	bra.l ooops							; non, erreur
.glue:
	bsr.s zero_variables
	st is_parse
	bsr.l parse_disk						; oui! lancer recherche.
	bra end_of_display

zero_variables:
	sf is_win
	moveq #0,d0
	lea start_zero,a0					; datas that must be 0 at start
	lea end_zero,a1
.lb3:
	move.l d0,(a0)+					; zero a long word
	cmp.l a1,a0							; have we finished?
	bmi.s .lb3							; not yet
	rts

next_file:
	bsr.l save_menu
	move #2,mf_int
	GEM_AES graf_mouse			; the busy bee
	move.l dta+26,total				; the file length
	lea dta+30,a0						; the file name
	move.l fname_pos,a1
.lb0:
	move.b (a0)+,(a1)+
	bne.s .lb0
	clr -(sp)
	lea full2,a0
	move.l a0,_dialogue+8
	pea (a0)
	GEMDOS 61,8							; fopen with MOV file
	move d0,mov_h						; handle of the file is saved
	bpl.s .short_name
	clr -(sp)			; essaye FULL si le nom DTA a plant‚...
	lea full,a0
	move.l a0,_dialogue+8
	pea (a0)
	GEMDOS 61,8
	move d0,mov_h
	bmi skip_long_mask
.short_name:


	; ******************* sets some datas to 0 ******************************

	bsr zero_variables

	move.l #yamaha_dum,yamaha_ptr
	
	bsr.l test_enhanced		; is there a *.ENH file present? And verify that is has the
								; correct header! and compile it
	

	; ******************* verifies the QT MOV format ************************

	bsr qt_parse_bin
	beq is_mov						; yes, it's a QT MOV file

	; ******************* supposes that it's an AVI file ********************

	bsr avi_parse_bin						; verifies header and gets blocs addresses
	beq is_avi

	; ******************* else, sopposes that it's a FLI ********************

	bsr fli_read_header
	beq is_fli

	; ******************* else, supposes that it's a Batch file *************

force_bat:
	bsr.l bat_read_header
	beq is_bat

	clr.l _delay
	bsr vst_read_header	; a file from VIDI ST ??
	beq is_vst

	bsr.l mpg_read_header
	beq is_mpg

	bsr.l seq_read_header
	beq is_seq

	bsr.l kin_read_header
	beq is_kin

	bsr.l dlt_read_header
	beq is_dlt

	bsr.l flm_read_header
	beq is_flm
	bmi is_xflm

	bsr.l gif_read_header
	beq is_gif

	bsr.l mvi_read_header
	beq.s is_mvi

	bsr.l dl_read_header
	beq is_dl

	bsr.l vmas_read_header
	beq.s is_vmas

	bsr.l cd_read_header
	beq is_cd
	
	bsr.l mjpeg_parse_bin
	beq.l is_mjpeg

	; ******************* else, it's an error *******************************

	clr mf_int
	GEM_AES graf_mouse			; the arrow
	tst.b cmd_return
	beq.s .lb0
	move.l cmd_return_adr,a0
	move #-1,(a0)+		; unknown
	lea dta+30,a1
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1),(a0)+
	clr (a0)
.lb0:
	moveq #27,d0			; alert bad file format
	bra.l ooops

is_mvi:
	move.l #mvi_title,a3
	bra.s mas_mvi

is_vmas:
	move.l #vmas_title,a3
mas_mvi:
	moveq #1+4,d3		; se fier a can step
	bsr.l principal
	tst.b stopped
	bne end_of_display
	cmp.l #'mvi ',comp_txt
	beq.s .mvi
	bsr treat_saveas
	tst.b step_mode
	beq.s .no_step
	move.l _delay,d0
	lsr.l #2,d0
	move.l d0,_delay
	moveq #3,d7
	bsr.l init_step_mode
	beq end_of_display_na
.no_step:
	bsr.l init_rect
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	move.l tree_sav,a0
	btst #0,299(a0)
	bne.s .sync
	clr.l _delay
.sync:
	btst #0,275(a0)
	beq.s .no_sound
	bsr.l vmas_read_sound
.no_sound:
	bsr.l set_video
	bsr.l _run_m_player
	bsr.l vmas_read_data
	bra end_of_display
.mvi:
	move.l tree_sav,a0
	btst #0,275(a0)
	beq end_of_display
	move.l snd_size,d4
	bsr.l adapt_d4_size
	move.l _freq_sav,d3
	add.l d3,d3
	add.l d3,d3
	divs.l #5,d3			; 80% of one second
	addq.l #5,d3			; plus the offset
	st mvi_flag
	bsr.l read_sound
	bsr.l mvi_read_data
	bra end_of_display

is_vst:
	move.l #vst_title,a3
	move.l #'VIDI',comp_txt
	st bad_comp
	bra.s ks_com

is_dl:
	move.l #dl_title,a3
	moveq #-4,d3
	bra.s _ks_com

is_flm:
	move.l #flm_title,a3
	moveq #-4,d3
	bra.s _ks_com

is_dlt:
	move.l #dlt_title,a3
	bra.s ks_com

is_kin:
	move.l #kin_title,a3
	bra.s ks_com

is_seq:
	move.l #seq_title,a3

ks_com:
	moveq #0,d3
_ks_com:
	bpl.s .posit
	st group_step
	neg.l d3
.posit:
	bsr.l principal
	bsr remet_play_sound
	bne end_of_display	; cancel button
	btst #0,299(a0)
	bne.s .lb4
	clr.l _delay			; no delay if max_speed set!
.lb4:
	tst.b group_step
	beq.s .no_step2
	bsr treat_saveas
.no_step:
	tst.b step_mode
	beq.s .no_step2
	moveq #-1,d7
	bsr.l init_step_mode
	beq end_of_display_na
.no_step2:
	bsr.l init_rect
	move.l comp_txt,d1
	cmp.l #'seq4',d1
	bne.s .other
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	move.l #32000,d1
	bsr.l malloc
	move.l d0,s_buffer
	move.l #64000,d1
	bsr.l malloc
	move.l d0,s_buffer_2
	bsr.l set_video
	bsr.l seq_read_data
.lb3:
	bra end_of_display
.other:
	cmp.l #'kin4',d1
	bne.s .other2
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	bsr.l set_video
	bsr.l kin_read_data
	bra end_of_display
.other2:
	cmp.l #'dlt4',d1
	bne.s .other3
	move.l physbase,buffer
	tst.b is_tt
	bne.s .tt_dlt
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
.tt_dlt:
	bsr.l set_video
	bsr.l dlt_read_data
	tst.b is_tt
	beq end_of_display
	clr.l buffer			; it was not allocated (the real screen)
	bra end_of_display
.other3:
	cmp.l #'VIDI',d1
	beq end_of_display		; n'est pas rejou‚ tel quel
	move.b #'0',d1
	cmp.l #'flm0',d1
	bne.s .other4
	tst.b bad_comp
	bne end_of_display		; unsupported resolution
	move.l physbase,s_buffer
	tst.b is_tt
	bne.s .tt_flm				; TT without NOVA
	move.l tt_screen_size,d1
	bsr.l malloc
	move.l d0,s_buffer
.tt_flm:
	move.l tt_flag_size,d1
	bsr.l malloc
	move.l d0,s_buffer_2		; flags for words that changed
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	bsr.l set_video
	bsr.l flm_read_data
	bra end_of_display
.other4:
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer			; all the screens!
	move.l sample_num,d1
	add.l d1,d1					; number of words
	bsr.l malloc
	move.l d0,s_buffer		; pointers to the images
	bsr.l load_dl_palette
	bsr.l load_dl_screens		; loads and converts 8bits to planes if TT
	bsr.l dl_frame_table
	bsr.l set_video
	lea cvid_fix1,a0			; the palette
	cmp #16,planes
	bne.s .not_tc
	lea cvid_fix0,a6
	bsr fli_color_64
	bra.s .dl_common
.not_tc:
	bsr fli_color_64_256
.dl_common:
	bsr.l _run_m_player
	bsr.l dl_read_data
	bra end_of_display


hide_mouse: dc.l hm_cont,dum,dum,dum,dum

remet_play_sound:
	move.l tree_sav,a0
	move.l play_sav,324(a0)
	move.l sync_sav,348(a0)
	bclr #4,273(a0)
	bclr #4,297(a0)		; clears the radio flags
	tst.b stopped
	rts

is_xflm:
	move.l #xflm_title,a3
	moveq #1+4,d3
	bsr.l principal
	tst.b stopped
	bne end_of_display
	bsr treat_saveas
	btst #0,299(a0)
	sne sync
	tst.b step_mode
	beq.s .lb4a
	moveq #4,d7
	bsr.l init_step_mode
	beq end_of_display_na
.lb4a:
	bsr.l init_rect
	move.l physbase,s_buffer
	tst is_tt
	bne.s .tt_flm
	move.l tt_screen_size,d1
	bsr.l malloc
	move.l d0,s_buffer
.tt_flm:
	move.l tt_flag_size,d1
	bsr.l malloc
	move.l d0,s_buffer_2		; flags for words that changed
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	tst.b step_mode
	bne.s .lb4b
	bsr flm_read_sound
.lb4b:
	bsr.l set_video
	bsr.l flm_read_data
	bra end_of_display


hm_cont: dc.w 123,0,0,0,0,0,0,0,0,0,0,0

cd_nul: rts

is_cd:
	move.l #cd_title,a3
	moveq #1,d3
	bsr.l principal
	tst.b stopped
	bne end_of_display
	move.l tree_sav,a0
	cmp.l #'CDA1',comp_txt
	beq .sound_file
	tst.b bad_comp
	bne.s .no_graph
	btst #0,299(a0)
	sne sync
	bsr.l init_rect
	move.l max_fsize,d1
	addq.l #8,d1
	addq.l #8,d1
	bsr.l malloc
	move.l d0,buffer
	addq.l #8,d0
	addq.l #7,d0
	and.w #$FFF0,d0
	move.l d0,buffer_16
.no_graph:
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .no_sound
	bsr.l cd_read_sound
.no_sound:
	tst.b bad_comp
	bne.s .lb4
	bsr.l set_video
	cmp.l #'CDL1',comp_txt
	bne.s .lb3
	bsr.l grey_mov
.lb3:
	cmp.l #'CDV1',comp_txt
	bne.s .lb4
	move.l #cvid_fix1,a0
	cmp #16,planes
	bne.s .lb5
	move.l #cvid_fix0,a6
	bsr fli_color_256
	bra.s .lb4
.lb5:
	bsr fli_color_256_256
.lb4:
	bsr.l cd_read_data
	bra end_of_display
.sound_file:
	btst #0,275(a0)
	beq end_of_display
	move.l total,d0
	sub.l sound_seek,d0
	move.l d0,snd_size
	bsr.l cd_read_sound
	bsr.l cd_play_sound
	bra end_of_display

is_gif:
	move.l #gif_title,a3
	moveq #0+4,d3
	bra.s gm_comm

is_mpg:
	bsr.l decide_count_mpg
	tst.b d7
	beq.s .dont_count
	moveq #2,d0
	bsr.l general_info
.dont_count:	
	move d7,-(sp)
	bsr mpg_parse_bin
	move (sp)+,d7
	beq.s .dont_count2
	bsr.l general_info_off
.dont_count2:
	sf bad_comp
	move.l #mpg_title,a3
	moveq #0+4+8,d3
gm_comm:
	bsr.l principal
	cmp #'mp',comp_txt
	bne .lb3
	bsr remet_play_sound
	bne end_of_display
	bsr treat_saveas
	move.l tree_sav,a0
	moveq #3,d0				; Output_Type
	btst #0,299(a0)		; propre?
	bne.s .aff_propre
	moveq #1,d0
.aff_propre:
	btst #0,515(a0)				; grey mode?
	beq.s .aff_couleur
	and #2,d0
.aff_couleur:
	bsr adapt_mpg_size	; cherche aussi la routine d'affichage
	tst.b step_mode
	beq.s .lb4a
	tst.l sample_num
	bne.s .ok
	tst.b mpeg_info_flag		; yet displayed once?
	bne.s .ok
	tst.b warnings				; if off, skip
	beq.s .ok
	st mpeg_info_flag
	moveq #4,d0					; mpeg_info
	bsr.l alert
	cmp #1,d0
	beq end_of_display_na	; user wants to compute number of frames	
.ok:
	moveq #-3,d7
	bsr.l init_step_mode
	beq end_of_display_na
.lb4a:
	bsr.l init_rect
	bsr.l set_video
	lea compression,a1
	move.l (a1),d0
	move planes,d1
	lea mpg_aff_tab,a0
	cmp #8,d1
	bne.s .normal
	bclr #0,Output_Type
	tst.b is_tt
	beq.s .pas_tt
	lea 36(a0),a0			; passe aux routines TT
	bra.s .normal
.pas_tt:
	divs #3,d0
	muls #3,d0
	addq #2,d0
.normal:
	move.l 0(a0,d0.l*4),(a1)
	cmp #16,d1
	bne.s .fast
	tst.b fast_mode
	beq.s .col
.fast:
	tst.b is_tt
	bne.s .hard_col
	move #8,grey_depth
	move.l #'INVE',d0
	bsr.l grey_mov
	bra.s .col
.hard_col:
	bsr.l set_colors
.col:
	bsr.l _run_m_player
	bsr mpg_read_data
	bra end_of_display
.lb3:						; here GIF
	tst.b stopped
	bne end_of_display
	move.l tree_sav,a0
	moveq #0,d0			; no delay (default)
	btst #0,299(a0)
	beq.s .no_del
	moveq #-1,d0
.no_del:
	move.l d0,_delay	; -1 if delay accepted, 0 if no delay wanted...
;	beq.s .no_step2	; ???
	bsr treat_saveas
.no_step:
	move.l total,d1
	addq.l #2,d1		; 0 plus $3B
	bsr.l malloc
	move.l d0,buffer
	tst.b step_mode
	beq.s .no_step2
	moveq #-2,d7
	bsr.l init_step_mode
	beq end_of_display_na
.no_step2:
	bsr.l init_rect
	move.l #4*4096,d1
	moveq #0,d0
	move max_imagex,d0
	add.l d0,d1
	bsr.l malloc
	move.l d0,hc_cvid	; bloc for the LZW codes, plus one line
	bsr.l set_video		; other mallocs possible
	bsr.l _run_m_player
	bsr.l gif_read_data
	bra end_of_display

; d0=Output_type
adapt_mpg_size:
	moveq #0,d5				; num‚ro de routine dans le tableau
	move max_imagex,d1
	move max_imagey,d2
	tst.b is_tt
	bne.s .un_tt
	btst #1,d0
	beq.s .reduit4
	move.l work_out,d3
	move d3,d4				; screenh
	swap d3					; screenw
	addq #1,d4
	addq #1,d3
	cmp d1,d3
	bmi.s .reduit2
	cmp d2,d4
	bpl.s .fin
.reduit2:
	addq.l #3,d5
	lsr #1,d1
	lsr #1,d2
	bra.s .sauve
.reduit4:
	addq.l #6,d5
	lsr #2,d1
	lsr #2,d2
.sauve:
	move d1,max_imagex
	move d2,max_imagey
.fin:
	btst #0,d0
	bne.s .couleur
	addq.l #1,d5
.couleur:
	move.l d5,compression
	lea adresse_retour,a0
	move.l #(fin_mpg_var-adresse_retour)/4-1,d2
	moveq #0,d1
.erase:
	move.l d1,(a0)+
	dbf d2,.erase
	move.b d0,Output_Type
	rts
.un_tt:
	btst #1,d0
	beq.s .dirty
	cmp #321,d1
	bpl.s .pb
	cmp #241,d2
	bmi.s .fin_tt
.pb:		; ici plus de 320x240
	move d1,d4
	muls #3,d1	; 3X
	swap d4
	move d2,d4
	lsl #2,d2	; 4Y
	cmp d2,d1
	bmi.s .aligne_hauteur
	muls #480,d2	; ici on aligne en largeur
	divs d1,d2		; d2 = nouvelle hauteur
	move.l d2,d6
	swap d6
	move #320,d1
	tst d6
	beq.s .pile
	addq #1,d2		; arrondi au dessus par s‚curit‚
	bra.s .pile
.aligne_hauteur:
	muls #320,d1
	divs d2,d1
	move.l d1,d6
	swap d6
	move #480,d2
	tst d6
	beq.s .pile
	addq #1,d1
.pile:
	moveq #2,d5		; num‚ro de routine
	cmp d2,d4
	bpl.s .yreduit
	addq #2,d5
.yreduit:
	swap d4
	cmp d1,d4
	bpl.s .xreduit
	addq #1,d5
.xreduit:
	bra.s .fin_tt
.dirty:
	lsr #2,d1
	lsr #2,d2
	moveq #1,d5				; routine 1
.fin_tt:
	move d1,max_imagex
	move d2,max_imagey	; 4 fois plus petit
	cmp #2,d5
	bmi.s .areu				; routines 0 et 1 -> y va doubler
	lsr #1,d2				; sinon il reste le mˆme
.areu:
	add #15,d1
	and.l #$FFF0,d1			; align sur 16
	move d1,alignwidth
	move #-320,d3
	sub #240,d2
	add d3,d1
	muls d3,d2
	ext.l d1
	move.l physbase,a0
	asr.l #1,d1
	sub.l d1,d2
	and.b #$F0,d2				; align‚ sur 16!
	lea 0(a0,d2.l),a0			; d‚but image … l'‚cran
	move.l a0,tt_screen
	bra .couleur

mpg_aff_tab: dc.l mpg_tc_color_full,mpg_tc_grey_full,mpg_256_grey_full
	dc.l mpg_tc_color_half,mpg_tc_grey_half,mpg_256_grey_half
	dc.l mpg_tc_color_dirty,mpg_tc_grey_dirty,mpg_256_grey_dirty
	dc.l mpg_tt_normal,mpg_tt_dirty
	dc.l mpg_tt_xmoins_ymoins,mpg_tt_xplus_ymoins
	dc.l mpg_tt_xmoins_yplus,mpg_tt_xplus_yplus

bat_title: dc.b "  Batch Slide Show (BAT)  ",0
bat_title_create:
			  dc.b "  Batch Create Mov (BAT)  ",0
bat_title_gif:
			  dc.b "  Batch Create Gif (BAT)  ",0
bat_title_avi:
			  dc.b "  Batch Create Avi (BAT)  ",0
bat_title_flm:
			  dc.b "  Batch Create Flm (BAT)  ",0
bat_screen_capture:
			  dc.b "Batch Screen Capture (BAT)",0

	even
is_bat:
;	tst.b mountain
;	beq.s .lbz
;	GEM_VDI hide_mouse
;.lbz:
	tst.b cancelled
	beq.s .lb0x
	st stopped
	bra end_of_display
.lb0x:
	moveq #0,d3
	lea bat_title(pc),a3
	tst.b create_mov
	beq.s .lb0
	bmi.s .lb0a
	lea bat_title_gif(pc),a3
	moveq #2,d3					; toujours Alt Go
	bra.s .lb0
.lb0a:
	moveq #2,d3
	lea bat_title_avi(pc),a3
	tst.b create_avi
	bne.s .lb0
	lea bat_title_flm(pc),a3
	tst.b slide_degas
	bne.s .lb0
	lea bat_screen_capture,a3
	tst.b is_grab
	bne.s .lb0
	move.l #bat_title_create,a3
.lb0:
	bsr.l principal
	beq.s .lb2a
	move.l tree_sav,a0
	btst #0,539(a0)	; save as?
	bne.s .lb2b
	sf create_mov		; create mode
.lb2b:
	tst.b create_mov
	beq.s .lb2a
	move planes,planes_sav
	move #16,planes
	tst.b is_vidi
	beq.s .bon
	move #8,planes
.bon:
	tst.b bad_sound
	bne .lb3c
	bsr.l init_create
	clr.l _delay		; no synchro!
	bra.s .lb2c
.lb2a:
	tst.b slide_gif
	beq.s .lb2c
	move.l #4*4096,d1
	moveq #0,d0
	move max_imagex,d0
	add.l d0,d1
	bsr.l malloc
	move.l d0,hc_cvid	; bloc for the LZW codes, plus one line
.lb2c:
	bsr remet_play_sound
	bne end_of_display
	btst #0,275(a0)
	beq.s .lb4
	clr.l _delay			; no delay if max_speed set!
.lb4:
	bsr.l init_rect
	move.l max_fsize,d1
	add.l tgac_offset,d1	; en cas de compression
	tst.b is_vidi
	beq.s .pas_vidi
	add.l #1558,d1			; pour simuler le header XIMG
.pas_vidi:
	bsr.l malloc
	move.l d0,buffer
	add.l neo_degas_offs,d0			; for degas,neo
	move.l d0,_flm_phys	; for degas,neo (if used)
;	tst.b is_vidi
;	beq.s .pas_vidi2
;	bsr init_ximg_header
;.pas_vidi2:
	tst.b create_mov
	beq.s .lb4a
	tst.b slide_gif
	bne.s .lb3d				; no need to decompress for GIF!
	tst.b slide_degas
	bne.s .lb3d
	move max_imagex,d0
	addq #3,d0
	and.b #$FC,d0
	move d0,screenw		; 4 pixels aligned
	move max_imagey,screenh
	clr offsx
	clr offsy
	move.l one_buffer,image
	move.l #_comp,compression
.lb3d:
	tst.b _conv_video
	beq.s .lb3a
	st switched
	bsr.l sv_falcon		; au cas ou M_PLAYER fils doit changer RES
	bra.s .lb3a
.lb4a:
	bsr.l set_video			; clears screen and switch to TC
	cmp #8,planes
	bne.s .lb3a
	bsr.l set_colors		; the 256 grey colors
.lb3a:
	bsr.l bat_read_data
	tst.b create_mov
	beq end_of_display	; no creatio, exit
	tst.b stopped
	bne end_of_display	; stopped or error, exit
	bsr.l save_header		; else terminates file.
.lb3c:
	move planes_sav,planes
;	tst.b mountain
;	beq end_of_display
;	GEM_VDI show_mouse
	bra end_of_display					; the common end for QT and AVI and FLI

init_ximg_header:
	move.l buffer,a0
	add.l tgac_offset,a0
	lea .header(pc),a1
	move max_imagex,12(a1)
	move max_imagey,14(a1)
	moveq #28,d0
.copy_head:
	move.l (a1)+,(a0)+
	dbf d0,.copy_head
	move (a1),(a0)+
	moveq #89,d0
	moveq #0,d1
.clear_pal:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d0,.clear_pal
	rts
.header: INCBIN "XIMGHEAD.BIN"
bat_timing:
	dc.l 200
	dc.l _ximg_

init_degas_header:
	move.l buffer,a0
	add.l tgac_offset,a0
	lea .header(pc),a1
	moveq #3,d0
.copy_head:
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	dbf d0,.copy_head
	move (a1),(a0)+
	rts
.header: INCBIN "DEGAHEAD.BIN"

is_fli:
	move.l #fli_title,a3
	moveq #0+4,d3
	bsr.l principal
	beq.s .no_step
	bsr treat_saveas
.no_step:
	bsr remet_play_sound
	bne end_of_display	; cancel button
	btst #0,299(a0)
	bne.s .lb4
	clr.l _delay			; no delay if max_speed set!
.lb4:
	tst.b step_mode
	beq.s .aaa
	moveq #0,d7
	bsr.l init_step_mode
	beq end_of_display_na
.aaa:
	bsr.l init_rect
	move.l max_fsize,d1
	bsr.l malloc
	move.l d0,buffer
	bsr.l set_video			; clears screen and switch to TC
	cmp #8,planes
	bne.s .lb3
	cmp.l #'flh ',comp_txt
	bne.s .lb3a
	bsr.l set_colors			; flh is TC, so grey display in 256 colors
.lb3a:
	bsr fli_read_data_256
	bra end_of_display
.lb3:
	bsr.l _run_m_player
	bsr fli_read_data
	bra end_of_display					; the common end for QT and AVI and FLI

treat_control:
	btst #2,([kbshift])
	beq.s .fin
	move #7,-(sp)
	move #2,-(sp)
	BIOS 3,6				; cloche!
	move.l #$00020002,-(sp)
	trap #13
	addq.l #4,sp		; lit un caractere
	sub.b #'0',d0
	bls.s .fin			; 0 ou moins refus‚
	cmp.b #10,d0
	bpl.s .fin			; 10 ou plus refus‚
	move.b d0,iv32_freq
.fin:
	rts

treat_saveas:
	move.l tree_sav,a0
	btst #0,539(a0)		; save as?
	sne step_mode			; set flag
	tst.b bad_card
	bne.s .monodisplay	; if bad card, act like step mode in mono
	tst.b step_mode
	beq .out					; no step mode wanted, so exit
	sf enh_flag				; no enhanced file with step mode
	tst.b can_step			; natural step?
;	bra.s .monodisplay	; for debug
	beq.s .monodisplay	; for 1-8 bits
	tst.b is_vdi
	bne .out					; nothing to do is yet in vdi mode
	moveq #16,d1
	lea TA,a0
	tst.b adapt_mode		; 00 if NOVA 32k
	beq.s .common
	lea T9,a0				; here NOVA 64k
	cmp.b #4,is_65k+1
	beq.s .common
	lea T8,a0				; here Falcon 64k
	bra.s .common	
.monodisplay:	
	lea TM,a0
	moveq #1,d1
.common:
	move.w d1,-(sp)		; number of planes for MFDB
	move.l a0,vdi_compression
	move.l #32768,d1
	bsr.l malloc
	move.l d0,a6
	move.l d0,step_vdi_sav
	st step_vdi
	bsr.l _nova_adapt
	bsr.l _gen_16_to_grey
	lea step_vdi_sav+4,a0
	move is_65k,(a0)+
	move #3,is_65k					; in mode3 = 32768 colors
	move planes_vdi,(a0)+
	move (sp)+,planes_vdi			; mode monochrome ou 16 bits
	move.b is_vdi,(a0)+
	st is_vdi						; and VDI mode on !!
	move.b nova,(a0)+
	st nova							; and force NOVA
	move.l ed_adr,(a0)+
	clr.l ed_adr					; no vdi extension requiered
	move planes,(a0)+
	moveq #16,d0
	move d0,planes
	move.b is_tt,(a0)+
	sf is_tt
	move.l step_compression,compression
.out:
	rts

treat_saveas_end:
	sf step_vdi
	FREE step_vdi_sav
	lea step_vdi_sav+4,a0
	move (a0)+,is_65k
	move (a0)+,planes_vdi
	move.b (a0)+,is_vdi
	move.b (a0)+,nova
	move.l (a0)+,ed_adr
	move (a0)+,planes
	move.b (a0)+,is_tt
	tst.b adapt_mode
	beq.s .nova
	bmi.s .falcon
	bsr.l adapt_256
	rts
.nova:
	bsr.l nova_adapt
	rts
.falcon:
	bsr.l falcon_adapt
	rts

is_avi:
	bsr avi_parse_chunks					; reads the header and 'idx1' bloc
	move.l #avi_title,a3
	moveq #1+4+16,d3
	move.l #'rawa',s_signe	; AVI sounds are supposed to be unsigned
	bsr.l principal
	beq end_of_display
	tst.b bad_comp
	bne.s .lb6			; no graphics
	bsr treat_control
	bsr treat_saveas
;.no_step:
	tst.b no_idx1
	beq.s .suite
	bsr avi_build_table	; pas de table, il faut la construire!!
.suite:
	tst.b step_mode
	beq.s .lb4a
	moveq #1,d7
	bsr.l init_step_mode
	beq end_of_display_na
.lb4a:
	bsr.l init_rect
	move.l max_fsize,d1
	add.l mjpg_offset,d1
	bsr.l malloc
	move.l d0,buffer
.lb6:
	bsr load_whole_file	; is "from RAM" selected?
	tst.b step_mode
	bne.s .lb4b			; no sound needed
	tst.b bad_sound	; bad sound, don't treat
	bne.s .lb4
	tst.l sound_num	; no sound anyway
	beq.s .lb4
	move.l snd_temp_size,d3
	move.l snd_size,d4
	bsr.l adapt_d4_size	; and eventually D3 if ima4!!!
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .lb4
	bsr.l read_sound
.lb4:
	bsr avi_sync_tab
.lb4b:
	bsr.l set_video
	move.l mapused,d0
	lea cvid_fix1,a0
	cmp #8,planes
	bne.s .lb9
	tst.l d0
	beq.s .lb8
	bsr fli_color_256_256	; the palette into VDI registers
	bra.s .lb3
.lb8:
	bsr.l set_colors
	bra.s .lb3
.lb9:
	tst.l d0
	beq.s .lb3
	lea cvid_fix0,a6
	bsr fli_color_256			; the palette into a table
.lb3:
	bsr.l _run_m_player
	bsr.l load_jpg_rim			; eventually...
	bsr avi_read_data

	bra end_of_display					; the common end for QT and AVI

load_whole_file:
	move.l tree_sav,a0
	btst #0,611(a0)		; From RAM
	sne from_ram
	bne.s .suite
	rts						; nothing to do
.suite:
	FREE buffer				; not needed
	move.l total,d1
	bsr.l malloc
	move.l d0,whole_file
	movem.l a3-a6/d2-d7,-(sp)
	moveq #1,d0
	bsr.l general_info	; display "loading into ram"
	SEEK #0,0			; start
	move.l whole_file,-(sp)
	move.l total,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the file
	bsr.l general_info_off		; remove box
	movem.l (sp)+,a3-a6/d2-d7
	rts

v_bar: dc.l vb_cont,dum,bar_pts,dum,dum
vb_cont: dc.w 11,2,0,0,0,1,0,0,0,0,0,0

; here, treats the case of a QT MOV file

is_mov:

	; *************** read infos to prepare decrunch **********************
	move.l #id_table,id_ptr			; list of IDs (CVID, etc...)
	bsr qt_parse_chunks				; reads the frames info and fills some
											; arrays
	lea id_table,a0
	move.l (a0)+,comp_txt		; back to the first ID
	move.b (a0),qt_palette

	move.l #qt_title,a3	; the type of file
	tst.b vr_flag
	beq.s .lb0
	move.l #vr_title,a3
.lb0:
	moveq #1+4+16,d3
	bsr.l principal
	beq end_of_display
	bra im_lb2			; no, so it's the 'Go!' button


show_mouse: dc.l sm_cont,sm_int,dum,dum,dum

flm_read_sound:
	sf playing
	move.l tree_sav,a0
	btst #0,275(a0)
	beq .end				; no Play sound wanted
	tst.b bad_sound
	bne .end				; bad sound any_way
	tst.l frequency
	beq .end				; no sound!
	move.l flm_snd_size,d7
	clr -(sp)				; ST ram only
	move.l d7,-(sp)
	GEMDOS $44,8			; mxalloc
	tst.l d0
	bmi.s .end				; alloc error
	beq.s .end
	move.l d0,snd_temp
	move.l d0,d6
	bsr.l init_loading_sound
	movem.l d6-d7,-(sp)
	moveq #1,d6
	moveq #1,d7
	bsr.l manage_tree
	movem.l (sp)+,d6-d7
	SEEK flm_snd_pos,0
	move.l d6,d0
	add.l d7,d0
	move.l d0,flm_snd_end
	move.l d6,-(sp)
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the whole sound into memory
	tst.b snd_value
	bmi.s .dma
	bsr.s adapt_sound
.dma:
	moveq #1,d6
	moveq #-1,d7
	bsr.l manage_tree
	st playing
.end:
	rts

sm_cont: dc.w 122,0,0,1,0,0,0,0,0,0,0,0
sm_int: dc.w 0

; DMA sound to Yamaha emulation 9,6KHz or soudn card
; converts to 8 bits mono (even with stereo samples)

adapt_sound:
	move.l d6,a0			; start adress
	move.l d6,a1			; other start adress
	move channels,d1
	move.l frequency,d0
	cmp.w #12517,d0
	bne.s .other
	cmp #2,d1
	beq .stereo12
	bra.s .l1
.loop:
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	addq.l #1,a0
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	move.b (a0)+,(a1)+
	addq.l #1,a0
.l1:
	subq.l #8,d7
	subq.l #1,d7
	bpl.s .loop
.no_zero:
	move.l d6,a0
	moveq #1,d0
.nz:
	tst.b (a0)+
	bne.s .nz2
	move.b d0,-1(a0)	; 0 replaced by 1
.nz2:
	cmp.l a1,a0
	bmi.s .nz
	clr.b (a0)			; end with a zero!!!
	rts
.other:
	cmp.w #25033,d0
	bne.s .last
	cmp #2,d1
	beq .stereo25
	bra.s .l2
.loop2:
	move.l (a0)+,d0
	swap d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	move.l (a0)+,d0
	swap d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	move.l (a0)+,d0
	move.b d0,(a1)+
	move.l (a0)+,d0
	swap d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	addq.l #2,a0
.l2:
	sub.l #18,d7
	bpl.s .loop2
	bra.s .no_zero
.last:
	cmp #2,d1
	beq .stereo50
	bra.s .l3
.loop3:
	rept 4
	move.l (a0)+,d0
	move.b d0,(a1)+
	endr
	addq.l #4,a0
	rept 3
	move.l (a0)+,d0
	move.b d0,(a1)+
	endr
	addq.l #4,a0
.l3:
	sub.l #36,d7
	bpl.s .loop3
	bra .no_zero
.stereo12:
	bra.s .s12l4
.s12again:
	move #$7b80,d0
	moveq #8,d1
.s12l0:
	add d0,d0
	bpl.s .s12l1
	move.b (a0)+,d2
	add.b (a0)+,d2
	asr.b #1,d2
	bne.s .s12l2
	moveq #1,d2	
.s12l2:
	move.b d2,(a1)+
	bra.s .s12l3
.s12l1:
	addq.l #2,a0
.s12l3:
	dbf d1,.s12l0
.s12l4
	sub.l #18,d7
	bpl.s .s12again
	rts
.stereo25:
	bra.s .s25l4
.s25again:
	move #$7b80,d0
	moveq #8,d1
.s25l0:
	add d0,d0
	bpl.s .s25l1
	move.b 1(a0),d2
	add.b 3(a0),d2
	asr.b #1,d2
	bne.s .s25l2
	moveq #1,d2	
.s25l2:
	move.b d2,(a1)+
.s25l1:
	addq.l #4,a0
	dbf d1,.s25l0
.s25l4:
	sub.l #36,d7
	bpl.s .s25again
	rts
.stereo50:
	bra.s .s50l4
.s50again:
	move #$7b80,d0
	moveq #8,d1
.s50l0:
	add d0,d0
	bpl.s .s50l1
	move.b 1(a0),d2
	add.b 3(a0),d2
	asr.b #1,d2
	bne.s .s50l2
	moveq #1,d2	
.s50l2:
	move.b d2,(a1)+
.s50l1:
	addq.l #8,a0
	dbf d1,.s50l0
.s50l4:
	sub.l #72,d7
	bpl.s .s50again
	rts

im_lb2:
	bsr treat_control
	bsr treat_saveas
.no_step:
	bsr.l treat_vr_box
	cmp #12,d6
	beq end_of_display
	tst.b step_mode
	beq.s .kk2
	moveq #2,d7
	bsr.l init_step_mode
	beq end_of_display_na
.kk2:
	move.l samp_sizes,a0
	cmp.l #0,a0
	beq no_graph
	move.l sample_num,d1
	moveq #0,d0					; computes the max size of a sample
lb4:
	tst.l d1
	beq.s lb5
	subq.l #1,d1
	move.l (a0)+,d2			; a size
	cmp.l d2,d0					; size > max size?
	bpl.s lb4
	move.l d2,d0				; yes, so it's a new max size
	bra.s lb4


graf_mouse: dc.l mf_cont,global,mf_int,intout,mouse_def,dum
mf_cont: dc.w 78,1,1,1,0
mf_int: dc.w 0
mouse_def: dc.l 0


lb5:
	move.l d0,max_fsize		; keeps the max size
	move.l d0,d1
	add.l mjpg_offset,d1
	bsr.l malloc					; and allocates the buffer
	move.l d0,buffer			; the address
	bsr load_whole_file	; is "from RAM" selected?


	bsr.l init_rect		; the movie rectangle, the screen adr, etc...
	bra.s kkk


appl_exit: dc.l ae_cont,global,dum,intout,dum,dum
ae_cont: dc.w 19,0,1,0,0


no_graph:
;	GEM_VDI hide_mouse
kkk:
	tst.b step_mode
	bne.s .kk3
	bsr.l init_sound
.kk3:
	tst.b vr2_flag
	beq.s .no_more_buffers
	bsr alloc_vr2_buf
.no_more_buffers:
	bsr.l set_video
	tst.b qt_palette
	beq.s .lb0
	tst.b is_grey
	beq.s .color
	bsr.l grey_mov
	bra.s .lb3
.color:
	move.l pal_adr,a0
	cmp #8,planes
	bne.s .zzz
	bsr fli_color_256_256
	bra.s .lb3
.zzz:
	lea cvid_fix0,a6
	bsr fli_color_256
	bra.s .lb3
.lb0:
	cmp #8,planes
	bne.s .lb3
	bsr.l set_colors		; the 256 grey colors
.lb3:
	bsr.l _run_m_player
	bsr.l load_jpg_rim		; eventually...
	bsr qt_read_data	; reads and displays the QT MOV file
	bra.s end_of_display
	
end_of_display_na:
	sf last_alert
	bra.s _eod_comm

end_of_display:
	st last_alert
_eod_comm:
;	tst.b mountain
;	beq.s .tagada
;	illegal
;.tagada:
	tst.b create_mov
	bne.s .no_vdi
	tst.b is_vdi
	beq.s .no_vdi
;	FREE physbase
	FREE old_screen
	move.l physbase,old_screen
	FREE vdi_buffer
	tst.b step_vdi
	beq.s .no_vdi
	bsr treat_saveas_end

.no_vdi:
	tst.b is_win
	beq.s .lb20
	GEM_AES wind_close
	GEM_AES wind_delete
	bra.s .lb5

.lb20:
	tst.b switched
	beq.s .lb2

	bsr.l restore_video
	GEM_VDI vq_extnd		; fills again work_out
	move planes_sav,planes

.lb2:
	tst.b slide_flag
	bne.s .lb5
	move #3,fd_int
	GEM_AES form_dial		; screen updates
.lb5:
	sf display
	clr mf_int
	GEM_AES graf_mouse		; back to the arrow

;	bsr.l redraw

	cmp #16,planes
	bpl.s .lb4
	bsr.l restore_256		; back to the desktop colors

.lb4:
	bsr.l redraw_menu
	bsr.l winup_clear
	GEM_VDI show_mouse
	tst.b stopped
	bne.s .lb0				; stopped, no general stats displayed
	tst.l samp_sizes
	beq.s .lb0				; no graphics, so no stats about graphics...
	tst.b bad_comp			; graphics played?
	bne.s .lb0				; no, because of the bad_compresion
	tst.b step_mode		; step mode?
	bne.s .lb0				; yes, no time stats

	bsr.l fill_stat		; renvoit dans D6 le bon arbre (3 ou 9)
	moveq #0,d7
	bsr.l manage_tree
	st stopped				; if stat box, don't show alert 'Everything is Ok'

.lb0:
	tst.b slide_flag
	bne.s end
;	GEM_VDI show_mouse	; the mouse is back

	tst.b command			; with a command line, no alert boxes
	bne.s end
	tst.b stopped			; if movie stopped (Control key), not that box
	bne.s end

	tst.b last_alert		; in some cases of "cancel"
	beq.s end
	tst.b warnings
	beq.s end				; skip warnings
	moveq #31,d0					; alert tells that everything is OK
	bsr.l alert

	; *************** closes the file and restarts ************************
	; *************** frees memory too ************************************
end:
	FREE enh_buffer
	FREE mjpg_buffer
	FREE vr2_temp
	FREE hc_cvid
	FREE codecs
	FREE samp_sizes
	FREE t2samps
	FREE s2chunks
	FREE chunkoffs
	FREE sound_offs
	FREE ss_tab
	tst.l whole_file
	beq.s .lb0
	FREE whole_file
	clr.l buffer
.lb0:
	FREE buffer
	FREE s_buffer
	FREE s_buffer_2
	FREE snd_temp
	FREE top_lines_buff
	FREE tga_buff
	FREE tga10_buff
	FREE slide_zone
	FREE bat_text
	FREE one_buffer
	FREE two_buffer
	FREE rle16_buffer
	FREE header_buffer
	FREE flm_screen
	FREE flm_frame
	bsr.l exit_menu
	FREE menu_buffer


	tst.b is_tt
	beq.s .lb3
	FREE image
.lb3:


	tst mov_h2
	beq.s .no_create
	move mov_h2,-(sp)
	GEMDOS 62,4							; closes created file
	clr mov_h2
.no_create:
	tst.b conv_flag
	bne.s .nobox						; if conv, then child has closed file
	tst mov_h
	bmi.s .nobox							; if <0, no file opened
	move mov_h,-(sp)					; else, a file is opened
	GEMDOS 62,4							; so, we need an fclose
.nobox:
	move #-1,mov_h						; in case of conv
;	bsr.l exit_menu

	tst.b inter_flag
	bne.s end_end						; stopped by an interruption
skip_long_mask:
	tst.b mountain
	bne.s end_end
	tst.b cmd_dial
	bne.s .lb00
	tst.b menu_flag
	bpl general_menu					; if other than load & read, then back to Menu
.lb00:
	pea dta
	GEMDOS 26,6							; fixes my own DTA
	GEMDOS 79,2							; search next
	tst.l d0
	beq next_file

	tst.b command
	beq again							; if no command line, go to the fileselector
											; else, this is the end!
	tst.b slide_flag
	beq.s .lb0
	bra.l slide_next_file
.lb0:

	tst.b cmd_dial
	bne.s end_end
	tst.b cmd_inter
	bne verify

end_end:
	lea _pile,sp			; au cas ou, quand on sort d'une routine JSR
	tst.b cmd_dial
	bne.s .lb0
	tst.b cmd_inter
	beq.s .lb0
	bsr.l restore_vectors
	tst.b inter_flag
	beq.s .lb0
	bclr #2,([kbshift])				; we simulated Control, so clear it
.lb0:
	bsr.l winup_clear

.lb2:
	GEM_VDI close_work				; byebye VDI

	tst.b acc
	beq.s .lb1							; not an acc, exit!

	move.l menu_buffer,a2
	bsr.l mfree							; frees the buffer
	bra acc_wait						; if an accessory, back to the loop

.lb1:
	GEM_AES rsrc_free
	GEM_AES appl_exit					; a hand-shaking to AES
	GEMDOS 0,2							; a kiss for GEMDOS

menu_bar: dc.l mb_cont,global,mb_int,dum,menu_tree,dum
mb_cont: dc.w 30,1,1,1,0
mb_int: dc.w 0

	; here, nothing can occur...

alloc_vr2_buf:
	move max_imagex,d0
	muls max_imagey,d0
	cmp #16,planes
	bne.s .lb0
	add.l d0,d0			; 2bytes/pixel
.lb0:
	move.l vr2_data+14,d1	; img/panneau
	move.l vr2_num,d2
	muls d1,d2					; total images
	move.l d2,sample_num
	muls.l d0,d1				; gros buffer circulaire
	move.l d0,d4				; saved
	add.l d0,d1					; ajoute!!!
	bsr.l malloc
	move.l d0,vr2_temp		; une image
	add.l d4,d0
	move.l d0,vr2_panneau 	; le 360ø
	tst.b is_tt
	beq.s .pas_tt
	move.l image,vr2_image
	clr offsy
	clr offsx
	move alignwidth,screenw
	move vr2_y+2,screenh
	bra.s .common
.pas_tt:
	move.l physbase,a0
	move screenh,d0
	sub vr2_y+2,d0
	lsr #1,d0
	move d0,offsy
	move screenw,d1
	muls d1,d0
	sub vr2_x+2,d1
	lsr #1,d1
	ext.l d1
	move.l d1,offsx
	add.l d1,d0
	add.l d0,a0
	cmp #8,planes
	beq.s .ok
	add.l d0,a0
.ok:
	move.l a0,vr2_image
.common:
	movem.l vr2_data+6,d0/d1
	movem.l vr2_x,d2/d3
	exg.l d0,d1
	cmp #360,vr2_data	; angle horizontal
	seq vr_xloop
	sf vr_yloop
	tst.b vr_xloop		; pour l'instant
	bne.s .ok2
	sub.l d2,d0
.ok2:
	sub.l d3,d1
	movem.l d0/d1,vr2_maxx
	lsr.l #1,d1
	lsr.l #1,d0
	movem.l d0/d1,vr2_sx
	rts

vst_read_header:
	SEEK #0,0
	bsr.l read_id_len
	cmp.l #'VIDI',d0
	beq.s .ok
.erreur:
	moveq #-1,d0
	rts
.ok:
;	move.l d0,comp_txt
	pea intout				; as a temporary buffer
	move.l d1,-(sp)		; header len
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	tst.l d0
	bmi.s .erreur
	lea intout,a0
	tst.b is_vidi
	bgt.s .degas			; si is_vidi=1, 320x200 forc‚
	move (a0),max_imagex
	move 2(a0),max_imagey
.degas:
	addq.l #6,a0
	move.l (a0)+,max_fsize
	moveq #0,d0
	move.w (a0)+,d0
	move.l d0,sample_num
	tst.l _delay			; si temps d‚j… sp‚cifi‚ (dans BAT par exemple)
	bne.s .pas_prendre	; alors ne pas prendre celui du fichier
	move.l (a0)+,_delay
.pas_prendre:
	st samp_sizes
	moveq #0,d0
	rts

fli_read_header:
	SEEK #0,0				; start of file
	pea intout				; as a temporary buffer
	move.l #128,-(sp)		; header len
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	tst.l d0
	bpl.s .lb0
.false:
	moveq #1,d0
	rts
.lb0:
	lea intout,a0
	move.l (a0)+,d0		; len of file
	INTEL d0					; they were drinking whiskey while building the 8088
	move.l d0,d1
	sub.l total,d1			; difference between two sizes
	bpl.s .plus
	neg.l d1
.plus:
	lsr.l #8,d0
	lsr.l #1,d0				; 1/512 of the size
	cmp.l d0,d1
	bpl.s .false			; difference is too high
	moveq #1,d7				; one pixel=one byte (fli,flc)
	move (a0)+,d0
	move 10(a0),d1			; time
	ror #8,d1
	cmp #$12af,d0
	bne.s .lb1
	move.l #'flc ',d0
.lb1a:
	ext.l d1					; milliseconds per frame
	divs #5,d1				; 1/200
	ext.l d1
	bne.s .lb2				; ok
	moveq #14,d1			; if 0, 14/200 gives 14 frames per second
	bra.s .lb2
.lb1:
	cmp #$44af,d0
	bne.s .lb1b
	move.l #'flh ',d0
	moveq #2,d7				; one pixel=2bytes
	bra.s .lb1a
.lb1b:
	cmp #$11af,d0		; magic
	bne.s .false
	move.l #'fli ',d0
	muls #731,d1
	lsr.l #8,d1				; number of 1/200
	bne.s .lb2				; ok
	moveq #14,d1			; if 0, default value
.lb2:
	move.l d1,_delay		; for one frame
	move.l d0,comp_txt
	moveq #0,d0
	move (a0)+,d0			; number of frames
	ror #8,d0
	move.l d0,sample_num
	move (a0)+,d0
	ror #8,d0
	move d0,max_imagex
	move (a0)+,d1
	ror #8,d1
	move d1,max_imagey
	muls d7,d1				; x1 (fli,flc) or x2 (flh)
	muls d0,d1				; number of pixels = max number of bytes per image
	add.l #1000,d1			; plus the palette (768) and others
	move.l d1,d0
	lsr.l #4,d0				; 1/16
	add.l d0,d1				; size + 6.25% (in case of bad compressor)
	move.l d1,max_fsize  ; must be enough to store one frame at the time.
	moveq #0,d0
	st samp_sizes
	rts						; returns EQ

c256 set 0

	rept 2

	if c256=1
fli_read_data_256:
	addq.l #8,compression	; skips the start of routine
	addq.l #8,compression
	else
fli_read_data:
	tst.b step_mode
	bne.l fli_step_mode
	endif
	tst.b bad_comp
	beq.s .good
	st stopped
	rts
.good:
	bsr.l install_traps
.disp_again:
	SEEK #128,0
	clr.l disp_frame
	move.l sample_num,d7	; number of frames
	if c256=0
		lea cvid_fix0,a6		; as a buffer for the palette
	endif
	cmp.l #'flh ',comp_txt
	bne.s .palette_mode
	move.l hc_cvid,a6		; with FLH, it's a 16 bits mode
.palette_mode:
	move.l image,a5
	move.l buffer,a4
	move screenw,d3
	if c256=0
		add d3,d3				; to skip one line
	endif
	trap #10
	move.l d0,start_time
	move.l d0,current_time
	bra.s .little_header
.loop:
	addq.l #1,disp_frame
	move.l intout,a3		; 16 bytes
	move.l (a3)+,d0
	INTEL d0					; size of the frame
	cmp #$faf1,(a3)+		; magic for a normal frame
	beq.s .normal
	subq.l #8,d0
	subq.l #8,d0
	SEEK d0,1				; else skips
.little_header:
	lea intout+4,a3
	move.l a3,-4(a3)
	pea (a3)					; as a buffer
	move.l #16,-(sp)		; the frame header
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	bra .next
.normal:
	move (a3),d6
	ror #8,d6				; number of chunks
	pea (a4)					; the buffer
	move.l d0,-(sp)		; the len to read + 16 bytes=next header
	lea -16(a4,d0.l),a0
	move.l a0,intout		; new little header
	move mov_h,-(sp)
	GEMDOS 63,12			; reads one frame
	move.l current_time,d1
.delay:
	trap #10
	cmp.l d0,d1
	bpl.s .delay
	add.l _delay,d1
	move.l d1,current_time
	move.l a4,a0			; start of the frame
	bra .ch_loop
.chunk:
	move.l (a0)+,d0
	INTEL d0					; chunk size
	lea -4(a0,d0.l),a1	; end of the chunk
	move (a0)+,d0
	ror #8,d0				; chunk ID
	cmp #12,d0				; fli_lc
	bne.s .lb0
	if c256=1
		bsr fli_lc_256
		tst.b is_tt
		beq .lb4
		bsr to_planes
		bra .lb4
	else
		bsr fli_lc
		bra.s .lb4
	endif
.lb0:
	cmp #7,d0				; flc_lc
	bne.s .lb00
	if c256=1
		bsr flc_lc_256
		tst.b is_tt
		beq .lb4
		bsr to_planes
	else
		bsr flc_lc
	endif
	bra.s .lb4
.lb00:
	cmp #15,d0				; fli_brun
	bne.s .lb1
	if c256=1
		bsr fli_brun_256
		tst.b is_tt
		beq.s .lb4
		bsr to_planes
	else
		bsr fli_brun
	endif
	bra.s .lb4
.lb1:
	cmp #11,d0				; fli_color (64)
	bne.s .lb2
	if c256=1
		bsr fli_color_64_256
	else
		bsr fli_color_64
	endif
	bra.s .lb4
.lb2:
	cmp #4,d0				; flc_color (256)
	bne.s .lb20
	if c256=1
		bsr fli_color_256_256
	else
		bsr fli_color_256
	endif
	bra.s .lb4
.lb20:
	cmp #13,d0				; fli_black
	bne.s .lb3
	bsr fli_black
	bra.s .lb4
.lb3:
	cmp #16,d0				; fli_copy
	bne.s .lb3a
	if c256=1
		bsr fli_copy_256
		tst.b is_tt
		beq.s .lb4
		bsr.s to_planes
	else
		bsr fli_copy
	endif
	bra.s .lb4
.lb3a:
	cmp #27,d0
	bne.s .lb3b
	if c256=1
		bsr flh_delta_256
		tst.b is_tt
		beq.s .lb4
		bsr.s to_planes
	else
			tst.b nova
			beq.s .lb3c
			bsr flh_delta
			bra.s .lb4
		.lb3c:
			bsr flh_delta_falc
	endif
	bra.s .lb4
.lb3b:
	cmp #25,d0
	bne.s .lb4
	if c256=1
		bsr flh_brun_256
		tst.b is_tt
		beq.s .lb4
		bsr.s to_planes
	else
			tst.b nova
			beq.s .lb3d
			bsr flh_brun
			bra.s .lb4
		.lb3d:
			bsr flh_brun_falc
	endif
.lb4:
	move.l a1,a0			; unknow ID, just skip!
.ch_loop:
	dbf d6,.chunk
	if c256=0
		tst.b is_vdi
		beq.s .next
		movem.l a0-a4/d0-d6,-(sp)
		jsr vdi_display
		movem.l (sp)+,a0-a4/d0-d6
	endif
.next:
	btst #2,([kbshift])
	bne.s .stop
	dbf d7,.loop
	tst.b is_rep
	bne .disp_again
	bra.s .exit
.stop:
	st stopped
.exit:
	trap #10
	move.l d0,end_time
	rts

	if c256=1

to_planes:
	movem.l a0-a4/d0-d7,-(sp)
	move flx_number,a3
	move flx_start,d0
	move.l compression,a0
	jsr (a0)
	movem.l (sp)+,a0-a4/d0-d7
	rts

	endif

	if c256=1
fli_brun_256:
	else
fli_brun:
	endif
	move max_imagey,d5		; number of lines to modify
	if c256=1
		move d5,flx_number
		clr flx_start
	endif
	move.l a5,a2				; screen pointer
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line in memory
	moveq #0,d4					; number of blocs
	move.b (a0)+,d4
	beq.s .apex					; si 0, c'est du Apex tout crach‚
	bra.s .b_loop
.blocs:
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$7f,d0
	bls.s .repeat
	sub #$100,d0
	neg d0
	bra.s .c_loop
.copy:
	if c256=1
		move.b (a0)+,(a2)+
	else
		move.b (a0)+,d1
		move.w (a6,d1*2),(a2)+	; the color from the palette into the screen memory
	endif
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	move.b (a0)+,d1
	if c256=0
		move.w (a6,d1.w*2),d1	; the color to be repeated
	endif
	bra.s .lb2
.lb1:
	if c256=1
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
.next_line:
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts
.apex:
	move max_imagex,d4		; loop key is the width
	subq #1,d4
.ap_blocs:
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$7f,d0
	bls.s .ap_repeat
	sub #$100,d0
	neg d0
	sub d0,d4
	bra.s .ap_c_loop
.ap_copy:
	if c256=1
		move.b (a0)+,(a2)+
	else
		move.b (a0)+,d1
		move.w (a6,d1*2),(a2)+	; the color from the palette into the screen memory
	endif
.ap_c_loop:
	dbf d0,.ap_copy
	bra.s .ap_b_loop
.ap_repeat:
	sub d0,d4
	move.b (a0)+,d1
	if c256=0
		move.w (a6,d1.w*2),d1	; the color to be repeated
	endif
	bra.s .ap_lb2
.ap_lb1:
	if c256=1
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.ap_lb2:
	dbf d0,.ap_lb1
.ap_b_loop:
	tst d4
	bpl.s .ap_blocs
	bra.s .next_line


	if c256=1
flc_lc_256:
	else
flc_lc:
	endif
	moveq #0,d1					; to convert bytes to words
	move (a0)+,d5				; number of lines
	ror #8,d5
	if c256=1
		move #1,flx_number
		clr flx_start
		sf _disp
	endif
	move.l a5,a2				; screen pointer
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; next line
.skip80:
	move (a0)+,d4
	cmp.b #$80,d4
	beq.s .skip80
	ror #8,d4					; number of blocs
	btst #14,d4
	beq.s .lb0
	eor #$ffff,d4
	if c256=1
		tst.b _disp
		bne.s .yet
		add d4,flx_number
	.yet:
	endif
	muls d3,d4
	add.l d4,a3
	addq #1,d5
	bra.s .next
.lb0:
	st _disp
	bra.s .b_loop
.blocs:
	moveq #0,d0
	move.b (a0)+,d0
	if c256=1
		lea (a2,d0.w),a2
	else
		lea (a2,d0.w*2),a2		; skips some pixels
	endif
	move.b (a0)+,d0
	cmp #$7f,d0
	bls.s .p2_loop
	sub #$100,d0
	neg d0
	if c256=1
		move.b (a0)+,d2
		lsl #8,d2
		move.b (a0)+,d2
	else
		move.b (a0)+,d1			; one color
		move (a6,d1.w*2),d2
		swap d2
		move.b (a0)+,d1			; second color
		move (a6,d1.w*2),d2		; two colors into d2.l
	endif
	bra.s .p_loop
.pixel:
	if c256=1
		move d2,(a2)+
	else
		move.l d2,(a2)+			; 2 colors
	endif
.p_loop:
	dbf d0,.pixel
	bra.s .b_loop
.pixel2:
	if c256=1
		move (a0)+,(a2)+	; 2 colors
	else
		move.b (a0)+,d1
		move (a6,d1.w*2),d2
		swap d2
		move.b (a0)+,d1
		move (a6,d1.w*2),d2
		move.l d2,(a2)+
	endif
.p2_loop:
	dbf d0,.pixel2
.b_loop:
	dbf d4,.blocs
.next:
	if c256=1
		tst.b _disp
		beq.s .yet2
		addq #1,flx_number
		.yet2:
	endif
	move.l a3,a2
.l_loop:
	dbf d5,.line
	move max_imagey,d0
	cmp flx_number,d0
	bpl.s .exit
	subq #1,flx_number
.exit:
	rts

	if c256=1
fli_lc_256:
	else
fli_lc:
	endif
	move (a0)+,d0
	ror #8,d0					; number of lines to skip
	move (a0)+,d5
	ror #8,d5					; number of lines to modify
	if c256=1
		move d0,flx_start
		move d5,flx_number
	endif
	move.l a5,a2				; screen pointer
	muls d3,d0
	add.l d0,a2					; points to the correct line
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line in memory
	moveq #0,d4					; number of blocs
	move.b (a0)+,d4
	bra.s .b_loop
.blocs:
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels to skip
	if c256=1
		lea (a2,d0.w),a2
	else
		lea (a2,d0.w*2),a2		; skips the pixels
	endif
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$80,d0
	bpl.s .repeat
	bra.s .c_loop
.copy:
	if c256=1
		move.b (a0)+,(a2)+
	else
		move.b (a0)+,d1
		move.w (a6,d1.w*2),(a2)+	; the color from the palette into the screen memory
	endif
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	sub #$100,d0
	neg d0
	move.b (a0)+,d1
	if c256=0
		move.w (a6,d1.w*2),d1	; the color to be repeated
	endif
	bra.s .lb2
.lb1:
	if c256=1
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts

	if c256=1
fli_copy_256:
	else
fli_copy:
	endif
	move.l a5,a2				; the image
	move max_imagey,d5		; number of lines
	if c256=1
		move d5,flx_number
		clr flx_start
	endif
	move max_imagex,d1
	moveq #0,d2
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line
	move d1,d4					; pixels per line
	bra.s .p_loop
.pixel:
	if c256=1
		move.b (a0)+,(a2)+
	else
		move.b (a0)+,d2
		move (a6,d2.w*2),(a2)+	; one pixel
	endif
.p_loop:
	dbf d4,.pixel
	move.l a3,a2				; next line
.l_loop:
	dbf d5,.line
	rts

c256 set 1+c256

	endr							; two types of fli routines (32k or 256c)


fli_color_64:
	move.l d3,-(sp)
	move (a0)+,d0				; number of blocs
	ror #8,d0
	move.l a6,a2				; palette pointer
	move bit_rot,d3
	move is_65k,d5
	move.b nova,d5				; NOVA or Falcon 16 bits
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	lea (a2,d1*2),a2			; jumps to the correct color
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1= it means 256 colors
.color:
		move.b (a0)+,d2
		ror #7,d2
		and #$7c00,d2				; red
		move.b (a0)+,d4
		lsl #4,d4
		and #$3e0,d4
		or d4,d2						; + green
		moveq #0,d4
		move.b (a0)+,d4
		lsr #1,d4
		or d4,d2						; + blue
	ror d3,d2					; to NOVA  format
	tst d5						; is_65k in upper byte
	bmi.s .lb00
	tst.b d5
	bne.s .lb0
.lb00:
	FALC16 d2
	tst d5
	bpl.s .lb0
	ror #8,d2
.lb0:
	move d2,(a2)+				; and into the palette
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	move.l (sp)+,d3
	rts

fli_color_64_256:
	move (a0)+,d0				; number of blocs
	ror #8,d0
	tst.b is_tt					; because of NVDI
	bne.s .tt_pal
	lea indexs,a2
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	lea (a2,d1*2),a2			; jumps to the correct color
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1=0 it means 256 colors
.color:
	lea vs_int,a6
	move (a2)+,(a6)+			; color index
		rept 3
			moveq #0,d2
			move.b (a0)+,d2
			lsl #4,d2					; 0-63 to 0-1008
			move d2,(a6)+
		endr
	movem.l d0-d1/a0-a2,-(sp)
	GEM_VDI vs_color
	movem.l (sp)+,d0-d1/a0-a2
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	rts
.tt_pal:
	sub.l a2,a2
	bra.s .tt_b_loop
.tt_blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	add d1,a2
	move.b (a0)+,d1
	bne.s .tt_col_loop
	move #255,d1				; if d1=0 it means 256 colors
.tt_color:
		move.b (a0)+,d2
		lsl #6,d2
		move.b (a0)+,d2
		lsl.b #2,d2
		lsl #4,d2
		move.b (a0)+,d2
		lsl.b #2,d2
		lsr #4,d2
	movem.l d0-d1/a0-a2,-(sp)
	bsr.s setonecolor
	movem.l (sp)+,d0-d1/a0-a2
	addq #1,a2
.tt_col_loop:
	dbf d1,.tt_color
.tt_b_loop:
	dbf d0,.tt_blocs
	rts

setonecolor:
	tst.b albertt
	bne.s .lb0
	move d2,-(sp)
	move a2,-(sp)
	XBIOS 83,6						; esetcolor
	rts
.lb0:
	lea .color(pc),a0
	move a2,(a0)+
	move d2,(a0)+
	pea (a0)
	XBIOS 38,6
	rts
.color: dc.w 0,0
	lea .color(pc),a0
	move (a0)+,d0
	lea ($FFFF8400,d0.w*2),a1
	move (a0),(a1)
	rts

fli_color_256:
	move.l d3,-(sp)
	move (a0)+,d0				; number of blocs
	ror #8,d0
	move.l a6,a2				; palette pointer
	move is_65k,d5
	move.b nova,d5				; NOVA or Falcon 16 bits
	move bit_rot,d3			; 8 for Intel, 0 for Motorola
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	lea (a2,d1*2),a2			; jumps to the correct color
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1=0 it means 256 colors
.color:
		move.b (a0)+,d2
		lsl #7,d2
		and #$7c00,d2				; red
		move.b (a0)+,d4
		lsl #2,d4
		and #$3e0,d4
		or d4,d2						; + green
		move.b (a0)+,d4
		lsr.b #3,d4
		or.b d4,d2					; + blue
	ror d3,d2					; to NOVA  format (if 8) or as is (if 0)
	tst d5
	bmi.s .lb00
	tst.b d5
	bne.s .lb0
.lb00:
	FALC16 d2
	tst d5
	bpl.s .lb0
	ror #8,d2
.lb0:
	move d2,(a2)+				; and into the palette
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	move.l (sp)+,d3
	rts

fli_color_256_256:
	move (a0)+,d0				; number of blocs
	ror #8,d0
	tst.b is_tt					; because of NVDI...
	bne.s .tt_pal
	lea indexs,a2
	bra.s .b_loop
.blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	lea (a2,d1*2),a2			; jumps to the correct color
	move.b (a0)+,d1
	bne.s .col_loop
	move #255,d1				; if d1=0 it means 256 colors
.color:
	lea vs_int,a6
	move (a2)+,(a6)+			; color index
		rept 3
			moveq #0,d2
			move.b (a0)+,d2
			lsl #2,d2					; 0-255 to 0-1020
			move d2,(a6)+
		endr
	movem.l d0-d1/a0-a2,-(sp)
	GEM_VDI vs_color
	movem.l (sp)+,d0-d1/a0-a2
.col_loop:
	dbf d1,.color
.b_loop:
	dbf d0,.blocs
	rts
.tt_pal:
	sub.l a2,a2
	bra.s .tt_b_loop
.tt_blocs:
	moveq #0,d1
	move.b (a0)+,d1			; number of colors to skip
	add d1,a2
	move.b (a0)+,d1
	bne.s .tt_col_loop
	move #255,d1				; if d1=0 it means 256 colors
.tt_color:
		move.b (a0)+,d2
		lsl #4,d2
		move.b (a0)+,d2
		lsl #4,d2
		move.b (a0)+,d2
		lsr #4,d2
	movem.l d0-d1/a0-a2,-(sp)
	bsr setonecolor
	movem.l (sp)+,d0-d1/a0-a2
	addq #1,a2
.tt_col_loop:
	dbf d1,.tt_color
.tt_b_loop:
	dbf d0,.tt_blocs
	rts

fli_black:
	move.l a1,-(sp)
	tst.b is_tt
	bne.s .lb2
	tst.b switched
	bne.s .lb0
.lb2:
	GEM_VDI v_bar			; VDI still works
	bra.s .end
.lb0:							; else, we handle it
	move.l physbase,a1
	move #9599,d5
.lb1:
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a1)+
	clr.l (a1)+
	dbf d5,.lb1
.end:
	move.l (sp)+,a1
	rts

	; verifies AVI format and gets the addresses of the 3 main blocs
	; header + data + index
	; returns EQ if ok and NE if error

avi_parse_bin:
	SEEK #0,0				; start of file
	move.l #$20202020,d6
	bsr.l read_3_long
	or.l d6,d0				; chunk name
	moveq #7,d7				; mask of bits to find
	cmp.l #'riff',d0
	beq.s .lb0
.false:
	cmp #1,d7				; reste la zone idx1??
	beq .no_id
	moveq #1,d0				; not an AVI file
	rts
.lb0:
	moveq #4,d1
.lb1:
	tst d7
	beq .end					; all found
	subq.l #4,d1
	SEEK d1,1				; position into d0
	move.l d0,d5			; saves it
	bmi.s .false			; error!
	cmp.l total,d0
	beq.s .false			; end of file!
	addq.l #8,d5
	bsr.l read_3_long
	or.l d6,d0
	or.l d6,d2
	INTEL d1
	cmp.l #'idx1',d0
	bne.s .lb2
	subq #1,d7				; one bloc found (bit 0)
	move.l d5,idx_pos
	move.l d1,idx_len
	bra.s .lb1
.lb2:
	cmp.l #'list',d0
	bne.s .lb1
	cmp.l #'hdrl',d2
	bne.s .lb3
	subq #2,d7				; one bloc (bit 1)
	addq.l #4,d5
	move.l d5,head_pos
	subq.l #4,d1
	move.l d1,head_len
	addq.l #4,d1
	bra.s .lb1
.lb3:
	cmp.l #'movi',d2
	bne .lb1
	subq #4,d7				; one bloc (bit 2)
	move.l d5,movi_pos
	bra .lb1
.no_id:
	st no_idx1
.end:
	moveq #0,d0
	rts

	; reads the header (size of the image, number of frames, compression,
	; sound frequency, etc...)
	; then reads the 'idx1' section and prepares the tables to read each
	; frame


avi_parse_chunks:
	move planes,planes_sav
	tst.b res_switch
	beq.s .no_sw
	bmi.s .aab
	move #8,planes				; always 256 colors for a TT
	bra.s .no_sw
.aab:
	move #16,planes			; act like TC if we're going to switch
.no_sw:
	move.l #$20202020,d7
	lea Sas,a6			; the buffer to read the header
	move.l head_len,d6
	SEEK head_pos,0			; to the right position
	move.l a6,-(sp)
	move.l d6,-(sp)	; lenght of the AVI header bloc
	move mov_h,-(sp)
	GEMDOS 63,12
	lea (a6,d6.l),a5			; end address
	moveq #0,d4					; ffctype (vids or auds)
.lb0:
	cmp.l a5,a6
	bpl .end_header
	move.l (a6)+,d0			; chunk name
	or.l d7,d0					; to lower case
	move.l (a6)+,d1
	INTEL d1						; size
	cmp.l #'avih',d0
	bne .lb1
	lea 16(a6),a3		; points to total frames
	move.l (a3)+,d0
	INTEL d0
	move.l d0,sample_num	; number of frames
	lea 12(a3),a3
	move.l (a3)+,d0		; width
	INTEL d0
	move d0,max_imagex
	move d0,d2
	addq #3,d0
	and.b #$FC,d0
	move d0,xto4n
	add #15,d0
	and.b #$F0,d0
	sub xto4n,d0
	lsr #2,d0
	move d0,iv32_uv_inc
	lsr #2,d2
	addq #3,d2
	and.b #$fc,d2
	move d2,xqto4n
	move.l (a3),d0			; height
	INTEL d0
	move d0,max_imagey
	move d0,d2
	addq #3,d0
	and.b #$fc,d0
	move d0,yto4n
	lsr #2,d2
	addq #3,d2
	and.b #$fc,d2
	move d2,yqto4n
	move #$0101,iv32_freq
	st samp_sizes
	bra .next
.lb1:
	cmp.l #'list',d0
	bne.s .lb2
	cmp.l #'strl',(a6)
	bne .next
	addq.l #4,a6
	bra .lb0
.lb2:
	cmp.l #'strh',d0
	bne.s .lb3
	move.l (a6),d4			; fcctype
	or.l d7,d4
	cmp.l #'vids',d4
	bne .next
	move.l 20(a6),d0
	INTEL d0					; time for one frame
	move.l 24(a6),d2		; rate
	INTEL d2
	muls.l #200,d0
	divs.l d2,d0
	move.l d0,avi_rate	; number of 1/200 for one frame
	bra .next
.lb3:
	cmp.l #'strf',d0
	bne .next
	cmp.l #'vids',d4		; video info?
	bne .lb4				; no...
	move.l 32(a6),d0
	INTEL d0					; number of colors into the palette
	move.l d0,mapused
	beq.s .c9
	bsr prepare_avi_pal
.c9:
	moveq #0,d4
	move.l 16(a6),d0		; compression
	or.l d7,d0				; to lower
	move.l d0,comp_txt
	cmp.l #'jpeg',d0
	beq.s .yeah
	cmp.l #"mjpg",d0
	bne.s .c1b
.yeah:
	lea qt_raw24,a0
	move.l a0,a1
	cmp #8,planes
	beq.s .mjp2
	tst.b nova
	bne.s .mjp1
	lea qt_raw24_falc,a0
	bra.s .mjp1
.mjp2:
	lea qt_raw24_256,a0
.mjp1:
	move.l a1,mjpg_step_compression
	move.l a0,mjpg_comp
	st is_mjpg
	move.l #440,mjpg_offset
	clr off_24_32			; 24 bits (for qt_raw)
	move.l #avi_mjpg,d0
	move.l d0,step_compression
	bra .next_comp
.c1b:
	cmp.l #'cvid',d0
	bne.s .c1
	move.l #qt_decode_cvid,d0
	move.l d0,step_compression
	cmp #8,planes
	bne .next_comp
	move.l #qt_decode_256,d0
	bra .next_comp
.c1:
	cmp.l #'msvc',d0
	beq.s .c1a
	cmp.l #'cram',d0
	bne .c2
.c1a:
	move 12(a6),d0			; Planes
	ror #8,d0
	move 14(a6),d2			; bitcount
	ror #8,d2
	muls d2,d0				; number of bits per pixel
	move d0,cram_bits
	cmp #16,d0
	bne.s .c5
	move.l #decode_cram16,step_compression
	tst.b is_tt
	bne.s .c4
	tst.b nova
	beq.s .c3
	cmp #8,planes
	beq.s .c4
	move.l #decode_cram16,d0
	bra .next_comp
.c4:
	move.l #decode_cram16_grey,d0
	bra .next_comp
.c3:
	move.l #decode_cram16_falc,d0
	bra .next_comp
.c5:
	cmp #8,d0
	bne .unsup				; unsupported CRAM
	move.l #decode_cram8,d0
	move.l d0,step_compression
	cmp #8,planes
	bne .next_comp
	move.l #decode_cram8_256,d0
	bra .next_comp
.c2:
	cmp.l #'!   ',d0	; rle 8
	bne.s .c8
	move.l #'rle8',comp_txt
	move.l #decode_rle8,d0
	move.l d0,step_compression
	cmp #8,planes
	bne .next_comp
	move.l #decode_rle8_256,d0
   bra .next_comp
.c8:
	cmp.l #'yuv9',d0
	beq.s .c12
	cmp.l #'yvu9',d0
	bne.s .c10
.c12:
	move.l #qt_yuv9,d0
	move.l d0,step_compression
	cmp #8,planes
	bne .next_comp
	move.l #qt_yuv9_256,d0
	bra .next_comp
.c10:
	cmp.l #'    ',d0	; rgb
	bne.s .c13
	move.l #'rgb8',comp_txt
	move.l #decode_rgb,d0
	move.l d0,step_compression
	cmp #8,planes
	bne .next_comp
	move.l #decode_rgb_256,d0
	bra .next_comp
.c13:
	not.l d0
	cmp.l #$9689ccce,d0		; iv31
	beq.s .iv
	cmp.l #$9689cccd,d0		; iv32
	bne.s .unsup
.iv:
	move.l #intel_iv32,d0
	move.l d0,step_compression
	move.l #intel_iv32_256,d0
	cmp #16,planes
	bne.s .next_comp
		st can_fast
	move.l #intel_iv32,d0
	bra.s .next_comp
.unsup:
	st bad_comp
	bra.s .next
.lb4:
	cmp.l #'auds',d4		; sound info?
	bne.s .next
	move.l a6,a3
	move (a3)+,avi_comp_flag
	move (a3)+,d4
	ror #8,d4
	move d4,channels
	move.l (a3)+,d0
	INTEL d0
	move.l d0,frequency
	move.l 4(a3),d0		; block & sound bits
	ror #8,d0
	bne.s .bitok			; if info present, ok
	swap d0					; else block size
	ror #8,d0
	cmp #2,d4
	bne.s .nostereo
	lsr #1,d0				; else half block
.nostereo:
	lsl #3,d0				; byte to bits	
.bitok:	
	move d0,sound_bits
	moveq #0,d4
.next:
	add.l d1,a6
	bra .lb0
.next_comp:
	move.l d0,compression
	bra.s .next
.end_header:
	move planes_sav,planes
	tst.b no_idx1
	bne .fin
	SEEK idx_pos,0			; to the index table
	move.l idx_len,d4
	move.l d4,d6
	asr.l #4,d6				; each entry is 16 bytes long
	move.l d6,d3			; for the loop
	move.l sample_num,d5
	tst.l frequency
	beq.s .no_sound
	sub.l d5,d6				; total frames - image frames >= sound frames
	move.l d6,d1
	beq.s .no_sound
	asl.l #3,d1				; 8 bytes for each sound (pos + len)
	bsr.l malloc
	move.l d0,sound_offs
	move.l d0,a4			; for the sound
.no_sound:
	move.l d5,d1
	muls.l #12,d1			; 12 bytes for each image (offset + size + time)
	addq.l #8,d1
	addq.l #8,d1			; for dummy values (start and end)
	bsr.l malloc
	move.l d0,chunkoffs
	move.l d0,a5			; for the graphics
	addq.l #4,a5			; skips over the dumy value
	move.l d4,d1
	bsr.l malloc				; for the whole idx1
	move.l d0,snd_temp	; saves it
	move.l d0,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	sub.l a3,a3				; no offset
	move.l snd_temp,a0
	move.l a0,a2			; for mfree
	move.l d3,d6
	moveq #0,d4				; total sound size
	moveq #0,d5				; max_fsize
	moveq #0,d3				; max sound size
	move.l sample_num,a1	; to verify
	move.l 8(a0),d1		; first position
	INTEL d1
	sf dc_flag
	cmp.l movi_pos,d1		; in the movie section?
	bpl.s .ok				; yes, positions are absolute
	move.l movi_pos,a3	; else, we must add a base address
.ok:
	move.l (a0)+,d0
	or.l d7,d0
	move.l d0,d1
	swap d1
	cmp #'00',d1			; 00dc or 00xx or else = a frame!
	bne.s .lb5
	cmp.l #0,a1				; end of expected frames?
	beq .unknown			; yes, skips!
	subq.l #1,a1			; one less frame
	move.l (a0)+,d2		; flags
	move.l (a0)+,d1		; offset
	INTEL d1
	add.l a3,d1
	addq.l #8,d1			; to skip the ID and the size
	move.l d1,(a5)+
	;***
	tst.b dc_flag
	beq.s .first
	sub.l -16(a5),d1		; diff of sizes
	bmi.s .first
	move.l -12(a5),d0		; old size
	beq.s .first			; nul frame, don't touch!
	sub.l d0,d1				; what will be added
	bmi.s .first
	cmp.l #2049,d1
	bpl.s .first			; too much
	add.l d1,d0				; back to diff of sizes
	cmp.l d0,d5
	bpl.s .lbtruc
	move.l d0,d5
.lbtruc:
	move.l d0,-12(a5)		; as the new size for the previous frame
.first:
	;***
	move.l (a0)+,d1		; size
	INTEL d1
	move.l d1,(a5)+
	st dc_flag
	cmp.l d1,d5
	bpl.s .lb6
	move.l d1,d5			; new max fsize
.lb6:
	clr.l (a5)+				; time
	btst #28,d2				; flag for 'key frame'
	beq.s .loop
	bset #7,-4(a5)			; bit 31 of time
	addq.l #1,ss_num			; number of key frames
	bra.s .loop
.lb5:
	cmp.l #'01wb',d0
	bne.s .unknown
	addq.l #1,sound_num
	addq.l #4,a0			; skip flags
	move.l (a0)+,d1		; offset
	INTEL d1
	add.l a3,d1
	addq.l #8,d1			; to skip the ID and the size
	move.l d1,(a4)+
	move.l (a0)+,d1		; size
	INTEL d1
	move.l d1,(a4)+
	add.l d1,d4				; updates the total size
	cmp.l d1,d3
	bpl.s .loop
	move.l d1,d3			; new max sound size
	bra.s .loop
.unknown:
	lea 12(a0),a0			; skips it
.loop:
	subq.l #1,d6
	bne .ok
	move.l a1,d6
	sub.l d6,sample_num	; if less than expected frames
	bsr.l mfree
	move.l sample_num,d2	; total frames
	move.l ss_num,d0		; key frames
	beq.s .no_key			; no key frames...
	divs.l d0,d2			; number of frames for 1 key frame
	cmp.l #4,d2				; more than 4?
	bmi.s .no_key
	st sync+1				; yes, so never skip a key frame!
.no_key:
	move.l d5,max_fsize
	move.l d4,snd_size
	move.l d3,snd_temp_size
.fin:
	rts

avi_build_table:
	moveq #0,d0
	bsr.l general_info
	bsr.l winup_on
	move.l #$20202020,d7
	move.l movi_pos,a3
	addq.l #4,a3		; saute 'movi'
	SEEK a3,0			; to the index table
	move.l sample_num,d5
	tst.l frequency
	beq.s .no_sound
	move.l d5,d6			; 1 image = 1 sound (???)
	move.l d6,d1
	beq.s .no_sound
	asl.l #3,d1				; 8 bytes for each sound (pos + len)
	bsr.l malloc
	move.l d0,sound_offs
	move.l d0,a4			; for the sound
.no_sound:
	move.l d5,d1
	muls.l #12,d1			; 12 bytes for each image (offset + size + time)
	addq.l #8,d1
	addq.l #8,d1			; for dummy values (start and end)
	bsr.l malloc
	move.l d0,chunkoffs
	move.l d0,a5			; for the graphics
	addq.l #4,a5			; skips over the dumy value
	move.l d3,d6
	moveq #0,d4				; total sound size
	moveq #0,d5				; max_fsize
	moveq #0,d3				; max sound size
	move.l sample_num,a1	; to verify
	sf dc_flag
.ok:
	move.l a1,-(sp)
	bsr.l read_id_len
	INTEL d1
	addq.l #1,d1
	bclr #0,d1
	move.l d1,a0			; sauve la taille
	move.l (sp)+,a1
	addq.l #8,a3
	or.l d7,d0
	swap d0
	cmp #'00',d0			; 00dc or 00xx or else = a frame!
	bne.s .lb5
	cmp.l #0,a1				; end of expected frames?
	beq.s .unknown			; yes, skips!
	subq.l #1,a1			; one less frame
	moveq #0,d2				; flags
	move.l a3,d1			; offset
	move.l a3,(a5)+
	;***
	tst.b dc_flag
	beq.s .first
	sub.l -16(a5),d1		; diff of sizes
	bmi.s .first
	move.l -12(a5),d0		; old size
	beq.s .first			; nul frame, don't touch!
	sub.l d0,d1				; what will be added
	bmi.s .first
	cmp.l #2049,d1
	bpl.s .first			; too much
	add.l d1,d0				; back to diff of sizes
	cmp.l d0,d5
	bpl.s .lbtruc
	move.l d0,d5
.lbtruc:
	move.l d0,-12(a5)		; as the new size for the previous frame
.first:
	;***
	move.l a0,d1		; size
	move.l d1,(a5)+
	st dc_flag
	cmp.l d1,d5
	bpl.s .lb6
	move.l d1,d5			; new max fsize
.lb6:
	clr.l (a5)+				; time
	btst #28,d2				; flag for 'key frame'
	beq.s .loop
	bset #7,-4(a5)			; bit 31 of time
	addq.l #1,ss_num			; number of key frames
	bra.s .loop
.lb5:
	swap d0
	cmp.l #'01wb',d0
	bne.s .unknown
	addq.l #1,sound_num
	move.l a3,(a4)+		; offset
	move.l a0,d1		; size
	move.l d1,(a4)+
	add.l d1,d4				; updates the total size
	cmp.l d1,d3
	bpl.s .loop
	move.l d1,d3			; new max sound size
	bra.s .loop
.unknown:
	cmp.l #"rec ",d0
	bne.s .loop				; non, sauter section
	sub.l a0,a0				; sinon, vider A0 car len id est suffisant
.loop:
	add.l a0,a3				; updates offset
	move.l a1,-(sp)
	SEEK a0,1
	move.l (sp)+,a1
	cmp.l d0,a3				; offset correct?
	bne.s .fin_fich
	subq.l #1,d6
	bne .ok
.fin_fich:
	move.l a1,d6
	sub.l d6,sample_num	; if less than expected frames
	move.l sample_num,d2	; total frames
	move.l ss_num,d0		; key frames
	beq.s .no_key			; no key frames...
	divs.l d0,d2			; number of frames for 1 key frame
	cmp.l #4,d2				; more than 4?
	bmi.s .no_key
	st sync+1				; yes, so never skip a key frame!
.no_key:
	move.l d5,max_fsize
	move.l d4,snd_size
	move.l d3,snd_temp_size
.fin:
	bsr.l winup_off
	bsr.l general_info_off
	rts

prepare_avi_pal:
	movem.l a0-a1,-(sp)
	lea cvid_fix1,a0
	move #$0100,(a0)+		; one bloc
	clr.b (a0)+				; first color
	move.b d0,(a0)+		; number of colors
	lea 40(a6),a1			; start of palette
	bra.s ap_loop


open_work: dc.l ow_cont,ow_int,dum,work_out,ptsout
ow_cont: dc.w 100,0,0,11,0,0,0,0,0,0,0,0
ow_int: dc.w 2,1,1,1,1,1,1,0,1,0,2


ap_lb0:
	move.b 2(a1),(a0)+	; red
	move.b 1(a1),(a0)+	; green
	move.b (a1),(a0)+		; blue
	addq.l #4,a1
ap_loop:
	dbf d0,ap_lb0
	movem.l (sp)+,a0-a1
	rts

avi_read_data:
	tst.b is_mjpg
	bne.s .keepit
	moveq #-1,d0
	move.l d0,bufused		; for CVID
.keepit:
	tst.b step_mode
	beq.s .pas_mode
	bra.l avi_step_mode
.pas_mode:
	bsr.l install_traps
.disp_again:
	moveq #0,d4				; file position!!!
	moveq #0,d3				; sync flags
	tst.b playing
	beq.s .no_sound
	tst.l s_buffer_2
	beq.s .s2
	bset #8,d3
.s2:
	pea start_sound
	XBIOS 38,6
.no_sound:
	tst.b bad_comp
	bne .exit				; bad compression!
	move.b sync,d3
	tst.b sync+1
	beq.s .ad
	bset #16,d3				; we can't skip a key frame
.ad:
	trap #10
	move.l d0,start_time	; Timer C
	bsr.l enh_event0		; init first event for enh_time
	move.l sample_num,d7
	move.l chunkoffs,a6
	addq.l #4,a6
	bra .loop
.lb0:
	btst #8,d3
	beq.s .no_remain
	tst.b snd_value
	bmi.s .dma_remain
	tst.b yamaha_flag
	bne.s .no_remain
	bsr yamaha_next_sound
	bra.s .no_remain
.dma_remain:
	trap #11
	bne.s .no_remain
	bsr next_sound
.no_remain:
	lea 8(a6),a0
	bclr #31,d3
	move.l (a0),d0	; time
	bpl.s .no_key
	bset #31,d3
	bclr #31,d0
.no_key:
	move.l d0,a3
	tst.w d3
	beq.s .lb1
	bpl.s .pos
	tst.l d3
	bpl.s .skip
	btst #16,d3
	bne.s .lb1
	bra.s .pos1
.pos:
	tst.l d3
	bpl.s .pos1
	btst #16,d3
	bne.s .lb1
.pos1:
	trap #10
	sub.l start_time,d0
	cmp.l d0,a3
	bpl.s .lb1
	tst d3
	bmi.s .skip
.search:
	lea 12(a0),a0
	tst.b (a0)
	bpl.s .search
	move.l -12(a0),d0
	bclr #31,d0			; en cas de key frames partout!
	cmp.l d1,d0
	bpl.s .lb1
	bset #15,d3
.skip:
	lea 12(a6),a6
	bra .loop
.lb1:
	bclr #15,d3
	move.l (a6)+,d0
	tst.b from_ram
	beq.s .from_file
	add.l whole_file,d0
	move.l d0,buffer
	move.l (a6)+,d0
	bra.s  .nul_frm
.from_file:
	cmp.l d0,d4
	beq.s .no_seek
	SEEK d0,0			; good positon
	move.l d0,d4		; new position
.no_seek:
	move.l (a6)+,d0
	beq.s .nul_frm
	move.l buffer,d1
	add.l mjpg_offset,d1
	move.l d1,-(sp)
	move.l d0,-(sp)
	add.l d0,d4			; new position
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the frame
.nul_frm:
	move.l (a6)+,d0
	bclr #31,d0
	move.l d0,a3			; the time
	addq.l #1,disp_frame
	tst.b d3
	beq.s .disp
	move.l start_time,a0
	move.l -16(a6),d0
	bclr #31,d0
	move.l enh_time,d1
	add.l d0,a0
.wait:
	trap #10
	cmp.l d0,d1
	bmi.s .event
	cmp.l d0,a0
	bpl.s .wait
	bra.s .disp
.event:
	bsr.l enh_event
	move.l enh_time,d1
	bra.s .wait
.disp:
	tst.l -8(a6)		; frame size
	beq.s .loop			; nul frame
	movem.l d3-d4/d7/a3/a6,-(sp)
	move.l compression,a0
	jsr (a0)
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	movem.l (sp)+,d3-d4/d7/a3/a6
.loop
	btst #2,([kbshift])
	bne.s .stop
	subq.l #1,d7
	bpl .lb0
	bsr wait_last
	bra.s .exit
.stop:
	st stopped
.exit:
	tst.b stopped
	bne.s .quit
	btst #2,([kbshift])
	bne.s .stop
	tst.b snd_value
	bmi.s .dma_quit
	tst.b yamaha_flag
	bne.s .exit
	bra.s .test_repeat
.dma_quit:
	tst.b playing
	beq.s .test_repeat	; if no sound played (in case of another player in use)
	trap #11
	bne.s .exit
	btst #8,d3
	beq.s .test_repeat
	bsr next_sound
	bra.s .exit
.test_repeat:
	tst.b is_rep
	beq.s .quit
	tst.b snd_value
	bpl .disp_again		; no DMA so no TT/ST ram problem
	tst.l s_buffer_2		; a TT Ram sound with DMA?
	beq .disp_again		; no, all in ST RAM
	sf playing				; else, no sound with repetition
	bra .disp_again
.quit:
	bsr.l stop_all_sounds
.quit3:
	bra.l common_end


avi_sync_tab:
	move.l tree_sav,a0
	btst #0,299(a0)		; objetc 'synchronize'
	beq .end					; no sync
	move.l chunkoffs,a1
	cmp.l #0,a1
	beq .end
	move.l sample_num,d4
	tst.b bad_sound	; bad sound, use avi_rate
	bne.s .lb4
	tst.l sound_num	; no sound anyway, avi_rate
	beq.s .lb4
	tst.b playing
	beq.s .lb4			; no sound loaded, use AVI rate
	move.l snd_size,d1	; the size in bytes
	tst.b snd_value
	bmi.s .dma
	move.l #9600,d5
	bra.s .lb5
.dma:
	move.l real_freq,d5
	cmp #2,channels
	bne.s .lb5				; not a stereo, 1byte = 1sample
	asr.l #1,d1				; else 2bytes = 1 sample
.lb5:
	moveq #0,d6
	muls.l #200,d6:d1
	divs.l d5,d6:d1	; d1=number of 200th of second for the whole sample
								; to use the Timer C of the system
	bra.s .lb3
.lb4:
	move.l d4,d1
	muls.l avi_rate,d1	; number of 200th of sec for the whole sample
.lb3:
	clr.l (a1)+				; the first entry contains 0 (start of the sound)
	moveq #1,d6
.lb1:
	addq.l #8,a1			; skips pos and size
	move.l d6,d3			; number of frames
	muls.l d1,d5:d3
	divs.l d4,d5:d3		; d3 is the corresponding duration in 1/200 sec
	or.l d3,(a1)+			; to keep the 'key frame' flag
	addq.l #1,d6
	cmp.l d6,d4
	bpl.s .lb1
	st sync
	bset #7,8(a1)			; the last is always marked!
.end:
	rts


	; qt_parse_bin returns EQ if the QT MOV format is correct
	; or NE if there's an error. In this case, the AVI format will be
	; supposed.

qt_parse_bin:
	moveq #2,d5							; 2 ids to find
	moveq #-1,d6
	moveq #1,d0
.next:
	tst.l d0
	bmi.s .bug
	beq.s .bug
	tst d5
	beq.s .ok
	add.l d0,d6
	cmp.l total,d6
	bpl.s .bug
	SEEK d6,0
	bsr read_len_id
	cmp.l #'skip',d1
	beq.s .skip0
	cmp.l #'mdat',d1
	bne.s .lb0
.skip0:
	move.l d6,d7
	add.l d0,d7							; end of mdat section
	move.l d7,mdat_end
	subq #1,d5
	bra.s .next
.lb0:
	cmp.l #'moov',d1
	bne.s .next
	subq #1,d5
	bra.s .next
.bug:
	moveq #1,d0
	rts
.ok:
	SEEK #0,0
	moveq #0,d0
	rts

qt_parse_chunks:
	moveq #1,d7				; the file_len
.lb0:
	tst.l d7
	bgt.s .lb1				; goes on if file_len >0
.end:
	rts   					; end if file_len<=0
.lb1:
	SEEK #0,1				; current position
	move.l total,d1
	sub.l d0,d1				; remaining bytes
	cmp.l #8,d1
	bmi.s .end				; not enough for len+id, end of file reached
	bsr read_len_id
	cmp.l #'skip',d1
	beq.s .skip1
	cmp.l #'mdat',d1
	bne.s .lb2
.skip1:
	tst.l d0
	bne.s .lb2
	moveq #30,d0			; alert if mdat and len=0, an error
	bra ooops
.lb2:
	cmp.l #8,d0
	bmi.s .end				; if len<8, we stop parsing
	cmp.l #1,d7
	bne.s .lb3
	cmp.l #'mdat',d1
	beq.s .lb3
	cmp.l #'skip',d1
	beq.s .lb3
	move.l d0,d7			; if file_len=1 and id <> 'mdat', file_len=len
	cmp.l #'moov',d1
	beq.s .lb3
	addq.l #1,d7			; and if id<>'moov', then file_len=len+1
.lb3:
	; *********************** atoms ***************
	cmp.l #'trak',d1
	bne.s .lb5
	clr.l v_flag
	clr.l s_flag
	move.l codec_num,codec_lastnum
	move.l chunkoff_num,chunkoff_lastnum
	move.l sample_num,sample_lastnum
	move.l s2chunk_num,s2chunk_lastnum
.lb4: subq.l #8,d7		; file_len = file_len - 8
	bra .lb0
.lb5:	cmp.l #'moov',d1
	beq.s .lb4
	cmp.l #'mdia',d1
	beq.s .lb4
	cmp.l #'minf',d1
	beq.s .lb4
	cmp.l #'stbl',d1
	beq.s .lb4
	cmp.l #'edts',d1
	beq.s .lb4
.lb6:
	; ********************** stuff *********************
	cmp.l #'mvhd',d1
	bne.s .lb7
	sub.l d0,d7
	SEEK #100,1			; just jump 100 bytes
	bra .lb0
.lb7:
	cmp.l #'tkhd',d1
	bne.s .lb8
	sub.l d0,d7
	SEEK #74,1			; just jump 74
	bsr read_len_id	; + 8
	move.l d0,_vr2_x
	move.l d1,_vr2_y	; temporaires (au cas ou GMHD=pano)
	SEEK #2,1			; +2 = 84....
	bra .lb0
.lb8:
	cmp.l #'elst',d1
	bne.s .lb9
	sub.l d0,d7
	bsr read_len_id
	muls #12,d1			; number of blocks of 12 bytes
	SEEK d1,1			; jumps
	bra .lb0
.lb9:
	cmp.l #'mdhd',d1
	bne.s .lb10
	sub.l d0,d7
	SEEK #12,1			; jumps 12 bytes
	bsr read_long
	lea qt_time,a0
	tst.l (a0)
	beq.s .lb9b
	clr.l (a0)+			; vmhd yet read = qt_time=0
.lb9b:
	move.l d0,(a0)		; in qt_time or qt_timescale
	SEEK #8,1			; jumps 8 more bytes
	bra .lb0
.lb10:
	cmp.l #'hdlr',d1
	bne.s .lb11
	sub.l d0,d7
	move.l d0,d6		; saves len
	SEEK #24,1			; jumps 24 bytes
	sub.l #32,d6		; is len>32
	bmi .lb0
	beq .lb0
	move.l d6,d0		; yes, d0 bytes to read
	bsr qt_read_name	; as a name
	bra .lb0
	; ********************* data chunks ***********************
.lb11:
	cmp.l #'skip',d1
	beq.s .skip2
	cmp.l #'mdat',d1
	bne.s .lb12
.skip2:
	subq.l #8,d0
	SEEK d0,1			; just jumps
	st data_flag		; and sets the data flag TRUE
	bra .lb0
.lb12:
	cmp.l #'stsd',d1
	bne.s .lb14
	clr.l video_flag
	move.l d0,-(sp)	; saves the len
	bsr qt_read_stsd
	move.l (sp)+,d0
	cmp.l #1,v_flag
	beq.s .lb13
	tst.b vr2_flag
	beq.s .lb13
	moveq #16,d0		; 16 for sound and text
.lb13:
	sub.l d0,d7			; sub 16 or normal len for video
	bra .lb0
.lb14:
	cmp.l #'stts',d1
	bne.s .lb15
	sub.l d0,d7
	bsr qt_read_stts
	bra .lb0
.lb15:
	cmp.l #'stss',d1
	bne.s .lb16
	sub.l d0,d7
	bsr qt_read_stss
	bra .lb0
.lb16:
	cmp.l #'stco',d1
	bne.s .lb17
	sub.l d0,d7
	bsr qt_read_stco
	bra .lb0
.lb17:
	cmp.l #'stsz',d1
	bne.s .lb18
	sub.l d0,d7
	bsr qt_read_stsz
	bra .lb0
.lb18:
	cmp.l #'stsc',d1
	bne.s .lb19
	sub.l d0,d7
	bsr qt_read_stsc
	bra .lb0
	; ************** sound codec header ******************
.lb19:
	cmp.l #'pods',d1
	bne.s .lb20
	sub.l d0,d7
	subq.l #8,d0
	SEEK d0,1			; just jumps
	bra .lb0
.lb20:
	; ************** video/sound codec headers ***********
	cmp.l #'twos',d1	; signed sound
	beq.s .lb201
	cmp.l #'raw ',d1
	beq.s .lb201
	cmp.l #$0000,d1
	bne.s .lb202
	move.l #'raw ',d1
	bra.s .lb201
.lb202:
	cmp.l #'ima4',d1
	beq.s .lb201
	cmp.l #'MAC6',d1
	bne .lb22
.lb201:
	move.l d1,s_signe
;	sub.l d0,d7
	subq.l #8,d0
	cmp.l #1,v_flag
	beq.s .lb21
	sub.l #28,d0
	move.l d0,-(sp)
	SEEK #12,1
	bsr read_long
	cmp.l #'gtel',d0
	seq gtel_sound
	bsr read_long
	move d0,sound_bits
	swap d0
	move d0,channels
	SEEK #4,1
	bsr read_long
	clr d0
	swap d0
	move.l d0,frequency
	move.l (sp)+,d0		; remaining bytes above the 28 standard
.lb21:
	SEEK d0,1
	bra .lb0
	; ************** video codec headers *****************
.lb22:
	cmp.l #'smc ',d1
	bne.s .lb24
.lb23:
	sub.l d0,d7
	subq.l #8,d0
	bra.s .lb21
.lb24:
	cmp.l #'rpza',d1
	beq.s .lb23
	cmp.l #'rle ',d1
	beq.s .lb23
	cmp.l #'cvid',d1
	beq.s .lb23
	; ************** type of trak ************************
	cmp.l #'vmhd',d1
	bne.s .lb25
	move.l #1,v_flag
	lea qt_time,a0
	moveq #-1,d1
	tst.l (a0)
	beq.s .lb24b
	move.l (a0),d1		; timscale yet read
	clr.l (a0)+
.lb24b:
	move.l d1,(a0)
	bra.s .lb23
.lb25:
	cmp.l #'smhd',d1
	bne.s .lb26
	move.l #1,s_flag
	bra.s .lb23
	; ************** ignored for now *********************
.lb26:
	cmp.l #'gmhd',d1
	bne.s .lb26a
	st _vr2_flag		; peut etre un vr2... (pas sur!)
	bra.s .lb23
.lb26a:
	cmp.l #'text',d1
	beq.s .lb23
	cmp.l #'skip',d1
	beq.s .lb23
	cmp.l #'stgs',d1
	beq.s .lb23
	cmp.l #'udta',d1
	beq.s .lb27
	cmp.l #'dinf',d1
	beq .lb23
	; ************* unknown ******************************
	bra .lb23
	; ************* in udta look for NAVG section ********
.lb27:
	sub.l d0,d7
	subq.l #8,d0
	cmp.l #12481,d0
	bpl .lb21		; too large, skip it!
	pea cvid_fix0
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .lb0
	lea cvid_fix0,a0
	clr.l 0(a0,d0.l)		; add a null pointer to stop search
.lb28:
	move.l (a0),d0
	beq .lb0			; nothing found...
	move.l 4(a0),d1
	or.l #$20202020,d1
	cmp.l #'navg',d1
	beq.s .lb29
	add.l d0,a0
	bra.s .lb28
.lb29:
	st vr_flag
	lea vr_info,a1
	move.l 16(a0),(a1)+	; img/cell and time
	move 12(a0),d0	; max_y
	ext.l d0
	moveq #0,d2		; default start_y
	move d0,(a1)+
	move.l 38(a0),d1
	sub.l 34(a0),d1
	cmp.l #360,d1
	spl (a1)			; loop_y
	addq.l #2,a1
	tst.l d1
	beq.s .lb30		; no y movement
	move.l d0,d2
	muls.l 46(a0),d2
	lsl.l #2,d2
	sub.l d1,d2
	lsr.l #2,d2
	divs.l d1,d2
	sub d0,d2
	neg d2
	subq #1,d2
	cmp d0,d2
	bne.s .lb30
	subq #1,d2
.lb30:
	move d2,(a1)+
	move 10(a0),d0	; max_x
	moveq #0,d2		; default start_x
	move d0,(a1)+
	move.l 30(a0),d1
	sub.l 26(a0),d1
	cmp.l #360,d1
	spl (a1)			; loop_x
	addq.l #2,a1
	tst.l d1
	beq.s .lb31		; no x movement
	move.l d0,d2
	muls.l 42(a0),d2
	divs.l d1,d2
	cmp d0,d2
	bne.s .lb31
	subq #1,d2
.lb31:
	move d2,(a1)+
	bra .lb0

	; reads a name
	; D0=size expected
	; if d0=1 we take the size of the string (1 byte) and jump this size
	; if D0>1 we jump d0 bytes

qt_read_name:
	cmp.l #2,d0
	bpl.s .lb0				; 2 or more, normal read
	pea dum
	move.l #1,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	moveq #0,d0
	move.b dum,d0
.lb0:
	SEEK d0,1				; jumps
	rts

moment:
qt_read_stsd:
	bsr read_len_id		; version and num
	tst.b _vr2_flag
	bne qt_read_pano
	cmp.l #1,v_flag
	beq.s .lb0
	rts
.lb0:
	move.l d1,d4			; saves num
	tst.l codecs
	bne.s .lb1
	move.l d1,codec_num
	asl.l #4,d1				; each bloc->16bytes
	bsr malloc
	move.l d0,codecs
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l codec_num,d5	; cur and saves the old num
	add.l d5,d1
	move.l d1,codec_num	; updates the num
	asl.l #4,d1
	bsr malloc				; a new larger block
	move.l codecs,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,codecs		; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+	; copies one codec
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one
.lb3:
	asl.l #4,d5				; the offset for the first codec to read
	move.l codecs,a5
	add.l d5,a5				; adress of the first codec
	moveq #0,d5				; the flag for validity
.lb4:
	bsr read_len_id
	move.l d0,d5			; len
	move.l d1,d6			; id
	SEEK #24,1
	bsr read_word
	move.l d0,(a5)			; width
	bsr read_word
	move.l d0,4(a5)		; height
	SEEK #14,1
	moveq #32,d0
	bsr qt_read_name
	bsr read_long
	move d0,d1				; flag for the palette
	clr d0
	swap d0					; qt_depth
	cmp #32,d0
	beq.s .common			; do not clear bit #5 if 32 planes
	bclr #5,d0				; flag for 'grey'
	beq.s .color
.grey:
	st is_grey
	move d0,grey_depth
	bra.s .common
.color:
	cmp #2,d0
	beq.s .grey				; grey when only 4 colors
.common:
	move.l d0,8(a5)		; into the codec
	sub.l #$56,d5			; updates the len
	move.l #default_pal_16,pal_adr
	cmp #4,d0
	beq.s .lb5
	move.l #default_palette,pal_adr
	cmp #8,d0				; qt_depth = 8?
	bne.s .lb5				; no color map
	btst #3,d1				; default palette?
	bne.s .lb5				; yes, nothing to do
	bsr load_palette
.lb5:
	or.l #$20202020,d6	; to lower case
	move.l d6,comp_txt
	move planes,planes_sav
	tst.b res_switch
	beq.s .aaa
	bmi.s .aab
	move #8,planes			; act like in 256 colors with a TT
	bra.s .aaa
.aab:
	move #16,planes		; act like in TC if we're going to switch
.aaa:
	cmp.l #'cvid',d6
	beq .lb7				; ok
	cmp.l #'smc ',d6
	beq .lb11
	cmp.l #'raw ',d6
	beq .lb12
	cmp.l #'rle ',d6
	beq .lb13
	cmp.l #'rpza',d6
	beq .lb15
	cmp.l #'yuv2',d6
	beq .lb17
	cmp.l #'yuv9',d6
	beq .lb18
	cmp.l #'yvu9',d6
	beq .lb18
	cmp.l #'8bps',d6
	beq .lb19
	cmp.l #'msvc',d6
	beq .lb20
	cmp.l #'wrle',d6
	beq .lb21
	cmp.l #'jpeg',d6
	beq.s .lb66
	cmp.l #'mjpa',d6
	beq.s .lb67
	cmp.l #'mjpb',d6
	beq.s .lb69
	not.l d6
	cmp.l #$9689cccd,d6		; iv32
	beq .lb22
	cmp.l #$9689ccce,d6
	beq .lb22
.lb6:
	st bad_comp
	bra .lb8
.lb69:
	moveq #3,d1				; mjpb
	move.l #4096,mjpg_offset	; place to rebuild whole JPEG with markers
	bra.s .lb69a
.lb67:
	moveq #2,d1				; mjpa
.lb69a:
	move.l #qt_mjpa,d0
	bra.s .lb68
.lb66:
	move.l #qt_jpeg,d0	; jpeg
	moveq #1,d1
.lb68:	
	move.b d1,is_mjpg
	lea qt_raw24,a0
	move.l a0,a1
	cmp #8,planes
	beq.s .mjp2
	tst.b nova
	bne.s .mjp1
	lea qt_raw24_falc,a0
	bra.s .mjp1
.mjp2:
	lea qt_raw24_256,a0
.mjp1:
	move.l a1,mjpg_step_compression
	move.l a0,mjpg_comp
;	move.l #440,mjpg_offset
	clr off_24_32			; 24 bits (for qt_raw)
	move.l d0,a0			; qt_jpeg or qt_mjpa
	move.l a0,a1
	bra .lb8
.lb7:
	move.l #qt_decode_cvid,a0
	move.l a0,a1
	cmp #8,planes
	bne.s .lb71
	move.l #qt_decode_256,a0
.lb71:
	cmp #24,d0				; 24 planes?
	beq .lb8
	cmp #32,d0				; 32 planes?
	bne .lb6           ; if not, unsupported
	bra .lb8
.lb11:
	cmp #8,d0				; depth
	bne .lb6				; unsupported
	st qt_palette
	move.l #qt_smc,a0
	move.l a0,a1
	cmp #8,planes
	bne .lb8
	move.l #qt_smc_256,a0		; or else, it's true color
	bra .lb8
.lb12:
	cmp #1,d0
	bne.s .lb12f				; other depth
	move.b #'1',comp_txt+3	; raw1, monochrome
	move.l #qt_raw1,a0
	move.l a0,a1
	cmp #8,planes
	bne .lb8
	move.l #qt_raw1_256,a0
	bra .lb8
.lb12f:
	cmp #2,d0
	bne.s .lb12g
	move.b #'2',comp_txt+3	; raw2, 4 colors
	st qt_palette
	move.l #qt_raw2,a0
	move.l a0,a1
	cmp #8,planes
	bne .lb8
	move.l #qt_raw2_256,a0
	bra .lb8
.lb12g:
	cmp #4,d0
	bne.s .lb12a				; other depth
	move.b #'4',comp_txt+3	; 'raw4'
	st qt_palette
	move.l #qt_raw4,a0
	move.l a0,a1
	cmp #8,planes
	bne .lb8
	move.l #qt_raw4_256,a0
	bra .lb8
.lb12a:
	cmp #16,d0
	bne.s .lb12b				; other depth
	move.l #'rw16',comp_txt
	move.l #qt_raw16,a1
	move.l #qt_raw16_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	tst.b nova
	bne .lb8
	move.l #qt_raw16_falc,a0
	bra .lb8
.lb12b:
	cmp #24,d0
	bne.s .lb12c				; other depth
	move.l #'rw24',comp_txt
	clr off_24_32
.lb12e:
   move.l #qt_raw24,a1
	move.l #qt_raw24_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	tst.b nova
	bne .lb8
	move.l #qt_raw24_falc,a0
	bra .lb8
.lb12c:
	cmp #32,d0
	bne.s .lb12d
	move #1,off_24_32
	move.l #'rw32',comp_txt
	bra.s .lb12e
.lb12d:
	cmp #8,d0
	bne .lb6				; unsupported depth
	move.b #'8',comp_txt+3	; 'raw8'
	st qt_palette
	move.l #qt_raw,a1
	move.l #qt_raw_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	bra .lb8
.lb13:
	cmp #32,d0
	bne.s .lb13b
	move #1,off_24_32
	move #'32',comp_txt+2
	bra.s .lb13c
.lb13b:
	cmp #24,d0
	bne.s .lb13a
	move #'24',comp_txt+2		; 'rl24'
	clr off_24_32
.lb13c:
	move.l #qt_rle24,a1
	move.l #qt_rle24_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	tst.b nova
	bne .lb8
	move.l #qt_rle24_falc,a0
	bra .lb8
.lb13a:
	cmp #16,d0
	bne.s .lb14
	move #'16',comp_txt+2		; 'rl16'
	move.l #qt_rle16,a1
	move.l #qt_rle16_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	tst.b nova
	bne .lb8
	move.l #qt_rle16_falc,a0
	bra .lb8
.lb14:
	cmp #8,d0
	bne.s .lb14b
	move.b #'8',comp_txt+3		; 'rle8'
	st qt_palette
	move.l #qt_rle8,a1
	move.l #qt_rle8_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	bra .lb8
.lb14b:
	cmp #2,d0
	bne.s .lb14c
	move.b #'2',comp_txt+3
	st qt_palette
	move.l #qt_rle2,a1
	move.l #qt_rle2_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	bra .lb8
.lb14c:
	cmp #4,d0
	bne.s .lb14d
	move.b #'4',comp_txt+3
	st qt_palette
	move.l #qt_rle4,a1
	move.l #qt_rle4_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	bra .lb8
.lb14d:
	cmp #1,d0
	bne .lb6				; unsuported
	move.b #'1',comp_txt+3
	move.l #qt_rle1,a1
	move.l #qt_rle1_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	bra .lb8
.lb15:
	cmp #16,d0
	bne .lb6				; always 16 bits
	move.l #qt_rpza,a1
	cmp #8,planes
	beq.s .lb16
	move.l a1,a0
	tst.b nova
	bne .lb8
	move.l #qt_rpza_falc,a0
	bra .lb8
.lb16:
	move.l #qt_rpza_256,a0
	bra .lb8
.lb17:
	cmp #24,d0
	bmi .lb6				; millions colors needed
	move.l #qt_yuv2,a0
	move.l a0,a1
	cmp #8,planes
	bne .lb8
	move.l #qt_yuv2_256,a0
	bra .lb8
.lb18:
	cmp #24,d0
	bmi .lb6				; millions colors needed
	move.l #qt_yuv9,a0
	move.l a0,a1
	cmp #8,planes
	bne .lb8
	move.l #qt_yuv9_256,a0
	bra .lb8
.lb19:
	cmp #8,d0
	bne .lb6				; unsupported depth
	st qt_palette
	move.l #decode_rgb,a1
	move.l #decode_rgb_256,a0
	cmp #8,planes
	beq .lb8
	move.l a1,a0
	bra .lb8
.lb20:
	move d0,cram_bits	; for init_rect
	cmp #16,d0
	bne.s .c5			; not cram 16
	move.l #decode_cram16,a1
	tst.b is_tt
	bne.s .c4
	tst.b nova
	beq.s .c3
	cmp #8,planes
	beq.s .c4
	move.l a1,a0
	bra .lb8
.c4:
	move.l #decode_cram16_grey,a0
	bra .lb8
.c3:
	move.l #decode_cram16_falc,a0
	bra.s .lb8
.c5:
	cmp #8,d0
	bne .lb6				; unsupported CRAM
	st qt_palette
	move.l #decode_cram8,a1
	cmp #8,planes
	beq.s .c6
	move.l a1,a0
	bra.s .lb8
.c6:
	move.l #decode_cram8_256,a0
	bra.s .lb8
.lb21:
	cmp #8,d0
	bne .lb6				; unsupported depth
	st qt_palette
	move.l #decode_rle8,a1
	move.l #decode_rle8_256,a0
	cmp #8,planes
	beq.s .lb8
	move.l a1,a0
	bra.s .lb8
.lb22:
	cmp #24,d0
	bne .lb6
	move.l #intel_iv32,a1
	move.l #intel_iv32_256,a0
	cmp #16,planes
	bne.s .lb8
		st can_fast
	move.l a1,a0
.lb8:
	move.l a1,step_compression
	move.l a0,12(a5)		; compression routine
	move planes_sav,planes
	SEEK d5,1				; jumps the data
	move.l (a5),d0			; W
	move d0,d1
	addq #3,d0
	and.b #$FC,d0
	move d0,xto4n
	add #15,d0
	and.b #$F0,d0
	sub xto4n,d0
	lsr #2,d0
	move d0,iv32_uv_inc
	lsr #2,d1
	addq #3,d1
	and.b #$fc,d1
	move d1,xqto4n
	move xto4n,d0
	cmp max_imagex,d0
	bmi.s .lb9
	move d0,max_imagex
.lb9:
	move.l 4(a5),d0
	move d0,d1
	addq #3,d0
	and.b #$fc,d0
	move d0,yto4n
	lsr #2,d1
	addq #3,d1
	and.b #$fc,d1
	move d1,yqto4n
	move #$0101,iv32_freq
	move yto4n,d0
	cmp max_imagey,d0
	bmi.s .lb10
	move d0,max_imagey
.lb10:
	lea 16(a5),a5			; next codec
	move.l id_ptr,a0
	move.l comp_txt,(a0)+
	move.w qt_palette,(a0)+
	move.l a0,id_ptr		; keeps every ID (if several are there!)
	subq.l #1,d4
	bne .lb4
	move.l #1,video_flag
	rts

qt_read_pano:
	bsr read_len_id
	or.l #$20202020,d1
	cmp.l #'pano',d1
	bne.s .autre
	move.b #$7F,vr_flag	; true but >0
	pea cvid_fix0
	subq.l #8,d0			; - len, id
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .gloups
	lea cvid_fix0,a0
	lea vr2_data,a1
	move 88(a0),(a1)+		; angle Horizontal
	move 92(a0),(a1)+		; angle haut
	move 96(a0),(a1)+		; angle bas
	move.l 108(a0),d0
	move.l d0,(a1)+	; hauteur panneau
	move.l 112(a0),(a1)+	; largeur panneau
	move.l 116(a0),(a1)+	; images par panneau
	move.l 120(a0),(a1)+	; images par colonne
.commun:
	st vr2_flag				; OUI!!! un VR2...
	lea _vr2_x,a0
	move.l (a0),8(a0)		; copie _vr2_x dans vr2_x et id pour y
	move.l 4(a0),d1		; limite vr2_y a la hauteur du panneau-1
	cmp.l d0,d1
	bmi.s .ok
	move.l d0,d1
	subq.l #1,d1
.ok:
	move.l d1,12(a0)
	rts
.autre:
	cmp.l #'qtvr',d1
	bne.s .gloups
	move.b #$7F,vr_flag	; true but >0
	pea cvid_fix0
	subq.l #8,d0			; - len, id
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi.s .gloups
	;	lea cvid_fix0,a0
	move.l codecs,a0
	lea vr2_data,a1
	move #360,(a1)+
	move #45,(a1)+
	move #-45,(a1)+
	move.l (a0)+,d2
	move.l d2,(a1)+	; largeur image=hauteur panneau
	moveq #24,d1
	move.l (a0)+,d0	; hauteur image
	muls d1,d0		; *24=largeur panneau
	move.l d0,(a1)+
	move.l qtvr_num,d0
	move.l d0,(a1)+
	divs d1,d0
	ext.l d0
	move.l d0,(a1)+
	move.l d2,d0
	bra .commun
.gloups:
	sf _vr2_flag
	rts


load_palette:
	movem.l d0-d2/a0-a2,-(sp)
	move.l d5,d0			; size to read
	cmp.l #2057,d5			; 2*.l + 256 * 8
	bmi.s .lb0
	move.l #2056,d0
.lb0:
	sub.l d0,d5				; updates the len
	pea cvid_fix1
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	lea cvid_fix1,a0		; the palette read
	lea 2056(a0),a1		; the palette for fli_color_256_(256)
	move.l a1,pal_adr
	move.l #$01000000,(a1)+
	move.l (a0)+,d0		; start
	move.l (a0)+,d1		; end
.lb1:
	move (a0)+,d2			; index
	tst.l d1
	bpl.s .toto
	move d0,d2
.toto:
	lea (a1,d2.w*2),a2
	add d2,a2
	move.b (a0),(a2)+
	move.b 2(a0),(a2)+
	move.b 4(a0),(a2)
	addq.l #6,a0			; next color
	addq #1,d0			; one more color
	cmp d0,d1			; the end?
	bpl.s .lb1			; no...
	movem.l (sp)+,d0-d2/a0-a2
	rts

qt_read_stts:
	bsr read_len_id		; version and num
	tst.l video_flag
	bne.s .lb0
	asl.l #3,d1				; each block is 8 bytes long
	SEEK d1,1				; jumps over
	rts
.lb0:
	move.l d1,d4			; saves num
	tst.l t2samps
	bne.s .lb1
	move.l d1,t2samp_num
	asl.l #3,d1				; each bloc->8 bytes
	bsr malloc
	move.l d0,t2samps
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l t2samp_num,d5	; cur and saves the old num
	add.l d5,d1
	move.l d1,t2samp_num	; updates the num
	asl.l #3,d1
	bsr malloc				; a new larger block
	move.l t2samps,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,t2samps		; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+	; copies one t2samp
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one
.lb3:
	asl.l #3,d5				; the offset for the first codec to read
	move.l t2samps,a5
	add.l d5,a5				; adress of the first t2samp
.lb4:
	bsr read_len_id		; count and duration
	move.l d0,(a5)+		; count
	move.l d1,(a5)+		; duration
.lb10:
	subq.l #1,d4			; another t2samp?
	bne.s .lb4					; yes, loop
	rts

qt_read_stss:
	bsr read_len_id		; version and num
	move.l d1,ss_num
	asl.l #2,d1
	tst.l video_flag
	bne.s .lb0
	SEEK d1,1
	rts
.lb0:
	move.l d1,d4			; saves the len to read
	bsr malloc
	move.l d0,ss_tab
	move.l d0,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	rts

qt_read_stsc:
	subq.l #8,d0			; len-8
	move.l d0,d5			; saves
	SEEK #0,1				; current position into d0
	move.l d0,d4			; sauve position
	add.l d0,d5				; whatever happens, we must leave at current+len-16
	move.l d5,-(sp)		; saves
	bsr read_len_id		; version and num
	tst.l video_flag
	bne.s .lb0
	tst.l s_flag
	beq.s .end
	addq.l #4,d4
	addq.l #8,d4
	movem.l d1/d4,snd_size_offs
.end:
	move.l (sp)+,d5
	SEEK d5,0				; jumps over what's not read
	rts
.lb0:
	move.l d1,d4			; saves num
	tst.l s2chunks
	bne.s .lb1
	move.l d1,s2chunk_num
	addq.l #1,d1			; starts at 0, one more block
	muls.l #12,d1			; each bloc->12 bytes
	bsr malloc
	move.l d0,s2chunks
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l s2chunk_num,d5	; cur and saves the old num
	add.l d5,d1
	move.l d1,s2chunk_num	; updates the num
	addq.l #1,d1			; begins at 0, so 1 block more
	muls.l #12,d1			; each block is 12 bytes long
	bsr malloc				; a new larger block
	move.l s2chunks,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,s2chunks	; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+	; copies one s2chunk
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one
.lb3:
	muls.l #12,d5			; the offset for the first s2chunk to fill
	move.l s2chunks,a5
	add.l d5,a5				; adress of the first s2chunk
	move.l codec_num,d5
	sub.l codec_lastnum,d5
.lb4:
	bsr read_long			; first_chk
	add.l chunkoff_lastnum,d0
	subq.l #1,d0
	move.l d0,(a5)+		; first
	bsr read_len_id		; samp_per and chunk_tag
	cmp.l d1,d5
	bpl.s .lb5
	st stsc_invalid
	moveq #1,d0
	moveq #1,d1
.lb5:
	move.l d0,(a5)+		; samp_per into num
	add.l codec_lastnum,d1
	subq.l #1,d1
	move.l d1,(a5)+		; chunk_tag into tag
.lb10:
	subq.l #1,d4			; another t2samp?
	bne.s .lb4					; yes, loop
	bra .end

qt_read_stsz:
	sub.l #20,d0			; len-20
	move.l d0,d5			; saves
	SEEK #4,1				; skips version
	bsr read_len_id		; samp_size and num
	tst.l video_flag
	bne.s .lb0
	tst.b vr2_flag
	beq.s .coucou
	move.l d1,vr2_num		; nombre de lieux
.coucou:
	SEEK d5,1				; jumps over what's not read
	rts
.lb0:
	move.l d0,d3			; for the last loop
	move.l d5,d6			; for the last loop too
	move.l d1,d4			; saves num
	tst.l samp_sizes
	bne.s .lb1
	move.l d1,sample_num
	move.l d1,qtvr_num	; en cas de qtvr...
	asl.l #2,d1				; each bloc->4 bytes
	bsr malloc
	move.l d0,samp_sizes
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l sample_num,d5		; cur and saves the old num
	add.l d5,d1
	move.l d1,sample_num	; updates the num
	asl.l #2,d1					; each block is 4 bytes long
	bsr malloc					; a new larger block
	move.l samp_sizes,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,samp_sizes	; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+	; copies one samp_size
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one
.lb3:
	asl.l #2,d5				; the offset for the first samp_size to fill
	move.l samp_sizes,a5
	add.l d5,a5				; adress of the first samp_size
	move.l a5,a4			; to know if we're on the first samp_size
.lb4:
	tst.l d6					; another samp_size on disk?
	beq.s .lb5				; no, all has been read
	bsr read_long			; else read 4 bytes...
	subq.l #4,d6			; ... and counts them!
	bra.s .lb7
.lb5:
	cmp.l a5,a4				; if all has been readen, is this the first?
	bne.s .lb6				; no
	move.l d3,d0         ; yes, use samp_size (see at the begining)
	bra.s .lb7
.lb6:
	move.l -4(a5),d0		; it's not the first, so use the previous value
.lb7:
	move.l d0,(a5)+	   ; fills the samp_size
	subq.l #1,d4			; another samp_size?
	bne.s .lb4					; yes, loop
	rts

qt_read_stco:
	bsr read_len_id		; version and num
	tst.l video_flag
	bne stco_video
	tst.l s_flag
	bne.s .stco_sound
	asl.l #2,d1				; nor video, neither sound, we skip it!
	SEEK d1,1
	rts
.stco_sound:
	move.l d1,d4			; saves num
	tst.l sound_offs
	bne.s .lb1
	move.l d1,sound_num
	asl.l #3,d1				; each bloc->8 bytes
	bsr malloc
	move.l d0,sound_offs
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l sound_num,d5		; cur and saves the old num
	add.l d5,d1
	move.l d1,sound_num	; updates the num
	asl.l #3,d1					; each block is 8 bytes long
	bsr malloc					; a new larger block
	move.l sound_offs,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,sound_offs	; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+	; copies one chunkoff
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one
.lb3:
	asl.l #3,d5				; the offset for the first chunkoff to fill
	move.l sound_offs,a5
	add.l d5,a5				; adress of the first chunkoff
.lb4:
	bsr read_long			; reads one chunkoff
	move.l d0,(a5)+	   ; and stores it
	addq.l #4,a5
	subq.l #1,d4			; another samp_size?
	bne.s .lb4					; yes, loop
	rts
stco_video:
	move.l d1,d4			; saves num
	tst.l chunkoffs
	bne.s .lb1
	move.l d1,chunkoff_num
	asl.l #2,d1				; each bloc->4 bytes
	bsr malloc
	move.l d0,chunkoffs
	moveq #0,d5				; cur
	bra.s .lb3
.lb1:
	move.l chunkoff_num,d5		; cur and saves the old num
	add.l d5,d1
	move.l d1,chunkoff_num	; updates the num
	asl.l #2,d1					; each block is 4 bytes long
	bsr malloc					; a new larger block
	move.l chunkoffs,a0		; old block
	move.l d0,a1			; new block
	move.l a0,a2			; saves the old bloc (for mfree)
	move.l d0,chunkoffs	; updates the adress
	move.l d5,d1			; old num
.lb2:
	move.l (a0)+,(a1)+	; copies one chunkoff
	subq.l #1,d1			; til the end of the old block
	bne.s .lb2
	bsr mfree				; a2 is the adress of the old one
.lb3:
	asl.l #2,d5				; the offset for the first chunkoff to fill
	move.l chunkoffs,a5
	add.l d5,a5				; adress of the first chunkoff
.lb4:
	pea (a5)
	lsl.l #2,d4
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	rts

; here d3 is used for synchro:
; d3.b:  $FF if synchro, $00 if no synchro
; bit #15: set if a frame has been skipped (display was late)
; bit #31: set if it's a particlar frame (whole screen built), cleared if
;			  the frame is a partial update of the screen.
; bit #16: if set, never skip a key frame
; bit #8	: set when the sound doesn't fit into ST Ram and that there's
;			  a remaining into TT Ram.

areu:
qt_read_data:
	tst.b step_mode
	bne.l qt_step_mode
	bsr.l install_traps
	tst.b vr_flag
	bmi vr_read_data
	bgt vr2_read_data		; ouh la!
.disp_again:
	moveq #0,d3				; resets bits #31, #15, #8
	tst.b playing			; is there a sound?
	beq.s .no_sound
	tst.l s_buffer_2		; a TT Ram remaining?
	beq.s .s2				; no!
	bset #8,d3				; else, sets the bit
.s2:
	pea start_sound
	XBIOS 38,6
.no_sound:
	tst.l samp_sizes
	beq .out
	tst.b bad_comp			; compression supported?
	bne .out					; no, only sound!
	move.b sync,d3
	beq.s .lb0				; no synchronisation
	move.l t2samps,a6		; the sync table
	addq.l #4,a6			; jumps over the dummy address
	tst.b sync+1			; can we skip a key frame?
	beq.s .lb0				; no!
	bset #16,d3
.lb0:
	trap #10
	move.l d0,start_time	; Timer C counter (1/200)
	bsr.l enh_event0
	moveq #0,d6				; current samp
	moveq #0,d5				; current s2chunk
	move.l s2chunks,a4
	move.l 12(a4),a5		; next s2chunk
	move.l 8(a4),d4		; tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
	move.l codecs,a2
	move.l (a2,d0.l),imagex
	move.l 4(a2,d0.l),imagey
	move.l 8(a2,d0.l),depth
	tst.b is_tt
	bne.s .tt
	move.l 12(a2,d0.l),compression
	bra.s .no_tt
.tt:
	move.l 12(a2,d0.l),tt_comp
.no_tt:
	moveq #-1,d7				; i for the loop
	bra .end_of_loop
.loop:
	move.l ([chunkoffs],d7.l*4),d0
	tst.b from_ram
	beq.s .from_file1
	add.l whole_file,d0
	move.l d0,whole_file_ptr
	bra.s .comread1
.from_file1:
	SEEK d0,0	; start of chunk data
.comread1:
	move.l d5,d1
	muls.l #12,d1
	cmp.l d7,a5				; jumps if i<>next_s2chunk
	bne.s .lb4
	move.l d5,d0
	addq.l #1,d0
	sub.l s2chunk_num,d0	; jumps if cur_s2chunk + 1 >= s2chunk_num
	bpl.s .lb4
	addq.l #1,d5			; cur_s2chunk++
	addq.l #8,d1
	addq.l #4,d1			; one bloc more
	move.l 12(a4,d1.l),a5
.lb4:
	move.l 4(a4,d1.l),d2	; num samps
	cmp.l 8(a4,d1.l),d4	; tags equals?
	beq .end_of_samps	; yes, that's ok
	move.l 8(a4,d1.l),d4	; new tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
	move.l (a2,d0.l),imagex
	move.l 4(a2,d0.l),imagey
	move.l 8(a2,d0.l),depth
	move.l 12(a2,d0.l),compression
	bra .end_of_samps
.samp_loop:
	btst #8,d3				; set if there's a sound with remaining into TT ram
	beq.s .no_remain
	tst.b snd_value
	bmi.s .dma_remain
	tst.b yamaha_flag
	bne.s .no_remain
	bsr yamaha_next_sound
	bra.s .no_remain
.dma_remain:
	trap #11
	bne.s .no_remain		; sound not stopped yet
	bsr next_sound
.no_remain:
	move.l samp_sizes,a0
	move.l (a0,d6.l*4),bufused	; size used for the current sample
	cmp.l sample_num,d6	; exit if cur_samp>=sample_num
	bpl .out
	addq.l #1,d6
	tst.w d3					; sync?
	beq .lb1				; no synchro
	bpl.s .pos
	tst.l d3					; bit 31 marked if particular
	bpl.s .skip				; can't come back with a non particular frame
	btst #16,d3				; key frame can be skipped?
	bne.s .lb1				; no, so display it!
	bra.s .pos1
.pos:
	tst.l d3
	bpl.s .pos1				; not a key frame
	btst #16,d3
	bne.s .lb1				; a key frame must be displayed
.pos1:
	trap #10
	sub.l start_time,d0
	cmp.l d0,a3				; address passed?
	bpl.s .lb1				; not yet
	tst d3
	bmi.s .skip
	move.l a6,a0
.search:
	tst.b (a0)				; high byte marked?
	bmi.s .found
	addq.l #4,a0
	bra.s .search
.found:
	move.l -(a0),d0		; the last address for this group
	bclr #31,d0
	cmp.l d1,d0				; passed?
	bpl.s .lb1				; not yet, continue!
	bset #15,d3				; a frame has been skipped
.skip:
	tst.b from_ram
	beq.s .from_file2
	move.l bufused,d0
	add.l d0,whole_file_ptr
	bra .end_of_samps
.from_file2:
	movem.l d2/a2,-(sp)
	SEEK bufused,1			; yes, passed, skip this frame
	movem.l (sp)+,d2/a2
	bra .end_of_samps
.lb1:
	bclr #15,d3
	movem.l d2-d7/a2-a6,-(sp)	; saves registers
	tst.b from_ram
	beq.s .from_file3
	move.l whole_file_ptr,d0
	move.l d0,buffer
	add.l bufused,d0
	move.l d0,whole_file_ptr
	bra.s .from_file4
.from_file3:
	move.l buffer,d0
	add.l mjpg_offset,d0
	move.l d0,-(sp)
	move.l bufused,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
.from_file4:
	tst.b 7(sp)				; sync (d3 on the stack)
	beq.s .lb2
	move.l 40(sp),a0		; a6 on the stack
	move.l -8(a0),d0		; time for previous frame
	bclr #31,d0
	move.l start_time,a0
	add.l d0,a0
.lb33:
	move.l enh_time,d1
.lb3:
	trap #10
	cmp.l d0,d1
	bmi.s .event
	cmp.l d0,a0		; yes, is the previous frame ended?
	bpl.s .lb3				; not yet.
	bra.s .lb2
.event:
	bsr.l enh_event
	bra.s .lb33
.lb2:
	addq.l #1,disp_frame	; counts the frames displayed
	move.l compression,a0
	jsr (a0)					; decodes and displays
	tst.b is_vdi
	beq.s .next
	jsr vdi_display
.next:
	movem.l (sp)+,d2-d7/a2-a6
	btst #2,([kbshift])	; Control key to stop
	bne.s .out3
.end_of_samps:
	tst.b d3
	beq.s .nosync
	bclr #31,d3
	move.l (a6)+,d0
	bpl.s .no_part
	bset #31,d3					; it's a particular frame (whole screen built)
	bclr #31,d0
.no_part:
	move.l d0,a3			; next step (for the synchro)
.nosync:
	subq.l #1,d2
	bpl .samp_loop
	subq.l #4,a6
.end_of_loop:
	addq.l #1,d7			; inc i
	cmp.l chunkoff_num,d7
	bmi .loop
.out:
	btst #2,([kbshift])			; control key to stop
	bne.s .out3
	bsr wait_last
	btst #2,([kbshift])			; control key to stop
	beq.s .out2
.out3:
	st stopped						; stopped, no stats displayed
	tst.b snd_value
	bpl.s .out2_yamaha
	bsr.l clear_dma_sound
	bclr #8,d3
	bra.s .out2
.out2_yamaha:
	bclr #8,d3
	bsr.l clear_yamaha_sound
.out2:
	tst.b snd_value
	beq.s .end
	bmi.s .dma_test
	tst.b yamaha_flag
	bne.s .out
	btst #8,d3
	beq.s .test_repeat
	bsr yamaha_next_sound
	bra.s .out
.dma_test:
	tst.b playing
	beq.s .test_repeat	; don't test DMA if no sound (in case of another player)
	trap #11
	bne.s .out
	btst #8,d3
	beq.s .test_repeat
	bsr next_sound
	bra.s .out
.test_repeat:
	tst.b stopped
	bne.s .end
	tst.b is_rep
	beq.s .end
	tst.b snd_value
	bpl .disp_again		; no DMA so no TT/ST ram problem
	tst.l s_buffer_2		; a TT Ram sound with DMA?
	beq .disp_again		; no, all in ST RAM
	sf playing				; else, no sound with repetition
	bra .disp_again
.end:
	bra.l common_end

wait_last:
	tst.b d3
	beq.s .no_sync
	move.l -4(a6),d0				; last time
	bclr #31,d0
	move.l start_time,a0
	add.l d0,a0
.waitlast:
	trap #10
	cmp.l d0,a0						; yes, is the last frame ended?
	bpl.s .waitlast				; not yet.
.no_sync:
	rts

; MOV files in VR format!!!!

vr_read_data:
	bsr find_offs_size_time
	sf vr_clic
	clr.l vr_keys
	move vr_sx,d6
	ext.l d6
	move vr_sy,d7
	ext.l d7
	move.l kvdbbase,a0
	tst.b vr_clic+1
	bne vr_read_data_mouse
	move.l -(a0),old_ikbd
	move.l #vr_ikbd,(a0)
.loop:
	bsr first_of_cell
.go_on_cell:
	trap #10
	move.l d0,d3
	SEEK (a3)+,0				; offset
	move.l buffer,d0
	add.l mjpg_offset,d0
	move.l d0,-(sp)	
	move.l (a5)+,d0
	move.l d0,-(sp)
	move.l d0,bufused
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
	movem.l d3-d4/d6-d7/a3-a5,-(sp)	; saves registers
	move.l compression,a0
	jsr (a0)					; decodes and displays
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	movem.l (sp)+,d3-d4/d6-d7/a3-a5
	move.l (a4)+,d0
	move.l kbshift,a1
	move.b (a1),d2
	and.b #3,d2
	beq.s .no_fast
	lsr.l #2,d0
.no_fast:
	add.l d0,d3
.delay:
	trap #10
	cmp.l d0,d3
	bpl.s .delay
	lea vr_keys(pc),a2
.wait:
	btst #2,(a1)	; Control key to stop
	bne .stop
	move.l (a2),d0
	bne.s .a_key
	tst.l d4
	bmi.s .wait		; one image per frame
	dbf d4,.go_on_cell
	bra .loop
.a_key:
	movem vr_y,d1-d2
	btst #23,d0
	beq.s .key1
	subq #1,d7		; down
	bpl .loop
	tst d2
	bne.s ._k0
	moveq #0,d7
	bra.s .wait
._k0:
	add d1,d7
	bra .loop
.key1:
	btst #31,d0
	beq.s .key2
	addq #1,d7		; up
	cmp d1,d7
	bmi .loop
	subq #1,d7
	tst d2
	beq.s .wait
	moveq #0,d7
	bra .loop
.key2:
	movem vr_x,d1-d2
	btst #15,d0
	beq.s .key3
	subq #1,d6		; $4D=RIGHT
	bpl .loop
	tst d2
	bne.s ._k2
	moveq #0,d6
	bra.s .wait
._k2:
	add d1,d6
	bra .loop
.key3:
	btst #7,d0
	beq.s .wait
	addq #1,d6		; $4B=LEFT
	cmp d1,d6
	bmi .loop
	subq #1,d6
	tst d2
	beq .wait
	moveq #0,d6
	bra .loop
.stop:
	st stopped
	move.l kvdbbase,a0
	move.l old_ikbd,-(a0)
	bsr.l remove_traps
	rts

vr_xymouse: dc.w 0,0
vr_clic: dc.b 0,0
vr_keys: dc.b 0,0,0,0
vr2_esc: dc.b 0,0				; ESC revient, TAB avance

vr_ikbd:
	lea vr_keys(pc),a0
	cmp.b #$48,d0
	bne.s .lb0
.vrai:
	st (a0)
	rts
.lb0:
	cmp.b #$c8,d0
	bne.s .lb1
.faux:
	sf (a0)
	rts
.lb1:
	addq.l #1,a0
	cmp.b #$50,d0
	beq.s .vrai
	cmp.b #$D0,d0
	beq.s .faux
	addq.l #1,a0
	cmp.b #$4D,d0
	beq.s .vrai
	cmp.b #$CD,d0
	beq.s .faux
	addq.l #1,a0
	cmp.b #$4B,d0
	beq.s .vrai
	cmp.b #$CB,d0
	beq.s .faux
	addq.l #1,a0
	cmp.b #$01,d0	; esc
	beq.s .vrai
	cmp.b #$81,d0
	beq.s .faux
	addq.l #1,a0
	cmp.b #$0F,d0	; tab
	beq.s .vrai
	cmp.b #$8F,d0
	beq.s .faux
	move.l kbshift,a0
	moveq #2,d1
	cmp.b #$1D,d0
	bne.s .lb2
.vrai2:
	bset d1,(a0)
	rts
.lb2:
	cmp.b #$9D,d0
	bne.s .lb3
.faux2:
	bclr d1,(a0)
	rts
.lb3:
	moveq #0,d1
	cmp.b #$2a,d0
	beq.s .vrai2
	cmp.b #$aa,d0
	beq.s .faux2
	moveq #1,d1
	cmp.b #$36,d0
	beq.s .vrai2
	cmp.b #$b6,d0
	beq.s .faux2
	rts

first_of_cell:
	move vr_x,d3
	muls d7,d3
	add.l d6,d3				; index of the cell
	move vr_info,d4
	ext.l d4
	muls.l d4,d3			; index of the image
	lsl.l #2,d3
	move.l s_buffer,a3
	move.l t2samps,a4
	move.l samp_sizes,a5
	add.l d3,a3
	add.l d3,a4
	add.l d3,a5
	subq #1,d4
	bne.s .end
	bset #31,d4
.end:
	rts

find_offs_size_time:
	move.l sample_num,d1
	lsl.l #2,d1
	bsr malloc
	move.l d0,s_buffer
	move.l d0,a3
	moveq #0,d6				; current samp
	moveq #0,d5				; current s2chunk
	move.l s2chunks,a4
	move.l 12(a4),a5		; next s2chunk
	move.l 8(a4),d4		; tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
	move.l codecs,a2
	move.l (a2,d0.l),imagex
	move.l 4(a2,d0.l),imagey
	move.l 8(a2,d0.l),depth
	tst.b is_tt
	bne.s .tt
	move.l 12(a2,d0.l),compression
	bra.s .no_tt
.tt:
	move.l 12(a2,d0.l),tt_comp
.no_tt:
	moveq #-1,d7				; i for the loop
	bra .end_of_loop
.loop:
	move.l ([chunkoffs],d7.l*4),d3	; offset
	move.l d5,d1
	muls.l #12,d1
	cmp.l d7,a5				; jumps if i<>next_s2chunk
	bne.s .lb4
	move.l d5,d0
	addq.l #1,d0
	sub.l s2chunk_num,d0	; jumps if cur_s2chunk + 1 >= s2chunk_num
	bpl.s .lb4
	addq.l #1,d5			; cur_s2chunk++
	addq.l #8,d1
	addq.l #4,d1			; one bloc more
	move.l 12(a4,d1.l),a5
.lb4:
	move.l 4(a4,d1.l),d2	; num samps
	cmp.l 8(a4,d1.l),d4	; tags equals?
	beq.s .end_of_samps	; yes, that's ok
	move.l 8(a4,d1.l),d4	; new tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
;	move.l (a2,d0.l),imagex		; pour l'instant!
;	move.l 4(a2,d0.l),imagey
;	move.l 8(a2,d0.l),depth
;	move.l 12(a2,d0.l),compression
	bra.s .end_of_samps
.samp_loop:
	cmp.l sample_num,d6	; exit if cur_samp>=sample_num
	bpl.s .out
	move.l samp_sizes,a0
	move.l (a0,d6.l*4),d1
	addq.l #1,d6
	move.l d3,(a3)+		; new offset
	add.l d1,d3				; next one
	move.l t2samps,a0
	lea (a0,d6.l*4),a0
	move.l (a0),d1			; end time
	bclr #31,d1
	move.l -(a0),d0		; start time
	clr.l (a0)
	tst.b sync
	beq.s .end_of_samps
	bclr #31,d0
	sub.l d0,d1				; duration
	move.l d1,(a0)
.end_of_samps:
	subq.l #1,d2
	bpl.s .samp_loop
.end_of_loop:
	addq.l #1,d7			; inc i
	cmp.l chunkoff_num,d7
	bmi .loop
.out:
	rts

vr_mouse:
	movem.l d0-d1/a1,-(sp)
	move.b (a0)+,d0
	and.b #3,d0					; buttons
	lea vr_keys(pc),a1
	move.b d0,-2(a1)
	clr.l (a1)
	move.b (a0)+,d0
	ext.w d0						; X movement
	add d0,-6(a1)
	sgt 2(a1)
	smi 3(a1)
	bpl.s .test_y
	neg d0						; absoluteddx
.test_y:
	move.b (a0)+,d1
	ext.w d1
	add d1,-4(a1)
	sgt 1(a1)
	smi (a1)
	bpl.s .next
	neg d1						; absolute dy
.next:
	cmp d0,d1
	bpl.s .keep_y
	clr (a1)						; dx>dy, clear Y infos
	bra.s .fin
.keep_y:
	clr 2(a1)					; dy>dx, clear X infos
.fin:
	movem.l (sp)+,d0-d1/a1
	rts

vr_read_data_mouse:
	move.l 16(a0),old_ikbd
	move.l #vr_mouse,16(a0)
.loop:
	bsr first_of_cell
.go_on_cell:
	trap #10
	move.l d0,d3
	SEEK (a3)+,0				; offset
	move.l buffer,d0
	add.l mjpg_offset,d0
	move.l d0,-(sp)
	move.l (a5)+,d0
	move.l d0,-(sp)
	move.l d0,bufused
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
	movem.l d3-d4/d6-d7/a3-a5,-(sp)	; saves registers
	move.l compression,a0
	jsr (a0)					; decodes and displays
	movem.l (sp)+,d3-d4/d6-d7/a3-a5
	move.l (a4)+,d0
	move.l kbshift,a1
	move.b vr_clic,d2
	beq.s .no_fast
	lsr.l #2,d0
.no_fast:
	add.l d0,d3
.delay:
	trap #10
	cmp.l d0,d3
	bpl.s .delay
	lea vr_keys(pc),a2
.wait:
	btst #2,(a1)	; Control key to stop
	bne .stop
	move.l (a2),d0
	bne.s .a_key
	tst.l d4
	bmi.s .wait		; one image per frame
	dbf d4,.go_on_cell
	bra .loop
.a_key:
	clr.l (a2)		; read once, then cleared
	movem vr_y,d1-d2
	btst #23,d0
	beq.s .key1
	subq #1,d7		; down
	bpl .loop
	tst d2
	bne.s ._k0
	moveq #0,d7
	bra.s .wait
._k0:
	add d1,d7
	bra .loop
.key1:
	btst #31,d0
	beq.s .key2
	addq #1,d7		; up
	cmp d1,d7
	bmi .loop
	subq #1,d7
	tst d2
	beq.s .wait
	moveq #0,d7
	bra .loop
.key2:
	movem vr_x,d1-d2
	btst #15,d0
	beq.s .key3
	subq #1,d6		; $4D=RIGHT
	bpl .loop
	tst d2
	bne.s ._k2
	moveq #0,d6
	bra.s .wait
._k2:
	add d1,d6
	bra .loop
.key3:
	btst #7,d0
	beq.s .wait
	addq #1,d6		; $4B=LEFT
	cmp d1,d6
	bmi .loop
	subq #1,d6
	tst d2
	beq .wait
	moveq #0,d6
	bra .loop
.stop:
	st stopped
	move.l kvdbbase,a0
	move.l old_ikbd,16(a0)
	bsr.l remove_traps
	rts

vr2_read_data:
	bsr find_offs_size_time
	tst.b is_tt
	beq.s .pas_tt
	move.l compression,a0
	move.l tt_comp,compression
	lea 22(a0),a0
	move.l a0,tt_comp
.pas_tt:
	bsr.l install_traps
	sf vr_clic
	clr.l vr_keys
	clr vr2_esc
	moveq #-1,d0
	move.l d0,vr2_index
	move.l vr2_temp,image	; image into TEMP
	move.l kvdbbase,a0
	tst.b vr_clic+1
	bne.s .mouse1
	move.l -(a0),old_ikbd
	move.l #vr_ikbd,(a0)
	bra.s .loop
.mouse1:
	move.l 16(a0),old_ikbd
	move.l #vr_mouse,16(a0)
.loop:
	bsr first_of_pano
	move.l screenw,vr2_save_screen
	move.l max_imagex,screenw	; temp a la meme taille que l'image
.go_on_pano:
	SEEK (a3)+,0				; offset
	move.l buffer,d0
	add.l mjpg_offset,d0
	move.l d0,-(sp)
	move.l (a5)+,d0
	move.l d0,-(sp)
	move.l d0,bufused
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
	movem.l d5/a3/a5,-(sp)	; saves registers
	move.l compression,a0
	jsr (a0)					; decode dans TEMP
	movem.l (sp)+,d5/a3/a5
	bsr vr2_save_image
	dbf d5,.go_on_pano
	move.l vr2_save_screen,screenw
	move.l vr2_sx,d6
	move.l vr2_sy,d7		; positions de depart
.voir:
	trap #10
	move.l d0,a4
	bsr vr2_display
	tst.b is_vdi
	beq.s .no_vdi
	movem.l a0-a4/d0-d6,-(sp)
	jsr vdi_display
	movem.l (sp)+,a0-a4/d0-d6
.no_vdi:
	tst.b is_tt
	beq.s .no_tt
	movem.l a4/d6-d7,-(sp)
	move.l vr2_y,a3
	move.l tt_comp,a1
	move.l vr2_image,a0
	moveq #0,d0
	jsr (a1)
	movem.l (sp)+,a4/d6-d7
.no_tt:
	move.l a4,d3
	move.l _delay,d0
	lsr.l #2,d0
	move.l kbshift,a1
	tst.b vr_clic+1
	bne.s .mouse2
	move.b (a1),d2
	and.b #3,d2
	beq.s .no_fast
	bra.s .fast
.mouse2:
	move.b vr_clic(pc),d2
	btst #1,d2
	beq.s .no_fast
.fast:
	lsr.l #2,d0
.no_fast:
	add.l d0,d3
.delay:
	trap #10
	cmp.l d0,d3
	bpl.s .delay
	lea vr_keys(pc),a2
.wait:
	btst #2,(a1)	; Control key to stop
	bne .stop
	move.l (a2),d0
	bne.s .a_key
	tst.b vr_clic+1
	bne.s .mouse3
	move 4(a2),d0
	bne .loop
	bra.s .wait
.mouse3:
	btst #0,vr_clic
	bne .loop		; if escape, other panel
	bra.s .wait
.a_key:
	tst.b vr_clic+1
	beq.s .no_mouse1
	clr.l (a2)		; with mouse: read once
	move.l vr2_maxy,d1
	move.l -6(a2),d0
	clr.l -6(a2)
	asl #4,d0
	add d0,d7
	bpl.s .m0
	moveq #1,d7
	bra.s .xmov
.m0:
	cmp d1,d7
	bmi.s .xmov
	move d1,d7
	subq #1,d7
.xmov:
	move.l vr2_maxx,d1
	swap d0
	asl #4,d0
	add d0,d6
	bpl.s .m1
	tst.b vr_xloop
	bne.s .m2
	moveq #0,d6
	bra .voir
.m2:
	add d1,d6
	bmi.s .m2
	bra .voir
.m1:
	tst.b vr_xloop
	bne.s .m3
	cmp d1,d6
	bmi .voir
	move d1,d6
	bra .voir
.m3:
	cmp d1,d6
	bmi .voir
	sub d1,d6
	bra.s .m3
.no_mouse1:
	move.l vr2_maxy,d1
	btst #31,d0
	beq.s .key1
	sub #16,d7		; down
	bgt .voir
	tst.b vr_yloop
	bne.s ._k0
	moveq #1,d7
	bra .voir
._k0:
	add d1,d7
	bra .loop
.key1:
	btst #23,d0
	beq.s .key2
	add #16,d7		; up
	cmp d1,d7
	bmi .voir
	move d1,d7
	tst.b vr_yloop
	beq .voir
	moveq #1,d7
	bra .voir
.key2:
	move.l vr2_maxx,d1
	btst #7,d0
	beq.s .key3
	sub #16,d6		; $4D=RIGHT
	bpl .voir
	tst.b vr_xloop
	bne.s ._k2
	moveq #0,d6
	bra .voir
._k2:
	move.l d1,d6
	bra .voir
.key3:
	btst #15,d0
	beq .wait
	add #16,d6		; $4B=LEFT
	cmp d1,d6
	bmi .voir
	move.l d1,d6
	tst.b vr_xloop
	beq .voir
	moveq #0,d6
	bra .voir
.stop:
	st stopped
	move.l kvdbbase,a0
	moveq #16,d0
	tst.b vr_clic+1
	bne.s .mouse4
	moveq #-4,d0
.mouse4:
	move.l old_ikbd,0(a0,d0)
	bsr.l remove_traps
	rts

first_of_pano:
	move.l vr2_index,d3
	addq.l #1,d3
	cmp.l vr2_num,d3
	bmi.s .ok
	moveq #0,d3
.ok:
	move.l d3,vr2_index
	move.l vr2_data+14,d5	; nombre d'images par panneau
	muls.l d5,d3	; index de la premiere image du panneau
	lsl.l #2,d3
	move.l s_buffer,a3
	move.l t2samps,a4
	move.l samp_sizes,a5
	add.l d3,a3
	add.l d3,a4
	move.l (a4),_delay
	add.l d3,a5
	subq #1,d5				; pour la boucle
	clr.l vr2_col_offy
	move.l vr2_data+10,d0
	sub max_imagey,d0
	move.l d0,vr2_col_offx
	rts

vr2_save_image:
	move max_imagey,d7
	ext.l d7
	move.l vr2_panneau,a1
	move.l a1,a2
	move max_imagex,d6
	move.l vr2_data+10,d3	; largeur
	move.l vr2_col_offy,d1
	muls d3,d1
	sub.l d7,d3					; increment horizontal
	add.l vr2_col_offx,d1
	add.l d1,a1
	move d6,d2
	subq #1,d2
	subq #1,d7
	cmp #8,planes
	beq.s .c256
	add.l d1,a1
	add.l	d3,d3
	add.l d6,d6
.lb1:
	move d7,d0
	move.l a2,a0				; saves
.lb0
	sub d6,a0
	move (a0),(a1)+
	dbf d0,.lb0
	add.l d3,a1
	addq.l #2,a2
	dbf d2,.lb1
	bra.s .new_offset
.c256:
	move d7,d0
	move.l a2,a0				; saves
.clb0
	sub d6,a0
	move.b (a0),(a1)+
	dbf d0,.clb0
	add.l d3,a1
	addq.l #1,a2
	dbf d2,.c256
.new_offset:
	move.l vr2_col_offy,d0
	add max_imagex,d0			; new offset
	cmp.l vr2_data+6,d0		; =hauteur pano?
	bmi.s .good					; oui, retour a zero.
	moveq #0,d0
	move max_imagey,d0
	sub.l d0,vr2_col_offx
	moveq #0,d0
.good:
	move.l d0,vr2_col_offy
	rts

vr2_display:
	move.l vr2_image,a3		; ecran
	move.l vr2_data+10,d0
	move.l d0,d3				; largeur
	muls d7,d0
	add.l d6,d0					; offset dans tableau
	move.l vr2_panneau,a0
	move.l vr2_x,d4
	move.l vr2_y,d5
	tst.b vr2_def
	bne.s vr2_disp_def
	sub.l d4,d3					; inc pour tableau
	move screenw,d1
	sub d4,d1					; inc pour ecran
	ext.l d1
	subq #1,d4
	subq #1,d5
	add.l d0,a0
	cmp #8,planes
	beq.s .c256
	add.l d0,a0
	add.l d1,d1
	add.l d3,d3
.lb1:
	move d4,d2
.lb0:
	move (a0)+,(a3)+
	dbf d2,.lb0
	add.l d3,a0
	add.l d1,a3
	dbf d5,.lb1
	rts
.c256:
	move d4,d2
.clb0:
	move.b (a0)+,(a3)+
	dbf d2,.clb0
	add.l d3,a0
	add.l d1,a3
	dbf d5,.c256
	rts
vr2_disp_def:
	movem.l d6-d7,-(sp)
	moveq #0,d6
	move.l d7,d1
	add.l d7,d1
	move.l d5,d2
	add.l d5,d2
	add.l d5,d2		; global effect with 3*window height
	sub.l d2,d1
	muls.l d4,d1
	bpl.s .areu1
	moveq #-1,d6
.areu1:
	swap d1
	move d1,d6
	clr d1
	lsl.l #3,d2
	dc.w $4c42,$1c06		; divsl.l d2,d6:d1
	move.l d1,a2			; x de depart en WORD,WORD
	lsr.l #3,d2
	add.l d7,d7
	moveq #0,d6
	sub.l d5,d7
	muls.l d4,d7
	neg.l d7
	bpl.s .areu2
	moveq #-1,d6
.areu2:
	move.l d5,d1
	muls.l d2,d1
	add.l d1,d1
	swap d7
	move d7,d6
	clr d7
	dc.w $4c41,$7c06		;	divsl.l d1,d6:d7		; dx en WORD,WORD
	exg.l a2,d7
	move screenw,d1
	sub d4,d1
	ext.l d1						; increment pour ecran
	subq #1,d5
	add.l d0,a0
	cmp #8,planes
	beq.s .clb1
	add.l d0,a0
	add.l d1,d1
	add.l d3,d3
.lb1:
	move.l d4,d2				; longueur normale
	swap d2
	sub.l d7,d2
	sub.l d7,d2
	swap d2						; nouvelle longueur
	swap d7
	move.l a0,a1				; save pos
	add d7,a0
	add d7,a0
	move.l a0,d6
	bclr #0,d6
	move.l d6,a0
	moveq #0,d6
	cmp d4,d2
	beq.s .copie
	lea 0(a3,d4.l*2),a5			; end of line (for A3)
	bpl.s .reduire
.agrandir:
	move (a0)+,d0
.ag0:
	move d0,(a3)+
	cmp.l a5,a3
	beq.s .fin_ligne
	add d2,d6
	cmp d4,d6
	bmi.s .ag0
	sub d4,d6
	bra.s .agrandir
.r0:
	addq.l #2,a0
	add d4,d6
	cmp d2,d6
	bmi.s .r0
.reduire:
	sub d2,d6
	move (a0),(a3)+
	cmp.l a3,a5
	bne.s .r0
	bra.s .fin_ligne
.c0:
	move (a0)+,(a3)+
.copie:
	dbf d2,.c0
.fin_ligne:
	lea 0(a1,d3.l),a0			; nouvelle ligne
	swap d7
	add.l a2,d7
	add.l d1,a3
	dbf d5,.lb1
	movem.l (sp)+,d6-d7
	rts
.clb1:
	move.l d4,d2				; longueur normale
	swap d2
	sub.l d7,d2
	sub.l d7,d2
	swap d2						; nouvelle longueur
	swap d7
	move.l a0,a1				; save pos
	add d7,a0
	moveq #0,d6
	cmp d4,d2
	beq.s .ccopie
	lea 0(a3,d4.l),a5			; end of line (for A3)
	bpl.s .creduire
.cagrandir:
	move.b (a0)+,d0
.cag0:
	move.b d0,(a3)+
	cmp.l a5,a3
	beq.s .cfin_ligne
	add d2,d6
	cmp d4,d6
	bmi.s .cag0
	sub d4,d6
	bra.s .cagrandir
.cr0:
	addq.l #1,a0
	add d4,d6
	cmp d2,d6
	bmi.s .cr0
.creduire:
	sub d2,d6
	move.b (a0),(a3)+
	cmp.l a3,a5
	bne.s .cr0
	bra.s .cfin_ligne
.cc0:
	move.b (a0)+,(a3)+
.ccopie:
	dbf d2,.cc0
.cfin_ligne:
	lea 0(a1,d3.l),a0			; nouvelle ligne
	swap d7
	add.l a2,d7
	add.l d1,a3
	dbf d5,.clb1
	movem.l (sp)+,d6-d7
	rts

yamaha_next_sound:
	lea s_buffer_2,a0		; TT ram buffer (one time)
	bclr #8,d3				; no more remaining
	pea yamaha_start_sound	; play it!
	XBIOS 38,6
	rts

next_sound:
	move.l snd_pos,a0
	move.l ttram_size,d0
	beq .end
	move.l stram_size,d1
	move.l d1,a1				; saves it
	cmp #2,channels
	bne.s .lb5
	asr.l #1,d1					; if stereo, 2 bytes for one sample
.lb5:
	muls.l #200,d1
	divs.l real_freq,d1		; number of 1/200 that have been played
	add.l d1,timer_c
	move.l a1,d1				; the stram size again
	cmp.l d0,d1
	bpl.s .lb0
	sub.l d1,ttram_size		; the remaining shrinks
	add.l d1,snd_pos			; updates the position
	bra.s .copy
.lb0:
	move.l d0,d1				; the size to copy
	bclr #8,d3					; there's no more remaining
.copy:
	move.l s_buffer,a1		; the ST Ram buffer
	move.l d1,d0
	lsr.l #4,d1					; blocs of 16 bytes
	and #$F,d0					; the remaining bytes
	bra.s .lb2
.lb1:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
.lb2:
	subq.l #1,d1
	bpl.s .lb1
	bra.s .lb4
.lb3:
	move.b (a0)+,(a1)+
.lb4:
	dbf d0,.lb3
	move.l a1,snd_end
	pea start_sound
	XBIOS 38,6
	trap #10
	sub.l timer_c,d0
	bpl.s .lb6
	moveq #0,d0
.lb6:
	move.l start_time,d1
	move.l d0,start_time
	sub.l d1,d0		; time added
	add.l d0,enh_time	; same offset for enhanced timing
	bra.s .out
.end:
	bclr #8,d3
.out:
	rts

start_sound:
	lea s_buffer,a0
	tst.b snd_value
	bpl yamaha_start_sound
	addq.l #1,a0
	move.b (a0)+,$ffff8903.w
	move.b (a0)+,$ffff8905.w
	move.b (a0),$ffff8907.w	; start address
	lea snd_end+1,a0
_start_sound_common:
	move.b (a0)+,$ffff890f.w
	move.b (a0)+,$ffff8911.w
	move.b (a0),$ffff8913.w	; end address
	moveq #0,d0				; sound mode control
	cmp #2,channels
	beq.s .s1				; stereo, bit 7 is 0
	moveq #-128,d0			; else, bit 7 is 1
.s1:
	move.l frequency,d1
	addq #1,d0				; 1 for 12,5 kHz
	cmp.l #12517,d1
	beq.s .start
	addq #1,d0
	cmp.l #25033,d1		; 2 for 25 kHz
	beq.s .start
	addq #1,d0				; else 3 for 50 kHz
.start:
	move.b d0,$ffff8921.w		; sound mode control
	move.b #1,$ffff8901.w		; starts the sound!
	move.l $4ba.w,d0
	add.l real_freq_tab+12,d0			; delay to start (mostly for Aranym)
.start_delay:
	cmp.l $4ba.w,d0
	bpl.s .start_delay
	rts


vq_extnd: dc.l ve_cont,ve_int,dum,intout,ptsout

flm_start_sound:
	lea snd_temp,a0
	tst.b snd_value
	bpl.s yamaha_start_sound	; no DMA!!!!
	clr.b $ffff8901.w
	addq.l #1,a0
	move.b (a0)+,$ffff8903.w
	move.b (a0)+,$ffff8905.w
	move.b (a0),$ffff8907.w	; start address
	lea flm_snd_end+1,a0
	bra _start_sound_common

yamaha_start_sound:
	move.l (a0),yamaha_ptr
	move sr,d0
	move.w	#$2700,sr
	move.l	#inull,$134.w
	lea $ffff8800.w,a0
	lea 2(a0),a1
	move.b	#0,(a0)
	move.b	#0,(a1)
	move.b	#1,(a0)
	move.b	#0,(a1)
	move.b	#2,(a0)
	move.b	#0,(a1)
	move.b	#3,(a0)
	move.b	#0,(a1)
	move.b	#4,(a0)
	move.b	#0,(a1)
	move.b	#5,(a0)
	move.b	#0,(a1)
	move.b	#7,(a0)
	move.b	#$FF,(a1)
	move.b	#8,(a0)
	move.b	#0,(a1)
	move.b	#9,(a0)
	move.b	#0,(a1)
	move.b	#10,(a0)
	move.b	#0,(a1)
	st yamaha_flag
	lea $fffffa00.w,a0					; save MFP
	bclr #5,7(a0)
	bclr #5,$13(a0)
	move.b	#1,$19(a0)		; control
	tst.b psnd_flag			; parallel sound card
	bne.s .coucou
 	move.b	#64,$1F(a0)		; data
	move.l	#yamaha_replay,$134.w
	bra.s .common
.coucou:
	move.b #32,$1f(a0)
	move.l #psnd_replay,$134.w
.common:
	bclr.b	#3,$17(a0)
	bset #5,7(a0)
	bset #5,$13(a0)
	move.w	d0,sr
	rts

yamaha_ptr: dc.l yamaha_dum
yamaha_dum: dc.w 0

inull: rte

stop_timer:
	move sr,d0
	move #$2700,sr
	lea $fffffa00.w,a0
	bclr #5,7(a0)
	bclr #5,$b(a0)
	bclr #5,$f(a0)
	bclr #5,$13(a0)
	move.l #inull,$134.w
	sf yamaha_flag
	move d0,sr
	rts

psnd_replay:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move.l yamaha_ptr(pc),a0
	move.l #$07ff0f00,d0
	move.b (a0)+,d0
	beq.s .end_replay
	eor.b #$80,d0
	move.l a0,yamaha_ptr
	move.l d0,.save_previous
	lea $FFFF8800.w,a0
	movep.l d0,0(a0)
	move.l #.psnd2,$134.w
.exit_int:
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte
.end_replay:
	bsr.s stop_timer
	bra.s .exit_int
.save_previous: dc.l 0
.psnd2:
	move.l a0,-(sp)
	move.l d0,-(sp)
	move d1,-(sp)
	move.l yamaha_ptr(pc),a0
	move.l .save_previous(pc),d0
	move.b (a0),d1
	lea $FFFF8800.w,a0
	eor.b #$80,d1
	move.l #psnd_replay,$134.w
	add.b d1,d0
	roxr.b d0
	move (sp)+,d1
	movep.l d0,0(a0)
	move.l (sp)+,d0
	move.l (sp)+,a0
	rte

yamaha_replay:
	movem.l d0/a0-a1,-(sp)
	move.l yamaha_ptr(pc),a0
	moveq #0,d0
	move.b (a0)+,d0
	beq.s .end_replay
	move.l d0,a1
	move.l a0,yamaha_ptr
	add.l a1,d0
	lea $ffff8800.w,a0
	add.l a1,d0
	lea yamaha_data(pc,d0.w),a1
	move.b #8,(a0)
	move.b (a1)+,2(a0)
	move.b #9,(a0)
	move.b (a1)+,2(a0)
	move.b #10,(a0)
	move.b (a1),2(a0)
.exit_int:
	movem.l (sp)+,d0/a0-a1
	rte
.end_replay:
	bsr stop_timer
	bra.s .exit_int

yamaha_data:
	dc.b	$C,$B,$9,$C,$B,$9
	dc.b	$D,$8,$8,$B,$B,$B
	dc.b	$D,$9,$5,$C,$B,$8
	dc.b	$D,$9,$2,$D,$8,$6
	dc.b	$C,$B,$7,$D,$7,$7
	dc.b	$C,$B,$6,$C,$A,$9
	dc.b	$B,$B,$A,$C,$B,$2
	dc.b	$C,$B,$0,$C,$A,$8
	dc.b	$D,$6,$4,$D,$5,$5
	dc.b	$D,$5,$4,$C,$9,$9
	dc.b	$D,$4,$3,$B,$B,$9
	dc.b	$C,$A,$5,$B,$A,$A
	dc.b	$C,$9,$8,$B,$B,$8
	dc.b	$C,$A,$0,$C,$A,$0
	dc.b	$C,$9,$7,$B,$B,$7
	dc.b	$C,$9,$6,$B,$B,$6
	dc.b	$B,$A,$9,$B,$B,$5
	dc.b	$A,$A,$A,$B,$B,$2
	dc.b	$B,$A,$8,$C,$7,$7
	dc.b	$C,$8,$4,$C,$7,$6
	dc.b	$B,$9,$9,$C,$6,$6
	dc.b	$A,$A,$9,$C,$7,$3
	dc.b	$B,$A,$5,$B,$9,$8
	dc.b	$B,$A,$3,$A,$A,$8
	dc.b	$B,$A,$0,$B,$9,$7
	dc.b	$B,$8,$8,$A,$A,$7
	dc.b	$A,$9,$9,$C,$1,$1
	dc.b	$A,$A,$6,$B,$8,$7
	dc.b	$A,$A,$5,$A,$9,$8
	dc.b	$A,$A,$2,$A,$A,$1
	dc.b	$A,$A,$0,$9,$9,$9
	dc.b	$A,$8,$8,$B,$8,$1
	dc.b	$A,$9,$6,$B,$7,$4
	dc.b	$A,$9,$5,$9,$9,$8
	dc.b	$A,$9,$3,$A,$8,$6
	dc.b	$A,$9,$0,$9,$9,$7
	dc.b	$9,$8,$8,$A,$8,$4
	dc.b	$9,$9,$6,$A,$8,$1
	dc.b	$9,$9,$5,$9,$8,$7
	dc.b	$8,$8,$8,$9,$9,$2
	dc.b	$9,$8,$6,$9,$9,$0
	dc.b	$9,$7,$7,$8,$8,$7
	dc.b	$9,$7,$6,$9,$8,$2
	dc.b	$8,$8,$6,$9,$6,$6
	dc.b	$8,$7,$7,$8,$8,$4
	dc.b	$8,$7,$6,$8,$8,$2
	dc.b	$7,$7,$7,$8,$6,$6
	dc.b	$8,$7,$4,$7,$7,$6
	dc.b	$8,$6,$5,$8,$6,$4
	dc.b	$7,$6,$6,$7,$7,$4
	dc.b	$8,$5,$4,$6,$6,$6
	dc.b	$7,$6,$4,$7,$5,$5
	dc.b	$6,$6,$5,$6,$6,$4
	dc.b	$6,$5,$5,$6,$6,$2
	dc.b	$6,$5,$4,$5,$5,$5
	dc.b	$6,$5,$2,$5,$5,$4
	dc.b	$5,$4,$4,$5,$5,$2
	dc.b	$4,$4,$4,$4,$4,$3
	dc.b	$4,$4,$2,$4,$3,$3
	dc.b	$3,$3,$3,$3,$3,$2
	dc.b	$3,$2,$2,$2,$2,$2
	dc.b	$2,$2,$1,$1,$1,$1
	dc.b	$2,$1,$0,$1,$1,$0
	dc.b	$1,$0,$0,$0,$0,$0
	dc.b	$E,$D,$C,$F,$3,$0
	dc.b	$F,$3,$0,$F,$3,$0
	dc.b	$F,$3,$0,$F,$3,$0
	dc.b	$F,$3,$0,$E,$D,$B
	dc.b	$E,$D,$B,$E,$D,$B
	dc.b	$E,$D,$B,$E,$D,$B
	dc.b	$E,$D,$B,$E,$D,$B
	dc.b	$E,$D,$A,$E,$D,$A
	dc.b	$E,$D,$A,$E,$D,$A
	dc.b	$E,$C,$C,$E,$D,$0
	dc.b	$D,$D,$D,$D,$D,$D
	dc.b	$D,$D,$D,$D,$D,$D
	dc.b	$D,$D,$D,$D,$D,$D
	dc.b	$E,$C,$B,$E,$C,$B
	dc.b	$E,$C,$B,$E,$C,$B
	dc.b	$E,$C,$B,$E,$C,$B
	dc.b	$E,$C,$B,$E,$C,$B
	dc.b	$E,$C,$A,$E,$C,$A
	dc.b	$E,$C,$A,$E,$C,$A
	dc.b	$D,$D,$C,$D,$D,$C
	dc.b	$E,$C,$9,$E,$C,$9
	dc.b	$E,$C,$5,$E,$C,$0
	dc.b	$E,$C,$0,$E,$B,$B
	dc.b	$E,$B,$B,$E,$B,$B
	dc.b	$E,$B,$B,$E,$B,$A
	dc.b	$E,$B,$A,$E,$B,$A
	dc.b	$D,$D,$B,$D,$D,$B
	dc.b	$D,$D,$B,$E,$B,$9
	dc.b	$E,$B,$9,$E,$B,$9
	dc.b	$D,$C,$C,$D,$D,$A
	dc.b	$E,$B,$7,$E,$B,$0
	dc.b	$E,$B,$0,$D,$D,$9
	dc.b	$D,$D,$9,$E,$A,$9
	dc.b	$D,$D,$8,$D,$D,$7
	dc.b	$D,$D,$4,$D,$D,$0
	dc.b	$E,$A,$4,$E,$9,$9
	dc.b	$E,$9,$9,$D,$C,$B
	dc.b	$E,$9,$8,$E,$9,$8
	dc.b	$E,$9,$7,$E,$8,$8
	dc.b	$E,$9,$1,$C,$C,$C
	dc.b	$D,$C,$A,$E,$8,$6
	dc.b	$E,$7,$7,$E,$8,$0
	dc.b	$E,$7,$5,$E,$6,$6
	dc.b	$D,$C,$9,$E,$5,$5
	dc.b	$E,$4,$4,$D,$C,$8
	dc.b	$D,$B,$B,$E,$0,$0
	dc.b	$D,$C,$6,$D,$C,$5
	dc.b	$D,$C,$2,$C,$C,$B
	dc.b	$C,$C,$B,$D,$B,$A
	dc.b	$D,$B,$A,$D,$B,$A
	dc.b	$D,$B,$A,$C,$C,$A
	dc.b	$C,$C,$A,$C,$C,$A
	dc.b	$D,$B,$9,$D,$B,$9
	dc.b	$D,$A,$A,$D,$A,$A
	dc.b	$D,$A,$A,$C,$C,$9
	dc.b	$C,$C,$9,$C,$C,$9
	dc.b	$D,$B,$6,$C,$B,$B
	dc.b	$C,$C,$8,$D,$B,$0
	dc.b	$D,$B,$0,$C,$C,$7
	dc.b	$C,$C,$6,$C,$C,$5
	dc.b	$C,$C,$3,$C,$C,$1
	dc.b	$C,$B,$A,$D,$A,$5
	dc.b	$D,$A,$4,$D,$A,$2
	dc.b	$D,$9,$8,$D,$9,$8

ve_cont: dc.w 102,0,0,1,0,0,0,0,0,0,0,0
ve_int: dc.w 1
vq_extnd2: dc.l ve_cont,ve_int2,dum,cvid_fix0,cvid_fix1
ve_int2: dc.w 2

	; ************* creates two routines very similar *****************
	; the first with c256=0  --> high color display
	; the second withcc256=1---> 256 grey
	; only a few lines change (if c256=..., comditional assembly)

c256 set 0			; first loop, c256=0

	rept 2			; two times

	if c256=0		; the name of the routine changes
qt_decode_cvid:
	else
qt_decode_256:
	endif

	move.l buffer,a2		; the datas
	clr x
	clr y
	clr y_top
	move screenw,d3
	move d3,d4
	if c256=0
		subq #3,d3			; row_inc
		add d3,d3				; one pixel=2bytes in true color mode
	else
		subq #4,d3
	endif
	asl #2,d4
	move max_imagex,d2
	addq #3,d2
	and.b #$fc,d2
	sub d2,d4	; y_inc
	if c256=0
		add d4,d4				; one pixel=2bytes in true color mode
	endif
	move.l image,a3		; the screen

	move.l (a2)+,d2
	and.l #$FFFFFF,d2		; the len
	move.l bufused,d1
	bmi.s .lbgood			; avi file!!!
	cmp.l d1,d2				; compared to the expected len
	beq.s .lbgood
	addq.l #1,d2			; try to correct
	cmp.l d1,d2				; correction failed?
	bne .out					; yes, we must get out!
.lbgood:
	addq.l #4,a2
	moveq #0,d2
	move (a2)+,d2			; strips
	move.l cvid_map_num,d1
	cmp.l d2,d1
	bpl.s .lb1
	; verify cvid max strips
	move.l d1,d5
	lea (cvid_maps0,d5.l*4),a4
	lea (cvid_vmap0,d5.l),a5
.lb0:
	move.l #2080,d0
	muls.l d5,d0
	add.l #cvid_fix1,d0
	move.l d0,24(a4)
	sf 6(a5)
	move.l #2080,d0
	muls.l d5,d0
	add.l #cvid_fix0,d0
	move.l d0,(a4)+
	sf (a5)+
	addq.l #1,d5
	cmp.l d2,d5
	bmi.s .lb0
.lb1:
	move.l d2,cvid_map_num
	moveq #0,d5								; kk for a loop
.lb2:
	move.l (cvid_maps0,d5.l*4),a4
	move.l (cvid_maps1,d5.l*4),a5
	lea (cvid_vmap0,d5.l),a6
	tst.b (a6)								; vmap = false?
	bne.s .lb5								; non, skip
	move.l a4,a1							; dest
	move.l d5,d0
	bne.s .lb3
	move.l d2,d0
.lb3:
	subq.l #1,d0							; kk-1 or if kk=0, strips-1
	move.l (cvid_maps0,d0.l*4),a0		; source
	st.b (a6)								; vmap=true
	moveq #63,d0
.lb4:
   move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbf d0,.lb4
.lb5:
	tst.b 6(a6)								; vmap = false?
	bne.s .lb8								; non, skip
	move.l a5,a1							; dest
	move.l d5,d0
	bne.s .lb6
	move.l d2,d0
.lb6:
	subq.l #1,d0							; kk-1 or if kk=0, strips-1
	move.l (cvid_maps1,d0.l*4),a0		; source
	st.b 6(a6)								; vmap=true
	moveq #63,d0
.lb7:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbf d0,.lb7
.lb8:
	addq.l #2,a2
	moveq #0,d6
	move (a2)+,d6			; topsize
	addq.l #4,a2
	move (a2)+,d0			; y1
	addq.l #2,a2
	add d0,y_top			; works better???
	move screenh,d0
	cmp y_top,d0			; under the screen?
	bpl.s .good_height	; no, ok
	move d0,y_top			; else, this is the limit
.good_height:
	subq.l #8,d6
	subq.l #4,d6			; topsize-12
	sub x,a3				; image-x
	if c256=0
		sub x,a3			; one pixel=2bytes
	endif
	clr x
.lb9:
	tst.l d6
	bls .end_while       ; while topsize>0
	move (a2)+,d0			; cid
	moveq #0,d1
	move (a2)+,d1			; csize
	sub.l d1,d6				; topsize-csize
	subq.l #4,d1
	cmp #$2000,d0
	beq.s .case0
	cmp #$2200,d0
	bne.s .next1
	move.l a5,a0				; cvid_map
	move.l cvid_map_num,d0
	lea (cvid_vmap1,d0.l),a6
	bra.s .lb10
.case0:
	move.l a4,a0				; cvid_map
	move.l cvid_map_num,d0
	lea (cvid_vmap0,d0.l),a6
.lb10:
	subq.l #1,d0
	bmi.s .comm0
	cmp.l d0,d5
	seq.b -(a6)					; set true only vmap(kk)
	bra.s .lb10
.comm0:
	if c256=0
		move.l hc_cvid,a1
	endif
	cmp.l #6,d1
	bmi.s .lb9
.lb11:
	if c256=0
		moveq #0,d0
		move.b 4(a2),d0
		lsl #5,d0
		move.b 5(a2),d0
		and.w #$1FF8,d0
		lsl.l #6,d0					; cr
		lea (a1,d0.l),a6			; hc_cvid[cr]
		moveq #0,d0
		move.b (a2)+,d0			; y1
		move.w (a6,d0.w*2),(a0)+	; fills	cvid_map
		move.b (a2)+,d0			; y2
		move.w (a6,d0.w*2),(a0)+
		move.b (a2)+,d0			; y3
		move.w (a6,d0.w*2),(a0)+
		move.b (a2)+,d0			; y4
		move.w (a6,d0.w*2),(a0)+
	else
		rept 2
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		swap d0
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		not.l d0
		move.l d0,(a0)+
		endr
	endif
	addq.l #2,a2				; skips cr
	subq.l #6,d1				; csize-6
	bgt.s .lb11
	if c256=0
		bra .lb9
	else
		bra.s .lb9
	endif
.next1:
	cmp #$2100,d0
	beq.s .case1
	cmp #$2300,d0
	bne.s .next2
	move.l a5,a0
	bra.s .gloups
.case1:
   move.l a4,a0
.gloups:
	move.l d2,-(sp)			; saves d2
.comm1:
	tst.l d1
	bmi.s .lb16
	beq.s .lb16					; while csize>0
	move.l (a2)+,d7			; flag
	subq.l #4,d1				; csize-4
	if c256=0
		move.l hc_cvid,a1
	endif
	moveq #31,d2				; mask
.lb15:
	btst d2,d7					; mask and flag?
	beq.s .lb13
.lb12:
	if c256=0
		moveq #0,d0
		move.b 4(a2),d0
		lsl #5,d0
		move.b 5(a2),d0
		and.w #$1FF8,d0
		lsl.l #6,d0					; cr
		lea (a1,d0.l),a6			; hc_cvid[cr]
		moveq #0,d0
		move.b (a2)+,d0			; y1
		move.w (a6,d0.w*2),(a0)+	; fills	cvid_map
		move.b (a2)+,d0			; y2
		move.w (a6,d0.w*2),(a0)+
		move.b (a2)+,d0			; y3
		move.w (a6,d0.w*2),(a0)+
		move.b (a2)+,d0			; y4
		move.w (a6,d0.w*2),(a0)+
	else
		rept 2
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		swap d0
		move.b (a2),d0
		ror #8,d0
		move.b (a2)+,d0
		not.l d0
		move.l d0,(a0)+
		endr
	endif
	addq.l #2,a2				; skips cr
	subq.l #6,d1				; csize-6
	bra.s .lb14
.lb13:
	addq.l #8,a0
.lb14:
	dbf d2,.lb15				; mask-1
	bra.s .comm1					; while csize
.lb16:
	move.l (sp)+,d2			; restores d2
	; verify csize=0
	bra .lb9
.next2:
	cmp #$3000,d0
	bne .next3
	move.l d2,-(sp)			; saves strips
.lb17:
	tst.l d1
	beq .lb22
	bmi .lb22					; while csize>0
	move y,d0
	cmp y_top,d0
	bpl .lb22					; and while y < ytop
	move.l (a2)+,d7			; flag
	subq.l #4,d1				; csize-4
	moveq #31,d2				; mask
.lb20:
	move y,d0
	cmp y_top,d0
	bpl .lb21
	btst d2,d7					; mask and flag?
	beq.s .lb23
	moveq #0,d0
	move.b (a2)+,d0		; d0
	lea (a4,d0.w*8),a0	; cv_map_d0
	move.b (a2)+,d0		; d1
	lea (a4,d0.w*8),a1	; cv_map_d1
	move.l a3,a6			; ip_ptr
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)+
	endif
	add d3,a6
	move.b (a2)+,d0		; d2
	lea (a4,d0.w*8),a0	; cv_map_d3
	move.b (a2)+,d0		; d4
	lea (a4,d0.w*8),a1	; cv_map_d4
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)
	endif
	subq.l #4,d1				; csize-4
	bra.s .lb18
.lb23:
	moveq #0,d0
	move.b (a2)+,d0		; d
	lea (a5,d0.w*8),a0	; cv_map_d
	move.l a3,a6			; the screen
	move.l (a0)+,d0		; d0 up and d1 down
	if c256=0
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
	else
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)
	endif
	subq.l #1,d1
.lb18:
	addq #4,x
	if c256=0
		addq.l #8,a3				; each pixel is 2 bytes
	else
		addq.l #4,a3
	endif
	move x,d0
	cmp max_imagex,d0
	bmi.s .lb19
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
.lb19:
	dbf d2,.lb20
.lb21:
	cmp.l #4,d1
	bpl .lb17
.lb22:
	add.l d1,a2					; dptr + csize
	move.l (sp)+,d2			; restores d2
	bra .lb9
.next3:
	cmp #$3200,d0
	if c256=0
		bne .next4
	else
		bne.s .next4
	endif
.lb24:
	tst.l d1
	beq.s .lb25
	bmi.s .lb25					; while csize>0
	move y,d0
	cmp y_top,d0
	bpl.s .lb25					; and while y < ytop
	moveq #0,d0
	move.b (a2)+,d0		; d
	lea (a5,d0.w*8),a0	; cv_map_d
	move.l a3,a6			; the screen
	move.l (a0)+,d0		; d0 up and d1 down
	if c256=0
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
	else
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)
	endif
	subq.l #1,d1				; csize-1
	addq #4,x
	if c256=0
		addq.l #8,a3				; each pixel is 2 bytes
	else
		addq.l #4,a3
	endif
	move x,d0
	cmp max_imagex,d0
	bmi.s .lb24
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
	bra.s .lb24
.lb25:
	add.l d1,a2					; dptr + csize
	bra .lb9
.next4:
	cmp #$3100,d0
	beq.s .case4
	cmp #$3300,d0
;	bne .lb9
	bne .out
	;****
.case4:
	st flag0
	sf flag1
	sf flag2
	move.l d2,-(sp)			; saves strips
.lb26:
	tst.l d1
	beq .lb27
	bmi .lb27					; while csize>0
	move y,d0
	cmp y_top,d0
	bpl .lb27					; and while y < ytop
	move.l (a2)+,d7			; flag
	subq.l #4,d1				; csize-4
	moveq #31,d2				; mask
.lb28:
	move y,d0
	cmp y_top,d0
	bpl.s .lb26					; end d2 loop and go to while
	btst d2,d7					; mask and flag?
	bne .mcode23
	subq #1,d2
	btst d2,d7
	if c256=0
		bne .mcode1
	else
		bne.s .mcode1
	endif
	st flag0						; here mcode = 00
	tst.b flag1
	beq.s .lb29
	moveq #0,d0
	move.b (a2)+,d0		; d
	lea (a5,d0.w*8),a0	; cv_map_d
	move.l a3,a6			; the screen
	move.l (a0)+,d0		; d0 up and d1 down
	if c256=0
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
	else
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)
	endif
	subq.l #1,d1
.lb29:
	sf flag1
.lb33:
	addq #4,x
	if c256=0
		addq.l #8,a3				; each pixel is 2 bytes
	else
		addq.l #4,a3
	endif
	move x,d0
	cmp max_imagex,d0
	bmi .end_mcode
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
	bra .end_mcode
.mcode1:							; here mcode = 01
	st flag1
	tst.b flag2
	bne.s .lb30
	tst.b flag0
	beq.s .lb31
.lb30:
	sf flag0
	sf flag2
	bra .end_mcode
.lb31:
	moveq #0,d0
	move.b (a2)+,d0		; d
	lea (a5,d0.w*8),a0	; cv_map_d
	move.l a3,a6			; the screen
	move.l (a0)+,d0		; d0 up and d1 down
	if c256=0
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
		add d3,a6				;+ row_inc
		swap d0					; d0
		move d0,(a6)+
		move d0,(a6)+
		swap d0					; d1
		move d0,(a6)+
		move d0,(a6)
	else
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l (a0),d0			; d0 up and d1 down
		move.l d0,(a6)+
		add d3,a6				;+ row_inc
		move.l d0,(a6)
	endif
	subq.l #1,d1
	bra .end_mcode
.mcode23:
	subq #1,d2
	btst d2,d7
	bne.s .mcode3
	st flag2						; here mcode = 10 (2)
	tst.b flag1
	beq.s .lb31
	moveq #0,d0
	move.b (a2)+,d0		; d0
	lea (a4,d0.w*8),a0	; cv_map_d0
	move.b (a2)+,d0		; d1
	lea (a4,d0.w*8),a1	; cv_map_d1
	move.l a3,a6			; ip_ptr
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)+
	endif
	add d3,a6
	move.b (a2)+,d0		; d2
	lea (a4,d0.w*8),a0	; cv_map_d3
	move.b (a2)+,d0		; d4
	lea (a4,d0.w*8),a1	; cv_map_d4
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)
	endif
	subq.l #4,d1
	bra .lb29
.mcode3:							; here mcode = 11 (3)
	moveq #0,d0
	move.b (a2)+,d0		; d0
	lea (a4,d0.w*8),a0	; cv_map_d0
	move.b (a2)+,d0		; d1
	lea (a4,d0.w*8),a1	; cv_map_d1
	move.l a3,a6			; ip_ptr
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)+
	endif
	add d3,a6
	move.b (a2)+,d0		; d2
	lea (a4,d0.w*8),a0	; cv_map_d3
	move.b (a2)+,d0		; d4
	lea (a4,d0.w*8),a1	; cv_map_d4
	if c256=0
		move (a0)+,(a6)+
		move (a0)+,(a6)+
		move (a1)+,(a6)+
		move (a1)+,(a6)
		add d3,a6				; +row_inc
		move (a0)+,(a6)+
		move (a0),(a6)+
		move (a1)+,(a6)+
		move (a1),(a6)
	else
		move.b (a0),(a6)+
		move.b 2(a0),(a6)+
		move.b (a1),(a6)+
		move.b 2(a1),(a6)+
		add d3,a6
		move.b 4(a0),(a6)+
		move.b 6(a0),(a6)+
		move.b 4(a1),(a6)+
		move.b 6(a1),(a6)
	endif
	subq.l #4,d1
.end_mcode:
	addq #4,x
	if c256=0
		addq.l #8,a3				; each pixel is 2 bytes
	else
		addq.l #4,a3
	endif
	move x,d0
	cmp max_imagex,d0
	bmi.s .lb32
	clr x
	addq #4,y
	add d4,a3					; image + y_inc
.lb32:
	dbf d2,.lb28				; end of d2 loop
	bra .lb26					; returns to while
.lb27:
	add.l d1,a2					; dptr + csize
	move.l (sp)+,d2			; restores d2
	bra .lb9
.end_while:
	addq.l #1,d5			; kk++
	cmp.l d2,d5
	bmi .lb2					; loops if kk<strips
.out:
	rts

	if c256=0
qt_smc:
	lea cvid_fix0,a6
	else
qt_smc_256:
	endif
	clr x
	clr y
	clr smc_8
	clr smc_a
	clr smc_c
	move screenw,d3
	subq #4,d3
	if c256=0
		add d3,d3					; row_inc
	endif
	move.l buffer,a2
	move.l (a2)+,d0
	and.l #$ffffff,d0
	cmp.l bufused,d0
	bmi.s .ok_size
	move.l bufused,d0
.ok_size:
	subq.l #4,d0
	add.l a2,d0			; end adress
	bra.s .while
.exit:
	rts
.while:
	cmp.l d0,a2
	bpl.s .exit
.lb0:
	moveq #0,d1
	move.b (a2)+,d1			; code
	cmp #$20,d1
	bpl.s .case2
	cmp #$10,d1
	bmi.s .lb1
	move.b (a2)+,d1			; cnt if hicode=1
	bra.s .lb2
.lb1:
	and #$f,d1					; cnt if hicode=0
.lb2:
	move max_imagex,d2
.lb3:
	addq #4,x
	cmp x,d2
	bgt.s .lb4
	clr x
	addq #4,y
.lb4:
	dbf d1,.lb3
	bra.s .while
.case2:
	cmp #$40,d1
	bpl.s .case4
	cmp #$30,d1
	bmi.s .lb5
	move.b (a2)+,d1
	bra.s .lb6
.lb5:
	and #$f,d1
.lb6:
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
		lea -8(a3),a4			; last bloc, o_tmp
	else
		add.l d2,a3
		lea -4(a3),a4
	endif
	tst x
	bne.s .lb7
	move screenw,d2
	neg d2
	if c256=0
		lea (a4,d2.w*8),a4	; one line up
		add d3,a4
		addq.l #8,a4			; end of line
	else
		lea (a4,d2.w*4),a4
		add d3,a4
		addq.l #4,a4
	endif
.lb7:
	if c256=0
		bsr qt_smc_o2i
	else
		bsr qt_smc_o2i_256
	endif
	dbf d1,.lb7
	bra .while
.case4:
	cmp #$60,d1
	bpl .case6
	cmp #$50,d1
	bmi.s .lb8
	move.b (a2)+,d1
	bra.s .lb9
.lb8:
	and #$f,d1
.lb9:
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
		lea -16(a3),a5			; o2tmp (2 blocs)
	else
		add.l d2,a3
		lea -8(a3),a5
	endif
	move x,d4				; mtx
	move y,d5				; mty
	subq #8,d4
	bpl.s .lb10
	add max_imagex,d4
	subq #4,d5
	move screenw,d2
	neg d2
	if c256=0
		lea (a5,d2.w*8),a5	; one line up
		add d3,a5
		addq.l #8,a5			; end of line
	else
		lea (a5,d2.w*4),a5
		add d3,a5
		addq.l #4,a5
	endif
.lb10:
	move.l a5,a4
	moveq #0,d6
	move d4,d6
	move d5,d7
	if c256=0
		bsr qt_smc_o2i
		addq #4,d6				; tx
		addq.l #8,a4
	else
		bsr qt_smc_o2i_256
		addq #4,d6
		addq.l #4,a4
	endif
	move max_imagex,d2
	cmp d6,d2
	bgt.s .lb11
	moveq #0,d6
	addq #4,d7
	move.l image,a3
	move d7,d2
	muls screenw,d2
	add.l d6,d2
	if c256=0
		lea (a4,d2.l*2),a4	; o_tmp
	.lb11:
		bsr qt_smc_o2i
	else
		add.l d2,a4
	.lb11:
		bsr qt_smc_o2i_256
	endif
	dbf d1,.lb10
	bra .while
.case6:
	cmp #$80,d1
	bpl.s .case8
	cmp #$70,d1
	bmi.s .lb12
	move.b (a2)+,d1
	bra.s .lb13
.lb12:
	and #$f,d1
.lb13:
	if c256=0
		moveq #0,d4
		move.b (a2)+,d4	; ct
		move.w (a6,d4.w*2),d4	; true color
	else
		move.b (a2)+,d4
		move.b d4,d2
		lsl #8,d4
		move.b d2,d4
	endif
	move d4,d2
	swap d4
	move d2,d4					; into high word
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	.lb14:
		bsr qt_smc_c1
	else
		add.l d2,a3
	.lb14:
		bsr qt_smc_c1_256
	endif
	dbf d1,.lb14
	bra .while
.case8:
	cmp #$a0,d1
	bpl .casea
	lea cvid_fix1,a0
	moveq #0,d2
	cmp #$90,d1
	bpl.s .lb15
	move.b smc_8+1,d2
	if c256=0
		lea (a0,d2.w*4),a0
		addq #1,smc_8
		move.b (a2)+,d2
		move (a6,d2.w*2),(a0)
		move.b (a2)+,d2
		move (a6,d2.w*2),2(a0)
	else
		lea (a0,d2.w*2),a0
		addq #1,smc_8
		move.b (a2)+,(a0)
		move.b (a2)+,1(a0)
	endif
	bra.s .lb16
.lb15:
	move.b (a2)+,d2
	if c256=0
		lea (a0,d2.w*4),a0
	else
		lea (a0,d2.w*2),a0
	endif
.lb16:
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
		and #$f,d1				; cnt
		move (a0)+,d4
		move (a0)+,d5			; c0, c1
	else
		add.l d2,a3
		and #$f,d1
		move.b (a0)+,d4
		move.b (a0)+,d5
	endif
.lb17:
	move.l a3,a0
	move.b (a2)+,d6		; msk0
	if c256=0
		bsr qt_smc_c2
	else
		bsr qt_smc_c2_256
	endif
	move.b (a2)+,d6		; msk1
	add d3,a0
	if c256=0
		bsr qt_smc_c2
	else
		bsr qt_smc_c2_256
	endif
	addq #4,x
	if c256=0
		addq.l #8,a3
	else
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb18
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.lb18:
	dbf d1,.lb17
	bra .while
.casea:
	cmp #$c0,d1
	bpl .casec
	lea cvid_fix1+1024,a0
	moveq #0,d2
	cmp #$b0,d1
	bpl.s .lb19
	move.b smc_a+1,d2
	if c256=0
		lea (a0,d2.w*8),a0
		addq #1,smc_a
		move.b (a2)+,d2
		move (a6,d2.w*2),(a0)
		move.b (a2)+,d2
		move (a6,d2.w*2),2(a0)
		move.b (a2)+,d2
		move (a6,d2.w*2),4(a0)
		move.b (a2)+,d2
		move (a6,d2.w*2),6(a0)
	else
		lea (a0,d2.w*4),a0
		addq #1,smc_a
		move.b (a2)+,(a0)+
		move.b (a2)+,(a0)+
		move.b (a2)+,(a0)+
		move.b (a2)+,(a0)
		subq.l #3,a0
	endif
	bra.s .lb20
.lb19:
	move.b (a2)+,d2
	if c256=0
		lea (a0,d2.w*8),a0
	else
		lea (a0,d2.w*4),a0
	endif
.lb20:
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
	and #$f,d1				; cnt
.lb21:
	move.l a3,a1
	move.l (a2)+,d4		; mask0-3
	if c256=0
		bsr qt_smc_c4
		addq #4,x
		addq.l #8,a3
	else
		bsr qt_smc_c4_256
		addq #4,x
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb22
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.lb22:
	dbf d1,.lb21
	bra .while
.casec:
	cmp #$e0,d1
	bpl .casee
	lea cvid_fix1+3072,a0
	moveq #0,d2
	cmp #$d0,d1
	bpl.s .lb23
	move.b smc_c+1,d2
	lea (a0,d2.w*8),a0
	if c256=0
		lea (a0,d2.w*8),a0
		addq #1,smc_c
		rept 8
		move.b (a2)+,d2
		move (a6,d2.w*2),(a0)+
		endr
		sub #16,a0
	else
		addq #1,smc_c
		rept 8
		move.b (a2)+,(a0)+
		endr
		subq.l #8,a0
	endif
	bra.s .lb24
.lb23:
	move.b (a2)+,d2
	lea (a0,d2.w*8),a0
	if c256=0
		lea (a0,d2.w*8),a0
	endif
.lb24:
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
	and #$f,d1				; cnt
.lb25:
	move.l a3,a1
	move (a2)+,d6
	if c256=0
		bsr qt_smc_c8
	else
		bsr qt_smc_c8_256
	endif
	move d6,d7
	move (a2)+,d6
	if c256=0
		bsr qt_smc_c8
	else
		bsr qt_smc_c8_256
	endif
	lsr #4,d6
	or d6,d7
	move (a2)+,d6
	if c256=0
		bsr qt_smc_c8
	else
		bsr qt_smc_c8_256
	endif
	lsr #8,d6
	or d7,d6
	if c256=0
		bsr qt_smc_c8
		addq #4,x
		addq.l #8,a3
	else
		bsr qt_smc_c8_256
		addq #4,x
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb26
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.lb26:
	dbf d1,.lb25
	bra .while
.casee:						; $ex
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
	and #$f,d1				; cnt
	moveq #0,d4
.lb27:
	move.l a3,a1
	rept 4
	rept 4
	if c256=0
		move.b (a2)+,d4
		move (a6,d4.w*2),(a1)+
	else
		move.b (a2)+,(a1)+
	endif
	endr
	add d3,a1
	endr
	addq #4,x
	if c256=0
		addq.l #8,a3
	else
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .lb28
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.lb28:
	dbf d1,.lb27
	bra .while

	if c256=0
qt_smc_c8:
	else
qt_smc_c8_256
	endif
	rept 4
	moveq #0,d2
	lsl #1,d6
	roxl #1,d2
	lsl #1,d6
	roxl #1,d2
	lsl #1,d6
	roxl #1,d2
	if c256=0
		move (a0,d2.w*2),(a1)+
	else
		move.b (a0,d2.w),(a1)+
	endif
	endr
	add d3,a1
	rts

	if c256=0
qt_smc_c4:
	else
qt_smc_c4_256:
	endif
	moveq #3,d5
.lb0:
	rept 4
	moveq #0,d2
	lsl.l #1,d4
	roxl #1,d2
	lsl.l #1,d4
	roxl #1,d2
	if c256=0
		move.w (a0,d2.w*2),(a1)+
	else
		move.b (a0,d2.w),(a1)+
	endif
	endr
	add d3,a1
	dbf d5,.lb0
	rts

	if c256=0
qt_smc_c2:
	btst #7,d6
	beq.s .lb0
	move d5,(a0)+
	bra.s .lb1
.lb0:
	move d4,(a0)+
.lb1:
	btst #6,d6
	beq.s .lb2
	move d5,(a0)+
	bra.s .lb3
.lb2:
	move d4,(a0)+
.lb3:
	btst #5,d6
	beq.s .lb4
	move d5,(a0)+
	bra.s .lb5
.lb4:
	move d4,(a0)+
.lb5:
	btst #4,d6
	beq.s .lb6
	move d5,(a0)+
	bra.s .lb7
.lb6:
	move d4,(a0)+
.lb7:
	add d3,a0
	btst #3,d6
	beq.s .lb8
	move d5,(a0)+
	bra.s .lb9
.lb8:
	move d4,(a0)+
.lb9:
	btst #2,d6
	beq.s .lb10
	move d5,(a0)+
	bra.s .lb11
.lb10:
	move d4,(a0)+
.lb11:
	btst #1,d6
	beq.s .lb12
	move d5,(a0)+
	bra.s .lb13
.lb12:
	move d4,(a0)+
.lb13:
	btst #0,d6
	beq.s .lb14
	move d5,(a0)+
	rts
.lb14:
	move d4,(a0)+
	rts

	else

qt_smc_c2_256:
	btst #7,d6
	beq.s .lb0
	move.b d5,(a0)+
	bra.s .lb1
.lb0:
	move.b d4,(a0)+
.lb1:
	btst #6,d6
	beq.s .lb2
	move.b d5,(a0)+
	bra.s .lb3
.lb2:
	move.b d4,(a0)+
.lb3:
	btst #5,d6
	beq.s .lb4
	move.b d5,(a0)+
	bra.s .lb5
.lb4:
	move.b d4,(a0)+
.lb5:
	btst #4,d6
	beq.s .lb6
	move.b d5,(a0)+
	bra.s .lb7
.lb6:
	move.b d4,(a0)+
.lb7:
	add d3,a0
	btst #3,d6
	beq.s .lb8
	move.b d5,(a0)+
	bra.s .lb9
.lb8:
	move.b d4,(a0)+
.lb9:
	btst #2,d6
	beq.s .lb10
	move.b d5,(a0)+
	bra.s .lb11
.lb10:
	move.b d4,(a0)+
.lb11:
	btst #1,d6
	beq.s .lb12
	move.b d5,(a0)+
	bra.s .lb13
.lb12:
	move.b d4,(a0)+
.lb13:
	btst #0,d6
	beq.s .lb14
	move.b d5,(a0)+
	rts
.lb14:
	move.b d4,(a0)+
	rts

	endif

	if c256=0
qt_smc_o2i:
	else
qt_smc_o2i_256:
	endif
	move.l a3,a0		; dest
	move.l a4,a1		; source
	rept 3
		move.l (a1)+,(a0)+
		if c256=0
			move.l (a1)+,(a0)+
		endif
		add d3,a0
		add d3,a1
	endr
	if c256=0
		move.l (a1)+,(a0)+
	endif
	move.l (a1),(a0)
	addq #4,x
	if c256=0
		addq.l #8,a3
	else
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .end
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.end:
	rts

	if c256=0
qt_smc_c1:
	else
qt_smc_c1_256
	endif
	move.l a3,a0		; dest
	rept 3
		if c256=0
			move.l d4,(a0)+
		endif
		move.l d4,(a0)+
		add d3,a0
	endr
	if c256=0
		move.l d4,(a0)+
	endif
	move.l d4,(a0)
	addq #4,x
	if c256=0
		addq.l #8,a3
	else
		addq.l #4,a3
	endif
	move max_imagex,d2
	cmp x,d2
	bgt.s .end
	clr x
	addq #4,y
	move.l image,a3
	move y,d2
	muls screenw,d2
	add.l x-2,d2
	if c256=0
		lea (a3,d2.l*2),a3	; i_tmp
	else
		add.l d2,a3
	endif
.end:
	rts

	if c256=0
intel_iv32:
	else

xqto4n: dc.w 0
yqto4n: dc.w 0
xto4n: dc.w 0
yto4n: dc.w 0
iv32_uv_inc: dc.w 0
iv32_entry: dc.l 0
iv32_freq: dc.w $0101

intel_iv32_256:
	endif
 MOVE.L buffer,A2
 move.l 12(a2),d0
 INTEL d0			; size of frame
 cmp.l #50,d0
 bmi .gloups2
 lea 16(a2,d0.l),a1	; end of frame
 LEA 16+2(A2),A2	;+2 => version
 MOVE (A2)+,D0	;flags
 MOVE.L (A2)+,D5	;lecture d'un .Li ->D5 =8*taille donn‚es utiles
 MOVEQ #0,D7
 MOVE.B (A2)+,D7 ; cboffset
 ADDQ.l #3,A2	;saute cbset
 MOVE (A2)+,D6	;hauteur
 ROR #8,D6	;format intel => motorola
 CMP max_imagey,D6
 BNE .fin
 swap d6
 MOVE (A2)+,D6	;largeur
 ROR #8,D6	;format intel -> motorola
 CMP max_imagex,D6
 BNE .fin ; bad dimensions
 MOVEM.L (A2)+,D2-D4	;lit les 3 offsets
 INTEL d2
 INTEL d3
 INTEL d4
 ADDQ.l #4,A2
 MOVE.L A2,A5		; a5=buffer+48
 CMP.L #128,D5
 beq .fin ; bad dimensions
 LEA -32(A5,D2.L),A0	;offset donn‚es Y
 MOVE.L (A0)+,D1	;1.Li
 INTEL d1
 lea iv32_ptrs,a3
 lea 12(a3),a2
 BTST #1,D0	;buffer swapping
 Bne.S .lb43
 exg.l a2,a3
.lb43:
 MOVE D6,D2	;largeur anim
 CMP #160,D6
 BLS.S .lb45
 MOVE #160,D2
.lb45:  MOVE D2,-(SP)	;largeur bloc
 MOVE.L A0,-(SP)	;donn‚es Y
 MOVE.L A5,-(SP)	;donn‚es entˆte
 MOVE d7,-(SP)	;cboffset
 pEA (A0,D1.L*2)	;donn‚es compress‚s
 swap d6
 MOVE.l d6,-(SP)	; x and y at the same time
 MOVE.L (A3),-(SP)	;ybuf
 MOVE.L (A2),-(SP)
 move.l iv32_entry(pc),a0
 jsr (a0)
 LEA 28(SP),SP

 if c256=0
		bne .fin	; plan Y
		tst.b fast_mode
		bne .fast_display

 LEA -32(A5,D3.L),A0	;offset donn‚es U
 MOVE.L (A0)+,D1
 INTEL d1
 MOVEQ #0,D6
 move xqto4n(pc),d2
 CMP #40,D2
 BLS.S .lb47
 MOVEQ #40,D2
.lb47:  MOVE D2,-(SP)	;largeur bloc
 MOVE.L A0,-(SP)	;donn‚es U
;
 MOVE.L A5,-(SP)	;donn‚es entˆte
 MOVE d7,-(SP)	;cboffset
; subq.l #6,sp
 pea (a0,d1.l*2)	;donn‚es compress‚s
 MOVE.l xqto4n(pc),-(SP)	;hauteur/4 + largeur
 MOVE.L 8(A3),-(SP)
 MOVE.L 8(A2),-(SP)
 move.l iv32_entry(pc),a0
 jsr (a0)
 LEA 28(SP),SP
 Bne .fin	; plan U
 LEA -32(A5,D4.L),A0	;offset donn‚es V
 MOVE.L (A0)+,D1
 INTEL d1
;
 MOVE D2,-(SP)	;largeur bloc
; subq.l #2,sp
 MOVE.L A0,-(SP)	;donn‚es V
;
 MOVE.L A5,-(SP)	;donn‚es entˆte
 MOVE d7,-(SP)	;cboffset
; subq.l #6,sp
 pea (a0,d1.l*2)	;donn‚es compress‚s
;
 move.l xqto4n(pc),-(sp)
; subq.l #4,sp
 MOVE.L 4(A3),-(SP)
 MOVE.L 4(A2),-(SP)
 move.l iv32_entry(pc),a0
 jsr (a0)
 LEA 28(SP),SP
 Bne .fin	; plan V
 move iv32_freq(pc),d0
 subq.b #1,d0
 beq.s .on_affiche
 move d0,iv32_freq
 rts							; n'affiche pas
.on_affiche:
 lsr #8,d0
 move.b d0,iv32_freq+1	; reset counter
 MOVE.L (A2)+,A0	;source tableau y
 MOVE.L (A2)+,A6	;source tableau u
 MOVE.L (A2),A5	;source tableau v
 move.l hc_cvid,a1	; conversion
 move.l image,a3
	move xto4n(pc),d0
	move yto4n(pc),d7
	subq #4,d0
	lsr #2,d7
	move screenw,d3
	subq #4,d3
	move iv32_uv_inc(pc),d5
	add d3,d3			; screen inc
	move #$1FF8,d4
	moveq #0,d1
 bra .line_loop
.line:
	move d0,d5
	lsr #2,d5
	bra.s .skip_init
.one_bloc:
	move.l a2,a3
	move.l d2,a0
.skip_init:
 moveq #0,d6
 move.b (a6)+,d6
 lsl #6,d6
 move.b (a5)+,d6
 add.b d6,d6
 and.w #$1FF8,d6	; and.w d4,d6
 lsl.l #6,d6
 lea (a1,d6.l),a4	; conversion
 rept 4
	 move.b (a0)+,d1
	 move (a4,d1*2),(a3)+
 endr
 move.l a3,a2		; saves for next bloc
 move.l a0,d2		; same
 rept 3
 	add d3,a3
	 add d0,a0
	 rept 4
 		move.b (a0)+,d1
	 	move (a4,d1*2),(a3)+
	 endr
 endr
	dbf d5,.one_bloc
.common:
	swap d5
	add d3,a3
	add d5,a5
	sub d0,a3
	add d5,a6
	sub d0,a3
.line_loop:
	swap d5
	dbf d7,.line
.fin:
; 	bra.s .gloups2
.gloups2:
	rts

.fast_display:
 move iv32_freq(pc),d0
 subq.b #1,d0
 beq.s .on_affiche_fast
 move d0,iv32_freq
 rts							; n'affiche pas
.on_affiche_fast:
 lsr #8,d0
 move.b d0,iv32_freq+1	; reset counter
	move.l (a2),a0		; Y plan
	move.l image,a3		; screen
	move screenw,d3
	move xto4n(pc),d7
	move.l hc_cvid,a4
	sub d7,d3				; screen inc
	add d3,d3
	move yto4n(pc),d6
	lsr #2,d7				; 4 par 4
	subq #1,d7
	moveq #0,d1
	bra.s .loop
.copy:
	move d7,d0
.pix4:
	rept 4
		move.b (a0)+,d1
		move 0(a4,d1.w*2),(a3)+
	endr
	dbf d0,.pix4
	add d3,a3
.loop:
	dbf d6,.copy
	rts

 else		; if c256=1, only Y and direct copy!!!

 bne.s .fin	; plan Y
 move iv32_freq(pc),d0
 subq.b #1,d0
 beq.s .on_affiche_256
 move d0,iv32_freq
 rts							; n'affiche pas
.on_affiche_256:
 lsr #8,d0
 move.b d0,iv32_freq+1	; reset counter
	move.l (a2),a0		; Y plan
	move.l image,a3		; screen
	move screenw,d3
	move xto4n(pc),d7
	sub d7,d3				; screen inc
	move yto4n(pc),d6
	lsr #2,d7				; 4 par 4
	subq #1,d7
	bra.s .loop
.copy:
	move d7,d0
.pix4:
	move.l (a0)+,d1
	not.l d1
	add.l d1,d1
	move.l d1,(a3)+
	dbf d0,.pix4
	add d3,a3
.loop:
	dbf d6,.copy
.fin:
;	bra.s .gloups2
.gloups2:
	rts

	endif


	if c256=0
qt_raw:
	lea cvid_fix0,a6			; the palette
	else
qt_raw_256:
	endif
	move.l buffer,a2
	move.l image,a3
	move screenw,d3
	move.l imagey,d5
	move.l bufused,d4
	divs d5,d4						; max image x according to bufused
	sub d4,d3
	if c256=0
		add d3,d3					; row_inc
		moveq #0,d2
	endif
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if c256=0
		move.b (a2)+,d2
		move (a6,d2.w*2),(a3)+
	else
		move.b (a2)+,(a3)+
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts

	if c256=0
qt_raw4:
	lea cvid_fix0,a6			; the palette
	else
qt_raw4_256:
	endif
	move.l buffer,a2
	move.l image,a3
	move screenw,d3
	move.l imagex,d4
	addq #7,d4
	and.b #$F8,d4
	sub d4,d3
	if c256=0
		add d3,d3					; row_inc
	endif
	moveq #0,d2
	moveq #0,d7
	move.l imagey,d5
	lsr #1,d4						; one byte=2 pixels
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if c256=0
		moveq #0,d2
		move.b (a2)+,d2
		ror.l #4,d2
		move (a6,d2.w*2),(a3)+
		swap d2
		rol #5,d2
		move (a6,d2.w),(a3)+
	else
		moveq #0,d2
		move.b (a2)+,d2
		lsl #4,d2
		lsr.b #4,d2
		move d2,(a3)+
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts

	if c256=0
qt_raw1:
	else
qt_raw1_256:
	endif
	move.l buffer,a2			; keep those 6 bytes first (CDV)
	move.l image,a3
	move screenw,d3
	move.l imagey,d5
	move max_imagex,d4
	move d4,d0
	add #15,d4
	and.w #$fff0,d4				; word aligned
	cmp d0,d4
	beq.s .mul16
	and #$f,d0						; how many pixels more
	moveq #-1,d1					; full mask
	lsr d0,d1						; good mask
	move d4,d0
	asr #3,d0						; number of bytes
	lea -2(a2,d0.w),a0			; first word to change
	move d5,d2
	subq #1,d2
.mask:
	or d1,(a0)						; add black pixels when unused
	add d0,a0
	dbf d2,.mask
.mul16:
	sub d4,d3
	if c256=0
		add d3,d3					; row_inc
	endif
	moveq #0,d2
	moveq #0,d7
	lsr #3,d4						; one byte=8 pixels
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if c256=0
		move.b (a2)+,d2
		rept 7
			spl (a3)+
			spl (a3)+
			lsl.b #1,d2
		endr
		spl (a3)+
		spl (a3)+
	else
		move.b (a2)+,d2
		rept 7
			smi (a3)+
			lsl.b #1,d2
		endr
		smi (a3)+
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts

	if c256=0
qt_raw2:
	lea cvid_fix0,a6
	else
qt_raw2_256:
	endif
	move.l buffer,a2
	move.l image,a3
	move screenw,d3
	move.l bufused,d4
	asl.l #2,d4
	move.l imagey,d5
	divs d5,d4
	sub d4,d3
	if c256=0
		add d3,d3					; row_inc
	endif
	moveq #0,d2
	moveq #0,d7
	lsr #2,d4						; one byte=4 pixels
	subq #1,d4
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if c256=0
		move.b (a2)+,d2
		rept 4
			moveq #0,d6
			lsl.b d2
			roxl.b d6
			lsl.b d2
			roxl.b d6
			move (a6,d6.w*2),(a3)+
		endr
	else
		move.b (a2)+,d2
		rept 4
			moveq #0,d6
			lsl.b d2
			roxl.b d6
			lsl.b d2
			roxl.b d6
			move.b d6,(a3)+
		endr
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts

	if c256=0
qt_rle1:
	else
qt_rle1_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move screenw,d3
	if c256=0
		add d3,d3		; inc for one line
	endif
		move.l (a2)+,d0
		and.l #$FFFFFF,d0	; codec size
		moveq #8,d2
		cmp.l d2,d0
		bmi.s .exit
		addq.l #1,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
.exit:
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines
	addq.l #2,a2
	move.l a3,a4		; saves start of line
.line:
	moveq #0,d1
	move.b (a2)+,d1		; code
	bclr #7,d1
	beq.s .lb1			; if >0, normal
	move.l a4,a3		; else, new line
	add d3,a4			; for the next time
.lb1:
	if c256=0
		lsl #5,d1
	else
		lsl #4,d1
	endif
	add d1,a3		; skips pixels
	moveq #0,d1
	move.b (a2)+,d1
	beq.s .exit			; code=0 means end of frame
	bmi.s .repeat
	subq #1,d1
.copy:
	bsr.s .one_word		; from a2 into a3
	dbf d1,.copy
	bra.s .line
.repeat:
	not.b d1
	beq.s .line
	move.l a3,a0		; saves the current position
	bsr.s .one_word
	bra.s .lb2
.rep:
	if c256=0
		rept 8
		move.l (a0)+,(a3)+
		endr
	else
		rept 4
		move.l (a0)+,(a3)+
		endr
	endif
.lb2:
	dbf d1,.rep
	bra.s .line
.one_word:
	moveq #1,d4
.again:
	if c256=0
		move.b (a2)+,d2
		rept 7
			spl (a3)+
			spl (a3)+
			lsl.b #1,d2
		endr
		spl (a3)+
		spl (a3)+
	else
		move.b (a2)+,d2
		rept 7
			smi (a3)+
			lsl.b #1,d2
		endr
		smi (a3)+
	endif
	dbf d4,.again
	rts

	if c256=0
qt_rle2:
	lea cvid_fix0,a6	; the palette
	else
qt_rle2_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move screenw,d3
	if c256=0
		add d3,d3		; inc for one line
	endif
		move.l (a2)+,d0
		and.l #$FFFFFF,d0	; codec size
		moveq #8,d2
		cmp.l d2,d0
		bmi.s .exit
		addq.l #1,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
.exit:
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines
	addq.l #2,a2
	move.l a3,a4		; saves start of line
	bra.s .start
.line:
	moveq #0,d1
	move.b (a2)+,d1	; code
	bpl.s .lb1			; positive, copy
	cmp.b #$ff,d1
	bne.s .repeat		; other than -1, repeat
	add d3,a4			; next line
	move.l a4,a3		; new line
.start:
	tst.b (a2)+
	bne.s .line
	rts
.lb1:
	subq #1,d1
.copy:
	bsr.s .one_long		; from a2 into a3
	dbf d1,.copy
	bra.s .line
.repeat:
	not.b d1
	move.l a3,a0		; saves the current position
	bsr.s .one_long
	bra.s .lb2
.rep:
	if c256=0
		rept 8
		move.l (a0)+,(a3)+
		endr
	else
		rept 4
		move.l (a0)+,(a3)+
		endr
	endif
.lb2:
	dbf d1,.rep
	bra.s .line
.one_long:
	moveq #1,d4
.again:
	if c256=0
		move (a2)+,d2
		rept 8
			moveq #0,d0
			lsl d2
			roxl d0
			lsl d2
			roxl d0
			move (a6,d0.w*2),(a3)+
		endr
	else
		move (a2)+,d2
		rept 8
			moveq #0,d0
			lsl d2
			roxl.b d0
			lsl d2
			roxl.b d0
			move.b d0,(a3)+
		endr
	endif
	dbf d4,.again
	rts

	if c256=0
qt_rle4:
	lea cvid_fix0,a6	; the palette
	else
qt_rle4_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move screenw,d3
	if c256=0
		add d3,d3		; inc for one line
	endif
		move.l (a2)+,d0
		and.l #$FFFFFF,d0	; codec size
		moveq #8,d2
		cmp.l d2,d0
		bmi.s .exit
		addq.l #1,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
.exit:
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines
	addq.l #2,a2
	move.l a3,a4		; saves start of line
	bra.s .start
.line:
	moveq #0,d1
	move.b (a2)+,d1	; code
	bpl.s .lb1			; positive, copy
	cmp.b #$ff,d1
	bne.s .repeat		; other than -1, repeat
	add d3,a4			; next line
	move.l a4,a3		; new line
.start:
	tst.b (a2)+
	bne.s .line
	rts
.lb1:
	subq #1,d1
.copy:
	bsr.s .one_long		; from a2 into a3
	dbf d1,.copy
	bra.s .line
.repeat:
	not.b d1
	move.l a3,a0		; saves the current position
	bsr.s .one_long
	bra.s .lb2
.rep:
	if c256=0
		rept 4
		move.l (a0)+,(a3)+
		endr
	else
		move.l (a0)+,(a3)+
		move.l (a0)+,(a3)+
	endif
.lb2:
	dbf d1,.rep
	bra.s .line
.one_long:
	moveq #1,d4
.again:
	if c256=0
		rept 2
		moveq #0,d2
		move.b (a2)+,d2
		moveq #15,d0
		and d2,d0
		lsr #4,d2
		move (a6,d2.w*2),(a3)+
		move (a6,d0.w*2),(a3)+
		endr
	else
		rept 2
		move.b (a2)+,d2
		unpk d2,d0,#0
		move d0,(a3)+
		endr
	endif
	dbf d4,.again
	rts

	if c256=0
qt_rle8:
	lea cvid_fix0,a6
	moveq #0,d4
	else
qt_rle8_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move screenw,d3
	if c256=0
		add d3,d3
	endif
		move.l (a2)+,d0
		and.l #$FFFFFF,d0	; codec size
		moveq #8,d2
		cmp.l d2,d0
		bmi.s .nopframe
		addq.l #1,a2		; codec size + one byte
	btst #3,(a2)+		; flag and $8
	bne.s .lb0			; if 8, header present
.nopframe:
	rts					; else, nop frame
.lb0:
	move (a2)+,d0		; start line
	muls d3,d0			; offset
	add.l d0,a3			; start into screen
	addq.l #2,a2
	move (a2)+,d0		; number of lines
	addq.l #2,a2
	move.l a3,a4
.while:
	subq #1,d0
	bpl.s .lb1
	rts
.lb1:
	move.l a4,a3		; start of line
	add d3,a4			; for the next line
	moveq #0,d2
	move.b (a2)+,d2
	if c256=0
		lea -8(a3,d2.w*8),a3	; skips blocs
	else
		lea -4(a3,d2.w*4),a3
	endif
.cnt:
	move.b (a2)+,d2	; code
	bne.s .case80
	move.b (a2)+,d2
	if c256=0
		lea -8(a3,d2.w*8),a3 ; skips
	else
		lea -4(a3,d2.w*4),a3
	endif
	bra.s .cnt
.case80:
	bmi.s .repeat
	subq #1,d2
.run:
	if c256=0
	rept 4
		move.b (a2)+,d4
		move (a6,d4.w*2),(a3)+
	endr
	else
		move.l (a2)+,(a3)+
	endif
	dbf d2,.run
	moveq #0,d2
	bra.s .cnt
.repeat:
	sub #256,d2
	neg d2
	subq #1,d2
	beq.s .while		; it was $FF=end of line
	if c256=0
		move.b (a2)+,d4
		move (a6,d4.w*2),d5
		swap d5
		move.b (a2)+,d4
		move (a6,d4.w*2),d5
		move.b (a2)+,d4
		move (a6,d4.w*2),d6
		swap d6
		move.b (a2)+,d4
		move (a6,d4.w*2),d6
	else
		move.b (a2)+,d5
		lsl #8,d5
		move.b (a2)+,d5
		swap d5
		move.b (a2)+,d5
		lsl #8,d5
		move.b (a2)+,d5
	endif
.rep:
	move.l d5,(a3)+
	if c256=0
		move.l d6,(a3)+
	endif
	dbf d2,.rep
	moveq #0,d2
	bra.s .cnt


	if c256=0
qt_yuv2:
	move.l hc_cvid,a1
	else
qt_yuv2_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move.l imagey,d5
	move.l bufused,d4
	divs d5,d4				; number of columns according to buffer size
	lsr #1,d4				; one pixel = 2 bytes
	subq #1,d5
	move #$F8,d7
	move screenw,d3
	sub d4,d3
	subq #1,d4
	if c256=0
		add d3,d3
	endif
	moveq #0,d0
	moveq #0,d1
.loop:
	move d4,d6
.line:
	if c256=0
		move.b (a2)+,d0		; y0
		moveq #0,d2
		move.b (a2)+,d2		; u
		lsl #5,d2
		move.b (a2)+,d1		; y1
		move.b (a2)+,d2		; v
		and.b d7,d2
		lsl.l #6,d2				; uuuuuvvvvv0 00000000
		lea (a1,d2.l),a4
		move (a4,d0.w*2),(a3)+
		move (a4,d1.w*2),(a3)+
	else
		move.b (a2)+,d0
		not.b d0
		move.b d0,(a3)+	; y0
		move.w (a2)+,d0	; u and y1
		not.b d0
		move.b d0,(a3)+	; y1
		addq.l #1,a2
	endif
	subq #1,d6
	dbf d6,.line			; next 2 pixels
	add d3,a3
	dbf d5,.loop			; next line
	rts

	if c256=0
qt_yuv9:
	move.l hc_cvid,a1
	else
qt_yuv9_256:
	endif
	move.l image,a3
	move.l buffer,a2	; Yptr

	move max_imagey,d5
	move max_imagex,d4
	if c256=0
		move d4,d7
		muls d5,d7
		lea (a2,d7.l),a0	; Vptr
		lsl.l #4,d7			; Vptr = yptr /16 (size)
		add.l a0,d7			; Uptr
	endif
	subq #1,d5
	move screenw,d3
	sub d4,d3
	lsr #2,d4			; pixels come 4 at a time
	subq #1,d4
	if c256=0
		add d3,d3
	endif
	moveq #0,d0
	moveq #0,d1			; y
.loop:
	move d4,d6
	if c256=0
		move.l d7,a5			; Up
		move.l a0,a6			; Vp
	endif
.line:
	if c256=0
		move.b (a5)+,d2		; u
		lsl #5,d2
		move.b (a6)+,d2		; v
		and.b #$f8,d2
		lsl.l #6,d2				; uuuuuvvvvv0 00000000
		lea (a1,d2.l),a4
		rept 4
			move.b (a2)+,d0	; Y0,1,2,3
			move (a4,d0.w*2),(a3)+	; corresponding RGB
		endr
	else
		move.l (a2)+,d0		; y0123
		not.l d0
		move.l d3,(a3)+
	endif
	subq #1,d6
	dbf d6,.line			; next 2 pixels
	add d3,a3
	if c256=0
		moveq #3,d0
		and d0,d1				; y mod 4
		cmp d0,d1
		bne.s .no
		move.l a5,d7			; every 4 lines, new UV
		move.l a6,a0
		.no:
	endif
	dbf d5,.loop			; next line
	rts


c256 set 1+c256				; now c256=1, second loop
	endr							; makes the second routine


close_work: dc.l cw_cont,dum,dum,dum,dum
cw_cont: dc.w 101,0,0,0,0,0,0,0,0,0,0,0


falc set 0						; 0 = NOVA 32k, 1 = Falc 32k, 2 = NOVA 256c,3=65k

	rept 4						; 2 routines for NOVA (faster), and 1 for falcon

	if falc=2
c256 set 1
	else
c256 set 0
	endif

	if falc=0
decode_cram16:
	moveq #8,d3
	swap d3
	else
		if falc=1
decode_cram16_falc:
		else
			if falc=3
decode_cram16_65k:
			else
decode_cram16_grey:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l buffer,a2			; the datas
		move screenw,d3
		move d3,d0
		addq #4,d3
		if falc<2
			add d3,d3					; row dec, 1pixel is 2 bytes
		endif
		moveq #0,d6						; x dans le high word
		move max_imagey,d7
		move.l image,a0
		subq #1,d7
		muls d7,d0
		swap d7							; y dans le high word
;		ext.l d3
		if falc<2
			add.l d0,d0
		endif
		add.l d0,a0						; premier bloc point‚
		neg.w d3							; on recule...
		if falc=2
			lea 16(a0,d3.w*4),a4		; bloc ligne suivante
		else
			lea 32(a0,d3.w*4),a4
		endif
	endif
	if falc=0
		tst.b is_65k
		bne decode_cram16_65k
		swap d3
		sub bit_rot,d3		; 8 for MAC (intel->motorola) 0 for NOVA
	endif
.loop:
	swap d6
	tst.l d7
	bmi .exit
	clr d6
	clr d7
	move.b (a2)+,d6				; code0
	move.b (a2)+,d7				; code1
	cmp #$84,d7
	bmi.s .blocs
	cmp #$88,d7
	bpl.s .blocs
	sub #$84,d7						; skip
	asl #8,d7
	add d6,d7
	subq #1,d7
.skip:
	swap d6
.skip2:
	addq #4,d6
	if falc=2
		addq.l #4,a0
	else
		addq.l #8,a0
	endif
	cmp max_imagex,d6
	bmi.s .lb0
	swap d7
	move.l a4,a0
	subq #4,d7
	if falc=2
		lea 16(a0,d3.w*4),a4		; bloc ligne suivante
	else
		if falc=0
			swap d3
		endif
		lea 32(a0,d3.w*4),a4
		if falc=0
			swap d3
		endif
	endif
	clr d6
	swap d7
.lb0:
	dbf d7,.skip2
	bra.s .loop
.blocs:
	move.l a0,a3
	cmp #$80,d7
	bpl.s .lb2
	move (a2)+,d5		; cb0
	move (a2)+,d4		; ca0
	tst.b d5
	bpl.s .lb1
	move (a2)+,d2		; cb1
	move (a2)+,d1		; ca1
	if falc=2
		bsr avi_cram16_c4_grey
	else
		if falc=0
			ror d3,d1
			ror d3,d2
			ror d3,d4
			ror d3,d5
			swap d3
		else
				FALC16 d5
				FALC16 d4
				FALC16 d2
				FALC16 d1
				if falc=3
					ror #8,d5
					ror #8,d4
					ror #8,d2
					ror #8,d1
				endif
		endif
		bsr avi_cram16_c4
		if falc=0
			swap d3
		endif
	endif
	move d7,d6
	move (a2)+,d5
	move (a2)+,d4
	move (a2)+,d2
	move (a2)+,d1
	if falc=2
		bsr avi_cram16_c4_grey
	else
		if falc=0
			ror d3,d1
			ror d3,d2
			ror d3,d4
			ror d3,d5
			swap d3
		else
				FALC16 d5
				FALC16 d4
				FALC16 d2
				FALC16 d1
				if falc=3
					ror #8,d5
					ror #8,d4
					ror #8,d2
					ror #8,d1
				endif
		endif
		bsr avi_cram16_c4
		if falc=0
			swap d3
		endif
	endif
	bra.s .inc_bloc
.lb1:
	if falc=2
		bsr avi_cram16_c2_grey
		move d7,d6
		bsr _avi_cram16_c2_grey
	else
		if falc=0
			ror d3,d4
			ror d3,d5
			swap d3
		else
				FALC16 d5
				FALC16 d4
				if falc=3
					ror #8,d5
					ror #8,d4
				endif
		endif
		bsr avi_cram16_c2
		move d7,d6
		bsr avi_cram16_c2
		if falc=0
			swap d3
		endif
	endif
	bra.s .inc_bloc
.lb2:
	lsl #8,d6
	add d6,d7
	if falc=2
		bsr avi_cram16_c1_grey
	else
		if falc=0
			ror d3,d7
			swap d3
		else
				FALC16 d7
				if falc=3
					ror #8,d7
				endif
		endif
		bsr avi_cram16_c1
		if falc=0
			swap d3
		endif
	endif
.inc_bloc:
	swap d6
	addq #4,d6
	if falc=2
		addq.l #4,a0
	else
		addq.l #8,a0
	endif
	cmp max_imagex,d6
	bmi .loop
	clr d6
	swap d7
	move.l a4,a0
	subq #4,d7
	if falc=2
		lea 16(a0,d3.w*4),a4		; bloc ligne suivante
	else
		if falc=0
			swap d3
		endif
		lea 32(a0,d3.w*4),a4
		if falc=0
			swap d3
		endif
	endif
	swap d7
	bra .loop
.exit:
	rts

		if falc=0
qt_raw16:
	else
		if falc=1
qt_raw16_falc:
		else
			if falc=3
qt_raw16_65k:
			else
qt_raw16_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l buffer,a2
		move.l image,a3
		move screenw,d3
		move.l imagey,d5
		move.l bufused,d4
		divs d5,d4
		lsr #1,d4						; max image x according to bufused
		sub d4,d3
		if falc<2
			add d3,d3					; row_inc
		endif
		subq #1,d4
	endif
	if falc=0
		tst.b is_65k
		bne qt_raw16_65k
	endif
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	move (a2)+,d2
	bclr #15,d2
	if falc=2
		move.b (a1,d2.w),(a3)+
	else
			ror #8,d2
			if (falc=1)|(falc=3)
				FALC16 d2
				if falc=3
					ror #8,d2
				endif
			endif
			move d2,(a3)+
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts

	if falc=0
qt_raw24:
	else
		if falc=1
qt_raw24_falc:
		else
			if falc=3
qt_raw24_65k:
			else
qt_raw24_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move off_24_32,d7			; 0 or 1 to skip one byte (R G B or 0 R G B)
		move.l buffer,a2
		move.l image,a3
		move screenw,d3
		move.l imagey,d5
		move.l bufused,d4
		moveq #3,d0
		add d7,d0
		muls d5,d0
		divs d0,d4					; max image_x according to bufused
		sub d4,d3
		if falc<2
			add d3,d3					; row_inc
		endif
		subq #1,d4
	endif
	if falc=0
		tst.b is_65k
		bne qt_raw24_65k
	endif
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	add d7,a2
	if (falc=1)|(falc=3)
		move.b (a2)+,d2
		lsl #5,d2
		move.b (a2)+,d2
		lsl.l #6,d2
		move.b (a2)+,d2
		lsr.l #3,d2
		if falc=3
			ror #8,d2
		endif
		move d2,(a3)+
	else
		move.b (a2)+,d2
		lsl #5,d2
		move.b (a2)+,d2
		lsl.l #5,d2
		move.b (a2)+,d2
		lsr.l #3,d2
		if falc=2
			bclr #15,d2
			move.b (a1,d2.w),(a3)+
		else
				ror #8,d2
				move d2,(a3)+
		endif
	endif
	dbf d0,.lb1
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts

; TGA 24 bits BVR

	if falc=0
bat_tga:
	else
		if falc=1
bat_tga_falc:
		else
			if falc=3
bat_tga_65k:
			else
bat_tga_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l buffer,a2
		move.l image,a3
		move screenw,d3
		move 14(a2),d5				; max_imagey
		ror #8,d5
		move 12(a2),d4				; max_imagex
		ror #8,d4
		btst #5,17(a2)				; origin top or bottom
		bne.s .top
		move d5,d0
		subq #1,d0
		muls d3,d0					; to go to the bottom
		add d4,d3
		neg d3						; back one line
		bra.s .common
	.top:
		moveq #0,d0					; yet at top
		sub d4,d3
	.common:
		if falc<2
			add.l d0,d0
			add d3,d3					; row_inc
		endif
		add.l d0,a3					; to the correct line
		subq #1,d4
		move.b 16(a2),d0
	endif
	if falc=0
		moveq #8,d1					; ror #8,xx
		tst.b create_mov
		bne.s .areu					; if CREATE, NOVA 15 bits encoding
		tst.b is_65k				; else, 16 bits allowed
		bne bat_tga_65k
		move bit_rot,d1			; or 15 bits INTEL/MOTOROLA
	.areu:
	endif
	cmp.b #24,d0					; 24 bits?
	bne.s .other_bits
	moveq #0,d0
	move.b (a2),d0					; offset
	lea 18(a2,d0.w),a2
	bra.s .y_loop
.lb0:
	move d4,d0
.lb1:
	if (falc=1)|(falc=3)
		move.b (a2)+,d2
		lsl #8,d2
		swap d2
		move.b (a2)+,d2
		lsl #8,d2
		move.b (a2)+,d2
		lsr.b #3,d2
		rol #6,d2
		rol.l #5,d2
		if falc=3
			ror #8,d2
		endif
		move d2,(a3)+
	else
		move.b (a2)+,d2
		lsl #8,d2
		swap d2
		move.b (a2)+,d2
		lsl #8,d2
		move.b (a2)+,d2
		lsr.b #3,d2
		rol #5,d2
		rol.l #5,d2
		if falc=2
			move.b (a1,d2.w),(a3)+
		else
				ror d1,d2
				move d2,(a3)+
		endif
	endif
	dbf d0,.lb1
	if c256=0
		tst.b create_mov
		beq.s .not_pad
		move.l a3,a0
		move d4,d2
	.pad:
		addq #1,d2
		cmp screenw,d2
		beq.s .not_pad
		clr (a0)+
		bra.s .pad
	.not_pad:
	endif
	add d3,a3
.y_loop:
	dbf d5,.lb0
	rts
.other_bits:			; assumes that it's a 16 bits TGA
	moveq #0,d0
	move.b (a2),d0
	lea 18(a2,d0.w),a2
	if falc=0
		tst bit_rot
		bne.s .oy_loop  ; NOVA encoding (Intel)
		bra.s .olb5
.olb2:
		move d4,d0
.olb3:
		move (a2)+,d2
		ror #8,d2
		move d2,(a3)+
		dbf d0,.olb3
.olb4:
		tst.b create_mov
		beq.s .onot_pad2
		move.l a3,a0
		move d4,d2
.opad2:
		addq #1,d2
		cmp screenw,d2
		beq.s .onot_pad2
		clr (a0)+
		bra.s .opad2
.onot_pad2:
		add d3,a3
.olb5:
		dbf d5,.olb2
		rts
	else
		bra.s .oy_loop
	endif
.olb0:
	move d4,d0
.olb1:
	if (falc=1)|(falc=3)
		move (a2)+,d2
		;	ror #8,d2
		FALC16 d2
		if falc=3
			ror #8,d2
		endif
		move d2,(a3)+
	else
		if falc=0
			move (a2)+,(a3)+
		else
			move (a2)+,d2
			ror #8,d2
			bclr #15,d2
			if falc=2
				move.b (a1,d2.w),(a3)+
			else
				move (a1,d2.w*2),(a3)+
			endif
		endif
	endif
	dbf d0,.olb1
	if falc=0
.olb7:
	endif
	if c256=0
		tst.b create_mov
		beq.s .onot_pad
		move.l a3,a0
		move d4,d2
	.opad:
		addq #1,d2
		cmp screenw,d2
		beq.s .onot_pad
		clr (a0)+
		bra.s .opad
	.onot_pad:
	endif
	add d3,a3
.oy_loop:
	dbf d5,.olb0
	rts

		if falc=0
qt_rle16:
	move bit_rot,d1
	else
		if falc=1
qt_rle16_falc:
		else
			if falc=3
qt_rle16_65k:
			else
qt_rle16_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l image,a3
		move.l buffer,a2
		move screenw,d3
		if falc<2
			add d3,d3
		endif
		move.l (a2)+,d0
		and.l #$FFFFFF,d0	; codec size
		moveq #8,d2
		cmp.l d2,d0
		bmi.s .nopframe
		addq.l #1,a2		; codec size + one byte
		btst #3,(a2)+		; flag and $8
		bne.s .lb0			; if 8, header present
	.nopframe:
		rts					; else, nop frame
	.lb0:
		move (a2)+,d0		; start line
		muls d3,d0			; offset
		add.l d0,a3			; start into screen
		addq.l #2,a2
		move (a2)+,d0		; number of lines
		addq.l #2,a2
		move.l a3,a4
	endif
	if falc=0
		tst.b is_65k
		bne qt_rle16_65k
	endif
.while:
	dbf d0,.lb1
;	subq #1,d0
;	bpl.s .lb1
	rts
.lb1:
	move.l a4,a3		; start of line
	moveq #0,d2
	add d3,a4			; for the next line
	move.b (a2)+,d2
	if falc=2
		lea -1(a3,d2.w),a3
	else
;		subq.l #2,a3
;		add d2,a3
;		add d2,a3
		lea -2(a3,d2.w*2),a3	; skips blocs
	endif
.cnt:
	move.b (a2)+,d2	; code
	bne.s .case80
	move.b (a2)+,d2
	if falc=2
		lea -1(a3,d2.w),a3
	else
;		subq.l #2,a3
;		add d2,a3
;		add d2,a3
		lea -2(a3,d2.w*2),a3 ; skips
	endif
	bra.s .cnt
.case80:
	bmi.s .repeat
	subq #1,d2
.run:
	move (a2)+,d4
	if falc=2
		bclr #15,d4
		move.b (a1,d4.w),(a3)+
	else
		if falc=0
			ror d1,d4
		else
			ror #8,d4
				FALC16 d4
				if falc=3
					ror #8,d4
				endif
		endif
		move d4,(a3)+
	endif
	dbf d2,.run
	moveq #0,d2
	bra.s .cnt
.repeat:
	sub #256,d2
	neg d2
	subq #1,d2
	beq.s .while		; it was $FF=end of line
	move (a2)+,d4
	if falc=2
		bclr #15,d4
		move.b (a1,d4.w),d4
	else
		if falc=0
			ror d1,d4
		else
			ror #8,d4
				FALC16 d4
				if falc=3
					ror #8,d4
				endif
		endif
	endif
.rep:
	if falc=2
		move.b d4,(a3)+
	else
		move d4,(a3)+
	endif
	dbf d2,.rep
	moveq #0,d2
	bra.s .cnt


	if falc=0
qt_rle24:
	else
		if falc=1
qt_rle24_falc:
		else
			if falc=3
qt_rle24_65k:
			else
qt_rle24_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l image,a3
		move.l buffer,a2
		move off_24_32,d7		; 1 or 0 to skip one byte before R G B
		move screenw,d3
		if falc<2
			add d3,d3
		endif
		move.l (a2)+,d0
		and.l #$FFFFFF,d0	; codec size
		moveq #8,d2
		cmp.l d2,d0
		bmi.s .nopframe
		addq.l #1,a2		; codec size + one byte
		btst #3,(a2)+		; flag and $8
		bne.s .lb0			; if 8, header present
	.nopframe:
		rts					; else, nop frame
	.lb0:
		move (a2)+,d0		; start line
		muls d3,d0			; offset
		add.l d0,a3			; start into screen
		addq.l #2,a2
		move (a2)+,d0		; number of lines
		addq.l #2,a2
		move.l a3,a4
	endif
	if falc=0
		tst.b is_65k
		bne qt_rle24_65k
	endif
.while:
	subq #1,d0
	bpl.s .lb1
	rts
.lb1:
	move.l a4,a3		; start of line
	add d3,a4			; for the next line
	moveq #0,d2
	move.b (a2)+,d2
	if falc=2
		lea -1(a3,d2.w),a3
	else
		lea -2(a3,d2.w*2),a3	; skips blocs
	endif
	move.b (a2)+,d2	; code
.cnt:
	cmp.b #$ff,d2
	beq.s .while		; end of line
	tst.b d2
	bne.s .case80
	move.b (a2)+,d2
	if falc=2
		lea -1(a3,d2.w),a3
	else
		lea -2(a3,d2.w*2),a3 ; skips
	endif
.next_cnt:
	move.b (a2)+,d2
	bra.s .cnt
.case80:
	cmp #$80,d2
	bpl.s .repeat
	subq #1,d2
.run:
	add d7,a2
	if (falc=1)|(falc=3)
		move.b (a2)+,d4
		lsl #5,d4
		move.b (a2)+,d4
		lsl.l #6,d4
		move.b (a2)+,d4
		lsr.l #3,d4
		if falc=3
			ror #8,d4
		endif
		move d4,(a3)+
	else
		move.b (a2)+,d4
		lsl #5,d4
		move.b (a2)+,d4
		lsl.l #5,d4
		move.b (a2)+,d4
		lsr.l #3,d4
		if falc=2
			bclr #15,d4
			move.b (a1,d4.w),(a3)+
		else
				ror #8,d4
				move d4,(a3)+
		endif
	endif
	dbf d2,.run
	moveq #0,d2
	bra.s .next_cnt
.repeat:
	sub #256,d2
	neg d2
	subq #1,d2
	add d7,a2
	if (falc=1)|(falc=3)
		move.b (a2)+,d4
		lsl #5,d4
		move.b (a2)+,d4
		lsl.l #6,d4
		move.b (a2)+,d4
		lsr.l #3,d4
		if falc=3
			ror #8,d4
		endif
	else
		move.b (a2)+,d4
		lsl #5,d4
		move.b (a2)+,d4
		lsl.l #5,d4
		move.b (a2)+,d4
		lsr.l #3,d4
		if falc=2
			bclr #15,d4
			move.b (a1,d4.w),d4
		else
				ror #8,d4
		endif
	endif
.rep:
	if falc=2
		move.b d4,(a3)+
	else
		move d4,(a3)+
	endif
	dbf d2,.rep
	moveq #0,d2
	bra.s .next_cnt


	if falc=0
qt_rpza:
	else
		if falc=1
qt_rpza_falc:
		else
			if falc=3
qt_rpza_65k:
			else
qt_rpza_256:
	move.l hc_cvid,a1			; pointer for the color/grey conversion
			endif
		endif
	endif
	if falc<3
		move.l buffer,a2
		move.l image,a3
		move screenw,d3
		moveq #0,d0
		move d3,d0
		move d3,d5
		muls #3,d5
		subq #4,d3
		lsl #2,d0
		sub max_imagex,d0
		if falc<2
			add d3,d3
			add d0,d0
			add d5,d5
		endif
		move.l d0,a4		; row inc
		moveq #0,d7				; x
		clr.b (a2)				; $e1
		if falc=0
			swap d3
			move bit_rot,d3		; d3 = WORD ligne WORD rotation (8 for NOVA or 0 for MAC)
		endif
		move.l (a2)+,d0		; len
		cmp.l bufused,d0
		beq.s .good_size
	.out:
		rts
	.good_size:
		lea -4(a2,d0.l),a0	; end of frame
	endif
	if falc=0
		tst.b is_65k
		bne qt_rpza_65k
	endif
.while:
	cmp.l a0,a2
	bpl.s .out
.lb0:
	moveq #0,d1
	move.b (a2)+,d1		; code
	move d1,d2
	lsr #5,d2
	cmp.b #5,d2				; code $a0 to $bf
	bne.s .case8
	move (a2)+,d2			; color
	if falc=2
		bsr.s qt_rpza_c1_256
	else
			if falc=1
				bsr.s qt_rpza_c1_falc
			else
				if falc=3
					bsr.s qt_rpza_c1_65k
				else
					bsr.s qt_rpza_c1
				endif
			endif
	endif
	bra.s .while
	if falc=3
.out:
	rts
	endif
.case8:
	cmp.b #4,d2				; code $80 to $9f
	bne.s .casec
	sub #$80,d1				; loops
.lb1:
	if falc=2
		addq.l #4,a3
	else
		addq.l #8,a3
	endif
	addq #4,d7
	cmp max_imagex,d7
	bmi.s ._lb0
	moveq #0,d7
	add.l a4,a3
._lb0:
	dbf d1,.lb1
	bra.s .while
.casec:
	cmp.b #6,d2
	bne.s .casex
	move d1,d0
	sub #$C0,d0				; loops (-1 for dbf)
	move (a2)+,d1			; one color
	move (a2)+,d2			; another
.col4_init:
		if falc=2
	bclr #15,d1
	bclr #15,d2
	move.b (a1,d1.w),d1
	move.b (a1,d2.w),d2
		else
			if (falc=1)|(falc=3)
	ror #8,d1
	ror #8,d2
	FALC16 d1
	FALC16 d2
			if falc=3
				ror #8,d1
				ror #8,d2
			endif
			else
	ror d3,d1
	ror d3,d2
			endif
		endif
.col4:
	if falc=2
		bsr.s qt_rpza_c4_256
	else
		if (falc=0)|(falc=3)
			swap d3
			if falc=0
				bsr.s qt_rpza_c4
			else
				bsr qt_rpza_c4
			endif
			swap d3
		else
			bsr qt_rpza_c4
		endif
	endif
	bra.s .while
.casex:						; under $80
	lsl #8,d1
	move.b (a2)+,d1		; one color
	move (a2)+,d2			; a second color
	moveq #0,d0				; one loop (if bit 15)
	bclr #15,d2
	bne.s .col4_init			; same as above
	if falc=2
		bsr qt_rpza_c16_256
	else
			if falc=1
				bsr.s qt_rpza_c16_falc
			else
				if falc=3
					bsr.s qt_rpza_c16_65k
				else
					bsr qt_rpza_c16
				endif
			endif
	endif
;	bra.s .while
	bra.s .while

	if falc=2
qt_rpza_c1_256:
	bclr #15,d2
	move.b (a1,d2.w),d2
	else
			if falc=0
qt_rpza_c1:
	ror d3,d2
			else
				if falc=3
qt_rpza_c1_65k:
	ror #8,d2
	FALC16 d2
	ror #8,d2
				else
qt_rpza_c1_falc:
	ror #8,d2
	FALC16 d2
				endif
			endif
	endif
	sub #$a0,d1		; loops
	if falc=2
		move d2,d4
		lsl #8,d2
		move.b d4,d2	; into high byte
	endif
	move d2,d4
	swap d2
	move d4,d2		; into high word
	if (falc=0)|(falc=3)
		swap d3			; recupŠre LIGNE
	endif
.lb0:
	rept 3
	move.l d2,(a3)+
	if c256=0
		move.l d2,(a3)+
	endif
	add d3,a3
	endr
	move.l d2,(a3)+
	if c256=0
		move.l d2,(a3)+
	endif
	sub d5,a3
	addq #4,d7
	cmp max_imagex,d7
	bmi.s .lb1
	moveq #0,d7
	add.l a4,a3
.lb1:
	dbf d1,.lb0
	if (falc=0)|(falc=3)
		swap d3			; remet ROTATION
	endif
	rts

	if (falc=0)|(falc=2)	; falc=0 pour 1 et 3 aussi

	if falc=2
qt_rpza_c4_256:
	else
qt_rpza_c4:
	endif
.debut:
	move.l (a2)+,d4
	moveq #3,d6
.loop:
	btst #31,d4
	beq.s .lb0

	if falc=2

	move.b d1,(a3)+
	bra.s .lb1
.lb0:
   move.b d2,(a3)+
.lb1:
	btst #29,d4
	beq.s .lb2
	move.b d1,(a3)+
	bra.s .lb3
.lb2:
   move.b d2,(a3)+
.lb3:
	btst #27,d4
	beq.s .lb4
	move.b d1,(a3)+
	bra.s .lb5
.lb4:
   move.b d2,(a3)+
.lb5:
	btst #25,d4
	beq.s .lb6
	move.b d1,(a3)+
	bra.s .lb7
.lb6:
   move.b d2,(a3)+

   else

   move d1,(a3)+
	bra.s .lb1
.lb0:
   move d2,(a3)+
.lb1:
	btst #29,d4
	beq.s .lb2
	move d1,(a3)+
	bra.s .lb3
.lb2:
   move d2,(a3)+
.lb3:
	btst #27,d4
	beq.s .lb4
	move d1,(a3)+
	bra.s .lb5
.lb4:
   move d2,(a3)+
.lb5:
	btst #25,d4
	beq.s .lb6
	move d1,(a3)+
	bra.s .lb7
.lb6:
   move d2,(a3)+

   endif

.lb7:
	add d3,a3
	lsl.l #8,d4
	dbf d6,.loop
	sub d3,a3
	sub d5,a3
	addq #4,d7
	cmp max_imagex,d7
	bmi.s .lb8
	moveq #0,d7
	add.l a4,a3
.lb8:
	dbf d0,.debut
	rts

	endif ; (for FALC<>1)

	if falc=2
qt_rpza_c16_256:
	bclr #15,d1
	move.b (a1,d1.w),(a3)+
	bclr #15,d2
	move.b (a1,d2.w),(a3)+
	else
			if falc=1
qt_rpza_c16_falc:
	ror #8,d1
	FALC16 d1
	ror #8,d2
	FALC16 d2
	move d1,(a3)+
	move d2,(a3)+
			else
			if falc=3
qt_rpza_c16_65k:
	ror #8,d1
	FALC16 d1
	ror #8,d2
	ror #8,d1
	FALC16 d2
	move d1,(a3)+
	ror #8,d2
	move d2,(a3)+
			else
qt_rpza_c16:
	ror d3,d1
	ror d3,d2
	move d1,(a3)+
	move d2,(a3)+
			endif
			endif
	endif
	RPZA	; 2 pixels
	moveq #2,d2
.loop:
	if (falc=0)|(falc=3)
		swap d3
		add d3,a3
		swap d3
	else
		add d3,a3
	endif
	rept 2
		RPZA	; 2 pixels
	endr
	dbf d2,.loop
	sub d5,a3
	addq #4,d7
	cmp max_imagex,d7
	bmi.s .lb8
	moveq #0,d7
	add.l a4,a3
.lb8:
	sub.l #28,d0
	rts

	if falc=2
flh_brun_256:
	else
		if falc=1
flh_brun_falc:
		else
			if falc=3
flh_brun_65k:
			else
flh_brun:
			endif
		endif
	endif
		move max_imagey,d5		; number of lines to modify
	if falc<3
;		move max_imagey,d5		; number of lines to modify
		if falc=2
			move d5,flx_number
			clr flx_start
		endif
	endif
		move.l a5,a2				; screen pointer
	if falc=0
		tst.b is_65k
		bne flh_brun_65k
	endif
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line in memory
	moveq #0,d4					; number of blocs
	move.b (a0)+,d4
	beq.s .apex					; si 0, c'est du Apex tout crach‚
	bra.s .b_loop
.blocs:
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$7f,d0
	bls.s .repeat
	sub #$100,d0
	neg d0
	bra.s .c_loop
.copy:
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),(a2)+
	else
		if falc=1
			move (a0)+,(a2)+
		else
			if falc=3
				move (a0)+,d1
				ror #8,d1
				move d1,(a2)+
			else
				move (a0)+,d1
				NOVA16 d1
					ror #8,d1
					move d1,(a2)+
			endif
		endif
	endif
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),d1
	else
		if falc=1
			move (a0)+,d1
		else
			if falc=3
				move (a0)+,d1
				ror #8,d1
			else
				move (a0)+,d1
				NOVA16 d1
					ror #8,d1
			endif
		endif
	endif
	bra.s .lb2
.lb1:
	if falc=2
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
.next_line:
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts
.apex:
	move max_imagex,d4		; loop key is the width
	subq #1,d4
.ap_blocs:
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$7f,d0
	bls.s .ap_repeat
	sub #$100,d0
	neg d0
	sub d0,d4
	bra.s .ap_c_loop
.ap_copy:
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),(a2)+
	else
		if falc=1
			move (a0)+,(a2)+
		else
			if falc=3
				move (a0)+,d1
				ror #8,d1
				move d1,(a2)+
			else
				move (a0)+,d1
				NOVA16 d1
					ror #8,d1
					move d1,(a2)+
			endif
		endif
	endif
.ap_c_loop:
	dbf d0,.ap_copy
	bra.s .ap_b_loop
.ap_repeat:
	sub d0,d4
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),d1
	else
		if falc=1
			move (a0)+,d1
		else
			if falc=3
				move (a0)+,d1
				ror #8,d1
			else
				move (a0)+,d1
				NOVA16 d1
					ror #8,d1
			endif
		endif
	endif
	bra.s .ap_lb2
.ap_lb1:
	if falc=2
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.ap_lb2:
	dbf d0,.ap_lb1
.ap_b_loop:
	tst d4
	bpl.s .ap_blocs
	bra.s .next_line

	if falc=2
flh_delta_256:
	else
		if falc=1
flh_delta_falc:
		else
			if falc=3
flh_delta_65k:
			else
			if falc=0
flh_delta:
			else
flh_non_delta:
			endif
			endif
		endif
	endif
	if falc<3
		move (a0)+,d5
		ror #8,d5					; number of lines to modify
		if falc=2
			move d5,flx_number
			moveq #0,d0
			move (a0),d4
			ror #8,d4
			bpl.s .zzz
			neg d4
			move d4,d0
			.zzz:
			move d0,flx_start
		endif
		move.l a5,a2				; screen pointer
	endif
	if falc=0
		tst.b is_65k
		bne flh_delta_65k
	endif
	bra.s .l_loop
.line:
	lea (a2,d3.l),a3			; the next line in memory
	move (a0)+,d4				; number of blocs
	ror #8,d4
	bpl.s .b_loop				; if >0, it's a normal line
	neg d4						; else, number of lines to skip!
	muls d3,d4					; number of bytes
	add.l d4,a2					; skips lines
	bra.s .line
.blocs:
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels to skip
	if falc=2
		lea (a2,d0.w),a2
	else
		lea (a2,d0.w*2),a2		; skips the pixels
	endif
	moveq #0,d1
	moveq #0,d0
	move.b (a0)+,d0			; number of pixels
	cmp #$80,d0
	bpl.s .repeat
	bra.s .c_loop
.copy:
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),(a2)+
	else
		if falc=1
			move (a0)+,(a2)+
		else
			if falc=3
				move (a0)+,d1
				ror #8,d1
				move d1,(a2)+
			else
				move (a0)+,d1
				NOVA16 d1
					ror #8,d1
					move d1,(a2)+
			endif
		endif
	endif
.c_loop:
	dbf d0,.copy
	bra.s .b_loop
.repeat:
	sub #$100,d0
	neg d0
	if falc=2
		move (a0)+,d1
		NOVA16 d1
		bclr #15,d1
		move.b (a6,d1.w),d1
	else
		if falc=1
			move (a0)+,d1
		else
			if falc=3
				move (a0)+,d1
				ror #8,d1
			else
				move (a0)+,d1
				NOVA16 d1
					ror #8,d1
			endif
		endif
	endif
	bra.s .lb2
.lb1:
	if falc=2
		move.b d1,(a2)+
	else
		move d1,(a2)+
	endif
.lb2:
	dbf d0,.lb1
.b_loop:
	dbf d4,.blocs
	move.l a3,a2				; the next line
.l_loop:
	dbf d5,.line
	rts


falc set 1+falc
	endr


avi_cram16_c1:
	move d7,d0
	swap d0
	move d7,d0		; repeats d7 into high word
	rept 4
	move.l d0,(a3)+
	move.l d0,(a3)+
	add d3,a3
	endr
	rts

PIX4_2_1	macro
	move.\0 d\1,(a3)+
	move.\0 d\2,(a3)+
	move.\0 d\3,(a3)+
	move.\0 d\4,(a3)+
	jmp (.second_cram2,pc,d6.w)
	endm

PIX4_2_2 macro
	add d3,a3
	move.\0 d\1,(a3)+
	move.\0 d\2,(a3)+
	move.\0 d\3,(a3)+
	move.\0 d\4,(a3)+
	add d3,a3
	rts
	nop
	endm

avi_cram16_c2:
	moveq #0,d0
	move.b d6,d0
	and.w #$F0,d6
	lsl.b #4,d0
	jmp .premier_cram2(pc,d0.l)
.premier_cram2:
	PIX4_2_1.w 4,4,4,4
	PIX4_2_1.w 5,4,4,4
	PIX4_2_1.w 4,5,4,4
	PIX4_2_1.w 5,5,4,4
	PIX4_2_1.w 4,4,5,4
	PIX4_2_1.w 5,4,5,4
	PIX4_2_1.w 4,5,5,4
	PIX4_2_1.w 5,5,5,4
	PIX4_2_1.w 4,4,4,5
	PIX4_2_1.w 5,4,4,5
	PIX4_2_1.w 4,5,4,5
	PIX4_2_1.w 5,5,4,5
	PIX4_2_1.w 4,4,5,5
	PIX4_2_1.w 5,4,5,5
	PIX4_2_1.w 4,5,5,5
	PIX4_2_1.w 5,5,5,5
.second_cram2:
	PIX4_2_2.w 4,4,4,4
	PIX4_2_2.w 5,4,4,4
	PIX4_2_2.w 4,5,4,4
	PIX4_2_2.w 5,5,4,4
	PIX4_2_2.w 4,4,5,4
	PIX4_2_2.w 5,4,5,4
	PIX4_2_2.w 4,5,5,4
	PIX4_2_2.w 5,5,5,4
	PIX4_2_2.w 4,4,4,5
	PIX4_2_2.w 5,4,4,5
	PIX4_2_2.w 4,5,4,5
	PIX4_2_2.w 5,5,4,5
	PIX4_2_2.w 4,4,5,5
	PIX4_2_2.w 5,4,5,5
	PIX4_2_2.w 4,5,5,5
	PIX4_2_2.w 5,5,5,5

avi_cram16_c4:
	moveq #0,d0
	move.b d6,d0
	and.w #$F0,d6
	lsl.b #4,d0
	jmp .premier_cram2(pc,d0.l)
.premier_cram2:
	PIX4_2_1.w 4,4,1,1
	PIX4_2_1.w 5,4,1,1
	PIX4_2_1.w 4,5,1,1
	PIX4_2_1.w 5,5,1,1
	PIX4_2_1.w 4,4,2,1
	PIX4_2_1.w 5,4,2,1
	PIX4_2_1.w 4,5,2,1
	PIX4_2_1.w 5,5,2,1
	PIX4_2_1.w 4,4,1,2
	PIX4_2_1.w 5,4,1,2
	PIX4_2_1.w 4,5,1,2
	PIX4_2_1.w 5,5,1,2
	PIX4_2_1.w 4,4,2,2
	PIX4_2_1.w 5,4,2,2
	PIX4_2_1.w 4,5,2,2
	PIX4_2_1.w 5,5,2,2
.second_cram2:
	PIX4_2_2.w 4,4,1,1
	PIX4_2_2.w 5,4,1,1
	PIX4_2_2.w 4,5,1,1
	PIX4_2_2.w 5,5,1,1
	PIX4_2_2.w 4,4,2,1
	PIX4_2_2.w 5,4,2,1
	PIX4_2_2.w 4,5,2,1
	PIX4_2_2.w 5,5,2,1
	PIX4_2_2.w 4,4,1,2
	PIX4_2_2.w 5,4,1,2
	PIX4_2_2.w 4,5,1,2
	PIX4_2_2.w 5,5,1,2
	PIX4_2_2.w 4,4,2,2
	PIX4_2_2.w 5,4,2,2
	PIX4_2_2.w 4,5,2,2
	PIX4_2_2.w 5,5,2,2

avi_cram16_c1_grey:
	TO_GREY d7
_avi_cram8_c1:
	and #$ff,d7
	move d7,d0
	lsl #8,d0
	or d0,d7		; repeats d7 into high byte
	move d7,d0
	swap d0
	move d7,d0	; and repeats into high word
	rept 4
	move.l d0,(a3)+
	add d3,a3
	endr
	rts

avi_cram16_c2_grey:
	TO_GREY d4
	TO_GREY d5
_avi_cram16_c2_grey:
_avi_cram8_c2:
	moveq #0,d0
	move.b d6,d0
	and.w #$F0,d6
	lsl.b #4,d0
	jmp .premier_cram2(pc,d0.l)
.premier_cram2:
	PIX4_2_1.b 4,4,4,4
	PIX4_2_1.b 5,4,4,4
	PIX4_2_1.b 4,5,4,4
	PIX4_2_1.b 5,5,4,4
	PIX4_2_1.b 4,4,5,4
	PIX4_2_1.b 5,4,5,4
	PIX4_2_1.b 4,5,5,4
	PIX4_2_1.b 5,5,5,4
	PIX4_2_1.b 4,4,4,5
	PIX4_2_1.b 5,4,4,5
	PIX4_2_1.b 4,5,4,5
	PIX4_2_1.b 5,5,4,5
	PIX4_2_1.b 4,4,5,5
	PIX4_2_1.b 5,4,5,5
	PIX4_2_1.b 4,5,5,5
	PIX4_2_1.b 5,5,5,5
.second_cram2:
	PIX4_2_2.b 4,4,4,4
	PIX4_2_2.b 5,4,4,4
	PIX4_2_2.b 4,5,4,4
	PIX4_2_2.b 5,5,4,4
	PIX4_2_2.b 4,4,5,4
	PIX4_2_2.b 5,4,5,4
	PIX4_2_2.b 4,5,5,4
	PIX4_2_2.b 5,5,5,4
	PIX4_2_2.b 4,4,4,5
	PIX4_2_2.b 5,4,4,5
	PIX4_2_2.b 4,5,4,5
	PIX4_2_2.b 5,5,4,5
	PIX4_2_2.b 4,4,5,5
	PIX4_2_2.b 5,4,5,5
	PIX4_2_2.b 4,5,5,5
	PIX4_2_2.b 5,5,5,5

;	btst #0,d6
;	bne.s .lb0
;	move.b d4,(a3)+
;	bra.s .lb1
;.lb0:
;	move.b d5,(a3)+
;.lb1:
;	btst #1,d6
;	bne.s .lb2
;	move.b d4,(a3)+
;	bra.s .lb3
;.lb2:
;	move.b d5,(a3)+
;.lb3:
;	btst #2,d6
;	bne.s .lb4
;	move.b d4,(a3)+
;	bra.s .lb5
;.lb4:
;	move.b d5,(a3)+
;.lb5:
;	btst #3,d6
;	bne.s .lb6
;	move.b d4,(a3)+
;	bra.s .lb7
;.lb6:
;	move.b d5,(a3)+
;.lb7:
;	add.l d3,a3
;	btst #4,d6
;	bne.s .lb8
;	move.b d4,(a3)+
;	bra.s .lb9
;.lb8:
;	move.b d5,(a3)+
;.lb9:
;	btst #5,d6
;	bne.s .lb10
;	move.b d4,(a3)+
;	bra.s .lb11
;.lb10:
;	move.b d5,(a3)+
;.lb11:
;	btst #6,d6
;	bne.s .lb12
;	move.b d4,(a3)+
;	bra.s .lb13
;.lb12:
;	move.b d5,(a3)+
;.lb13:
;	btst #7,d6
;	bne.s .lb14
;	move.b d4,(a3)+
;	bra.s .lb15
;.lb14:
;	move.b d5,(a3)+
;.lb15:
;	add.l d3,a3
;	rts

avi_cram16_c4_grey:
	TO_GREY d4
	TO_GREY d5
	TO_GREY d2
	TO_GREY d1
_avi_cram8_c4:
	moveq #0,d0
	move.b d6,d0
	and.w #$F0,d6
	lsl.b #4,d0
	jmp .premier_cram2(pc,d0.l)
.premier_cram2:
	PIX4_2_1.b 4,4,1,1
	PIX4_2_1.b 5,4,1,1
	PIX4_2_1.b 4,5,1,1
	PIX4_2_1.b 5,5,1,1
	PIX4_2_1.b 4,4,2,1
	PIX4_2_1.b 5,4,2,1
	PIX4_2_1.b 4,5,2,1
	PIX4_2_1.b 5,5,2,1
	PIX4_2_1.b 4,4,1,2
	PIX4_2_1.b 5,4,1,2
	PIX4_2_1.b 4,5,1,2
	PIX4_2_1.b 5,5,1,2
	PIX4_2_1.b 4,4,2,2
	PIX4_2_1.b 5,4,2,2
	PIX4_2_1.b 4,5,2,2
	PIX4_2_1.b 5,5,2,2
.second_cram2:
	PIX4_2_2.b 4,4,1,1
	PIX4_2_2.b 5,4,1,1
	PIX4_2_2.b 4,5,1,1
	PIX4_2_2.b 5,5,1,1
	PIX4_2_2.b 4,4,2,1
	PIX4_2_2.b 5,4,2,1
	PIX4_2_2.b 4,5,2,1
	PIX4_2_2.b 5,5,2,1
	PIX4_2_2.b 4,4,1,2
	PIX4_2_2.b 5,4,1,2
	PIX4_2_2.b 4,5,1,2
	PIX4_2_2.b 5,5,1,2
	PIX4_2_2.b 4,4,2,2
	PIX4_2_2.b 5,4,2,2
	PIX4_2_2.b 4,5,2,2
	PIX4_2_2.b 5,5,2,2

;	bne.s .lb0
;	move.b d4,(a3)+
;	bra.s .lb1
;.lb0:
;	move.b d5,(a3)+
;.lb1:
;	btst #1,d6
;	bne.s .lb2
;	move.b d4,(a3)+
;	bra.s .lb3
;.lb2:
;	move.b d5,(a3)+
;.lb3:
;	btst #2,d6
;	bne.s .lb4
;	move.b d1,(a3)+
;	bra.s .lb5
;.lb4:
;	move.b d2,(a3)+
;.lb5:
;	btst #3,d6
;	bne.s .lb6
;	move.b d1,(a3)+
;	bra.s .lb7
;.lb6:
;	move.b d2,(a3)+
;.lb7:
;	add.l d3,a3
;	btst #4,d6
;	bne.s .lb8
;	move.b d4,(a3)+
;	bra.s .lb9
;.lb8:
;	move.b d5,(a3)+
;.lb9:
;	btst #5,d6
;	bne.s .lb10
;	move.b d4,(a3)+
;	bra.s .lb11
;.lb10:
;	move.b d5,(a3)+
;.lb11:
;	btst #6,d6
;	bne.s .lb12
;	move.b d1,(a3)+
;	bra.s .lb13
;.lb12:
;	move.b d2,(a3)+
;.lb13:
;	btst #7,d6
;	bne.s .lb14
;	move.b d1,(a3)+
;	bra.s .lb15
;.lb14:
;	move.b d2,(a3)+
;.lb15:
;	add.l d3,a3
;	rts

c256 set 0						; 0 = NOVA 32k or Falc 32k, 1 = NOVA 256c

	rept 2

	if c256=0
decode_cram8:
	lea cvid_fix0,a1		; pointer for the palette to 16bits conversion
	else
decode_cram8_256:
	endif
	move.l buffer,a2			; the datas
	move screenw,d3
	move d3,d0
	addq #4,d3
	if c256=0
		add d3,d3					; row dec, 1pixel is 2 bytes
	endif
	moveq #0,d6
	move max_imagey,d7
	move.l image,a0
	subq #1,d7
	muls d7,d0
	swap d7
	ext.l d3
	if c256=0
		add.l d0,d0
	endif
	add.l d0,a0
	neg.l d3
	if c256=1
		lea 16(a0,d3.l*4),a4		; bloc ligne suivante
	else
		lea 32(a0,d3.l*4),a4
	endif
.loop:
	swap d6
	tst.l d7
	bmi .exit
	clr d6
	clr d7
	move.b (a2)+,d6				; code0
	move.b (a2)+,d7				; code1
	cmp #$84,d7
	bmi.s .blocs
	cmp #$88,d7
	bpl.s .blocs
	moveq #0,d1
	sub #$84,d7						; skip
	lsl #8,d7
	move d7,d1
	add d6,d1
	moveq #0,d2
	swap d6
	lsl.l #2,d1						; nombre de pixels a sauter
	moveq #0,d4
	move d6,d2						; X
	move max_imagex,d4
	add.l d1,d2
	swap d7
	sub.l a4,a0
.skip:
	cmp.l d4,d2
	bmi.s .lb0			;okay fin de skip
	sub.l d4,d2
	subq #4,d7
	sub.l d4,d1
	if c256=1
		lea 16(a4,d3.l*4),a4		; bloc ligne suivante
	else
		lea 32(a4,d3.l*4),a4
	endif
	bra.s .skip
.lb0:
	add.l a4,a0
	move d2,d6
	add.l d1,a0
	swap d7
	if c256=0
		add.l d1,a0
	endif
	bra.s .loop
.blocs:
	move.l a0,a3
	cmp #$90,d7
	bmi.s .lb1
	if c256=0
		moveq #0,d5
		moveq #0,d4
		moveq #0,d2
		moveq #0,d1
	endif
	move.b (a2)+,d5		; cb0
	move.b (a2)+,d4		; ca0
	move.b (a2)+,d2		; cb1
	move.b (a2)+,d1		; ca1
	if c256=0
		move (a1,d5.l*2),d5
		move (a1,d4.l*2),d4
		move (a1,d2.l*2),d2
		move (a1,d1.l*2),d1
		bsr avi_cram16_c4
	else
		bsr _avi_cram8_c4
	endif
	move d7,d6
	if c256=0
		moveq #0,d5
		moveq #0,d4
		moveq #0,d2
		moveq #0,d1
	endif
	move.b (a2)+,d5
	move.b (a2)+,d4
	move.b (a2)+,d2
	move.b (a2)+,d1
	if c256=0
		move (a1,d5.w*2),d5
		move (a1,d4.w*2),d4
		move (a1,d2.w*2),d2
		move (a1,d1.w*2),d1
		bsr avi_cram16_c4
	else
		bsr _avi_cram8_c4
	endif
	bra.s .inc_bloc
.lb1:
	cmp #$80,d7
	bpl.s .lb2
	if c256=0
		moveq #0,d5
		moveq #0,d4
	endif
	move.b (a2)+,d5
	move.b (a2)+,d4
	if c256=0
		move (a1,d5.l*2),d5
		move (a1,d4.l*2),d4
		bsr avi_cram16_c2
		move d7,d6
		bsr avi_cram16_c2
	else
		bsr _avi_cram8_c2
		move d7,d6
		bsr _avi_cram8_c2
	endif
	bra.s .inc_bloc
.lb2:
	if c256=0
		move (a1,d6.w*2),d7
		bsr avi_cram16_c1
	else
		move.b d6,d7
		bsr _avi_cram8_c1
	endif
.inc_bloc:
	swap d6
	addq #4,d6
	if c256=1
		addq.l #4,a0
	else
		addq.l #8,a0
	endif
	cmp max_imagex,d6
	bmi .loop
	clr d6
	swap d7
	move.l a4,a0
	subq #4,d7
	if c256=1
		lea 16(a0,d3.l*4),a4		; bloc ligne suivante
	else
		lea 32(a0,d3.l*4),a4
	endif
	swap d7
	bra .loop
.exit:
	rts

c256 set 1+c256
	endr


c256 set 0							; 0=32k, 1=256colors, for rle8 and rgb

	rept 2

	if 1=0

	if c256=0
decode_rle8:
	lea cvid_fix0,a1				; the palette pointer
	else
decode_rle8_256:
	endif
	moveq #0,d0						; x
	move max_imagey,d1
	subq #1,d1						; y
	move max_imagex,d4			; imagex
	move.l image,a4				; screen memory
	move.l buffer,a2
;	move.l bufused,d2
;	subq.l #1,d2
.while:
	tst d1
	bpl.s .lb0
.end:
	rts
.lb0:
;	tst.l d2
;	bmi.s .end
	moveq #0,d6
	move.b (a2)+,d6				; mod
	moveq #0,d7
	move.b (a2)+,d7				; opcode
;	subq.l #2,d2
	tst.b d6							; jumps if mod<>0
	bne .lb8
	tst.b d7							; if opcode=0
	bne.s .lb3
.lb2:
	cmp d0,d4						; while x> imagex
	bpl.s .lb1
	sub d4,d0
	subq #1,d1
	bra.s .lb2
.lb1:
	moveq #0,d0
	subq #1,d1
	bra.s .while
.lb3:
	cmp.b #1,d7						; if opcode=1
	bne.s .lb4
	moveq #-1,d1
	bra.s .while
.lb4:
	cmp.b #2,d7						; if opcode=2
	bne.s .lb5
	moveq #0,d5
	move.b (a2)+,d5
	add d5,d0						; x=x+*dptr++
	move.b (a2)+,d5
	sub d5,d1						; y=y-*dptr++
;	subq.l #2,d2
	bra.s .while
.lb5:									; else (for opcode)
;	sub.l d7,d2
	move.l a4,a3
	move d1,d3
	muls screenw,d3
	add.l d0,d3
	if c256=0
		add.l d3,d3
	endif
	add.l d3,a3						; image + y*imagex + x
	move d7,d5						; cnt
	bra.s .loop
.lb6:
	cmp d4,d0
	bmi.s .lb7
	sub d4,d0
	subq #1,d1
	move.l a4,a3
	move d1,d3
	muls screenw,d3
	add.l d0,d3
	if c256=0
		add.l d3,d3
	endif
	add.l d3,a3						; image + y*imagex + x
	bra.s .lb6
.lb7:
	if c256=1
		move.b (a2)+,(a3)+
	else
		move.b (a2)+,d6
		move (a1,d6.w*2),(a3)+
	endif
	addq #1,d0
.loop:
	dbf d5,.lb6
	btst #0,d7
	beq .while
	addq.l #1,a2
;	subq.l #1,d2
	bra .while
.lb8:
	move.l a4,a3
	move d1,d3
	muls screenw,d3
	add.l d0,d3
	if c256=0
		add.l d3,d3
	endif
	add.l d3,a3						; image + y*imagex + x
	move d6,d5						; cnt
	if c256=0
		move (a1,d7.w*2),d7
	endif
	bra.s .loop2
.lb9:
	cmp d4,d0
	bmi.s .lb10
	sub d4,d0
	subq #1,d1
	move.l a4,a3
	move d1,d3
	muls screenw,d3
	add.l d0,d3
	if c256=0
		add.l d3,d3
	endif
	add.l d3,a3						; image + y*imagex + x
	bra.s .lb9
.lb10:
	if c256=1
		move.b d7,(a3)+
	else
		move d7,(a3)+
	endif
	addq #1,d0
.loop2:
	dbf d5,.lb9
	bra .while

	else

	if c256=0
decode_rle8:
	lea cvid_fix0,a1				; the palette pointer
	else
decode_rle8_256:
	endif
	move max_imagey,d1
	subq #1,d1						; y
	move screenw,d4
	if c256=0
		add d4,d4
	endif
	move d4,d0
	muls d1,d0
	move.l image,a4				; screen memory
	add.l d0,a4						; last line
	move.l a4,a3
	move.l buffer,a2
.while:
	tst d1
	bpl.s .lb0
.end:
	rts
.lb0:
	moveq #0,d6
	move.b (a2)+,d6				; mod
	bne.s .lb8
	move.b (a2)+,d6				; opcode
	bne.s .lb3
	sub d4,a4						; mod=opcode=0, previous line
	move.l a4,a3					; new pos
	subq #1,d1
	bra.s .while
.lb3:
	cmp.b #1,d6						; if opcode=1
	bne.s .lb4
	moveq #-1,d1					; end of frame
	bra.s .while
.lb4:
	cmp.b #2,d6						; if opcode=2
	bne.s .lb5
	moveq #0,d0
	moveq #0,d5
	move.b (a2)+,d0
	if c256=0
		add d0,d0
	endif
	add d0,a3
	move.b (a2)+,d5
	beq.s .lb0
	sub d5,d1
	muls d4,d5						; number of lines
	sub.l d5,a4
	sub.l d5,a3
	bra.s .while
.lb5:									; else (for opcode)
	move d6,d5						; cnt
	moveq #0,d0
	bra.s .loop
.lb6:
	if c256=1
		move.b (a2)+,(a3)+
	else
		move.b (a2)+,d0
		move (a1,d0.w*2),(a3)+
	endif
.loop:
	dbf d5,.lb6
	btst #0,d6
	beq.s .lb0
	addq.l #1,a2
	bra.s .lb0
.lb8:
	move d6,d5		; cnt
	move.b (a2)+,d6
	if c256=0
		move (a1,d6.w*2),d6
	endif
	bra.s .loop2
.lb9:
	if c256=1
		move.b d6,(a3)+
	else
		move d6,(a3)+
	endif
.loop2:
	dbf d5,.lb9
	bra.s .lb0

	endif

	if c256=0
decode_rgb:
	lea cvid_fix0,a1
	else
decode_rgb_256:
	endif
	move.l image,a3
	move.l buffer,a2
	move max_imagex,d0
	move d0,d7
	addq #1,d7
	bclr #0,d7				; for the next line into buffer
	move max_imagey,d1
	move screenw,d4
	move d4,d3
	if c256=0
		add d3,d3			; for the next line into video ram
	endif
	cmp d4,d0
	bpl.s .lb0
	move d0,d4				; if image to large
.lb0:
	move screenh,d5
	move d1,d0				; y
	subq #1,d0
	muls d3,d0
	add.l d0,a3				; last line pointer
.lb4:
	cmp d1,d5				; under the screen?
	bpl.s .lb5				; no, ok
	subq #1,d1				; else one line skipped
	sub d3,a3				; one upinto screen
	add d7,a2				; one down into buffer
	bra.s .lb4
.lb5:
	moveq #0,d0
	bra.s .loop
.lb1:
	move.l a3,a5
	move.l a2,a4
	move d4,d6
	bra.s .line
.lb2:
	if c256=0
		move.b (a4)+,d0
		move (a1,d0.w*2),(a5)+
	else
		move.b (a4)+,(a5)+
	endif
.line:
	dbf d6,.lb2
	sub d3,a3
	add d7,a2
.loop:
	dbf d1,.lb1
	rts

	if c256=0
bat_ximg:
	else
bat_ximg_256:
	tst.b mountain
	bne _convert256
	endif
	move.l buffer,a2
	add.l tgac_offset,a2		; en cas de MSVC on d‚compresse dans buffer
	move.l 16(a2),d0
	or.l #$20202020,d0
	cmp.l #'ximg',d0
	beq.s .ok
.quit:
	rts				; not a ximg file!
.ok:
	cmp #8,4(a2)	; number of planes
	bne.s .quit		; only 256 colors accepted
	move 6(a2),d0	; pattern
	bne.s .lb1
	moveq #1,d0
.lb1:
	move d0,pattern
	if c256=0
		lea cvid_fix0,a6	; palette pointer
	endif
	tst.b bat_getp	; read palette?

	if c256=0
	beq.s .end_head

	lea 22(a2),a0	; palette VDI
	lea indexs,a1
	move #255,d7	; 256 colors
	tst.b nova
	beq.s .falcon
.lb0:
		move (a0)+,d0	; red
		lsr #5,d0
		lsl.b #2,d0
		move (a0)+,d1	; green
		lsr #5,d1
		ror #3,d1
		or d1,d0
		move (a0)+,d1	; blue
		lsr #5,d1
		lsl #8,d1
		or d1,d0
	move d0,(a6)+
	dbf d7,.lb0
	lea cvid_fix0,a6
	bra.s .end_head
.falcon:
		move (a0)+,d0	; red
		lsr #5,d0
		ror #5,d0
		move (a0)+,d1	; green
		lsr #4,d1
		lsl #5,d1
		or d1,d0
		move (a0)+,d1	; blue
		lsr #5,d1
		or d1,d0
	move d0,(a6)+
	dbf d7,.falcon
	lea cvid_fix0,a6

	else

	beq .end_head

	lea 22(a2),a5
	tst.b create_mov
	bne.s .mov_make
	move.l a2,-(sp)
	lea indexs,a4
	move #255,d7
.lb0:
	lea vs_int,a0
	move (a4)+,(a0)+
		move.l (a5)+,(a0)+
		move (a5)+,(a0)
	GEM_VDI vs_color
	dbf d7,.lb0
	move.l (sp)+,a2
	bra .end_head
.mov_make:
	tst.b create_avi
	bne.s .avi_make
	moveq #0,d7
	move.l mov_pal,a0
	clr.l (a0)+
	clr (a0)+
	clr.b (a0)+
	st (a0)+
.mov_loop:
	move d7,(a0)+		; index
		rept 3
			move (a5)+,d0
			muls #131,d0
			asr.l #1,d0
			move d0,(a0)+
		endr
	addq #1,d7
	cmp #256,d7
	bne.s .mov_loop
	bra.s .end_head
.avi_make:
	move.l header_buffer,a0
	move #255,d7
	tst.b create_avi
	bmi.s .avi_loop
	lea cvid_fix0,a6
.msvc_loop:
	moveq #0,d3
	move (a5)+,d2
	move (a5)+,d3
	add d3,d3
	add d2,d3
	move d3,d2
	add d3,d3
	add d2,d3
	add (a5)+,d3
	lsl.l #3,d3			; de 0 … 80000
	divs #313,d3			; de 0 a 255
	move.b d3,(a6)+			; pour transformer les indexs en gris
	dbf d7,.msvc_loop
	bra.s .end_head
.avi_loop:
		addq.l #3,a0
		rept 3
			move (a5)+,d0
			lsr #2,d0
			move.b d0,-(a0)
		endr
		addq.l #3,a0
	sf (a0)+			; 0
	dbf d7,.avi_loop

	endif

.end_head:
	tst.b is_vidi
	beq.s .decomp_ximg
	lea 1558(a2),a0		; data apres palette
	bsr.l _buf_to_tc_256	; vers ecran!
	rts
.decomp_ximg:
	move 12(a2),d0
	addq #7,d0
	and.b #$F8,d0
	move d0,a4	; image width
	move 14(a2),y	; image height
	move 2(a2),d0	; header in words
	lea (a2,d0.w*2),a2	; datas
	move.l image,a3
.next_line:
	lea cvid_fix0+512,a0	; one line decompressed
	lea (a0,a4.w),a5	; end of one ligne uncompressed
	move.b #1,dup_line
.uncomp:
	cmp.l a5,a0
	bpl.s .end_of_line
	moveq #0,d0
	move.b (a2)+,d0
	bne.s .other
	move.b (a2)+,d0	; second byte
	bne.s .pat_run
	cmp.b #$ff,(a2)+
	bne .quit			; error
	move.b (a2)+,dup_line
	bra.s .uncomp
.pat_run:
	move pattern,d1
	move d1,d2
	subq #1,d2
	bra.s .p1
.p0:
	move d2,d3
	move.l a2,a1
.p2:
	move.b (a1)+,(a0)+
	dbf d3,.p2
.p1:
	dbf d0,.p0
	add d1,a2
	bra.s .uncomp
.other:
	cmp.b #$80,d0
	bne.s .solid
	move.b (a2)+,d0	; how many
	bra.s .o1
.o0:
	move.b (a2)+,(a0)+
.o1:
	dbf d0,.o0
	bra.s .uncomp
.solid:
	bclr #7,d0
	bne.s .black
	bra.s .white
.w0:
	sf (a0)+
.white:
	dbf d0,.w0
	bra.s .uncomp
.b0:
	st (a0)+
.black:
	dbf d0,.b0
	bra.s .uncomp
.end_of_line:
	move a4,d0
	lsr #3,d0		; bytes for one plane
	lea cvid_fix0+512,a0
	lea (a0,d0.w),a5	; end of the 1st plane for the loop
	move.l a3,-(sp)	; if it's to be repeated!
.next_8_pixels:
	move.l a0,a1
	move.b (a1),d0
	ror.l #8,d0
	move a4,d0
	lsr #3,d0
	add d0,a1
	move.b (a1),d1
	add d0,a1
	move.b (a1),d2
	add d0,a1
	move.b (a1),d3
	add d0,a1
	move.b (a1),d4
	add d0,a1
	move.b (a1),d5
	add d0,a1
	move.b (a1),d6
	add d0,a1
	move.b (a1),d7
	move #8,a1		; a loop
.pixel:
	lsl.b #1,d7
	roxl #1,d0
	lsl.b #1,d6
	roxl #1,d0
	lsl.b #1,d5
	roxl #1,d0
	lsl.b #1,d4
	roxl #1,d0
	lsl.b #1,d3
	roxl #1,d0
	lsl.b #1,d2
	roxl #1,d0
	lsl.b #1,d1
	roxl #1,d0
	rol.l #1,d0
	if c256=0
		and #$FF,d0
		move (a6,d0.w*2),(a3)+
	else
		move.b d0,(a3)+
	endif
	subq #1,a1
	cmp #0,a1
	bne.s .pixel
	addq.l #1,a0
	cmp.l a5,a0
	bmi.s .next_8_pixels
.copy_line:
	move screenw,d3
	sub a4,d3
	if c256=0
		add d3,d3
	endif
	add d3,a3
	move.l (sp)+,a5		; old a3
	subq.b #1,dup_line
	beq.s .other_line
	subq #1,y
	move.l a3,-(sp)
	move a4,d0
	bra.s .cp1
.cp0:
	if c256=0
		move (a5)+,(a3)+
	else
		move.b (a5)+,(a3)+
	endif
.cp1:
	dbf d0,.cp0
	bra.s .copy_line
.other_line:
	subq #1,y
	bne .next_line
	rts

c256 set 1+c256

	endr

_convert256:
	move.l vanel_adr,a0
		cmp #$7fff,quality			; q=5?
		beq _dither216
	move.l 4(a0),d0				; numero d'image
	bne.s .pas_premier
	move.l #32768,d1
	bsr malloc
	move.l d0,hc_cvid
	bsr gen_16_to_grey
	moveq #-1,d0
	move #255,d1
	tst.b create_avi
	beq.s .pas_avi
	move.l header_buffer,a0
	sf d0
.avi_pal:
	move.l d0,(a0)+
	sub.l #$01010100,d0
	dbf d1,.avi_pal
	bra.s .pas_premier
.pas_avi:
	move.l mov_pal,a0
	clr.l (a0)+
	clr.w (a0)+
	move d1,(a0)+
	lea 2048(a0),a0
	moveq #0,d0
.move_pal:
	move d0,-(a0)
	move d0,-(a0)
	move d0,-(a0)
	move d1,-(a0)
	add #257,d0
	dbf d1,.move_pal
.pas_premier:
	move.l vanel_adr,a0
	move.l 8(a0),a1				; ses pixels
	move.l one_buffer,a2			; destination
	move max_imagey,d0
	subq #1,d0						; boucle
	move _vanel_line,d4
	move _vanel_plus,d5
	subq #1,d4						; for the loop
	move d4,d2
	move 12(a0),d1					; flag
	move.l hc_cvid,a0
	tst d1
	bne.s .falcon
.nova:
	move (a1)+,d1
	ror #8,d1
	bclr #15,d1
	move.b 0(a0,d1.w),(a2)+
	dbf d2,.nova
	move d5,d2
	bra.s .nov1
.efface:
	st (a2)+
.nov1:
	dbf d2,.efface
	move d4,d2
	dbf d0,.nova
	rts
.falcon:
	move (a1)+,d1
	NOVA16 d1
	move.b 0(a0,d1.w),(a2)+
	dbf d2,.falcon
	move d5,d2
	bra.s .fal1
.delete:
	st (a2)+
.fal1:
	dbf d2,.delete
	move d4,d2
	dbf d0,.falcon
	rts

magic:
   dc.b 34,5,21,44,32,3,20,42,33,4,21,43,35,6,22,44
   dc.b 15,50,28,12,13,48,26,10,14,49,27,11,15,51,28,12
   dc.b 31,8,18,47,29,7,16,45,30,8,17,46,32,9,19,48
   dc.b 25,41,37,2,23,39,36,0,24,40,37,1,25,41,38,3
   dc.b 33,4,20,43,35,6,22,45,34,5,21,43,33,4,20,42
   dc.b 14,49,27,10,16,51,29,13,14,50,27,11,13,49,26,10
   dc.b 30,7,17,46,32,9,19,48,31,8,18,47,30,7,17,46
   dc.b 23,39,36,1,26,42,38,3,24,40,37,2,23,39,36,1
   dc.b 34,5,21,44,33,4,20,42,33,4,20,43,35,6,22,45
   dc.b 15,50,28,11,13,49,26,10,14,49,27,11,16,51,29,12
   dc.b 31,8,18,47,29,7,16,45,30,7,17,46,32,9,19,48
   dc.b 24,40,37,2,23,39,36,0,24,40,36,1,25,41,38,3
   dc.b 34,5,21,43,35,6,22,44,34,5,22,44,32,3,19,42
   dc.b 14,50,27,11,15,51,28,12,15,50,28,12,13,48,26,10
   dc.b 30,8,18,46,31,9,19,47,31,9,18,47,29,6,16,45
   dc.b 24,40,37,1,25,41,38,2,25,41,38,2,23,39,35,0
col_mod:
	dc.b 0,8,16,24,32,40,48,5,13,21,29,37,45,2,10,18,26,34,42,40,7,15,23,31,39,47,4,12,20,28,36,0
bleu_div:
	dc.b 0,0,0,0,0,0,0,36,36,36,36,36,36,72,72,72,72,72,72,72,108,108,108,108,108,108,144,144,144,144,144,180
	dc.b 0,0,0,0,0,0,0,6,6,6,6,6,6,12,12,12,12,12,12,12,18,18,18,18,18,18,24,24,24,24,24,30
	dc.b 0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,5

_dither216:
	move.l 4(a0),d0
	bne.s .pas_premier
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	tst.b create_avi
	beq.s .pas_avi
	move.l header_buffer,a0
	moveq #51,d0
.avi_1:
	move.b d3,(a0)+
	move.b d2,(a0)+
	move.b d1,(a0)+
	sf (a0)+
	add.b d0,d1
	bcc.s .avi_1
	moveq #0,d1
	add.b d0,d2
	bcc.s .avi_1
	moveq #0,d2
	add.b d0,d3
	bcc.s .avi_1
	moveq #39,d0
.avi_2:
	clr.l (a0)+
	dbf d0,.avi_2
	bra.s .pas_premier
.pas_avi:
	move.l mov_pal,a0
	clr.l (a0)+
	clr (a0)+
	clr.b (a0)+
	st (a0)+
	move #13107,d0
	moveq #0,d4
.mov_1:
	move d4,(a0)+
	move d1,(a0)+
	move d2,(a0)+
	move d3,(a0)+
	addq #1,d4
	add d0,d1
	bcc.s .mov_1
	moveq #0,d1
	add d0,d2
	bcc.s .mov_1
	moveq #0,d2
	add d0,d3
	bcc.s .mov_1
	moveq #39,d0
.mov_2:
	move d4,(a0)+
	clr.l (a0)+
	clr (a0)+
	dbf d0,.mov_2
.pas_premier:
	move.l vanel_adr,a0
	move.l 8(a0),a1				; ses pixels
	move 12(a0),d1					; le flag
	lea col_mod(pc),a0			; modulos et quotients
	move.l one_buffer,a3			; destination
	move max_imagey,d6
	subq #1,d6						; boucle
	move _vanel_line,d4
	move _vanel_plus,d5
	subq #1,d4						; for the loop
	lea magic(pc),a2
	cmp #$FFFF,d1
	beq.s .fligne						; pixels Falcon
.ligne:
	move d4,d7
	lea 16(a2),a4					; fin ligne magic
.pixel:
	move (a1)+,d0					; un pixel NOVA
	move.b (a2)+,d2				; magic (x,y)
	ror #8,d0
	move d0,d1
	and #$1F,d0						; bleu
	move.b 32(a0,d0.w),d3		; le pixel 216
	cmp.b 0(a0,d0.w),d2
	bcc.s .pas_bleu
	add.b #36,d3
.pas_bleu:
	lsr #5,d1
	move d1,d0
	and #$1F,d1						; vert
	add.b 64(a0,d1.w),d3
	cmp.b 0(a0,d1.w),d2
	bcc.s .pas_vert
	addq.b #6,d3
.pas_vert:
	lsr #5,d0						; rouge
	and #$1F,d0
	add.b 96(a0,d0.w),d3
	cmp.b 0(a0,d0.w),d2
	bcc.s .pas_rouge
	addq.b #1,d3
.pas_rouge:
	move.b d3,(a3)+
	cmp.l a2,a4						; fin ligne (magic)?
	bne.s .pas_fin
	lea -16(a4),a2					; recule de 16 positions
.pas_fin:
	dbf d7,.pixel
	move d5,d7
	bra.s .nov1
.efface:
	sf (a3)+
.nov1:
	dbf d7,.efface
	cmp.l #magic+256,a4
	bne.s .pas_fin_magic
	lea -256(a4),a4
.pas_fin_magic:
	move.l a4,a2
	dbf d6,.ligne
	rts
.fligne:
	move d4,d7
	lea 16(a2),a4					; fin ligne magic
.fpixel:
	move (a1)+,d0					; un pixel Falcon
	move.b (a2)+,d2				; magic (x,y)
	move d0,d1
	and #$1F,d0						; bleu
	move.b 32(a0,d0.w),d3		; le pixel 216
	cmp.b 0(a0,d0.w),d2
	bcc.s .fpas_bleu
	add.b #36,d3
.fpas_bleu:
	lsr #6,d1
	move d1,d0
	and #$1F,d1						; vert
	add.b 64(a0,d1.w),d3
	cmp.b 0(a0,d1.w),d2
	bcc.s .fpas_vert
	addq.b #6,d3
.fpas_vert:
	lsr #5,d0						; rouge
	add.b 96(a0,d0.w),d3
	cmp.b 0(a0,d0.w),d2
	bcc.s .fpas_rouge
	addq.b #1,d3
.fpas_rouge:
	move.b d3,(a3)+
	cmp.l a2,a4						; fin ligne (magic)?
	bne.s .fpas_fin
	lea -16(a4),a2					; recule de 16 positions
.fpas_fin:
	dbf d7,.fpixel
	move d5,d7
	bra.s .fnov1
.fefface:
	sf (a3)+
.fnov1:
	dbf d7,.fefface
	cmp.l #magic+256,a4
	bne.s .fpas_fin_magic
	lea -256(a4),a4
.fpas_fin_magic:
	move.l a4,a2
	dbf d6,.fligne
	rts
								; fin de dithering 216

; d0 = alert number

ooops:								; when an error occurs
	move.l d0,-(sp)				; saves the alert number
	tst.b display					; form_dial called?
	beq.s .lb0						; no, jump!
	move #3,fd_int
	GEM_AES form_dial				; updates the screen
	sf display
.lb0:
	tst.b command
	beq.s .lb1
	tst.b cmd_return
	bne.l end_end
	tst.b cmd_erro
	bne.s .lb1
	addq.l #4,sp					; drops d0
	bra.s .lb2
.lb1:
	move.l (sp)+,d0				; alert number is back !
	bsr.s alert						; alert box
.lb2:
	st stopped
	bra.l end_of_display			; and exits

; d0 = alert number or address
; to detect address, d0 and $FFFFFF00 not nul

alert:
;	clr mf_int
;	GEM_AES graf_mouse			; the busy bee
;	GEM_VDI show_mouse			; the mouse is required for an alert box
	move.l d0,d1
	and.l #$FFFFFF00,d1
	bne.s .lb0						; if not nul, d0=address
	move.l ([alert_adr],d0.l*4),d0	; else index in table
.lb0:
	move.l d0,ab_addrin
	GEM_AES alert_box				; form alert
	move intout,-(sp)				; the exit button is saved
;	GEM_VDI hide_mouse			; hides the mouse
	move (sp)+,d0					; the exit button is returned into D0
	rts

read_byte:
	pea dum
	move.l #1,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	moveq #0,d0
	move.b dum,d0
	rts

	; reads a word from MOV file and returns it into D0 (long extended)
read_word:
	pea dum
	move.l #2,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move dum,d0
	ext.l d0
	rts
	; read a long word from MOV file and returns it into D0
read_long:
	pea dum
	move.l #4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l dum,d0
	rts
	; reads two long words from MOV file and returns then into D0(first)/D1
read_id_len:
read_len_id:
	pea dum
	move.l #8,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l dum,d0
	move.l dum+4,d1
	rts

read_3_long:
	pea dum
	move.l #12,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	lea dum,a0
	move.l (a0)+,d0
	move.l (a0)+,d1
	move.l (a0),d2
	rts

	if DBG=1
malloc2:
	add.l d1,d1
	endif

	; d1 is the size wanted
malloc:
	move.l d1,-(sp)
	GEMDOS 72,6
	tst.l d0
	bmi.s .lb0
	beq.s .lb0
	rts				; ok
.lb0:
	moveq #28,d0			; alert not enough memory
	bra ooops

	;a2 is the adress to free or 0 (it is checked inside)
mfree:
	cmp.l #0,a2
	beq.s .end
	bmi.s .end
	move.l a2,-(sp)
	GEMDOS 73,6
	tst d0
;	beq.s .end
;	nop
.end:
	rts

cookie:
	clr.l cpu_value
	clr.l vdo_value
	clr.l snd_value
	clr.l mch_value
	sf psnd_flag			; no parallel card
	sf albertt				; no alberTT card
	move.l $4f2.w,a0
	move.l 36(a0),kbshift	; address of the special keys
	move $1c(a0),d0
	lsr.b #1,d0				; code langue du TOS
	move.b d0,langue
	move.l $5A0.w,a0
	cmp.l #0,a0
	beq .end				; no cookie!
.lb0:
	tst.l (a0)
	beq .end
	cmp.l #'NOVA',(a0)	; a NOVA graphic card?
	bne.s .lb1
	st nova					; yes! nova = FF
	move.l 4(a0),a1
	move 12(a1),is_65k	; mode (3=32768)
	bra .lbnext
.lb1:
	cmp.l #'_VDO',(a0)
	bne.s .lb2
	move.l 4(a0),vdo_value
	bra .lbnext
.lb2:
	cmp.l #'MgMc',(a0)
	bne.s .lb3
	st magicmac
.lb21:
	st nova					; assumes that Mac video = NOVA Video
	bra .lbnext
.lb3:
	cmp.l #'MgMx',(a0)
	beq.s .lb21
	cmp.l #'_SND',(a0)
	bne.s .lb31
	move.l 4(a0),snd_value
	bra .lbnext
.lb31:
	cmp.l #'PSND',(a0)
	bne.s .lb32
	st psnd_flag
	bra .lbnext
.lb32:
	cmp.l #'EdDI',(a0)
	bne.s .lb33
	move.l 4(a0),ed_adr
	bra.s .lbnext
.lb33:
	cmp.l #'_MIL',(a0)	; MILAN = NOVA.
	bne.s .lb35
	st nova
	move #4,is_65k			; pas de 32768 support‚ (REVOIR CA AVEC MODE VDI)
	bra.s .lbnext
.lb35:
	cmp.l #'_CPU',(a0)
	bne.s .lb5
	move.l 4(a0),cpu_value
	bra.s .lbnext
.lb5:
	cmp.l #'_MCH',(a0)
	bne.s .lb4
	move.l 4(a0),mch_value
	bra.s .lbnext
.lb4:
	cmp.l #'XALT',(a0)
	bne.s .lb6
	st albertt				; albertt = tt video with display on Atari screen
	movem.l a0-a1,-(sp)
	lea albert_phys,a0
	lea $ffff8201.w,a1
	clr.b (a0)+				; upper part is null in ST RAM
	move.b (a1),(a0)+		; high byte of real physical address
	move.b 2(a1),(a0)+	; mid byte
	move.b 12(a1),(a0)	; low byte
	movem.l (sp)+,a0-a1
	bra.s .lbnext
.lb6:
	cmp.l #'_AKP',(a0)
	bne.s .lb7
	move.b 7(a0),langue
	bra.s .lbnext	
.lb7:
	nop
.lbnext:
	addq.l #8,a0			; next cookie
	bra .lb0
.end: 
	moveq #40,d0
	cmp.l cpu_value,d0			; a 68040
	bne.s .end2
	moveq #-1,d0
	cmp.l mch_value,d0	; and machine=-1 -> the Vampire V4 !!
	bne.s .end2
	moveq #5,d0
	swap d0
	move.l d0,mch_value	; Vampire acts like Aranym for graphics
.end2:
	rts

nova_adapt:
	tst.b is_65k
	bne.s falcon_adapt
	sf adapt_mode
_nova_adapt:
	lea hc_rmap,a0
	lea hc_gmap,a1
	lea hc_bmap,a2
	moveq #0,d3
.loop:
	move d3,d0
	lsl #2,d0		; red
	move d3,d1
	ror #3,d1		; green
	move d3,d2
	rol #8,d2		; blue
	moveq #7,d4
.lb0:
	move d0,(a0)+
	move d1,(a1)+
	move d2,(a2)+
	dbf d4,.lb0
	addq #1,d3
	cmp #32,d3
	bmi.s .loop
	tst.w bit_rot ; if 0, then big endian
	beq.s inverse_16bits;; so contrary of NOVA
	rts

falcon_adapt:
	st adapt_mode		; FF for falcon adapt
	lea hc_rmap,a0
	lea hc_gmap,a1
	lea hc_bmap,a2
	moveq #0,d3		; blue
.loop:
	move d3,d0
	ror #5,d0		; red
	move d3,d1
	rol #6,d1		; green
	moveq #7,d4
.lb0:
	move d0,(a0)+
	move d1,(a1)+
	move d3,(a2)+
	dbf d4,.lb0
	addq #1,d3
	cmp #32,d3
	bmi.s .loop
	tst.b is_65k
	bne.s inverse_16bits
	rts
inverse_16bits:
	move #255,d4
.lb1:
	move -(a0),d0
	move -(a1),d1
	move -(a2),d2
	ror #8,d0
	move d0,(a0)
	ror #8,d1
	move d1,(a1)
	ror #8,d2
	move d2,(a2)
	dbf d4,.lb1
	rts

	; the xbios palette (4096) into 16 bits (grey or color)

xbiospal_16:
	move bit_rot,d5
	lea cvid_fix1,a0
	lea 8192(a0),a1
	moveq #0,d0
.lb0:
	bfextu d0{20:4},d1	; red
	bfextu d0{24:4},d2	; green
	bfextu d0{28:4},d3	; blue
	add d1,d1
	bclr #4,d1
	beq.s .lb1
	addq #1,d1
.lb1:
	move d1,d4
	add d2,d2
	bclr #4,d2
	beq.s .lb2
	addq #1,d2
.lb2:
	lsl #4,d4
	or d2,d4
	add d3,d3
	bclr #4,d3
	beq.s .lb3
	addq #1,d3
.lb3:
	lsl #4,d4
	or d3,d4
		lsl #8,d1
		add d3,d3
		tst.b is_65k
		bne.s .falc
		tst.b nova
		beq.s .falc
		lsl #3,d1
		lsl #6,d2
		or d1,d2
		or d3,d2
		ror d5,d2
		bra.s .ok
		.falc:
		lsl #4,d1
		lsl #7,d2
		or d1,d2
		or d3,d2
		tst.b is_65k
		beq.s .ok
		ror #8,d2
.ok:
	move d2,(a0)+			; first table (st format)
	move d2,(a1,d4.w*2)	; second table (tt format)
	addq #1,d0
	cmp #4096,d0
	bmi.s .lb0
	rts

gen_16_to_grey:
	move.l hc_cvid,a6
_gen_16_to_grey:			; here with step by step and monochrome display
	moveq #0,d0				; brightness
	moveq #31,d1
.lb1:
	moveq #31,d2
.lb2:
	moveq #31,d3
.lb3:
	move.l d0,d4			; brightness from 0 to 310
	lsl.l #8,d4				;     "        "  0 to 79360
	divs #310,d4			;     "        "  0 to 255
	sub #255,d4
	bmi.s .lb4
	moveq #0,d4
.lb4:
	neg.b d4
	move.b d4,(a6)+		; the color index for that rgb
	addq.l #1,d0			; blue counts for 1
	dbf d3,.lb3
	sub.l #26,d0			; -32 (to reset the blue) and +6 (for the green)
	dbf d2,.lb2
	sub.l #189,d0			; -192 (to reset the green) and +3 (for the red)
	dbf d1,.lb1
	tst.b step_vdi
	beq.s .out
	move #8191,d0			; for step mode, only 0-127
	move.l #$7F7F7F7F,d2
.reduc:
	move.l -(a6),d1		; four bytes
	lsr.l #1,d1				; 0-255 to 0-127
	and.l d2,d1				; and remove unwanted bits
	move.l d1,(a6)
	dbf d0,.reduc
.out:
	rts

fast_y_to_grey:
	lea hc_rmap,a2
	lea hc_gmap,a3
	lea hc_bmap,a4
	move.l hc_cvid,a6
	moveq #127,d0
.lb0:
	move.l (a2)+,d1
	or.l (a3)+,d1
	or.l (a4)+,d1
	move d1,(a6)+
	dbf d0,.lb0
	rts

gen_yuv_tab:
	move #$100,d2			; y inc=1, one loop to 256
	move.l comp_txt,d1
	not.l d1
	cmp.l #$9689ccce,d1
	beq.s .iv
	cmp.l #$9689cccd,d1
	bne.s .not_invers
.iv:
	tst.b fast_mode
	bne.s fast_y_to_grey
	move #$201,d2			; y inc=2, 2 loops to 256
	lea qt_vr_tab,a0
	lea 32(a0),a1
	moveq #15,d0
.invers:
	add #44,64(a0)
	sub #44,64(a1)
	add #92,128(a0)
	sub #92,128(a1)
	sub #227,192(a0)
	add #227,192(a1)
	sub #180,(a0)+
	add #180,(a1)+
	dbf d0,.invers
.not_invers:
	move d2,-(sp)
	lea hc_rmap,a2
	lea hc_gmap,a3
	lea hc_bmap,a4
	move.l hc_cvid,a6
	lea qt_ug_tab,a0
	moveq #31,d0			; u
.loop_u:
	move 128(a0),d7		; ub_tab(u)
	move (a0)+,a5			; ug_tab(u)
	lea qt_vr_tab,a1
	moveq #31,d1			; v
.loop_v:
	move (sp),-(sp)
	move 128(a1),d5		; vg_tab(v)
	add a5,d5				; ug_tab(u) + vg_tab(v)
	move (a1)+,d4			; vr_tab(v)
	moveq #0,d2				; y
.loop_y:
	move d2,d3
	add d4,d3				; r
	bpl.s .lb0
	moveq #0,d3
.lb0:
	cmp #256,d3
	bmi.s .lb1
	move #255,d3
.lb1:
	moveq #0,d6
	move (a2,d3.w*2),d6	; rmap
	move d2,d3
	add d5,d3				; g
	bpl.s .lb2
	moveq #0,d3
.lb2:
	cmp #256,d3
	bmi.s .lb3
	move #255,d3
.lb3:
	add (a3,d3.w*2),d6	; rmap | gmap
	move d2,d3
	add d7,d3				; b
	bpl.s .lb4
	moveq #0,d3
.lb4:
	cmp #256,d3
	bmi.s .lb5
	move #255,d3
.lb5:
	add (a4,d3.w*2),d6	; rmap | gmap | bmap
	move d6,(a6)+			; into hc_cvid
	add.b (sp),d2
	bne.s .loop_y
	subq.b #1,1(sp)
	beq.s .loop_y
	addq.l #2,sp
	dbf d1,.loop_v
	dbf d0,.loop_u
	cmp.w #$201,(sp)+
	bne.s .not_revers
	lea qt_vr_tab,a0
	lea 32(a0),a1
	moveq #15,d0
.revers:
	sub #44,64(a0)
	add #44,64(a1)
	sub #92,128(a0)
	add #92,128(a1)
	add #227,192(a0)
	sub #227,192(a1)
	add #180,(a0)+
	sub #180,(a1)+
	dbf d0,.revers
.not_revers:
	rts


adapt_256:
	move.b #1,adapt_mode
	lea hc_rmap,a0
	lea hc_gmap,a1
	lea hc_bmap,a2
	moveq #0,d3		; blue
.loop:
	move d3,d0		; green
	add d0,d0
	move d0,d2
	add d0,d0
	add d2,d0		; green*6 for brightness
	move d3,d1
	add d1,d1
	add d3,d1		; red*3
	moveq #7,d4
.lb0:
	move d1,(a0)+
	move d0,(a1)+
	move d3,(a2)+
	dbf d4,.lb0
	addq #1,d3
	cmp #32,d3
	bmi.s .loop
	rts

set_colors:
	tst.b is_tt
	bne.s .tt_pal				; because of NVDI...
	lea indexs+512,a6		; starts with the black
	lea .offsets,a5
	moveq #0,d6					; the grey level (0 -> 1000)
.lb0:
	move.w (a5)+,d7
.lb1:
	lea vs_int,a0
	move -(a6),(a0)+
	bmi.s .end
	move d6,(a0)+
	move d6,(a0)+
	move d6,(a0)
	GEM_VDI vs_color
	subq #1,d7
	bmi.s .lb2
	addq #4,d6					; another grey level
	bra.s .lb1
.lb2:
	addq #3,d6
	lea vs_int,a0
	move -(a6),(a0)+
	bmi.s .end
	move d6,(a0)+
	move d6,(a0)+
	move d6,(a0)
	GEM_VDI vs_color
	bra.s .lb0
.end:
	rts
.tt_pal:
;	move.w #$FFF,d7
;	moveq #0,d6			; counter (0-255)
;.next:
;	moveq #15,d5		; counter (0-15)
;.tt_loop:
;	move d7,-(sp)
;	move d6,-(sp)
;	XBIOS 83,6			; esetcolor
;	addq #1,d6
;	dbf d5,.tt_loop
;	sub #$111,d7
;	bpl.s .next
;	rts
	tst.b albertt
	bne grey_albert
	move #1,-(sp)
	XBIOS 86,4			; esetgrey
	move #255,d7
	cmp #'mp',comp_txt
	beq.s .mpg
	moveq #0,d6
.next:
	move d7,-(sp)
	move d6,-(sp)
	XBIOS 83,6			; esetcolor
	addq #1,d6
	dbf d7,.next
	rts
.mpg:
	move d7,-(sp)		; couleurs inverses pour le MPG
	move d7,-(sp)
	XBIOS 83,6			; esetcolor
	dbf d7,.mpg
	rts
; first grey scale is 0, each entry indicates the number of times to add 4
; then we must add once 3.
.offsets: dc.w 6,12,11,12,12,12,11,12,12,12,11,12,12,12,11,12,12,12,11,12,6
			dc.w -1		; to end the index table
indexs: dc.w 0,2,3,6,4,7,5,8,9,10,11,14,12,15,13,255
a	set 16
	rept 239
	dc.w a
a  set a+1
	endr
	dc.w 1

grey_albert:
	pea .ga(pc)
	XBIOS 38,6
	rts
.ga:
	lea $FFFF8262.w,a0
	move.b (a0),d0
	bset #4,d0
	move.b d0,(a0)		; set gray mode
	move #255,d7
	cmp #'mp',comp_txt
	beq.s .mpg
	lea $FFFF8400.w,a0
.next:
	move d7,(a0)+
	dbf d7,.next
	rts
.mpg:
	lea $FFFF8600.w,a0
.nextmpg:
	move.w d7,-(a0)
	dbf d7,.nextmpg
	rts

grey_mov:
	move grey_depth,d0
	move planes,d1
	lea cvid_fix0,a6
	cmp #16,d1
	beq.s .tc
	move.l a6,a0			; for FLI color 256
	move #$0100,(a6)+		; one bloc
	clr.b (a6)+				; color start
	cmp #8,d0
	bne.s .fli1
	clr.b (a6)+				; 256 greys
	move #255,d0
	swap d0
	cmp #'IN',d0
	bne.s .normal
	add #768,a6
	swap d0
.lb44:
	move.b d0,-(a6)
	move.b d0,-(a6)
	move.b d0,-(a6)
	dbf d0,.lb44
	bra.s .go
.normal:
	swap d0
.lb4:
	move.b d0,(a6)+
	move.b d0,(a6)+
	move.b d0,(a6)+		; rvb
	dbf d0,.lb4
.go:
	bra.l fli_color_256_256
.fli1:
	cmp #4,d0
	bne.s .fli2
	move.b #16,(a6)+
	moveq #14,d0
	move #255,d1
.lb5:
	move.b d1,(a6)+
	move.b d1,(a6)+
	move.b d1,(a6)+
	sub #16,d1
	dbf d0,.lb5
	clr.l (a6)
	bra.s .go
.fli2:
	move.b #4,(a6)+
	move.l #$FFFFFFAA,(a6)+
	move.l #$AAAA5555,(a6)+
	move.l #$55000000,(a6)+
	bra.s .go
.tc:
	cmp #8,d0
	bne.s .tc1
	moveq #31,d0		; here, 256 grey
	cmp.l #'CDV1',comp_txt
	beq .tc_cd_stratos
	cmp #'mp',comp_txt ; mpg1 or mpg2
	beq .tc_cd_stratos
	move #$7FFF,d1
.lb0:
	move d1,d3
	ror #8,d3
	tst.b is_65k
	bne.s .lb00
	tst.b nova
	bne.s .lb1
.lb00:
	FALC16 d3
	tst.b is_65k
	beq.s .lb1
	ror #8,d3
.lb1:
	rept 8
	move d3,(a6)+
	endr
	sub #$421,d1
	dbf d0,.lb0
	rts
.tc1:
	cmp #4,d0
	bne.s .tc2
	moveq #16,d0		; here 16 grey
	move #$7FFF,d1
	bra.s .lb6
.lb2:
	move d3,(a6)+
	sub #$842,d1
.lb6:
	move d1,d3
	ror #8,d3
	tst.b is_65k
	bne.s .lb66
	tst.b nova
	bne.s .lb3
.lb66:
	FALC16 d3
	tst.b is_65k
	beq.s .lb3
	ror #8,d3
.lb3:
	dbf d0,.lb2
	rts
.tc2:
	tst.b is_65k
	bne.s .tc4
	tst.b nova
	bne.s .tc3
	move.l #$FFFF528A,(a6)+		; here 4 grey (Falcon)
	move.l #$29450000,(a6)+
	rts
.tc4:
	move.l #$FFFF8A52,(a6)+
	move.l #$45290000,(a6)+
	rts
.tc3:
	move.l #$FF7F4A29,(a6)+		; here 4 grey (NOVA)
	move.l #$a5140000,(a6)+
	rts
.tc_cd_stratos:
	moveq #0,d1
.cd_lb0:
	move d1,d3
	ror #8,d3
	tst.b is_65k
	bne.s .cd_lb00
	tst.b nova
	beq.s .cd_lb00
	tst bit_rot
	bne.s .cd_lb1
	ror #8,d3
	bra.s .cd_lb1
.cd_lb00:
	FALC16 d3
	tst.b is_65k
	beq.s .cd_lb1
	ror #8,d3
.cd_lb1:
	rept 8
	move d3,(a6)+
	endr
	add #$421,d1
	dbf d0,.cd_lb0
	cmp #'mp',comp_txt
	beq.s .pas_de_noir
	rept 8
	clr -(a6)			; 255 = black
	endr
.pas_de_noir:
	rts

save_256:
	lea col_sav,a6
	move #255,vq_int
.lb0:
	GEM_VDI vq_color
	lea intout+2,a0
	move.l (a0)+,(a6)+	; red+green
	move.w (a0),(a6)+		; blue
	subq #1,vq_int
	bpl.s .lb0
	rts

restore_256:
	tst.b slide_flag
	bne.s .out
	tst.b is_tt
	beq.s .lb1
	clr -(sp)
	XBIOS 86,4				; esetgray back to normal.
.lb1:
	lea col_sav,a6
	move #255,vs_int
.lb0:
	lea vs_int+2,a0
	move.l (a6)+,(a0)+
	move (a6)+,(a0)
	GEM_VDI vs_color
	subq #1,vs_int
	bpl.s .lb0
.out:
	rts

;redraw:
;	tst.b slide_flag
;	bne.s .out
;	move #2,wu_int
;	GEM_AES wind_update
;	GEM_AES evnt_timer
;	move #3,wu_int
;	GEM_AES wind_update
;.out:
;	rts

init_rect:
	move.l tree_sav,a0
	btst #0,515(a0)		; save as?
	sne fast_mode			; to accelerate IV32 or MPEG
;	bsr redraw
	clr.l fd_int+10
	move.l work_out,d0
	add.l #$10001,d0
	move.l d0,fd_int+14
	move d0,d3				; screenw
	swap d0
;	move d0,d4				; screenh
	tst.b is_vdi			; travailler dans un buffer?
	beq.s .no_vdi
	tst.b create_mov
	bne.s .no_vdi			; no buffer if creating
	muls	d3,d0				; W*H
	add.l d0,d0				; *2 for 16 bits
	move.l d0,d1
	bsr malloc
	move.l d0,old_screen	; new screen
.no_vdi:
	tst.b slide_flag
	bpl.s .no_trap			; 0 or $7f
;	GEM_VDI hide_mouse
;	tst.b conv_flag
;	bne.s .no_trap			; don't reserve if we are parent process
	clr fd_int
	GEM_AES form_dial    ; reserves screen
.no_trap:
	sf switched				; default is no resolution switch
	tst.b create_mov
	bne .no_switch			; no display for creation
	tst.b nova
	bne .no_switch			; on a NOVA, never switch!
	tst.b res_switch		; can we switch?
	beq .no_switch			; no!
	bpl.s .tt_sw
	move.l old_screen,physbase	; supposes it's enough
	move.l old_size,d0	; current size of screen
	cmp.l #153600,d0
	bpl .enough
	clr -(sp)				; only st ram
	move.l #153856,-(sp)
	GEMDOS 68,8
	move.l d0,physbase2
	and.l #$ffffff00,d0
	bmi.s .glups
	bne .ok
.glups:
	moveq #28,d0			; alert not enough memory
	bra ooops
.tt_sw:
	move planes,planes_sav
	move.l comp_txt,d1
	cmp.l #'CDH1',d1
	beq.s .st_high
	cmp.l #'dlt4',d1
	beq.s .tt_sw_16
	cmp.l #'seq4',d1
	beq.s .tt_sw_16
	cmp.l #'VIDI',d1
	beq.s .tt_sw_16
	cmp.l #'kin4',d1
	beq.s .tt_sw_16
	cmp.l #'VMAS',d1
	beq.s .tt_sw_16
	cmp.l #'CDL1',d1
	beq.s .tt_sw_16
	cmp.l #'dega',d1
	beq.s .tt_sw_16
	cmp.l #'neoc',d1
	beq.s .tt_sw_16
	move.b #'0',d1
	cmp.l #'flm0',d1
	bne.s .tt_sw_256
	move tt_res,d1
	beq.s .tt_sw_16	; 0: st low
	cmp #7,d1
	beq.s .tt_sw_256	; 7: TT low
	cmp #1,d1
	beq.s .st_high
	cmp #2,d1
	beq.s .st_med
.tt_med:
	moveq #4,d0
	move.l #$27f01df,d1
	bra.s .tt_com
.st_high:
	moveq #1,d0
	move.l #$27f018f,d1
	bra.s .tt_com
.st_med:
	moveq #2,d0
	move.l #$27f00c7,d1
	bra.s .tt_com
.tt_sw_16:
	moveq #4,d0
	move.l #$13f00c7,d1
	bra.s .tt_com
.tt_sw_256:
	moveq #8,d0
	move.l #$13f01df,d1
.tt_com:
	cmp planes,d0
	bne.s .change_res
	cmp.l work_out,d1
	beq.s .no_switch
.change_res:
	st switched
	move d0,planes
	move.l d1,work_out
	bra.s .no_switch
.ok:
	move.l d0,physbase
.enough:
	move planes,planes_sav
	move #16,planes
	st switched
	move.l #$13f00ef,work_out	; 319 x 239
.no_switch:
	move.l comp_txt,d1
	cmp.l #'flm8',d1
	beq.s .cec
	cmp.l #'flm4',d1
	beq.s .cec
	cmp.l #'dlt4',d1
	beq.s .cec
	cmp.l #'kin4',d1
	beq.s .cec
	cmp.l #'VIDI',d1
	beq.s .cec
	cmp.l #'seq4',d1
	beq.s .cec
	cmp.l #'VMAS',d1
	beq.s .cec
	cmp.l #'CDL1',d1
	beq.s .cec
	cmp.l #'dega',d1
	beq.s .cec
	cmp.l #'neoc',d1
	bne.s .zez
.cec:
	cmp #16,planes
	bne.s .ses
	bsr xbiospal_16
	bra .lb2
.ses:
	bra .lb2
.zez:
	cmp.l #'yuv2',d1
	beq.s .lb1x
	cmp.l #'yuv9',d1
	beq.s .lb1x
	cmp.l #'yvu9',d1
	beq.s .lb1x
	cmp.l #'YVU9',d1
	beq.s .lb1x
	cmp.l #'cvid',d1
	beq.s .lb1x
	tst.b fast_mode
	bne.s .coucou
	cmp.l #'mpg1',d1
	beq.s .lb1x
	cmp.l #'mpg2',d1
	beq.s .lb1x
.coucou:
	move.l #$9689cccd,d0
	not.l d0
	cmp.l d0,d1
	beq.s .iv
	subq #1,d0
	cmp.l d0,d1
	bne.s .lb1
.iv:
	bsr init_iv32_buf
.lb1x:
	cmp #8,planes
	beq .lb2								; no table if in grey!
	move.l #$80000,d1					; if cvid (or other yuv) allocate table
	bsr malloc
	move.l d0,hc_cvid
	bsr gen_yuv_tab					; and caculates it
	bra .lb2
.lb1:
	cmp.l #'flh ',d1
	beq .lb1a
	cmp.l #'tga2',d1
	beq.s .lb1a
	cmp.l #'rw16',d1
	beq.s .lb1a
	cmp.l #'rw24',d1
	beq.s .lb1a
	cmp.l #'rw32',d1
	beq.s .lb1a
	cmp.l #'rl32',d1
	beq.s .lb1a
	cmp.l #'rl24',d1
	beq.s .lb1a
	cmp.l #'mjpg',d1
	beq.s .lb1a
	cmp.l #'jpeg',d1
	beq.s .lb1a
	cmp.l #'mjpa',d1
	beq.s .lb1a
	cmp.l #'mjpb',d1
	beq.s .lb1a
	cmp.l #'rpza',d1
	beq.s .lb1a
	cmp.l #'rl16',d1
	beq.s .lb1a
	cmp.l #'msvc',d1
	beq.s .lb1b
	cmp.l #'MSVC',d1
	beq.s .lb1b
	cmp.l #'cram',d1
	bne.s .lb2
.lb1b:
	cmp #16,cram_bits
	bne.s .lb2
.lb1a:
	cmp #8,planes
		bne.s .lb2
	move.l #32768,d1
	bsr malloc
	move.l d0,hc_cvid
	bsr gen_16_to_grey				; only for 16bits images displayed in 256c
.lb2:
	tst.b vr2_flag
	beq.s .vv0
	move.l vr2_x,d0
	bra.s .vv1
.vv0:
	move max_imagex,d0
.vv1:
	addq #7,d0
	addq #8,d0
	and.b #$f0,d0
	move d0,alignwidth

	moveq #1,d0
	add.w work_out,d0					; screen width
	move d0,screenw
	tst.b switched
	bne.s .areu							; we switch, don't use cmd_coord
	tst.b cmd_coord
	beq.s .areu							; no coords specified...
	move cmd_x,d0						; else, use it!
	bra.s lb6
.areu:
	sub alignwidth,d0
	asr #1,d0							; offsx
	bpl.s lb6
	moveq #0,d0
lb6:
	move.l d0,offsx

	moveq #1,d1
	add.w work_out+2,d1				; screen height
	move d1,screenh
	tst.b switched
	bne.s .areu							; we switch, don't use cmd_coord
	tst.b cmd_coord
	beq.s .areu							; no coords specified...
	move cmd_y,d1						; else, use it!
	bra.s lb7
.areu:
	tst.b vr2_flag
	beq.s .vv2
	sub vr2_y+2,d1
	bra.s .vv3
.vv2:
	sub max_imagey,d1
	tst.b enh_flag
	beq.s .vv3
	sub enh_extra,d1					; if enhanced, then add lines!
.vv3:
	asr #1,d1							; offsy
	bpl.s lb7
	moveq #0,d1
lb7:
	move d1,offsy

	tst.b switched
	bne.s .no_align			; if switch, no real X length
	tst.b ed_adr				; if no Extended VDI, no real X
	beq.s .no_align

	move ed_adr+2,screenw	; else, real X!!
.no_align:
	muls screenw,d1
	ext.l d0
	add.l d0,d1
	move.l d1,d5
	cmp #8,planes
	beq.s .lb0
	add.l d1,d5							; a pixel is 2 bytes with 16 planes
.lb0:
	move.l old_screen,d0				; GEM physbase
	tst.b switched
	beq.s .aaa
	move.l physbase,d0				; my physbase
.aaa:
	add.l d0,d5							; physbase+offsets
	move.l d5,image					; start of image into video memory

	st display
	tst.b is_tt
	beq .exit
	move.l comp_txt,d1
	swap d1
	cmp #'mp',d1
	beq .exit
	swap d1
	cmp.l #'VMAS',d1
	beq .exit
	cmp.l #'CDL1',d1
	beq .exit
	cmp.l #'VFAL',d1
	beq .exit
	cmp.l #'CDV1',d1
	beq .exit
	cmp.l #'CDH1',d1
	beq .exit
	cmp.l #'seq4',d1
	beq .exit
	cmp.l #'VIDI',d1
	beq .exit
	cmp.l #'kin4',d1
	beq .exit
	cmp.l #'dlt4',d1
	beq .exit
	cmp.l #'dega',d1
	beq.s .exit
	cmp.l #'neoc',d1
	beq.s .exit
	move.b #'0',d1
	cmp.l #'dl/0',d1
	beq.s .exit
	cmp.l #'flm0',d1
	beq.s .exit
	move alignwidth,d1
	move d1,screenw
	tst.b vr2_flag
	beq.s .vv4
	move.l vr2_y,d0
	bra.s .vv5
.vv4:
	move max_imagey,d0
.vv5:
	move d0,screenh
	bsr adapt_ratio
	muls d0,d1					; number of bytes to allocate
	move.l d1,d3
	bsr malloc
	move.l image,d1
	and.b #$f0,d1				; 16 aligned
	move.l d1,tt_screen		; not directly into video RAM
	move.l d0,image			; but into my buffer
	bsr clear_buffer
	move.l compression,tt_comp
	move.l d7,compression
.exit:
	tst.b create_mov
	bne.s .out					; if creation, no VDI used
	tst.b is_vdi
	beq.s .out
	bne.s prepare_mfdb
.out:
	rts

prepare_mfdb:
	lea my_mfdb,a3
	lea cp_ptsin,a4
	move.l max_imagex,d7		; x and y
	move.l offsx+2,d6			; dx,dy
	move.l vdi_compression,a0
	moveq #0,d1
	move (a0),d1				; 0 if VDI_BUFFER useless
	beq.s .no_vdi_buffer
	move.l d7,d5
	swap d5
	add #15,d5
	and.b #$F0,d5				; d5 rounded to 16
	move d5,d0
	swap d5
	muls d7,d0
	tst d1
	bpl.s .prod					; if d1>0, then multiply w*h*d1
	neg d1						; else it's a division
	lsr.l d1,d0
	move.l d0,d1
	bra.s .reserve
.prod:
	muls.l d0,d1				; else byte per pixel
.reserve:
	bsr malloc
	move.l d0,vdi_buffer
	move.l d0,(a3)+			; LONG vdi_buffer
	move.l d5,(a3)+			; WORD x rounded ,y
	swap d5
	lsr #4,d5
	move d5,(a3)+				; word x (in words)
;	move #1,(a3)
	sub.l #$10001,d7			; x-1,y-1
	clr.l (a4)+					; 0,0
	move.l d7,(a4)+			; x-1,y-1
	move.l d6,(a4)+			; destx,desty
	add.l d7,d6
	move.l d6,(a4)				; destx+x-1,desty+y-1
	rts
.no_vdi_buffer:
	move.l d1,vdi_buffer		; = 0 (for FREE)
	move.l old_screen,(a3)+	; LONG physbase
	move.l screenw,d0
	move.l d0,(a3)+			; WORD x,y
	swap d0
	add #15,d0
	lsr #4,d0
	move d0,(a3)+
;	move #1,(a3)+
	sub.l #$10001,d7
	add.l d6,d7
	move.l d6,(a4)+
	move.l d7,(a4)+
	move.l d6,(a4)+
	move.l d7,(a4)
	rts

adapt_ratio:
	cmp #321,d1
	bmi.s .lb0
	add #31,d1
	and.b #$e0,d1
	move d1,alignwidth	; 32 bytes aligned
	move d1,screenw
	move.l #planes_disp_half,d7
	tst.b switched
	bne.s .lb4		; we switch, no cmd coords
	tst.b cmd_coord
	beq.s .lb4		; no coords anyway
	rts				; else keep position
.lb4:
	move d1,d5
	asr #2,d5
	move offsy,d6
.end:
	muls #320,d6
	add.l #160,d6
	ext.l d5
	sub.l d5,d6
	add.l physbase,d6
	move.l d6,image
	rts
.lb0:
	cmp #241,d0
	bmi.s .lb1
	move.l #planes_display,d7
	rts
.lb1:
	move.l #planes_disp_double,d7
	tst.b switched
	bne.s .lb2		; we switch, no cmd coords
	tst.b cmd_coord
	beq.s .lb2		; no coords anyway
	rts				; else keep position
.lb2:
	move #240,d6
	sub d0,d6		; new offsy
	move d1,d5
	asr d5
	bra.s .end

clear_buffer:
	move.l d0,a0
	lsr.l #4,d3		; d3 is 16 aligned
.lb0:
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	subq.l #1,d3
	bne.s .lb0
	rts

init_iv32_buf:
   LEA iv32_ptrs,A4
   LEA 12(a4),A5
	moveq #-16,d0
	moveq #15,d1
	move max_imagex,d2
	add d1,d2
	and.l d0,d2
	move max_imagey,d3
	add d1,d3
	and.l d0,d3
	muls d2,d3			; xy
	move.l d3,d1
	add.l d1,d1
	move.l d3,d0
	lsr.l #2,d0
	add.l d0,d1			; 2xy + xy/4
	move.l d2,d0
	lsl.l #2,d0
	add.l d0,d1			; 2xy +xy/4 +4x	: buffer total
	add.l #IV_SIZE,d1	; plus la routine + tableaux a decompresser
	move #3,-(sp)
	move.l d1,-(sp)
	GEMDOS 68,8			; alloc preffering TT ram
	move.l d0,a0		; adresse buffer
	move.l d0,bat_text	; as the iv_buffer
	bmi.s .lb0
	beq.s .lb0
	move.l a0,a1
	lea _iv32,a0
	bsr.l cache_off
	bsr.s ice_decrunch
	bsr.l cache_on
	move.l a1,a0
	add.l #IV_SIZE,a0	; for YUV buffer
	lea 28(a1),a1
	move.l a1,iv32_entry
	move.l #$40404040,d1	; valeur remplissage
	lsr #2,d2
	subq #1,d2			; boucle
	bsr.s .remplir
	move.l a0,(a4)+	; y1
	add.l d3,a0			; saute Y1
	bsr.s .remplir
	move.l a0,(a5)+	; y2
	add.l d3,a0			; saute y2
	bsr.s .remplir
	move.l a0,(a4)+	; U1
	lsr.l #4,d3			; xy/16
	addq #1,d2
	lsr #2,d2
	subq #1,d2			; x/16 longs
	add.l d3,a0			; saute u1
	bsr.s .remplir
	move.l a0,(a5)+	; u2
	add.l d3,a0			; saute u2
	bsr.s .remplir
	move.l a0,(a4)+	; v1
	add.l d3,a0			; saute v1
	bsr.s .remplir
	move.l a0,(a5)+	; v2
	add.l d3,a0
	bsr.s .remplir
	rts
.remplir:
	move d2,d0
.rr:
	move.l d1,(a0)+
	dbf d0,.rr
	rts
.lb0:
	moveq #28,d0			; alert not enough memory
	bra ooops

ice_decrunch:
	movem.l	d0-a6,-(sp)
	addq.l #4,a0				; skips 'ICE!'
	move.l (a0)+,d0
	lea.l	-8(a0,d0.l),a5
	move.l (a0)+,d0
	move.l	d0,(sp)
	move.l	a1,a4
	move.l	a1,a6
	adda.l	d0,a6
	move.l	a6,a3
	move.b	-(a5),d7
	bsr.s	.normal_bytes
	move.l	a3,a6
	bsr.s	.get_1_bit
	bcc.s	.not_packed
	move.w	#$0f9f,d7
	bsr.s	.get_1_bit
	bcc.s	.ice_00
	moveq	#15,d0
	bsr.s	.get_d0_bits
	move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
	moveq	#3,d5
.ice_02:	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbra	d5,.ice_02
	dbra	d6,.ice_01
	movem.w	d0-d3,(a3)
	dbra	d7,.ice_00
.not_packed:
	movem.l	(sp)+,d0-a6
	rts
.normal_bytes:
	bsr.s	.get_1_bit
	bcc.s	.test_if_end
	moveq.l	#0,d1
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1
	dbne	d3,.nextgb
.no_more:	add.l	20(a1),d1
.copy_direkt:
	move.b	-(a5),-(a6)
	dbf	d1,.copy_direkt
.test_if_end:
	cmpa.l	a4,a6
	bgt.s	.strings
	rts
.get_1_bit:
	add.b	d7,d7
	bne.s	.bitfound
	move.b	-(a5),d7
	addx.b	d7,d7
.bitfound:	rts
.get_d0_bits:
	moveq.l	#0,d1
.hole_bit_loop:
	add.b	d7,d7
	bne.s	.on_d0
	move.b	-(a5),d7
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1
	dbf	d0,.hole_bit_loop
	rts
.strings:	lea.l	.length_tab(pc),a1
	moveq.l	#3,d2
.get_length_bit:
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit
.no_length_bit:
	moveq.l	#0,d4
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	.no_uber
.get_uber: bsr.s	.get_d0_bits
.no_uber:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	.get_offset_2
	lea.l	.more_offset(pc),a1
	moveq.l	#1,d2
.getoffs:	bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	.get_d0_bits
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	.depack_bytes
	sub.w	d4,d1
	bra.s	.depack_bytes
.get_offset_2:
	moveq.l	#0,d1
	moveq.l	#5,d0
	moveq.l	#-1,d2
	bsr.s	.get_1_bit
	bcc.s	.less_40
	moveq.l	#8,d0
	moveq.l	#$3f,d2
.less_40:	bsr.s	.get_d0_bits
	add.w	d2,d1
.depack_bytes:
	lea.l	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
.dep_b:	move.b	-(a1),-(a6)
	dbf	d4,.dep_b
	bra	.normal_bytes
.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1
.length_tab:
	dc.b 9,1,0,-1,-1
	dc.b 8,4,2,1,0
.more_offset:
	dc.b	  11,   4,   7,  0
	dc.w	$11f,  -1, $1f

verify_dma:	; for FLM create (PI1, NEO) only
	sf bad_sound
	cmp #8,sound_bits
	bne.s .bad
	move.l frequency,d0
	moveq #0,d1
	move #12517,d1
	cmp #12266,d0
	bmi.s .bad
	cmp #12767,d0
	bmi.s .set_freq
	move #25033,d1
	cmp #24532,d0
	bmi.s .bad
	cmp #25533,d0
	bmi.s .set_freq
	cmp.l #49064,d0
	bmi.s .bad
	cmp.l #51067,d0
	bpl.s .bad
.set_freq:
	move.l d1,frequency
	bra.s .good
.bad:
	st bad_sound
.good:
	rts

	; verifies the frequency and the resolution and the channels

verify_sound:
	tst.b slide_degas
	bne.s verify_dma
	move avi_comp_flag,d4
	beq.s .ok7				; unknown = OK
	cmp #$0100,d4			; PCM
	bne .bye
.ok7:
	lea real_freq_tab,a2
	move.l (a2),d4
	move.l d4,real_freq	; for VMAS
	cmp.l 16(a2),d4
	sne real_freq			; $FF if TT, $00 if Falcon (for FLM)

	move.l comp_txt,d4
	cmp.l #'VMAS',d4
;	beq .ok2
	beq .ok9
	cmp.l #'VFAL',d4
;	beq .ok2
	beq.s .ok9
	swap d4
	cmp #'CD',d4
;	beq .ok2
	beq.s .ok5
	swap d4
	move.b #'0',d4
	cmp.l #'flm0',d4
	beq.s .ok5
	move.l s_signe,d4
	cmp.l #'twos',d4
	beq.s .ok4
	cmp.l #'raw ',d4
	beq.s .ok4
	cmp.l #'ima4',d4
	beq.s .ok4
	cmp.l #'rawa',d4
	bne.s .bye
.ok4:
	move.l frequency,d1
	move.l d1,_freq_sav
	bsr.s _verify_frequency
	tst.b bad_sound
	bne.s .bye
.ok:
	move.l (a2),real_freq
	move.l d4,frequency
	move sound_bits,d1
	cmp #4,d1
	beq.s .ok2
	cmp #8,d1
	beq.s .ok2
	cmp #16,d1
	bne.s .bye
	bra.s .ok2
.ok9:	
	move.l (a2),d1
	bra.s .ok8
.ok5:
	move.l frequency,d1
.ok8:
	tst.b snd_value
	bmi.s .ok6
	move #9600,d1
.ok6:
	move d1,real_freq+2	
.ok2:
	move channels,d1
	cmp #1,d1
	beq.s .ok3
	cmp #2,d1
	bne.s .bye
.ok3:
	tst.b snd_value
	beq.s .bye				; if $00, no DMA sound!!!!
	sf bad_sound
	rts
.bye:
	st bad_sound
	rts

; d1 = frequency
; return d4=dma frequency
; and bad_sound FF or 00
; modif A2

_verify_frequency:
	sf bad_sound
	move.l #12517,d4
	cmp.l #10900,d1
	bmi.s .bye
	cmp.l #11350,d1		; for 12,5kHz, 10,9 to 11,3 are accepted
	bmi.s .ok
	addq.l #4,a2
	move.l #25033,d4
	cmp.l #21800,d1
	bmi.s .bye
	cmp.l #22700,d1		; for 25kHz, 21,8 to 22,7 are accepted
	bmi.s .ok
	addq.l #4,a2
	move.l #50066,d4
	cmp.l #43600,d1
	bmi.s .bye
	cmp.l #45400,d1
	bmi.s .ok
.bye:
	st bad_sound
.ok:
	rts


adapt_d4_size:
   tst.b snd_value
   bmi.s .next				; don't create, but DMA, so st‚r‚o accepted
   cmp #2,channels
   bne.s .next
   asr.l #1,d4				; with no DMA: no stereo, so half size
.next:
	moveq #0,d0				; no ima4... default
	move.l d0,ima4_offs	; no offset
	cmp.l #'ima4',s_signe
	bne.s .no_comp
	bsr.l INIT_TAB_IMA4
	move.l #'twos',s_signe
	moveq #7,d0				; ima4 + 16bits + stereo
	lsl.l #6,d4				; *64
	divs.l #17,d4			; /17
	move.l d3,d1
	lsl.l #6,d3
	cmp #2,channels
	beq.s .comp_ste
	moveq #6,d0				; ima4 + 16bits + mono
.comp_ste:
	divs.l #17,d3			; 1 + 64/17 of the buffer =comp + uncomp
	move.l d3,ima4_offs
	add.l d1,d3
	move #16,sound_bits
	bra.s .lb9
.no_comp:
	cmp #8,sound_bits
	beq.s .lb9				; 8 bits, normal
	asr.l #1,d4				; else, 16 bits are converted into 8, half size
.lb9:
	move.b d0,ima4_flag
	addq.l #7,d4
	asr.l #3,d4				; rounded to the number of 8 bytes groups
	move.l d4,-(sp)
	asl.l #3,d4
	tst.b snd_value
	bmi.s .dma
	sub.l (sp)+,d4			; = 7/8 of d4 (8 bytes will take 7 with no DMA)
	move.l #9600,real_freq
	move.l frequency,d0
	divs #12516,d0			; 1, 2 or 4
.other_size:
	lsr d0
	beq.s .common
	lsr.l d4
	bra.s .other_size
.dma:
	add.l (sp)+,d4			; = d4 * 9/8
.common:
	addq.l #2,d4			; Magic hangs if all used!!!
	move.l d4,snd_size
	rts

old_init_sound:
	move.l sound_num,d7
	move.l chunkoff_num,d6
	move.l chunkoffs,a5
.lb1:
	move.l (a6)+,d0
.lb3:
	tst.l d6
	beq.s .lb5
	cmp.l (a5),d0
	bmi.s .lb2
	addq.l #4,a5
	subq.l #1,d6
	bra.s .lb3
.lb2:
	move.l (a5),d1
	cmp.l #1,d7
	beq.s .lb4
	cmp.l 4(a6),d1
	bmi.s .lb4
.lb6:
	move.l 4(a6),d1
.lb4:
	sub.l d0,d1
	move.l d1,(a6)+		; the size
	cmp.l d1,d3
	bpl.s .lb8				; below the max size
	move.l d1,d3			; else, it's a new size!
.lb8:
	add.l d1,d4
	bra.s  .lb7
.lb5:
	cmp.l #1,d7
	bne.s .lb6
	move.l mdat_end,d1
	bra.s .lb4
.lb7:
	subq.l #1,d7
	bne.s .lb1
	rts

init_sound:
	sf playing
	sf sync						; default is no synchronization, no sound
	tst.b bad_sound
	bne .bye
	move.l sound_offs,a6		; table with offset (present) and size (computed here)
	cmp.l #0,a6
	beq .bye
.lb0:
	moveq #0,d4					; the total size of the sound (bytes)
	moveq #0,d3					; the max size (for one sample)
	tst.b gtel_sound
	beq.s .titi
	bsr old_init_sound
	bra .common
.titi:
	move.l sound_num,a4
	addq.l #1,a4
	moveq #1,d7
	moveq #0,d6					; pas de d‚calage
	cmp.l #'ima4',s_signe
	bne.s .pas_comp
	cmp #1,channels
	bne.s .8bits
	moveq #-1,d6
	bra.s .8bits
.pas_comp:
	cmp #1,channels
	beq.s .mono
	addq #1,d6
.mono:
	cmp #8,sound_bits
	beq.s .8bits
	addq #1,d6					; nombre de d‚calages
.8bits:
	lea snd_size_offs,a0
	move.l (a0)+,d5			; num
	SEEK (a0),0					; bonne position
.coucou:
	subq #1,d5
	bsr read_3_long			; taille,tag,jusqu'ou
	tst d6
	bpl.s .normal
	lsr.l #1,d0
	bra.s .tutu
.normal:
	lsl.l d6,d0					; decale selon 8/16 bits et mono/stereo
.tutu:
	tst d5
	bne.s .toto1
	move.l a4,d2				; total + 1 (aller jusqu'a la fin)
.toto1:
	addq.l #4,a6
	move.l d0,(a6)+
	add.l d0,d4					; taille totale
	cmp.l d0,d3
	bpl.s .lb7
	move.l d0,d3
.lb7:
	addq.l #1,d7
	cmp.l d7,d2
	bne.s .toto1
	tst d5
	bne.s .coucou
.common:
	bsr adapt_d4_size		; and eventually D3 if ima4
	move.l tree_sav,a0
	btst #0,275(a0)
	beq.s .bye
	bsr.s read_sound			; reads the whole sound into memory
.bye:
	bsr sync_tab
	rts

read_sound:
	sf ttram_sound		; 00 on copie en ST Ram, FF on copie en tt Ram
	move.l d3,-(a7)
	GEMDOS $48,6
	tst.l d0
	bmi .end				; not enough memory for the temporary buffer
	move.l d0,snd_temp
	beq .end
	move.l d0,a3
	tst.b step_mode		; if step mode, only copies!!!
	bne.s .just_save
	add.l sound_num,d4	; plus 1 octet d'ecart par bloc
	moveq #64,d0
	add.l d0,d4				; plus une securite...
	move.l d4,stram_size	; default value if all fits in it
	clr -(sp)				; ST Ram only
	move.l #-1,-(a7)		; asks for the memory available
	GEMDOS $44,8
	tst.l d0
	bmi .end				; an error
	beq .end
	cmp.l d4,d0				; compared to the memory wanted
	bpl.s .enough			; whow! it's enough!
	move.l d4,d6
	sub.l d0,d6				; memory left (to be allocated in TT ram)
	move #1,-(sp)
	move.l d6,-(sp)
	GEMDOS $44,8			; tries to allocate the remaining into TT ram
	tst.l d0
	bmi .end				; no, impossible!
	move.l d0,snd_pos
	move.l d0,s_buffer_2
	beq .end				; not enough
	move.l d6,ttram_size
	sub.l d6,d4				; re-computes the amount available into ST Ram
	move.l d4,stram_size
.enough:
	clr -(sp)
	move.l d4,-(sp)
	GEMDOS $44,8
	move.l d0,s_buffer
	beq .end
	move.l d0,a6
.just_save:
	move.l sound_offs,a5
	move.l sound_num,d7
	move.l d7,d0
	bsr.l init_loading_sound
	tst.b mvi_flag
	beq .lb0				; avi or mov
	moveq #29,d0
	move.l d0,a5			; first position
	move.l mvi_save_size,d7	; old snd_size
	addq.l #5,d7
	move.l a3,a4
.lb_0:
	tst.b from_ram
	beq.s .from_file
	move.l a5,a0
	add.l whole_file,a0	; source
	move.l a4,a1			; dest
	move.l d3,d6			; size
.copy_ram:
	move.b (a0)+,(a1)+
	subq.l #1,d6
	bne.s .copy_ram
	move.l d3,d6			; size
	bra.s .comload
.from_file:
	SEEK a5,0
	move.l d3,d6			; size
	move.l a4,-(sp)
	move.l d6,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .end
.comload:
	lea 3(a4),a3
	tst.b (a3)+
	beq.s .lb_3
	tst.b mvi_rem
	beq.s .lb_3
	bpl.s .lb_2
	subq.l #1,d6
	subq.l #1,a5
	clr.b -(a6)
	subq.l #1,a3
	bra.s .lb_3
.lb_2:
	addq.l #1,d6
	addq.l #1,a5
	addq.l #1,a3
	move.b -1(a6),(a6)+
	clr.b (a6)
.lb_3:
	subq.l #5,d6
	sub.l d6,d7
	bsr treat_sound
	subq.l #3,a3
	move.l (a3),d0
	clr.b d0
	INTEL d0
	add.l d3,a5
	add.l d0,a5				; next position
	subq.l #2,a5
	tst.b mvi_flag
	beq.s .lb_1
	sf mvi_flag
	move.l mvi_next_size,d3
.lb_1:
	cmp.l d3,d7
	bpl .lb_0
	bra.s .common
.lb0:
	SEEK (a5)+,0			; to the good position
	move.l (a5)+,d6
	move.l a3,d0
	add.l ima4_offs,d0	; 0 if uncompressed
	move.l d0,-(sp)		; into the temporary buffer
	move.l d6,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi.s .end				; an error
	bsr.s treat_sound		; copies temp into the real buffer, updates a6
								; or (step mode) saves it into file!
	move.l _reference,d0
	subq.l #1,d7
	sub.l d7,d0
	bsr.l update_loading_sound
	tst.l d7
	bne.s .lb0
.common:
	tst.b step_mode
	bne.s .just_save2
	move.l a6,d0
	bclr #0,d0
	move.l d0,a6			; turns A6 into an even address
	moveq #0,d0
	tst.b ttram_sound
	beq.s .lb1
	move.l a6,snd_tt_end
	sub.l s_buffer_2,a6
	move.l a6,ttram_size
	move.l a6,d0
	move.l snd_end,a6	; *
	bra.s .lb2
.lb1:
	move.l a6,snd_end
.lb2:						; *
	sub.l s_buffer,a6
	move.l a6,stram_size
	add.l a6,d0
; .lb2:					; *
	move.l d0,snd_size
.just_save2:
	movem.l d2-d7/a2-a6,-(sp)
	moveq #1,d6
	moveq #-1,d7
	bsr manage_tree
	movem.l (sp)+,d2-d7/a2-a6
	st playing				; ok for playing the sound!
.end:
	rts

; converting 8 bytes into 9 bytes is equal to converting
; 11025 Hz into 12403 Hz, 22050 Hz into 24806 Hz and 44100 Hz into 49612 Hz
; witch are very close to the DMA frequencies: 12517, 25033 and 50066,
; this is an very good approximation (error 1%).

treat_sound:
	move.b ima4_flag,d1
	beq.s .no_comp
	move.l ima4_offs,a2
	add.l a3,a2		; compressed datas
	move.l a3,a4	; uncompressed
	bsr.l DECOMPRESS_IMA4
	move.l d0,d6	; uncompressed size
.no_comp:
	tst.b step_mode
	bne _save_avr_block
	tst.b ttram_sound
	bne.s .lb8					; yes
	move.l s_buffer,a1		; else, calculates the top address of the ST ram
	add.l stram_size,a1
	bra.s .lb9
.lb8:
	move.l s_buffer_2,a1	; en TT Ram
	add.l ttram_size,a1
.lb9:
	moveq #32,d0			; securite
	sub.l d0,a1				; the top minus 32 bytes
	tst.b snd_value
	bpl yamaha_treat_sound
	move.l a3,a0			; temporary buffer
	cmp #8,sound_bits
	bne bits_16			; it's a 16 bits sample
	move.l d6,d0			; the size
	asr.l #3,d6				; blocs of 8 bytes
	and #7,d0				; remaining
	cmp.l #'twos',s_signe
	bne.s .sign
.lb2:
	cmp.l a1,a6				; at the top?
	bmi.s .z1
	bsr into_tt
.z1:
	move.l (a0)+,(a6)+
	move.l (a0)+,(a6)+	; 8 bytes
	move.b -1(a0),(a6)+	; repeats the last one
	subq.l #1,d6
	bne.s .lb2
	cmp.l a1,a6
	bmi.s .lb3
	bsr into_tt
	bra.s .lb3
.lb4:
	move.b (a0)+,(a6)+
.lb3:
	dbf d0,.lb4				; copies the remaining
	rts
.sign:
	moveq #-128,d1
.lb5:
	cmp.l a1,a6
	bmi.s .z2
	bsr into_tt
.z2:
	rept 8
		move.b (a0)+,d2
		add.b d1,d2
		move.b d2,(a6)+	; copies and signs 8 bytes
	endr
	move.b d2,(a6)+		; repeats the 8th byte
	subq.l #1,d6
	bne.s .lb5
	cmp.l a1,a6
	bmi.s .lb6
	bsr into_tt
	bra.s .lb6
.lb7:
	move.b (a0)+,d2
	add.b d1,d2
	move.b d2,(a6)+		; copies and signst the remaining
.lb6:
	dbf d0,.lb7
	rts
bits_16:
	cmp.l #'rawa',s_signe	; avi sound?
	bne.s .lb0
	addq.l #1,a0			; the 8 high bits are in the lower byte (Intel)
.lb0:
	asr.l #1,d6
	move.l d6,d0
	asr.l #3,d6				; blocs of 16 bytes (8 bytes in the destination)
	and #7,d0				; remaining
	cmp #2,channels
	bne.s .lb5
.lb2:
	cmp.l a1,a6
	bmi.s .z1
	bsr.s into_tt
.z1:
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	move d2,(a6)+
	subq.l #1,d6
	beq.s .zed
	cmp.l a1,a6
	bmi.s .zz1
	bsr.s into_tt
.zz1:
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	subq.l #1,d6
	bne.s .lb2
.zed:
	cmp.l a1,a6
	bmi.s .lb3
	bsr.s into_tt
	bra.s .lb3
.lb4:
	move.b (a0),(a6)+
	addq.l #2,a0
.lb3:
	dbf d0,.lb4				; copies the remaining
	rts
.lb5:
	cmp.l a1,a6
	bmi.s .zzz1
	bsr.s into_tt
.zzz1:
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	movep.l 0(a0),d2
	addq.l #8,a0
	move.l d2,(a6)+
	move.b d2,(a6)+
	subq.l #1,d6
	bne.s .lb5
	bra.s .zed

into_tt:
	tst.b ttram_sound
	bne.s .end
	move.l a6,snd_end			; the end of the ST Ram buffer
	clr.b (a6)					; if yamaha...
	bclr #0,snd_end+3			; word aligned
	tst.l s_buffer_2			; is there a TT ram buffer?
	beq.s .end					; no...
	move.l s_buffer_2,a6		; yes, go on copying!
	st ttram_sound
	lea  -32(a6),a1
	add.l ttram_size,a1
	rts
.end:
	addq.l #4,sp				; a first RTS
	rts							; and a second one

_save_avr_block:
	cmp #16,sound_bits
	bne.s .lb0
	cmp.l #'rawa',s_signe
	bne.s .lb0
	move.l a3,a0
	move.l d6,d0
.motorola:
	move (a0),d1				; seul cas ou on inverse: AVI en 16 bits
	ror #8,d1
	move d1,(a0)+
	subq.l #2,d0
	bgt.s .motorola
.lb0:
	move.l a3,-(sp)
	move.l d6,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12
	rts

yamaha_treat_sound:
	move.l frequency,d0
	mulu sound_bits,d0
	lsr.l #2,d0
	divs #25033,d0			; step in d0.w
	move.l a3,a0			; temporary buffer
	lsr.l #3,d6				; blocs of 8
	move.l d0,d1
.other_size
	lsr d1
	beq.s .good_size
	lsr.l d6
	bra.s .other_size
.good_size:
	cmp #2,channels
	beq yamaha_treat_stereo
	cmp #8,sound_bits
	beq.s .lb20				; only 8 bits samples can be signed
	cmp.l #'rawa',s_signe	; for 16 bits samples...
	bne.s .lb2
	addq.l #1,a0				; ... some are in Intel format
	bra.s .lb2
.lb20:
	cmp.l #'twos',s_signe
	bne.s .sign
.lb2:
	cmp.l a1,a6
	bmi.s .z1
	bsr into_tt
.z1:
	rept 7
		move.b (a0),(a6)+
		bne.s *+8
		move.b #1,-1(a6)
		add d0,a0
	endr
	add d0,a0	; skips the last one
	subq.l #1,d6
	bne.s .lb2
	clr.b (a6)		; it's maybe the last one!
	rts
.sign:
	moveq #-128,d1
.lb5:
	cmp.l a1,a6
	bmi.s .z2
	bsr into_tt
.z2:
	rept 7
		move.b (a0),d2
		add.b d1,d2
		bne.s *+4
		moveq #1,d2
		move.b d2,(a6)+	; copies and signs 8 bytes
		add d0,a0
	endr
	add d0,a0
	subq.l #1,d6
	bne.s .lb5
	clr.b (a6)				; maybe the last one!
	rts
yamaha_treat_stereo:
	add d0,d0					; everything is doubled
	moveq #1,d3					; for 8 bits stereo signed
	cmp #8,sound_bits
	beq.s .lb20					; only 8 bits samples can be signed
	moveq #2,d3					; 16 bits stereo signed
	cmp.l #'rawa',s_signe	; for 16 bits samples...
	bne.s .lb2
	addq.l #1,a0				; ... some are in Intel format
	bra.s .lb2
.lb20:
	cmp.l #'twos',s_signe
	bne .sign
.lb2:
	cmp.l a1,a6
	bmi.s .z1
	bsr into_tt
.z1:
	rept 7
		move.b (a0),d1
		move.b 0(a0,d3.w),d2	; one or two bytes ahead
		ext.w d1
		ext.w d2
		add d1,d2
		asr d2
		move.b d2,(a6)+
		bne.s *+8
		move.b #1,-1(a6)
		add d0,a0
	endr
	add d0,a0	; skips the last one
	subq.l #2,d6
	bgt .lb2
	clr.b (a6)		; it's maybe the last one!
	rts
.sign:
	moveq #-128,d3
.lb5:
	cmp.l a1,a6
	bmi.s .z2
	bsr into_tt
.z2:
	rept 7
		moveq #0,d1
		move.b (a0),d1
		moveq #0,d2
		move.b 1(a0),d2
		add d1,d2
		lsr d2
		add.b d3,d2
		bne.s *+4
		moveq #1,d2
		move.b d2,(a6)+	; copies and signs 8 bytes
		add d0,a0
	endr
	add d0,a0
	subq.l #2,d6
	bgt .lb5
	clr.b (a6)				; maybe the last one!
	rts

sync_tab:
	tst.b vr_flag
	bne.s .yes
	move.l tree_sav,a0
	btst #0,299(a0)		; objetc 'synchronize'
	beq .end					; no sync
.yes:
	move.l t2samps,a0
	cmp.l #0,a0
	beq .end					; no time table for each frame
	move.l t2samp_num,d2
	moveq #0,d4				; total time
	moveq #0,d3				; total frames
.lb0:
	move.l (a0)+,d0		; number of frames
	add.l d0,d3				; updates the number of frames
	muls.l (a0)+,d0		; times their duration
	add.l d0,d4				; updates the total time
	subq.l #1,d2
	bne.s .lb0				; till the end of t2_samps
	move.l d3,d1
	asl.l #2,d1				; each entry is a long (4 bytes)
	addq.l #8,d1			; plus two dummy entries (the first and the last)
	bsr malloc
	move.l d0,a1

	tst.b bad_sound
	bne.s .scale
	tst.l sound_offs
	bne.s .sound
.scale:
	move.l #200,d1
	move.l qt_timescale,d4
	bne.s .go_on
	move.l #1000,d4
	bra.s .go_on

.sound:
	move.l snd_size,d1	; the size in bytes
	tst.b snd_value
	bmi.s .dma
	move.l #9600,d5
	bra.s .lb5
.dma:
	move.l real_freq,d5
	cmp #2,channels
	bne.s .lb5				; not a stereo, 1byte = 1sample
	asr.l #1,d1				; else 2bytes = 1 sample
.lb5:
	moveq #0,d6
	muls.l #200,d6:d1
	divs.l d5,d6:d1	; d1=number of 200th of second for the whole sample
								; to use the Timer C of the system
.go_on:
	move.l t2samps,a0
	move.l a0,a2			; for mfree
	move.l a1,t2samps
	move.l t2samp_num,d2
	move.l d3,t2samp_num ; new number
	clr.l (a1)+				; the first entry contains 0 (start of the sound)
	moveq #0,d6
.lb1:
	move.l (a0)+,d0		; number of frames
	move.l (a0)+,d7		; duration of one frame
.lb2:
	add.l d7,d6				; from the start
	move.l d6,d3			; the duration (in time)
	muls.l d1,d5:d3
	divs.l d4,d5:d3		; d3 is the corresponding duration in 1/200 sec
	move.l d3,(a1)+
	subq.l #1,d0
	bne.s .lb2
	subq.l #1,d2
	bne.s .lb1
	move.l tree_sav,a0
	btst #0,299(a0)		; objetc 'synchronize'
	beq.s .glub					; no sync
	st sync
.glub:
	bsr mfree
	move.l t2samps,a0		; points to the dummy, but the numbers start at 1
	move.l t2samp_num,d2
	bset #7,(a0,d2.l*4)	; the last is always marked!
	sf sync+1				; we can skip a key frame (default)
	move.l ss_tab,a1
	cmp.l #0,a1
	beq.s .lb4				; no stss table! No particular frame, mark all
	move.l ss_num,d0		; else, number of particular frames
	divs.l d0,d2			; number of frames for one key frame
	cmp.l #4,d2				; more than 4?
	bmi.s .lb3
	st sync+1				; yes, we will never skip one key frame
.lb3:
	move.l (a1)+,d1
	bset #7,(a0,d1.l*4)	; marks this address
	subq.l #1,d0
	bne.s .lb3
	bra.s .end
.lb4:
	addq.l #4,a0			; the next one (jumps over the dummy)
	bset #7,(a0)			; marks every frame
	subq.l #1,d2
	bne.s .lb4
.end:
	rts


display_general:
	moveq #0,d7
	moveq #18,d6
	bsr manage_tree
	cmp #5,d6			; options button ?
	bne.s .lb0
	st from_info
	bsr manage_options
	sf from_info
	bra.s display_general
.lb0:
	cmp #9,d6			; credits button?
	bne.s .lb1	
	moveq #0,d7
	moveq #2,d6
	bsr manage_tree
	bra.s display_general
.lb1:
	cmp #7,d6			; quit ?
	beq.l end_end			; exit program (or back to ACC loop)
	cmp #1,d6			; load and play ?
	beq.s .exit
	cmp #2,d6			; convert/disassemble?
	beq.s .exit
	cmp #3,d6			; assemble
	beq.s .exit	
	cmp #4,d6			; capture screen
	beq.s .exit
	cmp #8,d6			; search disk
	beq.s .exit
	nop		
.exit:
	subq #2,d6
	move.b d6,menu_flag
	rts

	
; debug line in INFO box:
; xxxx yy zz Tn CCs
; xxxx = is_65k word
; yy   = is_vdi
; zz   = adapt_mode
; Tn   = vdi routine
; CC   = country code, s=+ if rsc found or - if default loaded

_debug_line:
	GADDR d6
	move.l 24*7+12(a0),a0	; obspec = tedinfo debug line
	move.l (a0),a0				; text line
	move is_65k,d0
	swap d0
	move.b is_vdi,d0
	lsl #8,d0
	move.b adapt_mode,d0
	moveq #7,d1
.lb0:
	rol.l #4,d0
	move d0,d2
	and.w #$000F,d2
	add.b #'0',d2
	cmp #58,d2
	bmi.s .lb1
	addq #7,d2
.lb1:
	move.b d2,(a0)+
	dbf d1,.lb0
	addq.l #1,a0
	move.l vdi_compression,d0
	beq.s .lb2					; empty...
	move.l d0,a1
	move.b 8(a1),(a0)+
	move.b 9(a1),(a0)+
	bra.s .lb3
.lb2:
	move #'T-',(a0)+
.lb3:
	addq.l #1,a0
	move country_code,(a0)+
	moveq #'+',d0
	tst.b langue
	bpl.s .lb4		; if >0 then country rsc found
	moveq #'-',d0	; else default rsc loaded
.lb4:
	move.b d0,(a0)
	rts

	; upon entry:
	; d7=0 -> draw + form_do + clear
	; d7=1 -> draw
	; d7=-1 -> clear
	; d6= long word containing the index of the tree (0,1,2,3)

manage_tree:
	tst d7
	bmi .normal				; if <0, just frees the screen
	GADDR d6,1				; the address of the tree into 'tree'
	tst.b slide_flag
	bne.s .slide
	tst.b command
	beq.s .normal
	cmp #1,d6
	beq.s .normal			; Loading sound...
	cmp #8,d6
	beq.s .normal			; searching files...
	cmp #12,d6
	beq.s .normal			; creating box
.slide:
	move.l #cmd_dial,a1
	tst.b (a1)+
	bne.s .normal			; dialogs allowed
	tst d6
	bne .out				; other than the first dialog
	move.l tree,a0
	btst #0,467(a0)		; window??
	sne can_win
	bclr #0,275(a0)
	bclr #0,299(a0)		; the two buttons unset
	tst.b (a1)+				; cmd_play
	beq.s .k1
	bset #0,275(a0)
.k1:
	tst.b (a1)+				; cmd_sync
	beq.s .k2
	bset #0,299(a0)
.k2:
	tst.b (a1)				; cmd_alt
	beq.s .k3
	bset #0,539(a0)			; Save as...
.k3:
	moveq #9,d6				; GO button
	rts
.normal:
	bsr.s .treat_wdial
	tst d7
	bne.s .out
	move.l tree,a0
	tst d6
	bne.s .no_win
	btst #0,467(a0)			; Window or not?
	sne can_win
	btst #0,491(a0)		; repeat or not?
	sne is_rep
.no_win:
	move intout,d6
	and #$7fff,d6			; the exit object
	move d6,d0
	muls #24,d0
	bclr #0,11(a0,d0.w)	; resets the 'selected' bit of the exit button
.out:
	rts
.treat_wdial:
	movem.l d6-d7,-(sp)
	move.l (_dialog_table,d6.l*4),a0
	move.l a0,.dialogue
	moveq #20,d0     	; timer 20/1000
	tst d7
	bpl.s .dessine
	bsr.l wdial_close
	bra .fin
.dessine:
   bne.s .timer_oui
   moveq #0,d0
.timer_oui:
	move.l d0,.timer
	lea .ftext(pc),a1
.ftext_parse:
	move (a1)+,d0		; 1st editable ftext
	beq.s .pasftext	; if 0, end
	cmp (a1)+,d6
	bne.s .ftext_parse
.pasftext:
	ext.l d0
	lea .titre(pc),a1
	tst 20(a0)			; handle present?
	bne.s .boucle		; oui, on ne rouvre pas.
	bsr.l wdial_open
.boucle:
	move.l .timer(pc),d0
	bmi.s .fin				; c'est le signal qu'il y a eu un evenement timer
	bsr.l wdial_evnt
	tst d0
	bpl.s .evenement
	move.l d0,.timer		; si evenement timer, timer=-1 pour sortie ensuite
.evenement:
	bsr.l wdial_formdo
	tst.b d0
	beq.s .boucle			; rien a faire!
	bmi.s .lb0				; une sortie
	move.l .dialogue,a0  ; sinon, c'est AC_OPEN
	move 22(a0),d0
	lea .titre(pc),a1
	bsr.l wdial_open
	bra.s .boucle
.lb0:
	move d7,intout			; bouton exit ou -1 pour quitter
	move.l .dialogue,a0
	cmp.l a0,a3
	bne.s .fin				; pas le notre?
	bsr.l wdial_close
	tst.l d7
	bpl.s .fin
	move.l (sp),d6			; tree
	lea .exit_button(pc),a0
.parse_trees:
	move (a0)+,d0	; tree
	move (a0)+,d1	; exit button
	bmi.s .not_found
	cmp d0,d6
	bne.s .parse_trees
	move d1,intout	; if found, simulate exit button
	bra.s .fin
.not_found:
	st inter_flag
	bra.l end				; si -1, alors on quitte!
.fin:
	movem.l (sp)+,d6-d7
	rts
	; tree, exit button 
.exit_button: dc.w 0,10,2,0,3,7,5,12,6,29,7,23,9,5,11,4,14,20,15,25,16,6,18,7,19,71,20,11,-1,-1

		; 1st ftext, tree
.ftext: dc.w 28,6,2,11,12,15,2,17,9,16,49,19,5,20,0,0
.timer: dc.l 0
.dialogue: dc.l 0
.titre: dc.b "M_Player "
	VER_STR
	dc.b 0

	even


principal:
	bsr fill_dialog
	clr mf_int
	GEM_AES graf_mouse			; the arrow
.lb1:
	moveq #0,d6			; first tree
	moveq #0,d7
	bsr manage_tree
	sf enh_flag			; default
	cmp #10,d6			; Cancel?
	seq stopped
	beq.s .lb2
	move.l tree,a0
	btst #0,26*24+11(a0)	; Enhanced selected?
	sne enh_flag
	bne.s .lb3
	move.l #default_enhanced,enh_ptr0	; if deselected, then default
.lb3:
	cmp #16,d6			; Options ?
	bne.s .lb2			; no, so it's the 'Go!' button
	bsr manage_options
	bra.s .lb1
.lb2:						; EQ=stopped, NE=GO
	rts


test_sound:
	trap #11
	bne .exit			; sound playing!
	lea test_sound_start,a3
	tst.l (a3)
	bne .play			; sound loaded !
	move.l #'AVR ',d0
	bsr.l set_ext			; M_PLAYER.AVR
	pea opt_dta
	GEMDOS 26,6			; change DTA
	move #1,-(sp)		; normal+read_only files
	pea _name
	GEMDOS 78,8			; search first	
	tst d0
	bmi .exit
	moveq #-128,d3
	add.l opt_dta+26,d3	; file lenght
	pea dta
	GEMDOS 26,6				; back to standard DTA
	clr -(sp)				; ST Ram only
	move.l d3,-(a7)
	GEMDOS $44,8
	tst.l d0
	bmi .exit				; an error
	beq .exit	
	move.l d0,(a3)			; sound start
	add.l d3,d0
	move.l d0,4(a3)	   ; sound end
	clr -(sp)
	pea _name
	GEMDOS 61,8			; file open
	move.l d0,d4
	bmi.s .exit
	move.l (a3),-(sp)
	move.l #128,-(sp)
	move d4,-(sp)
	GEMDOS 63,12		; read header (ignored)
	move.l (a3),-(sp)
	move.l d3,-(sp)
	move d4,-(sp)
	GEMDOS 63,12		; read whole file
	move d4,-(sp)
	GEMDOS 62,4			; close		
.play:
	clr.l -(sp)
	GEMDOS 32,6			; supervisor
	addq.l #1,a3
	move.b (a3)+,$ffff8903.w
	move.b (a3)+,$ffff8905.w
	move.b (a3)+,$ffff8907.w	; start address
	addq.l #1,a3
	move.b (a3)+,$ffff890f.w
	move.b (a3)+,$ffff8911.w
	move.b (a3),$ffff8913.w	; end address
	move.b #2,$ffff8921.w		; sound mode control (stereo, 25 khz)
	move.b #1,$ffff8901.w		; starts the sound!
	move.l d0,-(sp)
	GEMDOS 32,6			; user
.exit:
	rts
			
microw_to_heights:
	lea temp_microw,a1
	cmp.b #$e7,(a1)+
	bne.s .exit
	moveq #14,d0
	GADDR d0				; tree
	lea 3*24+22(a0),a0	; height fond
	lea microw_max(pc),a2	; maximum
.again:	
	move (a2)+,d2
	beq.s .fin
	move d2,d1
	sub.b (a1)+,d1			; inverse max->0
	addq #1,d2
	move (a0),d0
	addq #1,d0
	muls d0,d1
	divs d2,d1
	move d1,24(a0)			; hauteur curseur
	lea 48(a0),a0
	bra.s .again
.fin:
	lea 133(a0),a0			; saute au state du bouton mix
	bclr #0,(a0)			; default no mix
	cmp.b #1,(a1)
	bne.s .exit
	bset #0,(a0)			; if mix=1, then set	
.exit:
	rts

microw_max: dc.w 40,20,20,12,12,0	; changed to --,15,15,--,--,0 with XBIOS functions
	
heights_to_microw:
	lea temp_microw,a1
	move.b #$e7,(a1)+
	moveq #14,d0
	GADDR d0				; tree
	lea 3*24+22(a0),a0	; height fond
	lea microw_max(pc),a2	; maximum
.again:	
	move (a2)+,d2			; max
	beq.s .fin
	move (a0),d1			; hauteur fond
	move d1,d0
	sub 24(a0),d1			; inverse max->0
	addq #1,d0
	addq #1,d2
	muls d2,d1
	divs d0,d1				; de 0 … max
	move.b d1,(a1)+
	lea 48(a0),a0
	bra.s .again
.fin:
	lea 133(a0),a0			; saute au state du bouton mix
	moveq #1,d0				; default = 1 (mix)
	btst #0,(a0)
	bne.s .lb0
	moveq #2,d0				; don't mix
.lb0:
	move.b d0,(a1)+
.exit:
	rts
	
; entr‚e: A4 adresse des donn‚es BYTE valid,vol,left,right,treb,bass,mix

set_microwire:
	cmp.b #$e7,(a4)+
	bne.s .exit			; unvalid data
	tst.b is_mw
	beq.s .exit			; no microwire
	bpl.s .xbios		; if>0 then only xbios functions
	clr.l -(sp)
	GEMDOS 32,6			; supervisor
	moveq #5,d2			; loop
	lea .mask(pc),a0	
.write:
	move (a0)+,d1
	add.b (a4)+,d1
	move.w #$7FF,$FFFF8924.w
	move.w d1,$FFFF8922.w
	move.l $4ba.w,d3
	addq.l #2,d3
.wait1:
	cmp.l $4ba.w,d3
	bne.s .wait1
.wait:
	cmp #$7FF,$FFFF8924.w
	bne.s .wait
	dbf d2,.write
	move.l d0,-(sp)
	GEMDOS 32,6			; user
.exit:
	rts	
.mask: dc.w $04c0,$0540,$0500,$0480,$0440,$0400
.xbios:
	addq.l #1,a4		; jump over Master volume
	moveq #15,d3
	sub.b (a4)+,d3		; invert 0-15 to 15-0
	lsl #4,d3			; 000F maxi to 00F0 maxi
	move d3,-(sp)
	clr -(sp)			; left
	XBIOS 130,6			; soundcmd
	moveq #15,d3
	sub.b (a4),d3
	lsl #4,d3
	move d3,-(sp)
	move #1,-(sp)		; right
	XBIOS 130,6			; same
	rts

vq_mouse: dc.l vqm_cont,dum,dum,dum,vqm_xy
vqm_cont: dc.w 124,0,0,0,0,0,0,0,0,0,0,0
vqm_xy: dc.w 0,0

objc_offset: dc.l oo_cont,global,oo_int,oo_xy,tree,dum
oo_cont: dc.w 44,1,3,1,0
oo_int: dc.w 0
oo_xy: dc.w 0,0,0


tt_sound_control:
	bsr.l install_traps
	lea temp_microw+8,a4
	lea microwire+8,a0
	move.l -(a0),-(a4)
	move.l -(a0),-(a4)
	bsr set_microwire
	bsr microw_to_heights
.again:
	moveq #0,d7
	moveq #14,d6
	bsr manage_tree
	cmp #13,d6
	bgt.s .buttons
	GEM_VDI vq_mouse
	addq #1,d6
	bclr #0,d6
	subq #1,d6			; cadre du dessous
	move d6,oo_int
	GEM_AES objc_offset
	move.l tree,a3
	moveq #24,d0
	muls d6,d0
	lea 22(a3,d0.l),a3	; adresse hauteur en pixels du cadre
	move vqm_xy+2(pc),d3
	sub oo_xy+4(pc),d3	; delta y
	bpl.s .ok1
	moveq #0,d3				; if <0, reset to 0
.ok1:
	cmp (a3),d3
	bmi.s .ok2
	move (a3),d3			; if > max, then =max
.ok2:
	move d3,24(a3)			; nouvelle hauteur pour cadre dessus
	bra.s .again
.buttons:
	cmp #20,d6				; cancel ?
	beq.s .exit
	bsr heights_to_microw
	lea temp_microw,a4
	bsr set_microwire
	cmp #18,d6				; test sound?
	bne.s .lb1
	bsr test_sound	
	bra .again
.lb1:
	cmp #21,d6				; save & exit ?
	bne .again				; bizarre...
	lea temp_microw,a0
	lea microwire,a4
	move.l (a0)+,(a4)+
	move.l (a0),(a4)		
.exit:
	bsr.l remove_traps
	st playing
	bsr.l clear_dma_sound
	sf playing
	lea test_sound_start,a3
	move.l (a3),a2
	bsr mfree
	clr.l (a3)	
	rts
	
manage_options:
	moveq #0,d7
	moveq #15,d6
	bsr manage_tree
	lea table_options,a3
	moveq #0,d7
.lb0:
	move (a3)+,d0			; one button #
	beq.s .lb1				; end of list
	cmp d0,d6
	bne.s .lb2
	bsr select_path		; correct button for string path
	bra.s manage_options
.lb2:
	addq.l #1,d7
	bra.s .lb0
.lb1:
	bsr buttons_to_flags	; save settings into flags, return D1 =FF/00
	cmp #26,d6				; TT Sound control?
	bne.s .lb3
	bsr tt_sound_control
	bra.s manage_options	
.lb3:
	cmp #25,d6				; OK button ?
	beq.s .end
	cmp #24,d6				; SAVE buton ?
	bne.s manage_options	; unknown button? restart...
							; here SAVE
	move.l #'OPT ',d0
	bsr.l set_ext
	clr -(sp)			; normal file
	pea _name		; M_PLAYER.OPT
	GEMDOS 60,8			; file create
	move.l d0,d4
	bpl.s .ok
	moveq #37,d0		; alert can't create file
	bsr alert
	bra.s manage_options
.ok:
	moveq #0,d0
	bsr.l my_mouse			; mouse is a disk
	pea options
	move.l #2304,-(sp)
	move d4,-(sp)
	GEMDOS 64,12		; write whole file
	move d4,-(sp)
	GEMDOS 62,4			; close	
	clr mf_int
	GEM_AES graf_mouse	; back to arrow
	bra manage_options	
.end:
	tst.b d1					; sound has changed?
	beq.s .exit
	tst.b from_info		; does it come from the general box?
	bne.s .dont_warn
	tst.b warnings			; do you want warnings?
	beq.s .dont_warn
	moveq #39,d0			; alert sound change, reload
	bsr alert
.dont_warn:
	moveq #0,d1
	move.b sound_system,d1
	bsr.l sound_simul		; set flags accordingly to new sound
.exit:
	rts

; return d1=FF if sound has changed

buttons_to_flags:
	moveq #15,d0
	GADDR d0
	move.l 24*22+12(a0),a2	; fps tedinfo
	move.l (a2),a2				; string
	lea mjpg_fps_string,a1
	move.l (a1),d0
	cmp.l (a2),d0	; change?
	beq.s .no_change
	tst.b (a2)
	beq.s .not_valid
	move.l (a2),(a1)			; else update string
	moveq.l #0,d0
	move.b (a2)+,d0
	sub.b #'0',d0
	muls #10,d0
	moveq #0,d1
	move.b (a2)+,d1
	beq.s .lb0					; ok, frames per 10 seconds
	sub.b #'0',d1
	add d1,d0
	muls #10,d0
	move.b (a2),d1
	beq.s .lb0
	sub.b #'0',d1
	add d1,d0
.lb0:
	move.l #2000,d1
	divs d0,d1
	move.w d1,mjpg_fps
	bra.s .no_change
.not_valid:
	move.l d0,(a2)			; put back previous string if not valid
.no_change:
	lea always_count,a2	; first flag!
.lb2:
	move.w (a3)+,d0
	beq.s .end_end
	muls #24,d0
	bmi.s .special
	btst #0,11(a0,d0.l)
	sne (a2)+
	bra.s .lb2	
.end_end:
	rts
.special:
	neg.l d0
	lea 11(a0,d0.l),a1		; DMA button
	moveq #1,d0
	btst #0,(a1)
	bne.s .found
	moveq #2,d0
	btst #0,24(a1)
	bne.s .found
	moveq #3,d0
.found:
	cmp.b (a2),d0
	sne d1						; sound has changed?
	move.b d0,(a2)+
	bra.s .lb2	

; d7 = 0,1,2,3 for default, sound, images, convert
	
select_path:
	move.l d7,d0
	muls #24,d0
	move.l ([fstring_adr],d0.l,12*24+12),a4	; dummy filename
	move.l ([fsel30_adr],d0.l,11*24+12),a3		; fsel title
	lea fs_addrin_opt+8,a5
	move.l a3,(a5)				; save title
	lea opt_file,a3
	move.l a3,-(a5)			; save file name adr
	move.l (a4)+,(a3)+		; copy dummy file name
	move.l (a4),(a3)+
	clr.b (a3)					; end of string if 8 bytes			
	lea opt_path,a4
	move.l a4,-(a5)			; save path adr
	move.l d7,d0
	bsr.l get_option
	beq.s .lb1					; no path defined, ignore
	move.l a4,a0
.lb0:
	move.b (a1)+,(a0)+		; copy existing path
	bne.s .lb0
.lb1:
	move.l a5,a0
	bsr.l get_file
	bne.s .lb2					; <>0 if Ok
	rts							; else, just quit
.lb2:
	move.l d7,d0
	bsr.l get_option
	muls #24,d6
	move.l tree,a3
	move.l a0,12(a3,d6.l)	; new STRING for dialog
	move #1,-2(a0)				; new flag, validate path
	move.b (a4),(a0)+			; drive name
	move.b #':',d1
	move.b d1,(a0)+
	move.b #'\',d0
	move.b d0,(a0)+
	move.b #'~',(a0)+
.lb3:
	move.b (a4)+,(a1)+
	bne.s .lb3					; full path
.lb4:
	cmp.b	-(a1),d0				; back on "\"
	bne.s .lb4
	clr.b 1(a1)					; end of path
.lb5:
	cmp.b -(a1),d0
	beq.s .lb6
	cmp.b (a1),d1
	bne.s .lb5
	addq.l #1,a1
.lb6:
	moveq #12,d1
.lb7:
	move.b (a1)+,(a0)+
	dbf d1,.lb7
	clr.b (a0)			; ensure string end
	rts
	
	; a3 contains the address of the string indicating the type of file
	; d3: bit0=1 playsound/=0max speed
	;		bit1=1 Alt go sans condition/=0voir condition
	;		bit2=1 Alt go si can step/=0 Go tout seul
	;		bit3=1 replace "max speed" with "dirt mode" with mpeg
	;		bit4=1 Load into RAM allowed, else disabled
	; samp_sizes indicates if there are graphics
	;	- max_imagex and max_imagey gives the size
	;	- samp_num gives the number of frames
	;
	; frequency indicates if there is a sound
	; - sound_bits gives the resolution
	; - frequency gives the frequency
	; - channels gives mono or stereo
	;
	; menu_flag:
	;	FF -> PLAY!
	;  00 -> Convert!
	;  01 -> Create !
	;  02 -> Capture!

fill_dialog:
	tst.b cmd_return
	bne fill_return_and_exit
	sf step_mode
	moveq #0,d0
	GADDR d0,1			; first tree
	move.l a0,a1
	move.l a1,tree_sav
	move.b menu_flag,d0
	ext.w d0
	tst.b is_grab
	beq.s .ntm7
	moveq #2,d0			; with grab, display "capture"
.ntm7:
	muls #24,d0			; from -24 to 48
	move.l ([fstring_adr],d0.l,2*24+24+12),9*24+12(a1)	; into PLAY button
	lea 443(a1),a0		; flag de "VDI"
	bclr #0,(a0)		; enleve SELECTED
	tst.b bad_card
	bne.s .ntm55
	tst.b is_vdi
	beq.s .ntm5
.ntm55:
	bset #0,(a0)		; si "is_vdi" alors SELECTED
.ntm5:
	lea 24*25+11(a1),a0		; flag de "load into ram"
	btst #4,d3			; allowed?
	beq.s .ntm0			; no!
	and.b #$F7,(a0)	; remove disable, keep previous "selected" state
;	and.b #$F7,24(a0)	; same for the text
	bra.s .ntm1
.ntm0:
	and.b #$FE,(a0)	; remove selected
	or.b #8,(a0)		; and disable
;	or.b #8,24(a0)		; same for text
.ntm1:
	lea 24*26+11(a1),a0	; flag de Enhanced
	tst.b enh_flag
	beq.s .ntm9
	and.b #$F7,(a0)	; remove disable
	or.b #1,(a0)		; add selected
	bra.s .ntm99
.ntm9:
	and.b #$FE,(a0)	; remove selected
	or.b #8,(a0)		; and disable
.ntm99:	
	lea 515(a1),a0		; flag de "Grey levels"
	and.b #$F6,(a0)	; enlŠve selected et disabled
	and.b #$F6,48(a0) ; idem pour sa chaine
	tst.b can_fast
	bne.s .ntm4
	or.b #8,(a0)
	or.b #8,48(a0)		; sinon, d‚sactive les deux
.ntm4:
	lea 539(a1),a0		; flag de "Save as..."
	and.b #$F6,(a0)	; enlŠve selected et disabled
	and.b #$F6,48(a0) ; idem pour sa chaine
	tst.b is_grab
	bne.s .ntm8
	tst.b menu_flag
	bmi.s .ntm6			; if Play, don't change
.ntm8:
	or.b #$09,(a0)		; with GRAB (or Menu Convert/Capture), select "Save As" and disable (can't change)
.ntm6:
	btst #1,d3
	bne.s .alt_go
	btst #2,d3
	beq.s .go_seul
; **SA
	bra.s .alt_go
;
;	tst.b can_step
;	bne.s .alt_go
.go_seul:
	or.b #8,(a0)
	or.b #8,48(a0)		; sinon, d‚sactive les deux
.alt_go:
	btst #0,d3
	bne .lb9
	bset #4,273(a1)
	bset #4,297(a1)	; radio buttons
	bclr #0,275(a1)	; max speed unset
	lea 324(a1),a1		; string adr
	move.l (a1),play_sav
	move.l ([fstring_adr],30*24+12),(a1)	; max speed
	btst #3,d3
	beq.s .not_mpeg
	move.l ([fstring_adr],31*24+12),(a1)	; dirt mode
.not_mpeg:
	lea 24(a1),a2
	move.l (a2),sync_sav
	move.l #delay,d0
	move.l d0,(a2)
	move.l d0,a1
	cmp #'mp',comp_txt
	bne.s .normal
	move.l avi_rate,d0
	bsr int_to_str
	bra.s .common
.sync:
	move.l sync_sav,(a2)
	bra.s .lb9
.normal:
	move.l _delay,d1
	beq.s .sync
	move.l #2000,d0
	divs.l d1,d0	; frames/10 sec
	divs #10,d0
	move.l d0,d5
	ext.l d0
	bsr int_to_str				; the int part
	move.b #'.',(a1)+
	swap d5
	add.b #'0',d5
	move.b d5,(a1)+
.common:
	move.l ([fstring_adr],28*24+12),a2	; chaine f/s
	move.b #' ',(a1)+
.c0:
	move.b (a2)+,(a1)+
	bne.s .c0
.lb9:
	moveq #15,d0
	bsr ted_adr
	rept 6
		move.l (a3)+,(a1)+	; the 24 caracters (maxi)
	endr
	move (a3),(a1)				; and 2 more!
	moveq #17,d0
	bsr add_name
	moveq #2,d0
	bsr ted_adr
	tst.l samp_sizes
	bne.s .graphics
	clr.b (a1)
	moveq #3,d0
	bsr ted_adr
	moveq #23,d0				; no graphics found
	bsr add_string
	moveq #4,d0
	bsr ted_adr
	clr.b (a1)
	bra .lb3
.graphics:
	moveq #19,d0				; Display
	bsr add_string
	moveq #0,d0
	move max_imagex,d0
	bsr int_to_str
	move.l #' x  ',(a1)
	addq.l #3,a1
	move max_imagey,d0
	bsr int_to_str
	moveq #3,d0
	bsr ted_adr
	moveq #20,d0				; with
	bsr add_string
	move.l sample_num,d0
	bne.s .connu
	tst.b unknown
	beq.s .connu		; mais nul...
	move.b #'-',(a1)+
	move #'?-',(a1)+
	bra.s .inconnu
.connu:
	bsr int_to_str
.inconnu:
	moveq #21,d0		; frames.
	bsr add_string_spc
	moveq #4,d0
	bsr ted_adr
	move.l #'CODE',(a1)+
	move.w #'C ',(a1)+
	move.l comp_txt,(a1)+
	cmp.b #' ',-(a1)	; codec ends with space?
	beq.s .spc			; if so, ok to go back one char
	addq.l #1,a1		
.spc:
	moveq #17,d0		; present.
	tst.b bad_comp
	beq.s .lb2
	move #18,d0			; absent.
.lb2:
	bsr add_string_spc
.lb3:
	moveq #6,d0
	bsr ted_adr
	move.l frequency,d3
	bne.s .sound
	clr.b (a1)
	moveq #7,d0
	bsr ted_adr
	moveq #24,d0		; No sound
	bsr add_string
	moveq #8,d0
	bsr ted_adr
	clr.b (a1)
	moveq #0,d2				; play sound unselected
	bra .lb4
.sound:
	moveq #22,d0			; Sound
	bsr add_string
	moveq #0,d0
	move sound_bits,d0
	bsr int_to_str
	move.l #' bit',(a1)+
	cmp #2,channels
	beq.s .lb5
	move.l #'s mo',(a1)+
	move.w #'no',(a1)+
	bra.s .lb6
.lb5:
	move.l #'s st',(a1)+
	move.l #'ereo',(a1)+
.lb6:
	clr.b (a1)
	moveq #7,d0
	bsr ted_adr
	moveq #25,d0			; at
	bsr add_string
	move.l d3,d0
	bsr int_to_str
	move.l #' Hz.',(a1)+
	clr.b (a1)
	bsr verify_sound
	moveq #8,d0
	bsr ted_adr
	move.l #'CODE',(a1)+
	move.w #'C ',(a1)+
	move.l s_signe,d0
	beq.s .lb88
	move.l d0,(a1)+
	cmp.b #' ',d0			; codec ends with space?
	beq.s .lb88				; if so, no extra space needed
	move.b #' ',(a1)+
.lb88:
	tst.b bad_sound
	beq.s .lb7
	moveq #18,d0			; absent
	moveq #0,d2				; don't play sound
	bra.s .lb8
.lb7:
	moveq #17,d0			; present
	moveq #1,d2				; play sound
.lb8:
	bsr add_string
.lb4:
	move.l tree,a0
	bset #0,299(a0)	; xx.x frames set or synchro
	btst #4,273(a0)		; radio buttons?
	bne.s .end				; yes, don't touch!
	bclr #0,275(a0)
	or.b d2,275(a0)		; state of play sound
.end:
	tst.b vr2_flag
	beq.s .end_end
	bclr #0,299(a0)
.end_end:
	rts


	; d0 = num‚ro de chaine dans FSTRING
	; si elle ne finit pas par "." un espace est ajout‚ en fin
	
add_string_spc:
	move.b #' ',(a1)+
add_string:
	muls #24,d0
	move.l ([fstring_adr],d0.l,12),a0
.lb0:
	move.b (a0)+,(a1)+
	bne.s .lb0
	subq.l #2,a1
	cmp.b #".",(a1)+		; fin de phrase? (avec un point)
	beq.s .end				; oui
	move.b #' ',(a1)+		; sinon, espace
.end:
	rts
	

	; upon entry: d0 is the index of the string
	; on exit: a1 is the address of the string

string_adr:
	move.l tree,a1
	muls #24,d0
	move.l 12(a1,d0.w),a1	; adr of the string
	rts

ted_adr:
	bsr.s string_adr
	move.l (a1),a1
	rts

	; upon entry, d0 is the integer
	; if d0<0 then format with one digit after comma
	;				  a1 is the address to put it
	; upon exit, a1 is updated.

int_to_str:
	lea intout+100,a0			; as a buffer
	clr.b (a0)					; to end the string
	tst.l d0
	bpl.s .lb0
	neg.l d0
	divsl.l #10,d1:d0
	add.b #'0',d1
	move.b d1,-(a0)			; one char
	move.b #'.',-(a0)
.lb0:
	divsl.l #10,d1:d0
	add.b #'0',d1
	move.b d1,-(a0)			; one char
	tst.l d0
	bne.s .lb0					; not nul, continue!
.lb1:
	move.b (a0)+,(a1)+
	bne.s .lb1
	subq.l #1,a1
	rts

; add filename in dialog
; from DTA
; or memory.bat if dummy
	
add_name:
	bsr.s ted_adr
	lea dta+30,a0
	cmp.b #1,menu_flag		; easybat create?
	beq.s .mem
	cmp.b #2,menu_flag		; capture screen?
	bne.s .normal_file
.mem:
	lea .memory(pc),a0	
.normal_file:
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+		; 12 char maxi	
	rts
.memory: dc.b "[memory.bat]"
	

fill_stat:
	tst.b is_parse
	bne .parse_stat
	moveq #3,d0
	GADDR d0,1
	moveq #11,d0
	bsr.s add_name
	moveq #4,d0
	bsr string_adr
	move.l sample_num,d6
	move.l d6,d0
	bsr int_to_str
	moveq #5,d0
	bsr string_adr
	move.l disp_frame,d5
	move.l d5,d0
	bsr int_to_str
	move.w #' (',(a1)+
	move.l d5,d0
	muls.l #100,d0
	divs.l d6,d0				; in %
	bsr int_to_str
	move.w #'%)',(a1)+
	clr.b (a1)
	moveq #6,d0
	bsr string_adr
	move.l d5,d0
	muls.l #2000,d0
	move.l end_time,d6
	sub.l start_time,d6
	divs.l d6,d0				; number of frames in 10 seconds
	divs #10,d0
	move.l d0,d5
	ext.l d0
	bsr int_to_str				; the int part
	move.b #'.',(a1)+
	swap d5
	add.b #'0',d5
	move.b d5,(a1)+
	clr.b (a1)
	moveq #10,d0				; total time
	bsr string_adr
	divs.l #20,d6				; 1/200 into 1/10 of sec
	divs #10,d6
	move.l d6,d0
	ext.l d0
	bsr int_to_str				; the int part
	move.b #".",(a1)+
	swap d6
	add.b #'0',d6
	move.b d6,(a1)+
	moveq #26,d0				; "sec."
	bsr add_string_spc
	moveq #3,d6
	rts
.parse_stat:
	moveq #9,d0
	GADDR d0,1
	moveq #8,d0
	bsr ted_adr
	lea file,a0				; file name
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+		; 12 char maxi
	moveq #3,d0
	bsr string_adr
	move.l sample_num,d0
	bsr int_to_str
	moveq #4,d0
	bsr string_adr
	move.l disp_frame,d0
	bsr int_to_str
	move.l end_time,d6
	sub.l start_time,d6
	moveq #7,d0				; total time
	bsr string_adr
	divs.l #20,d6				; 1/200 into 1/10 of sec
	divs #10,d6
	move.l d6,d0
	ext.l d0
	bsr int_to_str				; the int part
	move.b #".",(a1)+
	swap d6
	add.b #'0',d6
	move.b d6,(a1)+
	moveq #26,d0				; "sec."
	bsr add_string_spc
	moveq #9,d6
	rts


fill_return_and_exit:
	move.l cmd_return_adr,a0
	move #1,(a0)+		; OK
	lea dta+30,a1
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	clr (a0)+		; file name
.copy_type:
	move.b (a3)+,(a0)+
	bne.s .copy_type
	clr.b (a0)+		; type string
	moveq #0,d0		; default: no graphics
	tst.l samp_sizes
	beq.s .lb0
	moveq #1,d0		; or supported graphics
	tst.b bad_comp
	beq.s .lb0
	moveq #-1,d0	; or unsupported
.lb0:
	move d0,(a0)+
	move max_imagex,(a0)+
	move max_imagey,(a0)+
	move.l sample_num,(a0)+
	move.l comp_txt,(a0)+
	moveq #0,d0		; default: no sound
	move.l frequency,d7
	beq.s .lb1
	bsr verify_sound
	moveq #1,d0
	tst.b bad_sound
	beq.s .lb1
	moveq #-1,d0
.lb1:
	move d0,(a0)+
	move sound_bits,(a0)+
	move channels,(a0)+
	move.l d7,(a0)+
	move mov_h,-(sp)
	GEMDOS 62,4
	bra.l end_end

set_video:
	tst.b slide_flag
	beq.s .no_slide		; no slide of anim
	bclr #7,slide_flag
	bne.s .no_slide		; slide, but switch if the first file!
.end:
	rts
.no_slide:
	tst.b conv_flag
	bne.s .end
	tst.b mountain
	bne.s .end				; don't reserve when running child process
	bsr.l try_window
;	tst.b step_mode
;	beq.s .lb0				; no step mode !
;	move.l tree_filename,a1		; else, display dialog once before reserving
;	move.l tga_file_ptr,(a1)
;	lea _dialog_table,a3
;	move.l 4*LAST_TREE(a3),a3
;	moveq #0,d6	; redessiner depuis objet 0
;	moveq #0,d0
;	bsr.l wdial_change
;	moveq #1,d7		; just draw
;	moveq #LAST_TREE,d6
;	bsr manage_tree	
;	bra.s .lb1
;.lb0:
	bsr.l winup_on			
.lb1:
	if SOURIS=0
	GEM_VDI hide_mouse
	endif
;	bsr.l try_window
	lea vi_int,a3
	tst.b is_win
	bne .fin					; a window is opened!!!
	tst.b switched
	bne sv_falcon
	tst.b cmd_coord		; here no switch
	beq.s .black			; no coords so black the screen
	rts						; else, nothing to do!
.black:
	cmp #16,planes
	beq.s .one
	clr (a3)					; background is 0
	move.l comp_txt,d0
	swap d0
	cmp #'CD',d0			; CDH1, CHL1, CDV1
	beq.s .ok
	swap d0
	cmp.l #'fli ',d0
	beq.s .ok
	cmp.l #'flc ',d0
	beq.s .ok
	cmp.l #'VIDI',d0
	beq.s .ok
	cmp.l #'seq4',d0
	beq.s .ok
	cmp.l #'kin4',d0
	beq.s .ok
	cmp.l #'dlt4',d0
	beq.s .ok
	cmp.l #'VMAS',d0
	beq.s .ok
	cmp.l #'VFAL',d0
	beq.s .ok
	move.b #'0',d0
	cmp.l #'dl/0',d0
	beq.s .ok
	cmp.l #'flm0',d0
	beq.s .ok
.one:
	move #1,(a3)
.ok:
	GEM_VDI vsf_color
	GEM_VDI v_bar			; else, just blacks the screen
.fin:
	tst.b enh_flag
	beq .ok2
	moveq #0,d0
	move d0,(a3)
	GEM_VDI vsf_color
	lea vrf_pts,a0
	lea vgt_pts,a1
	move offsx+2,d0
	move d0,(a0)+			; offsx rectangle
	move d0,(a1)+			; x texte 1ere ligne
	move offsy,d1
	add max_imagey,d1
	add max_imagex,d0
	subq #1,d0
	move d1,(a1)+			; y texte 1ere ligne
	move d1,(a0)+			; offsy rectangle
	move d0,(a0)+			; x' rectangle
	add enh_extra,d1
	subq #1,d1
	move d1,(a0)			; y' rectangle
	GEM_VDI vr_recfl	
	lea DVI_DELTA,a0
	moveq #0,d0
	moveq #127,d1
.clear_intin:
	move.l d0,(a0)+
	dbf d1,.clear_intin	; prepare intin pour V-GTEXT
.ok2:
	rts

vr_recfl: dc.l .vrf_cont,dum,vrf_pts,dum,dum
.vrf_cont: dc.w 114,2,0,0,0,0,0

v_gtext: dc.l vgt_cont,DVI_DELTA,vgt_pts,dum,dum
vgt_cont: dc.w 8,1,0,128,0,0,0

vsf_interior: dc.l vi_cont,vi_int,dum,dum,dum
vi_cont: dc.w 23,0,0,1,0,0,0,0,0,0,0,0
vi_int: dc.w 1


sv_falcon:
	tst.b _conv_video
	bne.s .suite
	tst.b res_switch
	bmi.s .is_falc
	beq.s .is_falc			; if 0, a Falcon in TC and an FLM anim!
	move.l comp_txt,d0
	lsr.l #8,d0
	cmp.l #'flm',d0
	beq.s .use_tt_res
	lsr.l #8,d0
	cmp #'CD',d0
	bne.s .other
.use_tt_res:
	move tt_res,d0
	bra.s .tt_comm
.other:
	cmp #4,planes
	beq.s .st_low
	moveq #7,d0			; else it's a TT, to 320x480x256
	bra.s .tt_comm
.st_low:
	moveq #0,d0			; to 320x200x16 (with SEQ for example)
.tt_comm:
	moveq #1,d7			; to display info box if AlberTT
	bra setscreen

.is_falc:
	move.b conv_flag,conv_video
	beq.s .suite
	rts						; pas de changement de video si M_PLAYER pere
								; faire changement dans M_PLAYER fils
.suite:
	move.l physbase,a0
	move #9599,d1
.clear:
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	dbf d1,.clear
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr

	lea video_reg,a0
	MOVE.L   $FFFF8282.W,(a0)+
   MOVE.L   $FFFF8286.W,(a0)+
   MOVE.L   $FFFF828A.W,(a0)+
   MOVE.L   $FFFF82A2.W,(a0)+
   MOVE.L   $FFFF82A6.W,(a0)+
   MOVE.L   $FFFF82AA.W,(a0)+
   MOVE.W   $FFFF820A.W,(a0)+
   MOVE.W   $FFFF82C0.W,(a0)+
   move.w   $FFFF8266.W,(a0)+
   MOVE.W   $FFFF8266.W,(a0)+
   MOVE.W   $FFFF82C2.W,(a0)+
   MOVE.W   $FFFF8210.W,(a0)+

	move old_video,d0
	and.w	#$10,d0		; vga?
	beq.s	.rgb
.vga:
	move.w #$114,d1	; true color, interlace, vga
	bra.s	.set
.rgb:
	move.w old_video,d1
	and.w	#$20,d1		; keep pal/ntsc flag
	or.w #4,d1			; true color
.set:
	move.w d1,-(sp)
	move.w #-1,-(sp)
	move.l physbase,-(sp)
	move.l physbase,-(sp)
	XBIOS 5,12
	XBIOS 88,4
	move.l		$ffff9800.w,old_border
	clr.l		$ffff9800.w
; Monitor: VGA
; 320*240, True Colour, 60.0 Hz, 31470 Hz
	move old_video,d1
	btst #4,d1					; vga?
	beq.s .lb0
   MOVE.L   #$C6008B,$FFFF8282.W
   MOVE.L   #$1302AA,$FFFF8286.W
   MOVE.L   #$8B0097,$FFFF828A.W
   MOVE.L   #$41903FF,$FFFF82A2.W
   MOVE.L   #$3F003D,$FFFF82A6.W
   MOVE.L   #$3FD0415,$FFFF82AA.W
   MOVE.W   #$200,$FFFF820A.W
   MOVE.W   #$186,$FFFF82C0.W
   CLR.W    $FFFF8266.W
   MOVE.W   #$100,$FFFF8266.W
   MOVE.W   #$5,$FFFF82C2.W
   MOVE.W   #$140,$FFFF8210.W
   bra .end
.lb0:
	btst #5,d1				; pal?
	beq.s .lb1				; no
; Monitor: RGB/TV (PAL)
; 320*240, True Colour, 50.0 Hz, 15625 Hz
   MOVE.L   #$FE009A,$FFFF8282.W
   MOVE.L   #$5A0039,$FFFF8286.W
   MOVE.L   #$9A00D9,$FFFF828A.W
   MOVE.L   #$2710239,$FFFF82A2.W
   MOVE.L   #$590059,$FFFF82A6.W
   MOVE.L   #$239026B,$FFFF82AA.W
   MOVE.W   #$200,$FFFF820A.W
   MOVE.W   #$181,$FFFF82C0.W
   CLR.W    $FFFF8266.W
   MOVE.W   #$100,$FFFF8266.W
   MOVE.W   #$0,$FFFF82C2.W
   MOVE.W   #$140,$FFFF8210.W
	bra.s .end
.lb1:
; Monitor: RGB/TV (NTSC)
; 320*240, True Colour, 59.5 Hz, 15594 Hz
   MOVE.L   #$FE0099,$FFFF8282.W
   MOVE.L   #$590038,$FFFF8286.W
   MOVE.L   #$9900DA,$FFFF828A.W
   MOVE.L   #$20D01FB,$FFFF82A2.W
   MOVE.L   #$1B001B,$FFFF82A6.W
   MOVE.L   #$1FB0207,$FFFF82AA.W
   MOVE.W   #$200,$FFFF820A.W
   MOVE.W   #$181,$FFFF82C0.W
   CLR.W    $FFFF8266.W
   MOVE.W   #$100,$FFFF8266.W
   MOVE.W   #$0,$FFFF82C2.W
   MOVE.W   #$140,$FFFF8210.W
.end:
	btst #2,([kbshift])
	bne.s .end
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts

setscreen:
	tst.b albertt
	beq.s .normal
	move.b d0,.directbyte
	moveq #13,d6
	bsr manage_tree
	pea .direct(pc)
	XBIOS 38,6
	rts
.normal:
	move.w d0,-(sp)
	moveq #-1,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	XBIOS 5,12				; setscreen
	rts
.direct:
	lea $FFFF8262.w,a0
	move.b (a0),d0
	and #$F8,d0				; remove resolution but keep smear+gray if any
	or.b .directbyte(pc),d0	; new resolution
	move.b d0,(a0)			; and set it.
	moveq #0,d0
	move.l albert_phys,a0
	move #9599,d1
.lb0:
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	dbf d1,.lb0
	rts
.directbyte: dc.w 0

restore_video:
	tst.b _conv_video
	bne.s .suite
	tst.b slide_flag
	bne .out
	tst.b res_switch
	bmi.s .is_falc
	beq.s .is_falc				; Falcon TC with an FLM anim
	move old_video,d0			; else it's a TT
	moveq #-1,d7				; to remove box on AlberTT
	bra setscreen

.is_falc:
	tst.b conv_video
	beq.s .suite
	rts						; deja fait dans M_PLAYER FILS
.suite:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	move old_video,-(sp)
   XBIOS 88,4

	lea video_reg,a0
	MOVE.L   (a0)+,$FFFF8282.W
   MOVE.L   (a0)+,$FFFF8286.W
   MOVE.L   (a0)+,$FFFF828A.W
   MOVE.L   (a0)+,$FFFF82A2.W
   MOVE.L   (a0)+,$FFFF82A6.W
   MOVE.L   (a0)+,$FFFF82AA.W
   MOVE.W   (a0)+,$FFFF820A.W
   MOVE.W   (a0)+,$FFFF82C0.W
   move.w   (a0)+,$FFFF8266.W
   MOVE.W   (a0)+,$FFFF8266.W
   MOVE.W   (a0)+,$FFFF82C2.W
   MOVE.W   (a0)+,$FFFF8210.W

	move.l old_border,$ffff9800.w
   move #-1,-(sp)
	move.l old_screen,-(sp)
	move.l old_screen,-(sp)
	XBIOS 5,12

	move.l stack_adr,-(sp)
	GEMDOS 32,6
	move.l physbase,a2
	cmp.l old_screen,a2
	beq.s .out
	move.l physbase2,a2	; the real address (unaligned)
	bsr mfree
.out:
	rts

qt_step_mode:
	tst.b is_mjpg
	beq.s .lbm1
	move.l mjpg_step_compression,mjpg_comp
.lbm1:
	tst.l samp_sizes
	beq .out
	tst.b bad_comp			; compression supported?
	bne .out					; no, only sound!
	moveq #0,d6				; current samp
	moveq #0,d5				; current s2chunk
	move.l s2chunks,a4
	move.l 12(a4),a5		; next s2chunk
	move.l 8(a4),d4		; tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
	move.l codecs,a2
	move.l (a2,d0.l),imagex
	move.l 4(a2,d0.l),imagey
	move.l 8(a2,d0.l),depth
	tst.b step_vdi
	bne.s .stepcomp
	move.l 12(a2,d0.l),compression
	bra.s .comm
.stepcomp:
	move.l step_compression,compression
.comm:
	moveq #-1,d7				; i for the loop
	bra .end_of_loop
.loop:
	move.l ([chunkoffs],d7.l*4),d0
	SEEK d0,0	; start of chunk data
	move.l d5,d1
	muls.l #12,d1
	cmp.l d7,a5				; jumps if i<>next_s2chunk
	bne.s .lb4
	move.l d5,d0
	addq.l #1,d0
	sub.l s2chunk_num,d0	; jumps if cur_s2chunk + 1 >= s2chunk_num
	bpl.s .lb4
	addq.l #1,d5			; cur_s2chunk++
	addq.l #8,d1
	addq.l #4,d1			; one bloc more
	move.l 12(a4,d1.l),a5
.lb4:
	move.l 4(a4,d1.l),d2	; num samps
	cmp.l 8(a4,d1.l),d4	; tags equals?
	beq .end_of_samps	; yes, that's ok
	move.l 8(a4,d1.l),d4	; new tag
	move.l d4,d0
	asl.l #4,d0				; each codec 16 bytes
	move.l (a2,d0.l),imagex
	move.l 4(a2,d0.l),imagey
	move.l 8(a2,d0.l),depth
	move.l 12(a2,d0.l),compression
	bra.s .end_of_samps
.samp_loop:
	move.l samp_sizes,a0
	move.l (a0,d6.l*4),bufused	; size used for the current sample
	cmp.l sample_num,d6	; exit if cur_samp>=sample_num
	bpl.s .out
	addq.l #1,d6
	movem.l d2-d7/a2-a6,-(sp)	; saves registers
	move.l buffer,d0
	add.l mjpg_offset,d0
	move.l d0,-(sp)
	move.l bufused,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; fread!
	move.l compression,a0
	jsr (a0)					; decodes and displays
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	movem.l (sp)+,d2-d7/a2-a6
.bug:
	bsr inc_frame
	beq.s .out				; =0 quit
	bpl.s .end_of_samps	; >0 next
	bsr save_frame			; <0 save
	bmi.s .bug
.end_of_samps:
	subq.l #1,d2
	bpl.s .samp_loop
.end_of_loop:
;	move.l d7,d0
;	addq.l #2,d0
;	cmp.l chunkoff_num,d0
;	bne.s .tagada
;	illegal
;.tagada:
	addq.l #1,d7			; inc i
	cmp.l chunkoff_num,d7
	bmi .loop
.out:
	bsr close_step_dialog
	rts

avi_step_mode:
	tst.b is_mjpg
	beq.s .lbm1
	move.l mjpg_step_compression,mjpg_comp
.lbm1:
	move.l sample_num,d7
	move.l chunkoffs,a6
	addq.l #4,a6
	bra.s .loop
.lb0:
	SEEK (a6)+,0			; good positon
	move.l buffer,d1
	add.l mjpg_offset,d1
	move.l d1,-(sp)
	move.l (a6)+,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the frame
	move.l (a6)+,a3		; the time
	movem.l d3/d7/a3/a6,-(sp)
;	bsr .vide_tout
	move.l compression,a0
	jsr (a0)
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	movem.l (sp)+,d3/d7/a3/a6
.bug:
	bsr inc_frame
	beq.s .quit
	bpl.s .loop
	bsr save_frame
	bmi.s .bug
.loop:
	subq.l #1,d7
	bpl.s .lb0
.quit:
	bsr.s close_step_dialog
	rts
	
close_step_dialog:
	tst.b switched
	bne.s .nofalcon
	moveq #-1,d7
	moveq #LAST_TREE,d6
	bsr manage_tree
.nofalcon:
	rts
	
;.vide_tout:
;	move.l #$FF7FFF7F,d7
;	move #38399,d3
;	move.l physbase,a0
;.vt0:
;	rept 4
;		move.l d7,(a0)+
;	endr
;	dbf d3,.vt0
;	rts


fli_step_mode:
	tst.b bad_comp
	beq.s .good
	st stopped
	rts
.good:
	SEEK #128,0				; start of frames
	clr.l disp_frame
	move.l sample_num,d7	; number of frames
	lea cvid_fix0,a6		; as a buffer for the palette
	cmp.l #'flh ',comp_txt
	bne.s .palette_mode
	move.l hc_cvid,a6		; with FLH, it's a 16 bits mode
.palette_mode:
	move.l image,a5
	move.l buffer,a4
	move screenw,d3
	add d3,d3				; to skip one line
	ext.l d3
	bra .next
.loop:
	addq.l #1,disp_frame
	lea intout,a3
	pea (a3)					; as a buffer
	move.l #16,-(sp)		; the frame header
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	move.l (a3)+,d0
	INTEL d0					; size of the frame
	subq.l #8,d0
	subq.l #8,d0			; 16 bytes yet read
	cmp #$faf1,(a3)+		; magic for a normal frame
	beq.s .normal
	SEEK d0,1				; else skips
	bra .next
.normal:
	move (a3),d6
	ror #8,d6				; number of chunks
	pea (a4)					; the buffer
	move.l d0,-(sp)		; the len to read
	move mov_h,-(sp)
	GEMDOS 63,12			; reads one frame
	move.l a4,a0			; start of the frame
	bra .ch_loop
.chunk:
	move.l (a0)+,d0
	INTEL d0					; chunk size
	lea -4(a0,d0.l),a1	; end of the chunk
	move (a0)+,d0
	ror #8,d0				; chunk ID
	cmp #12,d0				; fli_lc
	bne.s .lb0
	bsr.l fli_lc
	bra .lb4
.lb0:
	cmp #7,d0				; flc_lc
	bne.s .lb00
	bsr.l flc_lc
	bra.s .lb4
.lb00:
	cmp #15,d0				; fli_brun
	bne.s .lb1
	bsr.l fli_brun
	bra.s .lb4
.lb1:
	cmp #11,d0				; fli_color (64)
	bne.s .lb2
	bsr.l fli_color_64
	bra.s .lb4
.lb2:
	cmp #4,d0				; flc_color (256)
	bne.s .lb20
	bsr.l fli_color_256
	bra.s .lb4
.lb20:
	cmp #13,d0				; fli_black
	bne.s .lb3
	bsr.l fli_black
	bra.s .lb4
.lb3:
	cmp #16,d0				; fli_copy
	bne.s .lb3a
	bsr.l fli_copy
	bra.s .lb4
.lb3a:
	cmp #27,d0
	bne.s .lb3b
		tst.b nova
		beq.s .lb3c
		bsr flh_delta
		bra.s .lb4
	.lb3c:
		bsr flh_delta_falc
	bra.s .lb4
.lb3b:
	cmp #25,d0
	bne.s .lb4
		tst.b nova
		beq.s .lb3d
		bsr flh_brun
		bra.s .lb4
	.lb3d:
		bsr flh_brun_falc
.lb4:
	move.l a1,a0			; unknow ID, just skip!
.ch_loop:
	dbf d6,.chunk
		tst.b is_vdi
		beq.s .bug
		movem.l a0-a4/d0-d6,-(sp)
		jsr vdi_display
		movem.l (sp)+,a0-a4/d0-d6
.bug:
	bsr inc_frame
	beq.s .exit
	bpl.s .next
	bsr save_frame
	bmi.s .bug
.next:
	dbf d7,.loop
.stop:
	st stopped
.exit:
	bsr close_step_dialog
	rts

ritme: dc.l 1

_prepare_chaines:
	moveq #6,d0
	GADDR d0,1
	move.l a0,a2
	move.l ritme(pc),d0
	move.l 684(a2),a3
	move.l (a3),a3			; tedinfo du ritme!
	bsr .add_int
	move.l 30*24+12(a2),a3
	moveq #0,d6
	move.l (a3),a3
	move.b d6,(a3)			; chaine New L … ZERO
	move.l 31*24+12(a2),a3
	move.l (a3),a3
	move.b d6,(a3)			; chaine New H … ZERO
	move.l #200,d6
	move anim_type,d7
	bne.s .pas_fli
.avec_delai:
	move.l _delay,d3	; 1/200 par image
.zorglub:
	move.l d6,d4
	divs d3,d4			; key frame (1 par seconde)
	ext.l d4
	bra.s .commun
.pas_fli:
	cmp #3,d7			; FLM VMAS
	beq.s .avec_delai
	cmp #-3,d7
	beq.s .mpeg
	cmp #1,d7
	bne.s .pas_avi
.mpeg:
	move.l avi_rate,d4
	move.l d4,d3
	lsr.l #1,d3
	add.l d6,d3
	divs d4,d3
	ext.l d3
	bra.s .commun
.pas_avi:
	cmp #2,d7
	bne.s .pas_mov
	move.l t2samps,a0
	cmp.l #0,a0
	beq.s .autre
	move.l t2samp_num,d2
	moveq #0,d3				; total time
	moveq #0,d4				; total frames
.lb0:
	move.l (a0)+,d0		; number of frames
	add.l d0,d4				; updates the number of frames
	muls.l (a0)+,d0		; times their duration
	add.l d0,d3				; updates the total time
	subq.l #1,d2
	bne.s .lb0				; till the end of t2_samps
	move.l qt_timescale,d1
	bne.s .go_on
	move.l #1000,d1
.go_on:
	muls.l d6,d0:d3
	divs.l d1,d0:d3		; total de 1/200 pour l'anim
	divs.l d4,d3			; 1/200 par image
	bra.s .zorglub
.pas_mov:
	cmp #-1,d7
	bne.s .pas_dl
	bra .avec_delai
.pas_dl:
.autre:
	moveq #25,d3
	moveq #8,d4
.commun:
	move.l tree,a2
	move.l 276(a2),a1	; tedinfo
	lea _temps(pc),a3
	move.l a3,(a1)
	move.l d3,d0
	bsr.s .add_int
	move.l 252(a2),a1
	lea _key(pc),a3
	move.l d4,d0
	move.l a3,(a1)
	bsr.s .add_int
	bclr #0,515(a2)	; ADD a sound cleared
	bset #3,539(a2)	; no save sound
	tst.b bad_sound
	bne.s .end
	tst.l sound_num
	beq.s .end
	bclr #3,539(a2)
.end:
	rts
.add_int:
	lea -1(a7),a0
	clr.b (a0)
	moveq #10,d2
.lbx:
	divsl.l d2,d1:d0
	add.b #'0',d1
	move.b d1,-(a0)
	tst.l d0
	bne.s .lbx
	move.l (a0),(a3)
	rts
_temps: dc.l 0
_key: dc.l 0
	even


init_step_mode:
	move d7,anim_type		; -3=mpeg, -2=GIF, -1=DL, 0=FL?, 1=AVI, 2=MOV, 3=VMAS/VFAL
	bsr _prepare_chaines
.again:
	moveq #0,d7
	moveq #6,d6
	bsr manage_tree
	cmp #29,d6							; cancel
	bne.s .not_cancel
.cancel:
	moveq #0,d0							; EQ si cancel
	sf switched
	rts
.not_cancel:
	cmp #21,d6							; ADD a sound?
	bne.s .other
	bsr select_avr_file
	bsr is_sound_accepted
	bra.s .again
.other:
	cmp #22,d6						; save sound?
	bne.s .other2
	bsr select_avr_file
	move.l tree,a0
	btst #0,515(a0)
	beq.s .again						; cancelled
	bsr save_avr_file
	bra.s .again
.other2:
	bsr.l get_quality_zoom
	move.l tree,a0
	move.l 684(a0),a5
	move.l (a5),a5		; chaine ritme
	bsr _number
;.termine:
	move.l d0,d1
	bne.s .ok1
	moveq #1,d1		; au moins 1, faut pas deconner!
.ok1:
	move.l d1,ritme
	clr _ritme
	move.l sample_num,d0
	add.l d1,d0
	subq.l #1,d0
	divs.l d1,d0
	move.l d0,sample_num2
	move.l 30*24+12(a0),a5	; chaine NEW L
	move.l (a5),a5
	bsr _number
	move.l d0,d2				; sauve L (ou z‚ro si rien)
	seq d3
	move.l 31*24+12(a0),a5	; chaine NEW H
	move.l (a5),a5
	bsr _number
	tst.l d0
	seq d1
	cmp #32,d6					; calc button?
	bne.s .not_calc
	bsr _calc_ratio
	bra .again
.not_calc:
	eor.b d1,d3
	beq.s .pas_un_seul
	moveq #0,d0					; seul L ou H est rempli
	bsr alert
	bra .again
.pas_un_seul:
	move d2,d4		; L wanted
	move d0,d5		; H wanted
	move d6,d7
	move work_out,d1					; screenw
	addq #1,d1
	muls boxh,d1
	asl.l #2,d1							; size of one text line in pixels
	move.l d1,top_lines_size
	bsr malloc
	move.l d0,top_lines_buff
	move.l work_out,d6
	add.l #$10001,d6
	move max_imagey,d1
	cmp d6,d1
	bmi.s .w_ok
	move d6,d1
.w_ok:
	tst d5
	bne.s .non_empty1
	move d1,d5
.non_empty1:
	move d1,tga_srcy
	move d5,tga_desty
	cmp d5,d1	
	sne tga_resize
	beq.s .nochange1
	move d5,d1
.nochange1:
	move d1,d6
	swap d6
	move max_imagex,d1
	cmp d6,d1
	bmi.s .h_ok
	move d6,d1
.h_ok:
	tst d4
	bne.s .non_empty2
	move d1,d4
.non_empty2:
	move d1,tga_srcx
	move d4,tga_destx
	cmp d4,d1
	sne tga_resize+1
	beq.s .nochange2
	move d4,d1
.nochange2:
	move d1,d6
	swap d6
	muls d6,d1
	move.l d1,d0
	add.l d1,d1
	cmp #3,d7							; TGA 24 bits?
	bne.s .16bits
	add.l d0,d1							; x 3, R G B
.16bits:
	add.l #18+30,d1						; TGA header + security
	move.l d1,tga_buff_size
	bsr malloc
	move.l d0,a0
	move.l d0,tga_buff
	move.l #$00000200,(a0)+
	clr.l (a0)+
	clr.l (a0)+
	swap d6
	ror #8,d6
	move d6,(a0)+		; W
	swap d6
	ror #8,d6
	move d6,(a0)+		; H
	cmp #3,d7			; TGA 24 bits?
	beq.s .lb3
	move #$1020,(a0)	; 16 bits
	bra.s .lb4
.lb3:
	move #$1820,(a0)	; 24 bits
.lb4:
	sf auto_save_tga
	sf auto_run_tga
	sf write_error
;	clr mf_int
;	GEM_AES graf_mouse				; the arrow
;	GEM_VDI show_mouse
	lea fs_addrin_tga,a0
	move.l ([fsel30_adr],9*24+12),8(a0)	; tga fsel title
	cmp #5,d7
	bmi.s .tga_save
	st conv_flag						; avec une conversion...
	st auto_save_tga					; ...sauvegarde automatique!!!
	st auto_run_tga					; ...sans intervention humaine!
	move.l ([fsel30_adr],10*24+12),8(a0)	; convert fsel title
	bra.s .pas_comp
.tga_save:
	move.l tree,a1
	btst #0,659(a1)					; bouton RLE
	sne tgac								; flag a FF si compression demandee
.pas_comp:
	bsr.l auto_path_name
	beq.s .lb5							; if 0, dont use fileselector
	lea fs_addrin_tga,a0
	bsr.l get_file
	beq .cancel							; 0 if abort/quit
.lb5:
	lea tga_path,a0
	lea tga_full,a1
	move.l a1,a2		; last '\'
.lb0:
	move.b (a0)+,d0
	move.b d0,(a1)+
	beq.s .lb2
	cmp.b #'\',d0
	bne.s .lb0
	move.l a1,a2
	bra.s .lb0
.lb2:
	move.l a2,tga_file_ptr	; the name of the file
	tst.b conv_flag
	bne _prepare_bat
	move.l #'0000',(a2)+		; default name
	move.l #'0000',(a2)+
	lea -1(a2),a1				; pointer to last digit
	move.l a1,tga_digit
	move.l #'.TGA',(a2)+
	clr.b (a2)
	sub #12,a2
	lea tga_file,a1
	moveq #6,d0
.lb1:
	move.b (a1)+,d1
	beq.s .arg
	cmp.b #'*',d1
	beq.s .arg
	cmp.b #'?',d1
	beq.s .arg
	cmp.b #'.',d1
	beq.s .arg
	move.b d1,(a2)+
	dbf d0,.lb1
.arg:
	cmp.l tga_file_ptr,a2
	bne.s .ok					; at least one good byte!
.default:
	move.w #'FR',(a2)+
	move.b #'M',(a2)+
.ok:
	tst.b tgac
	beq.s .pas_comp2
	move.l tga_buff_size,d1
	bsr malloc
	move.l d0,tga10_buff
.pas_comp2:
	moveq #-1,d0
	rts

_calc_ratio:
	move.l d0,d1
	beq.s .calc_h
	muls max_imagex,d1
	divs max_imagey,d1
	move.l d1,d2
	bra.s .commun
.calc_h:
	move.l d2,d0
	beq.s .defaut
	muls max_imagey,d0
	divs max_imagex,d0
	bra.s .commun
.defaut:
	move max_imagex,d2
	move max_imagey,d0
.commun:
	move.l #$FFFF,d3
	btst #0,34*24+11(a0)		; aligne sur 1?
	bne.s .pas_aligne
	addq.w #2,d0
	addq.w #2,d2
	lsl #2,d3
	btst #0,35*24+11(a0)		; align‚ sur 4?
	bne.s .pas_aligne
	addq.w #2,d0
	addq.w #2,d2
	add d3,d3
	btst #0,36*24+11(a0)		; align‚ sur 8?
	bne.s .pas_aligne
	addq.w #4,d0
	addq.w #4,d2
	add d3,d3
.pas_aligne:
	and.l d3,d0
	and.l d3,d2
	move.l #10000,d3
	cmp.l d3,d0
	bpl.s .trop_grand
	cmp.l d3,d2
	bpl.s .trop_grand
	move.l a0,a5
	move.l 31*24+12(a5),a1	; chaine NEW H
	move.l (a1),a1
	bsr int_to_str
	move.l 30*24+12(a5),a1	; chaine NEW L
	move.l d2,d0
	move.l (a1),a1
	bsr int_to_str
	rts
.trop_grand:
	moveq #1,d0
	bsr alert
	rts


is_sound_accepted:
	clr -(sp)
	pea avr_full
	GEMDOS 61,8			; open sound
	move.l d0,d3
	bmi.s .dont_exist
	pea cvid_fix0
	move.l #28,-(sp)	; enough for WAV or AVR header
	move d3,-(sp)
	GEMDOS 63,12
	move d3,-(sp)
	GEMDOS 62,4
	lea cvid_fix0,a0
	cmp.l #'RIFF',(a0)
	beq.s .wav
	cmp.l #'2BIT',(a0)
	bne.s .bad_type
	clr.b 22(a0)
	move.l 22(a0),d1
	bra.s .common
.wav:
	move.l 24(a0),d1
	INTEL d1
.common:
	move.b bad_sound,d2
	bsr _verify_frequency
	tst.b bad_sound
	bne.s .refused
	move.b d2,bad_sound
	rts
.dont_exist:
	moveq #25,d0						; alert file doesn't exist
	bra.s .oops
.bad_type:
	moveq #3,d0
	bra.s .oops
.refused:
	move.b d2,bad_sound
	moveq #2,d0
.oops:
	bsr alert
	bra _cancel_sound
mpeg_info_flag: dc.b 0	; for alert box once
	even	

select_avr_file:
;	clr mf_int
;	GEM_AES graf_mouse				; the arrow
;	GEM_VDI show_mouse
	move.l d6,d7						; the button
	bsr.l auto_path_name
	beq.s .lb1							; if OK, skip file selector
	lea fs_addrin_avr,a0
	bsr.l get_file
	beq.s _cancel_sound					; if abort, quits
.lb1:
	lea avr_path,a0
	lea avr_full,a1
	move.l #avr_file,d1
	bsr.l full_pathname
	move.l tree,a0
	bset #0,515(a0)
	rts
_cancel_sound:
	move.l tree,a0
	bclr #0,515(a0)
	rts

save_avr_file:
	clr -(sp)
	pea avr_full
	GEMDOS 60,8				; fcreate
	move d0,mov_h2
	bpl.s .ok
.gloub:
	rts
.ok:
	move.l #128,d4
	move.l snd_temp_size,d3
	cmp.l d4,d3
	bpl.s .enough
	move.l d4,d3
.enough:
	pea avr_full
	move.l d4,-(sp)		; 128 dummy for header
	move mov_h2,-(sp)
	GEMDOS 64,12
	cmp.l d4,d0
	bne.s .gloub
	move.l tree,-(sp)
	cmp #1,anim_type
	beq.s .avi_sound
	bsr init_sound			; sinon MOV
	bra.s .loaded
.avi_sound:
	bsr adapt_d4_size		; only for D3!!!
	bsr read_sound
.loaded:
	move.l (sp)+,tree
	move mov_h2,d7
	move #2,-(sp)
	move d7,-(sp)
	clr.l -(sp)
	GEMDOS 66,10
	move.l d0,d6			; taille du fichier
	move.l #128,d5
	sub.l d5,d6				; taille son
	move.l snd_temp,a3	; buffer
	clr -(sp)
	move d7,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; debut du fichier
	move.l a3,a0
	move.l #'2BIT',(a0)+
	move.l #'M_PL',(a0)+
	move.l #'AYER',(a0)+
	move channels,d2
	cmp #2,d2
	seq d0
	ext.w d0
	move d0,(a0)+
	move sound_bits,d3
	move d3,(a0)+
	move #$FFFF,d0				; signed
	cmp #16,d3
	beq.s .signe
	cmp.l #'twos',s_signe
	beq.s .signe
	moveq #0,d0					; cas 8 bits AVI ou raw MOV
.signe:
	move d0,(a0)+				; signed ou non
	lsl d2,d3				; 16 (m8), 32 (m16, s8) 64 (s16)
	lsr #5,d3
	lsr.l d3,d6				; nombre de samples
	clr (a0)+
	st (a0)+
	st (a0)+
	move.l _freq_sav,d0
	move.l d0,(a0)
	st (a0)
	addq.l #4,a0
	move.l d6,(a0)+
	clr.l (a0)+
	move.l d6,(a0)+
	moveq #44,d0
.del_header:
	clr (a0)+
	dbf d0,.del_header
	move.l a3,-(sp)
	move.l d5,-(sp)
	move d7,-(sp)
	GEMDOS 64,12
	move d7,-(sp)
	GEMDOS 62,4
	clr mov_h2
	move.l snd_temp,a2
	bsr mfree
	move.l tree,a0
	bset #3,539(a0)	; disable seconde sauvegarde
	rts

_prepare_bat:
	cmp #-3,anim_type
	bne.s .pas_mpg
	tst.l sample_num
	bne.s .pas_gif
	bsr.l _count_mpg_frames
	bne.s .commun		; images trouv‚es!
	moveq #0,d0			; EQ si cancel
	sf switched
	rts
.pas_mpg:
	cmp #-2,anim_type		; un GIF?
	bne.s .pas_gif
	tst.l sample_num		; le nombre d'images est connu?
	bne.s .pas_gif			; oui, pas de traitement … part
	bsr _count_gif_frames
.commun:
	move.l ritme(pc),d1
	move.l sample_num,d0
	add.l d1,d0
	subq.l #1,d0
	divs.l d1,d0
	move.l d0,sample_num2
.pas_gif:
	move d7,d6
	subq #7,d6				; -1=mov 16, 0=mov 8, 1=avi 8, 2=avi 16
	move.l tga_buff,a3
	add #18,a3
	move.l #'m_pl',(a3)+
	move.l #'ayer',(a3)+
	move #$0d0a,d7
	move d7,(a3)+
	move #'o=',(a3)+
	cmp #1,d6
	bmi.s .pas_avi
	bne.s .en16
	move.b #'#',(a3)+		; pour avi 8 bits
	bra.s .pas_avi
.en16:
	move.b #'+',(a3)+
	moveq #-1,d6     		; pour la suite = mov 16
.pas_avi:
	clr.b (a2)
	lea tga_full,a1
.lb0:
	move.b (a1)+,(a3)+
	bne.s .lb0
	subq.l #1,a3
	lea tga_file,a0
.lb1:
	move.b (a0)+,(a3)+
	bne.s .lb1
	subq.l #1,a3
	move d7,(a3)+
	move.l #'_TEM',(a2)+
	move.l #'P.BA',(a2)+
	move.w #$5400,(a2)
	tst d6
	bmi.s .tga
	move.l #'c=xi',(a3)+
	move #'mg',(a3)+
	bra.s .toto
.tga:
	move.l #'c=tg',(a3)+
	move #'a2',(a3)+
.toto:
	move d7,(a3)+
	move #'w=',(a3)+
	moveq #0,d0
	move max_imagex,d0
	cmp #2,d6				; AVI Cram 16?
	bne.s .skip
	addq #3,d0
	and #$FC,d0
.skip:
	move d0,d4
	bsr .add_int
	move d7,(a3)+
	move #'h=',(a3)+
	moveq #0,d0
	move max_imagey,d0
	muls d0,d4
	bsr .add_int
	move d7,(a3)+
	add.l d4,d4
	moveq #18,d0
	add.l d4,d0
	move #'b=',(a3)+
	bsr .add_int
	move d7,(a3)+
	move.l sample_num2,d4
	move #'f=',(a3)+
	move.l d4,d0
	bsr .add_int
	move d7,(a3)+
	move.l tree,a0
	btst #0,515(a0)
	beq.s .pas_avr
	move #'s=',(a3)+
	lea avr_full,a0
	bsr .add_str
	move d7,(a3)+
	bra.s .pas_t
.pas_avr:
	lea _temps(pc),a0
	tst.b (a0)
	beq.s .pas_t
	move #'t=',(a3)+
	bsr .add_str
	move d7,(a3)+
.pas_t:
	lea _key(pc),a0
	tst.b (a0)
	beq.s .pas_k
	move #'k=',(a3)+
	bsr .add_str
	move d7,(a3)+
.pas_k:
	move #'q=',(a3)+
	move.b quality_char,(a3)+
	move d7,(a3)+
	move #'m=',(a3)+
	lea _dialogue,a0
	move.l a0,d0
	move.l #ma_routine,(a0)+
	addq.l #8,a0
	move #'XE',(a0)+	; special 'EX' mode reserved for M_PLAYER
	move.w zoom_val,(a0)
	bset #7,(a0)		; marker for "show progression"
	bsr.s .add_int
	move d7,(a3)+
	lea .dat(pc),a0
	bsr.s .add_str
	subq.l #1,d4
	beq.s .terminus
	lea .aumoins2(pc),a0
	bsr.s .add_str
	move.l d4,d0
	bsr.s .add_int
	lea .fin(pc),a0
	bsr.s .add_str
.terminus:
	lea .stop(pc),a0
	bsr.s .add_str
	clr -(sp)
	pea tga_full
	GEMDOS 60,8
	move d0,d7
	bmi.s .gloub
	move.l tga_buff,a0
	add #18,a0
	move.l a0,-(sp)
	sub.l a0,a3
	move.l a3,-(sp)
	move d7,-(sp)
	GEMDOS 64,12
	tst.l d0
	bmi.s .gloub
	move d7,-(sp)
	GEMDOS 62,4
.ok:
	moveq #-1,d0
	rts
.gloub:
	moveq #0,d0
	rts
.add_int:
	lea 16(a3),a0
	clr.b (a0)
	moveq #10,d2
.lbx:
	divsl.l d2,d1:d0
	add.b #'0',d1
	move.b d1,-(a0)
	tst.l d0
	bne.s .lbx
.add_str:
	move.b (a0)+,(a3)+
	bne.s .add_str
	subq.l #1,a3
	rts

.dat: dc.b "data",13,10,"F0000000.TGA",13,10,0
.aumoins2: dc.b ".rept ",0
.fin: dc.b 13,10,".incr",13,10,".disp",13,10,".endr",13,10,0
.stop: dc.b ".stop",13,10,0
	even

_run_m_player:
	tst.b conv_flag
	bne.s .ok
	rts
.ok:
	move mov_h,-(sp)
	GEMDOS 62,4				; fclose and let the child open it again
	move #-1,mov_h
	lea _name,a0
	move.l #'M_PL',(a0)+
	move.l #'AYER',(a0)+
	move.l #'.PRG',(a0)+
	clr.b (a0)
	GEM_AES shel_find
	lea tga_full,a0
	move.l tga_buff,a1
	add #18,a1 		; command line
	lea 1(a1),a2
	move.b #"-",(a2)+
	move.l #'d+a+',(a2)+
	move #'e ',(a2)+
	tst.b conv_video
	beq.s .copy_cmd
	move.b #'+',-1(a2)
	move #'v ',(a2)+	; changer de RES Falcon dans M_Player fils
.copy_cmd:
	move.b (a0)+,(a2)+
	bne.s .copy_cmd
	subq.l #2,a2
	sub.l a1,a2
	move a2,d0
	move.b d0,(a1)		; size of command line
	move.l a7,conv1_stack
	cmp #$ffff,global+2	; multitasking?
	bne.s .monotos
;	GEM_AES appl_find
;	lea mp_buffer,a0
;	moveq #33,d0
;	move.w mp_id,d1
;	bmi.s .child_closed
;	move.w #$4d50,(a0)+
;	move.w appl_id,(a0)+
;	clr (a0)+
;	subq.l #1,a1
;	move.l a1,(a0)+
;	move.w #$504d,(a0)+
;	clr.l (a0)
;	GEM_AES appl_write
;	moveq #33,d0
;	tst intout
;	beq.s .child_closed
	
	lea sw_addrin,a0		; here run M_PLAYER with Mint
	move.l #_name,(a0)+	; addrin[0]= program name
	move.l a1,(a0)			; addrin[1]= command line
	GEM_AES shel_write
	moveq #-33,d0			; to simulate File not found
	move.w intout,d1		; if 0, M_PLAYER not found, else child ID
	beq.s .child_closed
.lb1:
	bsr.l wait_message
	cmp #90,(a0)			; CH_EXIT, child has finished?
	bne.s .lb1				; no, ignore...
	move intout,d1			; child id
	cmp 6(a0),d1			; is it my child?
	bne.s .lb1				; not my child!
;	moveq #0,d0
	move 8(a0),d0			; else exit code
	ext.l d0					; and if 0, everything is Ok.
	bra.s .child_closed
.monotos:				; run M_PLAYER with PEXEC()
	pea 0.w
	move.l a1,-(sp)	; cmd
	pea _name
	clr -(sp)			; load and go
	GEMDOS 75,16
.child_closed:
	move.l conv1_stack,a7
	tst.l d0
	bpl.s .suite
	neg.l d0
	sub #31,d0			; TOS code
	move d0,fe_int
	GEM_AES form_error
.suite:
	addq.l #4,sp		; don't do the RTS, so skip return address
	st stopped
	bra.l end_of_display	; and go to end of display.
	even

ma_routine:
	move.l a7,hote_stack
	move.l conv1_stack,a7
	move.l (a7),d0
	lea -512(a7),a7		; ben oui! pour pr‚server la pile d'appel de PEXEC
	move.l d0,-(a7)
	move.w _dialogue+12,mov_h	; handle of reopened file by the child
	rts

form_error: dc.l fe_cont,global,fe_int,dum,dum,dum
fe_cont: dc.w 53,1,1,0,0
fe_int: dc.w 0

_ritme: dc.w 0

; return >0 for next frame
; return <0 for save frame
; return 0 for quit


inc_frame:
	subq #1,_ritme			
	bmi.s .la_bonne
	moveq #1,d0
	rts						; renvoit ni EQ ni <0, sauter image
.la_bonne:
	move.l ritme,d0
	subq #1,d0
	move d0,_ritme
	tst.b conv_flag		; a conversion????
	beq.s .eq
	moveq #-1,d0
	rts
.eq:
	movem.l d0-d2/a0-a2,-(sp)
	tst.b write_error
	bne.s save_error
	tst.b switched
	beq.s .no_copy1
	move.l top_lines_buff,a0
;	move.l $44e.w,a1
	move.l physbase,a1
;
	move.l top_lines_size,d0
.cpy_lines:
	move.l (a1)+,(a0)+
	subq.l #4,d0
	bne.s .cpy_lines
.no_copy1:
	move.l tga_digit,a0
.lb0:
	move.b (a0),d0
	addq.b #1,d0
	cmp.b #'9'+1,d0
	bmi.s .good
	move.b #'0',(a0)
	subq.l #1,a0
	bra.s .lb0
.good:
	move.b d0,(a0)
save_error:					; comes back here when error (no inc frame)
	sf write_error
	tst.b switched
	beq.s .dialog1
	lea step_home,a0
	bsr print
.dialog1:
	move.l tga_file_ptr,a0
	bsr print
	btst #2,([kbshift])
	beq.s .no_stop
	sf auto_save_tga
	sf auto_run_tga
	bclr #2,([kbshift])
.no_stop:
	tst.b switched
	beq.s .dialog2
	tst.w auto_save_tga		; and auto_run_tga! (.b + .b)
	bne.s .contrl_txt
	move.l step_keys,a0		; save run etc...
	bra.s .lb1
.contrl_txt:
	lea control_text,a0
.lb1:
	bsr print
.dialog2:
	XBIOS 37,2
	XBIOS 37,2				; 2 vsync to read the line!
	tst.w auto_save_tga	; and auto_run_tga
	bne.s .no_key
	clr mf_int
	GEM_AES graf_mouse	; back to the arrow
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
.no_key:
	tst.b switched
	beq.s .no_copy2
	move.l top_lines_buff,a0
;	move.l $44e.w,a1
	move.l physbase,a1
;
	move.l top_lines_size,d1
.rst_lines:
	move.l (a0)+,(a1)+
	subq.l #4,d1
	bne.s .rst_lines
.no_copy2:
	tst.b auto_save_tga
	bne.s .mi
	tst.b auto_run_tga
	bne.s .pl
	cmp.b #27,d0
	beq.s .eq
	lea step_keys+4,a0
	or.b #$20,d0
	cmp.b (a0)+,d0		; Save ?
	beq.s .mi	
	cmp.b (a0)+,d0		; All ?
	beq.s .auto
	cmp.b (a0)+,d0		; Run ?
	beq.s .run
	cmp.b (a0)+,d0		; Quit ?
	beq.s .eq
.pl:
	moveq #1,d0			; 'next' returns>0
.quit:
	beq.s .quit2		; if0 = quit, don't change mouse
	bmi.s .quit2		; if<0, save_frame will change mouse
	move.l d0,-(sp)
	bsr.l select_mouse	; according to flags
	move.l (sp)+,d0
.quit2:
	movem.l (sp)+,d0-d2/a0-a2
	rts
.auto:
	st auto_save_tga
.mi:
	moveq #-1,d0		; 'save' returns <0
	bra.s .quit
.eq:
	moveq #0,d0			; 'quit' returns =0
	bra.s .quit
.run:
	st auto_run_tga
	bra.s .pl

; return 0 Ok
; return <0 if bug

save_frame:
	movem.l d0-d5/a0-a2,-(sp)
	moveq #0,d0
	bsr.l my_mouse			; mouse is a disk
	move.l tga_buff,a0
	move.l image,a1	; same but in memory
	move screenw,d3
	tst tga_resize
	beq.s .same_size
	movem.l d6/a3-a4,-(sp)
	bsr _resize_frame
	movem.l (sp)+,d6/a3-a4
	bra .next
.same_size:
	move 12(a0),d0
	ror #8,d0			; W
	move 14(a0),d1
	ror #8,d1			; H
	lea 16(a0),a0		; bits per pixel
	sub d0,d3
	add d3,d3			; row_inc
	subq #1,d1			; for the loop
	subq #1,d0
	cmp #$1820,(a0)+
	beq.s .24bits
	bsr _save_tga16
	bra .next
.24bits:
	tst.b is_65k
	bne.s .falcon
	tst.b nova
	beq.s .falcon
	move bit_rot,d5
	ror #4,d5			; d5.w NEG si NOVA little indian, else MAC Big Indian
.line:
	move d0,d2			; W
.pixel:
	move.w (a1)+,d4	; one pixel
	tst.w d5
	bmi.s .noswp2
	ror #8,d4
.noswp2:
	ror #5,d4
	move.b d4,d5
	and.b #$f8,d5
	move.b d5,(a0)+	; blue
	ror #5,d4
	move.b d4,d5
	and.b #$f8,d5
	move.b d5,(a0)+	; green
	ror #5,d4
	and.b #$f8,d4
	move.b d4,(a0)+	; red
	dbf d2,.pixel
	add d3,a1
	dbf d1,.line
	bra.s .next
.falcon:
	tst.b is_65k
	sne d5
	ror #8,d5			; D5.W neg if 65k (NOVA little indian), else if Falcon (big indian)
.line2:
	move d0,d2			; W
.pixel2:
	move.w (a1)+,d4	; one pixel
	tst.w d5
	bpl.s .noswp
;	swap d4
	ror #8,d4
.noswp:
	rol #3,d4
	move.b d4,d5
	and.b #$f8,d5
	move.b d5,(a0)+	; blue
	ror #6,d4
	move.b d4,d5
	and.b #$f8,d5
	move.b d5,(a0)+	; green
	ror #5,d4
	and.b #$f8,d4
	move.b d4,(a0)+	; red
	dbf d2,.pixel2
	add d3,a1
	dbf d1,.line2
.next:
	tst.b conv_flag
	bne .m_player
	clr -(sp)
	pea tga_full
	GEMDOS 60,8			; fcreate
	move.l d0,d3
	bmi.s .bug
	tst.b tgac
	beq.s .normal
	bsr _sauve_tga10
	beq.s .normal		; compression n'a pas marche!
	move.l tga10_buff,-(sp)
	bra.s .common
.normal:
	move.l tga_buff,-(sp)
	move.l tga_buff_size,d4
.common:
	move.l d4,-(sp)
	move d3,-(sp)
	GEMDOS 64,12
	move.l d0,d5		; size written
	bmi.s .bug
	move d3,-(sp)
	GEMDOS 62,4
	tst.l d0
	bmi.s .bug
	cmp.l d4,d5
	bne.s .bug
	moveq #0,d0			; 0 = Ok
	bra.s .quit
.bug:
	bsr ring_a_bell
	sf auto_save_tga	; if it was set!
	st write_error
	moveq #-1,d0
.quit:
	move.l d0,-(sp)
	bsr.l select_mouse
	move.l (sp)+,d0
	movem.l (sp)+,d0-d5/a0-a2
	rts
.m_player:
	lea _dialogue,a0
	lea .retour(pc),a1
	move.l a1,(a0)+
	addq.l #4,a0
	move.l tga_buff,a1
	add #18,a1
	move.l a1,(a0)+
	clr (a0)+			; toujours en 15 bits NOVA
	movem.l d6-d7/a3-a6,-(sp)
;	move.l stack_adr,-(sp)
;	GEMDOS 32,6			; retour en utilisateur
	move.l a7,conv_stack
	move.l hote_stack,a7
	rts
.retour:
	move.l a7,hote_stack
	move.l conv_stack,a7
;	clr.l -(sp)
;	GEMDOS 32,6
;	move.l d0,stack_adr
	movem.l (sp)+,d6-d7/a3-a6
	bra.s .quit

ring_a_bell:
	move #7,-(sp)		; bell
	move #2,-(sp)		; console
	BIOS 3,6				; rings a bell
	rts

_save_tga16:
	tst.b is_65k
	bne.s .nova65
	tst.b nova
	beq.s .falcon
	tst bit_rot
	bne.s .line			; NOVA
.line4:					; else MAC big endian
	move d0,d2			; W
.pixel4:
	move.w (a1)+,d4
	ror #8,d4
	move d4,(a0)+
	dbf d2,.pixel4
	add d3,a1
	dbf d1,.line4
	rts
.line:
	move d0,d2			; W
.pixel:
	move.w (a1)+,(a0)+
	dbf d2,.pixel
	add d3,a1
	dbf d1,.line
	rts
.falcon:
.line2:
	move d0,d2			; W
.pixel2:
	move.w (a1)+,d4	; one pixel
	NOVA16 d4
	ror #8,d4
	move d4,(a0)+	; red
	dbf d2,.pixel2
	add d3,a1
	dbf d1,.line2
	rts
.nova65:
.line3:
	move d0,d2			; W
.pixel3:
	move.w (a1)+,d4	; one pixel
	ror #8,d4
	NOVA16 d4
	ror #8,d4
	move d4,(a0)+	; red
	dbf d2,.pixel3
	add d3,a1
	dbf d1,.line3
	rts

_resize_frame:
	lea 18(a0),a0	; start of data
	lea tga_srcx,a2
	move.l (a2)+,d6	; scrx/srcy
	move.l (a2),d2		; destx/desty
	moveq #0,d5			; sx/sy
	move d2,d4			; for the loop
	add d3,d3
	subq #1,d4
	swap d6
	swap d2
	lea reduc_x(pc),a2
	cmp d2,d6
	bpl.s .lb0
	lea augm_x(pc),a2
.lb0:
	swap d6
	swap d2
	cmp d2,d6
	bpl.s reduc_y
	; ici augm y
	; bra.s .loop
.lb3:
	move.l a0,a3
	jsr (a2)
	add d3,a1
	bra.s .lb2
.lb4:
	add d6,d5
	cmp d2,d5
	bmi.s .lb5
	sub d2,d5
	bra.s .lb3
.lb5:
	move.l a0,d0
	sub.l a3,d0
	lsr d0
	bra.s .lb1
.copy_ligne:
	move (a3)+,(a0)+
.lb1:
	dbf d0,.copy_ligne
.lb2:
	dbf d4,.lb4
	bra.s finalize_resize

reduc_y:
	bra.s .lb3
.lb1:
	add d2,d5
	add d3,a1
	cmp d6,d5
	bmi.s .lb1
	sub d6,d5
.lb3:
	jsr (a2)
.lb2:
	dbf d4,.lb1
	bra.s finalize_resize

reduc_x:
	swap d6
	swap d2
	swap d5
	swap d4
	move d2,d4
	clr d5
	subq #1,d4
	move.l a1,a4
	bra.s .lb3
.lb1:
	add d2,d5
	addq.l #2,a4
	cmp d6,d5
	bmi.s .lb1
	sub d6,d5
.lb3:
	move (a4),(a0)+
.lb2:
	dbf d4,.lb1
retour_ligne:
	swap d4
	swap d5
	swap d6
	swap d2
	rts

augm_x:
	swap d4
	swap d6
	swap d2
	swap d5
	move d2,d4
	clr d5
	subq #1,d4
	move.l a1,a4
.lb3:
	move (a4)+,d0
	bra.s .lb5
.lb4:
	add d6,d5
	cmp d2,d5
	bmi.s .lb5
	sub d2,d5
	bra.s .lb3
.lb5:
	move d0,(a0)+
	dbf d4,.lb4
	bra.s retour_ligne

	; if TGA16 transform 16bits or 15bits motorola to 15bits Intel
	; if TGA24 the same to BVR
finalize_resize:
	move.l tga_buff,a1
	lea 16(a1),a1
	sub.l a1,a0
	move.l a0,d0			; nombre d'octets
	lsr.l d0					; nombre de WORD
	cmp #$1820,(a1)+		; tga24??
	beq.s .tga24
	tst.b nova
	bne.s .mode1
	; ici FALCON
.lb0:
	move (a1),d1
	NOVA16 d1
	ror #8,d1
	move d1,(a1)+
	subq.l #1,d0
	bne.s .lb0
	rts
.mode1:
	tst.b is_65k
	beq.s .mode2
	; ici 16bits Intel
.lb1:
	move (a1),d1
	ror #8,d1
	NOVA16 d1
	ror #8,d1
	move d1,(a1)+
	subq.l #1,d0
	bne.s .lb1
	rts
.mode2:
	tst bit_rot
	bne.s .mode3
	; ici 15bits motorola
.lb2:
	move (a1),d1
	ror #8,d1
	move d1,(a1)+
	subq.l #1,d0
	bne.s .lb2
	rts
.mode3:
	; ici NOVA 15 bits
	rts
.tga24:
	lea 0(a1,d0.l*2),a1	; end of WORD
	lea 0(a1,d0.l),a0		; end of BVR
	move #$f8,d4
	moveq #8,d2
	tst.b nova
	beq.s .mode16_24
	moveq #0,d2
	tst.b is_65k
	bne.s .mode16_24
	; ici 15 bits qu'on fait tourner de 9 ou 1
	moveq #9,d2
	sub bit_rot,d2
.mode15_24:
	move -(a1),d1
	rol d2,d1
	move d1,d3
	and.b d4,d1
	rol #5,d3
	move.b d1,-(a0)		; R
	move d3,d1
	and.b d4,d3
	rol #5,d1
	move.b d3,-(a0)		; V
	and.b d4,d1
	move.b d1,-(a0)		; B
	subq.l #1,d0
	bne.s .mode15_24
	rts
	; ici 16 bits qu'on fait tourner de 8 ou 0
.mode16_24:
	move -(a1),d1
	ror d2,d1
	move d1,d3
	and.b d4,d1
	rol #5,d3
	move.b d1,-(a0)		; R
	move d3,d1
	and.b #$FC,d3
	rol #6,d1
	move.b d3,-(a0)		; V
	and.b d4,d1
	move.b d1,-(a0)		; B
	subq.l #1,d0
	bne.s .mode16_24
	rts

_sauve_tga10:
	move.l tga_buff,a0
	move.l tga10_buff,a1
	move (a0)+,(a1)+
	move (a0)+,d0
	move.b #10,(a1)+
	move.b d0,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move (a0)+,d0
	move d0,(a1)+			; X
	ror #8,d0
	move (a0)+,d4
	move d4,(a1)+
	ror #8,d4				; Y
	muls d0,d4				; nombre de pixels
	move (a0)+,d0
	move d0,(a1)+
	cmp #$1820,d0
	beq.s _tga10_24			; 24 bits!
	move.l d4,d5			; compte les pixels lus dans buff
	add.l d4,d4				; compte les octets utilisables dans buff2
	subq.l #1,d4
	move (a0)+,d0			; valeur courante
	subq.l #1,d5
.fin_egal:
	move.l a1,a2
	sf (a1)+					; nouveau code = 0
	subq.l #1,d4
	bmi.s .comp_inefficace
.autre:
	move d0,(a1)+			; qu'on range
	subq.l #2,d4
	bmi.s .comp_inefficace
	subq.l #1,d5
	bmi.s .fin
	move (a0)+,d1			; pixel suppl‚mentaire
	cmp d1,d0
	beq.s .egal
	move d1,d0
	addq.b #1,(a2)
	bpl.s .autre			; si >0, moins de 128
	subq.b #1,(a2)			; retour a $00 + 127
	bra.s .fin_egal
.egal:
	tst.b (a2)
	beq.s .good
	subq.l #2,a1
	subq.b #1,(a2)
	move.l a1,a2
	sf (a1)+
	move d1,(a1)+
	subq.l #1,d4			; #1 car A1-2 puis +1 +2
	bmi.s .comp_inefficace
.good:
	move.b #$81,(a2)
.encore:
	subq.l #1,d5
	bmi.s .fin
	move (a0)+,d0
	cmp d1,d0
	bne.s .fin_egal
	addq.b #1,(a2)
	bmi.s .encore			; si toujours<0, moins de 128
	st (a2)					; retour a $80 + 127
	bra.s .fin_egal		; le 129eme ne commence pas forcement un bloc repeat
.comp_inefficace:
	moveq #0,d4
	rts
.fin:
	move.l a1,d4
	sub.l tga10_buff,d4	; taille a sauver
	rts
_tga10_24:
	move.l d4,d5			; compte les pixels lus dans buff
	add.l d4,d4
	add.l d5,d4				; compte les octets utilisables dans buff2
	subq.l #1,d4
	move.l #$FFFFFF00,d2
	move.l (a0),d0			; valeur courante
	and.l d2,d0
	addq.l #3,a0
	subq.l #1,d5
.fin_egal:
	move.l a1,a2
	sf (a1)+					; nouveau code = 0
	subq.l #1,d4
	bmi.s .comp_inefficace
.autre:
	move.l d0,(a1)			; qu'on range
	addq.l #3,a1
	subq.l #3,d4
	bmi.s .comp_inefficace
	subq.l #1,d5
	bmi.s .fin
	move.l (a0),d1			; pixel suppl‚mentaire
	addq.l #3,a0
	and.l d2,d1
	cmp.l d1,d0
	beq.s .egal
	move.l d1,d0
	addq.b #1,(a2)
	bpl.s .autre			; si >0, moins de 128
	subq.b #1,(a2)			; retour a $00 + 127
	bra.s .fin_egal
.egal:
	tst.b (a2)
	beq.s .good
	subq.l #3,a1
	subq.b #1,(a2)
	move.l a1,a2
	sf (a1)+
	move.l d1,(a1)
	addq.l #3,a1
	subq.l #1,d4			; #1 car A1-3 puis +1 +3
	bmi.s .comp_inefficace
.good:
	move.b #$81,(a2)
.encore:
	subq.l #1,d5
	bmi.s .fin
	move.l (a0),d0
	addq.l #3,a0
	and.l d2,d0
	cmp.l d1,d0
	bne.s .fin_egal
	addq.b #1,(a2)
	bmi.s .encore			; si toujours<0, moins de 128
	st (a2)					; retour a $80 + 127
	bra.s .fin_egal		; le 129eme ne commence pas forcement un bloc repeat
.comp_inefficace:
	moveq #0,d4
	rts
.fin:
	move.l a1,d4
	sub.l tga10_buff,d4	; taille a sauver
	rts

; print_ptr is the relative screen pointer)
; a0 contains the string to display (nul terminated)

print:
	tst.b switched				; res change on a Falcon?
	bne.s .my_print			; yes, don't use system routines
;	move.l a0,-(sp)			; else, normal print
;	GEMDOS 9,6
	movem.l d2-d7/a2-a6,-(sp)
	move.l tree_filename,a1
	move.l a0,(a1)
;	moveq #0,d5
;	tst.b first_step_dialog
;	bne.s .not_first
;	moveq #1,d5		; repeat twice for first time (Aranym/Mint/Xaes)
;.not_first:
	lea _dialog_table,a3
	move.l 4*LAST_TREE(a3),a3
	moveq #0,d6	; redessiner depuis objet 0
	moveq #0,d0
	bsr.l wdial_change
	moveq #1,d7		; just draw
	moveq #LAST_TREE,d6
	bsr manage_tree
;	dbf d5,.not_first
;	st first_step_dialog
	movem.l (sp)+,d2-d7/a2-a6
	rts
.my_print:
	cmp.l #step_home,a0		; is it just 'Home'
	bne.s .lb0
	clr.l print_ptr			; yes, so clear our pointer
	rts
.lb0:
	move.l print_ptr,a1		; else, write into video Ram
	add.l $44e.w,a1
	move screenw,d2
	subq #8,d2
	add d2,d2
.loop:
	move.b (a0)+,d0
	beq.s .end
	ext.w d0
	bmi.s .loop				; more than 127, not supported char
	sub.w #32,d0
	bmi.s .loop				; under 32, not supported
	lea (fonte,pc,d0.w*8),a2	; the datas for this char
	moveq #7,d0
	move.l a1,-(sp)
.line:
	swap d0
	move #7,d0
	move.b (a2)+,d1
.pix:
	spl (a1)+
	spl (a1)+
	subq #1,d0
	bmi.s .lb1
	lsl.b #1,d1
	bra.s .pix
.lb1:
	add d2,a1
	swap d0
	dbf d0,.line
	move.l (sp)+,a1
	lea 16(a1),a1
	bra.s .loop
.end:
	sub.l $44e.w,a1
	move.l a1,print_ptr
	rts

fonte: INCBIN "FONTE.BIN"

slide_read_header:
	or.l d7,d1
	cmp.l #'eani',d1
	beq.s .ok
.error:
	moveq #1,d0
	rts
.ok:
	move.l total,d1
	add.l #1024,d1		; 256 loops!!!
	bsr malloc
	move.l d0,a5
	move.l d0,slide_zone
	lea 1024(a5),a5	; start of file and end of stack
	move.l a5,slide_ptr
	move.l a5,slide_stack
	move.l a5,-(sp)
	move.l total,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12		; read the whole bat
	move mov_h,-(sp)
	GEMDOS 62,4			; close
	st slide_flag		; a slide of anim
	lea slide_save_flags,a1
	move command,(a1)+
	st command
	lea cmd_dial,a0
	move.l (a0),(a1)+
	move.l #$00FFFF00,(a0)+
	move.l (a0),(a1)+
	clr.l (a0)+
	bsr.l winup_on

slide_next_file:
	move.l slide_ptr,a5
	move.l slide_stack,a6
.loop:
	bsr bat_next_line
	cmp.b #'.',d0			; a command?
	beq.s .comm
	bsr slide_new_file
	bra .display
.comm:
	addq.l #1,a5
	move.l (a5)+,d0
	or.l #$20202020,d0	; to lower
	cmp.l #'disp',d0
	beq.s .display
	cmp.l #'rept',d0
	bne.s .c0
	addq.l #1,a5
	bsr get_number
	move.l a5,-(a6)		; return address
	move.l d0,-(a6)		; how many loops
	bra.s .loop
.c0:
	cmp.l #'endr',d0
	bne.s .c2
	subq.l #1,(a6)
	beq.s .lb0				; end of loop
	move.l 4(a6),a5		; else goes back
	bra.s .loop
.lb0:
	addq.l #8,a6
	bra.s .loop
.c2:
	cmp.l #'incr',d0
	bne.s .c3
	move.l slide_digit,a0
.lb1:
	move.b (a0),d0
	addq.b #1,d0
	cmp.b #'9'+1,d0
	bmi.s .good
	move.b #'0',(a0)
	subq.l #1,a0
	bra.s .lb1
.good:
	move.b d0,(a0)
	bra.s .loop
.c3:
	cmp.l #'decr',d0
	bne.s .c4
	move.l slide_digit,a0
.lb2:
	move.b (a0),d0
	subq.b #1,d0
	cmp.b #'0',d0
	bpl.s .good
	move.b #'9',(a0)
	subq.l #1,a0
	bra.s .lb2
.c4:
	cmp.l #'stop',d0
	beq.s .exit
	bra.s .exit				; unknown command!
.display:
	move.l a6,slide_stack
	move.l a5,slide_ptr
	bra.l verify
.exit:
	sf slide_flag
	lea slide_save_flags,a1
	move (a1)+,command
	lea cmd_dial,a0
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l slide_zone,a2
	bsr mfree
	bsr.l winup_off
	bra.l end_of_display

bat_read_header:
	sf create_mov
	sf create_avi
	sf slide_gif
	sf qt_palette		; if 8 planes (RLE8 encoding)
	sf is_vidi			; source is VST file (FF) and not Ximg(0)
	clr.l _delay
	move #1,bat_gif_loop
	move #5,quality	; default!
	clr key_rate		; default no key frame
	move.l #$20202020,d7
	moveq #0,d6				; bit map of every option found
	cmp.b #2,menu_flag	; is it from Capture Screen ??
	beq.s .capture
	cmp.b #1,menu_flag	; is it from "Create" from easybat panel?
	bne.s .load_file		; no, load file
	lea ebat_path_names+5*6,a5	; memory bat!
	move.l end_time,a1
	bra.s .dum_comm
.capture:
	lea memory_bat,a5		; else create a file in RAM
	move.l a5,a1
	lea .memory(pc),a0
.dum_file:
	move.b (a0)+,(a1)+
	bne.s .dum_file
.dum_comm:
	sub.l a5,a1			; size
	move.l a1,total
	st create_mov
	clr.l bat_text		; no bloc allocation
	bra .parse_header
.load_file:
	SEEK #0,0			; start of file
	bsr read_id_len
	or.l d7,d0
	cmp.l #'mpl',d0	; lower for 'M_PL'
	beq.s .half_ok
	cmp.l #'slid',d0
	beq slide_read_header
.error:
	moveq #-1,d0
	rts
.half_ok:
	or.l d7,d1
	cmp.l #'ayer',d1
	bne.s .error
	move.l #12480,d1
	bsr malloc
	move.l d0,a5
	move.l d0,bat_text
	move.l a5,-(sp)
	move.l total,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12		; read the whole bat
	move.l d0,total
	bmi.s .error
	clr.b (a5,d0.l)		; end of file marked with a 0
	move mov_h,-(sp)
	GEMDOS 62,4			; close
.parse_header:
	bsr bat_next_line
	cmp.l #'DIAL',(a5)
	bne.s .command
.skip_easybat:
	bsr bat_next_line
	cmp.l #'ENDD',(a5)
	beq.s .parse_header
	bra.s .skip_easybat
.command:
	or.b d7,d0			; to lower
	cmp.b #'=',1(a5)
	bne .end_head
	addq.l #2,a5			; skips X= (X beeing w,h,r,f,c,o,v)
	cmp.b #'w',d0
	bne.s .h0
	cmp.b #'?',(a5)		; w=? for screen captures
	bne.s .normal
	st is_grab
;	bsr.l get_rectangle
	cmp #16,planes_vdi
	bpl.s .to_tga
	move.l #'ximg',-(a5)
	bra.s .common
.to_tga:
	move.l #'tga2',-(a5)
.common:
	move.l #$0d0a633D,-(a5)	; CR+LF+"c="
	bra.s .parse_header
.normal:
	bsr get_number
	move d0,max_imagex
	bset #0,d6
	bra.s .parse_header
.h0:
	cmp.b #'h',d0
	bne.s .h1
	bsr get_number
	move d0,max_imagey
	bset #1,d6
	bra.s .parse_header
.h1:
	cmp.b #'f',d0
	bne.s .h2
	bsr get_number
	move.l d0,sample_num
	bset #16,d6
	bra .parse_header
.h2:
	cmp.b #'t',d0			; if "t=val", then same delay for replay and grab
	bne.s .h3
	bsr get_number
	move.l d0,_delay
	move.l d0,grab_delay
	bset #17,d6
	cmp.b #',',(a5)		; if t=val1,val2	then replay = val1, grab=val2 for "Auto capture"
	bne .parse_header
	addq.l #1,a5
	bsr get_number
	move.l d0,grab_delay	
	bra .parse_header
.h3:
	cmp.b #'b',d0
	bne.s .h4
	bsr get_number
	move.l d0,max_fsize
	bset #2,d6
	bra .parse_header
.h4:
	cmp.b #'o',d0
	bne.s .h5
	st create_mov
	cmp.b #'+',(a5)		; avi with MSVC
	bne.s .h4b
	addq.l #1,a5
	move.b #1,create_avi	; >0 pour MSVC
	bra.s .h4a
.h4b:
	cmp.b #'#',(a5)		; avi file?
	bne.s .h4a
	addq.l #1,a5			; skips '#'
	st create_avi			; <0 pour (w)RLE
.h4a:
	lea out_file,a0
	bsr get_name
	bset #18,d6
	bra .parse_header
.h5:
	cmp.b #'s',d0
	bne.s .h6
	lea sound_file,a0
	bsr get_name
	bsr read_sound_header
	bset #17,d6
	bra .parse_header
.h6:
	cmp.b #'q',d0
	bne.s .h7
	bsr get_number
	move d0,quality		; 1 … 5, et -1 … -5 pour TGA en MSVC 256 gris
	bra .parse_header
.h7:
	cmp.b #'k',d0
	bne.s .h8
	bsr get_number
	move d0,key_rate
	bra .parse_header
.h8:
	cmp.b #'r',d0
	bne.s .h9
	bsr get_number
	move d0,bat_gif_loop
	bra .parse_header
.h9:
	cmp.b #'v',d0
	bne.s .h10
	bsr treat_vr_infos
	bra .parse_header
.h10:
	cmp.b #'m',d0
	bne.s .h11
	bsr get_number
	move.l d0,vanel_adr
	move.l d0,a0
	st mountain			; $FF for creation with no progression box
	add.w #12,a0
	move (a0)+,d0
	cmp #"EX",d0		; standard extension
	beq.s .zoom		
	cmp #"XE",d0		; reserved for M_PLAYER conversions
	bne.s .pas_zoom
	st open_parent_file
.zoom:
	moveq #0,d0
	bclr #7,(a0)		; test and reset "Show progression" flag
	beq.s .no_progress
	bclr #0,mountain	; $FE for creation with progression box
.no_progress:
	cmp #$0101,(a0)
	beq.s .trouve
	moveq #1,d0
	cmp #$0201,(a0)
	beq.s .trouve
	moveq #-1,d0
	cmp #$0102,(a0)
	beq.s .trouve
	bra.s .pas_zoom
.trouve:
	move.b d0,conv_zoom
.pas_zoom:
	bra .parse_header
.h11:
	cmp.b #'c',d0
	bne .error
	move planes,planes_sav
	tst.b res_switch
	beq.s .c3
	move #16,planes
.c3:
	move.l (a5)+,d0		; compression (4 char)
	or.l d7,d0
	move.l d0,comp_txt
	move.l #'ximg',d1
	cmp.l d1,d0
	beq.s .c4a
	cmp.l #'vst8',d0
	bne.s .c4
	st is_vidi
	move.l d1,comp_txt	;change VST8 en XIMG
.c4a:
	move.l #bat_ximg_256,d0
	move.l d0,comp_create
	st qt_palette
	tst.b is_tt
	bne .c1
	cmp #8,planes
	beq .c1
	move.l #bat_ximg,d0
	bra .c1
.c4:
	cmp.l #'tga2',d0
	bne.s .c5
	move.l #bat_tga,comp_create
	move.l #bat_tga_256,d0
	tst.b is_tt
	bne .c1
	cmp #8,planes
	beq .c1
	move.l #bat_tga,d0
	tst.b nova
	bne .c1
	move.l #bat_tga_falc,d0
	bra .c1
.c5:
	cmp.l #'tgac',d0
	bne.s .c5c
	st tgac
	move.b #'2',d0
	move.l d0,comp_txt
	bra.s .c4
.c5c:
	move.l #'dega',d1
	cmp.l #'vst4',d0
	bne.s .c5d
	move.l d1,comp_txt		; VST4 -> Degas
	move.b #1,is_vidi			; mais avec flag is_vidi=1
	bra.s .c5e
.c5d:
	cmp.l d1,d0
	bne.s .c6
.c5e:
	moveq #34,d0
.c5b:
	move.l d0,neo_degas_offs
	move.l #bat_degas,d0
	move.l d0,comp_create
	st slide_degas
	or.b #$7,d6			; w, h, b
	move.l #33000,max_fsize
	move #320,max_imagex
	move #200,max_imagey
	bra.s .c1
.c6:
	cmp.l #'neoc',d0
	bne.s .c7
	move.l #128,d0
	bra.s .c5b
.c7:
	cmp.l #'gif8',d0
	bne.s .c0
	move.l #bat_gif,d0
	st slide_gif
.c1:
	move.l d0,compression
	bra.s .c2
.c0:
	st bad_comp
.c2:
	bset #3,d6
	move planes_sav,planes
	bra .parse_header
.end_head:
	tst.b is_grab
	beq.s .not_grab
	bsr.l get_rectangle
	bsr bat_default_data
.not_grab:	
	tst.b is_vidi
	beq.s .not_vidi
	bsr read_vidi_data
.not_vidi:
	move max_imagex,d0
	move max_imagey,d1
	move d0,conv_x
	move d1,conv_y
	moveq #-18,d2
	add.l max_fsize,d2
	tst.b conv_zoom
	beq.s .no_zoom
	bmi.s .reduc
	add d0,d0
	add d1,d1
	add.l d2,d2
	add.l d2,d2		; 4 fois plus de points
	bra.s .commun
.reduc:
	lsr #1,d0
	lsr #1,d1
	lsr.l #2,d2		; 4 fois moins de points
.commun:
	move d0,max_imagex
	move d1,max_imagey
	moveq #18,d1
	add.l d2,d1
	move.l d1,max_fsize
.no_zoom:
	cmp.l #bat_tga,comp_create
	bne.s .lb0
	move max_imagex,d0
	addq #3,d0
	and.b #$FC,d0
	move d0,max_imagex
.lb0:
	cmp.l #bat_ximg_256,comp_create
	bne.s .lb1
	tst.b mountain
	beq.s .lb00				; BAT normal, garder buffer
	tst.b conv_zoom
	bne.s .lb00				; avec ZOOM garder buffer TGA
	move.l #256,max_fsize	; sinon, buffer DUMMY
.lb00:
	move max_imagex,d0
	move d0,_vanel_line
	move d0,d1
	addq #7,d1
	and.b #$F8,d1
	move d1,max_imagex
	sub d0,d1
	move d1,_vanel_plus
.lb1:
	move quality,d0
	smi tga_vers_gris
	bpl.s .q_pos
	neg d0
.q_pos:
	cmp #5,d0
	bmi.s .q_ok
	moveq #5,d0
.q_ok:
	cmp #1,d0
	bpl.s .q_ok2
	moveq #1,d0
.q_ok2:
	lea qual(pc),a0
	tst.b create_avi
	ble.s .q_ok3
	lea 10(a0),a0	; deuxiŠme s‚rie si MSVC
.q_ok3:
	move d0,qual_sav
	move -2(a0,d0.w*2),quality
	move.l (a5)+,d0
	or.l d7,d0
	cmp.l #'data',d0
	bne .error
	move.l a5,bat_ptr
	cmp #$f,d6
	beq.s .ok
	moveq #35,d0				; alert not enough info for standard BAT
	bra ooops
.ok:
	tst.b create_avi
	bgt.s .detourne			; si AVI et MSVC (>0), d‚compresse en 24 bits
	tst.b create_mov
	beq.s .ok2
	tst.b slide_gif
	beq.s .ok3
	bclr #7,create_mov		; positive for a GIF
	bra.s .ok3
.detourne:
	lea bat_tga_msvc,a0
	tst.b qt_palette
	beq.s .det1
	lea bat_ximg_msvc,a0
	move max_imagex,d0
	muls max_imagey,d0
	move.l d0,tgac_offset	; pour la zone non compress‚e
.det1:
	move.l a0,comp_create
.ok3:
	swap d6
	cmp #$7,d6
	beq.s .ok2
	moveq #36,d0				; alert not enough info for create movie
	bra ooops
.ok2:
	bsr verify_vr_infos
 	st samp_sizes
	tst tgac						; compression?
	beq.s .no_comp
	move max_imagex,d0
	muls max_imagey,d0
	move.l d0,d1
	add.l d0,d1
	add.l d0,d1					; *3
	moveq #18,d0
	add.l d0,d1					; + header
	move.l d1,tgac_offset
.no_comp:
	move.b tga_vers_gris,d0
	or.b d0,qt_palette				; si vers gris, une palette!
	moveq #0,d0
	rts
.memory: dc.b ";DUM",13,10,"w=?",13,10,0
	even
qual: dc.w $4210,$6318,$739c,$7bde,$7fff
	;		dc.w 346,146,43,5,0	; q^3/10000*16 (q=0 bon, q=60 mauvais)
	dc.w 819,346,102,13,0


treat_vr_infos:
	lea vr_y,a0
	bsr _number
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,6(a0)		; largeur X
	bsr.s _number
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,(a0)		; hauteur Y
	bsr.s _number
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,10(a0)		; start X
	bsr.s _number
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,4(a0)		; start Y
	bsr.s _number
	cmp.b #','-'0',d1
	bne.s .erreur
	move d0,-4(a0)		; img/cell
	bsr.s _number
	move d0,8(a0)
	subq.l #1,a5		; back on CR/LF
	st create_vr
	rts
.erreur:
	moveq #5,d0			; 6 values needed for V=
	bra ooops

; IN -> A5 ascii number
; OUT -> D0.l = number

_number:
	moveq #0,d0
	moveq #0,d1
.lb0:
	move.b (a5)+,d1
	sub.b #'0',d1
	bmi.s .lb1
	muls #10,d0
	add.l d1,d0
	bra.s .lb0
.lb1:
	rts

verify_vr_infos:
	tst.b create_vr
	beq.s .fin			; Ok, no VR wanted
	moveq #6,d0			; alert total frames don't match vr infos
	lea vr_y,a1
	move (a1),d3
	move 6(a1),d1
	move -4(a1),d2
	muls d1,d2
	muls d3,d2			; total of images
	cmp.l sample_num,d2
	bne ooops			; go on with alert string #6
	moveq #7,d0			; alert 1st cell out of range
	subq #1,d3
	cmp 4(a1),d3
	bmi ooops			; alert #7
	subq #1,d1
	cmp 10(a1),d1
	bmi ooops			; alert #7
	moveq #0,d3
	move -4(a1),d3		; img_cell
	move key_rate,d1
	beq.s .warn
	divs d1,d3
	swap d3
	tst d3
	beq.s .fin			; no reminder, cool!
.warn:
	moveq #8,d0			; warning to use keyf because k= don't match the img/cell
	bsr alert
.fin:
	rts

; uses a0,d0
; updates a5

get_name:
	moveq #0,d0
.copy:
	move.b (a5)+,d0
	cmp #$21,d0
	bmi.s .end
	move.b d0,(a0)+
	bra.s .copy
.end:
	clr.b (a0)
	subq.l #1,a5
	rts

; uses d0
; updates a5
; if end_of_file reached, remains on chr(0)
; return d0 first char of new line of 0

bat_next_line:
	moveq #0,d0
.lb0:
	move.b (a5)+,d0		; looks for the end of a line
	beq.s .lb2				; end of file!
	cmp.b #13,d0
	beq.s .lb1
	cmp.b #10,d0
	bne.s .lb0
.lb1:
	move.b (a5)+,d0		; skips every CR,LF,space or tabulation
	beq.s .lb2				; end of file
	cmp.b #33,d0
	bmi.s .lb1
.lb2:
	move.b -(a5),d0		; back to the first char
	cmp.b #';',d0			; a comment?
	beq.s .lb0				; yes! another line!
	tst.b d0					; return EQ if end of file !
	rts

read_vidi_data:
	lea tga_full,a0
	bsr.s get_name			; nom du fichier VIDI
	clr -(sp)
	pea tga_full
	GEMDOS 61,8
	move d0,mov_h		;handle
	bmi.s .erreur
	bsr.l vst_read_header
	bmi.s .erreur
	or.l #$30007,d6		;marque donn‚es obtenues (T,F,B,H,W)
.erreur:
	bsr.s bat_default_data
	rts

bat_default_data:
	lea .mini_bat(pc),a5
	lea 19(a5),a1			; pointe sur le 00000
	move.l sample_num,d0
	bsr int_to_str			; met sample num dans .rept
	moveq #32,d0
.pad:
	move.b d0,(a1)+		; efface les z‚ros inutiles avec des espaces
	cmp.b (a1),d0
	bls.s .pad
	rts
.mini_bat: dc.b "data",13,10
	dc.b ".getp",13,10
	dc.b ".rept 000000",13,10
	dc.b ".disp",13,10
	dc.b ".endr",13,10
	dc.b ".stop",13,10,0

	even

read_sound_header:
	clr -(sp)
	pea sound_file
	GEMDOS 61,8
	move.l d0,d3
	bmi .end
	move #2,-(sp)		; from the end
	move d3,-(sp)
	clr.l -(sp)
	GEMDOS $42,10
	move.l d0,snd_size	; total size of the file
	clr -(sp)			; from the start
	move d3,-(sp)
	clr.l -(sp)
	GEMDOS $42,10
	pea cvid_fix0
	move.l #36,-(sp)	; enough for WAV or AVR header
	move d3,-(sp)
	GEMDOS 63,12
	move d3,-(sp)
	move.l d0,d3
	GEMDOS 62,4
	tst.l d0
	bmi .end
	cmp.l #36,d3
	bne .end
	lea cvid_fix0,a0
	cmp.l #'2BIT',(a0)
	bne .not_avr
	sf little_indian				; not an Intel format
	move.l #128,sound_seek
	sf bad_sound
	move #1,channels
	tst 12(a0)
	beq.s .lb0
	move #2,channels
.lb0:
	move 14(a0),sound_bits
.lb1:
	move.l #'twos',s_signe
	tst 16(a0)
	bne.s .lb2
	move.l #'raw ',s_signe
.lb2:
	move.l 22(a0),frequency
	clr.b frequency
.treat_size:
	move.l snd_size,d0	; total size
	sub.l sound_seek,d0	; minus the header size
	and.b #$FC,d0			; 4 aligned(for 16b/stereo), need an even value
	move.l d0,d1
	lsr.l #7,d0
	lsr.l #8,d0		; number of blocs of 32768 bytes
	bne.s .ok
	moveq #1,d0		; at least one bloc
.ok:
	move.l d0,bloc_num
	divs.l d0,d1		; size of one bloc
	and.b #$FC,d1		; for 16bits stereo
	move.l d1,last_size
	muls.l d0,d1		; total size
	move.l d1,snd_size
	subq.l #1,d0
	lsl.l #4,d0			; 16 octets par bloc suppl‚mentaire!
	move.l d0,size_added
	moveq #-1,d0		; return -1 if OK
	rts
.end:
	moveq #0,d0			; return 0 if read error
	rts
.end2:
	moveq #1,d0			; return 1 if format error
	rts
.not_avr:
	cmp.l #'RIFF',(a0)
	bne.s .end2
	sf bad_sound
	move.l #44,sound_seek
	move 22(a0),d0
	ror #8,d0
	move d0,channels
	move.l 24(a0),d0
	INTEL d0
	move.l d0,frequency
	move 34(a0),d0
	ror #8,d0
	move d0,sound_bits
	cmp #16,d0
	seq little_indian			; true if Intel 16 bits
	beq.s .rawa_16
	move.l #'raw ',s_signe	; 8 bits are unsigned
	bra .treat_size
.rawa_16:
	move.l #'twos',s_signe	; 16 bits are signed...
	bra .treat_size


decomp_tga10:
	movem.l d0-d5/a0-a2,-(sp)
	move.l buffer,a2
	move.l a2,a0
	add.l tgac_offset,a2
	cmp.b #10,2(a2)			; c'est du 10?
	bne .pas_comp
	move.b #2,2(a2)			; tga 10 en tga 2
	move.l a2,a1
	move 14(a2),d5				; max_imagey
	ror #8,d5
	move 12(a2),d4				; max_imagex
	ror #8,d4
	muls d5,d4
	move.b 16(a2),d1
	moveq #0,d0
	move.b (a2),d0
	lea 18(a2,d0.w),a2
.copy_head:
	move.b (a1)+,(a0)+
	cmp.l a2,a1
	bmi.s .copy_head
	cmp.b #24,d1
	bne.s .other_bits
.boukl:
	moveq #0,d0
	move.b (a2)+,d0
	bmi.s .pak
	sub.l d0,d4
.norm:
	move.b (a2)+,(a0)+
	move.b (a2)+,(a0)+
	move.b (a2)+,(a0)+
	dbf d0,.norm
.test:
	subq.l #1,d4
	bgt.s .boukl
	movem.l (sp)+,d0-d5/a0-a2
	rts
.pak:
	move.l (a2),d1
	addq.l #3,a2
	bclr #7,d0
	sub.l d0,d4
.pak2:
	move.l d1,(a0)
	addq.l #3,a0
	dbf d0,.pak2
	bra.s .test
.other_bits:
	moveq #0,d0
	move.b (a2)+,d0
	bmi.s .pak16
	sub.l d0,d4
.norm16:
	move (a2)+,(a0)+
	dbf d0,.norm16
.test16:
	subq.l #1,d4
	bgt.s .other_bits
	movem.l (sp)+,d0-d5/a0-a2
	rts
.pak16:
	move (a2)+,d1
	bclr #7,d0
	sub.l d0,d4
.pak216:
	move d1,(a0)+
	dbf d0,.pak216
	bra.s .test16
.pas_comp:
	move.l max_fsize,d0
.cpypk:
	move.l (a2)+,(a0)+
	subq.l #4,d0
	bpl.s .cpypk
	movem.l (sp)+,d0-d5/a0-a2
	rts

bat_read_data:
	tst.b bad_comp
	beq.s .ok
	rts
.ok:
	bsr.l install_traps
	trap #10
	move.l d0,start_time
	move.l d0,current_time
;	bra.s .no_mountain
.no_time:
;	GEM_VDI hide_mouse
.no_mountain:
	move.l bat_ptr,a5		; bat pointer
	lea cvid_fix1,a6		; stack pointer for loops
	clr.l disp_frame
	sf bat_getp
.loop:
	btst #2,([kbshift])
	bne .exit
	bsr bat_next_line
	cmp.b #'.',d0			; a command?
	beq.s .comm
	bsr bat_new_file
	bra .display
.comm:
	addq.l #1,a5
	move.l (a5)+,d0
	or.l #$20202020,d0	; to lower
	cmp.l #'disp',d0
	beq .display
	cmp.l #'rept',d0
	bne.s .c0
	addq.l #1,a5
	bsr get_number
	move.l a5,-(a6)		; return address
	move.l d0,-(a6)		; how many loops
	bra.s .loop
.c0:
	cmp.l #'endr',d0
	bne.s .c2
	subq.l #1,(a6)
	beq.s .lb0				; end of loop
	move.l 4(a6),a5		; else goes back
	bra.s .loop
.lb0:
	addq.l #8,a6
	bra.s .loop
.c2:
	cmp.l #'incr',d0
	bne.s .c3
	bsr increment_name
	bra.s .loop
.c3:
	cmp.l #'decr',d0
	bne.s .c4
	bsr decrement_name
	bra.s .loop
.c4:
	cmp.l #'getp',d0
	bne.s .c5
	st bat_getp		; next frame will change the palette
	bra .loop
.c5:
	cmp.l #'keyf',d0
	bne.s .c6
	st key_frame	; next frame is a key one!
	bra .loop
.c6:
	cmp.l #'stop',d0
	beq .exit
	move.b #$0F,stopped	; unknown command, stop but not with control
	move.l d0,([alert_ptr+48])	; bad command in string alert 41
	bra .exit
.display:
	tst.b mountain
	beq.s .normal
	bsr .mountain_image
	bra.s .common
.normal:
	tst.b is_vidi
	beq.s .load_file
	bsr vst_load_bloc
	bra.s .common
.load_file:
	tst.b is_grab			; screen copy mode?
	beq.s .from_file
	bsr.l screen_to_image
	bra.s .common
.from_file:
	clr -(sp)
	pea tga_full
	GEMDOS 61,8				; fopen
	move.l d0,d6			; handle
	bmi .loop
	move.l buffer,d0
	add.l tgac_offset,d0
	move.l d0,-(sp)
	move.l max_fsize,-(sp)
	move d6,-(sp)
	GEMDOS 63,12			; fread
	move.l d0,d5
	move d6,-(sp)
	GEMDOS 62,4				; fclose
	tst.l d5
	bmi .loop
	beq .loop
	tst.b tgac
	beq.s .common
	bsr decomp_tga10
.common:
	addq.l #1,disp_frame
;	tst.b mountain
;	bne.s .no_time2
	move.l current_time,d1
.delay:
	trap #10
	cmp.l d0,d1
	bpl.s .delay
	add.l _delay,d1
	move.l d1,current_time
	move.l d0,_update_time
	move.l compression,a0
	movem.l a5-a6,-(sp)
	jsr (a0)
	tst.b create_mov
	bne.s .no_vdi
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	movem.l (sp)+,a5-a6
	sf bat_getp
	sf key_frame
;
	bra .loop
.exit_stop:
	st stopped
.exit:
	trap #10
	move.l d0,end_time
	tst.b mountain
	bne.s .no_super3
	bsr.l remove_traps
	rts
.no_super3:
	tst.b open_parent_file
	beq.s .out
	move parent_source_handle,-(sp)
	GEMDOS 62,4				; close the parent source file
.out:
	bsr.l remove_traps
	tst.b stopped
	bpl.s .out2				; 00 = ok
	bmi.s .out2				; FF = stopped
	moveq #41,d0			; else 0F = error, alert bad command
	bsr alert
	st stopped
.out2:
	rts

; vanel_adr: LONG ROUT sa routine
;				LONG FRM le numero d'image que je demande
;				LONG BUFF l'adress ou il a ses pixels WORDS
;				WORD FLAG $FFFF si 16 bits Falcon, $0000 si 15 bits NOVA

; lors du premier ‚change
; BUFF contenait l'adresse du nom du fichier
; et on renvoit FLAG=handle

.mountain_image:
	move.l a7,conv_stack
	move.l vanel_adr,a2
	move.l (a2)+,a3			; routine
	move.l disp_frame,(a2)+	; image needed
	bne.s .open					; not the first one
	tst.b open_parent_file	; call with XE extension?
	beq.s .open
	clr -(sp)					; else open source file
	move.l (a2)+,-(sp)
	GEMDOS 61,8					; open source file
	move d0,(a2)				; and send handle to parent
	move d0,parent_source_handle
;	move.l stack_adr,-(sp)
;	GEMDOS 32,6
.open:
	movem.l a5-a6,-(sp)
	jsr (a3)
	movem.l (sp)+,a5-a6
;	clr.l -(sp)
;	GEMDOS 32,6
;	move.l d0,stack_adr
	move.l conv_stack,a7
	cmp.l #'tga2',comp_txt
	beq.s .true_color
	tst.b conv_zoom			; y a t-il du zoom?
	bne.s .true_color			; ben oui!!!
	rts							; sinon, rien! (dithering after!!!)
.true_color:
	move.l vanel_adr,a0
	move.l buffer,a1			; mon buffer
	move.l #$00000200,(a1)+
	clr.l (a1)+
	clr.l (a1)+
	move max_imagex,d0
	ror #8,d0
	move d0,(a1)+
	move max_imagey,d1
	ror #8,d1
	move d1,(a1)+
	move #$1020,(a1)+
	ror #8,d0
	ror #8,d1
	move.l 8(a0),a2			; ses pixels
	tst.b conv_zoom
	bne.s _zoom_2
	muls d0,d1					; nombre de pixels
	move 12(a0),d0				; flag
	beq.s .copy_nova
	cmp #$FFFF,d0
	beq.s .copy_falc
	rts							; mauvais flag, on s'en fout
.copy_nova:
	move.w (a2)+,(a1)+
	subq.l #1,d1
	bne.s .copy_nova
	rts
.copy_falc:
	move (a2)+,d0
	NOVA16 d0
	ror #8,d0
	move d0,(a1)+
	subq.l #1,d1
	bne.s .copy_falc
	rts

increment_name:
	move.l tga_digit,a0
.lb1:
	move.b (a0),d0
	addq.b #1,d0
	cmp.b #'9'+1,d0
	bmi.s .good
	move.b #'0',(a0)
	subq.l #1,a0
	bra.s .lb1
.good:
	move.b d0,(a0)
	rts

decrement_name:
	move.l tga_digit,a0
.lb2:
	move.b (a0),d0
	subq.b #1,d0
	cmp.b #'0',d0
	bpl.s .good
	move.b #'9',(a0)
	subq.l #1,a0
	bra.s .lb2
.good:
	move.b d0,(a0)
	rts

_zoom_2:
	cmp.l #'tga2',comp_txt
	beq.s .true_color
	sub.w #18,a1				; pas de header pour du 256 couleurs
	move.l a1,8(a0)			; ses pixels deviennent les miens!
.true_color:
	tst.b conv_zoom
	bmi.s _zoom_reduc
	move d0,d2
	add d2,d2
	move d1,d3
	lsr d3						; 2 lignes trait‚es a la fois
	move 12(a0),d0				; flag
	beq.s .copy_nova
	cmp #$FFFF,d0
	beq.s .copy_falc
	rts							; mauvais flag, on s'en fout
.copy_nova:
	bra.s .boucle
.ligne:
	move.w (a2)+,d0
	move d0,0(a1,d2)
	move d0,(a1)+
	move d0,0(a1,d2)
	move d0,(a1)+
	dbf d1,.ligne
	add d2,a1
.boucle:
	move d2,d1
	lsr #2,d1
	subq #1,d1
	dbf d3,.ligne
	rts
.copy_falc:
	bra.s .fboucle
.fligne:
	move.w (a2)+,d0
	NOVA16 d0
	ror #8,d0
	move d0,0(a1,d2)
	move d0,(a1)+
	move d0,0(a1,d2)
	move d0,(a1)+
	dbf d1,.fligne
	add d2,a1
.fboucle:
	move d2,d1
	lsr #2,d1
	subq #1,d1
	dbf d3,.fligne
	rts

_zoom_reduc:
	move conv_x,d2
	addq #1,d2
	bclr #0,d2
	add d2,d2
	move d1,d3
	move 12(a0),d0				; flag
	beq.s .copy_nova
	cmp #$FFFF,d0
	beq.s .copy_falc
	rts							; mauvais flag, on s'en fout
.copy_nova:
	bra.s .boucle
.ligne:
	move.w (a2)+,(a1)+
	addq.l #2,a2
	dbf d1,.ligne
	add d2,a2
.boucle:
	move max_imagex,d1
	subq #1,d1
	dbf d3,.ligne
	rts
.copy_falc:
	bra.s .fboucle
.fligne:
	move.w (a2)+,d0
	NOVA16 d0
	ror #8,d0
	move d0,(a1)+
	addq.l #2,a2
	dbf d1,.fligne
	add d2,a2
.fboucle:
	move max_imagex,d1
	subq #1,d1
	dbf d3,.fligne
	rts

slide_new_file:
	lea full,a0
	lea full2,a2
	move.l a2,a3
	move.l a0,a1
.lb0:
	move.b (a5)+,d0
	move.b d0,(a0)+
	move.b d0,(a2)+
	cmp.b #'\',d0
	bne.s .lb1
	move.l a0,a1
	move.l a2,a3
.lb1:
	cmp.b #33,d0
	bpl.s .lb0			; another!
	move.l a3,fname_pos	; in case of mask
	subq.l #1,a5
	clr.b -(a0)
.lb2:
	move.b (a1)+,d0
	beq.s .lb3			; the end!
	cmp.b #'.',d0
	bne.s .lb2
.lb3:
	subq.l #2,a1
	move.l a1,slide_digit
	rts

bat_new_file:
	lea tga_full,a0
	move.l a0,a1
.lb0:
	move.b (a5)+,d0
	move.b d0,(a0)+
	cmp.b #'\',d0
	bne.s .lb1
	move.l a0,a1
.lb1:
	cmp.b #33,d0
	bpl.s .lb0			; another!
	subq.l #1,a5
	clr.b -(a0)
.lb2:
	move.b (a1)+,d0
	beq.s .lb3			; the end!
	cmp.b #'.',d0
	bne.s .lb2
.lb3:
	subq.l #2,a1
	move.l a1,tga_digit
	rts

; uses d0,d1
; updates a5
get_number:
	moveq #0,d0				; the number
	moveq #0,d1
	cmp.b #"-",(a5)+
	beq.s .lb1
	subq.l #1,a5
.lb0:
	move.b (a5)+,d1
	sub.b #'0',d1
	bmi.s .end
	cmp.b #'9'+1,d1
	bpl.s .end
	muls.l #10,d0
	add.l d1,d0
	bra.s .lb0
.lb1:
	move.b (a5)+,d1
	sub.b #'0',d1
	bmi.s .end
	cmp.b #'9'+1,d1
	bpl.s .end
	muls.l #10,d0
	sub.l d1,d0
	bra.s .lb1
.end:
	subq.l #1,a5
	rts

vst_load_bloc:
	bgt.s .degas			; si is_vidi>0, du degas vers FLM
	bsr.l init_ximg_header	; effac‚ … chaque fois par improve_rle
	move.l a0,-(sp)		; a0 deja a la bonne adresse avec BSR pr‚c‚dent
	move.l max_fsize,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	rts
.degas:
	bsr.l init_degas_header
	move.l a0,-(sp)
	move.l max_fsize,d0
	cmp.l #9600,d0			; est-ce du 160x120?
	beq.s .petit
	move.l #3200,d1		; premier d‚calage
	tst.l disp_frame
	beq.s .ok
	add.l d1,d1
.ok:
	SEEK d1,1				; avance dans le fichier(ne prend que 200 lignes/240)
	move.l #32000,-(sp)	; a0 d‚j… sur la pile pour l'adresse
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	rts
.petit:
	lea 22400(a0),a1
	move.l a1,-(sp)
	move.l a1,-(sp)
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; fread
	move.l (sp)+,a1
	move.l (sp)+,a0
	moveq #0,d1
	move #401,d0
.efface_debut:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d0,.efface_debut
	move.l d1,(a0)+
	move.l d1,(a0)+	; 6440 octets effac‚s
	moveq #119,d0
.copy_image:
	moveq #4,d2
.ligne:
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+	; une ligne de 80 octets = 160 points
	dbf d2,.ligne
	moveq #4,d2
.saute_ligne:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d2,.saute_ligne	; efface les 160 autres.
	dbf d0,.copy_image
	moveq #0,d2
	move #396,d0
.efface_fin:
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	move.l d1,(a0)+
	dbf d0,.efface_fin
	move.l d1,(a0)+
	move.l d1,(a0)
	rts

init_square_table:
	movem.l d0-d2/a0,-(sp)
	lea Rdbfr,a0
	move #-255,d0
	move #510,d2
.lb0:
	move d0,d1
	muls d1,d1
	addq #1,d0
	move.l d1,(a0)+
	dbf d2,.lb0
	movem.l (sp)+,d0-d2/a0
	rts
init_create_avi:
	move.l _freq_sav,frequency
	seq bad_sound			; if 0, no sound
	move max_imagex,d0
	addq #7,d0
	and.b #$F8,d0			; 8 aligned
	move d0,max_imagex
	move max_imagey,d1
	move d0,d3
	muls d1,d3				; size of one image in pixels
	lea avi_header,a0
	tst.b create_avi
	bmi.s .en_rle
	move.l #'MSVC',112(a0)			; msvc
	move.l #'CRAM',188(a0)			; msvc
	bsr.s init_square_table
	bra.s .suite
.en_rle:
	move.l #'RLE ',112(a0)			; rle
	move.l #$01000000,188(a0)		; rle
.suite:
	move.l d3,d4						; pour rle16_buffer
	tst.b qt_palette
	bne.s .en_8_bits
	move.w #$1000,186(a0)			; en 16 bits
	clr.l 204(a0)						; 0 couleur dans palette
	add.l d4,d4							; taille image 16 bits
	moveq #0,d2
	add.l d4,d3							; 3*le nombre de pixels = en RGB
	bra.s .suite2
.en_8_bits:
	moveq #4,d2
	move.w #$0800,186(a0)			; 8 bits
	move.l #$00010000,204(a0)		; 256 couleurs dans palette
.suite2:
	move.b d2,93(a0)
	move.b d2,169(a0)					; taille chunk avec ou sans palette.
	ror #8,d0
	move d0,176(a0)
	move d0,64(a0)
	ror #8,d0
	ror #8,d1
	move d1,180(a0)
	move d1,68(a0)
	ror #8,d1
	INTEL d4
	move.l d4,192(a0)					; taille 16 bits (2*w*h) ou 8 bits (w*h)
	INTEL d4
	move.l sample_num,d2
	INTEL d2
	move.l d2,140(a0)
	move.l d2,48(a0)
	move.l d3,d1
	bsr malloc
	move.l d0,one_buffer
	move.l d3,d1
	bsr malloc
	move.l d0,two_buffer
	move.l d4,d1
	asr.l d4
	add.l d4,d1				; 1.5*image with bad rle compression!
	move.l last_size,d3
	addq.l #8,d3
	cmp.l d3,d1		; enough for one sound?
	bpl.s .enough
	move.l d3,d1	; no, so new size
.enough:
	bsr malloc
	move.l d0,rle16_buffer
	move.l sample_num,d1
	tst.b bad_sound
	bne.s .nos1
	add.l bloc_num,d1		; plus the blocs for sound
.nos1:
	asl.l #4,d1				; 16 bytes for each
	moveq #0,d4				; supposes there is no palette
	tst.b qt_palette
	beq.s .no_pal
	move #1024,d4			; else, palete size
.no_pal:
	add.l d4,d1
	addq.l #8,d1			;  plus the palette + idx1 + size
	bsr malloc
	move.l d0,header_buffer
	move.l d0,a0
	add.l d4,a0				; palette
	move.l #'idx1',(a0)+
	clr.l (a0)+
	move.l a0,size_ptr
	bsr fill_palette		; if in grey mode, palette is known
	clr -(sp)
	pea out_file
	GEMDOS 60,8
	tst.l d0
	bgt.s _end
	moveq #37,d0		; alert can't create file
	bra ooops

;wind_update: dc.l wu_cont,global,wu_int,dum,dum,dum
;wu_cont: dc.w 107,1,1,0,0

_end:
	move d0,mov_h2
	lea avi_header,a0
	move.l _delay,d1
	muls #5000,d1		; number of microsecond per frame
	INTEL d1
	move.l d1,32(a0)
	move.l d1,128(a0)
	pea (a0)
	move.l #avi_end_header-avi_header,d1
	add.l d4,d1
	add.l #12,d1		; plus the palette + LIST size 'movi'
	tst.b bad_sound
	bne.s .nos2
	add.l #100,d1			; plus the sound header
.nos2:
	move.l d1,-(sp)
	move d0,-(sp)
	GEMDOS 64,12	; write
	tst.b bad_sound
	bne .no_sound
	btst #0,mountain
	bne.s .pas_aff
	move.l bloc_num,d0
	bsr init_loading_sound
.pas_aff:
	clr -(sp)
	pea sound_file
	GEMDOS 61,8
	move.l d0,d3
	clr -(sp)
	move d3,-(sp)
	move.l sound_seek,-(sp)
	GEMDOS 66,10		; skips header!
	move.l rle16_buffer,a3
	move.l bloc_num,d4	; number of blocs
	move.l size_ptr,a4	; idx1 section
.loop_sound:
	move.l last_size,d6		; one bloc
	move.l #'01wb',(a3)
	move.l (a3),(a4)+		; id
	clr.l (a4)+				; flags
	clr.l (a4)+				; offsets later
	subq.l #1,d4
	INTEL d6
	move.l d6,(a4)+		; size
	move.l d6,4(a3)		; size
	INTEL d6
	pea 8(a3)
	move.l d6,-(sp)
	move d3,-(sp)
	GEMDOS 63,12		; fread
	bsr treat_avi_sound
	addq.l #8,d6		; +01wb + size
	move.l a3,-(sp)
	move.l d6,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite
	btst #0,mountain
	bne.s .pas_aff2
	move.l _reference,d0
	sub.l d4,d0
	bsr update_loading_sound
.pas_aff2:
	tst.l d4
	bne.s .loop_sound
	move d3,-(sp)
	GEMDOS 62,4
	move.l a4,size_ptr
.exit:
	lea avi_sound_header,a0
	moveq #1,d4
	move.l snd_size,d3
	move.b channels+1,d0
	cmp.b d4,d0
	beq.s .mono
	add d4,d4
	asr.l d3
.mono:
	move.b d0,86(a0)
	move.b sound_bits+1,d0
	cmp.b #8,d0
	beq.s .eight
	add d4,d4
	asr.l d3
.eight:
	move.b d0,98(a0)
	move.l last_size,d0
	INTEL d0
	move.l d0,56(a0)
	move.b d4,40(a0)
	move.b d4,64(a0)
	move.b d4,96(a0)
	move.l frequency,d0
	INTEL d0
	move.l d0,88(a0)
	INTEL d0
	mulu d4,d0			; freq * scale
	INTEL d0
	move.l d0,44(a0)
	move.l d0,92(a0)
	INTEL d0
	muls.l sample_num,d0
	move.l snd_size,d1
	muls.l #1000000,d2:d1
	divs.l d0,d2:d1	; d1= micro seconds per frame
	INTEL d3
	move.l d3,52(a0)
	lea avi_header,a0
	INTEL d1
	move.l d1,32(a0)
	move.l d1,128(a0)
	btst #0,mountain
	bne.s .pas_aff3
	moveq #-1,d7
	moveq #1,d6
	bsr manage_tree
.no_sound:
	btst #0,mountain
	bne.s .pas_aff3
	lea avi_header,a0
	move.l 112(a0),d1
	move.b 186(a0),d2
	move.l #'AVI ',d3
	bsr init_create_box
.pas_aff3:
	rts

vq_color: dc.l vq_cont,vq_int,dum,intout,dum
vq_cont: dc.w 26,0,0,2,0,0,0,0,0,0,0,0
vq_int: dc.w 0,1

treat_avi_sound:
	lea 8(a3),a0		; data pointer
	move.l d6,d0		; size in bytes
	cmp #8,sound_bits
	beq _eight
	asr.l d0
	subq.l #1,d0		; prepared for dbf
	move #$8000,d2		; to unsign raw 16 bits
	cmp.l #'twos',s_signe
	bne.s _raw_16
	tst.b little_indian	; here signed 16 bits
	bne.s .end				; Intel format, so Ok
.to_intel:
	move (a0),d1
	ror #8,d1
	move d1,(a0)+
	dbf d0,.to_intel
.end:
	rts

alert_box: dc.l ab_cont,global,ab_int,intout,ab_addrin,dum
ab_cont: dc.w 52,1,1,1,0
ab_int: dc.w 1
ab_addrin: dc.l 0

_raw_16:
	move (a0),d1
	add d2,d1
	ror #8,d1
	move d1,(a0)+
	dbf d0,_raw_16
	rts

evnt_timer: dc.l et_cont,global,et_int,dum,dum,dum
et_cont: dc.w 24,2,1,0,0
et_int: dc.w 250,0			; 1/4 sec

_eight:
	subq.l #1,d0			; prepared for dbf
	cmp.l #'raw ',s_signe
	beq.s .end				; raw 8 bits, nothing to change
	moveq #-128,d2
.sign_8:
	add.b d2,(a0)+
	dbf d0,.sign_8
.end:
	rts

init_create:
	tst.b slide_gif
	bne init_create_gif
	tst.b create_avi
	bne init_create_avi
	tst.b slide_degas
	bne init_create_degas
	bsr mac_date			; fills the dates with the MAC format
	move max_imagex,d0
	addq #3,d0
	and.b #$Fc,d0			; 4 bits aligned
	move max_imagey,d1
	move d0,d3
	muls d1,d3
	move.l d3,d4
	add.l d4,d4				; size for one 'screen'
	asl.l #1,d3
	add.l d4,d3
	ext.l d1
	add.l d1,d3
	add.l d1,d3
	add.l #14,d3			; max size for a frame (coded with RLE16)
	tst.b qt_palette
	beq.s .true_col
	asr.l #1,d3
	asr.l #1,d4				; for 8 planes, half the size!
.true_col:
	move.l d3,d1
	move.l d3,snd_temp_size	; if sound is to be loaded...
	bsr malloc
	move.l d0,rle16_buffer
	move.l d4,d1
	bsr malloc
	move.l d0,one_buffer
	move.l d4,d1
	bsr malloc
	move.l d0,two_buffer
	move.l _freq_sav,frequency
	beq.s .no_sound
	bsr size_into_samples
	move.l d0,d4
	muls.l #1000,d0:d4
	divs.l frequency,d0:d4
	divs.l sample_num,d4	; number of millisec per frame
	sf bad_sound
	bra.s .next
.no_sound:
	st bad_sound
	move.l _delay,d4		; time for one sample
	muls.l #5,d4			; in 1/1000
.next:
	move.l d4,d5
	move.l d4,_delay
	lea mov_header,a3
	move.l sample_num,d1
	muls.l d1,d5			; total time
	asl.l #2,d1				; each size is 4 bytes long
	move.l d1,d6			; variable size
	add.l (a3),d1			; size of header
	tst.b bad_sound
	bne.s .lb2
	add.l sound_header,d1	; plus the sound header length
	add.l size_added,d1		; plus extra size (if >1 bloc of sound)
.lb2:
	tst.b qt_palette
	beq.s .no_pal
	add.l #2056,d1			; for the palette
	add.l #2056,d6
.no_pal:
	move.l d1,header_size
	bsr malloc
	move.l d0,header_buffer
	move.l d0,a0			; fills the header!
	move.l header_size,(a0)+
	addq.l #4,a3			; 'moov' size
	moveq #6,d0
	bsr copy_longs
	move.l d5,(a0)+		; total time (mvhd)
	moveq #18,d0
	bsr copy_longs
	move.l (a3)+,d0		; next track is 2
	tst.b bad_sound
	bne.s .lb0
	addq.l #1,d0			; if sound, it is 3!
.lb0:
	move.l d0,(a0)+
	bsr make_size			; 'trak'
	moveq #7,d0
	bsr copy_longs
	move.l d5,(a0)+		; total time (tkhd)
	move (a3)+,(a0)+
	moveq #11,d0
	bsr copy_longs
	bsr copy_xy
	move (a3)+,(a0)+
	moveq #5,d0
	bsr copy_longs
	move.l d5,(a0)+		; total time (elst)
	moveq #1,d0
	bsr copy_longs
	bsr make_size			; 'mdia'
	moveq #6,d0
	bsr copy_longs
	move.l d5,(a0)+		; 'mdhd'
	moveq #14,d0
	bsr copy_longs
	bsr make_size			; 'minf'
	moveq #28,d0
	bsr copy_longs
	bsr make_size			; 'stbl'
	move.l (a3)+,(a0)+
	tst.b qt_palette
	beq.s .no_pal2
	move.l #2056,d0
	sub.l d0,d6
	move.l (a3)+,d1
	add.l d0,d1
	move.l d1,(a0)+		; new stsd size
	move.l (a3)+,(a0)+
	move.l (a3)+,(a0)+
	move.l (a3)+,(a0)+
	add.l (a3)+,d0
	move.l d0,(a0)+		; new video codec size
	bra.s .cont
.no_pal2:
	moveq #4,d0
	bsr copy_longs			; if no palette, just copies
.cont:
	moveq #6,d0
	bsr copy_longs
	move max_imagex,(a0)+
	move max_imagey,(a0)+
	move (a3)+,(a0)+
	moveq #11,d0
	bsr copy_longs
	tst.b qt_palette
	beq.s .no_pal3
	moveq #8,d1
	swap d1					; 8 planes, flag=0000
	move.l d1,-4(a0)		; overwrites 16 planes and flag=FFFF
	move.l a0,mov_pal
	lea 2056(a0),a0		; jumps over the palette
.no_pal3:
	moveq #3,d0
	bsr copy_longs
	move.l sample_num,(a0)+
	move.l _delay,(a0)+
	moveq #4,d0
	bsr copy_longs
	move.l sample_num,(a0)+
	move.l (a3)+,(a0)+
	bsr make_size			; 'stsz'
	moveq #2,d0
	bsr copy_longs
	move.l sample_num,(a0)+
	move.l a0,size_ptr
	add.l d6,a0
	moveq #3,d0
	bsr copy_longs
	move.l (a3)+,d0
	add.l snd_size,d0
	move.l d0,(a0)+		; offset of images (8 + size of sound)
	tst.b bad_sound
	bne .lb1
	lea sound_header,a3
	move.l size_added,d6	; if >1 bloc of sound
	bsr make_size			; trak
	moveq #7,d0
	bsr copy_longs			; tkhd
	move.l d5,(a0)+
	moveq #20,d0
	bsr copy_longs
	move.l d5,(a0)+
	move.l (a3)+,(a0)+
	move.l (a3)+,(a0)+
	bsr make_size			; 'mdia'
	moveq #5,d0
	bsr copy_longs
	move.l frequency,(a0)+
	bsr size_into_samples
	move.l d0,(a0)+
	moveq #14,d0
	bsr copy_longs
	move (a3)+,(a0)+
	bsr make_size			; minf
	moveq #27,d0
	bsr copy_longs
	move (a3)+,(a0)+
	bsr make_size			; stbl
	moveq #5,d0
	bsr copy_longs
	move.l s_signe,(a0)+
	moveq #3,d0
	bsr copy_longs
	move channels,(a0)+
	move sound_bits,(a0)+
	move.l (a3)+,(a0)+
	move.w frequency+2,(a0)+
	clr (a0)+
	moveq #3,d0
	bsr copy_longs
	bsr size_into_samples
	move.l d0,(a0)+
	move.l (a3)+,(a0)+
	move.l bloc_num,d1
	move.l d1,d0
	muls #12,d0			; taille chunks
	add.l #16,d0		; taille stsc
	move.l d0,(a0)+
	move.l (a3)+,(a0)+
	move.l (a3)+,(a0)+
	move.l d1,(a0)+
	moveq #0,d2
	move.l last_size,d0
	bsr _size_into_samples
	bra.s .stsc2
.stsc:
	move.l d2,(a0)+
	move.l d0,(a0)+
	move.l #1,(a0)+
.stsc2:
	addq.l #1,d2
	cmp.l d2,d1
	bpl.s .stsc
	moveq #3,d0
	bsr copy_longs		; zone stsz
	bsr size_into_samples
	move.l d0,(a0)+
	move.l d1,d0		; bloc num
	lsl.l #2,d0			; 4 octets par offset
	add.l #16,d0
	move.l d0,(a0)+	; taille stco
	move.l (a3)+,(a0)+
	move.l (a3)+,(a0)+
	move.l d1,(a0)+
	moveq #8,d0
	move.l last_size,d2
	bra.s .stco2
.stco:
	move.l d0,(a0)+
	add.l d2,d0
.stco2:
	dbf d1,.stco
.lb1:
	lea udta_header,a3
	bsr fill_navg_data
	moveq #19,d0
	bsr copy_longs
	clr -(sp)
	pea out_file
	GEMDOS 60,8
	tst.l d0
	bgt.s .end
	moveq #37,d0		; alert can't create file
	bra ooops
.end:
	move d0,mov_h2
	pea dum
	move.l #8,-(sp)
	move d0,-(sp)
	GEMDOS 64,12	; writes 8 dummy bytes (size + mdat)
	tst.b bad_sound
	bne .exit
	btst #0,mountain
	bne.s .pas_aff1
	move.l snd_size,d0
	bsr init_loading_sound
.pas_aff1:
	clr -(sp)
	pea sound_file
	GEMDOS 61,8
	move.l d0,d3
	clr -(sp)
	move d3,-(sp)
	move.l sound_seek,-(sp)
	GEMDOS 66,10		; skips header!
	move.l snd_temp_size,d6
	and.b #$F0,d6		; rounded
	move.l rle16_buffer,a3
	move.l snd_size,d4
.loop_sound:
	cmp.l d6,d4
	bpl.s .lb3
	move.l d4,d6
.lb3:
	sub.l d6,d4
	move.l a3,-(sp)
	move.l d6,-(sp)
	move d3,-(sp)
	GEMDOS 63,12		; fread
	btst #0,mountain
	bne.s .pas_aff2
	move.l snd_size,d0
	sub.l d4,d0
	bsr update_loading_sound
.pas_aff2:
	tst.b little_indian
	beq.s .lb4
	move.l a3,a0
	move.l d6,d1
	subq.l #1,d1
.lb5:
	move (a0),d0
	ror #8,d0
	move d0,(a0)+
	subq.l #2,d1
	bpl.s .lb5
.lb4:
	move.l a3,-(sp)
	move.l d6,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite
	tst.l d4
	bne.s .loop_sound
	move d3,-(sp)
	GEMDOS 62,4
	btst #0,mountain
	bne.s .exit
	moveq #1,d6
	moveq #-1,d7
	bsr manage_tree
.exit:
	btst #0,mountain
	bne.s .pas_aff3
	move.l #'RLE ',d1
	moveq #8,d2
	tst.b qt_palette
	bne.s .8bits
	addq.l #8,d2
.8bits:
	move.l #'MOV ',d3
	bsr init_create_box
.pas_aff3:
	rts


init_create_gif:
	sf smc_a
	clr -(sp)
	pea out_file
	GEMDOS 60,8
	tst.l d0
	bgt.s .end
	moveq #37,d0		; alert can't create file
	bra ooops
.end:
	move d0,mov_h2		; keeps the handle!
	move.l _delay,d0
	addq.l #1,d0
	lsr.l #1,d0
	swap d0
	tst d0
	beq.s .ok_time
	moveq #0,d0
.ok_time:
	swap d0
	ror #8,d0
	move d0,delay_gif
	move.l #'LZW ',d1
	moveq #8,d2
	move.l #"GIF ",d3
	bsr init_create_box
	rts

fill_navg_data:
	tst.b create_vr
	bne.s .lb0
	move.l #'skip',12(a3)
	rts
.lb0:
	move.l #'NAVG',12(a3)
	lea vr_y,a1
	move -4(a1),24(a3)	; img/cell
	move.l _delay,d1
	move d1,26(a3)			; time
	move 6(a1),d1
	move d1,18(a3)
	clr.l 38(a3)
	clr.l 42(a3)
	clr.l 50(a3)
	cmp #1,d1
	beq.s .lb2
	move #180,d0
	tst.w 8(a1)		; loop_x
	beq.s .lb1
	add d0,d0
.lb1:
	move d0,40(a3)
	muls 10(a1),d0
	add.l #67,d0
	divs d1,d0
	move.l d0,d1
	swap d1
	tst d1
	beq.s .no_reste
	addq #1,d0
.no_reste:
	move d0,52(a3)
.lb2:
	move (a1),d1
	move d1,20(a3)
	clr.l 46(a3)
	clr.l 54(a3)
	clr.l 42(a3)
	cmp #1,d1
	beq.s .lb3
	moveq #90,d0
	move d0,48(a3)
	move d1,d2
	sub 4(a1),d2
	subq #1,d2
	muls d2,d0
	add.l #22,d0
	divs d1,d0
	move.l d0,d1
	swap d1
	tst d1
	beq.s .no_reste2
	addq #1,d0
.no_reste2:
	move d0,56(a3)
.lb3:
	rts

size_into_samples:
	move.l snd_size,d0
_size_into_samples:
	cmp #16,sound_bits
	bne.s .lb0
	asr.l #1,d0
.lb0:
	cmp #2,channels
	bne.s .lb1
	asr.l #1,d0
.lb1:
	rts


copy_longs:
	move.l (a3)+,(a0)+
	dbf d0,copy_longs
	rts
make_size:
	move.l (a3)+,d0
	add.l d6,d0
	move.l d0,(a0)+
	rts
copy_xy:
	clr (a0)+
	move max_imagex,(a0)+
	clr (a0)+
	move max_imagey,(a0)+
	rts

_comp:
	move.l comp_create,a0
	jsr (a0)
	bsr.s compress_rle
	rts

compress_rle:
	addq #1,key_count
	bsr update_create_box
	move.l one_buffer,a1		; new frame
	move.l two_buffer,a2		; old one
	move.l a1,a3				; flags
	move.l rle16_buffer,a0
	tst.b create_avi
	bne compress_wrle
	addq.l #4,a0
	move #$0008,(a0)+			; a header present
	clr.l (a0)+
	move max_imagey,(a0)+
	clr (a0)+
	tst.b qt_palette
	beq.s .rle16
	bsr compress_rle8
	bsr improve_rle8
	bra .end
.rle16:
	move max_imagex,d5
	muls max_imagey,d5		; total size (in pixels)
	move quality,d4			; mask
	tst.b key_frame
	beq.s .z1					; no key forced
.glup:
	clr key_count
	bra.s .new
.z1:
	cmp.l #1,disp_frame		; first frame?
	beq.s .glup					; yes, like a key frame
	move key_count,d0
	cmp key_rate,d0
	bne.s .other				; not a key frame
.new:
	move (a1)+,d0
	ror #8,d0
	move d0,(a2)+				; copies every pixel
	st (a3)+						; all are new!
	subq.l #1,d5
	bne.s .new
	bra.s .next
.other:
	move (a1)+,d0
	ror #8,d0
	move d0,d1
	and d4,d1					; color with its quality reduced
	move (a2),d2
	and d4,d2					; its quality too
	cmp d1,d2
	beq.s .o1
	st (a3)+
	move d0,(a2)+
	bra.s .o2
.o1:
	sf (a3)+
	addq.l #2,a2
.o2:
	subq.l #1,d5
	bne.s .other
.next:
	move max_imagey,d7		; loop accross the lines!
	subq #1,d7
	move.l one_buffer,a1
	move.l two_buffer,a2
	move max_imagex,d4
.line:
	move.l a1,a3				; flags
	move.l a2,a4				; colors
	move.l a3,d3				; for size of run
	move d4,d2
	subq #1,d2					; loop through one line
.start:
	tst.b (a3)+					; pixels to skip at the beginning
	bne.s .lb0
	addq.l #2,a4
	dbf d2,.start
	move.b #$01,(a0)+			; all to skip, empty line!
	bra.s .end_of_line
.lb0:
	subq.l #1,a3
	move.l a3,d0
	sub.l d3,d0					; number of pixels to skip
.lb1:
	cmp #255,d0
	bmi.s .lb2
	st (a0)+
	sf (a0)+
	sub #254,d0
	bra.s .lb1
.lb2:
	addq #1,d0
	move.b d0,(a0)+
.lb4:
	move.l a3,d3				; new pos
	move.l a0,a5				; saves
	sf (a0)+						; the code byte
.run:
	tst.b (a3)+
	beq.s .lb5
	addq.b #1,(a5)				; the code byte
	bmi.s .lb3
	move (a4)+,(a0)+			; one pixel more
	dbf d2,.run
	bra.s .end_of_line
.lb3:
	subq.l #1,a3
	move.b #$7f,(a5)
	bra.s .lb4
.lb5:
	subq.l #1,a3
	move.l a3,d3
	sf (a0)+
	bra.s .start
.end_of_line:
	st (a0)+						; code $FF
	add d4,a1
	add d4,a2
	add d4,a2
	dbf d7,.line
	bsr improve_rle16
.end:
	move.l a0,d0
	move.l rle16_buffer,a0
	sub.l a0,d0	; codec size
	tst.w 4(a0)				; flag 0008 present?
	bne.s .normalframe
	moveq #6,d0				; else, a NOP frame, save 6 bytes (len+flag word)
.normalframe:
	move.l size_ptr,a1
	tst.b key_frame		; a key frame wanted?
	bne.s .key
	cmp.l #1,disp_frame	; first frame?
	beq.s .key				; yes! a key frame
	move key_count,d1		; else, auto key frame?
	cmp key_rate,d1
	bne.s .no_key			; no!
	clr key_count			; yes, reset counter
.key:
	bset #31,d0				; mark it as a key frame
	addq #1,key_frame_num
.no_key:
	move.l d0,(a1)+		; list of sizes
	move.l a1,size_ptr
	bclr #31,d0				; eventually set...
	move.l d0,(a0)
	bset #6,(a0)
	move.l a0,-(sp)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; fwrite
	rts

compress_rle8:
	move screenw,d5
	muls max_imagey,d5		; total size (in pixels)
	tst.b key_frame
	beq.s .z1
.gloube:
	clr key_count
	bra.s .new
.z1
	cmp.l #1,disp_frame		; first frame?
	beq.s .gloube
	move key_count,d0
	cmp key_rate,d0
	bne.s .other
.new:
	move.l (a1)+,(a2)+		; 4 at a time
	st (a3)+						; all are new!
	subq.l #4,d5
	bne.s .new
	bra.s .next
.other:
	move.l (a1)+,d0
	cmp.l (a2),d0
	sne (a3)+					; FF if 4 different pixels
	move.l d0,(a2)+
	subq.l #4,d5
	bne.s .other
.next:
	move max_imagey,d7		; loop accross the lines!
	subq #1,d7
	move.l one_buffer,a1
	move.l two_buffer,a2
	move screenw,d4
	lsr #2,d4					; 4 pixels at a time
.line:
	move.l a1,a3				; flags
	move.l a2,a4				; colors
	move.l a3,d3				; for size of run
	move d4,d2
	subq #1,d2					; loop through one line
.start:
	tst.b (a3)+					; pixels to skip at the beginning
	bne.s .lb0
	addq.l #4,a4
	dbf d2,.start
	move.b #$01,(a0)+			; all to skip, empty line!
	bra.s .end_of_line
.lb0:
	subq.l #1,a3
	move.l a3,d0
	sub.l d3,d0					; number of 4-pixels to skip
.lb1:
	cmp #255,d0
	bmi.s .lb2
	st (a0)+
	sf (a0)+
	sub #254,d0
	bra.s .lb1
.lb2:
	addq #1,d0
	move.b d0,(a0)+
.lb4:
	move.l a3,d3				; new pos
	move.l a0,a5				; saves
	sf (a0)+						; the code byte
.run:
	tst.b (a3)+
	beq.s .lb5
	addq.b #1,(a5)				; the code byte
	bmi.s .lb3
	move.l (a4)+,(a0)+			; 4-pixels more
	dbf d2,.run
	bra.s .end_of_line
.lb3:
	subq.l #1,a3
	move.b #$7f,(a5)
	bra.s .lb4
.lb5:
	subq.l #1,a3
	move.l a3,d3
	sf (a0)+
	bra.s .start
.end_of_line:
	st (a0)+						; code $FF
	add d4,a1
	lea (a2,d4.w*4),a2
	dbf d7,.line
.end:
	rts

;objc_draw: dc.l od_cont,global,rect_draw,dum,tree,dum
;od_cont: dc.w 42,6,1,1,0

compress_wrle:
	move.l #'00dc',(a0)+
	clr.l (a0)+					; future size
	tst.b create_avi
	bpl compress_msvc
	move screenw,d5
	muls max_imagey,d5		; total size (in pixels)
	tst.b key_frame
	beq.s _z1
	clr key_count
	bra.s _new

rsrc_gaddr: dc.l rg_cont,global,rg_int,dum,dum,tree
rg_cont: dc.w 112,2,1,0,1

_z1:
	cmp.l #1,disp_frame		; first frame?
	bne.s .lb0
	clr key_count
	bra.s _new
.lb0:
	move key_count,d0
	cmp key_rate,d0
	bne.s _other
_new:
	move.l (a1)+,(a2)+		; 8 at a time
	move.l (a1)+,(a2)+
	st (a3)+						; all are new!
	subq.l #8,d5
	bne.s _new
	bra.s _next
_other:
	move.l (a1)+,d0
	cmp.l (a2),d0
	sne (a3)+					; FF if 4 different pixels
	move.l d0,(a2)+
	move.l (a1)+,d0
	cmp.l (a2),d0
	sne (a3)+
	move.l d0,(a2)+
	move -(a3),d0
	sne (a3)+					; FF if 8 different pixels
	subq.l #8,d5
	bne.s _other
_next:
	move max_imagey,d7		; loop accross the lines!
	subq #1,d7
	move.l one_buffer,a1
	move.l two_buffer,a2
	move screenw,d4
	move d4,d2
	muls d7,d2
	add.l d2,a2					; last line (datas)
	lsr.l #3,d2
	add.l d2,a1					; last line (flags)
.line:
	lsr #3,d4					; 8 pixels at a time
	move.l a1,a3				; flags
	move.l a2,a4				; colors
	move.l a3,d3				; for size of run
	move d4,d2
	subq #1,d2					; loop through one line
.start:
	tst.b (a3)+					; pixels to skip at the beginning
	bne.s .lb0
	addq.l #8,a4
	dbf d2,.start
	bra.s .end_of_line
.lb0:
	subq.l #1,a3
	move.l a3,d0
	sub.l d3,d0					; number of 8-pixels to skip
	beq.s .lb4					; nothing, no skip code
	lsl #3,d0					; number of pixels
.lb1:
	sf (a0)+
	move.b #$02,(a0)+
	cmp #255,d0
	bmi.s .lb2
	move.b #254,(a0)+
	sf (a0)+
	sub #254,d0
	bra.s .lb1
.lb2:
	move.b d0,(a0)+
	sf (a0)+
.lb4:
	sf (a0)+						; the code byte
	move.l a0,a5				; saves
	sf (a0)+						; count byte
.run:
	tst.b (a3)+
	beq.s .lb5
	addq.b #8,(a5)				; the code byte
	bcs.s .lb3
	move.l (a4)+,(a0)+			; 4-pixels more
	move.l (a4)+,(a0)+			; and more
	dbf d2,.run
	bra.s .end_of_line
.lb3:
	subq.l #1,a3
	move.b #$F8,(a5)
	bra.s .lb4
.lb5:
	subq.l #1,a3
	move.l a3,d3
	bra.s .start
.end_of_line:
	sf (a0)+
	sf (a0)+
	sub d4,a1				; back one line (flags)
	lsl #3,d4
	sub.w d4,a2				; back one line (datas)
	dbf d7,.line
.end:
	move.b #1,-1(a0)		; $00,$01 for end of frame
	bsr.s improve_wrle
	move.l a0,d0
fin_commune_avi:			; avec D0 = adresse fin dans rle16_buffer
	move.l rle16_buffer,a0
	sub.l a0,d0				; codec size
	subq.l #8,d0			; codec offset
	INTEL d0
	move.l d0,4(a0)		; size into frame
	move.l size_ptr,a1
	move.l #'00dc',(a1)+
	move.l #$02000000,(a1)+		; default flags
	tst.b key_frame		; a key frame wanted?
	bne.s .key
	move key_count,d1		; else, auto key frame?
	cmp key_rate,d1
	bne.s .no_key			; no!
	clr key_count			; yes, reset counter
.key:
	bset #4,-4(a1)			; mark it as a key frame
	addq #1,key_frame_num
.no_key:
	clr.l (a1)+				; offsets will be computed at the end
	move.l d0,(a1)+		; size
	move.l a1,size_ptr
	move.l a0,-(sp)
	INTEL d0
	addq.l #8,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; fwrite
	rts

improve_wrle:
	move max_imagey,d2
	subq #1,d2
	move.l rle16_buffer,a4
	addq.l #8,a4				; skips 00dc + size
	move.l a4,a3
	sf flx_flag
.while:
	tst d2
	bpl.s .lb0
.end:
	move.l a3,a0					; new end of frame
	rts
.lb0:
	moveq #0,d6
	move.b (a4)+,d6				; mod=0 always!
	move.b (a4)+,d6				; opcode
	bne.s .lb3
	tst.b flx_flag
	beq.s .first
	addq #1,flx_number
	bra.s .common
.first:
	move.l a3,flx_ptr
	move #1,flx_number
	st flx_flag
.common:
	clr.w (a3)+
	subq #1,d2
	bra.s .while
.lb3:
	cmp.b #1,d6						; if opcode=1
	bne.s .lb4
	tst.b flx_flag
	beq.s .no_empty
	move.l flx_ptr,a3
.no_empty:
	clr.b (a3)+
	move.b d6,(a3)+				; end of frame
	moveq #-1,d2
	bra.s .while
.lb4:
	tst.b flx_flag
	beq.s .no_empty2
	sf flx_flag
	move flx_number,d0
	cmp #3,d0
	bmi.s .no_empty2				; 1 or 2 lines, no need to improve
	move.l flx_ptr,a3
	clr (a3)+
	subq #1,d0						; ***
.opti_loop:
	move #2,(a3)+					; byte0 + byte2
	cmp #255,d0
	bmi.s .end_loop
	move #254,(a3)+				; byte 0 + byte $FE
	sub #254,d0
	bra.s .opti_loop
.end_loop:
	move d0,(a3)+					; last value
	cmp.b #2,d6						; essaye de fusionner les deux 0,2,x,y
	bne.s .lb5
	move.b 1(a4),d6				; nombre de lignes a sauter
	add d0,d6
	cmp #255,d6
	bmi.s .merge
	moveq #2,d6
	bra.s .no_empty2				; pas de fusion possible
.merge:
	move.b (a4)+,-2(a3)			; new dx
	move.b (a4)+,d6
	sub d6,d2
	add.b d6,-1(a3)
	bra .while
.no_empty2:
	cmp.b #2,d6						; if opcode=2
	bne.s .lb5
	clr.b (a3)+
	move.b d6,(a3)+
	move.b (a4)+,(a3)+
	move.b (a4)+,d6
	sub d6,d2
	move.b d6,(a3)+
	bra .while
.lb5:									; else (for opcode)
	move d6,d7				; number of bytes
	move.l a4,a6			; uncompressed datas
	move.l buffer,a1		; new compressed datas (if possible)
	move.l one_buffer,d6	; temporary
	bsr.s compress_wrun
	move.l a1,d0
	move.l buffer,a1
	sub.l a1,d0				; new size
	move d7,d1
	add d1,a4				; skips this bloc
	addq #2,d1				; old size
	cmp d1,d0
	bmi.s .better
	clr.b (a3)+
	move.b d7,(a3)+		; no improvement
	subq #1,d7
.no_imp:
	move.b (a6)+,(a3)+
	dbf d7,.no_imp
	bra .while
.better:
	subq #1,d0
.copy_new:
	move.b (a1)+,(a3)+
	dbf d0,.copy_new
	bra .while

compress_wrun:
	move.l d6,a2
	moveq #0,d1					; t=0
	moveq #0,d3					; bdex
.do_again:
	moveq #0,d0					; i=0
	lea 0(a6,d1.w),a0		; p+t
	move d7,d4
	subq #1,d4
	sub d1,d4					; bytes-1-t
	bra.s .valid
.while:
	move.b 0(a0,d0.w),d5
	cmp.b 1(a0,d0.w),d5
	bne.s .end_of_while
	addq #1,d0
.valid:
	cmp d7,d0
	bpl.s .end_of_while
	cmp d4,d0
	bpl.s .end_of_while
	bra.s .while
.end_of_while:
	tst d0
	bne.s .good_if
	cmp d7,d3
	bmi.s .not_if
.good_if:
	tst d3
	beq.s .other_if
	bsr.s .wcopy_string
	moveq #0,d3
	move.l d6,a2
.other_if:
	tst d0
	beq.s .end_of_do
	addq #1,d0				; i=i+1
	add d0,d1				; t=t+(i+1)
	move.b d0,(a1)+
	move.b d5,(a1)+
	bra.s .end_of_do
.not_if:
	move.b (a0),(a2)+
	addq #1,d3
	addq #1,d1
.end_of_do:
	cmp d7,d1
	bmi.s .do_again
	tst d3
	beq.s .no_remain
	bsr.s .wcopy_string
.no_remain:
	rts
.wcopy_string:
	move.l d6,a2
	cmp.b #1,d3
	bne.s .not1
	move.b d3,(a1)+
	move.b (a2),(a1)+
	rts
.not1:
	cmp.b #2,d3
	bne.s .not2
	moveq #1,d3
	move.b d3,(a1)+
	move.b (a2)+,(a1)+
	move.b d3,(a1)+
	move.b (a2),(a1)+
	rts
.not2:
	clr.b (a1)+
	move.b d3,(a1)+
	bra.s .loop
.copy:
	move.b (a2)+,(a1)+
.loop:
	dbf d3,.copy
	move a1,d3
	btst #0,d3
	beq.s .pair
	clr.b (a1)+
.pair:
	rts

form_center: dc.l fc_cont,global,dum,rect,tree,dum
fc_cont: dc.w 54,0,5,1,0

improve_rle16:
	move.l rle16_buffer,a4
	clr flx_start
	clr flx_end
	add.w #10,a4
	move (a4)+,d2		; number of lines
	move d2,flx_number
	st flx_flag			; lines are empty till here!
	addq.l #2,a4
	move.l a4,a3
	move.l a3,flx_ptr	; start here
.while:
	subq #1,d2
	bmi .lb1
	move.b (a4)+,(a3)+	; first byte
	moveq #0,d0
.cnt:
	move.b (a4)+,d0	; code
	bne.s .case80
	move.b d0,(a3)+
	move.b (a4)+,(a3)+	; skip code
	bra.s .cnt
.case80:
	bmi.s .end_of_line
	sf flx_flag				; we meet an non empty line!
	move d0,d7				; number of words
	move.l a4,a6			; uncompressed datas
	move.l buffer,a1		; new compressed datas (if possible)
	move.l one_buffer,d6	; temporary
	bsr compress_run
	move.l a1,d0
	move.l buffer,a1
	sub.l a1,d0				; new size
	move d7,d1
	add d1,d1
	add d1,a4				; skips this bloc
	addq #1,d1				; old size
	cmp d1,d0
	bmi.s .better
	move.b d7,(a3)+		; no improvement
	subq #1,d7
.no_imp:
	move (a6)+,(a3)+
	dbf d7,.no_imp
	moveq #0,d0
	bra.s .cnt
.better:
	subq #1,d0
.copy_new:
	move.b (a1)+,(a3)+
	dbf d0,.copy_new
	moveq #0,d0
	bra.s .cnt
.end_of_line:
	move.b d0,(a3)+		; end of line
	tst.b flx_flag
	bpl.s .non_empty
	addq #1,flx_start
	subq #1,flx_number
	move.l flx_ptr,a3		; back one line, it was empty!
	bra.s .while
.non_empty:
	bne.s .while
	move.l a3,flx_ptr
	move d2,flx_end
	move.b #1,flx_flag
	bra .while
.lb1:
	move.l rle16_buffer,a0
	move flx_number,d2
	sub flx_end,d2
	bls.s .nop_frame
	move flx_start,6(a0)
	move d2,10(a0)
	bra.s .common
.nop_frame:
	clr 4(a0)
.common:
	move.l flx_ptr,a0		; new end of frame
	rts



; a0
; a1=buffer sortie
; a2=buffer temporaire
; a6=les donn‚es non compress‚es

; d0,d1,d3,d4,d5

compress_run:
	move.l d6,a2
	moveq #0,d1					; t=0
	moveq #0,d3					; bdex
.do_again:
	moveq #0,d0					; i=0
	lea 0(a6,d1.w*2),a0		; p+t
	move d7,d4
	subq #1,d4
	sub d1,d4					; bytes-1-t
	bra.s .valid
.while:
	move 0(a0,d0.w*2),d5
	cmp 2(a0,d0.w*2),d5
	bne.s .end_of_while
	addq #1,d0
.valid:
	cmp d7,d0
	bpl.s .end_of_while
	cmp d4,d0
	bpl.s .end_of_while
	bra.s .while
.end_of_while:
	tst d0
	bne.s .good_if
	cmp d7,d3
	bmi.s .not_if
.good_if:
	tst d3
	beq.s .other_if
	move.b d3,(a1)+
	move.l d6,a2	; start of buffer
	bra.s .d
.copy_string:
	move (a2)+,(a1)+
.d:
	dbf d3,.copy_string
	moveq #0,d3
	move.l d6,a2
.other_if:
	tst d0
	beq.s .end_of_do
	addq #1,d0				; i=i+1
	add d0,d1				; t=t+(i+1)
	sub #256,d0
	neg d0
	move.b d0,(a1)+
	move d5,(a1)+
	bra.s .end_of_do
.not_if:
	move (a0),(a2)+
	addq #1,d3
	addq #1,d1
.end_of_do:
	cmp d7,d1
	bmi.s .do_again
	tst d3
	beq.s .no_remain
	move.b d3,(a1)+
	move.l d6,a2
	bra.s .d2
.copy_last:
	move (a2)+,(a1)+
.d2:
	dbf d3,.copy_last
.no_remain:
	rts

improve_rle8:
	move.l rle16_buffer,a4
	clr flx_start
	clr flx_end
	add.w #10,a4
	move (a4)+,d2		; number of lines
	move d2,flx_number
	st flx_flag			; lines are empty till here!
	addq.l #2,a4
	move.l a4,a3
	move.l a3,flx_ptr	; start here
.while:
	subq #1,d2
	bmi .lb1
	move.b (a4)+,(a3)+	; first byte
	moveq #0,d0
.cnt:
	move.b (a4)+,d0	; code
	bne.s .case80
	move.b d0,(a3)+
	move.b (a4)+,(a3)+	; skip code
	bra.s .cnt
.case80:
	bmi.s .end_of_line
	sf flx_flag				; we meet an non empty line!
	move d0,d7				; number of long words
	move.l a4,a6			; uncompressed datas
	move.l buffer,a1		; new compressed datas (if possible)
	move.l one_buffer,d6	; temporary
	bsr compress_run8
	move.l a1,d0
	move.l buffer,a1
	sub.l a1,d0				; new size
	move d7,d1
	add d1,d1
	add d1,d1				; long words!
	add d1,a4				; skips this bloc
	addq #1,d1				; old size
	cmp d1,d0
	bmi.s .better
	move.b d7,(a3)+		; no improvement
	subq #1,d7
.no_imp:
	move.l (a6)+,(a3)+
	dbf d7,.no_imp
	moveq #0,d0
	bra.s .cnt
.better:
	subq #1,d0
.copy_new:
	move.b (a1)+,(a3)+
	dbf d0,.copy_new
	moveq #0,d0
	bra.s .cnt
.end_of_line:
	move.b d0,(a3)+		; end of line
	tst.b flx_flag
	bpl.s .non_empty
	addq #1,flx_start
	subq #1,flx_number
	move.l flx_ptr,a3		; back one line, it was empty!
	bra.s .while
.non_empty:
	bne .while
	move.l a3,flx_ptr
	move d2,flx_end
	move.b #1,flx_flag
	bra .while
.lb1:
	move.l rle16_buffer,a0
	move flx_number,d2
	sub flx_end,d2
	bls.s .nop_frame
	move flx_start,6(a0)
	move d2,10(a0)
	bra.s .common
.nop_frame:
	clr 4(a0)
.common:
	move.l flx_ptr,a0		; new end of frame
	rts


compress_run8:
	move.l d6,a2
	moveq #0,d1					; t=0
	moveq #0,d3					; bdex
.do_again:
	moveq #0,d0					; i=0
	lea 0(a6,d1.w*4),a0		; p+t
	move d7,d4
	subq #1,d4
	sub d1,d4					; bytes-1-t
	bra.s .valid
.while:
	move.l 0(a0,d0.w*4),d5
	cmp.l 4(a0,d0.w*4),d5
	bne.s .end_of_while
	addq #1,d0
.valid:
	cmp d7,d0
	bpl.s .end_of_while
	cmp d4,d0
	bpl.s .end_of_while
	bra.s .while
.end_of_while:
	tst d0
	bne.s .good_if
	cmp d7,d3
	bmi.s .not_if
.good_if:
	tst d3
	beq.s .other_if
	move.b d3,(a1)+
	move.l d6,a2	; start of buffer
	bra.s .d
.copy_string:
	move.l (a2)+,(a1)+
.d:
	dbf d3,.copy_string
	moveq #0,d3
	move.l d6,a2
.other_if:
	tst d0
	beq.s .end_of_do
	addq #1,d0				; i=i+1
	add d0,d1				; t=t+(i+1)
	sub #256,d0
	neg d0
	move.b d0,(a1)+
	move.l d5,(a1)+
	bra.s .end_of_do
.not_if:
	move.l (a0),(a2)+
	addq #1,d3
	addq #1,d1
.end_of_do:
	cmp d7,d1
	bmi.s .do_again
	tst d3
	beq.s .no_remain
	move.b d3,(a1)+
	move.l d6,a2
	bra.s .d2
.copy_last:
	move.l (a2)+,(a1)+
.d2:
	dbf d3,.copy_last
.no_remain:
	rts

compress_msvc:
	tst.b key_frame
	bne.s .new
	cmp.l #1,disp_frame		; first frame?
	beq.s .new
	move key_count,d0
	cmp key_rate,d0
	bne.s .other
.new:
	clr key_count
	st key_frame
.other:
	moveq #0,d0
	move d0,.num_skip			; pas de bloc saut‚ encore.
	exg.l a1,a0					; encore mal programm‚... a0=nouvelle image
	exg.l a1,a2					; a1=ancienne, a2=zone compress‚e
	move max_imagex,d0
	muls max_imagey,d0		; nombre de pixels … traiter
	tst.b qt_palette			; est-ce du 8 bits?
	bne _compress_msvc8
	move.l d0,d1
	add.l d1,d1
	add.l d1,d0					; nombre d'octets
	lea 0(a0,d0.l),a3			; adresse de fin
	move.l a3,.adr_fin
.bloc_suivant:
	cmp.l .adr_fin(pc),a0
	bpl .fin
	tst.b key_frame
	beq.s .pas_key
	move.l buffer,a3
	move.l #$7FFFFFFF,(a3)+
	bra.s .c1
.pas_key:
	bsr .msvc_diff
	moveq #0,d1
	move quality,d1
	moveq #1,d2
	add .num_skip(pc),d2
	divs.l d2,d1
	add.l d1,d0
	move.l buffer,a3
	move.l d0,(a3)+			; erreur avec DIFF
.c1:
	st (a3)						; pour faire <0 … la fin
	move.l a1,.save_two
	bsr _prepare_qualite
	bsr .msvc_c1
.c2:
	bsr .msvc_c2
.c8:
	bsr .msvc_c8

.decide:
	move.l buffer,a3
	move.l (a3)+,d1
	move.l a3,a4
	moveq #2,d0
.encore:
	lea 28(a3),a3
	move.l (a3)+,d2
	cmp.l d1,d2
	bpl.s .pas_mieux
	move.l d2,d1
	move.l a3,a4
.pas_mieux:
	dbf d0,.encore
	lea .num_skip(pc),a3
	move (a3),d1
	move (a4)+,d0
	bpl.s .copy_words
	cmp #$3FF,d1
	bne.s .conserve
	add #$8400,d1
	ror #8,d1
	move d1,(a2)+
	move #1,(a3)
	bra .suite
.conserve:
	addq #1,d1
	move d1,(a3)
	bra .suite
.copy_words:
	tst d1
	beq.s .copy
	add #$8400,d1
	ror #8,d1
	move d1,(a2)+
	clr (a3)
.copy:
	move (a4)+,(a2)+
	dbf d0,.copy
	move.l .save_two(pc),a1
	move (a4)+,d0			; code pour mettre … jour two_buffer
	bne.s .code1			; pas z‚ro
	move.b (a4)+,d1
	move.b (a4)+,d2
	move.b (a4)+,d3
	moveq #15,d4
.update_c1:
	move.b d1,(a1)+
	move.b d2,(a1)+
	move.b d3,(a1)+
	dbf d4,.update_c1
	bra.s .suite
.code1:
	subq #1,d0
	bne.s .code2			; pas 1
	move.w (a4)+,d1
	move.w (a4)+,d4
	move.w (a4)+,d2
	move.w (a4)+,d5
	move.w (a4)+,d3
	move.w (a4)+,d6		; r‚cupŠre best0 et best1
	move.w (a4),d7			; et l'index ordre 0-15
	moveq #0,d0
.update_c2:
	btst d0,d7
	bne.s .uc2_1
	move.b d4,(a1)+
	move.b d5,(a1)+
	move.b d6,(a1)+
	bra.s .uc2_2
.uc2_1:
	move.b d1,(a1)+
	move.b d2,(a1)+
	move.b d3,(a1)+
.uc2_2:
	addq #1,d0
	cmp #16,d0
	bne.s .update_c2
	bra.s .suite
.code2:
	moveq #3,d0				; compteur 3 … 0 pour 4 paquets
.update_c8:
	move.w (a4)+,d1
	move.w (a4)+,d4		; contient egalement l'index sur les bits 8-11
	move.w (a4)+,d2
	move.w (a4)+,d5
	move.w (a4)+,d3
	move.w (a4)+,d6		; r‚cupŠre best0 et best1
	moveq #8,d7				; numero de bit
.update_c8_1:
	btst d7,d4
	bne.s .uc8_1
	move.b d4,(a1)+
	move.b d5,(a1)+
	move.b d6,(a1)+
	bra.s .uc8_2
.uc8_1:
	move.b d1,(a1)+
	move.b d2,(a1)+
	move.b d3,(a1)+
.uc8_2:
	addq #1,d7
	cmp #12,d7
	bne.s .update_c8_1
	dbf d0,.update_c8
.suite:
	move.l .save_two(pc),a1
	lea 48(a0),a0			; saute 16 pixels
	lea 48(a1),a1
	bra .bloc_suivant
.fin:
	move .num_skip(pc),d0
	beq.s .vraiment_fini
	add.w #$8400,d0
	ror #8,d0
	move.w d0,(a2)+
.vraiment_fini:
	move.l a2,d0
	bra fin_commune_avi
.num_skip: dc.l 0
.adr_fin: dc.l 0
.save_two: dc.l 0
.msvc_diff:			; calcule somme (old-new)^2 sur 3*16 pixels
	move.l a0,a3	; somme dans D0
	move.l a1,a4
	moveq #47,d1
	moveq #0,d0
	lea Rdbfr+1020,a5
.ecart:
	move.b (a3)+,d2
	sub.b (a4)+,d2
	ext.w d2
	add.l 0(a5,d2.w*4),d0
	dbf d1,.ecart
.cont1:
	rts
.msvc_c1:			; calcule la moyenne RVB des 16 pixels
	move.l buffer,a3
	move.l (a3),d1	; erreur avec DIFF
	move.l 32(a3),d2
	cmp.l d1,d2
	bpl.s .cont1	; ne calcule pas car DIFF est meilleur d‚j…
	move.l a0,a3
	moveq #0,d1		; moyenne rouge
	moveq #0,d2		; vert
	moveq #0,d3		; bleu
	moveq #15,d4
	moveq #0,d5
.moy:
	move.b (a3)+,d5
	add d5,d1
	move.b (a3)+,d5
	add d5,d2
	move.b (a3)+,d5
	add d5,d3
	dbf d4,.moy
	move #$00F8,d5
	lsr #4,d1
	lsr #4,d2
	lsr #4,d3
	and d5,d1
	and d5,d2
	and d5,d3
	cmp.b #8,d1	; pour ‚viter le code $84 … $87
	bne.s .ok
	moveq #16,d1
.ok:
	move.l a0,a3
	moveq #0,d0
	moveq #15,d4
	lea Rdbfr+1020,a5
.ecart_c1:
	move.b (a3)+,d5
	sub.b d1,d5
	ext.w d5
	add.l 0(a5,d5.w*4),d0
	move.b (a3)+,d5
	sub.b d2,d5
	ext.w d5
	add.l 0(a5,d5.w*4),d0
	move.b (a3)+,d5
	sub.b d3,d5
	ext.w d5
	add.l 0(a5,d5.w*4),d0
	dbf d4,.ecart_c1
	move.l buffer,a3
	lea 32(a3),a3
	add.l d0,(a3)+			;	move.l d0,(a3)+		; erreur avec une couleur
	clr (a3)+				; une seule valeur
	addq.l #6,a3
	move.b d3,(a3)
	move.b d2,-(a3)
	move.b d1,-(a3)
	clr.w -(a3)				; code 0 pour copier 16 fois le mˆme RVB
	bsr.s .d123to15b
	or.b #$80,d2
	move d2,-(a3)			; la couleur en question
	rts
.d123to15b:
	lsl #7,d1		; pr‚pare rouge
	lsl #2,d2		; vert
	lsr #3,d3		; bleu
	or d1,d2
	or d3,d2
	ror #8,d2		; et INTEL!
.cont2:
	rts
.msvc_c2:
	move.l buffer,a3
	move.l (a3),d0
	move.l 64(a3),d4
	cmp.l d0,d4
	bpl.s .cont2			; ne calcule pas si DIFF meilleur
	move.l 32(a3),d0
	cmp.l d0,d4
	bpl.s .cont2			; ne calcule pas si MSVC 1 meilleur
	moveq #15,d0
	bsr.s .best2colors
	move.l buffer,a3
	lea 64(a3),a3
	add.l d0,(a3)+			; move.l d0,(a3)+		; erreur avec deux couleurs
	move #2,(a3)+			; trois valeurs
	tst d7
	bpl.s .pasbit15
	not d7
	swap d1
	swap d2
	swap d3
.pasbit15:
	move d7,d0
	move d7,d5
	and #$C3C3,d7
	move d0,d4
	and #$3030,d0
	and #$0C0C,d4
	lsr #2,d0
	lsl #2,d4
	or d0,d7
	or d4,d7
	ror #8,d7
	move d7,(a3)+			; index ordre CRAM
	lea 18(a3),a3
	move d5,(a3)			; index ordre 0-15
	move.l d3,-(a3)
	move.l d2,-(a3)
	move.l d1,-(a3)
	move #1,-(a3)			; code 1 pour deux couleurs
	bsr.s .d123to15b
	move d2,-(a3)
	swap d1
	swap d2
	swap d3
	bsr.s .d123to15b
	move d2,-(a3)
	rts
.best2colors:
	move.l d0,a4			; nombre de points (15 pour 16 ou 3 pour 4)
	moveq #0,d1
	move.l d0,d4
	move.l d1,a3			; old index
	moveq #0,d2
	add.l d4,d4
	moveq #0,d3
	add.l d4,d0				; 3*(len-1) pour acc‚der au dernier pixel
	move.l a0,a1
	move.b (a1)+,d1
	move.b (a1)+,d2
	swap d1
	move.b (a1),d3		; best0 initialis‚ … la couleur 0
	lea 0(a0,d0.l),a1
	swap d2
	move.b (a1)+,d1
	swap d3
	move.b (a1)+,d2
	swap d1
	move.b (a1),d3		; best1 initialis‚ … la couleur len-1
	swap d2
	swap d3
	moveq #20,d7
	move.l d7,a5		; boucle de 1 … 20 (maximum de recherche)
.iteration:
	moveq #0,d7			; index
	move.l a0,a1
	moveq #0,d5
	moveq #-1,d0			; boucle 0 … len-1
.plus_pres_de_qui:
	move.b (a1)+,d5
	sub.b d1,d5
	bcc.s .lb1
	neg.b d5
.lb1:
	swap d1
	move d5,d4
	move.b (a1)+,d5
	sub.b d2,d5
	bcc.s .lb2
	neg.b d5
.lb2:
	swap d2
	add d5,d4
	move.b (a1),d5
	sub.b d3,d5
	bcc.s .lb3
	neg.b d5
.lb3:
	swap d3
	subq.l #2,a1
	add d5,d4			; distance absolue entre pixel et best0
	move.b (a1)+,d5
	sub.b d1,d5
	bcc.s .lb4
	neg.b d5
.lb4:
	swap d1
	move d5,d6
	move.b (a1)+,d5
	sub.b d2,d5
	bcc.s .lb5
	neg.b d5
.lb5:
	swap d2
	add d5,d6
	move.b (a1)+,d5
	sub.b d3,d5
	bcc.s .lb6
	neg.b d5
.lb6:
	swap d3
	add d5,d6		; distance absolue entre pixel et best1
	addq.l #1,d0
	cmp d4,d6
	bpl.s .bit0
	bset d0,d7		; bit … 1 si plus prŠs de best0
	swap d7
	addq #1,d7
	swap d7			; compte le nombre de plus prŠs de best0
.bit0:
	cmp.l d0,a4		; len-1?
	bne.s .plus_pres_de_qui
	tst d7
	bne.s .lb7
	bset #1,d7
	swap d7
	addq #1,d7
	swap d7			; si aucun prŠs de best0, on met le pixel 1...
	bra.s .lb8
.lb7:
	move.l d7,d6
	swap d6
	cmp d6,d0		; >len-1
	bpl.s .lb8
	bclr #0,d7
	swap d7
	subq #1,d7
	swap d7			; si aucun prŠs de best1, on met le pixel 0...
.lb8:
	move.l a0,a1	; on reprend!
	moveq #-1,d0
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	moveq #0,d4
	moveq #0,d5
	moveq #0,d6
.recalcule_best01:
	addq.l #1,d0
	btst d0,d7
	bne.s .best0
	swap d0
	move.b (a1)+,d0
	add d0,d4
	move.b (a1)+,d0
	add d0,d5
	move.b (a1)+,d0
	add d0,d6			; ajoute … best1
	bra.s .lb9
.best0:
	swap d0
	move.b (a1)+,d0
	add d0,d1
	move.b (a1)+,d0
	add d0,d2
	move.b (a1)+,d0
	add d0,d3			; ajoute … best0
.lb9:
	swap d0
	cmp d0,a4
	bne.s .recalcule_best01
	swap d7					; nombre de plus prŠs de best 0
	divs d7,d1				; moyenne!
	divs d7,d2
	swap d1
	divs d7,d3
	swap d2
	move.l a4,d0
	sub d7,d0
	swap d3
	addq #1,d0				; nombre de plus prŠs de best 1
	divs d0,d4
	divs d0,d5
	move d4,d1
	divs d0,d6
	move d5,d2
	swap d1
	move d6,d3
	clr d7
	swap d2
	swap d7
	swap d3					; voil…!
	exg.l d7,a3
	cmp.l d7,a3				; old index = new index?
	beq.s .lb10				; oui on sort
	subq.l #1,a5
	cmp.l #0,a5				; sinon, on continue jusqu'… 20 fois
	bne .iteration
.lb10:
	move.l #$00F800F8,d0
	and.l d0,d1
	and.l d0,d2
	and.l d0,d3				; calibre bast0 et best1 … 5 bits
	sub.l a5,a5				; la distance … zero
	lea Rdbfr+1020,a6
	moveq #-1,d0
	move.l a0,a1			; on repart au debut
	move.l d1,d4
	move.l d2,d5
	move.l d3,d6
	swap d4
	swap d5
	swap d6
.distance:
	addq.l #1,d0
	btst d0,d7
	bne.s .lb11
	move.l d0,a3
	moveq #0,d0
	move.b (a1)+,d0
	sub d1,d0
	add.l 0(a6,d0.w*4),a5
	moveq #0,d0
	move.b (a1)+,d0
	sub d2,d0
	add.l 0(a6,d0.w*4),a5
	moveq #0,d0
	move.b (a1)+,d0
	sub d3,d0
	add.l 0(a6,d0.w*4),a5
	bra.s .lb12
.lb11:
	move.l d0,a3
	moveq #0,d0
	move.b (a1)+,d0
	sub d4,d0
	add.l 0(a6,d0.w*4),a5
	moveq #0,d0
	move.b (a1)+,d0
	sub d5,d0
	add.l 0(a6,d0.w*4),a5
	moveq #0,d0
	move.b (a1)+,d0
	sub d6,d0
	add.l 0(a6,d0.w*4),a5
.lb12:
	move.l a3,d0
	cmp.l d0,a4
	bne.s .distance
	move.l a5,d0		; distance D0 et D7 contient l'index
.cont3:
	rts
.msvc_c8:
	lea .adr1(pc),a5
	move.l buffer,a4
	move.l (a4),d0
	lea 96(a4),a4
	move.l (a4),d4
	cmp.l d0,d4
	bpl.s .cont3		; ne calcule pas car DIFF meilleur
	move.l -32(a4),d0
	cmp.l d0,d4
	bpl.s .cont3		; idem si MSVC 2 meilleur
	move.l -64(a4),d0
	cmp.l d0,d4
	bpl.s .cont3		; idem si MSVC 1 meilleur
	moveq #0,d0
	move.l a4,8(a5)	; pointeur distance
	addq.l #4,a4		; move.l d0,(a4)+
	move #8,(a4)+
	move d0,(a4)+		; index
	move.l a4,(a5)+	; pointeur sur couleurs 16 bits
	lea 16(a4),a4
	move #2,(a4)+
	move.l a4,(a5)+	; pointeur sur couleurs 24 bits
	bsr.s .paquetde4
	lsr #4,d7
	lea 12(a0),a0		; passe aux 4 pixels suivants
	move d7,(a5)
	bsr.s .paquetde4
	lsr #2,d7
	lea 12(a0),a0
	or d7,(a5)
	bsr.s .paquetde4
	lsl #4,d7
	lea 12(a0),a0
	or d7,(a5)
	bsr.s .dernierpaquetde4
	lsl #6,d7
	lea -36(a0),a0
	or (a5),d7
	ror #8,d7			; intel!
	move d7,(a5)
	bset #7,3(a5)		; met … 1 le bit 15 de la couleur 0 (marque de C8)
	rts
.dernierpaquetde4:
	moveq #3,d0
	bsr .best2colors
	btst #3,d7			; ne doit pas ˆtre mis pour C8!
	beq.s .pasmis
	not.b d7
	swap d1
	and.b #$0F,d7
	swap d2
	swap d3
	bra.s .pasmis
.paquetde4:
	moveq #3,d0
	bsr .best2colors
.pasmis:
	movem.l .adr1(pc),a3-a5
	add.l d0,(a5)
	addq.l #6,a5		; pour pointer sur l'index
	lsl #8,d7
	or d7,d1				; garde les 4 bits d'index dans le rouge...
	lsr #2,d7
	lsr.b #2,d7			; s‚pare les bits en 0000.0032.0010.0000
	move.l d1,(a4)+
	move.l d2,(a4)+
	move.l d3,(a4)+	; garde les deux couleurs
	bsr .d123to15b
	move d2,2(a3)
	swap d1
	swap d2
	swap d3
	bsr .d123to15b
	move d2,(a3)
	addq.l #4,a3
	movem.l a3-a4,.adr1
	rts
.adr1: dc.l 0	; pointeur 16 bits
.adr2: dc.l 0	; pointeur 24 bits
.dist: dc.l 0	; adresse distance

_prepare_qualite:
	move.l buffer,a3
	moveq #0,d0
	lea 32(a3),a3
	move quality,d0
	move.l d0,(a3)		; ecart + quality pour msvc 1
	move.l d0,d1
	lea 32(a3),a3
	add.l d1,d1
	add.l d0,d1
	move.l d1,(a3)		; ecart + 3*quality pour msvc 2
	move.l d1,d0
	lea 32(a3),a3
	add.l d0,d0
	add.l d1,d0
	move.l d0,(a3)		; ecart + 9*quality pour msvc 8
	rts

_compress_msvc8:
	lea 0(a0,d0.l),a3			; adresse de fin
	move.l a3,.adr_fin
	moveq #0,d0
	move d0,.num_skip			; compteur saut … z‚ro
.bloc_suivant:
	cmp.l .adr_fin(pc),a0
	bpl .fin
	tst.b key_frame
	beq.s .pas_key
	move.l buffer,a3
	move.l #$7FFFFFFF,(a3)+
	bra.s .c1
.pas_key:
	bsr .msvc_diff
	moveq #0,d1
	move quality,d1
	moveq #1,d2
	add .num_skip(pc),d2
	divs.l d2,d1
	add.l d1,d0
	move.l buffer,a3
	move.l d0,(a3)+			; erreur avec DIFF
.c1:
	st (a3)						; pour faire <0 … la fin
	move.l a1,.save_two
	bsr _prepare_qualite
	bsr .msvc_c1
.c2:
	bsr .msvc_c2
.c8:
	bsr .msvc_c8

.decide:
	move.l buffer,a3
	move.l (a3)+,d1
	move.l a3,a4
	moveq #2,d0
.encore:
	lea 28(a3),a3
	move.l (a3)+,d2
	cmp.l d1,d2
	bpl.s .pas_mieux
	move.l d2,d1
	move.l a3,a4
.pas_mieux:
	dbf d0,.encore
	lea .num_skip(pc),a3
	move (a3),d1
	move (a4)+,d0
	bpl.s .copy_words
	cmp #$3FF,d1
	bne.s .conserve
	add #$8400,d1
	ror #8,d1
	move d1,(a2)+
	move #1,(a3)
	bra .suite
.conserve:
	addq #1,d1
	move d1,(a3)
	bra.s .suite
.copy_words:
	tst d1
	beq.s .copy
	add #$8400,d1
	ror #8,d1
	move d1,(a2)+
	clr (a3)
.copy:
	move (a4)+,(a2)+
	dbf d0,.copy
	move.l .save_two(pc),a1
	move (a4),d0			; code pour mettre … jour two_buffer
	bne.s .code1			; pas z‚ro
	move.b -2(a4),d1		; r‚cupŠre la couleur
	move.b d1,d2
	lsl #8,d1
	move.b d2,d1
	move d1,d2
	swap d2
	move d1,d2
;.update_c1:
	move.l d1,(a1)+		; met … jour les 16 pixels
	move.l d1,(a1)+
	move.l d1,(a1)+
	move.l d1,(a1)+
	bra.s .suite
.code1:
	subq #1,d0
	bne.s .code2			; pas 1
	move.b -(a4),d4
	move.b -(a4),d1
	move.w -(a4),d7
	ror #8,d7
	moveq #0,d0
.update_c2:
	btst d0,d7
	bne.s .uc2_1
	move.b d4,(a1)+
	bra.s .uc2_2
.uc2_1:
	move.b d1,(a1)+
.uc2_2:
	addq #1,d0
	cmp #16,d0
	bne.s .update_c2
	bra.s .suite
.code2:
	moveq #3,d0				; compteur 3 … 0 pour 4 paquets
	addq.l #2,a4			; saute le code
.update_c8:
	move.b (a4)+,d7		; index
	move.b (a4)+,d1		; best1
	move.b (a4)+,d4		; best0
	moveq #0,d2				; numero de bit
.update_c8_1:
	btst d2,d7
	bne.s .uc8_1
	move.b d4,(a1)+
	bra.s .uc8_2
.uc8_1:
	move.b d1,(a1)+
.uc8_2:
	addq #1,d2
	cmp #4,d2
	bne.s .update_c8_1
	dbf d0,.update_c8
.suite:
	move.l .save_two(pc),a1
	lea 16(a0),a0			; saute 16 pixels
	lea 16(a1),a1
	bra .bloc_suivant
.fin:
	move .num_skip(pc),d0
	beq.s .vraiment_fini
	add.w #$8400,d0
	ror #8,d0
	move.w d0,(a2)+
.vraiment_fini:
	move.l a2,d0
	bsr stats_msvc
	bra fin_commune_avi
.num_skip: dc.l 0
.adr_fin: dc.l 0
.save_two: dc.l 0
.msvc_diff:			; calcule somme (old-new)^2 sur 16 pixels
	move.l a0,a3	; somme dans D0
	move.l a1,a4
	moveq #15,d1
	moveq #0,d0
	lea Rdbfr+1020,a5
.ecart:
	move.b (a3)+,d2
	sub.b (a4)+,d2
	ext.w d2
	add.l 0(a5,d2.w*4),d0
	dbf d1,.ecart
.cont1:
	rts
.msvc_c1:			; calcule la moyenne des 16 pixels
	move.l buffer,a3
	move.l (a3),d1	; erreur avec DIFF
	move.l 32(a3),d2
	cmp.l d1,d2
	bpl.s .cont1	; ne calcule pas car DIFF est meilleur d‚j…
	move.l a0,a3
	moveq #0,d1		; moyenne gris
	moveq #15,d4
	moveq #0,d5
.moy:
	move.b (a3)+,d5
	add d5,d1
	dbf d4,.moy
	lsr #4,d1
	move.l a0,a3
	moveq #0,d0
	moveq #15,d4
	lea Rdbfr+1020,a5
.ecart_c1:
	move.b (a3)+,d5
	sub.b d1,d5
	ext.w d5
	add.l 0(a5,d5.w*4),d0
	dbf d4,.ecart_c1
	move.l buffer,a3
	lea 32(a3),a3
	add.l d0,(a3)+			; erreur avec une couleur
	clr (a3)+				; un seul mot
	move.b d1,(a3)+		; la couleur
	move.b #$80,(a3)+		; code C1
	clr.w (a3)+				; code 0 pour copier 16 fois le mˆme gris
.cont2:
	rts
.msvc_c2:
	move.l buffer,a3
	move.l (a3),d0
	move.l 64(a3),d4
	cmp.l d0,d4
	bpl.s .cont2			; ne calcule pas si DIFF meilleur
	move.l 32(a3),d0
	cmp.l d0,d4
	bpl.s .cont2			; ne calcule pas si MSVC 1 meilleur
	moveq #15,d0
	bsr.s .best2colors
	move.l buffer,a3
	lea 64(a3),a3
	add.l d0,(a3)+			; erreur avec deux couleurs
	move #1,(a3)+			; deux mots
	tst d7
	bpl.s .pasbit15
	not d7
	swap d1
.pasbit15:
	move d7,d0
	move d7,d5
	and #$C3C3,d7
	move d0,d4
	and #$3030,d0
	and #$0C0C,d4
	lsr #2,d0
	lsl #2,d4
	or d0,d7
	or d4,d7
	ror #8,d7
	move d7,(a3)+			; index ordre CRAM
	swap d1
	move.b d1,(a3)+
	swap d1
	move.b d1,(a3)+
	move #1,(a3)			; code pour update c2
	rts
.best2colors:
	move.l d0,a4			; nombre de points (15 pour 16 ou 3 pour 4)
	moveq #0,d1
	move.l d1,a3			; old index
	move.b (a0),d1		; best0 initialis‚ … la couleur 0
	swap d1
	move.b 0(a0,d0.l),d1		; best1 initialis‚ … la couleur len-1
	moveq #20,d7
	move.l d7,a5		; boucle de 1 … 20 (maximum de recherche)
.iteration:
	moveq #0,d7			; index
	move.l a0,a1
	moveq #0,d5
	moveq #-1,d0			; boucle 0 … len-1
.plus_pres_de_qui:
	moveq #0,d4
	move.b (a1)+,d4
	moveq #0,d6
	move.b d4,d6
	sub.b d1,d4
	bcc.s .lb1
	neg.b d4
.lb1:
	swap d1
	sub.b d1,d6
	bcc.s .lb4
	neg.b d6
.lb4:
	swap d1
	addq.l #1,d0
	cmp d4,d6
	bpl.s .bit0
	bset d0,d7		; bit … 1 si plus prŠs de best0
	swap d7
	addq #1,d7
	swap d7			; compte le nombre de plus prŠs de best0
.bit0:
	cmp.l d0,a4		; len-1?
	bne.s .plus_pres_de_qui
	tst d7
	bne.s .lb7
	bset #1,d7
	swap d7
	addq #1,d7
	swap d7			; si aucun prŠs de best0, on met le pixel 1...
	bra.s .lb8
.lb7:
	move.l d7,d6
	swap d6
	cmp d6,d0		; >len-1
	bpl.s .lb8
	bclr #0,d7
	swap d7
	subq #1,d7
	swap d7			; si aucun prŠs de best1, on met le pixel 0...
.lb8:
	move.l a0,a1	; on reprend!
	moveq #-1,d0
	moveq #0,d1
	moveq #0,d4
	moveq #0,d2
.recalcule_best01:
	addq.l #1,d0
	move.b (a1)+,d2
	btst d0,d7
	bne.s .best0
	add d2,d4			; ajoute … best1
	bra.s .lb9
.best0:
	add d2,d1			; ajoute … best0
.lb9:
	cmp d0,a4
	bne.s .recalcule_best01
	swap d7					; nombre de plus prŠs de best 0
	divs d7,d1				; moyenne!
	swap d1
	move.l a4,d0
	sub d7,d0
	addq #1,d0				; nombre de plus prŠs de best 1
	divs d0,d4
	move d4,d1
	swap d1
	clr d7
	swap d7
	exg.l d7,a3
	cmp.l d7,a3				; old index = new index?
	beq.s .lb10				; oui on sort
	subq.l #1,a5
	cmp.l #0,a5				; sinon, on continue jusqu'… 20 fois
	bne .iteration
.lb10:
	sub.l a5,a5				; la distance … zero
	lea Rdbfr+1020,a6
	moveq #-1,d0
	move.l a0,a1			; on repart au debut
	move.l d1,d4
	swap d4
.distance:
	addq.l #1,d0
	btst d0,d7
	bne.s .lb11
	move.l d0,a3
	moveq #0,d0
	move.b (a1)+,d0
	sub d1,d0
	add.l 0(a6,d0.w*4),a5
	bra.s .lb12
.lb11:
	move.l d0,a3
	moveq #0,d0
	move.b (a1)+,d0
	sub d4,d0
	add.l 0(a6,d0.w*4),a5
.lb12:
	move.l a3,d0
	cmp.l d0,a4
	bne.s .distance
	move.l a5,d0		; distance D0 et D7 contient l'index
.cont3:
	rts
.msvc_c8:
	lea .adr1(pc),a5
	move.l buffer,a4
	move.l (a4),d0
	lea 96(a4),a4
	move.l (a4),d4
	cmp.l d0,d4
	bpl.s .cont3		; ne calcule pas car DIFF meilleur
	move.l -32(a4),d0
	cmp.l d0,d4
	bpl.s .cont3		; idem si MSVC 2 meilleur
	move.l -64(a4),d0
	cmp.l d0,d4
	bpl.s .cont3		; idem si MSVC 1 meilleur
	moveq #0,d0
	move.l a4,8(a5)	; pointeur distance
	addq.l #4,a4
	move #4,(a4)+
	move d0,(a4)+		; index
	move.l a4,(a5)+	; pointeur sur couleurs
	addq.l #8,a4
	move #2,(a4)+
	move.l a4,(a5)+	; pointeur sur couleurs et index pour update
	bsr .paquetde4
	lsr #4,d7
	addq.l #4,a0		; passe aux 4 pixels suivants
	move d7,(a5)
	bsr.s .paquetde4
	lsr #2,d7
	addq.l #8,a0
	or d7,(a5)
	bsr.s .dernierpaquetde4
	lsl #6,d7
	subq.l #4,a0
	or d7,(a5)
	bsr.s .avantdernierpaquetde4
	lsl #4,d7
	subq.l #8,a0
	or (a5),d7
	ror #8,d7			; intel!
	move d7,(a5)
	rts
.avantdernierpaquetde4:
	moveq #3,d0
	bsr .best2colors
	movem.l .adr1(pc),a3-a5
	subq.l #4,a3
	subq.l #6,a4		; deux paquets invers‚s
	tst.b .changer3	; confusion possible avec $8x?
	beq.s .commun		; non, on saute
	move.b d7,d2
	and.b #$C,d2		; teste les bits 32..
	bne.s .commun		; si mis, pas de confusion avec $8x
	not.b d7
	swap d1
	and.b #$0F,d7
	bra.s .commun
.dernierpaquetde4:
	sf .changer3
	moveq #3,d0
	bsr .best2colors
	btst #3,d7			; doit ˆtre mis!
	bne.s .mis
	not.b d7
	swap d1
	and.b #$0F,d7
.mis:
	btst #2,d7
	seq .changer3		; c'est 0x10.., confusion possible avec $1000
	movem.l .adr1(pc),a3-a5
	addq.l #2,a3
	addq.l #3,a4		; deux paquets invers‚s
	bra.s .commun
.paquetde4:
	moveq #3,d0
	bsr .best2colors
	movem.l .adr1(pc),a3-a5
.commun:
	add.l d0,(a5)
	addq.l #6,a5		; pour pointer sur l'index
	move.b d7,(a4)+	; 4 bits d'index
	lsl #6,d7
	lsr.b #2,d7			; s‚pare les bits en 0000.0032.0010.0000
	swap d1
	move.b d1,(a4)+
	move.b d1,(a3)+
	swap d1
	move.b d1,(a4)+
	move.b d1,(a3)+
	movem.l a3-a4,.adr1
	rts
.adr1: dc.l 0	; pointeur couleurs pour fichier AVI
.adr2: dc.l 0	; pointeur couleurs + index pour update
.dist: dc.l 0	; adresse distance
.changer3: dc.l 0	; flag si avant dernier paquet peut ˆtre invers‚

stats_msvc:
	movem.l a0-a1/d0-d1,-(sp)
	lea .var(pc),a0
	move.l rle16_buffer,a1
	addq.l #8,a1
	moveq #0,d1
.suite:
	cmp.l d0,a1
	bpl.s .termine
	move (a1)+,d1
	ror #8,d1
	bpl.s .c2
	cmp.l #$9000,d1
	bmi.s .suite
	addq.l #1,4(a0)
	addq.l #8,a1
	bra.s .suite
.c2:
	addq.l #1,(a0)
	addq.l #2,a1
	bra.s .suite
.termine:
	movem.l (sp)+,a0-a1/d0-d1
	rts

.var: dc.l 0,0		; nombre de 2 octets, nombre de 8 octets


end_of_avi:
	move mov_h2,d5
	move.l header_buffer,a0
	moveq #0,d4
	tst.b qt_palette
	beq.s .no_pal
	move #1024,d4
	add.l d4,a0				; idx1 section	after palette
.no_pal:
	move.l size_ptr,a1			; end of section
	move.l a1,d0
	sub.l a0,d0						; size of section
	subq.l #8,d0
	addq.l #4,a0
	INTEL d0
	move.l d0,(a0)+
	moveq #0,d0						; max frame size
	moveq #4,d1						; first offset
.offsets:
	cmp.l a1,a0
	bpl.s .save_idx1
	move.l (a0)+,d3				; 00dc or 01wb
	addq.l #4,a0					; skips flags
	INTEL d1
	move.l d1,(a0)+				; offset
	INTEL d1
	move.l (a0)+,d2				; size
	INTEL d2
	addq.l #8,d2
	cmp.l #'00dc',d3
	bne.s .no						; not an image, don't use with max size
	cmp.l d2,d0
	bpl.s .no
	move.l d2,d0					; new max_fsize
.no:
	add.l d2,d1						; new offset
	bra.s .offsets
.save_idx1:
	lea avi_header,a0
	INTEL D0
	move.l d0,144(a0)
	move.l d0,60(a0)				; max frame size
	move.l header_buffer,a0
	add.l d4,a0
	move.l size_ptr,a1
	sub.l a0,a1
	move.l a0,-(sp)
	move.l a1,-(sp)
	move d5,-(sp)				; prepares write
	move #1,-(sp)
	move d5,-(sp)
	clr.l -(sp)
	GEMDOS 66,10					; current position = end of movi section
	move.l d0,d7
	GEMDOS 64,12					; writes the idx1 section
	move #1,-(sp)
	move d5,-(sp)
	clr.l -(sp)
	GEMDOS 66,10					; current position = len of file
	subq.l #8,d0
	INTEL d0
	lea avi_header,a3
	move.l d0,4(a3)				; RIFF len
	move.b #$1,56(a3)				; one stream (images)
	move.l #$c0,d6				; header size
	add.l d4,d6					; plus palette
	tst.b bad_sound
	bne.s .nos1
	add.l #100,d6					; size of sound header
	addq.b #1,56(a3)				; two streams (images + sound)
.nos1:
	sub.l d6,d7
	sub.l #28,d7					; size of movi section
	INTEL d6
	move.l d6,16(a3)
	clr -(sp)
	move d5,-(sp)
	clr.l -(sp)
	GEMDOS 66,10					; start of file
	pea (a3)
	move.l #212,-(sp)			; first part of header
	move d5,-(sp)
	GEMDOS 64,12					; writes it
	tst.b qt_palette
	beq.s .no_pal2
	move.l header_buffer,-(sp)
	move.l #1024,-(sp)
	move d5,-(sp)
	GEMDOS 64,12					; writes the palette
.no_pal2:
	tst.b bad_sound
	bne.s _nos2
	move.l #avi_sound_header,-(sp)
	moveq #100,d0
	move.l d0,-(sp)
	move d5,-(sp)
	GEMDOS 64,12					; writes sound header
	bra.s _nos2

;evnt_button: dc.l eb_cont,global,eb_int,intout,dum,dum
;eb_cont: dc.w 21,3,5,0,0
;eb_int: dc.w 1,1,0

graf_mkstate: dc.l gmk_cont,global,dum,intout,dum,dum
gmk_cont: dc.w 79,0,5,0,0

_nos2:
	lea avi_end_header,a0
	INTEL d7
	move.l d7,4(a0)
	pea (a0)
	move.l #12,-(sp)
	move d5,-(sp)
	GEMDOS 64,12					; writes LIST size movi
	rts


end_of_gif:
	pea .code_end
	moveq #1,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12
	rts
.code_end: dc.b $3B
	even

end_of_flm:
	bsr complete_flm_file
	move.l flm_screen,a2
	bsr mfree
	move.l flm_frame,a2
	bsr mfree
	rts

save_header:
	tst.b slide_gif
	bne.s end_of_gif
	btst #0,mountain
	bne.s .pas_aff3
	moveq #-1,d7
	moveq #12,d6
	bsr manage_tree
.pas_aff3:
	tst.b create_avi
	bne end_of_avi
	tst.b slide_degas
	bne.s end_of_flm
	move #1,-(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS $42,10		; current file position
	move.l d0,dum		; for updating 'mdat' size
	tst key_frame_num
	beq.s .no_key
	bsr.s header_with_key	; upon return, header_size is updated
	move.l a5,-(sp)		; new start of bloc
	bra.s .truc
.no_key:
	move.l header_buffer,-(sp)
.truc:
	move.l header_size,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; writes the buffer!
.next:
	clr -(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS $42,10		; start of file
	move.l #'mdat',dum+4
	pea dum
	move.l #8,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12
	rts

header_with_key:
	move.l header_buffer,a0
	moveq #0,d7
	move key_frame_num,d7
	addq #4,d7
	asl.l #2,d7				; 4*(num + 4) = size added with key section!
	move.l #'moov',d0
	bsr adjust_size
	move.l #'trak',d0
	bsr adjust_size
	move.l #'mdia',d0
	bsr adjust_size
	move.l #'minf',d0
	bsr adjust_size
	move.l #'stbl',d0
	bsr.s adjust_size
.search_stsc:
	cmp.l #'stsc',4(a0)
	beq.s .found
	add.l (a0),a0
	bra.s .search_stsc
.found:
	move.l a0,a5	; saves it
	move.l a0,d0
	sub.l header_buffer,d0	; size that can be saved now
	sub.l d0,header_size		; updates
	move.l header_buffer,-(sp)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; saves the first part
	move.l d7,d6
	bsr.s save_long
	move.l #'stss',d6
	bsr.s save_long
	moveq #0,d6
	bsr.s save_long
	move key_frame_num,d6
	bsr.s save_long
	move.l a5,a0
.search_stsz:
	cmp.l #'stsz',4(a0)
	beq.s .found2
	add.l (a0),a0
	bra.s .search_stsz
.found2:
	lea 16(a0),a4
	move.l (a4)+,d5	; number of frames
	moveq #0,d6			; frame number (counter)
	bra.s .num_loop
.loop:
	addq.l #1,d6
	bclr #7,(a4)
	beq.s .no			; there was no bit, so not a key frame
	bsr.s save_long
.no:
	addq.l #4,a4		; next size
.num_loop:
	subq.l #1,d5
	bpl.s .loop
	rts

adjust_size:
	cmp.l 4(a0),d0
	beq.s .found
	add.l (a0),a0
	bra.s adjust_size
.found:
	add.l d7,(a0)+			; adjusts the size
	addq.l #4,a0			; skips the ID
	rts

save_long:
	move.l d6,.temp
	pea .temp
	moveq #4,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12
	rts
.temp: dc.l 0

parse_command_line:
	cmp.b #32,(a5)+
	beq.s parse_command_line
	move.b -(a5),d0
	bne.s .lbk			; stange end...
	rts
.lbk:
	moveq #-1,d1
	cmp.b #'+',d0
	beq.s .option
	moveq #0,d1
	cmp.b #'-',d0
	bne .file_name
.option:
	addq.l #1,a5
	move.b (a5)+,d0	; name of the option
	or.b #$20,d0		; to lower case
	cmp.b #'d',d0
	bne.s .o1
	move.b d1,cmd_dial
	bra.s parse_command_line
.o1:
	cmp.b #'p',d0
	bne.s .o2
	move.b d1,cmd_play
	bra.s parse_command_line
.o2:
	cmp.b #'s',d0
	bne.s .o3
	move.b d1,cmd_sync
	bra.s parse_command_line
.o3:
	cmp.b #'a',d0
	bne.s .o4
	move.b d1,cmd_alt
	bra.s parse_command_line
.o4:
	cmp.b #'e',d0
	bne.s .o5
	move.b d1,cmd_erro
	bra.s parse_command_line
.o5:
	cmp.b #'i',d0
	bne.s .o6
	move.b d1,cmd_inter
	bra.s parse_command_line
.o6:
	cmp.b #'x',d0
	bne.s .o7
	bsr cmd_get_int
	tst.b is_tt
	beq.s .o6a
	and.b #$F0,d0				; 16 aligned if a TT alone
.o6a:
	move d0,cmd_x
	or.b #$F0,cmd_coord
	bra parse_command_line
.o7:
	cmp.b #'y',d0
	bne.s .o8
	bsr cmd_get_int
	move d0,cmd_y
	or.b #$0F,cmd_coord
	bra parse_command_line
.o8:
	cmp.b #'r',d0
	bne.s .o9
	bsr.s cmd_get_int
	st cmd_return
	move.l d0,cmd_return_adr
	move.l d0,a0
	clr (a0)		; default is 'not found'!!!
	move.l #VERSION,68(a0)	; fills the version number
	bra parse_command_line
.o9:
	cmp.b #'v',d0
	bne.s .o10
	move.b d1,_conv_video
	bra parse_command_line
.o10:
	bra parse_command_line	; unknow option...
.file_name:
	lea full,a0							; the name of the file (or mask)
	lea full2,a1
	move.l a1,a2						; the last '\'
	subq #1,d0
.lb0:
	move.b (a5)+,d1
	move.b d1,(a0)+
	move.b d1,(a1)+					; copies the name
	beq.s .lb2
	cmp.b #'\',d1
	bne.s .lb0
	move.l a1,a2
	bra.s .lb0
.lb2:
	move.l a2,fname_pos
	moveq #-1,d0						; default LOAD mode
	tst.b cmd_dial
	bne.s .exit							; mode +d, so load
	tst.b cmd_alt
	beq.s .exit							; no coonversion wanted anyway, so load
	moveq #0,d0							; else CONVERT mode
.exit:
	move.b d0,menu_flag
	st command							; there's a COMMAND LINE
	rts

cmd_get_int:
	moveq #0,d0
	moveq #0,d1
	move.b (a5)+,d1
	cmp.b #'w',d1
	beq.s .word
	cmp.b #'W',d1
	beq.s .word
	cmp.b #'L',d1
	beq.s .long
	cmp.b #'l',d1
	beq.s .long
	cmp.b #'$',d1
	beq.s .hexa
	bra.s .skip
.lb0:
	move.b (a5)+,d1		; one char
.skip:
	sub.b #'0',d1
	bmi.s .end				; not a digit
	cmp.b #10,d1
	bpl.s .end				; not a digit
	add.l d0,d0
	move.l d0,d2
	add.l d2,d2
	add.l d2,d2
	add.l d2,d0				; d0*10
	add.l d1,d0				; adds this digit
	bra.s .lb0
.end:
	subq.l #1,a5			; back one char
	rts
.word:
	move.b (a5)+,d0
	ror #8,d0
	move.b (a5)+,d0
	rts
.long:
	bsr.s .word
	swap d0
	bra.s .word
.hexa:
	move.b (a5)+,d1		; one char
	or.b #$20,d1			; to lower case
	sub.b #'0',d1
	bmi.s .end				; not a digit
	cmp.b #10,d1
	bmi.s .ok
	sub.b #39,d1
	cmp.b #16,d1
	bpl.s .end
	cmp.b #10,d1
	bmi.s .end
.ok:
	lsl.l #4,d0				; d0*16
	add.l d1,d0				; adds this digit
	bra.s .hexa

install_vectors:
	move.l kvdbbase,a0
	lea old_midi,a1
	move.l (a0),(a1)+
	move.l 12(a0),(a1)+
	move.l 20(a0),(a1)+
	move.l 32(a0),(a1)
	move.l #my_midi,(a0)
	move.l #my_stat,12(a0)
	move.l #my_cloc,20(a0)
	move.l #my_ikbd,32(a0)
	rts

restore_vectors:
	move.l kvdbbase,a0
	lea old_midi,a1
	move.l (a1)+,(a0)
	move.l (a1)+,12(a0)
	move.l (a1)+,20(a0)
	move.l (a1)+,32(a0)
	rts

my_ikbd:
	st inter_flag
	move.l #return,-(sp)
	move.l old_ikbd,-(sp)
	rts
return:
	move sr,-(sp)
	tst.b inter_flag
	beq.s .lb0
	bset #2,([kbshift])
.lb0:
	move (sp)+,sr
	rts

my_midi:
	st inter_flag
	bset #2,([kbshift])
	move.l old_midi,-(sp)
	rts

my_stat:
	sf inter_flag
	move.l old_stat,-(sp)
	rts

my_cloc:
	sf inter_flag
	move.l old_cloc,-(sp)
	rts

planes_display:
	move.l tt_comp,a0
	jsr (a0)
	move max_imagey,a3	; 8 bytes from the upper label
	moveq #0,d0
	move.l image,a0		; 16 bytes from the upper label
	move d0,d1				; 22 bytes from the upper label
	muls alignwidth,d1
	add.l d1,a0
	muls #320,d0
	move.l tt_screen,a1
	add.l d0,a1
	move #320,a4
	sub alignwidth,a4		; row inc
	move a3,d5
	bra .first
.line_loop:
	move alignwidth,d6
	lsr #4,d6
	subq #1,d6
.line:
	movem.l (a0)+,d1-d4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	swap d2
	swap d4
	eor d1,d2
	eor d3,d4
	eor d2,d1
	eor d4,d3
	eor d1,d2
	eor d3,d4
	swap d2
	swap d4
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move d4,(a1)+
	swap d4
	move d2,(a1)+
	swap d2
	move d3,(a1)+
	swap d3
	move d1,(a1)+
	swap d1
	move d4,(a1)+
	move d2,(a1)+
	move d3,(a1)+
	move d1,(a1)+
	dbf d6,.line
	add a4,a1
.first:
	dbf d5,.line_loop
	rts


planes_disp_double:
	move.l tt_comp,a0
	jsr (a0)
	move max_imagey,a3	; 8 bytes from the upper label
	moveq #0,d0
	move.l image,a0		; 16 bytes from the upper label
	move d0,d1				; 22 bytes from the upper label
	muls alignwidth,d1
	add.l d1,a0
	muls #640,d0
	move.l tt_screen,a1
	add.l d0,a1
	move #640,a4
	sub alignwidth,a4		; row inc
	move a3,d5
	lea 320(a1),a3
	bra .first
.line_loop:
	move alignwidth,d6
	lsr #4,d6
	subq #1,d6
.line:
	movem.l (a0)+,d1-d4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	swap d2
	swap d4
	eor d1,d2
	eor d3,d4
	eor d2,d1
	eor d4,d3
	eor d1,d2
	eor d3,d4
	swap d2
	swap d4
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move d4,(a1)+
	move d4,(a3)+
	swap d4
	move d2,(a1)+
	move d2,(a3)+
	swap d2
	move d3,(a1)+
	move d3,(a3)+
	swap d3
	move d1,(a1)+
	move d1,(a3)+
	swap d1
	move d4,(a1)+
	move d2,(a1)+
	move d3,(a1)+
	move d1,(a1)+
	move d4,(a3)+
	move d2,(a3)+
	move d3,(a3)+
	move d1,(a3)+
	dbf d6,.line
	add a4,a1
	add a4,a3
.first:
	dbf d5,.line_loop
	rts

get4on8 MACRO
	move.w (a0)+,\1
	move.b (a0),\1
	swap \1
	addq.l #2,a0
	move.w (a0)+,\1
	move.b (a0),\1
	addq.l #2,a0
	ENDM

planes_disp_half:
	move.l tt_comp,a0
	jsr (a0)
	move max_imagey,a3		; 8 bytes from the upper label
	moveq #0,d0
	move.l image,a0		; 16 bytes from the upper label
	move d0,d1				; 22 bytes from the upper label
	muls alignwidth,d1
	add.l d1,a0
	muls #320,d0
	move.l tt_screen,a1
	add.l d0,a1
	move #640,d0
	sub alignwidth,d0
	asr d0
	move d0,a4
	move a3,d5
	bra .first
.line_loop:
	move alignwidth,d6
	lsr #5,d6
	subq #1,d6
.line:
	get4on8 d1
	get4on8 d2
	get4on8 d3
	get4on8 d4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	swap d2
	swap d4
	eor d1,d2
	eor d3,d4
	eor d2,d1
	eor d4,d3
	eor d1,d2
	eor d3,d4
	swap d2
	swap d4
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move d4,(a1)+
	swap d4
	move d2,(a1)+
	swap d2
	move d3,(a1)+
	swap d3
	move d1,(a1)+
	swap d1
	move d4,(a1)+
	move d2,(a1)+
	move d3,(a1)+
	move d1,(a1)+
	dbf d6,.line
	add a4,a1
.first:
	dbf d5,.line_loop
	rts

mac_date:
	GEMDOS 42,2			; tgetdate
	move d0,d1
	and #$1F,d1			; day
	lsr #5,d0
	move d0,d2
	and #$F,d2			; month
	lsr #4,d0			; year since 1980
	add.w #1980,d0		; absolute year
	moveq #-1,d3
	add d0,d3			; year -1
	moveq #0,d4
	cmp #3,d2
	bmi.s .lb0
	move d0,d3			; year
	move d2,d4
	asl #2,d4			; m * 4
	add.w #23,d4		; m * 4 + 23
	ext.l d4
	divs #10,d4			; int(0,4 * m + 2,3)
	ext.l d4
.lb0:
	muls #365,d0
	subq #1,d2
	muls #31,d2
	add.l d2,d0
	ext.l d1
	add.l d1,d0
	sub.l d4,d0
	asr #2,d3			; int (y(-1) / 4)
	ext.l d3
	add.l d3,d0			; 365Y + 31(M-1) + D + INT(Z/4) - X
	sub.l #695436,d0	; days since 1/1/1904 (you Mac!)
	moveq #24,d7
	muls.l d0,d7		; hours since 1/1/1904
	GEMDOS 44,2			; tgettime
	move d0,d1
	and #$1f,d1
	add d1,d1			; seconds
	lsr #5,d0
	move d0,d2
	and #$3f,d2			; minutes
	lsr #6,d0			; hours
	ext.l d0
	add.l d0,d7			; add the hours
	mulu.l #60,d7		; into minutes
	ext.l d2
	add.l d2,d7			; add the minutes
	mulu.l #60,d7		; into seconds
	ext.l d1
	add.l d1,d7			; add the minutes
	lea date_table,a0
.lb1:
	move.l (a0)+,d0
	beq.s .exit
	move.l d0,a1
	move.l d7,(a1)+
	move.l d7,(a1)
	bra.s .lb1
.exit
	rts
date_table:
	dc.l date1,date2,date3,date4,date5,0


mpg_read_header:
	SEEK #0,0		; start of file
	bsr.l read_long
	cmp.l #$000001b3,d0
	beq.s .ok
	cmp.l #$000001ba,d0
	beq.s .ok1
	moveq #1,d0
.ok:
	rts
.ok1:
	moveq #99,d0
	move d0,sound_bits
	move.l d0,frequency
	st bad_sound
	moveq #0,d0
	rts

seq_read_header:
	SEEK #0,0
	lea cvid_fix0,a3
	pea (a3)
	move.l #128,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	tst.l d0
	bmi .bug
	cmp #$FEDB,(a3)+
	bne .bug
	move #320,max_imagex
	move #200,max_imagey
	addq.l #2,a3
	move.l (a3)+,d1
	move.l d1,sample_num			; number of frames
	move.l d1,d4
	moveq #0,d0
	move (a3)+,d0					; number of VBLs (1/50)
	divs.l #30,d0					; nuber of 1/200 per frame
	move.l d0,_delay
	lsl.l #2,d1						; bytes to load the offset table
	move.l d1,d3					; saves it
	addq.l #4,d1					; plus a dummy value
	bsr.l malloc
	move.l d0,samp_sizes			; the bloc
	move.l d0,a3
	move.l d0,-(sp)
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12					; read the table
	tst.l d0
	bmi.s .bug
	move.l total,(a3,d3.l)		; the last value is the total length
	moveq #0,d0						; max fsize
	move.l (a3)+,d1				; first position
.lb0:
	move.l (a3)+,d2				; next position
	move.l d2,d3
	sub.l d1,d3						; current size
	cmp.l d3,d0
	bpl.s .lb1
	move.l d3,d0					; new max fsize
.lb1:
	move.l d2,d1					; new position
	subq.l #1,d4
	bne.s .lb0						; other size
	addq.l #1,d0
	bclr #0,d0						; word aligned
	move.l d0,max_fsize
	move.l #'seq4',comp_txt
	moveq #0,d0
	rts
.bug:
	moveq #1,d0
	rts

seq_read_data:
	bsr install_traps
.disp_again:
	clr.l disp_frame
	move.l s_buffer_2,a0
	move #3999,d0
.clear:
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	dbf d0,.clear
	bsr v_new_palette
	trap #10
	move.l d0,start_time
	move.l d0,current_time
	bsr.l enh_event0
	move.l samp_sizes,a5		; sizes pointer
.again:
	move.l (a5)+,d0
	cmp.l total,d0					; end of table?
	beq .exit
	move.l (a5),d4
	sub.l d0,d4
	SEEK d0,0						; good position
	move.l d4,bufused				; size to load
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	bsr.s seq_decomp_frame			; and updates the second buffer
	sne d2
	move.l current_time,d1
.delay:
	trap #10
	cmp.l enh_time,d0
	bpl.s .event
	cmp.l d0,d1
	bpl.s .delay
	bra.s .lb0
.event:
	bsr.l enh_event
	bra.s .delay
.lb0:
	add.l _delay,d1
	move.l d1,current_time
	tst.b d2
	bne.s .nop_frame
	bsr seq_read_palette
	bsr seq_disp_image
	tst.b is_vdi
	beq.s .nop_frame
	jsr vdi_display
.nop_frame:
	addq.l #1,disp_frame
	btst #2,([kbshift])
	bne.s .stop
	bra .again
.exit:
	tst.b is_rep
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	bra common_end


seq_decomp_frame:
	cmp.l #129,bufused
	bmi .exit						; only a header!
	move.l buffer,a0				; the frame
	move.l 64(a0),d0				; size of the datas
	beq .exit						; no datas
	lea 128(a0),a1					; the datas
	tst.b 63(a0)
	beq.s .no_comp
	lea (a1,d0.l),a2				; end of datas
	move.l s_buffer,a3
.again:
	cmp.l a2,a1
	bpl.s .end_decomp
	move (a1)+,d0					; code
	bmi.s .run
	subq #1,d0						; for dbf
	move (a1)+,d1					; word to be repeated
.rep:
	move d1,(a3)+
	dbf d0,.rep
	bra.s .again
.run:
	bclr #15,d0
	subq #1,d0
.run_2:
	move (a1)+,(a3)+				; copy
	dbf d0,.run_2
	bra.s .again
.end_decomp:
	move.l s_buffer,a1			; the datas
.no_comp:							; here a1 points to the uncompressed datas
	move 58(a0),d0			; W
	move d0,d1				; saves it
	add #15,d0
	lsr #4,d0				; number of columns of 16 pixels
	move d0,d3				; for TT 16 colors
	move 60(a0),d2			; H
	muls d2,d0				; number of words in one plane
	add.l d0,d0				; number of bytes in one plane
	lea (a1,d0.l),a2
	lea (a2,d0.l),a3
	lea (a3,d0.l),a4		; the other planes
	move.l s_buffer_2,a6
	subq #1,d2				; for the loop
	tst.b 63(a0)
	beq .really_no_comp
	cmp #4,planes			; 320x200x16???
	beq .planes_mode
	add.w 54(a0),a6		; + offs_x
	move 56(a0),d0			; offs_y
	muls #320,d0
	add.l d0,a6				; start into buffer 2
	move.l a6,clip_adr
	move.l a6,-(sp)
.other_column:
	moveq #16,d0
	cmp #16,d1
	bpl.s .ok_all
	move d1,d0
.ok_all:
	sub d0,d1				; those are treated now
	subq #1,d0				; for the loop
	swap d2
	move d0,d2
	swap d2
	swap d0
	move.l a6,-(sp)
	move d2,d0
	tst.b 62(a0)			; copy or XOR?
	bne.s .x_little_line
.little_line:
	swap d0
	move (a1)+,d3
	move (a2)+,d4
	move (a3)+,d5
	move (a4)+,d6
.pixels:
	moveq #0,d7
	lsl d6
	roxl.b d7
	lsl d5
	roxl.b d7
	lsl d4
	roxl.b d7
	lsl d3
	roxl.b d7
	move.b d7,(a6)+
	dbf d0,.pixels
	add.l #320,(sp)
	move.l (sp),a6
	swap d2
	move d2,d0
	swap d2
	swap d0
	dbf d0,.little_line
.common:
	addq.l #4,sp
	addq.l #8,(sp)
	addq.l #8,(sp)
	move.l (sp),a6
	tst d1
	bne.s .other_column
	addq.l #4,sp
	moveq #0,d0
	rts
.exit:
	moveq #1,d0				; a nop frame
	rts
.x_little_line:
	swap d0
	move (a1)+,d3
	move (a2)+,d4
	move (a3)+,d5
	move (a4)+,d6
.x_pixels:
	moveq #0,d7
	lsl d6
	roxl.b d7
	lsl d5
	roxl.b d7
	lsl d4
	roxl.b d7
	lsl d3
	roxl.b d7
	eor.b d7,(a6)+
	dbf d0,.x_pixels
	add.l #320,(sp)
	move.l (sp),a6
	swap d2
	move d2,d0
	swap d2
	swap d0
	dbf d0,.x_little_line
	bra.s .common
.planes_mode:
	move.l a1,d7
	lea mfdb_src,a1
	move.l a6,(a1)+
	move 58(a0),(a1)+
	move d3,d0
	lsl #4,d0
	move d0,(a1)+
	move d3,(a1)+
	moveq #4,d0
	move.l d0,(a1)+	; format 0 + planes 4
	clr.l mfdb_dest	; screen
	subq #1,d3			; for the loop
	move d3,d0			; number of columns-1
	lsl #3,d0			; inc into buffer
	move.l d7,a1
.next:
	move.l a6,a0
	move d2,d1
.one_column:
	move (a1)+,(a0)+
	move (a2)+,(a0)+
	move (a3)+,(a0)+
	move (a4)+,(a0)+
	add d0,a0
	dbf d1,.one_column
	addq.l #8,a6
	dbf d3,.next
	moveq #0,d0
	rts
.really_no_comp:
	cmp #4,planes
	bne.s .no_planes
	move.l a1,d7
	lea mfdb_src,a1
	move.l d7,(a1)+
	move 58(a0),(a1)+
	move d3,d0
	lsl #4,d0
	move d0,(a1)+
	move d3,(a1)+
	moveq #4,d0
	move.l d0,(a1)+
	clr.l mfdb_dest	; screen
	moveq #0,d0
	rts
.no_planes:
	move.l s_buffer_2,a6
	add.w 54(a0),a6		; + offs_x
	move 56(a0),d0			; offs_y
	muls #320,d0
	add.l d0,a6				; start into buffer 2
	move.l a6,clip_adr
	move.l d1,a3			; W
.nc_other_line:
	move.l a6,a4
	moveq #0,d1				; no pixels yet
.nc_16_pix:
	moveq #16,d0
	add d0,d1
	cmp d1,a3
	bpl.s .nc_ok_all
	sub a3,d1
	sub d1,d0
	move d3,d1
.nc_ok_all:
	movem (a1)+,d3-d6
	subq #1,d0
.nc_pixels:
	moveq #0,d7
	lsl d6
	roxl.b d7
	lsl d5
	roxl.b d7
	lsl d4
	roxl.b d7
	lsl d3
	roxl.b d7
	move.b d7,(a6)+
	dbf d0,.nc_pixels
	cmp d1,a3
	bne.s .nc_16_pix
	lea 320(a4),a6
	dbf d2,.nc_other_line
	moveq #0,d0
	rts

vro_cpyfm: dc.l vcp_cont,vcp_int,vcp_ptsin,dum,dum
vcp_cont: dc.w 109,4,0,1,0,0,0
				dc.l mfdb_src,mfdb_dest

seq_read_palette:
	move.l buffer,a0
	addq.l #4,a0

kin_read_palette:
	lea cvid_fix0,a6
	move.l a6,a2
	moveq #15,d0
	moveq #0,d3			; no palette change (default)
	move #$FFF,d2
	cmp #9,planes
	bmi.s .not_tc
	lea 32(a2),a3
	lea cvid_fix1,a1
.lb0:
	move (a0)+,d1
	and d2,d1
	cmp (a3),d1
	beq.s .equal
	move d1,(a3)
	addq #1,d3			; palette has changed
.equal:
	addq.l #2,a3
	move (a1,d1.w*2),(a2)+
	dbf d0,.lb0
	move.b d3,pal_change
	rts
.not_tc:
	tst.b is_tt
	beq.s .vdi_call
.tt_xbios:
	move (a0)+,d1		; one color
	cmp (a2),d1			; equals the old one?
	beq.s .eq_2			; yes
	move d1,(a2)		; else, updates
	addq #1,d3			; palette change!
.eq_2:
	addq.l #2,a2
	dbf d0,.tt_xbios
	tst.b d3
	beq.s .exit
	move.l a6,-(sp)
	XBIOS 6,6			; set palette
.exit:
	rts
.vdi_call:
	move (a0)+,d1		; one color
	cmp (a2),d1			; equals the old one?
	beq.s .eq_3			; yes
	move d1,(a2)		; else, updates
	movem.l d0/d2/a0/a2,-(sp)
	lea vs_int,a0
	moveq #15,d2
	sub d0,d2
	move (indexs,d2.w*2),(a0)+	; index
	move d1,d0
	and #$888,d0
	lsr #3,d0
	and #$777,d1
	add d1,d1
	add d0,d1
	bfextu d1{20:4},d0
	muls #66,d0
	move d0,(a0)+
	bfextu d1{24:4},d0
	muls #66,d0
	move d0,(a0)+
	and #$f,d1
	muls #66,d1
	move d1,(a0)
	GEM_VDI vs_color
	movem.l (sp)+,d0/d2/a0/a2
.eq_3:
	addq.l #2,a2
	dbf d0,.vdi_call
	rts

seq_disp_image:
	cmp #4,planes
	beq .st_low
	move.l image,a3
	move screenw,d3
	cmp #9,planes
	bmi .not_tc
	tst.b pal_change
	beq.s	.clip
	sub #320,d3
	add d3,d3
	move.l s_buffer_2,a0
	moveq #0,d0
	move #199,d1
.line:
	moveq #79,d2
.pixels:
	rept 4
	move.b (a0)+,d0
	move (a6,d0.w*2),(a3)+
	endr
	dbf d2,.pixels
	add d3,a3
	dbf d1,.line
	rts
.clip:
	move.l clip_adr,a0
	move.l buffer,a1
	move 56(a1),d0
	muls d3,d0
	move 54(a1),d1
	ext.l d1
	add.l d1,d0
	add.l d0,d0
	add.l d0,a3		; new address into video RAM
	move 58(a1),d0	; L
	sub d0,d3
	add d3,d3		; inc for video RAM
	move #320,d1
	sub d0,d1		; inc for buffer
	move 60(a1),d7	; H
	subq #1,d7		; for the loop
	subq #1,d0		; for the loop
	moveq #0,d6
.loop:
	move d0,d2
.c_line:
	move.b (a0)+,d6
	move (a6,d6.w*2),(a3)+
	dbf d2,.c_line
	add d1,a0
	add d3,a3
	dbf d7,.loop
	rts
.not_tc:
	move.l clip_adr,a0
	move.l buffer,a1
	move 56(a1),d0
	muls d3,d0
	move 54(a1),d1
	ext.l d1
	add.l d1,d0
	add.l d0,a3		; new address into video RAM
	move 58(a1),d0	; L
	sub d0,d3		; inc for video RAM
	move #320,d1
	sub d0,d1		; inc for buffer
	move 60(a1),d7	; H
	subq #1,d7		; for the loop
	subq #1,d0		; for the loop
.ntc_loop:
	move d0,d2
.ntc_line:
	move.b (a0)+,(a3)+
	dbf d2,.ntc_line
	add d1,a0
	add d3,a3
	dbf d7,.ntc_loop
	rts
.st_low:
	move.l buffer,a0
	move.l 54(a0),d0
	move.l 58(a0),d1
	moveq #$3,d2
	lea vcp_int,a1
	tst.b 62(a0)
	beq.s .st_copy
	moveq #$6,d2
.st_copy:
	move d2,(a1)+
	clr.l (a1)+
	sub.l #$10001,d1
	move.l d1,(a1)+
	move.l d0,(a1)+
	add.l d0,d1
	move.l d1,(a1)
	GEM_VDI vro_cpyfm
	rts

kin_read_header:
	SEEK #0,0
	lea cvid_fix0+64,a3	; jumps over the other palettes
	pea (a3)
	moveq #64,d3
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d0,d3
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	cmp.l #$27182818,48(a3)	; magic?
	bne.s .bug
	move (a3),d0
	ext.l d0
	move.l d0,sample_num		; number of frames
	move 40(a3),d0
	move d0,max_imagex
	move 42(a3),d1
	move d1,max_imagey
	add #15,d0
	and #$FFF0,d0				; word aligned
	muls d1,d0
	lsr.l #1,d0					; bytes for one frame
	move.l d0,max_fsize
	move.l #'kin4',comp_txt
	st samp_sizes
	moveq #100,d0
	sub 34(a3),d0				; number of 1/60 per frame
	muls #10,d0
	divs.l #3,d0				; number of 1/200 per frame
	move.l d0,_delay
	cmp #2,38(a3)
	seq reverse_flag
	moveq #0,d0
	rts

kin_read_data:
	bsr install_traps
	sf reverse_flag+1
	tst.b is_tt
	beq.s .other
	lea vcp_int,a1
	move #3,(a1)+
	clr.l (a1)+
	move max_imagex,d0
	swap d0
	move max_imagey,d0
	sub.l #$10001,d0
	move.l d0,(a1)+
	move.l offsx,d1
	swap d1
	move offsy,d1
	move.l d1,(a1)+
	add.l d0,d1
	move.l d1,(a1)+
	lea mfdb_src,a1
	move.l buffer,(a1)+
	add.l #$10001,d0
	move.l d0,(a1)+
	swap d0
	add #15,d0
	lsr #4,d0
	move d0,(a1)+
	moveq #4,d0
	move.l d0,(a1)+
.other:
	SEEK #2,0
	lea cvid_fix0,a5
	pea 64(a5)
	move.l #32,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	bsr v_new_palette
	lea 64(a5),a0	; palette loaded
	bsr kin_read_palette
.disp_again:
	trap #10
	move.l d0,start_time
	move.l d0,current_time
	bsr.l enh_event0
	clr.l disp_frame
	cmp #-1,reverse_flag
	bne.s .kaz
	move.l max_fsize,d0	; if reverse, goes back 2 frames
	add.l d0,d0
	sub.l d0,a5
	bra.s	.again
.kaz:
	move.w #64,a5			; current position (‚tendu … LONG)
.again:
	move.l a5,d5
	move.l max_fsize,d4
	cmp #-1,reverse_flag
	bne.s .forward
	cmp.l #64,a5
	bmi .exit
	sub.l d4,d5
	bra.s .common
.forward:
	add.l d4,d5
	cmp.l total,d5					; end of table?
	bgt .exit						; not more frames
.common:
	SEEK a5,0						; good position
	move.l d5,a5					; new position
	move.l d4,bufused				; size to load
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l current_time,d1
.delay:
	trap #10
	cmp.l enh_time,d0
	bpl.s .event
	cmp.l d0,d1
	bpl.s .delay
	bra.s .lb0
.event:
	bsr.l enh_event
	bra.s .delay
.lb0:
	add.l _delay,d1
	move.l d1,current_time
	bsr.s kin_disp_image
		tst.b is_vdi
		beq.s .no_vdi
		movem.l a0-a4/d0-d6,-(sp)
		jsr vdi_display
		movem.l (sp)+,a0-a4/d0-d6
.no_vdi:
	addq.l #1,disp_frame
	btst #2,([kbshift])
	bne.s .stop
	bra .again
.exit:
	lea reverse_flag,a0
	tst.b (a0)+
	beq.s .zak
	tst.b (a0)
	beq.s .rev
	sf (a0)
	bra.s .zak
.rev:
	st (a0)
	bra .disp_again
.zak:
	tst.b is_rep
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	bra common_end


kin_disp_image:
	cmp #4,planes
	bne.s buffer_to_tc_256
	clr.l mfdb_dest
	GEM_VDI vro_cpyfm
	rts

buffer_to_tc_256:
	move.l buffer,a0		; keep those 6 bytes first (VMAS)
_buf_to_tc_256:
	move.l a5,-(sp)
	move.l image,a3
	move screenw,d3
;	move max_imagex,d0
	move alignwidth,d0
	sub d0,d3
	move d3,a5
	move max_imagey,d6
	subq #1,d6
	cmp #16,planes
	bne .last
	lea cvid_fix0,a6		; the palette
	add a5,a5				; inc for Video ram
	lea .little_buf+16(pc),a2
.next:
	move max_imagex,d5
.line:
	moveq #16,d1
	cmp d1,d5
	bpl.s .enough
	move d5,d1
.enough:
	sub d1,d5
	move (a0)+,d4
	move (a0)+,d2
	move (a0)+,d3
	move (a0)+,d1
	move #$5555,d0
	sp_16.w d1,d3,1
	sp_16.w d2,d4,1
	move #$3333,d0
	sp_16.w d1,d2,2
	sp_16.w d3,d4,2
	swap d3
	swap d1
	move d4,d3
	move d2,d1
	move.l #$1E1E1E1E,d0
	move.l d1,d2
	move.l d3,d4
	add.l d1,d2
	add.l d3,d4		; double for A6 index
	and.l d0,d2
	and.l d0,d4
	lsr.l #3,d1
	lsr.l #3,d3
	and.l d0,d1
	and.l d0,d3
	move.l #$00ff00ff,d0
	sp_16.l d1,d3,8
	sp_16.l d2,d4,8
	moveq #0,d7
	movem.l d1-d4,-(a2)
	moveq #0,d0
	move.b (a2)+,d7
	rept 7
		move.b (a2)+,d0
		move 0(a6,d7.w),(a3)+
		move.b (a2)+,d7
		move 0(a6,d0.w),(a3)+
	endr
	move.b (a2)+,d0
	move 0(a6,d7.w),(a3)+
	move 0(a6,d0.w),(a3)+
	tst d5
	bne .line
	add a5,a3
	dbf d6,.next
	move.l (sp)+,a5
	rts
.last:
	move max_imagex,d5
.l_line:
	moveq #16,d1
	cmp d1,d5
	bpl.s .l_enough
	move d5,d1
.l_enough:
	sub d1,d5
	move (a0)+,d4
	move (a0)+,d2
	move (a0)+,d3
	move (a0)+,d1
	move #$5555,d0
	sp_16.w d1,d3,1
	sp_16.w d2,d4,1
	move #$3333,d0
	sp_16.w d1,d2,2
	sp_16.w d3,d4,2
	swap d3
	swap d1
	move d4,d3
	move d2,d1
	move.l #$0F0F0F0F,d0
	move.l d1,d2
	move.l d3,d4
	and.l d0,d2
	and.l d0,d4
	lsr.l #4,d1
	lsr.l #4,d3
	and.l d0,d1
	and.l d0,d3
	move.l #$00ff00ff,d0
	sp_16.l d1,d3,8
	sp_16.l d2,d4,8
	movem.l d1-d4,(a3)
	add.w #16,a3
	tst d5
	bne .l_line
	add a5,a3
	dbf d6,.last
	move.l (sp)+,a5
	rts
.little_buf: dc.l 0,0,0,0

dlt_read_header:
	cmp.l #32034,total		; pi1 file must be >= 32034 bytes
	bpl.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	SEEK #0,0
	move.l #cvid_fix0,a3
	move.l a3,-(sp)
	moveq #34,d4
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d4,d0
	bne.s .bug
	tst.w (a3)+
	bne.s .bug		; first word is 0 (ST Low)
	moveq #15,d0
.lb0:
	and.w #$F000,(a3)+	; the palette is 0xxx
	bne.s .bug
	dbf d0,.lb0				; after that, the first file is considered as a PI1 file
	move.l fname_pos,a0
.lb1:
	move.b (a0)+,d0		; one character of the name
	beq.s .lb2				; end reached, no extension
	cmp.b #'.',d0
	bne.s .lb1
.lb2:
	subq #1,a0
	move.l #'.DLT',(a0)+	; new extension
	clr.b (a0)				; end of string
	move.l #32034,d1
	bsr.l malloc
	move.l d0,s_buffer	; first image (PI1)
	lea full2,a0			; to load the DLT file !!
	jsr load_one_file			; return d6=size, a3=buffer+8 extra bytes
								; return MI if bug
	bmi .bug
	move.l a3,s_buffer_2
	clr.l (a3,d6.l)
	clr.l 4(a3,d6.l)		; the dummy value (0 for the end)
	moveq #1,d0				; number of frames (1 for the PI1 file)
.lb3:
	move (a3)+,d1
	beq.s .lb4
	addq.l #1,d0
	muls #6,d1
	add.l d1,a3
	bra.s .lb3
.lb4:
	move.l d0,sample_num
	move #320,max_imagex
	move #200,max_imagey
	move.l #'dlt4',comp_txt
	st samp_sizes
	moveq #13,d0
	move.l d0,_delay
	move.l #32000,max_fsize	; the screen buffer (if 256 or TC)
	moveq #0,d0
	rts

dlt_read_data:
	bsr install_traps
	SEEK #0,0
	move.l s_buffer,a3
	move.l a3,-(sp)
	move.l #32034,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; reads the whole pi1 file
	bsr v_new_palette
	lea 2(a3),a0			; points to the palette
	bsr kin_read_palette
.disp_again:
	clr.l disp_frame
	trap #10
	move.l d0,start_time
	move.l d0,current_time
	bsr.l enh_event0
	move.l buffer,a0		; the screen
	move.l s_buffer,a1	; the pi1
	lea 34(a1),a1			; to the image
	move #999,d0
.clear:
	movem.l (a1)+,d1-d4
	movem.l d1-d4,(a0)
	lea 16(a0),a0
	movem.l (a1)+,d1-d4
	movem.l d1-d4,(a0)
	lea 16(a0),a0
	dbf d0,.clear
	lea cvid_fix0+1024,a4	; line flags
	moveq #49,d0
	moveq #-1,d1
.flags:
	move.l d1,(a4)+			; every line has changed!
	dbf d0,.flags
	move.l s_buffer_2,a5		; dlt pointer
	bra.s .first_time
.again:
	bsr.s dlt_decomp_frame
	beq.s .exit					; EQ if last frame
	move.l current_time,d1
.delay:
	trap #10
	cmp.l enh_time,d0
	bpl.s .event
	cmp.l d0,d1
	bpl.s .delay
	bra.s .lb0
.event:
	bsr.l enh_event
	bra.s .delay
.lb0:
	add.l _delay,d1
	move.l d1,current_time
.first_time:
	tst.b is_tt
	bne.s .no_disp
	bsr.s dlt_disp_image
.no_disp:
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	addq.l #1,disp_frame
	btst #2,([kbshift])
	bne.s .stop
	bra.s .again
.exit:
	tst.b is_rep
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	bra common_end


dlt_decomp_frame:
	move.w (a5)+,d0		; number of places to modify
	bne.s .lb0
	rts						; if 0, returns EQ
.lb0:
	subq #1,d0
	move.l buffer,a0
	lea cvid_fix0+1023,a4	; flags for each line
	moveq #0,d3					; first offset
.lb1:
	move (a5)+,d1
	cmp d3,d1
	bmi.s .same_line
.next:
	add #160,d3					; next offset
	addq.l #1,a4
	cmp d3,d1
	bpl.s .next
	st (a4)
.same_line:
	move.l (a5)+,d2
	eor.l d2,(a0,d1.w)
	dbf d0,.lb1
	moveq #1,d0				; returns NE
	rts

dlt_disp_image:
	move.l image,a3
	move screenw,d3
	move #320,d0
	sub d0,d3
	move #200,a2
	move.l buffer,a0
	lea cvid_fix0+1024,a4	; the flags for each line
	cmp #16,planes
	bne.s .last
	lea cvid_fix0,a6		; the palette
	add d3,d3				; inc for Video ram
.next:
	tst.b (a4)				; this line has changed?
	bne.s .yes
	lea 160(a0),a0
	lea 640(a3),a3
	bra.s .skip_line
.yes:
	move #320,d0
.line:
	moveq #16,d1
	sub d1,d0
	subq #1,d1
	movem.w (a0)+,d4-d7	; the four planes
	swap d0
.pixels:
	clr d0
	lsl d7
	roxl.b d0
	lsl d6
	roxl.b d0
	lsl d5
	roxl.b d0
	lsl d4
	roxl.b d0
	move (a6,d0.w*2),(a3)+
	dbf d1,.pixels
	swap d0
	tst d0
	bne.s .line
.skip_line:
	sf (a4)+		; resets for the future
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .next
	rts
.last:
	tst.b (a4)				; this line has changed?
	bne.s .l_yes
	lea 160(a0),a0
	lea 320(a3),a3
	bra.s .l_skip_line
.l_yes:
	move #320,d0
.l_line:
	moveq #16,d1
	sub d1,d0
	subq #1,d1
	movem.w (a0)+,d4-d7	; the four planes
	swap d0
.l_pixels:
	clr d0
	lsl d7
	roxl.b d0
	lsl d6
	roxl.b d0
	lsl d5
	roxl.b d0
	lsl d4
	roxl.b d0
	move.b d0,(a3)+
	dbf d1,.l_pixels
	swap d0
	tst d0
	bne.s .l_line
.l_skip_line:
	sf (a4)+
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .last
	rts

flm_read_header:
	SEEK #0,0
	lea cvid_fix0,a3
	pea (a3)
	moveq #68,d7
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp d0,d7
	beq.s .lb0
.bug:
	moveq #1,d0
	rts
.lb0:
	move.l (a3),d0
	cmp.l total,d0				; total size correct?
	bne.s .bug
	cmp.l #$00010000,48(a3)	; magic
	bne.s .bug
	move.l 8(a3),max_fsize
	move.l 12(a3),sample_num
	move 52(a3),d0
	move d0,max_imagex
	swap d0
	move 54(a3),d0
	move d0,max_imagey
	moveq #0,d1
	move.l #16000,d2
	move.l #32000,d3
	cmp.l #$14000c8,d0		; st_low
	beq.s .found
	moveq #1,d1
	cmp.l #$28000c8,d0		; st med
	beq.s .found
	moveq #2,d1
	cmp.l #$2800190,d0		; st high
	beq.s .found
	moveq #4,d1
	move.l #76800,d2
	move.l #153600,d3
	cmp.l #$28001e0,d0		; tt med
	bne.s .zglity
	cmp.b #4,57(a3)			; 4 plans?
	beq.s .found
	add.l d2,d2
	add.l d3,d3
	cmp.b #8,57(a3)			; VGA 256c
	beq.s .found
.zglity:
	moveq #7,d1
	cmp.l #$14001e0,d0		; tt low
	beq.s .found
.no_more:
	moveq #-1,d1
	st bad_comp					; unsupported!
.found:
	move d1,tt_res
	move.l d2,tt_flag_size
	move.l d3,tt_screen_size
	move.l #'flm0',d0
	add.b 57(a3),d0			; flm1, 2, 4, 8, 16...
	move.l d0,comp_txt
	move 66(a3),d0
	move d0,mapused		; number of colors
	add d0,d0				; palette size
	add #68,d0				; plus header
	ext.l d0
	add.l 4(a3),d0			; plus extra infos
	move.l d0,snd_pos		; offset for the first frame
	addq.l #4,snd_pos		; next time we won't read the lenght
	SEEK d0,0				; go there
	pea snd_tt_end
	moveq #4,d7
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read size of first frame!
	cmp.l d0,d7
	bne .bug
	st samp_sizes
	SEEK #8,1
	pea dum
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12		; reads 'time' id or else
	cmp.l d0,d7
	bne .bug
	move.l #13,_delay
	move.l dum,d0
	or.l #$20202020,d0
	cmp.l #'time',d0
	beq.s .extended
	moveq #0,d0
	rts
.extended:
	tst.l 4(a3)	; no extra datas
	beq .exit
	move mapused,d0
	add d0,d0
	add #68,d0
	ext.l d0
	SEEK d0,0				; place for extra infos
.again:
	move.l d0,flm_snd_pos
	bsr.l read_len_id
	or.l #$20202020,d0	; the ID
	cmp.l #'dsnd',d0		; dma sound extension?
	bne.s .next_bloc
	bsr.l read_len_id
	move d0,d1
	swap d1
	move.l d1,flm_snd_size
	swap d0
	move.b d0,d1
	ext.w d1
	move d1,channels		; 1 or 2
	move #8,sound_bits
	lsr #8,d0				; frequency
	and.b #3,d0
	move.l #12517,d1
	subq #1,d0
	beq.s .found_f
	move.l #25033,d1
	subq #1,d0
	beq.s .found_f
	add.l d1,d1
	subq #1,d0
	beq.s .found_f
	clr.l d0
	st bad_sound
.found_f:
	move.l d1,frequency
	add.l #14,flm_snd_pos	; id+len+byte+byte+len
	bra.s .exit
.next_bloc:
	tst.l d1
	beq.s .exit				; no more blocs
	SEEK d1,1				; skips the bloc
	bra .again
.exit:
	moveq #-1,d0
	rts

flm_step_mode:
	move.l snd_size,d5
	move.l buffer,a3
	move.l a3,-(sp)
	move.l d5,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read one frame
	move.l -4(a3,d5.l),snd_size	; size of the next frame
	bsr flm_decomp_frame
	beq.s .nothing
	tst.b is_tt
	bne.s .nothing
	move.l d7,-(sp)
	bsr flm_disp_image
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	move.l (sp)+,d7
.nothing:
	bsr inc_frame
	beq.s .quit
	bpl.s .loop
	bsr save_frame
	bmi.s .nothing
.loop:
	subq.l #1,d7
	bne.s flm_step_mode
.quit:
	bsr close_step_dialog
	rts


flm_read_data:
	cmp.l #'flm1',comp_txt
	bne.s .colors
	tst.b is_tt
	beq.s .other
	pea .ttpal(pc)
	XBIOS 38,6
	bra .again
.ttpal:	
	clr $ffff8240.w
	move #$FFF,$ffff8242.w
	rts
.other:
	cmp #8,planes
	bne .again
	lea vs_int,a3
	clr.l (a3)+
	clr.l (a3)+
	GEM_VDI vs_color
	move #1000,d0
	move d0,-(a3)
	move d0,-(a3)
	move d0,-(a3)
	moveq #1,d0
	move d0,-(a3)
	GEM_VDI vs_color
	bra.s .again
.colors:
	SEEK #68,0
	lea cvid_fix0+64,a3
	move mapused,d0
	add d0,d0
	ext.l d0
	pea (a3)
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp #17,mapused
	bmi.s .old
	bsr flm_pal_256
	bra.s .again
.old:
	bsr v_new_palette
	move.l a3,a0
	bsr kin_read_palette
.again:
	move.l snd_pos,d0
	SEEK d0,0				; first frame
	move.l snd_tt_end,snd_size	; size of 1st frame
	move.l s_buffer,a0
	move.l s_buffer_2,a1
	moveq #-1,d1
	move.l tt_screen_size,d0
	asr.l #4,d0
	subq #1,d0
.clear:
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	clr.l (a0)+
	move.l d1,(a1)+
	move.l d1,(a1)+
	dbf d0,.clear
	move.l sample_num,d7	; number of frames
	clr.l disp_frame
	tst.b step_mode
	bne flm_step_mode
	bsr install_traps
	trap #10
	move.l d0,start_time
	move.l d0,current_time
	bsr.l enh_event0
.lb0:
	move.l snd_size,d5
	move.l buffer,a3
	move.l a3,-(sp)
	move.l d5,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read one frame
	move.l -4(a3,d5.l),snd_size	; size of the next frame
	bsr flm_decomp_frame
	move ccr,d2
	tst.l disp_frame
	bne.s .not_first
	trap #10
	move.l d0,start_time
	move.l d0,current_time
	tst.b playing
	beq.s .not_first
	pea flm_start_sound
	XBIOS 38,6
.not_first:
	move d2,ccr
	beq.s .nothing
	tst.b is_tt
	bne.s .nothing
	move.l d7,-(sp)
	bsr flm_disp_image
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	move.l (sp)+,d7
.nothing:
	addq.l #1,disp_frame
	move.l buffer,a3
	move.l 8(a3),d0
	or.l #$20202020,d0
	cmp.l #'time',d0
	bne.s .old_delay
	tst.b sync
	beq.s .common			; no synchro wanted
	move.l 12(a3),d0
	move.l d0,d1			; STE time
	tst.b real_freq
	beq.s .falc_adjust
	lsr.l #8,d1
	sub.l d1,d0
	lsr.l #2,d1
	sub.l d1,d0
	lsr.l d1
	sub.l d1,d0				; TT time (1-1/256-1/1024-1/2048)
	bra.s .adjusted
.falc_adjust:
	lsr.l #6,d1
	add.l d1,d0
	lsr.l #3,d1
	add.l d1,d0
	lsr.l #2,d1
	add.l d1,d0				; Falcon time (1+1/64+1/512+1/2048)
.adjusted:
	move.l start_time,d1
	add.l d0,d1
.new_delay:
	trap #10
	cmp.l enh_time,d0
	bpl.s .event1
	cmp.l d0,d1
	bpl.s .new_delay
	bra.s .common
.event1:
	bsr.l enh_event
	bra.s .new_delay
.old_delay:
	move.l current_time,d1
.delay:
	trap #10
	cmp.l enh_time,d0
	bpl.s .event2
	cmp.l d0,d1
	bpl.s .delay
	bra.s .lb00
.event2:
	bsr.l enh_event
	bra.s .delay
.lb00:
	add.l _delay,d1
	move.l d1,current_time
.common:
	move.l kbshift,a0
	btst #2,(a0)
	bne.s .stop
	subq.l #1,d7			; one frame less
	bne .lb0				; not ended
	tst.b playing
	beq.s .no_sound
.wait_sound:
	tst.b snd_value
	bmi.s .wait_dma
	tst.b yamaha_flag
	beq.s .no_sound
	bra.s .is_key
.wait_dma:
	trap #11
	beq.s .no_sound
.is_key:
	btst #2,(a0)			; control?
	bne.s .stop
	bra.s .wait_sound
.no_sound:
	tst.b is_rep
	bne .again
	bra.s .normal_out
.stop:
	st stopped
	tst.b playing
	beq.s .normal_out
	bsr stop_all_sounds
.normal_out:
	bra common_end


flm_pal_256:
	lea cvid_fix1+8192,a4
	move #$fff,d3
	move #255,d4
	cmp #16,planes
	bne.s .not_tc
	lea cvid_fix0,a6
	lea 64(a6),a3
.lb0:
	move (a3)+,d1
	and d3,d1
	move (a4,d1.w*2),(a6)+
	dbf d4,.lb0
	rts
.not_tc:
	lea cvid_fix0+64,a3
	lea indexs,a5
.lb1:
	move (a3)+,d1
	and d3,d1
	tst.b is_tt
	beq.s .not_tt
	move d1,-(sp)
	move #255,d1
	sub d4,d1
	move d1,-(sp)
	XBIOS 83,6
	dbf d4,.lb1
	rts
.not_tt:
	lea vs_int,a0
	move (a5)+,(a0)+
	move d1,d0
	lsr #8,d0
	muls #66,d0
	move d0,(a0)+
	move d1,d0
	lsr #4,d0
	and #$f,d0
	muls #66,d0
	move d0,(a0)+
	and #$f,d1
	muls #66,d1
	move d1,(a0)
	GEM_VDI vs_color
	dbf d4,.lb1
	rts

; returns EQ if nothing to do

flm_decomp_frame:
	cmp.l #20,d5
	bpl.s .ok
.nothing:
	moveq #0,d0
	rts				; a nop frame???
.ok:
	lea 4(a3),a2
	add.l (a2)+,a2
	move.l (a2)+,d0
	bmi.s .nothing
	exg.l a2,a3
	add.l (a3)+,a2
	subq.l #4,a2
	move.l s_buffer,a0	; the screen (or buffer)
	move.l s_buffer_2,a1	; the flags for words that changed
	add.l d0,a0				; plus the offset
	lsr.l d0
	add.l d0,a1				; idem in the flags
.lb0:
	moveq #0,d0
	move.b (a3)+,d0		; one code
	bmi.s .lb1
	moveq #0,d1
	move.b (a3)+,d1		; second code
	move d1,d3
.loop:
	move (a2)+,d2
	eor d2,(a0)+
	st (a1)+
	dbf d1,.loop
	lea (a0,d0.w*2),a0
	add d0,a1
	bra.s .lb0
.lb1:
	bclr #7,d0				; normal code
	cmp #$7d,d0
	bmi.s .lb2
	beq.s .end
	move.l (a2)+,d0
	add.l d0,a0
	lsr.l d0
	add.l d0,a1
	bra.s .lb0
.lb2:
	move d3,d1
	bra.s .loop
.end:
	moveq #1,d0
	rts

flm_disp_image:
	move.l s_buffer,a0		; the words
	move.l s_buffer_2,a1		; the flags
	move.l image,a3
	move screenw,d3
	move max_imagex,d0
	sub d0,d3
	move max_imagey,a2
	cmp #16,planes
	bne.s .not_tc
	lea cvid_fix0,a6		; the palette
	add d3,d3				; inc for Video ram
.not_tc:
	move tt_res,d0
	cmp #2,d0
	beq flm_st_high
	cmp #7,d0
	beq flm_tt_low
	cmp #16,planes			; here ST low or TT med (16 colors)
	bne.s .last_0
	cmp #4,d0
	bne.s .next
	cmp.l #'flm8',comp_txt
	beq flm_vga_256
	cmp #640,screenw
	bmi flm_tt_mid_half
.next:
	move max_imagex,d0
.line:
	moveq #16,d1
	cmp d1,d0
	bpl.s .enough
	move d0,d1
.enough:
	sub d1,d0
	tst.l (a1)
	bne.s .changed
	addq.l #8,a0			; skips 4 planes
	add d1,d1
	add d1,a3				; and 16 (or else) pixels
	bra.s .skip
.changed:
	clr.l (a1)
	subq #1,d1
	swap d0
	movem.w (a0)+,d4-d7	; the four planes
.pixels:
	clr d0
	lsl d7
	roxl.b d0
	lsl d6
	roxl.b d0
	lsl d5
	roxl.b d0
	lsl d4
	roxl.b d0
	move (a6,d0.w*2),(a3)+
	dbf d1,.pixels
	swap d0
.skip:
	addq.l #4,a1
	tst d0
	bne.s .line
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .next
	rts
.last_0:
	cmp #4,d0
	bne.s .last
	cmp.l #'flm8',comp_txt
	beq flm_vga_256
.last:
	move d3,a5
	move a2,d6
	subq #1,d6
.last_2:
	move max_imagex,d5
.l_line:
	moveq #16,d1
	cmp d1,d5
	bpl.s .l_enough
	move d5,d1
.l_enough:
	sub d1,d5
	tst.l (a1)
	bne.s .l_changed
	addq.l #8,a0
	add d1,a3
	bra .l_skip
.l_changed:
	clr.l (a1)
	move (a0)+,d4
	move (a0)+,d2
	move (a0)+,d3
	move (a0)+,d1
	move #$5555,d0
	sp_16.w d1,d3,1
	sp_16.w d2,d4,1
	move #$3333,d0
	sp_16.w d1,d2,2
	sp_16.w d3,d4,2
	swap d3
	swap d1
	move d4,d3
	move d2,d1
	move.l #$0F0F0F0F,d0
	move.l d1,d2
	move.l d3,d4
	and.l d0,d2
	and.l d0,d4
	lsr.l #4,d1
	lsr.l #4,d3
	and.l d0,d1
	and.l d0,d3
	move.l #$00ff00ff,d0
	sp_16.l d1,d3,8
	sp_16.l d2,d4,8
	movem.l d1-d4,(a3)
	add.w #16,a3
.l_skip:
	addq.l #4,a1
	tst d5
	bne .l_line
	add a5,a3
	dbf d6,.last_2
	rts
flm_tt_mid_half:
	move.l physbase,a3
	move screenh,d1
	sub #240,d1
	bpl.s .lb0
	moveq #0,d1
.lb0:
	asr d1
	move screenw,d0
	muls d0,d1
	sub #320,d0
	move d0,d3
	add d3,d3
	asr d0
	ext.l d0
	add.l d0,d1
	add.l d1,d1
	add.l d1,a3		; start in screen
.next:
	move #640,d0
.line:
	moveq #16,d1
	cmp d1,d0
	bpl.s .enough
	move d0,d1
.enough:
	sub d1,d0
	tst.l (a1)
	bne.s .changed
	addq.l #8,a0			; skips 4 planes
	add d1,a3				; and 8 (or else) pixels
	bra.s .skip
.changed:
	clr.l (a1)
	subq #1,d1
	swap d0
	movem.w (a0)+,d4-d7	; the four planes
.pixels:
	clr d0
	lsl d7
	roxl.b d0
	lsl d6
	roxl.b d0
	lsl d5
	roxl.b d0
	lsl d4
	roxl.b d0
	move (a6,d0.w*2),(a3)+
	subq #1,d1				; skips one pixel
	lsl d7
	lsl d6
	lsl d5
	lsl d4
	dbf d1,.pixels
	swap d0
.skip:
	addq.l #4,a1
	tst d0
	bne.s .line
	add d3,a3
	lea 320(a0),a0			; 640 pixels skipped (one line)
	lea 160(a1),a1			; 40 long flags skipped (one line)
	subq #1,a2
	cmp #0,a2
	bne.s .next
	rts
flm_st_high:
	cmp #16,planes
	bne.s .not_tc
	cmp #640,screenw
	bmi.s flm_st_high_half
.again:
	moveq #39,d2	; 40 words for each line
.line:
	tst.b (a1)
	beq.s .skip
	move (a0)+,d0
	moveq #15,d1
.lb0:
	btst d1,d0
	seq (a3)+
	seq (a3)+
	dbf d1,.lb0
	sf (a1)
	bra.s .next
.skip:
	lea 32(a3),a3	; 16 pixels
	addq.l #2,a0	; one word
.next:
	addq.l #1,a1	; flags
	dbf d2,.line
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .again
	rts
.not_tc:
	moveq #39,d2	; 40 words for each line
.nt_line:
	tst.b (a1)
	beq.s .nt_skip
	move (a0)+,d0
	moveq #15,d1
.nt_lb0:
	btst d1,d0
	sne (a3)+
	dbf d1,.nt_lb0
	sf (a1)
	bra.s .nt_next
.nt_skip:
	lea 16(a3),a3	; 16 pixels
	addq.l #2,a0	; one word
.nt_next:
	addq.l #1,a1	; flags
	dbf d2,.nt_line
	add d3,a3
	subq #1,a2
	cmp #0,a2
	bne.s .not_tc
	rts
flm_st_high_half:
	move.l physbase,a3
	move screenh,d1
	sub #200,d1
	asr d1
	move screenw,d0
	muls d0,d1
	sub #320,d0
	move d0,d3
	add d3,d3
	asr d0
	ext.l d0
	add.l d0,d1
	add.l d1,d1
	add.l d1,a3		; start in screen
	move #$1042,d4		; half grey for nova
	tst.b nova
	bne.s .again
	move #$8410,d4		; half grey for Falcon
.again:
	moveq #39,d2	; 40 words for each line
.line:
	tst.b (a1)
	beq.s .skip
	move (a0)+,d0
	moveq #15,d1
.lb0:
	btst d1,d0
	beq.s .lb1
	subq #1,d1
	btst d1,d0
	beq.s .lb2
	sf (a3)+
	sf (a3)+			; $11 = black
	bra.s .lb3
.lb1:
	subq #1,d1
	btst d1,d0
	bne.s .lb2
	st (a3)+			; $00 = white
	st (a3)+
	bra.s .lb3
.lb2:
	move d4,(a3)+	; one grey =$10 or $01
.lb3:
	dbf d1,.lb0
	sf (a1)
	bra.s .next
.skip:
	lea 16(a3),a3	; 8 pixels
	addq.l #2,a0	; one word
.next:
	addq.l #1,a1	; flags
	dbf d2,.line
	add d3,a3
	lea 80(a0),a0	; skips one line into buffer
	lea 40(a1),a1	; one flag byte line skipped
	subq #2,a2		; two lines at a time
	cmp #0,a2
	bne.s .again
	rts

falc set 0

	rept 2

	if falc=0
flm_tt_low:
	else
flm_vga_256:
	endif
	move a2,d6
	subq #1,d6
	move d3,a5
	move screenw,d3
	move screenh,d2
	if falc=0
		sub #240,d2
	else
		sub #480,d2
	endif
	asr d2
	bpl.s .off_ok
	moveq #0,d2
.off_ok:
	muls d2,d3
	add.l d3,a3
	cmp #16,planes
	bne .not_tc
	add.l d3,a3
	lea cvid_fix1,a2	; for 16 bytes buffer
.again:
	if falc=0
		moveq #19,d5
	else
		moveq #39,d5
	endif
.line:
	tst.l (a1)
	bne.s .do_it
	tst.l 4(a1)
	beq .skip
.do_it:
	rept 2
		move (a0)+,d4
		swap d4
		move (a0)+,d2
		swap d2
		move (a0)+,d3
		swap d3
		move (a0)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l d4,-(a2)
	move.l d3,-(a2)
	moveq #0,d0
	move.l d2,-(a2)
	moveq #0,d7
	move.l d1,-(a2)
	move.b (a2)+,d7
	rept 7
		move.b (a2)+,d0
		move (a6,d7.w*2),(a3)+
		move.b (a2)+,d7
		move (a6,d0.w*2),(a3)+
	endr
	move.b (a2)+,d0
	move (a6,d7.w*2),(a3)+
	move (a6,d0.w*2),(a3)+
	clr.l (a1)+
	clr.l (a1)+
	bra.s .next
.skip:
	lea 32(a3),a3
	lea 16(a0),a0
	addq.l #8,a1
.next:
	dbf d5,.line
	add a5,a3
	if falc=0
		lea 320(a0),a0
		lea 160(a1),a1
		subq #2,d6
	else
		subq #1,d6
	endif
	bpl .again
	rts
.not_tc:
	if falc=0
		moveq #19,d5
	else
		moveq #39,d5
	endif
.nt_line:
	tst.l (a1)
	bne.s .nt_do_it
	tst.l 4(a1)
	beq .nt_skip
.nt_do_it:
	rept 2
		move (a0)+,d4
		swap d4
		move (a0)+,d2
		swap d2
		move (a0)+,d3
		swap d3
		move (a0)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	move.l d1,(a3)+
	splice d2,d4,d0,d7,8
	move.l d2,(a3)+
	move.l d3,(a3)+
	move.l d4,(a3)+
	clr.l (a1)+
	clr.l (a1)+
	bra.s .nt_next
.nt_skip:
	lea 16(a3),a3
	lea 16(a0),a0
	addq.l #8,a1
.nt_next:
	dbf d5,.nt_line
	add a5,a3
	if falc=0
		lea 320(a0),a0
		lea 160(a1),a1
		subq #2,d6
	else
		subq #1,d6
	endif
	bpl .not_tc
	rts

falc set falc+1

	endr

dl_read_header:
	SEEK #0,0		; start of file
	lea cvid_fix0,a3
	moveq #64,d3
	pea (a3)
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp d0,d3
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	move.b (a3)+,d3		; 1 or 2
	cmp.b #1,d3
	bne.s .lb0
	moveq #1,d4				; 160x100
	moveq #24,d0			; header size
	bra.s .lb1
.lb0:
	cmp.b #2,d3
	bne.s .bug
	move.b (a3)+,d4
	moveq #47,d0			; header size
	lea 20(a3),a3			; one zone
.lb1:
	lea 20(a3),a3			; second zone
	moveq #0,d5
	move.b (a3)+,d5		; screens
	muls.l #64000,d5		; minimum size
	move.l d5,max_fsize	; to load the whole animation
	move.l d0,sound_seek
	add.l #768,d0			; plus the palette
	add.l d5,d0				; plus the screens
	cmp.l total,d5
	bpl.s .bug				; not enough bytes!
	cmp.b #1,d3
	bne.s .long_fr
	moveq #0,d0
	move (a3)+,d0
	ror #8,d0
	bra.s .common
.long_fr:
	move.l (a3)+,d0
	INTEL d0
.common:
	move.l d0,sample_num
	move.l #'dl/0',d0
	add.b d3,d0
	move.l d0,comp_txt	; dl-1 or dl-2
	move #320,d0
	move #200,d1
	moveq #1,d2				; one image per screen
	subq #1,d4
	bmi.s .good_size
	lsr d0
	lsr d1
	moveq #4,d2				; 4 images per screen
	subq #1,d4
	bmi.s .good_size
	lsr d0
	lsr d1
	moveq #16,d2			; 16 images per screen
.good_size:
	move d0,max_imagex
	move d1,max_imagey
	move d2,dl_i_per_s	; images per screen
	st samp_sizes
	moveq #33,d0
	move.l d0,_delay		; 6fps
	moveq #0,d0
	rts

load_dl_palette:
	move.l sound_seek,d0
	SEEK d0,0	; start of palette
	lea cvid_fix1,a3
	move.l #$01000000,(a3)+		; one bloc, 0 to 255
	pea (a3)
	move.l #768,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	rts

load_dl_screens:
	move.l buffer,a3
	move.l max_fsize,d5
	pea (a3)
	move.l d5,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12					; all screens loaded at once!
	tst.b is_tt
	beq.s .fin
	lsr.l #4,d5						; number of times we've got 16 pixels
	bsr.s byte_to_8_planes
.fin:
	rts
	
; transformation sur place
; a3 = adresse octets
; d5.l nombre de blocs de 16 pixels
	
byte_to_8_planes:
	movem.l (a3),d1-d4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	swap d2
	swap d4
	eor d1,d2
	eor d3,d4
	eor d2,d1
	eor d4,d3
	eor d1,d2
	eor d3,d4
	swap d2
	swap d4
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move d4,(a3)+
	swap d4
	move d2,(a3)+
	swap d2
	move d3,(a3)+
	swap d3
	move d1,(a3)+
	swap d1
	move d4,(a3)+
	move d2,(a3)+
	move d3,(a3)+
	move d1,(a3)+
	subq.l #1,d5
	bne byte_to_8_planes
	rts

dl_frame_table:
	move.l s_buffer,a3
	move.l sample_num,d3
	cmp.l #'dl/1',comp_txt
	beq.s .lb0
.lb1:
	bsr.l read_word
	ror #8,d0						; intel!!
	move d0,(a3)+
	subq.l #1,d3
	bne.s .lb1
	rts
.lb0:
	bsr.l read_byte
	moveq #0,d1
	move.b d0,d1
	divs #10,d1
	subq #1,d1
	move d1,d0						; nø of the screen
	swap d1
	subq #1,d1						; nø of image inside screen
	muls dl_i_per_s,d0
	add d1,d0						; global nø of image
	move d0,(a3)+
	subq.l #1,d3
	bne.s .lb0
	rts


dl_read_data:
	tst.b step_mode
	bne.s .step1
	bsr install_traps
	trap #10
	move.l d0,current_time
.step1:
	tst.b is_tt
	beq.s .again
	tst.b switched
	bne.s .adapt		; if switched, center of the screen
	tst.b cmd_coord
	bne.s .again		; else, if coords, don't care about centering
.adapt:
	move max_imagey,d0
	lsr d0
	muls #320,d0
	sub.l d0,image					; as we double the height.
.again:
	move.l #cvid_fix1+4000,s_buffer_2	; my stack for loops
	move.l s_buffer,a3	; table of frames
	move.l sample_num,d7	; number of frames
	tst.b step_mode
	bne.s .step2
	trap #10
	move.l d0,start_time
	bsr.l enh_event0
.step2:
	clr.l disp_frame
.lb0:
	moveq #0,d0
	move (a3)+,d0			; nø of the image
	bpl.s .normal
	cmp #$ffff,d0
	bne.s .cmd1
	move (a3)+,d0			; count
	move.l s_buffer_2,a0	; stack
	subq.l #1,d7
	move.l d7,-(a0)
	move.l a3,-(a0)
	move d0,-(a0)
	move.l a0,s_buffer_2
	bra .glop
.cmd1:
	cmp #$fffe,d0
	bne.s .cmd2
	move.l s_buffer_2,a0
	subq #1,(a0)+
	bne.s .not_end
	addq.l #8,a0
	move.l a0,s_buffer_2
	bra .glop
.not_end:
	move.l (a0)+,a3
	move.l (a0)+,d7
	bra .glop
.cmd2:
	cmp #$fffd,d0
	bne .glop
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	bra .glop
.normal:
	move dl_i_per_s,d2
	divs d2,d0	; screen and index
	moveq #0,d1
	move d0,d1
	muls.l #64000,d1		; offset for that screen
	swap d0
	lea .offsets,a0
	cmp #16,d2
	bne.s .lb1
	lea 16(a0),a0
.lb1:
	add.l (a0,d0.w*4),d1	; address in that screen
	add.l buffer,d1		; absolute address in that screen
	bsr dl_copy_image
	tst.b is_vdi
	beq.s .no_vdi
	movem.l a3/d7,-(sp)
	jsr vdi_display
	movem.l (sp)+,a3/d7
.no_vdi:
	addq.l #1,disp_frame
	tst.b step_mode
	beq.s .step3
.bug:
	bsr inc_frame
	beq.s .step_stop
	bpl.s .loop
	bsr save_frame
	bmi.s .bug
.loop:
	subq.l #1,d7
	bne .lb0
.step_stop:
	st stopped
	rts
.step3:
	move.l current_time,d1
.delay:
	trap #10
	cmp.l enh_time,d0
	bpl.s .event
	cmp.l d0,d1
	bpl.s .delay
	bra.s .lb00
.event:
	bsr.l enh_event
	bra.s .delay
.lb00:
	add.l _delay,d1
	move.l d1,current_time
	btst #2,([kbshift])
	bne.s .stop
.glop:
	subq.l #1,d7			; one frame less
	bne .lb0				; not ended
	tst.b is_rep
	bne .again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	bra common_end

.offsets: dc.l 0,160,32000,32160
.offsets2: dc.l 0,80,160,240,16000,16080,16160,16240
			  dc.l 32000,32080,32160,32240,48000,48080,48160,48240


dl_copy_image:
	move.l d1,a1			; buffer
	move.l image,a0
	move screenw,d3
	move max_imagex,d4
	sub d4,d3				; screen inc for one line
	move #320,d5
	sub d4,d5				; buffer inc for one line
	move max_imagey,d6
	subq #1,d6				; for the loop
	tst.b is_tt
	bne.s dl_tt_double
	cmp #16,planes
	beq.s dl_tc
	lsr #2,d4				; 4 bytes at a time
	subq #1,d4				; for dbf
.line:
	move d4,d1
.pixels:
	move.l (a1)+,(a0)+
	dbf d1,.pixels
	add d3,a0
	add d5,a1
	dbf d6,.line
	rts
dl_tc:
	lea cvid_fix0,a6		; the palette
	add d3,d3				; one pixel = 2 bytes
	lsr #2,d4
	subq #1,d4				; 4 pixels at a time
	moveq #0,d0
.line:
	move d4,d1
.pixels:
	rept 4
		move.b (a1)+,d0
		move (a6,d0.w*2),(a0)+
	endr
	dbf d1,.pixels
	add d3,a0
	add d5,a1
	dbf d6,.line
	rts
dl_tt_double:
	lsr #4,d4
	subq #1,d4				; 16 pixels at a time
	lea 320(a0),a5			; next line
	add #320,d3
.line:
	move d4,d1
.pixels:
	movem.l (a1)+,d0/d2/a2/a4	; 16 bytes
	movem.l d0/d2/a2/a4,(a0)
	movem.l d0/d2/a2/a4,(a5)
	lea 16(a5),a5
	lea 16(a0),a0
	dbf d1,.pixels
	add d3,a0
	add d3,a5
	add d5,a1
	dbf d6,.line
	rts

bat_create_gif:
	move.l buffer,a3
	move.l gif_pal_size,d0
	lea 13(a3,d0.l),a4		; start of datas
	tst.b smc_a
	bne.s .add_frame			; not the first one, don't use the colormap
	move.b #'9',4(a3)			; turns all to GIF89a
	addq.l #8,d0
	addq.l #5,d0				; colormap + 13 = header!!!
	move.l a3,-(sp)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; fwrite!!
	moveq #0,d1					; default is no netscape extension
	move bat_gif_loop,d0
	cmp #1,d0
	beq.s .no_loop
	ror #8,d0
	move d0,.net_loop
	moveq #19,d1				; 19 bytes more
.no_loop:
	move.l sample_num,d0
	INTEL d0
	move.l d0,.my_frm
	lea .my_ext(pc),a0
	sub d1,a0
	move.l a0,-(sp)
	moveq #20,d0
	add.l d1,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; my extension (and maybe Netscape)
	st smc_a						; turns the flag (header read)
.add_frame:
	add.l bufused,a3			; end of file
	move.w #$003b,(a3)		; end of file forced
.frames:
	move.b (a4)+,d0	; code
	cmp.b #$3B,d0
	beq .end
	cmp.b #$2c,d0
	bne .lb0
	bsr update_create_box
	addq.l #1,disp_frame
	lea -1(a4),a0		; start of frame
	addq.l #8,a4		; four words
	move.b (a4)+,d0
	btst #7,d0
	beq.s .no_pal
	and #$7,d0
	addq #1,d0
	moveq #1,d1
	lsl d0,d1
	move d1,d0
	add d0,d1
	add d0,d1			; size of the palette
		add d1,a4			; skips the palette
.no_pal:
	addq.l #1,a4		; LZW code
	moveq #0,d0
.lb2:
	cmp.l a3,a4
	bpl .end			; bad frame!
	move.b (a4)+,d0
	beq.s .save_frame	; 0, end of this part
	cmp.b #'0',d0		; for CALAMUS, them stupid!
	bne.s .lb3
	move.b (a4),d1
	cmp.b #$2c,d1
	beq.s .save_cal
	cmp.b #$3b,d1
	beq.s .save_cal
	cmp.b #$21,d1
	bne.s .lb3
	move.b 1(a4),d1
	cmp.b #$f9,d1
	beq.s .save_cal
	cmp.b #$fe,d1
	beq.s .save_cal
	cmp.b #$01,d1
	beq.s .save_cal
	cmp.b #$ff,d1
	beq.s .save_cal
.lb3:
	add d0,a4			; else, an offset
	bra.s .lb2			; other bloc
.save_cal:
	clr.b -1(a4)
.save_frame:
	move.l a4,d0
	sub.l a0,d0			; size of the frame
	move.l a0,-(sp)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite!
	tst.w delay_gif
	beq .frames		; delay is 0
	pea .delay_ext(pc)
	moveq #8,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite (delay extension bloc)
	bra .frames
.lb0:
	cmp.b #$21,d0
	bne.s .end
	bsr.s trans_index	; adds the transparency/restore extension if present
	addq.l #1,a4
.other:
	moveq #0,d0
.lb1:
	cmp.l a3,a4
	bpl.s .end
	move.b (a4)+,d0
	beq .frames			; 0, end of this part
	add d0,a4			; else, an offset
	bra.s .lb1			; other bloc
.end:
	rts
.net_ext: dc.b $21,$ff,$0b,'NETSCAPE','2.0',$03,$01
.net_loop: dc.b 0,0,0
.my_ext: dc.b $21,$ff,$0b,'M_PLAYER','FRM',$04
.my_frm: dc.b 0,0,0,0,0
.delay_ext: dc.b $21,$f9,$04,$00
delay_gif: dc.b 0,0,0,0
	even

trans_index:
	cmp.b #$f9,(a4)	; delay extension?
	beq.s .lb0
.exit:
	rts
.lb0:
	cmp.b #$4,1(a4)	; 4 bytes?
	bne.s .exit
	lea .trans(pc),a0	; out data
	move.b 2(a4),d0	; trans+restore byte
	move.b d0,3(a0)
	move.b 5(a4),6(a0) ; trans index (if used)
	btst #0,d0				; transparency index???
	bne.s .write
	and.b #$1c,d0		; action (0 to 7)
	cmp.b #$80,d0
	bmi.s .exit			; 0 or 1, no action!
.write:
	pea (a0)
	moveq #8,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12		; fwrite!
	rts
.trans: dc.b $21,$f9,$04,$01,$00,$00
.index: dc.b 0,0

	even

bat_gif:
	subq.l #1,disp_frame
	move.l d5,bufused			;size of the file
	move.l buffer,a3			; the file is here!
	bsr.s gif_read_header
	beq.s .ok
	rts
.ok:
	tst.b create_mov
	bgt bat_create_gif
.gif_loop:
	move.l buffer,a6
	move.l a6,a0
	add.l bufused,a0			; end_of_file
	move.w #$003B,(a0)
	move.l a0,last_size
	moveq #0,d0
	move.b gif_flags,d0
	bset #15,d0
	lea 13(a6),a6		; start of global palette
	bsr gif_palette
.frames:
	move.b (a6)+,d0	; code
	cmp.b #$3B,d0
	beq.s .end
	cmp.b #$2c,d0
	bne.s .lb0
	subq.l #1,sample_num
	bsr gif_decode_frame
	move.l a5,a6		; the next length
	bra.s .other		; skips if something remains
.lb0:
	cmp.b #$21,d0
	bne.s .end
	addq.l #1,a6
.other:
	moveq #0,d0
.lb1:
	cmp.l last_size,a6
	bpl.s .end
	move.b (a6)+,d0
	beq.s .frames		; 0, end of this part
	add d0,a6			; else, an offset
	bra.s .lb1			; other bloc
.end:
	st smc_a			; if next time, don't read palette
	rts

gif_read_header:
	tst.b slide_gif
	bne.s .ok
	SEEK #0,0
	lea cvid_fix0,a3
	move.l a3,-(sp)
	moveq #13,d3
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d3,d0
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	cmp.l #'GIF8',(a3)+
	bne.s .bug
	move.l #'gif7',d0
	cmp #'7a',(a3)
	beq.s .found
	move.b #'9',d0
	cmp #'9a',(a3)
	bne.s .bug
.found:
	st unknown				; a priori, pas de nombre d'images
	addq.l #2,a3
	move.l d0,comp_txt
	move (a3)+,d0
	ror #8,d0
	move d0,max_imagex
	move (a3)+,d0
	ror #8,d0
	move d0,max_imagey
	move (a3)+,d0
	move d0,gif_flags
	lsr #8,d0				; upper byte
	and #$7,d0
	addq #1,d0				; number of bits per color
	moveq #1,d1
	lsl d0,d1				; size of the palette
	move.l d1,d0
	add.l d1,d1
	add.l d0,d1				; 3 times the number of colors
	move.l d1,gif_pal_size
	moveq #39,d3			; 20 Mplayer + 19 Netscape
	tst.b slide_gif
	bne.s .special
	SEEK d1,1				; skips the palette
	lea cvid_fix0,a3
	move.l a3,-(sp)
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d3,d0
	bne .end
	bra.s .common
.special:
	add.l d1,a3				; skips the palette
.common:
	add.l a3,d3				; end of the block read
	move.l #$20202020,d1
	move #1,gif_repeat
.other_bloc:
	cmp.w #$21FF,(a3)+
	bne.s .end
	cmp.b #11,(a3)+		; application bloc?
	bne.s .end
	move.l (a3)+,d0
	or.l d1,d0
	cmp.l #'mpl',d0		; ID of application
	bne.s .other_id
	move.l (a3)+,d0
	or.l d1,d0
	cmp.l #'ayer',d0
	bne.s .end
	move.l (a3)+,d0
	lsr.l #8,d0
	or.l d1,d0
	cmp.l #' frm',d0		; frame infos?
	bne.s .end
	move.l (a3)+,d0			; everything OK, number of frames
	INTEL d0
	move.l d0,sample_num
	sf unknown				; nombre connu!
	bra.s .again
.other_id:
	cmp.l #'nets',d0
	bne.s .end
	move.l (a3)+,d0
	or.l d1,d0
	cmp.l #'cape',d0
	bne.s .end
	move.l (a3)+,d0
	lsr.l #8,d0
	or.l d1,d0
	cmp.l #' 2.0',d0
	bne.s .end
	addq.l #1,a3
	move (a3)+,d0
	ror #8,d0
	move d0,gif_repeat
.again:
	addq.l #1,a3			; skips the last '00'
	cmp.l d3,a3
	bmi.s .other_bloc
.end:
	st samp_sizes
	moveq #0,d0
	rts

_count_gif_frames:
	movem.l d0-d2/a0-a2,-(sp)
	bsr.s load_gif
	add #13,a2			; saute le header
	add.l gif_pal_size,a2	; et la palette
	moveq #0,d2			; nombre d'images
.loop:
	moveq #0,d0
	move.b (a2)+,d0
	cmp.b #$3b,d0
	beq.s .fin
	cmp.b #$21,d0
	beq.s .extens
	cmp.b #$2c,d0
	bne.s .autre
	addq.l #1,d2
	addq.l #8,a2	; saute x,y,w,h
	move.b (a2)+,d0	; masque de bits
	bpl.s .extens	; saute aussi le premier code LZW
	and.w #$07,d0
	moveq #2,d1
	lsl d0,d1
	muls #3,d1		; taille palette
	add.l d1,a2		; saute
.extens:
	addq.l #1,a2	; $21 + autre octet
.autre:
	cmp.l last_size,a2
	bpl.s .fin
	move.b (a2)+,d0
	beq.s .loop
	add d0,a2
	bra.s .autre
.fin:
	move.l d2,sample_num
	movem.l (sp)+,d0-d2/a0-a2
	rts

load_gif:
	tst.b gif_loaded
	bne.s .end
	st gif_loaded
	SEEK #0,0
	move.l buffer,-(sp)
	move.l total,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read the whole file
	move.l buffer,a2
	move.l a2,a0
	add.l total,a0			; end_of_file
	move.w #$003B,(a0)
	move.l a0,last_size
.end:
	rts

gif_read_data:
	bsr.s load_gif
	tst.b step_mode
	bne.s .no_step1
	bsr install_traps
.no_step1:
;	sf smc_a				; first time, read palette
.again:
	move gif_repeat,_gif_rep
.gif_loop:
	clr.l disp_frame
	clr.l sample_num
	tst.b step_mode
	bne.s .no_step2
	trap #10
	move.l d0,start_time
.no_step2:
	move.l buffer,a6
;	move.l a6,a0
;	add.l total,a0			; end_of_file
;	move.w #$003B,(a0)
;	move.l a0,last_size
	moveq #0,d0
	move.b gif_flags,d0
	bset #15,d0
	lea 13(a6),a6		; start of global palette
	bsr gif_palette
.frames:
	btst #2,([kbshift])
	bne .stop
	move.b (a6)+,d0	; code
	cmp.b #$3B,d0
	beq .end
	cmp.b #$2c,d0
	bne.s .lb0
	bsr gif_decode_frame
		tst.b is_vdi
		beq.s .no_vdi
		movem.l a0-a4/d0-d6,-(sp)
		jsr vdi_display
		movem.l (sp)+,a0-a4/d0-d6
.no_vdi:
	move.l a5,a6		; the next length
	tst.b is_tt
	beq.s .coucou
	move gif_lines,a3		; number of lines
	move gif_start_line,d0	; start line
	move.l compression,a0
	jsr 16(a0)
.coucou:
	tst.b step_mode
	beq.s .step3
.bug:
	bsr inc_frame
	beq.s .step_stop
	bpl.s .loop
	bsr save_frame
	bmi.s .bug
.loop:
	moveq #0,d0
.lb11:
	cmp.l last_size,a6
	bpl.s .step_stop
	move.b (a6)+,d0
	beq.s .frames		; 0, end of this part
	add d0,a6			; else, an offset
	bra.s .lb11			; other bloc
.step_stop:
	st stopped
	bsr close_step_dialog
	rts
.step3:
	bra.s .other		; skips if something remains
.lb0:
	cmp.b #$21,d0
	bne.s .end
	cmp.b #$f9,(a6)+	; sub code
	bne.s .other
	bsr gif_delay		; then will skip the bloc like 'other'
.other:
	moveq #0,d0
.lb1:
	cmp.l last_size,a6
	bpl.s .end
	move.b (a6)+,d0
	beq .frames		; 0, end of this part
	add d0,a6			; else, an offset
	bra.s .lb1			; other bloc
.end:
;	st smc_a			; if next time, don't read palette
	tst.b step_mode
	bne.s .step_stop
	subq #1,_gif_rep
	beq.s .another
	btst #0,([kbshift])	; shift with loop mode? to stop!
	bne.s .normal_out
	btst #1,([kbshift])
	bne.s .normal_out
	bra .gif_loop
.another:
	tst.b is_rep
	bne .again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	bra common_end


old_token: dc.w 0

gif_decode_frame:
	addq.l #1,disp_frame
	addq.l #1,sample_num
	bsr gif_prepare_rect
	moveq #0,d0
	move.b (a6)+,d0
	btst #6,d0
	sne gif_interlace
	bsr gif_palette
	moveq #0,d7
	move.b (a6)+,d7		; LZW size
	move d7,root_code
	moveq #1,d6
	lsl d7,d6				; bits2
	addq #1,d7				; code_size
	moveq #1,d0
	lsl d7,d0
	move d0,codesize2
	move d6,d5
	addq #2,d5				; next code
	moveq #-1,d2			; old code
	move d2,old_token
	moveq #0,d3
	move.l a6,a5			; end of bloc
	move.l hc_cvid,a4
	lea 16384(a4),a3		; line buffer!
.next_code:
	bsr gif_get_code
	addq #1,d6
	cmp d0,d6				; end of image?
	bne.s .no
.end:
	sf gif_trans			; only for one image
	rts
.no:
	subq #1,d6
	cmp d0,d5				; > next code?
	bmi.s .end
	move d0,d4				; current code
	cmp d0,d6
	bne.s .no_2
	move root_code,d7
	addq #1,d7				; codesize=bits+1
	moveq #1,d0
	lsl d7,d0
	move d0,codesize2
	move d6,d5
	addq #2,d5				; next code = bits2 + 2
	moveq #-1,d2			; old code	and old_token
	move d2,old_token
	bra.s .next_code
.no_2:
	move.l a4,a0			; first stack
	lea 4096(a0),a1		; last stack
	lea 4096(a1),a2		; code stack
	cmp d5,d0
	bne.s .no_3
	move.b old_token(pc),(a0)+
	move d2,d0
.no_3:
	cmp d6,d0
	bmi.s .end_of_while
	move.b (a1,d0.w),(a0)+
	move.w (a2,d0.w*2),d0
	bra.s .no_3
.end_of_while:
	move.b d0,old_token
	moveq #0,d1
	move gif_rows,d1
	add.l a4,d1
	add.l #16384,d1		; end of line
.do:
	move.b d0,(a3)+
	cmp a3,d1
	bne.s .no_4
	bsr gif_display_line
.no_4:
	cmp.l a0,a4				; stack empty?
	beq.s .end_of_do
	move.b -(a0),d0
	bra.s .do
.end_of_do:
	cmp #4096,d5
	bpl.s .end_of_for
	tst d2
	bmi.s .end_of_for
	move d2,(a2,d5.w*2)
	move.b old_token(pc),(a1,d5.w)
	addq #1,d5
	cmp #12,d7
	bpl.s .end_of_for
	move codesize2,d0
	cmp d0,d5
	bmi.s .end_of_for
	addq #1,d7
	add d0,d0
	move d0,codesize2
.end_of_for:
	move d4,d2
	bra .next_code

gif_prepare_rect:
	moveq #0,d0
	move (a6)+,d0
	move (a6)+,d1
	ror #8,d1
	move d1,gif_start_line
	muls screenw,d1
	ror #8,d0
	add.l d0,d1			; offset from start of image in screen
	move (a6)+,d0
	ror #8,d0
	move d0,gif_rows
	neg d0
	move screenw,d2
	add d2,d0		; row inc
	cmp #16,planes
	bmi.s .lb0
	add.l d1,d1
	add d0,d0
	add d2,d2
.lb0:
	add.l image,d1
	move.l d1,gif_image
	move.l d1,gif_image_sav	; when interlaced
	move d0,gif_inc
	move d2,gif_one_line
	move (a6)+,d0
	ror #8,d0
	move d0,gif_lines
	muls d0,d2
	add.l d2,d1					; end of image
	move.l d1,gif_end_image
	clr gif_pass
	rts

gif_display_line:
	movem.l d0-d2/a0-a1/a6,-(sp)
	move gif_rows,d0
	subq #1,d0
	lea 16384(a4),a3		; start of line
	move.l a3,a0
	move.l gif_image,a1
	cmp #16,planes
	bne .not_tc
	move.l pal_adr,a6		; palette
	moveq #0,d1
	tst.b gif_trans
	beq.s .lb0
	move.b gif_trans_index,d2
.lb0t:
	move.b (a0)+,d1
	cmp.b d2,d1
	bne.s .lb1t
	addq.l #2,a1		; skips
	dbf d0,.lb0t
	bra.s .exit
.lb1t:
	move (a6,d1.w*2),(a1)+
	dbf d0,.lb0t
	bra.s .exit
.lb0:
	move.b (a0)+,d1
	move (a6,d1.w*2),(a1)+
	dbf d0,.lb0
.exit:
	add gif_inc,a1
	tst.b gif_interlace
	beq.s .not_inter
	move gif_one_line,d0
	move gif_pass,d1
	and #$3,d1
	lea (.gif_table,d1.w*4),a0
	move d0,d1
	muls (a0)+,d0					; number of lines
	add.l d0,a1
	cmp.l gif_end_image,a1
	bmi.s .ok
	addq #1,gif_pass
	muls (a0),d1					; new start line
	add.l gif_image_sav,d1
	move.l d1,a1
	bra.s .ok
.not_inter:
	cmp.l gif_end_image,a1
	bmi.s .ok
	move.l gif_image_sav,a1		; end reached! start at bottom
.ok:
	move.l a1,gif_image
	movem.l (sp)+,d0-d2/a0-a1/a6
	rts
.not_tc:
	tst.b gif_trans
	beq.s .nt0
	move.b gif_trans_index,d2
.nt1:
	move.b (a0)+,d1
	cmp.b d1,d2
	bne.s .nt2
	addq.l #1,a1
	dbf d0,.nt1
	bra.s .exit
.nt2:
	move.b d1,(a1)+
	dbf d0,.nt1
	bra .exit
.nt0:
	move.b (a0)+,(a1)+
	dbf d0,.nt0
	bra .exit
.gif_table: dc.w 7,4,7,2,3,1,1,0,0,0

gif_get_code:
	move.l a6,a0
	cmp.l a0,a5
	bne.s .lb0
	tst.b (a0)
	bne.s .normal
	move d6,d0
	addq #1,d0			; returns end_of_frame code
	rts
.normal:
	addq.l #1,a0
.lb0:
	move.b (a0)+,d0
	ror #8,d0
	cmp.l a0,a5
	bne.s .lb1
	addq.l #1,a0
.lb1:
	move.b (a0)+,d0
	ror #8,d0
	swap d0
	cmp.l a0,a5
	bne.s .lb2
	addq.l #1,a0
.lb2:
	move.b (a0),d0
	swap d0				; 3 bytes from input
	lsr.l d3,d0			; shifted!
	moveq #1,d1
	lsl d7,d1
	subq #1,d1			; mask
	and d1,d0			; correct code!
	add d7,d3			; bits read
.while:
	cmp #8,d3
	bmi.s .exit			; in the same byte, don't move
	subq #8,d3
	cmp.l a6,a5
	beq.s .lb3
	addq.l #1,a6
	cmp.l a6,a5
	bne.s .while
	moveq #0,d1
	move.b (a6)+,d1
	bne.s .not_end
.end:
	subq.l #1,a6
.not_end:
	lea (a6,d1.w),a5	; next bloc
	cmp.l last_size,a5
	bmi.s .while
	move.l last_size,a5 ; end reached! limit!
	cmp.l a6,a5
	bpl.s .while			; good A6
	move.l a5,a6			; else limit!
	bra.s .while
.exit:
	rts
.lb3:
	moveq #0,d1
	move.b (a6)+,d1
	beq.s .end
	addq.l #1,a6
	subq #1,d1
	bra.s .not_end


gif_delay:
	tst.b _delay
	beq.s .end				; no delay wanted
	tst.b step_mode
	bne.s .end				; ni avec la conversion
	move.l d1,-(sp)
	moveq #0,d1
	move 2(a6),d1
	ror #8,d1
	add.l d1,d1
	trap #10
	add.l d0,d1		; end of time
.lb0:
	trap #10
	cmp.l d0,d1
	bpl.s .lb0				; not ended
	move.l (sp)+,d1
.end:
	btst #0,1(a6)			; transparency?
	sne gif_trans
	move.b 4(a6),gif_trans_index
	rts

; d0 = flag bit #7 if there's a palette
; d0 and $7 +1 number of colors
; bit  #15 set if global palette
; bit  #31 set if load (else it is loaded ADR = a6, a6 updated!)

gif_palette:
	tst.b d0
	bmi.s .ok		; no palette!
	move.l #cvid_fix0,pal_adr	; no palette->global is back!
	rts
.ok:
	lea cvid_fix0,a4
	tst d0
	bmi.s .lb0
	lea cvid_fix0+2000,a4
.lb0:
	move.l a4,pal_adr
	lea 1000(a4),a4
	move.w #$0100,(a4)+
	clr.b (a4)+
	move.l d0,d7
	and #$7,d0
	addq #1,d0
	moveq #1,d1
	lsl d0,d1		; number of colors
	move.b d1,(a4)+
	tst.l d7
	bpl.s .loaded	; yet loaded!
	move d1,d0
	add d1,d1
	add d0,d1		; size of the palette
	ext.l d1
	pea (a4)
	move.l d1,-(sp)
	GEMDOS 63,12	; reads the palette
	bra.s .next
.loaded:
	move.b (a6)+,(a4)+
	move.b (a6)+,(a4)+
	move.b (a6)+,(a4)+
	subq #1,d1
	bne.s .loaded
.next:
	move.l a6,-(sp)
;	tst.b smc_a
;	bne.s .end
	move.l pal_adr,a6
	lea 1000(a6),a0
	cmp #8,planes
	beq.s .not_tc
	bsr.l fli_color_256
	bra.s .end
.not_tc:
	bsr.l fli_color_256_256
.end:
	move.l (sp)+,a6
	rts

exit_menu:
	moveq #0,d0
	bra.s _menu
redraw_menu:
	moveq #1,d0
_menu:
	tst.b mountain
	bne.s .lb1
	tst.b cmd_coord
	bne.s .lb1				; if coords, don't erase upper line
	tst.b slide_flag
	bne.s .lb1
	tst.b acc
	bne.s .lb0				; no menu with an ACC
	move d0,mb_int
	GEM_AES menu_bar		; redraws the upper line
	bra.s .lb1
.lb0:
	tst.b is_win
	bne.s .lb1
	move.l menu_buffer,d0
	beq.s .lb1				; not yet allocated
	move.l d0,a0
	move.l menu_len,d0
	move.l old_screen,a1
	asr.l #2,d0
	subq.l #1,d0
.lb2:
	move.l (a0)+,(a1)+
	subq.l #1,d0
	bpl.s .lb2
.lb1:
	rts

save_menu:
	tst.b acc
	beq.s .lb1
	moveq #1,d0
	add work_out,d0		; pixels per line
	muls planes,d0			; bits per line
	asr.l #3,d0				; bytes per line
	moveq #2,d1
	add boxh,d1				; menu height
	muls.l d0,d1			; size of the menu
	move.l d1,menu_len
	bsr.l malloc
	move.l d0,menu_buffer
	move.l d0,a0
	move.l old_screen,a1
	move.l menu_len,d0
	asr.l #2,d0
	subq.l #1,d0
.lb0:
	move.l (a1)+,(a0)+
	subq.l #1,d0
	bpl.s .lb0
.lb1:
	rts

vmas_read_header:
	SEEK #0,0
	lea cvid_fix0,a3
	pea (a3)
	moveq #10,d3
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d0,d3
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	move.l #'VMAS',d0
	sf cram_bits			; 0 if ST Low
	cmp.l (a3)+,d0
	beq.s .ok_st_low
	move.l #'VFAL',d0
	st cram_bits
	cmp.l -4(a3),d0
	bne.s .bug
.ok_st_low
	cmp.w #'10',(a3)+
	bne.s .bug
	move.l d0,comp_txt
	move (a3)+,d0
	ext.l d0
	move.l d0,sample_num
	move #160,max_imagex
	move #100,max_imagey
	move.l #8032,d0
	tst.b cram_bits
	beq.s .st_low
	move.l #17024,d0
.st_low:
	move.l d0,max_fsize
	st samp_sizes
	moveq #0,d0
	move (a3)+,d0
	cmp #7,d0
	bpl.s .affine
	lea .tab(pc),a0
	move.b 0(a0,d0.w),d0
	bra.s .common
.affine:
	muls #150,d0
	sub.l #892,d0
.common:
	add.l d0,d0
	add.l d0,d0						; number of 1/200 to 1/800
	move.l d0,_delay
	move.l (a3)+,flm_snd_size		; size of sound into file
	beq.s .no_sound
	moveq #0,d0
	move (a3)+,d0					; frequency
	move.l d0,frequency
	move #8,sound_bits
	move #1,channels
	move.l sample_num,d0
	move.l max_fsize,d1
	muls d1,d0						; size of frames
	add.l #32,d0					; plus header
	move.l d0,flm_snd_pos		; position in file
.no_sound:
	moveq #0,d0
	rts
.tab: dc.b 14,20,26,36,44,56,80,0

vmas_read_data:
	tst.b step_mode
	bne.s .disp_again
	bsr install_traps
.disp_again:
	clr.l disp_frame
	bsr v_new_palette
	SEEK #32,0				; start of first frame (with palette)
	tst.b step_mode
	bne.s .again
	tst.b playing
	beq.s .nosound
	pea flm_start_sound
	XBIOS 38,6
.nosound:
	trap #10
	move.l d0,start_time
	add.l d0,d0
	add.l d0,d0
	move.l d0,current_time
	bsr.l enh_event0
.again:
	move.l max_fsize,d4		; size to load
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d4,d0
	bne .exit
	move.l buffer,a0
	tst.b cram_bits
	bne.s .fal
	move.l a0,a1
	moveq #15,d0
.inver_pal:
	move (a1),d1
	move d1,d2
	lsr d1
	and #$777,d1
	lsl #3,d2
	and #$888,d2
	or d2,d1
	move d1,(a1)+
	dbf d0,.inver_pal
	bsr kin_read_palette
	bsr vmas_aff_image
	bra.s .timing
.fal:
	bsr vfal_get_palette
	bsr vfal_aff_image
.timing:
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi
	tst.b step_mode
	beq.s .no_step
.bug:
	bsr inc_frame
	beq.s .step_stop
	bpl.s .loop
	bsr save_frame
	bmi.s .bug
.loop:
	move.l sample_num,d0
	addq.l #1,disp_frame
	cmp.l disp_frame,d0
	bne .again
.step_stop:
	bsr.l close_step_dialog
	st stopped
	rts
.no_step:
	move.l current_time,d1	; in 1/800
	add.l _delay,d1
	move.l d1,current_time
	lsr.l #2,d1					; back to 1/200
.delay:
	trap #10
	cmp.l enh_time,d0
	bpl.s .event
	cmp.l d0,d1
	bpl.s .delay
	bra.s .lb0
.event:
	bsr.l enh_event
	bra.s .delay
.lb0:
	move.l sample_num,d0
	addq.l #1,disp_frame
	cmp.l disp_frame,d0
	beq.s .exit
	btst #2,([kbshift])
	bne.s .stop
	bra .again
.exit:
	tst.b playing
	beq.s .no_sound_end
	tst.b snd_value
	bpl.s .yamaha
	trap #11
	beq.s .no_sound_end
	bra.s .test_control
.yamaha:
	tst.b yamaha_flag
	beq.s .no_sound_end
.test_control:
	btst #2,([kbshift])
	beq.s .exit
.no_sound_end:
	tst.b is_rep
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	tst.b playing
	beq.s .no_stop_sound
	bsr stop_all_sounds
.no_stop_sound:
	bra common_end


v_new_palette:
	lea cvid_fix0,a0
	tst.b cram_bits
	bne.s .fal
	moveq #63,d0
.new:
	st (a0)+
	dbf d0,.new		; new palette forced
	rts
.fal:
	move #255,d0
.new_pal:
	st (a0)			; the normal palette has always 0 here
	addq.l #4,a0	; and so $FF is different!
	dbf d0,.new_pal
	rts


vmas_aff_image:
	move.l buffer,a0
	add.w #32,a0
	cmp #8,planes
	bpl _buf_to_tc_256	; on a graphic card or Falcon TC
	move.l physbase,a3	; else, on a simple TT
	add.w #8040,a3
	moveq #99,d7			; 100 lines
.line:
	moveq #4,d6				; 5 times 32 points
.pixels:
	movem.l (a0)+,d0-d3
	movem.l d0-d3,(a3)
	add.w #16,a3
	dbf d6,.pixels
	add.w #80,a3
	dbf d7,.line
	rts

vfal_get_palette:
	lea cvid_fix0,a6
	move #255,d0			; loop
	cmp #16,planes
	bne.s .not_tc
	tst.b nova
	bne.s .nova
.couleur:
	move.w (a0)+,d1
	lsl #5,d1
	move.b (a0)+,d1
	lsl.l #6,d1
	move.b (a0)+,d1
	lsr.l #3,d1
	move d1,(a6)+
	dbf d0,.couleur
	rts
.nova:
	move.w (a0)+,d1
	lsl #5,d1
	move.b (a0)+,d1
	lsl.l #5,d1
	move.b (a0)+,d1
	lsr.l #3,d1
	ror #8,d1
	move d1,(a6)+
	dbf d0,.nova
	rts
.not_tc:
	tst.b is_tt
	bne.s .tt_pal
	move.l a0,a3
	lea indexs,a4
	move d0,d7
.vdi_pal:
	move.l (a3)+,d0		; one color
	cmp.l (a6)+,d0
	beq.s .skip_vdi
	move.l d0,-4(a6)		; new color
	lea vs_int,a0
	move (a4),(a0)+		; index
	swap d0
	lsl #2,d0
	move d0,(a0)+
	swap d0
	move d0,d1
	lsr #6,d1
	move d1,(a0)+
	ror #8,d0
	lsr #6,d0
	move d0,(a0)
	GEM_VDI vs_color
.skip_vdi:
	addq.l #2,a4
	dbf d7,.vdi_pal
	rts
.tt_pal:
	move (a0)+,d1
	lsl #4,d1
	move.b (a0)+,d1
	lsl #4,d1
	move.b (a0)+,d1
	lsr #4,d1
	move d1,(a6)+
	dbf d0,.tt_pal
	pea -512(a6)
	move #256,-(sp)
	clr -(sp)
	XBIOS 84,10
	rts

vfal_aff_image:
	move.l buffer,a1
	add #1024,a1
	moveq #99,d5	; H
	move screenw,a5
	sub #160,a5		; inc
	tst.b is_tt
	bne .tt_256
	move.l image,a0
	cmp #16,planes
	bne .not_tc
	lea cvid_fix0,a6
	add a5,a5
.again:
	moveq #9,d6		; 10 times 16 pixels
.line:
	rept 2
		move (a1)+,d4
		swap d4
		move (a1)+,d2
		swap d2
		move (a1)+,d3
		swap d3
		move (a1)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l d4,-(a1)
	move.l d3,-(a1)
	moveq #0,d0
	move.l d2,-(a1)
	moveq #0,d7
	move.l d1,-(a1)
	move.b (a1)+,d7
	rept 7
		move.b (a1)+,d0
		move (a6,d7.w*2),(a0)+
		move.b (a1)+,d7
		move (a6,d0.w*2),(a0)+
	endr
	move.b (a1)+,d0
	move (a6,d7.w*2),(a0)+
	move (a6,d0.w*2),(a0)+
	dbf d6,.line
	add a5,a0
	dbf d5,.again
	rts
.not_tc:
	moveq #9,d6
.nt_line:
	rept 2
		move (a1)+,d4
		swap d4
		move (a1)+,d2
		swap d2
		move (a1)+,d3
		swap d3
		move (a1)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	move.l d1,(a0)+
	splice d2,d4,d0,d7,8
	move.l d2,(a0)+
	move.l d3,(a0)+
	move.l d4,(a0)+
	dbf d6,.nt_line
	add a5,a0
	dbf d5,.not_tc
	rts
.tt_256:
	move.l a1,a0
	move d5,a2
	move.l physbase,a3
	add.l #44880,a3		; start in screen memory
	lea 320(a3),a5			; double the lines
	move #32,a4
	move #512,a1
.other_line:
	rept 4
	movem.l (a0)+,d0-d7
	movem.l d0-d7,(a3)
	movem.l d0-d7,(a5)
	add a4,a3
	add a4,a5
	endr
	movem.l (a0)+,d0-d7
	movem.l d0-d7,(a3)
	movem.l d0-d7,(a5)
	add a1,a3
	add a1,a5
	subq #1,a2
	cmp #0,a2
	bne.s .other_line
	rts

vmas_read_sound:
	move.l flm_snd_size,d0		; source size
	move.l d0,d5					; saves it
	move.l frequency,d7			; source frequency
	beq.s .end
	tst.b bad_sound
	bne.s .end
	divs d7,d0
	moveq #0,d1
	move d0,d1
	clr d0
	swap d0
	lea real_freq,a0
	sf (a0)
	move.l (a0),d6
	tst.b snd_value
	bmi.s .dma
	move.l #9600,d6		; other sound hardware
.dma:
	move.l #12517,frequency
	muls d6,d1
	muls d6,d0
	divs d7,d0
	ext.l d0
	add.l d0,d1						; dest size of the sound
	move.l d1,snd_size
	addq.l #8,d1					; security
	clr -(sp)
	move.l d1,-(sp)
	GEMDOS 68,8
	move.l d0,snd_temp
	bgt.s .ok
.end:
	rts								; no sound loaded...
.ok:
	move.l d0,a6					; sound ptr
	move #3,-(sp)
	move.l #32768,-(sp)
	GEMDOS 68,8						; temporary buffer
	move.l d0,a5
	tst.l d0
	bmi.s .end
	beq.s .end
	move.l d5,d0
	bsr init_loading_sound
;	movem.l d5-d7,-(sp)
;	moveq #1,d6
;	moveq #1,d7
;	bsr.l manage_tree				; loading sound...
;	movem.l (sp)+,d5-d7
	SEEK flm_snd_pos,0
.again:
	move.l #32768,d4
	cmp.l d4,d5
	bpl.s .enough
	move.l d5,d4
.enough:
	sub.l d4,d5
	move.l a5,a3
	move.l a3,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l flm_snd_size,d0
	sub.l d5,d0
	bsr update_loading_sound
	bsr.s vmas_treat_sound
	tst.l d5
	bgt.s .again
	tst.b snd_value
	bmi.s .no_stop_byte
	clr.b -1(a6)		; end of sound
.no_stop_byte:
	move.l a6,flm_snd_end
	move.l a5,a2
	bsr.l mfree
	tst.l _delay
	beq.s .no_sync
	move.l a6,d0
	sub.l snd_temp,d0			; sound size
	divs d6,d0
	move d0,d1					; q
	clr d0
	swap d0						; r
	muls #800,d1
	muls #800,d0
	divs d6,d0
	ext.l d0
	add.l d0,d1					; number of 1/200 for the whole anim
	move.l sample_num,d0
	divs d0,d1					; number of 1/200 for one image
	ext.l d1
	move.l d1,_delay
.no_sync:
	st playing
	moveq #1,d6
	moveq #-1,d7
	bsr.l manage_tree
	rts

vmas_treat_sound:
	lea 0(a3,d4.l),a0	; end of source
	moveq #0,d2
	moveq #0,d3			; with DMA, 0=0
	tst.b snd_value
	bmi.s .dma
	moveq #1,d3			; else, change 0 with 1
.dma:
	cmp.l d6,d7
	bmi.s .lb3			; greater dest
	bra.s .lb1
.lb0:
	addq.l #1,a3
	cmp.l a0,a3
	bpl.s .end
	add.l d6,d2
	cmp.l d7,d2
	bmi.s .lb0
.lb1:
	move.b (a3),(a6)+
	bne.s .ok1
	move.b d3,-1(a6)
.ok1:
	sub.l d7,d2
	bra.s .lb0
.end:
	rts
.lb2:
	move.b d0,(a6)+
	add.l d7,d2
	cmp.l d6,d2
	bmi.s .lb2
	sub.l d6,d2
.lb3:
	cmp.l a0,a3
	bpl.s .end
	move.b (a3)+,d0
	bne.s .lb2
	move.b d3,d0
	bra.s .lb2

bat_degas:
	tst.b create_mov
	bne.s .create_flm
	tst.b bat_getp
	beq.s .no_pal
	bsr v_new_palette
	move.l buffer,a0
	addq.l #2,a0
	bsr kin_read_palette
.no_pal:
	move.l buffer,a0
	add.l neo_degas_offs,a0					; skips the palette
	tst.b is_tt
	bne.s .tt_direct
	bsr _buf_to_tc_256
	rts
.tt_direct:
	move.l physbase,a3				; the screen
	move #1999,d0
.copy:
	move.l (a0)+,(a3)+
	move.l (a0)+,(a3)+
	move.l (a0)+,(a3)+
	move.l (a0)+,(a3)+
	dbf d0,.copy
	rts
.create_flm:
	bsr update_create_box
	tst.b bat_getp
	beq.s .out
	move.l buffer,a0
	addq.l #2,a0		; to the palette
	lea flm_header+68(pc),a1
		rept 8
		move.l (a0)+,(a1)+	; copies the palette
		endr
.out:
	move.l _flm_phys,a0
	move.l flm_screen,a1
	move #1999,d0
.new_words:
	rept 4
		move.l (a0)+,d1
		eor.l d1,(a1)+		; 0 if unchanged
	endr
	dbf d0,.new_words
	move.l a1,a3			; end of flm-screen
	move.l flm_frame,a0
	move.l (a0)+,d0			; size of previous frame
	move.l d0,(a0)+
	bne.s .lb2
	tst.b slide_degas
	bne.s .lb2					; colors treated with '.getp'
	lea $ffff8240.w,a2		; palette
	lea flm_header+68(pc),a1		; into header
	moveq #15,d0
.lb1:
	move.w (a2)+,(a1)+		; one color
	dbf d0,.lb1
.lb2:
	moveq #8,d0
	move.l d0,(a0)+			; extra datas
	move.l #'time',(a0)+		; ID for time
	move.l degas_div,a1		; if degas_div<>0: FLM synchro with sound
	cmp.l #0,a1
	beq.s .other
	move.l degas_q1,d0
	add.l degas_q,d0
	move.l degas_r1,d1
	add.l degas_r,d1
	cmp.l a1,d1
	bmi.s .glump
	sub.l a1,d1
	addq.l #1,d0
.glump:
	move.l d0,degas_q1
	move.l d1,degas_r1
	move.l d0,(a0)+
	bra.s .next
.other:
	move.l flm_time_ptr,a1	; where to find the time
	add.l flm_ptr_inc,a1		; 12 for AVI, 4 for MOV, 0 for FLI or FLM
	bclr #7,(a1)				; for some key frames...
	move.l (a1),(a0)+			; time in 1/200 of second
	move.l flm_time_inc,d0
	add.l d0,(a1)				; updates the time (usefull with FLI only)
	move.l a1,flm_time_ptr	; updates
.next:
	lea -32000(a3),a1			; flm_screen
.first_offset:
	cmp.l a3,a1
	bpl .nop_frame
	tst (a1)+
	beq.s .first_offset
	subq.l #2,a1
	move.l a1,d0
	move.l flm_screen,d1
	sub.l d1,d0					; first offset
	move.l d0,(a0)+
	addq.l #4,a0				; skips offset to second block
	lea 20000(a0),a2			; second bloc
.no_nul:
	move.l a2,a4				; saves the current position
.loop:
	cmp.l a3,a1
	bpl.s .end_on_NE
	move (a1)+,(a2)+			; into the datas
	bne.s .loop					; not zero, go on!
	subq.l #2,a1
	subq.l #2,a2
.end_on_NE:
	move.l a2,d0
	sub.l a4,d0
	asr.l #1,d0					; number of words to change
.store_codes:
	cmp #257,d0
	bmi.s .stored
	sub #256,d0
	clr.b (a0)+					; no offset
	move.b #$ff,(a0)+			; 128 words to store
	bra.s .store_codes
.stored:
	tst d0
	beq.s .mul_256
	subq #1,d0
	clr.b (a0)+
	move.b d0,(a0)+
.mul_256:
	move.l a1,a4				; saves current position
.loop2:
	cmp.l a3,a1
	bpl.s .end_on_EQ
	tst (a1)+
	beq.s .loop2
	subq.l #2,a1
	move.l a1,d0
	sub.l a4,d0
	asr.l #1,d0					; number of words to skip
	cmp #128,d0
	bpl.s .long_zero
	move.b d0,-2(a0)
	bra.s .no_nul
.long_zero:
	move.b #$7f,-2(a0)
	sub.l #127,d0
	add.l d0,d0
	move.b #$FF,(a0)+
	move.l d0,(a2)+
	bra.s .no_nul
.end_on_EQ:
	move.b #$FD,(a0)+			; end of frame
	move.l flm_frame,a0
	add #28,a0					; start of the codes
	move.l a0,a1
	moveq #-1,d0				; current size
	moveq #0,d1					; for bytes being read
	moveq #0,d2
.reduce_codes:
	move.b (a1)+,d1
	cmp.b #$FD,d1
	beq.s .end_of_reduc
	cmp.b #$FF,d1
	beq.s .one_byte
	move.b (a1)+,d2
	cmp d2,d0
	beq.s .try_it
	move d2,d0					; new size
.no:
	move.b d1,(a0)+
	move.b d2,(a0)+
	bra.s .reduce_codes
.try_it:
	cmp #$7d,d1
	bpl.s .no					; reserved codes (7d, 7e, 7f)
	bset #7,d1
.one_byte:
	move.b d1,(a0)+
	bra.s .reduce_codes
.end_of_reduc:
	move.b d1,(a0)+			; last code
	move.l a0,d0
	addq.l #1,d0
	bclr #0,d0					; word aligned
	move.l d0,a0
	move.l flm_frame,a1
	sub.l a1,d0					; offset for second bloc
	move.l d0,24(a1)			; stored into header
	lea 20028(a1),a3			; start of data zone
.glue_frame:
	move.w (a3)+,(a0)+
	cmp.l a2,a3
	bmi.s .glue_frame
	sub.l a1,a0					; size of this frame
	move.l a0,d0
	bra.s .save_frame
.nop_frame:
	moveq #28,d0
.save_frame:
	addq.l #1,flm_header+12	; number of frames strored
	move.l flm_frame,a0
	addq.l #1,d0
	bclr #0,d0
	move.l d0,(a0)
	cmp.l #28,d0
	bne.s .lb3
	move.l #-1,20(a0)
.lb3:
	lea flm_header+8(pc),a1
	cmp.l (a1),d0				; compared to max_fsize
	bmi.s .lb0
	move.l d0,(a1)
.lb0:
	pea (a0)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; writes that frame
	move.l _flm_phys,a0
	move.l flm_screen,a1
	move #1999,d0
.update:
	rept 4
		move.l (a0)+,(a1)+
	endr
	dbf d0,.update
	rts
.grey_palette:
	dc.w $000,$888,$111,$999,$222,$aaa,$333,$bbb
	dc.w $444,$ccc,$555,$ddd,$666,$eee,$777,$fff

complete_flm_file:
	move #1,-(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS 66,10
	lea flm_header,a3
	move.l d0,(a3)			; size of the file
	clr -(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; start of file
	moveq #100,d0
	tst.l 4(a3)				; no snd ext?
	beq.s .no_ext
	moveq #114,d0			; if extension, 14 bytes more
.no_ext:
	pea (a3)
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12			; write again the header (completed)
	move #2,-(sp)
	move mov_h2,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; back to the end of the file
	rts

init_create_degas:
	tst.l frequency
	bne.s .next
	st bad_sound
.next:
	tst.b bad_sound
	bne.s .create_degas		; no sound alignment
	move.l sample_num,d1
	muls.l frequency,d1
	move.l d1,degas_div
	move.l snd_size,d2
	moveq #100,d0
	cmp #2,channels
	beq.s .ok1
	add.l d0,d0
.ok1:
	muls.l d0,d2
	divsl.l d1,d0:d2
	lea degas_r,a1
	move.l d0,(a1)+
	move.l d2,(a1)
.create_degas:
	move.l #32000,d1		; point d'entree
	bsr.l malloc
	move.l d0,flm_screen
	move.l d0,a0
	moveq #0,d0
	move #1999,d1
.clear:
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	dbf d1,.clear
	move.l #64000,d1
	bsr.l malloc
	move.l d0,flm_frame
	move.l d0,a0
	clr.l (a0)			; size of frame (if 0: first frame!)
	clr -(sp)
	pea out_file
	GEMDOS 60,8
	tst.l d0
	bgt.s .end
	moveq #37,d0		; alert can't create file
	bra.l ooops
.end:
	move d0,mov_h2
	lea flm_header(pc),a0
	clr.l 4(a0)				; extra datas reset
	clr.l 8(a0)				; max_fsize reset
	clr.l 12(a0)			; number of frames reset
	lea .degas(pc),a1
	cmp.l #"dega",comp_txt
	beq.s .ok_info
	addq.l #5,a1
.ok_info:
	move.l (a1)+,25(a0)	; writes Degas or *.NEO
	move.b (a1),29(a0)
	pea (a0)
	moveq #100,d3
	move.l d3,-(sp)
	move d0,-(sp)
	GEMDOS 64,12	; writes the header (not filled)
	lea flm_time,a0
	move.l _delay,(a0)	; start time
	move.l (a0),flm_time_inc	; will add _delay each time
	move.l a0,flm_time_ptr		; memore position
	clr.l flm_ptr_inc		; same memory position
	tst.b bad_sound
	bne .out
	bsr flm_snd_ext
	clr -(sp)
	pea sound_file
	GEMDOS 61,8
	move.l d0,d3
	clr -(sp)
	move d3,-(sp)
	move.l sound_seek,-(sp)
	GEMDOS 66,10		; skips header!
	move.l snd_size,d6		; total size
	move.l d6,d0
	bsr init_loading_sound
	lea flm_snd,a3
	move.l flm_frame,a6
	add.w #256,a6				; don't overwrite frame header
.sound_loop:
	move.l #32768,d5
	cmp.l d5,d6
	bpl.s .ok_size
	move.l d6,d5
.ok_size:
	sub.l d5,d6
	pea (a6)
	move.l d5,-(sp)
	move d3,-(sp)
	GEMDOS 63,12				; reads 32K
	move.l snd_size,d0
	sub.l d6,d0
	bsr update_loading_sound
	bsr.s sign_dma_sound
	add.l d5,10(a3)			; snd size
	addq.l #1,d5
	bclr #0,d5					; even
	pea (a6)
	move.l d5,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12				; writes the same
	tst.l d6
	bne.s .sound_loop
	moveq #14,d0
	add.l 10(a3),d0			; snd + extension
	addq.l #1,d0
	bclr #0,d0					; even
	move.l d0,flm_header+4	; size of extra infos
	move d3,-(sp)
	GEMDOS 62,4					; fclose
	moveq #1,d6
	moveq #-1,d7
	bsr.l manage_tree
.out:
	move.l #'FLM ',d1
	moveq #4,d2
	move.l d1,d3
	bsr init_create_box
	rts
.degas: dc.b "Degas"
	dc.b "*.NEO"

	even

sign_dma_sound:
	cmp.l #'twos',s_signe
	beq.s .end
	move.l a6,a0
	move.l d5,d0
	moveq #-128,d2
.loop:
	add.b d2,(a0)+
	subq.l #1,d0
	bne.s .loop
.end:
	rts

flm_snd_ext:
	lea flm_snd,a0
	move.b channels+1,9(a0)
	moveq #0,d0
	move.l frequency,d1
	addq #1,d0				; 1 for 12,5 kHz
	cmp.l #12517,d1
	beq.s .start
	addq #1,d0
	cmp.l #25033,d1		; 2 for 25 kHz
	beq.s .start
	addq #1,d0				; else 3 for 50 kHz
.start:
	move.b d0,8(a0)
	clr.l 10(a0)			; size reset for now
	pea (a0)
	moveq #14,d0
	move.l d0,-(sp)
	move mov_h2,-(sp)
	GEMDOS 64,12			; writes that little header
	rts

flm_header:
	dc.l 0		; file size
	dc.l 0		; extra datas
	dc.l 0		; max f size
	dc.l 0		; number of frames
	dc.b "M_Player Degas-->Extended FLM",0,0,0
	dc.l $00010000
	dc.w 320,200	; width and height
	dc.w 4		; planes
	dc.b 1,0,0,0,0,8,0,0	; unknown
	dc.w 16		; number of colors
	dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
flm_snd:
	dc.b 'dsnd'
	dc.l 0
	dc.b 0		; channels
	dc.b 0		; freq
	dc.l 0		; sound size


mvi_read_header:
	SEEK #0,0
	moveq #32,d3
	lea cvid_fix0,a3
	pea (a3)
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d0,d3
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	move.l (a3),d0
	lsr.l #8,d0
	cmp.l #$00070402,d0
	bne.s .bug
	addq.l #3,a3
	move.l (a3)+,d0
	INTEL d0
	move.l d0,sample_num
	move.l (a3)+,d0
	INTEL d0
	divs.l #5000,d0			; number of 1/200
	move.l d0,_delay
	move (a3)+,d0
	ror #8,d0
	move d0,max_imagex
	move (a3)+,d0
	ror #8,d0
	move d0,max_imagey
	st bad_comp
	st samp_sizes
	move.l #"mvi ",comp_txt
	move #8,sound_bits
	move #1,channels
	moveq #0,d0
	addq.l #1,a3
	move (a3)+,d0
	ror #8,d0
	move.l d0,frequency
	move.l (a3),d0
	INTEL d0
	move.l d0,snd_size
	move.l d0,mvi_save_size
	move.l d0,d3
	move.l sample_num,d1
	move.l d1,d2
	lsr.l #1,d2		; half
	add.l d2,d0
	divs.l d1,d0	; rounded: number of bytes for one frame
	muls.l d0,d1
	sub.l d1,d3		; the remainder
	move.b d3,mvi_rem
	addq.l #5,d0	; plus offset
	move.l d0,mvi_next_size
	move.l #'rawa',s_signe
	moveq #0,d0
	rts

mvi_read_data:
	bsr install_traps
	moveq #0,d3				; sync flags
	tst.l s_buffer_2
	beq.s .s2
	bset #8,d3
.s2:
	pea start_sound
	XBIOS 38,6
.no_sound:
	trap #10
	move.l d0,start_time	; Timer C
.lb0:
	btst #2,([kbshift])
	bne.s .stop						; control? so quit!
	btst #8,d3
	beq.s .no_remain
	tst.b snd_value
	bmi.s .dma_remain
	tst.b yamaha_flag
	bne.s .lb0
	bsr.l yamaha_next_sound
	bra.s .lb0
.dma_remain:
	trap #11
	bne.s .lb0
	bsr.l next_sound
	bra.s .lb0
.no_remain:
	tst.b snd_value
	bmi.s .dma_quit
	tst.b yamaha_flag
	bne.s .lb0
	bra.s .quit
.dma_quit:
	trap #11
	bne.s .lb0
	bra.s .quit
.stop:
	st stopped
.quit:
	bsr stop_all_sounds
.quit3:
	bra common_end


cd_read_header:
	SEEK #0,0
	moveq #40,d3
	lea cvid_fix0,a3
	pea (a3)
	move.l d3,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d0,d3
	beq.s .ok
.bug:
	moveq #1,d0
	rts
.ok:
	move.l (a3)+,d0
	move.l d0,comp_txt	; compression name
	cmp.l #'CDA1',d0
	beq .sound_file
	moveq #3,d4			; monochrome
	moveq #2,d5
	move.l #cdh1_aff,a0
	cmp.l #'CDH1',d0
	beq.s .found
	moveq #1,d4			; 16 greys
	moveq #0,d5
	move.l #cdl1_aff,a0
	cmp.l #'CDL1',d0
	beq.s .found
	moveq #0,d4			; 256 greys
	moveq #7,d5
	move.l #cdv1_aff,a0
	cmp.l #'CDV1',d0
	bne.s .bug
.found:
	move.l a0,compression
	move d4,cram_bits		; number of planes
	moveq #8,d0
	lsr d4,d0				; grey_depth
	move d0,grey_depth
	move d5,tt_res
	bsr .cd_read_num
	move.l d0,sample_num
	bsr .cd_read_num
	moveq #16,d6			; delay in 1/200
	moveq #0,d5				; no remain
	moveq #1,d2
	move.l d0,snd_size
	beq.s .no_sound
	muls.l #50,d5:d0
	move.l #12517,d2
	move.l d2,frequency
	lsr.l #2,d2
	muls.l sample_num,d2
	divs.l d2,d5:d0
	move.l d0,d6
	move #8,sound_bits
	move #1,channels
.no_sound:
	move.l d6,_delay
	move.l d5,cd_delay
	move.l d2,max_cd_delay
	bsr.s .cd_read_num
	move d0,max_imagex
	move d0,d3
	bsr.s .cd_read_num
	move d0,max_imagey
	move.l d0,imagey		; for qt_raw1 (CDH1)
	muls d0,d3				; d3=number of pixels
	lsr.l d4,d3				; d3=size of one frame
	move.l d3,max_fsize
	bsr.s .cd_read_num	; ??
	st samp_sizes
	move.l snd_size,d1
	beq.s .exit
	move.l sample_num,d0
	muls #6258,d0
	divs.l d1,d2:d0
	lea cd_acc+8,a0
	move d0,(a0)+			; integer
	move.l d2,(a0)+		; remainder
	move.l d1,(a0)			; remainder limit
.exit:
	addq.l #2,a3			; skips 13,10
	sub.l #cvid_fix0,a3	; number of bytes for header
	move.l a3,sound_seek
	cmp.l #'CDV1',comp_txt
	bne.s .no_iff
	bsr.s cd_read_iff_pal
.no_iff:
	tst.b bad_comp
	beq.s .exit_exit
	move.l #cd_nul,compression
.exit_exit:
	moveq #0,d0
	rts
.cd_read_num:
	cmp.b #32,(a3)+
	bmi.s .cd_read_num
	subq.l #1,a3
	moveq #0,d0
	moveq #1,d1
.digit:
	move.b (a3)+,d1
	sub #'0',d1
	bmi.s .end
	add.l d0,d0
	move.l d0,d2
	add.l d2,d2
	add.l d2,d2
	add.l d2,d0		; x 10
	add.l d1,d0		; + digit
	bra.s .digit
.end:
	subq.l #1,a3
	rts
.sound_file:
	bsr.s .cd_read_num	; number of 6258 bytes (maybe...)
	move.l #12517,frequency
	move #1,channels
	move #8,sound_bits
	bra.s .exit

cd_read_iff_pal:
	move.l fname_pos,a0
.lb1:
	move.b (a0)+,d0		; one character of the name
	beq.s .lb2				; end reached, no extension
	cmp.b #'.',d0
	bne.s .lb1
.lb2:
	subq.l #2,a0
	move.b #'1',(a0)+		; xxxx1.IFF
	move.l #'.IFF',(a0)+	; new extension
	clr.b (a0)				; end of string
	clr -(sp)
	pea full2				; tries to open IFF file
	GEMDOS 61,8				; fopen
	move d0,d7				; handle of the file is saved
	bmi.s .bug
	lea cvid_fix1,a3
.loop:
	move.l a3,-(sp)
	moveq #8,d0
	move.l d0,-(sp)
	move d7,-(sp)
	GEMDOS 63,12
	move.l (a3),d0			; id
	move.l 4(a3),d1		; size
	cmp.l #'FORM',d0
	bne.s .id2
	moveq #4,d1				; skip
	bra.s .skip
.id2:
	cmp.l #'BODY',d0
	beq.s .close_bug		; if BODY, then CMAP not found!!!
	cmp.l #'CMAP',d0
	beq.s .found_pal
.skip:
	move #1,-(sp)
	move d7,-(sp)
	move.l d1,-(sp)
	GEMDOS 66,10			; fseek D1 bytes
	tst.l d0
	bmi.s .close_bug
	bra.s .loop
.found_pal:
	move.l #$01000000,(a3)+	; one bloc, 256 colors
	move.l a3,-(sp)
	move.l d1,-(sp)		; size of CMAP
	move d7,-(sp)
	GEMDOS 63,12
	move d7,-(sp)
	GEMDOS 62,4
	rts
.close_bug:
	move d7,-(sp)
	GEMDOS 62,4
.bug:
	st bad_comp
	rts

cd_calc_loops:
	lea cd_acc,a0
	move.l (a0)+,d0	; remainder
	move (a0)+,d1	; integer
	add.l 4(a0),d0
	add 2(a0),d1
	cmp.l 8(a0),d0
	bmi.s .end
	sub.l 8(a0),d0
	addq #1,d1
.end:
	move d1,d2		; how many
	tst d0
	beq.s .lb0
	addq #1,d2
.lb0:
	sub d2,d1		; 0 or -1
	subq #1,d2		; for the loop
	move d2,(a0)
	move d1,-(a0)
	move.l d0,-(a0)
	rts

cd_sound_size:
	move.l #6258,d0
	lea cd_sound_count,a0
	cmp.l (a0),d0
	bmi.s .enough
	move.l (a0),d0
	clr.l (a0)
	rts
.enough:
	sub.l d0,(a0)
	rts

cd_read_data:
	bsr tt_calc_image
	bsr install_traps
	cmp.l #'CDH1',comp_txt
	bne.s .disp_again
	tst.b is_tt
	beq.s .other
	pea .mono(pc)
	XBIOS 38,6
	bra.s .disp_again
.mono:	
	clr $ffff8240.w
	move #$FFF,$ffff8242.w
	rts
.other:
	lea vs_int,a3
	clr.l (a3)+
	clr.l (a3)+
	GEM_VDI vs_color
	move #1000,d0
	move d0,-(a3)
	move d0,-(a3)
	move d0,-(a3)
	moveq #1,d0
	move d0,-(a3)
	GEM_VDI vs_color
.disp_again:
	clr.l disp_frame
	clr.l gif_image
	move.l snd_size,cd_sound_count
	bsr cd_sound_size
	add.l #40,d0
	SEEK d0,0				; start of data
	lea cd_acc,a0
	clr.l (a0)+
	clr (a0)
	bsr cd_calc_loops
	tst.b playing
	beq.s .nosound
	pea flm_start_sound
	XBIOS 38,6
.nosound:
	trap #10
	move.l d0,start_time
	move.l d0,current_time
	bsr.l enh_event0
	clr.l cd_delay_acc
.again:
	tst.l frequency
	beq.s .no_sound_skip
	cmp.l #1,gif_image
	beq.s .skip
	subq.w #1,cd_acc+6
	bpl.s .no_sound_skip
	bsr cd_calc_loops
.skip:
	bsr cd_sound_size
	SEEK d0,1			; relative skip
.no_sound_skip:
	move.l max_fsize,d4		; size to load
	moveq #0,d1
	lea cd_delay_acc,a0
	move.l (a0)+,d0
	add.l (a0)+,d0
	cmp.l (a0),d0
	bmi.s .zzz
	sub.l (a0),d0
	moveq #1,d1
.zzz:
	move.l d0,-8(a0)
	addq.l #4,a0
	add.l (a0)+,d1
	add.l (a0),d1
	tst.b sync
	bne.s .ok
	trap #10
	move.l d0,d1	; false_time
	addq.l #2,d1		; + 1/100
.ok:
	move.l d1,(a0)
	addq.l #1,gif_image
	trap #10
	cmp.l d0,d1
	bpl.s .aff
	SEEK d4,1
	bra.s .no_timing
.aff:
	move.l buffer_16,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	cmp.l d4,d0
	bne.s .exit
	move.l compression,a0
	jsr (a0)
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	addq.l #1,disp_frame
	move.l current_time,d1
.delay:
	trap #10
	cmp.l enh_time,d0
	bpl.s .event
	cmp.l d0,d1
	bpl.s .delay
	bra.s .no_timing
.event:
	bsr.l enh_event
	bra.s .delay
.no_timing:
	move.l sample_num,d0
	cmp.l gif_image,d0
	beq.s .exit
	btst #2,([kbshift])
	bne.s .stop
	bra .again
.exit:
	tst.b playing
	beq.s .no_sound_end
	tst.b snd_value
	bpl.s .yamaha
	trap #11
	beq.s .no_sound_end
	bra.s .test_control
.yamaha:
	tst.b yamaha_flag
	beq.s .no_sound_end
.test_control:
	btst #2,([kbshift])
	beq.s .exit
.no_sound_end:
	tst.b is_rep
	bne .disp_again
	bra.s .normal_out
.stop:
	st stopped
.normal_out:
	tst.b playing
	beq.s .no_stop_sound
	bsr stop_all_sounds
.no_stop_sound:
	bra common_end


cd_play_sound:
	clr.l -(sp)
	GEMDOS 32,6
	move.l d0,stack_adr
	tst.b playing
	beq.s .exit
	bsr.l flm_start_sound
.exit:
	tst.b playing
	beq.s .normal_out
	tst.b snd_value
	bpl.s .yamaha
	btst #0,$ffff8901.w
	beq.s .normal_out
	bra.s .test_control
.yamaha:
	tst.b yamaha_flag
	beq.s .normal_out
.test_control:
	btst #2,([kbshift])
	beq.s .exit
	st stopped
.normal_out:
	tst.b playing
	beq.s .no_stop_sound
	tst.b snd_value
	bmi.s .dma
	move sr,d0
	move #$2700,sr
	move.l yamaha_ptr,a0
	clr.b (a0)+
	clr.b (a0)
	move d0,sr
	bra.s .no_stop_sound
.dma:
	clr.b $ffff8901.w
.no_stop_sound:
	move.l $4ba.w,end_time
	move.l stack_adr,-(sp)
	GEMDOS 32,6
	rts



tt_calc_image:
	tst.b is_tt
	bne.s .ok
	rts
.ok:
	move max_imagex,d0
	move max_imagey,d1
	lea .data(pc),a0
	move.l comp_txt,d2
	cmp.l #'CDH1',d2
	beq.s .found
	addq.l #8,a0
	cmp.l #'CDL1',d2
	beq.s .found
	addq.l #8,a0
.found:
	move (a0)+,d3		; height
	muls (a0)+,d1		; double?
	sub d1,d3
	lsr #1,d3
	move (a0)+,d1		; width
	muls d1,d3			; complete lines
	sub d0,d1
	lsr #1,d1
	add #15,d1
	and #$fff0,d1
	ext.l d1
	add.l d1,d3			; upper left in pixels
	move (a0)+,d0		; shifts
	lsr.l d0,d3
	add.l physbase,d3
	move.l d3,image
	rts
.data: dc.w 400,1,640,3,200,1,320,1,480,2,320,0

cdh1_aff:
	move.l buffer_16,a0
	tst.b is_tt
	beq.s .lb2
	move.l image,a3
	move #640,d3
	move max_imagex,d2
	add #15,d2
	and #$fff0,d2
	sub d2,d3
	lsr #3,d3
	lsr #4,d2
	subq #1,d2
	move max_imagey,d4
	subq #1,d4
.line:
	move d2,d1
.pixel:
	move (a0)+,(a3)+
	dbf d1,.pixel
	add d3,a3
	dbf d4,.line
	rts
.lb2:
	move.l a0,a2
	cmp #16,planes
	bne.s .lb0
	bra.l qt_raw1+6
.lb0:
	cmp #8,planes
	bne.s .lb1
	bra.l qt_raw1_256+6
.lb1:
	rts

cdl1_aff:
	move.l buffer_16,a0
	tst.b is_tt
	beq _buf_to_tc_256
	move.l image,a3
	move #320,d3
	move max_imagex,d2
	add #15,d2
	and #$fff0,d2
	sub d2,d3
	lsr #1,d3
	lsr #4,d2
	subq #1,d2
	move max_imagey,d4
	subq #1,d4
.line:
	move d2,d1
.pixel:
	move.l (a0)+,(a3)+
	move.l (a0)+,(a3)+
	dbf d1,.pixel
	add d3,a3
	dbf d4,.line
	rts

cdv1_aff:
	move.l buffer_16,a0
	move.l image,a3
	move screenw,d3
	tst.b is_tt
	bne cdv1_tt
	sub max_imagex,d3
	move max_imagey,d6
	subq #1,d6
	cmp #16,planes
	bne .not_tc
	lea cvid_fix0,a6
	add d3,d3
	move d3,a5
.again:
	move max_imagex,d5
	add #15,d5
	lsr #4,d5
	subq #1,d5
.line:
	rept 2
		move (a0)+,d4
		swap d4
		move (a0)+,d2
		swap d2
		move (a0)+,d3
		swap d3
		move (a0)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	splice d2,d4,d0,d7,8
	move.l d4,-(a0)
	move.l d3,-(a0)
	moveq #0,d0
	move.l d2,-(a0)
	moveq #0,d7
	move.l d1,-(a0)
	move.b (a0)+,d7
	rept 7
		move.b (a0)+,d0
		move (a6,d7.w*2),(a3)+
		move.b (a0)+,d7
		move (a6,d0.w*2),(a3)+
	endr
	move.b (a0)+,d0
	move (a6,d7.w*2),(a3)+
	move (a6,d0.w*2),(a3)+
	dbf d5,.line
	add a5,a3
	dbf d6,.again
	rts
.not_tc:
	move d3,a5
.tc_again:
	move max_imagex,d5
	add #15,d5
	lsr #4,d5
	subq #1,d5
.tc_line:
	rept 2
		move (a0)+,d4
		swap d4
		move (a0)+,d2
		swap d2
		move (a0)+,d3
		swap d3
		move (a0)+,d1
		swap d1
	endr
	move.l #$55555555,d0
	splice d1,d3,d0,d7,1
	splice d2,d4,d0,d7,1
	move.l #$33333333,d0
	splice d1,d2,d0,d7,2
	splice d3,d4,d0,d7,2
	swap d4
	swap d2
	eor d3,d4
	eor d1,d2
	eor d4,d3
	eor d2,d1
	eor d3,d4
	eor d1,d2
	swap d4
	swap d2
	move.l #$0F0F0F0F,d0
	splice d1,d2,d0,d7,4
	splice d3,d4,d0,d7,4
	move.l #$00FF00FF,d0
	splice d1,d3,d0,d7,8
	move.l d1,(a3)+
	splice d2,d4,d0,d7,8
	move.l d2,(a3)+
	move.l d3,(a3)+
	move.l d4,(a3)+
	dbf d5,.tc_line
	add a5,a3
	dbf d6,.tc_again
	rts
cdv1_tt:
	move max_imagex,d2
	add #15,d2
	and #$fff0,d2
	add d3,d3
	sub d2,d3
	lsr #4,d2
	subq #1,d2
	move max_imagey,d4
	subq #1,d4
.line:
	move d2,d1
	lea 320(a3),a1		; second line
.pixel:
	movem.l (a0)+,d5-d7/a2
	movem.l d5-d7/a2,(a3)
	lea 16(a3),a3
	movem.l d5-d7/a2,(a1)
	lea 16(a1),a1
	dbf d1,.pixel
	add d3,a3
	dbf d4,.line
	rts

cd_read_sound:
	sf playing
	tst.b bad_sound
	bne .end				; bad sound any_way
	tst.l frequency
	beq .end				; no sound!
	move.l snd_size,d7
	tst.b snd_value
	bmi.s .dma1
	move.l d7,d0
	move.l d0,d1
	lsl.l #3,d1
	add.l d1,d0
	add.l d1,d1
	add.l d1,d0			; x 25
	lsr.l #5,d0			; /32 ~ x.78 (>9600/12516)
	add.l #2000,d0		; security (6258 > 4800)
	move #3,-(sp)		; TT Ram is better (cause faster!)
	move.l d0,-(sp)
	bra.s .no_dma
.dma1:
	clr -(sp)				; ST ram only
	move.l d7,-(sp)
.no_dma:
	GEMDOS $44,8			; mxalloc
	tst.l d0
	bmi .end				; alloc error
	beq .end
	move.l d0,snd_temp
	move.l d0,d6
	move.l d7,d0
	bsr init_loading_sound
;	movem.l d6-d7,-(sp)
;	moveq #1,d6
;	moveq #1,d7
;	bsr.l manage_tree
;	movem.l (sp)+,d6-d7
	SEEK sound_seek,0
	move.l d6,d0
	add.l d7,d0
	move.l d0,flm_snd_end
	tst.l max_fsize
	beq.s .sound_file
	bsr.s .load_one
	SEEK max_fsize,1
	bsr.s .load_one
	lea cd_acc,a0
	clr.l (a0)+
	clr (a0)
	bsr cd_calc_loops
.loop:
	move cd_acc+6,d0
	ext.l d0
	move.l max_fsize,d1
	muls.l d0,d1
	SEEK d1,1
	bsr cd_calc_loops
	addq #1,cd_acc+6
	bsr.s .load_one
	tst.l d7
	bne.s .loop
.exit:
	moveq #1,d6
	moveq #-1,d7
	bsr.l manage_tree
	st playing
.end:
	rts
.sound_file:
	bsr.s .load_one
	tst.l d7
	bne.s .sound_file
	bra.s .exit
.load_one:
	move.l #6258,d0
	cmp.l d0,d7
	bpl.s .load_enough
	move.l d7,d0
.load_enough:
	sub.l d0,d7
	move.l d6,-(sp)
	move.l d0,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l d0,-(sp)
	move.l snd_size,d0
	sub.l d7,d0
	bsr update_loading_sound
	move.l (sp)+,d0
	tst.b snd_value
	bpl.s .adapt
	add.l d0,d6
	rts
.adapt:
	move.l d6,a0	; source
	move.l d6,a1	; dest
	lea 0(a0,d0.l),a2	; end
	moveq #0,d0
	moveq #1,d1
	bra.s .lb1
.lb0:
	addq.l #1,a0
	cmp.l a2,a0
	bpl.s .treated
	add.l #19200,d0
	cmp.l #25033,d0
	bmi.s .lb0
.lb1:
	move.b (a0),(a1)+
	bne.s .ok1
	move.b d1,-1(a1)
.ok1:
	sub.l #25033,d0
	bra.s .lb0
.treated:
	move.l a1,d6	; new end of sample
	rts

TAB_AUDIO_DVI_PAS:
 DC.W     7,    8,    9,   10,   11,   12,   13,   14,   16,   17
 DC.W    19,   21,   23,   25,   28,   31,   34,   37,   41,   45
 DC.W    50,   55,   60,   66,   73,   80,   88,   97,  107,  118
 DC.W   130,  143,  157,  173,  190,  209,  230,  253,  279,  307
 DC.W   337,  371,  408,  449,  494,  544,  598,  658,  724,  796
 DC.W   876,  963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066
 DC.W  2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358
 DC.W  5894, 6484, 7132, 7845, 8630, 9493,10442,11487,12635,13899
 DC.W 15289,16818,18500,20350,22385,24623,27086,29794,32767

cache_sav: dc.l 0

cache_off:
	movem.l d0-d2/a0-a2,-(sp)
	pea invalid_cache(pc)
	XBIOS 38,6
	movem.l (sp)+,d0-d2/a0-a2
	rts
invalid_cache:
	movec CACR,d0
	move.l d0,cache_sav
	cmp #40,cpu_value+2
	bpl.s .hades
	ori #$0808,d0
	movec d0,CACR
	rts
.hades:

;	movec CACR,d0
;	and.l #$6FFF7FFF,d0
;	movec d0,CACR
	rts

cache_on:
	movem.l d0-d2/a0-a2,-(sp)
	pea restore_cache(pc)
	XBIOS 38,6
	movem.l (sp)+,d0-d2/a0-a2
	rts
restore_cache:
	cmp #40,cpu_value+2
	bpl.s .hades
	move.l cache_sav(pc),d0
	movec d0,CACR
	rts
.hades:
	dc.w $F4F8		; flush instruction cache
	rts

INIT_TAB_IMA4:
	MOVEM.L D0-D4/A0-A1,-(SP)
   LEA TAB_AUDIO_DVI_PAS(pc),A0
   LEA DVI_DELTA,A1
   MOVE #88,D2
.lb1:
	MOVEQ #0,D4;delta
   MOVEQ #15,D3
.lb2:
   MOVE (A0),D1
   MOVEQ #0,D0
   BTST #2,D4
   BEQ.S .lb3
   ADD D1,D0;+ pas
.lb3:
   LSR #1,D1
   BTST #1,D4
   BEQ.S .lb4
   ADD D1,D0;+ 1/2 pas
.lb4:
   LSR #1,D1
   BTST #0,D4
   BEQ.S .lb5
   ADD D1,D0;+ 1/4 pas
.lb5:
   LSR #1,D1
   ADD D1,D0;+ 1/8 pas
   BTST #3,D4;signe
   BEQ.S .lb6;positif
   NEG D0
.lb6:
   MOVE D0,(A1)+
   addq #1,D4
   DBRA D3,.lb2
   ADDQ #2,A0
   DBRA D2,.lb1
   MOVEM.L (SP)+,D0-D4/A0-A1
   RTS

TAB_AUDIO_DVI_INDEX:
 DC.W -1,-1,-1,-1,2,4,6,8
 DC.W -1,-1,-1,-1,2,4,6,8

DECOMPRESS_IMA4:
	; A4 cible 16 bits
	; A2 compresse
	; d6 taille compressee
	;D1.W:mode avec B0: mono(0)/st‚r‚o(1)
	;  B1: 8 bits (0)/16 bits(1)
	;  B2: deltapack_ima4
	;au retour dans D0.L: longueur

   BTST #2,D1;mode: B0: mono(0)/st‚r‚o(1), B1: 8 bits(0)/16 bits(1)
			;  B2: deltapack ima4/dvi, B3:deltapack adpcm, B4:ulaw
   BEQ .lb1
   BTST #1,D1		;8 bits (0)/16 bits(1)
   BEQ .lb1
   MOVEM.L D1-A5,-(SP)
   MOVE.L A4,-(SP)
   MOVE D1,-(SP)							;mode
   LEA TAB_AUDIO_DVI_INDEX(pc),A0
   LEA DVI_DELTA,A1
   MOVE.L A2,A3							;buffer voie gauche
   LEA 0.w,A5									;compteur bloc
   MOVE.L d6,D7
   BLE .lb8
   ADD #$22,A3								;buffer voie droite ‚ventuelle
.lb6:
	MOVE (A2)+,D0
   SUBQ.L #2,D7
   MOVE D0,D4
   AND #$7F,D4								;index voie gauche
   CMP #88,D4
   BLS.S .lb3
   MOVE #88,D4
.lb3:
   AND #$FF80,D0
   MOVE D0,D2								;‚chantillon voie gauche
   BTST #0,1(SP)							;mono(0)/st‚r‚o(1)
   BEQ.S .lb9								;mono
   MOVE (A3)+,D0
   SUBQ.L #2,D7
   MOVE D0,D5
   AND #$7F,D5								;index voie droite
   CMP #88,D5
   BLS.S .lb2
   MOVE #88,D5
.lb2:
   AND #$FF80,D0
   MOVE D0,D3								;‚chantillon voie droite
.lb9:
   MOVE #$22-2,A5							;taille bloc -> compteur bloc
.lb4:
   subq #1,A5									;compteur bloc
   MOVE.B (A2)+,D1
   MOVE.B D1,D6							;! quartet poids forts et poids faible invers‚s dans un ancien format
   AUD_CALC_DVI D2,D1,D4,A0,A1
   MOVE D2,(A4)+							;‚chantillon voie gauche ou mono
   LSR.B #4,D6
   AUD_CALC_DVI D2,D6,D4,A0,A1
   BTST #0,1(SP)							;mono(0)/st‚r‚o(1)
   BEQ .lb7									;mono
   MOVE.B (A3)+,D1
   MOVE.B D1,D6
   AUD_CALC_DVI D3,D1,D5,A0,A1
   MOVE D3,(A4)+							;‚chantillon voie droite
   LSR.B #4,D6
   AUD_CALC_DVI D3,D6,D5,A0,A1
   MOVE D2,(A4)+							;‚chantillon voie gauche
   MOVE D3,(A4)+							;‚chantillon voie droite
   SUBQ.L #2,D7							;compteur octets
   BLE.S .lb8
   MOVE A5,D0								;compteur bloc
   BGT .lb4
   ADD #$22,A2								;saute la 2Šme voie
   ADD #$22,A3
   BRA .lb6
.lb7:
   MOVE D2,(A4)+							;‚chantillon mono
   SUBQ.L #1,D7							;compteur octets
   BLE.S .lb8
   MOVE A5,D0								;compteur bloc
   BGT .lb4
   BRA .lb6
.lb8:
	ADDQ #2,SP
   MOVE.L A4,D0
   SUB.L (SP)+,D0							;longueur en octets
   MOVEM.L (SP)+,D1-A5
.lb1:
	RTS

wind_get: dc.l wg_cont,global,wg_int,window0,dum,dum
wg_cont: dc.w 104,2,5,0,0
wg_int: dc.w 0,4

window_use:
	move.l d0,-(sp)
	GEM_AES wind_get	; work size of window 0
	lea _dialog_table,a0
	move.l 4*LAST_TREE(a0),a0	; structure step by step dialog
	lea window0,a1
	move.l (a0),a2		; tree address
	move.l 12(a0),d0	; ext coords
	sub.l d0,4(a0)		; int coord as offsets
	sub.l d0,16(a2)	; same for 1st object
	move.l 2(a1),d0	; window0 x,y
	move.l d0,12(a0)	; as start x,y for dialog
	add.l d0,4(a0)		; +offset for int coords
	add.l d0,16(a2)	; same for 1st object
	move.l (sp)+,d0
	tst (a1)				; intout de wind_get
	beq.s .error
	cmp #16,d0			; number of planes on desktop
	spl can_win			; $FF if window allowed
.error:
	rts

wind_calc: dc.l wc_cont,global,wc_int2,wc_int+2,dum,dum
wc_cont: dc.w 108,6,5,0,0

try_window:
	tst.b slide_flag
	bne.s .end			; no window with slideshow of anims
	tst.b step_vdi
	bne.s .try_it
	tst.b can_win
	beq.s .end
.try_it:
	sf is_win
	lea wc_int2,a0
	clr (a0)+			; calc from work to full
	move #1,(a0)+		; kind of window (only title)
	move offsx+2,(a0)+
	move offsy,(a0)+
	tst.b vr2_flag
	beq.s .no_vr2
	move vr2_x+2,(a0)+
	move vr2_y+2,(a0)+
	bra.s .common
.no_vr2:
	move max_imagex,(a0)+
	move max_imagey,d0
	tst.b enh_flag
	beq.s .no_extra
	add enh_extra,d0
.no_extra:
	move d0,(a0)
.common:
	GEM_AES wind_calc
	lea wc_int+2,a0
	tst (a0)
	bne.s .ok
.end:
	rts
.ok:
	move #1,(a0)+		; for eventually wind_create
	lea window0+2,a1
	move (a1)+,d1
	move (a0)+,d0
	cmp d1,d0
	bmi.s .end			; bad x
	move (a1)+,d3
	move (a0)+,d2
	cmp d3,d2
	bmi.s .end			; bad y
	add (a1)+,d1
	add (a0)+,d0
	cmp d0,d1
	bmi.s .end			; bad x'
	add (a1),d3
	add (a0),d2
	cmp d2,d3
	bmi.s .end			; bad y'
	GEM_AES wind_create
	move wc_int+2,d7
	beq.s .end
	st is_win
	lea ws_int,a0
	move d7,(a0)+	; handle
	move #2,(a0)+	; TITLE
	move.l fname_pos,(a0)	; string address
	GEM_AES wind_set
	GEM_AES wind_open
	move #3,fd_int
	GEM_AES form_dial		; screen updates
	rts

wind_create: dc.l wcr_cont,global,wc_int+2,wc_int+2,dum,dum
wcr_cont: dc.w 100,5,1,0,0

wind_open: dc.l wo_cont,global,wc_int+2,dum,dum,dum
wo_cont: dc.w 101,5,1,0,0

treat_w_button:
	lea 467(a1),a0
	move.b (a0),d0
	move.l a0,DVI_DELTA	; if coords...
	tst.b can_win
	beq.s .disable
	btst #3,d0		; disabled?
	beq.s .enabled
	sf can_win		; if disabled, no WINDOW at all
	bra.s .disable
.enabled:
	btst #0,d0		; selected?
	sne can_win
	rts
.disable:
	and.b #$FE,d0	; not selected
	or.b #$08,d0		; and disabled
	move.b d0,(a0)
	rts

wind_set: dc.l ws_cont,global,ws_int,dum,dum,dum
ws_cont: dc.w 105,6,1,0,0

wind_close: dc.l wcl_cont,global,ws_int,dum,dum,dum
wcl_cont: dc.w 102,1,1,0,0

treat_vr_box:
	moveq #11,d6	; simulates 'OK'
	tst.b step_mode
	beq.s .lb0
	sf vr_flag		; no VR mode with step mode
	rts
.fin:
	move.l tree,a0
	btst #0,371(a0)
	sne vr_clic+1
	btst #0,443(a0)
	sne vr2_def
	rts
.lb0:
	tst.b vr_flag
	beq.s .fin		; no VR anyway...
	moveq #5,d0
	GADDR d0,1
	btst #0,227(a0)	; box 'do not display'
	bne.s .fin
	bclr #3,83(a0)
	bclr #3,131(a0)
	cmp #1,vr_x
	bne.s .lb1
	bset #3,83(a0)
	bset #3,131(a0)	; no x movement
.lb1:
	bclr #3,107(a0)
	bclr #3,155(a0)
	cmp #1,vr_y
	bne.s .lb2
	bset #3,107(a0)
	bset #3,155(a0)	; no y movement
.lb2:
	bclr #3,443(a0)
	bclr #3,467(a0)	; def allowed
	tst.b vr2_flag
	bne.s .no_def
	bset #3,443(a0)
	bset #3,467(a0)
.no_def:
	moveq #5,d6
	moveq #0,d7
	bsr.l manage_tree
	cmp #13,d6
	bne .fin
	sf vr_flag
	sf vr2_flag
	rts


wind_delete: dc.l wd_cont,global,ws_int,dum,dum,dum
wd_cont: dc.w 103,1,1,0,0

parse_disk:
	moveq #7,d6
	moveq #0,d7
	bsr.l manage_tree
	cmp #23,d6				; cancel?
	beq .fin
	move.l tree,a0
	add.w #24*3+11,a0		; select du 3eme element
	moveq #19,d0			; 20 boutons a tester
	cmp #25,d6				; select all?
	bne.s .lb0
.all:
	btst #3,(a0)			; disabled?
	bne.s .skip				; yes, don't select
	bset #0,(a0)			; else select
.skip:
	add #24,a0				; next object
	dbf d0,.all
	bra.s parse_disk
.lb0:
	cmp #26,d6				; deselect all?
	bne.s .lb1
.none:
	bclr #0,(a0)
	add #24,a0
	dbf d0,.none
	bra.s parse_disk
.lb1:						; par defaut bouton 24=START
	lea cvid_fix1,a1
	moveq #0,d7			; nombre d'extensions choisies
.sel:
	btst #0,(a0)
	beq.s .lb2
	move.l 1(a0),a2	; texte du bouton *.xxx
	move.l 1(a2),(a1)+	; partie .xxx copiee
	addq #1,d7
.lb2:
	add #24,a0
	dbf d0,.sel
	tst d7
	beq.s .fin			; rien de choisi!!!
	bsr.s _open_parse_bat
	beq.s .fin			; annulation ou erreur
	bsr _parse
	pea .batch3(pc)
	moveq #7,d4
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 64,12
	st samp_sizes
	rts
.fin:
	st stopped
	rts
.batch3: dc.b ".stop",13,10		; 7 car
	even	

vsf_color: dc.l vc_cont,vi_int,dum,dum,dum
vc_cont: dc.w 25,0,0,1,0,0,0,0,0,0,0,0

_open_parse_bat:
;	clr mf_int
;	GEM_AES graf_mouse				; the arrow
;	GEM_VDI show_mouse
	lea fs_addrin_parse,a0
	bsr get_file
	beq.s .gloups							; if abort, quits
	lea path(pc),a0
	lea full(pc),a1
	move.l #file,d1
	bsr full_pathname
	clr -(sp)
	pea full(pc)
	GEMDOS 60,8
	tst.l d0
	bmi.s .gloups
	move d0,mov_h
	pea .batch2(pc)
	moveq #10,d4
	move.l d4,-(sp)
	move d0,-(sp)
	GEMDOS 64,12
	cmp.l d4,d0
	bne.s .gloups
	moveq #1,d0
	rts
.gloups:
	moveq #0,d0
	rts
.batch2: dc.b "SLIDEANI",13,10	; 10 car
	even

_parse:
	move.l d7,-(sp)
	lea _dialog_table,a1
	move.l 32(a1),a1		; structure "searching files"
	move.l (a1),a1			; arbre
	move.l 48+12(a1),a1	; tedinfo
	move.l (a1),a1			; chaine (enfin...)
.find_space:
	cmp.b #' ',(a1)+
	bne.s .find_space		; dŠs l'espace, a1 pointe sur le premier z‚ro
	rept 6
		move.b #'0',(a1)+
	endr
	move.l a1,.zero
	moveq #8,d6
	moveq #1,d7
	bsr.l manage_tree				; searching files
	move.l (sp)+,d7
	pea .debut(pc)
	XBIOS 38,6
	moveq #0,d6						; niveau de base
	move.l fname_pos,a5			; pointeur dans le nom
	clr.b (a5)						; termine
	lea full2(pc),a3
	move (a3),d0
	cmp.b #":",d0					; un nom de lecteur?
	bne.s .setpath
	lsr #8,d0						; le nom
	move.l #$FFDFDFDF,d3			; masque pour les extensions en majuscules
	sub #"A",d0
	move d0,-(sp)
	GEMDOS 14,4
	addq.l #2,a3
.setpath:
	move.l a3,-(sp)
	GEMDOS 59,6
	tst.l d0
	bmi .fin							; path not found
	lea cvid_fix1,a3			; pointe sur les extensions
	subq #1,d7						; pour les boucles
	lea 100(a3),a4					; premiŠre DTA
.dossier:
	movem.l d3-d7/a3-a6,-(sp)
	move.l .zero(pc),a1
.incremente
	addq.b #1,-(a1)
	cmp.b #"9"+1,(a1)
	bne.s .fin_incr
	move.b #"0",(a1)
	bra.s .incremente
.fin_incr:
	lea _dialog_table,a3
	move.l 32(a3),a3
	moveq #2,d6
	moveq #0,d0
	bsr wdial_change
	moveq #8,d6
	moveq #1,d7
	bsr.l manage_tree				; mettre a jour a chaque dossier
	movem.l (sp)+,d3-d7/a3-a6
	addq.l #1,sample_num
	move.l a4,-(sp)
	GEMDOS 26,6						; fixe ma DTA
	move #-1,-(sp)
	pea .batch4(pc)
	GEMDOS 78,8						; fsfirst
	bra.s .autre
.next:
	GEMDOS 79,2
.autre:
	tst.l d0
	bmi .fin_dossier
	move.b 21(a4),d0				; attrib
	btst #4,d0						; dossier?
	bne.s .zyva
	move.l a5,a1
	lea 30(a4),a0
	moveq #0,d1
.cpy_name:
	move.b (a0)+,d0
	beq.s .lb1
	cmp.b #".",d0
	bne.s .lb0
	move.l -1(a0),d1				; extension
.lb0:
	move.b d0,(a1)+
	bra.s .cpy_name
.lb1:
	and.l d3,d1						; en majuscules pour la comparaison
	move d7,d0						; compteur
	move.l a3,a0					; les extensions
.lb2:
	cmp.l (a0)+,d1
	beq.s .lb3
	dbf d0,.lb2
	bra.s .next
.lb3:
	move.w #$0d0a,(a1)+
	lea full2(pc),a0
	sub.l a0,a1						; taille
	move.l a0,-(sp)
	move.l a1,-(sp)
	move mov_h,-(sp)
	GEMDOS 64,12					; fwrite
	addq.l #1,disp_frame
	bra.s .next
.zyva:
	move 30(a4),d0					; deux lettres
	cmp #"..",d0
	beq.s .next
	cmp #$2e00,d0
	beq.s .next
	and #$FF00,d0
	beq.s .next						; si il est nul, ignorer

	pea 30(a4)
	GEMDOS 59,6						; nouveau dossier
	tst.l d0
	bmi .next						; path not found, autre dossier
	lea 30(a4),a0					; nom
	add #44,a4						; saute la DTA
	move.l a5,(a4)+
.lb4:
	move.b (a0)+,(a5)+			; ajoute dossier
	bne.s .lb4
	move.b #"\",-1(a5)			; et modifie fname pos
	addq #1,d6
	bra .dossier
.fin_dossier:
	subq #1,d6
	bmi.s .fin
	move.l -(a4),a5				; vieux fname pos
	sub #44,a4
	pea .batch5(pc)
	GEMDOS 59,6
	tst.l d0
	bmi.s .fin						; refuse de remonter, sortir!
	move.l a4,-(sp)
	GEMDOS 26,6						; fixe ma DTA
	bra .next
.fin:
	pea .term(pc)
	XBIOS 38,6
	move.l d7,-(sp)
	moveq #8,d6
	moveq #-1,d7
	bsr.l manage_tree				; searching files
	move.l (sp)+,d7
	rts
.debut:
	move.l $4ba.w,start_time
	rts
.term:
	move.l $4ba.w,end_time
	rts
.zero: dc.l 0
.batch4: dc.b "*.*",0				; masque de recherche, 4 caractŠres
.batch5: dc.b "..",0				; pour remonter
	even


bat_tga_msvc:
	move.l buffer,a0	; le tga
	move.l image,a1	; zone 24 bits MSVC ordre R,V,B ou zone 256 gris
	moveq #0,d3
	move screenw,d3
	move 14(a0),d5				; max_imagey
	ror #8,d5
	lsr #2,d5					; blocs de 4
	subq #1,d5					; pour dbf
	move 12(a0),d4				; max_imagex
	ror #8,d4
	lsr #2,d4					; blocs de 4
	subq #1,d4					; pour dbf
	move.w 16(a0),d0			; bits/pixel + flag orientation
	lea 18(a0),a0				; les donnes
	ror #8,d0
	cmp.b #24,d0
	beq _24_msvc
	ror #8,d0
	add.l d3,d3					; 2 octets/pixel
	btst #5,d0					; 1=haut en bas, 0=bas en haut
	bne _16msvch
_16msvcb:
	move d4,d1
.ligne:
	lea 0(a0,d3.l),a2			; seconde ligne
	bsr.s _2sur2
	move.l a0,a3				; pour prochain bloc
	lea -8(a2,d3.l),a0
	lea 0(a0,d3.l),a2
	bsr.s _2sur2
	move.l a3,a0
	dbf d1,.ligne
	move.l a2,a0				; waow!
	dbf d5,_16msvcb
	rts
_2sur2:
	tst.b tga_vers_gris
	bne.s .2sur2gris
	rept 2
		move (a0)+,d0
		bsr.s .16to24
		move (a0)+,d0
		bsr.s .16to24
		move (a2)+,d0
		bsr.s .16to24
		move (a2)+,d0
		bsr.s .16to24
	endr
	rts
.16to24:
	ror #8,d0
	swap d0
	rol.l #6,d0
	lsl.b #3,d0		; rouge
	move.b d0,(a1)+
	rol.l #5,d0
	lsl.b #3,d0		; vert
	move.b d0,(a1)+
	rol.l #5,d0
	lsl.b #3,d0		; bleu
	move.b d0,(a1)+
	rts
.2sur2gris:
	rept 2
		move (a0)+,d0
		bsr.s .16togris
		move (a0)+,d0
		bsr.s .16togris
		move (a2)+,d0
		bsr.s .16togris
		move (a2)+,d0
		bsr.s .16togris
	endr
	rts
.16togris:
	moveq #0,d6
	moveq #0,d2
	ror #8,d0
	swap d0
	rol.l #6,d0
	lsl.b #3,d0		; rouge
	move.b d0,d6
	rol.l #5,d0
	lsl.b #3,d0		; vert
	move.b d0,d2
	rol.l #5,d0
	add d2,d2
	lsl.b #3,d0		; bleu
	add d6,d2
	lsl #8,d0
	move d2,d6
	add d2,d2
	lsr #8,d0
	add d6,d2
	add d0,d2
	divs #10,d2
	move.b d2,(a1)+
	rts
_16msvch:
	move d5,d0
	lsl #2,d0		; lignes-4
	addq #3,d0		; derniŠre ligne
	muls d3,d0		; on y va
	add.l d0,a0		; pointe au dbut de la derniŠre ligne
	neg.l d3			; pour reculer!
.encore:
	move d4,d1
.ligne:
	lea 0(a0,d3.l),a2			; seconde ligne
	bsr _2sur2
	move.l a0,a3				; pour prochain bloc
	lea -8(a2,d3.l),a0
	lea 0(a0,d3.l),a2
	bsr _2sur2
	move.l a3,a0
	dbf d1,.ligne
	lea 0(a2,d3.l*2),a0		; plus dur!
	dbf d5,.encore
	rts
_24_msvc:
	move.l d3,d1
	add.l d1,d1
	add.l d1,d3					; 3 octets/pixel
	ror #8,d0
	btst #5,d0					; 1=haut en bas, 0=bas en haut
	bne _24msvch
_24msvcb:
	move d4,d1
.ligne:
	lea 0(a0,d3.l),a2			; seconde ligne
	bsr.s _2sur2_24
	move.l a0,a3				; pour prochain bloc
	lea -12(a2,d3.l),a0
	lea 0(a0,d3.l),a2
	bsr.s _2sur2_24
	move.l a3,a0
	dbf d1,.ligne
	move.l a2,a0				; waow!
	dbf d5,_24msvcb
	rts
_2sur2_24:
	moveq #1,d6
	tst.b tga_vers_gris
	bne.s .2sur2gris
.lb0:
	move.b 2(a0),d0
	lsl #8,d0
	move.b 1(a0),d0
	swap d0
	move.b (a0),d0
	lsl #8,d0
	move.b 5(a0),d0
	move.l d0,(a1)+
	move.b 4(a0),d0
	lsl #8,d0
	move.b 3(a0),d0
	addq.l #6,a0
	move.w d0,(a1)+
	move.b 2(a2),d0
	lsl #8,d0
	move.b 1(a2),d0
	swap d0
	move.b (a2),d0
	lsl #8,d0
	move.b 5(a2),d0
	move.l d0,(a1)+
	move.b 4(a2),d0
	lsl #8,d0
	move.b 3(a2),d0
	addq.l #6,a2
	move.w d0,(a1)+
	dbf d6,.lb0
	rts
.2sur2gris:
	bsr.s .lb1
	bsr.s .lb1
	exg.l a0,a2
	bsr.s .lb1
	bsr.s .lb1
	exg.l a0,a2
	rts
.lb1:
	moveq #0,d2
	moveq #0,d0
	move.b 1(a0),d2
	move.b 2(a0),d0
	add d2,d2
	add d0,d2
	move d2,d0
	add d2,d2
	add d0,d2
	moveq #0,d0
	move.b (a0),d0
	add d0,d2
	divs #10,d2
	move.b d2,(a1)+
	addq.l #3,a0
	rts
_24msvch:
	move d5,d0
	lsl #2,d0		; lignes-4
	addq #3,d0		; derniŠre ligne
	muls d3,d0		; on y va
	add.l d0,a0		; pointe au dbut de la derniŠre ligne
	neg.l d3			; pour reculer!
.encore:
	move d4,d1
.ligne:
	lea 0(a0,d3.l),a2			; seconde ligne
	bsr _2sur2_24
	move.l a0,a3				; pour prochain bloc
	lea -12(a2,d3.l),a0
	lea 0(a0,d3.l),a2
	bsr _2sur2_24
	move.l a3,a0
	dbf d1,.ligne
	lea 0(a2,d3.l*2),a0		; plus dur!
	dbf d5,.encore
	rts

bat_ximg_msvc:
	move.l image,-(sp)
	move.l buffer,image	; on d‚tourne
	st bat_getp				; lire toutes les palettes
	bsr.l bat_ximg_256	; on d‚compresse d'abord
	move.l (sp)+,a1
	move.l buffer,a0	; le ximg (octets 0-255 indexs)
	move.l a1,image	; zone 8bits MSVC (0-255 gris)
	moveq #0,d3
	move screenw,d3
	move max_imagey,d5		; max_imagey
	lsr #2,d5					; blocs de 4
	subq #1,d5					; pour dbf
	move max_imagex,d4		; max_imagex
	lsr #2,d4					; blocs de 4
	subq #1,d4					; pour dbf
	move d5,d0
	lsl #2,d0		; lignes-4
	addq #3,d0		; derniŠre ligne
	muls d3,d0		; on y va
	add.l d0,a0		; pointe au d‚but de la derniŠre ligne
	neg.l d3			; pour reculer!
	moveq #0,d0		; index vers gris
	lea cvid_fix0,a6	; table index vers gris
.encore:
	move d4,d1
.ligne:
	lea 0(a0,d3.l),a2			; seconde ligne
	bsr.s .2sur2
	move.l a0,a3				; pour prochain bloc
	lea -4(a2,d3.l),a0
	lea 0(a0,d3.l),a2
	bsr.s .2sur2
	move.l a3,a0
	dbf d1,.ligne
	lea 0(a2,d3.l*2),a0		; plus dur!
	dbf d5,.encore
	rts
.2sur2:
	rept 2
		move.b (a0)+,d0
		move.b 0(a6,d0.l),(a1)+
		move.b (a0)+,d0
		move.b 0(a6,d0.l),(a1)+
		move.b (a2)+,d0
		move.b 0(a6,d0.l),(a1)+
		move.b (a2)+,d0
		move.b 0(a6,d0.l),(a1)+
	endr
	rts

fill_palette:
	tst d4
	beq.s .fin		; pas de palette
	tst.b create_avi
	bmi.s .fin		; pas de MSVC en gris
	move.l d0,a0	; adresse header
	move #255,d2
	moveq #0,d0
	move.l #$01010100,d1
.msvc_loop:
	move.l d0,(a0)+			; cree une palette grise
	add.l d1,d0
	dbf d2,.msvc_loop
.fin:
	rts

; sample_num = nombre d'images
; D1 compression (RLE, MSVC, GIF ou FLM)
; D2 nombre de bits/pixels
; D3 type de fichier cr‚‚ (AVI, MOV, GIF, FLM)
; out_file = nom du fichier
; qual_sav: la qualit‚ (1 … 5)
; start_time et current time pour l'estimation.

init_create_box:
	movem.l d4-d7/a0-a6,-(sp)
	lea _reference(pc),a2
	move.l sample_num,(a2)+
	clr.l (a2)
	moveq #12,d0
	GADDR d0,1
	moveq #0,d0
	move d0,12*24+20(a0)		; annule la taille de la barre
	move.l 4*24+12(a0),a1	; chaine compression
	move.l d1,(a1)+
	add.b #'0',d2
	cmp.b #'9'+1,d2
	bmi.s .ok
	move.b #'1',(a1)+
	move.b #'6',d2
.ok:
	move.b d2,(a1)+
	clr.b (a1)
	move.l 1*24+12(a0),a1	; ted
	move.l (a1),a1
	moveq #27,d0
	bsr.l add_string				; creating + space
	move.l tree,a0					; car A0 perdu par add_string
	move.l d3,(a1)+			; type de fichier
	move.w #": ",(a1)+		
	bsr.s nom_du_fichier		; au final "Creating AVI : filename.ext"
	move.l _reference,d0
	moveq #10,d1
	bsr _int_to_6digits		; total frames
	moveq #0,d0
	moveq #14,d1
	bsr _int_to_6digits		; d‚but … z‚ro frames
	bsr.s .qualite
	moveq #1,d7
	moveq #12,d6
	bsr.l manage_tree
	movem.l (sp)+,d4-d7/a0-a6
	rts
.qualite:
	move.l 5*24+12(a0),a1
	move qual_sav,d0
	move.l #'----',(a1)+
	move.w #$2d00,(a1)
	moveq #48,d1
	add.b d0,d1
	move.b d1,-5(a1,d0.w)
	rts

; a1= zone ou copier le nom FILENAME.EXT
; extrait du chemin complet de out_file
; utilise a3,a4,d0,d1

nom_du_fichier:
	lea out_file,a3
	move.l a3,a4
.lb0:
	tst.b (a4)+		; cherche la fin
	bne.s .lb0
	moveq #11,d0
	subq.l #1,a4
.lb1:
	move.b -(a4),d1
	cmp.b #'\',d1
	beq.s .depass
	cmp.b #':',d1
	beq.s .depass
	cmp.l a3,a4
	beq.s .lb2
	dbf d0,.lb1	; pas plus de 12 caractŠres
	bra.s .lb2
.depass:
	addq.l #1,a4
.lb2:
	move.b (a4)+,(a1)+
	bne.s .lb2
	rts

update_create_box:
	btst #0,mountain
	bne.s .pas_aff
	movem.l d0-d7/a0-a6,-(sp)
	lea _dialog_table,a1
	move.l 48(a1),a3		; structure "create"
	move.l (a3),a0			; arbre
	lea _actuel(pc),a2
	addq.l #1,(a2)				; image suivante
	moveq #0,d1
	move.l (a2),d0
	move.w 11*24+20(a0),d1	; taille barre totale
	muls.l d0,d2:d1
	divs.l -(a2),d2:d1
	move.w d1,12*24+20(a0)	; taille de la barre
	moveq #14,d1
	bsr.s _int_to_6digits
	bsr.s _remaining_time
	moveq #7,d6				; numero objet
	moveq #0,d0				; il a chang‚
	bsr wdial_change
	moveq #1,d7
	moveq #12,d6
	bsr.l manage_tree
;	move.l #$00070007,rect_draw	; redessinerI-BOX, frame et progress
;	GEM_AES objc_draw		; met … jour
	movem.l (sp)+,d0-d7/a0-a6
.pas_aff:
	rts

_int_to_6digits:
	muls #24,d1
	move.l 12(a0,d1.l),a1	; adresse chaine
	addq.l #6,a1
	moveq #5,d2
.lb0:
	divsl.l #10,d1:d0
	add.b #'0',d1
	move.b d1,-(a1)			; one char
	dbf d2,.lb0
	rts

_remaining_time:
	move.l (a2)+,d0
	move.l (a2)+,d2
	move.l (a2)+,d1	; update time
	subq.l #1,d2
	bne.s .suite
	moveq #0,d0
	move.l d1,_start_time	; premiŠre fois, on garde le temps
	rts
.suite:
	sub.l d2,d0				; images restantes
	move.l d2,a1
	sub.l (a2)+,d1		; temps ‚coul‚
	muls.l d0,d2:d1
	move.l a1,d0
	divs.l d0,d2:d1			; 1/200e de sec restants
	divs.l #200,d1				; secondes!
	move.l 24*17+12(a0),a1	; chaine
	addq.l #8,a1				; fin
	moveq #10,d0
	rept 2
		divsl.l d0,d2:d1
		moveq #6,d0
		add.b #'0',d2
		move.b d2,-(a1)
		divsl.l d0,d2:d1
		add.b #'0',d2
		move.b d2,-(a1)
		moveq #10,d0
		move.b #':',-(a1)
	endr
	rept 2
		divsl.l d0,d2:d1
		add.b #'0',d2
		move.b d2,-(a1)
	endr
	rts

; D0.l valeur de r‚f‚rence correspondant … la barre entiŠre
init_loading_sound:
	move.l d0,_reference
	movem.l d0-d7/a0-a6,-(sp)
	moveq #1,d0
	GADDR d0
	moveq #0,d0
	move d0,72+20(a0)		; annule la taille de la barre
	move.l 4*24+12(a0),a0	; tedinfo "replay at xx.x khz"
	move.l (a0),a0				; string
	lea 20(a0),a0				; last x
	moveq #0,d0
	move real_freq+2,d0
	divs #100,d0
	ext.l d0
	divs #10,d0
	swap d0
	add.b #'0',d0
	move.b d0,(a0)
	subq.l #1,a0
	clr d0
	swap d0
	divs #10,d0
	swap d0
	add.b #'0',d0
	move.b d0,-(a0)
	move.b #' ',-(a0)
	clr d0
	swap d0
	beq.s .lb0
	add.b #'0',d0
	move.b d0,(a0)
.lb0:
	subq.l #7,a0
	cmp #2,channels
	beq.s .stereo
.mono:
	move.l #' mon',(a0)+
	move #'o ',(a0)
	bra.s .lb1
.stereo:
	tst.b snd_value
	bpl.s .mono			; no dma, so mono
	move.l #'ster',(a0)+
	move #'eo',(a0)
.lb1:
	moveq #1,d7
	moveq #1,d6
	bsr.l manage_tree
.wait:
	move.b ([kbshift]),d5	; sinon, voir SHIFT pour forcer comptage
	and.b #3,d5			; BYTE non nul si SHIFT
	bne.s .wait
	movem.l (sp)+,d0-d7/a0-a6
	rts
_reference: dc.l 0
_actuel: dc.l 0
_update_time: dc.l 0
_start_time: dc.l 0

; D0.l: valeur relative de la progression	par rapport … la r‚f‚rence
update_loading_sound:
	movem.l d0-d7/a0-a6,-(sp)
	lea _dialog_table,a1
	move.l 4(a1),a3		; structure "loading sound"
	move.l (a3),a0			; arbre
	moveq #0,d1
	move.w 48+20(a0),d1	; taille barre totale
	muls.l d0,d2:d1
	divs.l _reference(pc),d2:d1
	cmp 72+20(a0),d1		; la taille a chang‚?
	beq.s .fin				; non!
	move.w d1,72+20(a0)	; taille de la barre
	moveq #3,d6				; numero objet
	moveq #0,d0				; il a chang‚
	bsr wdial_change
	moveq #1,d7
	moveq #1,d6
	bsr.l manage_tree
;	move.l #$00030007,rect_draw
;	GEM_AES objc_draw		; met … jour
.fin:
	movem.l (sp)+,d0-d7/a0-a6
	rts

	if DBG=1
_debug_hex:
	movem.l d0-d2/a0-a2,-(sp)
	lea _debug_int_fin(pc),a0
	lea _hex_digits(pc),a1	
	moveq #7,d2
.lb0:
	move d0,d1
	and #$F,d1
	move.b 0(a1,d1.w),-(a0)
	lsl.l #4,d0
	dbf d2,.lb0
	subq.l #1,a0
	bra.s _debug_comm
_debug_string:
	movem.l d0-d2/a0-a2,-(sp)
	move.l _debug_adr,a0
	bra.s _debug_comm
_debug:
	movem.l d0-d2/a0-a2,-(sp)
	lea _debug_text(pc),a0
	addq.b #1,1(a0)
_debug_comm:
	pea (a0)
	GEMDOS 9,6
	move.l #$20002,-(sp)
	trap #13
	addq.l #4,sp
	cmp.b #27,d0
	bne.s .lb0
	illegal
.lb0:
	cmp.b #9,d0
	bne.s .lb1
	jmp end_end
.lb1:
	movem.l (sp)+,d0-d2/a0-a2
	rts
_debug_int: dc.b 13,"FFFFFFFF"
_debug_int_fin: dc.b " ",0
_hex_digits: dc.b "0123456789ABCDEF"
	even
_debug_text: dc.b 13,"@ ",0
	even
_debug_adr: dc.l 0
	endif


set_easybat_path:
	lea ebat_path,a4	; 1st image path
	moveq #2,d0			; image default path
	bsr.s get_path
	lea ebat_path,a4	
	lea 400(a4),a0		; 2nd
	lea 400(a0),a1		; 3rd
	lea 400(a1),a2		; 4th
	lea 400(a2),a3		; 5th
	moveq #99,d0		; 400 bytes each
.lb0:
	move.l (a4)+,d1	; copy one path to five
	move.l d1,(a0)+
	move.l d1,(a1)+
	move.l d1,(a2)+
	move.l d1,(a3)+
	dbf d0,.lb0
	move.l a3,a4		; start of sound path
	moveq #1,d0			; sound default path
	bsr.s get_path
	lea ebat_out,a4	; for output file
	moveq #3,d0			; convert default path
	bsr.s get_path
	lea ebat_outbat,a4	; for saving BAT
	moveq #3,d0			; convert default path
	bsr.s get_path	
	rts
	
	
	; d0 = option number in M_PLAYER.OPT
	; a4 = address to store the path
	
get_path:
	bsr get_option		; is there a default path to start?
	beq.s .lba				; no !
.lbb:
	move.b (a1)+,(a4)+	; else, a1 = full path + "\"
	bne.s .lbb
	subq.l #2,a4			; back on "\"
	bra.s .lbc	
.lba:
	GEMDOS 25,2				; dgetdrv
	add #'A',d0	   		; ascii drive (A=0, B=1 ...)
	move.b d0,(a4)+
	move.b #':',(a4)+		; paths stats with X:, X being the drive
	sub #'A'-1,d0			; drive number (A=1, B=2,...)
	move d0,-(sp)
	move.l a4,-(sp)
	GEMDOS 71,8				; degetpath, adds path in (A4)
.lb0:
	tst.b (a4)+
	bne.s .lb0				; looks for the 0 (end of the string)
	subq.l #1,a4			; back on the 0
.lbc:
	move.l #'\*.*',(a4)+
	clr.b (a4)
	rts

build_dialogue_table:
	move.l #$31415927,d0
	lea rsrc_load,a4
	move #13,([a4])
	lea bat_timing,a0
	eor.l d0,-(a0)
	eor.l d0,-(a0)
	move.l a0,34(a4)
	lea _dialog_table,a4
	moveq #0,d6
.lb0:
	move.l d6,rg_int		; the index of the tree
	GEM_AES rsrc_gaddr	; the address of the tree into 'tree'
	move.l tree,a0
	cmp #4,d6
	bne.s .lb2				; pour le menu, on garde juste son adresse
	move.l a0,menu_tree
	bra.s .lb1
.lb2:
	bsr wdial_create		; pour les autres, on cr‚e la structure WDIAL
.lb1:
	move.l a0,(a4)+		; pour le menu, ce n'est pas une structure
	addq #1,d6
	cmp #LAST_TREE+1,d6
	bne.s .lb0
	moveq #LAST_TREE,d0
	GADDR d0
	move.l 4*24+12(a0),a0	; chaine des commandes Step by Step
	lea step_keys,a1
	move.l a0,(a1)+			; adresse chaine pour mode Falcon 
	moveq #3,d0					; 4 keys to find
.lb5:
	cmp.b #'(',(a0)+
	bne.s .lb5
	move.b (a0),(a1)			; take the key
	or.b #$20,(a1)+			; to lower case
	dbf d0,.lb5
	moveq #17,d0				; tree CAPTURE SCREEN ******
	GADDR d0
	move.l 2*24+12(a0),a0	; field delay
	move.l (a0),a0
	clr.l (a0)					; string ___+0 to zero
	moveq #16,d0				; tree DEFINE RECTANGLE ******
	GADDR d0
	move.l 9*24+12(a0),a1	; Frames to 0
	move.l (a1),a1
	clr.b (a1)			
	move.l 10*24+12(a0),a1	; grab delay to 0
	move.l (a1),a1
	clr.b (a1)			
	move.l 11*24+12(a0),a1	; replay delay to 0
	move.l (a1),a1
	clr.b (a1)			
	move.l 13*24+12(a0),a1	; filename to 0
	clr.b (a1)			
	moveq #19,d0				; tree EASYBAT ******
	GADDR d0
	move.l 24*76+12(a0),a1	; output filename
	clr.b (a1)
	lea 24*19+12(a0),a1
	moveq #4,d0
.lb3:
	move.l (a1),a2
	move.l (a2),a2
	clr.b (a2)					; clear 1st file
	move.l 48(a1),a2
	move.l (a2),a2
	clr.b (a2)					; clear last file
	add.w #5*24,a1
	dbf d0,.lb3
	lea 50*24+12(a0),a1
	move.l (a1),a2
;	move.l (a2),a2
	clr.b (a2)					; sound file	
	move.l 49*24+12(a0),a1	; time
	move.l (a1),a1
	clr.b (a1)		
	move.l 53*24+12(a0),a1	; key frame
	move.l (a1),a1
	clr.b (a1)		
	moveq #20,d0
	GADDR d0						; tree VR PARAMETERS *****
	lea 5*24+12(a0),a0	; first ted
	moveq #4,d0
.lb4:
	move.l (a0),a1
	move.l (a1),a1
	clr.b (a1)	
 	lea 24(a0),a0				; next
 	dbf d0,.lb4
 	moveq #2,d0
 	GADDR d0						; tree INFO CREDITS *****
 	lea 9*24+12(a0),a0		; first icon
 	move.l (a0),a1				; ICONBLK
 	move.l #$FF00FF00,26(a1)	; text position negative : no text!
 	move.l 24(a0),a1			; ICONBLK
 	move.l #$FF00FF00,26(a1)	; text position negative : no text!
 	moveq #18,d0
 	GADDR d0						; tree GENERAL MENU *****
 	lea 6*24+12(a0),a0		; icon
 	move.l (a0),a1				; ICONBLK
 	move.l #$FF00FF00,26(a1)	; text position negative : no text! 	
	rts

; when is_mw=1 (only xbios functions), disable all but left/right

adapt_sound_panel:
	move.l #$000F000F,microw_max+2	; new max values for left/right
	lea microwire+2,a0
	moveq #15,d0
	cmp.b (a0)+,d0
	bpl.s .okl
	move.b d0,-1(a0)	; limit left and right to 15
.okl:
	cmp.b (a0),d0
	bpl.s .okr
	move.b d0,(a0)
.okr:		
	moveq #14,d0
	GADDR d0
	lea .table(pc),a1
.lb0:
	moveq #0,d0
	move.b (a1)+,d0
	beq.s .fin
	muls #24,d0
	bset #3,11(a0,d0.l)		; disable object
	bra.s .lb0
.fin:
	move.l 24*2+12(a0),a0	; tedinfo "Microwire Interface"
	move.l ([fstring_adr],10*24+12),(a0)			; changed to " xbios func", string 10
	rts
	
.table: dc.b 3,4,9,10,11,12,19,0

	include "WDIAL.S"

;sauve_bloc:
;	movem.l d0-d2/a0-a2,-(sp)
;	clr -(sp)
;	pea .fichier(pc)
;	GEMDOS 60,8
;	move d0,d7
;	lea bloc(pc),a0
;	move planes_vdi,128(a0)
;	pea (a0)
;	move.l #130,-(sp)
;	move d7,-(sp)
;	GEMDOS 64,12
;	move d7,-(sp)
;	GEMDOS 62,4
;	movem.l (sp)+,d0-d2/a0-a2
;	rts
;.fichier: dc.b "DUMP.TXT",0

;	even

get_screen_encoding:
	lea palplus(pc),a6
	bsr dessin
;	bsr sauve_bloc
	move planes_vdi,d0
	cmp #16,d0
	beq.s highcol
	cmp #24,d0
	beq truecol24
	cmp #32,d0
	beq truecol32
screen_error:
	moveq #24,d0		; alert can't detect screen
	bra.l ooops
screen_detected:
	move.l a0,vdi_compression
	tst.b is_vdi
	beq.s .out		; si pas VDI, on teste juste le mode 16 bits
	cmp #16,planes_vdi
	bne.s .out
	tst 6(a0)		; word for 65k mode
	sne is_65k
.out:
	rts

highcol:
	movem.l (a0),d0-d1	; 4 premiers pixels
	move.l a0,a1
	lea T8(pc),a0
	bset #21,d0
	bset #21,d1
	cmp.l #$FFFFF800,d0
	bne.s .autre
	cmp.l #$07E0001F,d1
	beq.s .ok
.autre:
	movem.l (a1),d0-d1
	lea T9(pc),a0
	bset #29,d0
	bset #29,d1
	cmp.l #$FFFF00F8,d0
	bne.s .zotr
	cmp.l #$E0071F00,d1
	beq.s .ok
.zotr:
	lea TG(pc),a0
	movem.l (a1),d0-d1
	and.l #$7FFF7FFF,d0
	and.l #$7FFF7FFF,d1
	cmp.l #$7FFF7C00,d0
	bne.s .dernier
	cmp.l #$03E0001F,d1
	beq.s .ok
.dernier:
	lea TA(pc),a0
	movem.l (a1),d0-d1
	and.l #$FF7FFF7F,d0
	and.l #$FF7FFF7F,d1
	cmp.l #$FF7F007C,d0
	bne screen_error
	cmp.l #$E0031F00,d1
	beq.s .ok
	bra screen_error
.ok: bra screen_detected


truecol24:
	movem.l (a0),d0-d2	; 4 premiers pixels
	lea TB(pc),a0
	cmp.l #-1,d0
	bne.s .autre
	cmp.l #255,d1
	bne.s .autre
	cmp.l #255,d2
	beq.s .ok
.autre:
	lea TC(pc),a0
	cmp.l #$FFFFFF00,d0
	bne screen_error
	cmp.l #$00FF00FF,d1
	bne screen_error
	cmp.l #$00FF0000,d2
	bne screen_error
.ok: bra screen_detected

truecol32:
	move.l a0,a1
	movem.l (a1),d0-d3
	move.l #$00FFFFFF,d4
	lea TD(pc),a0
	and.l d4,d0
	and.l d4,d1
	and.l d4,d2
	and.l d4,d3
	cmp.l d4,d0
	bne.s .autre
	cmp.l #$FF00,d2
	bne.s .autre
	cmp.l #$FF0000,d1
	bne.s .inverse1
	cmp.l #255,d3
	beq.s .ok
.inverse1:
	lea TH(pc),a0
	cmp.l #255,d1
	bne.s .autre
	cmp.l #$FF0000,d3
	beq.s .ok
.autre:
	movem.l (a1),d0-d3
	lsl.l #8,d4
	lea TE(pc),a0
	and.l d4,d0
	and.l d4,d1
	and.l d4,d2
	and.l d4,d3
	cmp.l d4,d0
	bne screen_error
	cmp.l #$FF0000,d2
	bne screen_error
	cmp.l #$FF00,d1
	bne.s .inverse2
	cmp.l #$FF000000,d3
	beq.s .ok
.inverse2:
	lea TI(pc),a0
	cmp.l #$FF000000,d1
	bne screen_error
	cmp.l #$FF00,d3
	bne screen_error
.ok: bra screen_detected

dessin:
	lea palplus(pc),a6
	GEM_VDI hide_mouse
	move.l work_out,d1
	sub.l #$000F0001,d1
	lsr.l #1,d1				; (w-16)/2 et (h-2)/2: centrage
	lea vp_int(pc),a5		; to re-init coords for marker and vro_cpyfm
	lea vp_int_sav(pc),a0
	moveq #9,d0
.init_coords:
	move.l (a0)+,d2
	add.l d1,d2
	move.l d2,(a5)+
	dbf d0,.init_coords
	move.l (a0)+,(a5)+
	move.l (a0)+,(a5)+
	move.l (a0)+,(a5)+	; re-init my_mfdb (if ACC)
	move.l (a0)+,(a5)+
	move.l (a0)+,(a5)+
	lea wc_int+2,a0
	move.l #$00140006,d2
	sub.l #$00020002,d1	; window with -2 +2 around the bloc
	clr (a0)+
	move.l d1,(a0)+
	move.l d2,(a0)
	lea fd_int,a0
	clr (a0)+
	move.l d1,(a0)+
	move.l d2,(a0)+
	move.l d1,(a0)+
	move.l d2,(a0)
	GEM_AES wind_create
	move wc_int+2,ws_int		; copie le handle pour wind_close
	bgt.s .ok
	moveq #26,d0
	bsr.l alert					; alert, no more window
	bra.s .no_win1				; but go on without window...
.ok:
	GEM_AES form_dial
	GEM_AES wind_open
	move #1,wu_int
	GEM_AES wind_update
.no_win1:
	lea vs_int,a5
	move (a6)+,(a5)
	move (a6)+,d4		; nombre
	bra.s .fin_coul
.coul:
	move (a6)+,2(a5)
	move (a6)+,4(a5)
	move (a6)+,6(a5)
	GEM_VDI vs_color
	addq #1,(a5)
.fin_coul:
	dbf d4,.coul
	moveq #3,d6
	lea vm_int(pc),a5
.points:
	move (a6)+,(a5)		; couleur!
	GEM_VDI vsm_color
	GEM_VDI v_pmarker
	lea vp_int(pc),a0
	moveq #7,d0
.trans:
	addq #1,(a0)
	addq.l #4,a0
	dbf d0,.trans
	dbf d6,.points
;	move.l #$20002,-(sp)
;	trap #13
;	addq.l #4,sp
	bsr .xchange
	GEM_VDI vro_cpyfm2	; remplit le bloc!!!
	bsr .xchange
	tst ws_int
	bmi.s .no_win2			; tries to go on without window...
	move #0,wu_int
	GEM_AES wind_update
	GEM_AES wind_close
	GEM_AES wind_delete
.no_win2:
	move #3,fd_int
	GEM_AES form_dial
	GEM_VDI show_mouse
	clr mf_int
	GEM_AES graf_mouse	; the arrow
	lea bloc(pc),a0		; le bloc!!!
	rts
.xchange:
	lea cp_cont+14(pc),a0
	movem.l (a0)+,d0-d1
	exg.l d0,d1
	movem.l d0-d1,-(a0)	; xchange mfdb source and dest for next use VDI_DISPLAY
	rts


vdi_display:
	tst.b conv_flag
	beq.s .go_on
	rts
.go_on:
	lea my_mfdb(pc),a2
	move.l (a2)+,a3		; vdi_buffer
	move 4(a2),d2			; max_imagex in words
	subq #1,d2
	swap d2
	move (a2)+,d2			; max_imagex (rounded to 16)
	subq #1,d2
	move (a2)+,d3			; max_imagey
	subq #1,d3
	move.l image,a2		; adresse premiŠre ligne
	move screenw,d4
	add d4,d4				; 16 bits!
	move.l vdi_compression,a0
	addq.l #2,a0
	move.l (a0)+,a1
	jmp (a1)


vdi_swap16:
	move.l a2,a0
	move d2,d1
.lb0:
	move (a0)+,d0
	ror #8,d0
	move d0,(a3)+
	dbf d1,.lb0
	add d4,a2
	dbf d3,vdi_swap16
;	bra vdi_direct16

vdi_direct16:
	GEM_VDI vro_cpyfm2
	rts

vdi_rvb:
	move #$F8,d5
	tst.b 1(a0)
	beq.s .lb0
	addq.l #1,a3
.lb0:
	move.l a2,a1
	move d2,d1
.lb1:
	move (a1)+,d0
	move d0,d6
	add d6,d6
	and d5,d6
	move.b d6,(a3)+
	move d0,d6
	rol #6,d6
	and d5,d6
	move.b d6,(a3)+
	lsr #5,d0
	and d5,d0
	move.b d0,(a3)+
	tst.b (a0)
	beq.s .lb2
	addq.l #1,a3
.lb2:
	dbf d1,.lb1
	add d4,a2
	dbf d3,.lb0
	bra.s vdi_direct16

vdi_bvr:
	move #$F8,d5
	tst.b 1(a0)
	beq.s .lb0
	addq.l #1,a3
.lb0:
	move.l a2,a1
	move d2,d1
.lb1:
	move (a1)+,d0
	move d0,d6
	lsr #5,d6
	and d5,d6
	move.b d6,(a3)+
	move d0,d6
	rol #6,d6
	and d5,d6
	move.b d6,(a3)+
	add d0,d0
	and d5,d0
	move.b d0,(a3)+
	tst.b (a0)
	beq.s .lb2
	addq.l #1,a3
.lb2:
	dbf d1,.lb1
	add d4,a2
	dbf d3,.lb0
	bra vdi_direct16


vdi_mono:
	swap d2							; prefer x in words
	move.l step_vdi_sav,a1		; 16bits to grey table
.next_line:
	move.l a2,a0
	swap d4
	move d3,d4
	and #$7,d4
	lea bayer(pc,d4.w*8),a4
	swap d3
	move d2,d0
.next_word:
	move #15,d3
.word:
	lsl #1,d4
	move (a0)+,d1
	TO_GREY d1
	cmp.b (a4)+,d1
	bgt.s .white
	addq #1,d4
.white:
	dbf d3,.word
	move d4,(a3)+
	lea -16(a4),a4
	dbf d0,.next_word
	swap d4
	add.w d4,a2
	swap d3
	dbf d3,.next_line
	GEM_VDI vrt_cpyfm
	rts
	
bayer: dc.b 0,64,16,80,4,68,20,82
		dc.b 96,32,112,48,100,36,116,52
		dc.b 24,88,8,7,28,92,12,76
		dc.b 120,56,104,40,124,60,108,44
		dc.b 6,70,22,86,2,66,18,82
		dc.b 102,38,118,54,98,34,114,50
		dc.b 30,94,14,78,26,90,10,74
		dc.b 126,62,110,46,122,58,106,42
		dc.b 0,64,16,80,4,68,20,82

vdi_32to65:
	move.l a2,a0
	move d2,d1
.lb0:
	move (a0)+,d0
	FALC16 d0
	ror #8,d0
	move d0,(a3)+
	dbf d1,.lb0
	add d4,a2
	dbf d3,vdi_32to65
	bra vdi_direct16	
	
vdi_32to65M:
	move.l a2,a0
	move d2,d1
.lb0:
	move (a0)+,d0
	FALC16 d0
	move d0,(a3)+
	dbf d1,.lb0
	add d4,a2
	dbf d3,vdi_32to65M
	bra vdi_direct16

_mon_trap10:
	move.l $4ba.w,d0
	rte
	
_mon_trap11:
	btst #0,$FFFF8901.w
	move ccr,d0
	move.b d0,1(sp)
	rte 

stop_all_sounds:
	tst.b snd_value
	bpl.s clear_yamaha_sound
	bra.s clear_dma_sound

clear_yamaha_sound:
	tst.b playing
	beq.s .out
	pea .clear(pc)
	XBIOS 38,6
.out:
	rts
.clear:
	move sr,d0
	move #$2700,sr
	move.l yamaha_ptr,a0
	clr.b (a0)+
	clr.b (a0)
	move d0,sr
	rts

clear_dma_sound:
	tst.b playing
	beq.s .out
	pea .clear(pc)
	XBIOS 38,6
.out:
	rts
.clear:	
	clr.b $ffff8901.w
	rts
	
install_traps:
	pea .inst(pc)
	XBIOS 38,6
	rts
.inst:
	move.l $a8.w,old_trap10
	move.l $ac.w,old_trap11
	move.l #_mon_trap10,$a8.w
	move.l #_mon_trap11,$ac.w
	rts

common_end:
	trap #10
	move.l d0,end_time		
remove_traps:
	pea .rem(pc)
	XBIOS 38,6
	rts
.rem:
	move.l old_trap10,$a8.w
	move.l old_trap11,$ac.w
	rts
	
select_mouse:
	moveq #1,d0		; NEXT
	tst.b auto_save_tga
	bne.s .fast
	tst.b auto_run_tga
	beq.s my_mouse
.fast:
	moveq #2,d0
	; ... go on with my_mouse
	
; d0 = 0=disk, 1=next, 2=fast
my_mouse:
	tst.b conv_flag
	bne.s .out				; do not touch AES if conversion !
	move #255,mf_int
	muls #74,d0
	lea (mouse_disk,pc,d0.l),a0
	move.l a0,mouse_def
	GEM_AES graf_mouse
.out:
	rts

; return d7.w = 0 don't force count (only if little files)
; d7 <>0 force count

decide_count_mpg:
	move.b always_count,d7
	beq.s .lb1
	move.l #$7FFFFFFF,mpg_big
	rts
.lb1:	
	bsr install_traps
	bsr.s .machine_power
	move.l d0,mpg_big	; limite pour le comptage auto des images
	moveq #0,d7
	cmp.l total,d0
	bpl.s .exit			; little file, frames will be counted
	move.b ([kbshift]),d7
	and.b #3,d7					; is SHIFT on ?
	bne.s .exit
	moveq #3,d0
	bsr general_info			; box SHIFT for count
	trap #10
	move.l d0,d1
	add.l #200,d1
.wait_shift:
	move.b ([kbshift]),d7
	and.w #3,d7					; is SHIFT on ?
	bne.s .yeeha
	trap #10
	cmp.l d0,d1
	bpl.s .wait_shift
.yeeha:
	move.w d7,-(sp)
	bsr general_info_off
	move.w (sp)+,d7
.exit:
	bsr remove_traps
	rts
.machine_power:
   moveq #0,d1
   trap #10
   move.l d0,d3
.wait:
	trap #10
   cmp.l d0,d3
   beq.s .wait
   moveq.l #16,d3
   add.l d0,d3
.lb0:
   move.l d1,d2
   muls d1,d2
   add.l d1,d2
   muls d1,d2
   sub.l d1,d2
   rol.l #8,d2
   addq.l #1,d1
   trap #10
   cmp.l d0,d3
   bgt.s .lb0
   lsr.l #4,d1
	add.l #500,d1
	divs.l #1000,d1	; d1=1 Falcon, 2=TT, 50=CT60 100MHz, 200=Aranym I5
	lea .table(pc),a0
	move.l (a0)+,d0
	moveq #2,d2
	cmp.l d2,d1
	bmi.s .found	; a Falcon power
	move.l (a0)+,d0
	cmp.l d2,d1
	beq.s .found	; a TT power
	move.l (a0)+,d0
	moveq #50,d2
	cmp.l d2,d1
	bpl.s .more
	muls #51,d1
	add.l #282,d1	
	bra.s .found2
.more:
	move.l (a0)+,d0
	lsl.l #2,d2
	cmp.l d2,d1
	bpl.s .found	; more than 200, limit to 40MB
	muls #49,d1
	add.l #341,d1
	bra.s .found2
.found:
	lsl.l #8,d0
.found2:
	lsl.l #2,d0	; times 1024 in bytes
	rts 	

.table: dc.l 500,1500,11000,40000

general_info_off:
	moveq #10,d6
	moveq #-1,d7
	bra.l manage_tree
	
; d0 : 0 "idx1", 1 "load ram", 2 "count mpg"...
general_info:
	moveq #10,d6
	GADDR d6
	muls #24,d0
	move.l ([infbox24_adr],d0.l,24*2+12),24+12(a0)	; the correct string in box (starting at Obj#2)
	moveq #1,d7
	bra.l manage_tree
	
; D0 = extension exemple "RSC "

set_ext:
	lea _name,a0
.lb0:
	tst.b (a0)+
	bne.s .lb0
	subq.l #4,a0		; back on extension
	rol.l #8,d0
	move.b d0,(a0)+
	rol.l #8,d0
	move.b d0,(a0)+
	rol.l #8,d0
	move.b d0,(a0)+
	rts
		
load_options:
	move.b #1,sound_system	; default DMA if nothing laoded
	move.l #'OPT ',d0
	bsr.s set_ext		; M_PLAYER.OPT
	clr -(sp)
	pea _name
	GEMDOS 61,8			; file open
	move.l d0,d4
	bmi.s .set_options ; jump over read/close
	move.l #2304,d3
	lea options,a3
	pea (a3)
	move.l d3,-(sp)
	move d4,-(sp)
	GEMDOS 63,12		; read whole file
	move d4,-(sp)
	GEMDOS 62,4			; close
.set_options:
	lea microwire,a1
	cmp.b #$e7,(a1)	; valid ?
	beq.s .yes
	move.l #$E7281414,(a1)+	; 3 volumes
	move.l #$06060100,(a1)+	; trebble/bass/mix/dum
.yes:
	moveq #15,d0		; option dialog
	GADDR d0
	lea mjpg_fps,a1
	move.l #2000,d1
	move (a1),d0
	cmp #2,d0
	bne.s .lb9
	lsr.l #1,d1
	subq.l #1,d1		; max = 99.9
	bra.s .lb10
.lb9:
	blt.s .reset
	cmp d1,d0
	bls.s .lb7
.reset:
	moveq #20,d0
.lb7:
	divs d0,d1			; frames in 10 sec
.lb10:
	move.l 24*22+12(a0),a2		; tedinfo xx.x
	move.l (a2),a2					; string
	addq.l #3,a2					; end of string
	moveq #2,d0
.lb11:	
	divs #10,d1
	swap d1
	add.b #'0',d1
	move.b d1,-(a2)
	clr d1
	swap d1
	dbf d0,.lb11
	move.l (a2),mjpg_fps_string	; to compare for changes
	lea table_options(pc),a1
.fill_opt:
	move.w (a1)+,d1	; string number
	beq.s .lb1			; end of table
	muls #24,d1			; object offset
	lea 12(a0,d1.l),a2	; obspec
	tst.w (a3)+				; flag <>0 ?
	beq.s .lb2
	move.l a3,(a2)			; yes so valid string
	bra.s .lb3
.lb2:
	move.l #.dum_str,(a2)	; no; so dum string
.lb3:
	lea 510(a3),a3	
	bra.s .fill_opt
.lb1:
	move (a1)+,d1		; button number
	beq.s .lb4			; end of table
	muls #24,d1
	bmi.s .lb6			; special value for radio buttons
	lea 11(a0,d1.l),a2	; ob_state
	tst.b (a3)+			; FF for selected ?
	beq.s .lb5
	bset #0,(a2)		; yes, set bit
	bra.s .lb1
.lb5:
	bclr #0,(a2)		; no, clear bit
	bra.s .lb1
.lb6:
	neg.l d1
	lea 11(a0,d1.l),a2	; ob_state DMA
	bclr #0,(a2)
	bclr #0,24(a2)
	bclr #0,48(a2)			; 3 buttons reset
	moveq #0,d1
	move.b (a3)+,d1		; 1-2-3
	and.b #$03,d1
	beq.s .lb1				; oups...
	muls #24,d1
	bset #0,-24(a2,d1.l)	; and set correct button
	bra.s .lb1
.lb4:
	rts	
.dum_str: dc.b "_________________",0

table_options: dc.w 14,6,7,8,0	; string numbers in tree
	dc.w 20,9,10,11,-16,23,21,0	; button number in tree
	
validate_sound_option:
	moveq #15,d0
	GADDR d0						; option tree
	lea 16*24+11(a0),a0		; first radio button "state"
	move.l snd_value,d0
	btst #1,d0					; DMA available?
	bne.s .lb0					; yes!
	bclr #0,(a0)				; remove selected
	bset #3,(a0)				; and set disabled
.lb0:
	btst #0,d0					; Yamaha available?
	bne.s .lb1					; yes!
	bclr #0,24(a0)				; remove selected
	bset #3,24(a0)				; and set disabled
.lb1:	
	tst.b psnd_flag			; Psound available?
	bne.s .lb2					; yes!
	bclr #0,48(a0)				; remove selected
	bset #3,48(a0)				; and set disabled
.lb2:
	moveq #0,d1
	move.b sound_system,d1	; the system wanted in Options
	muls #24,d1
	lea -24(a0,d1.l),a1		; points to the "state" wanted
	btst #3,(a1)				; disabled?
	beq.s .ok					; no, so it's ok
	move.l a0,a1				; else we have to change...
	btst #3,(a1)				; DMA available?
	beq.s .ok					; yes, prefer this
	lea 48(a1),a1				
	btst #3,(a1)				; Psound available?
	beq.s .ok					; yes, this is the second choice
	lea -24(a1),a1
	btst #3,(a1)				; yamaha available?
	beq.s .ok					; yes, this is the last choice...
	clr.l snd_value			; no sound available !!
	rts	
.ok:
	bset #0,(a1)				; force selected
	move.l a1,d1
	sub.l a0,d1
	divs #24,d1
	addq #1,d1
	bsr.s sound_simul
	rts

; d1 BYTE 1,2,3 for each sound system
; fills snd_value and psnd_flag

sound_simul:	
	sf psnd_flag
	move.b d1,sound_system
	move.l #$FF000002,d0	; DMA
	subq.b #1,d1
	beq.s .ok
	move.l #$01000001,d0 ; yamaha
	subq.b #1,d1
	sne psnd_flag			; if true, psnd
.ok:
	move.l d0,snd_value
	rts




; d0 = 0,1,2,3 for one bloc of 512
; return D0=EQ if no path defined
; return D0=NE if path present
; A0 = string for dialog
; A1 = full path+\

get_option:
	lsl.l #8,d0
	lea (options,d0.l*2),a0
	lea 20(a0),a1		; full path
	move.w (a0)+,d0
	rts
	
	; a0=addrin bloc
	; return d0=0 if error/cancel
	; return d0<>0 if Ok
	
get_file:
	move.l a0,fileselect+16	; new addrin
	GEM_VDI show_mouse
	GEM_AES fileselect
	move.l #fs_addrin,fileselect+16		; restores it
	lea intout,a0
	move (a0)+,d0					; 0 if error
	beq.s .end
	move (a0),d0					; 0 if quit
.end:
	rts

; d7<5 for save TGA
; 5<=d7<=9 for conversion
; d7=21/22 for sound
; return EQ=0 if skip fileselector
; return NE if fileselector needed
	
auto_path_name:
	tst.b disable_options
	beq.s .lb0
.use_fs:
	moveq #1,d0
	rts
.lb0:
	moveq #2,d0			; images?
	lea tga_path,a4
	lea tga_file,a3
	cmp #5,d7
	bmi.s .lb1
	moveq #3,d0			; no, conversion?
	cmp #10,d7
	bmi.s .lb1
	moveq #1,d0			; no, so it's a sound
	lea avr_path,a4
	lea avr_file,a3	
.lb1:
	bsr get_option
	beq.s .use_fs		; no path defined for this option
.lb2:
	move.b (a1)+,(a4)+
	bne.s .lb2			; copy path
	tst.b auto_name
	beq.s .use_fs		; dont create name automatically, so use fileselector
	cmp #21,d7
	beq.s .use_fs		; it's "add a sound", so no auto name
	lea dta+30,a1		; source filename
	moveq #7,d1			; 8 chars max
.lb3:
	move.b (a1),d0		; name padded with "_" up to 8 chars
	beq.s .pad
	cmp.b #' ',d0
	beq.s .pad
	cmp.b #".",d0
	beq.s .pad
	move.b (a1)+,(a3)+
	bra.s .lb4
.pad:
	move.b #'_',(a3)+
.lb4:
	dbf d1,.lb3
	clr.b (a3)
	cmp #5,d7
	bmi.s .tga
	cmp #10,d7
	bmi.s .conv
										; here a sound
	move.l #'.AVR',(a3)+
	clr.b (a3)						
	bra .skip_fs
											
.conv:								; here conversion
	subq.l #3,a3			; back on the last 3 chars
	move.b quality_char,(a3)+	; 1-2-3-4-5
	move.b zoom_val+3,(a3)+		; H S D (half, same, double)
	lea (.ext_table-48,pc,d7.w*8),a1
	move.l (a1)+,(a3)+
	move.w (a1),(a3)
	bra.s .skip_fs
.tga:							; here TGA
	tst.b create_folder
	beq.s .do_not		
	subq.l #8,a3			; name
	subq.l #1,a4
.lb6:
	move.b (a3)+,(a4)+	; append name to path
	bne.s .lb6
	subq.l #1,a4
	subq.l #1,a3
	move.l #'\*.*',(a4)+		; old path\ + name\*.*
	clr.b (a4)
	pea opt_dta
	GEMDOS 26,6
	move #16,-(sp)			; system dir present?
	pea tga_path
	GEMDOS 78,8				; fsfirst (dsetpath ne fonctionne pas!)
	subq.l #3,a4
	clr.b (a4)				; end at \
	tst d0
	beq.s .exist
	clr.b -(a4)				; remove \ to create
	pea tga_path
	GEMDOS 57,6				; dcreate
	tst d0
	bmi.s .error
	move.b #"\",(a4)		; put \ again
.exist:
.do_not:
	move.l sample_num2,d0	; here TGA file !!
	bne.s .lb5
	move.l #9999999,d0	; if no frames (mpg, gif), put max!
.lb5:
	move.b #"0",-(a3)		; as many "0" as sample num needs
	divs.l #10,d0
	bne.s .lb5
.skip_fs:
	moveq #0,d0
	rts
.ext_table:	; 8 chars each
	dc.b "6.MOV",0,0,0
	dc.b "8.MOV",0,0,0
	dc.b "8.AVI",0,0,0
	dc.b "6.AVI",0,0,0
.error:
	moveq #37,d0		; alert can't create file
	bsr.l alert
	bra .use_fs				; if can't create folder, back to fileselector
	
; get quality from dialog and fills quality_char (byte 1,2,3,4,5)
; get zoom from dialog and fill zoom_val (WORD + WORD)

get_quality_zoom:
	move.l tree,a1
	move.b #'1',d0
	lea 371(a1),a0		; selected de qualite
.again:
	btst #0,(a0)
	bne.s .qual
	add.w #24,a0
	addq.b #1,d0
	bra.s .again
.qual:
	move.b d0,quality_char
	move.l #$01010000+'S',d0	; same
	btst #0,611(a1)
	bne.s .pas_zoom
	btst #0,587(a1)
	bne.s .zoom2
	move.l #$01020000+'H',d0		; half
	bra.s .pas_zoom
.zoom2:
	move.l #$02010000+'D',d0		; double
.pas_zoom:
	move.l d0,zoom_val
	rts

load_jpg_rim:
	tst.b is_mjpg
	beq.s .exit
	bsr.s alloc_mjpeg_rvb
	bsr.s load_rim
.exit:
	rts
	
alloc_mjpeg_rvb:
	move max_imagex,d0
	move max_imagey,d1
	add #15,d0
	and.w #$FFF0,d0
	move d1,imagey+2		; for qt_raw24
	muls d1,d0
	move.l d0,d1
	add.l d1,d1
	add.l d0,d1
	lea bufused,a0
	move.l d1,(a0)+	; size of buffer for RIM
	move.l d1,(a0) 	; bufused_save
	cmp.b #2,is_mjpg
	bmi.s .lb0			; enough for AVI and JPEG
	move.l d1,d0		; add half buffer for MJPEG A/B MOV
	addq.l #7,d0		; security
	lsr.l #1,d0
	add.l d0,d1			; 1,5 * buffer for 2 frames
.lb0:
	move.l d1,-(sp)
	bsr.l malloc
	move.l d0,mjpg_buffer
	move.l (sp)+,d1
	move.l d0,a0
	moveq #0,d0
.lb1:
	move.l d0,(a0)+
	move.l d0,(a0)+
	subq.l #8,d1
	bgt.s .lb1
	rts
	
load_rim:
	lea _name,a0
	lea DCTptr,a1
.copypath:
	move.b (a0)+,(a1)+
	bne.s .copypath
	lea -13(a1),a1		; back to M_PLAYER.xxx
	lea rim_file(pc),a0
.addname:
	move.b (a0)+,(a1)+
	bne.s .addname
	move #0,-(sp)
	pea DCTptr
	GEMDOS 61,8			; open JPEG_68K.RIM
	move.l d0,d3
	bmi.s .error
	bsr cache_off
	pea DCTptr
	move.l #40000,-(sp)
	move d3,-(sp)
	GEMDOS 63,12		; read whole file
	bsr cache_on
	move d3,-(sp)
	GEMDOS 62,4			; close file
	bsr cache_off
	pea 0.w
	move #0,-(sp)		; code=0, appel nul mais reloge le module
	jsr DCTptr+68		; si code=1 affiche les copyrights
	addq.l #6,sp
	bsr cache_on
.exit:
	rts
.error:
	moveq #40,d0		; alert no RIM found
	bra.l ooops
	
	
rim_file: dc.b "JPEG_68K.RIM",0
	even

qt_mjpa:
	cmp.b #3,is_mjpg
	beq qt_mjpb
	move.l buffer,a1
	move.l a1,a0
	cmp.w #$FFD8,(a0)+
	bne.s .exit
.loop:
	move.w (a0)+,d0	; marker
	cmp #$FFE1,d0		; mjpg?
	beq.s .found
	cmp #$FFDB,d0
	beq.s .exit			; no mjpeg bloc...
	cmp #$FFC4,d0
	beq.s .exit			; no mjpeg bloc...
	cmp #$FFC0,d0
	beq.s .exit			; no mjpeg bloc...
	cmp #$FFDA,d0
	beq.s .exit			; no mjpeg bloc...
	move (a0),d0
	add.w d0,a0
	bra.s .loop			; else jump over bloc
.exit: rts
.found:
	cmp #20,(a0)+		; at least 20 bytes?
	bmi.s .exit
	cmp.l #'mjpg',4(a0)
	bne.s .exit
	move.l 16(a0),a3	; offset to next frame !!
	add.l a1,a3			; in absolute
	lea bufused,a0
	move.l (a0),d1
	move.l 4(a0),(a0)	; due to a strange behaviour in qt_raw24
							; bufused must be reset to w*h*3 (bufused_save)		
	move.l mjpg_buffer,d3
	bsr decomp_jpeg	; one frame
	bne.s .exit			; error...
	move.l bufused_save,d1
	add.l d1,d3			; decomp in second zone
	move.l a3,a1		; second frame!
	bsr decomp_jpeg
	bne.s .exit
qt_mjpab_common:
	move.l bufused_save,d1
	move.l mjpg_buffer,a1
	lea 0(a1,d1.l),a0	; end of normal buffer
	lsr.l #1,d1
	lea 0(a0,d1.l),a2	; end of second frame
	add.l d1,a1			; end of first frame
	move max_imagex,d3
	subq #1,d3
	move max_imagey,d1
	lsr #1,d1
	subq #1,d1
.interlace:
	move d3,d0
.line2:
	move.b -(a2),-(a0)
	move.b -(a2),-(a0)
	move.b -(a2),-(a0)
	dbf d0,.line2
	move d3,d0
.line1:
	move.b -(a1),-(a0)
	move.b -(a1),-(a0)
	move.b -(a1),-(a0)
	dbf d0,.line1
	dbf d1,.interlace
	
	move.l buffer,-(sp)
	move.l a0,buffer		; mjpg_buffer
	move.l mjpg_comp,a0
	jsr (a0)
	move.l (sp)+,buffer
.exit:
	rts

qt_mjpb:
	move.l buffer,a1			; here to build new header
	move.l a1,a0
	add.l mjpg_offset,a0		; points to the actuel 1st frame	
	bsr.s .one_frame
	bne.s .exit
	lea bufused,a0
	move.l 4(a0),(a0)	; due to a strange behaviour in qt_raw24
							; bufused must be reset to w*h*3 (bufused_save)		
	move.l mjpg_buffer,d3
	bsr decomp_jpeg
	bne.s .exit
	
	move.l buffer,a1
	move.l a3,a0
	bsr.s .one_frame
	bne.s .exit
	move.l mjpg_buffer,d3
	add.l bufused_save,d3
	bsr decomp_jpeg
	bne.s .exit	
	bra qt_mjpab_common
.exit: rts
	
.glups: rts
.one_frame:
	tst.l (a0)+					; should be zero
	bne.s .glups
	cmp.l #'mjpg',(a0)+
	bne.s .glups
	lea jfifhead,a3
	move.l (a3)+,(a1)+		; JFIF header
	move.l (a3)+,(a1)+		; JFIF header
	move.l (a3)+,(a1)+		; JFIF header
	move.l (a3)+,(a1)+		; JFIF header
	move.l (a3)+,(a1)+		; JFIF header
	move.l (a0)+,d3			; real size
	addq.l #4,a0
	move.l (a0)+,a3			; pointer to frame 2
	lea -20(a0,a3.l),a3		; start of frame 2
	move.l (a0)+,a2
	lea -24(a0,a2.l),a2
	move #$FFDB,(a1)+
	bsr.s .copy_bloc
	move.l (a0)+,a2
	lea -28(a0,a2.l),a2
	move #$FFC4,(a1)+
	bsr.s .copy_bloc	
	move.l (a0)+,a2
	lea -32(a0,a2.l),a2
	move #$FFC0,(a1)+
	bsr.s .copy_bloc
	move.l (a0)+,d0			; this bloc can be null
	beq.s .jump
	lea -36(a0,d0.l),a2
	move #$FFDA,(a1)+
	bsr.s .copy_bloc	
.jump:
	move.l (a0)+,d0
	bne.s .data_present
	moveq #1,d0
	bra.s .glups
.data_present:	
	sub.l d0,d3					; remaining size for data
	bmi.s .glups
	lea -40(a0,d0.l),a2
.pad_ff:
	move.b (a2)+,d0
	move.b d0,(a1)+
	cmp.b #$ff,d0
	bne.s .lb3
	clr.b (a1)+					; add 00 after FF
.lb3:	
	subq.l #1,d3
	bne.s .pad_ff		
	move.b #$FF,(a1)+
	move.b #$D9,(a1)+			; end marker
	move.l a1,d1
	move.l buffer,a1			; start of image
	sub.l a1,d1					; size of image
	moveq #0,d0					; return EQ
	rts
.copy_bloc:
	move.w (a2),d0
	bra.s .lb0
.lb1:
	move.b (a2)+,(a1)+
.lb0:
	dbf d0,.lb1
	rts	
		
	
qt_jpeg:
	lea bufused,a0
	move.l (a0),d1
	move.l buffer,a1
	move.l 4(a0),(a0)	; due to a strange behaviour in qt_raw24
							; bufused must be reset to w*h*3 (bufused_save)
	bra.s jpeg_ok
	
avi_mjpg:
	move.l -8(a6),d1			; taille image
	move.l buffer,a0
	add.l mjpg_offset,a0
	move.l a0,a1				; start of jpeg file
	cmp.l #'jpeg',comp_txt	; jpeg files or mjpg ?
	beq.s jpeg_ok				; ig jpeg, nothing to verify
	cmp.l #$FFD8FFE0,(a0)+
	bne.s .exit
	cmp.w #$0010,(a0)+
	bne.s .exit
	cmp.l #'JFIF',(a0)
	beq.s jpeg_ok
	cmp.l #'AVI1',(a0)
	beq.s .avi_header
.exit:
	rts
.avi_header:	
	lea 14(a0),a1				; if AVI1, remove this header
	lea jfifhead+440,a0		; and replace with correct one
	moveq #54,d0
.copyheader:
	move.l -(a0),-(a1)
	move.l -(a0),-(a1)
	dbf d0,.copyheader		; now a1 = jpeg pointer
	add.l #440-20,d1			; new size 440 new header - 20 old header
jpeg_ok:
	move.l mjpg_buffer,d3
	bsr.s decomp_jpeg
	bne.s .exit

	move.l buffer,-(sp)
	move.l mjpg_buffer,buffer
	move.l mjpg_comp,a0
	jsr (a0)
	move.l (sp)+,buffer
		
.exit:
	rts

; return NE if error
; EQ if all OK
; d1=size, a1=address image JPEG, d3=(mjpg_buffer)=adr ou ranger les RVB

decomp_jpeg:
	pea mjpg_mfdb			; mfdb
	move.l #'.JPG',-(sp)	; extension
	move.l d1,-(sp)		; size loaded
	move.l d1,-(sp)		; total size
	move.l a1,-(sp)		; address image
	move #0,-(sp)			; code 0
	jsr DCTptr+56			; test image
	addq.l #2,sp
	move.l (sp)+,a1
	move.l (sp)+,d1
	lea 12(sp),sp
	
	cmp #3,d0
	bne.s .exit
	
	lea mjpg_mfdb,a0
	move.l d3,(a0)
	pea (a0)			; mfdb
	move.l d1,-(sp)	; size image
	move.l a1,-(sp)	; adress image
	move #0,-(sp)		; code=0
	jsr DCTptr+64		; uncompress JPEG
	lea 14(sp),sp

	cmp #3,d0
.exit:
	rts

	
jfifhead: INCBIN "JFIFHEAD.BIN"	; header to complete AVI1 MJPG frames

mjpeg_parse_bin:
	SEEK #0,0
	lea Sas,a3			
	pea (a3)
	move.l #65540,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l d0,d4		; size read
	move.l (a3),d0
	lsr.l #8,d0
	cmp.l #$00FFD8FF,d0
	beq.s .ok
.exit:
	rts					; return NE if not correct
.ok:
	bsr load_rim
	lea mjpg_mfdb,a4
	pea (a4)					; mfdb
	move.l #'.JPG',-(sp)	; extension
	move.l d4,-(sp)		; size loaded
	move.l d4,-(sp)		; total size
	move.l a3,-(sp)		; address image
	move #0,-(sp)			; code 0
	jsr DCTptr+56			; test image
	lea 22(sp),sp
	cmp #3,d0
	bne.s .exit			
	move 4(a4),d0
	add #15,d0
	and #$FFF0,d0
	move d0,max_imagex
	move 6(a4),max_imagey
	moveq #0,d0
	move.w mjpg_fps,d0
	move.l d0,_delay
	lea DCTptr+131072,a5
	move.l a5,samp_sizes	; simule le bloc
	bsr.s count_mjpeg_frames
	move.l #'jpeg',d1
	cmp.l #1,sample_num
	beq.s .lb0
	move.l #'mjpg',d1
	movem.l d0-d7/a0-a6,-(sp)
	bsr general_info_off
	movem.l (sp)+,d0-d7/a0-a6	
.lb0:
	move.l d1,comp_txt
	moveq #0,d0
	rts


count_mjpeg_frames:
	move.l a3,a0
	moveq #-1,d2			; FF
	moveq #0,d1				; to manage bytes
	move.l #-2,sample_num	; =0 with 2 frames to write "Counting MJPEG FRAMES"
	moveq.l #0,d5			; first offset
	subq.l #4,d4
	move.l #65536,d7
.bloc:
	move.l #$FFFF,d0
	cmp.l d7,d4
	smi d6					; EOF marker
	beq.s .loop
	move.l d4,d0
	bra.s .loop
.again:
	cmp.b (a0)+,d2			; marker FF?
	beq.s .found
.loop:
	dbf d0,.again	
	tst.b d6
	bne.s .fin
	bsr.s .load_bloc
	bra.s .bloc
.found:
	move.b (a0),d1
	beq.s .loop			; FF 00
	cmp #1,d1
	beq.s .loop			; FF 01
	cmp.b #$D8,d1		; FF D8 start of image
	beq.s .new_frame
	cmp #$D0,d1
	bmi.s .skipbloc	; under D0, so from 02 to CF	
	cmp #$D9,d1
	bls.s .loop			; D0-D7/D9 nothing more to do
.skipbloc:
	move 1(a0),d1		; bloc size
	addq.l #1,d1
	add.l d1,a0			; new pointer
	sub.l d1,d0
	bpl.s .loop
	sub.l d7,a0
	movem.l d0/a0,-(sp)
	bsr.s .load_bloc
	movem.l (sp)+,d0/a0
	add.l d4,d0
	moveq #0,d1
	bra.s .loop
.new_frame:
	addq.l #1,sample_num
	bne.s .not_second
	movem.l d0-d7/a0-a6,-(sp)
	moveq #4,d0
	bsr general_info
	movem.l (sp)+,d0-d7/a0-a6
.not_second:
	lea -1(a0),a1			; back one byte
	sub.l a3,a1
	add.l d5,a1				; offset in the file
	move.l a1,(a5)+
	bra.s .loop	
.fin:	
	sub.l a3,a0
	add.l d5,a0
	move.l a0,(a5)			; last offset
	addq.l #2,sample_num
	rts
.load_bloc:
	move.l 0(a3,d7.l),(a3)	; last bloc as first
	pea 4(a3)
	move.l d7,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12
	move.l d0,d4		; size read		
	move.l a3,a0
	add.l d7,d5
	rts
	
is_mjpeg:
	move.l #mjpeg_title,a3
	moveq #0+4,d3
	bsr.l principal
	bsr.l remet_play_sound
	bne.l end_of_display
	clr.l _delay			; no delay if max_speed set!
	btst #0,299(a0)
	beq.s .lb4
	move mjpg_fps,_delay+2
.lb4:
	bsr.l treat_control
	bsr.l treat_saveas
	tst.b step_mode
	beq.s .lb4a
	moveq #1,d7
	bsr.l init_step_mode
	beq.l end_of_display_na
.lb4a:
	bsr.l init_rect
	bsr mjpeg_buffer_size
	move.l max_fsize,d1
	add.l mjpg_offset,d1
	bsr.l malloc
	move.l d0,buffer
	bsr alloc_mjpeg_rvb
	lea qt_raw24,a0
	move.l a0,a1
	cmp #8,planes
	beq.s .mjp2
	tst.b nova
	bne.s .mjp1
	lea qt_raw24_falc,a0
	bra.s .mjp1
.mjp2:
	lea qt_raw24_256,a0
.mjp1:
	move.l a1,mjpg_step_compression
	move.l a0,mjpg_comp
	st is_mjpg
;	move.l #440,mjpg_offset
	clr off_24_32			; 24 bits (for qt_raw)
	move.l #avi_mjpg,d0
	move.l d0,step_compression	
	bsr.l set_video
	cmp #8,planes
	bne.s .lb0
	bsr.l set_colors
.lb0:
	bsr.l _run_m_player
	bsr.s mjpeg_read_data	
	bra.l end_of_display
	
mjpeg_buffer_size:
	lea DCTptr+131072,a5
	move.l sample_num,d0
	moveq #0,d4
	move.l (a5)+,d1
.lb0:
	move.l (a5)+,d2
	move.l d2,d3
	sub.l d1,d3			; frame size
	cmp.l d3,d4
	bpl.s .lb1
	move.l d3,d4		; new max
.lb1:
	move.l d2,d1
	subq.l #1,d0
	bne.s .lb0
	move.l d4,max_fsize
	rts
	
mjpeg_read_data:
	lea DCTptr+131072,a6	; offset pointer
	move.l sample_num,d7	; number of images
	tst.b step_mode
	bne mjpeg_step_mode
	tst.b is_tt
	beq.s .nott
	move.l mjpg_comp,tt_comp
	move.l compression,mjpg_comp
.nott:
	bsr install_traps
.repeat:
	lea DCTptr+131072,a6	; offset pointer
	move.l sample_num,d7	; number of images
	clr.l disp_frame
	trap #10
	move.l d0,start_time
	move.l d0,current_time
.again:
	move.l (a6)+,d3
	SEEK d3,0
	move.l (a6),d4
	sub.l d3,d4				; frame size
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read frame
	move.l buffer,a1		; address
	move.l d4,d1			; size
	addq.l #1,disp_frame
	movem.l d7/a6,-(sp)
	bsr jpeg_ok
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	movem.l (sp)+,d7/a6
	move.l _delay,d1
	beq.s .no_sync
	trap #10
	add.l d1,current_time
	cmp.l current_time,d0
	bmi.s .wait
.sync:
	addq.l #4,a6
	subq.l #1,d7
	beq.s .last
	add.l d1,current_time
	cmp.l current_time,d0
	bgt.s .sync	
	bra.s .no_sync
.wait:
	trap #10
	cmp.l current_time,d0
	bmi.s .wait
.no_sync:
	btst #2,([kbshift])
	bne.s .stop
	subq.l #1,d7
	bne .again
.last:
	cmp.l #1,sample_num	; one single JPEG?
	beq.s .admire_jpeg
	btst #2,([kbshift])
	bne.s .stop	
	tst.b is_rep
	bne .repeat
	bra.s .stop
.admire_jpeg:
	GEM_AES graf_mkstate
	lea intout+6,a0
	tst (a0)+
	bne.s .stop				; one mouse button !
	move (a0),d0
	btst #2,d0				; control key?
	beq.s .admire_jpeg
.stop:
	bra common_end
	
mjpeg_step_mode:
	lea DCTptr+131072,a6	; offset pointer
	move.l sample_num,d7	; number of images
	move.l mjpg_step_compression,mjpg_comp
.again:
	move.l (a6)+,d3
	tst _ritme
	bne.s .bug				; skip unsaved frames
	SEEK d3,0
	move.l (a6),d4
	sub.l d3,d4				; frame size
	move.l buffer,-(sp)
	move.l d4,-(sp)
	move mov_h,-(sp)
	GEMDOS 63,12			; read frame
	move.l buffer,a1		; address
	move.l d4,d1			; size
	movem.l d7/a6,-(sp)
	bsr jpeg_ok
	tst.b is_vdi
	beq.s .no_vdi
	jsr vdi_display
.no_vdi:
	movem.l (sp)+,d7/a6
.bug:
	bsr.l inc_frame
	beq.s .quit
	bpl.s .loop
	bsr.l save_frame
	bmi.s .bug
.loop:
	subq.l #1,d7
	bpl.s .again
.quit:
	bsr.l close_step_dialog
	rts

manage_easybat:
	moveq #0,d7
	moveq #19,d6
	bsr.l manage_tree
	move.l tree,a0
	cmp #71,d6			; cancel?
	bne.s .lb0
	rts					; return EQ when nothing to do
.lb0:
	cmp #14,d6			; output file type?
	bgt.s .lb1
	moveq #24,d0
	muls d6,d0
	bset #0,11(a0,d0.l)	; remet le bouton ON, il doit rester s‚lectionn‚
	subq #6,d6			; de 0 … 8
	lea ebat_objects(pc),a1
	lea .enable_disable(pc),a2
	move 0(a2,d6.w*2),d1	; mask
.set_dis:
	move (a1)+,d0			; object num
	beq.s .all_set			; end_of_list
	muls #24,d0
	lea 11(a0,d0.l),a2	; state
	bclr #3,(a2)			; enabled
	ror #1,d1				; one bit into carry
	bcs.s .set_dis			; if set, ok
	bset #3,(a2)			; if not, then disable object
	bra.s .set_dis		
.all_set:
	btst #3,24*47+11(a0)	; sound disabled?
	beq.s .soundon			; no, normal
	bclr #0,24*47+11(a0)	; unselect use sound
	bclr #4,24*46+9(a0)	; no more radio button
.common:
	bset #0,24*46+11(a0)	; select use time
	bra.s manage_easybat	
.soundon:
	bset #4,24*46+9(a0)	; radio button
	btst #0,24*47+11(a0)	; is sound off?
	beq.s .common			; yes, so select use time
	bclr #0,24*46+11(a0)	; else clear use time
	bra manage_easybat	
.lb1:	
	cmp #41,d6				; images box?
	bgt.s .lb2
	bsr ebat_load_image
	bra manage_easybat			
.lb2:	
	cmp #62,d6				; vr parameters?
	bne.s .lb3
	bset #0,61*24+11(a0)	; validate "turn to vr mov"
	moveq #0,d7
	moveq #20,d6
	bsr.l manage_tree
	bra manage_easybat
.lb3:
	cmp #76,d6				; output filename?
	bne.s .lb4
	lea ebat_out,a3		; path for output
	lea 7*400(a3),a4		; temp path
	muls #24,d6
	lea 0(a0,d6.l),a2		; object
	moveq #-1,d5			; dummy value
	bsr _common_ebat_load
	bra manage_easybat
.lb4:
	cmp #65,d6				; verif ??
	bne.s .lb5
	bsr ebat_verify
	bra manage_easybat
.lb5:
	cmp #50,d6
	bne.s .lb6
	lea ebat_path+2000,a3		; path for sound file
	lea 400(a3),a4		; temp path
	muls #24,d6
	lea 0(a0,d6.l),a2		; object
	moveq #-1,d5			; dummy value
	clr.b d5					; FFFF FF00
	bsr _common_ebat_load
	bra manage_easybat	
.lb6:
	cmp #73,d6				; save to BAT !
	bne.s .lb7
	bsr.s ebat_verify
	bne manage_easybat	; errors, can't save
	bsr prepare_memorybat
	bsr save_bat
	bra manage_easybat
.lb7:
	cmp #74,d6				; create
	bne.s .lb8
	bsr.s ebat_verify
	bne manage_easybat	; errors, can't proceed
	bsr prepare_memorybat
	moveq #-1,d0			; return NE when create !
	rts
.lb8:
	cmp #72,d6				; load from bat
	bne.s .lb9				; euh... error?
	bsr load_dial_settings
	bra manage_easybat
.lb9:
	moveq #0,d0				; nothing to do
	rts
	; VR, VR, qual 5-4-3-2-1, keyf, snd, use snd, use time
.enable_disable: dc.w %11111111111		; mov highcolor
					  dc.w %11111111100		; avi 16
					  dc.w %11111111100		; avi88g
					  dc.w %11111111111		; mov 8
					  dc.w %11111111100		; avi88
					  dc.w %11111111100		; avi88g
					  dc.w %11100000000		; flmpp
					  dc.w %11100000000		; flmnn
					  dc.w %10000000000		; gif
ebat_obj: dc.w 21,26,31,36,41
ebat_objects: dc.w 62,61,59,58,57,56,55,53,50,47,46,0
					  
ebat_verify:
	moveq #19,d0
	GADDR d0
	move.l a0,a3		; tree
	lea 6*24+11(a0),a0	; first state
	moveq #0,d3
.find_type:
	btst #0,(a0)
	bne.s .lb0
	lea 24(a0),a0
	addq.l #1,d3
	bra.s .find_type
.table:
	dc.l 'TGA ','TGA ','TGA ','XIMG','XIMG','XIMG','PI1 ','NEO ','GIF '
	dc.l 'tga2','tga2','tga2','ximg','ximg','ximg','dega','neoc','gif8'
	dc.b 0,0,0,0,'+',0,0,0,'+',0,'-',0,0,0,0,0,'#',0,0,0,'+',0,0,0
	dc.l 0,0,0
.lb0:						; here D3=file type (0 to 8)
	lea .table(pc),a0
	move.l 0(a0,d3.l*4),comp_txt		; extension des images
	move.l 36(a0,d3.l*4),comp_create	; code pour c=xxxx
	move.l 72(a0,d3.l*4),vr_offset	; codes … ajouter devant o= et q=
	moveq #4,d7
	sf tgac					; default is uncompressed TGA
	clr.l sample_num		; number of frames
	clr.l max_fsize
	clr max_imagex
	clr max_imagey
	st first_image
	lea 19*24+12(a3),a4	; object with filename
	lea ebat_path,a5		; the path
	lea ebat_path_names,a6	; to store result (long repeat (or -1), byte 0 (inc) ff dec (6 bytes/group)
.image_group:
	bsr verif_one_group
	beq .error
	move.l (a6),d0
	addq.l #1,d0
	add.l d0,sample_num	; update number of frames
	lea 5*24(a4),a4
	lea 400(a5),a5
	addq.l #6,a6
	dbf d7,.image_group
	move.l sample_num,d0
	beq .no_image
	move.l 66*24+12(a3),a1
	move.l (a1),a1	
	bsr.l int_to_str		; string with number of frames found
	move max_imagey,d0
	ext.l d0
	move.l 67*24+12(a3),a1
	move.l (a1),a1	
	move.l #'____',(a1)+
	bsr.l int_to_str		; string with H
	move max_imagex,d0
	ext.l d0
	move.l 67*24+12(a3),a1
	move.l (a1),a1	
	bsr.l int_to_str		; string with W
	move.b #'_',(a1)
	move.l 76*24+12(a3),a1	; output file
	tst.b (a1)
	beq .no_output
	clr.l _delay
	moveq #46,d0			; button "use time"
	bsr .is_on
	ble.s .sync0			; if not selected, skip
	move.l 49*24+12(a3),a1	; ted time
	move.l (a1),a5			; string	
	bsr.l _number
	move.l d0,_delay
	beq .no_time
	move.l sample_num,d1
	muls d0,d1				; total time in 1/200
	move.l d1,end_time	; total time in 1/10
	bra.s .sync1
.sync0:
	moveq #47,d0			; button "use sound file"
	bsr .is_on
	ble.s .sync1			; if not selected, skip
	move.l 50*24+12(a3),a1	; sound file
	tst.b (a1)
	beq .no_sound
	bsr ebat_sound_verif
	beq .noc					; an error
.sync1:
	move.l end_time,d0
	divs.l #20,d0				; 1/200 -> 1/10
	neg.l d0						; because in 1/10
	move.l 68*24+12(a3),a1	; ted duration
	move.l (a1),a1
	bsr.l int_to_str
	move.l sample_num,d0
	muls.l #2000,d0
	divs.l end_time,d0		; rate in 10*fps
	neg.l d0						; in 1/10
	move.l 69*24+12(a3),a1	; ted duration
	move.l (a1),a1
	bsr.l int_to_str	
.sync5:	
	clr key_rate
	moveq #53,d0			; key_frame rate
	bsr .is_on
	bmi.s .sync2
	move.l 53*24+12(a3),a1
	move.l (a1),a5
	bsr.l _number
	move.w d0,key_rate
.sync2:
	moveq #0,d1				; default no quality
	moveq #55,d0
	bsr .is_on	
	bmi.s .sync3			; disabled
	lea 55*24+11(a3),a0	; parse radio buttons from qual=1 to 5
.sync4:
	addq #1,d1
	btst #0,(a0)
	bne.s .sync3
	lea 24(a0),a0
	bra.s .sync4
.sync3:
	move d1,quality		; when found, saved to quality
	lea vr_flag,a4
	sf (a4)
	moveq #61,d0
	bsr .is_on				; turn to VR
	ble.s .sync6			; no VR informations
	st (a4)					; else go for infos
	addq.l #2,a4
	moveq #20,d0
	GADDR d0
	lea 5*24+12(a0),a0	; first TED
	moveq #4,d2
.get_vr:
	move.l (a0),a5
	move.l (a5),a5			; string
	bsr.l _number
	move d0,(a4)+			; store col,line,startx,starty,img/cell
	lea 24(a0),a0			; next ted
	dbf d2,.get_vr
	moveq #0,d0
	btst #0,-1(a0)			; state for horizontal loop
	beq.s .sync7
	moveq #1,d0
.sync7:
	move d0,(a4)+			; horizontal loop 1 or 0
	lea -12(a4),a4			; back on data
	move (a4)+,d0			; col
	move (a4)+,d1			; lines
	cmp (a4)+,d0
	ble.s .bad_start			; start-x must be < columns
	cmp (a4)+,d1
	ble.s .bad_start			; idem for start-y
	muls d0,d1
	muls (a4),d1			; col*lines*img/cell
	cmp.l sample_num,d1	; must be the total frames number !
	bne.s .bad_vr
.sync6:
	move.l ([fstring_adr],7*24+12),a0	; string "Ok !"
	moveq #11,d0				; green
	moveq #0,d2					; to return EQ = ok
	bra.s .set_state
.noc:
	bsr.l alert
.error:
	move.l ([fstring_adr],8*24+12),a0	; string "errors"
	moveq #2,d0				; red
	moveq #-1,d2			; to return MI = error
.set_state:
	move.l 70*24+12(a3),a1	; tedinfo of state
	move.l a0,(a1)			; its text
	move 18(a1),d1
	and #$F0FF,d1
	lsl #8,d0
	or d0,d1
	move d1,18(a1)			; its color
	tst.l d2					; return EQ = ok or else
	rts
.bad_start:
	moveq #7,d0		; alert 1st cell out of range
	bra.s .noc
.bad_vr:
	moveq #6,d0		; alert total frames don't match vr
	bra.s .noc	
.no_image:
	moveq #9,d0		; alert no image
	bra.s .noc
.no_time:
	moveq #10,d0	; alert no time
	bra.s .noc
.no_sound:
	moveq #11,d0	; alert no sound file
	bra.s .noc
.no_output: 
	moveq #12,d0	; alert no out file
	bra.s .noc
.is_on:
	muls #24,d0
	btst #3,11(a3,d0.l)	; disabled?
	bne.s .io0
	btst #0,11(a3,d0.l)	; selected?
	beq.s .io1
	moveq #1,d0				; selected
	rts
.io1:
	moveq #0,d0				; not selected
	rts	
.io0:
	moveq #-1,d0			; disabled
	rts	
; return in a6 
; 0 : long repeat (or -1)
; 4 : byte 0 (inc) ff dec
; byte 5 is free

verif_one_group:
	move.l (a4),a1		; tedinfo
	move.l (a1),a1		; string "from" name
	tst.b (a1)			; empty line?
	bne.s .lb0
	moveq #-1,d0
	move.l d0,(a6)		; returns -1, empty group
	rts
.lb0:
	move.l 48(a4),a0
	move.l (a0),a0		; string "to"
	tst.b (a0)			; empty?
	bne.s .lb1
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1),(a0)	; if empty, copy "from"
	subq.l #8,a1
	subq.l #8,a0
.lb1:
	moveq #0,d0
	moveq #0,d4			; first number
	moveq #0,d5			; second number
	moveq #0,d1
.lb2:
	move.b (a1)+,d1
	beq.s .end_name
	move.b (a0)+,d0
	beq.s .end_name
	cmp.b d0,d1
	bne.s .build_numbers
	cmp.b #'.',d0
	beq.s .end_name
	bra.s .lb2
.build_numbers:
	sub.b #'0',d1
	bmi .error_num	; "names must differ only by digits"
	cmp.b #9,d1
	bgt .error_num
	muls #10,d5
	add.l d1,d5
	sub.b #'0',d0
	bmi .error_num
	cmp.b #9,d0
	bgt .error_num
	muls #10,d4
	add.l d0,d4
	move.b (a1)+,d1
	beq.s .end_name
	move.b (a0)+,d0
	beq.s .end_name
	cmp.b #'.',d0
	bne.s .build_numbers
	cmp.b #'.',d1
	beq.s .end_name
	bra .error_size ; "names must share the same number of digits"
.end_name:
	sf 4(a6)				; default is decrement
	sub.l d4,d5			; from - to
	bpl.s .lb3
	st 4(a6)				; if<0 then increment
	neg.l d5
.lb3:
	move.l d5,(a6)		; return LONG number of frames-1 (if 0, one frame!)
	lea ebat_path+6*400,a0		; where to store path+name (temp)
	move.l a0,a1		; last "\"+1
	move.l a5,a2		; source
.copy_path:
	move.b (a2)+,d0
	move.b d0,(a0)+
	beq.s .lb4
	cmp.b #'\',d0
	bne.s .copy_path
	move.l a0,a1
	bra.s .copy_path
.lb4:
	move.l (a4),a0
	move.l (a0),a0		; name
	move.l a1,tga_file_ptr
.lb5:
	move.b (a0)+,d0
	move.b d0,(a1)+	; copy name
	beq.s .lb6
	cmp.b #'.',d0		; until '.'
	bne.s .lb5
	lea -2(a1),a2		; last digit
.lb7:
	move.b (a0)+,(a1)+ ; remaining bytes
	bne.s .lb7
	bra.s .lb8
.lb6:
	lea -2(a1),a2		; if no extension, las digit
.lb8:
	move.l a2,tga_digit	; for increment/decrement

	pea opt_dta
	GEMDOS 26,6						; fixe ma DTA
.next_file:
	move #-1,-(sp)
	pea ebat_path+6*400			; temp
	GEMDOS 78,8						; fsfirst
	tst.l d0
	bmi .not_found

	lea opt_dta,a0
	move.l 26(a0),d4				; file size
	cmp.l max_fsize,d4
	bmi.s .lb9
	move.l d4,max_fsize			; update max file size
.lb9:
	clr -(sp)
	pea ebat_path+6*400
	GEMDOS 61,8						; fopen
	move d0,d2
	pea cvid_fix0
	move.l #128,-(sp)
	move d2,-(sp)
	GEMDOS 63,12					; fread 128 octets
	move d2,-(sp)
	GEMDOS 62,4						; fclose
	lea cvid_fix0,a0
	move.l (a0),d0
	cmp.l #$00000200,d0
	bne.s .img0
.img1:
	move 12(a0),d1
	ror #8,d1
	swap d1
	move 14(a0),d1
	ror #8,d1
	cmp.b #16,16(a0)
	beq.s .oktga
	cmp.b #24,16(a0)
	bne.s .img3				; if not a success test for PI1/NEO
.oktga:
	cmp #$0a00,d0
	bne.s .notcomp
	st tgac
.notcomp:
	moveq #1,d0				; TGA
	move.l #'TGA ',d2
	bra .ok
.img0:
	cmp.l #$00000A00,d0
	beq.s .img1
	cmp.l #'GIF8',d0
	bne.s .img2
	move 6(a0),d1
	ror #8,d1
	swap d1
	move 8(a0),d1
	ror #8,d1
	moveq #4,d0				; GIF file
	move.l #'GIF ',d2
	bra.s .ok	
.img2:
	swap d0
	cmp #1,d0				
	bne.s .img3
	cmp #8,4(a0)
	bne.s .img3
	cmp.l #'XIMG',16(a0)
	bne.s .img3
	move.l 12(a0),d1		; l,h
	moveq #2,d0				; XIMG
	move.l #'XIMG',d2
	bra.s .ok
.img3:
	cmp.l #32034,d4		; pi1?
	bne.s .img4
	moveq #8,d0
	move.l #'PI1 ',d2
.pi1_neo:
	tst.w (a0)+				; resolution = 0
	bne .unknown
	moveq #15,d4
.test_palette:
	move (a0)+,d1
	and.w #$F000,d1		; high nibble = 0 in palette
	bne .unknown
	dbf d4,.test_palette
	move.l #$014000c8,d1	; 320x200
	bra.s .ok	
.img4:
	cmp.l #32128,d4
	bne.s .unknown
	addq.l #2,a0
	moveq #16,d0
	move.l #'NEO ',d2
	bra.s .pi1_neo
.ok:
	tst.b first_image
	beq.s .not_first
	move.l d1,max_imagex	; w h
	sf first_image
	bra.s .verif_type
.not_first:
	cmp.l max_imagex,d1	; same w and h ?
	bne.s .error_wh
.verif_type:
	cmp.l comp_txt,d2
	bne.s .error_type
	tst.b 4(a6)						; direction
	bne.s .inc
	bsr.l decrement_name
	bra.s .lb10
.inc:
	bsr.l increment_name
.lb10:
	dbf d5,.next_file
	moveq #-1,d0	
	rts
	; ALERT this image has not the same size as the previous
.error_wh:
	moveq #17,d1
	lea alert_ptr+28,a0
	bra.s .name_
	; ALERT this image is not of the required type
.error_type:
	moveq #18,d1
	lea alert_ptr+44,a0
	move.l (a0),a1
	move.l d2,(a1)			; current type
	move.l -(a0),a1
	move.l comp_txt,(a1)	; required type
	subq.l #4,a0
	bra.s .name_
	; ALERT this image has an unknown type
.unknown:
	moveq #16,d1		; alert #
	lea alert_ptr+20,a0
	bra.s .name_
	; ALERT image not found
.not_found:
	moveq #15,d1		; alert #
	lea alert_ptr+12,a0	; point to name ptr
.name_:
	move.l (a0),a1		; name ptr
	move.l #'    ',d0	; del name with spaces
	move.l d0,(a1)+
	move.l d0,(a1)+
	move.l d0,(a1)
	subq.l #8,a1
	move.l tga_file_ptr,a2
.nf0:
	move.b (a2)+,(a1)+
	bne.s .nf0
	move.b d0,-(a1)
	move.l -(a0),a0	; group pointer
	bra.s .error_com
	; ALERT names must differ only by digits
.error_num:
	moveq #14,d1		; alert string #
	move.l alert_ptr+4,a0	; group pointer
	bra.s .error_com
	; ALERT names must share the same number of digits
.error_size:
	moveq #13,d1		; alert #
	move.l alert_ptr,a0	; group pointer
.error_com:
	moveq #5,d0
	sub d7,d0
	add.b #'0',d0
	move.b d0,(a0)		; group number
	move.l d1,d0			; alert #
	bsr.l alert
	moveq #0,d0
	rts

ebat_load_image:
	move.l d6,d5
	sub #18,d5
	ext.l d5
	divs #5,d5
	lea ebat_path,a3
	lea 6*400(a3),a4	; temp path
	move #400,d0
	muls d5,d0
	add.l d0,a3			; image path
	move d5,d0
	muls #5,d0
	add.w #19,d0
	muls #24,d0
	move.l tree,a2
	add.l d0,a2			; address of "from" object of this line
	swap d5				; reste = 0 (bouton del) 1 (fichier from) 3 (fichier to)
	tst d5				; if 0 = clear button
	bne.s _common_ebat_load
	move.l 12(a2),a0
	move.l (a0),a0
	clr.b (a0)			; clear "from" string
	lea 48(a2),a2		; "to" object
	move.l 12(a2),a0
	move.l (a0),a0
	clr.b (a0)			; clear "to" string
	bset #3,11(a2)		; "to" string disabled
	rts
_common_ebat_load:
	moveq #99,d0
	move.l a4,a0
	move.l a3,a1
.copy_to_temp:
	move.l (a1)+,(a0)+
	dbf d0,.copy_to_temp
	lea ebat_addrin,a0
	move.l a4,(a0)		; temp path
	lea 400(a4),a1
	move.l a1,4(a0)	; temp filename
	tst d5
	bpl.s .lb0
	tst.b d5				; FFFF for output file
	bmi.s .lb0c
	move.l ([fsel30_adr],5*24+12),8(a0)	; avr title
	bra.s .lb0a	
.lb0c:
	move.l ([fsel30_adr],10*24+12),8(a0)	; convert fsel title
	bra.s .lb0a
.lb0:
	cmp #1,d5			; "from" string?
	bne.s .lb1
	move.l ([fsel30_adr],3*24+12),8(a0)	; select first image
.lb0a:
	bsr get_file
	beq.s .cancel		; cancel/error
	moveq #99,d0
.copy_from_temp:
	move.l (a4)+,(a3)+
	dbf d0,.copy_from_temp	
	tst d5
	bmi.s .copy_name
	lea 48(a2),a2		; "to" object
	move.l 12(a2),a0
	move.l (a0),a0
	clr.b (a0)			; clear "to" string
	bclr #3,11(a2)		; "to" string enabled
	lea -48(a2),a2		; "from" object
.copy_name:
	move.l 12(a2),a0
	tst d5
	bmi.s .lb0b
	move.l (a0),a0
.lb0b
	move.l (a4)+,(a0)+	; copy name (12 bytes max)
	move.l (a4)+,(a0)+	
	move.l (a4)+,(a0)+	
.cancel:
	rts
.lb1:						; here "to" string selected
	move.l ([fsel30_adr],4*24+12),8(a0)	; select last image
	bsr get_file
	beq.s .cancel		; error/cancel
	move.l a4,a1
.lb1b:
	move.b (a3)+,d0	; one "from"-path  byte
	cmp.b (a1)+,d0		; one temp-path byte
	bne.s .error		; not the same path, error
	tst.b d0				; until 0 is found !
	bne.s .lb1b
	lea 400(a4),a4		; to temp filename
	lea 48(a2),a2		; to object
	bra.s .copy_name
.error:
	move.l 48+12(a2),a0
	move.l (a0),a0
	clr.b (a0)			; clear "to" string
	moveq #19,d0		; alert paths are not similar for 1st and last image
	bsr.l alert
	rts

prepare_memorybat:
	moveq #19,d0
	GADDR d0
	move.l a0,a3		; tree	
	lea ebat_path_names+5*6,a1
	move.l #'M_PL',(a1)+
	move.l #'AYER',(a1)+	; header
	move.w #$0d0a,(a1)+
	bsr save_dial_settings	; all dialog saved with DIAL/ENDD markers
	move.w #'c=',(a1)+
	move.l comp_create,(a1)+
	tst.b tgac				; is it compressed?
	beq.s .lb00
	move.b #'c',-1(a1)	; replace tga2 with tgac
.lb00:
	move.w #$0d0a,(a1)+
	move.w #'b=',(a1)+
	move.l max_fsize,d0
	bsr.l int_to_str
	move.w #$0d0a,(a1)+
	move.w #'f=',(a1)+
	move.l sample_num,d0
	bsr.l int_to_str
	move.w #$0d0a,(a1)+
	move.w #'w=',(a1)+
	move max_imagex,d0
	ext.l d0
	bsr.l int_to_str
	move.w #$0d0a,(a1)+
	move.w #'h=',(a1)+
	move max_imagey,d0
	ext.l d0
	bsr.l int_to_str
	move.w #$0d0a,(a1)+
	move.w #'o=',(a1)+
	move.b vr_offset,d0
	beq.s .lb0
	move.b d0,(a1)+		; + or # to modify output type
.lb0:
	move.l 76*24+12(a3),d1	; addr name
	lea ebat_out,a0			; addr path
	bsr full_pathname			; add output file name
	move quality,d0
	beq.s .lb2
	move.w #$0d0a,(a1)+
	move.w #'q=',(a1)+
	move.b vr_offset+2,d1
	beq.s .lb1
	move.b d1,(a1)+	; sign - to modify output type
.lb1:
	add.b #'0',d0
	move.b d0,(a1)+	; quality 1-5
.lb2:
	move.l _delay,d0
	bmi.s .lb3			; a sound file!
	beq.s .lb4			; no time
	move.w #$0d0a,(a1)+
	move.w #'t=',(a1)+	
	bsr.l int_to_str	; add time
	bra.s .lb4
.lb3:
	move.w #$0d0a,(a1)+
	move.w #'s=',(a1)+
	move.l 50*24+12(a3),d1	; addr name
	lea ebat_path+2000,a0		; addr path
	bsr full_pathname			; add sound file name		
.lb4:
	move key_rate,d0
	beq.s .lb5
	ext.l d0
	move.w #$0d0a,(a1)+
	move.w #'k=',(a1)+	
	bsr.l int_to_str	; add key frame rate
	lea vr_flag,a4
	tst.b (a4)
	beq.s .lb5			; no vr info
	move.w #$0d0a,(a1)+
	move.w #'v=',(a1)+
	addq.l #2,a4
	moveq #5,d2
.add_vr:
	move (a4)+,d0
	ext.l d0
	bsr.l int_to_str
	move.b #',',(a1)+
	dbf d2,.add_vr
	subq.l #1,a1		; remove last ","
.lb5:
	move.w #$0d0a,(a1)+		; end of header
	move.l #'data',(a1)+
	move.w #$0d0a,(a1)+
	moveq #4,d7					; for 5 image blocs
	lea ebat_path_names,a6
	lea ebat_path,a4
	lea 19*24+12(a3),a5		; ted "from" image
.lb6:
	tst.l (a6)					; number of images in block
	bmi.s .lb8					; empty block, skip
	move.l (a5),a0
	move.l (a0),d1				; file name
	move.l a4,a0				; path
	bsr full_pathname	
	move.w #$0d0a,(a1)+
	move.l (a6),d0
	beq.s .lb8					; no repetiton, just one image
	move.l #'.rep',(a1)+
	move #'t ',(a1)+
	bsr.l int_to_str			; number of repetitions
	lea .two(pc),a0			; increment loop
	tst.b 4(a6)
	beq.s .lb9
	lea .one(pc),a0			; decrement loop
.lb9:
	move.b (a0)+,(a1)+
	bne.s .lb9
	subq.l #1,a1		
.lb8:
	addq.l #6,a6
	lea 400(a4),a4				; next path
	lea 5*24(a5),a5			; next ted
	dbf d7,.lb6
	move.l #'.sto',(a1)+
	move.l #$700d0a00,(a1)+	; 'p'
	subq.l #1,a1
	move.l a1,end_time		; comme marqueur
	rts	
.one: dc.b 13,10,".incr",13,10,".disp",13,10,".endr",13,10,0
.two: dc.b 13,10,".decr",13,10,".disp",13,10,".endr",13,10,0
	even

; a0 = path
; d1 = name
; a1=full updated
; d0-a2 used
; return d0=fileptr in fullname

full_pathname:
	move.l a1,a2		; last '\'
.lb0:
	move.b (a0)+,d0
	move.b d0,(a1)+
	beq.s .lb2
	cmp.b #'\',d0
	bne.s .lb0
	move.l a1,a2
	bra.s .lb0
.lb2:
	move.l d1,a0
	move.l a2,d0			; return file ptr in name
.lb3:
	move.b (a0)+,(a2)+	; plus le nom
	bne.s .lb3
	lea -1(a2),a1			; update a1
	rts

ebat_sound_verif:
	moveq #-1,d0
	move.l d0,_delay
	st bad_sound
	move.l 50*24+12(a3),d1	; sound file
	lea ebat_path+2000,a0	; path
	lea sound_file,a1
	bsr.s full_pathname
	movem.l d1-d3/a0-a1,-(sp)
	bsr.l read_sound_header
	movem.l (sp)+,d1-d3/a0-a1
   tst d0
   beq.s .cant_read	; 0 if read error
   bgt.s .bad_format	; 1 if bad format
   bsr.l size_into_samples
   muls.l #200,d0
   divs.l frequency,d0		; temps en 1/200
   move.l d0,end_time
   moveq #-1,d0				; return NE if ok
   rts
.cant_read:
	moveq #20,d0	; alert can't open or read sound file
	bra.s .eco
.bad_format:
	moveq #3,d0		; alert unknown sound type
.eco:
	moveq #0,d1		; to return EQ
	rts

; a3 = tree
; a1 = batch text
; d3 = file type

save_dial_settings:
	lea .one(pc),a0
.lb0:
	move.b (a0)+,(a1)+
	bne.s .lb0
	subq.l #1,a1
	move.l ([fstring_adr],16*24+12),a4	; don't modify until
.lb0a:
	move.b (a4)+,(a1)+
	bne.s .lb0a
	subq.l #1,a1
.lb0b:
	move.b (a0)+,(a1)+
	bne.s .lb0b	
	subq.l #1,a1
	move d3,d0
	lsl #8,d0
	add.w #'0#',d0
	move d0,(a1)+			; file type
	move #$0d0a,(a1)+
	move.b #9,(a1)+
	lea ebat_path,a4
	lea 19*24+12(a3),a2
	moveq #4,d7
.lb3:
	move.l a4,a0
	bsr .add_str			; add path+#
	move.l (a2),a0			; first image
	bsr .add_str_ind
	move.l 48(a2),a0		; last image
	bsr .add_str_ind
	move #$0d0a,(a1)+
	move.b #9,(a1)+
	lea 400(a4),a4
	lea 5*24(a2),a2
	dbf d7,.lb3
	move.l a4,a0
	bsr .add_str			; sound path
	move.l 50*24+12(a3),a0
	bsr .add_str			; sound file
	move #$0d0a,(a1)+
	move.b #9,(a1)+
	lea ebat_out,a0
	bsr.s .add_str			; out path
	move.l 76*24+12(a3),a0
	bsr.s .add_str			; out file
	move #$0d0a,(a1)+
	move.b #9,(a1)+
	lea ebat_obj,a4	
.save_status:
	move (a4)+,d0
	beq.s .lb1	
	muls #24,d0
	move.b 11(a3,d0.l),d0	; state
	and.b #$0F,d0				; nibble
	lsl #8,d0
	add #'a#',d0
	move d0,(a1)+				; state + #	
	bra.s .save_status
.lb1:
	move.l 49*24+12(a3),a0
	bsr.s .add_str_ind			; time
	move.l 53*24+12(a3),a0
	bsr.s .add_str_ind			; keyframe
	move #$0d0a,(a1)+
	move.b #9,(a1)+
	moveq #20,d0
	GADDR d0
	lea 5*24+12(a0),a4		; 1st ted in VR tree
	moveq #4,d7
.lb2:
	move.l (a4),a0
	bsr.s .add_str_ind			; one value
	lea 24(a4),a4
	dbf d7,.lb2
	move.b -1(a4),d0			; status of "horizontal loop"
	and.b #$0F,d0
	lsl #8,d0
	add #'a#',d0
	move d0,(a1)+
	lea .two(pc),a0
.lb5:
	move.b (a0)+,(a1)+
	bne.s .lb5
	subq.l #1,a1
	rts	
.add_str_ind:
	move.l (a0),a0	
.add_str:
	move.b (a0)+,(a1)+	; copy string
	bne.s .add_str
	move.b #'#',-1(a1)	; end marker
	rts
.add_state:
	muls #24,d0
	move.b 11(a3,d0.l),d0	; state
	and.b #$0F,d0				; nibble
	lsl #8,d0
	add #'a#',d0
	move d0,(a1)+				; state + #
	rts
	
.one: dc.b "DIAL **** ",0
	dc.b " ENDD",13,10,9,0
.two: dc.b 13,10,"ENDD ****",13,10,0
	even
	
load_dial_settings:
	bsr define_bat
	beq .out
	clr -(sp)
	pea (a3)
	GEMDOS 61,8			; fopen 
	move d0,d3
	bmi .cant_load
	lea ebat_path_names+5*6,a5
	move.l a5,-(sp)
	move.l #65535,-(sp)	; whole file
	move d3,-(sp)
	GEMDOS 63,12		; read the whole bat
	tst.l d0
	bmi .cant_load
	clr.b (a5,d0.l)		; end of file marked with a 0
	move d3,-(sp)
	GEMDOS 62,4			; close
	move.l #$20202020,d7
	move.l (a5)+,d0
	or.l d7,d0
	cmp.l #'mpl',d0
	bne .not_bat
	move.l (a5)+,d0
	or.l d7,d0
	cmp.l #'ayer',d0
	bne .not_bat
.lb0:
	bsr.l bat_next_line
	beq .not_dial				; end_of_file?
	cmp.l #'DIAL',(a5)
	bne.s .lb0
	bsr.l bat_next_line		; new line
	beq .error_end				; end_of_file?
	moveq #19,d0
	GADDR d0
	move.l a0,a3			; tree
	move.b (a5)+,d0
	sub #'0',d0				; file type
	moveq #8,d7
	lea 14*24+11(a3),a0	; state of buttons
.set_type:
	bclr #0,(a0)		; default is not selected
	cmp.b d7,d0
	bne.s .lb1
	bset #0,(a0) 		; if save type, then selected !
.lb1:
	lea -24(a0),a0		; previous button
	dbf d7,.set_type
	moveq #4,d7
	lea ebat_path,a4
	lea 19*24+12(a3),a2	; first 'from' ted
.set_images:
	bsr.l bat_next_line
	beq .error_end				; end_of_file?
	move.l a4,a0
	bsr .load_str		; one path
	move.l (a2),a0
	bsr .load_str_ind	; one filename
	move.l 48(a2),a0
	bsr .load_str_ind	; second filename
	lea 400(a4),a4
	lea 5*24(a2),a2
	dbf d7,.set_images	
	bsr.l bat_next_line
	beq .error_end				; end_of_file?
	move.l a4,a0
	bsr .load_str		; sound path
	move.l 50*24+12(a3),a0
	bsr .load_str		; sound file
	bsr.l bat_next_line
	beq .error_end				; end_of_file?
	lea ebat_out,a0
	bsr.s .load_str		; out path
	move.l 76*24+12(a3),a0
	bsr.s .load_str		; out file
	bsr.l bat_next_line
	beq .error_end				; end_of_file?
	lea ebat_obj(pc),a2
.set_states:
	move (a2)+,d0
	beq.s .lb2
	muls #24,d0
	move.b 11(a3,d0.l),d1	; current state
	and.b #$F0,d1
	move.b (a5),d2				; saved state
	sub.b #'a',d2
	add.b d2,d1
	move.b d1,11(a3,d0.l)	; new state
	addq.l #2,a5				; state and #
	bra.s .set_states
.lb2:
	move.l 49*24+12(a3),a0
	bsr.s .load_str_ind		; time
	move.l 53*24+12(a3),a0
	bsr.s .load_str_ind		; keyf
	bsr.l bat_next_line
	beq.s .error_end				; end_of_file?
	moveq #20,d0
	GADDR d0
	lea 5*24+12(a0),a4	; first ted in VR
	moveq #4,d7
.set_vr:
	move.l (a4),a0
	bsr.s .load_str_ind
	lea 24(a4),a4
	dbf d7,.set_vr
	move.b -(a4),d1	; current state Horizontal loop
	and.b #$F0,d1
	move.b (a5),d2				; saved state
	sub.b #'a',d2
	add.b d2,d1
	move.b d1,(a4)	; new state	
.out:
	rts
.load_str_ind:
	move.l (a0),a0
.load_str:
	move.b (a5)+,d0
	beq.s .arg
	move.b d0,(a0)+
	cmp.b #'#',d0		; string ends with #
	bne.s .load_str
	clr.b -(a0)			; mark end of string
	rts	
.arg:
	subq.l #1,d5		; end of file? 0 found
	rts
.cant_load:
	moveq #21,d0		; alert can't read file
	bra.s .errcom
.not_bat:
	moveq #22,d0		; alert not a valid BAT (no header)
	bra.s .errcom
.not_dial:
	moveq #23,d0		; alert no DIAL section
	bra.s .errcom		
.error_end:
	moveq #33,d0		; alert unexpected end of file
.errcom:
	bsr.l alert
	rts

define_bat:
	lea fs_addrin_bat,a0
	bsr get_file
	beq.s .out				; cancel/error
	move.l #ebat_outfile,d1	; name
	lea ebat_outbat,a0		; path
	lea ebat_path+6*400,a3	; full path name
	move.l a3,a1
	bsr full_pathname
	moveq #-1,d0
.out:
	rts
	
save_bat:
	bsr.s define_bat
	beq.s .out
	clr -(sp)
	pea (a3)
	GEMDOS 60,8
	move d0,d7
	bmi.s .gloub
	lea ebat_path_names+5*6,a0	; start of file
	move.l end_time,d0			; end
	move.l a0,-(sp)
	sub.l a0,d0						; size to save
	move.l d0,-(sp)
	move d7,-(sp)
	GEMDOS 64,12
	tst.l d0
	bmi.s .gloub
	move d7,-(sp)
	GEMDOS 62,4	
	bra.s .out
.gloub:
	moveq #37,d0		; alert can't create file
	bsr.l alert	
.out:
	rts
ebat_outfile: dc.b "DEFAULT.BAT",0
	dcb.b 10,0
	
graf_rubberbox: dc.l grb_cont,global,grb_int,intout,dum,dum
grb_cont: dc.w 70,4,3,0,0
grb_int: dc.w 0,0,16,16


; d0 = FTEXT number
; out d0.l = number
; use d0-d1-a5

get_tedinfo:
	muls #24,d0
	move.l 12(a4,d0.l),a5
	move.l (a5),a5					; string
	bsr.l _number						; returns number in d0
	rts

; d1=FTEXT number
; d0.l=value
; out: number in ASCII or null string if d0=0
; use d0-d1-a0-a1

fill_tedinfo:
	muls #24,d1
	move.l 12(a4,d1.l),a1		; tedinfo
	move.l (a1),a1					; string
	clr.b (a1)						; null string
	tst.l d0
	beq.s .exit
	bsr.l int_to_str
.exit:
	rts
	
get_rectangle:
	movem.l d0-d7/a0-a6,-(sp)
	moveq #16,d0
	GADDR d0
	move.l a0,a4					; tree !
	tst.b menu_flag				; if from BAT file, fill frames/delays
	bpl.s .again					; else don't modify dialog
	move.l sample_num,d0
	moveq #9,d1
	bsr.s fill_tedinfo			; frames
	move.l grab_delay,d2
	move.l d2,d0
	moveq #10,d1
	bsr.s fill_tedinfo			; grab delay
	bclr #0,12*24+11(a4)			; use same unselected by default
	move.l _delay,d0
	cmp.l d0,d2
	bne.s .lb4
	bset #0,12*24+11(a4)			; set use same
	moveq #0,d0
.lb4:
	moveq #11,d1
	bsr.s fill_tedinfo			; replay delay
.again_change:
	move.l 13*24+12(a4),a1		; chaine pour nom du fichier
	bsr nom_du_fichier			; efface a4-a3 !!
.again:
	clr mf_int
	GEM_AES graf_mouse			; the arrow
	moveq #0,d7
	moveq #16,d6
	bsr.l manage_tree
	cmp #13,d6						; file name ??
	bne.s .lb6
	bsr get_output_file
	beq.s .again					; cancelled
	move.l tree,a4
	bra.s .again_change
.lb6:
	cmp #6,d6
	beq.s .everything_ok			; abandon, don't verify
	moveq #16,d0
	GADDR d0
	move.l a0,a4					; tree
	moveq #9,d0
	bsr get_tedinfo				; get frames number
	move.l d0,sample_num
	beq.s .not_enough_values	; if 0, alert and again
	moveq #10,d0
	bsr get_tedinfo
	move.l d0,d2					; get grab_delay
	moveq #11,d0
	bsr get_tedinfo				; get replay_delay
	btst #0,12*24+11(a4)			; use same ?
	beq.s .notsame
	move.l d2,d0					; use grab for replay
.notsame:
	move.l d0,_delay
	beq.s .not_enough_values
	move.l d2,grab_delay
	beq.s .not_enough_values
	move.l 13*24+12(a4),a1		; chaine pour nom du fichier		
	tst.b (a1)						; au moins un caractŠre?
	bne.s .everything_ok
.not_enough_values:
	moveq #32,d0					; alert fill param before rectangle
	bsr.l alert
	bra .again	
.everything_ok:	
	btst #0,7*24+11(a0)			; state de Use Alt Help
	sne use_alt_help
	btst #0,8*24+11(a0)			; state of Auto Capture
	sne auto_capture_first
	moveq #0,d2
	moveq #0,d3
	cmp #6,d6			; abandon
	seq cancelled
	beq .ok
	cmp #4,d6			; Whole screen ?
	bne.s .lb0
	lea work_out,a0
	move (a0)+,d2
	move (a0),d3
	addq #1,d2
	addq #1,d3
	bra .ok
.lb0:						; here define rectangle
	move #6,mf_int
	GEM_AES graf_mouse			; the cross
	clr fd_int
	GEM_AES form_dial    ; reserves screen	
	move #1,wu_int
	GEM_AES wind_update	; mouse for me	
	move #3,wu_int
	GEM_AES wind_update	; mouse for me
	GEM_VDI show_mouse
.lb2:
	GEM_AES graf_mkstate
	lea intout+6,a0
	tst (a0)+
	bne.s .lb3				; one mouse button !
	move (a0),d0
	btst #2,d0				; control key?
	beq.s .lb2	
	move #2,wu_int
	GEM_AES wind_update	; mouse for all
	move #3,fd_int
	GEM_AES form_dial
	bra .again			; then redisplay tree
.lb3:
	lea intout+2,a3
	move.l (a3),grb_int
	move (a3),d2
	swap d2			; start x
	move 2(a3),d3
	swap d3			; start y
.lb1:
	GEM_AES graf_rubberbox
	move (a3),d2	; width
	move 2(a3),d3	; height
	GEM_AES graf_mkstate
	lea intout+6,a0
	tst (a0)+
	bne.s .lb1				; one mouse button !	
	move #2,wu_int
	GEM_AES wind_update	; mouse free
	move #0,wu_int
	GEM_AES wind_update	; mouse for me	
	move #3,fd_int
	GEM_AES form_dial		; screen free
.ok:
;	add #15,d2
	moveq #0,d1
	move planes_vdi,d1
	and #$FFF0,d2		; 16 rounded
	cmp #16,d1
	bpl.s .no_limit
	cmp #2032,d2		; for rle8, limit to 2040 pixels to ease XIMG simul
	bmi.s .no_limit
	move #2032,d2
.no_limit:
	and #$FFFC,d3		; 4 rounded
	move d2,max_imagex
	move d3,max_imagey
	move d2,d0
	muls d3,d0			; number of pixels !
	cmp #16,d1
	bpl.s .tga
	moveq #0,d4
	move d3,d4
	lsl.l #4,d4			; lines *16 bytes for ximg codes
	add.l #2048,d4		; enough for 1558 header + security
	add.l d0,d4			; buffer size
	lsr.l #3,d0
	mulu.l d1,d0		; buffer size for vro_cpyfm
	exg.l d0,d4			; d0=max_fsize
	sub.l d0,d4
	neg.l d4				; offset in buffer to copy screen	
	sub.l #1558,d4
	move.l d4,offset_ximg
	bra.s .common	
.tga:
	lsr.l #3,d0
	mulu.l d1,d0		; buffer size for vro_cpyfm
	add.l #18,d0		; + tga header !!
.common:
	move.l d0,max_fsize
	lea mfdb_dest+4,a0
	move d2,(a0)+
	move d3,(a0)+
	lsr #4,d2
	move d2,(a0)+
	lsl #4,d2
	move.l d1,(a0)		; 0 + planes
	subq #1,d2
	subq #1,d3
	lea vcp_ptsin+16,a0
	move d3,-(a0)
	move d2,-(a0)
	clr.l -(a0)			; 0,0,w-1,h-1 for dest rectangle	
	lea gsb_int+16,a1	; for graf_shrinkbox
	move d3,d1			; d1=h-1
	move d2,d0			; d0=w-1
	swap d3
	swap d2
	add d3,d1			; d1=mousey + h-1 = y2
	add d2,d0			; d0=mousex + w-1 = x2
	move d1,-(a0)
	move d0,-(a0)
	move d3,-(a0)
	move d2,-(a0)		; x,y,x2,y2 source rect
	move d3,d1
	move d2,d0
	swap d3
	swap d2
	addq #1,d2
	addq #1,d3
	move d3,-(a1)		; h
	move d2,-(a1)		; w
	move d1,-(a1)		; x
	move d0,-(a1)		; y for graf_shrinkbox
	lsr #1,d3
	lsr #1,d2			; half size
	subq #8,d3
	bpl.s .lb5
	moveq #0,d3
.lb5:
	subq #8,d2			; d2=16 mini
	move.l #$00100010,-(a1)	; w=16, h=16
	add d3,d1
	move d1,-(a1)
	add d2,d0
	move d2,-(a1)	
	move #3,-(a0)		; mode 3 dans vcp_int
	clr mf_int
	GEM_AES graf_mouse			; the arrow
	movem.l (sp)+,d0-d7/a0-a6
	or.l #$70007,d6			; add o=, t=, f=, w=, h=, b= data
	rts

get_output_file:
	tst.b menu_flag
	bpl.s .ok			; not from a BAT file
	lea out_path,a0	; else copy out_file to path + name
	lea out_file,a1
.p0:
	move.b (a1)+,d0
	move.b d0,(a0)+
	beq.s .p2
	cmp.b #'\',d0
	bne.s .p0
	move.l a1,a2 
	bra.s .p0
.p2:
	lea out_name,a1
.p1:
	subq.l #1,a0			; reduit out_path
	move.b (a2)+,(a1)+	; copie le nom
	bne.s .p1
	clr.b (a0)				; fin du path
.ok:
	lea fs_addrin_grab,a0
	bsr get_file
	beq.s .cancel							; 0 if abort/quit
.lb5:
	lea out_path,a0
	lea out_file,a1
	move.l #out_name,d1
	bsr full_pathname
	moveq #1,d0			; return NE if changed
.cancel:					; else return EQ if don't change
	rts

; wait for Alt+Help
; vro_cpyfm screen to buffer
; adapt buffer to an XIMG image (1-8 planes)
; or to TGA 16 bits (16 planes)
; or TGA 24 bits (24-32 planes)

screen_to_image:
	bsr wait_for_grab
	movem.l bat_timing,d0-d1	
	trap #9
	clr.l mfdb_src		; source is screen
	move.l buffer,a0
	lea intout,a1
	cmp #16,planes_vdi
	bpl.s .to_tga
	move.l #$0001030B,(a0)+	; version and header size
	move.l #$00080000,(a0)+	; planes and pattern (unused)
	move.l #$01d401d4,(a0)+	; pixels in microns
	move max_imagex,(a0)+	; w
	move max_imagey,(a0)+	; h
	move.l #'XIMG',(a0)+		; palette extension
	clr (a0)+					; palette mode 0 = RGB
	bsr set_ximg_palette
	add.l offset_ximg,a0
	bra.s .lb4			; to copy!	
.to_tga:
	move.l #$00000200,(a0)+
	clr.l (a0)+
	clr.l (a0)+
	move.l max_imagex,d0
	swap d0
	ror #8,d0
	move d0,(a0)+		; W
	swap d0
	ror #8,d0
	move d0,(a0)+		; H
	cmp #24,planes_vdi	; 24/32 bits ->  TGA 24 bits?
	bpl.s .lb3
	move #$1020,(a0)+	; else TGA 16 bits
	bra.s .lb4
.lb3:
	move #$1820,(a0)+	; 24 bits
.lb4:
	tst (a1)+
	bmi.s .lb5
	tst.b (a1)
	bne.s .lb5
	move #$0100,-4(a0)
.lb5:		
	move.l a0,mfdb_dest	; destination is buffer
	GEM_VDI vro_cpyfm	
	GEM_AES graf_shrinkbox
	move.l mfdb_dest,a0	; buffer
	move.l vdi_compression,a1
	move.l 10(a1),a1		; grab conversion routine
	moveq.l #-18,d0
	add.l max_fsize,d0	; size of data
	jmp (a1)

; according to method:
; (even with Auto capture for first frame)
; wait for alt+help through $502 vector (print screen)
; or display a dialog and wait for clic
;
; then if Auto capture and next frames, use grab_delay

wait_for_grab:
	tst.b auto_capture_next
	bne .delay_method
	bsr.l ring_a_bell		; bell to say "OK, ready"
	sf alt_help
	pea init_althelp(pc)	; put my vector in $502
	XBIOS 38,6
	tst.b use_alt_help
	beq.s .aes_method
.lb0:
	tst.b alt_help			; my vector sets this flag when Alt+HELP keyed
	bne.s .lb1
	moveq #100,d0		; 1/10 sec
	bsr wdial_evnt		; else wait a bit and let applications work
	bra.s .lb0
.lb1:
	tst.b auto_capture_first
	beq.s .exit
	trap #10
	move.l d0,grab_time
	st auto_capture_next
.exit:
	btst #1,([kbshift])
	sne intout+2
	rts
.aes_method:
	movem.l d2-d7/a2-a6,-(sp)
	moveq #0,d7
	moveq #17,d6
	bsr.l manage_tree			; display "Delay:___" and "capture next frame"
	moveq #17,d0
	GADDR d0
	move.l 2*24+12(a0),a0	; tedinfo
	move.l (a0),a0				; delay string
	moveq #0,d6
	moveq #0,d1
.lb2:
	move.b (a0)+,d1
	beq.s .lb3
	muls #10,d6
	sub #'0',d1
	add d1,d6
	bra.s .lb2
.lb3:
	muls #1000,d6			; delay in milli sec
	add.l #200,d6			; mini 0,2 sec to rebuild screen
.lb4:
	move.l d6,d0	
	bsr wdial_evnt		; wait and grab!
	bpl.s .lb4				; until "-1" = event timer
	movem.l (sp)+,d2-d7/a2-a6
	bra.s .lb1
.delay_method:
	move.l grab_time,d0
	add.l grab_delay,d0
	move.l d0,grab_time
.lb5:
	trap #10
	cmp.l grab_time,d0
	bpl.s .exit
	moveq #20,d0			; minimum for waiting
	bsr wdial_evnt		; else wait a bit and let applications work
	bra.s .lb5
	
my_alt_help:
	st alt_help
	move.l old_screen_dump,$502.w
	rts
		
init_althelp:
	bsr.l bat_timing-16
	tst.b use_alt_help
	beq.s .lb0
	move.l $502.w,old_screen_dump
	move.l #my_alt_help,$502.w
	move #-1,$4ee.w
.lb0:
	rts
	
set_ximg_palette:
	tst (a1)+
	bmi.s .lb4
	tst.b (a1)
	bne.s .lb4
	move #1,-8(a0)
.lb4:
	tst.b bat_getp
	bne.s .get_pal
	add.l #6*256,a0	; fake palette, jump over !
	rts
.get_pal:
	movem.l d3-d4/a3-a4,-(sp)
	move.l a0,a3
	lea indexs,a4
	moveq #1,d3
	move #254,d4
	move planes_vdi,d0
	cmp #1,d0
	beq.s .lb0
	moveq #3,d3
	subq #2,d4
	cmp #2,d0
	beq.s .lb0
	moveq #15,d3
	move #240,d4
	cmp #4,d0
	beq.s .lb0
	move #255,d3
	moveq #0,d4
.lb0:
	move (a4)+,d0
	tst d3
	bne.s .lb3
	moveq #1,d0
.lb3:
	move d0,vq_int			; from index except last one = 1
	GEM_VDI vq_color
	lea intout+2,a0
	move.l (a0)+,(a3)+	; red+green
	move.w (a0),(a3)+		; blue
	addq #1,vq_int
	dbf d3,.lb0
	moveq #0,d3
	bra.s .lb2
.lb1:
	move.l d3,(a3)+
	move d3,(a3)+	
.lb2:
	dbf d4,.lb1
	move.l a3,a0			; palette end
	movem.l (sp)+,d3-d4/a3-a4
	rts

grab_planes:
;	move.l mfdb_dest,a0	; address of planes/chunk A0
	movem.l d2-d5/a2,-(sp)
	move.l buffer,a1
	lea 1558(a1),a1	; jump over header+palette
	lea mfdb_dest,a2
	move 6(a2),d5
	subq #1,d5			; for loop on number of lines
	move 8(a2),d2		; number of blocs of 16
	move d2,d3
	move d3,d0
	lsl #8,d3
	move.b d0,d3
	move d3,d0
	swap d3
	move d0,d3			; d3= 4 times the code for empty lines
	move d2,d4
	add d2,d2			; bytes per plane
	bset #15,d2			; $80nn to encode one full line
	move planes_vdi,d0
	cmp #1,d0
	beq.s mono_to_ximg
	cmp #2,d0
	beq.s col4_to_ximg
	cmp #4,d0
	beq col16_to_ximg

col256_to_ximg:
	tst.b nova
	beq.s .planes_ready
	movem.l d0-d7/a3,-(sp)
	move.l a0,a3
	addq #1,d5			; number of lines
	muls d4,d5			; blocs of 16 pixels
	bsr byte_to_8_planes
	movem.l (sp)+,d0-d7/a3
.planes_ready:
	moveq #7,d3				; for 8 planes
.one_line:
	move d2,(a1)+			; one full line
	move.l a0,a2
	move d4,d0
	bra.s .lb1
.lb0:
	move (a2),(a1)+
	lea 16(a2),a2
.lb1:
	dbf d0,.lb0
	addq.l #2,a0
	dbf d3,.one_line
	lea -14(a2),a0
	dbf d5,.planes_ready
	
grab_planes_end:
	movem.l (sp)+,d2-d5/a2
	rts

mono_to_ximg:
	move d2,(a1)+			; one full line
	move d4,d0
	bra.s .lb1
.lb0:
	move (a0)+,(a1)+
.lb1:
	dbf d0,.lb0
	move.l d3,(a1)+		; two empty planes
	move.l d3,(a1)+		; four empty planes
	move.l d3,(a1)+		; six empty planes
	move d3,(a1)+			; seven
	dbf d5,mono_to_ximg
	bra.s grab_planes_end
	
col4_to_ximg:
	moveq #1,d1				; for 2 planes
.one_line:
	move d2,(a1)+			; one full line
	move.l a0,a2
	move d4,d0
	bra.s .lb1
.lb0:
	move (a2),(a1)+
	addq.l #4,a2
.lb1:
	dbf d0,.lb0
	addq.l #2,a0
	dbf d1,.one_line
	lea -2(a2),a0
	move.l d3,(a1)+		; two empty planes
	move.l d3,(a1)+		; four empty planes
	move.l d3,(a1)+		; six empty planes
	dbf d5,col4_to_ximg
	bra.s grab_planes_end
	
col16_to_ximg:
	moveq #3,d1				; for 4 planes
.one_line:
	move d2,(a1)+			; one full line
	move.l a0,a2
	move d4,d0
	bra.s .lb1
.lb0:
	move (a2),(a1)+
	addq.l #8,a2
.lb1:
	dbf d0,.lb0
	addq.l #2,a0
	dbf d1,.one_line
	lea -6(a2),a0
	move.l d3,(a1)+		; two empty planes
	move.l d3,(a1)+		; four empty planes
	dbf d5,col16_to_ximg
	bra.s grab_planes_end
	
grab_32I:
	rts					; nothing to do, 32k intel is the TGA format!

grab_32M:				; 32k motorola, just ror words
	move.l (a0),d1
	ror #8,d1
	swap d1
	ror #8,d1
	swap d1
	move.l d1,(a0)+
	subq.l #4,d0
	bne.s grab_32M
	rts
	
grab_65M:				; falcon to TGA 16
	move (a0),d1
	NOVA16 d1
	ror #8,d1
	move d1,(a0)+
	subq.l #2,d0
	bne.s grab_65M
	rts
	
grab_65I:				; 16 bits Intel to 15 bits Intel
	move (a0),d1
	ror #8,d1
	NOVA16 d1
	ror #8,d1
	move d1,(a0)+
	subq.l #2,d0
	bne.s grab_65I
	rts
		
grab_24BVR:				; nothing to do, BVR is the TGA format
	rts
	
grab_24RVB:
	move.b (a0),d1		; R
	move.b 2(a0),(a0)	; B first
	move.b d1,2(a0)	; R last
	subq.l #3,d0
	bne.s grab_24RVB
	rts

grab_32xBVR:
	lea 1(a0),a1	
	bra.s *+4				; (vers .lb0)
grab_32BVRx:
	move.l a0,a1
.lb0:
	move.b (a1)+,(a0)+	; B
	move.b (a1)+,(a0)+	; V
	move.b (a1)+,(a0)+	; R
	addq.l #1,a1
	subq.l #4,d0
	bne.s .lb0
	rts

grab_32xRVB:
	lea 1(a0),a1
	bra.s *+4
grab_32RVBx:
	move.l a0,a1
.lb0:
	move.b (a1)+,d1		; save R
	move.b 1(a1),(a0)+	; B
	move.b (a1)+,(a0)+	; V
	move.b d1,(a0)+		; R
	addq.l #2,a1
	subq.l #4,d0
	bne.s .lb0
	rts	

; get free string table (ALERTS)
; and get pointers into some alerts
; that contain variable fields

alert_table:
	move.l #$000F0000,d0
	move.l d0,rg_int
	GEM_AES rsrc_gaddr
	move.l tree,a0		; the alert table of free strings!
	move.l a0,alert_adr
	lea .search(pc),a1
	lea alert_ptr,a2
.again:
	moveq #0,d0
	move.b (a1)+,d0	; string id
	beq.s .end
	move.l 0(a0,d0.l*4),a3	; string adr
.next_byte:
	move.b (a1)+,d0	; byte to find
	beq.s .again		; if zero, next string
	move.l a3,a4		; start of string
.parse:
	cmp.b #'#',(a4)+	; search for # marker
	bne.s .parse
	cmp.b (a4),d0		; if found, is it my byte?
	bne.s .parse
	cmp.b #'0',d0		; if a zero...
	beq.s .lb0			; ... then correct position!
	subq.l #1,a4		; ... else # was the start
.lb0:
	move.l a4,(a2)+	; one more pointer
	bra.s .next_byte
.end:
	rts
.search:
	dc.b 13,'0',0
	dc.b 14,'0',0
	dc.b 15,'0','X',0
	dc.b 16,'0','X',0
	dc.b 17,'0','X',0
	dc.b 18,'0','X','F','R',0
	dc.b 41,'-',0
	dc.b 38,'=','-',0
	dc.b 34,'=',0
	dc.b 0
	even
	
free_strings:
	lea fstring_adr,a3
	move.l #STRING_TREE,d4
	moveq #2,d3
.lb0:
	move.l d4,rg_int
	GEM_AES rsrc_gaddr	; fill free_strings, fsel30_adr, infbox24_adr
	move.l tree,(a3)+
	addq.l #1,d4		; next tree
	dbf d3,.lb0
	move.l -8(a3),a0		; fsel30_adr
	lea .addrin_fill(pc),a1
	lea fs_addrin+8,a2
.lb2:
	moveq #0,d0
	move.b (a1)+,d0
	beq.s .lb1				; end of table
	muls #24,d0
	move.l 12(a0,d0.l),(a2)+	; one fsel title
	add.l #8,a2				; next addrin
	bra.s .lb2
.lb1:	
	rts
.addrin_fill:	dc.b 8,9,5,10,2,6,7,0
	even

; a0 = full path name
; exit: MI if bug
; else A3 = buffer addre + 8 extra bytes
; d6=file size

load_one_file:
	clr -(sp)
	pea (a0)					; tries to open the file
	GEMDOS 61,8				; fopen
	move d0,d7				; handle of the file is saved
	bmi.s .bug
	move #2,-(sp)
	move d7,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; fseek to end
	move.l d0,d1			; total size
	addq.l #8,d1			; one dummy value
	move.l d0,d6
	bsr.l malloc
	move.l d0,a3			; buffer address
	clr -(sp)
	move d7,-(sp)
	clr.l -(sp)
	GEMDOS 66,10			; fseek to the beginning
	move.l a3,-(sp)
	move.l d6,-(sp)
	move d7,-(sp)
	GEMDOS 63,12			; reads the whole file
	move d7,-(sp)
	GEMDOS 62,4				; closes the file
	moveq #0,d0				; not MI
.bug:
	rts

test_enhanced:
	move.l _dialogue+8,a0	; chaine du fichier en cours
	lea DVI_DELTA,a1			; temporaire pour nom du *.ENH
	move.l a1,d2
	moveq #0,d1
.again:
	move.b (a0)+,d0
	move.b d0,(a1)+
	beq.s .fin
	cmp.b #':',d0
	beq.s .found
	cmp.b #'\',d0
	beq.s .found
	cmp.b #'.',d0
	bne.s .again
.found:
	move.b d0,d1		; save char
	move.l a1,a2		; save pos+1
	bra.s .again
.fin:
	subq.l #1,a1		; back on the last '0'
	cmp.b #'.',d1
	bne.s .add_ext
	lea -1(a2),a1		; is '.' is last, then change extension
.add_ext:
	move.l #'.ENH',(a1)+
	clr.b (a1)
	move.l d2,a0		; DVI_DELTA file name
	bsr load_one_file
	bmi .bug				; pas de fichier trouv‚
	move.l a3,enh_buffer
	move.l a3,enh_ptr0			; defaut pointer on 1st version
	move.l #$0d0a0000,0(a3,d6.l)		; end of line + zero
	move.l a3,a0
	move.l (a0)+,d0
	or.l #$20202020,d0
	cmp.l #'enha',d0
	bne .bug_head			; not correct header
	move.l (a0)+,d0
	or.l #$20202020,d0
	cmp.l #'nced',d0
	bne .bug_head			; idem
	move.l a0,a5
	move #1,enh_lines	; default is one line
	move #13,enh_size	; default 16 points
.read_header:
	bsr.l bat_next_line
	beq .bug_head			; unexpected end of file
	move (a5)+,d0
	or.w #$2000,d0
	cmp.w #'l=',d0			; number of lines?
	bne.s .lb0
	bsr.l get_number
	move d0,enh_lines
	bra.s .read_header	
.lb0:
	cmp.w #'s=',d0			; font size?
	bne.s .lb1
	move d0,([alert_ptr+52])
	lea .h_table(pc),a1
	move.b (a5)+,d0
	bsr .cherche
	beq .bug_param					; bad size
	move.l d0,enh_size-2		; store size!
	bra.s .read_header
.lb1:
	cmp.w #'v=',d0			; start of one version
	bne .bug_unknown			; unknown command
	move.l enh_ptr0,a0	; start of compilation overwriting ENH file
	bra.s .first_version
.read_versions:
	bsr.l bat_next_line
	beq .end
	cmp.b #'0',d0
	bmi.s .a_command
	cmp.b #'9'+1,d0
	bpl.s .a_command
	bsr.l get_number		; if not a command, then a time
	add.l d0,d0			; 1/100 into 1/200
	bset #31,d0			; mark time
	move.l d0,(a0)+ 	; store as long
	bra.s .read_versions
.a_command:
	move.w (a5)+,d0
	move d0,([alert_ptr+52])	; command name in alert string 38
	or.w #$2000,d0
	cmp.b #'=',d0
	beq.s .lb2
	or.b #$20,d0
.lb2:
	cmp #'v=',d0
	bne.s .lb3
	moveq #-1,d0
	move.l d0,(a0)+		; time marker, in case of previous version
	clr.w (a0)+				; with null code = end of file for previous
.first_version:
	bsr.l get_number
	lea langue,a1
	cmp.b (a1)+,d0
	beq.s .langue_ok
	cmp.b (a1),d0
	bne.s .read_versions
.langue_ok:
	move.l a0,enh_ptr0		; replace pointer with the one found
	bra.s .read_versions		
.lb3:
	cmp #'cl',d0
	bne.s .lb4
	move #$0100,(a0)+		; clear code
	bra.s .read_versions
.lb4:
	cmp #'be',d0
	bne.s .lb5
	move #$0200,(a0)+		; bell sound code
	bra.s .read_versions
.lb5:
	cmp #'pa',d0
	bne.s .lb6
	move #$0300,(a0)+		; pause code
	bra .read_versions
.lb6:
	cmp #'d=',d0
	bne.s .lb9
	move #$0400,(a0)+	; display code
	move.l a0,a1		; keep this place
.lb7:
	move.b (a5)+,d0	; one character
	cmp.b #32,d0		; less than space? so 0 (EOF or CR/LF EOL)
	bmi.s .lb8
	move.b d0,(a0)+	; else add character
	bra.s .lb7
.lb8:
	subq.l #1,a5
	clr.b (a0)+			; end of string
	move.l a0,d1
	sub.l a1,d1			; string size
	move.b d1,-(a1)	; store size
	move.l a0,d1
	addq.l #1,d1
	bclr #0,d1			; a0 = even
	move.l d1,a0
	bra .read_versions
.lb9:
	cmp #'a=',d0
	bne.s .lb10
	lea .a_table(pc),a1	; attributes!
	move.b (a5)+,d0
	bsr .cherche	
	beq .bug_param					; bad attribute
	add.w #$0500,d0	
	move d0,(a0)+
	bra .read_versions	
.lb10:
	cmp #'e=',d0
	bne .bug_unknown			; bad command
	move #$0600,d2		; effects
.next_effect:
	move.b (a5)+,d0
	cmp.b #33,d0
	bmi.s .lb11
	lea .e_table(pc),a1
	bsr .cherche
	beq .bug_param					; bad attribute
	or d0,d2
	bra.s .next_effect
.lb11:
	subq.l #1,a5
	move d2,(a0)+
	bra .read_versions
.end:
	moveq #-1,d0
	move.l d0,(a0)+		; time marker
	clr.w (a0)+				; with null code = end of file !		
	clr va_int				; alignement gauche
	GEM_VDI vst_alignment	; haut/gauche par d‚faut
	clr vte_int
	GEM_VDI vst_effects		; pas d'effet de texte
	GEM_VDI vst_height		; ma hauteur demand‚e
	move enh_cell,d0
	muls enh_lines,d0
	move d0,enh_extra		; height of enhanced zone to be added to video rectangle
	st enh_flag			; all ok !
	rts
.bug_head:
	moveq #29,d0		; bad header
	bra.s .box
.bug_unknown:
	move d0,([alert_ptr+60])
	moveq #34,d0		; bad command
	bra.s .box
.bug_param:
	lsl #8,d0			; parameter
	move.b #32,d0		; + space
	move d0,([alert_ptr+56])	; bad param
	moveq #38,d0
.box:
	bsr.l alert
.bug:
	move.l #default_enhanced,enh_ptr0
	sf enh_flag
	rts
.cherche:
	cmp.b #'A',d0
	bmi.s .ch1
	cmp.b #'Z'+1,d0
	bpl.s .ch1
	or.b #$20,d0
.ch1:
	move.b (a1)+,d1
	beq.s .ch5		; return EQ if not found
	cmp.b d1,d0
	beq.s .ch2
	addq.l #1,a1
	bra.s .ch1
.ch2:
	moveq #0,d0
	move.b (a1),d0
	moveq #1,d1		; return NE if Ok
.ch5:
	rts
.h_table: dc.b '0',4,'1',6,'2',13,'3',26,0,0		; 4 tailles (0,1,2,3) en points
.a_table: dc.b 'l',0,'c',1,'r',2,0,0				; alignements gauche/centre/droit
.e_table: dc.b 'n',0,'b',1,'l',2,'i',4,'u',8,'o',16,'s',32,0,0; effets de texte

default_enhanced:
	dc.l -1		; time = -1
	dc.w 0		; no command

vst_alignment: dc.l .va_cont,va_int,dum,dum,dum
.va_cont: dc.w 39,0,0,2,0,0,0
va_int: dc.w 0,5			; alignement en haut … gauche des cellules

vst_effects: dc.l .ve_cont,vte_int,dum,dum,dum
.ve_cont: dc.w 106,0,0,1,0,0,0
vte_int: dc.w 0

vst_height: dc.l .vh_cont,dum,vh_pts,dum,vh_pts
.vh_cont: dc.w 12,1,0,0,0,0,0

enh_event0:
	move.l enh_ptr0,enh_ptr		; first call, init current pointer
enh_event:
	movem.l d0-d2/a0-a3,-(sp)
	move vgt_pts+2,-(sp)			; y pour 1 ere ligne
	move.l enh_ptr,a3
.loop:
	move (a3)+,d0
	bpl.s .command
	swap d0
	move (a3)+,d0
	cmp.l #-1,d0		; special time?
	bne.s .normal_time
.special_time:
	trap #10					; if -1, then end of ENH, so...
	add.l #3600*200,d0	; time + 1h 
	move.l d0,enh_time	; won't be back here before 1 hour
	subq.l #4,a3			; don't change pointer
	bra .exit
.normal_time:
	bclr #31,d0				; remove time marker
	add.l start_time,d0
	move.l d0,enh_time	; new time event
	bra .exit
.command:
	ror #8,d0				; upper byte!
	cmp.b #1,d0
	bne.s .lb0
	GEM_VDI vr_recfl		; 01 = clear!
	bra.s .loop
.lb0:
	cmp.b #2,d0
	bne.s .lb1
	bsr.l ring_a_bell		; 02 = bell
	bra.s .loop
.lb1:
	cmp.b #3,d0
	bne.s .lb2
	bra.s .loop				; 03 = pause		
.lb2:
	cmp.b #4,d0				; 04 = display?
	bne.s .lb5
	lsr #8,d0				; string size
	move.l a3,d2
	add.w d0,d2
	subq #1,d0
	move d0,vgt_cont+6	; size dans control
	addq.l #1,d2
	bclr #0,d2				; d2 = next a3 address
	lea DVI_DELTA,a0
.copy_string:
	move.l (a3)+,d1
	movep.l d1,1(a0)
	addq.l #8,a0
	cmp.l d2,a3
	bmi.s .copy_string
	move.l d2,a3
	GEM_VDI v_gtext
	move enh_cell,d0
	add d0,vgt_pts+2		; next line if future "d="
	bra .loop			
.lb5:
	cmp.b #5,d0
	bne.s .lb6
	lea vrf_pts,a0
	move (a0),d1			; left
	move 4(a0),d2			; right
	lsr #8,d0				; alignement 0,1,2
	move d0,va_int
	beq.s .aok1
	exg.l d1,d2
	cmp #2,d0
	beq.s .aok1			
	add d2,d1
	lsr #1,d1
.aok1:
	move d1,vgt_pts		; correct "x" according to alignment
	GEM_VDI vst_alignment
	bra .loop
.lb6:
	cmp.b #6,d0
	bne.s .lb7
	lsr #8,d0				; effets!
	move d0,vte_int
	GEM_VDI vst_effects
	bra .loop	
.lb7:
	move.l #default_enhanced,a3
	bra .loop				; bad command, go back to no action
.exit:
	move.l a3,enh_ptr
	move (sp)+,vgt_pts+2			; restore y 1ere ligne
	movem.l (sp)+,d0-d2/a0-a3
	rts


TM: dc.w -3				; monochrome, buffer w*h>>3	EX TT standard
	 dc.l vdi_mono		; bitblt mono to screen
	 dc.w 0				; don't change is_65k
	 dc.b "TM"
	 dc.l grab_planes
T8: dc.w 2				; rrrrrvvvvvvbbbbb 2nd buffer = 2*w*h EX CTPCI Radeon
	 dc.l vdi_32to65M	; routine									  EX Falcon
	 dc.w -1				; is_65k = true
	 dc.b "T8"
	 dc.l grab_65M
T9: dc.w 2				; vvvbbbbbrrrrrvvv 2nd buffer = 2*w*h	EX NOVA 65k
	 dc.l vdi_32to65	; routine
	 dc.w 1				; is_65k = true
	 dc.b "T9"
	 dc.l grab_65I
TA: dc.w 0				; vvvbbbbbxrrrrrvv 2nd buffer useless EX TT Nova 32k
	 dc.l vdi_direct16; routine
	 dc.w 0				; is_65k = false
	 dc.b "TA"
	 dc.l grab_32I
TG: dc.w 2				; xrrrrrvvvvvbbbbb 2nd buffer = 2*w*h
	 dc.l vdi_swap16	; routine
	 dc.w 0				; is_65k = false
	 dc.b "TG"
	 dc.l grab_32M
TB: dc.w 3				; RVB  2nd buffer = 3*w*h
	 dc.l vdi_rvb
	 dc.b 0,0			; jump x byte = no, jump at start = no
	 dc.b "TB"
	 dc.l grab_24RVB
TC: dc.w 3				; BVR  2nd buffer = 3*w*h
	 dc.l vdi_bvr
	 dc.b 0,0			; jump x byte = no, jump at start = no
	 dc.b "TC"
	 dc.l grab_24BVR
TD: dc.w 4				; xRVB 2nd buffer = 4*w*h
	 dc.l vdi_rvb
	 dc.b 1,1			; jump x byte = yes, jump at start = yes
	 dc.b "TD"
	 dc.l grab_32xRVB
TE: dc.w 4				; BVRx 2nd buffer = 4*w*h
	 dc.l vdi_bvr
	 dc.b 1,0			; jump x byte = yes, jump at start = no
	 dc.b "TE"
	 dc.l grab_32BVRx
TH: dc.w 4				; xBVR 2nd buffer = 4*w*h
	 dc.l vdi_bvr
	 dc.b 1,1			; jump x byte = yes, jump at start = yes
	 dc.b "TH"
	 dc.l grab_32xBVR
TI: dc.w 4				; RVBx 2nd buffer = 4*w*h
	 dc.l vdi_rvb
	 dc.b 1,0			; jump x byte = yes, jump at start = no
	 dc.b "TI"
	 dc.l grab_32RVBx

	even

vsm_color: dc.l vm_cont,vm_int,dum,dum,dum
vm_cont: dc.w 20,0,0,1,0,0,0,0,0,0,0,0
vm_int: dc.w 0

v_pmarker: dc.l vp_cont,dum,vp_int,dum,dum
vp_cont: dc.w 7,8,0,0,0,0,0,0,0,0,0,0

vp_int_sav: dc.w 0,0,4,0,8,0,12,0,0,1,4,1,8,1,12,1
cp_ptsin_sav: dc.w 0,0,15,1,0,0,15,1
my_mfdb_sav: dc.l bloc
				dc.w 16,2,1,0

vrt_cpyfm: dc.l cpt_cont,cpt_int,cp_ptsin,dum,dum
cpt_cont: dc.w 121,4,0,3,0,0,0
	dc.l my_mfdb,mfdb_screen
cpt_int: dc.w 1,0,1
vro_cpyfm2: dc.l cp_cont,cp_int,cp_ptsin,dum,dum
cp_cont: dc.w 109,4,0,1,0,0,0
	dc.l my_mfdb,mfdb_screen
cp_int: dc.w 3
mfdb_screen: dc.l 0,0,0,0,0


palplus: dc.w 16,4
	dc.w 1000,1000,1000,1000,0,0,0,1000,0,0,0,1000
	dc.w 16,17,18,19

;_log:
;	lea .text(pc),a3
;	move.l d0,(a3)
;	move d1,-(sp)		; 0=fcreate, 1=fopen write
;	pea .file(pc)
;	add #$3C,d1
;	move d1,-(sp)
;	trap #1
;	addq.l #8,sp
;	tst d0
;	bmi.s .exit
;	move d0,d3
;	move #2,-(sp)
;	move d3,-(sp)
;	clr.l -(sp)
;	GEMDOS 66,10
;	pea (a3)
;	move.l #6,-(sp)
;	move d3,-(sp)
;	GEMDOS 64,12
;	move d3,-(sp)
;	GEMDOS 62,4
;.exit:
;	rts
;.text: dc.b "****",13,10
;.file: dc.b "c:\m_player.log",0
;	even

	data

bad_card:    dc.b 0
	even

fileselect: dc.l fs_cont,global,dum,intout,fs_addrin,dum
fs_cont: dc.w 91,0,2,3,0

	; don't separate or change order of fs_addrin's
fs_addrin: dc.l path,file,0
fs_addrin_tga: dc.l tga_path,tga_file,0
fs_addrin_avr: dc.l avr_path,avr_file,0
fs_addrin_grab: dc.l out_path,out_name,0
fs_addrin_parse: dc.l path,file,0
fs_addrin_parse2: dc.l path,file,0
fs_addrin_bat: dc.l ebat_outbat,ebat_outfile,0

vs_color: dc.l vs_cont,vs_int,dum,intout,dum
vs_cont: dc.w 14,0,0,4,0,0,0,0,0,0,0,0

shel_find: dc.l sf_cont,global,dum,intout,rsc_name,dum
sf_cont: dc.w 124,0,1,1,0

shel_write: dc.l sw_cont,global,sw_int,intout,sw_addrin,dum
sw_cont: dc.w 121,3,1,2,0
sw_int: dc.w 1,1,0
_ximg_:

rsrc_load: dc.l rl_cont,global,dum,intout,rsc_name,dum
rl_cont: dc.w 110,0,1,1,0
rsc_name: dc.l _name

rsrc_free: dc.l rf_cont,global,dum,dum,dum,dum
rf_cont: dc.w 111,0,1,0,0

; form_dial2: dc.l fd_cont,global,rect_dial,dum,dum,dum

form_do: dc.l do_cont,global,do_int,intout,tree,dum
do_cont: dc.w 50,1,1,1,0
do_int: dc.w 0			; no edit object

qt_title:  dc.b "  Apple QuickTime¿ (MOV)  ",0
vr_title:  dc.b "   QuickTime¿ V_R (MOV)   ",0
avi_title: dc.b " Video for Windows¿ (AVI) ",0
fli_title: dc.b "Autodesk Animator¿ (FLI/C)",0
mpg_title: dc.b "   MPEG animation (MPG)   ",0
seq_title: dc.b " Cyber Paint¿ anims (SEQ) ",0
kin_title: dc.b " Kinetic Microsyst¿ (FLM) ",0
dlt_title: dc.b " Cyber¿ anims (PI1 + DLT) ",0
flm_title: dc.b "   Lexicor¿ films (FLM)   ",0
xflm_title:
			  dc.b "  Extended Lexicor¿ Film  ",0
gif_title: dc.b "Compuserve¿ graphics (GIF)",0
dl_title:  dc.b " Uncompressed DL1/2  (DL) ",0
vmas_title:
			  dc.b " Video Master¿ V1.0 (FLM) ",0
mvi_title: dc.b "   Motion Pixels¿ (MVI)   ",0
cd_title:  dc.b "  Stratos Magazine (CDx)  ",0
vst_title: dc.b "  Vidi ST ram file (VST)  ",0
mjpeg_title:
			  dc.b "(M)JPEG sequence (MJP/JPG)",0
comp_txt: dc.b "xxxx"
control_text: dc.b " (Control = Stop!)",0
step_home: dc.b 27,"H",0
no_rsc: dc.b "[1][ |Can't find ressource file | M_PLAYER.RSC ! ][ Quit ]",0
   even

	; to build each table, x goes from 4 to 124 and from -124 to -4 (step 8)
	; then we calculate int( x * A + 0.5 ), A depends on the table.

	; A=1.402
qt_vr_tab: dc.w 6,17,28,39,50,62,73,84,95,107
			  dc.w 118,129,140,151,163,174
			  dc.w -174,-163,-151,-140,-129
			  dc.w -118,-107,-95,-84,-73,-62,-50
			  dc.w -39,-28,-17,-6
	; A=-0.34414
qt_ug_tab: dc.w -1,-4,-7,-10,-12,-15,-18,-21
			  dc.w -23,-26,-29,-32,-34,-37,-40,-43
			  dc.w 43,40,37,34,32,29,26,23,21
			  dc.w 18,15,12,10,7,4,1
	; A=-0.71414
qt_vg_tab: dc.w -3,-9,-14,-20,-26,-31,-37,-43
		     dc.w -49,-54,-60,-66,-71,-77,-83,-89
		     dc.w 89,83,77,71,66,60,54,49,43,37
		     dc.w 31,26,20,14,9,3
	; A=1.772
qt_ub_tab: dc.w 7,21,35,50,64,78,92,106,120,135,149,163,177,191,206,220
			  dc.w -220,-206,-191,-177,-163,-149,-135,-120,-106,-92,-78,-64
			  dc.w -50,-35,-21,-7

	; for QT modes (rle, smc, ...)

default_palette:
	dc.b 1,0		; one block
	dc.b 0,0		; 0=start, 0=256 colors
   dc.b $ff,$ff,$ff,$ff,$ff,$cc,$ff,$ff,$99,$ff,$ff,$66
   dc.b $ff,$ff,$33,$ff,$ff,$0,$ff,$cc,$ff,$ff,$cc,$cc
   dc.b $ff,$cc,$99,$ff,$cc,$66,$ff,$cc,$33,$ff,$cc,$0
   dc.b $ff,$99,$ff,$ff,$99,$cc,$ff,$99,$99,$ff,$99,$66
   dc.b $ff,$99,$33,$ff,$99,$0,$ff,$66,$ff,$ff,$66,$cc
   dc.b $ff,$66,$99,$ff,$66,$66,$ff,$66,$33,$ff,$66,$0
   dc.b $ff,$33,$ff,$ff,$33,$cc,$ff,$33,$99,$ff,$33,$66
   dc.b $ff,$33,$33,$ff,$33,$0,$ff,$0,$ff,$ff,$0,$cc
   dc.b $ff,$0,$99,$ff,$0,$66,$ff,$0,$33,$ff,$0,$0
   dc.b $cc,$ff,$ff,$cc,$ff,$cc,$cc,$ff,$99,$cc,$ff,$66
   dc.b $cc,$ff,$33,$cc,$ff,$0,$cc,$cc,$ff,$cc,$cc,$cc
   dc.b $cc,$cc,$99,$cc,$cc,$66,$cc,$cc,$33,$cc,$cc,$0
   dc.b $cc,$99,$ff,$cc,$99,$cc,$cc,$99,$99,$cc,$99,$66
   dc.b $cc,$99,$33,$cc,$99,$0,$cc,$66,$ff,$cc,$66,$cc
   dc.b $cc,$66,$99,$cc,$66,$66,$cc,$66,$33,$cc,$66,$0
   dc.b $cc,$33,$ff,$cc,$33,$cc,$cc,$33,$99,$cc,$33,$66
   dc.b $cc,$33,$33,$cc,$33,$0,$cc,$0,$ff,$cc,$0,$cc
   dc.b $cc,$0,$99,$cc,$0,$66,$cc,$0,$33,$cc,$0,$0
   dc.b $99,$ff,$ff,$99,$ff,$cc,$99,$ff,$99,$99,$ff,$66
   dc.b $99,$ff,$33,$99,$ff,$0,$99,$cc,$ff,$99,$cc,$cc
   dc.b $99,$cc,$99,$99,$cc,$66,$99,$cc,$33,$99,$cc,$0
   dc.b $99,$99,$ff,$99,$99,$cc,$99,$99,$99,$99,$99,$66
   dc.b $99,$99,$33,$99,$99,$0,$99,$66,$ff,$99,$66,$cc
   dc.b $99,$66,$99,$99,$66,$66,$99,$66,$33,$99,$66,$0
   dc.b $99,$33,$ff,$99,$33,$cc,$99,$33,$99,$99,$33,$66
   dc.b $99,$33,$33,$99,$33,$0,$99,$0,$ff,$99,$0,$cc
   dc.b $99,$0,$99,$99,$0,$66,$99,$0,$33,$99,$0,$0
   dc.b $66,$ff,$ff,$66,$ff,$cc,$66,$ff,$99,$66,$ff,$66
   dc.b $66,$ff,$33,$66,$ff,$0,$66,$cc,$ff,$66,$cc,$cc
   dc.b $66,$cc,$99,$66,$cc,$66,$66,$cc,$33,$66,$cc,$0
   dc.b $66,$99,$ff,$66,$99,$cc,$66,$99,$99,$66,$99,$66
   dc.b $66,$99,$33,$66,$99,$0,$66,$66,$ff,$66,$66,$cc
   dc.b $66,$66,$99,$66,$66,$66,$66,$66,$33,$66,$66,$0
   dc.b $66,$33,$ff,$66,$33,$cc,$66,$33,$99,$66,$33,$66
   dc.b $66,$33,$33,$66,$33,$0,$66,$0,$ff,$66,$0,$cc
   dc.b $66,$0,$99,$66,$0,$66,$66,$0,$33,$66,$0,$0
   dc.b $33,$ff,$ff,$33,$ff,$cc,$33,$ff,$99,$33,$ff,$66
   dc.b $33,$ff,$33,$33,$ff,$0,$33,$cc,$ff,$33,$cc,$cc
   dc.b $33,$cc,$99,$33,$cc,$66,$33,$cc,$33,$33,$cc,$0
   dc.b $33,$99,$ff,$33,$99,$cc,$33,$99,$99,$33,$99,$66
   dc.b $33,$99,$33,$33,$99,$0,$33,$66,$ff,$33,$66,$cc
   dc.b $33,$66,$99,$33,$66,$66,$33,$66,$33,$33,$66,$0
   dc.b $33,$33,$ff,$33,$33,$cc,$33,$33,$99,$33,$33,$66
   dc.b $33,$33,$33,$33,$33,$0,$33,$0,$ff,$33,$0,$cc
   dc.b $33,$0,$99,$33,$0,$66,$33,$0,$33,$33,$0,$0
   dc.b $0,$ff,$ff,$0,$ff,$cc,$0,$ff,$99,$0,$ff,$66
   dc.b $0,$ff,$33,$0,$ff,$0,$0,$cc,$ff,$0,$cc,$cc
   dc.b $0,$cc,$99,$0,$cc,$66,$0,$cc,$33,$0,$cc,$0
   dc.b $0,$99,$ff,$0,$99,$cc,$0,$99,$99,$0,$99,$66
   dc.b $0,$99,$33,$0,$99,$0,$0,$66,$ff,$0,$66,$cc
   dc.b $0,$66,$99,$0,$66,$66,$0,$66,$33,$0,$66,$0
   dc.b $0,$33,$ff,$0,$33,$cc,$0,$33,$99,$0,$33,$66
   dc.b $0,$33,$33,$0,$33,$0,$0,$0,$ff,$0,$0,$cc
   dc.b $0,$0,$99,$0,$0,$66,$0,$0,$33,$ee,$0,$0
   dc.b $dd,$0,$0,$bb,$0,$0,$aa,$0,$0,$88,$0,$0
   dc.b $77,$0,$0,$55,$0,$0,$44,$0,$0,$22,$0,$0
   dc.b $11,$0,$0,$0,$ee,$0,$0,$dd,$0,$0,$bb,$0
   dc.b $0,$aa,$0,$0,$88,$0,$0,$77,$0,$0,$55,$0
   dc.b $0,$44,$0,$0,$22,$0,$0,$11,$0,$0,$0,$ee
   dc.b $0,$0,$dd,$0,$0,$bb,$0,$0,$aa,$0,$0,$88
   dc.b $0,$0,$77,$0,$0,$55,$0,$0,$44,$0,$0,$22
   dc.b $0,$0,$11,$ee,$ee,$ee,$dd,$dd,$dd,$bb,$bb,$bb
   dc.b $aa,$aa,$aa,$88,$88,$88,$77,$77,$77,$55,$55,$55
   dc.b $44,$44,$44,$22,$22,$22,$11,$11,$11,$0,$0,$0

; for MOV rle4 or raw4...

default_pal_16:
	dc.b 1,0,0,16
	dc.b $ff,$ff,$ff,255,247,0,$ff,$63,0,$de,8,0
	dc.b $f7,8,$84,$42,0,$a5,0,0,$d6,0,$ad,$ef
	dc.b $18,$b5,$10,0,$63,$10,$52,$29,0,$94,$73,$39
	dc.b $c6,$c6,$c6,$84,$84,$84,$42,$42,$42,0,0,0

mov_header:
	dc.l	$2ee	; taille + 4 * number of frames
	dc.b 'moov'

	dc.l $6c
	dc.b 'mvhd'
	dc.l 0
date1:
	dc.l $ae33de13,$ae33de13
	dc.l 1000		; 1/1000 de sec!
;	dc.l 0		; dur‚e totale (1/1000 Šmes)
	dc.l $00010000
	dc.w $00ff
	dc.l 0,0,1,0,0,0,1,0,0,0,$4000
	dc.w 0
	dc.l 0,0,0,0,0,0,2

	dc.l $22a	; taille + 4 * number of frames
	dc.b 'trak'

	dc.l $5c
	dc.b 'tkhd'
	dc.l $f
date2:
	dc.l $AE33D60F,$AE33DE14,1
	dc.l 1000	; timescale
;	dc.l 0	; dur‚e totale
	dc.l 0,0
	dc.w 0,0,0
	dc.l 1,0,0,0,1,0,0,0,$4000
;	dc.l 0,0		; width et height
	dc.w 0

	dc.l $24
	dc.b 'edts'

	dc.l $1c
	dc.b 'elst'
	dc.l 0,1
;	dc.l 0	; dur‚e totale
	dc.l 0
	dc.w 1,0

	dc.l $1a2	; taille + 4 * number of frames
	dc.b 'mdia'

	dc.l $20
	dc.b 'mdhd'
	dc.l 0
date3:
	dc.l $ae33de13,$ae33de14,1000
;	dc.l 0	; dur‚e totale
	dc.w 0,0

	dc.l $38	; taille
	dc.b 'hdlr'
	dc.l 0
	dc.b 'mhlr','vide','gtel'
	dc.l $40000000,$0001002e
	dc.b $17,'M_Player on Atari 68030'

	dc.l $142	; taille + 4 * number of frames
	dc.b 'minf'

	dc.l $14
	dc.b 'vmhd'
	dc.l 1
	dc.w $0040,$8000,$8000,$8000

	dc.l $38	; taille
	dc.b 'hdlr'
	dc.l 0
	dc.b 'dhlr','alis','gtel'
	dc.l $40000000,$00010037
	dc.b $17,'M_Player on Atari 68030'

	dc.l $24
	dc.b 'dinf'

	dc.l $1c
	dc.b 'dref'
	dc.l 0,1,$c
	dc.b 'alis'
	dc.l 1

	dc.l $CA	; taille + 4 x number of frames
	dc.b 'stbl'

	dc.l $66
	dc.b 'stsd'
	dc.l 0,1
	dc.l $56
	dc.b 'rle '
	dc.l 0
	dc.w 0,1,1,1
	dc.b 'gtel'
	dc.l 0,$400
;	dc.w 0,0		; width et height
	dc.l $480000,$480000,0
	dc.w 1
	dc.b 15,"M_PLAYER(V"
	VER_STR
	dc.b ")"
	dcb.b 16,0
	dc.w 16,$ffff	;plans et flag

	dc.l $18
	dc.b 'stts'
	dc.l 0,1
;	dc.l 0	; number of frames
;	dc.l 0	; duration of 1 frame

	dc.l $1c
	dc.b 'stsc'
	dc.l 0,1
	dc.l 1
;	dc.l 0	; number of frames
	dc.l 1

	dc.l $14	; ( + 4 x number of frames)
	dc.b 'stsz'
	dc.l 0,0
;	dc.l 0	; number of frames
;	dc.l x,x,x	; taille de chaque frame

	dc.l $14
	dc.b 'stco'
	dc.l 0,1,8	; first and only offset!

sound_header:
	dc.l $1f8
	dc.b 'trak'

	dc.l $5c
	dc.b 'tkhd'
	dc.l $f
date4:
	dc.l $ac78a740,$ad057173,2
	dc.l 0
;	dc.l	dur‚e totale	en 1/200 de seconde
	dc.l 0,0
	dc.w 0,0,$100
	dc.l 1,0,0,0,1,0,0,0,$4000,0,0
	dc.w 0

	dc.l $24
	dc.b 'edts'

	dc.l $1c
	dc.b 'elst'
	dc.l 0,1
;	dc.l dur‚e totale	en 1/1000
	dc.l 0
	dc.w 1,0

	dc.l $170
	dc.b 'mdia'

	dc.l $20
	dc.b 'mdhd'
	dc.l 0
date5:
	dc.l $ad057171,$ad057171
;	dc.l frequency,taille en octets
	dc.w 0,0

	dc.l $3a
	dc.b 'hdlr'
	dc.l 0
	dc.b 'mhlr','soun','gtel'
	dc.l $40000000,$00010024
	dc.b 25,'M_PLAYER sound Atari68030'

	dc.l $10e
	dc.b 'minf'

	dc.l $10
	dc.b 'smhd'
	dc.l 0,0

	dc.l $3A
	dc.b 'hdlr'
	dc.l 0
	dc.b 'dhlr','alis','gtel'
	dc.l $40000000,$0001002c
	dc.b 25,'M_PLAYER sound Atari68030'

	dc.l $24
	dc.b 'dinf'

	dc.l $1c
	dc.b 'dref'
	dc.l 0,1,$c
	dc.b 'alis'
	dc.l 1

	dc.l $98
	dc.b 'stbl'

	dc.l $34
	dc.b 'stsd'
	dc.l 0,1,$24
;	dc.b 'raw '	s_signe!
	dc.l 0
	dc.w 0,1,0,0
	dc.b 'gtel'
;	dc.w channels,res
	dc.w 0,0
;	dc.l frequency (LFIXED)

	dc.l $18
	dc.b 'stts'
	dc.l 0,1
;	dc.l taille totale en samples
	dc.l 1

;	dc.l $1c
	dc.b 'stsc'
	dc.l 0
;	dc.l 1
;	dc.l 1
;	dc.l taille d'un bloc en samples
;	dc.l 1

	dc.l $14
	dc.b 'stsz'
	dc.l 0
	dc.l 1
;	dc.l taille totale en samples

;	dc.l $14
	dc.b 'stco'
	dc.l 0
;	dc.l 1
;	dc.l 8		; offset des sons

udta_header:
	dc.l $50
	dc.b 'udta'
	dc.l $38
	dc.b 'NAVG'
	dc.w 1	; version number?
	dc.w 0,0	; xmax, ymax
	dc.w 0,1	; ??, img/cell
	dc.w 1000,1	; time/img, cursor type
	dc.l 180	; view field
	dc.l 0,0	; start & end angle x
	dc.l 0,0	; start & end angle y
	dc.l 0,0	; first x and first y angle
	dc.w 0,0,0
	dc.l $c
	dc.b 'ctyp','stna'
	dc.l 0

avi_header:
	dc.b 'RIFF    AVI LIST    hdrlavih'
	dc.l $38000000
	dc.l $40420f00		; (32) microseconds per frame (5000 x _delay)
	dc.l 0				; (36) bytes per second
	dc.l 0,$10000000
	dc.l 0				; (48) number of frames
	dc.l 0
	dc.l $01000000		; (56) 1 images, 2 images + sound
	dc.l 0				; (60) max frame size + max sound size
	dc.l 0				; (64) W
	dc.l 0				; (68) H
	dc.l 0,0,0,0
	dc.b 'LIST'
	dc.l $74040000		; (92) $74000000 si pas de palette!
	dc.b 'strlstrh'
	dc.l $38000000
	dc.b 'vids'
	dc.b 'RLE '			; (112) codec (RLE ou MSVC)
	dc.l 0,0
	dc.l 0
	dc.l $01000000		; (128) microseconds per frame
	dc.l $40420F00
	dc.l 0
	dc.l 0				; (140) number of frames
	dc.l 0				; (144) max frame size
	dc.l $34210000,0,0,0
	dc.b 'strf'
	dc.l $28040000,$28000000	; (168) $28000000 si pas de palette!
	dc.l 0				; (176) W
	dc.l 0				; (180) H
	dc.w $0100
	dc.w $0800			; (186) bits par pixel (8 ou 16)
	dc.l $01000000		; (188) codec 01000000=RLE ou  CRAM=MSVC
	dc.l 0				; (192) w*h
	dc.l 0,0
	dc.l $00010000		; (204) taille palette (256 en 8bits, 0 en 16bits)
	dc.l 0
							; here should come the palette 1024 bytes
							; b,v,r,0 * 256
avi_end_header:
	dc.b 'LIST    movi'

avi_sound_header:		; 100 bytes
	dc.b 'LIST'
	dc.l $5c000000
	dc.b 'strlstrh'
	dc.l $38000000
	dc.b 'auds'
	dc.l 0,0,0,0
	dc.l 0				; (40) scale = bytes per sample (1, 2 or 4)
	dc.l 0				; (44) freq*scale
	dc.l 0
	dc.l 0				; (52) total bytes / scale
	dc.l 0				; (56) max f size
	dc.l $34210000
	dc.l 0				; (64) scale again
	dc.l 0,0
	dc.b 'strf'
	dc.l $10000000
	dc.w $0100
	dc.w 0				; (86) channels
	dc.l 0				; (88) freq
	dc.l 0				; (92) freq x scale
	dc.w 0				; (96) scale again
	dc.w 0				; (98) bits per sample

is_65k: dc.w $0003 ; mode for 32768 colors on NOVA
bit_rot: dc.w 8	 ; 8 rotations for high color in NOVA mode

mouse_disk:
	dc.w 7,7,1,0,1
	dc.l $ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$ffffffff,$7fff3fff
	dc.l $00007ffe,$500a700e,$700e500a,$500a500a,$4ff24002,$4ff24b12,$4b122b12,$1ffe0000
	
mouse_next:
	dc.w 7,7,1,0,1
	dc.l $0000f000,$9e008700,$81c08070,$801c8006,$80028006,$801c8070,$81c08700,$9e00f000
	dc.l $00000000,$60007800,$7e007f80,$7fe07ff8,$7ffc7ff8,$7fe07f80,$7e007800,$60000000
	
mouse_fast:
	dc.w 7,7,1,0,1
	dc.l $0000e1c0,$b1609930,$8d18870c,$83068183,$80c18183,$8306870c,$8d189930,$b160e1c0
	dc.l $00000000,$408060c0,$70e078f0,$7cf87e7c,$7f3e7e7c,$7cf878e0,$70e060c0,$40800000
	



	bss

vp_int: ds.w 16
cp_ptsin: ds.w 8
my_mfdb: ds.l 1
		ds.w 4
planes_vdi: ds.w 4

dta: ds.b 44
aes_handle: ds.w 1
i_handle: ds.w 1
mov_h: ds.w 1
total: ds.l 1
global: ds.l 100
intout: ds.w 100

_dialog_table: ds.l LAST_TREE+2

bar_pts: ds.w 2		; do not separate bar_pts and work_out
work_out: ds.w 100

ptsout: ds.w 100
dum: ds.l 3
fname_pos: ds.l 1
path: ds.b 400		; the path (for ex: F:\MOVIES\*.MOV )
file: ds.b 256		; the file (for ex: THING.MOV )
full: ds.b 420		; the full pathname (for ex: F:\MOVIES\THING.MOV )
full2: ds.b 420

avr_path: ds.b 400
avr_file: ds.b 20
avr_full: ds.b 420
tga_path: ds.b 400
tga_file: ds.b 20
tga_full: ds.b 420
tga_file_ptr: ds.l 1
tga_digit: ds.l 1
auto_save_tga: ds.b 1
auto_run_tga: ds.b 1
last_alert: ds.b 1
quality_char: ds.b 1
from_info: ds.b 1

	even
write_error: ds.w 1
zoom_val: ds.l 1

; *********** start of data that will be zeroed at launch ***********
start_zero:

inter_flag: ds.b 1
create_avi: ds.b 1
create_mov: ds.b 1
slide_gif: ds.b 1
slide_degas: ds.b 1
mvi_flag: ds.b 1
is_vidi: ds.b 1
from_ram: ds.b 1

head_pos: ds.l 1
head_len: ds.l 1
idx_pos: ds.l 1
idx_len: ds.l 1
movi_pos: ds.l 1
avi_rate: ds.l 1

real_freq: ds.l 1
frequency: ds.l 1
channels: ds.w 1
sound_bits: ds.w 1
s_signe: ds.l 1
playing: ds.w 1
sync: ds.w 1
step_mode: ds.w 1

ss_num: ds.l 1
ss_tab: ds.l 1

sound_offs: ds.l 1
sound_num: ds.l 1

top_lines_buff: ds.l 1
one_buffer:
s_buffer: ds.l 1			; the ST ram buffer
top_lines_size:
stram_size: ds.l 1
tga_buff:	ds.l 1
two_buffer:
s_buffer_2: ds.l 1		; the remaining into TT ram
tga_buff_size: ds.l 1
ttram_size: ds.l 1
snd_temp: ds.l 1
snd_temp_size: ds.l 1

snd_pos: ds.l 1
snd_end: ds.l 1
snd_tt_end: ds.l 1
snd_size: ds.l 1
timer_c: ds.l 1
end_time: ds.l 1
start_time: ds.l 1
stopped: ds.w 1
header_read: ds.w 1

qt_time: ds.l 1
qt_timescale: ds.l 1

chunkoffs: ds.l 1
chunkoff_num: ds.l 1
chunkoff_lastnum: ds.l 1
	; each entry is a long
samp_sizes: ds.l 1
sample_num: ds.l 1
sample_lastnum: ds.l 1
	; each entry is a long
s2chunks: ds.l 1
s2chunk_num: ds.l 1
s2chunk_lastnum: ds.l 1
	; each bloc is 12 bytes long
	; 1 long : first
	; 1 long : num
	; 1 long : tag
rle16_buffer:
t2samps: ds.l 1
size_ptr:
t2samp_num: ds.l 1
	; each block is 8 bytes long:
	; 1 long : count
	; 1 long : time (or duration)
header_buffer:
codecs: ds.l 1			; adress of the malloc block
codec_num: ds.l 1	; number of codecs
codec_lastnum: ds.l 1
	; each block is 16 bytes long:
	; 1 long: width
	; 1 long: heigh
	; 1 long: depth
	; 1 long: compression

bad_comp: ds.w 1
bad_sound: ds.w 1

v_flag: ds.l 1
video_flag: ds.l 1
stsc_invalid: ds.l 1

qt_palette: ds.b 1
tga_vers_gris: ds.b 1

s_flag: ds.l 1
data_flag: ds.l 1

max_imagex: ds.w 1	; DO NOT
max_imagey: ds.w 1	; SEPARATE

max_fsize: ds.l 1
buffer: ds.l 1
bufused: ds.l 1		; do not separate
bufused_save: ds.l 1	; those two
vdi_buffer: ds.l 1
whole_file: ds.l 1
mjpg_buffer: ds.l 1

alignwidth: ds.w 1
screenw: ds.w 1	; do not
screenh: ds.w 1	; separate
offsx: ds.l 1		; there
offsy: ds.w 1		; the same

image: ds.l 1
imagex: ds.l 1
imagey: ds.l 1
depth: ds.l 1
compression: ds.l 1

disp_frame: ds.l 1
singlestep: ds.l 1
skipframes: ds.l 1

cvid_map_num: ds.l 1

hc_cvid: ds.l 1
mapused: ds.l 1

mov_h2: ds.w 1
key_frame_num: ds.w 1
key_count: ds.w 1
key_rate: ds.w 1
key_frame: ds.w 1

switched: ds.w 1
is_grey: ds.w 1
gif_trans: ds.b 1
gif_trans_index: ds.b 1

flm_screen: ds.l 1
flm_frame: ds.l 1

bat_text: ds.l 1

yamaha_flag: ds.w 1
degas_div: ds.l 1
degas_q1: ds.l 1
degas_r1: ds.l 1

grey_depth: ds.w 1
cram_bits: ds.w 1

ima4_offs: ds.l 1
ima4_flag: ds.w 1
avi_comp_flag: ds.w 1

vr_flag: ds.b 1		; DO NOT SEPARATE UNTIL vr_offset, used in EASYBAT for vr_info
create_vr: ds.b 1
vr_info:
	ds.l 1	; img/cell and time
vr_y: ds.w 1
vr_yloop: ds.w 1
vr_sy: ds.w 1
vr_x: ds.w 1
vr_xloop: ds.w 1
vr_sx: ds.w 1
vr_offset: ds.l 1		; used in EASYBAT for output/quality modifiers

vr2_flag: ds.b 1	; byte!		NE PAS SEPARER
vr2_def:	ds.b 1
vr2_data: ds.w 3	; angle large, haut, bas
			 ds.l 4	; hauteur, largeur, images/panneau, images/colonne
vr2_col_offx: ds.l 1
vr2_col_offy: ds.l 1

_vr2_x: ds.l 1		; ne pas separer les 4
_vr2_y: ds.l 1
vr2_x: ds.l 1
vr2_y: ds.l 1		; fenetre dans le panneau

vr2_num: ds.l 1	; nombre de lieux
vr2_temp: ds.l 1
vr2_panneau: ds.l 1
vr2_image: ds.l 1
vr2_index: ds.l 1
vr2_sx: ds.l 1
vr2_sy: ds.l 1
vr2_save_screen: ds.w 2
vr2_maxx: ds.l 1
vr2_maxy: ds.l 1
_freq_sav: ds.l 1

enh_buffer: ds.l 1	; adr of enh_file in RAM

mountain: ds.b 1	; byte!
conv_flag: ds.b 1
vanel_adr: ds.l 1
_vanel_plus: ds.w 1	; en plus sur une ligne
_vanel_line: ds.w 1
conv_zoom: ds.b 1		; byte! (0=pas de zoom, 1=x2, -1=:2)
group_step: ds.b 1
gif_loaded: ds.b 1	; byte!
gtel_sound: ds.b 1
_vr2_flag: ds.b 1		; byte
can_fast: ds.b 1		; byte!
unknown: ds.b 1		; byte
tgac: ds.b 1			; FF si TGA compress‚ (entree ou sortie!)
cancelled: ds.b 1		; FF if cancel in Get Rectangle
	even

offset_ximg: ds.l 1	;
mjpg_offset: ds.l 1	; 440 if MJPEG AVI (place pour le header JFIF)
mjpg_rim: ds.l 1		; address of RIM JPEG_68K.RIM
mjpg_comp: ds.l 1		; video mode in qt_raw24 for mjpg
mjpg_step_compression: ds.l 1	
tga_resize: ds.w 1		; FF si changement de taille pour sauvegarde TGA
tgac_offset: ds.l 1
tga10_buff: ds.l 1	; second buffer pour compression
conv_video: ds.b 1	; byte FF si M_PLAYER fils doit changer de RES Falcon
_conv_video: ds.b 1	; byte FF dans fils si M_PLAYER doit changer RES Falcon
etat_sav: ds.b 1		; etat des touches apres FILESLECTOR (pour parse_disk).
is_parse: ds.b 1		; FF si mode parse (pour les dialogues a modifier)
no_idx1: ds.b 1		; FF si AVI sans idx1
ttram_sound: ds.b 1	; FF si on charge en TT ram
open_parent_file: ds.b 1 ; when M_PLAYER calls M_PLAYER...
first_step_dialog: ds.b 1
is_mjpg: ds.b 1		; FF if MJPG AVI, 1=JPEG MOV, 2=MJPA MOV, 3=MJPB mov  (and load JPEG68k.RIM)
is_grab: ds.b 1		; FF dans BAT si captures d'‚cran (w=?)
alt_help: ds.b 1		; FF if alt help pressed when capturing screen
use_alt_help: ds.b 1	; FF grab with alt help, 00 with AES dialog
auto_capture_first: ds.b 1	; FF if Auto capture, 00 else
auto_capture_next: ds.b	1	; 00 until first capture, FF when previous is set
first_image: ds.b 1	; when parsing groups in Easybat
enh_flag: ds.b 1		; FF if ENHANCED file present then loaded (VIDEONAME.ENH)

; *********** end of zeroed data **************************
end_zero:
	even
ebat_addrin: ds.l 3			; path + file + text
ebat_outbat: ds.b 400		; to save BAT file
ebat_out: ds.b 400			; pah for output file
ebat_path:	ds.b 400*7		; 5 image paths + 1 sound path + temp
ebat_file: ds.b 128			; in case of long names...

whole_file_ptr:	ds.l 1	; when QT loaded into RAM

tga_srcx: ds.w 1	; source et dest pour resize sauvegarde TGA
tga_srcy: ds.w 1	; ne pas changer l'ordre !!!
tga_destx: ds.w 1
tga_desty: ds.w 1

degas_r: ds.l 1
degas_q: ds.l 1

ed_adr: ds.l 1
ed_adr_sav: ds.l 1	; for ACC

vdo_value: ds.l 1
snd_value: ds.l 1
cpu_value: ds.l 1
mch_value: ds.l 1
res_switch: ds.w 1
can_step: ds.w 1
psnd_flag: ds.w 1		; for VIRUS sound card

pattern:
smc_8: ds.w 1
dup_line:
dc_flag:
smc_a: ds.w 1
bat_getp:
smc_c: ds.w 1
pal_adr: ds.w 1

off_24_32: ds.w 1

cvid_maps0: ds.l 6
cvid_maps1: ds.l 6
bloc:			; for screen detection
cvid_fix0:  ds.b 6*2080
cvid_fix1:  ds.b 6*2080
				ds.b 3904	; for the FLM palettes
cvid_vmap0: ds.b 6
cvid_vmap1: ds.b 6
	ds.w 1					; when x needs to be long
x: ds.w 1
y: ds.w 1
y_top: ds.w 1
flag0: ds.w 1
flag1: ds.w 1
flag2: ds.w 1
nova: ds.w 1
command: ds.w 1
basepage: ds.l 1
magicmac: ds.w 1
albertt: ds.w 1

col_sav: ds.w 256*3
vs_int: ds.w 4
planes: ds.w 1
display: ds.w 1		; 1 if form_dial(reserve) has been called
							; 0 after form_dial(free)

planes_sav: ds.w 1	; in case of a screen switch
old_video: ds.w 1		; mode code
old_screen: ds.l 1	; GEM physbase
old_size: ds.l 1		; GEM screen size
old_border: ds.l 1	; some video registers
physbase: ds.l 1		; my physbase (if needed)
physbase2: ds.l 1		; the unaligned address (for mfree)
video_reg: ds.b 36	; hardware video registers for Falcon

albert_phys: ds.l 1

desiredtag: ds.l 1
fcctype: ds.l 1
mdat_end: ds.l 1

stack_adr: ds.l 1
kbshift: ds.l 1

rg_int: ds.w 2
tree: ds.l 1
tree_sav: ds.l 1
;rect_dial: ds.w 3
;rect_draw: ds.w 1
rect: ds.w 5
play_sav: ds.l 1
sync_sav: ds.l 1

cd_delay_acc: ds.l 1	; do not separate
cd_delay: ds.l 1
max_cd_delay: ds.l 1
_delay: ds.l 1
current_time: ds.l 1
grab_delay: ds.l 1
grab_time: ds.l 1

boxh: ds.w 1

hc_rmap: ds.w 256
hc_gmap: ds.w 256
hc_bmap: ds.w 256

bat_ptr: ds.l 1
out_file: ds.b 400	; enough!
out_name: ds.b 20
out_path: ds.b 400
sound_file: ds.b 400
comp_create: ds.l 1
header_size: ds.l 1
quality: ds.w 1
qual_sav: ds.w 1
size_added: ds.l 1
last_size: ds.l 1
bloc_num: ds.l 1
sound_seek: ds.l 1
mov_pal: ds.l 1
print_ptr: ds.l 1

old_midi: ds.l 1
old_stat: ds.l 1
old_cloc: ds.l 1
old_ikbd: ds.l 1

tt_screen: ds.l 1
tt_comp: ds.l 1
is_tt: ds.w 1
flx_number: ds.w 1
flx_start: ds.w 1
_disp: ds.w 1
little_indian: ds.b 1
pal_change: ds.b 1
clip_adr: ds.l 1
mfdb_dest: ds.w 10
mfdb_src: ds.w 100

flx_ptr: ds.l 1
flx_flag: ds.w 1
flx_end: ds.w 1

vcp_int: ds.w 1		; do not separate vcp_*
vcp_ptsin: ds.w 8

reverse_flag: ds.w 1
gif_flags: ds.w 1
codesize2: ds.w 1
root_code: ds.w 1
gif_image: ds.l 1
gif_image_sav: ds.l 1
gif_rows: ds.w 1
gif_lines: ds.w 1
gif_inc: ds.w 1
gif_start_line: ds.w 1
gif_one_line: ds.w 1
gif_pass: ds.w 1
gif_interlace: ds.w 1
gif_end_image: ds.l 1
gif_repeat: ds.w 1
_gif_rep: ds.w 1
gif_pal_size: ds.l 1
bat_gif_loop: ds.w 1

tt_res: ds.w 1
tt_flag_size: ds.l 1
tt_screen_size: ds.l 1

menu_tree: ds.l 1
menu_buffer: ds.l 1
menu_len: ds.l 1

dl_i_per_s: ds.w 1

cmd_x: ds.w 1
cmd_y: ds.w 1
cmd_return_adr: ds.l 1

acc_cmd_adr: ds.l 1

flm_snd_size: ds.l 1
flm_snd_pos: ds.l 1
flm_snd_end: ds.l 1

flm_time_ptr: ds.l 1
flm_ptr_inc: ds.l 1
flm_time: ds.l 1
flm_time_inc: ds.l 1
_flm_phys: ds.l 1
neo_degas_offs: ds.l 1

id_ptr: ds.l 1				; initialis‚ a id_table!
id_table: ds.l 6			; au cas ou! VR2 n'en compte que 2
								; LONG ID et qt_palette
mvi_save_size: ds.l 1
mvi_next_size: ds.l 1
mvi_rem: ds.w 1	; byte

slide_zone: ds.l 1
slide_ptr: ds.l 1
slide_stack: ds.l 1
slide_flag: ds.w 1
slide_digit: ds.l 1
slide_save_flags: ds.b 10

iv32_ptrs: ds.l 6	; y1,u1,v1,y2,u2,v2

cd_acc: ds.w 9 ; LONG acc_remain, WORD acc_int, WORD loop
					; word +int, LONG+remain, LONG remain limit
cd_sound_count: ds.l 1

buffer_16: ds.l 1	; 16 bytes aligned buffer

	; do not separate those flags
	; chacun = FF si +option ou 00 si -option
cmd_dial: ds.b 1	; d‚faut +d afficher les dialogues
cmd_play: ds.b 1	; d‚faut +p play sound en mode -d
cmd_sync: ds.b 1	; d‚faut +s synchro en mode -d
cmd_alt: ds.b 1	; d‚faut -a ne pas cr‚er/ne pas d‚sassembler en mode -d
cmd_erro: ds.b 1	; d‚faut -e ne pas afficher erreurs en mode -d
cmd_inter: ds.b 1	; d‚faut -i ne pas boucler en mode -d
cmd_coord: ds.b 1	; d‚faut 00 pas de coordonn‚es fix‚es mode -d
cmd_return: ds.b 1	; d‚faut -r pas de retour au programme appelant mode -d
	even

DVI_DELTA: ds.w 1424	; compressed sound
							; used by v_gtext as intin tab for string

can_win: ds.b 1		; 16 bits (NOVA or Falcon) on desktop -> window allowed
is_win: ds.b 1			; can_win=true and enough place for a window
fast_mode: ds.b 1		; byte
is_rep: ds.b 1			; if REPEAT button is ON
is_vdi: ds.b 1			; modes 24/32 bits ON
adapt_mode: ds.b 1	; FF falcon adapt, 0 nova_adapt, 1 adapt_256
is_mw: ds.b 1			; FF if microwire present (TT), 01 if XBIOS function Souncmd present
menu_flag: ds.b 1		; according to menu selection:
							; FF Load and play video
							; 00 convert/disassemble video
							; 01 assemble images
							; 02 capture screen
langue: ds.b 1			; code pays 0=US, 2=FR, ...
langue_ami: ds.b 1	; code pays mˆme langue ou doublon
	even
vdi_compression: ds.l 1	; pointer to flag/routine/flag structure. See TM:
step_compression: ds.l 1	; 16 bit routine, whatever the screen is
step_vdi: ds.b 2		; to use VDi in step mode and <16bits resol
step_vdi_sav: ds.w 20	; to save context
							; LONG 16 to grey buffer
							; WORD is_65k
							; WORD planes_vdi
							; BYTE is_vdi
							; BYTE nova
							; LONG ed_adr
							; WORD planes
							; BYTE is_tt
							; 17 used
							

sample_num2: ds.l 1	; les effectivements sauv‚es (voire ritme!)

window0: ds.w 5		; return + x + y + l + h of window 0
ws_int: ds.w 6
wc_int: ds.w 6
wc_int2: ds.w 6

tree_filename: ds.l 1
parent_source_handle:  ds.w 1 ; when M_PLAYER calls M_PLAYER
_dialogue: ds.l 3		; ma routine, frame number, adresse pixels
	ds.w 1				; flag, si flag='EX' ou 'XE', il y a une extension
	ds.w 1				; extension: $0101=taille normale
							;				 $0201=zoom fois deux
							;				 $0102=zoom divis‚ par deux
							; si flag='XE', adresse pixels contient l'adresse
							; du nom du fichier … ouvrir par le CHILD … la premiŠre
							; image et qui renvoit le handle fichier dans flag.

conv_stack: ds.l 1
hote_stack: ds.l 1
conv1_stack: ds.l 1
anim_type: ds.w 1
conv_x: ds.w 1			; en cas de zoom, garde les tailles d'origine
conv_y: ds.w 1

snd_size_offs: ds.l 2	; pour MOV

qtvr_num: ds.l 1		; nombre d'images du premier codec.
_mpg_trap: ds.l 2		; trap 8 (dessin) trap 7 (timer)
_mpg_time: ds.w 1

em_buffer: ds.w 8
mp_buffer: ds.w 8

acc: ds.b 1
rsc: ds.b 1
acc_command: ds.b 1
repondre: ds.b 1
sw_addrin: ds.l 2

	even.l
mjpg_mfdb:
intra_quantizer_matrix: ds.l 64	; used as MFDB in JPEG RIM
gsb_int:
non_intra_quantizer_matrix: ds.l 64	; used as intin for graf_shrinkbox
memory_bat:
chroma_intra_quantizer_matrix: ds.l 64	; used as a dummy BATCH when capturing
chroma_non_intra_quantizer_matrix: ds.l 64
block: ds.w 64*12
Clip: ds.b 1024
ebat_path_names:		; 5*6 for images groups (easybat) then memory bat file
Sas: ds.b 65540		; used to parse AVI, MJP or JPG files, or with easybat
DCTptr: ds.l 65536	; used to load JPEG_68K.RIM and then at DCTptr+65536 = *.WIM
Rdbfr: ds.b 8452		; and at DCTptr+131072 : offset pointer to  every mjpeg frame (34881 frames)
options: ds.b 4*512	; file M_PLAYER.OPT
	; four blocs of:
	; +0  (2)   WORD status
	; +2  (18)  STRING as appears in RSC dialog (17 chars+0)
	; +20 (492) STRING full path name (491 + zero)
	; Four blocs for DEFAULT, SOUND, IMAGES, VIDEO CONVER
	; + those flags
always_count: ds.b 1		; FF if always count MPEG
create_folder: ds.b 1	; FF is create folder with anim name
auto_name: ds.b 1			; FF if build name auto
disable_options: ds.b 1 ; FF to disable the 3 above
sound_system: ds.b 1		; 1 DMA, 2 YAMAHA, 3 PSOUND
warnings: ds.b 1			; FF on, 00 off for some alert boxes
dma_quality: ds.b 1		; FF for upper freq, 00 for lower
	ds.b 1
mjpg_fps: ds.w 1			; default delay for frames per second in mjpeg (1 to 2000)
	ds.b 230
	; laisser ici sur une adresse paire !
microwire: ds.b 8			; validate($E7),vol(40),left(40),right(40),treb(12),bass(12),mix(1/2),dum
	ds.b 8					; 8 more in case... up to 256 bytes

fs_addrin_opt: ds.l 3
opt_path: ds.b 492
opt_file: ds.b 128
opt_dta: ds.b 44
old_trap10: ds.l 1		; my trap 10 reads timer
old_trap11: ds.l 1		; my trap 11 reads the DMA sound state
temp_microw: ds.b 8		; temporary microwire data
test_sound_start: ds.l 1	; address of sound for TT Microwire start
test_sound_end: ds.l 1	
mjpg_fps_string: ds.l 1	; keep xx.x string for changes
kvdbbase: ds.l 1
old_screen_dump: ds.l 1 ; vector $502 with Alt Help
alert_adr: ds.l 1			; start of free string table in RSC (alert strings)
alert_ptr:					; table with pointers into the modifiable strings
	ds.l 1	; +0 pointer to group number into string 13
	ds.l 1	; +4 pointer to group number into string 14
	ds.l 1	; +8 pointer to group number into string 15
	ds.l 1	; +12 pointer to filename into string 15
	ds.l 1	; +16 pointer to group number into string 16
	ds.l 1	; +20 pointer to filename into string 16
	ds.l 1	; +24 pointer to group number into string 17
	ds.l 1	; +28 pointer to filename into string 17
	ds.l 1	; +32 pointer to group number into string 18
	ds.l 1	; +36 pointer to filename into string 18
	ds.l 1	; +40 pointer to current image type in string 18
	ds.l 1	; +44 pointer to required image type in string 18
	ds.l 1	; +48 pointer to bad command in string 41
	ds.l 1	; +52 pointer to command ENHANCED in string 38
	ds.l 1	; +56 pointer to bad parameter ENHANCED in string 38
	ds.l 1	; +60 pointer to unknown command ENHANCED in string 34
principal_ptr:		; table de pointeurs sur l'interface principale
fstring_adr: ds.l 1	; tree with some free strings
fsel30_adr: ds.l 1	; tree with fileselector titles (30 chars each)
infbox24_adr: ds.l 1	; tree with lines into info box (24 chars each)	
step_keys:	ds.l 1	; adresse chaine step by step en mode Falcon
	ds.b 4				; les 4 touches actives du menu prises dans la chaine
delay: ds.b 20			; xxx.x f/s
_name: ds.b 200		; path to M_PLAYER.RSC/AVR/OPT...
country_code: ds.w 1	; two digits country code from OS header/_AKP cookie
enh_time: ds.l 1		; time for next enhanced event
enh_ptr0: ds.l 1		; first enh ptr (in case of REPEAT)
enh_ptr: ds.l 1		; current pointer in this file
enh_lines: ds.w 1		; number of lines in enhanced
	;*** garder ensemble!
vh_pts: ds.w 1			; entr‚e vst_height 0,hauteur=enh_size
							; et sortie x,x,x,hauteur cellule=enh_cell
enh_size: ds.w 1		; font size
enh_extra:	ds.w 1	; lines*cell
enh_cell: ds.w 1		; hauteur d'une cellule de caractŠre
vrf_pts: ds.w 4		; coordonn‚es du rectangle enhanced pour effacage du fond
	; *** jusqu'ici
vgt_pts: ds.w 2		; coordonn‚es v_gtext enhanced

	even
	ds.b $1000
_pile: ds.w 1		; room for the stack

	end
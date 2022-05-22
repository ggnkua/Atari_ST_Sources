;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; TFMX Pro 2.0 Replay Routine (ST/STE Version), Version 6		;
;									;
;     Paula emulator							;
;     Developed : 13/02/1991.     This Version updated : 23/06/1991	;	
;     Marx Marvelous stepped in: 05/12/1992.				;
;     8-voice added: 21/12/1992.					;
;     TFMX Pro 1.0 sorta-support added: 20/03/93.			;
;     8-voice made 7-voice: 21/12/1992.					;
;									;
;------------------   A few notes about this driver   ------------------;
; - TFMX was(?) a creation of Chris Huelsbeck from sometime in 1990	;
; - Emulator adapted to be more Paula-like by Marx Marvelous/TPPI	;
; - TFMX player adapted by Marx Marvelous/TPPI				;
; - Everything else by Griff/Electronic Images				;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

; Griff would just like to say that he spent the last half hour going
; thru his source code and commenting it for us (ain't he kind!!).

; (So?  I spent at least an hour reverse-engineering TFMX-Pro and
; another two hours documenting it.  Nyah.)

; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

NEATO	=	0
		OPT O-,OW-
; MFP equates, to help me and bore you
mfp_gpip	equ	$FFFFFA01
mfp_aer		equ	$FFFFFA03
mfp_ddr		equ	$FFFFFA05
mfp_iera	equ	$FFFFFA07
mfp_ierb	equ	$FFFFFA09
mfp_ipra	equ	$FFFFFA0B
mfp_iprb	equ	$FFFFFA0D
mfp_isra	equ	$FFFFFA0F
mfp_isrb	equ	$FFFFFA11
mfp_imra	equ	$FFFFFA13
mfp_imrb	equ	$FFFFFA15
mfp_vr		equ	$FFFFFA17
mfp_tacr	equ	$FFFFFA19
mfp_tbcr	equ	$FFFFFA1B
mfp_tcdcr	equ	$FFFFFA1D
mfp_tadr	equ	$FFFFFA1F
mfp_tbdr	equ	$FFFFFA21
mfp_tcdr	equ	$FFFFFA23
mfp_tddr	equ	$FFFFFA25
mfp_scr		equ	$FFFFFA27
mfp_ucr		equ	$FFFFFA29
mfp_rsr		equ	$FFFFFA2B
mfp_tsr		equ	$FFFFFA2D
mfp_udr		equ	$FFFFFA2F

mfp_iio7	equ	$13C
mfp_iio6	equ	$138
mfp_ita		equ	$134
mfp_rful	equ	$130
mfp_rerr	equ	$12C
mfp_smpt	equ	$128
mfp_serr	equ	$124
mfp_itb		equ	$120
mfp_iio5	equ	$11C
mfp_iio4	equ	$118
mfp_itc		equ	$114
mfp_itd		equ	$110
mfp_iio3	equ	$10C
mfp_iio2	equ	$108
mfp_iio1	equ	$104
mfp_iio0	equ	$100

; TFMX equates

* Referenced from tfmx_parms (64 bytes)
p1_mdatbase	=	$0	l
p1_smplbase	=	$4	l
p1_chanstop	=	$8	w
p1_chanstart	=	$A	w
p1_subsong2	=	$C	b
p1_kmastervol	=	$D	b
p1_holdstack	=	$E	w		not used here
;4
p1_cmd0		=	$12	l
p1_cmd1		=	$13
p1_cmd2		=	$14
p1_cmd3		=	$15
p1_cntdown	=	$16	w
p1_playflag	=	$18	b
p1_overagain	=	$19
;4
p1_ciatempo	=	$1E	w
;6
p1_subsong	=	$26	w
p1_nmastervol	=	$28	b	new
p1_tmastervol	=	$29	b	target
p1_cmastervol	=	$2A	b	count
p1_rmastervol	=	$2B	b	reset-count
p1_onflag	=	$2C
p1_nonflag	=	$2D
p1_songrept	=	$2E
p1_plstbase	=	$30
p1_patsbase	=	$34
p1_instbase	=	$38
;4

* Referenced from voice records (one for each channel, 84 bytes per record)
pv_running	=	$0
pv_setup	=	$1
;1
pv_csampmod	=	$3
pv_lastnote	=	$4
pv_thisnote	=	$5
pv_loopctr	=	$6
pv_nybvolume	=	$8
pv_notetune	=	$A
pv_instptr	=	$C
pv_instidx	=	$10
pv_cntdown	=	$12
pv_setdma	=	$14
pv_clrdma	=	$16
pv_nvolume	=	$18	b
pv_ovolume	=	$19	b
pv_reptctr	=	$1A
pv_rsampmod	=	$1B
pv_rvslide	=	$1C
pv_cvslide	=	$1D
pv_tvslide	=	$1E
pv_svslide	=	$1F
pv_kvibrato	=	$20
pv_vibrflag	=	$21
pv_rporta	=	$22
pv_cporta	=	$23
pv_nvibrato	=	$24	w
pv_rvibrato	=	$26
pv_cvibrato	=	$27
pv_per		=	$28
;2
pv_sampstart	=	$2C
pv_kporta	=	$30
pv_tporta	=	$32
pv_samplgth	=	$34
pv_envcycle	=	$36
pv_instisv	=	$38
pv_instpsv	=	$3A
;2
pv_setint	=	$40
pv_clrint	=	$42
;4
pv_audioptr	=	$48
pv_ksampmod	=	$4C
;2
pv_finalper	=	$50	w
pv_freqset	=	$52	b

* Referenced from tfmx_parms2 (200 bytes)
p2_songrst	=	$0
p2_songend	=	$2
p2_songptr	=	$4
p2_speed	=	$6
p2_lpattidx	=	$8	w
p2_lpattctr	=	$A	w
p2_pattptr	=	$28	l
p2_pattidx	=	$48	w
p2_pattrep	=	$4A	b
p2_pattctr	=	$68	w
p2_pattcdn	=	$6A	b
p2_pattpsv	=	$88
p2_pattcsv	=	$A8


letsgo		MOVE.L 4(SP),A5
		MOVE.L $C(A5),A4
		ADD.L $14(A5),A4
		ADD.L $1C(A5),A4
		LEA $100(A4),A4			; proggy size+basepage
		PEA (A4)
		PEA (A5)
		CLR -(SP)
		MOVE #$4A,-(SP)
		TRAP #1				; reserve some memory
		LEA 12(SP),SP
		BSR appl_ini			; appli init
		CLR.L -(SP)
		MOVE #$20,-(SP)	
		TRAP #1				; supervisor mode
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		MOVE.L USP,A0
		MOVE.L A0,oldusp
		
		LEA my_stack,SP			; our own stack.
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_stuff		; save palette
		MOVE #4,-(SP)
		TRAP #14			; get rez
		ADDQ.L #2,SP
		CMP.W #2,D0
		BEQ exit			; exit if in hirez
		MOVE.W D0,oldres
		DC.W $A00A			; hide mouse
		BSR set_screen			; setup the screen
		MOVE #1,-(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE #$777,D7
.fadedownfirst	BSR Wait_Vbl
		BSR Wait_Vbl
		MOVE.W D7,$FFFF8240.W
		SUB #$111,D7
		BGE.S .fadedownfirst
		MOVE.L #$00000777,$FFFF8240.W
		MOVE.L #$00000777,$FFFF8244.W
		BSR Wait_Vbl
		BSR Ste_Test
		BSR Init_Voltab			; initialise volume table.
		BSR tables_init2
		move.w #$19,-(a7)
		trap #1
		addq.l #2,a7
		add.b #"A",d0
		move.b d0,path
		and.w #$1F,d0
		move.w d0,-(a7)
		pea path+2(pc)
		move.w #$47,-(a7)
		trap #1
		addq.l #8,a7
		bsr Concate_path2
.select		BSR Wait_Vbl
		MOVE.L log_base(PC),A0
		BSR clsfast			; clear the screen
		MOVE.B #0,txpos
		MOVE.B #1*8,typos		; tell 'em to select
		LEA selecttext(PC),A0		; a file!
		BSR print			

		DC.W $A009
		BSR fileselect			; select a file
		TST int_out+2
		BEQ exit 			; <cancel> exits.
		DC.W $A00A
		BSR Wait_Vbl
		MOVE.L log_base(PC),A0
		BSR clsfast			; clear the screen
		MOVE.B #25,txpos		; and print
		MOVE.B #12*8,typos		; 'loading'
		LEA loading(PC),A0		; file xxxxxx 
		BSR print			

.loadit		BSR Concate_path	
		LEA path_n_name(PC),A4
		LEA mt_data,A5
		MOVE.L #1000000,D7
		BSR Load_file			; load the file
		TST.B errorflag
		BNE.S .select
		LEA (A5),A0
.test_packmdat	CMP.L #'ICE!',(A0)		; is it packed?
		BNE.S .no_icemdat
		MOVE.B #25,txpos		; print
		MOVE.B #12*8,typos		; 'decrunching'
		LEA decrunching(PC),A0		; file xxxxxx 
		BSR print			
		LEA (A5),A0
		BSR ice_decrunch		; do the decrunch
		BRA .decrunchedmdat
.no_icemdat
		moveq #2,d1
		cmp.l #"PP20",(a0)+
		dbeq d1,.no_icemdat+2
		bne.s .decrunchedmdat
		move.b d0,d1
		and.b #$3,d1
		bne.s .decrunchedmdat
		move.l a0,-(a7)
		MOVE.B #27,txpos		; print
		MOVE.B #12*8,typos		; 'depacking'
		LEA depacking(PC),A0		; file xxxxxx 
		BSR print
		move.l (a7)+,a0
		lea (a5,d0.l),a1
		lea 256(a5),a2
		bsr PP20_DECRUNCH
		lea (a5),a0
		lea 256(a5),a1
		move.l d0,d1
.movelpmdat
		subq.l #1,d1
		bmi.s .decrunchedmdat
		move.b (a1)+,(a0)+
		bra.s .movelpmdat
.decrunchedmdat
		LEA (A5),A0
		cmp.l #"TFMX",(A0)+
		bne .select
*		cmp.l #"-SON",(A0)+
*		bne .select
*		cmp.w #"G ",(A0)+
*		bne .select
		LEA filename(PC),A4
.getend		tst.b (a4)+
		bne.s .getend
.getdot		cmp.b #'.',-(a4)
		bne.s .getdot
		addq.l #1,a4
		move.b #"S",(a4)+
		move.b #"M",(a4)+
		move.b #"P",(a4)+
		sf (a4)+
		MOVE.L #mt_data,d1
		MOVE.L d1,tmp1adr
		ADD.L d1,d0
		MOVE.L d0,tmp2adr
		MOVE.L d0,a5
		MOVE.B #25,txpos		; and print
		MOVE.B #12*8,typos		; 'loading'
		LEA loading(PC),A0		; file xxxxxx 
		BSR print			
		BSR Concate_path
		LEA path_n_name(PC),a4
		MOVE.L #$3FFFFE,d7
		BSR Load_file
		TST.B errorflag
		BNE .select			; reselect on errror.
		LEA (A5),A0
.test_pack	CMP.L #'ICE!',(A0)		; is it packed?
		BNE.S .no_ice
		MOVE.B #25,txpos		; print
		MOVE.B #12*8,typos		; 'decrunching'
		LEA decrunching(PC),A0		; file xxxxxx 
		BSR print			
		LEA (A5),A0
		BSR ice_decrunch		; do the decrunch
		BRA .decrunched
.no_ice
		moveq #2,d1
		cmp.l #"PP20",(a0)+
		dbeq d1,.no_ice+2
		bne.s .decrunched
		move.b d0,d1
		and.b #$3,d1
		bne.s .decrunched
		move.l a0,-(a7)
		MOVE.B #27,txpos		; print
		MOVE.B #12*8,typos		; 'depacking'
		LEA depacking(PC),A0		; file xxxxxx 
		BSR print
		move.l (a7)+,a0
		lea (a5,d0.l),a1
		lea 256(a5),a2
		bsr PP20_DECRUNCH
		lea (a5),a0
		lea 256(a5),a1
		move.l d0,d1
.movelp
		subq.l #1,d1
		bmi.s .decrunched
		move.b (a1)+,(a0)+
		bra.s .movelp
.decrunched
		BSR Test_for_8_vs
		BSR Wait_Vbl
		CLR.B txpos
		CLR.B typos
		LEA thetext(PC),A0		; main text
		BSR print			; draw text
		MOVE.W Which_replay(PC),D0
		and.w #$7,D0
		BSR Update_Outputpt		; draw pointer to output

		bsr STspecific

		BSR tfmx_base+0			init the player
		MOVE.L tmp1adr,d0
		MOVE.L tmp2adr,d1
		BSR tfmx_base+20		init the module
		BSR display_songnum
		BSR display_temponum
		ifne NEATO
		BSR display_instnum
		endc

		BSR init_ints			start ints
		move.w #$1E,songnum		load last song into ctr
		move.b #$CD,key			for first valid tune

.waitk
		ifne	NEATO
		BSR tfmx_base+44
		tst.b $15(a0)
		beq .notdisp
		sf $15(a0)
		moveq #-12,d6
.bratwurst
		lea tfmx_parms2,a0
		lea .listtab(PC),a3
		moveq #7,d5
.braful
		move.w p2_pattidx(a0),d0
		move.w p2_pattctr(a0),d1
*		cmp.w p2_lpattidx(a0),d0
*		bne.s .breasts
*		cmp.w p2_lpattctr(a0),d1
*		beq.s .braless
.breasts
		move.w d0,p2_lpattidx(a0)
		move.w d1,p2_lpattctr(a0)
		move.l p2_pattptr(a0),a1
		lea .hextab(PC),a4
		add.w d6,a1
		add.w d1,d1
		add.w d1,d1
		move.l (a1,d1.w),d2
		moveq #7,d3
.digitman
		rol.l #4,d2
		move.b d2,d4
		and.w #$F,d4
		move.b (a4,d4.w),(a3)+
		dbf d3,.digitman
		bra.s .d_cup
.braless
		addq.w #8,a3
.d_cup
		addq.w #4,a0
		addq.w #2,a3
		dbf d5,.braful
		bra.s .disper
.longtemp
		dc.l	0
.listtab
 dc.b "         |         |         |         |"
 dc.b "         |         |         |         ",0
.hextab
		dc.b "0123456789ABCDEF"
		even
.disper
		move.w d6,-(a7)
		move.b #0,txpos
		add.w d6,d6
		add.b #23*8,d6
		move.b d6,typos
		move.w (a7)+,d6
		lea .listtab(pc),a0
		bsr print
		addq.w #4,d6
		ble .bratwurst
		endc
.notdisp
		tst.b ciatempochg
		beq.s .brian
		sf ciatempochg
		bsr display_temponum
.brian
		MOVE.B key(PC),D0
		CMP.B #$3B+$80,D0		; lower than F1?
		BLT.S .notfunk
		CMP.B #$42+$80,d0		; higher than f7?
		BGT.S .notfunk
		AND #$7F,D0
		sf key
		SUB #$3B,D0			; normalise
		move.w Which_replay(PC),d1
		and.w #7,d1
		CMP.W d1,D0
		BEQ .waitk			; same as already playing?
		BSR Update_Outputpt		; update onscreen pointer
		BSR Select_PlayRout		; select new rout
		BRA .waitk
.notfunk
		cmp.b #$0F+$80,d0
		bne.s .notbksp
		move.l #$040040,d0
		bsr tfmx_base+40
		sf key
		bra .waitk
.notbksp
		ifne	NEATO
		CMP.B #$4A+$80,D0
		BNE.S .notminus
		subq.w #1,instrx
		bsr display_instnum
		sf key
		bra .waitk
.notminus
		CMP.B #$4E+$80,D0
		BNE.S .notplus
		addq.w #1,instrx
		bsr display_instnum
		sf key
		bra .waitk
.notplus
		CMP.B #2+$80,D0
		BLO.S .notplay
		CMP.B #11+$80,D0
		BHS.S .notplay
		CMP.B #10+$80,D0
		BEQ.S .nostop
		move.w d0,-(a7)
		moveq #1,d0
		bsr tfmx_base+32
		move.w (a7)+,d0
.nostop
		and.w #$0F,d0
		subq.b #2,d0
		add.w d0,d0
		add.w d0,d0
		move.l .notetbl(PC,d0.w),d0
		moveq #0,d1
		move.b voices,d1
		lsl.w #7,d1
		or.w d1,d0
		swap.w d0
		bra.s .nottbl
.notetbl
		dc.l $1A00F300
		dc.l $1C00F300
		dc.l $1E00F300
		dc.l $1F00F300
		dc.l $2100F300
		dc.l $2300F300
		dc.l $2500F300
		dc.l $2600F300
		dc.l $F5000300
.nottbl
		add.w instrx,d0
		swap.w d0
		bsr tfmx_base+16
		sf key
		bra .waitk
.notplay
		CMP.B #11+$80,D0
		BNE.S .notstopn
		moveq #1,d0
		bsr tfmx_base+32
		sf key
		bra .waitk
.notstopn
		endc
		CMP.B #$4B+$80,D0
		BNE.S .notleft
		clr.b key
.lfbad
		subq.w #1,songnum
		and.w #$1F,songnum
		move.w songnum,d0
		cmp.b #$1F,d0
		beq.s .lfbad
		move.l tmp1adr,a0
		add.w d0,a0
		add.w d0,a0
		tst.w $140(A0)
		ble.s .lfbad
		bsr tfmx_base+12
		bsr display_songnum
		BRA .waitk
.notleft	CMP.B #$4D+$80,D0
		BNE.S .notright
		clr.b key
.rtbad
		addq.w #1,songnum
		and.w #$1F,songnum
		move.w songnum,d0
		cmp.b #$1F,d0
		beq.s .rtbad
		move.l tmp1adr,a0
		add.w d0,a0
		add.w d0,a0
		tst.w $140(A0)
		ble.s .rtbad
		bsr tfmx_base+12
		bsr display_songnum
		BRA .waitk
.notright
		CMP.B #$50+$80,D0
		bne.s .notdn
		subq.w #1,ciatempo
		cmp.w #31,ciatempo
		bne .clopd
		move.w #32,ciatempo
		clr key
		bra .waitk
.clopd
		move.l #1790456,d1
		divu.w ciatempo,d1
		move.w d1,-(a7)
		bsr tf_settempo
		addq.l #2,a7
		sf key
		bra .waitk
.notdn
		CMP.B #$48+$80,D0
		bne.s .notup
		addq.w #1,ciatempo
		cmp.w #256,ciatempo
		bne .clopu
		move.w #255,ciatempo
		clr key
		bra .waitk
.clopu
		move.l #1790456,d1
		divu.w ciatempo,d1
		move.w d1,-(a7)
		bsr tf_settempo
		addq.l #2,a7
		sf key
		bra .waitk
.notup
		CMP.B #$47+$80,D0
		bne.s .not60h
		move.w #150,ciatempo
		move.l #1790456,d1
		divu.w ciatempo,d1
		move.w d1,-(a7)
		bsr tf_settempo
		addq.l #2,a7
		sf key
		bra .waitk
.not60h
		CMP.B #$52+$80,D0
		bne.s .not50h
		move.w #125,ciatempo
		move.l #1790456,d1
		divu.w ciatempo,d1
		move.w d1,-(a7)
		bsr tf_settempo
		addq.l #2,a7
		sf key
		bra .waitk
.not50h
		CMP.B #$39+$80,D0		; space exits.
		BNE .waitk
		moveq.l #15,d0
		swap.w d0
		bsr tfmx_base+40
		bsr tfmx_base+44
		lea tfmx_parms,a6
.waitfade
		tst.b p1_playflag(a6)
		beq.s .fadedone
		tst.w (a0)
		bne.s .waitfade
.fadedone

		BSR restore_ints		; restore gem..

		BRA .select			; select another file...

songnum		dc.w	0
ciatempo	dc.w	50
ciatempochg	dc.w	0
instrx		dc.w	0
voices		dc.w	0

pd		dc.w	50

tables_init2
; generate the Ami frequency conversion table and lookup table for note
; values (for finetune purposes)
	movem.l	d0-d7/a0-a6,-(a7)
	lea	freqs+8192,a0
	move.l	#2047,d0
	move.l	#$5D37A,d6		the constant!!!
	move.l	d6,d7
	mulu.w	pd,d6
	swap.w	d7
	mulu.w	pd,d7
	swap.w	d7
	add.l	d6,d7
.no0_lp
	move.l	d7,d1
	move.l	d1,d2
	clr.w	d1
	swap.w	d1
	cmp.w	d1,d0
	bgt.s	.no1
	swap.w	d2
	clr.w	d2
	swap.w	d2
	divu.w	d0,d1		d'h=b/a
	move.l	d1,d3
	clr.w	d3
	add.l	d3,d2
	divu.w	d0,d2
	swap.w	d2
	clr.w	d2
	add.l	d2,d1
	swap.w	d1
	bra.s	.no2
.no1
	divu.w	d0,d2
	moveq	#0,d1
	move.w	d2,d1
.no2
	move.l	d1,-(a0)
	subq.w	#1,d0
	bne.s	.no0_lp
	clr.l	-(a0)
	movem.l	(a7)+,d0-d7/a0-a6
	rts


exit		MOVE oldres(PC),-(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVEM.L old_stuff(PC),D0-D7	; restore palette
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.L oldsp(PC),-(SP)
		MOVE #$20,-(SP)	
		TRAP #1				; user mode
		ADDQ.L #6,SP
		BSR appl_exi			; appli exit.
.redir		PEA dummy(PC)
		MOVE.W #$4e,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		CLR.W -(SP)			; Get dir.
		PEA dir
		MOVE.W #$47,-(SP)
		TRAP #1
		ADDQ.L #8,SP
		CLR -(SP)
		TRAP #1

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff+32(PC),A0
		MOVE.B (mfp_iera).W,(A0)+
		MOVE.B (mfp_ierb).W,(A0)+
		MOVE.B (mfp_imra).W,(A0)+
		MOVE.B (mfp_imrb).W,(A0)+	; Save mfp registers 
		MOVE.B (mfp_tbcr).W,(A0)+
		MOVE.B (mfp_tcdcr).W,(A0)+
		MOVE.B (mfp_tbdr).W,(A0)+
		MOVE.B (mfp_tddr).W,(A0)+
		MOVE.L (mfp_itb).W,(A0)+		; save some vectors
		MOVE.L (mfp_iio4).W,(A0)+
		MOVE.L (mfp_itd).W,(A0)+
		MOVE.B #$01,(mfp_iera).W
		MOVE.B #$50,(mfp_ierb).W
		MOVE.B #$01,(mfp_imra).W
		MOVE.B #$50,(mfp_imrb).W
		BCLR.B #3,(mfp_vr).W		; software end of int.
		MOVE.B #0,(mfp_tbcr).W
		MOVE.B #0,(mfp_tcdcr).W
		MOVE.B #246,(mfp_tddr).W	till TFMX sez otherwise
		MOVE.B #7,(mfp_tcdcr).W
		LEA my_vbl(PC),A0
		MOVE.L A0,(mfp_itd).W		; set our vbl
		LEA key_rout(PC),A0
		MOVE.L A0,(mfp_iio4).W		; and our keyrout.
		MOVE Which_replay(PC),D0
		and.w #$7,d0
		MOVE #16,Which_replay
		BSR Select_PlayRout
		CLR key			
		LEA sndbuff1(PC),A1
		move.l a1,loc
		MOVE.B #1,(mfp_tbcr).W
		MOVE #$2500,SR
		MOVEQ #$11,D0			; resume sending
		BSR Writeikbd
		MOVEQ #$12,D0			; kill mouse
		BSR Writeikbd
		BSR flush
		RTS
.rte
		RTE
; Restore mfp vectors and ints.

restore_ints	MOVE.L oldusp(PC),A0
		MOVE.L A0,USP
		MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff+32(PC),A0
		MOVE.B (A0)+,(mfp_iera).W
		MOVE.B (A0)+,(mfp_ierb).W
		MOVE.B (A0)+,(mfp_imra).W
		MOVE.B (A0)+,(mfp_imrb).W	; restore mfp
		bclr.b #4,(mfp_ierb).w
		bclr.b #4,(mfp_imrb).w
		bclr.b #0,(mfp_iera).w
		bclr.b #0,(mfp_imra).w
		bset.b #5,(mfp_ierb).w
		bset.b #5,(mfp_imrb).w
		MOVE.B (A0)+,(mfp_tbcr).W
		tst.b (a0)+
		move.b #$50,(mfp_tcdcr).w
		move.b #$C0,(mfp_tcdr).w
		MOVE.B (A0)+,(mfp_tbdr).W
		MOVE.B (A0)+,(mfp_tddr).W
		MOVE.L (A0)+,(mfp_itb).W
		MOVE.L (A0)+,(mfp_iio4).W
		MOVE.L (A0)+,(mfp_itd).W
		BSET.B #3,(mfp_vr).W
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume
		BSR Writeikbd		
		MOVEQ #$8,D0			; restore mouse.
		BSR Writeikbd
		BSR flush
		RTS

; Wait for a vbl..

Wait_Vbl	MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		RTS

old_stuff:	DS.L 22
oldres		DS.W 1
oldsp		DS.L 1
oldusp		DS.L 1
tmp1adr		DS.L 1
tmp2adr		DS.L 1

; Flush IKBD

flush		BTST.B #0,$FFFFFC00.W		; any waiting?
		BEQ.S .flok			; exit if none waiting.
		MOVE.B $FFFFFC02.W,D0		; get next in queue
		BRA.S flush			; and continue
.flok		RTS

; Write d0 to IKBD

Writeikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Writeikbd			; wait for ready
		MOVE.B D0,$FFFFFC02.W		; and send...
		RTS

; Keyboard handler interrupt routine...

key_rout	MOVE #$2500,SR			; ipl 5 for 'cleanness' 
		MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0			; int req?
		BEQ.S .end			
		BTST #0,D0			; 
		BEQ.S .end
		MOVE.B $FFFFFC02.W,key		; store keypress
.end		MOVE (SP)+,D0
		RTE
key		DC.W 0

; Init screen - and clear it too.

set_screen	MOVE.W #2,-(SP)
		TRAP #14			; get phybase
		ADDQ.L #2,SP
		MOVE.L D0,log_base		; store it.
		MOVE.L D0,A0			; fall thru and clear screen

; Clear screen ->A0
		
clsfast		MOVEQ #0,D0
		MOVE #(32000/32)-1,D1
.cls		REPT 8
		MOVE.L D0,(A0)+
		ENDR 
		DBF D1,.cls
		RTS

log_base	DC.L 0				; screen ptr

; Load a file of D7 bytes, Filename at A4 into address A5.

Load_file	SF errorflag			; assume no error!
		MOVE #2,-(SP)
		MOVE.L A4,-(SP)
		MOVE #$3D,-(SP)
		TRAP #1				; open da file
		ADDQ.L #8,SP
		TST.L D0
		BMI.S .error
		MOVE D0,D4
.read		MOVE.L A5,-(SP)
		MOVE.L D7,-(SP)
		MOVE D4,-(SP)
		MOVE #$3F,-(SP)
		TRAP #1				; read da file
		LEA 12(SP),SP
		TST.L D0
		BMI.S .error
		move.l	d0,-(a7)
.close		MOVE D4,-(SP)
		MOVE #$3E,-(SP)
		TRAP #1				; close da file!
		ADDQ.L #4,SP
		move.l (a7)+,d0
		RTS
 
.error		ST errorflag			; shit a load error!
		RTS

errorflag	DC.W 0

; Ice 2.31 Decrunch Rout. A0 -> packed data.

ice_decrunch:	link a3,#-120
		movem.l	d0-a6,-(sp)
		lea 120(a0),a4		; a4 = Anfang entpackte Daten
		move.l a4,a6		; a6 = Ende entpackte Daten
		bsr.s .getinfo
		cmpi.l #'ICE!',d0	; Kennung gefunden?
		bne .not_packed
		bsr.s .getinfo		; gepackte L„nge holen
		lea.l -8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
		bsr.s .getinfo		; ungepackte L„nge holen (original)
		move.l d0,(sp)		; Originall„nge: sp„ter nach d0
		adda.l d0,a6		; a6 = Ende entpackte Daten
		move.l a6,a1

		moveq #119,d0		; 120 Bytes hinter entpackten Daten
.save:		move.b -(a1),-(a3)	; in sicheren Bereich sichern
		dbf d0,.save
		move.l a6,a3		; merken fr Picture decrunch
		move.b -(a5),d7		; erstes Informationsbyte
		bsr.s .normal_bytes
		move.l a3,a5		; fr 120 Bytes restore

.no_picture	movem.l	(sp),d0-a3	; hole n”tige Register

.move		move.b (a4)+,(a0)+
		subq.l #1,d0
		bne.s .move
		moveq #119,d0		; um berschriebenen Bereich
.rest		move.b -(a3),-(a5)	; wieder herzustellen
		dbf d0,.rest
.not_packed:	movem.l	(sp)+,d0-a6
		unlk a3
		rts

.getinfo: 	moveq #3,d1		; ein Langwort vom Anfang
.getbytes: 	lsl.l #8,d0		; der Daten lesen
		move.b (a0)+,d0
		dbf d1,.getbytes
		rts

.normal_bytes:	bsr.s .get_1_bit
		bcc.s .test_if_end	; Bit %0: keine Daten
		moveq.l	#0,d1		; falls zu copy_direkt
		bsr.s .get_1_bit
		bcc.s .copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
		lea.l .direkt_tab+20(pc),a1
		moveq.l	#4,d3
.nextgb:	move.l -(a1),d0		; d0.w Bytes lesen
		bsr.s .get_d0_bits
		swap.w d0
		cmp.w d0,d1		; alle gelesenen Bits gesetzt?
		dbne d3,.nextgb		; ja: dann weiter Bits lesen
.no_more: 	add.l 20(a1),d1 	; Anzahl der zu bertragenen Bytes
.copy_direkt:	move.b -(a5),-(a6)	; Daten direkt kopieren
		dbf d1,.copy_direkt	; noch ein Byte
.test_if_end:	cmpa.l	a4,a6		; Fertig?
		bgt.s .strings		; Weiter wenn Ende nicht erreicht
		rts	

.get_1_bit:	add.b d7,d7		; hole ein bit
		bne.s .bitfound 	; quellfeld leer
		move.b -(a5),d7		; hole Informationsbyte
		addx.b d7,d7
.bitfound:	rts	

.get_d0_bits:	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:	add.b d7,d7		; hole ein bit
		bne.s .on_d0		; in d7 steht noch Information
		move.b -(a5),d7		; hole Informationsbyte
		addx.b d7,d7
.on_d0:		addx.w d1,d1		; und bernimm es
		dbf d0,.hole_bit_loop  	; bis alle Bits geholt wurden
		rts	

.strings: 	lea.l .length_tab(pc),a1 ; a1 = Zeiger auf Tabelle
		moveq.l	#3,d2		 ; d2 = Zeiger in Tabelle
.get_length_bit:bsr.s .get_1_bit
		dbcc d2,.get_length_bit	; n„chstes Bit holen
.no_length_bit:	moveq.l	#0,d4		; d4 = šberschuž-L„nge
		moveq.l	#0,d1
		move.b 1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
		ext.w d0		; als Wort behandeln
		bmi.s .no_ber		; kein šberschuž n”tig
.get_ber:	bsr.s .get_d0_bits
.no_ber:	move.b 6(a1,d2.w),d4	; Standard-L„nge zu šberschuž add.
		add.w d1,d4		; d4 = String-L„nge-2
		beq.s .get_offset_2	; L„nge = 2: Spezielle Offset-Routine

		lea.l .more_offset(pc),a1 ; a1 = Zeiger auf Tabelle
		moveq.l	#1,d2
.getoffs: 	bsr.s .get_1_bit
		dbcc d2,.getoffs
		moveq.l	#0,d1		; Offset-šberschuž
		move.b 1(a1,d2.w),d0	; request d0 Bits
		ext.w d0		; als Wort
		bsr.s .get_d0_bits
		add.w d2,d2		; ab jetzt: Pointer auf Worte
		add.w 6(a1,d2.w),d1	; Standard-Offset zu šberschuž add.
		bpl.s .depack_bytes	; keine gleiche Bytes: String kop.
		sub.w d4,d1		; gleiche Bytes
		bra.s .depack_bytes


.get_offset_2:	moveq.l	#0,d1		; šberschuž-Offset auf 0 setzen
		moveq.l	#5,d0		; standard: 6 Bits holen
		moveq.l	#-1,d2		; Standard-Offset auf -1
		bsr.s .get_1_bit
		bcc.s .less_40		; Bit = %0
		moveq.l	#8,d0		; quenty fourty: 9 Bits holen
		moveq.l	#$3f,d2		; Standard-Offset: $3f
.less_40: 	bsr.s .get_d0_bits
		add.w d2,d1		; Standard-Offset + šber-Offset

.depack_bytes:				; d1 = Offset, d4 = Anzahl Bytes
		lea.l 2(a6,d4.w),a1	; Hier stehen die Originaldaten
		adda.w	d1,a1		; Dazu der Offset
		move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:		move.b	-(a1),-(a6)	; mehr Bytes kopieren
		dbf d4,.dep_b 		; und noch ein Mal
		bra .normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
		dc.l 270-1,15-1,8-1,5-1,2-1	; Anz. Bytes

.length_tab:	dc.b 9,1,0,-1,-1	; Bits lesen
		dc.b 8,4,2,1,0		; Standard-L„nge - 2 (!!!)
.more_offset:	dc.b 11,4,7,0		; Bits lesen
		dc.w $11f,-1,$1f	; Standard Offset

* Prepare registers as follows:
* A0=points to just after the "PP20" longword
* A1=points just past the end of the packed data
* A2=points to the destination area

PP20_DECRUNCH:
	movem.l	d0-d7/a0-a6,-(a7)
	MOVEA.L	A2,A4
	MOVE.L	-(A1),D0
	MOVEQ	#0,D1
	MOVE.B	D0,D1
	LSR.L	#8,D0
	move.l	d0,(a7)
	ADDA.L	D0,A4
	MOVE.L	-(A1),D2
	MOVEQ	#$20,D3
	TST.W	D1
	BEQ.B	.pp_loop
	SUBQ.W	#1,D1
	BSR	.pp_getbits
.pp_loop:
	DBF	D3,.pp_mainsk
	MOVE.L	-(A1),D2
	MOVEQ	#$1F,D3
.pp_mainsk:
	LSR.L	#1,D2
	BCS.B	.pp_unpack
	MOVEQ	#0,D4
.pp_loadunravctr:
	MOVEQ	#1,D1
	BSR	.pp_getbits
	ADD.W	D0,D4
	SUBQ.W	#3,D0
	BEQ.B	.pp_loadunravctr
.pp_unravel:
	SUBQ.W	#8,D3
	BMI.B	.pp_unravel2
	LSR.L	#1,D2
	ROXL.W	#1,D0
	LSR.L	#1,D2
	ROXL.W	#1,D0
	LSR.L	#1,D2
	ROXL.W	#1,D0
	LSR.L	#1,D2
	ROXL.W	#1,D0
	LSR.L	#1,D2
	ROXL.W	#1,D0
	LSR.L	#1,D2
	ROXL.W	#1,D0
	LSR.L	#1,D2
	ROXL.W	#1,D0
	LSR.L	#1,D2
	ROXL.W	#1,D0
.pp_unravelmore:
	MOVE.B	D0,-(A4)
	DBF	D4,.pp_unravel
	CMPA.L	A4,A2
	BCC.B	.pp_done
.pp_unpack:
	MOVEQ	#1,D1
	BSR.B	.pp_getbits
	MOVEQ	#0,D1
	MOVE.B	0(A0,D0.W),D1
	SUBQ.W	#1,D1
	MOVE.W	D0,D4
	ADDQ.W	#1,D4
	SUBQ.W	#3,D0
	BMI.B	.pp_defaultsize
	DBF	D3,.pp_findsize_sk
	MOVE.L	-(A1),D2
	MOVEQ	#$1F,D3
.pp_findsize_sk:
	LSR.L	#1,D2
	BCS.B	.pp_usevrblsize
	MOVEQ	#6,D1
.pp_usevrblsize:
	BSR.B	.pp_getbits
	LEA	1(A4,D0.W),A3
.pp_howmany:
	MOVEQ	#2,D1
	BSR.B	.pp_getbits
	ADD.W	D0,D4
	SUBQ.W	#7,D0
	BEQ.B	.pp_howmany
	BRA.B	.pp_copybytes_lp
.pp_defaultsize:
	BSR.B	.pp_getbits
	LEA	1(A4,D0.W),A3
.pp_copybytes_lp:
	MOVE.B	-(A3),-(A4)
	DBF	D4,.pp_copybytes_lp
	CMPA.L	A4,A2
	BCS	.pp_loop
.pp_done:
	movem.l	(a7)+,d0-d7/a0-a6
	RTS	
.pp_unravel2:
	ADDQ.W	#8,D3
	MOVEQ	#7,D1
.pp_unravel2_lp:
	DBF	D3,.pp_unravel2_sk
	MOVE.L	-(A1),D2
	MOVEQ	#$1F,D3
.pp_unravel2_sk:
	LSR.L	#1,D2
	ROXL.W	#1,D0
	DBF	D1,.pp_unravel2_lp
	BRA.B	.pp_unravelmore
.pp_getbits:
	MOVEQ	#0,D0
.pp_getbits_lp:
	DBF	D3,.pp_getbits_sk
	MOVE.L	-(A1),D2
	MOVEQ	#$1F,D3
.pp_getbits_sk:
	LSR.L	#1,D2
	ROXL.W	#1,D0
	DBF	D1,.pp_getbits_lp
	RTS	


; Routines for VDI and AES access By Martin Griffiths 1990
; Call appl_ini at start of a program and appl_exi before terminating.

; AES call for gemdos fileselector routine.

fileselect	LEA control(PC),A0
		MOVE.W #90,(A0)+
		MOVE.W #0,(A0)+
		MOVE.W #2,(A0)+
		MOVE.W #2,(A0)+
		MOVE.L #path,addr_in
		MOVE.L #filename,addr_in+4
		BSR AES
		RTS

dummy:		DC.B '*.*',0
path		DC.B "X:\*.MDA",0
		DS.B 100
wild		dc.b "\*.MDA",0
		EVEN
loading		DC.B "    Loading : "
filename	DS.B 64
path_n_name	DS.W 64

; VDI subroutine call.

VDI		LEA VDIparblock(PC),A0
		MOVE.L #contrl,(A0)
		MOVE.L A0,D1
		MOVEQ #115,D0
		TRAP #2
		RTS

; AES subroutine call.

AES		LEA AESparblock(PC),A0
		MOVE.L #control,(A0)
		MOVE.L A0,D1
		MOVE.L #200,D0
		TRAP #2
		RTS

; 1st BDOS call is APPL_INI

appl_ini	LEA control(PC),A0
		MOVE #10,(A0)+
		MOVE #0,(A0)+
		MOVE #1,(A0)+
		MOVE #0,(A0)+
		BRA AES

; Last BDOS call is APPL_EXI

appl_exi	LEA control(PC),A0
		MOVE #19,(A0)+
		MOVE #0,(A0)+
		MOVE #1,(A0)+
		MOVE #0,(A0)+
		BRA AES

; VDI & AES Reserved arrays

VDIparblock	DC.L contrl
		DC.L intin
		DC.L ptsin
		DC.L intout
		DC.L ptsout
		
contrl		DS.W 12
intin		DS.W 30
ptsin		DS.W 30
intout		DS.W 45
ptsout		DS.W 12

AESparblock	DC.L control
		DC.L global
		DC.L int_in
		DC.L int_out
		DC.L addr_in
		DC.L addr_out 
control		DS.W 5
global		DS.W 16
int_in		DS.W 16
int_out		DS.W 7
addr_in		DS.L 2
addr_out	DS.L 1

; The Gem Fileselector returns a path and filename as seperate strings
; - this rout concatenates the two strings together into one (for loading).

Concate_path	LEA path(PC),A1
		MOVE.L A1,A0
.find_end	TST.B (A0)+		; search for end of path
		BNE.S .find_end
.foundit	CMP.B #'\',-(A0)	; now look back for slash
		BEQ.S .foundslash	
		CMP.L A1,A0		; (or if we reach start of path)
		BNE.S .foundit
.foundslash	SUB.L A1,A0		; number of bytes
		MOVE.W A0,D0
		LEA path_n_name(PC),A0
		TST.W D0
		BEQ.S .nonetodo		; if zero then not in subdir
.copypath	MOVE.B (A1)+,(A0)+	; copy path
		DBF D0,.copypath	
.nonetodo	LEA filename(PC),A1
.copy_filename	MOVE.B (A1)+,(A0)+	; concatenate file name
		BNE.S .copy_filename
		RTS

; This routine catenates the wildcard onto the end of the pathname as
; returned by Dgetpath().

Concate_path2
		lea path+2(PC),a1
.gitit
		tst.b (a1)+
		bne.s .gitit
		subq.l #1,a1
		lea wild(PC),a0
.gotit
		move.b (a0)+,(a1)+
		bne.s .gotit
		RTS

; This routine displays the tempo on the screen.

display_temponum
		lea .tempomsg,a0
		moveq #0,d0
		move.w ciatempo,d0
		divu.w #10,d0
		swap.w d0
		move.b d0,2(a0)
		clr.w d0
		swap.w d0
		divu.w #10,d0
		move.b d0,(a0)
		swap.w d0
		move.b d0,1(a0)
		tst.b (a0)
		beq.s .no100
		add.b #$30,(a0)
		bra.s .prant
.no100
		move.b #$20,(a0)
		tst.b 1(a0)
		beq.s .no10
.prant
		add.b #$30,1(a0)
		bra.s .print
.no10
		move.b #$20,1(a0)
.print
		add.b #$30,2(a0)
		move.b #47,txpos
		move.b #19*8,typos
		LEA .tempotext,A0
		BSR print
		rts

.tempotext
		dc.b "Tempo = "
.tempomsg
		dc.b "   bpm",0
		even

display_songnum
		MOVE.B #37,txpos
		MOVE.B #19*8,typos
		MOVE.W songnum,d0
		ADD.W d0,d0
		MOVE.W .list(PC,D0.w),.body
		lea .body(PC),a0
		BSR print
		RTS

.list
	dc.b	" 0 1 2 3 4 5 6 7 8 910111213141516171819202122232425262728293031"
.body
	dc.l	0

; This routine displays the instrument number selected at the bottom of
; the screen, just below the instruction line.

display_instnum
		move.b #39,txpos
		move.b #18*8,typos
		move.w instrx,d0
		ror.w #4,d0
		cmp.b #9,d0
		ble.s .blah
		addq.b #7,d0
.blah
		add.b #$30,d0
		move.b d0,.inst
		sf d0
		rol.w #4,d0
		cmp.b #9,d0
		ble.s .blah2
		addq.b #7,d0
.blah2
		add.b #$30,d0
		move.b d0,.inst+1
		move.l #.inst,a0
		bsr print
		rts
.inst
		dc.l	0

; This routine goes through the mod and looks for voice numbers greater
; than 3.  If there are any the search aborts and voices is set to 8.  If
; not, voices is set to 0.

Test_for_8_vs
	move.b	#8,voices
	move.l	tmp1adr,a0
	tst.l	$1D0(a0)
	beq.s	.abort0srch
	move.l	$1D4(a0),a1
	move.l	$1D8(a0),a2
	add.l	a0,a1
	add.l	a0,a2
.lp1
	cmp.l	a1,a2
	beq.s	.abort0srch
	move.l	(a1)+,a3
	add.l	a0,a3
.lp2
	move.l	(a3)+,d1
	rol.l	#8,d1
	cmp.b	#$F0,d1
	beq.s	.lp1
	cmp.b	#$C0,d1
	bge.s	.lp2
	swap.w	d1
	and.b	#$F,d1
	cmp.b	#3,d1
	bls.s	.lp2
	rts
.abort0srch
	sf	voices
	rts

; This routine updates the little pointer which shows you which Output
; rout is currently active. It deletes the old arrow and draws the new.

Update_Outputpt:
		MOVE.W Which_replay(PC),D1
		and.w #7,d1
		LSL #3,D1
		ADD.W #9*8,D1
		MOVE.B #25,txpos
		MOVE.B D1,typos
		LEA space(PC),A0
		BSR print			; print space over old one
		MOVE.W D0,D1
		LSL #3,D1
		ADD.W #9*8,D1
		MOVE.B #25,txpos
		MOVE.B D1,typos
		LEA reppoint(PC),A0
		BSR print			; and draw new one
		RTS

space		DC.B 32,0
reppoint	DC.B 128,0

; Print Rout -> Text address in A0...  Uses TXPOS and TYPOS (.B)
; 1 (in text) = Inverse text, else normal.
; 2 (in text) = Normal text.
; Returns with LASTPTR holding last address after 0 termination.

print:		movem.l	d0-d4/a0/a2-a3,-(sp)
		moveq	#0,d2
printline:
		move.b	(a0)+,d0
		bne.s	notend
		move.l	a0,lastptr
		movem.l	(sp)+,d0-d4/a0/a2-a3
		rts
notend:		cmpi.b	#1,d0
		bne.s	notinv
		moveq	#1,d2
		move.b	(a0)+,d0
notinv:		cmpi.b	#2,d0
		bne.s	notnorm
		moveq	#0,d2
		move.b	(a0)+,d0
notnorm:	cmpi.b	#$a,d0
		bne.s	notcr
		addq.b	#8,typos
		bra.s	printline
notcr:		cmpi.b	#$d,d0
		bne.s	notlf
		move.b	#0,txpos
		bra.s	printline
notlf:		tst.b	d2
		bne.s	inverse
		moveq   #0,D3
	        moveq   #0,D4
        	move.b  txpos(PC),D3
	        move.b  typos(PC),D4
		mulu #160,d4
	        movea.l log_base(pc),A2		; Screen
        	adda.l d4,A2
	        lea     xtab(PC),a3
        	move.b  0(a3,D3.w),D3
	        adda.w  D3,A2
        	lea     font(PC),a3
	        moveq   #0,D3
	        move.b  D0,D3
        	sub.b   #32,D3
	        lsl.w   #3,D3
        	adda.w  D3,a3
        	move.b  (a3)+,(A2)
	        move.b  (a3)+,160(A2)
        	move.b  (a3)+,320(A2)
	        move.b  (a3)+,480(A2)
        	move.b  (a3)+,640(A2)
	        move.b  (a3)+,800(A2)
        	move.b  (a3)+,960(A2)
	        move.b  (a3),1120(A2)
		addq.b	#1,txpos
		bra	printline

inverse:	moveq   #0,D3
	        moveq   #0,D4
        	move.b  txpos(PC),D3
	        move.b  typos(PC),D4
		mulu #160,d4
	        movea.l log_base(pc),A2		; Screeen
	        adda.l d4,A2
        	lea     xtab(PC),a3
	        move.b  0(a3,D3.w),D3
        	adda.w  D3,A2
        	lea     font(PC),a3
	        moveq   #0,D3
        	move.b  D0,D3
	        sub.b   #32,D3
        	lsl.w   #3,D3
	        adda.w  D3,a3
        	move.b  (a3)+,(A2)
		not.b	(a2)
        	move.b  (a3)+,160(A2)
		not.b	160(a2)
	        move.b  (a3)+,320(A2)
		not.b	320(a2)
        	move.b  (a3)+,480(A2)
		not.b	480(a2)
        	move.b  (a3)+,640(A2)
		not.b	640(a2)
	        move.b  (a3)+,800(A2)
		not.b	800(a2)
	        move.b  (a3)+,960(A2)
		not.b	960(a2)
	        move.b  (a3),1120(A2)
		not.b	1120(a2)
		addq.b	#1,txpos
		bra	printline

font:   	dc.l	$00000000,$00000000,$00181818,$18001800,$00666666 
		dc.l	$00000000,$0066FF66,$66FF6600,$183E603C,$067C1800 
		dc.l	$00666C18,$30664600,$1C361C38,$6F663B00,$00181818 
		dc.l	$00000000,$000E1C18,$181C0E00,$00703818,$18387000 
		dc.l	$00663CFF,$3C660000,$0018187E,$18180000,$00000000 
		dc.l	$00181830,$0000007E,$00000000,$00000000,$00181800 
		dc.l	$00060C18,$30604000,$003C666E,$76663C00,$00183818 
		dc.l	$18187E00,$003C660C,$18307E00,$007E0C18,$0C663C00 
		dc.l	$000C1C3C,$6C7E0C00,$007E607C,$06663C00,$003C607C 
		dc.l	$66663C00,$007E060C,$18303000,$003C663C,$66663C00 
		dc.l	$003C663E,$060C3800,$00001818,$00181800,$00001818 
		dc.l	$00181830,$060C1830,$180C0600,$00007E00,$007E0000 
		dc.l	$6030180C,$18306000,$003C660C,$18001800,$003C666E 
		dc.l	$6E603E00,$00183C66,$667E6600,$007C667C,$66667C00 
		dc.l	$003C6660,$60663C00,$00786C66,$666C7800,$007E607C 
		dc.l	$60607E00,$007E607C,$60606000,$003E6060,$6E663E00 
		dc.l	$0066667E,$66666600,$007E1818,$18187E00,$00060606 
		dc.l	$06663C00,$00666C78,$786C6600,$00606060,$60607E00 
		dc.l	$0063777F,$6B636300,$0066767E,$7E6E6600,$003C6666 
		dc.l	$66663C00,$007C6666,$7C606000,$003C6666,$666C3600 
		dc.l	$007C6666,$7C6C6600,$003C603C,$06063C00,$007E1818 
		dc.l	$18181800,$00666666,$66667E00,$00666666,$663C1800 
		dc.l	$0063636B,$7F776300,$0066663C,$3C666600,$0066663C 
		dc.l	$18181800,$007E0C18,$30607E00,$001E1818,$18181E00 
		dc.l	$00406030,$180C0600,$00781818,$18187800,$00081C36 
		dc.l	$63000000,$00000000,$0000FF00,$00183C7E,$7E3C1800 
		dc.l	$00003C06,$3E663E00,$0060607C,$66667C00,$00003C60 
		dc.l	$60603C00,$0006063E,$66663E00,$00003C66,$7E603C00 
		dc.l	$000E183E,$18181800,$00003E66,$663E067C,$0060607C 
		dc.l	$66666600,$00180038,$18183C00,$00060006,$0606063C 
		dc.l	$0060606C,$786C6600,$00381818,$18183C00,$0000667F 
		dc.l	$7F6B6300,$00007C66,$66666600,$00003C66,$66663C00 
		dc.l	$00007C66,$667C6060,$00003E66,$663E0606,$00007C66 
		dc.l	$60606000,$00003E60,$3C067C00,$00187E18,$18180E00 
		dc.l	$00006666,$66663E00,$00006666,$663C1800,$0000636B 
		dc.l	$7F3E3600,$0000663C,$183C6600,$00006666,$663E0C78 
		dc.l	$00007E0C,$18307E00,$00183C7E,$7E183C00,$18181818 
		dc.l	$18181818,$00660066,$66663E00,$08183878,$38180800 
		dc.l	$0018387E,$7E381800,$00181C7E,$7E1C1800
		dc.l	$000F1830,$363E3E06,$00F0180C,$6C7C7C60
		dc.l	$00183C7E,$18181800,$00181818,$7E3C1800

xoff		set	0
xtab:   	
		rept	40
		dc.b	xoff,xoff+1
xoff		set	xoff+4
		endr


txpos:		ds.b 1
typos:		ds.b 1

lastptr:	ds.l 1

selecttext
 dc.b "                 TFMX Pro 2.0 Replay (ST/STE), 8 voice version"
 rept 23
 dc.b $a,$d
 endr
 dc.b "                           ",1,"Please Select an MDAT File",2," "
 dc.b 0

decrunching
 dc.b "Decrunching",0
depacking
 dc.b "Depacking",0

thetext	
 dc.b $a,$d
 dc.b "                 TFMX Pro 2.0 Replay (ST/STE), 8 voice version",$d,$a,$a
 dc.b "                            Player by Chris H}lsbeck,",$d,$a
 dc.b "                    adapted by Marx Marvelous/TPPI 27 Oct 92",$d,$a
 dc.b "             Paula engine programmed by Griff of Electronic Images",$a,$d,$a,$d
 dc.b "                                ",1,"Output Options",2,$a,$d,$a,$d
 dc.b "                           [ F1 ]        YM2149       ",$a,$d
 dc.b "                           [ F2 ]  STE Stereo Output  ",$a,$d
 dc.b "                           [ F3 ]  Replay (Microdeal) ",$a,$d
 dc.b "                           [ F4 ] YM2149   ",129,130," ProSound",$a,$d
 dc.b "                           [ F5 ] YM2149   ",129,130,"   Replay",$a,$d
 dc.b "                           [ F6 ]         MV16        ",$a,$d
 dc.b "                           [ F7 ]   ProSound Designer ",$a,$d
 dc.b "                           [ F8 ] Replay   ",129,130," ProSound",$a,$d
 dc.b "                                  ",1,"left",2,"           ",1,"right",2,$a,$d,$a,$d
 dc.b "                       Now Playing : ",$a,$d,$a,$d
 dc.b "               ",1,127,2,32,1,128,2," selects subsong, ",1,131,2,32,1,132,2," changes tempo, ",1,"SPACE",2," exits",$a,$d
 dc.b 0
	even

;-----------------------------------------------------------------------;
									
; The vbl - calls sequencer and vbl filler.

; NOTE: VERY BADLY OPTIMIZED!  Could be trillions of times better!

my_vbl
		addq.b #1,.phreak
		and.b #0,.phreak
		beq.s .carryon
		bra.s .justplay
.carryon
		bclr #4,$FFFFFA15.w
		move.w #$2500,sr
		MOVEM.L D0-D7/A0-A6,-(SP)
		ifne NEATO
		move.w $FFFF8240.w,-(a7)
		move.w #$303,$FFFF8240.w
		endc
		BSR Vbl_play
		ifne NEATO
		move.w #$030,$FFFF8240.w
		endc
		BSR tfmx_irqhdl	
		ifne NEATO
		move.w (a7)+,$FFFF8240.w
		endc
		MOVEM.L (SP)+,D0-D7/A0-A6
		btst #4,$FFFFFA11.w
		bne.s .blowup
		bset #4,$FFFFFA15.w
		RTE
.justplay
		bclr #4,$FFFFFA15.w
		move.w #$2500,sr
		MOVEM.L D0-D7/A0-A6,-(SP)
		ifne NEATO
		move.w $FFFF8240.w,-(a7)
		move.w #$303,$FFFF8240.w
		endc
		BSR Vbl_play
		ifne NEATO
		move.w (a7)+,$FFFF8240.w
		endc
		MOVEM.L (SP)+,D0-D7/A0-A6
		btst #4,$FFFFFA11.w
		bne.s .blowup
		bset #4,$FFFFFA15.w
		RTE
.blowup
		bsr tf_settempo2
		bclr #4,(mfp_iprb).w
		bset #4,$FFFFFA15.w
		RTE

.phreak
		dc.w	0

; Vbl player - this is a kind of 'Paula' Emulator(!)

BUFSIZE = $800

Vbl_play:	MOVEA.L	buff_ptr(PC),A4
		MOVE.L loc,D0			; current pos in buffer
		CMP.L #endbuff1,d0
		BNE.S .norm
		MOVE.L #sndbuff1,d0		; wooky case(at end of buf)
.norm		MOVE.L D0,buff_ptr
		SUB.L A4,D0
		BEQ .skipit
		BHI.S .higher
		ADDI.W #BUFSIZE,D0			; abs
.higher		LSR.W #1,D0
		MOVE.L #endbuff1,D1
		SUB.L A4,D1
		LSR.W #1,D1
		CLR.W fillx1			; assume no buf overlap
		CMP.W D1,D0			; check for overlap
		BCS.S  .higher1
		MOVE.W D1,fillx1		; ok so there was overlap!!
.higher1	SUB.W fillx1(PC),D0		; subtract any overlap
		MOVE.W D0,fillx2		; and store main
; A4 points to place to fill

		tst.b voices
		bne.s .voices_1_4

.voices_1_2	MOVE.L #sndbuff1,buffbase		
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch1s(PC),A5
		MOVE.W amove(pc),D0
		BSR add1			; move voice 1
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch4s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 2
		move.w aadd(pc),d0
		move.w Which_replay,d1
		btst.b d1,isit(pc)
		beq.s .voices_3_4

		LEA BUFSIZE+2(A4),A4
		MOVE.W amove(pc),D0
		MOVE.L #sndbuff2,buffbase	
.voices_3_4
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch3s(PC),A5	
		BSR add1			; move voice 3	
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch2s(PC),A5	
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 4					; add voice 4
		BRA .skipit
.voices_1_4	MOVE.L #sndbuff1,buffbase		
		LEA freqs(PC),A3		; int.w/frac.w freq tab
		LEA.L ch8s(PC),A5
		MOVE.W amove(pc),D0
		BSR add1			; move voice 1
		LEA freqs(PC),A3
		LEA.L ch5s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 4
		LEA freqs(PC),A3
		LEA.L ch6s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 3
		LEA freqs(PC),A3
		LEA.L ch7s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 2

		pea (a4)
		lea disttab(pc),a3
		moveq #0,d2
		MOVE.W fillx1(PC),D0
		ble.s .no1
		subq.w #1,d0
.blech
		move.w (a4),d2
		add.w d2,d2
		move.w (a3,d2),(a4)+
		dbf d0,.blech
.no1
		MOVE.W fillx2(PC),D0
		ble.s .slipit
		TST.W fillx1
		BEQ.S .nores2
		MOVE.L buffbase(PC),A4		; buffer base
.nores2
		subq.w #1,d0
.blech2
		move.w (a4),d2
		add.w d2,d2
		move.w (a3,d2),(a4)+
		dbf d0,.blech2
.slipit
		move.l (a7)+,a4

		LEA freqs(PC),A3
		LEA.L ch1s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 8
		move.w aadd(pc),d0
		move.w Which_replay,d1
		btst.b d1,isit(pc)
		beq.s .voices_5_8

		LEA BUFSIZE+2(A4),A4
		MOVE.W amove(pc),D0

		MOVE.L #sndbuff2,buffbase	
.voices_5_8
		LEA freqs(PC),A3
		LEA.L ch3s(PC),A5	
		BSR add1			; move voice 5	
		LEA freqs(PC),A3
		LEA.L ch2s(PC),A5	
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 6
*		LEA freqs(PC),A3
*		LEA.L ch4s(PC),A5	
*		MOVE.W aadd(pc),D0
*		BSR add1			; add voice 7

.skipit
		RTS

disttab
	dcb.w	384,0
x	set	0
	rept	256
	dc.w	x
x	set	x+1
	endr
	dcb.w	384,255

aud_amadr	=	0
aud_amlgt	=	4
aud_amper	=	6
aud_amvol	=	8
aud_amload	=	10
aud_amdma	=	11
aud_adr		=	12
aud_iofs	=	16
aud_fofs	=	18
aud_full	=	20
aud_amint	=	22

isit
		dc.w $9A9A		; stereo rout tab: 1=stereo

; Routine to add/move one voice to buffer. The real Paula emulation part!!

add1		PEA (A4)			; save buff pos
		LEA moda(PC),A2
		MOVE.W D0,(A2)
		MOVE.W D0,modb-moda(A2)		; self modifying
		MOVE.W D0,modc-moda(A2)		; add/move code(see below)
		MOVE.W D0,modd-moda(A2)	
		MOVE.W D0,mode-moda(A2)	
		MOVE.W D0,.blech
		MOVE.W D0,.blech2
		tst.b aud_amdma(A5)
		beq .bloch
*		tst.w aud_amvol(A5)
*		beq .bloch
		tst.w aud_amper(A5)
		beq .bloch
		tst.b aud_amload(A5)
		beq.s .noload
		bsr pau_load
		clr.w aud_fofs(a5)
.noload
		MOVE.L aud_adr(A5),A2		; current sample end address
		MOVE.W aud_amvol(A5),D2		; volume
		cmp.w #$40,d2
		ble.s .rats
		moveq #$40,d2
.rats
		MOVE.W aud_amper(A5),D1		; period
		cmp.w #$7FF,d1
		ble.s .star
		move.w #$7FF,d1
.star
		ADD.W D1,D1
		ADD.W D1,D1			; *4 for lookup
		MOVEM.W 0(A3,D1),D1/D4		; get int.w/frac.w
		MOVE.L voltab_ptr(PC),A6	; base of volume table
		LSL.W #8,D2
		ADD.W D2,A6			; ptr to volume table
		MOVEQ #0,d5
		MOVE.W aud_iofs(A5),d5		; sample length
		CMP.w #8,aud_full(a5)
		BHS.S .vcon
		MOVEQ.L	#0,D4			; channel is off.
		MOVEQ.L	#0,D1			; clear all if off.
		MOVE.L voltab_ptr(PC),A6	; zero vol(safety!!)
		CLR.W aud_fofs(A5)		; clear frac part
.vcon		NEG.L d5
		MOVE.L A6,D6			; vol ptr
		MOVEQ.L	#0,D2			; clr top byte for sample
; Setup Loop stuff
		st loopdma
		move.l aud_amadr(a5),a0
		moveq #0,d3
		move.w aud_amlgt(a5),d3
		add.w d3,d3
		add.l d3,a0
		NEG.L D3
		MOVEM.W D1/D4,loopfreq
		CMP.L #-4,D3
		Blo.S .isloop
.noloop
		sf loopdma
		MOVE.L D2,loopfreq		; no loop-no frequency
		LEA nulsamp+2(PC),A0	 	; no loop-point to nul
.isloop		MOVE.L D3,looplength
		MOVE.W aud_fofs(A5),D3		; fraction part
		MOVE.W aud_amint(A5),loopvoice
		MOVE.W fillx1(PC),D0
		BSR addit			; 
		MOVE.W fillx2(PC),D0
		TST.W fillx1
		BEQ.S .nores
		MOVE.L buffbase(PC),A4		; buffer base
.nores		BSR addit
		NEG.L d5			; +ve offset(as original!)
		MOVE.L A2,aud_adr(A5)		; store voice address
		MOVE.W d5,aud_iofs(A5)		; store offset for next time
		MOVE.W D3,aud_fofs(A5)		; fraction part
.skipit		MOVE.L (SP)+,A4
		RTS

.bloch
		move.w #$80,d2
		MOVE.W fillx1(PC),D0
		ble.s .no1
		subq.w #1,d0
.blech
		move.w d2,(a4)+
		dbf d0,.blech
.no1
		MOVE.W fillx2(PC),D0
		ble.s .skipit
		TST.W fillx1
		BEQ.S .nores2
		MOVE.L buffbase(PC),A4		; buffer base
.nores2
		subq.w #1,d0
.blech2
		move.w d2,(a4)+
		dbf d0,.blech2
		bra .skipit

pau_load
		sf aud_amload(a5)
		tst.l aud_amadr(a5)
		beq.s .blop
		move.l aud_amadr(a5),a2
		moveq #0,d5
		move.w aud_amlgt(a5),d5
		add.w d5,d5
		bra.s .loaded
.blop
		move.l #nulsamp+2,a5
		moveq #2,d5
.loaded
		move.w d5,aud_iofs(a5)
		move.w d5,aud_full(a5)
		add.l d5,a2
		move.l a2,aud_adr(a5)
		neg.l d5
		rts

pau_load2
		move.l aud_amadr(a5),a2
		moveq #0,d7
		move.w aud_amlgt(a5),d7
		add.w d7,d7
		add.l d7,a2
		move.l a2,aud_adr(a5)
		rts
	
; Add D0 sample bytes to buffer

addit
		MOVE.W D0,donemain+2		; lets go!!
		LSR #2,D0			; /4 for speed
		SUBQ #1,D0			; -1 (dbf)
		BMI.S donemain			; none to do?
makelp
		MOVE.B (A2,d5.L),D6		; fetch sample byte
		MOVE.L D6,A6
		MOVE.B (A6),D2			; lookup in vol tab
moda		ADD.W D2,(A4)+			; add/move to buffer(self modified)
		ADD.W D4,D3			; add frac part
		ADDX.W D1,d5			; add ints.(carried thru)
		BCS.S lpvoice1			; voice looped?
CONT1		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modb		ADD.W D2,(A4)+
		ADD.W D4,D3			; 
		ADDX.W D1,d5
		BCS lpvoice2
CONT2		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modc		ADD.W D2,(A4)+
		ADD.W D4,D3			;
		ADDX.W D1,d5
		BCS lpvoice3
CONT3		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modd		ADD.W D2,(A4)+			;
		ADD.W D4,D3
		ADDX.W D1,d5
CONT4		DBCS  D0,makelp
		BCS lpvoice4
donemain	MOVE.W #0,D0
		AND #3,D0			; remaining bytes.
		SUBQ #1,D0
		BMI.S yeah
niblp		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
mode		ADD.W D2,(A4)+
		ADD.W D4,D3
		ADDX.W D1,d5
CONT5		DBCS D0,niblp
		BCS lpvoicelast
yeah		RTS

buffbase	DS.L 1
loopfreq:	DS.W 2
looplength:	DS.L 1
loopvoice:	DS.W 1
loopdma:	DS.W 1
voltab_ptr	DS.L 1

lpvoice		MACRO
		MOVE.L A0,A2 
		EXT.L D5
		ADD.L looplength(PC),D5		; fetch loop constants
		MOVEM.W loopfreq(PC),D1/D4	; (channel independent)
		MOVE.B loopdma(PC),aud_amdma(A5)
		bsr pau_load2
		MOVE.W loopvoice(PC),D2
		BPL.S v\1
		JSR tfmx_virqhdl	
v\1
		MOVEQ #0,D2
		MOVE D2,CCR
 		BRA \1
		ENDM

lpvoice1:	lpvoice CONT1			;
lpvoice2:	lpvoice CONT2			; loop routs
lpvoice3:	lpvoice CONT3			; (since code is repeated)
lpvoice4:	lpvoice CONT4			;
lpvoicelast:	lpvoice CONT5			;

aadd		ADD.W D2,(A4)+
amove		MOVE.W D2,(A4)+

nulsamp		ds.l 2				; nul sample.
buff_ptr:	dc.l 0
sndbuff1:	ds.w BUFSIZE/2			; buffer for voices 1+2
endbuff1:	dc.w -1
sndbuff2	ds.w BUFSIZE/2			; buffer for voices 3+4
endbuff2	dc.w -1

fillx1:		DC.W 0
fillx2:		DC.W 0

; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.

ste_flg		DC.W 0
	
Ste_Test	LEA $FFFF8205.W,A5
		MOVEQ #-1,D1
		MOVE.B (A5),D0
		MOVE.B D1,(A5)
		CMP.B (A5),D0
		BEQ .notSTE
		MOVE.B	D0,(a5)
.ste_found	ST ste_flg
		MOVE.B voices,Which_replay+1
		ADDQ.W #1,Which_replay
.notSTE		RTS

temp:		dc.l	0

; Select The Playback Routine D0.W = 0 to 7

Select_PlayRout:
		MOVE.W SR,-(SP)
		MOVE.L D1,-(A7)
		add.b voices,d0
		MOVE.L D0,-(A7)
		MOVE #$2700,SR
		MOVE.W Which_replay,D1
		MOVE.W D0,Which_replay
		CMP.B #1,D0
		BNE.S .peachy
		TST.B ste_flg
		BNE.S .peachy
		MOVE.W D1,D0	can't enter STE mode unless you got one
.peachy
		MOVE.B .spd(PC,D1.w),D1
		MOVE.B .spd(PC,D0.w),D0
		CMP.B D0,D1
		BEQ.S .gotit
		MOVE.B #0,(mfp_tbcr).w
		MOVE.B D0,(mfp_tbdr).w
		MOVE.B D0,pd+1
		BSR tables_init2
		move.l a1,-(a7)
		move.l a0,-(a7)
		LEA sndbuff1(PC),A0
		LEA sndbuff2(PC),A1
		MOVEQ.L	#0,D1
		MOVEQ #(BUFSIZE/16)-1,D0
.banana
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+
		DBF D0,.banana
		move.l (a7)+,a0
		move.l (a7)+,a1
.spandex
		MOVE.B #1,(mfp_tbcr).w
		BRA.S .gotit
.spd
		dc.b 30,30,30,30,30,30,30,30
		dc.b 30,30,30,30,30,30,30,30
.gotit
		MOVE.L (A7),D0
		ADD.W D0,D0
		ADD.W D0,D0			; *4 (longword lookup)
		MOVE.L Output_Routs(PC,D0),(mfp_itb).W
		and.w #$1C,d0
		JSR rout_tab(PC,D0.W)		; jump to setup rout
		MOVE.L (A7)+,D0
		MOVE.L (A7)+,D1
		MOVE.W (SP)+,SR
		RTS

rout_tab	BRA.W YM2149_Setup
		BRA.W Ste_Setup
		BRA.W Internal_Off
		BRA.W YM2149_Setup
		BRA.W YM2149_Setup
		BRA.W Internal_Off
		BRA.W Internal_Off
		BRA.W Internal_Off

Which_replay	DC.W 0				; 0 - F as below
Output_Routs	DC.L YM2149_Player
		DC.L Ste_Stereo
		DC.L Replay_Player
		DC.L ProYM_Player
		DC.L RepYM_Player
		DC.L MV16_Player
		DC.L ProSound_Player
		DC.L ProRep_Player

		DC.L YM2149_Player
		DC.L Ste_Stereo
		DC.L Replay_Player
		DC.L ProYM_Player
		DC.L RepYM_Player
		DC.L MV16_Player
		DC.L ProSound_Player
		DC.L ProRep_Player


; YM2149 Setup rout - turns off ste dma(if machine is st) and clears YM.

YM2149_Setup:	TST.B ste_flg
		BEQ.S .not_ste 
		MOVE.W #0,$FFFF8900.W
.not_ste	BSR Initsoundchip		; init soundchip
		RTS

; Ste Stereo Setup rout - turns off YM 2149 and setsup dma.

Ste_Setup:	TST.B ste_flg
		BEQ.S .not_ste
		BSR Killsoundchip
		MOVE.W #0,$FFFF8900.W
		MOVE.W #$8080,$D0.W		; prime with nul sample
		LEA temp(PC),A6
		MOVE.L #$D0,(A6)			
		MOVE.B 1(A6),$ffff8903.W
		MOVE.B 2(A6),$ffff8905.W	; set start of buffer
		MOVE.B 3(A6),$ffff8907.W
		MOVE.L #$D2,(A6)
		MOVE.B 1(A6),$ffff890f.W
		MOVE.B 2(A6),$ffff8911.W	; and set end of buf
		MOVE.B 3(A6),$ffff8913.W
		MOVE.W #%0000000000000011,$ffff8920.W
		MOVE.W #3,$FFFF8900.W		; dma go!
.not_ste	RTS

; Setup rout for all other output routs - kills both dma and YM sound.

Internal_Off:	TST.B ste_flg
		BEQ.S .not_ste 
		MOVE.W #0,$FFFF8900.W
.not_ste	BSR Killsoundchip
 		RTS

;--------- The 12 bit sample interrupt Routines ---------;
; YM2149 Soundchip output.


YM2149_Player:
		movem.l d7/a1,-(a7)
loc	=	*+2
		lea $12345678,a1
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd	move.l a1,loc
*		add.w BUFSIZE(a1),d7
		lsl.w #3,d7
		lea sound_look(pc),a1
		move.w 4(a1,d7.w),$FFFF8800.w	is this really necessary?!
		move.w 6(a1,d7.w),$FFFF8800.w	is this really necessary?!
		move.l (a1,d7.w),d7	; using quartet table.
		lea $ffff8800.w,a1		; output
		movep.w d7,(a1)
		swap 	d7
		movep.w d7,(a1)
		move.l (a7)+,d7
		move.l (a7)+,a1
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.s .contsnd

; Soundchip (left) / ProSound (right) output (MM 1992)

ProYM_Player:
		movem.l d7/a1/a0,-(a7)
		move.l loc(pc),a1
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd
		move.l	a1,loc
		lsl #2,d7
		and.w #$FFF8,d7
	lea sound_look+3072(pc),a0
	add.w d7,a0
		move.l (a0)+,d7	; using quartet table.
*	move.l (a0),$FFFF8800.w
	lea	$ffff8800.w,a0
		movep.l d7,(a0)
	move.w BUFSIZE(a1),d7
	lsr.w	#1,d7
		move.w #$F00,(a0)+
		move.b d7,(a0)
		movem.l (a7)+,d7/a1/a0
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.s .contsnd

; Soundchip (left) / ST Replay (right) output (MM 1992)

RepYM_Player:
		movem.l d7/a1,-(a7)
	move.l	a0,usp
		move.l loc(pc),a1
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd
		move.l a1,loc
		lsl #4,d7
		lea $ffff8800.w,a0		; output
*		move.l sound_look+4(pc,d7.w),(a0)
		move.l sound_look(pc,d7.w),d7	; using quartet table.
		movep.l d7,(a0)
		lea $FA0000,a0
	move.w BUFSIZE(a1),d7
	and.w	#$7FFE,d7
		move.b (a0,d7.w),d7
	move.l	usp,a0
		move.l (a7)+,d7
		move.l (a7)+,a1
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.s .contsnd

sound_look:	incbin quarfast.tab

; Ste Stereo sound output with volume boost.

Ste_Stereo:
		movem.l d6/d7/a1,-(a7)
		move.l loc(pc),a1
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd
		move.l	a1,loc
		move.w BUFSIZE(a1),d6
		add.w d6,d6
		add.w d7,d7
		move.w stetab(pc,d6),d6
		move.b stetab(pc,d7),d6
		move.w d6,$d0.w
		movem.l (a7)+,d6/d7/a1
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

stetab		dcb.w 128,$8000
i		set -128
		rept 256
		dc.b i,0
i		set i+1
		endr
		dcb.w 128,$7f00


; Replay Catridge Output

Replay_Player:
		movem.l d7/a1/a0,-(a7)
		move.l loc(pc),a1
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd
		move.l	a1,loc
*		add.w BUFSIZE(a1),d7
		add.w d7,d7
		move.w replaytab(pc,d7),d7	; give the replay
		lea $fa0000,a0			; output a vol boost!!
		move.b (a0,d7.w),d7
		movem.l (a7)+,d7/a1/a0
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

replaytab	ds.w	384
i		set 0
		rept	64
		dc.w i,i+2,i+4,i+6
i		set i+8
		endr
		dcb.w 	384,$1fe

replay_noclip
	lea	replaytab,a0
	moveq	#0,d0
	moveq	#127,d1
.lick_me
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	add.l	#$20002,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	add.l	#$20002,d0
	dbf	d1,.lick_me
	rts

replay_2x
	lea	replaytab,a0
	moveq	#0,d0
	moveq	#47,d1
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d1,*-4
	moveq	#127,d1
.lick_me
	move.l	d0,(a0)+
	add.l	#$20002,d0
	move.l	d0,(a0)+
	add.l	#$20002,d0
	dbf	d1,.lick_me
	move.l	#$1FE01FE,d0
	moveq	#47,d1
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbf	d1,*-4
	rts

replay_clip
	lea	replaytab,a0
	moveq	#0,d0
	moveq	#95,d1
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	dbf	d1,*-8
	moveq	#127,d1
	move.w	d0,(a0)+
	addq.w	#2,d0
	move.w	d0,(a0)+
	addq.w	#2,d0
	dbf	d1,*-8
	move.w	#$1FE,d0
	moveq	#95,d1
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	dbf	d1,*-8
	rts

; Replay Professional Cartridge Output.

ReplayPro_Player:
		movem.l d7/a1,-(a7)
		move.l loc(pc),a1
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd
		move.l	a1,loc
*		add.w BUFSIZE(a1),d7
		add.w d7,d7
		add.w d7,d7
		lea $fa0000,a1	
		move.b (a1,d7.w),d7		; output (by input!!)
		move.l (a7)+,d7
		move.l (a7)+,a1
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

; MV16 Catridge Output

MV16_Player:
		movem.l d7/a1,-(a7)
		move.l loc(pc),a1
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd
		move.l	a1,loc
*		add.w BUFSIZE(a1),d7
		lsl #3,d7
		lea $fa0000,a1		
		move.b (a1,d7.w),d7		; output (by input!!)
		move.l (a7)+,d7
		move.l (a7)+,a1
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

; Pro-Sound Designer Cartridge

ProSound_Player:
		move.l a1,-(a7)
		move.w d7,-(a7)
		move.l loc(pc),a1
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd	move.l a1,loc
*		add.w BUFSIZE(a1),d7
		lsr #2,d7
		lea $ffff8848.w,a1
		move.w #$f00,(a1)+		12
		move.b d7,(a1)			8
		move.w (a7)+,d7
		move.l (a7)+,a1
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

; ProSound (right) / ST-Replay (left) (MM 1992)

ProRep_Player:
		movem.l d7/a1/a0,-(a7)
		move.l loc(pc),a1
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd
		move.l	a1,loc
		lea $fa0000,a0
		move.b (a0,d7.w),d7
		lea $ffff8800.w,a0
	move.w BUFSIZE(a1),d7
		lsr.w	#1,d7
		move.w #$f00,(a0)+
		move.b d7,(a0)			; output
		movem.l (a7)+,d7/a1/a0
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd



; ST specific initialisation routines - sets up shadow amiga registers.

STspecific:	LEA  nulsamp(PC),A2
		MOVEQ #0,D0
		LEA ch1s(pc),A0
		move.w #$01,aud_amint(A0)
		BSR initvoice
		LEA ch2s(pc),A0
		move.w #$02,aud_amint(A0)
		BSR initvoice			;init shadow regs
		LEA ch3s(pc),A0
		move.w #$04,aud_amint(A0)
		BSR initvoice
		LEA ch4s(pc),A0
		move.w #$08,aud_amint(A0)
		BSR initvoice
		LEA ch5s(pc),A0
		move.w #$10,aud_amint(A0)
		BSR initvoice
		LEA ch6s(pc),A0
		move.w #$20,aud_amint(A0)
		BSR initvoice
		LEA ch7s(pc),A0
		move.w #$40,aud_amint(A0)
		BSR initvoice
		LEA ch8s(pc),A0
		move.w #$80,aud_amint(A0)
		BSR initvoice
		LEA sndbuff1(PC),A0
		MOVE.L A0,buff_ptr
		LEA sndbuff2(PC),A1
		MOVEQ.L	#0,D1
		MOVEQ #(BUFSIZE/16)-1,D0
.setbuf1	MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+		; clear 2 ring buffers
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		DBF D0,.setbuf1
		RTS
initvoice:	MOVE.L A2,aud_amadr(A0)	; point voice to nul sample
		MOVE.W #1,aud_amlgt(A0)	
		MOVE.W D0,aud_amper(A0)	; period=0
		MOVE.W D0,aud_amvol(A0)	; volume=0
		ST aud_amload(A0)
		SF aud_amdma(A0)
		move.l #nulsamp+2,aud_adr(A0)
		move.w #2,aud_iofs(a0)
		MOVE.W D0,aud_fofs(A0)	; clear fraction part.
		MOVE.W D0,aud_full(A0)	; period=0
		RTS

; Initialise Soundchip

Initsoundchip:	LEA $FFFF8800.W,A0
		MOVE.B #7,(A0)			; turn on sound
		MOVE.B #$c0,D0
		AND.B (a0),D0
		OR.B #$38,D0
		MOVE.B d0,2(a0)
		MOVE.W #$0500,d0		; clear out ym2149
.initslp	MOVEP.W	d0,(a0)
		SUB.W #$0100,d0
		BPL.S .initslp
		RTS

; Reset sound chip

Killsoundchip	MOVE.W D0,-(SP)
		MOVE.B #7,$ffff8800.W		
		MOVE.B #7,D0
		OR.B $ffff8800.W,D0
		MOVE.B D0,$ffff8802.W
		MOVE.W (SP)+,D0
		RTS

; Make sure Volume lookup table is on a 256 byte boundary.

Init_Voltab	LEA vols+256(PC),A0
		MOVE.L A0,D0
		CLR.B D0
		LEA voltab_ptr(PC),A1
		TST.L (A1)
		BNE.S .alreadyinited
		MOVE.L D0,(A1)
		MOVE.L D0,A1
		MOVE.W #(16640/16)-1,D0
.lp		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D0,.lp
.alreadyinited	RTS


; Shadow Amiga Registers.
	
ch1s		DS.W 12
ch2s		DS.W 12
ch3s		DS.W 12
ch4s		DS.W 12
ch5s		DS.W 12
ch6s		DS.W 12
ch7s		DS.W 12
ch8s		DS.W 12


* TFMX-Professional v2.0 player
* Original Ami version by Chris Huelsbeck?, adapted for the ST by
* Marx Marvelous/TPPI

tfmx_base
	bra	tfmx_initplyr		0
	bra	tfmx_player
	bra	tfmx_initplyr
	bra	tfmx_startsong
	bra	tfmx_donote		16
	bra	tfmx_initmodl
	bra	tfmx_initplyr
	bra	tfmx_installplyr
	bra	tfmx_stopnote		32
	bra	tfmx_startsong
	bra	tfmx_makefade		40
	bra	tfmx_cuedataadr
	bra	tfmx_initplyr		48
	bra	tfmx_initplyr
	bra	tfmx_initplyr		56
	bra	tfmx_initplyr
	bra	tfmx_startsong		64	was holdsong
	bra	tfmx_initplyr
	bra	tfmx_initplyr
	bra	tfmx_initplyr
	bra	tfmx_initplyr		80
	bra	tfmx_setupframerate
	bra	tfmx_initplyr
	bra	tfmx_initplyr
	bra	tfmx_initplyr

stopvs	macro	voice
	btst	#\1-1,d0
	beq.s	.not\1
	move.l	tfmx_vrecs+(\1*4)-4,a0
	move.l	pv_audioptr(a0),a0
	sf	aud_amdma(a0)
.not\1
	endm

startvs	macro	voice
	btst	#\1-1,d0
	beq.s	.not\1s
	move.l	tfmx_vrecs+(\1*4)-4,a0
	move.l	pv_audioptr(a0),a0
	st	aud_amload(a0)
	st	aud_amdma(a0)
.not\1s
	endm

setper	macro	voice
	move.l	tfmx_vrecs+(\1*4)-4,a0
	move.w	pv_finalper(a0),d0
	move.l	pv_audioptr(a0),a0
	move.w	d0,aud_amper(a0)
	endm

tfmx_player	movem.l	d0-d7/a0-a6,-(sp)
	lea	tfmx_parms(pc),a6
	move.l	p1_cmd0(a6),-(sp)
	move.w	p1_chanstop(a6),d0
	beq	.nostops
	clr.w	p1_chanstop(a6)
	stopvs	1
	stopvs	2
	stopvs	3
	stopvs	4
	tst.b	voices
	beq.s	.nostops
	stopvs	5
	stopvs	6
	stopvs	7
	stopvs	8
.nostops
	tst.b	p1_playflag(a6)
	beq	.restore
	bsr	tf_doinsts		check efx
	tst.b	p1_subsong2(a6)
	bmi.s	.noplay
	bsr	tf_getnew
.noplay
	setper	1
	setper	2
	setper	3
	setper	4
	tst.b	voices
	beq.s	.nosets
	setper	5
	setper	6
	setper	7
	setper	8
.nosets
	move.w	p1_chanstart(a6),d0
	beq	.nostarts
	clr.w	p1_chanstart(a6)
	startvs	1
	startvs	2
	startvs	3
	startvs	4
	tst.b	voices
	beq.s	.nostarts
	startvs	5
	startvs	6
	startvs	7
	startvs	8
.nostarts
.restore
	move.l	(sp)+,p1_cmd0(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; get new note

tf_getnew
	lea	tfmx_parms2(pc),a5
	move.l	p1_mdatbase(a6),a4
	subq.w	#1,p1_cntdown(a6)
	bpl.s	.rts
	move.w	p2_speed(a5),p1_cntdown(a6)
.again
	move.l	a5,a0
	clr.b	p1_overagain(a6)
	bsr.s	tf_dotrack+2		1
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		2
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		3
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		4
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		5
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		6
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		7
	tst.b	p1_overagain(a6)
	bne.s	.again
	bsr.s	tf_dotrack		8
	tst.b	p1_overagain(a6)
	bne.s	.again
.rts
	rts

tf_dotrack
	addq.l	#4,a0
	cmp.b	#$90,p2_pattidx(a0)
	bcs.s	.legal
	cmp.b	#$FE,p2_pattidx(a0)
	bne.s	.rts
	st 	p2_pattidx(a0)
	move.b	p2_pattidx+1(a0),d0
	bra	tfmx_stopnote
.legal
	lea	tf_cuedata(pc),a1
	st 	$15(a1)
	tst.b	p2_pattcdn(a0)
	beq.s	tf_fetchcmd1
	subq.b	#1,p2_pattcdn(a0)
.rts
	rts

tf_fetchcmd1
	move.w	p2_pattctr(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	p2_pattptr(a0),a1
	move.l	(a1,d0.w),p1_cmd0(a6)
	move.b	p1_cmd0(a6),d0
	cmp.b	#$F0,d0
	bcc.s	.f_cmds
	move.b	d0,d7
	cmp.b	#$C0,d0
	bcc.s	.notnote
	cmp.b	#$7F,d0
	bcs.s	.notnote
	move.b	p1_cmd3(a6),p2_pattcdn(a0)
	clr.b	p1_cmd3(a6)
.notnote
	move.b	p2_pattidx+1(a0),d1
	add.b	d1,d0
	cmp.b	#$C0,d7
	bcc.s	.notnote2
	and.b	#$3F,d0
.notnote2
	move.b	d0,p1_cmd0(a6)
	move.l	p1_cmd0(a6),d0
	bsr	tfmx_donote		play the note
	cmp.b	#$C0,d7
	bcc.s	.tf_fend
	cmp.b	#$7F,d7
	bcs.s	.tf_fend
	addq.w	#1,p2_pattctr(a0)
	rts

; F commands

.f_cmds
	and.w	#15,d0
	add.w	d0,d0
	add.w	d0,d0
	jmp	.f_table(pc,d0.w)
.f_table
	bra	tf_f0		0	end pattern
	bra	tf_f1		1	repeat block
	bra	tf_f2		2	pattern jump
	bra	tf_f3		3	rest
	bra	tf_f4		4	disable track
	bra	tf_f5		5	start release
	bra	tf_f5		6	vibrato
	bra	tf_f5		7	vol slide
	bra	tf_f8		8	call
	bra	tf_f9		9	return
	bra	tf_fa		A	fade master volume
	bra	tf_fb		B	jump other track w/transpose
	bra	tf_f5		C	portamento
	bra	tf_fd		D	cue
	bra	tf_f4		E	disable trk

; FF, other illegal notes
.tf_fend
	addq.w	#1,p2_pattctr(a0)
	bra	tf_fetchcmd1
tf_fend	=	.tf_fend

; F0 = finish ptn

tf_f0
	st 	p2_pattidx(a0)
	move.w	p2_songptr(a5),d0
	cmp.w	p2_songend(a5),d0
	bne.s	.next
	move.w	p2_songrst(a5),p2_songptr(a5)
	bra.s	.get
.next
	addq.w	#1,p2_songptr(a5)
.get
	bsr	tf_getnewptn
	st 	p1_overagain(a6)
	rts

; F1 = repeat section from (x) (y-1) number of times

tf_f1
	tst.b	p2_pattrep(a0)
	beq.s	.zero
	cmp.b	#$FF,p2_pattrep(a0)
	beq.s	.ff
	subq.b	#1,p2_pattrep(a0)
	bra.s	.rept
.zero
	st 	p2_pattrep(a0)
	bra.s	tf_fend
.ff
	move.b	p1_cmd1(a6),d0
	subq.b	#1,d0
	move.b	d0,p2_pattrep(a0)
.rept
	move.w	p1_cmd2(a6),p2_pattctr(a0)
	bra	tf_fetchcmd1

; F2 = pattern jump

tf_f2
	move.b	p1_cmd1(a6),d0
	move.b	d0,p2_pattidx(a0)
	add.w	d0,d0
	add.w	d0,d0
	move.l	p1_patsbase(a6),a1
	move.l	(a1,d0.w),d0
	add.l	a4,d0
	move.l	d0,p2_pattptr(a0)
	move.w	p1_cmd2(a6),p2_pattctr(a0)
	bra	tf_fetchcmd1

; F3 = rest

tf_f3
	move.b	p1_cmd1(a6),p2_pattcdn(a0)
	addq.w	#1,p2_pattctr(a0)
	rts

; F4,FE = kill track

tf_f4
	st 	p2_pattidx(a0)
	rts

; F5,F6,F7,FC = miscellaneous efx

tf_f5
	move.l	p1_cmd0(a6),d0
	bsr	tfmx_donote
	bra	tf_fend

; F8 = call fill

tf_f8
	move.l	p2_pattptr(a0),p2_pattpsv(a0)
	move.w	p2_pattctr(a0),p2_pattcsv(a0)
	move.b	p1_cmd1(a6),d0
	move.b	d0,p2_pattidx(a0)
	add.w	d0,d0
	add.w	d0,d0
	move.l	p1_patsbase(a6),a1
	move.l	(a1,d0.w),d0
	add.l	a4,d0
	move.l	d0,p2_pattptr(a0)
	move.w	p1_cmd2(a6),p2_pattctr(a0)
	bra	tf_fetchcmd1

; F9 = return from fill

tf_f9
	move.l	p2_pattpsv(a5),p2_pattptr(a5)
	move.w	p2_pattcsv(a5),p2_pattctr(a5)
	bra	tf_fend

; FA = fade master volume

tf_fa
	lea	tf_cuedata(pc),a1
	tst.w	0(a1)
	bne	tf_fend
	move.w	#1,0(a1)
	move.b	p1_cmd3(a6),p1_tmastervol(a6)
	move.b	p1_cmd1(a6),p1_cmastervol(a6)
	move.b	p1_cmd1(a6),p1_rmastervol(a6)
	beq.s	.there
	move.b	#1,p1_kmastervol(a6)
	move.b	p1_nmastervol(a6),d0
	cmp.b	p1_tmastervol(a6),d0
	beq.s	.none
	bcs	tf_fend
	neg.b	p1_kmastervol(a6)
	bra	tf_fend
.there
	move.b	p1_tmastervol(a6),p1_nmastervol(a6)
.none
	clr.b	p1_kmastervol(a6)
	clr.w	0(a1)
	bra	tf_fend

; FB = make other track jump with transpose

tf_fb
	MOVE.B	p1_cmd2(A6),D1
	ANDI.W	#7,D1 
	ADD.W	D1,D1 
	ADD.W	D1,D1 
	MOVE.B	p1_cmd1(A6),D0
	MOVE.B	D0,p2_pattidx(A5,D1.W) 
	MOVE.B	p1_cmd3(A6),p2_pattidx+1(A5,D1.W)
	ANDI.W	#$7F,D0 
	ADD.W	D0,D0 
	ADD.W	D0,D0 
	MOVEA.L	p1_patsbase(A6),A1
	MOVE.L	(A1,D0.W),D0 
	ADD.L	A4,D0 
	MOVE.L	D0,p2_pattptr(A5,D1.W) 
	CLR.L	p2_pattctr(A5,D1.W)
	ST	p2_pattrep(A5,D1.W)
	bra	tf_fend

; FD = cueing

tf_fd
	lea	tf_cuedata(pc),a1
	move.b	p1_cmd1(a6),d0
	and.w	#3,d0
	add.w	d0,d0
	move.w	p1_cmd2(a6),$1E(a1,d0.w)
	bra	tf_fend

; read from the plst

tf_getnewptn
	movem.l	a0/a1,-(sp)
tf_getnxtlin
	move.w	p2_songptr(a5),d0
	lsl.w	#4,d0
	move.l	p1_plstbase(a6),a0
	add.w	d0,a0
	move.l	p1_patsbase(a6),a1
	move.w	(a0)+,d0
	cmp.w	#$EFFE,d0
	bne.s	.readem
	move.w	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	jmp	.effetbl(pc,d0.w)
.effetbl
	bra	tf_effestop
	bra	tf_efferepeat
	bra	tf_effetempochg
	bra	tf_effe8vparms
	bra	tf_effefade

; read pattern from the plst and point all 8 tracks to it

.readem
	move.w	d0,p2_pattidx(a5)
	bmi.s	.no1		play nothing
	clr.b	d0
	lsr.w	#6,d0
	move.l	(a1,d0.w),d0
	add.l	a4,d0
	move.l	d0,p2_pattptr(a5)
	clr.l	p2_pattctr(a5)
	st 	p2_pattrep(a5)
.no1
	movem.w	(a0)+,d0-d6
	move.w	d0,$4C(a5)
	bmi.s	.no2
	clr.b	d0
	lsr.w	#6,d0
	move.l	(a1,d0.w),d0
	add.l	a4,d0
	move.l	d0,$2C(a5)
	clr.l	$6C(a5)
	st 	$4E(a5)
.no2
	move.w	d1,$50(a5)
	bmi.s	.no3
	clr.b	d1
	lsr.w	#6,d1
	move.l	(a1,d1.w),d0
	add.l	a4,d0
	move.l	d0,$30(a5)
	clr.l	$70(a5)
	st 	$52(a5)
.no3
	move.w	d2,$54(a5)
	bmi.s	.no4
	clr.b	d2
	lsr.w	#6,d2
	move.l	(a1,d2.w),d0
	add.l	a4,d0
	move.l	d0,$34(a5)
	clr.l	$74(a5)
	st 	$56(a5)
.no4
	move.w	d3,$58(a5)
	bmi.s	.no5
	clr.b	d3
	lsr.w	#6,d3
	move.l	(a1,d3.w),d0
	add.l	a4,d0
	move.l	d0,$38(a5)
	clr.l	$78(a5)
	st 	$5A(a5)
.no5
	move.w	d4,$5C(a5)
	bmi.s	.no6
	clr.b	d4
	lsr.w	#6,d4
	move.l	(a1,d4.w),d0
	add.l	a4,d0
	move.l	d0,$3C(a5)
	clr.l	$7C(a5)
	st 	$5E(a5)
.no6
	move.w	d5,$60(a5)
	bmi.s	.no7
	clr.b	d5
	lsr.w	#6,d5
	move.l	(a1,d5.w),d0
	add.l	a4,d0
	move.l	d0,$40(a5)
	clr.l	$80(a5)
	st 	$62(a5)
.no7
	move.w	d6,$64(a5)
	bmi.s	.no8
	clr.b	d6
	lsr.w	#6,d6
	move.l	(a1,d6.w),d0
	add.l	a4,d0
	move.l	d0,$44(a5)
	clr.l	$84(a5)
	st 	$66(a5)
.no8
	movem.l	(sp)+,a0/a1
	rts

; EFFE0000 = stop

tf_effestop
*	sf	p1_playflag(a6)
	sf	p1_subsong2(a6)
	movem.l	(sp)+,a0/a1
	rts

; EFFE0001 = repeat blocks

tf_efferepeat
	tst.w	p1_songrept(a6)
	beq.s	.zero
	bmi.s	.minus
	subq.w	#1,p1_songrept(a6)
	bra.s	.cont
.zero
	move.w	#$FFFF,p1_songrept(a6)
	addq.w	#1,p2_songptr(a5)
	bra	tf_getnxtlin
.minus
	move.w	2(a0),d0
	subq.w	#1,d0
	move.w	d0,p1_songrept(a6)
.cont
	move.w	(a0),p2_songptr(a5)
	bra	tf_getnxtlin

; EFFE0002 = tempo change

tf_effetempochg
	move.w	(a0),p2_speed(a5)
	move.w	(a0),p1_cntdown(a6)
	move.w	2(a0),d0
	bmi.s	.dontdoit
	and.w	#$1FF,d0
	tst.w	d0
	beq.s	.dontdoit
	move.l	#$1B51F8,d1
	divu	d0,d1
	move.w	d1,p1_ciatempo(a6)
.dontdoit
	addq.w	#1,p2_songptr(a5)
	bra	tf_getnxtlin

; EFFE0003 = 8 voice setup

tf_effe8vparms
	move.w	2(a0),d1		1% units variation
*	bmi	tf_getnxtlin
	ext.w	d1
	cmp.b	#$E0,d1
	bgt.s	*+4
	moveq.l	#$E0,d1
	add.w	#100,d1
	mulu	#14318*128/100,d1	gets it close anyway
	lsr.l	#7,d1
*	illegal
	move.w	d1,p1_ciatempo(a6)
	addq.w	#1,p2_songptr(a5)
	bra	tf_getnxtlin

; EFFE0004 = fade

tf_effefade
	addq.w	#1,p2_songptr(a5)
	lea	tf_cuedata(pc),a1
	tst.w	0(a1)
	bne	tf_getnxtlin
	move.w	#1,0(a1)
	move.b	3(a0),p1_tmastervol(a6)
	move.b	1(a0),p1_cmastervol(a6)
	move.b	1(a0),p1_rmastervol(a6)
	beq.s	.there
	move.b	#1,p1_kmastervol(a6)
	move.b	p1_nmastervol(a6),d0
	cmp.b	p1_tmastervol(a6),d0
	beq.s	.none
	bcs	tf_getnxtlin
	neg.b	p1_kmastervol(a6)
	bra	tf_getnxtlin
.there
	move.b	p1_tmastervol(a6),p1_nmastervol(a6)
.none
	move.b	#0,p1_kmastervol(a6)
	clr.w	0(a1)
	bra	tf_getnxtlin

tf_doinsts
	lea	v1_parms(pc),a5
	bsr.s	.doinsts
	lea	v2_parms(pc),a5
	bsr.s	.doinsts
	lea	v3_parms(pc),a5
	bsr.s	.doinsts
	lea	v4_parms(pc),a5
	bsr.s	.doinsts
	lea	v5_parms(pc),a5
	bsr.s	.doinsts
	lea	v6_parms(pc),a5
	bsr.s	.doinsts
	lea	v7_parms(pc),a5
	bsr.s	.doinsts
	lea	v8_parms(pc),a5
.doinsts	move.l	pv_audioptr(a5),a4
	tst.b	pv_running(a5)
	beq	tf_endproc
	tst.w	pv_cntdown(a5)			time to next step
	beq.s	tf_vgetnew
	subq.w	#1,pv_cntdown(a5)
	bra	tf_endproc

; get the next note

tf_vgetnew	move.l	pv_instptr(a5),a0
	move.w	pv_instidx(a5),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),p1_cmd0(a6)
	moveq	#0,d0
	move.b	p1_cmd0(a6),d0
	cmp.b	#$2A,d0
	bls.s	.tit
	sf	pv_running(a5)
	bra	tf_endproc
.tit
	cmp.b	#$21,d0
	bhs	tf_vnext
	clr.b	p1_cmd0(a6)
	add.w	d0,d0
	add.w	d0,d0
	jmp	.xjmp(pc,d0.w)
.xjmp
	bra	tf_00		0 = stop efx and dma
	bra	tf_01		1 = start voice
	bra	tf_02		2 = address long
	bra	tf_03		3 = set length
	bra	tf_04		4 = wait
	bra	tf_05		5 = repeat section
	bra	tf_06		6 = jmp
	bra	tf_07		7 = end instrument
	bra	tf_08		8 = set freq
	bra	tf_09		9 = set freq, direct
	bra	tf_0a		A = clear all effects
	bra	tf_0b		B = portamento
	bra	tf_0c		C = vibrato
	bra	tf_0d		D = set fine volume
	bra	tf_0e		E = set volume
	bra	tf_0f		F = vol slide
	bra	tf_10		10 = repeat x times or until release
	bra	tf_11		11 = pointer slide
	bra	tf_12		12 = relative loop lgth
	bra	tf_13		13 = stop dma
	bra	tf_14		14 = wait x cycles or until release
	bra	tf_15		15 = jsr
	bra	tf_16		16 = rts
	bra	tf_17		17 = absolute period
	bra	tf_18		18 = set loop start
	bra	tf_19		19 = setup null sample
	bra	tf_1a		1A = repeat sample
	bra	tf_05		1B
	bra	tf_1c		1C = jump if note < parm
	bra	tf_1d		1D = jump if volume < parm
	bra	tf_05		1E
	bra	tf_1f		1F = set freq, last note relative
	bra	tf_20		20 = cueing
	bra	tf_21		21 = retrig
	bra	tf_vnext		22
	bra	tf_vnext		23
	bra	tf_vnext		24
	bra	tf_vnext		25
	bra	tf_vnext		26
	bra	tf_vnext		27
	bra	tf_vnext		28
	bra	tf_vnext		29

; finish

tf_finish
	tst.b	pv_freqset(a5)
	beq.s	.noadv
	addq.w	#1,pv_instidx(a5)
	bra	tf_endproc
.noadv
	st 	pv_freqset(a5)
tf_vnext
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_00
	clr.b	pv_rvslide(a5)
	clr.b	pv_rvibrato(a5)
	clr.w	pv_kporta(a5)
tf_13
	addq.w	#1,pv_instidx(a5)
	tst.b	p1_cmd1(a6)
	bne.s	.bop
	sf	aud_amdma(a4)
	bra	tf_vgetnew
.bop
	move.w	pv_clrdma(a5),d0
	or.w	d0,p1_chanstop(a6)
	clr.b	pv_freqset(a5)
	bra	tf_endproc

tf_01
	move.b	p1_cmd1(a6),pv_setup(a5)
	move.w	pv_setdma(a5),d0
	or.w	d0,p1_chanstart(a6)
	st	aud_amdma(a4)
	sf	aud_amint(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_02
	clr.b	pv_csampmod(a5)
	move.l	p1_cmd0(a6),d0
	add.l	p1_smplbase(a6),d0		sample base
	and.w	#$FFFE,d0
	move.l	d0,pv_sampstart(a5)
	move.l	d0,(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_11
	move.b	p1_cmd1(a6),pv_csampmod(a5)
	move.b	p1_cmd1(a6),pv_rsampmod(a5)
	move.w	p1_cmd2(a6),d1
	ext.l	d1
	move.l	d1,pv_ksampmod(a5)
	move.l	pv_sampstart(a5),d0
	add.l	d1,d0
	move.l	d0,pv_sampstart(a5)
	move.l	d0,(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_12
	move.w	p1_cmd2(a6),d0
	move.w	pv_samplgth(a5),d1
	add.w	d0,d1
	move.w	d1,pv_samplgth(a5)
	move.w	d1,4(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_03
	move.w	p1_cmd2(a6),pv_samplgth(a5)
	move.w	p1_cmd2(a6),4(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_04
	move.w	p1_cmd2(a6),pv_cntdown(a5)
	bra	tf_finish

tf_1a
	move.w	p1_cmd2(a6),pv_loopctr(a5)
	clr.b	pv_running(a5)
	move.l	pv_audioptr(a5),a1
	st	aud_amint(A1)
	bra	tf_finish

; end-of-voice interrupt for $1A

tfmx_virqhdl
	movem.l	d0/a5,-(sp)
	lea	v1_parms(pc),a5
	btst	#0,d0
	bne.s	.found
	lea	v2_parms(pc),a5
	btst	#1,d0
	bne.s	.found
	lea	v3_parms(pc),a5
	btst	#2,d0
	bne.s	.found
	lea	v4_parms(pc),a5
	btst	#3,d0
	bne.s	.found
	lea	v5_parms(pc),a5
	btst	#4,d0
	bne.s	.found
	lea	v6_parms(pc),a5
	btst	#5,d0
	bne.s	.found
	lea	v7_parms(pc),a5
	btst	#6,d0
	bne.s	.found
	lea	v8_parms(pc),a5
.found
	subq.w	#1,pv_loopctr(a5)
	bpl.s	.pop
	st	pv_running(a5)
	move.l	pv_audioptr(a5),a5
	sf	aud_amint(A5)
*	sf	aud_amdma(a5)
.pop
	move.l	(sp)+,d0
	move.l	(a7)+,a5
	rts

; 1B-1E,5

tf_1c:            MOVE.B    p1_cmd1(A6),D0
                  CMP.B     pv_thisnote(A5),D0
                  BCC       tf_vnext 
                  MOVE.W    p1_cmd2(A6),pv_instidx(A5) 
                  BRA       tf_vgetnew
tf_1d:            MOVE.B    p1_cmd1(A6),D0
                  CMP.B     pv_nvolume(A5),D0
                  BCC       tf_vnext
                  MOVE.W    p1_cmd2(A6),pv_instidx(A5) 
                  BRA       tf_vgetnew


tf_05
	tst.b	pv_reptctr(a5)
	beq.s	.zero
	cmp.b	#$FF,pv_reptctr(a5)
	beq.s	.ff
	subq.b	#1,pv_reptctr(a5)
	bra.s	.finish
.zero
	st 	pv_reptctr(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew
.ff
	move.b	p1_cmd1(a6),d0
	subq.b	#1,d0
	move.b	d0,pv_reptctr(a5)
.finish
	move.w	p1_cmd2(a6),pv_instidx(a5)
	bra	tf_vgetnew

tf_10
	tst.b	pv_envcycle(a5)
	bne.s	tf_05
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_07
	clr.b	pv_running(a5)
	bra	tf_endproc

tf_0d
	move.w	pv_nybvolume(a5),d0
	add.w	d0,d0
	add.w	pv_nybvolume(a5),d0
	add.w	p1_cmd2(a6),d0
	move.b	d0,pv_nvolume(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_0e
	move.b	p1_cmd3(a6),pv_nvolume(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_21
	move.b	pv_thisnote(a5),p1_cmd0(a6)
	move.b	pv_nybvolume+1(a5),d0
	lsl.b	#4,d0
	or.b	d0,p1_cmd2(a6)
	move.l	p1_cmd0(a6),d0
	bsr	tfmx_donote
	bra	tf_vnext

tf_1f
	move.b	pv_lastnote(a5),d2
	lea	tf_finish(pc),a1
	bra.s	.bob
.tf_09
	moveq	#0,d2
	lea	tf_finish(pc),a1
	bra.s	.bob
.tf_08
	move.b	pv_thisnote(a5),d2
	lea	tf_finish(pc),a1
.bob
	moveq	#0,d0
	move.b	p1_cmd1(a6),d0
	add.b	d2,d0
	and.b	#$3F,d0
	add.w	d0,d0
	lea	tfmx_notevals(pc),a0
	move.w	(a0,d0.w),d0
	move.w	pv_notetune(a5),d1
	add.w	p1_cmd2(a6),d1
	beq.s	.nochg
	add.w	#$100,d1
	mulu	d1,d0
	lsr.l	#8,d0
.nochg
	move.w	d0,pv_per(a5)
	tst.w	pv_kporta(a5)
	bne.s	.jmp
	move.w	d0,pv_finalper(a5)
.jmp
	jmp	(a1)

tf_08	=	.tf_08
tf_09	=	.tf_09

tf_17
	move.w	p1_cmd2(a6),pv_per(a5)
	tst.w	pv_kporta(a5)
	bne	tf_vnext
	move.w	p1_cmd2(a6),pv_finalper(a5)
	bra	tf_vnext

tf_0b
	move.b	p1_cmd1(a6),pv_rporta(a5)
	move.b	#1,pv_cporta(a5)
	tst.w	pv_kporta(a5)
	bne.s	.noset
	move.w	pv_per(a5),pv_tporta(a5)
.noset
	move.w	p1_cmd2(a6),pv_kporta(a5)
	bra	tf_vnext

tf_0c
	move.b	p1_cmd1(a6),d0
	move.b	d0,pv_rvibrato(a5)
	lsr.b	#1,d0
	move.b	d0,pv_cvibrato(a5)
	move.b	p1_cmd3(a6),pv_kvibrato(a5)
	move.b	#1,pv_vibrflag(a5)
	tst.w	pv_kporta(a5)
	bne	tf_vnext
	move.w	pv_per(a5),pv_finalper(a5)
	clr.w	pv_nvibrato(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_0f
	move.b	p1_cmd2(a6),pv_rvslide(a5)
	move.b	p1_cmd1(a6),pv_svslide(a5)
	move.b	p1_cmd2(a6),pv_cvslide(a5)
	move.b	p1_cmd3(a6),pv_tvslide(a5)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_0a
	clr.b	pv_csampmod(a5)
	clr.b	pv_rvslide(a5)
	clr.b	pv_rvibrato(a5)
	clr.w	pv_kporta(a5)
	bra	tf_vnext


tf_14
	tst.b	pv_envcycle(a5)
	beq	tf_vnext
	tst.b	pv_reptctr(a5)
	beq.s	.zero
	cmp.b	#$FF,pv_reptctr(a5)
	beq.s	.ff
	subq.b	#1,pv_reptctr(a5)
	bra.s	.finish
.zero
	st 	pv_reptctr(a5)
	bra	tf_vnext
.ff
	move.b	p1_cmd3(a6),d0
	subq.b	#1,d0
	move.b	d0,pv_reptctr(a5)
.finish
	bra	tf_endproc

tf_15
	move.l	pv_instptr(a5),pv_instpsv(a5)
	move.w	pv_instidx(a5),pv_instisv(a5)
tf_06
	moveq	#0,d0
	move.b	p1_cmd1(a6),d0
	chk	#$80,d0
	and.l	#$7F,d0
	move.l	p1_instbase(a6),a0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a0
	move.l	(a0),d0
	add.l	p1_mdatbase(a6),d0
	move.l	d0,pv_instptr(a5)
	bne.s	*+4
	illegal
	move.w	p1_cmd2(a6),pv_instidx(a5)
	st 	pv_reptctr(a5)
	bra	tf_vgetnew

tf_16
	move.l	pv_instpsv(a5),pv_instptr(a5)
	move.w	pv_instisv(a5),pv_instidx(a5)
	bra	tf_vnext

tf_18
	move.l	p1_cmd0(a6),d0
	add.l	d0,pv_sampstart(a5)
	move.l	pv_sampstart(a5),(a4)
	lsr.w	#1,d0
	sub.w	d0,pv_samplgth(a5)
	move.w	pv_samplgth(a5),4(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_19
	clr.b	pv_csampmod(a5)
	move.l	p1_smplbase(a6),pv_sampstart(a5)
	move.l	p1_smplbase(a6),(a4)
	move.w	#1,pv_samplgth(a5)
	move.w	#1,4(a4)
	addq.w	#1,pv_instidx(a5)
	bra	tf_vgetnew

tf_20
	move.b	p1_cmd1(a6),d0
	and.w	#3,d0
	add.w	d0,d0
	lea	tf_cuedata(pc),a0
	move.w	p1_cmd2(a6),$1E(a0,d0.w)
	bra	tf_vnext



tf_endproc
	tst.b	pv_setup(a5)
	bmi.s	.skipefx
	bne.s	.dosampmod
	move.b	#1,pv_setup(a5)
.skipefx
	bra	.domasterfade		skip all efx

; sample modulation

.dosampmod
	tst.b	pv_csampmod(a5)
	beq.s	.dovibrato
	move.l	pv_sampstart(a5),d0
	add.l	pv_ksampmod(a5),d0
	move.l	d0,pv_sampstart(a5)
	move.l	d0,(a4)
	sub.b	#1,pv_csampmod(a5)
	bne.s	.dovibrato
	move.b	pv_rsampmod(a5),pv_csampmod(a5)
	neg.l	pv_ksampmod(a5)

; vibrato engine

.dovibrato
	tst.b	pv_rvibrato(a5)
	beq.s	.doporta
	move.b	pv_kvibrato(a5),d0
	ext.w	d0
	add.w	d0,pv_nvibrato(a5)
	move.w	pv_per(a5),d0
	move.w	pv_nvibrato(a5),d1
	beq.s	.nomult
	and.l	#$FFFF,d0
	add.w	#$800,d1
	mulu	d1,d0
	lsl.l	#5,d0
	swap	d0
.nomult
	tst.w	pv_kporta(a5)
	bne.s	.vnoporta
	move.w	d0,pv_finalper(a5)
.vnoporta
	subq.b	#1,pv_cvibrato(a5)
	bne.s	.doporta
	move.b	pv_rvibrato(a5),pv_cvibrato(a5)
	neg.b	pv_kvibrato(a5)

; portamento

.doporta	tst.w	pv_kporta(a5)
	beq.s	.dovslide
	subq.b	#1,pv_cporta(a5)
	bne.s	.dovslide
	move.b	pv_rporta(a5),pv_cporta(a5)
	move.w	pv_per(a5),d1
	moveq	#0,d0
	move.w	pv_tporta(a5),d0
	cmp.w	d1,d0
	beq.s	.endporta
	bcs.s	.porta2
	move.w	#$100,d2
	sub.w	pv_kporta(a5),d2
	mulu	d2,d0
	lsr.l	#8,d0
	cmp.w	d1,d0
	beq.s	.endporta
	bcc.s	.psetper
.endporta
	clr.w	pv_kporta(a5)
	move.w	pv_per(a5),d0
.psetper
	and.w	#$7FF,d0
	move.w	d0,pv_tporta(a5)
	move.w	d0,pv_finalper(a5)
	bra.s	.dovslide
.porta2
	move.w	pv_kporta(a5),d2
	add.w	#$100,d2
	mulu	d2,d0
	lsr.l	#8,d0
	cmp.w	d1,d0
	beq.s	.endporta
	bcc.s	.endporta
	bra.s	.psetper

; volume slide engine

.dovslide
	tst.b	pv_rvslide(a5)
	beq.s	.dotempo
	tst.b	pv_cvslide(a5)
	beq.s	.dovs
	subq.b	#1,pv_cvslide(a5)
	bra.s	.dotempo
.dovs
	move.b	pv_rvslide(a5),pv_cvslide(a5)
	move.b	pv_tvslide(a5),d0
	cmp.b	pv_nvolume(a5),d0
	bgt.s	.sbig
	move.b	pv_svslide(a5),d1
	sub.b	d1,pv_nvolume(a5)
	bmi.s	.stopslide
	cmp.b	pv_nvolume(a5),d0
	bge.s	.stopslide
	bra.s	.dotempo
.stopslide
	move.b	pv_tvslide(a5),pv_nvolume(a5)
	clr.b	pv_rvslide(a5)
	bra.s	.dotempo
.sbig
	move.b	pv_svslide(a5),d1
	add.b	d1,pv_nvolume(a5)
	cmp.b	pv_nvolume(a5),d0
	ble.s	.stopslide

; tempo control

.dotempo
	tst.w	p1_ciatempo(a6)
	beq.s	.domasterfade
	move.w	p1_ciatempo(a6),-(a7)
	bsr	tf_settempo
	addq.l	#2,a7
	clr.w	p1_ciatempo(a6)

; master fade

.domasterfade
	tst.b	p1_kmastervol(a6)
	beq.s	.nomasf
	subq.b	#1,p1_cmastervol(a6)
	bne.s	.nomasf
	move.b	p1_rmastervol(a6),p1_cmastervol(a6)
	move.b	p1_kmastervol(a6),d0
	add.b	d0,p1_nmastervol(a6)
	move.b	p1_tmastervol(a6),d0
	cmp.b	p1_nmastervol(a6),d0
	bne.s	.nomasf
	clr.b	p1_kmastervol(a6)
	lea	tf_cuedata(pc),a0
	clr.w	0(a0)
.nomasf
	moveq	#0,d1
	move.b	p1_nmastervol(a6),d1
	moveq	#0,d0
	move.b	pv_nvolume(a5),d0
	btst	#6,d1
	bne.s	.setvol
	add.w	d0,d0
	add.w	d0,d0
	mulu	d1,d0
	lsr.w	#8,d0

; set volume reg if necessary, then finish

.setvol
	cmp.b	pv_ovolume(a5),d0
	beq.s	.rts
	move.b	pv_nvolume(a5),pv_ovolume(a5)
	move.w	d0,aud_amvol(a4)
.rts
	cmp.w	#$6C,pv_finalper(a5)
	bge.s	.blahblah
	move.w	#$6C,pv_finalper(a5)
.blahblah
	rts

; play a note or other fx

tfmx_donote
	movem.l	d0/a4-a6,-(sp)
	lea	tfmx_parms(pc),a6
	move.l	p1_cmd0(a6),-(sp)		save old cmd
	lea	tfmx_vrecs(pc),a5
	move.l	d0,p1_cmd0(a6)		store mod'd cmd
	move.b	p1_cmd2(a6),d0		likely, channel #
	and.w	#15,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a5,d0.w),a5		get chan rec
	move.b	p1_cmd0(a6),d0
	tst.b	d0
	bpl	.is_note

	cmp.b	#$F7,d0
	bne.s	.not_f7
	move.b	p1_cmd1(a6),pv_svslide(a5)
	move.b	p1_cmd2(a6),d0
	lsr.b	#4,d0
	addq.b	#1,d0
	move.b	d0,pv_cvslide(a5)
	move.b	d0,pv_rvslide(a5)
	move.b	p1_cmd3(a6),pv_tvslide(a5)
	bra	.return

.not_f7
	cmp.b	#$F6,d0
	bne.s	.not_f6
	move.b	p1_cmd1(a6),d0
	and.b	#$FE,d0
	move.b	d0,pv_rvibrato(a5)
	lsr.b	#1,d0
	move.b	d0,pv_cvibrato(a5)
	move.b	p1_cmd3(a6),pv_kvibrato(a5)
	move.b	#1,pv_vibrflag(a5)
	clr.w	pv_nvibrato(a5)
	bra.s	.return

.not_f6
	cmp.b	#$F5,d0
	bne.s	.not_f5
	clr.b	pv_envcycle(a5)
	bra.s	.return

.not_f5
	cmp.b	#$BF,d0
	bcc.s	.is_port
; start a note
.is_note
	move.b	p1_cmd3(a6),d0
	ext.w	d0
	move.w	d0,pv_notetune(a5)
	move.b	p1_cmd2(a6),d0
	lsr.b	#4,d0
	move.b	d0,pv_nybvolume+1(a5)
	move.b	p1_cmd1(a6),d0
	move.b	pv_thisnote(a5),pv_lastnote(a5)
	move.b	p1_cmd0(a6),pv_thisnote(a5)
	move.l	p1_instbase(a6),a4
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a4
	move.l	(a4),a4
	add.l	p1_mdatbase(a6),a4
	move.l	a4,pv_instptr(a5)
	clr.w	pv_instidx(a5)
	clr.w	pv_cntdown(a5)
	clr.b	pv_setup(a5)
	st 	pv_reptctr(a5)
	st 	pv_running(a5)
	clr.w	pv_loopctr(a5)
	move.l	pv_audioptr(a5),a1
	sf	aud_amint(A1)
	move.b	#1,pv_envcycle(a5)
.return
	move.l	(sp)+,p1_cmd0(a6)
	movem.l	(sp)+,d0/a4-a6
	rts

.is_port
	move.b	p1_cmd1(a6),pv_rporta(a5)
	move.b	#1,pv_cporta(a5)
	tst.w	pv_kporta(a5)
	bne.s	.noset
	move.w	pv_per(a5),pv_tporta(a5)
.noset
	clr.w	pv_kporta(a5)
	move.b	p1_cmd3(a6),pv_kporta+1(a5)
	move.b	p1_cmd0(a6),d0
	and.w	#$3F,d0
	move.b	d0,pv_thisnote(a5)
	add.w	d0,d0
	lea	tfmx_notevals(pc),a4
	move.w	(a4,d0.w),pv_per(a5)
	bra.s	.return

; stop a voice

tfmx_stopnote
	movem.l	a1/a5,-(sp)
	lea	tfmx_vrecs(pc),a5
	and.w	#15,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a5,d0.w),a5
	move.l	pv_audioptr(a5),a1
	sf	aud_amint(A1)
	move.l	#nulsamp,aud_amadr(a1)
	move.w	#1,aud_amlgt(a1)
	sf	aud_amload(a1)
	sf	aud_amdma(a1)
	clr.b	pv_running(a5)
	movem.l	(sp)+,a1/a5
	rts

tfmx_makefade
	movem.l	a5/a6,-(sp)
	lea	tfmx_parms(pc),a6
	lea	tf_cuedata(pc),a5
	move.w	#1,0(a5)
	move.b	d0,p1_tmastervol(a6)
	swap	d0
	move.b	d0,p1_cmastervol(a6)
	move.b	d0,p1_rmastervol(a6)
	beq.s	.match
	move.b	p1_nmastervol(a6),d0
	move.b	#1,p1_kmastervol(a6)
	cmp.b	p1_tmastervol(a6),d0
	beq.s	.stop
	bcs.s	.end
	neg.b	p1_kmastervol(a6)
	bra.s	.end
.match
	move.b	p1_tmastervol(a6),p1_nmastervol(a6)
.stop
	clr.b	p1_kmastervol(a6)
	clr.w	0(a5)
.end
	movem.l	(sp)+,a5/a6
	rts

tfmx_cuedataadr
	lea	tf_cuedata(pc),a0
	rts

; reset

tfmx_initplyr
	move.l	a6,-(sp)
	lea	tfmx_parms(pc),a6
	clr.b	p1_playflag(a6)
	clr.w	p1_chanstart(a6)
	lea	v1_parms(pc),a6
	bsr.s	.clrv
	lea	v2_parms(pc),a6
	bsr.s	.clrv
	lea	v3_parms(pc),a6
	bsr.s	.clrv
	lea	v4_parms(pc),a6
	bsr.s	.clrv
	lea	v5_parms(pc),a6
	bsr.s	.clrv
	lea	v6_parms(pc),a6
	bsr.s	.clrv
	lea	v7_parms(pc),a6
	bsr.s	.clrv
	lea	v8_parms(pc),a6
	bsr.s	.clrv
	lea	tf_cuedata(pc),a6
	clr.b	$15(a6)
	move.l	(sp)+,a6
	rts
.clrv
	st	pv_setup(a6)
	clr.b	pv_running(a6)
	clr.b	pv_ovolume(a6)
	move.l	#nulinst,pv_instptr(a6)
	clr.w	pv_instidx(a6)
	move.l	pv_audioptr(a6),a6
	move.l	#nulsamp,(a6)+
	move.w	#1,(a6)+
	clr.l	(a6)+
	sf	(a6)+
	sf	(a6)+
	rts

nulinst
	dc.l	$07000000
	dc.l	$07000000


; start a new subsong

tfmx_startsong
	movem.l	d1-d7/a0-a6,-(sp)
	lea	tfmx_parms(pc),a6
	move.b	d0,p1_subsong+1(a6)
	bsr	tfmx_initplyr
	clr.b	p1_playflag(a6)
	move.l	p1_mdatbase(a6),a4		mdat_base
	move.b	p1_subsong+1(a6),d0
	and.w	#$1F,d0
	add.w	d0,d0
	add.w	d0,a4
	bsr	tfmx_setupframerate
	lea	tfmx_parms2(pc),a5
	move.w	$100(a4),p2_songptr(a5)
	move.w	$100(a4),p2_songrst(a5)
	move.w	$140(a4),p2_songend(a5)
	move.w	$180(a4),d2
	cmp.w	#15,d2
	bls.s	.nocia
	move.w	d2,d0
	move.l	#$1B51F8,d1
	divu	d0,d1
	move.w	d1,p1_ciatempo(a6)
	move.w	d1,-(a7)
	bsr	tf_settempo
	addq.l	#2,a7
	move.b	#1,p1_onflag(a6)
	moveq	#0,d2
.nocia
	move.w	d2,p2_speed(a5)
	moveq	#$1C,d1
	lea	tfmx_dummypat(pc),a4
.vcslp
	move.l	a4,p2_pattptr(a5,d1.w)
	move.w	#$FF00,p2_pattidx(a5,d1.w)
	clr.l	p2_pattctr(a5,d1.w)
	subq.w	#4,d1
	bpl.s	.vcslp
	move.l	p1_mdatbase(a6),a4
	bsr	tf_getnewptn
	clr.b	p1_overagain(a6)
	clr.w	p1_cntdown(a6)
	st 	p1_songrept(a6)
	move.b	p1_subsong+1(a6),p1_subsong2(a6)
	clr.b	p1_subsong(a6)
	clr.w	p1_chanstart(a6)
	lea	tf_cuedata(pc),a4
	clr.w	0(a4)
	clr.b	$15(a4)
	move.b	#1,p1_playflag(a6)
	movem.l	(sp)+,d1-d7/a0-a6
	rts

; start a new subsong saving return address

; oh my god!  can it be init code?!?!?  (d0=mdat d1=smpl)

tfmx_initmodl
	movem.l	a2-a6,-(sp)
	lea	tfmx_parms(pc),a6
	move.l	#$40400000,p1_nmastervol(a6)
	clr.b	p1_kmastervol(a6)
	move.l	d0,p1_mdatbase(a6)
	move.l	d1,p1_smplbase(a6)
	move.l	d1,a4
	clr.l	(a4)
	move.l	d0,a4
	move.l	$1D0(a4),d1
	beq.s	.is_v1
	add.l	d0,d1
	move.l	d1,p1_plstbase(a6)
	move.l	$1D4(a4),d1
	add.l	d0,d1
	move.l	d1,p1_patsbase(a6)
	move.l	$1D8(a4),d1
	add.l	d0,d1
	move.l	d1,p1_instbase(a6)
	bra.s	.got_bases
.is_v1
	add.w	#$400,a4
	move.l	a4,p1_patsbase(a6)
	add.w	#$200,a4
	move.l	a4,p1_instbase(a6)
	add.w	#$200,a4
	move.l	a4,p1_plstbase(a6)
.got_bases
	lea	tfmx_virqhdl(pc),a4
	lea	tfmx_parms2(pc),a5
	move.w	#5,p2_songrst(a5)
	lea	tf_songcont(pc),a6
	move.w	#$1F,d0
.lp
	move.w	#5,$40(a6)
	clr.w	$80(a6)
	clr.w	(a6)+
	dbra	d0,.lp

	lea	tfmx_parms(pc),a6
	lea	tfmx_vrecs(pc),a4
	lea	v1_parms(pc),a5
	move.l	a5,(a4)+
	lea	v2_parms(pc),a5
	move.l	a5,(a4)+
	lea	v3_parms(pc),a5
	move.l	a5,(a4)+
	lea	v4_parms(pc),a5
	move.l	a5,(a4)+

	tst.b	voices
	bne.s	.no8

	lea	v1_parms(pc),a5
	move.l	a5,(a4)+
	lea	v2_parms(pc),a5
	move.l	a5,(a4)+
	lea	v3_parms(pc),a5
	move.l	a5,(a4)+
	lea	v4_parms(pc),a5
	move.l	a5,(a4)+
	bra.s	.got4

.no8
	lea	v5_parms(pc),a5
	move.l	a5,(a4)+
	lea	v6_parms(pc),a5
	move.l	a5,(a4)+
	lea	v7_parms(pc),a5
	move.l	a5,(a4)+
	lea	v8_parms(pc),a5
	move.l	a5,(a4)+

.got4
	moveq	#7,d0
.lp2
	move.l	-$20(a4),(a4)+
	dbra	d0,.lp2

	movem.l	(sp)+,a2-a6
	rts

tfmx_setupframerate
	movem.l	a5/a6,-(sp)
	lea	tfmx_parms(pc),a6
	clr.b	p1_nonflag(a6)
	clr.w	p1_ciatempo(a6)
	move.l	p1_mdatbase(a6),a5
	btst	#1,11(a5)
	bne.s	.leave
; NTSC (/14318)
	move.b	#1,p1_nonflag(a6)
	move.w	#$37EE,-(a7)
	bsr	tf_settempo
	addq.l	#2,a7
	move.w	#$37EE,p1_ciatempo(a6)
.leave
	movem.l	(sp)+,a5/a6
	rts

; the magical, mystical CIA->MFP tempo rout by /\/\ /\/\!

; Check CIAdiv against the jps ratings.  Find the largest CIA prediv
; in the table smaller than CIAtempo.
; Multiply CIAtempo by 256.  Divide CIAtempo by the above selected prediv.
; Load the timer with the quotient (rounded to nearest integer).

tf_settempo
	movem.l	d0/d1/a0,-(a7)
	moveq	#0,d0
	move.w	16(a7),d0
	cmp.w	#700,d0			ridiculous tempo filter
	blo	.ex
	move.w	d0,.oldtempo
	move.l	#$1B51F8,d1
	divu.w	d0,d1
	move.w	d1,ciatempo
	st	ciatempochg
	lea	.brax(PC),a0
.lp1
	tst.w	(a0)
	beq	.sk2
	addq.w	#2,a0
	cmp.w	(a0)+,d0
	bhs.s	.lp1
.sk2
	lsl.l	#8,d0
	divu	-(a0),d0
	move.b	-1(a0),my_vbl+9
	move.w	(a0),d1
	asr.w	#1,d1
	swap.w	d0
	cmp.w	d0,d1
	swap.w	d0
	blt.s	.sk1
	addq.w	#1,d0
.sk1
	cmp.w	#256,d0
	blt.s	.blah
	move.w	#256,d0
.blah
	cmp.w	#80,d0
	bgt.s	.blah2
	move.w	#80,d0
.blah2
	move.w	sr,-(a7)
	move.w	#$2700,sr
	move.b	#$40,(mfp_ierb).w
	move.b	#$40,(mfp_imrb).w
	move.b	#0,(mfp_tcdcr).w
.lp
	move.b	d0,(mfp_tddr).w
	cmp.b	(mfp_tddr).w,d0
	bne.s	.lp
	and.b	#$40,(mfp_iprb).w
	and.b	#$40,(mfp_isrb).w
	move.b	#$50,(mfp_ierb).w
	move.b	-2(a0),d0
.lpp
	move.b	d0,(mfp_tcdcr).w
	cmp.b	(mfp_tcdcr).w,d0
	bne.s	.lp
	move.b	#$50,(mfp_imrb).w
	move.w	(a7)+,sr
.ex
	movem.l	(a7)+,d0/d1/a0
	rts
.brax
	dc.w	$0500,4773
	dc.w	$0600,7458
	dc.w	$0700,14914
	dc.w	$0503,19091
	dc.w	$0603,29829
	dc.w	$0703,59659
	dc.l	0
.oldtempo
	dc.w	0
.tf_settempo2
	move.w	.oldtempo,-(a7)
	beq.s	.bibi
	bsr	tf_settempo
.bibi
	addq.l	#2,a7
	rts
tf_settempo2 = .tf_settempo2

tfmx_irqhdl
	move.l	a6,-(sp)
	lea	tfmx_parms(pc),a6
	bsr	tfmx_player
	move.l	(sp)+,a6
	rts

tfmx_installplyr
	move.l	a6,-(sp)
	lea	tfmx_parms(pc),a6
	bsr	tfmx_initplyr
	lea	tfmx_parms(pc),a6
	move.l	(sp)+,a6
	rts

tfmx_parms
	dc.l	0,0,0,0
	dc.l	0,0,0,$7FFF
	dc.l	0,0,$40400000,$FFFF
	dc.l	0,0,0,0
tfmx_vrecs
	dcb.l	16,0
v1_parms
	dc.l	0,0,0,0
	dc.l	0,$82010001,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$80800080,$FFFFFF04,ch1s,0
	dc.l	$FF00
v2_parms
	dc.l	0,0,0,0
	dc.l	0,$82020002,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$81000100,$FFFFFF04,ch2s,0
	dc.l	$FF00
v3_parms
	dc.l	0,0,0,0
	dc.l	0,$82040004,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$82000200,$FFFFFF04,ch3s,0
	dc.l	$FF00
v4_parms
	dc.l	0,0,0,0
	dc.l	0,$82080008,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$84000400,$FFFFFF04,ch4s,0
	dc.l	$FF00
v5_parms
	dc.l	0,0,0,0
	dc.l	0,$82100010,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$88000800,$FFFFFF04,ch5s,0
	dc.l	$FF00
v6_parms
	dc.l	0,0,0,0
	dc.l	0,$82200020,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$90001000,$FFFFFF04,ch6s,0
	dc.l	$FF00
v7_parms
	dc.l	0,0,0,0
	dc.l	0,$82400040,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$A0002000,$FFFFFF04,ch7s,0
	dc.l	$FF00
v8_parms
	dc.l	0,0,0,0
	dc.l	0,$82800080,0,0
	dc.l	0,0,0,0
	dc.l	0,0,0,0
	dc.l	$C0004000,$FFFFFF04,ch8s,0
	dc.l	$FF00
tfmx_parms2
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0
tf_songcont
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
	dc.l	0,0,0,0,0,0,0,0
tf_cuedata
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0

tfmx_dummypat
	dc.l	$F4000000
	dc.l	$F0000000

tfmx_notevals
	dc.w	$6AE,$64E,$5F4,$59E,$54D,$501,$4B9,$475,$435,$3F9,$3C0,$38C
	dc.w	$358,$32A,$2FC,$2D0,$2A8,$282,$25E,$23B,$21B,$1FD,$1E0,$1C6
	dc.w	$1AC,$194,$17D,$168,$154,$140,$12F,$11E,$10E,$0FE,$0F0,$0E3
	dc.w	$0D6,$0CA,$0BF,$0B4,$0AA,$0A0,$097,$08F,$087,$07F,$078,$071
	dc.w	$0D6,$0CA,$0BF,$0B4,$0AA,$0A0,$097,$08F,$087,$07F,$078,$071
	dc.w	$0D6,$0CA,$0BF,$0B4



freqs		ds.l 2048
		even

vols		ds.l 64
		incbin pt_volta.dat
				; 65 ,256 byte lookups.
		even

		SECTION BSS
		DS.L 512
my_stack	DS.L 4

dir
mt_data						; module is loaded here.
		

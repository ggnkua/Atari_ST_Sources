*-------------------------------------------------------------------------------
* SHOW_DEBUGGER: Schaltet den Bildschirm auf den Debuggerscreen.
*
* SHOW_PROGRAMM: Schaltet den Bildschirm auf den Programmscreen.
*
* GET_HARDWARE: Rettet einige Hardwareregister, sollte beim Einsprung in den
*				Debugger und beim Installieren aufgerufen werden.
*
* INIT_HARDWARE: Initialisiert die Hardware, nach M”glichkeit nur nach einem
*				 Reset aufrufen.
*
* WAIT_VBL: Wartet auf den n„chsten VBL.
*
* TestTC: Testet ob eine True Color Aufl”sung vorliegt.
* <--- flag.ne = ja, True Color
*-------------------------------------------------------------------------------

		.EXPORT		GET_HARDWARE,SHOW_PROGRAMM,SHOW_DEBUGGER
		.EXPORT		WAIT_VBL,GET_FALCON,INIT_HARDWARE,TestTC
		.EXPORT		SAVE_SHIFTMODE,SAVE_SCREEN,SAVE_SYNCMODE,SAVE_LINEWID
		.EXPORT		SAVE_HSCROLL,SAVE_FALCON_REG,DEBUGGER_BILD

		.INCLUDE	'EQU.S'

*-------------------------------------------------------------------------------

		.BSS
SAVE_HARDWARE_ST:	ds.b	12
SAVE_HARDWARE_STE:	ds.b	4
SAVE_HARDWARE_TT:	ds.b	10
SAVE_HARDWARE_STE_TT:ds.b	6

* Videoregister
SAVE_SCREEN:		ds.l	1				; Originalbildadresse
SAVE_FARBREGISTER:	ds.w	256				; 256 Farbregister, st=16.w
					ds.w	256				; TT=256.w
SAVE_FARBREGISTER_F030:ds.l	256				; F030=256.l
SAVE_FALCON_REG:	ds.b	FALCONREGLENGTH	; Falconregister
SAVE_SHIFTMODE: 	ds.w	1				; Shiftmoderegister st & TT
SAVE_SYNCMODE:		ds.b	1				; Sync Mode Register
SAVE_LINEWID:		ds.b	1				; Linewid bei STE
SAVE_HSCROLL:		ds.b	1				; Hscroll bei STE

DEBUGGER_BILD:		ds.b	1				; Debuggerscreen aktiv?
			EVEN

*-------------------------------------------------------------------------------

		.TEXT
SHOW_DEBUGGER:	move.l		a0,-(sp)
				tst.b		DEBUGGER_BILD
				bne.s		.keep_screen
				movea.l		USERSWITCH_1,a0
				jsr			(a0)
				bsr.s		SWITCH_TO_BUG
				st			DEBUGGER_BILD
.keep_screen:	move.l		(sp)+,a0
				rts

*-------------------------------------------------------------------------------

SHOW_PROGRAMM:	move.l		a0,-(sp)
				tst.b		DEBUGGER_BILD
				beq.s		.keep_screen
				movea.l		USERSWITCH_2,a0
				jsr			(a0)
				bsr			SWITCH_TO_PROG
				sf			DEBUGGER_BILD
.keep_screen:	move.l		(sp)+,a0
				rts

*-------------------------------------------------------------------------------

SWITCH_TO_BUG:	cmpi.b		#3,VDO			; unbekannte Maschine?
				bls.s		.cont
				rts
.cont:			move.w		sr,-(sp)
				ori.w		#$700,sr
				movem.l		d0-a6,-(sp)


				lea			VIDEO_BASE_HIGH.w,a0	; Get Screen
				moveq		#0,d0
				movep.w		(a0),d0
				lsl.l		#8,d0
				tst.b		VDO						; ST?
				beq.s		.video_st_1
				move.b		VIDEO_BASE_LOW.w,d0
.video_st_1:	move.l		d0,SAVE_SCREEN

				bsr			WAIT_VBL				; Switch Screen
				move.l		BILDSCHIRM_ADRESSE,d0
				tst.b		VDO						; ST?
				beq.s		.video_st_2
				move.b		d0,VIDEO_BASE_LOW.w
.video_st_2:	lsr.l		#8,d0
				movep.w		d0,(a0)


				cmpi.b		#3,VDO					; Falcon?
				beq			.falcon
				cmpi.b		#1,VDO					; STE?
				bne.s		.kein_STE


				tst.b		SWITCH_REGISTER
				beq.s		.kein_STE
				move.b		HSCROLL.w,SAVE_HSCROLL	; STE
				move.b		LINEWID.w,SAVE_LINEWID
				clr.b		HSCROLL.w
				clr.b		LINEWID.w


.kein_STE:		cmpi.b		#2,VDO					;TT?
				bne.s		.kein_TT

				tst.b		SWITCH_REGISTER
				beq.s		.cont_1
				move.b		SYNC_MODE.w,SAVE_SYNCMODE	; TT
				bset		#0,SYNC_MODE.w
				move.w		SHIFTMD_TT.w,SAVE_SHIFTMODE
				move.w		SET_SHIFTMD_TT,SHIFTMD_TT.w
.cont_1:		lea			F_REGISTER_TT.w,A0
				move.w		#255,D0
				bra.s		.FREGISTER


.kein_TT:		tst.b		SWITCH_REGISTER
				beq.s		.cont_2
				move.b		SYNC_MODE.w,SAVE_SYNCMODE ; ST(E)
				clr.b		SYNC_MODE.w
				move.b		SHIFTMD_ST.w,SAVE_SHIFTMODE
				move.b		SET_SHIFTMD_ST,SHIFTMD_ST.w
.cont_2:		lea			F_REGISTER_ST.w,A0
				moveq		#15,D0


.FREGISTER:		tst.b		SWITCH_PALETTE
				beq.s		.ende
				lea			SAVE_FARBREGISTER,a1
				lea			OWN_PALETTE,a2
.loop_1:		move.w		(a0),(a1)+
				move.w		(a2)+,(a0)+
				dbra		d0,.loop_1
.ende:			movem.l		(sp)+,d0-a6
				move.w		(sp)+,sr
				rts

*---------------

.falcon:		lea			SAVE_FALCON_REG,a0
				bsr			GET_FALCON
				lea			SET_FALCON_REG,a0
				bsr			SET_FALCON
				tst.b		SWITCH_PALETTE
				beq.s		.ende
				lea			$FFFF9800.w,a0
				lea			SAVE_FARBREGISTER_F030,a1
				move.w		#255,d0
.loop_2:		move.l		(a0)+,(a1)+
				dbra		d0,.loop_2
				move.l		#-1,$FFFF9800.w
				clr.l		$FFFF9BFC.w
				clr.l		$FFFF9800+4*3.w
				clr.l		$FFFF9800+4*15.w
				bra.s		.ende

*-------------------------------------------------------------------------------

SWITCH_TO_PROG: cmpi.b		#3,VDO			; unbekannte Maschine?
				bls.s		.cont
				rts
.cont:			move.w		sr,-(sp)
				ori.w		#$0700,sr
				movem.l		d0-a6,-(sp)


				bsr			WAIT_VBL
				lea			VIDEO_BASE_HIGH.w,a0	; Switch Screen
				move.l		SAVE_SCREEN,d0
				lsr.l		#8,d0
				movep.w		d0,(a0)
				tst.b		VDO						; ST?
				beq.s		.video_st
				move.b		SAVE_SCREEN+3,VIDEO_BASE_LOW.w


.video_st:		cmpi.b		#3,VDO					; Falcon?
				beq			.falcon
				cmpi.b		#1,VDO					; STE?
				bne.s		.kein_STE

				
				tst.b		SWITCH_REGISTER
				beq.s		.kein_STE
				move.b		SAVE_HSCROLL,HSCROLL.w	; STE
				move.b		SAVE_LINEWID,LINEWID.w


.kein_STE:		cmpi.b		#2,VDO					; TT?
				bne.s		.kein_TT

				tst.b		SWITCH_REGISTER
				beq.s		.cont_1
				move.b		SAVE_SYNCMODE,SYNC_MODE.w	; TT
				move.w		SAVE_SHIFTMODE,SHIFTMD_TT.w
.cont_1:		lea			F_REGISTER_TT.w,a0
				move.w		#255,d0
				bra.s		.FREGISTER


.kein_TT:		tst.b		SWITCH_REGISTER
				beq.s		.cont_2
				move.b		SAVE_SYNCMODE,SYNC_MODE.w	; ST(E)
				move.b		SAVE_SHIFTMODE,SHIFTMD_ST.w
.cont_2:		lea			F_REGISTER_ST.w,a0
				moveq		#15,d0


.FREGISTER:		tst.b		SWITCH_PALETTE
				beq.s		.ende
			 	lea			SAVE_FARBREGISTER,a1
.loop_1:		move.w		(a1)+,(a0)+
				dbra		d0,.loop_1
.ende:			movem.l		(sp)+,d0-a6
				move.w		(sp)+,sr
				rts

*---------------

.falcon:		lea			SAVE_FALCON_REG,a0
				bsr.s		SET_FALCON
				tst.b		SWITCH_PALETTE
				beq.s		.ende
				lea			$FFFF9800.w,a0
				lea			SAVE_FARBREGISTER_F030,a1
				move.w		#255,d0
.loop_2:		move.l		(a1)+,(a0)+
				dbra		d0,.loop_2
				bra.s		.ende

*-------------------------------------------------------------------------------

* 40 Bytes
GET_FALCON:		lea			regtabl(pc),a2
				moveq		#(regtabl_e-regtabl)/2-1,d0
.save:			movea.w		(a2)+,a1
				move.w		(a1),(a0)+
				dbra		d0,.save
				rts

*-------------------------------------------------------------------------------

* 40 Bytes
SET_FALCON:		tst.b		SWITCH_REGISTER
				beq.s		.ende
				lea			regtabl(pc),a2
				moveq		#(regtabl_e-regtabl)/2-1-4,d0
.restore:		movea.w		(a2)+,a1
				move.w		(a0)+,(a1)
				dbra		d0,.restore
				cmpi.w		#$50,$ffff8282.w	; STE-Komp. Modus?
				blt.s		.ste_comp
				move.w		(a0)+,$ffff8260.w
				move.w		(a0)+,$ffff8266.w
				bra.s		.cont
.ste_comp:		move.w		2(a0),$ffff8266.w
				move.w		(a0)+,$ffff8260.w	; STE-Komp. Modus einstellen
				addq.w		#2,a0
.cont:			move.w		(a0)+,$ffff8210.w
				move.w		(a0)+,$ffff82C2.w
.ende:			rts

*---------------

regtabl:		dc.w		$820A,$8282,$8284,$8286,$8288,$828A,$828C
				dc.w		$828E,$8290,$82A2,$82A4,$82A6,$82A8,$82AA
				dc.w		$82AC,$82C0,$8260,$8266,$8210,$82C2
regtabl_e:

*-------------------------------------------------------------------------------

WAIT_VBL:		cmpi.b		#1,VDO			; only STE
				bhi.s		.dont_wait
				move.w		sr,-(sp)
				move.l		d0,-(sp)
				andi.w		#$fbff,sr
				move.l		_FRCLOCK.w,d0
.wait:			cmp.l		_FRCLOCK.w,d0
				beq.s		.wait
				move.l		(sp)+,d0
				move.w		(sp)+,sr
.dont_wait:		rts

*-------------------------------------------------------------------------------

TestTC:			move.l		d0,-(sp)
				moveq		#0,d0
				cmpi.b		#3,MCH
				bne.s		.cont
				move.w		$ffff8266.w,d0
				btst		#8,d0
				sne			d0
.cont:			tst.b		d0
				movem.l		(sp)+,d0		; movem wegen CCR
				rts

*-------------------------------------------------------------------------------

GET_HARDWARE:	cmpi.b		#3,MCH		  ; nur st/STE/TT/FALCON
				bls.s		.cont
				rts
.cont:			MOVEM.L     d0-a6,-(SP)

		MOVEQ	    #11,D0
		LEA	    SAVE_HARDWARE_ST,A0
		LEA	    Hardware_ST,A1
GET_ST_MFP:	MOVEA.W     (A1)+,A2
		MOVE.B	    (A2),(A0)+
		DBRA	    D0,GET_ST_MFP

		CMPI.B	    #2,MCH
		BNE.S	    WIEDER_KEIN_TT

		MOVEQ	    #10,D0
		LEA	    SAVE_HARDWARE_TT,A0
		LEA	    Hardware_TT,A1
GET_TT_MFP:	MOVEA.W     (A1)+,A2
		MOVE.B	    (A2),(A0)+
		DBRA	    D0,GET_TT_MFP
		BRA.S	    TT_EINSTIEG

WIEDER_KEIN_TT: CMPI.B	    #1,MCH
		BNE.S	    WIEDER_KEIN_STE

		MOVE.W	    MWDATA.w,SAVE_HARDWARE_STE
		MOVE.W	    MWMASK.w,SAVE_HARDWARE_STE+2
		CMPI.B	    #$10,MSTE
		BNE.S	    WIEDER_KEIN_STE

TT_EINSTIEG:	MOVEQ	    #5,D0
		LEA	    SAVE_HARDWARE_STE_TT,A0
		LEA	    Hardware_STE_TT,A1
GET_STE_TT:	MOVEA.W     (A1)+,A2
		MOVE.B	    (A2),(A0)+
		DBRA	    D0,GET_STE_TT

WIEDER_KEIN_STE:MOVEM.L     (SP)+,d0-a6
		RTS

*-------------------------------------------------------------------------------

INIT_HARDWARE:	cmpi.b		#3,MCH		  ; nur st/STE/TT/FALCON
				bls.s		.cont
				rts
.cont:			JSR	    CREATE_FRAME_PC
		MOVE	    SR,-(SP)
		ORI	    #$0700,SR

		MOVEM.L     d0-a6,-(SP)

		LEA	    FIFO.w,A0
		MOVE.W	    #$90,(A0)		  ; FIFO-Puffer leeren
		MOVE.W	    #$0190,(A0)
		MOVE.W	    #$90,(A0)

		LEA     ACIA_STATUS_IKBD.w,A0
		MOVE.B	    #3,(A0)		  ; KBD-Acia Reset
		MOVE.B	    #$96,(A0)
		MOVE.B	    #$80,2(A0)
		MOVE.B	    #1,2(A0)		  ; IKBD reseten
		MOVE.B	    #8,2(A0)		  ; relativer Mousemodus
		MOVE.B	    #3,4(A0)		  ; Midi-Acia Reset
		MOVE.B	    #$95,4(A0)		  ; Acia's initialisieren

* Der 6301 Tastaturprozessor arbeitet beim st im Single-Chip-Modus (Mode 7)
* Bei einem Reset erf„hrt der 6301 den Modus ber die Portleitungen P20/P21/P22
* Softwarem„ssig kann der Modus nicht mehr ge„ndert werden, durch Drcken der
* Maustasten beim Reset kann Modus 1, 3 oder 5 aktiviert werden, was dazu fhrt
* das man nicht mehr mit der Tastatur arbeiten kann

		CLR.B	    ST_IERA.w		  ; mal alles vom MFP
		CLR.B	    ST_IERB.w		  ; blockieren
		MOVE.B	    #$10,ST_TACR.w	  ; alle Timer vorerst mal
		MOVE.B	    #$10,ST_TBCR.w	  ; stoppen und Ausgang auf
		CLR.B	    ST_TCDCR.w		  ; Low
		MOVEQ	    #11,D0
		LEA	    SAVE_HARDWARE_ST,A0
		LEA	    Hardware_ST,A1
INIT_ST_MFP:	MOVEA.W     (A1)+,A2
		MOVE.B	    (A0)+,(A2)
		DBRA	    D0,INIT_ST_MFP

		CLR.B	    ST_IPRA.w		  ; Interrupt Pending Register
		CLR.B	    ST_IPRB.w		  ; l”schen
		CLR.B	    ST_ISRA.w		  ; Interrupt Service Register
		CLR.B	    ST_ISRB.w		  ; l”schen
		BCLR	    #4,ST_AER.w 	  ; Flanke auf fallend
		BCLR	    #4,ST_DDR.w 	  ; Direction auf In
		BSET	    #5,ST_IMRB.w	  ; Timer C nicht maskieren
		BSET	    #5,ST_IERB.w	  ; und enablen
		BSET	    #6,ST_IMRB.w	  ; Acia nicht maskieren
		BSET	    #6,ST_IERB.w	  ; und enablen

		BTST	    #0,SND
		BEQ.S	    KEIN_YAMAHA
		LEA	    GISELECT.w,A0	  ; Yamaha initialisieren
		MOVE.B	    #7,(A0)		  ; alle Kan„le aus und
		MOVE.B	    #-1,2(A0)		  ; Ports auf out
		MOVE.B	    #14,(A0)		  ; Select aus, Strobe High
		MOVE.B	    #$27,2(A0)

KEIN_YAMAHA:	BTST	    #1,SND
		BEQ.S	    KEIN_DMASOUND
		CLR.W	    SNDMACTL.w

KEIN_DMASOUND:	CMPI.B	    #2,MCH
		BNE.S	    KEIN_TT

		MOVE.B	    #$80,S_ICR.w	  ; SCSI reseten
		TST.B	    S_INIRCV.w		  ; Interrupts & Parity l”schen

		CLR.B	    TT_IERA.w		  ; mal alles vom MFP
		CLR.B	    TT_IERB.w		  ; blockieren
		MOVE.B	    #$10,TT_TACR.w	  ; alle Timer vorerst mal
		MOVE.B	    #$10,TT_TBCR.w	  ; stoppen und Ausgang auf
		CLR.B	    TT_TCDCR.w		  ; Low
		MOVEQ	    #10,D0
		LEA	    SAVE_HARDWARE_TT,A0
		LEA	    Hardware_TT,A1
INIT_TT_MFP:	MOVEA.W     (A1)+,A2
		MOVE.B	    (A0)+,(A2)
		DBRA	    D0,INIT_TT_MFP
		CLR.B	    TT_IPRA.w		  ; Interrupt Pending Register
		CLR.B	    TT_IPRB.w		  ; l”schen
		CLR.B	    TT_ISRA.w		  ; Interrupt Service Register
		CLR.B	    TT_ISRB.w		  ; l”schen

		CLR.B	    S_ICR.w		  ; SCSI wieder io bringen
		BRA.S	    TT_EINSTIEG_2

KEIN_TT:	CMPI.B	    #1,MCH
		BNE.S	    KEIN_STE

		MOVE.W	    SAVE_HARDWARE_STE,MWDATA.w
		MOVE.W	    SAVE_HARDWARE_STE+2,MWMASK.w

		CMPI.B	    #$10,MSTE
		BNE.S	    KEIN_STE

TT_EINSTIEG_2:	MOVEQ	    #-1,D0
SCC_LOOP:	MOVE.B	    D0,D1
		AND.B	    #%11111000,D1
		MOVE.B	    D1,SCCCTL_A 	  ; SCC A reseten
		MOVE.B	    D1,SCCCTL_B 	  ; SCC B reseten
		DBRA	    D0,SCC_LOOP
		MOVE.B	    #%11000000,SCCCTL_A.w
		MOVE.B	    #%11000000,SCCCTL_B.w

		MOVEQ	    #5,D0
		LEA	    SAVE_HARDWARE_STE_TT,A0
		LEA	    Hardware_STE_TT,A1
INIT_STE_TT:	MOVEA.W     (A1)+,A2
		MOVE.B	    (A0)+,(A2)
		DBRA	    D0,INIT_STE_TT

KEIN_STE:
		TST.B	    VDO
		BNE.S	    TT_METHODE

		TST.B	    ST_GPIP.w		  ; Monochrom Monitor Detect?
		BMI.S	    NO_MONOCHROM
		LEA	    ST_TBDR.w,A0
		LEA	    ST_TBCR.w,A1
		MOVE.B	    #$10,(A1)
		MOVEQ	    #1,D4
		MOVE.B	    #0,(A1)
		MOVE.B	    #$F0,(A0)
		MOVE.B	    #8,(A1)
WAITING:	MOVE.B	    (A0),D0
		CMP.B	    D4,D0
		BNE.S	    WAITING
STILL_WAITING:	MOVE.B	    (A0),D4
		MOVE.W	    #$0267,D3
TEST_WEITER:	CMP.B	    (A0),D4
		BNE.S	    STILL_WAITING
		DBRA	    D3,TEST_WEITER
		MOVE.B	    #$10,(A1)
		MOVE.B	    #2,SHIFTMD_ST.w
NO_MONOCHROM:	MOVEM.L     (SP)+,d0-a6
		RTE

TT_METHODE:	BSR	    SHOW_PROGRAMM
		BSR	    SHOW_DEBUGGER
		MOVEM.L     (SP)+,d0-a6
		RTE

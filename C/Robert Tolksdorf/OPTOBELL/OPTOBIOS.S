;	OPTOBIOS - Der BIOS-Handler fr OPTOBELL
;
;	1991 by Robert Tolksdorf
;	(C) ST-Computer
;

			EXPORT	XB_BIOS, my_bios
			IMPORT	blink, OptoConf, stackcorr

			DC.L	"XBRARTOB"
XB_BIOS:	DC.L	0

my_bios:
			TST.W	OptoConf
			BEQ		goto_stand
			
			MOVE.L	A0, a0_save		; A0 sichern
			MOVE.L	USP,A0
			BTST	#$5,(A7)
			BEQ		not_super
			
			LEA		6(A7),A0
			
not_super:
			ADD.L	stackcorr(PC),A0; 68020 beachten
			
			CMPI.L	#$30002,(A0)	; BConOut(2,... ?
			BNE		cont_stand		; Nein -> normal weiter
			
			CMPI.W	#$7,4(A0)		; BConOut(2,7) ?
			BNE		cont_stand		; Nein -> normal weiter
			
			JSR		blink			; Blinken lassen
			
			TST.W	OptoConf
			BMI		cont_stand
			
			MOVE.L	a0_save(PC),A0		; A0 restaurieren
			RTE						; und fertig
			
cont_stand:
			MOVE.L	a0_save(PC),A0		; A0 restaurieren
goto_stand:
			MOVE.L	XB_BIOS,-(A7)
			RTS
			
a0_save:	DC.L	0

			END

; Ende von OPTOBIOS.S

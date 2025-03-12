;	CLICKHAN.S
;
;	1991 by Robert Tolksdorf
;
;	Leitet kbd_sys() um
;

			IMPORT	handle_ikbd, stackcorr
			IMPORT	kc, rom_start
			EXPORT	XB_KBDSYS, XB_AES, XB_GEMDOS
			EXPORT 	XB_BIOS, my_kbdsys, my_aes
			EXPORT	my_gemdos, my_bios, aes_save

BUFFERSIZE	=	16
WINDOWMAX	=	8
KINDOFFS	=	12+BUFFERSIZE
IDOFFS		=	KINDOFFS+WINDOWMAX*2

			TEXT

semaphor:	DC.W	0

; XBRA-Header
			DC.L	"XBRARTKC"
XB_KBDSYS:	DC.L	0

my_kbdsys:
		MOVE.L	XB_KBDSYS(PC),A1	; Alten Vektor holen
		
		TAS.W	semaphor			; Ist unser Handler frei ?
		BEQ		check_key			; ja, Taste berprfen

		JMP		(A1)				; normal weiter

check_key:
		JSR		(A1)				; Tastendruck verarbeiten
		JSR		handle_ikbd(PC)		; und berprfen
		
		CLR.W	semaphor			; wir sind fertig
		RTS							; und beenden


; XBRA-Header
			DC.L	"XBRARTKC"
XB_AES:		DC.L	0

; jeder AES/VDI-Call landet hier
my_aes:
		CMPI.B	#$C8,D0				; ist es ein AES-Call
		BNE		standard_call		; nein -> normal weiter
			
do_aes_call:
		MOVEM.L	A0-A2/D0,-(A7)		; A0,A1,A2,D0 sichern
		MOVE.L	D1,A1				; AES-Parmblock-Adr holen
		MOVE.L	8(A1),A2			; IntIn-Adresse holen
		MOVE.L	4(A1),A0
		MOVE.L	(A1),A1				; Control-Adresse holen
		CMPI.W	#105, (A1)			; wind_set Call ?
		BNE		test_delete			; nein -> weiter
;
;	Ein wind_set-Aufruf, auf WF_KIND testen
;
		CMPI.W	#1, 2(A2)			; IntIn[1]==WF_KIND ?
		BNE		continue_standard	; nein -> zum normalen GEM-Call
;
;	Ein wind_set(handle,WF_KIND, kind)-Aufruf -> kind merken
;
		MOVEA.L	#kc+KINDOFFS, A1
		MOVE.W	(A2), D0			; handle aus IntIn[0]
		LSL.W	#1,D0
		MOVE.W	4(A2), (A1,D0.W)	; kind aus IntIn[2]
		BRA		continue_standard

test_delete:
		CMPI.W	#103, (A1)			; wind_delete Call ?
		BNE		test_new			; nein -> weiter
;
;	Ein wind_delete(handle)-Aufruf -> ID-l”schen
;
		MOVEA.L	#kc+IDOFFS,A1
		MOVE.W	(A2), D0			; handle aus IntIn[0]
		LSL.W	#1,D0
		MOVE.W	#-1,(A1,D0.W)		; id[handle]=-1

		BRA		continue_standard

test_new:
		CMPI.W	#109, (A1)			; wind_new Call ?
		BNE		test_create			; nein -> weiter
;
;	Ein wind_new()-Aufruf -> alle ID's l”schen
;
		MOVEA.L	#kc+IDOFFS,A1
		MOVEQ.L	#-1,D0
		MOVE.L	D0,(A1)+			; id[0-1]
		MOVE.L	D0,(A1)+			; id[2-3]
		MOVE.L	D0,(A1)+			; id[4-5]
		MOVE.L	D0,(A1)				; id[6-7]
		
		BRA		continue_standard
			
test_create:
		CMPI.W	#100, (A1)			; wind_create ?
		BNE		continue_standard

;
;	Ein wind_create(kind)-Aufruf -> kind merken, hinterher
;	ID holen und handle ablegen
;
		MOVE.W	(A2), curr_kind		; kind aus IntIn[0]
		MOVE.W	4(A0), curr_id		; id aus global[2]
		MOVE.L	18(SP),return_sav	; trap-return Adresse sichern
		MOVE.L	#after_create,18(SP); unseren Restore einmogeln

continue_standard:
		MOVEM.L	(A7)+,A0-A2/D0
			
standard_call:
		MOVE.L	XB_AES(PC),-(A7)	; zum normalen GEM-Vektor
		RTS
;
;	Ein wind_create landet hinterher hier
;
after_create:
		MOVE.L	A1,-(A7)
		MOVE.L	D0,-(A7)
		
		MOVE.L	D1,A1
		MOVE.L	12(A1),A1			; IntOut-Adresse

		MOVE.W	(A1), D0			; handle aus IntOut[0]
		LSL.W	#1,D0
		MOVEA.L	#kc+KINDOFFS, A1
		MOVE.W	curr_kind(PC),(A1,D0.W)	; kind ablegen
		LEA.L	WINDOWMAX*2(A1),A1
		MOVE.W	curr_id(PC), (A1,D0.W)	; id ablegen
		
		MOVE.L	D0,(A7)+
		MOVE.L	A1,(A7)+
		
		MOVE.L	return_sav(PC), -(A7)	; weiter
		RTS
			
curr_id:	DS.W	1
curr_kind:	DS.W	1

;
;	Ab hier Sicherung des #2-Vektors!
; 
; XBRA-Header
			DC.L	"XBRARTKC"
XB_GEMDOS:	DC.L	0

my_gemdos:
		MOVE.L	A0, tmp_sv			; A0 sichern
		MOVE.L	A7,A0
		ADD.L	stackcorr(PC),A0
		BTST.B	#5,(A7)				; supervisor?
		BNE		called_in_super
		MOVE.L	USP, A0

called_in_super:
		TST.W	(A0)				; PTERM0 (#0) ??
		BEQ		save_gemtrap		; ja -> sichern
		
		CMPI.W	#76,(A0)			; PTERM ??
		BEQ		save_gemtrap		; ja -> sichern
		
		CMPI.W	#49,(A0)			; PTERMRES ??
		BNE		do_gemdos			; auch nicht -> weiter

save_gemtrap:
		MOVE.L	$88, aes_save		; TRAP #2 sichern

do_gemdos:
		MOVE.L	tmp_sv(PC),A0		; A0 restaurieren
		MOVE.L	XB_GEMDOS(PC),-(A7)
		RTS

; XBRA-Header
			DC.L	"XBRARTKC"
XB_BIOS:	DC.L	0

; jeder Bios-Call landet hier
my_bios:
		BTST.B	#5,(A7)
		BEQ		do_bios				; nur Superaufrufe interessant

		MOVE.L	A0,tmp_sv			; A0 sichern
		MOVE.L	A7,A0
		ADD.L	stackcorr(PC),A0
		
		CMPI.L	#$00050101,(A0)		; Setexc(101,...) ?
		BNE		cont_bios			; anderer Vektor

		MOVE.L	4(A0),A0			; neuer Vektor in's ROM ?
		CMPA.L	rom_start(PC),A0
		BLT		cont_bios			; nicht ins ROM

		MOVE.L	2(SP),return_sav	; trap-return Adresse sichern
		MOVE.L	#restore,2(SP)		; unseren Restore einmogeln

cont_bios:
		MOVE.L	tmp_sv(PC),A0		; A0 restaurieren
			
do_bios:
		MOVE.L	XB_BIOS(PC),-(A7)	; zum alten Bios-Vektor
		RTS

aes_save:		DS.L	1
return_sav:		DS.L	1
tmp_sv:			DS.L	1
			
restore:
		MOVE.L	aes_save(PC), $88		; TRAP #2 sichern
		MOVE.L	return_sav(PC), -(A7)	; weiter
		RTS

		END

; Ende von CLICKHAN.S


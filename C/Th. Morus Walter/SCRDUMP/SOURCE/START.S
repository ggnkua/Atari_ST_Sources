	XDEF errno			; macht den linker glÅcklich, steht sonst im startupcode
	XREF do_althelp
	XDEF dump;
	XREF make_name
	XREF store_img

	even

* Base page structure
	.OFFSET 0
TpaStart:		.DS.L   1
TpaEnd:			.DS.L   1
TextSegStart:	.DS.L   1
TextSegSize:	.DS.L   1
DataSegStart:	.DS.L   1
DataSegSize:	.DS.L   1
BssSegStart:	.DS.L   1
BssSegSize:		.DS.L   1
DtaPtr:			.DS.L   1
PntPrcPtr:		.DS.L   1
Reserved0:		.DS.L   1
EnvStrPtr:		.DS.L   1
Reserved1:		.DS.B   7
CurDrv:			.DS.B   1
Reserved2:		.DS.L   18
CmdLine:		.DS.B   128
BasePageSize:	.DS     0

_p_cookies		equ		$5a0
cookie			equ		'SDMP'

		TEXT

			BRA		do_init

;
;	voreinstellungen/struktur auf die cookie zeigt
;
dump:		DC.L	'TMMW'
			DC.B	"C:\TEMP\SCRDUMP\SCR",0,"                    "
			DC.B	0
		even
			DC.W	0
			DC.L	make_name
			DC.L	store_img
;
; initialisierung
;
do_init:	MOVEA.L	4(A7),A5	; base-page-pointer
			MOVEA.L	#uss,A7

			PEA		initstring
			MOVE.W	#9,-(A7)
			TRAP 	#1			; meldung auf screen
			ADDQ.L	#6,A7

			PEA		init
			MOVE.W	#$26,-(A7)
			TRAP 	#14			; superexec
			ADDQ.L	#6,A7

			TST.W	D0			; fehler ?
			BEQ		quit

			CLR.W	-(A7)
	        MOVE.L  TextSegSize(A5),A0
    	    ADD.L   DataSegSize(A5),A0
	        ADD.L   BssSegSize(A5),A0
    	    ADD.W   #BasePageSize,A0
			MOVE.L	A0,-(A7)
			MOVE.W	#$31,-(A7)
			TRAP 	#1			; ptermres
	
quit: 		PEA		error
			MOVE.W	#9,-(A7)
			TRAP 	#1			; fehlermeldung raus
			ADDQ.L	#6,A7
								
			MOVE.W	#0,-(A7)	; und beenden
			TRAP 	#1			; pterm0

;
;	vbl eintragen 
;		cookie anlegen
;		kbshift-flag adresse ermittlen
;	(wird im supervisor-modus aufgerufen)
; 	  	
init: 		MOVE.W	$454,D0
			LSL.W	#2,D0
			MOVE.L	$456,A0
			MOVEQ	#4,D1		; ersten eintrag auslassen
sloop:		TST.L	0(A0,D1)
			BEQ.B	found_
			ADDQ.W	#4,D1
			CMP.W	D0,D1		; genial ist die schleife aber nicht!!!
			BNE.B	sloop		; warum nicht d0 runterzÑhlen, A0 um 4 erhîhen?

			CLR.W	D0			; war wohl nichts
			RTS					; ganzer vbl belegt, da kann man nichts machen

found_:		LEA		vbl,A1
			MOVE.L	A1,0(A0,D1)

; kb_shift-adresse ermitteln

			MOVE.L	$4F2,A0		; sysbase
			CLR.L	kbshift
			CMP.W	#$0104,2(A0)	; versionsnummer
			BLT		no_kbshift
			MOVE.L	36(A0),kbshift	; kbshift-adresse merken (TOS1.4 required!!)

; cookie eintragen
no_kbshift:	MOVEA.L	_p_cookies,A0
			BEQ		end_cookie	; kann keinen neuer jar erzeugen
			CLR.W	D0
.c_loop:	TST.L	(A0)	
			BEQ		.found
			ADDA.W	#8,A0
			ADDQ.W	#1,D0
			BRA		.c_loop
.found:		MOVE.L	4(A0),D1
			CMP.W	D0,D1
			BLT		end_cookie	; passt nichts mehr rein
			MOVE.L	(A0),8(A0)
			MOVE.L	4(A0),12(A0)
			MOVE.L	#cookie,(A0)
			MOVE.L	#dump,4(A0)

end_cookie:	MOVEQ	#1,D0		; war erfolgreich
			RTS

;
;			vbl-routine
;
;	ALT HELP		-> do_althelp fÅr screendump aufrufen
;	CTRL ALT HELP 	-> nichts tun (-> tos-hcopy)
;	

vbl:		TST.W	$4EE 		; dumpflag ?
			BNE		end_vbl

			movea.l	kbshift,a0
			tst.l	a0
			BEQ		notest
			btst	#2,(a0)		; ctrl ??
			bne		end_vbl		; dann nichts tun

notest:		move.w	#-1,$4EE	; habs gelesen
			sub.l	#46,$4A2
			jsr		do_althelp	; speichern
			add.l	#46,$4A2
end_vbl:	rts

kbshift:	DC.L		0

		DATA

error:		dc.b 	'  kein VBL-Slot frei, nicht installiert '
			dc.b 	$0a,$0d,0

		even

initstring: dc.b	$0A,$0D
			dc.b 	$0A,$0D,$1B,'p'
			dc.b 	'  Extended ALT-HELP  v1.0  10. 4.1994  ',$0a,$0d,$1B,'q'
;					 123456789012345678901234567890123456789
			dc.b 	'    ALT-HELP     : GEM-IMG Screendump',$0a,$0d
			dc.b 	'    CTRL-ALT-HELP: TOS Hardcopy',$0a,$0d
			dc.b 	'  (c) 1994 by TMMW Morus Walter',$0a,$0d
			dc.b 	$0a,$0d,0

		even

			ds.l 	2		; stack fÅr init (wird schon reichen)
uss:		dc.l 	0		; Åberschreibt sonst eh nur die message

errno:		DC.W	0


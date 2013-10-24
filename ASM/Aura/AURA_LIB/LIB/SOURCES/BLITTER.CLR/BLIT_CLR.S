; //////////////////////////////////////////////////////////////////////////
; Speicherbereich via Blitter leerfegen.
;				a0.l	- Startadresse
;				a1.l	- Endadresse

; L”scht auch Bereiche >32767 Bytes...

; Der Blitter ist ein lames Teil.

; (c) 1993 by Jochen Knaus (who	else ???)
; //////////////////////////////////////////////////////////////////////////
WAIT_FOR_BL		EQU		0				; <> 0 => Weg, wenn	Blitter	freigibt.
binaerfile		EQU		0

		IFEQ	binaerfile
				MC68000
				OPT		D-,O+
				ORG		0
				MODUL	"F:\LIB\BLIT_CLR.INC"
				
				bra.s	blitter_clr

				DC.B	'PMOD'
				DC.B	'Blitterl”schen.',0
				DC.B	'BDCannibal/AURA',0
				DC.B	'01930193'
				DC.B	'010000B-'		; Ab 68000, Blitter
				DC.B	'--------'
		ENDIF

blitter_clr:	movem.l	d6-a2,-(SP)

				lea		$FFFF8A00.w,A2	; Blitterbase
				moveq	#-1,d7
				move.w	d7,$28(A2)		; Endmask =	$ffffff
				move.l	d7,$2A(A2)

				move.l	A1,D7			; Endadresse
				sub.l	A0,D7			; L„nge	des	Blocks.
				bmi.w	alles_clean		; L„nge	< 0	=> Abbrechen
				lsr.l	#1,D7			; Blitter "denkt" in Worten

				cmpi.l	#$ffff,D7		; >	32 KBytes terminieren ?
				blt.s	boring

				move.w	D7,D6			; Restwords
				swap	D7				; /(2^16)
				move.w	D7,$38(A2)		; Y-Count=X*65535
				clr.w	$36(A2)			; X-Count=65535
				bra.s	startblit

boring:			move.w	D7,$36(A2)
				move.w	#1,$38(A2)		; Nur "eine	Zeile"
				moveq	#0,D6			; Gleich nur Rest...

startblit:		move.l	#$020000,$2E(A2) ; Destination X Inc.=2	(Word) Y=0
				move.l	A0,$32(A2)		; Destination Adress
				move.l	#$0000c000,$3A(A2) ; HOP/OP/Busy/SKEW (HOG=1)

			IFEQ	WAIT_FOR_BL
wait_blit:		btst	#7,$3C(A2)		; Voller Buszugriff	und	nur	zur
				bne.s	wait_blit		; Sicherheit
			ENDIF

				tst.w	d6
				beq.s	alles_clean
				
				move.w	D6,$36(A2)		; Restanzahl Words zum L”schen ?
;				 beq.s	 alles_clean
				move.w	#1,$38(A2)
				moveq	#0,D6
				bra.s	startblit

alles_clean:	movem.l	(SP)+,d6-a2
				rts

; ---------------------------------------------------------------------------
; Transformationsroutine. 1990 mit Turbo-Ass erstellt.
; April	1993 Anpassung an 68030	und Umsetzung in Devpac.
; Coderight (c)	by BDC/AURA (Jochen Knaus).
; P.S.:	Dies ist eine Top-ST-Transrout,	aber in	Zeiten des DSPs...

; Parameter:	alpha:	DC.W	0,0,0	; Rot.winkel a,b,c
;		a6   :	DC.W	0	; Urpunktstruktur u[0]=Anz. Punkte
;			DC.W	x,y,z	; Urpunkt 1, WORD !
;		a4:			; projezierte Punkte (x/y)
;		x_off, y_off, z_off:	; Screen- bzw. Worldoffsets
; Aufruf "trans".

; PMOD:		a4	- projezierte Punkte
;		a5	- Winkel a,b,c
;		a6	- Urpunktstruktur
; x_off,y_off,z_off:	Offsets	2,4,6
; ---------------------------------------------------------------------------

PMOD		EQU	0

	IFEQ	PMOD
		MC68030
		OPT	D-,O+
		ORG	0
		MODUL	"F:\LIB\TRANS030.INC"

		bra.w	trans
		bra.s	init

x_off:		DC.W	159		; Variablen, mssen initialisiert
y_off:		DC.W	119		; werden.
z_off:		DC.W	0
		
		DC.B	'PMOD'		; PMOD-Header.
		DC.B	'Transforma. 030',0
		DC.B	'BDCannibal/AURA',0
		DC.B	'01900493'
		DC.B	'020120--'
		DC.B	'--------'

; a0 - x/y/z-off
init:		pea	(a1)
		lea	x_off(pc),a1
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)
		move.l	(sp)+,a1
		rts
	ENDIF

trans:		lea	sinus(PC),A0	; Sinustabelle
		lea	cos(PC),A1	; Cosinustabelle
	IFNE	PMOD
		lea	alpha(PC),A2	; Winkel (alpha/beta/gamma [a,b,c])
	ELSE
		move.l	a5,a2
	ENDIF

		move.w	(A2)+,D0	; alpha-Winkel holen
		move.w	(A0,D0.w*2),D6	; sin(à)   Winkelparameter holen
		move.w	(A1,D0.w*2),D7	; cos(à)

		move.w	(A2)+,D0	; beta-Winkel holen
		move.w	(A0,D0.w*2),D4	; sin(á)
		move.w	(A1,D0.w*2),D5	; cos(á)

		move.w	(A2),D0		; gamma-Winkel holen
		move.w	(A0,D0.w*2),D2	; sin(ë)
		move.w	(A1,D0.w*2),D3	; cos(ë)

		movec	cacr,d0
		move.l	d0,-(sp)
		moveq	#0,d0		; Cache	aus, selbstmodif. Code !
		movec	d0,cacr

		move.w	D5,D0		; A=cos(b)*cos(c)
		muls	D7,D0
		add.l	D0,D0
		swap	D0
		move.w	D0,_a+2

		move.w	D5,D0		; B=cos(b)*sin(c)
		muls	D6,D0
		add.l	D0,D0
		swap	D0
		move.w	D0,_b+2

		move.w	D4,D0		; C=-sin(b)
		neg.w	D0
		move.w	D0,_c+2

		move.w	D2,D0		; D=sin(a)*sin(b)*cos(c)-cos(a)*sin(c)
		muls	D4,D0
		add.l	D0,D0
		swap	D0

		movea.w	D0,A0		; sin(a)*sin(b)	wird noch gebraucht

		muls	D7,D0
		move.w	D3,D1
		muls	D6,D1
		sub.l	D1,D0
		add.l	D0,D0
		swap	D0
		move.w	D0,_d+2

		move.w	A0,D0		; E=sin(a)*sin(b)*sin(c)+cos(a)*cos(c)
		muls	D6,D0
		move.w	D3,D1
		muls	D7,D1
		add.l	D1,D0
		add.l	D0,D0
		swap	D0
		move.w	D0,_e+2

		move.w	D2,D0		; F=sin(a)*cos(b)
		muls	D5,D0
		add.l	D0,D0
		swap	D0
		move.w	D0,_f+2

		move.w	D3,D0		; G=cos(a)*sin(b)*cos(c)+sin(a)*sin(c)
		muls	D4,D0
		add.l	D0,D0
		swap	D0

		movea.w	D0,A0		; sin(a)*cos(b)	wird nochmals gebraucht

		muls	D7,D0
		move.w	D2,D1
		muls	D6,D1
		add.l	D1,D0
		add.l	D0,D0
		swap	D0
		move.w	D0,_g+2

		move.w	A0,D0		; H=cos(a)*sin(b)*sin(c)-sin(a)*cos(c)
		muls	D6,D0
		move.w	D2,D1
		muls	D7,D1
		sub.l	D1,D0
		add.l	D0,D0
		swap	D0
		move.w	D0,_h+2

		move.w	D3,D0		; I=cos(a)*cos(b)
		muls	D5,D0
		add.l	D0,D0
		swap	D0
		move.w	D0,_i+2

		move.l	(sp)+,d0	; Cache	wieder an !
		movec	d0,cacr

		move.l	A4,A1		; transformierte Punkte	dahin schaufeln
		move.w	(A6)+,D7	; Anzahl Punkte	(-1)
trans_lp:	movem.w	(A6)+,D0-D2	; P(x/y/z)
		move.w	D0,D3
		move.w	D1,D4
		move.w	D2,D5

_a:		muls	#$00,D0		; x*A
_b:		muls	#$00,D1		; y*B
_c:		muls	#$00,D2		; z*C
		add.l	D2,D0
		add.l	D1,D0
		add.l	D0,D0
		swap	D0

		move.w	D3,D6
		move.w	D4,D1
		move.w	D5,D2
_d:		muls	#$00,D6		; x*D
_e:		muls	#$00,D1		; y*E
_f:		muls	#$00,D2		; z*F
		add.l	D6,D1
		add.l	D2,D1
		add.l	D1,D1
		swap	D1

_g:		muls	#$00,D3		; x*G
_h:		muls	#$00,D4		; y*H
_i:		muls	#$00,D5		; z*I
		add.l	D3,D5
		add.l	D4,D5
		add.l	D5,D5
		swap	D5

		add.w	z_off(PC),D5	; z-Offset VOR Projektion !

; Zx/Zy=0 Zz=1024 => Px=-(Qx*Zz)/(Qz-Zz)
;		     Py=-(Qy*Zz)/(Qz-Zz)

		swap	D0		; swap	  =*65536
		swap	D1		; asr.l	#6=/64	(65536/64=1024)
		clr.w	D0
		clr.w	D1
		asr.l	#7,D0
		asr.l	#7,D1

		sub.w	#512,D5
		divs	D5,D0
		divs	D5,D1
		add.w	x_off(PC),D0	; Screenoffset
		add.w	y_off(PC),D1
		move.w	D0,(A1)+
		move.w	D1,(A1)+

		dbra	D7,trans_lp	; n„chster Punkt transformieren.
		rts

; Cosinus ist phasen(0.5*pi)verschobene Sinuskurve.
sinus:		DC.W $0000,$0189,$0336,$04BF,$0648,$07D0,$097C,$0B04,$0C8C
		DC.W $0E13,$0FBD,$1143,$12C8,$144D,$15F4,$1776,$18F9,$1A7A
		DC.W $1C1D,$1D9C,$1F1A,$2097,$2235,$23AF,$2528,$269F,$2837
		DC.W $29AC,$2B1F,$2C90,$2E22,$2F8F,$30FB,$3266,$33EF,$3555
		DC.W $36BA,$381D,$399C,$3AFA,$3C56,$3DB0,$3F26,$407B,$41CE
		DC.W $431E,$4489,$45D5,$471C,$4862,$49C2,$4B02,$4C3F,$4D7A
		DC.W $4ECE,$5002,$5133,$5262,$53A8,$54D0,$55F5,$5717,$584F
		DC.W $596A,$5A82,$5B96,$5CC0,$5DCD,$5ED7,$5FDD,$60F7,$61F7
		DC.W $62F1,$63E9,$64F3,$65E3,$66CF,$67B7,$68B0,$6990,$6A6D
		DC.W $6B46,$6C2D,$6CFD,$6DCA,$6E91,$6F67,$7027,$70E2,$7199
		DC.W $725C,$730C,$73B5,$745B,$750C,$75A8,$7641,$76D5,$7772
		DC.W $77FD,$7884,$7907,$798F,$7A07,$7A7C,$7AEC,$7B61,$7BC7
		DC.W $7C2A,$7C86,$7CE7,$7D3B,$7D89,$7DD4,$7E20,$7E61,$7E9C
		DC.W $7ED4,$7F0C,$7F38,$7F61,$7F86,$7FA8,$7FC2,$7FD8,$7FE9
		DC.W $7FF5,$7FFD
cos:		DC.W $7FFF,$7FFD,$7FF4,$7FE9,$7FD8,$7FC2,$7FA5
		DC.W $7F86,$7F61,$7F38,$7F07,$7ED4,$7E9C,$7E61,$7E1A,$7DD4
		DC.W $7D89,$7D3B,$7CDF,$7C86,$7C2A,$7BC7,$7B57,$7AEC,$7A7C
		DC.W $7A07,$7984,$7907,$7884,$77FD,$7765,$76D5,$7641,$75A8
		DC.W $74FD,$745B,$73B5,$730C,$724C,$7199,$70E2,$7027,$6F55
		DC.W $6E91,$6DCA,$6CFD,$6C1A,$6B46,$6A6D,$6990,$689C,$67B7
		DC.W $66CF,$65E3,$64DE,$63E9,$62F1,$61F7,$60E0,$5FDD,$5ED7
		DC.W $5DCD,$5CA7,$5B96,$5A82,$596A,$5835,$5717,$55F5,$54D0
		DC.W $538D,$5262,$5133,$5002,$4EB2,$4D7A,$4C3F,$4B02,$49A5
		DC.W $4862,$471C,$45D5,$446B,$431E,$41CE,$407B,$3F07,$3DB0
		DC.W $3C56,$3AFA,$397C,$381D,$36BA,$3555,$33CE,$3266,$30FB
		DC.W $2F8F,$2E00,$2C90,$2B1F,$29AC,$2815,$269F,$2528,$23AF
		DC.W $2212,$2097,$1F1A,$1D9C,$1BFA,$1A7A,$18F9,$1776,$15D0
		DC.W $144D,$12C8,$1143,$0F99,$0E13,$0C8C,$0B04,$0959,$07D0
		DC.W $0648,$04BF,$0312,$0189,$00,$FE77,$FCCA,$FB41,$F9B8
		DC.W $F830,$F684,$F4FC,$F374,$F1ED,$F043,$EEBD,$ED38,$EBB3
		DC.W $EA0C,$E88A,$E707,$E586,$E3E3,$E264,$E0E6,$DF69,$DDCB
		DC.W $DC51,$DAD8,$D961,$D7C9,$D654,$D4E1,$D370,$D1DE,$D071
		DC.W $CF05,$CD9A,$CC11,$CAAB,$C946,$C7E3,$C664,$C506,$C3AA
		DC.W $C250,$C0DA,$BF85,$BE32,$BCE2,$BB77,$BA2B,$B8E4,$B79E
		DC.W $B63E,$B4FE,$B3C1,$B286,$B132,$AFFE,$AECD,$AD9E,$AC58
		DC.W $AB30,$AA0B,$A8E9,$A7B1,$A696,$A57E,$A46A,$A340,$A233
		DC.W $A129,$A023,$9F09,$9E09,$9D0F,$9C17,$9B0D,$9A1D,$9931
		DC.W $9849,$9750,$9670,$9593,$94BA,$93D3,$9303,$9236,$916F
		DC.W $9099,$8FD9,$8F1E,$8E67,$8DA4,$8CF4,$8C4B,$8BA5,$8AF4
		DC.W $8A58,$89BF,$892B,$888E,$8803,$877C,$86F9,$8671,$85F9
		DC.W $8584,$8514,$849F,$8439,$83D6,$837A,$8319,$82C5,$8277
		DC.W $822C,$81E0,$819F,$8164,$812C,$80F4,$80C8,$809F,$807A
		DC.W $8058,$803E,$8028,$8017,$800B,$8003,$8001,$8003,$800C
		DC.W $8017,$8028,$803E,$805B,$807A,$809F,$80C8,$80F9,$812C
		DC.W $8164,$819F,$81E6,$822C,$8277,$82C5,$8321,$837A,$83D6
		DC.W $8439,$84A9,$8514,$8584,$85F9,$867C,$86F9,$877C,$8803
		DC.W $889B,$892B,$89BF,$8A58,$8B03,$8BA5,$8C4B,$8CF4,$8DB4
		DC.W $8E67,$8F1E,$8FD9,$90AB,$916F,$9236,$9303,$93E6,$94BA
		DC.W $9593,$9670,$9764,$9849,$9931,$9A1D,$9B22,$9C17,$9D0F
		DC.W $9E09,$9F20,$A023,$A129,$A233,$A359,$A46A,$A57E,$A696
		DC.W $A7CB,$A8E9,$AA0B,$AB30,$AC73,$AD9E,$AECD,$AFFE,$B14E
		DC.W $B286,$B3C1,$B4FE,$B65B,$B79E,$B8E4,$BA2B,$BB95,$BCE2
		DC.W $BE32,$BF85,$C0F9,$C250,$C3AA,$C506,$C684,$C7E3,$C946
		DC.W $CAAB,$CC32,$CD9A,$CF05,$D071,$D200,$D370,$D4E1,$D654
		DC.W $D7EB,$D961,$DAD8,$DC51,$DDEE,$DF69,$E0E6,$E264,$E406
		DC.W $E586,$E707,$E88A,$EA30,$EBB3,$ED38,$EEBD,$F067,$F1ED
		DC.W $F374,$F4FC,$F6A7,$F830,$F9B8,$FB41,$FCEE,$FE77
		DC.W $0000,$0189,$0336,$04BF,$0648,$07D0,$097C,$0B04,$0C8C
		DC.W $0E13,$0FBD,$1143,$12C8,$144D,$15F4,$1776,$18F9,$1A7A
		DC.W $1C1D,$1D9C,$1F1A,$2097,$2235,$23AF,$2528,$269F,$2837
		DC.W $29AC,$2B1F,$2C90,$2E22,$2F8F,$30FB,$3266,$33EF,$3555
		DC.W $36BA,$381D,$399C,$3AFA,$3C56,$3DB0,$3F26,$407B,$41CE
		DC.W $431E,$4489,$45D5,$471C,$4862,$49C2,$4B02,$4C3F,$4D7A
		DC.W $4ECE,$5002,$5133,$5262,$53A8,$54D0,$55F5,$5717,$584F
		DC.W $596A,$5A82,$5B96,$5CC0,$5DCD,$5ED7,$5FDD,$60F7,$61F7
		DC.W $62F1,$63E9,$64F3,$65E3,$66CF,$67B7,$68B0,$6990,$6A6D
		DC.W $6B46,$6C2D,$6CFD,$6DCA,$6E91,$6F67,$7027,$70E2,$7199
		DC.W $725C,$730C,$73B5,$745B,$750C,$75A8,$7641,$76D5,$7772
		DC.W $77FD,$7884,$7907,$798F,$7A07,$7A7C,$7AEC,$7B61,$7BC7
		DC.W $7C2A,$7C86,$7CE7,$7D3B,$7D89,$7DD4,$7E20,$7E61,$7E9C
		DC.W $7ED4,$7F0C,$7F38,$7F61,$7F86,$7FA8,$7FC2,$7FD8,$7FE9
		DC.W $7FF5,$7FFD,$7fff

* Routine to rotate X,Y,Z around the X axis by angle in XANG
* with start of coordinates in A1

	lea	sintab(pc),a0
	move.w	xang(pc),d0
	and.w	#$ff,d0
	move.b	(a0,d0.w),d1		* Sin into D1
	move.b	64(a0,d0.w),d0		* Cos into D0
	ext.w	d0
	ext.w	d1			* Extend to 16 bitz.
	move.w	2(a1),d3		* Get Y
	move.w	4(a1),d4		* Get Z
	move.w	d3,d5			* Store Y
	move.w	d4,d6			* Store Z
	muls	d0,d3			* Y * Cos
	muls	d1,d4			* Z * Sin
	add.w	d3,d4			* Y=Y*Cos+Z*Sin
	asr.w	#7,d4			* Shrink so we can see!
	mulu	d0,d6			* Z * Cos
	mulu	d1,d5			* Y * Sin
	sub.w	d6,d5			* Z=Z*Cos-Y*Sin
	asr.w	#7,d6			* Shrink so we can see!
	
	move.w	d4,2(a1)		* Store new Y.
	move.w	d6,4(a1)		* Store new Z.

sintab:		* (Stolen from metacomco assembler!)

	dc.b      $00,$03,$06,$09,$0C,$0F,$12,$15   ;   0 to   7
	dc.b      $18,$1B,$1E,$21,$24,$27,$2A,$2D   ;   8 to  15
	dc.b      $30,$33,$36,$39,$3B,$3E,$41,$43   ;  16 to  23
	dc.b      $46,$49,$4B,$4E,$50,$52,$55,$57   ;  24 to  31
	dc.b      $59,$5B,$5E,$60,$62,$64,$66,$67   ;  32 to  39
	dc.b      $69,$6B,$6C,$6E,$70,$71,$72,$74   ;  40 to  47
	dc.b      $75,$76,$77,$78,$79,$7A,$7B,$7B   ;  48 to  55
	dc.b      $7C,$7D,$7D,$7E,$7E,$7E,$7E,$7E   ;  56 to  63
	dc.b      $7E,$7E,$7E,$7E,$7E,$7E,$7D,$7D   ;  64 to  71
	dc.b      $7C,$7B,$7B,$7A,$79,$78,$77,$76   ;  72 to  79
	dc.b      $75,$74,$72,$71,$70,$6E,$6C,$6B   ;  80 to  87
	dc.b      $69,$67,$66,$64,$62,$60,$5E,$5B   ;  88 to  95
	dc.b      $59,$57,$55,$52,$50,$4E,$4B,$49   ;  96 to 103
	dc.b      $46,$43,$41,$3E,$3B,$39,$36,$33   ; 104 to 111
	dc.b      $30,$2D,$2A,$27,$24,$21,$1E,$1B   ; 112 to 119
	dc.b      $18,$15,$12,$0F,$0C,$09,$06,$03   ; 120 to 127
	dc.b      $00,$FD,$FA,$F7,$F4,$F1,$EE,$EB   ; 128 to 135
	dc.b      $E8,$E5,$E2,$DF,$DC,$D9,$D6,$D3   ; 136 to 143
	dc.b      $D0,$CD,$CA,$C7,$C5,$C2,$BF,$BD   ; 144 to 151
	dc.b      $BA,$B7,$B5,$B2,$B0,$AE,$AB,$A9   ; 152 to 159
	dc.b      $A7,$A5,$A2,$A0,$9E,$9C,$9A,$99   ; 160 to 167
	dc.b      $97,$95,$94,$92,$90,$8F,$8E,$8C   ; 168 to 175
	dc.b      $8B,$8A,$89,$88,$87,$86,$85,$85   ; 176 to 183
	dc.b      $84,$83,$83,$82,$82,$82,$82,$82   ; 184 to 191
	dc.b      $82,$82,$82,$82,$82,$82,$83,$83   ; 192 to 199
	dc.b      $84,$85,$85,$86,$87,$88,$89,$8A   ; 200 to 207
	dc.b      $8B,$8C,$8E,$8F,$90,$92,$94,$95   ; 208 to 215
	dc.b      $97,$99,$9A,$9C,$9E,$A0,$A2,$A5   ; 216 to 223
	dc.b      $A7,$A9,$AB,$AE,$B0,$B2,$B5,$B7   ; 224 to 231
	dc.b      $BA,$BD,$BF,$C2,$C5,$C7,$CA,$CD   ; 232 to 239
	dc.b      $D0,$D3,$D6,$D9,$DC,$DF,$E2,$E5   ; 240 to 247
	dc.b      $E8,$EB,$EE,$F1,$F4,$F7,$FA,$FD   ; 248 to 255
	dc.b      $00,$03,$06,$09,$0C,$0F,$12,$15   ; 256 to 263
	dc.b      $18,$1B,$1E,$21,$24,$27,$2A,$2D   ; 264 to 271
	dc.b      $30,$33,$36,$39,$3B,$3E,$41,$43   ; 272 to 279
	dc.b      $46,$49,$4B,$4E,$50,$52,$55,$57   ; 280 to 287
	dc.b      $59,$5B,$5E,$60,$62,$64,$66,$67   ; 288 to 295
	dc.b      $69,$6B,$6C,$6E,$70,$71,$72,$74   ; 296 to 303
	dc.b      $75,$76,$77,$78,$79,$7A,$7B,$7B   ; 304 to 311
	dc.b      $7C,$7D,$7D,$7E,$7E,$7E,$7E,$7E   ; 312 to 319

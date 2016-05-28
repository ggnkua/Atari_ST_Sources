*
*	Installs a Norwegian keymap on the Milan.
*	It works perfectly with my old-style (no Windows-keys) Norwegian
*	AT-keyboard, with the following exceptions:
*
*	- @, ú and $ are not mapped on their AltGr-keys, because this is
*	  not handled on the Milan. It looks like Milan-TOS has hardcoded
*	  AltGr-combos.
*	- @ is mapped on Alt+è.
*	- ú is not mapped at all.
*	- $ is mapped on Shift+4. The odd "sun" which should be there does
*	  not exist in the standard Atari systemfont.
*	- ∫ is not mapped. This is normally a dead-key, which TOS doesn't support.
*	- True to old-style German/Scandinavian keymaps, []{} is mapped on
*	  Alt+≥ë≤í in addition to AltGr+7890. 
*
*	This program is currently only of interest for Norwegian Milan-users,
*	and so far I'm the only one... 
*
*	Ω 2002,	Jo Even Skarstein
*			joska@nvg.org
*			http://joska.nvg.org/
*

		TEXT

		movea.l	4(sp),a0		; Calculate the size of this binary
		move.l	#256,d6
		add.l	12(a0),d6
		add.l	20(a0),d6
		add.l	28(a0),d6
		move.l	d6,pta_size

		pea		msg
		move.w	#9,-(sp)		; Cconws
		trap	#1				; Gemdos
		addq.l	#6,sp

		pea 	tbl_caps
		pea 	tbl_shift
		pea 	tbl_normal
		move 	#16,-(sp)		; Keytbl
		trap	#14				; Xbios
		adda.l	#14,a7

		clr 	-(sp)
		move.l	pta_size,-(sp)
		move 	#49,-(sp)		; Ptermres
		trap	#1				; Gemdos

		DATA

msg:
		dc.b	27,"pInstallerer norsk tastatur",27,"q",13,10,"Ω 2002, Jo Even Skarstein",13,10,10,0

		even
pta_size:
		ds.l	1

tbl_normal: 
		dc.b $00,$1B,$31,$32,$33,$34,$35,$36 * ..123456 
		dc.b $37,$38,$39,$30,$2B,$5C,$08,$09 * 7890+\.. 
		dc.b $71,$77,$65,$72,$74,$79,$75,$69 * qwertyui 
		dc.b $6F,$70,$86,$B9,$0D,$00,$61,$73 * opÜπ..as 
		dc.b $64,$66,$67,$68,$6A,$6B,$6C,$B3 * dfghjkl≥ 
		dc.b $91,$27,$00,$7C,$7A,$78,$63,$76 * ë'.|zxcv 
		dc.b $62,$6E,$6D,$2C,$2E,$2D,$00,$00 * bnm,.-.. 
		dc.b $00,$20,$00,$00,$00,$00,$00,$00 * . ...... 
		dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........ 
		dc.b $00,$00,$2D,$00,$00,$00,$2B,$00 * ..-...+. 
		dc.b $00,$00,$00,$7F,$00,$00,$00,$00 * ....... 
		dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........ 
		dc.b $3C,$00,$00,$28,$29,$2F,$2A,$37 * <..()/*7 
		dc.b $38,$39,$34,$35,$36,$31,$32,$33 * 89456123 
		dc.b $30,$2E,$0D,$00,$00,$00,$00,$00 * 0....... 
		dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........ 
tbl_shift:     
		dc.b $00,$1B,$21,$22,$23,$24,$25,$26 * ..!"#$%& 
		dc.b $2F,$28,$29,$3D,$3F,$60,$08,$09 * /()=?`.. 
		dc.b $51,$57,$45,$52,$54,$59,$55,$49 * QWERTYUI 
		dc.b $4F,$50,$8F,$5E,$0D,$00,$41,$53 * OPè^..AS 
		dc.b $44,$46,$47,$48,$4A,$4B,$4C,$B2 * DFGHJKL≤ 
		dc.b $92,$2A,$00,$DD,$5A,$58,$43,$56 * í*.›ZXCV 
		dc.b $42,$4E,$4D,$3B,$3A,$5F,$00,$00 * BNM;:_.. 
		dc.b $00,$20,$00,$00,$00,$00,$00,$00 * . ...... 
		dc.b $00,$00,$00,$00,$00,$00,$00,$37 * .......7 
		dc.b $38,$00,$2D,$34,$00,$36,$2B,$00 * 8.-4.6+. 
		dc.b $32,$00,$30,$7F,$00,$00,$00,$00 * 2.0.... 
		dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........ 
		dc.b $3E,$00,$00,$28,$29,$2F,$2A,$37 * >..()/*7 
		dc.b $38,$39,$34,$35,$36,$31,$32,$33 * 89456123 
		dc.b $30,$2E,$0D,$00,$00,$00,$00,$00 * 0....... 
		dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........ 
tbl_caps:  
		dc.b $00,$1B,$31,$32,$33,$34,$35,$36 * ..123456 
		dc.b $37,$38,$39,$30,$2B,$5C,$08,$09 * 7890+\.. 
		dc.b $51,$57,$45,$52,$54,$59,$55,$49 * QWERTYUI 
		dc.b $4F,$50,$8F,$B9,$0D,$00,$41,$53 * OPèπ..AS 
		dc.b $44,$46,$47,$48,$4A,$4B,$4C,$B2 * DFGHJKL≤ 
		dc.b $92,$27,$00,$7C,$5A,$58,$43,$56 * í'.|ZXCV 
		dc.b $42,$4E,$4D,$2C,$2E,$2D,$00,$00 * BNM,.-.. 
		dc.b $00,$20,$00,$00,$00,$00,$00,$00 * . ...... 
		dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........ 
		dc.b $00,$00,$2D,$00,$00,$00,$2B,$00 * ..-...+. 
		dc.b $00,$00,$00,$7F,$00,$00,$00,$00 * ....... 
		dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........ 
		dc.b $3C,$00,$00,$28,$29,$2F,$2A,$37 * <..()/*7 
		dc.b $38,$39,$34,$35,$36,$31,$32,$33 * 89456123 
		dc.b $30,$2E,$0D,$00,$00,$00,$00,$00 * 0....... 
		dc.b $00,$00,$00,$00,$00,$00,$00,$00 * ........ 

		END		


; bitmap file: wpcons.rbf (ikonen fuer waffenstandsanzeige)
CONSOLEWEAPONWIDTH		equ	50
CONSOLEWEAPONHEIGHT		equ	220
CONSOLEWEAPONSINGLEHEIGHT	equ	22			; hoehe einer einzelnen ikone

;CONSOLEWEAPONDISTANCEX
;CONSOLEWEAPONDISTANCEY



		text


; ---------------------------------------------------------
; 11.07.00/vk
; laedt die grafik zum zeichnen der waffenstandsanzeige
; (ikonen fuer waffentyp).
initWeaponConsoleFile

		lea	fileIO,a0
		move.l	#wpconsFile,FILENAME(a0)
		move.l	#weaponConsole,FILEBUFFER(a0)
		move.l	#CONSOLEWEAPONWIDTH*CONSOLEWEAPONHEIGHT*2,FILEBYTES(a0)
		bsr	loadFile

		rts


; ---------------------------------------------------------
; 11.07.00/vk
; zeichnet die angegebene waffe in den logischen screen.
; d0 = waffentyp 0..9 (unveraendert)
; rettet alle register
wpconsDrawWeaponIcon
		movem.l	d0-a6,-(sp)

		lea	bmpCWeapon,a2
		moveq	#0,d2
		move.w	#CONSOLEWEAPONSINGLEHEIGHT,d3
		mulu.w	d0,d3
		move.w	#CONSOLEWEAPONWIDTH,d4
		move.w	#CONSOLEWEAPONSINGLEHEIGHT,d5

		movea.l	screen_1,a0
		move.w	wpconsXOffset,d6
		move.w	wpconsYOffset,d7
		bsr	bitBltSizeOffset

		movem.l	(sp)+,d0-a6
		rts



		data

wpconsFile	dc.b	"data\console\wpcons.rbf",0
		even


		bss

wpconsXOffset	ds.w	1					; screenoffset (dx)
wpconsYOffset	ds.w	1					; screenoffset (dy)

weaponConsole	ds.b	CONSOLEWEAPONWIDTH*CONSOLEWEAPONHEIGHT*2

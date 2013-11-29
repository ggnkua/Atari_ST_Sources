* Sam-Edit 2 Cli handler
	SECTION	text
cliHandler
	tst.w	cliLength
	beq	.done

	move.l	cli,a0

; treat as only file passed on cli for now
	stringCopy	a0,#samplePath
	clr.b	(a1)
	move.w	#1,vaStart	; flag to load file
.done
	rts
;--------------------------------------------
	SECTION	bss
noWindows	ds.w	1

;--------------------------------------------
;
; cli settings
;
; <filename> = file to load
; -d2d       = load in d2d mode
; -hide      = no display
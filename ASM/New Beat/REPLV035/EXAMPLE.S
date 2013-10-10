
example:
		INCLUDE	"REPLACE.DEF"

		nop

		move.l	4(sp),a0		; Address to basepage
		move.l	12(a0),d0		; Length of TEXT segment
		add.l	20(a0),d0		; Add length of DATA segment
		add.l	28(a0),d0		; Add length of BSS segment
		add.l	#256,d0			; Add length of Basepage

		;// Mshrink

		move.l	d0,-(sp)
		move.l	a0,-(sp)
		move.w	#0,-(sp)
		move.w	#$4A,-(sp)
		trap	#1
		lea	10(sp),sp

		;// Super

		move.l	#0,-(sp)
		move.w	#$0020,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_ssp

		lea	_filter_table,a0	; No FPU
		move.l	#REPLACE_INITIALIZE,d0
		jsr	replace
		cmp.w	#REPLACE_OK,d0
		bne	.exit

		lea	_module,a0
		move.l	#REPLACE_INITIALIZE_MODULE,d0
		jsr	replace
		cmp.w	#REPLACE_OK,d0
		bne	.exit

		move.l	#REPLACE_START_INTERRUPT,d0
		jsr	replace
		cmp.w	#REPLACE_OK,d0
		bne	.exit

		move.l	#50,d1
		move.l	#REPLACE_SET_VOLUME,d0
		jsr	replace
		cmp.w	#REPLACE_OK,d0
		bne	.exit

		move.l	#REPLACE_PLAY_SONG,d0
		jsr	replace
		cmp.w	#REPLACE_OK,d0
		bne	.exit

.wait_esc:	cmp.b	#1,$fffffc02
		bne.s	.wait_esc

		move.l	#REPLACE_STOP_SONG,d0
		jsr	replace
		cmp.w	#REPLACE_OK,d0
		bne.s	.exit

		move.l	#REPLACE_REMOVE_MODULE,d0
		jsr	replace
		cmp.w	#REPLACE_OK,d0
		bne.s	.exit

		move.l	#REPLACE_EXIT,d0
		jsr	replace
.exit:
		move.l	old_ssp,-(sp)
		move.w	#$0020,-(sp)			; Super()
		trap	#1
		addq.l	#6,sp

		move.w	#$0000,-(sp)			; Pterm0()
		trap	#1

		dc.l	0

		SECTION DATA

.r:		incbin	"replace.bin"
replace:	equ	.r+28

_module:	incbin	"400beats.am"
		dc.l	0

_filter_table:	incbin	"f32.dat"

		SECTION BSS
			ds.l	1

old_ssp:		ds.l	1
			ds.l	1024
usp_stack:		ds.l	1024

		SECTION TEXT



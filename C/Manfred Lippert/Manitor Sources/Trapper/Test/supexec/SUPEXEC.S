		.text

; Programmgr”že ermitteln, Mshrink

		move.l	4(sp),a0

; NEU 1 !!!!!!!!!!!!!!!!
;move.l #stackend,sp

		move.l #$100,a6
		add.l	$0c(a0),a6
		add.l	$14(a0),a6
		add.l	$1c(a0),a6

		move.l	a6,_PgmSize

      move.l	a6,-(sp)
      move.l	a0,-(sp)
      move.w	#0,-(sp)
      move.w	#74,-(sp)
      trap	#1
      lea		12(sp),sp

; Hallo!

/*
		pea		vor_supexec_txt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
*/

		clr.l -(sp)
		move.w #32,-(sp)
		trap #1
		addq.l #6,sp
		move.l d0,-(sp)

; Supexec

/*
		pea		supexec_func(pc)
		move.w	#$26,-(sp)
		trap	#14
		addq.l	#6,sp
*/

	move.w #2,-(sp)
	trap #14
	addq.l #2,sp

	move.w #32,-(sp)
	trap #1
	addq.l #6,sp

; Servus ...

/*
		pea		nach_supexec_txt(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
*/

; Ende

		clr.l	-(sp)
		trap	#1


; ----------------------------------------------

supexec_func:

		nop
; macht nicht sonderlich viel ;-)

		rts

		.data

/*
vor_supexec_txt:
		dc.b	27,'p'
		dc.b	'- vor  Supexec -',27,'q',13,10,0
nach_supexec_txt:
		dc.b	27,'p'
		dc.b	'- nach Supexec -',27,'q',13,10,0
*/

		.bss

; NEU 2 !!!!!!!!!!!!!!!!
stack:
;		ds.l 1024
stackend:
;		ds.l 4

_PgmSize:
		ds.l	0

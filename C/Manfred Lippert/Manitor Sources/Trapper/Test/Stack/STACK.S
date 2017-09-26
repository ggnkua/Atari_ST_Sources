.import main
.export get_stack
.export _PgmSize

		.text

; Programmgr”že ermitteln, Mshrink

		move.l	4(sp),a0

		move.l a0,a5

; NEU 1 !!!!!!!!!!!!!!!!
;move.l #stackend,sp

		move.l	#$100,a6
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

move.l sp,a0
move.l a5,a1
jsr main

		clr.l	-(sp)
		trap	#1

get_stack:
		move.l sp,d0
		rts

		.bss

; NEU 2 !!!!!!!!!!!!!!!!
stack:
;		ds.l 1024
stackend:
;		ds.l 4

_PgmSize:
		ds.l	0

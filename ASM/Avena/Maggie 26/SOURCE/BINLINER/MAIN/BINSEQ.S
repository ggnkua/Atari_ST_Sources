;
; binliner script file
;
; version 0.0
;
;
;
;
;

		include	system\shared.s

;-----------------------------------------------------------------------
init_system	MACRO
		dc.l	"SYS_"
		ENDM

load		MACRO
		dc.l	"LOAD",\1
		ENDM

startprog		MACRO
		dc.l	"STPR",\1
		ENDM

music		MACRO
		dc.l	"MUSI"
		ENDM

startup		MACRO				;initialize routs of effect
		dc.l	"STRT",\1,\2
		ENDM

message		MACRO				;send message to prog
		dc.l	"MESS",\1,\2
		ENDM

session		MACRO				;clear for session
		dc.l	"SESS",\1,\2
		ENDM

setend		MACRO				;set end frame flag
		dc.l	"SETE",\1,\2,\3
		ENDM

doseq		MACRO				;clear for sequence
		dc.l	"SEQ_",\1,\2
		ENDM

frames		MACRO				;do frames
		dc.l	"FRAM",\1,\2
		ENDM

seqend		MACRO				;end sequence
		dc.l	"SEQE",\1,\2
		ENDM

sessend		MACRO				;end session
		dc.l	"SESE",\1,\2
		ENDM

shutdown	MACRO				;shut down effect
		dc.l	"SHUT",\1,\2		;(free mem etc)
		ENDM

unload		MACRO				;clear whole prog
		dc.l	"END_",\1
		ENDM

end_all		MACRO				;bye bye
		dc.l	"FADE"	
		ENDM

quit		MACRO
		dc.l	"QUIT"
		ENDM
;-----------------------------------------------------------------------
main_script:

	init_system

	music
	load		mainprog
	startprog	mainprog

	startup		mainprog,fx1
	session		mainprog,fx1
	startup		mainprog,foet
	session		mainprog,foet


	;message		mainprog,foet
	;dc.l	0,0,0,0

	
	setend		0,$01,$00
	doseq		mainprog,fx1
	frames		mainprog,fx1
	seqend		mainprog,fx1
	setend		0,$01,$20
	doseq		mainprog,foet
	frames		mainprog,foet
	seqend		mainprog,foet
	setend		0,$02,$00
	doseq		mainprog,fx1
	frames		mainprog,fx1
	seqend		mainprog,fx1
	setend		0,$02,$20
	doseq		mainprog,foet
	frames		mainprog,foet
	seqend		mainprog,foet












	sessend 	mainprog,foet
	shutdown	mainprog,foet
	sessend 	mainprog,fx1
	shutdown	mainprog,fx1

	unload		mainprog		;deinit
	end_all	
	quit

;-----------------------------------------------------------------------
;	program buffers

mainprog:
		dc.l	0			;address where loaded
						;filled by the loader
		dc.l	1000000			;memory req!
		dc.w	0
		dc.b	"prg\binmain.prg",0
		even




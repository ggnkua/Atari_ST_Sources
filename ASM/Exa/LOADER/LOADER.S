  	include	MACRO&CO.S
	TEXT
BOOM
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	big_pile,a7
	move.l	#FIN,FIN_PTR
	jsr	SAVE_ALL
	
	jsr	INIT_TRAP
	move.l	#PLAYER,$40c+4.w	
	bsr	player+of_reloc
	bsr	load_module
	
	move.l	MOD_PTR,a0
	bsr	player+of_mt_init	
	bsr	player+of_init		
	
	move.l	#VBL,$70.w
	move.w	#$2100,sr	
	move.w	#0,player+of_master_vol		
	move.w	#400,player+of_inc_vol		
	st	player+of_playing		

	vsync	
	asave_video
	asave_screen
	;asave_palette
	vsync
	bsr	INTRO1
	bsr	AMOUR1
	bsr	CHATO1
	bsr	PLASMA1
	bsr	FRACTAL1

FOLKS
	vsync
	cmp.b	#$39,$fffffc02.W
	bne.s	folks

	sf	player+of_playing		;on coupe le player
	vsync
	arestore_video
	arestore_screen
	arestore_palette
	vsync
		
	bsr	player+of_mt_end		;restitue la configuration initiale 
	bsr	RESTORE_ALL
	
	MOVE.W	#1,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#8,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#$8B,-(A7)
	TRAP	#14
	LEA	12(A7),A7
	MOVE.W	#0,-(A7)
	MOVE.W	#$84,-(A7)
	TRAP	#14
	addq	#4,A7
	
	clr.w	-(sp)
	trap	#1	
	

VBL
	trap	#3
	addq.l	#1,$466.w
	trap	#4
	rte
INTRO1	
;*************** INTRO ****************
	lea	INTRO,a0
	move.l	FIN_PTR,a1
	move.l	#1024*4096,d0
	bsr	LOAD_FILE
	move.l	FIN_PTR,a0
	bsr	DEPACK
	move.l	FIN_PTR,a0
	bsr	RELOC
	jsr	([FIN_PTR.l])
	rts

FRACTAL1	
;*************** INTRO ****************
	lea	FRACTAL,a0
	move.l	FIN_PTR,a1
	move.l	#1024*4096,d0
	bsr	LOAD_FILE
	move.l	FIN_PTR,a0
	bsr	DEPACK
	move.l	FIN_PTR,a0
	bsr	RELOC
	jsr	([FIN_PTR.l])
	rts
	
AMOUR1	
;*************** AMOUR ****************
	lea	AMOUR,a0
	move.l	FIN_PTR,a1
	move.l	#1024*4096,d0
	bsr	LOAD_FILE
	move.l	FIN_PTR,a0
	bsr	DEPACK
	move.l	FIN_PTR,a0
	bsr	RELOC
	jsr	([FIN_PTR.l])
	rts
CHATO1
;**********    CHATO  ******************
	lea	CHATO,a0
	move.l	FIN_PTR,a1
	move.l	#1024*4096,d0
	bsr	LOAD_FILE
	move.l	FIN_PTR,a0
	bsr	DEPACK
	move.l	FIN_PTR,a0
	bsr	RELOC
	move.l	a0,a1
	lea	CHATO_DAT,a0
	move.l	a1,BUFFER+parametre1
	move.l	#1024*4096,d0
	bsr	LOAD_FILE
	jsr	([FIN_PTR.l])
	rts
;**********    PLASMA  ******************
PLASMA1
	lea	PLASMA,a0
	move.l	FIN_PTR,a1
	move.l	#1024*4096,d0
	bsr	LOAD_FILE
	move.l	FIN_PTR,a0
	bsr	DEPACK
	move.l	FIN_PTR,a0
	bsr	RELOC
	jsr	([FIN_PTR.l])
	rts
;**************************************

load_module
	lea	DOH,a0
	move.l	FIN_PTR,a1
	move.l	#1024*4096,d0
	bsr	LOAD_FILE
	move.l	FIN_PTR,a0
	move.l	a0,MOD_PTR
	cmp.l	#'ATM5',(a0)
	bne.s	.no_cpt	
	move.l	4(a0),d0
	add.l	d0,FIN_PTR
	bsr	DEPACK
	add.l	#3000*31,FIN_PTR	;secu secu
	rts
.no_cpt	
	add.l	file_lenght,a0
	move.l	a0,fin_ptr
	add.l	#3000*31,FIN_PTR	;secu secu
	rts
	


	include	CONFIG.S
	include	FAL_REZ2.S
	TEXT

LOAD_FILE
	move.l	a0,file_ptr
	move.l	a1,buf_ptr
	move.l	d0,file_lenght
		
	clr.w	-(sp)
	move.l	file_ptr,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,fhandle	

	MOVE.L	buf_ptr,-(SP)
	move.l	file_lenght,-(sp)
	move.w	fhandle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.w	#12,sp
	move.l	d0,file_lenght
		
	move.w	fhandle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
	rts
file_ptr	ds.l	1
buf_ptr		ds.l	1
file_lenght	ds.l	1
fhandle		ds.w	1

	
DEPACK	incbin	d:\sources\depack35.PRG
	
	INCLUDE	D:\SOURCES\RELOC.S
player	incbin	d:\sources\loader\zpy_bin.prg

;**** FICHIERS ***
DOH	dc.b	'd:\musique\modules\fullmoon.mod',0
;DOH	dc.b	'd:\sources\loader\fullmoon.mod',0

INTRO	dc.b	'd:\sources\source.6\intro\introsnd.prg',0
	even
AMOUR	dc.b	'd:\sources\amour\amoursnd.prg',0
	even
CHATO	dc.b	'd:\sources\new_chat.o\aff_snd.prg',0
	even
CHATO_DAT	dc.b	'd:\sources\new_chat.o\A.DAT',0
	even
PLASMA	dc.b	'd:\sources\plasma\good_snd.prg',0
	even
FRACTAL	dc.b	'd:\sources\fractal\fract10.prg',0
	even
	BSS
FIN_PTR	ds.l	1
MOD_PTR	ds.l	1
	ds.l	10000	
big_pile
FIN
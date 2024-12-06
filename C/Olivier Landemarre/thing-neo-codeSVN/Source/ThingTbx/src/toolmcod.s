;==========================================================================
;TOOLMCOD.S
;
;Assemblerroutinen der Toolbox
;==========================================================================

	globl	get_oshdr
	globl	get_twin

	text
	
;--------------------------------------------------------------------------
;Zeiger auf den OS-Header holen
;
;Deklaration: OSHEADER *get_oshdr(void)
;--------------------------------------------------------------------------

module get_oshdr
	pea			get_oshdr1(pc)
	move.w	#38,-(sp)		; Supexec()
	trap		#14
	addq.l	#6,sp
	move.l	d0,a0
	rts

get_oshdr1:
	move.l	$4f2,d0
	rts
endmod

	end

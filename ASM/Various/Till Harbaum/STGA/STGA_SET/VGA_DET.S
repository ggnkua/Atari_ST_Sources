	.globl detect_vga, reboot

reboot:
	clr.l	-(sp)	
	move	#$20,-(sp)		; Supervisor an
	trap	#1

	move	#$2700,sr		; Ints sperren
	
	move.l	$4f2,a0			; _sysbase-Pointer holen
	move.l	4(a0),a0		; os_start-Pointer holen
	
	jmp		(a0)			; und Abflug ...
	
detect_vga:
	movem.l	d1-d7/a0-a6,-(sp)
	clr.l	-(sp)	
	move	#$20,-(sp)		; Supervisor an
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)
	move.l	8,a0			; Busfehler-Trap merken
	move.l	sp,a1			; Stackpointer merken
	move.l	#end_trap1,8	; Trap setzen
	clr		d7				; keine VGA
	move.b	$d003c3,d0		; VOFA testen
	move	#1,d7			; VOFA-Flag
	bra.s	end_trap2
end_trap1:	
	move.l	a1,sp			; Stack restaurieren
	move.l	#end_trap2,8
	move.b	$cf03c3,d0		; STGA testen	
	move	#2,d7			; STGA-Flag
end_trap2:
	move.l	a1,sp			; Stack restaurieren
	move.l	a0,8			; Trap restausrieren
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp			; Supervisor aus
	move	d7,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts
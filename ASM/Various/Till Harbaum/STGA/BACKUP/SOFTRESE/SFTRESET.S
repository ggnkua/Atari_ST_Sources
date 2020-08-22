;
;	Soft-Reset-Auslîser, startet das System neu, ohne 
;	den Bildschirmmodus der STGA auszuschalten
;	(c)1993 Till Harbaum
;

	output	sftreset.tos

	clr.l	-(sp)			; Supervisor an
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move	#$2700,sr		; Ints sperren
	
	move.l	$4f2,a0			; _sysbase-Pointer holen
	move.l	4(a0),a0			; os_start-Pointer holen
	addq.l	#6,a0			; RESET-Befehl Åbergehen
	
	jmp		(a0)			; und Abflug ...
	
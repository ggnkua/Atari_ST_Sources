;
; Extension de signe d'un mot de 24 bits
;

	globl	Ext24;

Ext24:
	swap	d0
	ext.w	d0
	swap	d0
	rts
	
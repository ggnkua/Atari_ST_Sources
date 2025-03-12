;*************************************************************************
;** XBios-Patch fr TurboC
;**
;**         Friedel van Megen
;**         H”fflerstraže 25a
;**         6750 Kaiserslautern
;** 
;*************************************************************************

gemdos	equ	1
Cconws	equ	9	;schreibe String
Ptermres	equ	49	;Terminate but stay resident

xbios	equ	14
Supexec	equ	38	;exec in Supervisormode
Setscreen	equ	5	;Set screenbase

v_trp14	equ	$b8	;Trap #14 Vektor

p_start	bra	p_init	;zum Start!

;********************************************************************
;** patch as patch can...
;********************************************************************
inst_vec	move.l	v_trp14,sv_trp14	;Trap #14 Vektor patchen
	move.l	#new_trp14,v_trp14
	rts

;********************************************************************
;** neuer TRAP #14 handler, XBRA-tauglich, Kennung 'PBIT'
;********************************************************************
	dc.l	'XBRA'
	dc.l	'PBIT'
sv_trp14	dc.l	0		;savearea fr trap #14 vektor
new_trp14	move.l	a7,a0		;welchen Stackpointer soll ich benutzen
	addq.l	#6,a0		;(das SR wird in jedem Fall auf dem SSP abgelegt)
	move.w	(sp),d1		;Statusregister holen
	btst	#13,d1
	bne.s	in_supm		;ok, Supervisor
	move.l	usp,a0		;Aufruf aus USER-Mode
in_supm	move.w	(a0)+,d0		;Funktionscode
	cmp.w	#Setscreen,d0	;Soll ich was machen ??
	bne.s	end_ein		;N™ ->

	move.l	#-1,(a0)		;verhindern, daž die Bildschirmadresse
	move.l	#-1,4(a0)		;ge„ndert wird

end_ein  	move.l	sv_trp14,a0
	jmp	(a0)		;dann eben nicht....
p_end	nop

;********************************************************************
;** initialisieren...
;********************************************************************
p_init	pea	copy_msg			;Nur mein NAME....
	move.w	#Cconws,-(sp)
	trap	#gemdos
	addq.l	#6,sp	

	dc.w	$a000			;LineA Parameterblock holen
	moveq.l	#80,D0	;Bytes pro Zeile (bei 'normaler' Aufl”sung)
	mulu.w	(A0),D0
	sub.w	2(A0),D0			;akt. Anzahl Bytes pro Zeile
	bpl	no_big_scr		;nur die normale Aufl”sung

	pea	on_msg			;Dies ist was Hyperm„žiges
	move.w	#Cconws,-(sp)
	trap	#gemdos
	addq.l	#6,sp	
	pea	inst_vec			;nur noch Vektoren patchen
	move.w	#Supexec,-(sp)
	trap	#xbios
	addq.l	#6,sp
	move.w	#0,-(sp)			;wir bleiben resident !
	move.l	#$100+p_end-p_start,-(sp)
	move.w	#Ptermres,-(sp)
	trap	#gemdos			;Das war's.....

no_big_scr pea	not_on_msg
	move.w	#Cconws,-(sp)
	trap	#gemdos
	addq.l	#6,sp	
	clr.w	-(sp)
	trap	#gemdos			;Nicht resident

;********************************************************************
;** DATA
;********************************************************************
	data
copy_msg	dc.b	13,10,"Setscreen manager V1.0",10,13
	dc.b	"(C) 1990 Friedel van Megen",13,10,0
not_on_msg dc.b	"NOT "
on_msg	dc.b	"INSTALLED...",13,10,0
	end



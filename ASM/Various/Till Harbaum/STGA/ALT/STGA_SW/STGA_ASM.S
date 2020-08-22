;
;	Assemblerteil fÅr INIT_VGA	(c) 1992 by Till Harbaum
;

.globl	clear_mem,adapter_ist_da
IOBASE	equ		$cf0000

;
;	Anzahl Bytes ab Adresse lîschen
;
clear_mem:
	lsr.l	#2,d0		; Anzahl Bytes durch vier teilen
cl_lp:
	clr.l	(a0)+		; lîschen
	subq.l	#1,d0
	bne.b	cl_lp
	rts
	
;
;	Testen, ob Adapter da ist
;	0 - kein Adapter da
;	1 - Adapter da
;
adapter_ist_da:
	movem.l	d1-d7/a0-a6,-(sp)
	pea		bus_error			; Busfehler verbiegen
	move	#2,-(sp)
	move	#5,-(sp)
	trap	#13
	addq.l	#8,sp
    move.l  d0,old_be

    move    #1,vga_adap        	; Adapter-Flag setzen

    move.b  #$01,IOBASE+$3c3 	; Karte freigeben
    nop
    nop                     	; fÅr eventuellen Busfehler
be_ret:
	move.l	old_be,-(sp)		; Busfehler restaurieren
	move	#2,-(sp)
	move	#5,-(sp)
	trap	#13
	addq.l	#8,sp

	movem.l	(sp)+,d1-d7/a0-a6
    move	vga_adap,d0
    rts

;
;	evtl. Busfehler abfangen
;
bus_error:
    clr     vga_adap        	; Adapter-Flag lîschen
    addq.l  #8,sp           	; SP korrigieren
    move.l  #be_ret,2(sp)   	; RÅcksprung korrigieren
    rte

old_be:		dc.l	0		; alter Busfehler-Vektor
vga_adap:	dc.w	0		; Adapterflag

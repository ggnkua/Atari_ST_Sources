; Timer-Routine
; 
.EXPORT	install
.EXPORT	counter

.TEXT
install:
; Routine einh„ngen
		pea			nrepeat					;neuer Vektor
		move.w	#256,-(sp)			;etv_timer
		move.w	#5,-(sp)				;Setexc
		trap		#13							;BIOS
		move.l	d0,tivec				;alten Vektor merken
		addq.l	#8,sp

		rts
		
		.EVEN

; XBRA-Kennung

		.DC.B		"XBRA"
		.DC.B		"SLIP"
tivec:
		.DS.L		1		

;Routine, die den Z„hler erh”ht
nrepeat:
		addq.w	#1,counter
nend:
		move.l  tivec,-(sp)
		rts
		
counter:
		.DS.B 2
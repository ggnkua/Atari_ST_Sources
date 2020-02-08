;********* Programm zum Auschalten der Caches
;
; nur mit einem Assembler der >=68020 Code erzeugen kann
; zu assemblieren !!!  

xbios  equ 14
gemdos equ 1
		
		pea  cache_off
		move.w	#$26,-(SP)
		trap	#xbios
		addq.l	#6,sp
		
		
		clr.w   -(sp)
	    trap	#gemdos

cache_off:
		
		movec   cacr,d0
		andi #$fefe,d0 ;Ausschalten der Caches
;		ORI #$3111,d0 ;Einschalten der Caches 
		movec   d0,cacr
		
		rts
		
end
		
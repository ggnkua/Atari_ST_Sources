;********* Programm zum beschr„nken des ST - RAM's 
;
;

speicher equ 524288 ;Speicher auf den beschr„nkt wird

xbios  equ 14
gemdos equ 1
		
		pea  memo_down
		move.w	#$26,-(SP)	;SUPEREXEC
		trap	#xbios
		addq.l	#6,sp
		
		
		clr.w   -(sp)
    trap	#gemdos

memo_down:
		
		move.l	#speicher,$42e.w ;Phystop (nicht Memtop !!!)
		move.l	4,-(sp)	;RESET
		move.w	#38,-(sp)
		trap		#14
		
		rts
		
end
		
;********* Programm zum verz”gern des Falcon030 
;
;


xbios  equ 14
gemdos equ 1
		
		pea  memo_down
		move.w	#$26,-(SP)	;SUPEREXEC
		trap	#xbios
		addq.l	#6,sp
		
		
		clr.w   -(sp)
    trap	#gemdos

memo_down:
		
		bclr		#0,$ffff8007.w ; drosselt Falcon
		
end
		
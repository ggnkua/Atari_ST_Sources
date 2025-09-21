                EXPORT  appl_tplay
                IMPORT  aes, intin, addrin

appl_tplay:	movem.w D0-D1,intin
                move.l  A0,addrin
                move.l	#$0E020101,D0
		bra     aes



                EXPORT  appl_trecord
                IMPORT  aes, intin, addrin

appl_trecord:	move.w  D0,intin
                move.l  A0,addrin
                move.l	#$0F010101,D0
		bra     aes



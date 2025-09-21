                EXPORT  menu_unregister
                IMPORT  aes, intin

menu_unregister:move.w	D0,intin
		move.l	#$24010100,D0
		bra	aes


			Include	D:\Jaguar\Include\Objlist.Inc

System_Setup		Lea	$200000.l,a7
			Lea	(HARDWARE).l,a5
			Bsr	Screen_Black
			Bsr	VideoInit
			Jmp	Program_Start(pc)

Screen_Black		Move.l	#$0,BG(a5)
			Move.l	#$0,BORD1(a5)
			Rts

			Include	Video.s
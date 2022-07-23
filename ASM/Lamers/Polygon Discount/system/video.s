; 	VIDEO
video_vga_160x200x16:
        MOVE.L   #$620046,$FFFF8282.W
        MOVE.L   #$A024D,$FFFF8286.W
        MOVE.L   #$46004B,$FFFF828A.W
        MOVE.L   #$41903FF,$FFFF82A2.W
        MOVE.L   #$3F008D,$FFFF82A6.W
        MOVE.L   #$3AD0415,$FFFF82AA.W
        MOVE.W   #$200,$FFFF820A.W
        MOVE.W   #$186,$FFFF82C0.W
        CLR.W    $FFFF8266.W
        MOVE.W   #$100,$FFFF8266.W
        MOVE.W   #$1,$FFFF82C2.W
        MOVE.W   #$A0,$FFFF8210.W
		rts
		
video_rgb_320x100x16:
		move.l   #$c700a0,$ffff8282.w
		move.l   #$1f0003,$ffff8286.w
		move.l   #$9b00ab,$ffff828a.w
		move.l   #$2710265,$ffff82a2.w
		move.l   #$2f0081,$ffff82a6.w
		move.l   #$211026b,$ffff82aa.w
		move.w   #$200,$ffff820a.w
		move.w   #$185,$ffff82c0.w
		clr.w    $ffff8266.w
		move.w   #$100,$ffff8266.w
		move.w   #$1,$ffff82c2.w
		move.w   #$140,$ffff8210.w
		rts

video_320x200x16:
		cmp.w	#0,monitor
		bne.s	_rgb50_16bit_320_200		
		move.l   #$c6008D,$ffff8282.w
		move.l   #$1502ac,$ffff8286.w
		move.l   #$8D0097,$ffff828a.w
		move.l   #$41903ff,$ffff82a2.w
		move.l   #$3f008D,$ffff82a6.w
		move.l   #$3aD0415,$ffff82aa.w
		move.w   #$200,$ffff820a.w
		move.w   #$186,$ffff82c0.w
		clr.w    $ffff8266.w
		move.w   #$100,$ffff8266.w
		move.w   #$5,$ffff82c2.w
		move.w   #$140,$ffff8210.w
		rts
_rgb50_16bit_320_200
		move.l   #$c700a0,$ffff8282.w
		move.l   #$1f0003,$ffff8286.w
		move.l   #$9b00ab,$ffff828a.w
		move.l   #$2710265,$ffff82a2.w
		move.l   #$2f0081,$ffff82a6.w
		move.l   #$211026b,$ffff82aa.w
		move.w   #$200,$ffff820a.w
		move.w   #$185,$ffff82c0.w
		clr.w    $ffff8266.w
		move.w   #$100,$ffff8266.w
		move.w   #$0,$ffff82c2.w
		move.w   #$140,$ffff8210.w
		rts


video_320x240x16:
		cmp.w	#0,monitor
		bne.s	_rgb50_16bit_320_240
		move.l   #$c6008D,$ffff8282.w
		move.l   #$1502ac,$ffff8286.w
		move.l   #$8D0097,$ffff828a.w
		move.l   #$41903ff,$ffff82a2.w
		move.l   #$3f003D,$ffff82a6.w
		move.l   #$3fD0415,$ffff82aa.w
		move.w   #$200,$ffff820a.w
		move.w   #$186,$ffff82c0.w
		clr.w    $ffff8266.w
		move.w   #$100,$ffff8266.w
		move.w   #$5,$ffff82c2.w
		move.w   #$140,$ffff8210.w
		rts
_rgb50_16bit_320_240
		move.l   #$c700a0,$ffff8282.w
		move.l   #$1f0003,$ffff8286.w
		move.l   #$9b00ab,$ffff828a.w
		move.l   #$2710265,$ffff82a2.w
		move.l   #$2f0059,$ffff82a6.w
		move.l   #$239026b,$ffff82aa.w
		move.w   #$200,$ffff820a.w
		move.w   #$185,$ffff82c0.w
		clr.w    $ffff8266.w
		move.w   #$100,$ffff8266.w
		move.w   #$0,$ffff82c2.w
		move.w   #$140,$ffff8210.w
		rts


vga60_16bit_320_240:
		rts
		
video_320x100x8rgb:
		move.l   #$c700a0,$ffff8282.w
		move.l   #$1f02ba,$ffff8286.w
		move.l   #$8900ab,$ffff828a.w
		move.l   #$2710265,$ffff82a2.w
		move.l   #$2f0081,$ffff82a6.w
		move.l   #$211026b,$ffff82aa.w
		move.w   #$200,$ffff820a.w
		move.w   #$185,$ffff82c0.w
		clr.w    $ffff8266.w
		move.w   #$10,$ffff8266.w
		move.w   #$1,$ffff82c2.w
		move.w   #$a0,$ffff8210.w
		rts		

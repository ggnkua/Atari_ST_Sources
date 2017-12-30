; VIDEO-modes available

; VGA (60 & 100Hz)  RGB (50 & 60Hz)
; 160*100 8bit      320*100 8bit
; 160*120 8bit      320*120 8bit
; 320*200 8bit      320*200 8bit
; 320*240 8bit      320*240 8bit
; 640*400 8bit      640*400 8bit
; 640*480 8bit      640*480 8bit

; 160*100 16bit     320*100 16bit
; 320*100 16bit
; 160*120 16bit     320*120 16bit
; 320*200 16bit     320*200 16bit
; 320*240 16bit     320*240 16bit

; Notes:
; For the lower resolutions in RGB mode,
; manual pixeldoubling in X has to be
; made, there's no way to obtain real
; 2*2 hardwaremode on RGB.
; Also, the RGB modes are all in "cinemascope"
; mode for total overscan.


; --------------------------------------------------------------
; ------------- VGA 8bit 60Hz ----------------------------------
; --------------------------------------------------------------
 
vga60_8bit_160_100:
	move.l   #$620046,$ffff8282.w
	move.l   #$a023b,$ffff8286.w
	move.l   #$34004b,$ffff828a.w
	move.l   #$41903ff,$ffff82a2.w
	move.l   #$3f0155,$ffff82a6.w
	move.l   #$2e50415,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$50,$ffff8210.w
	rts

vga60_8bit_160_120:
	move.l   #$620046,$ffff8282.w
	move.l   #$a023b,$ffff8286.w
	move.l   #$34004b,$ffff828a.w
	move.l   #$41903ff,$ffff82a2.w
	move.l   #$3f012D,$ffff82a6.w
	move.l   #$30D0415,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$50,$ffff8210.w
	rts

vga60_8bit_320_200:
	move.l   #$c6008D,$ffff8282.w
	move.l   #$15029a,$ffff8286.w
	move.l   #$7b0097,$ffff828a.w
	move.l   #$41903ff,$ffff82a2.w
	move.l   #$3f008D,$ffff82a6.w
	move.l   #$3aD0415,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$5,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

vga60_8bit_320_240:
	move.l   #$c6008D,$ffff8282.w
	move.l   #$15029a,$ffff8286.w
	move.l   #$7b0097,$ffff828a.w
	move.l   #$41903ff,$ffff82a2.w
	move.l   #$3f003D,$ffff82a6.w
	move.l   #$3fD0415,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$5,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

vga60_8bit_640_400:
	move.l   #$c6008D,$ffff8282.w
	move.l   #$1502ab,$ffff8286.w
	move.l   #$840097,$ffff828a.w
	move.l   #$41903ff,$ffff82a2.w
	move.l   #$3f008f,$ffff82a6.w
	move.l   #$3af0415,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$8,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

vga60_8bit_640_480:
	move.l   #$c6008D,$ffff8282.w
	move.l   #$1502ab,$ffff8286.w
	move.l   #$840097,$ffff828a.w
	move.l   #$41903ff,$ffff82a2.w
	move.l   #$3f003f,$ffff82a6.w
	move.l   #$3ff0415,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$8,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- VGA 8bit 100Hz ---------------------------------
; --------------------------------------------------------------

vga100_8bit_160_100:
	move.l   #$620047,$ffff8282.w
	move.l   #$c023c,$ffff8286.w
	move.l   #$35004c,$ffff828a.w
	move.l   #$275025b,$ffff82a2.w
	move.l   #$410085,$ffff82a6.w
	move.l   #$2150271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$50,$ffff8210.w
	rts

vga100_8bit_160_120:
	move.l   #$620047,$ffff8282.w
	move.l   #$c023c,$ffff8286.w
	move.l   #$35004c,$ffff828a.w
	move.l   #$275025b,$ffff82a2.w
	move.l   #$41005D,$ffff82a6.w
	move.l   #$23D0271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$50,$ffff8210.w
	rts

vga100_8bit_320_200:
	move.l   #$c6008f,$ffff8282.w
	move.l   #$18029c,$ffff8286.w
	move.l   #$7D0098,$ffff828a.w
	move.l   #$275025b,$ffff82a2.w
	move.l   #$410085,$ffff82a6.w
	move.l   #$2150271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$4,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

vga100_8bit_320_240:
	move.l   #$c6008f,$ffff8282.w
	move.l   #$18029c,$ffff8286.w
	move.l   #$7D0098,$ffff828a.w
	move.l   #$275025b,$ffff82a2.w
	move.l   #$41005D,$ffff82a6.w
	move.l   #$23D0271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$4,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

vga100_8bit_640_400:
	move.l   #$c6008f,$ffff8282.w
	move.l   #$1802aD,$ffff8286.w
	move.l   #$860098,$ffff828a.w
	move.l   #$274025b,$ffff82a2.w
	move.l   #$410084,$ffff82a6.w
	move.l   #$2140271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$a,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

vga100_8bit_640_480:
	move.l   #$c6008f,$ffff8282.w
	move.l   #$1802aD,$ffff8286.w
	move.l   #$860098,$ffff828a.w
	move.l   #$274025b,$ffff82a2.w
       		move.l   #$41005c,$ffff82a6.w
	move.l   #$23c0271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$a,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- VGA 16bit 60Hz ---------------------------------
; --------------------------------------------------------------

vga60_16bit_160_100:
	move.l   #$620046,$ffff8282.w
	move.l   #$a024D,$ffff8286.w
	move.l   #$46004b,$ffff828a.w
	move.l   #$41903ff,$ffff82a2.w
	move.l   #$3f0155,$ffff82a6.w
	move.l   #$2e50415,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

vga60_16bit_320_100:
	move.l   #$c6008D,$ffff8282.w
	move.l   #$1502ac,$ffff8286.w
	move.l   #$8D0097,$ffff828a.w
	move.l   #$41903ff,$ffff82a2.w
	move.l   #$3f0155,$ffff82a6.w
	move.l   #$2e50415,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$5,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

vga60_16bit_160_120:
	move.l   #$620046,$ffff8282.w
	move.l   #$a024D,$ffff8286.w
	move.l   #$46004b,$ffff828a.w
	move.l   #$41903ff,$ffff82a2.w
	move.l   #$3f012D,$ffff82a6.w
	move.l   #$30D0415,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

vga60_16bit_320_200:
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

vga60_16bit_320_240:
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

; --------------------------------------------------------------
; ------------- VGA 16bit 100Hz --------------------------------
; --------------------------------------------------------------

vga100_16bit_160_100:
	move.l   #$620047,$ffff8282.w
	move.l   #$c024e,$ffff8286.w
	move.l   #$47004c,$ffff828a.w
	move.l   #$275025b,$ffff82a2.w
	move.l   #$410085,$ffff82a6.w
	move.l   #$2150271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

vga100_16bit_320_100:
	move.l   #$c6008f,$ffff8282.w
	move.l   #$1802ae,$ffff8286.w
	move.l   #$8f0098,$ffff828a.w
	move.l   #$275025b,$ffff82a2.w
	move.l   #$410085,$ffff82a6.w
	move.l   #$2150271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$5,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

vga100_16bit_160_120:
	move.l   #$620047,$ffff8282.w
	move.l   #$c024e,$ffff8286.w
	move.l   #$47004c,$ffff828a.w
	move.l   #$275025b,$ffff82a2.w
	move.l   #$41005D,$ffff82a6.w
	move.l   #$23D0271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

vga100_16bit_320_200:
	move.l   #$c6008f,$ffff8282.w
	move.l   #$1802ae,$ffff8286.w
	move.l   #$8f0098,$ffff828a.w
	move.l   #$275025b,$ffff82a2.w
	move.l   #$410085,$ffff82a6.w
	move.l   #$2150271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$4,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

vga100_16bit_320_240:
	move.l   #$c6008f,$ffff8282.w
	move.l   #$1802ae,$ffff8286.w
	move.l   #$8f0098,$ffff828a.w
	move.l   #$275025b,$ffff82a2.w
	move.l   #$41005D,$ffff82a6.w
	move.l   #$23D0271,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$186,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$4,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- RGB 8bit 50Hz ----------------------------------
; --------------------------------------------------------------


rgb50_8bit_320_100:
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

rgb50_8bit_320_120:
	move.l   #$c700a0,$ffff8282.w
	move.l   #$1f02ba,$ffff8286.w
	move.l   #$8900ab,$ffff828a.w
	move.l   #$2710265,$ffff82a2.w
	move.l   #$2f0059,$ffff82a6.w
	move.l   #$239026b,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

rgb50_8bit_320_200:
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
	move.w   #$0,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

rgb50_8bit_320_240:
	move.l   #$c700a0,$ffff8282.w
	move.l   #$1f02ba,$ffff8286.w
	move.l   #$8900ab,$ffff828a.w
	move.l   #$2710265,$ffff82a2.w
	move.l   #$2f0059,$ffff82a6.w
	move.l   #$239026b,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$0,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

rgb50_8bit_640_400:
	move.l   #$1900141,$ffff8282.w
	move.l   #$3e0005,$ffff8286.w
	move.l   #$1240156,$ffff828a.w
	move.l   #$2700265,$ffff82a2.w
	move.l   #$2f0080,$ffff82a6.w
	move.l   #$210026b,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$6,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

rgb50_8bit_640_480:
	move.l   #$1900141,$ffff8282.w
	move.l   #$3e0005,$ffff8286.w
	move.l   #$1240156,$ffff828a.w
	move.l   #$2700265,$ffff82a2.w
	move.l   #$2f0058,$ffff82a6.w
	move.l   #$238026b,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$6,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- RGB 8bit 60Hz ----------------------------------
; --------------------------------------------------------------


rgb60_8bit_320_100:
	move.l   #$c7009f,$ffff8282.w
	move.l   #$1f02b9,$ffff8286.w
	move.l   #$8800ab,$ffff828a.w
	move.l   #$20d0201,$ffff82a2.w
	move.l   #$170041,$ffff82a6.w
	move.l   #$1d10207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

rgb60_8bit_320_120:
	move.l   #$c7009f,$ffff8282.w
	move.l   #$1f02b9,$ffff8286.w
	move.l   #$8800ab,$ffff828a.w
	move.l   #$20d0201,$ffff82a2.w
	move.l   #$170019,$ffff82a6.w
	move.l   #$1f90207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

rgb60_8bit_320_200:
	move.l   #$c7009f,$ffff8282.w
       		move.l   #$1f02b9,$ffff8286.w
	move.l   #$8800ab,$ffff828a.w
	move.l   #$20d0201,$ffff82a2.w
	move.l   #$170043,$ffff82a6.w
	move.l   #$1d30207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$0,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts

rgb60_8bit_320_240:
	move.l   #$c7009f,$ffff8282.w
	move.l   #$1f02b9,$ffff8286.w
	move.l   #$8800ab,$ffff828a.w
	move.l   #$20d0201,$ffff82a2.w
	move.l   #$17001b,$ffff82a6.w
	move.l   #$1fb0207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$0,$ffff82c2.w
	move.w   #$a0,$ffff8210.w
	rts


rgb60_8bit_640_400:
	move.l   #$1910140,$ffff8282.w
	move.l   #$3e0005,$ffff8286.w
	move.l   #$1230157,$ffff828a.w
	move.l   #$20c0201,$ffff82a2.w
	move.l   #$170042,$ffff82a6.w
	move.l   #$1d20207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$6,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

rgb60_8bit_640_480:
	move.l   #$1910140,$ffff8282.w
	move.l   #$3e0005,$ffff8286.w
	move.l   #$1230157,$ffff828a.w
	move.l   #$20c0201,$ffff82a2.w
	move.l   #$17002e,$ffff82a6.w
	move.l   #$1e60207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$10,$ffff8266.w
	move.w   #$6,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- RGB 16bit 50Hz ---------------------------------
; --------------------------------------------------------------


rgb50_16bit_320_100:
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

rgb50_16bit_320_120:
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
	move.w   #$1,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

rgb50_16bit_320_200:
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

rgb50_16bit_320_240:
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


; --------------------------------------------------------------
; ------------- RGB 16bit 60Hz ---------------------------------
; --------------------------------------------------------------


rgb60_16bit_320_100:
	move.l   #$c7009f,$ffff8282.w
	move.l   #$1f0002,$ffff8286.w
	move.l   #$9a00ab,$ffff828a.w
	move.l   #$20d0201,$ffff82a2.w
	move.l   #$170041,$ffff82a6.w
	move.l   #$1d10207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

rgb60_16bit_320_120:
	move.l   #$c7009f,$ffff8282.w
	move.l   #$1f0002,$ffff8286.w
	move.l   #$9a00ab,$ffff828a.w
	move.l   #$20d0201,$ffff82a2.w
	move.l   #$170019,$ffff82a6.w
	move.l   #$1f90207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$1,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

rgb60_16bit_320_200:
	move.l   #$c7009f,$ffff8282.w
	move.l   #$1f0002,$ffff8286.w
	move.l   #$9a00ab,$ffff828a.w
	move.l   #$20d0201,$ffff82a2.w
	move.l   #$170043,$ffff82a6.w
	move.l   #$1d30207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$0,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

rgb60_16bit_320_240:
	move.l   #$c7009f,$ffff8282.w
	move.l   #$1f0002,$ffff8286.w
	move.l   #$9a00ab,$ffff828a.w
	move.l   #$20d0201,$ffff82a2.w
	move.l   #$17001b,$ffff82a6.w
	move.l   #$1fb0207,$ffff82aa.w
	move.w   #$200,$ffff820a.w
	move.w   #$185,$ffff82c0.w
	clr.w    $ffff8266.w
	move.w   #$100,$ffff8266.w
	move.w   #$0,$ffff82c2.w
	move.w   #$140,$ffff8210.w
	rts

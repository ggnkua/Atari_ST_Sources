* Falcon screenroutines:
*
* + resolutionswitchers
* + screenclearers
* + screencopiers
* + pallettesetters/savers

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

* Saves the current falcon resolution to an internal buffer.
SAVE_FV:
	lea	save_fv+6,a1
	move.l	$ffff820e.w,(a1)+		* offset & vwrap
	move.w	$ffff8266.w,(a1)+		* spshift
	lea	$ffff8282.w,a0			* horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a0
	bne.s	.loop1
	lea	$ffff82a2.w,a0			* vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a0
	bne.s	.loop2
	move.w	$ffff82c2.w,(a1)+		* video control
	move.w	$ffff82c0.w,(a1)+		* video clock
	move.b	$ffff8260.w,(a1)+		* shifter resolution
	move.b	$ffff820a.w,(a1)+		* video sync mode
	rts

* Changes screenresolution the fast way.. Do this synced to the VBL for
* the smooth res-change.
* INPUT: a0: address of fv2-buffer
CHANGE_FVFAST:
	addq	#6,a0				* Skip header + monitortype
	lea	(a0),a6

	move.l	(a0)+,$ffff820e.w		* offset & vwrap
	move.w	(a0)+,$ffff8266.w		* spshift
	lea	$ffff8282.w,a1			* horizontal control registers
.loop1	move.w	(a0)+,(a1)+
	cmpa.w	#$8292,a1
	bne.s	.loop1
	lea	$ffff82a2.w,a1			* vertical control registers
.loop2	move.w	(a0)+,(a1)+
	cmpa.w	#$82ae,a1
	bne.s	.loop2
	move.w	(a0)+,$ffff82c2.w		* video control
	move.w	(a0)+,$ffff82c0.w		* video clock
	cmpi.w	#$50,6(a6)			* ST resolution?
	blt.s	.stres
	addq	#1,a0				* st res
	bra.s	.fres
.stres:	move.b	(a0)+,$ffff8260.w		* st res
.fres:	move.b	(a0)+,$ffff820a.w		* video sync mode
	rts

SAVE_FALCPAL:
	move.w	$468.w,d0
.waitvbl:
	cmp.w	$468.w,d0
	beq.s	.waitvbl
	lea	falcsave_pal,a0
	lea	$ffff9800.w,a1
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

RESTORE_FALCPAL:
	move.w	$468.w,d0
.waitvbl:
	cmp.w	$468.w,d0
	beq.s	.waitvbl
	lea	falcsave_pal,a1
	lea	$ffff9800.w,a0
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

* INPUT: a0: screenaddress
CLEAR_320200TSCR:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#123-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*200*2,a0
.loop:
	REPT	20
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	dbra	d7,.loop
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6,-(a0)
	rts

* INPUT: a0: screenaddress
CLEAR_320100TSCR:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#100-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*100*2,a0
.loop:
	REPT	12
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d3,-(a0)
	dbra	d7,.loop
	rts

* INPUT: a0: screenaddress
CLEAR_3202008SCR:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#100-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*100*2,a0
.loop:
	REPT	12
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d3,-(a0)
	dbra	d7,.loop
	rts

COPY_PIC3202008:
	moveq	#100-1,d7
.loop:	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,144(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,192(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,240(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,288(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,336(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,384(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,432(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,480(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,528(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,576(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,624(a0)
	lea	640(a0),a0
	dbra	d7,.loop
	rts

	BSS

save_fv:
	DS.W	24
falcsave_pal:
	DS.L	256

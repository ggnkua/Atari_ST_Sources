*
*  NEOchrome V2.24 cut buffer contents (left justified):
*  by Chaos, Inc. of the Delta Force (member of The Union)
*
*    pixels/scanline    = $0010 (bytes/scanline: $0008)
*  # scanlines (height) = $0010
*
*  Hardware color pallet  (color 0 to 15):
*

spritep:
		dc.w	$0000,$0013,$0035,$0057,$0000,$0000,$0343,$0000
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
*
*
spriteimg:
		dc.w	$07E0,$0000,$0000,$0000,$1FF8,$0000,$0000,$0000
		dc.w	$3FFC,$0000,$0000,$0000,$7FFE,$0000,$0000,$0000
		dc.w	$63FE,$1C00,$0000,$0000,$C1FF,$3E00,$0000,$0000
		dc.w	$B8FF,$7F00,$0000,$0000,$B8FF,$7F00,$0000,$0000
		dc.w	$B8FF,$7F00,$0000,$0000,$B8FF,$7F00,$0000,$0000
		dc.w	$C1FF,$3E00,$0000,$0000,$63FE,$1C00,$0000,$0000
		dc.w	$7FFE,$0000,$0000,$0000,$3FFC,$0000,$0000,$0000
		dc.w	$1FF8,$0000,$0000,$0000,$07E0,$0000,$0000,$0000
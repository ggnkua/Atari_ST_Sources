; **  Routine which clears the little screen in one bitplane.  **
; Parameters:
;     a0.l = adress of the ramvideo.
; Uses no register, uses no customchips!...
;   ( Who needs a blitter anyway?... )

;************
 Section TEXT

  movem.l	d0-d2,-(sp)

.preparation:
  add.l	#$ca8,a0	; Beginning of the area.
  moveq.l	#$00,d0	; Internal pattern.
  moveq.l	#$58,d1
  move.l	#$9f,d2	; 160 lines.
  
.one_line:
  rept	9
  move.w	d0,(a0)
  addq.l	#$8,a0
  endr
  move.w	d0,(a0)
  add.l	d1,a0	; Next line.
  dbra	d2,.one_line
  
.end:
  movem.l	(sp)+,d0-d2
  rts

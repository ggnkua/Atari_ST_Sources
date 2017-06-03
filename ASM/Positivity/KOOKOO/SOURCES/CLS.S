; **  Routine which clears the screen.  **
; Parameters:
;     a0.l = adress of the ramvideo.
; Uses no register, uses no customchips!...
;   ( Who needs a blitter anyway?... )

;************
 Section TEXT

  movem.l	d0-d7/a1-a6,-(sp)

.preparation:
  add.l	#$7d00,a0	; End of the screen.
  moveq.l	#$0,d0
  move.l	d0,d1
  move.l	d0,d2
  move.l	d0,d3
  move.l	d0,d4
  move.l	d0,d5
  move.l	d0,d6
  move.l	d0,a1
  move.l	d0,a2
  move.l	d0,a3
  move.l	d0,a4
  move.l	d0,a5
  move.l	d0,a6
  
  move.w	#614,d7	; (615*52)+20 bytes
.one_time:
  movem.l	d0-d6/a1-a6,-(a0)
  dbra	d7,.one_time
  movem.l	d0-d4,-(a0)

.end:
  movem.l	(sp)+,d0-d7/a1-a6
  rts
  
  
  
  
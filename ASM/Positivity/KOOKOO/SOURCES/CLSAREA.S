; **  Routine which clears the little screen in four bitplanes.  **
; **    ( considering the fourth bitplane is always cleared! )   **
; Parameters:
;     a0.l = adress of the ramvideo.
; Uses no register, uses no customchips!...
;   ( Who needs a blitter anyway?... )

;************
 Section TEXT

  movem.l	d0-d7/a1-a4,-(sp)

.preparation:
  add.l	#$ca8,a0	; Beginning of the area.
  moveq.l	#$00,d0	; Internal pattern.
  move.l	d0,d1	; 4th plane always cleared.
  move.l	d0,d2
  move.l	d0,d3
  move.l	d0,d4
  move.l	d0,d5
  move.l	d0,a1
  move.l	d0,a2
  move.l	d0,a3
  move.l	d0,a4
  move.l	#$28,a5
  moveq.l	#$78,d6
  move.l	#$9f,d7	; 160 lines.
  
.one_line:
  movem.l	d0-d5/a1-a4,(a0)
  add.l	a5,a0
  movem.l	d0-d5/a1-a4,(a0)
  add.l	d6,a0	; Next line.
  dbra	d7,.one_line
  
.end:
  movem.l	(sp)+,d0-d7/a1-a4
  rts
  

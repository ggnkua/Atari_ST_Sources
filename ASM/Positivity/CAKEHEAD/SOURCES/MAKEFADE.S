; *****************************************************************
; **  Routine which creates 16 fading tables.(STe colors used!)  **
; **      Dracula/Positivity                       22-12-93      **
; *****************************************************************
; Parameters:
;      a0.l = adress of the initial colors table.
;      a1.l = adress of the final colors table.
;      a2.l = adress for the 16 calculated tables.

  movem.l	d0-a6,-(sp)
  move.l	#.conv_from_ste,a3
  move.l	#.conv_to_ste,a4
  
.copy_initial_colors:	; I want to have the initial colors in
N set 0		; the table.
 rept	8
  move.l	N(a0),(a2)+
N set N+4
 endr
  
  moveq.l	#$f,d7	; 16 colors to fade.
.fade_one_color:
  moveq.l	#$f,d6
  move.w	(a0)+,d0	; Initial value for this color.
  move.w	d0,d1
  and.l	d6,d0	; d0=blue compound.(STe mode.)
  lsr.w	#$4,d1
  move.w	d1,d2
  and.l	d6,d1	; d1=green compound.(STe mode.)
  lsr.w	#$4,d2
  and.l	d6,d2	; d2=red compound.(STe mode.)
  move.b	(a3,d0.w),d0	; d0=blue.(Normal)
  move.b	(a3,d1.w),d1	; d1=green.(Normal)
  move.b	(a3,d2.w),d2	; d2=red.(Normal)

  move.w	(a1)+,d3	; Final value for this color.
  move.w	d3,d4
  and.l	d6,d3	; d3=blue compound.(STe mode.)
  lsr.w	#$4,d4
  move.w	d4,d5
  and.l	d6,d4	; d4=green compound.(STe mode.)
  lsr.w	#$4,d5
  and.l	d6,d5	; d5=red compound.(STe mode.)
  move.b	(a3,d3.w),d3	; d3=blue.(Normal)
  move.b	(a3,d4.w),d4	; d4=green.(Normal)
  move.b	(a3,d5.w),d5	; d5=red.(Normal)

N set	0
 rept	15	; 15 tables.

  cmp.b	d5,d2
  dc.w	$6708	; beq.s "ok".
  dc.w	$6c04	; bge.s "higher".
  addq.l	#$1,d2	; 
  dc.w	$6002	; bra.s "ok".
;"higher".
  subq.l	#$1,d2
;"ok".
  move.b	(a4,d2.w),d6	; Red compound.(STe)
  lsl.w	#$4,d6

  cmp.b	d4,d1
  dc.w	$6708	; beq.s "ok".
  dc.w	$6c04	; bge.s "higher".
  addq.l	#$1,d1	; 
  dc.w	$6002	; bra.s "ok".
;"higher".
  subq.l	#$1,d1
;"ok".
  or.b	(a4,d1.w),d6  	; Green.(STe)
  lsl.w	#$4,d6

  cmp.b	d3,d0
  dc.w	$6708	; beq.s "ok".
  dc.w	$6c04	; bge.s "higher".
  addq.l	#$1,d0	; 
  dc.w	$6002	; bra.s "ok".
;"higher".
  subq.l	#$1,d0
;"ok".
  or.b	(a4,d0.w),d6  	; Blue.(STe)
  move.w	d6,N(a2)	; Store this color in the (N/32)th table.

N set	N+32
 endr

  addq.l	#$2,a2	; Next color.
  dbra	d7,.fade_one_color  

  movem.l	(sp)+,d0-a6
  rts

.conv_from_ste:		; STe strange mode to a normal
  dc.b	$0,$2,$4,$6,$8,$a,$c,$e   ; 0 to 15 mode.
  dc.b	$1,$3,$5,$7,$9,$b,$d,$f

.conv_to_ste:		; Normal 0-15 mode to STe mode.
  dc.b	%0000,%1000,%0001,%1001
  dc.b	%0010,%1010,%0011,%1011
  dc.b	%0100,%1100,%0101,%1101
  dc.b	%0110,%1110,%0111,%1111


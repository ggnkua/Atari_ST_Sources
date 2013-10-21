
;
; extcall (c)2000 Richard Gordon Faika
;


					move	4(sp),d0	; Par 1
					
					lea		varbuf(pc),a0	; varbuf-adress

					cmpi	#-99,d0		; init?
					bne		set_flag
					move.l	a0,d0		; yes, return adress
					rts					; bye
					
set_flag:			move	#-1,(a0)+	; set flag
					move	4(sp),(a0)+	; Par 1 from extern Routine
					move.l	6(sp),(a0)+	; Par 2 from extern Routine...
					move	10(sp),(a0) ; Par 3 from extern Routine...
					
					clr.l	d0
					rts					; and return

varbuf:				dc.w	0
					dc.w	0
					dc.l	0
					dc.l	0
					dc.l	0
					
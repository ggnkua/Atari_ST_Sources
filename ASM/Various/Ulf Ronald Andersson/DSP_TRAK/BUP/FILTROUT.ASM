;-----     -----     -----     -----     -----     -----     -----     -----
;Routine to filter output sample data
;
filt_fact	equ	0.5
;
	move	X:<frame_base,r6		;r6 -> mixed data destination
	move	#>filt_fact,x0			;x0 = filt_fact
	move	#>(1-filt_fact),x1		;x1 = 1-filt_fact
	move	L:-(r6),Y			;y1 = L_old,  y0 = R_old
	lua	(r6)+,r6			;r6 -> 1st new output sample
	DO	X:<frame_size,Filt_End
	mpy	x0,y1,a		X:(r6),y1	;a  = f_f * L_old,  y1 = L_new
	mpy	x0,y0,b		Y:(r6),y0	;b  = f_f * R_old,  y0 = R_new
	macr	x1,y1,a				;a  = L_result
	macr	x0,y0,b		a1,y1		;b  = R_result,  y1 = L_result
	move	a0,y0				;                y0 = R_result
	move	AB,L:(r6)+			;L:(r6)+ = results
Filt_End
;-----     -----     -----     -----     -----     -----     -----     -----

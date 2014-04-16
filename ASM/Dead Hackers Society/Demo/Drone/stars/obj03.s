s:		equ	20
z:		equ	30
ypos:		equ	20

; square 1 50pts
q:		set	-70
		rept	15
		dc.w	q*s,ypos+-60*s,-20*z,0
q:		set	q+10
		endr

q:		set	-70
		rept	15
		dc.w	q*s,ypos+50*s,-20*z,0
q:		set	q+10
		endr

q:		set	-50
		rept	10
		dc.w	-70*s,ypos+q*s,-20*z,0
q:		set	q+10
		endr

q:		set	-50
		rept	10
		dc.w	70*s,ypos+q*s,-20*z,0
q:		set	q+10
		endr


; square 2 42pts
q:		set	-60
		rept	13
		dc.w	q*s,ypos+-50*s,-10*z,0
q:		set	q+10
		endr

q:		set	-60
		rept	13
		dc.w	q*s,ypos+40*s,-10*z,0
q:		set	q+10
		endr

q:		set	-40
		rept	8
		dc.w	-60*s,ypos+q*s,-10*z,0
q:		set	q+10
		endr

q:		set	-40
		rept	8
		dc.w	60*s,ypos+q*s,-10*z,0
q:		set	q+10
		endr



; square 3 34pts
q:		set	-50
		rept	11
		dc.w	q*s,ypos+-40*s,0*z,0
q:		set	q+10
		endr

q:		set	-50
		rept	11
		dc.w	q*s,ypos+30*s,0*z,0
q:		set	q+10
		endr

q:		set	-30
		rept	6
		dc.w	-50*s,ypos+q*s,0*z,0
q:		set	q+10
		endr

q:		set	-30
		rept	6
		dc.w	50*s,ypos+q*s,0*z,0
q:		set	q+10
		endr


; square 4 26pts
q:		set	-40
		rept	9
		dc.w	q*s,ypos+-30*s,10*z,0
q:		set	q+10
		endr

q:		set	-40
		rept	9
		dc.w	q*s,ypos+20*s,10*z,0
q:		set	q+10
		endr

q:		set	-20
		rept	4
		dc.w	-40*s,ypos+q*s,10*z,0
q:		set	q+10
		endr

q:		set	-20
		rept	4
		dc.w	40*s,ypos+q*s,10*z,0
q:		set	q+10
		endr




; square 5 18pts
q:		set	-30
		rept	7
		dc.w	q*s,ypos+-20*s,20*z,0
q:		set	q+10
		endr

q:		set	-30
		rept	7
		dc.w	q*s,ypos+10*s,20*z,0
q:		set	q+10
		endr

q:		set	-10
		rept	2
		dc.w	-30*s,ypos+q*s,20*z,0
q:		set	q+10
		endr

q:		set	-10
		rept	2
		dc.w	30*s,ypos+q*s,20*z,0
q:		set	q+10
		endr


; square 6 10pts
q:		set	-20
		rept	5
		dc.w	q*s,ypos+-10*s,30*z,0
q:		set	q+10
		endr

q:		set	-20
		rept	5
		dc.w	q*s,ypos+0*s,30*z,0
q:		set	q+10
		endr

















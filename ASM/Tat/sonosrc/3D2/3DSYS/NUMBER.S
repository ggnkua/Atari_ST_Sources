;
;
;
;
;


num		MACRO
		dc.w	\1,\2,\3		;"true" colour
		ENDM

X		set	-1
	

		num	X,X,X
		num	X,0,X
		num	X,0,X
		num	X,0,X
		num	X,X,X

		num	0,X,0
		num	0,X,0
		num	0,X,0
		num	0,X,0
		num	0,X,0

		num	X,X,X
		num	0,0,X
		num	X,X,X
		num	X,0,0
		num	X,X,X

		num	X,X,X
		num	0,0,X
		num	X,X,X
		num	0,0,X
		num	X,X,X

		num	X,0,X
		num	X,0,X
		num	X,0,X
		num	X,X,X
		num	0,0,X

		num	X,X,X
		num	X,0,0
		num	X,X,X		;5
		num	0,0,X
		num	X,X,X

		num	X,X,0
		num	X,0,0
		num	X,X,0
		num	X,0,X
		num	X,X,X

		num	X,X,X
		num	0,0,X
		num	0,X,0		;7
		num	0,X,0
		num	0,X,0

		num	X,X,X
		num	X,0,X
		num	X,X,X		;8
		num	X,0,X
		num	X,X,X

		num	X,X,X
		num	X,0,X
		num	X,X,X		;9
		num	0,0,X
		num	0,0,X

		num	X,X,X
		num	X,0,X
		num	X,0,X		;A
		num	X,X,X
		num	X,0,X

		num	X,X,0
		num	X,0,X
		num	X,X,0		;B
		num	X,0,X
		num	X,X,0

		num	X,X,X
		num	X,0,X
		num	X,0,0		;C
		num	X,0,X
		num	X,X,X

		num	X,X,0
		num	X,0,X
		num	X,0,X		;D
		num	X,0,X
		num	X,X,0

		num	X,X,X
		num	X,0,0
		num	X,X,X		;E
		num	X,0,0
		num	X,X,X

		num	X,X,X
		num	X,0,0
		num	X,X,X		;F
		num	X,0,0
		num	X,0,0

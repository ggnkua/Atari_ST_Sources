;Floating point MACRO definitions

fp_op	MACRO		1\function
	move	\1,d4
	bsr	float_point
	ENDM
	
fp_add	MACRO
	fp_op	#0
	ENDM

fp_sub	MACRO
	fp_op	#1
	ENDM

fp_mul	MACRO
	fp_op	#2
	ENDM

fp_div	MACRO
	fp_op	#3
	ENDM
	
fp_sin	MACRO
	fp_op	#4
	ENDM

fp_cos	MACRO
	fp_op	#5
	ENDM
	
fp_tan	MACRO
	fp_op	#6
	ENDM

fp_exp	MACRO
	fp_op	#7
	ENDM
	
fp_log	MACRO
	fp_op	#8
	ENDM
	
fp_log10	MACRO
	fp_op	#9
	ENDM
	
fp_square	MACRO
	fp_op	#10
	ENDM
	
ascii_fp	MACRO		1\buffer
	move.l	\1,a0
	fp_op	#11
	ENDM
	
fp_ascii	MACRO		1\size,2\buffer
	move	\1,d2
	move.l	\2,a0
	fp_op	#12
	ENDM

fp_int	MACRO
	fp_op	#13
	ENDM

int_fp	MACRO
	fp_op	#14
	ENDM	

fp_eq	MACRO
	fp_op	#15
	ENDM

fp_ne	MACRO
	fp_op	#16
	ENDM	

fp_gt	MACRO
	fp_op	#17
	ENDM

fp_ge	MACRO
	fp_op	#18
	ENDM

fp_lt	MACRO
	fp_op	#19
	ENDM

fp_le	MACRO
	fp_op	#20
	ENDM

fp_arcsin	MACRO
	fp_op	#21
	ENDM

fp_arccos	MACRO
	fp_op	#22
	ENDM

fp_arctan	MACRO
	fp_op	#23
	ENDM

fp_sinh	MACRO
	fp_op	#24
	ENDM
	
fp_cosh	MACRO
	fp_op	#25
	ENDM	
	
fp_tanh	MACRO
	fp_op	#26
	ENDM	
	
fp_intpart	MACRO
	fp_op	#27
	ENDM	
	
fp_power	MACRO
	fp_op	#28
	ENDM	
	

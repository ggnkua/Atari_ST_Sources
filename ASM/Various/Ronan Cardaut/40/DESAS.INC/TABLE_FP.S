table_fpu
	dc.w	%0000000
	dc.b	'FMOVE   '

	dc.w	%0011100
	dc.b	'FACOS   '
	dc.w	%0001100
	dc.b	'FASIN   '
	dc.w	%0001010
	dc.b	'FATAN   '
	dc.w	%0001101
	dc.b	'FATANH  '
	dc.w	%0111000
	dc.b	'FCMP    '
	dc.w	%0011101
	dc.b	'FCOS    '
	dc.w	%0011001
	dc.b	'FCOSH   '
	dc.w	%0010000
	dc.b	'FETOX   '
	dc.w	%0010000
	dc.b	'FETOXM1 '
	dc.w	%0011110
	dc.b	'FGETEXP '
	dc.w	%0011111
	dc.b	'FGETMAN '
	dc.w	%0000001
	dc.b	'FINT    '
	dc.w	%0000011
	dc.b	'FINTRZ  '
	dc.w	%0010101
	dc.b	'FLOG10  '
	dc.w	%0010110
	dc.b	'FLOG2   '
	dc.w	%0010100
	dc.b	'FLOGN   '
	dc.w 	%0000110
	dc.b	'FLOGNP1 '
	dc.w	%0100001
	dc.b	'FMOD    '
	dc.w	%0100101
	dc.b	'FREM    '
	dc.w	%0100110
	dc.b	'FSCALE  '
	dc.w	%0100100
	dc.b	'FSGLDIV '
	dc.w	%0100111
	dc.b	'FSGLMUL '
	dc.w	%0001110
	dc.b	'FSIN    '
	dc.w	%0000010
	dc.b	'FSINH   '
	dc.w	%0001111
	dc.b	'FTAN    '
	dc.w	%0001001
	dc.b	'FTANH   '
	dc.w	%0010010
	dc.b	'FTENTOX '
	dc.w	%0111010		; tst … voir
	dc.b	'FTST    '
	dc.w	%0010001
	dc.b	'FTWOTOX '
	

	dc.w	%0100010
	dc.b	'FADD    '
	dc.w	%1100010
	dc.b	'FSADD   '
	dc.w	%1100110
	dc.b	'FDADD   '
	
	dc.w	%0100000
	dc.b	'FDIV    '
	dc.w	%1100000
	dc.b	'FSDIV   '
	dc.w	%1100100
	dc.b	'FDDIV   '
	
	dc.w	%0100011
	dc.b	'FMUL    '
	dc.w	%1100011
	dc.b	'FSMUL   '
	dc.w	%1100111
	dc.b	'FDMUL   '
	
	
	dc.w	%0011010
	dc.b	'FNEG    '
	dc.w	%1011010
	dc.b	'FSNEG   '
	dc.w	%1011110
	dc.b	'FDNEG   '
	
	dc.w	%0000100
	dc.b	'FSQRT   '
	dc.w	%1000101
	dc.b	'FSSQRT  '
	dc.w	%1000100
	dc.b	'FDSQRT  '
	
	
	dc.w	%0101000
	dc.b	'FSUB    '
	dc.w	%1101000
	dc.b	'FSSUB   '
	dc.w	%1101100
	dc.b	'FDSUB   '
	
	
	dc.w	%0011000
	dc.b	'FABS    '
	dc.w	%1011000
	dc.b	'FSABS   '
	dc.w	%1011100
	dc.b	'FDABS   '
	
	
	
	
	dc.w	$ffff
	
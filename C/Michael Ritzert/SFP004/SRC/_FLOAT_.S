
# double _Float_( long Value_1, long Exponent_1, long Value_2, long Exponent_2 )
#
# merges the accumulators Value_1, Value_2 and the Exponent to a double
# precision float
# called by strtod()
#
# does all floating point computations with extended precision on the fpu
#
# mjr, 30.1.1991
#
# base =	0xfffa50
#      the fpu addresses are taken relativ to "base":
#
# a0: fpu base address
#

# waiting loop ...
#
# wait:
# ww:	cmpiw	#0x8900,a0@(resp)
# 	beq	ww
# is coded directly by
#	.long	0x0c688900, 0xfff067f8 (a0)
# and
# www:	tst.w	a0@(resp)
#	bmi.b	www
# is coded by
#	.word	0x4a68,0xfff0,0x6bfa		| test
#

comm =	 -6
resp =	-16
zahl =	  0

	.globl __Float_
.even
.text
__Float_:
	lea	0xfffa50,a0							| fpu address

#	movew	#%0100 0000 1001 0010,a0@(comm)	| ftentoxl -> fp1
	movew	#0x4092,a0@(comm)				| ftentoxl -> fp1
	.long	0x0c688900, 0xfff067f8
	movel	a7@(8),a0@						| load Exponent_1

#	movew	#%0100 0001 0001 0010,a0@(comm)	| ftentoxl -> fp2
	movew	#0x4112,a0@(comm)				| ftentoxl -> fp2
	.long	0x0c688900, 0xfff067f8
	movel	a7@(16),a0@						| load Exponent_2

|	movew	#%0100 0001 0010 0011,a0@(comm)	| fmull Value_2 -> fp2
	movew	#0x4123,a0@(comm)				| fmull Value_2 -> fp2
	.long	0x0c688900, 0xfff067f8
	movel	a7@(12),a0@						| load Value_2

|	movew	#%0100 0000 1010 0011,a0@(comm)	| fmull Value_1 -> fp1
	movew	#0x40a3,a0@(comm)				| fmull Value_1 -> fp1
	.long	0x0c688900, 0xfff067f8
	movel	a7@(4),a0@						| load Value_1

|	movew	#%000 010 001 0100010,a0@(comm)	| faddx fp2 -> fp1
	movew	#0x08a2,a0@(comm)				| faddx fp2 -> fp1
	.word	0x4a68,0xfff0,0x6bfa			| test

	movew	#0x7480,a0@(comm)				| fmoved fp1 -> d0/d1
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
 	rts

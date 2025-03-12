; fractional fixed point division: S > D
fdiv		MACRO
		tst	\2
		jmi	__negative
		andi	#<%11111110,ccr			;clear carry
		rep	#<8+1
		div	\1,\2
		move	\20,\2
		jset	#23,\1,__neg
		jmp	<__divss_end

__negative:	neg	\2
		andi	#<%11111110,ccr			;clear carry
		rep	#<8+1
		div	\1,\2
		move	\20,\2
		jset	#23,\1,__divss_end
__neg:		neg	\2
__divss_end:
		ENDM

; integer fixed point division: S<<4 > D
idiv		MACRO
		tst	\2
		jmi	__negative
		andi	#<%11111110,ccr			;clear carry
		rep	#<12+1
		div	\1,\2
		move	\20,\2
		jset	#23,\1,__neg
		jmp	<__divss_end

__negative:	neg	\2
		andi	#<%11111110,ccr			;clear carry
		rep	#<12+1
		div	\1,\2
		move	\20,\2
		jset	#23,\1,__divss_end
__neg:		neg	\2
__divss_end:
		ENDM

rhost		MACRO
		jclr	#0,X:<<$ffe9,*
		movep	X:<<$ffeb,\1
		ENDM

whost		MACRO
		jclr	#1,X:<<$ffe9,*
		movep	\1,X:<<$ffeb
		ENDM

wait_read	MACRO
		jclr	#0,X:<<$ffe9,*
		ENDM

wait_write	MACRO
		jclr	#1,X:<<$ffe9,*
		ENDM
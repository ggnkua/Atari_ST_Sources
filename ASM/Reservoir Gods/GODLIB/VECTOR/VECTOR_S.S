**************************************************************************************
*
* GodLib Vector Maths Library
*
* [c] 2001 Reservoir Gods 
*
**************************************************************************************

	export	Vector_Add
	export	Vector_Sub
	export	Vector_Mul

	export	Vector_Normal
	export	Vector_Length
	export	Vector_SquareLength

	export	Vector_Dot
	export	Vector_Cross


**************************************************************************************
;	STRUCTS
**************************************************************************************

	OFFSET

sVector_X:		ds.w	1
sVector_Y:		ds.w	1
sVector_Z:		ds.w	1
sVector_sizeof:	ds.w	1


**************************************************************************************
;	MACROS
**************************************************************************************

; d0=inp
; d1=res
; d2=temp

	MACRO	mSqrtIter	aShift
	LOCAL	lNoShift

	move.l	d1,d2
;	lsl.l	#aShift,d2
	add.l	#(1<<((aShift*2)-2)),d2
	cmp.l	d2,d0
	blt.s	lNoShift
	add.l	#(1<<(aShift-1)),d0
	sub.l	d2,d0
lNoShift:

	ENDM

**************************************************************************************
	TEXT
**************************************************************************************


*------------------------------------------------------------------------------------*
* FUNCTION : Vector_Add( const sVector * apSrcVec0, const sVector * apSrcVec1, sVector * apDstVec );
* ACTION   : adds two vectors
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Vector_Add:

	movem.w	(a0),d0-d2	
	add.w	sVector_X(a1),d0
	add.w	sVector_Y(a1),d1
	add.w	sVector_Z(a1),d2
	movem.w	d0-d2,(a2)

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Vector_Sub( const sVector * apSrcVec0, const sVector * apSrcVec1, sVector * apDstVec );
* ACTION   : adds two vectors
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Vector_Sub:

	movem.w	(a1),d0-d2	
	sub.w	sVector_X(a0),d0
	sub.w	sVector_Y(a0),d1
	sub.w	sVector_Z(a0),d2
	movem.w	d0-d2,(a2)

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Vector_Mul( const sVector * apSrcVec, const S16 * aScaler, sVector * apDstVec )
* ACTION   : muls vector by a scaler
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Vector_Mul:

	move.w	sVector_X(a0),d1
	muls.w	d0,d1
	swap	d1
	move.w	d1,(a1)+

	move.w	sVector_Y(a0),d1
	muls.w	d0,d1
	swap	d1
	move.w	d1,(a1)+

	move.w	sVector_Z(a0),d1
	muls.w	d0,d1
	swap	d1
	move.w	d1,(a1)+

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Vector_Normal( const sVector * apSrcVec, sVector * apDstVec )
* ACTION   : noamralise apSrcVec and returns result in apDstVec
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Vector_Normal:

	movem.w	(a0),d0-d2
	muls.w	d0,d0
	muls.w	d1,d1
	muls.w	d2,d2
	add.l	d1,d0
	add.l	d2,d0
	
	bsr		VecSqrt

	moveq	#0,d1
	move.w	d0,d1
	add.l	d1,d1
	move.w	(OneOver,d1),d0

	move.w	sVector_X(a0),d1
	muls.w	d0,d1
	swap	d1
	move.w	d1,(a1)+

	move.w	sVector_Y(a0),d1
	muls.w	d0,d1
	swap	d1
	move.w	d1,(a1)+

	move.w	sVector_Z(a0),d1
	muls.w	d0,d1
	swap	d1
	move.w	d1,(a1)+

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Vector_Length( const sVector * apSrcVec )
* ACTION   : returns length of vector apSrcVec
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Vector_Length:

	movem.w	(a0),d0-d2
	muls.w	d0,d0
	muls.w	d1,d1
	muls.w	d2,d2
	add.l	d1,d0
	add.l	d2,d0
	
	bsr		VecSqrt

	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Vector_SquaredLength( const sVector * apSrcVec )
* ACTION   : returns squared length of vector apSrcVec
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Vector_SquaredLength:

	movem.w	(a0),d0-d2
	muls.w	d0,d0
	muls.w	d1,d1
	muls.w	d2,d2
	add.l	d1,d0
	add.l	d2,d0
	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Vector_Dot( const sVector * apSrcVec0, const sVector * apSrcVec1 )
* ACTION   : returns dot product of apScrVec0 with apSrcVec1
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Vector_Dot:

	movem.w	(a0),d0-d2
	muls.w	sVector_X(a1),d0
	muls.w	sVector_Y(a1),d1
	muls.w	sVector_Z(a1),d2
	add.l	d1,d0
	add.l	d2,d0
	swap	d0
	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Vector_Cross( const sVector * apSrcVec0, const sVector * apSrcVec1, sVector * apDstVec )
* ACTION   : returns cross product of apScrVec0 with apSrcVec1 in apDstVec
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

Vector_Cross:

	move.w	sVector_Y(a0),d0
	move.w	sVector_Z(a1),d1
	muls.w	d1,d0
	move.w	sVector_Z(a0),d1
	move.w	sVector_Y(a1),d2
	muls.w	d2,d1
	add.l	d1,d0
	swap	d0
	move.w	d0,(a2)+

	move.w	sVector_Z(a0),d0
	move.w	sVector_X(a1),d1
	muls.w	d1,d0
	move.w	sVector_X(a0),d1
	move.w	sVector_Z(a1),d2
	muls.w	d2,d1
	add.l	d1,d0
	swap	d0
	move.w	d0,(a2)+

	move.w	sVector_X(a0),d0
	move.w	sVector_Y(a1),d1
	muls.w	d1,d0
	move.w	sVector_Y(a0),d1
	move.w	sVector_X(a1),d2
	muls.w	d2,d1
	add.l	d1,d0
	swap	d0
	move.w	d0,(a2)+
	
	rts

*------------------------------------------------------------------------------------*
* FUNCTION : VecSqrt( U32 aVal )
* ACTION   : returns integer sqrt of aVal
* CREATION : 17.11.01 PNK
*------------------------------------------------------------------------------------*

VecSqrt:
	moveq	#0,d1

	cmp.l	#$40000000,d0
	blt.s	.inLow
	
	move.l	#$8000,d1
	sub.l	#$40000000,d0
.inLow:

	mSqrtIter	15
	mSqrtIter	14
	mSqrtIter	13
	mSqrtIter	12
	mSqrtIter	11
	mSqrtIter	10
	mSqrtIter	9
	mSqrtIter	8
	mSqrtIter	7
	mSqrtIter	6
	mSqrtIter	5
	mSqrtIter	4
	mSqrtIter	3
	mSqrtIter	2

	move.l	d1,d2
	add.l	d1,d2
	addq.l	#1,d2
	cmp.l	d2,d0
	blt.s	.lsSkip
	addq.l	#1,d1
.lsSkip:

	move.l	d1,d0


	rts

OneOver:	ds.l	1
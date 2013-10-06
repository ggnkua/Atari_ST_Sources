**************************************************************************************
*	XBIOS_S.S
*
*	TOS XBIOS calling routines
*
*	[c] 2003 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Xbios_Call
	export	Xbios_Call_L
	export	Xbios_Call_P
	export	Xbios_Call_W
	export	Xbios_Call_LL
	export	Xbios_Call_PP
	export	Xbios_Call_WP
	export	Xbios_Call_WW
	export	Xbios_Call_LLW
	export	Xbios_Call_WWL
	export	Xbios_Call_WWP
	export	Xbios_Call_PLW
	export	Xbios_Call_PPP
	export	Xbios_Call_PPW
	export	Xbios_Call_PWP
	export	Xbios_Call_WPP
	export	Xbios_Call_WWWP
	export	Xbios_Call_WLPL
	export	Xbios_Call_LLPP
	export	Xbios_Call_LWPW
	export	Xbios_Call_PLLP
	export	Xbios_Call_PLPL
	export	Xbios_Call_PLWW
	export	Xbios_Call_PPWW
	export	Xbios_Call_WWWWW
	export	Xbios_Call_WWWWWW
	export	Xbios_Call_PPLLLP
	export	Xbios_Call_PLWWWWW
	export	Xbios_Call_PLWWWWWW
	export	Xbios_Call_PPWWWWWLW


**************************************************************************************
;	EQUATES
**************************************************************************************

eXBIOS_STACKOFFSET	EQU	8



**************************************************************************************
	TEXT
**************************************************************************************


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call( const S16 aOp )
* ACTION   : Xbios_Call
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call:
	pea		(a2)

	move.w	d0,-(a7)
	trap	#14
	addq.l	#2,a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_L( const S16 aOp,const S32 aL0 )
* ACTION   : Xbios_Call_L
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_L:
	pea		(a2)

	move.l	d1,-(a7)
	move.w	d0,-(a7)
	trap	#14
	addq.l	#6,a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_P( const S16 aOp,const void * ap0 )
* ACTION   : Xbios_Call_P
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_P:
	pea		(a2)

	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	addq.l	#6,a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_W( const S16 aOp,const S16 aW0 )
* ACTION   : Xbios_Call_W
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_W:
	pea		(a2)

	move.w	d1,-(a7)	
	move.w	d0,-(a7)
	trap	#14
	addq.l	#4,a7

	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_LL( const S16 aOp,const S32 aL0,const S32 aL1 )
* ACTION   : Xbios_Call_LL
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_LL:
	pea		(a2)

	move.l	d2,-(a7)	
	move.l	d1,-(a7)	
	move.w	d0,-(a7)
	trap	#14
	lea		10(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PP( const S16 aOp,const void * ap0,const void * ap1 )
* ACTION   : Xbios_Call_PP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PP:
	pea		(a2)

	pea		(a1)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		10(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_WP( const S16 aOp,const S16 aW0,const void * ap0 )
* ACTION   : Xbios_Call_WP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_WP:
	pea		(a2)

	pea		(a0)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#14
	addq.l	#8,a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_WW( const S16 aOp,const S16 aW0,const S16 aW1 )
* ACTION   : Xbios_Call_WW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_WW:
	pea		(a2)

	move.w	d2,-(a7)	
	move.w	d1,-(a7)	
	move.w	d0,-(a7)
	trap	#14
	addq.l	#6,a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_LLW( const S16 aOp,const S32 aL0,const S32 aL1,const S16 aW0 )
* ACTION   : Xbios_Call_LLW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_LLW:
	pea		(a2)

	move.w	eXBIOS_STACKOFFSET(a7),-(a7)
	move.l	d2,-(a7)	
	move.w	d1,-(a7)	
	move.w	d0,-(a7)
	trap	#14
	lea		10(a7),a7
		
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_WWL( const S16 aOp,const S16 aW0,const S16 aW1,const S32 aL0 )
* ACTION   : Xbios_Call_WWL
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_WWL:
	pea		(a2)

	move.l	eXBIOS_STACKOFFSET(a7),-(a7)
	move.w	d2,-(a7)	
	move.w	d1,-(a7)	
	move.w	d0,-(a7)
	trap	#14
	lea		10(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_WWP( const S16 aOp,const S16 aW0,const S16 aW1,const void * ap0 )
* ACTION   : Xbios_Call_WWP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_WWP:
	pea		(a2)

	pea		(a0)
	move.w	d2,-(a7)	
	move.w	d1,-(a7)	
	move.w	d0,-(a7)
	trap	#14
	lea		10(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PLW( const S16 aOp,const void * ap0,const S32 aL0,const S16 aW0 )
* ACTION   : Xbios_Call_PLW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PLW:
	pea		(a2)

	move.w	d2,-(a7)	
	move.l	d1,-(a7)	
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		12(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PPP( const S16 aOp,const void * ap0,const void * ap1,const void * ap2 )
* ACTION   : Xbios_Call_PPP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PPP:
	pea		(a2)

	move.l	eXBIOS_STACKOFFSET(a7),-(a7)
	pea		(a1)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		14(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PPW( const S16 aOp,const void * ap0,const void * ap1,const S16 aW0 )
* ACTION   : Xbios_Call_PPW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PPW:
	pea		(a2)

	move.w	d1,-(a7)
	pea		(a1)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		12(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PWP( const S16 aOp,const void * ap0,const S16 aW0,const void * ap1 )
* ACTION   : Xbios_Call_PWP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PWP:
	pea		(a2)

	pea		(a1)
	move.w	d1,-(a7)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		12(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_WPP( const S16 aOp,const S16 aW0,const void * ap0,const void * ap1 )
* ACTION   : Xbios_Call_WPP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_WPP:
	pea		(a2)

	pea		(a1)
	pea		(a0)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#14
	lea		12(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_WWWP( const S16 aOp,const S16 aW0,const S16 aW1,const S16 aW2,const void * ap0 )
* ACTION   : Xbios_Call_WWWP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_WWWP:
	pea		(a2)

	pea		(a0)
	move.l	eXBIOS_STACKOFFSET+4(a7),-(a7)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#14
	lea		12(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_WLPL( const S16 aOp,const S16 aW0,const S32 aL0,const void * ap0,const S32 aL1 )
* ACTION   : Xbios_Call_WLPL
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_WLPL:
	pea		(a2)

	move.l	eXBIOS_STACKOFFSET(a7),-(a7)
	pea		(a0)
	move.l	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#14
	lea		16(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_LLPP( const S16 aOp,const S32 aL0,const S32 aL1,const void * ap0,const void * ap1 )
* ACTION   : Xbios_Call_LLPP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_LLPP:
	pea		(a2)

	pea		(a1)
	pea		(a0)
	move.l	d2,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	trap	#14
	lea		18(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_LWPW( const S16 aOp,const S32 aL0,const S16 aW0,const void * ap0,const S16 aW1 )
* ACTION   : Xbios_Call_LWPW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_LWPW:
	pea		(a2)

	move.w	eXBIOS_STACKOFFSET(a7),-(a7)
	pea		(a0)
	move.w	d2,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	trap	#14
	lea		16(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PLLP( const S16 aOp,const void * ap0,const S32 aL0,const S32 aL1,const void * ap1 )
* ACTION   : Xbios_Call_PLLP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PLLP:
	pea		(a2)

	pea		(a1)
	move.l	d2,-(a7)
	move.l	d1,-(a7)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		18(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PLPL( const S16 aOp,const void * ap0,const S32 aL0,const void * ap1,const S32 aL1 )
* ACTION   : Xbios_Call_PLPL
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PLPL:
	pea		(a2)

	move.l	d2,-(a7)
	pea		(a1)
	move.l	d1,-(a7)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		18(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PLWW( const S16 aOp,const void * ap0,const S32 aL0,const S16 aW0,const S16 aW1 )
* ACTION   : Xbios_Call_PLWW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PLWW:
	pea		(a2)

	move.w	eXBIOS_STACKOFFSET(a7),-(a7)
	move.w	d2,-(a7)
	move.l	d1,-(a7)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		14(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PPWW( const S16 aOp,const void * ap0,const void * ap1,const S16 aW0,const S16 aW1 )
* ACTION   : Xbios_Call_PPWW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PPWW:
	pea		(a2)

	move.w	d2,-(a7)
	move.w	d1,-(a7)
	pea		(a1)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		18(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_WWWWW( const S16 aOp,const S16 aW0,const S16 aW1,const S16 aW2,const S16 aW3,const S16 aW4 )
* ACTION   : Xbios_Call_WWWWW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_WWWWW:
	pea		(a2)

	move.w	eXBIOS_STACKOFFSET+4(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+4(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+4(a7),-(a7)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#14
	lea		12(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_WWWWWW( const S16 aOp,const S16 aW0,const S16 aW1,const S16 aW2,const S16 aW3,const S16 aW4,const S16 aW5 )
* ACTION   : Xbios_Call_WWWWWW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_WWWWWW:
	pea		(a2)

	move.w	eXBIOS_STACKOFFSET+6(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+6(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+6(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+6(a7),-(a7)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#14
	lea		14(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PPLLLP( const S16 aOp,const void * ap0,const void * ap1,const S32 aL0,const S32 aL1,const S32 aL2,const void * ap2 )
* ACTION   : Xbios_Call_PPLLLP
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PPLLLP:
	pea		(a2)

	move.l	eXBIOS_STACKOFFSET+4(a7),-(a7)
	move.l	eXBIOS_STACKOFFSET+4(a7),-(a7)
	move.l	d2,-(a7)
	move.l	d1,-(a7)
	pea		(a1)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		26(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PLWWWWW( const S16 aOp,const void * ap0,const S32 aL0,const S16 aW0,const S16 aW1,const S16 aW2,const S16 aW3,const S16 aW4 )
* ACTION   : Xbios_Call_PLWWWWW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PLWWWWW:
	pea		(a2)

	move.w	eXBIOS_STACKOFFSET+6(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+6(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+6(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+6(a7),-(a7)
	move.w	d2,-(a7)
	move.l	d1,-(a7)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		20(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PLWWWWWW( const S16 aOp,const void * ap0,const S32 aL0,const S16 aW0,const S16 aW1,const S16 aW2,const S16 aW3,const S16 aW4,const S16 aW5 )
* ACTION   : Xbios_Call_PLWWWWWW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PLWWWWWW:
	pea		(a2)

	move.w	eXBIOS_STACKOFFSET+8(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+8(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+8(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+8(a7),-(a7)
	move.w	d2,-(a7)
	move.l	d1,-(a7)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		22(a7),a7
	
	move.l	(a7)+,a2	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : Xbios_Call_PPWWWWWLW( const S16 aOp,const void * ap0,const void * ap1,const S16 aW0,const S16 aW1,const S16 aW2,const S16 aW3,const S16 aW4,const S32 aL0,const S16 aW5 )
* ACTION   : Xbios_Call_PPWWWWWLW
* CREATION : 03.01.2003 PNK
*------------------------------------------------------------------------------------*

Xbios_Call_PPWWWWWLW:
	pea		(a2)

	move.w	eXBIOS_STACKOFFSET+12(a7),-(a7)
	move.l	eXBIOS_STACKOFFSET+12(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+12(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+12(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+12(a7),-(a7)
	move.w	eXBIOS_STACKOFFSET+12(a7),-(a7)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	pea		(a1)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#14
	lea		28(a7),a7
	
	move.l	(a7)+,a2	
	rts



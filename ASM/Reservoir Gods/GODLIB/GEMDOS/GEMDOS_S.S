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


**************************************************************************************
;	EQUATES
**************************************************************************************

eGEMDOS_STACKOFFSET	EQU	8



**************************************************************************************
	TEXT
**************************************************************************************

	export	GemDos_Call
	export	GemDos_Call_L
	export	GemDos_Call_P
	export	GemDos_Call_W
	export	GemDos_Call_LW
	export	GemDos_Call_PL
	export	GemDos_Call_PP
	export	GemDos_Call_PW
	export	GemDos_Call_WL
	export	GemDos_Call_WP
	export	GemDos_Call_WW
	export	GemDos_Call_LWW
	export	GemDos_Call_PWW
	export	GemDos_Call_WLP
	export	GemDos_Call_WLL
	export	GemDos_Call_WLW
	export	GemDos_Call_WPL
	export	GemDos_Call_WPP
	export	GemDos_Call_WWP
	export	GemDos_Call_WWW
	export	GemDos_Call_WPPL
	export	GemDos_Call_WPPP
	export	GemDos_Call_WWLL


**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call( const S16 aOp )
* ACTION   : GemDos_Call
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call:
	pea		(a2)

	move.w	d0,-(a7)
	trap	#1
	addq.l	#2,a7	

	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_L( const S16 aOp,const S32  aL0 )
* ACTION   : GemDos_Call_L
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_L:
	pea		(a2)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#6,a7	
	
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_P( const S16 aOp,const void *  ap0 )
* ACTION   : GemDos_Call_P
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_P:
	pea		(a2)

	pea		(a0)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#6,a7	
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_W( const S16 aOp,const S16 aW0 )
* ACTION   : GemDos_Call_W
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_W:
	pea		(a2)

	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#4,a7	
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_LW( const S16 aOp,const S32 aL0,const S16 aW0 )
* ACTION   : GemDos_Call_LW
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_LW:
	pea		(a2)

	move.w	d2,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#8,a7	
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_PL( const S16 aOp,const void * ap0,const S32 aL0 )
* ACTION   : GemDos_Call_PL
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_PL:
	pea		(a2)

	move.l	d1,-(a7)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#1
	lea		10(a7),a7	
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_PP( const S16 aOp,const void * ap0,const void * ap1 )
* ACTION   : GemDos_Call_PP
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_PP:
	pea		(a2)

	pea		(a1)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#1
	lea		10(a7),a7	
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_PW( const S16 aOp,const void * ap0,const S16 aW0 )
* ACTION   : GemDos_Call_PW
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_PW:
	pea		(a2)

	move.w	d1,-(a7)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#8,a7	
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WL( const S16 aOp,const S16 aW0,const S32 aL0 )
* ACTION   : GemDos_Call_WL
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WL:
	pea		(a2)

	move.l	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#8,a7	
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WP( const S16 aOp,const S16 aW0,const void * ap0 )
* ACTION   : GemDos_Call_WP
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WP:
	pea		(a2)

	pea		(a0)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#8,a7	
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WW( const S16 aOp,const S16 aW0,const S16 aW1 )
* ACTION   : GemDos_Call_WW
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WW:
	pea		(a2)

	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#6,a7	
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_LWW( const S16 aOp,const S32 aL0,const S16 aW0,const S16 aW1 )
* ACTION   : GemDos_Call_LWW
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_LWW:
	pea		(a2)

	move.w	eGEMDOS_STACKOFFSET(a7),-(a7)
	move.w	d2,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		10(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_PWW( const S16 aOp,const void * ap0,const S16 aW0,const S16 aW1 )
* ACTION   : GemDos_Call_PWW
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_PWW:
	pea		(a2)

	move.w	d2,-(a7)
	move.w	d1,-(a7)
	pea		(a0)
	move.w	d0,-(a7)
	trap	#1
	lea		10(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WLP( const S16 aOp,const S16 aW0,const S32 aL0,const void * ap0 )
* ACTION   : GemDos_Call_WLP
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WLP:
	pea		(a2)

	pea		(a0)
	move.l	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		12(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WLL( const S16 aOp,const S16 aW0,const S32 aL0,const S32 aL1 )
* ACTION   : GemDos_Call_WLL
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WLL:
	pea		(a2)

	move.l	eGEMDOS_STACKOFFSET(a7),-(a7)
	move.l	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		12(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WLW( const S16 aOp,const S16 aW0,const S32 aL0,const S16 aW1 )
* ACTION   : GemDos_Call_WLW
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WLW:
	pea		(a2)

	move.w	eGEMDOS_STACKOFFSET(a7),-(a7)
	move.l	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		10(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WPL( const S16 aOp,const S16 aW0,const void * ap0,const S32 aL0 )
* ACTION   : GemDos_Call_WPL
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WPL:
	pea		(a2)

	move.l	d2,-(a7)
	pea		(a0)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		12(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WPP( const S16 aOp,const S16 aW0,const void * ap0,const void * ap1 )
* ACTION   : GemDos_Call_WPP
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WPP:
	pea		(a2)

	pea		(a1)
	pea		(a0)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		12(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WWP( const S16 aOp,const S16 aW0,const S16 aW1,const void * ap0 )
* ACTION   : GemDos_Call_WWP
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WWP:
	pea		(a2)

	pea		(a0)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		10(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WWW( const S16 aOp,const S16 aW0,const S16 aW1,const S16 aW2 )
* ACTION   : GemDos_Call_WWW
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WWW:
	pea		(a2)

	move.w	eGEMDOS_STACKOFFSET(a7),-(a7)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	addq.l	#8,a7
		
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WPPL( const S16 aOp,const S16 aW0,const void * ap0,const void * ap1,const S32 aL0 )
* ACTION   : GemDos_Call_WPPL
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WPPL:
	pea		(a2)

	move.w	d2,-(a7)
	pea		(a1)
	pea		(a0)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		14(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WPPP( const S16 aOp,const S16 aW0,const void * ap0,const void * ap1,const void * ap2 )
* ACTION   : GemDos_Call_WPPP
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WPPP:
	pea		(a2)

	move.l	eGEMDOS_STACKOFFSET(a7),-(a7)
	pea		(a1)
	pea		(a0)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		16(a7),a7
	
	move.l	(a7)+,a2
	rts


*------------------------------------------------------------------------------------*
* FUNCTION : GemDos_Call_WWLL( const S16 aOp,const S16 aW0,const S16 aW1,const S32 aL0,const S32 aL1 )
* ACTION   : GemDos_Call_WWLL
* CREATION : 04.01.2003 PNK
*------------------------------------------------------------------------------------*

GemDos_Call_WWLL:
	pea		(a2)

	move.l	eGEMDOS_STACKOFFSET+4(a7),-(a7)
	move.l	eGEMDOS_STACKOFFSET+4(a7),-(a7)
	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)
	trap	#1
	lea		14(a7),a7
	
	move.l	(a7)+,a2
	rts



/*
 * PURE-C/TURBO-C header file for implementing the control traps of
 * the debugger. Copyright 1993 Andrew L. Younger ( BSS )
 *
 * This should be easily adaptable to work on almost any C compiler.
 */
#define	BREAKLock		16
#define	BREAKSimple		1
#define	BREAKCounter	2
#define	BREAKExpress	3
#define	BREAKCntExpr	4

#define	WATCHPointer 	128
#define	WATCHByte	 	1
#define	WATCHWord	 	2
#define	WATCHLong	 	3
#define	WATCHText	 	4

long xbios( void, ... );

#define	SetBreak(addr_string,breaktype,counter,expr_string)	\
	(void )xbios(32000,(char *)addr_string,(short)breaktype,	\
	(long)counter,(char *)expr_string)	

#define 	SetWatch(addr_string,type)					\
	 (void )xbios(32001,(char *)addr_string, (short)type)
	 

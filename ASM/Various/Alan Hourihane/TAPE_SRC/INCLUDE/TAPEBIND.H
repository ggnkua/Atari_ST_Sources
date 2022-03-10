#ifndef _TAPEBIND_H
#define _TAPEBIND_H

#ifdef __GNUC__

#define trap_10_wwll(n, a, b, c)					\
({									\
	register long retvalue __asm__("d0");				\
	short _a = (short)(a);						\
	long  _b = (long) (b);						\
	long  _c = (long) (c);						\
									\
	__asm__ volatile						\
	("\
		movl	%4,sp@-; \
		movl	%3,sp@-; \
		movw	%2,sp@-; \
		movw	%1,sp@-; \
		trap	#10;	\
		addw	#12,sp "					\
	: "=r"(retvalue)			/* outputs */		\
	: "g"(n), "r"(_a), "r"(_b), "r"(_c)	/* inputs  */		\
	: "d0", "d1", "d2", "a0", "a1", "a2"	/* clobbered regs */	\
	);								\
	retvalue;							\
})

#else 
#ifdef __MSHORT__

extern int tapebios();

#define trap_10_wwlw(n,a,b,c)	tapebios(n,a,(long)b,(long)c)

#endif
#endif 


/* DEFINITIONS FOR TAPE I/O FUNCTIONS */

#define Tfunc	0x0ACE	/* Tape BIOS Call for Tape function */

#define Ready	0	/* Tape Ready */
#define Read	1	/* Tape Read */
#define Write	2	/* Tape Write */
#define Rewind	3	/* Tape Rewind */
#define Load	4	/* Tape Load */
#define Unload	5	/* Tape Unload */
#define WrtFM	6	/* Write FileMark */
#define ReqSen	7	/* Request Sense */
#define ModSel	8	/* Mode Select */
#define ModSen	9	/* Mode Sense */
#define Space	10	/* Tape Space */
#define Erase	11	/* Tape Erase */
#define Inquire 12	/* Tape Inquiry */

#define Tready()	trap_10_wwll(Tfunc, Ready, 0L, 0L)
#define Tread(a, b)	trap_10_wwll(Tfunc, Read, a, b)
#define Twrite(a, b)	trap_10_wwll(Tfunc, Write, a, b)
#define Trewind()	trap_10_wwll(Tfunc, Rewind, 0L, 0L)
#define Tload(a)	trap_10_wwll(Tfunc, Load, 0L, a)
#define Tunload(a)	trap_10_wwll(Tfunc, Unload, 0L, a)
#define Tfmark(a)	trap_10_wwll(Tfunc, WrtFM, 0L, a)
#define Trsense(a, b)	trap_10_wwll(Tfunc, ReqSen, a, b)
#define Tmselect(a, b)	trap_10_wwll(Tfunc, ModSel, a, b)
#define Tmsense(a, b)	trap_10_wwll(Tfunc, ModSen, a, b)
#define Tspace(a)	trap_10_wwll(Tfunc, Space, 0L, a)
#define Terase()	trap_10_wwll(Tfunc, Erase, 0L, 0L)
#define Tinquire(a, b)	trap_10_wwll(Tfunc, Inquire, a, b)

#endif /* end of _TAPEBIND_H */

/*
 * basepage.h -- describe GEM-DOS base page structure.
 *
 * Copyright (c) 1981-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */
#ifndef BASEPAGE_H
#define BASEPAGE_H
/*
 * GEM-DOS base page structure, also called the "psp".
 * The documented elements have been supplemented with
 * information gleaned from disassembling the ROM-based system.
 */
typedef struct {
	long	p_lowtpa;	/* 0 Low transient program area (TPA) */
	long	p_hitpa;	/* 4 High TPA */
	long	p_tbase;	/* 8 Text segment base */
	long	p_tlen;		/* C Text segment length */
	long	p_dbase;	/* 10 Data length base */
	long	p_dlen;		/* 14 Data length length */
	long	p_bbase;	/* 18 bss segment base */
	long	p_blen;		/* 1C bss segment length */
	long	p_dta;		/* 20 data (dta) pointer (undocumented) */
	long	p_parent;	/* 24 Parent's basepage (undocumented) */
	long	p_fxx0;		/* 28 Undocumented */
	long	p_env;		/* 2C Environment string pointer */
	char	p_stdfh[6];	/* 30 Standard file handles (undocumented) */
	char	p_fxx1;		/* 36 Undocumented */
	char	p_curdrv;	/* 37 Current drive number (undocumented) */
	long	p_fxx2;		/* 38 Undocumented */
	long 	p_fxx3;		/* 3C Undocumented */
	long	p_fxx4;		/* 40 Undocumented */
	long	p_fxx5;		/* 44 Undocumented */
	long	p_fxx6;		/* 48 Undocumented */
	long	p_fxx7;		/* 4C Undocumented */
	long	p_fxx8;		/* 50 Undocumented */
	long	p_fxx9;		/* 54 Undocumented */
	long	p_fxx10;	/* 58 Undocumented */
	long	p_fxx11;	/* 5C Undocumented */
	long	p_fxx12;	/* 60 Undocumented */
	long	p_fxx13;	/* 64 Undocumented */
	long	p_saved0;	/* 68 Undocumented */
	long	p_savea3;	/* 6C Undocumented */
	long	p_savea4;	/* 70 Undocumented */
	long	p_savea5;	/* 74 Undocumented */
	long	p_savea6;	/* 78 Undocumented */
	long	p_saveusp;	/* 7C Undocumented */
	char	p_cmdlin[128];	/* Command line */
} BASEPAGE;
/*
 * When linked with an MWC runtime startup, the entry point and textbase
 * are named '_start'.  The basepage occupies the 256 bytes of memory
 * immediately preceding.
 */
extern BASEPAGE _start[];
#define BP	(&_start[-1])
/*
 * A pointer to the process's basepage is also passed at 4(sp) when the
 * process is executed.  crts0.s also passes the basepage pointer
 * as a fourth argument to main.
 */

/* GEM-DOS maintains a pointer to the basepage of the process currently
 * executing at this location in memory.  True for RAM- and ROM-loaded
 * systems as of 06/14/86.
 */
#define GEMBP	((BASEPAGE **)0x602C)
/*
 * When handling a GEM-DOS trap, the element "p_saveusp" points to a
 * considerable amount of saved context on the user's stack.
 * The layout is as follows:
 */
typedef struct {
	long	p_savessp;	/* The supervisor stack after clean up */
	int	p_savesr;	/* The status register from the trap */
	long	p_savepc;	/* The program counter from the trap */
	long	p_saved1;	/* The saved user d1 */
	long	p_saved2;	/* The saved user d2 */
	long	p_saved3;	/* The saved user d3 */
	long	p_saved4;	/* The saved user d4 */
	long	p_saved5;	/* The saved user d5 */
	long	p_saved6;	/* The saved user d6 */
	long	p_saved7;	/* The saved user d7 */
	long	p_savea0;	/* The saved user a0 */
	long	p_savea1;	/* The saved user a1 */
	long	p_savea2;	/* The saved user a2 */
/*
 * That's 50 bytes of stack overflow that you will never see in user
 * context.
 */
/*
 * Next are the GEM-DOS opcode and parameters pushed by the user:
 */
	int	p_op;		/* GEM-DOS operation requested */
				/* parameters for operation */
} OVERFLOW;
#endif
/* End of basepage.h */

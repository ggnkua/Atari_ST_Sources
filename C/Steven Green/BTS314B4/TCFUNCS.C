/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*                     Turbo C routines for BinkleyTerm                     */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*                                                                          */
/*  This module is derived from an original work by Russell J. Price, who   */
/*  has graciously allowed us to use his code in this work.                 */
/*                                                                          */
/*--------------------------------------------------------------------------*/

/*
   This module implements the utime() and _dos_read() functions for Turbo C,
   along with replacements for Turbo's IBM-specific cprintf(), cputs(), and
   putch() functions.
 
*/

#include <stdio.h>
#include <conio.h>
/* #include "tos.h" */
#include <io.h>
#include <ext.h>
#include <time.h>
#include <stdarg.h>
#include "tc_utime.h"

/* always uses modification time */
int cdecl utime(char *name, struct utimbuf *times)
{
	int handle;
	struct date d;
	struct time t;
	struct ftime ft;

#ifdef __DOS__
	unixtodos(times->modtime, &d, &t);
#endif

#ifdef __TOS__
	getdate(&d);
	gettime(&t);
#endif

	if ( times )
	{
	}

	ft.ft_tsec = t.ti_sec / 2;
	ft.ft_min = t.ti_min;
	ft.ft_hour = t.ti_hour;
	ft.ft_day = d.da_day;
	ft.ft_month = d.da_mon;
   ft.ft_year = d.da_year - 1980;
	if((handle = open(name, O_RDONLY)) == -1)
		return -1;

	setftime(handle, &ft);
	close(handle);
	return 0;
}

#ifndef __TOS__

int _dos_read(int fd, void far *buf, int nbytes, int *bytes_read)
{
	union REGS regs;
	struct SREGS sregs;

	regs.h.ah = 0x3f;	/* read file */
	regs.x.bx = fd;
	regs.x.cx = nbytes;
	regs.x.dx = FP_OFF(buf);
	sregs.ds = FP_SEG(buf);
	*bytes_read = intdosx(&regs, &regs, &sregs);
	return regs.x.cflag ? -1 : 0;
}

#endif

#ifndef __TURBOC__

int _Cdecl cprintf(const char *format, ...)
{
	va_list arg_ptr;

	va_start(arg_ptr, format);
	return vprintf(format, arg_ptr);
}

/* dunno why Turbo's <conio.h> declares this as
   int when the manual says it returns nothing */
int _Cdecl cputs (const char *str)
{
	printf("%s", str);
	return 0;
}

int _Cdecl putch(int ch)
{
	return putchar(ch);
}

#endif

#ifdef __TOS__

char *mktemp(char *pat)
{
	return tmpnam(pat);
}

void putenv(char *var)
{
	if ( var )
	{
	}
	
	/* Nothing */
}

void tzset(void)
{
	/* Nothing */
}

#endif

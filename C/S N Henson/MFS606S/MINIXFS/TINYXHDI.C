/*
	@(#)XHDI/xhdi.c
	
	Julian F. Reschke, 2. April 1993
	
	Bindings for the XHDI functions
	--- NOT FULLY TESTED, USE AT YOUR OWN RISK ---

    Important:
    
    Do calls only if XHGetVersion() was successful
*/

/* S.N.Henson: this has been hacked up a bit so gcc will tolerate it.
 * Define SUPER_CALL if functions will already be called from supervisor
 * mode (e.g. from an installable filesystem). Also define TINY_XHDI to
 * strip all but minixfs used functions.
 */

#include <stddef.h>
#include <stdio.h>
#include <string.h>
#ifdef __GNUC__
#include <osbind.h>
#define BPB _BPB
#else
#include <tos.h>
#endif

#include "xhdi.h"

#define XHDIMAGIC 0x27011992L

#ifdef __GNUC__
typedef LONG (*cookie_fun)(UWORD opcode,...);
#else
typedef LONG cdecl (*cookie_fun)(UWORD opcode,...);
#endif

#ifndef SUPER_CALL
static long
cookieptr (void)
{
	return *((long *)0x5a0);
}
#endif

static int
getcookie (long cookie, long *p_value)
{

#ifdef SUPER_CALL
	long *cookiejar = *((long **)0x5a0);
#else
	long *cookiejar = (long *)Supexec (cookieptr);
#endif

	if (!cookiejar) return 0;

	do
	{
		if (cookiejar[0] == cookie)
		{
			if (p_value) *p_value = cookiejar[1];
			return 1;
		}
		else
			cookiejar = &(cookiejar[2]);
	} while (cookiejar[-2]);

	return 0;
}

static cookie_fun
get_fun_ptr (void)
{
	static cookie_fun XHDI = NULL;
	static int have_it = 0;
	
	if (!have_it)
	{
		LONG *magic_test;
	
		getcookie (*((long *)"XHDI"), (LONG *)&XHDI);
		have_it = 1;

		/* check magic */
		
		magic_test = (LONG *)XHDI;
		if (magic_test && (magic_test[-1] != XHDIMAGIC))
			XHDI = NULL;
	}
	
	return XHDI;
}


UWORD
XHGetVersion (void)
{
	cookie_fun XHDI = get_fun_ptr ();

	UWORD ret = 0;		/* 0: kein Cookie da */
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif
	if (XHDI)
		ret = (UWORD) XHDI (0);
#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}

LONG
XHInqTarget (UWORD major, UWORD minor, ULONG *block_size,
             ULONG *device_flags, char *product_name)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL	
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif	
	ret = XHDI (1, major, minor, block_size, device_flags,
	            product_name);

#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}
#ifndef TINY_XHDI
LONG
XHReserve (UWORD major, UWORD minor, UWORD do_reserve, UWORD key)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif

	ret = XHDI (2, major, minor, do_reserve, key);

#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}

LONG
XHLock (UWORD major, UWORD minor, UWORD do_lock, UWORD key)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif

	ret = XHDI (3, major, minor, do_lock, key);

#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}

LONG
XHStop (UWORD major, UWORD minor, UWORD do_stop, UWORD key)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif

	ret = XHDI (4, major, minor, do_stop, key);

#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}

LONG
XHEject (UWORD major, UWORD minor, UWORD do_eject, UWORD key)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif

	ret = XHDI (5, major, minor, do_eject, key);

#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}

ULONG
XHDrvMap (void)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif
	ret = XHDI (6);
#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}
#endif
LONG
XHInqDev (UWORD bios_device, UWORD *major, UWORD *minor,
          ULONG *start_sector, BPB *bpb)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif
	ret = XHDI (7, bios_device, major, minor, start_sector, bpb);
#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}
#ifndef TINY_XHDI
LONG
XHInqDriver (UWORD bios_device, char *name, char *version,
	char *company, UWORD *ahdi_version, UWORD *maxIPL)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif
	ret = XHDI (8, bios_device, name, version, company, ahdi_version,
				maxIPL);
#ifndef SUPER_CALL
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}

LONG
XHNewCookie (void *newcookie)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif
	ret = XHDI (9, newcookie);
#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}
#endif
LONG
XHReadWrite (UWORD major, UWORD minor, UWORD rwflag,
             ULONG recno, UWORD count, void *buf)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif
	ret = XHDI (10, major, minor, rwflag, recno, count, buf);
#ifndef SUPER_CALL
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}
#ifndef TINY_XHDI
LONG
XHInqTarget2 (UWORD major, UWORD minor, ULONG *block_size,
              ULONG *device_flags, char *product_name,
              UWORD stringlen)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif
	ret = XHDI (11, major, minor, block_size, device_flags,
	            product_name, stringlen);
#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}
#endif
LONG
XHInqDev2 (UWORD bios_device, UWORD *major, UWORD *minor,
           ULONG *start_sector, BPB *bpb, ULONG *blocks,
           char *partid)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG ret;
#ifndef SUPER_CALL
	LONG oldstack = 0;

	if (!Super ((void *)1L)) oldstack = Super (0L);
#endif
	ret = XHDI (12, bios_device, major, minor, start_sector, bpb,
	            blocks, partid);
#ifndef SUPER_CALL		
	if (oldstack) Super ((void *)oldstack);
#endif
	return ret;
}
#ifndef TINY_XHDI
void
XHMakeName (UWORD major, UWORD minor, ULONG start_sector, char *name)
{
	if (major < 8)
	{
		sprintf (name, "ACSI.%d.%d.%ld", major, minor, start_sector);
		return;
	}	

	if (major < 16)
	{
		sprintf (name, "SCSI.%d.%d.%ld", major - 8, minor,
			start_sector);
		return;
	}	

	if (major < 18)
	{
		sprintf (name, "IDE.%d.%ld", major - 16, start_sector);
		return;
	}	

	if (major == 64)
	{
		sprintf (name, "FD.%d.%ld", minor, start_sector);
		return;
	}	
	
	sprintf (name, "XHDI.%d.%d.%ld", major, minor, start_sector);
}
#endif

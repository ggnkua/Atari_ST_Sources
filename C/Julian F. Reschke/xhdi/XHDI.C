/*
	@(#)XHDI/xhdi.c
	
	Julian F. Reschke, 21. August 1994
	
	Bindings for the XHDI functions
	--- NOT FULLY TESTED, USE AT YOUR OWN RISK ---

    Important:
    
    Do calls only if XHGetVersion() was successful
*/

#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>

#include "xhdi.h"

#define XHDIMAGIC 0x27011992L

typedef LONG cdecl (*cookie_fun)(UWORD opcode,...);

static long
cookieptr (void)
{
	return *((long *)0x5a0);
}

static int
getcookie (long cookie, long *p_value)
{
	long *cookiejar = (long *)Supexec (cookieptr);

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
	
		getcookie ('XHDI', (LONG *)&XHDI);
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
	LONG oldstack = 0;
	UWORD ret = 0;		/* 0: kein Cookie da */

	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	if (XHDI)
		ret = (UWORD) XHDI (0);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHInqTarget (UWORD major, UWORD minor, ULONG *block_size,
             ULONG *device_flags, char *product_name)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (1, major, minor, block_size, device_flags,
	            product_name);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHReserve (UWORD major, UWORD minor, UWORD do_reserve, UWORD key)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (2, major, minor, do_reserve, key);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHLock (UWORD major, UWORD minor, UWORD do_lock, UWORD key)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (3, major, minor, do_lock, key);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHStop (UWORD major, UWORD minor, UWORD do_stop, UWORD key)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (4, major, minor, do_stop, key);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHEject (UWORD major, UWORD minor, UWORD do_eject, UWORD key)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (5, major, minor, do_eject, key);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

ULONG
XHDrvMap (void)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (6);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHInqDev (UWORD bios_device, UWORD *major, UWORD *minor,
          ULONG *start_sector, BPB *bpb)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (7, bios_device, major, minor, start_sector, bpb);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHInqDriver (UWORD bios_device, char *name, char *version,
	char *company, UWORD *ahdi_version, UWORD *maxIPL)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (8, bios_device, name, version, company, ahdi_version,
				maxIPL);

	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHNewCookie (void *newcookie)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (9, newcookie);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHReadWrite (UWORD major, UWORD minor, UWORD rwflag,
             ULONG recno, UWORD count, void *buf)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (10, major, minor, rwflag, recno, count, buf);

	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHInqTarget2 (UWORD major, UWORD minor, ULONG *block_size,
              ULONG *device_flags, char *product_name,
              UWORD stringlen)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (11, major, minor, block_size, device_flags,
	            product_name, stringlen);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHInqDev2 (UWORD bios_device, UWORD *major, UWORD *minor,
           ULONG *start_sector, BPB *bpb, ULONG *blocks,
           char *partid)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (12, bios_device, major, minor, start_sector, bpb,
	            blocks, partid);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHDriverSpecial (ULONG key1, ULONG key2, UWORD subopcode, void *data)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (13, key1, key2, subopcode, data);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHGetCapacity (UWORD major, UWORD minor, ULONG *blocks, ULONG *bs)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (14, major, minor, blocks, bs);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHMediumChanged (UWORD major, UWORD minor)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (15, major, minor);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHMiNTInfo (UWORD opcode, void *data)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (16, opcode, data);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHDOSLimits (UWORD which, ULONG limit)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (17, which, limit);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHLastAccess (UWORD major, UWORD minor, ULONG *ms)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (18, major, minor, ms);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

LONG
XHReaccess (UWORD major, UWORD minor)
{
	cookie_fun XHDI = get_fun_ptr ();
	LONG oldstack = 0;
	LONG ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (19, major, minor);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}



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

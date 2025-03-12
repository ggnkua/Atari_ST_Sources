/*
	@(#)XHDI/xhdi.c
	
	Julian F. Reschke, 1999-05-02
	
	Bindings for the XHDI functions
	--- NOT FULLY TESTED, USE AT YOUR OWN RISK ---

    Important:
    
    Do calls only if XHGetVersion() was successful
    
    Modifiy for used with MiNTLib. Gerhard Stoll, 2015-12-01
    
*/

#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include <.\sys\cookie.h>

#include "xhdi.h"

#define XHDIMAGIC 0x27011992L

typedef long cdecl (*cookie_fun)(unsigned short opcode,...);

static cookie_fun
get_fun_ptr (void)
{
	static cookie_fun XHDI = NULL;
	static short have_it = 0;
	
	if (!have_it)
	{
		long *magic_test;
	
		Getcookie (C_XHDI /*'XHDI'*/, (long *)&XHDI);
		have_it = 1;

		/* check magic */
		
		magic_test = (long *)XHDI;
		if (magic_test && (magic_test[-1] != XHDIMAGIC))
			XHDI = NULL;
	}
	
	return XHDI;
}


unsigned short
XHGetVersion (void)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	unsigned short ret = 0;		/* 0: kein Cookie da */

	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	if (XHDI)
		ret = (unsigned short) XHDI (0);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHInqTarget (unsigned short major, unsigned short minor, unsigned long *block_size,
             unsigned long *device_flags, char *product_name)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (1, major, minor, block_size, device_flags,
	            product_name);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHReserve (unsigned short major, unsigned short minor, unsigned short do_reserve, unsigned short key)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (2, major, minor, do_reserve, key);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHLock (unsigned short major, unsigned short minor, unsigned short do_lock, unsigned short key)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (3, major, minor, do_lock, key);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHStop (unsigned short major, unsigned short minor, unsigned short do_stop, unsigned short key)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (4, major, minor, do_stop, key);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHEject (unsigned short major, unsigned short minor, unsigned short do_eject, unsigned short key)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (5, major, minor, do_eject, key);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

unsigned long
XHDrvMap (void)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (6);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHInqDev (unsigned short bios_device, unsigned short *major, unsigned short *minor,
          unsigned long *start_sector, _BPB *bpb)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (7, bios_device, major, minor, start_sector, bpb);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHInqDriver (unsigned short bios_device, char *name, char *version,
	char *company, unsigned short *ahdi_version, unsigned short *maxIPL)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (8, bios_device, name, version, company, ahdi_version,
				maxIPL);

	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHNewCookie (void *newcookie)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (9, newcookie);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHReadWrite (unsigned short major, unsigned short minor, unsigned short rwflag,
             unsigned long recno, unsigned short count, void *buf)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (10, major, minor, rwflag, recno, count, buf);

	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHInqTarget2 (unsigned short major, unsigned short minor, unsigned long *block_size,
              unsigned long *device_flags, char *product_name,
              unsigned short stringlen)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (11, major, minor, block_size, device_flags,
	            product_name, stringlen);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHInqDev2 (unsigned short bios_device, unsigned short *major, unsigned short *minor,
           unsigned long *start_sector, _BPB *bpb, unsigned long *blocks,
           char *partid)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (12, bios_device, major, minor, start_sector, bpb,
	            blocks, partid);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHDriverSpecial (unsigned long key1, unsigned long key2, unsigned short subopcode, void *data)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (13, key1, key2, subopcode, data);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHGetCapacity (unsigned short major, unsigned short minor, unsigned long *blocks, unsigned long *bs)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (14, major, minor, blocks, bs);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHMediumChanged (unsigned short major, unsigned short minor)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (15, major, minor);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHMiNTInfo (unsigned short opcode, void *data)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (16, opcode, data);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHDOSLimits (unsigned short which, unsigned long limit)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (17, which, limit);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHLastAccess (unsigned short major, unsigned short minor, unsigned long *ms)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (18, major, minor, ms);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}

long
XHReaccess (unsigned short major, unsigned short minor)
{
	cookie_fun XHDI = get_fun_ptr ();
	long oldstack = 0;
	long ret;
	
	if (!Super ((void *)1L)) oldstack = Super (0L);
	
	ret = XHDI (19, major, minor);
		
	if (oldstack) Super ((void *)oldstack);
	return ret;
}



void
XHMakeName (unsigned short major, unsigned short minor, unsigned long start_sector, char *name)
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

	if (major < 24)
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

/************************************************************************/
/* interface to the MINT kernel because you must not use GEMDOS or BIOS	*/
/* calls in an XDD.														*/
/* TC calling convention to stay compatible with TC's TCTOSLIB			*/
/* Copyright: Dr. Thomas Redelberger, 2000								*/
/* Tab 4																*/
/************************************************************************/
/*
$Id$
 */

#include "filesys.h"
#include "mymntlib.h"

extern struct kerinfo *kernel;

/* can use only kernel entry points in a MINT XDD */

int Cconws( const char *buf )
{
	return (*kernel->dos_tab[0x09])((char*)buf);
}


long Dcntl(short a, long b, long c)
{
	return (*kernel->dos_tab[0x130])((short)a, (long)b, (long)c);
}

int Tgettime(void)
{
	return (*kernel->dos_tab[0x2c])();
}


int Tgetdate(void)
{
	return (*kernel->dos_tab[0x2a])();
}


int Fcreate(char* a, short b)
{
	return (*kernel->dos_tab[0x3c])((char*)a, (short)b);
}


int Fopen(char* a, short b)
{
	return (*kernel->dos_tab[0x3d])((char*)a, (short)b);
}


int Fclose(short a)
{
	return (*kernel->dos_tab[0x3e])((short)a);
}


long Fread(short a, long b, char* c)
{
	return (*kernel->dos_tab[0xef])((short)a, (long)b, (char*)c);
}


long Fwrite(short a, long b, char* c)
{
	return (*kernel->dos_tab[0x40])((short)a, (long)b, (char*)c);
}


int Fdelete(char* a)
{
	return (*kernel->dos_tab[0x41])((char*)a);
}


int Fseek(long a, int b, int c)
{
	return (*kernel->dos_tab[0x42])((long)a, (int)b, (int)c);
}


void Bconout(int a, int b)
{
	(*kernel->bios_tab[0x03])((int)a, (int)b);
}


void _appl_yield(void)
{
	(*kernel->nap)(10);		/* millisecs */
}


int Random(void)
{
	return (*kernel->dos_tab[0x2c])();	/* fake: just use time */
}


long Supexec( long (*func)() )
{
	return (*func)();
}

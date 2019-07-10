/*
 * sysdep.h -- header file for some system-dependent things in Fnordadel
 *
 * 90Nov05 AA	Got rid of mach_dep.h and moved a few things from there to here
 * 88Jul21 orc	Stripped down to get rid of lurking system dependencies
 * 88Apr08 orc	#ifdefs put in for MS-DOS port
 * 87May19 orc	created.
 */

/*
 * This file done up for gcc 1.37 on the Atari ST (TOS)
 */

#ifndef _SYSDEP_H
#define _SYSDEP_H

extern long gemdos(), xbios();

#undef toupper		/* Why? */
#undef tolower		/*  ''  */

#define getch()		(char)Crawcin()

/*
 * `standard' i/o routines
 */
#define dcreat(f)	(int)Fcreate(f,0)
#define dopen(f,m)	(int)Fopen(f,m)
#define dclose(f)	Fclose(f)
#define dread(f,p,s)	Fread(f,(long)(s),(char *)(p))
#define dwrite(f,p,s)	Fwrite(f,(long)(s),(char *)(p))
#define dseek(f,l,w)	Fseek((long)(l), f, w)

#define dunlink(f)	Fdelete(f)
#define	drename(b,c)	Frename(0,b,c)

#define	safeopen	fopen
#define	mkdir		Dcreate

#endif /* _SYSDEP_H */

/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _SYSTEM_

#define _SYSTEM_

typedef struct 
{
	int puns;
	char v_p_un[16];
	long p_start[16];
	BPB bpbs[16];
} HDINFO;

#define trap1		( *( long cdecl (**)() ) 0x84L )
#define trap2		( *( long cdecl (**)() ) 0x88L )
#define trap3		( *( long cdecl (**)() ) 0x8CL )
#define trap13		( *( long cdecl (**)() ) 0xB4L )
#define trap14		( *( long cdecl (**)() ) 0xB8L )

#define prn_busy	( *( void (**)( void ) ) 0x100L )
#define hz200_timer	( *( void (**)( void ) ) 0x114L )
#define ikbdmidi	( *( void (**)( void ) ) 0x118L )

#define etv_critic	( *( int cdecl (**)( int error,int drive ) ) 0x404L )
#define etv_term	( *( void (**)( void ) ) 0x408L )

#define resvalid	( * (long *) 0x426L )
#define memctrl		( * (long *) 0x420L )			/* HR 230203 */
#define memval2		( * (long *) 0x43aL )			/* HR 230203 */
#define os_start	( * (long *) 0x4f2L )			/* HR 230203 */
#define phystop		( * (void **) 0x42EL )
#define resvector   ( * ( void (**)( void ) ) 0x42AL )

#define _timer_ms	( * (int *) 0x442L )
#define _fverify	( * (int *) 0x444L )
#define _bootdev	( * (int *) 0x446L )

#define _v_bas_ad	( * (void **) 0x44EL )

#define nvbls		( * (int *) 0x454L )
#define VBL			( ( void (***)( void ) ) 0x456L )
#define VBLempty	( ( void (*)( void ) ) 0L )

#define colorptr	( * (void **) 0x45AL )

#define hdv_bpb		( *( long cdecl (**)( int dev ) ) 0x472L )
#define hdv_rw		( *( long cdecl (**)( int rwflag,void *buf,int cnt,int recnr,int dev ) ) 0x476L )
#define hdv_mediach	( *( long cdecl (**)( int dev ) ) 0x47EL )

#define conterm		( * (char *) 0x484L )

#define _nflops		( * (int *) 0x4A6L )
#define _hz_200		( * (long *) 0x4BAL )
#define _drvbits	( * (long *) 0x4C2L )
#define _dumpflg	( * (int *) 0x4EEL )
#define _sysbase	( * ( (SYSHDR **) 0x4F2L ) )

#define scr_dump	( * ( void (**)( void ) ) 0x502L )

#define pun_ptr		( * ( ( HDINFO ** ) 0x516 ) )

#define xconstat_d0	( * ( long (**)( void ) ) 0x51EL )
#define xconstat_d1	( * ( long (**)( void ) ) 0x522L )
#define xconstat_d2	( * ( long (**)( void ) ) 0x526L )
#define xconstat_d3	( * ( long (**)( void ) ) 0x52AL )
#define xconstat_d4	( * ( long (**)( void ) ) 0x52EL )
#define xconstat_d5	( * ( long (**)( void ) ) 0x532L )
#define xconstat_d6	( * ( long (**)( void ) ) 0x536L )
#define xconstat_d7	( * ( long (**)( void ) ) 0x53AL )

#define xconin_d0	( * ( long (**)( void ) ) 0x53EL )
#define xconin_d1	( * ( long (**)( void ) ) 0x542L )
#define xconin_d2	( * ( long (**)( void ) ) 0x546L )
#define xconin_d3	( * ( long (**)( void ) ) 0x54AL )
#define xconin_d4	( * ( long (**)( void ) ) 0x54EL )
#define xconin_d5	( * ( long (**)( void ) ) 0x552L )
#define xconin_d6	( * ( long (**)( void ) ) 0x556L )
#define xconin_d7	( * ( long (**)( void ) ) 0x55AL )

#define xcostat_d0	( * ( long (**)( void ) ) 0x55EL )
#define xcostat_d1	( * ( long (**)( void ) ) 0x562L )
#define xcostat_d2	( * ( long (**)( void ) ) 0x566L )
#define xcostat_d3	( * ( long (**)( void ) ) 0x56AL )
#define xcostat_d4	( * ( long (**)( void ) ) 0x56EL )
#define xcostat_d5	( * ( long (**)( void ) ) 0x572L )
#define xcostat_d6	( * ( long (**)( void ) ) 0x576L )
#define xcostat_d7	( * ( long (**)( void ) ) 0x57AL )

#define xconout_d0	( * ( long (**)( int c ) ) 0x57EL )
#define xconout_d1	( * ( long (**)( int c ) ) 0x582L )
#define xconout_d2	( * ( long (**)( int c ) ) 0x586L )
#define xconout_d3	( * ( long (**)( int c ) ) 0x58AL )
#define xconout_d4	( * ( long (**)( int c ) ) 0x58EL )
#define xconout_d5	( * ( long (**)( int c ) ) 0x592L )
#define xconout_d6	( * ( long (**)( int c ) ) 0x596L )
#define xconout_d7	( * ( long (**)( int c ) ) 0x59AL )

#define long_frame	( * (int *) 0x59EL )
#define p_cookie	( * (void **) 0x5A0L )

#endif

/*
inet/inet.h

Created:	Dec 30, 1991 by Philip Homburg

Copyright 1995 Philip Homburg
*/

#ifndef INET__INET_H
#define INET__INET_H

#define _SYSTEM	1	/* get OK and negative error codes */

#include <minix/config.h>
#include <ansi.h>

#if (MACHINE == ATARI)
#define	CRAMPED 1
#else
#define CRAMPED (_EM_WSIZE==2)	/* 64K code and data is quite cramped. */
#endif /* MACHINE == ATARI */
#define ZERO 0	/* Used to comment out initialization code that does nothing. */

#if CRAMPED && (MACHINE != ATARI)
/* Keep 16-bit compiler from running out of memory. */
#undef _PROTOTYPE
#undef _ARGS
#define _PROTOTYPE(f, a) f()
#define _ARGS(a) ()
#endif

#include <sys/types.h>
#include <errno.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include <minix/config.h>
#include <minix/type.h>
#include <minix/const.h>
#include <minix/com.h>
#include <minix/syslib.h>
#include <net/hton.h>
#include <net/gen/ether.h>
#include <net/gen/eth_hdr.h>
#include <net/gen/eth_io.h>
#include <net/gen/in.h>
#include <net/gen/ip_hdr.h>
#include <net/gen/ip_io.h>
#include <net/gen/icmp.h>
#include <net/gen/icmp_hdr.h>
#include <net/gen/oneCsum.h>
#include <net/gen/psip_hdr.h>
#include <net/gen/psip_io.h>
#include <net/gen/route.h>
#include <net/gen/tcp.h>
#include <net/gen/tcp_hdr.h>
#include <net/gen/tcp_io.h>
#include <net/gen/udp.h>
#include <net/gen/udp_hdr.h>
#include <net/gen/udp_io.h>
#include <sys/ioctl.h>

#include "const.h"
#include "inet_config.h"

#define PUBLIC
#define EXTERN	extern
#define PRIVATE	static
#define FORWARD	static

typedef int ioreq_t;

#define THIS_FILE static char *this_file= __FILE__;

_PROTOTYPE( void panic0, (char *file, int line) );
#if CRAMPED
_PROTOTYPE( void panic, (char *file, int line) );
#else
_PROTOTYPE( void panic, (void) );
#endif /* CRAMPED */

#if !CRAMPED
#define ip_panic(print_list)  \
	(panic0(this_file, __LINE__), printf print_list, panic())
#else
#define ip_panic(print_list)  panic(this_file, __LINE__)
#endif

#if DEBUG
#define ip_warning(print_list)  \
	( \
		printf("warning at %s, %d: ", this_file, __LINE__), \
		printf print_list, \
		printf("\ninet stacktrace: "), \
		stacktrace() \
	)

#define DBLOCK(level, code) \
	do { if ((level) & DEBUG) { where(); code; } } while(0)
#define DIFBLOCK(level, condition, code) \
	do { if (((level) & DEBUG) && (condition)) \
		{ where(); code; } } while(0)

#else /* !DEBUG */
#define ip_warning(print_list)	0
#define DBLOCK(level, code)	0
#define DIFBLOCK(level, condition, code)	0
#endif

#define ARGS(x) _ARGS(x)

#define this_proc INET_PROC_NR
extern char version[];

void stacktrace ARGS(( void ));

#endif /* INET__INET_H */

/*
 * $PchId: inet.h,v 1.8 1996/05/07 21:05:04 philip Exp $
 */

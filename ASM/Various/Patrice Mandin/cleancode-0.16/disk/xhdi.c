/*
	XHDI

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#include <stdlib.h>

#include <mint/osbind.h>
#include <mint/cookie.h>
#include <mint/errno.h>

/*--- Defines ---*/

#define XHDI_MAGIC 0x27011992UL

#define XHDI_BEGIN(cookie,result,stack) \
	if (Getcookie(C_XHDI, &cookie) != C_FOUND) { \
		return result; \
	} \
	\
	if ( *(((unsigned long *)cookie)-1) != XHDI_MAGIC) { \
		return result; \
	} \
	\
	stack=NULL; \
	if (Super(1)==0) { \
		stack=(void *)Super(NULL); \
	}

#define XHDI_END(cookie,result,stack) \
	if (stack!=NULL) { \
		Super(stack); \
	} \
	\
	return result;

/*--- XHDI function calls ---*/

#define XHDICALL_w_w(cookie,n)	\
__extension__	\
({	\
	register short retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"addql	#2,sp"		\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_w(cookie,n)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"addql	#2,sp"		\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wl(cookie,n,p1)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"addql	#6,sp"		\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_www(cookie,n,p1,p2)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movw	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"addql	#6,sp"		\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwl(cookie,n,p1,p2)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(8),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwwl(cookie,n,p1,p2,p3)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%5,sp@-;\n\t"	\
		"movw	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(10),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwwww(cookie,n,p1,p2,p3,p4)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movw	%6,sp@-;\n\t"	\
		"movw	%5,sp@-;\n\t"	\
		"movw	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(10),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3), "g"(p4)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwwll(cookie,n,p1,p2,p3,p4)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%6,sp@-;\n\t"	\
		"movl	%5,sp@-;\n\t"	\
		"movw	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(14),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3), "g"(p4)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wllwl(cookie,n,p1,p2,p3,p4)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%6,sp@-;\n\t"	\
		"movw	%5,sp@-;\n\t"	\
		"movl	%4,sp@-;\n\t"	\
		"movl	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(16),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3), "g"(p4)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwwlll(cookie,n,p1,p2,p3,p4,p5)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%7,sp@-;\n\t"	\
		"movl	%6,sp@-;\n\t"	\
		"movl	%5,sp@-;\n\t"	\
		"movw	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(18),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3), "g"(p4), "g"(p5)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwllll(cookie,n,p1,p2,p3,p4,p5)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%7,sp@-;\n\t"	\
		"movl	%6,sp@-;\n\t"	\
		"movl	%5,sp@-;\n\t"	\
		"movl	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(20),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3), "g"(p4), "g"(p5)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwwwlwl(cookie,n,p1,p2,p3,p4,p5,p6)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%8,sp@-;\n\t"	\
		"movw	%7,sp@-;\n\t"	\
		"movl	%6,sp@-;\n\t"	\
		"movw	%5,sp@-;\n\t"	\
		"movw	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(18),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3), "g"(p4), "g"(p5), "g"(p6)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwwlllw(cookie,n,p1,p2,p3,p4,p5,p6)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movw	%8,sp@-;\n\t"	\
		"movl	%7,sp@-;\n\t"	\
		"movl	%6,sp@-;\n\t"	\
		"movl	%5,sp@-;\n\t"	\
		"movw	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(20),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3), "g"(p4), "g"(p5), "g"(p6)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwlllll(cookie,n,p1,p2,p3,p4,p5,p6)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%8,sp@-;\n\t"	\
		"movl	%7,sp@-;\n\t"	\
		"movl	%6,sp@-;\n\t"	\
		"movl	%5,sp@-;\n\t"	\
		"movl	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(24),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3), "g"(p4), "g"(p5), "g"(p6)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define XHDICALL_l_wwllllll(cookie,n,p1,p2,p3,p4,p5,p6,p7)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%9,sp@-;\n\t"	\
		"movl	%8,sp@-;\n\t"	\
		"movl	%7,sp@-;\n\t"	\
		"movl	%6,sp@-;\n\t"	\
		"movl	%5,sp@-;\n\t"	\
		"movl	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"		\
		"lea	sp@(28),sp"	\
		: "=r"(retvalue)			/* outputs */	\
		: "a"(cookie), "g"(n), "g"(p1), "g"(p2), "g"(p3), "g"(p4), "g"(p5), "g"(p6), "g"(p7)		/* inputs  */	\
		: "d0", "d1", "a0", "a1" 	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

/*--- Variables ---*/

static unsigned long cookie_xhdi;
static void *oldstack;

/*--- Functions prototypes ---*/

/*--- Functions ---*/

unsigned short XHGetVersion(void)
{
	unsigned short result=0;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_w_w(cookie_xhdi, 0);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHInqTarget(
	unsigned short major,
	unsigned short minor,
	unsigned long *blocksize,
	unsigned long *device_flags,
	char *product_name
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwwlll(cookie_xhdi, 1,major,minor,blocksize,device_flags,product_name);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHReserve(
	unsigned short major,
	unsigned short minor,
	unsigned short do_reserve,
	unsigned short key
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwwww(cookie_xhdi, 2,major,minor,do_reserve,key);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHLock(
	unsigned short major,
	unsigned short minor,
	unsigned short do_lock,
	unsigned short key
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwwww(cookie_xhdi, 3,major,minor,do_lock,key);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHStop(
	unsigned short major,
	unsigned short minor,
	unsigned short do_stop,
	unsigned short key
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwwww(cookie_xhdi, 4,major,minor,do_stop,key);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHEject(
	unsigned short major,
	unsigned short minor,
	unsigned short do_eject,
	unsigned short key
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwwww(cookie_xhdi, 5,major,minor,do_eject,key);
	XHDI_END(cookie_xhdi, result, oldstack);
}

unsigned long XHDrvMap(void)
{
	unsigned long result=0;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_w(cookie_xhdi, 6);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHInqDev(
	unsigned short bios_device,
	unsigned short *major,
	unsigned short *minor,
	unsigned long *start_sector,
	_BPB *bpb
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwllll(cookie_xhdi, 7,bios_device,major,minor,start_sector,bpb);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHInqDriver(
	unsigned short bios_device,
	char *name,
	char *version,
	char *company,
	unsigned short *ahdi_version,
	unsigned short *max_ipl
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwlllll(cookie_xhdi, 8,bios_device,name,version,company,ahdi_version,max_ipl);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHNewCookie(unsigned long newcookie)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wl(cookie_xhdi, 9,newcookie);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHReadWrite(
	unsigned short major,
	unsigned short minor,
	unsigned short rwflag,
	unsigned long recno,
	unsigned short count,
	void *buf
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwwwlwl(cookie_xhdi, 10,major,minor,rwflag,recno,count,buf);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHInqTarget2(
	unsigned short major,
	unsigned short minor,
	unsigned long *blocksize,
	unsigned long *device_flags,
	char *product_name,
	unsigned short stringlen
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwwlllw(cookie_xhdi, 11,major,minor,blocksize,device_flags,product_name,stringlen);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHInqDev2(
	unsigned short bios_device,
	unsigned short *major,
	unsigned short *minor,
	unsigned long *start_sector,
	_BPB *bpb,
	unsigned long *blocks,
	char *partid
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwllllll(cookie_xhdi, 12,bios_device,major,minor,start_sector,bpb,blocks,partid);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHDriverSpecial(
	unsigned long key1,
	unsigned long key2,
	unsigned short subopcode,
	void *data
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wllwl(cookie_xhdi, 13,key1,key2,subopcode,data);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHGetCapacity(
	unsigned short major,
	unsigned short minor,
	unsigned long *blocks,
	unsigned long *blocksize
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwwll(cookie_xhdi, 14,major,minor,blocks,blocksize);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHMediumChanged(
	unsigned short major,
	unsigned short minor
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_www(cookie_xhdi, 15,major,minor);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHMiNTInfo(
	unsigned short opcode,
	void *data
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwl(cookie_xhdi, 16,opcode,data);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHDOSLimits(
	unsigned short which,
	unsigned long limit
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwl(cookie_xhdi, 17,which,limit);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHLastAccess(
	unsigned short major,
	unsigned short minor,
	unsigned long *ms
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_wwwl(cookie_xhdi, 18,major,minor,ms);
	XHDI_END(cookie_xhdi, result, oldstack);
}

long XHReaccess(
	unsigned short major,
	unsigned short minor
)
{
	long result=-ENOSYS;

	XHDI_BEGIN(cookie_xhdi, result, oldstack);
	result = XHDICALL_l_www(cookie_xhdi, 19,major,minor);
	XHDI_END(cookie_xhdi, result, oldstack);
}

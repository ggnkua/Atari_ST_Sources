/*
	SCSIdrv calling functions

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

#include <stdio.h>
#include <stdlib.h>

#include <mint/osbind.h>
#include <mint/cookie.h>
#include <mint/errno.h>

#include "scsidrv.h"

/*--- Defines ---*/

#define SCSIDRV_BEGIN(stack) \
	stack=NULL; \
	if (Super(1)==0) { \
		stack=(void *)Super(NULL); \
	}

#define SCSIDRV_END(stack) \
	if (stack!=NULL) { \
		Super(stack); \
	}

/*--- SCSIDRV function calls ---*/
/* necessary because gcc only saves d0-d1/a0-a1 on function calls, */
/* and scsidrv functions can modify d0-d2/a0-a1 */

#define SCSIDRVCALL_l_w(func_ptr,p1)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"	\
		"addqw	#2,sp"	\
		: "=r"(retvalue)				/* outputs */	\
		: "a"(func_ptr), "g"(p1)		/* inputs  */	\
		: "d0", "d1", "d2", "a0", "a1"	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define SCSIDRVCALL_l_l(func_ptr,p1)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"	\
		"addqw	#4,sp"	\
		: "=r"(retvalue)				/* outputs */	\
		: "a"(func_ptr), "g"(p1)		/* inputs  */	\
		: "d0", "d1", "d2", "a0", "a1"	/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define SCSIDRVCALL_l_ww(func_ptr,p1,p2)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"	\
		"addqw	#4,sp"	\
		: "=r"(retvalue)					/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2)	/* inputs  */	\
		: "d0", "d1", "d2", "a0", "a1"		/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define SCSIDRVCALL_l_wl(func_ptr,p1,p2)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"	\
		"addqw	#6,sp"	\
		: "=r"(retvalue)					/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2)	/* inputs  */	\
		: "d0", "d1", "d2", "a0", "a1"		/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define SCSIDRVCALL_l_wwl(func_ptr,p1,p2,p3)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"	\
		"lea	sp@(8),sp"	\
		: "=r"(retvalue)							/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2), "g"(p3)	/* inputs  */	\
		: "d0", "d1", "d2", "a0", "a1"				/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define SCSIDRVCALL_l_wll(func_ptr,p1,p2,p3)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%4,sp@-;\n\t"	\
		"movl	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"	\
		"lea	sp@(10),sp"	\
		: "=r"(retvalue)							/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2), "g"(p3)	/* inputs  */	\
		: "d0", "d1", "d2", "a0", "a1"				/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define SCSIDRVCALL_l_wlll(func_ptr,p1,p2,p3,p4)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movl	%5,sp@-;\n\t"	\
		"movl	%4,sp@-;\n\t"	\
		"movl	%3,sp@-;\n\t"	\
		"movw	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"	\
		"lea	sp@(14),sp"	\
		: "=r"(retvalue)							/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2), "g"(p3), "g"(p4)	/* inputs  */	\
		: "d0", "d1", "d2", "a0", "a1"				/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

#define SCSIDRVCALL_l_lww(func_ptr,p1,p2,p3)	\
__extension__	\
({	\
	register long retvalue __asm__("d0");	\
	\
	__asm__ volatile	\
	(	"movw	%4,sp@-;\n\t"	\
		"movw	%3,sp@-;\n\t"	\
		"movl	%2,sp@-;\n\t"	\
		"jbsr	%1@;\n\t"	\
		"lea	sp@(8),sp"	\
		: "=r"(retvalue)							/* outputs */	\
		: "a"(func_ptr), "g"(p1), "g"(p2), "g"(p3)	/* inputs  */	\
		: "d0", "d1", "d2", "a0", "a1"				/* clobbered regs */	\
		AND_MEMORY	\
	);	\
	retvalue;	\
})

/*--- Types ---*/

typedef unsigned char scsi_reqdata_t[18];

/* Cookie SCSI points to this */
typedef struct {
	unsigned short version;

	long (*in)(scsi_cmd_t *params);
	long (*out)(scsi_cmd_t *params);
	long (*inquire_scsi)(short what, scsi_businfo_t *info);
	long (*inquire_bus)(short what, short busno, scsi_devinfo_t *device);
	long (*check_dev)(short busno, const scsi_long64_t *scsi_id, char *name, unsigned short *features);
	long (*rescan_bus)(short busno);
	long (*open)(short busno, const scsi_long64_t *scsi_id, unsigned long *maxlen);
	long (*close)(short *handle);
	long (*error)(short *handle, short rwflag, short errno);

	long (*install)(short bus, scsi_targethandler_t *handler);
	long (*deinstall)(short bus, scsi_targethandler_t *handler);
	long (*get_cmd)(short bus, unsigned char *cmd);
	long (*send_data)(short bus, unsigned char *buffer, unsigned long length);
	long (*get_data)(short bus, void *buffer, unsigned long length);
	long (*send_status)(short bus, unsigned short status);
	long (*send_msg)(short bus, unsigned short msg);
	long (*get_msg)(short bus, unsigned short *msg);

	scsi_reqdata_t *req_data;
} scsidrv_t __attribute__((packed));

/*--- Variables ---*/

static scsidrv_t *cookie_scsi;

/*--- Functions prototypes ---*/

/*--- Functions ---*/

long scsidrv_init(void)
{
	if (Getcookie(C_SCSI, (unsigned long *)&cookie_scsi) != C_FOUND) {
		return -ENOSYS;
	}

	return 0;
}

unsigned short scsidrv_get_version(void)
{
	return cookie_scsi->version;
}

long scsidrv_in(scsi_cmd_t *params)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->in(params);*/
	result=SCSIDRVCALL_l_l(cookie_scsi->in, params);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_out(scsi_cmd_t *params)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->out(params);*/
	result=SCSIDRVCALL_l_l(cookie_scsi->out, params);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_inquire_scsi(short what, scsi_businfo_t *info)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->inquire_scsi(what, info);*/
	result=SCSIDRVCALL_l_wl(cookie_scsi->inquire_scsi, what, info);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_inquire_bus(short what, short busno, scsi_devinfo_t *device)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->inquire_bus(what, busno, device);*/
	result=SCSIDRVCALL_l_wwl(cookie_scsi->inquire_bus, what, busno, device);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_check_dev(short busno, const scsi_long64_t *scsi_id, char *name, unsigned short *features)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->check_dev(busno, scsi_id, name, features);*/
	result=SCSIDRVCALL_l_wlll(cookie_scsi->check_dev, busno, scsi_id, name, features);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_rescan_bus(short busno)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->rescan_bus(busno);*/
	result=SCSIDRVCALL_l_w(cookie_scsi->rescan_bus, busno);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_open(short busno, const scsi_long64_t *scsi_id, unsigned long *maxlen)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->open(busno, scsi_id, maxlen);*/
	result=SCSIDRVCALL_l_wll(cookie_scsi->open, busno, scsi_id, maxlen);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_close(short *handle)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->close(handle);*/
	result=SCSIDRVCALL_l_l(cookie_scsi->close, handle);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_error(short *handle, short rwflag, short errno)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->error(handle, rwflag, errno);*/
	result=SCSIDRVCALL_l_lww(cookie_scsi->error, handle, rwflag, errno);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_install(short bus, scsi_targethandler_t *handler)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->install(bus, handler);*/
	result=SCSIDRVCALL_l_wl(cookie_scsi->install, bus, handler);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_deinstall(short bus, scsi_targethandler_t *handler)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->deinstall(bus, handler);*/
	result=SCSIDRVCALL_l_wl(cookie_scsi->deinstall, bus, handler);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_get_cmd(short bus, unsigned char *cmd)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->get_cmd(bus, cmd);*/
	result=SCSIDRVCALL_l_wl(cookie_scsi->get_cmd, bus, cmd);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_send_data(short bus, unsigned char *buffer, unsigned long length)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->send_data(bus, buffer, length);*/
	result=SCSIDRVCALL_l_wll(cookie_scsi->send_data, bus, buffer, length);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_get_data(short bus, void *buffer, unsigned long length)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->get_data(bus, buffer, length);*/
	result=SCSIDRVCALL_l_wll(cookie_scsi->get_data, bus, buffer, length);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_send_status(short bus, unsigned short status)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->send_status(bus, status);*/
	result=SCSIDRVCALL_l_wl(cookie_scsi->send_status, bus, status);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_send_msg(short bus, unsigned short msg)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->send_msg(bus, msg);*/
	result=SCSIDRVCALL_l_ww(cookie_scsi->send_msg, bus, msg);
	SCSIDRV_END(oldstack);
	return result;
}

long scsidrv_get_msg(short bus, unsigned short *msg)
{
	void *oldstack;
	long result;

	SCSIDRV_BEGIN(oldstack);
/*	result=cookie_scsi->get_msg(bus, msg);*/
	result=SCSIDRVCALL_l_wl(cookie_scsi->get_msg, bus, msg);
	SCSIDRV_END(oldstack);
	return result;
}

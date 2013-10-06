/*
	SCSI drv functions

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

#ifndef _SCSIDRV_H
#define _SCSIDRV_H

/*--- Defines ---*/

/* inquire_[scsi,bus], 'what' parameter */
#define SCSIDRV_INQUIRE_FIRST 0
#define SCSIDRV_INQUIRE_NEXT 1

/* businfo_t, features */
#define SCSIDRV_ARBIT		(1<<0)
#define SCSIDRV_ALLCMDS		(1<<1)
#define SCSIDRV_TARGETCTL	(1<<2)
#define SCSIDRV_TARGET		(1<<3)
#define SCSIDRV_DISCONNECT	(1<<4)
#define SCSIDRV_SCATTER		(1<<5)

/*--- Types ---*/

typedef struct {
	unsigned long high;
	unsigned long low;
} scsi_long64_t, scsi_ulong64_t __attribute__((packed));

typedef struct {
	unsigned long bus_ids;
	unsigned char reserved[28];
} scsi_private_t __attribute__((packed));

typedef struct {
	scsi_private_t private;
	char busname[20];
	unsigned short busno;
	unsigned short features;
	unsigned long maxlen;
} scsi_businfo_t __attribute__((packed));

typedef struct {
	unsigned char private[32];
	scsi_long64_t scsi_id;
} scsi_devinfo_t __attribute__((packed));

typedef struct {
	short *handle;				/* Handle of SCSIdrv device */
	unsigned char *cmd;			/* Pointer to command */
	unsigned short cmdlen;		/* Length of command */
	void *buffer;				/* Input/output buffer */
	unsigned long transferlen;	/* Maximum transfer length */
	unsigned char *sensebuffer;	/* Pointer to 18bytes buffer */
	unsigned long timeout;		/* in 200Hz tics */
	unsigned short flags;
} scsi_cmd_t __attribute__((packed));

typedef struct {
	void *next;
	short (*tsel)(short bus, unsigned short csb, unsigned short csd);
	short (*tcmd)(short bus, unsigned short cmd);
	unsigned short (*tcmdlen)(short bus, unsigned short cmd);
	void (*treset)(short bus);
	void (*teop)(short bus);
	void (*tperr)(short bus);
	void (*tpmism)(short bus);
	void (*tbloss)(short bus);
	void (*tunknownint)(short bus);
} scsi_targethandler_t __attribute__((packed));

/*--- Functions prototypes ---*/

long scsidrv_init(void);
unsigned short scsidrv_get_version(void);

long scsidrv_in(scsi_cmd_t *params);
long scsidrv_out(scsi_cmd_t *params);
long scsidrv_inquire_scsi(short what, scsi_businfo_t *info);
long scsidrv_inquire_bus(short what, short busno, scsi_devinfo_t *device);
long scsidrv_check_dev(short busno, const scsi_long64_t *scsi_id, char *name, unsigned short *features);
long scsidrv_rescan_bus(short busno);
long scsidrv_open(short busno, const scsi_long64_t *scsi_id, unsigned long *maxlen);
long scsidrv_close(short *handle);
long scsidrv_error(short *handle, short rwflag, short errno);

long scsidrv_install(short bus, scsi_targethandler_t *handler);
long scsidrv_deinstall(short bus, scsi_targethandler_t *handler);
long scsidrv_get_cmd(short bus, unsigned char *cmd);
long scsidrv_send_data(short bus, unsigned char *buffer, unsigned long length);
long scsidrv_get_data(short bus, void *buffer, unsigned long length);
long scsidrv_send_status(short bus, unsigned short status);
long scsidrv_send_msg(short bus, unsigned short msg);
long scsidrv_get_msg(short bus, unsigned short *msg);

#endif /* _SCSIDRV_H */

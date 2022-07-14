/*
 * USB Storage SCSIDRV Implementation (C) 2014-2015.
 * By Alan Hourihane <alanh@fairlite.co.uk>
 */

#include "../../global.h"
#include "scsi.h"
#include "part.h"
#include "../../usb.h"
#include "../../usb_api.h"
#include "usb_storage.h"

extern struct mass_storage_dev mass_storage_dev[USB_MAX_STOR_DEV];

extern void usb_stor_eject (long);
extern long usb_request_sense (ccb *srb, struct us_data *ss);

#define USBNAME "USB Mass Storage"

//#define DEBUGSCSIDRV
#ifdef DEBUGSCSIDRV
#ifdef TOSONLY
#define debug(a) (void)Cconws(a)
#else
#define debug(a) DEBUG((a))
#endif
#else
#define debug(a)
#endif


#include "mint/scsidrv.h"

#ifdef TOSONLY
typedef struct
{
	long ident;
	union
	{
		long l;
		short i[2];
		char c[4];
	} v;
} COOKIE;

static COOKIE *
findcookie (void)
{
	COOKIE *p;
	long stack;
	stack = 0;
	if (Super (1L) >= 0)
		stack = Super (0L);
	p = *(COOKIE **) 0x5a0;
	if (stack)
		SuperToUser ((void *) stack);
	if (!p)
		return ((COOKIE *) 0);
	return (p);
}

static COOKIE *
ncookie (COOKIE * p)
{
	if (!p->ident)
		return (0);
	return (++p);
}

static int
add_cookie (COOKIE * cook)
{
	COOKIE *p;
	int i = 0;
	p = findcookie ();
	while (p)
	{
		if (p->ident == cook->ident)
		{
			*p = *cook;
			return (0);
		}
		if (!p->ident)
		{
			if (i + 1 < p->v.l)
			{
				*(p + 1) = *p;
				*p = *cook;
				return (0);
			}
			else
			{
				c_conws("Failed to add SCSIDRV cookie, no slots left. Install bigger cookie jar.\r\n");
				return (-2);	/* problem */
			}
		}
		i++;
		p = ncookie (p);
	}

	c_conws("Failed to add SCSIDRV cookie, no slots left. Install bigger cookie jar.\r\n");
	return (-1);				/* no cookie-jar */
}

long ssp;
static COOKIE SCSIDRV_COOKIE;
#endif /* TOSONLY */

static REQDATA reqdata;

typedef struct SCSIDRV_Data
{
	ushort features; /* this has to be at the top ! */
	short changed;
} SCSIDRV_Data;

static SCSIDRV_Data* private = NULL;
static SCSIDRV scsidrv;
static SCSIDRV oldscsi;
static unsigned short USBbus = 3; /* default */

void SCSIDRV_MediaChange(int dev);

/*
 * USB functions
 */

void
SCSIDRV_MediaChange(int dev)
{
	// On TOS this is called during boot, before install_scsidrv() has the chance to allocate 'private'.
	if (private)
		private[dev].changed = TRUE;
}

/*
 * SCSIDRV handlers
 */

static long
SCSIDRV_Install (ushort bus, TARGET *handler)
{
	return 0;
}

static long
SCSIDRV_Deinstall (ushort bus, TARGET *handler)
{
	return 0;
}

static long
SCSIDRV_GetCmd (ushort bus, char *cmd)
{
	return 0;
}

static long
SCSIDRV_SendData (ushort bus, char *buf, ulong len)
{
	return 0;
}

static long
SCSIDRV_GetData (ushort bus, void *buf, ulong len)
{
	return 0;
}

static long
SCSIDRV_SendStatus (ushort bus, ushort status)
{
	return 0;
}

static long
SCSIDRV_SendMsg (ushort bus, ushort msg)
{
	return 0;
}

static long
SCSIDRV_GetMsg (ushort bus, ushort * msg)
{
	return 0;
}

static long
SCSIDRV_In (SCSICMD *parms)
{
	SCSIDRV_Data *priv = NULL;
	long i;

	debug ("IN\r\n");

	for (i = 0; i < USB_MAX_STOR_DEV; i++) {
		if (&private[i] == (SCSIDRV_Data *) parms->handle) {
			priv = (SCSIDRV_Data *) parms->handle;
			break;
		}
	}

	if (priv)
	{
		if (mass_storage_dev[i].target != 0xff)
		{
			struct us_data *ss = &mass_storage_dev[i].usb_stor;
			long retries = 0;
			ccb srb;
			long r, dev = i;

			if (parms->cmdlen > 16) {
				return STATUSERROR;
			}

			/* Note for SCSI_REQ_SENSE command: Last sense data will be in the */
			/* data buffer. Sense data for the command itself, if it failed, */
			/* will be in the sense buffer, */

			/* Filter commands for non existent LUNs */
			if (((parms->cmd[1] & 0xE0) >> 5 ) > mass_storage_dev[i].total_lun) {
				parms->sense[0] = 0x70;
				parms->sense[2] = SENSE_ILLEGAL_REQUEST;
				parms->sense[7] = 0x0A;
				parms->sense[12] = 0x25;
				parms->sense[13] = 0x00;
				if (parms->cmd[0] == SCSI_REQ_SENSE) {
					char *buffer = (char *) parms->buf;
					for (i = 0; i < parms->transferlen; i++)
					{
						buffer[i] = parms->sense[i];
					}
					parms->sense[2] = parms->sense[12] = 0x00;
					return NOSCSIERROR;
				} else {
					return S_CHECK_COND;
				}
			}

			memset (&srb, 0, sizeof (srb));
			for (i = 0; i < parms->cmdlen; i++)
			{
				srb.cmd[i] = parms->cmd[i];
			}

			srb.cmdlen = parms->cmdlen;
			srb.datalen = parms->transferlen;
			srb.pdata = parms->buf;
			srb.lun = (parms->cmd[1] & 0xE0) >> 5;
			srb.direction = USB_CMD_DIRECTION_IN;
			srb.timeout = parms->timeout * 5;

#if 0
			c_conws ("SCSIPACKET\r\n");
			hex_long (srb.cmd[0]);
			c_conout(' ');
			hex_long (srb.cmd[1]);
			c_conout(' ');
			hex_long (srb.cmd[2]);
			c_conout(' ');
			hex_long (srb.cmd[3]);
			c_conout(' ');
			hex_long (srb.cmd[4]);
			c_conout(' ');
			hex_long (srb.cmd[5]);
			c_conws ("\r\n");
			hex_long (srb.cmdlen);
			c_conws ("\r\n");
			hex_long (srb.datalen);
			c_conws ("\r\n");
#endif

			if (srb.cmd[0] == SCSI_INQUIRY)
				retries = 3;

			if (srb.cmd[0] == SCSI_RD_CAPAC ||
			    srb.cmd[0] == SCSI_RD_CAPAC16) {
				ccb pccb;

				retries = 5;

				memset(&pccb.cmd[0], 0, 12);
				pccb.cmd[0] = SCSI_TST_U_RDY;
				pccb.datalen = 0;
				pccb.cmdlen = 12;
				pccb.lun = srb.lun;
				r = ss->transport(&pccb, ss);
				if (r == USB_STOR_TRANSPORT_FAILED
					|| r == USB_STOR_TRANSPORT_DATA_FAILED
					|| r == USB_STOR_TRANSPORT_ERROR)
					return STATUSERROR;
				else if(r == USB_STOR_TRANSPORT_SENSE) {
					usb_request_sense(&srb, ss);
					memcpy(parms->sense, srb.sense_buf, 18);
					return S_CHECK_COND;
				}
			}
			
			/* an EJECT command? */
			if (srb.cmd[0] == SCSI_START_STP &&
				srb.cmd[4] & SCSI_START_STP_LOEJ &&
				!(srb.cmd[4] & SCSI_START_STP_START) &&
				!(srb.cmd[4] & SCSI_START_STP_PWCO))
			{
				usb_stor_eject(mass_storage_dev[dev].usb_dev_desc[srb.lun]->usb_logdrv);
			}

			if (srb.cmd[0] == SCSI_TST_U_RDY) {
				retries = 10;
			}

			if (srb.cmd[0] == SCSI_REPORT_LUN) {
				parms->sense[2] = SENSE_ILLEGAL_REQUEST;
				parms->sense[12] = 0x20;
				parms->sense[13] = 0x00;
				return S_CHECK_COND;
			}

			/* promote read6 to read10 */
			if (srb.cmd[0] == SCSI_READ6)
			{
				long block;
				srb.cmd[0] = SCSI_READ10;
				block = (long) (srb.cmd[1] & 0x1f) << 16 |
					(long) srb.cmd[2] << 8 | (long) srb.cmd[3];
                		/* do 4 & 5 here as we overwrite them later */
				srb.cmd[8] = srb.cmd[4];
				srb.cmd[9] = srb.cmd[5];
				srb.cmd[2] = (block >> 24) & 0xff;
				srb.cmd[3] = (block >> 16) & 0xff;
				srb.cmd[4] = (block >> 8) & 0xff;
				srb.cmd[5] = block & 0xff;
				srb.cmd[6] = 0;
				srb.cmd[7] = 0;
				srb.cmdlen = 10;
			}

			/* XXXX: Needs verification !!!!!
			 */
			/* This failed sdrvtest on a USB key. */
			/* priv->changed is set in part_init() in usb_storage.c */
			/* by SCSIDRV_MediaChange but is not need to detect media changes */
#if 0
			if (srb.cmd[0] == SCSI_TST_U_RDY && priv->changed) {
				/* Report Media Change sense key */
				/* 2 = sense key (bits 0 to 3) */
				/* 12 = ASC. 28h = media was inserted. */
				/* 13 = ASCQ. Set to 00h */
				parms->sense[2] = SENSE_UNIT_ATTENTION;
				parms->sense[12] = 0x28;
				parms->sense[13] = 0x00;
				priv->changed = FALSE;
				return S_CHECK_COND;
			}
#endif


retry:
			r = ss->transport (&srb, ss);
			
			if (r == USB_STOR_TRANSPORT_SENSE) {
				usb_request_sense(&srb, ss);
				memcpy(parms->sense, srb.sense_buf, 18);
				return S_CHECK_COND;
			}
			
			if (r != USB_STOR_TRANSPORT_GOOD && retries--) {
				goto retry;
			}
			
			switch(r)
			{
				case USB_STOR_TRANSPORT_GOOD :
					return NOSCSIERROR;
				case USB_STOR_TRANSPORT_DATA_FAILED :
					return TRANSERROR;
				case USB_STOR_TRANSPORT_PHASE_ERROR :
					return PHASEERROR;
				case USB_STOR_TRANSPORT_TIMEOUT :
					return TIMEOUTERROR;
				default:
					return STATUSERROR;
			}
			
#if 0		/* Fix up INQUIRY NUL bytes to spaces. */
			/* Doesn't seem to be needed. */
			/* If so, move higher, this code isn't executed. */
			if (srb.cmd[0] == SCSI_INQUIRY)
			{
				for (i = 8; i < ((srb.datalen < 44) ? srb.datalen : 44); i++)
				{
					if (srb.pdata[i] == 0)
					{
						srb.pdata[i] = ' ';
					}
				}
			}
#endif
		}
		return SELECTERROR;
	}
	else
	{
		if (oldscsi.version)
		{
			return oldscsi.In (parms);
		}
	}

	return SELECTERROR;
}

static long
SCSIDRV_Out (SCSICMD *parms)
{
	SCSIDRV_Data *priv = NULL;
	long i;

	debug ("OUT\r\n");

	for (i = 0; i < USB_MAX_STOR_DEV; i++) {
		if (&private[i] == (SCSIDRV_Data *) parms->handle) {
			priv = (SCSIDRV_Data *) parms->handle;
			break;
		}
	}


	if (priv)
	{
		if (mass_storage_dev[i].target != 0xff)
		{
			struct us_data *ss = &mass_storage_dev[i].usb_stor;
			long retries = 0;
			ccb srb;
			long r;

			if (parms->cmdlen > 16) {
				return STATUSERROR;
			}

			/* Filter commands for non existent LUNs */
			if (((parms->cmd[1] & 0xE0) >> 5 ) > mass_storage_dev[i].total_lun) {
				parms->sense[0] = 0x70;
				parms->sense[2] = SENSE_ILLEGAL_REQUEST;
				parms->sense[7] = 0x0A;
				parms->sense[12] = 0x25;
				parms->sense[13] = 0x00;
				if (parms->cmd[0] == SCSI_REQ_SENSE) {
					char *buffer = (char *) parms->buf;
					for (i = 0; i < parms->transferlen; i++)
					{
						buffer[i] = parms->sense[i];
					}
					parms->sense[2] = parms->sense[12] = 0x00;
					return NOSCSIERROR;
				} else {
					return S_CHECK_COND;
				}
			}

			memset (&srb, 0, sizeof (srb));
			for (i = 0; i < parms->cmdlen; i++)
			{
				srb.cmd[i] = parms->cmd[i];
			}

			srb.cmdlen = parms->cmdlen;
			srb.datalen = parms->transferlen;
			srb.pdata = parms->buf;
			srb.lun = (parms->cmd[1] & 0xE0) >> 5;
			srb.direction = USB_CMD_DIRECTION_OUT;
			srb.timeout = parms->timeout * 10;

			/* promote write6 to write10 */
			if (srb.cmd[0] == SCSI_WRITE6)
			{
				long block;
				srb.cmd[0] = SCSI_WRITE10;
				block = (long) (srb.cmd[1] & 0x1f) << 16 |
					(long) srb.cmd[2] << 8 | (long) srb.cmd[3];

                		/* do 4 & 5 here as we overwrite them later */
				srb.cmd[8] = srb.cmd[4];
				srb.cmd[9] = srb.cmd[5];
				srb.cmd[2] = (block >> 24) & 0xff;
				srb.cmd[3] = (block >> 16) & 0xff;
				srb.cmd[4] = (block >> 8) & 0xff;
				srb.cmd[5] = block & 0xff;
				srb.cmd[6] = 0;
				srb.cmd[7] = 0;
				srb.cmdlen = 10;
			}

retry:
			r = ss->transport (&srb, ss);
			
			if (r == USB_STOR_TRANSPORT_SENSE) {
				usb_request_sense(&srb, ss);
				memcpy(parms->sense, srb.sense_buf, 18);
				return S_CHECK_COND;
			}

			if (r != USB_STOR_TRANSPORT_GOOD && retries--) {
				goto retry;
			}
			
			switch(r)
			{
				case USB_STOR_TRANSPORT_GOOD :
					return NOSCSIERROR;
				case USB_STOR_TRANSPORT_DATA_FAILED :
					return TRANSERROR;
				case USB_STOR_TRANSPORT_PHASE_ERROR :
					return PHASEERROR;
				case USB_STOR_TRANSPORT_TIMEOUT :
					return TIMEOUTERROR;
				default:
					return STATUSERROR;
			}
		}
		else
		{
			return SELECTERROR;
		}
	}
	else
	{
		if (oldscsi.version)
		{
			return oldscsi.Out (parms);
		}
	}
	return SELECTERROR;
}

static long
SCSIDRV_InquireSCSI (short what, BUSINFO * info)
{
	long ret;

	debug ("INQSCSI\r\n");

	if (what == cInqFirst) {
		info->busids = 0;
	}

	/* 
	 * We let Uwe go first because it looks nicer in HDDRUTIL to show
	 * 0, 1, 2, and then 3 :-)
	 */
	if (oldscsi.version)
	{
		ret = oldscsi.InquireSCSI (what, info);
		if (ret == 0)
			return 0;
	}

	/*
	 * We shouldn't fail here as we scanned the busses when we installed
	 * so our USBbus number should be valid.
	 */
	if (!(info->busids & (1<<USBbus)))
	{
		strncpy (info->busname, USBNAME, sizeof(info->busname));
		info->busids |= 1<<USBbus;
		info->busno = USBbus;
		info->features = cArbit | cAllCmds | cTargCtrl | cTarget | cCanDisconnect;
		info->maxlen = 64L * 1024L;
		return 0;
	}

	return -1;
}


static long
SCSIDRV_InquireBus (short what, short busno, DEVINFO * dev)
{
	static long inqbusnext;
	long ret;

	debug ("INQBUS\r\n");

	if (what == cInqFirst)
	{
		inqbusnext = 0;
	}

	if (oldscsi.version)
	{
		ret = oldscsi.InquireBus (what, busno, dev);
		if (ret == 0)
			return 0;
	}

	if (busno == USBbus)
	{
		memset (dev->priv, 0, 32);
		if (inqbusnext >= USB_MAX_STOR_DEV)
		{
			return -1;
		}

again:
		if (mass_storage_dev[inqbusnext].target == 0xff)
		{
			inqbusnext++;
			if (inqbusnext >= USB_MAX_STOR_DEV)
			{
				return -1;
			}
			goto again;
		}

		dev->SCSIId.hi = 0;
		dev->SCSIId.lo = inqbusnext;
		inqbusnext++;
		return 0;
	}

	return -1;
}

static long
SCSIDRV_CheckDev (short busno,
					  const DLONG * DevNo, char *Name, ushort * Features)
{
	debug ("CHECKDEV\r\n");

	if (busno == USBbus)
	{
		memset (Name, 0, 20);
		strcat (Name, USBNAME);
		*Features = 0;
		if (DevNo->hi != 0L)
		{
			return ENODEV;
		}
		if (DevNo->lo >= USB_MAX_STOR_DEV)
		{
			return ENODEV;
		}
		if (mass_storage_dev[DevNo->lo].target != 0xff)
		{
			*Features = cArbit | cAllCmds | cTargCtrl | cTarget | cCanDisconnect;
			return 0;
		} 
		return ENODEV;
	}
	else
	{
		if (oldscsi.version)
		{
			return oldscsi.CheckDev (busno, DevNo, Name, Features);
		}
	}
	return ENODEV;
}

static long
SCSIDRV_RescanBus (short busno)
{
	debug ("RESCAN\r\n");
	if (busno == USBbus)
	{
		return 0;
	}
	else
	{
		if (oldscsi.version)
		{
			return oldscsi.RescanBus (busno);
		}
	}
	return -1;
}

static long
SCSIDRV_Open (short bus, const DLONG * Id, ulong * MaxLen)
{
	debug ("OPEN\r\n");
	if (bus == USBbus)
	{
		if (Id->hi != 0)
			return -1;

		if (Id->lo >= USB_MAX_STOR_DEV)
			return -1;

		if (mass_storage_dev[Id->lo].target != 0xff)
		{
			struct us_data *ss = &mass_storage_dev[Id->lo].usb_stor;

			/* We only allow SCSI compliant USB devices and CD/DVD class */
			if ((ss->subclass != US_SC_SCSI) && (ss->subclass != US_SC_8020)) {
				return -1;
			}
		} else {
			return -1;
		}
		*MaxLen = 64 * 1024L;
		return (long) &private[Id->lo];
	}
	else
	{
		if (oldscsi.version)
		{
			return oldscsi.Open (bus, Id, MaxLen);
		}
	}
	return -1;
}

static long
SCSIDRV_Close (short *handle)
{
	long i;

	debug ("CLOSE\r\n");

	for (i = 0; i < USB_MAX_STOR_DEV; i++) {
		if (&private[i] == (SCSIDRV_Data *) handle) {
			return 0;
		}
	}

	if (oldscsi.version) {
		return oldscsi.Close (handle);
	}

	return -1;
}

static long
SCSIDRV_Error (short *handle, short rwflag, short ErrNo)
{
	long i;

	debug ("ERROR\r\n");

	for (i = 0; i < USB_MAX_STOR_DEV; i++) {
		if (&private[i] == (SCSIDRV_Data *) handle) {
			return 0;
		}
	}

	if (oldscsi.version)
	{
		return oldscsi.Error (handle, rwflag, ErrNo);
	}

	return -1;
}

void install_scsidrv (void);
void
install_scsidrv (void)
{
	short i;

	scsidrv.version = SCSIRevision;
	scsidrv.In = SCSIDRV_In;
	scsidrv.Out = SCSIDRV_Out;
	scsidrv.InquireSCSI = SCSIDRV_InquireSCSI;
	scsidrv.InquireBus = SCSIDRV_InquireBus;
	scsidrv.CheckDev = SCSIDRV_CheckDev;
	scsidrv.RescanBus = SCSIDRV_RescanBus;
	scsidrv.Open = SCSIDRV_Open;
	scsidrv.Close = SCSIDRV_Close;
	scsidrv.Error = SCSIDRV_Error;

	/* optional - SCSIDRV2 */
	scsidrv.Install = SCSIDRV_Install;
	scsidrv.Deinstall = SCSIDRV_Deinstall;
	scsidrv.GetCmd = SCSIDRV_GetCmd;
	scsidrv.SendData = SCSIDRV_SendData;
	scsidrv.GetData = SCSIDRV_GetData;
	scsidrv.SendStatus = SCSIDRV_SendStatus;
	scsidrv.SendMsg = SCSIDRV_SendMsg;
	scsidrv.GetMsg = SCSIDRV_GetMsg;
	scsidrv.ReqData = &reqdata;
	
	/* Allocate globally accessible memory for SCSIDRV handles.
	 * As per SCSIDRV spec the caller is allowed to read the memory pointed to by the handle.
	 */
#ifndef TOSONLY
	private = (SCSIDRV_Data*)m_xalloc(USB_MAX_STOR_DEV * sizeof(SCSIDRV_Data), 0x20|0);
#else
	private = (SCSIDRV_Data*)Malloc(USB_MAX_STOR_DEV * sizeof(SCSIDRV_Data));
#endif
	if (private == NULL)
		return;

	for (i = 0; i < USB_MAX_STOR_DEV; i++)
	{
		private[i].features = cArbit | cAllCmds | cTargCtrl | cTarget | cCanDisconnect;
		private[i].changed = FALSE;
	}

#ifdef TOSONLY
	SCSIDRV *tmp = NULL;
	if (getcookie (COOKIE_SCSI, (long *)&tmp))
	{
		BUSINFO info[32];
		short j;
		long ret;

		/*
		 * Find a busno. We start at 3, and work up to a max of 32.
		 */
		i = 0;
		ret = tmp->InquireSCSI(cInqFirst, &info[i++]);

		while (ret == 0 && i < 32)
		{
			ret = tmp->InquireSCSI(cInqNext, &info[i++]);
		}

again:
		for (j = 0; j < i; j++) {
			if (info[j].busno == USBbus) {
				USBbus++;
				goto again;
			}
		}

		/* don't install, we couldn't find a bus */
		if (USBbus >= 32) 
			return;

		/* Take a copy of the old pointers, and replace with ours.
		 * This way we don't delete and replace the existing cookie.
		 */
		memcpy(&oldscsi, (char*)tmp, sizeof(oldscsi));
		tmp->In = SCSIDRV_In;
		tmp->Out = SCSIDRV_Out;
		tmp->InquireSCSI = SCSIDRV_InquireSCSI;
		tmp->InquireBus = SCSIDRV_InquireBus;
		tmp->CheckDev = SCSIDRV_CheckDev;
		tmp->RescanBus = SCSIDRV_RescanBus;
		tmp->Open = SCSIDRV_Open;
		tmp->Close = SCSIDRV_Close;
		tmp->Error = SCSIDRV_Error;
	} else {
		SCSIDRV_COOKIE.ident = COOKIE_SCSI;
		SCSIDRV_COOKIE.v.l = (long) &scsidrv;
		add_cookie (&SCSIDRV_COOKIE);
	}
#else
	BUSINFO info[32];
	short j;
	long ret;
	SCSIDRV *tmpscsi;

	/*
	 * Find a busno. We start at 3, and work up to a max of 32.
	 */
	i = 0;
	ret =scsidrv_InquireSCSI(cInqFirst, &info[i++]);

	while (ret == 0 && i < 32)
	{
		ret = scsidrv_InquireSCSI(cInqNext, &info[i++]);
	}

again:
	for (j = 0; j < i; j++) {
		if (info[j].busno == USBbus) {
			USBbus++;
			goto again;
		}
	}

	/* don't install, we couldn't find a bus */
	if (USBbus >= 32) 
		return;

	tmpscsi = (SCSIDRV *)scsidrv_InstallNewDriver(&scsidrv);
	if (tmpscsi)
		memcpy(&oldscsi, tmpscsi, sizeof(oldscsi));
#endif /* TOSONLY */
}

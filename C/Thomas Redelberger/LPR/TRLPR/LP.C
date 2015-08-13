/************************************************************************/
/* This is a device driver for MagiC.									*/
/* It provides U:\DEV\LP . Copying a file to it triggers a lp-protocol	*/
/* printing via STinG													*/
/*																		*/
/* Copyright: Dr. Thomas Redelberger, 1999								*/
/* Tab 4																*/
/************************************************************************/
/*
$Id: lp.c 1.2 1999/12/30 12:55:34 Thomas Exp Thomas $
 */

#define	NULL ((void*) 0L)
#include <string.h>
#include <tos.h>
#define Dcntl(a,b,c)	gemdos(0x130, (short) a, (char*) b, (long) c)

#define	E_OK	0			/* TOS error numbers */
#define EREADF	-11
#define	EINVFN	-32
#define	EACCDN	-36

#include <portab.h>
#include "magx.h"
#include "mgx_xfs.h"
#include "mgx_dfs.h"

#include "transprt.h"		/* access to STinG */
#include "lpraux.h"			/* my lpr functions */
#include "lprui.h"			/* user interface */

#define TIMEOUT	10			/* TCP timeout seconds */

/* other function declarations */

extern int link2Sting(void);			/* LNK2STNG.C */



int errno;					/* needed by stdlib */

typedef struct magx_unsel {
	union {
		void (*unsel) (struct magx_unsel *un);
		long status;
	} v;
	long param;
} MAGX_UNSEL;

/* forward declarations */
long lp_dev_open   (MX_DOSFD *f);
long lp_dev_close  (MX_DOSFD *f);
long lp_dev_read   (MX_DOSFD *f, void *buf,  long len);
long lp_dev_write  (MX_DOSFD *f, void *buf,  long len);
long lp_dev_stat   (MX_DOSFD *f, int  rwflag, MAGX_UNSEL *unsel, void *appl);
long lp_dev_lseek  (MX_DOSFD *f, long where, int mode);
long lp_dev_ioctl  (MX_DOSFD *f, int  cmd, void *buf);
long lp_dev_delete (MX_DOSFD *parent, MX_DOSDIR *dir);


MX_DDEV drvr =
{
	lp_dev_open,
	lp_dev_close,
	lp_dev_read,
	lp_dev_write,
	lp_dev_stat,
	lp_dev_lseek,
	NULL,		/* datime is handled by XFS_DOS */
	lp_dev_ioctl,
	lp_dev_delete,
	NULL,		/* no getc */
	NULL,		/* no getline */
	NULL		/* no putc */
};



/******************************************************************
*
* Device specific variables
*
******************************************************************/

MX_KERNEL*	kernel;				/* access to MagiC kernel */

/* due to this variables the code is not reentrant */
void* 		devOwner;			/* MagiC device owner */
JOBDEF* 	pjd;				/* my job definition object */
char* 		spoolFileFullName;	/* my spool file fully qualified name */ 
int 		spoolFileHndl;		/* my spool file handle */
BASPAG*		_BasPag;			/* used to delete driver; also used by C lib? */
char		devName[]= {'u',':','\\','d','e','v','\\'};		/* concatenates with qName! */
char		qName[] = "lp";		/* THE queue name (until I know to get the device name) */
char		dummy[] = "@@@@@";	/* marker, allows to patch device name (8 chars max) */

/******************************************************************
*
* Note that this program does NOT use the standard startup code
* The function  main  below MUST be the first one in the text segment
*
******************************************************************/


static void cdecl main (BASPAG *bp)
{
	/* calculate size of TPA */
	long PgmSize = (long) bp->p_bbase + bp->p_blen - (long) bp;
	_BasPag = bp;

	if ( Dcntl(DEV_M_INSTALL, devName, (long) &drvr) < 0L )
		goto errExit;

	kernel = (MX_KERNEL*) Dcntl(KER_GETINFO, NULL, 0L);

#if 0
	Ptermres(-1L, 0);        /* allen Speicher behalten */
#else
	Ptermres (PgmSize, 0);	/* I understand this, above I do not */
#endif


errExit:
	Pterm(-1);
}


/* do not moarn unused parameters */
#pragma warn -par


/******************************************************************
*
* Open device
* The process requesting gets saved. This is used to lock the 
* device from use by other concurrent processes
* Note:
* As we need spool file name and handle across device calls open,
* write, close we allocate them on the STinG heap instead of using
* static variables. Thus you save memory when the device driver is 
* idle.
******************************************************************/

#define MAXPATH	256

long lp_dev_open   (MX_DOSFD *f)
{
/*	uiPrintf( uiH, uiPrINF, "dev_open");*/
	if (devOwner) return(EACCDN);				/* already open */

	devOwner = kernel->act_pd;

	if (tpl == NULL) {				/* do it only first time */
		uiH = uiOpen("LP");			/* access to console for error printing */
		if (link2Sting() != 0) {	/* access sting (sets tpl) */
			uiPrintf( uiH, uiPrERR, "cannot link to STinG");
			return(EACCDN);			/* sorry */
		}
	}


	/* allocate JOBDEF for this job */
	if ( (pjd = KRmalloc(sizeof(JOBDEF))) == NULL )
		return(EACCDN);		/* serious trouble */

	if ( (spoolFileFullName = KRmalloc(MAXPATH)) == NULL ) {
		KRfree(pjd);
		return(EACCDN);		/* serious trouble */
	}

	lprInit(pjd);				/* read from default.cfg */

	/* look for queue whose name equals the device name */
#if 0
uiPrintf(uiH, uiPrOK, ">%s<", f->fd_name);	/* this is empty */
	lprLookupQueue(pjd, f->fd_name);
#else
	lprLookupQueue(pjd, qName);		/* defaults to lp */
#endif

	/* construct spoolfile name and create it */
	strcpy(spoolFileFullName, pjd->spoolDir);
	/* make shure directory ends with a slash */
	if (spoolFileFullName[strlen(spoolFileFullName)-1] != '\\')
		strcat(spoolFileFullName, "\\");

	strcat(spoolFileFullName, pjd->spoolFile);

	if ( (spoolFileHndl = Fcreate(spoolFileFullName, 0)) < 0 ) {
		KRfree(spoolFileFullName);	/* release tmp memory */
		KRfree(pjd);				/* " */
		return(EACCDN);				/* unlucky */
	}

	return(E_OK);
}


/******************************************************************
* The device gets closed.
* The accumulated spoolfile get printed by lp-protocol (RFC 1179),
* then the device becomes available again
******************************************************************/

long lp_dev_close  (MX_DOSFD *f)
{
	int16 cnId;

/*	uiPrintf( uiH, uiPrINF, "dev_close");*/
	if (f->fd_refcnt > 1) return E_OK;	/* wait till final close (io redir!) */

	Fclose(spoolFileHndl);		/* close the spool file */

	/* open a TCP connection & print */
	if( (cnId = lprConnect(pjd->rmHost)) > 0 ) {
		lprPrintfile(
			pjd,
			"unknown",
			spoolFileFullName,
			cnId, (void (*)(long, long, long)) 0L); 
		TCP_close(cnId, TIMEOUT, NULL);	/* = disconnect */
	}

	Fdelete(spoolFileFullName);	/* do not need spool file any more */
	KRfree(spoolFileFullName);	/* release tmp memory */
	KRfree(pjd);				/* " */

	devOwner = NULL;		/* release this device */
	return E_OK;
}


/******************************************************************
*
* Read
*
******************************************************************/

long lp_dev_read   (MX_DOSFD *f, void *buf,  long len  )
{
	return(EINVFN);
}


/******************************************************************
*
* Write just does a straight copy to the spool file
*
******************************************************************/

long lp_dev_write  (MX_DOSFD *f, void *buf,  long len  )
{
	return Fwrite(spoolFileHndl, len, buf);
}


/******************************************************************
*
* Status
*
******************************************************************/

long lp_dev_stat   (MX_DOSFD *f, int  rwflag, MAGX_UNSEL *unsel, void *appl)
{
	long rc = 1;
/*	uiPrintf( uiH, uiPrINF, "dev_stat");*/

/*	if (!rwflag) rc = EREADF;*/

	if (unsel) unsel->v.status = rc;
	return rc;
}


/******************************************************************
*
* Seek is useless but we do not return an error to keep shells
* like mupfel happy that do a seek in e.g.
*	echo anything >u:\dev\lp
*
******************************************************************/

long lp_dev_lseek  (MX_DOSFD *f, long where, int mode  )
{
	return E_OK;
}


#if 0

/******************************************************************
*
* Date is handled by DOS
*
******************************************************************/

long lp_dev_datime (MX_DOSFD *f, int  *buf,  int rwflag)
{
}

#endif

/******************************************************************
*
* Device control is basic
*
******************************************************************/

long lp_dev_ioctl  (MX_DOSFD *f, int  cmd, void *buf )
{
/*	uiPrintf( uiH, uiPrINF, "dev_ioctl");*/

	if        (cmd == FIONREAD) {
		*(long *)buf = 1L;
	} else if (cmd == FIONWRITE) {
		*(long *)buf = 1L;
	} else if (cmd == FTRUNCATE) {
		*(long *)buf = 1L;
	} else {
		return EINVFN;
	}

	return E_OK;
}


/******************************************************************
*
* Device gets deleted and device driver code released
*
******************************************************************/

long lp_dev_delete ( MX_DOSFD *parent, MX_DOSDIR *dir )
{
	kernel->Pfree(_BasPag);
	return(E_OK);
}

#pragma warn +par

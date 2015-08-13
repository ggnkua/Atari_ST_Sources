head	1.2;
access;
symbols
	TRLPR11B:1.2
	TRLPR10B:1.1;
locks
	Thomas:1.2; strict;
comment	@ * @;


1.2
date	99.12.30.12.55.34;	author Thomas;	state Exp;
branches;
next	1.1;

1.1
date	99.11.13.17.05.52;	author Thomas;	state Exp;
branches;
next	;


desc
@MagiC device driver with lpr functionality
@


1.2
log
@Version to use DEFAULT.CFG instead of printcap
@
text
@/************************************************************************/
/* This is a device driver for MagiC.									*/
/* It provides U:\DEV\LP . Copying a file to it triggers a lp-protocol	*/
/* printing via STinG													*/
/*																		*/
/* Copyright: Dr. Thomas Redelberger, 1999								*/
/* Tab 4																*/
/************************************************************************/
/*
$Id: lp.c 1.1 1999/11/13 17:05:52 Thomas Exp Thomas $
 */

#define	NULL ((void*) 0L)
#include <string.h>
#include <tos.h>
#define Dcntl(a,b,c)	gemdos(0x130, (short) a, (char*) b, (long) c)
#define	E_OK	0			/* TOS error numbers */
#define	EACCDN	-36

#define	GEM	GEM2
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


/* forward declarations */
long lp_dev_open   (MX_DOSFD *f);
long lp_dev_close  (MX_DOSFD *f);
long lp_dev_read   (MX_DOSFD *f, void *buf,  long len);
long lp_dev_write  (MX_DOSFD *f, void *buf,  long len);
long lp_dev_stat   (MX_DOSFD *f, int  rwflag, void *unsel, void *appl);
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
char		dummy[] = {'@@', '@@'};	/* marker */
char		qName[] = "lp";		/* THE queue name (until I know to get the device name) */

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

	if ( Dcntl(DEV_M_INSTALL, "u:\\dev\\lp", (long) &drvr) < 0L )
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
	if (devOwner)
		return(EACCDN);				/* already open */
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
	return(E_OK);
}


/******************************************************************
*
* Read
*
******************************************************************/

long lp_dev_read   (MX_DOSFD *f, void *buf,  long len  )
{
	return(EACCDN);
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

long lp_dev_stat   (MX_DOSFD *f, int  rwflag, void *unsel, void *appl)
{
	return 1;
}


/******************************************************************
*
* Seek is invalid
*
******************************************************************/

long lp_dev_lseek  (MX_DOSFD *f, long where, int mode  )
{
	return(EACCDN);
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
* Device control is invalid
*
******************************************************************/

long lp_dev_ioctl  (MX_DOSFD *f, int  cmd, void *buf )
{
	return(EACCDN);
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
@


1.1
log
@Initial revision
@
text
@d4 1
a4 1
/* printing via Sting													*/
d10 1
a10 1
$Id$
d17 2
d26 4
a29 2
#define	E_OK	0			/* TOS error numbers */
#define	EACCDN	-36
d32 4
a35 2
#include "transprt.h"		/* access to Sting */
#include "lpraux.h"			/* my lpr functions */		
d42 8
a49 8
long lpt_dev_open   (MX_DOSFD *f);
long lpt_dev_close  (MX_DOSFD *f);
long lpt_dev_read   (MX_DOSFD *f, void *buf,  long len);
long lpt_dev_write  (MX_DOSFD *f, void *buf,  long len);
long lpt_dev_stat   (MX_DOSFD *f, int  rwflag, void *unsel, void *appl);
long lpt_dev_lseek  (MX_DOSFD *f, long where, int mode);
long lpt_dev_ioctl  (MX_DOSFD *f, int  cmd, void *buf);
long lpt_dev_delete (MX_DOSFD *parent, MX_DOSDIR *dir);
d54 12
a65 12
	lpt_dev_open,
	lpt_dev_close,
	lpt_dev_read,
	lpt_dev_write,
	lpt_dev_stat,
	lpt_dev_lseek,
	NULL,		/* datime erledigt XFS_DOS */
	lpt_dev_ioctl,
	lpt_dev_delete,
	NULL,		/* kein getc */
	NULL,		/* kein getline */
	NULL		/* kein putc */
d72 1
a72 1
* ger„tespezifische Variablen
d76 1
a76 4
void *lpt_dev_owner = NULL;
int hTmpFil;
static char  spoolFileFullName[50];
static char *spoolFileName;
d78 8
a85 1
MX_KERNEL *kernel;
d87 6
a93 4
/* Note that this program does NOT use the standard startup code
 * The function  main  below must be the first one in the text segment
 */
BASPAG *_BasPag;
a96 1
	long errcode;
d101 1
a101 2
	errcode = Dcntl(DEV_M_INSTALL, "u:\\dev\\lp", (long) &drvr);
	if (errcode < 0L)
d104 2
a105 1
	kernel = (MX_KERNEL *) Dcntl(KER_GETINFO, NULL, 0L);
d109 1
a109 1
	Ptermres (PgmSize, 0);
a117 33

long get_sting_cookie (void)
{
	long  *p;

	for (p = * (long **) 0x5a0L; *p ; p += 2)
	if (*p == 'STiK')
		return *++p;

	return 0L;
}


TPL *tpl = NULL;

int initSting(void)
{
	DRV_LIST *sting_drivers;

	if ( (sting_drivers = (DRV_LIST*) Supexec(get_sting_cookie)) == NULL )
		return -1;

	if (strcmp (sting_drivers->magic, MAGIC) != 0)
		return -1;

	if ( (tpl = (TPL*) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER)) == NULL)
		return -1;

	return 0;	/* OK */
}



d124 8
a131 4
* Ger„t ”ffnen:
*  Ich merke mir den aktuellen Prozež, damit das Ger„t nicht
*  mehrmals ge”ffnet wird.
*
d134 3
a136 1
long lpt_dev_open   (MX_DOSFD *f)
d138 12
a149 3
	if (lpt_dev_owner)
		return(EACCDN);		/* schon ge”ffnet */
	lpt_dev_owner = kernel->act_pd;
d151 7
a157 3
	if (tpl == NULL) {	/* we need to initialize Sting and Lpr already here */
		initSting();	/* otherwise spoolFileName is crap */
		initLpr();
d160 1
a160 3
	getSpoolFilePath(spoolFileFullName);
	spoolFileName  = spoolFileFullName+strlen(spoolFileFullName);
	getSpoolFileName(spoolFileName);
d162 7
a168 1
	spoolFileName[8] = '\0';	/* sorry, no more than eight chars */
d170 13
a182 2
	if ( (hTmpFil = Fcreate(spoolFileFullName, 0)) < 0)
		return(EACCDN);		/* unlucky */
d189 3
a191 4
*
* Ger„t schliežen:
*  Ich gebe das Ger„t frei.
*
d194 1
a194 1
long lpt_dev_close  (MX_DOSFD *f)
d198 1
a198 2
	lpt_dev_owner = NULL;
	Fclose(hTmpFil);
d200 4
a203 2
	if( (cnId = connect(rmHost)) > 0 ) {
		printfile(
d206 2
a207 2
			spoolFileName, cnId, (void (*)(long, long, long)) 0L); 
		TCP_close(cnId, TIMEOUT);	/* = disconnect */
d210 5
d221 1
a221 1
* lesen:
d225 1
a225 1
long lpt_dev_read   (MX_DOSFD *f, void *buf,  long len  )
d233 1
a233 1
* schreiben:
d237 1
a237 1
long lpt_dev_write  (MX_DOSFD *f, void *buf,  long len  )
d239 1
a239 1
	return Fwrite(hTmpFil, len, buf);
d245 1
a245 1
* Status:
d249 1
a249 1
long lpt_dev_stat   (MX_DOSFD *f, int  rwflag, void *unsel, void *appl)
d257 1
a257 1
* Dateizeiger positionieren
d261 1
a261 1
long lpt_dev_lseek  (MX_DOSFD *f, long where, int mode  )
d267 2
d271 1
a271 1
* Uhrzeit/Datum der ge”ffneten Datei
d275 1
a275 5
/*

erledigt das DOS

long lpt_dev_datime (MX_DOSFD *f, int  *buf,  int rwflag)
d279 1
a279 1
*/
d283 1
a283 1
* Ger„tespezifische Befehle
d287 1
a287 1
long lpt_dev_ioctl  (MX_DOSFD *f, int  cmd, void *buf )
d295 1
a295 2
* Ger„t wird gel”scht:
*  Ger„tetreiber aufwecken und damit beenden.
d299 1
a299 1
long lpt_dev_delete ( MX_DOSFD *parent, MX_DOSDIR *dir )
a305 2


@

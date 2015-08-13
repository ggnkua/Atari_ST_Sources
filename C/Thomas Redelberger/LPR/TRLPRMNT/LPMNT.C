/************************************************************************/
/* This is a device driver for MINT.									*/
/* It provides U:\DEV\LP . Copying a file to it triggers a lp-protocol	*/
/* printing via STinG													*/
/*																		*/
/* Copyright: Dr. Thomas Redelberger, 2000								*/
/* Tab 4																*/
/************************************************************************/
/*
$Id$
 */

#define	NULL ((void*) 0L)
#include <string.h>
/* #include <tos.h> cannot use this in an XDD */
#include "mymntlib.h"
#define	E_OK	0			/* TOS error numbers */
#define EINVFN	-32			/* invalid function */
#define EACCDN	-36			/* access denied */


#include "..\trlpr\transprt.h"		/* access to STinG */

#include "..\trlpr\lpraux.h"		/* my lpr functions */
#include "..\trlpr\lprui.h"			/* my lpr user interface */

#include "filesys.h"



#define TIMEOUT	10			/* TCP timeout seconds */

/* other function declarations */

extern int link2Sting(void);			/* LNK2STNG.C */



/* keep the TCTOSLIB happy */
int		errno;
BASPAG*	_BasPag;


/* 
 * Debugging stuff; it can be removed if you want to spare a few bytes
 */

#define DEBUG(x)	(*kernel->debug)x
#define ALERT(x)	(*kernel->alert)x
#define TRACE(x)	(*kernel->trace)x
#define FATAL(x)	(*kernel->fatal)x


/*
 * Global variables
 */
/* MINT */ 
long selector;
struct kerinfo *kernel;


/* my stuff */
/* due to these variables the code is not reentrant */
JOBDEF* 	pjd;				/* my job definition object */
char* 		spoolFileFullName;	/* my spool file fully qualified name */ 
int 		spoolFileHndl;		/* my spool file handle */
/*BASPAG*		_BasPag;*/			/* used to delete driver; also used by C lib? */
char		devName[]= {'u',':','\\','d','e','v','\\'};
char		qName[] = "lp";		/* THE queue name (until I know to get the device name) */
char		dummy[] = "@@@@@";	/* marker, allows to patch device name (8 chars max) */


/*
 * Forward declarations of the device driver functions
 */

long	cdecl lp_open		(FILEPTR *f);
long	cdecl lp_write		(FILEPTR *f, char *buf, long bytes);
long	cdecl lp_read		(FILEPTR *f, char *buf, long bytes);
long	cdecl lp_lseek		(FILEPTR *f, long where, int whence);
long	cdecl lp_ioctl		(FILEPTR *f, int mode, void *buf);
long	cdecl lp_datime		(FILEPTR *f, int *timeptr, int rwflag);
long	cdecl lp_close		(FILEPTR *f, int pid);
long	cdecl lp_select		(FILEPTR *f, long proc, int mode);
void	cdecl lp_unselect	(FILEPTR *f, long proc, int mode);

DEVDRV lp_device = {
	lp_open, lp_write, lp_read, lp_lseek, lp_ioctl,
	lp_datime, lp_close, lp_select, lp_unselect
};

struct dev_descr devinfo = { &lp_device };




/******************************************************************
*
* Note that this program does NOT use the standard startup code
* The function below MUST be the first one in the text segment
*
******************************************************************/

/* uk: if this is linked and started as an externel device driver,
 *     the memory allocation stuff is already done and we are in
 *     super mode already.
 */
static DEVDRV* cdecl xdd_main(struct kerinfo *k)
{
	kernel = k;
	kernel = (struct kerinfo *)Dcntl(DEV_INSTALL, (long) devName, (long) &devinfo);
	if ((long)kernel <= 0L) {
		Cconws("lp: unable to install device\r\n\r\n");
		return NULL;
	} else {
		return (DEVDRV*)1;
	}
}




/*
 * Here are the actual device driver functions
 */

#pragma warn -par

/***************************************************************** 
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

long cdecl tlp_open (long dummy1, long dummy2, FILEPTR *f)
{
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

long cdecl tlp_close (long dummy1, long dummy2, FILEPTR *f, int pid)
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

	return(E_OK);
}



/******************************************************************
*
* Read
*
******************************************************************/

long cdecl tlp_read (long dummy1, long dummy2, FILEPTR *f, char *buf, long bytes)
{
	return(EACCDN);
}


/******************************************************************
*
* Date
*
******************************************************************/

long cdecl tlp_datime (long dummy1, long dummy2, FILEPTR *f, int *timeptr, int rwflag)
{
	if (rwflag) {
		return EACCDN;
	}
	*timeptr++ = Tgettime();
	*timeptr   = Tgetdate();
	return 0;
}



/******************************************************************
*
* Seek is invalid
*
******************************************************************/

long cdecl tlp_lseek (long dummy1, long dummy2, FILEPTR *f, long where, int whence)
{
	return(EACCDN);
}


/******************************************************************
*
* Device control is invalid
*
******************************************************************/

long cdecl tlp_ioctl (long dummy1, long dummy2, FILEPTR *f, int mode, void *buf)
{
	if        (mode == FIONREAD) {
		TRACE(("lp: ioctl(FIONREAD)"));
		*(long *)buf = 0L;
	} else if (mode == FIONWRITE) {
		TRACE(("lp: ioctl(FIONWRITE)"));
		*(long *)buf = 1L;
	} else
		return EINVFN;

	return E_OK;
}

/******************************************************************
*
* Write just does a straight copy to the spool file
*
******************************************************************/

long cdecl tlp_write (long dummy1, long dummy2, FILEPTR *f, char *buf, long bytes)
{
	return Fwrite(spoolFileHndl, bytes, buf);
}


/* Bug: only one process can select the printer */

long cdecl tlp_select (long dummy1, long dummy2, FILEPTR *f, long proc, int mode)
{
	if (!selector) {
		selector = proc;
		return 0;
	} else {
		return 1;
	}
}


void cdecl tlp_unselect (long dummy1, long dummy2, FILEPTR *f, long proc, int mode)
{
	selector = 0L;
}

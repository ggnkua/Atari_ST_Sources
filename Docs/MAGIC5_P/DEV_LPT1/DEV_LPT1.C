/********************************************************************
*
* MagiC Device Driver Development Kit
* ===================================
*
* Beispieltreiber fÅr Drucker-Hintergrundbetrieb
*
*
* Dieses Programm realisiert einen interruptgesteuerten
* GerÑtetreiber.
* Einige der GerÑtefunktionen sind in Assembler ausgefÅhrt,
* was einen schnellen und kompakten Code ermîglicht.
*
*
* (C) Andreas Kromke, 1994
*
********************************************************************/


#include <string.h>
#include <tos.h>
#include <tosdefs.h>
#include "magx.h"
#include "mgx_xfs.h"
#include "mgx_dfs.h"

extern void handle_busy( void );

#define NULL ((void *) 0)

/******************************************************************
*
* gerÑtespezifische Variablen
*
******************************************************************/

void *lpt_dev_owner = NULL;
MX_KERNEL *kernel;
void **oldvec;



#pragma warn -par

/******************************************************************
*
* GerÑt îffnen:
*  Ich merke mir den aktuellen Prozeû, damit das GerÑt nicht
*  mehrmals geîffnet wird.
*
******************************************************************/

long lpt_dev_open   (MX_DOSFD *f)
{
     if   (lpt_dev_owner)
          return(EACCDN);          /* schon geîffnet */
     lpt_dev_owner = kernel->act_pd;
     return(E_OK);
}


/******************************************************************
*
* GerÑt schlieûen:
*  Ich gebe das GerÑt frei.
*
******************************************************************/

long lpt_dev_close  (MX_DOSFD *f)
{
     lpt_dev_owner = NULL;
     return(E_OK);
}


/******************************************************************
*
* lesen:
*
******************************************************************/

long lpt_dev_read   (MX_DOSFD *f, void *buf,  long len  )
{
     return(EACCDN);
}


/******************************************************************
*
* schreiben:
*  -> Assemblermodul
*
******************************************************************/

extern long lpt_dev_write  (MX_DOSFD *f, void *buf,  long len  );


/******************************************************************
*
* Status:
*  -> Assemblermodul
*
******************************************************************/

extern long lpt_dev_stat   (MX_DOSFD *f, int  rwflag, void *unsel, void *appl);


/******************************************************************
*
* Dateizeiger positionieren
*
******************************************************************/

long lpt_dev_lseek  (MX_DOSFD *f, long where, int mode  )
{
     return(EACCDN);
}


/******************************************************************
*
* Uhrzeit/Datum der geîffneten Datei
*
******************************************************************/

/*

erledigt das DOS

long lpt_dev_datime (MX_DOSFD *f, int  *buf,  int rwflag)
{
}

*/

/******************************************************************
*
* GerÑtespezifische Befehle
*
******************************************************************/

long lpt_dev_ioctl  (MX_DOSFD *f, int  cmd, void *buf )
{
     return(EACCDN);
}


/******************************************************************
*
* GerÑt wird gelîscht:
*  GerÑtetreiber aufwecken und damit beenden.
*
******************************************************************/

long lpt_dev_delete ( MX_DOSFD *parent, MX_DOSDIR *dir )
{
     Mfpint(0, (void (*)()) oldvec);
     kernel->Pfree(_BasPag);
     return(E_OK);
}

#pragma warn +par

MX_DDEV drvr =
     {
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
     NULL			/* kein putc */
     };

int main()
{
	long errcode;

	/* MFP- Interrupt #0 (Centronics busy) initialisieren */

	oldvec = (void **) Setexc(64, (void (*)()) -1L);
	Mfpint(0, handle_busy);
	errcode = Dcntl(DEV_M_INSTALL, "u:\\dev\\lpt1", (long) &drvr);
	if   (errcode < 0L)
		{
		Mfpint(0, (void (*)()) oldvec);
		return((int) kernel);
		}

	kernel = (MX_KERNEL *) Dcntl(KER_GETINFO, NULL, 0L);
	Ptermres(-1L, 0);        /* allen Speicher behalten */
	return(0);
}

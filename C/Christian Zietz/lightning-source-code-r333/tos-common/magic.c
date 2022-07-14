/* magic.c - MagiC detection functions for USB TOS drivers
 *
 * Copyright (C) 2019 David Galvez

 * This file is distributed under the GPL, version 2.
 * See /COPYING.GPL for details.
 */

#include  "../../global.h"

#define MagX_COOKIE    0x4D616758L

 /* Protoypes */
short InqMagX (void);

typedef struct _osheader
{
	unsigned short	os_entry;	/* BRAnch instruction to Reset-handler  */
	unsigned short	os_version;	/* TOS version number                   */
	void		*reseth;	/* Pointer to Reset-handler             */
	void		*os_beg;	/* Base address of the operating system */
	void		*os_end;	/* First byte not used by the OS        */
	long		os_rsvl;	/* Reserved                             */
	void		*os_magic;	/* GEM memory-usage parameter block     */
	long		os_date;	/* TOS date (English !) in BCD format   */
	unsigned short	os_conf;	/* Various configuration bits           */
	unsigned short	os_dosdate;	/* TOS date in GEMDOS format            */

	/* The following components are available only as of TOS Version 1.02 (Blitter-TOS) */
	char		**p_root;	/* Base address of the GEMDOS pool      */
	char		**pkbshift;	/* Pointer to BIOS Kbshift variable
					(for TOS 1.00 see Kbshift)              */
	void		**p_run;	/* Address of the variables containing
					   a pointer to the current GEMDOS
					   process.                             */
	char		*p_rsv2;	/* Reserved                             */
					/* If EmuTOS is present, then 'ETOS'    */
} OSHEADER;

typedef struct
{
	long magic;				/* Has to be 0x87654321 */
	void *membot;				/* End of the AES variables */
	void *aes_start;			/* Start address */
	long magic2;				/* Is 'MAGX' or 'KAOS' */
	long date;				/* Creation date */
	void (*chgres)(short res, short txt);	/* Change resolution */
	long (**shel_vector)(void);		/* Resident desktop */
	char *aes_bootdrv;			/* Booting will be from here */
	short *vdi_device;			/* Driver used by AES */
	void *reservd1;				/* Reserved */
	void *reservd2;				/* Reserved */
	void *reservd3;				/* Reserved */
	short version;				/* Version (0x0201 is V2.1) */
	short release;				/* 0=alpha..3=release */
} AESVARS;

typedef struct
{
	long config_status;
	void *dosvars;
	AESVARS *aesvars;
	void *res1;
	void *hddrv_functions;
	long   status_bits;
} MAGX_COOKIE;

/* Are we running on MagiC? */
int MagiC = -1;


/* Code taken from TOS.HYP
 * https://freemint.github.io/tos.hyp/en/magic_aesvars.html
 * https://freemint.github.io/tos.hyp/en/magic_test.html
 */

/* The following code obtains the pointer to the AESVARS structure of
 * MagiC in a reliable manner.
 *
 * The routine is particularly important as the relevant components
 * in the MagX cookie do not yet have a valid value at boot-up.
 */

static OSHEADER* get_osheader(void)
{
	long *osheader_sv = (long *)0x4f2;
	OSHEADER *osheaderp = (OSHEADER *)*osheader_sv;

	return osheaderp;
}

static AESVARS* DOMagixAESVars (void)
{
	short have_it = 0;
	AESVARS *ap = 0;

	if (!have_it)
	{
		OSHEADER *O;

		have_it = 1;

		O = (OSHEADER *) Supexec (get_osheader);
		ap = (AESVARS *) O->os_magic;

		if (!getcookie (MagX_COOKIE, NULL) || ap->magic != 0x87654321L
		    || ap->magic2 != 0x4D414758 /* 'MAGX' */)
			ap = 0;
	}

	return (ap);
}

/* The following code test whether MagiC is installed, and returns
 * one of the following values:
 *
 * -1 = No MagiC present
 * >0 = MagiC present and MagiC-AES active. The return value contains
 *      the BCD-coded version number.
 */
short InqMagX (void)
{
	AESVARS *ap = 0;

	ap = DOMagixAESVars();

	if (ap)
		return (ap->version);
	else
		return (-1);
}


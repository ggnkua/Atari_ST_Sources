/*
 * new_rsc.h dated 02/13/97
 *
 * Contains the prototypes for the functions rsc_load, rsc_free and
 * rsc_gaddr in new_rsc.c. Requires drawcicn.h
 *
 * For copyright information, copying and use of this routine see
 * new_rsc.c!
 *
 * History:
 * 08/14/95: Creation
 * 08/15/95: Added protection against multiple includes
 * 08/26/95: Renamed include-protection-define
 * 02/13/97: Added some #ifdefs and structure NRSC_DTA to increase
 *           compatibility with other compilers.
 */

#ifndef _NEW_RSC_H_INCLUDED
#define _NEW_RSC_H_INCLUDED

#include "drawcicn.h"
/*
 * You may have to replace mintbind.h to compile this file with your
 * favourite compiler. Btw, no MiNT-function is actually used, so
 * a simple tos.h or osbind.h is OK.
 */
#ifdef __MINT__
#include <mintbind.h>
#else
#ifdef __TURBOC__
#include <tos.h>
#else
#include <osbind.h>
#endif
#endif /* __MINT__ */

/*
 * As almost every compiler has its own defintion of the DTA, we use
 * our own to get around an annoyingly high number of #ifdefs. Its
 * members are compatible to the ones found in ostruct.h of the
 * MiNT library.
 */
typedef struct
{
	char	dta_buf[21];	/* reserved */	char	dta_attribute;	/* file attribute */	UWORD	dta_time;		/* file time stamp */	UWORD	dta_date;		/* file date stamp */	LONG	dta_size;		/* file size */	char	dta_name[14];	/* file name */} NRSC_DTA;

/* The name of the original struct used for F[sg]etdta() */
#ifdef __MINT__
#define ORIG_DTA	_DTA
#else
#ifdef LATTICE
#define ORIG_DTA	void
#else
#define ORIG_DTA	DTA
#endif
#endif /* __MINT__ */

/*
 * rsc_load
 *
 * This function replaces the call rsrc_load and is able to load
 * extended resource-files, i.e. those with color-icons. In that
 * case, all CICON-objects are automatically transformed into
 * USERDEFs (see drawcicn.c/h), so you can use the resource with
 * older versions of TOS as well. Note that rsc_load doesn't set
 * global[5-9]!
 *
 * Input:
 * rname: Pointer to filename of the resource file, the routine uses
 *        shel_find to locate it, just as the normal rsrc_load would
 *        do.
 *
 * Output:
 * 0: An error occured, i.e. file not found or not enough memory
 *    (sorry that it's not possible to detect the type of error, but
 *    this is a tribute to having compatible return codes.
 * otherwise: Resource file loaded successfully
 */
WORD rsc_load(char *rname);

/*
 * rsc_free
 *
 * This function replaces the call rsrc_free and frees all memory
 * allocated by the rsc_load-call (including the memory used by the
 * color-icon-routines).
 *
 * Output:
 * 0: An error occurred, e.g. no call to rsr_load was done before
 * otherwise: Resource and memory freed successfully
 */
WORD rsc_free(void);

/*
 * rsc_gaddr
 *
 * This function replaces the call rsrc_gaddr and determines
 * the addresses of certain structures found in the resource, e.g.
 * object trees, free strings, etc.
 *
 * Input:
 * type: What type of structure is requested. Refer to an AES-
 *       documentation for details
 * index: Index of requested structure
 * address: Pointer to the pointer where the address of the requested
 *          structure should be stored in.
 *
 * Output:
 * 0: An error occurred, e.g. no resource-file was loaded via
 *    rsc_load or the requested structure does not exist (i.e. the
 *    index is out of range)
 * otherwise: Everything OK
 */
WORD rsc_gaddr(WORD type, WORD index, void *address);

#endif

/* EOF */

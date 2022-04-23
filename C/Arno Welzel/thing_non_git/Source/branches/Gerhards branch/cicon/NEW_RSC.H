/*
 * new_rsc.h as of 08/26/95
 *
 * Contains the prototypes for the functions rsc_load, rsc_free and
 * rsc_gaddr in new_rsc.c. Requires drawcicn.h
 *
 * For copying and use of this routine see new_rsc.c!
 *
 * History:
 * 08/14/95: Creation
 * 08/15/95: Added protection against multiple includes
 * 08/26/95: Renamed include-protection-define
 */

#ifndef _NEW_RSC_H_INCLUDED
#define _NEW_RSC_H_INCLUDED

#include "drawcicn.h"
#include <mintbind.h>

typedef struct
{
 RSHDR		*rsc_file;
 LONG		load_magic;
 WORD		vh;
 OBJECT		*rs_object;
 TEDINFO		*rs_tedinfo;
 ICONBLK		*rs_iconblk;
 BITBLK		*rs_bitblk;
 char		**rs_frstr;
 WORD		*rs_imdata;
 BITBLK		**rs_frimg;
 OBJECT		**rs_trindex;
 _CICONBLK	**rs_ciconblk;
 UWORD		rs_ncib;
 DCINFO		dinfo;
} RSINFO;

WORD rsc_load(char *rname, RSINFO *rinfo);
WORD rsc_free(RSINFO *rinfo);
WORD rsc_gaddr(WORD type, WORD index, void *address, RSINFO *rinfo);

#endif

/* EOF */

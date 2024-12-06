/*
 * new_rsc.c as of 12/11/96
 *
 * (c) 1995 by Thomas Binder (binder@rbg.informatik.th-darmstadt.de),
 * Johann-Valentin-May-Straže 7, 64665 Alsbach-H„hnlein, Germany
 *
 * Contains routines to load extended resource-files under all
 * versions of TOS. Requires the routines from drawcicn.c.
 *
 * Permission is granted to spread this routine, but only the .c- and
 * the .h-file together, *unchanged*. Permission is also granted to
 * use this routine in own productions, as long as it's mentioned that
 * the routine was used and that it was written by me.
 *
 * I can't be held responsible for the correct function of this routine,
 * nor for any damage that occurs after the correct or incorrect use of
 * this routine. USE IT AT YOUR OWN RISK!
 *
 * If you find any bugs or have suggestions, please contact me!
 *
 * History:
 * 08/14-
 * 08/15/95: Creation
 * 08/16/95: Moved call rsrc_obfix to the end of get_objects
 * 08/22/95: get_iconblks and get_bitblks now also convert the bitmap-
 *           data into device-dependent format
 * 08/26/95: Removed serious bug which caused crashes when a color
 *           icon had no color data at all (in that case, mainlist
 *           pointed to the ICONBLK of the next color icon instead
 *           of NULL); added new constant named LOAD_MAGIC as a
 *           replacement for the simple 'RSRC'-long and changed the
 *           magic value into 'NRSC'
 * 10/19/95: Memdebug showed a memory leak: I forgot to free the
 *           temporary memory used for speeding up the vr_trnfm-
 *           calls, shame on me...
 * 12/11/96: Removed serious bug which caused crashes with certain
 *           VDIs: The width in pixel of BITBLKs was calculated
 *           wrong :(
 * 11/16/23: Remove manual rsc file load by AES rsc load - Olivier Landemarre
 */

#include <gem.h>
#include "new_rsc.h"
#include <stddef.h>
#ifdef MEMDEBUG
#include <memdebug.h>
#endif
#ifdef USE_PMALLOC
#include <malloc.h>


#define malloc(x) pmalloc(x)
#define free(x) pfree(x)
#endif

#ifdef __MINT__
#undef __MINT__
#endif

/* Workaround for typo in Pure C's aes.h */
#if defined(R_IPBTEXT) && !defined(R_IBPTEXT)
#define R_IBPTEXT	R_IPBTEXT
#endif

#define LOAD_MAGIC	'NRSC'



typedef struct {
	unsigned long	rlen;
	unsigned long	cicon_offset;
} NRSHDR;


/*
 * rsc_load
 *
 * This function manage ressource file with AES only no  USERDEF used
 *  so not compatible with AES < 3.30
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
#define NRSC_INTERFACE 3


WORD rsc_load(char *rname,RSINFO *rinfo)
{	
	short retour;
	retour = rsrc_load(rname);
	if(retour)
	{
		rinfo->load_magic = LOAD_MAGIC;
		rinfo->rs_trindex = (OBJECT **)(*(unsigned long *)(&aes_global[5]));
		rinfo->rsc_file = (RSHDR *)(*(unsigned long *)(&aes_global[7]));
		if(rinfo->rsc_file->rsh_vrsn!=NRSC_INTERFACE)
		{
			rinfo->rs_frstr = (char **)((unsigned long)(rinfo->rsc_file->rsh_frstr)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_tedinfo = (TEDINFO		*)((unsigned long)(rinfo->rsc_file->rsh_tedinfo)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_iconblk = (ICONBLK		*)((unsigned long)(rinfo->rsc_file->rsh_iconblk)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_bitblk = (BITBLK		*)((unsigned long)(rinfo->rsc_file->rsh_bitblk)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_imdata = (WORD		*)((unsigned long)(rinfo->rsc_file->rsh_imdata)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_frimg = (BITBLK		**)((unsigned long)(rinfo->rsc_file->rsh_frimg)+(unsigned long)rinfo->rsc_file);
		}
		else
		{
			rinfo->rs_frstr = (char **)((unsigned long)(((RSXHDR*)rinfo->rsc_file)->rsh_frstr)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_tedinfo = (TEDINFO		*)((unsigned long)(((RSXHDR*)rinfo->rsc_file)->rsh_tedinfo)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_iconblk = (ICONBLK		*)((unsigned long)(((RSXHDR*)rinfo->rsc_file)->rsh_iconblk)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_bitblk = (BITBLK		*)((unsigned long)(((RSXHDR*)rinfo->rsc_file)->rsh_bitblk)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_imdata = (WORD		*)((unsigned long)(((RSXHDR*)rinfo->rsc_file)->rsh_imdata)+(unsigned long)rinfo->rsc_file);
			rinfo->rs_frimg = (BITBLK		**)((unsigned long)(((RSXHDR*)rinfo->rsc_file)->rsh_frimg)+(unsigned long)rinfo->rsc_file);

		}
		if(/*(rinfo->rsc_file->rsh_vrsn==NRSC_INTERFACE)|| A faire*/(rinfo->rsc_file->rsh_vrsn&4))
		{
			NRSHDR *nrsh;	
			nrsh = (NRSHDR*)((unsigned long)rinfo->rsc_file+(unsigned long)rinfo->rsc_file->rsh_rssize) ;
			
			if(nrsh->cicon_offset) 
			{
				rinfo->rs_ciconblk = (_CICONBLK **)((unsigned long)rinfo->rsc_file + nrsh->cicon_offset) ;
			
				rinfo->rs_ncib = 0;
				while((LONG)rinfo->rs_ciconblk[rinfo->rs_ncib]!=-1L && rinfo->rs_ciconblk[rinfo->rs_ncib] && rinfo->rs_ncib<10000) rinfo->rs_ncib++;
				if(rinfo->rs_ncib>9999) 
				{
					Cconws("rsc_load ncib too high!!!\n"); 
				}
			}	
		}
		else 
		{
			rinfo->rs_ciconblk = NULL;
			rinfo->rs_ncib = 0;
		}
	}
	return retour;

}

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
WORD rsc_free(RSINFO *rinfo)
{
	if (rinfo->load_magic != LOAD_MAGIC)
		return(0);
	
	(*(unsigned long *)(&aes_global[5])) = (unsigned long )(rinfo->rs_trindex);
	(*(unsigned long *)(&aes_global[7])) = (unsigned long )(rinfo->rsc_file);
	rinfo->load_magic = 0L;
	return rsrc_free();

};

/*
 * rsc_gaddr
 *
 * This function replaces the call rsrc_gaddr and determines
 * the addresses of certain structures found in the resource, e.g.
 * object trees, free strings, etc. Note that rsc_gaddr isn't able
 * to return the addresses of the color-icon-structures, mainly
 * because I have no information if rsrc_gaddr is able to do so, and,
 * if yes, what new constants are used for that. If you know this,
 * please contact me.
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
 *    index is out of range). Note that the AES usually doesn't check
 *    this, i.e. rsrc_gaddr may return nonsense in address, which
 *    won't happen with this function.
 * otherwise: Everything OK
 */
WORD rsc_gaddr(WORD type, WORD index, void *address,RSINFO *rinfo)
{
	if (rinfo->load_magic != LOAD_MAGIC)
		return(0);

	(*(unsigned long *)(&aes_global[5])) = (unsigned long )(rinfo->rs_trindex);
	(*(unsigned long *)(&aes_global[7])) = (unsigned long )(rinfo->rsc_file);
	return rsrc_gaddr(type,index,address);
}

/* EOF */

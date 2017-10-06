/****************************************************************************

 Module
  rsrc.c
  
 Description
  Resource handling functions in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	
 Revision history
 
  951224 cg
   Added standard header.
 
  951228 cg
   Fixed bug in Rsrc_load; if the resource couldn't be loaded no error
   code was returned.
   
  960413 cg
   Fixed bug in fixobcoord(); changed from signed to unsigned BYTE.
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <osbind.h>
#include <stdio.h>
#include <unistd.h>

#include "appl.h"
#include "debug.h"
#include "gemdefs.h"
#include "mintdefs.h"
#include "rsrc.h"
#include "shel.h"
#include "types.h"
#include "vdi.h"

/****************************************************************************
 * Macros                                                                   *
 ****************************************************************************/

#define	FO_READ	0

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/
 
typedef struct {
  LONG filesize;
  LONG cicon_offset;
  LONG terminator;
}RSHD_EXT;

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

static WORD	fixobcoord(OBJECT *ob) {
	UBYTE *dumchar = (UBYTE *)&ob->ob_x;
	
	ob->ob_x = dumchar[0] + ((WORD)dumchar[1]) * globals.clwidth;
	ob->ob_y = dumchar[2] + ((WORD)dumchar[3]) * globals.clheight;
	ob->ob_width = dumchar[4] + ((WORD)dumchar[5]) * globals.clwidth;
	ob->ob_height = dumchar[6] + ((WORD)dumchar[7]) * globals.clheight;

	return	0;
};

static RSHDR	*loadrsc(WORD vid,BYTE *filename) {
	LONG	fnr;
	BYTE    namebuf[200];
	LONG	flen;
	
	RSHDR	*rsc;

	strcpy( namebuf, filename);
	if (!Shel_do_find( namebuf)) {
		return NULL;
	};

	fnr = Fopen( namebuf, FO_READ);

	if(fnr < 0) {
		return NULL;
	};
	
	flen = Fseek(0,(WORD)fnr,SEEK_END);
	
	rsc = (RSHDR *)Mxalloc(flen,GLOBALMEM);

	if(!rsc) {
		return NULL;
	};
	
	Fseek(0,(WORD)fnr,SEEK_SET);	
	Fread((WORD)fnr,flen,rsc);
	Fclose((WORD)fnr);

	Rsrc_do_rcfix(vid,rsc);
	
	return rsc;
}

static void	*calcelemaddr(RSHDR *rsc,WORD type,WORD nr) {
	switch(type) {
		case R_TREE:  /*0x00*/
			return ((OBJECT **)(rsc->rsh_trindex + (LONG)rsc))[nr];
		case R_STRING: /*0x05*/
			return ((BYTE **)(rsc->rsh_frstr + (LONG)rsc))[nr];
		
		case R_FRSTR:  /*0x0f*/
			return &((BYTE **)(rsc->rsh_frstr + (LONG)rsc))[nr];
			
		case R_FRIMG: /* 0x10 */
			return &((void **)(rsc->rsh_frimg + (LONG)rsc))[nr];
			
		default:
			DB_printf("%s: Line %d: Rsrc_gaddr: unknown type %d\r\n",
							__FILE__,__LINE__,type);
			return 0L;
	};
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 *  Rsrc_do_rcfix                                                           *
 *   Implementation of rsrc_rcfix().                                        *
 ****************************************************************************/
WORD              /* 0 if ok or != 0 if error.                              */
Rsrc_do_rcfix(    /*                                                        */
WORD   vid,       /* VDI workstation id.                                    */
RSHDR  *rsc)      /* Resource structure to fix.                             */
/****************************************************************************/
{
	WORD	i;
	
	OBJECT	*owalk = (OBJECT *)((LONG)rsc->rsh_object + (LONG)rsc); 
	TEDINFO	*tiwalk = (TEDINFO *)((LONG)rsc->rsh_tedinfo + (LONG)rsc);
	ICONBLK	*ibwalk = (ICONBLK *)((LONG)rsc->rsh_iconblk + (LONG)rsc);
	BITBLK	*bbwalk = (BITBLK *)((LONG)rsc->rsh_bitblk + (LONG)rsc);
	LONG		*treewalk = (LONG *)((LONG)rsc->rsh_trindex + (LONG)rsc);
	LONG    *frstrwalk = (LONG *)((LONG)rsc->rsh_frstr + (LONG)rsc);
	
	CICONBLK *(*cicons);
	
	if(rsc->rsh_vrsn & 0x4) {
		RSHD_EXT *extension = (RSHD_EXT *)((LONG)rsc + (LONG)rsc->rsh_rssize);
		CICONBLK *cwalk;
		WORD     nr_cicon;
		WORD     i = 0;

		cicons = (CICONBLK **)((LONG)extension->cicon_offset + (LONG)rsc);

		while(cicons[i++] != (CICONBLK *)-1);
		
		nr_cicon = i - 1;
		
		cwalk = (CICONBLK *)&cicons[i];
		
		for(i = 0; i < nr_cicon; i++) {
			LONG monosize = (((cwalk->monoblk.ib_wicon + 15) >> 4) << 1) * cwalk->monoblk.ib_hicon;
			CICON *cicwalk;
			LONG nr_icons = (LONG)cwalk->mainlist;
			WORD j;

			cicons[i] = cwalk;

			cwalk->monoblk.ib_pdata = (WORD *)((LONG)cwalk + sizeof(ICONBLK) + sizeof(LONG));
			cwalk->monoblk.ib_pmask = (WORD *)((LONG)cwalk->monoblk.ib_pdata + monosize);
			cwalk->monoblk.ib_ptext = (BYTE *)((LONG)cwalk->monoblk.ib_pmask + monosize);

			cicwalk = (CICON *)((LONG)cwalk->monoblk.ib_ptext + 12);
			cwalk->mainlist = cicwalk;
			
			for(j = 0; j < nr_icons; j++) {
				LONG planesize = monosize * cicwalk->num_planes;
				MFDB s,d;
				
				cicwalk->col_data = (WORD *)((LONG)cicwalk + sizeof(CICON));
				cicwalk->col_mask = (WORD *)((LONG)cicwalk->col_data + planesize);
				
				if(cicwalk->sel_data) {
					cicwalk->sel_data = (WORD *)((LONG)cicwalk->col_mask + monosize);
					cicwalk->sel_mask = (WORD *)((LONG)cicwalk->sel_data + planesize);
					cicwalk->next_res = (CICON *)((LONG)cicwalk->sel_mask + monosize);				
				}
				else {
					cicwalk->sel_data = NULL;
					cicwalk->sel_mask = NULL;
					cicwalk->next_res = (CICON *)((LONG)cicwalk->col_mask + monosize);				
				};

				(LONG)s.fd_addr = (LONG)cicwalk->col_data;
				s.fd_w = cwalk->monoblk.ib_wicon;
				s.fd_h = cwalk->monoblk.ib_hicon;
				s.fd_wdwidth = ((cwalk->monoblk.ib_wicon +15) >> 4);
				s.fd_stand = 1;
				s.fd_nplanes = cicwalk->num_planes;
	
				d = s;
				d.fd_stand = 0;
	
				Vdi_vr_trnfm(vid,&s,&d);

				if(cicwalk->sel_data) {
					(LONG)s.fd_addr = (LONG)cicwalk->sel_data;
					(LONG)d.fd_addr = (LONG)cicwalk->sel_data;
	
					Vdi_vr_trnfm(vid,&s,&d);
				};

				cicwalk = cicwalk->next_res;
				
				if(j == (nr_icons - 1)) {
					cicwalk->next_res = NULL;
				};
			};
			
			cwalk = (CICONBLK *)cicwalk;			
		};
	};

	for(i = 0; i < rsc->rsh_nobs; i++) {
		switch((BYTE)owalk[i].ob_type) {
		case	G_BOX:
		case	G_IBOX:
		case	G_BOXCHAR:
	    break;
		case	G_TEXT:
		case	G_BOXTEXT:
		case	G_FTEXT:
		case	G_FBOXTEXT:
		case	G_IMAGE:
		case	G_PROGDEF:
		case	G_BUTTON:
		case	G_STRING:
		case	G_TITLE:
		case	G_ICON:
			owalk[i].ob_spec.index += (LONG)rsc;
			break;

		case	G_CICON:
			owalk[i].ob_spec.index = (LONG)cicons[owalk[i].ob_spec.index];
			break;
							
		default:
			DB_printf("fixrsc: unsupported type: %d\r\n"
				,owalk[i].ob_type);
			sleep(1);
		};
		
		fixobcoord(&owalk[i]);
	};

	for(i = 0; i < rsc->rsh_nted; i++) {
		(LONG)tiwalk[i].te_ptext += (LONG)rsc;
		(LONG)tiwalk[i].te_ptmplt += (LONG)rsc;
		(LONG)tiwalk[i].te_pvalid += (LONG)rsc;
	};
	
	for(i = 0; i < rsc->rsh_nib; i++) {
		(LONG)ibwalk[i].ib_pmask += (LONG)rsc;
		(LONG)ibwalk[i].ib_pdata += (LONG)rsc;
		(LONG)ibwalk[i].ib_ptext += (LONG)rsc;
	};
	
	for(i = 0; i < rsc->rsh_nbb; i++) {
		(LONG)bbwalk[i].bi_pdata += (LONG)rsc;
	};

	for(i = 0; i < rsc->rsh_ntree; i++) {
		(LONG)treewalk[i] += (LONG)rsc;
	};	
	
	for(i = 0; i < rsc->rsh_nstring; i++) {
		(LONG)frstrwalk[i] += (LONG)rsc;
	};	
	
	return 0;
}


void	Rsrc_load(AES_PB *apb)	/*0x006e*/ {
	RSHDR	*rsc;

	rsc = loadrsc(apb->global->int_info->vid,(BYTE *)apb->addr_in[0]);

	apb->global->rscfile = (OBJECT **)((LONG)rsc->rsh_trindex + (LONG)rsc);
	apb->global->rshdr = (RSHDR *)rsc;

	if(rsc) {
		apb->global->int_info->rshdr = rsc;
		apb->int_out[0] = 1;
	}
	else {
		apb->int_out[0] = 0;
	};
}

void	Rsrc_free(AES_PB *apb)	/*0x006f*/ {
	if(apb->global->int_info->rshdr) {
		Mfree(apb->global->int_info->rshdr);
		apb->global->int_info->rshdr = NULL;
		
		apb->int_out[0] = 1;
	}
	else {
		apb->int_out[0] = 0;
	};
}

/****************************************************************************
 *  Rsrc_do_gaddr                                                           *
 *   Implementation of rsrc_gaddr().                                        *
 ****************************************************************************/
WORD              /* 0 if ok or != 0 if error.                              */
Rsrc_do_gaddr(    /*                                                        */
RSHDR  *rshdr,    /* Resource structure to search.                          */
WORD   type,      /* Type of object.                                        */
WORD   index,     /* Index of object.                                       */
OBJECT **addr)    /* Object address.                                        */
/****************************************************************************/
{
	if(rshdr) {
		*addr = calcelemaddr(rshdr,type,index);
		
	  if(*addr) {
			return 1;
		};
	};
	
	return 0;
}

void	Rsrc_gaddr(AES_PB *apb)	/*0x0070*/ {
	apb->int_out[0] = Rsrc_do_gaddr(apb->global->int_info->rshdr,
		apb->int_in[0],apb->int_in[1],
		(OBJECT **)&apb->addr_out[0]);
}

void	Rsrc_saddr(AES_PB *apb)	/*0x0071*/ {
	apb->int_out[0] = 0;
};

void	Rsrc_obfix(AES_PB *apb)	/*0x0072*/ {
	apb->int_out[0] = fixobcoord(&((OBJECT *)apb->addr_in[0])[apb->int_in[0]]);
};

void	Rsrc_rcfix(AES_PB *apb)	/*0x0073*/ {
	RSHDR	*rsc = (RSHDR *)apb->addr_in[0];
	
	Rsrc_do_rcfix(apb->global->int_info->vid,rsc);
	
	apb->global->rscfile = (OBJECT **)((LONG)rsc->rsh_trindex + (LONG)rsc);
	apb->global->rshdr = apb->global->int_info->rshdr = rsc;
	
	apb->int_out[0] = 1;
}

/****************************************************************************
 *  Rsrc_duplicate                                                          *
 *   Create copy of resource tree. When the copy isn't needed anymore it    *
 *   should be freed using Rsrc_free_tree().                                *
 ****************************************************************************/
OBJECT *          /* New resource tree, or NULL.                            */
Rsrc_duplicate(   /*                                                        */
OBJECT *src)      /* Original resource tree.                                */
/****************************************************************************/
{
	OBJECT *twalk = src,*newrsc;
	TEDINFO	*ti;
	WORD	num_obj = 0;
	WORD	num_ti = 0;
	
	do {
		num_obj++;
		
		switch(twalk->ob_type) {
		case G_TEXT:
			num_ti++;
		};
	}while(!((twalk++)->ob_flags & LASTOB));

	newrsc = (OBJECT *)Mxalloc(sizeof(OBJECT) * num_obj + sizeof(TEDINFO) * num_ti,PRIVATEMEM);
	ti = (TEDINFO *)(((LONG)newrsc) + sizeof(OBJECT) * num_obj);

	memcpy(newrsc,src,sizeof(OBJECT) * num_obj);

	twalk = newrsc;

	do {
		switch(twalk->ob_type) {
		case G_TEXT:
			memcpy(ti,twalk->ob_spec.tedinfo,sizeof(TEDINFO));
			twalk->ob_spec.tedinfo = ti;
			ti++;
		};
	}while(!((twalk++)->ob_flags & LASTOB));

	return newrsc;
}

/****************************************************************************
 *  Rsrc_free_tree                                                          *
 *   Erase resource tree created with Rsrc_duplicate.                       *
 ****************************************************************************/
void              /*                                                        */
Rsrc_free_tree(   /*                                                        */
OBJECT *src)      /* Tree to erase.                                         */
/****************************************************************************/
{
	Mfree(src);
}

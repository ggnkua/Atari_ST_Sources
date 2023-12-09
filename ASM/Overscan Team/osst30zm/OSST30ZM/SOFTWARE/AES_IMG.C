/**********************************************
 *
 * Routinen zum Konvertieren von AES-Images in das
 * ger„teabh„ngige Format.
 * 
 * šbernommen aus ProGEM von Tim Oren
 *
 * Fr TurboC-Compiler 1.1
 *
 ****************/

#include <vdi.h>
#include <aes.h>

/* Prototypes */
void vdi_fix(MFDB *pfd,void *theaddr,int wb,int h);
void vdi_trans(void *saddr,int swb,void *daddr,int dwb,int h,int handle);
void trans_bitblk(OBSPEC *spec,int handle);
int  trans_gimage(OBJECT *tree,int obj,int handle);


void vdi_fix(MFDB *pfd,void *theaddr,int wb,int h)
{
	pfd->fd_wdwidth = wb >> 1;
	pfd->fd_w       = wb << 3;
	pfd->fd_h       = h;
	pfd->fd_nplanes = 1;       /* Monochrome  */
	pfd->fd_addr    = theaddr;
}

void vdi_trans(void *saddr,int swb,void *daddr,int dwb,int h,int handle)
{
MFDB	src, dst;

	vdi_fix(&src, saddr, swb, h);	/* Load the source MFDB	       */
	src.fd_stand = 1;		/* Set it's std form flag      */

	vdi_fix(&dst, daddr, dwb, h);	/* Load the destination MFDB   */
	dst.fd_stand = 0;		/* Clear the std flag	       */
	vr_trnfm(handle, &src, &dst );	/* Call the VDI	       */
}

void trans_bitblk(OBSPEC *spec,int handle)
{
void   *taddr;
int    wb, hl;

	taddr = (*spec).bitblk;
	if ((long)taddr == -1L) return; /* Get and validate image address */
	wb = (*spec).bitblk->bi_wb;	/* Extract image dimensions	  */
	hl = (*spec).bitblk->bi_hl;	/* Perform a transform in place   */
	vdi_trans(taddr, wb, taddr, wb, hl, handle);
}				

int trans_gimage(OBJECT *tree,int obj,int handle)
{
int	type, wb, hl;
void	*taddr;
OBSPEC  spec;

	type = tree[obj].ob_type;		/* Load object type 	*/
        spec = tree[obj].ob_spec;
	if (spec.index == -1L)			/* Load and check 	*/
		return 0;			/* ob_spec pointer  	*/
	switch (type) 
	{
	case G_IMAGE:	trans_bitblk((OBSPEC *)&spec,handle);	
			return 1;		/* Transform image  */
	case G_ICON:	hl = spec.iconblk->ib_hicon;	/* Load icon size   */
			wb = (spec.iconblk->ib_wicon + 7) >> 3;
                        taddr = spec.iconblk->ib_pdata;	/* Transform data   */
			if ( (long)taddr != -1L)
				vdi_trans(taddr, wb, taddr, wb, hl,handle);
                        taddr = spec.iconblk->ib_pmask;	/* Transform mask   */
			if ( (long)taddr != -1L)
				vdi_trans(taddr, wb, taddr, wb, hl,handle);
			return 1;
	default:	return 0;
	}
}

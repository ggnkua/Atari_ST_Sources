/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		sprites.c

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

#include <gemfast.h>
#include <types.h>
#include "chkalloc.h"
#include "scratt.h"
#include "spritesc.h"

int WordPix(i)	/* Rounds up pixel value to be on word boundary	*/
int i;
{
	return (i+15)>>4;	/* = ((i+15)/16) but quicker	*/
}

void InitFDB(fdb, addr, dimx, dimy)	/* Initialise VDI FDB	*/
FDB *fdb;	/* Pointer to the FDB			*/
char *addr;	/* Address of the VDI memory form	*/
int dimx, dimy; /* Dimensions of the memory form	*/
{
    register FDB *f = fdb;

    f->fd_addr = (long)addr;
    f->fd_w = dimx;
    f->fd_wdwidth = WordPix(dimx);		/* dimension in 'words'	*/
    f->fd_h = dimy;
    f->fd_stand = 0;				/* device specific form */
    f->fd_nplanes = planes();			/* number of planes	*/ 
    f->fd_r1 =
    f->fd_r2 =
    f->fd_r3 = 0;				/* reserved fields	*/
}	
    
struct sprite_s *OpenSprite(vdi_handle, dimx, dimy)
int vdi_handle;
int dimx, dimy;
{
    register struct sprite_s *sp;
    int swsize;		/* sprite word size */

    swsize = WordPix(dimx)*dimy*planes();

    sp = (struct sprite_s *)chkcalloc(1, sizeof(struct sprite_s));
    sp->v_hnd = vdi_handle;
    sp->sptemp = chkcalloc(swsize, sizeof(WORD));
    InitFDB(&sp->spriteFDB, sp->sptemp, dimx, dimy);
    InitFDB(&sp->screenFDB, (char *)0, 0, 0);

    sp->pxymemscr[0] = sp->pxyscrmem[4] =
    sp->pxymemscr[1] = sp->pxyscrmem[5] = 0;
    sp->pxymemscr[2] = sp->pxyscrmem[6] = dimx-1;
    sp->pxymemscr[3] = sp->pxyscrmem[7] = dimy-1;

    return sp;
}
    
void DrawSprite(spp, x, y, shape, mask)
struct sprite_s *spp;
int x,y;		/* Sprite position in logical coordinates */	
char *shape, *mask;
{
    register struct sprite_s *sp = spp;
    sp->pxymemscr[4] = sp->pxyscrmem[0] = x;
    sp->pxymemscr[5] = sp->pxyscrmem[1] = y;
    sp->pxymemscr[6] = sp->pxyscrmem[2] = sp->pxyscrmem[0]+sp->pxymemscr[2];
    sp->pxymemscr[7] = sp->pxyscrmem[3] = sp->pxyscrmem[1]+sp->pxymemscr[3];

    sp->spriteFDB.fd_addr = (long)sp->sptemp;
    vro_cpyform(spp->v_hnd, S_ONLY, sp->pxyscrmem,
		&sp->screenFDB, &sp->spriteFDB);

    sp->spriteFDB.fd_addr = (long)mask;
    vro_cpyform(spp->v_hnd, NOTS_AND_D, sp->pxymemscr, 
		&sp->spriteFDB, &sp->screenFDB);

    sp->spriteFDB.fd_addr = (long)shape;
    vro_cpyform(spp->v_hnd, S_OR_D, sp->pxymemscr, 
		&sp->spriteFDB, &sp->screenFDB);
}

void UndrawSprite(spp)
struct sprite_s *spp;
{
    register struct sprite_s *sp =spp;

    sp->spriteFDB.fd_addr = (long)sp->sptemp;
    vro_cpyform(spp->v_hnd, S_ONLY, sp->pxymemscr, 
		&sp->spriteFDB, &sp->screenFDB);
}

void CloseSprite(spp)
struct sprite_s *spp;
{
    free(spp->sptemp);
    free(spp);
}

/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		pinball.c

	Version:	1.0

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

#include <osbind.h>
#include <gemfast.h>
#include <stdio.h>
#include <malloc.h>

/*	SCREEN DATA	*/

#define SPRITDIMX	(16)
#define SPRITDIMY	(16)
#define SCREENSIZE	(32000)
#define SCREENALLOC	(32256)
#define REZS		(3)

static int res = 2;
static int planes[REZS] =	{ 4, 2, 1 };
static int screendimx[REZS] =	{ 320, 640, 640 };
static int screendimy[REZS] = 	{ 200, 200, 400 };
#define LOGDIMX 32000
#define LOGDIMY 32000
static int divx; 
static int divy;	/* scaling for logical to physical coordinates	      */
static int pallette[16];/* place to store pallette so we can restore at end   */

/*	GLOBAL DATA	 */

static int v_hnd;			/* VDI handle */

struct sprite_s {
	FDB spriteFDB;
        FDB screenFDB;
	int pxymemscr[8];
	int pxyscrmem[8];
	char *sptemp;
};

struct flipdef_s{
    struct flipdef_s	*nextflip;
    char		*mempos;
    struct sprite_s	*scrsprite;
};

static struct flipdef_s loc, phys, *curlog;
static char myscreen[SCREENALLOC];	/* my screen memory for flipping */

static char *ball, *mask;

static struct {
	int	usealert;
	char	*errstring;
} err[] = {
	0, "",
	0, "Sorry, there isn't enough memory\n",
	0, "Sorry, the GEM AES won't initialise\n",
	0, "Sorry, I can't open a GEM VDI virtual workstation\n",
	1, "[1][ Sorry, | I can't read the picture file][OK]",
	1, "[1][ Sorry, | I can't find the picture file][OK]",
	1, "[1][ Sorry, | the picture file format is wrong][OK]" 
};

void errexit(n)
int n;
{
	if (err[n].usealert)
		form_alert(1, err[n].errstring);
	else
		fprintf(stderr, err[n].errstring);
	exit(n);
}

char *mycalloc(nelem, elemsize)
int nelem;
int elemsize;
{
	char *temp;

	if (temp = calloc(nelem, elemsize))
		return temp;
	errexit(1);
}

void AppStart()				/* Initialise GEM		*/
{
    extern int gl_apid;			/* the AES application id	*/

    int work_in[12], work_out[57];	/* arrays for openvwk		*/
    int i;				/* loop index			*/
    int dummy;				/* dummy return variable	*/

    appl_init();			/* initialise GEM's AES		*/
    if(gl_apid == -1)
	errexit(2);
    v_hnd = graf_handle(&dummy, &dummy, &dummy, &dummy);
    for(i = 0; i < 10; i++)
    	work_in[i] = 1;
    work_in[10] = 2;			/* raster co-ordinates		*/
    v_opnvwk(work_in, &v_hnd, work_out);/* open GEM virtual workstation */
    if (!v_hnd)
	errexit(3);
    Cursconf(0, 0);			/* configure cursor off		*/
    res = Getrez();			/* get screen resolution	*/
    for (i=0; i<16; i++) {		/* get pallette setting		*/
	pallette[i] = Setcolor(i, -1);
    }
}

void AppEnd()
{
    v_clsvwk(v_hnd);			/* Close GEM virtual workstation*/
    appl_exit();			/* Closedown AES session	*/
    Setpallete(&pallette[0]);		/* Restore pallete		*/
}

int  row;		/* current row number				*/
int  plane;		/* current plane number				*/
int  bytix;		/* byte index for this row and plane		*/
char *planep;		/* pointer to first word in this row and plane	*/
int  bytesperrow;	/* number of bytes per row * planes		*/
 
void DgPutInit(buf)	/* Initialise unpacking of Degas screen		*/
char *buf;
{
    bytesperrow = (screendimx[res]/8) * planes[res];
    planep = buf;
    row =
    plane =
    bytix = 0;
}

void DegasPutByte(b)	/* Puts b into screen buffer */
char b;
{
    planep[bytix++] = b;
    if ((bytix&1)==0) {
	bytix += (planes[res]+planes[res]-2);
	if (bytix >= bytesperrow) {
	    plane++;
	    if (plane >= planes[res]) {
		plane = 0;
		planep += bytesperrow;
		row++;
    	    }
	    bytix = plane+plane;
	}
    }
}

struct degashdr_s {	/* structure of first part of a degas picture	*/
    int		res;
    int		pallette[16];
};

void DegasGet(buf, filename)	/* Gets Degas picture into screen buffer */
char *buf;	/* screen buffer	*/
char *filename;	/* picture's file name	*/
{
    FILE *f;			/* file handle			*/
    struct degashdr_s hdr;	/* Degas picture header		*/
    int prefix;			/* character buffer		*/
    int c;			/* another character buffer	*/

    if ((f=fopen(filename, "rb")) != NULL) { 
	if (fread(&hdr, sizeof(struct degashdr_s), 1, f) != 1)
		errexit(4);
	DgPutInit(buf);
	do {
	    prefix = fgetc(f);
	    if (prefix==EOF)
		errexit(6);
	    if (prefix>=0 && prefix<=127 ) {
		prefix++;
		while ((prefix--)>0) {
		    c = fgetc(f);
		    if (c==EOF || row>=screendimy[res])
			errexit(6);
		    DegasPutByte(c);
	        }
	    }
	    else if (prefix>=129 && prefix<=255) {
		prefix = 257-prefix;
		c = fgetc(f);
		if (c==EOF)
		    errexit(6);
		while ((prefix--)>0) {
		    if (row>=screendimy[res])
			errexit(6);
		    DegasPutByte(c);
		}
	    }
	} while (row<screendimy[res]);
	fclose(f);
    }
    else {
	errexit(5);
    }
    Setpallete(&hdr.pallette[0]);
    Vsync();
}

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
    f->fd_nplanes = planes[res];		/* number of planes	*/ 
    f->fd_r1 =
    f->fd_r2 =
    f->fd_r3 = 0;			/* reserved fields	*/
}	
    
struct sprite_s *OpenSprite(dimx, dimy)
int dimx, dimy;
{
    register struct sprite_s *sp;
    int swsize;		/* sprite word size */

    swsize = WordPix(dimx)*dimy*planes[res];

    sp = (struct sprite_s *)mycalloc(1, sizeof(struct sprite_s));
    sp->sptemp = mycalloc(swsize, sizeof(WORD));
    InitFDB(&sp->spriteFDB, sp->sptemp, dimx, dimy);
    InitFDB(&sp->screenFDB, (char *)0, 0, 0);

    sp->pxymemscr[0] = sp->pxyscrmem[4] =
    sp->pxymemscr[1] = sp->pxyscrmem[5] = 0;
    sp->pxymemscr[2] = sp->pxyscrmem[6] = dimx-1;
    sp->pxymemscr[3] = sp->pxyscrmem[7] = dimy-1;

    return sp;
}
    
DrawSprite(spp, x, y, shape, mask)
struct sprite_s *spp;
int x,y;		/* Sprite position in logical coordinates */	
char *shape, *mask;
{
    register struct sprite_s *sp = spp;
    sp->pxymemscr[4] = sp->pxyscrmem[0] = (x)/divx;
    sp->pxymemscr[5] = sp->pxyscrmem[1] = (y)/divy;
    sp->pxymemscr[6] = sp->pxyscrmem[2] = sp->pxyscrmem[0]+sp->pxymemscr[2];
    sp->pxymemscr[7] = sp->pxyscrmem[3] = sp->pxyscrmem[1]+sp->pxymemscr[3];

    sp->spriteFDB.fd_addr = (long)sp->sptemp;
    vro_cpyform(v_hnd, S_ONLY, sp->pxyscrmem, &sp->screenFDB, &sp->spriteFDB);

    sp->spriteFDB.fd_addr = (long)mask;
    vro_cpyform(v_hnd, NOTS_AND_D, sp->pxymemscr, 
		&sp->spriteFDB, &sp->screenFDB);

    sp->spriteFDB.fd_addr = (long)shape;
    vro_cpyform(v_hnd, S_OR_D, sp->pxymemscr, &sp->spriteFDB, &sp->screenFDB);
}

UndrawSprite(spp)
struct sprite_s *spp;
{
    register struct sprite_s *sp =spp;

    sp->spriteFDB.fd_addr = (long)sp->sptemp;
    vro_cpyform(v_hnd, S_ONLY, sp->pxymemscr, &sp->spriteFDB, &sp->screenFDB);
}

CloseSprite(spp)
struct sprite_s *spp;
{
    free(spp->sptemp);
    free(spp);
}

void Flip()	/* Animate by switching over screen buffers	*/
{
    Setscreen(curlog->nextflip->mempos, curlog->mempos, -1);
    Vsync();			/* wait til done on next vertical blank	*/
    curlog = curlog->nextflip;	/* cycle onto next screen buffer	*/
}

void PrepSprites(screenimg)	/* Get sprites from picture	*/
char *screenimg;
{
    static int pxy[] = {0, 0, 0, 0, 0, 0, 0, 0};
    FDB f, s;
    int spritedimx = screendimx[res]/40;
    int spritedimy = screendimy[res]/25;
    int i;
    int swsize;		/* sprite word size */

    swsize = WordPix(spritedimx)*spritedimy*planes[res];

    /* 
     * Get ball from [0, 0] -> [spritedimx-1, spritedimy-1] rectangle
     */

    loc.scrsprite = OpenSprite(spritedimx, spritedimy);
    phys.scrsprite = OpenSprite(spritedimx, spritedimy);

    ball = mycalloc(swsize, sizeof(WORD));
    for (i=0; i<swsize*sizeof(WORD); i++)
	ball[i] = 0;
    InitFDB(&f, ball, spritedimx, spritedimy);
    InitFDB(&s, screenimg, screendimx[res], screendimy[res]);
    pxy[6] = pxy[2] = spritedimx-1;
    pxy[7] = pxy[3] = spritedimy-1;

    vro_cpyform(v_hnd, S_ONLY, &pxy[0], &s, &f);

    /* 
     * Get mask from [spritedimx, 0] -> [2*spritedimx-1, spritedimy-1] rectangle
     */

    mask = mycalloc(swsize, sizeof(WORD));
    for (i=0; i<swsize*sizeof(WORD); i++)
	mask[i] = 0;
    f.fd_addr = (long)mask;
    pxy[0] = spritedimx;
    pxy[2] = spritedimx+spritedimx-1;

    vro_cpyform(v_hnd, S_ONLY, &pxy[0], &s, &f);
}

void PrepScreens()	/* Get the screen buffers	*/ 
{
    divx = LOGDIMX/screendimx[res];
    divy = LOGDIMY/screendimy[res];

    curlog = &loc;
    loc.nextflip = &phys;
    phys.nextflip = &loc;	/* now buffers are in a cyclic structure      */
    phys.mempos = (char *)Physbase();
    {
	register long temp = (long)myscreen;
	
	temp = (temp+255) & 0xffffff00;
	loc.mempos = (char *)temp;	/* now buffer is at 256 byte boundary */
    }
}

char fname[] = "pinball.pc?";

void Prepare()
{
    PrepScreens();
    fname[sizeof(fname)-2] = res + '1';
    DegasGet(loc.mempos, fname);
    PrepSprites(loc.mempos);
    memmove(phys.mempos, loc.mempos, SCREENSIZE); /* same pic on each screen  */
    Flip();
}

int main()
{
    register int posx = 100;	
    register int posy = 100;
    register int speedx = 800;
    register int speedy = 800;
    int fgravity = 5;
    int borderx = 29000;
    int bordery = 29000;
    int speedlimx = 50;
    
    AppStart();
    Prepare();

    /* Get into initial state where only physical screen shows sprite */

    DrawSprite(curlog->scrsprite, posx, posy, ball, mask);
    Flip();

    /* Main program loop */

    while (speedx<-speedlimx || speedx>speedlimx) { /* while ball fast enough */
	speedy = speedy + fgravity;	/* apply effect of gravity */
	posx = posx + speedx;		/* ball moves to new position */
	posy = posy + speedy;
	if (posx<=0 || posx>=borderx) {/* if hitting wall */
		posx = posx - speedx;
		speedx = -speedx/2;	/* bounce and reduce speed */
	}
	if (posy<=0 || posy>=bordery) {/* if hitting floor/roof */ 
		posy = posy - speedy;
		speedy = -speedy/2;	/* bounce and reduce speed */
	}
	DrawSprite(curlog->scrsprite, posx, posy, ball, mask);
	Flip();
	UndrawSprite(curlog->scrsprite);
    }

    Flip();
    UndrawSprite(curlog->scrsprite);

    Setscreen(phys.mempos, phys.mempos, -1);
    Vsync();

    AppEnd();
    return (0);
}

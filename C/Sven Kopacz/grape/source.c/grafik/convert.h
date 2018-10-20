/* Global import/export palette CMY */
extern uchar gc_pal[256][3];

/* Def's for Plane-input */
#define PRED 	1
#define PGREEN 2
#define PBLUE 	4

#define PCYAN	1
#define PMAG		2
#define PYEL		4
#define PBLACK 8

void con_set_grey_pal(int mode);
void pal_to_grey(int num);

void incon_1(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void incon_4pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void incon_4ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void incon_8ppgrey(BLOCK_DSCR *bd, GRAPE_DSCR *dd, int mode);
void incon_8pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void incon_8ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void incon_rgbpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void incon_rgbip(int planes, BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void incon_cmypp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void incon_cmykpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void incon_cmykip(int planes,BLOCK_DSCR *bd, GRAPE_DSCR *dd);

void outcon_1(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_4pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_4ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_8ppgrey(BLOCK_DSCR *bd, GRAPE_DSCR *dd, int mode);
void outcon_8ipgrey(int lbit, int black, BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_8pp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_8ip(int mode, BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_rgbpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_rgbip(int planes, BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_cmypp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_cmykpp(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void outcon_cmykip(int planes,BLOCK_DSCR *bd, GRAPE_DSCR *dd);

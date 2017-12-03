/*
	vector.h
	
	defines for vector
*/
#include <portab.h>
#include "ptlist.h"

#ifndef _VECTOR_H
#define _VECTOR_H

typedef unsigned int uint;
typedef long unsigned ulong;

typedef struct
{
	char fname[120];
	uint mode;
	ulong colors;
	uint maxx, maxy;
	ulong size;
	UWORD *img;
} IMGF30;

typedef struct
{
	uint maxx, maxy;
	ulong size;
	BYTE *img;
} GREY;

#define DEFAULT_FILTER_FACTOR 1.8	/* used when not specified in cmd line */

#if defined(_QUIET)
#define printf nulldev
/* debug.c */
void nulldev(const char* format, ...);
#endif

#if defined(_DEBUG)
#define malloc debug_malloc
#define free debug_mfree
/* debug.c */
void *debug_malloc(long size);
void debug_mfree(void *block);
#endif

extern UWORD greytone[];

extern float alpha;
extern double sa[], sb[];	/* filter */
extern double da,   db[];	/* gradient */

/* factor.c */
extern void factor(float alpha);

/* imgf30.c */
extern IMGF30 *load_f30(char *fname);
extern void free_f30(IMGF30 *i);

/* imgrey.c */
extern void precalc_grey(void);
extern GREY *new_grey(void);
extern GREY *create_grey(GREY *grey);
extern GREY *copy_grey(GREY *grey);
extern void free_grey(GREY *g);
extern GREY *convf30_grey(IMGF30 *i);
extern void disp_grey(GREY *g);
extern void disp_pol(GREY *g);
extern void disp_diff(GREY *g1, GREY *g2);
extern void disp_mask(GREY *g, GREY *mask);
extern int save_grey(GREY *g, char *fname);
extern int load_grey(GREY *g, char *fname);

/* iir4.c */
extern GREY *filter(GREY *sx, GREY *sy);
extern GREY *gradient(GREY *dx, GREY *dy);
extern GREY *laplacian(GREY *lx, GREY *ly);

/* edge.c */
extern void check_z(GREY *lg);
extern void check_zgr(GREY *lg, GREY *dx, GREY *dy);
extern void check_8connex(GREY *lg);
extern void grlocalsort(GREY *dg, GREY *dx, GREY *dy);
extern void grlocalsort_8c(GREY *dg, GREY *dx, GREY *dy);
extern void histo(GREY *g, long h[]);
extern void recadre_histo(GREY *g, long h[]);

extern EDLIST *chain_edge(GREY *g);

/* dsptools.s */
extern void init_send_factor(void);
extern void send_factor(long *factor, int n);
extern GREY *calc_sx(GREY *g);
extern GREY *calc_sy(GREY *g);
extern GREY *calc_dx(GREY *g);
extern GREY *calc_dy(GREY *g);

/* tools.c */
extern void alert(char *msg, ...);
extern char *file_ext(char *newfn, char *ext, char *fn);
extern void init_dsp(char *lodfname);
extern void free_dsp(void);

#endif

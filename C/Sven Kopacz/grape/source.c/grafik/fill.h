#if  !defined( __FILL__ )
#define __FILL__

#include "layer.h"
#include "mask.h"

typedef struct
{
	/* Pufferinformationen fÅr Fill-Routinen */
	/* Alle Adresse nicht auf 0,0 sondern auf Start X/Y */
	uchar	*c;	/* Cyan-Plane */
	uchar	*m;	/* Magenta-Plane */
	uchar	*y; /* Yellow-Plane */
	uchar	*b; /* Buffer-Zielplane */
	
	uchar	*start_buf; /* Adresse des Puffers an der er mit 0,0
											 der Planes Åbereinstimmt */
											 
	uchar	*obuf; /* Ursprungsadresse des Puffers (fÅr free())*/
	
	int		line;	/* Zeilenbreite */
	
	uchar	cmin; /* Cyan-Vergleichswerte */
	uchar	cmax;	
	uchar mmin;	/* Magenta-Vergleichswerte */
	uchar mmax;
	uchar ymin;	/* Yellow-Vergleichswerte */
	uchar	ymax;
	
	int		rx,ry,rw,rh;	/* Wird von FÅllroutine geliefert=
										 Bereich in dem was passiert ist */
}COM_BUF;

typedef struct
{
	uchar	*c,*m,*y; 		/* Source planes */
	uchar	*mask;				/* Mask plane */
	int		sx,sy,w,h;	/* Square */
	uchar	tol;					/* Toleranz */
}MAG_MASK;

void	fill(int wid);
uchar	*compare_buf(LAYER *lay, MASK *mask, int stx, int sty, int c, int m, int y, int c_tol, int m_tol, int y_tol, int nur_kontur, int *rx, int *ry, int *rw, int *rh, uchar **use_buf);
void	kontur_buf(COM_BUF *cb, int nur_kontur);
void	kontur_buf_mono(COM_BUF *cb, int nur_kontur);
void	kontur(COM_BUF *cb);
void	kontur_mono(COM_BUF *cb);
void	fill_buf(COM_BUF *cbuf);
void	copy_buf_to_dest(uchar *buf, LAYER *lay, MASK *mask, CMY_COLOR *col, int tol, CMY_COLOR *scol, int use_mask, int rx, int ry, int rw, int rh);

void 	magic_mask(int wid);

void	stick(int wid);

#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <vdi.h>
#include <aes.h>
#include <portab.h>

#define EXTERN extern
#include "CKBD.H"
#include "XCONTROL.H"
#include "MOUS_RSC.RH"
#include "MOUS_RSC.H"


#define XSCALE		13.0				/* Display scale */
#define YSCALE		64.0
#define POLYPOINTS 	64					/* StÅtzpunktanzahl */


/* global variables */
extern CPX_PARAMS	*xpcb;

char	pftext1[8], pftext2[8], pftext3[8];


/* internal variables */
int		userhandle;						/* VDI handle */
int		work_in[11]= { 1,1,1,1,1,1,1,1,1,1,2 },
		work_out[57];
int		polyarray[POLYPOINTS+1][2];		/* fÅr v_pline */

double	mat_p[PDEGREE][2]; 				/* work matrices */
double	mat_a[PDEGREE][PDEGREE+1];
double	mat_x[PDEGREE];

/* internal prototypes */
void build_equations(void);
void eliminate(void);
void substitute(void);






/* VDI initialisieren
 * Paramester:	keine
 * Return:		nichts
 * SideEffects: globale var 'userhandle' wird gesetzt
 */
void init_uvdi(void)
{
	userhandle = xpcb->handle;
	v_opnvwk(work_in, &userhandle, work_out);
}


/* VDI Workstation schlieûen
 * Parameter:	keine
 * Return:		keine
 * SideEffects: reset userhandle
 */
void exit_uvdi(void)
{
	v_clsvwk(userhandle);
}


/*
 * Readout editfield & calculate the polynomial factors.
 */
void read_editfield(int *polyfactors)
{
	int		marker_w, marker_h, zy,
			w,h,i;
	double	*mp;
	OBJECT	*tree;
	
	tree = rs_trindex[POLY_ED];
	marker_w = ObW(P_P1)/2;			/* half marker width in pixels */
	marker_h = ObH(P_P1)/2;
	w = ObW(P_EDITFIELD)-ObW(P_P1);
	h = ObH(P_EDITFIELD)-ObH(P_P1);
	zy = ObY(P_ZEROLINE);
	
	/* read marker positions */
	mp = &mat_p[0][0];
	*mp++ = (double)(ObX(P_P1)+marker_w);
	*mp++ = (double)(zy-ObY(P_P1)+marker_h);
	*mp++ = (double)(ObX(P_P2)+marker_w);
	*mp++ = (double)(zy-ObY(P_P2)+marker_h);
	*mp++ = (double)(ObX(P_P3)+marker_w);
	*mp++ = (double)(zy-ObY(P_P3)+marker_h);

	/* convert marker positions into real float data */
	for (i=0; i<PDEGREE; i++)
	{	mat_p[i][0] = (XSCALE*mat_p[i][0])/(double)w;
		mat_p[i][1] = (YSCALE*mat_p[i][1])/(double)h;
	};

	/* calculate the polynomial parameters */
	build_equations(); eliminate(); substitute();

	/* convert into CKBD format */
	for (i=0; i<4; i++) polyfactors[i]=0;
	for (i=0; i<PDEGREE; i++)
		polyfactors[i+(4-PDEGREE)]=(int)(256.0*mat_x[i]);
}


/*
 * polynomfaktoren lesen & setzen
 */
void read_polyfactors(int *polynomial)
{
	OBJECT	*tree;
	
	tree = rs_trindex[POLY_ED];
	polynomial[0] = 0;
	polynomial[1] = atoi(TedText(P_PF3));
	polynomial[2] = atoi(TedText(P_PF2));
	polynomial[3] = atoi(TedText(P_PF1));
}


/*
 * set editfield. Sets the markerpositions if not yet done (internal flag)
 * or if force == TRUE.
 * Texts are always set
 */
void set_editfield(int *polynomial, int force)
{
	static int markerset;
	int		i, k, pts[3][2], *ip,
			marker_w, marker_h, w, h, zy;
	OBJECT	*tree;
	double	x,y;
	
	tree = rs_trindex[POLY_ED];
	TedText(P_PF1) = itoa(polynomial[3], pftext1, 10);
	TedText(P_PF2) = itoa(polynomial[2], pftext2, 10);
	TedText(P_PF3) = itoa(polynomial[1], pftext3, 10);
	pftext1[5]=0; pftext2[5]=0;	pftext3[5]=0;

	if (force==FALSE && markerset==1) return;
	markerset=1;

	marker_w = ObW(P_P1)/2;			marker_h = ObH(P_P1)/2;
	w = ObW(P_EDITFIELD)-ObW(P_P1);	h = ObH(P_EDITFIELD)-ObH(P_P1);
									zy = ObY(P_ZEROLINE);

	/* Markerpositionen berechnen */
	for ( x=XSCALE*0.95, k=0; x>0.01 && k<3; x/=1.1)
	{
		/* compute the x;y pair */
		y=0;
		for (i=0; i<4; i++) y=y*x+polynomial[i];
		y=y*x/256.0;
		
		pts[k][0] =    ((int)(x*w/XSCALE)-marker_w);
		pts[k][1] = zy-((int)(y*h/YSCALE)-marker_h);
		
		if (0<=pts[k][1] && pts[k][1]<=h)
		{	k++; x/=1.45;
		};
	};

	/* Marker setzen */
	ip = (int*)pts;
	ObX(P_P1) = *ip++;		ObY(P_P1) = *ip++;
	ObX(P_P2) = *ip++;		ObY(P_P2) = *ip++;
	ObX(P_P3) = *ip++;		ObY(P_P3) = *ip++;
	
}


/*
 * draw the polynomial into the editfield
 * Note: User VDI must be initialized!
 */
WORD cdecl draw_polynomial(PARMBLK *pb)
{
	int		i,j, field_w, field_h, *polyfactors;
	double	x, y;
	int		xo,yo;
	OBJECT	*tree;
	int		clipper[4], box[4], zero[4];
	
	if (userhandle<=0) return(NORMAL);		/* NO VDI!!! */
	
	tree = rs_trindex[POLY_ED];
	
	/* check: draw only if current state = old state */
	if (pb->pb_prevstate!=pb->pb_currstate)
		return (pb->pb_currstate & ~SELECTED);
	
	field_w = ObW(P_EDITFIELD);	field_h = ObH(P_EDITFIELD);
	polyfactors = *(int**)pb->pb_parm;
	
	box[0] = pb->pb_x-1;	
	box[1] = pb->pb_y-1;
	box[2] = pb->pb_x+pb->pb_w;
	box[3] = pb->pb_y+pb->pb_h;

	/* get pixel offsets */
	xo = box[0]; yo = box[1]+ObY(P_ZEROLINE)+ObH(P_ZEROLINE);
	
	/* Set Clip: */
	clipper[0] = MAX(box[0], pb->pb_xc);
	clipper[1] = MAX(box[1], pb->pb_yc);
	clipper[2] = MIN(box[2], pb->pb_xc+pb->pb_wc-1);
	clipper[3] = MIN(box[3], pb->pb_yc+pb->pb_hc-1);
	vs_clip(userhandle, 1, clipper);

	/* draw box */
	vsf_perimeter(userhandle, 1);		/* visible fill perimeter */
	vsf_color(userhandle, BLACK);
	vsf_interior(userhandle, FIS_HOLLOW);
	v_bar(userhandle, (int *)box);		/* fill rectangle */

	/* draw zeroline */
	zero[0]=xo; zero[1]=yo; zero[2]=xo+field_w; zero[3]=yo;
	vsl_type(userhandle, 3);
	vsl_color(userhandle, BLUE);
	v_pline(userhandle, 2, (int*)zero);
	
	/* calc polyarray */
	for (i=0; i<=POLYPOINTS; i++)
	{
		x = (XSCALE*(double)i)/(double)POLYPOINTS;
		for (j=0, y=0.0; j<4; j++) y=x*y+polyfactors[j];
		y=y*x/256.0;
		polyarray[i][0] = xo + ((double)field_w*i)/(double)POLYPOINTS;
		polyarray[i][1] = yo - ((double)field_h*y)/YSCALE;
		if (polyarray[i][1]<0) polyarray[i][1]=0;
	};
	
	/* draw curve */
	vsl_type(userhandle, 1);
	vsl_color(userhandle, RED);
	v_pline(userhandle, POLYPOINTS, (int *)&polyarray[0]);

	return (pb->pb_currstate & ~SELECTED);
}






/* 
 * Polynomial fit
 *
 * Aufrufe:
 *
 *	mat_p[PDEGREE][2] mit KoordinatenpÑrchen fÅllen
 *		build_equations();			Gleichungssystem aufbauen
 *		eliminate();				Elimination
 *		substitute();				Substitution
 *  mat_x[PDEGREE] auslesen
 */
 
/*
 * Lîsung eines LGS, Eliminationsverfahren nach Gauss.
 */


/***********************************************************************
 * Elimination nach GAUSS, mit Suche nach optimalem Pivot-wert.
 * Quelle: Robert Sedgewick, 'Algorithms'
 * Parameter: size, global: mat_a
 * Voraussetzung: mat_a[size][size+1] ist dimensioniert.
 */
void eliminate(void)
{
	int			i,j,k,max;
	const int	n=PDEGREE;
	double		t;
	
	for (i=0; i<n; i++) {
		max=i;
		for (j=i+1; j<n; j++)
			if (fabs(mat_a[j][i])>fabs(mat_a[max][i])) max=j;
		for (k=i; k<n+1; k++)
		{
			t=mat_a[i][k]; mat_a[i][k]=mat_a[max][k]; mat_a[max][k]=t;
		}
		for (j=i+1; j<n; j++)
			for (k=n; k>=i; k--)
				mat_a[j][k] =
				mat_a[j][k]-mat_a[i][k]*mat_a[j][i]/mat_a[i][i];
	}
}


/***********************************************************************
 * RÅckwÑrtseinsetzen in mat_a, resultate in mat_x
 * Quelle: Robert Sedgewick, 'Algorithms'
 */
void substitute(void)
{
	int			j,k;
	const int	n=PDEGREE;
	double		t;
	
	for (j=n-1; j>=0; j--)
	{
		t=0.0;
		for (k=j+1; k<n; k++)
			t=t+mat_a[j][k]*mat_x[k];
		mat_x[j]=(mat_a[j][n]-t)/mat_a[j][j];
	}
}


/***********************************************************************
 * Aufbau eines LGS zur Ermittlung des Polynoms mit N StÅtzwerten
 * ParameterpÑrchen werden aus mat_p[2][PDEGREE] ausgelesen,
 * Aufbau der mat_a[][] Matrix.
 */
void build_equations(void)
{
	int			i,j;
	const int	n=PDEGREE;
	double		t,u;
	
	for (i=0; i<n; i++) {
		mat_a[i][n]=mat_p[i][1];
		t=u=mat_p[i][0];
		for (j=n-1; j>=0; j--) {
			mat_a[i][j]=t; t*=u;
		}
	}
}


/* eof */

/* Polynom typedef's */

#if  !defined( __PLE__ )
#define __PLE__

typedef struct
{
	double	x1,y1,x2,y2,x3,y3;	/* Koordinaten */
	int			curve_type;					/* 1=konst, 2=line, 3=poly, 4=Freihand */
	int			y[512];							/* Freihandwerte */
}POLYNOM;

typedef struct
{
	POLYNOM	*p1,*p2,*p3;
}POLY_TARGET;


/* Polynom Functions */

void	dial_pledit(int ob);
void	curve_to_free(void);
void	move_point(int ob);
void	free_hand(void);

void	fill_ple(int *pxy);

int		cdecl plgraph(PARMBLK *pblk);
int		cdecl sm_graph(PARMBLK *pblk);


/* Polynom Globvar's */
extern POLYNOM	ple;
extern POLY_TARGET ple_target;

extern OBJECT *opledit;
extern WINDOW wpledit;
extern DINFO  dpledit;
#endif

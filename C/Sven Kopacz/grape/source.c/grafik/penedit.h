#if  !defined( __PENEDIT__ )
#define __PENEDIT__


#include "ple.h"

typedef struct
{
	int	square;		/* Form ist rechteckig */
	int	du;				/* Obenoffset */
	int	dd;				/* Untenoffset */
	int	dl;				/* Linksoffset */
	int	dr;				/* Rechtsoffset */
	int	max;			/* Grîûter Wert davon */
	unsigned char	red[4096];		/* Werte fÅr maximalen Durchlass */
	unsigned char	yellow[4096];	
	unsigned char	blue[4096];	
}TIP;

typedef struct
{
	CMY_COLOR col;/* Zeichenfarbe */
	int	source_lay_id;	/* oder Quellebene */
	
	int	d_type;		/* 0 = normale Malweise, 1 = flow */
								/* 2 = add, 3 = sub */
	
	int	q_opt;		/* !=0: Rechteckoptimierung an */

	int	line;			/* != 0: Punkte verbinden */
	int	step;			/* Schrittweite fÅr Verbindung */
	int	f_speed;	/* Flow-Speed */

	int	verlust;	/* Farbverlust */
	int	wischen;	/* Verwischen */

	TIP	*tip[256];	/* Spitze fÅr jede StrichstÑrke */
}PEN;

typedef struct
{
	int form; 			/*0=eckig, 1=rund*/

	int	d_type;		/* 0 = normale Malweise, 1 = addierend */
								/* 2 = add, 3 = sub */

	POLYNOM	plp;		/* Polynom-Parameter fÅr Stiftgrîûe */
	POLYNOM	plr;		/* Polynom-Parameter fÅr Rot */
	POLYNOM	plg;		/* Polynom-Parameter fÅr GrÅn */
	POLYNOM	plb;		/* Polynom-Parameter fÅr Blau */

	int	verlust;		/* Farbverlust (0-32)*/
	int	wischen;		/* Verwischen (0-32)*/
	int	randhell;		/* Randaufhellung (0-32)*/
	int	rauschen;		/* Rauschen (0-32)*/
	int	rs_bunt;		/* !=0 buntes Rauschen, 0=homogen */
	
	int	q_opt;			/* !=0 Rechteckoptimierung an */
	
	/* Online-Parameter */
	int	col_ok;	/* Bei != 0 col.ryb Åbernehmen */
	int	las_ok;	/* Bei != 0 col.lasur Åbernehmen */
	CMY_COLOR	col;
	/* nur bei > -1 Åbernehmen */
	int	line;
	int	step;
	int	f_speed;
	
	/* Tastatur */
	int	kbs;			/* Umschalttastencode */
	int	kcode;		/* Tastencode */
	
	/* Parameter fÅr Palette */
	int	oicon;			/* Objektnummer des Icons */
	int	om1;				/* Objektnummer des ersten Merkers */
	int	om2;				/* Objektnummer des zweiten Merkers */
	int	okbs;			/* Umschalttaste 0=kein, 1=Alt, 2=Ctrl, 3=Shift */
	char	keyname[4];	/* Name der Taste */
	char	name[16];/* Name des Pens */
	
}PEN_PARAMETER;


/* Pened-Functions*/

void	dial_pened(int ob);
void	init_pened(void);

void	sl_sel_fv(int a);
void	sl_sel_vw(int a);
void	sl_sel_rs(int a);
void	sl_sel_ah(int a);
void	sl_fspeed(int a);

void	make_pen(PEN_PARAMETER *p);


/* Pened Globvars */

extern PEN	pen;
extern PEN_PARAMETER pgp, default_pen;

extern OBJECT *opened;
extern WINDOW wpened;
extern DINFO	dpened;

#endif
/* Typedefs */
typedef unsigned long ulong;
typedef unsigned int  uint;
typedef unsigned char uchar;
typedef unsigned int	PTC;
typedef long PTI;

/* Structures : */
typedef struct
{
	PTC ur_x;
	PTC ur_y;
	PTC ur_w;
	PTC ur_h;
} URECT;

typedef struct
{
	long lr_x;
	long lr_y;
	long lr_w;
	long lr_h;
} LRECT;

typedef struct
{
	struct
	{
		uint pt_exist			:1;
		uint pt_multiuse	:1;
		uint pt_rsvd			:14;
	} pt_state;
	
	PTC pt_x, pt_y;
} POINT;

typedef struct
{
	struct
	{
		uint en_exist		:1;
		uint en_rsvd		:15;
	} en_state;
	
	PTI en_num_point_first;
	PTI en_num_point_last;
} ENTITE;

typedef struct
{
	long fn_zoom;					/* Puissance du zoom dans cette fenetre */
	
	GRECT fn_pwork;				/* Position de la fenetre de travail (pix.) */
	LRECT fn_ulwork;			/* Position de la fenetre de travail (unit‚s) */
} FENETRE;

/* Routines : */
void pixel (FENETRE *fenetre, PTC sx, PTC sy, int *dx, int *dy)
{
	/* Convertit des coord. unit‚s en pixels ‚cran. */
	
	(*dx) = (int)((((long)sx - (long)fenetre->fn_ulwork.lr_x) * 100L / (long)fenetre->fn_zoom) +
					fenetre->fn_pwork.g_x);
	(*dy) = (int) (fenetre->fn_pwork.g_y + fenetre->fn_pwork.g_h - 1 -
					(((long)sy - (long)fenetre->fn_ulwork.lr_y) * 100L / (long)fenetre->fn_zoom));
}

void unite (FENETRE *fenetre, int sx, int sy, PTC *dx, PTC *dy)
{
	/* Convertit des coord. pixels en unit‚s (1/10 mm) */
	
	(*dx) = (PTC)((((long)sx - (long)fenetre->fn_pwork.g_x) * (long)fenetre->fn_zoom / 100L) +
					(long)fenetre->fn_ulwork.lr_x);
	(*dy) = (PTC)((((long)fenetre->fn_pwork.g_y + (long)fenetre->fn_pwork.g_h - 1 - (long)sy) *
					(long)fenetre->fn_zoom / 100L) + (long)fenetre->fn_ulwork.lr_y);
}

void unite_rect (FENETRE *fenetre, GRECT *pr, URECT *ur)
{
	/* Coord. unit‚s d'un rectangle dans une fenetre */
	ur->ur_w = pr->g_w * (long)fenetre->fn_zoom / 100L;	
	ur->ur_h = pr->g_h * (long)fenetre->fn_zoom / 100L;
	unite (fenetre, pr->g_x, pr->g_y + pr->g_h - 1, &ur->ur_x, &ur->ur_y);
}

void pixel_rect (FENETRE *fenetre, URECT *ur, GRECT *pr)
{
	pr->g_w = ur->ur_w * 100L / fenetre->fn_zoom;
	pr->g_h = ur->ur_h * 100L / fenetre->fn_zoom;
	pixel (fenetre, ur->ur_x, ur->ur_y + ur->ur_h, &pr->g_x, &pr->g_y);
}

int inter_grect (GRECT *g1, GRECT *g2)
{
	int tx, ty, tw, th;
	
	/* Inter urect se d‚duit facilement de cette routine. */

	tw = min (g2->g_x + g2->g_w, g1->g_x + g1->g_w);
	th = min (g2->g_y + g2->g_h, g1->g_y + g1->g_h);
	tx = max (g2->g_x, g1->g_x);
	ty = max (g2->g_y, g1->g_y);
	g2->g_x = tx;
	g2->g_y = ty;
	g2->g_w = tw - tx;
	g2->g_h = th - ty;
	return ((tw > tx) && (th > ty));
}

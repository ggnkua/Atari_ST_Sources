#include <stddef.h>
#include <aes.h>
#include <moddef.h>
#include "hilfspal.rsh"

#define otree (&rs_object[0])

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);

int				global[80];

static MODULE_FN mod_fn=
{
	mod_init,
	mod_quit,
	do_function1,
	do_function2
};

static MODULEBLK mblock=
{
	"GRAPEMODULE",
	'0101',
	/* name */
	"1234567890123456789012345678901",

	/* CICONBLK */
	NULL,NULL,NULL,0,0,0,0,0,0,0,0,0,0,0,NULL,
	/* mask_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	/* data_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	/* name */
	0,0,
	/* CICON */
	0,NULL,NULL,NULL,NULL,NULL,
	/* col_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	/* bw_data */
	0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,
	
	0,&mod_fn,
	
	/* Objekt-Tree+Service */
	otree,
	dservice,
	
	/* global */
	NULL,
	/* Grape-Functions */
	NULL,
	/* id */
	0
};

void main(void)
{
	appl_init();
	if(mblock.magic[0])
		form_alert(1,"[3][Ich bin ein Grape-Modul!][Abbruch]");
	appl_exit();
}

void fill_usr_col_ob(OBJECT *tree, int ob, int c, int m, int y)
{
	typedef struct
	{
		int						w; /* Gr”že auf n„chste 16 gerundet */
		long					*table_offset; /* Zeiger auf Offsettabelle fr Zeilen */
		unsigned char	*r, *g,	*b; 	/* Zeiger auf Speicher fr Farbfelder */
	} COL_OB;
	
	typedef struct
	{
		int					type; 	/* 1=Grože Kurve, 2=Kleine Kurve, 3=Farbe */
		COL_OB			color;	/* Nur fr Farbe */
	}U_OB; /* User-Objekt fr User-Defs */
	
	/* Einfacherer Zugriff: */
	#define _UP_ .ob_spec.userblk->ub_parm

	int a, b;

	b=((U_OB*)(tree[ob]_UP_))->color.w*tree[ob].ob_height;
	
	for(a=0; a < b; ++a)
	{
		((U_OB*)(tree[ob]_UP_))->color.r[a]=m;
		((U_OB*)(tree[ob]_UP_))->color.g[a]=y;
		((U_OB*)(tree[ob]_UP_))->color.b[a]=c;
	}
}

void cdecl mod_init(void)
{
	int a;
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];
	
	a=1;
	do
	{
		if((otree[a].ob_type & 255) == G_USERDEF)
			fill_usr_col_ob(otree, a, 0, 0, 0);

	}while(!(otree[a++].ob_flags & LASTOB));
	
}

void cdecl mod_quit(void)
{
}

void cdecl dservice(int ob)
{
}

int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm)
{
	return(0);
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	return(0);
}

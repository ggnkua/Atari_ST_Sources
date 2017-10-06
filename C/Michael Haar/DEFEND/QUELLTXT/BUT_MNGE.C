/*********************************************/
/* BUT_MNGE.C                                */
/* 'Button Manager' zum Verwalten selbstent- */
/* worfener Knîpfe in Resourcen              */
/*                                           */
/* öbersetzt mit Turbo C 2.03                */
/*                                           */
/* von Hans-JÅrgen Richstein                 */
/*     (c)1990 Maxon Computer GmbH           */
/*********************************************/

#include <vdi.h>
#include <aes.h>

/* Die vom 'Button-Design' Editor erzeugten Daten
 und die Struktur SWITCH werden hier eingefÅgt */

#include "switches.btn"

#define RASTERBREITE 16
#define RASTERHOEHE 16
#define RASTER_WORTE 16

#define COL_SET 1
#define COL_RESET 0

/*------ Prototypen -----------*/
void init_buttons(OBJECT *trees[]);
void convert_tree(OBJECT *tree, unsigned int ob);
int find_switch(char pate);
int cdecl draw_procedure(PARMBLK *pb);
/*----------------------*/

extern MFDB screen_mfdb;
extern int handle; /* FÅr die Zeichen- und Raster-*/
MFDB bitmap_mfdb; /* operationen */

/* Hier werden nun die Platzhalter in einem
   String eingetragen und in gleicher Reihenfolge
   folgen die dazugehîrigen User-Blocks */

char paten[] = "xoe3fb"; /* 4 Schalterarten */

USERBLK user_defined[] =
{
	draw_procedure, (long)&Kreuz,
	draw_procedure, (long)&kreis,
	draw_procedure, (long)&Rechteck,
	draw_procedure, (long)&knopf3d,
	draw_procedure, (long)&onoff,
	draw_procedure, (long)&Binaerschalter
};
/*------------------------*/
void init_buttons(OBJECT *trees[])
{
	int i = 0;

	bitmap_mfdb.fd_w = RASTERBREITE;
	bitmap_mfdb.fd_h = RASTERHOEHE;
	bitmap_mfdb.fd_wdwidth = 1;
	bitmap_mfdb.fd_stand = 1;
	bitmap_mfdb.fd_nplanes = 1;
	while(trees[i])
		convert_tree(trees[i++], 0);
}
/*------------------------*/
void convert_tree(OBJECT *tree, unsigned int ob)
{
	/* Durchsucht alle Kinder von 'ob' nach BOXCHARs
	   die als Pate fÅr die neuen Buttons stehen und
	   substituiert diese mit einem Zeiger auf die
	   zugehîrige USERBLK-Struktur */

	static int schalter;
	int akt_child = tree[ob].ob_head;

	while(akt_child != ob)
	{
		if(tree[akt_child].ob_type == G_BOXCHAR)
		{
			schalter = find_switch(tree[akt_child].ob_spec.obspec.character);
			if(schalter >= 0)
			{
				tree[akt_child].ob_type = G_USERDEF;
				tree[akt_child].ob_spec.userblk = &user_defined[schalter];
			}
		}
		if(tree[akt_child].ob_head >= 0)
			convert_tree(tree, akt_child); /* Rekursiv durchhangeln */
		akt_child = tree[akt_child].ob_next;
	}
}
/*----------------------------*/
int find_switch(char pate)
{
	/* Sucht die zu einem Buchstaben gehîrende
	   Schalterstruktur. Liefert -1, wenn fÅr diesen
	   Buchstaben kein Button vorhanden ist. */

	char *cur = paten;
	int ctr = 0;

	while(*cur)
	{
		if(*cur == pate)
			return(ctr);
		cur++;
		ctr++;
	}
	return(-1);
}
/*--------------------------*/
int cdecl draw_procedure(PARMBLK *pb)
{
	/* Dies ist die eigendliche Zeichenroutine */

	int pxy[8], col_index[2];

	col_index[0] = COL_SET;
	col_index[1] = COL_RESET;

	/* Evt. Clipping setzen */
	pxy[0] = pb->pb_xc;
	pxy[1] = pb->pb_yc;
	pxy[2] = pxy[0] + pb->pb_wc - 1;
	pxy[3] = pxy[1] + pb->pb_hc - 1;

	if(pxy[2] || pxy[3])
		vs_clip(handle, 1, pxy);

	if(pb->pb_currstate & OUTLINED) /* Rahmen? */
	{
		pxy[0] = pb->pb_x - 2;
		pxy[1] = pb->pb_y - 2;
		pxy[2] = pxy[0] + RASTERBREITE + 3;
		pxy[3] = pxy[1] + RASTERHOEHE + 3;

		vsl_color(handle, COL_SET);
		vsf_interior(handle, FIS_HOLLOW);
		vsf_perimeter(handle, 1); /* Rand sichtbar */
		v_bar(handle, pxy);
	}
	/* Ein- oder Ausschalter */
	bitmap_mfdb.fd_addr = (char *)((pb->pb_currstate & SELECTED) ? ((SWITCH *)(pb->pb_parm))->on : ((SWITCH *)(pb->pb_parm))->off);

	pxy[0] = pxy[1] = 0; /* Quellrasterkoord. */
	pxy[2] = RASTERBREITE - 1;
	pxy[3] = RASTERHOEHE - 1;

	pxy[4] = pb->pb_x;
	pxy[5] = pb->pb_y;
	pxy[6] = pxy[4] + RASTERBREITE - 1;
	pxy[7] = pxy[5] + RASTERHOEHE - 1;

	v_hide_c(handle); /* Kein AES-Aufruf mîglich, weil schon mitten im AES! */
	vrt_cpyfm(handle, MD_REPLACE, pxy, &bitmap_mfdb, &screen_mfdb, col_index);
	v_show_c(handle, 1);

	return(0);
}
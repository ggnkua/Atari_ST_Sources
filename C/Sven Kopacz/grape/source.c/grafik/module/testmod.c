#include <stddef.h>
#include <aes.h>
#include <moddef.h>

void	mod_init(void);	/* Initialisierung des Moduls */
void	mod_quit(void);	/* Deinitialisierung */
int		do_function1(GRECT *area, LAYER *l, MASK *m);
int		do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area);


int				global[80];

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
	
	mod_init,
	mod_quit,
	do_function1,
	do_function2,
	
	/* Objekt-Tree+Service */
	NULL,
	((void(*)(int ob))0),
	
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

void mod_init(void)
{
	int a;
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];
		
	form_alert(1,"[1][Ich wurde initialisiert!][Goil]");
}

void mod_quit(void)
{
	form_alert(1,"[1][Das war's][Sch”n]");
}

int		do_function1(GRECT *area, LAYER *l, MASK *m)
{
	
	showxy(0,1,area->g_x);
	showxy(0,2,area->g_y);
	showxy(5,1,area->g_w);
	showxy(5,2,area->g_h);

	if(!m)
		form_alert(1,"[1][Das da soll ich in der Ebene machen.][Aha]");
	else
		form_alert(1,"[1][Das da soll ich in der Maske machen.][Oho]");
		
	return(0);
}

int		do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area)
{
	
	showxy(0,1,area->g_x);
	showxy(0,2,area->g_y);
	showxy(5,1,area->g_w);
	showxy(5,2,area->g_h);

	form_alert(1,"[1][Das da soll ich machen.][Aha]");
		
	return(0);
}

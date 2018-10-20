#include <stddef.h>
#include <stdlib.h>
#include <aes.h>
#include <moddef.h>
#include <string.h>
#include "palasist.rsh"
#define X 1
#define Y 2

#define otree (&rs_object[0])

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

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
void	cdecl dservice(int ob);


int		global[80];


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

void cdecl mod_init(void)
{
	int a, b;
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];
	
	/* Down-Buttons nach oben setzen */
	otree[DL1].ob_y=otree[DR1].ob_y=otree[DL2].ob_y=otree[DR2].ob_y-=otree[DR2].ob_height;
	otree[DL3].ob_y=otree[DL4].ob_y-=otree[DL4].ob_height;
	otree[DR3].ob_y=otree[DR4].ob_y-=otree[DR4].ob_height;
	
	/* Untere Reihe nach oben setzen */
	for(a=UP1; a<=COL2; ++a)
		otree[a].ob_y-=otree[a].ob_height/2;	
	
	/* Farbfelder auf weiž-schwarz initialisieren */

	b=((U_OB*)(otree[COL1]_UP_))->color.w*otree[COL1].ob_height;
	
	for(a=0; a < b; ++a)
	{
		((U_OB*)(otree[COL1]_UP_))->color.r[a]=0;
		((U_OB*)(otree[COL1]_UP_))->color.g[a]=0;
		((U_OB*)(otree[COL1]_UP_))->color.b[a]=0;
		((U_OB*)(otree[COL2]_UP_))->color.r[a]=255;
		((U_OB*)(otree[COL2]_UP_))->color.g[a]=255;
		((U_OB*)(otree[COL2]_UP_))->color.b[a]=255;
	}
	
	strcpy(otree[LINE1].ob_spec.tedinfo->te_ptext, "A");
	strcpy(otree[LINE2].ob_spec.tedinfo->te_ptext, "A");
	strcpy(otree[LINE3].ob_spec.tedinfo->te_ptext, "A");
	strcpy(otree[LINE4].ob_spec.tedinfo->te_ptext, "A");
	strcpy(otree[ROW1].ob_spec.tedinfo->te_ptext, "1");
	strcpy(otree[ROW2].ob_spec.tedinfo->te_ptext, "0");
	strcpy(otree[ROW3].ob_spec.tedinfo->te_ptext, "1");
	strcpy(otree[ROW4].ob_spec.tedinfo->te_ptext, "1");
}

void cdecl mod_quit(void)
{
}

void up_line(int ob)
{
	char x=otree[ob].ob_spec.tedinfo->te_ptext[0];
	++x;
	if(x > 'Z') x='A';
	otree[ob].ob_spec.tedinfo->te_ptext[0]=x;
	_G_ d_objc_draw(_ID_, ob);
}
void down_line(int ob)
{
	char x=otree[ob].ob_spec.tedinfo->te_ptext[0];
	--x;
	if(x < 'A') x='Z';
	otree[ob].ob_spec.tedinfo->te_ptext[0]=x;
	_G_ d_objc_draw(_ID_, ob);
}
void up_row(int ob)
{
	char x=otree[ob].ob_spec.tedinfo->te_ptext[0];
	++x;
	if(x > '9') x='0';
	otree[ob].ob_spec.tedinfo->te_ptext[0]=x;
	_G_ d_objc_draw(_ID_, ob);
}
void down_row(int ob)
{
	char x=otree[ob].ob_spec.tedinfo->te_ptext[0];
	--x;
	if(x < '0') x='9';
	otree[ob].ob_spec.tedinfo->te_ptext[0]=x;
	_G_ d_objc_draw(_ID_, ob);
}

void fill_pal(void)
{
	long mc, mm, my, ac, am, ay, steps;
	int	 six, eix, cmy[3], step;
	
	/* Startindex */
	six=(otree[LINE1].ob_spec.tedinfo->te_ptext[0]-'A')*10;
	if(otree[ROW1].ob_spec.tedinfo->te_ptext[0]=='0')
		six+=9;
	else
		six+=otree[ROW1].ob_spec.tedinfo->te_ptext[0]-'1';
	/* Endindex */
	eix=(otree[LINE2].ob_spec.tedinfo->te_ptext[0]-'A')*10;
	if(otree[ROW2].ob_spec.tedinfo->te_ptext[0]=='0')
		eix+=9;
	else
		eix+=otree[ROW2].ob_spec.tedinfo->te_ptext[0]-'1';
	
	steps=eix-six;
	
	if(steps==0)
	{
		cmy[0]=((U_OB*)(otree[COL1]_UP_))->color.b[0];
		cmy[1]=((U_OB*)(otree[COL1]_UP_))->color.r[0];
		cmy[2]=((U_OB*)(otree[COL1]_UP_))->color.g[0];
		_G_ set_pal_col(six, cmy);
		return;
	}
	
	mc=((U_OB*)(otree[COL2]_UP_))->color.b[0];
	mm=((U_OB*)(otree[COL2]_UP_))->color.r[0];
	my=((U_OB*)(otree[COL2]_UP_))->color.g[0];
	mc-=ac=((U_OB*)(otree[COL1]_UP_))->color.b[0];
	mm-=am=((U_OB*)(otree[COL1]_UP_))->color.r[0];
	my-=ay=((U_OB*)(otree[COL1]_UP_))->color.g[0];
	ac*=1024; am*=1024; ay*=1024;	/* Startwerte */
	mc*=1024; mm*=1024; my*=1024;	/* Steigungen */
	if(steps < 0)
	{	mc/=-steps; mm/=-steps; my/=-steps; step=-1;}
	else
	{	mc/=steps; mm/=steps; my/=steps; step=1;}
	
	for(;six!=eix;six+=step)
	{
		cmy[0]=(int)(ac/1024);
		cmy[1]=(int)(am/1024);
		cmy[2]=(int)(ay/1024);
		_G_ set_pal_col(six, cmy);
		ac+=mc; am+=mm; ay+=my;
	}

	/* Endfarbe wegen Rundungsfehlern explizit setzen */
	cmy[0]=((U_OB*)(otree[COL2]_UP_))->color.b[0];
	cmy[1]=((U_OB*)(otree[COL2]_UP_))->color.r[0];
	cmy[2]=((U_OB*)(otree[COL2]_UP_))->color.g[0];
	_G_ set_pal_col(eix, cmy);
}

void copy_line(void)
{
	int	 sl, dl, cmy[3], a;
	
	/* Source-Zeile */
	sl=(otree[LINE3].ob_spec.tedinfo->te_ptext[0]-'A')*10;
	/* Dest-Zeile: */
	dl=(otree[LINE4].ob_spec.tedinfo->te_ptext[0]-'A')*10;

	if(sl==dl) return;
	
	for(a=0; a < 10; ++a)
	{
		_G_ get_pal_col(sl+a, cmy);
		_G_ set_pal_col(dl+a, cmy);
	}
}

void copy_row(void)
{
	int	 sr, dr, cmy[3], a;
	
	/* Source-Spalte */
	sr=otree[ROW3].ob_spec.tedinfo->te_ptext[0]-'1';
	if(sr<0)sr=9;
	/* Dest-Spalte: */
	dr=otree[ROW4].ob_spec.tedinfo->te_ptext[0]-'1';
	if(dr<0)dr=9;

	if(sr==dr) return;
	
	for(a=0; a < 26; ++a)
	{
		_G_ get_pal_col(a*10+sr, cmy);
		_G_ set_pal_col(a*10+dr, cmy);
	}
}

void cdecl dservice(int ob)
{
	switch(ob)
	{
		case UL1:
		case UL2:
		case UL3:
		case UL4:
			up_line(ob-1);
		break;
		case DL1:
		case DL2:
		case DL3:
		case DL4:
			down_line(ob-2);
		break;
		case UR1:
		case UR2:
		case UR3:
		case UR4:
			up_row(ob-1);
		break;
		case DR1:
		case DR2:
		case DR3:
		case DR4:
			down_row(ob-2);
		break;
		case FILL:
			fill_pal();
			_G_ d_unsel(_ID_, FILL);
		break;
		case COPY1:
			copy_line();
			_G_ d_unsel(_ID_, COPY1);
		break;
		case COPY2:
			copy_row();
			_G_ d_unsel(_ID_, COPY2);
	break;
	}
}

int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm)
{
	return(0);
}

int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv)
{
	return(0);
}

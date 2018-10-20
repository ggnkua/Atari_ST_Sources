#include <stddef.h>
#include <aes.h>
#include <moddef.h>
#include <stdlib.h>

void	cdecl mod_init(void);	/* Initialisierung des Moduls */
void	cdecl mod_quit(void);	/* Deinitialisierung */
int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm);
int		cdecl do_function2(uchar *c, uchar *m, uchar *y, int w, int h, GRECT *area, int prv);
int		invert(uchar *pp, int ww, GRECT *area);


int				global[80];

unsigned int c_table[256][3], b_table[256][3];

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
	NULL,
	((void cdecl(*)(int ob))0),
	
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
	int a, r, g, b;
	
	for(a=0; a < 80; ++a)
		_GemParBlk.global[a]=mblock.global[a];

	/* 24->8Bit Table erzeugen */
	/*	n=16+(color.red/51)*36+(color.yellow/51)*6+color.blue/51;*/
	for(r=0; r < 256; ++r)
	{
		c_table[r][0]=(r/51)*36;
		c_table[r][1]=(r/51)*6;
		c_table[r][2]=(r/51);
	}

	/* 8->24Bit Table */
	/* VDI-Farben setzen */
	for(r=5; r > -1; --r)
	{
		for(g=5; g > -1; --g)
		{
			for(b=5; b > -1; --b)
			{
				a=36*r+6*g+b;
				b_table[a][0]=r*51;	/* C */
				b_table[a][1]=b*51; /* M */
				b_table[a][2]=g*51; /* Y */
			}
		}
	}

}

void cdecl mod_quit(void)
{
}

int		cdecl do_function1(GRECT *area, LAYER *l, MASK *mm)
{
	int w, h;
	uchar *c, *m, *y;
	
	w=l->word_width;
	h=l->height;
	
	if(mm)
	{
		c=mm->mask;
		m=y=NULL;
	}
	else
	{
		c=l->blue;
		m=l->red;
		y=l->yellow;
	}
	
	if(c||m||y)
	{
		if(!(_G_ undo_buf(area, l, mm, 1)))
				return(0);/* Undo schlug fehl */
		return(do_function2(c,m,y,w,h,area,-1));
	}
	else
		return(0);
}

int		cdecl do_function2(uchar *cp, uchar *mp, uchar *yp, int w, int h, GRECT *area, int prv)
{
	register uchar *dest, *c, *m, *y;
	register uchar err_tab[256];
	register unsigned int	 err_c, err_x, ix, *blin, *err_lin;
	register long	 sdif;
	register int	 xx, yy, dif_x, dif_y;
	uchar		 *mdst;
	long		 start_offset;

	if((cp==NULL) || (mp==NULL) || (yp==NULL))
	{/* Sinnlos, ist ja schon eine Ebene */
		return(1);
	}

	for(xx=0; xx < 256; ++xx)
		err_tab[xx]=((xx-(xx/51)*51)*3)>>3;	

	start_offset=(long)w*(long)(area->g_y)+(long)(area->g_x);
	c=cp+start_offset;
	m=mp+start_offset;
	y=yp+start_offset;
	
	
	dif_x=area->g_w-1;
	dif_y=area->g_h-1;
	
	sdif=(long)w-(long)dif_x-1;

	blin= calloc((w+1)*2,1);
	if(blin==NULL) return(0);
	mdst=dest= malloc((long)(area->g_w)*(long)(area->g_h));	
	if(dest==NULL) { free(blin); return(0);}

	for(yy=dif_y; yy > -1; --yy)
	{
		err_lin=blin;
		err_c=0;
		for(xx=dif_x; xx > -1; --xx)
		{
			ix=*c++ + err_c + *err_lin;
			if(ix > 255)
			{
				err_x=err_tab[ix-255];
				ix=255;
			}
			else
				err_x=0;
			err_x+=err_tab[ix];
			err_c=err_x+*err_lin/3;
			*err_lin++=err_x;
			
			*dest++=(uchar)(c_table[ix][0]);
		}
		c+=sdif;
	}
	dest=mdst;
	err_lin=blin;
	for(xx=dif_x; xx > -1; --xx)
		*err_lin++=0;
	for(yy=dif_y; yy > -1; --yy)
	{
		err_lin=blin;
		err_c=0;
		for(xx=dif_x; xx > -1; --xx)
		{
			ix=*m++ + err_c + *err_lin;
			if(ix > 255)
			{
				err_x=err_tab[ix-255];
				ix=255;
			}
			else
				err_x=0;
			err_x+=err_tab[ix];
			err_c=err_x+*err_lin/3;
			*err_lin++=err_x;
			
			*dest++ +=(uchar)(c_table[ix][2]);
		}
		m+=sdif;
	}
	dest=mdst;
	err_lin=blin;
	for(xx=dif_x; xx > -1; --xx)
		*err_lin++=0;
	for(yy=dif_y; yy > -1; --yy)
	{
		err_lin=blin;
		err_c=0;
		for(xx=dif_x; xx > -1; --xx)
		{
			ix=*y++ + err_c + *err_lin;
			if(ix > 255)
			{
				err_x=err_tab[ix-255];
				ix=255;
			}
			else
				err_x=0;
			err_x+=err_tab[ix];
			err_c=err_x+*err_lin/3;
			*err_lin++=err_x;
			
			*dest++ +=(uchar)(c_table[ix][1]);
		}
		y+=sdif;
	}

	/* Zurck-Kopieren */

	c=cp+start_offset;
	m=mp+start_offset;
	y=yp+start_offset;
	dest=mdst;
	for(yy=area->g_h; yy > 0; --yy)
	{
		for(xx=area->g_w; xx > 0; --xx)
		{
			*c++=(uchar)(b_table[*dest][0]);
			*m++=(uchar)(b_table[*dest][1]);
			*y++=(uchar)(b_table[*dest++][2]);
		}
		c+=sdif;
		m+=sdif;
		y+=sdif;
	}


	if(prv!=1)
	{/* Palette setzen */
		_G_ set_col_pal(CMY_8, 256, (int*)&(b_table[0][0]));
	}
	
	free(mdst);
	free(blin);
	return(1);
}

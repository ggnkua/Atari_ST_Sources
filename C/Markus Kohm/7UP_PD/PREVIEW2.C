/* Textvorschau (kein Fensterdialog, nicht auto-redraw-f„hig) */
/*****************************************************************************
*
*												7UP
*										Modul: PREVIEW.C
*									  (c) by TheoSoft '91
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <aes.h>
#include <vdi.h>

#include "windows.h"
#include "forms.h"
#include "7UP.H"
#include "alert.h"

#define FF 12
#if GEMDOS
#define HI 16
#else
#define HI 14
#endif
#define LO  8

#define FLAGS15 0x8000

extern int zl,bl,or,kz,fz,ur,lr,zz;
extern int aeshandle,boxh;
extern char alertstr[];

int MAX_SPALT, BLATTHOEHE, BLATTBREITE;

static void set_attr(int handle)
{
	int ret,attr[10];
	
	vswr_mode(handle,MD_REPLACE);			 /* transparent */
	vsm_color(handle,BLACK);
	vsm_type(handle,PM_DOT);
	vsf_color(handle,BLACK);
	vsf_style(handle,1);
	vqt_attributes(aeshandle,attr);
	vst_font(handle,attr[0]);  /* Systemfont einstellen */
	vst_point(handle,8,&ret,&ret,&ret,&ret);
	vst_color(handle,BLACK);
	vst_alignment(handle,0,5,&ret,&ret); /* Ausrichtung */
}

/* ------------------------------------------------------------ */

static void pt_set(int *points, int x, int y)
{
	points[0]=x;
	points[1]=y;
}

/* ------------------------------------------------------------ */

static void set_pixel(int handle, int cx, int cy)
{
	int pxyarray[4];
	pxyarray[0]= cx;
	pxyarray[1]= cy;
	pxyarray[2]= cx;
	pxyarray[3]= cy;
/*
	v_pmarker(handle,1,pxyarray);
*/
	v_pline(handle,2,pxyarray);
}

/* ------------------------------------------------------------ */

static void draw_seite(int handle, int x_pos, int y_pos) /* Ein leeres "Blatt" an der	 */
{
	int x_len=BLATTBREITE,y_len=BLATTHOEHE;
	int points [5][2];

	x_pos=x_pos+1;
	y_pos=y_pos+1;
/*
	vsf_color(handle,BLACK);
*/
	vsf_interior(handle,FIS_SOLID);
	pt_set(points[0],x_pos,y_pos);
	pt_set(points[1],(x_pos+x_len),y_pos);
	pt_set(points[2],(x_pos+x_len),(y_pos+y_len));
	pt_set(points[3],x_pos,(y_pos+y_len));
	pt_set(points[4],x_pos,y_pos);
	v_fillarea(handle,5,points);
	x_pos=x_pos-1;
	y_pos=y_pos-1;
/*
	vsf_style(handle,1);
*/
	vsf_interior(handle,FIS_HOLLOW);
	pt_set(points[0],x_pos,y_pos);
	pt_set(points[1],(x_pos+x_len),y_pos);
	pt_set(points[2],(x_pos+x_len),(y_pos+y_len));
	pt_set(points[3],x_pos,(y_pos+y_len));
	pt_set(points[4],x_pos,y_pos);
	v_fillarea(handle,5,points);
}

static int calc_page(OBJECT *tree, int mx, int my, int maxcol, int maxrow, int box, int maxpage)
{												/* aus Mausposition Seite berechnen */
	int x,y,page=0;
	
	objc_offset(tree,PREVPAGE,&x,&y);
	mx-=x;
	my-=y;
	page+=mx/(tree[PREVPAGE].ob_width/maxcol);
	page+=my/(tree[PREVPAGE].ob_height/maxrow)*maxcol;
	page+=(maxcol*maxrow*box+1);
/*
printf("\33H|%d|%d|",page,maxpage);
*/
	return(page>(maxpage+1)?0:page);
}

/* ------------------------------------------------------------ */
void hndl_preview(WINDOW *wp, OBJECT *tree, LINESTRUCT *begcut, LINESTRUCT *endcut)
{
	LINESTRUCT *line;
	int ret,pxyarray[4];
	register int i,k,m,exit_obj=0;
	long *pagedesc;
	
	int cx,cy;  /* Zeichenposition */
	int px,py;  /* Seitenposition  */
	int mx,my;	/* Mausposition fr Klick */
	
	int zeile=0,
		 spalte=0;
	int col,maxcol,
		 row,maxrow,
		 box,maxbox;
	int page=0;
	long gotoline=0;
	int gotopage=0;
	
	long lines,chars;
	extern int userhandle;
	
	line=wp->fstr;
	Wtxtsize(wp,&lines,&chars);						 /* ganzer Text... */

	if(begcut && endcut)
	{
		line=begcut;
		Wblksize(wp,begcut,endcut,&lines,&chars);  /* ...oder Block */
	}

	if((pagedesc = malloc(lines*sizeof(long)))==NULL)
	{
		form_alert(1,Apreview[1]);
		return;
	}

	BLATTHOEHE=2*bl;
	BLATTBREITE=lr+zl+2;
	MAX_SPALT=BLATTBREITE-lr;

	maxcol=(tree->ob_width-(tree[PREVOK].ob_width+2*24))/(BLATTBREITE+4);  /* Anzahlder Bl„tter */
	maxrow=(tree->ob_height-2*tree[1].ob_height)/(BLATTHOEHE+4); /* Reihen */
	maxbox=(int)(lines%(long)(maxrow*maxcol) ?			 /* Anzahl der Durchg„nge */
			 		 lines/(long)(maxrow*maxcol)+1 :
					 lines/(long)(maxrow*maxcol));

	tree->ob_flags|=FLAGS15; /* kein Fensterdialog */

	tree[PREVPAGE].ob_spec.obspec.framesize=0;
	tree[PREVPAGE].ob_y++; /* ein Pixel tiefer wg. š-Unterstreichung */
	
	form_write(tree,PREVNAME,(char *)Wname(wp),FALSE);
	form_exopen(tree,0);
	graf_mouse(M_OFF,NULL);

	pxyarray[0]=tree->ob_x;
	pxyarray[1]=tree->ob_y;
	pxyarray[2]=tree->ob_x+tree->ob_width-1;
	pxyarray[3]=tree->ob_y+tree->ob_height-1;
	vs_clip(userhandle,TRUE,pxyarray);

	set_attr(userhandle);
	
	px=tree->ob_x+24;  /* Blattpositionen */
	py=tree->ob_y+3*(boxh>8?HI:LO)-1;
	cx=px+lr;			  /* Zeichenpositionen */
	cy=py+2*(or+kz);

	for(box=0, i=0; box<maxbox; box++, i++)
	{
		for(row=0, k=0; row<maxrow; row++, k++)
		{
			for(col=0, m=0; col<maxcol; col++, m++)
			{
				draw_seite(userhandle,px,py);
				pagedesc[page]=gotoline+1;
				for(zeile=0; line && zeile<zz; line=line->next, zeile++)
				{
					gotoline++;
					for(spalte=0; spalte<MAX_SPALT; spalte++)
					{
						switch(line->string[spalte])
						{
							case 0:
								spalte=MAX_SPALT;
								if(((begcut&&endcut) ? line==endcut : !line->next))
								{
									zeile=zz;
									col=maxcol;
									row=maxrow;
									box=maxbox;
								}
								break;
							case FF:
								spalte=MAX_SPALT;
								zeile=zz;
								if(((begcut&&endcut) ? line==endcut : !line->next))
								{
									col=maxcol;
									row=maxrow;
									box=maxbox;
								}
								break;
							case ' ':
								break;
							default:
								set_pixel(userhandle,cx,cy);
								break;
						}
						cx++;
					}
					cx=px+lr;
					cy=cy+2;
				}
				sprintf(alertstr,"%d",++page);
				v_gtext(userhandle,px+1,py+2,alertstr);
				px=px+BLATTBREITE+4;
				cx=px+lr;
				cy=py+2*(or+kz);
			}
			px=tree->ob_x+24;
			py=py+BLATTHOEHE+4;
			cx=px+lr;
			cy=py+2*(or+kz);
		}
		if(box<maxbox)
		{
			graf_mouse(M_ON,NULL);		/* evtl. beeenden */
			do
			{
				exit_obj=form_exdo(tree,0)&0x7FFF;
				switch(exit_obj)
				{
					case PREVPAGE:
						graf_mkstate(&mx,&my,&ret,&ret);
						gotopage=calc_page(tree,mx,my,maxcol,maxrow,box,page-1);
						if(gotopage)
							goto ENDE;
						objc_update(tree,PREVPAGE,0);
						break;
					case PREVHELP:
						form_alert(1,Apreview[0]);
						objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,
							tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
						break;
					case PREVOK:
		 				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,
							tree->ob_width,tree->ob_height,NORMAL,TRUE);
						objc_update(tree,PREVPAGE,0);
						break;
					case PREVABBR:
		 				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,
							tree->ob_width,tree->ob_height,NORMAL,TRUE);
						goto ENDE;
						break;
				}
			}
			while(exit_obj==PREVHELP);
			graf_mouse(M_OFF,NULL);
			px=tree->ob_x+24;  /* Blattpositionen */
			py=tree->ob_y+3*(boxh>8?HI:LO)-1;
			cx=px+lr;			/* Zeichenpositionen */
			cy=py+2*(or+kz);
			pxyarray[0]=tree->ob_x;
			pxyarray[1]=tree->ob_y;
			pxyarray[2]=tree->ob_x+tree->ob_width-1;
			pxyarray[3]=tree->ob_y+tree->ob_height-1;
			vs_clip(userhandle,TRUE,pxyarray);
		
			set_attr(userhandle);
		}
	}
	graf_mouse(M_ON,NULL);
	do
	{
		exit_obj=form_exdo(tree,0)&0x7FFF;
		switch(exit_obj)
		{
			case PREVPAGE:
				graf_mkstate(&mx,&my,&ret,&ret);
				gotopage=calc_page(tree,mx,my,maxcol,maxrow,i-1,page-1);
				if(gotopage)
				  	goto ENDE;
				break;
			case PREVHELP:
				form_alert(1,Apreview[0]);
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,
					tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
				break;
		}
	}
	while(exit_obj==PREVHELP || exit_obj==PREVPAGE);
ENDE:
	form_exclose(tree,exit_obj,0);
	tree[PREVPAGE].ob_y--; /* ein Pixel wieder h”her wg. š-Unterstreichung */
	vs_clip(userhandle,FALSE,pxyarray);
	if(gotopage)
	{
		hndl_goto(wp,NULL,pagedesc[gotopage-1]);
	}
	free(pagedesc);
	return;
}

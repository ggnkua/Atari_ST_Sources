/*
	edge.c
	
*/

#include <stdio.h>
#include <tos.h>
#include <string.h>
#include <math.h>

#include "vector.h"
#include "ptlist.h"

#define SQR(x) pow(x, 2.0)
#define ABS(x) ((x)>0 ? (x) : -(x))


void check_zgr(GREY *lg, GREY *dx, GREY *dy)
{
	int cx, cy;
	BYTE a, b;
	BYTE *l= lg->img, *ll;
	BYTE *x= dx->img, 
	     *y= dy->img;
		
	for(cy= 0; cy < lg->maxy -1; cy++)
	{
		for(cx= 0; cx < lg->maxx -1; cx++, x++, y++)
		{
			if(*l>0)       a=  1;
			else if(*l<0)  a= -1;
			else           a=  0;
			
			ll= l +1;
			if(*ll>0)      b=  1;
			else if(*ll<0) b= -1;
			else           b=  0;
			
			if(a>b && *x<0 || a<b && *x>0)      /* test x */
				*l++= 63;
			else
			{
				ll= l + lg->maxx;
				if(*ll>0)      b=  1;
				else if(*ll<0) b= -1;
				else           b=  0;

				if(a>b && *y<0 || a<b && *y>0)  /* test y */
					*l++= 63;
				else
					*l++= 0;
			}
		}
		*l++= 0;
		x++; y++;
	}
	memset(l, 0, lg->maxx);
}

void check_8connex(GREY *lg)
{
	int cx, cy;
	int c;
	BYTE *l= lg->img,
	     *ll= lg->img;
	
	for(cy= 1, l+= lg->maxx; cy < lg->maxy -1; cy++)
	{
		for(cx= 1, l++; cx < lg->maxx -1; cx++, l++, ll++)
		{
			c= 0;
			if(*ll) c++;
			if(ll[1]) c++; 
			if(ll[2]) c++;
			if(ll[lg->maxx]) c++;
			if(c>1) *l= 0;
		}
		l++;
		ll+= 2;
	}
}

void check_z(GREY *lg)
{
	int cx, cy;
	BYTE *l= lg->img, *ll;
		
	for(cy= 0; cy < lg->maxy -1; cy++)
	{
		for(cx= 0; cx < lg->maxx -1; cx++)
		{
			ll= l +1;
			if(*l>=0 && *ll<0
			|| *l<=0 && *ll>0) /* test x */
				*l++= 63;
			else
			{
				ll= l + lg->maxx;
				if(*l>=0 && *ll<0 
				|| *l<=0 && *ll>0)  /* test y */
					*l++= 63;
				else
					*l++= 0;
			}
		}
		*l++= 0;
	}
	memset(l, 0, lg->maxx);
}

void grlocalsort(GREY *dg, GREY *dx, GREY *dy)
{
	BYTE pix;
	long c;
	BYTE *x= dx->img,
	     *y= dy->img,
	     *i=  dg->img;
	BYTE *sym1, *sym2;
	
	for(c= dg->size; c; c--)
	{
		sym1= sym2= i;
		pix= *x++;
		if(pix>0)		{ sym1++; sym2--; }
		else if(pix<0)	{ sym1--; sym2++; }
		
		pix= *y++;
		if(pix>0)		{ sym1+= dg->maxx; sym2-= dg->maxx; }
		else if(pix<0)	{ sym1-= dg->maxx; sym2+= dg->maxx; }
		
		pix= *i;
		if(sym1!=sym2 && pix>*sym2 && pix>=*sym1) 
			i++;
		else 
			*i++= 0;
	}
}

void grlocalsort_8c(GREY *dg, GREY *dx, GREY *dy)
{
	BYTE px, py;
	long c;
	BYTE *x= dx->img,
	     *y= dy->img,
	     *i=  dg->img;
	BYTE *sym1, *sym2;

	for(c= dg->size; c; c--, i++)
	{
		sym1= sym2= i;
		px= *x++;
		py= *y++;

		if(ABS(px) > ABS(py))
		{
			if(px>0)      { sym1++; sym2--;}
			else if(px<0) { sym1--; sym2++;}
		}
		else
		{
			if(py>0)      { sym1+= dg->maxx; sym2-= dg->maxx;}
			else if(py<0) { sym1-= dg->maxx; sym2+= dg->maxx;}
		}

		px= *i;
		if(sym1==sym2 || px<=*sym2 || px<*sym1)
			*i= 0;
	}
}

void histo(GREY *g, long h[])
{
	int n;
	long c, max;
	BYTE pix;
	BYTE *img;
	UWORD *scr, *screen= Physbase();

	for(c= 0; c<256; c++) h[c]= 0;
	
	img= g->img;
	c= (long) g->maxx * g->maxy;
	for(; c; c--)
	{
		pix= *img++;
		if(pix>=0) h[pix]++;
		else       h[-pix]++;
	}

	for(max= 0, c= 0; c<64; c++)
		if(h[c]>max)
			max= h[c];

	screen+= (long) g->maxx * (g->maxy-1);
	for(c= 0; c<64; c++, screen++)
	{
		n= (int) ((h[c] * (g->maxy*60)) / (100 * max));
		
		scr= screen;
		if(h[c]) *scr= (UWORD) 0x001f;
		else     *scr= (UWORD) 0xffe0;
		for(; n; n--)
		{
			*scr= (UWORD) 0x001f;
			scr-= g->maxx;
		}
	}
	
	for(c=64; c<256; c++, screen++)
	{
		n= (int) h[c];
		
		scr= screen;
		if(h[c]) *scr= (UWORD) 0x0fe0;
		else     *scr= (UWORD) 0xffe0;
		for(; n; n--)
		{
			*scr= (UWORD) 0x0fe0;
			scr-= g->maxx;
		}
	}
}	

void recadre_histo(GREY *g, long h[])
{
	int dn, min, max;
	register int d, e;
	register long c;
	BYTE *i= g->img;
	BYTE ng[64];
	
	for(d= 0; d<64; d++) if(h[d]) break;
	min= d;
	
	for(d= 63; d>=0; d--) if(h[d]) break;
	max= d;
	
	for(d= 0; d<64; d++) ng[d]= 0;
	dn= max-min;

	for(e= 0, d= min; d<=max; d++, e+= 63)
		ng[d]= e/dn;
		
	c= (long) g->maxx * g->maxy;
	for(; c; c--)
		*i++= ng[*i];
}


EDLIST *chain_edge(GREY *g)
{
	int x, y;
	int beg, end;
	unsigned int label= 0;
	UWORD *screen= Physbase();
	BYTE *i= g->img;
	EDLIST *chain= NULL;
	HSEGLIST *hseg, *oldseg= NULL, *seg, *old;
	PTLIST *pt;

	for(y= 0; y < g->maxy; y++)
	{
		*screen= (UWORD) 0xf800;
		screen+= 320L;
		
		hseg= NULL;
		/* construit la liste des hseg */
		for(x= 0; x < g->maxx;)
		{
			while(!*i && x < g->maxx)
			{
				i++; x++;
			}
			if(x>= g->maxx) break;
			
			beg= x; end= x;
			x++; i++;
			while(*i && x < g->maxx)
			{
				end= x;
				i++; x++;
			}
						
			/* ajoute le segment */
			add_hseg(&hseg, create_hseg(beg, end, NULL));
		}
		
		/* recherche la chaine de contour associ‚e … chaque plage */
		seg= hseg; old= oldseg;
		while(seg)
		{
			/* recherche de la plage pr‚cedente */
			while(old && old->end+1 < seg->beg)
				old= old->next;
			
			/* intersection de 2 plages ? */
			if(old && seg && 
			  (old->beg <= seg->beg && old->end >= seg->beg
			|| old->beg <= seg->end && old->end >= seg->end
			|| old->beg >= seg->beg && old->end <= seg->end
			|| old->end+1 == seg->beg
			|| old->beg-1 == seg->end))
			{
				if(seg->edge && seg->edge != old->edge)
				{	/* fusion des 2 contours */
					/* disp_edge(seg->edge->points, old->edge->points); */
					add_ptlist(&seg->edge->points, old->edge->points);
					
					/* destruction de l'ancien contour */
					old->edge->points= NULL;

					/* unifie les autres plages */
					edge_equiv(seg, old, old, hseg);
				}
				else
				{	/* unifier les 2 contours */
					seg->edge= old->edge;
					
					/* inserer les points du segment dans le contour */
					pt= hseg_2_pt(seg, y, 0);
					/* disp_edge(seg->edge->points, pt); */
					add_ptlist(&seg->edge->points, pt);
				}
				
				/* plage suivante */
				if(old->end < seg->end)
					old= old->next;
				else
					seg= seg->next;
			}

			/* pas d'intersection, creation d'un nouveau contour */
			else
			{
				/* contour deja connu -> suivant */
				if(!seg->edge)
				{	/* creation d'un nouveau contour */
					/* inserer les points du segment dans le contour */
					seg->edge= create_ed(hseg_2_pt(seg, y, 0), ++label);

					/* disp_edge(NULL, seg->edge->points); */
					/* chainer le nouveau contour */
					add_ed(&chain, seg->edge);
				}
				seg= seg->next;
			}
		}
		
		/* iteration suivante */
		free_hseg(oldseg);
		oldseg= hseg;
	}	
	
	free_hseg(hseg);
	return chain;
}

void hough(GREY *dx, GREY *dy, EDLIST *chain)
{
	;	
}

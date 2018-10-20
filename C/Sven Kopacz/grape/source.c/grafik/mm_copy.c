#include <grape_h.h>
#include "grape.h"
#include "layer.h"
#include "mask.h"

/* Ebene <> Maske kopieren mit Masken-Beachtung */

void copy_layer_mm(int src, int dst, int how, int mid)
{
 /* Kopiert Ebene src in Ebene dst */
 /* scr und dst sind ID und nicht Nummer in der Liste !! */
 /* how gibt Kopierart an: 0=transparent, 1=deckend, 2=deck. incl weiž */
 /* mid ist die ID der zu beachtenden Maske */
 
	LAYER	*s, *d;
	MASK	*m;
	long		x, y;
 	unsigned char	*sc, *dc, *sr, *dr, *sy, *dy, *sb, *db;
 	unsigned char *sm;
 	register uchar s1, s2, s3, dd, mm, *d_tab;
 	register unsigned int	*m_tab1, *m_tab2, z1, z2, z3;
 	register unsigned int	**m_tabs;
 	m_tabs=mul_adr;
 	d_tab=div_tab;
 	
	s=find_layer_id(src);
	d=find_layer_id(dst);
	m=find_mask_id(mid);
	
	d->changes=1;
	actize_win_name(); 
	switch(how)
	{
		case 0:
		/* Transparent kopieren */
			sc=s->red;
			dc=d->red;
			sm=m->mask;
			for(y=0; y < s->height; ++y)
			{
				for(x=0; x < s->word_width; ++x)
				{
					s1=*sc++; dd=*dc++; mm=*sm++;
					if(s1 < mm)
						s1=0;
					else s1-=mm;
					
					if(dd < s1)
						*(dc-1)=s1;
				}
			}
			sc=s->yellow;
			dc=d->yellow;
			sm=m->mask;
			for(y=0; y < s->height; ++y)
			{
				for(x=0; x < s->word_width; ++x)
				{
					s1=*sc++; dd=*dc++; mm=*sm++;
					if(s1 < mm)
						s1=0;
					else s1-=mm;
					
					if(dd < s1)
						*(dc-1)=s1;
				}
			}
			sc=s->blue;
			dc=d->blue;
			sm=m->mask;
			for(y=0; y < s->height; ++y)
			{
				for(x=0; x < s->word_width; ++x)
				{
					s1=*sc++; dd=*dc++; mm=*sm++;
					if(s1 < mm)
						s1=0;
					else s1-=mm;
					
					if(dd < s1)
						*(dc-1)=s1;
				}
			}
		break;
		case 1:
		/* Deckend kopieren */
			sr=s->red;
			dr=d->red;
			sy=s->yellow;
			dy=d->yellow;
			sb=s->blue;
			db=d->blue;
			sm=m->mask;
			
			for(y=0; y < s->height; ++y)
			{
				for(x=0; x < s->word_width; ++x)
				{
					s1=*sr++; s2=*sy++; s3=*sb++; mm=*sm++;
					if(s1 || s2 || s3)
					{
						m_tab1=m_tabs[mm];
						m_tab2=m_tabs[255-mm];
						z1=m_tab1[s1]; z2=m_tab1[s2]; z3=m_tab1[s3];
						z1+=m_tab2[*dr]; z2+=m_tab2[*dy]; z3+=m_tab2[*db];
						*dr=d_tab[z1];
						*dy=d_tab[z2];
						*db=d_tab[z3];
					}
					++dr; ++dy; ++db;
				}
			}
		break;
		case 2:
		/* Deckend incl. weiž */
			sr=s->red;
			dr=d->red;
			sy=s->yellow;
			dy=d->yellow;
			sb=s->blue;
			db=d->blue;
			sm=m->mask;
			
			for(y=0; y < s->height; ++y)
			{
				for(x=0; x < s->word_width; ++x)
				{
					s1=*sr++; s2=*sy++; s3=*sb++; mm=*sm++;

					m_tab1=m_tabs[mm];
					m_tab2=m_tabs[255-mm];
					z1=m_tab1[s1]; z2=m_tab1[s2]; z3=m_tab1[s3];
					z1+=m_tab2[*dr]; z2+=m_tab2[*dy]; z3+=m_tab2[*db];
					*dr++=d_tab[z1];
					*dy++=d_tab[z2];
					*db++=d_tab[z3];
				}
			}
		break;
	}
	
	if(d->visible)
		redraw_pic();
}

void copy_mask_mm(int sid, int did, int how, int mid)
{
	/* sid=ID der Source-Maske
	   did=ID der Dest-Maske
	   how=Kopierart 0=transparent, 1=deckend, 2=deck. incl weiž
	*/
	
	MASK	*s, *d, *m;
	unsigned char *a, *b, *c;
	long siz;
	register unsigned char ss, dd, mm, *d_tab;
 	register unsigned int	*m_tab1, *m_tab2, z1;
 	register unsigned int	**m_tabs;
 	m_tabs=mul_adr;
 	d_tab=div_tab;
	
	s=find_mask_id(sid);
	d=find_mask_id(did);
	m=find_mask_id(mid);
	
	if(s && d)
	{
		a=s->mask;
		b=d->mask;
		c=m->mask;
		siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
		
		switch(how)
		{
			case 0: /* transparent */
				while(siz--)
				{
					ss=*a++; dd=*b++; mm=*c++;
					
					if(ss > mm)
					{
						ss-=mm;
						if(ss > dd)
							*(b-1)=ss;
					}
				}
			break;
				
			case 1: /* deckend ohne weiž */
				while(siz--)
				{
					ss=*a++; mm=*c++;
					if(ss)
					{
						m_tab1=m_tabs[mm];
						m_tab2=m_tabs[255-mm];
						z1=m_tab1[ss]+m_tab2[*b];
						*b=d_tab[z1];
					}
					++b;
				}
			break;
			
			case 2: /* deckend incl. weiž*/
				while(siz--)
				{
					ss=*a++; mm=*c++;

					m_tab1=m_tabs[mm];
					m_tab2=m_tabs[255-mm];
					z1=m_tab1[ss]+m_tab2[*b];
					*b++=d_tab[z1];
				}
			break;
		}
	}
	
	/* Zielmaske sichtbar? */
	if((act_mask->this.id == d->id) && (otoolbar[MASK_VIS-1].ob_state & SELECTED))
		redraw_pic();
}

void copy_lay_mask_mm(int sid, int did, int how, int mid)
{
	/* sid=ID der Source-Ebene
	   did=ID der Dest-Maske
	   how=Kopierart 0=transparent, 1=deckend, 2=deck. incl weiž
	*/
	
	LAYER	*s;
	MASK	*d, *m;
	unsigned char *a, *r, *g, *b, *sm;
	unsigned int mr,mg,mb,mc,grey;
	long siz;
	register unsigned char *d_tab, mm;
 	register unsigned int	*m_tab1, *m_tab2, z1;
 	register unsigned int	**m_tabs;
 	m_tabs=mul_adr;
 	d_tab=div_tab;
	
	s=find_layer_id(sid);
	d=find_mask_id(did);
	m=find_mask_id(mid);	
	
	if(s && d)
	{
		r=s->red;
		g=s->yellow;
		b=s->blue;
		a=d->mask;
		sm=m->mask;
		
		siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
		
		switch(how)
		{
			case 0: /* transparent */
				while(siz--)
				{
					mr=255-*b;
					mg=255-*r;
					mb=255-*g;
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					grey=(unsigned char)255-mc;
					if(grey > *sm)
					{
						grey-=*sm;
						if(grey > *a)
							*a=grey;
					}

					++a; ++sm;
					++r;++g;++b;
				}
			break;
				
			case 1: /* deckend ohne weiž */
				while(siz--)
				{
					mr=255-*b;
					mg=255-*r;
					mb=255-*g;
					mm=*sm;
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					grey=(unsigned char)255-mc;
					if(grey)
					{
						m_tab1=m_tabs[mm]; m_tab2=m_tabs[255-mm];
						z1=m_tab1[grey]+m_tab2[*a];
						*a=d_tab[z1];
					}
					++a; ++sm;
					++r;++g;++b;
				}
			break;
			
			case 2: /* deckend incl. weiž*/
				while(siz--)
				{
					mr=255-*b++;
					mg=255-*r++;
					mb=255-*g++;
					mm=*sm++;
					/* RGB->Grey Hibyte(77*R+151*G+28*B) */
					mc=77*mr+151*mg+28*mb;
					mc=mc >> 8;
					grey=(unsigned char)255-mc;

					m_tab1=m_tabs[mm]; m_tab2=m_tabs[255-mm];
					z1=m_tab1[grey]+m_tab2[*a];
					*a++=d_tab[z1];
				}
			break;
		}
	}
	/* Zielmaske sichtbar? */
	if((act_mask->this.id == d->id) && (otoolbar[MASK_VIS-1].ob_state & SELECTED))
		redraw_pic();
}

void copy_mask_lay_mm(int sid, int did, int how, int mid)
{
	/* sid=ID der Source-Maske
	   did=ID der Dest-Ebene
	   how=Kopierart 0=transparent, 1=deckend, 2=deck. incl weiž
	*/
	
	MASK	*s, *m;
	LAYER	*d;
	unsigned char *a, *r, *g, *b, *sm;
	unsigned int mr,mg,mb,mc,grey;
	register unsigned char *d_tab, mm, mx;
 	register unsigned int	*m_tab1, *m_tab2, z1, z2;
 	register unsigned int	**m_tabs;
	long siz;
 	m_tabs=mul_adr;
 	d_tab=div_tab;
	
	
	s=find_mask_id(sid);
	d=find_layer_id(did);
	m=find_mask_id(mid);
		
	if(s && d)
	{
		a=s->mask;
		r=d->red;
		g=d->yellow;
		b=d->blue;
		sm=m->mask;
			
		siz=(long)((long)first_lay->this.word_width*(long)first_lay->this.height);
		
		switch(how)
		{
			case 0: /* transparent */
				while(siz--)
				{
					mm=*a;
					if(mm > *sm)
					{
						mm-=*sm;
						mr=255-*b;
						mg=255-*r;
						mb=255-*g;
						/* RGB->Grey Hibyte(77*R+151*G+28*B) */
						mc=77*mr+151*mg+28*mb;
						mc=mc >> 8;
						grey=(unsigned char)255-mc;
						if(mm > grey)
							*r=*g=*b=mm;
					}
					++a; ++sm;
					++r;++g;++b;
				}
			break;
				
			case 1: /* deckend ohne weiž */
				while(siz--)
				{
					mm=*a++;
					mx=*sm++;
					if(mm)
					{
						m_tab1=m_tabs[mx]; m_tab2=m_tabs[255-mx];
						z1=m_tab1[mm];
						z2=z1+m_tab2[*r];
						*r=d_tab[z2];
						z2=z1+m_tab2[*g];
						*g=d_tab[z2];
						z2=z1+m_tab2[*b];
						*b=d_tab[z2];
					}
					++r;++g;++b;
				}
			break;
			
			case 2: /* deckend incl. weiž*/
				while(siz--)
				{
					mm=*a++;
					mx=*sm++;

					m_tab1=m_tabs[mx]; m_tab2=m_tabs[255-mx];
					z1=m_tab1[mm];
					z2=z1+m_tab2[*r];
					*r++=d_tab[z2];
					z2=z1+m_tab2[*g];
					*g++=d_tab[z2];
					z2=z1+m_tab2[*b];
					*b++=d_tab[z2];
				}
			break;
		}
	}

	if(d->visible)
		redraw_pic();
}

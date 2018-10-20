#include "varycopy.h"

extern unsigned char div_tab[131072l];
extern unsigned int *mul_adr[256l];

void cmy_cmy_mask_copy(COPY_DSCR *cd)
{
	register uchar *sc=cd->sc, *sm=cd->sm, *sy=cd->sy; 
	register uchar *dc=cd->dc, *dm=cd->dm, *dy=cd->dy;
	uchar *msk=cd->mask;
	register int dw=cd->dw, mv;
	register int rx, ry;
 	register unsigned char *d_tab;
	register unsigned int	*m_tab, z1, z2, z3;
 	unsigned int	**m_tabs;
	long sdif=cd->sldif, ddif=cd->dldif, mdif=cd->mldif;
 	m_tabs=mul_adr;
 	d_tab=div_tab;

	if((cd->mode & 6)==2)	
	for(ry=cd->dh; ry>0 ; --ry) /* Transparent */
	{	for(rx=cd->dw; rx>0 ; --rx)
		{	mv=*msk++;
			dw=*sc++ -mv;	if(dw < 0) dw=0;
			if(*dc++ < (uchar)dw)
				*(dc-1)=(uchar)dw;
			dw=*sm++ -mv;	if(dw < 0) dw=0;
			if(*dm++ < (uchar)dw)
				*(dm-1)=(uchar)dw;
			dw=*sy++ -mv;	if(dw < 0) dw=0;
			if(*dy++ < (uchar)dw)
				*(dy-1)=(uchar)dw;
		}
		sc+=sdif; sm+=sdif; sy+=sdif; dc+=ddif; dm+=ddif; dy+=ddif; msk+=mdif;
	}
	else if((cd->mode & 6)==4)
	for(ry=cd->dh; ry>0 ; --ry) /* Deckend ohne weiž */
	{	for(rx=dw; rx>0 ; --rx) /* dw wird fr Quellwert mižbraucht */
		{	mv=*msk++;
			if(*sc || *sm || *sy)
			{
				m_tab=m_tabs[mv];
				z1=m_tab[*sc++]; z2=m_tab[*sm++]; z3=m_tab[*sy++];
				m_tab=m_tabs[255-mv];
				z1+=m_tab[*dc]; z2+=m_tab[*dm]; z3+=m_tab[*dy];
				*dc++=d_tab[z1];
				*dm++=d_tab[z2];
				*dy++=d_tab[z3];
			}
			else
			{++sc; ++sm; ++sy; ++dc; ++dm; ++dy;}
		}
		sc+=sdif; sm+=sdif; sy+=sdif; dc+=ddif; dm+=ddif; dy+=ddif; msk+=mdif;
	}
	else for(ry=cd->dh; ry>0 ; --ry) /* Deckend mit weiž */
	{	for(rx=dw; rx>0 ; --rx) /* dw wird fr Quellwert mižbraucht */
		{	mv=*msk++;
			m_tab=m_tabs[mv];
			z1=m_tab[*sc++]; z2=m_tab[*sm++]; z3=m_tab[*sy++];
			m_tab=m_tabs[255-mv];
			z1+=m_tab[*dc]; z2+=m_tab[*dm]; z3+=m_tab[*dy];
			*dc++=d_tab[z1];
			*dm++=d_tab[z2];
			*dy++=d_tab[z3];
		}
		sc+=sdif; sm+=sdif; sy+=sdif; dc+=ddif; dm+=ddif; dy+=ddif; msk+=mdif;
	}
}
void cmy_cmy_copy(COPY_DSCR *cd)
{
	register uchar *sc=cd->sc, *sm=cd->sm, *sy=cd->sy, *dc=cd->dc, *dm=cd->dm, *dy=cd->dy;
	register int dw=cd->dw;
	register long sdif=cd->sldif, ddif=cd->dldif;
	register int rx, ry;

	if((cd->mode & 6)==2)	
	for(ry=cd->dh; ry>0 ; --ry) /* Transparent */
	{	for(rx=dw; rx>0 ; --rx)
		{	if(*dc++ < *sc++)
				*(dc-1)=*(sc-1);
			if(*dm++ < *sm++)
				*(dm-1)=*(sm-1);
			if(*dy++ < *sy++)
				*(dy-1)=*(sy-1);
		}
		sc+=sdif; sm+=sdif; sy+=sdif; dc+=ddif; dm+=ddif; dy+=ddif;
	}
	else if((cd->mode & 6)==4)
	for(ry=cd->dh; ry>0 ; --ry) /* Deckend ohne weiž */
	{	for(rx=dw; rx>0 ; --rx)
		{	if(*sc || *sm || *sy)
			{	*dc++=*sc++; *dm++=*sm++; *dy++=*sy++;}
			else
			{++dc; ++dm; ++dy; sc++; sm++; sy++;}
		}
		sc+=sdif; sm+=sdif; sy+=sdif; dc+=ddif; dm+=ddif; dy+=ddif;
	}
	else for(ry=cd->dh; ry>0 ; --ry) /* Deckend mit weiž */
	{	for(rx=dw; rx>0 ; --rx)
		{	*dc++=*sc++; *dm++=*sm++; *dy++=*sy++;}
		sc+=sdif; sm+=sdif; sy+=sdif; dc+=ddif; dm+=ddif; dy+=ddif;
	}
}
void cmy_g_copy(COPY_DSCR *cd)
{
	register uchar *sc=cd->sc, *sm=cd->sm, *sy=cd->sy, *dc=cd->dc;
	register int dw=cd->dw;
	register long sdif=cd->sldif, ddif=cd->dldif;
	register int rx, ry, mc;
	if((cd->mode & 6)==2)	
	for(ry=cd->dh; ry>0 ; --ry) /* Transparent */
	{	for(rx=dw; rx>0 ; --rx)
		{	/* RGB->Grey Hibyte(77*R+151*G+28*B) */
			mc=77*(255-*sc++)+151*(255-*sm++)+28*(255-*sy++);
			mc=mc >> 8;	mc=255-mc;
			if(*dc++ < (uchar)mc)
				*(dc-1)=(uchar)mc;
		}
		sc+=sdif; sm+=sdif; sy+=sdif; dc+=ddif;
	}
	else if((cd->mode & 6)==4)
	for(ry=cd->dh; ry>0 ; --ry) /* Deckend ohne weiž */
	{	for(rx=dw; rx>0 ; --rx)
		{	/* RGB->Grey Hibyte(77*R+151*G+28*B) */
			mc=77*(255-*sc++)+151*(255-*sm++)+28*(255-*sy++);
			mc=mc >> 8;	mc=255-mc;
			if((uchar)mc)
				*dc++=(uchar)mc;
			else
				++dc;
		}
		sc+=sdif; sm+=sdif; sy+=sdif; dc+=ddif;
	}
	else for(ry=cd->dh; ry>0 ; --ry) /* Deckend mit weiž */
	{	for(rx=dw; rx>0 ; --rx)
		{	/* RGB->Grey Hibyte(77*R+151*G+28*B) */
			mc=77*(255-*sc++)+151*(255-*sm++)+28*(255-*sy++);
			mc=mc >> 8;	mc=255-mc;
			*dc++=(uchar)mc;
		}
		sc+=sdif; sm+=sdif; sy+=sdif; dc+=ddif;
	}
}
void g_cmy_mask_copy(COPY_DSCR *cd)
{
	register uchar *src=cd->sc, *dc=cd->dc, *dm=cd->dm, *dy=cd->dy;
	register uchar *msk=cd->mask;
	register int dw=cd->dw, mv;
	register int rx, ry;
 	register unsigned char *d_tab;
	register unsigned int	*m_tab, z1, z2, z3;
 	register unsigned int	**m_tabs;
	long sdif=cd->sldif, ddif=cd->dldif, mdif=cd->mldif;
 	m_tabs=mul_adr;
 	d_tab=div_tab;

	if((cd->mode & 6)==2)	
	for(ry=cd->dh; ry>0 ; --ry) /* Transparent */
	{	for(rx=dw; rx>0 ; --rx)
		{	mv=*src++;
			mv-=*msk++;
			if(mv < 0) mv=0;
			if(*dc++ < (uchar)mv)
				*(dc-1)=(uchar)mv;
			if(*dm++ < (uchar)mv)
				*(dm-1)=(uchar)mv;
			if(*dy++ < (uchar)mv)
				*(dy-1)=(uchar)mv;
		}
		src+=sdif; dc+=ddif; dm+=ddif; dy+=ddif; msk+=mdif;
	}
	else if((cd->mode & 6)==4)
	for(ry=cd->dh; ry>0 ; --ry) /* Deckend ohne weiž */
	{	for(rx=cd->dw; rx>0 ; --rx) /* dw wird fr Quellwert mižbraucht */
		{	mv=*msk++;
			if((dw=*src++)!=0)
			{
				m_tab=m_tabs[mv];
				z1=m_tab[dw]; z2=m_tab[dw]; z3=m_tab[dw];
				m_tab=m_tabs[255-mv];
				z1+=m_tab[*dc]; z2+=m_tab[*dm]; z3+=m_tab[*dy];
				*dc++=d_tab[z1];
				*dm++=d_tab[z2];
				*dy++=d_tab[z3];
			}
			else
			{++dc; ++dm; ++dy;}
		}
		src+=sdif; dc+=ddif; dm+=ddif; dy+=ddif; msk+=mdif;
	}
	else for(ry=cd->dh; ry>0 ; --ry) /* Deckend mit weiž */
	{	for(rx=cd->dw; rx>0 ; --rx) /* dw wird fr Quellwert mižbraucht */
		{	mv=*msk++;
			dw=*src++;
			m_tab=m_tabs[mv];
			z1=m_tab[dw]; z2=m_tab[dw]; z3=m_tab[dw];
			m_tab=m_tabs[255-mv];
			z1+=m_tab[*dc]; z2+=m_tab[*dm]; z3+=m_tab[*dy];
			*dc++=d_tab[z1];
			*dm++=d_tab[z2];
			*dy++=d_tab[z3];
		}
		src+=sdif; dc+=ddif; dm+=ddif; dy+=ddif; msk+=mdif;
	}
}
void g_cmy_copy(COPY_DSCR *cd)
{
	register uchar *src=cd->sc, *dc=cd->dc, *dm=cd->dm, *dy=cd->dy;
	register int dw=cd->dw;
	register long sdif=cd->sldif, ddif=cd->dldif;
	register int rx, ry;

	if((cd->mode & 6)==2)	
	for(ry=cd->dh; ry>0 ; --ry) /* Transparent */
	{	for(rx=dw; rx>0 ; --rx)
		{	if(*dc++ < *src)
				*(dc-1)=*src;
			if(*dm++ < *src)
				*(dm-1)=*src;
			if(*dy++ < *src++)
				*(dy-1)=*(src-1);
		}
		src+=sdif; dc+=ddif; dm+=ddif; dy+=ddif;
	}
	else if((cd->mode & 6)==4)
	for(ry=cd->dh; ry>0 ; --ry) /* Deckend ohne weiž */
	{	for(rx=dw; rx>0 ; --rx)
		{	if(*src)
				*dc++=*dm++=*dy++=*src++;
			else
			{++dc; ++dm; ++dy; ++src;}
		}
		src+=sdif; dc+=ddif; dm+=ddif; dy+=ddif;
	}
	else for(ry=cd->dh; ry>0 ; --ry) /* Deckend mit weiž */
	{	for(rx=dw; rx>0 ; --rx)
			*dc++=*dm++=*dy++=*src++;
		src+=sdif; dc+=ddif; dm+=ddif; dy+=ddif;
	}
}

void g_g_copy(COPY_DSCR *cd)
{
	register uchar *src=cd->sc, *dst=cd->dc;
	register int dw=cd->dw;
	register long sdif=cd->sldif, ddif=cd->dldif;
	register int rx, ry;

	if((cd->mode & 6)==2)	
	for(ry=cd->dh; ry>0 ; --ry) /* Transparent */
	{	for(rx=dw; rx>0 ; --rx)
		{	if(*dst++ < *src++)
				*(dst-1)=*(src-1);
		}
		src+=sdif; dst+=ddif;
	}
	else if((cd->mode & 6)==4)
	for(ry=cd->dh; ry>0 ; --ry) /* Deckend ohne weiž */
	{	for(rx=dw; rx>0 ; --rx)
		{	if(*src)
				*dst++=*src++;
			else
			{++dst; ++src;}
		}
		src+=sdif; dst+=ddif;
	}
	else for(ry=cd->dh; ry>0 ; --ry) /* Deckend mit weiž */
	{	for(rx=dw; rx>0 ; --rx)
			*dst++=*src++;
		src+=sdif; dst+=ddif;
	}
}

void 	vary_copy(COPY_DSCR *cd)
{
	if(cd->sm)
	{/* CMY-Source */
		if(cd->dm)
		{/* CMY-Dest */
			if(cd->mode & 1)
				cmy_cmy_mask_copy(cd);
			else
				cmy_cmy_copy(cd);
		}
		else
		{/* Mask-Dest */
			cmy_g_copy(cd);
		}
	}
	else
	{/* Grey-Source */
		if(cd->dm)
		{/* CMY-Dest */
			if(cd->mode & 1)
				g_cmy_mask_copy(cd);
			else
				g_cmy_copy(cd);
		}
		else
		{/* Grey-Dest */
			g_g_copy(cd);
		}
	}
}


void	add_masks(uchar *s1, uchar *s2, uchar *ds, long s1dif, long s2dif, long ddif, int w, int h)
{
	/* s1,s2=Startpixel in den Sourcemasken
		ds=Starpixel in Destmaske
		s1dif, s2dif, ddif=Zeilenoffsets in den Ebenen
		w,h=Copy-Rect
	*/
	register uchar	*sr1=s1, *sr2=s2, *dst=ds;
	register long		s1d=s1dif, s2d=s2dif, dld=ddif;
	register int		dw=w, rx, ry, sum;
	
	for(ry=h; ry>0 ; --ry)
	{	for(rx=dw; rx>0 ; --rx)
		{
			sum=*sr1++ + *sr2++;
			if(sum > 255) sum=255;
			*dst++=(uchar)sum;
		}
		sr1+=s1d; sr2+=s2d; dst+=dld;
	}
	
}
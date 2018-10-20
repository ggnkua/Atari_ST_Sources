#include <grape_h.h>
#include "grape.h"
#include "ctcppt.h"

/* Skalierungen */


void scale_three(unsigned char *s1, unsigned char *s2, unsigned char *s3, unsigned char *d1, unsigned char *d2, unsigned char *d3, unsigned char *mask, int sw, int sh, int dw, int dh, long ad_dw, int mode)
{
	/* Kopiert die src-Bereich in die dst-Bereich und skaliert dabei
	   von sw/sh nach dw/dh
	   Åber ad_dw kann ein Zeilenoffset fÅr den Zielbereich 
	   angegeben werden
	   
	   mask:	Adresse von Maske (nicht anfang sondern erstes zu
	          beachtendes Byte)
	          Falls keine Maske dann NULL
	          FÅr Maske wird gleiche Breite (und Zeilenoffset)
	          wie fÅr Ziel benutzt
	          
	   mode: 0=einfach in Ziel schreiben
	   			 1=Status von EinfÅgemodus beachten
	*/
	
	long a, fx, fy, zy;
	register long off, iy, zx, b, ad_lin;
	register unsigned char c, m, y, mv;
	register unsigned char *maske=mask;
	register unsigned char *d_tab;
 	register unsigned int	*m_tab1, *m_tab2, z1, z2, z3;
 	register unsigned int	**m_tabs;
 	m_tabs=mul_adr;
 	d_tab=div_tab;
	
	fy=((long)sh*65536l)/(long)dh;
	fx=((long)sw*65536l)/(long)dw;
	
	ad_lin=dw+ad_dw;

	zy=0;
	
	if(mode)
	{
		if(opmode[PM1].ob_state & SELECTED)
			mode=0;
		else if(opmode[PM2].ob_state & SELECTED)
			mode=1;
		else
			mode=2;
	}
	else
		mode=2; /* Auf deckend mit weiû setzen */

	if(maske)	switch(mode)
	{ /* Skalieren mit Maske */
		case 0:
			for(a=0; a < dh; ++a)
			{
				iy=(zy>>16)*sw;
				zx=0;
				for(b=0; b < dw; ++b)
				{
					off=iy+(zx>>16);
					
					mv=maske[b];
					
					c=s1[off];
					m=s2[off];
					y=s3[off];
					if(c > mv) c-=mv;
					else c=0;
					if(m > mv) m-=mv;
					else m=0;
					if(y > mv) y-=mv;
					else y=0;

					if(c > d1[b])
						d1[b]=c;
					if(m > d2[b])
						d2[b]=m;
					if(y > d3[b])
						d3[b]=y;
					zx+=fx;
				}
				d1+=ad_lin;
				d2+=ad_lin;
				d3+=ad_lin;
				maske+=ad_lin;
				zy+=fy;
			}
		break;
		case 1:
			for(a=0; a < dh; ++a)
			{
				iy=(zy>>16)*sw;
				zx=0;
				for(b=0; b < dw; ++b)
				{
					off=iy+(zx>>16);

					mv=maske[b];

					c=s1[off];
					m=s2[off];
					y=s3[off];
					
					if(c || m || y)
					{
						m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
						z1=m_tab1[c]; z2=m_tab1[m]; z3=m_tab1[y];
						z1+=m_tab2[d1[b]]; z2+=m_tab2[d2[b]]; z3+=m_tab2[d3[b]];
						
						d1[b]=d_tab[z1];
						d2[b]=d_tab[z2];
						d3[b]=d_tab[z3];
					}
					zx+=fx;
				}
				d1+=ad_lin;
				d2+=ad_lin;
				d3+=ad_lin;
				maske+=ad_lin;
				zy+=fy;
			}
		break;
		case 2:
			for(a=0; a < dh; ++a)
			{
				iy=(zy>>16)*sw;
				zx=0;
				for(b=0; b < dw; ++b)
				{
					off=iy+(zx>>16);

					mv=maske[b];

					c=s1[off];
					m=s2[off];
					y=s3[off];
					
					m_tab1=m_tabs[mv]; m_tab2=m_tabs[255-mv];
					z1=m_tab1[c]; z2=m_tab1[m]; z3=m_tab1[y];
					z1+=m_tab2[d1[b]]; z2+=m_tab2[d2[b]]; z3+=m_tab2[d3[b]];
					
					d1[b]=d_tab[z1];
					d2[b]=d_tab[z2];
					d3[b]=d_tab[z3];

					zx+=fx;
				}
				d1+=ad_lin;
				d2+=ad_lin;
				d3+=ad_lin;
				maske+=ad_lin;
				zy+=fy;
			}
		break;
	}

	else switch(mode)

	{
		case 0:
			for(a=0; a < dh; ++a)
			{
				iy=(zy>>16)*sw;
				zx=0;
				for(b=0; b < dw; ++b)
				{
					off=iy+(zx>>16);
					
					c=s1[off];
					m=s2[off];
					y=s3[off];

					if(c > d1[b])
						d1[b]=c;
					if(m > d2[b])
						d2[b]=m;
					if(y > d3[b])
						d3[b]=y;
					zx+=fx;
				}
				d1+=ad_lin;
				d2+=ad_lin;
				d3+=ad_lin;
				zy+=fy;
			}
		break;
		case 1:
			for(a=0; a < dh; ++a)
			{
				iy=(zy>>16)*sw;
				zx=0;
				for(b=0; b < dw; ++b)
				{
					off=iy+(zx>>16);
					
					c=s1[off];
					m=s2[off];
					y=s3[off];

					if(c || m || y)
					{
						d1[b]=c;
						d2[b]=m;
						d3[b]=y;
					}
					zx+=fx;
				}
				d1+=(dw+ad_dw);
				d2+=(dw+ad_dw);
				d3+=(dw+ad_dw);
				zy+=fy;
			}
		break;
		case 2:
			for(a=0; a < dh; ++a)
			{
				iy=(zy>>16)*sw;
				zx=0;
				for(b=0; b < dw; ++b)
				{
					off=iy+(zx>>16);
					
					d1[b]=s1[off];
					d2[b]=s2[off];
					d3[b]=s3[off];

					zx+=fx;
				}
				d1+=ad_lin;
				d2+=ad_lin;
				d3+=ad_lin;
				zy+=fy;
			}
		break;
	}

}


void scale_one(unsigned char *src, unsigned char *dst, int sw, int sh, int dw, int dh, long ad_dw, int mode)
{
	/* Kopiert den src-Bereich in den dst-Bereich und skaliert dabei
	   von sw/sh nach dw/dh
	   Åber ad_dw kann ein Zeilenoffset fÅr den Zielbereich 
	   angegeben werden
	   
	   mode: 0=einfach in Ziel schreiben
	   			 1=Status von EinfÅgemodus beachten
	*/
	
	long a, b, iy, fx, fy, zy, zx;
	unsigned char c;
	
	fy=((long)sh*65536l)/(long)dh;
	fx=((long)sw*65536l)/(long)dw;
	
	zy=0;
	
	if(mode)
	{
			if(opmode[PM1].ob_state & SELECTED)
				mode=0;
			else if(opmode[PM2].ob_state & SELECTED)
				mode=1;
			else
				mode=2;
	}
	else
		mode=2; /* Auf deckend mit weiû setzen */
			
	switch(mode)
	{
		case 0:
			for(a=0; a < dh; ++a)
			{
				iy=(zy>>16)*sw;
				zx=b=0;
				while(b < dw)
				{
					c=src[iy+(zx>>16)];
					if(c > dst[b++])
						dst[b-1]=c;
					zx+=fx;
				}
				dst+=(dw+ad_dw);
				zy+=fy;
			}
		break;
		case 1:
			for(a=0; a < dh; ++a)
			{
				iy=(zy>>16)*sw;
				zx=b=0;
				while(b < dw)
				{
					c=src[iy+(zx>>16)];
					if(c)
						dst[b++]=c;
					else
						++b;
					zx+=fx;
				}
				dst+=(dw+ad_dw);
				zy+=fy;
			}
		break;
		case 2:
			for(a=0; a < dh; ++a)
			{
				iy=(zy>>16)*sw;
				zx=b=0;
				while(b < dw)
				{
					dst[b++]=src[iy+(zx>>16)];
					zx+=fx;
				}
				dst+=(dw+ad_dw);
				zy+=fy;
			}
		break;
	}
}

void simple_scale_one(unsigned char *src, unsigned char *dst, int sw, int sh, int dw, int dh, long ad_dw, long sw_wid, int sx, int sy)
{
	/* Kopiert den src-Bereich in den dst-Bereich und skaliert dabei
	   von sw/sh nach dw/dh
	   Åber ad_dw kann ein Zeilenoffset fÅr den Zielbereich 
	   angegeben werden
	   Auûerdem kann in sw_wid die TatsÑchliche Quellbreite angegeben
	   werden und in sx+sy der Offset in der Quellebene
	   
	   DafÅr gibt es keine mode-Auswahl
	   mode: 0=einfach in Ziel schreiben
	   			 1=Status von EinfÅgemodus beachten
	*/
	
	register long a, b, iy, fx, fy, zy, zx;
	
	fy=((long)sh*65536l)/(long)dh;
	fx=((long)sw*65536l)/(long)dw;
	
	zy=(long)sy*65536l;
	
			
	for(a=0; a < dh; ++a)
	{
		iy=(zy>>16)*sw_wid;
		zx=b=0;
		while(b < dw)
		{
			dst[b++]=src[sx+iy+(zx>>16)];
			zx+=fx;
		}
		dst+=(dw+ad_dw);
		zy+=fy;
	}
}
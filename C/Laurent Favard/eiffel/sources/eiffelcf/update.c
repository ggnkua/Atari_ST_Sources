/*
 *	--------------------------------------------------------------
 *	Eiffel Control Pannel, a setup utility for eiffel interface.
 *
 * 	Author  :	Laurent Favard, Didier Mequignon
 *	Date    :	10 April 2002
 *	Release :   1 Novrembre 2004
 *	Version :	1.10
 *	Country :	FRANCE
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *	--------------------------------------------------------------
 */

#include 	<stdio.h>
#include 	<stdlib.h>
#include	<ext.h>
#include	<string.h>
#include 	<tos.h>

#include 	<PCAads.h>
#include 	"eiffel_g.h"
#include 	"eiffel.h"

extern	int	WHandle;

/*	--------------------------------------------------------------	*/

static unsigned char buf[8192];
unsigned char shift[0x90];
unsigned char altgr[0x90];
unsigned char modifier[0x90];

/*	--------------------------------------------------------------	*/
int lect_hex1(unsigned char car)
{
	int x;
	x=(int)car;
	x-='0';
	if(x<0)
		return(-1);
	if(x<10)
		return(x);
	x-=7;
	if(x<10 || x>15)
		return(-1);
	return(x);
}
/*	--------------------------------------------------------------	*/
int lect_hex(unsigned char *ptr)
{
	int i;
	i=lect_hex1(ptr[0]);
	if(i>=0)
	{
		i<<=4;
		i|=lect_hex1(ptr[1]);
	}
	return(i);
}
/*	--------------------------------------------------------------	*/
long tempo(void)
{
	unsigned long 	start_time;
	
	start_time	=*(unsigned long *)0x4BA;
	while( ((*(unsigned long *)0x4BA) - start_time) <= 2); /* 10 mS */
	return( 0L );
}
/*	--------------------------------------------------------------	*/
void prog_flash(unsigned char *buffer)
{
	int i,j;
	unsigned char sum;
	static unsigned char load[4] = {0x20,0,0,0};
	static unsigned char checksum[1] = {0};
	OBJECT	*Arbre;
	int		x, y, w, h;
	
	rsrc_gaddr( R_TREE, FMAIN, &Arbre );
	W_WorkXYWH( WHandle, &x, &y, &w, &h );
	Arbre[L1].ob_state &= ~SELECTED;
	Arbre[L2].ob_state &= ~SELECTED;
	Arbre[L3].ob_state &= ~SELECTED;
	Arbre[L4].ob_state &= ~SELECTED;
	Arbre[L5].ob_state &= ~SELECTED;
	objc_draw( Arbre, L1, 1, x, y, w, h);
	objc_draw( Arbre, L2, 1, x, y, w, h);
	objc_draw( Arbre, L3, 1, x, y, w, h);
	objc_draw( Arbre, L4, 1, x, y, w, h);
	objc_draw( Arbre, L5, 1, x, y, w, h);
	for(i=0,j=0xD01*2;i<0x90;buffer[j++]=0x34,buffer[j++]=modifier[i++]); /* retlw 0xXX */
	for(i=0,j=0xE01*2;i<0x90;buffer[j++]=0x34,buffer[j++]=shift[i++]); /* retlw 0xXX */
	for(i=0,j=0xF01*2;i<0x90;buffer[j++]=0x34,buffer[j++]=altgr[i++]); /* retlw 0xXX */
	for(sum=0,i=0;i<8192;sum+=buffer[i++]);
	Ikbdws(3,load);
	for(i=0;i<200;Supexec(tempo),i++);	
	for(i=0;i<4096;i++)
	{
		Ikbdws(1,buffer);
		if(i&2)
			Supexec(tempo); /* after 4 bytes */
		if(i==(4096*1)/5)
		{
			Arbre[L1].ob_state |= SELECTED;
			objc_draw( Arbre, L1, 1, x, y, w, h);
		}
		if(i==(4096*2)/5)
		{
			Arbre[L2].ob_state |= SELECTED;
			objc_draw( Arbre, L2, 1, x, y, w, h);
		}
		if(i==(4096*3)/5)
		{
			Arbre[L3].ob_state |= SELECTED;
			objc_draw( Arbre, L3, 1, x, y, w, h);
		}
		if(i==(4096*4)/5)
		{
			Arbre[L4].ob_state |= SELECTED;
			objc_draw( Arbre, L4, 1, x, y, w, h);
		}
		buffer+=2;
	}
	*checksum=sum;
	Ikbdws(0,checksum);
	Supexec(tempo);
	Arbre[L5].ob_state |= SELECTED;
	objc_draw( Arbre, L5, 1, x, y, w, h);
}
/*	--------------------------------------------------------------	*/
void UpdateEiffel( const char *aPath )
{
	int 					i, handle, size;
	long 					longueur, offset;
	void 					*buffer;
	unsigned char 			*ptr, *ptr2;

	if( ( handle=Fopen( aPath, 0) ) < 0 )
		form_error(-handle-31);
	else
	{
		if ((longueur=Fseek(0L,handle,2))>=0)
		{
			Fseek(0L,handle,0);
			if ((buffer=Malloc(longueur))<0)
				form_error(-(int)buffer-31);
			else
			{
				if (Fread(handle,longueur,buffer)<0) /* lecture du .HEX */
					form_error(-handle-31);
				else
				{
					for(i=0;i<8192;buf[i++]=0x3F,buf[i++]=0xFF);
					ptr=(unsigned char *)buffer;
					while(*ptr++ == ':')
					{
						size=lect_hex(ptr); ptr+=2;
						if(size<0 || (size & 1 ))
							break;
						size >>= 1; 								/* taille en mots */
						offset=(long)lect_hex(ptr); ptr+=2;
						if(offset<0)
							break;	
						offset <<= 8;
						i=lect_hex(ptr); ptr+=2;
						if(i<0)
							break;
						offset |= (long)i;
						i=lect_hex(ptr); ptr+=2;
						if(i<0)
							break;
						if(offset >= 0x2000L)
						{
							prog_flash(buf);
							break;	
						}
						ptr2=buf+offset;
						i=0;
						while(ptr < (unsigned char *)buffer+longueur && size>0)
						{
							i=lect_hex(ptr); ptr+=2;
							if(i<0)
								break;
							ptr2[1]=(unsigned char)i;				/* poids faible */
							i=lect_hex(ptr); ptr+=2;
							if(i<0)
								break;
							ptr2[0]=(unsigned char)i; 				/* poids fort */
							ptr2+=2;	
								size--;
						}
						if(ptr >= (unsigned char *)buffer+longueur)
						{
							prog_flash(buf);
							break;	
						}
						if(i<0)
							break;
						i=lect_hex(ptr); ptr+=2; /* checksum ligne HEX */
						if(i<0)
							break;
						while((ptr < (unsigned char *)buffer+longueur) && (*ptr==13 || *ptr==10))
							ptr++;
						if(ptr >= (unsigned char *)buffer+longueur)
						{
							prog_flash(buf);
							break;	
						}
					}
				}
				Mfree(buffer);
			}
			Fclose(handle);
		}
	}
}
/*	--------------------------------------------------------------	*/
void ChangeTable( const char *aPath, unsigned char *table )
{
	int 					handle,val;
	long 					longueur, offset;
	void 					*buffer;
	unsigned char 			*ptr;

	if( ( handle=Fopen( aPath, 0) ) < 0 )
		form_error(-handle-31);
	else
	{
		if ((longueur=Fseek(0L,handle,2))>=0)
		{
			Fseek(0L,handle,0);
			if ((buffer=Malloc(longueur))<0)
				form_error(-(int)buffer-31);
			else
			{
				if (Fread(handle,longueur,buffer)<0) /* lecture du .INF */
					form_error(-handle-31);
				else
				{
					offset=0;
					ptr=(unsigned char *)buffer;
					do
					{
						if(*ptr++ == ':') 
						{
							val=lect_hex(ptr);
							if(val>=0)
							{ 
								table[offset++]=val;
								ptr+=2;
							}
						}
					}
					while(offset<0x90 && (ptr < (unsigned char *)buffer+longueur));
				}
				Mfree(buffer);
			}
			Fclose(handle);
		}
	}
}
/*	--------------------------------------------------------------	*/
COOKIE *fcookie(void)
{
	COOKIE *p;
	long stack;
	stack=Super(0L);
	p=*(COOKIE **)0x5a0;
	Super((void *)stack);
	if(!p)
		return((COOKIE *)0);
	return(p);
}
/*	--------------------------------------------------------------	*/
COOKIE *ncookie(COOKIE *p)
{
	if(!p->ident)
		return(0);
	return(++p);
}
/*	--------------------------------------------------------------	*/
COOKIE *get_cookie(long id)
{
	COOKIE *p;
	p=fcookie();
	while(p)
	{
		if(p->ident==id)
			return p;
		p=ncookie(p);
	}
	return((COOKIE *)0);
}
/*	--------------------------------------------------------------	*/

#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"

#include "globals.h"


	unsigned getbyte();

	char str2[80],str3[80];
	char twoblanks[5]="  ";

/*		Display one window full of data.       */

one_page(thewin, blank) /* draw one window full of data */
	windowptr	thewin;
	int			blank;
{	int i, nc;

	wr_ins_rpl(ins); /* input status written upper rt.  see keys.c */

	graf_mouse(M_OFF, 0L);
	nc = (thewin->work.g_h/gl_hchar)*16;  /* nc is number of char */
	if(partial)
	{	nc = nc - (thewin->position - thewin->topchar ) + 16;
		for(i=0;i<nc;i+=16)
			one_line0(thewin,thewin->position+i);
			partial = FALSE;
	}
	else
	{
		wind_blank(thewin);
		for(i=0;i<nc;i+=16)
			one_line0(thewin,thewin->topchar+i);
	}
		graf_mouse(M_ON, 0L);

}


unsigned getbyte(thewin,pos) /* retreive any byte in file in ram */
	windowptr thewin;
	long pos;
{	
	linkbufptr amem;
	char *addr;
    
    if (pos<thewin->flen)
	{	amem = thewin->headptr;
		while (amem->inuse<=pos)
			{	pos = pos - amem->inuse;
				amem = amem->next;
			}
		addr = (char *)(amem->block+pos);
		return(*addr);
	}
	else return((unsigned)0x00);
}

putbyte(thewin,pos,lnum) /* put byte lnum into file at pos */
	windowptr	thewin;
	long	pos, lnum;
{
	linkbufptr amem;
	char *addr;
    
    if (pos<thewin->flen)
	{	amem = thewin->headptr;
		while (amem->inuse<=pos)
			{	pos = pos - amem->inuse;
				amem = amem->next;
			}
		addr = (char *)(amem->block+pos);
		*addr = (char)lnum;
		thewin->changed = TRUE;
	}
}


one_line0(thewin,pos)
	windowptr	thewin;
	long 		pos;
{
	long l;

	l = pos&~0xf;
	if( (l > thewin->endmark) || ((l+16) < thewin->startmark) )
		one_line1(thewin,pos);
	else
		one_line2(thewin,pos);

}

one_line2(thewin,pos)	/* handles mixed marked and unmarked */
	windowptr	thewin;
	long 		pos;

{	int i, lineno;
	int			tx, ty;
	int			grafhandle;
	long  l;
	unsigned num;
	register int j,k;
	char *ptr3;

	tx = thewin -> work.g_x + 7;
	ty = thewin -> work.g_y + gl_hchar;
	grafhandle = thewin -> graf.handle;


	lineno = (pos - thewin->topchar)>>4;
	ty += (gl_hchar*lineno);
			l = pos&~0xf;
			ptr3=str3;
			str2[2] = '\0';
		for (j=0; j < 16 ; j +=2 )
         {  for (k=0; k < 2  ; k++   )
			{	if(l+j+k < thewin->flen-1)
				{	num = getbyte(thewin,l + j + k);
					if(num)
						*(ptr3++) = num;
					else
						*(ptr3++) = (unsigned)32;
					bcopy(table+num*2,str2,2);
					if( (l+j+k>=thewin->startmark) && (l+j+k<=thewin->endmark) )
						vswr_mode(thewin->graf.handle,4);
					else
						vswr_mode(thewin->graf.handle,1);
				}
				else
				{	bcopy(twoblanks,str2,3);
					*(ptr3++) = (unsigned)32;
				}
						v_gtext(grafhandle, tx, ty, str2);
					tx += 2*gl_wchar;
			}		
					vswr_mode(thewin->graf.handle,1);
					bcopy(twoblanks,str2,3);
					v_gtext(grafhandle, tx, ty, str2);
					tx += 2*gl_wchar;
		}
				*(ptr3++)=0x0;
				vswr_mode(thewin->graf.handle,1);
				v_gtext(thewin->graf.handle, tx, ty, str3);
}

one_line1(thewin,pos)	/* handles unmarked text	*/
	windowptr	thewin;
	long 		pos;

{	int i, lineno;
	int			tx, ty;
	int			grafhandle;
	long  l;
	unsigned num;
	register int j,k;
	char *ptr2,*ptr3;

	tx = thewin -> work.g_x + 7;
	ty = thewin -> work.g_y + gl_hchar;

	lineno = (pos - thewin->topchar)>>4;
	ty += (gl_hchar*lineno);
			l = pos&~0xf;
			ptr2 = str2;
			ptr3 = str3;

	           for (j=0; j < 16 ; j +=2 )
          {  for (k=0; k < 2  ; k++   )
            {	num = getbyte(thewin,l + j + k);
            	if(l+j+k < thewin->flen-1)
				{
					if(num)
						*(ptr3++) = num;
					else
						*(ptr3++) = (unsigned)32;
					bcopy(table+num*2,ptr2,2);
					ptr2+=2;
				}
				else
				{	bcopy(twoblanks,ptr2,2);
					ptr2+=2;
					*(ptr3++) = 0x20;
				}
             }
				*(ptr2++)=0x20;
				*(ptr2++)=0x20;
           }   
				*(ptr2++)=0x20;
				*(ptr2++)=0x20;
				*(ptr2++)=0x0;
				v_gtext(thewin->graf.handle, tx, ty, str2);
				tx += 48*gl_wchar; 
				*(ptr3++)=0x0;
				v_gtext(thewin->graf.handle, tx, ty,str3);
}


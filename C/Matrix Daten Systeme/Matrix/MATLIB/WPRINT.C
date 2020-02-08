#include <vdi.h>
#include <aes.h>
#include <stdio.h>

#include <global.h>

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"
# include "wprint.h"


POINT cursor = { 0, 0 } ;

# define NUL '\0'
# define CR  '\x0d'
# define LF	 '\x0a'
# define ESC '\x1b'

/* ???? */
extern void filled_box(int color, int x, int y, int dx, int dy);

/*--------------------------------------------- v_printf -----*/
int v_printf(int handle, int x, int y, const char *format, ... )

{
	int length ;
	char buffer[256] ;
	
	length = vsprintf(buffer, format, ... );
	
	vst_color ( handle, BLUE ) ;
	v_gtext ( handle, x, y, buffer );
	return ( length ) ;
}


 # define chk_out() \
 		 if(op>obuffer) {\
 		 	*op = NUL ;\
			v_gtext ( vdi_handle, work->x+cursor.x*hwchar,\
						  work->y+(cursor.y+1)*hhchar,\
						  obuffer );\
			cursor.x += (int)(op - obuffer) ;\
			op = obuffer ; }
			

/*--------------------------------------------- w_printf -----*/
int w_printf( RECTangle *work, const char *format, ... )

{
	int length ;
	char ibuffer[256] ;
	char obuffer[256] ;
	char c,*ip,*op;
	
	length = vsprintf ( ibuffer, format, ... );

	ip = ibuffer ;
	op = obuffer ;

	for(;;)
	{
		switch(c = *ip++)
		{
 case CR :	chk_out();			/* return */
		  	cursor.x = 0 ;
			break ;

 case LF :	chk_out();			/* new line */
		  	cursor.x  = 0 ;
		  	cursor.y += 1 ;
			break ;

 case ESC :	switch(c = *ip++)
  			{
	case 'E' :	filled_box ( WHITE, VALrect(*work) ) ;
				cursor.x  = 0 ;		/* clear screen */
			  	cursor.y  = 0 ;
				break ;

	case 'H' : 	chk_out();			/* home */
		  		cursor.x  = 0 ;
			  	cursor.y  = 0 ;
				break ;
				
	default :	*op++ = ESC ;
			 	*op++ = c ;
			 	break ;
			}
			break ;

case NUL :	chk_out();			/* eos */
			return ( length ) ;

default :	*op++ = c ;
		 	break ;
		}
	}
}

/*-------------------------------------------- set_line_attr --------*/
void dis_text ( int color, int x, int y, char *s )
{
	vst_color(vdi_handle,color);
	v_gtext(vdi_handle,x,y,s);
}


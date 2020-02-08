#include	<stdlib.h>
#include	<stdio.h>
#include	<string.h>
#include	<tos.h>

# if 1
#include	<vdi.h>		/* needed only for MFDB declaration in jpgdh.h */
#include	"jpgdh.h"
# else
# ifndef __JPGDH__
typedef void *JPGD_PTR;
# endif
# endif

#include 	"if.h"

#define	unused(x)	(x)=(x)

extern int printfnl ( const char *format, ... ) ;

TPrintfProc uprintf = printfnl ;

/*------------------------------------------------------ printfnl --------*/
int printfnl ( const char *format, ... )
{
	int l ;
	
	l = vprintf ( format, (va_list)... ) ;
	l += printf ( "\n" ) ;

	return l ;
}

/*------------------------------------------------------ UserRoutine -----*/
short UserRoutine ( JPGD_PTR jpgd )
{
	unused(jpgd);
	if ( ( ++(jpgd->User[0]) % 32 ) == 0 )
	{
		Cconout('\r');
		Cconout('\n');
	}
	Cconout('.');
	return 0 ;
}


/*------------------------------------------------------ main ----*/
int main ( short argc, char **argv )
{
	ERROR	err;

	switch ( argc )
	{
  case 3 :	err = JpegDecodeToFile ( argv[1], argv[2], RGBout, Bpp24 ) ;
  			break ;
  case 4 :
  case 2 :	{
			  	long outsize ;
	  			MFDB mfdb ;
	  			
				err = JpegDecodeToMemory ( argv[1], RGBout, Bpp24, &mfdb, &outsize ) ;
				if ( err == OK )
				{
					printf ( "mfdb = $%p - %d:%d,  ww=%d, std=%d, planes=%d\n",
										mfdb.fd_addr,
										mfdb.fd_w,
										mfdb.fd_h,
										mfdb.fd_wdwidth,
										mfdb.fd_nplanes ) ;
		
					free ( mfdb.fd_addr ) ;
				}
			}
			break ;
  default :	printf ( "usage : if.ttp source.jpg [ destination.tga ]\n" ) ;
  			break ;
	}
		
  	printf ( "- press any key !\n" ) ;
	Crawcin();

	return err ;
}

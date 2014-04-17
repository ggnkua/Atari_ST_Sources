/*	NEWGLUE.C	12/21/87		Derek Mui	*/

#include <osbind.h>

#define	 RSH_SIZE  17
#define	 TRUE	1
#define	 FALSE  0
#define  HEADSIZE 12


long	address, size, totalsize;
char	buffer1[16];		/* input buffer    */
char	buffer2[16];		/* filename buffer */
int	handle, i, j;
long	out;
long	top, memory;
char	*chrptr;
int	*header;
unsigned int	*intptr;


#define TOTALFILE	4


char	*files[TOTALFILE] =
{ 
	"GEMXXX.RSC" ,
	"DESKXXX.RSC",
	"DESKXXX.INF",
	"GLUE.XXX"
};

int	space[TOTALFILE] = { 3,4,4,5 };

char	exitstr[] = "EXIT";


main()
{
char	keyin;
char	*outfile;


	outfile = files[TOTALFILE-1];	

	totalsize = Malloc( 0xFFFFFFFFL );	/* get all the memory */
	if ( !totalsize )
	{
	  Cconws( "No memory !\012\015" );
	  return;
	}	
	
	totalsize -= 0x4000L;			/* minus 16k */
	top = Malloc( totalsize );


	Cconws( "\012\015New Resource Glue\012\015" );
	Cconws( "Atari Corp.   2/28/90\012\015" );
	Cconws( "Please type in a three-letter abbrevation of the\012\015" );
	Cconws( "country or hit escape key to quit.\012\015\012" );

	while( TRUE )
	{
start:
	  header = top;				/* header adrea	*/
	  memory = totalsize - HEADSIZE;
	  address = top + HEADSIZE;			
	  size = 0;

	  Cconws( ">" );

	  buffer1[0] = 5;
	  Cconrs( &buffer1[0] );
	  buffer1[ buffer1[1] + 2 ] = 0;
	  Cconws( "\012\015" );

	  out = TRUE;

	  for ( i = 0; i < 4; i++ )		/* exit  ?  */
	  {
	    if ( exitstr[i] != ( buffer1[i+2] & 0xdf ) )
	    {
	      out = FALSE;
	      break;
	    }
	  }

	  if ( out )
	    goto bad;
	     
	  for ( i = 0; i < TOTALFILE; i++ )
	  {
	     chrptr = files[i];
	     chrptr += space[i];
	     for ( j = 2; j < 5; j++ )
		*chrptr++ = ( buffer1[j] & 0xdf );
	  }
		
	  for ( i = 0; i < (TOTALFILE - 1); i++ )	/* three files */
	  {
	    memory -= size; 	

	    handle = Fopen( files[i], 0 );	/* open source file */
	    if ( handle < 0 )
	    {
	      Cconws( files[i] );
	      Cconws( " not found\012\015" );
	      goto start;
	    }
		
	    Cconws( "Reading " );
	    Cconws( files[i] );
	    Cconws( "\012\015" );

	    size = Fread( handle, memory, address );
	    Fclose( handle );

#if 0
	    if ( ( !i )||( i == 1 ) )
	    {
	      intptr = address;
	      intptr += RSH_SIZE;		/* get the size  */
	      size = (long)(*intptr);
	    }
#endif

	    if ( size & 0x1 )			/* on the odd boundary */
	      size += 5;
	    else
	      size += 4;

	    if ( memory <= size )
	    {
	      Cconws( "Not enough memory\012\015" );
	      goto bad;
	    }
							
						/* fill in header */
	    header[i] = (int)(address - top - 2);

	    address += size;
	  }

	  header[i] = (int)(address - top); 

	  Fdelete( outfile );			/* open output file */
	  handle = Fcreate( outfile, 0 );
	  if ( handle < 0 )
	  {
	    Cconws( "Can not create " );
	    Cconws( outfile );
	    Cconws( "\012\015" );
	    goto bad;
	  }

	  size = address - top;
		
	  Cconws( "Writing " );
	  Cconws( outfile );				/* i = 5 */
	  Cconws( "\012\015" );
	
	  memory = Fwrite( handle, size, top+2 );
	  Fclose( handle );
	  if ( size != memory )
	  {
	    Cconws( "Write error in output file\012\015" );
            goto bad;
	  }

	  out = size;	
	  i = 0;
	  do
	  {
	     j = out % 16;
             if ( j <= 9 )
	       buffer1[i++] = j + '0';
	     else
	       buffer1[i++] = j + 0x37;

	  }while( ( out /= 16 ) > 0 );

	  for ( i--,j = 0; i >= 0; j++,i-- )
	    buffer2[j] = buffer1[i];

	  buffer2[j] = 0;

	  Cconws( "File size is $" );
	  Cconws( &buffer2[0] );
	  Cconws( "\012\015Done.\012\015" );
	}

bad:
	Mfree( top );
	return;
}

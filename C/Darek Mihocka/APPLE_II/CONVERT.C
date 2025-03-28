
/***********************************************************************
*                                                                      *
* CONVERT.C - by Darek Mihocka  December 14, 1986                      *
*                                                                      *
* This program converts a Apple monitor hex dump into a Atari DOS 2.0  *
* formatted file for use with the Apple Emulator.                      *
*                                                                      *
* Specify a source file which contains a hex dump and a destination    *
* file ending in .BIN which will be the binary file.                   *
*                                                                      *
* Note: binary file generated should be loaded and resaved with the    *
*       emulator to adjust file length.                                *
*                                                                      *
***********************************************************************/

#include <stdio.h>
#include <osbind.h>
#include <string.h>

main (argc,argv)
int argc ;
char *argv[] ;
 {

  FILE *source, *dest ;
  unsigned int hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7 ;
  unsigned int addr ;
  int error ;

  printf ("now converting ... %s to %s\n",argv[1],argv[2]) ;
  source = fopen (argv[1],"r") ;
  dest = fopen (argv[2],"bw") ;

  error = fscanf (source,
           " %x- %x %x %x %x %x %x %x %x ",
          &addr, &hex0, &hex1, &hex2, &hex3, &hex4, &hex5, &hex6, &hex7) ;


  putc (255,dest) ;     /* DOS 2.0 header */
  putc (255,dest) ;
  putc (addr&255,dest) ;
  putc (addr>>8,dest) ;
  putc (255,dest) ;
  putc (255,dest) ;

  do {

       if (error==9) printf (" %4x",addr) ;
       else printf ("ERROR!!!!\n %4x",addr) ;

       putc ((char)hex0,dest) ;
       putc ((char)hex1,dest) ;
       putc ((char)hex2,dest) ;
       putc ((char)hex3,dest) ;
       putc ((char)hex4,dest) ;
       putc ((char)hex5,dest) ;
       putc ((char)hex6,dest) ;
       putc ((char)hex7,dest) ;

       error = fscanf (source,
           " %x- %x %x %x %x %x %x %x %x ",
          &addr, &hex0, &hex1, &hex2, &hex3, &hex4, &hex5, &hex6, &hex7) ;

   } while (error==9 && error !=-1 ) ;

  fflush (dest) ;

  fclose (source) ;
  fclose (dest) ;
}



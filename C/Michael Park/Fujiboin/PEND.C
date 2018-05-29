/***************************************************************************/
/*                                                                         */
/*  PendBoink!  Written by Xanth Park.  23 Apr 86 (START mod: 27 Jun 86)   */
/*                                                                         */
/*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing     */
/*                                                                         */
/***************************************************************************/
/*
 *      stupid way to append title.d8a, fujidraw.d8a, fujishad.d8a
 *
 *      don't worry about the boo-boo bombs when this runs...
 *      if they really bother you, put in the rest of the GEM calls.
 */

#include <osbind.h>

char buff[109596+2304+6800];

main(){
  int fhandle;

  fhandle = Fopen( "TITLE.D8A", 0 );
  Fread( fhandle, 6800L, buff );
  Fclose( fhandle );
  fhandle = Fopen( "FUJIDRAW.D8A", 0 );
  Fread( fhandle, 109596L, buff+6800 );
  Fclose( fhandle );
  fhandle = Fopen( "FUJISHAD.D8A", 0 );
  Fread( fhandle, 2304L, buff+6800+109596 );
  Fclose( fhandle );
  fhandle = Fcreate( "FUJIBOIN.D8A", 0 );
  Fwrite( fhandle, 6800L+109596+2304, buff );
  Fclose( fhandle );
}


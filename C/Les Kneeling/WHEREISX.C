/*-------------------------------------------------------------------------
  WHEREIS? - by Les Kneeling

  Lost a file? Don't know which folder it is in? Give the file name to
  WHEREIS? and it will search all of the disk for it. When it finds an
  exact match for the filename it will display the full path on screen.
  WHEREIS? will find all of the files with the specified name on the
  disk. Only exact matches will be found.

  Sorry about the readability of the code but it was the only way I
  could get it into 22 lines.
--------------------------------------------------------------------------*/
#include <stdio.h>      /* WHEREIS.TTP - search a disk for a lost file(s) */ 
#include <osbind.h>     /* Written in Laser C by Les Kneeling             */
#include <strings.h>
typedef struct dta{ char r[21]; char fattr; char r2[8]; char fname[14]; };
char spec[15], path[160] = "\\";
main( argc, argv )
int argc;
char **argv;{
strcpy( spec, argv[1] );strcat( path, spec );
locate( path ); puts("Finished");Cconin(); }

locate( path ) char *path;{ struct dta newdta; 
int error; char newpath[160], temp[160];
strcpy( newpath, path );Fsetdta( &newdta );
error = Fsfirst( newpath, 0x0 );
while(!error){ if( strcmp( newdta.fname, spec ) == 0 )
    puts( newpath );error = Fsnext(); }
*rindex( newpath, '\\' ) = 0; strcat( newpath, "\\*.*" );
error = Fsfirst( newpath, 0x10 ); while(!error){ 
if((newdta.fattr && 0x10)&&(newdta.fname[0] != '.') ){ strcpy(temp,newpath);
    sprintf( rindex( temp, '\\' ), "\\%s\\%s", newdta.fname, spec );
    locate( temp ); Fsetdta( &newdta ); } error = Fsnext();     } }

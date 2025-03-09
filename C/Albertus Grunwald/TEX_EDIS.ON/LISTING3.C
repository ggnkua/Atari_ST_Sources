/***************************************************
**                                                **
**       Kommandozeilenbearbeitung fÅr TeX        **
**                                                **
**       von Albertus Grunwald   18.2.1991        **
**          geschrieben mit Turbo C               **
**          (c) 1992 MAXON Computer               **
***************************************************/

#include <stdio.h>
#include <string.h>
#include <tos.h>

#define _toupper( c) ( ( (c)>='a' && (c)<='z') ? (c)+'A'-'a' : (c) )

int main( int argc, char *argv[] )
{
   COMMAND cmdln;
   int i, index;
   char c, *h , *path;
   
      /* Optionen kopieren */
   for( index=0, i=1; i<argc-1; i++)
    { while( ( c= *argv[i]++)!= '\0')
         cmdln.command_tail[index++]= c;
      cmdln.command_tail[index++]= ' ';
    }

      /* Pfad- und Dateiname trennen*/
   path= argv[argc-1];  
   if( (h= strrchr( path,'\\') )!= NULL)
      h++;
   else if( (h= strrchr( path,':') )!= NULL)
      h++;
   else
      h= path;

      /* Dateiname kopieren */
   for( index=0; ( c= *h)!= '\0'; h++, index++)
    { cmdln.command_tail[index]= c;
      *h= '\0';
    }
   cmdln.command_tail[index]= '\0';
   cmdln.length= index+1;

   if( path[1]== ':')
    { Dsetdrv( _toupper(path[0])-'A');
      Dsetpath( path+2);
    }
   else
      Dsetpath( path);

   return( (int)Pexec( 0, "E:\\TEX\\TEX.TTP", &cmdln, NULL) );
}

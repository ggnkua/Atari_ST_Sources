/* SPLIT.C
   utility for splitting a 192K TOS-file into 6 files
   2.3.1989 by Urs ThÅrmann/SH
*/

#include <osbind.h>
#include <string.h>

#define SIZE 192 * 1024L

char infile[SIZE], outfile[SIZE / 6];

int main(argc, argv)
int argc;
char *argv[];

{  char name[128], *ext, *strrchr();
   char *sptr, *dptr;
   int fh, i;

   if(argc > 1)
      strcpy(name, argv[1]);
   else
      strcpy(name, "tos.img");
   if((fh = Fopen(name, 0)) < 0)
      return(-1);
   Fread(fh, SIZE, infile);
   Fclose(fh);

   if(!(ext = strrchr(name, '.')))
      ext = strrchr(name, 0);
   for(i = 0; i < 6; i++)
   {  
       for(dptr = outfile, sptr = infile + i/2 * (SIZE / 3) + i%2;
          dptr < outfile + SIZE / 6; dptr++, sptr += 2)
          {  
             *dptr = *sptr;
          }
      if(i % 2)
         strcpy(ext, ".lox");
      else
         strcpy(ext, ".hix");
      ext[3] = i / 2 + '0';
      printf("Schreibe die Datei %s...\n",name);
      fh = Fcreate(name, 0);
      Fwrite(fh, SIZE / 6, outfile);
      Fclose(fh);
    }
    return(0);
}

char *strrchr(text, ch)
char *text;
int ch;
{
   int i = strlen(text);

   while(i>=0)
   {
		  if (text[i] == ch)
          return(&text[i]);
      i--;
   }   return(0);
}

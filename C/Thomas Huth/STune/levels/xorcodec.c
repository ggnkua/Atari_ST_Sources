
#include <osbind.h>
#include <stdio.h>

/* *** Ein einfacher XOR Verschl《seler/Entschl《seler *** */
void xor_codec(char *addr, long len)
{
 static unsigned char xtable[8]={~16,~128,~1,~4,~64,~2,~32,~8};
 int i=0;

 do
  {
   *addr ^= xtable[i];
   ++addr;
   if( ++i == 8 )  i=0;
  }
 while( --len > 0 );
}


/* ***Levelinfodatei laden und entschl《seln*** */
int main(int argc, char *argv[])
{
 int fhndl;
 long f_siz;
 char *ptr;

 if(argc!=2)
  {
   puts("\nBitte Dateinamen als Argument!\n");
   getchar();
   exit(1);
  }

 fhndl=Fopen(argv[1], 0);
 if( fhndl < 0L )
  { puts("\nCould not open file!\n"); getchar(); exit(2); }

 f_siz=Fseek(0L, fhndl, 2);  /* Dateigr麦e ermitteln */
 Fseek(0L, fhndl, 0);

 ptr=malloc(f_siz);
 if(ptr==NULL)
  { puts("Could not alloc mem!"); getchar(); return(-1); }
 
 if( Fread(fhndl, f_siz, ptr) != f_siz )
  { puts("Could not load file!"); Fclose(fhndl); getchar(); return -1; }

 Fclose(fhndl);

 /* Entschl《seln: */
 xor_codec(ptr, f_siz);

 /* Speichern: */
 fhndl=Fopen(argv[1], 1);
 if( fhndl < 0L )
  { puts("\nCould not open file for writing!\n"); getchar(); exit(2); }

 if( Fwrite(fhndl, f_siz, ptr) != f_siz )
  { puts("Could not write file!"); Fclose(fhndl); getchar(); return -1; }

 Fclose(fhndl);

 return 0;
}

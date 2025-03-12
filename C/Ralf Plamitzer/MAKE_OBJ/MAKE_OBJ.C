  /********************************\
  |  Von   Ralf Plamitzer          |
  |                                |
  |                                |
  |        TURBO C 2.0             |
  |                                |
  |  (c) MAXON Computer GmbH 1990  |
  |  Macht aus beliebigen Dateien  |
  |  linkbare Objektdateien im     |
  |  DR-Format.                    |
  |  Beispielaufruf:               |
  |  B:\ORDNER\FILE.EXT  SYMBOL    |
  |  erzeugt:  B:\ORDNER\FILE.O    |
  \********************************/

  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  #include <ext.h>

  typedef struct
  {
   int             branch; /*  Immer 0x601A      */
   long    tlen;       /*  L„nge Textsegment (0) */
   long    dlen;       /*  L„nge Datensegment    */
   long    blen;       /*  L„nge BSS             */
   long    slen;       /*  L„nge Symb.tab. (14)  */
   char    reserved[10];
  }OHEADER;

  typedef struct
  {
   char    name[8];     /*  Symbolname */
   int             typ; /*  Bei uns immer 0xA400 */
   long    fill;        /*  Immer null */
  }SYM;

  OHEADER  oh = {  0x601A,0L,0L,0L,0x0EL,0,0,0,0,0,0,0,0,0,0 };
  SYM      sym = { "12345678",0xA400,0L };


  void set_ext(char *name,char *ext)
  {
   char *c;

   if((c = strrchr(name,'.')) == NULL)
           return;
   *++c = '\0';
   strcat(name,ext);
  }

  int main(int argc,char *argv[])
  {
   FILE *file;
   char *buf,path[128];

   if(argc != 3)
           return(1);
   strcpy(path,argv[1]);
   if((file = fopen(path,"rb")) == NULL)
           return(1);
   if((oh.dlen = filelength(file->Handle)) % 2)
           oh.dlen++;
   if((buf = malloc(oh.dlen)) == NULL)
   {
           fclose(file);
           return(1);
   }
   fread(buf,oh.dlen,1,file);
   fclose(file);
   set_ext(path,"O");
   if((file = fopen(path,"wb")) == NULL)
   {
           free(buf);
           return(1);
   }
   strncpy(sym.name,argv[2],8);
   fwrite(&oh,sizeof(OHEADER),1,file);
   fwrite(buf,oh.dlen,1,file);
   fwrite(&sym,sizeof(SYM),1,file);
   memset(buf,0,oh.dlen);
   fwrite(buf,oh.dlen,1,file);
   fclose(file);
   free(buf);
   return(0);
  }

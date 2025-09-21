/* 16.5.86  Max B”hm */

/* Dieses Programm kopiert den Inhalt des "Source"-Directory    */
/* in das "Dest"-Directory.                                     */
/* Die beiden Directorys k”nnen als Parameter angegeben werden. */
/* Defaultwerte sind A:\COPY und D:                             */

#include <osbind.h>
#include <string.h>

long buffer, buf_size;

char source[100]="A:\\COPY";
char dest[100]="D:";

copy_dir ()       /* source und dest sind global; bei Fehler: return (1) */
{
int source_len, dest_len, fd_source, fd_dest, error;
char dta[44];
long old_dta, fail, size, count;
   error=0;
   source_len=strlen(source);
   dest_len=strlen(dest);
   old_dta=Fgetdta();
   Fsetdta(dta);
   strcat(source,"\\*.*");
   fail=Fsfirst(source,16);
   source[source_len]=0;
   while (!fail)
   {  strcat(source,"\\");
      strcat(source,dta+30);
      strcat(dest,"\\");
      strcat(dest,dta+30);
      if (dta[21]==16)         /* Directory */
      {  if (strcmp(dta+30,".")&&strcmp(dta+30,".."))
            if (Dcreate(dest))
            {  printf("Ordner %s l„žt sich nicht anlegen.\n",dest);
               error=1;
            }
            else
               error|=copy_dir(source,dest);
      }
      else                     /* File */
      {  printf("%s  nach  %s\n",source,dest);
         if ((fd_source=Fopen(source,0))<0)
         {  printf("Datei %s l„žt sich nicht ”ffnen.\n",source);
            error=1;
         }
         else
            if ((fd_dest=Fcreate(dest,dta[21]&~1))<0)
            {  printf("Datei %s l„žt sich nicht einrichten.\n",dest);
               error=1;
            }
            else
            {  size=*(long*)(dta+26);
               while (size)
               {  count=(size<buf_size)?size:buf_size;
                  size-=count;
                  if (Fread(fd_source,count,buffer)!=count)
                  {  printf("Fehler beim Lesen von %s .\n",source);
                     error=1;
                     break;
                  }
                  if (Fwrite(fd_dest,count,buffer)!=count)
                  {  printf("Fehler beim Schreiben von %s .\n",dest);
                     error=1;
                     break;
                  }
               }
               Fclose(fd_source);
               Fclose(fd_dest);
               fd_dest=Fopen(dest,1);
               Fdatime(fd_dest,dta+22,1);
               Fclose(fd_dest);
            }
      }
      source[source_len]=0;
      dest[dest_len]=0;
      fail=Fsnext();
   }
   if (fail!=-49l)
   {  printf("Ordner %s nicht gefunden.\n",source);
      error=1;
   }
   Fsetdta(old_dta);
   return (error);
}

main(argc,argv)
int argc;
char *argv[];
{
   if (argc>=1)
      strcpy(source,argv[1]);
   if (argc>=2)
      strcpy(dest,argv[2]);
   if (dest[2])
      Dcreate(dest);
   buf_size=Malloc(-1l);
   buffer=Malloc(buf_size);
   if (copy_dir())
   {  printf("\nWeiter mit Return.\n");
      Cconin();
   }
   Mfree(buffer);
}

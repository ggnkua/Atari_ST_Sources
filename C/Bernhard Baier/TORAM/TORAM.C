/* Programm kopiert aus der Datei TORAM.SYS  */
/* Dateien auf eine RAM-Disk                 */
/* 27.08.1986 by Bernhard Baier              */

#include <osbind.h>
#define Maxlength 120000L

unsigned int dtaddress[25];
char data[2000];
long buffer;
int err;
int errflag = 0;

long eval_length(datei)
char *datei;
{
       long length;

       Fsetdta(dtaddress);
       err = Fsfirst(datei, 0);        
       length = ((long) dtaddress[13] << 16) + dtaddress[14];
       if (err)
        {
          Cconws(datei);
          Cconws(" nicht gefunden!\15\12");
          errflag = 1;
          return (0x0L);
        }
       return (length);
}

copy(datei)
char *datei;
{
       long file_length;
       int handle;

       if ((file_length = eval_length(datei)) != 0x0L)
        {

          Cconws(datei);
          Cconws(" wird kopiert\15\12");

          handle = Fopen(datei, 2);
          Fread(handle, file_length, buffer);
          Fclose(handle);
          datei[0] = data[0];
          handle = Fcreate(datei, 0);                 

          if (handle > 0)
           {
             Fwrite(handle, file_length, buffer);
             Fclose(handle);
           }           
          else
           {
             Cconws("Schreibfehler!\15\12");
             errflag = 1;
           }

        }
}

int isname(i)
int i;
{
       if (data[i] > 32 && data[i] < 127)
          return (1);
       return (0);
}

main()
{
       int i, handle;
       int p, flag;
       long length;
       
       Cconws("\33E\TORAM.PRG by Bernhard Baier\15\12\15\12");
       if ((length = eval_length("TORAM.SYS")) == 0x0L)
        {
          Cnecin();
          exit(1);
        }
       if ((buffer = Malloc(Maxlength)) == 0x0L)
        {
          Cconws("\15\12Fehler! Nicht gengend Speicher!");
          Cnecin();
          exit(1);
        }

       if (length > 2000)
        {
          Cconws("\15\12Fehler! Datei TORAM.SYS zu lang!");
          Cnecin();
          exit(1);
        }
       handle = Fopen("TORAM.SYS", 2);
       Fread(handle, length, data);
       Fclose(handle);

       Cconws("Kopieren auf Laufwerk ");
       Cconout(data[0]);
       Cconws(":\15\12\15\12");

       i = 1;
       flag = 0;
       while (!flag)
        {
             while (!isname(i))
              {
                   ++i;
                   if (i >= length)
                    {
                      flag = 1;
                      break;
                    }
              }
             if (!flag)
              {
                p = i;
                while (isname(i))
                       ++i;
                data[i] = 0;
                copy(&data[p]);
              }
        }
       if (errflag)
          Cnecin();
}
      

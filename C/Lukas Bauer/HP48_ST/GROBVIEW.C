/* ------------------------------------------- */
/* GROBVIEW - Darstellung von HP-GROBs auf dem */
/*            Bildschirm des Atari ST          */
/*                                             */
/*           C-Quelltext  "GROBVIEW.C"         */
/*           Lukas Bauer und Dirk Schwarzhans  */
/*           (c) 1991 MAXON Computer           */
/* ------------------------------------------- */

#include <stdio.h>
#include <tos.h>
#include <string.h>

#define __VERSION__ "1.00"
#define FILENAME "GROBFILE.BIT"

typedef unsigned char uchar;

/* Funktionsprototypen */
int display(char *buffer, char *end);
size_t read_file(char *fn, char **buffer);
int reverse(int val);

/*---------------------------------------------*/
/* öbergabe an das TTP-Programm:               */
/* Filename der GROB-Datei                     */
/*                                             */
/* Programm nich in Gemini-Console starten!    */
/*---------------------------------------------*/

int main(int argc, char *argv[])
   {
   char *buffer;
   size_t length;

   if (argc != 2)
      {
      puts("\033E\n\nGROBVIEW: Programm zum An"
           "zeigen von HP 48SX Grafikobjekten");
      puts("Version "__VERSION__","
           __DATE__"\n\r");
      puts("\r\nöbergabeparameter:\r\n");
      puts("GROBVIEW.TTP filename");
      return -1;
      }

   if (length = read_file(argv[1], &buffer))
      display(buffer, buffer + length);

   Mfree(buffer);
   return 0;
   }

/*---------------------------------------------*/
/* Reserviert Speicher und liest die Datei     */
/* '*fn' ein.                                  */
/*---------------------------------------------*/

size_t read_file(char *fn, char **buffer)
   {
   FILE *fp;
   size_t length;

   if ((fp = fopen(fn, "rb")) == NULL)
      {
      puts("\n\rFehler beim ôffnen der Datei!");
      return 0;
      }

   fseek(fp, 0L, SEEK_END);
   length = ftell(fp);
   fseek(fp, 0L, SEEK_SET);

   *buffer = (char *)Malloc(length);
   if (*buffer == NULL)
      {
      puts("\n\rNicht genÅgend Speicher zum Ein"
           "lesen der Datei frei!");
      return 0;
      }
   if (fread(*buffer, sizeof(char), length, fp)
      != length)
      {
      puts("\n\rFehler beim Lesen der Datei!");
      return -1;
      }
   fclose(fp);

   return length;
   }

/*---------------------------------------------*/
/* Zeigt die eingelesene GROB-Datei als        */
/* Grafik an. (Nur hohe ST-Auflîsung)          */
/*---------------------------------------------*/

int display(char *buffer, char *end)
   {
   char *work;
   uchar *screen;
   int xs, ys, x, y, len, handle;
   unsigned int val;

   screen = Physbase();
   puts("\033E\033f");

   work = buffer;
   while (memcmp(work, "GROB ", 5))
      {
      if (work >= end)
         {
         puts("\n\rDiese Datei enthÑlt keine gÅl"
              "tigen Grafikdaten!");
         return -1;
         }
      work++;
      }

   if (sscanf(work + 5, "%d %d %n", &xs, &ys,
              &len) != 2)
      {
      puts("\n\rUngÅltiger 'GROB'-Befehl!");
      return -1;
      }

   work += 5 + len;

   if (xs % 8)
      xs += 8 - (xs % 8);
   for (y = 0; y < ys; y++)
      {
      for (x = 0; x < xs; x += 8)
         {
         if (sscanf(work, "%2xd", &val) != 1)
            {
            puts("\n\rUngÅltiger GROB-Befehl!");
            return -1;
            }
         work += 2;
         val = reverse(val);
         *(screen + (x >> 3) + y * 80) = val;
         }
      }

   Crawcin();

   if ((handle = Fcreate(FILENAME, 0)) > 0)
      {
      Fwrite(handle, 32000, screen);
      Fclose(handle);
      }

   return 0;
   }

/*---------------------------------------------*/
/* Wandelt ein Byte aus der HP-Darstellung in  */
/* die Motorola-Form                           */
/* ==> Der HP48SX ist ein 4 Bit-Rechner !!!    */
/*---------------------------------------------*/

int reverse (int val)
   {
   static int bitpos[] = {3, 2, 1, 0,
                          7, 6, 5, 4};
   int nval, b;

   nval = 0;
   for (b = 0; b <= 7; b++)
      if (val & (1 << b))
         nval |= (1 << bitpos[b]);

   return nval;
   }

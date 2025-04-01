/*
   @(#)atarium/drag.c
   (c)1993 by MAXON-Computer   
   Beispielroutinen fÅr D&D
   basierend auf Sample-Code der 
   ATARI Corporation 
*/

#include <tos.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define AP_DRAGDROP  63

#define  DD_OK    0
#define DD_NAK    1
#define DD_EXT    2
#define DD_LEN    3

/* Standard-Extensionliste */
#define DD_NUMEXTS   8
#define DD_EXTSIZE   32

/* Objektname; MaximallÑnge */
#define DD_NAMEMAX   128

static void *oldsig;

/* Kommandozeile tokenisieren. ' wird als
   Quote-Zeichen benutzt, '' wird durch ein
   einzelnes Quote ersetzt. Die einzelnen
   Komponenten werden durch '\0' voneinander
   getrennt und die Gesamtzahl wird
   zurÅckgeliefert */

static int
parse_ARGS (char *str)
{
   int cnt = 1;
   char *c = str;
   int in_quote = 0;

   while (*c)
   {
      switch (*c)
      {
         case ' ':
            if (!in_quote) {
               *c = '\0';
               cnt++;
            }
            break;

         case 39: /* quote char */
            strcpy (c, c + 1);
            if (!in_quote)
               in_quote = 1;
            else
            {
               if (*c != 39) {
                  in_quote = 0;
                  *c = 0;
                  if (c[1])
                     cnt++;
               }
            }
            break;

         default:
            break;
      }

      c += 1;
   }

   return cnt;
}

/* Kommandozeile verarbeiten */

static void
parse (char *obname, char *cmdline)
{
   int comps = parse_ARGS (cmdline);
   char *c = cmdline;

   while (comps - 1) {
      /* c zeigt auf Element der
         Kommandozeile */
      puts (c);
      c += strlen (c) + 1;
      comps--;
   }

   /* c zeigt auf letztes Element der
      Kommandozeile */
   puts (c);
}

/* ôffnet die Pipe anhand `extension'. Bei
   Erfolg wird der Handler fÅr SIGPIPE gesetzt.
   Ergebnis ist das Dateihandle */

static long
dd_open_fifo (int pnum)
{
   char pipename[20];
   long fd;

   sprintf (pipename, "U:\\PIPE\\DRAGDROP.%c%c",
      (pnum & 0xff00) >> 8, pnum & 0xff);

   if (0 <= (fd = Fopen (pipename, 2)))
      oldsig = Psignal (SIGPIPE, (void *) 1);

   return fd;
}

/* D&D-Operation beenden */

void
dd_close (long fd)
{
   Psignal (SIGPIPE, oldsig);
   Fclose ((int) fd);
}

/* D&D-Pipe îffnen und Extensionliste
   hereinschreiben. Wenn dabei etwas
   schiefgeht, wird der alte SIGPIPE-
   Handler wiederhergestellt. Ergebnis
   ist das Dateihandle oder ein
   Fehlercode */

long
dd_open (int pipe_num, const char *extlist)
{
   long fd;
   char outbuf[DD_EXTSIZE + 1];

   fd = dd_open_fifo (pipe_num);
   if (fd < 0) return fd;

   outbuf[0] = DD_OK;
   strncpy (outbuf + 1, extlist, DD_EXTSIZE);

   if (DD_EXTSIZE + 1 != Fwrite ((int) fd,
      DD_EXTSIZE + 1, outbuf)) {
      dd_close ((int) fd);
      return -1;
   }

   return fd;
}

/* Holt den nÑchsten Header aus der Pipe
   (fd) ab. Ausgabeparameter sind `name'
   (Name des Objekts, mindestens DD_NAMEMAX
   Zeichen), `datatype' (Datentyp, 4 + 1
   Zeichen) und `size' (Grîûe der Daten).
   RÅckgabewert ist 1 im Erfolgsfall,
   0 sonst */

int
dd_getheader (long fd, char *obname,
   char *fname, char *datatype, long *size)
{
   short hdrlen;
   size_t cnt, slen;
   char buf[PATH_MAX + DD_NAMEMAX + 1];

   if (2 != Fread ((int) fd, 2, &hdrlen))
      return 0;
   if (hdrlen < 9) return 0;

   if (4 != Fread ((int) fd, 4, datatype))
      return 0;
   datatype[4] = '\0';

   if (4 != Fread ((int) fd, 4, size))
      return 0;

   hdrlen -= 8;
   cnt = hdrlen;

   /* Objektnamen und Dateinamen lesen */
   if (cnt > PATH_MAX + DD_NAMEMAX)
      cnt = PATH_MAX + DD_NAMEMAX;
   if (cnt != Fread ((int) fd, cnt, buf))
      return 0;

   buf[PATH_MAX + DD_NAMEMAX] = '\0';
   hdrlen -= cnt;
   slen = strlen (buf);

   if (slen < DD_NAMEMAX)
      strcpy (obname, buf);

   if (slen < PATH_MAX + DD_NAMEMAX) {
      char *fp = buf + slen + 1;

      slen = strlen (fp);

      if (slen < PATH_MAX)
         strcpy (fname, fp); 
   }

   /* Rest Åberspringen */
   while (hdrlen) {
      size_t cnt = hdrlen;
      if (cnt > sizeof (buf))
         hdrlen = sizeof (buf);

      Fread ((int) fd, cnt, buf);
      hdrlen -= cnt;
   }

   return 1;
}

/* Ein-Zeichen-Antwort verschicken. Im
   Fehlerfall wird die Pipe geschlossen.
   RÅckgabewert: 0 bei Fehlern */

int
dd_reply (long fd, char ack)
{
   if (1 != Fwrite ((int) fd, 1L, &ack)) {
      dd_close (fd);
      return 0;
   }
   return 1;
}

/* D&D durchfÅhren */

void
dd_receive (int msg[])
{
   long fd;
   char obname[DD_NAMEMAX], ext[5];
   char fname[PATH_MAX];
   char ourexts[DD_EXTSIZE] = "ARGS";
   long size;

   fd = dd_open (msg[7], ourexts);
   if (fd < 0) return;

   do
   {
      if (!dd_getheader (fd, obname, fname,
         ext, &size))
      {
         dd_close (fd);
         return;
      }

      if (! strncmp (ext, "ARGS", 4)) {
         char *cmdline = malloc (size + 1);

         if (!cmdline) {
            dd_reply (fd, DD_LEN);
            continue;
         }

         dd_reply (fd, DD_OK);
         Fread ((int) fd, size, cmdline);
         dd_close (fd);
         cmdline[size] = 0;
         parse (obname, cmdline);
         free (cmdline);
         return;
      }
   } while (dd_reply (fd, DD_EXT));
}


/* <<< VSSCANF.C 1.0 06.05.92 14:30 >>> */

/* Library: LCxxxx.LIB

   Dieses Modul enth„lt die globale Funktion:
      -  vsscanf

   (c) 1992 by MAXON Computer
           und Heiner H”gel

   History:
      1.0  06.05.92  -  Ersterstellung (vsscanf)! Dies ist eine Erg„nzung der
                        scanf-Funktionenfamilie, um kompatibel zur Pure-C-
                        Library zu sein. Die Verwendung der library-internen
                        Funktion _sf ist von Lattice/Hisoft/CCD nicht
                        offiziell dokumentiert und beruht auf eigenen Analysen
                        der Library LCSR.LIB! (Heiner H”gel)
*/

/*===========================================================================*/

#include <stdarg.h>

int vsscanf (const char *s, const char *format, va_list arglist);

extern int __regargs _sf (int (*p_getc) (void), void (*p_ungetc) (int c),
                          int *p_count, const char *format, va_list arglist);

#define EOF (-1)

static int         count;
static const char *input;

/*===========================================================================*/

static int x_getc (void) /*
-----------======--------*/
   {
   unsigned char c;

   count++;
   if ((c = *input++) == '\0')
      return (EOF);
   else
      return ((int) c);
   }

static void x_ungetc (int c) /*
------------========---------*/
   {
   count--;
   input--;
   }

int vsscanf (const char *s, const char *format, va_list arglist) /*
----=======------------------------------------------------------*/
   {
   count = 0;
   input = s;
   return (_sf(x_getc, x_ungetc, &count, format, arglist));
   }

/*===========================================================================*/



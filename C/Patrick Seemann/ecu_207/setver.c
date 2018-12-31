/* --------------------------------------------------------------------
   Module:     SETVER.C
   Subject:    Setzt Versionsnummer und Datum
   Author:     ho
   Started:    03.11.1991   12:37:27
   --------------------------------------------------------------------
   92-06-18ps Suffix-Parameter hinzugefÅgt
   --------------------------------------------------------------------
   void SetVersion(char *pName, int update, int release, int revision, char *suffix)

   pName:      Programmname, z.B. "ECU/ST"
   update:     Major-Release Nummer
   release:    Minor-Release Nummer
   revision:   Pre-Release Character
   suffix:     Suffix fÅr Tearline

   szTearline und szVersion werden erzeugt. Als Datum wird das Datum
   verwendet, an dem dieses Sourcefile Åbersetzt wurde.
   -------------------------------------------------------------------- */



#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>

#include "global.h"

static char *szMonth[] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                           "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

void SetVersion(char *pName, int update, int release, int revision, char *suffix)
{
   int   day;
   int   month;
   int   year;

   for (month = 0;
      month < 12 && strnicmp(__DATE__, szMonth[month], 3) != 0;
      month++);
   assert(month < 12);
   day = atoi(__DATE__ + 4);
   year = atoi(__DATE__ + 7) % 100;

   sprintf(szTearline, "%s %d.%.2d%c%s", pName, update, release, revision, suffix);
   sprintf(szVersion,  "%.2d%.2d%.2d%.2d%.2d", update, release,
         day, month + 1, year);
}

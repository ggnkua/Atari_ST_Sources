/* --------------------------------------------------------------------
   Module:     QBBS.C
   Subject:    Load, Save and Maintain LastRead-Pointers for QBBS
   Author:     ho
   Started:    23.03.1992	21:13:33
   Modified:   23.03.1992	21:59:50
   -------------------------------------------------------------------- */



#include <stdlib.h>
#include <stdio.h>
#include <ext.h>
#include <string.h>

#include "global.h"
#include "ecudef.h"

#define AREAS_MAX 200

typedef WORD LASTREAD[AREAS_MAX];

static LASTREAD   *pLastRead  = NULL;
static size_t     users       = 0;



/* --------------------------------------------------------------------
   qbbsLastRead  --  reads QBBS's Last-Read-Pointers. On return static
   variables fpLastRead and pLastRead reflect the outcome of this
   function.
   -------------------------------------------------------------------- */
void qbbsReadLastRead(void)
{
   if (szLastReadQBBS[0])
   {
      FILE *fp = fopen(szLastReadQBBS, "rb+");
      if (fp == NULL)
      {
         ShowError(szLastReadQBBS, strerror(errno));
         return;
      }
      users = filelength(fileno(fp)) / sizeof(LASTREAD);
      pLastRead = calloc(users, sizeof(LASTREAD));
      if (pLastRead != NULL)
      {
         fseek(fp, 0, SEEK_SET);
         fread(pLastRead, sizeof(LASTREAD), users, fp);
      }
      else
      {
         ShowError(szLastReadQBBS, szOutOfMemory);
      }
      fclose(fp);
   }
}


void qbbsSaveLastRead(void)
{
   if (pLastRead != NULL)
   {
      FILE *fp = fopen(szLastReadQBBS, "wb");
      if (fp == NULL)
      {
         ShowError(szLastReadQBBS, strerror(errno));
      }
      else
      {
         size_t n = fwrite(pLastRead, sizeof(LASTREAD), users, fp);
         if (n != users) ShowError(szLastReadQBBS, szWriteError);
         fclose(fp);
      }
      free(pLastRead);
   }
}


void qbbsUpdateLastRead(int area, int msg)
{
   if (area >= 0 && area < AREAS_MAX)
   {
      int i;
      for (i = 0; i < users; i++)
      {
         if (pLastRead[i][area] > msg) --pLastRead[i][area];
      }
   }
}

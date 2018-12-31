/* --------------------------------------------------------------------
   Module:     COOKIE.C
   Subject:    cookies and includes for Ecu
   Author:     ho
   Started:    19.09.1991   15:58:16              
   Modified:   19.10.91     09:52:56              
   --------------------------------------------------------------------
   19.10.1991  60 Zeichen fÅr Origin-Zeile
   13.10.1991  IncludeText
   -------------------------------------------------------------------- */


#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "defines.h"
#include "global.h"


#define  COOKIE_MAX  60


BOOL  OpenCookie(char *pName, COOKIE *pCookie)
{
   FILE  *fp;
   int   n;
   int   i;
   long  size;
   long  bfrpos;
   long  msgpos;
   long  *p;
   char  buffer[512];

   fp = fopen(pName, "rb");
   if (fp == NULL)
   {
      ShowError(pName, strerror(errno));
      return FALSE;
   }
   n = 0;
   while ((size = fread(buffer, sizeof(char), sizeof(buffer), fp)) > 0)
   {
      for (i = 0; i < size; i++)
      {
         if (buffer[i] == '\n') ++n;
      }
   }
   p = calloc(n, sizeof(*pCookie->offset));
   if (p == NULL)
   {
      ShowError("OpenCookie", szOutOfMemory);
      fclose(fp);
      return FALSE;
   }
   fseek(fp, 0, SEEK_SET);
   bfrpos = 0;
   msgpos = 0;
   n      = 0;
   while ((size = fread(buffer, sizeof(char), sizeof(buffer), fp)) > 0)
   {
      for (i = 0; i < size; i++)
      {
         if (buffer[i] == '\n')
         {
            p[n++] = msgpos;
            msgpos = bfrpos + i + 1;
         }
      }
      bfrpos += size;
   }
   pCookie->fp     = fp;
   pCookie->cnt    = n;
   pCookie->offset = p;

   srand((unsigned) time(NULL));
   return TRUE;
}



BOOL  GetCookie(COOKIE *pCookie, char *pBuffer)
{
   int   n;

   if (pCookie->fp == NULL || pCookie->offset == NULL) return FALSE;
   n = rand() % pCookie->cnt;
   fseek(pCookie->fp, pCookie->offset[n], SEEK_SET);
   fread(pBuffer, sizeof(char), COOKIE_MAX, pCookie->fp);
   pBuffer[COOKIE_MAX] = 0;

   while (isascii(*pBuffer) && isprint(*pBuffer)) ++pBuffer;
   *pBuffer = 0;

   return TRUE;
}


void  CloseCookie(COOKIE *pCookie)
{
   if (pCookie->offset != NULL)
   {
      free(pCookie->offset);
      pCookie->fp = NULL;
   }
   if (pCookie->fp != NULL)
   {
      fclose(pCookie->fp);
      pCookie->offset = NULL;
   }
}



size_t IncludeText(FILE *fpOutput, char *pName)
{
   char   buffer[128];
   char   *p;
   FILE   *fpInput;
   size_t written;
   size_t cnt;

   while (*pName == ' ' || *pName == '\t') ++pName;
   for (p = buffer;
        *pName && *pName != ' ' && *pName != '\t' && *pName != '\n';
        *p++ = *pName++);
   *p = 0;
   written = 0;

   fpInput = fopen(buffer, "rb");
   if (fpInput != NULL)
   {
      while ((cnt = fread(buffer, sizeof(char), sizeof(buffer), fpInput)) > 0)
      {
         cnt = fwrite(buffer, sizeof(char), cnt, fpOutput);
         if (cnt < 0)
         {
            ShowError("InsertText", szWriteError);
            break;
         }
         written += cnt;
      }
      if (ferror(fpInput))
      {
         ShowError("InsertText", strerror(errno));
      }
      fclose(fpInput);
   }
   else
   {
      ShowError(buffer, strerror(errno));
   }

   return written;
}

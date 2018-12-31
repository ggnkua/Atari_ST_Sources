/* --------------------------------------------------------------------
   Module:     DUPES.C
   Subject:    markes all dupes in an area
   Author:     ho
   Started:    11.11.1991   10:25:18
   --------------------------------------------------------------------
   92-10-17ps  GEM-Abh„ngigkeiten entfernt
   --------------------------------------------------------------------
   26.01.91 bad access to CRC-Flag array fixed
   10.02.91 sets dupe-count in area block, no output to log-file
   -------------------------------------------------------------------- */



#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "defines.h"

#include "global.h"



#define  MAGIC 0x5F15



static   int   TotalDupes = 0;
static   int   LocalDupes = 0;
static   BYTE  CrcList[8192];



/* --------------------------------------------------------------------
   strfill

   pads a string with \0's to a given length.

   Input:
      str   address of array/string to pad
      len   size of array
   -------------------------------------------------------------------- */
void  strfill(char *str, size_t len)
{
   int i;

   str += (i = (int) strlen(str));
   while (i++ < len) *str++ = 0;
}



/* --------------------------------------------------------------------
   NewCrc

   computes the CRC of a given message and stores the CRC together with
   a magic value in the message header. The magic value should be used
   to determine validity of the CRC. When the algorithem to compute the
   CRC is changed, the magic value should be changed, too, ensuring
   that all CRC's are recalculated.

   Input:
      pHeader  address of message header

   The CRC can be derived from different data. A fast, but incomplete
   method would be computing the CRC over some part of the message
   header only. A slower method would be computing the CRC over the
   message text with technical stuff removed. However, this requires
   reading the message text, but the probability of two messages with
   the same CRC should be reduced. To use the entire message to calcu-
   late the CRC, define the FULLCRC pro-processor symbol. Otherwise
   only a part of the header is used to calculate the CRC.

   Some investigation has shown, that a partial CRC is sufficient in
   most cases. In a message area with about 900 messages there have
   been 5 or 6 CRC dupes, that hadn't been real dupes. In none of
   these cases the message text had to be read to find differences.
   -------------------------------------------------------------------- */
void  NewCrc(MSG_HEADER *pHdr)
{
#ifdef FULLCRC

   BYTE  *pBody;

   pBody = malloc(pHdr->wSize);
   if (pBody != NULL)
   {
      fseek(fpMessages, pHdr->lStart, SEEK_SET);
      if (fread(pBody, 1, pHdr->wSize, fpMessages) < pHdr->wSize)
      {
         ShowError(nmMessages, strerror(errno));
         free(pBody);
         return;
      }
      RemoveOldScrolls(pBody);
      pHdr->wCrc = sCalcCrc(pBody);
   }

   free(pBody);

#else

   strfill(pHdr->szFrom,    sizeof(pHdr->szFrom));
   strfill(pHdr->szTo,      sizeof(pHdr->szTo));
   strfill(pHdr->szSubject, sizeof(pHdr->szSubject));
   strfill(pHdr->szDate,    sizeof(pHdr->szDate));
   pHdr->wCrc = bCalcCrc(pHdr, offsetof(MSG_HEADER, lDate));

#endif

   pHdr->wMagic = MAGIC;
   WriteHeader  = TRUE;
}



/* --------------------------------------------------------------------
   CompareHeaders

   compares a given header with all previous headers to find a dupe. If
   a matching header is found, the messages themselves are compared.

   Input:
      pHdr  address of message to find

   When the message is identified as a dupe, its deleted-flag is set,
   and a flag is set to ensure updating of the header file.
   -------------------------------------------------------------------- */
void  CompareHeaders(MSG_HEADER *pHdr)
{
   MSG_HEADER *p;
   BYTE        *pText1;
   BYTE        *pText2;

   for (p = pHeader; p < pHdr; p++)
   {
      if (p->wCrc        == pHdr->wCrc
      &&  p->wFlags      == pHdr->wFlags
      &&  p->wFromPoint  == pHdr->wFromPoint
      &&  p->wToPoint    == pHdr->wToPoint
      &&  p->wFromNode   == pHdr->wFromNode
      &&  p->wToNode     == pHdr->wToNode
      &&  p->wFromNet    == pHdr->wFromNet
      &&  p->wToNet      == pHdr->wToNet
      &&  p->wFromZone   == pHdr->wFromZone
      &&  p->wToZone     == pHdr->wToZone
      &&  stricmp(p->szDate,    pHdr->szDate)    == 0
      &&  stricmp(p->szSubject, pHdr->szSubject) == 0
      &&  stricmp(p->szFrom,    pHdr->szFrom)    == 0
      &&  stricmp(p->szTo,      pHdr->szTo)      == 0)
      {
         pText1 = calloc(pHdr->wSize + 1, 1);
         pText2 = calloc(p->wSize    + 1, 1);
         if (pText1 != NULL && pText2 != NULL)
         {
            fseek(fpMessages, pHdr->lStart, SEEK_SET);
            if (fread(pText1, 1, pHdr->wSize, fpMessages) == pHdr->wSize)
            {
               fseek(fpMessages, p->lStart, SEEK_SET);
               if (fread(pText2, 1, p->wSize, fpMessages) == p->wSize)
               {
                  RemoveOldScrolls(pText1);
                  RemoveOldScrolls(pText2);
                  if (!stricmp(pText1, pText2))
                  {
                     pHdr->wFlags |= MF_DELETED;
                     WriteHeader = TRUE;
                     ++TotalDupes;
                     ++LocalDupes;
                     free(pText1);
                     free(pText2);
                     return;
                  }
               }
               else
               {
                  ShowError(nmMessages, strerror(errno));
               }
            }
            else
            {
               ShowError(nmMessages, strerror(errno));
            }
            free(pText1);
            free(pText2);
         }
         else
         {
            ShowError("CompareHeaders", szOutOfMemory);
            if (pText1 != NULL) free(pText1);
            if (pText2 != NULL) free(pText2);
         }
      }
   }
}



/* --------------------------------------------------------------------
   MarkDupes

   searches the entire area for dupes. To speed things up, a CRC is cal-
   culated for all messages. When two matching CRCs are found, the mes-
   sages are inspected in more details. A vector of 65536 bits is used
   to keep track of all the CRCs already found in the area. This costs
   8k bytes of memory, but it saves many pathes thru the message area.
   -------------------------------------------------------------------- */
void  MarkDupes(void)
{
   MSG_HEADER  *p;
   int         n;

   LocalDupes = 0;
#ifdef GEM
   SetDlgItemText(pInfoDlg, d0status, "searching for dupes");
   SetDlgItemInt(pInfoDlg, d0dlcnt, LocalDupes);
   SetDlgItemInt(pInfoDlg, d0dtcnt, TotalDupes);
#endif

   memset(CrcList, 0, sizeof(CrcList));

   for (p = pHeader, n = nHeader; n--; p++)
   {
      if ((p->wFlags & MF_DELETED) == 0)
      {
         if (p->wMagic != MAGIC)
         {
            NewCrc(p);
         }
         if (KillDupes)
         {
            if (CrcList[p->wCrc >> 3] & (1 << (p->wCrc & 0x07)))
            {
               CompareHeaders(p);
            }
            else
            {
               CrcList[p->wCrc >> 3] |= (1 << (p->wCrc & 0x07));
            }
         }
      }
   }

   pActiveArea->Dupes = LocalDupes;
}

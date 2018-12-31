/* --------------------------------------------------------------------
   Module:     LLEGADEF.H
   Subject:    global definitions for Llegada
   Author:     ho
   Started:    28.09.1991   14:19:23
   Modified:   02.12.1991   23:43:39
   -------------------------------------------------------------------- */


#ifndef  __ECUDEF
#define  __ECUDEF



#include "global.h"
#include "defines.h"



/* -------------
      Defines
   ------------- */

enum { UNKNOWN, ARC, ZOO, ZIP, LHA, ARJ, LHARC, };



/* ----------------
      Prototypes
   ---------------- */

/*--- IMPORT.C ---*/
void UnpackArchives(void);
BOOL IsGoodMessage(void);
BOOL ImportPacket(void);
void UnpackMail(void);
BOOL WriteMessage(BOOL (* callback)(FILE *, MSG_HEADER *, char *, char *),
                  MSG_HEADER *pHeader, BYTE *pData, char *pAreaname);
BOOL WritePlainText(FILE *fpMessages, MSG_HEADER *pHeader,
                    char *pMessage, char *pAreaname);

/*--- LLEGADA.C ---*/
void WriteStatistics(void);

/*--- WHICHARC.C ---*/
int WhichArc(char *pName);

/*--- CENSOR.C ---*/
BOOL ReadRules(char *pName);
BOOL CensorMessage(MSG_HEADER *pHeader, char *pMessage, char *pAreaName);
void CensorStats(void);

#endif

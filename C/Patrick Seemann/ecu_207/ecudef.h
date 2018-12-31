/* --------------------------------------------------------------------
   Module:     ECUDEF.H
   Subject:    global definitions for ECU
   Author:     ho
   Started:    27.01.1991   01:39:21
   Modified:  23.03.1992   21:44:08
   --------------------------------------------------------------------
   23.03.1992  QBBS-support (update last read pointers for multiple
               users)
   -------------------------------------------------------------------- */



#ifndef  __ECUDEF
#define  __ECUDEF



/* -------------
      Defines
   ------------- */

         /* die Reihenfolge FLO, CLO, HLO muž unbedingt eingehalten werden */
#define  FF_FLO            0
#define  FF_CLO            1
#define  FF_HLO            2



/* ----------------
      Prototypes
   ---------------- */

/*--- EXPORT.C ---*/
HOSTPARAM *AlternateHost(HOSTPARAM *pHost);
void  WriteFlowFileEntry(WORD, WORD, WORD, WORD, char *, char *, int);
BOOL  LoadHeader(void);
void  CreatePkt(HOSTPARAM *pHost);
FILE *CreateCrashPkt(HOSTPARAM *pHost,
                     WORD zone, WORD net, WORD node, WORD POINT);
void  PutString(char **d, char *s, int len, int limit);
BOOL  ExportMessage(MSG_HEADER *pHeader);
void  ProcessHeader(void);
void  CopyMessages(void);
BOOL  SaveHeader(void);
void  UpdateMessageBase(void);
void  ExportArea(AREAPARAM *pArea);
void  ClosePackets(void);
void  AppendTbFlow(void);

/*--- QBBS.C ---*/
void  qbbsReadLastRead(void);
void  qbbsSaveLastRead(void);
void  qbbsUpdateLastRead(int area, int msg);

#endif

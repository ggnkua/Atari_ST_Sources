#ifndef __MSG_TXT_H
#define __MSG_TXT_H

typedef void* HMSG ;

/* Loads a Text Message file in memory                 */
/* Returned pointer should be tread as opaque          */
/* It actually returns a pointer to char *mesg[]       */
/* i.e: HMSG   hmsg=MsgTxtLoadFile(...)                */
/*      char** mesg = *hmsg ;                          */
/* Holding pointers to text messages but you should    */
/* Use MsgTxtGetMsg to access a particular message     */
/* Use it as mesg[id] if you are damn sure id is valid */
HMSG  MsgTxtLoadFile(char* filename) ;
int   MsgTxtFreeMsg(HMSG hMsg) ;
char* MsgTxtGetMsg(HMSG hMsg, int id) ;
 
#endif
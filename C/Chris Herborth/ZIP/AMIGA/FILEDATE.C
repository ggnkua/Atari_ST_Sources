/***********************/
/* Function filedate() */
/***********************/

/*  FileDate() (originally utime.c), by Paul Wells.  Modified by John Bush
 *  and others (see also sendpkt() comments, below); NewtWare SetFileDate()
 *  clone cheaply ripped off from utime().
 */

/* HISTORY/CHANGES
 *  2 Sep 92, Greg Roelofs, Original coding.
 *  6 Sep 92, John Bush, Incorporated into UnZip 5.1
 *  6 Sep 92, John Bush, Interlude "FileDate()" defined, which calls or
 *            redefines SetFileDate() depending upon AMIGADOS2 definition.
 * 11 Oct 92, John Bush, Eliminated AMIGADOS2 switch by determining
 *            revision via OpenLibrary() call.  Now only one version of
 *            the program runs on both platforms (1.3.x vs. 2.x)
 * 11 Oct 92, John Bush, Merged with Zip version and changed arg passing
 *            to take time_t input instead of struct DateStamp.
 *            Arg passing made to conform with utime().
 * 22 Nov 92, Paul Kienitz, fixed includes for Aztec and cleaned up some
 *            lint-ish errors; simplified test for AmigaDOS version.
 */

/* DESCRIPTION
 * This routine chooses between 2 methods to set the file date on AMIGA.
 * Since AmigaDOS 2.x came out, SetFileDate() was available in ROM (v.36
 * and higher).  Under AmigaDOS 1.3.x (less than v.36 ROM), SetFileDate()
 * must be accomplished by constructing a message packet and sending it
 * to the file system handler of the file to be stamped.
 *
 * The system's ROM version is extracted from the external system Library
 * base.
 *
 * NOTE:  although argument passing conforms with utime(), note the
 *        following differences:  
 *          - Return value is boolean success/failure.
 *          - If a structure or array is passed, only the first value
 *            is used, which *may* correspond to date accessed and not
 *            date modified.
 */

#include <string.h>
#include <time.h>
#include <errno.h>
#include <stdio.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>

#ifdef AZTEC_C
   extern int timezone;
   void tzset(void);
#  include <clib/exec_protos.h>
#  include <clib/dos_protos.h>
#  include <pragmas/exec_lib.h>
#  include <pragmas/dos_lib.h>
#  define ESRCH ENOENT
#  define EOSERR EIO
#endif

#if defined(LATTICE) || defined(__SASC)
#  include <proto/exec.h>
#  include <proto/dos.h>
#endif

extern int _OSERR;

#ifndef SUCCESS
#  define SUCCESS (-1L)
#  define FAILURE 0L
#endif

#define ReqVers 36L  /* required library version for SetFileDate() */

extern struct Library *SysBase;

LONG FileDate (char *filename, time_t u[]);

/* =============================================================== */

LONG FileDate(filename, u)
  char *filename;
  time_t u[];
{
  LONG SetFileDate(UBYTE *filename, struct DateStamp *pDate);
  LONG sendpkt(struct MsgPort *pid, LONG action, LONG *args, LONG nargs);
  struct MsgPort *taskport;
  struct FileLock *dirlock, *lock;
  struct FileInfoBlock *fib;
  LONG pktargs[4];
  UBYTE *ptr;
  long ret;

  struct DateStamp pDate;
  time_t mtime;

  tzset();
  mtime=u[0]-timezone;

#ifdef DEBUG
  fprintf (stderr,"Entry to FileDate(): mtime=%s\n",ctime(&mtime));
#endif
    
/*  magic number = 2922 = 8 years + 2 leaps between 1970 - 1978 */

  pDate.ds_Days = (mtime / 86400L) - 2922L;
  mtime = mtime % 86400L;
  pDate.ds_Minute = mtime / 60L;
  mtime = mtime % 60L;
  pDate.ds_Tick = mtime * TICKS_PER_SECOND;

#ifdef DEBUG
  fprintf (stderr,"In FileDate(): Days=%ld Minutes=%ld Ticks=%ld\n",
           pDate.ds_Days,pDate.ds_Minute,pDate.ds_Tick);
#endif

  if (SysBase->lib_Version >= ReqVers) {
      return (SetFileDate(filename,&pDate));  /* native routine at 2.0+ */
    }
    else  /* !(SysBase->lib_Version >=ReqVers) */
    { 
      if( !(taskport = (struct MsgPort *)DeviceProc(filename)) )
      {
          errno = ESRCH;          /* no such process */
          _OSERR = IoErr();
          return FAILURE;
      }

      if( !(lock = (struct FileLock *)Lock(filename,SHARED_LOCK)) )
      {
          errno = ENOENT;         /* no such file */
          _OSERR = IoErr();
          return FAILURE;
      }

      if( !(fib = (struct FileInfoBlock *)AllocMem(
          (long)sizeof(struct FileInfoBlock),MEMF_PUBLIC|MEMF_CLEAR)) )
      {
          errno = ENOMEM;         /* insufficient memory */
          UnLock((BPTR)lock);
          return FAILURE;
      }

      if( Examine((BPTR)lock,fib)==FAILURE )
      {
          errno = EOSERR;         /* operating system error */
          _OSERR = IoErr();
          UnLock((BPTR)lock);
          FreeMem((char *)fib,(long)sizeof(*fib));
          return FAILURE;
      }

      dirlock = (struct FileLock *)ParentDir((BPTR)lock);
      ptr = (UBYTE *)AllocMem(64L,MEMF_PUBLIC);
      strcpy((ptr+1),fib->fib_FileName);
      *ptr = strlen(fib->fib_FileName);
      FreeMem((char *)fib,(long)sizeof(*fib));
      UnLock((BPTR)lock);

      /* now fill in argument array */

      pktargs[0] = 0;
      pktargs[1] = (LONG)dirlock;
      pktargs[2] = (LONG)&ptr[0] >> 2;
      pktargs[3] = (LONG)&pDate;

      errno = ret = sendpkt(taskport,ACTION_SET_DATE,pktargs,4L);

      FreeMem(ptr,64L);
      UnLock((BPTR)dirlock);

      return SUCCESS;
    }  /* ?(SysBase->lib_Version >= ReqVers) */
} /* FileDate() */

/* LOW LEVEL SUPPORT ROUTINES */

/*  sendpkt.c
 *  by A. Finkel, P. Lindsay, C. Sheppner
 *  returns Res1 of the reply packet
 */
/*
#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <proto/exec.h>
#include <proto/dos.h>
*/

LONG sendpkt(pid,action,args,nargs)
struct MsgPort *pid;           /* process identifier (handler message port) */
LONG action,                   /* packet type (desired action)              */
     *args,                    /* a pointer to argument list                */
     nargs;                    /* number of arguments in list               */
{

    struct MsgPort *replyport, *CreatePort(UBYTE *, long);
    void DeletePort(struct MsgPort *);
    struct StandardPacket *packet;
    LONG count, *pargs, res1;

    replyport = CreatePort(NULL,0L);
    if( !replyport ) return(0);

    packet = (struct StandardPacket *)AllocMem(
            (long)sizeof(struct StandardPacket),MEMF_PUBLIC|MEMF_CLEAR);
    if( !packet )
    {
        DeletePort(replyport);
        return(0);
    }

    packet->sp_Msg.mn_Node.ln_Name  = (char *)&(packet->sp_Pkt);
    packet->sp_Pkt.dp_Link          = &(packet->sp_Msg);
    packet->sp_Pkt.dp_Port          = replyport;
    packet->sp_Pkt.dp_Type          = action;

    /* copy the args into the packet */
    pargs = &(packet->sp_Pkt.dp_Arg1);      /* address of 1st argument */
    for( count=0; count<nargs; count++ )
        pargs[count] = args[count];

    PutMsg(pid,(struct Message *)packet);   /* send packet */

    WaitPort(replyport);
    GetMsg(replyport);

    res1 = packet->sp_Pkt.dp_Res1;

    FreeMem((char *)packet,(long)sizeof(*packet));
    DeletePort(replyport);

    return(res1);

} /* sendpkt() */

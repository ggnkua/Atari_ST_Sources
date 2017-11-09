typedef unsigned long ULONG;

typedef struct
{                                /* These timeouts are used...                */
   ULONG    BeforeCommand;       /* ...before sending a command               */
   ULONG    AfterCommand;        /* ...after sending a command                */
   ULONG    ShortTimeout;        /* ...for quick commands                     */
   ULONG    LongTimeout;         /* ...for long commands                      */
   ULONG    Wait4IRQ;            /* ...for commands which can last to eternity*/
   ULONG    XtraShortTimeout;    /* ...for very short commands like TestUnit  */
	ULONG		CommandDelay;			/* between two commands								*/
} SCSI_TIMEOUT;

/*
 * Pre-sets for timeouts are:
 * BeforeCommand   : 20UL     (25ms)
 * AfterCommand    : 20UL     (25ms)
 * ShortTimeout    : 6000UL   (30s)
 * LongTimeout     : 12000UL  (60s)
 * Wait4IRQ        : 240000UL (20min)
 * XtraShortTimeout: 50UL     (250ms)
 */

int HDCapacity(int pdev, int ldev, int iface, char *buf);
int HDCopy(int pdev, int ldev, long length, char *buf, int erase);
int HDDefect(int pdev, int ldev, int iface, int fmt, int count, char *buf);
int HDFormat(int pdev, int ldev, int interleave);
int HDRead(int pdev, int ldev, long start, long count, char *buf);
int HDWrite(int pdev, int ldev, long start, long count, char *buf);
int Illegal(void);
int Inquiry(int pdev, int ldev, int bytes, char *buf);
int MSelect(int pdev, int ldev, int count, char *buf);
int MSense(int pdev, int ldev, int page, int bytes, char *buf);
int ReqSense(int pdev, int ldev, int count, char *buf);
long SCSIVersion(void);
SCSI_TIMEOUT *SetTimeout(SCSI_TIMEOUT *scsi_timeout);
int STLocate(int pdev, int ldev, int iface, int cp, int part, long adr);
int STReqAux(int pdev, int ldev, int bytes, char *buf);
int STRead(int pdev, int ldev, long count, char *buf);
int STWrite(int pdev, int ldev, long count, char *buf);
int STSkip(int pdev, int ldev, int kind, int count);
int HDStop(int pdev, int ldev, int eject);
int STErase(int pdev, int ldev, int async);
int STPrewind(int pdev, int ldev, int async);
int STRewind(int pdev, int ldev, int async);
int STWFileM(int pdev, int ldev, int kind);
int HDReleas(int pdev, int ldev);
int HDReserv(int pdev, int ldev);
int HDRezero(int pdev, int ldev);
int HDStart(int pdev, int ldev);
int STAppend(int pdev, int ldev);
int STLock(int pdev, int ldev);
int STUnlock(int pdev, int ldev);
int TestUnit(int pdev, int ldev);


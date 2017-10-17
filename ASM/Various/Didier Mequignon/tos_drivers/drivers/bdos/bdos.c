/* This file exist because it's impossible to
   use TOS trap out of CF68KLIB !!!
 */
#include "config.h"
#include "../freertos/FreeRTOS.h"
#include "../freertos/task.h"
#include "../../include/vars.h"
#include "asm.h"
#include "fs.h"
#include "mem.h"
#include "console.h"
#include "gemerror.h"

#ifdef NETWORK
#ifdef LWIP

extern void xSemaphoreTakeBDOS(void);
extern void xSemaphoreGiveBDOS(void);
extern void board_printf(const char *fmt, ...);

extern void *pxCurrentTCB;
static DTAINFO dta;
extern PD *run, *start_run;
static PD *save_run;
long function_BDOS; /* info */
void *current_TCB_BDOS; /* info */

/*
 *  freetree -  free the directory node tree
 */

static void freetree(DND *d)
{
  int i;
  if(d->d_left)
    freetree(d->d_left);
  if (d->d_right)
    freetree(d->d_right);
  if(d->d_ofd)
    xmfreblk(d->d_ofd);
  for(i = 0; i < NCURDIR; i++)
  {
    if(dirtbl[i] == d)
    {
      dirtbl[i] = 0;
      diruse[i] = 0;
    }
  }
  xmfreblk(d);
}

static void offree(DMD *d)
{
  int i;
  OFD *f;
  for(i=0; i < OPNFILES; i++)
  {
    if((((long)(f = sft[i].f_ofd)) > 0L) && (f->o_dmd == d))
    {
      xmfreblk(f);
      sft[i].f_ofd = 0;
      sft[i].f_own = 0;
      sft[i].f_use = 0;
    }
  }
}

static BPB *MyGetbpb(short errdrv)
{
  BPB * (*p)(short);
  p = (BPB * (*)(short))*(void **)hdv_bpb;
  return((*p)(errdrv));
}

static void SemaphoreTakeBDOS(void)
{
  unsigned long *p = (unsigned long *)pxCurrentTCB;
  xSemaphoreTakeBDOS();
  save_run = run; /* for TOS */
  current_TCB_BDOS = pxCurrentTCB;
  if(!p[39] || (p[39] == 0xA5A5A5A5))
  {
    run = MGET(PD);
    p[39] = (unsigned long)run;
    if(!p[39])
    {
      board_printf("BDOS task allocation full!\r\n");
      while(1)
        vTaskDelay(1);
    }
//    else board_printf("BDOS: TCB: 0x%08X, address of basepage = 0x%08X\r\n", p, p[39]);
    run->p_curdrv = 2; /* drive C */
    run->p_xdta = (char *)&dta;
    /* set up system initial standard handles */
    run->p_uft[0] = H_Console;          /* stdin        =       con:    */
    run->p_uft[1] = H_Console;          /* stdout       =       con:    */
    run->p_uft[2] = H_Console;          /* stderr       =       con:    */
    run->p_uft[3] = H_Aux;              /* stdaux       =       aux:    */
    run->p_uft[4] = H_Print;            /* stdprn       =       prn:    */
  }
  else
    run = (PD *)p[39];
}

static void SemaphoreGiveBDOS(void)
{
  run = save_run; /* for TOS */
  xSemaphoreGiveBDOS();
}

static long error_processing(void)
{
  BPB *b;
  BCB *bx;
  DND *dn;
  int i;
  long rc = errcode;
  /* hard error processing */
//  board_printf("Error code gotten from some longjmp(): %ld\r\n", rc);
  /* is this a media change ? */
  if(rc == E_CHNG)
  {
    /* first, out with the old stuff */
    dn = drvtbl[errdrv]->m_dtl;
    offree(drvtbl[errdrv]);
    xmfreblk(drvtbl[errdrv]);
    drvtbl[errdrv] = 0;
    if(dn)
      freetree(dn);
    for(i = 0; i < 2; i++)
    {
      for(bx = bufl[i]; bx; bx = bx->b_link)
      {
        if(bx->b_bufdrv == errdrv)
          bx->b_bufdrv = -1;
      }
    }
    /* then, in with the new */
    b = MyGetbpb(errdrv);       /* use wrapper just to avoid longjmp() compiler warning */
    if((long)b <= 0)
    {
      drvsel &= ~(1<<errdrv);
      if((long)b)
        return((long)b);
      return(rc);
    }
    if(log_(b,errdrv))
      return(ENSMEM);
    rwerr = 0;
    errdrv = 0;
    return(0); /* restart */
  }
  /* else handle as hard error on disk for now */
  for(i = 0; i < 2; i++)
  {
    for(bx = bufl[i]; bx; bx = bx->b_link)
    {
      if(bx->b_bufdrv == errdrv)
        bx->b_bufdrv = -1;
      return(rc);
    }
  }
  return(rc);
}

long Dsetdrv(long drv)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  function_BDOS = 0x0E;
  ret = xsetdrv((short)drv);
  SemaphoreGiveBDOS();
  return(ret);
}

long Dgetdrv(void)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  function_BDOS = 0x19;
  ret = (long)xgetdrv();
  SemaphoreGiveBDOS();
  return(ret);
}

void Fsetdta(DTAINFO *buf) 
{
  if(start_run == NULL)
    return;
  SemaphoreTakeBDOS();
  function_BDOS = 0x1A;
  xsetdta((char *)buf);
  SemaphoreGiveBDOS();
}

DTAINFO *Fgetdta(void)
{
  DTAINFO *ret;
  if(start_run == NULL)
    return((DTAINFO *)-1);
  SemaphoreTakeBDOS();
  function_BDOS = 0x2F;
  ret = (DTAINFO *)xgetdta();
  SemaphoreGiveBDOS();
  return(ret);
}

long Dfree(long *buf, long driveno) 
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x36; 
  ret = (long)xgetfree(buf, (short)driveno);
  SemaphoreGiveBDOS();
  return(ret);
}

long Dcreate(const char *path)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x39;
  ret = (long)xmkdir((char *)path);
  SemaphoreGiveBDOS();
  return(ret);
}

long Ddelete(const char *path)  
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x3A;
  ret = (long)xrmdir((char *)path);
  SemaphoreGiveBDOS();
  return(ret);
}

long Dsetpath(const char *path)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x3B; 
  ret = (long)xchdir((char *)path);
  SemaphoreGiveBDOS();
  return(ret);
}
   
long Fcreate(const char *fname, long attr)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x3C;
  ret = (long)xcreat((char *)fname, (char)attr);
  SemaphoreGiveBDOS();
  return(ret);
}

long Fopen(const char *fname, long mode) 
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x3D;
  ret = (long)xopen((char *)fname, (short)mode);
  SemaphoreGiveBDOS();
  return(ret);
}

long Fclose(long handle)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x3E;
  ret = (long)xclose((short)handle);
  SemaphoreGiveBDOS();
  return(ret);
}

long Fread(long handle, long count, void *buf) 
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x3F; 
  if(handle <= 0)
  {
    SemaphoreGiveBDOS();
    return(EIHNDL); /* invalid handle: media change, etc */
  }
  ret = xread((short)handle, count, buf);
  SemaphoreGiveBDOS();
  return(ret);
}

long Fwrite(long handle, long count, void *buf) 
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x40;
  if(handle <= 0)
  {
    SemaphoreGiveBDOS();
    return(EIHNDL);/* invalid handle: media change, etc */
  }
  ret = xwrite((short)handle, count, buf);
  SemaphoreGiveBDOS();
  return(ret);
}

long Fdelete(const char *fname)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x41;
  ret = (long)xunlink((char *)fname); 
  SemaphoreGiveBDOS();
  return(ret);
}

long Fseek(long offset, long handle, long seekmode)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x42;
  if(handle <= 0)
  {
    SemaphoreGiveBDOS();
    return(EIHNDL); /* invalid handle: media change, etc */
  }
  ret = xlseek(offset, (short)handle, (short)seekmode);
  SemaphoreGiveBDOS();
  return(ret);
}

long Fattrib(const char *filename, long wflag, long attrib)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x43; 
  ret = (long)xchmod((char *)filename, (short)wflag, (char)attrib);
  SemaphoreGiveBDOS();
  return(ret);
}

long Dgetpath(char *path, long driveno)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x47; 
  ret = (long)xgetdir(path, (short)driveno);
  SemaphoreGiveBDOS();
  return(ret);
}

long Fsfirst(const char *filename, long attr)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x4E;
  ret = (long)xsfirst((char *)filename, (short)attr);
  SemaphoreGiveBDOS();
  return(ret);
}

long Fsnext(void)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x4F; 
  ret = (long)xsnext();
  SemaphoreGiveBDOS();
  return(ret);
} 

long Frename(const char *oldname, const char *newname)
{
  long ret;
  if(start_run == NULL)
    return(-1);
  SemaphoreTakeBDOS();
  if(setjmp(errbuf))
  {
    if((ret = error_processing()) != 0)
    {
      SemaphoreGiveBDOS();
      return(ret);
    }
  }
  function_BDOS = 0x56; 
  ret = (long)xrename(0, (char *)oldname, (char *)newname);
  SemaphoreGiveBDOS();
  return(ret);
}

void Fdatime(short *timeptr, long handle, long wflag)
{
  if(start_run == NULL)
    return;
  SemaphoreTakeBDOS();
  function_BDOS = 0x57;
  xgsdtof(timeptr, (short)handle, (short)wflag);
  SemaphoreGiveBDOS();
}

#endif /* LWIP */
#endif /* NETWORK */

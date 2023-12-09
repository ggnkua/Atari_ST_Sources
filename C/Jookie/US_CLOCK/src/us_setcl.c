/*--------------------------------------------------*/
#include <stdio.h>
#include <conio.h>
#include <screen.h>
#include <string.h>
#include <stdlib.h>
#include <graphics.h>
#include <aes.h>

#include "dma.h"
#include "system.h"
/*--------------------------------------------------*/
#define BYTE  unsigned char
#define WORD  unsigned int
#define DWORD unsigned long int

/* -------------------------------------- */
 struct mfp_chip {
                  char reg[48]; /* MFP registers are on odd bytes */
                 } ;
/* -------------------------------------- */
typedef long (*func)();         /* pointer to function returning a long */

/* Logical Drive Info */
struct hd_drv {
            short dev_addr;     /* physical unit ASCI address */
            long  part_start;   /* start sector logical unit */
               } ;
/*--------------------------------------------------*/
BYTE ShowMenu(void);
BYTE GetClock(void);
BYTE SetClock(void);
BYTE SetTime(void);
BYTE US_ReadRunningFW(BYTE ACSI_id, BYTE *buffer);

void DoOnKeyD(void);
void DoOnKeyT(void);
/*--------------------------------------------------*/
BYTE UltraSatanID;
BYTE hours, minutes, seconds, day, month;
WORD year;    

BYTE myBuffer[520];
BYTE *pBuffer;
/*--------------------------------------------------*/
/*
#define DEBUG_VERSION
*/

void main(void)
{
  BYTE res, i, key;
  DWORD scancode;
  DWORD toEven;
 
  /* ---------------------- */
  toEven = (DWORD) &myBuffer[0];
  
  if(toEven & 0x0001)       /* not even number? */
    toEven++;
  
  pBuffer = (BYTE *) toEven; 
  /* ---------------------- */
   
  UltraSatanID = (BYTE) 0;
  /* ----------------- */
  printf("  ");
  Clear_home();
  printf("\nLooking for UltraSatan:\n");

  while(1)
  {
    for(i=0; i<8; i++)
    {
      printf("%d", (int) i);
      
      res = US_ReadRunningFW(i, pBuffer);      /* try to read FW name */
      
      if(res == 1)                            /* if found the US */
      {
        UltraSatanID = (BYTE) i;                     /* store the ACSI ID of UltraSatan */
        break;
      }
    }
  
    if(res == 1)                              /* if found, break */
      break;
      
    printf(" - not found.\nPress any key to retry or 'Q' to quit.\n");
    
    key = Cconin();
    
    if(key == 'Q' || key=='q')
      return;
  }
  
  printf("\n\n");
  printf("UltraSatan ACSI ID: %d\n", (int) UltraSatanID);
  printf("FirmWare: %s\n", (char *) pBuffer);
  delay(3000);
  /* ----------------- */

  while(1)
  {
    res = ShowMenu();
    
    if(res == 0)
      break;
  
    Goto_pos(24, 24);
    scancode = Cconin();

    key = scancode & 0xff;

    Goto_pos(24, 24);
    printf(" ");
     
    if(key=='q' || key=='Q')
      break;
      
    switch(key)
    {
      case 'd':
      case 'D': DoOnKeyD(); break;
      
      case 't':
      case 'T': DoOnKeyT(); break;
    }

  }
}
/*--------------------------------------------------*/
void DoOnKeyD(void)
{
  int nYear, nMonth, nDay, iRes;
  BYTE res;
  
  Clear_home();
  Rev_on();
  printf(">> UltraSatan RTC setter <<\n");
  Rev_off();
 
  printf("Current date: %04d-%02d-%02d (YYYY-MM-DD)\n", (int) year, (int) month, (int) day);
  printf("New date    : ");

  scanf("%s", (char *) myBuffer);
  iRes = sscanf((char *) myBuffer, "%d-%d-%d", &nYear, &nMonth, &nDay);
  
  if(iRes != 3)
  {
    printf("\n\nCould not get the new date\nfrom keyboard - bad format entered?\n");
    Cconin();
    return;
  }
  /* ----------------- */
  if(nYear>2100 || nYear<2000)
    nYear = 2008;
    
  if(nMonth>12 || nMonth<1)
    nMonth = 1;
    
  if(nDay>31 || nDay<1)
    nDay = 1;
  /* ----------------- */
  res = GetClock();

  if(!res)
  {
    printf("Failed to get date & time\nfrom UltraSatan!");
    Cconin();
    return;
  }
  /* ----------------- */
  year    = nYear;
  month   = (BYTE) nMonth;
  day     = (BYTE) nDay;
  /* ----------------- */
  res = SetClock();

  if(!res)
  {
    printf("Failed to set new date & time\nto UltraSatan!");
    Cconin();
    return;
  }
}
/*--------------------------------------------------*/
void DoOnKeyT(void)
{
  int nHours, nMinutes, nSeconds, iRes;
  BYTE res;
  
  Clear_home();
  Rev_on();
  printf(">> UltraSatan RTC setter <<\n");
  Rev_off();
 
  printf("Current time: %02d:%02d:%02d (HH-MM-SS)\n", hours, minutes, seconds);
  printf("New time    : ");

  scanf("%s", (char *)myBuffer);
  iRes = sscanf((char *)myBuffer, "%d:%d:%d", &nHours, &nMinutes, &nSeconds);
  
  if(iRes != 3)
  {
    printf("\n\nCould not get the new time\nfrom keyboard - bad format entered?\n");
    Cconin();
    return;
  }
  /* ----------------- */
  if(nHours>23 || nHours<0)
    nHours = 0;
    
  if(nMinutes>59 || nMinutes<0)
    nMinutes = 0;
    
  if(nSeconds>59 || nSeconds<0)
    nSeconds = 0;
  /* ----------------- */
  res = GetClock();

  if(!res)
  {
    printf("Failed to get date & time\nfrom UltraSatan!");
    Cconin();
    return;
  }
  /* ----------------- */
  hours    = (BYTE) nHours;
  minutes  = (BYTE) nMinutes;
  seconds  = (BYTE) nSeconds;
  /* ----------------- */
  res = SetClock();

  if(!res)
  {
    printf("Failed to set new date & time\nto UltraSatan!");
    Cconin();
    return;
  }
}
/*--------------------------------------------------*/
BYTE ShowMenu(void)
{
  BYTE res;

  Clear_home();
  Rev_on();
  printf(">> UltraSatan RTC setter <<\n");
  Rev_off();
  /* ----------------- */
  res = GetClock();

#ifndef DEBUG_VERSION
  if(!res)
  {
    printf("Failed to get date & time\nfrom UltraSatan!");
    Cconin();
    
    return 0;
  }
#endif
  
  printf("\n\nDate: %04d-%02d-%02d (YYYY-MM-DD)\n", year, month, day);
  printf("Time:   %02d:%02d:%02d (HH:MM:SS)\n\n", hours, minutes, seconds);

  printf("\n\nMenu:\n[    d    ] - set new date\n[    t    ] - set new time\n[    q    ] - quit\n[ any key ] - show menu\n\n");

  /* ----------------- */
  return 1;
}
/*--------------------------------------------------*/
BYTE GetClock(void)
{
  BYTE res;
  BYTE cmd[] = {0x1f, 0x20, 'U', 'S', 'R', 'd', 'C', 'l', 'R', 'T', 'C'};
  /* ------------------- */
  memset(pBuffer, 0, 512);  
  
  cmd[0] = 0x1f | (UltraSatanID << 5);  
  res = LongRW(1, cmd, pBuffer);         /* read clock */

#ifndef DEBUG_VERSION
  if(res != OK)
    return 0;
  /* ------------------- */
  if(pBuffer[0]!='R' || pBuffer[1]!='T' || pBuffer[2]!='C')  /* if bad format */
    return 0;
  /* ------------------- */
  year    = (WORD) pBuffer[3];
  month   = pBuffer[4];
  day     = pBuffer[5];
  hours   = pBuffer[6];
  minutes = pBuffer[7];
  seconds = pBuffer[8];
  
  year += 2000;
#else
  year    = 8;
  month   = 9;
  day     = 29;
  hours   = 17;
  minutes = 12;
  seconds = 38;
#endif
  
  return 1;
}
/*--------------------------------------------------*/
BYTE SetClock(void)
{
  BYTE res;
  BYTE cmd[] = {0x1f, 0x20, 'U', 'S', 'W', 'r', 'C', 'l', 'R', 'T', 'C'};
  /* ------------------- */
  memset(pBuffer, 0, 512);  
  pBuffer[0] = 'R';
  pBuffer[1] = 'T';
  pBuffer[2] = 'C';
  
  pBuffer[3] = (BYTE) (year - 2000);
  pBuffer[4] = month;
  pBuffer[5] = day;
  pBuffer[6] = hours;
  pBuffer[7] = minutes;
  pBuffer[8] = seconds;
  
  cmd[0] = 0x1f | (UltraSatanID << 5);  
  res = LongRW(0, cmd, pBuffer);         /* set clock */

  #ifndef DEBUG_VERSION
  if(res != OK)
    return 0;
  #endif
  /* ------------------- */
  return 1;
}
/*--------------------------------------------------*/
BYTE US_ReadRunningFW(BYTE ACSI_id, BYTE *buffer)
{
  WORD res;
  BYTE cmd[] = {0x1f, 0x20, 'U', 'S', 'C', 'u', 'r', 'n', 't', 'F', 'W'};
  
  cmd[0] = 0x1f | (ACSI_id << 5);  
  memset(buffer, 0, 512);               /* clear the buffer */
  
  #ifdef DEBUG_VERSION
  if(ACSI_id==4)
  {
    strcpy((char *) buffer, "UltraSatan - fake present FW");
    return 1;
  }
  #endif
  
  res = LongRW(1, cmd, buffer);         /* read name and version of current FW */
    
  if(res != OK)                         /* if failed, return FALSE */
    return 0;
    
  return 1;                             /* success */
}
/*--------------------------------------------------*/
BYTE LongRW(BYTE ReadNotWrite, BYTE *cmd, BYTE *buffer)
{
 DWORD status;
 WORD i;
 void *OldSP;
  
 OldSP = (void *) Super((void *)0);  			/* supervisor mode */ 

 FLOCK = -1;                            /* disable FDC operations */
 setdma((DWORD) buffer);                      /* setup DMA transfer address */

 DMA->MODE = NO_DMA | HDC;              /* write 1st byte (0) with A1 low */
 DMA->DATA = cmd[0];
 DMA->MODE = NO_DMA | HDC | A0;         /* A1 high again */

  for(i=1; i<10; i++)
  {
    if (qdone() != OK)                  /* wait for ack */
    {
      hdone();                          /* restore DMA device to normal */
      Super((void *)OldSP);  			      /* user mode */
      return ERROR;
    }
    
    DMA->DATA = cmd[i];
    DMA->MODE = NO_DMA | HDC | A0;
  }

  if (qdone() != OK)                  /* wait for ack */
  {
    hdone();                          /* restore DMA device to normal */
    Super((void *)OldSP);  			      /* user mode */
    return ERROR;
  }

  if(ReadNotWrite==1)
  {
    DMA->MODE = DMA_WR | NO_DMA | SC_REG;  /* clear FIFO = toggle R/W bit */
    DMA->MODE = NO_DMA | SC_REG;           /* and select sector count reg */ 

    DMA->SECT_CNT = 1;                     /* write sector cnt to DMA device */
    DMA->MODE = NO_DMA | HDC | A0;         /* select DMA data register again */

    DMA->DATA = cmd[10];                   
    DMA->MODE = 0;                         /* start DMA transfer */

    status = endcmd(NO_DMA | HDC | A0);    /* wait for DMA completion */
  }
  else
  {
    DMA->MODE = NO_DMA | SC_REG;           /* clear FIFO = toggle R/W bit */
    DMA->MODE = DMA_WR | NO_DMA | SC_REG;  /* and select sector count reg */

    DMA->SECT_CNT = 1;                     /* write sector cnt to DMA device */
    DMA->MODE = DMA_WR | NO_DMA | HDC | A0;/* select DMA data register again */

    DMA->DATA = cmd[10];                   
    DMA->MODE = DMA_WR;                    /* start DMA transfer */

    status = endcmd(DMA_WR | NO_DMA | HDC | A0); /* wait for DMA completion */
  }

  hdone();                                 /* restore DMA device to normal */
  
  Super((void *)OldSP);  			             /* user mode */
  return status;
}
/****************************************************************************/
long endcmd(short mode)
{
 if (fdone() != OK)                   /* wait for operation done ack */
    return(ERRORL);

 DMA->MODE = mode;                    /* write mode word to mode register */
 return((long)(DMA->DATA & 0x00FF));  /* return completion byte */
}
/****************************************************************************/
long hdone(void)
{
 DMA->MODE = NO_DMA;        /* restore DMA mode register */
 FLOCK = 0;                 /* FDC operations may get going again */
 return((long)DMA->STATUS); /* read and return DMA status register */
}
/****************************************************************************/
void setdma(DWORD addr)
{
 DMA->ADDR[LOW]  = (BYTE)(addr);
 DMA->ADDR[MID]  = (BYTE)(addr >> 8);
 DMA->ADDR[HIGH] = (BYTE)(addr >> 16);
}
/****************************************************************************/
long qdone(void)
{
 return(wait_dma_cmpl(STIMEOUT));
}
/****************************************************************************/
long fdone(void)
{
 return(wait_dma_cmpl(LTIMEOUT));
}
/****************************************************************************/
long wait_dma_cmpl(unsigned long t_ticks)
{
 unsigned long to_count;

 to_count = t_ticks + HZ_200;   /* calc value timer must get to */

 do
 {
    if ( (MFP->GPIP & IO_DINT) == 0) /* Poll DMA IRQ interrupt */
         return(OK);                 /* got interrupt, then OK */

 }  while (HZ_200 <= to_count);      /* check timer */

 return(ERROR);                      /* no interrupt, and timer expired, */
}
/****************************************************************************/



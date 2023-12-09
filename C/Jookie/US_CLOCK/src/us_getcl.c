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
BYTE GetClock(void);
BYTE SetTime(void);
BYTE US_ReadRunningFW(BYTE ACSI_id, BYTE *buffer);
/*--------------------------------------------------*/
BYTE UltraSatanID;

BYTE myBuffer[520];
BYTE *pBuffer;

BYTE hours, minutes, seconds, day, month;
WORD year;    
/*--------------------------------------------------*/
/*
#define DEBUG_VERSION
*/

void main(void)
{
  BYTE res, i, key;
  DWORD toEven;

  /* ---------------------- */
  toEven = (DWORD) &myBuffer[0];
  
  if(toEven & 0x0001)       /* not even number? */
    toEven++;
  
  pBuffer = (BYTE *) toEven; 
  /* ---------------------- */
  UltraSatanID = 0;
  /* ----------------- */
  printf("  ");
  Clear_home();
  printf("\nLooking for UltraSatan:\n");

  while(1)
  {
    for(i=0; i<8; i++)
    {
      printf("%d", i);
      
      res = US_ReadRunningFW(i, pBuffer);      /* try to read FW name */
      
      if(res == 1)                            /* if found the US */
      {
        UltraSatanID = i;                     /* store the ACSI ID of UltraSatan */
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
  
  printf("\n\nUltraSatan ACSI ID: %d\nFirmWare: %s", UltraSatanID, (char *)pBuffer);
  delay(500);
  /* ----------------- */
  Clear_home();
  Rev_on();
  printf(">> ST RTC setter from UltraSatan <<\n");
  Rev_off();
  /* ----------------- */
  res = GetClock();

  if(!res)
  {
    printf("Failed to get date & time\nfrom UltraSatan!\n");
    Cconin();
    
#ifndef DEBUG_VERSION
    return;
#endif
  }
  
  printf("\nDate: %04d-%02d-%02d (YYYY-MM-DD)\n", (int) year, (int) month, (int) day);
  printf("Time:   %02d:%02d:%02d (HH:MM:SS)\n\n", (int) hours, (int) minutes, (int) seconds);
  
  res = SetTime();

  if(!res)
  {
    printf("Failed to set the new date & time.");
    Cconin();
    
#ifndef DEBUG_VERSION
    return;
#endif
  }
  
  delay(500);
  /* ----------------- */
}
/*--------------------------------------------------*/
BYTE SetTime(void)
{
  WORD newDate, newTime;
  WORD newYear, newMonth;
  WORD newHour, newMinute, newSecond;
  BYTE res;
  /*------------------*/
  newYear = year - 1980;
  newYear = newYear << 9;
  
  newMonth = month;
  newMonth = newMonth << 5;
  
  newDate = newYear | newMonth | (day & 0x1f);
  
  res = Tsetdate(newDate);
  
  if(res)                   /* if some error, then failed */
    return 0;         
  /*------------------*/
  newSecond = ((seconds/2) & 0x1f);
  newMinute = minutes & 0x3f;
  newMinute = newMinute << 5;
  newHour = hours & 0x1f;
  newHour = newHour << 11;
  
  newTime = newHour | newMinute | newSecond;
  
  res = Tsettime(newTime);
  
  if(res)                   /* if some error, then failed */
    return 0;         
  /*------------------*/
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
  year    = ((WORD) pBuffer[3]) + 2000;
  month   = pBuffer[4];
  day     = pBuffer[5];
  hours   = pBuffer[6];
  minutes = pBuffer[7];
  seconds = pBuffer[8];
#else
  year    = 8;
  month   = 9;
  day     = 29;
  hours   = 17;
  minutes = 12;
  seconds = 38;
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
    strcpy((char *)buffer, "UltraSatan - fake present FW");
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

  hdone();                               /* restore DMA device to normal */
  Super((void *)OldSP);  			      /* user mode */
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



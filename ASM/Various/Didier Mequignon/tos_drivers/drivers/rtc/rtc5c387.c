#include "config.h"
#include <string.h>
#include "../freertos/FreeRTOS.h"
#include "../freertos/FreeRTOSConfig.h"
#include "../freertos/task.h"
#include "../freertos/semphr.h"
#include "../lwip/net.h"
#include "mcf548x.h"

extern void display_string(char *string);

#define RTC_ADDR 0xB2
#define TEMPO_US 5
#define TIMEOUT 100000000 /* 1S */

struct rtc_tm {
	unsigned char	secs;
	unsigned char	mins;
	unsigned char	hours;
	unsigned char	mday;
	unsigned char	mon;
	unsigned short year; /* xxxx 4 digits :) */
	unsigned char wday;
	unsigned char set;
};

#define RTC5C387_REG_SEC       0x0 /* x 4 2 1 | 8 4 2 1 */
#define RTC5C387_REG_MIN       0x1 /* x 4 2 1 | 8 4 2 1 */
#define RTC5C387_REG_HR        0x2 /* x x 2 1 | 8 4 2 1 */
#define RTC5C387_REG_WDAY      0x3 /* x x x x | x 4 2 1 */
#define RTC5C387_REG_DAY       0x4 /* x x 2 1 | 8 4 2 1 */
#define RTC5C387_REG_MON_CENT  0x5 /* C x x 1 | 8 4 2 1 */
#define RTC5C387_REG_YEAR      0x6 /* 8 4 2 1 | 8 4 2 1 */
#define RTC5C387_REG_AL_MIN    0x8 /* x 4 2 1 | 8 4 2 1 */
#define RTC5C387_REG_AL_HR     0x9 /* x 4 2 1 | 8 4 2 1 */
#define RTC5C387_REG_AL_WDAY   0xa /* x 6 5 4 | 3 2 1 0 */
#define RTC5C387_REG_CTRL1     0xe
#define RTC5C387_REG_CTRL2     0xf

/* Control reg */
#define RTC5C387_CTRL1_TEST    (1<<3)
#define RTC5C387_CTRL1_CLEN2   (1<<4)
#define RTC5C387_CTRL1_24      (1<<5)
#define RTC5C387_CTRL1_DALE    (1<<6)
#define RTC5C387_CTRL1_WALE    (1<<7)

#define RTC5C387_CTRL2_DAFG    (1<<0)
#define RTC5C387_CTRL2_WAFG    (1<<1)
#define RTC5C387_CTRL2_CTFG    (1<<2)
#define RTC5C387_CTRL2_CLEN1   (1<<3)
#define RTC5C387_CTRL2_XSTP    (1<<4)
#define RTC5C387_CTRL2_SCRATCH (1<<5)
#define RTC5C387_CTRL2_VDET    (1<<6)
#define RTC5C387_CTRL2_VDSL    (1<<7)

#ifdef USE_RTC
#ifdef NETWORK
#ifdef LWIP

static xSemaphoreHandle	smid;
static unsigned long date, time;
static struct rtc_tm dt_set;

/*
 * I2Cinit: I2C initilazation as master
 *
 * Parameters: None.
 *
 * Return : None.
 */
void I2Cinit()
{
	unsigned char temp;		 
	/* set the frequency near 400KHz */ 
	MCF_I2C_I2FDR = MCF_I2C_I2FDR_IC(0x10);
	/* start the module */
	MCF_I2C_I2CR = 0 | MCF_I2C_I2CR_IEN;
	/* if bit busy set, send a stop condition to slave module */
	if(MCF_I2C_I2SR & MCF_I2C_I2SR_IBB)
	{
		MCF_I2C_I2CR = 0;						/* clear control register */
		MCF_I2C_I2CR = MCF_I2C_I2CR_IEN |	MCF_I2C_I2CR_MSTA; /*  enable module & send a START condition */
		temp = MCF_I2C_I2DR;					/* dummy read */
		MCF_I2C_I2SR = 0;						/* clear status register */
		MCF_I2C_I2CR = 0;						/* clear control register */
		MCF_I2C_I2CR = 0 | MCF_I2C_I2CR_IEN;	/* enable the module again */
	}
  MCF_SLT_SLTCNT(1) = 0xFFFFFFFF;
  MCF_SLT_SCR(1) = MCF_SLT_SCR_TEN + MCF_SLT_SCR_RUN;
}

static unsigned long ReadTimer(void)
{
	return((unsigned long)MCF_SLT_SCNT(1)); /* en 100eme uS */
}

static void DelayMicroSec(unsigned long delay)
{
  unsigned long val = ReadTimer();
  delay *= SYSTEM_CLOCK;
  while(val-ReadTimer() < delay);
} 

/*
 * I2CreceiveByte: I2C read byte
 *
 * Parameters: address: address to read
 *			   id: I2C device to read
 *
 * Return : data: byte read it from device
 */
unsigned char I2CreceiveByte(unsigned char address, unsigned char id)
{
  unsigned long timeout;
	unsigned char data;
	MCF_I2C_I2CR |= MCF_I2C_I2CR_MTX;			/* setting in Tx mode */
	/* send start condition */
	MCF_I2C_I2CR |= MCF_I2C_I2CR_MSTA;
	MCF_I2C_I2DR = id;                    /* device ID to write */
	/* wait until one byte transfer completion */
	timeout = ReadTimer();
	while(!(MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(timeout-ReadTimer() >= TIMEOUT)
    {
      display_string("Timeout I2CreceiveByte (1)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	/* Wait for a bit */
	DelayMicroSec(TEMPO_US);
	MCF_I2C_I2DR = address;					       /* memory address */
	/* wait until one byte transfer completion */
	timeout = ReadTimer();
	while(!(MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(timeout-ReadTimer() >= TIMEOUT)
    {
      display_string("Timeout I2CreceiveByte (2)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;	 	
	MCF_I2C_I2CR |= MCF_I2C_I2CR_RSTA;			/* resend start */
	MCF_I2C_I2DR = id | 0x01;					/* device id to read */
	/* wait until one byte transfer completion */
	timeout = ReadTimer();
	while(!(MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(timeout-ReadTimer() >= TIMEOUT)
    {
      display_string("Timeout I2CreceiveByte (3)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	MCF_I2C_I2CR &= ~MCF_I2C_I2CR_MTX;			/* setting in Rx mode */
	MCF_I2C_I2CR |= MCF_I2C_I2CR_TXAK;			/* send NO ACK */
	/* Wait for a bit */
	DelayMicroSec(TEMPO_US);
	data = MCF_I2C_I2DR;						/* dummy read */
	/* wait until one byte transfer completion */
	timeout = ReadTimer();
	while(!(MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(timeout-ReadTimer() >= TIMEOUT)
    {
      display_string("Timeout I2CreceiveByte (4)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	/* Wait for a bit */
	DelayMicroSec(TEMPO_US);
	data = MCF_I2C_I2DR;						/* read data received */
	/* wait until one byte transfer completion */
	timeout = ReadTimer();
	while(!(MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(timeout-ReadTimer() >= TIMEOUT)
    {
      display_string("Timeout I2CreceiveByte (5)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	/* generates stop condition */
	MCF_I2C_I2CR &= ~MCF_I2C_I2CR_MSTA;
	/* Wait for a bit */
	DelayMicroSec(TEMPO_US);
	/* send the received data */
	return data;
}

/*
 * I2CsendByte: send byte to I2C device
 *
 * Parameters: data: byte to write
 *			   address: address to write
 *			   id: I2C device to write
 *
 * Return : None.
 */
void I2CsendByte(unsigned char data, unsigned char address, unsigned char id)
{
  unsigned long timeout;
	MCF_I2C_I2CR |= MCF_I2C_I2CR_MTX;			/* setting in Tx mode */
	/* generates start condition */
	MCF_I2C_I2CR |= MCF_I2C_I2CR_MSTA;
	MCF_I2C_I2DR = id;                    /* set device ID to write */
	/* wait until one byte transfer completion */
	while(!(MCF_I2C_I2SR & MCF_I2C_I2SR_IIF));
	/* clear the completion transfer flag */
	MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;
	/* Wait for a bit */
	DelayMicroSec(TEMPO_US);
	MCF_I2C_I2DR = address;						/* memory address */
	/* wait until one byte transfer completion */
	timeout = ReadTimer();
	while(!(MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(timeout - ReadTimer() >= TIMEOUT)
    {
      display_string("Timeout I2CsendByte (1)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;	
	/* Wait for a bit */
	DelayMicroSec(TEMPO_US);
	MCF_I2C_I2DR = data;						/* memory data */
	/* wait until one byte transfer completion */
	timeout = ReadTimer();
	while(!(MCF_I2C_I2SR & MCF_I2C_I2SR_IIF))
  {
    if(timeout-ReadTimer() >= TIMEOUT)
    {
      display_string("Timeout I2CsendByte (2)\r\n");
      break;
    }    
  }
	/* clear the completion transfer flag */
	MCF_I2C_I2SR &= ~MCF_I2C_I2SR_IIF;	
	/* generates stop condition */
	MCF_I2C_I2CR &= ~MCF_I2C_I2CR_MSTA;
	/* Wait for a bit */
	DelayMicroSec(TEMPO_US);
	return;
}

#define BCD_TO_BIN(val) (((val)&15) + ((val)>>4)*10)
#define BIN_TO_BCD(val) ((((val)/10)<<4) + (val)%10)

static void rtc5c387_get_datetime(struct rtc_tm *dt)
{
	int i;
	unsigned char buf[15];
  if(xSemaphoreTake(smid, portMAX_DELAY) != pdTRUE)
    return;
	for(i=0; i<15; i++)
		buf[i] = I2CreceiveByte(i, RTC_ADDR);
	/* century stored in minute alarm reg */
	dt->year = BCD_TO_BIN(buf[RTC5C387_REG_YEAR]);
	dt->year += 100 * BCD_TO_BIN(buf[RTC5C387_REG_AL_MIN] & 0x3f);
	dt->mday = BCD_TO_BIN(buf[RTC5C387_REG_DAY] & 0x3f);
	dt->wday = BCD_TO_BIN(buf[RTC5C387_REG_WDAY] & 7);
	dt->mon = BCD_TO_BIN(buf[RTC5C387_REG_MON_CENT] & 0x1f);
	dt->secs = BCD_TO_BIN(buf[RTC5C387_REG_SEC] & 0x7f);
	dt->mins = BCD_TO_BIN(buf[RTC5C387_REG_MIN] & 0x7f);
	dt->hours = BCD_TO_BIN(buf[RTC5C387_REG_HR] & 0x3f);
  xSemaphoreGive(smid);
}

static void rtc5c387_set_datetime(struct rtc_tm *dt, int datetoo)
{
	int i, len = 5;
	unsigned char buf[15];
  if(xSemaphoreTake(smid, 1) != pdTRUE)
  {
    display_string("RTC busy\r\n");
    return;
  }
	buf[RTC5C387_REG_CTRL1] = RTC5C387_CTRL1_24;
	buf[RTC5C387_REG_CTRL2] = RTC5C387_CTRL2_XSTP;
	buf[RTC5C387_REG_SEC] = BIN_TO_BCD(dt->secs);
	buf[RTC5C387_REG_MIN] = BIN_TO_BCD(dt->mins);
	buf[RTC5C387_REG_HR] = BIN_TO_BCD(dt->hours);
	if(datetoo)
	{
		len += 5;
		buf[RTC5C387_REG_DAY] = BIN_TO_BCD(dt->mday);
		buf[RTC5C387_REG_WDAY] = BIN_TO_BCD(dt->wday);
		buf[RTC5C387_REG_MON_CENT] = BIN_TO_BCD(dt->mon) & 0x1f;
		/* century stored in minute alarm reg */
		buf[RTC5C387_REG_YEAR] = BIN_TO_BCD(dt->year % 100);
		buf[RTC5C387_REG_AL_MIN] = BIN_TO_BCD(dt->year / 100);
	}
	for(i=0; i<len; i++)
		I2CsendByte(buf[i], i, RTC_ADDR);
 	I2CsendByte(0, RTC5C387_REG_CTRL2, 0);
  xSemaphoreGive(smid);
}

static int dayofweek(int year, int mon, int mday)
{
  static int doylookup[2][13] = {
   { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 },
   { 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 }};
  int doe,isleapyear;
  int era,cent,quad,rest;
  /* break down the year into 400, 100, 4, and 1 year multiples */
  rest = year-1;
  quad = rest/4;
  rest %= 4;
  cent = quad/25;
  quad %= 25;
  era = cent/4;
  cent %= 4;
  /* leap year every 4th year, except every 100th year,
     not including every 400th year. */
  isleapyear = !(year % 4) && ((year % 100) || !(year % 400));
  /* set up doe */
  doe = mday + doylookup[isleapyear][mon - 1];
  doe += era * (400 * 365 + 97);
  doe += cent * (100 * 365 + 24);
  doe += quad * (4 * 365 + 1);
  doe += rest * 365;
  return(doe %7);
}

unsigned long gettime(void)
{
  return((date << 16) + time);
} 

void settime(unsigned long datetime)
{
  dt_set.year = (datetime >> 25) + 1980;
  dt_set.mon = (datetime >> 21) & 0xF;
  dt_set.mday = (datetime >> 16) & 0x1F;
  dt_set.wday = (unsigned char)dayofweek((int)dt_set.year, (int)dt_set.mon, (int)dt_set.mday) + 1; /* day of week */
  dt_set.hours = (datetime >> 11) & 0x1F;
  dt_set.mins = (datetime >> 5) & 0x3F;
  dt_set.secs = (datetime & 0x1F) << 1;
  dt_set.set = 1;
}

void RTC_task(void)
{
  int ticks = 0, set_ok = 0;
  struct rtc_tm dt;
  date = time = 0;
  memset(&dt_set, 0, sizeof(struct rtc_tm));
  vSemaphoreCreateBinary(smid);
  if(smid == 0)
    vTaskDelete(0);
  I2Cinit();
  while(1)
  {
    if(dt_set.set)
    {
      rtc5c387_set_datetime(&dt, 1);
      dt_set.set = 0;
      set_ok = 1;
    }
    ticks++;
    if(ticks >= configTICK_RATE_HZ)
    {
      ticks = 0;
      if(set_ok)
      {
        rtc5c387_get_datetime(&dt);
        time = ((unsigned long)dt.hours << 11) + ((unsigned long)dt.mins << 5) + (unsigned long)(dt.secs >> 1);
        if(dt.hours && dt.mins && dt.secs && dt.year && dt.mon && dt.mday)
          date = ((((unsigned long)dt.year - 1980) & 0x7F) << 9) + ((unsigned long)dt.mon << 5) + (unsigned long)dt.mday;    
      }
    	vTaskDelay(1);
    }
    else  
	    vTaskDelay(1);
  }
}

#endif
#endif
#endif


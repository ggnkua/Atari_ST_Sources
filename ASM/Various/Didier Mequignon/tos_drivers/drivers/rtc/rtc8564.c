#include "config.h"
#include <string.h>
#include "../freertos/FreeRTOS.h"
#include "../freertos/FreeRTOSConfig.h"
#include "../freertos/task.h"
#include "../freertos/semphr.h"
#include ../lwip/net.h"
#include "mcf548x.h"

extern void display_string(char *string);

#define RTC_ADDR 0xA2
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
	unsigned char vl;
	unsigned char set;
};

#define RTC8564_REG_CTRL1		0x0 /* T  0 S 0 | T 0 0 0 */
#define RTC8564_REG_CTRL2		0x1 /* 0  0 0 TI/TP | AF TF AIE TIE */
#define RTC8564_REG_SEC			0x2 /* VL 4 2 1 | 8 4 2 1 */
#define RTC8564_REG_MIN			0x3 /* x  4 2 1 | 8 4 2 1 */
#define RTC8564_REG_HR			0x4 /* x  x 2 1 | 8 4 2 1 */
#define RTC8564_REG_DAY			0x5 /* x  x 2 1 | 8 4 2 1 */
#define RTC8564_REG_WDAY		0x6 /* x  x x x | x 4 2 1 */
#define RTC8564_REG_MON_CENT	0x7 /* C  x x 1 | 8 4 2 1 */
#define RTC8564_REG_YEAR		0x8 /* 8  4 2 1 | 8 4 2 1 */
#define RTC8564_REG_AL_MIN		0x9 /* AE 4 2 1 | 8 4 2 1 */
#define RTC8564_REG_AL_HR		0xa /* AE 4 2 1 | 8 4 2 1 */
#define RTC8564_REG_AL_DAY		0xb /* AE x 2 1 | 8 4 2 1 */
#define RTC8564_REG_AL_WDAY		0xc /* AE x x x | x 4 2 1 */
#define RTC8564_REG_CLKOUT		0xd /* FE x x x | x x FD1 FD0 */
#define RTC8564_REG_TCTL		0xe /* TE x x x | x x FD1 FD0 */
#define RTC8564_REG_TIMER		0xf /* 8 bit binary */

/* Control reg */
#define RTC8564_CTRL1_TEST1		(1<<3)
#define RTC8564_CTRL1_STOP		(1<<5)
#define RTC8564_CTRL1_TEST2		(1<<7)

#define RTC8564_CTRL2_TIE		(1<<0)
#define RTC8564_CTRL2_AIE		(1<<1)
#define RTC8564_CTRL2_TF		(1<<2)
#define RTC8564_CTRL2_AF		(1<<3)
#define RTC8564_CTRL2_TI_TP		(1<<4)

/* CLKOUT frequencies */
#define RTC8564_FD_32768HZ		(0x0)
#define RTC8564_FD_1024HZ		(0x1)
#define RTC8564_FD_32			(0x2)
#define RTC8564_FD_1HZ			(0x3)

/* Timer CTRL */
#define RTC8564_TD_4096HZ		(0x0)
#define RTC8564_TD_64HZ			(0x1)
#define RTC8564_TD_1HZ			(0x2)
#define RTC8564_TD_1_60HZ		(0x3)

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
    if(timeout-ReadTimer() >= TIMEOUT)
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
    if(timeout - ReadTimer() >= TIMEOUT)
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

static void rtc8564_get_datetime(struct rtc_tm *dt)
{
	int i;
	unsigned char buf[15];
  if(xSemaphoreTake(smid, portMAX_DELAY) != pdTRUE)
    return;
	for(i=0; i<15; i++)
		buf[i] = I2CreceiveByte(i, RTC_ADDR);
	/* century stored in minute alarm reg */
	dt->year = BCD_TO_BIN(buf[RTC8564_REG_YEAR]);
	dt->year += 100 * BCD_TO_BIN(buf[RTC8564_REG_AL_MIN] & 0x3f);
	dt->mday = BCD_TO_BIN(buf[RTC8564_REG_DAY] & 0x3f);
	dt->wday = BCD_TO_BIN(buf[RTC8564_REG_WDAY] & 7);
	dt->mon = BCD_TO_BIN(buf[RTC8564_REG_MON_CENT] & 0x1f);
	dt->secs = BCD_TO_BIN(buf[RTC8564_REG_SEC] & 0x7f);
	dt->vl = (buf[RTC8564_REG_SEC] & 0x80) == 0x80;
	dt->mins = BCD_TO_BIN(buf[RTC8564_REG_MIN] & 0x7f);
	dt->hours = BCD_TO_BIN(buf[RTC8564_REG_HR] & 0x3f);
  xSemaphoreGive(smid);
}

static void rtc8564_set_datetime(struct rtc_tm *dt, int datetoo)
{
	int i, len = 5;
	unsigned char buf[15];
  if(xSemaphoreTake(smid, 1) != pdTRUE)
  {
    display_string("RTC busy\r\n");
    return;
  }
	buf[RTC8564_REG_CTRL1] = RTC8564_CTRL1_STOP;
	buf[RTC8564_REG_CTRL2] = 0;
	buf[RTC8564_REG_SEC] = BIN_TO_BCD(dt->secs);
	buf[RTC8564_REG_MIN] = BIN_TO_BCD(dt->mins);
	buf[RTC8564_REG_HR] = BIN_TO_BCD(dt->hours);
	if(datetoo)
	{
		len += 5;
		buf[RTC8564_REG_DAY] = BIN_TO_BCD(dt->mday);
		buf[RTC8564_REG_WDAY] = BIN_TO_BCD(dt->wday);
		buf[RTC8564_REG_MON_CENT] = BIN_TO_BCD(dt->mon) & 0x1f;
		/* century stored in minute alarm reg */
		buf[RTC8564_REG_YEAR] = BIN_TO_BCD(dt->year % 100);
		buf[RTC8564_REG_AL_MIN] = BIN_TO_BCD(dt->year / 100);
	}
	for(i=0; i<len; i++)
		I2CsendByte(buf[i], i, RTC_ADDR);
 	I2CsendByte(0, RTC8564_REG_CTRL1, RTC_ADDR);
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
      rtc8564_set_datetime(&dt_set, 1);
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

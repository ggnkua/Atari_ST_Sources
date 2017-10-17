#ifndef _FLASH_H_
#define _FLASH_H_

#define   _1MBYTE	0x01000000
#define   _2MBYTE	0x01000000
#define   _4MBYTE	0x01000000
#define   _8MBYTE	0x01000000
#define  _16MBYTE	0x01000000
#define  _32MBYTE	0x02000000
#define  _64MBYTE	0x04000000
#define _128MBYTE	0x08000000
#define _256MBYTE	0x10000000
#define _512MBYTE	0x20000000
#define   _1GBYTE	0x40000000
#define   _2GBYTE	0x80000000
#define   _4GBYTE	0x0000000100000000
#define   _8GBYTE	0x0000000200000000
#define  _16GBYTE	0x0000000400000000
#define  _32GBYTE	0x0000000800000000
#define  _64GBYTE	0x0000001000000000

typedef long long					INT64;
typedef volatile long long			VINT64;
typedef unsigned long long			UINT64;
typedef volatile unsigned long long	VUINT64;
typedef long						INT32;
typedef volatile long				VINT32;
typedef unsigned long				UINT32;
typedef volatile unsigned long		VUINT32;
typedef short						INT16;
typedef volatile short				VINT16;
typedef unsigned short				UINT16;
typedef volatile unsigned short		VUINT16;
typedef char						INT8;
typedef volatile char				VINT8;
typedef unsigned char				UINT8;
typedef volatile unsigned char		VUINT8;




#define FLASHBASE 0xFC000000

#define PASS    0
#define SUCCESS 0
#define FAIL    1


// Manufacturer IDs
#define MANUFACTURER_AMD	0x01
#define MANUFACTURER_MBM	0x04	/* Fujitsu */
#define MANUFACTURER_AT		0x1F	/* Atmel */
#define MANUFACTURER_STM	0x20	/* STMicroelectronix */
#define MANUFACTURER_HY		0xAD	/* Hyundai */
#define MANUFACTURER_SST	0xBF	// SST
#define MANUFACTURER_MX		0xC2	/* Macronix */
#define MANUFACTURER_INT	0x89	// Intel

// Intel Strata Devices
#define DEVCODE_28F640K3	0x8801
#define DEVCODE_28F128K3	0x8802
#define DEVCODE_28F256K3	0x8803
#define DEVCODE_28F320J3	0x0016
#define DEVCODE_28F640J3	0x0017
#define DEVCODE_28F128J3	0x0018
#define DEVCODE_28F256J3	0x001d


#ifndef NULL
   #define NULL ((void *) 0)
#endif

typedef struct
{
	unsigned int n;		/* number of sectors */
	unsigned int size;	/* size of sector */
} sector_tab_t;

typedef struct
{
  unsigned short	Device;
  char				Manufactur;
  char				*DeviceName;
  unsigned long		Capacity;
  sector_tab_t		*SectorTable;
} Descriptor;


typedef struct
{
	unsigned int addr;
	unsigned int length;
	unsigned int usage;
} sector_t;


#define Am29F200AT 0x2251
#define Am29F400AB 0x22AB
#define Am29F800B  0x225B

#define Am29LV200B	0x22BF
#define Am29LV400B	0xffBA
#define Am29LV800B	0x22DA

extern unsigned int FlashBase;

unsigned char FlashIdentify(void);
void UnprotectCSBOOT(void);
void ProtectCSBOOT(void);
unsigned long EraseFlash(unsigned long Begin, unsigned long End);
unsigned long ResetFlash(void);
unsigned long ProgFlash(unsigned long Address, unsigned long Code);

void FlashStatus(Descriptor *);
Descriptor * GetFlashDevice(Descriptor * DeviceData);
unsigned long ReadFlash(unsigned long Address);
void WriteFlash(unsigned long Address, unsigned long Code);

unsigned long ReadFlashStatusReg(unsigned long Address);
void ClearFlashStatusReg(void);
void ResumeFlash(void);
void UnlockFlashBlock(unsigned long Address);
void UnlockFlashBlockAll(void);

#endif

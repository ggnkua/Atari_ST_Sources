
#include <stdio.h>
#include "flash.h"

/* Intel Strata 28F640K3 in x32 access */
static sector_tab_t sector_INT28F640K3[] =
{
	{ 64, 0x20000}, { 0, 0}
};

/* Intel Strata 28F128K3 in x32 access */
static sector_tab_t sector_INT28F128K3[] =
{
	{ 128, 0x20000}, { 0, 0}
};

/* Intel Strata 28F256K3 in x32 access */
static sector_tab_t sector_INT28F256K3[] =
{
	{ 256, 0x20000}, { 0, 0}
};

/* Intel Strata 28F320J3 in x32 access */
static sector_tab_t sector_INT28F320J3[] =
{
	{ 32, 0x20000}, { 0, 0}
};

/* Intel Strata 28F640J3 in x32 access */
static sector_tab_t sector_INT28F640J3[] =
{
	{ 64, 0x20000}, { 0, 0}
};

/* Intel Strata 28F128J3 in x32 access */
static sector_tab_t sector_INT28F128J3[] =
{
	{ 128, 0x20000}, { 0, 0}
};

/* Intel Strata 28F256J3 in x32 access */
static sector_tab_t sector_INT28F256J3[] =
{
	{ 256, 0x20000}, { 0, 0}
};

Descriptor DeviceTable[] =
{
  0x0000, 0x00, "unknown", 0x00000000, NULL,
  0x8801, 0x89, "Intel 28F640K3", 0x800000, sector_INT28F640K3,
  0x8802, 0x89, "Intel 28F128K3", 0x1000000, sector_INT28F128K3,
  0x8803, 0x89, "Intel 28F256K3", 0x2000000, sector_INT28F256K3,
  
  0x0016, 0x89, "Intel 28F320J3", 0x0400000, sector_INT28F320J3,
  0x0017, 0x89, "Intel 28F640J3", 0x0800000, sector_INT28F640J3,
  0x0018, 0x89, "Intel 28F128J3", 0x1000000, sector_INT28F128J3,
  0x001d, 0x89, "Intel 28F256J3", 0x2000000, sector_INT28F256J3,
};
 

void f_Wait(unsigned long times);

unsigned int FlashBase=FLASHBASE;

Descriptor * GetFlashDevice(Descriptor * DeviceData)
{
  int i;
  
  for(i = 0; i < (sizeof(DeviceTable) / sizeof(Descriptor)); i++)
  {
    if((DeviceTable[i].Device  == DeviceData->Device) && (DeviceTable[i].Manufactur == DeviceData->Manufactur))
    {
    	return(&DeviceTable[i]);
	}
  }
  
  return(&DeviceTable[0]);  
}      

void FlashStatus(Descriptor * CurrentDevice)
{
  unsigned long Result;
  
  *(volatile unsigned long *) FlashBase = 0x00900090;
  Result = *(volatile unsigned long *) FlashBase;
  (&CurrentDevice[0])->Manufactur = (char) Result;
  (&CurrentDevice[1])->Manufactur = (char) (Result>>16);
  
  *(volatile unsigned long *) (FlashBase+4) = 0x00900090;
  Result = *(volatile unsigned long *) (FlashBase+4);
  (&CurrentDevice[0])->Device = (unsigned short) *(volatile unsigned long *) (FlashBase+4);
  (&CurrentDevice[1])->Device = (unsigned short) ((*(volatile unsigned long *) (FlashBase+4))>>16); 
  
  ResetFlash();
}

void UnlockFlashBlock(unsigned long Address)
{
	unsigned int result;
	
	*(volatile unsigned long *) Address = 0x00600060;
	*(volatile unsigned long *) Address = 0x00D000D0;
	
	while(((result=ReadFlashStatusReg(Address)) & 0x00800080) != 0x00800080);
}

void UnlockFlashBlockAll(void)
{
	unsigned long i = 0, n, Address;
	Descriptor CurrentDevice[2], *FlashDevice;

	FlashStatus(CurrentDevice);
	FlashDevice = GetFlashDevice(&CurrentDevice[0]);
	
	switch(FlashDevice->Device)
	{
		case DEVCODE_28F640K3:
		case DEVCODE_28F128K3:
		case DEVCODE_28F256K3:
			while(FlashDevice->SectorTable[i].n != 0)
			{
				for(n = FlashDevice->SectorTable[i].n; n>0; n--)
				{ 
					Address = FlashBase + (n-1) * FlashDevice->SectorTable[i].size * 2;	// due to 32-Bit wide organisation
					UnlockFlashBlock(Address);			
				}
				
				i++;
			}
			break;

		case DEVCODE_28F320J3:
		case DEVCODE_28F640J3:	
		case DEVCODE_28F128J3:
		case DEVCODE_28F256J3:
			UnlockFlashBlock(FlashBase);
			break;
	}
	
	ResumeFlash();
}

unsigned long ReadFlashStatusReg(unsigned long Address)
{
	*(volatile unsigned long *) Address = 0x00700070;
	
	return(*(volatile unsigned long *) Address);
}

void ClearFlashStatusReg(void)
{
	*(volatile unsigned long *) FlashBase = 0x00500050;
}

void ResumeFlash(void)
{
	*(volatile unsigned long *) FlashBase = 0x00D000D0;
}

unsigned long ReadFlash(unsigned long Address)
{
	return ( * ((volatile unsigned long *) Address) );
}

void WriteFlash(unsigned long Address, unsigned long Code)
{
	*((volatile unsigned long *) Address) = Code;
}

unsigned long ProgFlash(unsigned long Address, unsigned long Code)
{

	ClearFlashStatusReg();

	*(volatile unsigned long *) Address = 0x00400040;
	*(volatile unsigned long *) Address = Code;
	
	while((ReadFlashStatusReg(Address) & 0x00800080) != 0x00800080);
	
	*(volatile unsigned long *) Address = 0xFFFFFFFF;
  
   return(SUCCESS);
}    

unsigned long EraseFlash(unsigned long Begin, unsigned long End)
{
	unsigned long i = 0, n, Address;
	Descriptor CurrentDevice[2], *FlashDevice;

	Address = FLASHBASE;
	FlashStatus(CurrentDevice);
	FlashDevice = GetFlashDevice(&CurrentDevice[0]);
	
	if(CurrentDevice[0].Device != CurrentDevice[1].Device) return FAIL;

	while(FlashDevice->SectorTable[i].n != 0)
	{
		for(n = FlashDevice->SectorTable[i].n; n>0; n--)
		{
      if((Address >= (Begin & ~(FlashDevice->SectorTable[i].n-1))) && (Address < End))
      {  
  			ClearFlashStatusReg();
  			WriteFlash(FlashBase + (n-1) * FlashDevice->SectorTable[i].size * 2, 0x00200020);
			  WriteFlash(FlashBase + (n-1) * FlashDevice->SectorTable[i].size * 2, 0x00D000D0);
			  while((ReadFlashStatusReg(FlashBase + (n-1) * FlashDevice->SectorTable[i].size * 2) & 0x00800080) != 0x00800080);
      }
			Address += FlashDevice->SectorTable[i].n;
		}
		i++;
	}
	
	ResumeFlash();
	
	return(SUCCESS);
}

unsigned long ResetFlash(void)
{
	*((unsigned long *) FlashBase) = 0xFFFFFFFF;
	
	return(0);
}

void UnprotectCSBOOT(void)
{
} 

void ProtectCSBOOT(void)
{
}

unsigned char FlashIdentify(void)
{
	Descriptor CurrentDevice[2], *FlashDevice;

	FlashStatus(CurrentDevice);
//	printf("FLASH U5\t");
	FlashDevice = GetFlashDevice(&CurrentDevice[0]);
//	printf(FlashDevice->DeviceName);
//	printf("\r\n");
//	printf("FLASH U6\t");
	FlashDevice = GetFlashDevice(&CurrentDevice[1]);
//	printf(FlashDevice->DeviceName);
//	printf("\r\n");
	return 0;
}

  
void f_Wait(unsigned long times)
{
  unsigned long n;

  for(n = 0; n < times; n++) {};
}
  

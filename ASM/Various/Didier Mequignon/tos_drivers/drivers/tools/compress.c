#include <mint/osbind.h>
#include <string.h>
#include <stdio.h>
#include "lz.h"
#include "../../include/main.h"

extern int srec_read(const char *path);
void *buffer_flash=NULL;
extern unsigned long start_addr,end_addr;

int main(int argc, char **argv)
{
	char *sbuf=NULL,*dbuf=NULL;
	int *work=NULL;
	long length, clength;
	short handle=-1;
	unsigned long size_pci_drivers;
	char *buffer_pci_drivers=NULL;
	if(argc!=3)
	{
		printf("Usage: compress input output\r\n");
		return(-1);
	}
	if(strstr(argv[1], ".hex") != NULL)	
	{
		if((buffer_flash = (char *)Mxalloc(0x200000,3)) == NULL)
		{
			printf("Not enough memory\r\n");
			return(-1);
		}
		memset(buffer_flash, -1, 0x200000);
		if(srec_read(argv[1]))
		{
			printf("Error with HEX file pci drivers\r\n");
			return(-1);
		}
		if((start_addr < FLASH_ADR) || (start_addr >= (FLASH_ADR2+FLASH_SIZE2)))
		{
			printf("Error with HEX file, bad start address\r\n");
			return(-1);
		}
		if((end_addr < FLASH_ADR) || (end_addr >= (FLASH_ADR2+FLASH_SIZE2)))
		{
			printf("Error with HEX file, bad end address\r\n");
			return(-1);
		}
		if(end_addr <= start_addr)
		{
			printf("Error with HEX file, end address < start address\r\n", NULL);
			return(-1);
		}
		if(end_addr >= FLASH_ADR2)
		{
			memcpy(buffer_flash+0x100000,buffer_flash+FLASH_ADR2-FLASH_ADR,end_addr-FLASH_ADR2);
			size_pci_drivers = FLASH_ADR+0x100000-start_addr + end_addr-FLASH_ADR2;
		}
		else
			size_pci_drivers = end_addr-start_addr;
		buffer_pci_drivers = buffer_flash+start_addr-FLASH_ADR;
		if((work = (int *)Mxalloc(sizeof(int)*(size_pci_drivers+65536),3)) == NULL)
		{
			printf("Not enough memory for compress work buffer\r\n");
			return(-1);
		}
		if((dbuf = (unsigned char *)Mxalloc(FLASH_SIZE-PARAM_SIZE,3)) == NULL)
		{
			printf("Not enough memory for target buffer\r\n");
			goto error;
		}		
		printf("compress drivers part %d bytes (0x%08lX-0x%08lX)... \r\n", (int)size_pci_drivers, start_addr, end_addr);
		clength = (long)LZ_CompressFast(buffer_pci_drivers, dbuf+8, (int)size_pci_drivers, work);
		printf("compress %s (%d) to %s (%d)\r\n", argv[1], (int)size_pci_drivers, argv[2], (int)clength);
		if((unsigned long)clength > FLASH_ADR+FLASH_SIZE-PARAM_SIZE-start_addr-8)
		{
			printf("Not enough memory for put compressed drivers in flash.");
			goto error;
		}
		dbuf[0] = dbuf[3]='_'; /* add header */
		dbuf[1] = 'L';
		dbuf[2] = 'Z';
		*(long *)&dbuf[4] = clength;
		clength += 8;
	}
	else /* binary file */
	{
		handle=Fopen(argv[1], 0);
		if(handle<0)
			return(-1);
		length = Fseek(0, handle, 2);
		if(length <= 0)
		{
			Fclose(handle);
			return(-1);
		}
		Fseek(0, handle, 0);
		sbuf = (char *)Mxalloc(length, 3);
		work = (int *)Mxalloc(sizeof(int)*(length+65536), 3);
		dbuf = (char *)Mxalloc(length*11/10, 3);
		if(sbuf == NULL || work == NULL || dbuf == NULL)
			goto error;
		if(Fread(handle, length, sbuf) != length)
			goto error;
		Fclose(handle);
	  *(long *)dbuf = (long)length;
		clength = (long)LZ_CompressFast(sbuf, dbuf+4, (int)length, work) + 4;
		printf("compress %s (%d) to %s (%d)\r\n", argv[1], (int)length, argv[2], (int)clength);
	}
	handle=Fcreate(argv[2], 0);
	if(handle < 0)
	{
error:
		if(buffer_flash!= NULL)
			Mfree(buffer_flash);
		if(sbuf!=NULL)
			Mfree(sbuf);
		if(work!=NULL)
			Mfree(work);
		if(dbuf!=NULL)
			Mfree(dbuf);
		if(handle >= 0)
			Fclose(handle);
		return(-1);
	}
	if(Fwrite(handle, clength, dbuf) != clength)
	{
		printf("Writing error\r\n");
		goto error;
	}
	Fclose(handle);
	if(buffer_flash!= NULL)
		Mfree(buffer_flash);
	if(sbuf!=NULL)
		Mfree(sbuf);
	if(work!=NULL)
		Mfree(work);
	if(dbuf!=NULL)
		Mfree(dbuf);
	return(0);
}

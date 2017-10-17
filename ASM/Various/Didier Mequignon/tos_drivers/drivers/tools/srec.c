/* Drivers, HEX part
*  Didier Mequignon 2010, e-mail: aniplay@wanadoo.fr
*
*  This program is free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 2 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software
*  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <osbind.h>
#include <stdio.h>
#include <string.h>
#include "../../include/main.h"

extern void *buffer_flash;
unsigned long start_addr,end_addr;

const unsigned char nibble[256] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0,
  0,10,11,12,13,14,15, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0,10,11,12,13,14,15, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

long stegf(char * buf,long len,int handle)
{
	char *cp;
	long ret,pos;
	pos=Fseek(0L,handle,1);
	ret=Fread(handle,len,buf);
	while(ret>=0 && (cp=strchr(buf,'\n')) != 0)
	{
		*cp = 0;
		pos++;
	}
	while(ret>=0 && (cp=strchr(buf,'\r')) != 0)
	{
		*cp = 0;
		pos++;
	}
	if(ret<0)
		ret=0;
	else
	{
		if(Fseek(pos+strlen(buf),handle,0)<0)
			ret=0;
	}
	return(ret);
}

int strneq(const char *s1,const char *s2)
{
	return(strncmp(s1,s2,strlen(s2))==0);
}

void getbytes(char *line,long addr_bytes)
{
	unsigned long count,offset;
	unsigned char *p; 
	long i,j;
	unsigned char asciiByte[64];

	for(i=0;*line;line+=2,i++)
		asciiByte[i] = (nibble[(unsigned)line[0]] << 4) | nibble[(unsigned)line[1]];
	j = 2 + addr_bytes;
	count = (unsigned long)asciiByte[1] - addr_bytes - 1;
	switch(addr_bytes)
	{
		case 2: offset = ((unsigned long)asciiByte[2] << 8) + (unsigned long)asciiByte[3]; break;
		case 3: offset = ((unsigned long)asciiByte[2] << 16) + ((unsigned long)asciiByte[3] << 8) + (unsigned long)asciiByte[4]; break;
		case 4: offset = ((unsigned long)asciiByte[2] << 24) + ((unsigned long)asciiByte[3] << 16) + ((unsigned long)asciiByte[4] << 8) + (unsigned long)asciiByte[5]; break;
		default: return;
	}
	if(offset < start_addr)
		start_addr=offset;
	if((offset+count) > end_addr)
		end_addr=offset+count; 
	p=(unsigned char *)buffer_flash;
	p+=(offset-FLASH_ADR);
	if((offset >= FLASH_ADR)
	 && ((offset+count) < (FLASH_ADR2+FLASH_SIZE2)))
		memcpy(p, &asciiByte[j], count);
}

int srec_read(const char *path)
{
	int handle,rt;
	char line[256];
	long line_count=0;
	start_addr=0xFFFFFFFF;
	end_addr=0;
	if((handle=(int)Fopen(path,0))<0)
		return(handle);
	while(stegf(line,100,handle))
	{
		if(strneq(line,"S0")) rt=0;
		else if(strneq(line,"S1")) rt=1;
		else if(strneq(line,"S2")) rt=2;
		else if(strneq(line,"S3")) rt=3;
		else if(strneq(line,"S7")) rt=7;
		else if(strneq(line,"S8")) rt=8;
		else if(strneq(line,"S9")) rt=9;
		else
		{
			Fclose(handle);
			return(-1);
		}
		line_count++;
		switch(rt)
		{
			case 0: break;
			case 1: getbytes(line,2); break;
			case 2: getbytes(line,3); break;
			case 3: getbytes(line,4); break;
			case 7:
			case 8:
			case 9: Fclose(handle); return(0);
		}
	}
	Fclose(handle);
	return(0);
}



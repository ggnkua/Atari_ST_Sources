/*
 * malltest.c
 *
 *  Created on: 01.06.2013
 *      Author: mfro
 */

#include <stdio.h>
#include <stdlib.h>
#include <mint/osbind.h>
#include <assert.h>

int main(int argc, char *argv[])
{
	char str[1024];
	int i;
	char *endp;

	for (i = 0; i < 10; i++)
	{
		sprintf(str, "this is test #%d\r\n", i);
		Cconws(str);
	}

	for (i = 0; i < 10; i++)
	{
		sprintf(str, "this is test #%f\r\n", (float) i);
		Cconws(str);
	}

	sprintf(str, "This %s %d complex %s%s", "is", 1, "test", "\r\n");
	Cconws(str);
	printf("little test: %x, %d, %f\r\n", 0xff, 12345, 3.1415926);

	i = snprintf(NULL, 0, "%d", 100);
	assert(i == 3);
	
	#define	_strtol(v) do{ printf("strtol(\"" v "\") => %x", strtol(v,&endp,0)); printf(*endp ? " Rest:%s\n\r":"\n\r", endp); } while(0)
	#define	_strtoul(v) do{ printf("strtoul(\"" v "\") => %x", strtoul(v,&endp,0)); printf(*endp ? " Rest:%s\n\r":"\n\r", endp); } while(0)
	_strtol("0x5050");
	_strtol("0b1010");
	_strtol("077");
	_strtol("-0x5050");
	_strtol("0xDEADBEEF");
	_strtol("10kg");

	_strtoul("0x5050");
	_strtoul("0b1010");
	_strtoul("077");
	_strtoul("-0x5050");
	_strtoul("0xDEADBEEF");
	_strtoul("10kg");
	
	
	Cconws("press a key to return to desktop\r\n");
	Cconin();
}


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>
#include "driver.h"

int main(int argc, char *argv[])
{
long basepage,result;
struct driver driver;
char buf[100];
int mode;

	printf("X-Debug Screen Driver Test Program 1.0\n");
	if (argc!=2)
		{
		printf("usage: testscr <driver.scr>\n");
		return 10;
		}
	mode=0;

	sprintf(buf+1,"VER=%x BUF=%lx MODE=%x",1,&driver,mode);
	buf[0]=(char)strlen(buf);
	
	basepage=Pexec(3,argv[1],buf,"\0\0");
	if (basepage<0)
		{
		printf("Cannot load %s\n",argv[1]);
		return 10;
		}
	
	result=Pexec(4,NULL,basepage,NULL);
	printf("\nmain() returned %ld\n\n",result);
	if (result)
		return 0;
	printf("Address   : $%lX\n",driver.address);
	printf("Planes    : %d\n",driver.planes);
	printf("Bytes/line: %d\n",driver.bytesperline);
	printf("Pixel size: %dx%d\n",(int)(driver.width),(int)(driver.height));
	printf("GEM output: %s\n",driver.gem ? "Yes" : "No" );
	printf("TOS output: %s\n",driver.tos ? "Yes" : "No" );
	printf("RAM       : $%lX-$%lX\n",driver.start,driver.end);
	
	if (driver.font!=-1)
		printf("ERROR: font not -1\n");
	if (driver.width>1280)
		printf("ERROR: wider than 1280\n");
	if (driver.height>1024)
		printf("ERROR: taller than 1024\n");
	
	printf("\n\nInitialise Y/N?");
	gets(buf);
	if ( (buf[0]=='y') || (buf[0]=='Y') )
		{
		short init;
		init=driver.init();
		if (init)
			printf("init() returned %d\n",(int)init);
		}
	return 0;
	
}

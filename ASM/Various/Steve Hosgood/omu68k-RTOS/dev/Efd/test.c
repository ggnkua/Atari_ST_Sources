#include	"../../include/buf.h"

extern	long edata, end;

main(){
	struct buf buffer;
	int bno, dev;
	char str[100];
	char *address;

	for(address = (char *)edata; address < (char *)end; address++)
		*address = 0;
	printf("Input device no: ");
	gets(str);
	printf("%s\n\r",str);
	dev = atoi(str);
	fdopen(dev);
	while(1){
		printf("Input buffer no: ");
		gets(str);
		printf("%s\n\r",str);
		bno = atoi(str);
		buffer.b_bno = bno;
		buffer.b_dev = dev;
		buffer.b_flags &= ~WRITE;
		printf("Dev %d, bno %d\n\r",buffer.b_dev,buffer.b_bno);
		fdstrat(&buffer);
		tsecout(&buffer);
	}
}
gets(str)
char *str;
{
	while((*str++ = getchar()) != '\r');
	*(--str) = 0;
}

#define NOPERLINE	16	/* No bytes perline  */
#define	TAB		09
#define	CR		0x0D

char *bascii();

tsecout(buf)
char *buf;
{
	char ch;

	while(1){
		printf("\n\rP - print, CR - continue ");
		ch=getchar();
		switch(ch){
		case 'P':
			convert(buf);
			break;
		case CR:
			return;
		}
	}
}

convert(buf)
char *buf;
{
	int n,count;
	char buffer1[16], *ptr1, buffer2[256], *ptr2;
	char ascii[4];

	count=32;
	while(count--){
		if(count==16) getchar();
		ptr1=buffer1;
		n=NOPERLINE;
		while(n--) *ptr1++ = *buf++;
		ptr1=buffer1;
		ptr2=buffer2;
		n=NOPERLINE;
		while(n--){
			ptr2=bascii(ptr2,*ptr1++);
		}
		n=NOPERLINE;
		*(ptr2-1)=TAB;
		*ptr2++ ='*';
		ptr1=buffer1;
		for(n=NOPERLINE; n>0; n--){
			if(!(*ptr1&0x80)&&(*ptr1>0x1F)&&(*ptr1<0x7F))
				*ptr2++ = *ptr1;
			else *ptr2++ = '.';
			ptr1++;
		}
		*ptr2++ ='\n';
		*ptr2++ ='\r';
		*ptr2++ = 0;
		ptr2=buffer2;
		while(*ptr2 !=0) putchar(*ptr2++);
	}
}
char *bascii(str,byte)
char *str, byte;
{
	int n;

	if((n=((byte>>4)&0xF)+'0')>'9') n+=7;
	*str++ =n;
	if((n=(byte&0xF)+'0')>'9') n+=7;
	*str++ =n;
	*str++ =',';
	return str;
}

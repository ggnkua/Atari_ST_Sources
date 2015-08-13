#include <stdio.h>
#include <ctype.h>

FILE    *Sfile = NULL;
int     checksum = 0;

#define S1MAX   0xFFFF
#define S2MAX   0xFFFFFF

srecinit(s)
char *s;
{
	if( (Sfile = fopen(s,"w")) == NULL )
		fatal("Can't open output file");
	srec('0',strlen(s),0,s);
}

srecdata(count,addr,buf)
int count;
unsigned addr;
char *buf;
{
	char	type;

	if( addr <= S1MAX )
		type = '1';
	else if( addr <= S2MAX )
		type = '2';
	else
		type = '3';
	srec(type,count,addr,buf);
}

srecend(addr)
int addr;
{
	char	type;

	if( addr <= S1MAX )
		type = '9';
	else if(addr <=S2MAX)
		type = '8';
	else
		type = '7';
	srec(type,0,addr,&type);
	fclose(Sfile);
}

srec(type,count,addr,buf)
char type;
int count;      /* number of data bytes */
unsigned addr;
char *buf;      /* data bytes */
{
	static int alen[10] = { 2, 2, 3, 4, 0, 0, 0, 4, 3, 2 };

	fprintf(Sfile,"S%c",type);    /* record header */
	checksum = 0;
	put2hex(count+alen[type-'0']+1);
	switch(alen[type-'0']){
	case 4:
		put2hex(addr>>24);
	case 3:
		put2hex(addr>>16);
	case 2:
		put2hex(addr>>8);
		put2hex(addr);
		}
	while(count--)
		put2hex(*buf++);

	put2hex(~checksum);
	fprintf(Sfile,"\n");
}

/*
 *      put2hex --- print low byte of integer in hex
 *
 *      Also, update checksum
 */
put2hex(b)
int b;
{
	static char hexstr[] = "0123456789ABCDEF";

	b &= 0xFF;
	fprintf(Sfile,"%c%c",hexstr[(b>>4)&0xF],hexstr[b&0xF]);
	checksum += b;
}

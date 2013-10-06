
#include <stdio.h>
#include "dspbind.h"

char ch;
long memtype;

main()
{
	Dsp_LoadProg("dbprog.lod",3);
	interface();
}

send_info(memtype,addr,count)
long memtype;
long addr,count;
{
   printf("memtype = %D\n",memtype);
   printf("address = %D\n",addr);
   printf("count = %D\n",count);
   addr = addr << 8;
   count = count << 8;
   memtype = memtype << 8;
/*   Dsp_TriggerHC(0x14); */
   Dsp_DoBlock(&memtype,1L,0L,0L);
   Dsp_DoBlock(&addr,1L,0L,0L);
   Dsp_DoBlock(&count,1L,0L,0L);
}

long get_data()
{
   long temp;
   Dsp_DoBlock(0L,0L,&temp,1L);
   return(temp);
}

interface()
{
	long	addr;
	long	cnt,i,num;
	char	str[6];
	int	cols, maxcols = 8;

cnt = 1L;
while(cnt !=0L )
{
/* Get user inputs */
	printf("[Address] > ");	
	scanf("%c %X",&ch, &addr);
	while(getchar() != '\n');
	printf("[Count] > ");
	scanf("%D", &cnt);
	while(getchar() != '\n');
	if(ch == 'X' || ch == 'x')
	   memtype = 1L;
	else if(ch == 'Y' || ch == 'y')
	   memtype = 2L;	
	else
	   memtype = 0L;			/* Default p space */
	send_info(memtype,addr,cnt);	

/* Convert integer data to string then output only high 24 bits (32-9)  */
/* of long in rows of eight columns.					*/
	cols = 1;
	for (i=0; i<cnt; i++)
	{
		(long)num = get_data();
		word_to_hex( num, str );
		printf("%6s ",str);

		if (cols++ == maxcols)
		{
			printf("\n");
			cols = 1;
		}
	}
	printf("\n");
}
}
char
hex_convert( i )
long i;
{
    if ( i < 10 )
	return( i + '0' );
    else
	return( i - 10 + 'A' );
}

/* converts a word into ASCII in the form of "0xXXXX" where the X's
 * hex digits.
 */
word_to_hex( num, str )
long num;
char *str;
{
    long i, mask;

    str[6] = '\0';

    mask = 0x00000F00;
    i = num & mask;
    str[5] = hex_convert( (i >> 8) & 0x0000000F );
    mask = 0x0000F000;
    i = num & mask;
    str[4] = hex_convert( (i >> 12) & 0x0000000F );
    mask = 0x000F0000;
    i = num & mask;
    str[3] = hex_convert( (i >> 16) & 0x0000000F );
    mask = 0x00F00000;
    i = num & mask;
    str[2] = hex_convert( (i >> 20) & 0x0000000F );
    mask = 0x0F000000;
    i = num & mask;
    str[1] = hex_convert( (i >> 24) & 0x0000000F );
    mask = 0xF0000000;
    i = num & mask;
    str[0] = hex_convert( (i >> 28) & 0x0000000F );

}


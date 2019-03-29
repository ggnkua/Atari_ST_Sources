
/*
	Program Name:   KEYMAP.PRG
	
	Description:    Prints out the keyboard translate tables as C source
			code. Also identifies where in memory the table is
			currently located.

	Author:	 	Greg Baker

	Date:		02/01/1988
*/

#include <osbind.h>
#include <xbios.h>

showmap(map,p)
register char *map,*p;
{
	register int i,j,s,e;
	printf("char %s[128] = {           /* @%06lx */\n",map,p);
	s=0;
	e=7;
	
	for (i=0;i<16;i+=1) {
	putchar('\t');
	for(j=0;j<8;j+=1) {
		printf("0x%02x",*p++ & 0xff);
		if(i <15 && j<7)
			printf(",");
		if(i==15 && j<7)
			printf(",");
		if(i==15 && j==7)
			printf("\t/* %02x - %02x */",s,e);
		if(i<15 && j==7) {
			printf("\t/* %02x - %02x */",s,e);
			s+=8;
			e+=8;
			}
	}
	putchar('\n');
	}
	printf("};\n");
}

main() {
	struct keytbl *kp;
/* 
   the following line of code gets the pointer to the keyboard translate
   tables. -1L says to leave that particular table alone. To set up new
   tables use Keytbl(normal,shifted,capslock) where the three values point
   to the related translate table. Note that you can change any or all 
   tables by using -1L for the ones you don't want to change.
*/
	kp = Keytbl(-1L,-1L,-1L);
	showmap("normal",kp->kt_normal);
	showmap("shifted",kp->kt_shifted);
	showmap("capslock",kp->kt_capslock);
	return;
}

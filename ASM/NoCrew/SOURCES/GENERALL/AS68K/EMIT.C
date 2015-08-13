#include <stdio.h>
#include "as.h"

int     E_total =0;             /* total # bytes for one line           */
char    E_bytes[E_LIMIT] = {0}; /* Emitted held bytes                   */
int     E_pc =0;                /* Pc at beginning of collection        */

int     P_force = 0;            /* force listing line to include Old_pc */
int     P_total =0;             /* current number of bytes collected    */
int     P_bytes[P_LIMIT] = {0}; /* Bytes collected for listing          */

extern int Pc;
extern int Pass;
extern char Line[];

/*
 *      elong --- emit a long to code file
 */
elong(wd)
int wd;
{
	eword(hiword(wd));
	eword(loword(wd));
}

/*
 *      eword --- emit a word to code file
 */
eword(wd)
int     wd;
{
	emit(hibyte(wd));
	emit(lobyte(wd));
}

/*
 *      emit --- emit a byte to code file
 */
emit(byte)
{
	if(Pass==1)
		Pc++;
	else{
		if(P_total < P_LIMIT)
			P_bytes[P_total++] = byte;
		E_bytes[E_total++] = byte;
		Pc++;
		if(E_total == E_LIMIT)
			f_record();
		}
}

/*
 *      f_record --- flush record out in `S1' format
 */
f_record()
{
	if(Pass == 1)
		return;
	if(E_total==0){
		E_pc = Pc;
		return;
		}
	srecdata(E_total,E_pc,E_bytes);
	E_pc = Pc;
	E_total = 0;
}

/*
 *      print_line --- pretty print input line
 */
print_line()
{
	int     i;
	register char *ptr;
	extern int Old_pc;

	if(P_total || P_force)
		printf("%08x",Old_pc);
	else
		printf("        ");

	for(i=0;i<P_total && i<6;i++){
		if((i&1)==0)printf(" ");
		printf("%02x",lobyte(P_bytes[i]));
		}
	for(;i<6;i++)
		if( i&1 )
			printf("  ");
		else
			printf("   ");
	printf(" ");

	ptr = Line;
	while( *ptr != '\n' )   /* just echo the line back out */
		putchar(*ptr++);
	for(;i<P_total;i++){
		if( i%6 == 0 )
			printf("\n        ");
		if( (i&1)==0 )printf(" ");
		printf("%02x",lobyte(P_bytes[i]));
		}
	printf("\n");
}


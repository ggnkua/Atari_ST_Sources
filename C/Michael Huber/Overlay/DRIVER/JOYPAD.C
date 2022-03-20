/*
  Jaguar-Joypad-Abfrage
  fÅr STE und Falcon030 
  Patrick Jerchel/Michael Huber
  (c) 1994
*/

#include <stdio.h>
#include <tos.h>
#include <setjmp.h>

#define JOY00 (volatile int*)0xff9200L
#define JOY02 (volatile int*)0xff9202L
#define JOYPAD2

/*
 * Modulglobales.
 */
static jmp_buf jmpbuf;

/* -----------------------------------------------------------------
 * f_exception()
 * -----------------------------------------------------------------
 * Interrupt-Routine, die mit longjmp zurÅckkehrt.
 * -----------------------------------------------------------------
 */
void f_exception(void)
{
	longjmp(jmpbuf, 1);
	/* Der zweite Parameter 1 wird weiterverwendet! Nicht Ñndern. */
}

/* -----------------------------------------------------------------
 * reg_wordtest(int *reg, int rxw)
 * -----------------------------------------------------------------
 * Teste, ob der Inhalt der Adresse *reg gelesen (rxw==1) oder 
 * beschrieben (rxw==0) werden kann.
 * Ergebnis: 1 wenn Register lesbar, 0 wenn nicht.
 * -----------------------------------------------------------------
 */
int reg_wordtest(volatile int *reg, int rxw)
{
	void (*oldbus)();			/* Original-Exception-Routinen */
	void (*oldadr)();
	int  test;
	int  exception;
	long stack;
	
	oldbus = Setexc(2, (void(*)()) -1L);
	oldadr = Setexc(3, (void(*)()) -1L);

	Setexc(2, f_exception);		/* Unsere Knallfunktion */
	Setexc(3, f_exception);		/* Unsere Knallfunktion */
	
	if ((exception = setjmp(jmpbuf)) == 0)
	{
		stack = Super(0x0L);
		if (rxw)
			test = *reg;		/* Register lesen */
		else
			*reg = 0x5555;		/* Muster 'reinschreiben */
		
		Super((void*)stack);
	}
	
	test = test; 				/* Nur gegen Compiler-WARNING */
	
	Setexc(2, oldbus);			/* Alten Vektor restaurieren */
	Setexc(2, oldadr);			/* Alten Vektor restaurieren */

	return(!exception);			/* Hat's geknallt? */
}

unsigned int get_ID( int joy[8][2] )
{

	/* ID ermittlen */
	
	unsigned int id = 0x8000;
	
	
	/* Richtungen */
	
	switch( joy[0][1] )
	{
		case 0x0101: id = 'u';break;
		case 0x0201: id = 'd';break;
		case 0x0401: id = 'l';break;
		case 0x0801: id = 'r';break;
		case 0x0501: id = 'U';break;
		case 0x0901: id = 'R';break;
		case 0x0601: id = 'L';break;
		case 0x0a01: id = 'D';break;
	}
	
	/* Pause */
	
	if( joy[0][0] == 0x0001 )
		id = 'p';
		
	/* Option */
		
	if( joy[3][0] == 0x0002 )
		id = 'o';
			
	/* Knîpfe A-C */					
	
	if( joy[0][0] == 0x0002 )
		id = 'a';
	if( joy[1][0] == 0x0002 )
		id = 'b';
	if( joy[2][0] == 0x0002 )
		id = 'c';
		
	/* Tastenfeld */
	
	switch( joy[1][1] )
	{
		case 0x802: id = '1';break;
		case 0x402: id = '4';break;
		case 0x202: id = '7';break;
		case 0x102: id = '*';
	}	
	switch( joy[2][1] )
	{
		case 0x804: id = '2';break;
		case 0x404: id = '5';break;
		case 0x204: id = '8';break;
		case 0x104: id = '0';
	}	
	switch( joy[3][1] )
	{
		case 0x808: id = '3';break;
		case 0x408: id = '6';break;
		case 0x208: id = '9';break;
		case 0x108: id = '#';
	}	
	
		
	/* Richtungen */
	
	switch( joy[4][1] )
	{
		case 0x1010: id = 'u';break;
		case 0x2010: id = 'd';break;
		case 0x4010: id = 'l';break;
		case 0x8010: id = 'r';break;
		case 0x5010: id = 'U';break;
		case 0x9010: id = 'R';break;
		case 0x6010: id = 'L';break;
		case 0xa010: id = 'D';break;
	}
	
	/* Pause */
	
	if( joy[4][0] == 0x0004 )
		id = 'p';
		
	/* Option */
		
	if( joy[7][0] == 0x0008 )
		id = 'o';
			
	/* Knîpfe A-C */					
	
	if( joy[4][0] == 0x0008 )
		id = 'a';
	if( joy[5][0] == 0x0008 )
		id = 'b';
	if( joy[6][0] == 0x0008 )
		id = 'c';
		
	/* Tastenfeld */
	
	switch( joy[5][1] )
	{
		case 0x8020: id = '1';break;
		case 0x4020: id = '4';break;
		case 0x2020: id = '7';break;
		case 0x1020: id = '*';
	}	
	switch( joy[6][1] )
	{
		case 0x8040: id = '2';break;
		case 0x4040: id = '5';break;
		case 0x2040: id = '8';break;
		case 0x1040: id = '0';
	}	
	switch( joy[7][1] )
	{
		case 0x8080: id = '3';break;
		case 0x4080: id = '6';break;
		case 0x2080: id = '9';break;
		case 0x1080: id = '#';
	}	
	
	/* Feuer!? */
	
	#ifdef JOYPAD2
	if(id >= 'a' && id <= 'c')
	#endif    
	    id |= 0x4000;
	
	return( id );    	
				
}


/* -----------------------------------------------------------------
 * main()
 * -----------------------------------------------------------------
 * -----------------------------------------------------------------
 */
main(void)
{

	int  i;
	int  joy[8][2];
	long stack;
	int x;
	int id = 0x8000;

	
	if (!reg_wordtest(JOY00, 1)
	||  !reg_wordtest(JOY02, 1)
	||  !reg_wordtest(JOY02, 0))
	{
		return id;
	}

	for( i=0; i<8; i++ )	
	{
		joy[i][0] = 0;
		joy[i][1] = 0;
	}
	
	for (i = 0x0001, x=0; i < 0x0100; i<<=1, x++)
	{

		stack = Super(0L);
		*JOY02 = ~(i | 0xff00);
		
		joy[x][0] = ~(*JOY00) & ~0x4000;
		joy[x][1] = ~(*JOY02);
		Super ((void*)stack);

	}
	id = get_ID( joy );
	
	return id;
	
}

/************************************************************************
*                                                                       *
*       the F68KANS BIOS-functions                                      *
*                                                                       *
************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h> 
#include <ext.h>
#include "loader.h" 



/*
 * declaration of the BIOS functions
 */
long cdecl key();
long cdecl key_quest();
void cdecl emit();
long cdecl emit_quest();
char* cdecl biostest();

extern int echo;

extern FILE *(infiles[100]);
extern int current_infile;

SI_funcarr SI_BIOS_fa[] = {key, key_quest, emit, emit_quest, biostest};


long cdecl key()   
{  
long c;
long cdecl key(void);
int n;

/*        return (long)Bconin(CONSOLE); */

		if(infiles[current_infile] == NULL)
			{
        	c = (long)(char)Cnecin();
			}
		else
			{
			n = getc(infiles[current_infile]);
			if(n == EOF) 	
				{
				fclose(infiles[current_infile]);
				current_infile++;
				return key();
				}
			c = (long)n;		
			}
			
        return c;
}




long cdecl key_quest()   
{  
/*        return (long)Bconstat(CONSOLE); */
/*        return (long)Cconis();			*/
		return	(long)kbhit();
}




void cdecl emit(ch)   
long ch;
{
	if( (infiles[current_infile] == NULL) || echo )
		{
/*        Bconout(CONSOLE,(int)ch); */
        Cconout((int)ch);
        } 
}




long cdecl emit_quest()
{
	return (long)Cconos();
}
 


 
char* cdecl biostest(str, n)
char *str;
long n;
{
static char dest[256];

	dest[0] = '\0';	
	sprintf(dest, str, n);
	return dest;
} 
 
/************************************************************************
*       end of BIOS functions                                           *
************************************************************************/



#define _LONGFRAME   0x59E

#define MC68000      0       
#define MC68010      10
#define MC68020      20    
#define MC68030      30 
#define MC68040      40      
#define MC68060      60    

WORD get_cpu( VOID )
{
	REG WORD i=MC68000;  
	LONG cv;

	if( GetCookie( '_CPU',&cv ) )
		i = (WORD) cv;                   
	else
		i = (WORD) Supexec( get_longframe );

	return( i );
}

LONG get_longframe( VOID )
{
	return( (LONG) (*(WORD *) _LONGFRAME) );
}


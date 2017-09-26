#include	<mt_mem.h>
/*-----------------------------------------------------------------------------*/
/* Unabh„ngige Auswertung der Tastatur                                         */
/* (Profibuch S. 759f)                                                         */
/*-----------------------------------------------------------------------------*/

#include	<PORTAB.H>
#include <TOS.H>
#include <mapkey.h>

typedef struct
{
	char	*unshift;
	char	*shift;
	char	*caps;
} KEYTABLE;

KEYTABLE	*Kt;

WORD	MapKey( WORD Key )
{
	WORD	Keystate, Scancode, Ret;
	if(!Kt)
		Kt = (KEYTABLE *)Keytbl ((VOID *) -1L, (VOID *) -1L, (VOID*)-1L);
	
	Scancode = (Key >> 8 ) & 0xff;
	Keystate = (WORD) Kbshift (-1);
	
	if(( Keystate & KsALT) && ( Scancode >= 0x78 ) && (Scancode <= 0x83 ))
		Scancode -= 0x76;
	
	if( Keystate & KsCAPS )
		Ret = Kt->caps[Scancode];
	else
	{
		if( Keystate & KsSHIFT )
			Ret = Kt->shift[((Scancode >= KbF11) && (Scancode <= KbF20)) ? Scancode - 0x19:Scancode];
		else
			Ret = Kt->unshift[Scancode];
/* Eigene Erweiterung: Bei den Cursor-Tasten wird nun der normale Scancode zurckgegeben
   mit dem jeweiligem Status der SHIFT -Taste */
		if( Scancode == KbUP || Scancode == KbDOWN || Scancode == KbLEFT || Scancode == KbRIGHT || Scancode == KbHOME || Scancode == KbUNDO )
			Ret = Kt->unshift[Scancode];
	}

	Ret &= 0x00ff;

	if( !Ret )
		Ret = Scancode | KbSCAN;
	else if(( Scancode == 0x4a) || ( Scancode == 0x4e) || (( Scancode >= 0x63) && ( Scancode <= 0x72 )))
			Ret |= KbNUM;

	return( Ret | (Keystate << 8 ));
}


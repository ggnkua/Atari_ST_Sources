/*  kbd.h - header file for keyboard/console routines			*/


/*
**  KBCHAR - type for characters comming in from logical keyboard
**	these are longs because we pass back a UWORD full of info  
**	(scan code + char code), and have -1 mean error.
*/

typedef	long	KBCHAR ;

/*
**  KBSCN - type for kbd scan code
*/

typedef	BYTE	KBSCN ;


/*
**  status registers
*/

#define NOCHAR		0		/* no character was returned	     */
#define BREAK		1		/* break key was struck		     */
#define KYBD_LOCKED	2		/* key on front panel in lock pos.   */
#define IN_CHAR		3		/* a real live character available   */



/*
**  external declarations
*/

EXTERN	ERROR	kbinit() ;	
EXTERN	ERROR	kbselect() ;
EXTERN	ERROR	kbdisab() ;
EXTERN	KBCHAR	kbdecode() ;
EXTERN	VOID	mode_chg() ;
EXTERN	ISR	kbint() ;
EXTERN	KBCHAR	kbread() ;


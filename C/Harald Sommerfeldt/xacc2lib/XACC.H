/* XACC.H - Routinen zur Behandlung des XACC-Protokolls
            nach der Spezifikation vom 28. November 1992,
            erweitert um Mag!X 2.0 (ap_version == 0x399)
	(c) 1993 Harald Sommerfeldt @ KI im Maus-Netz
	E-Mail:  Harald_Sommerfeldt@ki.maus.de */

/* XACC - Definitionen */
#define ACC_ID		0x400
#define ACC_OPEN	0x401
#define ACC_CLOSE	0x402
#define ACC_ACC	0x403
#define ACC_EXIT	0x404
#define ACC_ACK	0x500
#define ACC_TEXT	0x501
#define ACC_KEY	0x502
#define ACC_META	0x503
#define ACC_IMG	0x504


#define MAX_XACC 20					/* Anzahl der unterstÅzten XACC-Partner */

extern struct xaccs {				/* Strukturen, um sich die XACC-Partner zu merken */
	int	id;							/* ap_id */
	unsigned  groups;					/* XACC-Group-Wort */
	const char *name;					/* XACC-Name */
} xaccs[MAX_XACC];


/* bereitgestellte XACC - Routinen */
int	xacc_init( int menu_id, const char *name, int sizeofname, unsigned groups );
void	xacc_exit( void );
int	xacc_message( const int *msgbuf );
int	xacc_send( int dest_id, int message, void *addr, long length, int last );
int	xacc_ack( int dest_id, int ok );

/* interne XACC - Routinen, werden normalerweise nicht benîtigt */
int	xacc_id( int dest_id, int message );
int	xacc_remid( int id, const int *msgbuf );
int	xacc_killid( int id );
int	xacc_cookie( long cookie, long *value );


/* ein minimales XACC-Programm sieht nun in etwa so aus:

#include <aes.h>
#include "xacc.h"

int	quit;

main()
{
	const char name[] = "mein Programm";
	int	event, msgbuf[8];

	appl_init();
	xacc_init( -1, name, sizeof( name ), 0x0000 );
	for ( quit = FALSE; !quit ; ) {
		event = evnt_multi( MU_MESAG, ..., msgbuf, ... );
		if ( event & MU_MESAG ) {
			if ( !xacc_message( msgbuf ) ) switch ( msgbuf[0] ) {
				...
			}
		}
	}
	xacc_exit();
	appl_exit();
	return 0;
}
*/

/* und ein minimales XACC-Accessory in etwa so:

#include <aes.h>
#include "xacc.h"

void main( void )
{
	const char name[] = "mein Accessory";
	int	menu_id, event, msgbuf[8];

	menu_id = menu_register( appl_init(), "  mein ACC" );
	xacc_init( menu_id, name, sizeof( name ), 0x0000 );
	for (;;) {
		event = evnt_multi( MU_MESAG, ..., msgbuf, ... );
		if ( event & MU_MESAG ) {
			if ( !xacc_message( msgbuf ) ) switch ( msgbuf[0] ) {
				case AC_OPEN:
					...
					break;
				...
			}
		}
	}
}
*/

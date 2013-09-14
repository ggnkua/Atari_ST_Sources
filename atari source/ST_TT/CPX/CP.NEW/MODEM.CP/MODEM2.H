/* MODEM2.H
 *==========================================================================
 * Prototypes, defines and externs for modem.c
 */
 
/* DEFINES
 *==========================================================================
 */


#define PORT_A		0
#define PORT_B		1
#define PORT_C		2
#define PORT_D		3

#define MASK_A		6
#define MASK_B		7
#define MASK_C		8
#define MASK_D		9

 
/* PROTOTYPES
 *==========================================================================
 */
BOOLEAN  Check_OS( void );
int	 Set_Active_Port( int port );
 
/* EXTERNS
 *==========================================================================
 */
extern MDEFAULT Modem;
extern int     old_port;
extern int     cur_port;	/* Current Serial Port  - NUM_PORTS
				 * 0, 1, 2, 3
				 * There is only ONE port on regular STs.
				 * The other ports are for the TT.
				 */
				 
extern BUFFER  *store;		/* Need to store baud rate and flow cntrl
				 * in the 64 byte buffer. There is no other
				 * way to get these 2 numbers since they
				 * are write only items. The UCR data 
				 * can be had from RSCONF
				 */
 
 
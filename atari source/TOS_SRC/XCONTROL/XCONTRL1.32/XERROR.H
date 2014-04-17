/* XERROR.H
 *==========================================================================
 * Defines and Prototypes frm XERROR.C for those who need it
 */
 

/* DEFINES
 *==========================================================================
 */
#define SAVE_DEFAULTS	0
#define MEM_ERR		1
#define FILE_ERR	2
#define FILE_NOT_FOUND  3

#define NO_NODES_ERR	4
#define RELOAD_CPXS	5
#define UNLOAD_CPX	6
#define NO_RELOAD	7
#define SAVE_HEADER	8
#define FILE_NOT_CPX	9
#define NO_SOUND_DMA	10

#define SHUTDOWN	11



/* EXTERNS
 *==========================================================================
 */
extern char Shut_String[];

extern char Alert1A[];
extern char Alert1B[];

extern char Alert2A[];
extern char Alert2B[];

extern char Alert3[];

extern char Alert4A[];
extern char Alert4B[];
extern char Alert5[];

/* PROTOTYPES
 *==========================================================================
 */
BOOLEAN  cdecl XGen_Alert( int id );

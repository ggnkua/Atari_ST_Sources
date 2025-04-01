/* Resource Datei Indizes fÅr RESOURCE */

#define R_MENU   0   /* Menuebaum */
#define R_T_DESK 3   /* TITLE in Baum R_MENU */
#define R_T_FILE 4   /* TITLE in Baum R_MENU */
#define R_E_PROGINFO 7   /* STRING in Baum R_MENU */
#define R_E_PRINT 16  /* STRING in Baum R_MENU */
#define R_E_QUIT 18  /* STRING in Baum R_MENU */

#define R_PROGINFO 1   /* Formular/Dialog */

#define R_PRINT  2   /* Formular/Dialog */
#define R_PRINT_CANCEL 1   /* BUTTON in Baum R_PRINT */
#define R_PRINT_START 3   /* BUTTON in Baum R_PRINT */
#define NUM_STRINGS 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_IB 0
#define NUM_TI 1
#define NUM_OBS 35
#define NUM_TREE 3

#include <aes.h>

void    objc_init( int start_of_dialogs );
extern  OBJECT	*TREE[];
extern	char	*alert_msg[];

/* RSC2CSRC */
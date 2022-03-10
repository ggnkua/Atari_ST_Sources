/* GEMTRRSC 
   Resource header file
*/

#if !defined( __GEMTRRSC )
#define __GEMTRRSC

#include <aes.h>

#define RSH_VRSN    1
#define RSH_NOBS    71
#define RSH_NTREE   3
#define RSH_NTED    25
#define RSH_NIB     0
#define RSH_NBB     0
#define RSH_NSTRING 3
#define RSH_NIMAGES 0

extern OBJECT  rs_object[];
extern OBJECT  *rs_tree[];
extern TEDINFO rs_tedinfo[];
extern char    *rs_frstr[];

/* prototypes */
void rsc_init(void);
void rsc_exit(void);

#endif

/* End of headerfile */


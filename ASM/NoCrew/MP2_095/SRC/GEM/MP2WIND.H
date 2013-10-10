#include "mp2ctrl.h" /* rsc file defines */

typedef struct
{
	int whandle,wind_open,windkind,firstobj,objdepth;
	char wind_title[64];
	CORDS wind,form;
	OBJECT *formtree;
} WINDFORM;

#define WIND_CTRL 0
#define WIND_INFO 1
/* #define WIND_LYRICS 2 */

#define N_WINDS 2

#define KEEPSELECT 0x8000  /* flag bit 15 */

/************************************************************************/
/* RESOUCE.H															*/
/************************************************************************/
#define BYTE	char
#define LONG	long
#define WORD	int


typedef struct
{
	int	dummy;
	int	*image;
}RS_IMDOPE;  


void rsrc_init( int tree, int n_obs, int n_frstr, int n_frimg,
		char **rs_strings, long *rs_frstr, BITBLK *rs_bitblk,
		long *rs_frimg, ICONBLK *rs_iconblk, TEDINFO *rs_tedinfo,
		OBJECT *rs_object, OBJECT **rs_trindex, RS_IMDOPE *rs_imdope );
void cut_obwidth( OBJECT *menu, int width );


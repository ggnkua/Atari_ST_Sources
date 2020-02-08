# define MATtcCookie	"MaTC"

typedef struct
{
	int version,release ;
	char *date ;

	SCREENparameter *scr_par ;
	BOARDparameter  *brd_par ;
	TCXXtables		*tables ;
	E2Pparameter	*e2p_par ;
} TCXXparameterBlock ;
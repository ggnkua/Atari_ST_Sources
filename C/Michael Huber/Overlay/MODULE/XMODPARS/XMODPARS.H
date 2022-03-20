/*
	@(#) Overlay-Schnittstelle fÅr externe Module
	@(#) Michael Huber (c) 1994
*/

#include <vdi.h>

typedef struct __xmodpw	{
	char	obj_name[256];
	int		original;
	int		x;
	int 	y;
	int 	w;
	int 	h;
	struct __xmodpw	*next;	
} XMODPW;
	
typedef struct {
	char 	ozz_name[14];
	char 	xdriver_name[14];
	int		frame_index;	
	int     *pal;
	int		view_x1;
	int		view_y1;
	int 	view_x2;
	int		view_y2;
	struct __xmodpw	*pars;
}	XMODPARS;	

enum { XMD_OR, XMD_SC, XMD_NEW };

int Xmod_GetPars( int argc, char *argv[] );	
int Xmod_LoadXDriver( void );	
int Xmod_CallXDriver( void );	

extern int Xmd_ParNum;			/* Anzahl der ParametersÑtze */
extern XMODPARS Xmd_ParHead;	/* Parameterheader	*/	
extern XMODPW *Xmd_ParSet;		/* ParametersÑtze */

#ifndef _qed_rsc_h_
#define _qed_rsc_h_

#include "qed.h"

/****** VARIABLES ************************************************************/

extern OBJECT 	*menu;
extern OBJECT 	*about;
extern OBJECT 	*about2;
extern OBJECT 	*print;
extern OBJECT 	*textinfo;
extern OBJECT 	*prjinfo;
extern OBJECT	*blockinfo;
extern OBJECT	*sort;
extern OBJECT 	*replace;
extern OBJECT	*repask;
extern OBJECT 	*find_obj;
extern OBJECT 	*pos;
extern OBJECT 	*marken;
extern OBJECT 	*makrorep;
extern OBJECT 	*funktionstasten;
extern OBJECT	*umlautkonv;
extern OBJECT	*fehler;
extern OBJECT 	*globalop;
extern OBJECT 	*localop;
extern OBJECT 	*muster;
extern OBJECT	*autosave;
extern OBJECT	*klammer;
extern OBJECT 	*printer;
extern OBJECT 	*printer_sub;
extern OBJECT	*seoptions;

extern OBJECT 	*winicon;

extern OBJECT 	*popups;
extern OBJECT 	*strings;

extern char		**alertmsg;

/****** FUNCTIONS ************************************************************/

#define rsc_string(a) (char *) get_obspec(strings, a)
/* einen String als der strings-Box herausholen */

extern bool		init_resource	(void);
extern void		term_resource	(void);

#endif

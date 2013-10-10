#ifndef _qed_global_h_
#define _qed_global_h_

#include <cflib.h>
#include <macros.h>
#include <mintbind.h>

#ifndef __MINT__
#error qed benîtigt ab Version 4 die MiNT-Lib!!
#endif

#include "types.h"


#define	ltoa(a,b,c)	_ltoa(a,b,c)
#define	itoa(a,b,c)	_itoa(a,b,c)

/****** Defines ***************************************************************/

#ifndef TA_LEFT						/* text alignment */
#define TA_LEFT			0
#define TA_ASCENT			2
#define TA_TOP				5
#endif

#ifndef SC_CHANGED
#define SC_CHANGED		80			/* AES-Message: Klemmbrett wurde verÑndert */
#endif

#define DTA					_DTA		/* Warum mit '_' in MiNT-Lib?? */

#define TIMER_INTERVALL	500L		/* Pollzeit fÅr Timerevent */


/****** global Variablen ******************************************************/

extern int		fill_color;			/* aktuell eingestellte FÅllfarbe */

extern bool		quick_close;		/* Sichern der Texte ohne Nachfrage */
extern int		vdi_handle;			/* Virtuelles Workstation Handle */

extern bool		done;					/* Ende gewÑhlt ? */

extern int		desire_x, return_code;
extern long		desire_y, undo_y;

extern int		font_id, font_pts, 
					font_wcell, font_hcell,
					min_ascii, max_ascii;
extern bool		font_prop;

/****** Functions ************************************************************/

extern bool		mouse_sleeps			(void);
extern void		sleep_mouse 			(void);
extern void		wake_mouse				(void);

extern void		print_headline		(char *str);

extern bool		inside				(int x, int y, GRECT *r);

extern bool		get_clip				(GRECT *size);
extern void		set_clip				(bool	 flag, GRECT *size);

extern int		note					(int def, int undo, int index);
extern int		inote					(int def, int undo, int index, int val);
extern int		snote					(int def, int undo, int index, char *val);

extern bool		shift_pressed		(void);

extern void		get_datum			(char *date);
extern long		file_time			(char *filename, char *date, char *time);
extern long		file_size			(char *filename);
extern void		file_name			(char *fullname, char *filename, bool withoutExt);
extern bool		file_readonly		(char *filename);
extern bool		is_bin_name			(char *filename);
extern bool		path_from_env		(char *env, char *path);

extern void		font_change 		(void);
extern void		select_font			(void);

extern void		init_global			(void);
extern void		term_global			(void);


/* Debug-Level */
#define DBG_GEN	1			/* generell */
#define DBG_OS		2			/* OS */
#define DBG_ARG	4			/* argv */
#define DBG_INIT	8			/* init_* */
#define DBG_AV		16			/* AV-Protokoll */
#define DBG_SE		32			/* SE-Protokoll */
#define DBG_OL		64			/* OLGA */

extern int	debug_level;

#endif

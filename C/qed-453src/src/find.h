#ifndef _qed_find_h_
#define _qed_find_h_

/* Grîûe des History-Puffers fÅr Suchstrings */
#define HIST_ANZ	10		
#define HIST_LEN 	50

#define RP_FIRST 	0
#define RP_ALL   	1
#define RP_OPT   	2			/* Werte von 'r_modus' */

extern bool 	s_grkl, s_quant, s_wort, s_vorw, s_global, s_round,
					ff_rekursiv;
extern int		r_modus, rp_box_x, rp_box_y;
extern char		r_str[], s_str[], 
					s_history[HIST_ANZ][HIST_LEN+1],
					r_history[HIST_ANZ][HIST_LEN+1],
					ff_mask[];

extern UMLAUTENCODING	umlaut_from,
								umlaut_to;


extern int		start_find		(TEXTP t_ptr, bool quiet);
extern int		start_replace	(TEXTP t_ptr);
extern int		do_next			(TEXTP t_ptr);
extern void		find_selection	(TEXTP t_ptr);

extern bool		filematch		(char *filename, char *m, int fs_typ);
/*
 * Testet auf Gleichheit von Dateiname und Muster.
 * Beachtet dabei fs_case_sens().
*/

extern void		change_umlaute	(TEXTP t_ptr);
/* Umlaute im Text konvertieren */


/* Dialoge */

extern int		replace_dial	(void);
extern bool		findfile_dial	(char *path, bool in_prj);
extern bool		umlaut_dial		(void);

#endif

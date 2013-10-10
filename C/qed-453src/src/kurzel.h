#ifndef _qed_kurzel_h_
#define _qed_kurzel_h_

extern bool 	goto_line_dial (void);

/* Marken */
#define MARKEN_ANZ	5

extern void 	set_marke		(int nr, char *name, PATH file, long y, int x);
extern bool 	get_marke		(int nr, char *name, PATH file, long *y, int *x);

extern void 	init_marken		(void);
extern void 	goto_marke		(int nr);
extern void 	config_marken	(TEXTP t_ptr);
extern void		del_marke 		(int nr);

/* KÅrzel */
#define KURZEL_MAX	8		/* max. Anzahl der konfi. KÅrzeldateien */

extern bool		krz_loaded;

extern void 	do_kurzel		(TEXTP t_ptr, bool online);
/* versucht ein KÅrzel zu expandieren */

extern void		ch_kurzel		(char *name, bool force_load);
/* wechselt gemÑû der lok. Optionen ggf. die KÅrzeldatei */

#endif

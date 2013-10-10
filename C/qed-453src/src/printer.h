#ifndef _qed_printer_h_
#define _qed_printer_h_

typedef struct
{
	int	wp_mode;
	int	wp_s_len;
	int	wp_z_len;
	PATH	wp_treiber;
	bool	wp_nlq;
	bool	vorschub;
	bool	pruef_prn;

	bool	use_gdos;
	bool	use_pdlg;
	int	font_id;
	int	font_pts;	

	bool	num_zeilen;
	bool	num_seiten;
	int	rand_len;

	void	*pdlg;		/* PRN_SETTINGS */
	
	/* momentane Einstellungen, werden nicht gesichert! */
	bool	pdlg_avail;
	bool	ausdruck;	/* FALSE: normale Konfig, TRUE: vor Ausdruck */
	bool	block;		/* Bei start=TRUE: Block oder alles */
	int	handle;		/* VDI/GEMDOS-Handle */
	int	height;		/* H”he der Druckseite */
} PRN_CFG;


/* Konfiguration: prn_cfg.c */
extern PRN_CFG	*prn;

extern void		prn_cfg_dial	(void);
extern bool		prn_start_dial	(bool *block);

extern void		prn_save_cfg	(char	*cfg_file);
extern bool		prn_get_cfg		(char *var, char *buffer);

extern void		init_printer	(void);
extern void		term_printer	(void);


/* Ausgabe: prn_out.c */
extern void		blk_drucken		(char *name, TEXTP t_ptr);
extern void		txt_drucken		(char *name, TEXTP t_ptr);

#endif

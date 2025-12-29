
struct cookie {
		long c;
		long v;
	};

#define FAX_COOKIE	0x46784F50L			/* "FxOP" */



typedef struct {
				int		version;		/* Version 1.00 -> 0x0100 */
				int		fax_ready;
				int		x_dpi;			/* X-Aufl”sung des Faxes	*/
				int		y_dpi;			/* Y-Aufl”sung des Faxes	*/
				long	page_height;	/* in mm */
				long	page_width;		/* in mm */
				int		tot_txtlines;	/* Seitenh”he in Textzeilen */
				int		tot_pixlines;	/* Seitenh”he in pixelzeilen */
				int		act_page;		/* aktuelle Seitennummer */
				int		(*init_app)(int new_page, int xres, int yres,
									int page_len);
				void	(*exit_app)( void );
				int		(*bit_out)( void *bit_map,int width,int	height,
									int word_width);
				int		(*txt_out)( char *string );
				int		(*lf)( void );
				int		(*ff)( void );
				int		(*page_break)( void );

				int		cdecl (*Cinit_app)(int new_page, int xres, int yres,
										   int page_len);
				int		cdecl (*Cbit_out)( void *bit_map,int width,int	height,
										   int word_width);
				int		cdecl (*Ctxt_out)( char *string );
				int		cdecl (*Clf)( void );
				int		cdecl (*Cff)( void );
				int		cdecl (*Cpage_break)( void );
								
				int		rsvd[20];
				/*
				*		die folgenden Daten sind zur internen Verwendung
				*/
				void	(*init_syns)( char *syn_file );
				char	file_name[128];	/* Ausgabedatei */
				int		fh;				/* file handle */
				char	sig_string[128];
				int		page_empty;
				int		pix_line;
				int		txt_line;
				int		pages;
				long	max_bytes;
			} FAX_OUTPUT;
			
			 
				
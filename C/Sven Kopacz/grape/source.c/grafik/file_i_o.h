#if  !defined( __FILE_I_O__ )
#define __FILE_I_O__

#include "layer.h"
#include "mask.h"

#define FF_VERSION 1

#define FF_GRAPE 1
#define FF_ESM	 2
#define FF_TIFF_MOT 3
#define FF_TIFF_INT 4


typedef struct
{
	/* Info Åber Grape-Datei */
	
	int		version;		/* Dateiversion */
	int		lay_num;		/* Anzahl Ebenen */
	int		mask_num;		/* Anzahl Masken */
	int		width;			/* Maximale Breite (genutzt) */
	int		word_width;	/* Wordbreite */
	int		height;			/* Maximale Hîhe */
}GRAPE_INFO;

/* File_i_o Functions */
void	import_selected(void);
void	import_edit(void);
int		import_mask(void);
int		quick_io(char	*titel, char	*path, void *load, void *save, long	size, ulong magic);
int		f_input(char *spruch, char *path, char *name);
int		main_load(void);
int		main_save(void);
int		main_save_as(void);
int 	l_import(int fh, LAYER *l, MASK *ms, int mode);
int 	esm_import(int fh, LAYER *l, MASK *ms, int mode);
int 	tiff_import(int fh, LAYER *l, MASK *ms, int mode);
int		ibm_tiff_import(int fh, LAYER *l, MASK *ms, int mode);
int		f_sinput(char *spruch, char *path, char *name);
void	make_path(char *com, char *path, char *name);
long	save_all(int fh);
int		identify(int fh);
int		load_file(void);
long	load_all(int fh);

int		get_grape_info(int fh, GRAPE_INFO *gp);
int		get_grape_size(int fh, int *x, int *y);
int		get_esm_size(int fh, int *x, int *y);
int		get_tiff_size(int fh, int mot_or_ibm, int *x, int *y);
int		get_graphik_size(int fh, int *x, int *y);

unsigned int iturn(unsigned int num);
long	lturn(long num);


#endif
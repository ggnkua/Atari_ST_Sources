#include <fiodef.h>

#if  !defined( __FIOMOD__ )
#define __FIOMOD__


typedef struct	_FIO_LIST
{
	void			*base;					/* Zeiger auf Basepage */
	FIOMODBLK	*fblk;	/* Module-Descriptor */
	struct		_FIO_LIST	*next;
}FIO_LIST;

void cdecl			fio_set_pal(int mode, int num, int *pal);
int *cdecl			fio_get_pal(int mode, int num);
void cdecl 			fio_store_block(BLOCK_DSCR *bd, GRAPE_DSCR *dd);
void cdecl			fio_get_block(BLOCK_DSCR *bd, GRAPE_DSCR *sd);
int cdecl				fio_form_alert(int fo_adefbttn, const char *fo_astring );
void *cdecl			fio_malloc( size_t size );
void *cdecl			fio_calloc( size_t nitems, size_t size );
void *cdecl			fio_realloc( void *block, size_t newsize );
void cdecl			fio_free( void *ptr );

void			scan_fio_modules(void);
int 			scan_folder(char *path);
int 			cat_fiomod(char *path);
FIOMODBLK *find_fiomod_magic(uchar *mem, long len);
void 			delete_fiomod(void);
void			close_all_fio_win(void);

int				count_fiomod(void);
int				count_fio_saveables(void);
FIOMODBLK	*find_fiomod_by_id(long id);
int 			find_fioidx_by_id(long id);
long 			find_fiomodid_by_index(int ix);
long 			find_fiomodid_by_savindex(int ix);


extern GRAPE_FIOFN	grape_fiomod_info;
extern FIO_LIST		*first_fiomod;

#endif
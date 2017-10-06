/*******************************************************************

	Header-Datei: XFORM_DO.H
	fÅr TURBO C 2.0 und kompatible...

*******************************************************************/
#if  !defined( __XFORM_DO__ )
#define __XFORM_DO__

#include <aes.h>
#include <vdi.h>

/*** Neue Struktur: DIAINFO ***/

typedef struct
{
	MFDB	di_mfdb;
	int		di_flag;
	long	di_length;
} DIAINFO;

int		open_res(char *rscname);
void	clse_res(void);
void	half_on(void);
void	half_off(void);
void	fix_objs(OBJECT	*tree);

void	open_dia(OBJECT *tree, DIAINFO *info, int flag);
void	clse_dia(OBJECT *tree, DIAINFO *info);

int		xform_do(OBJECT *tree, DIAINFO *info, int objekt);

extern	int	vhandle;
extern	int	gr_cw, gr_ch, gr_bw, gr_bh;
extern	int	max_w, max_h;
extern	int	planes;
extern	int	aktivkom;
extern	int	gr_res;

extern	USERBLK	checkblk;
extern	USERBLK	hotkeybl;

#ifdef __TURBOC__
extern	void *aes_pb[];	/* Ist  sehr wichtig! Siehe Dokumentation! */
#define INITGEM aes_pb[1] = _GemParBlk.global
#endif

#endif

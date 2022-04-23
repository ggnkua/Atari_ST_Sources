/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#define	GAI_WDLG		0x0001											/* wdlg_xx()-Funktionen vorhanden */
#define	GAI_LBOX		0x0002											/* lbox_xx()-Funktionen vorhanden */
#define	GAI_FNTS		0x0004											/* fnts_xx()-Funktionen vorhanden */
#define	GAI_FSEL		0x0008											/* neue Dateiauswahl vorhanden */

#define	GAI_MAGIC	0x0100											/* MagiC-AES vorhanden */
#define	GAI_INFO		0x0200											/* appl_getinfo() vorhanden */
#define	GAI_3D		0x0400											/* 3D-Look vorhanden */
#define	GAI_CICN		0x0800											/* Color-Icons vorhanden */

WORD	get_aes_info( WORD *font_id, WORD *font_height, WORD *hor_3d, WORD *ver_3d );
void	adapt3d_rsrc( OBJECT *objs, UWORD no_objs, WORD hor_3d, WORD ver_3d );
void	no3d_rsrc( OBJECT *objs, UWORD no_objs, WORD ftext_to_fboxtext );
void	substitute_objects( OBJECT *objs, UWORD no_objs, WORD aes_flags, OBJECT *rslct, OBJECT *rdeslct );
void	substitute_free( void );
BYTE	*is_userdef_title( OBJECT *obj );

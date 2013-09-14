/* PROTOTYPES 
 * ===============================================================
 */
void	 Reset_Tree( OBJECT *tree );
void 	 MF_Save( void );
void	 MF_Restore( void );
void	 Scan_Message( OBJECT *Tree, BOOLEAN flag );
void	 close_vwork( void );
int 	 open_vwork( void );
void	 SetupDriverFonts( DEV_PTR device );
void	 strip_period( char *text );
void	 RestoreMainTree( void );
void	 ClearChangeFlag( void );
void	 SetChangeFlag( void );
BOOLEAN	 IsChangeFlag( void );
void	 CloseWindow( void );
void     DoActiveFonts( void );

/* EXTERNS
 * ===============================================================
 */
extern OBJECT *tree; 
extern OBJECT *ad_inactive;		/* Outline Tree          */
extern OBJECT *ad_active;		/* Font GDOS tree        */
extern OBJECT *ad_path;			/* Edit Font path tree   */
extern OBJECT *ad_edit;			/* Edit Devices tree	 */
extern OBJECT *ad_scan;
extern OBJECT *ad_front;
extern OBJECT *ad_menu;

extern OBJECT *PrevTree;
extern char   device_text[];		/* Text to display device number */
extern char   driver_text[];		/* Text to display driver name   */
extern int    Item;

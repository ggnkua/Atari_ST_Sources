/* PROTOTYPES - DAVESTUF.S
 * ================================================================
 */
int  DaveInit( char *path );
void DaveDraw( GRECT *rect );
void DaveButton( int x, int y );
void load_brush( char *path );
void save_brush( char *path );
int  load_world( char *path );
int  save_world( char *path );
void DaveExit( void );

void DaveClrWorld( void );
void DaveTile( void );
void DaveITile( void );

void DaveSize( void );
void LibraryDraw( GRECT *rect );
void LibButton( int x, int y );
void DaveGrid( void );
void ITileSetup( void );

void GetCurObj( char *text, GRECT *rect );
void ClrFloor( void );
void LoadPal( void );

void SaveErr( void );
void DaveKey( int kstate, int key, int whandle ); /* WORLD, LIBRARY or NO_WINDOW */

int  load_cluster( char *path );
int  save_cluster( char *path );

void DisplayXY( void );

/* EXTERN
 * ================================================================
 */
extern int  BUT_STATE; 
extern long BUT_ADDR;
int  NEW_BUT( void );





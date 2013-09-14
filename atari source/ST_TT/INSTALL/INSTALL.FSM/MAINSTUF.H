/* PROTOTYPES
 * ================================================================
 */
void Graf_Mouse( int item );
void Scan_Message( OBJECT *Tree, BOOLEAN flag );
int  execform( OBJECT *tree, int start_obj );

/* GLOBALS
 * ================================================================
 */
extern OBJECT *tree;
extern OBJECT *ad_dir;
extern OBJECT *ad_driver;
extern OBJECT *ad_copy;
extern OBJECT *ad_assign;
extern OBJECT *ad_extend;
extern OBJECT *ad_massign;
extern OBJECT *ad_rename;
extern OBJECT *ad_conflict;
extern OBJECT *ad_pageone;
extern OBJECT *ad_pagetwo;

extern char dirpath[];
extern char folder_name[];
extern char adirpath[];

extern int  DriveMenuID;
extern int  CurDrive;
extern int  DriveArray[];
extern int  DriveCount;
extern int  CurDriver;
extern char DriverName[];
extern int  CurCPX;
extern int  CurMeta;
extern BOOLEAN CurScreen;
extern char CurBName[];
extern int  CurBFont;
extern int  InstallFlag;
extern BOOLEAN PageOneFlag;
extern int  CurPageTwo;
extern char PagePath[];




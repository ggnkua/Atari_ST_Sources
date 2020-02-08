extern OBJECT *ToolsTree ;
extern bool	ToolBarOn ;
extern bool	ToolsVisible ;
extern TImageWindow LiveBox ;

# define ToolsHeight() ( ToolBarOn ? ToolsTree->ob_height : 0 )
# define ToolsWidth()  ( ToolBarOn ? ToolsStartWidth      : 0 )

extern int ToolsStartWidth ;

extern void DrawToolBar ( TRectangle *clip ) ;
extern void SetToolsWindow ( void ) ;

extern void ToolBarInit ( void ) ;

extern int GetToolIcon ( void ) ;

extern void SignalReady ( int units, int of ) ;

extern void SetIconMaskColor ( OBJECT *icnobj, int color ) ;
extern void SetIconDataColor ( OBJECT *icnobj, int color ) ;
extern int  GetIconDataColor ( OBJECT *icnobj ) ;
extern void SwitchFilmIconColor ( int color ) ;
extern void StepFilm ( bool forw ) ;

extern void SetTrashState ( void ) ;
extern bool ToolSelected ( int obj ) ;
extern void ToolSelect ( int obj ) ;
extern void ToolNormal ( int obj ) ;
extern bool ToggleTool ( int obj ) ;
extern bool DisplayParameter ( int n ) ;

# define INVALID ((int)0x8000L)

extern void SetToolNumber ( int obj, int n ) ;
extern void SetToolNumberFormat ( int obj, int n, char *format ) ;

extern int  DeselectCurrTextField ( void ) ;
extern void SelectTextField ( int obj, int *pval ) ;
extern int  GetCurrTextField ( void ) ;
extern void EnterCurrTextField ( int key ) ;
extern int  GetCurrTextField ( void ) ;


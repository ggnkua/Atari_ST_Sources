/* PROTOTYPES 
 * ===============================================================
 */
void	XDeselect( OBJECT *tree, int button );
void	XSelect( OBJECT *tree, int button );
void	RedrawObject( OBJECT *tree, int obj );
void	RedrawBase( OBJECT *tree, int obj );

/* EXTERNS
 * ===============================================================
 */
extern OBJECT *tree; 
extern OBJECT *ad_front;
extern OBJECT *PrevTree;
extern OBJECT *ad_scan;
extern OBJECT *ad_inactive;
extern OBJECT *ad_options;
extern OBJECT *ad_path;
extern OBJECT *ad_points;
extern OBJECT *ad_cache;
extern OBJECT *ad_custom;
extern OBJECT *ad_printer;
extern OBJECT *ad_load;
extern OBJECT *ad_width;
extern OBJECT *ad_add;

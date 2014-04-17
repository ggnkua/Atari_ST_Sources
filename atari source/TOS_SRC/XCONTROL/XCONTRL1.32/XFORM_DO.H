/*  XFORM_DO.C Prototypes
 *==========================================================================
 */


/*  PROTOTYPES
 *==========================================================================
 */
WORD    cdecl xform_do( OBJECT *tree, WORD start_field, WORD puntmsg[] );
void    CheckXAccClose( void );
void	Redraw_XForm_Do( GRECT *rect );
void    Move_XForm_Do( GRECT *rect );
void    CheckXWmClose( void );

GRECT   *cdecl GetFirstRect( GRECT *prect );
GRECT	*cdecl GetNextRect( void );




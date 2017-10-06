/****  dog.c  ****/
CPXINFO *cpx_init( XCPB *Xcpb, LONG copsmagic, LONG copsversion );
WORD cpx_call( GRECT *work, void *copsdialog );
void redraw( GRECT *clip, WORD obj, WORD depth );
void cpx_draw( GRECT *clip );
void cpx_wmove( GRECT *work );
void cpx_timer( WORD *event );
void cpx_key( WORD kstate, WORD key, WORD *event );
void cpx_button( MRETS *mrets, WORD nclicks, WORD *event );
void cpx_close(WORD flag);
void InitDog(void);

/****  rsh.c  ****/


/*
 *	MT_AES library
 *	initied by A. Kromke
 *	this version (for LDG) comes from GemLib pl36
 *	tabulation size : 4 characters
 *	New version (with LDG v1.2)
 */

#ifndef _MT_AES_H_#define _MT_AES_H_#ifndef MENU_T#define MENU_T MENU#endif
#ifndef XFSL_FILTER
typedef int cdecl (*XFSL_FILTER)(char *path, char *name, void /*XATTR*/ *xa);
#endif

#ifndef EVNT
typedef struct {
	int	mwhich;
	int	mx;
	int	my;
	int	mbutton;
	int	kstate;
	int	key;
	int	mclicks;
	int	reserved[9];
	int	mesg[16];
} EVNT;
#endif
int	mt_appl_bvset 		( int bvdisk, int bvhard, WORD *pb);int	mt_appl_control		( int ap_cid, int ap_cwhat, void *ap_cout, WORD *pb);int	mt_appl_exit 		( WORD *pb);int	mt_appl_find 		( const char *Name, WORD *pb);int	mt_appl_getinfo 	( int type, int *out1, int *out2,int *out3, int *out4, WORD *pb);int	mt_appl_init 		( WORD *pb);int	mt_appl_read 		( int ApId, int Length, void *ApPbuff, WORD *pb);int	mt_appl_search 		( int mode, char *fname, int *type, int *ap_id, WORD *pb);int	mt_appl_tplay 		( void *Mem, int Num, int Scale, WORD *pb);int	mt_appl_trecord 	( void *Mem, int Count, WORD *pb);int	mt_appl_write 		( int ApId, int Length, void *ApPbuff, WORD *pb);int mt_appl_yield 		( WORD *pb);int	mt_evnt_button 		( int Clicks, int WhichButton, int WhichState, int *Mx, int *My,                                   	  int *ButtonState, int *KeyState, WORD *pb); int	mt_evnt_dclick 		( int ToSet, int SetGet, WORD *pb);int	mt_evnt_keybd 		( WORD *pb);int	mt_evnt_mesag 		( int MesagBuf[], WORD *pb);int	mt_evnt_mouse 		( int EnterExit, int InX, int InY, int InW, int InH, 
						  int *OutX, int *OutY, int *ButtonState, int *KeyState, WORD *pb); #ifdef __OLD_WAY__int	__mt_evnt_multi 	( int Type, int Clicks, 
						  int WhichButton, int WhichState, 
						  int EnterExit1, int In1X, int In1Y, int In1W, int In1H,
						  int EnterExit2, int In2X, int In2Y, int In2W, int In2H,                          int MesagBuf[], unsigned long Interval,                          int *OutX, int *OutY, int *ButtonState,                          int *KeyState, int *Key, int *ReturnCount, WORD *pb);#define mt_evnt_multi(Type, Clicks, WhichButton,                    \                   WhichState, EnterExit1, In1X, In1Y, In1W, In1H,  \                   EnterExit2, In2X, In2Y, In2W, In2H, MesagBuf,    \                   I1, I2, OutX, OutY, ButtonState, KeyState, Key,  \                   ReturnCount, pb)                                 \        __mt_evnt_multi((Type), (Clicks), (WhichButton),            \                     (WhichState), (EnterExit1), (In1X), (In1Y),    \                     (In1W), (In1H), (EnterExit2), (In2X), (In2Y),  \                     (In2W), (In2H), (MesagBuf),                    \                     (((unsigned long)(I1)) << 16 |                 \                      ((unsigned long)(I2))),                       \                     (OutX), (OutY), (ButtonState), (KeyState),     \                     (Key), (ReturnCount), (pb))#elseint 	mt_evnt_multi 	( int Type, int Clicks, int WhichButton, int WhichState,
						  int EnterExit1, int In1X, int In1Y, int In1W, int In1H,                          int EnterExit2, int In2X, int In2Y, int In2W, int In2H,                          int MesagBuf[],  unsigned long Interval,                          int *OutX, int *OutY, int *ButtonState, 
                          int *KeyState, int *Key, int *ReturnCount, WORD *pb);#endif /* __OLD_WAY__ */int	mt_evnt_timer 		( unsigned long Interval, WORD *pb);int 	mt_form_alert 	( int DefButton, char *Str, WORD *pb);int 	mt_form_button 	( void *Btree, int Bobject, int Bclicks, int *Bnxtobj, WORD *pb);int 	mt_form_center 	( void *Tree, int *Cx, int *Cy, int *Cw, int *Ch, WORD *pb);int 	mt_form_dial 	( int Flag, int Sx, int Sy, int Sw, int Sh,                              	    int Bx, int By, int Bw, int Bh, WORD *pb);int 	mt_form_do 		( void *Tree, int StartObj, WORD *pb);int 	mt_form_error 	( int ErrorCode, WORD *pb);int 	mt_form_keybd 	( void *Ktree, int Kobject, int Kobnext, int Kchar, int *Knxtobject, int *Knxtchar, WORD *pb);int 	mt_form_popup 	( void *tree, int x, int y, WORD *pb);int 	mt_fsel_exinput ( char *Path, char *File, int *ExitButton, char *Prompt, WORD *pb);int 	mt_fsel_input 	( char *Path, char *File, int *ExitButton, WORD *pb);int 	mt_graf_dragbox ( int Sw, int Sh, 
						  int Sx, int Sy, int Bx, int By, int Bw, int Bh, 
						  int *Fw, int *Fh, WORD *pb); int 	mt_graf_growbox ( int Sx, int Sy, int Sw, int Sh, 
						  int Fx, int Fy, int Fw, int Fh, WORD *pb); int 	mt_graf_handle	( int *Wchar, int *Hchar, int *Wbox, int *Hbox, WORD *pb);int 	mt_graf_mkstate ( int *Mx, int *My, int *ButtonState, int *KeyState, WORD *pb); int 	mt_graf_mouse 	( int Form, void *FormAddress, WORD *pb);int 	mt_graf_movebox ( int Sw, int Sh, int Sx, int Sy, int Dx, int Dy, WORD *pb);int 	mt_graf_rubberbox(int Ix, int Iy, int Iw, int Ih, int *Fw, int *Fh, WORD *pb);int 	mt_graf_shrinkbox(int Fx, int Fy, int Fw, int Fh, int Sx, int Sy, int Sw, int Sh, WORD *pb); int 	mt_graf_slidebox( void *Tree, int Parent, int Object, int Direction, WORD *pb); int 	mt_graf_watchbox( void *Tree, int Object, int InState, int OutState, WORD *pb);int 	mt_menu_attach 	( int me_flag, OBJECT *me_tree, int me_item, MENU_T *me_mdata, WORD *pb);int 	mt_menu_bar 	( void *Tree, int ShowFlag, WORD *pb);int 	mt_menu_icheck 	( void *Tree, int Item, int CheckFlag, WORD *pb);int 	mt_menu_ienable	( void *Tree, int Item, int EnableFlag, WORD *pb);int 	mt_menu_istart 	( int me_flag, OBJECT *me_tree, int me_imenu, int me_item, WORD *pb);int 	mt_menu_popup 	( MENU_T *me_menu, int me_xpos, int me_ypos, MENU_T *me_mdata, WORD *pb);int 	mt_menu_register( int ApId, char *MenuText, WORD *pb);int 	mt_menu_settings( int me_flag, MN_SET *me_values, WORD *pb);int 	mt_menu_text 	( void *Tree, int Item, char *Text, WORD *pb);int 	mt_menu_tnormal ( void *Tree, int Item, int NormalFlag, WORD *pb);int	mt_objc_add 		( void *Tree, int Parent, int Child, WORD *pb);int	mt_objc_change 		( void *Tree, int Object, int Res, 
						  int Cx, int Cy, int Cw, int Ch, int NewState, int Redraw, WORD *pb);int	mt_objc_delete 		( void *Tree, int Object, WORD *pb);int	mt_objc_draw 		( void *Tree, int Start, int Depth,
						  int Cx, int Cy, int Cw, int Ch, WORD *pb);int	mt_objc_edit 		( void *Tree, int Object, int Char, int *Index, int Kind, WORD *pb); int	mt_objc_find 		( void *Tree, int Start, int Depth, int Mx, int My, WORD *pb);int	mt_objc_offset 		( void *Tree, int Object, int *X, int *Y, WORD *pb);int	mt_objc_order 		( void *Tree, int Object, int NewPos, WORD *pb);int	mt_objc_sysvar 		( int mode, int which, int in1, int in2, int *out1, int *out2, WORD *pb);int	mt_rsrc_free 		( WORD *pb);int	mt_rsrc_gaddr 		( int Type, int Index, void *Address, WORD *pb);int	mt_rsrc_load 		( char *Name, WORD *pb);int	mt_rsrc_obfix 		( void *Tree, int Index, WORD *pb);int	mt_rsrc_rcfix 		( void *rc_header, WORD *pb);int	mt_rsrc_saddr 		( int Type, int Index, void *Address, WORD *pb);int	mt_scrp_clear 		( WORD *pb);int	mt_scrp_read 		( char *Scrappath, WORD *pb);int	mt_scrp_write 		( char *Scrappath, WORD *pb);int	mt_shel_envrn 		( char **result, char *param, WORD *pb);int	mt_shel_find 		( char *buf, WORD *pb);int mt_shel_get 		( char *Buf, int Len, WORD *pb);int	mt_shel_help		( int sh_hmode, char *sh_hfile, char *sh_hkey, WORD *pb);int mt_shel_put	 		( char *Buf, int Len, WORD *pb);int	mt_shel_read 		( char *Command, char *Tail, WORD *pb);int	mt_shel_write		( int Exit, int Graphic, int Aes, char *Command, char *Tail, WORD *pb);int	mt_wind_calc 		( int Type, int Parts, int InX, int InY, int InW, int InH, 
						  int *OutX, int *OutY, int *OutW, int *OutH, WORD *pb); int	mt_wind_close 		( int WindowHandle, WORD *pb);int	mt_wind_create 		( int Parts, int Wx, int Wy, int Ww, int Wh, WORD *pb); int	mt_wind_delete 		( int WindowHandle, WORD *pb);int	mt_wind_find 		( int X, int Y, WORD *pb);int	mt_wind_get 		( int WindowHandle, int What,				  		  int *W1, int *W2, int *W3, int *W4, WORD *pb); int mt_wind_new 		( WORD *pb);int	mt_wind_open 		( int WindowHandle, int Wx, int Wy, int Ww,				   								int Wh, WORD *pb);int	mt_wind_set 		( int WindowHandle, int What, int W1, int W2, int W3, int W4, WORD *pb);int	mt_wind_update 		( int Code, WORD *pb);
/*
 *	fslx functions
 */
void* mt_fslx_do		( char *title, char *path, int pathlen, char *fname, int fnamelen,
						  char *patterns, XFSL_FILTER *filter, char *paths, int *sort_mode,
						  int flags, int *button, int *nfiles, char **pattern, WORD *gl);
int mt_fslx_evnt		( void *fsd, EVNT *events, char *path, char *fname, int *button,
						  int *nfiles, int *sort_mode, char **pattern, WORD *gl);
void* mt_fslx_open		( char *title, int x, int y, int *handle, char *path, int pathlen,
						  char *fname, int fnamelen, char *patterns, XFSL_FILTER *filter,
						  char *paths, int sort_mode, int flags, WORD *gl);
int mt_fslx_close		( void *fsd, WORD *gl);

/* * Some usefull extensions. */
int	mt_wind_calc_grect	( int Type, int Parts, GRECT *In, GRECT *Out, WORD *pb);int	mt_wind_create_grect( int Parts, GRECT *r, WORD *pb);int	mt_wind_open_grect 	( int WindowHandle, GRECT *r, WORD *pb);int mt_wind_get_grect	( int WindowHandle, int What, GRECT *r, WORD *pb);int mt_wind_set_grect	( int WindowHandle, int What, GRECT *r, WORD *pb);int mt_wind_set_str		( int WindowHandle, int What, char *str, WORD *pb);#endif
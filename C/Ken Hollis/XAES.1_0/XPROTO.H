/********************************************************************
 *																1.00*
 *	XAES: XAES Prototypes											*
 *	By Ken Hollis													*
 *																	*
 *	Copyright (C) 1994, Bitgate Software.							*
 *																	*
 ********************************************************************/

GLOBAL void WHandleActiveDrag(WINDOW *win);
GLOBAL void WSetCallback(int CBType, void *CallBackRout);
GLOBAL void DoCallback(int CBType);
GLOBAL void ClearCallbacks(void);
GLOBAL void ReadConfig(void);
GLOBAL WINDOW *WFindHandle(int handle);
GLOBAL int WDoDial(void);
GLOBAL long *get_cookiejar(void);
GLOBAL void create_cookie(COOKIE *cookie, long id, long value);
GLOBAL COOKIE *find_cookie(long id);
GLOBAL int new_cookie(COOKIE *ent);
GLOBAL BOOL get_cookie (long cookie, long *value);
GLOBAL int locate_cookie(long cookie);
GLOBAL void remove_cookie(long cookie_id);
GLOBAL void move_cookiejar(long *dest, long size);
GLOBAL long cookie_size();
GLOBAL int WWindSet(WINDOW *win, int wi_sfield, ...);
GLOBAL int WWindGet(WINDOW *win, int wi_gfield, ...);
GLOBAL int WOpenWindow(WINDOW *win);
GLOBAL void WCruelCloseWindow(WINDOW *win, BOOL icon);
GLOBAL void WKillWindow(WINDOW *win);
GLOBAL int WWindCreate(WINDOW *win);
GLOBAL void *WCreateObject(int type, ...);
GLOBAL void WTopWindow(WINDOW *win);
GLOBAL void WRedrawWindow(WINDOW *win, int x, int y, int w, int h);
GLOBAL void WKillAllWindows(int check);
GLOBAL void WCloseWindow(WINDOW *win, int message, int priority);
GLOBAL int WCallWndDispatcher(WINDOW *win, int msg_buf[]);
GLOBAL int WCallDlgDispatcher(WINDOW *win, int message);
GLOBAL int WCallWKeyDispatcher(WINDOW *win, int key);
GLOBAL int WCallBtnDispatcher(WINDOW *win, int mx, int my, int button, int kstate, int bclicks);
GLOBAL int WCallTxtDispatcher(WINDOW *win, int message);
GLOBAL int WCallFKeyDispatcher(WINDOW *win, int fkeynum);
GLOBAL int WCallHelpDispatcher(WINDOW *win);
GLOBAL int WCallUndoDispatcher(WINDOW *win);
GLOBAL int WCallHotkeyDispatcher(WINDOW *win, int key, int objnum);
GLOBAL int WCallTmrDispatcher(WINDOW *win);
GLOBAL int WCallTMDDispatcher(WINDOW *win, int mode);
GLOBAL int WCallBHelpDispatcher(WINDOW *win, int button);
GLOBAL int WCallSliderDispatcher(WINDOW *win, int object, int pos, int lastpos);
GLOBAL int WCallEtcDispatcher(int msg_buf[]);
GLOBAL int WCallKeyDispatcher(int key);
GLOBAL char *WGetEditText(char *te_ptmplt, char *te_ptext);
GLOBAL void WObjc_Edit(WINDOW *win, int mode, int key, int kstate);
GLOBAL int fix_object(OBJECT *obj, BOOL pos, BOOL repos);
GLOBAL void unfix_object(OBJECT *obj);
GLOBAL BOOL CheckMultitask(void);
GLOBAL BOOL	CheckSpeedup(void);
GLOBAL BOOL CheckPowerDOS(void);
GLOBAL BOOL CheckWinX(void);
GLOBAL void WObjFixPosition(OBJECT *obj);
GLOBAL void ChangeObjectText(OBJECT *obj, int idx, char *txt, int fnt, int just);
GLOBAL int intersect(int  x1,int  y1,int  w1,int  h1,
      	   	         int  x2,int  y2,int  w2,int  h2,
          	         int *x3,int *y3,int *w3,int *h3);
GLOBAL void *scrsave(int vdihandle,int x,int y,int w,int h);
GLOBAL void scrrestore(void *buffer);
GLOBAL void Objc_Change(WINDOW *win, int ob_cobject, int ob_crecvd, int ob_cnewstate, int ob_credraw);
GLOBAL void WObjc_Change(WINDOW *win, int ob_cobject, int ob_crecvd, int ob_cnewstate, int ob_credraw);
GLOBAL int WForm_button(WINDOW *win, int obj, int clicks, int *nxtobj);
GLOBAL void WUpdateWindow(WINDOW *win, int x, int y, int w, int h, int obj);
GLOBAL void WUpdateWindowDlg(WINDOW *win, int obj);
GLOBAL int rc_intersect(GRECT *r1, GRECT *r2);
GLOBAL int rc_inside(int x, int y, GRECT *r);
GLOBAL void no_click(void);
GLOBAL void edit_pos(WINDOW *win, int where);
GLOBAL int find_position(OBJECT *obj, int No, int mx);
GLOBAL int WForm_keybd(WINDOW *win, int key, int kstate, int *nobj, int *nchr);
GLOBAL void WSetupWinPopups(void);
GLOBAL void WDoRightHandle(void);
GLOBAL void WDoIconHandle(WINDOW *win);
GLOBAL int WForm_window(WINDOW *win, int obj, int clicks);
GLOBAL void WHandleWindowHelp(int button);
GLOBAL void init_mfdb(MFDB *fm, int *adr, int w, int h, int st, int pl);
GLOBAL void scale_img(int *src, int w, int h, int mode, int *b_w, int *b_h);
GLOBAL void scale_image(OBJECT *obj, int mode);
GLOBAL void vdi_trans(int w, int h, void *data);
GLOBAL void trans_image(OBJECT *obj);
GLOBAL void WMsgWindow(WINDOW *win, int msg_buf[8]);
GLOBAL int WFindOwner(int handle);
GLOBAL int WGrafMouse(int mo_sfield, ...);
GLOBAL void WObjc_Draw(WINDOW *win, int x, int y, int w, int h);
GLOBAL void WObjc_Draw_Out(WINDOW *win, int x, int y, int w, int h);
GLOBAL void PPopup_DialXY(OBJECT *srctree, int srcindex, OBJECT *desttree);
GLOBAL void PDropdown_DialXY(OBJECT *srctree, int srcindex, OBJECT *desttree);
GLOBAL void PPopup_WinXY(WINDOW *win, int srcindex, OBJECT *desttree);
GLOBAL void PDropdown_WinXY(WINDOW *win, int srcindex, OBJECT *desttree);
GLOBAL void PMovePopupCoord(OBJECT *desttree, int x, int y);
GLOBAL int PDoPopup(WINDOW *win, int index, OBJECT *menu_addr, int show, int x, int y, int w, int h);
GLOBAL int PDoPopupAddr(OBJECT *index);
GLOBAL int PShowPopupDesk(OBJECT *index);
GLOBAL int PEndPopupDesk(OBJECT *index);
GLOBAL int PDoPopupDeskMenu(OBJECT *index, int *retbtn);
GLOBAL BOOL WAttachCode(int typ, OBJECT *obj, int object, void *rout);
GLOBAL void position_fix(OBJECT *obj);
GLOBAL void WUpdateWindowDlgLevel(WINDOW *win, int x, int y, int w, int h, int obj, int level);
GLOBAL void WHandleSlider(WINDOW *win, int object);
GLOBAL void WHandleSlider_Window(WINDOW *win, int object);
GLOBAL int WInit(int DeskWndDispatcher(WINDOW *, int[]),
				 int MainDispatcher(int[]),
				 int KeyDispatcher(int), char *prgname, char *header,
				 BOOL HandleCallBacks);
GLOBAL void WBoot(void);
GLOBAL int WTerm(BOOL HandleCallBacks);
GLOBAL void WDie(int returns);
GLOBAL void WStartTimer(WINDOW *win);
GLOBAL void WStopTimer(WINDOW *win);
GLOBAL void WCreateTimer(WINDOW *win, int status, long ev_tcount, void *user);
GLOBAL BOOL WCheckTimersOpen(void);
GLOBAL void WRedrawAllWindows(void);
GLOBAL void WFixWindow(WINDOW *win);
GLOBAL void WFixSize(WINDOW *win);
GLOBAL void WWindAdjust(WINDOW *win);
GLOBAL void WMoveWindow(WINDOW *win, int x, int y, int w, int h);
GLOBAL void WInitCustomWindow(void);
GLOBAL void WGraf_Rubberbox(int bx, int by, int *endx, int *endy);
GLOBAL void WDragBox(int width, int height, int beginx, int beginy,
			int boundx, int boundy, int boundw, int boundh,
			int *endx, int *endy);
GLOBAL void WSizeBox(WINDOW *win, int mode);
GLOBAL void line(int x1, int y1, int x2, int y2);
GLOBAL void point(int x, int y, int color);
GLOBAL void box(int x, int y, int w, int h, int color);
GLOBAL void box_fill(int x, int y, int w, int h, int color);
GLOBAL void fillarea(int x1, int y1, int x2, int y2, int interior, int color);
GLOBAL void fill(int x, int y, int color);
GLOBAL void XVDI_SaveHandles(void);
GLOBAL void XVDI_RestoreHandles(void);
GLOBAL void XVDI_RestoreForGEM(void);

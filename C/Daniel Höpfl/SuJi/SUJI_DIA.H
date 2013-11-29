#ifndef __DH_SUJI_DIA_H_
#define __DH_SUJI_DIA_H_

#define BUBBLEGEM_SHOW	0xBABB
#define BUBBLEGEM_ACK	0xBABC
#define BUBBLEGEM_REQUEST 0xBABA

int cdecl handle_exit(DIALOG *dialog,EVNT *events,int obj,int clicks,void *data);
int passt_auf_den_bildschirm(int baum);
void clr_or_set_dialog_titel(int clr_set,OBJECT *tree,int obj);
void redraw_objc(DIALOG *dialog,int obj);
int my_sscanf(char *woher,int *a,int *b,int *c);
void make_scroll_edit(OBJECT *tree,int obj,XTED *xxted,int len);
void handle_dialog(void *pfade, int *x, int *y);
void bubble_hilfen(int fenster, int x, int y);

struct D_INFO
{
	int what;
	OBJECT *tree;
	int x,y,w,h;
	int w_handle;

	void *slider;
};

extern struct D_INFO dialog_maske;

extern DIALOG *maske_dialog;

extern XTED xted_maske;
extern XTED xted_inhalt;

extern EVNT events;

#endif

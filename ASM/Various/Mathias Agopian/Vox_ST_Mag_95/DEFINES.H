#include <aes.h>

#define max(A,B) ((A) > (B) ? (A) : (B))
#define min(A,B) ((A) < (B) ? (A) : (B))
#define TRUE ~0
#define FALSE 0

#define nb_window		5
#define W_INFOS			0
#define W_F0			1
#define W_F01			2
#define W_F1			3
#define W_F2			4
#define W_PRG_GRP		nb_window

typedef struct
{
	OBJECT *form;
	int hwind;
	int iconified;
	int opened;
	int	x;
	int	y;
	int	w;
	int	h;
	int attr;
	int fulled;
	char *title;
	char *title_icn;
	int pos;
	int bloquante;
	void (*DrawWind)(OBJECT *adr,int x,int y,int w,int h);
}WINDOW;


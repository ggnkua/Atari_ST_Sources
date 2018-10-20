#include "penedit.h"

typedef struct _PEN_LIST
{
	struct	_PEN_LIST	*prev;
	PEN_PARAMETER			this;
	struct	_PEN_LIST	*next;
}PEN_LIST;	

/* Pen-Funktionen */

void	dial_pens(int ob);
void	init_pen(int num);

void	init_pens(void);
int		count_pens(void);
PEN_PARAMETER *find_pen(int num);
PEN_LIST *find_pen_list(int num);
void	sel_pen_up(void);
void	sel_pen_down(void);

void	new_pen_val(int size, int ob);
void	pens_arrowed(WINDOW *win, int *pbuf);
void	pens_vslid(WINDOW *win, int *pbuf);
void	pens_sized(WINDOW *win, int *pbuf);

void	pens_load_save(void);
void	pens_load(int fh);
void	pens_save(int fh);


/* Pen-Globvars */

extern PEN_LIST	first_pen;
typedef struct
{
	int	off;	/* Offset fÅr oberstes (ab 0 )*/
	int	sel;	/* Nummer des selektierten oder -1 */
	int	len;	/* Anzahl der sichtbaren Objekte */
	int	last;	/* Nummer Letztes Objekt der sichtbaren Liste */
	
	int	wx,wy,ww,wh;	/* Fensterkoordinaten fÅr's Speichern */
}_pens_obs;
extern _pens_obs pens_obs;

extern OBJECT *opens, *osrcpens;
extern WINDOW wpens;
extern DINFO	dpens;
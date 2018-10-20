#include "layer.h"
#include "mask.h"

/* Undo-Eintrag: 
word info: 
     255 = Es folgt ein Zeigerpaar auf den n„chsten Pufferblock
     			(falls NULL = Pufferende)
     254 = Es folgt ein Zeigerpaar auf den vorigen Pufferblock
     			(falls NULL = Pufferanfang)
     sonstige: ID des Layers [ | 512 ]

falls Layer:
word x-pos: X-Position des Blocks
word y-pos: Y-Position des Blocks
word width: Breite
word height: H”he
falls | 512:
n*char(grey): Alter Wert
sonst:
n*(char red, char yellow, char blue): Alte Werte

immer:
word size: Gesamtgr”že des Undo-Eintrags (incl. size!)
*/


/* Undo defines */

#define UNDO_BUFSIZ	262144l


/* Undo typedefs */

typedef struct _FREE_UNDO_LIST
{
	struct _FREE_UNDO_LIST	*last;
	unsigned char		*free_buffer;
	struct _FREE_UNDO_LIST	*next;
}FREE_UNDO_LIST;


/* Undo-Funktionen */

void	dial_undo(int ob);
void	resize_undo(void);
void	init_undo(void);
void	clear_undo(void);
void	free_undo(void);
void	ff_undo(int mode);
void	rw_undo(int mode);
void	display_undo(void);
int		auto_reset(int typ);
int		cdecl undo_buf(GRECT *area, LAYER *layer, MASK *mask, int auto_res);
int		all_to_undo(LAYER *layer, MASK *mask);
int		frame_to_undo(int lay_or_mask);
int		frame_to_undo_ws(LAYER *lay, MASK *mask);
int		frame_to_undo_mouse(LAYER *lay, MASK *mask, int mouse);
int		part_frame_to_undo(LAYER *lay, MASK *mask, int flags);
void	del_undo_entry(int id, int mask);
void	undo_options(void);
void	dial_unopt(int ob);

/* Globale Variablen */

extern unsigned char *undo_start, *undo_end;
extern unsigned char *undo_maxend, undo_ok, undo_on;
extern int undo_id;

extern int undo_buffers;
extern OBJECT *oundo, *ounopt;
extern WINDOW	wundorec, wunopt;
extern DINFO	dundorec, dunopt;

extern FREE_UNDO_LIST	*ful;

;Tabulatorgrîûe:	3
;Kommentare:																;ab Spalte 60

						IMPORT	_GemParBlk								;extern  GEMPARBLK _GemParBlk;

						EXPORT	wdlg_create
						EXPORT	wdlg_open
						EXPORT	wdlg_close
						EXPORT	wdlg_delete
						
						EXPORT	wdlg_get_tree
						EXPORT	wdlg_get_edit
						EXPORT	wdlg_get_udata
						EXPORT	wdlg_get_handle

						EXPORT	wdlg_set_edit
						EXPORT	wdlg_set_tree
						EXPORT	wdlg_set_size

						EXPORT	wdlg_evnt
						EXPORT	wdlg_redraw

						EXPORT	lbox_create
						EXPORT	lbox_do
						EXPORT	lbox_update
						EXPORT	lbox_delete
						
						EXPORT	lbox_cnt_items
						EXPORT	lbox_get_tree
						EXPORT	lbox_get_avis
						EXPORT	lbox_get_udata
						EXPORT	lbox_get_afirst
						EXPORT	lbox_get_slct_idx
						EXPORT	lbox_get_items
						EXPORT	lbox_get_item
						EXPORT	lbox_get_slct_item
						EXPORT	lbox_get_idx
						
						EXPORT	lbox_set_asldr
						EXPORT	lbox_set_bsldr
						EXPORT	lbox_set_bentries
						EXPORT	lbox_set_items
						EXPORT	lbox_free_items
						EXPORT	lbox_free_list
						EXPORT	lbox_ascroll_to
						EXPORT	lbox_bscroll_to
						
						EXPORT	fnts_create
						EXPORT	fnts_delete
						EXPORT	fnts_open
						EXPORT	fnts_close
						EXPORT	fnts_get_no_styles
						EXPORT	fnts_get_style
						EXPORT	fnts_get_name
						EXPORT	fnts_get_info
						EXPORT	fnts_add
						EXPORT	fnts_remove
						EXPORT	fnts_update
						EXPORT	fnts_evnt
						EXPORT	fnts_do
						
;je nach Compiler und Definition des _GemParBlk mÅssen evtl. die Offset fÅr 
;die AES-Felder geÑndert werden.

						OFFSET	0
																				;{
_contrl: 			DS.W	15												;    int    contrl[15];
_global:				DS.W	15												;    int    global[15];
_intin:				DS.W	132											;    int    intin[132];
_intout:				DS.W	140											;    int    intout[140];
_addrin:				DS.L	16												;    int    intout[140];
_addrout:			DS.L	16												;    void   *addrout[16];
																				;} GEMPARBLK;

						
n_intin				EQU	2
n_addrin				EQU	6

AES					EQU	200
			
WDLG_CREATE			EQU	160
WDLG_OPEN			EQU	161
WDLG_CLOSE			EQU	162
WDLG_DELETE			EQU	163
WDLG_GET				EQU	164
WDLG_SET				EQU	165
WDLG_EVNT			EQU	166
WDLG_REDRAW			EQU	167

WDLG_GET_TREE		EQU	0
WDLG_GET_EDIT		EQU	1
WDLG_GET_UDATA		EQU	2
WDLG_GET_HANDLE	EQU	3

WDLG_SET_EDIT		EQU	0
WDLG_SET_TREE		EQU	1
WDLG_SET_SIZE		EQU	2
WDLG_SET_ICONIFY	EQU	3
WDLG_SET_UNICONIFY	EQU	4

LBOX_CREATE			EQU	170
LBOX_UPDATE			EQU	171
LBOX_DO				EQU	172
LBOX_DELETE			EQU	173
LBOX_GET				EQU	174
LBOX_SET				EQU	175

LBOX_CNT_ITEMS		EQU	0
LBOX_GET_TREE		EQU	1
LBOX_GET_AVIS		EQU	2
LBOX_GET_UDATA		EQU	3
LBOX_GET_FIRST		EQU	4
LBOX_GET_SLCT_IDX	EQU	5
LBOX_GET_ITEMS		EQU	6
LBOX_GET_ITEM		EQU	7
LBOX_GET_SLCT_ITEM	EQU	8
LBOX_GET_IDX		EQU	9
LBOX_GET_BVIS		EQU	10
LBOX_GET_BENTRIES	EQU	11
LBOX_GET_BFIRST	EQU	12

LBOX_SET_ASLDR		EQU	0
LBOX_SET_ITEMS		EQU	1
LBOX_FREE_ITEMS	EQU	2
LBOX_FREE_LIST		EQU	3
LBOX_ASCROLL_TO	EQU	4
LBOX_SET_BSLDR		EQU	5
LBOX_SET_BENTRIES	EQU	6
LBOX_BSCROLL_TO	EQU	7

FNTS_CREATE			EQU	180
FNTS_DELETE			EQU	181
FNTS_OPEN			EQU	182
FNTS_CLOSE			EQU	183
FNTS_GET				EQU	184
FNTS_SET				EQU	185
FNTS_EVNT			EQU	186
FNTS_DO				EQU	187

FNTS_GET_NO_STYLES	EQU	0
FNTS_GET_STYLE		EQU	1
FNTS_GET_NAME		EQU	2
FNTS_GET_INFO		EQU	3

FNTS_ADD				EQU	0
FNTS_REMOVE			EQU	1
FNTS_UPDATE			EQU	2

						TEXT
						
;DIALOG	*wdlg_create( HNDL_OBJ handle_exit, OBJECT *tree, void *user_data, WORD code, void *data, WORD flags );
wdlg_create:		move.l	a2,-(sp);

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_CREATE,(a2)						;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integers
						move.w	#4,n_addrin(a2)						;contrl[3]: 4 Adressen
						
						lea		(_GemParBlk+_intin),a2
						move.w	d0,(a2)+									;intin[0]: code
						move.w	d1,(a2)+									;intin[1]: flags
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: handle_exit
						move.l	a1,(a2)+									;addrin[1]: tree
						move.l	8(sp),(a2)+								;addrin[2]: user_data
						move.l	12(sp),(a2)+							;addrin[3]: data

						bsr		call_aes

						movea.l	(_GemParBlk+_addrout),a0			;addrout[0]: Zeiger auf Dialog-Struktur
						movea.l	(sp)+,a2
						rts


;WORD	wdlg_open( DIALOG *dialog, BYTE *title, WORD kind, WORD x, WORD y, WORD code, void *data );
wdlg_open:			move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_OPEN,(a2)						;contrl[0]: Funktionsnummer
						move.w	#4,n_intin(a2)							;contrl[1]: 4 Integers
						move.w	#3,n_addrin(a2)						;contrl[3]: 3 Adressen
						
						lea		(_GemParBlk+_intin),a2
						move.w	d0,(a2)+									;intin[0]: kind
						move.w	d1,(a2)+									;intin[1]: x
						move.w	d2,(a2)+									;intin[2]: y
						move.w	8(sp),(a2)+								;intin[3]: code
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						move.l	a1,(a2)+									;addrin[1]: title
						move.l	10(sp),(a2)+							;addrin[2]: data

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]: Fensterhandle
						movea.l	(sp)+,a2
						rts

;WORD	wdlg_close( DIALOG *dialog );
wdlg_close:			move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_CLOSE,(a2)						;contrl[0]: Funktionsnummer
						clr.w		n_intin(a2)								;contrl[1]: kein Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	wdlg_delete( DIALOG *dialog );
wdlg_delete:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_DELETE,(a2)						;contrl[0]: Funktionsnummer
						clr.w		n_intin(a2)								;contrl[1]: kein Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	wdlg_get_tree( DIALOG *dialog, OBJECT **tree, GRECT *r );
wdlg_get_tree:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#3,n_addrin(a2)						;contrl[3]: 3 Adressen

						lea		(_GemParBlk+_intin),a2
						clr.w		(a2)										;intin[0]: WDLG_GET_TREE

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						move.l	a1,(a2)+									;addrin[1]: tree
						move.l	8(sp),(a2)+								;addrin[2]: rect
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	wdlg_get_edit( DIALOG *dialog, WORD *cursor );
wdlg_get_edit:		move.l	a2,-(sp)
						move.l	a1,-(sp)

						move.w	#-1,(_GemParBlk+_intout+2)			;intout[1] fÅr alte Versionen
						
						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						move.w	#WDLG_GET_EDIT,(a2)					;intin[0]: WDLG_GET_EDIT

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						
						bsr		call_aes

						movea.l	(sp)+,a1
						lea		(_GemParBlk+_intout),a0				;intout
						move.w	(a0)+,d0									;intout[0]: Edit-Objekt
						move.w	(a0),(a1)								;intout[1]: Cursor-Position
						movea.l	(sp)+,a2
						rts

;void	*wdlg_get_udata( DIALOG *dialog );
wdlg_get_udata:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						move.w	#WDLG_GET_UDATA,(a2)					;intin[0]: WDLG_GET_UDATA

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						
						bsr		call_aes

						movea.l	(_GemParBlk+_addrout),a0			;addrout[0]: user_data
						movea.l	(sp)+,a2
						rts

;WORD	wdlg_get_handle( DIALOG *dialog );
wdlg_get_handle:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						move.w	#WDLG_GET_HANDLE,(a2)				;intin[0]: WDLG_GET_HANDLE

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]: Handle
						movea.l	(sp)+,a2
						rts

;WORD	wdlg_set_edit( DIALOG *dialog, WORD obj );
wdlg_set_edit:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integers
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						clr.w		(a2)+										;intin[0]: WDLG_SET_EDIT
						move.w	d0,(a2)+									;intin[1]: obj

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]: Edit-Objekt
						movea.l	(sp)+,a2
						rts

;WORD	wdlg_set_tree( DIALOG *dialog, OBJECT *tree );
wdlg_set_tree:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen

						lea		(_GemParBlk+_intin),a2
						move.w	#WDLG_SET_TREE,(a2)+					;intin[0]: WDLG_SET_TREE

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						move.l	a1,(a2)+									;addrin[1]: tree
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	wdlg_set_size( DIALOG *dialog, GRECT *size );
wdlg_set_size:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen

						lea		(_GemParBlk+_intin),a2
						move.w	#WDLG_SET_SIZE,(a2)+					;intin[0]: WDLG_SET_SIZE

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						move.l	a1,(a2)+									;addrin[1]: size
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts
						
;WORD	wdlg_set_iconify( DIALOG *d, GRECT *g, char *title, OBJECT *tree, WORD obj );
wdlg_set_iconify:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integer
						move.w	#4,n_addrin(a2)						;contrl[3]: 4 Adressen

						lea		(_GemParBlk+_intin),a2
						move.w	#WDLG_SET_ICONIFY,(a2)+				;intin[0]: WDLG_SET_ICONIFY
						move.w	d0,(a2)+									;intin[1]: obj

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						move.l	a1,(a2)+									;addrin[1]: size
						move.l	8(sp),(a2)+								;addrin[2]:	title
						move.l	12(sp),(a2)+							;addrin[3]: tree
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	wdlg_set_uniconify( DIALOG *d, GRECT *g, char *title, OBJECT *tree );
wdlg_set_uniconify:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#4,n_addrin(a2)						;contrl[3]: 4 Adressen

						lea		(_GemParBlk+_intin),a2
						move.w	#WDLG_SET_UNICONIFY,(a2)+			;intin[0]: WDLG_SET_UNICONIFY

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						move.l	a1,(a2)+									;addrin[1]: size
						move.l	8(sp),(a2)+								;addrin[2]:	title
						move.l	12(sp),(a2)+							;addrin[3]: tree
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts
						
;WORD	wdlg_evnt( DIALOG *dialog, EVNT *events );
wdlg_evnt:			move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_EVNT,(a2)						;contrl[0]: Funktionsnummer
						clr.w		n_intin(a2)								;contrl[1]: keine Integers
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						move.l	a1,(a2)+									;addrin[1]: events
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;void	wdlg_redraw( DIALOG *dialog, GRECT *rect, WORD obj, WORD depth );
wdlg_redraw:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#WDLG_REDRAW,(a2)						;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integers
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen
						
						lea		(_GemParBlk+_intin),a2
						move.w	d0,(a2)+									;intin[0]: obj
						move.w	d1,(a2)+									;intin[1]: depth

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: dialog
						move.l	a1,(a2)+									;addrin[1]: rect
						
						bsr		call_aes

						movea.l	(sp)+,a2
						rts

;LIST_BOX	*lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, 
;								  LBOX_ITEM *items, WORD visible_a, WORD first_a,
;								  WORD *ctrl_objs, WORD *objs, WORD flags, 
;								  WORD pause_a, void *user_data, DIALOG *dialog,
;								  WORD visible_b, WORD first_b, WORD entries_b, WORD pause_b );
lbox_create:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_CREATE,(a2)						;contrl[0]: Funktionsnummer
						move.w	#8,n_intin(a2)							;contrl[1]: 8 Integers
						move.w	#8,n_addrin(a2)						;contrl[3]: 8 Adressen
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: tree
						move.l	a1,(a2)+									;addrin[1]: slct

						lea		8(sp),a0									;Zeiger auf <set>
						move.l	(a0)+,(a2)+								;addrin[2]: set
						move.l	(a0)+,(a2)+								;addrin[3]: items

						lea		(_GemParBlk+_intin),a1
						move.w	d0,(a1)+									;intin[0]: visible_a
						move.w	d1,(a1)+									;intin[1]: first_a

						move.l	(a0)+,(a2)+								;addrin[4]: ctrl_objs
						move.l	(a0)+,(a2)+								;addrin[5]: objs

						move.w	d2,(a1)+									;intin[2]: flags
						move.w	(a0)+,(a1)+								;intin[3]: pause_a
						
						move.l	(a0)+,(a2)+								;addrin[6]: user_data
						move.l	(a0)+,(a2)+								;addrin[7]: dialog

						move.w	(a0)+,(a1)+								;intin[4]: visible_b
						move.w	(a0)+,(a1)+								;intin[5]: first_b
						move.w	(a0)+,(a1)+								;intin[6]: entries_b
						move.w	(a0)+,(a1)+								;intin[7]: pause_b
						
						bsr		call_aes

						movea.l	(_GemParBlk+_addrout),a0			;addrout[0]:
						movea.l	(sp)+,a2
						rts

;void	lbox_update( LIST_BOX *box, GRECT *rect );
lbox_update:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_UPDATE,(a2)						;contrl[0]: Funktionsnummer
						clr.w		n_intin(a2)								;contrl[1]: keine Integers
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box
						move.l	a1,(a2)+									;addrin[1]: rect

						bsr		call_aes

						movea.l	(sp)+,a2
						rts

;WORD	lbox_do( LIST_BOX *box, WORD obj );
lbox_do:				move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_DO,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	d0,(a2)+									;intin[0]: obj

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]: slct_obj
						movea.l	(sp)+,a2
						rts

;WORD	lbox_delete( LIST_BOX *box );
lbox_delete:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_DELETE,(a2)						;contrl[0]: Funktionsnummer
						clr.w		n_intin(a2)								;contrl[1]: keine Integers
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	lbox_cnt_items( LIST_BOX *box );
lbox_cnt_items:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						clr.w		(a2)+										;intin[0]: LBOX_CNT_ITEMS
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;OBJECT	*lbox_get_tree( LIST_BOX *box );
lbox_get_tree:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_TREE,(a2)+					;intin[0]: LBOX_GET_TREE
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						movea.l	(_GemParBlk+_addrout),a0			;addrout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	lbox_get_avis( LIST_BOX *box );
lbox_get_avis:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_AVIS,(a2)+					;intin[0]: LBOX_GET_AVIS
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;void	*lbox_get_udata( LIST_BOX *box );
lbox_get_udata:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_UDATA,(a2)+				;intin[0]: LBOX_GET_UDATA 
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						movea.l	(_GemParBlk+_addrout),a0			;addrout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	lbox_get_afirst( LIST_BOX *box );
lbox_get_afirst:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_FIRST,(a2)+				;intin[0]: LBOX_GET_FIRST
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	lbox_get_slct_idx( LIST_BOX *box );
lbox_get_slct_idx:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_SLCT_IDX,(a2)+			;intin[0]: LBOX_GET_SLCT_IDX
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;LBOX_ITEM	*lbox_get_items( LIST_BOX *box );
lbox_get_items:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_ITEMS,(a2)+				;intin[0]: LBOX_GET_ITEMS
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						movea.l	(_GemParBlk+_addrout),a0			;addrout[0]:
						movea.l	(sp)+,a2
						rts

;LBOX_ITEM	*lbox_get_item( LIST_BOX *box, WORD n );
lbox_get_item:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integers
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_ITEM,(a2)+					;intin[0]: LBOX_GET_ITEM
						move.w	d0,(a2)+									;intin[1]: n
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						movea.l	(_GemParBlk+_addrout),a0			;addrout[0]:
						movea.l	(sp)+,a2
						rts

;LBOX_ITEM *lbox_get_slct_item( LIST_BOX *box );
lbox_get_slct_item:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_SLCT_ITEM,(a2)+			;intin[0]: LBOX_GET_SLCT_ITEM
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						movea.l	(_GemParBlk+_addrout),a0			;addrout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	lbox_get_idx( LBOX_ITEM *items, LBOX_ITEM *search );
lbox_get_idx:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_IDX,(a2)+					;intin[0]: LBOX_GET_IDX
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: items
						move.l	a1,(a2)+									;addrin[1]: search

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	lbox_get_bvis( LIST_BOX *box );
lbox_get_bvis:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_BVIS,(a2)+					;intin[0]: LBOX_GET_BVIS
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	lbox_get_bentries( LIST_BOX *box );
lbox_get_bentries:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_BENTRIES,(a2)+			;intin[0]: LBOX_GET_BENTRIES
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	lbox_get_bfirst( LIST_BOX *box );
lbox_get_bfirst:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_GET_BFIRST,(a2)+				;intin[0]: LBOX_GET_BFIRST
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts
						
;void	lbox_set_asldr( LIST_BOX *box, WORD first, GRECT *rect );
lbox_set_asldr:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integers
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen
						
						lea		(_GemParBlk+_intin),a2
						clr.w		(a2)+										;intin[0]: LBOX_SET_ASLDR,(a2)+
						move.w	d0,(a2)+									;intin[1]: first
										
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box
						move.l	a1,(a2)+									;addrin[1]: rect
						
						bsr		call_aes

						movea.l	(sp)+,a2
						rts

;void	lbox_set_items( LIST_BOX *box, LBOX_ITEM *items );
lbox_set_items:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_SET_ITEMS,(a2)+				;intin[0]: LBOX_SET_ITEMS
										
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box
						move.l	a1,(a2)+									;addrin[1]: items
						
						bsr		call_aes

						movea.l	(sp)+,a2
						rts

;void	lbox_free_items( LIST_BOX *box );
lbox_free_items:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_FREE_ITEMS,(a2)+				;intin[0]: LBOX_FREE_ITEMS
										
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box
						
						bsr		call_aes

						movea.l	(sp)+,a2
						rts

;void	lbox_free_list( LBOX_ITEM *items );
lbox_free_list:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_FREE_LIST,(a2)+				;intin[0]: LBOX_FREE_LIST
										
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: items
						
						bsr		call_aes

						movea.l	(sp)+,a2
						rts

;void	lbox_ascroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect );
lbox_ascroll_to:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integers
						move.w	#3,n_addrin(a2)						;contrl[3]: 3 Adressen
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_ASCROLL_TO,(a2)+				;intin[0]: LBOX_ASCROLL_TO
						move.w	d0,(a2)+									;intin[1]: first
										
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box
						move.l	a1,(a2)+									;addrin[1]: box_rect
						move.l	8(sp),(a2)+								;addrin[2]: slider_rect						

						bsr		call_aes

						movea.l	(sp)+,a2
						rts
						
;void	lbox_set_bsldr( LIST_BOX *box, WORD first, GRECT *rect );
lbox_set_bsldr:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integers
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_SET_BSLDR,(a2)+
						move.w	d0,(a2)+									;intin[1]: first
										
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box
						move.l	a1,(a2)+									;addrin[1]: rect
						
						bsr		call_aes

						movea.l	(sp)+,a2
						rts
						
;void	lbox_set_bentries( LIST_BOX *box, WORD entries );
lbox_set_bentries:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integers
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_SET_BENTRIES,(a2)+
						move.w	d0,(a2)+									;intin[1]: entries
										
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box
						
						bsr		call_aes

						movea.l	(sp)+,a2
						rts

;void	lbox_bscroll_to( LIST_BOX *box, WORD first, GRECT *box_rect, GRECT *slider_rect );
lbox_bscroll_to:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#LBOX_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#2,n_intin(a2)							;contrl[1]: 2 Integers
						move.w	#3,n_addrin(a2)						;contrl[3]: 3 Adressen
						
						lea		(_GemParBlk+_intin),a2
						move.w	#LBOX_BSCROLL_TO,(a2)+				;intin[0]: LBOX_BSCROLL_TO
						move.w	d0,(a2)+									;intin[1]: first
										
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: box
						move.l	a1,(a2)+									;addrin[1]: box_rect
						move.l	8(sp),(a2)+								;addrin[2]: slider_rect						

						bsr		call_aes

						movea.l	(sp)+,a2
						rts

;FNT_DIALOG	*fnts_create( WORD vdi_handle, WORD no_fonts, WORD font_flags, WORD dialog_flags, BYTE *sample, BYTE *opt_button );
fnts_create:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_CREATE,(a2)						;contrl[0]: Funktionsnummer
						move.w	#4,n_intin(a2)							;contrl[1]: 4 Integers
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen

						lea		(_GemParBlk+_intin),a2
						move.w	d0,(a2)+									;intin[0]: vdi_handle
						move.w	d1,(a2)+									;intin[1]: no_fonts
						move.w	d2,(a2)+									;intin[2]: font_flags
						move.w	8(sp),(a2)+								;intin[3]: dialog_flags
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: sample
						move.l	a1,(a2)+									;addrin[1]: opt_button
						
						bsr		call_aes
						
						movea.l	(_GemParBlk+_addrout),a0			;addrout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	fnts_delete( FNT_DIALOG *fnt_dialog, WORD vdi_handle );
fnts_delete:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_DELETE,(a2)						;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						move.w	d0,(a2)+									;intin[0]: vdi_handle
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog
						
						bsr		call_aes
						
						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	fnts_open( FNT_DIALOG *fnt_dialog, WORD button_flags, WORD x, WORD y, LONG id, LONG pt, LONG ratio );
fnts_open:			move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_OPEN,(a2)						;contrl[0]: Funktionsnummer
						move.w	#9,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog
						
						lea		(_GemParBlk+_intin),a2
						move.w	d0,(a2)+									;intin[0]: button_flags
						move.w	d1,(a2)+									;intin[1]: x
						move.w	d2,(a2)+									;intin[2]: y

						lea		8(sp),a0									;Zeiger auf die Stack-Parameter
						move.l	(a0)+,(a2)+								;intin[3/4]: id
						move.l	(a0)+,(a2)+								;intin[5/6]: pt
						move.l	(a0)+,(a2)+								;intin[7/8]: ratio

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts
						
;WORD	fnts_close( FNT_DIALOG *fnt_dialog );
fnts_close:			move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_CLOSE,(a2)						;contrl[0]: Funktionsnummer
						move.w	#0,n_intin(a2)							;contrl[1]: kein Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	fnts_get_no_styles( FNT_DIALOG *fnt_dialog, LONG id );
fnts_get_no_styles:
						move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#3,n_intin(a2)							;contrl[1]: kein Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						move.w	#FNTS_GET_NO_STYLES,(a2)+			;intin[0]: fnts_get_no_styles
						move.l	d0,(a2)+									;intin[1/2]: id

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;LONG	fnts_get_style( FNT_DIALOG *fnt_dialog, LONG id, WORD index );
fnts_get_style:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#4,n_intin(a2)							;contrl[1]: kein Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						move.w	#FNTS_GET_STYLE,(a2)+				;intin[0]: fnts_get_style
						move.l	d0,(a2)+									;intin[1/2]: id
						move.w	d1,(a2)+									;intin[3]: index
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog

						bsr		call_aes

						move.l	(_GemParBlk+_intout),d0				;intout[0/1]:
						movea.l	(sp)+,a2
						rts

;WORD	fnts_get_name( FNT_DIALOG *fnt_dialog, LONG id, BYTE *full_name, BYTE *family_name, BYTE *style_name );
fnts_get_name:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#3,n_intin(a2)							;contrl[1]: 3 Integers
						move.w	#4,n_addrin(a2)						;contrl[3]: 4 Adressen

						lea		(_GemParBlk+_intin),a2
						move.w	#FNTS_GET_NAME,(a2)+					;intin[0]: fnts_get_name
						move.l	d0,(a2)+									;intin[1/2]: id
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog
						move.l	a1,(a2)+									;addrin[1]: full_name
						move.l	8(sp),(a2)+								;addrin[2]: family_name
						move.l	12(sp),(a2)+							;addrin[3]: style_name
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts
	
;WORD	fnts_get_info( FNT_DIALOG *fnt_dialog, LONG id, WORD *mono, WORD *outline );
fnts_get_info:	move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_GET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#3,n_intin(a2)							;contrl[1]: 3 Integers
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						move.w	#FNTS_GET_INFO,(a2)+					;intin[0]: fnts_get_info
						move.l	d0,(a2)+									;intin[1/2]: id
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog
						
						move.l	a1,-(sp)
						bsr		call_aes
						movea.l	(sp)+,a1									;mono
						movea.l	8(sp),a2									;outline
						
						lea		(_GemParBlk+_intout),a0
						move.w	(a0)+,d0									;intout[0]: index
						move.w	(a0)+,(a1)								;intout[1]: *mono
						move.w	(a0)+,(a2)								;intout[2]: *outline

						movea.l	(sp)+,a2
						rts

;WORD	fnts_add( FNT_DIALOG *fnt_dialog, FNTS_ITEM *user_fonts );
fnts_add:			move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: kein Integer
						move.w	#2,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						move.w	#FNTS_ADD,(a2)+						;intin[0]: fnts_add
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog
						move.l	a1,(a2)+									;addrin[1]: user_fonts
						
						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;void	fnts_remove( FNT_DIALOG *fnt_dialog );
fnts_remove:		move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#1,n_intin(a2)							;contrl[1]: kein Integer
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_intin),a2
						move.w	#FNTS_REMOVE,(a2)+					;intin[0]: fnts_remove
						
						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog
						
						bsr		call_aes

						movea.l	(sp)+,a2
						rts

;WORD	fnts_update( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id, LONG pt, LONG ratio );
fnts_update:		move.l	a2,-(sp)

						move.w	#-1,(_GemParBlk+_intout)			;intout[0] fÅr alte Versionen

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_SET,(a2)							;contrl[0]: Funktionsnummer
						move.w	#8,n_intin(a2)							;contrl[1]: 1 Integer
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog
						
						lea		(_GemParBlk+_intin),a2
						move.w	#FNTS_UPDATE,(a2)+					;intin[0]: fnts_update
						move.w	d0,(a2)+									;intin[1]: button_flags
						move.l	d1,(a2)+									;intin[2/3]: id
						move.l	d2,(a2)+									;intin[4/5]: pt
						move.l	8(sp),(a2)+								;intin[6/7]: ratio

						bsr		call_aes

						move.w	(_GemParBlk+_intout),d0				;intout[0]:
						movea.l	(sp)+,a2
						rts

;WORD	fnts_evnt( FNT_DIALOG *fnt_dialog, EVNT *events, WORD *button, WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio );
fnts_evnt:			move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_EVNT,(a2)						;contrl[0]: Funktionsnummer
						move.w	#0,n_intin(a2)							;contrl[1]: kein Integer
						move.w	#2,n_addrin(a2)						;contrl[3]: 2 Adressen

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog
						move.l	a1,(a2)+									;addrin[1]: events

						bsr		call_aes

						lea		(_GemParBlk+_intout),a2
						move.w	(a2)+,d0									;intout[0]:

						lea		8(sp),a0									;Zeiger auf die Stack-Parameter
						move.l	(a0)+,a1
						move.w	(a2)+,(a1)								;intout[1]: *button
						move.l	(a0)+,a1
						move.w	(a2)+,(a1)								;intout[2]: *check_boxes
						move.l	(a0)+,a1
						move.l	(a2)+,(a1)								;intout[3/4]: *id
						move.l	(a0)+,a1
						move.l	(a2)+,(a1)								;intout[5/6]: *pt
						move.l	(a0)+,a1
						move.l	(a2)+,(a1)								;intout[7/8]: *ratio

						movea.l	(sp)+,a2
						rts

;WORD	fnts_do( FNT_DIALOG *fnt_dialog, WORD button_flags, LONG id_in, LONG pt_in, LONG ratio_in, 
;					WORD *check_boxes, LONG *id, LONG *pt, LONG *ratio );
fnts_do:				move.l	a2,-(sp)

						lea		(_GemParBlk+_contrl),a2
						move.w	#FNTS_DO,(a2)							;contrl[0]: Funktionsnummer
						move.w	#7,n_intin(a2)							;contrl[1]: 7 Integers
						move.w	#1,n_addrin(a2)						;contrl[3]: 1 Adresse

						lea		(_GemParBlk+_addrin),a2
						move.l	a0,(a2)+									;addrin[0]: fnt_dialog

						lea		(_GemParBlk+_intin),a2
						move.w	d0,(a2)+									;intin[0]: button_flags
						move.l	d1,(a2)+									;intin[1/2]: id_in
						move.l	d2,(a2)+									;intin[3/4]: pt_in
						move.l	8(sp),(a2)+								;intin[5/6]: ratio_in
						
						move.l	a1,-(sp)									;check_boxes sichern

						bsr		call_aes

						movea.l	(sp)+,a1
						lea		(_GemParBlk+_intout),a2

						move.w	(a2)+,d0									;intout[0]:
						move.w	(a2)+,(a1)								;intout[1]: *check_boxes

						lea		12(sp),a0								;Zeiger auf die Stack-Parameter ab id
						move.l	(a0)+,a1
						move.l	(a2)+,(a1)								;intout[2/3]: *id
						move.l	(a0)+,a1
						move.l	(a2)+,(a1)								;intout[4/5]: *pt
						move.l	(a0)+,a1
						move.l	(a2)+,(a1)								;intout[6/7]: *ratio

						movea.l	(sp)+,a2
						rts

call_aes:			lea		pb,a0
						move.l	a0,d1										;Zeiger auf pb
						move.w	#AES,d0
						trap		#2
						rts

						DATA
						
pb:					DC.L	_GemParBlk + _contrl
						DC.L	_GemParBlk + _global
						DC.L	_GemParBlk + _intin
						DC.L	_GemParBlk + _intout
						DC.L	_GemParBlk + _addrin
						DC.L	_GemParBlk + _addrout

						END
;Tabulatorgrîûe:	3
;Kommentare:																;ab Spalte 60

						IMPORT	_GemParBlk								;extern  GEMPARBLK _GemParBlk;

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

						TEXT
						

;void	*lbox_create( OBJECT *tree, SLCT_ITEM slct, SET_ITEM set, 
;						  LBOX_ITEM *items, WORD visible_a, WORD first_a,
;						  WORD *ctrl_objs, WORD *objs, WORD flags, 
;						  WORD pause_a, void *user_data, void *dialog,
;						  WORD visible_b, WORD first_b, WORD entries_b, WORD pause_b );
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

;void	lbox_update( void *box, GRECT *rect );
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

;WORD	lbox_do( void *box, WORD obj );
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

;WORD	lbox_delete( void *box );
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

;WORD	lbox_cnt_items( void *box );
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

;OBJECT	*lbox_get_tree( void *box );
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

;WORD	lbox_get_avis( void *box );
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

;void	*lbox_get_udata( void *box );
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

;WORD	lbox_get_afirst( void *box );
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

;WORD	lbox_get_slct_idx( void *box );
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

;LBOX_ITEM	*lbox_get_items( void *box );
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

;LBOX_ITEM	*lbox_get_item( void *box, WORD n );
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

;LBOX_ITEM *lbox_get_slct_item( void *box );
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

;WORD	lbox_get_bvis( void *box );
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

;WORD	lbox_get_bentries( void *box );
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

;WORD	lbox_get_bfirst( void *box );
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
						
;void	lbox_set_asldr( void *box, WORD first, GRECT *rect );
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

;void	lbox_set_items( void *box, LBOX_ITEM *items );
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

;void	lbox_free_items( void *box );
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

;void	lbox_ascroll_to( void *box, WORD first, GRECT *box_rect, GRECT *slider_rect );
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
						
;void	lbox_set_bsldr( void *box, WORD first, GRECT *rect );
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
						
;void	lbox_set_bentries( void *box, WORD entries );
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

;void	lbox_bscroll_to( void *box, WORD first, GRECT *box_rect, GRECT *slider_rect );
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
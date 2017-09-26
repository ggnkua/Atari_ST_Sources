typedef struct _suf_item
{
	struct	_suf_item	*next;
	BYTE		*str;
	UWORD		mode;
} SUF_ITEM;

WORD	cdecl	HandleSuffixDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );

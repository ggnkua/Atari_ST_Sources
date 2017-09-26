#ifndef	__HOTLIST__
#define	__HOTLIST__

#ifdef	IRC_CLIENT
#include	"Irc.h"
#endif
#ifdef	TELNET_CLIENT
#include	"Telnet.h"
#endif


typedef struct	__ht_item__
{
	struct __ht_item__	*next;
	WORD	selected;
	WORD	data1;
	BYTE	*Name;
#ifdef	IRC_CLIENT
	IRC	*Irc;
#endif
#ifdef	TELNET_CLIENT
	TELNET	*Telnet;
#endif
	struct __ht_item__	*prev;
}	HT_ITEM;

#ifdef	IRC_CLIENT
IRC	*GetIrcHotlist( WORD n );
#endif
#ifdef	TELNET_CLIENT
TELNET	*GetTelnetHotlist( WORD n );
#endif

void		OpenHotlistDialog( WORD Global[15] );
void		UpdateHotlistPopup( HT_ITEM *HtList, OBJECT **HotlistPopup );
void		InsertHtItem( HT_ITEM *New, HT_ITEM **HtList );
void		SortHtItem( HT_ITEM *HtList );
WORD		GetMaxLenHtItem( HT_ITEM *HtList );

#endif

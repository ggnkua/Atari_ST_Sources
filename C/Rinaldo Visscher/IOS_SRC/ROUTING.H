/*
**	OutMail utility routines
*/

#if !defined (__ROUTING_H__)
#define __ROUTING_H__

BYTE	*outbound_dir(UWORD zone, UWORD net, UWORD node, UWORD point);
BYTE	DenyOk(UWORD zone, UWORD net, UWORD node, UWORD point);
VOID	Knownas(MSGHEADER *hdr, UWORD *zone, UWORD *net, UWORD *node, UWORD *point);

VOID	attached_file(MSGHEADER *hdr);
BOOLEAN	filesendOk(LONG size, UWORD zone, UWORD net, UWORD node, UWORD point);

WORD	routeOk(MSGHEADER *hdr);
WORD	moveOk(UWORD zone, UWORD net, UWORD node, UWORD point);
BOOLEAN	sendOk(MSGHEADER *hdr, WORD what);
BOOLEAN	holdOk(UWORD zone, UWORD net, UWORD node, UWORD point);
BOOLEAN crashPoint(UWORD zone, UWORD net, UWORD node, UWORD point);
BOOLEAN	crashOk(UWORD zone, UWORD net, UWORD node);
BOOLEAN	arcOk(UWORD zone, UWORD net, UWORD node, UWORD point);
WORD	hold_pollOk(UWORD zone, UWORD net, UWORD node, UWORD point, WORD what);

VOID	find_ROUTE(MSGHEADER *hdr, BYTE *msgtext);
VOID	check_HDR(VOID);

BOOLEAN	capture_msg(MSGHEADER *hdr);
BOOLEAN	checkPATH(VOID);
VOID	redo_PATH(VOID);
BYTE 	DO_readdress (MSGHEADER *Hdr, BYTE *msg) ;
#endif
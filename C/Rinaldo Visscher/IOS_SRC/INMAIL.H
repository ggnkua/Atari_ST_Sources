#if !defined (__INMAIL_H__)
#define __INMAIL_H__

#define	ARCMAIL			1
#define	EMPTY			0

#define	UNKNOWN_SYSTEM	1
#define	OUR_SYSTEM		0

VOID	import_pkt(BYTE *path);
BYTE	unpack_pkt(VOID);
BYTE	arc_mail(BYTE *name);
BYTE	unpack(BYTE *name);
VOID	have_pkt(BYTE *pktname, BYTE *path);
VOID	rename_pkt(BYTE *oldname);
BYTE	check_nodes(UWORD zone, UWORD net, UWORD node, UWORD point);
BYTE	import_messages(BYTE *pktname);
BYTE	get_fields(VOID);
VOID	read_message(VOID);
BYTE	find_message(VOID);
BYTE	*get_area(BYTE *msg);
UWORD	get_point(BYTE *msg, BYTE *line);
BYTE	get_interzone(BYTE *msg, UWORD *fzone, UWORD *fnet,
			UWORD *fnode, UWORD *tzone, UWORD *tnet, UWORD *tnode);
BYTE	get_msgid(BYTE *msg, UWORD *zone, UWORD *net, UWORD *node, UWORD *point);
BYTE	get_reply(BYTE *msg, UWORD *zone, UWORD *net, UWORD *node, UWORD *point);
VOID	handle_message(BYTE *);
BYTE	*strip_cr(BYTE *l);
BYTE	*get_path(BYTE *msg, WORD area);
BYTE	*get_seen(BYTE *msg, WORD area);
VOID	get_org_and_tearline(BYTE *msg);
WORD	ourseen(WORD area, UWORD point, MSGHEADER *hdr, BYTE *domain);
WORD	ourpath(WORD area, BYTE *domain);
VOID	Addline(BYTE *msg, BYTE *what, WORD numbers, UWORD ourzone);
VOID	savemsg(BYTE whereto, MSGHEADER *hmsg, WORD area, BYTE *msg,
			UWORD zone, UWORD net, UWORD node, UWORD point);
VOID	dupesave(MSGHEADER *Hdr, BYTE *message);
BYTE	*strip_line(BYTE *msg, BYTE *lie);
BYTE	Openpkt(WORD file, BYTE *node32, MSGHEADER *Hdr);
BYTE	Openarea(WORD file, BYTE *Hfile, BYTE *Mfile, MSGHEADER *Hdr);
BYTE	ouralias(UWORD zone, UWORD net, UWORD node, UWORD point);
VOID	show_results(VOID);
BYTE	find_field_end(VOID);
BYTE	rename_arcmail(BYTE *name);
WORD	other_zone(UWORD *tozone, UWORD *tonet, UWORD *tonode,
			UWORD *fromzone, UWORD *fromnet, UWORD *fromnode);
VOID	add_extra_byte(BYTE *ext);
VOID	extra_byte(BYTE *fname);
VOID	get_last_byte(FILE *stream, BYTE *filename);
BYTE	check_diskspace(LONG space);
VOID 	ToDataBase(MSGHEADER *Hdr, BYTE *msg, WORD area);
VOID	isPKT(BYTE *file);

#endif
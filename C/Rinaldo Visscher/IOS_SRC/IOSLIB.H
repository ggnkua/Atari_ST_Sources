/*
**	IOSmail Utility Library
*/

#if !defined (__IOSLIB_H__)
#define __IOSLIB_H__

VOID	w_error(BYTE *where);
VOID	terminate(WORD elevel);
VOID	*myalloc(size_t sp);
BOOLEAN	area_changed(WORD area);
WORD	to_area(BYTE *msgtext);
WORD	ARCtype(BYTE *ARCfile);
VOID	decrypt(IOSKEY *key);
UWORD	intel(UWORD x);
VOID	sort_connected(WORD count, WORD start);
VOID	Copy_or_Move(BYTE *line,BOOLEAN what);
WORD	move_area(WORD org_area, MSGHEADER *hdr);
WORD	copy_area(WORD org_area, MSGHEADER *hdr);
VOID	packmail(UWORD toarea, UWORD nseenby, BYTE *expmsg, MSGHEADER *fhdr);
LONG 	lmin(register LONG g1, register LONG g2);
WORD 	min(register WORD g1, register WORD g2);
LONG 	lmax(register LONG g1, register LONG g2);
VOID 	OpenLastRead(VOID);
VOID 	SetLastReadPtr (WORD area, WORD value);
WORD 	GetLastReadPtr (WORD Area);
WORD 	Aopen(VOID);
VOID 	clean_mess(VOID);
VOID 	buf_init(_filebuf *bp, LONG bsize, LONG itemsize);
VOID 	buf_free(_filebuf *bp);
VOID 	up_lastbbs(WORD areanr, WORD highest);
WORD 	msgok(MSGHEADER *hp, WORD area);
WORD 	cleanEcho(VOID);
VOID 	Aclose(WORD changed);
VOID 	deinitialize(VOID);
LONG	diskfree(WORD drive);
VOID 	Update_LED(WORD deleted);
BOOLEAN newmatch(BYTE *str, BYTE *pattern);
BOOLEAN Not_allowed(BYTE *msgtext, WORD area);

/*
**	Message text manipulation
*/

BYTE	*change_msgid(BYTE *msgtext, MSGHEADER *hdr);
BYTE	*add_a_line(BYTE *line, BYTE *addline, BYTE *msgtext);
BOOLEAN	add_point(BYTE *msgtext, MSGHEADER *hdr);
BYTE	*strline(BYTE *msgtext, BYTE *line);
BYTE	*strip_those_lines(BYTE *msgtext, BYTE *line);
BYTE	*Remove_and_Add(BYTE *string, BYTE *msg);

/*
**	Filenames generating/parsing
*/

BYTE	*nodestr(UWORD zone, UWORD net, UWORD node);
VOID	getTBaddress(BYTE *str, UWORD *zone, UWORD *net, UWORD *node);
VOID	getBTaddress(BYTE *str, UWORD *net, UWORD *node, UWORD *point);
VOID	get4Daddress(BYTE *str, UWORD *zone, UWORD *net, UWORD *node,
			UWORD *point);
BYTE	*address(BYTE *s, UWORD *zone, UWORD *net, UWORD *node,
			UWORD *point, UWORD *pnet, BYTE *domain);
BYTE	*expand(BYTE *addr);

/*
**	Screen buffering
*/

VOID	instal_s_scr(VOID);
VOID	dump_screen(VOID);
VOID	old_screen(VOID);
VOID	switch_screens(VOID);
VOID	end_screen(VOID);

/*
**	Logfile handling functions
*/

WORD	log_open(VOID);
VOID	log_close(VOID);
VOID	log_start(BYTE *program, BYTE *function);
WORD	log_line(WORD level, BYTE *fmt, ...);
WORD	gprintf(BYTE *fmt, ...);
WORD	hprintf(BYTE to, BYTE *fmt, ...);

/*
**	File I/O routines
*/

VOID	pktwrite(BYTE *str, UWORD len, FILE *fp);
VOID	msgwrite(BYTE *str, size_t len, FILE *fp);
VOID	msgread(BYTE *str, size_t len, FILE *fp);
VOID	hdrwrite(VOID *str, size_t len, FILE *fp);
VOID	hdrread(VOID *str, size_t len, FILE *fp);

/*
**	Packet routines
*/

VOID	create_pkt_hdr(UWORD ozone, UWORD onet, UWORD onode,
			UWORD dzone, UWORD dnet, UWORD dnode, BYTE *pwd);
VOID	create_pkt_fnd(UWORD ozone, UWORD onet, UWORD onode,
			UWORD opoint, UWORD dzone, UWORD dnet, UWORD dnode,
			UWORD dpoint, BYTE *pwd);
VOID 	create_pkt_2_2(UWORD ozone, UWORD onet, UWORD onode, 
			UWORD opoint, UWORD dzone, UWORD dnet, UWORD dnode, 
			UWORD dpoint, BYTE *pwd,
			BYTE *Odomain, BYTE *Ddomain);

VOID	init_PKTS(VOID);
VOID	close_PKTS(VOID);

/*
**	Multitask routine
*/

VOID giveTIMEslice(VOID);
VOID install_gem(VOID);
VOID close_gem(VOID);

#endif
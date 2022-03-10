#if !defined (__MODULES_H__)
#define __MODULES_H__

/*
**	InMail
*/

BYTE	unpack_pkt(VOID);
VOID	import_pkt(BYTE *path);

/*
**	OutMail
*/

VOID	pack_mail(VOID);
VOID	pack_netmail(MSGHEADER *hdr, BYTE *msgtext);

/*
**	ScanMail
*/

VOID	scan_areas(VOID);
VOID	compactMSGbase(WORD mode);

/*
**	Configuration parser
*/

BOOLEAN	init_cfg(BOOLEAN *foundlabel);
BOOLEAN read_areas(BYTE *filename, BYTE what);
VOID	read_lednew(VOID);
VOID	write_lednew(VOID);
VOID	read_ioskey(VOID);

/*
**	Area consultant.
*/

VOID consult_areafix(MSGHEADER *hdr, BYTE *message);
WORD ADDarea (BYTE *area);

/*
**	Other external modules
*/

WORD	match(BYTE *first, BYTE *second);
VOID	CDECL xsprintf(BYTE *buf, BYTE *format, ...);
BOOLEAN	langload(VOID);
VOID 	addpktbuf(VOID *text, UWORD len, WORD to, BYTE what);
BYTE	DO_track (MSGHEADER *Hdr, BYTE *msg);
#endif
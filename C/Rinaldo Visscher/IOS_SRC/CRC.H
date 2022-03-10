/*
**	CRC-Routines
*/

#if !defined (__CRC_H__)
#define __CRC_H__

#define	MAILER_FIELD	0
#define	UPCOST			1

VOID reply_chain(BYTE *msgtext, MSGHEADER *msghdr, BYTE whichfields);
VOID inst_dupetrap(VOID);
VOID free_dupetrap(VOID);
BOOLEAN get_dupes(BYTE *msgtext, WORD area);

#endif
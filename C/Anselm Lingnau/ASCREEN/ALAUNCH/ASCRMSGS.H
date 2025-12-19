/* ASCRMSGS.H --- Header file for ASCREEN GEM Messages
**
** Copyright (C) 1992 by Anselm Lingnau. All rights reserved.
** You may use and distribute this file freely as long as you don't
** make any money off it or pretend that you wrote it.
**
** This file defines symbolic constants for the GEM messages that
** ASCREEN understands. In particular, these are the following:
**
** MSG_READ --- read a new DVI file
**
** Word	0:	MSG_ASCREEN	ASCREEN message follows
**	1:	<sender>	Application ID of message sender
**	2:	<oversize>
**	3:	MSG_READ	ASCREEN message subcode
**	4...	Filename
**
** The message contains the first eight characters of the file name.
** Any excess characters will have to be retrieved by another
** call to appl_read, giving the <oversize> as the length argument.
** Use something like the following fragment to construct the complete
** file name:
**
**	char name[...];
**	if (msg[0] == MSG_ASCREEN && msg[3] == MSG_READ) {
**		strcpy(name, (char *)&msg[4]);
**		if (msg[2] > 0)
**			appl_read(id, msg[2], name + 16);
**	}
**
** MSG_REREAD --- reread the current DVI file
**
** Word	0:	MSG_ASCREEN	ASCREEN message follows
**	1:	<sender>	Application ID of message sender
**	2:	0
**	3:	MSG_REREAD	ASCREEN message subcode
**	4...7	don't care
**
** This message is equivalent to the menu item of the same name.
** The DVI file being displayed is closed and re-opened. This is
** most useful if TeX has been run in-between in a multitasking
** environment.
**
** MSG_NEWPAGE --- format a page
**
** Word 0:	MSG_ASCREEN	ASCREEN message follows
**	1:	<sender>	Application ID of message sender
**	2:	0
**	3:	MSG_NEWPAGE	ASCREEN message subcode
**	4:	<page>		Number of page to be formatted
**	5...7	don't care
**
** This message instructs ASCREEN to format the page whose number
** is given in word 4. This is probably not very useful, but ASCREEN
** uses this message internally to organize cacheing-ahead of pages.
**
** MSG_NEWWIN --- open a new window
**
** Word 0:	MSG_ASCREEN	ASCREEN message follows
**	1:	<sender>	Application ID of message sender
**	2:	2
**	3:	MSG_NEWWIN	ASCREEN message subcode
**	4:	<kind>		Window kind: 1 - normal, 2 - shrink2,
**					4 - shrink3
**	5:	<page>		Page number to be displayed in window
**	6:	<x-pos>		X position of window
**	7:	<y-pos>		Y position of window
**	8:	<width>		Width of window
**	9:	<height>	Height of window
**
** This message opens a window of kind <kind> on page <page> of the
** document. The window is positioned at (<x-pos>, <y-pos>) with
** dimensions <width> and <height>.
*/
#if !ASCRMSGS_H
#define ASCRMSGS_H	1

/* Message numbers. msg[0] is always MSG_ASCREEN with subcode in msg[3] */

#define	MSG_ASCREEN	0x2004	/* 8196, hopefully otherwise unused */
#define MSG_READ	0x0000	/* Read DVI file, name follows */
#define MSG_REREAD	0x0001	/* Reread DVI file */
#define MSG_NEWPAGE	0x0002	/* Format new page */
#define MSG_NEWWIN	0x0003	/* Open new window */

#endif /* ASCRMSGS_H */

/*********************************************************************

					IOS - lib routines
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991

	Misc. routines.
**********************************************************************/

#include		<stdio.h>
#include		<stdlib.h>
#include		<stdarg.h>
#include		<aes.h>
#include		<vdi.h>
#if defined LATTICE
#include		<sys/stat.h>
#include		<dos.h>
#else
#include		<ext.h>
#include		<tos.h>
#endif
#include		<string.h>
#include		<time.h>
#include		<ctype.h>
#include		<errno.h>

#include		"portab.h"
#include		"defs.h"
#include		"ioslib.h"
#include		"crc.h"

#include		"inmail.h"
#include		"strutil.h"
#include		"modules.h"
#include		"lang.h"

#include		"vars.h"

#include		"compiler.h"

VOID freepktbuf(VOID);
VOID freemsgbuf(VOID);
VOID checkABC(VOID);

MLOCAL BYTE		*chars = "zCoHaJSu0.EikMm1BFchN4A tLvU3beInq29QGjyD5d6WTswlRg7PZfrxVp8YKOX";
MLOCAL FILE		*LOG;
MLOCAL BOOLEAN 	isABCnode;
MLOCAL BYTE		blink = 0;
MLOCAL BYTE		bcount=0;

MLOCAL CONST BYTE	*werr[] = {	"Ok, no error",
								"File permission denied",
								"File not found",
								"----",
								"----",
								"General I/O error",
								"----",
								"----",
								"----",
								"Invalid file handle",
								"Illegal file specification",
								"Invalid heap block",
								"Heap overflow",
								"File access mode error",
								"----",
								"----",
								"----",
								"File exists",
								"Program load format",
								"Device error",
								"Path not found",		/*	20	*/
								"----",
								"Invalid parameter",
								"File table overflow",
								"Too many files open",
								"----",
								"----",
								"----",
								"Disk full",
								"Seek error",
								"Read only device",		/*	30	*/
								"----",
								"----",
								"Domain error",
								"Range error",
								"No more matching files" };

EXTERN CONST BYTE *Copyright;

VOID terminate(WORD elevel)
{
	WORD	i;

	if (MTask == MULTIGEM) close_gem();
	
	for (i=0; i < LAST_MESSAGE; i++) free (Logmessage[i]);
	
	if (maxPRD)
		for (i = 0; i < maxPRD; i++) free (PRDcode[i]);
	
	for (i=0; i < msgareas; i++)
	{
		free(Areaname[i]);
		free(Areaorg[i]);
		free(Areapath[i]);
		if (Randorgfile[i])
			free(Randorgfile[i]);
		free(Tozone[i]);
		free(Tonet[i]);
		free(Tonode[i]);
		free(Topoint[i]);
		if (ROnode[i] != NULL) free (ROnode[i]);
	}

	for(i=0 ; i < ncopyareas ; i++) {
		free(Copyarea[i]);
		free(Destarea[i]);
		free(Copylegal[i]);
	}
	
	for (i=0; i < nnodelist; i++) {
		free (NODElist[i]);
	}
	
	for (i=0; i < nfdbase; i++) free(ToBase[i]);
	
	for (i=0; i < nled; i++) free(Lareaname[i]);
	
	for(i=0; i < nkill; i++) free(Killfrom[i]);

	free_dupetrap();
		
	if (strlen(FDbase))		free(FDbase);
	if (strlen(mailarea))	free(mailarea);
	if (strlen(pkt_temp))	free(pkt_temp);
	if (strlen(trasharea))	free(trasharea);
	if (strlen(privatebox))	free(privatebox);
	if (strlen(dupearea))	free(dupearea);
	if (strlen(mailtemp))	free(mailtemp);
	if (strlen(outbound))	free(outbound);
	
	if (doimport)
		if (strlen(inbound))	free(inbound);
	
	if (strlen(Arch))		free(Arch);
	if (strlen(Archcmdi))	free(Archcmdi);
	if (strlen(Archcmdo))	free(Archcmdo);
	if (strlen(Qbbslr))		free(Qbbslr);
	if (strlen(Envpath))	free(Envpath);
	if (strlen(logfile))	free(logfile);
	
	if (strlen(Lzh)) 		free(Lzh);
	if (strlen(Zip))		free(Zip);
	if (strlen(Arc))		free(Arc);
	if (strlen(Arj))		free(Arj);
	
	if (strlen(LzheC))		free(LzheC);
	if (strlen(ZipeC))		free(ZipeC);
	if (strlen(ArceC))		free(ArceC);
	if (strlen(ArjeC))		free(ArjeC);
	
	if (strlen(LzheA))		free(LzheA);
	if (strlen(ZipeA))		free(ZipeA);
	if (strlen(ArceA))		free(ArceA);
	if (strlen(ArjeA))		free(ArjeA);
	if (strlen(TRACKmsg))	free(TRACKmsg);
	
	if (strlen(Mainorg))	free(Mainorg);
	
	if(Areafix != NULL) {
		if (strlen(Areafix)) 	free(Areafix);
		if (strlen(Areafixcmd)) free(Areafixcmd);
	}
	
	log_close();
	
	if (dowait)
	{
		if (MTask == MULTIGEM) {
			v_curtext(vdi_handle,"\r\n--- Press KEY ---");
			evnt_keybd();
		}
		else {
			printf("\n--- \033pPress RETURN\033q ---");
			getchar();
		}
	}
	
	exit(elevel);
}

VOID w_error(BYTE *where)
{
	log_line(6,Logmessage[M__WRITE_ERROR], errno,
		(errno <= ERANGE) ? werr[errno] : "Unknown", where);
	
	terminate(10);
}

VOID *myalloc(size_t sp)
{
	BYTE	*tmp = malloc(sp);

#if defined EXTERNDEBUG
	if (debugflag) {
		log_line(6, ">%ld memory allocated", sp);
	}
#endif

	if (!tmp)
	{
		log_line(6,Logmessage[M__MEMORY_ERROR]);
#if defined DEBUG
		log_line(6,"?Memory allocation failed.");
#endif
		terminate(-39);
	}
	
	return(tmp);
}

BOOLEAN area_changed(WORD area)
{
	/*
	**	Returns TRUE if area was changed and resets the archive
	**	bit according to the TOS version
	*/
	
	BYTE	buffer[128];
	WORD	attr;
	
	sprintf(buffer, "%s.HDR", Areapath[area]);
	
	attr = Fattrib(buffer, 0, -1);
	giveTIMEslice();

	if (attr != -33 && attr != -34 && attr & FA_ARCHIVE)
	{
		if (intel(Sversion()) >= 0x0015U)
			Fattrib(buffer, 1, 0);
		else
			Fattrib(buffer, 1, FA_ARCHIVE);
		
		return(TRUE);
	}
	
	return(FALSE);
}

WORD to_area(BYTE *msgtext)
{
	/*
	**	Returns the area number to which a PrivateBox message
	**	is destinated. If Netmail, it returns (-2)
	**
	**	If no AREA-Tag found, it returns (-1)
	*/
	
	BYTE	*p, *q, *z,
			temp[80];
	WORD	i;
	
	if ((p = strstr(msgtext, "\03AREA [")) == NULL)
	{
		log_line(3,Logmessage[M__NO_AREALINE]);
		return (-1);
	}
	
	z = p;
	
	while (*p != '[') p++;
	p++;
	
	for(q = temp; *p && *p != ']'; *q++ = *p++);
	*q = EOS;
	
	p = skip_to_blank(p);
	strcpy(z, p);
	
	for(i=0; i < msgareas; i++)
		if (!stricmp(temp, Areaname[i])) return(i);
	
	if (!strcmp(temp, "MAIL")) return(-2);
	
	return(-1);
}

MLOCAL VOID swap_node(WORD first, WORD last)
{
	UWORD	h1, h2, h3, h4;
	
	h1 = Tz[first];
	h2 = Tnt[first];
	h3 = Tne[first];
	h4 = Tp[first];
	
	Tz[first] = Tz[last];
	Tnt[first] = Tnt[last];
	Tne[first] = Tne[last];
	Tp[first] = Tp[last];
	
	Tz[last] = h1;
	Tnt[last] = h2;
	Tne[last] = h3;
	Tp[last] = h4;
}

VOID sort_connected(WORD count, WORD start)
{
	WORD	i,
			j;
	
	--count;
	
	if (count-1 <= 1) return;
	
	for (i = start; Tz[i] != (UWORD)(-1); i++)
	{
		for (j = i+1; Tz[j] != (UWORD)(-1); j++)
		{
			if (Tz[i] > Tz[j])
			{
				swap_node(i, j);
				continue;
			}
			
			if (Tz[i] == Tz[j] && Tnt[i] > Tnt[j])
			{
				swap_node(i, j);
				continue;
			}
			
			if (Tz[i] == Tz[j] && Tnt[i] == Tnt[j] && Tne[i] > Tne[j])
			{
				swap_node(i,j);
				continue;
			}
			
			if (Tz[i] == Tz[j] && Tnt[i] == Tnt[j] && Tne[i] == Tne[j] && Tp[i] > Tp[j])
				swap_node(i, j);
		}
	}
}

BYTE *Remove_and_Add(BYTE *string, BYTE *msg) {
	BYTE *rem,
		 *p,
		 line[100];
	
	strcpy (line, string);
	
	if (strstr(msg, line) != NULL) return (msg);
	
	msg = strip_line(msg, line);
	strcpy (line, " ");
	strcat (line, string);
	msg = strip_line(msg,line);
	
	if ((p = strline(msg, "\01REPLY:")) == NULL &&
		(p = strline(msg, "\01MSGID:")) == NULL) {
		msg = add_a_line(string, G_VERSION, msg);
		return (msg);
	}
	
	p = skip_to_token (p, '\n');
	
	if (!*p) return (msg);
	
	rem = (BYTE *)myalloc(strlen(p) + 2);
	
	strcpy (rem, p);
	
	strcpy (p, string);
	strcat (p, G_VERSION);
	strcat (p, "\n");
	strcat (p, rem);
	
	free (rem);
	
	return (msg);
}

BYTE *change_msgid(BYTE *msgtext, MSGHEADER *hdr)
{
	/*
	**	Changes the MSGID kludge to the address given in the
	**	message header.
	*/
	
	BYTE	*temp, *p, s,
	/*
			*p = strline(msgtext, "\01MSGID:"),
	*/
			bf[30],
			tmp[40];

	WORD 	i;
	ULONG	j;
	
/*		
	p = skip_to_token(p, '\n') - 2;
	while (!isspace(*p) && *p) --p;
	
	if(*p)
	{
		p = skip_blanks(p);
		for (temp = bf; *p && !isspace(*p); *temp++ = *p++);
		*temp = EOS;
	}
	else
	{
		log_line(3,Logmessage[M__ILLEGAL_MSGID]);
		return(msgtext);
	}

*/	
	j = Random();
	s = (BYTE) Random();
	
	sprintf (bf, "%02x%06lx" ,s ,j);
	
	msgtext = strip_line(msgtext, "\01MSGID:");
	
	p = (BYTE *) myalloc(MAXMSGLENGTH);
	sprintf(p, "\01MSGID: %u:%u/%u ", hdr->Ozone, hdr->Onet, hdr->Onode);
	
	if (hdr->Opoint && !Npoint) {
		sprintf(&p[strlen(p)-1], ".%u ", hdr->Opoint);
	} else {
		for (i=0; i < Npoint; i++) {
			if (hdr->Ozone == Zpoint[i]) {
				break;
			}
		}
		if (i >= Npoint && hdr->Opoint) {
			sprintf(&p[strlen(p)-1], ".%u ", hdr->Opoint);
		}
	}
	
	if (!strlen (org_domain)) {
		for (i=0; i < domain; i++) {
			if (Appl[i].zone == hdr->Ozone) {
				if (strlen(Appl[i].domain)) {
					strncpy(tmp, Appl[i].domain, 39);
					if ((temp = strchr(tmp, '.')) != NULL) *temp = EOS;
					sprintf(&p[strlen(p)-1], "@%s ", tmp);
				}
				break;
			}
		}
	} else {
		sprintf (&p[strlen(p)-1], "@%s ", org_domain);
	}
	
	sprintf(&p[strlen(p)], "%s\n", bf);
	
	strcat(p, msgtext);
	strcpy(msgtext, p);
	free(p);
	return(msgtext);
}

BYTE *add_a_line(BYTE *line, BYTE *addline, BYTE *msgtext)
{
	/*
	**	Adds a line to the top of the message if such a line
	**	is not already in the message text.
	*/
	
	BYTE	*p;
	
	if (strline(msgtext, line)) return(msgtext);
	
	if ((UWORD)(strlen(msgtext) + strlen(line) + strlen(addline)) >= MAXMSGLENGTH)
	{
		log_line(6,Logmessage[M__MSG_TO_BIG_TO_ADD], line);
		return(msgtext);
	}
	
	p = (BYTE *) myalloc(MAXMSGLENGTH);
	
	sprintf(p, "%s %s\n", line, addline);
	strcpy(&p[strlen(p)], msgtext);
	
	strcpy(msgtext, p);
	free(p);
	
	return(msgtext);
}

BOOLEAN add_point(BYTE *msgtext, MSGHEADER *hdr)
{
	WORD	i;
	BYTE	done_fmpt = FALSE,
			done_topt = FALSE,
			done_intl = FALSE;
	
	for (i = 0; i < nkey; i++)
	{
		if (hdr->Dzone == pwd[i].zone && hdr->Dnet == pwd[i].net &&
			hdr->Dnode == pwd[i].node && hdr->Dpoint == pwd[i].point)
		{
			if (pwd[i].mtype == TYPE4d)
			{
				sprintf(&msgtext[strlen(msgtext)], "\01INTL %u:%u/%u %u:%u/%u\n",
					hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Ozone,
					hdr->Onet,hdr->Onode);
				
				done_intl++;
				
				if (hdr->Dpoint)
				{
					sprintf(&msgtext[strlen(msgtext)], "\01TOPT %u\n", hdr->Dpoint);
					done_topt++;
				}
				else
					if (hdr->Opoint)
					{
						sprintf(&msgtext[strlen(msgtext)], "\01FMPT %u\n", hdr->Opoint);
						done_fmpt++;
					}
			}
			
			break;
		}
	}
	
#if defined EXTERNDEBUG
	if (debugflag)
	{
		log_line(6,">Add kludged INTL etc. :");
		log_line(6,">TOPT = %s", (done_topt) ? "Added" :"None");
		log_line(6,">FMPT = %s", (done_fmpt) ? "Added" :"None");
		log_line(6,">INTL = %s", (done_intl) ? "Added" :"None");
	}
#endif
	
	return((done_topt+done_fmpt+done_intl) ? TRUE : FALSE);
}

BYTE *strline(BYTE *msgtext, BYTE *line)
{
	while (*msgtext)
	{
		if (!strncmp(msgtext, line, (WORD)strlen(line)))
			return(msgtext);
		
		msgtext = skip_to_token(msgtext, '\n');
		if (!*msgtext) break;
	}
	
	return(NULL);
}

BYTE *strip_those_lines(BYTE *msgtext, BYTE *line)
{
	while (strline(msgtext, line) != NULL)
		msgtext = strip_line(msgtext, line);
	
	return(msgtext);
}

WORD ARCtype(BYTE *ARCfile)
{
	/*
	**	wwwMail: v.pomey 27 july 90
	**	public domain - whatarc like
	*/
	
	WORD	amail;
	UBYTE	c[4];
	
	amail = Fopen(ARCfile, FO_READ);
	
	if (amail < 0)
	{
		log_line(6,Logmessage[M__CANT_OPEN], ARCfile);
		return(isUNKNOWN);
	}
	
	Fread(amail, 4L, c);
	Fclose(amail);
	
	giveTIMEslice();
	
	if (*c == 'P' && c[1] == 'K')	return(isZIPmail);
	if (*c == 0x1a)					return(isARCmail);
	if (c[2] == '-' && c[3] == 'l')	return(isLZHmail);
	if (*c == 0x60 && c[1] == 0xea)	return(isARJmail);
	
	return(isUNKNOWN);
}

MLOCAL VOID rollchars(VOID)
{
	BYTE	charbuf = *chars;
	
	memcpy(chars, chars+1L, 63L);
	chars[63] = charbuf;
}

/*
VOID decrypt(IOSKEY *key)
{
	WORD	i, j;
	
	key->year ^= DATE_XOR;
	key->day ^= DATE_XOR;
	key->month ^= DATE_XOR;
	
	key->start ^= START_XOR;
	key->type  ^= KTYPE_XOR;
	IOSKEY_zone = key->zone ^ START_XOR;
	
	while (*chars != key->start) rollchars();
	
	for (i=0; i < 36; i++)
	{
		key->name[i] ^= NAME_XOR;
		
		if (key->name[i] == -1)
		{
			key->name[i] = EOS;
			break;
		}
		
		for (j=0; j < key->name[i]; j++) rollchars();
		
		key->name[i] = *chars;
	}
}
*/

UWORD intel(UWORD x)
{
	return( ((x << 8) & 0xFF00) | ((x >> 8) & 0x00FF) );
}

MLOCAL UWORD ztoi(BYTE *str, WORD len)
{
	UWORD	temp = 0;
	
	while (*str && len-- && isalnum(*str))
	{
		temp *= 36;
		temp += isdigit(*str) ? *str-'0' : toupper(*str)-'A'+10;
		str++;
	}
	
	return(temp);
}

VOID getTBaddress(BYTE *str, UWORD *zone, UWORD *net, UWORD *node)
{
	*zone = ztoi(str, 2);
	*net = ztoi(str+2, 3);
	*node = ztoi(str+5, 3);
}

VOID getBTaddress(BYTE *str, UWORD *net, UWORD *node, UWORD *point)
{
	*net = ztoi(str, 3);
	*node = ztoi(str+3, 3);
	*point = ztoi(str+6, 2);
}

VOID get4Daddress(BYTE *str, UWORD *zone, UWORD *net, UWORD *node, UWORD *point)
{
	*zone = ztoi(str, 2);
	*net = ztoi(str+2, 3);
	*node = ztoi(str+5, 3);
	*point = ztoi(str+9, 2);
}

BYTE *expand(BYTE *addr)
{
	LOCAL BYTE	dest[128];
	/*BYTE		zone[6],
				net[6],
				node[6],
				point[6],
				*p = addr;*/
	WORD		usealias = 0;
	
	
	memset(dest, 0, 128L);
	
	if (addr[strlen(addr)-1] == '*')
	{
		strcpy(dest, addr);
		return(dest);
	}
	
	if (!strchr(addr, ':'))
		sprintf(dest, "%u:", alias[0].zone);
	else
	{
		strcpy(dest, addr);
		if (!strchr(dest, '.')) strcat(dest, ".0");
		
		return(dest);
	}
	
	if (!strchr(addr, '/'))
		sprintf(dest+strlen(dest), "%u/", alias[usealias].net);
	else
	{
		strcat(dest, addr);
		if (!strchr(dest, '.')) strcat(dest, ".0");
		return(dest);
	}
	
	if (!strchr(addr, '.'))
	{
		strcat(dest, addr);
		strcat(dest, ".0");
		return(dest);
	}
	else if (*addr == '.')
		sprintf(dest+strlen(dest), "%u", alias[usealias].node);
	
	strcat(dest, addr);
	
	return(dest);
}

BYTE *address(BYTE *s, UWORD *zone, UWORD *net, UWORD *node,
				UWORD *point, UWORD *pnet, BYTE *domain)
{
	BYTE			*p = s,
					n[9],
					have = 0;
	WORD			i = 0;
	
	if (!s) return(NULL);
	
	domain [0] = '\0';
	
	/*
	**	First, give them all our numbers, if it's only .XX
	*/
	
	*zone = alias[0].zone;
	*net = alias[0].net;
	*node = alias[0].node;
	*point = 0;
	*pnet = alias[0].pointnet;
	
	if (*p == '.')		/* if it's a point */
	{
		*point = atoi(++p);
		return(domain);
	}
	
	do
	{
		while (*p != ':' && *p != '/' && *p != '.' && *p != EOS &&
				*p != ' ' && *p != '\t' && *p !='@') n[i++] = *p++;
		
		n[i] = EOS;
		
		if (!strlen(n))
		{
			if (*p == EOS) return (p);
			log_line(6,Logmessage[M__CONFIG_ERROR_ADRES], s);
			p = skip_blanks(++p);
			continue;
		}
		
		if (!isdigit (n[0])) {
			log_line(6,Logmessage[M__CONFIG_ERROR_ADRES], s);
			return (domain);
		}
		
		if (!have && *p == ':')
			*zone = atoi(n);
		else if (have == 1 || *p == '/')
		{
			*net = atoi(n);
			have = 1;
		}
		else if (have == 2) *node = atoi(n);
		else if (have == 3) *point = atoi(n);
		else if (have == 4) *pnet = atoi(n);
		
		have++;
		
		if (*p == EOS) return(NULL);
				
		if (*p == '@') {
			i = 0;
			++p;
			do {
				if (*p == '.') break;
				domain[i++] = *p++;
				if (*p == EOS || *p == ' ') break;
			} while (i < 10);
			domain [i] = EOS;
			
			if (*p != ' ') p = skip_to_blank (p);
			p = skip_blanks (p);
			if (*p == EOS) return (NULL);
			else {
				i = 0;
				continue;
			}
		} 
		
		p = skip_blanks(++p);
		
		i = 0;
		
	} while (*p != '\r', have < 5);
	
	return(domain);
}

/*
**	Screen buffering
*/

VOID instal_s_scr(VOID)
{
	BYTE	*help;
	size_t	size;
	
	size = (size_t)_screen * 1024L;
	help = (BYTE *) myalloc(size);
	
	oldestscr = scr1 = (LONG *) Physbase();
	scr2 = (LONG *)((LONG) help + (512L - (LONG) help%512));
	switch_it = (LONG)scr1 ^ (LONG)scr2;
}

VOID dump_screen(VOID)
{
	WORD	i;
	LONG	*dump_scr = scr2,
			*old_scr = scr1;
	
	for (i=0; i < 8000; i++) *dump_scr++ = *old_scr++;
}

VOID old_screen(VOID)
{
	WORD	i;
	LONG	*dump_scr = scr2,
			*old_scr = scr1;
	
	for (i=0; i < 8000; i++) *old_scr = *dump_scr++;
}

VOID switch_screens(VOID)
{
	scr1 = (LONG *) ((LONG)scr1 ^ switch_it);
	scr2 = (LONG *) ((LONG)scr2 ^ switch_it);
	/*Setscreen(scr2, scr1, -1);*/
}

VOID end_screen(VOID)
{
	Setscreen(oldestscr, oldestscr, -1);
}

/*
**	Logfile
*/

WORD log_open(VOID)
{
	if (dolog)
		return(((LOG = fopen(logfile, "a")) != NULL) ? SUCCESS : FAILURE);
	else
		return(SUCCESS);
}

VOID log_close(VOID)
{
	if (LOG)
	{
		fputs("\n", LOG);
		fclose(LOG);
	}
	
	LOG = NULL;
}

VOID log_start(BYTE *program, BYTE *function)
{
	BYTE		startline[128];
	time_t		unixtime;
	struct tm	*tmptr;
	
	time(&unixtime);
	tmptr = localtime(&unixtime);
	if (strlen(Dateformat)) {
		strftime(startline, 127L, Dateformat, tmptr);
		strcat(startline, " IOS  ");
		strcat(startline, program);
	} else {
		strcpy (startline, program);
	}
	
	if (function)
	{
		strcat(startline, " execute ");
		strcat(startline, function);
	}
	
	strcat(startline, "\n");
	
	if (dolog) {
		fputs("\n# ", LOG);
		fputs(startline, LOG);
	}
}

WORD log_line(WORD level,BYTE *fmt, ...)
{
	BYTE		line[256],
				timestring[40],
				buffer[250];
				
	WORD		cnt = 0,
				i;
	time_t		unixtime;
	struct tm	*tmptr;
	va_list		argptr;
	
	
	va_start(argptr, fmt);
	
	time(&unixtime);
	tmptr = localtime(&unixtime);
	
	if (strlen(Dateformat))
		strftime(timestring, 40, Dateformat, tmptr);
	else timestring[0] = EOS;
	
	cnt += vsprintf(line, &fmt[1], argptr);
	
	if (dolog && strchr(logtypes, *fmt) && LOG && level >= loglevel)
	{
#if defined CONF_COMPILER
		fprintf(LOG,"%c %s CCM  %s\n",*fmt,timestring,line);
#else	
		if (strlen(Dateformat))			
			fprintf(LOG,"%c %s IOS  %s\n",*fmt,timestring,line);
		else
			fprintf(LOG,"%c %s\n",*fmt,line);
#endif		
		if ((i = ferror(LOG)) != 0)
		{
			fclose(LOG);
			LOG = NULL;
			cnt += printf ("Write error %d while writing LOG. Log closed.\n", i);
			if (i == -1) {
				cnt += printf ("Disk FULL");
				terminate (10);
			}
			dolog = 0;
		} else {
			fflush(LOG);
		}
	}
	
	giveTIMEslice();
	
	if (strchr(disptypes, fmt[0]))
		if (!doquit)
#if defined CONF_COMP
			cnt += printf("%c %s CCM  %s\n",*fmt,timestring,line);
#else
			if (MTask != MULTIGEM) {
				LOG_line ++;
				
				if (LOG_line >= 23) {
					LOG_line = 22;
					printf ("\033Y%c%c\033M", 7+' ', 0+' ');
				}
				printf ("\033Y%c%c", LOG_line+' ', 0+' ');
				
				if (strlen(Dateformat)) 
					cnt += printf("%c %s IOS  %s",*fmt,timestring,line);
				else
					cnt += printf("%c %s",*fmt,line);
			} else {
				if (strlen(Dateformat))
					cnt += sprintf(buffer, "%c %s IOS  %s\n\r",*fmt,timestring,line);
				else
					cnt += sprintf(buffer, "%c %s\n\r",*fmt,line);
				
				v_curtext(vdi_handle, buffer);
			}
#endif
	
	va_end(argptr);
	
	return(cnt);
}

/*
**	File I/O routines
*/

VOID pktwrite(BYTE *str, UWORD len, FILE *fp)
{
	while (len--)
	{
		if (*str == '\n') putc('\r',fp);
		else putc(*str, fp);
		
		if (ferror(fp)) w_error("writing packet");
		
		str++;
	}
	
	putc(0, fp);
	
	giveTIMEslice();
	
	fflush(fp);
	
	if (ferror(fp)) w_error("writing packet");
}

VOID msgwrite(BYTE *str, size_t len, FILE *fp)
{
	while (len--)
	{
		putc(*str,fp);
		
		if (ferror(fp)) w_error("writing message");
		
		str++;
	}
	
	fflush(fp);
	
	giveTIMEslice();
	
	if (ferror(fp)) w_error("writing message");
}

VOID msgread(BYTE *str, size_t len, FILE *fp)
{
	BYTE	*p = str;
	
	while (len--) *p++ = (BYTE)getc(fp);
	
	*p = EOS;
	giveTIMEslice();
}

VOID hdrwrite(VOID *str, size_t len, FILE *fp)
{
	BYTE	*p = (BYTE *)str;
	
	while (len--)
	{
		putc(*p,fp);
		if (ferror(fp)) w_error("writing header");
		p++;
	}
	
	fflush(fp);
	
	giveTIMEslice();
	
	if (ferror(fp)) w_error("writing header");
}

VOID hdrread(VOID *str, size_t len, FILE *fp)
{
	BYTE	*p = (BYTE *)str;
	
	while (len--) *p++ = (BYTE)getc(fp);
	
	giveTIMEslice();
}

/*
**	Get used product code for the packetheader.
*/

UBYTE Get_Code (UWORD zone, UWORD net, UWORD node, UWORD point)
{
	WORD i;
	
	if (point == (UWORD) -1) {
		for (i = 0; i < nalias; i++) {
			if (net == alias[i].pointnet) break;
		}
		if (i >= nalias)
			return (IOSPRDCODE);
		
		net = alias[i].net;
		point = node;
		node = alias[i].node;
	}
	
	for (i= 0 ; i < nkey; i++) {
		if (zone == pwd[i].zone && net == pwd[i].net &&
			node == pwd[i].node && point==pwd[i].point &&
			!strnicmp (pwd[i].Domain, dest_domain, 8)) {
			
			if (pwd[i]. TosScan == TRUE)
				return (TOSSCANPRD);
			
			break;
		}
	}
	
	return (IOSPRDCODE);
}

/*
**	Packet header creation routines
*/

VOID create_pkt_hdr(UWORD ozone, UWORD onet, UWORD onode, UWORD dzone, UWORD dnet, UWORD dnode, BYTE *pwd)
{
	UBYTE			PrdCode;
	
	struct date		d;
	struct time		t;
	
	getdate(&d);
	gettime(&t);
	
	PrdCode = Get_Code(dzone, dnet, dnode, -1);
	
	memset(&phdr, 0, sizeof(struct _pkthdr));
	
	phdr.ph_ozone = intel(ozone);
	phdr.ph_onet = intel(onet);
	phdr.ph_onode = intel(onode);
	
	phdr.ph_dzone = intel(dzone);
	phdr.ph_dnet = intel(dnet);
	phdr.ph_dnode = intel(dnode);
	
	strcpy(phdr.ph_pwd, pwd);
	
#if defined EXTERNDEBUG
	if (debugflag)
	{
		log_line(6,">Packet header :");
		log_line(6,">Origin %u:%u/%u -> %u:%u/%u", ozone, onet, onode, dzone, dnet, dnode);
	}
#endif
	
	phdr.ph_ver = intel(2);
	
	phdr.ph_capable = 0;				/*	Stone-Age	*/
	phdr.ph_CWcopy = 0;
	
	phdr.ph_prod = PrdCode;
	
	phdr.ph_yr = intel(d.da_year);
	phdr.ph_mo = intel(d.da_mon - 1);
	phdr.ph_dy = intel(d.da_day);
	
	phdr.ph_hr = intel(t.ti_hour);
	phdr.ph_mn = intel(t.ti_min);
	phdr.ph_sc = intel(t.ti_sec);
}

VOID create_pkt_fnd(UWORD ozone, UWORD onet, UWORD onode, UWORD opoint, UWORD dzone, UWORD dnet, UWORD dnode, UWORD dpoint, BYTE *pwd)
{
	UBYTE			PrdCode;
	
	struct date		d;
	struct time		t;
	
	getdate(&d);
	gettime(&t);
	
	PrdCode = Get_Code(dzone, dnet, dnode, dpoint);
	
	memset(&phdr, 0, sizeof(struct _pkthdr));
	
	phdr.ph_ozone = phdr.ph_qozone = intel(ozone);
	phdr.ph_onet = intel(onet);
	phdr.ph_onode = intel(onode);
	phdr.ph_opoint = intel(opoint);
	
	/*if (opoint)
	{
		phdr.ph_auxnet = phdr.ph_onet;
		phdr.ph_onet = intel((UWORD)(-1));
	}*/
	
	phdr.ph_dzone = phdr.ph_qdzone = intel(dzone);
	phdr.ph_dnet = intel(dnet);
	phdr.ph_dnode = intel(dnode);
	phdr.ph_dpoint = intel(dpoint);
	
	strcpy(phdr.ph_pwd, pwd);
	
	phdr.ph_ver = intel(2);
	
	phdr.ph_capable = intel(1);			/*	Type 2+	*/
	phdr.ph_CWcopy = 1;
	
	phdr.ph_prod = PrdCode;
	phdr.ph_rev = IOSMINOR;
	phdr.ph_revMin = IOSPKTVERS;
	
	phdr.ph_yr = intel(d.da_year);
	phdr.ph_mo = intel(d.da_mon - 1);
	phdr.ph_dy = intel(d.da_day);
	
	phdr.ph_hr = intel(t.ti_hour);
	phdr.ph_mn = intel(t.ti_min);
	phdr.ph_sc = intel(t.ti_sec);
}

VOID create_pkt_2_2(UWORD ozone, UWORD onet, UWORD onode, 
	UWORD opoint, UWORD dzone, UWORD dnet, UWORD dnode, 
	UWORD dpoint, BYTE *pwd, BYTE *Odomain, BYTE *Ddomain)
{
	WORD 		i;
	BYTE 		temp[20], *q;
	UBYTE		PrdCode;
	
	memset(&phdr2, 0, sizeof(struct _phdr2));

	strncpy(phdr2.ph_odomain, Odomain, 8);

	strncpy(phdr2.ph_ddomain, Ddomain, 8);
	
	PrdCode = Get_Code(dzone, dnet, dnode, dpoint);
	
	phdr2.ph_ozone = intel(ozone);
	phdr2.ph_onet = intel(onet);
	phdr2.ph_onode = intel(onode);
	phdr2.ph_opoint = intel(opoint);
	
	phdr2.ph_dzone = intel(dzone);
	phdr2.ph_dnet = intel(dnet);
	phdr2.ph_dnode = intel(dnode);
	phdr2.ph_dpoint = intel(dpoint);
	
	strcpy(phdr2.ph_pwd, pwd);
	
	phdr2.ph_ver = intel(2);
	
	phdr2.ph_sub = intel(2);			/*	Type 2.2	*/
	
	phdr2.ph_prod = PrdCode;
	phdr2.ph_rev = IOSPKTVERS;
	
	phdr2.ph_spec_data[1] = IOSMINOR;
	phdr2.ph_spec_data[2] = IOSPRDCODE;
	
	memcpy(&phdr, &phdr2, sizeof(struct _phdr2));
}

VOID init_PKTS(VOID)
{
	WORD	i;
	
	memset(&PKTzone, 0, N_MAXPKT * 2);
	memset(&PKTnet, 0, N_MAXPKT * 2);
	memset(&PKTnode, 0, N_MAXPKT * 2);
	memset(&PKTpoint, 0, N_MAXPKT * 2);
	
	/*
	**	Netmail area
	*/
	
	MMSG = NULL;
	MHDR = NULL;
	
	for (i=0; i < N_MAXPKT; i++) PKTchannel[i] = FILEclosed;
		
	for (i=0; i < N_MAXAREA; i++)
	{
		/*
		**	Local msgbase
		*/
		
		LMSGfile[i] = FILEclosed;
		LHDRfile[i] = FILEclosed;
		lastareawritten[i] = -1;
	}
	
	/*
	**	Trasharea
	*/
	
	MSGMSG = NULL;
	MSGHDR = NULL;
}

VOID close_PKTS(VOID)
{
	WORD	i, attr;
	BYTE	fbuf[128];
	UWORD	TO_AREAS, TO_PKTS;
	
	if (MMSG) fclose(MMSG);
	if (MHDR) fclose(MHDR);
	
	giveTIMEslice();
	
	if (MSGMSG) fclose(MSGMSG);
	if (MSGHDR) fclose(MSGHDR);
	
	giveTIMEslice();

	if (MTask == MULTITOS) {
		TO_PKTS = (UWORD) Files_to_open / 3;
		if (TO_PKTS > N_MAXPKT) TO_PKTS = N_MAXPKT;
		if (dofastimport == TRUE) TO_PKTS = N_PKTFILE / 2;
	} else {
		if (dofastimport) 
			TO_PKTS = N_PKTFILE / 2;
		else
			TO_PKTS = N_PKTFILE;
	}
	
	for (i=0; i < TO_PKTS; i++)
		if (PKTchannel[i] == FILEopen)
		{
			putc(0, PKTfile[i]);
			putc(0, PKTfile[i]);
			
			fclose(PKTfile[i]);
			giveTIMEslice();
		}
	
	if (MTask == MULTITOS) {
		TO_AREAS = (UWORD)Files_to_open / 5;
		if (TO_AREAS > N_MAXAREA) TO_AREAS = N_MAXAREA;
	}
	else
		TO_AREAS = N_AREAFILE;

	if (dofastimport == TRUE) {
		freemsgbuf();
		for (i = 0; i < N_FASTAREAS; i++) {
			lastareawritten[i] = -1;
		
			LHDRfile[i] = FILEclosed;
			LMSGfile[i] = FILEclosed;
		}
		
	} else {			
		for (i=0; i < TO_AREAS; i++)
		{
			if (LHDRfile[i] == FILEopen) fclose(LHDR[i]);
			giveTIMEslice();
			if (LMSGfile[i] == FILEopen) fclose(LMSG[i]);
			giveTIMEslice();
			
			if (LHDRfile[i] == FILEopen)
			{
				sprintf(fbuf, "%s.HDR", Areapath[lastareawritten[i]]);
				attr = Fattrib(fbuf, 0, -1);
				if (attr != -33 && attr != -34 && attr & FA_ARCHIVE)
				{
					if (intel(Sversion()) >= 0x0015U)
						Fattrib(fbuf, 1, 0);
					else
						Fattrib(fbuf, 1, FA_ARCHIVE);
				}
			}
			
			lastareawritten[i] = -1;
			
			LHDRfile[i] = FILEclosed;
			LMSGfile[i] = FILEclosed;
		}
	}
}


BOOLEAN Not_allowed(BYTE *msgtext, WORD area) {
	WORD i;
	UWORD zone, net, node, point;
	BYTE Node[40];
	
	i = get_msgid(msgtext, &zone, &net, &node, &point);
	sprintf(Node, "%u:%u/%u.%u", zone, net, node ,point);
	if (i && newmatch(Node, ROnode[area] )) return (TRUE);

	return (FALSE);
}

VOID giveTIMEslice() {
	
	switch (MTask) {
		case MULTIGEM:
			evnt_timer(0, 0);
		break;
	}
/*	
	if (registered == UNR_VERS) {
		if (bcount ++ >= 10) {
			if (blink) {
				printf("\033Y%c%c\033pRegister for Hfl 25-,\033q", 4+' ', 40+' ');
				blink = 0;
			} else {
				printf("\033Y%c%cRegister for Hfl 25-,", 4+' ', 40+' ');
				blink = 1;
			}
			bcount =0;
		}
		delay (3);
	}
*/

}

VOID install_gem () {
	WORD i;
	
	appl_init();
	
    for ( i = 1; i < 10; work_in[i++] = 1 ) {
	    work_in[10] = 2;
     	v_handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );
      	work_in[0]  = vdi_handle = v_handle;

      	v_opnvwk( work_in, &vdi_handle, work_out );
	}
}

VOID close_gem() {
   v_clsvwk( vdi_handle );
   appl_exit();
}

WORD hprintf(BYTE to, BYTE *fmt, ...)
{
	BYTE		line[256];
				
	WORD		cnt = 0;
	va_list		argptr;

	va_start(argptr, fmt);
	
	cnt += vsprintf(line, fmt, argptr);

	if (MTask != MULTIGEM) {
		printf ("\033Y%c%cTime : %-05ld Secs.", ' ', 60+' ', time(NULL) - Ttest);
		switch (to) {
			case S_ALL:
				printf("\033E\033Y%c%cArea     :", ' ', ' ');
				printf("\033Y%c%cImported : %d", 1+ ' ', ' ', nimported);
				printf("\033Y%c%cExported : %d", 2+ ' ', ' ', nechos);
				printf("\033Y%c%cSysop    : %d", 3+ ' ', ' ', nprivate);
				printf("\033Y%c%cNetmail  : %d", 4+ ' ', ' ', nnetmails);
				printf("\033Y%c%cComments :", 5+' ', ' ');
				printf("\033Y%c%cFrom        :", 1+' ', 16+' ');
				printf("\033Y%c%cDestanation :", 2+' ', 16+' ');
				printf("\033Y%c%cDeleted     : 0", 3+ ' ', 16+' ');
				printf("\033Y%c%cTrashed     : %d", 4+' ', 16 +' ', ntrashed);
				printf ("\033Y%c%c\033p", (S_START - 1)+' ', ' ');
				printf ("%s    \033q", Copyright);

				LOG_line = S_START;
				break;
			case S_AREA:
				printf("\033Y%c%c%-20s",   ' ', 11+' ', line);
			break;
			case S_IMP:
				printf("\033Y%c%c%-04s", 1+' ', 11+' ', line);
			break;
			case S_EXP:
				printf("\033Y%c%c%-04s", 2+' ', 11+' ', line);
			break;
			case S_SYSOP:
				printf("\033Y%c%c%-04s", 3+' ', 11+' ', line);
			break;
			case S_NETMAIL:
				printf("\033Y%c%c%-04s", 4+' ', 11+' ', line);
			break;
			case S_DELETED:
				printf("\033Y%c%c%-04s", 3+' ', 30+' ', line);
			break;
			case S_FROM:
				printf("\033Y%c%c%-25s", 1+' ', 30+' ', line);
			break;
			case S_DEST:
				printf("\033Y%c%c%-25s", 2+' ', 30+' ', line);
			break;
			case S_COMMENT:
				printf("\033Y%c%c%-50s", 5+' ', 11+' ', line);
			break;
			case S_TRASH:
				printf("\033Y%c%c%-04s", 4+' ', 30+' ', line);
			break;
		}
	}
	else {
		va_end (argptr);
		return (0);
	}
	
	va_end(argptr);
	
	return (cnt);
}

WORD gprintf(BYTE *fmt, ...)
{
	BYTE		line[256];
				
	WORD		cnt = 0;
	va_list		argptr;

	va_start(argptr, fmt);
	
	cnt += vsprintf(line, fmt, argptr);

	if (MTask != MULTIGEM) {
		LOG_line ++;
		
		if (LOG_line >= 23) {
			LOG_line = 22;
			printf ("\033Y%c%c\033M", S_START+' ', 0+' ');
		}
		printf ("\033Y%c%c", LOG_line+' ', 0+' ');
		if (line [strlen (line) - 1] == '\n')
			line[strlen(line) - 1] = EOS;
		printf("%s", line);
	}
	else {
		v_curtext(vdi_handle, line);
		if (line [strlen (line) - 1] == '\n')
			v_curtext (vdi_handle, "\r");
		else
			v_curtext (vdi_handle, " ");
	}
	
	va_end(argptr);
	
	return (cnt);
}


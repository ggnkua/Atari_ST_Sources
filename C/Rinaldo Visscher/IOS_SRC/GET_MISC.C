/*********************************************************************

					IOS - Get_ routines
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991

	Get the areaname
	Get the SEEN-BY's
	Get the PATH's
	Get the FMPT and TOPT lines
	Get the INTL line
	Get the MSGID
	Get the REPLY
	Get the tearline
	Get the origin line
***********************************************************************/

#include		<stdio.h>
#include		<string.h>
#include		<stdlib.h>
#include		<errno.h>
#include		<ctype.h>
#if !defined LATTICE
#include		<ext.h>
#else
#include 		<sys/stat>
#endif

#include		"portab.h"
#include		"defs.h"
#include		"ioslib.h"

#include		"inmail.h"
#include		"strutil.h"
#include		"lang.h"

#include		"vars.h"



/*
**	Get arealine.
*/

BYTE *get_area(BYTE *msg)
{
	BYTE	*q,
			*p = msg,
			temp[80],
			*area;
	BYTE	*s;
	WORD	i = 0;
	
	if (!*p) return(NULL);
	
	if (strncmp(p, "AREA:", 5) && strncmp(p, "\01AREA:", 6))
	{
		p = skip_to_token(p, '\n');
		
		while (*p)
		{
			if (!strncmp(p, "AREA:", 5) || !strncmp(p, "\01AREA:", 6))
				goto HAVE_AREA;
			
			i++;
			
			if (*p != '\01' || i > 4) break;
			
			p = skip_to_token(p, '\n');
		}
		
		return(NULL);
	}
	
	HAVE_AREA:
	
	while (*p)
	{
		p = skip_to_token(p, ':');
		p = skip_blanks(p);
		
		/*
		** Look for secundary arealine such as AREA: AREA: MYAREA
		** try to be smarter then the ones that trying to get the
		** system on the run.
		*/
		
		if ((s = get_area(p)) != NULL)
		{
			log_line(6,Logmessage[M__AREA_LINE_2], s);
			return(s);
		}
		else break;
	}
	
	if (!*p)
	{
		log_line(5,Logmessage[M__NO_MESSAGE]);
		return(NULL);
	}
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	area = ctl_string(temp);
	
	/*
	**	Look if the message contains an second arealine. Such as
	**
	**		AREA:MYAREA1
	**		AREA:MYAREA2
	**
	**	If trasharea exist, dump this message there so the sysop
	**	can move the message to the right area.
	*/
	
	p = skip_blanks(p);
	
	if ((s = get_area(p)) != NULL)
	{
		if (stricmp(s, area))
		{
			if (strlen(trasharea))
			{
				log_line(5,Logmessage[M__MORE_AREA_LINES]);
				free(area);
				free(s);
				return("TRASHAREA");
			}
			
			log_line(5,Logmessage[M__MORE_AREA_LINES]);
			return(s);
		}
		
		free(s);
	}
	
	return(area);
}

/* Get TOPT or FMPT line. */

UWORD get_point(BYTE *msg, BYTE *line)
{
	UWORD	point;
	BYTE	*p = strline(msg, line),
			*q,
			temp[10];
	
	if (!p) return(-1);
	
	p = skip_blanks(p);
	p = skip_to_blank(p);
	p = skip_blanks(p);
	
	for (q = temp; *p && isdigit(*p); *q++ = *p++);
	*q = EOS;
	
	/*
	**	If no number found try to find an next line.
	**	If found return that number.
	*/
	
	if (!strlen(temp))
		if (*p)
			if ((point = get_point(p, line)) == (UWORD)(-1))
				return((UWORD)(-1));
			else
				return(point);
		else
			return((UWORD)(-1));
	
	/*
	**	We'v got a number.
	*/
	
	point = atoi(temp);
	
	if (strline(messagebuffer, line) != NULL)
		messagebuffer = strip_line(messagebuffer, line);
	
	return(point);
}

/* Parse INTL line */

BYTE get_interzone(BYTE *msg, UWORD *fzone, UWORD *fnet, UWORD *fnode,
					UWORD *tzone, UWORD *tnet, UWORD *tnode)
{
	UWORD	z, e, n;
	BYTE	*p = strline(msg, "\01INTL"),
			*q,
			temp[80];
	
	if (!p) return(0);
	
	p = skip_to_token(p, 'L');
	p = skip_blanks(p);
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	if (sscanf(temp, "%d:%d/%d", &z, &e, &n) != 3)
	{
		log_line(6,Logmessage[M__INTL_ERROR]);
		return(0);
	}
	
	*tzone = z;
	*tnet = e;
	*tnode = n;
	
	p = skip_blanks(p);
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	if (sscanf(temp, "%d:%d/%d", &z, &e, &n) != 3)
	{
		log_line(5,Logmessage[M__INTL_ERROR]);
		return(0);
	}
	
	*fzone = z;
	*fnet = e;
	*fnode = n;

/*	
	if (strline(messagebuffer, "\01INTL") != NULL)
		messagebuffer = strip_cr(p);
*/
	if (strline(msg, "\01INTL") != NULL)
		msg = strip_line(msg, "\01INTL");
		
	return(1);
}

/* Get the msgid. */

BYTE get_msgid(BYTE *msg, UWORD *zone, UWORD *net, UWORD *node, UWORD *point)
{
	BYTE	*p = strline(msg, "\01MSGID:"),
			*q,
			temp[80];
	UWORD	zo,
			ne,
			no,
			po;
	
	if(!p) return(FALSE);
	
	p = skip_to_token(p, ':');
	p = skip_blanks(p);
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	if ((q = strchr(temp, '@')) != NULL) *q = EOS;
	
	if (strchr(temp, '.') != NULL) 
		{
		if (sscanf(temp, "%d:%d/%d.%d", &zo, &ne, &no, &po) != 4)
			return(FALSE);
		}
	else
		{
		if (sscanf(temp,"%d:%d/%d",&zo,&ne,&no) != 3)
		
			return(FALSE);
		else
			po = 0;
		}
	*zone = zo;
	*net = ne;
	*node = no;
	*point = po;
	
	return(TRUE);
}

/* Get reply fom node */

BYTE get_reply(BYTE *msg, UWORD *zone, UWORD *net, UWORD *node, UWORD *point)
{
	UWORD	zo,
			ne,
			no,
			po;
	BYTE	*p = strline(msg, "\01REPLY"),
			*q,
			temp[80];
	
	if (!p) return(FALSE);
	
	p = skip_to_token(p, ':');
	p = skip_blanks(p);
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	if ((q = strchr(temp, '@')) != NULL) *q = EOS;
	
	if (strchr(temp, '.') != NULL)
		{
		if (sscanf(temp, "%d:%d/%d.%d", &zo, &ne, &no, &po) != 4)
			return(0);
		}
	else
		{
		if (sscanf(temp,"%d:%d/%d",&zo,&ne,&no) != 3)
			return(FALSE);
		else
			po = 0;
		}
	*zone = zo;
	*net = ne;
	*node = no;
	*point = po;
	
	return(TRUE);
}

/* Get PATH of the message. */

BYTE *get_path(BYTE *msg, WORD area)
{
	BYTE	*p,
			*q,
			temp[100],
			*oldmsg,
			*keepnul;
	UWORD	zone,
			net,
			node;
	WORD	i;
	
#if defined DEBUG
	printf("*Get PATH:\n");
#endif
	
	if ((oldmsg = strline(msg, "PATH:")) == NULL &&
		(oldmsg = strline(msg,"\01PATH:")) == NULL) return(NULL);
	
#if defined DEBUG
	printf("*Have PATH.\n");
#endif
	
	keepnul = oldmsg;
	
	oldmsg = skip_to_token(oldmsg, ':');
	p = skip_blanks(oldmsg);
	
	if (!isdigit(*p))
	{
		log_line(6,Logmessage[M__PATH_ERROR]);
		
		while (!isdigit(*p))
		{
			if (!*p)
			{
				log_line(4,Logmessage[M__PATH_HAS_NO_NODES]);
				return(NULL);
			}
			p++;
		}
	}
	
	zone = Tozone[area][0];
	
	for (i=0; i < nalias; i++)
		if (zone == alias[i].zone) break;
	
	if (i >= nalias) zone = alias[0].zone;
	
	/*
	**	We getting it from an other zone
	*/
	
	if (zone != Fzone) zone = Fzone;
	
#if defined DEBUG
	printf("*Parsing numbers\n");
#endif
	
	net = node = 0;
	
	while (*p)
	{
		/*
		**	No numbers anymore and the message goes one?
		**	leave routine
		*/
		
		if (!isdigit(*p)) break;
		
		for (q = temp; *p && isdigit(*p); *q++ = *p++);
		*q = EOS;
		
		if (*p == ':')
		{
			zone = atoi(temp);
			
			p++;
			continue;
		}
		
		if (*p == '/')
		{
			net = atoi(temp);
			p++;
			continue;
		}
		
		node = atoi(temp);
		
		Pathzone[npath] = zone;
		Pathnet[npath] = net;
		Pathnode[npath++] = node;
		
		p = skip_blanks(p);
		if (!*p) break;
		
		if (!strncmp(p, "PATH:", 5) || !strncmp(p, "\01PATH:", 6))
		{
			p = skip_to_token(p, ':');
			p = skip_blanks(p);
		}
	}
	
	*keepnul = EOS;
	
	Pathzone[npath] = Pathnet[npath] = Pathnode[npath] = (-1);
	
	return(NULL);
}

/*
**	Find the SEEN-BY in the message.
*/

BYTE *get_seen(BYTE *msg, WORD area)
{
	BYTE	*p,
			*q,
			temp[100],
			*oldmsg,
			*keepnul;
	UWORD	zone,
			net,
			node,
			lzone = 0,
			lnet = 0,
			lnode = 0;
	WORD	i;
	
#if defined DEBUG
	printf("*Get SEEN-BY\n");	
#endif
	
	/*
	**	Try to follow me. Trying to get several known seen-by's.
	*/
	
	if ((oldmsg = strline(msg, "SEEN-BY:")) == NULL) {
		if ((oldmsg = strline(msg, "\01SEEN-BY:")) == NULL) return (NULL);
	}
	
#if defined DEBUG
	printf("*Have SEEN-BY.\n");
#endif
	
	keepnul = oldmsg;
	
	/*
	**	If the messages comes from an other zone and we want to
	**	strip the SEEN-BY from this zone, returns simply a NULL.
	**	fzone is the zonenumber in the packet header, thus where
	**	we get the message's from. tzone is ourzone. So let end
	**	the message's at the SEEN-BY
	*/
	
	if (dostripzone && fzone != tzone) return(NULL);
	
	oldmsg = skip_to_token(oldmsg, ':');
	p = skip_blanks(oldmsg);
	
	/*
	**	Maybe they try to fool us, and a message is under it.
	*/
	
	if (!isdigit(*p) && *p)
	{
		get_seen(oldmsg, area);
		return(NULL);
	}
	
	zone = Tozone[area][0];
	
	for (i=0; i < nalias; i++)
		if(zone == alias[i].zone) break;
	
	if (i >= nalias) zone = alias[0].zone;
	
	/*
	**	If getting from other zone than add zone.
	*/
	
	if (zone != Fzone) zone = Fzone;
	
#if defined DEBUG
	printf("*Parsing numbers.\n");
#endif
	
	net = node = 0;
	
	while (*p)
	{
		/*
		**	No numbers anymore and the message goes one?
		**	leave routine
		*/
		
		if (!isdigit(*p)) break;
		
		for (q = temp; *p && isdigit(*p); *q++ = *p++);
		*q = EOS;
		
		if (*p == ':')
		{
			zone = atoi(temp);
			p++;
			continue;
		}
		
		if (*p == '/')
		{
			net = atoi(temp);
			p++;
			continue;
		}
		
		node = atoi(temp);
		
		if ((net == Ffake && Fpoint) ||
			(lzone == zone && lnet == net && lnode == node))
			continue;
		
		for (i = 0; i < nalias; i++) {
			if (net == alias[i].pointnet) break;
		}
		
		if (i < nalias) continue;
		
		lzone = zone;
		lnet = net;
		lnode = node;
		
		SeenZ[nseenby] = zone;
		SeenN[nseenby] = net;
		SeenO[nseenby++] = node;
		
		if (nseenby >= N_SEENS-1) break;
		
		p = skip_blanks(p);
		
		/*
		**	If we have more of them, parse it.
		*/
		
		if (!strncmp(p, "SEEN-BY:", 8) ||
			!strncmp(p, "\01SEEN-BY:",9))
		{
			p = skip_to_token(p, ':');
			p = skip_blanks(p);
		}
		
		/*
		**	No numbers anymore and the line keep going?
		*/
		
		if (!isdigit(*p) && *p)
		{
			get_seen(p, area);
			return(NULL);
		}
	}
	
	*keepnul = EOS;
	
#if defined DEBUG
	printf("*Have SEEN-BY\n");
#endif
	
	msg = strip_those_lines(msg, "SEEN-BY:");
	msg = strip_those_lines(msg, "\01SEEN-BY");
	
	return(msg);
}

/*
**	Is there any tearline ans origin in the message?
**	No, create one.
*/

VOID get_org_and_tearline(BYTE *msg)
{
	BYTE	*p, *q,
			*temp1,
			*temp2,
			org[80],
			tearline[40],
			origin = TRUE,
			tear = TRUE,
			pnt[20];
	UWORD	zone, net, node, point;
	
	if ((p = strline(msg, "---\n")) == NULL &&
		(p = strline(msg,"--- ")) == NULL) tear = FALSE;
	
	if ((q = strline(msg, " * Origin:")) == NULL) origin = FALSE;
	
	if (tear && origin) return;
	
#if defined DEBUG
	printf("*No origin or tearline.\n");
#endif
	
	if (tear)
	{
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,"#Alloc temp1 (Get_)");
		}
#endif
		temp1 = (BYTE *) myalloc(strlen(p)+2);
		strcpy(temp1, p);
	}
	else
		sprintf(tearline, "\n--- %s\n", InMail);
	
	zone = Fzone;
	net = Fnet;
	node = Fnode;
	point = Fpoint;
	
	if (origin)
	{
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,"#Alloc temp2 (Get_)");
		}
#endif
		temp2 = (BYTE *) myalloc(strlen(q)+2);
		strcpy(temp2,q);
	}
	else
	{
		if (get_msgid(msg, &zone, &net, &node, &point) == -1)
		{
			zone = Fzone;
			net = Fnet;
			node = Fnode;
			point = Fpoint;
		}
		
		if (point) sprintf(pnt, ".%d", point);
		else *pnt = EOS;
		
#if defined DEBUG
		printf("*Adding origin line.\n");
#endif
		
		sprintf(org, "\n * Origin: Unknown, added by IOSmail (%d:%d/%d%s)\n",
			zone, net, node, pnt);
	}
	
	if (!tear && !origin)
	{
		strcat(msg, tearline);
		strcat(msg, org);
		return;
	}
	
	if (!tear)
	{
#if defined DEBUG
		printf("*Adding tearline.\n");
#endif
		sprintf(q, "%s%s", tearline, temp2);
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,"#Free temp2 (Get_)");
		}
#endif
		free(temp2);
		return;
	}
	
	if (!origin)
	{
		strcat(msg, org);
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,"#Free temp1 (Get_)");
		}
#endif
		free(temp1);
#if defined DEBUG
		printf("*Added origin line.\n");
#endif
		return;
	}
}

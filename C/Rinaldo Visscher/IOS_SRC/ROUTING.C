/*********************************************************************

					IOS - routing checker
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	Check routing of files and-or packets
***********************************************************************/

#include		<stdio.h>
#include		<stdlib.h>
#include		<ext.h>
#include		<string.h>
#include		<tos.h>
#include		<ctype.h>

#include		"portab.h"
#include		"defs.h"
#include		"ioslib.h"
#include		"routing.h"
#include		"modules.h"
#include		"inmail.h"
#include		"lang.h"

#include		"vars.h"


BYTE *outbound_dir(UWORD zone, UWORD net, UWORD node, UWORD point)
{
	BYTE	*p,*q,
			folder[128];
	MLOCAL BYTE temp[128];
	WORD	i;
	
	strcpy(folder, outbound);
	
	if (dothebox == TRUE) {
		strcpy (temp, outbound);
		return (temp);
	}
	
	for (i=0; i < domain; i++)
		if (zone == Appl[i].zone)
		{
			if (zone != alias[0].zone) strcpy(folder, Appl[i].path);
			
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">Domain %u dir %s", Appl[i].zone, Appl[i].path);
#endif
			break;
		}
	
	strcpy(temp, folder);
	
	if (zone == alias[0].zone)
	{
		xsprintf(&temp[strlen(temp)], "%03z%03z%02z", net, node, point);
		
#if defined OUTDEBUG
		if (dooutdeb)
		{
			log_line(6,">Zone is the same as first alias.");
			log_line(6,">Return %s", temp);
		}
#endif
		return(temp);
	}

	if(donewbink == TRUE && dothebox == TRUE) dothebox = FALSE;
	
	if ((p = strrchr(temp, '\\')) != NULL) *p = EOS;
	
	p = strrchr (temp, '\\');
	
	if(p) {
		if ((q = strchr(p, '.')) != NULL)
			sprintf(++q, "%03x", zone);
		else	
			if (dothebox == FALSE)
				sprintf(&temp[strlen(temp)], ".%03x", zone);
	}
	
	if (stat(temp, &stbuf) == FAILURE && Dcreate(temp) < 0)
	{
		log_line(5,Logmessage[M__CANT_CREATE_FOLDER], temp);
		strcpy(temp, folder);
		xsprintf(&temp[strlen(temp)], "%03z%03z%02z", net, node, point);
		
		return(temp);
	}
	
	strcat(temp, "\\");
	xsprintf(&temp[strlen(temp)], "%03z%03z%02z", net, node, point);
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Return outbound %s", temp);
#endif
	
	return(temp);
}

VOID attached_file(MSGHEADER *hdr)
{
	BYTE		*q,
				*p,
				*temp,
				filename[128],
				buffer[128],
				domain[10];
	WORD		i, hold;
	UWORD		dzone, dnet, dnode, dpoint = 0,
				retcode,
				j;
	
	struct ffblk blk;
	
	if (hdr->Dpoint == (UWORD)-1) hdr->Dpoint = 0;
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Attached file for %u:%u/%u.%u", hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Dpoint);
#endif
	
	/*
	**	Is file send allowed?
	*/
	
	if (!(hdr->flags & CRASH))
	{
#if defined OUTDEBUG
		if (dooutdeb) log_line(6,">Not crashed");
#endif
		if (!sendOk(hdr, FILETO))
		{
			log_line(4,Logmessage[M__FILE_NOT_SENT], hdr->Dzone,
				hdr->Dnet,	hdr->Dnode,	hdr->Dpoint);
			return;
		}
	}
	
	/*
	**	Controleer of bestemming in de password regels zit.
	*/
	
	for (i=0; i < nkey; i++)
		if (pwd[i].zone == hdr->Dzone && pwd[i].net == hdr->Dnet &&
			pwd[i].node == hdr->Dnode && pwd[i].point == hdr->Dpoint)
		{
			dzone	=	hdr->Dzone;
			dnet	=	hdr->Dnet;
			dnode	=	hdr->Dnode;
			dpoint	=	hdr->Dpoint;
			
			break;
		}
	
	if (i >= nkey) {
		
		/*
		**	Als niet gecrashed, zoek naar routing van file.
		*/
		
		if (!(hdr->flags & CRASH))
		{
			retcode = routeOk(hdr);
			
			if (retcode != (UWORD) -1)
				address(RouteDef[retcode].destnode, &dzone, &dnet, &dnode, &j, &j, domain);
			else {
				
				/*
				**	File kan niet normaal gerouted worden.
				*/
				
				log_line (6, "No route for file %s!!", hdr->topic);
				return;
			}
			
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">Not passworded, File dzone, dnet, dnode %u:%u/%u", dzone, dnet, dnode);
#endif
		}
		else
		{
			/*
			**	Crash file
			*/
			
			dzone	=	hdr->Dzone;
			dnet	=	hdr->Dnet;
			dnode	=	hdr->Dnode;
			
			if (crashPoint(dzone, dnet, dnode, hdr->Dpoint) == TRUE) {
				dpoint = hdr->Dpoint;
			} else {
				dpoint = 0;
			}
			
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">Crashed, File dzone, dnet, dnode, dpoint %u:%u/%u.%u", dzone, dnet, dnode, dpoint);
#endif
		}
	} else {
	
	/*
	**	Als node voorkomt in password regels en het bericht is niet
	**	gecrashed, dan moet het niet via de gecrashde routing
	**	gaan.
	*/
	
		if ((hdr->flags & CRASH)) {
			if (dpoint) {
				if (crashPoint (dzone, dnet, dnode, dpoint) == FALSE) {
					dpoint = 0;
				}
			}
		} else {
			if ( pwd[i].crash_to == AT_CRASH) {
				if ((retcode = routeOk(hdr)) != (UWORD) -1) {
					address(RouteDef[retcode].destnode, &dzone, &dnet, &dnode, &j, &j, domain);
				}
			}
		}
	}
	
	/*
	**	Send to ....
	*/
	
	Knownas(hdr, &dzone, &dnet, &dnode, &dpoint);
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Known as dzone, dnet, dnode, dpoint %u:%u/%u.%u", dzone, dnet, dnode, dpoint);
#endif
	
	temp = outbound_dir(dzone, dnet, dnode, dpoint);
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Outbound created %s", temp);
#endif

	/*
	**	First build the filename.
	*/
		
	if (hdr->flags & CRASH) {
		if (donewbink) {
			strcat(temp,".CFT");
		} else {
			p = strrchr(temp ,'\\');
			if (p) {
				if (dothebox) {
					xsprintf(++p, "%02z%03z%03z.CF",dzone,dnet,dnode);
				} else {
					sprintf(++p, "%04x%04x.CLO", dnet, dnode);
				}
			}
		}
	}
	else {
		if (hdr->flags & CRASH)
			hold = FALSE;
		else 
			hold = holdOk(hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Dpoint);
		if (donewbink) {
			strcat(temp, (hold) ? ".HFT" : ".OFT");
		} 
		else {
			p = strrchr(temp, '\\');
			if (p) {
				if (!hdr->Opoint && hdr->Dpoint) {
					for (i = 0; i< nalias; i++) {
						if (hdr->Dnet == alias[i].net &&
							hdr->Dnode== alias[i].node) {
							sprintf(++p, "%04x%04x.",alias[i].pointnet,
								hdr->Dpoint);
							break;
						}
					}
					if (i >= nalias) sprintf(++p, "%04x%04x.",dnet,dnode);
				} else {
					sprintf(++p, "%04x%04x.",dnet, dnode);
				}
				strcat(temp, (hold) ? "HLO" : "FLO");
			}
		}
	}
	
	/*
	**	If received, take path of inbound.
	*/
	
	if (!(hdr->flags & MSGLOCAL))
	{
		
#if defined OUTDEBUG
		if (dooutdeb) log_line(6,">Message not crashed.");
#endif
		for (i=0; i < 3; i++)
		{
			if (Inboundpaths[i] != NULL)
			{
				if (Inboundpaths[i][strlen(Inboundpaths[i])-1] != '\\')
					sprintf(filename, "^%s\\%s", Inboundpaths[i], hdr->topic);
				else
					sprintf(filename, "^%s%s", Inboundpaths[i], hdr->topic);
				
				if (!findfirst(&filename[1], &blk, 0))
				{
					if (strcmp(hdr->from, SysOp) &&
						!filesendOk(blk.ff_fsize, hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Dpoint))
					{
						log_line(4,Logmessage[M__FILE_TO_BIG],
							hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Dpoint);
						
						free(temp);
						return;
					}
					
					log_line(5,Logmessage[M__GET_FILES], hdr->Dzone,
						hdr->Dnet, hdr->Dnode, hdr->Dpoint, hdr->topic);
					break;
				}
			}
		}
		
		if (i >= 3)
		{
			log_line(4,Logmessage[M__FILE_NOT_FOUND]);
			hdr->topic[0] = EOS;
			free(temp);
			return;
		}
	}
	else
	{
		strcpy(buffer, hdr->topic);
		
		if (findfirst(buffer, &blk, 0))
		{
			log_line(5,Logmessage[M__FILE_DOESNT_EXIST]);
			return;
		}
		
		q = strrchr(buffer, '\\');
		
		if (q)
		{
			++q;
			strcpy(hdr->topic, q);
		}
		else
		{
			log_line(4,Logmessage[M__NO_FILE_SPECIFIED]);
			free(temp);
			return;
		}
		
		log_line(6,Logmessage[M__SENT_FILE_TO], hdr->topic, hdr->Dzone,
			hdr->Dnet, hdr->Dnode, hdr->Dpoint);
		strcpy(filename, buffer);
	}
	
	if ((FDUMMY = fopen(temp, "r+")) == NULL)
	{
		if ((FDUMMY = fopen(temp, "w")) == NULL)
		{
			log_line(6,Logmessage[M__CANT_OPEN], temp);
			free(temp);
			return;
		}
	}
	else
	{
		while (fgets(buffer, 128, FDUMMY))
			if (!strncmp(buffer, filename, (WORD)strlen(filename)) ||
				!strncmp(&buffer[1], filename, (WORD)strlen(filename)))
			{
				fclose(FDUMMY);
				free(temp);
				return;
			}
	}
	
	fseek(FDUMMY, 0L, SEEK_END);
	fprintf(FDUMMY, "%s\n", filename);
	fclose(FDUMMY);
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">File %s in file %s", filename, temp);
#endif
	
	free(temp);
}

BOOLEAN sendOk(MSGHEADER *hdr, WORD what)
{
	WORD	i;
	BYTE	buffer[100];
	
	for (i=0; i < nRouteDef; i++)
	{
		if (RouteDef[i].flags == what)
		{
			sprintf(buffer, "%u:%u/%u.%u", hdr->Dzone, hdr->Dnet,
				hdr->Dnode,	hdr->Dpoint);
			
			if (match(buffer, RouteDef[i].destnode))
			{
#if defined OUTDEBUG
				if (dooutdeb) log_line(6,">sendOk have %s to %s", buffer, RouteDef[i].destnode);
#endif
				return(TRUE);
			}
		}
	}
	
	return(FALSE);
}

BYTE DenyOk (UWORD zone, UWORD net, UWORD node, UWORD point) {
	WORD	i;
	BYTE	buffer[100];
	
	if (doDENIED == FALSE) return (TRUE);
	
	for (i=0; i < nRouteDef; i++)
	{
		if (RouteDef[i].flags == DENYOK)
		{
			sprintf(buffer, "%u:%u/%u.%u", zone, net,
				node, point);
			
			if (match(buffer, RouteDef[i].destnode))
			{
#if defined EXTERNDEBUG
				if (dooutdeb) log_line(6,">DenyOk have %s to %s", buffer, RouteDef[i].destnode);
#endif
				return(TRUE);
			}
		}
	}
	
	return(FALSE);
}

WORD holdOk(UWORD zone, UWORD net, UWORD node, UWORD point)
{
	WORD	i;
	BYTE	buffer[100];
	
	sprintf(buffer, "%u:%u/%u.%u", zone, net, node, point);
	
	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags  & HOLDMSG && match(buffer, RouteDef[i].destnode))
		{
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">holdOk have %s for %s", buffer, RouteDef[i].destnode);
#endif
			return(TRUE);
		}
	
	return(FALSE);
}

BOOLEAN arcOk(UWORD zone, UWORD net, UWORD node, UWORD point)
{
	WORD	i;
	BYTE	buffer[100];
	
	sprintf(buffer, "%u:%u/%u.%u", zone, net, node, point);
	
	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags  & SENDARC && match(buffer, RouteDef[i].destnode))
			return(TRUE);
	
	return(FALSE);
}

WORD moveOk(UWORD zone, UWORD net, UWORD node, UWORD point)
{
	WORD	i;
	BYTE	buffer[100];
	
	sprintf(buffer, "%u:%u/%u.%u", zone, net, node, point);
	
	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags & KNOWNAS && match(buffer, RouteDef[i].fromnode))
		{
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">moveOk have %s against %s", buffer, RouteDef[i].destnode);
#endif
			return(i);
		}
	
	return(-1);
}

WORD hold_pollOk(UWORD zone, UWORD net, UWORD node, UWORD point, WORD what)
{
	WORD	i;
	BYTE	buffer[100];
	
	sprintf(buffer, "%u:%u/%u.%u", zone, net, node, point);
	
	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags & what && match(buffer, RouteDef[i].destnode))
		{
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">hold_pollOk have %s against %s", buffer, RouteDef[i].destnode);
#endif
			return(i);
		}
	
	return(-1);
}

BOOLEAN crashPoint(UWORD zone, UWORD net, UWORD node,UWORD point) {
	WORD	i;
	BYTE	buffer[100];
	
	sprintf(buffer, "%u:%u/%u.%u", zone, net, node, point);
	
	for(i=0; i < nRouteDef; i++) 
		if (RouteDef[i].flags & CRASHPOINT && match(buffer, RouteDef[i].destnode))
		{
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">crashPoint have %s against %s", buffer, RouteDef[i].destnode);
#endif
			return (TRUE);
		}
	
	return (FALSE);
}

BOOLEAN crashOk(UWORD zone, UWORD net, UWORD node)
{
	WORD	i;
	BYTE	buffer[100];
	
	sprintf(buffer, "%u:%u/%u", zone, net, node);
	
	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags & CRASHOK && match(buffer, RouteDef[i].destnode))
		{
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">crashOk have %s against %s", buffer, RouteDef[i].destnode);
#endif
			return(TRUE);
		}
	
	return(FALSE);
}

WORD routeOk(MSGHEADER *hdr)
{
	WORD	i;
	BYTE	buffer[100];
	
	if (!ouralias(hdr->Dzone, hdr->Dnet, hdr->Dnode, 0))
		sprintf(buffer, "%u:%u/%u.%u", hdr->Dzone, hdr->Dnet,
			hdr->Dnode, hdr->Dpoint);
	else
		sprintf(buffer, "%u:%u/%u.0", hdr->Dzone, hdr->Dnet, hdr->Dnode);
	
	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags & ROUTE && match(buffer, RouteDef[i].fromnode))
		{
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">routeOk have %s against %s", buffer, RouteDef[i].destnode);
#endif
			return(i);
		}
	
	return(-1);
}

VOID Knownas(MSGHEADER *hdr, UWORD *zone, UWORD *net, UWORD *node, UWORD *point)
{
	UWORD	i, j,
			zo,	ne,	no,	po;
	BYTE	buffer[100],
			domain[10];
	
	sprintf(buffer, "%u:%u/%u.%u", hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Dpoint);
	
	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags == KNOWNAS && match(buffer, RouteDef[i].fromnode))
		{
			address(RouteDef[i].destnode, &zo, &ne, &no, &po, &j, domain);
			
			*zone = zo;
			*net = ne;
			*node = no;
			*point = po;
			
			break;
		}
	
	return;
}

BOOLEAN filesendOk(LONG size, UWORD zone, UWORD net, UWORD node, UWORD point)
{
	WORD	i, j;
	LONG	s;
	BYTE	buffer[128];
	
	sprintf(buffer, "%u:%u/%u.%u", zone, net, node, point);
	
	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags & FILEMAX &&
			match(buffer, RouteDef[i].destnode) &&
			(j = atoi(RouteDef[i].fromnode)) != 0)
		{
			s = (LONG)j * 1024L;
			
			if (size > s) return(FALSE);
			return (TRUE);
		}
	
	return(TRUE);
}

/*
**	Check the way this netmail must go.
*/

VOID find_ROUTE(MSGHEADER *hdr, BYTE *msgtext)
{
	UWORD	j, Xvia,
			zone, net, node, point;
	WORD	i,
			retcode;
	BYTE	*newmsg,
			intl_ever = FALSE,
			domain[10];
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Find route %u:%u/%u.%u", hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Dpoint);
#endif

	if ( DO_track (hdr, msgtext) == TRUE) {
		return;
	}
	
	newmsg = (BYTE *) myalloc(MAXMSGLENGTH);
	*newmsg = EOS;

	if (!(hdr->flags & CRASH)) {
	
		/*
		**	Get address for proper sending.
		**	To which node must this message go ?
		*/
		
		retcode = moveOk(hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Dpoint);
		
		if (retcode != -1)
		{
			address(RouteDef[retcode].destnode, &zone, &net, &node, &point, &j, domain);
			
	#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">move has %u:%u/%u.%u", zone, net, node, point);
	#endif
		}
		else
		{
			retcode = routeOk(hdr);
			
			if (retcode != -1)
			{
				address(RouteDef[retcode].destnode, &zone, &net, &node, &point, &j, domain);
				
	#if defined OUTDEBUG
				if (dooutdeb) log_line(6,">RouteOk has %u:%u/%u.%u", zone, net, node, point);
	#endif
			}
			else
			{
				if (!nbosses)
				{
					log_line(3,Logmessage[M__NO_DESTANATION]);
					
					free(newmsg);
					return;
				}
				
				zone = bosszone[0];
				net = bossnet[0];
				node = bossnode[0];
				point = bosspoint[0];
			}
		}
	}
	else {
		 zone = hdr->Dzone;
		 net  = hdr->Dnet;
		 node = hdr->Dnode;
		 point= hdr->Dpoint;
	}
		 
	for (i=0; i < nalias; i++)
		if (hdr->Ozone == alias[i].zone &&
			hdr->Onet ==alias[i].net &&
			hdr->Onode == alias[i].node)
		{
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">Have our alias");
#endif
			break;
		}
	
	
	if (i >= nalias)
	{
		for (i=0; i < nalias; i++)
			if (zone == alias[i].zone) break;
		
		if (i >= nalias) i = 0;
	}
	
	Xvia = i;
	
	time(&secs);
	tijd = localtime(&secs);
	strftime(tm_now, 39, "%b %d %Y at %H:%M", tijd);

	for (i = 0; i < nkey; i++) {
		if (pwd[i].zone == zone && pwd[i].net == net &&
			pwd[i].net  == net  && pwd[i].point==point) {
			
			intl_ever = pwd[i].intl_always;
			break;
		}
	}
	
	if (hdr->Ozone != hdr->Dzone || intl_ever == TRUE) { 
		sprintf(newmsg,"\01INTL %u:%u/%u %u:%u/%u\n",
			hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Ozone, hdr->Onet, hdr->Onode);
	}
	
	if (hdr->Dpoint) sprintf(&newmsg[strlen(newmsg)], "\01TOPT %u\n", hdr->Dpoint);
	if (hdr->Opoint) sprintf(&newmsg[strlen(newmsg)], "\01FMPT %u\n", hdr->Opoint);
	
	strcat(newmsg, msgtext);
	
	if (strncmp(newmsg, "AREA:", 5))
	{
		sprintf(&newmsg[strlen(newmsg)], "\n\01Via %s %u:%u/%u.%u, %s",
			OutMail, alias[Xvia].zone, alias[Xvia].net,
			alias[Xvia].node, alias[Xvia].point, tm_now);
	}
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Savemessage");
#endif
	
	savemsg(NETMAILPACKET, hdr, -1, newmsg, zone, net, node, point);
	
	if (!(hdr->flags & CRASH))
		log_line(4,Logmessage[M__FOLLOW_ROUTE], zone, net, node, point);
	else
		log_line(4,Logmessage[M__MAIL_CRASHED], hdr->Dzone,
			hdr->Dnet, hdr->Dnode, hdr->Dpoint);
	
	free(newmsg);
}

VOID check_HDR(VOID)
{
	WORD	i,
			ret;
	UWORD	zone, net, node, point,
			j;
	BYTE	domain[10];
	
	if (doredirect && hdr.flags & MSGLOCAL)
	{
		/*
		**	fakenet gebruikt ?
		*/
		
		for (i=0; i < nalias; i++)
			if (hdr.Onet == alias[i].pointnet)
			{
				hdr.Opoint = hdr.Onode;
				hdr.Onet = alias[i].net;
				hdr.Onode = alias[i].node;
				
				break;
			}
		
		/*
		**	Andere zone, multizone?
		*/
		
		if (hdr.Ozone != hdr.Dzone)
			for(i=0; i < nalias; i++)
				if (alias[i].zone == hdr.Dzone)
				{
					hdr.Ozone	=	alias[i].zone;
					hdr.Onet	=	alias[i].net;
					hdr.Onode	=	alias[i].node;
					hdr.Opoint	=	alias[i].point;
					
					log_line(5,Logmessage[M__MAIL_REDIRECTED],
						hdr.Ozone, hdr.Onet, hdr.Onode, hdr.Opoint);
					
					break;
				}
		
		/*
		**	Multipoint? Use right number.
		*/
		
		if (hdr.Opoint)
		{
			ret = routeOk(&hdr);
			
			if (ret != -1)
			{
				address(RouteDef[ret].destnode, &zone, &net, &node, &point, &j, domain);
				
				for (i=0; i < nalias; i++) {
					if (alias[i].zone == zone &&
						alias[i].net == net &&
						alias[i].node == node)
					{
						hdr.Ozone = alias[i].zone;
						hdr.Onet  = alias[i].net;
						hdr.Onode = alias[i].node;
						hdr.Opoint= alias[i].point;
						
						log_line(5,Logmessage[M__MAIL_UNDER],
							hdr.Ozone, hdr.Onet, hdr.Onode, hdr.Opoint);
						
						break;
					}
				}
			}
		}
	}
}

BOOLEAN capture_msg(MSGHEADER *hdr)
{
	WORD	i;
	
	for (i = 0; i < ncapbuf; i++)
		if (hdr->Dzone == capbuf[i].zone && hdr->Dnet == capbuf[i].net &&
			hdr->Dnode == capbuf[i].node && hdr->Dpoint == capbuf[i].point)
		{
			if (!stricmp((BYTE *)&hdr->to, capbuf[i].name))
				return(TRUE);
			else
				return(FALSE);
		}
	
	return(TRUE);
}

BOOLEAN checkPATH(VOID)
{
	WORD	i, j;
	
	for (i = 0; i < npath; i++)
		for (j = 0; j < nalias; j++)
			if (!alias[i].point && Pathnet[i] == alias[j].net &&
				Pathnode[i] == alias[j].node && !alias[j].point)
			{
				log_line(6,Logmessage[M__MAIL_BOUNCED]);
				return(FALSE);
			}
	
	return(TRUE);
}

VOID redo_PATH(VOID)
{
	WORD	i;
	BYTE	had_none = FALSE;
	
	if (npath <= 0)
	{
		log_line(4,Logmessage[M__NO_PATH]);
		
		Pathzone[0] = Fzone;
		Pathnet[0]  = Fnet;
		Pathnode[0] = Fnode;
		
		had_none = TRUE;
		npath = 1;
	}
	
	for (i=0; i < nalias; i++)
		if (Pathzone[0] == alias[i].zone && Pathnet[0] == alias[i].net &&
			Pathnode[0] == alias[i].node && Fpoint)
		{
			if (alias[i].pointnet) {
				if (!had_none) log_line(5,Logmessage[M__POINT_USES_BOSS], Fpoint);
				
				Pathnet[0] = alias[i].pointnet;
				Pathnode[0] = Fpoint;
			}
			break;
		}
}

BYTE DO_readdress (MSGHEADER *Hdr, BYTE *msg) {
	WORD	i;
	UWORD	zone, net, node, point, j;
	BYTE	buf1[50],
			buf2[50],
			domain[10];
	
	sprintf (buf1, "%u:%u/%u.%u", Hdr->Dzone, Hdr->Dnet,
			Hdr->Dnode, Hdr->Dpoint);

	for (i=0;i <nreaddress; i++) {
		if (newmatch (Hdr->to, readdress[i].fname)) {
			if (match (buf1, readdress[i].fnode)) {
				address (readdress[i].tnode, &zone, &net, &node, &point, &j, domain);
				Hdr->Dzone = zone;
				Hdr->Dnet  = net;
				Hdr->Dnode = node;
				Hdr->Dpoint= point;
				
				strcpy (buf2, Hdr->to);
				strcpy (Hdr->to, readdress[i].tname);
				
				if (doknown && dopkt)
					Hdr->flags |= DELETED;
				else
					Hdr->flags |= KILLSEND;

				time(&secs);
				tijd = localtime(&secs);
				strftime(tm_now, 39, "%b %d %Y at %H:%M", tijd);
				
				sprintf (&msg[strlen (msg)], "\n\01Readdressed by %s on %s",
					V_IOSMAIL, tm_now);
				sprintf (&msg[strlen (msg)], "\n\01Original to %s (%s), readdressed to %s (%u:%u/%u.%u)", 
					buf2, buf1, Hdr->to, zone, net, node, point);
				
				return (TRUE);
			}
		}
	}
	return (FALSE);
}

/*
**	Track destanation, check if destanation is in nodelist.
*/

BYTE CHECKlist (MSGHEADER *Hdr) {
	WORD 	Nlist;
	BYTE	filen[128], *node_index;
	UWORD	zone, net, node;
	LONG 	i, j;
	ULONG	flen, idx_size;
	
	struct ffblk blk;
	
	for (i=0; i < nnodelist; i++) {
		strcpy (filen, NODElist[i]);
		strcat (filen, ".IDX");
		findfirst (filen, &blk, 0);
		
		if ((Nlist = open (filen, O_RDONLY)) == -1) {
			log_line (6, "!Can't open nodelist %s", NODElist[i]);
			continue;
		}
		
		flen = blk.ff_fsize;
		
		idx_size = flen / sizeof (struct _ndi);
		
		node_index = (BYTE *) myalloc (flen);
		
		if (read (Nlist, node_index, flen) != flen) {
			log_line (6, "!Error reading nodelist...");
			close (Nlist);
			return (FALSE);
		}
		
		nodeidx = (struct _ndi *) node_index;
		
		close (Nlist);
		
		for (j=1; j <= idx_size; nodeidx++, j++) {
			net = nodeidx->net;
			node= nodeidx->node;
			
			if ( node == -2 ) {
				zone = net;
				continue;
			}
			
			if (zone == Hdr->Dzone && net == Hdr->Dnet &&
				node == Hdr->Dnode) {
				
				free (node_index);
				return (FALSE);
			}
		}
		free (node_index);
	}
	
	return (TRUE);
}

BYTE TrackOk (MSGHEADER *Hdr) {
	WORD	i;
	BYTE	buf1[50];
	
	if (doNODELIST == FALSE) return (FALSE);
	
	if (!nnodelist) {
		log_line (6, "!Can't track nodes, no nodelist specified.");
		return (FALSE);
	}
	
	sprintf (buf1, "%u:%u/%u.%u", Hdr->Ozone, Hdr->Onet,
			Hdr->Onode, Hdr->Opoint);

	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags & MSGTRACK &&
			match(buf1, RouteDef[i].destnode)) 
				return (FALSE);
	
	return (CHECKlist (Hdr));
}

BYTE DO_track (MSGHEADER *Hdr, BYTE *msg) {
	MSGHEADER 	Shdr;
	BYTE		*Sbuffer, *Tbuffer;
	FILE		*SENDFILE;
	LONG		count = 0, j;
	WORD		c;
	
	if (TrackOk (Hdr) == FALSE) return (FALSE);
	
	if (Hdr->flags & MSGLOCAL) {
		log_line (6, "-This LOCAL message can't be routed, compile newer nodelist.");
		return (TRUE);
	}
	
	if (strlen (TRACKmsg)) {
		if ((SENDFILE = fopen (TRACKmsg, "rb")) == NULL) {
			log_line (6, "!Can't open %s", TRACKmsg);
			return (FALSE);
		}
		
		log_line (4, "-Sending an message back.");
		
		Sbuffer = (BYTE *) myalloc (MAXMSGLENGTH);
		Sbuffer [0] = EOS;
		
		while (1) {
			c = fgetc (SENDFILE);
			
			if (feof (SENDFILE)) break;
			
			if (c == '\r') continue;
			
			count = strlen (Sbuffer);
			
			if (c == '%') {
				c = fgetc (SENDFILE);
				
				if (feof (SENDFILE)) break;
				switch (toupper(c)) {
				
				/*
				**	Parse % signs from file.
				*/
					case 'S':
						sprintf (&Sbuffer[strlen (Sbuffer)], "%s", SysOp);
					break;
					
					case 'T':
						sprintf (&Sbuffer[strlen (Sbuffer)], "%s", Hdr->to);
					break;
					
					case 'F':
						sprintf (&Sbuffer[strlen (Sbuffer)], "%s", Hdr->from);
					break;
					
					case 'P':
						sprintf (&Sbuffer[strlen (Sbuffer)], "%s", Hdr->topic);
					break;
					
					case 'D':
						sprintf (&Sbuffer[strlen (Sbuffer)], 
						"%u:%u/%u.%u", Hdr->Dzone, Hdr->Dnet, Hdr->Dnode, Hdr->Dpoint);
					break;
					
					case 'M':
						Tbuffer = (BYTE *) myalloc (MAXMSGLENGTH);
						
						strcpy (Tbuffer, msg);
						
						for (j = 0; j < strlen (Tbuffer); j++) {
							if (Tbuffer[j] == '\01') {
								Tbuffer[j] = '.';
							}
							if (!strncmp (&Tbuffer[j], "SEEN-BY ", 8)) {
								Tbuffer [j] = '$';
							}
						}
						
						sprintf (&Sbuffer[strlen (Sbuffer)], Tbuffer);
						
						free (Tbuffer);
					break;
				}
			} else {
				sprintf (&Sbuffer[ strlen (Sbuffer)], "%c", (BYTE) c);
			}
		}	/*
			**	End while
			*/
		fclose (SENDFILE);
		
		for (c = 0; c < nalias; c ++) {
			if (Hdr->Ozone == alias[c].zone) break;
		}
		if ( c >= nalias) c = 0;

		time(&secs);
		tijd = localtime(&secs);
		strftime(tm_now, 39, "%b %d %Y at %H:%M", tijd);
		
		sprintf (&Sbuffer[strlen (Sbuffer)], 
			"\n\01Via IOSTrackMsg at %u:%u/%u.%u, %s", 
			alias[c].zone, alias[c].net,
			alias[c].node, alias[c].point, tm_now);

		memcpy (&Shdr, Hdr, sizeof (MSGHEADER));
		
		Shdr.Dzone = Hdr->Ozone;
		Shdr.Dnet  = Hdr->Onet;
		Shdr.Dnode = Hdr->Onode;
		Shdr.Dpoint= Hdr->Opoint;
		
		Shdr.Ozone = alias[c].zone;
		Shdr.Onet  = alias[c].net;
		Shdr.Onode = alias[c].node;
		Shdr.Opoint= alias[c].point;
		
		Shdr.size = (UWORD) strlen (Tbuffer);
		
		strcpy (Shdr.to, Shdr.from);
		strcpy (Shdr.from, SysOp);
		strcpy (Shdr.topic, "Unadressable message.");
		
		Shdr.flags &=~ (ALLBITS);
		
		Shdr.flags |= (PRIVATE|SENT);
		
		if (CHECKlist (&Shdr) == FALSE)
			pack_netmail (&Shdr, Sbuffer);
		else
			log_line (6, "=Origin node not in the nodelist.");
		
		free (Sbuffer);
		
	}
	else {
		log_line (6, "-No output file specified for MSGtrack.");
	}
	/*
	**	Mark message as deleted.
	*/
	return (TRUE);
}

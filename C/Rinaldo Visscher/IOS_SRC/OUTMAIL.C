/*********************************************************************

					IOS - routing manager
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991

	Scan netmail and route the mail bundled or unpacked to the
	connected systems. Check the routing .
***********************************************************************/

/*#define TESTCASE	1*/

#include		<tos.h>
#include		<stdio.h>
#include		<time.h>
#include		<ctype.h>
#include		<ext.h>
#include		<string.h>
#include		<stdlib.h>
#include		<process.h>
#include		<errno.h>

#include		"portab.h"
#include		"defs.h"
#include		"ioslib.h"
#include		"modules.h"
#include		"routing.h"

#include		"inmail.h"
#include		"strutil.h"
#include		"lang.h"

#include		"vars.h"

#define PACKMAIL	0
#define LEAVEPKT	1
#define HIGH_POINT	960

BOOLEAN	get_gateway(MSGHEADER *hdr, BYTE *msg);
VOID	prepare_poll(VOID);
VOID	put_hold(BYTE *name, UWORD usedzone, BYTE *dir, WORD what, BYTE Pkt);
VOID	hold_to_poll(WORD what);
VOID	arc_PKTS(BYTE what);
VOID	crunch_it(BYTE *packet, BYTE do_it, LONG size);
VOID 	create_pollPKT(BYTE *dir, UWORD zone, UWORD net, UWORD node, UWORD point);
BYTE	check_hold_poll (BYTE *file, BYTE Pkt);

/*
**	Pack netmail that is for an known node.
*/

VOID pack_netmail(MSGHEADER *hdr, BYTE *msgtext)
{
	WORD		i,
				havekey,
				retcode;
	UWORD		dpoint=0, opoint=0, fakenet,
				zone, net, node, point,
				j;
	BYTE		used_intl = TYPE4d,
				intl_ever = FALSE,
				*newmsg,
				domain[10];
	
	hprintf (S_COMMENT, "Packing NETMAIL");
	
	/*
	**	Crash on this node?
	*/
	
	if (crashOk(hdr->Dzone, hdr->Dnet, hdr->Dnode))
		hdr->flags |= CRASH;
	
	/*
	**	If destination is found, break the loop.
	**	Seek destanation is one of out points.
	*/
	
	found_an_gateway:
	
	/*
	**	If we have a message to the gateway then start again
	*/
	
	for (i=0; i < nkey; i++)
		if (hdr->Dzone == pwd[i].zone &&
			hdr->Dnet == pwd[i].net &&
			hdr->Dnode == pwd[i].node &&
			hdr->Dpoint == pwd[i].point )
		{
			used_intl = pwd[i].intl_type;
			intl_ever = pwd[i].intl_always;
			
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">Found destination %u:%u/%u.%u '%s'", pwd[i].zone, pwd[i].net, pwd[i].node, pwd[i].point, pwd[i].pwd);
#endif
			havekey = i;
			break;
		}
	
	/*
	**	Destination not found, look if this message is to us.
	*/
	
	if (i >= nkey)
	{
		for (i=0; i < nalias; i++)
		{
			if (hdr->Dzone == alias[i].zone &&
				hdr->Dnet == alias[i].net &&
				hdr->Dnode == alias[i].node &&
				hdr->Dpoint == alias[i].point)
			{
				/*
				**	This message is to us.
				*/
				
#if defined OUTDEBUG
				if (dooutdeb) log_line(6,">Destination is %u:%u/%u.%u", hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Dpoint);
#endif				
				if (!stricmp(hdr->to, "gateway"))
				{
					if (!get_gateway(hdr, msgtext)) return;
					goto found_an_gateway;
				}
				
				return;
			}
		}
		
		/*
		**	Message not for us. Seek message is for 1 of our nodes.
		*/
		
		for (i=0; i < nkey; i++)
			if (hdr->Dzone == pwd[i].zone &&
				hdr->Dnet == pwd[i].net &&
				hdr->Dnode == pwd[i].node)
			{
				if (hdr->Dpoint && !hdr->Opoint && hdr->flags & MSGLOCAL) {
					for (j=0; j < nalias; j++) {
						if (hdr->Dzone == alias[j].zone &&
							hdr->Dnet  == alias[j].net &&
							hdr->Dnode == alias[j].node) {
							log_line(6, Logmessage[M__POINT_NOT_SYSTEM], hdr->Dpoint);
							return;
						}
					}
				}
				used_intl = pwd[i].intl_type;
				intl_ever = pwd[i].intl_always;
				
#if defined OUTDEBUG
				if (dooutdeb) log_line(6,">Found destination %u:%u/%u.%u '%s'", pwd[i].zone, pwd[i].net, pwd[i].node, pwd[i].point, pwd[i].pwd);
#endif
				havekey = i;
				break;
			}
		
		/*
		**	Message not for one of our nodes. Find routing.
		*/
		
		if (i >= nkey)
		{
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">Destination not in password");
#endif	
			/*
			**	This message is not to one of our known
			**	nodes, and not to us. Find routing.
			*/
			
			if (hdr->flags & FILEATCH) attached_file(hdr);
			
			find_ROUTE(hdr, msgtext);
			
			return;
		}
	}
	
	/*
	**	Als bestemmengs node in de password regels staat en het
	**	bericht is niet gecrashed, dan moet het niet direct naar
	**	die node verzonden worden, maar via de host.
	*/
	
	if (!(hdr->flags & CRASH) && havekey < nkey) {
		if (pwd[havekey].crash_to == AT_CRASH) {
			if (hdr->flags & FILEATCH) attached_file (hdr);
			find_ROUTE (hdr, msgtext);
			return;
		}
	}
	
	/*
	**	Message has file attached. Output it.
	*/
	
	if (hdr->flags & FILEATCH) attached_file(hdr);
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Alloc newmsg (Out)");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
	
	newmsg = (BYTE *) myalloc(MAXMSGLENGTH);
	*newmsg = EOS;
	
	/*
	**	AREA: regel in het bericht. Moet in de area geplaatst worden.
	*/
	
	if (strncmp(msgtext, "AREA:",5))
	{
#if defined OUTDEBUG
		if (dooutdeb) log_line(6,">Origin zone %u - Destination %u", hdr->Ozone, hdr->Dzone);
#endif

		/*
		**	Plaats een INTL regel als het moet.
		*/
		
		if (hdr->Ozone != hdr->Dzone || intl_ever == TRUE)
		
		/*
		**	3D INTL regel ?
		*/
		
			if (used_intl == TYPE3d && hdr->Dpoint)
			{
				for (i=0; i < nalias; i++)
					if (alias[i].zone == hdr->Dzone &&
						alias[i].net == hdr->Dnet &&
						alias[i].node== hdr->Dnode)
					{
						fakenet = alias[i].pointnet;
#if defined OUTDEBUG
						if (dooutdeb) log_line(6,">Destination fakeaddress is %u/%u", fakenet, hdr->Dpoint);
#endif
						break;
					}
				
				/*
				**	Point niet gevonden, ga naar 4D INTL regel.
				**	
				*/
				
				if (i >= nalias) goto INTL_4d;
				
				/*
				** Schrijf 3D INTL regel weg in buffer.
				*/
				
				if (!hdr->Opoint && hdr->Dpoint) {
					sprintf (newmsg, "\01INTL%u:%u/%u %u:%u/%u\n",
						hdr->Dzone, fakenet, hdr->Dpoint,
						hdr->Ozone, hdr->Onet, hdr->Onode);
				} else if (hdr->Dpoint && hdr->Opoint) {
					sprintf (newmsg, "\01INTL%u:%u/%u %u:%u/%u\n",
						hdr->Dzone, fakenet, hdr->Dpoint,
						hdr->Ozone, fakenet, hdr->Opoint);
				} else if (!hdr->Dpoint && hdr->Opoint) {
					sprintf (newmsg, "\01INTL%u:%u/%u %u:%u/%u\n",
						hdr->Dzone, hdr->Dnet, hdr->Dnode,
						hdr->Ozone, fakenet, hdr->Opoint);
				} else {
					goto INTL_4d;
				}
				
			}
			else
			{
				/*
				**	4D INTL regel maken.
				*/
				
				INTL_4d:
				
				used_intl = TYPE4d;
				
				sprintf(newmsg, "\01INTL %u:%u/%u %u:%u/%u\n",
					hdr->Dzone, hdr->Dnet, hdr->Dnode, hdr->Ozone,
					hdr->Onet, hdr->Onode);
			}
		
		/*
		**	Als point, dan moet er een TOPT regel bij.
		*/
		
		if (hdr->Dpoint && used_intl == TYPE4d)
		{
#if defined OUTDEBUG
				if (dooutdeb) log_line(6,">Adding TOPT %u", hdr->Dpoint);
#endif
				sprintf(&newmsg[strlen(newmsg)], "\01TOPT %u\n", hdr->Dpoint);
				dpoint = hdr->Dpoint;
		}
		
		/*
		**	En ook een FMPT regel als het moet.
		*/
		
		if (hdr->Opoint && used_intl == TYPE4d)
		{
#if defined OUTDEBUG
			if (dooutdeb) log_line(6,">Adding FMPT %u", hdr->Opoint);
#endif				
			sprintf(&newmsg[strlen(newmsg)], "\01FMPT %u\n", hdr->Opoint);
			opoint = hdr->Opoint;
		}
	}
	
	/*
	**	Einde van AREA: regel afvraag routine.
	*/
	
	/*
	**	Bericht te groot, breek af.
	*/
	
	if ((strlen(newmsg) + strlen(msgtext)) >= MAXMSGLENGTH -1)
	{
		log_line(4,Logmessage[M__NETMAIL_MSG_TO_BIG]);
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Free newmsg (Out)");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
		free(newmsg);
		return;
	}
	
	strcat(newmsg, msgtext);
	
	/*
	**	Zoek eventuele zone nummer uit dat gebruikt gaat worden in
	**	de Via regel.
	*/
	
	for (i=0; i < nalias; i++)
		if (hdr->Ozone == alias[i].zone &&
			hdr->Onet == alias[i].net &&
			hdr->Onode == alias[i].node) break;
	
	if (i >= nalias)
	{
		for (i=0; i < nalias; i++)
			if (hdr->Ozone == alias[i].zone) break;
		
		if(i>=nalias) i=0;
	}

#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Using Via %u:%u/%u.%u i = %d", alias[i].zone, alias[i].net, alias[i].node, alias[i].point, i);
#endif
	
	/*
	**	Verkrijg huidige tijd.
	*/
	
	time(&secs);
	tijd = localtime(&secs);
	strftime(tm_now, 39, "%b %d %Y at %H:%M", tijd);
	
	OutMail[0] = 'O';
	
	/*
	**	Als er geen AREA: regel instaat, plaats Via regel.
	*/
	
	if (strncmp(msgtext, "AREA:", 5)) sprintf(&newmsg[strlen(newmsg)],
		"\n\01Via %s %u:%u/%u.%u, %s\n", OutMail, alias[i].zone, alias[i].net,
		alias[i].node, alias[i].point, tm_now);
		
	zone	=	hdr->Dzone;
	net	=	hdr->Dnet;
	node	=	hdr->Dnode;
	point	=	hdr->Dpoint;
	
	/*
	**	Als niet gecrashed,
	*/
	
	if (!(hdr->flags & CRASH)) {
	/*
	**	en de key regel is niet gevonden, zoek de routing uit.
	*/
	
		if (havekey >= nkey)
		{
			retcode = routeOk(hdr);
			
			if (retcode != -1) address(RouteDef[retcode].destnode,
				&zone, &net, &node, &point, &j, domain);
		}
		else
		{
			zone	=	pwd[havekey].zone;
			net	=	pwd[havekey].net;
			node	=	pwd[havekey].node;
			point	=	pwd[havekey].point;
		}
	}
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Save message to %u:%u/%u.%u", zone, net, node, point);
#endif
	
	savemsg(NETMAILPACKET, hdr, -1, newmsg, zone, net, node, point);
	
	if (hdr->flags & KILLSEND)
		hdr->flags |= DELETED;
	else
		hdr->flags |= SENT;

/*	
	if (opoint) hdr->Opoint = opoint;
	if (dpoint) hdr->Dpoint = dpoint;
*/
	
	nechos++;
	
	hprintf(S_EXP, "%d", nechos);
	
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Free newmsg (Out)");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
	
	free(newmsg);
}

VOID pack_mail(VOID)
{
	UWORD	zone, net, node, point;
	WORD	i;
	BYTE	Mfile[128], Hfile[128],
			areabuf[128],
			*msgbuf, *p, *q,
			buffer[100];
	LONG	tell;
	
	if (donopack) arc_PKTS(PACKMAIL);
	
	hprintf(S_AREA, "NETMAIL");
	
	log_line(3,Logmessage[M__NETMAIL_READ]);
	
	init_PKTS();
	
	sprintf(Mfile, "%s.MSG", mailarea);
	sprintf(Hfile, "%s.HDR", mailarea);
	
	if ((FHDR = fopen(Hfile, "r+b")) == NULL)
	{
		log_line(6,Logmessage[M__CANT_OPEN_NETMAIL]);
		return;
	}
	
	hprintf (S_COMMENT, "Scanning NETMAIL");
	
	while (!feof(FHDR))
	{
		hdrread(&hdr, sizeof(MSGHEADER), FHDR);
		
		if (feof(FHDR)) break;
		if (!(hdr.flags & MSGLOCAL) || hdr.flags & DELETED || hdr.flags & SENT)
			continue;
		
		if ((tell = ftell(FHDR)) < sizeof(MSGHEADER))
		{
			if (tell > 0L)
				log_line(6,Logmessage[M__FILE_PROBLEM], tell);
			
			break;
		}
		
		if (hdr.flags & KILLSEND)
			hdr.flags |= DELETED;
		else
			hdr.flags |= SENT;
		
		if ((FMSG = fopen(Mfile, "rb")) != NULL)
		{
			fseek(FMSG, hdr.Mstart, SEEK_SET);
			
			if (ferror(FMSG))
			{
				log_line(6,Logmessage[M__SEEK_ERROR]);
				fclose(FMSG);
				continue;
			}
						
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Alloc msgbuf (Out)");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
			msgbuf = (BYTE *) myalloc(MAXMSGLENGTH);
			msgread(msgbuf, hdr.size, FMSG);
			fclose(FMSG);
			
			check_HDR();
			
#if !defined TESTCASE
			fseek(FHDR, ftell(FHDR) - sizeof(MSGHEADER), SEEK_SET);
			hdrwrite(&hdr, sizeof(MSGHEADER), FHDR);
			fflush(FHDR);
#endif

			hdr.flags &= ~(DELETED); 

			hprintf(S_DEST, "%u:%u/%u.%u", hdr.Dzone, hdr.Dnet,
				hdr.Dnode, hdr.Dpoint);
			hprintf(S_FROM, "%u:%u/%u.%u", hdr.Ozone, hdr.Onet,
				hdr.Onode, hdr.Opoint);
			
			log_line(3,"*%-20.20s (%u:%u/%u.%u) > %-20.20s (%u:%u/%u.%u)",
				hdr.from, hdr.Ozone, hdr.Onet, hdr.Onode, hdr.Opoint,
				hdr.to, hdr.Dzone, hdr.Dnet, hdr.Dnode, hdr.Dpoint);
			
			i = 0;
					
			if (!strncmp(msgbuf, "AREA:",5))
			{
				p = msgbuf;
				while (*p && !isspace(*p)) areabuf[i++] = *p++;
				areabuf[i] = EOS;
				msgbuf = strip_line(msgbuf, "AREA:");
				if ((p = strline (msgbuf, "--- ")) != NULL) {
					q = skip_to_token (p, '\n');
					--q;
					if (q) {
						strncpy (TEAR_buffer, q, 511);
						strcpy (q, " [IOS ");
						strcpy (buffer, &ScanMail[strlen (ScanMail) - 5]);
						strcat (q, buffer);
						strcat (q, "]");
						strcat (q, TEAR_buffer);
					}
				}
			}
			else
			{
				if (dostripPID)
					msgbuf = strip_line(msgbuf, "\01PID:");
			}
			
			/*
			**	Change MSGID.
			*/
			
			if (get_msgid(msgbuf, &zone, &net, &node, &point) &&
				zone != hdr.Ozone && net != hdr.Onet && node != hdr.Onode)
				msgbuf = change_msgid(msgbuf, &hdr);
			
			if (i) msgbuf = add_a_line(areabuf, "", msgbuf);
			
			pack_netmail(&hdr, msgbuf);
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Free msgbuf (Out)");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
			
			free(msgbuf);
		}
	}
	
	fclose(FHDR);
	
	close_PKTS();
	arc_PKTS(donopack);
	
	hold_to_poll(HOLDPOLL);
	hold_to_poll(HOLDMAX);
	hold_to_poll(HOLDDEL);
	prepare_poll();
	
	return;
}

VOID arc_PKTS(BYTE what)
{
	struct ffblk	blk;
	BYTE			buffer[128],
					Mail[4];
	WORD			i;
	
	log_line(4,Logmessage[M__ARC_PACKETS]);

	sprintf(buffer, "%s*.???", mailtemp);
	strcpy (Mail, "HNC");
	
	for (i = 0; i < 3; i++) {
	
		/*instal_s_scr();*/
		
		buffer [ (WORD) strlen (buffer) - 1] = Mail[i];
		
		if (!findfirst(buffer, &blk, 0))
		{
			crunch_it(blk.ff_name, what, blk.ff_fsize);
			
			while (!findnext(&blk))
				crunch_it(blk.ff_name, what, blk.ff_fsize);
		}
		
		/*end_screen();*/
	}
}

VOID crunch_it(BYTE *packet, BYTE do_it, LONG size)
{
	BYTE		buffer[256],
				folder[128],
				fname[128],
				dummy[128],
				program[128],
				cmds[256],
				temp[128],
				mailtype,
				arctype,
				testarc,
				*p, *q,
				*currentfolder,
				*COPYbuf,
				domain[10];
	WORD		i, x,
				ret;
	UWORD		j,
				zone, net, node, point,
				t_zone, t_net, t_node, t_point,
				netdiff,nodediff,
				pointnet = 0;
	LONG		secs_now;
	BOOLEAN		hold,
					Set_old_BT=FALSE;
					
	struct ffblk blk;
	
#if defined OUTDEBUG
	log_line(6,">Arc packet %s", packet);
#endif
	
	strcpy(buffer, packet);
	
	hprintf (S_COMMENT, "Bundling packets");
	
	if ((p = strchr(buffer, '.')) != NULL)
	{
		mailtype = p[3];
		p[3] = EOS;
	}
	
	/*
	**	Check for PKT files
	*/
	
	if (mailtype == 'T') return;
	
	if (minpktsize && mailtype != 'C' && size < minpktsize)
	{
		log_line(3,Logmessage[M__PACKET_TO_SMALL]);
		return;
	}
	
	if ((i = (WORD)strlen(buffer)) != 11)
	{
		log_line(4,Logmessage[M__FILENAME_PROBLEM]);
		return;
	}

/*	
	get4Daddress(buffer, &zone, &net, &node, &point);
*/

/*
**	Lees de packetheader voor de bestemming. De filenaam methode is
**	onbetrouwbaar, in zoverre dat hoge nummers niet kunnen worden
**	weergegeven.
*/

	sprintf (fname, "%s%s%c", mailtemp, buffer, mailtype);
	
	if ((FDUMMY = fopen (fname, "rb")) == NULL) {
		log_line (6, "+Can't open packet.");
		terminate (10);
	}
	
	
	fread (&phdr, sizeof (struct _pkthdr), 1, FDUMMY);
	fclose (FDUMMY);

	if ((i= intel(phdr.ph_rate)) == TYPE2_2) {
		memcpy(&phdr2, &phdr, sizeof(struct _phdr2));
		memset(&phdr, 0, sizeof(struct _pkthdr));
		
		zone = intel (phdr2.ph_dzone);
		net  = intel (phdr2.ph_dnet);
		node = intel (phdr2.ph_dnode);
		point= intel (phdr2.ph_dpoint);
	} else if (intel(phdr.ph_capable) == phdr.ph_CWcopy &&
			phdr.ph_capable && intel(phdr.ph_capable) & TYPE2PLUS) {
		
		zone = intel (phdr.ph_dzone);
		net  = intel (phdr.ph_dnet);
		node = intel (phdr.ph_dnode);
		point= intel (phdr.ph_dpoint);
	} else {
		zone = intel (phdr.ph_qdzone);
		net  = intel (phdr.ph_dnet);
		node = intel (phdr.ph_dnode);
		point= intel (phdr.ph_dpoint);
		for (i = 0; i < nalias; i++) {
			if (net == alias[i].pointnet && zone == alias[i].zone) {
				if (!alias[i].pointnet) {
					log_line (6, "-Can't send 3D packets without an pointnet.");
					return;
				}
				point = node;
				node  = alias[i].node;
				net   = alias[i].net;
				break;
			}
		}
	}		

	hprintf(S_DEST, "%u:%u/%u.%u", zone, net, node, point);
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Getaddress returns %u:%u/%u.%u", zone, net, node, point);
#endif
	
	/*
	**	Check for pointnet.
	*/
	
	for (i=0; i < nalias; i++)
		if (net == alias[i].pointnet)
		{
			t_zone = alias[i].zone;
			t_net = alias[i].net;
			t_node = alias[i].node;
			t_point = node;
			
			break;
		}
	
	if (i >= nalias)
	{
		t_zone = zone;
		t_net = net;
		t_node = node;
		t_point = point;
		
		i = 0;
	}
	
	hprintf (S_FROM, "%u:%u/%u.%u", alias[i].zone, alias[i].net, 
		alias[i].node, alias[i].point);
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Destination %u:%u/%u.%u", t_zone, t_net, t_node, t_point);
#endif	
	
	/*
	**	Verplaats naar ander nodenummer.
	*/
	
	if ( mailtype != 'C' )
		ret = moveOk(t_zone, t_net, t_node, t_point);
	else ret = -1;
	
	if (ret != -1)
	{
		address(RouteDef[ret].destnode, &t_zone, &t_net, &t_node, &t_point, &j, domain);
		log_line(4,Logmessage[M__MSG_MOVED], t_zone, t_net, t_node, t_point);
	}
	
	if (mailtype != 'C')
		hold = holdOk(t_zone, t_net, t_node, t_point);
	else hold = FALSE;
	
	if (mailtype == 'H' && donewbink == TRUE)
		hold = TRUE;
	
	time(&secs_now);
	tijd = localtime(&secs_now);
	
	if (t_point)
	{
		for (i=0; i < nalias; i++)
			if (t_zone == alias[i].zone && t_net == alias[i].net &&
				t_node == alias[i].node)
			{
				zone = alias[i].zone;
				net = alias[i].pointnet;
				node = t_point;
				
				break;
			}
		
		if (i >= nalias)
		{
			for (i=0; i < nkey ; i++) {
				if (t_zone == pwd[i].zone && t_net == pwd[i].net &&
					t_node == pwd[i].node && t_point == pwd[i].point) {
					
					if ( crashPoint(t_zone, t_net, t_node, t_point) == FALSE || donewbink == FALSE) {
						i = nkey;
						break;
					}
					break;
				}
			}
			if (i >= nkey) {
				i = 0;
				log_line(6,Logmessage[M__UNKNOWN_POINT], t_zone, t_net, t_node, t_point);
				t_point = 0;
			}
		}
	}
	else
	{
		zone = t_zone;
		net = t_net;
		node = t_node;
		
		for (i=0; i < nalias; i++)
			if (t_zone == alias[i].zone) break;
		
		if (i >= nalias) i = 0;
	}

	hprintf (S_FROM, "%u:%u/%u.%u", alias[i].zone, alias[i].net, 
		alias[i].node, alias[i].point);
	
	/*
	**	Pack message
	*/
	
	if (arcOk(t_zone, t_net, t_node, t_point) && do_it == PACKMAIL) {

		if(!alias[i].point)  {
			netdiff = alias[i].net - net;
			nodediff= alias[i].node- node;
			pointnet= alias[i].pointnet;
		} else {
			netdiff = alias[i].pointnet - net;
			nodediff= alias[i].node - alias[i].point;
			pointnet= alias[i].pointnet;
		}

		/*
		**	Outbound dir is ....
		*/
		
		currentfolder = outbound_dir(t_zone, t_net, t_node, t_point);
		strcpy(folder, currentfolder);
		
		if ((q = strrchr(folder, '\\')) != NULL) *q = EOS;
		
		/*
		**	Rename to PKT
		*/
		
		sprintf(buffer, "%s%s", mailtemp, packet);
		sprintf(temp, "%02d%02d%02d%02d.PKT", tijd->tm_mday,
			tijd->tm_hour, tijd->tm_min, tijd->tm_sec);
		sprintf(fname, "%s%s", mailtemp, temp);
		
		rename(buffer, fname);
		
		if (folder[strlen(folder)-1] == '\\')
			folder[strlen(folder)-1] = EOS;

/*
**	Als de point een hoger pointnummer heeft dan 960, ga dan naar de
**	oude FLO etc. filenamen.
*/

		if (t_point > HIGH_POINT	&& donewbink == TRUE) {
			donewbink = FALSE;
			Set_old_BT = TRUE;
		}
		
		/*
		**	Get packetname
		*/
		
		if(donewbink == TRUE && dothebox == TRUE) {
			log_line(3,Logmessage[M__MORE_MAILERS]);
			dothebox = FALSE;
		}
		
		if(donewbink == TRUE || dothebox == TRUE) {
			if(donewbink) 
				xsprintf(buffer, "%s\\%03z%03z%02z.", folder, t_net, t_node, t_point);
			else {
				if (t_point) {
					for (i = 0; i < nalias; i++) {
						if (t_zone == alias[i].zone && t_net == alias[i].net &&
							t_node == alias[i].node) {
								if (!alias[i].pointnet) {
									log_line (6, "-Can't send. No pointnet.");
									return;
								}
								net = alias[i].pointnet;
								node= t_point;
								break;
						}
					}
				}
				xsprintf(buffer, "%s\\%02z%03z%03z.", folder, zone, net, node);
			}
			if (hold) {
				if (check_hold_poll(buffer, ARC_PKTS) == FAILURE) {
					strcat (buffer,(donewbink == TRUE) ? "HAT" : "HA");
				} else {
					strcat (buffer,(donewbink == TRUE) ? "OAT" : "NA");
				}
			}
			else {
				if (mailtype == 'C')
					strcat(buffer, (donewbink == TRUE) ? "CAT" : "CA");
				else
					strcat(buffer, (donewbink == TRUE) ? "OAT" : "NA");
			}
		}
		else 
			sprintf(buffer, "%s\\%04x%04x.%s0",folder,
			netdiff, nodediff, isuf[tijd->tm_wday]);
			
		strcpy(dummy, buffer);
		
#if defined OUTDEBUG
		if (dooutdeb) log_line(6,">File: %s", dummy);
#endif
		
		sprintf(&buffer[strlen(buffer)], " %s", fname);
		
		/*
		**	ARC-Typ for this system
		*/
				
		arctype = isUNKNOWN;
		
		for (j=0; j < nkey; j++)
			if (t_zone == pwd[j].zone && t_net == pwd[j].net &&
				t_node == pwd[j].node && t_point == pwd[j].point)
			{
				arctype = pwd[j].arctype;
				break;
			}
		
		if (j >= nkey) arctype = isUNKNOWN;
		
		/*
		**	Check al aanwezige packets voor veranderingen.
		*/
		
		if (!findfirst(dummy, &blk, 0))
		{
			testarc = ARCtype(dummy);
			
			if (testarc != arctype)
			{
				log_line(3,Logmessage[M__PACKER_CHANGED], ArcMail[testarc], ArcMail[arctype]);
				log_line(3,Logmessage[M__TAKE_OLD]);
				
				arctype = testarc;
			}
		}
		
		switch (arctype)
		{
			case isLZHmail:
			
				if (strlen(Lzh))
				{
					strcpy(program, Lzh);
					
					if (strlen(LzheA)) strcpy(cmds,LzheA);
					else strcpy(cmds, "a");
				}
				else
				{
					log_line(5,Logmessage[M__NO_PACKER_SPEC], "LZH");
					goto Default_archive;
				}
				
				break;
				
			case isARCmail:
			
				if (strlen(Arc))
				{
					strcpy(program, Arc);
					
					if (strlen(ArceA)) strcpy(cmds,ArceA);
					else strcpy(cmds, "a");
				}
				else
				{
					log_line(5,Logmessage[M__NO_PACKER_SPEC], "ARC");
					goto Default_archive;
				}
				
				break;
				
			case isZIPmail:
			
				if (strlen(Zip))
				{
					strcpy(program, Zip);
					
					if(strlen(ZipeA)) strcpy(cmds,ZipeA);
					else strcpy(cmds, "-a");
				}
				else
				{
					log_line(5,Logmessage[M__NO_PACKER_SPEC], "ZIP");
					goto Default_archive;
				}
				
				break;
				
			case isARJmail:
			
				if (strlen(Arj))
				{
					strcpy(program, Arj);
					
					if (strlen(ArjeA)) strcpy(cmds, ArjeA);
					else strcpy(cmds, "a");
				}
				else
				{
					log_line(5,Logmessage[M__NO_PACKER_SPEC], "ARJ");
					goto Default_archive;
				}
				
				break;
				
			case isUNKNOWN:
			
				Default_archive:
				
				if (strlen(Arch))
				{
					strcpy(program, Arch);
					
					if (strlen(Archcmdo)) strcpy(cmds,Archcmdo);
					else strcpy(cmds, "a");
				}
				else log_line(5,Logmessage[M__NO_PACKER_SPEC], "");
				
				break;
				
			default:
			
				log_line(4,Logmessage[M__UNKNOWN_ERROR]);
				break;
		}
		
		sprintf(&cmds[strlen(cmds)], " %s", buffer);

		printf("\033Y%c%c\033J\033Y%c%c", S_START+' ', ' ', S_START+' ', ' ');
		
		LOG_line = S_START + 1;
		
		log_line(3,Logmessage[M__SEND_MAIL], t_zone, t_net, t_node,
			t_point, ArcMail[arctype], (hold) ? "Hold" : "Poll");
		
		/*
		**	Run arc program
		*/
				
		x = exec(program, cmds, "", &i);

		printf("\033Y%c%c\033J\033Y%c%c", S_START+' ', ' ', S_START+' ', ' ');
		
		LOG_line = S_START + 1;
		
		if (i) log_line(6,Logmessage[M__RETURNS_ERRORCODE], i);
		
		if (x != FAILURE)
		{
			if (findfirst(dummy, &blk, 0) || i)
			{
				log_line(6,Logmessage[M__PACKET_NOT_ARCED]);
				sprintf(dummy, "%s%s", mailtemp, temp);
			}
			else {
				
				sprintf(buffer, "%s%s", mailtemp, temp);
				unlink(buffer);
				
				if (Set_old_BT == TRUE)
					donewbink = Set_old_BT;
				
				if(donewbink == TRUE || dothebox == TRUE) {
					return;
				}
			}
		}
		else
		{
			log_line(6,Logmessage[M__CANT_EXEC_PRG], program);
			strcpy (packet, temp);
			goto unbundled;
			/*
			sprintf(dummy, "%s\\%s", mailtemp, temp);
			*/
		}
		
		if(t_point ) {
			for (i = 0; i< nalias; i++) {
				if (alias[i].zone == t_zone &&
					alias[i].net  == t_net &&
					alias[i].node == t_node) {
						if (!alias[i].point) {
							if (!alias[i].pointnet) {
								log_line (6, "-Can't send. Pointnet unknown.");
								if (Set_old_BT == TRUE)
									donewbink = Set_old_BT;
								return;
							}
							sprintf(buffer,"%s\\%04x%04x.",folder,
							alias[i].pointnet,t_point);
						}
						else
							sprintf(buffer,"%s\\%04x%04x.",folder,
							t_net,t_node);
						break;
				}
			}
			if (i >= nalias) 
				sprintf(buffer,"%s\\%04x%04x.",folder,t_net,t_node);
		}
		else
			sprintf(buffer,"%s\\%04x%04x.",folder,t_net,t_node);
			
		if(hold) {
			strcat(buffer,"HLO");
		} else {
			if(mailtype == 'C') {
				strcat(buffer,"CLO");
			} else {
				strcat(buffer,"FLO");
			}
		}
		
		if((PACKET = fopen(buffer,"r+")) == NULL) {
			if((PACKET = fopen(buffer,"w")) == NULL) {
				log_line(6,Logmessage[M__CANT_CREATE_POLL]);
				return;
			}
		} else {
			while(fgets(temp,128,PACKET)) {
				if(!strncmp(&temp[1],dummy,(int)strlen(dummy))) {
					fclose(PACKET);
					return;
				}
			}
		}
		fseek(PACKET,0L,SEEK_END);
		fprintf(PACKET,"^%s ; Packet for %u:%u/%u.%u\n",dummy,
		t_zone,t_net,t_node,t_point);
		fclose(PACKET);
		if (Set_old_BT == TRUE)
			donewbink = Set_old_BT;
		return;
	}
	
	/*	
	**	buffer = <mailtempdir><filename>.<NM..>
	**	dummy  = <filename>.<OPT..>
	**	temp   = <outbounddir><filename>.<OPT..>
	*/
	
	unbundled:
	
	hprintf (S_COMMENT, "Send unbundled packet.");
	
	if (t_point > HIGH_POINT && donewbink == TRUE) {
		donewbink = FALSE;
		Set_old_BT = TRUE;
	}
	
	if(donewbink == TRUE) {
		sprintf(buffer, "%s%s", mailtemp, packet);
		xsprintf(dummy, "%03z%03z%02z.", t_net, t_node, t_point);
		sprintf(temp, "%s%s", outbound, dummy);
	} else {
		sprintf(buffer,"%s%s",mailtemp,packet);
		if (!t_point) {
			sprintf(dummy,"%04x%04x.",t_net,t_node);
		} else {
			for (i=0; i <nalias; i++) {
				if (alias[i].zone == t_zone &&
					alias[i].net  == t_net  &&
					alias[i].node == t_node) {
						if (!alias[i].point) {
							if (!alias[i].pointnet) {
								log_line (6, "-Can't send. Pointnet unknown.");
								if (Set_old_BT == TRUE);
									donewbink = Set_old_BT;
								return;
							}
							sprintf(dummy,"%04x%04x.", alias[i].pointnet,
							t_point);
						}
						else
							sprintf(buffer,"%s\\%04x%04x.",folder,
							t_net,t_node);
						break;
					
				}
			}
			if (i >= nalias)
				sprintf(buffer,"%s\\%04x%04x.",folder,t_net,t_node);
		}
		sprintf(temp,"%s%s",outbound,dummy);
	}

	
	if (hold)
	{
		if(donewbink == TRUE) {
			strcat(temp, "HPT");
			strcat(dummy, "HPT");
		} else {
			strcat(temp, "HUT");
			strcat(dummy,"HUT");
		}
	}
	else
	{
		if (mailtype == 'C')
		{
			if(donewbink == TRUE) {
				strcat(temp, "CPT");
				strcat(dummy, "CPT");
			} else {
				strcat(temp, "CUT");
				strcat(dummy, "CUT");
			}
		}
		else
		{
			if(donewbink == TRUE) {
				strcat(temp,"OPT");
				strcat(dummy, "OPT");
			} else {
				strcat(temp, "OUT");
				strcat(dummy, "OUT");
			}
		}
	}
	
	/*
	**	p = Domain folder + filename.
	*/
	
	p = outbound_dir(t_zone, t_net, t_node, t_point);
	q = strrchr(p, '\\');
	
	if (q)
	{
		sprintf(++q, "%s", dummy);
		strcpy(dummy, p);
	}
	else
		sprintf(dummy, "%s%s", outbound, dummy);

	if (hold) {
		strcpy (temp, dummy);
		q = strrchr (temp, '.');
		
		if (q) {
			*++q = EOS;
			if (check_hold_poll (temp, NORM_PKTS) == SUCCESS) {
				q = strrchr (dummy, '.');
				strcpy (++q, "OFT");
			}
		}
	}
	
	log_line(4,Logmessage[M__SEND_UNPACKED], t_zone, t_net, t_node, t_point);
	
	findfirst (buffer, &blk, 0);
	
	if ((PACKET = fopen(buffer, "r+b")) != NULL)
	{
		if ((MMSG = fopen(dummy, "r+b")) == NULL)
		{
			if ((MMSG = fopen(dummy, "wb")) == NULL)
			{
				log_line(4,Logmessage[M__CANT_MOVE_PKT]);
				
				fclose(PACKET);
				free(p);
				if (Set_old_BT == TRUE)
					donewbink = Set_old_BT;
				return;
			}
		}
		else
		{
			/*
			**	If already exist, append mail.
			*/
			
			fseek(PACKET, (LONG)sizeof(struct _pkthdr), SEEK_SET);
			fseek(MMSG, 0L, SEEK_END);
			fseek(MMSG, ftell(MMSG) - 2L, SEEK_SET);
		}
		
		/*
		**	Check size of file, fits in memory ?
		*/
		
		COPYbuf = (BYTE *) myalloc (blk.ff_fsize + 10);
		
		j = 0;
		
		/*
		**	Copy packet to current dir.
		*/
		
		if (!COPYbuf) {
			while (!feof(PACKET))
			{
				i = fgetc(PACKET);
				if (feof(PACKET)) break;
				
				if ((j = ferror(PACKET)) != 0)
				{
					log_line(6,Logmessage[M__READ_ERROR], errno);
					break;
				}
				
				putc(i, MMSG);
				
				if ((j = ferror(MMSG)) != 0) w_error("copying packet");
			}
		} else {
			fread (COPYbuf, blk.ff_fsize, 1, PACKET);
			fwrite(COPYbuf, blk.ff_fsize, 1, MMSG);
			
			free (COPYbuf);
		}
		
		fclose(PACKET);
		fclose(MMSG);
		
		if (!j) unlink(buffer);
		
		free(p);
		if (Set_old_BT == TRUE)
			donewbink = Set_old_BT;
		return;
	}
	if (Set_old_BT == TRUE)
		donewbink = Set_old_BT;
}

BOOLEAN get_gateway(MSGHEADER *hdr, BYTE *msg)
{
	WORD	i;
	UWORD	zone, net, node, point,
			wzone, wnet, wnode, wpoint,
			j;
	BYTE	*p, *q, *a,
			*gatename = strline(msg, "&To:"),
			temp[100],
			wasfrom[40],
			newname[40],
			domain[10],
			*newmsg;
	
	if (!gatename)
	{
		hdr->flags |= SENT;
		return(FALSE);
	}
	
	p = gatename;
	
	for (q = temp; *p && *p != '\n'; *q++ = *p++);
	*q = EOS;
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Temp has %s", temp);
#endif
	
	for (q = temp, i=0; i < 4; i++) q++;
	q = skip_blanks(q);
	
	if (!*q)
	{
		hdr->flags |= SENT;
		return(FALSE);
	}
	
	for (a = newname; *q && *q != '@'; *a++ = *q++);
	*a = EOS;
	
#if defined OUTDEBUG
	if (dooutdeb) log_line(6,">Newname %s", newname);
#endif
	
	if (!*q)
	{
		hdr->flags |= SENT;
		return(FALSE);
	}
	
	q = skip_blanks(++q);
	
	if (!*q)
	{
		hdr->flags |= SENT;
		return(FALSE);
	}
	
	address(q, &zone, &net, &node, &point, &j, domain);
	
	log_line(4,Logmessage[M__GATEWAY_MSG], newname, zone, net, node, point);

	strcpy(wasfrom, hdr->from);
	
	wzone = hdr->Ozone;
	wnet = hdr->Onet;
	wnode = hdr->Onode;
	wpoint = hdr->Opoint;
	
	for (i=0; i < nalias; i++)
		if (zone == alias[i].zone)
		{
			hdr->Ozone = alias[i].zone;
			hdr->Onet = alias[i].net;
			hdr->Onode = alias[i].node;
			hdr->Opoint = alias[i].point;
			
			break;
		}
	
	if (i >= nalias)
	{
		log_line(3,Logmessage[M__NO_GATEWAY], zone);
		hdr->flags |= SENT;
		return(FALSE);
	}
	
	strcpy(hdr->from, "GateWay");
	strcpy(hdr->to, newname);
	
	sprintf(temp, "%u:%u/%u", hdr->Dzone, hdr->Dnet, hdr->Dnode);
	
	hdr->Dzone = zone;
	hdr->Dnet = net;
	hdr->Dnode = node;
	hdr->Dpoint = point;
	
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Alloc newmsg (Out gate)");
			log_line(6,">Memory %ld", coreleft());
		}
#endif

	newmsg = (BYTE *) myalloc(MAXMSGLENGTH);
	
	sprintf(newmsg, "&From: %s@%u:%u/%u.%u\n", wasfrom, wzone, wnet, wnode, wpoint);
	
	if ((strlen(newmsg) + strlen(msg)) > (MAXMSGLENGTH - 100))
	{
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Free newmsg (Out gate)");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
		free(newmsg);
		
		log_line(5,Logmessage[M__MSG_TO_BIG]);
		
		hdr->flags |= SENT;
		return(FALSE);
	}
	
	strcat(newmsg, msg);
	
	time(&secs);
	tijd = localtime(&secs);
	strftime(tm_now, 39, "%b %d %Y at %H:%M", tijd);
	
	OutMail[0] = 'O';
	
	sprintf(&newmsg[strlen(newmsg)], "\01Via %s GateWay %s, %s\n",
		OutMail, temp, tm_now);
	
	strcpy(msg, newmsg);
#if defined EXTERNDEBUG
		if (debugflag)
		{
			log_line(6,">Free newmsg (Out gate)");
			log_line(6,">Memory %ld", coreleft());
		}
#endif
	
	free(newmsg);
	return(TRUE);
}

MLOCAL VOID prepare_poll(VOID)
{
	WORD	i, x;
	BYTE	*outdir, *p, SEND_PKT = FALSE,
			domain[10];
	UWORD	zone, net, node, point,
			j;
	
	for (i=0; i < nRouteDef; i++)
	{
		if (RouteDef[i].flags & POLLNODE)
		{
			address(RouteDef[i].destnode, &zone, &net, &node, &point, &j, domain);
			outdir = outbound_dir(zone, net, node, point);
			if ((p = strrchr(outdir, '\\')) == NULL) {
				log_line(6,Logmessage[M__CANT_CREATE_POLL]);
				return;
			}
			
			for (x = 0;x < nkey; x++) {
				if (pwd[x].zone == zone && pwd[x].net == net &&
					pwd[x].node == node && pwd[x].point==point) {
					SEND_PKT = pwd[x]. Send_PKT == TRUE;
					break;
				}
			}
			
			if (dothebox) {
				xsprintf(++p, "%02z%03z%03z.NF",zone,net,node);
			} else if (donewbink == FALSE) {
				sprintf(++p, "%04x%04x.FLO",net,node);
			} else {
				if(dosentpkt || SEND_PKT == TRUE) {
					create_pollPKT(outdir, zone, net, node, point);
					continue;
				}
				else
					strcat(outdir, ".OFT");
			}
			
			if ((FDUMMY = fopen(outdir, "r+")) == NULL)
				if ((FDUMMY = fopen(outdir, "w")) == NULL)
					log_line(6,Logmessage[M__CANT_CREATE_POLL_FILE], zone, net, node, point);
				else
				{
					log_line(3,Logmessage[M__CREATED_POLL], zone, net, node, point);
					fclose(FDUMMY);
				}
			else fclose(FDUMMY);
			
			free(outdir);
		}
	}
}

MLOCAL VOID create_pollPKT(BYTE *dir, UWORD zone, UWORD net, UWORD node, UWORD point)
{
	WORD 	i;
	UWORD	f_zone, f_net, f_node, f_point, f_pnet;
	BYTE 	type = defPKT,
			fname[128],
			pktpwd[10];
	FILE	*fp;
	
	for (i=0; i < nkey; i++) {
		if (zone == pwd[i].zone && net == pwd[i].net &&
			node == pwd[i].node && point == pwd[i].point) {
			
			type = pwd[i].htype;
			strncpy(pktpwd, pwd[i].pwd, 8);
			break;
		}
	}
	
	if (i >= nkey) {
		pktpwd[0] = EOS;
	}
	
	for (i=0; i <nalias; i++) {
		if (zone == alias[i].zone) {
			f_zone = alias[i].zone;
			f_net  = alias[i].net;
			f_node = alias[i].net;
			f_point= alias[i].point;
			f_pnet = alias[i].pointnet;
			break;
		}
	}
	
	if ( i >= nalias) {
		i = 0;
		f_zone = alias[i].zone;
		f_net  = alias[i].net;
		f_node = alias[i].net;
		f_point= alias[i].point;
		f_pnet = alias[i].pointnet;
	}
		
	switch (type)
	{
		case FTS_TYPE:
		
			ftsp_TYPE:
			if (f_point)
				create_pkt_hdr(f_zone, f_pnet, f_point,
					 zone, net, node, pktpwd);
			else
				create_pkt_hdr(f_zone, f_net, f_node,
					 zone, net, node, pktpwd);
			
			break;
			
		/*
		**	Create an packetheader for frontdoor.
		*/
		
		case TYPE_2_1:
		case FRONTDOOR:
		
			create_pkt_fnd(f_zone, f_net, f_node, f_point,
				zone, net, node, point, pktpwd);
			break;

		case TYPE_2_2:	
			create_pkt_2_2(f_zone, f_net, f_node, f_point,
				zone, net, node, point, pktpwd, org_domain, dest_domain);
			break;
		
		default:
		
			log_line(6,Logmessage[M__COMPILER_ERROR]);
			goto ftsp_TYPE;
	}

	strcpy(fname, dir);
	strcat(fname, ".OPT");
	
	if ((fp = fopen(fname, "r+b")) == NULL) {
		if ((fp = fopen(fname, "wb")) == NULL) {
			log_line(6,Logmessage[M__CANT_CREATE_POLL_FILE], zone, net, node, point);
			return;
		}
		fwrite(&phdr, sizeof(struct _pkthdr), 1, fp);
		putc(0, fp);
		putc(0, fp);
	}
	fclose(fp);
	log_line(3,Logmessage[M__CREATED_POLL], zone, net, node, point);
}	
		
MLOCAL VOID put_hold(BYTE *name, UWORD usedzone, BYTE *dir, WORD what, BYTE Pkt)
{
	WORD	i,
			ret;
	UWORD	zone = usedzone,
			net, node, point = 0;
	BYTE	buffer[128],
			buffer1[128],
			temp[80],
			*p;
	LONG	maxsize;
	
	strcpy(temp, name);
	
	p = strrchr(temp, '.');
	if (!p) return;
	*p = EOS;
	
	getBTaddress(temp, &net, &node, &point);
	
	for (i=0; i < nalias; i++)
		if (net == alias[i].pointnet)
		{
			point = node;
			net = alias[i].net;
			node = alias[i].node;
			break;
		}
	
	if ((ret = hold_pollOk(zone, net, node, point, what)) != -1)
	{
		if (what & HOLDPOLL)
			log_line(4,Logmessage[M__HOLD_TO_POLL], zone, net, node, point);
		else
			log_line(4,Logmessage[M__CHECK_SIZE], zone, net, node, point);
		
		strcpy(buffer, dir);
		strcpy(buffer1, dir);
		strcat(buffer, name);
		strcat(buffer1, name);
		
		if (what & HOLDMAX || what & HOLDDEL)
		{
			maxsize = atol(RouteDef[ret].fromnode) * 1024L;
			
			if (!findfirst(buffer, &blok, 0))
			{
				if (blok.ff_fsize < maxsize) return;
				
				if (what & HOLDMAX)
				{
					if (point)
						log_line(6,Logmessage[M__HOLD_TO_POLL_POINT]);
					
					log_line(4,Logmessage[M__CHANGE_TO_POLL]);
				}
				else
				{
					log_line(4,Logmessage[M__DELETE_PACKET], zone, net, node, point);
					unlink(buffer);
					return;
				}
			}
		}
		
		p = strrchr(buffer, '.');
		
		if (!p)
		{
			log_line(5,Logmessage[M__UNKNOWN_ERR_CHANGE]);
			return;
		}
		
		if (Pkt == ARC_PKTS)
			strcpy(++p, "OAT");
		else
			strcpy(++p, "OPT");
		
		if (rename(buffer1, buffer))
			log_line(6,Logmessage[M__CANT_RENAME_POLL], buffer1, buffer);
	}
}

MLOCAL VOID hold_to_poll(WORD what)
{
	WORD	i;
	BYTE	dir[128],
			*path,
			*p;
	
	for (i=0; i < nRouteDef; i++)
		if (RouteDef[i].flags & what) break;
	
	if (i >= nRouteDef) return;
	
	if (what & HOLDDEL)
		log_line(4,Logmessage[M__CHECK_HOLD]);
	else
		log_line(4,Logmessage[M__HOLD_TO_POLL_FILE],
			(what & HOLDMAX) ? " on maximum size" : "");
	
	sprintf(dir, "%s*.HAT", outbound);
	
	if (!findfirst(dir, &blok, 0))
	{
		put_hold(blok.ff_name, alias[0].zone, outbound, what, ARC_PKTS);
		
		while (!findnext(&blok))
			put_hold(blok.ff_name, alias[0].zone, outbound, what, ARC_PKTS);
	}
	
	sprintf (dir, "%s*.HPT", outbound);

	if (!findfirst(dir, &blok, 0))
	{
		put_hold(blok.ff_name, alias[0].zone, outbound, what, NORM_PKTS);
		
		while (!findnext(&blok))
			put_hold(blok.ff_name, alias[0].zone, outbound, what, NORM_PKTS);
	}
	
	for (i=0; i < domain; i++)
	{
		if (Appl[i].zone == alias[0].zone) continue;
		
		path = outbound_dir(Appl[i].zone, 0, 0, 0);
		p = strrchr(path, '\\');
		
		if (!p)
		{
			free(path);
			continue;
		}
		
		p++;
		*p = EOS;
		
		sprintf(dir, "%s*.HAT", path);
		
		if (!findfirst(dir, &blok, 0))
		{
			put_hold(blok.ff_name, Appl[i].zone, path, what, ARC_PKTS);
			
			while (!findnext(&blok))
				put_hold(blok.ff_name, Appl[i].zone, path, what, ARC_PKTS);
		}
		
		sprintf (dir, "%s*.HPT", path);

		if (!findfirst(dir, &blok, 0))
		{
			put_hold(blok.ff_name, Appl[i].zone, path, what, NORM_PKTS);
			
			while (!findnext(&blok))
				put_hold(blok.ff_name, Appl[i].zone, path, what, NORM_PKTS);
		}
		
		free(path);
	}
}

BYTE check_hold_poll (BYTE *file, BYTE Pkt) {
	BYTE	buffer[128];
	
	strcpy (buffer, file);
	
	if (Pkt == ARC_PKTS) {
		strcat (buffer, (donewbink == TRUE) ? "OAT" : "NA");
	} else {
		strcat (buffer, (donewbink == TRUE) ? "OPT" : "NM");
	}
	
	if (!findfirst (buffer, &blok, 0)) {
		return (SUCCESS);
	}
	return (FAILURE);
}

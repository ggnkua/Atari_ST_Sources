/*********************************************************************

					IOS - messagebase scanner
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	Scan messagebase on new entered messages. Scan privatemailbox for
	new entered messages. If new message found, create packets, if on,
	and send those to the connected people.
	
*********************************************************************/
/*#define TESTCASE 1*/

#include		<stdio.h>
#include		<stdlib.h>
#include		<ext.h>
#include 		<string.h>
#include		<time.h>
#include		<tos.h>
#include		<vdi.h>

#include		"portab.h"
#include		"defs.h"
#include		"ioslib.h"
#include		"routing.h"
#include		"inmail.h"
#include		"strutil.h"
#include		"lang.h"

#include		"vars.h"

#define		MAX_ORGLINES	65

MLOCAL VOID have_message(WORD area)
{
	WORD	i, j, a, r, l = 0, rnd = 0, lcount;
	BYTE	*msgbuf, *q, *p,
			*outmsg,
			origin[100], tear[100],
			orgline[MAX_ORGLINES] [128],
			havetear = 0, haveorg = 0, orgrnd,
			was_private = 0, pnt[10],
			is_our_message = TRUE,
			use_domain[40],
			buffer[250],
			*Odomain;
	UWORD	ournode,
			zone, net, node, point,
			pzone[N_SEENS], pnet[N_SEENS], pnode[N_SEENS], ppoint[N_SEENS],
			TO_AREA;
	LONG	file_watch;
	
	msgbuf = (BYTE *) myalloc(MAXMSGLENGTH);
	outmsg = (BYTE *) myalloc(MAXMSGLENGTH);
	
	lcount = 0;
	
	*outmsg = EOS;
/*	
	msgread(msgbuf, hdr.size, FMSG);
*/
	Fread(fileno(FMSG), hdr.size, msgbuf);
	
	fclose(FMSG);
	
	/*
	**	Create an clear msgheader.
	*/
	
	hdr.flags &= ~SENT;
	
	Fzone = Fnet = Fnode = Fpoint = Tzone = Tnet = Tnode = Tpoint = 0;
	
	if (area == -1)
	{
		area = to_area(msgbuf);
		
		if (area == -1)
		{
			free(msgbuf);
			free(outmsg);
			return;
		}
		
		was_private++;
	}
	
	nseenby = npath = 0;
	
	/*
	**	This message is written in the privatearea
	**	for the netmail. Create an message.
	*/
	
	if (area == -2)
	{
		hdr.mailer[7] = 0;
		
		/*
		**	If message is in multizone, and written in an other
		**	zone, compare the zonenumbers. If found, change into
		**	that zone alias.
		*/
		
		if (hdr.Ozone != hdr.Dzone)
			for (i=0; i < nalias; i++)
				if(alias[i].zone == hdr.Dzone)
				{
					hdr.Ozone = alias[i].zone;
					hdr.Onet  = alias[i].net;
					hdr.Onode = alias[i].node;
					hdr.Opoint= alias[i].point;
					Odomain = alias[i].Domain;
					ournode = i;
					break;
				}
		
#if defined EXTERNDEBUG
	if (debugflag)
		log_line(6,">Netmail Msg using address %u:%u/%u.%u",
			hdr.Ozone, hdr.Onet, hdr.Onode, hdr.Opoint);
#endif
		
		/*
		**	Remove some lines. Add our own if necessary.
		*/
		
		msgbuf = strip_line(msgbuf, "\03AREA [");

		if (dostripPID)
			msgbuf = strip_line(msgbuf, "\01PID:");
		else
			msgbuf = Remove_and_Add("\01PID: ", msgbuf);
		
		/*
		**	Change MSGID.
		*/
		
		if (get_msgid(msgbuf, &zone, &net, &node, &point) &&
			zone != hdr.Ozone &&
			net != hdr.Onet &&
			node != hdr.Onode) msgbuf = change_msgid(msgbuf, &hdr);
		
		if (!doniceout && !doquit) {
 			gprintf("%-20.20s > %-20.20s %s.\n", hdr.from, hdr.to,
				(hdr.flags & CRASH) ? "Crashmail" : "Netmail");
		}
		else
			log_line(3,"*%-15.15s > %-15.15s %s %s", hdr.from, hdr.to,
				(hdr.flags & CRASH) ? "Crashmail" : "Netmail",
				(area >= 0) ? Areaname[area] : "MAIL");
		
		hdr.flags |= MSGLOCAL;
		
		strcpy(&outmsg[strlen(outmsg)], msgbuf);
		
		time(&secs);
		tijd = localtime(&secs);
		strftime(tm_now, 39, "%b %d %Y at %H:%M", tijd);
		
		/*
		**	Add Via line.
		*/
		/*
		sprintf(&outmsg[strlen(outmsg)], "\n\01Via %s %u:%u/%u.%u, %s",
			OutMail, hdr.Ozone, hdr.Onet, hdr.Onode, hdr.Opoint, tm_now);
		*/
		
		savemsg(TONETMAIL, &hdr, 0, outmsg, 0, 0, 0, 0);
		
		hdr.mailer[7] |= SCANNED;
		
		free(msgbuf);
		free(outmsg);
		
		return;
	}
	
	/*--------------------------------------------------*/
	/*	Normal echomail messages.						*/
	/*--------------------------------------------------*/

/*	
**	Routine herschreven t.b.v. domains.

	for (i=0; i < nalias; i++)
	{
		if (alias[i].zone == Tozone[area][0])
		{
			zone = alias[i].zone;
			net = alias[i].net;
			node = alias[i].node;
			point = alias[i].point;
			Odomain = alias[i].Domain;
			
#if defined EXTERNDEBUG
			if (debugflag) log_line(6,">Using alias %u:%u/%u.%u", alias[i].zone, alias[i].net, alias[i].node, alias[i].point);
#endif
			
			/*
			**	Are we multipoint?
			*/
			
			for (j=0; j < nalias; j++)
			{
				if (Tozone[area][0] == alias[j].zone &&
					Tonet[area][0] == alias[j].net && 
					Tonode[area][0] == alias[j].node &&
					alias[j].point)
				{
					zone = alias[j].zone;
					net = alias[j].net;
					node = alias[j].node;
					point = alias[j].point;
					Odomain = alias[i].Domain;

#if defined EXTERNDEBUG
					if (debugflag) log_line(6,">Changed alias %u:%u/%u.%u", alias[i].zone,alias[i].net, alias[i].node, alias[i].point);
#endif
					
					break;
				}
			}
			
			break;
		}
	}
*/

/*
**	Zoek naar het juiste nodenummer. Gebruik daarbij domains.
*/
	for (i=0; i < nkey; i++)
	{
		if (pwd[i].zone == Tozone[area][0] &&
			 pwd[i].net  == Tonet[area][0] &&
			 pwd[i].node == Tonode[area][0] &&
			 !strnicmp (pwd[i].Domain, Todomain[area], 8))
		{
			Odomain = pwd[i].Domain;
			
/*
**	Voor multipoint gedoe.
*/
			for (j = 0; j < nalias; j++) {
				if (!strnicmp (pwd[i].Domain, alias[j].Domain, 8) &&
					pwd[i].zone == alias[j].zone && 
					pwd[i].net == alias[j].net &&
					pwd[i].node== alias[j].node &&
					!strnicmp (Todomain[area], alias[j].Domain, 8)) {
			
					zone = alias[j].zone;
					net = alias[j].net;
					node = alias[j].node;
					point = alias[j].point;
					Odomain = alias[j].Domain;
					break;
				}
			}

/*
**	Voor nodes. Neem het domain van de degene waar het heen moet.
*/
			if ( j >= nalias) {
				for (j = 0; j < nalias; j++) {
					if (!strnicmp (alias[j].Domain, pwd[i].Domain, 8)) {
						zone = alias[j].zone;
						net = alias[j].net;
						node = alias[j].node;
						point = alias[j].point;
						Odomain = alias[j].Domain;

						break;
					}
				}
			}
			if (j >= nalias) {
				i = nkey;
				break;
			}
			break;
		}
	}

	if (i >= nkey) {
		log_line (6, "-No domain for this area.");
		zone = alias[0].zone;
		net = alias[0].net;
		node = alias[0].node;
		point = alias[0].point;
		Odomain = alias[0].Domain;
	}
	
	strcpy (org_domain, Odomain);
	strcpy (dest_domain, Odomain);
	
	if (dostripPID)
		msgbuf = strip_line(msgbuf, "\01PID:");
	else
		msgbuf = Remove_and_Add("\01PID: ", msgbuf);
	
	hdr.Ozone = zone;
	hdr.Onet = net;
	hdr.Onode = node;
	hdr.Opoint = point;
	
	if (area < 0)
	{
		log_line(5,Logmessage[M__UNKNOWN_AREA_NUMBER], area);
		return;
	}

	if (doadd_domain) {
		for (i=0; i< domain; i++) {
			if (Appl[i].zone == hdr.Ozone) {
				for (j = 0; j < Ndomain; j++) {
					if (Zdomain[j] == Appl[i].zone) {
						if (strlen(Appl[i].domain)) {
							strcpy(use_domain, "@");
							if (!strlen (Odomain))
								strcat(use_domain, Appl[i].domain);
							else if (!strnicmp (Odomain, Appl[i].domain, (WORD)strlen (Odomain)))
								strcat(use_domain, Appl[i].domain);
							else
								strcat(use_domain, Odomain);
							
							break;
						}
					}
				}
				break;
			}
		}
	}
	
	if (hdr.Opoint) {
		if (!Npoint) {	
			sprintf(pnt, ".%u", point);
		} else {
			for (j = 0; j < Npoint; j++) {
				if (hdr.Ozone == Zpoint[j]) {
					pnt[0] = EOS;
					break;
				}
			}
			if (j >= Npoint) {
				sprintf(pnt, ".%u", point);
			}
		}
	} else pnt[0] = EOS;

	/*
		Create random originline from file.
	*/
	
	if (Randorgfile[area]) {
		rnd = 0;
		if ((FDUMMY = fopen(Randorgfile[area], "rb")) == NULL) {
			log_line(4, Logmessage[M__NO_RANDOM_FILE]);
			goto NormalOrg;
		}
		while( fgets(origin, 100, FDUMMY)) {
			p = skip_blanks(origin);
			if (*p == ';') continue;
			if ((i = (WORD)strlen(p)) < 3) continue;
			p = &origin[--i];
			if (*p == '\n' || *p == '\r') *p = EOS;
			p = skip_blanks(origin);
			strcpy (orgline[rnd++], p);
			
/*			orgline[rnd++] = ctl_string(p); */
			if (rnd == MAX_ORGLINES) break;
		}
		fclose (FDUMMY);
		
		log_line (3, Logmessage[M__CALCULATE_ORIGIN]);
		
		orgrnd = (BYTE ) Random();
		orgrnd &= 0x3F;
		
		if (orgrnd >= rnd) {
			while (orgrnd >= rnd)
				orgrnd /= 2;
		}
		
		while (1) {
			if ((q = strchr (orgline[orgrnd], '%')) == NULL) break;
			++q;
			if (*q == 'd' || *q == 'u') {
				++q;
				strcpy (TEAR_buffer, q);
				*q = EOS;
				sprintf (buffer, orgline[orgrnd], (UWORD)Random());
				strcat (buffer, TEAR_buffer);
				strcpy (orgline[orgrnd], buffer);
			} else break;
		}
		
		if (orgline[orgrnd] [strlen (orgline[orgrnd]) - 1] == '\r')
			 orgline[orgrnd] [strlen (orgline[orgrnd]) - 1] = EOS;
		
		sprintf(origin, " * Origin: %s (%u:%u/%u%s%s)", orgline[orgrnd],
			hdr.Ozone, hdr.Onet, hdr.Onode, pnt, (doadd_domain == TRUE) ? use_domain : "");
		
/*		for (i=0; i < rnd; i++) free (orgline[i]); */
	}
	else {
		NormalOrg:	
		
		sprintf(origin, " * Origin: %s (%u:%u/%u%s%s)", Areaorg[area],
			hdr.Ozone, hdr.Onet, hdr.Onode, pnt, (doadd_domain == TRUE) ? use_domain : "");
	}

	ScanMail[0] = 'S';
	
	sprintf(tear, "--- %s\n", (doonly_tear == TRUE) ? "" : ScanMail);
	
	if ((i = (WORD)strlen(origin)) > 75)
		log_line(6,Logmessage[M__ORG_LINE_TO_LONG],
			i-75, Areaname[area]);
	
	/*
	**	We have an tearline?
	*/
	
	if ((p = strline(msgbuf, "--- ")) != NULL)
	{
		q = skip_to_token (p , '\n');
		--q;
		if (q) {
			strncpy (TEAR_buffer, q, 511);
			if (!strncmp (p, "--- \n", 5))
				strcpy (q, "[");
			else
				strcpy (q, " [");
			strcat (q, IOSmail);
			strcat (q, "]");
			strcat (q, TEAR_buffer);
		}
		havetear++;
		is_our_message = FALSE;
	}
	
	/*
	**	Do we have an origin?
	*/
	
	if ((q = strline(msgbuf, " * Origin:")) != NULL) haveorg++;
	
	if (msgbuf[strlen(msgbuf)-1] != '\n') strcat(msgbuf, "\n");
	
	/*
	**	Add, if none.
	*/
	
	if (!havetear && !haveorg)
	{
		sprintf(&msgbuf[strlen(msgbuf)], "%s%s", tear, origin);
		havetear = haveorg = TRUE;
	}
	
	if (!havetear)
	{
		sprintf(&msgbuf[strlen(msgbuf)], "%s%s", tear, q);
		havetear = TRUE;
	}
	
	if (!haveorg)
	{
		strcat(msgbuf, origin);
		haveorg = TRUE;
	}
	
	/*
	**	Info to screen/logfile
	*/
	
	if (!doquit)
	{
		if (was_private)
		{
			if(!doniceout && !doquit) {
				gprintf("%-20.20s > %-20.20s %s %s.\n", hdr.from,
					hdr.to, (hdr.flags & CRASH) ? "Crashmail" : "Echomail",
					(area >= 0) ? Areaname[area] : "MAIL");
			}
			else
				log_line(4,"*%-15.15s > %-15.15s %s %s.", hdr.from,
					hdr.to, (hdr.flags & CRASH) ? "Crashmail" : "Echomail",
					(area >= 0) ? Areaname[area] : "MAIL");
		}
		else
		{
			if(!doniceout && !doquit) {
				gprintf("%-20.20s > %-20.20s %s.\n", hdr.from, hdr.to,
				(hdr.flags & CRASH) ? "Crashmail" : "Echomail");
			}
			else
				log_line(3,"*%-15.15s > %-15.15s %s.", hdr.from,
				hdr.to, (hdr.flags & CRASH) ? "Crashmail" : "Echomail");
		}
	}
	
	npath = nseenby = 0;
	Fzone = fzone = hdr.Ozone;
	
	get_path(msgbuf, area);
	get_seen(msgbuf, area);
	
	/*
	**	If an echomail is moved, and the mailer field is set to 0,
	**	and we have found SEEN-BY's etc. get the SEEN_BY we have.
	*/
	
	fzone = fnet = fnode = 0;
	
	/*
	**	Do we have already SEEN-BY's in this message?
	*/
	
	if (nseenby)
	{
		fzone = Fzone = hdr.Ozone;
		fnet = Fnet = hdr.Onet;
		fnode = Fnode = hdr.Onode;
		fpoint = Fpoint = hdr.Opoint;
		
#if defined EXTERNDEBUG
		if (debugflag) log_line(6,">Found SEEN-BY's %u", nseenby);
#endif
		
		for (i=0; i < nseenby; i++)
		{
			for (j=0; j < nalias; j++)
			{
				if (SeenN[i] == alias[j].pointnet)
				{
					ppoint[l]	=	SeenO[i];
					pnet[l]		=	alias[j].net;
					pnode[l]	=	alias[j].node;
					pzone[l++]	=	alias[j].zone;
					SeenZ[i]	=	alias[j].zone;
					break;
				}
				
				if (SeenN[i] == alias[j].net &&
					SeenO[i] == alias[j].node)
				{
					pzone[l]	=	alias[j].zone;
					pnet[l]		=	alias[j].net;
					pnode[l]	=	alias[j].node;
					ppoint[l++]	=	0;
					SeenZ[i]	=	alias[j].zone;
					break;
				}
			}
			
			if (j >= nalias)
			{
				j = 0;
				
				for (a=0; a < nkey; a++)
					if (SeenN[i] == pwd[a].net &&
						SeenO[i] == pwd[a].node)
					{
						pzone[l]	=	pwd[a].zone;
						pnet[l]		=	pwd[a].net;
						pnode[l]	=	pwd[a].node;
						ppoint[l++]	=	pwd[a].point;
						SeenZ[i]	=	pwd[a].zone;
						break;
					}
				
				if (a >= nkey && !SeenZ[i]) SeenZ[i] = alias[0].zone;
			}
		}
	}
	else
	{
		/*
		**	If MSGID: has an other nodenumber than the
		**	zone we are working, change the nodenumber.
		*/
		
		if (get_msgid(msgbuf, &zone, &net, &node, &point) &&
			(zone != hdr.Ozone || net != hdr.Onet || node !=
			hdr.Onode || point != hdr.Opoint))
			msgbuf = change_msgid(msgbuf, &hdr);
		
		/*
		**	Do we add our realname?
		*/
		
		if ((dorealname & REALOUT) && is_our_message &&
			stricmp(hdr.from, SysOp) && Ausername[area])
			msgbuf = add_a_line("\01REALNAME:", SysOp, msgbuf);
	}
	
	/*
	**	Fakename in message ?
	*/
	
	if (!stricmp(hdr.from, SysOp) && Ausername[area]) {
		strncpy (hdr.from, Ausername[area], 30);
	}
	
	/*
	**	Message save back to local messagebase.
	*/
	
	if (dosavelocal)
	{
		strcpy(outmsg, msgbuf);
		
		fzone = Fzone = hdr.Ozone;
		fnet = Fnet = hdr.Onet;
		fnode = Fnode = hdr.Onode;
		fpoint = Fpoint = hdr.Opoint;
		
		i = ourseen(area, 1, &hdr, Odomain);
		Addline(outmsg, "SEEN-BY:", i-1, hdr.Ozone);
		
		i = ourpath(area, Odomain);
		Addline(outmsg, "\01PATH:", i-1, hdr.Ozone);
	
		file_watch = ftell(FHDR);
		fclose(FHDR);
		
		hdr.flags |= SENT;
		savemsg(TOLOCAL, &hdr, area, outmsg, 0, 0, 0, 0);
		
		if (MTask == MULTITOS) {
			TO_AREA = Files_to_open / 5;
			if (TO_AREA > N_MAXAREA) TO_AREA = N_MAXAREA;
		} else {
			TO_AREA = N_AREAFILE;
		}
		
		for (i=0; i < N_AREAFILE; i++)
		{
			if(LHDRfile[i] == FILEopen) fclose(LHDR[i]);
			if(LMSGfile[i] == FILEopen) fclose(LMSG[i]);
			
			lastareawritten[i] = -1;
			
			LHDRfile[i] = FILEclosed;
			LMSGfile[i] = FILEclosed;
		}
		
		if (!was_private) sprintf(tear, "%s.HDR", Areapath[area]);
		else sprintf(tear, "%s.HDR", privatebox);
		
		FHDR = fopen(tear, "r+b");
		
		if (!FHDR)
		{
			log_line(3,Logmessage[M__SER_PROBLEMS]);
			terminate(10);
		}
		
		fseek(FHDR, file_watch, SEEK_SET);
		
		*outmsg = EOS;
	}

	if (Read_only[area] == REMOTE_ONLY) {
		if (Not_allowed(msgbuf, area) == FALSE) {
			log_line(3,Logmessage[M__READ_ONLY_AREA]);
			free(msgbuf);
			free(outmsg);
			return;
		}
	}
	
	/*
	**	Export new message to nodes/point.
	*/
	
	for (j=0; Tozone[area][j] != (UWORD)-1; j++)
	{
		ournode = 0;
		
		for (i=0; i < nalias; i++)
			if (Tozone[area][j] == alias[i].zone &&
				Tonet[area][j] == alias[i].net &&
				Tonode[area][j] == alias[i].node &&
				Topoint[area][j] == alias[i].point &&
				!strnicmp (Odomain, Todomain[area], 8))
			{
				ournode++;
				break;
			}
		
		/*
		**	We have our node number added in
		**	the areas.bbs continue then.
		*/
		
		if (ournode) continue;
		
		/*
		**	If we have an message with an SEEN-BY already,
		**	find out who have this message already.
		*/
		
		if (l)
		{
			for (a=0; a < l; a++)
				if (pzone[a] == Tozone[area][j] &&
					pnet[a] == Tonet[area][j] &&
					pnode[a] == Tonode[area][j] &&
					ppoint[a] == Topoint[area][j]) break;
			
			if (a < l) continue;
		}
		
		nechos++;
		Ncreated[area]++;
		
		/*
		**	If message has the crash flag on, then this
		**	is an netmail. Don't add SEEN-BY to it.
		*/
		
		if (!(hdr.flags & CRASH))
		{
			hdr.Dzone = Tozone[area][j];
			hdr.Dnet = Tonet[area][j];
			hdr.Dnode = Tonode[area][j];
			hdr.Dpoint = Topoint[area][j];
			
			if (!capture_msg(&hdr)) continue;
			
			hprintf(S_EXP, "%d", nechos);
			hprintf(S_DEST, "%u:%u/%u.%u", hdr.Dzone, hdr.Dnet,
				hdr.Dnode, hdr.Dpoint);
			hprintf(S_FROM, "%u:%u/%u.%u", hdr.Ozone, hdr.Onet,
				hdr.Onode, hdr.Opoint);
			
			sprintf(outmsg, "AREA:%s\n", Areaname[area]);
			add_point(outmsg, &hdr);
			strcat(outmsg, msgbuf);
			
			nseenby = npath = 0;
			
			if (!fzone || !fnet)
			{
				fzone = Fzone = hdr.Ozone;
				fnet = Fnet = hdr.Onet;
				fnode = Fnode = hdr.Onode;
				fpoint = Fpoint = hdr.Opoint;
			}
			
			i = ourseen(area, Topoint[area][j], &hdr, Odomain);
			Addline(outmsg, "SEEN-BY:", i-1, Tozone[area][j]);
			
			i = ourpath(area, Odomain);
			Addline(outmsg, "\01PATH:", i-1, Tozone[area][j]);
			ournode = 0;
		}
		else
		{
			strcpy(outmsg, msgbuf);
			
			outmsg = strip_those_lines(outmsg, "SEEN-BY:");
			outmsg = strip_those_lines(outmsg, "\01SEEN-BY:");
			outmsg = strip_those_lines(outmsg, "\01PATH:");
			
			ournode = 1;
			
			time(&secs);
			tijd = localtime(&secs);
			strftime(tm_now, 39, "%b %d %Y at %H:%M", tijd);
			
			sprintf(&outmsg[strlen(outmsg)],
				"\n\01Via %s %u:%u/%u.%u, %s\n", OutMail, hdr.Ozone,
				hdr.Onet, hdr.Onode, hdr.Opoint, tm_now);
			
			if (hdr.flags & ORPHAN) hdr.flags &= ~CRASH;
			hdr.flags |= (PRIVATE|MSGLOCAL);
		}
		
		hdr.flags &= ~(SENT|RECEIVED);
		hdr.mailer[7] = 0;
		
		if (!dopkt)
		{
			hdr.flags |= (KILLSEND|MSGLOCAL);
			strcat(outmsg, "\n");
		}
		
		if(!doniceout && !doquit)
		{
			if(!ournode) {				
				hprintf(S_DEST, "%u:%u/%u.%u", hdr.Dzone, hdr.Dnet,
					hdr.Dnode, hdr.Dpoint);
				hprintf(S_FROM, "%u:%u/%u.%u", hdr.Ozone, hdr.Onet,
					hdr.Onode, hdr.Opoint);
			}
			else {
				hprintf(S_DEST, "%u:%u/%u.%u", hdr.Dzone, hdr.Dnet,
					hdr.Dnode, hdr.Dpoint);
				hprintf(S_FROM, "%u:%u/%u.%u", hdr.Ozone, hdr.Onet,
					hdr.Onode, hdr.Opoint);
				
				hprintf(S_COMMENT, " Via netmail to %u:%u/%u.%u", hdr.Dzone,
					hdr.Dnet, hdr.Dnode, hdr.Dpoint);
			}
		}
		else
		{
			if(!ournode)
				log_line(2,Logmessage[M__VIA_NODE], hdr.Dzone, hdr.Dnet,
					hdr.Dnode,hdr.Dpoint);
			else
				log_line(3,Logmessage[M__VIA_NETMAIL], hdr.Dzone,
					hdr.Dnet, hdr.Dnode, hdr.Dpoint);
		}
		
		if (!ournode)
			savemsg((dopkt) ? TOPACKET : TONETMAIL, &hdr, area,
				outmsg, 0, 0, 0, 0);
		else
			savemsg(TONETMAIL, &hdr, 0, outmsg, 0, 0, 0, 0);
		
		hdr.flags |= SENT;
		hdr.mailer[7] |= SCANNED;
		hdr.flags &= ~(KILLSEND);
		
		*outmsg = EOS;
	}
	
	
	free(outmsg);
	free(msgbuf);
}

MLOCAL VOID export(WORD area)
{
	BYTE	Mfile[128],
			Hfile[128];
	LONG	tell;
	ULONG	MaxMsg;
	
	if (area != -1) {
		log_line(6,Logmessage[M__READING_AREA], Areaname[area]);
		hprintf (S_AREA, "%s", Areaname[area]);
	}
	else {
		log_line(6,Logmessage[M__READING_PVTBOX]);
		hprintf (S_AREA, "PRIVATEMAILBOX");
	}
	
	if (area != -1)
	{
		sprintf(Mfile, "%s.MSG", Areapath[area]);
		sprintf(Hfile, "%s.HDR", Areapath[area]);
	}
	else
	{
		sprintf(Hfile, "%s.HDR", privatebox);
		sprintf(Mfile, "%s.MSG", privatebox);
	}
	
	if ((FHDR = fopen(Hfile, "r+b")) == NULL) return;
	
	while (!feof(FHDR))
	{
/*
		hdrread(&hdr, sizeof(MSGHEADER), FHDR);
*/
		if (Fread(fileno(FHDR), sizeof(MSGHEADER), &hdr) != sizeof(MSGHEADER)) break;
		
		if (!hdr.size)
		{
			hdr.flags = DELETED;
			fseek(FHDR, ftell(FHDR) - sizeof(MSGHEADER), SEEK_SET);
			fwrite(&hdr, sizeof(MSGHEADER) ,1, FHDR);
			fflush(FHDR);
			continue;
		}
				
		if (hdr.mailer[7] & SCANNED || hdr.flags & DELETED) continue;
		
		if ((tell = ftell(FHDR)) < sizeof(MSGHEADER))
		{
			if (tell > 0L) log_line(5,Logmessage[M__FILESIZE_PROBLEM],
				tell, (WORD)sizeof(MSGHEADER));
			break;
		}
		
		if (hdr.size >= MAXMSGLENGTH)
		{
			log_line(4,Logmessage[M__MSG_TO_BIG_SIZE], MAXMSGLENGTH);
			
			hdr.mailer[7] |= SCANNED;
			fseek(FHDR, ftell(FHDR) - sizeof(MSGHEADER), SEEK_SET);
			hdrwrite(&hdr, sizeof(MSGHEADER), FHDR);
			
			continue;
		}
				
		if ((FMSG = fopen(Mfile,"rb")) != NULL)
		{
			fseek(FMSG, hdr.Mstart, SEEK_SET);
			
			if (ferror(FMSG))
			{
				log_line(4,Logmessage[M__SEEK_ERROR]);
				fclose(FMSG);
				continue;
			}
#if !defined TESTCASE			
			fseek(FHDR, ftell(FHDR) - sizeof(MSGHEADER), SEEK_SET);
#endif			
			hdr.mailer[7] |= SCANNED;
			if (hdr.flags & MSGLOCAL) hdr.flags |= SENT;
			
			if (hdr.flags & KILLSEND || dosavelocal)
			{
				hdr.flags |= DELETED;
				if (area == -1 && !dosavelocal) hdr.flags &= ~DELETED;
			}
#if !defined TESTCASE			
			hdrwrite(&hdr, sizeof(MSGHEADER), FHDR);
			fflush(FHDR);
#endif			
			if (dosavelocal) hdr.flags &= ~DELETED;
			
			have_message(area);
		}
	}
	
	fclose(FHDR);
}

VOID scan_areas(VOID)
{
	WORD	i;
	
	log_line(6,Logmessage[M__SCAN_AREAS]);

	hprintf (S_COMMENT, "Scanning echomail");
	
	init_PKTS();
	
	for (i=0; i < msgareas; i++)
	{
		if (Dareas[i] || (dochanged && !area_changed(i))) continue;
		
		export(i);
		
		area_changed(i);
	}
	
	if (toprivate || dopvtmail) export(-1);
	
	close_PKTS();
}

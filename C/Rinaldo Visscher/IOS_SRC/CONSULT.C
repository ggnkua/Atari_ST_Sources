/*********************************************************************

					IOS - area consultant
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1992
	
	Handle messages to areafix. Connect and/or disconnect points or
	node from an messagearea.
		
*********************************************************************/

#include		<stdio.h>
#include		<time.h>
#include		<ctype.h>
#if !defined LATTICE
#include		<ext.h>
#include 		<tos.h>
#include		<process.h>
#else
#include		<sys/stat.h>
#include		<dos.h>
#endif
#include		<string.h>
#include		<stdlib.h>
#include		<errno.h>

#include		"portab.h"
#include		"defs.h"
#include		"ioslib.h"
#include		"modules.h"
#include		"routing.h"

#include		"inmail.h"
#include		"strutil.h"
#include		"crc.h"
#include		"lang.h"
#include		"wareas.h"

#include		"vars.h"


MLOCAL BYTE	rescan,
			llist,
			qlist;
			
MLOCAL BYTE	*sentbuf;
MLOCAL WORD	rescanareas[N_AREAS];
MLOCAL WORD	areas_resc, pwdnode;
MLOCAL BYTE msgreply [100];
MLOCAL BYTE msgid[100];

/*
MLOCAL UWORD fzo, fne, fno, fpo, tzo, tne, tno, tpo;
*/
MLOCAL VOID rescan_areas(MSGHEADER *Hdr, WORD pwdnode);
MLOCAL VOID disconnect (MSGHEADER *Hdr, BYTE *area);
MLOCAL BYTE *connect(MSGHEADER *Hdr, BYTE * area, BYTE *line);
MLOCAL VOID send_llist(MSGHEADER *Hdr) ;
MLOCAL VOID send_qlist(MSGHEADER *Hdr) ;
MLOCAL VOID sent_help(VOID);

ULONG get_crc(BYTE *text, BYTE *string);

VOID Set_REPLY(BYTE *msgtext, BYTE *into, WORD node) {
	BYTE *p, *q, *w, s,
	buffer[100];

	UWORD i;
	ULONG j;
	
	w = strline(msgtext, "\01MSGID:");

	buffer[0] = EOS;
	
	if (!w) {
		log_line( 5, Logmessage[M__ILLEGAL_MSGID]);
	} else {
		if ((q = strchr (w , '@')) != NULL) {
			strncpy( buffer, q, 49);
			if ((q = strchr(buffer, '\n')) != NULL) *q = EOS;
		} else {
			w = skip_to_token(w, '\n');
			w--;
			w--;
			
			for (; !isspace (*w) && *w ; w--) ;
			
			if (*w) {
				w = skip_blanks(w);
				for (q = buffer; *w && !isspace(*w); *q++ = *w++);
				*q = EOS;
			} else {
				log_line( 5, Logmessage[M__ILLEGAL_MSGID]);
			}
		}
	}
	
	
	strcpy (msgreply, buffer);
	
	sprintf(buffer, "\01MSGID: ");
	
	if (!pwd[node].point) {
		
		Standaard_MSGID:
		
		for (i = 0; i < nalias; i++) {
			if (alias[i].zone == pwd[node].zone) {
				sprintf (&buffer[strlen(buffer)], "%u:%u/%u",
						 alias[i].zone, alias[i].net, alias[i].node);
				for (j = 0; j < domain; j++) {
					if (pwd[node].zone == Appl[j].zone) {
						if (strlen (Appl[j].domain)) {
							sprintf(&buffer[strlen(buffer)], "@%s ", Appl[j].domain);
						}
						break;
					}
				}
				if (j >= domain) {
					strcat(buffer, " ");
				}
				break;
			}
		}
		if (i >= nalias) {
			i = 0;
			goto Standaard_MSGID;
		}
	} else {
		for (i = 0; i < nalias; i++) {
			if (alias[i].zone == pwd[node].zone && 
				alias[i].net  == pwd[node].net  &&
				alias[i].node == pwd[node].node) {
				sprintf (&buffer[strlen(buffer)], "%u:%u/%u",
						 alias[i].zone, alias[i].net, alias[i].node);
				for (j = 0; j < domain; j++) {
					if (pwd[node].zone == Appl[j].zone) {
						if (strlen (Appl[j].domain)) {
							sprintf(&buffer[strlen(buffer)], "@%s ", Appl[j].domain);
						}
						break;
					}
				}
				if (j >= domain) {
					strcat(buffer, " ");
				}
				break;
			}
		}
		if (i >= nalias) {
			i = 0;
			goto Standaard_MSGID;
		}
	}
	
	strcpy (msgid, buffer);
	
	if (strlen(msgid)) {
		sprintf(into, msgid);
		if (i < nalias) {
			s = (BYTE) Random();
			j = Random();
			sprintf(&into[strlen(into)], " %02x%06lx\n", s, j);
		} else {
			msgid[0] = EOS;
		}
	
	}
	
	if (strlen(msgreply)) {
		sprintf(&into[strlen(into)], "\01REPLY: %u:%u/%u",
			pwd[node].zone, pwd[node].net, pwd[node].node);
		
		if (pwd[node].point)
			sprintf (&into[strlen(into)], ".%u", pwd[node].point);
		
		if (*msgreply != '@') strcat (into, " ");
		strcat (into, msgreply);
	}
	
	sprintf(&into[strlen(into)], "\n\01PID: %s\n",IOSmail);
}
	
VOID consult_areafix(MSGHEADER *Hdr, BYTE *message) {
	UWORD	i,
			zone, net ,node, point;
	
	BOOLEAN Changed = FALSE;
	
	BYTE 	*p, *q, *w,
			temp[100],
			buffer[50];

	log_line(4, Logmessage[M__AREAFIX_PARSE]);
	hprintf (S_COMMENT, "Parsing Areafix.");
	
	for (i=0; i<nkey; i++) {
		if (pwd[i].zone == Hdr->Ozone && pwd[i].net == Hdr->Onet &&
			pwd[i].node == Hdr->Onode && pwd[i].point==Hdr->Opoint) {
			
			pwdnode = i;
			break;
		}
	}
	
	if (i >= nkey) {
		log_line(6, Logmessage[M__AREAFIX_NODE_UNKNOWN]);
		return;
	}

	p = Hdr->topic;
	
	for (q=temp; *p && !isspace(*p); *q++ = *p++);
	*q= EOS;
	
	if (stricmp(pwd[pwdnode].Afix, temp)) {
		log_line(6, Logmessage[M__PASSWORD_ERROR], temp, 
			pwd[pwdnode].Afix);
		return;
	}

	sentbuf = (BYTE *)myalloc(MAXMSGLENGTH);
	
	areas_resc = 0;
	rescan = qlist = llist = FALSE;
/*	
	fzo = Hdr->Dzone;
	fne = Hdr->Dnet;
	fno = Hdr->Dnode;
	fpo = Hdr->Dpoint;
	tzo = Hdr->Ozone;
	tne = Hdr->Onet;
	tno = Hdr->Onode;
	tpo = Hdr->Opoint;
*/	
	p = skip_blanks(p);
	
	if (*p) {
		while (*p) {
			switch (toupper(*p)) {
				case '-':
				case ' ':	break;
				case 'R':	if (dorescan == TRUE) 
								rescan = TRUE; 
							p++; 
							continue;
				case 'Q':	qlist  = TRUE; p++; continue;
				case 'L':	llist  = TRUE; p++; continue;
			}
			p++;
			if (!*p) break;
		}
	}
	
	p = message;
	
	Set_REPLY (p, sentbuf, pwdnode);
	
	while (*p) {
		p = skip_blanks(p);
		if (!*p) break;
		if (*p == '\01') {
			p = skip_to_token(p, '\n');
			continue;
		}
		
		if (*p == '%') {
			p = skip_blanks(&p[1]);
			switch (toupper(*p)) {
				case 'H': 	sent_help();	break;
				case 'R':	rescan = TRUE;	break;
				case 'L':	llist = TRUE;	break;
				case 'Q':	qlist = TRUE;	break;
			}
			p = skip_to_token(p, '\n');
			continue;
		}
		
		if (*p == '-') {
			if (!strncmp (p, "---", 3)) break;
			
			p = skip_blanks(&p[1]);
			for (q=temp; *p && !isspace(*p); *q++ = *p++);
			*q= EOS;
			
			disconnect(Hdr, temp);
			Changed = TRUE;
			continue;
		}
		
		if (*p == '+') p = skip_blanks(&p[1]);
		for (q=temp; *p && !isspace(*p); *q++ = *p++);
		*q= EOS;
		
		p = connect(Hdr, temp, (p = skip_blanks(p)));
		Changed = TRUE;
	}
	strcat(sentbuf, "\n--- ");
	strcat(sentbuf, V_CONSULTANT);
	strcat(sentbuf, "\n");

	for (i=0; i <nalias; i++) {
		if (Hdr->Dzone == alias[i].zone) {
			zone = alias[i].zone;
			net  = alias[i].net;
			node = alias[i].node;
			point= alias[i].point;
			break;
		}
	}
	
	if (i >= nalias) {
		zone = alias[0].zone;
		net  = alias[0].net;
		node = alias[0].node;
		point= alias[0].point;
	}
	
	Hdr->Dzone = Hdr->Ozone;
	Hdr->Dnet  = Hdr->Onet;
	Hdr->Dnode = Hdr->Onode;
	Hdr->Dpoint= Hdr->Opoint;
	
	Hdr->Ozone = zone;
	Hdr->Onet  = net;
	Hdr->Onode = node;
	Hdr->Opoint= point;
	
	strcpy(Hdr->to, Hdr->from);
	
	strcpy(Hdr->from, IOSmail);
	strcat(Hdr->from, " Areaconsultant.");
	strcpy(Hdr->topic ,"Areaconsultant receipt.");

	Hdr->mailer[7] |= SCANNED;
	Hdr->flags = (MSGLOCAL|SENT);
	
	if (Changed == TRUE) {
		savemsg(TONETMAIL, Hdr, -1, sentbuf, Hdr->Dzone, Hdr->Dnet,
			Hdr->Dnode, Hdr->Dpoint);
		
		Hdr->mailer[7] = 0;
		
		Hdr->flags = (MSGLOCAL|KILLSEND);
		
		savemsg((dopkt) ? TOPACKET : TONETMAIL, Hdr, -1, sentbuf,
			Hdr->Dzone, Hdr->Dnet, Hdr->Dnode, Hdr->Dpoint);
	}
	
	if (doquery == TRUE && qlist == TRUE)
		send_qlist(Hdr);
	
	if (dototallist == TRUE && llist == TRUE)
		send_llist(Hdr);
		
	if (areas_resc && rescan == TRUE) {
		rescan_areas(Hdr, pwdnode);
		areas_resc = 0;
	}

	free(sentbuf);
	
	if (Changed == TRUE) {
		log_line(3, Logmessage[M__AREAFIX_WRITE_AREAS]);
		write_bin_areas();
	}
}

MLOCAL VOID disconnect (MSGHEADER *Hdr, BYTE *area) {
	WORD	i, j, w;
	
	for (i=0; i<msgareas; i++) {
		if (!stricmp(area, Areaname[i])) {
			for (j = 0; Tozone[i][j] != (UWORD) -1; j++) {
				if (Hdr->Ozone == Tozone[i][j] &&
					Hdr->Onet  == Tonet [i][j] &&
					Hdr->Onode == Tonode[i][j] &&
					Hdr->Opoint== Topoint[i][j]) {
					
					for(w = j+1; Tozone[i][w] != (UWORD) -1; w++) {
						Tozone[i][j] = Tozone[i][w];
						Tonet [i][j] = Tonet [i][w];
						Tonode[i][j] = Tonode[i][w];
						Topoint[i][j]= Topoint[i][w];
						j++;
					}
					
					Tozone[i][j] = Tonet[i][j] = (UWORD) -1;
					Tonode[i][j] = Topoint[i][j] = (UWORD) -1;
					
					sprintf(&sentbuf[strlen(sentbuf)], "Area %s disconnected.\n",
						strupr(area));
					log_line(3,Logmessage[M__AREAFIX_DISCONNECT], area);
					return;
				}
			}
			sprintf(&sentbuf[strlen(sentbuf)], "Area %s, was not active.\n",
				strupr(area));
			log_line(3, Logmessage[M__AREAFIX_NO_CONNECT], strupr(area));
			
			return;
		}
	}
	log_line(4, Logmessage[M__AREAFIX_NO_EXIST], strupr(area));
}

MLOCAL BYTE *connect(MSGHEADER *Hdr, BYTE * area, BYTE *line) {
	WORD 	i, j;
	BYTE	*p;
	
	BYTE	resc;
	
	p = line;
	
	resc = rescan;
	
	if (*p == '-' || *p == '%') {
		if (!strncmp(p, "---", 3)) goto manage;
		p++;
		while (*p) {
			if (*p == '\n') break;
			*p = toupper(*p);
			if (*p == 'R' && dorescan == TRUE) {
				resc = TRUE;
				++p;
				continue;
			}
			p++;
			if (!*p || *p == '\n') break;
		}
	}
	
	manage:
	
	line = p;
	
	for (i=0; i < msgareas ; i++) {
		if (!stricmp(area, Areaname[i])) {
			for (j = 0; Tozone[i][j] != (UWORD) -1; j++) {
				if (Hdr->Ozone == Tozone[i][j] &&
					Hdr->Onet  == Tonet [i][j] &&
					Hdr->Onode == Tonode[i][j] &&
					Hdr->Opoint== Topoint[i][j]) {
						sprintf(&sentbuf[strlen(sentbuf)],
							"Area %s, already active.\n", strupr(area));
						log_line(4, 
							Logmessage[M__AREAFIX_EXIST], strupr(area));
						return (line);
				}
			}
			
			if (!strchr(pwd[pwdnode].Ugroup, Areagroup[i])) {
				sprintf(&sentbuf[strlen(sentbuf)],
					"You are not authorized for area %s\n", strupr(area));
				return (line);
			}
			
			Tozone[i] = (UWORD *) realloc(Tozone[i], 
				(j+2) * sizeof(UWORD));
			Tonet[i] = (UWORD *) realloc(Tonet[i], 
				(j+2) * sizeof(UWORD));
			Tonode[i] = (UWORD *) realloc(Tonode[i],
				(j+2) * sizeof(UWORD));
			Topoint[i] = (UWORD *) realloc(Topoint[i],
				(j+2) * sizeof(UWORD));
			Tozone[i][j] = Hdr->Ozone;
			Tonet[i][j]  = Hdr->Onet;
			Tonode[i][j] = Hdr->Onode;
			Topoint[i][j]= Hdr->Opoint;
			j++;
			
			Tozone[i][j] = Tonet[i][j] = 0xFFFFU;
			Tonode[i][j] = Topoint[i][j] = 0xFFFFU;
			
			j++;
			
			memmove(Tz, Tozone[i], (j * sizeof(UWORD)));
			memmove(Tnt,Tonet[i], (j * sizeof(UWORD)));
			memmove(Tne,Tonode[i], (j * sizeof(UWORD)));
			memmove(Tp, Topoint[i], (j * sizeof(UWORD)));
			
			log_line(2, Logmessage[M__AREAFIX_SORT]);
			
			sort_connected(j, 1);

			memmove(Tozone[i], Tz, (j * sizeof(UWORD)));
			memmove(Tonet[i], Tnt, (j * sizeof(UWORD)));
			memmove(Tonode[i], Tne, (j * sizeof(UWORD)));
			memmove(Topoint[i], Tp, (j * sizeof(UWORD)));
			
			if (resc == FALSE)
				sprintf(&sentbuf[strlen(sentbuf)],"Area %s connected\n", 
					strupr(area));
			else {
				if (Dareas[i]) {
					sprintf(&sentbuf[strlen(sentbuf)], "Area %s connected, rescan not possible.\n",
						strupr(area));
				} else {
					rescanareas[areas_resc++] = i;
					sprintf(&sentbuf[strlen(sentbuf)],"Area %s connected and rescanned.\n", 
						strupr(area));
				}
			}
			log_line(4, Logmessage[M__AREAFIX_CONNECTED], strupr(area));
			return (line);
		}
	}
	sprintf(&sentbuf[strlen(sentbuf)],"Area %s, does'nt exist.\n", strupr(area));
	log_line(4, Logmessage[M__AREAFIX_NO_EXIST], strupr(area));
	return (line);
}

MLOCAL VOID rescan_areas(MSGHEADER *Hdr, WORD tonode) {
	WORD 	i, c, j;

	BYTE 	Hfile[128],
			Mfile[128];
	
	BYTE	*qbuf;
	
	ULONG	MaxMsg, MaxHdr;
	
	struct	ffblk blk;
	
	FILE	*Mhdr, *Mmsg;
	MSGHEADER hdr;
	
	if (dofastimport == TRUE) {
		log_line(6, "!RESCAN : Switch of 'FastImport' in config first ....");
		return;
	}
	
	close_PKTS();
	init_PKTS();
		
	qbuf = (BYTE *) myalloc (MAXMSGLENGTH);
			
	for (i = 0; i < areas_resc; i++) {
		hprintf (S_AREA, "%s", Areaname[rescanareas[i]]);
		sprintf(Mfile, "%s.MSG", Areapath[rescanareas[i]]);
		sprintf(Hfile, "%s.HDR", Areapath[rescanareas[i]]);
		
		if (findfirst(Mfile, &blk, 0)) continue;
		if (!blk.ff_fsize) continue;
		if (findfirst(Hfile, &blk, 0)) continue;
		if (!blk.ff_fsize) continue;
		
		if ((Mmsg = fopen(Mfile, "rb")) == NULL) {
			log_line(6, Logmessage[M__CANT_OPEN], Mfile);
			return;
		}
		
		if ((Mhdr = fopen(Hfile, "r+b")) == NULL) {
			fclose(Mmsg);
			log_line(6, Logmessage[M__CANT_OPEN], Hfile);
			return;
		}
		
		fseek(Mmsg, 0L, SEEK_END);
		fseek(Mhdr, 0L, SEEK_END);
	
		MaxMsg = ftell(Mmsg);
		MaxHdr = ftell(Mhdr);
		c = 0;
		
		fseek(Mhdr, 0L, SEEK_SET);
		
		log_line(3, Logmessage[M__AREAFIX_RESCAN], 
			Areaname[rescanareas[i]], MaxHdr / sizeof(MSGHEADER));
		
		while (!feof(Mhdr)) {
			fread(&hdr, sizeof(MSGHEADER), 1, Mhdr);
			if (feof(Mhdr)) break;
			*sentbuf = EOS;
			*qbuf    = EOS;
			
			if (Hdr->flags & DELETED) continue;
			
			if (hdr.Mstart > MaxMsg || !hdr.size) {
				log_line(6, Logmessage[M__AREAFIX_ILLEGAL_MSG]);
				fseek(Mhdr, ftell(Mhdr) - sizeof(MSGHEADER), SEEK_SET);
				hdr.flags = DELETED;
				fwrite(&hdr, sizeof(MSGHEADER), 1, Mhdr);
				fflush(Mhdr);
				continue;
			}

			if(dopkt) nechos++;
			
			hprintf (S_EXP, "%d", nechos);
			
			fseek (Mmsg, hdr.Mstart, SEEK_SET);
			
			sprintf(sentbuf, "AREA:%s\n", Areaname[rescanareas[i]]);
			
			fread(qbuf, hdr.size, 1 ,Mmsg);
			
			strncat (sentbuf, qbuf, (LONG) hdr.size);

			for (j=0; j < nalias; j++) {
				if (pwd[tonode].zone == alias[j].zone) {
					Hdr->Ozone = alias[j].zone;
					Hdr->Onet  = alias[j].net;
					Hdr->Onode = alias[j].node;
					Hdr->Opoint= alias[j].point;
					break;
				}
			}
		
			hdr.Dzone = pwd[tonode].zone;
			hdr.Dnet  = pwd[tonode].net;
			hdr.Dnode = pwd[tonode].node;
			hdr.Dpoint= pwd[tonode].point;
						
			c++;
			
			savemsg((dopkt) ? TOPACKET : TONETMAIL, &hdr, i, sentbuf, 
				hdr.Dzone, hdr.Dnet, hdr.Dnode, hdr.Dpoint);
		}
		
		log_line(2, Logmessage[M__AREAFIX_RESCANNED], c);
		rescanareas[i] = c;
		
		fclose(Mmsg);
		fclose(Mhdr);
	}
	close_PKTS();
	init_PKTS();
	free (qbuf);
}

MLOCAL VOID send_qlist(MSGHEADER *Hdr) {
	WORD 	i, j, c = 0;
	ULONG	l;
	BYTE	s;
	
	*sentbuf = EOS;
	
	log_line(2, Logmessage[M__AREAFIX_QUERY]);

	if (strlen(msgid)) {	
		s = (BYTE) Random();
		l = Random();
		sprintf(sentbuf,"%s%02x%06lx\n", msgid, s, l);
	}
	
	if (strlen(msgreply)) {
		sprintf(&sentbuf[strlen(sentbuf)], "\01REPLY: %u:%u/%u",
			pwd[pwdnode].zone, pwd[pwdnode].net, pwd[pwdnode].node);
		if (pwd[pwdnode].point)
			sprintf(&sentbuf[strlen(sentbuf)], ".%u", pwd[pwdnode].point);

		if (*msgreply != '@') strcat (sentbuf, " ");
		
		sprintf(&sentbuf[strlen(sentbuf)], "%s\n", msgreply);
	}
	
	sprintf(&sentbuf[strlen(sentbuf)], "\01PID: %s\n", IOSmail);
	sprintf(&sentbuf[strlen(sentbuf)], "List of connected areas on %u:%u/%u.%u\n\n",
		Hdr->Ozone, Hdr->Onet, Hdr->Onode, Hdr->Opoint);
	
	for (i=0; i < msgareas; i++) {
		for (j=0; Tozone[i][j] != (UWORD)-1; j++) {
			if (Hdr->Dzone == Tozone[i][j] &&
				Hdr->Dnet  == Tonet[i][j] &&
				Hdr->Dnode == Tonode[i][j] &&
				Hdr->Dpoint== Topoint[i][j]) {
				
				sprintf(&sentbuf[strlen(sentbuf)],
					"%s\n", Areaname[i]);
				c++;
				break;
			}
		}
	}
	
	sprintf(&sentbuf[strlen(sentbuf)],"\nTotal connected areas %d.", c);
	
	strcat(sentbuf, "\n--- ");
	strcat(sentbuf, V_CONSULTANT);
	
	Hdr->flags = (MSGLOCAL|SENT);
	
	strcpy (Hdr->topic, "List of connected area(s).");
	
	savemsg(TONETMAIL, Hdr, -1, sentbuf, Hdr->Dzone,
		Hdr->Dnet, Hdr->Dnode, Hdr->Dpoint);
	
	Hdr->flags = 0;
	
	Hdr->flags = (MSGLOCAL|KILLSEND);
	savemsg((dopkt) ? NETMAILPACKET : TONETMAIL, Hdr, -1, sentbuf, Hdr->Dzone,
		Hdr->Dnet, Hdr->Dnode, Hdr->Dpoint);
}

MLOCAL VOID send_llist(MSGHEADER *Hdr) {
	WORD 	i, j, c = 0;
	ULONG	l;
	BYTE	s;
	
	*sentbuf = EOS;
	
	log_line(2, Logmessage[M__AREAFIX_TOTAL]);

	if (strlen(msgid)) {	
		s = (BYTE) Random();
		l = Random();
		sprintf(sentbuf,"%s%02x%06lx\n", msgid, s, l);
	}
	
	if (strlen(msgreply)) {
		sprintf(&sentbuf[strlen(sentbuf)], "\01REPLY: %u:%u/%u",
			pwd[pwdnode].zone, pwd[pwdnode].net, pwd[pwdnode].node);
		
		if (pwd[pwdnode].point)
			sprintf(&sentbuf[strlen(sentbuf)], ".%u", pwd[pwdnode].point);
		
		if (*msgreply != '@') strcat (sentbuf, " ");
		
		sprintf(&sentbuf[strlen(sentbuf)], "%s\n", msgreply);
	}
	
	sprintf(&sentbuf[strlen(sentbuf)], "\01PID: %s\n", IOSmail);
	sprintf(&sentbuf[strlen(sentbuf)], "List of avaible areas on %u:%u/%u.%u\n\n",
		Hdr->Ozone, Hdr->Onet, Hdr->Onode, Hdr->Opoint);
	
	for (i=0; i < msgareas; i++) {
		for (j=0; Tozone[i][j] != (UWORD)-1; j++) {
			if (Hdr->Dzone == Tozone[i][j] &&
				Hdr->Dnet  == Tonet[i][j] &&
				Hdr->Dnode == Tonode[i][j] &&
				Hdr->Dpoint== Topoint[i][j]) {
				
				break;
			}
		}
		if (Tozone[i][j] == (UWORD) -1) {
			if (Hdr->Dzone == Tozone[i][0] &&
				strchr(pwd[pwdnode].Ugroup, Areagroup[i])) {
				sprintf(&sentbuf[strlen(sentbuf)],
					"%s\n", Areaname[i]);
				c++;
			}
		}
	}
	
	sprintf(&sentbuf[strlen(sentbuf)],"\nTotal avaible areas %d.", c);
	
	strcat(sentbuf, "\n--- ");
	strcat(sentbuf, V_CONSULTANT);
	
	strcpy (Hdr->topic, "List of avaible areas.");
	
	Hdr->flags = (MSGLOCAL|SENT);
	
	savemsg(TONETMAIL, Hdr, -1, sentbuf, Hdr->Dzone,
		Hdr->Dnet, Hdr->Dnode, Hdr->Dpoint);
	
	Hdr->flags = 0;
	Hdr->flags = (MSGLOCAL|KILLSEND);
	savemsg((dopkt) ? NETMAILPACKET : TONETMAIL, Hdr, -1, sentbuf, Hdr->Dzone,
		Hdr->Dnet, Hdr->Dnode, Hdr->Dpoint);
}

VOID sent_help() {
	sprintf(&sentbuf[strlen(sentbuf)], "To request, write to AreaFix or IOS.\n");
	sprintf(&sentbuf[strlen(sentbuf)], "Your AreaFix password goes into the subject line.\n\n");
	sprintf(&sentbuf[strlen(sentbuf)], "In the body of your message to AreaFix :\n\n");
	sprintf(&sentbuf[strlen(sentbuf)], "+<areaname>    Connect this area.\n");
	sprintf(&sentbuf[strlen(sentbuf)], "-<areaname>    Disconnect this area.\n");
	sprintf(&sentbuf[strlen(sentbuf)], "%%(H)elp       This message.\n");
	sprintf(&sentbuf[strlen(sentbuf)], "%%(R)escan     Rescan all new connected areas.\n");
	sprintf(&sentbuf[strlen(sentbuf)], "%%(Q)uery      Query list, list of connected areas.\n");
	sprintf(&sentbuf[strlen(sentbuf)], "%%(L)ist       List of avaible areas.\n\n");
	sprintf(&sentbuf[strlen(sentbuf)], "How to send a message :\n\n");
	sprintf(&sentbuf[strlen(sentbuf)], "From : Joe Jet\n");
	sprintf(&sentbuf[strlen(sentbuf)], "To   : AreaFix\n");
	sprintf(&sentbuf[strlen(sentbuf)], "Topic: <Your areafix password here> <(-l -q -r)>\n\n");
	sprintf(&sentbuf[strlen(sentbuf)], "+(AreaSysOp)    -R\n");
	sprintf(&sentbuf[strlen(sentbuf)], "-(AreaNoNo)\n");
	sprintf(&sentbuf[strlen(sentbuf)], "(---) Tearline, all after this is ignored.\n\n");
	sprintf(&sentbuf[strlen(sentbuf)], "Connect to area AreaSysOp and rescan.\n");
	sprintf(&sentbuf[strlen(sentbuf)], "Disconnect area AreaNoNo\n\n");
	sprintf(&sentbuf[strlen(sentbuf)], "=======================================================\n\n");
}

WORD ADDarea (BYTE *area) {
	WORD 	i, w = 0, where;
	BYTE 	buffer[128],
			Qbuf[100],
			*p;
	
	Areaname[msgareas] = ctl_string (area);

	strcpy (buffer, Areapath[0]);

	strcpy (Qbuf, area);
	
	while ((p = strchr (Qbuf, '\\')) != NULL) *p = '_';
	
	p = Qbuf;
	
	while (*p) {
		if (*p == EOF) break;
		if (!isalnum (*p)) *p = '_';
		p++;
	}
	
	p = strrchr (buffer, '\\');

	if (p)
		strncpy (++p, Qbuf, 8);
	else {
		log_line (6, "!Error can't add areas");
		return (-1);
	}
	
	for (i=0; i < msgareas; i++) {
		if (Dareas[i]) continue;
		if (!stricmp (buffer, Areapath[i])) {
			buffer[ strlen (buffer) - 1] = EOS;
			
			p = strrchr (buffer, '\\');
			if (!strlen (++p)) {
				log_line (6, "!Can't add area ....");
				return (-1);
			}
			i = 0;
		}
	}
	
	Areapath[msgareas] = ctl_string (buffer);
	
	Areaorg[msgareas] = ctl_string(Mainorg);

	Dareas[msgareas] = 0;
	
	Areamin[msgareas] = minmsgs;
	Areaday[msgareas] = def_days;
	
	Read_only[msgareas] = PUBLIC;
	Ausername[msgareas] = NULL;
	Areakeep[msgareas]  = KILLMSGS;
	if (doDEFgroup == TRUE) {
		Areagroup[msgareas] = Defaultgroup;
	} else {
		Areagroup[msgareas] = 0;
	}

	Tz[w] = Fzone;
	Tnt[w] = Fnet;
	Tne[w] = Fnode;
	Tp[w]  = Fpoint;
	
	++w;
	
	Tz[w] = Tnt[w] = Tne[w] = Tp[w] = (UWORD) -1;
	
	where = msgareas;
	
	++w;
	
	Tozone[where] = (UWORD *) myalloc((w+1) * sizeof(UWORD));
	Tonet[where] = (UWORD *) myalloc((w+1) * sizeof(UWORD));
	Tonode[where] = (UWORD *) myalloc((w+1) * sizeof(UWORD));
	Topoint[where] = (UWORD *) myalloc((w+1) * sizeof(UWORD));
	
	memset(Tozone[where], -1, w+1);
	memset(Tonet[where], -1, w+1);
	memset(Tonode[where], -1, w+1);
	memset(Topoint[where], -1, w+1);
	
	memmove(Tozone[where], Tz, sizeof(WORD) * w);
	memmove(Tonet[where], Tnt, sizeof(WORD) * w);
	memmove(Tonode[where], Tne, sizeof(WORD) * w);
	memmove(Topoint[where], Tp, sizeof(WORD) * w);

	log_line (5, "!Area %s added, writing ....", area);

	msgareas++;
	write_bin_areas();
	
	AreaAdded = TRUE;
	
	return (msgareas -1);
}

/*
BYTE AUTO_area (BYTE *msgtext, MSGHEADER *Hdr) {
	WORD 	i;
	BYTE	*q, *p,
			buffer[100],
			temp[100],
			retcode = 0;
			
	if (!Hdr->Opoint) return (0);

	p = msgtext;
		
	while (*p) {
		p = skip_blanks(p);
		if (!*p) break;
		if (*p == '\01') {
			p = skip_to_token(p, '\n');
			continue;
		}

		if (*p == '-') {
			if (!strncmp (p, "---", 3)) break;
			
			p = skip_blanks(&p[1]);
			for (q=temp; *p && !isspace(*p); *q++ = *p++);
			*q= EOS;
			
			AUTO_disconnect(Hdr, temp);
			retcode ++;
			continue;
		}
		
		if (*p == '+') p = skip_blanks(&p[1]);
		for (q=temp; *p && !isspace(*p); *q++ = *p++);
		*q= EOS;
		retcode ++;
		
		AUTO_connect(Hdr, temp);
	}
	
	return (retcode);
}

VOID AUTO_connect (MSGHEADER *Hdr, BYTE area) {
	WORD 	i, j;
	BYTE	Path[128], *q,
			c;
			
	for (i = 0; i < msgareas; i++) {
		if (!stricmp (temp, Areaname[i])) {
			log_line (6, "-Already connected to %s.", temp);
			return;
		}
	}
	
	i = msgareas++;
	
	strcpy (Path, Areapath[0]);
		
	Areaname[i] = ctl_string (area);
	strncat(Path, Areaname[i], 8);
	
	c = x020;
	
	for (j=0; j < msgareas; j++) {
		if (!stricmp (Path, Areapath[i])) {
			Path[strlen (Path) -1] = (BYTE) c;
			j = 0;
			c++
		}
	}
*/
	

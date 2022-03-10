/*********************************************************************

					IOS - configuration handler
					
	Program : IOSmail
    Source  : free
	Author  : Rinaldo Visscher
	Date    : 1991
	
	This part contains,
	
	Read configuration and parse it.
	Read AREAS.BBS and parse it.
	Read LED.NEW and parse it.
	Update LED.NEW
	
*********************************************************************/


#include		<stdio.h>
#include		<stdlib.h>
#include		<aes.h>

#if !defined LATTICE
#include		<ext.h>
#include		<tos.h>
#else
#include		<dos.h>
#include		<sys/stat.h>
#endif
#include		<ctype.h>
#include		<string.h>
#include		<time.h>
#include		<errno.h>

#include		"portab.h"

#include		"defs.h"
#include		"ioslib.h"

#include		"inmail.h"
#include		"strutil.h"
#include		"lang.h"

#include		"vars.h"


MLOCAL CONST BYTE	*Myweek[] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};

MLOCAL CONST BYTE	*DFTpkt[] = {"2.0","2+","2.1","2.2",NULL};

MLOCAL VOID check_N_space(VOID)
{
	if (nRouteDef >= MaxRouteDef)
	{
		if (MaxRouteDef >= 30000)
		{
			log_line(-1,Logmessage[M__ROUTE_OVERFLOW]);
			nRouteDef = 0;
			return;
		}
		
		MaxRouteDef += 1000;
		
		RouteDef = (struct _RouteDef *) realloc(RouteDef,
			MaxRouteDef * sizeof(struct _RouteDef));
		
		if (!RouteDef)
		{
			log_line(6,Logmessage[M__MEMORY_ERROR]);
			terminate(-31);
		}
	}
}

MLOCAL VOID parse_readdress(BYTE *line) {
	BYTE	*p, *q,
			temp[100];
	

	p = line;
	
	for (q=temp; *p && *p != ','; *q++=*p++);
	*q = EOS;
	if (!*p) goto Read_ERR;
	
	strncpy (readdress[nreaddress].fname, temp, 36);
	
	p = skip_blanks (++p);
	
	for (q=temp; *p && *p != ','; *q++=*p++);
	*q = EOS;
	if (!*p) goto Read_ERR;
	
	strncpy (readdress[nreaddress].fnode, temp, 20);

	p = skip_blanks (++p);
	
	for (q=temp; *p && *p != ','; *q++=*p++);
	*q = EOS;
	if (!*p) goto Read_ERR;
	
	strncpy (readdress[nreaddress].tname, temp, 36);

	p = skip_blanks (++p);

	for (q=temp; *p && *p != ','; *q++=*p++);
	*q = EOS;
	
	strncpy (readdress[nreaddress++].tnode, temp, 20);
	
	return;
	
	Read_ERR:
	
	log_line (-1, "!Error in Readdress line.");
}

MLOCAL BYTE *parse_event(BYTE *line)
{
	BYTE	*p = line,
			*q,
			temp[80],
			day[20];
	WORD	shour,
			smin,
			ehour,
			emin,
			start,
			end,
			now;
	LONG	secs_now;
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	strncpy(day, temp, 19);
	p = skip_blanks(p);
	
	if (!isdigit(*p))
	{
		Illegal_event:
		
		log_line(4,Logmessage[M__EVENT_ERROR]);
		return(NULL);
	}
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	p = skip_blanks(p);
	q = temp;
	shour = atoi(q);
	
	while (*q != ':' && *q) q++;
	
	if (!*q)
	{
		Illegal_date:
		
		log_line(4,Logmessage[M__DATE_ERROR]);
		return(NULL);
	}
	
	smin = atoi(++q);
	
	if (shour > 23 || smin > 59)
	{
		Illegal_hour:
		
		log_line(4,Logmessage[M__HOUR_ERROR]);
		return(NULL);
	}
	
	if (!isdigit(*p)) goto Illegal_event;
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	p = skip_blanks(p);
	q = temp;
	ehour = atoi(q);
	
	while (*q != ':' && *q) q++;
	if (!*q) goto Illegal_date;
	
	emin = atoi(++q);
	
	if (ehour > 23 || emin > 59) goto Illegal_hour;
	
	time(&secs_now);
	tijd = localtime(&secs_now);
	
	/*
	**	Weekends, week, day.
	*/
	
	if (stricmp(day, "all"))
	{
		if (!stricmp(day, "wkd") &&
			(tijd->tm_wday == 0) || (tijd->tm_wday == 6))
			goto have_event;
		
		if (!stricmp(day, "week"))
		{
			if (tijd->tm_wday == 0 || tijd->tm_wday == 6) return(NULL);
			goto have_event;
		}
		
		if (stricmp(day, Myweek[tijd->tm_wday])) return(NULL);
	}
	
	have_event:
	
	start = (shour * 60) + smin;
	end = (ehour * 60) + emin;
	now = (tijd->tm_hour * 60) + tijd->tm_min;
	
	if (start < end)
	{
		if (start <= now && now <= end)
			return(p);
		else
			return(NULL);
	}
	else
	{
		if ((start >= now && now < (24*60)) ||
			(now <= end && now >= 0))
			return(p);
		else
			return(NULL);
	}
}

MLOCAL VOID parsepassword(BYTE *line)
{
	BYTE	temp[80],
			*q,
			*p = skip_blanks(line);
	UWORD	i, j;
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	address(temp, &pwd[nkey].zone, &pwd[nkey].net, &pwd[nkey].node,
		&pwd[nkey].point, &i, pwd[nkey].Domain);
	
	pwd[nkey].mtype = TYPE3d;
	pwd[nkey].htype = FTS_TYPE;
	pwd[nkey].intl_type = TYPE4d;
	pwd[nkey].intl_always=FALSE;
	pwd[nkey].Uname[0] = EOS;
	pwd[nkey].Ugroup[0] = EOS;
	pwd[nkey].crash_to = NO_CRASH;
	pwd[nkey].Send_PKT = FALSE;
	pwd[nkey].TosScan = FALSE;
	
	j = 0;
	
	while (*p)
	{
		p = skip_blanks(p);
		if (!*p) break;

		if (*p == '"')
		{
			p++;
			j=0;
			while (*p != '"') {
				pwd[nkey].Uname[j++] = *p++;
				
				if (!*p) break;
			}
			p++;
			continue;
		}
		
		
		for (q = temp; *p && !isspace(*p); *q++ = *p++);
		*q = EOS;
		
		i = 0;
		
		if (*temp == '{') 
		{
			j = 1;
			
			while (temp[j] != '}')
			{
				pwd[nkey].Ugroup[i++] = temp[j++];
			}
			continue;
		}
		
		if (*temp == '$')
		{
			if (!strlen(&temp[1]))
			{
				log_line(-1,Logmessage[M__AREAFIX_PWD], line);
				continue;
			}
			
			strcpy(pwd[nkey].Afix, &temp[1]);
			continue;
		}
		
		if (!strcmp(temp, "*"))
		{
			pwd[nkey].mtype = TYPE4d;
			continue;
		}
		
		if (!strcmp(temp, "#"))
		{
			pwd[nkey].htype = FRONTDOOR;
			continue;
		}
		
		if (!strcmp(temp, "&"))
		{
			pwd[nkey].htype = TYPE_2_2;
			continue;
		}
		
		if (!strcmp(temp, "^"))
		{
			pwd[nkey].intl_type = TYPE3d;
			continue;
		}
		
		if (!strcmp(temp, "!"))
		{
			pwd[nkey].intl_always = TRUE;
			continue;
		}
		
		if (!strcmp (temp, "+"))
		{
			pwd[nkey].crash_to = AT_CRASH;
			continue;
		}
		
		if (!strcmp (temp, "-")) 
		{
			pwd[nkey].Send_PKT = TRUE;
			continue;
		}
		
		if (!strcmp (temp, "T"))
		{
			pwd[nkey].TosScan = TRUE;
			continue;
		}
		
		if (*temp == '*' || *temp == '#' || *temp == '^' ||
			*temp == '!' || *temp == '&' || *temp == '+' ||
			*temp == '-')
		{
			q = temp;
			
			while (*q)
			{
				if (*q == '*') pwd[nkey].mtype = TYPE3d;
				if (*q == '#') pwd[nkey].htype = FRONTDOOR;
				if (*q == '&') pwd[nkey].htype = TYPE_2_2;
				if (*q == '^') pwd[nkey].intl_type = TYPE3d;
				if (*q == '!') pwd[nkey].intl_always=TRUE;
				if (*q == '+') pwd[nkey].crash_to = AT_CRASH;
				if (*q == '-') pwd[nkey].Send_PKT = TRUE;
				if (*q == 'T') pwd[nkey].TosScan  = TRUE;
				q++;
			}
			
			continue;
		}
		
		if (*temp == '%')
		{
			if (!strnicmp(&temp[1], "lzhmail", 7))
			{
				pwd[nkey].arctype = isLZHmail;
				continue;
			}
			
			if (!strnicmp(&temp[1], "arcmail", 7))
			{
				pwd[nkey].arctype = isARCmail;
				continue;
			}
			
			if (!strnicmp(&temp[1], "zipmail", 7))
			{
				pwd[nkey].arctype = isZIPmail;
				continue;
			}

			if (!strnicmp(&temp[1], "arjmail", 7))
			{
				pwd[nkey].arctype = isARJmail;
				continue;
			}
		}
		
		strncpy(pwd[nkey].pwd, temp, 8);
	}
	
	nkey++;
}

MLOCAL VOID parse_domain(BYTE *line)
{
	BYTE	temp[128],
			*p = skip_blanks(line),
			*q;
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	Appl[domain].zone = atoi(temp);
	
	p = skip_blanks(p);
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	strcpy(Appl[domain].path, temp);
	
	
	p = skip_blanks(p);
	
	if (!*p) {
		Appl[domain].domain[0] = EOS;
		domain++;
		return ;
	}
	
	for (q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	strncpy(Appl[domain].domain, temp,40);
	
	if (strchr(Appl[domain].path, '\\') == NULL ||
		!strlen(Appl[domain].domain)) {
		log_line(-1, Logmessage[M__MISSING_DOMAIN]);
	} else {
		domain++;
	}
}

/*
**	Look for which nodes and points are connected to this area.
**	Store them in Tozone,Tonet,Tonode,Topoint.
**	line  : line with nodenumbers
**	where : which area
*/

MLOCAL VOID get_connected(BYTE *line, WORD where)
{
	BYTE	*p = skip_blanks(line),
			*q,
			Odomain[10],
			temp[80],
			*dummy = NULL;
	UWORD	w = 0,
			i, j, z,
			current_address = 0;
	
	while (*p)
	{
		if (dummy) free(dummy);
		
		for (q = temp; *p && !isspace(*p); *q++ = *p++);
		*q = EOS;
		
		dummy = ctl_string(temp);
		
		address(dummy, &Tz[w], &Tnt[w], &Tne[w], &Tp[w], &i, Odomain);
		
		if (!current_address) {
			if (strlen (Odomain)) {
				strcpy (Todomain [where], Odomain);
				Odomain [0] = EOS;
				current_address++;
			} else {
				log_line (6, "+Please add DOMAIN at area %s", Areaname[where]);
				exit (10);
			}
		}
		
		p = skip_blanks(p);
		w++;
	}
	
	Tz[w] = Tnt[w] = Tne[w] = Tp[w] = (-1);
	
	if (w > 1)
	{
		for (i = 0; i < nalias; i++)
		{
			if (Tz[0] == alias[i].zone)
			{
				for (z = 1; z < w; z++)
				{
					if (Tz[z] != Tz[0] && Tp[z])
					{
						for (j = 0; j < nkey; j++)
						{
							if (alias[i].zone == pwd[j].zone &&
								alias[i].net == pwd[j].net &&
								alias[i].node== pwd[j].node &&
								Tp[z] == pwd[j].point)
							{
								Tz[z] = alias[i].zone;
								Tnt[z] = alias[i].net;
								Tne[z] = alias[i].node;
								break;
							}
						}
					}
					else
					{
						for (j = 0; j < nkey; j++)
						{
							if (Tnt[z] == pwd[j].net &&
								Tne[z] == pwd[j].node)
							{
								Tz[z] = pwd[j].zone;
								break;
							}
						}
					}
				}
				break;
			}
		}
	}
	
	w++;

	/*
	**	Store numbers
	*/
	
	Tozone[where] = (UWORD *) myalloc((w+1) * sizeof(UWORD));
	Tonet[where] = (UWORD *) myalloc((w+1) * sizeof(UWORD));
	Tonode[where] = (UWORD *) myalloc((w+1) * sizeof(UWORD));
	Topoint[where] = (UWORD *) myalloc((w+1) * sizeof(UWORD));
	
	memset(Tozone[where], -1, w+1);
	memset(Tonet[where], -1, w+1);
	memset(Tonode[where], -1, w+1);
	memset(Topoint[where], -1, w+1);
	
	sort_connected(w, 1);
	
	memmove(Tozone[where], Tz, sizeof(WORD) * w);
	memmove(Tonet[where], Tnt, sizeof(WORD) * w);
	memmove(Tonode[where], Tne, sizeof(WORD) * w);
	memmove(Topoint[where], Tp, sizeof(WORD) * w);
	
	free(dummy);
}

/*
**	Read the areas we have.
*/
	
BOOLEAN read_areas(BYTE *filename, BYTE what)
{
	BYTE	buffer[2048],
			temp[130],
			*q, *p,
			Hday = 0,
			Horg = 0,
			Hmin = 0,
			Hrd  = 0,
			Hkp  = 0,
			Huse = 0,
			Hgr  = 0,
			Hrand=0,
			PASSarea = FALSE;
			
	WORD	i, attrib;
	
	sprintf(temp, "%s%s", Envpath, filename);
	if (findfirst(temp, &blok, 0)) sprintf(temp, "%s", filename);
	
	if ((FDUMMY = fopen(temp, "r")) == NULL)
	{
 		if (!what) log_line(-1,Logmessage[M__CANT_OPEN],temp);
		
		return(FALSE);
	}
	
	if (!what)
	{
		while (fgets(buffer, 2048, FDUMMY))
		{
			p = skip_blanks(buffer);
			if (*p == ';') continue;
			if ((i = (WORD)strlen(p)) < 3) continue;
			
			giveTIMEslice();
						
			p = &p[--i];
			*p = EOS;
			
			if ((p = strchr(buffer,';')) != NULL) *p = EOS;
			
			p = skip_blanks(buffer);
			
			if (*p)
			{
				Mainorg = ctl_string(p);
				break;
			}
			else continue;
		}
	}
	
	while (fgets(buffer, 2048, FDUMMY))
	{
		p = skip_blanks(buffer);
		if (*p == ';') continue;
		if ((i = (WORD)strlen(p)) < 3) continue;
		
		p = &p[--i];
		*p = EOS;
		
		if (what) PASSarea = TRUE;
		
		giveTIMEslice();
		
		if ((p = strchr(buffer, ';')) != NULL) *p = EOS;
		
		p = skip_blanks(buffer);
		if (!*p) continue;
		
		if (!Horg && !Hday && !Hmin && !Hrd && !Huse && !Hkp && !Hgr && !Hrand)
		{
			Areaday[msgareas] = -1;
			Areaorg[msgareas] = NULL;
			Randorgfile[msgareas] = NULL;

			Areamin[msgareas] = -1;
			Read_only[msgareas] = PUBLIC;
			Ausername[msgareas] = NULL;
			Areakeep[msgareas]  = KILLMSGS;
			if (doDEFgroup == TRUE) {
				Areagroup[msgareas] = Defaultgroup;
			} else {
				Areagroup[msgareas] = 0;
			}
		}
		
		if (*p == '-')
		{
			switch (toupper(*++p))
			{
				case 'O':		/* Origin line */
				
					p = skip_to_blank(p);
					Areaorg[msgareas] = ctl_string(p);
					Horg++;
					break;
				
				case 'D':		/* Days */
				
					p = skip_to_blank(p);
					p = skip_blanks(p);
					Areaday[msgareas] = atoi(p);
					Hday++;
					break;
				
				case 'G':
					p = skip_to_blank(p);
					p = skip_blanks(p);
					
					if (*p) {
						if (isalnum(*p))
							Areagroup[msgareas] = *p;
					}
					Hgr++;
					break;

				case 'M':
						
					p = skip_to_blank(p);
					p = skip_blanks(p);
					Areamin[msgareas] = atoi(p);
					Hmin++;
					break;
				
				case 'N':
					if (Huse) break;
					p = skip_to_blank(p);
					p = skip_blanks(p);
					Ausername[msgareas] = ctl_string(p);
					Huse++;
					break;
				
				case 'K':
					Areakeep[msgareas] = KEEPMSGS;
					Hkp++;
					break;

				case 'L':
				
					Read_only[msgareas] = READ_ONLY;
					Hrd++;
					break;
					
				case 'R':
					p = skip_to_blank(p);
					p = skip_blanks(p);
					
					if (!*p) {
						log_line(4,Logmessage[M__NO_REMOTE]);
						break;
					}
					
					Read_only[msgareas] = REMOTE_ONLY;
					ROnode[msgareas] = ctl_string(p);
					Hrd++;
					break;
				
				case 'F':
					p = skip_to_blank(p);
					p = skip_blanks(p);
					if (!*p) {
						log_line(3,Logmessage[M__NO_ORIGINFILE]);
						break;
					}
					Randorgfile[msgareas] = ctl_file(p);
					Hrand++;
					break;
					
				case 'P':
					PASSarea = TRUE;
					break;

			}
			
			continue;
		}
		
		/*
		**	Get areapath first if not DAREAS file
		**
		**	if this area has the magic name:
		**	MAIL
		**	then this is the netmail. Copy it and continue
		*/
		
		if (!what || PASSarea == FALSE)
		{
			for (q = temp; *p && !isspace(*p); *q++ = *p++);
			*q = EOS;
			Areapath[msgareas] = ctl_string(temp);
		}
		
		/*
		**	Get areaname next
		*/
		
		p = skip_blanks(p);
		
		for (q = temp; *p && !isspace(*p); *q++ = *p++);
		*q = EOS;
		
		/*
		**	Netmail path found in areas
		*/
		
		if (!stricmp(temp, "mail"))
		{
			if (strlen(mailarea)) free(mailarea);
			
			mailarea = (BYTE *) myalloc(strlen(Areapath[msgareas]) + 10);
			sprintf(mailarea, "%s", Areapath[msgareas]);
			
			if (Areaday[msgareas] == -1) maildays = def_days;
			else maildays = Areaday[msgareas];
			
			if(Areamin[msgareas] == -1) mailmin = minmsgs;
			else mailmin = Areamin[msgareas];
			
			mailkeep = Areakeep[msgareas];
			Horg = Hday = Hmin = Hrd = Huse = Hkp = Hgr = Hrand = 0;
			
			continue;
		}
		
		/*
		**	Trasharea path found in areas
		*/
		
		if (!stricmp(temp, "trasharea"))
		{
			if (strlen(trasharea)) free(trasharea);
			
			trasharea = (BYTE *) myalloc(strlen(Areapath[msgareas]) + 10);
			sprintf(trasharea, "%s", Areapath[msgareas]);
			
			if (Areaday[msgareas] == -1) trashdays = def_days;
			else trashdays = Areaday[msgareas];
			
			if (Areamin[msgareas] == -1) trashmin = minmsgs;
			else trashmin = Areamin[msgareas];
			
			trashkeep = Areakeep[msgareas];
			Horg = Hday = Hmin = Hrd = Huse = Hkp = Hgr = Hrand = 0;
			
			continue;
		}
		
		/*
		**	Dupe messages in this area.
		*/
		
		if (!stricmp(temp, "dupe_area"))
		{
			if (strlen(dupearea)) free(dupearea);
			dupearea = ctl_string (Areapath[msgareas]);

			if (Areaday[msgareas] == -1) dupedays = def_days;
			else dupedays = Areaday[msgareas];
			
			if(Areamin[msgareas] == -1) dupemin = minmsgs;
			else dupemin = Areamin[msgareas];
			
			dupekeep = Areakeep[msgareas];
			Horg = Hday = Hmin = Hrd = Huse = Hkp = Hgr = Hrand = 0;
			
			continue;
		}
			
		if (!stricmp(temp, "privateboxarea"))
		{
			PVTmailBOX:
			
			if (strlen(privatebox)) free(privatebox);
			
			privatebox = (BYTE *) myalloc(strlen(Areapath[msgareas]) +10);
			sprintf(privatebox, "%s", Areapath[msgareas]);
			
			if (Areaday[msgareas] == -1) pvtboxdays = def_days;
			else pvtboxdays = Areaday[msgareas];
			
			if(Areamin[msgareas] == -1) pvtboxmin = minmsgs;
			else pvtboxmin = Areamin[msgareas];
			
			pvtkeep = Areakeep[msgareas];
			Horg = Hday = Hmin = Hrd = Huse = Hkp = Hgr = Hrand = 0;
			
			continue;
		}
		
		if (!stricmp(temp, "privatemailbox")) goto PVTmailBOX;
		if (!stricmp(temp, "privatemail")) goto PVTmailBOX;
		
		/*
		**	Normal echomail
		*/
		
		Areaname[msgareas] = ctl_string(temp);
		
		p = skip_blanks(p);
		
		/*
		**	Check on non nummeric numbers.
		*/
		
		if (!isdigit (*p) && strlen (p)) {
			log_line (6, "!Error in areafile, no nodenumber specified.");
			terminate (10);
		}
				
		/*
		**	Store connected systems as words
		*/
		
		get_connected(p, msgareas);
		
		/*
		**	Look for origin etc.
		*/

		if (Areaorg[msgareas] == NULL) Areaorg[msgareas] = ctl_string(Mainorg);
		
		if (Areaday[msgareas] == -1) Areaday[msgareas] = def_days;
		if (Areamin[msgareas] == -1) Areamin[msgareas] = minmsgs;
		
		Areamsgs[msgareas] = 0;
		Tosysop[msgareas] = 0;
		Horg = Hday = Hmin = Hrd = Huse = Hkp = Hgr = Hrand = 0;
		
		if (PASSarea == TRUE)
			Dareas[msgareas++] = 1;
		else
			Dareas[msgareas++] = what;
			
		PASSarea = FALSE;
	}
	
	fclose(FDUMMY);
	sprintf(temp, "%s%s", Envpath, filename);
	attrib = Fattrib(temp, 0, -1);
	if (attrib != -33 && attrib != -34 && attrib & FA_ARCHIVE)
	{
		if (intel(Sversion()) >= 0x0015U)
			Fattrib(temp, 1, 0);
		else
			Fattrib(temp, 1, FA_ARCHIVE);
	}
		
	return (TRUE);
}

VOID read_lednew(VOID)
{
	CONST BYTE	*filename = "LED.NEW";
	BYTE		buffer[2048],
				temp[130],
				*q, *p;
	WORD		i;
	
	sprintf(temp, "%s%s", Envpath, filename);
	
	if ((FDUMMY = fopen(temp, "r")) == NULL)
	{
		log_line(-1,Logmessage[M__NO_OPEN_CREATE], temp);
		
		for (i = 0; i < msgareas; i++)
		{
			Lareaname[i] = ctl_string(Areaname[i]);
			Lledmask[i] = Lledmsgs[i] = 0;
		}
		
		nled = msgareas;
		return;
	}
	
	while (fgets(buffer, 2048, FDUMMY))
	{
		p = skip_blanks(buffer);
		if (*p == ';') continue;
		if ((i = (WORD)strlen(p)) < 3) continue;
		
		giveTIMEslice();
		
		p = &p[--i];
		*p = EOS;
		
		if ((p = strchr(buffer, ';')) != NULL) *p = EOS;
		
		p = skip_blanks(buffer);
		if (!*p) continue;
		
		for (q = temp; *p && !isspace(*p); *q++ = *p++);
		*q = EOS;
		
		Lareaname[nled] = ctl_string(temp);
		
		p = skip_blanks(p);
		
		if (!*p)
		{
			Lledmsgs[nled] = Lledmask[nled++] = 0;
			continue;
		}
		
		for (q = temp; *p && !isspace(*p); *q++ = *p++);
		*q = EOS;
		
		Lledmsgs[nled] = atoi(temp);
		
		p = skip_blanks(p);
		
		if (!*p)
		{
			Lledmask[nled++] = 0;
			continue;
		}
		
		Lledmask[nled++] = atoi(p);
	}
	
	fclose(FDUMMY);
	
	return;
}

VOID write_lednew(VOID)
{
	BYTE	buffer[128];
	WORD	i, j;
	
	log_line(4,Logmessage[M__WRITE_LASTRD]);
	
	sprintf(buffer, "%sLED.NEW", Envpath);
	
	if ((OUT = fopen(buffer, "w")) == NULL)
	{
		log_line(6,Logmessage[M__CANT_OPEN_LR]);
		return;
	}
	
	if (nnetmails) {
		if(nled) {
			if (Lareaname[0])
				fprintf(OUT, "%s %d %d\n", Lareaname[0], Lledmsgs[0],
					(Lledmask[0] | (UNREADMSGS|NEWMSGS|SYSOPMSGS)));
		}
		else if (Lareaname[0])
			fprintf(OUT, "%-20s 0 4\n", "FidoNetmail");
	}
	else if (Lareaname[0])
		fprintf(OUT, "%-20s %d %d\n", Lareaname[0], Lledmsgs[0], Lledmask[0]);
	
	for (i = 0; i < msgareas; i++)
	{
		if (Dareas[i]) continue;
		
		for (j = 0; j < nled; j++) {
			giveTIMEslice();
			
			if (Lareaname[j]) {
				if (!stricmp(Lareaname[j], Areaname[i]))
				{
					if (Tosysop[i]) Lledmask[j] |= SYSOPMSGS;
					
					fprintf(OUT, "%-20s %d %d\n", Lareaname[j], Lledmsgs[j],
						(Areamsgs[i]) ? (Lledmask[j] | (UNREADMSGS|NEWMSGS)) : Lledmask[j]);
					break;
				}
			}
		}
		if (j >= nled) fprintf(OUT, "%-20s 0 %d\n", Areaname[i], (UNREADMSGS|NEWMSGS));
	}
	
	for (i = 0; i < nled; i++)
	{
		if (!stricmp(Lareaname[i], "privateboxarea"))
		{
			strcpy(buffer, "PRIVATEBOXAREA");
			break;
		}
		
		if (!stricmp(Lareaname[i], "privatemailbox"))
		{
			strcpy(buffer, "PRIVATEMAILAREA");
			break;
		}
		
		if (!stricmp(Lareaname[i], "privatemail"))
		{
			strcpy(buffer, "PRIVATEMAIL");
			break;
		}
	}
	
	if (i < nled) fprintf(OUT, "%-20s %d %d\n", buffer, Lledmsgs[i],
		(nprivate) ? (Lledmask[i] | (UNREADMSGS|NEWMSGS)) : Lledmask[i]);
	
	for (i = 0; i < nled; i++)
		if (!stricmp(Lareaname[i], "trasharea"))
		{
			fprintf(OUT, "%-20s %d %d\n", "TRASHAREA", Lledmsgs[i],
				(ntrashed) ? (Lledmask[i] | (UNREADMSGS|NEWMSGS)) : Lledmask[i]);
			break;
		}
	
	for (i = 0; i < nled; i++) {
		if (stricmp(Lareaname[i], "dupearea")) {
			fprintf(OUT, "%-20s %d %d\n", "DUPEAREA", Lledmsgs[i],
			(HaveDUPES) ? (Lledmask[i] | (NEWMSGS)) : Lledmask[i]);
			break;
		}
	}
	
	fclose(OUT); 
}

BOOLEAN init_cfg(BOOLEAN *foundlabel)
{
	BYTE	*p = getenv("MAILER"),
			*q,
			*cfgname = CONFIGFILE,
			buffer[1024],		/*	line buffer of statements	*/
			temp[1024],
			*havelabel = "",	/*	having labels				*/
			uselabel = NOLABEL,
			No[30];
	WORD	line = 0;
	UWORD	i;					/*	dummy integer				*/
	
	if (findfirst(cfgname, &blok, 0) && p && *p != EOS)
		Envpath = ctl_path(p);
	
	Inboundpaths[0] = Inboundpaths[1] = Inboundpaths[2] = NULL;
	
	sprintf(buffer, "%s%s", Envpath, cfgname);
	
#if defined EXTERNDEBUG
	log_line(6,">Environment path = %s", Envpath);
	log_line(6,">Config assumed as %s", buffer);
#endif
	
	if ((FDUMMY = fopen(buffer, "r")) == NULL)
	{
		log_line(-1,Logmessage[M__CONFIG_NOT_FOUND], buffer);
		return(FALSE);
	}
	
	RouteDef = (struct _RouteDef *) myalloc(1000L * sizeof(struct _RouteDef));
	MaxRouteDef = 1000;
	
	Dateformat[0] = EOS;
	
	while ((fgets(buffer, 1023, FDUMMY)))
	{
		line++;
		p = skip_blanks(buffer);
		
		giveTIMEslice();
		
		if (*p == ';') continue;
		if ((i = (WORD)strlen(p)) < 3) continue;
		if ((p = strchr(buffer, ';')) != NULL) *p = EOS;
		
		p = &buffer[--i];
		
		if (*p == '\r' || *p == '\n') *p = EOS;
		
		p = skip_blanks(buffer);
		
		/*
		**	Using labels? Label starts always with an '#'
		**	If in the defined label, take all commands etc.
		*/
		
		if (dolabel)
		{
			if (*p == '#')
			{
				if (strlen(havelabel)) free(havelabel);
				
				havelabel = ctl_string(skip_blanks(&p[1]));
				uselabel = USELABEL;
				
				if (!stricmp(havelabel, configlabel))
					*foundlabel = TRUE;
				
				if (!stricmp(havelabel, "endlabel"))
					uselabel = ENDLABEL;
				if (!stricmp(havelabel, "endall"))
				{
					uselabel = NOLABEL;
					dolabel = FALSE;
					continue;
				}
				
				continue;
			}
			
			if (uselabel && (stricmp(havelabel, configlabel) ||
				uselabel == ENDLABEL)) continue;
			else
				*foundlabel = TRUE;
		}
		
		if (*p == '#') continue;
		
		if (!strnicmp(p, "event", 5))
		{
			p = skip_blanks(&p[5]);
			if ((p = parse_event(p)) == NULL) continue;
		}
		
		if (!strnicmp(p, "commands", 8))
		{
			if (!dolabel) continue;
			p = &p[8];
			
			while (*p)
			{
				p = skip_blanks(++p);
				if (!*p) break;
				if (*p == '-') p++;
				
				if (*p)
					switch (toupper(*p))
					{
						case	'A':	keepmsg = TRUE; break;
						case	'B':	toprivate = TRUE; break;
						case	'C':	dochanged = TRUE; break;
						case	'D':	docrunch = TRUE; break;
						case	'E':	log_line(-1,Logmessage[M__CANT_EXEC_LABEL]);
										break;
						case	'H':	log_line(-1,Logmessage[M__NO_HELP]);
										break;
						case	'I':	doimport = TRUE; break;
						case	'K':	doifna = TRUE; break;
						case	'L':	doled = TRUE; break;
						case	'M':	domsg = TRUE; break;
						case	'O':	dopack = TRUE; break;
						case	'P':	dopkt = TRUE; break;
						case	'Q':	doquit = TRUE; break;
						case	'R':	dosecure = TRUE; break;
						case	'S':	doscanmail = TRUE; break;
						case	'T':	dolog = TRUE; break;
						case	'V':	CRspec = TRUE; break;
						case	'W':	dowait = TRUE; break;
						case	'X':	domulti_reg = TRUE; break;
						case	'Z':	dostripzone = TRUE; break;
						
						default:	log_line(-1,Logmessage[M__SWITCH_CONF], *p, line, CONFIGFILE);
					}
				else
					log_line(-1,Logmessage[M__NO_COMMAND], line, CONFIGFILE);
			}
			
			continue;
		}
		
		if (!strnicmp(p, "sysop", 5))
		{
			p = skip_blanks(&p[5]);
			p = skip_after_blanks(p);
			
			strncpy(SysOp, p, 78);
			SysOp[77] = EOS;
			continue;
		}
		
		if (!strnicmp(p, "address", 7))
		{
			p = skip_blanks(&p[7]);
			
			address(p, &alias[nalias].zone, &alias[nalias].net,
						&alias[nalias].node, &alias[nalias].point,
						&alias[nalias].pointnet, alias[nalias].Domain);
			
			nalias++;
			continue;
		}
		
		if (!strnicmp(p, "netmail", 7))
		{
			mailarea = ctl_string(&p[7]);
			continue;
		}
		
		if (!strnicmp(p, "logfile", 7))
		{
			if (!strlen(logfile)) logfile = ctl_string(&p[7]);
			continue;
		}
		
		if(!strnicmp(p,"loglevel",8)) {
			p = skip_blanks(&p[8]);
			if(!*p || !isdigit(*p)) 
				log_line(-1,Logmessage[M__NO_LOGLEVEL]);
			else
				loglevel = atoi(p);
			continue;
		}
		
		if (!strnicmp(p, "nolog", 5))
		{
			p = skip_blanks(&p[5]);
			
			if (*p == EOS) continue;
			
			for (i=0; i < strlen(p); i++)
				if (strchr(logtypes, p[i]))
					*(strchr(logtypes, p[i])) = ' ';
			
			continue;
		}
		
		if (!strnicmp(p, "nodisplay", 9))
		{
			p = skip_blanks(&p[9]);
			
			if (*p == EOS) continue;
			
			for (i=0; i < strlen(p); i++)
				if (strchr(disptypes, p[i]))
					*(strchr(disptypes, p[i])) = ' ';
			
			continue;
		}
		
		if (!strnicmp(p, "mailtemp", 8))
		{
			mailtemp = ctl_path(&p[8]);
			continue;
		}
		
		if (!strnicmp(p, "pkttemp",7)) {
			pkt_temp = ctl_path(&p[7]);
			continue;
		}
		
		if (!strnicmp(p, "outbound", 8))
		{
			outbound = ctl_path(&p[8]);
			continue;
		}
		
		if (!strnicmp(p, "inbound", 7))
		{
			Inboundpaths[2] = ctl_path(&p[7]);
			continue;
		}
		
		if (!strnicmp(p, "knowninbound", 12))
		{
			Inboundpaths[1] = ctl_path(&p[12]);
			continue;
		}
		
		if (!strnicmp(p, "protinbound", 11))
		{
			Inboundpaths[0] = ctl_path(&p[11]);
			continue;
		}
		
		if (!strnicmp(p, "trasharea", 9))
		{
			trasharea = ctl_file(&p[9]);
			continue;
		}
		
		if (!strnicmp(p, "archiver", 8))
		{
			p = skip_blanks(&p[8]);
			
			for (q = temp; *p && !isspace(*p); *q++ = *p++);
			*q = EOS;
			
			Arch = ctl_string(temp);
			
			p = skip_blanks(p);
			if (*p)
			{
				for (q = temp; *p && !isspace(*p); *q++ = *p++);
				*q = EOS;
				
				Archcmdi = ctl_string(temp);
				
				p = skip_blanks(p);
				if (*p) Archcmdo = ctl_string(p);
				else goto ARCcommand_error;
			}
			else goto ARCcommand_error;
			
			continue;
		}
		
		if (!strnicmp(p, "lzharchive", 10))
		{
			p = skip_blanks(&p[10]);
			for (q = temp; *p && !isspace(*p); *q++ = *p++);
			*q = EOS;
			
			Lzh = ctl_file(temp);
			
			p = skip_blanks(p);
			if (*p)
			{
				for (q = temp; *p && !isspace(*p); *q++ = *p++);
				*q = EOS;
				
				LzheC = ctl_string(temp);
				
				p = skip_blanks(p);
				if (*p) LzheA = ctl_string(p);
				else goto ARCcommand_error;
			}
			else
			{
				ARCcommand_error:
				
				log_line(-1,Logmessage[M__ARCHIVER_CMD_UNKN], line, CONFIGFILE);
			}
			
			continue;
		}
		
		if (!strnicmp(p, "arcarchive", 10))
		{
			p = skip_blanks(&p[10]);
			for (q = temp; *p && !isspace(*p); *q++ = *p++);
			*q = EOS;
			
			Arc = ctl_file(temp);
			
			p = skip_blanks(p);
			if (*p)
			{
				for (q = temp; *p && !isspace(*p); *q++ = *p++);
				*q = EOS;
				
				ArceC = ctl_string(temp);
				
				p = skip_blanks(p);
				if (*p) ArceA = ctl_string(p);
				else goto ARCcommand_error;
			}
			else goto ARCcommand_error;
			
			continue;
		}
		
		if (!strnicmp(p, "ziparchive", 10))
		{
			p = skip_blanks(&p[10]);
			for (q = temp; *p && !isspace(*p); *q++ = *p++);
			*q = EOS;
			
			Zip = ctl_file(temp);
			
			p = skip_blanks(p);
			if (*p)
			{
				for (q = temp; *p && !isspace(*p); *q++ = *p++);
				*q = EOS;
				
				ZipeC = ctl_string(temp);
				
				p = skip_blanks(p);
				if (*p) ZipeA = ctl_string(p);
				else goto ARCcommand_error;
			}
			else goto ARCcommand_error;
			
			continue;
		}
		
		if (!strnicmp(p, "arjarchive", 10))
		{
			p = skip_blanks(&p[10]);
			for (q = temp; *p && !isspace(*p); *q++ = *p++);
			*q = EOS;
			
			Arj = ctl_file(temp);
			
			p = skip_blanks(p);
			if (*p)
			{
				for (q = temp; *p && !isspace(*p); *q++ = *p++);
				*q = EOS;
				
				ArjeC = ctl_string(temp);
				
				p = skip_blanks(p);
				if (*p) ArjeA = ctl_string(p);
				else goto ARCcommand_error;
			}
			else goto ARCcommand_error;
			
			continue;
		}
		
		if (!strnicmp(p, "applzone", 8))
		{
			p = skip_blanks(&p[8]);
			parse_domain(p);
			
			continue;
		}

		if(!strnicmp(p,"newbinkley",10)) {
			donewbink = TRUE;
			continue;
		}
		
		if(!strnicmp(p,"the-box",7)) {
			dothebox = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "password", 8))
		{
			p = skip_blanks(&p[8]);
			parsepassword(p);
			
			continue;
		}
		
		if (!strnicmp(p, "boss", 4))
		{
			p = skip_blanks(&p[4]);
			
			address(p, &bosszone[nbosses], &bossnet[nbosses],
				&bossnode[nbosses], &i, &i, q);
			nbosses++;
			
			continue;
		}

		if(!strnicmp(p,"copyarea",8)) {
			p = skip_blanks(&p[8]);
			
			Copy_or_Move(p,COPYAREA);
			
			continue;
		}
		
		if (!strnicmp(p,"movearea",8)) {
			p = skip_blanks(&p[8]);
			
			Copy_or_Move(p,MOVEAREA);
			
			continue;
		}
		
		if (!strnicmp(p,"copy-to-point",13)) {
			dopointcpy = TRUE;
			continue;
		}

		if (!strnicmp(p, "nodupecheck",11)) {
			doNOdupecheck = TRUE;
			continue;
		}
				
		if (!strnicmp(p,"fdatabase",9)) {
			p = skip_blanks(&p[9]);
			
			if ( !*p ) {
				log_line(-1,Logmessage[M__EMPTY_DBASE]);
				continue;
			}
			
			if (strlen(FDbase)) {
				log_line(-1,Logmessage[M__DBASE_KNOWN]);
				continue;
			}
			
			FDbase = ctl_path(p);
			
			continue;
		}
		
		if (!strnicmp(p,"fdgetfrom",9)) {
			p = skip_blanks(&p[9]);
			
			if (!*p) {
				log_line(-1,Logmessage[M__NO_NAME_DBASE]);
				continue;
			}
			
			if (*p != '<' || *p != '>') {
				log_line(-1,Logmessage[M__DIRECTION_ERROR]);
				continue;
			}
			
			if (*p == '<') FDcompare[nfdbase] = FD_FROM;
			else           FDcompare[nfdbase] = FD_TO;
			
			ToBase[nfdbase++] = ctl_string(&p[1]);
			
			continue;
		}

		if (!strnicmp(p, "dateformat", 10)) {
			p = skip_blanks(&p[10]);
			p = skip_after_blanks(p);
			
			strncpy (Dateformat, p, 79);
			continue;
		}
		
		if (!strnicmp(p, "shorttear", 9)) {
			doonly_tear = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "adddomain",9)) {
			doadd_domain = TRUE;
			p = skip_blanks(&p[9]);
			while (*p) {
				if (*p && isdigit(*p)) {
					for (q=temp; *p && !isspace(*p); *q++ = *p++);
					*q= EOS;
					if (strlen(temp))
						Zdomain[Ndomain++] = atoi(temp);
					p = skip_blanks(p);
				} else {
					p = skip_to_blank(p);
					p = skip_blanks(p);
				}
				if (!*p) break;
			}
			continue;
		}
		
		if (!strnicmp(p, "nopoint", 7)) {
			p = skip_blanks(&p[7]);
			while (*p) {
				if (*p && isdigit(*p)) {
					for(q=temp ; *p && !isspace(*p); *q++=*p++);
					*q = EOS;
					if (strlen(temp)) 
						Zpoint[Npoint++] = atoi(temp);
					p = skip_blanks(p);
				} else {
					p = skip_to_blank(p);
					p = skip_blanks(p);
				}
				if (!*p) break;
			}
			continue;
		}
		
		if (!strnicmp(p, "multitasker", 11)) {
			p = skip_blanks(&p[11]);
			p = skip_after_blanks(p);
			
			for (i=0 ;Mtasker[i] != NULL; i++) {
				if (!stricmp(p , Mtasker[i]))
					MTask = i+1;
				
			}
			
			if (MTask == MULTIGEM) install_gem();
			
			continue;
		}

		if (!strnicmp(p, "fastimport", 10)) {
			dofastimport = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "tinyseenby", 10)) {
			donopointadd = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "tinypath", 8)) {
			donopointpath = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "defaultpkt", 10)) {
			p = skip_blanks(&p[10]);
			
			if (!*p) continue;
			
			for (i=0; DFTpkt[i] != NULL; i++) {
				if (!strnicmp(p, DFTpkt[i], strlen(DFTpkt[i]))) {
					defPKT = i;
					break;
				}
			}
			continue;
		}
		
		if (!strnicmp(p, "sendalwayspkt", 13)) {
			dosentpkt = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "checknames", 10)) {
			docheckname = TRUE;
			continue;
		}

		if (!strnicmp(p, "strippid", 8)) {
			dostripPID = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "msgbuffer", 9)) {
			p = skip_blanks(&p[9]);
			
			if (isdigit(*p)) {
				for (q=temp; *p && !isspace(*p); *q++=*p++);
				*q=EOS;
				MAXMSGLENGTH = atol(temp);
				if (MAXMSGLENGTH < 8192L)
					MAXMSGLENGTH = 8192L;
			}
			continue;
		}

		if (!strnicmp(p, "4dmsgheader", 11)) {
			MSGheader4d = TRUE;
			continue;
		}
		
		if (!strnicmp (p, "KeepFidoBits", 12)) {
			SENDfido_bits = TRUE;
			continue;
		}

		if (!strnicmp(p, "stripcontrols", 12)) {
			dostripINTL = TRUE;
			continue;
		}
		
		if (!strnicmp (p, "auto-addareas", 13)) {
			doAUTOaddareas = TRUE;
			continue;
		}
				
		if (!strnicmp(p, "killfrom", 8)) {
			p = skip_blanks(&p[8]);
			
			if (!*p)
			{
				log_line(-1,Logmessage[M__NO_NAME_KILL], line, CONFIGFILE);
				continue;
			}
			
			Killfrom[nkill++] = ctl_string(p);
			continue;
		}
		
		if (!strnicmp( p, "defaultgroup", 12)) {
			p = skip_blanks(&p[12]);
			strncpy( &Defaultgroup, p, 1);
			doDEFgroup = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "minpacketsize", 13))
		{
			p = skip_blanks(&p[13]);
			minpktsize = atol(p);
			continue;
		}
		
		if (!strnicmp(p, "dupelog", 7)) {
			p = skip_blanks(&p[7]);
			DupeLog = atol(p);
			continue;
		}
		
#if defined OUTDEBUG
		if (!strnicmp(p, "outmaildebug", 12))
		{
			dooutdeb = TRUE;
			continue;
		}
#endif
		
		if (!strnicmp(p, "nonetmailpack", 13))
		{
			donopack = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "redirectnetmail", 15))
		{
			doredirect = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "addaka", 6))
		{
			doadd_AKA = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "pathcheck", 9))
		{
			dopathcheck = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "nozone", 6))
		{
			donozone = TRUE;
			continue;
		}
		
#if defined EXTERNDEBUG
		if (!strnicmp(p, "debug", 5))
		{
			debugflag = TRUE;
			continue;
		}
#endif
		
		if (!strnicmp(p, "niceoutput", 10))
		{
			doniceout = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "qbbslastread", 12))
		{
			p = skip_blanks(&p[12]);
			
			if (!*p)
			{
				log_line(-1,Logmessage[M__NO_QBBS]);
				continue;
			}
			
			Qbbslr = ctl_file(p);
			doQbbslr = TRUE;
			
			continue;
		}
		
		if (!strnicmp(p, "mindiskspace", 12))
		{
			p = skip_blanks(&p[12]);
			
			if (!*p)
			{
				log_line(-1,Logmessage[M__NO_NUMBER_DISKSPC], line, CONFIGFILE);
				
				continue;
			}
			
			mindiskspace = atol(p);
			dodiskcheck = TRUE;
			
			continue;
		}
		
		if (!strnicmp(p, "minmessages", 11))
		{
			p = skip_blanks(&p[11]);
			
			if (isdigit(*p)) minmsgs = atoi(p);
			continue;
		}
		
		if (!strnicmp(p, "maxmessages", 11))
		{
			p = skip_blanks(&p[11]);
			
			if (isdigit(*p)) maxmsgs = (UWORD) atoi(p);
			continue;
		}
		
		if (!strnicmp(p, "defdays", 7))
		{
			p = skip_blanks(&p[7]);
			
			if (isdigit(*p)) def_days = atoi(p);
			continue;
		}
		
		if (!strnicmp(p, "compactmsgs", 11))
		{
			p = skip_blanks(&p[11]);
			
			if (isdigit(*p)) defcrunch = (BYTE) atoi(p);
			if (defcrunch > CRUNCHALWAYS) defcrunch = AFTERSCAN;
			
			continue;
		}
		
		if (!strnicmp(p, "keepprivate", 11))
		{
			dosaveprivate = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "killsent", 8))
		{
			dokillsent = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "msgreport", 9))
		{
			doreport = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "realname", 8))
		{
			p = skip_blanks(&p[8]);
			
			if (isdigit(*p)) dorealname = (BYTE) atoi(p);
			else dorealname = REALAL;
			
			continue;
		}
		
		if (!strnicmp(p, "killall", 7))
		{
			dokillall = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "copypvtmail", 11))
		{
			dopvtmail = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "packknown", 9))
		{
			doknown = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "areafix", 7))
		{
			p = skip_blanks(&p[7]);
			
			for (q = temp; *p && !isspace(*p); *q++ =*p++);
			*q = EOS;
			
			Areafix = ctl_string(temp);
			
			p = skip_blanks(p);
			p = skip_after_blanks(p);
			
			Areafixcmd = (BYTE *) myalloc(strlen(p)+2);
			strcpy(Areafixcmd, p);
			
			doareafix = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "capture", 7))
		{
			p = skip_blanks(&p[7]);
			
			address(p, &capbuf[ncapbuf].zone, &capbuf[ncapbuf].net,
				&capbuf[ncapbuf].node, &capbuf[ncapbuf].point, &i, q);
			
			p = skip_to_blank(p);
			p = skip_blanks(p);
			p = skip_after_blanks(p);
			strcpy(capbuf[ncapbuf++].name, p);
			
			continue;
		}
		
		if (!strnicmp(p, "savelocal", 9))
		{
			dosavelocal = TRUE;
			continue;
		}
		
		if (!strnicmp(p, "savescreen", 10))
		{
			p = skip_blanks(&p[10]);
			
			_screen = atoi(p);
			continue;
		}
		
		if (!strnicmp (p, "readdress", 9)) {
			p = skip_blanks (&p[9]);
			
			parse_readdress(p);
			continue;
		}
		
		if (!strnicmp (p, "trackmessage", 12)) {
			p = skip_blanks(&p[12]);

			TRACKmsg = ctl_string (p);
			continue;
		}
		
		if (!strnicmp (p ,"nodelist", 8)) {
			p = skip_blanks (&p[8]);
			
			NODElist[nnodelist++] = ctl_string(p);
			continue;
		}
		
		if (!strnicmp(p, "arc-for", 7))
		{
			p = skip_blanks(&p[7]);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = SENDARC;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef++].destnode, temp, 29);
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}
		
		if (!strnicmp (p, "track-except", 12)) {
			
			doNODELIST = TRUE;
			
			p = skip_blanks(&p[12]);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = MSGTRACK;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef++].destnode, temp, 29);
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}
		
		if (!strnicmp(p, "move-mail", 9))
		{
			p = skip_blanks(&p[9]);
			
			for (q = temp; *p && !isspace(*p); *q++=*p++);
			*q = EOS;
			
			if (!*p)
			{
				log_line(-1,Logmessage[M__NO_NODE_MOVE_M], temp);
				RouteDef[nRouteDef].flags = 0;
				
				continue;
			}
			
			strncpy(No, temp, 29);
			
			p = skip_blanks(p);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = KNOWNAS;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef].fromnode, temp, 29);
				strcpy(RouteDef[nRouteDef++].destnode, No);
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}
		
		if (!strnicmp(p, "hold-for", 8))
		{
			p = skip_blanks(&p[8]);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = HOLDMSG;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy((BYTE *)RouteDef[nRouteDef++].destnode, temp, 29);
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}
		
		if (!strnicmp(p, "route", 5))
		{
			p = skip_blanks(&p[5]);
			
			for (q = temp; *p && !isspace(*p); *q++=*p++);
			*q = EOS;
			
			strncpy(No, temp, 29);
			
			p = skip_blanks(p);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = ROUTE;
				
				for(q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef].fromnode, temp, 29);
				strcpy(RouteDef[nRouteDef++].destnode, No);
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}			
		
		if (!strnicmp(p, "file-to", 7))
		{
			p = skip_blanks(&p[7]);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = FILETO;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef++].destnode, temp, 29);
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}
		
		if (!strnicmp(p, "prepare-poll", 12))
		{
			p = skip_blanks(&p[12]);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = POLLNODE;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef++].destnode, temp, 29);
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}
		
		if (!strnicmp(p, "hold-to-poll", 12))
		{
			p = skip_blanks(&p[12]);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = HOLDPOLL;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef++].destnode,temp,29);
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}

		if (!strnicmp(p, "crash-point", 11))
		{
			p = skip_blanks(&p[11]);
			
			while(*p) {
				RouteDef[nRouteDef].flags = CRASHPOINT;
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef++].destnode, temp, 29);
				check_N_space();
				p = skip_blanks(p);
			}
			continue;
		}
				
		if (!strnicmp (p, "deny-except", 10)) {
			
			doDENIED = TRUE;
			
			p = skip_blanks(&p[8]);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = DENYOK;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef++].destnode, temp, 29);
				check_N_space();
				p = skip_blanks(p);
			}
			continue;
		}
			 				
		if (!strnicmp(p, "crash-to", 8))
		{
			p = skip_blanks(&p[8]);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = CRASHOK;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef++].destnode, temp, 29);
				check_N_space();
				p = skip_blanks(p);
			}
			continue;
		}
		
		if (!strnicmp(p, "hold-max", 8))
		{
			p = skip_blanks(&p[8]);
			
			for (q = temp; *p && !isspace(*p); *q++=*p++);
			*q = EOS;
			
			strncpy(No, temp, 29);
			p = skip_blanks(p);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = HOLDMAX;
				
				for (q = temp; *p && !isspace(*p); *q++=*p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef].destnode, temp, 29);
				strcpy(RouteDef[nRouteDef++].fromnode, No);
				
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}				
				
		if (!strnicmp(p, "hold-del", 8))
		{
			p = skip_blanks(&p[8]);
			
			for (q = temp; *p && !isspace(*p); *q++ = *p++);
			*q = EOS;
			
			strncpy(No, temp, 29);
			p = skip_blanks(p);
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = HOLDDEL;
				
				for (q = temp; *p && !isspace(*p); *q++ = *p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef].destnode, temp, 29);
				strcpy(RouteDef[nRouteDef++].fromnode, No);
				
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}				

		if (!strnicmp(p, "file-max", 8))
		{
			p = skip_blanks(&p[8]);
			
			for (q = temp; *p &&!isspace(*p); *q++ = *p++);
			*q = EOS;
			
			strncpy(No, temp, 29);
			p = skip_blanks(p);
			
			if (!*p)
			{
				log_line(-1,Logmessage[M__NO_NODE_FILE_M]);
				continue;
			}
			
			while (*p)
			{
				RouteDef[nRouteDef].flags = FILEMAX;
				
				for (q = temp; *p && !isspace(*p); *q++ = *p++);
				*q = EOS;
				
				strncpy(RouteDef[nRouteDef].destnode,temp,29);
				strcpy(RouteDef[nRouteDef++].fromnode,No);
				
				check_N_space();
				p = skip_blanks(p);
			}
			
			continue;
		}			

#if defined AREAFIX
		
		if (!strnicmp (p, "areaconsultant", 14)) {
			p = &p[14];
			
			while (*p) {
				p = skip_blanks(++p);
				if (!*p) break;
				
				switch (toupper(*p)) {
					case ' ':
					case '-':	continue;
					case 'R':	dorescan = TRUE;	break;
					case 'Q':	doquery = TRUE;		break;
					case 'L':	dototallist = TRUE;	break;
				}
			}
			
			areafix_on = TRUE;
			continue;
		}
#endif

		log_line(-1,Logmessage[M__UNKNOWN_COMMAND], p, line, CONFIGFILE);
		sleep(4);
	}
	
	fclose(FDUMMY);
	
	if (dolabel) free(havelabel);

	if (uselabel == USELABEL) {
		log_line (-1, "!Label(s) not undefined with '#ENDALL', exiting .....");
		exit (10);
	}
	
	giveTIMEslice();
	
	if (!strlen(outbound))
	{
		log_line(-1,Logmessage[M__DIR_NOT_SPECIFIED],"OUTBOUND");
		return(FALSE);
	}
	
	if (Inboundpaths[0] == NULL && Inboundpaths[1] == NULL)
	{
		if (Inboundpaths[2] == NULL)
		{
			log_line(-1,Logmessage[M__DIR_NOT_SPECIFIED],"INBOUND");
			return(FALSE);
		}
		
		Inboundpaths[0] = ctl_path(Inboundpaths[2]);
		free(Inboundpaths[2]);
		Inboundpaths[2] = NULL;
	}
	else
		if (Inboundpaths[0] == NULL && Inboundpaths[1] != NULL)
		{
			Inboundpaths[0] = ctl_path(Inboundpaths[1]);
			free(Inboundpaths[1]);
			Inboundpaths[1] = ctl_path(Inboundpaths[2]);
			free(Inboundpaths[2]);
			Inboundpaths[2] = NULL;
		}
	
	if (!nalias)
	{
		log_line(-1,Logmessage[M__ADDRESS_NOT_SPECIFIED]);
		return(FALSE);
	}
	
	if(nfdbase) {
		if(!strlen(FDbase)) {
			log_line(-1,Logmessage[M__NO_DBASE_DIR]);
			for (i=0;i < nfdbase; i++) {
				free(ToBase[i]);
			}
			nfdbase = 0;
		}
	}
	
	/*
	** Notice, this is changed. If an user has NO mailtemp
	** mentioned in the config an buseeror is the result.
	** An checking is done on the mailtemp variable.
	** If zero bytes an new directoryname must be created, so
	** no buserror can be occured.
	**
	** Rinaldo Visscher 22-12-1991
	**
	*/
	
	if (strlen(pkt_temp)) {
		strcpy(buffer, pkt_temp);
		*(strrchr(buffer, '\\')) = EOS;
	} else {
		i = Dgetdrv();
		sprintf(buffer,"%c:\\INTEMP\\",'A'+i);
		pkt_temp = ctl_string(buffer);
		*(strrchr(buffer, '\\')) = EOS;		
	}
	
	sprintf (temp, "%c:", 'A' + Dgetdrv());
	
	if (!Dgetpath (&temp[strlen (temp)], Dgetdrv())) {
		if (!strnicmp (temp, buffer, (WORD)strlen (buffer))) {
			log_line (6, "?Temp. INmail folder same as your mailfolder.");
			terminate (-3);
		}
	}
	
	if (stat(buffer, &stbuf) == FAILURE ) {
		if(Dcreate(buffer) < 0) {
			log_line(-1,Logmessage[M__CANT_CREATE_TEMP_DIR],"INmail", mailtemp);
			terminate(10);
		}
	}
		
	if (strlen(mailtemp)) {
		strcpy(buffer, mailtemp);
		*(strrchr(buffer, '\\')) = EOS;
	} else {
		i = Dgetdrv();
		
		/*
		** I don't like sprintf, because there is original an big
		** error is in the TC 2.0 lib. I don't know if this is changed
		** in PureC, but the original source uses 'sprint', so I did't
		** use 'sprintf'.
		**
		** Rinaldo Visscher 21-12-1991
		**
		*/
		
		sprintf(buffer,"%c:\\OUTTEMP\\",'A'+i);
		mailtemp = ctl_string(buffer);
		*(strrchr(buffer, '\\')) = EOS;		
	}
	
	if (stat(buffer, &stbuf) == FAILURE ) {
		if(Dcreate(buffer) < 0) {
			log_line(-1,Logmessage[M__CANT_CREATE_TEMP_DIR],"OUTmail", mailtemp);
			terminate(10);
		}
	}
	
	return(TRUE);
}

VOID Copy_or_Move(BYTE *line, BOOLEAN what) {
	BYTE temp[1024],
		 *p,*q;
	
	p = line;

	Copy_area[ncopyareas] = what;
	
	if(!*p) {
		log_line(-1,Logmessage[M__AREA_NOT_],(what == COPYAREA) ? "copy" : "move");
		return;
	}

	for(q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	Copyarea[ncopyareas] = ctl_string(temp);
	
	p = skip_blanks(p);
	if(	!*p ) {
		log_line(-1,Logmessage[M__DEST_AREA_ERROR]);
		free(Copyarea[ncopyareas]);
		return;
	}
	for(q = temp; *p && !isspace(*p); *q++ = *p++);
	*q = EOS;
	
	Destarea[ncopyareas] = ctl_string(temp);
	
	p = skip_blanks(p);
	
	if( !*p ) {
		log_line(-1,Logmessage[M__ARGUMENT_ERROR],(what == COPYAREA) ? "'copyarea'" : "'movearea'");
		free(Copyarea[ncopyareas]);
		free(Destarea[ncopyareas]);
		return;
	}

	Copylegal[ncopyareas++] = ctl_string(p);
}

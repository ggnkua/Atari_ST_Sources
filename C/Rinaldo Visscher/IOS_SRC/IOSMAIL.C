/*
    This source of IOSmail is free. This is indeed the source of iosmail.
    Compile it, and try out. The original author don't take any reponsability
    if something go wrong.
*/

#include        <stdio.h>
#include		<stdlib.h>
#include		<ext.h>
#include		<string.h>
#include		<ctype.h>
#include		<process.h>
#include		<tos.h>
#include		<vdi.h>
#include		<time.h>

/*
    For 2 underneath .H file you need the original package of multitos.
*/

#include 	<mintbind.h>
#include 	<filesys.h>

#include		"portab.h"

#include		"defs.h"
#include		"ioslib.h"
#include		"modules.h"
#include		"wareas.h"
#include		"strutil.h"
#include		"crc.h"
#include		"lang.h"

#include		"vars.h"


MLOCAL CONST BYTE	*Importing[] = {"protected inbound",
									"known inbound",
									"normal inbound"};

ULONG timeTESTresult;

BYTE *Copyright = "      [I]nMail [O]utMail [S]canMail. Copyright Rinaldo Visscher 1990 - 1992.";

/*
**	Show the results.
*/

MLOCAL VOID show_results(VOID)
{
	WORD	i, m;
	BYTE	buffer[128],
			*p, *q,
			temp[128];
	
	log_line(2,"%+-------+---------------------+-------+------+");
	log_line(2,"%| Msgs  | Area                | SysOp | Email|");
	log_line(2,"%+-------+---------------------+-------+------+");
	
	for(i=0; i < msgareas; i++)
		if (Areamsgs[i])
			log_line(2,"%| %-4d  | %-20s| %-4d  | %-4d |",
				Areamsgs[i], Areaname[i], Tosysop[i], Ncreated[i]);
	
	log_line(2,"%+-------+---------------------+-------+------+");
	
	if (nnetmails)
		log_line(2,"%| %-4d  | %-20s| %-4d  | 0    |", nnetmails, "MAIL", nnet_priv);
	
	if (nprivate)
		log_line(2,"%| %-4d  | %-20s| %-4d  | 0    |", nprivate, "PRIVATEMAILBOX", nprivate);
	
	if (nnetmails || nprivate)
		log_line(2,"%+-------+---------------------+-------+------+");
	
	if (doreport)
	{
		log_line(1,Logmessage[M__DAILY_RAPPORT]);
		
		time(&secs);
		tijd = localtime(&secs);
		strftime(tm_now,29,"%d %b %H:%M:%S",tijd);
		
		if ((FDUMMY = fopen(HISTORYFILE, "r")) == NULL)
		{
			if ((OUT = fopen(HISTORYFILE, "w")) == NULL)
			{
				log_line(6,Logmessage[M__RAPPORT_NOT_OPEN]);
				return;
			}
			
			fprintf(OUT, "Started : %s\nUpdated : %s\n", tm_now, tm_now);
			
			for (i=0; i < msgareas; i++)
				fprintf(OUT,"%-20s %d\n",Areaname[i],Areamsgs[i]);
			
			fclose(OUT);
			return;
		}
		
		if ((OUT = fopen(HISTORYDUP, "w")) == NULL)
		{
			log_line(6,Logmessage[M__RAPPORT_NOT_OPEN]);
			fclose(FDUMMY);
			return;
		}
		
		fgets(buffer, 128, FDUMMY);
		fprintf(OUT, "%sUpdated : %s\n", buffer, tm_now);
		fgets(buffer, 128, FDUMMY);
		
		while ((fgets(buffer, 128, FDUMMY)))
		{
			p = skip_blanks(buffer);
			
			if (*p == ';') continue;
			if ((i = (WORD)strlen(p)) < 3) continue;
			
			q = &p[--i];
			
			if (*q == '\r' || *q == '\n') *q = EOS;
			if ((q = strchr(p, ';')) != NULL) *q = EOS;
			
			for (q = temp; *p && !isspace(*p); *q++ = *p++);
			*q = EOS;
			
			for (i=0; i < msgareas; i++)
				if (!strnicmp(temp, Areaname[i], 20))
				{
					p = skip_blanks(p);
					m = atoi(p);
					m += Areamsgs[i];
					break;
				}
			
			if (i < msgareas) fprintf(OUT, "%-20s %d\n", temp, m);
		}
		
		fclose(OUT);
		fclose(FDUMMY);
		unlink(HISTORYFILE);
		rename(HISTORYDUP, HISTORYFILE);
	}
}

MLOCAL VOID give_help(VOID)
{
	WORD i = 0;
	BYTE buffer[128],keyhit[128],
		 *p;
	
	if ((FDUMMY = fopen("IOSMAIL.HLP","r")) == NULL) {
		log_line(-1,Logmessage[M__NO_HELP_FILE]);
		return;
	}
	
	while (fgets(keyhit, 128, FDUMMY)) {
		p = skip_blanks(keyhit);
		if (*p == ';') continue;
		break;
	}
	
	while(fgets(buffer, 128, FDUMMY)) {
		p = skip_blanks(buffer);
		if (*p == ';') continue;
		fprintf(stderr, buffer);
		i ++;
		if ( i == 23) {
			i = 0;
			fprintf(stderr, keyhit);
			while (!kbhit());
			getch();
			fprintf(stderr,"\033E");
		}
	}

	fprintf(stderr, keyhit);
	while (!kbhit());
	getch();
	fprintf(stderr, "\033E");
	
	fprintf(stderr, "This program and the C source code is registrated copyright of\n");
	fprintf(stderr, "(c) QandA software Holland. The changing any byte in this program or\n");
	fprintf(stderr, "changing the source code of this program is an violation against the\n");
	fprintf(stderr, "law in the country where it is commited, and can be seen as criminal act.\n\n");
	fprintf(stderr, "This program is written by Rinaldo Visscher, Holland.\n\n");
	fprintf(stderr, "Many thanks to Udo Erdelhoff,\n");
	fprintf(stderr, "               Joerg Spilker,\n");
	fprintf(stderr, "           and Daniel Roessen\n\n");
	fprintf(stderr, "Read the license agreement as is stated in the document.\n\n");
	
/*	
	fprintf(stderr, "Many thanks to\n\n");
	fprintf(stderr, "Johan Ansems .......... 2:280/301    .... Support Benelux\n");
	fprintf(stderr, "Bernd Renzing ......... 2:245/52     .... Support Germany\n");
	fprintf(stderr, "Steven Green .......... 2:252/25     .... Support UK\n");
	fprintf(stderr, "Rolf Thieme ........... 2:243/95     .... Manual\n");
	fprintf(stderr, "Eddie Tao ............. 2:280/3.9    .... Manual\n");
	fprintf(stderr, "Fred Schuit ........... 2:280/3.10   .... Manual\n");
	fprintf(stderr, "Vincent Pomey ......... 2:320/100\n");
	fprintf(stderr, "Alexander Bochmann .... 2:247/12\n");
	fprintf(stderr, "Daron Breewood ........ 2:252/123\n");
	fprintf(stderr, "Peter Habing .......... 2:280/3.15\n");
	fprintf(stderr, "Rene Drenth ........... 2:280/3.4\n\n");
	fprintf(stderr, "THIS IS AN BETATESTER VERSION ONLY Version 0.81\n\n");
*/	
	fprintf(stderr, "Hee you, turn on some good music ......\n");
	fprintf(stderr, "Like Pink Floyd, Yngwie Malmsteen, Steve Vai, Joe Satriani,\n");
	fprintf(stderr, "Rush, Mindstorm, Asia, Jason Becker, Marty Friedman, Anthrax,\n");
	fprintf(stderr, "Patrick Rondat, Dweezil Zappa and many more :-)\n\n");
	
	fprintf(stderr, keyhit);
	
	while (!kbhit());
	getch();
}

WORD read_keyfile(BYTE phase)
{
/*
	IOSKEY			key;
	WORD			fhandle;
	struct ffblk	fi;
	UBYTE			retcode;
*/	
	/*
	**	REMEMBER TO UPDATE PACKET HEADER VERSION INFO !!!!!!!
	*/
	
	strcpy(IOSmail, V_IOSMAIL);
	
	strcpy(InMail, V_INMAIL);
	strcpy(OutMail, V_OUTMAIL);
	strcpy(ScanMail, V_SCANMAIL);
	strcpy(Consultant, V_CONSULTANT);
	return (1);
	
}
/*
	
	if (findfirst(KEYFILE, &fi, 0x20))
	{
		if (!phase) exit (25);
	}
	
	fhandle = Fopen(KEYFILE, FO_READ);
	Fread(fhandle, sizeof(IOSKEY), &key);
	Fclose(fhandle);
	
	decrypt(&key);
	
	if (key.type == ALPHALEVEL)
	{
		strcat(IOSmail, "U");
		strcat(InMail, "U");
		strcat(OutMail, "U");
		strcat(ScanMail, "U");
		retcode = UNR_VERS;
	}
	
	if (phase) {
		if ((key.type == BETALEVEL && !stricmp(SysOp, key.name)))
		{
			strcat(IOSmail, "X");
			strcat(InMail, "X");
			strcat(OutMail, "X");
			strcat(ScanMail, "X");
			retcode = BET_VERS;
		}		
		else if ((key.type == REGISTEREDLEVEL && !stricmp(SysOp, key.name)))
		{
			strcat(IOSmail, "R");
			strcat(InMail, "R");
			strcat(OutMail, "R");
			strcat(ScanMail, "R");
			retcode = REG_VERS;
		} else if (key.type != ALPHALEVEL) {
			terminate (10);
		}
	} else {
		if (key.type == ALPHALEVEL) 
			retcode = UNR_VERS;
		else if (key.type == BETALEVEL)
			retcode = BET_VERS;
		else if (key.type == REGISTEREDLEVEL)
			retcode = REG_VERS;
		else
			exit (25);
	}
	
	sprintf (&IOSmail[strlen(IOSmail)], "%04x", key.reg_num);
	sprintf (&InMail[strlen(InMail)], "%04x", key.reg_num);
	sprintf (&OutMail[strlen(OutMail)], "%04x", key.reg_num);
	sprintf (&ScanMail[strlen(ScanMail)], "%04x", key.reg_num);

	return(retcode);
}
*/

VOID main(WORD argc, BYTE *argv[], BYTE *env)
{
	WORD		i;
	BOOLEAN		foundlabel = FALSE,
				uncomp = FALSE,
				forcecompile = FALSE;
	BYTE 		cmdline[129],
		 		*p, *q,
				temp[128];
/*
	LONG		usp, *cookie;

	__MiNT = 0;

	usp = Super (0L);

	cookie = (LONG *) 0x5a0UL;
		
	while (*cookie) {
		if (*cookie == 0x4d694e54L) { /* MiNT */
			__MiNT = cookie[1];
			MTask = MULTITOS;
			break;
		}
		cookie += 2;
	}
	
	Super ( (LONG *) usp );
*/
	
	i = Pgetpid();
	
	if (i == -32)
		__MiNT = 0;
	else {
		__MiNT= 1;
		MTask = MULTITOS;
		Files_to_open = (UWORD) Sysconf (MAX_FILES_OPEN);
	}
	
	Ttest = time(NULL);
		
	strcpy(envp, env);
	
	if (langload() == FALSE) exit (100);
		
	if (argc > 1)
		strcpy(cmdline,argv[1]);
		for(i=2; i < argc; i++) {
			strcat(cmdline," ");
			strcat(cmdline,argv[i]);
		}
		i = 0;
		if (cmdline[i] == '-')
		{
			while(cmdline[i+1] != EOS) {
				i++;
				switch(toupper(cmdline[i]))
				{
					case ' ': 	
					case '-':	i++; break;
					case 'A':	keepmsg = TRUE; break;
					case 'B':	toprivate = TRUE; break;
					case 'C':	dochanged = TRUE; break;
					case 'D':	docrunch = TRUE; break;
					case 'E':
					
						i++;
						
						if (cmdline[i] == '-')
						{
							log_line(4,Logmessage[M__LABEL_EXPECT]);
							i++;
							continue;
						}
						
						dolabel = TRUE;
						
						p = &cmdline[i];
						
						p = skip_blanks(p);
						
						for(q=temp; *p && !isspace(*p); *q++=*p++,i++);
						*q = EOS;
						
						configlabel = ctl_string(temp);
						
						if (!stricmp(configlabel, "endlabel"))
						{
							log_line(-1,Logmessage[M__ILL_LABEL]);
							free(configlabel);
							dolabel = FALSE;
						}
						i++;
						break;
					
					case 'F':	forcecompile = TRUE; break;
					case 'H':	give_help(); exit(SUCCESS); break;
					case 'I':	doimport = TRUE; break;
					case 'K':	doifna = TRUE; break;
					case 'L':	doled = TRUE; break;
					case 'M':	domsg = TRUE; break;
					case 'O':	dopack = TRUE; break;
					case 'P':	dopkt = TRUE; break;
					case 'Q':	doquit = TRUE; break;
					case 'R':	dosecure++; break;
					case 'S':	doscanmail = TRUE; break;
					case 'T':	dolog = TRUE; break;
					case 'U':	uncomp = TRUE; break;
					case 'V':	CRspec = TRUE; break;
					case 'W':	dowait = TRUE; break;
					case 'X':	domulti_reg = TRUE;	break;
					case 'Z':	dostripzone = TRUE;	break;
					
					default:	log_line(-1,Logmessage[M__SWITCH_MAIN], cmdline[i]);
								break;
				}
			} 
		}

	StatusScreen = TRUE;

	Cursconf (0, 0);

	if (StatusScreen) {
		hprintf (S_ALL, "");
	}

/*	registered = read_keyfile(0); */
				
	if (!init_cfg(&foundlabel)) exit(10);
	
	if (MTask == MULTIGEM && __MiNT != 0) {
		MTask = MULTITOS;
	}
	
	if (MTask == MULTITOS) {
		log_line (2, "+MultiTos detected....");
		Psetlimit (2, 0);
	}
	
	registered = read_keyfile(1); 
	
	if(area_attrib() == TRUE || forcecompile == TRUE) {
		if (!read_areas(AREAFILE, 0)) exit(10);
		read_areas(DAREAFILE, 1);
		write_bin_areas();
	} else {
		if(!read_bin_areas()) exit(10);
	}
	
	if (uncomp == TRUE) uncompile();
	
	if (doled) read_lednew();
	
	/*
	**	Moved for multitasking
	*/
	
	if (StatusScreen == FALSE) {
		if (MTask != MULTIGEM) {
			fprintf(stderr, "%s\n\n", Copyright);
			fprintf(stderr, "         Read for copyrights the enclosed licence agreements !\n");
			fprintf(stderr, "               FidoNet productcode information %d\n\n",IOSPRDCODE);
	#if defined EXTERNDEBUG
			fprintf(stderr, "IOSmail debug version. Debug & OutmailDebug in CFG\n");
	#endif
			for (i=0; i < 80; i++) {
				fprintf(stderr, "-");
			}
			fprintf(stderr, "\n");
			LOG_line = 4;
		} else {
			v_curtext(vdi_handle, Copyright);
			v_curtext(vdi_handle, "\n\n\r");
			v_curtext(vdi_handle, "         Read for copyrights the enclosed licence agreements !\n\r");
			for (i=0; i < 80; i++) {
				v_curtext(vdi_handle, "-");
			}
			v_curtext(vdi_handle, "\n\r");
		}
	}
		
	TOSversion = Sversion();

#if defined EXTERNDEBUG
	if (debugflag) {
		log_line(6, ">Free memory at start %ld", coreleft());
		log_line(6, ">TOS version %x", TOSversion);
	}
#endif
	
	if (strlen(logfile))
	{
		if (log_open() == FAILURE)
		{
			log_line(-1,Logmessage[M__LOG_NOT_OPEN]);
			exit(10);
		}
		else
			if (foundlabel)
				log_start(IOSmail, configlabel);
			else
				log_start(IOSmail, NULL);
	}
	else log_line(2,Logmessage[M__LOG_DIR]);
	
	if (dolabel) free(configlabel);
	
	inst_dupetrap();
	
	/*
	**	If an error on reading an config file exit with
	**	errorlevel 10
	*/
	
	if (doimport)
	{
		inbound = (BYTE *) myalloc(128);
		
		for (i=0; i < 3; i++)
		{
			if (Inboundpaths[i] == NULL)
			{
				log_line(1,Logmessage[M__NO_INBOUND], Importing[i]);
				continue;
			}
			
			if (!strlen(Inboundpaths[i])) continue;
			we_have_inbound = (BYTE) i;
			
			strncpy(inbound, Inboundpaths[i], 127);

			log_line(1,Logmessage[M__DIR_SEARCH], inbound);
			
			import_pkt(inbound);
			import_pkt(pkt_temp);
			
			while (unpack_pkt()) import_pkt(pkt_temp);
		}
		
		if (nimported)
		{
			show_results();
			log_line(3,Logmessage[M__MESSAGES_IMPORTED], nimported);
			log_line(3,Logmessage[M__MESSAGES_CREATED], nechos);
			log_line(3,Logmessage[M__MESSAGES_TRASHED], ntrashed);
		}
		
		if (AreaAdded) {
			uncompile();
			strcpy (cmdline, Envpath);
			strcpy (temp, Envpath);
			strcat (cmdline, "AREAS.BBS");
			strcat (temp, "AREAS.DUP");
			
			unlink (temp);
			
			rename (cmdline, temp);
			strcpy (temp, Envpath);
			strcat (temp, "AREAS.UNC");
			rename (temp, cmdline);
		}
			
		/*
		**	Exit with errorlevel when mail is imported,
		**	otherwise exit with 0
		*/
		
		if (!doscanmail && !dopack && !docrunch)
		{
			timeTESTresult = time(NULL);
			
			log_line(6, Logmessage[M__IMPORT_TIME], timeTESTresult - Ttest);
			
			if (doled) write_lednew();
			
			if (nimported) terminate(1);
			terminate(0);
		}
	}
	
	if (doscanmail)
	{
		dofastimport = FALSE;
		scan_areas();
		log_line(2,Logmessage[M__MESSAGES_CREATED], nechos);
	}
	
	if (dopack)
	{
		if (areafixmsgs)
		{
			log_close();
			
			if (strlen(Areafix))
			{
				if (exec(Areafix, Areafixcmd, "", &i))
					log_line(6,Logmessage[M__AREAFIX_NORUN]);
				
				if (strlen(logfile))
				{
					if (log_open() == FAILURE)
						log_line(-1,Logmessage[M__LOG_NOT_OPEN]);
				}
				else
					log_line(3,Logmessage[M__LOG_DIR]);
			}
		}
		
		pack_mail();
	}
	
	if (docrunch && !CRspec)
		compactMSGbase(CRUNCHALL);
	else if (CRspec && !docrunch)
		compactMSGbase(CRUNCHSPECIALS);
	else if(docrunch && CRspec)
		compactMSGbase(CRUNCHSPECIALS);
		
	timeTESTresult = time(NULL);
	
	log_line(6, Logmessage[M__OVERAL_TIME], timeTESTresult - Ttest);
	
	if (nechos || nimported)
	{
		if (doled) write_lednew();
		terminate(1);
	}
	
	terminate(0);
}

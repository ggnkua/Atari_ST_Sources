/* 
 *	BloufGate
 *	Fido to Unix
 *
 *	Public Domain: may be copied and sold freely
 */

#include	"blouf.h"

/* list of official internet primary domains (char **validdom) */

#include "validdom.h"

/* fixme ? */
char msgtext[32700], msgheader[5000];
FILE *news=NULL;

#define endofstr(a) a+strlen(a)

/* 
 * case insensitive comparison of string ENDINGS 
 */

int strendcmp(char *one, char *two)
{
	if(strlen(one)>strlen(two))
		return stricmp(one+(strlen(one)-strlen(two)),two);
	else
		return stricmp(two+(strlen(two)-strlen(one)),one);
}

/*
 *	Gate mail message
 */

int gatemail(BFIDOUSER *ffrom, char *to, char *subject, char *text,
           struct tm *fidotime, char *fidomsgid)
{
	int i,error;
	FILE *msg;
	char *ptr;
	char *domain;
	time_t now;
	
	char from[BLFSTR];
	char org[BLFSTR];
	char date[BLFSTR];
	char datenow[BLFSTR];
	char uufrom[BLFSTR];
	char uuuser[BLFSTR];

	i=0;
	error=0;

	/* find organization and verify that node is listed */
	ptr=findnode(ffrom->zone,ffrom->net,ffrom->node);
	if(!ptr)
	{
		logline("!Message from unlisted node %d:%d/%d trashed.",
				ffrom->zone, ffrom->net, ffrom->node);
		return FAIL;
	}
	strcpy(org,ptr);

	/* verify size */
	if( ((int)strlen(text))>cf->outmaxsize )
	{
		bounce_fido(BOUNCE,"Message too big", ffrom, to);
		return FAIL;
	}

	/* fill from field */
	fido2rfc(ffrom, from, uufrom, uuuser);

	/* find user in local user list */
	ptr=finduser(to);
	if(ptr)
	 	strcpy(to, ptr);
	
	/* check to field */
	if(strchr(to,' '))
	{
		bounce_fido(BOUNCE,"Invalid address: space(s) in address string", ffrom, to);
		return FAIL;
	}
	
	if(strlen(to)<2)
	{
    	bounce_fido(BOUNCE,"No address.",ffrom,to);
		return FAIL;
	}

	if(strchr(to,'@') && strchr(to,'!'))
	{
		bounce_fido(WARNING,"Bang and domain mix, use %",ffrom, to);
	}

	/* Get primary domain */
	domain=strchr(to,'@');
	if(domain)
	{
		if(cf->tunnelwarning==TRUE)
		{
			if(strendcmp(domain,finddomain(cf->o_zone,cf->o_net,cf->o_node))==0)
			{
				bounce_fido(BOUNCE,"FTN to FTN tunnelling through the Internet illegal",
							ffrom,to);
				return FAIL;
			}
		}	

		domain=strrchr(++domain,'.');
		if(domain)
		{
			domain++; /* skip '.' */
			if(*domain==0)
			{
				bounce_fido(BOUNCE,"No domain: Address ending by '.'",
							ffrom,to);
				return FAIL;
			}
			if(cf->uucpwarning==TRUE)
			{
				if(stricmp(domain,"uucp")==0)
					bounce_fido(WARNING,".UUCP fakedomain obsolate, use domain address",
								ffrom, to);
			}

			if(cf->bitnetwarning==TRUE)
			{
				if(stricmp(domain,"bitnet")==0)
					bounce_fido(WARNING,"No agreement with bitnet gateway: msg may be lost",
								ffrom, to);
			}

			if(cf->checkdomain==TRUE)
			{
				int i=0;
				while(validdom[i])
				{
					if(stricmp(domain,validdom[i++])==0)
						break;
				}
				if(validdom[i]==NULL)
				{
					bounce_fido(BOUNCE,"Invalid primary domain", ffrom, to);
					return FAIL;
				}
			}
		}
	}

	/* date */
	if(strncmp(cf->uuname,uufrom,(size_t)strlen(cf->uuname))==0)
		strftime(date,BLFSTR,"%a, %d %b %y %H:%M:%S %z",fidotime);
	else
		strftime(date,BLFSTR,"%a, %d %b %y %H:%M:%S GMT",fidotime);
	time(&now);
	strftime(datenow,BLFSTR,"%a, %d %b %y %H:%M:%S %z",localtime(&now));
		
	/* open output file */
	msg = create_rfcfile(cf->outrfc,"rfc");
	if(!msg)
	{
		logline("*Can't create rfc file");
		return FAIL;
	}

	/* and now write it */
#ifdef BATCHSMTP
   	/* BATCH SMTP Header */
	fprintf(msg,"HELO suntopo.matups.fr\n"); /* fixme: get from config */
	fprintf(msg,"MAIL FROM:<%s>\n",from);
	fprintf(msg,"RCPT TO:<%s>\n",to);
	fprintf(msg,"DATA\n");
#endif
	/*** Uucp FROM ***/
	fprintf (msg, "From: %s (%s)\n", from, ffrom->name);
	fprintf (msg, "Message-ID: <%s>\n", fidomsgid);
	/*fprintf (msg, "Message-ID: <%s@%s.%s>\n", fidomsgid, cf->uuname,
			finddomain(cf->o_zone,cf->o_net,cf->o_node));*/	
	/* fprintf (msg, "Sender: bloufgate@%s.%s\n", cf->uuname,"fidonet.org"); */
	fprintf (msg, "To: %s\n", to);
	fprintf (msg, "Date: %s\n", date);
	fprintf (msg, "Subject: %s\n", subject);
	fprintf (msg, "Organization: Fido node %d:%d/%d: %s.\n",
						ffrom->zone,ffrom->net,ffrom->node,org);
	fprintf (msg, "X-Mailer: %s version %s\n",ProgName,Version);
	
	if(cf->startrek==TRUE)
	{
		fprintf (msg,"X-Starship: USS Enterprise [NCC1701]\n");
		fprintf (msg,"X-Stardate: 5982.1\n");
	} 	
	
	fputc ('\n', msg);

	/* msg itself */
	mksoftcr (text);
	fputs (text, msg);

	/* signature */
	fprintf (msg, "\n---\n	  %s\n", from);

#ifdef BATCHSMTP
	fprintf(msg,".\nQUIT\n");
#endif

	if(ferror(msg))
		logline("*File error while writing rfc msg!!!!");

	fclose (msg);

	if(ffrom->point ==0)
		logline ("+%s (%d:%d/%d) -> %s", ffrom->name, ffrom->zone, ffrom->net, ffrom->node, to);
	else
		logline ("+%s (%d:%d/%d.%d) -> %s", ffrom->name, ffrom->zone, ffrom->net, ffrom->node, ffrom->point, to);

	return SUCCESS;
}

/* fixme, msgheader== buffer */

int gatenews(char *fidoarea, BFIDOUSER * orig, char *subject, struct tm *fidotime,
               char *messageid, char *replymsgid, char *msgscan)
{
	char *kludge, tmp[BLFSTR];
	char nixfrom[BLFSTR], uufrom[BLFSTR], uuuser[BLFSTR];
	char date[BLFSTR];
	char *org;
	GATENEWS *mynews;

	if (news == NULL)
	{
		/* initialize the globalocal file pointer to the news batch */
		news=create_rfcfile(cf->outrfc,"nws");
		if(news==NULL)
			return FAIL;
	}

	/* Find fido group */
	mynews = area_fido2unix(fidoarea);
	if (mynews == NULL)
	{
		logline("!Bad area %s",fidoarea);
		return FAIL;
	}

	/* Moderated ? */
	if(mynews->write==FALSE)
	{
		logline("-%s tried to write in %s (moderated).",
					orig->name,mynews->news);
		return FAIL;
	}

	/* check SEEN-BY */
	kludge = strstr (msgscan, "\nSEEN-BY");
	if (kludge == NULL)
	{
		logline ("!Trashing %s -> %s (no SEEN-BY)", orig->name, mynews->news);
		return FAIL;
	}

	/* find node number in origin */
	kludge = strstr(msgscan, "* Origin:");
	if(kludge)
		kludge = strrchr(kludge,'(');
	if (kludge == NULL)
	{
		logline ("!Trashing %s -> %s (no origin)", orig->name, mynews->news);
		return FAIL;
	}
	kludge[-1] = '\0'; /* suppress node number in texte */

	while(*kludge)
	{
		if(isdigit(*kludge))
			break;
		kludge++;
	}

	if(!*kludge)
	{
		logline ("!Trashing %s -> %s (no node number)", orig->name, mynews->news);
		return FAIL;
	}

	if(fido2ints(kludge,&orig->zone,&orig->net,&orig->node,&orig->point)==FAIL)
	{
		logline ("!Trashing %s -> %s (no valid node number)", orig->name, mynews->news);
		return FAIL;
	}

	/* check origin */
	org=findnode(orig->zone,orig->net,orig->node);
	if(org==NULL)
	{
		logline("-Trashing %s (%d:%d/%d) -> %s (unlisted node)",
			orig->name,orig->zone,orig->net,orig->node,mynews->news);
		return FAIL;
	}

	/* don't send again messages from us */
	if(orig->zone==cf->o_zone && orig->net==cf->o_net
		&& orig->node==cf->o_node && orig->point==cf->o_point)
	{
		logline("-Trashing %s -> %s (message from us!)",
			orig->name,mynews->news);
		return FAIL;
	}

	kludge[-1] = '\0'; /* suppress node number in text */

	strftime(date,BLFSTR,"%a, %d %b %y %H:%M:%S GMT",fidotime);

	fido2rfc(orig,nixfrom,uufrom,uuuser);

	msgheader[0] = '\0';
	if(cf->nopath==TRUE)
		sprintf (endofstr(msgheader), "Path: %s\n", uuuser); /* no path => local processing */
	else
		sprintf (endofstr(msgheader), "Path: %s!%s\n", cf->uuname,uuuser);
	sprintf (endofstr(msgheader), "From: %s (%s)\n", nixfrom, orig->name);

	sprintf (endofstr(msgheader), "Date: %s\n", date);
	sprintf (endofstr(msgheader), "Subject: %s\n", subject);

	sprintf (endofstr(msgheader), "Sender: bloufgate@%s.%s\n", cf->uuname,
	finddomain(cf->o_zone,cf->o_net,cf->o_node));

	strcpy (tmp, mynews->news);
	tmp[strscan('.', mynews->news)] = '\0';
	sprintf (endofstr(msgheader), "Distribution: %s\n", tmp);

	sprintf (endofstr(msgheader), "Message-ID: <%s>\n", messageid);

	/* fill In-Reply-To: */
	if(*replymsgid)
		sprintf (endofstr(msgheader), "In-Reply-To: %s\n", replymsgid);

	sprintf (endofstr(msgheader), "Newsgroups: %s\n", mynews->news);

	sprintf (endofstr(msgheader), "Organization: Fido node %d:%d/%d : %s\n",
					orig->zone, orig->net, orig->node, org);

	mksoftcr (msgscan);

	/* suppress tear line, fixme? */
	kludge = max(strstr (msgscan, "\n--- "), strstr (msgscan, "\n---\n"));
	if (kludge != NULL) {
		*kludge = '\0';
		/* display origin line text in sig. */
		strncpy (tmp, strstr(kludge+1, " * Origin:") + 11, 75);
		sprintf (&msgscan[strlen(msgscan)], "\n--- %s\n    %s\n", tmp, nixfrom);
	}
	else
		sprintf (&msgscan[strlen(msgscan)], "\n---\n	%s\n", nixfrom);

	fprintf (news, "#! rnews %d\n", strlen(msgheader)+strlen(msgscan)+1);
	fputs (msgheader, news);
	fputc ('\n', news);
	fputs (msgscan, news);

	/* don't log messages posted in fido.* uuname.* groups */
	if (!token("fido.", mynews->news) && !token(cf->uuname, mynews->news))
		logline ("+%s (%d:%d/%d.%d) -> %s", orig->name,
       				orig->zone, orig->net, orig->node, orig->point, mynews->news);
	else
		printf("%s (%d:%d/%d.%d) -> %s\n", orig->name,
			orig->zone, orig->net, orig->node, orig->point, mynews->news);

	return SUCCESS;
}


int process_packet(char *outbound)
{
	FILE *packet;
	char *msgscan;
	char fidomsgid[40],replymsgid[40];
	BFIDOUSER orig;
	char to[BLFSTR], subject[75], date[25], fidogrp[60];
	char  pktheader[58];
	char dum1[BLFSTR],dum2[BLFSTR];
	char messageid[BLFSTR];
	unsigned char c;
	int i,j;
	char *tmp;

	struct tm msgtime;
	time_t timerid;

	int error=0;

	time (&timerid);

	printf("Processing packet %s.\n",outbound);

	packet = fopen (outbound, "rb");
	if(packet == NULL)
		return FAIL;


/* fixme, skip packet header ?!?, read zone in pkt, 4dpacket support */
	orig.zone=0;
	if(fread(pktheader,58,1,packet)!=1)
		error++;

			
	while(!error)
	{
		orig.zone = cf->o_zone;
		orig.point = 0;
		*messageid=0;

		c = (unsigned char) fgetc(packet); /* end */
		if (c==0)
			break;

		/* else read packet header */
		fgetc(packet);

		orig.node = fgetiw(packet);
		if(fgetiw(packet)!=cf->td_node && cf->fourdpkt==FALSE) /* dest node */
		{
			logline("?Bad destination node in packet");
			error++;
		}
		orig.net = fgetiw(packet);
		if(fgetiw(packet)!=cf->td_net && cf->fourdpkt==FALSE)
		{
			logline("?Bad destination net in packet");
			error++; /* dest net */
		}
		fgetiw(packet); /* attrb (fixme?) */
		fgetiw(packet); /* cost */

		fgetf (date, 21, packet);
		fgetf (to, 37, packet);
		fgetf (orig.name, 37, packet);
		fgetf (subject, 73, packet);
		fgetf (msgtext, 32000, packet);

/* fixme check msg size */

		if (date[0] != 0 && orig.name[0] != 0 && !error)
		{
			strdate2tm(date, &msgtime);

			fidomsgid[0] = '\0';
			replymsgid[0] = '\0';

			msgscan = msgtext;

			fidogrp[0] = '\0';

			/* find AREA: -> fidogroup */
			if ((i=token("AREA:", msgscan))!=0)
			{
				msgscan += i;
				tmp = msgscan;
				while ((*msgscan != '\n') && (*msgscan))
					msgscan++;
				*msgscan++ = '\0';
				strcpy (fidogrp, tmp);
			}

			/* scan kludges */
			while (*msgscan == '\01')
			{
				tmp=++msgscan;

				/* remove EOL */
				while ((*msgscan != '\n') && (*msgscan))
					msgscan++;
				*msgscan++='\0'; /* msgscan ptr to next line */

				/* find FMPT, INTL, MSGID, REPLY? kludges */
				if ((i=token("FMPT", tmp))!=0)
					orig.point=atoi(tmp+i);

				/* find and verify INTL kludge */
				if ((i=token("INTL", tmp))!=0)
				{
					int z,n,f,p;

					if(fido2ints(tmp+i,&z,&n,&f,&p)==FAIL)
						error++;
					else
					{
						if((z!=cf->o_zone) || (z!=cf->o_node) || (z!=cf->o_net) || (z!=cf->o_point))
							error++;
						else
						{
							j=strscan(' ',tmp+i);
							if(i<0)
								if(fido2ints(tmp+i+j,&orig.zone,&orig.node,&orig.net,&orig.point)==FAIL)
									error++;
						}
					}

					if(error)
						logline("!Message with invalid INTL kludge");
				}

				/* convert message ID */
				if ((i=token("MSGID:", tmp))!=0)
				{
					if(sscanf (&tmp[i], "%s %s", dum1, dum2)==2)
					{
						if ((i=strscan('@', dum1)) > 0)
							dum1[i] = '\0';
						if((i=strscan(':', dum1)) > 0)
							dum1[i] = '_';
						sprintf (fidomsgid, "%s_%s", dum1, dum2);
						strlwr(fidomsgid);
					}
				}

#ifdef USE_RFCID
				/* news: use old message id on already gated mails */
				if ((i=token(RFCIDKLUDGE, tmp))!=0)
				{
					if(sscanf (&tmp[i], "%s", dum1)==1)
						strcpy(messageid,dum1);
				}
#endif

				if ((i=token("REPLY:", tmp))!=0)
				{
					sscanf (&tmp[i], "%s %s", dum1, dum2);
					if ((i=strscan('@', dum1)) > 0)
						dum1[i] = '\0';
					if ((i=strscan(':', dum1)) > 0)
						dum1[i] = '_';
					sprintf (replymsgid, "<%s_%s@%s>", dum1, dum2,
                   	finddomain(cf->o_zone,cf->o_net,cf->o_node));
				}
			}

			/* default message id & reply id, locally generated for news */
			if (fidomsgid[0] == '\0')
				sprintf (fidomsgid, "local_%d_%d/%d_%lx",
					cf->o_zone, cf->o_net, cf->o_node, timerid++);
			
			if(!*messageid)
				sprintf(messageid,"%s@%s",fidomsgid,
               	finddomain(cf->o_zone,cf->o_net,cf->o_node));
					
			/* Generate fake replymsgid */
			if(replymsgid[0] == '\0')
			{
				if ((to[0] != 0) && (stricmp("All", to) != 0))
				{
					if ((i=strscan('(', to)) != -1)
						to[i-1] = 0;
					sprintf(replymsgid,"%s's message", to);
				}
			}
			
			/* handle mail to 'uucp' */
			if (fidogrp[0]=='\0' && !stricmp(to, "uucp"))
			{
				i=0;
				/* find to: on the first line */
				while ((*msgscan != '\n') && (*msgscan != '\0') && (i<BLFSTR))
					dum1[i++] = *msgscan++;
				dum1[i]='\0';
				if ((i=token ("To:", dum1))!=0)
					strcpy (to, &dum1[i]);
				else
					strcpy (to, dum1);
				msgscan++;
			 }

			if (fidogrp[0] == '\0')
				gatemail(&orig,to,subject,msgscan,&msgtime,messageid);
			else
				gatenews(fidogrp, &orig, subject, &msgtime,messageid, replymsgid, msgscan);
		}

	} /* end pkt loop */

	fclose(packet);
	if(news)
		fclose(news);
	
	/* rename bad packet */
	if(error)
	{
		logline("*Renaming bad packet");
		strcpy(dum1,outbound);
		if(strlen(dum1)>3)
		{ /* pkt to bkt */
			dum1[strlen(dum1)-3]='B';
			rename(outbound,dum1);
		}
	}

	/* remove processed packet */
	if(cf->keep==FALSE && !error)
	{
		if(remove (outbound))
			logline("!Can't remove %s",outbound);
	}

	return SUCCESS;
}

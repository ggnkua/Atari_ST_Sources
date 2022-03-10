/*
 *	BloufGate
 *	Convert RFC mail/news to Fidonet PKTs
 *
 *	Public Domain: may be copied and sold freely
 */

#include "blouf.h"

/* idea: user setable gatekw, bin support, large unbatch */
/* ----------------------------------------------------- Local globs */

int 	gated=0; /* News messages gated */
char	*buffer; /* unbatcher buffer - should be dynamic */

/* ------------------------------------------------- Gatemail tables */

enum keywords {
	From, To, Date, Newsgroups, Subject, Msgid, Path, ReplyTo, Sender,
	Followup, Expires, References, Control, Distrib, Organization,
	Keywords, Summary, Approved, Lines, InReplyTo};
#define nkw (InReplyTo+1)

char kwtext[nkw][13] = {
	"From", "To", "Date", "Newsgroups", "Subject", "Message-ID",
	"Path", "Reply-To", "Sender", "Followup-To", "Expires",
	"References", "Control", "Distribution", "Organization",
	"Keywords", "Summary", "Approved", "Lines", "In-Reply-To"};

/* ----------------------------------------------- Message gate */

/* 
 *	Convert a rfc news/mail file to an already opened type-2 packet 
 */

int process_rfcfile(char *file, FILE *packet, char *to_envel)
{
	/* incoming mail */
	FILE   *msgtext;
	char   Header[nkw][BLFSTR];
	long   startm;
	/* general purpose var */
	char   oneline[BLFSTR], temp[BLFSTR];
	int    i, j, npart, extline;
	long   len;
	char  *ptr;
	/* outgoing mail */
	int    gotto=0;
	long   gatekw=0;
	char   area[MAXCROSS][BLFSTR];
	char   msgsubject[BLFSTR];
	int    cross,icros;
	struct tm msgtime;
	BFIDOUSER msgfrom,msgto;
	
	/* check */
	if(!packet)
	{
		logline("?Invalid packet handle");
		return FAIL;
	}
	
	/* open data file */
	if(!file)
		msgtext=stdin;
	else
		msgtext=fopen(file,"rb"); /* "rb" for compatibility with fseek()/ftell() */
	if(!msgtext)
		return FAIL;
	
	/* Init header strings */
	for (i=0; i<nkw; i++)
		Header[i][0] = 0;
	
	/* Decode header */
	extline = 0;
	while (!feof(msgtext)) 
	{
		
		/* Read a line */
		if(fblfgets(oneline,BLFSTR-2,msgtext)==NULL)
		{
			logline("?Error while reading header of %s",file ? file : "stdin");
			fclose(msgtext);
			return FAIL; /* File error */
		}
		
		/* end of header */
		if (extline && (oneline[0] == '\n')) break;
		
		/* Compare the current line with know headers */
		for (i=0; i<nkw; i++)
		{
			len = (int) strlen(kwtext[i]);
			if (strnicmp (oneline, kwtext[i],(size_t) len) == 0)
			{
				j = (int) len+2;
				while ((oneline[j] == ' ') & (oneline[j] != 0))
					j++;
				if(strlen(oneline+j)>=BLFSTR)
					oneline[j+BLFSTR-1]=0;
				strcpy (Header[i], oneline+j);
				Header[i][strlen(Header[i])-1] = '\0';
				if (i != Path) 
					extline = 1;
				break;
			}
		}
	}
	/* Header now read */
	
	/* If !from, use reply-to */
	if (Header[From][0] == '\0')
		strcpy (Header[From], Header[ReplyTo]);
	if (Header[From][0] == '\0')
		strcpy(Header[From],"unknown@nowhere");
	
	/* Verify that we are not the sender */
	sprintf (temp, "bloufgate@%s.", cf->uuname);
	if (strncmp(Header[Sender], temp, strlen(temp)) == 0)
	{
		printf("Message from us.\n");
		fclose(msgtext);
		return FAIL;
	}
	
#ifdef KILL_DUPES
	/* Check dupe on Message-ID */
	if (Header[Msgid][0]) {
		char *ptr1, *ptr2; 
		
		ptr1 = strchr(Header[Msgid], '<');
		ptr2 = strchr(Header[Msgid], '>');
		if (ptr1 && ptr2 && ptr1 < ptr2) 
		{ /* we have a msgid */
			strncpy(temp, ptr1, ptr2-ptr1+1);
			temp[ptr2-ptr1+1] = '\0';
			/*logline("-Message-ID: %s", temp);*/
			if (dupechk_seen(temp)) 
			{
				logline("?Duplicate message skipped (ID: %s)",temp);
				fclose(msgtext);
				return FAIL;
			}
		}
		else
		{
			logline("=Invalid or no Message-ID, message skipped");
			fclose(msgtext);
			return FAIL;
		}
	}
#endif

	/* Convert newsgroups to areas */
	cross=-1; /* Nothing (mail?) */

	if(Header[Newsgroups][0])
	{
		strcpy(temp,Header[Newsgroups]);
		ptr=temp;
		/* parse newsgroup line */
		do
		{
			char *ptr2;
			GATENEWS *local;
		
			/* extract one newsgroup name */
			ptr2=strchr(ptr,',');
			if(ptr2)
				*ptr2++=0;
			strcpy(temp,ptr);
			
			local=area_unix2fido(temp);
			if(local)
			{   /* gated group */
				if(++cross<MAXCROSS)
					strcpy(area[cross],local->fido);
			}
			else
			{
/* FIXME support binary groups
				local=area_unix2file(temp);
				if(local)
				{
				
					return SUCCESS;
				}
*/
			}
			ptr=ptr2;
		} while(ptr); /* end of newsgroup */
	}
	
	/* convert date */
	strdate2tm(Header[Date],&msgtime);
	
	/** TO **/
	if(Header[To][0]!=0)
	{
		norm_rfc(Header[To],temp,msgto.name);
		strcpy(Header[To],temp);
		if(rfc2fido(&msgto, to_envel!=NULL ? to_envel : Header[To])==SUCCESS)
			gotto++;
	}
	
	/** FROM **/
	norm_rfc(Header[From],temp,msgfrom.name);
	strcpy(Header[From],temp);
	
	if(strlen(msgfrom.name)==0)
	{ /* no name field use login to avoid empty fido from */
		char *ptr;
		ptr=strchr(temp,'@');
		if(ptr)
			*ptr=0;
		strcpy(msgfrom.name,temp);
	}
	
	msgfrom.zone=cf->o_zone;
	msgfrom.net=cf->o_net;
	msgfrom.node=cf->o_node;
	msgfrom.point=cf->o_point;
	
	/** SUBJECT **/
	strcpy (msgsubject, Header[Subject]);
	if(strlen(msgsubject)>71)
		msgsubject[71]='\0'; /* truncate at max fsc subject field len */
	
	/* start of the message text */
	startm=ftell(msgtext);
	if(startm<0)
	{
		logline("?ftell() error");
		fclose(msgtext);
		return FAIL;
	}
	
	/*  WRITE ECHOMAILS if it is a conference mail */
	for(icros=0;icros<=cross;icros++) /* while(cross>=0) */
	{
		/* log something */
		printf("Writing echomail from %s -> %s\n",Header[From],area[icros]);
		
		/* convert echomail's to */
		ptr = strstr(Header[InReplyTo], "'s message");
		if (ptr)
		{
			*ptr = 0;
			strcpy(msgto.name,Header[InReplyTo]);
		}
		else
			strcpy(msgto.name,"All");
		
		npart = 0; /* Cut long messages */
		
		/* rewind to start of message text */
		if(fseek(msgtext,startm,SEEK_SET)<0)
		{
			logline("?fseek error");
			fclose(msgtext);
			return FAIL;
		}
		
		do /* large message loop */
		{
			/* multiple parts subjects */
			if (npart)
				sprintf (msgsubject, "[%d] %s", npart+1, Header[Subject]);
			
			/*** Write Message Header in Fido packet */
			openpktmessage(packet,area[icros],&msgfrom,&msgto,
							msgsubject,0,&msgtime);

#ifdef USE_CHRS
			fprintf(packet,"\01CHRS: LATIN-1 2\r");
#endif			
#ifdef USE_RFCID
			if(Header[Msgid][0])
			{
				ptr=strchr(Header[Msgid],'>');
				if(ptr)
					*ptr=0;
				ptr=strchr(Header[Msgid],'<');
				if(ptr)
				{
					ptr++;
					fprintf(packet,"\01%s %s\r",RFCIDKLUDGE,ptr);
				}
			}
#endif
			
			/* fsc-0035 support */
			if(cf->fsc0035==TRUE)
			{
				fprintf(packet,"\01REPLYADDR: %s\r",Header[From]);
				fprintf(packet,"\01REPLYTO: %d:%d/%d Uucp\r",cf->o_zone,
				cf->o_net,cf->o_node);
			}
			
			/* text tags for information at the beginning of the message */
			gatekw=Set(From);
			/* add Reply-To if different than From */
			if (strcmp(Header[ReplyTo], Header[From]) != 0)
				gatekw |= Set(ReplyTo);
			/* add Newsgroups if Crosspost */
			if (strscan(',', Header[Newsgroups]) != -1)
				gatekw |= Set(Newsgroups);
			/* ajoute Followup-To si different du newsgroup */
			if (/*(strcmp(Header[Followup], group) != 0) && */ (strcmp(Header[Followup], Header[Newsgroups]) != 0))
				gatekw |= Set(Followup);
			
			/* write them */
			for (i=0; i<nkw; i++)
			{
				if ((Header[i][0] != 0) && (Set(i) & gatekw))
					fprintf (packet, "%s: %s\r", kwtext[i], Header[i]);
			}
			fprintf(packet,"\r");
			
			/* Copy the message text itself */
			len = 0;
			while (fgets(temp,sizeof(temp)-1,msgtext))
			{
				/* convert unix lf to fido cr */
				for(j=0;j<((int)strlen(temp));j++)
				{
					if(temp[j]=='\n' && (j==0 || temp[j-1]!='\r'))
						temp[j]='\r';
				}
				
				fputs(temp,packet);
				
				/* verify lenght */
				len+=strlen(temp);
				if (len > cf->maxsize)
				{
					fprintf (packet, "\r      (Post splitted at gateway, will continue on next message)\r");
					npart++;
					break;
				}
			}
			
			/* The end of the message text (origin) */
			fprintf (packet, "\r--- %s %s\r", ProgName, Version);
			/* Origin line */
			fprintf (packet, " * Origin: %s (%d:%d/%d.%d)\r", cf->origin,
					cf->o_zone,cf->o_net,cf->o_node,cf->o_point);
			/* Seenby and path */
			fprintf (packet, "SEEN-BY: %d/%d %d/%d\r", cf->o_net, cf->o_node,
					cf->td_net, cf->td_node);
			fprintf (packet, "\01PATH: %d/%d\r", cf->td_net, cf->td_node);
			
			/* Next message */
			closepktmessage(packet);
			
		} while (!feof(msgtext) && npart<BLF_MAXNPART);
		gated++;
	} /* End crosspost loop */
	
	/* write NETMAIL message */
	if(cross<0)
	{
		if(Header[Newsgroups][0])
		{
			logline("?Ungated news message to newsgroups: %s",Header[Newsgroups]);
			fclose(msgtext);
			return FAIL;
		}
		
		if(!gotto || !findnode(msgto.zone,msgto.net,msgto.node))
		{ /* bounce bad mail */
			if(!gotto) /* no to */
				bounce_net(BOUNCE,"Can't parse fidonet address",
				Header[From],Header[Msgid],Header[To]);
			else /* unlisted */
				bounce_net(BOUNCE,"Message to unlisted fidonet node",
					Header[From],Header[Msgid],Header[To]);
		}
		else
		{
			logline("+Netmail from %s to %s (%d:%d/%d.%d)",Header[From],
					msgto.name,msgto.zone,msgto.net,msgto.node,msgto.point);
			
			/*** Write Message Header in Fido packet */
			openpktmessage(packet,NULL,&msgfrom,&msgto,
						msgsubject,0,&msgtime);
			
			/* text tags for information at the beginning of the message */
			gatekw=Set(From)+Set(Organization);
			/* add Reply-To if different than From */
			if (strcmp(Header[ReplyTo], Header[From]) != 0)
				gatekw |= Set(ReplyTo);
		
			/* write them */
			for (i=0; i<nkw; i++)
			{
				if ((Header[i][0] != 0) && (Set(i) & gatekw))
					fprintf (packet, "%s: %s\r", kwtext[i], Header[i]);
			}
			fprintf(packet,"\r");
		
			/* Copy the message text itself */
			len = 0;
			while (fgets(temp,sizeof(temp)-1,msgtext))
			{
				/* convert unix lf to fido cr */
				for(j=0;j<((int)strlen(temp));j++)
				{
					if(temp[j]=='\n' && (j==0 || temp[j-1]!='\r'))
						temp[j]='\r';
				}
				
				fputs(temp,packet);
				
				/* verify lenght */
				len+=strlen(temp);
				if (len > cf->maxsize)
				{
					fprintf(packet, "\r====================================================\r"
							"Message TRUNCATED at gateway. It is annoying practice\r"
							"to send large mails over Fido/Usenet gateways.\r");
					break;
				}
			
			}
			
			/* write RFC header behind kludges at the message end */
			fseek(msgtext,0,SEEK_SET);
			fprintf(packet,"\r\01=====================================================\r"
				"\01Original RFC message header follow:\r\r");
			while (fgets(temp,sizeof(temp)-1,msgtext))
			{
				/* convert unix lf to fido cr */
				for(j=0;j<((int)strlen(temp));j++)
				{
					if(temp[j]=='\n' && (j==0 || temp[j-1]!='\r'))
						temp[j]='\r';
				}
				
				fprintf(packet,"\01%s",temp);
				if(ftell(msgtext)>=startm-1)
					break;
			}
			
			closepktmessage(packet);
			gated++;
		}
	}
	
	fclose(msgtext);
	
	return SUCCESS;
}

/*
 *	Process a new batch
 */

int process_news(char *name, FILE *pkt)
{
	FILE *idx;
	FILE *fhdle;
	size_t len;
	int message=1;
	int bad=0;
	int first=0;
	char temp[BLFSTR];
	char outname[BLFSTR];
	
	buffer=malloc((size_t)BLF_BUFSIZE);
	if(!buffer)
	{
		logline("?Can't malloc unbatch buffer.");
		return FAIL;
	}
	
	/* create outname */
	sprintf(outname,"%s%c_BLOUF_.TMP",cf->tempdir,BLF_DSEPAR);

	/* open input file */
	if(!name)
	{
		logline("-Unbatching stdin");
		idx=NULL;
	}
	else
	{
		logline("-Unbatching %s",name);
		idx=fopen(name,"rb");
	}
	
	/* check handle */
	if(!idx)
	{
		if(name)
			logline("?Can't open %s!",name);
		bad++;
	}
	else
	{
		while(!feof(idx)) /* read file */
		{
			if(fblfgets(temp,BLFSTR-2,idx)==NULL)
			{
				printf("Can't read newline (out of synch?)\n");
				break;  /* exit loop */
			}
			
			if(strncmp(RNEWSSTR,temp,strlen(RNEWSSTR)))
			{
				if(first)
				{
					logline("?Out of synch at message %d!",message);
					break; /* exit loop */
				}
				else
				{
					fclose(idx);
					logline("-Single article mail");
					if(process_rfcfile(name,pkt,NULL)==FAIL)
						bad++;
					break; /* exit loop */
				}
			}
			
			first++;
			
			len=(size_t) atol(temp+strlen(RNEWSSTR));
			if(len<BLF_BUFSIZE)
			{
				if(fread(buffer,len,1,idx)==1)
				{
					/* writing temp file */
					fhdle=fopen(outname,"wb");
					if(!fhdle)
					{
						logline("?Can't open temp file %s",outname);
						fclose(idx);
						bad++;
						break; /* exit loop */
					}
					else
					{
						if(fwrite(buffer,len,1,fhdle)!=1)
							logline("?Write error on outgoing message %s",outname);
						fclose(fhdle);
					}
					
					/* gate temp file */
					if(process_rfcfile(outname,pkt,NULL)==FAIL)
					{
						logline("?Can't gate message %d.",message);
						bad++;
					}
					
					/* delete temp file */
					if(remove(outname))
						logline("?Can't delete %s",outname);
				}
				else
				{
					logline("?Can't read message %d.",message);
					break;
				}
			}
			else
			{
				logline("?Skipping message %d (too long: %d)",message,(long) len);
				fseek(idx,(long) len,SEEK_CUR);
			}
			message++;
		} /* end read file loop */
		
		fclose(idx);
	}
	logline("-%d news messages gated",gated);
	
	if(cf->keep==FALSE)
	{
		if(!bad && name)
			remove(name);
	}
	
	free(buffer);
	if(bad)
		return FAIL;
	return SUCCESS;
}

/*
 *	Process a mailbox file
 */

int process_mailbox(char *name, FILE *pkt, char *to_env)
{
	FILE *idx;
	FILE *outf=NULL;
	int message=1;
	int bad=0;
	int end=0;
	char temp[BLFSTR];
	char outname[BLFSTR];
	
	/* create outname */
	sprintf(outname,"%s%c_BLOUF_.TMP",cf->tempdir,BLF_DSEPAR);
	
	/* open file */
	if(!name)
	{
		logline("-Processing mailbox on stdin");
		idx=stdin;
	}
	else
	{  
		logline("-Processing mailbox file %s",name);
		idx=fopen(name,"r");
	}
	
	/* check file handle */
	if(!idx)
	{
		logline("?Can't open %s!",name);
		bad++;
	}
	else
	{
		while(!feof(idx))
		{
			if(fblfgets(temp,BLFSTR-2,idx)==NULL)
			{
				printf("Can't read newline\n");
				end++;
			}
			
			if(!strncmp(temp,"From ",strlen("From ")) || end) /* improve separator detection? */
			{ /* this is another mail */
				/* close last message temp file if there's one*/
				if(outf)
				{
					fclose(outf);
					outf=NULL;
				
					/* gate temp file */
					if(process_rfcfile(outname,pkt,to_env)==FAIL)
					{
						logline("?Can't gate message %d.",message);
						bad++;
					}
					message++;

					/* delete temp file */
					if(remove(outname))
						logline("?Can't delete %s",outname);
				}
			}

			if(end) 
				break;
			
			/* if temp file is not open create it */
			if(!outf)
			{
				/* writing temp file */
				outf=fopen(outname,"wb");
				if(!outf)
				{
					logline("?Can't open temp file %s",outname);
					fclose(idx);
					return FAIL;
				}
			}
			
			/* copy string to temp file */
			fputs(temp,outf);
		}
		fclose(idx);
	}
	logline("-%d news messages gated",gated);
	
	if(cf->keep==FALSE)
	{
		if(!bad && name)
			remove(name);
	}

	if(bad)
		return FAIL;
	return SUCCESS;
}
/* end of ufg.c */
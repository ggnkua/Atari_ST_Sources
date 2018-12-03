/* 
 *   Copyright (c) 1990 Rodney Volz
 *   ALL RIGHTS RESERVED 
 * 
 *   THIS SOFTWARE PRODUCT CONTAINS THE
 *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
 *
 *   The copyright notices above do not evidence
 *   intended publication of such source code.
 *
 */

/*
 * MERCURY UUCP SOURCECODE [header.c]
 */

#ifndef HEADERS
#define HEADERS

#include "define.h"

#ifndef MWC
overlay "headers"
#endif

#ifdef MWC
#define its(a,b) (strcmp(a,b) ? 0 : 1)
#else
#define its(a,b) ((strcmp(a,b) == TRUE) ? 1 : 0)
#endif


struct header *stream_gh(stream,mode)
int stream,mode;
{
	struct header *head;
	static char s[LONGLEN],a[LLEN],b[LONGLEN];
	char dummy[LLEN];

	head = (struct header *)malloc((long)sizeof(struct header));
	bzero((long)head,(long)sizeof(struct header));
	
	while (lgetline(stream,s) != -1)
	{
		trim(s);
		if (strlen(s) < 2)
			break;

		strcpys(s,a,0,4);
		strcpys(s,b,linstr(s,' ') + 1,strlen(s));

		lower(a);
		trim(b);

		/**************/
		/* PARSE IT!! */
		/**************/
		
		if (its(a,"from:"))
		{
			adrparse(b,head->from,head->fromfull);
			continue;
		}

		strcpy(a,s);
		s[3] = '\0';
		if (its(s,"To:"))
		{
			adrparse(b,head->to,head->tofull);
			continue;
		}

		if (its(s,"Cc:"))
		{
			adrparse(b,head->cc,dummy);
			continue;
		}

		if (its(a,"reply"))
		{
			adrparse(b,head->replyto,head->replytofull);
			continue;
		}
		if (its(a,"sende"))
		{
			adrparse(b,head->sender,head->senderfull);
			continue;
		}
		if (its(a,"appar"))
		{
			adrparse(b,head->apparent,head->apparentfull);
			continue;
		}
		if (its(a,"newsg"))
		{
			strcpy(b,head->nbuf);
			continue;
		}
		if (its(a,"subje"))
		{
			strcpy(b,head->subject);
			continue;
		}
		if (its(a,"messa"))
		{
			strcpy(b,head->id);
			continue;
		}
		if (its(a,"date:"))
		{
			strcpy(b,head->date);
			continue;
		}


		/* Fast mode? */
		if (mode)
			continue;


		if (its(a,"path:"))
		{
			strcpy(b,head->path);
			continue;
		}
		if (its(a,"appro"))
		{
			adrparse(b,head->approved,head->approvedfull);
			continue;
		}
		if (its(a,"refer"))
		{
			strcpy(b,head->refer);
			continue;
		}
		if (its(a,"expir"))
		{
			strcpy(b,head->expire);
			continue;
		}
		if (its(a,"poste"))
		{
			strcpy(b,head->posted);
			continue;
		}
		if (its(a,"contr"))
		{
			strcpy(b,head->control);
			continue;
		}
		if (its(a,"follo"))
		{
			strcpy(b,head->followto);
			continue;
		}
		if (its(a,"distr"))
		{
			strcpy(b,head->distribution);
			continue;
		}
		if (its(a,"organ"))
		{
			strcpy(b,head->organization);
			continue;
		}
		if (its(a,"lines"))
		{
			strcpy(b,head->lines);
			continue;
		}
		if (its(a,"keywo"))
		{
			strcpy(b,head->keywords);
			continue;
		}
		if (its(a,"summa"))
		{
			strcpy(b,head->summary);
			continue;
		}
		if (its(a,"super"))
		{
			strcpy(b,head->supersedes);
			continue;
		}


		if (its(a,"xref:"))
		{
			strcpy(b,head->xref);
			continue;
		}
	}

	return(head);
}



struct header *gethead(file)
char *file;
{
	int inh;
	struct header *hd;

	inh = open(file,2);
	if (inh < 0)
	{
		send("Couldn't open ");
		send(file);
		send(" to parse its header.");
		return(0);
	}
	hd = stream_gh(inh,0);
	close(inh);

	strcpy(file,hd->file);
	return(hd);
}

struct header *fgethead(file)
char *file;
{
	int inh;
	struct header *hd;

	inh = open(file,2);
	if (inh < 0)
	{
		send("Couldn't open ");
		send(file);
		send(" to parse its header.");
		return(0);
	}
	hd = stream_gh(inh,1);
	close(inh);

	strcpy(file,hd->file);
	return(hd);
}



/* For future use */
makehead(file,head)
char *file;
struct header *head;
{
#if 0
	FILE *fp;

	if ((fp = fopen(file,"w")) == NULL)
	{
		send("Error opening ");
		send(file);
		send(" as output.");
		cr(1);
		return(-1);
	}
	
	if (*head->from && *head->fromfull)
		fprintf(fp,"From: %s (%s)\n",head->from,head->fromfull);
	else
		if (*head->from)
			fprintf(fp,"From: %s\n",head->from);

	if (*head->nbuf)
		fprintf(fp,"Newsgroups: %s\n",head->nbuf);
	
	if (*head->subject)
		fprintf(fp,"Subject: %s\n",head->subject);

	if (*head->keywords)
		fprintf(fp,"Keywords: %s\n",head->keywords);
	
	if (*head->id)
		fprintf(fp,"Message-Id: %s\n",head->id);

	if (*head->to)
		fprintf(fp,"To: %s\n",head->to);

	if (*head->date)
		fprintf(fp,"Date: %s\n",head->date);

	if (*head->sender)
		fprintf(fp,"Sender: %s\n",head->sender);

	if (*head->followto)
		fprintf(fp,"Followup-To: %s\n",head->followto);
	
	if (*head->replyto)
		fprintf(fp,"Reply-To: %s\n",head->replyto);

	if (*head->refer)
		fprintf(fp,"References: %s\n",head->refer);
	
	if (*head->organization)
		fprintf(fp,"Organization: %s\n",head->organization);

	if (*head->distribution)
		fprintf(fp,"Distribution: %s\n",head->distribution);

	if (*head->posted)
		fprintf(fp,"Posted: %s\n",head->posted);

	fprintf(fp,"\n");
	fclose(fp);
#endif
}



adrparse(source,s1,s2)
char *source,*s1,*s2;
{
	char s3[LLEN];
	
	if ((linstr(source,'<') != -1) && (linstr(source,'>') != -1))
	{
		strcpys(source,s1,linstr(source,'<') + 1,rinstr(source,'>') - 1);
		strcpys(source,s3,0,linstr(source,'<') - 1);

		trim(s3);

		strcpy(s3,s2);

#if 0
		if (strlen(s1) == 0)
			*s1 = '\0';
		
		if (strlen(s2) == 0)
			*s2 = '\0';
#endif
		
		return(0);
	}
	
	if (linstr(source,' ') != -1)
		strcpys(source,s1,0,linstr(source,' ') - 1);
	else
		strcpy(source,s1);

	if (linstr(source,'(') != -1) /* Fullname supplied? */
		strcpys(source,s2,linstr(source,'(') + 1,rinstr(source,')') - 1);

	trim(s1);
	trim(s2);
	
#if 0
	if (strlen(s1) == 0)
		*s1 = '\0';
		
	if (strlen(s2) == 0)
		*s2 = '\0';
#endif
}

#endif HEADERS

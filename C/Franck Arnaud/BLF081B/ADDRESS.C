/*
 *	BloufGate
 *	Address processing 
 *
 *	Public Domain: may be copied and sold freely
 */

#include	"blouf.h"

/*#define sdc(a,b) strnicmp(a,b,3)==0*/

/*
 *	Convert string to date struct
 */

static char *day[]={"sun","mon","tue","wed","thu","fri","sat"};
static char *month[]={"jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"};

void strdate2tm(char *str, struct tm *out)
{
	char *ptr;
	int i;
	time_t tt;

	out->tm_sec=0;
	out->tm_min=0;
	out->tm_hour=0;
	out->tm_mday=0;
	out->tm_mon=0;
	out->tm_year=0;
	out->tm_wday=0;
	out->tm_yday=0;
	out->tm_isdst=0;

	ptr=strtok(str,", ");

	do
	{
		if(!ptr) break;

		if(isalpha(*ptr))
		{
			for(i=0;i<7;i++)
			{
				if(strnicmp(day[i],ptr,3)==0)
					break;
			}
			if(i<7)
				out->tm_wday=i;	/* found day */
			else
			{
				for(i=0;i<12;i++)
				{
					if(strnicmp(month[i],ptr,3)==0)
						break;

				}
				if(i<12)
					out->tm_mon=i;	/* found month */
				else
				{
					if(strnicmp(ptr,"pm",2)==0)
						out->tm_hour+=12;	/* found PM */
				}
			}

		}

		if(isdigit(*ptr))
		{
			if(strchr(ptr,':'))	/* this is an hour */
			{
				out->tm_hour+=atoi(ptr);
				ptr=strchr(ptr,':');
				if(ptr)
				{
					ptr++;
					out->tm_min=atoi(ptr);
					ptr=strchr(ptr,':');
					if(ptr)
					{
						ptr++;
						out->tm_sec=atoi(ptr);
					}
				}
			}
			else /* not an hour */
			{
				i=atoi(ptr);
				if((i<32) && (i>0))	/* day */
					out->tm_mday=i;
				else if(i>1969) /* full year */
					out->tm_year=i-1900;
				else if((i<100) && (i>69)) /* short year */
					out->tm_year=i;
				/*
				 	This routine will not work for short years after
					Jan. 1st 2000, but anyway this program will not be
					used anymore by this time :-)
				*/
			}
		}
	} while((ptr=strtok(NULL,", "))!=NULL);

	if((out->tm_year==0) || (out->tm_mon==0) || (out->tm_mday==0))
	{ /* invalid date use current */
		time(&tt);
		*out=*gmtime(&tt);
	}

	if(mktime(out)==(time_t)-1) /* fill empty fields */
	{ /* bad date ? */
		time(&tt);
		*out=*gmtime(&tt);
	}
}

/*
 *	Get the internet address and the user name from a From: field
 */

void norm_rfc(char *in, char *outaddr, char *outname)
{
	char *ptr;

	if((ptr=strchr(in,'('))!=NULL)
	{
		*ptr='\0';
		ptr++;
		strcpy(outaddr,in);
		strcpy(outname,ptr);
		ptr=strchr(outname,')');
		if(ptr)
			*ptr='\0';
	}
	else if((ptr=strchr(in,'<'))!=NULL)
	{
		*ptr='\0';
		ptr++;
		strcpy(outname,in);
		strcpy(outaddr,ptr);
		ptr=strchr(outaddr,'>');
		if(ptr)
			*ptr='\0';
	}
	else
	{
		strcpy(outaddr,in);
		strcpy(outname,"");
	}
	killendspace(outaddr);
	killendspace(outname);
}

/*
 *	Removes spaces at the end of a string
 */

void killendspace(char *s)
{
	int end=strlen(s);

	while(end>0)
	{
		end--;
		if(s[end]!=' ')
			break;
		s[end]=0;
	}
}

/*
 * Convert a fidonet address string ("1:1/1") to ints
 */

int fido2ints(char *in, int *zone, int *net, int *node, int *point)
{
	char *ptr;

	*zone=0;
	*node=0;
	*net=0;
	*point=0;

	ptr=in;

	/* zone */
	if(!isdigit(*ptr))
		return FAIL;
	*zone=atoi(ptr);

	/* net */
	ptr=strchr(ptr,':');
	if(!ptr)
		return FAIL;
	if(!isdigit(*++ptr))
		return FAIL;
	*net=atoi(ptr);

	/* node */
	ptr=strchr(ptr,'/');
	if(!ptr)
		return FAIL;
	if(!isdigit(*++ptr))
		return FAIL;
	*node=atoi(ptr);

	/* point */
	*point=0;
	ptr=strchr(ptr,'.');
	if(ptr)
	{
		if(isdigit(*++ptr))
			*point=atoi(ptr);
	}
	if(*zone==0 || *net==0)
		return FAIL;

	return SUCCESS;
}

/*
 * 	Convert a fidonet address to rfc
 *
 *	outaddr: joe.user@<uuname>.fidonet.org || joe.user@[px].fx.nx.zx.fidonet.org
 *	outsite: fx.nx.zx.fido
 *	outname: joe.user
 *
 *	return fail if node doesn't exist
 */

int fido2rfc(BFIDOUSER *fido, char *outaddr, char *outsite, char *outname)

{
	int i,j;

	/* convert name */
	strcpy(outname,fido->name);

	if(strchr(outname,' '))
	{ /* at least one space, if no space messages comes probably from
       	another (technology) gateway, then mail bijectiveness is likely
           to be lost so maker user "unknown" */
		i=0;
		j=0;
		while(outname[i])
		{
/*
			outname[i]&=0x7F;
*/	
			if(outname[i]==' ')
				outname[i]='.';
			else if(outname[i]=='.')
				outname[i]='_';
			i++;
		}
	}
	else
		strcpy(outname,"unknown");


	if ((fido->zone == cf->o_zone) &&
		(fido->net  == cf->o_net)  &&
		(fido->node == cf->o_node)	&& 
		(cf->registered==TRUE))
	{
			strcpy(outsite,cf->uuname);
	}
	else
	{
		if (fido->point != 0)
			sprintf (outsite, "p%d.f%d.n%d.z%d", fido->point,fido->node, fido->net, fido->zone);
		else
			sprintf (outsite, "f%d.n%d.z%d", fido->node, fido->net, fido->zone);
	}

	sprintf(outaddr,"%s@%s.%s",outname, outsite, finddomain(fido->zone, fido->net, fido->node));
	strcat(outsite,".fido");

	return SUCCESS;
}

/*
 *		Convert a RFC to fidonet address
 */

int rfc2fido(BFIDOUSER *fido, char *netaddr)
{
	int i;
	char rfcaddr[BLFSTR], temp[BLFSTR];

	if(strlen(netaddr)>BLFSTR)
		return FAIL;

#ifdef DEBUG
printf("rfc2fido: IN: %s\n",netaddr);
#endif

	/* is ! & @ mixed ? */
	if((strscan('!',netaddr)>=0) && (strscan('@',netaddr)>=0))
	{ /* assumes someroad!<fido-aka>!user@something
			to someroad!<fido-aka>!user */
		netaddr[strscan('@',netaddr)]='\0';
	}

	/* something!somehost!<fido-aka>!user to <fido-aka>!user */
	i=-1;
	do
	{
		if(strscan('!',netaddr+i+1)>=0) /* is there another '!' */
			strcpy(rfcaddr,netaddr+i+1);
	}
	while( (i=strscan('!',netaddr+i+1))>=0 );

	/* user@<fido-aka> to <fido-aka>!user */
	i=strscan('@',netaddr);
	if(i>0)
	{
		netaddr[i]='\0';
		strcpy(rfcaddr,netaddr+i+1);
		strcat(rfcaddr,"!");
		strcat(rfcaddr,netaddr);
	}

	/* local */
	if(strscan('!',netaddr)<0)
		strcpy(rfcaddr,netaddr);

	if(rfcaddr[0]=='\0')
	{
		logline("!Invalid address %s",fido->name);
		return FAIL;
	}

	/* rfcaddr == [pxx].fxx.nxx.zxx.<something>ourdomain!Amelie_Cecile.Vloupf */
	strlwr (rfcaddr);

	i = strscan ('!', rfcaddr);
	strcpy (fido->name, rfcaddr+i+1);

	if (i > 0)
	{
		rfcaddr[i]='\0';

		if (rfcaddr[0] == 'p')
		{
			if(sscanf (rfcaddr, "p%d.%s", &fido->point, temp)==2)
				strcpy (rfcaddr, temp);
			else
				fido->point=0;
		}
		else
			fido->point = 0;

		if (token(cf->uuname, rfcaddr))
		{
			/* allows uuname.ourdomain, uuname.fido, uuname */
			fido->node = cf->o_node;
			fido->net = cf->o_net;
			fido->zone = cf->o_zone;
		}
		else
		{
			if(sscanf (rfcaddr, "f%d.n%d.z%d.%s", &fido->node, &fido->net, &fido->zone, temp)!=4)
			{
				logline("-Invalid address %s",rfcaddr);
				return FAIL;
			}

#ifdef STRICTDOMAINCHECK
			if(strcmp(temp,"fidonet.org") && strcmp(temp,"fido"))
			{
#ifndef ALTERDOM
				logline("?Invalid domain %s in %s",temp,rfcaddr);
				return FAIL;
#endif
			}
#endif
		}
	}
	else /* assumes local */
	{
		fido->point = 0;
		fido->node = cf->o_node;
		fido->net = cf->o_net;
		fido->zone = cf->o_zone;
	}

	/* convert amelie-cecile{.|_}vloupf to Amelie.Cecile Vloupf */
	if (stricmp(fido->name, "postmaster")==0)
		strcpy (fido->name, "Sysop");
	else
	{
		fido->name[0] = (char) toupper(fido->name[0]);
		
		for(i=0;i<((int)strlen(fido->name));i++)
		{
			switch(fido->name[i])
			{
				case '.':
				case '_':
				fido->name[i]=' ';
				break;
				case '-':
				fido->name[i]='.';
				break;
			}
			
			/* capitalize first letter of names */
           if(isalpha(fido->name[i+1]) && (fido->name[i]==' ' || fido->name[i]=='.'))
				fido->name[i+1]=(char) toupper(fido->name[i+1]);
			
       }
	}

#ifdef DEBUG
printf("rfc2fido: OUT: %s @ %d:%d/%d.%d\n",
		fido->name,fido->zone,fido->net,fido->node,fido->point);
#endif
	return SUCCESS;
}

/*
 *	Bounce net file
 *
 *	type:	BOUNCE or WARNING
 * reason:	text describing reason (may be NULL)
 *	to:		RFC address of original author
 *	origmsgid, origmsgto: info about original msg
 */

int bounce_net(int type, char *reason, char *to, char *origmsgid,
				char *origmsgto)
{
	FILE *msg;
	char rreason[BLFSTR];
	char rto[BLFSTR];
	char rid[BLFSTR];
	char date[BLFSTR];

	time_t now;

	if(origmsgid)
		strcpy(rid,origmsgid);
	else
		strcpy(rid,"Unknown");

	if(origmsgto)
		strcpy(rto,origmsgto);
	else
		strcpy(rto,"Unknown");

	if(reason)
		strcpy(rreason,reason);
	else
		strcpy(rreason,"Unknown reason.");

	/* open output file */
	msg = create_rfcfile(cf->outrfc,"rfc");
	if(!msg)
	{
		logline("*Error while trying to bounce msg to %s",to);
		return FAIL;
	}

	/* ! timezone must be set correctly by libs */
	time(&now);
	strftime(date,BLFSTR,"%a, %d %b %y %H:%M:%S %Z",localtime(&now));

#ifdef BATCHSMTP
	/* BATCH SMTP Header */
	fprintf(msg,"HELO suntopo.matups.fr\n"); /* fixme: get from config */
	fprintf(msg,"MAIL FROM:<>\n"); /* bounce file, empty from */
	fprintf(msg,"RCPT TO:<%s>\n",to);
	fprintf(msg,"DATA\n");
#endif
	fprintf (msg, "From: postmaster@%s.%s (System Administrator)\n", cf->uuname, finddomain(cf->o_zone,cf->o_net,cf->o_node));

	fprintf (msg, "Message-ID: <bounce_%ld@%s.%s>\n",
					(long) time(NULL), cf->uuname, finddomain(cf->o_zone,cf->o_net,cf->o_node));

	fprintf (msg, "To: %s\n", to);
	fprintf (msg, "Date: %s\n", date);
	if(type==BOUNCE)
		fprintf (msg, "Subject: Message bounced.\n");
	else
		fprintf (msg, "Subject: Mailer warning.\n");

	fprintf (msg, "Organization: Fido/Usenet Gateway\n");
	fputc ('\n', msg);

	/* msg itself */
	if(type==BOUNCE)
	{
		fprintf(msg,"   %s.%s was unable to process the message you sent to:\n\n     %s\n\n",
			 cf->uuname,finddomain(cf->o_zone,cf->o_net,cf->o_node),rto);
     	fprintf(msg, "   for the following reason: %s\n\n",rreason);
	}
	else
	{
		fprintf(msg,"   You sent a message to %s through %s.%s,\n",
			rto,cf->uuname,finddomain(cf->o_zone,cf->o_net,cf->o_node));
		fprintf(msg,"   your mail may not arrive for the following reason:\n"
				"   %s\n",rreason);
	}

	fprintf(msg, "   Original message Id: %s\n\n\n",rid);
	fprintf(msg, "   If you have any question, contact postmaster@%s.%s\n\n\n\n",
				cf->uuname,finddomain(cf->o_zone,cf->o_net,cf->o_node));
	fprintf(msg,"   (this message was automatically generated by\n%s %s)\n\n",ProgName,Version);
	/* signature */
	fprintf (msg, "\n---\n	  postmaster@%s.%s\n", cf->uuname, finddomain(cf->o_zone,cf->o_net,cf->o_node));

#ifdef BATCHSMTP
	fprintf(msg,".\nQUIT\n");
#endif

	logline("*Message from %s to %s bounced",to,rto);
	logline("*Reason: %s",rreason);
	fclose(msg);

	return SUCCESS;
}

/*
 *	Bounce to fido
 */

void bounce_fido(int type, char *reason, BFIDOUSER *bb, char *origmsgto)
{
	FILE *pkt;
	char rto[BLFSTR];
	char rreason[BLFSTR];
	BFIDOUSER from;

	init_user(from,"Uucp Gateway",cf->o_zone,cf->o_net,cf->o_node,cf->o_point);
	
	if(!origmsgto)
		strcpy(rto,"unknown");
	else
		strcpy(rto,origmsgto);

	if(!reason)
		strcpy(rreason,"unknown reason");
	else
		strcpy(rreason,reason);

	pkt=openpacket();
	if(pkt)
	{
		if(type==BOUNCE)
		{
			openpktmessage(pkt,NULL,&from,bb,"Message bounced",0,NULL);
			fprintf(pkt,"\r\rThe message you sent to %s\rwas bounced at %d:%d/%d.%d ",
					rto,cf->o_zone,cf->o_net,cf->o_node,cf->o_point);
			fprintf(pkt,"for the following reason:\r%s\r\r",rreason);
		}
		else
		{
			openpktmessage(pkt,NULL,&from,bb,"Warning from uucp mailer",0,NULL);
			fprintf(pkt,"\r\rWhile processing the message you sent to %s\r",rto);
			fprintf(pkt,"the uucp mailer at %d:%d/%d.%d issued the following warning:\r%s\r\r",
					cf->o_zone,cf->o_net,cf->o_node,cf->o_point,rreason);
		}

		if(cf->magic[0])
		{
			fprintf(pkt,"For more information on the UUCP Gateway you can request\r"
						"the magic file %s at node %d:%d/%d\r\r",cf->magic,
						cf->o_zone, cf->o_net, cf->o_node);
		}

		fprintf(pkt,"=== %s v%s\r",ProgName,Version);
		closepktmessage(pkt);
		closepacket(pkt);
	}
	logline("*Message from %s (%d:%d/%d.%d) to %s %s.",bb->name,bb->zone,
				bb->net,bb->node,bb->point,rto, type==BOUNCE ? "Bounced":"-> Warning");
	logline("*Reason: %s",rreason);
}

/* end of address.c */

/*
 *	BloufGate
 *	Configuration File And Nodelist 
 *
 *	Public Domain: may be copied and sold freely
 */

#include	"blouf.h"

/* local globs */

GATENEWS firstnews;
int freenews=0;

/*
 *	find the gatenews record corresponding to a given name
 *
 *	return NULL if conf not gated
 */

GATENEWS *area_unix2fido(char *name)
{
	GATENEWS *lastnews;

	/* Find fido group */
	lastnews = &firstnews;
	while (lastnews != NULL)
	{
		if (strcmp(name, lastnews->news) == 0)
			return lastnews;

		lastnews = lastnews->next;
	}
	return NULL;
}

GATENEWS *area_fido2unix(char *name)
{
	GATENEWS *lastnews;

	/* Find fido group */
	lastnews = &firstnews;
	while (lastnews != NULL)
	{
		if (strcmp(name, lastnews->fido) == 0)
		return lastnews;
		
		lastnews = lastnews->next;
	}
	
	return NULL;
}

void cleanconfig(void)
{
	GATENEWS *ttt,*lastnews;
	LISTIDX *list,*lll;
	
	if(freenews)
	{
		lastnews = firstnews.next;
		while (lastnews != NULL)
		{
			ttt=lastnews;
			lastnews=lastnews->next;
			free(ttt);
		}
	}
	
	list=cf->netlist;
	while(list!=NULL)
	{
		lll=list;
		list=list->next;
		free(lll);
	}
	
	if(cf) free(cf);
}

/*
 *	Read config file
 */

int readconfig(char *configfile, char *condition)
{
	char	oneline[BLFSTR], temp[BLFSTR];
	FILE	*config;
	int 	i, j, k;
	int 	error,waitend;
	GATENEWS *lastnews;

	cf=malloc(sizeof (BCONFIG));	
	if(cf==NULL)
		return FAIL;
		
	/* init list */
	lastnews = &firstnews;
	lastnews->next = NULL;

	/* init default domain */
	setdomain(NULL);

	/* init struct */
	cf->o_zone=-1;
	cf->o_net=-1;
	cf->o_node=-1;
	cf->o_point=-1;
	cf->td_net=-1;
	cf->td_node=-1;
	cf->b_zone=-1;
	cf->b_net=-1;
	cf->b_node=-1;
	cf->outpkt[0]='\0';
	cf->outrfc[0]='\0';
	cf->outnws[0]='\0';
	cf->dupefile[0]='\0';
	cf->tempdir[0]='\0';
	cf->uuname[0]='\0';
	cf->magic[0]='\0';
	cf->fgateann[0]='\0';
	cf->fgatetemp[0]='\0';
	cf->fgatebin[0]='\0';
	cf->fgateann[0]='\0';
	cf->origin[0]='\0';
	cf->maxsize=16000;	/* default 16 KB */
	cf->outmaxsize=cf->maxsize;
	cf->fsc0035=FALSE;
	cf->registered=FALSE;
	cf->fourdpkt=FALSE;
	cf->keep=TRUE;
	cf->nopath=FALSE;
	cf->tunnelwarning=TRUE;
	cf->uucpwarning=FALSE;
	cf->checkdomain=FALSE;
	cf->bitnetwarning=FALSE;
	cf->startrek=FALSE;
	for(i=0;i<PASSLEN;i++) cf->pktpass[i]='\0';

	/* init linked lists */
	cf->userlist=NULL;
	cf->netlist=NULL;
	/*cf->firstnews=NULL;*/

	/* search in current dir */
	config = fopen (configfile, "r");

	if(!config)
	{
		char *v;
		v=getenv("BLOUF");
		if(v)
		{
			config = fopen(v,"r");
			if(!config)
			{
				printf("can't open %s\n",v);
				return FAIL;
			}
		}
		else
		{
			printf("can't open config\n");
			return FAIL;
		}
	}

	error=0;
	waitend=0;

	while (!feof(config) && !error)
	{
		if(fgets (oneline, BLFSTR, config)==NULL)
			break;

		strip (oneline);

		if (oneline[0] != 0)
		{
			/* don't process lines beetwen if <condition>/end  if !our condition*/
			if((i=token("if",oneline))!=0)
			{
				if(condition)
				{
					if(stricmp(condition,&oneline[i]))
						waitend++; /* not our condition */
				}
				else
					waitend++;
			}
	
			/* if waitend !0 we're in a if/end loop that is not for us */
			if(waitend)
			{
				if((i=token("end",oneline))!=0)
					waitend=0;
			}
			else
			{

				if ((i=token("address", oneline))!=0)
				{
					j=sscanf (&oneline[i], "%d:%d/%d.%d %d", &cf->o_zone,
							&cf->o_net, &cf->o_node, &cf->o_point, &i);
					if(j<4)
					{
						printf("invalid address %s\n",oneline+i);
						error++;
					}
					else	if(j==5)
					{
						if(cf->o_point==0)
						{
							printf("fakenet without point?\n");
							error++;
						}
						else
						{
							cf->td_net=i;
							cf->td_node=cf->o_point;
						}
					}
					else
					{
						if(cf->o_point)
						{
							printf("point without fakenet?\n");
							error++;
						}
						else
						{
							cf->td_net=cf->o_net;
							cf->td_node=cf->o_node;
						}
					}
				}
				else if ((i=token("boss", oneline))!=0)
				{
					j=sscanf (&oneline[i], "%d:%d/%d", &cf->b_zone,
							&cf->b_net, &cf->b_node);
					if(j!=3)
					{
						printf("invalid boss %s\n",oneline+i);
						error++;
					}
				}
				else if ((i=token("outpkt", oneline))!=0)
				{
					strcpy (cf->outpkt, &oneline[i]);
					killslash(cf->outpkt);
				}
				else if ((i=token("outrfc", oneline))!=0)
				{
					strcpy (cf->outrfc, &oneline[i]);
					killslash(cf->outrfc);
				}
				else if ((i=token("outnews", oneline))!=0)
				{
					strcpy (cf->outnws, &oneline[i]);
					killslash(cf->outnws);
				}
				else if ((i=token("dupefile", oneline))!=0)
				{
					strcpy (cf->dupefile, &oneline[i]);
				}
				else if ((i=token("tempdir", oneline))!=0)
				{
					strcpy (cf->tempdir, &oneline[i]);
					killslash(cf->tempdir);
				}
				else if ((i=token("uuname", oneline))!=0)
				{
					strcpy (cf->uuname, &oneline[i]);
					killslash(cf->uuname);
				}
				else if ((i=token("domain", oneline))!=0)
					setdomain(&oneline[i]);
				else if ((i=token("origin", oneline))!=0)
				{
					strcpy (cf->origin, &oneline[i]);
				}
				else if ((i=token("reqhelp", oneline))!=0)
				{
					strcpy (cf->magic, &oneline[i]);
				}
				else if ((i=token("fgateann", oneline))!=0)
				{
					strcpy (cf->fgateann, &oneline[i]); /* FGATE */
				}
				else if ((i=token("fgateref", oneline))!=0)
				{
					strcpy (cf->fgateref, &oneline[i]); /* FGATE */
					killslash(cf->fgateref);
				}
				else if ((i=token("fgatetemp", oneline))!=0)
				{
					strcpy (cf->fgatetemp, &oneline[i]); /* FGATE */
					killslash(cf->fgatetemp);
				}
				else if ((i=token("fgatebin", oneline))!=0)
				{
					strcpy (cf->fgatebin, &oneline[i]); /* FGATE */
					killslash(cf->fgatebin);
				}
				else if ((i=token("maxsize", oneline))!=0)
					cf->maxsize = atoi (&oneline[i]);
				else if ((i=token("outmax", oneline))!=0)
					cf->outmaxsize = atoi (&oneline[i]);
				else if ((i=token("logfile", oneline))!=0)
				{
					strcpy (temp, &oneline[i]);
					if(openlog(temp)!=SUCCESS)
						return FAIL;
				}
				else if ((i=token("password", oneline))!=0)
				{
					if(strlen(oneline+i)>=PASSLEN)
					{
						printf("invalid password.\n");
						return FAIL;
					}
					strcpy (cf->pktpass, &oneline[i]);
				}					   
				else if ((i=token("registered", oneline))!=0)
					cf->registered=TRUE;
				else if ((i=token("nokeep", oneline))!=0)
					cf->keep=FALSE;
				else if ((i=token("fsc-0035", oneline))!=0)
					cf->fsc0035=TRUE;
				else if ((i=token("4d-packet", oneline))!=0)
					cf->fourdpkt=TRUE;
				else if ((i=token("nopath", oneline))!=0)
					cf->nopath=TRUE;
				else if ((i=token("uucpwarning", oneline))!=0)
					cf->uucpwarning=TRUE;
				else if ((i=token("bitnetwarning", oneline))!=0)
					cf->bitnetwarning=TRUE;
				else if ((i=token("chkdomain", oneline))!=0)
					cf->checkdomain=TRUE;
				else if ((i=token("startrek", oneline))!=0)
					cf->startrek=TRUE;
	
				else if ((i=token("nodelist", oneline))!=0)
				{
					killslash(oneline+i);
					if(openlist(oneline+i)==FAIL)
					{
						logline("!Can't load nodelist");
						error++;
					}
				}
				else if ((i=token("localusers", oneline))!=0)
				{
					killslash(oneline+i);
					if(openusers(oneline+i)==FAIL)
					{
						logline("!Can't load user list");
						error++;
					}
				}
				else if ((i=token("gatenews", oneline))!=0)
				{
					j = strscan (' ', &oneline[i]);
					k = strscan ('\t', &oneline[i]);
					if (j == -1) j = k;
					else if (k != -1) j = min(j, k);
					oneline[i+j] = '\0'; j++;
					while ( ((oneline[i+j] == ' ') || (oneline[i+j] == '\t')) && (oneline[i+j] != '\0'))
						j++;
	
					if(oneline[i]=='!')
					{
						lastnews->write=FALSE;
						i++; j--;
					}
					else
						lastnews->write=TRUE;
	
					if( (strlen(oneline+i+j)>FIDOLEN) || (strlen(oneline+i)>NEWSLEN) )
					{
						printf("bad gatenews line: name too long\n");
						error++;
						break;
					}
					strcpy (lastnews->fido, oneline+i+j);
					strcpy (lastnews->news, oneline+i);
					lastnews->next = malloc (sizeof(GATENEWS));
					lastnews = lastnews->next;
					if(!freenews)
						freenews++;
					if(lastnews==NULL)
					{
						logline("*Malloc error");
						return FAIL;
					}
					lastnews->next = NULL;
				}
			} /* waitend */
		}
/* fixme, gatefile */
	}
	fclose (config);

	
	if(cf->o_zone<=0)
		error++;
	if(cf->o_net<0)
		error++;
	if(cf->o_node<0)
		error++;
	if(cf->o_point<0)
		error++;
	if(cf->td_net<0)
		error++;
	if(cf->td_node<0)
		error++;
	if(cf->b_zone<=0)
		error++;
	if(cf->b_net<0)
		error++;
	if(cf->b_node<0)
		error++;
	if(cf->outpkt[0]=='\0')
		error++;
	if(cf->outrfc[0]=='\0')
		error++;
	if(cf->uuname[0]=='\0')
		error++;
	if(cf->origin[0]=='\0')
		error++;

	if(cf->outnws[0]=='\0')
		strcpy(cf->outnws,cf->outrfc);
	
	if(cf->tempdir[0]=='\0')
		strcpy(cf->tempdir,cf->outrfc);

	if(error)
	{
		printf("error in config file\n");
		return FAIL;
	}

	return SUCCESS;
}

/*
 *	Display the config file
 */

void displayconfig(void )
{
	USERIDX *list;
	LISTIDX *nli;
	GATENEWS *lastnews;

	if(!cf) return;

	printf("\n%s version %s Configuration:\n\n",ProgName,Version);
	printf("Gateway (RFC) address : %d:%d/%d.%d (FTN-4D) %d/%d (FTN-2D) %s.%s (RFC)\n",
		cf->o_zone,cf->o_net,cf->o_node,cf->o_point,
		cf->td_net,cf->td_node,
		cf->uuname,finddomain(0,0,0));
	printf("Fidonet (Boss) address:	%d:%d/%d\n",cf->b_zone,cf->b_net,cf->b_node);
	printf("Maximum size limits   : %d bytes (rfc>ftn) %d bytes (ftn>rfc)\n",
		cf->maxsize,cf->outmaxsize);
	printf("Options               : %s %s %s %s %s %s\n",
		cf->checkdomain ? "check-domains" : "no-check-domains",
		cf->registered ? "reg.-site" : "unreg.-site",
		cf->uucpwarning ? "uucp-warn" : "no-uucp-warn",
		cf->bitnetwarning ? "bnet-warn" : "no-bnet-warn",
		cf->startrek ? "galactic" : "terrian",
		cf->fsc0035 ? "use-fsc0035" : "no-fsc0035"); /* fourdpkt */
	printf("Packet password       : %s.\n",cf->pktpass);
	printf("PKT outbound dir.     : %s.\n",cf->outpkt);
	printf("RFC Mail outbound dir.: %s.\n",cf->outrfc);
	printf("RFC news outbound dir.: %s.\n",cf->outnws);
	printf("Duplicates file       : %s.\n",cf->dupefile[0]!=0 ? cf->dupefile : "*NONE*");
	printf("Temporary directory   : %s.\n",cf->tempdir);
	printf("Origin line           : \"%s\"\n",cf->origin);
	printf("\n");
	
	/* list newsgroups */
	lastnews = &firstnews;
	while (lastnews != NULL)
	{
		printf("Gate newsgroup %s from/to echomail %s %s\n",
			lastnews->news, lastnews->fido,
			lastnews->write ? "" : "(read only)");
		lastnews = lastnews->next;
	}

	/* list users */
	if(cf->userlist)
	{
		printf("USER LIST:\n");
		list=cf->userlist;
		while(list)
		{
			printf("User fido: %s, rfc: %s.\n",list->fido,list->rfc);
			list=list->next;
		}
	}
	else
		printf("No user list\n");
	
	/* net list */
	if(cf->netlist)
	{
		printf("NET LIST:\n");
		nli=cf->netlist;
		while(nli)
		{
			printf("Net %d:%d -> \"%s\"\n",nli->zone,nli->net,nli->name);
			nli=nli->next;
		}
	}
	else
		printf("No net list\n");
}

/*
 * Open the userlist
 */

int openusers(char *ulist)
{
	FILE *idx;
	int error=0;
	char temp[BLFSTR];
	char *ptr;
	USERIDX *list;
	
	cf->userlist=list=malloc(sizeof(USERIDX));
	if(!list)
	{
		logline("!No memory for net list.");
		return FAIL;
	}
	list->next=NULL;
	
	idx=fopen(ulist,"r");
	if(!idx)
	{
		logline("!Can't load net list!");
		return FAIL;
	}
	
	while(fgets(temp,BLFSTR,idx)!=NULL)
	{
		if(*temp!='#' && *temp!=';')
		{
			clean_string(temp);
			
			ptr=strchr(temp,':');
			if(ptr)
			{	

				*ptr++=0;
				strcpy(list->fido,temp);
				if(strlen(ptr)>=BLFSTR)
					ptr[BLFSTR-1]=0;
				strcpy(list->rfc,ptr);
					
				list->next=malloc(sizeof(USERIDX));
				list=list->next;
				if(!list)
				{
					logline("Can't malloc user list!");
					return FAIL;
				}
				list->next=NULL;
			}
		}
	}
	
	fclose(idx);
	
	if(error)
	return FAIL;
	
	return SUCCESS;
}

/*
 * Get a fidoname user
 */

char *finduser(char *in)
{
	USERIDX *list;
	
	if(cf->userlist)
	{
		list=cf->userlist;
		while(list!=NULL)
		{
			if(!stricmp(list->fido,in))
				return list->rfc;
			list=list->next;
		}
	}
	return NULL;
}

/*
 *	Open the nodelist
 */

int openlist(char *fnetlist)
{
	FILE *idx;
	int error=0;
	char temp[BLFSTR];
	char *ptr;
	LISTIDX *list;

	cf->netlist=list=malloc(sizeof( LISTIDX));
	if(!list)
	{
		logline("!No memory for net list.");
		return FAIL;
	}
	list->next=NULL;
	
	idx=fopen(fnetlist,"r");
	if(!idx)
	{
		logline("!Can't load net list!");
		return FAIL;
	}

	while(fgets(temp,BLFSTR,idx)!=NULL)
	{
		if(*temp!='#' && *temp!=';')
		{
			clean_string(temp);
			
			list->zone=atoi(temp);
			ptr=strchr(temp,':');
			if(ptr)
			{	
			 	list->net=atoi(++ptr);
				ptr=strchr(ptr,' ');
/* fixme: be more versatile tab, multispace etc */
				if(ptr)
				{
					if(strlen(ptr)>=BLFSTR-1)
						ptr[BLFSTR-2]=0;
					strcpy(list->name,ptr+1);
					list->next=malloc(sizeof(LISTIDX));
					list=list->next;
					if(!list)
					{
						logline("Can't malloc net list!");
						return FAIL;
					}
					list->next=NULL;
				}
			}
		}
	}

	fclose(idx);

	if(error)
		return FAIL;

	return SUCCESS;
}

/*
 *	Close the nodelist <fixme: unused?>
 */

void closelist(void )
{
}

/*
 *	Find a node in the systemlist
 *
 *	returns its system name or NULL if ! found
 */

char *findnode(int zone,int net,int node)
{
	LISTIDX *list;
	
	if(!cf->netlist)
		return "FTN BBS -- via gateway";
	else
	{
		list=cf->netlist;
		while(list!=NULL)
		{
			if(list->zone==zone && list->net==net)
				return list->name;
			list=list->next;
		}
	}
	return NULL;
}

/* Domain processor
	IDEA: put that in {node|net}list */

static char mydomain[BLFSTR];

void setdomain(char *domain)
{
	if(domain)
		strcpy(mydomain,domain);
	else
		strcpy(mydomain,DEFAULT_DOMAIN);
}

char *finddomain(int zone, int net, int node)
{
	return mydomain;
}

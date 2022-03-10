/*
 *	LazyTick main module
 *	(LazyTick Project)
 *   
 *	Public Domain: may be copied and sold freely
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	<ctype.h>
#include	<string.h>
#include    <stdarg.h>

#include	<dirent.h>
#include	<sys/types.h>
#include	<sys/stat.h>

#include	"qbbs.h"
#include	"tick.h"
#include 	"misc.h"
#include	"config.h"
#include 	"announce.h"
#include	"crc32.h"

#ifdef LATTICE /* for atari Lattice C 5 */
unsigned long _STACK=16000;
#endif

void process_tic(char *, char *,char *, char *);
void send_tic(BTICFILE *,int,int,int,int);

#define timenix(a) time(a)

/* main */

int main(int argc, char **argv)
{
	char net[BBSSTR];
	char tickfile[BBSSTR];
	int received=0;
	BTCKANN *tica;
	ECHOLIST *ticalist;
	DIR *dir;
	struct dirent *mydesc;

	printf("%s version %s (compiled on %s)\n",LAZYNAME,LAZYVERS,__DATE__);
	printf("A Public Domain Program. May be copied and sold freely.\n\n");

	/* init */
	open_config();
	
	/* mode == debug ? */
	if(argc==2 && !stricmp(argv[1],"debug"))
	{
		debug_config();
		if(open_areas(FAREASFILE)==BBSOK)
		{
			debug_areas();
			close_areas();
		}
	}
	else if(argc==5 && !stricmp(argv[1],"hatch")) /* mode == hatch */
	{
		logline(0,"Loading file area configuration");
		if(open_areas(FAREASFILE)==BBSFAIL)
			return 1;
		logline(1,"Hatching %s to %s (%s)",argv[2],argv[3],argv[4]);
		process_tic(NULL,argv[2],argv[3],argv[4]);
		received++;
		close_areas();
	}
	else if(argc>1)
	{
		printf("Usage: ltick                            (process incoming .tic files)\n"
			   "       ltick debug                      (display config file parsing)\n"
			   "       ltick hatch <file> <area> <desc> (send local file to network\n\n");
	}
	else
	{ /* incoming tics */
		logline(0,"Loading file area configuration");
		if(open_areas(FAREASFILE)==BBSFAIL)
			return 1;

		/* process incoming TICs */
		strcpy(net,get_inbound());

		dir=opendir(net);
		if(dir)
		{
			while((mydesc=readdir(dir))!=NULL)
			{
				if(!strendcmp(mydesc->d_name,".tic"))
				{
					strcpy(tickfile,net);
					strcat(tickfile,mydesc->d_name);
					logline(1,"Processing %s",tickfile);
					process_tic(tickfile,NULL,NULL,NULL);
					received++;
				}
			}
			closedir(dir);
		}
		else
			logline(2,"Can't open dir %s",net);
		close_areas(); /* close fareas.bbs */
	}
	
	/* do announces */	
	if(received)
	{
		if(open_areas(AREASFILE)==BBSOK)
		{
			tica=get_announce();
			while(tica)
			{
				ticalist=get_area(tica->area);
				if(ticalist)
				{
					if(process_announce(tica->group,ticalist->file,
							tica->footer[0] ? tica->footer : NULL)==BBSOK)
						logline(1,"Announced %s to %s",tica->group,tica->area);
					
				}
				else
					logline(3,"Can't find %s in areas.bbs",tica->area);
				tica=tica->next;
			}
			close_areas();
		}
		else
			logline(3,"Can't open areas.bbs");
	}
	else
		logline(1,"No inbound activity");
	
	/* close */
	close_config();
	return 0;
}

/* process tick file or hatch */

void process_tic(char *tickfile, char *hatchfile, char *hatcharea, char *hatchdesc)
{
	BTICFILE *ctic;
	FILE *tickf;
	FILE *descf;
	char desctmp[BBSSTR];	
	char buffer[BBSSTR];
	char shadowpass[BBSSTR];
	ECHOLIST *mylist;
	FIDONODE *mynode;
	struct stat mystat;
	char *ptr;
	int fd_area=0,fd_file=0,fd_desc=0,fd_from=0,fd_origin=0;
	int fd_crc=0,fd_pw=0;
	int badtick=0;
	int seen_flag=0,i;
	
	ctic=malloc(sizeof(struct _ticfile));
	if(!ctic)
	{
		logline(5,"Malloc error for tic structure");
		the_end(242);
	}

	ctic->area[0]=0;
	ctic->file[0]=0;
	ctic->desc[0]=0;
	ctic->password[0]=0;
	ctic->crc=0;
	ctic->size=0;
	ctic->from.zone=ctic->from.net=ctic->from.node=ctic->from.point=0;
	ctic->origin.zone=ctic->origin.net=ctic->origin.node=ctic->origin.point=0;
	
	ctic->pass_nb=0;
	ctic->seenby_nb=0;

	if(tickfile)
	{ /* process .tic file */
		/* load tickfile */
		tickf=fopen(tickfile,"r");
		if(tickf)
		{
			while(fticgets(buffer,BBSSTR-2,tickf)!=NULL)
			{
				strcln(buffer,-1);
			
				/* mandatory fields */
				if(!strticcmp(buffer,"area"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
					{
						strcpy(ctic->area,ptr);
						fd_area++;
					}
				}
				else if(!strticcmp(buffer,"file"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
					{
						strcpy(ctic->file,ptr);
						fd_file++;
					}
				}
				else if(!strticcmp(buffer,"desc"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
					{
						strcpy(ctic->desc,ptr);
						fd_desc++;
					}
				}
				else if(!strticcmp(buffer,"origin"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
					{
						if(getaddress(ptr,&ctic->origin.zone,&ctic->origin.net,
							&ctic->origin.node,&ctic->origin.point))
						{
							fd_origin++;
						}
					}
				}
				else if(!strticcmp(buffer,"from"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
					{
						if(getaddress(ptr,&ctic->from.zone,&ctic->from.net,
							&ctic->from.node,&ctic->from.point))
						{
							fd_from++;
						}
					}
				}
				/* optional fields */
				else if(!strticcmp(buffer,"seenby"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
					{
						if(ctic->seenby_nb<MAXSEEN)
						{
							if(getaddress(ptr,&(ctic->seenby[ctic->seenby_nb].zone),
								&(ctic->seenby[ctic->seenby_nb].net),
								&(ctic->seenby[ctic->seenby_nb].node),
								&(ctic->seenby[ctic->seenby_nb].point)));
							{
								ctic->seenby[ctic->seenby_nb].position=0;
								ctic->seenby_nb++;
							}
						}
					}
				}
				else if(!strticcmp(buffer,"crc"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
					{
						ctic->crc=xtol(ptr);
						fd_crc++;
					}
				}
				else if(!strticcmp(buffer,"size"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
					{
						ctic->size=(unsigned long) atol(ptr);
					}
				}
				else if(!strticcmp(buffer,"pw"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
					{
						strcpy(ctic->password,ptr);
						fd_pw++;
					}	
				}
				else if(!strticcmp(buffer,"log"))
				{
					ptr=nextstrtic(buffer);
					if(ptr)
						logline(1,"Message in TIC: %s",ptr);
				}
				else if(!strticcmp(buffer,"created"))
					; /* skip */
				/* passthru fields */
				else if(!strticcmp(buffer,"path")
					|| !strticcmp(buffer,"app")
					|| !strticcmp(buffer,"release")
					|| !strticcmp(buffer,"replaces")
					|| !strticcmp(buffer,"magic")
					|| !strticcmp(buffer,"date"))
				{
					if(ctic->pass_nb<MAXPASSNB)
					{
						if(strlen(buffer)>PASSLEN-2)
							buffer[PASSLEN-1]=0;
						strcpy(ctic->pass[ctic->pass_nb],buffer);
						ctic->pass_nb++;
					}
				}
				else
				{
					logline(2,"Unknown field: %s",buffer);
					/* pass unknow line thru, as per fsc-0028 */
					if(ctic->pass_nb<MAXPASSNB)
					{
						if(strlen(buffer)>PASSLEN-2)
							buffer[PASSLEN-1]=0;
						strcpy(ctic->pass[ctic->pass_nb],buffer);
						ctic->pass_nb++;
					}
				}	
			}
		
			fclose(tickf);
			
			/* create filepath */
			strcpy(ctic->filepath,get_inbound());
			strcat(ctic->filepath,ctic->file);
		}
		else
			logline(4,"Can't open tickfile %s",tickfile);
	}
	else /* hatch */
	{
		int k;
		
		mylist=get_area(hatcharea);
		if(!mylist)
		{
			logline(2,"Area %s doesn't exist",hatcharea);
		}
		else
		{
			/* reset size */
			ctic->size=0;
			
			/* copy area */
			strcpy(ctic->area,hatcharea);
			fd_area++;
		
			/* copy filename part */
			k=strlen(hatchfile);
			while(k>0 && hatchfile[k]!=SYSSEPAR)
				k--;
			if(k>0)
				strcpy(ctic->file,hatchfile+k+1);
			else
				strcpy(ctic->file,hatchfile);
			fd_file++;
			
			/* description */
			strcpy(ctic->desc,hatchdesc);
			fd_desc++;
		
			/* actual filename */
			strcpy(ctic->filepath,hatchfile);
			
			/* origin/from */
			if(mylist->firstnode)
			{
				get_ouraddress(&(ctic->from),
					(mylist->firstnode)->zone,
					(mylist->firstnode)->net,
					(mylist->firstnode)->node,
					(mylist->firstnode)->point);
				fd_from++;
				get_ouraddress(&(ctic->origin),
					(mylist->firstnode)->zone,
					(mylist->firstnode)->net,
					(mylist->firstnode)->node,
					(mylist->firstnode)->point);
				fd_origin++;
			}
			else
			{
				get_ouraddress(&ctic->from,0,0,0,0);
				fd_from++;
				get_ouraddress(&ctic->origin,0,0,0,0);
				fd_origin++;
			}
		}
	}	
	
	/* 1st checks */
	if(!fd_origin)
	{
		logline(2,"Missing 'Origin' field!");
		badtick++;
	}
	if(!fd_from)
	{
		logline(2,"Missing 'From' field!");
		badtick++;
	}
	if(!fd_area)
	{
		logline(2,"Missing 'Area' field!");
		badtick++;
	}
	if(!fd_desc)
	{
		logline(2,"Missing 'Desc' field!");
		badtick++;
	}
	if(!fd_file)
	{
		logline(2,"Missing 'File' field!");
		badtick++;
	}
	
	if(!badtick)
	{ /* second checks */
		mylist=get_area(ctic->area);
		if(!mylist)
		{
			logline(2,"Area %s doesn't exist!",ctic->area);
			badtick++;
		}
		else
		{ /* got echolist */
			if(stat(ctic->filepath,&mystat))
			{
				logline(3,"File %s not received!",ctic->filepath);
				badtick++;
			}
			else /* ok */
			{
				if(ctic->size)
				{
					if(mystat.st_size!=ctic->size)
					{
						logline(2,"Bad file size!");
						badtick++;
					}	
				}
				else
					ctic->size=mystat.st_size;
				
				if(fd_crc)
				{
					unsigned long tempcrc;
					if(crc32file(ctic->filepath,&tempcrc)==BBSOK)
					{
						if(ctic->crc!=tempcrc)
						{
							logline(2,"Bad CRC on %s!",ctic->filepath);
							badtick++;
						}
					}
					else
					{
						logline(4,"Can't calculate CRC32");
						badtick++;
					}
				}
				else
				{
					if(crc32file(ctic->filepath,&ctic->crc)==BBSFAIL)
					{
						logline(4,"Can't calculate CRC-32");
						badtick++;
					}
				}
				
				/* check from */
				mynode=mylist->firstnode;
				while(mynode)
				{
					if(mynode->zone==ctic->from.zone
					 	&& mynode->net==ctic->from.net
					 	&& mynode->node==ctic->from.node
					 	&& mynode->point==ctic->from.point)
					 	break;
					mynode=mynode->next;
				}
				if(!mynode)
				{
/* fixme: do it nicer? */
					if(tickfile) /* !hatch */
					{
						logline(2,"%d:%d/%d.%d is not a subscriber to %s",
							ctic->from.zone,ctic->from.net,ctic->from.node,ctic->from.point,
							ctic->area);
						badtick++;
					}
				}
				
				if(fd_pw)
				{
					
					shadowpass[0]=0;
					get_password(shadowpass,ctic->from.zone,ctic->from.net,
								ctic->from.node,ctic->from.point);
					if(strnicmp(shadowpass,ctic->password,7))
					{
						logline(2,"Bad password for file %s (%s)",ctic->file,ctic->password);
						/* badtick++; */
					}
				}
			}
		} /* end got echolist */
	}

	/* copy the file to area */
	if(!badtick)
	{
		strcpy(buffer,mylist->file);
		strcat(buffer,ctic->file);
	
		if((descf=fopen(buffer,"r"))!=NULL)
		{	
			fclose(descf);
			logline(2,"File %s already exists",buffer);
			badtick++;
		}
		else
		{
			if(copyfile(ctic->filepath,buffer)==BBSOK)
			{
				logline(1,"Received file %s in area %s from %d:%d/%d.%d via %d:%d/%d.%d",
						ctic->file,ctic->area,
						ctic->origin.zone,ctic->origin.net,
						ctic->origin.node,ctic->origin.point,
						ctic->from.zone,ctic->from.net,
						ctic->from.node,ctic->from.point);
				announce_tic(ctic,mylist->group);
				if(remove(ctic->filepath))
					logline(3,"Can't remove %s",ctic->filepath);
				strcpy(ctic->filepath,buffer);
			
				sprintf(desctmp,"%s%s",mylist->file,FILESBBS);
				descf=fopen(desctmp,"a");
				if(!descf)
				{
					logline(4,"Can't open file.bbs!");
					badtick++;
				}
				else
				{
					fprintf(descf,"%-12.12s %s\n",ctic->file,ctic->desc);
					fclose(descf);
				}
			}	
			else
			{
				logline(4,"Can't copy %s to %s?",ctic->filepath,buffer);	
				badtick++;
			}
		}
	}
	
	if(badtick)
	{ /* Bad file */
		if(tickfile)
		{
			strcpy(buffer,tickfile);
			strcpy(buffer+strlen(buffer)-4,".BTK");
			ptr=strrchr(buffer,SYSSEPAR);
			if(ptr)
			{
				logline(3,"Bad TIC file %s renamed to %s",tickfile,ptr?++ptr:buffer);
				if(rename(tickfile,buffer))
					logline(3,"Can't rename %s",tickfile);
			}
		}
		else
			logline(1,"Hatch failed");
	}
	else
	{ /* We succesfully received the file */
		if(tickfile)
		{
			if(remove(tickfile))
				logline(3,"Can't delete %s",tickfile);
		}
		
		/* send the file to other nodes */
		mynode=mylist->firstnode;
		while(mynode)
		{
			seen_flag=0;
			/* check seen by */
			for(i=0;i<ctic->seenby_nb;i++)
			{
				if(ctic->seenby[i].zone==mynode->zone
						&& ctic->seenby[i].net==mynode->net
						&& ctic->seenby[i].node==mynode->node
						&& ctic->seenby[i].point==mynode->point)
					seen_flag++;
			}
			if(ctic->from.zone==mynode->zone /* do not resend to sender */
				&& ctic->from.net==mynode->net
				&& ctic->from.node==mynode->node
				&& ctic->from.point==mynode->point)
					seen_flag++;
			if(!seen_flag)
			{ /* not seen by */
				if(ctic->seenby_nb<MAXSEEN)
				{
					ctic->seenby[ctic->seenby_nb].zone=mynode->zone;
					ctic->seenby[ctic->seenby_nb].net=mynode->net;
					ctic->seenby[ctic->seenby_nb].node=mynode->node;
					ctic->seenby[ctic->seenby_nb].point=mynode->point;
					ctic->seenby[ctic->seenby_nb].position=1;
					ctic->seenby_nb++;
				}
			}
			mynode=mynode->next;
		}
		for(i=0;i<ctic->seenby_nb;i++)
		{
			if(ctic->seenby[i].position)
			{
				logline(1,"Sending %s to %d:%d/%d.%d",
					ctic->file, ctic->seenby[i].zone,
					ctic->seenby[i].net,
					ctic->seenby[i].node,
					ctic->seenby[i].point);
				send_tic(ctic,ctic->seenby[i].zone,
					ctic->seenby[i].net,
					ctic->seenby[i].node,
					ctic->seenby[i].point);
				
			}
		}
	}
	free(ctic);
}

void send_tic(BTICFILE *tic, int zone, int net, int node, int point)
{
	char ticknm[BBSSTR];
	char outdir[BBSSTR];
	FILE *tfl;
	FILE *outfl;
	FILE *tmpfl;
	FIDONODE ourad;
	char password[BBSSTR];
	char datebuf[BBSSTR];
	unsigned long tickid;
	time_t timer;
	int i,try=100;
	
	get_ouraddress(&ourad,zone,net,node,point);
	tickid=(unsigned long) timenix(NULL);
	
	/* create tickfile */
	while(try>0)
	{
		sprintf(ticknm,"%s%lx.TIC",get_ticktemp(),tickid);
		
		/* test existence */
		tmpfl=fopen(ticknm,"r");
		if(tmpfl)
			fclose(tmpfl);
		else
			break;
			
		try--;
		tickid++;
	}
	
	if(!try)
	{
		logline(4,"Can't find unique ID!");
		return;
	}
	
	tfl=fopen(ticknm,"w");
	if(tfl)
	{
		logline(0,"Creating %s",ticknm);
		/* area */
		fprintf(tfl,"Area %s\n",tic->area);
		/* origin */
		fprintf(tfl,"Origin %d:%d/%d",tic->origin.zone,
			tic->origin.net,tic->origin.node);
		if(tic->origin.point)
			fprintf(tfl,".%d",tic->origin.point);
		fprintf(tfl,"\n");
		/* from */
		fprintf(tfl,"From %d:%d/%d",ourad.zone,ourad.net,ourad.node);
		if(ourad.point)
			fprintf(tfl,".%d",ourad.point);
		fprintf(tfl,"\n");
		/* file */
		fprintf(tfl,"File %s\n",tic->file);
		/* desc */
		fprintf(tfl,"Desc %s\n",tic->desc);
		/* crc */
		fprintf(tfl,"CRC %lx\n",tic->crc);
		/* (c) */
		fprintf(tfl,"Created by %s v. %s\n",LAZYNAME,LAZYVERS);
		/* pass */
		for(i=0;i<tic->pass_nb;i++)
		{
			fprintf(tfl,"%s\n",tic->pass[i]);
		}
		/* path */
		time(&timer);
		strftime(datebuf,BBSSTR,"%a %b %d %H:%M:%S %Y %Z GMT",gmtime(&timer));
		fprintf(tfl,"Path %d:%d/%d",ourad.zone,ourad.net,ourad.node);
		if(ourad.point)
			fprintf(tfl,".%d",ourad.point);
		fprintf(tfl," %lu %s\n",tickid,datebuf);
		/* seenby */
		for(i=0;i<tic->seenby_nb;i++)
		{
			fprintf(tfl,"Seenby %d:%d/%d",tic->seenby[i].zone,
				tic->seenby[i].net,tic->seenby[i].node);
			if(tic->seenby[i].point)
				fprintf(tfl,".%d",tic->seenby[i].point);
			fprintf(tfl,"\n");
		}
		/* password */
		get_password(password,zone,net,node,point);
		if(*password)
		{
			fprintf(tfl,"Pw %s\n",password);
		}
		fclose(tfl);
	
	
		/* append to outbound directory */
		if(get_out_fname(outdir,zone,net,node,point)==BBSOK)
		{
			outfl=fopen(outdir,"a");
			if(outfl)
			{
				fprintf(outfl,"%s\n",tic->filepath);
				fprintf(outfl,".%s\n",ticknm);
				fclose(outfl);
			}
		}
		else
			logline(4,"Can't open %s",outdir);
	}
}

/**/
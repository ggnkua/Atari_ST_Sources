/*
 *	Announce Engine
 *	(LazyTick project)
 *
 *	Public Domain. May be copied and sold freely.
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	<portab.h>
#include	<ctype.h>
#include	<string.h>

#include	"tick.h"
#include 	"misc.h"
#include	"config.h"
#include 	"announce.h"

/* global */

ANNTICK *firstann=NULL;

/* store announce */

void announce_tic(BTICFILE *tic, char *group)
{
	ANNTICK *cann;
	char temp[BBSSTR],tempds[ANNDLEN];
	int i,idx,lastspace,lastcut;

	/* allocate new entry */	
	if(firstann==NULL)
	{
		cann=firstann=malloc(sizeof(struct _ticlog));
		if(!firstann)
		{
			logline(5,"Malloc error in announce!");
			the_end(242);
		}
		firstann->next=NULL;
	}
	else
	{
		cann=firstann;
		while(cann->next)
			cann=cann->next;
		cann->next=malloc(sizeof(struct _ticlog));
		if(!cann->next)
		{
			logline(5,"Malloc error in announce!");
			the_end(242);
		}
		cann=cann->next;
		cann->next=NULL;
	}
		
	/* do */
	strcpy(cann->group,group);
	strcpy(temp,tic->area);
	strcat(temp,":");
	
	/* description */
	sprintf(tempds,"%-12.12s %4dk %-10.10s %s\n",tic->file,
		(int)tic->size/1024,temp,tic->desc);
	
	if(strlen(tempds)>ANNLLEN)
	{
		idx=ANNSKIP+1;
		lastspace=-1; /* last space, invalid */
		lastcut=0; /* start of current line */
		while(tempds[idx]) /* multiline */
		{
			/* anti overflow */
			if(idx>=strlen(tempds))
				break;
			
			/* anti inflation, enougn space for one inflation */
			if(strlen(tempds)>(ANNDLEN-ANNSKIP-2))
			{	
				tempds[idx]=0;
				break;
			}
			
			/* lastspace */
			if(tempds[idx]==' ')
				lastspace=idx;
				
			if((idx-lastcut)>ANNLLEN)
			{
				/* if no spaces in current string cut here */
				if((lastspace>idx) || (lastspace<lastcut))
					lastspace=idx;
				
				/* cut at <lastspace> */	
				tempds[lastspace]='\n';
				lastcut=lastspace+1;
				lastspace=-1; /* reset lastspace */
				
				/* inflate with spaces beginning of new line */
				for(i=0;i<ANNSKIP;i++)
				{	
					idx++;
					strspins(tempds+lastcut+i);
				}
			}
			idx++;
		}
	}
	/* done */
	strcpy(cann->display,tempds);
}

int process_announce(char *group, char *arearad, char *footer)
{
	ANNTICK *cura;
	char tempfile[BBSSTR];
	char buffer[BBSSTR];
	char subject[BBSSTR];
	FILE *tf;
	FILE *foot;
	int something=0;
	
	strcpy(tempfile,get_ticktemp());
	strcat(tempfile,"TICKANN.TMP");
	
	tf=fopen(tempfile,"w");
	if(!tf)
		logline(4,"Can't open %s",tempfile);
	else
	{
		fprintf(tf,"\n");
		
		cura=firstann;
		while(cura)
		{
			if(!stricmp(cura->group,group))
			{
				fprintf(tf,cura->display);
				something++;
			}
			cura=cura->next;
		}
		
		if(footer)
		{
			if(footer[0])
			{
				foot=fopen(footer,"r");
				if(foot)
				{
					while(fgets(buffer,BBSSTR-2,foot)!=NULL)
						fputs(buffer,tf);
					fclose(foot);
				}
				else
					logline(3,"Can't open footer %s",footer);
			}
		}
		else
			fprintf(tf,"\nFile request or download from this node.\n");
			
		fclose(tf);
		
		if(something)
		{
			sprintf(subject,"New file(s) received in %s.",group);
			logline(0,"Writing message to %s",arearad);
			postmsg(LAZYNAME,NULL,"All",NULL,subject,
					arearad,tempfile,0);
		}
	}
	
	if(remove(tempfile))
		logline(3,"Can't remove announce temp. file");
	
	if(something)
		return BBSOK;
	return BBSFAIL; /* nothing announced */
}
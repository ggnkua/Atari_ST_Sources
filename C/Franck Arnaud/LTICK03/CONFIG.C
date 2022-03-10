/*
 *	Configuration file manager (tb.cfg)
 *	(LazyTick/LazyFix Project; based on Bermuda code)
 *   
 *	Public Domain: may be copied and sold freely
 */

#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	<portab.h>
#include	<ctype.h>
#include	<string.h>

#include	"tick.h"
#include	"misc.h"
#include	"config.h"

/* open_config: load the config file
   close_config: close the config file
   debug_config: display the config file
   get_announce: get announce list
   get_out_fname: get outbound hold file nale
   get_password: get password for a node
   get_ouraddress: get ouraka 
   get_sysop: get sysop name
   get_inbound: get in dir
   get_outbound: get out dir
   get_ticktemp: get tick dir */

/* ===================================================== GLOBAL VARS */

BPASSWORD *cfg_pwd;
BAKA alias[30];      /* aliases */
int  nalias=0;              /* number of aliases */
BTCKANN *cfg_announce=NULL;
BFIXPERM *cfg_perms=NULL;
BFIXPERM *cfg_fperms=NULL;
char cfg_temp[BBSSTR];
char cfg_sysop[BBSSTR];
char cfg_mailpath[BBSSTR];
char cfg_netpath[BBSSTR];
char cfg_holdbink[BBSSTR];
char cfg_hold[BBSSTR];
int	 cfg_binkley=0;


/* ==================================================== LOAD CONFIG */

void close_config(void )
{
	close_the_log();
}

void debug_config(void )
{
	int i;
	BPASSWORD *pw;
	BTCKANN *tica;
	BFIXPERM *fica;
	
	printf("Inbound : %s\n",get_inbound());
	printf("Hold    : %s\n",get_outbound());
	printf("Sysop   : %s\n",get_sysop());
	printf("Temp	: %s\n",get_ticktemp());

	for(i=0;i<nalias;i++)
	{
		printf("address %d:%d/%d.%d\n",alias[i].zone,
			alias[i].net,alias[i].node,
			alias[i].point);
	}
    
    pw=cfg_pwd->next;
    while (pw!=NULL)
    {
    	printf("key %d:%d/%d.%d password: %s aka: %d\n",
    		pw->zone,pw->net,pw->node,pw->point,
    		pw->passw,
    		pw->my_aka);
        pw=pw->next;
    }
    
    tica=cfg_announce;
    while(tica)
    {
    	printf("announce group %s in %s with footer %s\n",
    		tica->group,tica->area,tica->footer[0] ? tica->footer : "-none-");
    	tica=tica->next;
    }
    
    fica=cfg_perms;
    while(fica)
    {
    	printf("Areafix permissions for group %s: nodes %s.\n", 
    		fica->group, fica->nodes);
    	fica=fica->next;
    }
    
    fica=cfg_fperms;
    while(fica)
    {
    	printf("Filefix permissions for group %s: nodes %s.\n", 
    		fica->group, fica->nodes);
    	fica=fica->next;
    }
}
   
int open_config(void )
{
    FILE *conf;                     /* filepointer for config-file */
    char buffer[BBSSTR];            /* buffer for 1 line */
    char Bpath[BBSSTR];
    char logname[BBSSTR];
    char *p;                        /* workhorse */
    int count;                      /* just a counter... */
	int loglevel=2;

	/* zerostr */
	cfg_netpath[0]=0;
	cfg_sysop[0]=0;
	cfg_mailpath[0]=0;
	cfg_temp[0]=0;
	cfg_hold[0]=0;
	cfg_holdbink[0]=0;
		
	/* init */
	Bpath[0]=0;
	cfg_pwd= (struct _passw *) malloc(sizeof(struct _passw));
    if(!cfg_pwd)
    {
    	logline(5,"Can't malloc pwd!");
    	the_end(242);
    }
    cfg_pwd->zone=cfg_pwd->net=cfg_pwd->node=cfg_pwd->point=0;
    cfg_pwd->next=NULL;
    
#ifdef OLDCODE /* mailer env var, change ffirst */	
    p=getenv("MAILER");
    if (!ffirst("bermuda.cfg") &&      /* check local config */
        !ffirst("tb.cfg") &&
        p!=NULL && *p!='\0')
    {                                  /* no local, and envi contained one */
        strcpy(Bpath,p);
        addslash(Bpath);
    }
#endif

    sprintf( buffer, "%s%s", Bpath,BERMCFG1);
    conf= fopen(buffer, "r");

    if (conf==NULL)
    {
        sprintf(buffer,"%s%s", Bpath,BERMCFG2);

        conf = fopen(buffer, "r");
    }

#ifdef DEBUG
    printf("Config: %s\n",buffer);
#endif

    if (conf==NULL)
    {
        logline(5,"Configuration file not found, please check!");
        return BBSFAIL;                           /* not found, back */
    }

    /* set all to default values */

    logline(0,"Parsing configuration file");
       
    while((fgets(buffer, BBSSTR-2, conf)))       /* read a line */
    {
#ifdef DEBUG
		printf("Config: %s\n",buffer);
#endif

        p=skip_blanks(buffer);
        if (*p==';') continue;               /* comment?? */

        /* delete ALL chars following (and inclusive) comment sign */
        if ((p=strchr(buffer,';'))!=NULL)  *p= '\0';
        if ((count= (int)strlen(buffer))<3) continue;
                                            /* what's the length of the rest? */
        p= &buffer[--count];
        if (*p=='\n') *p=0;                 /* delete (possible) newline char */

        /* process "application bermuda" and 
        	"application lazytick" lines as normal lines */
        if (!strnicmp(buffer,"application",11))
        {
        	p=skip_blanks(&buffer[11]);
        	if(!strnicmp(p,"bermuda",7)) {
        		p=skip_blanks(&p[7]);
        		strcpy(buffer,p);
        	}
        	if(!strnicmp(p,"lazyfix",7)) {
        		p=skip_blanks(&p[7]);
        		strcpy(buffer,p);
        	}
        	if(!strnicmp(p,"lazytick",8)) {
        		p=skip_blanks(&p[8]);
        		strcpy(buffer,p);
        	}
        }

        if (!strnicmp(buffer,"sysop",5))
        {
                p=skip_blanks(&buffer[5]);
                strncpy(cfg_sysop,p,BBSSTR-10);
                cfg_sysop[BBSSTR-10]='\0';
                continue;
        }

        if (!strnicmp(buffer,"address",7))
        {
            p=skip_blanks(&buffer[7]);
            if(getaddress(p,&alias[nalias].zone, &alias[nalias].net,
                &alias[nalias].node, &alias[nalias].point)!=7)
            {
               logline(3,"Invalid address in %s",buffer);
               continue;
            }
            p=skip_blanks(skip_to_blank(p));

            if (*p=='+' || *p=='*') p=skip_blanks(skip_to_blank(p));

            if (*p && isdigit(*p))            
            {
                if ((alias[nalias].pointnet=atoi(p))==0)
                {
                   logline(5,"Invalid pointnet in %s",buffer);
                   continue;
                }
            }
            else 
            	alias[nalias].pointnet=0;
            ++nalias;

            continue;
        }

        if (!strnicmp(buffer,"loglevel",8))
        {
            p=skip_blanks(&buffer[8]);
            if (sscanf(p,"%d", &count)!=1 || count>5 || count<0)
                logline(3,"Invalid loglevel (%s)", p);
            else 
            	loglevel=count;
            continue;
        }

        if (!strnicmp(buffer, "statuslog",9))
        {
            ctl_string(logname,&buffer[9]);        	
            continue;
        }

        if (!strnicmp(buffer,"netfile",7))
        {
            ctl_path(cfg_mailpath,&buffer[7]);
            continue;
        }
		
		if (!strnicmp(buffer,"ticktemp",8))
        {
            ctl_path(cfg_temp,&buffer[8]);
            continue;
        }
        
        if (!strnicmp(buffer,"tickann",7))
        {
        	char *ptr;
        	BTCKANN workst,*annptr;
        	
        	ptr=nextstr(buffer);
        	if(ptr)
        	{
        		strspacecpy(workst.area,ptr);
        		ptr=nextstr(ptr);
        		if(ptr)
        		{
        			strspacecpy(workst.group,ptr);
        			ptr=nextstr(ptr);
        			if(ptr)
        				strspacecpy(workst.footer,ptr);
        			else
        				workst.footer[0]=0;
        			
        			/* ok we got it */
 					annptr=cfg_announce;
 					if(annptr==NULL) /* first one */
 						annptr=cfg_announce=malloc(sizeof(struct _ticann));
 					else
 					{
 						while(annptr->next)
 							annptr=annptr->next;
 						annptr->next=malloc(sizeof(struct _ticann));
 						annptr=annptr->next;
 						
 					}	
 					if(!annptr)
 					{
 						logline(5,"Malloc error in cfg");
 						the_end(242);
 					}
 					annptr->next=NULL;
 					strcpy(annptr->area,workst.area);
 					strcpy(annptr->group,workst.group);
 					strcpy(annptr->footer,workst.footer);
        		}
        	}
        	continue;
        }
		
		if (!strnicmp(buffer,"afixperm",8)) /* areafix permissions */
        {
        	char *ptr;
        	BFIXPERM workst,*annptr;
        	
        	ptr=nextstr(buffer);
        	if(ptr)
        	{
        		strspacecpy(workst.group,ptr);
        		ptr=nextstr(ptr);
        		if(ptr)
        		{
        			strspacecpy(workst.nodes,ptr);
        			
        			/* ok we got it */
 					annptr=cfg_perms;
 					if(annptr==NULL) /* first one */
 						annptr=cfg_perms=malloc(sizeof(struct _fixperm));
 					else
 					{
 						while(annptr->next)
 							annptr=annptr->next;
 						annptr->next=malloc(sizeof(struct _fixperm));
 						annptr=annptr->next;
 						
 					}	
 					if(!annptr)
 					{
 						logline(5,"Malloc error in cfg");
 						the_end(242);
 					}
 					annptr->next=NULL;
 					strcpy(annptr->group,workst.group);
 					strcpy(annptr->nodes,workst.nodes);
        		}
        	}
        	continue;
        }
        
        if (!strnicmp(buffer,"ffixperm",8)) /* filefix perissions */
        {
        	char *ptr;
        	BFIXPERM workst,*annptr;
        	
        	ptr=nextstr(buffer);
        	if(ptr)
        	{
        		strspacecpy(workst.group,ptr);
        		ptr=nextstr(ptr);
        		if(ptr)
        		{
        			strspacecpy(workst.nodes,ptr);
        			
        			/* ok we got it */
 					annptr=cfg_fperms;
 					if(annptr==NULL) /* first one */
 						annptr=cfg_fperms=malloc(sizeof(struct _fixperm));
 					else
 					{
 						while(annptr->next)
 							annptr=annptr->next;
 						annptr->next=malloc(sizeof(struct _fixperm));
 						annptr=annptr->next;
 						
 					}	
 					if(!annptr)
 					{
 						logline(5,"Malloc error in cfg");
 						the_end(242);
 					}
 					annptr->next=NULL;
 					strcpy(annptr->group,workst.group);
 					strcpy(annptr->nodes,workst.nodes);
        		}
        	}
        	continue;
        }
        
        if (!strnicmp(buffer,"netmail",7))
        {
            ctl_string(cfg_netpath,&buffer[7]);
            continue;
        }

        if (!strnicmp(buffer,"hold",4))
        {
            ctl_path(cfg_hold,&buffer[4]);
			strcpy(cfg_holdbink,cfg_hold); 
			cfg_holdbink[strlen(cfg_holdbink)-1]=0;
            continue;
        }

        if (!strnicmp(buffer,"key",3))
        {
            parsekey(&buffer[3]);
            continue;
        }

		if (!strnicmp(buffer,"binkley", 7))
		{
	    	cfg_binkley=1;
	    	continue;
		}
	}
    
    fclose(conf);
    
    /* open the logfile */
    if(open_the_log(logname,loglevel)==BBSFAIL)
       	logline(5,"Can't open logfile %s",logname);
    
    return BBSOK;                           /* signal OK */
}

/* parse the key line */

void parsekey(char *p)
{
    int i;
    char password[9];
    BPASSWORD *pw,*pn;
    int zone,net,node,point;
    int my_aka=0;
    
    /* get to the end of the list. */
    pw=cfg_pwd;

    while (pw->next!=NULL)      pw=pw->next;

    password[0]='\0';
    
    p=skip_blanks(p);
    while (*p && *p!=';')
    {
        if (*p=='!')
        {
            strncpy(password,p+1,7);
            for (i=0; i<7; ++i)
            {
                if (isspace(password[i])) break;
            }
            password[i]='\0';

            /* skip password and go on to node(s) */
            p=skip_to_blank(p);
            p=skip_blanks(p);
            continue;
        }

        if (*p=='#')
        {
            if (getaddress(p+1,&zone,&net,&node,&point))
            {
                int found=0;
                for (i=0; i<nalias; i++)
                {
                    if (alias[i].zone==zone && alias[i].net==net &&
                        alias[i].node==node && alias[i].point==point)
                    {
                        found++;
                        break;
                    }
                }
                if (found) my_aka=i;
                else
                {
                    my_aka=0;
                    logline(3,"Address %d:%d/%d.%d used in key is unknown",
                     zone,net,node,point);
                }
            }

            p= skip_to_blank(p);
            p= skip_blanks(p);
            continue;
        }

        pn=pw->next= (struct _passw *) malloc(sizeof(struct _passw));
        if(!pw)
        {
        	logline(5,"Malloc error in config");
        	the_end(242);
        }

        if (!getaddress(p,&zone,&net,&node,&point))
        {
            free(pn);
            pw->next=NULL;
            logline(3,"-Invalid address: %s",p);
            return;
        }

        if (point)
        {
            for (i=0; i < nalias; i++)
            {
                if (alias[i].zone==zone && alias[i].net==net &&
                    alias[i].node==node)
                {
                    net= alias[i].pointnet;
                    node= point;
                    point= 0;
                    break;
                }
            }
        }
        pn->zone=zone;
        pn->net=net;
        pn->node=node;
        pn->point=point;
        pn->my_aka=my_aka;
        strcpy(pn->passw,password);
        p=skip_to_blank(p);
        p=skip_blanks(p);
        pw=pn;
        pw->next=NULL;
    }
    
    return;
}

int getint(p,i)                                   /* Mind the calling parms! */
char **p;
int *i;
{
        char *q;
        long temp;

        q=*p;
        if (!isdigit(*q)) return (-1);

        temp=0;
        do {
           temp*=10;
           temp+=(*q++-'0');
           } while (isdigit(*q));
        *p=q;
        *i=(int)temp;
        if (temp>32767) return (-1);
        return (0);
}

int getaddress(str, zone, net, node, point)     /* Decode zz:nn/mm.pp number */
char *str;       /* 0=error | 1=node | 2=net/node | 3=zone:net/node | 4=pnt */
int *zone, *net, *node, *point;
{
        int retcode=0;

        *zone  = alias[0].zone;
        *net   = alias[0].net;
        *node  = alias[0].node;
        *point = 0;

        str=skip_blanks(str);

        if (*str=='.') goto pnt;
        retcode++;
        if (getint(&str,node))
        {
            if (strnicmp(str,"ALL",3)) return (0);
            *zone=*net=*node=-1;
            return 10;
        }
        if (!*str) return (retcode);
        if (*str=='.') goto pnt;
        retcode++;
        if (*str==':') {
           str++;
           *zone=*node;
           *node=-1;
           if (!*str) return (0);
           if (getint(&str,node))
           {
              if (strnicmp(str,"ALL",3)) return (0);
              *net=*node=-1;
              return 10;
           }
           retcode++;
        }
        if (*str!='/') return (0);
        str++;
        *net=*node;
        *node=alias[0].node;
        if (getint(&str,node))
        {
            if (strnicmp(str,"ALL",3)) return (0);
            *node=-1;
            return 10;
        }
        if (*str=='.') goto pnt;
        return (retcode);
pnt:    str++;
        if (getint(&str,point))
        {
            if (strnicmp(str,"ALL",3)) return (0);
            *point=-1;
            return 10;
        }
        return (4+retcode);
}

/* utils funcs for config */

char *skip_blanks(char *string)
{
    while (*string && isspace(*string)) ++string;
    return string;
}

char *skip_to_blank(char *string)
{
        while (*string && !isspace(*string)) ++string;
        return string;
}

void ctl_string(char *copy, char *string)
{
    char *p;
    p=skip_blanks(string);
    strcpy(copy,p);
}

void ctl_path(char *copy, char *str)
{
    char *q;
    
    str= skip_blanks(str);
    for (q=str; *q && !isspace(*q); q++) ;
    *q= '\0';
	addslash(q);
    ctl_string(copy, str);
}

void ctl_file(char *copy, char *str)
{
    char *q;
    
    str= skip_blanks(str);
    for (q=str; *q && !isspace(*q); q++) ;
    *q= '\0';
    ctl_string(copy, str);
}

/* =============================================== CONFIG ACCESS */

BFIXPERM *get_perms(void )
{
	return cfg_perms;
}

BFIXPERM *get_fperms(void )
{
	return cfg_fperms;
}

BTCKANN *get_announce(void )
{
	return cfg_announce;
}

/* get outbound file name */

int get_out_fname(char *outdir,int zone, int net, int node, int point)
{
	char fileroot[BBSSTR];
	int i,got_it=0;
	
	if(point!=0)
	{
        for (i=0; i < nalias; i++)
        {
            if (alias[i].zone==zone && alias[i].net==net &&
               alias[i].node==node && alias[i].point==0)
            {
                net= alias[i].pointnet;
                node= point;
                point= 0;
                got_it++;
                break;
            }
        }
        if(!got_it)
        {
        	logline(3,"Can't find %d:%d/%d.%d fakenet!",zone,net,node,point);
        	return BBSFAIL;
        }
    }
	
	if(cfg_binkley) /* binkley outbound */
	{
		if(zone!=alias[0].zone)
			sprintf(outdir,"%s%c%4x%4x.HLO",get_outbound(),SYSSEPAR,
								net,node);
		else
			sprintf(outdir,"%s.%3x%c%4x%4x.HLO",get_outbound(),zone,SYSSEPAR,
								net,node);
	}
	else
	{ /* thebox outbound */
		strcpy(outdir,get_outbound());
		put36(fileroot,zone,2);
		put36(fileroot+2,net,3);
		put36(fileroot+5,node,3);
		strcat(fileroot,".HF");
		strcat(outdir,fileroot);
	}
	return BBSOK;
}

/* utility for above func, by Jac Kersing */

void put36(char *s, unsigned int n, int len)
{
	s += len;	/* Get to end of string! */
	*s-- = 0;	/* Null terminate */
	while(len--)
	{
		int d = n % 36;				/* Remainder */
		n /= 36;
		if(d < 10)
			*s-- = d + '0';
		else
			*s-- = d - 10 + 'A';
	}
}

/* get password */

void get_password(char *passwd,int zone, int net,int node,int point)
{
    int i;
    BPASSWORD *pw;
    
    pw=cfg_pwd->next;
    
    if (point)
    {
        for (i=0; i < nalias; i++)
        {
            if (alias[i].zone==zone && alias[i].net==net &&
                alias[i].node==node && alias[i].point==0)
            {
                net= alias[i].pointnet;
                node= point;
                point= 0;
                break;
            }
        }
    }
  
    while (pw!=NULL)
    {
       /* no match at all.. (yet) */
        if ( (pw->zone==zone) &&
       /* zone numbers match, now net */
            (pw->net==net) &&
       /* zone and net match.. node also? */
            (pw->node==node) &&
       /* and how about point */
           	(pw->point==point))
        {
                strcpy(passwd,pw->passw);
                return;
        }
        pw=pw->next;
    }
    *passwd= '\0';
}

/* find our address */

void get_ouraddress(FIDONODE *us, int zone, int net, int node, int point)
{
    int i;
    BPASSWORD *pw;
    
    pw=cfg_pwd->next;
    
    if (point)
    {
        for (i=0; i < nalias; i++)
        {
            if (alias[i].zone==zone && alias[i].net==net &&
               alias[i].node==node && alias[i].point==0)
            {
                net= alias[i].pointnet;
                node= point;
                point= 0;
                break;
            }
        }
    }

    while (pw!=NULL)
    {
       /* no match at all.. (yet) */
        if ((pw->zone==-1 || pw->zone==zone) &&
       /* zone numbers match, now net */
           (pw->net==-1 || pw->net==net) &&
       /* zone and net match.. node also? */
           (pw->node==-1 || pw->node==node) &&
       /* and how about point */
           (pw->point==-1 || pw->point==point))
        {
                us->zone=alias[pw->my_aka].zone;
                us->net=alias[pw->my_aka].net;
                us->node=alias[pw->my_aka].node;
                us->point=alias[pw->my_aka].point;
                return;
        }
        pw=pw->next;
    }
    us->zone=alias[0].zone;
    us->net=alias[0].net;
    us->node=alias[0].node;
    us->point=alias[0].point;

}

/* strings */

char *get_netmail(void )
{
	return cfg_netpath;
}

char *get_inbound(void )
{
	return cfg_mailpath;
}

char *get_outbound(void )
{
	if(cfg_binkley)
		return cfg_holdbink;
	return cfg_hold;
}

char *get_sysop(void )
{
	return cfg_sysop;
}

char *get_ticktemp(void)
{
	return cfg_temp;
}

/**/
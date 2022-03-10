/**************************************************************************
 *  PACK.C                                                                *
 *                                                                        *
 * Message bundler for use with The-Box/Pandora/QBBS-ST type messagebase  *
 *                                                                        *
 * PACK is part of the BERMUDA software. BERMUDA is a package of FidoNet  *
 * compatible message/nodelist processing software.                       *
 * Please read LICENSE for information about distribution.                *
 *                                                                        *
 * Written by Jac Kersing,                                                *
 * Modifications by Arjen Lentz and Enno Borgsteede                       *
 * Modifications by Vincent Pomey and Franck Arnaud                       *
 **************************************************************************/

#define MAXMSGLEN (30 * 1024)   /* Don't increase it too much or PC's
                                 * won't like it!!
                                 */

#define MAILER              /* needed in PANDORA.H */

#include "pandora.h"        /* for structure of the area's etc. */
#include <string.h>

#if TC
#include <dos.h>
#endif

#if STTC
#ifdef LINN
#include <tos.h>	/* Dcreate for bibi */
#endif
#endif

#include "mail.h"           /* pretty obvious if your packing mail.. */

#include "pack.pro"
#include "route.pro"
#include "utextra.pro"

#define UVERSION "1.22"  /* version-number */
#define isBERMUDA 0xA0       /* productcode for BERMUDA */

#define DEBUG    0           /* show debugging info? */

#ifdef  ERROR
#undef  ERROR
#endif

struct _passw           /* structure for passwords */
{
  char passw[8];        /* the password itself */
  int  zone;            /* zone number for remote */
  int  net;             /* net number for remote */
  int  node;            /* node number for remote */
  int  point;           /* point number for remote */
  int  my_aka;          /* the number in the addresslist for this sucker */
  struct _passw *next;  /* pointer to next struct */
} ;

struct _aka
{
 int zone;
 int net;
 int node;
 int point;
 int pointnet;
} ;

char progname[]="B-P";      /* program name for logging */
FILE *fopen(), *pkt;        /* the mailpacket */
char *Bpath="";             /* path for mailer info */

struct _pkthdr phdr;        /* storage for packetheader */
struct _pktmsgs mhdr;       /* header of current message */
struct Hdr Mhdr;            /* storage for outgoing message header  */
struct Hdr Shdr;            /* save message header */

char arc_prg[90];           /* archive program name */
char arc_cmd[90];           /* commands for archive program */
#ifdef LINN
#define ARC 0
#define ZIP 1
#define ZOO 2
#define LZH 3
#define ARJ 4
char archiv_prg[5][90];
char archiv_cmd[5][90];
int  binkley=0;
#endif

char *hold;                 /* path to hold area                    */
#ifdef LINN
char *holdbink;             /* same but without trailing /          */
int  addintl=0;				/* always add intl lines in netmail		*/
#endif
char *mailpath;             /* path to netmail                      */
char *netpath;              /* path to netmsgs                      */
struct _aka alias[30];      /* aliases                              */
int  nalias;                /* number of aliases                    */
int  verbose=6;             /* level for message displaying         */
int  loglevel;              /* level for message logging            */
char *logname;              /* name of logfile                      */
FILE *log;                  /* filepointer for logfile              */
struct _passw *pwd;         /* password pointer                     */

int  ourzone;               /* zone,                                */
int  ournet;                /*      net and                         */
int  ournode;               /*              node of our BBS         */
int  ourpoint;              /*                 point                */
int  ourpointnet;           /* we've got a pointnet too             */
char ourpwd[10];            /* the password we're using now         */

char active[20];            /* the active if                        */

char *MESSAGE;              /* adress of message buffer (malloced)  */

FILE *MHDR;
FILE *MMSG;

int  pktzone[10];           /* zone, net, node                      */
int  pktnet[10];            /* = address for open packet            */
int  pktnode[10];           /* used for saving messages to          */
int  pkttype[10];           /* type of packet (Crash/Hold/Normal)   */
FILE *pktfile[10];          /* the packet                           */

char *pktnames[1000];

#ifdef LINN
char binktype(char in);
char *convert (char *name);
int hextoint (char *str, int len);
char *ffirstout(char *name);
char *fnextout(void);

/* converts the The-Box letter for mail type to Binkley */
char binktype(char in)
{
	switch(in)
	{
		case 'W':	/* hold */
		case 'H':
		return 'H';
		
		case 'I': /* crash /direct ? */
		case 'C':
		return 'C';

		case 'P': /* poll files */
		case 'A': /* along doesn't exist with bink */
		case 'N': /* normal */
		return 'O';

	}
	message (6, "!Mhhhmm, I'm buggy");
	return 'H';
}

char boxtype(char in)
{
	switch(in)
	{
		case 'H':
		return 'W';
		
		case 'D':
		case 'C':
		return 'C';
		
		case 'O':
		return 'N';
		
		case 'F': /* poll files */
		return 'P';

	}
	message (6, "!Mhhhmm, I'm buggy");
	return 'W';
}

/* simulate ffirst/fnext on a Binkley outbound */
/* depends highly on the way they are used ! */
/*  ie:calls with hold/*.?t where t is the mail type */
/*  and uses only the names to find out the zone/net/node */

char fouttype, foutflav;	/* the type and flavor of mail beeing scanned */
char foutname[100];		/* the name returned, in The-Box format */
int  numscanzone, curzone;	/* number of zones already scanned */

/* converts a Binkley file name to a The-Box filename, using curzone */
char *convert (char *name)
{
	int net, node, point;

	if (name==NULL)
		return NULL;
	net=ztoi (name, 3);
	node=ztoi (name+3, 3);
	point=ztoi (name+6, 2);
	if (point)
		return fnextout();
	sprint (foutname, "%02z%03z%03z.%c%c", curzone, net, node, boxtype(name[9]), (name[10]=='P') ? 'M' : name[10]);
	return foutname;
}

int hextoint (char *str, int len)
{
	int temp;
	
	temp = 0;
	while(*str && len-- && isalnum(*str))
	{
		temp *= 16;
		temp += isdigit(*str) ? *str-'0' : toupper(*str)-'A'+10;
		str++;
	}
	return temp;
}

char *ffirstout(char *name)
{
	char tmp[100], *res;
	
	if (!binkley)
		return ffirst (name);
	numscanzone=0;
	fouttype=(name[strlen(name)-1]=='M') ? 'P' : name[strlen(name)-1];
	foutflav=(name[strlen(name)-2]=='?') ? '?' : binktype(name[strlen(name)-2]);
	/* first, scan the main zone */
	curzone=alias[0].zone;
	sprintf (tmp, "%s*.%c%cT", hold, foutflav, fouttype);
	res=ffirst(tmp);
	if (res==NULL)
		return fnextout();
	else	return convert(res);
}

char *fnextout()
{
	char *res, tmp[100];
	int i;
	
	if (!binkley)
		return fnext();
	res=fnext();
	if (res==NULL) {
		/* end of zone directory scan, go to the next zone */
		sprintf (tmp, "%s.???", holdbink);
		i=numscanzone;
		res=ffirst (tmp);
		while (i--)
			res=fnext();	/* skip the directory already scanned */
		if (res==NULL)
			return NULL;
		numscanzone++;
		curzone=hextoint (res+strlen(res)-3, 3);
		sprint (tmp, "%s.%03y%c*.%c%cT", holdbink, curzone, DIRSEP, foutflav, fouttype);
		return convert (ffirst (tmp));
	}
	else return convert (res);
}
#endif

/* Ok, so far all definitions. The program is next.. */

char *skip_blanks(string)
char *string;
{
    while (*string && isspace(*string)) ++string;
    return string;
}

char *skip_to_blank(string)
char *string;
{
        while (*string && !isspace(*string)) ++string;
        return string;
}

char *myalloc(sp)
size_t sp;
{
    char *tmp;
    
    tmp=malloc(sp);
    if (tmp==NULL)
    {
        message(6,"!Mem error");
        exit(1);
    }
    return tmp;
}

char *ctl_string(string)
char *string;
{
    char *p, *d;
    p=skip_blanks(string);
    d=myalloc(strlen(p)+1);
    strcpy(d,p);
    return d;
}

char *ctl_path(str)
char *str;
{
    char *q;
    
    str= skip_blanks(str);
    for (q=str; *q && !isspace(*q); q++) ;
    *q= '\0';
#if UNIX
    if (*(q-1)!='/') strcat(q,"/");
#else
    if (*(q-1)!='\\') strcat(q,"\\");
#endif
    return ctl_string(str);
}

char *ctl_file(str)
char *str;
{
    char *q;
    
    str= skip_blanks(str);
    for (q=str; *q && !isspace(*q); q++) ;
    *q= '\0';
    return ctl_string(str);
}

int init_conf()
{
    FILE *conf;                     /* filepointer for config-file */
    char buffer[256];               /* buffer for 1 line */
    char *p;                        /* workhorse */
#ifdef LINN
     char *q;
#endif
    int count;                      /* just a counter... */
    char *getenv();                 /* get the environment string */

    /* Try to find the path for configuration */
    
    p=getenv("MAILER");
    if (!ffirst("bermuda.cfg") &&      /* check local config */
        !ffirst("tb.cfg") &&
        p!=NULL && *p!='\0')
    {                                   /* no local, and envi contained one */
        Bpath= ctl_path(p);
    }

    /* set all to default values */
    
    loglevel=255;
    ourzone=ournet=ournode=ourpoint=0;

    sprintf( buffer, "%sbermuda.cfg", Bpath);
    conf= fopen(buffer, "r");

    if (conf==NULL)
    {
        sprintf(buffer,"%stb.cfg", Bpath);

        conf = fopen(buffer, "r");
    }

    if (conf==NULL)
    {
        message(6,"!Configuration file not found, please check!!!");
        return 1;                           /* not found, back */
    }

    message(-1,"+Parsing configuration file");
       
    while((fgets(buffer, 250, conf)))       /* read a line */
    {
        p=skip_blanks(buffer);
        if (*p==';') continue;               /* comment?? */

        /* delete ALL chars following (and inclusive) after comment sign */
        if ((p=strchr(buffer,';'))!=NULL)  *p= '\0';
        if ((count= (int)strlen(buffer))<3) continue;
                                            /* what's the length of the rest? */
        p= &buffer[--count];
        if (*p=='\n') *p=0;                 /* delete (possible) newline char */

#ifdef LINN
        /* process "application bermuda" lines as normal lines */
        if (!strnicmp(buffer,"application",11))
        {
        	p=skip_blanks(&buffer[11]);
        	if(!strnicmp(p,"bermuda",7)) {
        		p=skip_blanks(&p[7]);
        		strcpy (buffer, p);
        	}
        }
#endif
        if (!strnicmp(buffer,"address",7))
        {
            p=skip_blanks(&buffer[7]);
            if(getaddress(p,&alias[nalias].zone, &alias[nalias].net,
                &alias[nalias].node, &alias[nalias].point)!=7)
            {
               message(3,"!Invalid address in %s",buffer);
               continue;
            }
            p=skip_blanks(skip_to_blank(p));

            if (*p=='+' || *p=='*') p=skip_blanks(skip_to_blank(p));

            if (*p && isdigit(*p))
            {
                if ((alias[nalias].pointnet=atoi(p))==0)
                {
                   message(6,"!Invalid pointnet in %s",buffer);
                   continue;
                }
            }
            else alias[nalias].pointnet=0;
            ++nalias;

            ourzone=alias[0].zone;
            ournet=alias[0].net;
            ournode=alias[0].node;
            ourpoint=alias[0].point;
            ourpointnet=alias[0].pointnet;

            continue;
        }

        if (!strnicmp(buffer,"loglevel",8))
        {
            p=skip_blanks(&buffer[8]);
            if (sscanf(p,"%d", &count)!=1 || count>6 || count<0)
                message(3,"-Invalid loglevel (%s)", p);
            else loglevel=count;
            continue;
        }

        if (!strnicmp(buffer, "statuslog",9))
        {
            logname= ctl_string(&buffer[9]);
            if ((log=fopen(logname, "a"))==NULL)
                if ((log=fopen(logname, "w+"))==NULL)
                {
                    message(6,"!Could not create logfile!");
                    free(logname);
                    logname=NULL;
                }
            else
            {
                fflush(log);
            }
            continue;
        }

        if (!strnicmp(buffer,"netfile",7))
        {
            mailpath=ctl_path(&buffer[7]);
            continue;
        }

        if (!strnicmp(buffer,"netmail",7))
        {
            netpath=ctl_string(&buffer[7]);
            continue;
        }

        if (!strnicmp(buffer,"hold",4))
        {
            hold=ctl_path(&buffer[4]);
#ifdef LINN
            holdbink=strdup(hold); holdbink[strlen(holdbink)-1]=0;
#endif
            continue;
        }

        if (!strnicmp(buffer,"key",3))
        {
            parsekey(&buffer[3]);
            continue;
        }
#ifdef LINN
	if (!strnicmp(buffer,"arcpack", 7))
	{
	    p=skip_blanks(&buffer[7]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (archiv_prg[ARC], p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (archiv_cmd[ARC], p);
	    continue;
	}

	if (!strnicmp(buffer,"zippack", 7))
	{
	    p=skip_blanks(&buffer[7]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (archiv_prg[ZIP], p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (archiv_cmd[ZIP], p);
	    continue;
	}

	if (!strnicmp(buffer,"zoopack", 7))
	{
	    p=skip_blanks(&buffer[7]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (archiv_prg[ZOO], p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (archiv_cmd[ZOO], p);
	    continue;
	}

	if (!strnicmp(buffer,"lzhpack", 7))
	{
	    p=skip_blanks(&buffer[7]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (archiv_prg[LZH], p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (archiv_cmd[LZH], p);
	    continue;
	}

	if (!strnicmp(buffer,"arjpack", 7))
	{
	    p=skip_blanks(&buffer[7]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (archiv_prg[ARJ], p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (archiv_cmd[ARJ], p);
	    continue;
	}
	if (!strnicmp(buffer,"binkley", 7))
	{
	    binkley=1;
	    continue;
	}
#endif
    }
    
    fclose(conf);
    
    return 0;                           /* signal OK */
}

void parsekey(p)
char *p;
{
    int i;
    char password[9];
    struct _passw *pw,*pn;
    int zone,net,node,point;
    int my_aka=0;
    
    /* get to the end of the list. */
    pw=pwd;
    while (pw->next!=NULL) pw=pw->next;

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
                    message(3,"-Address %d:%d/%d.%d used in key is unknown",
                     zone,net,node,point);
                }
            }

            p= skip_to_blank(p);
            p= skip_blanks(p);
            continue;
        }

        pn=pw->next= (struct _passw *) myalloc(sizeof(struct _passw));

        if (!getaddress(p,&zone,&net,&node,&point))
        {
            free(pn);
            pw->next=NULL;
            message(3,"-Invalid address: %s",p);
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
        if (temp>32767) return (-1);
        *p=q; *i=(int) temp;
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

int getalias(zone,net,node,point)
int zone,net,node,point;
{
    int i;
    struct _passw *pw;
    
    pw=pwd->next;
    
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
                ourzone=alias[pw->my_aka].zone;
                ournet=alias[pw->my_aka].net;
                ournode=alias[pw->my_aka].node;
                ourpoint=alias[pw->my_aka].point;
                ourpointnet=alias[pw->my_aka].pointnet;
                return 1;
        }
        pw=pw->next;
    }
    ourzone=alias[0].zone;
    ournet=alias[0].net;
    ournode=alias[0].node;
    ourpoint=alias[0].point;
    ourpointnet=alias[0].pointnet;
    return 0;
}

void get_passw(zone,net,node,point)
int zone,net,node,point;
{
    int i;
    struct _passw *pw;
    
    pw=pwd->next;
    
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
                strcpy(ourpwd,pw->passw);
                return;
        }
        pw=pw->next;
    }
    *ourpwd= '\0';
}

void Init(argc, argv)       /* initialize everything needed */
int argc;                   /* counter */
char *argv[];               /* commandline crap */
{
    int  i;                 /* counter */
    int  the_box=0;         /* flags to signal we wanna use logging */

#ifdef LINN
    archiv_prg[ARC][0] = '\0';
    archiv_prg[ZIP][0] = '\0';
    archiv_prg[ZOO][0] = '\0';
    archiv_prg[LZH][0] = '\0';
    archiv_prg[ARJ][0] = '\0';
#endif
#if     MEGAMAX | MWC | STTC
    strcpy(arc_prg,"ARC.TTP");
#endif
#if     TC
    strcpy(arc_prg,"ARC.EXE");
#endif
    strcpy(arc_cmd,"M");

    pwd= (struct _passw *) myalloc(sizeof(struct _passw));
    pwd->zone=pwd->net=pwd->node=pwd->point=0;
    pwd->next=NULL;

    if (init_conf()) exit(2);       /* first parse config file */
    
    for (i=1;i<argc;i++)
    {
        if (argv[i][0]=='-')
        {
            switch(toupper(argv[i][1]))
            {
              case 'S': if (i+1< argc)
                        {
                            strncpy(active,argv[i+1],20);
                            ++i;
                            active[19]='\0';
                        }
                        break;
              case 'T': ++the_box;      break;
              case 'A': *arc_cmd= *arc_prg= '\0';
                        if (i+1<argc)
                        {
                            strncpy(arc_prg,argv[i+1],89);
                            i++;
                            while (i<argc-1 &&
                              (strlen(arc_cmd)+strlen(argv[i+1]))<88)
                            {
                                strcat(arc_cmd,argv[i+1]);
                                strcat(arc_cmd," ");
                                i++;
                            }
                        }
                        break;
              case 'I': addintl++; break;
              default : message(6,"!Unknown option %s",argv[0]);
            }
        }
    }

    if (!netpath || !*netpath)
    {
        message(6,"!Don't know the path to your mailarea..");
        exit(2);
    }

    if (!the_box) loglevel=255;     /* called from command-line, no logging */

    if (loglevel<2) verbose=6;
}

void OpenMail()
{
    char buffer[80];

    sprintf(buffer,"%s.MSG",netpath);
    if((MMSG=fopen(buffer, BRUP))==NULL) MMSG=fopen(buffer, BWUP);
    sprintf(buffer,"%s.HDR",netpath);
    if((MHDR=fopen(buffer, BRUP))==NULL) MHDR=fopen(buffer, BWUP);
    if (!MMSG || !MHDR)
    {
        message(6,"!Error opening Mailarea");
        exit(1);
    }

    if ((MESSAGE=malloc(MAXMSGLEN))==NULL)                            /* Agl */
    {
        message(6,"!Mem error");
        exit(-39);
    }
}

void CloseMail()
{
        /* Close files and free memory used for message storage */
        free(MESSAGE);
        fclose(MHDR);
        fclose(MMSG);
}

void InitPackets()
{
        int i;

        for (i=0;i<10;i++)
        {
                pktzone[i]= pktnet[i]= pktnode[i]= 0;
                pktfile[i]= NULL;
        }
}

void ClosePacket(nr)
int nr;
{
#if DEBUG
print("Close packet\n");
#endif
    if (pktfile[nr])
    {
        pktzone[nr]= pktnet[nr]= pktnode[nr]= 0;
        if (fwrite("\0\0", 2, 1, pktfile[nr])!=1)
        {
            message(6,"!Error writing to packet");
            exit(1);
        }
        fclose(pktfile[nr]);
    }
}

void DeInitPackets()
{
        int i;

#if DEBUG
print("DeInit packets\n");
#endif
        for (i=0; i<10; i++)
        {
            if (pktzone[i]!=0 || pktnet[i]!=0 || pktnode[i]!=0)
            {
                ClosePacket(i);
            }
        }
}

int OurMessage(from)
int from;
{
        int i;
        int zone, net, node, point;

        /* Checks whether it's a message from/to one of our Aka's */
        if (from)
        {
                zone=Mhdr.Ozone;
                net= Mhdr.Onet;
                node= Mhdr.Onode;
                point= Mhdr.Opoint;
        }
        else
        {
                zone= Mhdr.Dzone;
                net= Mhdr.Dnet;
                node= Mhdr.Dnode;
                point= Mhdr.Dpoint;
        }

        for (i=0; i<nalias; i++)
        {
                if (alias[i].zone==zone && alias[i].net==net &&
                    alias[i].node==node && alias[i].point==point) return 1;
        }
#ifdef LINN
	/* check also pointnet address */
	if (point==0) {
	        for (i=0; i<nalias; i++)
        	{
                	if (alias[i].zone==zone && alias[i].pointnet==net &&
	                    alias[i].point==node) return 1;
        	}
	}
#endif
        return 0;
}

int ReadMessage()
{
    *MESSAGE=0;
    if (fread((char *) &Mhdr, sizeof(struct Hdr), 1, MHDR)!=1) return -1;
    
    if (Mhdr.flags & DELETED) return 0;
    if (Mhdr.flags & SENT) return 0;
    if (Mhdr.mailer[0]) return 0;
    if (OurMessage(0)) return 0;
    if (Mhdr.Dnode==65535U || Mhdr.Dnet==65535U || Mhdr.Dzone==65535U) return 0;

    memcpy(&Shdr, &Mhdr, sizeof(struct Hdr));
    fseek(MMSG,Mhdr.Mstart,SEEK_SET);
    if (Mhdr.size > MAXMSGLEN) {
       message(6,"!Message too long (%u)",Mhdr.size);
       return (-1);
    }

    if (fread(MESSAGE, Mhdr.size, 1, MMSG)!=1)
    {
        message(6,"!Error reading message from file");
        return -1;
    }
    *(MESSAGE + Mhdr.size)= '\0';

    if (Mhdr.flags & MSGLOCAL) return 1;
    if (OurMessage(1)) return 0;
    if (ForwardOk(Mhdr.Ozone,Mhdr.Onet,Mhdr.Onode,Mhdr.Opoint,
                     Mhdr.Dzone,Mhdr.Dnet,Mhdr.Dnode,Mhdr.Dpoint,
                     Mhdr.flags & CRASH, Mhdr.flags & FILEATCH)) return 1;
    /* If we're not forwarding crashmail, then as normal mail?? */
    if (ForwardOk(Mhdr.Ozone,Mhdr.Onet,Mhdr.Onode,Mhdr.Opoint,
                     Mhdr.Dzone,Mhdr.Dnet,Mhdr.Dnode,Mhdr.Dpoint,
                     0, Mhdr.flags & FILEATCH))
    {
        Mhdr.flags &= ~CRASH;
        return 1;
    }
    return 0;
}

void SaveMessage()
{
#if DEBUG
print("SaveMessage\n");
#endif
    fseek(MHDR, ftell(MHDR) - (long) sizeof(struct Hdr), SEEK_SET);
    if (fwrite((char *) &Shdr, sizeof(struct Hdr), 1, MHDR)!=1)
    {
        message(6,"!Error writing message to file");
        exit(1);
    }

    /* Don't tell me this should do the job, I know, tell TC 2.0 (PC) */
    fflush(MHDR);

    /* But this never failed, so... */
    fseek(MHDR,ftell(MHDR),SEEK_SET);
}

void Destination(zone,net,node,type)
int *zone, *net, *node, *type;
{
    int i;
    int pzone, pnet, pnode;

/*
    *zone= Mhdr.Dzone;
    *net= Mhdr.Dnet;
    *node= Mhdr.Dnode;
    if (Mhdr.Dpoint!=0)
    {
        for (i=0; i<nalias; i++)
        {
            if (alias[i].zone== *zone && alias[i].net== *net &&
                alias[i].node== *node && alias[i].point==0) break;
        }
        if (i<nalias)
        {
            *net=alias[i].pointnet;
            *node=Mhdr.Dpoint;
        }
    }
*/
#ifdef LINN
    /* since Direct flag may not be set by some message editors,
       setting both Crash and Hold flags is equivalent */
    /* note that DIRECT flag (bit 10) is zeroed on importing, but not
       on exporting (best way ?) */
    if ((Mhdr.flags & (CRASH+MSGHOLD)) == CRASH+MSGHOLD) {
        Mhdr.flags |= DIRECT;
        Mhdr.flags -= CRASH+MSGHOLD;
    }
#endif
    ToWhere(zone,net,node,Mhdr.Dzone,Mhdr.Dnet,Mhdr.Dnode,Mhdr.Dpoint,
#ifdef LINN
            Mhdr.flags & (CRASH+DIRECT), Mhdr.flags & FILEATCH);
#else
            Mhdr.flags & CRASH, Mhdr.flags & FILEATCH);
#endif

    *type = Mhdr.flags & CRASH ? 'C' : Mhdr.flags & MSGHOLD ? 'H' : 'N';

    /* Remap if it's to one of our points and it's a packet to him/her */
    if (Mhdr.Dpoint!=0)
    {
        pzone= Mhdr.Dzone;
        pnet= Mhdr.Dnet;
        pnode= Mhdr.Dnode;

        for (i=0; i<nalias; i++)
        {
            if (alias[i].zone== pzone && alias[i].net== pnet &&
                alias[i].node== pnode && alias[i].point== 0) break;
        }
        if (i<nalias)
        {
            pnet=alias[i].pointnet;
            pnode=Mhdr.Dpoint;
            if (pnode== *node && pnet== *net && pzone== *zone)
            {
                /* It seems to be directly to our point, Pfew */
                Mhdr.Dnode= pnode;
                Mhdr.Dpoint= 0;
                Mhdr.Dnet= pnet;
            }
        }
    }
}

void OpenPacket(nr,zone,net,node,type)
int nr, zone, net, node, type;
{
    struct time t;
    struct date d;
    struct _pkthdr phdr;
    char fname[80];

#if DEBUG
print("Open packet[%d] %d:%d/%d, type %c\n",nr,zone,net,node,type);
#endif
    /* Get password first before all information is destroyed */
    getalias(zone,net,node,0);
    get_passw(zone,net,node,0);

#ifdef LINN
    if (binkley)
    	if (zone==alias[0].zone)
		sprint(fname, "%s%03z%03z00.%cPT", hold, net, node, binktype((char)type));
	else	sprint(fname, "%s.%03y%c%03z%03z00.%cPT", holdbink, zone, DIRSEP, net, node, binktype((char)type));
    else
	sprint(fname, "%s%02z%03z%03z.%cM", hold, zone, net, node, type);
#else
    sprint(fname, "%s%02z%03z%03z.%cM", hold, zone, net, node, type);
#endif

    pktzone[nr]= zone;
    pktnet[nr]= net;
    pktnode[nr]= node;
    pkttype[nr]= type;

    pktfile[nr]= fopen(fname,BRUP);
    if (pktfile[nr]!=NULL)
    {
        fseek(pktfile[nr],-2L,SEEK_END);
        return;
    }

    pktfile[nr]= fopen(fname,BWUP);
    if (pktfile[nr]==NULL)
    {
        message(6,"!Can't open file %s",fname);
        exit(1);
    }

    /* new packet, we've to make a header first */
    getdate(&d);
    gettime(&t);
    memset(&phdr, 0, sizeof(struct _pkthdr));

    /* are we a point and not to boss then re-address */
    if (ourpoint)
    {
        if (ournode!=node || ournet!=net || ourzone!=zone)
        {
            phdr.ph_onode= inteli(-1);
            phdr.ph_onet = inteli(ournet);
        }
        else
        {
            phdr.ph_onode= inteli(ourpoint);
            phdr.ph_onet= inteli(ourpointnet);
        }
    }
    else
    {
        phdr.ph_onode=inteli(ournode);
        phdr.ph_onet=inteli(ournet);
    }
    phdr.ph_ozone=inteli(ourzone);
    phdr.ph_dnode=inteli(node);
    phdr.ph_dnet=inteli(net);
    phdr.ph_dzone=inteli(zone);
    phdr.ph_yr=inteli(d.da_year);
    phdr.ph_mo=inteli(d.da_mon-1);
    phdr.ph_dy=inteli(d.da_day-1);
    phdr.ph_hr=inteli(t.ti_hour);
    phdr.ph_mn=inteli(t.ti_min);
    phdr.ph_sc=inteli(t.ti_sec);
    phdr.ph_rate=0;
    phdr.ph_ver=inteli(2);
    phdr.ph_prod=inteli(isBERMUDA);
    strncpy(phdr.ph_pwd,ourpwd,8);
    if( fwrite((char *)&phdr, sizeof(struct _pkthdr), 1, pktfile[nr]) !=1)
    {
        message(6,"-Write error (disk full??)");
        exit(1);
    }
}

int MakeMsg(nr)
int nr;
{
    struct _pktmsgs mh;
#ifndef LINN
    struct date d;
    struct time t;
#endif
    FILE *pkt= pktfile[nr];
    FILE *temp;
    int direct=0;
    char *p, *q;
    char files[80];
    char name[80];
#ifdef LINN
    char tmp[100];
#endif
    
#if DEBUG
print("MakeHdr\n");
#endif
    mh.pm_ver=inteli(2);

#ifdef LINN
    /* Change origin of netmail if needed */
    if (OurMessage(1))
    {
#if DEBUG
printf("origine %d:%d/%d.%d\n", Mhdr.Dzone, Mhdr.Dnet, Mhdr.Dnode, Mhdr.Dpoint);
#endif
        getalias(Mhdr.Dzone, Mhdr.Dnet, Mhdr.Dnode, 0 /* VP Mhdr.Dpoint*/);
#if DEBUG
printf("changed to %d:%d/%d.%d\n", ourzone, ournet, ournode, ourpoint);
#endif
        Mhdr.Ozone  = Shdr.Ozone  = ourzone;
        Mhdr.Onet   = Shdr.Onet   = ournet;
        Mhdr.Onode  = Shdr.Onode  = ournode;
        Mhdr.Opoint = Shdr.Opoint = ourpoint;
    }
#endif

    /* Get the correct ID, we might need it */
    getalias(pktzone[nr], pktnet[nr], pktnode[nr], 0);          /* ,0 by Agl */

    /* mail to boss or direct mail? */
    if (Mhdr.Opoint && OurMessage(1) &&
        (pktzone[nr]!=ourzone || pktnet[nr]!=ournet || pktnode[nr]!=ournode))
    {
        /* direct to other than BOSS --> re-addressing! */
        mh.pm_onode=inteli(ournode);
        mh.pm_onet=inteli(ournet);
        direct=1;
    }
    else
    {
        /* to BOSS (or normal BBS opperation) --> normal address */
        mh.pm_onode=inteli(Mhdr.Onode);
        mh.pm_onet=inteli(Mhdr.Onet);
    }

    mh.pm_dnode=inteli(Mhdr.Dnode);
    mh.pm_dnet=inteli(Mhdr.Dnet);
    if (Mhdr.Dzone && pktzone[nr] && (Mhdr.Dzone!=pktzone[nr]))
    {
        mh.pm_dnet=inteli(Mhdr.Ozone);
        mh.pm_dnode=inteli(Mhdr.Dzone);
    }

    mh.pm_attr=inteli(Mhdr.flags&0x3413);
    mh.pm_cost=inteli(Mhdr.cost);
    fwrite((char *)&mh, sizeof(struct _pktmsgs), 1, pkt);
    fprintf(pkt,"%19s",Mhdr.time);
    putc('\0',pkt);
    fprintf(pkt,"%s",Mhdr.to);        /* from & to */
    putc('\0',pkt);
    fprintf(pkt,"%s",Mhdr.from);
    putc('\0',pkt);
    
    if (verbose>1) message(1,"=%s (%d:%d/%d.%d) --> %s (%d:%d/%d.%d)",Mhdr.from,
        Mhdr.Ozone, Mhdr.Onet, Mhdr.Onode, Mhdr.Opoint,
        Mhdr.to, Mhdr.Dzone, Mhdr.Dnet, Mhdr.Dnode, Mhdr.Dpoint);
    
    if (Mhdr.flags&FILEATCH)
    {
#ifdef LINN
        if (binkley)
		if (pktzone[nr]==alias[0].zone)
			sprint(name, "%s%03z%03z00.%cFT", hold, pktnet[nr], pktnode[nr], binktype((char)pkttype[nr]));
		else	sprint(name, "%s.%03y%c%03z%03z00.%cFT", holdbink, pktzone[nr], DIRSEP, pktnode[nr], binktype((char)pkttype[nr]));
    else
        sprint( name,"%s%02z%03z%03z.%cF", hold, pktzone[nr],pktnet[nr],
           pktnode[nr],pkttype[nr]);
#else
        sprint( name,"%s%02z%03z%03z.%cF", hold, pktzone[nr],pktnet[nr],
           pktnode[nr],pkttype[nr]);
#endif

        if((temp=fopen(name,"a+"))==NULL && (temp=fopen(name,"w+"))==NULL)
        {
            message(6,"!!! Error opening file attaches: %s",name);
            message(6,"!!! for file(s): %s",Mhdr.topic);
            return -1;
        }

        strcpy(files,Mhdr.topic);
        q= files;

        while (*q)
        {
            p= q;
            /* Find end of filename */
            while (*q && !isspace(*q) && *q!=',') q++;

            if (*q)
            {
                *q='\0';
                q++;
            }

            /* to attach file (fix path if forwarding) */
            fprintf(temp, "%s%s\n",
            	(OurMessage(1) || (Mhdr.flags&MSGLOCAL)) ? "" : mailpath,
            	p);

            /* strip path */
            p= q-2;
#if UNIX
            while (p!=files && *p && *p!=':' && *p!='/') --p;
            if (!*p || *p==':' || *p=='/') ++p;
#else
            while (p!=files && *p && *p!=':' && *p!='\\') --p;
            if (!*p || *p==':' || *p=='\\') ++p;
#endif

            /* to message */
            fprintf(pkt,"%s ",p);         /* plain filename (no path) */

	    /* display in logfile too */
            if (verbose>1) message(1,"= File %s",p);
        }
        fclose(temp);
    }
    else
    {
        fprintf(pkt,"%s",Mhdr.topic);     /* topic */
    }
    putc('\0',pkt);
    
    if (Mhdr.Ozone && Mhdr.Dzone && ((Mhdr.Ozone!=Mhdr.Dzone) || addintl))
        fprintf(pkt,"\01INTL %d:%d/%d %d:%d/%d\r\n", Mhdr.Dzone,
          Mhdr.Dnet, Mhdr.Dnode, Mhdr.Ozone, Mhdr.Onet, Mhdr.Onode);
    if (Mhdr.Dpoint!=0 && pktnet[nr]!=ourpointnet)
        fprintf(pkt,"\01TOPT %d\r\n",Mhdr.Dpoint);

    /* We do NOT allow points under points! (gives 2 kludge lines) */
    if (direct)
    {
        fprintf(pkt,"\01FMPT %d\r\n",ourpoint);
    }
    if (Mhdr.Opoint!=0)
        fprintf(pkt,"\01FMPT %d\r\n",Mhdr.Opoint);

    p= MESSAGE;
    while (*p)                            /* message */
    {
        if (*p=='\n') putc('\r',pkt);
        putc(*p,pkt);
        p++;
    }

    if (!OurMessage(1))
    {
#ifdef LINN
	/* display date in european (?) format */
	sprint (tmp, "\01Via Bermuda-P %s %d:%d/%d, $D $m $y at $T\r\n",
                UVERSION, ourzone, ournet, ournode); 
        fprintf(pkt, tmp);
#else
        getdate(&d);
        gettime(&t);
        fprintf(pkt,"\r\n\01Via Node %d:%d/%d %02d:%02d %02d/%02d by BERMUDA-P %s\r\n",
                ourzone, ournet, ournode, t.ti_hour, t.ti_min, d.da_mon, d.da_day, UVERSION);
#endif
    }
    putc('\0',pkt);                     /* terminator */

    Shdr.flags |= SENT;
    if (Shdr.flags & KILLSEND) Shdr.flags |= DELETED;
    return (0);
}

void PackTo(zone, net, node, type)
int zone, net, node, type;
{
        int i;
        int empty=-1;
        static int j=0;

        for (i=0; i<10; i++)
        {
                if (pktfile[i]==NULL && empty==-1) empty=i;
                if (zone==pktzone[i] && net==pktnet[i] &&
                    node==pktnode[i] && type==pkttype[i]) break;
        }

        if (i>=10)
        {
                if (empty==-1)
                {
                        ClosePacket(j);
                        i= j;
                        j= (j==9) ? 0 : j+1;
                }
                else i=empty;
                OpenPacket(i,zone,net,node,type);
        }

        MakeMsg(i);
}

#ifdef LINN
int CallArc(archiver, comline, zone, net, node, type)
char *archiver, *comline;
int  zone, net, node, type;
{
    char newname[80];
    char arcname[80];
    char buffer[80];
    char cmd[128];
    char *buf;
    struct date d;
    struct time t;
    int result;
    FILE *fd;

    getdate(&d);
    gettime(&t);

    if (!archiver) {
    	/* if undefined, compatibility */
    	archiver=arc_prg;
    	comline=arc_cmd;
    }

    if (binkley)
    	if (zone==alias[0].zone) {
		sprint(buffer, "%s%03z%03z00.%cPT", hold, net, node, binktype((char)type));
		sprint(newname, "%s%02d%02d%02d%02d.PKT", hold, d.da_day, t.ti_hour, t.ti_min, t.ti_sec);
	} else {
		sprint(buffer, "%s.%03y%c%03z%03z00.%cPT", holdbink, zone, DIRSEP, net, node, binktype((char)type));
		sprint(newname, "%s.%03y%c%02d%02d%02d%02d.PKT", holdbink, zone, DIRSEP, d.da_day, t.ti_hour, t.ti_min, t.ti_sec);
	}
    else {
	sprint(buffer, "%s%02z%03z%03z.%cM", hold, zone, net, node, type);
	sprint(newname, "%s%02d%02d%02d%02d.PKT", hold, d.da_day, t.ti_hour, t.ti_min, t.ti_sec);
    }

    if (rename(buffer,newname)) {
        message(6,"!Fatal error renaming packet %s",buffer);
        exit(2);
    }

    /* Ok it has got a 'standard' name now, next step is finding
       an archive */

    if (binkley)
    	if (zone==alias[0].zone)
		sprint(arcname, "%s%03z%03z00.%cAT", hold, net, node, binktype((char)type));
	else	sprint(arcname, "%s.%03y%c%03z%03z00.%cAT", holdbink, zone, DIRSEP, net, node, binktype((char)type));
    else
	sprint(arcname, "%s%02z%03z%03z.%cA", hold, zone, net, node, type);


	/* set up command line */
        buf=cmd+1;	/* copy to buffer2 the command line */
        while (*comline != '\0') {
        	if (*comline != '%')
        		*buf++ = *comline++;
        	else {
        		switch (*++comline) {
        			case 'p' : /* %p = packet */
					   strcpy (buf, newname);
        				   buf = &buf[strlen(buf)];
        				   break;
        			case 'n' : /* %n = archive name */
					   strcpy (buf, arcname);
        				   buf = &buf[strlen(buf)];
        				   break;
        			case 'd' : /* %d = hold path */
        				   if ((binkley) && (zone != alias[0].zone))
        				   	sprint (buf, "%s.%03y%c", holdbink, zone, DIRSEP);
        				   else
						strcpy (buf, hold);
        				   buf = &buf[strlen(buf)];
        				   break;
        			case 'k' : /* %k = packet without path */
					   sprint(buf, "%02d%02d%02d%02d.PKT", d.da_day, t.ti_hour, t.ti_min, t.ti_sec);
        				   buf = &buf[strlen(buf)];
        				   break;
       				case '%' : *buf++ = *comline;
       					   break;
       				case ':' : *buf++ = ';';
       					   break;
        		}
        		if (*comline != '\0')
        			comline++;
        	}
	}
        *buf='\0';
	*cmd= strlen(cmd+1);

     result = execute(archiver,cmd);

     if (result) {
        message(6,"!Error: Packet not ARCed.");
        rename(newname,buffer);
     }
     else {
         /* succeeded or trap? Check for file */
         if ((fd = fopen(newname,"r")) != NULL) {
            fclose(fd);
            rename(newname,buffer);
            message(6,"!Error: Packet not ARCed.");
             /* continue; */
         }
     }
     return (result);
}

void ArcMail()
   /* This Routine searches the outbound dir for mail packets and
       arcs them if needed. Calls ArcOk(zone,net,node) to check
       if the packet should be arced */
{
    char buffer[80];
    int zone, net, node;
    char *p;
    int type;
    int num_pktnames;
    int i, archiv;
    static char name[5][4]={"arc","zip","zoo","lzh","arj"};
    
    sprint(buffer, "%s*.?M", hold);
    for (num_pktnames = 0, p = ffirstout(buffer); p != NULL; p = fnextout()) {
        if ((pktnames[num_pktnames++] = strdup(p)) == NULL) {
           message(6,"!Mem error");
           exit (1);
        }
    }

    for (i = 0; i < num_pktnames; free(pktnames[i++])) {
        getadress(pktnames[i],&zone,&net,&node);
        type = pktnames[i][strlen(pktnames[i])-2];
#if DEBUG
message(6," ArcMail: found mail (%c) to %d:%d/%d",type,zone,net,node);
#endif
        if ((archiv=ArcOk(zone,net,node)) != -1) {
            message (1, "+Node %d:%d/%d gets %smail",zone,net,node,name[archiv]);
            CallArc (archiv_prg[archiv],archiv_cmd[archiv],zone,net,node,type);
        }
     }
}
#else	/* !LINN */
void ArcMail()
{
    /* This Routine searches the outbound dir for mail packets and
       arcs them if needed. Calls ArcOk(zone,net,node) to check
       if the packet should be arced */

    char buffer[80];
    char newname[80];
    char arcname[80];
    char cmd[128];
    int zone, net, node;
    char *p;
    struct date d;
    struct time t;
    int type;
    int result;
    FILE *fd;
    int num_pktnames;
    int i;

    sprint(buffer, "%s*.?M", hold);
    for (num_pktnames = 0, p = ffirst(buffer); p != NULL; p = fnext()) {
        if ((pktnames[num_pktnames++] = strdup(p)) == NULL) {
           message(6,"!Mem error");
           exit (1);
        }
    }

    for (i = 0; i < num_pktnames; free(pktnames[i++])) {
        getadress(pktnames[i],&zone,&net,&node);
        type = pktnames[i][strlen(pktnames[i])-2];
#if DEBUG
message(6," ArcMail: found mail (%c) to %d:%d/%d",type,zone,net,node);
#endif
        if (ArcOk(zone,net,node)) {
           getdate(&d);
           gettime(&t);
           sprint(buffer,  "%s%02z%03z%03z.%cM",
                  hold, zone, net, node, type);
           sprint(newname, "%s%02d%02d%02d%02d.PKT", hold,
                  d.da_day, t.ti_hour, t.ti_min, t.ti_sec);
#if DEBUG
print("New packet-name: %s\n",newname);
#endif
           if (rename(buffer,newname)) {
              message(6,"!Fatal error renaming packet %s",buffer);
              exit(2);
           }

           /* Ok it has got a 'standard' name now, next step is finding
              an archive */
           sprint(arcname, "%s%02z%03z%03z.%cA",
                           hold, zone, net, node, type);

           /* Now call ARC! */
           /* ARC M B:\MAIL\00000001.NA B:\02010101.PKT             */
           sprint((cmd+1), "%s %s %s", arc_cmd, arcname, newname);
           *cmd= strlen(cmd+1);

#if DEBUG
print(">>%s %s<<",arc_prg,(cmd+1));
#endif
           result = execute(arc_prg,cmd);

#if DEBUG
print("Arc result: %d\n",result);
#endif
           if (result) {
              message(6,"!Error: Packet not ARCed.");
              rename(newname,buffer);
           }
           else {
              /* succeeded or trap? Check for file */
              if ((fd = fopen(newname,"r")) != NULL) {
                 fclose(fd);
                 rename(newname,buffer);
                 message(6,"!Error: Packet not ARCed.");
                 continue;
              }
           }     /*arc succeeded*/
        }
     }
}
#endif /* LINN */

void ReDirect()
{
    int zone, net, node;
    int dzone, dnet, dnode;
    char buffer[80];
    char *p;
    FILE *fd;
    int ch, type;
    int i, num_pktnames;

    sprint(buffer, "%s*.?M", hold);
    for (num_pktnames = 0, p = ffirstout(buffer); p != NULL; p = fnextout()) {
        if ((pktnames[num_pktnames++] = strdup(p)) == NULL) {
           message(6,"!Mem error");
           exit (1);
        }
    }

    for (i = 0; i < num_pktnames; free(pktnames[i++])) {
        getadress(pktnames[i],&zone,&net,&node);
        type = pktnames[i][strlen(pktnames[i])-2];
#if DEBUG
message(6," Redirect: found mail (%c) to %d:%d/%d",type,zone,net,node);
#endif
        dzone = zone;
        dnet  = net;
        dnode = node;
        ReDirectTo(&zone, &net, &node, dzone, dnet, dnode, type == 'C');
        if (zone != dzone || net != dnet || node != dnode) {
#if DEBUG
message(6," ReDirect: should sent to %d:%d/%d", zone,net,node);
#endif
#ifdef LINN
	if (binkley)
    		if (zone==alias[0].zone)
			sprint(buffer, "%s%03z%03z00.%cPT", hold, net, node, binktype((char)type));
		else	sprint(buffer, "%s.%03y%c%03z%03z00.%cPT", holdbink, zone, DIRSEP, net, node, binktype((char)type));
	else
		sprint(buffer, "%s%02z%03z%03z.%cM", hold, zone, net, node, type);
#else
            sprint(buffer,  "%s%02z%03z%03z.%cM",
                   hold, zone, net, node, type);
#endif
            OpenPacket(0,zone,net,node,type);

            /* We've a new packet open (to real destination) */
            fd = fopen(buffer,BRUP);
            if (fd == NULL) {
               message(6,"!Can't open %s",buffer);
               exit(1);
            }
            fseek(fd, (long) sizeof(struct _pkthdr), SEEK_SET);

            /* start copying data now */
            while ((ch = getc(fd)) != EOF) putc(ch,pktfile[0]);
            fclose(fd);

            /* Get to the correct position for EOF markers */
            fseek(pktfile[0],-2L,SEEK_END);
            ClosePacket(0);

            /* Now the data is copied we can get rid of the original */
            if (unlink(buffer)) {
               message(6,"!Can't delete %s",buffer);
               exit(1);
            }
        }
    }
}

void Hold()
{
    int zone, net, node;
    char buffer[80];
    char buffer1[80];
    char *p;
    int type;
    int num_pktnames;
    int i;

    sprint(buffer, "%s*.N?", hold);
    for (num_pktnames = 0, p = ffirstout(buffer); p != NULL; p = fnextout()) {
        if ((pktnames[num_pktnames++] = strdup(p)) == NULL) {
           message(6,"!Mem error");
           exit (1);
        }
    }

    for (i = 0; i < num_pktnames; free(pktnames[i++])) {
        getadress(pktnames[i],&zone,&net,&node);
        type = pktnames[i][strlen(pktnames[i])-1];
#if DEBUG
message(6," Hold: found (%c) to %d:%d/%d",type,zone,net,node);
#endif

        if (HoldOk(zone,net,node)) {
#if DEBUG
message(6," Hold: should hold for %d:%d/%d", zone,net,node);
#endif

#ifdef LINN
	if (binkley)
    		if (zone==alias[0].zone) {
			sprint(buffer, "%s%03z%03z00.O%cT", hold, net, node, (type=='M') ? 'P' : type);
			sprint(buffer1, "%s%03z%03z00.H%cT", hold, net, node, (type=='M') ? 'P' : type);
		} else {
			sprint(buffer, "%s.%03y%c%03z%03z00.O%cT", holdbink, zone, DIRSEP, net, node, (type=='M') ? 'P' : type);
			sprint(buffer1, "%s.%03y%c%03z%03z00.H%cT", holdbink, zone, DIRSEP, net, node, (type=='M') ? 'P' : type);
		}
	else {
	        sprint(buffer, "%s%02z%03z%03z.N%c", hold, zone, net, node, type);
		sprint(buffer1,"%s%02z%03z%03z.W%c", hold, zone, net, node, type);
	}
#else
           sprint(buffer, "%s%02z%03z%03z.N%c",
                          hold, zone, net, node, type);
           sprint(buffer1,"%s%02z%03z%03z.W%c",
                          hold, zone, net, node, type);
#endif
           if (rename(buffer,buffer1)) {
              message(6,"!Can't rename %s to %s",buffer,buffer1);
              exit(1);
           }
        }
    }
}

void UnHold()
{
    int zone, net, node;
    char buffer[80];
    char buffer1[80];
    char *p;
    int type;
    int num_pktnames;
    int i;

    sprint(buffer, "%s*.W?", hold);
    for (num_pktnames = 0, p = ffirstout(buffer); p != NULL; p = fnextout()) {
        if ((pktnames[num_pktnames++] = strdup(p)) == NULL) {
           message(6,"!Mem error");
           exit (1);
        }
    }

    for (i = 0; i < num_pktnames; free(pktnames[i++])) {
        getadress(pktnames[i],&zone,&net,&node);
        type = pktnames[i][strlen(pktnames[i])-1];
#if DEBUG
message(6," UnHold: found (%c) to %d:%d/%d",type,zone,net,node);
#endif

        if (type != 'F') {
#if DEBUG
message(6," UnHold: should unhold for %d:%d/%d", zone,net,node);
#endif
#ifdef LINN
	   if (binkley)
    		if (zone==alias[0].zone) {
			sprint(buffer, "%s%03z%03z00.H%cT", hold, net, node, (type=='M') ? 'P' : type);
			sprint(buffer1, "%s%03z%03z00.O%cT", hold, net, node, (type=='M') ? 'P' : type);
		} else {
			sprint(buffer, "%s.%03y%c%03z%03z00.H%cT", holdbink, zone, DIRSEP, net, node, (type=='M') ? 'P' : type);
			sprint(buffer1, "%s.%03y%c%03z%03z00.O%cT", holdbink, zone, DIRSEP, net, node, (type=='M') ? 'P' : type);
		}
	   else {
	        sprint(buffer, "%s%02z%03z%03z.W%c", hold, zone, net, node, type);
		sprint(buffer1,"%s%02z%03z%03z.N%c", hold, zone, net, node, type);
	   }
#else
           sprint(buffer,  "%s%02z%03z%03z.W%c",
                           hold, zone, net, node, type);
           sprint(buffer1, "%s%02z%03z%03z.N%c",
                           hold, zone, net, node, type);
#endif
           if (rename(buffer,buffer1)) {
              message(6,"!Can't rename %s to %s",buffer,buffer1);
              exit(1);
           }
        }
    }
}


void MakePoll()
{
        int i=-1;
        char *p, *q;
        int zone, net, node;
        FILE *fd;
        char name[80];

        while ((p = PollNode(&i)) != NULL)
        {
                if ((q = strchr(p,'.')) != NULL)
                {
                        zone= alias[0].zone;
                        net = alias[0].pointnet;
                        node= atoi(q+1);
                        if (node==0)
                        {
                                message(6,"-Invalid point (%s) in POLL",p);
                                continue;
                        }
                }
                else
                {
                    if (sscanf(p,"%d:%d/%d",&zone,&net,&node)!=3)
                    {
                        zone= alias[0].zone;
                        if (sscanf(p,"%d/%d",&net,&node)!=2)
                        {
                            net= alias[0].net;
                            node= atoi(p);
                            if (node==0)
                            {
                                message(6,"-Invalid node (%s) in POLL",p);
                                continue;
                            }
                        }
                    }
                }
#ifdef LINN
		if (binkley)
			if (zone==alias[0].zone)
				sprint(name, "%s%03z%03z00.OFT", hold, net, node);
			else	sprint(name, "%s.%03y%c%03z%03z00.OFT", holdbink, zone, DIRSEP, net, node);
		else	sprint(name,"%s%02z%03z%03z.PF",hold,zone,net,node);
#else
                sprint(name,"%s%02z%03z%03z.PF",hold,zone,net,node);
#endif
                fd= fopen(name,"a");
                if (fd==NULL)
                {
                    message(6,"!Could not create file %s",name);
                    exit(1);
                }
                fclose(fd);
        }
}

void DeInit()
{
        /* Don't know what to do here, but this way main is nice symetrical */
}

#if STTC
char *environ;

void main(argc, argv, envir)
int argc;
char *argv[], *envir;
#else
void main(argc, argv)
int argc;
char *argv[];
#endif
{
        int result, nrmsgs;
        int zone, net, node, type;

#if STTC
    environ= envir;
#endif

        /* Tell them who we are */
        fprintf(stderr,
         "BERMUDA : FidoNet compatible message processing software\n");
        fprintf(stderr,
         "PACK utility ; Version %s created %s at %s\n\n",UVERSION,
         __DATE__,__TIME__);
        fflush(stderr);

        /* Init first, parses commandline and configuration */
        Init(argc,argv);
        parse_route();
        nrmsgs=0;

        message(0,"+Unhold packets");
        /* Check for HOLD packets */
        UnHold();

        /* Open mail-area next */
        OpenMail();

        /* Init all packets (none open) */
        InitPackets();

        /* for all messages do
           begin
             read message;
             find destination;
             pack to destination;
           end;
         */
        message(2,"+Pack messages");
        while ((result=ReadMessage())!=-1)
        {
                if (result)
                {
                        Destination(&zone,&net,&node,&type);
                        PackTo(zone,net,node,type);
                        SaveMessage();
                        nrmsgs++;
                }
        }

        /* DeInit packets (some might be open) */
        DeInitPackets();

        /* Get rid of the mail area */
        CloseMail();

        message(0,"+Redirect packets");
        /* If there are any redirections, do them now */
        ReDirect();

        message(0,"+Arc mail");
        /* Arc all mail found in the outbound directory */
        ArcMail();

        message(0,"+Hold mail");
        Hold();

        /* Anyone in for polling? */
        message(0,"+Prepare poll");
        MakePoll();

        /* DeInit program */
        DeInit();

        /* Tell them what we did */
        message(2,"+Processed %d messages",nrmsgs);

}

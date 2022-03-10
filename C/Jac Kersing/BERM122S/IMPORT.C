/***************************************************************************
 *  IMPORT.C                                                               *
 *                                                                         *
 *  import utility.                                                        *
 *                                                                         *
 * This program IMPORTs FidoNet<tm> mailpackets and TOSSes mail and        *
 * echomail.                                                               *
 *                                                                         *
 * IMPORT is part of the BERMUDA software. BERMUDA is a package of FidoNet *
 * compatible message/nodelist processing software.                        *
 * Please read LICENSE for information about distribution.                 *
 *                                                                         *
 * Written by Jac Kersing,                                                 *
 * Modifications by Enno Borgsteede and Rinaldo Visscher                   *
 * Modifications by Vincent Pomey and Franck Arnaud                        *
 ***************************************************************************/

#define MAILER              /* needed in PANDORA.H */
#define DEBUG   0           /* Debugging mode (extended info) on/off */
#define DEBUG_SORT      0   /* Debugging info in sort routine? */

#include "pandora.h"        /* for structure of the area's etc. */
#include "mail.h"           /* pretty obvious if your unpacking mail.. */

#include <stdlib.h>

#if TC
#include <dos.h>
#include <sys\stat.h>
#endif

#define __PROTO__ 1
#include "import.pro"
#include "utextra.pro"


#define UVERSION "1.22"     /* version-number */
#define LASTMOD  __DATE__

#define isBERMUDA 0xA0          /* productcode for Bermuda */

#define MSGSCANNED      0x8000

/* defines for writemessage         */
#define OUTBOUND    0       /* message to mailarea      */
#define LOCAL       1       /* message to local msgfile */
#define SCANFILE    2       /* message to node file     */

/* defines for SEEN-BY treatement   */
#define NOTHING     0       /* no echomail message         */
#define POINTS      1       /* add pointlist to message    */
#define LOCALS      2       /* add local list to msg       */
#define DIFFZONE    4       /* add list for OTHER zone     */
#define OTHERS      8       /* add all nodes already there */

struct _passw           /* structure for passwords */
{
  char passw[8];        /* the password itself */
  unsigned zone;        /* zone number for remote */
  unsigned net;         /* net number for remote */
  unsigned node;        /* node number for remote */
  unsigned point;       /* point number for remote */
  int  my_aka;          /* the number in the addresslist for this sucker */
  struct _passw *next;  /* pointer to next struct */
} ;

struct _aka
{
 unsigned zone;
 unsigned net;
 unsigned node;
 unsigned point;
 unsigned pointnet;
} ;

#undef  NORMAL

void Aopen(), Aclose(), cleanEcho(), renumber();

char progname[]="B-I";      /* program name for logging */
FILE *pkt;                  /* the mailpacket */
char *Bpath="";             /* path for mailer info */

char packet[80];            /* name of the packet we're dealing with now */
struct _pkthdr phdr;        /* storage for packetheader */
struct _pktmsgs mhdr;       /* header of current message */
struct Hdr hhdr;            /* header for message (in hdr file) */
struct Hdr Mhdr;            /* storage for outgoing message header  */

char arc_prg[90];           /* archive program name */
char arc_cmd[90];           /* commands for archive program */
#ifdef LINN
char zip_prg[90];
char zip_cmd[90];
char zoo_prg[90];
char zoo_cmd[90];
char lzh_prg[90];
char lzh_cmd[90];
char arj_prg[90];
char arj_cmd[90];
char def_prg[90];           /* default archiver */
char def_cmd[90];
#endif
int  akeep=0;               /* keep extracted archives? */
char *ms;                   /* pointer in message buffer */

int  lastarea;              /* area last message was stored */
char *AreaPath[N_AREAS];    /* path to message area                 */
char *AreaName[N_AREAS];    /* name of area                         */
char *AreaOrig[N_AREAS];    /* the origin line for this area        */
int  AreaDays[N_AREAS];     /* number of days this area lasts       */
unsigned *ToZone[N_AREAS];  /* Zone, Net,                           */
unsigned *ToNet[N_AREAS];   /*            Node and Point            */
unsigned *ToNode[N_AREAS];  /*    numbers of nodes we're supposed   */
unsigned *ToPoint[N_AREAS]; /*    to echo messages to..........     */
int  nmsgs[N_AREAS];        /* number of messages tossed to this area */
int  smsgs[N_AREAS];        /* number of messages to sysop in this area */
#ifdef LINN
int  emsgs[N_AREAS];        /* number of messages echoed in this area */
#endif
int  SendTo[51];            /* Send to this node too?               */
unsigned TZone[51];         /* Temp. storage for addresses          */
unsigned TNet[51];          /* Zone and Net..                       */
unsigned TNode[51];         /*               Node                   */
unsigned TPoint[51];        /*                      Point           */

unsigned SeenZone[950];     /* Zone...                              */
unsigned SeenNet[950];      /* adress of nodes that have seen       */
unsigned SeenNode[950];     /*                         this message */
unsigned SeenPoint[950];    /*                               Point  */
int  nSeen;                 /* number of Seen-bys                   */
unsigned PathZone[200];     /* Zone of path..                       */
unsigned PathNet[200];      /* adresses listed in the               */
unsigned PathNode[200];     /*                        path line     */
unsigned PathPoint[200];    /* Ditto                                */
int  nPath;                 /* number of nodes in Path              */
char ThisArea[80];          /* name of this echomail area           */

int  mailarea;              /* number of mailarea                   */
int  badarea;               /* number of area for badmessages       */
int  msgareas;              /* number of messageareas               */
char *hold;                 /* path to hold area                    */
#ifdef LINN
char *holdbink;
#endif
char *mailpath;             /* path to mailmsgs                     */
char *netpath;              /* path to netmail                      */
struct _aka alias[30];      /* aliases                              */
int  nalias;                /* number of aliases                    */
#ifdef LINN
int  binkley=0;
int  add_aka=0;             /* number of aliases to add to seen-bys */
int  no_intl=0;
#else
int  add_aka;               /* number of aliases to add to seen-bys */
#endif
int  verbose=0;             /* level for message displaying         */
int  loglevel;              /* level for message logging            */
#ifdef LINN
int  killrouted;            /* set flag Kill/Sent for routed msg    */
#endif
char *logname;              /* name of logfile                      */
FILE *log;                  /* filepointer for logfile              */
struct _passw *pwd;         /* password pointer                     */

char sysop[80];             /* name of sysop */
char *ourorigin;            /* line for origin                      */
unsigned ourzone;           /* zone,                                */
unsigned ournet;            /*      net and                         */
unsigned ournode;           /*              node of our BBS         */
unsigned ourpoint;          /*                 point                */
unsigned ourpointnet;       /* we've got a pointnet too             */
char ourpwd[10];            /* the password we're using now         */

char *MESSAGE;              /* adress of message buffer (malloced)  */
char *mend;                 /* points to end of the message         */
char *endbody;              /* end of message body WITHOUT seen-bys */
int  mlength;               /* length of message (including seen-by)*/
int  area;                  /* area we're processing                */
int  echomsgs=0;            /* number of messages generated         */
char *origl;                /* points to origin line in message     */

int  ask=0;                 /* ask for a packetname? */
int  arcmail=0;             /* unpacking arcmail? */
int  use_path;              /* do we wanna use the PATH line?       */
int  use_kludge;            /* we want to use the IFNA kludge?      */
int  use_origin;            /* do we wanna have an origin line??    */
int  use_readdress;         /* readress message (fake from our bbs) */
int  use_packet;            /* scan messages to packets             */
int  use_tiny=0;            /* tiny adresses (ones I'm sending to)  */
int  secure=0;              /* only import mail from known sources  */

FILE *MHDR;
FILE *MMSG;
FILE *hdr;                  /* file with message headers */
FILE *msg;                  /* file with message text */

char oldmsg[80];            /* names of the message and header files */
char oldhdr[80];

int  j;                     /* stupid counter                       */
int  x;                     /* x position in line                   */

unsigned pktzone[10];       /* zone, net, node and point            */
unsigned pktnet[10];        /* = address for open packet            */
unsigned pktnode[10];       /* used for saving messages to          */
unsigned pktpoint[10];
unsigned pktfake[10];
unsigned fromzone;          /* address this packet was packed       */
unsigned fromnet;
unsigned fromnode;
unsigned frompoint;
FILE *pktfile[10];          /* the packet                           */

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
    
    if (sp==0) sp=1;
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
    char *q;                        /* another one */
#endif
    int count;                      /* just a counter... */
    char *ffirst();                 /* directory find */
    char *getenv();                 /* get the environment string */

    p=getenv("MAILER");
    if (!ffirst("bermuda.cfg") &&      /* check local config */
        !ffirst("tb.cfg") &&
        p!=NULL && *p!='\0')
    {                                   /* no local, and envi contained one */
        Bpath= ctl_path(p);
    }

    sprintf( buffer, "%sbermuda.cfg", Bpath);
    conf= fopen(buffer, "r");

    if (conf==NULL)
    {
        sprintf(buffer,"%stb.cfg", Bpath);

        conf = fopen(buffer, "r");
    }


    if (verbose > 2) printf("Config: %s\n",buffer);

    if (conf==NULL)
    {
        message(6,"!Configuration file not found, please check!!!");
        return 1;                           /* not found, back */
    }

    /* set all to default values */
    
    loglevel=255;
    ourzone=ournet=ournode=ourpoint=0;
#ifdef LINN
    killrouted=1;
#endif
    
    message(-1,"+Parsing configuration file");
       
    while((fgets(buffer, 250, conf)))       /* read a line */
    {
        if (verbose > 2) printf("Config: %s\n",buffer);

        p=skip_blanks(buffer);
        if (*p==';') continue;               /* comment?? */

        /* delete ALL chars following (and inclusive) comment sign */
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
        		strcpy(buffer,p);
        	}
        }
#endif

        if (!strnicmp(buffer,"sysop",5))
        {
                p=skip_blanks(&buffer[5]);
                strncpy(sysop,p,79);
                sysop[79]='\0';
                continue;
        }

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

            if (*p && isdigit(*p))            {
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
	if (!strnicmp(buffer,"nokillrouted",12))
	{
	    killrouted = 0;
	    continue;
	}

	if (!strnicmp(buffer,"arcunpack", 9))
	{
	    p=skip_blanks(&buffer[9]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (arc_prg, p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (arc_cmd, p);
	    continue;
	}

	if (!strnicmp(buffer,"zipunpack", 9))
	{
	    p=skip_blanks(&buffer[9]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (zip_prg, p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (zip_cmd, p);
	    continue;
	}

	if (!strnicmp(buffer,"zoounpack", 9))
	{
	    p=skip_blanks(&buffer[9]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (zoo_prg, p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (zoo_cmd, p);
	    continue;
	}

	if (!strnicmp(buffer,"lzhunpack", 9))
	{
	    p=skip_blanks(&buffer[9]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (lzh_prg, p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (lzh_cmd, p);
	    continue;
	}

	if (!strnicmp(buffer,"arjunpack", 9))
	{
	    p=skip_blanks(&buffer[9]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (arj_prg, p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (arj_cmd, p);
	    continue;
	}

	if (!strnicmp(buffer,"defaultunpack", 13))
	{
	    p=skip_blanks(&buffer[13]);
    	    q=p;
            while (*q && !isspace(*q)) ++q;
            *q='\0';
	    strcpy (def_prg, p);
            p=skip_blanks(&p[strlen(p)+1]);	/* skip to next word */
            strcpy (def_cmd, p);
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
    unsigned zone,net,node,point;
    int my_aka=0;
    
    /* get to the end of the list. */
    pw=pwd;

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
unsigned *i;
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
unsigned *zone, *net, *node, *point;
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
            *zone=*net=*node=65535U;
            return 10;
        }
        if (!*str) return (retcode);
        if (*str=='.') goto pnt;
        retcode++;
        if (*str==':') {
           str++;
           *zone=*node;
           *node=65535U;
           if (!*str) return (0);
           if (getint(&str,node))
           {
              if (strnicmp(str,"ALL",3)) return (0);
              *net=*node=65535U;
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
            *node=65535U;
            return 10;
        }
        if (*str=='.') goto pnt;
        return (retcode);
pnt:    str++;
        if (getint(&str,point))
        {
            if (strnicmp(str,"ALL",3)) return (0);
            *point=65535U;
            return 10;
        }
        return (4+retcode);
}

int getalias(zone,net,node,point)
unsigned zone,net,node,point;
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
        if ((pw->zone==65535U || pw->zone==zone) &&
       /* zone numbers match, now net */
           (pw->net==65535U || pw->net==net) &&
       /* zone and net match.. node also? */
           (pw->node==65535U || pw->node==node) &&
       /* and how about point */
           (pw->point==65535U || pw->point==point))
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
unsigned zone,net,node,point;
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
    	/* vp 27 juil 93 : no wildcards for passwords */
       /* no match at all.. (yet) */
        if ((/*pw->zone==65535U ||*/ pw->zone==zone) &&
       /* zone numbers match, now net */
           (/*pw->net==65535U ||*/ pw->net==net) &&
       /* zone and net match.. node also? */
           (/*pw->node==65535U ||*/ pw->node==node) &&
       /* and how about point */
           (/*pw->point==65535U ||*/ pw->point==point))
        {
                strcpy(ourpwd,pw->passw);
                return;
        }
        pw=pw->next;
    }
    *ourpwd= '\0';
}

void init(argc, argv)            /* initialize everything needed */
int argc;                   /* counter */
char *argv[];               /* commandline crap */
{
    int i,j;                /* counter */
    char *p, *q;            /* nice pointers.. */
    char buffer[300];       /* to store lines from AREAS.BBS etc. in */
    char temp[80];          /* temp. storage */
    char areasbbs[80];      /* name of file for AREAS.BBS */
    int  the_box=0;         /* flags to signal call from The-Box */
    FILE *fd;               /* file descriptor for control and areas.bbs */
#ifndef LINN
    long atol();
#endif
    
    strcpy(areasbbs, "areas.bbs");  /* default name */
#ifdef LINN
    /* set all archiver to nothing, except default archiver to ARC */
    /* arc.ttp should be actually whatarc.ttp */
    lzh_prg[0] = '\0';
    arj_prg[0] = '\0';
    zoo_prg[0] = '\0';
    zip_prg[0] = '\0';
    arc_prg[0] = '\0';
#if     STTC
    strcpy(def_prg,"ARC.TTP");
#endif
#if     TC
    strcpy(def_prg,"ARC.EXE");
#endif
    strcpy (def_cmd, "X");
#else
#if     STTC
    strcpy(arc_prg,"ARC.TTP");
#endif
#if     TC
    strcpy(arc_prg,"ARC.EXE");
#endif
    strcpy(arc_cmd,"X");
#endif
    strcpy(areasbbs, "areas.bbs");  /* default name */

    pwd= (struct _passw *) myalloc(sizeof(struct _passw));
    pwd->zone=pwd->net=pwd->node=pwd->point=0;
    pwd->next=NULL;

    if (init_conf()) exit(2);       /* first parse config file */
    
    use_path=use_origin=use_readdress=1;
    use_kludge=0;

    for (i=1;i<argc;i++)
    {
        ++argv;

        if (argv[0][0]=='-')
        {
            switch(toupper(argv[0][1]))
            {
              case 'S': ask=1; break;     /* ask for packetnames     */
              case 'R': secure++; break;  /* secure system  */
              case 'K': ++akeep;   break; /* keep extracted archives */
              case 'P': use_packet=1; break; /* output to packet */
              case 'I': use_kludge=1; break; /* ifna kludge */
              case 'V': verbose++;    break; /* more detail */
              case 'G': use_path=0;   break; /* no path line */
              case 'T': ++the_box;    break; /* called with logging */
#ifdef LINN
              case 'D': add_aka = nalias; break;
              case 'N': no_intl = 1;
	     /* -A set the default archiver, since arc_??? now means
                only the ARC program */
              case 'A': *def_cmd= *def_prg= '\0';
                        if (i+1<argc)
                        {
                            strncpy(def_prg,argv[1],89);
                            while (++i<argc-1 &&
                              (strlen(def_cmd)+strlen(argv[1]))<88)
                            {
                                strcat(def_cmd,(++argv)[1]);
                                strcat(def_cmd," ");
                            }
                        }
                        break;
#else
              case 'A': *arc_cmd= *arc_prg= '\0';
                        if (i+1<argc)
                        {
                            strncpy(arc_prg,argv[1],89);
                            while (++i<argc-1 &&
                              (strlen(arc_cmd)+strlen(argv[1]))<88)
                            {
                                strcat(arc_cmd,(++argv)[1]);
                                strcat(arc_cmd," ");
                            }
                        }
                        break;
#endif
              default : message(6,"!Unknown option %s",argv[0]);
            }
        }
        else strcpy(areasbbs,argv[0]);
    }

    badarea= mailarea= -1;
    msgareas=0;

    sprintf(buffer,"%s%s", Bpath, areasbbs);
    if((fd=fopen(buffer, "r"))==NULL)
    {
        message(0,"=%s not found, assuming simple set-up",buffer);
    }
    else
    {
            /* get the MAIN origin line */
        do
            fgets(buffer,299,fd);
        while (buffer[0]=='-' || buffer[0]==';') ;

        q=buffer+strlen(buffer)-1;
        while (isspace(*q) || !*q) *q--=0;  /* get rid of trailing blanks   */
        ourorigin=ctl_string(buffer);

        while (fgets(buffer,299,fd))        /* next line                    */
        {
            q=skip_blanks(buffer);
            if (!*q || *q==';') continue;               /* comment line? */
            if (strlen(q)<5) continue;
            if (*q=='-')
            {
                    switch (toupper(*(q+1)))
                    {
                     case 'O': q=skip_to_blank(q);
                               q=skip_blanks(q);
                               p= q+strlen(q)-1;
                               while (isspace(*p) || !*p) *p--=0;
                               AreaOrig[msgareas]=ctl_string(q);
                               break;
                    }
                    continue;
            }
            for (p=temp; *q && !isspace(*q); *p++=*q++) ;
            *p=0;
            AreaPath[msgareas]=ctl_string(temp);        /* copy path to area */
            while (isspace(*q)) q++;
            for (p=temp; *q && !isspace(*q); *p++=*q++) ;
            *p=0;
            AreaName[msgareas]=ctl_string(temp);        /* copy name of area */
            while (*q && !isspace(*q)) q++;
            if (!stricmp(AreaName[msgareas],"MAIL"))
            {                                           /* is the mail area? */
                mailarea=msgareas;
                if (mailarea != -1) free(AreaName[mailarea]);
                AreaName[mailarea]=ctl_string("* Network");
            }
            if (!stricmp(AreaName[msgareas],"BADMSGS"))
            {
                badarea=msgareas;
                AreaName[badarea]=ctl_string("* BAD *");
            }

            i=1;                            /* No destinations (yet)        */

            do
            {                               /* get them all                 */
                q=skip_blanks(q);
                j= getaddress(q, &TZone[i], &TNet[i], &TNode[i], &TPoint[i]);
                if (j==0) break;
                if (j==10)
                {
                    message(6,"!Invalid address %s in area-file",q);
                    exit(2);
                }
                while (*q && !isspace(*q)) q++;
                i++;
            }
            while (*q);
            TZone[0]=TZone[1];
            TNet[0]=TNet[1];
            TNode[0]=TNode[1];
            TPoint[0]=TPoint[1];

            --i;
            SortThem(&TZone[1],&TNet[1],&TNode[1],&TPoint[1],&i,0);
            ++i;
            TZone[i]=TNet[i]=TNode[i]=TPoint[i]=0; /* and terminate         */
            ++i;

            /* only store them if we found some and if it's not the bad area */
            if (i>2 && msgareas != badarea)
            {
                ToZone[msgareas]= (unsigned *) myalloc(sizeof(unsigned) * i);
                ToNet[msgareas]= (unsigned *) myalloc(sizeof(unsigned) * i);
                ToNode[msgareas]= (unsigned *) myalloc(sizeof(unsigned) * i);
                ToPoint[msgareas]= (unsigned *) myalloc(sizeof(unsigned) * i);
                memmove(ToZone[msgareas],TZone,sizeof(unsigned) * i);
                memmove(ToNet[msgareas],TNet,sizeof(unsigned) * i);
                memmove(ToNode[msgareas],TNode,sizeof(unsigned) * i);
                memmove(ToPoint[msgareas],TPoint,sizeof(unsigned) * i);
            }

            if (verbose > 2)
            {
                print("%s %s",AreaPath[msgareas],AreaName[msgareas]);
                if (i>2 && msgareas!=badarea)
                    for(i=0;ToNet[msgareas][i];i++)
                      print(" %u/%u",ToNet[msgareas][i],
                       ToNode[msgareas][i]);
                print("\n");
            }

            if (AreaOrig[msgareas]==NULL) AreaOrig[msgareas]=ourorigin;

            ++msgareas;                     /* next area                    */
#ifdef LINN
	    if (msgareas==N_AREAS-2) {
	    	message(6,"!More than %d areas, areas.bbs read incomplete", N_AREAS);
	    	break;
	    }
#endif
        }
        fclose(fd);
    }

    if (mailarea==-1 && netpath)       /* if mailarea not defined in AREAS.BBS */
    {
        AreaName[msgareas]=ctl_string("* Network");
        AreaPath[msgareas]=ctl_string(netpath);
        mailarea=msgareas++;            /* then use the THE-BOX.CFG one */
    }

#ifdef LINN
    for(i=0;i<msgareas;i++)
        nmsgs[i]=smsgs[i]=emsgs[i]=0;
#endif
    
    if (mailarea==-1 || !AreaPath[mailarea] || !*AreaPath[mailarea])
    {
        message(6,"!Don't know the path to your mailarea..");
        exit(2);
    }

    if (badarea == -1)
    {
        /* area for bad messages has not been specified, make it same as mail */
        badarea = mailarea;
    }

    if ((MESSAGE=malloc(30*1024))==NULL)
    {
        message(6,"!Mem error");
        exit(-39);
    }

    if (!the_box) loglevel=255;     /* called from command-line, no logging */

    sprintf(buffer,"%s.MSG",AreaPath[mailarea]);
    if((MMSG=fopen(buffer, BRUP))==NULL) MMSG=fopen(buffer, BWUP);
    sprintf(buffer,"%s.HDR",AreaPath[mailarea]);
    if((MHDR=fopen(buffer, BRUP))==NULL) MHDR=fopen(buffer, BWUP);
    if (!MMSG || !MHDR)
    {
        message(6,"!Error opening Mail file");
        exit(1);
    }
    
    fseek(MHDR,0l,2);               /* seek to end of (new) mailfile    */
    fseek(MMSG,0l,2);               /* to add echomail there            */

    lastarea=-1;                    /* don't lose msgs in area 0 */

    if (verbose > 1)
    {
        print("Mail area (%d): %s\n",mailarea,AreaPath[mailarea]);
        print("Bad area (%d): %s\n",badarea,AreaPath[badarea]);
    }
}

#ifdef LINN
int extract(archive)
char *archive;
{
	FILE *amail;
	char name[80], buffer2[80];
	char *archiver, *comline, *buf;
	unsigned char c1, c2, c3, c4;
	int net;

 	sprintf (name, "%s%s", mailpath, archive);
	amail = fopen(name, "rb");
	
	if (amail == NULL) {
		return (1);
	}

	c1 = fgetc(amail);
	c2 = fgetc(amail);
	c3 = fgetc(amail);
	c4 = fgetc(amail);
	fclose (amail);

	archiver = NULL;
	comline = NULL;
	
	if ((c1 == 'P') && (c2 == 'K')) { /* zip mail */
		message(2, "+Received zipmail");
		archiver = zip_prg;
		comline = zip_cmd;
	}

	if (c1 == 0x1a) { /* arc mail */
		message(2, "+Received arcmail");
		archiver = arc_prg;
		comline = arc_cmd;
	}
	
	if ((c3 == '-') && (c4 == 'l')) { /* lzh mail */
		message(2, "+Received lzhmail");
		archiver = lzh_prg;
		comline = lzh_cmd;
	}

	if ((c1 == 'Z') && (c2 == 'O') && (c3 == 'O')) { /* zoo mail */
		message(2, "+Received zoomail");
		archiver = zoo_prg;
		comline = zoo_cmd;
	}

	if ((c1 == 0x60) && (c2 == 0xea)) { /* arj mail */
		message(2, "+Received arjmail");
		archiver = arj_prg;
		comline = arj_cmd;
	}

	if ((archiver == NULL) || (*archiver == '\0')) {
		/* unknown archive type or uninitialized xxx_prg */
		message(2, "+Received compressed mail");
		archiver = def_prg;
		comline = def_prg;
	}

        /* set up the command line for archiver */
	buf=buffer2+1;	/* copy to buffer2 the command line */
        while (*comline != '\0') {
        	if (*comline != '%')
        		*buf++ = *comline++;
        	else {
        		switch (*++comline) {
        			case 'd' : /* %d = directory */
					   strcpy (buf, mailpath);
        				   buf = &buf[strlen(buf)];
        				   break;
        			case 'n' : /* %n = archive name */
					   strcpy (buf, mailpath);
        				   strcat (buf, archive);
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
        *buffer2=strlen((buffer2+1));

        if (verbose > 2) print(" Exec: <%s> <%s>\n", archiver, buffer2);

        /* and execute it... */
        net=execute(archiver, buffer2);

        if (verbose > 2) print("Arc terminated with errorlevel %d\n",net);
        return (net);	
}
#endif

int process_arc()
{
    char buffer1[80], buffer2[140];
    char *found;
    char *ffirst(), *fnext();
    int  net, node;
    
    sprint(buffer1, "%s*.*", mailpath);

    found= ffirst(buffer1);
    if (!found) return 0;
    do
    {
        if ( is_arcmail(found,(int)strlen(found)-1) )
        {
            /* Found an arcmail packet right now! */
            sscanf( found, "%04x%04x", &net, &node);
         
#ifdef LINN
            net=extract(found);
#else
            message(3,"+Received arcmail");
            /* set up the command line for archiver */
            sprint((buffer2+1), "%s %s%s %s*.*", arc_cmd, mailpath,
                   found, mailpath);
            *buffer2=strlen((buffer2+1));

            if (verbose > 2) print(" Exec: <%s> <%s>\n", arc_prg, buffer2);

            /* and execute it... */
            net=execute(arc_prg, buffer2);

            if (verbose > 2) print("Arc terminated with errorlevel %d\n",net);
#endif

            if (!net)
            {
                sprint(buffer1, "%s%s", mailpath, found);
                if (akeep)
                {
                    sprint(buffer2, "%s%11.11s%c", mailpath, found,
                        *(found+11) + 'A');
                    if (rename(buffer1,buffer2))
                    {
                        message(6,"!Can not rename %s to %s",buffer1,
                                buffer2);
                        exit(2);
                    }
                }
                else
                {
                    if (unlink(buffer1))
                    {
                        message(6,"!Can not delete %s.",buffer1);
                        exit(2);
                    }
                }
                return 1;
            }
            else
            {
#ifdef LINN
                message(6,"!Fatal: Archiver error %d", net);
                sprint(buffer1,"%s%s",mailpath,found);
                sprint(buffer2, "%s%11.11s%c", mailpath, found,
                     found[11] + 'A' - '0');
                message(6,"!Packet renamed to %11.11s%c", found,
                     *(found+11) + 'A' - '0');
                if (rename(buffer1,buffer2))
                {
                    message(6,"!Can not rename %s to %s",buffer1,
                            buffer2);
                    exit(2);
                }
#else
                message(6,"!Fatal: ARChiver error");
#endif
                return 0; /* Archiver went wrong, abort else end-less loop */
            }
        }
        found=fnext();
    }
    while (found);
    return 0;
}

void mv_pkt()                           /* rename packet .pkt -> .bkt */
{
        char tmppkt[80];

        if (pkt!=NULL)
        {
                fclose(pkt);
                pkt=NULL;
        }
        strcpy(tmppkt,packet);
        strcpy(&tmppkt[strlen(packet)-3],"BKT");
        if (rename(packet,tmppkt))
        {
                message(6,"!Cannot rename %s to %s",packet,tmppkt);
                exit(2);
        }
        else message(6,"!Bad packet (%s > %s)",packet,tmppkt);
        *packet= '\0';
}

int open_pack()                 /* open mailpacket */
{
    char *p;                /* workhorse.. */
    char *ffirst();         /* find file with name */
    char temp[80];          /* temp. storage */

#ifdef LINN
    char type[10];          /* string for packet type */
#endif
    
    if (ask)                /* should ask for packet-name? */
    {
        print("Packet name: ");
        scanf("%79s",packet);
        if (!*packet) return 0;
    }
    else
    {
        sprint( temp, "%s*.PKT", mailpath);
        p=ffirst(temp);                       /* get the first packet */
        if (!p || !*p) return 0;              /* no packet found */
        sprint( packet, "%s%s", mailpath, p);
        message(2,"+Import %s",packet);
    }
    if ((pkt=fopen(packet, BREAD))==NULL)
    {
        message(6,"-Fatal: Can't open packet.");
        exit(1);    /* sysop gave wrong name, or it's a system error.. */
    }
    if (fread((char *)&phdr, sizeof(struct _pkthdr), 1, pkt)!=1)
    {
        message(6,"-Empty or too small, not a packet!");
        mv_pkt();
        return open_pack();
    }
    if (phdr.ph_ver!=inteli(0x2))              /* check packet type */
    {
        message(6,"-Not a packet or wrong version");
        mv_pkt();
        return open_pack();
    }
    
#ifdef LINN /* Modification to accept incoming 4D packets */
    if(phdr.ph_rate==inteli(0x2))
    { /* fsc-0045, type 2.2 */
        fromzone= inteli(phdr.ph_ozone);
        fromnet= inteli(phdr.ph_onet);
        fromnode= inteli(phdr.ph_onode);
        frompoint= inteli(phdr.ph_dy);
        strcpy(type,"2.2");
    }
    else
    {
        int cw,cwcheck; /* cap word */
        
        cw=inteli(phdr.ph_rsvd[3]);
        cwcheck=inteli(phdr.ph_rsvd[1]);
        /* invert cw validation copy, byte order indep */
        cwcheck=((cwcheck << 8) & 0xFF00) | ((cwcheck >> 8) & 0x00FF);
        if((cw==cwcheck) && (cw & 0x0001))
        { /* fsc-0039 & fsc-0048 */
            fromzone= inteli(phdr.ph_ozone);
            fromnet= inteli(phdr.ph_onet);
            fromnode= inteli(phdr.ph_onode);
            frompoint= inteli(phdr.ph_rsvd[6]);
            /* fsc-0048 */
            if((fromnet==0xFFFF) && (frompoint!=0))
                fromnet= inteli(phdr.ph_rsvd[0]);
            strcpy(type,"2+");
        }
        else
        { /* fsc-0001 */
            fromzone= inteli(phdr.ph_ozone);
            fromnet= inteli(phdr.ph_onet);
            fromnode= inteli(phdr.ph_onode);
            frompoint= 0;
            strcpy(type,"2");
        }
    }
    if (fromzone==0)
    	fromzone=alias[0].zone;		/* default zone number to alias[0] rather than zone of latest packet */
#else
    fromzone= inteli(phdr.ph_ozone);
    fromnet= inteli(phdr.ph_onet);
    fromnode= inteli(phdr.ph_onode);
    frompoint= 0;
#endif
    
    get_passw(fromzone, fromnet, fromnode, frompoint);
    if (secure>1 && strncmp(ourpwd,phdr.ph_pwd,6))
    {
        message(6,"-PASSWORD ERROR");
        mv_pkt();
        return open_pack();
    }
  
#ifdef LINN
    message(2,"+Packet type %s from %u:%u/%u.%u",type,
                fromzone,fromnet,fromnode,frompoint);
#else
    message(2,"+Packet from %u:%u/%u",inteli(phdr.ph_ozone),
                inteli(phdr.ph_onet), inteli(phdr.ph_onode));
#endif

    if (verbose) message(1,"+Assembled: %d-%d-%d  %d:%02d:%02d", inteli(phdr.ph_dy), inteli(phdr.ph_mo)+1,
           inteli(phdr.ph_yr), inteli(phdr.ph_hr), inteli(phdr.ph_mn), inteli(phdr.ph_sc));

#ifndef LINN
    if (phdr.ph_rate && verbose) message(1,"+Baudrate: %d",inteli(phdr.ph_rate));
#endif

    return 1;
}

static int openarea;

void open_area(area)                         /* open a certain message-area */
int area;                               /* number of area to open */
{
    char name[80];                      /* areaname */

    openarea= area;
    if (area==mailarea)
    {
        msg= MMSG;
        hdr= MHDR;
        return;
    }

    sprint( name, "%s.MSG", AreaPath[area]);
    if ((msg=fopen(name, BRUP))==NULL) msg=fopen(name, BWUP);
    sprint( name, "%s.HDR", AreaPath[area]);
    if ((hdr=fopen(name, BRUP))==NULL) hdr=fopen(name, BWUP);
    if (!msg || !hdr)                   /* not open? */
    {
        message(6,"-Error opening file(s) for area: %s",AreaPath[area]);
        exit(1);
    }
    fseek(hdr,0l,2);                    /* to end of files */
    fseek(msg,0l,2);
}

void close_area()                            /* close message area */
{
    if (openarea==mailarea) return;

    fclose(hdr);
    fclose(msg);
}

int read_hdr()                          /* read header of next message */
{
    char i,j;                           /* temp. storage */
    
    while (1)
    {
        i=getc(pkt);                    /* get the first 2 byte of new msg */
        j=getc(pkt);

        if (i==j)
        {
            /* this should be the end, but some utils **** up, so better
             * check it!
             */
            i = getc(pkt);
            if (feof(pkt) || i == 0x1a) return 0;    /* end of package */

            /* somehow there's still some data left. Process it! */
            ungetc(i,pkt);
            continue;
        }

        if (i!=2 || j!=0)               /* check message type */
        {
            /* there we go again, a bad message in this packet, let's resync! */
            message(1,"-garbage in '%s' at position %ld",packet,ftell(pkt));

            /* resync: */
            while (!feof(pkt))
            {
                if ((i=getc(pkt))== 0x02)
                {
                    /* found possible start of message! Test next byte */
                    if ((j=getc(pkt)) == 0x00) goto doit;
                    else ungetc(j,pkt);
                }
            }

            /* save packet for closer examination by hand */
            mv_pkt();
            return 0;
        }

doit:
        if (fread(((char *)&mhdr)+2, (sizeof(struct _pktmsgs) -2), 1, pkt)!=1)
        {                                /* read error? */
            message(6,"-Unexpected end of package!");
            return 0;
        }
        return 1;                       /* all ok */
    }
}

void conv_hdr()
{
    char temp[200];                     /* temp. buffer */
    char *p;                            /* pointer in buffer */
    char ch;                            /* character from packet */
    long time();                        /* current time */

    /* Date routine modified once again. It's still giving LOTS of trouble.. */
    /* Drop me a message if you've found a bomb free way to read it!         */
    ch = -1;
    for (p=temp; p<temp+20 && !feof(pkt) && ch;)
    {
        ch=getc(pkt);
        *p++=ch;
    }

    while (p++ < temp+20 && (ch=getc(pkt))=='\0') ;
    if (ch) ungetc(ch,pkt);

    strncpy(hhdr.time,temp,20);
    hhdr.time[19]='\0';

    ch=-1;
    for(p=temp; ch && p<temp+200 && !feof(pkt);)           /* to */
    {
        ch=getc(pkt);
        *p++=ch;
    }
    strncpy(hhdr.to,temp,36);
    hhdr.to[35]='\0';
    ch=-1;
    for(p=temp; ch && p<temp+200 && !feof(pkt);)     /* from */
    {
        ch=getc(pkt);
        *p++=ch;
    }
    strncpy(hhdr.from,temp,36);
    hhdr.from[35]='\0';
    ch=-1;
    for(p=temp; ch && p<temp+200 && !feof(pkt);)     /* topic */
    {
        ch=getc(pkt);
        *p++=ch;
    }
    strncpy(hhdr.topic,temp,72);
    hhdr.topic[71]='\0';
    hhdr.create=time(NULL);             /* created at receive date */
    hhdr.up=hhdr.parent=0;              /* no connection to other messages */
    hhdr.flags=inteli(mhdr.pm_attr) & ~(KILLSEND|MSGLOCAL|MSGFWD|SENT|ORPHAN|DELETED);
    hhdr.cost=inteli(mhdr.pm_cost);
    hhdr.reads=0;
    hhdr.Ozone=hhdr.Dzone= (fromzone != 0) ? fromzone : ourzone;
    hhdr.Dpoint=hhdr.Opoint=0;          /* not known yet */
    hhdr.Onet=inteli(mhdr.pm_onet);
    hhdr.Onode=inteli(mhdr.pm_onode);
    hhdr.Dnet=inteli(mhdr.pm_dnet);
    hhdr.Dnode=inteli(mhdr.pm_dnode);
    for (ch=0; ch<8; ch++) hhdr.mailer[ch]=0;
    for (ch=0; ch<nalias; ch++)
    {   /* It's one of our points? (Onet ok && pkthdr ok??) */
        if (hhdr.Onet==alias[ch].pointnet && alias[ch].point==0 &&
            inteli(phdr.ph_onet)==alias[ch].pointnet)
        {
            /* Gee, one of our points! */
            hhdr.Onet=alias[ch].net;
            hhdr.Opoint=hhdr.Onode;
            hhdr.Onode=alias[ch].node;

            /* And get out of the loop */
            break;
        }
    }
}

int ourmessage()                        /* message for this node? */
{
    int i;                              /* silly counter */
    
    for (i=0;i<nalias;i++)
    {
       if (alias[i].point && alias[i].pointnet==hhdr.Dnet &&
           alias[i].point==hhdr.Dnode && alias[i].zone==hhdr.Dzone) return 1;
       if (hhdr.Dzone==alias[i].zone && alias[i].net==hhdr.Dnet &&
           alias[i].node==hhdr.Dnode && alias[i].point==hhdr.Dpoint) return 1;
#ifdef LINN
       /* if we are a point and the message is from_AND_to our boss, then
          we consider it as to us - needed for importing echomain on points
          with a tosscan boss - ugly ... - vp */
       if (hhdr.Dzone==hhdr.Ozone && hhdr.Ozone==alias[i].zone && alias[i].net==hhdr.Dnet &&
	   hhdr.Dnet==hhdr.Onet && hhdr.Dnode==hhdr.Onode && hhdr.Dpoint==hhdr.Opoint &&
           alias[i].node==hhdr.Dnode && alias[i].point && hhdr.Dpoint==0) return 1;
#endif
    }
    return 0;
}

int read_line()
{
    int ch;
  
    ch=getc(pkt);
    while (!feof(pkt) && ch && ch!=2 && ms<MESSAGE+(30*1024-10))
    {
        switch(ch)
        {
          case '\r': *ms++='\n';
                     *ms='\0';
                     return 0;
          case '\n':
          case 0x7f:
          case 0x8d:
          case 0x8a: 
                     if (verbose > 3) print("`%02x`",ch);
                     break;
          default:   *ms++=ch;
                     if (verbose > 3) print("%c",ch);
        }
        ch=getc(pkt);
    }

    *ms++='\n';
    *ms++=0;
    if (feof(pkt) && ch)
    {
        message(6,"-Unexpected end of package!");
        return -2;
    }

    if (ch==2)
    {
        message(6,"-Cripled message");
        fseek(pkt,-1L,1);
    }

    if (ms>=MESSAGE+((30*1024)-10))
    {
        message(2,"-Message too long, will not be echoed anymore");
        while (!feof(pkt) && ch) ch=getc(pkt);   /* too long, skip rest! */
        hhdr.flags |= SENT;                      /* signal it being sent */
    }
    return -1;
}

void Iadress(str, zone, net, node)
char *str;
short *zone, *net, *node;
{
    char *p;
    int zo, ne, no;
   
    for (p=str; *p && isspace(*p); p++) ;
    if (sscanf(p, "%d:%d/%d", &zo, &ne, &no)!=3)
    {
        message(6,"!INTL error in %s.", str);
        *zone=0;
        return;
    }
    *zone= zo; *node= no; *net= ne;
}

#define NORMAL  1
#define SKIP    4

int line_type(line)
char *line;
{
    char *p, *q;
    int j;
   
    if (*line!=0x01) return NORMAL;

    if (verbose > 3) print("^A line: %s\n",line+1);
    
    /* Parse and remove INTL, FMPT and TOPT */
    if (!strnicmp(line+1,"INTL",4))
    {
        /* We've got an international (interzone) adress so parse it */
#ifdef LINN
        Iadress(line+5,(short *)&hhdr.Dzone,(short *) &hhdr.Dnet,(short *) &hhdr.Dnode);
#else
        Iadress(line+5,(int *)&hhdr.Dzone,(int *) &hhdr.Dnet,(int *) &hhdr.Dnode);
#endif
        p=line+8;
        while (*p && !isspace(*p)) ++p;
#ifdef LINN
        Iadress(p,(short *) &hhdr.Ozone,(short *) &hhdr.Onet,(short *) &hhdr.Onode);
#else
        Iadress(p,(int *) &hhdr.Ozone,(int *) &hhdr.Onet,(int *) &hhdr.Onode);
#endif
        return SKIP;
    }

    if (!strnicmp(line+1,"FMPT",4))
    {
        if (hhdr.Opoint) return NORMAL;
        for(p=line+5;*p && isspace(*p);++p) ;
        q = p;
        j = 0;
        while (isdigit(*p))
        {
            j *= 10;
            j += *p-'0';
            ++p;
        }
        if (j==0)
        {
            message(6,"!FMPT error in %s",line+1);
            return NORMAL;
        }
        hhdr.Opoint=j;
        if (*p=='.')        /* more point numbers?? */
        {
            while (*p) *q++=*p++;
            return NORMAL;
        }
        return SKIP;
    }
    if (!strnicmp(line+1,"TOPT",4))
    {
        if (verbose > 3) print("TOPT line %s\n",line+1);

        for(p=line+5;*p && isspace(*p);++p) ;
        q = p;
        j = 0;
        while (isdigit(*p))
        {
            j *= 10;
            j += *p-'0';
            ++p;
        }
        if (j==0)
        {
            message(6,"!TOPT error in %s",line+1);
            return NORMAL;
        }
        hhdr.Dpoint=j;
        if (*p=='.')        /* more point numbers?? */
        {
            while (*p) *q++=*p++;
            return NORMAL;
        }
        return SKIP;
    }

    /* Leave everything we don't know about at the same place in the message */
    return NORMAL;
}

char *next_str (p, lookfor)
char *p;
char *lookfor;
{
   extern char *strchr();
   char *found;

    if (verbose > 4) print ("Look for '%s'\n", lookfor);

    found=p;
    while (1)
    {
        found = strchr(found, *lookfor);

      /* Found anything at all? */
        if (found == NULL)
        {
            if (verbose > 4) print("End-Of-Message\n");
            return NULL;
        }

        if (verbose > 4) print ("Match first char in '%20.20s'\n", found);

        if (strncmp (found, lookfor, strlen(lookfor)))
        {
            ++found;
            if (verbose > 4) print("match FAIL\n");
            continue;
        }
        else
        {
            if (verbose > 4) print("match OK\n");
            return found;
        }
    }
}

char *GetArea()
{
        char *p;

        /* Check for AREA line at start of message */
        if (!strncmp(MESSAGE,"AREA:",5)) return MESSAGE;
        if (!strncmp(MESSAGE,"\01AREA:",6)) return MESSAGE;

        /* Not at start of message, somewhere else in the message? */
        if ( (p=next_str(MESSAGE,"\n\01AREA:"))!=NULL ||
             (p=next_str(MESSAGE,"\nAREA:"))!=NULL ) return p;

        /* No AREA line found in message */
        return NULL;
}
             
int read_msg()
{
    char ch;
    int result;
    char temp[80];                  /* temp. storage */
    char *p,*q;                     /* pointer in MESSAGE buffer */
    
    ms=MESSAGE;                     /* initiatial state for new message */
   
    if (verbose > 3) print("Message body:\n");

    /* Now we're gonna read the entire message */
    do
    {
        p=ms;
        result= read_line();
        switch (line_type(p))
        {
            case NORMAL:
                         break;
            case SKIP  : ms=p;
        }
    }
    while (!result) ;
    
    /* we've got it! is it ECHOmail to us? */
    
    area=mailarea;
    *ms='\0';

    /* Make sure endbody points to the trailing zero */
    endbody= ms;
    while (*endbody=='\0' && endbody>MESSAGE) endbody--;
    endbody++;

    if (verbose > 2) print("It is %sto us.\n",ourmessage() ? "" : "not ");

    if ( (p=GetArea())!=NULL )
    {                                 /* Gee, an echomail message! */
        hhdr.Dpoint = 0;              /* Clear point fields        */
        hhdr.Opoint = 0;
    	if (ourmessage())             /* only toss our messages */
    	{
            q= p;
            while (!(isspace(*p) || *p==':')) ++p; /* skip to 'spaces' */
            while ((isspace(*p) || *p==':')) ++p;  /* skip 'spaces' */
            ch=0;
            while (*p && !isspace(*p))
            {
                temp[ch++]=*p++;
            }
            temp[ch]=0;

            if (verbose > 2) print("Its echomail, the area is >%s<\n",temp);

            for (area=0; area<msgareas; area++)
            {
                if (!strcmp(temp,AreaName[area]))
                {
                    int i;

                    /* secure mode? */
                    if (!secure) goto gotit;

                    /* Yep, check feed for valid address */
                    if (ToZone[area]==NULL) continue;
                    for (i=1; ToZone[area][i]||ToNet[area][i]; i++)
                    {
                        if (hhdr.Ozone==ToZone[area][i] &&
                            hhdr.Onet==ToNet[area][i] &&
                            hhdr.Onode==ToNode[area][i]) goto gotit;
                    }
                }
            }

            if (area>=msgareas)          /* unknown? */
            {
                area=badarea;
            }
            else
            {
gotit:
                while (*p=='\n') p++;

                memmove(q,p,strlen(p)+1);  /* get rid of useless line */
                                /*    ^ Don't forget trailing zero!! */
                endbody = endbody - (p-q);

                sprintf(ThisArea,"%sAREA:%s\n", use_kludge ? "\01":"",
                        AreaName[area]);
            }
        }
    }

    mend= endbody;

    return (result==-1);                    /* if result<>-1 serious trouble */
}

void GetThem(msg, str, szones, snets, snodes, spoints, tseen)
char *msg;
char *str;
unsigned szones[];
unsigned snets[];
unsigned snodes[];
unsigned spoints[];
int *tseen;
{
    unsigned j, last_net;
    char *p,*q,*r;
#ifdef LINN
    int i;
#endif

    last_net = 65535U;
    r=msg;

    while ((p=next_str(r,str))!=NULL)
    {
        q=p;
       /* get begin of this line */
        while (q > MESSAGE && *q!='\n') --q;
        r=q;
        if (*p=='\n') ++p;

        while (*p && *p!='\n')        /* not the end of the line */
        {
           /* found a net/node pair? */
            if (isdigit(*p))
            {
               /* get the number. */
                getint(&p, &j);

               /* Is it a net/node pair? */
                if (*p == ':')
                {
#ifdef LINN
		/* simply strip the zone number, because there are some
		   problems parsing them and I'm not sure other parts of
		   import would works ok if the parsing was correctly
		   done. VP */
		   p++;
		   getint (&p, &j);
		}
#else
                    if (getaddress(p+1, &szones[*tseen], &snets[*tseen],
                                    &snodes[*tseen], &spoints[*tseen])!=6)
                    {
                        message(6,"!Illegal address %s",p);
                        *tseen--;       /* because it's incremented below */
                    }
                    while (*p && !isspace(*p)) p++;
                    szones[*tseen]=j;
                }
                else
                {
#endif
                    szones[*tseen]=ourzone;
                    spoints[*tseen]=0;
                    
                    if (*p == '/')
                    {
                        ++p;
                        last_net = snets[*tseen] = j;
                        getint(&p, &snodes[*tseen]);
                    }
                    else
                    {
                        snets[*tseen] = last_net;
                        snodes[*tseen] = j;
                    }
                    if (last_net==ourpointnet)
                    {
                        spoints[*tseen]=snodes[*tseen];
#ifdef LINN /* pointnet/point -> net/node.point expansion
                converts to primary address instead of 1st feed alias's
                pointnet */
                        for (i=0; i < nalias; i++)
                        {
                            if (alias[i].pointnet==ourpointnet)
                            {
                                snets[*tseen]=alias[i].net;
                                snodes[*tseen]=alias[i].node;
                                break;
                            }
                        }
#else
                        snets[*tseen]=ournet;
                        snodes[*tseen]=ournode;
#endif
                    }
#ifndef LINN
                }
#endif

                if (verbose > 4) print ("Got %d:%d/%d.%d\n", szones[*tseen],snets[*tseen],
                        snodes[*tseen],spoints[*tseen]);

                if (*tseen<940)
                {
                    ++*tseen;
                }
            }
            else
            {
                ++p;
            }
        }   /* end while for this line */
        while (*p)
        {
            *q++=*p++;          /* copy rest of the message to delete line */
        }
        *q=0;
        mend=q;
    } /* end while for lines.. */
}

/* I've seen better sort algoritmes, so do you undoubtely, but this one works
 * alright and for these small numbers it doesn't matter.
 * (Routine taken from a nice book on algorithems by L. Ammeraal as far
 *  as I recall, it's a long time ago I even looked at this code...)
 */

void SortThem(zones,nets,nodes,points,nr,chpoints)
unsigned zones[], nets[], nodes[], points[];
int *nr, chpoints;
{
    register int i, i1, left=0, right=(*nr)-1, temp=0;
    unsigned ne1,ne2,no1,no2,p1,p2;

    if (verbose > 5) print("start sorting now....\n");

   /* sort them all (not recursive sort to prevent stack problems) */
    do
    {
        for (i=left; i<right; i++)
        {
            i1=i+1;
            if (chpoints && points[i])
            {
                ne1=ourpointnet;
                no1=points[i];
                p1=0;
            }
            else
            {
                ne1=nets[i];
                no1=nodes[i];
                p1=points[i];
            }
            if (chpoints && points[i1])
            {
                ne2=ourpointnet;
                no2=points[i1];
                p2=0;
            }
            else
            {
                ne2=nets[i1];
                no2=nodes[i1];
                p2=points[i1];
            }
            if ((zones[i] > zones[i1]) || ((zones[i] == zones[i1]) &&
                ((ne1 > ne2) || ((ne1==ne2) && 
                ((no1>no2) || ((no1==no2) && (p1>p2) ))))))
            {
                temp=zones[i]; zones[i]=zones[i1]; zones[i1]=temp;
                temp=nets[i]; nets[i]=nets[i1]; nets[i1]=temp;
                temp=nodes[i]; nodes[i]=nodes[i1]; nodes[i1]=temp;
                temp=points[i]; points[i]=points[i1]; points[i1]= temp;
                temp=i;
            }
        }
        right=temp;

        /* Still with me? No?!? I'm not sure I do understand it myself
         * anymore (and the original routine was so simple).
         */

        for(i=right; i>left; i--)
        {
            i1=i-1;
            if (chpoints && points[i])
            {
                ne1=ourpointnet;
                no1=points[i];
                p1=0;
            }
            else
            {
                ne1=nets[i];
                no1=nodes[i];
                p1=points[i];
            }
            if (chpoints && points[i1])
            {
                ne2=ourpointnet;
                no2=points[i1];
                p2=0;
            }
            else
            {
                ne2=nets[i1];
                no2=nodes[i1];
                p2=points[i1];
            }
            if ((zones[i1] > zones[i]) || ((zones[i1] == zones[i]) &&
                ((ne2 > ne1) || ((ne2==ne1) && 
                ((no2>no1) || ((no2==no1) && (p2>p1) ))))))
            {
                temp=zones[i]; zones[i]=zones[i1]; zones[i1]=temp;
                temp=nets[i]; nets[i]=nets[i1]; nets[i1]=temp;
                temp=nodes[i]; nodes[i]=nodes[i1]; nodes[i1]=temp;
                temp=points[i]; points[i]=points[i1]; points[i1]= temp;
                temp=i;
            }
        }
        left=temp;

        if (verbose > 5) print("Left: %d        Right: %d\n",left,right);

    }
    while (left<right);

    if (verbose > 5) print("Sorted.\n");

   /* get rid of duplicates now */
    temp=*nr;
    for(i1=i=1; i<temp; i++)
    {
        if (zones[i]!=zones[i-1] || nets[i]!=nets[i-1] ||
            nodes[i]!=nodes[i-1] || points[i]!=points[i-1])
        {
            zones[i1]=zones[i];
            nets[i1]=nets[i];
            nodes[i1]=nodes[i];
            points[i1++]=points[i];
        }
    }
    if (i!=1) *nr=i1;

    if (verbose > 5) print("Original: %d      Now: %d\n", i,i1);
}

/* CheckSeen checks your seen-bys to find any missing nodes you're
 * supposed to feed this echo to.
 */
void CheckSeen()
{
    int i, fo, found, k, what;
    
    fo= found= 0;
    i= 1;

    while (ToZone[area][i] || ToNet[area][i])
    {
        if (verbose > 2) print("Check for send to %u:%u/%u.%u\n",ToZone[area][i],ToNet[area][i],
        ToNode[area][i],ToPoint[area][i]);

        for (k=found; k < nSeen; k++)
        {
            if (SeenNet[k]==ToNet[area][i] && SeenNode[k]==ToNode[area][i] && 
                SeenPoint[k]==ToPoint[area][i])
            {
                SendTo[i]=0;
                if (SeenZone[k]==ToZone[area][i]) found=k;
                break;
            }
        }
        if (k==nSeen)
        {
            SendTo[i]=1;
            fo=1;
        }
        ++i;
    }
    if (!fo) return;

    if (verbose > 2) print("Should send message to:");

    i=0;
    while (++i, ToNet[area][i]||ToNode[area][i])
    {
        if (!SendTo[i]) continue;

        if (verbose > 2) print("%u:%u/%u.%u  ",ToZone[area][i],ToNet[area][i],
                ToNode[area][i],ToPoint[area][i]);

        SeenZone[nSeen]=ToZone[area][i];
        SeenNet[nSeen]=ToNet[area][i];
        SeenNode[nSeen]=ToNode[area][i];
        SeenPoint[nSeen++]=ToPoint[area][i];
    }

    if (verbose > 2) print("\nSort now..");

    SortThem(SeenZone,SeenNet,SeenNode,SeenPoint,&nSeen,1);

    if (verbose > 2) print("\nCreating message to ");

    i=0;
    while (++i, ToNet[area][i]||ToNode[area][i])
    {
        if (!SendTo[i]) continue;
        if (verbose > 2)
                print("%u:%u/%u.%u ",ToZone[area][i],ToNet[area][i],
                        ToNode[area][i],ToPoint[area][i]);

        what= ((ToPoint[area][i]) ? POINTS : 0) |
               (use_tiny ? LOCALS:OTHERS);
        writemessage(use_packet ? SCANFILE : OUTBOUND,what,
             ToZone[area][i],ToNet[area][i],ToNode[area][i],ToPoint[area][i]);
    }

    if (verbose > 2) print("\n");
}

void PurgeBlanks()           /* delete trailing blanks */
{
    char *p;
    
   /* point p at end of message */
    p=mend;
   /* if it's the trailing '\0' then skip it. */
    while (p>MESSAGE && *p==0) --p;
   /* back till begin of message or any non blank */
    while (p>MESSAGE && isspace(*p)) --p;
   /* p points to valid char now (non blank) so increment by one */
    *(++p)='\0';
    mend=p;
}

int CheckEcho()
{
    int i;
    
   /* first check if msg valid for sending. */
    if (hhdr.flags & SENT ||
        hhdr.flags & FILEATCH)  return 1;

    if (next_str(MESSAGE,"\nNOECHO") || next_str(MESSAGE,"\nnoecho")) return 1;
  
   /* Get the seen-bys (deletes the lines..) */
    nSeen=0;
    GetThem(MESSAGE, "\n\01SEEN-BY:", SeenZone, SeenNet, SeenNode,
            SeenPoint, &nSeen);
    GetThem(MESSAGE, "\nSEEN-BY:", SeenZone, SeenNet, SeenNode,
            SeenPoint, &nSeen);

    /* Check the number of seen-bys. If zero it's a bad message */
    if (nSeen == 0)
    {
        message(6,"-echomail missing seen-by lines --> badmsgs (%d)",
#ifdef LINN
                nmsgs[badarea]+1);
#else
                nmsgs[badarea]);
#endif
        hhdr.mailer[7] |= MSGSCANNED;
        area = badarea;
        return 1;
    }

    /* Add our primary address */
    SeenZone[nSeen]=ourzone;
    SeenNet[nSeen]=ournet;
    SeenNode[nSeen]=ournode;
    SeenPoint[nSeen++]=ourpoint;

   /* add our own numbers (AKAs etc.) */
    for (i=0;i<add_aka && i<nalias;i++)
    {
#ifdef LINN
        if (alias[i].zone==ourzone) {
#endif
            SeenZone[nSeen]=alias[i].zone;
            SeenNet[nSeen]=alias[i].net;
            SeenNode[nSeen]=alias[i].node;
            SeenPoint[nSeen++]=alias[i].point;
#ifdef LINN
	}
#endif
    }

   /* get them in the correct order again.. */
    SortThem(SeenZone,SeenNet,SeenNode,SeenPoint, &nSeen,0);

    if (verbose > 2)
    {
        print("Message SEEN-BY:");
        for (i=0;i<nSeen;i++) print(" %u:%u/%u.%u",SeenZone[i],SeenNet[i],
             SeenNode[i],SeenPoint[i]);
        print("\n");
    }
    
   /* get the path, not restored if not in use (get rid of line anyway..) */
    nPath=0;
    GetThem(MESSAGE, "\n\01PATH:", PathZone, PathNet, PathNode,
            PathPoint, &nPath);

    if (verbose > 2)
    {
        print("Message PATH:");
        for (i=0;i<nPath;i++) print(" %u:%u/%u.%u",PathZone[i],PathNet[i],
                PathNode[i],PathPoint[i]);
        print("\n");
    }
    
   /* Get rid of all trailing blanks now. */
    PurgeBlanks();

#ifdef HELL_FREEZES_OVER
   /* Check if we've got an origin-line, it's a bad message if none found */
    if (next_str(MESSAGE,"\n * Origin:")==NULL)
    {
        message(6,"-echomail missing Origin line --> badmsgs");
        hhdr.mailer[7] |= MSGSCANNED;
        area = badarea;
        return 1;
    }
#endif

    endbody=mend;   /* message body ends HERE */
    
   /* Now check for nodes to send the message to (and send those msgs) */
    CheckSeen();
    
   /* Flag message as scanned */
    hhdr.mailer[7] |= MSGSCANNED;
    return 1;
}

void add(p) char *p;
{       while (*p)
        {       *mend++=*p++;
                x++;
        }
}

void AddThem(addstr,zones,nets,nodes,points,nr,dopoints,dozones)
char *addstr;
unsigned zones[], nets[], nodes[], points[];
int nr, dopoints, dozones;
{
    unsigned lastnet, len, tnet, tnode;
    int i;
    char str[20];
    
    x=100;
#ifdef LINN
    lastnet=(unsigned) -1;
#else
    lastnet=-1;
#endif
    for(i=0; i<nr; i++)
    {
        if (zones[i]!=ourzone)
        {
            if (dozones)
            {
#ifdef LINN
                tnet=(unsigned)-1;
#else
                tnet=-1;
#endif
                sprintf(str," %u:%u/%u.%u",zones[i],nets[i],nodes[i],points[i]);
            }
            else *str=0;
        }
        else
        {
            if (verbose > 3) print("%u/%u.%u -> ",nets[i],nodes[i],points[i]);

            if (points[i])
            {
                tnet=ourpointnet;
                tnode=points[i];
            }
            else
            {
                tnet=nets[i];
                tnode=nodes[i];
            }
            
            if (!dopoints && points[i] && !(points[i]==ourpoint &&
                nodes[i]==ournode && nets[i]==ournet)) continue;

            if (lastnet==tnet) sprintf(str," %u",tnode);
            len=(int)strlen(str);
            if (lastnet!=tnet || (len+x > 76))
                sprintf(str," %u/%u",tnet,tnode);
        }
        len=(int)strlen(str);
        if (len+x >76)
        {
            x=0;
            add(addstr);
        }
        if (verbose > 3) print("%s\n",str);

        add(str);
        lastnet=tnet;
    }
    *mend=0;
}

/* AddSeen adds seen-by lines to a message */
void AddSeen(what)
int what;
{
    char sline[20];
    int i;

    sprintf(sline, "\n%sSEEN-BY:", use_kludge ? "\01" : "");
    if (what&LOCALS)
    {
        for (i=1; ToNet[area][i]|ToNode[area][i]; ++i);
        AddThem(sline,&ToZone[area][1],&ToNet[area][1],
                &ToNode[area][1],&ToPoint[area][1],i-1,
               (what&POINTS),(what&DIFFZONE));
    }
    else AddThem(sline,SeenZone,SeenNet,SeenNode,SeenPoint,
                  nSeen, (what&POINTS), (what&DIFFZONE));
}

void AddPath(add)
int add;
{
    int th=1;
    
    if (PathZone[nPath-1]==ourzone && PathNet[nPath-1]==ournet &&
        PathNode[nPath-1]==ournode && PathPoint[nPath-1]==ourpoint) --th;
    PathZone[nPath]=ourzone;
    PathNet[nPath]=ournet;
    PathNode[nPath]=ournode;
    PathPoint[nPath]=ourpoint;
    /* Only add all path nodes when in own zone */
    if (!add) AddThem("\n\01PATH:",PathZone,PathNet,PathNode,
                 PathPoint,nPath+th,-1,0);
    else AddThem("\n\01PATH:",&ourzone,&ournet,&ournode,&ourpoint,1,-1,0);
}

void OpenPacket(nr,zone,net,node,point)
int nr;
unsigned zone, net, node, point;
{
    struct time t;
    struct date d;
    struct _pkthdr phdr;
    char fname[80];
    int  i;
    int tzone, tnet, tnode, tpoint;
    
    tzone= ourzone;
    tnet= ournet;
    tnode= ournode;
    tpoint= ourpoint;

    if (verbose > 1) print("Open packet %u:%u/%u.%u\n",zone,net,node,point);

    /* Get password first before all information is destroyed */
    get_passw(zone,net,node,point);
    getalias(zone,net,node,point);

	/* save the 4-D address first */
    pktzone[nr]= zone;
    pktnet[nr]= net;
    pktnode[nr]= node;
    pktpoint[nr]= point;

    if (point)
    {
        for (i=0; i<nalias; i++)
        {
            if (alias[i].zone==zone && alias[i].net==net &&
                alias[i].node==node && alias[i].point==0)
            {
                net= alias[i].pointnet;
                node= point;
                point= 0;
                pktfake[nr] = net;
                break;
            }
        }
        if (point)
        {
            message(6,"!Can't scan for points of other BBSes!");
            exit(2);
        }
    }
    else
    {
    	pktfake[nr] = 0;
    }

	/* try to open existing files, first .WM then .NM */

#ifdef LINN
    if (binkley) {
       if (zone==alias[0].zone) {
         sprint(fname, "%s%03z%03z00.HPT", hold, net, node);
         pktfile[nr]=fopen(fname, BRUP);
         if (pktfile[nr] == NULL) {
	    sprint(fname, "%s%03z%03z00.OPT", hold, net, node);
    	    pktfile[nr]= fopen(fname,BRUP);
    	 }
       } else {
         sprint(fname, "%s.%03x%c%03z%03z00.HPT", holdbink, zone, DIRSEP, net, node);
         pktfile[nr]=fopen(fname, BRUP);
         if (pktfile[nr] == NULL) {
	    sprint(fname, "%s.%03x%c%03z%03z00.OPT", holdbink, zone, DIRSEP, net, node);
    	    pktfile[nr]= fopen(fname,BRUP);
    	 }
       }
    } else {
       sprint(fname, "%s%02z%03z%03z.WM", hold, zone, net, node);
       pktfile[nr]= fopen(fname,BRUP);
       if (pktfile[nr] == NULL) {
	    sprint(fname, "%s%02z%03z%03z.NM", hold, zone, net, node);
    	    pktfile[nr]= fopen(fname,BRUP);
       }
    }
#else
    sprint(fname, "%s%02z%03z%03z.WM", hold, zone, net, node);
    pktfile[nr]= fopen(fname,BRUP);
    if (pktfile[nr] == NULL) {
	    sprint(fname, "%s%02z%03z%03z.NM", hold, zone, net, node);
    	pktfile[nr]= fopen(fname,BRUP);
    }

#endif

    if (pktfile[nr]!=NULL)
    {
        fseek(pktfile[nr],-2L,2);
        ourzone= tzone;
        ournet= tnet;
        ournode= tnode;
        ourpoint= tpoint;
        return;
    }

    pktfile[nr]= fopen(fname,BWUP);
    if (pktfile[nr]==NULL)
    {
        message(6,"!Can't open file %s",fname);
        exit(1);
    }

    /* new packet, we've to make a header first */
    getdate((struct date *)&d);
    gettime((struct time *)&t);
    memset(&phdr, 0, sizeof(struct _pkthdr));

    /* are we a point and not to boss then re-address */
    if (ourpoint)
    {
        if (ournode!=node || ournet!=net || ourzone!=zone)
        {
            phdr.ph_onode= inteli(-1);
            phdr.ph_onet = inteli(ourpointnet);
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

    ourzone= tzone;
    ournet= tnet;
    ournode= tnode;
    ourpoint= tpoint;
}

void ClosePacket(nr)
int nr;
{
    if (verbose > 1) print("Close packet\n");

    if (pktfile[nr])
    {
        pktzone[nr]= pktnet[nr]= pktnode[nr]= pktpoint[nr]= 0;
        if (fwrite("\0\0", 2, 1, pktfile[nr])!=1)
        {
            message(6,"!Error writing to package");
            exit(1);
        }
        fclose(pktfile[nr]);
        pktfile[nr]= NULL;
    }
}

void MakeHdr(nr,Mhdr)
int nr;
struct Hdr *Mhdr;
{
    struct _pktmsgs mh;
    
    if (verbose > 1) print("MakeHdr\n");

    mh.pm_ver=inteli(2);
    mh.pm_onode=inteli(Mhdr->Onode);
    mh.pm_onet=inteli(Mhdr->Onet);
    mh.pm_dnode=inteli(Mhdr->Dnode);
    mh.pm_dnet=inteli(Mhdr->Dnet);
    mh.pm_attr=inteli(Mhdr->flags&0x3413);
    mh.pm_cost=inteli(Mhdr->cost);
    fwrite((char *)&mh, sizeof(struct _pktmsgs), 1, pktfile[nr]);
    fprintf(pktfile[nr],"%19s",Mhdr->time);
    putc('\0',pktfile[nr]);
    fprintf(pktfile[nr],"%s",Mhdr->to);        /* from & to */
    putc('\0',pktfile[nr]);
    fprintf(pktfile[nr],"%s",Mhdr->from);
    putc('\0',pktfile[nr]);
    fprintf(pktfile[nr],"%s",Mhdr->topic);     /* topic */
    putc('\0',pktfile[nr]);
    
#ifdef LINN
    if (no_intl)
#endif
    if (Mhdr->Ozone && Mhdr->Dzone && (Mhdr->Ozone!=Mhdr->Dzone))
        fprintf(pktfile[nr],"\01INTL %d:%d/%d %d:%d/%d\r\n", Mhdr->Dzone,
          Mhdr->Dnet, Mhdr->Dnode, Mhdr->Ozone, Mhdr->Onet, Mhdr->Onode);
}

void PktWrite(nr, str, len)
int nr;
char *str;
int len;
{
    if (verbose > 1) print("PktWrite\n");

    while (len--)
    {
        if (*str=='\n') putc('\r',pktfile[nr]);
        else putc(*str,pktfile[nr]);
        str++;
        if (ferror(pktfile[nr]))
        {
                exit(1);
        }
    }
    if (ferror(pktfile[nr]))
    {
        message(6,"!Error writing to packet-file");
        exit(1);
    }
}

void writemessage(where,what,zone,net,node,point)
int where;
int what;
unsigned zone,net,node,point;
{
    int i;
    static int j= -1;
    char sline[20];
    int empty= -1;

    memmove((char *) &Mhdr, (char *) &hhdr, sizeof(struct Hdr));
#ifdef LINN
    getalias (zone, net, node, point);
#endif
    mend=endbody;
    if (what)
    {
        if (zone!=ourzone) 
        {
            unsigned z[3],ne[3],no[3],p[3];
            int i;
            
            i=2;
            z[0]=ourzone; z[1]=ourzone;
            ne[0]=ournet; ne[1]=net;
            no[0]=ournode; no[1]=node;
            p[0]=ourpoint; p[1]=0;
            SortThem(z,ne,no,p,&i,1);
            sprintf(sline, "\n%sSEEN-BY:", use_kludge ? "\01" : "");
            AddThem(sline,z,ne,no,p,2,1,0);
        }
        else AddSeen(what);
        if (use_path) AddPath(zone!=ourzone);

        if (use_readdress)
        {
            Mhdr.Ozone = ourzone;
            Mhdr.Onet  = ournet;
            Mhdr.Onode = ournode;
            Mhdr.Opoint= ourpoint;
            if (ourpoint)
            {
                Mhdr.Onet= ourpointnet;
                Mhdr.Onode= ourpoint;
                Mhdr.Opoint=0;
            }
        }
    }
    switch (where)
    {
      case OUTBOUND:
                    Mhdr.Mstart= ftell(MMSG);
                    echomsgs++;
#ifdef LINN
                    emsgs[area]++;
#endif
                    if (what)
                    {
                        if (fwrite(ThisArea, strlen(ThisArea),1, MMSG)!=1)
                        {
                            message(6,"!Fatal error writing to mail");
                            exit(1);
                        }
                        Mhdr.size=(int)strlen(ThisArea);
                    }
                    else Mhdr.size=0;
                    *mend++='\n';
                    *mend='\0';
                    Mhdr.size += (int)(mend-MESSAGE)+2;
                    Mhdr.Dzone = zone;
                    Mhdr.Dnet  = net;
                    Mhdr.Dnode = node;
                    Mhdr.Dpoint= point;
                    Mhdr.flags |= (MSGLOCAL|KILLSEND);
                    Mhdr.parent = 0;
                    for (i=0; i<8; i++) Mhdr.mailer[i]=0;
                    Mhdr.cost=0;
                    if (fwrite(MESSAGE, ((mend-MESSAGE)+2), 1, MMSG)!=1)
                    {
                        message(6,"!Fatal error writing to mail");
                        exit(1);
                    }
                    if (fwrite((char *) &Mhdr, sizeof(struct Hdr), 1, MHDR)!=1)
                    {
                        message(6,"!Fatal error writing to mail");
                        exit(1);
                    }
                    break;
      case SCANFILE:
                    echomsgs++;
#ifdef LINN
                    emsgs[area]++;
#endif
                    for (i=0; i<10; i++)
                    {
                        if (pktfile[i]==NULL) empty= i;
                        if (zone==pktzone[i] && net==pktnet[i] && 
                            node==pktnode[i] && point==pktpoint[i]) break;
                    }

                    if (i>=10)
                    {
                        if (empty != -1)
                        {
                            OpenPacket(empty,zone,net,node,point);
                            i= empty;
                        }
                        else
                        {
                            j= (j+1) < 10 ? j+1 : 1;
                            ClosePacket(j);
                            OpenPacket(j,zone,net,node,point);
                            i= j;
                        }
                    }
                    
                    *mend++='\n';
                    *mend='\0';
                    if (point) {
                    	net = pktfake[i];
                    	node = pktpoint[i];
                    	point = 0;
                    }
                    Mhdr.Dzone = zone;
                    Mhdr.Dnet  = net;
                    Mhdr.Dnode = node;
                    Mhdr.Dpoint= point;
                    Mhdr.flags |= (MSGLOCAL);
                    Mhdr.cost=0;
                    MakeHdr(i,&Mhdr);
                    if (what)
                    {
                        PktWrite(i, ThisArea, (int)strlen(ThisArea));
                    }
                    PktWrite(i, MESSAGE, ((int)(mend-MESSAGE)+1));
                    break;
      case LOCAL:
      default:      message(6,"?Internal error %02x in messagewrite",where);
    }
}

/* Save message to local messagebase */
void savemessage(where,what)
int where;
int what;
{
    mend=endbody;
#ifdef LINN	/* do not save empty messages... usefull ??? */
    if (mend==MESSAGE)
    	return;
#endif

    if (what)
    {
        AddSeen(what);
        if (use_path) AddPath(0);
    }

#ifdef LINN
    /* does not count messages to sysop in echomail */
    if ((!what && (!strnicmp(hhdr.to,"sysop",5))) || !strnicmp(hhdr.to,sysop,strlen(sysop)))
#else
    if (!strnicmp(hhdr.to,"sysop",5) || !strnicmp(hhdr.to,sysop,strlen(sysop)))
#endif
        smsgs[area]++;

    if (verbose)
    {
        clprint(": %s ",hhdr.from);
        if (area==mailarea)
           clprint("(%d:%d/%d.%d) ",hhdr.Ozone,hhdr.Onet,hhdr.Onode,hhdr.Opoint);
        clprint("> %s ", hhdr.to);
        if (area==mailarea)
           clprint("(%d:%d/%d.%d) ",hhdr.Dzone,hhdr.Dnet,hhdr.Dnode,hhdr.Dpoint);
#ifdef LINN
        clprint(", %s (msg %d)\n",AreaName[area],nmsgs[area]+1);
#else
        clprint(", %s (msg %d)\n",AreaName[area],nmsgs[area]);
#endif
    }

    nmsgs[area]++;

#ifdef LINN	/* passthrough area */
    if (!stricmp("PASSTHRU", AreaPath[area]))
    	return;
#endif

    if (area!=lastarea)                     /* same area? */
    {
        if (lastarea!=-1) close_area();
        open_area(area);
        lastarea=area;
    }

    switch (where)
    {
      case LOCAL:   hhdr.Mstart= ftell(msg);
                    hhdr.size  = (int) (mend-MESSAGE)+1;
                    if (fwrite(MESSAGE, hhdr.size, 1, msg)!=1)
                    {
                        message(6,"!Fatal error writing message");
                        exit(1);
                    }
                    if (fwrite((char *) &hhdr, sizeof(struct Hdr), 1, hdr)!=1)
                    {
                        message(6,"!Fatal error writing header");
                        exit(1);
                    }
                    break;
      default:      message(6,"?Internal error %02x",where);
    }
}


void display_results()
{
    int i;                              /* yep, counter again... */
    int flag=0;                         /* displayed something?? */

    for (i=0;i<msgareas;i++)
        if (nmsgs[i])
        {
            if (!flag)
            {
#ifdef LINN
              message(2,"=     AREANAME     | MESSAGES | To Sysop | Echomail");
              message(2,"===================+==========+==========+==========");
#else
              message(2,"=     AREANAME     | MESSAGES | To Sysop");
              message(2,"===================+==========+==========");
#endif
              flag=1;
            }            
#ifdef LINN
            message(2,  "= %-16.16s |  %4d    |  %4d    |  %4d",AreaName[i],
                         nmsgs[i],smsgs[i], emsgs[i]);
#else
            message(2,  "= %-16.16s |   %3d    |   %d",AreaName[i],nmsgs[i],
                         smsgs[i]);
#endif
        }
    if (!flag) message(2,"=No mail imported");
    else message(2,"=Created %d echo-messages",echomsgs);
}

void process_packets()
{
    int i, na;
    
    while (open_pack())           /* open packet                */
    {
        i=1;                      /* begin this packet, so no errors (yet) */
        while ( i && read_hdr() ) /* get message header */
        {
            conv_hdr();           /* convert header */
            i=read_msg();         /* read the message */
            if (area != mailarea && ToZone[area]!=NULL)
            {
                /* we've got echomail, so let's toss it right away */
                getalias(ToZone[area][0],ToNet[area][0],
                                ToNode[area][0],ToPoint[area][0]);
                if (CheckEcho()) savemessage(LOCAL,POINTS|OTHERS|DIFFZONE);
            }
            else
#ifdef LINN
            {
            	if (killrouted & !ourmessage())
            	        hhdr.flags |= KILLSEND;
                /* import netmail to points as 4D */
                for (na=0;na<nalias;na++)
                {
                   if (alias[na].point && alias[na].pointnet==hhdr.Dnet &&
                   alias[na].point==hhdr.Dnode && alias[na].zone==hhdr.Dzone)
                   {
                       hhdr.Dnet=alias[na].net;
                       hhdr.Dnode=alias[na].node;
                       hhdr.Dpoint=alias[na].point;
                   }
                }
                savemessage(LOCAL,0);
            }
#else
                savemessage(LOCAL,0);
#endif
        }
        if (pkt)
        {
            fclose(pkt);      /* close and */
            pkt=NULL;
        }
        if (*packet && unlink(packet))       /* delete packet */
        {
            message(6,"!Can not delete %s",packet);
            exit(2);
        }
    }
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
    int i;
    
#if STTC
    environ= envir;
#endif

    fprintf(stderr,
     "BERMUDA : FidoNet compatible message processing software\n");
    fprintf(stderr,
     "IMPORT utility ; Version %s created %s at %s\n\n",UVERSION,
     __DATE__,__TIME__);
    fflush(stderr);

    init(argc, argv);             /* initiate everything needed */

    message(6,"*Import mail.");
    
    process_packets();            /* first process normal mail  */
    while (process_arc())         /* process arcmail            */
    {
        process_packets();
    }
    
    if (lastarea!=-1) close_area(); /* close message files */
    display_results();

    for (i=0; i<10; i++) if(pktfile[i]!=NULL) ClosePacket(i);
    
 /* Get rid of all buffers (no way, let the lib take care of that part) */

    if (log) fclose(log);
}   /* end of program */


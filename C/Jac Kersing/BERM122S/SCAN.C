/***************************************************************************
 *  SCAN.C                                                                 *
 *                                                                         *
 *  echomail SCAN utility.                                                 *
 *                                                                         *
 * SCAN is part of the BERMUDA software. BERMUDA is a package of FidoNet   *
 * compatible message/nodelist processing software.                        *
 * Please read LICENSE for information about distribution.                 *
 *                                                                         *
 * Written by Jac Kersing,                                                 *
 * Modifications by Enno Borgsteede and Rinaldo Visscher                   *
 * Modifications by Vincent Pomey and Franck Arnaud                        *
 ***************************************************************************/

/***************************************************************************
 **
 ** Update history:
 **
 ** Till version 0.63:
 **  Conversion of comscan from CP/M to Atari ST.
 ** 
 ** Version 0.63: (release 01/19/89, TB 1.15)
 ** - The maximum day limit has been changed. From 100 days to infinite.
 **
 ** Version 0.64:
 ** - Aka, NODE and BOSS nodes removed. All addresses are ADDRESS.
 ** - Added smart scanning (uses key).
 ** - Added zones and points for message creation
 **
 ** Version 1.00 TB:
 ** - Fixed control-file problem.
 ** - Changed tearline to ComScan vx.xx TB/nn.
 **
 ** Version 1.01 TB:
 ** - Adapted for Mark Williams C
 **
 ** Version 1.02 TB/ST by Enno F. Borgsteede
 ** - Adapted for Turbo C/ST 2.0
 **	- Error in point readressing fixed
 ** - First tries to open .WM then .NM
 **
 ** Version 1.00 BERMUDA SCAN
 ** - Adapted COMSCAN to SCAN
 **************************************************************************/

/*
#pragma warn -sus
#pragma warn -par
*/

#define MAILER              /* needed in PANDORA.H */

#include "pandora.h"        /* for structure of the area's etc. */
#include "mail.h"

#if TC
#include <dos.h>
#include <sys\stat.h>
#endif

#include "scan.pro"
#include "utextra.pro"

#define UVERSION "1.22"     /* Version number of this utility */
#define LASTMOD  __DATE__
#define isBERMUDA       0xA0

#define DEBUG   0              /* Display extended (debugging) info? */

#define MSGSCANNED      0x8000

/*  defines for readmessage         */
#define ENDOFAREA   0       /* no more messages in area */
#define SKIP        1       /* skip this message        */
#define MSGALRIGHT  2       /* message ok               */

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

void Aopen(), Aclose(), cleanEcho(), renumber();

/* Definitions of global variables first */

char progname[]="B-S";      /* program name for logging             */
char *Bpath="";             /* path for config file                 */

char *AreaPath[N_AREAS];    /* path to message area                 */
char *AreaName[N_AREAS];    /* name of area                         */
char *AreaOrig[N_AREAS];    /* the origin line for this area        */
int  *ToZone[N_AREAS];      /* Zone, Net,                           */
int  *ToNet[N_AREAS];       /*            Node and Point            */
int  *ToNode[N_AREAS];      /*    numbers of nodes we're supposed   */
int  *ToPoint[N_AREAS];     /*    to echo messages to..........     */
int  SendTo[50];            /* Send to this node too?               */
int  TZone[50];             /* Temp. storage for addresses          */
int  TNet[50];              /* Zone and Net..                       */
int  TNode[50];             /*               Node                   */
int  TPoint[50];            /*                      Point           */

int  SeenZone[450];         /* Zone...                              */
int  SeenNet[450];          /* adress of nodes that have seen       */
int  SeenNode[450];         /*                         this message */
int  SeenPoint[450];        /*                               Point  */
int  nSeen;                 /* number of Seen-bys                   */
int  PathZone[100];         /* Zone of path..                       */
int  PathNet[100];          /* adresses listed in the               */
int  PathNode[100];         /*                        path line     */
int  PathPoint[100];        /* Ditto                                */
int  nPath;                 /* number of nodes in Path              */
char ThisArea[80];          /* name of this echomail area           */

int  OriginZone;            /* Address this message was created     */
int  OriginNet;             /* Zone and Net                         */
int  OriginNode;            /*              Node                    */
int  OriginPoint;           /*                  Point               */

int  mailarea;              /* number of mailarea                   */
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
int  add_aka=0;             /* number of aliases to add to seen-bys */
int  no_intl=0;
int  binkley=0;
#else
int  add_aka;               /* number of aliases to add to seen-bys */
#endif
int  verbose=6;             /* level for message displaying         */
int  loglevel;              /* level for message logging            */
char *logname;              /* name of logfile                      */
FILE *log;                  /* filepointer for logfile              */
struct _passw *pwd;         /* password pointer                     */

char *ourorigin;            /* line for origin                      */
int  ourzone;               /* zone,                                */
int  ournet;                /*      net and                         */
int  ournode;               /*              node of our BBS         */
int  ourpoint;              /*                 point                */
int  ourpointnet;           /* we've got a pointnet too             */
char ourpwd[10];            /* the password we're using now         */

char *MESSAGE;              /* adress of message buffer (malloced)  */
char *mend;                 /* points to end of the message         */
char *endbody;              /* end of message body WITHOUT seen-bys */
int  mlength;               /* length of message (including seen-by)*/
int  area;                  /* area we're processing                */
int  echomsgs;              /* number of echomsgs created           */
char *origl;                /* points to origin line in message     */
int  use_path;              /* do we wanna use the PATH line?       */
int  use_kludge;            /* we want to use the IFNA kludge?      */
int  use_origin;            /* do we wanna have an origin line??    */
int  use_readdress;         /* readress message (fake from our bbs) */
int  use_packet;            /* scan messages to packets             */
int  use_tiny=0;            /* tiny adresses (ones I'm sending to)  */
int  maxmsgs=1000;          /* max number of echomail messages      */

FILE *HDR;                  /* File pointers for message and header */
FILE *MSG;                  /* files used in creating echomail and  */
FILE *MHDR;                 /* updating the message file            */
FILE *MMSG;

char oldmsg[80];            /* names of the message and header files */
char oldhdr[80];

int  x;                     /* x position in line                   */

struct Hdr hdr;             /* storage for message header           */
struct Hdr Mhdr;            /* storage for outgoing message header  */

int  pktzone;               /* zone, net, node and point            */
int  pktnet;                /* = 4-D address for open packet        */
int  pktnode;               /* used for saving messages to          */
int  pktpoint;
int  pktfake;               /* this is the fakenet we use           */
FILE *pktfile;              /* the packet                           */

/* Ok, so far all definitions. The program is next.. */

void *myalloc(sp)
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

char *ctl_string(string)
char *string;
{
    char *p, *d;
    p=skip_blanks(string);
    d=malloc(strlen(p)+1);
    if(d==NULL)
    {
        message(6,"!Mem error");
        return "";
    }
    strcpy(d,p);
    return d;
}

char *ctl_path(string)
char *string;
{
    char *p, *d, db[80];

    p=skip_blanks(string);
    d=skip_to_blank(string);
    *d='\0';
    if (strlen(p)>78)
    {
        message(6,"!Path too long (%s)",p);
        return "";
    }
    strcpy(db,p);
#if UNIX
    if (db[strlen(db)-1]!='/') strcat(db,"/");
#else
    if (db[strlen(db)-1]!='\\') strcat(db,"\\");
#endif
    return ctl_string(db);
}

init_conf()
{
    FILE *conf;                     /* filepointer for config-file */
    char buffer[256];               /* buffer for 1 line */
    char *p;                        /* workhorse */
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

    if (conf==NULL)   /* open config-file */
    {
        message(6,"!Configuration file not found, please check!!!");
        return 1;                           /* not found, back */
    }

    /* set all to default values */
    
    loglevel=255;
    ourzone=ournet=ournode=0;
    message(-1,"+Parsing configuration file");
       
    while((fgets(buffer, 250, conf)))       /* read a line */
    {
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

#ifdef LINN /* as in pack */
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
#endif

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
        *p=q; *i=(int)temp;
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

getalias(zone,net,node,point)
int zone,net,node,point;
{
    struct _passw *pw;
#ifdef LINN
    int i;
#endif
        
    pw=pwd->next;

#ifdef LINN /* as in pack */
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
#endif
    
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
    struct _passw *pw;
    
    pw=pwd->next;
    
    while (pw!=NULL)
    {
    	/* vp 27 juil 93 : no wildcards for passwords */
       /* no match at all.. (yet) */
        if ((/*pw->zone==-1 ||*/ pw->zone==zone) &&
       /* zone numbers match, now net */
           (/*pw->net==-1 ||*/ pw->net==net) &&
       /* zone and net match.. node also? */
           (/*pw->node==-1 ||*/ pw->node==node) &&
       /* and how about point */
           (/*pw->point==-1 ||*/ pw->point==point))
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

    pwd= (struct _passw *) myalloc(sizeof(struct _passw));
    pwd->zone=pwd->net=pwd->node=pwd->point=0;
    pwd->next=NULL;

    if (init_conf()) exit(2);       /* first parse config file */
    
    use_path=use_origin=use_readdress=1;
    use_kludge=0;

    for (i=1;i<argc;i++)            /* parse commandline arguments */
    {
        if (argv[i][0]=='-')
        {
            switch (toupper(argv[i][1]))
            {
             case 'P': use_packet=1; break; /* output to packet */
#ifdef LINN
             case 'I': use_kludge=1; break; /* ifna kludge */
#else
             case 'K': use_kludge=1; break; /* ifna kludge */
#endif
             case 'Q': verbose=0;    break; /* quiet mode */
/*             case 'S': scan_only=1;  break; /+ tiny subset */
             case 'G': use_path=0;   break; /* no path line */
             case 'T': ++the_box;    break; /* called with logging */
             case 'O': use_origin=0; break; /* no origin line */
             case 'M': maxmsgs=atoi(&argv[i][2]); break;
#ifdef LINN
             case 'D': add_aka = nalias; break;
             case 'N': no_intl = 1;
#endif
             default:  message(6,"!Unknown option %s",argv[i]);
            }
        }
        else strncpy(areasbbs,argv[i],79);
    }

    mailarea=-1;                              /* don't lose msgs in area 0 */

    msgareas=0;
    sprintf(buffer,"%s%s", Bpath, areasbbs);
    if((fd=fopen(buffer, "r"))==NULL)
    {
        message(6,"-Cannot open %s, aborting...",buffer);
        exit(2);
    }

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
        if (msgareas >= N_AREAS) {
            message(6,"!Too many areas, only %d allowed\n", N_AREAS);
            exit(2);
        } 
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
#ifdef LINN
       	if (!stricmp(temp,"PASSTHRU"))
            continue;
#endif
        AreaPath[msgareas]=ctl_string(temp);        /* copy path to area */
        while (isspace(*q)) q++;
        for (p=temp; *q && !isspace(*q); *p++=*q++) ;
        *p=0;
        AreaName[msgareas]=ctl_string(temp);        /* copy name of area */
        while (*q && !isspace(*q)) q++;
#ifdef LINN
        if (!stricmp(AreaName[msgareas],"MAIL"))
#else
        if (!strnicmp(AreaName[msgareas],"MAIL",4))
#endif
        {                                           /* is the mail area? */
            mailarea=msgareas;
            free(AreaName[mailarea]);
            AreaName[mailarea]=ctl_string("* Network");
        }

        i=0;                            /* No destinations (yet)        */

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

        TZone[i]=TNet[i]=TNode[i]=TPoint[i]=0; /* and terminate         */
        i++;

        if (i>1 && stricmp(AreaName[msgareas],"BADMSGS"))
        {
            ToZone[msgareas]= (int *) myalloc(sizeof(int) * i);
            ToNet[msgareas]= (int *) myalloc(sizeof(int) * i);
            ToNode[msgareas]= (int *) myalloc(sizeof(int) * i);
            ToPoint[msgareas]= (int *) myalloc(sizeof(int) * i);
            memmove(ToZone[msgareas],TZone,sizeof(int) * i);
            memmove(ToNet[msgareas],TNet,sizeof(int) * i);
            memmove(ToNode[msgareas],TNode,sizeof(int) * i);
            memmove(ToPoint[msgareas],TPoint,sizeof(int) * i);
        }

#if DEBUG
  print("%s %s",AreaPath[msgareas],AreaName[msgareas]);
  if (i>1 && stricmp(AreaName,"BADMSGS")) for(i=0;ToNet[msgareas][i];i++) print(" %d/%d",ToNet[msgareas][i],
  ToNode[msgareas][i]);
  print("\n");
#endif

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
      
    if (mailarea==-1 && netpath)       /* if mailarea not defined in AREAS.BBS */
    {
        AreaName[msgareas]=ctl_string("* Network");
        AreaPath[msgareas]=ctl_string(netpath);
        mailarea=msgareas++;            /* then use the THE-BOX.CFG one */
    }
    
    if (mailarea==-1 || !AreaPath[mailarea] || !*AreaPath[mailarea])
    {
        message(6,"!Don't know the path to your mailarea..");
        exit(2);
    }

    if ((MESSAGE=malloc(20*1024))==NULL)
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
    
    fseek(MHDR,0l,2);               /* seek to end of mailfile          */
    fseek(MMSG,0l,2);               /* to add echomail (if wanted)      */
}

void Aopen()
{
        sprintf(oldmsg,"%s.MSG",AreaPath[area]);
        if((MSG=fopen(oldmsg, BRUP))==NULL) MSG=fopen(oldmsg, BWUP);
        sprintf(oldhdr,"%s.HDR",AreaPath[area]);
        if((HDR=fopen(oldhdr, BRUP))==NULL) HDR=fopen(oldhdr, BWUP);
        if (!MSG || !HDR)
        {
            message(6,"!Error opening Area file(s)");
            exit(2);
        }
}

char *next_str (p, lookfor)
char *p;
char *lookfor;
{
   extern char *strchr();
   char *found;

#if DEBUG
print ("Look for '%s'\n", lookfor);
#endif

    found=p;
    while (1)
    {
        found = strchr(found, *lookfor);

      /* If we are past the end of the message, then get out */
        if (found == NULL)
        {
#if DEBUG
print("E-O-M\n");
#endif
            return NULL;
        }

#if DEBUG
print ("Match '%20.20s'\n", found);
#endif

        if (strncmp (found, lookfor, strlen(lookfor)))
        {
            ++found;
            continue;
        }
        else
        {
#if DEBUG
print("match OK\n");
#endif
            return found;
        }
    }
}

void GetThem(msg, str, szones, snets, snodes, spoints, tseen)
char *msg;
char *str;
int szones[];
int snets[];
int snodes[];
int spoints[];
int *tseen;
{
    int j, last_net;
    char *p,*q,*r;

    last_net = -1;
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
                        snets[*tseen]=ournet;
                        snodes[*tseen]=ournode;
                    }
                }
#if DEBUG
print ("Got %d:%d/%d.%d\n", szones[*tseen],snets[*tseen],
        snodes[*tseen],spoints[*tseen]);
#endif
                if (*tseen<440)
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

void AddOrigin()
{
        char point[9];
        char tmp[100];
        int  left;

#if DEBUG
print("Adding origin\n");
#endif
        if (ourpoint) sprintf(point,".%d",ourpoint);
        else *point='\0';

        sprint(tmp," * Origin: %%s (%d:%d/%d%s)",ourzone,ournet,ournode,point);
        left=80-(int)strlen(tmp);
#ifdef LINN
 		if (((int)strlen(AreaOrig[area]))>left) AreaOrig[area][left-1]='\0';
        sprint(mend,"\n\n--- Bermuda v%s\n",UVERSION);
#else
        if (strlen(AreaOrig[area])>left) AreaOrig[area][left-1]='\0';
        sprint(mend,"\n--- Bermuda v%s\n",UVERSION);
#endif
        while (*mend) ++mend;
        sprint(mend,tmp,AreaOrig[area]);
        while (*mend) ++mend;
        *mend=0;
}

/* I've seen better sort algoritmes, so do you undoubtely, but this one works
   alright and for these small numbers it doesn't matter.
 */

void SortThem(zones,nets,nodes,points,nr,chpoints)
int zones[],nets[], nodes[], points[], *nr, chpoints;
{
    register int i, i1, left=0, right=(*nr)-1, temp=0;
    int ne1,ne2,no1,no2,p1,p2;

#if DEBUG
print("start sorting now....\n");
#endif
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
#if DEBUG
print("Left: %d        Right: %d\n",left,right);
#endif
    }
    while (left<right);

#if DEBUG
print("Sorted.\n");
#endif    

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
#if DEBUG
print("Original: %d      Now: %d\n", i,i1);
#endif
}

void CheckSeen()
{
    int i, fo, found, k, what;
    
    i= fo= found= 0;

    while (ToZone[area][i] || ToNet[area][i])
    {
#if DEBUG
print("Check for send to %d:%d/%d.%d\n",ToZone[area][i],ToNet[area][i],
        ToNode[area][i],ToPoint[area][i]);
#endif
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
#if DEBUG
print("Should send message to:");
#endif
    i=-1;
    while (++i, ToNet[area][i]||ToNode[area][i])
    {
        if (!SendTo[i]) continue;
#if DEBUG
print("%d:%d/%d.%d  ",ToZone[area][i],ToNet[area][i],
        ToNode[area][i],ToPoint[area][i]);
#endif
        SeenZone[nSeen]=ToZone[area][i];
        SeenNet[nSeen]=ToNet[area][i];
        SeenNode[nSeen]=ToNode[area][i];
        SeenPoint[nSeen++]=ToPoint[area][i];
    }
#if DEBUG
print("\nSort now..");
#endif
    SortThem(SeenZone,SeenNet,SeenNode,SeenPoint,&nSeen,1);

#if DEBUG
print("\nCreating message to ");
#endif
    i=-1;
    while (++i, ToNet[area][i]||ToNode[area][i])
    {
        if (!SendTo[i]) continue;
#if DEBUG
print("%d:%d/%d.%d ",ToZone[area][i],ToNet[area][i],
        ToNode[area][i],ToPoint[area][i]);
#endif
        what= ((ToPoint[area][i]) ? POINTS : 0) |
               (use_tiny ? LOCALS:OTHERS);
        writemessage(use_packet ? SCANFILE : OUTBOUND,what,
             ToZone[area][i],ToNet[area][i],ToNode[area][i],ToPoint[area][i]);
    }
#if DEBUG
print("\n");
#endif    
}

void PurgeBlanks()           /* delete trailing blanks */
{
    char *p;
    
   /* point p at end of message */
    p=mend;
   /* if it's the trailing '\0' then skip it. */
    if (p>MESSAGE && *p==0) --p;
   /* back till begin of message or any non blank */
    while (p>MESSAGE && isspace(*p)) --p;
   /* p points to valid char now (non blank) so increment by one */
    *(++p)='\0';
    mend=p;
}

/* keep in memory the name of the posters */
struct Scanned {
	char from[36];
	struct Scanned *next;
} *scan_start=NULL, *scan_cur, *scan_tmp;

void CheckEcho()
{
    int i;
    
   /* first check if msg valid for sending. */
    if (hdr.flags & SENT ||
        hdr.flags & FILEATCH) return;
    if (next_str(MESSAGE,"\nNOECHO") || next_str(MESSAGE,"\nnoecho")) return;
  
   /* Get the seen-bys (deletes the lines..) */
    nSeen=0;
    GetThem(MESSAGE, "\n\01SEEN-BY:", SeenZone, SeenNet, SeenNode,
            SeenPoint, &nSeen);
    GetThem(MESSAGE, "\nSEEN-BY:", SeenZone, SeenNet, SeenNode,
            SeenPoint, &nSeen);

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

#if DEBUG
print("Message SEEN-BY:");
for (i=0;i<nSeen;i++) print(" %d:%d/%d.%d",SeenZone[i],SeenNet[i],
     SeenNode[i],SeenPoint[i]);
print("\n");
#endif
    
   /* get the path, not restored if not in use (get rid of line anyway..) */
    nPath=0;
    GetThem(MESSAGE, "\n\01PATH:", PathZone, PathNet, PathNode,
            PathPoint, &nPath);
#if DEBUG
print("Message PATH:");
for (i=0;i<nPath;i++) print(" %d:%d/%d.%d",PathZone[i],PathNet[i],
        PathNode[i],PathPoint[i]);
print("\n");
#endif
    
   /* Get rid of all trailing blanks now. */
    PurgeBlanks();

   /* Check if we've got an origin-line already (and add if not and we use one) */
    if (use_origin)
    {
        if (next_str(MESSAGE,"\n * Origin:")==NULL) AddOrigin();
    }
    endbody=mend;   /* message body ends HERE */
    
   /* Now check for nodes to send the message to (and send those msgs) */
    CheckSeen();
    
   /* Flag message as scanned */
    hdr.mailer[7] |= MSGSCANNED;
#ifdef LINN
    /* for compatibility with other scanners */
    hdr.flags |= SENT;
    
	if (scan_start) {
		scan_cur->next=malloc (sizeof(struct Scanned));
		scan_cur=scan_cur->next;
	} else {
		scan_start=malloc (sizeof(struct Scanned));
		scan_cur=scan_start;
	}
	scan_cur->next=NULL;
	strcpy (scan_cur->from, hdr.from);
#endif
}

readmessage()
{
    *MESSAGE=0;
    if (fread((char *) &hdr, sizeof(struct Hdr), 1, HDR)!=1) return ENDOFAREA;
    
    if (hdr.flags & DELETED) return SKIP;
    if ((hdr.flags & KILLSEND) && (hdr.flags & SENT)) return SKIP;
    if (hdr.mailer[7] & MSGSCANNED) return SKIP;
    
    fseek(MSG,hdr.Mstart,0);
    if (fread(MESSAGE, hdr.size, 1, MSG)!=1)
    {
        message(6,"!Error reading message from file");
        return SKIP;
    }
    endbody=mend= MESSAGE + (hdr.size-1);
    return MSGALRIGHT;
}

void add(p) char *p;
{       while (*p)
        {       *mend++=*p++;
                x++;
        }
}

void AddThem(addstr,zones,nets,nodes,points,nr,dopoints,dozones)
char *addstr;
int zones[], nets[], nodes[], points[], nr, dopoints, dozones;
{
    int lastnet, i, len, tnet, tnode;
    char str[20];
    
    x=100;
    lastnet=-1;
    for(i=0; i<nr; i++)
    {
        if (zones[i]!=ourzone)
        {
            if (dozones)
            {
                tnet=-1;
                sprintf(str," %d:%d/%d.%d",zones[i],nets[i],nodes[i],points[i]);
            }
            else *str=0;
        }
        else
        {
#if DEBUG
print("%d/%d.%d -> ",nets[i],nodes[i],points[i]);
#endif
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

            if (lastnet==tnet) sprintf(str," %d",tnode);
            len=(int)strlen(str);
            if (lastnet!=tnet || (len+x > 76))
                sprintf(str," %d/%d",tnet,tnode);
        }
        len=(int)strlen(str);
        if (len+x >76)
        {
            x=0;
            add(addstr);
        }
#if DEBUG
print("%s\n",str);
#endif
        add(str);
        lastnet=tnet;
    }
    *mend=0;
}

void AddSeen(what)
int what;
{
    char sline[20];
    int i;

    sprintf(sline, "\n%sSEEN-BY:", use_kludge ? "\01" : "");
    if (what&LOCALS)
    {
        for (i=0; ToNet[area][i]|ToNode[area][i]; ++i);
        AddThem(sline,*ToZone,*ToNet,*ToNode,*ToPoint,i,	/* added '*', VP */
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

    AddThem("\n\01PATH:",PathZone,PathNet,PathNode,PathPoint,nPath+th,-1,0);
}

void OpenPacket(zone,net,node,point)
int zone, net, node, point;
{
    struct time t;
    struct date d;
    struct _pkthdr phdr;
    char fname[80];
    int  i;

#if DEBUG
print("Open packet %d:%d/%d.%d\n",zone,net,node,point);
#endif
    /* Get password first before all information is destroyed */
    get_passw(zone,net,node,point);
#ifdef LINN /* as in pack */
    getalias(zone,net,node,point);
#endif

    /* save the 4-D address first */
    pktzone= zone;
    pktnet= net;
    pktnode= node;
    pktpoint= point;

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
                pktfake = net;
                break;
            }
        }
        if (point)
        {
            message(6,"!Can't scan for points of other BBSes!");
            exit(2);
        }
    } else {
    	pktfake = 0;
    }

	/* try to open existing files, first .WM then .NM */

#ifdef LINN
    /* how boring ... */
    if (binkley) {
       if (zone==alias[0].zone) {
         sprint(fname, "%s%03z%03z00.HPT", hold, net, node);
         pktfile=fopen(fname, BRUP);
         if (pktfile == NULL) {
	    sprint(fname, "%s%03z%03z00.OPT", hold, net, node);
    	    pktfile=fopen(fname,BRUP);
    	 }
       } else {
         sprint(fname, "%s.%03y%c%03z%03z00.HPT", holdbink, zone, DIRSEP, net, node);
         pktfile=fopen(fname, BRUP);
         if (pktfile == NULL) {
	    sprint(fname, "%s.%03y%c%03z%03z00.OPT", holdbink, zone, DIRSEP, net, node);
    	    pktfile = fopen(fname,BRUP);
    	 }
       }
    } else {
       sprint(fname, "%s%02z%03z%03z.WM", hold, zone, net, node);
       pktfile = fopen(fname,BRUP);
       if (pktfile == NULL) {
	    sprint(fname, "%s%02z%03z%03z.NM", hold, zone, net, node);
    	    pktfile = fopen(fname,BRUP);
       }
    }
#else
    sprint(fname, "%s%02z%03z%03z.WM", hold, zone, net, node);
    pktfile = fopen(fname,BRUP);
    if (pktfile == NULL) {
	    sprint(fname, "%s%02z%03z%03z.NM", hold, zone, net, node);
    	pktfile = fopen(fname,BRUP);
    }
#endif

    if (pktfile!=NULL)
    {
        fseek(pktfile,-2L,2);
        return;
    }

    pktfile= fopen(fname,BWUP);
    if (pktfile==NULL)
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
    if( fwrite((char *)&phdr, sizeof(struct _pkthdr), 1, pktfile) !=1)
    {
        message(6,"-Write error (disk full??)");
        exit(1);
    }
}

void ClosePacket()
{
#if DEBUG
print("Close packet\n");
#endif
    if (pktfile)
    {
        pktzone= pktnet= pktnode= pktpoint= 0;
        if (fwrite("\0\0", 2, 1, pktfile)!=1)
        {
            message(6,"!Error writing to package");
            exit(1);
        }
        fclose(pktfile);
    }
}

void MakeHdr(Mhdr)
struct Hdr *Mhdr;
{
    struct _pktmsgs mh;
    
#if DEBUG
print("MakeHdr\n");
#endif
    mh.pm_ver=inteli(2);
    mh.pm_onode=inteli(Mhdr->Onode);
    mh.pm_onet=inteli(Mhdr->Onet);
    mh.pm_dnode=inteli(Mhdr->Dnode);
    mh.pm_dnet=inteli(Mhdr->Dnet);
    mh.pm_attr=inteli(Mhdr->flags&0x3413);
    mh.pm_cost=inteli(Mhdr->cost);
    fwrite((char *)&mh, sizeof(struct _pktmsgs), 1, pktfile);
    fprintf(pktfile,"%19s",Mhdr->time);
    putc('\0',pktfile);
    fprintf(pktfile,"%s",Mhdr->to);        /* from & to */
    putc('\0',pktfile);
    fprintf(pktfile,"%s",Mhdr->from);
    putc('\0',pktfile);
    fprintf(pktfile,"%s",Mhdr->topic);     /* topic */
    putc('\0',pktfile);

#ifdef LINN
    if (no_intl)
#endif
    if (Mhdr->Ozone && Mhdr->Dzone && (Mhdr->Ozone!=Mhdr->Dzone))
        fprintf(pktfile,"\01INTL %d:%d/%d %d:%d/%d\r\n", Mhdr->Dzone,
          Mhdr->Dnet, Mhdr->Dnode, Mhdr->Ozone, Mhdr->Onet, Mhdr->Onode);
}

void PktWrite(str, len)
char *str;
int len;
{
#if DEBUG
print("PktWrite\n");
#endif
    while (len--)
    {
        if (*str=='\n') putc('\r',pktfile);
        else putc(*str,pktfile);
        str++;
    }
    if (ferror(pktfile))
    {
        message(6,"!Error writing to packet-file");
        exit(1);
    }
}

void writehdr()
{
    fflush(HDR);
    fseek(HDR, ftell(HDR) - sizeof(struct Hdr), 0);
    if (fwrite((char *) &hdr, sizeof(struct Hdr), 1, HDR)!=1)
    {
        message(6,"!Fatal error writing to %s",oldhdr);
        exit(1);
    }
    fflush(HDR);
    fseek(HDR,ftell(HDR),0);
}

void writemessage(where,what,zone,net,node,point)
int where;
int what;
int zone,net,node,point;
{
    int i;
    char sline[20];

#ifdef LINN
    getalias (zone, net, node, point);
#endif
    mend=endbody;
    if (what)
    {
        if (zone!=ourzone) 
        {
            int z[3],ne[3],no[3],p[3],i;
            
            i=2;
            z[0]=ourzone; z[1]=ourzone;
            ne[0]=ournet; ne[1]=net;
            no[0]=ournode; no[1]=node;
            p[0]=ourpoint; p[1]=0;
            SortThem(z,ne,no,p,&i,1);
            sprintf(sline, "\n%sSEEN-BY:", use_kludge ? "\01" : "");
            AddThem(sline,z,ne,no,p,2,1,1);
        }
        else AddSeen(what);
        if (use_path) AddPath(zone!=ourzone);

        if (use_readdress)
        {
            hdr.Ozone = ourzone;
            hdr.Onet  = ournet;
            hdr.Onode = ournode;
            hdr.Opoint= ourpoint;
            if (ourpoint)
            {
                hdr.Onet= ourpointnet;
                hdr.Onode= ourpoint;
                hdr.Opoint=0;
            }
        }
    }
    switch (where)
    {
      case OUTBOUND: memmove((char *) &Mhdr, (char *) &hdr, sizeof(struct Hdr));
                    Mhdr.Mstart= ftell(MMSG);
                    if (what)
                    {
                        ++echomsgs;
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
                    if (fwrite((char *) &Mhdr, sizeof(struct Hdr), 1, MHDR)!=1)
                    {
                        message(6,"!Fatal error writing to mail");
                        exit(1);
                    }
                    if (fwrite(MESSAGE, ((mend-MESSAGE)+2), 1, MMSG)!=1)
                    {
                        message(6,"!Fatal error writing to mail");
                        exit(1);
                    }
                    break;
      case SCANFILE: memmove((char *) &Mhdr, (char *) &hdr, sizeof(struct Hdr));
                    if (zone!=pktzone || net!=pktnet || node !=pktnode ||
                        point!=pktpoint)
                    {
                        ClosePacket();
                        OpenPacket(zone,net,node,point);
                    }
                    *mend++='\n';
                    *mend='\0';
                    if (point) {
                    	net = pktfake;
                    	node = pktpoint;
                    	point = 0;
                    }
                    Mhdr.Dzone = zone;
                    Mhdr.Dnet  = net;
                    Mhdr.Dnode = node;
                    Mhdr.Dpoint= point;
                    Mhdr.flags |= (MSGLOCAL);
                    Mhdr.cost=0;
                    MakeHdr(&Mhdr);
                    if (what)
                    {
                        ++echomsgs;
                        PktWrite(ThisArea, (int)strlen(ThisArea));
                    }
                    PktWrite(MESSAGE, ((int)(mend-MESSAGE)+1));
                    break;
      default:      message(6,"?Don't know how to handle %02x in messagewrite",where);
    }
}

void cleanEcho()
{       int current,i;
        int msgok;

        current=0;

        sprint(ThisArea, "%sAREA:%s\n", (use_kludge?"\01":""), AreaName[area]);

#if DEBUG
if (echoarea) print("AreaID: %s\n",ThisArea);
#endif

        getalias(ToZone[area][0],ToNet[area][0],ToNode[area][0],
                        ToPoint[area][0]);
        i=0;
        while (ToZone[area][i]||ToNet[area][i]||ToNode[area][i])
        {
            ++i;
        }
        SortThem(ToZone[area],ToNet[area],ToNode[area],ToPoint[area],&i,0);

        i = echomsgs;

        while (msgok=readmessage(), msgok!=ENDOFAREA)
        {
                if (msgok!=SKIP)
                {
                        if (echomsgs<maxmsgs)
                        {
                                CheckEcho();

                                /* signal this one has been scanned */
                                writehdr();
                        }
                }
                current++;
        }
        if (verbose) print("%d message(s), %d new\n",current,echomsgs-i);
}

void Aclose()
{
        fclose(HDR);
        fclose(MSG);
}

void LogScanned()
{
	scan_cur=scan_start;
	while (scan_cur) {
	    message(3,"*Scanned a message from %s to %s", scan_cur->from, AreaName[area]);
	    scan_tmp=scan_cur;
	    scan_cur=scan_cur->next;
	    free(scan_tmp);
	}
	scan_start=NULL;
}

void deinitialize()
{
        if (pktzone!=0 || pktnet!=0 || pktnode!=0 ||
            pktpoint!=0) ClosePacket();
        if (verbose)
        {
                print("\n");
                message(1,"+%d echomail message(s) created\n\n",echomsgs);
        }
}

main(argc, argv)
int argc;
char *argv[];
{
    fprintf(stderr,
     "BERMUDA : FidoNet compatible message processing software\n");
    fprintf(stderr,
     "SCAN utility ; Version %s created %s at %s\n\n",UVERSION,
     __DATE__,__TIME__);
    fflush(stderr);

    init(argc, argv);
    for (area=0;area<msgareas;area++)
    {
        if (area!=mailarea && ToZone[area] != NULL)
        {
            if (verbose)
                print("Processing ECHO area %25.25s : ",AreaPath[area]);

            Aopen();        /* open the current area    */
            cleanEcho();    /* delete and scan messages */
            Aclose();       /* close the current area   */
            LogScanned();
        }
    }
    deinitialize();
    return 0;
}


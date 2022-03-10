/**************************************************************************
 *  ROUTE.C                                                               *
 *                                                                        *
 *  Proces route information for BERMUDA-P.                               *
 *                                                                        *
 * Written by Jac Kersing                                                 *
 **************************************************************************/
 
#define MAILER              /* needed in PANDORA.H */
#include "pandora.h"        /* for structure of the area's etc. */

/*#pragma warn -rng*/

#if TC
#include <dos.h>
#endif

#include "patmat.pro"
#include "route.pro"
#include "utextra.pro"

#define DEBUG    0          /* show debugging info? */

#if MEGAMAX || MWC
char    *malloc(), *realloc();
#endif

#define STRING      0
#define ARCMAIL     1
#define ROUTE_TO    2
#define NO_ROUTE    3
#define FORWARD_FOR 4
#define TO          5
#define NODE        6
#define IF          7
#define REDIRECT    8
#define HOLD        9
#define POLL        10
#ifdef LINN
#define NOHOLD      11
#define ZIPMAIL     20
#define LZHMAIL     21
#define ZOOMAIL     22
#define ARJMAIL     23
#endif
#define FIRST       0x1000
#define CRASHMAIL   0x2000
#define REQUEST     0x4000
#define KW_FILE     0x8000
#define MASK        0x00ff

struct _route
{
  char node[21];        /* spec for a node */
  int  maxkbfile;       /* maximum number of bytes for files */
  int  flags;
} ;

extern char *skip_blanks();
extern char *skip_to_blank();
extern char *Bpath;
extern struct _aka
       {
        int zone;
        int net;
        int node;
        int point;
        int pointnet;
       } alias[];
extern int nalias;
extern char active[];

FILE *routef;
#ifdef LINN
#define ARC 0
#define ZIP 1
#define ZOO 2
#define LZH 3
#define ARJ 4
struct _arc {
	char *address;	/* node address */
	int  archiveur; /* number of archiver */
} *arc;
#else
char **arc;                     /* pointer to strings with arcmail specs */
#endif
int  maxanode;
int  anode;
struct _route *route;           /* routing info stored here */
int  maxrnode;
int  rnode;
char buffer[255];               /* for parsing of routefile */
char yytext[255];
int token;
int store;
char pattern[10][40];           /* for pattern matcher */


/* The program.... */

int isok(string)
char *string;
{
    char *p;
    char foundcolon=0, foundslash=0;

    for (p= string; *p; p++)
    {
        if (*p==':')
        {
            if (foundcolon) return -1;
            else foundcolon++;
        }
        else if (*p=='/')
        {
            if (foundslash) return -1;
            else foundslash++;
        }
        else if (*p=='.' && p==string) continue;
        else if (isspace(*p)) break;
        else if (*p=='$' && isdigit(*(p+1))) { p++; continue; }
        else if (*p!='*' && *p!='?' && !isdigit(*p)) return -1;
    }
    return (int) (p-string);
}

int yyparse()
{
    int i;
    char *p;
    int ch;

    p= buffer;
    while ((ch=getc(routef))!=EOF && (!isspace(ch) || p==buffer))
    {
        if (!isspace(ch))
        {
            if (ch==';')        /* skip comment */
            {
                while( (ch=getc(routef))!=EOF && ch!='\n' && ch!='\r') ;
                continue;       /* OUTER LOOP !! */
            }
            *p++=ch;
            if (p-buffer > 240)
            {
                message(6,"!String > 240 chars in routefile");
                exit(2);
            }
        }
    }
    if (ch==EOF && p==buffer) return EOF;

    *p='\0';
    p= buffer;
#if DEBUG
message(6," command: %s",p);
#endif
    if (!stricmp(p,"forward-from"))
    {
        return FORWARD_FOR;
    }

    if (!stricmp(p,"to"))
    {
        return TO;
    }

    if (!stricmp(p,"route-to"))
    {
        return ROUTE_TO;
    }
    
    if (!stricmp(p,"no-route"))
    {
        return NO_ROUTE;
    }

    if (!stricmp(p,"ARCMAIL"))
    {
        return ARCMAIL;
    }

#ifdef LINN
    if (!stricmp(p,"ZIPMAIL"))
    {
        return ZIPMAIL;
    }
    
    if (!stricmp(p,"LZHMAIL"))
    {
        return LZHMAIL;
    }
    
    if (!stricmp(p,"ZOOMAIL"))
    {
        return ZOOMAIL;
    }
    
    if (!stricmp(p,"ARJMAIL"))
    {
        return ARJMAIL;
    }
#endif

    if (!stricmp(p,"HOLD"))
    {
        return HOLD;
    }
    
#ifdef LINN
    if(!stricmp(p,"NO-HOLD"))
    {
        return NOHOLD;
    }
#endif

    if (!stricmp(p,"POLL"))
    {
        return POLL;
    }

    if (!stricmp(p,"CRASH"))
    {
        return CRASHMAIL;
    }

    if (!stricmp(p,"FILE"))
    {
        return KW_FILE;
    }
/*
    if (!stricmp(p,"REQUEST"))
    {
        return REQUEST;
    }
*/
    if (!stricmp(p,"IF"))
    {
        return IF;
    }

    if (!stricmp(p,"REDIRECT"))
    {
        return REDIRECT;
    }

    if (!stricmp(p,"ALL"))
    {
        strcpy(yytext,"*");
        return NODE;
    }

    if (!stricmp(p,"ournet"))
    {
        sprint(yytext,"%d:%d/*",alias[0].zone,alias[0].net);
        return NODE;
    }

    if (!stricmp(p,"boss"))
    {
        sprint(yytext,"%d:%d/%d",alias[0].zone,alias[0].net,alias[0].node);
        return NODE;
    }

    if (!stricmp(p,"points"))
    {
        strcpy(yytext,".*");
        return NODE;
    }

    i= isok(p);
    if (i>0)
    {
        strncpy(yytext,p,i);
        yytext[i]= '\0';

        if (strchr("?*$",*yytext) != NULL) return (NODE);
        if (strchr(yytext,'.') != NULL) return NODE;
        if (strchr(yytext,':') != NULL) return NODE;
        if (strchr(yytext,'/') == NULL)
        {
            char buf[80];
            sprint(buf,"%d:%d/%s",alias[0].zone, alias[0].net, yytext);
            strcpy(yytext,buf);
        }
        else
        {
            char buf[80];
            sprint(buf,"%d:%s", alias[0].zone, yytext);
            strcpy(yytext,buf);
        }
        return NODE;
    }

    strcpy(yytext,buffer);
    return STRING;
}

void parse()
{
        token= yyparse();
}

#ifdef LINN
void arcmail(int archiveur)
{
        /* Found ARCMAIL in the input, read nodenumbers next */
        do
        {
                parse();
                if (token==NODE && store)
                {
                        arc[anode].address= malloc(strlen(yytext)+1);
                        if (arc[anode].address==NULL)
                        {
                                message(6,"!Mem error");
                                exit(1);
                        }
                        strcpy(arc[anode].address,yytext);
                        arc[anode].archiveur=archiveur;
                        anode++;
                        if (anode>=maxanode)
                        {
                                maxanode += 1000;
                                arc= realloc(arc, maxanode * sizeof(struct _arc));
                                if (arc==NULL)
                                {
                                        message(6,"!Mem error");
                                        exit(1);
                                }
                        }
                }
        }
        while (token==NODE) ;
}
#else
void arcmail()
{
        /* Found ARCMAIL in the input, read nodenumbers next */
        do
        {
                parse();
                if (token==NODE && store)
                {
                        arc[anode]= malloc(strlen(yytext)+1);
                        if (arc[anode]==NULL)
                        {
                                message(6,"!Mem error");
                                exit(1);
                        }
                        strcpy(arc[anode],yytext);
                        anode++;
                        if (anode>=maxanode)
                        {
                                maxanode += 1000;
                                arc= realloc(arc, maxanode * sizeof(struct _arc));
                                if (arc==NULL)
                                {
                                        message(6,"!Mem error");
                                        exit(1);
                                }
                        }
                }
        }
        while (token==NODE) ;
}
#endif

void addroute(flags)
int flags;
{
        if (!store) return;

        strncpy(route[rnode].node,yytext,20);
        route[rnode].node[20]='\0';
        route[rnode].flags= flags;
        route[rnode].maxkbfile= 0;
        rnode++;
        if (rnode >= maxrnode)
        {
                maxrnode += 1000;
                route=realloc(route, sizeof(struct _route) * maxrnode);
                if (route==NULL)
                {
                        message(6,"!Mem error");
                        exit(1);
                }
        }
}

void route_to()
{
        int flags= ROUTE_TO|FIRST;

        do
        {
                parse();
                if (token==CRASHMAIL) flags |= CRASHMAIL;
                if (token==KW_FILE) flags |= KW_FILE;
                if (token==NODE)
                {
                        addroute(flags);
                        flags &= ~FIRST;
                }
        }
        while (token==NODE || token==CRASHMAIL || token==KW_FILE);
}

void no_route()
{
        int flags= NO_ROUTE;

        do
        {
                parse();
                if (token==CRASHMAIL) flags |= CRASHMAIL;
                if (token==KW_FILE) flags |= KW_FILE;
                if (token==NODE)
                {
                        addroute(flags);
                }
        }
        while (token==NODE || token==CRASHMAIL || token==KW_FILE);
}

void add_hold()
{
        int flags= HOLD;

        do
        {
                parse();
                if (token==NODE)
                {
                        addroute(flags);
                }
        }
        while (token==NODE);
}

void add_poll()
{
        int flags= POLL;

        do
        {
                parse();
                if (token==NODE)
                {
                        addroute(flags);
                }
        }
        while (token==NODE);
}

#ifdef LINN /* ho-hold */
void add_nohold()
{
        int flags= NOHOLD;

        do
        {
                parse();
                if (token==NODE)
                {
                        addroute(flags);
                }
        }
        while (token==NODE);
}
#endif

void forward()
{
        int flags= FORWARD_FOR;

        do
        {
                parse();
                if (token==CRASHMAIL) flags |= CRASHMAIL;
                if (token==KW_FILE) flags |= KW_FILE;
                if (token==TO) flags= TO | (flags & ~MASK);
                if (token==NODE)
                {
                        addroute(flags);
                }
        }
        while (token==NODE || token==CRASHMAIL || token==TO || token==KW_FILE);
}

void if_ok()
{
        /* Found IF in the input, check for tag next */
        parse();

        if (token!=STRING)
        {
            message(6,"!Invalid TAG");
            return;
        }

        store= !stricmp(yytext,active);
        parse();
}

void redirect()
{
        /* found redirect in input, now store nodes */
        int flags= REDIRECT|FIRST;

        do
        {
                parse();
                if (token==CRASHMAIL) flags |= CRASHMAIL;
                if (token==NODE)
                {
                        addroute(flags);
                        flags &= ~FIRST;
                }
        }
        while (token==NODE || token==CRASHMAIL);
}

int parse_route()
{
    sprintf( buffer, "%sbermuda.rte", Bpath);
    routef= fopen(buffer,"r");
    
    if (routef == NULL)
    {
        sprintf( buffer, "%stb.rte", Bpath);
        routef = fopen(buffer,"r");
    }

    if (routef==NULL)
    {
        message(6,"!Can not find ROUTE file, please check!!");
        exit(2);
    }
    
    arc=malloc(1000 * sizeof(struct _arc));
    maxanode=1000;
    anode=0;

    if (arc==NULL)
       {
           message(6,"!Mem error");
           exit(1);
       }

    route=malloc(1000 * sizeof(struct _route));
    maxrnode= 1000;
    rnode= 0;

    store= 1;

    parse();
    while (token != EOF)
    {
        switch(token)
        {
#ifdef LINN
         case NOHOLD  : add_nohold(); break;
         case ARCMAIL : arcmail(ARC);  break;
         case ZIPMAIL : arcmail(ZIP);  break;
         case LZHMAIL : arcmail(LZH);  break;
         case ARJMAIL : arcmail(ARJ);  break;
         case ZOOMAIL : arcmail(ZOO);  break;
#else
         case ARCMAIL : arcmail();  break;
#endif
         case ROUTE_TO: route_to(); break;
         case NO_ROUTE: no_route(); break;
         case FORWARD_FOR: forward(); break;
         case IF      : if_ok();    break;
         case REDIRECT: redirect(); break;
         case HOLD    : add_hold(); break;
         case POLL    : add_poll(); break;
         default      : printf("Error in %s\n",buffer);
                        parse();
        }
    }
    
    fclose(routef);
    return 0;
}

#ifdef LINN
int ArcOk(zone,net,node)
int zone, net, node;
{
        char buffer[80];
        int i, ret;

        sprint(buffer,"%d:%d/%d",zone,net,node);
        for(i=0; i<nalias; i++)
        {
            if (alias[i].point==0)
            {
                if (alias[i].zone==zone && alias[i].pointnet==net)
                {
                    sprint(buffer,".%d",node);
                }
            }
        }

        ret=-1;
        for (i=0; i<anode; i++)
        {
                if (patmat(buffer,arc[i].address))
			ret=arc[i].archiveur;
        }
        return ret;
}
#else
int ArcOk(zone,net,node)
int zone, net, node;
{
        char buffer[80];
        int i;

        sprint(buffer,"%d:%d/%d",zone,net,node);
        for(i=0; i<nalias; i++)
        {
            if (alias[i].point==0)
            {
                if (alias[i].zone==zone && alias[i].pointnet==net)
                {
                    sprint(buffer,".%d",node);
                }
            }
        }

        for (i=0; i<anode; i++)
        {
                if (patmat(buffer,arc[i])) return 1;
        }
        return 0;
}
#endif

int HoldOk(zone,net,node)
int zone, net, node;
{
        char buffer[80];
        int i;
#ifdef LINN
        int dohold=0;
#endif
        sprint(buffer,"%d:%d/%d",zone,net,node);
        for(i=0; i<nalias; i++)
        {
            if (alias[i].point==0)
            {
                if (alias[i].zone==zone && alias[i].pointnet==net)
                {
                    sprint(buffer,".%d",node);
                }
            }
        }

        for (i=0; i<rnode; i++)
        {
                if (((route[i].flags&MASK)==HOLD) &&
                    patmat(buffer,route[i].node)) 
#ifdef LINN
                    dohold=1;
#else
                    return 1;
#endif
        }

#ifdef LINN
        for (i=0; i<rnode; i++)
        {
                if (((route[i].flags&MASK)==NOHOLD) &&
                    patmat(buffer,route[i].node)) dohold=0;
        }
        return dohold;
#else
        return 0;
#endif
}

int ForwardOk(fromzone,fromnet,fromnode,frompoint,
              tozone,tonet,tonode,topoint,
              crash,file)
int fromzone, fromnet, fromnode, frompoint;
int tozone, tonet, tonode, topoint;
int crash,file;
{
        int i;
        char buffer1[80];
        char buffer2[80];

        /* Should do checking for points (our points!) also */

        sprint(buffer1,"%d:%d/%d",fromzone,fromnet,fromnode);
        if (frompoint)
        {
            for(i=0; i<nalias; i++)
            {
                if (alias[i].point==0 && alias[i].zone==fromzone &&
                    alias[i].net==fromnet && alias[i].node==fromnode)
                {
                    sprint(buffer1,".%d",frompoint);
                }
            }
        }

        sprint(buffer2,"%d:%d/%d",tozone,tonet,tonode);
        if (topoint)
        {
            for(i=0; i<nalias; i++)
            {
                if (alias[i].point==0 && alias[i].zone==tozone &&
                    alias[i].net==tonet && alias[i].node==tonode)
                {
                    sprint(buffer1,".%d",topoint);
                }
            }
        }

        for (i=0; i<rnode; i++)
        {
            if ((route[i].flags&MASK)== FORWARD_FOR)
            {
                if (patmat(buffer1,route[i].node))
                {
                    /* for part matches, now skip rest of for part */
                    for(;i<rnode && (route[i].flags&MASK)==FORWARD_FOR; i++) ;

                    /* AS long we are in the to part check destination */
                    for(;i<rnode && (route[i].flags&MASK)==TO; i++)
                    {
                        if (patmat(buffer2,route[i].node))
                        {
                           /* File attached? Do we fwd files? No -> next */
                           if (file && !(route[i].flags&KW_FILE)) continue;
                           
                           /* crash && forward crash? No -> next */
                           if (crash && (route[i].flags&CRASHMAIL)) return 1;
                           if (!crash && !(route[i].flags&CRASHMAIL)) return 1;
                        }
                    }
                }
            }
        }
        return 0;
}

int match(raw,pat)
char *raw, *pat;
{
        int i;

        for (i=0; i<10; i++)
        {
                pattern[i][0]='\0';
        }
        return match1(raw,pat,1);
}

int match1(raw, pat, level)
char *raw;
char *pat;
int level;
{  int  i ;

   if ((*pat == '\0') && (*raw == '\0'))    /*  if it is end of both  */
     return( 1 ) ;                          /*  strings,then match    */
   if (*pat == '\0')                        /*  if it is end of only  */
     return( 0 ) ;                          /*  pat then mismatch     */
   if (*pat == '*')                         /* if pattern is a '*'    */
   {
        if (*(pat+1) == '\0')               /*    if it is end of pat */
         return( 1 ) ;                      /*    then match          */
        for(i=0;i<=(int)strlen(raw);i++)           /*    else hunt for match */
         if ((*(raw+i) == *(pat+1)) ||       /*         or wild card   */
            (*(pat+1) == '?'))
         {
           strcpy(pattern[level],raw);
           pattern[level][i]='\0';
           if (match1(raw+i+1,pat+2,level+1) == 1) return( 1 ) ;
         }
    }
   else
    { if (*raw == '\0')                     /*  if end of raw then    */
         return( 0 ) ;                      /*     mismatch           */
      if ((*pat == *raw))
        if (match1(raw+1,pat+1,level) == 1)       /*  try & match rest of it*/
           return( 1 ) ;
      if (*pat == '?')
      {
        pattern[level][0]= *raw;
        pattern[level][1]= '\0';
        if (match1(raw+1,pat+1,level+1) == 1) return( 1 ) ;
      }
    }
   return( 0 ) ;                            /*  no match found        */
}

void getid(nr,zone,net,node)
int nr, *zone, *net, *node;
{
    char buffer[80];
    char *p= route[nr].node;
    int i,b;

    if (strchr(p,'.')!=NULL)
    {
        sprint(buffer,"%d:%d/%d",alias[0].zone, alias[0].net, alias[0].node);
    }
    else
    {
        for(b=i=0;i<(int)strlen(p);i++)
        {
            if (p[i]=='$')
            {
                i++;
                strcpy(&buffer[b],pattern[p[i]-'0']);
                while (buffer[b]) b++;
            }
            else buffer[b++]=p[i];
        }
    }
#ifdef LINN
    /* the mysterious bug was here */
    buffer[b]='\0';
#endif

    /* Now the buffer contains an explicit node */
    *zone= alias[0].zone;
    *net= alias[0].net;
    *node= alias[0].node;
    sscanf(buffer,"%d:%d/%d",zone,net,node);
}

void ToWhere(zone, net, node, dzone, dnet, dnode, dpoint, crash, file)
int *zone, *net, *node, dzone, dnet, dnode, dpoint, crash, file;
{
    int i;
    int first;
    char buffer1[80];
    int chk = (crash ? CRASHMAIL : 0) | (file ? KW_FILE : 0);

    *zone= dzone;
    *net= dnet;
    *node= dnode;

    /* Do something for points here too */
    sprint(buffer1,"%d:%d/%d", dzone, dnet, dnode);
    if (dpoint)
    {
        for(i=0; i<nalias; i++)
        {
            if (alias[i].point==0 && alias[i].zone==dzone &&
                alias[i].net==dnet && alias[i].node==dnode)
            {
                sprint(buffer1,".%d",dpoint);
                *net = dnet = alias[i].pointnet;
                *node= dnode = dpoint;
                break;
            }
        }
    }

    for (i=0; i<rnode; i++)
    {
        if ((route[i].flags&MASK)==ROUTE_TO)
        {
            for (;i<rnode && (route[i].flags&MASK)==ROUTE_TO; i++)
            {
                if (route[i].flags&FIRST) first=i;
                if (chk != (route[i].flags&(CRASHMAIL|KW_FILE))) continue;
                if (match(buffer1,route[i].node)) getid(first,zone,net,node);
            }
        }
        if ((route[i].flags&MASK)==NO_ROUTE)
        {
            if (patmat(buffer1,route[i].node))
            {
                if (chk != (route[i].flags&(CRASHMAIL|KW_FILE))) continue;
                *zone= dzone;
                *net= dnet;
                *node= dnode;
            }
        }
    }
}

void ReDirectTo(zone, net, node, dzone, dnet, dnode, crash)
int *zone, *net, *node, dzone, dnet, dnode, crash;
{
    int i;
    int first;
    char buffer1[80];
    int chk = crash ? CRASHMAIL : 0;

    /* Do something for points here too */
    sprint(buffer1,"%d:%d/%d", dzone, dnet, dnode);
    for(i=0; i<nalias; i++)
    {
        if (alias[i].point==0)
        {
            if (alias[i].zone==dzone && alias[i].pointnet==dnet)
            {
                sprint(buffer1,".%d",dnode);
            }
        }
    }

    *zone= dzone;
    *net= dnet;
    *node= dnode;

    for (i=0; i<rnode; i++)
    {
        if ((route[i].flags&MASK)==REDIRECT)
        {
            for (;i<rnode && (route[i].flags&MASK)==REDIRECT; i++)
            {
                if (route[i].flags&FIRST) first=i;
                if (chk != (route[i].flags&CRASHMAIL)) continue;
                if (match(buffer1,route[i].node)) getid(first,zone,net,node);
            }
        }
    }
}

char *PollNode(start)
int *start;
{
        int i;

        for (i=(*start)+1; i<rnode; i++)
        {
                if (route[i].flags==POLL)
                {
                        *start= i;
                        return route[i].node;
                }
        }
        return NULL;
}


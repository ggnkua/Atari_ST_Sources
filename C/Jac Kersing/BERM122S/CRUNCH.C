/*************************************************/
/*               CRUNCH utility                  */
/*                                               */
/* Delete old messages in a Pandora message base */
/*                                               */
/*  Written by Vincent Pomey, 30 july 1992       */
/*    with parts of Jac Kersing's code           */
/*                                               */
/*************************************************/

#define MAILER              /* needed in PANDORA.H */

#include "pandora.h"        /* for structure of the area's etc. */

#include "utextra.pro"
#include "crunch.pro"

#define UVERSION "1.22"     /* Version number of this utility */
#define LASTMOD  __DATE__
#define BUFFERSIZ 100L         /* size in kbyte of the buffer	     */
#define MAXINT    32500

#define DEBUG   0              /* Display extended (debugging) info? */
#define LED
#define QBBS
/* Definitions of global variables first */

typedef unsigned long ulong;

char progname[]="B-C";      /* program name for logging             */
char *Bpath="";             /* path for config file                 */

char *AreaPath[N_AREAS];    /* path to message area                 */
char *AreaName[N_AREAS];    /* name of area                         */
struct akeep {
	int days, min, max;
} *AreaKeep[N_AREAS], DefKeep;
#ifdef LED
int  *AreaLed, *AreaLedFlags;
char *ledfile;
#endif

int  msgareas;              /* number of messageareas               */
int  verbose=6;             /* level for message displaying         */
int  loglevel;              /* level for message logging            */
char *logname;              /* name of logfile                      */
char *netpath=NULL;         /* path to netmail area                 */
FILE *log;                  /* filepointer for logfile              */
#ifdef QBBS
FILE *qbbs;
#endif
#ifdef LED
FILE *led;           /* lastread pointers for QuickBBS and Led */
#endif

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

void sprintb(char *b, char *f, char *n)
{
	if (n[strlen(n)-1]!=DIRSEP) {
		strcpy (b, n);
#ifdef UNIX
		strcat (b, "/");
#else
		strcat (b, "\\");
#endif
		strcat (b, f);
	} else {
		strcpy (b, n);
		strcat (b, f);
	}
}

int init_conf(void)
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

        if (!strnicmp(buffer,"netmail",7))
        {
            netpath=ctl_string(&buffer[7]);
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
    }    
    fclose(conf);
    
    return 0;                           /* signal OK */
}


void init(argc, argv)            /* initialize everything needed */
int argc;                   /* counter */
char *argv[];               /* commandline crap */
{
    int i;                  /* counter */
    char *p, *q;            /* nice pointers.. */
    char buffer[300];       /* to store lines from AREAS.BBS etc. in */
    char temp[80];          /* temp. storage */
    char areasbbs[80];      /* name of file for AREAS.BBS */
    FILE *fd;               /* file descriptor for control and areas.bbs */
    long atol();
    
    strcpy(areasbbs, "areas.bbs");  /* default name */

    if (init_conf()) exit(2);       /* first parse config file */

    DefKeep.days=30;
    DefKeep.min=0;
    DefKeep.max=MAXINT;
    
    for (i=1;i<argc;i++)            /* parse commandline arguments */
    {
        if (argv[i][0]=='-')
        {
            switch (toupper(argv[i][1]))
            {
             case 'D': DefKeep.days=atoi(&argv[i][2]); break;
             case 'M': DefKeep.min =atoi(&argv[i][2]); break;
             case 'X': DefKeep.max =atoi(&argv[i][2]); break;
             default:  message(6,"!Unknown option %s",argv[i]);
            }
        }
        else strncpy(areasbbs,argv[i],79);
    }

    for (i=0; i<N_AREAS; i++)
    	AreaKeep[i]=&DefKeep;	/* set the default */

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

    while (fgets(buffer,299,fd))        /* next line                    */
    {
        q=skip_blanks(buffer);
        if (!*q || *q==';') continue;               /* comment line? */
        if (strlen(q)<5) continue;
        if (msgareas >= N_AREAS) {
            message(6,"!Too many areas, only %d allowed\n", N_AREAS);
            exit(2);
        } 
	/* process option lines, and modify the default */
        if (*q=='-')
        {
        	if (!(strnicmp (q+1, "days", 4))) {
        		   AreaKeep[msgareas]=myalloc (sizeof (struct akeep));
                           AreaKeep[msgareas]->min=0;
                           AreaKeep[msgareas]->max=MAXINT;
			   q=skip_blanks(skip_to_blank(q));
                           p=skip_to_blank(q);	/* q : first, p : second */
                           
                           if (*p==0)
	                        AreaKeep[msgareas]->days=atoi(q);
	   		   else {
				*p++=0;
	                        AreaKeep[msgareas]->days=atoi(q);
				while (1) {
		                        p=skip_blanks(p);
		                        if (*p==0)
		                        	break;
					if (!strnicmp (p, "max", 3)) {
						q=skip_blanks(skip_to_blank(p));
						p=skip_to_blank(q);
						if (*p==0) {
							AreaKeep[msgareas]->max=atoi(q);
							break;
						} else {
							*p++=0;
							AreaKeep[msgareas]->max=atoi(q);
						}
					} else if (!strnicmp (p, "min", 3)) {
						q=skip_blanks(skip_to_blank(p));
						p=skip_to_blank(q);
						if (*p==0) {
							AreaKeep[msgareas]->min=atoi(q);
							break;
						} else {
							*p++=0;
							AreaKeep[msgareas]->min=atoi(q);
						}
					}
				} /* while */
                           }
			   continue;
                }
        	if (!(strnicmp (q+1, "msgs", 4))) {
        		   AreaKeep[msgareas]=myalloc (sizeof (struct akeep));
			   q=skip_to_blank(q);
                           q=skip_blanks(q);
                           p= q+strlen(q)-1;
                           while (isspace(*p) || !*p) *p--=0;
			   AreaKeep[msgareas]->max=atoi(q);
			   AreaKeep[msgareas]->days=MAXINT;
			   AreaKeep[msgareas]->min=0;
			   continue;
                }
		continue;
        }
        for (p=temp; *q && !isspace(*q); *p++=*q++) ;
        *p=0;
       	if (!stricmp(temp,"PASSTHRU"))
            continue;

        AreaPath[msgareas]=ctl_string(temp);        /* copy path to area */
        while (isspace(*q)) q++;
        for (p=temp; *q && !isspace(*q); *p++=*q++) ;
        *p=0;
       	if (!stricmp(temp,"MAIL")) {
            netpath=NULL;    /* won't add a netmail area later */
            strcpy (temp, "FidoNetmail");
        }
        AreaName[msgareas]=ctl_string(temp);        /* copy name of area */

#if DEBUG
	printf ("area=%s days=%d min=%d max=%d\n", AreaName[msgareas], AreaKeep[msgareas]->days, AreaKeep[msgareas]->min, AreaKeep[msgareas]->max);
#endif
        ++msgareas;                     /* next area                    */
	if (msgareas==N_AREAS-2) {
	    	message(6,"!More than %d areas, areas.bbs read incomplete", N_AREAS);
	    	break;
	}
    }
    fclose(fd);
    if (netpath != NULL) {
    	/* no netmail area found, use the one of tb.cfg */
    	AreaName[msgareas]=ctl_string("FidoNetmail");
    	AreaPath[msgareas]=netpath;
    	AreaKeep[msgareas]=&DefKeep;
    	++msgareas;
    }

#ifdef QBBS
    qbbs=NULL;
    p=getenv ("QBBS");
    if (p) {
    	sprintb (buffer, "lastread.bbs", p);
    	qbbs=fopen(buffer, BRUP);
    }
#endif
#ifdef LED
    led=NULL;
    p=getenv ("BINKLEY");
    if (p) {
    	sprintb (buffer, "led.new", p);
		led=fopen(buffer, "r");
    }
    if (led==NULL) {
    	p=getenv ("MAILER");
    	if (p) {
		sprintb (buffer, "led.new", p);
		led=fopen(buffer, "r");
	}
    }
    if (led) {
    	AreaLed=myalloc(msgareas*sizeof(int));
    	AreaLedFlags=myalloc(msgareas*sizeof(int));
    	for (i=0; i<msgareas; i++) {
    		AreaLed[i]=AreaLedFlags[i]=0;
    	}
    	while (fgets (temp, 80, led)) {
    		p=skip_to_blank(temp);
    		*p=0;
    		p=skip_blanks(p+1);
    		for (i=0; i<msgareas; i++)
    			if (!strcmp(temp, AreaName[i])) {
    				AreaLed[i]=atoi(p);
    				AreaLedFlags[i]=atoi(skip_blanks(skip_to_blank(p)));
    			}
	}
	ledfile=ctl_string(buffer);
    }
#endif
}

long fsize(f)
FILE *f;
{
	long opos, len;

	opos=fseek(f, 0, SEEK_CUR);
	fseek(f, 0, SEEK_END);
	len=ftell(f);
	fseek (f, opos, SEEK_SET);
	return len;
}

#ifdef QBBS
void qbbs_lr(int *decal, int nummsg, int area)
{
	short blk[200];
	long  pos;
	int   narea, newpos;
	char  *s, *t;

	s=AreaPath[area]; t=s;
	while ((s=strchr(t, '\\')) != NULL)
		t=s+1;
	narea=atoi(t)-1;
	if (narea>200)
		return;
	rewind (qbbs);
	while (!feof(qbbs)) {
		pos=ftell(qbbs);
		if (fread (blk, sizeof(blk), 1, qbbs) != 1)
			return;
		if (blk[narea]>nummsg)
			newpos=nummsg;
		else	newpos=decal[blk[narea]];
		if (blk[narea] != newpos) {
			blk[narea]=newpos;
			fseek (qbbs, pos, SEEK_SET);
			fwrite (blk, sizeof(blk), 1, qbbs);
		}
	}
}
#endif

int main(argc, argv)
int argc;
char *argv[];
{
    char   nam1[100], nam2[100];
    ulong  killdate;
    struct Hdr *hstart, *hcurrent, *hnew;
    int    nummsg, numdel, numkeep, area, maxmsg, minmsg, curmsg, i;
    FILE   *hdr, *msg, *nhdr, *nmsg;
    long   moffset;		/* offset of message buffer in message file */
    char   *mstart, *mcurrent;	/* pointer to message buffer, and free space in buffer */
    long   msize;		/* size of message buffer */
    long   mfree;		/* free size in message buffer */
    long   hsize;		/* size of header buffer */
    long   sav;
    int    totdel=0;		/* total of deleted messages */
    int    *decal;		/* table for updating lastread pointers */
    
    fprintf(stderr,
     "BERMUDA : FidoNet compatible message processing software\n");
    fprintf(stderr,
     "CRUNCH utility ; Version %s created %s at %s\n\n",UVERSION,
     __DATE__,__TIME__);
    fflush(stderr);

    init(argc, argv);

    for (area=0; area<msgareas; area++) {
    	/* open header file file */
    	sprintf(nam1,"%s.HDR",AreaPath[area]);
	hdr = fopen (nam1, BRUP);
	if (hdr == NULL)
		continue;
    	/* read current header file */
	hsize = fsize (hdr);
	hstart = myalloc (hsize);
	if (fread (hstart, 1, hsize, hdr) != hsize) {
	        message(6,"!Read error (header)");
        	exit(1);
	}
	fclose (hdr);
	
    	nummsg=hsize / sizeof (struct Hdr);

    	if (!nummsg)
    		continue;
    		
    	/* first pass to see if there are messages to delete */
    	sav=(long)AreaKeep[area]->days;
    	if (sav > 3000)
    		sav = 3000;
	killdate = time(NULL)-sav*24*60*60;
	minmsg = AreaKeep[area]->min;
	maxmsg = AreaKeep[area]->max;
		
    	hcurrent=hstart+nummsg-1;
    	numdel=numkeep=0;
    	while (nummsg--) {
		if ((!(hcurrent->flags & NOKILL)) && (numkeep >= minmsg) &&
		    ((hcurrent->create < killdate) || (numkeep >= maxmsg)))
			hcurrent->flags |= DELETED;

		if (hcurrent->flags & DELETED)
			numdel++;
    		else	numkeep++;
    		hcurrent--;
    	}
    	
	printf ("%25.25s (%13.13s) : %d message%s deleted.", AreaPath[area], AreaName[area], numdel, (numdel>1) ? "s":"");

    	if (numdel) {
		/* update lastread pointers and reply links */
	    	nummsg=hsize / sizeof (struct Hdr);
		decal=myalloc((nummsg+1)*sizeof(int));
		curmsg=1;
		decal[0]=0;
		for (i=1; i<=nummsg; i++) {
			if (hstart[i-1].flags & DELETED)
				decal[i]=curmsg;
			else	decal[i]=curmsg++;
			if (hstart[i-1].parent >= i)
				hstart[i-1].parent=0;
			hstart[i-1].parent=decal[hstart[i-1].parent];
		}
#ifdef QBBS
		if (qbbs)
			qbbs_lr (decal, nummsg, area);
#endif
#ifdef LED
		if (led)
			AreaLed[area]=(AreaLed[area]>nummsg) ? decal[nummsg] : decal[AreaLed[area]];
#endif
		free (decal);

	    	/* second pass to delete messages */
    		moffset=0;
	    	sprintf(nam1,"%s.MSG",AreaPath[area]);
		msg = fopen (nam1, BRUP);
	    	sprintf(nam1,"%s.H",AreaPath[area]);
		nhdr = fopen (nam1, BWUP);
	    	sprintf(nam1,"%s.M",AreaPath[area]);
		nmsg = fopen (nam1, BWUP);
		
    		/* allocate buffer for messages */
    		msize=BUFFERSIZ*1024L;
		mstart=myalloc(msize);
    		mcurrent=mstart;
		mfree=msize;
    		
	    	nummsg=hsize / sizeof (struct Hdr);
    		hcurrent=hnew=hstart;
	    	while (nummsg--) {
	    		if (!(hcurrent->flags & DELETED)) {
    				/* keep the message */
    				*hnew = *hcurrent;
	    			hnew->Mstart = moffset + (mcurrent - mstart);
    				/* copy the message */
				if (mfree < hnew->size) {
					sav=mcurrent-mstart;
					if (fwrite (mstart, 1, sav, nmsg) != sav) {
						putchar ('\n');
					        message(6,"!Write error (message)");
				        	exit(1);
					}
					mcurrent = mstart;
					mfree = msize;
					moffset += sav;
				}
				fseek (msg, hcurrent->Mstart, SEEK_SET);
				if (fread (mcurrent, 1, hcurrent->size, msg) != hcurrent->size) {
					putchar ('\n');
					message(6,"!Read error (message)");
					exit(1);
				}
				mcurrent += hcurrent->size;
				mfree -= hcurrent->size;
    				hnew++;
	    		}
    			hcurrent++;
	    	}
	    	/* flush the message buffer */
		sav=mcurrent-mstart;
		if (fwrite (mstart, 1, sav, nmsg) != sav) {
			putchar ('\n');
		        message(6,"!Write error (message)");
        		exit(1);
		}
		/* write the new header file */
		sav=hnew-hstart;
		if (fwrite (hstart, sizeof (struct Hdr), sav, nhdr) != sav) {
			putchar ('\n');
			message(6,"!Write error (header)");
        		exit(1);
		}
		free (mstart);
		/* renames the tempo files */
		fclose (msg);
		fclose (nhdr);
		fclose (nmsg);
		sprintf(nam1,"%s.M",AreaPath[area]);
		sprintf(nam2,"%s.MSG",AreaPath[area]);
		remove (nam2);
		rename (nam1, nam2);
		sprintf(nam1,"%s.H",AreaPath[area]);
		sprintf(nam2,"%s.HDR",AreaPath[area]);
		remove (nam2);
		rename (nam1, nam2);
	}
	free (hstart);
	putchar ('\n');
	totdel += numdel;
    }
    message(2,"=Deleted %d messages", totdel);
#ifdef LED
    if (led) {
	fclose (led);
	led=fopen(ledfile, "w");
    	for (area=0; area<msgareas; area++)
		fprintf (led, "%-16s %-4d %d\n", AreaName[area], AreaLed[area], AreaLedFlags[area]);
	fclose (led);
    }
#endif
#ifdef QBBS
    if (qbbs)
    	fclose (qbbs);
#endif
    return 0;
}

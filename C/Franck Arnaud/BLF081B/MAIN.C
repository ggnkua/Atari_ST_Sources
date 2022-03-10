/*
 *	BloufGate
 *	Main driver
 *
 *	Public domain: may be copied and sold freely
 */

#include	"blouf.h"

#define MODENEWS	1
#define MODEMAIL	2
#define MODEFIDO	3
#define MODEMBOX	4
#define MODERMAIL	5
#define MODERNEWS	6

/* Global vars declarations */

#ifdef ATARIST
#ifdef LATTICE
unsigned long _STACK=0x4000;		/* stack size = 16 K */
#endif
#endif

/*
 *	main driver
 *
 *	syntax:	blouf [-c<blouf.ctl>] [-s<site>] -f|-n|-m <files...>
 *	novice:	blouf -fido|-news|-mail <files...>
 */

int main(int argc, char **argv)
{
	int mode, optind;

	char cfgfile[FILENAME_MAX];	/* config file */
	char condit[BLFSTR];		/* conditions */
	char overto[BLFSTR]; 		/* to field */
	char *cond_ptr=NULL;		/* condition pointer */
	FILE *pkt=NULL;				/* packet */
	char *to_env_ptr=NULL; 		/* force to: field */
	int dispflag=0;				/* debug config flag */
	int dupeflag=0;				/* dupe file */

	/* Public Domain notice */
	printf ("%s %s - Public Domain 1991-1993\n\n",ProgName,Version);

	/* config filename */
	if (getenv("BLOUFRC"))
		strcpy(cfgfile, getenv("BLOUFRC"));
	else	
		strcpy(cfgfile,DEFAULT_CONFIG);

	/* init mode */
	mode=-1;
	
	/* parse command line */
	optind=0;
	while( (++optind<argc) && ((*(argv[optind]))=='-') )
	{
		
		if(strlen(argv[optind])>1)
		{
			switch(*(argv[optind]+1))
			{
				case 's':	/* label for config file */
				strcpy(condit,argv[optind]+2);
				cond_ptr=condit;
				break;
				case 't':	/* To: override */
				strcpy(overto,argv[optind]+2);
				to_env_ptr=overto;
				break;
				case 'c':	/* config file */
				strcpy(cfgfile,argv[optind]+2);
				break;
				case 'd':	/* debug */
				dispflag++;
				break;
				case 'f': 	/* -fido|-fug */
				mode=MODEFIDO;
				break;
				case 'm': 	/* -mail */
				if(strcmp(argv[optind],"-mbox")==0)
					mode=MODEMBOX;
				else
					mode=MODEMAIL;
				break;
				case 'n': /* -news */
				mode=MODENEWS;
				break;
				case 'r': /* -rmail|-rnews unix compatible mail */
				if(strcmp(argv[optind],"-rmail")==0)
					mode=MODERMAIL;
				else if(strcmp(argv[optind],"-rnews")==0)
					mode=MODERNEWS;
				break;
			}
		}
	}

	/* read config file */
	printf("Parsing configuration.\n");
	if(readconfig(cfgfile,cond_ptr)==FAIL)
	{
		if(readconfig("blouf.cfg",cond_ptr)==FAIL)
		{
			printf("can't read config file\n");
			return 10;
		}
	}

	/* display config file */
	if(dispflag)
		displayconfig();
	
	/* check mode */
	if(mode<0)
	{
		printf("command line error: missing mode.\n");
		usage();
	}
	else if(mode==MODERNEWS)
	{
		if(!pkt)
			pkt=openpacket();
		if(!dupeflag)
		{
			logline("=Opening dupe checker (%ld)",
				dupechk_open(cf->dupefile[0] ? cf->dupefile : NULL));
			dupeflag++;
		}
		process_news(NULL,pkt);
	}
	else if(mode==MODERMAIL)
	{
		if(!pkt)
			pkt=openpacket();
		process_rfcfile(NULL,pkt,to_env_ptr);
	}
	else
	{
		for(;optind<argc;optind++)
		{
			switch(mode)
			{
				case MODENEWS:
				if(!pkt)
					pkt=openpacket();
				if(!dupeflag)
				{
					logline("=Opening dupe checker (%ld)",
						dupechk_open(cf->dupefile[0] ? cf->dupefile : NULL));
					dupeflag++;
				}
				process_news(argv[optind],pkt);
				break;
				
				case MODEMBOX:
				if(!pkt)
					pkt=openpacket();
				process_mailbox(argv[optind],pkt,to_env_ptr);
				break; /*modembox*/
	
				case MODEMAIL:
				if(!pkt)
					pkt=openpacket();
				if(process_rfcfile(argv[optind],pkt,to_env_ptr)==FAIL)
					logline("?Can't process mail");
				else if(cf->keep==FALSE)
					remove(argv[optind]);
				break; /*modemail*/
	
				case MODEFIDO:
				if(process_packet(argv[optind])==FAIL)
					logline("!Can't process packet");
				break;
			}
		} /*endfor*/
	}

	if(pkt)
		closepacket(pkt);
	
	if(dupeflag) /* close dupechecker if opened */
		dupechk_close();
	cleanconfig(); /* close config */
	
	return 0;
}

/*
 * Prints usage
 */

void usage(void )
{
	printf("\nstandard syntax:\n"
		"  blouf [-c<ctrl-file>] [-s<label>] [-t<to>] [-d] -fido|-news|-mail|-mbox <files...>\n"
		"  -c    : use specified <ctrl-file> instead of default\n"
		"  -t    : <to> will be used instead of mail's To: field\n"
		"  -d    : print parsed config file to stdout\n"
		"  -s    : <label> for conditional control files\n"
		"  -fido : <files> are fidonet packets to convert\n"
		"  -news : <files> are batched news files (not compressed)\n"
		"  -mail : <files> are rfc822 mails\n"
		"  -mbox : <files> are batches of rfc822 mails as in a unix mailbox file\n\n");
	printf("rnews/rmail compatible syntax:\n"
		"  blouf [-c<control-file>] [-s<label>] [-t<to>] -rmail\n"
		"        : file on stdin is rfc822 mail\n"
		"  blouf [-c<control-file>] [-s<label>] -rnews\n"
		"        : file on stdin is batched (uncompressed) news\n");
}

/**/
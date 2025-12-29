/* Menus and command line interface for CLUSTAL V  */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "clustalv.h"


/*
*	Prototypes
*/

extern void 	getstr(char *,char *);
extern double	getreal(char *,double,double);
extern int		getint(char *,int,int,int);
extern void		do_system(void);
extern void		make_pamo(int);
extern int	    readseqs(int);
extern void		get_path(char *,char *);
extern void		show_pair(void);
extern void		upgma(int);
extern void		myers(int);
extern void     phylogenetic_tree(void);
extern void	    bootstrap_tree(void);
extern void		error(char *,...);
extern int              SeqGCGCheckSum(char *, int);


void init_amenu(void);
void parse_params(void);
void main_menu(void);
FILE * open_output_file(char *, char *, char *, char *);
#if UNIX
FILE * open_path(char *);
#endif

static Boolean check_param(char *, char *, char *, int *);
static void get_help(int);			/* Help procedure */
static void pair_menu(void);
static void multi_menu(void);
static void multiple_align_menu(void);          /* multiple alignments menu */
static void profile_align_menu(void);           /* profile       "      "   */
static void phylogenetic_tree_menu(void);       /* NJ trees/distances menu  */
static void read_matrix(void);
static void seq_input(void);
static void align(void);
static void make_tree(void);
static void get_tree(void);
static Boolean user_mat(char *);
static void clustal_out(FILE *);
static void nbrf_out(FILE *);
static void gcg_out(FILE *);
static void phylip_out(FILE *);
static Boolean open_alignment_output(char *);
static void create_alignment_output(void);
static void reset(void);
static void profile_input(int);   		/* DES read a profile */
static void format_options_menu(void);          /* format of alignment output */
static void profile_align(void);                /* Align 2 alignments */

/*
*	 Global variables
*/

char *lin1, *lin2, *lin3;

extern char *amino_acid_order;
extern char *nucleic_acid_order;
extern void *ckalloc(size_t);
extern Boolean		percent,is_weight,dnaflag;
extern int		wind_gap,ktup,window,signif;
extern int               dna_wind_gap, dna_ktup, dna_window, dna_signif;
extern int              prot_wind_gap,prot_ktup,prot_window,prot_signif;
extern unsigned int boot_ran_seed;
extern int      gap_open,      gap_extend;
extern int  dna_gap_open,  dna_gap_extend;
extern int prot_gap_open, prot_gap_extend;
extern int boot_ntrials;		/* number of bootstrap trials */
extern int		xover,big_pam;
extern char *params;
extern char		seqname[],treename[];
extern char     *matptr,pam100mt[],pam250mt[],idmat[];
extern int		nseqs,nblocks;
extern int 		weights[21][21];
extern FILE *	tree;
extern FILE *clustal_outfile, *gcg_outfile, *nbrf_outfile, *phylip_outfile;
extern char **	names, **titles;
extern int *seqlen_array;
extern char **seq_array;
extern char ntrials;		/* number of bootstrap trials (trees.c) */

Boolean usemenu;
char mtrxnam[FILENAMELEN+1];
Boolean explicit_dnaflag;  /* Explicit setting of sequence type on comm.line*/
Boolean output_clustal, output_nbrf, output_phylip, output_gcg;
Boolean empty;
Boolean profile1_empty, profile2_empty;   /* whether or not profiles   */
int profile1_nseqs;	       /* have been filled; the no. of seqs in prof 1*/
Boolean tossgaps, kimura;
int  matnum;
static char clustal_outname[FILENAMELEN+1], gcg_outname[FILENAMELEN+1];
static char  phylip_outname[FILENAMELEN+1],nbrf_outname[FILENAMELEN+1];

static char *pam_matrix_name[] = {
		"PAM 100",
		"PAM 250",
		"Identity matrix",
		"user defined"   };
		
char usermat[210];

void init_amenu()
{
	matnum=2;
	empty=TRUE;
	explicit_dnaflag = FALSE;     
    profile1_empty=TRUE;     /* DES */
    profile2_empty=TRUE;     /* DES */
	output_clustal = TRUE;
	output_gcg     = FALSE;
	output_phylip  = FALSE;
	output_nbrf    = FALSE;

    lin1 = (char *)ckalloc( (MAXLINE+1) * sizeof (char) );
    lin2 = (char *)ckalloc( (MAXLINE+1) * sizeof (char) );
    lin3 = (char *)ckalloc( (MAXLINE+1) * sizeof (char) );
}




static Boolean check_param(char *paramstr, char *probe, char *arg, int *len)
{
	int i,j,k,paramlen;
	char testarg[80];

	paramlen = strlen(paramstr);
	i = 1;
	while(i < paramlen) {
		for(j=i+1; j<=paramlen      &&
			paramstr[j] != '/'  &&
			paramstr[j] != EOS; j++) ;
		for(k=i+1; k<j; k++)
			if(paramstr[k] == '=') {
			   	strncpy(testarg,&paramstr[i],k-i);
				if(!strncmp(testarg,probe,k-i)){
					strncpy(arg,&paramstr[k+1],j-k-1);
					arg[j-k-1] = EOS;
					*len = strlen(arg);
					return TRUE;
				}
			}
		strncpy(testarg,&paramstr[i],j-i);
		if(!strncmp(testarg,probe,j-i)) {
			*len = 0;
			arg[0] = EOS;
			return TRUE;
		}
		i = j + 1;
	}
	return FALSE;
}



 
#if UNIX
FILE *open_path(char *fname)  /* to open in read-only file fname searching for 
				 it through all path directories */
{
#define Mxdir 70
        char dir[Mxdir+1], *path, *deb, *fin;
        FILE *fich;
        int lf, ltot;
 
        path=getenv("PATH"); 	/* get the list of path directories, 
					separated by :
    				*/
        if (path == NULL ) return fopen(fname,"r");
        lf=strlen(fname);
        deb=path;
        do
                {
                fin=strchr(deb,':');
                if(fin!=NULL)
                        { strncpy(dir,deb,fin-deb); ltot=fin-deb; }
                else
                        { strcpy(dir,deb); ltot=strlen(dir); }
                /* now one directory is in string dir */
                if( ltot + lf + 1 <= Mxdir)
                        {
                        dir[ltot]='/';
                        strcpy(dir+ltot+1,fname); /* now dir is appended with fi
   lename */
                        if( (fich = fopen(dir,"r") ) != NULL) break;
                        }
                else fich = NULL;
                deb=fin+1;
                }
        while (fin != NULL);
        return fich;
}
#endif

 

static void get_help(int help_pointer)    /* Help procedure */
{	
	FILE *help_file;
	int  i, number, nlines;
	Boolean found_help;
	char temp[MAXLINE+1];
	char *digits = "0123456789";
	char *help_marker    = ">>HELP<<";

#if MSDOS
	char *help_file_name = "clustalv.hlp";
#else
	char *help_file_name = "clustalv_help";
#endif

#if VMS
        if((help_file=fopen(help_file_name,"r","rat=cr","rfm=var"))==NULL) {
#else
#if UNIX
        if((help_file=open_path(help_file_name))==NULL) {
#else
        if((help_file=fopen(help_file_name,"r"))==NULL) {
#endif
#endif
		error("Cannot open help file [%s]",help_file_name);
		return;
	}

	nlines = 0;
	number = -1;
	found_help = FALSE;

	while(TRUE) {
		if(fgets(temp,MAXLINE+1,help_file) == NULL) {
			if(!found_help)
				error("No help found in help file");
			fclose(help_file);
			return;
		}
		if(strstr(temp,help_marker)) {
			for(i=0; i<MAXLINE; i++)
				if(strchr(digits, temp[i])) {
					number = temp[i] - '0';
					break;
				}
		}
		if(number == help_pointer) {
			found_help = TRUE;
			while(fgets(temp,MAXLINE+1,help_file)) {
				if(strstr(temp, help_marker)){
				  	if(usemenu) {
						fprintf(stdout,"\n");
				    		getstr("Press [RETURN] to continue",lin2);
				  	}
					fclose(help_file);
					return;
				}
			       fputs(temp,stdout);
			       ++nlines;
			       if(usemenu) {
			          if(nlines >= PAGE_LEN) {
				     	   fprintf(stdout,"\n");
			 	  	   getstr("Press [RETURN] to continue or  X  to stop",lin2);
				  	   if(toupper(*lin2) == 'X') {
						   fclose(help_file);
						   return;
				  	   }
				  	   else
						   nlines = 0;
				   }
			       }
			}
			if(usemenu) {
				fprintf(stdout,"\n");
				getstr("Press [RETURN] to continue",lin2);
			}
			fclose(help_file);
		}
	}

}


void parse_params()
{
	int i,j,k,len,lenp,temp;
	char probe[80], param_arg[80];
	int param_arg_len;

	Boolean do_align, do_tree, do_boot, do_profile, do_something;

/* command line switches for PARAMETERS **************************/
	static char *fixedgapst 	= "fixedgap";
	static char *floatgapst 	= "floatgap";
	static char *kimurast		= "kimura";
	static char *ktuplest  		= "ktuple";
	static char *matrixst		= "matrix";
	static char *outputst		= "output";
	static char *pairgapst  	= "pairgap";
	static char *scorest		= "score";
	static char *seedst		= "seed";
	static char *topdiagsst 	= "topdiags";
	static char *tossgapsst		= "tossgaps";
	static char *transitionsst 	= "transitions";
	static char *typest		= "type";
	static char *windowst	   	= "window";

/* command line switches for DATA       **************************/
	static char *infilest		= "infile";
	static char *profile1st		= "profile1";
	static char *profile2st		= "profile2";

/* command line switches for VERBS      **************************/
	static char *alignst		= "align";
	static char *bootstrapst	= "bootstrap";
	static char *checkst		= "check";        /*  /check = /help */
	static char *helpst   		= "help";
	static char *treest		= "tree";

	fprintf(stdout,"\n\n\n");
	fprintf(stdout," CLUSTAL V ... Multiple Sequence Alignments\n\n\n");

	do_align = do_tree = do_boot = do_profile = do_something = FALSE;

	*seqname=EOS;

	len=strlen(params);
	for(i=0;i<len;++i) params[i]=tolower(params[i]);

	if(check_param(params, helpst,  param_arg, &param_arg_len) ||
	   check_param(params, checkst, param_arg, &param_arg_len) ) {
		get_help(9);
		exit(1);
	}


/*****************************************************************************/
/*  Check to see if sequence type is explicitely stated..override ************/
/* the automatic checking (DNA or Protein).   /type=d or /type=p *************/
/*****************************************************************************/
	if(check_param(params, typest, param_arg, &param_arg_len)) 
		if(param_arg_len > 0) {
			if(param_arg[0] == 'p') {
				dnaflag = FALSE;
				explicit_dnaflag = TRUE;
				fprintf(stdout,
				"\nSequence type explicitely set to Protein\n");
			}
			else if(param_arg[0] == 'd') {
				fprintf(stdout,
				"\nSequence type explicitely set to DNA\n");
				dnaflag = TRUE;
				explicit_dnaflag = TRUE;
			}
			else
				fprintf(stdout,"\nUnknown sequence type %s\n",
				param_arg);
		}


/***************************************************************************
*   check to see if 1st parameter does not start with '/' i.e. look for an *
*   input file as first parameter.   The input file can also be specified  *
*   by /infile=fname.                                                      *
****************************************************************************/

	for (i=0; params[i] != '/' && params[i] != EOS; i++) ;
	if(i > 0) {
		strncpy(seqname, &params[0], i);
		seqname[i] = EOS;
		nseqs = readseqs(1);
		if(nseqs < 2) {
                	fprintf(stderr,
			"\nNo. of seqs. read = %d. No alignment!\n",nseqs);
			exit(1);
		}
		for(i = 1; i<=nseqs; i++) 
			fprintf(stdout,"Sequence %d: %-*.s   %6.d %s\n",
			i,MAXNAMES,names[i],seqlen_array[i],dnaflag?"bp":"aa");
		empty = FALSE;
		do_something = TRUE;
	}

/**************************************************/
/*  Look for /infile=file.ext on the command line */
/**************************************************/

	if(check_param(params, infilest, param_arg, &param_arg_len)) {
		if(param_arg_len == 0) {
			error("Bad sequence file name");
			exit(1);
		}
		strncpy(seqname, param_arg, param_arg_len);
/*		seqname[param_arg_len-1] = EOS;  */
		nseqs = readseqs(1);
		if(nseqs < 2) {
                	fprintf(stderr,
			"\nNo. of seqs. read = %d. No alignment!\n",nseqs);
			exit(1);
		}
		for(i = 1; i<=nseqs; i++) 
			fprintf(stdout,"Sequence %d: %-*.s   %6.d %s\n",
			i,MAXNAMES,names[i],seqlen_array[i],dnaflag?"bp":"aa");
		empty = FALSE;
		do_something = TRUE;
	}

/*********************************************************/
/* Look for /profile1=file.ext  AND  /profile2=file2.ext */
/* You must give both file names OR neither.             */
/*********************************************************/

	if(check_param(params, profile1st, param_arg, &param_arg_len)) {
		if(param_arg_len == 0) {
			error("Bad profile 1 file name");
			exit(1);
		}
		strncpy(seqname, param_arg, param_arg_len);
/*		seqname[param_arg_len-1] = EOS;	*/
		profile_input(1);
		if(nseqs <= 0) 
			exit(1);
	}

	if(check_param(params, profile2st, param_arg, &param_arg_len)) {
		if(param_arg_len == 0) {
			error("Bad profile 2 file name");
			exit(1);
		}
		if(profile1_empty) {
			error("Only 1 profile file (profile 2) specified.");
			exit(1);
		}
		strncpy(seqname, param_arg, param_arg_len);
/*		seqname[param_arg_len-1] = EOS;	*/
		profile_input(2);
		if(nseqs > profile1_nseqs) 
			do_something = do_profile = TRUE;
		else {
			error("No sequences read from profile 2");
			exit(1);
		}
	}

/*************************************************************************/
/* Look for /tree or /bootstrap or /align ********************************/
/*************************************************************************/

	if(check_param(params, treest, param_arg, &param_arg_len))
		if(empty) {
			error("Cannot draw tree.  No input alignment file");
			exit(1);
		}
		else 
			do_tree = TRUE;

	if(check_param(params, bootstrapst, param_arg, &param_arg_len))
		if(empty) {
			error("Cannot bootstrap tree. No input alignment file");
			exit(1);
		}
		else {
			temp = 0;
			if(param_arg_len > 0) sscanf(param_arg,"%d",&temp);
			if(temp > 0)          boot_ntrials = temp;
			do_boot = TRUE;
		}

	if(check_param(params, alignst, param_arg, &param_arg_len))
		if(empty) {
			error("Cannot align sequences.  No input file");
			exit(1);
		}
		else 
			do_align = TRUE;

	if( (!do_tree) && (!do_boot) && (!empty) && (!do_profile) ) 
		do_align = TRUE;

	if(!do_something) {
		error("No input file(s) specified");
		exit(1);
	}

	
	if(dnaflag) {
		gap_open   = dna_gap_open;
		gap_extend = dna_gap_extend;
		ktup       = dna_ktup;
		window     = dna_window;
		signif     = dna_signif;
		wind_gap   = dna_wind_gap;
	}
	else {
		gap_open   = prot_gap_open;
		gap_extend = prot_gap_extend;
		ktup       = prot_ktup;
		window     = prot_window;
		signif     = prot_signif;
		wind_gap   = prot_wind_gap;
	}


/****************************************************************************/
/* look for parameters on command line  e.g. gap penalties, k-tuple etc.    */
/****************************************************************************/

/*** ? /kimura  */
	if(check_param(params, kimurast, param_arg, &param_arg_len))
		kimura = TRUE;


/*** ? /tossgaps */
	if(check_param(params, tossgapsst, param_arg, &param_arg_len))
		tossgaps = TRUE;


/*** ? /score=percent or /score=absolute */
	if(check_param(params, scorest, param_arg, &param_arg_len))
		if(param_arg_len > 0) {
			if(param_arg[0] == 'p')
				percent = TRUE;
			else if(param_arg[0] == 'a') 
				percent = FALSE;
			else
				fprintf(stdout,"\nUnknown SCORE type: %s\n",
				param_arg);
		}


/*** ? /transitions */
	if(check_param(params, transitionsst, param_arg, &param_arg_len))
		is_weight = FALSE;


/*** ? /seed=n */
	if(check_param(params, seedst, param_arg, &param_arg_len)) {
		temp = 0;
		if(param_arg_len > 0) sscanf(param_arg,"%d",&temp);
		if(temp > 0) boot_ran_seed = temp;
	fprintf(stdout,"\ntemp = %d; seed = %u;\n",temp,boot_ran_seed);
	}


/*** ? /output=PIR, GCG or PHYLIP  Only 1 can be switched on at a time */
	if(check_param(params, outputst, param_arg, &param_arg_len))
		if(param_arg_len > 0) {
			if(param_arg[0] == 'g')  {	/* GCG */
				output_gcg     = TRUE;
				output_clustal = FALSE;
			}
			else if(param_arg[0] == 'p') 
				if(param_arg[1] == 'i') {
					output_nbrf    = TRUE;
					output_clustal = FALSE;
				}
				else if(param_arg[1] == 'h') {
					output_phylip  = TRUE;
					output_clustal = FALSE;
				}
				else
					fprintf(stdout,"\nUnknown OUTPUT type: %s\n",
					param_arg);
			else
				fprintf(stdout,"\nUnknown OUTPUT type: %s\n",
				param_arg);
		}


/*** ? /ktuple=n */
	if(check_param(params, ktuplest, param_arg, &param_arg_len)) {
		temp = 0;
		if(param_arg_len > 0) sscanf(param_arg,"%d",&temp);
		if(temp > 0) {
			if(dnaflag) {
				if(temp <= 4) { 
					ktup         = temp;
					dna_ktup     = ktup;
					wind_gap     = ktup + 4;
					dna_wind_gap = wind_gap;
				}
			}
			else {
				if(temp <= 2) {
					ktup          = temp;
					prot_ktup     = ktup;
					wind_gap      = ktup + 3;
					prot_wind_gap = wind_gap;
				}
			}
		}
	}


/*** ? /pairgap=n */
	if(check_param(params, pairgapst, param_arg, &param_arg_len)) {
		temp = 0;
		if(param_arg_len > 0) sscanf(param_arg,"%d",&temp);
		if(temp > 0)
			if(dnaflag) {
				if(temp > ktup) {
					wind_gap     = temp;
					dna_wind_gap = wind_gap;
				}
			}
			else {
				if(temp > ktup) {
					wind_gap      = temp;
					prot_wind_gap = wind_gap;
				}
			}
	}
	

/*** ? /topdiags=n   */
	if(check_param(params, topdiagsst, param_arg, &param_arg_len)) {
		temp = 0;
		if(param_arg_len > 0) sscanf(param_arg,"%d",&temp);
		if(temp > 0)
			if(dnaflag) {
				if(temp > ktup) { 
					signif       = temp;
					dna_signif   = signif;
				}
			}
			else {
				if(temp > ktup) {
					signif        = temp;
					prot_signif   = signif;
				}
			}
	}
	

/*** ? /window=n  */
	if(check_param(params, windowst, param_arg, &param_arg_len)) {
		temp = 0;
		if(param_arg_len > 0) sscanf(param_arg,"%d",&temp);
		if(temp > 0)
			if(dnaflag) {
				if(temp > ktup) { 
					window       = temp;
					dna_window   = window;
				}
			}
			else {
				if(temp > ktup) {
					window        = temp;
					prot_window   = window;
				}
			}
	}


/*** ? /matrix=pam100, or ID or file.ext (user's file)  */
	if(check_param(params, matrixst, param_arg, &param_arg_len))
		if(param_arg_len > 0) {
			if( !strcmp(param_arg, "pam100") )  {
				matptr = pam100mt;
				make_pamo(0);
				prot_gap_open   = 13;
				prot_gap_extend = 13;
				if(!dnaflag) gap_open   = prot_gap_open;
				if(!dnaflag) gap_extend = prot_gap_extend;
				matnum = 1;
			}
			else if( !strcmp(param_arg, "id") )  {
				matptr = idmat;
				make_pamo(0);
				matnum = 3;
			}
			else if(user_mat(param_arg))
				matnum = 4;
			else
				fprintf(stdout,"\nUnknown MATRIX type: %s\n",
				param_arg);
		}


/*** ? /fixedgap=n  */
	if(check_param(params, fixedgapst, param_arg, &param_arg_len)) {
		temp = 0;
		if(param_arg_len > 0)
			sscanf(param_arg,"%d",&temp);
		if(temp > 0)
			if(dnaflag) {
					gap_open     = temp;
					dna_gap_open = gap_open;
			}
			else {
					gap_open      = temp;
					prot_gap_open = gap_open;
			}
	}


/*** ? /floatgap=n   */
	if(check_param(params, floatgapst, param_arg, &param_arg_len)) {
		temp = 0;
		if(param_arg_len > 0)
			sscanf(param_arg,"%d",&temp);
		if(temp > 0)
			if(dnaflag) {
					gap_extend      = temp;
					dna_gap_extend  = gap_extend;
			}
			else {
					gap_extend      = temp;
					prot_gap_extend = gap_extend;
			}
	}


/****************************************************************************/
/* Now do whatever has been requested ***************************************/
/****************************************************************************/

	if(do_profile)
		profile_align();

	if(do_align)
		align();

	if(do_tree)
		phylogenetic_tree();

	if(do_boot)
		bootstrap_tree();

	exit(1);

/*******whew!***now*go*home****/
}







void main_menu()
{
	while(TRUE) {
		fprintf(stdout,"\n\n\n");
		fprintf(stdout," **************************************************************\n");
		fprintf(stdout," ********* CLUSTAL V ... Multiple Sequence Alignments  ********\n");
		fprintf(stdout," **************************************************************\n");
		fprintf(stdout,"\n\n");
		
		fprintf(stdout,"     1. Sequence Input From Disc\n");
		fprintf(stdout,"     2. Multiple Alignments\n");
		fprintf(stdout,"     3. Profile Alignments\n");
		fprintf(stdout,"     4. Phylogenetic trees\n");
		fprintf(stdout,"\n");
		fprintf(stdout,"     S. Execute a system command\n");
		fprintf(stdout,"     H. HELP\n");
		fprintf(stdout,"     X. EXIT (leave program)\n\n\n");
		
		getstr("Your choice",lin1);

		switch(toupper(*lin1)) {
			case '1': seq_input();
				break;
			case '2': multiple_align_menu();
				break;
			case '3': profile_align_menu();
				break;
			case '4': phylogenetic_tree_menu();
				break;
			case 'S': do_system();
				break;
			case '?':
			case 'H': get_help(1);
				break;
			case 'Q':
			case 'X': exit(0);
				break;
			default: fprintf(stderr,"\n\nUnrecognised Command\n\n");
				break;
		}
	}
}









static void multiple_align_menu()
{
    while(TRUE)
    {
        fprintf(stdout,"\n\n\n");
        fprintf(stdout,"******Multiple*Alignment*Menu******\n");
        fprintf(stdout,"\n\n");


        fprintf(stdout,"    1.  Do complete multiple alignment now\n");
        fprintf(stdout,"    2.  Produce dendrogram file only\n");
        fprintf(stdout,"    3.  Use old dendrogram file\n");
        fprintf(stdout,"    4.  Pairwise alignment parameters\n");
        fprintf(stdout,"    5.  Multiple alignment parameters\n");
        fprintf(stdout,"    6.  Output format options\n");
        fprintf(stdout,"\n");
        fprintf(stdout,"    S.  Execute a system command\n");
        fprintf(stdout,"    H.  HELP\n");
        fprintf(stdout,"    or press [RETURN] to go back to main menu\n\n\n");

        getstr("Your choice",lin1);
        if(*lin1 == EOS) return;

        switch(toupper(*lin1))
        {
        case '1': align();
            break;
        case '2': make_tree();
            break;
        case '3': get_tree();
            break;
        case '4': pair_menu();
            break;
        case '5': multi_menu();
            break;
        case '6': format_options_menu();
            break;
        case 'S': do_system();
            break;
        case '?':
        case 'H': get_help(2);
            break;
        case 'Q':
        case 'X': return;

        default: fprintf(stderr,"\n\nUnrecognised Command\n\n");
            break;
        }
    }
}









static void profile_align_menu()
{
    while(TRUE)
    {
	fprintf(stdout,"\n\n\n");
        fprintf(stdout,"******Profile*Alignment*Menu******\n");
        fprintf(stdout,"\n\n");

        fprintf(stdout,"    1.  Input 1st. profile/sequence\n");
        fprintf(stdout,"    2.  Input 2nd. profile/sequence\n");
        fprintf(stdout,"    3.  Do alignment now\n");
        fprintf(stdout,"    4.  Alignment parameters\n");
        fprintf(stdout,"    5.  Output format options\n");
        fprintf(stdout,"\n");
        fprintf(stdout,"    S.  Execute a system command\n");
        fprintf(stdout,"    H.  HELP\n");
        fprintf(stdout,"    or press [RETURN] to go back to main menu\n\n\n");

        getstr("Your choice",lin1);
        if(*lin1 == EOS) return;

        switch(toupper(*lin1))
        {
        case '1': profile_input(1);      /* 1 => 1st profile */
            break;
        case '2': profile_input(2);      /* 2 => 2nd profile */
            break;
        case '3': profile_align();       /* align the 2 alignments now */
            break;
        case '4': multi_menu();
            break;
        case '5': format_options_menu();
            break;
        case 'S': do_system();
            break;
        case '?':
        case 'H': get_help(6);
            break;
        case 'Q':
        case 'X': return;

        default: fprintf(stderr,"\n\nUnrecognised Command\n\n");
            break;
        }
    }
}











static void phylogenetic_tree_menu()
{
    while(TRUE)
    {
        fprintf(stdout,"\n\n\n");
        fprintf(stdout,"******Phylogenetic*tree*Menu******\n");
        fprintf(stdout,"\n\n");

        fprintf(stdout,"    1.  Input an alignment\n");
        fprintf(stdout,"    2.  Exclude positions with gaps?        ");
	if(tossgaps)
		fprintf(stdout,"= ON\n");
	else
		fprintf(stdout,"= OFF\n");
        fprintf(stdout,"    3.  Correct for multiple substitutions? ");
	if(kimura)
		fprintf(stdout,"= ON\n");
	else
		fprintf(stdout,"= OFF\n");
        fprintf(stdout,"    4.  Draw tree now\n");
        fprintf(stdout,"    5.  Bootstrap tree\n");
        fprintf(stdout,"\n");
        fprintf(stdout,"    S.  Execute a system command\n");
        fprintf(stdout,"    H.  HELP\n");
        fprintf(stdout,"    or press [RETURN] to go back to main menu\n\n\n");

        getstr("Your choice",lin1);
        if(*lin1 == EOS) return;

        switch(toupper(*lin1))
        {
       	 	case '1': seq_input();
         	   	break;
        	case '2': tossgaps ^= TRUE;
          	  	break;
      		case '3': kimura ^= TRUE;;
            		break;
        	case '4': phylogenetic_tree();
            		break;
        	case '5': bootstrap_tree();
            		break;
        	case 'S': do_system();
            		break;
            	case '?':
        	case 'H': get_help(7);
            		break;
            	case 'Q':
        	case 'X': return;

        	default: fprintf(stderr,"\n\nUnrecognised Command\n\n");
            	break;
        }
    }
}






static void format_options_menu()      /* format of alignment output */
{	
	char path[FILENAMELEN+1];

	while(TRUE) {
	fprintf(stdout,"\n\n\n");
	fprintf(stdout," ********* Format of Alignment Output *********\n");
	fprintf(stdout,"\n\n");
	fprintf(stdout,"     1. Toggle CLUSTAL format output   =  %s\n",
					(!output_clustal) ? "OFF" : "ON");
	fprintf(stdout,"     2. Toggle NBRF/PIR format output  =  %s\n",
					(!output_nbrf) ? "OFF" : "ON");
	fprintf(stdout,"     3. Toggle GCG format output       =  %s\n",
					(!output_gcg) ? "OFF" : "ON");
	fprintf(stdout,"     4. Toggle PHYLIP format output    =  %s\n\n",
					(!output_phylip) ? "OFF" : "ON");
      if(empty)
	fprintf(stdout,"\n");
      else
	fprintf(stdout,"     5. Create alignment output file(s) now?\n");
	fprintf(stdout,"     H. HELP\n\n\n");	
	
		getstr("Enter number (or [RETURN] to exit)",lin2);
		if(*lin2 == EOS) return;
		
		switch(toupper(*lin2)) {
			case '1':
				output_clustal ^= TRUE;
				break;
			case '2':
              			output_nbrf ^= TRUE;
			  	break;
			case '3':
              			output_gcg ^= TRUE;
			  	break;
			case '4':
              			output_phylip ^= TRUE;
			  	break;
			case '5':
				if(empty) break;
				get_path(seqname,path);
				if(!open_alignment_output(path)) break;
				create_alignment_output();
				break;
			case '?':
			case 'H':
				get_help(5);
				break;
			default:
				fprintf(stderr,"\n\nUnrecognised Command\n\n");
				break;
		}
	}
}












static void pair_menu()
{
	if(dnaflag) {
		ktup     = dna_ktup;
		window   = dna_window;
		signif   = dna_signif;
		wind_gap = dna_wind_gap;
	}
	else {
		ktup     = prot_ktup;
		window   = prot_window;
		signif   = prot_signif;
		wind_gap = prot_wind_gap;
	}

	while(TRUE) {
		lin3 = percent ? "Percentage" : "Absolute";
	
		fprintf(stdout,"\n\n\n");
		fprintf(stdout," ********* WILBUR/LIPMAN PAIRWISE ALIGNMENT PARAMETERS *********\n");
		fprintf(stdout,"\n\n");

		fprintf(stdout,"     1. Toggle Scoring Method  :%s\n",lin3);
		fprintf(stdout,"     2. Gap Penalty            :%d\n",wind_gap);
		fprintf(stdout,"     3. K-tuple                :%d\n",ktup);
		fprintf(stdout,"     4. No. of top diagonals   :%d\n",signif);
		fprintf(stdout,"     5. Window size            :%d\n\n",window);
		fprintf(stdout,"     H. HELP\n\n\n");
		
		getstr("Enter number (or [RETURN] to exit)",lin2);
		if( *lin2 == EOS) {
			if(dnaflag) {
				dna_ktup      = ktup;
				dna_window    = window;
				dna_signif    = signif;
				dna_wind_gap  = wind_gap;
			}
			else {
				prot_ktup     = ktup;
				prot_window   = window;
				prot_signif   = signif;
				prot_wind_gap = wind_gap;
			}
			return;
		}
		
		switch(toupper(*lin2)) {
			case '1':
				percent ^= TRUE;
				break;
			case '2':
				fprintf(stdout,"Gap Penalty Currently: %d\n",wind_gap);
				wind_gap=getint("Enter number",1,500,wind_gap);
				break;
			case '3':
				fprintf(stdout,"K-tuple Currently: %d\n",ktup);
				ktup=getint("Enter number",1,4,ktup);
				break;
			case '4':
				fprintf(stdout,"Top diagonals Currently: %d\n",signif);
				signif=getint("Enter number",1,MAXLEN,signif);
				break;
			case '5':
				fprintf(stdout,"Window size Currently: %d\n",window);
				window=getint("Enter number",1,50,window);
				break;
			case '?':
			case 'H':
				get_help(3);
				break;
			default:
				fprintf(stderr,"\n\nUnrecognised Command\n\n");
				break;
		}
	}
}












static void multi_menu()
{
	if(dnaflag) {
		gap_open   = dna_gap_open;
		gap_extend = dna_gap_extend;
	}
	else {
		gap_open   = prot_gap_open;
		gap_extend = prot_gap_extend;
	}

	while(TRUE) {
		lin3 = is_weight ? "Weighted" :"Unweighted";

		fprintf(stdout,"\n\n\n");
		fprintf(stdout," ********* MYERS/MILLER MULTIPLE ALIGNMENT PARAMETERS *********\n");
		fprintf(stdout,"\n\n");
		
		fprintf(stdout,"     1. Fixed Gap Penalty       :%d\n",gap_open);
		fprintf(stdout,"     2. Floating Gap Penalty    :%d\n",gap_extend);
		fprintf(stdout,"     3. Toggle Transitions (DNA):%s\n",lin3);
		fprintf(stdout,"     4. Protein weight matrix   :%s\n\n"
					,pam_matrix_name[matnum-1]);
		fprintf(stdout,"     H. HELP\n\n\n");		

		getstr("Enter number (or [RETURN] to exit)",lin2);

		if(*lin2 == EOS) {
			if(dnaflag) {
				dna_gap_open    = gap_open;
				dna_gap_extend  = gap_extend;
			}
			else {
				prot_gap_open   = gap_open;
				prot_gap_extend = gap_extend;
			}
			return;
		}
		
		switch(toupper(*lin2)) {
			case '1':
			fprintf(stdout,"Fixed Gap Penalty Currently: %d\n",gap_open);
				gap_open=getint("Enter number",1,100,gap_open);
				break;
			case '2':
				fprintf(stdout,"Floating Gap Penalty Currently: %d\n",gap_extend);
				gap_extend=getint("Enter number",1,100,gap_extend);
				break;
			case '3':
				is_weight ^= TRUE;
				break;
			case '4':
				read_matrix();
				break;
			case '?':
			case 'H':
				get_help(4);
				break;
			default:
				fprintf(stderr,"\n\nUnrecognised Command\n\n");
				break;
		}
	}
}











static void read_matrix()
{	static char userfile[FILENAMELEN+1];
	
	while(TRUE)
	{
		fprintf(stdout,"\n\n\n");
		fprintf(stdout," ********* PROTEIN WEIGHT MATRIX MENU *********\n");
		fprintf(stdout,"\n\n");
		
		
		fprintf(stdout,"     1. %s\n",pam_matrix_name[0]);
		fprintf(stdout,"     2. %s\n",pam_matrix_name[1]);
		fprintf(stdout,"     3. %s\n",pam_matrix_name[2]);
		fprintf(stdout,"     4. %s\n\n",pam_matrix_name[3]);
		fprintf(stdout,"     H. HELP\n\n");
		fprintf(stdout,
"     -- Current matrix is the %s ",pam_matrix_name[matnum-1]);
		if(matnum == 4) fprintf(stdout,"(file = %s)",userfile);
		fprintf(stdout,"--\n");
		
			
		getstr("\n\nEnter number (or [RETURN] to exit)",lin2);
		if(*lin2 == EOS) return;

		switch(toupper(*lin2))  {
			case '1':
				matptr=pam100mt;
				make_pamo(0);
				prot_gap_open   = 13;
				prot_gap_extend = 13;
				matnum=1;
				break;
			case '2':
				matptr=pam250mt;
				make_pamo(0);
				prot_gap_open   = 10;
				prot_gap_extend = 10;
				matnum=2;
				break;
			case '3':
				matptr=idmat;
				make_pamo(0);
				prot_gap_open   = 10;
				prot_gap_extend = 10;
				matnum=3;
				break;
			case '4':
				if(user_mat(userfile)) matnum=4;
				break;
			case '?':
			case 'H':
				get_help(8);
				break;
			default:
				fprintf(stderr,"\n\nUnrecognised Command\n\n");
				break;
		}
	}
}


static Boolean user_mat(char *str)
{
	int i,j,nv,pos,idx,val;
	FILE *infile;
	
	if(usemenu)
		getstr("Enter name of the matrix file",lin2);
	else
		strcpy(lin2,str);

	if(*lin2 == EOS) return FALSE;
	
	if((infile=fopen(lin2,"r"))==NULL) {
		error("Cannot find matrix file [%s]",lin2);
		return FALSE;
	}

	strcpy(str,lin2);
	strcpy(mtrxnam,lin2);
	
	idx=0;
	for(i=0;i<20;++i) 
		for(j=0;j<=i;++j) {
			if( fscanf(infile,"%d",&val) == EOF) {
				error("Input matrix has too few values");
				return FALSE;
			}
			usermat[idx++]=(char)val;
		}

	fclose(infile);
	matptr=usermat;
	make_pamo(0);
	return TRUE;
}










static void seq_input()
{
	char c;
        int i;
	
	if(usemenu) {
fprintf(stdout,"\n\nSequences should all be in 1 file.\n"); 
fprintf(stdout,
"\n3 formats accepted:  NBRF/PIR, EMBL/SwissProt, Pearson (Fasta).\n");
fprintf(stdout,
"\nGCG users should use TOPIR to convert their sequence files before use.\n\n\n");
	}

	
       nseqs = readseqs(1);        /* DES   1 is the first seq to be read */
       if(nseqs < 0)               /* file could not be opened */
           { 
               nseqs = 0;
               empty = TRUE;
           }
       else if(nseqs == 0)         /* no sequences */
           {
	       error("No sequences in file!  Bad format?");
               empty = TRUE;
           }
       else if(nseqs == 1)
           {
               error("Only one sequence in file!");
               empty = TRUE;
               nseqs = 0;
           }
       else 
           {
		fprintf(stdout,"\nSequences assumed to be %s \n\n",
			dnaflag?"DNA":"PROTEIN");
                for(i=1; i<=nseqs; i++) {
                        fprintf(stdout,"Sequence %d: %-*.s   %6.d %s\n",
                        i,MAXNAMES,names[i],seqlen_array[i],dnaflag?"bp":"aa");
                }	
			if(dnaflag) {
				gap_open   = dna_gap_open;
				gap_extend = dna_gap_extend;
			}
			else {
				gap_open   = prot_gap_open;
				gap_extend = prot_gap_extend;
			}
			empty=FALSE;
	   }
	
}







static void profile_input(int profile_no)   /* DES  read a profile   */
{                                           /* profile_no is 1 or 2  */
	char c;
        int local_nseqs, i;
	
        if(profile_no == 2 && profile1_empty) 
           {
             error("You must read in profile number 1 first");
             return;
           }


    if(profile_no == 1)     /* for the 1st profile */
      {
       local_nseqs = readseqs(1); /* (1) means 1st seq to be read = no. 1 */
       if(local_nseqs < 0)               /* file could not be opened */
	       return;
       else if(local_nseqs == 0)         /* no sequences  */
           {
	       error("No sequences in file!  Bad format?");
	       return;
           }
       else 
           { 				/* success; found some seqs. */
                nseqs = profile1_nseqs = local_nseqs;
		fprintf(stdout,"\nNo. of seqs=%d\n",nseqs);
		profile1_empty=FALSE;
		profile2_empty=TRUE;
	   }
      }
    else
      {			        /* first seq to be read = profile1_nseqs + 1 */
       local_nseqs = readseqs(profile1_nseqs+1); 
       if(local_nseqs < 0)               /* file could not be opened */
               profile2_empty = TRUE;
       else if(local_nseqs == 0)         /* no sequences */
           {
	       error("No sequences in file!  Bad format?");
               profile2_empty = TRUE;
           }
       else 
           {
		fprintf(stdout,"\nNo. of seqs in profile=%d\n",local_nseqs);
                nseqs = profile1_nseqs + local_nseqs;
                fprintf(stdout,"\nTotal no. of seqs     =%d\n",nseqs);
		profile2_empty=FALSE;
		empty = FALSE;
	   }

      }
	
	fprintf(stdout,"\nSequences assumed to be %s \n\n",
		dnaflag?"DNA":"PROTEIN");
        for(i=profile2_empty?1:profile1_nseqs+1; i<=nseqs; i++) {
                fprintf(stdout,"Sequence %d: %-*.s   %6.d %s\n",
                   i,MAXNAMES,names[i],seqlen_array[i],dnaflag?"bp":"aa");
        }	
	if(dnaflag) {
		gap_open   = dna_gap_open;
		gap_extend = dna_gap_extend;
	}
	else {
		gap_open   = prot_gap_open;
		gap_extend = prot_gap_extend;
	}
}






FILE *  open_output_file(char *prompt,      char *path, 
				char *file_name,   char *file_extension)
 
{	static char temp[FILENAMELEN+1];
	static char local_prompt[MAXLINE];
	FILE * file_handle;

	strcpy(file_name,path);
	strcat(file_name,file_extension);
	strcpy(local_prompt,prompt);
	strcat(local_prompt," [%s]: ");          

	if(usemenu) {
		fprintf(stdout,local_prompt,file_name);
		gets(temp);
		if(*temp != EOS) strcpy(file_name,temp);
	}

#if VMS
	if((file_handle=fopen(file_name,"w","rat=cr","rfm=var"))==NULL) {
#else
	if((file_handle=fopen(file_name,"w"))==NULL) {
#endif
		error("Cannot open output file [%s]",file_name);
		return NULL;
	}
	return file_handle;
}











static void align()
{ 
	char path[FILENAMELEN+1],temp[FILENAMELEN+1];
	int oldmax,oldneut;
	
	if(empty && usemenu) {
		error("No sequences in memory. Load sequences first.");
		return;
	}

	get_path(seqname,path);
	
	if(!open_alignment_output(path)) return;

	if((tree = open_output_file(
			"\nEnter a name for the dendrogram file     ",
			path,treename,"dnd"))==NULL) return;
	
	fclose(tree);
	
	if(dnaflag) {
		ktup     = dna_ktup;
		window   = dna_window;
		signif   = dna_signif;
		wind_gap = dna_wind_gap;
	}
	else {
		ktup     = prot_ktup;
		window   = prot_window;
		signif   = prot_signif;
		wind_gap = prot_wind_gap;
	}

	reset();
	
	fprintf(stdout,"\nStart of Pairwise alignments\n");
	fprintf(stdout,"Aligning...\n");
	show_pair();
	upgma(nseqs);
	
	if((tree=fopen(treename,"r"))==NULL) {
		error("Cannot open file [%s]",treename);
		return;
	}
	
	oldneut=xover;
	oldmax=big_pam;
	myers(0);
	big_pam=oldmax;
	xover=oldneut;
	fclose(tree);
	
	fprintf(stdout,"\n\n\n");
	fprintf(stdout,"Consensus length = %d\n",seqlen_array[1]);
	
	create_alignment_output();
}









static void make_tree()
{
	char path[FILENAMELEN+1],temp[FILENAMELEN+1];
	
	if(empty) {
		error("No sequences in memory. Load sequences first.");
		return;
	}

	get_path(seqname,path);

	strcpy(treename,path);
	strcat(treename,"dnd");
	
	fprintf(stdout,"\nEnter a name for the DENDROGRAM file [%s]: ",treename);
	gets(temp);
	if(*temp != EOS)
		strcpy(treename,temp);
	
#if VMS
	if((tree=fopen(treename,"w","rat=cr","rfm=var"))==NULL) {
#else
	if((tree=fopen(treename,"w"))==NULL) {
#endif
		error("Cannot open file [%s]",treename);
		return;
	}
	fclose(tree);
	
	if(dnaflag) {
		ktup     = dna_ktup;
		window   = dna_window;
		signif   = dna_signif;
		wind_gap = dna_wind_gap;
	}
	else {
		ktup     = prot_ktup;
		window   = prot_window;
		signif   = prot_signif;
		wind_gap = prot_wind_gap;
	}

	reset();
	fprintf(stdout,"\nStart of Pairwise alignments\n");
	fprintf(stdout,"Aligning...\n");
	show_pair();
	upgma(nseqs);
	
	fprintf(stdout,"\nDENDROGRAM file created [%s]\n",treename);
}









static void get_tree()
{
	char path[FILENAMELEN+1],temp[MAXLINE+1];
	int count,oldmax,oldneut;
	
	if(empty) {
		error("No sequences in memory. Load sequences first.");
		return;
	}

	get_path(seqname,path);
	
	strcpy(treename,path);
	strcat(treename,"dnd");
	
	fprintf(stdout,"\nEnter a name for the DENDROGRAM file      [%s]:",treename);
	gets(temp);
	if(*temp != EOS)
		strcpy(treename,temp);
	
	if((tree=fopen(treename,"r"))==NULL) {
		error("Cannot open file [%s]",treename);
		return;
	}
	
	count=0;
	
	while(fgets(temp,MAXLINE+1,tree)!=NULL) ++count;
	
	fclose(tree);
	
	if(++count != nseqs) {
		error("Dendrogram file is not consistent with the sequence data");
		return;
	}
	
	if(!open_alignment_output(path)) return;

	reset();
	
	if((tree=fopen(treename,"r"))==NULL) {
		error("Cannot open file [%s]",treename);
		return;
	}
	
	oldmax=big_pam;
	oldneut=xover;
	myers(0);
	xover=oldneut;
	big_pam=oldmax;
	fclose(tree);

	fprintf(stdout,"\n\n\n");
	fprintf(stdout,"Consensus length = %d\n",seqlen_array[1]);

	create_alignment_output();
}










static void profile_align()
{
	char path[FILENAMELEN+1],temp[MAXLINE+1];
	int count,oldmax,oldneut;
	
	if(profile2_empty) {
		error("No sequences in memory. Load sequences first.");
		return;
	}

	get_path(seqname,path);
	
	if(!open_alignment_output(path)) return;

	reset();
		
	oldmax=big_pam;
	oldneut=xover;
	myers(1);
	xover=oldneut;
	big_pam=oldmax;

	fprintf(stdout,"\n\n\n");
	fprintf(stdout,"Consensus length = %d\n",seqlen_array[1]);

	create_alignment_output();
}








static void clustal_out(FILE *clusout)
{
	static char seq1[MAXLEN+1];
	char 	    temp[MAXLINE];
	int val,i,j,k,a,b,len;
	int chunks,ident,lv1,pos,ptr,copt,flag;


	fprintf(clusout,"CLUSTAL V multiple sequence alignment\n\n\n");

	len=seqlen_array[1];
	
	chunks = len/LINELENGTH;
	if(len % LINELENGTH != 0)
		++chunks;
		
	for(lv1=1;lv1<=chunks;++lv1) {
		pos = ((lv1-1)*LINELENGTH)+1;
		ptr = (len<pos+LINELENGTH-1) ? len : pos+LINELENGTH-1;
		for(i=1;i<=nseqs;++i) {
			for(j=pos;j<=ptr;++j) {
				val=seq_array[i][j];
				if(val==0 || val>20)
					seq1[j]='X';
				else
					if(val<0) seq1[j]='-';
				else {
					if(dnaflag)
						seq1[j]=nucleic_acid_order[val];
					else
						seq1[j]=amino_acid_order[val];
				}
			}
			strncpy(temp,&seq1[pos],ptr-pos+1);
			temp[ptr-pos+1]=EOS;
			fprintf(clusout,"%-15s %s\n",names[i],temp);
		}
	
		copt = ((nseqs*nseqs) - nseqs) / 2;
		for(i=pos;i<=ptr;++i) {
			seq1[i]=' ';
			ident=0;
			for(j=1;j<=nseqs;++j)
				if(seq_array[1][i] == seq_array[j][i])
					++ident;
			if(ident==nseqs)
				seq1[i]='*';
			else {
				if(!dnaflag) {
					ident=flag=0;
					for(j=1;j<=nseqs;++j) {
						for(k=j+1;k<=nseqs;++k)
							if(seq_array[j][i]>0 && seq_array[k][i]>0) {
								if(weights[seq_array[j][i]][seq_array[k][i]]<xover)
									++ident;
								else {
									flag=TRUE;
									break;
								}
							}
							else {
								flag=TRUE;
								break;
							}
							if(flag)
								break;
					}
					if(flag)
						continue;
					if(ident==copt)
						seq1[i]='.';
				}
			}
		}
		strncpy(temp,&seq1[pos],ptr-pos+1);
		temp[ptr-pos+1]=EOS;
/* "bugfix" Cornelius Krasel 19.02.94
		fprintf(clusout,"                %s\n\n",temp);
   is replaced by: */
		fprintf(clusout,"               %s\n\n",temp);
		++nblocks;
	}
	
/*
	fprintf(stdout,"\nEnd of Multiple Alignment\n\n");
	fprintf(clusout,"\nEnd of Multiple Alignment\n\n");
	fprintf(clusout,"\nKey:\n     Identity:     #\n     Conservative: ^\n\n");

	fprintf(clusout,"\nParameters:\n\n");
	fprintf(clusout,"Ktup:         %d\nWilbur Gap:   %d\nCutoff:       %d\nDiagonal:     %d\n",
	ktup,wind_gap,signif,window);
	fprintf(clusout,"Fixed Gap:    %d\nFloating Gap: %d\n\n",gap_open,gap_extend);

	fprintf(clusout,"Sequences were: ");
	fprintf(clusout,dnaflag ? "Nucleic Acid\n" : "Proteins\n");
	fprintf(clusout,percent ? "Percentage" : "Absolute");
	fprintf(clusout," Identities Were Scored\n");
	if(dnaflag) {
		fprintf(clusout,"Nucleotide Transitions: ");
		fprintf(clusout,is_weight ? "WEIGHTED\n" : "UNWEIGHTED\n");
	}
	fprintf(clusout,"Sequence Input file: %s\n",seqname);
	fprintf(clusout,"Matrix used: ");
	if(matptr==idmat)
		fprintf(clusout,"No penalty\n");
	else
		if(matptr==pam250mt)
			fprintf(clusout,"PAM 250\n");
	else
		if(matptr==pam100mt)
			fprintf(clusout,"PAM 100\n");
	else
		fprintf(clusout,"%s\n",mtrxnam);
*/
}






static void gcg_out(FILE *gcgout)
{
/*        static char *aacids = "XCSTPAGNDEQHRKMILVFYW";*/
/*	static char *nbases = "XACGT";	*/
	char seq[MAXLEN+1], residue;
	int all_checks[MAXN+1];
	int i,j,k,len,val,check,chunks,block,pos1,pos2;	
	long grand_checksum;
	
	len = seqlen_array[1];

	for(i=1; i<=nseqs; i++) {
		for(j=1; j<=len; j++) {
			val = seq_array[i][j];
			if(val == 0 || val > 20) 
				residue = 'X';
			else if(val < 0) 
				residue = '.';
			else {
				if(dnaflag)
					residue = nucleic_acid_order[val];
				else
					residue = amino_acid_order[val];
			}
			seq[j] = residue;
		}
		all_checks[i] = SeqGCGCheckSum(seq+1, len);
	}	

	grand_checksum = 0;
	for(i=1; i<=nseqs; i++) grand_checksum += all_checks[i];
	grand_checksum = grand_checksum % 10000;
	fprintf(gcgout,"\n\n   MSF:%5d  Type: ",len);
	if(dnaflag)
		fprintf(gcgout,"N");
	else
		fprintf(gcgout,"P");
	fprintf(gcgout,"    Check:%6d   .. \n\n", grand_checksum);
	for(i=1; i<=nseqs; i++) 
/*		for(j=0; j<MAXNAMES; j++) 
			if(names[i][j] == ' ')  names[i][j] = '_';     */
		fprintf(gcgout,
			" Name: %-15s oo  Len:%5d  Check:%6d  Weight:  1.00\n",
			names[i],len,all_checks[i]);
	fprintf(gcgout,"\n//\n");  

	chunks = len/GCG_LINELENGTH;
	if(len % GCG_LINELENGTH != 0) ++chunks;

	for(block=1; block<=chunks; block++) {
		fprintf(gcgout,"\n\n");
		pos1 = ((block-1) * GCG_LINELENGTH) + 1;
		pos2 = (len<pos1+GCG_LINELENGTH-1)? len : pos1+GCG_LINELENGTH-1;
		for(i=1; i<=nseqs; i++) {
			fprintf(gcgout,"\n%-15s ",names[i]);
			for(j=pos1, k=1; j<=pos2; j++, k++) {
				val = seq_array[i][j];
				if(val == 0 || val > 20) 
					residue = 'X';
				else if(val < 0) 
					residue = '.';
				else {
					if(dnaflag)
						residue = nucleic_acid_order[val];
					else
						residue = amino_acid_order[val];
				}
				fprintf(gcgout,"%c",residue);
				if(j % 10 == 0) fprintf(gcgout," ");
			}
		}
	}
	fprintf(gcgout,"\n\n");
}



static void phylip_out(FILE *phyout)
{
/*      static char *aacids = "XCSTPAGNDEQHRKMILVFYW";*/
/*		static char *nbases = "XACGT";	*/
	char residue;
	int i,j,k,len,val,chunks,block,pos1,pos2;	
	
	len = seqlen_array[1];


	chunks = len/GCG_LINELENGTH;
	if(len % GCG_LINELENGTH != 0) ++chunks;

	fprintf(phyout,"%6d %6d",nseqs,len);

	for(block=1; block<=chunks; block++) {
		pos1 = ((block-1) * GCG_LINELENGTH) + 1;
		pos2 = (len<pos1+GCG_LINELENGTH-1)? len : pos1+GCG_LINELENGTH-1;
		for(i=1; i<=nseqs; i++) {
			if(block == 1) 
				fprintf(phyout,"\n%-10s ",names[i]);
			else
				fprintf(phyout,"\n           ");
			for(j=pos1, k=1; j<=pos2; j++, k++) {
				val = seq_array[i][j];
				if(val == 0 || val > 20) 
					residue = 'X';
				else if(val < 0) 
					residue = '-';
				else {
					if(dnaflag)
						residue = nucleic_acid_order[val];
					else
						residue = amino_acid_order[val];
				}
				fprintf(phyout,"%c",residue);
				if(j % 10 == 0) fprintf(phyout," ");
			}
		}
		fprintf(phyout,"\n");
	}
}





static void nbrf_out(FILE *nbout)
{
/*      static char *aacids = "XCSTPAGNDEQHRKMILVFYW";*/
/*		static char *nbases = "XACGT";	*/
	char seq[MAXLEN+1], residue;
	int i,j,len,val;	
	
	len = seqlen_array[1];

	for(i=1; i<=nseqs; i++) {
		fprintf(nbout, dnaflag ? ">DL;" : ">P1;");
		fprintf(nbout, "%s\n%s\n", names[i], titles[i]);
		for(j=1; j<=len; j++) {
			val = seq_array[i][j];
			if(val == 0 || val > 20) 
				residue = 'X';
			else if(val < 0) 
				residue = '-';
			else {
				if(dnaflag)
					residue = nucleic_acid_order[val];
				else
					residue = amino_acid_order[val];
			}
			seq[j] = residue;
		}
		for(j=1; j<=len; j++) {
			fprintf(nbout,"%c",seq[j]);
			if((j % LINELENGTH == 0) || (j == len)) 
				fprintf(nbout,"\n");
		}
		fprintf(nbout,"*\n");
	}	
}


static Boolean open_alignment_output(char *path)
{
	if(output_clustal) 
		if((clustal_outfile = open_output_file(
		    	"\nEnter a name for the CLUSTAL output file ",path,
			clustal_outname,"aln"))==NULL) return FALSE;
	if(output_nbrf) 
		if((nbrf_outfile = open_output_file(
		    	"\nEnter a name for the NBRF/PIR output file",path,
			nbrf_outname,"pir"))==NULL) return FALSE;
	if(output_gcg) 
		if((gcg_outfile = open_output_file(
		    	"\nEnter a name for the GCG output file     ",path,
			gcg_outname,"msf"))==NULL) return FALSE;
	if(output_phylip) 
		if((phylip_outfile = open_output_file(
		    	"\nEnter a name for the PHYLIP output file  ",path,
			phylip_outname,"phy"))==NULL) return FALSE;
	return TRUE;
}





static void create_alignment_output()
{
	if(output_clustal) {
		clustal_out(clustal_outfile);
		fclose(clustal_outfile);
		fprintf(stdout,"\nCLUSTAL-Alignment file created  [%s]\n",clustal_outname);
	}
	if(output_nbrf)  {
		nbrf_out(nbrf_outfile);
		fclose(nbrf_outfile);
		fprintf(stdout,"\nNBRF/PIR-Alignment file created [%s]\n",nbrf_outname);
	}
	if(output_gcg)  {
		gcg_out(gcg_outfile);
		fclose(gcg_outfile);
		fprintf(stdout,"\nGCG-Alignment file created      [%s]\n",gcg_outname);
	}
	if(output_phylip)  {
		phylip_out(phylip_outfile);
		fclose(phylip_outfile);
		fprintf(stdout,"\nPHYLIP-Alignment file created   [%s]\n",phylip_outname);
	}
}






static void reset()   /* remove gaps from older alignments (code = -1) */
{		      /* EXCEPT for gaps that were INPUT with the seqs.*/
	register int i,j,sl;   		     /* which have  code = -2  */
	
	for(i=1;i<=nseqs;++i) {
		sl=0;
		for(j=1;j<=seqlen_array[i];++j) {
			if(seq_array[i][j] == -1) continue;
			++sl;
			seq_array[i][sl]=seq_array[i][j];
		}
		seqlen_array[i]=sl;
	}
}



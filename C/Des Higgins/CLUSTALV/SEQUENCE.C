/********* Sequence input routines for CLUSTALV *******************/
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "clustalv.h"	


/*
*	Prototypes
*/

extern Boolean linetype(char *,char *);
extern void warning(char *,...);
extern void error(char *,...);
extern char *	rtrim(char *);
extern void 	getstr(char *,char *);

void fill_chartab(void);
int readseqs(int);

static void get_seq(char *,char *,int *,char *);
static void check_infile(int *);
static void p_encode(char *, char *, int);
static void n_encode(char *, char *, int);
static int res_index(char *,char);
static Boolean check_dnaflag(char *, int);
/*
 *	Global variables
 */

extern FILE *fin;
extern Boolean usemenu, dnaflag, explicit_dnaflag;
extern char seqname[];
extern int nseqs;
extern int *seqlen_array;
extern char **names,**titles;
extern char **seq_array;
extern profile1_empty, profile2_empty;

char *amino_acid_codes   =    "ABCDEFGHIKLMNPQRSTUVWXYZ-"; 
char *amino_acid_order   =    "XCSTPAGNDEQHRKMILVFYW";
char *nucleic_acid_order = 	  "NACGTU";
static int seqFormat;
static char chartab[256];
static char *formatNames[] = {"unknown","EMBL/Swiss-Prot","PIR","Pearson"};

void fill_chartab()	/* Create translation and check table */
{
/*	static char valid[]="ABCDEFGHIKLMNPQRSTVWXYZ-";  */
	register int i;
	register char c;
	
	for(i=0;i<256;chartab[i++]=0);
	for(i=0;c=amino_acid_codes[i];i++)
		chartab[c]=chartab[tolower(c)]=c;
}



static void get_seq(char *sname,char *seq,int *len,char *tit)
{
	static char line[MAXLINE+1];
	int i;
        unsigned char c;

	switch(seqFormat) {
		case EMBLSWISS:
			while( !linetype(line,"ID") )
				fgets(line,MAXLINE+1,fin);
			
		strncpy(sname,line+5,MAXNAMES); /* remember entryname */
			sname[MAXNAMES]=EOS;
			rtrim(sname);

/*			while( !linetype(line,"DE") )
				fgets(line,MAXLINE+1,fin);
			strncpy(tit,line+5,MAXTITLES);
			tit[MAXTITLES]=EOS;
			i=strlen(tit);
			if(tit[i-1]=='\n') tit[i-1]=EOS;
*/
			while( !linetype(line,"SQ") )
				fgets(line,MAXLINE+1,fin);
			
			*len=0;
		while(fgets(line,MAXLINE+1,fin)) {
			for(i=0;*len < MAXLEN;i++) {
				c=line[i];
			if(c == '\n' || c == EOS || c == '/')
				break;			/* EOL */
		
			if( (c=chartab[c]))
				seq[++(*len)]=c;
		}
		if(*len == MAXLEN || c == '/') break;
		}
		break;
		
		case PIR:
			while(*line != '>')
				fgets(line,MAXLINE+1,fin);
			
			strncpy(sname,line+4,MAXNAMES);
			sname[MAXNAMES]=EOS;
			for(i=MAXNAMES-1;i > 0;i--) 
				if(isspace(sname[i])) {
					sname[i]=EOS;	
					break;
				}		

			fgets(line,MAXLINE+1,fin);
			strncpy(tit,line,MAXTITLES);
			tit[MAXTITLES]=EOS;
			i=strlen(tit);
			if(tit[i-1]=='\n') tit[i-1]=EOS;
			
			*len=0;
			while(fgets(line,MAXLINE+1,fin)) {
				for(i=0;*len < MAXLEN;i++) {
					c=line[i];
				if(c == '\n' || c == EOS || c == '*')
					break;			/* EOL */
			
				if( (c=chartab[c]))
					seq[++(*len)]=c;
			}
			if(*len == MAXLEN || c == '*') break;
			}
		break;

		case PEARSON:
			while(*line != '>')
				fgets(line,MAXLINE+1,fin);
			
			strncpy(sname,line+1,MAXNAMES);
			sname[MAXNAMES]=EOS;
			for(i=MAXNAMES-1;i > 0;i--) 
				if(isspace(sname[i])) {
					sname[i]=EOS;	
					break;
				}		
			*tit=EOS;
			
			*len=0;
			while(fgets(line,MAXLINE+1,fin)) {
				for(i=0;*len < MAXLEN;i++) {
					c=line[i];
				if(c == '\n' || c == EOS || c == '>')
					break;			/* EOL */
			
				if( (c=chartab[c]))
					seq[++(*len)]=c;
			}
			if(*len == MAXLEN || c == '>') break;
			}
		break;
	}
	
	if(*len == MAXLEN)
		warning("Sequence %s truncated to %d residues",
				sname,MAXLEN);
				
	seq[*len+1]=EOS;
}


int readseqs(int first_seq) /*first_seq is the #no. of the first seq. to read */
{
	char line[FILENAMELEN+1];
	static char seq1[MAXLEN+2],sname1[MAXNAMES+1],title[MAXTITLES+1];
	int i,j,no_seqs;
	static int l1;
	static Boolean dnaflag1;
	
	if(usemenu)
		getstr("Enter the name of the sequence file",line);
	else
		strcpy(line,seqname);
	if(*line == EOS) return -1;
	
	if((fin=fopen(line,"r"))==NULL) {
		error("Could not open sequence file %s",line);
		return -1;      /* DES -1 => file not found */
	}
	strcpy(seqname,line);
	no_seqs=0;
	check_infile(&no_seqs);
	printf("\nSequence format is %s\n",formatNames[seqFormat]);
	if(no_seqs == 0)
		return 0;       /* return the number of seqs. (zero here)*/

	if((no_seqs + first_seq -1) > MAXN) {
		error("Too many sequences. Maximum is %d",MAXN);
		return 0;       /* also return zero if too many */
	}

	for(i=first_seq;i<=first_seq+no_seqs-1;++i) {    /* get the seqs now*/
		get_seq(sname1,seq1,&l1,title);
		seqlen_array[i]=l1;                   /* store the length */
		strcpy(names[i],sname1);              /*    "   "  name   */
		strcpy(titles[i],title);              /*    "   "  title  */

		if(!explicit_dnaflag) {
			dnaflag1 = check_dnaflag(seq1,l1); /* check DNA/Prot */
		        if(i == 1) dnaflag = dnaflag1;
		}			/* type decided by first seq*/
		else
			dnaflag1 = dnaflag;

		if( (!explicit_dnaflag) && (dnaflag1 != dnaflag) )
			warning(
	"Sequence %d [%s] appears to be of different type to sequence 1",
			i,sname1);

		if(dnaflag)
			n_encode(seq1,seq_array[i],l1); /* encode the sequence*/
		else					/* as ints  */
			p_encode(seq1,seq_array[i],l1);
	}

	fclose(fin);
	return no_seqs;    /* return the number of seqs. read in this call */
}


static Boolean check_dnaflag(char *seq, int slen)
/* check if DNA or Protein
   The decision is based on counting all A,C,G,T,U or N. 
   If >= 85% of all characters (except -) are as above => DNA  */
{
	int i, c, nresidues, nbases;
	float ratio;
	
	nresidues = nbases = 0;	
	for(i=1; i <= slen; i++) {
		if(seq[i] != '-') {
			nresidues++;
			if(seq[i] == 'N')
				nbases++;
			else {
				c = res_index(nucleic_acid_order, seq[i]);
				if(c > 0)
					nbases++;
			}
		}
	}
	if( (nbases == 0) || (nresidues == 0) ) return FALSE;
	ratio = (float)nbases/(float)nresidues;
/*
	fprintf(stdout,"\n nbases = %d, nresidues = %d, ratio = %f\n",
		nbases,nresidues,ratio);
*/
	if(ratio >= 0.85) 
		return TRUE;
	else
		return FALSE;
}



static void check_infile(int *nseqs)
{
	char line[MAXLINE+1];
	
	*nseqs=0;
	fgets(line,MAXLINE+1,fin);
	if( linetype(line,"ID") )					/* EMBL/Swiss-Prot format ? */
		seqFormat=EMBLSWISS;
	else if(*line == '>')						/* no */
		seqFormat=(line[3] == ';')?PIR:PEARSON; /* distinguish PIR and Pearson */
	else {
		seqFormat=UNKNOWN;
		return;
	}

	(*nseqs)++;
	
	while(fgets(line,MAXLINE+1,fin) != NULL) {
		switch(seqFormat) {
			case EMBLSWISS:
				if( linetype(line,"ID") )
					(*nseqs)++;
				break;
			case PIR:
			case PEARSON:
				if( *line == '>' )
					(*nseqs)++;
				break;
			default:
				break;
		}
	}
	fseek(fin,0,0);
}

static void p_encode(char *seq, char *naseq, int l)
{					/* code seq as ints .. use -2 for gap */
	register int i;
/*	static char *aacids="CSTPAGNDEQHRKMILVFYW";*/
	
	for(i=1;i<=l;i++)
		if(seq[i] == '-')
			naseq[i] = -2;
		else if(seq[i] == 'X') 
			naseq[i] = 0;
		else
			naseq[i] = res_index(amino_acid_order,seq[i]);
}

static void n_encode(char *seq,char *naseq,int l)
{					/* code seq as ints .. use -2 for gap */
	register int i,c;
/*	static char *nucs="ACGTU";	*/
	
	for(i=1;i<=l;i++) {
    	if(seq[i] == '-')          	   /* if a gap character -> code = -2 */
			naseq[i] = -2;     /* this is the code for a gap in */
		else {                     /* the input files */
			c=res_index(nucleic_acid_order,seq[i]);
			if (c == 5) c=4;
			naseq[i]=c;
		}
	}
}

static int res_index(char *t,char c)
{
	register int i;
	
	for(i=0;t[i] && t[i] != c;i++)
		;
	if(t[i]) return(i);
	else return 0;
}

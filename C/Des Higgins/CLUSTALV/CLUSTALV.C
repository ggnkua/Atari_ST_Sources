#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#ifdef THINK_C
#include <console.h>
#endif
#include "clustalv.h"
#include "matrices.h"

/*
*	Prototypes
*/

extern void *ckalloc(size_t);
extern init_show_pair(void);
extern init_upgma(void);
extern init_myers(void);
extern void init_amenu(void);
extern void init_trees(void);
extern fill_chartab(void);
extern void parse_params(void);
extern void main_menu(void);

void make_pamo(int);
Boolean read_tree(int *,double *,int *,int *,int *);

static void alloc_mem(void);


/*
*	Global variables
*/

extern Boolean usemenu;

char  **seq_array;
int  *seqlen_array;
char **names,**titles;
char *params;
FILE *fin,*tree;
FILE *clustal_outfile, *gcg_outfile, *nbrf_outfile, *phylip_outfile;
char *matptr;
int xover,big_pam,little_pam;
int pamo[210];
Boolean dnaflag;
char seqname[FILENAMELEN+1],mtrxname[FILENAMELEN+1],treename[FILENAMELEN+1];
int nblocks,nseqs,next;
double **tmat;


static void alloc_mem()
{
	register int i;
	
	seqlen_array = (int *)ckalloc( (MAXN+1) * sizeof (int));

	seq_array = (char **)ckalloc( (MAXN + 1) * sizeof (char *) );
	for(i=0;i<MAXN+1;i++)
		seq_array[i]=(char *)ckalloc( (MAXLEN +2) * sizeof (char));
				
	names = (char **)ckalloc( (MAXN+1) * sizeof (char *) );
	for(i=0;i<MAXN+1;i++)
		names[i] = (char *)ckalloc(MAXNAMES+1 * sizeof (char));
		
	titles = (char **)ckalloc( (MAXN) * sizeof (char *) );
	for(i=0;i<MAXN;i++)
		titles[i] = (char *)ckalloc(MAXTITLES+1 * sizeof (char));

	tmat = (double **) ckalloc( (MAXN+1) * sizeof (double *) );
	for(i=0;i<MAXN+1;i++)
		tmat[i] = (double *)ckalloc( (MAXN+1) * sizeof (double) );

	params = (char *)ckalloc(1024 * sizeof(char));
}


Boolean read_tree(int *n,double *s,int *a,int *b,int *ptr)
{
	char line[MAXLINE+1];
	int i,seq_no;
	/* Reads one entry from the tree file */

	
	for(i=0; i<=MAXLINE; i++) line[i] = ' ';
 
	if(fgets(line,MAXLINE+1,tree)==NULL) return FALSE;

	sscanf(line,"%f%d%d%d",s,a,b,n);
	for(i=MAXLINE, seq_no=nseqs; seq_no>0; i--) {
			if(line[i] == '0') {
				ptr[seq_no] = 0;
				--seq_no;
			}
			else if(line[i] == '1') {
				ptr[seq_no] = 1;
				--seq_no;
			}
			else if(line[i] == '2') {
				ptr[seq_no] = 2;
				--seq_no;
			}	
	}
	return TRUE;
}


void make_pamo(int nv)
{
	register int i,c;
	
	little_pam=big_pam=matptr[0];
	for(i=0;i<210;++i) {
		c=matptr[i];
		little_pam=(little_pam<c) ? little_pam : c;
		big_pam=(big_pam>c) ? big_pam : c;
	}
	for(i=0;i<210;++i)
		pamo[i]= matptr[i]-little_pam;
	nv -= little_pam;
	big_pam -= little_pam;
	xover = big_pam - nv;
/*
	fprintf(stdout,"\n\nxover= %d, big_pam = %d, little_pam=%d, nv = %d\n\n"
		,xover,big_pam,little_pam,nv);
*/
}



void main(int argc,char **argv)
{
	int i;

#ifdef THINK_C
	argc=ccommand(&argv);
#endif

	matptr=pam250mt;	
	
	alloc_mem();
	init_show_pair();
	init_upgma();
	init_myers();
	init_amenu();
        init_trees();
	
	fill_chartab();
	make_pamo(0);
	if(argc>1) {
		params[0]=EOS;
		for(i=1;i<argc;++i) 
			strcat(params,argv[i]);
		usemenu=FALSE;
		parse_params();
	}
	else {	
		usemenu=TRUE;
		main_menu();
	}
}

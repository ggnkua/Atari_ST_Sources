	/* Phyle of filogenetic tree calculating functions for CLUSTAL V */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "clustalv.h"

/*
 *   Prototypes
 */

extern void *ckalloc(size_t);
extern int getint(char *, int, int, int);
extern void get_path(char *, char *);
extern FILE * open_output_file(char *, char *, char *, char *);


void init_trees(void);
void phylogenetic_tree(void);
void bootstrap_tree(void);
void compare_tree(char **, char **, int *, int);
void tree_gap_delete(void); /*flag all positions in alignment that have a gap */
void dna_distance_matrix(FILE *);
void prot_distance_matrix(FILE *);
void nj_tree(char **, FILE *);
void print_tree(char **, FILE *, int *);
void root_tree(char **, int);

Boolean transition(int,int);

/*
 *   Global variables
 */


extern double **tmat;     /* general nxn array of reals; allocated from main */
                          /* this is used as a distance matrix */
extern double **smat;
extern Boolean dnaflag;   /* TRUE for DNA seqs; FALSE for proteins */
extern Boolean tossgaps;  /* Ignore places in align. where ANY seq. has a gap*/
extern Boolean kimura;    /* Use correction for multiple substitutions */
extern Boolean empty;     /* any sequences in memory? */
extern Boolean usemenu;   /* interactive (TRUE) or command line (FALSE) */
extern void error(char *,...);  /* error reporting */
extern int nseqs;         /* total no. of seqs. */
extern int *seqlen_array; /* the lengths of the sequences */
extern char **seq_array;   /* the sequences */
extern char **names;       /* the seq. names */
extern char seqname[];		/* name of input file */

static double *av;
static int *kill;
static int ran_factor;
int boot_ntrials;			/* number of bootstrap trials */
unsigned int boot_ran_seed;		/* random number generator seed */
static int root_sequence;
static int *boot_positions;
static int *boot_totals;
static char **standard_tree;
static char **sample_tree;
static FILE *phy_tree_file;
static char phy_tree_name[FILENAMELEN+1];
static Boolean verbose;
static char *tree_gaps;    /* array of weights; 1 for use this posn.; 0 don't */


void init_trees()
{
	register int i;
	
	tree_gaps = (char *)ckalloc( (MAXLEN+1) * sizeof (char) );
        
	boot_positions = (int *)ckalloc( (MAXLEN+1) * sizeof (int) );
	boot_totals    = (int *)ckalloc( (MAXN+1) * sizeof (int) );

	kill = (int *) ckalloc( (MAXN+1) * sizeof (int) );
	av   = (double *) ckalloc( (MAXN+1) * sizeof (double)   );

	standard_tree = (char **) ckalloc( (MAXN+1) * sizeof (char *) );
	for(i=0; i<MAXN+1; i++) 
		standard_tree[i] = (char *) ckalloc( (MAXN+1) * sizeof(char) );

	sample_tree   = (char **) ckalloc( (MAXN+1) * sizeof (char *) );
	for(i=0; i<MAXN+1; i++) 
		sample_tree[i]   = (char *) ckalloc( (MAXN+1) * sizeof(char) );

	boot_ntrials  = 1000;
	boot_ran_seed = 111;
        kimura   = FALSE;
        tossgaps = FALSE;	
}



void phylogenetic_tree()
{	char path[FILENAMELEN+1];
	int j;

	if(empty) {
		error("You must load an alignment first");
		return;
	}

	get_path(seqname,path);
	
	if((phy_tree_file = open_output_file(
		"\nEnter name for tree output file  ",path,
		phy_tree_name,"nj")) == NULL) return;

	for(j=1; j<=seqlen_array[1]; ++j) 
		boot_positions[j] = j;		

	verbose = TRUE;                  /* Turn on screen output */
	if(dnaflag)
		dna_distance_matrix(phy_tree_file);
	else 
		prot_distance_matrix(phy_tree_file);

	verbose = TRUE;			  /* Turn on output */
	nj_tree(standard_tree,phy_tree_file);
	fclose(phy_tree_file);	
/*
	print_tree(standard_tree,phy_tree_file);
*/
	fprintf(stdout,"\nPhylogenetic tree file created:   [%s]",phy_tree_name);
}





Boolean transition(int base1, int base2) /* TRUE if transition; else FALSE */
/* 

   assumes that the bases of DNA sequences have been translated as
   a,A = 1;   c,C = 2;   g,G = 3;   t,T,u,U = 4;  X or N = 0;  "-" < 0;

   A <--> G  and  T <--> C  are transitions;  all others are transversions.

*/
{
	if( ((base1 == 1) && (base2 == 3)) || ((base1 == 3) && (base2 == 1)) )
		return TRUE;                                     /* A <--> G */
	if( ((base1 == 4) && (base2 == 2)) || ((base1 == 2) && (base2 == 4)) )
		return TRUE;                                     /* T <--> C */
    return FALSE;
}


void tree_gap_delete()   /* flag all positions in alignment that have a gap */
{			  /* in ANY sequence */
	int seqn, posn;

	for(posn=1; posn<=seqlen_array[1]; ++posn) {
		tree_gaps[posn] = 0;
     	for(seqn=1; seqn<=nseqs; ++seqn)  {
			if(seq_array[seqn][posn] <= 0) {
			   tree_gaps[posn] = 1;
				break;
			}
		}
	}
}



void nj_tree(char **tree_description, FILE *tree)
{
	register int i;
	int l[4],nude,k;
	int nc,mini,minj,j,j1,ii,jj;
	double fnseqs,fnseqs2,sumd;
	double diq,djq,dij,d2r,dr,dio,djo,da;
	double tmin,total,dmin;
	double bi,bj,b1,b2,b3,branch[4];
	int typei,typej,type[4];             /* 0 = node; 1 = OTU */
	
	fnseqs = (double)nseqs;

/*********************** First initialisation ***************************/
	
	if(verbose)  {
		fprintf(tree,"\n\n\t\t\tNeighbor-joining Method\n");
		fprintf(tree,"\n Saitou, N. and Nei, M. (1987)");
		fprintf(tree," The Neighbor-joining Method:");
		fprintf(tree,"\n A New Method for Reconstructing Phylogenetic Trees.");
		fprintf(tree,"\n Mol. Biol. Evol., 4(4), 406-425\n");
		fprintf(tree,"\n\n This is an UNROOTED tree\n");
		fprintf(tree,"\n Numbers in parentheses are branch lengths\n\n");
	}	

	mini = minj = 0;

	for(i=1;i<=nseqs;++i) 
		{
		tmat[i][i] = av[i] = 0.0;
		kill[i] = 0;
		}

/*********************** Enter The Main Cycle ***************************/

 /*	for(nc=1; nc<=(nseqs-3); ++nc) {  */            	/**start main cycle**/
	for(nc=1; nc<=(nseqs-3); ++nc) {
		sumd = 0.0;
		for(j=2; j<=nseqs; ++j)
			for(i=1; i<j; ++i) {
				tmat[j][i] = tmat[i][j];
				sumd = sumd + tmat[i][j];
				smat[i][j] = smat[j][i] = 0.0;
			}

		tmin = 99999.0;

/*.................compute SMATij values and find the smallest one ........*/

		for(jj=2; jj<=nseqs; ++jj) 
			if(kill[jj] != 1) 
				for(ii=1; ii<jj; ++ii)
					if(kill[ii] != 1) {
						diq = djq = 0.0;

						for(i=1; i<=nseqs; ++i) {
							diq = diq + tmat[i][ii];
							djq = djq + tmat[i][jj];
						}

						dij = tmat[ii][jj];
						d2r = diq + djq - (2.0*dij);
						dr  = sumd - dij -d2r;
						fnseqs2 = fnseqs - 2.0;
					        total= d2r+ fnseqs2*dij +dr*2.0;
						total= total / (2.0*fnseqs2);
						smat[ii][jj] = total;

						if(total < tmin) {
							tmin = total;
							mini = ii;
							minj = jj;
						}
					}
		

/*.................compute branch lengths and print the results ........*/


		dio = djo = 0.0;
		for(i=1; i<=nseqs; ++i) {
			dio = dio + tmat[i][mini];
			djo = djo + tmat[i][minj];
		}

		dmin = tmat[mini][minj];
		dio = (dio - dmin) / fnseqs2;
		djo = (djo - dmin) / fnseqs2;
		bi = (dmin + dio - djo) * 0.5;
		bj = dmin - bi;
		bi = bi - av[mini];
		bj = bj - av[minj];

		if( av[mini] > 0.0 )
			typei = 0;
		else
			typei = 1;
		if( av[minj] > 0.0 )
			typej = 0;
		else
			typej = 1;

		if(verbose) {
	 	    fprintf(tree,"\n Cycle%4d     = ",nc);
		    if(typei == 0)
			fprintf(tree,"Node:%4d (%9.5f) joins ",mini,bi);
		    else
		 	fprintf(tree," SEQ:%4d (%9.5f) joins ",mini,bi);
		    if(typej == 0) 
			fprintf(tree,"Node:%4d (%9.5f)",minj,bj);
		    else
			fprintf(tree," SEQ:%4d (%9.5f)",minj,bj);
			fprintf(tree,"\n");
		}

		for(i=1; i<=nseqs; i++)
			tree_description[nc][i] = 0;

	     	if(typei == 0) { 
			for(i=nc-1; i>=1; i--)
				if(tree_description[i][mini] == 1) {
					for(j=1; j<=nseqs; j++)  
					     if(tree_description[i][j] == 1)
						    tree_description[nc][j] = 1;
					break;
				}
		}
		else
			tree_description[nc][mini] = 1;

		if(typej == 0) {
			for(i=nc-1; i>=1; i--) 
				if(tree_description[i][minj] == 1) {
					for(j=1; j<=nseqs; j++)  
					     if(tree_description[i][j] == 1)
						    tree_description[nc][j] = 1;
					break;
				}
		}
		else
			tree_description[nc][minj] = 1;
			
		if(dmin <= 0.0) dmin = 0.0001;
		av[mini] = dmin * 0.5;

/*........................Re-initialisation................................*/

		fnseqs = fnseqs - 1.0;
		kill[minj] = 1;

		for(j=1; j<=nseqs; ++j) 
			if( kill[j] != 1 ) {
				da = ( tmat[mini][j] + tmat[minj][j] ) * 0.5;
				if( (mini - j) < 0 ) 
					tmat[mini][j] = da;
				if( (mini - j) > 0)
					tmat[j][mini] = da;
			}

		for(j=1; j<=nseqs; ++j)
			tmat[minj][j] = tmat[j][minj] = 0.0;


/****/	}						/**end main cycle**/

/******************************Last Cycle (3 Seqs. left)********************/

	nude = 1;

	for(i=1; i<=nseqs; ++i)
		if( kill[i] != 1 ) {
			l[nude] = i;
			nude = nude + 1;
		}

	b1 = (tmat[l[1]][l[2]] + tmat[l[1]][l[3]] - tmat[l[2]][l[3]]) * 0.5;
	b2 =  tmat[l[1]][l[2]] - b1;
	b3 =  tmat[l[1]][l[3]] - b1;
	branch[1] = b1 - av[l[1]];
	branch[2] = b2 - av[l[2]];
	branch[3] = b3 - av[l[3]];


	for(i=1; i<=nseqs; i++)
		tree_description[nseqs-2][i] = 0;

	if(verbose)
		fprintf(tree,"\n Cycle%4d (Last cycle, trichotomy):\n",nc);

	for(i=1; i<=3; ++i) {
	   if( av[l[i]] > 0.0) {
	      	if(verbose)
	      	    fprintf(tree,"\n\t\t Node:%4d (%9.5f) ",l[i],branch[i]);
		for(k=nseqs-3; k>=1; k--)
			if(tree_description[k][l[i]] == 1) {
				for(j=1; j<=nseqs; j++)
				 	if(tree_description[k][j] == 1)
					    tree_description[nseqs-2][j] = i;
				break;
			}
	   }
	   else  {
	      	if(verbose)
	   	    fprintf(tree,"\n\t\t  SEQ:%4d (%9.5f) ",l[i],branch[i]);
		tree_description[nseqs-2][l[i]] = i;
	   }
	   if(i < 3) {
	      	if(verbose)
	            fprintf(tree,"joins");
	   }
	}

	if(verbose)
		fprintf(tree,"\n");

}




void bootstrap_tree()
{
	int i,j,ranno;
	int k,l,m,p;
	unsigned int num;
	char lin2[MAXLINE],path[MAXLINE+1];

	if(empty) {
		error("You must load an alignment first");
		return;
	}

	get_path(seqname, path);
	
	if((phy_tree_file = open_output_file(
		"\nEnter name for bootstrap output file  ",path,
		phy_tree_name,"njb")) == NULL) return;

	for(i=0;i<MAXN+1;i++)
		boot_totals[i]=0;
		
	for(j=1; j<=seqlen_array[1]; ++j)  /* First select all positions for */
		boot_positions[j] = j;	   /* the "standard" tree */

	verbose = TRUE;            	   /* Turn on screen output */
	if(dnaflag)
		dna_distance_matrix(phy_tree_file);
	else 
		prot_distance_matrix(phy_tree_file);

	verbose = TRUE;			  	/* Turn on screen output */
	nj_tree(standard_tree, phy_tree_file);	/* compute the standard tree */

	fprintf(phy_tree_file,"\n\n\t\t\tBootstrap Confidence Limits\n\n");

	ran_factor = RAND_MAX / seqlen_array[1];

	if(usemenu) 
  	 	boot_ran_seed = 
getint("\n\nEnter seed no. for random number generator ",1,1000,boot_ran_seed);

	srand(boot_ran_seed);
	fprintf(phy_tree_file,"\n Random number generator seed = %7u\n",
	boot_ran_seed);

	if(usemenu) 
	  	boot_ntrials = 
getint("\n\nEnter number of bootstrap trials ",1,10000,boot_ntrials);

  	fprintf(phy_tree_file,"\n Number of bootstrap trials   = %7d\n",
	boot_ntrials);

	fprintf(phy_tree_file,
	"\n\n Diagrammatic representation of the above tree: \n");
	fprintf(phy_tree_file,"\n Each row represents 1 tree cycle;");
	fprintf(phy_tree_file," defining 2 groups.\n");
	fprintf(phy_tree_file,"\n Each column is 1 sequence; ");
	fprintf(phy_tree_file,"the stars in each line show 1 group; ");
	fprintf(phy_tree_file,"\n the dots show the other\n");
	fprintf(phy_tree_file,"\n Numbers show occurences in bootstrap samples.");
/*
	print_tree(standard_tree, phy_tree_file, boot_totals);
*/
	verbose = FALSE;                   /* Turn OFF screen output */

	fprintf(stdout,"\n\nEach dot represents 10 trials\n\n");
	for(i=1; i<=boot_ntrials; ++i) {
		for(j=1; j<=seqlen_array[1]; ++j) {	  /* select alignment */
			ranno = ( rand() / ran_factor ) + 1; /* positions for */
			boot_positions[j] = ranno; 	  /* bootstrap sample */
		}
		if(dnaflag)
			dna_distance_matrix(phy_tree_file);
		else
			prot_distance_matrix(phy_tree_file);
		nj_tree(sample_tree, phy_tree_file); /* compute 1 sample tree */
		compare_tree(standard_tree, sample_tree, boot_totals, nseqs);
		if(i % 10  == 0) fprintf(stdout,".");
		if(i % 100 == 0) fprintf(stdout,"\n");
	}

/*
	fprintf(phy_tree_file,"\n\n Bootstrap totals for each group\n");
*/
	print_tree(standard_tree, phy_tree_file, boot_totals);

	fclose(phy_tree_file);

	fprintf(stdout,"\n\nBootstrap output file completed       [%s]"
		,phy_tree_name);
}


void compare_tree(char **tree1, char **tree2, int *hits, int n)
{	
	int i,j,k,l;
	int nhits1, nhits2;

	for(i=1; i<=n-3; i++)  {
		for(j=1; j<=n-3; j++)  {
			nhits1 = 0;
			nhits2 = 0;
			for(k=1; k<=n; k++) {
				if(tree1[i][k] == tree2[j][k]) nhits1++;
				if(tree1[i][k] != tree2[j][k]) nhits2++;
			}
			if((nhits1 == nseqs) || (nhits2 == nseqs)) hits[i]++;
		}
	}
}




void print_tree(char **tree_description, FILE *tree, int *totals)
{
	int row,col;

	fprintf(tree,"\n");

	for(row=1; row<=nseqs-3; row++)  {
		fprintf(tree," \n");
		for(col=1; col<=nseqs; col++) { 
			if(tree_description[row][col] == 0)
				fprintf(tree,"*");
			else
				fprintf(tree,".");
		}
		if(totals[row] > 0)
			fprintf(tree,"%7d",totals[row]);
	}
	fprintf(tree," \n");
	for(col=1; col<=nseqs; col++) 
		fprintf(tree,"%1d",tree_description[nseqs-2][col]);
	fprintf(tree,"\n");
}



void dna_distance_matrix(FILE *tree)
{   
	int m,n,j,i;
	int res1, res2;
	double p,q,e,a,b,k;	

	tree_gap_delete();  /* flag positions with gaps (tree_gaps[i] = 1 ) */
	
	if(verbose) {
		fprintf(tree,"\n");
		fprintf(tree,"\n DIST   = percentage divergence (/100)");
		fprintf(tree,"\n p      = rate of transition (A <-> G; C <-> T)");
		fprintf(tree,"\n q      = rate of transversion");
		fprintf(tree,"\n Length = number of sites used in comparison");
		fprintf(tree,"\n");
	    if(tossgaps) {
		fprintf(tree,"\n All sites with gaps (in any sequence) deleted!");
		fprintf(tree,"\n");
	    }
	    if(kimura) {
		fprintf(tree,"\n Distances corrected by Kimura's 2 parameter model:");
		fprintf(tree,"\n\n Kimura, M. (1980)");
		fprintf(tree," A simple method for estimating evolutionary ");
		fprintf(tree,"rates of base");
		fprintf(tree,"\n substitutions through comparative studies of ");
		fprintf(tree,"nucleotide sequences.");
		fprintf(tree,"\n J. Mol. Evol., 16, 111-120.");
		fprintf(tree,"\n\n");
	    }
	}

	for(m=1;   m<nseqs;  ++m)     /* for every pair of sequence */
	for(n=m+1; n<=nseqs; ++n) {
		p = q = e = 0.0;
		tmat[m][n] = tmat[n][m] = 0.0;
		for(i=1; i<=seqlen_array[1]; ++i) {
			j = boot_positions[i];
                    	if(tossgaps && (tree_gaps[j] > 0) ) 
				goto skip;          /* gap position */
			res1 = seq_array[m][j];
			res2 = seq_array[n][j];
			if( (res1 < 1) || (res2 < 1) )  
				goto skip;          /* gap in a seq*/
			e = e + 1.0;
                        if(res1 != res2) {
				if(transition(res1,res2))
					p = p + 1.0;
				else
					q = q + 1.0;
			}
		        skip:;
		}


	/* Kimura's 2 parameter correction for multiple substitutions */

		if(!kimura) {
			k = (p+q)/e;
			if(p > 0.0)
				p = p/e;
			else
				p = 0.0;
			if(q > 0.0)
				q = q/e;
			else
				q = 0.0;
			tmat[m][n] = tmat[n][m] = k;
			if(verbose)                    /* if screen output */
				fprintf(tree,        
 	     "%4d vs.%4d:  DIST = %7.4f; p = %6.4f; q = %6.4f; length = %6.0f\n"
        	                 ,m,n,k,p,q,e);
		}
		else {
			if(p > 0.0)
				p = p/e;
			else
				p = 0.0;
			if(q > 0.0)
				q = q/e;
			else
				q = 0.0;
			a = 1.0/(1.0-2.0*p-q);
			b = 1.0/(1.0-2.0*q);
			k = 0.5*log(a) + 0.25*log(b);
			tmat[m][n] = tmat[n][m] = k;
			if(verbose)                      /* if screen output */
	   			fprintf(tree,
             "%4d vs.%4d:  DIST = %7.4f; p = %6.4f; q = %6.4f; length = %6.0f\n"
        	                ,m,n,k,p,q,e);

		}
	}
}



void prot_distance_matrix(FILE *tree)
{
	int m,n,j,i;
	int res1, res2;
	double p,e,a,b,k;	

	tree_gap_delete();  /* flag positions with gaps (tree_gaps[i] = 1 ) */
	
	if(verbose) {
		fprintf(tree,"\n");
		fprintf(tree,"\n DIST   = percentage divergence (/100)");
		fprintf(tree,"\n Length = number of sites used in comparison");
		fprintf(tree,"\n\n");
	        if(tossgaps) {
			fprintf(tree,"\n All sites with gaps (in any sequence) deleted");
			fprintf(tree,"\n");
		}
	    	if(kimura) {
			fprintf(tree,"\n Distances corrected by Kimura's empirical method:");
			fprintf(tree,"\n\n Kimura, M. (1983)");
			fprintf(tree," The Neutral Theory of Molecular Evolution.");
			fprintf(tree,"\n Cambridge University Press, Cambridge, England.");
			fprintf(tree,"\n\n");
	    	}
	}

	for(m=1;   m<nseqs;  ++m)     /* for every pair of sequence */
	for(n=m+1; n<=nseqs; ++n) {
		p = e = 0.0;
		tmat[m][n] = tmat[n][m] = 0.0;
		for(i=1; i<=seqlen_array[1]; ++i) {
			j = boot_positions[i];
	            	if(tossgaps && (tree_gaps[j] > 0) ) goto skip; /* gap position */
			res1 = seq_array[m][j];
			res2 = seq_array[n][j];
			if( (res1 < 1) || (res2 < 1) )  goto skip;   /* gap in a seq*/
			e = e + 1.0;
                        if(res1 != res2) p = p + 1.0;
		        skip:;
		}

		if(p <= 0.0) 
			k = 0.0;
		else
			k = p/e;

		if(kimura) 
			if(k > 0.0) k = - log(1.0 - k - (k * k/5.0) );

		tmat[m][n] = tmat[n][m] = k;
		    if(verbose)                    /* if screen output */
			fprintf(tree,        
 	                 "%4d vs.%4d  DIST = %6.4f;  length = %6.0f\n",m,n,k,e);
	}
}



#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "clustalv.h"

/*
*	Prototypes
*/

extern Boolean read_tree(int *,double *,int *,int *,int *);
extern void *ckalloc(size_t);

void init_myers(void);
void myers(int);

static void group_gap(int,int,char *);
static void add_ggaps(void);
static void add(int);
static int calc_weight(int,int,int,int);
static void fill_pam(void);
static int diff(int,int,int,int,int,int);
static void do_align(int,int *);
static int *alist;
static int	** naa1,**naa2,**naas;

/*
*	Global variables
*/

extern int nseqs, next, profile1_nseqs;    /* DES */
extern int *seqlen_array;
extern char **seq_array;
extern int pamo[];
extern Boolean dnaflag,percent;
extern int xover,big_pam;
extern int nblocks;
extern FILE *clustal_outfile,*tree;
extern char treename[],seqname[],mtrxnam[],**names;
extern char *matptr,idmat[],pam100mt[],pam250mt[];
extern int ktup,wind_gap,window;
extern int signif;


int      gap_open,      gap_extend;
int  dna_gap_open,  dna_gap_extend;
int prot_gap_open, prot_gap_extend;

Boolean is_weight;

extern int *zza,*zzb,*zzc,*zzd;		/* allocated in show_pair.c     */
static int *group;
static int print_ptr,last_print,pos1,pos2;
extern int * displ;					/* allocated in show_pair.c		*/
static int pam[21][21];
 int	weights[21][21];
static int *fst_list,*snd_list;

#define gap(x)  ((x) <= 0 ? 0 : gap_open + gap_extend * (x))

void init_myers()
{
	register int i;
	
	group = (int *)ckalloc( (MAXN+1) * sizeof (int));

	alist = (int *)ckalloc( (MAXN+1) * sizeof (int));
	fst_list = (int *)ckalloc( (MAXN+1) * sizeof (int));
	snd_list = (int *)ckalloc( (MAXN+1) * sizeof (int));

	naa1 = (int **)ckalloc(21 * sizeof (int *) );
	for(i=0;i<21;i++)
		naa1[i]=(int *)ckalloc( (MAXLEN+1)*sizeof (int));
	naa2 = (int **)ckalloc(21 * sizeof (int *) );
	for(i=0;i<21;i++)
		naa2[i]=(int *)ckalloc( (MAXLEN+1)*sizeof (int));
	naas = (int **)ckalloc(21 * sizeof (int *) );
	for(i=0;i<21;i++)
		naas[i]=(int *)ckalloc( (MAXLEN+1)*sizeof (int));

	dna_gap_open    = 10;	/* Default gap penalties for DNA */
	dna_gap_extend  = 10;

	prot_gap_open   = 10;	/* Default gap penalties for protein */
	prot_gap_extend = 10;

	is_weight = TRUE;
}



static void group_gap(int len,int sclass,char *seq)
{
	int i,j,k,xtra;
	
	for(i=1;i<=nseqs;++i)
		if(group[i] == sclass) {
			xtra = len - seqlen_array[i];
			if(xtra>0)
				for(j=1;j<=xtra;++j)
					seq_array[i][seqlen_array[i]+j] = -1;
			for(j=1;j<=len;++j)
				if(seq[j] == '-') {
					for(k=len;k>=j+1;--k)
					seq_array[i][k] = seq_array[i][k-1];
					seq_array[i][j] = -1;
				}
			seqlen_array[i] = len;
		}
}


static void add_ggaps()
{
	int i,j,k,pos,to_do,len;
	char str1[MAXLEN+1],str2[MAXLEN+1];
	
	pos=1;
	to_do=print_ptr-1;
	
	for(i=1;i<=to_do;++i) {
		if(displ[i]==0) {
			str1[pos]=str2[pos]='*';
			++pos;
		}
		else {
			if((k=displ[i])>0) {
				for(j=0;j<=k-1;++j) {
					str2[pos+j]='*';
					str1[pos+j]='-';
				}
				pos += k;
			}
			else {
				k = (displ[i]<0) ? displ[i] * -1 : displ[i];
				for(j=0;j<=k-1;++j) {
					str1[pos+j]='*';
					str2[pos+j]='-';
				}
			pos += k;
			}
		}
	}
	
	len = --pos;
	group_gap(len,1,str1);
	group_gap(len,2,str2);
}


static void add(int v)
{
	
	if(last_print<0) {
		displ[print_ptr-1] = v;
		displ[print_ptr++] = last_print;
	}
	else 
		last_print = displ[print_ptr++] = v;
}


static int calc_weight(int iat,int jat,int v1,int v2)
{
	int sum,i,j,lookn,ret;
	int ipos,jpos;
	
	sum=lookn=0;
	ipos = v1 + iat -1;
	jpos = v2 + jat -1;
	
	ret=0;
	if(pos1>=pos2) {
		for(i=1;i<=pos2;++i) {
			j=seq_array[alist[i]][jpos];
			if(j>0) {
				sum += naas[j][ipos];
				++lookn;
			}
		}	
	}
	else {
		for(i=1;i<=pos1;++i) {
			j=seq_array[alist[i]][ipos];
			if(j>0) {
				sum += naas[j][jpos];
				++lookn;
			}
		}
	}
	
	if(sum > 0 ) ret = sum / lookn;
	return ret;
}


static void fill_pam()
{
	register int i,j,pos;
	
	pos=0;
	
	for(i=0;i<20;++i)
		for(j=0;j<=i;++j)
			pam[i][j]=pamo[pos++];
	
	for(i=0;i<20;++i)
		for(j=0;j<=i;++j)
			pam[j][i]=pam[i][j];
	
	if(dnaflag) {
		xover=4;
		big_pam=8;
		for(i=0;i<5;++i)
			for(j=0;j<5;++j) {
				if(i==j)
					weights[i][j]=0;
				else
					weights[j][i]=10;
			}
		if(is_weight) {
			weights[1][3]=4;
			weights[3][1]=4;
			weights[2][4]=4;
			weights[4][2]=4;
		}
	}
	else {
/*
	fprintf(stdout,"\nxover = %d; big_pam = %d\n",xover,big_pam);
*/
		for(i=1;i<21;++i)
			for(j=1;j<21;++j) {
				weights[i][j] = big_pam - pam[i-1][j-1];
/*
				fprintf(stdout,"\n%2d vs %2d:  %5d",i,j,weights[i][j]);
*/
			}
		for(i=0;i<21;++i) {
			weights[0][i] = xover;
			weights[i][0] = xover;
		}
	}
}

static int diff(int v1,int v2,int v3,int v4,int st,int en)
{
	int ctrc,ctri,ctrj,i,j,k,l,m,n,p,q,flag;
    
	q  = gap_open + gap_extend;
    
	if(v4<=0)  {
		if(v3>0) {
			if(last_print<0)
				last_print = displ[print_ptr-1] -= v3;
			else
				last_print = displ[print_ptr++] = -(v3);
		}
	
                return gap(v3);
	}
    
	if(v3<=1) {
		if(v3<=0) {
			add(v4);
                        return gap(v4);
		}
		if(st>en)
			st=en;

/***************if(!v4)*********BUG********************************/

		ctrc = (st+gap_extend) + gap(v4);
		ctrj = 0;
		for(j=1;j<=v4;++j) {
			k = calc_weight(1,j,v1,v2) + gap(v4-j) + gap(j-1);
			if(k<ctrc) {
				ctrc = k;
				ctrj = j;
			}
		}

		if(!ctrj) {
			add(v4);
			if(last_print<0)
				last_print = displ[print_ptr-1] -= 1;
			else
				last_print = displ[print_ptr++] = -1;
		}
		else {
			if(ctrj>1)
				add(ctrj-1);
			displ[print_ptr++] = last_print = 0;
			if(ctrj<v4)
				add(v4-ctrj);
		}
		return ctrc;
	}
    
    
	ctri = v3 / 2;
	zza[0] = 0;
	p = gap_open;
	for(j=1;j<=v4;++j) {
		p += gap_extend;
		zza[j] = p;
		zzb[j] = p + gap_open;
	}
    
	p=st;
	for(i=1;i<=ctri;++i) {
		n=zza[0];
		p += gap_extend;
		k = p;
		zza[0]=k;
		l = p+gap_open;
		for(j=1;j<=v4;++j) {
			k += q;
			l += gap_extend;
			if(k<l)
				l=k;
			k = zza[j] + q;
			m = zzb[j] + gap_extend;
			if(k<m)
				m=k;
			k = n + calc_weight(i,j,v1,v2);
			if(l<k)
				k=l;
			if(m<k)
				k=m;
			n=zza[j];
			zza[j]=k;
			zzb[j]=m;
		}
	}
    
	zzb[0]=zza[0];
	zzc[v4]=0;
	p=gap_open;
	for(j=v4-1;j>-1;--j) {
		p += gap_extend;
		zzc[j]=p;
		zzd[j]=p+gap_open;
	}
	p=en;
	for(i=v3-1;i>=ctri;--i) {
		n=zzc[v4];
		p += gap_extend;
		k = p;
		zzc[v4] = k;
		l = p+gap_open;
		for(j=v4-1;j>=0;--j) {
			k += q;
			l += gap_extend;
			if(k<l)
				l=k;
			k = zzc[j] + q;
			m = zzd[j] + gap_extend;
			if(k<m)
				m=k;
			k = n + calc_weight(i+1,j+1,v1,v2);
			if(l<k)
				k=l;
			if(m<k)
				k=m;
			n=zzc[j];
			zzc[j]=k;
			zzd[j]=m;
		}
	}

	zzd[v4]=zzc[v4];
	ctrc=zza[0]+zzc[0];
	ctrj=0;
	flag=1;
	for(j=0;j<=v4;++j) {
		k = zza[j] + zzc[j];
		if(k<=ctrc)
			if(k<ctrc || ((zza[j]!=zzb[j]) && (zzc[j]==zzd[j]))) {
				ctrc=k;
				ctrj=j;
			}
	}

	for(j=v4;j>=0;--j) {
		k = zzb[j] + zzd[j] - gap_open;
		if(k<ctrc) {
			ctrc=k;
			ctrj=j;
			flag=2;
		}
	}

	/* Conquer recursively around midpoint  */

	if(flag==1) {             /* Type 1 gaps  */
		diff(v1,v2,ctri,ctrj,st,gap_open);
		diff(v1+ctri,v2+ctrj,v3-ctri,v4-ctrj,gap_open,en);
	}
	else {
		diff(v1,v2,ctri-1,ctrj,st,0);
		if(last_print<0)                         /* Delete 2 */
			last_print = displ[print_ptr-1] -= 2;
		else
			last_print = displ[print_ptr++] = -2;
		diff(v1+ctri+1,v2+ctrj,v3-ctri-1,v4-ctrj,0,en);
	}
	return ctrc;       /* Return the score of the best alignment */
}






static void do_align(int v1,int *score)
{
	int ctrc,i,j,k,l1,l2,n;
	int t_arr[21];

	l1=l2=pos1=pos2=0;

	for(i=1;i<=MAXLEN;++i) {
		for(j=0;j<21;++j)
			naa1[j][i]=naa2[j][i]=0;
		for(j=1;j<21;++j)
			naas[j][i]=0;
	}

	for(i=1;i<=nseqs;++i) {
		if(group[i]==1) {
			fst_list[++pos1]=i;
			for(j=1;j<=seqlen_array[i];++j)
				if(seq_array[i][j]>0) {
				 ++naa1[seq_array[i][j]][j];
				 ++naa1[0][j];
				}
			if(seqlen_array[i]>l1)
				l1=seqlen_array[i];
		}
		else if(group[i]==2) {
			snd_list[++pos2]=i;
			for(j=1;j<=seqlen_array[i];++j)
				if(seq_array[i][j]>0) {
					++naa2[seq_array[i][j]][j];
					++naa2[0][j];
				}
			if(seqlen_array[i]>l2) l2=seqlen_array[i];
		}
	}

	if(pos1>=pos2) {
		for(i=1;i<=pos2;++i)
			alist[i]=snd_list[i];
		for(n=1;n<=l1;++n) {
			for(i=1;i<21;++i)
				t_arr[i]=0;
			for(i=1;i<21;++i)
				if(naa1[i][n]>0)
					for(j=1;j<21;++j)
						t_arr[j] += (weights[i][j]*naa1[i][n]);
			k = naa1[0][n];
			if(k>0)
				for(i=1;i<21;++i)
					naas[i][n]=t_arr[i]/k;
		}
	}
	else {
		for(i=1;i<=pos1;++i)
			alist[i]=fst_list[i];
		for(n=1;n<=l2;++n) {
			for(i=1;i<21;++i)
				t_arr[i]=0;
			for(i=1;i<21;++i)
				if(naa2[i][n]>0)
					for(j=1;j<21;++j)
						t_arr[j] += (weights[i][j]*naa2[i][n]);
			k = naa2[0][n];
			if(k>0)
				for(i=1;i<21;++i)
					naas[i][n]=t_arr[i]/k;
		}
	}

	*score=diff(1,1,l1,l2,v1,v1);	/* Myers and Miller alignment now */
}


void myers(int align_type)   /* align_type = 0 for full progressive alignment*/
			     /* align_type = 1 for a profile alignment */
{
/*	static char *nbases = "XACGT";
	static char seq1[MAXLEN+1];     */
	char		temp[MAXLINE];
	int val,i,j,k,a,b,len,set;
	int sets,chunks,ident,lv1,pos,copt,flag,entries,idummy,score,ptr;
	double dummy;

	nblocks=0;

	fprintf(stdout,"\nStart of Multiple Alignment\n");

	fill_pam();

	if(align_type == 0)  {		/* a full progressive alignment */
		sets=0;
		tree=fopen(treename,"r");
		while(fgets(temp,MAXLINE,tree)!=NULL) ++sets;
		fseek(tree,0,0);
		fprintf(stdout,"There are %d sets\n",sets);
	}
	else 			   /* just one set (a profile alignment) */
		sets = 1;

	fprintf(stdout,"Aligning...\n");

	for(set=1;set<=sets;++set) {
		if(align_type == 0)
			read_tree(&entries,&dummy,&idummy,&idummy,group);
		else  {
			for(i=1; i<=profile1_nseqs; ++i)
				group[i] = 1;
            for(i=profile1_nseqs+1; i<=nseqs; ++i)
 				group[i] = 2;
 			entries = nseqs;
		}
		last_print=0;
		print_ptr=1;
		do_align(gap_open,&score);
		fprintf(stdout,"Set %d: Entries:%d	Score:%d\n",set,entries,score);
		add_ggaps();
	}
	if(align_type == 0) fclose(tree);

/* make the rest (output stuff) into routine clustal_out in file amenu.c */

}



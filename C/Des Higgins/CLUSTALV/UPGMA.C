#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "clustalv.h"

/*
*	Prototypes
*/

extern void *ckalloc(size_t);
extern Boolean read_tree(int *,double *,int *,int *,int *);
extern void warning(char *,...);
void init_upgma(void);
void upgma(int);

/*
*	Global variables
*/

extern FILE *tree;
extern char treename[];
extern double **tmat;

static int *combine;
static int *otree_array,*tree_array;
double **smat;
static int *group1,*group2;


void init_upgma()
{
	register int i;
	
	combine = (int *)ckalloc( (MAXN+1) * sizeof (int) );
	otree_array = (int *)ckalloc( (MAXN+1) * sizeof (int) );
	
	smat = (double **) ckalloc( (MAXN+1) * sizeof (double *) );
	for(i=0;i<MAXN+1;i++)
		smat[i] = (double *)ckalloc( (MAXN+1) * sizeof (double) );
		
	tree_array = (int *)ckalloc( (MAXN+1) * sizeof (int) );
	group1 = (int *)ckalloc( (MAXN+1) * sizeof (int) );
	group2 = (int *)ckalloc( (MAXN+1) * sizeof (int) );
}

void upgma(int totseqs)
{
	int i,j,k,sub1,sub2,lowp,highp,ndone,chunks,comv,flag,gp2,iter,n,idummy;
	int m,m2;
	int bottom,top;
	double score,med,acc,dummy;
	
	iter=0;
	
	for(i=1;i<=totseqs;++i) {
		combine[i]=otree_array[i]=0;
		tmat[i][i]=0.0;
	}
	
	for(i=1;i<=totseqs;++i)
		for(j=1;j<=totseqs;++j)
			smat[i][j]=tmat[i][j];
	
	while(TRUE) {
		score = 0.0;
		sub1 = sub2 =0;
	
		for(i=1;i<=totseqs;++i)
			if(combine[i]==0 || combine[i]==i)
				for(j=1;j<=totseqs;++j) {
					if(combine[j]!=0 && combine[j]!=j) continue;
					if(smat[i][j]> score) {
						score = smat[i][j];
						sub1 = i;
						sub2 = j;
					}
				}
	
	
		bottom = (sub1<sub2) ? sub1 : sub2;
		top = (sub1>sub2) ? sub1 : sub2;
		for(i=1;i<=totseqs;++i)
			tree_array[i]=0;
	
		if(combine[bottom]==0 && combine[top]==0) {
			combine[bottom]=bottom;
			combine[top]=bottom;
			lowp=highp=0;
			tree_array[bottom]=1;
			tree_array[top]=2;
		}
		else if(combine[bottom]==0 && combine[top]>0) {
			combine[bottom]=bottom;
			lowp=0;
			tree_array[bottom]=1;
			for(i=top;i<=totseqs;++i)
				if(combine[i]==top) {
					combine[i]=bottom;
					tree_array[i]=2;
				}
		}
		else if(combine[bottom]>0 && combine[top]==0) {
			highp=0;
			for(i=bottom;i<=totseqs;++i)
				if(combine[i]==bottom)
					tree_array[i]=1;
			combine[top]=bottom;
			tree_array[top]=2;
		}
		else {
			for(i=1;i<=totseqs;++i) {
				if(combine[i]==bottom)
					tree_array[i]=1;
				if(combine[i]==top) {
					combine[i]=bottom;
					tree_array[i]=2;
				}
			}
		}
	
		m=m2=ndone=0;
		for(i=1;i<=totseqs;++i) {
			if(tree_array[i]==1)
				++m;
			if(tree_array[i]==2)
				++m2;
			if(combine[i]==bottom) {
				++ndone;
				group1[ndone]=i;
			}
		}
		
		chunks=0;
		
		if(ndone>2) {
			flag=FALSE;
			if(m>1) {
				tree=fopen(treename,"r");
				while(TRUE) {
					if(!read_tree(&n,&dummy,&idummy,&idummy,otree_array)) {
						flag=TRUE;
						break;
					}
					++chunks;
					if(n!=m)
						continue;
					else {
						comv=0;
						for(i=1;i<=totseqs;++i)
							if(otree_array[i]>0 && tree_array[i]==1)
								++comv;
						if(comv!=m)
							continue;
						lowp=chunks;
						break;
					}
					break;
				}
				fclose(tree);
			}
			if(flag)
				warning("Dutch Elm Disease. Bad tree");
			
			flag=FALSE;
			chunks=0;
			if(m2>1) {
				tree=fopen(treename,"r");
				while(TRUE) {
					if(!read_tree(&n,&dummy,&idummy,&idummy,otree_array)) {
						flag=TRUE;
						break;
					}
					++chunks;
					if(n!=m2)
						continue;
					else {
						comv=0;
						for(i=1;i<=totseqs;++i)
							if(otree_array[i]>0 && tree_array[i]==2)
								++comv;
						if(comv!=m2)
							continue;
						highp=chunks;
						break;
					}
					break;
				}
				fclose(tree);
			}
			if(flag)
				warning("Dutch Elm Disease. Bad tree");
		}
	
		tree=fopen(treename,"a");
		fprintf(tree," %7.1f %3d %3d %3d   ",score,lowp,highp,ndone);
		for(i=1;i<=totseqs;++i)
			fprintf(tree,"%1d",tree_array[i]);
		fprintf(tree,"\n");
		fclose(tree);
	
		for(i=1;i<=totseqs;++i) {
			gp2=0;
			if(combine[i]==bottom)
				continue;
			else if(combine[i]==0) {
				gp2=1;
				group2[1]=i;
			}
			else if(combine[i]==i) {
				for(j=1;j<=totseqs;++j)
					if(combine[j]==i) {
						++gp2;
						group2[gp2]=j;
					}
			}
			else continue;
		
			acc=0.0;
			comv=0;
			for(j=1;j<=gp2;++j)
				for(k=1;k<=ndone;++k) {
					acc += tmat[group2[j]][group1[k]];
					++comv;
				}
			med=acc/(double)comv;
			smat[i][bottom]=med;
			smat[bottom][i]=med;
		}
	
		++iter;
		if(iter>800)
			return;
		flag=FALSE;
		for(i=1;i<=totseqs;++i)
			if(combine[i]!=1)
				flag=TRUE;
		if(!flag)
			break;
	}
}

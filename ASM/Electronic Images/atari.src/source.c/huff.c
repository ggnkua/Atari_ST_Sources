#include <stdio.h>
#include <stdlib.h>

#define MC (4096)             /* maximum no. of characters */
#define MQ (2*MC-1)

typedef struct {
	unsigned long icod[MQ];
	unsigned long ncod[MQ];
	unsigned long left[MQ];
	unsigned long right[MQ];
	unsigned long nch;
	unsigned long nodemax;
} huffcode;

huffcode hcode;

/*
 *
 */
 
static void huffapp(unsigned long index[], unsigned long nprob[],unsigned long n,unsigned long i)
{	unsigned long j,k;
	k = index[i];
	while (i <= (n>>1))
	{	if ((j = i<<1) < n && nprob[index[j]] > nprob[index[j+1]])
	 		j++;
		if (nprob[k] <= nprob[index[j]]) 
			break;
		index[i]=index[j];
		i=j;
	}
	index[i]=k;
}

void huff_make(unsigned long nfreq[],unsigned long nchin, unsigned long *ilong,unsigned long *nlong,unsigned long i,huffcode *hcode)
{	int ibit;
	long node,*up;
	unsigned long j,k,*index,n,nused,*nprob;
	hcode->nch = nchin;
	index = (unsigned long *) malloc (2 * nchin * sizeof(long));
	up = (long *) malloc (2 * nchin * sizeof(long));
	nprob = (unsigned long *) malloc (2 * nchin * sizeof(long));
	for (nused=0,j=1;j<=2*nchin;j++)
	{	nprob[j] = nfreq[j];
		hcode->icod[j]=hcode->ncod[j]=0;
		if (nfreq[j]) index[++nused]=j;
	}
	for (j=nused;j>=1;j--) huffapp(index,nprob,nused,j);
	k=hcode->nch;
	while (nused > 1)
	{	node=index[1];
		index[1]=index[nused--];
		huffapp(index,nprob,nused,1);
		nprob[++k]=nprob[index[1]]+nprob[node];
		hcode->left[k]=node;
		hcode->right[k]=index[1];
		up[index[1]]=-k;
		up[node]=index[1]=k;
		huffapp(index,nprob,nused,1);
	}
	up[hcode->nodemax=k]=0;
	for (j=1;j<=hcode->nch;j++)
	{	if (nprob[j])
		{	for (n=0,ibit=0,node=up[j];node;node=up[node],ibit++)
			{	if (node < 0)
				{	n |= (1 << ibit);
					node = -node;
				}
			}
			hcode->icod[j]=n;
			hcode->ncod[j]=ibit;
		}
	}
	*nlong=0;
	for (j=1;j<hcode->nch;j++)
	{	if (hcode->ncod[j] > *nlong)
		{	*nlong=hcode->ncod[j];
			*ilong=j-1;
		}
	}
	free (nprob);
	free (up);
	free (index);
}

void init_huff(huffcode *hcode)
{	int j;
	for (j=1;j<=MQ;j++)
	{ 	hcode->icod[j]=0;
		hcode->ncod[j]=0;
	}
}

/*
' QUICKSORT sorts elements in the array A with indices between
' LO and HI (both inclusive). Note that the QUICKSORT proce-
' dure provides only an "interface" to the program. The actual
' processing takes place in the SORT procedure, which executes
' itself recursively.
'
' compose test: 
*/

long	*data;			/* base of array */

void sort(int l, int r)
{
	int		i,j;
	long	x,y;

	i=l; j=r; x=data[(l+r)>>1];
	do {
	    while (data[i]<x) i++;
	    while (x<data[j]) j--;
		if (i<=j) {
			y=data[i]; data[i]=data[j];	data[j]=y;
			i++; j--;
		};
	} while (i<=j);
	if (l<j) sort(l,j);
	if (i<r) sort(i,r);
};
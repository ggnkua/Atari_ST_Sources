/* The inevitable hello world program...
 *
 * I found this one while reading news and modified it slightly
 * in order to avoid the CR/LF problem.
 */


float o=0.075,h=1.5,T,r,O,l,I;
int x,L=80,s=3200;

void main()
{
	for( ;s%L||(h-=o,T= -2),s;4 -(r=O*O)<(l=I*I)|++x==L &&\
				printf("%.1s",(--s%L?(x<L ? --x%6:6):7)+"World! \n")&&\
				(O=I=l=x=r=0,T+=o/2) )
		O=I*2*O+h,I=l+T-r;
}

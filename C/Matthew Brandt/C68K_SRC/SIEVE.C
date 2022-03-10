
#define true 1
#define false 0
#define size 8190
#define sizepl 8191
#define display(c) printf(c)
char	flags[sizepl];

main() {
	int i,prime,k,count,iter;
	display("10 iterations\n");
	for(iter=1;iter<= 10;iter++){
		count=0;
		for(i = 0; i<=size;i++)
			flags[i]=true;
		for(i=0;i <= size; i++){
			if(flags[i]){
				prime = i+i+3;
				k=i+prime;
					while(k<=size){
						flags[k] = false;
						k += prime;
						}
					count = count+1;
				}
			}
		}
	printf("\n%d primes\n",count);
	}

.. Test the random number creator

function randomtest (n=5000)
## perform various test on the random number creator
	t=random(2,n)*0.999999999;
	color(1);
## distribution test
	c=count(t[1]*100,100);
	histogram(t[1]*100,100); title("distribution of random numbers");
	wait();
	histogram(c,integer=1); title("distribution of distribution");
	wait();
	chi2=sum((c-n/100)^2/(n/100));
	printf("chi^2 for distribution of numbers = %0.5f",chi2),
	printf("Probability for this: %0.2f%%",(1-chidis(chi2,99))*100),
## gap test
	f=nonzeros(t[1]<0.1); m=length(f);
	gaps=f[2:m]-f[1:m-1];
	histogram(gaps,integer=1); title("distribution of gaps");
	wait();
	color(2);
	x=1:max(gaps); hold on; plot(x,0.9^(x-1)*0.1*m); hold off;
	color(1);
	wait();
	c=count(gaps-1,20); p=0.9^(0:19)*0.1*m;
	chi2=sum((c-p)^2/p);
	printf("chi^2 for the gaps = %0.5f",chi2),
	printf("Probability for this: %0.2f%%",(1-chidis(chi2,20))*100),	
## distribution of pairs test
	markerstyle("m.");
	xmark(t[1],t[2],grid=0); title("pairs of random numbers");
	wait();
	l=floor(t[1]*10)*10+floor(t[2]*10);
	histogram(l,integer=1); title("distribution of pairs"); wait();
	c=count(l,100);
	histogram(c,integer=1);
	title("distribution of distribution of pairs"); wait();
	chi2=sum((c-n/100)^2/(n/100));
	printf("chi^2 for distribution of pairs = %0.5f",chi2),
	printf("Probability for this: %0.2f%%",(1-chidis(chi2,99))*100),
	return ""
endfunction

"randomtest",
"test of the builtin random number generator."
randomtest;

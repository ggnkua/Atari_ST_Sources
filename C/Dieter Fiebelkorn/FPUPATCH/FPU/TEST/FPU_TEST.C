#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <tos.h>

#define COUNT	10000L



long time(void)
{
	long	*_hz_200 = (long *) 0x4BA;
	
	return(*_hz_200);
}



double null(double dummy)
{
	return(dummy);
}



main(int argc, char *argv[])
{
	register long	f, i, count;
	register long	time1, time2, leer;
	long            firstTime, lastTime;
	int             mode, error, last, new;
	double          v1, v2, v3, v4, v5, points;
	double			res0, res1, a = M_1_SQRTPI;
	float			flt0, flt1, b = M_1_SQRTPI;
	double          (*fktpntr)(double);
	char           *fktname;
	struct _FKT
	{
		char	*name;
		double	(*pntr)(double);
	} fktarray[] =
	{
		" SQRT  (%6ld) : ", sqrt,
		" EXP   (%6ld) : ", exp,
		" LOG   (%6ld) : ", log,
		" TAN   (%6ld) : ", tan,
		" SIN   (%6ld) : ", sin,
		" COS   (%6ld) : ", cos,
		" ATAN  (%6ld) : ", atan,
		" ASIN  (%6ld) : ", asin,
		" ACOS  (%6ld) : ", acos,
		" TANH  (%6ld) : ", tanh,
		" SINH  (%6ld) : ", sinh,
		" COSH  (%6ld) : ", cosh,
		" ATANH (%6ld) : ", atanh,
		" ASINH (%6ld) : ", asinh,
		" ACOSH (%6ld) : ", acosh,
		NULL               , NULL
	};


	
	puts("\033E   \033p============================ COPROZESSOR TEST ============================\033q");
	
	if (argc == 1)
	{
		puts ("\n\n  Using: FPU_TEST <counts>");
		puts ("\n\n                                 \033pPress [RETURN]\033q");
		getchar();
		exit(1);
	}
	if (!fpumode(0))
	puts("   \033p============== NO COPROZESSOR OR  _FPU COCKIE NOT INSTALLED ==============\033q\n");
	else
	{
		extern short	_fpuco;
		short			co = _fpuco;
		
		switch (co)
		{
			case 1:
				puts("   \033p=========================== SFP004 COPROZESSOR ===========================\033q\n");
				break;
			case 2:
				puts("   \033p====================== REAL COPROZESSOR (MC68881/2) ======================\033q\n");
				break;
			case 4:
				puts("   \033p==================== REAL COPROZESSOR (MC68881)  sure ====================\033q\n");
				break;
			case 6:
				puts("   \033p==================== REAL COPROZESSOR (MC68882)  sure ====================\033q\n");
				break;
			case 8:
				puts("   \033p=================== MC68040  WITH INTERNAL COPROZESSOR ===================\033q\n");
				break;
			default:
				puts("   \033p===================== A COMBINATION  OF COPROZESSORS =====================\033q\n");
		}
	}
	puts(" FUNCTION(ITER) :  WITHOUT COPROZESSOR  |       WITH COPROZESSOR  | ?? |   %");
	puts(" ---------------:-----------------------+-------------------------+----+-------");
	


	count = COUNT;
	mode = 1;
	if (argc == 2 && (count = atol(argv[1])) == 0)
		count = COUNT;
	if (count < 100)
		count = 100;
	if (count > 999999L)
		count = 999999L;
	
	if (argc == 3)
	{
		if ((count = atol(argv[1])) == 0)
			count = COUNT;
		mode = atoi(argv[2]) & 0x01;
	}
	



	fpumode(1);
	error = 0;
	printf(" check (%6ld) :", count);
	points = (double) count / (double)strlen("-----------------------+-------------------------");
	last = 0;
    for (i = 1; i <= count; i++)
    {
    	new = (int)((double)i / points);
    	if (new != last)
    	{
    		for (f = 0; f < new - last; f++)
    			putchar('.');
    		last = new;
    	}
    	v1 = (double)rand() / (double)rand();
    	v2 = (double)rand() / (double)rand();
    	v3 = (double)rand() / (double)rand();
    	v4 = (double)rand() / (double)rand();
    	v5 = (double)rand() / (double)rand();
		fpumode(1);
		res0 = v1 * v2 + v3 / v4 + v5;
		fpumode(0);
		res1 = v1 * v2 + v3 / v4 + v5;
		fpumode(mode);
		if (fabs(res1 - res0) > 1E-11)
			error = 1;
    }
	if (!error)
		printf("|\033p OK \033q|\n");
	else
		printf("|\033pERR \033q|\n");
    
    
    
	time1 = Supexec(time);
	for(i = count; i; i--)
		res0 = a;
	time2 = Supexec(time);
	leer = time2 - time1;
	
	printf(" +-*/ X(%6ld) : ", count);
	fpumode(1);
	time1 = Supexec(time);
	for(i = count; i; i--)
		res0 = (a * a - a) / a + a;
	time2 = Supexec(time);
	firstTime = (time2-time1-leer)/4;
	printf("%10ld (%6.3fs)  |   ", firstTime, firstTime / 200.0);
	fpumode(0);
	time1 = Supexec(time);
	for(i = count; i; i--)
		res1 = (a * a - a) / a + a;
	time2 = Supexec(time);
	fpumode(mode);
	lastTime = (time2-time1-leer)/4;
	printf("%10ld (%6.3fs)", lastTime, lastTime / 200.0);
	if (fabs(res1 - res0) < 1E-11)
		printf("  |\033p OK \033q| %6.2f\n", 100.0 * lastTime / firstTime);
	else
		printf("  |\033pERR \033q| %6.2f\n", 100.0 * lastTime / firstTime);
	
	printf(" +-*/ S(%6ld) : ", count);
	fpumode(1);
	time1 = Supexec(time);
	for(i = count; i; i--)
		flt0 = (b * b - b) / b + b;
	time2 = Supexec(time);
	firstTime = (time2-time1-leer)/4;
	printf("%10ld (%6.3fs)  |   ", firstTime, firstTime / 200.0);
	fpumode(0);
	time1 = Supexec(time);
	for(i = count; i; i--)
		flt1 = (b * b - b) / b + b;
	time2 = Supexec(time);
	fpumode(mode);
	lastTime = (time2-time1-leer)/4;
	printf("%10ld (%6.3fs)", lastTime, lastTime / 200.0);
	if (fabs(flt1 - flt0) < 1E-6)
		printf("  |\033p OK \033q| %6.2f\n", 100.0 * lastTime / firstTime);
	else
		printf("  |\033pERR \033q| %6.2f\n", 100.0 * lastTime / firstTime);
	
	
	
	fktpntr = null;
	time1 = Supexec(time);
	for(i = count; i; i--)
		(*fktpntr)(M_1_SQRTPI);
	time2 = Supexec(time);
	leer = time2 - time1;

	
	for(f = 0, fktname = fktarray[f].name, fktpntr = fktarray[f].pntr;
	    fktname != NULL && fktpntr != NULL;
	    f++, fktname = fktarray[f].name, fktpntr = fktarray[f].pntr)
	{
		a = M_1_SQRTPI;
		if (fktpntr == sqrt)
			a = 1234.56789 * M_E;
		if (fktpntr == acosh)
			a = M_2_SQRTPI;
		printf(fktname, count);
		fpumode(1);
		time1 = Supexec(time);
		for(i = count; i; i--)
			(*fktpntr)(a);
		time2 = Supexec(time);
		res0 = (*fktpntr)(a);
		firstTime = (time2-time1-leer)/4;
		printf("%10ld (%6.3fs)  |   ", firstTime, firstTime / 200.0);
		fpumode(0);
		time1 = Supexec(time);
		for(i = count; i; i--)
			(*fktpntr)(a);
		time2 = Supexec(time);
		res1 = (*fktpntr)(a);
		fpumode(mode);
		lastTime = (time2-time1-leer)/4;
		printf("%10ld (%6.3fs)", lastTime, lastTime / 200.0);
		if (fabs(res1 - res0) < 1E-11)
			printf("  |\033p OK \033q| %6.2f\n", 100.0 * lastTime / firstTime);
		else
			printf("  |\033pERR \033q| %6.2f\n", 100.0 * lastTime / firstTime);
	}



	fprintf(stderr, "\n                                 \033pPress [RETURN]\033q");
	getchar();
	return(0);
}

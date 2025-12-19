#include <tos.h>
#include <stdio.h>


void extractinfo(char *fn, char *p, size_t length)
{char *type;
 long *lp;
 
 	lp = (long*)&p[0x438];
 	
	type = (*lp == 'M.K.') ? "31": "15";
	
	printf("%20s%32s%10ld%5s instr.\n",fn, p, length, type);
}

char *get_path(void)
{static char path[128];
	
	path[0] = 'A'+ Dgetdrv();
	path[1] = ':';
	Dgetpath(path+2, 0);
	
	return path;
}


int main()
{int  end,f;
 char *p;
 DTA  mydta, *olddta;
 
 	olddta = Fgetdta();
	Fsetdta(&mydta);
	
	if (Fsfirst("\\*.*",FA_VOLUME) == 0)
		printf("Disc: %s\n",mydta.d_fname);
	printf("Path: %s\n",get_path());
	
	printf("%20s%32s%10s%15s\n","FILE NAME","MODULE NAME","SIZE","INSTRUMENTS");

	end = Fsfirst("*.MOD", 0);
	
	while(!end)
	{
		f = Fopen(mydta.d_fname, 0);
		p = Malloc(2048 /*mydta.d_length*/);
		Fread(f, 2048 /*mydta.d_length*/, p);
		Fclose(f);
		extractinfo(mydta.d_fname, p, mydta.d_length);
		Mfree(p);
		end = Fsnext();
	}
	
	Fsetdta(olddta);
	
	return 0;	
}
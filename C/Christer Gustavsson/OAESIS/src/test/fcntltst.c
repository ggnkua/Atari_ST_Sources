#include <ioctl.h>
#include <mintbind.h>
#include <stdio.h>

#define WORD short
#define LONG long

void	main(void) {
		char pname[30];
	_DTA *olddta,newdta;
	WORD retval;
	char tail[128],name[128];
	
	olddta = Fgetdta();
	Fsetdta(&newdta);
	
	sprintf(pname,"u:\\proc\\*.%03d",Pgetppid());
	if(Fsfirst(pname,0) == 0) {
		LONG fd;
		
		sprintf(pname,"u:\\proc\\%s",newdta.dta_name);
		
		if((fd = Fopen(pname,0)) >= 0) {
			struct __ploadinfo li;
			
			li.fnamelen = 128;
			li.cmdlin = tail;
			li.fname = name;
			
			Fcntl((WORD)fd,&li,PLOADINFO);
			Fclose((WORD)fd);
		};
		
		fprintf(stderr,"name=%s\r\n",name);
		fprintf(stderr,"cmd=%s\r\n",&tail[1]);
	};
}

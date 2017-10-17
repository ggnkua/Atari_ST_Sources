# include "../../include/excep.h"
# include "acia.h"
# include <sgtty.h>
# include "tty.h"

extern struct ttystruct ttys[];

char txchar, rxchar;
char buf[] = "Hello there";

main(){
	int c;
	char ch;
	char buff[100];

	excep_init();
	c = txchar = rxchar = 0;

	o_tty(0);
	spl0();

	w_tty(0,buf,11);
	w_tty(0,buf,11);
	w_tty(0,buf,11);
	for(c=0; c<50; c++){
		w_tty(0,"Hello 123456789 \n\r",17);
	}
	printf("Wait\n");
	for(c=0; c<50000; c++);
	for(c=0; c<50; c++){
		w_tty(0,"Hello 123456789 \n\r",17);
	}

	c=r_tty(0,buff,20);
	for(c=0; c<1000; c++) w_tty(0,"HI ",3);
	printf("Interupts enabled\n");
	while(1){
		c=r_tty(0,buff,20);
		buff[c] = 0;
		printf("char ! %s\n",buff);
		if(buff[0] == 0x01) break;
	}
	ttys[0].sgtty.sg_flags |= TANDEM;
	printf("Waiting\n");
	for (c= 0; c<5000000; c++){
		c=c;
	}
	printf("Finished\n");
	while(1){
		c=r_tty(0,buff,20);
		buff[c] = 0;
		printf("char ! %s\n",buff);
		if(buff[0] == 0x01) break;
	}
}

/* testbios.c  tests working of bioscall.asm functions for screen output */

main()
{
    int i;
    
    clearsc();
    
    for (i=0; i < 24; i++){
	csrplot(i,i);
	writtty('A'+i);
	writchr('B'+i,1);
	writbw('C'+i,1);
	writul('D'+i,1);
	writrv('E'+i,1);
	writblr('F'+i,1);
    }
    home();
    exit();
}



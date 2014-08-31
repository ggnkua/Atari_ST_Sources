/* Anv„nder GEMDOS-anrop ist„llet f”r standard C */

#include<stdio.h>
#include<fcntl.h>
#include<osbind.h>

main()
{
	char buf[80];
	const char *str = "AAAAAAAAAAAAAAAAAAAA";
	long fh;
	
	printf("\nVilken fil:");
	gets(buf);
	
	if((fh = Fopen(buf,O_RDWR)) < 0){
		printf("\nKan ej ”ppna filen !");
		exit(1);
	}
	
	Fseek(10L,fh,SEEK_SET);
	
	Fwrite(fh,20,str);
	
	Fclose(fh);
}

#include	<dirent.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<time.h>


void	doupdate(char *fname,char *radslut)
{
	FILE	*fp1;
	FILE	*fp2 = NULL;
	
	char	tempfil[200];
		
	long	writepos = 0L;
	
	fp1 = fopen(fname,"rb");
	
	if(fp1 != NULL)
	{
		char *buffer;
		
		long	length;
		
		long	pos;
		
		fseek(fp1,0L,2);
		
		length = ftell(fp1);
		
		fseek(fp1,0L,0);
		
		buffer = malloc(length + 1);
		
		fread(buffer,1,length,fp1);
		
		buffer[length] = 0;
		
		pos = 0;
		
		do
		{
			pos += strcspn(&buffer[pos],"\r\n");

			switch(buffer[pos])
			{
				case	'\r'	:						
 					if(writepos == 0L)
  					{
  						tmpnam(tempfil);
 
 						printf("Skapar tempor„rfil %s\n",tempfil);
 						 								
  						fp2 = fopen(tempfil,"wb");
 					}
  							
  					fwrite(&buffer[writepos],1,pos - writepos,fp2);
  					
  					fwrite(radslut,1,strlen(radslut),fp2);
  							
  					if(buffer[pos + 1] == '\n')
  					{
  						pos = pos + 2;
  					}
  					else
  					{
  						pos++;
  					}	
					writepos = pos;
					break;

				case	'\n'	:						
 					if(writepos == 0L)
  					{
  						tmpnam(tempfil);

 						printf("Skapar tempor„rfil %s\n",tempfil);
 						 								
  						fp2 = fopen(tempfil,"wb");
  					}
  							
  					fwrite(&buffer[writepos],1,pos - writepos,fp2);
  					
  					fwrite(radslut,1,strlen(radslut),fp2);
  							
					pos++;
					writepos = pos;

					break;

				default	:
					pos++;
			}
			
		}while(pos < length);
		
		fclose(fp1);

		if(writepos > 0)
		{
			char	s[200];
			
 			fwrite(&buffer[writepos],1,length - writepos,fp2);
 			
 			fclose(fp2);
 			
 			strcpy(s,fname);
 			strcat(s,"~");
 			rename(fname,s);
 			
 			if(rename(tempfil,fname))
 			{
 				FILE	*fp = fopen(fname,"wb");
 				
				char *buffer;
				
				long	length;
				
				
 				fp2 = fopen(tempfil,"rb");
				
				fseek(fp2,0L,2);
				
				length = ftell(fp2);
				
				fseek(fp2,0L,0);
				
				buffer = malloc(length + 1);
				
				fread(buffer,1,length,fp2);
				fwrite(buffer,1,length,fp);
				
				free(buffer);
				
				fclose(fp);
				fclose(fp2);
				
				remove(tempfil);
 			};
 			
 			printf("%s uppdaterad\n",fname);
 		}
		
		free(buffer);
	}
	else
	{
		DIR	*dp1 = opendir(fname);
		
		if(dp1 != NULL)
		{
			struct dirent	*de;
			
			for(de = readdir(dp1); de != NULL; de = readdir(dp1))
			{
				if(strcmp(de->d_name,".") && strcmp(de->d_name,".."))
				{
					char	s[300];
					
					strcpy(s,fname);
					strcat(s,"\\");
					strcat(s,de->d_name);
					doupdate(s,radslut);
				}
			}
			
			closedir(dp1);
		}
	}
}


int	main(int argc,char *argv[])
{
	int	i;
	char	radslut[5];
	
	if(argc > 2)
	{
		if(!stricmp("-u",argv[1]))
		{
			strcpy(radslut,"\n");
		}
		else if(!stricmp("-a",argv[1]))
		{
			strcpy(radslut,"\r\n");
		}
		else
		{
			printf("-u\tUnix-radslut\n-a\tAtari-radslut\n");
			return	1;
		}
	
		for(i = 2; i < argc; i++)
		{
			doupdate(argv[i],radslut);
		}
	}
	else
	{
		printf("Jag vill ha †tminstone tv† argument!\n");
		return	1;
	}
	
	return	0;
}
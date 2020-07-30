/* entfernt Symboltabelle (wenn das Pure-C Format passen t„te) */
#include <stdio.h>
#include <stdlib.h>
#include <ext.h>

typedef struct
{
	int  ph_branch; /*0x601A*/
	long ph_tlen;
	long ph_dlen;
	long ph_blen;
	long ph_slen;
	long ph_res1;
	long ph_prgflags;
	int  ph_absflag;
}PH;

int main(int argc, char *argv[])
{
   int fh;
   char *cp;
   PH *ph;
	long slen, flen;
	
	if(argc == 2)
	{   
	   if((fh=open(argv[1], O_RDONLY)) >= 0)
	   {
         flen = filelength(fh);
	      if((cp=malloc(flen))!=NULL)
	      {
		      read(fh, cp, flen);
		      close(fh);
			   if((fh=open(argv[1], O_CREAT|O_TRUNC|O_WRONLY)) >= 0)
		      {
		      	ph = cp;
					printf("\nStripping %s\n",argv[1]);
					printf("\nT:%ld D:%ld B:%ld S:%ld ", 
												 ph->ph_tlen, 
                                     ph->ph_dlen, 
                                     ph->ph_blen, 
                                     ph->ph_slen);

		      	slen = ph->ph_slen;
		      	ph->ph_slen = 0;
		         
		         write(fh, cp, sizeof(PH));
		         cp += sizeof(PH);

			      write(fh, cp, ph->ph_tlen + ph->ph_dlen);
		         cp += (ph->ph_tlen + ph->ph_dlen + slen);

			      write(fh, cp, (long)ph + flen - (long)cp);

					printf("R:%ld\n", (long)ph + flen - (long)cp);

			      close(fh);
			      free(ph); /* !!!! nicht cp */
				   return(0);
		      }
			   else
					printf("\nCouldn't write %s\n", argv[1]);
	      }
		   else
				printf("\nNot enough memory to read %s\n", argv[1]);
	   }
	   else
			printf("\nCouldn't open %s\n", argv[1]);
   }
   else
		printf("\nUSAGE: pcstrip filename\n");
   
   return(-1);
}

#include <stdio.h>

/*THIS IS A C PROGRAM WHICH USES THE RANDOM GENERATOR*/
/* TO GENERATE NUMBERS AND THE ENCODE THEM USING     */
/* REED SOLOMON TECHNIQUES                           */


main()
{
     FILE  *efopen(),*fin,*fout;
     long int INPUT,I,J; 
     long int NINPUT, CINPUT,USE1,USE2,G1;
     long int G2,P1S,P2S,P3S,P4S;
     long int ALPHA[512],BITS[256];
     long int ilp1,ilp3,ilp4,ilp5,ilp6; 
     long int ilp2,ilp7;
     long int buffer[3000],output[896]; 
     long int input[1540];
     int p1=1,p2=0,p3=0,p4=0;
     int p5=0,p6=0,p7=0,p8=0;
     int pinit=0;
     int cnt1  = 1;
     int cnt2 = 1;

     /* open files for I/O */
     fin = efopen("in","w");
     fout = efopen("out","w");


     ALPHA[0]=1;
     ALPHA[255]=ALPHA[0];

     for (I=1; I < 256; I++){
        pinit = p8;
        p8 = p7;
        p7 = p6;
        p6 = p5;
        p5 = p4 ^ pinit;
        p4 = p3 ^ pinit;
        p3 = p2 ^ pinit;
        p2 = p1;
        p1 = pinit;
        ALPHA[I] = p1 + p2*2 + p3*4 + p4*8 + p5*16 + p6*32 + p7*64 + p8*128;
        ALPHA[I+255] = ALPHA[I];
        }


     for (I=1; I < 256; I++){
        for (J=0; J < 256; J++){
           if (ALPHA[J] == I){
              BITS[I] = J;
              J = 256;
              }
           }
        }

     /* set up random number generator */
     srandom(getpid());

     G1 = 1;
     G2 = 2;
     G1 = ALPHA[128] ^ ALPHA[128] ^ ALPHA[127] ^ ALPHA[126];
     G1 = BITS[G1];
     G2 = ALPHA[254] ^ ALPHA[253] ^ ALPHA[2] ^ ALPHA[1];
     G2 = BITS[G2];
 
     P1S = P2S = P3S = P4S = 0;
	 
     for(ilp1=1; ilp1 < 56 ;ilp1++){
        P1S = P2S = P3S = P4S = 0;
	cnt1 = (ilp1 - 1)*28 ;


        for(ilp3=1; ilp3 < 13 ;ilp3++){
           INPUT = (((float) (random() & 0x7FFFFFFF)) / 0x7FFFFFFF) * 255;
           fprintf(fin,"%d\n",INPUT);
           ilp7 = ilp1 + ilp3; 
	   buffer[cnt2] = INPUT;
           input[cnt1 + ilp3 ] = INPUT;
           NINPUT = INPUT ^ P4S;
           CINPUT = BITS[NINPUT];
           USE1 = CINPUT + G1;
           USE2 = CINPUT + G2;
           USE1 = ALPHA[USE1];
           USE2 = ALPHA[USE2];
           P4S = P3S ^ USE1;
           P3S = P2S ^ USE2;
           P2S = P1S ^ USE1;
           P1S = NINPUT;
	   cnt2 = cnt2 + 29; 
           }

		
	cnt2 = cnt2 + 4*29;
        for(ilp3=13; ilp3 < 25 ;ilp3++){
           INPUT = (((float) (random() & 0x7FFFFFFF)) / 0x7FFFFFFF) * 255;
           fprintf(fin,"%d\n",INPUT);
	   buffer[cnt2] = INPUT;
           input[cnt1 + ilp3 ] = INPUT;
           NINPUT = INPUT ^ P4S;
           CINPUT = BITS[NINPUT];
           USE1 = CINPUT + G1;
           USE2 = CINPUT + G2;
           USE1 = ALPHA[USE1];
           USE2 = ALPHA[USE2];
           P4S = P3S ^ USE1;
           P3S = P2S ^ USE2;
           P2S = P1S ^ USE1;
           P1S = NINPUT;
	   cnt2 = cnt2 + 29; 
           }

	cnt2 = cnt2- 16*29;

	buffer[cnt2] = P4S;
	cnt2 = cnt2 + 29;

	buffer[cnt2] = P3S;
	cnt2 = cnt2 + 29;

	buffer[cnt2] = P2S;
	cnt2 = cnt2 + 29;

	buffer[cnt2] = P1S;
	cnt2 = cnt2 + 29;

	cnt2 = cnt2 - 16*29;
        P1S = P2S = P3S = P4S = 0;

        for(ilp5=1; ilp5 < 29 ;ilp5++){
	   INPUT = buffer[cnt2];
	   cnt2=cnt2+1;
	   output[cnt1 + ilp5] = INPUT;
           fprintf(fout,"%d\n",INPUT);
           NINPUT = INPUT ^ P4S;
           CINPUT = BITS[NINPUT];
           USE1 = CINPUT + G1;
           USE2 = CINPUT + G2;
           USE1 = ALPHA[USE1];
           USE2 = ALPHA[USE2];
           P4S = P3S ^ USE1;
           P3S = P2S ^ USE2;
           P2S = P1S ^ USE1;
           P1S = NINPUT;
           }


	output[cnt1 + 29] = P4S;
	output[cnt1 + 30] = P3S;
	output[cnt1 + 31] = P2S;
	output[cnt1 + 32] = P1S;

        fprintf(fout,"%d\n",P4S);
        fprintf(fout,"%d\n",P3S);
        fprintf(fout,"%d\n",P2S);
        fprintf(fout,"%d\n",P1S);


     }

     fclose(fin);
     fclose(fout);
}


FILE *
efopen(fname, mode)
char *fname, *mode;
{
   FILE *fid, *fopen();

   if ((fid = fopen(fname, mode)) == 0){
      (void) fprintf(stderr,"error opening file -- %s\n",fname);
      exit(-1);
      }
   
   return(fid);
}


#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <image.h>

IMG_HEADER head;
MFDB picture;

void do_output_data(FILE *file)
{
int i,j;
char *l;
char str[258];

	for ( i=0; i<picture.fd_h; i++ ) {
		l=(char*)picture.fd_addr+picture.fd_wdwidth*2l*i;
		for ( j=0; j<picture.fd_w; j+=8,l++ ) {
			sprintf(str+j/4,"%02x",~*l);
		}
		fprintf(file,str);
		fprintf(file,"\n");
	}
}

int main(int argc,char *argv[])
{
char out[256],*c;
FILE *file;
double x,y,w,h;

	printf("img2ps V0.1 (%s) by Th. Morus Walter\n",__DATE__);
	if ( argc!=3 ) {
		printf(" usage: img2ps infile outfile\n");
		printf(" thanx to John Bradley for XV\n\n");
		return 1;
	}

	printf("reading %s ...\n",argv[1]);
	if ( xload_img(&head,argv[1],&picture)!=IMG_OK ) {
		printf("load-error: img2ps aborts\n");
		return 1;
	}
	if ( picture.fd_nplanes!=1 ) {
		printf("error: can't handle color images\n");
		return 1;
	}
	if ( picture.fd_w>1024 ) {
		printf("error: picture width too large\n");
		return 1;
	}

	strcpy(out,argv[2]);
	c=strrchr(out,'.');
	if ( c!=0 )
		strcpy(c+1,"ps");

	printf("writing %s ...\n",out);

	w=picture.fd_w;
	w*=head.pix_wid;
	h=picture.fd_h;
	h*=head.pix_hght;
	w/=25400.0/72.0;
	h/=25400.0/72.0;
	x=(612.0-w)/2;		/* 612/72" papierbreite */
	y=(792.0-h)/2;		/* 792/72" papierh”he */

	file=fopen(out,"w");
	if ( file ) {
		fprintf(file,"%%!PS-Adobe-2.0 EPSF-2.0\n");
		fprintf(file,"%%%%Title: %s\n",out);
		fprintf(file,"%%%%Creator: img2ps V0.1 %s by Th. Morus Walter\n",__DATE__);
		fprintf(file,"%%%%BoundingBox: %d %d %d %d\n",(int)(x+.5),(int)(y+.5),(int)(x+w+.5),(int)(y+h+.5));
		fprintf(file,"%%%%Pages: 1\n");
		fprintf(file,"%%%%DocumentFonts:\n");
		fprintf(file,"%%%%EndComments\n");
		fprintf(file,"%%%%EndProlog\n");
		fprintf(file,"\n");
		fprintf(file,"%%%%Page: 1 1\n");
		fprintf(file,"\n");
		fprintf(file,"%% remember original state\n");
		fprintf(file,"/origstate save def\n");
		fprintf(file,"\n");
		fprintf(file,"%% build a temporary dictionary\n");
		fprintf(file,"20 dict begin\n");
		fprintf(file,"\n");
		fprintf(file,"%% define string to hold a scanline's worth of data\n");
		fprintf(file,"/pix %d string def\n",(picture.fd_w+7)/8);
		fprintf(file,"\n");
		fprintf(file,"%% lower left corner\n");
		fprintf(file,"%d %d translate\n",(int)(x+.5),(int)(y+.5));
		fprintf(file,"\n");
		fprintf(file,"%% size of image (on paper, in 1/72inch coords)\n");
		fprintf(file,"%lf %lf scale\n",w,h);

		fprintf(file,"\n");
		fprintf(file,"%% dimensions of data\n");
		fprintf(file,"%d %d %d\n",picture.fd_w,picture.fd_h,picture.fd_nplanes);
		fprintf(file,"\n");
		fprintf(file,"%% mapping matrix\n");
		fprintf(file,"[%d %d %d %d %d %d]\n",picture.fd_w,0,0,-picture.fd_h,0,picture.fd_h);
		fprintf(file,"\n");

		fprintf(file,"{currentfile pix readhexstring pop}\n");
		fprintf(file,"image\n");

		do_output_data(file);

		fprintf(file,"\n");
		fprintf(file,"showpage\n");

		fprintf(file,"\n");
		fprintf(file,"%% stop using temporary dictionary\n");
		fprintf(file,"end\n");

		fprintf(file,"\n");
		fprintf(file,"%% restore original state\n");
		fprintf(file,"origstate restore\n");

		fprintf(file,"\n");
		fprintf(file,"%%%% Trailer\n");
		fclose(file);
	}

	free(picture.fd_addr);
	return 0;
}


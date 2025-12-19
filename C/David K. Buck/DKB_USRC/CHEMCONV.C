#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void write_header(void);
void write_atom(void);
void write_footer(void);

char colors[][128]={
"COLOUR RED 0.0 GREEN 0.0 BLUE 0.0",
"COLOUR BLUE 1.0",
"COLOUR GREEN 1.0",
"COLOUR BLUE 1.0 GREEN 1.0",
"COLOUR RED 1.0",
"COLOUR RED 1.0 BLUE 1.0",
"COLOUR RED 0.647059 GREEN 0.164706 BLUE 0.164706",
"COLOUR RED 0.658824 GREEN 0.658824 BLUE 0.658824",
"COLOUR RED 0.752941 GREEN 0.752941 BLUE 0.752941",
"COLOUR RED 0.74902 GREEN 0.847059 BLUE 0.847059",
"COLOUR RED 0.196078 GREEN 0.8 BLUE 0.196078",
"COLOUR RED 0.678431 GREEN 0.917647 BLUE 0.917647",
"COLOUR RED 0.737255 GREEN 0.560784 BLUE 0.560784",
"COLOUR RED 0.917647 GREEN 0.678431 BLUE 0.917647",
"COLOUR RED 1.0 GREEN 1.0",
"COLOUR RED 1.0 GREEN 1.0 BLUE 1.0"};

FILE *in, *out;
char buff[256];

int main(int argc, char *argv[])
{
 char infile[256], outfile[256];
 int frames=1;
 float xr, yr, zr;

 if(argc<2)
  {
   printf("CHEM2DKB v1.1s infile [outfile]\n");
   printf("Converts CHEMVIEW data file to DKB datafile.\n");
   exit(1);
  }
 strcpy(infile,strupr(argv[1]));
 if(argc>2)
  strcpy(outfile,strupr(argv[2]));
 else
  strcpy(outfile,argv[1]);
 if(argc>2&&strstr(argv[2],"/S"))
  {
   strcpy(outfile,argv[1]);
   printf("\n# of frames:");
   scanf("%d", &frames);
   printf("\nInitial X,Y,Z rot:");
   scanf("%f,%f,%f",&xr,&yr,&zr);
  }
 strcat(infile,".DAT");
 strcat(outfile,".DKB");
 in=fopen(infile, "r");
 if(!in)
  exit(1);
 out=fopen(outfile, "w");
 write_header();
 while(!feof(in))
  {
   fgets(buff, 255, in);
   if(strstr(strupr(buff),"ATOMLOCATION"))
    write_atom();
  }
 write_footer();
 exit(0);
 return(1);
}

void write_header(void)
{
  fprintf(out,"VIEW_POINT\n");
  fprintf(out,"    LOCATION <0.0  0.0  -10.0>     {Z may need modification}\n");
  fprintf(out,"    DIRECTION <0.0 0.0  2.0>\n");
  fprintf(out,"    UP  <0.0  1.0  0.0>\n");
  fprintf(out,"    RIGHT <1.33333 0.0 0.0>\n");
  fprintf(out,"    LOOK_AT <0.0  0.0  0.0>\n");
  fprintf(out,"END_VIEW_POINT\n\n");
  fprintf(out,"OBJECT\n");
  fprintf(out,"    SPHERE <0.0  0.0  0.0>  2.0 END_SPHERE\n");
  fprintf(out,"    TRANSLATE <500.0  500.0  -100.0> {Z may need modification}\n");
  fprintf(out,"    COLOUR RED 1.0 GREEN 1.0 BLUE 1.0\n");
  fprintf(out,"    AMBIENT 1.0\n");
  fprintf(out,"    DIFFUSE 0.0\n");
  fprintf(out,"    LIGHT_SOURCE\n");
  fprintf(out,"END_OBJECT\n\n");
  fprintf(out,"OBJECT\n");
  fprintf(out,"    SPHERE <0.0  0.0  0.0>  2.0 END_SPHERE\n");
  fprintf(out,"    TRANSLATE <-500.0  50.0  -1000.0> {Z may need modification}\n");
  fprintf(out,"    COLOUR RED 0.2 GREEN 0.2 BLUE 0.2\n");
  fprintf(out,"    AMBIENT 1.0\n");
  fprintf(out,"    DIFFUSE 0.0\n");
  fprintf(out,"    LIGHT_SOURCE\n");
  fprintf(out,"END_OBJECT\n\n");
  fprintf(out,"COMPOSITE\n");
}

void write_atom(void)
{
  int color;
  float x, y, z, r, j;
  sscanf(buff,"ATOMLOCATION(%d,L(%f,%f,%f,%f,%f,%f,%f,%d",&j,&x,&y,&z,&r,&j,&j,&j,&color);
  fprintf(out,"    OBJECT\n");
	fprintf(out,"        SPHERE <%6.4f %6.4f %6.4f> %f END_SPHERE\n",x/1300.0,y/1300.0,z/1300.0,r);
	fprintf(out,"        COLOUR %s\n",colors[color]);
  fprintf(out,"        TEXTURE\n");
  fprintf(out,"            AMBIENT 0.3\n");
  fprintf(out,"            DIFFUSE 0.7\n");
  fprintf(out,"            PHONG 1.0\n");
  fprintf(out,"            PHONGSIZE 40.0\n");
  fprintf(out,"        END_TEXTURE\n");
  fprintf(out,"    END_OBJECT\n");
}

void write_footer(void)
{
  fprintf(out,"TRANSLATE <0.0  0.0  0.0>\n");
  fprintf(out,"ROTATE    <0.0  0.0  0.0>\n");
  fprintf(out,"END_COMPOSITE\n");
}

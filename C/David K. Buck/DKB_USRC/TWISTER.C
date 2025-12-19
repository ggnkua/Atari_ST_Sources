/******************************************************************
 * 
 * Program : Twister.c
 * Purpose : Create twisted objects for the DKB raytracer
 * Created : 12/05/90
 * By      : Drew Wells [CIS 73767,1244]
 * Files   : Twister.c
 * Compiler: Microsoft C 6.00a
 * Model   : Tiny
 * Comments: This simple program used to create the floating twisters in
 *          the image "Not a Trace of Reality" a.k.a. Ntreal.gif.
 *          It should be compatible with any ANSI C compiler, and is 
 *          easily modifiable to create more complex shapes by adding
 *          code to change the x and z axis rotation and step.
 *
 *
 * Copyright 1990 Drew Wells
 * This copyrighted code is released for non-commercial use only.
 * It may not be sold or used a part of a commercial package.
 * This code may be modified and distributed provided it is done at no
 * cost to the user.
 * Please comment and maintain version list if you modify this code.
 ******************************************************************/
/* Version
 *   0.01 12/05/90 DW Created program.   
 *   1.00 12/26/90 DW Added user input.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void show_title(void); 
void get_parameters(void);
void write_header(char *filename, char *union_name,  char *objname);
void write_quadric(char *objname);
void write_piece(char *objname,double xpos, double ypos, double zpos,
                               double xrot, double yrot, double zrot);
void write_end(char *filename, char *union_name);
void err_exit(char *message);

FILE *outfile;
char object[80],filename[80],union_name[80],workstr[256];
double length, numtwist, ystep, rstep,xrot,yrot,zrot,x,y,z,numdeg;
long numpieces;

    

main()
{  
   show_title();
   
/* Get twister values from user */
    get_parameters();

/* Open file for output  and write header */
    printf("\n\nCreating DKB data file %s...\n",filename);
    if ((outfile = fopen(filename,"w")) == NULL)
     err_exit("Opening file.");
    
    write_header(filename,union_name, object);
    
/* Create twister and write each piece to file */ 
    for(y=0.0;y<=length;y+=ystep){
      write_piece(object,x,y,z,xrot,yrot,zrot);
      yrot += rstep;
     if(yrot>=360.0)
         yrot = yrot - 360.0;
     }

/* Write object end and close file */
    write_end(filename,union_name);
    fclose(outfile);
    printf("\nDKB data file %s created.\n",filename);
    return(0);
}


void show_title(void)
{ 
   printf("\n\n\n\n");
   printf("___________________________________________________________________\n\n");
   printf("[ TWISTER V1.00 ]\n");
   printf("This program creates a DKB raytracer data file of a twisted object.\n"); 
   printf("See TWISTER.doc for more details.\n");
   printf("- DW 12/26/90\n");
   printf("___________________________________________________________________\n");
}
void get_parameters(void)
{ 
/* Get twister values from user */    
    
    printf("Twister filename? [twist.dat]: ");
    gets(workstr);
    strcpy(filename,workstr);
    
    printf("Union name? [Macaroni]: ");
    gets(workstr);
    strcpy(union_name,workstr);
    
    printf("Quadric name? [Part]: ");
    gets(workstr);
    strcpy(object,workstr);
    
    
    printf("Length of twister? [20.0]: ");
    gets(workstr);
    sscanf (workstr, "%lf", &length);
    
    printf("Number of pieces for twister? [50]: ");
    gets(workstr);
    numpieces = atoi(workstr);
    
    printf("Number of twists? [1.0]: ");
    gets(workstr);
    sscanf (workstr, "%lf", &numtwist);
 
 /* Set up default values */
    if(filename[0]=='\0') strcpy(filename,"twist.dat");
    if(union_name[0]=='\0') strcpy(union_name,"Macaroni");
    if(object[0]=='\0') strcpy(object,"Part");
    if(length==0.0) length = 20.0;
    if(numpieces==0) numpieces = 50;
    if(numtwist==0.0) numtwist = 1.0;
    
    xrot = yrot = zrot = x = y = z = 0.0;
    ystep = length/(double)(numpieces-1);
    rstep = (360.0 * numtwist)/(length/ystep); 
}

void write_header(char *filename,  char *union_name, char *objname)
{ 
  fprintf(outfile,"{ File : %s  Union Name : %s }\n",filename,union_name);
  fprintf(outfile,"{ This data file created by TWISTER for the DKB ray tracer. }\n");
  fprintf(outfile,"{ NOTE: Change quadric '%s' to change the look of '%s' }\n",objname,union_name); 
  fprintf(outfile,"{ See TWISTER docs for more details.}\n\n");
  write_quadric(objname);
  fprintf(outfile,"\n{ Twister %s Length=%.3lf Number pieces=%ld Number twists=%.3lf }\n",union_name,length,numpieces,numtwist);
  fprintf(outfile,"DECLARE %s = OBJECT \n UNION\n",union_name);
}

void write_quadric(char *objname)
{ 
  /* Write a sample quadric to file for ease of use */
  fprintf(outfile,"DECLARE %s = QUADRIC Sphere ",objname);
  fprintf(outfile,"SCALE < %.2lf 1.0 1.0 > END_QUADRIC\n",length/4.0);
}  
void write_piece(char *objname,double xpos, double ypos, double zpos,
                            double xrot, double yrot, double zrot)
{
    char tofile[256];
    
    sprintf(tofile,"   QUADRIC %s\n   ROTATE <%.3lf %.3lf %.3lf> TRANSLATE <%.3lf %.3lf %.3lf>\n   END_QUADRIC\n",
                objname,xrot,yrot,zrot,xpos,ypos,zpos);

    if( fputs(tofile,outfile) )
     err_exit("Writing string to file.");
    
}
  
void write_end(char *filename, char *union_name)
{
 fprintf(outfile," END_UNION\n TEXTURE COLOR RED 0.9 GREEN 0.1 BLUE 0.1 END_TEXTURE \nEND_OBJECT\n");
 fprintf(outfile,"{ End_File : %s  End_Union Name : %s }\n",filename,union_name);
}

void err_exit(char *message)
{
    puts("\n\nERROR! \a");
    puts(message);
    puts("- Exiting program\n[Press CR]");
    getchar();
    exit(1);
}

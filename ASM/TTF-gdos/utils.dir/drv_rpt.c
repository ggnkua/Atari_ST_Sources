/***************************************************
**
** investigate GDOS device drivers
**
** Listing 1, Programmers' Forum STA 21 (September 1992)
** modified
*/

#include <osbind.h>
#include <stdio.h>
#include <time.h>
#include <vdibind.h>


/*
**  Type declarations and prototypes.
**  Alter the definition of 'int16' to suit your compiler system.
*/

#define MIN_DEVICE      1
#define MAX_DEVICE      70

#define BITS_PER_BYTE   8

typedef int int16;                     /* Signed 16 bits */

void dump_workstation(FILE *,int,int16);
void dump_gdps(FILE *,int16 *);
void dump_fonts(FILE *,int16);

/*
** The program starts here...
*/

int main( int argc, char *argv[], char *envp[])
{
int16 work_in[11], work_out[57];
int16 handle;
char output_file[FILENAME_MAX];
int device, f;
time_t now;
struct tm *tptr;
FILE *fp;

    printf("\033E\nDevice driver interrogator\n\n");
    if( vq_gdos() == 0) {
        printf("Must have GDOS resident to run this !\n");
        getchar();
        return(0);
    } /* if */
    printf("Enter name for report file, or press <RETURN> for screen.\n");
    printf(" Output file: ");
    if( fgets(output_file,FILENAME_MAX-1,stdin) == NULL) {
        printf("\nError reading file name\n");
        getchar();
        return(0);
    } /* if */
    output_file[FILENAME_MAX-1] = '\0';
    if( output_file[0] != '\n') {
        fp = fopen(output_file,"wa");
        if( fp == NULL) {
            printf("Error opening output file\n");
            getchar();
            return(0);
        } /* if */
    }
    else {
        fp = stdout;
        printf("\033E");
    } /* if */

    fprintf(fp,"             Results of interrogation of GDOS device drivers\n");
    fprintf(fp,"             ===============================================\n\n");
    time(&now);
    tptr = localtime(&now);
    fprintf(fp,"Output produced on %02d/%02d/%02d\n\n",tptr->tm_mday,
                                            tptr->tm_mon+1,tptr->tm_year);

    for( device=MIN_DEVICE; device<=MAX_DEVICE; device++) {
        work_in[0] = device;
        for( f=1; f<10; f++)
            work_in[f] = 1;
        work_in[10] = 2;
        if( device <=10) {
            handle = 0; /* was handle = device !!! */
            v_opnvwk( work_in, &handle, work_out);
            if( handle != 0 ) {
                dump_workstation( fp, device, handle );
                v_clsvwk(handle);
            } /* if */
        }
        else {
            v_opnwk( work_in, &handle, work_out);
            if( handle != 0 ) {
                dump_workstation( fp, device, handle );
                v_clswk(handle);
            } /* if */
        } /* if */
    } /* for */
    remove("GEMFILE.GEM");
    putc('\n',fp);
    if( fp != stdout)
        fclose(fp);
    printf("Press <RETURN> to exit:");
    getchar();
    return(0);
}


/****************************************************************
** Function to dump a report on the specified
** GDOS device driver out to a file.  The arguments
** are a file specification, the device number
** and a handle of an open workstation associated
** with that device.  There are no return values.
**
** Usage:   dump_workstation(fp,num,handle);
**
**          void dump_workstation(FILE *,int,int16);
*/

void dump_workstation( FILE *fp, int dev, int16 handle )
{
char *s;
int16 info[57], extra[57];
unsigned long w, h;
int i;
char device_name[32];
char driver_name[14];
int dev_open;

    for( i=0; i<57; i++ ) {
      info[i] = extra[i] = 0;
    } /* for */
    fprintf(fp,"\nDetails for device %2d\n",dev);
    fprintf(fp,"=====================\n\n");
    if( dev < 11)
        s = "Screen";
    else if( dev < 21)
        s = "Plotter";
    else if( dev < 31)
        s = "Printer";
    else if( dev < 41)
        s = "Metafile";
    else if( dev < 51)
        s = "Camera";
    else if( dev < 61)
        s = "Graphics tablet";
    else s = "Unknown";
    vq_devinfo( handle, dev, &dev_open, driver_name, device_name );
    fprintf(fp,"%s device, %s, driver is %s\n\n", s, device_name, driver_name );

    vq_extnd( handle, 0, info );
    w = (unsigned long)(info[0]+1) * info[3];
    h = (unsigned long)(info[1]+1) * info[4];
    fprintf(fp,"\nStandard information\n--------------------\n");
    fprintf(fp,"Device width in pixels:\t\t\t%d\n",info[0]+1);
    fprintf(fp,"Device height in pixels:\t\t%d\n",info[1]+1);
    fprintf(fp,"Precise scaling available:\t\t%s\n",(info[2] ? "Yes" : "No"));
    fprintf(fp,"Width of pixel:\t\t\t\t%d \346m (%d dpi)\n",info[3], 25400/info[3]);
    fprintf(fp,"Height of pixel:\t\t\t%d \346m (%d dpi)\n",info[4], 25400/info[4]);
    if( info[5]) fprintf(fp,"Number of character heights:\t\t%d\n",info[5]);
    else fprintf(fp,"Continuous character scaling\n");
    fprintf(fp,"Number of line types:\t\t\t%d\n",info[6]);
    if( info[7]) fprintf(fp,"Number of line widths:\t\t\t%d\n",info[7]);
    else fprintf(fp,"Continuous range of line widths\n");
    fprintf(fp,"Number of line types:\t\t\t%d\n",info[8]);
    if( info[9]) fprintf(fp,"Number of marker sizes:\t\t\t%d\n",info[9]);
    else fprintf(fp,"Continuous range of marker sizes\n");
    fprintf(fp,"Number of built-in fonts:\t\t%d\n",info[10]);
    fprintf(fp,"Number of fill patterns:\t\t%d\n",info[11]);
    fprintf(fp,"Number of fill styles:\t\t\t%d\n",info[12]);
    fprintf(fp,"Number of predefined colours:\t\t%d\n",info[13]);
    fprintf(fp,"\nNumber of GDP functions supported:\t%d\n",info[14]);
    dump_gdps(fp,info+15);
    fprintf(fp,"Colour available:\t\t\t%s\n",(info[35] ? "Yes" : "No"));
    fprintf(fp,"Text rotation available:\t\t%s\n",(info[36] ? "Yes" : "No"));
    fprintf(fp,"Area fill available:\t\t\t%s\n",(info[37] ? "Yes" : "No"));
    fprintf(fp,"Cell array operations available:\t%s\n",(info[38] ? "Yes" : "No"));
    if( info[39] == 2)
     fprintf(fp,"Monochrome palette\n");
    else if( info[39] > 2)
        fprintf(fp,"Number of colours in palette:\t\t%d\n",info[39]);
    else if( info[39] == 0)
        fprintf(fp,"Continuous range of colours in palette\n");
    fprintf(fp,"Locator devices:\t\t\tKeyboard %s\n",(info[40]-1 ? "and others" : "only"));
    fprintf(fp,"Valuator devices:\t\t\tKeyboard %s\n",(info[41]-1 ? "and others" : "only"));    
    fprintf(fp,"Choice devices:\t\t\t\tFunction keys %s\n",(info[42]-1 ? "and others" : "only"));
    fprintf(fp,"String devices:\t\t\t\tKeyboard %s\n",(info[43]-1 ? "and others" : "only"));
    switch( info[44] )  {
        case 0:     s = "Output only";          break;
        case 1:     s = "Input only";           break;
        case 2:     s = "Input and output";     break;
        case 4:     s = "Metafile output only"; break;
        default:    s = "Unknown";              break;
    } /* switch */
    fprintf(fp,"Workstation mode:\t\t\t%s\n",s);
    fprintf(fp,"Minimum character size (w x h):\t\t%d x %d\n",info[45],info[46]);
    fprintf(fp,"Maximum character size (w x h):\t\t%d x %d\n",info[47],info[48]);
    fprintf(fp,"Minimum line width:\t\t\t%d\n",info[49]);
    fprintf(fp,"Maximum line width:\t\t\t%d\n",info[51]);
    fprintf(fp,"Minimum marker size (w x h):\t\t%d x %d\n",info[53],info[54]);
    fprintf(fp,"Maximum marker size (w x h):\t\t%d x %d\n",info[55],info[56]);

    vq_extnd(handle,1,extra);
    fprintf(fp,"\nExtra information\n-----------------\n");
    if( extra[0] == 0) s = "Not graphics";
    else if( extra[0] == 4) s = "Graphics";
    else s = "Unknown";
    fprintf(fp,"Screen type:\t\t\t\t%s screen\n",s);
    fprintf(fp,"Number of background colours:\t\t%d\n",extra[1]);
    fprintf(fp,"Bit map of text effects supported:\t$%02X\n",extra[2]);
    fprintf(fp,"Raster scaling available:\t\t%s\n",(extra[3] ? "Yes" : "No"));
    fprintf(fp,"Number of bit planes:\t\t\t%d\n",extra[4]);
    fprintf(fp,"Lookup table available:\t\t\t%s\n",(extra[5] ? "Yes" : "No"));
    fprintf(fp,"Raster operations per second:\t\t%d\n",extra[6]);
    fprintf(fp,"Contour fill available:\t\t\t%s\n",(extra[7] ? "Yes" : "No"));
    if( extra[8] == 0) s = "None";
    else if( extra[8] == 1) s = "90 degree increments";
    else if( extra[8] == 2) s = "Any angle";
    else s = "Unknown";
    fprintf(fp,"Character rotation:\t\t\t%s\n",s);
    fprintf(fp,"Number of writing modes:\t\t%d\n",extra[9]);
    if( extra[10] == 0) s = "None";
    else if( extra[10] == 1) s = "Request";
    else if( extra[10] == 2) s = "Sample";
    else s = "Unknown";
    fprintf(fp,"Highest input mode:\t\t\t%s\n",s);
    fprintf(fp,"Text alignment available:\t\t%s\n",(extra[11] ? "Yes" : "No"));
    fprintf(fp,"Inking available:\t\t\t%s\n",(extra[12] ? "Yes" : "No"));
    if( extra[13] == 0) s = "None";
    else if( extra[13] == 1) s = "lines only";
    else if( extra[13] == 2) s = "Lines and rectangles";
    else s = "Unknown";
    fprintf(fp,"Rubber-banding modes:\t\t\t%s\n",s);
    fprintf(fp,"Maximum number of vertices:\t\t");
    if( extra[14] == -1) fprintf(fp,"Unlimited\n");
    else fprintf(fp,"%d\n",extra[14]);
    fprintf(fp,"Maximum size of intin array:\t\t");
    if( extra[15] == -1) fprintf(fp,"Unlimited\n");
    else fprintf(fp,"%d words\n",extra[15]);
    fprintf(fp,"Number of mouse buttons:\t\t%d\n",extra[16]);
    fprintf(fp,"Wide line styles available:\t\t%s\n",(extra[17] ? "Yes" : "No"));
    fprintf(fp,"Wide line writing modes available:\t%s\n",(extra[18] ? "Yes" : "No"));
    fprintf(fp,"Clipping enabled:\t\t\t%s\n",(extra[19] ? "Yes" : "No"));
    if( extra[19])
        fprintf(fp,"\tClipping rectangle:\t(%d,%d) to (%d,%d)\n",
          extra[45],extra[46],extra[47],extra[48]);
          
    fprintf(fp,"\nDerived values\n-------------\n");
    for( i=20; i<=44; i++ ) {
       if( extra[i] != 0 ) fprintf( fp, "extra[%d] is %d, %x, %c\n", i, extra[i], extra[i], extra[i] );
    } /* for */
    fprintf(fp,"Size of output work area:\t\t%lu.%lu x %lu.%lu cm\n",
                                      w/10000,w%10000,h/10000,h%10000);
    fprintf(fp,"Size of bitmap of output area:\t\t%lu bytes\n",
        ((unsigned long)(info[0]+1) * (info[1]+1) * extra[4]) / BITS_PER_BYTE);
   if( (dev>=21) && (dev<=30) ) {
      int16 g_slice, g_page, a_slice, a_page, div_fac;
      vq_scan( handle, &g_slice, &g_page, &a_slice, &a_page, &div_fac);
      fprintf(fp, "height of printer head, graphics mode:\t\t%d pixels\n", (int)(g_slice/div_fac) );
      fprintf(fp, "height of printer head, alfa mode:\t\t%d pixels\n", (int)(a_slice/div_fac) );
      fprintf(fp, "head passes per page, graphics mode:\t\t%d\n", (int)g_page );
      fprintf(fp, "head passes per page, alfa mode:\t\t%d\n", (int)a_page );
   } /* if */
   dump_fonts(fp,handle);
}


/*****************************************************
** list out the GDP functions available to a particular driver.
** The arguments are an output file pointer and 
** a pointer to a list of up to 10 supported GDPs, terminated with a -1,
** followed by a list of their attribute types.
** There are no returns.
**
** Usage:   dump_gdps(fp,list);
**
**          void dump_gdps(FILE *,int16 *);
*/

void dump_gdps( FILE *fp, int16 *list )
{
int f;
char *function, *attributes;

    for( f=0; f<10; f++) {
        switch(list[f]) {
            case 1:     function = "v_bar()";           break;
            case 2:     function = "v_arc()";           break;
            case 3:     function = "v_pieslice()";      break;
            case 4:     function = "v_circle()";        break;
            case 5:     function = "v_ellipse()";       break;
            case 6:     function = "v_ellarc()";        break;
            case 7:     function = "v_ellpie()";        break;
            case 8:     function = "v_rbox()";          break;
            case 9:     function = "v_rfbox()";         break;
            case 10:    function = "v_justified()";     break;
            case -1:    return;
            default:    function = "Unknown";           break;
        } /* switch */

        switch(list[f+10]) {
            case 0:     attributes = "polyline";        break;
            case 1:     attributes = "polymarker";      break;
            case 2:     attributes = "text";            break;
            case 3:     attributes = "fill area";       break;
            case 4:     attributes = "no";              break;
            default:    attributes = "unknown";         break;
        } /* switch */
        fprintf(fp,"\tGDP function %s supported using %s attributes\n",
                function,attributes);
    } /* for */
    putc('\n',fp);
} /* dump_gdps() */


/***********************************************************
** Function to dump out the list of font names
** available for a particular workstation.  The
** arguments are a pointer to a FILE to use for
** output, and a workstation handle.  There are
** no returns.
**
** Usage:   dump_fonts(fp,handle);
**
**          void dump_fonts(FILE *,int16);
*/

void dump_fonts( FILE *fp, int16 handle )
{
int f, size, font_index, number, start, end;
int16 dum;
char font_name[64];

   number = vst_load_fonts( handle, 0 );
   fprintf(fp,"\nAdditional fonts available\n--------------------------\n\n");
   if( number == 0 ) {
      fprintf(fp,"None\n");
   } /* if */

   for( f=1; f<=number+1; f++) {
      font_index = vqt_name( handle, f, font_name);
      fprintf(fp,"Font %d: %s (id is %d)\n", f, font_name, font_index );
      if( font_index > 0 ) {
         vst_font( handle, font_index );
         fprintf(fp," Sizes: ");
         start = end = -1;
         for( size=1; size<128; size++) {
            if( size == vst_point(handle,size,&dum,&dum,&dum,&dum) ) {
                end = size;
                if( start == -1)
                    start = size;
            }
            else if( start != -1) {
                if( start == end)
                    fprintf(fp,"%dpt ", start);
                else if( end > start + 1)
                    fprintf(fp,"%d to %d pts ",start,end);
                else fprintf(fp,"%d pt %d pt ",start,end);
                start = end = -1;
            } /* if */
         } /* for each size */
         if( start != -1)
            if( end > start + 1)
               if( end > start + 1)
                    fprintf(fp,"%d to %d pts ",start,end);
               else fprintf(fp,"%d pt %d pt ",start,end);
         fprintf(fp,"\n\n");
      } /* if */
   } /* for each font */
   vst_unload_fonts(handle,0);
} /* dump_fonts() */
/************************ end of drv_rpt.c ***************/  

/************************************************************************/
/*  v_bit.c                 Craig W. Daymon                    9/3/89   */
/*                                                                      */
/*  The following program requires GDOS and a GDOS printer driver as    */
/*  device #21 to be present.  It will display a file selector,         */
/*  allowing the user to select an .IMG file for printing.  The image   */
/*  will be scaled to fit in a 8"x10" area, preserving the proper       */
/*  aspect ratio and centered within the 8x10 area.                     */
/*                                                                      */
/*  The main purpose of this program is to show the proper bindings     */
/*  for the GEM function, v_bit_image().                                */
/*                                                                      */
/*  NOTE: This program contains virtually NO error checking.  If you    */
/*        do not have GDOS installed, it will likely crash.             */
/*                                                                      */
/*              * Written with Laser C from Megamax.                    */
/*                                                                      */
/************************************************************************/

#include <stdio.h>
#include <strings.h>

#include <osbind.h>
#include <gemdefs.h>
#include <obdefs.h>

#define TRUE  1
#define FALSE 0

int contrl[12];                     /* The GEM bindings                 */
int intin[256];
int ptsin[256];
int intout[256];
int ptsout[256];

char file[105];                     /* Image file name and path.        */
char fname[13];                     /* Fielname: 8 + 3(extender)        */

int pix_w, pix_h;       /* Printer pixel width and height in microns.   */

int prn_handle;                     /* printer handle                   */

int xyarray[8];                     /* Coordinates for 8x10 area.       */

main()
{
    register int i;

    appl_init();

    intin[0] = 21;                      /* GDOS Device #21 - printer    */
    for (i=1;i<10; ++i) intin[i] = 1;   /* use raster coordinates       */
    intin[10] = 2;
    v_opnwk(intin,&prn_handle,intout);
    pix_w = intout[3];                  /* Get printer pixel size.      */
    pix_h = intout[4];

    xyarray[0] = xyarray[1] = 0;

    /****        There are 25400 microns per inch.                  *****/

    xyarray[2] = (25400/pix_w) << 3;            /* 8  inches wide.      */
    xyarray[3] = (25400/pix_h) * 10;            /* 10 inches high.      */

    while(TRUE)
    {
        get_filename(file,fname,"*.IMG");   /* Get file to print.       */

        if(file[0] == '\0') break;

        v_bit_image(prn_handle,file,2,1,0,0,1,1,xyarray); 
        v_updwk(prn_handle);
        v_clrwk(prn_handle);

    }   

    v_clswk(prn_handle);

    appl_exit();

} /* End of main()  */

/*
    get_filename() is used for file selection.

    It is passed 2 string pointers:

        file_n_path -   Pointer to a character array to hold the useable
                        path and filename.  It will return a NULL string
                        if a CANCEL is returned by fsel_input() or the no
                        file name is selected.

        name        -   Default file name to use.

        ext         -   Pointer to a string describing the directory
                        search string/wild card.

        **  The string pointed to by file_n_path should be about        **
        **  105 characters in length to accommodate up to 7             **
        **  directories and the file name.                              **

*/

get_filename(file_n_path,name,ext)

    char    *file_n_path;   /* Pointer to useable path & file string.   */
    char    *name;
    char    *ext;
{
    char path[90];      /* Directory Path - Disk + a max of 7 folders   */
    int drive;  /* drive number returned by Dgetdrv - A=0,B=1,...       */
    int button; /* Button returned by fsel_input (ok or cancel)         */
    char c;     /*Just a dummy                                          */

    drive=Dgetdrv();            /* Get the current active drive         */
    path[0]=drive + 'A';    /* Places the drive letter in 1st position  */
    path[1] = ':';
    Dgetpath(&path[2],(drive+1));   /* Now we have the path             */
    strcat(path,"\\");
    strcat(path,ext);               /* Set initial directory search     */
    fsel_input(path,name,&button);
    if(!button || !strlen(name))
    {
        file_n_path[0] = '\0';
    }
    else
    {
        for(button=strlen(path);
            button && (((c = path[button-1]) != '\\') && (c != ':'));
            button--);

        path[button] = '\0';
        strcpy(file_n_path,path);
        strcat(file_n_path,name);
    }

} /* End of get_filename */

/*

    v_bit_image()

*/

v_bit_image(handle,filename,num_pts,aspect,xscale,yscale,halign,valign,points)
    int     handle;
    int     aspect;
    char    filename[];
    int     xscale,yscale;
    int     halign,valign;
    int     num_pts;
    int     points[];
{

    int     lv;                 /* Loop variable.                       */

    contrl[0]   =   5;          /* Opcode.                              */

    contrl[1]   =   num_pts;    /* 0    =   Take rectangle from file.   */
                                /*                                      */
                                /* 1    =   Use point as upper left     */
                                /*          corner and calculate lower  */
                                /*          left from file.             */
                                /*                                      */
                                /* 2    =   Use these points to define  */
                                /*          the rectangle.              */

    contrl[2]   =   0;

    contrl[3]   =   strlen(filename) + 5;

    contrl[4]   =   0;

    contrl[5]   =   23;         /* Function ID.                         */

    contrl[6]   =   handle;     /* The workstation device handle.       */

    intin[0]    =   aspect;     /* Aspect ratio flag:                   */
                                /*                                      */
                                /*  0   =   Ignore aspect ratio.        */
                                /*                                      */
                                /*  1   =   Preserve pixel aspect ratio.*/

    intin[1]    =   xscale;     /* X-axis scaling flag:                 */
                                /*                                      */
                                /*  0   =   Integral scaling.           */
                                /*                                      */
                                /*  1   =   Fractional scaling.         */

    intin[2]    =   yscale;     /* Y-axis scaling flag:                 */
                                /*                                      */
                                /*  0   =   Integral scaling.           */
                                /*                                      */
                                /*  1   =   Fractional scaling.         */

    intin[3]    =   halign;     /* Horizontal Alignment:                */
                                /*                                      */
                                /*  0   =   Left Aligned                */
                                /*                                      */
                                /*  1   =   Centered                    */
                                /*                                      */
                                /*  2   =   Right Aligned               */

    intin[4]    =   valign;     /* Vertical Alignment:                  */
                                /*                                      */
                                /*  0   =   Left Aligned                */
                                /*                                      */
                                /*  1   =   Centered                    */
                                /*                                      */
                                /*  2   =   Right Aligned               */



    for(lv = 0;filename[lv];lv++)
    {
        intin[5 + lv] = (int)filename[lv];
    }

    ptsin[0]    =   points[0];
    ptsin[1]    =   points[1];
    ptsin[2]    =   points[2];
    ptsin[3]    =   points[3];

    vdi();

} /* End of v_bit_image()   */


/***************************************************/
/* Program : PICSHOW.c                             */
/* Author  : Lee Russell                           */
/* Written : 28/03/93                              */
/* Revsion : 08/07/93                              */
/* Purpose : To display NEOCHROME format pictures  */
/***************************************************/

#include <dos.h>
#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/******************************************************************/
/* Define The Global Variables Required To Make The GEM Interface */
/******************************************************************/

int ap_id;         /* AES Application Handle          */
short handle;      /* VDI Virtual Workstation Handle  */
short phys_handle; /* VDI Physical Workstation Handle */

short work_in[11]={1,1,1,1,1,1,1,1,1,1,2};
short work_out[57];
short contrl[12];
short ptsin[128];
short ptsout[128];

/*************************************************/
/* Now Define The Global Variables For PICSHOW.c */
/*************************************************/

FILE *neo_file;

short old_pal[16]; /* The Old Colour Palette */
short new_pal[16]; /* The New Colour Palette */
short *picaddr;    /* Pointer To Base Of Temporary Screen Buffer */
short *tpicaddr;   /* Temporary Pointer To Screen Buffer         */

short dummy;       /* Dummy GEM Function Parameter */

/**************************************/
/* Now Define The Function Prototypes */
/**************************************/

void main(void);
void initialise(void);
void open_file(void);
void disp_pic(void);
void close_station(void);
void read_error(void);

/* End Of Function Prototype Definitions */

/*********************************/
/* The Main Function Begins Here */
/*********************************/

void main(void)
    {
    initialise();
    open_file();
    disp_pic();
    close_station();
    }
    
/******************************/
/* The Main Funtion Ends Here */
/******************************/

/********************************************/
/* Now Define The PICSHOW Control Functions */
/********************************************/

void initialise(void)
     {
     long amount;
     int cntr;
     short old, mode;
     
     ap_id = appl_init(); /* Set Up AES Global Arrays, Get Application ID */
     if (ap_id == -1)
        {
        exit(EXIT_FAILURE);
        }
        
     phys_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
     handle = phys_handle; /* Get VDI Physical Workstation Handle */

     v_opnvwk(work_in, &handle, work_out); /* Open Virtual Workstation */
     if (handle == 0)
        {
        appl_exit();
        exit(EXIT_FAILURE);
        }

     amount = 32000; /* A Low Resolution Screen Requires 32000 Bytes */
     picaddr = malloc(amount);
     if (picaddr == NULL)
        {
        form_alert(1,"[3][Can't Alloc Block][Quit]");
        v_clsvwk(handle);
        appl_exit();
        exit(EXIT_FAILURE);
        }            
     tpicaddr=picaddr;
     
     mode = -1;
     old = Blitmode(mode); /* Determine Blitter Status */
     if (old & 2)
        {
        Blitmode(old | 1); /* A Blitter Is Available, So Enable It */
        }

     for (cntr = 0; cntr <16; cntr++)
         {
         old_pal[cntr] = Setcolor(cntr, -1); /* Save The Current Palette */
         }

     mode = Getrez();
     if (mode != 0)
        {
        form_alert(1,"[3][Low Resolution Only !][QUIT]");
        close_station();
        }
     }
     
void open_file(void)
     {
     char select[FNSIZE];
     char dirname[FMSIZE];
     char fname[FNSIZE+FMSIZE]; /* More Than Enough Room For Path & Name */
     short button;     
     short pathlen;
     short cntr;     
     short dummy;
     
     getcd(0, dirname); /* Get The Current Drive And Path */
     strcat(dirname, "\\*.*");
     *select = 0;
     /* Now Display The GEM Extended File Selector */
     fsel_exinput(dirname, select, &button, "Load a File");

     if (button) /* If The User Has Double Clicked A File OR Clicked OK */
        {
        /* Now Construct The Path And Filename To The Selected File */
        pathlen = strlen(dirname);
        for (cntr = 0; cntr < pathlen; cntr++)
            {
            if (dirname[cntr] == '*')
               {
               break;
               }
            }
        strncpy(fname, dirname, cntr);
        strcat(fname, select);
               
        neo_file = fopen(fname, "rb");
        if (neo_file == NULL)
           {
           free(picaddr);
           form_alert(1,"[3][Can't Open NEO][Quit]");
           v_clsvwk(handle);
           appl_exit();
           exit(EXIT_FAILURE);
           }
     
        for (cntr = 0; cntr < 2; cntr++)
            {
            if (feof(neo_file) == 0)
               {
               dummy = fgetw(neo_file);
               }
            else
               {
               read_error();
               }
            }
     
        for (cntr = 0; cntr < 16; cntr++)
            {
            if (feof(neo_file) == 0)
               {
               new_pal[cntr]=fgetw(neo_file);
               }
            else
               {
               read_error();
               }
            }
          
        for (cntr = 0; cntr < 46; cntr++)
            {
            if (feof(neo_file)== 0)
               {
               dummy=fgetw(neo_file);
               }
            else
               {
               read_error();
               }
            }
          
        /* Now Read In 16000 Words Of Picture Data */
        for (cntr = 0; cntr < 16000; cntr++)
            {
            if (feof(neo_file) == 0)
               {
               dummy=fgetw(neo_file);
               *tpicaddr= dummy;
               tpicaddr++;
               }
            else
               {
               read_error();
               }
            }
          
        fclose(neo_file);
        }
     else
        {
        close_station(); /* The User Has Selected Cancel, So Quit */
        }
     }
     
void disp_pic(void)
     {
     int maxclicks, mask, state;       /* Variables Used By evnt_button() */
     short *x, *y, *button, *kstate;   /* Variables Used By evnt_button() */
     short xpos, ypos, butt, ks;       /* Variables Used By evnt_button() */

     /* Now Define Blitting Variables */
     short pxyarray[8]={0,0,319,199,0,0,319,199}; /* Clipping Rectangle */
     MFDB srce;     /* Source Memory Form Definition Block      */
     MFDB dest;     /* Destination Memory Form Definition Block */
     MFDB *s, *d;   /* Pointers To MFDB's */
     
     /* Initialise Variables */
     
     x = &xpos;        /* Final Mouse X Co-Ordinate    */
     y = &ypos;        /* Final Mouse Y Co-Ordinate    */
     button = &butt;   /* Final State Of Mouse Buttons */
     kstate = &ks;     /* Final State Of Shift Kets    */
     maxclicks = 2;    /* Wait For Single Or Double Mouse Click */
     mask = 1;         /* Check Left Mouse Button Status Only   */
     state = 1;        /* Check That The Left Button Is Down    */

     s = &srce;
     d = &dest;         
     srce.fd_addr=picaddr;  /* Start Of Temporary Screen Buffer          */
     srce.fd_w=319;         /* Height Of Source Form In Pixels           */
     srce.fd_h=199;         /* Width Of Source Form In Pixels            */
     srce.fd_wdwidth=20;    /* Word Width Of Source Form                 */
     srce.fd_stand=0;       /* Source Is In Device Specific Format       */
     srce.fd_nplanes=4;     /* A Low Resolution Picture Has 4 Bit Planes */
     dest.fd_addr=NULL;     /* The Destination Is The Physical Screen    */
     
     graf_mouse(M_OFF,NULL);
     v_clrwk(handle);
     Setpalette(new_pal);
     vro_cpyfm(handle, S_ONLY, pxyarray, s, d); /* Perform The Blit */
     graf_mouse(M_ON,NULL);
     evnt_button(maxclicks, mask, state, x, y, button, kstate);
     Setpalette(old_pal);
     }
     
void close_station(void)
     {
     free(picaddr); /* Release The Temporary Screen Buffer */
     v_clrwk(handle);
     v_clsvwk(handle);
     appl_exit();
     exit(EXIT_SUCCESS);
     }

void read_error(void)
     {
     form_alert(1,"[3][Error Reading File][QUIT]");
     free(picaddr); /* Release The Temporary Screen Buffer */
     v_clsvwk(handle);
     appl_exit();
     exit(EXIT_FAILURE);
     }
     
/* EOF : PICSHOW.c */
     
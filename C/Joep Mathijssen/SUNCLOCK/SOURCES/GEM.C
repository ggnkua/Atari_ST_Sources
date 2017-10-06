#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <vdi.h>
#include <aes.h>

#include "gem.h"

/*---- General GEM-variables ----*/
int handle,
    work_out[57],
    work_in[12],
    pxyarray[10],
    txt_attrib[10];

char errorsound[100] = {
                  0  ,  0,                          /* Voice A frequention */
                  1  ,  5,
                  2  ,  0,                          /* Voice B frequention */
                  3  ,  0,
                  4  ,  0,                          /* Voice C frequention */
                  5  ,  0,
                  6  ,  50,                           /* Noise frequention */
                  7  ,  0xf6,                                  /* Switches */
                  8  ,  31,                                    /* Volume A */
                  9  ,  0,                                     /* Volume B */
                  10 ,  0,                                     /* Volume C */
                  11 ,  8,                         /* Period of the master */
                  12 ,  3,
                  13 ,  8,                                         /* Wave */
                  0x80, 0,
                  0x81, 0, 0x08, 248,
                  7  ,  0xff,
                  8  ,  0,
                  255,  0
};

static bool GemRscLoaded = FALSE;

/*-------------------------------------------------------------------------*/
/* GemInit:                                                                */
/* Opens an gem-application.                                               */
/* Load .RSC-file, not when rscfile = NULL.                                */
/*-------------------------------------------------------------------------*/
void GemInit( res, rscfile )
eGetRez res;
char *rscfile;
{
    register int i;
    char str[50];

    appl_init();
    for(i=0 ; i<10 ; work_in[i++] = 1);
    work_in[10] = 2;
    v_opnvwk(work_in, &handle, work_out);
    vqt_attributes(handle, txt_attrib);              /* get text attributes */
    v_show_c(handle, 0);

    if (!(Getrez() & res)) {
       GemSound();
       strcpy(str, "Wrong resolution:|(");
       if (res & cLowRez) strcat(str, " Low");
       if (res & cMedRez) strcat(str, " Med");
       if (res & cHighRez) strcat(str, " High");
       strcat(str, " )");
       GemAbort(str); 
    }

    if (rscfile) {
        GemRscLoaded = TRUE;
        if (!rsrc_load(rscfile))
            GemAbort("Loading .RSC failed!");
    }
}

/*-------------------------------------------------------------------------*/
/* GemExit:                                                                */
/* Closes an gem-application.                                              */
/*-------------------------------------------------------------------------*/
void GemExit()
{
    if (GemRscLoaded)
        if (!rsrc_free())
            GemAbort("Freeing .RSC failed!");
    v_clsvwk(handle);
    printf("\033q\033E");
    appl_exit();
}
 
/*-------------------------------------------------------------------------*/
/* GemAbort:                                                               */
/* Aborts the program and returns to the desktop.                          */
/* Usefull on error-conditions.                                            */
/*-------------------------------------------------------------------------*/
void GemAbort(str)
char *str;
{
    char *abortstr;

    abortstr = (char*)malloc( strlen(str) + 20 ); 
    sprintf(abortstr, "[3][%s][DESKTOP]", str);
    form_alert(1, abortstr);
    free(abortstr);
    appl_exit();
    Pterm0();
}

/*-------------------------------------------------------------------------*/
/* GemSound:                                                               */
/* If an error occurs this sound can be used to get attention of the user. */
/*-------------------------------------------------------------------------*/
void GemSound()
{
    Dosound(errorsound);
}


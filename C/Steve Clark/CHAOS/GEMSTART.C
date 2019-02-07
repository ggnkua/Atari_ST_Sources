/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include <aesbind.h>
#include <vdibind.h>
#include "easy.h"

gemstart()

/*
** This routine opens a virtual workstation for use by the gem routines.
** It must be called before any gem routines can be used. */

{
   appl_init();
   handle = graf_handle(&letterw, &letterh, &charboxw, &charboxh);
   v_opnvwk(workin, &handle, workout);
   xrez = workout[0] + 1;
   yrez = workout[1] + 1;
   nplanes = 1;   /* Number of bit planes for High resolution display */
   if(yrez EQ 200) nplanes = 2;  /* Medium resolution */
   if(xrez EQ 320) nplanes = 4;  /* Low resolution */
   v_hide_c(handle);    /* Turn off the mouse pointer */
}


gemend()  /********************* GEMEND *******************************/

/* This routine is used to shut down a gem virtual work station. It must be
   called when a workstation has been opened by gemstart() */

{
   v_clsvwk(handle);
   appl_exit();
}

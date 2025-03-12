/************************************************************/
/* Atari ST-spezifische Routine(n)                          */
/* ======================================================== */
/* Quelldatei: INTERNA.C                                    */
/************************************************************/

/* TOS ist gefragt! */
# include <tos.h>

/************************************************************/
/* Boot-Laufwerk                                            */
/* Aufgabe: Ermittlung des Boot-Laufwerks                   */
/************************************************************/

int boot_dev(void)

{long old_super_stack;
 int  ret_wert;

 old_super_stack = Super(0L);        /* Supervisor-Modus */
 ret_wert        = *(int*) 0x446;
 Super((void *) old_super_stack);    /* User-Modus       */
 return(ret_wert);
}


/************************************************************/


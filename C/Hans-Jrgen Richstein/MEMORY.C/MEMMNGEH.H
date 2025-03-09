/**************************************************************/
/*                         MEM_MNGE.H                         */
/*                        ============                        */
/*                                                            */
/* Prototypen der Funktionen, die zur Verwendung des neuen    */ 
/* "Memory Managers" erforderlich sind. Diese mÅssen mit      */
/* 'include "MEM_MNGE.H" ' in das eigene Programm eingebunden */
/* werden. In der Projektdatei muû dann lediglich der Objekt- */
/* code durch einfÅgen einer Zeile 'MEM_MNGE.O' bekannt ge-   */
/* macht werden.                                              */
/**************************************************************/

long init_memory_manager(void *start_adress, long size);
long hjr_total_coreleft(void);
long hjr_number_of_fragments(void);
long hjr_coreleft(void);
long hjr_free(void *block);

void *hjr_malloc(long desired_size);
void *hjr_calloc(long number_of_items, long size_of_items);
void *hjr_realloc(void *block, long new_size);


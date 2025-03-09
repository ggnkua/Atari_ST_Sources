/*************************************************************************/
/*                          Memory Manager                               */
/*                         ================                              */
/*                                                                       */
/* Funktionen zur effektiven Verwaltung eines Freispeicher-Heaps, ins-   */
/* besondere vorteilhaft bei Verwendung vieler kleiner dynamisch erfor-  */
/* derlicher Speicherbereiche, wie sie in Datenstrukturen wie Listen und */
/* BÑumen oft erforderlich sind.                                         */
/*                                                                       */
/* Autor :      Hans-JÅrgen Richstein                                    */
/*              Konrad-Adenauer Str. 19                                  */
/*              6750 Kaiserslautern                                      */
/*              Tel.: 0631/22253                                         */
/*                                                                       */
/*************************************************************************/

#include "MEM_MNGE.H"       /*   Prototypen der exportierten Funktionen  */
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

/*********************** Datenstrukturen *********************************/

#define MEM_BLOCK struct memory_header

MEM_BLOCK                   /* Header der Freispeicherbereiche           */
{                           /* ===============================           */
    MEM_BLOCK *next;        /* Freispeicher an der nÑchsthîheren Adresse */
    long    size;           /* Grîûe dieses Speicherblocks (incl. Header)*/
    char    data[];         /* Rest des Blocks folgt hier                */
};


typedef struct              /* Header fÅr vergebenen Speicher > 64 KB    */
{                           /* ======================================    */
    long    size;           /* Grîûe des Blocks (incl. Header)           */
    int     mark;           /* Markierung (immer 0)                      */
    char    user_block[];   /* Hier beginnt der vom User nutzbare Bereich*/
} LARGE_BLOCK;


typedef struct              /* Header fÅr vergebenen Speicher < 64 KB    */
{                           /* ======================================    */
    unsigned int size;      /* Grîûe des Blocks (incl. Header)           */
    char    user_block[];   /* Hier beginnt der vom User nutzbare Bereich*/
} SMALL_BLOCK;

/**************** Prototypen der internen Funktionen *********************/

void remove_from_list(MEM_BLOCK *block);
void get_block_data (void *block, MEM_BLOCK **block_start, 
                     long *block_size, long *size_of_user_data);
void *make_user_block(MEM_BLOCK *block, long block_size);
void *shrink_block(void *block, long old_size, long new_size);
void split_block(MEM_BLOCK *block, long size_of_first);

long actual_size(long desired_size);
long insert_into_list(MEM_BLOCK *block,long size);

MEM_BLOCK *find_previous_block(MEM_BLOCK *block);


/******************* Verwaltungsinformationen ****************************/

static MEM_BLOCK head;          /* Listenkopf, dummy-Header mit size = 0 */

static char *start_of_buffer,   /* Anfang und Ende des verwalteten Be-   */
            *end_of_buffer;     /* reichs zur PlausibilitÑtskontrolle der*/
                                /* mit 'hjr_free' zurÅckgegebenen Blîcke */

/*-----------------------------------------------------------------------*/

long init_memory_manager(void *start_adress,long size)
/*************************************************************************/
/* Eingabe: Zeiger auf den zu verwaltenden Speicherbereich und die LÑnge */
/*          dieses Bereiches                                             */
/* Effekt : Die internen Verwaltungsstrukturen werden initialisiert      */
/* Wert   : 0 = Alles Paletti, -1 = Es konnte nicht initialisiert werden */
/*************************************************************************/
{
    if ((size < sizeof(MEM_BLOCK)) || (start_adress == NULL))
        return -1;
    else
    {
        ((MEM_BLOCK *) start_adress)->next = NULL;
        ((MEM_BLOCK *) start_adress)->size = size;
        head.next = (MEM_BLOCK *) start_adress;
        start_of_buffer = (char *) start_adress;
        end_of_buffer = (char *) start_adress + size;
        head.size = 0;
        return 0;
    }
}
/*-----------------------------------------------------------------------*/

void *hjr_malloc(long desired_size)
/*************************************************************************/
/* Eingabe: Die gewÅnschte Speichergrîûe                                 */
/* Effekt : Es wird der erste passende Bereich ('First Fit' Verfahren)   */
/*          auf die gewÅnschte Grîûe gestutzt und verbleibender Speicher */
/*          wieder an die Freispeicherverkettung eingehÑngt.             */
/* Wert   : Ein void-Zeiger auf den allokierten Bereich. Ist kein aus-   */
/*          reichend groûer Speicher vorhanden, wird ein Nullzeiger zu-  */
/*          rÅckgegeben                                                  */
/*************************************************************************/
{
    MEM_BLOCK *current_block,*previous_block;
    void *desired_block;
    long allocated_size;

    desired_block = NULL;
    
    if (desired_size >= 0)
    {   
        allocated_size = actual_size(desired_size);
                
        current_block = head.next;
        previous_block = &head;
        
        while ((current_block != NULL) 
               && (current_block->size < allocated_size))
        {
            previous_block = current_block;
            current_block = current_block->next;
        }
        
        if (current_block != NULL)
        {
            if (current_block->size - allocated_size < sizeof(MEM_BLOCK))
                allocated_size = current_block->size; /* Aufteilen lohnt */
            else                                      /* nicht...        */
                split_block(current_block,allocated_size);
        
            previous_block->next = current_block->next;
            
            desired_block = make_user_block(current_block,allocated_size);
        }
    }
    return desired_block;
}
/*-----------------------------------------------------------------------*/

void *hjr_calloc(long number_of_items, long size_of_items)
/*************************************************************************/
/* Eingabe: Eine Anzahl von Elementen und die Grîûe eines dieser Elemente*/
/* Effekt : Es wird ein 'hjr_malloc' mit Anzahl * Grîûe Bytes durchge-   */
/*          fÅhrt. Falls dies erfolgreich war, wird der Bereich mit Null */
/*          initialisiert                                                */
/* Wert   : siehe 'hjr_malloc'                                           */
/*************************************************************************/
{
    void *block;
    long total_size;
    
    total_size = number_of_items * size_of_items;
    block = hjr_malloc(total_size);
    if (block != NULL)
        memset(block,0,total_size);
    return block;
}
/*-----------------------------------------------------------------------*/

void *hjr_realloc(void *block, long new_size)
/*************************************************************************/
/* Eingabe: Der Zeiger auf einen bereits allokierten Block und eine neue */
/*          Grîûe fÅr diesen Bereich.                                    */
/* Effekt : Bei einer Verkleinerung wird der frei werdende Speicher      */
/*          wieder in die Freispeicherverkettung einsortiert, bei einer  */
/*          Vergrîûerung wird zunÑchst versucht, Speicher der zusÑtzlich */
/*          erforderlichen Grîûe direkt hinter dem bestehenden Block zu  */
/*          finden. Gelingt dies nicht, wird ein neuer Block der ge-     */
/*          wÅnschten Grîûe allokiert und die bestehenden Daten werden   */
/*          in den neuen Bereich verschoben.                             */
/* Wert   : Der Zeiger auf den neuen Bereich. Kann kein Speicher der an- */
/*          geforderten Grîûe reallokiert werden, so wird ein Nullzeiger */
/*          geliefert. Der ursprÅngliche Block bleibt dann unverÑndert.  */
/*************************************************************************/
{
    MEM_BLOCK *returned_block,
              *previous,
              *following;

    void *temp_block;

    long current_size,
         size_of_reallocation,
         size_of_enlargement,
         data_size;


    size_of_reallocation = actual_size(new_size);
    
    if ((block != NULL) && (size_of_reallocation >= sizeof(MEM_BLOCK)))
    {
        get_block_data(block,&returned_block,&current_size,&data_size);

        if (size_of_reallocation > current_size)    /* Block vergrîûern  */
                                                    /* ================= */
        {           
            previous = find_previous_block(returned_block);
            following = previous->next;

            if (((char *) returned_block 
                                + current_size == (char *) following)
                 && (current_size + following->size >= size_of_reallocation))
            {
                size_of_enlargement = current_size + following->size;
            
                previous->next = following->next;
            
                if (   (current_size < 0xffff) 
                    && (size_of_reallocation > 0xffff))
                    memcpy((char *) block + sizeof(LARGE_BLOCK) 
                                            - sizeof(SMALL_BLOCK),
                            block,data_size);

                block = shrink_block(returned_block,
                                     size_of_enlargement,
                                     size_of_reallocation);
            }
            else

            if (((char *) returned_block == (char *) previous 
                                                        + previous->size)
                && (current_size + previous->size >= size_of_reallocation))
            {
                size_of_enlargement = current_size + previous->size;
                remove_from_list(previous);
                temp_block = block;
                block = make_user_block(previous,size_of_reallocation);
                memcpy(block,temp_block,data_size);
                shrink_block(previous,
                             size_of_enlargement,
                             size_of_reallocation);             
            }
            else

            if (((char *) returned_block 
                                + current_size == (char *) following)

                && ((char *) returned_block == (char *) previous 
                                                        + previous->size)
                && (current_size 
                        + previous->size 
                                + following->size >= size_of_reallocation))
            {
                size_of_enlargement = current_size 
                                        + previous->size 
                                                + following->size;
                

                previous->next = following->next;
                remove_from_list(previous);

                temp_block = block;
                block = make_user_block(previous,size_of_reallocation);
                memcpy(block,temp_block,data_size);
                shrink_block(previous,
                             size_of_enlargement,
                             size_of_reallocation);             

            }
            else

            {
                temp_block = block;
                block = hjr_malloc(new_size);
                
                if (block != NULL)
                {
                    memcpy(block,temp_block,data_size);
                    hjr_free(temp_block);
                }
            }
        }
        else

        if (size_of_reallocation < current_size)  /* Block verkleinern */
        {                                         /* ================= */

            if ((current_size > 0xffff) && (size_of_reallocation < 0xffff))
                memcpy(((SMALL_BLOCK *) returned_block)->user_block,
                        block,data_size);

            shrink_block(returned_block,
                         current_size,
                         size_of_reallocation);         
        }
    }
    return block;
}
/*-----------------------------------------------------------------------*/

long hjr_free(void *block)
/*************************************************************************/
/* Eingabe: Der Zeiger auf einen allokierten Block.                      */
/* Effekt : Soweit mîglich, wird mittels einer PlausibilitÑtskontrolle   */
/*          geprÅft, ob es sich tatsÑchlich um einen vorher allokierten  */
/*          Block handelt. Wenn ja, wird dieser in die Freispeicherver-  */
/*          kettung eingehÑngt.                                          */
/* Wert   : 0 = Alles Paletti, -1 = Block konnte nicht angenommen werden */
/*************************************************************************/
{
    MEM_BLOCK *returned_block;
    long size, dummy;
    
    if (block != NULL)
    {
        get_block_data(block,&returned_block,&size,&dummy);

        return insert_into_list(returned_block,size);
    }
    else
        return -1;
}
/*-----------------------------------------------------------------------*/

long hjr_coreleft(void)
/*************************************************************************/
/* Eingabe: --                                                           */
/* Effekt : --                                                           */
/* Wert   : Die nutzbare Grîûe des grîûten freien Speicherbereichs       */
/*************************************************************************/
{
    MEM_BLOCK *block;
    long size_of_largest;
    
    size_of_largest = 0;
    block = &head;  
    
    while (block->next != NULL)
    {
        if (block->size > size_of_largest)
            size_of_largest = block->size;
            
        block = block->next;
    }
    
    return size_of_largest - ((size_of_largest < 0xFFFFL) 
                                                ? sizeof(SMALL_BLOCK)
                                                : sizeof(LARGE_BLOCK));
}
/*-----------------------------------------------------------------------*/

long hjr_total_coreleft(void)
/*************************************************************************/
/* Eingabe: --                                                           */
/* Effekt : --                                                           */
/* Wert   : Die Summe der nutzbaren Grîûen aller freien Speicherbereiche */
/*************************************************************************/
{
    MEM_BLOCK *block;
    long total;

    block = head.next;
    total = 0L;
    
    while (block != NULL)
    {
        total += block->size - 
                    ((block->size < 0xFFFFL) ? sizeof(SMALL_BLOCK)
                                             : sizeof(LARGE_BLOCK));
        block = block->next;
    }
    
    return total;
}
/*-----------------------------------------------------------------------*/

long hjr_number_of_fragments(void)
/*************************************************************************/
/* Eingabe: --                                                           */
/* Effekt : --                                                           */
/* Wert   : Die Anzahl der Freipeicherfragmente                          */
/*************************************************************************/
{
    MEM_BLOCK *block;
    long total;

    block = &head;
    total = 0L;
    
    while (block->next != NULL)
    {
        total++;
        block = block->next;
    }
    
    return total;
}
/*-----------------------------------------------------------------------*/


/*************************************************************************/
/*                        Interne Funktionen                             */
/*************************************************************************/


static void *make_user_block(MEM_BLOCK *block, long block_size)
/*************************************************************************/
/* Eingabe: Zeiger auf einen (ehemaligen) Freispeicherbereich und die    */
/*          LÑnge des vergebenen Blocks.                                 */
/* Effekt : Der Block wird zur Vergabe mit dem der Grîûe entsprechenden  */
/*          Header versehen, also in einen 'Userblock' verwandelt.       */
/* Wert   : Der void-Zeiger auf den tatsÑchlich nutzbaren Bereich.       */
/*************************************************************************/
{
    if (block_size > 0xFFFF) 
    {
        ((LARGE_BLOCK *) block)->size = block_size;
        ((LARGE_BLOCK *) block)->mark = 0;
        return (void *) &(((LARGE_BLOCK *) block)->user_block);
    }
    else
    {
        ((SMALL_BLOCK *) block)->size = (unsigned int) block_size;
        return (void *) &(((SMALL_BLOCK *) block)->user_block);
    }
}
/*-----------------------------------------------------------------------*/

static long actual_size(long desired_size)
/*************************************************************************/
/* Eingabe: Die gewÅnschte Grîûe                                         */
/* Effekt : --                                                           */
/* Wert   : Die tatsÑchlich zuzuweisende Grîûe incl. Verwaltungsbereich  */
/*************************************************************************/
{
    long size;
    
    if (desired_size & 1L)              /* Ungerade ?       */
        desired_size++;                 /* ... gibt's nicht */
    
    size = desired_size + ((desired_size < 0xFFFEL) ?  sizeof(SMALL_BLOCK)
                                                     : sizeof(LARGE_BLOCK));

    if (size < (long) sizeof(MEM_BLOCK)) size = sizeof(MEM_BLOCK);

    return size;
}
/*-----------------------------------------------------------------------*/

static void get_block_data (void *block, MEM_BLOCK **block_start, 
                            long *block_size, long *size_of_user_data)
/*************************************************************************/
/* Eingabe: Zeiger auf einen zurÅckgegebenen Block und die Adressen von  */
/*          Variablen fÅr einen Zeiger, Blockgrîûe und Datenbereichsgrîûe*/
/* Effekt : In die Variable 'block_start' wird der tatsÑchliche Beginn   */
/*          des Blocks geschrieben, in 'block_size' die Grîûe des gesam- */
/*          ten Blocks und in 'size_of_user_data' die Grîûe des Daten-   */
/*          bereichs.                                                    */
/* Wert   : --                                                           */
/*************************************************************************/
{
    if (*((int *) block - 1) == 0)
    {
        *block_start = (MEM_BLOCK *) ((LARGE_BLOCK *) block - 1);
        *block_size = ((LARGE_BLOCK *) *block_start)->size;
        *size_of_user_data = *block_size - sizeof(LARGE_BLOCK);
    }
    else
    {
        *block_start = (MEM_BLOCK *) ((SMALL_BLOCK *) block - 1);
        *block_size = (long) ((SMALL_BLOCK *) *block_start)->size;
        *size_of_user_data = *block_size - sizeof(SMALL_BLOCK);
    }
}
/*-----------------------------------------------------------------------*/

static MEM_BLOCK *find_previous_block(MEM_BLOCK *block)
/*************************************************************************/
/* Eingabe: Zeiger auf einen Speicherbereich                             */
/* Effekt : --                                                           */
/* Wert   : Zeiger auf den letzten freien Speicherblock, der vor der     */
/*          Åbergebenen Adresse liegt.                                   */
/*************************************************************************/
{
    MEM_BLOCK *previous;
    
    previous = &head;
    
    while ((previous->next < block) && (previous->next != NULL))
        previous = previous->next;
    
    return previous;
}
/*-----------------------------------------------------------------------*/

static void *shrink_block(void *block, long old_size, long new_size)
/*************************************************************************/
/* Eingabe: Ein Zeiger auf einen bel. Block, dessen bisherige Grîûe und  */
/*          die neue (kleinere) Grîûe.                                   */
/* Effekt : Falls der verbleibende Rest zur Aufnahme eines MEM_BLOCK-    */
/*          Headers ausreicht, wird er wie ein zuvor allokierter Block   */
/*          prÑpariert und dann freigegeben, also in die Freispeicherver-*/
/*          kettung einverleibt.                                         */
/* Wert   : Der verkleinerte Block als 'Userblock'.                      */
/*************************************************************************/
{
    if (old_size - new_size >= (long) sizeof(MEM_BLOCK))
    {
        hjr_free(make_user_block((MEM_BLOCK *) 
                                    ((char *) block + new_size),
                                  old_size - new_size));

        return make_user_block(block,new_size);
    }
    else
        return make_user_block(block,old_size);
}
/*-----------------------------------------------------------------------*/

static void split_block(MEM_BLOCK *block, long size_of_first)
/*************************************************************************/
/* Eingabe: Zeiger auf einen Freispeicherbereich und die gewÅnschte LÑnge*/
/*          des ersten der beiden entstehenden Blîcke.                   */
/* Effekt : Der neu entstehende zweite Freispeicherbereich wird mit der  */
/*          sich ergebenden Grîûe und der Adresses des folgenden Blocks  */
/*          initialisiert. Dementsprechend wird der erste Block mit der  */
/*          neuen Grîûe und der Adresse des neuen zweiten Blocks als     */
/*          Folgeblock aktualisiert                                      */
/* Wert   : --                                                           */
/*************************************************************************/
{
    MEM_BLOCK *second_block;
    
    second_block = (MEM_BLOCK *) (((char *) block) + size_of_first);
    second_block->next = block->next;
    second_block->size = block->size - size_of_first;
    block->size = size_of_first;
    block->next = second_block;
}
/*-----------------------------------------------------------------------*/

static long insert_into_list(MEM_BLOCK *block, long size)
/*************************************************************************/
/* Eingabe: Ein Zeiger auf einen zukÅnftigen, daher evt. nicht initiali- */
/*          sierten Freispeicherblock und (deswegen extra) dessen LÑnge. */
/* Effekt : ZunÑchst wird geprÅft, ob sich aus Adresse und LÑnge keine   */
/*          Kollisionsprobleme mit vorherigem und nachfolgendem Freispei-*/
/*          cher ergeben. In dem Fall passiert nichts. Ansonsten wird    */
/*          versucht, aus dem gegebenen Block und dem davor- und/oder da-*/
/*          hinterliegenden Freispeicher einen zusammenhÑngenden Block zu*/
/*          erzeugen.                                                    */
/* Wert   : -1 = o.g. Kollisionsproblem ist aufgetreten                  */
/*          0  = alles in Ordnung                                        */
/*************************************************************************/
{
    MEM_BLOCK *previous,*following;
        
    previous = find_previous_block(block);
    following = previous->next;

    if ( (  (following != NULL)               /* PlausibilitÑtskontrolle */
            && ((MEM_BLOCK *) ((char *) block + size) > following))
        ||  (size < (long) sizeof(MEM_BLOCK))
        ||  (block < (MEM_BLOCK *) ((char *) previous + previous->size))
        ||  ((char *) block < start_of_buffer)
        ||  ((char *) block + size > end_of_buffer))

        return -1;       /* Diesen Block nehmen wir nicht */

    else
    {
        block->size = size;
        if ((MEM_BLOCK *) ((char *) previous + previous->size) == block)
        {
            previous->size += size;
            block = previous;
        }
        else
        {
            block->size = size;
            block->next = following;
            previous->next = block;
        }
        
        if ((MEM_BLOCK *) ((char *) block + block->size) == following)
        {
            block->size += following->size;
            block->next = following->next;
        }
        return 0;
    }
}
/*-----------------------------------------------------------------------*/

static void remove_from_list(MEM_BLOCK *block)
/*************************************************************************/
/* Eingabe: Ein Zeiger auf einen initialisierten Freispeicherblock.      */
/* Effekt : Der Block wird aus der Freispeicherverkettung entfernt       */
/* Wert   : --                                                           */
/*************************************************************************/
{   
    MEM_BLOCK *previous;
    
    previous = find_previous_block(block);
    
    previous->next = block->next;
    block->next = NULL;
}
/*-----------------------------------------------------------------------*/


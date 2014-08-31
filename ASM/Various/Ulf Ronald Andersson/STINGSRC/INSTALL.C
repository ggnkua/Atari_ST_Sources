
/*********************************************************************/
/*                                                                   */
/*     STinG : API and IP kernel package                             */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                      from 23. November 1996      */
/*                                                                   */
/*      Module for Installation, Config Strings, *.STX Loading       */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#include "globdefs.h"


#define  MAX_SEMAPHOR    64


long           init_cookie (void);

void           install_PrivVio (void);
void           uninst_PrivVio (void);
uint16         lock_exec (uint16 status);

void           install (void);
int16          KRinitialize (int32 size);
void *  cdecl  KRmalloc (int32 size);
void    cdecl  KRfree (void *mem_block);

int16   cdecl  routing_table (void);

void           get_path (void);
long           get_boot_drv (void);
int16          compare (char string_1[], char string_2[], int16 number);
int16          search_value (char **string);
int16          init_cfg (char filename[]);
int16   cdecl  setvstr (char name[], char value[]);
long           do_setvstr (void *array);
char *  cdecl  getvstr (char name[]);
void           load_stx (void);


extern CONFIG  conf;
extern void    *memory;

char  sting_path[245], semaphors[MAX_SEMAPHOR];



void  main()

{
   int   count;
   char  def_conf[255];

   puts ("\n\033p  *** STinG TCP/IP InterNet Connection Layer ***  \033q");

   for (count = 0; count < MAX_SEMAPHOR; count++)
        semaphors[count] = 0;

   get_path();

   strcpy (def_conf, sting_path);
   strcat (def_conf, "DEFAULT.CFG");

   install_PrivVio();

   switch (init_cfg (def_conf)) {
      case -3 :
        puts ("Could not allocate enough memory ! No installation ...");
        uninst_PrivVio();
        return;
      case -2 :
        puts ("ALLOCMEM must be at least 1024 bytes ! No installation ...");
        uninst_PrivVio();
        return;
      case -1 :
        puts ("Problem finding/reading DEFAULT.CFG ! No installation ...");
        uninst_PrivVio();
        return;
      }

   if (Supexec (init_cookie) < 0) {
        puts ("STinG already installed ! No installation ...");
        uninst_PrivVio();
        if (memory)   Mfree (memory);
        return;
      }

   install();
   load_stx();
   routing_table();

   strcpy (def_conf, "STinG version ");   strcat (def_conf, TCP_DRIVER_VERSION);
   strcat (def_conf, " (");               strcat (def_conf, STX_LAYER_VERSION);
   strcat (def_conf, ") installed ...");
   puts (def_conf);

   Ptermres (_PgmSize, 0);
 }


void  get_path()

{
   int   handle;
   long  len;
   char  *ptr, file[] = "\\STING.INF", path[] = "\\STING\\";

   sting_path[0] = 'A' + Dgetdrv();
   sting_path[1] = ':';
   Dgetpath (&sting_path[2], 0);
   strcat (sting_path, file);
   handle = (int) Fopen (sting_path, 0);

   if (handle < 0) {
        strcpy (&sting_path[3], "AUTO");
        strcat (sting_path, file);
        handle = (int) Fopen (sting_path, 0);

        if (handle < 0) {
             strcpy (&sting_path[2], file);
             handle = (int) Fopen (sting_path, 0);

             if (handle < 0) {
                  sting_path[0] = (char) Supexec (get_boot_drv);
                  handle = (int) Fopen (sting_path, 0);

                  if (handle < 0) {
                       strcpy (sting_path, path);
                       return;
                     }
                }
           }
      }

   len = Fread (handle, 240L, sting_path);
   Fclose (handle);

   if (len > 0) {
        if ((ptr = strchr (sting_path, '\r')) != NULL)   *ptr = '\0';
        if ((ptr = strchr (sting_path, '\n')) != NULL)   *ptr = '\0';
        sting_path[len] = '\0';
      }
     else
        strcpy (sting_path, path);
 }


long  get_boot_drv()

{
   unsigned  int  *_bootdev = (void *) 0x446L;

   return ((long) ('A' + *_bootdev));
 }


int16  compare (string_1, string_2, number)

char   string_1[], string_2[];
int16  number;

{
   int16  count;

   for (count = 0; count < number; count++) {
        if (toupper (string_1[count]) != toupper (string_2[count]))
             return (FALSE);
        if (! string_1[count] || ! string_2[count])
             return (FALSE);
      }

   return (TRUE);
 }


int16  search_value (string)

char  **string;

{
   int16  count;

   while (**string == ' ' || **string == '\t')
        (*string)++;

   if (**string != '=')
        return ((**string == '\r' || **string == '\n') ? 1 : -1);

   (*string)++;

   while (**string == ' ' || **string == '\t')
        (*string)++;

   return (0);
 }


int16  init_cfg (fname)

char  fname[];

{
   int32  status, length, count, memory;
   int16  handle;
   char   *cfg_ptr, *work, *name, *value, *tmp;

   if ((status = Fopen (fname, FO_READ)) < 0)
        return (-1);
   handle = (int16) status;

   length = Fseek (0, handle, 2);
   Fseek (0, handle, 0);

   if ((cfg_ptr = (char *) Malloc (length + 3)) == NULL) {
        Fclose (handle);
        return (-1);
      }
   status = Fread (handle, length, cfg_ptr);
   Fclose (handle);

   if (status != length) {
        Mfree (cfg_ptr);   return (-1);
      }
   strcpy (& cfg_ptr[length], "\r\n");

   for (count = 0; count < length; count++)
        if (compare (& cfg_ptr[count], "ALLOCMEM", 8)) {
             work = & cfg_ptr[count - 1];
             if (count != 0 && *work != '\r' && *work != '\n')
                  continue;
             work = & cfg_ptr[count + 8];
             if (search_value (& work) != 0) {
                  Mfree (cfg_ptr);
                  return (-1);
                }
             if ((memory = atol (work)) < 1024) {
                  Mfree (cfg_ptr);
                  return (-2);
                }
             if (KRinitialize (memory) < 0)
                  return (-3);
             break;
           }

   if (count >= length) {
        Mfree (cfg_ptr);   return (-1);
      }

   for (count = 0; count < CFG_NUM; count++)
        conf.cv[count] = NULL;

   work = cfg_ptr;

   while (*work && work < &cfg_ptr[length] && count > 0) {
        if (isalpha (*work)) {
             name = work;
             while (isalpha (*work) || *work == '_')
                  work++;
             tmp = work;
             switch (search_value (&work)) {
                case  0 :
                  if (*work == '\r' || *work == '\n') {
                       value = "0";
                       break;
                     }
                case -1 :   value = work;   break;
                case  1 :   value = "1";    break;
                }
             while (*work && *work != '\r' && *work != '\n')
                  work++;
             --work;
             while (*work == ' ' || *work == '\t')
                  --work;
             work++;
             *work++ = *tmp = '\0';
             setvstr (name, value);
             count--;
           }
        while (*work && *work != '\r' && *work != '\n')
             work++;
        while (*work == '\r' || *work == '\n')
             work++;
      }

   Mfree (cfg_ptr);
   return (0);
 }


int16  cdecl  setvstr (name, value)

char  *name, value[];

{
   uint16  length, status, count;
   char    *work;

   length = strlen (name);

   status = lock_exec (0);

   for (count = 0; count < length; count++)
        if (! isalpha (name[count]) && name[count] != '_') {
             lock_exec (status);
             return (FALSE);
           }

   for (count = 0; count < CFG_NUM; count++)
        if (conf.cv[count]) {
             if (compare (name, conf.cv[count], length))
                  break;
           }
          else
             break;

   if (count >= CFG_NUM || (length = length + strlen (value) + 3) > 253) {
        lock_exec (status);
        return (FALSE);
      }

   if (conf.cv[count]) {
        if (length <= (int) *(conf.cv[count] - 1))
             work = conf.cv[count];
          else {
             if ((work = KRmalloc (length)) == NULL) {
                  lock_exec (status);
                  return (FALSE);
                }
             KRfree (conf.cv[count] - 1);
             *work++ = (unsigned char) length;
           }
      }
     else {
        if ((work = KRmalloc (length)) == NULL) {
             lock_exec (status);
             return (FALSE);
           }
        *work++ = (unsigned char) length;
      }

   conf.cv[count] = work;
   strcpy (work, name);   strcat (work, "=");   strcat (work, value);

   lock_exec (status);

   return (TRUE);
 }


char *  cdecl  getvstr (name)

char  *name;

{
   uint16  length, status, count;
   char    *result;

   length = strlen (name);

   status = lock_exec (0);

   for (count = 0; count < CFG_NUM; count++)
        if (conf.cv[count]) {
             if (compare (name, conf.cv[count], length))
                  break;
           }
          else
             break;

   result = conf.cv[count] + length + 1;

   if (count == CFG_NUM || conf.cv[count] == NULL)
        result = "0";

   lock_exec (status);

   return (result);
 }


void  load_stx()

{
   DTA    *my_dta;
   char   *walk = sting_path, temp[32];
   int16  error, modules = FALSE;

   if (sting_path[0] != '\\') {
        walk += 2;
        Dsetdrv (sting_path[0] - 'A');
      }
   Dsetpath (walk);

   my_dta = Fgetdta();

   printf ("Loading Modules : ");

   error = Fsfirst ("*.STX", 0);

   while (error >= 0) {
        strcpy (temp, my_dta->d_fname);
        if (strchr (temp, '.'))   * strchr (temp, '.') = '\0';
        printf ("%s, ", temp);
        Pexec (0, my_dta->d_fname, "\012STinG_Load", "");
        modules = TRUE;
        error = Fsnext();
      }

   if (modules)
        printf ("\b\b.\r\n");
     else
        printf ("None.\r\n");
 }

/* <<< OMLINDEX.C 1.0 06.05.92 19:00 >>> */

/* Dieses Programm dient dazu, die "Index-Daten" einer Bibliotheksdatei im
   Lattice/HiSoft-Format so ausfÅhrlich wie mîglich aufzulisten. Der Aufruf 
   des Programms hat folgendes Format:

   OMLINDEX.TTP <library file> [<library file>] ...
   
   Die Ausgaben des Programms landen in der Standard-Ausgabe (Bildschirm) und 
   kînnen daher in eine Datei umgeleitet werden, soweit der richtige 
   Startup-Code beim Linken verwendet wurde und das TOS ausnahmsweise mal 
   mitspielt!

   (c) 1992 by MAXON Computer
           und Heiner Hîgel

   History:
      1.0  06.05.92  -  Ersterstellung!
*/

/*---------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <portab.h>

/* Diverse library-interne Kennungen: */
#define LIB_ID    0x000003FAL
#define LIB_INDEX 0x000003FBL
#define LI_CODE   0x03E9
#define LI_DATA   0x03EA
#define LI_BSS    0x03EB

/* Der main-Prototyp ist nur fÅr Lattice-C notwendig! */
int main (int argc, char *argv[]);

/* Prototypen modulinterner Funktionen: */
static int   show_lib_index (FILE *lib);
static int   read_error     (void);
static char *print_symbol   (char *symlist, UWORD sym_offset);
static char *hunk_type      (UWORD hunk_id, char *hunk_name);

/*===========================================================================*/
/* Globale Funktionen:                                                       */
/*===========================================================================*/

int main (int argc, char *argv[]) /*
----====--------------------------*/
   {
   FILE *lib;
   int   i,
         status;

   if (argc <= 1)
      {
      puts("Usage: OMLINDEX.TTP <library file> [<library file>] ...");
      return (EXIT_FAILURE);
      }
   for (i = 1; i < argc; i++)
      {
      if ((lib = fopen(argv[i], "rb")) == NULL)
         {
         status = EXIT_FAILURE;
         printf("*** Cannot open libray file %s! ***\n", argv[i]);
         continue;
         }
      printf("\nDumping library index of file %s:\n", argv[i]);
      puts("==============================================================");
      status = show_lib_index(lib);
      fclose(lib);
      }
   return (status);
   }

/*===========================================================================*/
/* Modulinterne Funktionen:                                                  */
/*===========================================================================*/

static int show_lib_index (FILE *lib) /*
-----------==============-------------*/
   {
   struct
      {
      ULONG index_id;
      ULONG index_len;
      UWORD symlist_len;
      }   index_header;

   char  *symlist,
         *buffer = NULL,
         *str;
   UWORD *module_index,
         *index_end,
          offset,
          sym_offset,
          n;
   ULONG  lib_header[2];
   long   index_start;
   size_t buflen;
   int    hunks,
          hunk_count,
          symbols,
          module_count;

   /* Read library header and check it */
   if (fread(lib_header, sizeof(ULONG) * 2, 1, lib) != 1)
      return (read_error());
   if (lib_header[0] != LIB_ID)
      {
      puts("*** This is not a HiSoft library file! ***");
      return (EXIT_FAILURE);
      }

   /* Read index header and check it */
   index_start = (long) (sizeof(ULONG) * (lib_header[1] + 2));
   if (fseek(lib, index_start, SEEK_SET) != 0)
      return (read_error());
   if (fread(&index_header, sizeof(index_header), 1, lib) != 1)
      return (read_error());
   if (index_header.index_id != LIB_INDEX)
      {
      puts("*** Syntax error in library file! ***");
      return (EXIT_FAILURE);
      }

   /* Allocate buffer and load index */
   buflen = index_header.index_len * sizeof(ULONG) - sizeof(UWORD);
   if ((buffer = malloc(buflen)) == NULL)
      {
      puts("*** Not enough memory to load library index! ***");
      return (EXIT_FAILURE);
      }
   if (fread(buffer, buflen, 1, lib) != 1)
      return (read_error());
   symlist = buffer;
   module_index = (UWORD *) (buffer + index_header.symlist_len);
   index_end = (UWORD *) (buffer + buflen - 8 * sizeof(UWORD));

   /* Walk through index as long as there is enough data left for
      at least one module
   */
   for (module_count = 0; module_index <= index_end; module_count++)
      {
      /* Dump header data for next module */
      printf("\nModule: ");
      print_symbol(symlist, *module_index++);
      offset = *module_index++ + (UWORD) sizeof(ULONG) * 2;
      hunks = (int) *module_index++;
      printf("   Library Offset: 0x%04X (%u), %d Hunk(s)\n",
             offset, offset, hunks);
      
      /* Walk through hunks of module */
      for (hunk_count = 0; hunk_count < hunks; hunk_count++)
         {
         /* Dump header data of hunk */
         printf("   Section %d \"", hunk_count);
         str = print_symbol(symlist, *module_index++);
         n = *module_index++ * (UWORD) sizeof(ULONG);
         printf("\" 0x%X (%u) Bytes, <%s>\n",
                n, n, hunk_type(*module_index++, str));
         
         /* Dump external references */
         if ((symbols = *module_index++) > 0)
            {
            printf("    %d external reference(s):\n", symbols);
            for (; symbols > 0; symbols--)
               {
               printf("     ");
               print_symbol(symlist, *module_index++);
               putchar('\n');
               }
            }
         
         /* Dump exported symbols */
         if ((symbols = *module_index++) > 0)
            {
            printf("    %d exported symbol(s):\n", symbols);
            for (; symbols > 0; symbols--)
               {
               sym_offset = *module_index++;
               offset = *module_index++;
               printf("     Section offset: 0x%04X, Extra: 0x%04X, Symbol: ",
                      offset, *module_index++);
               print_symbol(symlist, sym_offset);
               putchar('\n');
               }
            }
         }
      }

   printf("\n--------------------------------------------------------------------"
          "\n%d Modules in library file!\n", module_count);
   if (buffer != NULL)
      free(buffer);
   return (EXIT_SUCCESS);
   }

/*---------------------------------------------------------------------------*/

static int read_error (void) /*
-----------==========--------*/
   {
   puts("*** Read error on library file! ***");
   return (EXIT_FAILURE);
   }

/*---------------------------------------------------------------------------*/

static char *print_symbol (char *symlist, UWORD sym_offset) /*
-------------============-----------------------------------*/
   {
   int   special = FALSE;
   char *symbol;

   symbol = symlist + sym_offset;
   if (*symbol == '\0'  &&  sym_offset != 0)
      {
      special = TRUE;
      symbol++;
      }
   printf("%s", symbol);
   if (special == TRUE)
      printf(" (16 bit ref)");
   return (symbol);
   }

/*---------------------------------------------------------------------------*/

static char *hunk_type (UWORD hunk_id, char *hunk_name) /*
-------------=========----------------------------------*/
   {
   char *type;
   int   far_type = FALSE;

   if (strcmp(hunk_name, "__MERGED"))
      far_type = TRUE;
   switch (hunk_id)
      {
      case LI_CODE: type = "Code"; break;
      case LI_DATA: type = (far_type) ? "far DATA" : "near DATA"; break;
      case LI_BSS:  type = (far_type) ? "far BSS"  : "near BSS";  break;
      default:      type = "Unknown hunk type"; break;
      }
   return (type);
   }

/*===========================================================================*/


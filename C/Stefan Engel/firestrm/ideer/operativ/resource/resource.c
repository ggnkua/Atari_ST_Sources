#include "os.h"
#include "error.h"
#include "language.h"
#include "resource.h"

/*****************************************************************/
/* Global Variables for the resource control                     */
/*****************************************************************/
extern static PROGINFO *program;
/*****************************************************************/
/*****************************************************************/
long LoadResource(const char *FileName)
{
  long ResourceSize;

  /***************************************************************/
  /* Load the Graphical part of the Resource                     */
  /***************************************************************/
  Program->FileId=Open(FileName,READ);                             /* Opens the resource-file                                   */
  if(Program->FileId<0)                                            /* IF the resourcefile cannot be opened                      */
    return ERROR_NO_RESOURCE_FILE;                                 /* Return an error                                           */

  ResourceSize=FileSize(filename);                                 /* Get the size of the resourcefile                          */
  Program->Resource=(RHeader *)Alloc(ResourceSize+1);                 /* Allocate enough memory for the resource and the header    */
  if(Program->Resource==NULL)                                      /* If the needed memory could not be allocated               */
  {
    Close(Program->FileId);                                        /* close the resource-file                                   */
    return ERROR_NO_MEMORY_FOR_RESOURCE;                           /* and return an error                                       */
  }
  if(Read(FileId,Program->Resource,ResourceSize)!=ResourceSize)    /* Read the resourcefile contents into the allocated memory  */
  {                                                                /* If the file cannot be read, or less Data is read          */
    Close(Program->FileID);                                        /* Close the Resopurce file                                  */
    Free(Program->Resource);                                       /* Free the allocated memory                                 */
    return ERROR_READING_RESOURCE_FILE;                            /* Return an error                                           */
  }
  StringCopy(Program->ResourceName,FileName);                      /* Copy the resource-file-name to the program data buffert   */

  Close(Program->FileID);                                          /* Close the resource-file since it is not needed any more   */
  /***************************************************************/
  /* Load the Textual part of the resource                       */
  /***************************************************************/
  if(!LoadLanguage(0))                                             /* Load the default system language (what the user has set) */
  {                                                                /* If any language at all cannot be loaded                  */
    Free(Program->resource);                                       /* Free the allocated memory for the graphical part         */
    return ERROR_NO_LANGUAGE_FILE;                                 /* return an Error                                          */
  }

  /***************************************************************/
  /* Insert the Textual Part into the Graphical Part             */
  /***************************************************************/

  /***************************************************************/
  /* Fix objects and other parts that use pointers in memory     */
  /***************************************************************/

}

/*****************************************************************/
/* Unloads the resource-memory, and everything else with it :)   */
/*****************************************************************/
int UnloadResource(void)
{
}
/*****************************************************************/
/* Language File Extensions                                      */
/*****************************************************************/

/*****************************************************************/
/* Unload the current language, this should not be done by any   */
/* Application, only by the LoadLanguage Call, However this      */
/* function is provided for the applications also.               */
/*****************************************************************/
int UnloadLanguage()
{

}

/*****************************************************************/
/*****************************************************************/
int LoadLanguage(long Language)
{

  return language;
}

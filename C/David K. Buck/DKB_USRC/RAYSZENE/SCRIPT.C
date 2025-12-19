/*****************************************************************************
*                                                                            *
* SCRIPT GENERATOR, V1.22, 28.11.1990 Jari K„hk”nen                          *
*                                                                            *
* Creates new script-file from old script by replacing all REPLACE_MARK's    *
* with new file_name, which is same as picture/scene-name. If OUTPUT_NAME    *
* is longer than MAX_NAME_LENGTH+SCENE_NUMBER, name is replaced with name    *
* +scene_number. SCRIPT_LENGTH indentifies maximum length of old script file.*
*                                                                            *
*                                                                            *
* V1.0  6.11.90  First working version                                       *
* V1.1  17.11.90 DEF_NEW_SCRIPT_EXT added, few bugs repaired                 *
* V1.2  18.11.90 STDIN-input added                                           *
* V1.21 25.11.90 STDIN-script has DEF_SCRIPT_NAME                            *
* V1.22 28.11.90 Uses user-defined editor                                    *
*                                                                            *
* BUGS                                                                       *
*                                                                            *
*  Don't use filenames like "Simple1", end names with letters, not numbers   *
*                                                                            *
*                                                                            *
*****************************************************************************/


#include "rayscene.h"


create_script()
{

  char ch;
  char *system_call;

  system_call=(char *)malloc(40);
  memset(script,'\0',sizeof(script));                   /* Clear buffer */
  printf("ScriptGenerator invoked, cooking new script file...\n");


  if( !strlen (script_name) )
  {

   printf("Give name for script, no extension (Enter=default:%s.%s):",DEF_SCRIPT_NAME,DEF_SCRIPT_EXT);

   for( index3=0;  ( (ch = getc(stdin) ) != '\n' )
                 &&( (script_name[index3] = ch ) != EOF )
                 &&( index3 < MAX_NAME_LENGTH );
                 index3++ );

   if( ! strlen(script_name) )
    {
    printf("Using default name '%s'\n",DEF_SCRIPT_NAME);
    strcpy(script_name,DEF_SCRIPT_NAME);
    }

   if( data_size == 1)
       {                                           /* Script length */
        printf("\nEmpty script-file...Terminating...\n");
	exit(1);
       }

    /* New name for script */

   sprintf(file_name,"%s.%s",script_name,DEF_SCRIPT_EXT);

   strcpy(system_call,EDITOR_NAME);
   strcat(system_call," ");
   strcat(system_call,file_name);
   system(system_call);
   }

   sprintf(file_name,"%s.%s",script_name,DEF_SCRIPT_EXT);

    if( (stream = fopen(file_name,"r") ) == NULL)
     {
      printf("Cannot open old script file.\nTerminating...\n");
      fclose(stream);
      exit(-3);
     }

     for( index3=0; !feof(stream); index3++)          /* Read stuff */
       script[index3]=fgetc(stream);

      if((data_size=index3)<=0)
	{                                           /* Script length */
	 printf("Empty script-file...Terminating...\n");
	 fclose(stream);
	 exit(1);
	}

      fclose(stream);

   sprintf(file_name,"%s.%s",script_name,DEF_NEW_SCRIPT_EXT);


					     /* Create new script name */

   printf("Creating new script %s\n",file_name);

   if( (stream = fopen(file_name,"w+") ) == NULL)
    {
     printf("Cannot open file for new script.\nTerminating...\n");
     fclose(stream);
     exit(-3);
    }

    /* After succesful reading, replace all REPLACE_MARK's from script
    file. First reset SCENE_NUMBER */

    strcpy(scene_number,"0");

   for( index2 = 0; index2 < count; index2++ )
    {

     index3 = 0;

     /* Increase file_name */

     sprintf(scene_number,"%d",atoi(scene_number)+1);
     memset(file_name,'\0',sizeof(file_name));

     while( index3 < data_size-1 )
     {

     if( script[index3] != REPLACE_MARK )

        fputc(script[index3],stream);

      else

       {

        /* OK, lets get new filename */

        memset(file_name,'\0',sizeof(file_name));
        strncpy(file_name,output_name,(MAX_NAME_LENGTH-strlen(scene_number)));

   if((add_null == 2) && ( atoi(scene_number ) <10 )) /* Name01.dat */
    strncat(file_name,"0", 1);

	strcat(file_name,scene_number);

        /* Replace REPLACE_MARK with filename */

        fputs(file_name,stream);

       }
      index3++;
     }
    }
  fclose(stream);
  if( strlen(file_name) == 0)
     printf("Warning, no REPLACE MARKs found from script file!!\n");

  return(0);
}

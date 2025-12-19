/*****************************************************************************
*                                                                            *
* RAY-TRACER SCENE GENERATOR, V1.31, 17.12.1990                              *
*                                                                            *
* Creates datafiles for raytracers.                                          *
*                                                                            *
* HISTORY                                                                    *
*                                                                            *
* V1.0 16.11.90  First working version                                       *
* V1.1 19.11.90  Option -I added                                             *
* V1.2 25.11.90  Accepts multiple variables with same name                   *
* V1.3 28.11.90  /N-option added, ScriptGenerator uses user-defined editor   *
* V1.31 10.12.90 /U-option added. Sin-program added to package               *
* V1.32 BETA     Calculations possible                                       *
* V1.33 30.12.90 /R-option added                                             *
* BUGS                                                                       *
*                                                                            *
*  Don't use output filenames like "Simple1", end names with letters,        *
*  NOT NUMBERS!!                                                             *
*                                                                            *
*                                                                            *
*****************************************************************************/



#include "rayscene.h"

int readval(void);
int create_script(void);

main(argc,argv)
int argc;
char *argv[];
 {

    char *pth_tmp;
    int pth2=0;
    int check=0;
    float old_value=0, calc_value=0;
    char calc_buffer[12];
    int calc=0;
    int scene_end=0, scene_start=0;

    script_gen=0;
    comment=0;

 if( argc < 2 ) /* Checking arguments */
  {

   printf("\n                 Ray Tracing Scene Generator, v1.33 1991\n\n");

   printf("Usage: Rayscene (+-/) /Uname /Aname /Dname /Ccount /Oname [/Sname /I /N]\n");
   printf("    /Aname  = Filename for Array file, without extension\n");
   printf("    /Dname  = Filename for Data file, without extension\n");
   printf("    /Ccount = Required scene count\n");
   printf("    /Uname  = Use same name for input-,output- and datafile\n");
   printf("    /Oname  = Filename for output file, without extension\n");
   printf("    /Sname  = Old script file, for ScriptGenerator. No name=use editor\n");
   printf("    /NA     = Output-name:name01.dat\n");
   printf("    /NN     = Output-name:name1.dat\n");
   printf("    /Rx,x1  = Create only scenes x-x1 ('1' is the first)\n");
   printf("    /I{}    = Do not replace inside comments,{=start letter,}=end letter\n");
   printf("              You can also define raytracer, for example /IDKB,/IVORT,/IQRT\n\n");
   printf("    Current defaults:\n");
   printf("      -Datafile extension  :%s\n",DEF_DATA_EXT);
   printf("      -Arrayfile name      :%s   Extension:%s\n",DEF_ARRAY_NAME,DEF_ARR_EXT);
   printf("      -User defined editor :%s\n",EDITOR_NAME);
   printf("      -Script name         :%s   Extension:%s   New Ext:%s\n",DEF_SCRIPT_NAME,DEF_SCRIPT_EXT,DEF_NEW_SCRIPT_EXT);
   printf("    Rayscene -a -dtest -s -c10\n");
   printf("    -Use %s.%s, test.%s and %s.%s. Use %s-editor to create %s.%s\n",
           DEF_ARRAY_NAME,DEF_ARR_EXT,DEF_DATA_EXT,DEF_SCRIPT_NAME,DEF_SCRIPT_EXT,EDITOR_NAME,DEF_SCRIPT_NAME,DEF_NEW_SCRIPT_EXT);
   getch();
   exit(10);

  }
   printf("\n                 Ray Tracing Scene Generator, v1.33 Beta 1990\n\n");


 for( index = 1; index < argc; index++ )   /* Loop for examining arguments */
 {

  pth2=FALSE;

  if( ( argv[index][1] == 'U' ) || ( argv[index][1] == 'u' ) )   /* /Use= */
   {
    pth2=TRUE;    
    printf("Using name '%s' for all files (except for script)\n",argv[index]+2);
    sprintf(dat_name,"%s.%s",argv[index]+2,DEF_DATA_EXT);

    strcpy(output_name,argv[index]+2);
    data=index;                         /* Now there is output name */

    sprintf(arr_name,"%s.%s",argv[index]+2,DEF_ARR_EXT); /* data-file */

   }                                        /* END OF /Use */


  if( ( argv[index][1] == 'D' ) || ( argv[index][1] == 'd' ) )   /* /FILE= */
   {
    pth2=TRUE;
    sprintf(dat_name,"%s",argv[index]+2);

    if ( isdigit(dat_name[strlen(dat_name)-1]))
     printf("WARNING:Last character of datafile-name is number..!!\n");

    sprintf(dat_name,"%s.%s",argv[index]+2,DEF_DATA_EXT);
    printf("Data-name:%s\n",dat_name);

      if( data == 0)  /*  There's no Output name  */
        {

        strcpy(output_name,argv[index]+2);
        data=index;                         /* Now there is output name */

        }
   }                                        /* END OF /FILE= */


  if( ( argv[index][1] == 'A' ) || ( argv[index][1] == 'a' ) )   /* /ARRAY= */
   {
   pth2=TRUE;
   if( strlen (argv[index]) > 2)
       {
        sprintf(arr_name,"%s.%s",argv[index]+2,DEF_ARR_EXT);
        printf("Arrayfile:%s\n",arr_name);
       }
   }                                        /* END OF /ARRAY= */


  if( ( argv[index][1] == 'C' ) || ( argv[index][1] == 'c' ) )   /* /COUNT= */
    {
    pth2=TRUE;
    count=atoi(argv[index]+2);
    if ( count == 0)
     {
     printf("Number of scenes cannot be 0 ! Terminating...\n");
     getch();
     exit(1);
     }
    printf("Number of scenes requested:%d\n",count);

    if( scene_end ) /* If /r option was given */
     printf(" WARNING:This option overrides /R-option...!\n");

    }

  if( ( argv[index][1] == 'O' ) || ( argv[index][1] == 'o' ) )   /* /OUTPUT= */
    {
    pth2=TRUE;
    sprintf(output_name,"%s",argv[index]+2);
    printf("Output-name:%s\n",output_name);
    data=index;                             /* This replaces default name
                                              which is .dat-name */
    }

  if( ( argv[index][1] == 'S' ) || ( argv[index][1] == 's' ) )   /* /SCRIPT= */
    {
    pth2=TRUE;
    sprintf(script_name,"%s",argv[index]+2);

    if( strlen(argv[index]) > 2 )
       printf("Script-name:%s.%s\n",script_name,DEF_SCRIPT_EXT);
     else
       printf("No script-name, using editor...\n");

    script_gen=1;

    }

  if( ( argv[index][1] == 'I' ) || ( argv[index][1] == 'i' ) )   /* /I */
    {
    comment=1;
    pth2=TRUE;
    /*
     * Check for DKB/QRT/VORT/MTV/DBW
     *
     */

    if( !(strnicmp(argv[index]+2,"DKB",3))
         || !(strnicmp(argv[index]+2,"QRT",3)) )
      {
       strcpy(comment_start,DKB_COMMENT_START);
       strcpy(comment_end,DKB_COMMENT_END);
       printf("Using DKB comment marks...\n");
       }
    else

    if( !(strnicmp(argv[index]+2,"VOR",3)))
      {
       strcpy(comment_start,VORT_COMMENT_START);
       strcpy(comment_end,VORT_COMMENT_END);
       printf("Using VORT comment marks...\n");
      }
    else
     {
     strcpy(string,argv[index]+2);

     if( strlen(string) )                            /* New characters */
      {
       strncpy(comment_start,string,strlen(string)/2);
       strncpy(comment_end,string+strlen(string)/2,strlen(string)/2);
      }
     else
      {                                               /* No new characters */
      strcpy(comment_start,DEF_COMMENT_START);
      strcpy(comment_end,DEF_COMMENT_END);
      printf("Using default comment marks...\n");
      }

     }

    }

  if( ( argv[index][1] == 'N' ) || ( argv[index][1] == 'n' ) ) /* Name */
    {
     pth2=TRUE;
     if((argv[index][2] == 'a') || ( argv[index][2] == 'A' ))
       add_null = 2;
      else
       add_null = 1;
    
    }

  if( ( argv[index][1] == 'R' ) || ( argv[index][1] == 'r' ) )   /* /OUTPUT= */
    {
    pth2=TRUE;
    sscanf(argv[index]+2,"%d,%d",&scene_start,&scene_end);

    if( (scene_start < 0) || (scene_end < 0) || (scene_start > scene_end ))
     {
     printf("Strange range-values %d,%d...ignoring %c%c-option...\n",
	scene_start,scene_end,argv[index][0],argv[index][1]);
     continue;
     }
    printf("Creating %d scenes (%d-%d) \n",
      (1+(count=scene_end-scene_start)),scene_start,scene_end);
    }

  
   if( pth2 == FALSE )
      printf("Unknown option %s...\n",argv[index]);
   /* BTW, give /Ox-option to MSC, and the line above's gonna cost you one
      call to Microsoft Technical support...:) JK */
      
   }                                                 /* END OF FOR */
   memset(string,'\0',sizeof(string));
   pth2=0;
                                                    /* No name for data-file */
    if( strlen(dat_name) != 0 )
     {

        strcpy(file_name,dat_name);
        if( ( stream=fopen(file_name,"r") ) == NULL)         /* Open data-file */
        {
            printf("Cannot open data-file (%s).\nTerminating...\n",file_name);  /* Error occurred */
            fclose(stream);
            getch();
            exit(10);

        }

      fseek(stream,0L,SEEK_END);                     /* Find last position */
      data_size=(int)ftell(stream);
      buffer= (char *) malloc(data_size+512);
      fseek(stream,0L,SEEK_SET);                     /* Back to start */

      for( index=0; !feof(stream); index++)          /* Read stuff */
       buffer[index]=fgetc(stream);

       data_size=index;                             /* Real length */

      fclose(stream);                               /* Close data-file */
     }                                              /* END_OF_READ_data */


     if( strlen(arr_name) == 0 )                         /* No ARR-name */
      {

       strcat(arr_name,DEF_ARRAY_NAME);
       strcat(arr_name,".");
       strcat(arr_name,DEF_ARR_EXT);
       printf("Using default array-name:%s\n",arr_name);

      }


     /*
      * Now the fun begins, first, quick scan through buffer to examine how
      * many REPLACE_MARKs there are. Number of variables is then how_many/2
      *
      */

     index = 0;
     index2= 0;

     for( index = 0; index < data_size; index ++)
      {

        if( buffer[index] == comment_start[0] && (comment) )
        {
         if( strlen(comment_start) == 2 && buffer[index+1] != comment_start[1])
          break;
         while( buffer[index] != EOF )
          {
          if (buffer[index] == comment_end[0])
           if ( (strlen( comment_end ) ==2)
             && ( buffer[index+1] == comment_end[1] )
             || ( strlen ( comment_end) == 1))
               {
               index+=(int)strlen(comment_end);
               break;
               }
          index++;
          if ( buffer[index] == EOF )
          {
          printf("Unexpected end of file! Cannot found comment_end mark. Terminating...\n");
          getch();
          exit(5);
          }

          }
        }


      else
      if( buffer[index] == REPLACE_MARK) index2++;  /* AHA, found one */
      }                                              /* END_OF_FOR */


     if( index2 <= 1)
      {
       printf("No variables or one REPLACE MARK found from data-file...Terminating...\n");
       getch();
       exit(0);
      }

     printf("%d Variables found from data-file after quick scan...\n",index2/2);
     var_count = index2/2;

     /* If R-option is enabled, put scene_end to count */
     if(scene_end)count=scene_end;

				    /* Space for var. names */
     names = (char *) malloc(var_count * MAX_VAR_LENGTH); 
     memset( names, '\0', var_count * MAX_VAR_LENGTH);
     values = (float *)malloc(var_count * count * sizeof(float));


     /*
      * Start from the beginning of buffer. If found REPLACE_MARK, get current
      * variable name, and move to next REPLACE_MARK
      *
      */

      for( index = 0;index < data_size; index++)
      {
        if( buffer[index] == comment_start[0] && ( comment ))
        {
         if( strlen(comment_start) == 2 && buffer[index+1] != comment_start[1])
          break;
         while( buffer[index] != EOF )
          {
          if (buffer[index] == comment_end[0])
           if ( (strlen( comment_end ) ==2)
             && ( buffer[index+1] == comment_end[1] )
             || ( strlen ( comment_end) == 1))
               {
               index+=(int)strlen(comment_end);
               break;
               }
          index++;

          }
        }
      else
      if( buffer[index] == REPLACE_MARK)
       if( buffer[index+1] == REPLACE_MARK)
       {
       printf("Variables must have name! Terminating...\n");
       getch();
       exit(8);
       }
       else
       {

       /* Check, if name is already been used. If it is, continue with next
         variable */

        for ( index2 = 1; index2 < (MAX_VAR_LENGTH); index2++)
         if( buffer[index2+index] == REPLACE_MARK)break;


        /*
         * now we have a length of current variable, compare it to names
         */

         for( index3 = 0; index3 < var_count; index3++ )
          if(!( strnicmp(names+(index3*MAX_VAR_LENGTH),buffer+index+1,index2-1)))
            {
            var_count--;
            check=1;
            break;
            }

         if(check)
          {
           check=0;
           index+=index2;
           continue;
          }
         else
         {
          pth_tmp = names + pth2 * (MAX_VAR_LENGTH);
          for ( index2 = 1; index2 < (MAX_VAR_LENGTH); index2++)
          {
                  if( buffer[index2+index] == REPLACE_MARK)
                   break;
                    else
                  *(pth_tmp++) = buffer[index2+index];

          }
          pth2++;

         /* Then move buffer, until var_name ends */

         index++;

         while( buffer[index] != REPLACE_MARK ) index++;
        }
       }
      check=0;
     }


  /*
   * READ VALUES FROM DISK
   *
   */

    printf("%d real variables found from data-file (duplicates not included)\n",
      var_count);
    readval();
    fclose(stream);

  /*
   * First, if current FILE_NAME is too long (there is no space after name
   * for two/three numbers...), remove last two characters.
   *
   */
  if( !scene_start )
   strncpy(scene_number,"1",1);   /* First file number */
  else
   sprintf(scene_number,"%d",scene_start);
 
  memset(file_name,'\0',sizeof(file_name));

  if( scene_end ) count --;

  for(; atoi(scene_number)-scene_start<(count+1+(scene_end-scene_start))+scene_start; 
        sprintf(scene_number,"%d", atoi(scene_number)+1))
   {

   if(scene_end)
    {
    count=scene_end;
    if( atoi(scene_number) > scene_end) break;
    }

   memset(file_name,'\0',sizeof(file_name));
   strncpy(file_name,argv[data]+2,(MAX_NAME_LENGTH-strlen(scene_number)));

   if((add_null == 2) && ( atoi(scene_number ) <10 )) /* Name01.dat */
    strncat(file_name,"0", 1);
 
   strncat(file_name,scene_number,strlen(scene_number));
   strncat(file_name,".",1);
   strncat(file_name,DEF_DATA_EXT,EXT_LENGTH);

   if( ( stream=fopen(file_name,"w+") ) == NULL)         /* Open data-file */
     {
     printf("Cannot open scene-file.\nTerminating...\n");  /* Error occurred */
     fclose(stream);
     getch();
     exit(10);
     }


   /*
    * Then, replace all variables with right values
    */

     for( index = 0;index < data_size-1; index++)
     {
        if( buffer[index] == comment_start[0] && (comment) )
        {
         if( strlen(comment_start) == 2 && buffer[index+1] != comment_start[1])
          break;
         while( buffer[index] != EOF )
          {
          if (buffer[index] == comment_end[0])
           if ( (strlen( comment_end ) ==2)
             && ( buffer[index+1] == comment_end[1] )
             || ( strlen ( comment_end) == 1))
               {
               fputc(buffer[index],stream);

               if( strlen(comment_end) == 2)
                fputc(buffer[++index],stream);

               index+=(int)strlen(comment_end);
               break;
               }
          fputc(buffer[index],stream);
          index++;
          }
        }

      if( buffer[index] == REPLACE_MARK)
       {

        for ( index2 = 1; index2 < (MAX_VAR_LENGTH); index2++)
         {
         if( buffer[index2+index] == REPLACE_MARK)break;
         }

        /*
         * now we have a length of current variable, compare it to names
         */

         memset(string,'\0', sizeof(string));

         for( index3 = 0; index3 < var_count; index3++ )
          if(!( strnicmp(names+(index3*MAX_VAR_LENGTH),buffer+index+1,index2-1)))
            break;

        /*
         * Now we know current variable, so replace current value to buffer
         */

        
        /* Test if calculations */
	if( (buffer[index2+index+1] == '+')||(buffer[index2+index+1] == '-')
	  ||(buffer[index2+index+1] == '*')||(buffer[index2+index+1] == '/'))
         {
	 strncpy(calc_buffer,buffer+index2+index+2,10);
         old_value=values[atoi(scene_number)+(index3 * count)-1];
         sscanf(calc_buffer,"%f ",&calc_value);
	 switch (buffer[index2+index+1])
            {
		case '+': old_value+=calc_value;
           	          break;
		case '-': old_value-=calc_value;
           	          break;
		case '/': old_value=old_value/calc_value;
           	          break;
		case '*': old_value=old_value*calc_value;
           	          break;
           	          
           	default: break;
            }
	sprintf(string,"%.3f",old_value);
	while( buffer[index] != ' ' ) index++;
	index--;
	calc=1;
	}
        else
	sprintf(string,"%.3f",values[atoi(scene_number)+(index3 * count)-1]);
	strcat( string , " " );

        fputs(string,stream);
        
        index++;   /* Move forward */

	if(calc==1)
	 calc=0;
	else
	 while( buffer[index] != REPLACE_MARK ) index++;

       }                                         /* END_OF_REPLACE_MARK */
       else
       fputc(buffer[index],stream);
     }                                              /* END_OF_BUFFER_SEARCH */

     fclose(stream);
  }                                               /* END_OF_SCENE_LOOP */



   /*
    * Release all buffers
    */

   free(buffer);
   free(array);
   free(modified);

   if(script_gen)create_script();                 /* Start scriptgenerator */
   return(0);

}

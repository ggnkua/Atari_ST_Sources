int read_tiny_file( char *pathname, char *char_ptr, int *colours )
/*=======================================================================*/
/*                                                                       */
/*  Reads the contents of the TINY format file given in pathname into    */
/*  memory begining at the byte pointed to by char_ptr. The appropriate  */
/*  colour palette is not set up, instead it is passed back in the       */
/*  array colours so that Setpallete [ xbios(6) ] can be used later.     */
/*  This means that the picture can be loaded into a background display  */
/*  display screen without altering the colours of the currently shown   */
/*  picture.                                                             */
/*                                                                       */
/*  The function returns the following values :-                         */
/*                                                                       */
/*          0 - File loaded sucessfully                                  */
/*          1 - Couldn't open the file                                   */
/*          2 - TINY file is not for the current resolution              */
/*          3 - Couldn't grab enough memory to read file contents        */
/*          4 - File isn't a TINY file                                   */
/*                                                                       */
/*                                                                       */
/*  This function uses the following external functions :-               */
/*                                                                       */
/*          fopen             - stdio.h                                  */
/*          fread             - stdio.h                                  */
/*          fclose            - stdio.h                                  */
/*          Getres [xbios(4)] - osbind.h                                 */
/*          malloc            - stdlib.h                                 */
/*          free              - stdlib.h                                 */
/*          memcpy            - string.h                                 */
/*                                                                       */
/*  (Compiles with Lattice C, other systems may have different           */
/*  include file names.)                                                 */
/*-----------------------------------------------------------------------*/
/*  Written by Geoff Smith for the Seaton Shareware Cooperative          */
/*=======================================================================*/
{
   int count, offset, data_count, end;
   int size[2];
   char res, data_type;
   FILE *t_file;
   char *control_start, *control_ptr, *end_of_control;
   int *data_start, *data_ptr, *mem_loc;
   
   /* open file */
   if ( (t_file = fopen( pathname, "rb" )) == NULL ) return 1;

   /* find out what resolution the file is for */
   fread( &res, sizeof(char), 1, t_file);
   /* check if a valid resolution code */
   if ( res < 0 || res > 5 ) return 4;
   /* check if resolution is the same as the current resolution */
   if ( res%3 != Getrez() ) return 2;     

   /* if there is animation information ignore it */
   if (res > 2) fread( size, sizeof(int), 2, t_file);

   /* read the colour palette */
   fread( colours, sizeof(int), 16, t_file);
   /* check the colour palette */
   for (count=0; count<16; count++) if (colours[count]<0 || colours[count]>0x777) return 4;
   
      
   /* get size of control and data sections */
   fread( size, sizeof(int), 2, t_file);
      
   /* grab some memory to read the data into */
   control_start = (char *)malloc(size[0]);
   if (!control_start) return 3;
   data_start = (int *)malloc(sizeof(int)*size[1]);
   if (!data_start) return 3;
      
   /* read data into memory and then we can close the file */
   fread( control_start, sizeof(char), size[0], t_file);
   fread( data_start, sizeof(int), size[1], t_file);
   fclose( t_file );

   /* convert the byte pointer supplied to a word pointer & set pointers */
   mem_loc = (int *)char_ptr;
   control_ptr = control_start;
   data_ptr = data_start;
      
   /* initialise count of number of words written to memory */
   count = 0;
   
   /* calculate end of control data */
   end_of_control = control_start + size[0];
      
   /* read through each control byte */
   while (control_ptr < end_of_control)
   {
       /* check if copying data or repeating data */
       if ( *control_ptr < 0 || *control_ptr == 1 )
          data_type = 'c';
       else
          data_type = 'r';
          
       /* get number of words to copy or repeat */
       if ( *control_ptr < 0 || *control_ptr > 1 )
       {
          data_count = abs( *control_ptr );
          control_ptr++;
       }
       else
       {
          /* copy two bytes to form an integer */
          memcpy( &data_count, control_ptr+1, 2 );
          control_ptr += 3;
       }

      end = count + data_count;
      for ( ; count<end; count++)
      {
         /* work out where to write data using magic formula */
         offset = ((count%4000)/200)*4 + (count/4000) + (80*(count%200));

         /* set memory location to appropriate value */
         *(mem_loc + offset) = *data_ptr;
         
         /* if data is being copied advance data pointer after each integer */
         if (data_type == 'c') data_ptr++;
      }
      /* if data was repeated advance data pointer once finished */
      if (data_type == 'r') data_ptr++;

   }
   
   /* free up memory used */
   free( data_start );
   free( control_start );

   return 0;

}

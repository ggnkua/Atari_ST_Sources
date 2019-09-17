/*************************************************/
/* File     : IMG_LOAD.C                         */
/* Author   : Lee Russell                        */
/* Written  : 26th April 1994                    */
/* Revision : 1st Issue                          */
/* Compiler : Lattice C v5.5 - HiSoft            */
/* Purpose  : Functions To Read .IMG Format File */
/*************************************************/

/* These functions have been "lifted" from a program which I am still developing,  */
/* hence they make reference to other code which I have not included. However, all */
/* the code necessary to load an IMG file is included. Upon exit, variable         */
/* img_data points to the image which is described by the structure img_header.    */

/* Functions Prototypes */

void load(void);
int open_file(void);
int scan_run(void);
int pattern_run(void);
int literal_read(void);
int solid_run_set(void);
int solid_run_clear(void);
void read_error(void);

/* Global Variables */

struct i_header
       {
       unsigned short version;
       unsigned short header_length;
       unsigned short planes;
       unsigned short pattern_length;
       unsigned short pixel_width;
       unsigned short pixel_height;
       unsigned short line_width;
       unsigned shoer number_lines;
       } img_header;
       
FILE *img_file;
char fname[FNSIZE], path[FMSIZE], filename[FNSIZE+FMSIZE];
unsigned char *img_data, *img_pointer;
unsigned char *pattern_buffer, *pattern_pointer;
unsigned char *scan_buffer, *scan_pointer;
unsigned short bytes_per_line;
unsigned long length;
unsigned short dummy_word, cntr, cntr1;
unsigned char byte_in, temp_byte_in, patt_repeat;
unsigned long byte_count;
int result;
     
/* Functions To Read .IMG File */

void load(void)
     {
     /* Load In An .IMG Format File */
     
     short x_coord, y_coord;
     char mess_text[50];
     div_t line_length;

     result = open_file();
     if (result == -1) return;
     
     win_handle = open_window(GENL, NAME|CLOSE);
     if (win_handle == -1)
        {
        error_bell();
        form_alert(1,"[3][Can't open new window][STOP]");
        men_title_change(f_opt, 1); /* Return File Option To Normal Video */
        return;
        }
        
     /* Read In .IMG File Header Block */
     
     img_header.version = fgetw(img_file);
     img_header.header_length = fgetw(img_file);
     img_header.planes = fgetw(img_file);
     img_header.pattern_length = fgetw(img_file);
     img_header.pixel_width = fgetw(img_file);
     img_header.pixel_height = fgetw(img_file);
     img_header.line_width = fgetw(img_file);
     img_header.number_lines = fgetw(img_file);      
     if (img_header.header_length >8)
        {
        form_alert(1,"[3][Skipping Header Bytes][OK]");
        cntr1 = img_header.header_length-8;
        for (cntr = 0; cntr < cntr1; cntr ++) dummy_word = fgetw(img_file);
        }
               
     /* Define Storage Requirements */
    
     /* Define buffer for Pattern Run */
     pattern_buffer = malloc(img_header.pattern_length);
     if (pattern_buffer == NULL)
        {
        error_bell();
        form_alert(1,"[3][File Load.|No Room For Pattern|Buffer.][OK]");
        fclose(img_file);
        close_window(win_handle, GENL);
        return;
        }
     pattern_pointer = pattern_buffer;
               
     /* Define buffer for scan line run */
     line_length = div(img_header.line_width, 8);
     if (line_length.rem != 0)
        {      
        bytes_per_line = (img_header.line_width+(8-line_length.rem))/8;
        }
     else
        {
        bytes_per_line = img_header.line_width / 8;
        }
     scan_buffer = malloc(bytes_per_line);
     if (scan_buffer == NULL)
        {
        error_bell();
        form_alert(1,"[3][File Load.|No Memory For Line Buffer][OK]");
        fclose(img_file);
        free(pattern_buffer);
        close_window(win_handle, GENL);
        return;
        }
     scan_pointer = scan_buffer;                   

     /* Define area for image data */
     length = bytes_per_line * img_header.number_lines;
     img_data = malloc(length);
     if (img_data == NULL)
        {
        error_bell();
        form_alert(1,"[3][File Load.|No Memory For Picture][OK]");
        fclose(img_file);
        free(pattern_buffer);
        free(scan_buffer);
        close_window(win_handle, GENL);
        return;
        }
     img_pointer = img_data;          

     /* Prepare the status display in window GENL */
     dummy_word = work_out[47] * 1.5;
     wind_update(BEG_UPDATE);
     x_coord = xwork[GENL];
     y_coord = ywork[GENL];
     mess_text[0] = '\0';
     strcat(mess_text, "Loading File : ");
     strcat(mess_text, filename);
     v_gtext(virt_handle, x_coord, y_coord, mess_text);
     y_coord = y_coord + dummy_word;
     cvtitos(img_header.line_width);
     mess_text[0] = '\0';
     strcat(mess_text, "This image is ");
     strcat(mess_text, outstr);
     cvtitos(img_header.number_lines);
     strcat(mess_text, " pixels by ");
     strcat(mess_text, outstr);
     strcat(mess_text, " lines.");
     y_coord = y_coord + dummy_word;
     v_gtext(virt_handle, x_coord, y_coord, mess_text);
     cvtltos(length);
     mess_text[0] = '\0';
     strcat(mess_text, "The image is ");
     strcat(mess_text, outstr);
     strcat(mess_text, " bytes long.");
     y_coord = y_coord + dummy_word;
     v_gtext(virt_handle, x_coord, y_coord, mess_text);
     mess_text[0] = '\0';
     y_coord = y_coord + dummy_word;
 
     /* Now Read In The Image Data */
     byte_count = 0;	

     while(! feof(img_file))
          {
          mess_text[0] = '\0';
          strcat(mess_text, "Bytes Processed : ");
          cvtltos(byte_count);
          strcat(mess_text, outstr);
          v_gtext(virt_handle, x_coord, y_coord, mess_text);

          if (! feof(img_file)) byte_in = fgetc(img_file); else
                                                              {
                                                              read_error();
                                                              return;
                                                              }
          if (byte_in == 0)
             {
             if (! feof(img_file)) patt_repeat = fgetc(img_file); else
                                                                     {
                                                                     read_error();
                                                                     return;
                                                                     }
             if (patt_repeat == 0) result = scan_run(); else result = pattern_run();
             if (result == -1)
                {
                error_bell();
                form_alert(1,"[3][File Load.|Read Error|Scan/Patt][STOP]");
                fclose(img_file);
                free(pattern_buffer);
                free(scan_buffer);
                free(img_data);
                close_window(win_handle, GENL);
                return;
                }
             byte_in = 0;
             }

          if (byte_in == 128)
             {
             result = literal_read();
             if (result == -1)
                {
                error_bell();
                form_alert(1,"[3][File Load.|Error|Literal Data][STOP]");
                fclose(img_file);
                free(pattern_buffer);
                free(scan_buffer);
                free(img_data);
                close_window(win_handle, GENL);
                return;
                }
             byte_in = 128;
             }
            
          if (byte_in != 0 && byte_in != 128)
             {
             temp_byte_in = byte_in & 128;
             if (temp_byte_in == 128) result = solid_run_set(); else result = solid_run_clear();
             if (result == -1)
                {
                error_bell();
                form_alert(1,"[3][File Load.|Solid Run Error][STOP]");
                fclose(img_file);
                free(pattern_buffer);
                free(scan_buffer);
                free(img_data);
                close_window(win_handle, GENL);
                return;
                }
             }
          }
         
     fclose(img_file);
     free(pattern_buffer);
     free(scan_buffer);
     mess_text[0] = '\0';
     y_coord = y_coord + dummy_word;
     y_coord = y_coord + dummy_word;
     strcat(mess_text, "FILE LOADED.");
     v_gtext(virt_handle, x_coord, y_coord, mess_text);
     wind_update(END_UPDATE);
     return;
     }
   
int open_file(void)
    {
    /* Open An .IMG File */
    
    short button, pathlen;

    fname[0] = '\0';
    path[0] = '\0';
    filename[0] = '\0';
    
    result = form_dial(FMD_START, 0, 0, 0, 0, xdesk, ydesk, wdesk, hdesk);
    if (result == 0)
       {
       error_bell();
       form_alert(1,"[3][Open File.|Can't reserve area for|file selector][STOP]");
       men_title_change(f_opt, 1);
       return -1;
       }
       
    *fname = 0;
    getcd(0, path); /* Get current drive & path */
    strcat(path, "\\*.IMG");

    result = fsel_exinput(path, fname, &button, "Load An .IMG File");
    if (result == 0)
       {
       error_bell();
       form_alert(1,"[3][Open File.|Can't select file][STOP]");
       men_title_change(f_opt, 1);
       return -1;
       }
    if (button == 0)
       {
       men_title_change(f_opt, 1);
       return -1;
       }
       
    pathlen = strlen(path);
    for (cntr = 0; cntr < pathlen; cntr++) if (path[cntr] == '*') break;
    strncpy(filename, path, cntr);
    strcat(filename, fname);
    img_file = fopen(filename, "rb");
    if (img_file == NULL)
       {
       error_bell();
       form_alert(1,"[3][Open File.|Can't Open IMG File][STOP]");
       men_title_change(f_opt, 1);
       return -1;
       }
       
    return 0;
    }
    
int scan_run(void)
    {
    /* Read In Data - Scan Run Compression */
    
    unsigned char scan_run;
    unsigned short scan_length;
    
    if (! feof(img_file)) byte_in = fgetc(img_file); else
                                                        {
                                                        read_error();
                                                        return -1;
                                                        }
    if (byte_in != 0xFF)
       {
       error_bell();
       form_alert(1,"[3][File Format Error|Scanline Flag Expected][STOP]");
       return -1;
       }
       
    if (! feof(img_file)) scan_run = fgetc(img_file); else
                                                         {
                                                         read_error();
                                                         return -1;
                                                         }
    scan_length = 0;
    
    while (scan_length < bytes_per_line)
          {
          if (! feof(img_file)) byte_in = fgetc(img_file); else
                                                              {
                                                              read_error();
                                                              return -1;
                                                              }
          if (byte_in == 0)
             {
             if (! feof(img_file)) byte_in = fgetc(img_file); else
                                                                 {
                                                                 read_error();
                                                                 return -1;
                                                                 }
             if (byte_in == 0)
                {
                error_bell();
                form_alert(1,"[3][Scan Run|Logic Error][STOP]");
                return -1;
                }
             else
                {
                for (cntr = 0; cntr < img_header.pattern_length; cntr++)
                    {
                    if (! feof(img_file)) *pattern_pointer = fgetc(img_file); else
                                                                                 {
                                                                                 read_error();
                                                                                 return -1;
                                                                                 }
                    pattern_pointer++;
                    }
                pattern_pointer = pattern_buffer;
                for (cntr = 0; cntr < byte_in; cntr++)
                    { 
                    for (cntr1 = 0; cntr1 < img_header.pattern_length; cntr1++)
                        {
                        *scan_pointer = *pattern_pointer;
                        scan_pointer++;
                        pattern_pointer++;
                        scan_length++;
                        }
                    pattern_pointer = pattern_buffer;
                    }
                byte_in = 0;
                }
             }      
             
          if (byte_in == 128)
             {
             if (! feof(img_file)) byte_in = fgetc(img_file); else
                                                                {
                                                                read_error();
                                                                return -1;
                                                                }
             for (cntr = 0; cntr < byte_in; cntr++)
                 {
                 if (! feof(img_file)) *scan_pointer = fgetc(img_file); else
                                                                           {
                                                                           read_error();
                                                                           return -1;
                                                                           }
                 scan_pointer++;
                 scan_length++;
                 }
             byte_in = 128;
             }
             
          if (byte_in != 0 && byte_in != 128)
             {
             temp_byte_in = byte_in & 128;
             if (temp_byte_in == 128)
                {
                byte_in = byte_in & 127;
                for (cntr = 0; cntr < byte_in; cntr++)
                    {
                    *scan_pointer = 0xFF;
                    scan_pointer++;
                    scan_length++;
                    }
                }
             else
                {
                byte_in = byte_in & 127;
                for (cntr = 0; cntr < byte_in; cntr++)
                    {
                    *scan_pointer = 0;
                    scan_pointer++;
                    scan_length++;
                    }
                 }
             }
          }
    
    scan_pointer = scan_buffer;
    for (cntr = 0; cntr < scan_run; cntr++)
        {
        for (cntr1 = 0; cntr1 < bytes_per_line; cntr1++)
            {
            *img_pointer = *scan_pointer;
            byte_count++;
            img_pointer++;
            scan_pointer++;
            }
        scan_pointer = scan_buffer;
        }
    return 0;
    }
    
int pattern_run(void)
    {
    /* Read In Data - Pattern Run Compression */
    
    pattern_pointer = pattern_buffer;
    
    for (cntr = 0; cntr < img_header.pattern_length; cntr++)
        {
        if (! feof(img_file)) *pattern_pointer = fgetc(img_file); else
                                                                     {
                                                                     read_error();
                                                                     return -1;
                                                                     }
        }
    pattern_pointer = pattern_buffer;
    for (cntr = 0; cntr < patt_repeat; cntr ++)
        {
        for (cntr1 = 0; cntr1 < img_header.pattern_length; cntr1++)
            {
            *img_pointer = *pattern_pointer;
            byte_count++;
            img_pointer++;
            pattern_pointer++;
            }
        pattern_pointer = pattern_buffer;
        }
    byte_in = 0;
    return 0;
    }
    
int literal_read(void)
    {
    /* Read In Data - Literal Data Bytes */
    
    if (! feof(img_file)) byte_in = fgetc(img_file); else
                                                        {
                                                        read_error();
                                                        return -1;
                                                        }
    for (cntr = 0; cntr < byte_in; cntr++)
        {
        if (! feof(img_file)) *img_pointer = fgetc(img_file); else
                                                                 {
                                                                 read_error();
                                                                 return -1;
                                                                 }
        byte_count++;
        img_pointer++;
        }
    byte_in = 128;
    return 0;
    }
    
int solid_run_set(void)
    {
    /* Solid Run - 0xFF */
    
    byte_in = byte_in & 127;
    for (cntr = 0; cntr < byte_in; cntr++)
        {
        *img_pointer = 0xFF;
        byte_count++;
        img_pointer++;
        }
    return 0;
    }
    
int solid_run_clear(void)
    {
    /* Solid Run - 0x00 */
    
    byte_in = byte_in & 127;
    for (cntr = 0; cntr < byte_in; cntr++)
        {
        *img_pointer = 0;
        byte_count++;
        img_pointer++;
        }
    return 0;
    }
    
void read_error(void)
     {
     /* Report An EOF Condition When Reading img_file */
     
     error_bell();
     form_alert(1,"[3][Read Error|Reached EOF][STOP]");
     fclose(img_file);
     free(pattern_buffer);
     free(scan_buffer);
     wind_close(wi_handle[GENL]);
     wind_delete(wi_handle[GENL]);
     wi_handle[GENL] = -1;
     img_data = NULL;
     return;
     }

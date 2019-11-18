#ifndef __ZVLIGHT_H
#define __ZVLIGHT_H

/* This is extracted from zview.h and arranged for VISION */
/* Purpose is to located all the required ZView specific  */
/* Structures here without official ZView headers which   */
/* Quite heavy and with some dependencies on Mint/SLB     */
#define UP_TO_DOWN 0
#define DOWN_TO_UP 1

#define OPTION_CAPABILITIES 0
#define OPTION_EXTENSIONS   1

#define INFO_NAME           6	/* a single string */
#define INFO_VERSION        7	/* should be a BCD encoded version, like 0x102 */

#define CAN_DECODE 0x01
#define CAN_ENCODE 0x02

typedef struct
{
  unsigned char	red ;
  unsigned char	green ;
  unsigned char	blue ;
  /* Note that compiler includes a char filed here to align each structure element on 16bit */
}
ZVCOLOR_MAP ;

typedef struct _img_info
{
  /* Data returned by the decoder Picture's initialisation */
  unsigned short width ;               /* Picture width                                          */
  unsigned short height ;              /* Picture Height                                         */
  unsigned short components ;          /* Picture components                                     */
  unsigned short planes ;              /* Picture bits by pixel                                  */
  unsigned long  colors ;              /* Picture colors number                                  */
  short         orientation ;          /* Picture orientation: UP_TO_DOWN or DONW_TO_UP (ex TGA) */
  unsigned short page ;                /* Number of page/image in the file                       */
  unsigned short delay ;               /* Animation delay in 200th sec. between each frame.      */
  unsigned short num_comments ;        /* Lines in the file's comment. ( 0 if none)              */
  unsigned short max_comments_length ; /* The length of the greater line in the comment          */
  short          indexed_color ;       /* Picture has a palette: 0) No 1) Yes                    */
  short          memory_alloc ;        /* where to do the memory allocation for the reader_read 
                                          function buffer, possible values are ST_RAM or TT_RAM  */
  ZVCOLOR_MAP    palette[256] ;        /* Palette in standard RGB format                         */

  /* data send to the codec */
  unsigned long  background_color ;    /* The wanted background's color in hexa                  */
  short          thumbnail ;           /* 1 if true else 0.
                                          Some format have thumbnail inside the picture, if 1, we
                                          want only this thumbnail and not the image itself      */
  unsigned short page_wanted ;         /* The wanted page to get for the reader_read() function
                                          The first page is 0 and the last is img_info->page - 1 */

  /* The following variable are only for Information Prupose, the zview doesn't
     use it for decoding routine but only for the information dialog                             */ 
  char           info[40] ;            /* Picture's info, for ex: "Gif 87a"                      */
  char           compression[5] ;      /* Compression type, ex: "LZW"                            */
  unsigned short real_width ;          /* Real picture width( if the thumbnail variable is 1)    */
  unsigned short real_height ;         /* Ral picture Height( if the thumbnail variable is 1)    */


  /* Private data for the plugin */
  void* _priv_ptr ;
  void* _priv_ptr_more ;
  void* __priv_ptr_more ;

  long  _priv_var ;
  long  _priv_var_more ;
}
ZVIMGINFO, *PZVIMGINFO ;

typedef struct _txt_data
{
  short lines ;             /* Number of lines in the text                   */
  short max_lines_length ;  /* The length of the greater line ( in nbr char) */
  char* txt[256] ;
}
txt_data ;

#endif
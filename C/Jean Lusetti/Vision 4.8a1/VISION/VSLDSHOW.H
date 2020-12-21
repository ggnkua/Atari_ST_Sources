#if !defined (__VSLIDESHOW)
#define __VSLIDESHOW

#define DISPLAYTYPE_ZOOM      1
#define DISPLAYTYPE_REDUC     2

#define TRANSITION_NULL       0
#define TRANSITION_VLINES     1
#define TRANSITION_HLINES     2
#define TRANSITION_MOSAIC     3

#define BACK_BLACK            0
#define BACK_WHITE            1

#define CMD_NULL     0
#define CMD_REMARK   1
#define CMD_DISPLAY  2

#define ID_REMARK    ';'


typedef struct
{
  int   cmd_id ;
  char* params ;
}
CMD ;

typedef struct
{
  int  err ;
  int  line_err ;

  int  wait_mini_sec ;
  char do_not_show_mouse ;
  char do_not_cls_scr ;
  int  back ;
  int  display_type ;
  int  transition ;
  int  cycle ;
  int  ignore_vss ;
  int  aff_name ;
  int  aff_prog ;

  long  nb_cmd ;
  CMD*  cmds ;
  long  buffer_params_size ;
  char* buffer_params ;
  long  ncmds ;  /* While loading to make  */
  long  nbytes ; /* Sure we don't overflow */

  /* Internal data used by vss_doslideshow */
 int nb_steps ;
 int num_courant ;
 int num_total ;
 int txt_color ;
 int back_color ;
 int yprog ;
}
VSS_INFO ;

#define VSSERR_NOERROR        0
#define VSSERR_FILE           1
#define VSSERR_CMDUNKNOWN     2
#define VSSERR_MEMORY         3


int  vss_load(char* name, VSS_INFO* vss_info) ;
void vss_doslideshow(VSS_INFO* vss_info) ;
void vss_free(VSS_INFO* vss_info) ;


#endif

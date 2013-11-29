/* define stuff for CZ-Android */

#define WBHEIGHT 182    /* pixel height of WBA,WBB,CZ windows (based on 200) */
#define WSHEIGHT 22     /* pixel height of WS window (based on 200) */
#define WBWIDTH  132    /* pixel width for all 4 windows (based on 640) */
#define WI_KIND 9       /* all 4 windows are named and movable */
#define WI_KIND2   3    /* edit window is named and closable */
#define TE_TXTLEN(x) (x+24)  /* editable text length */
#define INITNAME &"***** init *****"  /* name for initialized voices */
#define DROIDNAM &"*** android ****"  /* name for androided voices */
#define DISTNAME &"*** distort ****"  /* name for distorted voices */
#define NONAME   &"   (no name)    "    /* name for "unnamed" voices */

/* form_alert messages */

#define BADINIT  &"[1][Cannot initialize|this application.][Oh no!]"
#define BADRAM   &"[1][CZ-Android cannot run with|TOS loaded into RAM.][Sorry]"
#define BADRSRC  &"[1][The resource file|can't be found.][Oh no!]"
#define BADREZ   &"[1][Screen resolution must|be set to medium][Sorry]"
#define BADCREAT &"[1][Unable to create|the specified file.][Cancel]"
#define BADWRITE &"[1][Unable to write|the specified file.][Cancel]"
#define BADOPEN  &"[1][Unable to open|the specified file.][Cancel]"
#define BADREAD  &"[1][The file is too short.][Cancel]"
#define BADDATA  &"[1][The file contains weird data.][Cancel]" 
#define BADERASE &"[1][Unable to erase|the specified file.][Cancel]"
#define BADFMT   &"[1][Disk formatting has failed.][Cancel]"
#define BADRENAM &"[1][Unable to rename|the specified file.][Cancel]"
#define BADFNM1  &"[1][Cannot rename file:|Void name.][Cancel]"
#define BADFNM2  &"[1][File name can't|start with a period.][Cancel]"
#define BADFNM3  &"[1][File name can't|end with a period.][Cancel]"
#define BADFNM4  &"[1][File name can't have|more than one period.][Cancel]"
#define BADFNM5  &"[1][File name contains|illegal character(s).][Cancel]"
#define BADFNM6  &"[1][File name or a part|of it is too long.][Cancel]"
#define BADCPY1  &"[1][You can't copy a group|of voices into one slot.][Cancel]"
#define BADCPY2  &"[1][Undefined copy destination.][Cancel]"
#define BADSYN   &"[1][Synth i/o error:|Check MIDI cables or synth.][Cancel]"
#define BAD230S &"[1][Only voices 96-99 are|available on a CZ-230S.][Cancel]"
#define BADDEMO &"[3][CZ-Android demo version:|Function not available.][Sorry]"

#define CHEKQUIT &"[3][Select OK only if|you've saved your work.][Cancel|OK]"
#define CHEKSAFE &"[2][Are you sure you want to do this?][Yes|No]"
#define CHEKREPL &"[3][You are about to|replace an existing file.][Cancel|OK]"
#define CHEKFMT &"[3][Formatting a disk|will erase any files on it.][Cancel|OK]"
#define CHEKEXIT &"[2][Keep or discard all editing?][Cancel|Keep|Discard]"


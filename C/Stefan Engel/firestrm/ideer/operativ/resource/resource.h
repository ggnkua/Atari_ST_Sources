/*****************************************************************/
/* Declaration of Routines                                       */
/*****************************************************************/
long LoadResource(const char*)

struct OBJECT
{
  long          next,
                prev,
                parent,
                child;
  short         type,
                switches;
  union
  {
    RO_UserDefined  *UserDefined;
    RO_Button       *Button;
    RO_ButtonHelp   *ButtonHelp;
    RO_BottunScroll *ButtonScroll;
  };
  char          *Helptext;
  short         x,
                y,
                w,
                h;
}RObject;

struct
{
  union
  {
    long Language
    char Langstring[4];
  }
  RObject *List[];
}RHeader

struct
{
  char *HelpFile,
       *ShortText;
  long HelpIndex;
}HELP

#define RO_USERDEFINED
#define RO_BOX
#define RO_ONOFFSWITCH
#define RO_STRING
#define RO_TEXT
#define RO_TEXTINPUT
#define RO_TEXTINPUTSECRET
#define RO_TEXTAREA
#define RO_BUTTON
#define RO_BUTTONHELP
#define RO_BUTTONUP
#define RO_BUTTONDOWN
#define RO_BUTTONLEFT
#define RO_BUTTONRIGHT
#define RO_SLIDEBOXVERTIKAL
#define RO_SLIDEBOXHORISONTAL
#define RO_IMAGE
#define RO_ICON
#define RO_PAGEREGISTER
#define RO_PAGE

#define ROTE_BOLD         1
#define ROTE_ITALIC       2
#define ROTE_GHOST        4
#define ROTE_UNDERLINE    8

struct
{
  void  *update;
  void  *handler;
  void  *extendeddata;
  long   events;
}RO_UserDefined;

struct
{
  char  *text
  Help  *help;
}RO_Button;

struct
{
  Help  *help;
}RO_ButtonHelp;

struct
{
  byte   Direction;
  Help  *help;
}RO_ButtonScroll;

struct
{
  long   Min,
         Max,
         Position,
         Size;
  Help  *help;
}RO_SlideBox


struct
{
  short  size;
  char  *string;
}RO_String;

struct
{
  byte   colour;
  byte   effects;
  long   fontid;
  short  fontsize;
  short  templatesize;
  char  *template;
}RO_Text;

struct
{
  byte   colour;
  long   fontid;
  short  fontsize;
  short  stringsize;
  char  *string;
  short  validsize;
  char  *valid;
  short  templatesize;
  char  *template
  Help  * help;
}RO_TextInput;


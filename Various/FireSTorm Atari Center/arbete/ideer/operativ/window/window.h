/********************************************************************/
/* Header file for EVERY window system component                    */
/********************************************************************/
#include <osbind.h>
/********************************************************************/
#define byte  char
//#define short short
//#define long  long
#define ultra struct{long High,low;}
/********************************************************************/
#define FATAL_WINDOW  -10
#define FAIL          -1
#define SYSTEM_OK     0
#define TRUE          1
#define FALSE         0
#define WINDOW_FREE   (byte)(1<<0)
#define WINDOW_DIALOG (byte)(1<<1)
#define WINDOW_SCREEN (byte)(1<<7)

#define WINDOW_STATUS_CLOSED   (byte)0x00
#define WINDOW_STATUS_OPENED   (byte)(1<<0)
#define WINDOW_STATUS_ICONIZED (byte)(1<<1)
#define WINDOW_STATUS_HIDDEN   (byte)(1<<2)

/********************************************************************/
typedef struct _attributes
{
  long closer      ;
}attributes;

/********************************************************************/
typedef struct _color
{
  short red;
  short green;
  short blue;
} color;

/********************************************************************/
typedef struct _window
{
  ultra pidowner;
  byte  type;
  byte  status;
  byte  colorlistsize;
  color *colorlist;
  long  parentid;
  long  nextid;
  long  id;
  attributes attribs;
}window;

/********************************************************************/
typedef struct _windowentry
{
  short        used;
  struct _windowentry *nextentry;
  window       *currwindow;
}_windowentry;

/********************************************************************/
typedef struct _windowlist
{
  byte windowlisttotalsize;
  byte windowlistsize;
  _windowentry *list;
  struct _windowlist *nextwindowlist;
} _windowlist;

/********************************************************************/
typedef struct _windowsystem
{
  byte        createwindowlist,
              deletewindowlist;
  long        lowid,highid;
  int         lockwindowlistchange :1,
              lockwindowsystem     :1;
  _windowlist *firstlist;
  _windowentry   *firstentry,
                 *lastentry,
                 *firstfreeentry, 
                 *lastfreeentry;
} _windowsystem;

/********************************************************************/
extern _windowsystem  windowsystem;
/********************************************************************/
int          WindowOpen(long id, short xy[4]);
int          WindowClose(long id);
window      *WindowFind(long id);
int          WindowDelete(long id);
window      *WindowCreate(int type, int parent);
_windowlist *CreateWindowList(_windowlist* previouslist);

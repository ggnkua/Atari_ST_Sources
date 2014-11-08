#define DATAVOID
#include "dialog.h"
static RO_Button button[]=
{
/* 0 */    {BUTTON_NORMAL,(char *)"Testing 1"},
/* 1 */    {BUTTON_ROUNDED,(char *)"Testing 2"},
/* 2 */    {BUTTON_RADIO,(char *)"Skit"},
/* 3 */    {BUTTON_CROSS,(char *)"Helvete"},
/* 4 */    {BUTTON_NORMAL,(char *)0},
/* 5 */    {BUTTON_NORMAL,(char *)0},
/* 6 */    {BUTTON_NORMAL,(char *)0},
/* 7 */    {BUTTON_NORMAL,(char *)0},
};

static RO_ScrollBar scrollbar[]=
{
/* 0 */    {0,1000,200,200,SCROLLBAR_VERTICAL},
};

static RO_Window window[]=
{
/* 0 */    {(char*)"testing",0xffffffff,0x00081003},
};

static char *strings[]=
{
/* 0 */    "String 1",
/* 1 */    "Row 2",
};

static char *helpstrings[]=
{
/* 0 */    "Tryck h„r f”r roliga saker",
};
RO_Object objects[]=
{
/* 0 */    {"ResourceTree1\0\0",-1,-1,-1,1,RO_TREE,0,(void*)"SE",(char*)0,80,31,5,2},
/* 1 */    {"WINDOW1\0\0\0\0\0\0\0\0",-1,-1,0,2,RO_WINDOW,SW_DEFAULT,(void*)&window[0],(char*) 0,300,100,500,250},
/* 2 */    {"BUTTON1\0\0\0\0\0\0\0\0",3,-1,1,-1,RO_BUTTON,SW_DEFAULT,(void*)&button[0],(char*)&helpstrings[0],10,10,200,20},
/* 3 */    {"BUTTON2\0\0\0\0\0\0\0\0",4,2,1,-1,RO_BUTTON,SW_NONE,(void*)&button[3],(char*)0,10,40,100,20},
/* 4 */    {"BUTTON3\0\0\0\0\0\0\0\0",5,3,1,-1,RO_BUTTON,SW_NONE,(void*)&button[1],(char*)0,10,70,100,20},
/* 5 */    {"BUTTON4\0\0\0\0\0\0\0\0",6,4,1,-1,RO_BUTTON,SW_NONE,(void*)&button[2],(char*)0,10,100,100,20},
/* 6 */    {"SCROLLBAR1\0\0\0\0\0",7,5,1,-1,RO_SCROLLBAR,SW_NONE,(void*)&scrollbar[0],(char*)0,477,3,20,224},
/* 7 */    {"STRING1\0\0\0\0\0\0\0\0",-1,6,1,-1,RO_STRING,SW_NONE,(void*)&strings[0],(char*)0,150,50,100,20},
};

long ResourceTree1,BUTTON1,BUTTON2,BUTTON3,BUTTON4,WINDOW1,TOOLPANEL1,SCROLLBAR1;


void init_resource(RO_Object *tree)
{
  ResourceTree1=find_object(tree,"ResourceTree1");
  BUTTON1=find_object(tree,"BUTTON1");
  BUTTON2=find_object(tree,"BUTTON2");
  BUTTON3=find_object(tree,"BUTTON3");
  BUTTON4=find_object(tree,"BUTTON4");
  WINDOW1=find_object(tree,"WINDOW1");
  SCROLLBAR1=find_object(tree,"SCROLLBAR1");
}

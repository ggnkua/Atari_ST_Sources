/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
#include <aes.h>
#include "dialog.h"
/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
void init_graph(void);
void deinit_graph(void);

/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
extern short work_in[11], work_out[57];
extern short graph_id;
short appl_id;
extern RO_Object objects[];
extern long ResourceTree1,BUTTON1,BUTTON2,BUTTON3,BUTTON4,WINDOW1;

/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
int main(void)
{
  init_graph();
  init_resource(objects);
  show(objects,WINDOW1);
  while(getch()!=27)
  {
    if(objects[BUTTON1].switches&SW_SELECTED)
      objects[BUTTON1].switches&=~SW_SELECTED;
    else
      objects[BUTTON1].switches|=SW_SELECTED;
    show(objects,BUTTON1);

    if(getch()==27) break;

    if(objects[BUTTON2].switches&SW_SELECTED)
      objects[BUTTON2].switches&=~SW_SELECTED;
    else
      objects[BUTTON2].switches|=SW_SELECTED;
    show(objects,BUTTON2);

    if(getch()==27) break;

    if(objects[BUTTON4].switches&SW_SELECTED)
      objects[BUTTON4].switches&=~SW_SELECTED;
    else
      objects[BUTTON4].switches|=SW_SELECTED;
    show(objects,BUTTON4);

    if(getch()==27) break;

    if(objects[BUTTON1].switches&SW_TEMP)
      objects[BUTTON1].switches&=~SW_TEMP;
    else
      objects[BUTTON1].switches|=SW_TEMP;
    show(objects,BUTTON1);

    if(getch()==27) break;

  }
  deinit_graph();
  return 0;
}

/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
void init_graph(void)
{
  appl_id=appl_init();
  work_in[0]=1;
  work_in[1]=0;
  work_in[2]=1;
  work_in[3]=0;
  work_in[4]=0;
  work_in[5]=0;
  work_in[6]=1;
  work_in[7]=1;
  work_in[8]=0;
  work_in[9]=COLOR_GRAY;
  work_in[10]=2;
  graph_id=appl_id;
  v_opnvwk(work_in,&graph_id,work_out);
}

/****************************************************************************************/
/*                                                                                      */
/****************************************************************************************/
void deinit_graph(void)
{
  v_clsvwk(graph_id);
  appl_exit();
}




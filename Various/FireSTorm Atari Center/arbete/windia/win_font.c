#ifdef WINFONT
/***********************************************************************/
/* Routines for Font specification                                     */
/***********************************************************************/
#include <aes.h>
#include <vdi.h>
#include <stdio.h>
#include <tos.h>
#include <string.h>
#include "windia.h"
#include "win_dia.h"
#include "win_dia2.h"
/********************************************************************/
/********************************************************************/
short font_popup(int curr_id, OBJECT *tree, int object, char *choice, char *head)
{
#ifdef WINPOPUP
#define counter xy[0]
#define select  xy[1]

  if(!gdos)
    return curr_id;

  if(head)
  {
    pop_string=Malloc(strlen(head)+2+num_fonts*(FONT_NAME_SIZE+2));
    if(!pop_string)
      return curr_id;
    strcpy(pop_string,head);
  }
  else
  {
    pop_string=Malloc(strlen("Select font")+2+num_fonts*(FONT_NAME_SIZE+2));
    if(!pop_string)
      return curr_id;
    strcpy(pop_string,"Select font");
  }
  pop_values=Malloc((num_fonts+1)*sizeof(long));
  if(pop_values==NOLL)
  {
    Mfree(pop_string);
    return curr_id ;
  }
  for(counter=NOLL;counter<=num_fonts;counter++)
  {
    pop_values[counter]=vqt_name(graf_id,counter+1,d_temp);
    if(pop_values[counter]==curr_id)
      select=counter;
    d_temp[32]=NOLL;
    strcat(pop_string,"|");
    strcat(pop_string,d_temp);
  }
  
  select=popup(pop_string,select,tree,object,choice);
  
  select=pop_values[select];
  Mfree(pop_string);
  Mfree(pop_values);
  return select;
#undef counter
#undef select
#else
  return curr_id;
#endif
}
/********************************************************************/
/********************************************************************/
short fontsize_popup(short curr_id, short curr_size, OBJECT *tree, int object, char *head)
{
#ifdef WINPOPUP

#define FONT_CURR_ID   xy[1]
#define FONT_CURR_SIZE xy[0]
#define counter        xy[8]
#define num_sizes      xy[7]
#define temp_size1     xy[6]
#define temp_size2     xy[5]
#define select         xy[4]

  if(!gdos)
    return curr_size;
    
  FONT_CURR_ID=vst_font(graf_id,-1);
  FONT_CURR_SIZE=vst_point(graf_id,-1,&dummy,&dummy,&dummy,&dummy);

  temp_size1=9999;
  temp_size2=9998;
  xy[4]=0;
  num_sizes=0;
  vst_font(graf_id,curr_id);
  while(temp_size1>temp_size2)
  {
    if(temp_size2!=9998)
    {
      num_sizes++;
    }
    temp_size1=temp_size2;
    temp_size2=vst_point(graf_id,temp_size1-1,&dummy,&dummy,&dummy,&dummy);
  }

  if(!num_sizes)
    return(curr_size);
  if(head)
  {
    pop_string=(char *)Malloc(strlen(head)+2+num_sizes*(FONT_SIZE_SIZE+2));
    if(pop_string==NOLL)
      return(curr_size);
    strcpy(pop_string,head);
  }
  else
  {
    pop_string=(char *)Malloc(strlen("Size")+num_sizes*(FONT_SIZE_SIZE+2));
    if(pop_string==NOLL)
      return(curr_size);
    strcpy(pop_string,"Size");
  }
  pop_values=(long *)Malloc((num_sizes+1)*sizeof(long));
  if(pop_values==NOLL)
  {
    Mfree(pop_string);
    return(curr_size);
  }
  temp_size1=9999;
  temp_size2=9998;
  num_sizes=0;
  select=FAIL;
  vst_font(graf_id,curr_id);
  while(temp_size1>temp_size2)
  {
    if(temp_size2!=9998)
    {
      strcat(pop_string,"|");
      sprintf(d_temp,"%4d",temp_size2);
      strcat(pop_string,d_temp);
      pop_values[num_sizes]=temp_size2;
      if(temp_size2==curr_size)
        select=xy[4];
      num_sizes++;
    }
    temp_size1=temp_size2;
    temp_size2=vst_point(graf_id,temp_size1-1,&dummy,&dummy,&dummy,&dummy);
  }
  select=popup(pop_string,select,tree,object,NULL);
  
  vst_font(graf_id,FONT_CURR_ID);
  vst_point(graf_id,FONT_CURR_SIZE,&dummy,&dummy,&dummy,&dummy);
  return(pop_values[select]);

#undef FONT_CURR_ID
#undef FONT_CURR_SIZE
#undef counter
#undef num_sizes
#undef temp_size1
#undef temp_size2
#undef select

#else
  return curr_size;
#endif

}
/********************************************************************/
/********************************************************************/
void font_name(long id,char *name)
{
  int counter;
  short select;
  if(name==NULL)
    return;
  strcpy(name,"");
  for(counter=NOLL;counter<=num_fonts;counter++)
  {
    select=vqt_name(graf_id,counter+1,d_temp);
    d_temp[32]=NOLL;
    if(!select==counter)
    {
      strcpy(name,d_temp);
      break;
    }
  }
}
/********************************************************************/
/********************************************************************/
short font_id(char *name)
{
#define counter xy[0]
#define select  xy[1]

  select=0;
  if(name==NOLL)
    return(1);
  for(counter=NOLL;counter<=num_fonts;counter++)
  {
    select=vqt_name(graf_id,counter+1,d_temp);
    d_temp[32]=NOLL;
    if(!strcmp(d_temp,name))
      return(select);
  }
  return(1);

#undef counter
#undef select
}

#endif
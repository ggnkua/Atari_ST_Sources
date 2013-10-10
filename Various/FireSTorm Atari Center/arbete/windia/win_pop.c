#ifdef WINPOPUP
/***********************************************************************/
/* * The Slidebox does not work at the moment                          */
/* * Selecting which Mouse-button to select with should be possible    */
/* * The Seperator is NOT going to work with scrollable popups         */
/* * the "Disabled entries" does not work with scrollable popups       */
/* * The Popup should be created in the program (so that more than 20  */
/*   entries can be possible                                           */
/* * the popup should be keyboard controllable (up/down, shift-up/down */
/*   , clr/home, shift-clr/home, undo,esc and Return/enter             */
/***********************************************************************/
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
/***********************************************************************/
/* Rutin f”r att sl„nga upp en Popup-ruta                              */
/***********************************************************************/
int popup(char *string,int selected, OBJECT *tree,int object,char *choice)
{
  POPUP_DATA pop;
  EVENT_DATA evnt;
  int        dummy;

  pop.select=selected;
  pop.s_antal=20;
  pop.d_antal=0;
  pop.number=0;
  pop.size=0;
  pop.tree=tree;
  pop.object=object;
  pop.string=string;
  pop.offset=-1;

  if(string==NULL)
    return(selected);
  
  init_popup(&pop);
  evnt.check=NOLL;
  evnt.end=FALSE;
  if(choice!=NULL)
    strcpy(choice,poptree[pop.number+P_CHOOSE0].ob_spec);
  do
  {
    if(evnt.check==NOLL)
      evnt.check=evnt_multi(MU_KEYBD|MU_BUTTON,258,MO_LEFT|MO_RIGHT,0,0,0,0,0,0,0,0,0,0,0,0,0,0,&evnt.mo_x,&evnt.mo_y,&evnt.mo_b,&evnt.k_s,&evnt.key,&evnt.m_r);
    if((evnt.check&MU_BUTTON)&&(evnt.mo_b==MO_LEFT))
    {
      evnt.d1=objc_find(poptree,ROOT,MAX_DEPTH,evnt.mo_x,evnt.mo_y);
      if((evnt.mo_x<poptree[ROOT].ob_x)||(evnt.mo_x>poptree[ROOT].ob_x+poptree[ROOT].ob_width)||(evnt.mo_y<poptree[ROOT].ob_y)||(evnt.mo_y>poptree[ROOT].ob_y+poptree[ROOT].ob_height))
      {
        evnt.end=TRUE;
        evnt.check&=~MU_BUTTON;
      }
      else if((evnt.d1>=P_CHOOSE0)&&(evnt.d1<=P_CHOOSE19)&&(poptree[evnt.d1].ob_type==G_STRING)&&(!(poptree[evnt.d1].ob_state&DISABLED)))
      {
        if((pop.number!=FAIL)&&(pop.number!=evnt.d1-P_CHOOSE0))
        {
          objc_change(poptree,pop.number+P_CHOOSE0,0,screenx,screeny,screenw,screenh,NOLL,TRUE);
          objc_change(poptree,evnt.d1,0,screenx,screeny,screenw,screenh,SELECTED,TRUE);
        }
        else if(pop.number==FAIL)
        {
          objc_change(poptree,evnt.d1,0,screenx,screeny,screenw,screenh,SELECTED,TRUE);
        }
        pop.number=evnt.d1-P_CHOOSE0;
        pop.select=pop.offset+pop.number;
        objc_offset(poptree,pop.number+P_CHOOSE0,&evnt.xy[X],&evnt.xy[Y]);
        evnt.xy[W]=poptree[pop.number+P_CHOOSE0].ob_width;
        evnt.xy[H]=poptree[pop.number+P_CHOOSE0].ob_height;
        dummy=evnt_multi(MU_BUTTON|MU_M1,1,MO_LEFT,MO_NO_BUTT,1,evnt.xy[X],evnt.xy[Y],evnt.xy[W],evnt.xy[H],0,0,0,0,0,0,0,0,&evnt.mo_x,&evnt.mo_y,&evnt.mo_b,&evnt.k_s,&evnt.key,&evnt.m_r);
        if(dummy&MU_BUTTON)
        {
          selected=pop.offset+pop.number;
          if(choice!=NULL)
            strcpy(choice,poptree[pop.number+P_CHOOSE0].ob_spec);
          evnt.end=TRUE;
        }
      }
      else
      {
        switch(evnt.d1)
        {
          break;
          case POPUP_UP:
          case POPUP_UP_IMG:
            if(pop.offset>0)
            {
              if(!(poptree[POPUP_UP].ob_state&SELECTED))
              {
                poptree[POPUP_UP].ob_state|=SELECTED;
                objc_draw(poptree,POPUP_UP,1,screenx,screeny,screenw,screenh);
              }
              pop.offset--;
              if(pop.number!=FAIL)
              {
                poptree[pop.number+++P_CHOOSE0].ob_state=NOLL;
                if(pop.number>P_CHOOSE19-P_CHOOSE0)
                  pop.number=FAIL; 
              }
              if(pop.number==FAIL)
              {
                if((pop.select-pop.offset>FAIL)&&(pop.select-pop.offset<9))
                  pop.number=pop.select-pop.offset;
               }
              if(pop.number!=FAIL)
                poptree[pop.number+P_CHOOSE0].ob_state=SELECTED;

              for(dummy=P_CHOOSE19; dummy>P_CHOOSE0; dummy--)
                poptree[dummy].ob_spec=poptree[dummy-1].ob_spec;
              for(;*pop.pointer1!='\0';pop.pointer1--);
              pop.pointer1--;
              poptree[P_CHOOSE0].ob_spec=pop.pointer1+2;
              pop.pointer2=(char *)poptree[P_CHOOSE19].ob_spec;
              dummy=poptree[ROOT].ob_y;
              objc_draw(poptree,ROOT,MAX_DEPTH,poptree[ROOT].ob_x,dummy+poptree[P_CHOOSE0].ob_y,poptree[P_CHOOSE0].ob_width+1,dummy+poptree[P_CHOOSE19].ob_y+poptree[P_CHOOSE19].ob_height);
              dummy=evnt_multi(MU_BUTTON|MU_M1|MU_TIMER,1,MO_LEFT,MO_NO_BUTT,1,evnt.xy[X],evnt.xy[Y],evnt.xy[W],evnt.xy[H],0,0,0,0,0,0,0,100,&evnt.mo_x,&evnt.mo_y,&evnt.mo_b,&evnt.k_s,&evnt.key,&evnt.m_r);
              if(dummy&(MU_BUTTON|MU_M1))
              {
                poptree[POPUP_UP].ob_state&=~SELECTED;
                objc_draw(poptree,POPUP_UP,1,screenx,screeny,screenw,screenh);
              }
            }
            break;
          case POPUP_DOWN:
          case POPUP_DOWN_IMG:
            if(pop.offset+pop.s_antal<pop.d_antal)
            {
              pop.offset++;
              if(pop.number!=FAIL)
                poptree[pop.number--+P_CHOOSE0].ob_state=NOLL;
              if(pop.number==FAIL)
              {
                if((pop.select-pop.offset>FAIL)&&(pop.select-pop.offset<9))
                  pop.number=pop.select-pop.offset;
              }
              if(pop.number!=FAIL)
                poptree[pop.number+P_CHOOSE0].ob_state=SELECTED;
              
              for(dummy=P_CHOOSE0; dummy<P_CHOOSE19; dummy++)
                poptree[dummy].ob_spec=poptree[dummy+1].ob_spec;
              for(;*pop.pointer2!='\0';pop.pointer2++);
              pop.pointer2++;
              poptree[P_CHOOSE19].ob_spec=pop.pointer2;
              pop.pointer1=(char *)poptree[P_CHOOSE0].ob_spec-2;
              dummy=poptree[ROOT].ob_y;
              objc_draw(poptree,ROOT,MAX_DEPTH,poptree[ROOT].ob_x,dummy+poptree[P_CHOOSE0].ob_y,poptree[P_CHOOSE0].ob_width+1,dummy+poptree[P_CHOOSE19].ob_y+poptree[P_CHOOSE19].ob_height);
            }
            break;
          default:
            break;
        }
        evnt.check&=~MU_BUTTON;
      }
    }
    else if((evnt.check&MU_BUTTON)&&(evnt.mo_b|MO_RIGHT))
    {
      evnt.end=TRUE;
      evnt.check&=~MU_BUTTON;
    }
    else if(evnt.check&MU_KEYBD)
    {
      evnt.end=TRUE;
      evnt.check&=~MU_KEYBD;
    }
  } while(!evnt.end);

  deinit_popup(&pop);
  return(selected);
}

/********************************************************************/
/* initiering av en popup                                           */
/********************************************************************/
void init_popup(POPUP_DATA *pop)
{
  int   counter=0; 

  pop->pointer1=pop->pointer2=pop->string;
  /******************************************************************/
  /* Change the '|' terminated strings to 0 terminated and count    */
  /* How many strings                                               */
  /******************************************************************/
  while(pop->string[pop->size]!=NOLL)
  {
    if(pop->string[pop->size]=='|')
    {
      counter++;
      pop->string[pop->size]=NOLL;
    }
    pop->size++;
  }
  pop->d_antal=counter /*-1*/;
  if(pop->d_antal<pop->s_antal)
    pop->s_antal=pop->d_antal;
  if(exist_3d)
  {
    long temp;
    poptree=POPUP_3D;
    temp=(long)poptree[ROOT].ob_spec;
    temp&=0xff00ffff;
    temp|=0x00020000;
    poptree[ROOT].ob_spec=temp;
  }
  else
    poptree=POPUP_MONO;

  poptree[P_TITLE_TEXT].ob_spec=pop->string;
  b_place(pop->tree,pop->object,xy);
  poptree[ROOT].ob_x=pop->tree[pop->object].ob_x;
  if(pop->object!=ROOT)
  poptree[ROOT].ob_x+=pop->tree[ROOT].ob_x;
  poptree[ROOT].ob_width=xy[W];
  if(pop->s_antal==pop->d_antal)
  {
    poptree[POPUP_UP].ob_flags|=HIDETREE;
    poptree[POPUP_DOWN].ob_flags|=HIDETREE;
    poptree[POPUP_SLIDE_BACK].ob_flags|=HIDETREE;
  }
  else
  {
    poptree[ROOT].ob_width+=poptree[POPUP_UP_IMG].ob_width+3;
    poptree[POPUP_UP].ob_flags&=~HIDETREE;
    poptree[POPUP_DOWN].ob_flags&=~HIDETREE;
    poptree[POPUP_SLIDE_BACK].ob_flags&=~HIDETREE;
  }
  poptree[POPUP_TITLE].ob_x=0;
  poptree[POPUP_TITLE].ob_y=0;
  poptree[POPUP_TITLE].ob_height=font_height+2;
  poptree[POPUP_TITLE].ob_width=poptree[ROOT].ob_width;
  poptree[POPUP_TITLE].ob_spec=(void *)0x00FF0000;
  poptree[ROOT].ob_height=poptree[POPUP_TITLE].ob_height+2+pop->s_antal*font_height;
  poptree[P_TITLE_TEXT].ob_x=poptree[POPUP_TITLE].ob_x;
  poptree[P_TITLE_TEXT].ob_y=poptree[POPUP_TITLE].ob_y;
  poptree[P_TITLE_TEXT].ob_height=poptree[POPUP_TITLE].ob_height;
  poptree[P_TITLE_TEXT].ob_width=poptree[POPUP_TITLE].ob_width;
  poptree[POPUP_UP].ob_x=poptree[ROOT].ob_width-poptree[POPUP_UP_IMG].ob_width-2;
  poptree[POPUP_UP].ob_y=poptree[POPUP_TITLE].ob_height+4;
  poptree[POPUP_UP].ob_width=poptree[POPUP_UP_IMG].ob_width;
  poptree[POPUP_UP].ob_height=poptree[POPUP_UP_IMG].ob_height;
  poptree[POPUP_UP_IMG].ob_x=0;
  poptree[POPUP_UP_IMG].ob_y=0;
  poptree[POPUP_DOWN].ob_x=poptree[POPUP_UP].ob_x;
  poptree[POPUP_DOWN].ob_y=poptree[ROOT].ob_height-poptree[POPUP_DOWN_IMG].ob_height-2;
  poptree[POPUP_DOWN].ob_width=poptree[POPUP_DOWN_IMG].ob_width;
  poptree[POPUP_DOWN].ob_height=poptree[POPUP_DOWN_IMG].ob_height;
  poptree[POPUP_DOWN_IMG].ob_x=0;
  poptree[POPUP_DOWN_IMG].ob_y=0;
  poptree[POPUP_SLIDE_BACK].ob_x=poptree[POPUP_UP].ob_x;
  poptree[POPUP_SLIDE_BACK].ob_y=poptree[POPUP_UP].ob_y+poptree[POPUP_UP].ob_height+4;
  poptree[POPUP_SLIDE_BACK].ob_width=poptree[POPUP_DOWN].ob_width;
  poptree[POPUP_SLIDE_BACK].ob_height=poptree[POPUP_DOWN].ob_y-poptree[POPUP_SLIDE_BACK].ob_y;
  poptree[POPUP_SLIDE].ob_x=0;
  poptree[POPUP_SLIDE].ob_y=0;
  /* Nedanst†ende rad skall ber„knas fram */
  poptree[POPUP_SLIDE].ob_height=poptree[POPUP_SLIDE_BACK].ob_height-16;
  poptree[POPUP_SLIDE].ob_width=poptree[POPUP_SLIDE_BACK].ob_width;
  for(counter=P_CHOOSE0; counter<=P_CHOOSE19; counter++)
  {
    poptree[counter].ob_type=G_STRING;
    poptree[counter].ob_state=NOLL;
    poptree[counter].ob_flags=NOLL;
    poptree[counter].ob_x=1;
    poptree[counter].ob_y=poptree[POPUP_TITLE].ob_height+2+(counter-P_CHOOSE0)*font_height;
    poptree[counter].ob_height=16;
    if(pop->s_antal>=pop->d_antal)
      poptree[counter].ob_width=poptree[ROOT].ob_width-2;
    else
      poptree[counter].ob_width=poptree[POPUP_DOWN].ob_x-6;
    poptree[counter].ob_flags&=~HIDETREE;
  }
  counter=P_CHOOSE0+pop->s_antal;
  while(counter<=P_CHOOSE19)
    poptree[counter++].ob_flags|=HIDETREE;
  if(pop->select>FAIL)
  {
    while((pop->offset+pop->s_antal<pop->d_antal)&&(pop->offset<pop->select))
    {
      for( ; *pop->pointer1!=0; pop->pointer1++);
      pop->pointer1++;
      pop->offset++;
    }
  }
  else
  {
    for( ; *pop->pointer1!=0; pop->pointer1++);
    pop->pointer1++;
    pop->offset++;
  }
  pop->pointer2=pop->pointer1;
  pop->pointer1-=2;
  if(*pop->pointer2=='-')
  {
    poptree[P_CHOOSE0].ob_state|=DISABLED;
    pop->pointer2++;
  }
  (char *)poptree[P_CHOOSE0].ob_spec=pop->pointer2;
  for(counter=1; counter<pop->s_antal; counter++)
  {
    for(;*pop->pointer2!='\0';pop->pointer2++);
    pop->pointer2++;
    if(strcmp(pop->pointer2,"-"))
    {
      if(*pop->pointer2=='-')
      {
        poptree[P_CHOOSE0+counter].ob_state|=DISABLED;
        pop->pointer2++;
      }
      (char *)poptree[P_CHOOSE0+counter].ob_spec=pop->pointer2;
    }
    else
    {
      poptree[P_CHOOSE0+counter].ob_type=G_BOX;
      poptree[P_CHOOSE0+counter].ob_x+=font_width/2;
      poptree[P_CHOOSE0+counter].ob_width-=font_width;
      if(exist_3d)
      {
        poptree[P_CHOOSE0+counter].ob_flags=FL3DACT;
        poptree[P_CHOOSE0+counter].ob_spec=(void *)0x00FF0000;
        poptree[P_CHOOSE0+counter].ob_state=SELECTED;
        poptree[P_CHOOSE0+counter].ob_height=1;
        poptree[P_CHOOSE0+counter].ob_y+=font_height/2;
      }
      else
      {
        poptree[P_CHOOSE0+counter].ob_height=2;
        poptree[P_CHOOSE0+counter].ob_y+=font_height/2-1;
        poptree[P_CHOOSE0+counter].ob_spec=(void *)0x1071;
      }
    }
  }
  pop->number=pop->select-pop->offset;
  poptree[ROOT].ob_y=pop->tree[pop->object].ob_y-poptree[POPUP_TITLE].ob_height-2-font_height*(pop->select-pop->offset);
  if(pop->object!=ROOT)
    poptree[ROOT].ob_y+=pop->tree[ROOT].ob_y;
  if(poptree[ROOT].ob_x+poptree[ROOT].ob_width>screenx+screenw)
     poptree[ROOT].ob_x=screenx+screenw-poptree[ROOT].ob_width;
  while(poptree[ROOT].ob_y<screeny)
    poptree[ROOT].ob_y+=font_height;
  if(pop->number!=FAIL)
    poptree[P_CHOOSE0+pop->number].ob_state|=SELECTED;
  while(poptree[ROOT].ob_y+poptree[ROOT].ob_height>screeny+screenh)
    poptree[ROOT].ob_y-=font_height;
  
  if(pop->number!=FAIL)
  {
    pop->x=poptree[P_CHOOSE0+pop->number].ob_x;
    pop->y=poptree[P_CHOOSE0+pop->number].ob_y;
    pop->w=poptree[P_CHOOSE0+pop->number].ob_width;
    pop->h=poptree[P_CHOOSE0+pop->number].ob_height;
  }
  else
  {
    pop->x=poptree[P_CHOOSE0].ob_x;
    pop->y=poptree[P_CHOOSE0].ob_y;
    pop->w=poptree[P_CHOOSE0].ob_width;
    pop->h=poptree[P_CHOOSE0].ob_height;
  }
  wind_update(BEG_UPDATE);
  wind_update(BEG_MCTRL);
  form_dial(FMD_START,0,0,0,0,poptree[ROOT].ob_x-5,poptree[ROOT].ob_y-5,poptree[ROOT].ob_width+10,poptree[ROOT].ob_height+10);
  objc_draw(poptree,ROOT,MAX_DEPTH,screenx,screeny,screenw,screenh);
}
/********************************************************************/
/* avinstallera popupen                                             */
/********************************************************************/
void deinit_popup(POPUP_DATA *pop)
{
  int counter=NOLL;

  form_dial(FMD_FINISH,0,0,0,0,poptree[ROOT].ob_x-5,poptree[ROOT].ob_y-5,poptree[ROOT].ob_width+10,poptree[ROOT].ob_height+10);
  wind_update(END_MCTRL);
  wind_update(END_UPDATE);
  /******************************************************************/
  /* Change the 0 terminated strings back to '|' terminated         */
  /******************************************************************/
  while(counter<pop->size)
  {
    if(pop->string[counter]==NOLL)
      pop->string[counter]='|';
    counter++;
  }
}
/********************************************************************/
/* open an "Free" Popup, not dependend on any resource object       */
/********************************************************************/
int freepopup(char *string,int selected, short x,short y,char *choice)
{
  OBJECT temp;
  char *pointer=string;
  temp.ob_next=FAIL;
  temp.ob_head=FAIL;
  temp.ob_tail=FAIL;
  temp.ob_type=G_BOX;
  temp.ob_x=x;
  temp.ob_y=y;

  xy[0]=xy[1]=0;
  
  while(*pointer!=0)
  {
    xy[0]++;
    pointer++;
    if(*pointer=='|' || *pointer==NOLL)
    {
      if(xy[0]>xy[1])
        xy[1]=xy[0];
      xy[0]=0;
    }
  }
  temp.ob_width=xy[1]*font_width;
  return popup(string, selected, &temp, ROOT, choice);

}
#endif
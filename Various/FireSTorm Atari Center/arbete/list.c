#include "list.h"
/********************************************************************/
/* sorting list by using Bubble-Sort :(((                           */
/********************************************************************/
void sort_list( MLIST *start,int (*compare)(const void *, const void *,const int),int sort_order,int sort_type)
{
  void *temp1,*temp2,*swap;
  int counter=0,sorted=0,result;

  swap=Malloc(start->sizeentity);
  if(!swap)
    return;
  while(!sorted)
  {
    sorted=1;
    counter=0;
    temp1=get_entity(start,counter);
    temp2=get_entity(start,counter+1);
    while(temp2!=NULL)
    {
      result=compare(temp1,temp2,sort_type);
      if(((result<0) && (sort_order==SORT_ORDER_UP))||((result>0) && (sort_order==SORT_ORDER_DOWN)))
      {
        memcpy(swap,temp1,start->sizeentity);
        memcpy(temp1,temp2,start->sizeentity);
        memcpy(temp2,swap,start->sizeentity);
        compare(temp1,temp2,sort_type);
        sorted=0;
      }
      counter++;
      temp1=get_entity(start,counter);
      temp2=get_entity(start,counter+1);
    }
  }
  Mfree(swap);
}
/********************************************************************/
/********************************************************************/
void free_list( MLIST **start )
{
  MLIST *temp = *start , *temp2 ;
  
  while( temp )
  {
    if( temp->data )
      Mfree( temp->data ) ;
    temp2 = temp ;
    temp = temp->next ;
    Mfree( temp2 ) ;
  }
  *start = NULL ;
}
/********************************************************************/
/********************************************************************/
void *get_entity( MLIST *start, long number)
{
   MLIST *temp = start;

  if(!temp)
  {
    return NULL;
  }
  while(number>=temp->size)
  {
    number-=temp->size;
    temp=temp->next;
    if(!temp)
    {
      return NULL;
    }
  }
  if(!temp->data)
  {
    return NULL;
  }
  if(number>=temp->used)
  {
    return NULL;
  }
  return ((temp->data)+number*temp->sizeentity);
}
/********************************************************************/
/********************************************************************/
void *new_entity( MLIST **start , size_t size, long num_alloc)
{
   MLIST *temp , *temp2 ;
   
  if(!*start)
  {
    *start=(MLIST *)Malloc(sizeof(MLIST));
    if(!*start)
    {
      return NULL;
    }
    memset(*start,0,sizeof(MLIST));
    (*start)->size=num_alloc;
    (*start)->sizeentity=size;
    (*start)->data=(void *)Malloc(num_alloc*size);
    if(!(*start)->data )
    {
      return NULL;
    }
    memset((*start)->data,0,num_alloc*size);
  }
  temp=*start;
  while(temp->next)
  {
    temp2=temp;
    temp=temp->next;
  }
  if(!temp->data)
  {
    temp->size=num_alloc;
    temp->used=0;
    temp->sizeentity=size;
    temp->data=(void *)Malloc(num_alloc*size);
    if(!temp->data)
    {
      return NULL;
    }
    memset(temp->data,0,num_alloc*size);
  }
  if(temp->used < temp->size)
  {
    return (temp->data)+(temp->used++)*temp->sizeentity;
  }

  temp->next=(MLIST *)Malloc(sizeof(MLIST));
  if(!temp->next)
  {
    return NULL;
  }
  memset(temp->next,0,sizeof(MLIST));
  temp=temp->next;
  temp->size=num_alloc;
  temp->sizeentity=size;
  temp->data=(void *)Malloc(num_alloc*size);
  if(!temp->data)
  {
    return NULL;
  }
  memset(temp->data,0,num_alloc*size);
  return (temp->data)+(temp->used++)*temp->sizeentity;
  
}
/********************************************************************/
/********************************************************************/
void del_entity( MLIST **start , long number )
{
  MLIST *temp = *start, *temp2=NULL;
  long number2 ;

  if( ! temp )
  {
    return ;
  }
  while( number >= temp->size )
  {
    number -= temp->size ;
    temp2=temp;
    temp = temp->next ;
    if( ! temp )
    {
      return ;
    }
  }
  if(!temp->data)
  {
    return ;
  }
  for( number2 = number+1; number2 < temp->used ; number2 ++ )
  {
    memcpy( (temp->data)+(number2-1)*temp->sizeentity, (temp->data)+number2*temp->sizeentity , temp->sizeentity);
  }
  temp->used -- ;
  if( temp->next )
    temp->size -- ;
  if(!temp->used && temp2)
  {
    if(temp->data)
      Mfree(temp->data);
    temp2->next=temp->next;
    Mfree(temp);
  }
}

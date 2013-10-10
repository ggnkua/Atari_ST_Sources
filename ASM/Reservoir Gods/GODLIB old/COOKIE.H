
typedef struct
{
 U32 cookie_id;
 U32 cookie_info;
} COOKIE_STRUCT;

U16 cookie_get_offset(U32 cookie_name);
U32 cookie_get_info(U16 cookie_offset);
void cookie_set_info(U32 cookie_name, U32 new_info);

U16 cookie_get_offset(U32 cookie_name)
{
 S16 i=0;
 COOKIE_STRUCT * c_ptr;

 c_ptr=*(COOKIE_STRUCT **)0x5A0;
 if(c_ptr)
 {
  while(c_ptr[i].cookie_id)
  {
   if(c_ptr[i++].cookie_id==cookie_name) return(i);
  }
 }
 return(0);
}

U32 cookie_get_info(U16 cookie_offset)
{
 COOKIE_STRUCT * c_ptr;

 c_ptr=*(COOKIE_STRUCT **)0x5A0;
 return(c_ptr[cookie_offset].cookie_info);
}

void cookie_set_info(U32 cookie_name, U32 new_info)
{
 S16 i;
 COOKIE_STRUCT * c_ptr;

 i=cookie_get_offset(cookie_name);
 c_ptr=*(COOKIE_STRUCT **)0x5A0; 
 if(i)
 {
   c_ptr[i-1].cookie_info=new_info;
 }
 else if(c_ptr!=0)
 {
  i=0;
  while(c_ptr[i].cookie_id!=0) i++;
  c_ptr[i].cookie_id=cookie_name;
  c_ptr[i].cookie_info=new_info;
 }
}

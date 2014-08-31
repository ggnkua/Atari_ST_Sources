
/*********************************************************************/
/*                                                                   */
/*     STinG : API and IP kernel package                             */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                          from 7. April 1997      */
/*                                                                   */
/*      Module for High Level Protocol releated calls                */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>

#include "globdefs.h"


typedef  struct cn_desc {
           int16           handle;
           void            *anonymous;
           CN_FUNCS        *funcs;
           struct cn_desc  *next_desc;
     } CN_DESC;


uint16         lock_exec (uint16 status);

PORT *         route_it (uint32 ip_destination, uint32 *gateway);

void *  cdecl  KRmalloc (int32 size);
void    cdecl  KRfree (void *mem_block);

int16          do_lookup (int16 connec, void **anonymous, CN_FUNCS **entry);
int16          handle_lookup (int16 connec, void **anonymous, CN_FUNCS **entry);
int16   cdecl  PRTCL_announce (int16 protocol);
int16   cdecl  PRTCL_get_parameters (uint32 rem_host, uint32 *src_ip, int16 *ttl, uint16 *mtu);
int16   cdecl  PRTCL_request (void *anonymous, CN_FUNCS *cn_functions);
void    cdecl  PRTCL_release (int16 handle);
void *  cdecl  PRTCL_lookup (int16 handle, CN_FUNCS *cn_functions);
int16   cdecl  TIMER_call (int16 cdecl handler (IP_DGRAM *), int16 flag);
int32   cdecl  TIMER_now (void);
int32   cdecl  TIMER_elapsed (int32 then);


extern CONFIG    conf;
extern IP_PRTCL  ip[];
extern int32     sting_clock;

CN_DESC  *cn_array[MAX_HANDLE];
int16    next_handle = 0;



int16  do_lookup (connec, anonymous, entry)

int16     connec;
void      **anonymous;
CN_FUNCS  **entry;

{
   CN_DESC  *walk;

   walk = cn_array[connec & (MAX_HANDLE - 1)];

   while (walk) {
        if (walk->handle == connec) {
             *anonymous = walk->anonymous;  *entry = walk->funcs;
             return (TRUE);
           }
        walk = walk->next_desc;
      }

   return (FALSE);
 }


int16  handle_lookup (connec, anonymous, entry)

int16     connec;
void      **anonymous;
CN_FUNCS  **entry;

{
   uint16  status;
   int16   result;

   status = lock_exec (0);
   result = do_lookup (connec, anonymous, entry);
   lock_exec (status);

   return (result);
 }


int16  cdecl  PRTCL_announce (protocol)

int16  protocol;

{
   int16  old_value;

   if (protocol <= 1 || 255 < protocol)
        return (E_PARAMETER);

   old_value = ip[protocol].active;
   ip[protocol].active = TRUE;

   return (old_value);
 }


int16  cdecl  PRTCL_get_parameters (rem_host, src_ip, ttl, mtu)

uint32  rem_host, *src_ip;
int16   *ttl;
uint16  *mtu;

{
   PORT  *port;

   if ((long) (port = route_it (rem_host, NULL)) <= 0)
        return (E_UNREACHABLE);

   if (src_ip)   *src_ip = port->ip_addr;
   if (ttl)      *ttl    = conf.ttl;
   if (mtu)      *mtu    = port->mtu;

   return (E_NORMAL);
 }


int16  cdecl  PRTCL_request (anonymous, cn_functions)

void      *anonymous;
CN_FUNCS  *cn_functions;

{
   CN_DESC   *new;
   CN_FUNCS  *cn_dummy;
   void      *ano_dummy;
   uint16    status;

   if ((new = (CN_DESC *) KRmalloc (sizeof (CN_DESC))) == NULL)
        return (-1);

   status = lock_exec (0);

   do {
        if (++next_handle == 32765)
             next_handle = 0;
     } while (do_lookup (next_handle, & ano_dummy, & cn_dummy) != 0);

   new->handle    = next_handle;
   new->anonymous = anonymous;
   new->funcs     = cn_functions;

   new->next_desc = cn_array[next_handle & (MAX_HANDLE - 1)];
   cn_array[next_handle & (MAX_HANDLE - 1)] = new;

   lock_exec (status);

   return (new->handle);
 }


void  cdecl  PRTCL_release (handle)

int16  handle;

{
   CN_DESC  *walk, **previous;
   uint16   status;

   status = lock_exec (0);

   walk = * (previous = & cn_array[handle & (MAX_HANDLE - 1)]);

   while (walk) {
        if (walk->handle == handle) {
             *previous = walk->next_desc;   KRfree (walk);
             break;
           }
        walk = * (previous = & walk->next_desc);
      }

   lock_exec (status);

   return;
 }


void *  cdecl  PRTCL_lookup (handle, cn_functions)

int16     handle;
CN_FUNCS  *cn_functions;

{
   void      *anonymous;
   CN_FUNCS  *entry;

   if (handle_lookup (handle, & anonymous, & entry) == 0)
        return (NULL);

   if (entry != cn_functions)
        return (NULL);
     else
        return (anonymous);
 }


int16  cdecl  TIMER_call (handler, flag)

int16  cdecl handler (IP_DGRAM *), flag;

{
   FUNC_LIST  *walk, *previous, *this, *prev_this;

   this = prev_this = previous = NULL;

   for (walk = conf.interupt; walk; walk = walk->next) {
        if (walk->handler == handler)
             this = walk,  prev_this = previous;
        previous = walk;
      }

   switch (flag) {
      case HNDLR_SET :
      case HNDLR_FORCE :
        if (this != NULL)   return (FALSE);
        if ((this = KRmalloc (sizeof (FUNC_LIST))) == NULL)
             return (FALSE);
        this->handler = handler;   this->next = conf.interupt;
        conf.interupt = this;
        return (TRUE);
      case HNDLR_REMOVE :
        if (this == NULL)   return (FALSE);
        if (prev_this)
             prev_this->next = this->next;
          else
             conf.interupt = this->next;
        KRfree (this);
        return (TRUE);
      case HNDLR_QUERY :
        return ((this) ? TRUE : FALSE);
      }

   return (FALSE);
 }


int32  cdecl  TIMER_now()

{
   return (sting_clock);
 }


int32  cdecl  TIMER_elapsed (then)

int32  then;

{
   int32  diff;

   if ((diff = sting_clock - then) >= 0)
        return (diff);
     else
        return (diff + 86400000L);
 }

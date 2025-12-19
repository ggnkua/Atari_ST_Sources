/*****************************************************************************
*
*                                  showprioq.c
*
*   from DKBTrace (c) 1990  David Buck
*
*  This file manages a priority queue for dump2iff
*
* This software is freely distributable. The source and/or object code may be
* copied or uploaded to communications services so long as this notice remains
* at the top of each file.  If any changes are made to the program, you must
* clearly indicate in the documentation and in the programs startup message
* who it was who made the changes. The documentation should also describe what
* those changes were. This software may not be included in whole or in
* part into any commercial package without the express written consent of the
* author.  It may, however, be included in other public domain or freely
* distributed software so long as the proper credit for the software is given.
*
* This software is provided as is without any guarantees or warranty. Although
* the author has attempted to find and correct any bugs in the software, he
* is not responsible for any damage caused by the use of the software.  The
* author is under no obligation to provide service, corrections, or upgrades
* to this package.
*
* Despite all the legal stuff above, if you do find bugs, I would like to hear
* about them.  Also, if you have any comments or questions, you may contact me
* at the following address:
*
*     David Buck
*     22C Sonnet Cres.
*     Nepean Ontario
*     Canada, K2H 8W7
*
*  I can also be reached on the following bulleton boards:
*
*     OMX              (613) 731-3419
*     Mystic           (613) 596-4249  or  (613) 596-4772
*
*  Fidonet:   1:163/109.9
*  Internet:  dbuck@ccs.carleton.ca
*  You Can Call Me Ray: (708) 358-5611
*
*
*****************************************************************************/


#include <stdio.h>
#include <exec/types.h>
#include "showprioq.h"
#include "dump2iff.h"
#include "dumproto.h"

char *malloc();


struct prioq_struct *pq_new (index_size, value_size)
  int index_size, value_size;
  {
  struct prioq_struct *pq;
  unsigned char *tmp_array;
  int i;

  if (index_size > 256)
    return (NULL);

  if ((pq = (struct prioq_struct *) malloc
        (sizeof (struct prioq_struct))) == NULL)
    return (NULL);

  if ((pq -> queue = (struct q_entry *)
                  malloc (index_size * sizeof (struct q_entry))) == NULL)  {
    free (pq);
    return (NULL);
    }
    
  if ((pq -> array = (unsigned char *) malloc (value_size)) == NULL) {
    free (pq -> queue);
    free (pq);
    return (NULL);
    }

  for (i=0, tmp_array = pq -> array ; i<value_size ; i++, tmp_array++)
    *tmp_array = 0;

  pq -> queue_size = index_size;
  pq -> array_size = value_size;
  pq -> current_entry = 0;
  return (pq);
  }

void pq_add (q, index, value)
  struct prioq_struct *q;
  unsigned int index, value;
  {
  unsigned int existing_entry;

  if (value >= q -> array_size)
    return;

  if ((existing_entry = pq_find_value(q, value)) != 0) {
    if ((q -> queue[existing_entry].index) < index)
      (q -> queue[existing_entry].index) = index;
    pq_balance (q, existing_entry);
    }
  else {
    q -> current_entry++;
    if (q -> current_entry >= q -> queue_size) {
      q -> current_entry--;
      q -> array [q->queue[q->current_entry].value] = 0;
      }

    q -> queue [q -> current_entry].index = index;
    q -> queue [q -> current_entry].value = value;
    q -> array [value] = q -> current_entry;
    pq_balance (q, q -> current_entry);
    }
  return;
  }
    
int pq_find_value (q, value)
  struct prioq_struct *q;
  unsigned int value;
  {
  if (value < q -> array_size)
    return ((int) q -> array[value]);
  else
    return (0);
  }

void pq_balance(q, entry_pos1)
  struct prioq_struct *q;
  unsigned int entry_pos1;
  {
  register struct q_entry *entry1, *entry2;
  register unsigned int tmp_index, tmp_value, entry_pos2;

  entry1 = &q->queue[entry_pos1];

  if ((entry_pos1 * 2 < q->queue_size)
      && (entry_pos1 * 2 <= q -> current_entry))
    {
    if ((entry_pos1*2+1 > q->current_entry) ||
        (q->queue[entry_pos1*2].index > q->queue[entry_pos1*2+1].index))
      entry_pos2 = entry_pos1*2;
    else
      entry_pos2 = entry_pos1*2+1;

    entry2 = &q->queue[entry_pos2];

    if (entry1->index < entry2->index) {
      q -> array [entry1->value] = entry_pos2;
      q -> array [entry2->value] = entry_pos1;

      tmp_index = entry1->index;
      entry1->index = entry2->index;
      entry2->index = tmp_index;

      tmp_value = entry1->value;
      entry1->value = entry2->value;
      entry2->value = tmp_value;

      pq_balance (q, entry_pos2);
      }
    }

  if (entry_pos1 / 2 >= 1 )
    {
    entry_pos2 = entry_pos1 / 2;
    entry2 = &q->queue[entry_pos2];
    if (entry1->index > entry2->index) {
      q -> array [entry1->value] = entry_pos2;
      q -> array [entry2->value] = entry_pos1;

      tmp_index = entry1->index;
      entry1->index = entry2->index;
      entry2->index = tmp_index;

      tmp_value = entry1->value;
      entry1->value = entry2->value;
      entry2->value = tmp_value;

      pq_balance (q, entry_pos2);
      }
    }
  }

int pq_get_highest_index(q)
  struct prioq_struct *q;
  {
  if (q -> current_entry >= 1)
    return ((int) q -> queue[1].index);
  else
    return (0);
  }

int pq_get_highest_value(q)
  struct prioq_struct *q;
  {
  if (q -> current_entry >= 1)
    return ((int) q -> queue[1].value);
  else
    return (0);
  }

void pq_delete_highest (q)
  struct prioq_struct *q;
  {
  q -> queue[1].index = q -> queue[q -> current_entry].index;
  q -> queue[1].value = q -> queue[q -> current_entry--].value;
  pq_balance (q, 1);
  }

void pq_free (q)
  struct prioq_struct *q;
  {
  free (q ->queue);
  free (q -> array);
  free (q);
  }

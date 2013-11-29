#include "extern.h"

static MULTI *first_multi, *multi_task;

/* --------------------
   | Start Multi-Task |
   -------------------- */
void start_slider(MULTI *adr)
{
adr->next = first_multi;
first_multi = adr;

ev_action |= MU_TIMER;
}

/* ------------------
   | Execute a task |
   ------------------ */
void do_task(void)
{
if (first_multi)
	{
	if (!multi_task)
		multi_task = first_multi;
		
	if ((*multi_task->task)())
		task_delete(multi_task);
	
	multi_task = multi_task->next;
	}
}

/* ---------------
   | Task cancel |
   --------------- */
void task_delete(MULTI *del_task)
{
MULTI **srch;

srch = (MULTI **)&first_multi;
if (*srch == del_task)
	*srch = del_task->next;

if (!first_multi)
	ev_action &= ~MU_TIMER;

set_options();
}
   
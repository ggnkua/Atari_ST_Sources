typedef struct {
Mtrk_start_ptr:	DS.L	1
Mtrk_event_end:	DS.L	1
Mtrk_curr_ptr:	DS.L	1
Mtrk_delta_time:DS.L	1
Mtrk_finished:	DS.W	1
Mtrk_Running_st:DS.W	1
Mtrk_curr_chan:	DS.W	1
		DS.W	1
} Track;

extern Track TrackInfo[16];
 
void ScanMidiFile(void)
{	unsigned char channel_first[16];
	int i;
	for (i=0 ; i <16 ; i++)
		channel_first[i] = 0;
	for (i=0 ; i < ntrks ; i++)
	{	unsigned char * ptr = &TrackInfo[i];
		 

	}


}

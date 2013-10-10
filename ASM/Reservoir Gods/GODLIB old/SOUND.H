U8 old_484;
U8 old_speaker;

void rlsd_open_sound();
void rlsd_close_sound();
U8 rlsd_toggle_internal_speaker();
void rlsd_internal_speaker_on();
void rlsd_internal_speaker_off();

void rlsd_open_sound()
{
	U8 * key_ptr;
    
	key_ptr=(U8 *)0x484L;
	old_484=*key_ptr;
	*key_ptr&=2;

	key_ptr=(U8 *)0xFFFF8800L;
	*key_ptr=14;
	old_speaker=*key_ptr;
	old_speaker&=0x40;
}


void rlsd_close_sound()
{
	U8 * key_ptr;
	key_ptr=(U8 *)0x484;
	*key_ptr=old_484;

	key_ptr=(U8 *)0xFFFF8800L;
	*key_ptr=14;
	old_speaker|=*key_ptr & 0xBF;
	key_ptr[2]=old_speaker;
}

U8 rlsd_toggle_internal_speaker()
{
 U8 sd;
 U8 * snd_ptr;

 snd_ptr=(U8 *)0xFFFF8800L;
 *snd_ptr=14;
 sd=*snd_ptr;
 sd^=0x40;
 snd_ptr[2]=sd;
 return((sd>>6)&1);
}

void rlsd_internal_speaker_off()
{
 U8 sd;
 U8 * snd_ptr;

 snd_ptr=(U8 *)0xFFFF8800L;
 *snd_ptr=14;
 sd=*snd_ptr;
 sd|=0x40;
 snd_ptr[2]=sd;
}

void rlsd_internal_speaker_on()
{
 U8 sd;
 U8 * snd_ptr;

 snd_ptr=(U8 *)0xFFFF8800L;
 *snd_ptr=14;
 sd=*snd_ptr;
 sd&=0xBF;
 snd_ptr[2]=sd;
}

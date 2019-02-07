/* midiview.c - a MIDI data display program 
   7/22/87 by J. Johnson 

   Original version compiled with Megamax C version 1.1
   This modified version compiled with Mark Williams C  

   (c) 1987 by Antic Publishing, Inc. */

#include <stdio.h>
#include <osbind.h>
#include <gemdefs.h>
/* #include <string.h> */ /* Used with Megamax C compiler */

#define note_string "CCDDEFFGGAAB" /* For data to note conversion */
#define MIDI 2 /* device number */
 
/* globals and arrays for GEM */
int intin[256], intout[256], ptsin[256];
int ptsout[256], contrl[12];
int handle, dummy;
int gr_mkmx, gr_mkmy; /* X & Y coordinates of mouse */
int gr_mkmstate, gr_mkkstate; /* mouse button and keyboard status */

int byte_num = 1; /* counter for two byte MIDI data fields */

struct iorec /* structure for MIDI buffer description */
{       char *ibuf;
        int ibufsize;
        int ibufhd;
        int ibuftl;
        int ibuflow;
        int ibufhigh;
};

/*            MAIN PROGRAM LOOP      */
main()
{       int midistat, midibyte, device;

        init_gem(); /* GEM initialization */
        midi_buffer(); /* move MIDI buffer & increase size */
        form_alert(1,"[0][MIDIVIEW - A MIDI Data Window|        By Jim Johnson|   Press Alternate to pause|      or Control to quit|][Let's go]");

        device = form_alert(1,"[2][ |Send output to..][Screen|Printer]");

        v_hide_c(handle); /* hide cursor */
        v_clrwk(handle); /* clear screen */
        clean_buffer(); /* clear out MIDI buffer */
        printf("Ready to accept MIDI data.\n");

        if (device == 2)
        {       printf("Output will go to printer.\n");
                freopen("PRN:","w",stdout);
        }

        /* Check for Esc and Control keys */
        gr_mkkstate = 0;
        while(gr_mkkstate != 4)
        {       graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);
                while(gr_mkkstate == 8)
                {       graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);
                }
                midistat = midi_status();
                if(midistat != 0)
                {       midibyte = from_midi();
                        print_midi(midibyte);
                }
        } 


        v_show_c(handle);
        appl_exit();
}
/*           FUNCTIONS          */

/* initialize GEM and application*/
init_gem()
{       int i;
        for(i = 0; i < 10; intin[i++]=1);
        intin[10] = 2;
        appl_init();
        handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
        v_opnvwk(intin, &handle, intout);
}

/* set up MIDI buffer */
midi_buffer()
{       char *malloc();
        unsigned size;
        long temp_pointer; /* temporary storage for pointers - 
                                                  must be type cast to pointer after
                                                  assignment */
        struct iorec *midi_buff; 
        size = 16384; /* 16K MIDI buffer */

        temp_pointer = Iorec(MIDI); /* pointer to buffer descriptor */
        midi_buff = (struct iorec *)temp_pointer; /* cast to pointer */
        (*midi_buff).ibuf = malloc(size); /* change address of buffer */
        (*midi_buff).ibufsize = size;     /* and size, too */
}

/* get MIDI byte */
from_midi()
{       int midibyte;
        midibyte = Bconin(3);
        midibyte &= 0x00ff;
        return(midibyte);
}

/* print midibyte */
print_midi(midibyte)
int midibyte;

{       char interpretation[40];
        static int index;
        interpret(midibyte,interpretation);
        printf("  %6d  %-4d      %s\n",++index,midibyte,interpretation);
        return;
}       

/* check midi status */
midi_status()
{       int midistat;
        midistat = Bconstat(3);
        if (midistat != 0)
                midistat = 1;
        return(midistat);
}

/* clean out MIDI buffer */
clean_buffer()
{       int midibyte, data_flag;
        data_flag = midi_status();
        while(data_flag == 1) 
                { from_midi();
                data_flag = midi_status();
                }
}

interpret(midibyte,interpretation)
int midibyte;
char *interpretation;
{       static int type;
        extern int byte_num;
        if (midibyte>127)
                type = num_to_status(midibyte,interpretation, type);
        else if (byte_num == 1)
        {       switch(type)
                {       case 0:
                                type_to_text(type,interpretation);
                                break;
                        case 1:
                        case 2:
                                num_to_note(midibyte,interpretation);
                                break;
                        case 3:
                                num_to_cc(midibyte,interpretation);
                                break;;
                        case 4:
                                type_to_text(type,interpretation);
                                break;
                        case 5:
                                num_to_pb(midibyte,interpretation);
                                break;
                        case 6:
                                num_to_spp(midibyte,interpretation);
                                break;
                }
        }
        else
        {       switch (type)
                {       case 0:
                        case 1:
                        case 2:
                        case 3:
                        case 4:
                                type_to_text(type,interpretation);
                                break;
                        case 5:
                                num_to_pb(midibyte,interpretation);
                                break;
                        case 6:
                                num_to_spp(midibyte,interpretation);
                                break;
                }
        }
        return;
}

/* convert MIDI status byte to text description */
num_to_status(midibyte,interpretation,old_type)
int midibyte, old_type;
char *interpretation;
{       char *int_string;
        int new_type;
        extern int byte_num;
        new_type = old_type;
        if (midibyte<240) 
        {       new_type = num_to_ch_mess(midibyte,interpretation,new_type);
                byte_num = 1;
        }
        else
        {       switch(midibyte)
                {       case 240:
                                int_string = "System Exclusive";
                                new_type = 4;
                                byte_num = 1;
                                break;
                        case 242:
                                int_string = "Song Position Pointer";
                                new_type = 6;
                                byte_num = 1;
                                break;
                        case 243:
                                int_string = "Song Select";
                                new_type = 4;
                                byte_num = 1;
                                break;
                        case 246:
                                int_string = "Tune";
                                new_type = 0;
                                break;
                        case 247:
                                int_string = "End of SysEx";
                                new_type = 0;
                                break;
                        case 248:
                                int_string = "Clock";
                                break;
                        case 250:
                                int_string = "Start";
                                break;
                        case 251:
                                int_string = "Continue";
                                break;
                        case 252:
                                int_string = "Stop";
                                break;
                        case 254:
                                int_string = "Active Sense";
                                break;
                        case 255:
                                int_string = "System Reset";
                                break;
                        default:
                                int_string = "Undefined";
                                new_type = 0;
                                break;
                }
        strcpy(interpretation,int_string);
        }
        return new_type;
}

/* convert MIDI byte to channel message description */
num_to_ch_mess(midibyte,interpretation,old_type)
int midibyte, old_type;
char *interpretation;
{       int top_nybble, channel, new_type;
        char chan_string[3], *int_string;
        new_type = old_type;
        top_nybble = ((midibyte & 112)/16);
        channel = (midibyte & 15)+1;
        switch (top_nybble)
        {       case 0:
                        int_string = "Note Off, Channel ";
                        new_type = 1;
                        break;
                case 1:
                        int_string = "Note On, Channel ";
                        new_type = 1;
                        break;
                case 2:
                        int_string = "Key Pressure, Channel ";
                        new_type = 2;
                        break;
                case 3:
                        int_string = "Control Change, Channel ";
                        new_type = 3;
                        break;
                case 4:
                        int_string = "Program Change, Channel ";
                        new_type = 4;
                        break;
                case 5:
                        int_string = "Channel Pressure, Channel ";
                        new_type = 2;
                        break;
                case 6:
                        int_string = "Pitch Bend, Channel ";
                        new_type = 5;
                        break;
        }
        strcpy(interpretation, int_string);
        itoa(channel,chan_string);
        strcat(interpretation,chan_string);
        return new_type;
}

/* convert MIDI data byte to text description */
type_to_text(number,text)
int number;
char *text;
{       char *string;
        extern int byte_num;
        switch(number)
        {       case 0:
                        string = "?";
                        break;
                case 1:
                        string = "Velocity";
                        byte_num = 1;
                        break;
                case 2:
                case 3:
                        string = "Value";
                        byte_num = 1;
                        break;
                case 4:
                        string = "Data";
                        break;
        }
        strcpy(text,string);
        return;
}

/* convert MIDI note number to Dr. T pitch notation */
                        /* data types 1 & 2 */
num_to_note(number,note)
int number;
char *note;
{       int octave, pitch;
        extern int byte_num;
        byte_num = 2; /* next byte is velocity value */
        *(note+3)='\0';
        octave=(number/12)-1;
        switch (octave)
        {       case -1:
                        *(note+2)='-';
                        break;
                default:
                        *(note+2)=octave+48;
                        break;
        } 
        pitch=number % 12;
        *note=note_string[pitch];
        switch (pitch) 
        {       case 1:
                case 3:
                case 6:
                case 8:
                case 10:
                        *(note+1)='#';
                        break;
                default:
                        *(note+1)=' ';
                        break;
        }
        return;
}


/* convert MIDI controller to text description */
                        /* data type 3 */
num_to_cc(number,controller)
int number;
char *controller;
{       char *string, *lsb;
        extern int byte_num;
        byte_num = 2;
        switch(number)
        {       case 1:
                case 33:
                        string = "Modulation Wheel";
                        break;
                case 2:
                case 34:
                        string = "Breath Controller";
                        break;
                case 3:
                case 35:
                        string = "DX7 Pressure";
                        break;
                case 4:
                case 36:
                        string = "Pedal";
                        break;
                case 5:
                case 37:
                        string = "Portamento Time";
                        break;
                case 6:
                case 38:
                        string = "Data Entry";
                        break;
                case 7:
                case 39:
                        string = "Volume";
                        break;
                case 8:
                case 40:
                        string = "Balance";
                        break;
                case 10:
                case 42:
                        string = "Pan";
                        break;
                case 11:
                case 43:
                        string = "Expression";
                        break;
                case 16:
                case 48:
                        string = "General Purpose #1";
                        break;
                case 17:
                case 49:
                        string = "General Purpose #2";
                        break;
                case 18:
                case 50:
                        string = "General Purpose #3";
                        break;
                case 19:
                case 51:
                        string = "General Purpose #4";
                        break;
                case 64:
                        string = "Sustain Switch";
                        break;
                case 65:
                        string = "Portamento Switch";
                        break;
                case 66:
                        string = "Sustenuto Switch";
                        break;
                case 67:
                        string = "Soft Pedal";
                        break;
                case 69:
                        string = "Hold Switch";
                        break;
                case 80:
                        string = "General Purpose #5";
                        break;
                case 81:
                        string = "General Purpose #6";
                        break;
                case 82:
                        string = "General Purpose #7";
                        break;
                case 83:
                        string = "General Purpose #8";
                        break;
                case 92:
                        string = "Tremolo";
                        break;
                case 93:
                        string = "Chorus";
                        break;
                case 94:
                        string = "Celeste";
                        break;
                case 95:
                        string = "Phase";
                        break;
                case 96:
                        string = "Data Increment";
                        break;
                case 97:
                        string = "Data Decrement";
                        break;
                case 98:
                        string = "Non-registered Parameter MSB";
                        break;
                case 99:
                        string = "Non-registered Parameter LSB";
                        break;
                case 100:
                        string = "Registered Parameter MSB";
                        break;
                case 101:
                        string = "Registered Parameter LSB";
                        break;
                case 122:
                        string = "Local Control";
                        break;
                case 123:
                        string = "All Notes Off";
                        break;
                case 124:
                        string = "Omni Off";
                        break;
                case 125:
                        string = "Omni On";
                        break;
                case 126:
                        string = "Mono On";
                        break;
                case 127:
                        string = "Poly On";
                        break;
                default:
                        string = "Unassigned Controller";
                        break;
        }
        strcpy(controller,string);
        if ((number > 31) && (number < 64))
        {       lsb = ", LSB";
                strcat(controller,lsb);
        }       
        return;
}

/* convert MIDI pitch bend to value */
                        /* data type 5 */
num_to_pb(number,value)
int number;
char *value;
{       extern int byte_num;
        char *string;
        static int pitch_bend;
        if (byte_num == 1)
        {       string = "    ";
                pitch_bend = number;
                byte_num = 2;
                strcpy(value,string);
        }
        else
        {       pitch_bend += 128*number;
                pitch_bend -= 8192;
                itoa(pitch_bend,value);
                byte_num = 1;
        }
        return;
}

/* convert MIDI song position pointer to text description */
                        /* data type 6 */
num_to_spp(number,pointer)
int number;
char *pointer;
{       extern int byte_num;
        int measure, beat, clock;
        static int spp;
        char *string, b[3], c[3], *colon; /* b$[3] and c$[3] in Megamax */
        colon = ":";
        if (byte_num == 1)
        {       string = "    ";
                spp = number;
                byte_num = 2;
                strcpy(pointer,string);
        }
        else
        {       spp += number*128;
                measure = (spp/16)+1;
                itoa(measure,pointer);
                beat = ((spp % 16)/4)+1;
                itoa(beat,b);
                clock = (6*((spp % 16) % 4)+1);
                itoa(clock,c);
                strcat(pointer,colon);
                strcat(pointer,b);
                strcat(pointer,colon);
                strcat(pointer,c);
                byte_num = 1;
        }
        return;
}

/* convert integer to string */
itoa(number, string)
char string[];
int number;
{ int i, sign;
        if ((sign = number) < 0 )
                number = -number;
        i = 0;
        do
        {       string[i++] = number % 10 + '0';
        }       while ((number /= 10) > 0);
        if (sign < 0)
                string[i++] = '-';
        string[i] = '\0';
        rev_string(string);
}

/* reverse string in place */
rev_string(string)
char string[];
{       int c, i, j;
        for (i = 0, j = strlen(string)-1; i < j; i++, j--)
        {       c = string[i];
                string[i] = string[j];
                string[j] = c;
        }
}       





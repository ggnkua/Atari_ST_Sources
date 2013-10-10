#ifndef __pattern_h__
#define __pattern_h__

// misc. defines /*fold00*/
#define NOTE_PLAY_PITCH(note) (note->val1)
#define NOTE_SLIDE_PITCH(note) (note->val1)
#define NOTE_SLIDE_ADD(note) (note->val2)
#define NOTE_VOICE_VOICE(note) (note->val2)
#define NOTE_LOOP_CNT(note) ((note->val2)>>16)

// define NOTE_* /*fold00*/
#define NOTE_END       0x0046
#define NOTE_PLAY      0x0050
#define NOTE_Q         0x0051
#define NOTE_STOP      0x0052
#define NOTE_SLIDE     0x0053
#define NOTE_VOICE     0x0056
#define NOTE_LOOPSTART 0x006C
#define NOTE_LOOPEND   0x004C

// struct note /*fold00*/
struct note{
   unsigned short cmd;
   unsigned short delay;
   unsigned long val1;
   unsigned long val2;
};


// struct channel /*fold00*/
struct channel{
   struct note *start;
   struct note *end;
   int pos;
   unsigned long pitch;
   unsigned short voice;

};

// struct patternheader /*fold00*/
struct pattern_header{
   char x[16];
};

#endif /*FOLD00*/


#include "sampleSequence.h"

//sample sequence data
// output, test sequence for channel 1
  sEvent testSequenceChannel1[]=
  {
  {0,24,0xAD},
  {16,25,0xAD},
  {32,26,0xAD},
  {64,27,0xAD},
  {96,28,0xAD},
  {128,29,0xAD},
  {16,31,0xAD},
  {32,32,0xAD},
  {64,33,0xAD},
  {96,34,0xAD},
  {128,35,0xAD},
  {16,37,0xAD},
  {32,38,0xAD},
  {64,39,0xAD},
  {96,40,0xAD},
  {0,0,0xAD}
};

// output test sequence for channel 2
 sEvent testSequenceChannel2[]=
 {
  {0,24,0xAD},
  {16,25,0xAD},
  {32,26,0xAD},
  {64,27,0xAD},
  {96,28,0xAD},
  {128,29,0xAD},
  {16,31,0xAD},
  {32,32,0xAD},
  {64,33,0xAD},
  {96,34,0xAD},
  {128,35,0xAD},
  {16,37,0xAD},
  {32,38,0xAD},
  {64,39,0xAD},
  {96,40,0xAD},
  {0,0,0xAD}
};

// output test sequence for channel 2
 sEvent testSequenceChannel3[]={
  {0,24,0xAD},
  {16,25,0xAD},
  {32,26,0xAD},
  {64,27,0xAD},
  {96,28,0xAD},
  {128,29,0xAD},
  {16,31,0xAD},
  {32,32,0xAD},
  {64,33,0xAD},
  {96,34,0xAD},
  {128,35,0xAD},
  {0,36,0xAD},
  {16,37,0xAD},
  {32,38,0xAD},
  {64,39,0xAD},
  {96,40,0xAD},
  {0,0,0xAD}
};

 sEvent *getTestSequenceChannel(const uint8 chNb)
 {
     switch(chNb)
     {
        case 0: return &testSequenceChannel1[0]; break;
        case 1: return &testSequenceChannel2[0]; break;
        case 2: return &testSequenceChannel3[0]; break;
        default: return 0;break;
     };
 }

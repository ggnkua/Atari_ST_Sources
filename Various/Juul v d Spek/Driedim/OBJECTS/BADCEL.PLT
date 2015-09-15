object badcel=


   object blok =

      object zijvlak=
       plane intern 0 0 0,
         .5  .5  0,
         .5  .5  1,
         .5 -.5  1,
         .5 -.5  0,
         .5  .5  0
       endplane
      obend;

      plane intern 0 0 0,
        .5  .5 1,
        .5 -.5 1,
       -.5 -.5 1,
       -.5  .5 1,
        .5  .5 1
      endplane;

      zijvlak;
      zijvlak turn 90;
      zijvlak turn 180;
      zijvlak turn 270
   obend;


   blok times 25  2 24    at .5   11 0;
   blok times  2 22 19.5  at 12 -0.5 0;
   blok times  2  8 19.5  at -3    6 0;
   blok times  8  2 19.5  at  7  -1  0
obend

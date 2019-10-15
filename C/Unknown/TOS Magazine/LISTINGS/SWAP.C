#ifdef __TURBOC__
    long Swap( long swp ) 0x4840;
#else

    #define Swap(swp)   ((long) ((unsigned long) spw >> 16) 
                        + ((long) swp << 16))
#endif


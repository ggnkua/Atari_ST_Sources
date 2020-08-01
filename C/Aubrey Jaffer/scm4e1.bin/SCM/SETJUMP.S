* setjmp on the Cray YMP does not save all registers.  Although this
* conforms to the ANSI standard, it is not sufficient for SCM garbage
* collection and continuations.
*
* This is a version of setjump for the Cray YMP that does save all non-
* temporary registers.  It might work for the XMP. It definitely will 
* not work on the Cray 2.  I do not know if the setjmp on the Cray 2 will
* work with SCM or not.
*
* This has been tested under Unicos 6.1.
*
* --Radey Shouman <rshouman@chpc.utexas.edu>
*
            IDENT           SETJUMP
            ENTRY           setjump
setjump     =               *
            A1              1,A6
            A2              56
            A0              A1
            ,A0             T00,A2
            A0              A1+A2
            ,A0             B00,A2
            S1              0
            J               B00
*
            ENTRY           longjump
longjump    =               *
            A1              1,A6
            A0              A1
            A2              56
            T00,A2          ,A0
            A0              A1+A2
            B00,A2          ,A0
            S1              2,A6
            J               B00
            END 
** Local Variables:
** tab-stop-list: (12 28 45)
** indent-tabs-mode: nil
** End:

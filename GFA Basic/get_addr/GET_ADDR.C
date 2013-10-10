/*                                                                      */
/*      C source for function to detemine the runtime address of        */
/*      a GFA Basic procedure or function.                              */
/*                                                                      */
/*      By Peter Kocourek, January 16, 1992                             */
/*      Please refer to the text file accompanying this code            */
/*                                                                      */
/*      For PureC, compile with option -B (Generate standard object)    */
/*      and switch off -A (ANSI keywords only)                          */

/*      First, declare prototype for the GFA function you want to get   */
/*      the address of. The GFA compiler adds the underscore and        */
/*      converts the name of the procedure to uppercase.                */
/*      Actually, only the first 8 characters will survive in the       */
/*      object file, but this way it is clearer for the programmer.     */

extern void cdecl _EXTREMELY_LONG_NAME(void); 

/*      Now, declare prototype of the C function in this module.        */
/*      This isn't strictly necessary, but it can't hurt.               */
/*      And use cdecl calling for use of stack; other compilers may not */
/*      have this option. You can just leave it out.                    */

long cdecl get_addr(void);

/*      Now the function itself. All it does is it returns the address  */
/*      as a long (32 Bits)                                             */

long cdecl get_addr(void)
{
        return ((long) _EXTREMELY_LONG_NAME);
        
}

/*      And that's all folks!                                           */

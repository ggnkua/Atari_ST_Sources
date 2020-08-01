#if 0
+----------------------------------------------------------------------+
|   Question: My filter design package gives me decimal fractional     |
|             numbers  as output  for my  FIR filter coefficients.     |
|             How  do I convert  these decimal fractions  into the     |
|             DSP56200's format?                                       |
+----------------------------------------------------------------------+

      Answer:
           It's fairly easy to convert decimal fractions into  the
      data  format required by the DSP56200.  The DSP56200 coeffi-
      cients are represented as  24-bit  signed,  fractional,  2's
      complement numbers as shown in Table 1.

         TABLE 1 - Representations for FIR Filter Coefficients
         -----------------------------------------------------

          Decimal                                  Hexadecimal
          Fraction       24-Bit Binary Value       Coefficient
          --------       -------------------       ----------

            0.75     0.1100000 00000000 00000000    60 00 00
            0.5      0.1000000 00000000 00000000    40 00 00
            0.25     0.0100000 00000000 00000000    20 00 00
            0.125    0.0010000 00000000 00000000    10 00 00
           -0.125    1.1110000 00000000 00000000    F0 00 00
           -0.75     1.0100000 00000000 00000000    A0 00 00

      Each  24-bit  coefficient  is  separated  into  three  bytes
      corresponding  to the high, middle, and low bytes.  The high
      byte is written to the DSP56200 at  address  0A  (hex),  the
      middle byte to address 0B (hex), and the low byte to address
      0C (hex).

      Conversion Procedure:

         Step 1:  Multiply the decimal fraction by 8388608.0 (decimal).
                  Note that 8388608 = 2 raised to the 23rd power.
         Step 2:  Truncate or round the result into an integer.
         Step 3:  Logically AND this integer with 00FFFFFF (hex).
         Step 4:  Write the result to an output file as a hex integer.

      It is easy to write a program to perform this conversion  on
      a  set  of  coefficients.  If done by computer program, make
      sure that all integer  variables  are  represented  with  at
      least  24-bits.   An  example  of  a  short  "C"  program is
      included at the end of this answer.

      Things to watch for:

         (1) Avoid letting a coefficient value be exactly 800000
             (-1.0 in a fractional system).  If this coefficient
             is multiplied by a data sample with value -1.0, the
             result is -1.0 instead of +1.0 as expected. This is
             because +1.0 cannot be represented in a signed, 2's
             complement, fractional system.

         (2) The filter coefficients must  be carefully selected
             to prevent overflow.   If there is a possibility of
             overflow with a set of filter coefficients, then all
             coefficients must be scaled by a constant value. The
             DSP56200's 24-bit coefficients  allow plenty of room
             for scaling.   If 12-bit input data samples are used
             in a system,  the potential  for overflow is greatly
             reduced if the samples are right justified and sign-
             extended four bits before they are sent to the 
             DSP56200.

"C" Program:
#endif
           /****************************************\
           **  DECIMAL FRACTION TO HEX CONVERSION  **
           \****************************************/

/******************************************************************\
*  This program converts one decimal, fractional number to a hex   *
*  number which can be written to the DSP56200's Coefficient RAM   *
*  Access registers.  It prompts the user for a decimal fraction   *
*  and returns the corresponding hex number.                       *
*                                                                  *
*   Examples of Program Results (useful for checking programs)     *
*        Inputs                    Outputs                         *
*        ------                    -------                         *
*         0.750                =>  600000                          *
*         0.500                =>  400000                          *
*         0.250                =>  200000                          *
*         0.125                =>  100000                          *
*        -0.125                =>  f00000                          *
*        -0.750                =>  a00000                          *
*         0.00784313678741455  =>  010101                          *
*        -0.00784313678741455  =>  fefeff                          *
*                                                                  *
*   Note: The program assumes that the variable type "long" is an  *
*         integer which is at least 24-bits wide.                  *
*                                                                  *
*   Also: The DSP56200 cannot  use any coefficient value with a    *
*         magnitude of 1.0 or larger.  All coefficients must be    *
*         signed, fractional quantities.                           *
\******************************************************************/

main()
{
           double fractnum;              /* double precision floating pt */
           long   hexval;                /* long integer */

    for(;;) {
        /* Read 1 Decimal Floating Point Number from the Keyboard */
           printf("Enter the decimal fraction: ");
           scanf("%lf", &fractnum);

        /* Convert to a Hex Integer which can be used by the DSP56200 */
           hexval =  (long) (8388608.0 * fractnum);
           hexval =  0x00ffffffL & hexval;

        /* Write the Hex number out to the Terminal */
           printf("DSP56200 Coefficient = %06lx\n", hexval);
    }
}

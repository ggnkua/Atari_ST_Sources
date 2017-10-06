/**************************************************************************
 * RCEQUAL.C - Return TRUE/FALSE indicating rectangles are EQUAL/NOTEQUAL.
 *************************************************************************/

int rc_equal(prect1, prect2)
    long *prect1;
    long *prect2;
{
    if (*prect1++ == *prect2++) {
        if (*prect1 == *prect2) {
            return 1;
        }
    }
    return 0;
}

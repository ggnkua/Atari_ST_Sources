#define AV_SENDCLICK       0x4709;

msg[0] = AV_SENDCLICK  /* 0x4709 */
msg[1] = ap_id;
msg[2] = 0;
msg[3] = ev_mmox;
msg[4] = ev_mmoy;
msg[5] = ev_mmobutton;
msg[6] = ev_mmokstate;
msg[7] = ev_mbreturn;


AV_SENDCLICK will be sent, if the bubble was closed by clicking (as 
opposed bursting bubbles by releasing the mouse button!). AV_SENDCLICK 
is the counterpart to AV_SENDKEY.


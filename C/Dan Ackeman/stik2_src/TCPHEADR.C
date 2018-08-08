	/* Now will try some header prediction to see
	   what we get from it.  Should be some boost 
	   This code could be shrunk down to one big test
	   I'm splitting up now while I get it working */
	   
	if (tcb->state == TESTABLISH)
	{
		/* Ok we are established that's the first rule */

		if(tcph->f_ack)
		{			
			/* We have an ACK, that's the second rule */
					
			if (!(tcph->f_syn) && 
				!(tcph->f_fin) &&
				!(tcph->f_rst) &&
				!(tcph->f_urg))
				 {
					/* We don't have a SYN, FIN, RST or URG, that's part of rule 2 */

					/* We don't have TIMESTAMPS yet, so I'll skip that bit which is rule 3*/
							
					if (tcph->seq == tcb->rcv.nxt)
					{
						/* The sequence is the one we are expecting that's rule 4 */
						
						if ((tcph->window) && (tcph->window == tcb->snd.wnd))
						{
							/* we have a non zero window and it hasn't changed - rule 5 */
							
							if (tcb->snd.ptr == tcb->snd.nxt)
							{
								/* our last transmission wasn't a retranmission - rule 6 */
							
								/* Our next step would be processing the timestamp
									we don't have one so we will skip it */
									
								/* Now test for a Pure ACK */
								
								if (p->dlen == 0)
								{
									/* There is no data in the packet */
								
									if ((tcph->ack > tcb->snd.una) &&
										(tcph->ack < tcb->snd.ptr) &&
										(tcb->cwind >= tcb->snd.wnd))
										{
											/* acknowledgment is greater than largest unacknowledged,
											   acknowledgement is less or equal to largest sent,
											   and congestion window is larger or equal to send window */
											
											/* update the round trip timer */
										
											/* Round trip timer good candidate to be it's own routine 
												It's a few places in the code*/
											
										    /* Round trip time estimation */
										    if (tcb->rtt_run && seq_ge(tcph->ack,tcb->rttseq)) 
										    {
										        /* A timed sequence number has been acked */
										        tcb->rtt_run = 0;
										        if (!(tcb->retran)) {
										            clock_t rtt;    /* measured round trip time */
										            clock_t abserr; /* abs(rtt - srtt) */

										            /* This packet was sent only once and now
										             * it's been acked, so process the round trip time
										             */
										            rtt = msclock() - tcb->rtt_time;

										            abserr = (rtt > tcb->srtt) ? rtt - tcb->srtt : tcb->srtt - rtt;
										            /* Run SRTT and MDEV integrators, with rounding */
										            tcb->srtt = ((AGAIN-1)*tcb->srtt + rtt + (AGAIN/2)) >> LAGAIN;
										            tcb->mdev = ((DGAIN-1)*tcb->mdev + abserr + (DGAIN/2)) >> LDGAIN;

										            rtt_add(((IP_HDR *)p->pip)->s_ip, rtt);
										            /* Reset the backoff level */
										            tcb->backoff = 0;
											        }
											 }

										    acked = (int16)(tcph->ack - tcb->snd.una);
											
											/* delete acknowledged bytes from buffer */

										    tcb->sndcnt -= acked;   /* Update virtual byte count on snd queue */
										    tcb->snd.una = tcph->ack;

										    /* Remove acknowledged bytes from the send queue and update the
										     * unacknowledged pointer. If a FIN is being acked,
										     * pullup won't be able to remove it from the queue, but that
										     * causes no harm.
										     */

										    obtrim(tcb->outq, acked);
											
											/* stop retransmit timer */

										    /* Stop retransmission timer, but restart it if there is still
										     * unacknowledged data. If there is no more unacked data,
										     * the transmitter has gone at least momentarily idle, so
										     * record the time for the VJ restart-slowstart rule.
										     */
										    tcb->timer_e = (clock_t)0;
										
										    if(tcb->snd.una != tcb->snd.nxt)
										        tcb->timer_e = set_time(tcb->timer_d);
										    else
										        tcb->lastactive = msclock();

											
											/* We don't do wakeups */
											
											/* Generate more output */
											if (tcb->outq->cnt)
												{
													tcp_output(cn);
												}
																					
											return;
										}
									else if ((tcph->ack == tcb->snd.una) &&
											(tcb->pq == GPNULL))
										{
											/* ACK acknowledges largest unacknowledged &&
											   There are no out of order packets
												BSD would check for space here we don't/can't
												but will find out momentarily */
											   
											/* This is a pure, in-sequence data packet
											   with nothing on the reassembly queue */

							                tcb->rcv.nxt += p->dlen;
							                tcb->rcv.wnd -= p->dlen;

							                tcb->send_ack = TRUE;

							                q_tcp_in(cn, p);								   
											
											return;				
										}
								}
								
							}								
						}
					}
				}			
		}
	} /* End of header prediction code */
		
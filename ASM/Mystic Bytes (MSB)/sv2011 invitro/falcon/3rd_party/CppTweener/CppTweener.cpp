/*****************

 Wesley Ferreira Marques - wesley.marques@gmail.com 
 http://codevein.com
 
 This port was based in a inital code from Jesus Gollonet, him port Penners easing equations to C/C++:

 http://www.jesusgollonet.com/blog/2007/09/24/penner-easing-cpp/
 http://robertpenner.com/easing/

 I´m just make a better wrapper a litlle more OOP e put some callbacks like the original Tweener
 (http://code.google.com/p/tweener/)





 **********************/
#include "CppTweener.h"
namespace tween {
	/***** LINEAR ****/
	float Linear::easeNone (float t,float b , float c, float d) {
		return c*t/d + b;
	}
	float Linear::easeIn (float t,float b , float c, float d) {
		return c*t/d + b;
	}
	float Linear::easeOut(float t,float b , float c, float d) {
		return c*t/d + b;
	}

	float Linear::easeInOut(float t,float b , float c, float d) {
		return c*t/d + b;
	}

	/***** SINE ****/

	float Sine::easeIn (float t,float b , float c, float d) {
		return -c * cos(t/d * (PI/2)) + c + b;
	}
	float Sine::easeOut(float t,float b , float c, float d) {
		return c * sin(t/d * (PI/2)) + b;
	}

	float Sine::easeInOut(float t,float b , float c, float d) {
		return -c/2 * (cos(PI*t/d) - 1) + b;
	}

	/**** Quint ****/

	float Quint::easeIn (float t,float b , float c, float d) {
		return c*(t/=d)*t*t*t*t + b;
	}
	float Quint::easeOut(float t,float b , float c, float d) {
		return c*((t=t/d-1)*t*t*t*t + 1) + b;
	}

	float Quint::easeInOut(float t,float b , float c, float d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
		return c/2*((t-=2)*t*t*t*t + 2) + b;
	}

	/**** Quart ****/
	float Quart::easeIn (float t,float b , float c, float d) {
		return c*(t/=d)*t*t*t + b;
	}
	float Quart::easeOut(float t,float b , float c, float d) {
		return -c * ((t=t/d-1)*t*t*t - 1) + b;
	}

	float Quart::easeInOut(float t,float b , float c, float d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
		return -c/2 * ((t-=2)*t*t*t - 2) + b;
	}

	/**** Quad ****/
	float Quad::easeIn (float t,float b , float c, float d) {
		return c*(t/=d)*t + b;
	}
	float Quad::easeOut(float t,float b , float c, float d) {
		return -c *(t/=d)*(t-2) + b;
	}

	float Quad::easeInOut(float t,float b , float c, float d) {
		if ((t/=d/2) < 1) return ((c/2)*(t*t)) + b;
		return -c/2 * (((t-2)*(--t)) - 1) + b;
		/*
		 originally return -c/2 * (((t-2)*(--t)) - 1) + b;

		 I've had to swap (--t)*(t-2) due to diffence in behaviour in
		 pre-increment operators between java and c++, after hours
		 of joy
		 */

	}

	/**** Expo ****/

	float Expo::easeIn (float t,float b , float c, float d) {
		return (t==0) ? b : c * pow(2, 10 * (t/d - 1)) + b;
	}
	float Expo::easeOut(float t,float b , float c, float d) {
		return (t==d) ? b+c : c * (-pow(2, -10 * t/d) + 1) + b;
	}

	float Expo::easeInOut(float t,float b , float c, float d) {
		if (t==0) return b;
		if (t==d) return b+c;
		if ((t/=d/2) < 1) return c/2 * pow(2, 10 * (t - 1)) + b;
		return c/2 * (-pow(2, -10 * --t) + 2) + b;
	}


	/****  Elastic ****/

	float Elastic::easeIn (float t,float b , float c, float d) {
		if (t==0) return b;  if ((t/=d)==1) return b+c;
		float p=d*.3f;
		float a=c;
		float s=p/4;
		float postFix =a*pow(2,10*(t-=1)); // this is a fix, again, with post-increment operators
		return -(postFix * sin((t*d-s)*(2*PI)/p )) + b;
	}

	float Elastic::easeOut(float t,float b , float c, float d) {
		if (t==0) return b;  if ((t/=d)==1) return b+c;
		float p=d*.3f;
		float a=c;
		float s=p/4;
		return (a*pow(2,-10*t) * sin( (t*d-s)*(2*PI)/p ) + c + b);
	}

	float Elastic::easeInOut(float t,float b , float c, float d) {
		if (t==0) return b;  if ((t/=d/2)==2) return b+c;
		float p=d*(.3f*1.5f);
		float a=c;
		float s=p/4;

		if (t < 1) {
			float postFix =a*pow(2,10*(t-=1)); // postIncrement is evil
			return -.5f*(postFix* sin( (t*d-s)*(2*PI)/p )) + b;
		}
		float postFix =  a*pow(2,-10*(t-=1)); // postIncrement is evil
		return postFix * sin( (t*d-s)*(2*PI)/p )*.5f + c + b;
	}

	/****  Cubic ****/
	float Cubic::easeIn (float t,float b , float c, float d) {
		return c*(t/=d)*t*t + b;
	}
	float Cubic::easeOut(float t,float b , float c, float d) {
		return c*((t=t/d-1)*t*t + 1) + b;
	}

	float Cubic::easeInOut(float t,float b , float c, float d) {
		if ((t/=d/2) < 1) return c/2*t*t*t + b;
		return c/2*((t-=2)*t*t + 2) + b;
	}

	/*** Circ ***/

	float Circ::easeIn (float t,float b , float c, float d) {
		return -c * (sqrt(1 - (t/=d)*t) - 1) + b;
	}
	float Circ::easeOut(float t,float b , float c, float d) {
		return c * sqrt(1 - (t=t/d-1)*t) + b;
	}

	float Circ::easeInOut(float t,float b , float c, float d) {
		if ((t/=d/2) < 1) return -c/2 * (sqrt(1 - t*t) - 1) + b;
		return c/2 * (sqrt(1 - t*(t-=2)) + 1) + b;
	}

	/****  Bounce ****/
	float Bounce::easeIn (float t,float b , float c, float d) {
		return c - easeOut (d-t, 0, c, d) + b;
	}
	float Bounce::easeOut(float t,float b , float c, float d) {
		if ((t/=d) < (1/2.75f)) {
			return c*(7.5625f*t*t) + b;
		} else if (t < (2/2.75f)) {
			float postFix = t-=(1.5f/2.75f);
			return c*(7.5625f*(postFix)*t + .75f) + b;
		} else if (t < (2.5/2.75)) {
			float postFix = t-=(2.25f/2.75f);
			return c*(7.5625f*(postFix)*t + .9375f) + b;
		} else {
			float postFix = t-=(2.625f/2.75f);
			return c*(7.5625f*(postFix)*t + .984375f) + b;
		}
	}

	float Bounce::easeInOut(float t,float b , float c, float d) {
		if (t < d/2) return easeIn (t*2, 0, c, d) * .5f + b;
		else return easeOut (t*2-d, 0, c, d) * .5f + c*.5f + b;
	}

	/**** Back *****/

	float Back::easeIn (float t,float b , float c, float d) {
		float s = 1.70158f;
		float postFix = t/=d;
		return c*(postFix)*t*((s+1)*t - s) + b;
	}
	float Back::easeOut(float t,float b , float c, float d) {
		float s = 1.70158f;
		return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
	}

	float Back::easeInOut(float t,float b , float c, float d) {
		float s = 1.70158f;
		if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525f))+1)*t - s)) + b;
		float postFix = t-=2;
		return c/2*((postFix)*t*(((s*=(1.525f))+1)*t + s) + 2) + b;
	}


	//implementation Tweener Class*********************************************************

        float Tweener::runEquation(int transition,int equation, float t,float b , float c, float d) {

			float result;
			if (equation == EASE_IN) {
				result = funcs[transition]->easeIn(t,b,c,d);
			} else if (equation == EASE_OUT) {
				result = funcs[transition]->easeOut(t,b,c,d);
			} else if (equation == EASE_IN_OUT) {
				result = funcs[transition]->easeInOut(t,b,c,d);
			}

			return result;
		}

		void Tweener::dispatchEvent(TweenerParam *param, short eventType) {

			for (unsigned int i = 0; i < listeners.size(); i++ ) {
				listenerIT = listeners.begin();
				TweenerListener *listener = *listenerIT;
				switch(eventType) {
					case ON_START:
						listener->onStart(*param);
						break;
					case ON_STEP:
						listener->onStep(*param);
						break;
					case ON_COMPLETE:
						listener->onComplete(*param);
						break;
					default:
					//	std::cout<<"Event not found!!";
						break;
				}


			}
		}


        void Tweener::addTween(TweenerParam& param) {
			param.timeCount = 0;
            if (param.delay > 0){
              param.delayFinished = false;
            }
            if (param.total_properties > 0) {
                for (int i =0 ; i < param.total_properties; i++ ) {
                    TweenerProperty prop = param.properties[i];
                    param.properties[i].initialValue = *(prop.ptrValue);

                }
            }
			//std::cout<<" \nParam: props"<< (param).total_properties  << " time" << (param).time;

			tweens.push_back(param);
			total_tweens = tweens.size();

		}

		void Tweener::removeTween(TweenerParam  *param) {

			total_tweens = tweens.size();
			tweensIT = tweens.begin();
			for (int i=0; i <  total_tweens; i++,tweensIT++) {
				if ((*param) == (*tweensIT)) {
					(*tweensIT).cleanProperties();
					tweens.erase(tweensIT);
					//std::cout<<"\n-Tween Removed";
					--total_tweens;
					break;
				}
			}

		}
	
	
		
	

		void Tweener::addListener(TweenerListener *listener) {
			listeners.push_back(listener);
		}


		void Tweener::removeListener(TweenerListener *listener) {
			for (listenerIT = listeners.begin(); listenerIT != listeners.end(); ++listenerIT ) {
			  if (listener == (*listenerIT) ) {
					//std::cout<< "\n-Listener removed";
					listeners.erase(listenerIT);
					listenerIT = listeners.begin();
					break;
				}
			}
		}
		void Tweener::setFunction(short funcEnum) {
			if (funcEnum > -1 && funcEnum <=11) {
				currentFunction = funcEnum;
			}
		};

		void Tweener::step(long currentMillis) {
			//fix thanks for Etienne Mouchel
			if(lastTime == 0)
				lastTime = currentMillis;
			
			total_tweens = tweens.size();
			int t = 0 ;
			int d = 0;
			int  dif = (currentMillis - lastTime);

			for (tweensIT = tweens.begin();  tweensIT != tweens.end(); ++tweensIT ) {

				if (!(*tweensIT).started) {
					dispatchEvent(&(*tweensIT), ON_START);
					(*tweensIT).started = true;
				
				}

				dispatchEvent(&(*tweensIT), ON_STEP);
				if ((*tweensIT).onStepCallBack){
					(*tweensIT).onStepCallBack();					
				}	

				if ((*tweensIT).useMilliSeconds == true) {
					((*tweensIT).timeCount)+=dif;
					t = (*tweensIT).timeCount ;
				} else {
					((*tweensIT).timeCount)++;
					t =(*tweensIT).timeCount;
				}

				if ( (*tweensIT).delayFinished ) {
                    d = (*tweensIT).time ;
                    if ( t < d  && (*tweensIT).total_properties > 0 ) {

                        if ((*tweensIT).timeCount < (*tweensIT).time  ) {
                            for (unsigned int i =0 ; i < (*tweensIT).total_properties; i++ ) {
                                TweenerProperty prop = (*tweensIT).properties[i];
                                if (prop.ptrValue != 0 ) {

                                    float  res   = runEquation(
                                                               (*tweensIT).transition,
                                                               (*tweensIT).equation,
                                                               t,
                                                               prop.initialValue,
                                                               (prop.finalValue - prop.initialValue ),
                                                               d);

                                    *(prop.ptrValue) = res;
                                }
                            }
                        }

                    } else {
						if ((*tweensIT).decreaseRepeat() < 0 ) {
							//garante o valor final
							/*for (unsigned int i =0 ; i < (*tweensIT).total_properties; i++ ) {
                                TweenerProperty prop = (*tweensIT).properties[i];
                                if (prop.ptrValue != NULL ) {
									*(prop.ptrValue) = prop.finalValue;
								}
                            }*/
							dispatchEvent(&(*tweensIT), ON_COMPLETE);							
							if ((*tweensIT).onCompleteCallBack){
								(*tweensIT).onCompleteCallBack();
								(*tweensIT).onCompleteCallBack = 0;
								(*tweensIT).onStepCallBack = 0;
							}	
							removeTween(&(*tweensIT));
							tweensIT = tweens.begin();
							if(total_tweens == 0) //if the tweener is empty again this way for the next param adding the dif won't be huge and it won't skip the tweening
								lastTime = 0;
						} 
	
                        

                    }
				} else  if ((!(*tweensIT).delayFinished) && ((*tweensIT).timeCount > (*tweensIT).delay)) {
                     (*tweensIT).delayFinished = true;
                     (*tweensIT).timeCount = 0;
                }

			}
			if(lastTime != 0)
				lastTime = currentMillis;

		};

}

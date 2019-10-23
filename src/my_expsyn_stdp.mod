COMMENT
Two state kinetic scheme synapse described by rise time tau1,
and decay time constant tau2. The normalized peak condunductance is 1.
Decay time MUST be greater than rise time.

The solution of A->G->bath with rate constants 1/tau1 and 1/tau2 is
 A = a*exp(-t/tau1) and
 G = a*tau2/(tau2-tau1)*(-exp(-t/tau1) + exp(-t/tau2))
	where tau1 < tau2

If tau2-tau1 -> 0 then we have a alphasynapse.
and if tau1 -> 0 then we have just single exponential decay.

The factor is evaluated in the
initial block such that an event of weight 1 generates a
peak conductance of 1.

Because the solution is a sum of exponentials, the
coupled equations can be solved as a pair of independent equations
by the more efficient cnexp method.

ENDCOMMENT

NEURON {
	POINT_PROCESS MyExpSynSTDP
	RANGE tau, e, i, g, gmax, d, p, dtau, ptau, dW, sh, rest_width, wmax, wmin, isHebb, pre_spike_num, post_spike_num, maximum_spike_num
	NONSPECIFIC_CURRENT i
}

UNITS {
	(nA) = (nanoamp)
	(mV) = (millivolt)
	(uS) = (microsiemens)
}

PARAMETER {
	tau=.1 (ms) <1e-9,1e9>
	e=0	(mV)
	gmax = 1e9 (uS)
	
	d = 0.0053 <0,1>: depression factor (multiplicative to prevent < 0)
	p = 0.0096 : potentiation factor (additive, non-saturating)
	dtau = 34 (ms) : depression effectiveness time constant
	ptau = 17 (ms) : Bi & Poo (1998, 2001)
	dW = 1 : readout value
	
	rest_width = 0.1 (ms) : for baseline  
	sh = 0 : curve shift
	wmax = 1 : Maximum Bound
	wmin = -1 : Minimum Bound
	isHebb = 1 : is Hebbian or Anti-Hebbian
	pre_spike_num = 0
	post_spike_num = 0
	maximum_spike_num = 3

}

ASSIGNED {
	v (mV)
	i (nA)
	
	tpost (ms)	
}

STATE {
	g (uS)
}

INITIAL {

	g = 0
	dW = 0 : readout value
	
	tpost = -1e9
	net_send(0, 1)
}

BREAKPOINT {
	SOLVE state METHOD cnexp
	i = gmax*g*(v - e)
}

DERIVATIVE state {
	g' = -g/tau
}

FUNCTION abs(x) {
	if (x < 0) {
		abs = x*-1
	} else {
		abs = x
	}
}
FUNCTION stdp_factor(Dt (ms), nw) { : Dt is interval between most recent presynaptic spike
    : and most recent postsynaptic spike
    : calculated as tpost - tpre (i.e. > 0 if pre happens before post)
  : the following rule is the one described by Bi & Poo
  :printf("t = %f,  Dt = %f, now W = %f\n", t, Dt,nw) 
	
  if (Dt > rest_width*-1 && Dt < rest_width ) {
	stdp_factor = 0 : no change if pre and post are simultaneous
	:printf("no change if pre and post are simultaneous (for baseline case)\n")
  } else if (Dt>0) {
    stdp_factor = p*abs(wmax-nw)*exp(-Dt/ptau) : potentiation
	:printf("the case of LTP\n")
  } else if (Dt<0) {
    stdp_factor = -1*d*abs(nw-wmin)*exp(Dt/dtau) : depression
	:printf("the case of LTD\n")
  } else {
	:printf("no change if pre and post are simultaneous (dt = 0)\n")
    stdp_factor = 0 : no change if pre and post are simultaneous
  }
}

: Anti-Hebbian
FUNCTION stdp_factor2(Dt (ms), nw) { : Dt is interval between most recent presynaptic spike
    : and most recent postsynaptic spike
    : calculated as tpost - tpre (i.e. > 0 if pre happens before post)
  : the following rule is the one described by Bi & Poo
  :printf("t = %f,  dt = %f, now W = %f\n", t, Dt,nw) 
  
  
  if (Dt > rest_width*-1 && Dt < rest_width ) {
	stdp_factor2 = 0 : no change if pre and post are simultaneous
  } else if (Dt<0) {
    stdp_factor2 =  p*abs(wmax-nw)*exp(Dt/ptau) : potentiation
  } else if (Dt>0) {
    stdp_factor2 = -1 *d*abs(nw-wmin)*exp(-Dt/dtau) : depression
  } else {
    stdp_factor2 = 0 : no change if pre and post are simultaneous
  }
}

NET_RECEIVE(weight (uS), W, tpre (ms)) {
	INITIAL { W =0  tpre = -1e9 }
	
	if (flag == 0) { :presynaptic spike 
		tpre = t
		:printf("tpre: %f\n", tpre)
		:printf("tpost: %f\n", tpost)
		if (isHebb == 1){
			if(abs(tpost - t + sh) < 100){ 
				:printf("(LTP): %f ms\n", tpost - t + sh)
				pre_spike_num = pre_spike_num + 1
			}
			if(pre_spike_num == maximum_spike_num){
				W = W + stdp_factor(tpost - t + sh, W)
				pre_spike_num = 0
				post_spike_num = 0
			}
			:printf("changed W: %f\n",W)
		} else {
			W = W + stdp_factor2(tpost - t + sh, W)
		}		
		:printf("pre first -> post after (LTP): %f ms, W = %f\n", tpost - t + sh,W)
		dW = W
		g = g + weight * (1+dW)
		
		
		
	}else if (flag == 2) { :postsynaptic spike		
		tpost = t	
			:printf("tpost: %f\n", tpost)
		FOR_NETCONS(w1, A1, tp) { : also can hide NET_RECEIVE args
			if (isHebb == 1) {
				:printf("post_case: w1: %f, A1: %f, tp: %f\n", w1, A1, tp)
				:printf("t - tp: %f\n", t-tp)
				if(abs(t - tp + sh) < 100){ 
					post_spike_num = post_spike_num + 1
				}
				if(post_spike_num == maximum_spike_num){
					A1 = A1 + stdp_factor(t - tp + sh, A1)
					post_spike_num = 0
					pre_spike_num = 0
					:printf("changed A1: %f\n", A1)
				}
			} else {
				A1 = A1 + stdp_factor2(t - tp + sh, A1)
				
			}
			 :printf("post first -> pre after (LTD): %f ms, A1 = %f\n",  t - tp + sh, A1)
			 dW = A1
			 :g = g + weight * (1+A1)
		}
	} else { : flag == 1 from INITIAL block
		:printf("initial\n")
		WATCH (v > 0) 2
	}
	
	:dW = (1+W) * 100
}

// Seonghyun Kim

v_init = 0

load_file("nrngui.hoc")
load_file("IafCell.hoc")
xopen("modeling.hoc")

cvode_active(0)

proc init(){
	finitialize()
	if (cvode.active()) {
		cvode.re_init()
	} else {
		fcurrent()
	}
	frecord_init()
}

simulation_time = 1000
tstop = simulation_time

objref corpus_file

corpus_file = new File()
corpus_file.ropen("../data/corpus.txt")

corpus_sent_num  = 0

strdef current_sent
while(!corpus_file.eof()){
    corpus_file.gets(current_sent)
	corpus_sent_num += 1
}


objref sentences[corpus_sent_num]
for(i = 0; i < corpus_sent_num; i += 1){
    sentences[i] = new Vecotr()
}

corpus_file.ropen("../data/corpus.txt")
sent_idx = 0
data_idx = 0
objref ch
while(!corpus_file.eof()){
    ch = corpus_file.scanvar()
    sentences[sent_dix].insrt(data_idx, corpus_file.scanvar())
    if(ch == 0){
        sent_idx += 1
        data_idx = 0
    } else{
        data_idx = 0
    }
}

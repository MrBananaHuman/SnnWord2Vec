vocab = open('vocab.txt', 'r', encoding='utf-8')
corpus = open('corpus.txt', 'r', encoding='utf-8')
output = open('preprocessed_corpus.txt', 'w', encoding='utf-8')

vocab_lines = vocab.readlines()
vocab.close()

vocab_id = dict()
id = 0

for line in vocab_lines:
    line = line.replace('\n', '')
    vocab_id[line] = id
    id += 1

corpus_lines = corpus.readlines()
corpus.close()

for line in corpus_lines:
    line = line.replace('\n', '')
    output_line = ''
    for word in line.split(' '):
        if word in vocab_id:
            output_line += vocab_id[word] + ' '
    output.write(output_line.strip() + '\n')

output.close()


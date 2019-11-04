from collections import OrderedDict
data = open('preprocessed_wiki_en_small.txt', 'r', encoding='utf-8')
output = open('vocabs.txt', 'w', encoding='utf-8')

vocab_set = dict()

lines = data.readlines()
total_num = len(lines)
print('total lines: ', total_num)
data.close()


for line in lines:
    line = line.replace('\n', '')
    for word in line.split(' '):
        if word in vocab_set:
            value = vocab_set[word]
            value += 1
            vocab_set[word] = value
        else:
            vocab_set[word] = 1

sorted_vocab_set = OrderedDict(sorted(vocab_set.items(), key=lambda x: x[1], reverse=True))

for vocab in sorted_vocab_set:
    output.write(vocab + '\n')

output.close()

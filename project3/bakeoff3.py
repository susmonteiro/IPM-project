#curl http://norvig.com/ngrams/count_big.txt | sort -k2 -n -r | awk '{print $1}' > sorted.txt  

from operator import itemgetter

f = open('count_big.txt', 'r')
max = 0
lines = f.readlines()
f.close()
list = []
for l in lines:
    list.append([int(l.split('\t')[1]), l.split('\t')[0]])
list2 = sorted(list, reverse=True)

o = open('words_per_frequency.txt', 'w')
for k in list2:
    o.write(k[1] + '\n')
o.close()
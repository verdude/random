import sys;
input = sys.stdin.read().split("\n");
files = [(int(x.split("\t")[0]), x.split("\t")[1:][0]) for x in input if len(x)>0];
for tup in files:
    print"%i, \"%s\""%(tup[0],tup[1])

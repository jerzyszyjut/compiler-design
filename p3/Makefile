#
CC=gcc
LEX=flex
CFLAGS=-Wall

% : %.tab.o %.o 
	$(CC) $< $*.o $(LDFLAGS) -o $@

%.tab.c %.tab.h: %.y
	bison -d $<

%.c: %.l %.tab.h
	$(LEX) -t $< > $@

z7a: z7a.y z7a.l


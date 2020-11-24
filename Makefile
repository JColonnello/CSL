all:
	mkdir -p generated
	bison -d -b generated/grammar grammar.y
	flex -o generated/tokens.c tokens.l 
	mkdir -p build
	gcc -g -I generated -o build/test generated/grammar.tab.c generated/tokens.c

clean:
	rm -rf generated build

.PHONY: all clean
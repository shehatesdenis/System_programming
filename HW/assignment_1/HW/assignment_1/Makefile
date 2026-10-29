all: homework_exe

homework_exe: main.o hw.o
	gcc -m32 main.o hw.o -o homework_exe

main.o: main.c
	gcc -m32 -c main.c -o main.o

hw.o: hw.asm
	fasm hw.asm hw.o

clean:
	rm -f homework_exe main.o hw.o

CC = gcc
AS = fasm
LD = gcc

TARGET = homework_exe
ASM_OBJ = hw.o
C_OBJ = main.o

all: $(TARGET)

$(TARGET): $(C_OBJ) $(ASM_OBJ)
	$(LD) -m32 -o $(TARGET) $(C_OBJ) $(ASM_OBJ)

$(C_OBJ): main.c
	$(CC) -c -m32 main.c -o $(C_OBJ)

$(ASM_OBJ): hw.asm
	$(AS) hw.asm $(ASM_OBJ)

clean:
	rm -f $(TARGET) $(C_OBJ) $(ASM_OBJ)

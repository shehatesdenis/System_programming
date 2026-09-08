format ELF
public _start

section '.data' writeable
msg1 db "Shtyka", 0xA, 0
msg2 db "Denis", 0xA, 0
msg3 db "Alexandrovich", 0xA, 0

section '.text' executable

_start:
    ;инициализация регистров для вывода информации на экран
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, 7
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, 6
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg3
    mov edx, 14
    int 0x80

    ;инициализация регистров для успешного завершения работы программы
    mov eax, 1
    mov ebx, 0
    int 0x80

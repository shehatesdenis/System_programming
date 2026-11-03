format ELF
public _start

section '.data' writeable
msg db "Denis", 0xA, 0

section '.text' executable

_start:
    mov eax, 4          ; syscall 4 = sys_write
    mov ebx, 1          ; файловый дескриптор: 1 = stdout
    mov ecx, msg        ; адрес строки в памяти
    mov edx, 6          ; длина (5 символов + перевод строки)
    int 0x80            ; вызов системного вызова ядра

    mov eax, 1          ; syscall 1 = sys_exit
    mov ebx, 0          ; код завершения 0
    int 0x80

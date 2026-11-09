format ELF64
public _start

section '.data' writable
    newline db 0x0A

section '.bss' writable
    buf rb 66               ; N = 66 байт

section '.text' executable
_start:
    mov rdi, buf            ; заполняем память символом '+'
    mov al, '+'
    mov rcx, 66
    rep stosb

    mov r12, buf            ; указатель на начало текущей строки
    mov r13, 11             ; K = 11 строк
row_loop:
    mov rax, 1
    mov rdi, 1
    mov rsi, r12
    mov rdx, 6              ; M = 6 символов
    syscall

    mov rax, 1              ; перевод строки
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    add r12, 6              ; следующая строка в памяти
    dec r13
    jnz row_loop

    mov rax, 60
    xor rdi, rdi
    syscall

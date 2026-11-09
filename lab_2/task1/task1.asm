format ELF64
public _start

section '.data' writable
    string db 'AMVtdiYVETHnNhuYwnWDVBqL'
    len = $ - string        ; длина строки (24)
    newline db 0x0A

section '.text' executable
_start:
    mov r13, len            ; r13 = 24
loop_rev:
    dec r13                 ; индекс 23, 22, ... 0
    lea rsi, [string + r13] ; адрес текущего символа
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rdx, 1              ; 1 байт
    syscall

    test r13, r13
    jnz loop_rev

    mov rax, 1              ; перевод строки
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60             ; sys_exit
    xor rdi, rdi
    syscall

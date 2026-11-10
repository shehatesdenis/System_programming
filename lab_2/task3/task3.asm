format ELF64
public _start

section '.data' writable
    newline db 0x0A

section '.bss' writable
    buf rb 45

section '.text' executable
_start:
    mov rdi, buf
    mov al, '!'
    mov rcx, 45
    rep stosb

    xor r13, r13            ; сколько символов уже выведено (смещение в buf)
    xor r12, r12            ; длина текущей строки
tri_loop:
    inc r12                 ; 1, 2, 3, ...
    mov rax, 1
    mov rdi, 1
    lea rsi, [buf + r13]    ; продолжаем с того места, где остановились
    mov rdx, r12
    syscall

    add r13, r12

    mov rax, 1              ; перевод строки
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    cmp r13, 45
    jb tri_loop

    mov rax, 60
    xor rdi, rdi
    syscall

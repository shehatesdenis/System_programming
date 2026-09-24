format ELF64
public _start

section '.data' writable
    char_val db '+'
    newline  db 0x0A

section '.bss' writable
    char_buf db 1

section '.text' executable
_start:
    mov r12, 11         ; K = 11 rows
outer_loop:
    push r12
    mov r12, 6          ; M = 6 cols
inner_loop:
    mov al, [char_val]
    mov [char_buf], al

    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, char_buf
    mov rdx, 1
    syscall

    dec r12
    jnz inner_loop

    mov rax, 1          ; print newline
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    pop r12
    dec r12
    jnz outer_loop

    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

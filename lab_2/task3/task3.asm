format ELF64
public _start

section '.data' writable
    char_val db '+'
    newline  db 0x0A

section '.bss' writable
    char_buf db 1

section '.text' executable
_start:
    mov r12, 0           ; Current row size
    mov r13, 0           ; Total printed
triangle_loop:
    inc r12
    mov r14, r12        ; chars to print in this row
row_loop:
    mov al, [char_val]
    mov [char_buf], al

    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, char_buf
    mov rdx, 1
    syscall

    inc r13
    dec r14
    jnz row_loop

    mov rax, 1          ; print newline
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    cmp r13, 66
    jl triangle_loop

    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

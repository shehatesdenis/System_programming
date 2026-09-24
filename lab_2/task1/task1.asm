format ELF64
public _start

section '.data' writable
    string db 'AMVtdiYVETHnNhuYwnWDVBqL'
    newline db 0x0A

section '.bss' writable
    char_buf db 1

section '.text' executable
_start:
    mov r12, string
    mov r13, 23
    dec r13
loop_rev:
    mov al, [r12 + r13]
    mov [char_buf], al

    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, char_buf
    mov rdx, 1          ; 1 byte
    syscall

    dec r13
    cmp r13, -1
    jne loop_rev

    mov rax, 1          ; print newline
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

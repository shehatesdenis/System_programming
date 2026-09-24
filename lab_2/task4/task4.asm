format ELF64
public _start

section '.data' writable
    number dq 5277616985
    newline db 0x0A

section '.bss' writable
    result_buf db 20
    char_buf db 1

section '.text' executable
_start:
    mov rax, [number]
    xor rbx, rbx
sum_loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx
    add rbx, rdx
    test rax, rax
    jnz sum_loop

    mov rax, rbx
    mov r8, 0
convert_loop:
    xor rdx, rdx
    mov rcx, 10
    div rcx
    add dl, '0'
    mov [result_buf + r8], dl
    inc r8
    test rax, rax
    jnz convert_loop

    mov r9, r8
    dec r9
print_loop:
    mov al, [result_buf + r9]
    mov [char_buf], al
    mov rax, 1
    mov rdi, 1
    mov rsi, char_buf
    mov rdx, 1
    syscall
    dec r9
    jge print_loop

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

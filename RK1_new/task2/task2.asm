format ELF64
public _start

section '.data' writable
    buf     rb 32
    err_msg db 'Usage: ./task2 n', 0x0A
    err_len = $ - err_msg

section '.text' executable
_start:
    cmp qword [rsp], 2
    jl usage
    mov rsi, [rsp+16]
    xor rbx, rbx

parse:
    movzx rax, byte [rsi]
    test al, al
    jz calc
    cmp al, '0'
    jl usage
    cmp al, '9'
    jg usage
    sub al, '0'
    imul rbx, 10
    add rbx, rax
    inc rsi
    jmp parse

calc:
    xor r12, r12
    mov r13, 1
    mov r14, 10

sum_loop:
    cmp r13, rbx
    jg print_res
    mov rax, r13
first_digit:
    xor rdx, rdx
    div r14
    test rax, rax
    jnz first_digit
    imul rdx, r13
    add r12, rdx
    inc r13
    jmp sum_loop

print_res:
    mov rax, r12
    mov rdi, buf + 31
    mov byte [rdi], 0x0A
    mov rbx, 10
conv:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz conv

    mov rsi, rdi
    mov rdx, buf + 32
    sub rdx, rdi
    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

usage:
    mov rax, 1
    mov rdi, 2
    mov rsi, err_msg
    mov rdx, err_len
    syscall
    mov rax, 60
    mov rdi, 1
    syscall

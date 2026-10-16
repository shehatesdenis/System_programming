format ELF64
public _start

section '.data' writable
    res_buf db 32
    newline db 0x0A

section '.text' executable
_start:
    mov rsi, [rsp + 8]
    cmp rsi, 0
    je exit
    mov rdi, [rsi]

    mov rbx, 0
parse_n:
    cmp rdi, 0
    je start_calc
    mov al, [rdi]
    cmp al, '0'
    jl start_calc
    cmp al, '9'
    jg start_calc
    sub al, '0'
    imul rbx, 10
    add rbx, rax
    inc rdi
    jmp parse_n

start_calc:
    mov r12, 0
    mov r13, 1

loop_sum:
    cmp r13, rbx
    jg print_res
    mov rax, r13
    mov rdx, 0
find_first:
    cmp rax, 0
    je next_k
    mov rdx, rax
    mov rax, 10
    div rax
    cmp rax, 0
    jne find_first
    mov rax, rdx
    imul rax, r13
    add r12, rax
next_k:
    inc r13
    jmp loop_sum

print_res:
    mov rax, r12
    mov rdi, res_buf + 31
    mov rcx, 0
conv_num:
    cmp rax, 0
    je do_print
    mov rdx, 0
    mov rbx, 10
    div rbx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc rcx
    jmp conv_num
do_print:
    mov rax, 1
    mov rdi, 1
    mov rsi, res_buf
    add rsi, 31
    sub rsi, rcx
    mov rdx, rcx
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

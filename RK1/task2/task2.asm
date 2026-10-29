format ELF64
public _start

section '.data' writable
    res_buf db 64
    newline db 0x0A

section '.text' executable
_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, res_buf
    mov rdx, 64
    syscall
    
    mov rsi, res_buf
    xor rbx, rbx
parse_n:
    mov al, [rsi]
    cmp al, 0
    je start_calc
    cmp al, 10
    je start_calc
    cmp al, '0'
    jl next_char
    cmp al, '9'
    jg next_char
    sub al, '0'
    movzx rax, al
    imul rbx, 10
    add rbx, rax
next_char:
    inc rsi
    jmp parse_n

start_calc:
    xor r12, r12
    mov r13, 1

loop_sum:
    cmp r13, rbx
    jg print_res
    
    mov rax, r13
    xor rdx, rdx
find_first:
    test rax, rax
    jz multiply_add
    mov rcx, 10
    div rcx
    test rax, rax
    jnz find_first
    mov rax, rdx
multiply_add:
    imul rax, r13
    add r12, rax
    inc r13
    jmp loop_sum

print_res:
    mov rax, r12
    mov rdi, res_buf + 31
    xor rcx, rcx
conv_num:
    cmp rax, 0
    je do_print
    xor rdx, rdx
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

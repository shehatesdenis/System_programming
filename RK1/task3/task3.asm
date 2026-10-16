format ELF64
public _start

section '.data' writable
    ; no data needed

section '.text' executable
_start:
    mov rsi, [rsp + 8]
    cmp rsi, 0
    je exit
    
    mov rdi, [rsi]
    mov rsi, [rsi + 8]
    cmp rsi, 0
    je exit
    
    mov r12, [rsi]
    mov rsi, [rsi + 8]
    
    mov rbx, 0
parse_n:
    cmp rsi, 0
    je start_mkdir
    mov al, [rsi]
    cmp al, '0'
    jl start_mkdir
    cmp al, '9'
    jg start_mkdir
    sub al, '0'
    imul rbx, 10
    add rbx, rax
    inc rsi
    jmp parse_n

start_mkdir:
    mov r13, 0
loop_mkdir:
    cmp r13, rbx
    jge exit
    
    ; mkdir(r12, 0777)
    mov rax, 8
    mov rdi, r12
    mov rsi, 0777
    syscall
    
    ; chdir(r12)
    mov rax, 12
    mov rdi, r12
    syscall
    
    inc r13
    jmp loop_mkdir

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

format ELF64
public _start

section '.data' writable
    newline db 10

section '.bss' writable
    result_buf rb 32

section '.text' executable
_start:
    cmp qword [rsp], 2
    jne .error

    mov rsi, [rsp + 16]
    cmp byte [rsi + 1], 0
    jne .error
    movzx rax, byte [rsi]
    cmp rax, 127
    ja .error

    call print_number
    xor rdi, rdi
    jmp exit

.error:
    mov rdi, 1

exit:
    mov rax, 60
    syscall

print_number:
    mov r8, result_buf + 32
    mov r9, r8
    mov rcx, 10

.convert:
    xor rdx, rdx
    div rcx
    dec r8
    add dl, '0'
    mov [r8], dl
    test rax, rax
    jnz .convert

    mov rax, 1
    mov rdi, 1
    mov rsi, r8
    mov rdx, r9
    sub rdx, r8
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret
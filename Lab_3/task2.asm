format ELF64
public _start

section '.data' writable
    newline db 10

section '.bss' writable
    a_value rq 1
    b_value rq 1
    c_value rq 1
    result_buf rb 32

section '.text' executable
_start:
    cmp qword [rsp], 4
    jne .error

    mov rsi, [rsp + 16]
    call parse_integer
    mov [a_value], rax

    mov rsi, [rsp + 24]
    call parse_integer
    mov [b_value], rax

    mov rsi, [rsp + 32]
    call parse_integer
    mov [c_value], rax
    test rax, rax
    jz .error

    mov rax, [a_value]
    sub rax, [c_value]
    imul rax, [b_value]
    cqo
    idiv qword [c_value]
    imul rax, [a_value]
    call print_number

    xor rdi, rdi
    jmp exit

.error:
    mov rdi, 1

exit:
    mov rax, 60
    syscall

parse_integer:
    xor rax, rax
    mov r8, 1
    cmp byte [rsi], '-'
    jne .digits
    mov r8, -1
    inc rsi

.digits:
    movzx rdx, byte [rsi]
    test dl, dl
    jz .parsed
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rsi
    jmp .digits

.parsed:
    imul rax, r8
    ret

print_number:
    xor r10, r10
    test rax, rax
    jns .absolute
    mov r10, 1
    neg rax

.absolute:
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

    test r10, r10
    jz .write
    dec r8
    mov byte [r8], '-'

.write:
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
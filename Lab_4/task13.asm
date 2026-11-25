format ELF64
public _start

result_text equ 'Numbers:'

include 'common.inc'

_start:
    call read_number
    jc input_error
    mov r12, rax

    mov rsi, result_msg
    mov edx, result_len
    call write_stdout

    mov r13d, 10
    cmp r13, r12
    jg finish

.next_number:
    mov rax, r13
    xor edx, edx
    mov ecx, 10
    div rcx
    mov r14, rdx                ; units digit

    xor edx, edx
    div rcx
    mov r15, rdx                ; tens digit

    test r14, r14
    jz .advance
    test r15, r15
    jz .advance

    mov rax, r13
    xor edx, edx
    div r14
    test rdx, rdx
    jnz .advance
    mov rax, r13
    xor edx, edx
    div r15
    test rdx, rdx
    jnz .advance

    mov rsi, space
    mov edx, 1
    call write_stdout
    mov rax, r13
    call print_number

.advance:
    cmp r13, r12
    je finish
    inc r13
    jmp .next_number

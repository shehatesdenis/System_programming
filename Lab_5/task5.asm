format ELF64
public _start

section '.bss' writable
    output_byte rb 1

section '.text' executable
_start:
    cmp qword [rsp], 5
    jne .failure

    mov rsi, [rsp + 32]
    call parse_nonnegative
    test rax, rax
    jle .failure
    mov r14, rax                ; 1-based starting position k

    mov rsi, [rsp + 40]
    call parse_nonnegative
    test rax, rax
    js .failure
    mov r15, rax                ; number of steps m

    mov eax, 2                  ; open(input, O_RDONLY)
    mov rdi, [rsp + 16]
    xor esi, esi
    syscall
    test rax, rax
    js .failure
    mov r12, rax

    mov eax, 2                  ; open(output, O_WRONLY|O_CREAT|O_TRUNC, 0644)
    mov rdi, [rsp + 24]
    mov esi, 577
    mov edx, 420
    syscall
    test rax, rax
    js .close_input_failure
    mov r13, rax

    mov rax, r14
    call emit_at_position
    test eax, eax
    jnz .close_both_failure
    xor ebx, ebx                ; step j
.step_loop:
    inc rbx
    cmp rbx, r15
    ja .success
    mov rax, r14
    add rax, rbx
    jo .left_position
    call emit_at_position
    test eax, eax
    jnz .close_both_failure
.left_position:
    mov rax, r14
    sub rax, rbx                ; k-j (skipped if it is before position 1)
    call emit_at_position
    test eax, eax
    jnz .close_both_failure
    jmp .step_loop

.success:
    mov eax, 3
    mov rdi, r12
    syscall
    mov eax, 3
    mov rdi, r13
    syscall
    xor edi, edi
    jmp .exit

.close_both_failure:
    mov eax, 3
    mov rdi, r13
    syscall
.close_input_failure:
    mov eax, 3
    mov rdi, r12
    syscall
.failure:
    mov edi, 1
.exit:
    mov eax, 60
    syscall

; RAX is the 1-based position. Returns 0 on success or 1 on I/O error.
emit_at_position:
    test rax, rax
    jle .skip
    dec rax
    mov rsi, rax
    mov eax, 8                  ; lseek(input, position - 1, SEEK_SET)
    mov rdi, r12
    xor edx, edx
    syscall
    test rax, rax
    js .failure

    xor eax, eax                ; read(input, &output_byte, 1)
    mov rdi, r12
    mov rsi, output_byte
    mov edx, 1
    syscall
    test rax, rax
    js .failure
    jz .skip

    mov eax, 1                  ; write(output, &output_byte, 1)
    mov rdi, r13
    mov rsi, output_byte
    mov edx, 1
    syscall
    cmp rax, 1
    jne .failure

.skip:
    xor eax, eax
    ret

.failure:
    mov eax, 1
    ret

; Convert the decimal string at RSI to an integer. Returns -1 if invalid.
parse_nonnegative:
    xor eax, eax
    cmp byte [rsi], 0
    je .invalid

.digits:
    movzx edx, byte [rsi]
    sub edx, '0'
    cmp edx, 9
    ja .invalid
    imul rax, 10
    jo .invalid
    add rax, rdx
    jo .invalid
    inc rsi
    cmp byte [rsi], 0
    jne .digits
    ret

.invalid:
    mov rax, -1
    ret

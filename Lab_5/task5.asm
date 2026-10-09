format ELF64 executable 3
entry _start

segment readable writeable
output_byte rb 1

segment readable executable
_start:
    cmp qword [rsp], 5
    jne .failure

    mov eax, 2                  ; open(input, O_RDONLY)
    mov rdi, [rsp+16]
    xor esi, esi
    syscall
    test rax, rax
    js .failure
    mov r12, rax

    mov eax, 2                  ; open(output, O_WRONLY|O_CREAT|O_TRUNC, 0644)
    mov rdi, [rsp+24]
    mov esi, 577
    mov edx, 420
    syscall
    test rax, rax
    js .close_input_failure
    mov r13, rax

    mov rsi, [rsp+32]
    call parse_positive
    test rax, rax
    jle .close_both_failure
    mov r14, rax                ; 1-based starting position k

    mov rsi, [rsp+40]
    call parse_nonnegative
    test rax, rax
    js .close_both_failure
    mov r15, rax                ; number of steps m

    mov rax, r14
    call emit_at_position
    xor ebx, ebx                ; step j
.step_loop:
    inc rbx
    cmp rbx, r15
    ja .success
    mov rax, r14
    add rax, rbx                ; k+j
    call emit_at_position
    mov rax, r14
    sub rax, rbx                ; k-j (skipped if it is before position 1)
    call emit_at_position
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

; Emit the byte at the 1-based file position in RAX. Out-of-range positions
; are ignored (lseek/read report EOF for positions past the end of the file).
emit_at_position:
    test rax, rax
    jle .emit_return
    dec rax
    mov rsi, rax
    mov eax, 8                  ; lseek(input, position-1, SEEK_SET)
    mov rdi, r12
    xor edx, edx
    syscall
    test rax, rax
    js .emit_return
    xor eax, eax                ; read(input, &output_byte, 1)
    mov rdi, r12
    lea rsi, [output_byte]
    mov edx, 1
    syscall
    cmp rax, 1
    jne .emit_return
    mov eax, 1                  ; write(output, &output_byte, 1)
    mov rdi, r13
    lea rsi, [output_byte]
    mov edx, 1
    syscall
.emit_return:
    ret

; Parse a positive decimal integer at RSI. Returns it in RAX, or 0 if invalid.
parse_positive:
    xor eax, eax
    xor r8d, r8d
.positive_loop:
    movzx ecx, byte [rsi]
    test ecx, ecx
    jz .positive_done
    cmp ecx, '0'
    jb .positive_invalid
    cmp ecx, '9'
    ja .positive_invalid
    imul rax, 10
    sub ecx, '0'
    add rax, rcx
    inc r8
    inc rsi
    jmp .positive_loop
.positive_done:
    test r8, r8
    jz .positive_invalid
    ret
.positive_invalid:
    xor eax, eax
    ret

; Parse a nonnegative decimal integer at RSI. Returns -1 if invalid.
parse_nonnegative:
    xor eax, eax
    xor r8d, r8d
.nonnegative_loop:
    movzx ecx, byte [rsi]
    test ecx, ecx
    jz .nonnegative_done
    cmp ecx, '0'
    jb .nonnegative_invalid
    cmp ecx, '9'
    ja .nonnegative_invalid
    imul rax, 10
    sub ecx, '0'
    add rax, rcx
    inc r8
    inc rsi
    jmp .nonnegative_loop
.nonnegative_done:
    test r8, r8
    jz .nonnegative_invalid
    ret
.nonnegative_invalid:
    mov rax, -1
    ret

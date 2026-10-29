format ELF
public init_queue
public add_to_end
public remove_from_start
public fill_random
public count_primes
public get_odds
public count_ends_with_1

section '.text' executable

extrn malloc
extrn rand

init_queue:
    push ebp
    mov ebp, esp
    push ebx

    mov eax, [ebp+8]     ; initial_capacity
    mov ecx, eax
    shl ecx, 2
    add ecx, 8

    push ecx            ; argument for malloc
    call malloc
    add esp, 4

    test eax, eax
    jz .error

    mov ebx, eax        ; addr of allocated region
    mov dword [ebx], 0       ; size = 0
    mov edx, [ebp+8]
    mov [ebx+4], edx    ; capacity = initial_capacity

    mov eax, ebx
    pop ebx
    mov esp, ebp
    pop ebp
    ret

.error:
    xor eax, eax
    pop ebx
    mov esp, ebp
    pop ebp
    ret

add_to_end:
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8]    ; queue
    mov ecx, [ebp+12]   ; value

    test ebx, ebx
    jz .err

    mov eax, [ebx]      ; size
    mov edx, [ebx+4]    ; capacity
    cmp eax, edx
    jge .err            ; queue full

    mov eax, [ebx]
    shl eax, 2
    add eax, 8
    mov [ebx + eax], ecx
    inc dword [ebx]
    xor eax, eax        ; return 0 on success
    jmp .done
.err:
    mov eax, -1
.done:
    mov esp, ebp
    pop ebp
    ret

remove_from_start:
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8]

    test ebx, ebx
    jz .empty

    mov eax, [ebx]
    cmp eax, 0
    je .empty

    mov ecx, 1
.loop:
    mov edx, [ebx + 8 + ecx*4]
    mov [ebx + 8 + (ecx-1)*4], edx
    inc ecx
    mov eax, [ebx]
    cmp ecx, eax
    jl .loop

    dec dword [ebx]
    xor eax, eax
    jmp .done
.empty:
    mov eax, -1
.done:
    mov esp, ebp
    pop ebp
    ret

fill_random:
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8]    ; queue

    test ebx, ebx
    jz .done

    mov ecx, [ebx+4]    ; use capacity to fill
    xor edi, edi        ; index
.loop:
    cmp edi, ecx
    jge .done
    call rand
    mov [ebx + 8 + edi*4], eax
    inc edi
    jmp .loop
.done:
    mov dword [ebx], ecx ; update size to capacity
    xor eax, eax
    mov esp, ebp
    pop ebp
    ret

count_primes:
    push ebp
    mov ebp, esp
    sub esp, 4           ; local count
    mov dword [ebp-4], 0

    mov ebx, [ebp+8]
    test ebx, ebx
    jz .done

    mov ecx, [ebx]       ; size
    xor edi, edi        ; index
.next_val:
    cmp edi, ecx
    jge .done
    mov edx, [ebx + 8 + edi*4]
    cmp edx, 1
    jle .not_prime
    mov esi, 2
.prime_loop:
    mov eax, esi
    imul eax, eax
    cmp eax, edx
    jg .is_prime
    mov eax, edx
    xor edx, edx
    idiv esi
    cmp edx, 0
    je .not_prime
    inc esi
    jmp .prime_loop
.is_prime:
    inc dword [ebp-4]
    jmp .next_val
.not_prime:
    inc edi
    jmp .next_val
.done:
    mov eax, [ebp-4]
    mov esp, ebp
    add esp, 4
    pop ebp
    ret

get_odds:
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8]    ; queue
    mov esi, [ebp+12]   ; out_list

    test ebx, ebx
    jz .done_0

    mov ecx, [ebx]      ; size
    xor eax, eax        ; count
    xor edi, edi        ; index
.loop:
    cmp edi, ecx
    jge .done
    mov edx, [ebx + 8 + edi*4]
    test edx, 1          ; check if odd
    jz .next
    mov edx, eax
    shl edx, 2
    mov edi, [ebx + 8 + edi*4]
    mov [esi + edx], edi
    inc eax
.next:
    inc edi
    jmp .loop
.done:
    mov eax, eax        ; return count
    mov esp, ebp
    pop ebp
    ret
.done_0:
    mov eax, 0
    mov esp, ebp
    pop ebp
    ret

count_ends_with_1:
    push ebp
    mov ebp, esp
    mov ebx, [ebp+8]
    test ebx, ebx
    jz .done

    mov ecx, [ebx]
    xor eax, eax
    xor edi, edi
.loop:
    cmp edi, ecx
    jge .done
    mov edx, [ebx + 8 + edi*4]
    mov esi, 10
    xor edx, edx
    div esi
    cmp edx, 1
    jne .next
    inc eax
.next:
    inc edi
    jmp .loop
.done:
    mov esp, ebp
    pop ebp
    ret

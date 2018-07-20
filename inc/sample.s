    .text                              ❶
    .intel_syntax noprefix             ❷
    .file   "sample.c"
    .globl  add
    .p2align    4, 0x90
    .type   add,@function
add:                                   ❸
    mov     dword ptr [rsp - 4], edi   ❹
    mov     dword ptr [rsp - 8], esi   ❺
    mov     esi, dword ptr [rsp - 4]   ❻
    add     esi, dword ptr [rsp - 8]   ❼
    mov     eax, esi                   ❽
    ret                                ❾

    .globl  main
    .p2align    4, 0x90
    .type   main,@function
main:
    sub     rsp, 24                    ❿
    mov     dword ptr [rsp + 20], 0
    mov     dword ptr [rsp + 16], edi
    mov     qword ptr [rsp + 8], rsi
    mov     dword ptr [rsp + 4], 10    ⓫
    mov     dword ptr [rsp], 20        ⓬
    mov     edi, dword ptr [rsp + 4]   ⓭
    mov     esi, dword ptr [rsp]       ⓮
    call    add                        ⓯
    add     rsp, 24                    ⓰
    ret                                ⓱

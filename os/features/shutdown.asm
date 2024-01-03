global _shutdown

section .text:
    _shutdown:
        mov al, 0x01
        mov ah, 0x53
        xor bx, bx
        int 15h
    
        mov al, 0x0e
        mov ah, 0x53
        xor bx, bx
        mov ch, 0x01
        mov cl, 0x02
        int 15h

        mov al, 0x07
        mov ah, 0x53
        mov bx, 0x0001
        mov cx, 0x03
        int 15h

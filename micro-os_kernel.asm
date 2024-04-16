     name "kernel"
; this is a very basic example
; of a tiny operating system.
;
; this is kernel module!
;
; it is assumed that this machine
; code is loaded by 'micro-os_loader.asm'
; from floppy drive from:
;   cylinder: 0
;   sector: 2
;   head: 0


;=================================================
; how to test micro-operating system:
;   1. compile micro-os_loader.asm
;   2. compile micro-os_kernel.asm
;   3. compile writebin.asm
;   4. insert empty floppy disk to drive a:
;   5. from command prompt type:
;        writebin loader.bin
;        writebin kernel.bin /k
;=================================================

; directive to create bin file:
#make_bin#

; where to load? (for emulator. all these values are saved into .binf file)
#load_segment=0800#
#load_offset=0000#

; these values are set to registers on load, actually only ds, es, cs, ip, ss, sp are
; important. these values are used for the emulator to emulate real microprocessor state 
; after micro-os_loader transfers control to this kernel (as expected).
#al=0b#
#ah=00#
#bh=00#
#bl=00#
#ch=00#
#cl=02#
#dh=00#
#dl=00#
#ds=0800#
#es=0800#
#si=7c02#
#di=0000#
#bp=0000#
#cs=0800#
#ip=0000#
#ss=07c0#
#sp=03fe#



; this macro prints a char in al and advances
; the current cursor position:
putc    macro   char
        push    ax
        mov     al, char
        mov     ah, 0eh
        int     10h     
        pop     ax
endm


; sets current cursor position:
gotoxy  macro   col, row
        push    ax
        push    bx
        push    dx
        mov     ah, 02h
        mov     dh, row
        mov     dl, col
        mov     bh, 0
        int     10h
        pop     dx
        pop     bx
        pop     ax
endm


print macro x, y, attrib, sdat
LOCAL   s_dcl, skip_dcl, s_dcl_end
    pusha
    mov dx, cs
    mov es, dx
    mov ah, 13h
    mov al, 1
    mov bh, 0
    mov bl, attrib
    mov cx, offset s_dcl_end - offset s_dcl
    mov dl, x
    mov dh, y
    mov bp, offset s_dcl
    int 10h
    popa
    jmp skip_dcl
    s_dcl DB sdat
    s_dcl_end DB 0
    skip_dcl:    
endm



; kernel is loaded at 0800:0000 by micro-os_loader
org 0000h

; skip the data and function delaration section:
jmp start 
; The first byte of this jump instruction is 0E9h
; It is used by to determine if we had a sucessful launch or not.
; The loader prints out an error message if kernel not found.
; The kernel prints out "F" if it is written to sector 1 instead of sector 2.
           



;==== data section =====================

; welcome message:
msg  db "Ho",159,"geldiniz!", 0 

cmd_size        equ 10    ; size of command_buffer
command_buffer  db cmd_size dup("b")
clean_str       db cmd_size dup(" "), 0
prompt          db ">", 0

; commands:
chelp    db "help", 0
chelp_tail:
ccls     db "cls", 0
ccls_tail:          
canimation     db "animation", 0
canimation_tail: 
chiworld     db "hiworld", 0
chiworld_tail:
cquit    db "quit", 0
cquit_tail:
cexit    db "exit", 0
cexit_tail:
creboot  db "reboot", 0
creboot_tail:

help_msg db "Bizi se",135,"ti",167,"iniz i",135,"in te",159,"ekk",154,"rler!", 0Dh,0Ah
         db "Komutlar:", 0Dh,0Ah
         db "help      - Bu listeyi yazd",141,"r.", 0Dh,0Ah
         db "cls       - Ekran",141," temizle.", 0Dh,0Ah
         db "hiworld   - D",129,"nyaya selam ver.", 0Dh,0Ah
         db "animation - Animasyon ",135,"izdir.", 0Dh,0Ah
         db "reboot    - Yeniden ba",159,"lat.", 0Dh,0Ah
         db "quit      - Kapat.", 0Dh,0Ah 
         db "exit      - Ayr",141,"l.", 0Dh,0Ah
         db "Daha Fazlas",141," gelecek!", 0Dh,0Ah, 0

unknown  db "unknown command: " , 0    

;======================================

start:

; set data segment:
push    cs
pop     ds

; set default video mode 80x25:
mov     ah, 00h
mov     al, 03h
int     10h

; blinking disabled for compatibility with dos/bios,
; emulator and windows prompt never blink.
mov     ax, 1003h
mov     bx, 0      ; disable blinking.
int     10h


; *** the integrity check  ***
cmp [0000], 0E9h
jz integrity_check_ok
integrity_failed:  
mov     al, 'F'
mov     ah, 0eh
int     10h  
; wait for any key...
mov     ax, 0
int     16h
; reboot...
mov     ax, 0040h
mov     ds, ax
mov     w.[0072h], 0000h
jmp	0ffffh:0000h	 
integrity_check_ok:
nop
; *** ok ***
              


; clear screen:
call    clear_screen
                     
                       
; print out the message:
lea     si, msg
call    print_string


eternal_loop:
call    get_command

call    process_cmd

; make eternal loop:
jmp eternal_loop


;===========================================
get_command proc near

; set cursor position to bottom
; of the screen:
mov     ax, 40h
mov     es, ax
mov     al, es:[84h]

gotoxy  0, al

; clear command line:
lea     si, clean_str
call    print_string

gotoxy  0, al

; show prompt:
lea     si, prompt 
call    print_string


; wait for a command:
mov     dx, cmd_size    ; buffer size.
lea     di, command_buffer
call    get_string


ret
get_command endp
;===========================================

process_cmd proc    near

;//// check commands here ///
; set es to ds
push    ds
pop     es

cld     ; forward compare.

; compare command buffer with 'help'
lea     si, command_buffer
mov     cx, chelp_tail - offset chelp   ; size of ['help',0] string.
lea     di, chelp
repe    cmpsb
je      help_command

; compare command buffer with 'cls'
lea     si, command_buffer
mov     cx, ccls_tail - offset ccls  ; size of ['cls',0] string.
lea     di, ccls
repe    cmpsb
jne     not_cls
jmp     cls_command
not_cls:





; compare command buffer with 'animation'
lea     si, command_buffer
mov     cx, canimation_tail - offset canimation   ; size of ['animation',0] string.
lea     di, canimation
repe    cmpsb
je      animation_command





; compare command buffer with 'hiworld'
lea     si, command_buffer
mov     cx, chiworld_tail - offset chiworld   ; size of ['hiworld',0] string.
lea     di, chiworld
repe    cmpsb
je      hiworld_command








; compare command buffer with 'quit'
lea     si, command_buffer
mov     cx, cquit_tail - offset cquit ; size of ['quit',0] string.
lea     di, cquit
repe    cmpsb
je      reboot_command

; compare command buffer with 'exit'
lea     si, command_buffer
mov     cx, cexit_tail - offset cexit ; size of ['exit',0] string.
lea     di, cexit
repe    cmpsb
je      reboot_command

; compare command buffer with 'reboot'
lea     si, command_buffer
mov     cx, creboot_tail - offset creboot  ; size of ['reboot',0] string.
lea     di, creboot
repe    cmpsb
je      reboot_command

; ignore empty lines
cmp     command_buffer, 0
jz      processed


;////////////////////////////

; if gets here, then command is
; unknown...

mov     al, 1
call    scroll_t_area

; set cursor position just
; above prompt line:
mov     ax, 40h
mov     es, ax
mov     al, es:[84h]
dec     al
gotoxy  0, al

lea     si, unknown
call    print_string

lea     si, command_buffer
call    print_string

mov     al, 1
call    scroll_t_area

jmp     processed

; +++++ 'help' command ++++++
help_command:

; scroll text area 9 lines up:
mov     al, 9
call    scroll_t_area

; set cursor position 9 lines
; above prompt line:
mov     ax, 40h
mov     es, ax
mov     al, es:[84h]
sub     al, 9
gotoxy  0, al

lea     si, help_msg
call    print_string

mov     al, 1
call    scroll_t_area

jmp     processed




; +++++ 'cls' command ++++++
cls_command:
call    clear_screen
jmp     processed





; +++ 'animation' command +++
animation_command:
call    animation_fun
jmp     processed





; +++ 'hiworld' command +++
hiworld_command:
call    hwfun
jmp     processed

         
 
 
 



; +++ 'quit', 'exit', 'reboot' +++
reboot_command:
call    clear_screen
print 5,2,0011_1111b," please eject any floppy disks "
print 5,3,0011_1111b," and press any key to reboot... "
mov ax, 0  ; wait for any key....
int 16h

; store magic value at 0040h:0072h:
;   0000h - cold boot.
;   1234h - warm boot.
mov     ax, 0040h
mov     ds, ax
mov     w.[0072h], 0000h ; cold boot.
jmp	0ffffh:0000h	 ; reboot!

; ++++++++++++++++++++++++++

processed:
ret
process_cmd endp

;===========================================

; scroll all screen except last row
; up by value specified in al

scroll_t_area   proc    near

mov dx, 40h
mov es, dx  ; for getting screen parameters.
mov ah, 06h ; scroll up function id.
mov bh, 07  ; attribute for new lines.
mov ch, 0   ; upper row.
mov cl, 0   ; upper col.
mov di, 84h ; rows on screen -1,
mov dh, es:[di] ; lower row (byte).
dec dh  ; don't scroll bottom line.
mov di, 4ah ; columns on screen,
mov dl, es:[di]
dec dl  ; lower col.
int 10h

ret
scroll_t_area   endp

;===========================================




; get characters from keyboard and write a null terminated string 
; to buffer at DS:DI, maximum buffer size is in DX.
; 'enter' stops the input.
get_string      proc    near
push    ax
push    cx
push    di
push    dx

mov     cx, 0                   ; char counter.

cmp     dx, 1                   ; buffer too small?
jbe     empty_buffer            ;

dec     dx                      ; reserve space for last zero.


;============================
; eternal loop to get
; and processes key presses:

wait_for_key:

mov     ah, 0                   ; get pressed key.
int     16h

cmp     al, 0Dh                 ; 'return' pressed?
jz      exit


cmp     al, 8                   ; 'backspace' pressed?
jne     add_to_buffer
jcxz    wait_for_key            ; nothing to remove!
dec     cx
dec     di
putc    8                       ; backspace.
putc    ' '                     ; clear position.
putc    8                       ; backspace again.
jmp     wait_for_key

add_to_buffer:

        cmp     cx, dx          ; buffer is full?
        jae     wait_for_key    ; if so wait for 'backspace' or 'return'...

        mov     [di], al
        inc     di
        inc     cx
        
        ; print the key:
        mov     ah, 0eh
        int     10h

jmp     wait_for_key
;============================

exit:

; terminate by null:
mov     [di], 0

empty_buffer:

pop     dx
pop     di
pop     cx
pop     ax
ret
get_string      endp




; print a null terminated string at current cursor position, 
; string address: ds:si
print_string proc near
push    ax      ; store registers...
push    si      ;

next_char:      
        mov     al, [si]
        cmp     al, 0
        jz      printed
        inc     si
        mov     ah, 0eh ; teletype function.
        int     10h
        jmp     next_char
printed:

pop     si      ; re-store registers...
pop     ax      ;

ret
print_string endp



; clear the screen by scrolling entire screen window,
; and set cursor position on top.
; default attribute is set to white on blue.
clear_screen proc near
        push    ax      ; store registers...
        push    ds      ;
        push    bx      ;
        push    cx      ;
        push    di      ;

        mov     ax, 40h
        mov     ds, ax  ; for getting screen parameters.
        mov     ah, 06h ; scroll up function id.
        mov     al, 0   ; scroll all lines!
        mov     bh, 1001_1111b  ; attribute for new lines.
        mov     ch, 0   ; upper row.
        mov     cl, 0   ; upper col.
        mov     di, 84h ; rows on screen -1,
        mov     dh, [di] ; lower row (byte).
        mov     di, 4ah ; columns on screen,
        mov     dl, [di]
        dec     dl      ; lower col.
        int     10h

        ; set cursor position to top
        ; of the screen:
        mov     bh, 0   ; current page.
        mov     dl, 0   ; col.
        mov     dh, 0   ; row.
        mov     ah, 02
        int     10h

        pop     di      ; re-store registers...
        pop     cx      ;
        pop     bx      ;
        pop     ds      ;
        pop     ax      ;

        ret
clear_screen endp

         
         
         
         
         
         

animation_fun proc near

    

MOV AH, 0
MOV AL, 13H
INT 10H

MOV AH,0CH
MOV AL,10
MOV CX,30
MOV DX,50
INT 10H

; DX --> Y KORDINATI
; CX --> X KORDINATI



;birinci karemiz
MOV BL,20
ilkcizgi:
INT 10H
INC CX
DEC BL
JNZ ilkcizgi

MOV BL,80
ikincicizgi:
INT 10H
INC DX
DEC BL
JNZ ikincicizgi

MOV BL,20
ucuncucizgi:
INT 10H
DEC CX
DEC BL
JNZ ucuncucizgi

MOV BL,80
dorduncucizgi:
INT 10H
DEC DX
DEC BL
JNZ dorduncucizgi

;ikinci karemiz

MOV CX,50
MOV DX,50

MOV BL,30
ilkcizgi1:
INT 10H
INC CX
DEC BL
JNZ ilkcizgi1

MOV BL,20
ikincicizgi1:
INT 10H
INC DX
DEC BL
JNZ ikincicizgi1

MOV BL,30
ucuncucizgi1:
INT 10H
DEC CX
DEC BL
JNZ ucuncucizgi1

MOV BL,20
dorduncucizgi1:
INT 10H
DEC DX
DEC BL
JNZ dorduncucizgi1

;ucuncu karemiz

MOV CX,50
MOV DX,80

MOV BL,30
ilkcizgi3:
INT 10H
INC CX
DEC BL
JNZ ilkcizgi3

MOV BL,20
ikincicizgi3:
INT 10H
INC DX
DEC BL
JNZ ikincicizgi3

MOV BL,30
ucuncucizgi3:
INT 10H
DEC CX
DEC BL
JNZ ucuncucizgi3

MOV BL,20
dorduncucizgi3:
INT 10H
DEC DX
DEC BL
JNZ dorduncucizgi3


;dorduncu karemiz

MOV CX,50
MOV DX,110

MOV BL,30
ilkcizgi2:
INT 10H
INC CX
DEC BL
JNZ ilkcizgi2

MOV BL,20
ikincicizgi2:
INT 10H
INC DX
DEC BL
JNZ ikincicizgi2

MOV BL,30
ucuncucizgi2:
INT 10H
DEC CX
DEC BL
JNZ ucuncucizgi2

MOV BL,20
dorduncucizgi2:
INT 10H
DEC DX
DEC BL
JNZ dorduncucizgi2



;besinci karemiz . olan

MOV CX,90
MOV DX,110

MOV BL,20
ilkcizgi4:
INT 10H
INC CX
DEC BL
JNZ ilkcizgi4

MOV BL,20
ikincicizgi4:
INT 10H
INC DX
DEC BL
JNZ ikincicizgi4

MOV BL,20
ucuncucizgi4:
INT 10H
DEC CX
DEC BL
JNZ ucuncucizgi4

MOV BL,20
dorduncucizgi4:
INT 10H
DEC DX
DEC BL
JNZ dorduncucizgi4


;altinci karemiz

MOV CX,120
MOV DX,50

MOV BL,80
ilkcizgi5:
INT 10H
INC CX
DEC BL
JNZ ilkcizgi5

MOV BL,20
ikincicizgi5:
INT 10H
INC DX
DEC BL
JNZ ikincicizgi5

MOV BL,80
ucuncucizgi5:
INT 10H
DEC CX
DEC BL
JNZ ucuncucizgi5

MOV BL,20
dorduncucizgi5:
INT 10H
DEC DX
DEC BL
JNZ dorduncucizgi5

;yedinci karemiz

MOV CX,150
MOV DX,70

MOV BL,20
ilkcizgi6:
INT 10H
INC CX
DEC BL
JNZ ilkcizgi6

MOV BL,60
ikincicizgi6:
INT 10H
INC DX
DEC BL
JNZ ikincicizgi6

MOV BL,20
ucuncucizgi6:
INT 10H
DEC CX
DEC BL
JNZ ucuncucizgi6

MOV BL,60
dorduncucizgi6:
INT 10H
DEC DX
DEC BL
JNZ dorduncucizgi6


;sekizinci karemiz . olan

MOV CX,180
MOV DX,110

MOV BL,20
ilkcizgi7:
INT 10H
INC CX
DEC BL
JNZ ilkcizgi7

MOV BL,20
ikincicizgi7:
INT 10H
INC DX
DEC BL
JNZ ikincicizgi7

MOV BL,20
ucuncucizgi7:
INT 10H
DEC CX
DEC BL
JNZ ucuncucizgi7

MOV BL,20
dorduncucizgi7:
INT 10H
DEC DX
DEC BL
JNZ dorduncucizgi7




animation_fun endp        



          
          
          
          


hwfun proc near

    
; this example shows how to print string.
; the string is defined just after the call instruction.
; this example does not use emu8086.inc library.

name "print"



; set these values to registers for no particular reason,
; we just want to check that the procedure does not destroy them.
mov si, 1234h
mov ax, 9876h

; 0Dh,0Ah - is the code
;          for standard new
;          line characters:
;   0Dh - carriage return.
;   0Ah - new line.

call printme
db "D",129,"nyayla", 0

; gets here after print:
mov    cx, 1    

call   printme
db  "Kar",159,"",141,"la",159,"t",141,"n", 0Dh,0Ah, 0

; gets here after print:
mov    cx, 2

call   printme
       db "Merhaba D",129,"nya!", 0Ah
       db "D",129,"nyaya selam verdi",167,"in i",135,"in D",129,"nya Mutlu Oldu!", 0Dh,0Ah
       db "Yazd",141,"rma i",159,"lemi tamamland",141,"!", 0

; printme returns here:
xor    cx, cx

call   printme
       db 0xd,0xa,"press any key...", 0


; wat for any key....
mov ah, 0
int 16h


ret    ; return to os.

;*******************************
; this procedure prints a null terminated
; string at current cursor position.
; the zero terminated string should
; be defined just after
; the call. for example:
;
; call printme
; db 'hello world!', 0
;
; address of string is stored in the
; stack as return address.
; procedure updates value in the
; stack to make return
; after string definition.

printme:

mov     cs:temp1, si  ; protect si register.

pop     si            ; get return address (ip).

push    ax            ; store ax register.

next_char_print:      
        mov     al, cs:[si]
        inc     si              ; next byte.
        cmp     al, 0
        jz      printed_str        
        mov     ah, 0eh         ; teletype function.
        int     10h
        jmp     next_char_print ; loop.
printed_str:

pop     ax            ; re-store ax register.

; si should point to next command after
; the call instruction and string definition:
push    si            ; save new return address into the stack.

mov     si, cs:temp1  ; re-store si register.

ret
; variable to store original
; value of si register.
temp1  dw  ?    
;*******************************




hwfun endp
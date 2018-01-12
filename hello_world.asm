; ------------------------------------------
; created by: Thomas Osgood
; date created: 2016-12-10
; Assembly Language Practice
;
; to compile:
; nasm -f elf hello_world.asm
;
; to link:
; ld -m elf_i386 -s -o hello hello_world.o
;
; to run:
; ./hello
; ------------------------------------------

; --------------------------------
; common symbolic representations
; make code more human-readable
; --------------------------------
SYS_EXIT  equ 1
SYS_WRITE equ 4
SYS_READ  equ 3
STDIN     equ 0
STDOUT    equ 1

; ---------------------------
; mark text section
; this is where the code goes
; ---------------------------
section .text
	global _start ; always required. starts main function

_start:
	call PRINT_NEWLINE ; function call (print newline)
	call DISP_MSG ; function call (display Hello World!)
	call DISP_AUTHOR ; function call (display Author Name)
	call ADD_NUMS ; function call (add two numbers)
	call USER_INPUT ; function call (get user input)

	; Exit Successfully
	mov ebx,0 ; return (exit) code 
   	mov eax,SYS_EXIT ; system call number (sys_exit)
   	int 0x80 ; call kernel

; ------------------------------
; Display Author Function
; Prints author name to stdout
; ------------------------------
DISP_AUTHOR:
	push ebp ; push base pointer to stack
	mov ebp,esp ; move stack pointer to base pointer
	sub esp,0x40 ; fill stack pointer (move down stack)
	mov ebx,[ebp+8] ; move base pointer position, save in ebx

	; display message
	mov edx,lenA ; save message length in data register
	mov ecx,author ; save message in register
	mov ebx,STDOUT ; print to stdout
	mov eax,SYS_WRITE ; system call (print message)
	int 0x80 ; kernel call

	; return process
	mov esp,ebp ; move base pointer to stack pointer
	pop ebp ; pop base pointer (ready return)
	ret ; return to main function

; ----------------------------------
; Display Message Function
; Prints 'Hello, World!' to stdout
; ----------------------------------
DISP_MSG:
	push ebp ; push base pointer to stack
	mov ebp,esp ; move stack pointer to base pointer
	sub esp,0x40 ; fill stack pointer (move down stack)
	mov ebx,[ebp+8] ; move base pointer position, save in ebx

	mov edx,len ;message length
   	mov ecx,msg ;message to write
   	mov ebx,STDOUT ;file descriptor (stdout)
  	mov eax,SYS_WRITE ;system call number (sys_write)
   	int 0x80 ;call kernel

	; return process
	mov esp,ebp ; move base pointer to stack pointer
	pop ebp ; pop base pointer (ready return)
	ret ; return to main function

; ---------------------------
; Add Numbers Function
; Adds 0x2 and 0x3 together
; ---------------------------
ADD_NUMS:
	push ebp ; push base pointer to stack
	mov ebp,esp ; move stack pointer to base pointer
	sub esp,0x40 ; fill stack pointer (move down stack)
	mov ebx,[ebp+8] ; move base pointer position, save in ebx

	; print sum message (part w/o result)
	mov eax,SYS_WRITE
	mov ebx,1
	mov ecx,sumMsg
	mov edx,sumLen
	int 0x80

	; calculate sum
	mov eax,0x02 ; move 1st number to reg a
	mov ecx,0x03 ; move 2nd number to reg c
	add eax,ecx ; add 1st and 2nd numbers
	add eax,'0' ; add null character
	mov [res],eax ; save result in res var

	; print result to stdout
	mov edx,16
	mov ecx,res
	mov ebx,STDOUT
	mov eax,SYS_WRITE
	int 0x80

	call PRINT_NEWLINE
	call PRINT_NEWLINE

	; return process
	mov esp,ebp ; move base pointer to stack pointer
	pop ebp ; pop base pointer (ready return)
	ret ; return to main function

; -----------------------
; User Input Function
; Takes input from user
; -----------------------
USER_INPUT:
	push ebp ; push base pointer to stack
	mov ebp,esp ; move stack pointer to base pointer
	sub esp,0x40 ; fill stack pointer (move down stack)
	mov ebx,[ebp+8] ; move base pointer position, save in ebx

	; display user message
	mov eax,SYS_WRITE
	mov ebx,STDOUT
	mov ecx,usrMsg
	mov edx,usrMsgLen
	int 0x80

	add esi,'0'

	; get user input
	mov eax,SYS_READ
	mov ebx,STDIN
	mov ecx,inpUsr
	mov edx,usrNameLen
	int 0x80

	; display user input
	; prefix message
	mov eax,SYS_WRITE
	mov ebx,STDOUT
	mov ecx,usrMsgRpt
	mov edx,usrMsgRptLen
	int 0x80

	call PRINT_NEWLINE

	; user input
	mov eax,SYS_WRITE
	mov ebx,STDOUT
	mov ecx,inpUsr
	mov edx,usrNameLen
	int 0x80

	call PRINT_NEWLINE

	; return process
	mov esp,ebp ; move base pointer to stack pointer
	pop ebp ; pop base pointer (ready return)


; ---------------------------
; Print Newline Function
; Prints a newline to stdout
; ---------------------------
PRINT_NEWLINE:
	push ebp ; push base pointer to stack
	mov ebp,esp ; move stack pointer to base pointer
	sub esp,0x40 ; fill stack pointer (move down stack)
	mov ebx,[ebp+8] ; move base pointer position, save in ebx

	mov eax,SYS_WRITE ; set syscall (print to screen)
	mov ebx,STDOUT ; set file pointer (stdout)
	mov ecx,newline ; save newline chars
	mov edx,newlinelen ; save length of newline
	int 0x80 ; call kernel	

	; return process
	mov esp,ebp ; move base pointer to stack pointer
	pop ebp ; pop base pointer (ready return)
	ret ; return to main function


; ---------------------------------------
; mark data section
; this is where initialized vars are made
; ---------------------------------------
section .data
	align 2 ; Align to the nearest 2 byte boundry (must be pow of 2)
	; message strings
	msg db 'Hello, World!', 0xa ; hello world string
	len equ $ - msg ;length of the string

	author db 'Author : John Smith', 0xa ; author name string (0xa is \n)
	lenA equ $ - author ; length of author

	sumMsg db 'Sum of 2 and 3 : ' ; message to help display result
	sumLen equ $ - sumMsg ; length of result message

	usrMsg db 'Please type your name: ' ; message asking for input
	usrMsgLen equ $ - usrMsg ; length of user message

	usrMsgRpt db 'Your Name Is : ' ; feed back input to user
	usrMsgRptLen equ $ - usrMsgRpt ; length of above string

	usrNameLen db 40 ; length of user name allowed

	newline db 0xa,0xd ; create newline variable & initialize
	newlinelen equ $-newline ; length of newline variable

; ------------------------------------------
; mark bss section
; this is where uninitialized vars are made
; ------------------------------------------
section .bss
	res resb 2 ; allocate memory for result variable
	inpUsr resw 10 ; allocate memory for user input

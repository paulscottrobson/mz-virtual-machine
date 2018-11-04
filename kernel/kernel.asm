; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		kernel.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		4th November 2018
;		Purpose :	MZ Virtual Kernel
;
; ***************************************************************************************
; ***************************************************************************************

Stack = $5C00

			org 	$8000

			di 											; no interrupts possible ever :)
			ld 		ix,MainLoop 						; IX is the 'next instruction'
			ld 		sp,DemoCode 						; SP contains the code address

; ***************************************************************************************
;
;			Main loop comes here. SP contains address of next instruction.
;			8000-FFFF => Z80 code at that address
;			0000-7FFF => Call routine at that address | 0x8000
;
; ***************************************************************************************

MainLoop:	
			pop 	hl 									; get next instruction.
			bit 	7,h 								; if bit 7 is set, it is an instruction
			jr 		z,IsCallRoutine 					; otherwise, it's a call instruction
			jp 		(hl) 								; go do the instruction

;
;	A standard instruction takes 10 + 8 + 7 + 4 + 8 T-States = 37 T-States
;
; 	A call instruction takes 10 + 8 + 12 + 4 + 20 + 11 + 11 + 4 + 8 + 6 + 12 = 106
;
; ***************************************************************************************
;
;			Call routine. HL contains the routine address to call, save that
;			bit 15 is zero.
;
; ***************************************************************************************

IsCallRoutine:
			exx 										; switch to alt register set, save target

StackPointer:
			ld 		(Stack),sp 							; save stack. This address is modified.

			ld 		hl,StackPointer+2 					; bump the 'stack pointer'
			inc 	(hl) 								; e.g. the above save address
			inc 	(hl)								; but only the LSB of that address

			exx 										; get the address back
			set 	7,h 								; make address in $8000-$FFFF
			ld 		sp,hl 								; put in SP i.e. 'go there'
			jp 		(ix) 								; and execute next.

; ***************************************************************************************
;
;			This is a return instruction. It undoes the change of the
; 			address at the instruction at 'StackPointer' and reloads
;			the address.
;
; ***************************************************************************************

; @word 	;

ReturnCode:	ld 		hl,(StackPointer+2) 				; get the stack pointer
			dec 	l 									; back wind it.
			dec 	l
			ld 		(StackPointer+2),hl 				; write it back.
			ld 		(Reloader+1),hl 					; and overwrite the code that loads this
Reloader:	ld 		hl,(0000)							; this address here.
			;
			; TODO: here, H bit 0 indicates a far return.
			;
			ld 		sp,hl 								; and go there
			jp 		(ix) 								; execute again.


DemoCode:	dw 		TestWord1
			dw 		TestCall1 & 0x7FFF

			org 	0x9000
			align 	2
TestWord1:	inc 	de
			jp 		(ix)

TestCall1:	dw 		ReturnCode


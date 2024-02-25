[org 0x0100]

jmp start

;variables ending with start1 and start2 etc contain the row number

dimLength: dw 200 ;number of rows in screen
dimWidth: dw 320 ;number of columns in screen

;buffer1: times 2000 dw 0

backgroundEnd: dw 66 ;row number where the background ends i.e 1/3rd
foregroundEnd: dw 135 ;row number where the foreground ends i.e 2/3rd


carStart1: dw 71 
carStart2: dw 105


brickStart1: dw 140
brickStart2: dw 167
brickStart3: dw 194

;can be positive or negative. moves the brick left or right from center by the help of brickflag
brickmove1: dw 0
brickmove2: dw 0
brickmove3: dw 0

;decides whether brick will be left from center or right from center
brickflag1: dw 0
brickflag2: dw 1
brickflag3: dw 0

;colors of all the bricks
brickC1: db 0x0E ;yellow
brickC2: db 0x2B ;orange
brickC3: db 0x0A ;green

;decides what is the colour of the new brick and it goes in brickC1
brickColourRandom: dw 0

;decides brick speed i.e how much is added or subtracted to brickmove
brickSpeed: dw 3

;check if blue brick already present for increasing count and setting count
blueBrickFlag: dw 0

;count that acts as timer for blue brick
blueBrickCount: dw 0


rabbitStart: dw 179

;can be positive or negative. moves the rabbit left or right from center. We use brickflag3 as rabbitflag as rabbit will always be on brick3
rabbitMove: dw 0


carrotStart: dw 164

;decides if carrot will be generated or not
carrotRandom: dw 0

;can be positive or negative. moves the carrot left or right from center by the help of carrotMoveFlag and is randomly generated
carrotMoveRand: dw 0

;decides whether the carrot will be left from center or right from center
carrotMoveFlag: dw 0


oldisr1: dd 0 ;kbisr

oldisr2: dd 0 ;timer

score: dw 0 ;contains current score

scoreflag: dw 1 ;flag that determines if score would be incremented

tickcount: dw 0 ;current number of seconds in timer

tickdel: dw 0 ;when 18, 1 second is passed and tickcount is incremented

escape: dw 0 ;if 1, it means game is paused

gameEnd: dw 0 ;if 1, game will end

random: dw 0 ;value stored in this variable after rand function is called


;starting prompts
prompt1: db "Welcome to Rabbit Jump!", $ ;23
prompt2: db "Keep jumping and catching those carrots!", $ ;40
prompt3: db "Aim for a high score!", $ ;21
prompt4: db "GoodLuck! Game will start shortly...", $ ;36
prompt5: db "Ziyad 22L-6855", $ ;14
prompt6: db "Iman  22L-6854", $ ;14

;ending prompts
prompt7: db "GAME OVER!", $ ;10
prompt8: db "SCORE: ", $ ;7
prompt10: db "Program will terminate shortly...", $ ;33

;pause screen prompt
prompt9: db "Press Esc again to quit. Press Enter to continue", $ ;48

scoreP: db "Score:"

timeP: db "Timer:"

brickChance: dw 0

;--------------------------------------------------USEFUL FUNCTIONS------------------------------------------------------------------
clrscr:
	push es
	push ax
	push di
	push bx
	
	mov ax, 0xA000
	mov es, ax
	xor di, di
	
	mov bl, 0x00
	mov ax, [dimWidth]
	mul word[dimLength]
	
	nextPixel: mov [es:di], bl
		inc di
		cmp di, ax
		jne nextPixel
		
	pop bx
	pop di
	pop ax
	pop es
	ret
	
	
clrscr3b:
	push es
	push ax
	push di
	push bx
	
	mov ax, 0xA000
	mov es, ax
	mov di, 43520
	
	mov bl, 0x00
	mov ax, [dimWidth]
	mul word[dimLength]
	
	nextPixel3b: mov [es:di], bl
		inc di
		cmp di, ax
		jne nextPixel3b
		
	pop bx
	pop di
	pop ax
	pop es
	ret
	
rand:
	push bp
	mov bp, sp
	pusha
	
	rdtsc ;this command brings a random value to ax by reading time stamp counter
	xor  dx, dx
	mov  cx, [bp+4]
	div  cx
	mov [cs:random],dl

	popa 
	pop bp
	ret 2

delay:
	push cx
	push ax
	push bx
	
	mov ax, 50
	xor bx, bx
	
	time:
		mov cx, 0xffff
		time1:
			loop time1
		inc bx
		cmp bx, ax
		jne time
	
	pop bx
	pop ax
	pop cx
	ret
	
shiftScreenRight:
		push bp
		mov bp, sp
		push dx
		push ax
		push es
		push ds
		push cx
		sub sp, 2
		
		mov dx,60;number of rows
		
		mov ax,0xA000
		mov es,ax
		mov ds,ax
		
		
		;starting pixels
		mov si,2878
		mov di,2879
	
	loopShiftRight:	
		
		mov al, [es:di]
		mov [bp - 2], al
		mov cx, 319
		
		nextShiftRight:
			movsb
			sub si, 2
			sub di, 2
			loop nextShiftRight
			
		mov al, [bp - 2]
		mov [es:di], al
		add si, 319
		add di, 319
		add si, 320
		add di, 320
		sub dx, 1
		jnz loopShiftRight
		
	add sp,2
	pop cx
	pop ds
	pop es
	pop ax
	pop dx
	pop bp
	ret
		
shiftScreenLeft:
		push bp
		mov bp, sp
		push dx
		push ax
		push es
		push ds
		push cx
		sub sp, 2
		
		mov dx, 27 ;number of rows
		mov ax, 0xA000
		mov es, ax
		mov ds, ax
		
		;starting pixels
		mov si, [bp + 4]
		inc si
		mov di, [bp + 4]
	
	loopShiftLeft:	
		
		mov al, [es:di]
		mov [bp-2], al
		mov cx, 319
		
		rep movsb
		
		mov al, [bp - 2]
		mov [es:di], al
		
		sub si, 319
		sub di, 319
		add si, 320	
		add di, 320
		sub dx, 1
		jnz loopShiftLeft
		
		
	add sp,2
	pop cx
	pop ds
	pop es
	pop ax
	pop dx
	pop bp
	ret 2
		
ShiftScreenDown:
	
	push bp
	mov bp,sp
	push ds
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	
	mov ax,0xA000
	mov es,ax
	mov ds,ax

	std ;set auto decrement mode

	mov bx,26 ;how many times we need to shift down
	
	loop24:
		mov di,63999
		mov si, 63679
		mov dx,60 ;rows starting from last that we need to shift down
		loop23:
			mov cx,320
			rep movsb
			sub dx,1
			jnz loop23
		sub bx,1
	jnz loop24
	
	cld;set auto increment mode
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop ds
	pop bp
	ret 
	
ShiftScreenUp:

	push bp
	mov bp,sp
	push ds
	push es
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	sti ;set interupts for timer
	
	;2 blue conseq
	mov word [blueBrickCount], 0 ; every jump resets timer count of blue brick
	mov word [blueBrickFlag], 0 ; every jump resets if blue
	
	;to avoid stack problems
	mov ax,cs
	mov ds,ax
	
	;shift rabbit up before calling shiftscreendown a total of 27 rows
	sub word [rabbitStart], 3 ;outside loop as 27 is an odd number
	
	mov cx, 6
	loopmov:
		sub word [rabbitStart], 4
		call ReservedSpace
		call PrintAnimation ;so that animation doesnt stop when upkey is pressed
		loop loopmov
	
	
	;We need to implement score checks and game over checks before changing rabbit start
	
	;increase score check
	mov word [scoreflag], 1
	
	;right check
	mov ax, [rabbitMove]
	add ax, 145
	
	mov bx, 157
	add bx, 5;carrot length
	add bx, [carrotMoveRand]
	
	cmp word ax, bx
	jl skips2
		mov word [scoreflag], 0
	skips2:
	
	;left check
	mov ax, 145
	add ax, 20 ;rabbit length
	add ax, [rabbitMove]
	sub bx, 5 ;carrot length

	cmp word ax, bx
	jg skips3
		mov word [scoreflag], 0
	skips3:
	
	;if carrot does not exist, dont increase score
	cmp word [carrotRandom], 0
	je CarrotGen
		mov word [scoreflag], 0
	CarrotGen:
	
	
	cmp word[scoreflag], 0
	je dontincS
		inc word [score] ;score is incremented
		
		;setting speed based on score
		xor dx, dx
		mov ax, [score] 
		mov bx, 3
		div bx
		cmp dl, 0
		jne dontincS
			inc word [brickSpeed]
	dontincS:
	
	
	;game over check
	;left check
	mov ax, [rabbitMove]
	add ax, 35
	cmp ax, [brickmove2] ;comparing with brick 2 only as the rabbit always lands on brick2
	jge skipbb1
		mov word [gameEnd], 1
	skipbb1:
		;right check
		sub ax, 80
		cmp ax, [brickmove2]
		jle skipbb2
			mov word [gameEnd], 1
		skipbb2:
		
	
	;shift rabbit back down
	call ShiftScreenDown
	
	;original position
	add word [rabbitStart], 27
	
	
	;shift flags down. Flag1 will be random
	mov ax, [brickflag1]
	mov bx, [brickflag2]
	
	mov word [brickflag2], ax
	mov word [brickflag3], bx
	
	;random flag1
	push word 2
	call rand
	mov ax, [random]
	mov [brickflag1], ax
	
	;shift down current locations i.e column of each brick. brickmove1 will be randomly generated
	mov word ax, [brickmove1]
	mov word bx, [brickmove2]
	
	mov word [brickmove2], ax
	mov word [brickmove3], bx
	
	;random brickmove1
	
	push word 2
	call rand
	mov ax, [random]
	mov [brickChance], ax
	
	push word 40
	call rand
	mov ax, [random]
	cmp word [brickChance], 1 ;brickflag1 becasue 1/2 chance
	jne minusPos
		mov [brickmove1], ax
		jmp plusPos
	minusPos:
		xor bx, bx
		sub bx, ax
		mov [brickmove1], bx
	
	plusPos:
	
	
	;shift colours down. colour1 will be random
	mov byte al, [brickC1]
	mov byte bl,[brickC2]
	
	mov byte  [brickC2], al
	mov byte  [brickC3], bl
	
	;random colour1
	push word 4
	call rand
	
	mov ax, [random]
	mov [brickColourRandom], ax
	
	cmp word [brickColourRandom], 0
	je bc1
	cmp word [brickColourRandom], 1
	je bc2
	cmp word [brickColourRandom], 2
	je bc3
	cmp word [brickColourRandom], 3
	je bc4
	
	
	bc1:
		mov byte [brickC1], 0x0E ;yellow
		jmp skipbbb
		
	bc2:
		mov byte [brickC1], 0x2B ;orange
		jmp skipbbb
		
	bc3:
		mov byte [brickC1], 0x0A ;green
		jmp skipbbb
		
	bc4:
		mov byte [brickC1], 0x37 ;blue
		jmp skipbbb
	
	skipbbb:
	
	
	;random carrot print
	push word 3
	call rand
	
	mov ax, [random]
	mov [carrotRandom], ax
	
	;random carrot position in row
	push 2
	call rand
	mov ax, [random]
	mov [carrotMoveFlag], ax
	
	push word 40
	call rand
	mov ax, [random]
	
	cmp word [carrotMoveFlag], 0
	je carrotLeftRand
		mov [carrotMoveRand], ax
		jmp carrotRightRand
	
	carrotLeftRand:
		xor bx, bx
		sub bx, ax
		mov [carrotMoveRand], bx
		
	carrotRightRand:
	
	
	
	cli
	
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop ds
	pop bp
	ret
	
kbisr:
	push es
	pusha
	
	
	in al, 0x60 ; read a char from keyboard port
	cmp al, 0x48 ; upkey
	je upk
	cmp al, 1 ;escape
	je PrintConfirm
	cmp al, 28 ;enter
	je Resume

	nomatch:
		popa
		pop es
		mov al, 0x20
		out 0x20, al	; send EOI to PIC (end of interface to program interface controller)
		iret; jmp far [cs:oldisr1]

	PrintConfirm:
	
		cmp word [cs:escape], 1
		jne skipconf
			mov word [gameEnd], 1

		skipconf:
		call PrintConfirmm
		mov al, 0x20
		out 0x20, al	; send EOI to PIC
		popa
		pop es
		iret ;jmp far [cs:oldisr1]
	
	Resume:
		
		cmp word [escape], 1
		jne Resume1
			mov word [escape], 0
			call PrintStartScreen
		Resume1:
		mov al, 0x20
		out 0x20, al	; send EOI to PIC
		popa
		pop es
		iret ;jmp far [cs:oldisr1]
		
	upk:
		
		cmp word [escape], 1
		je skipup
			call ShiftScreenUp
		skipup:
		mov al, 0x20
		out 0x20, al	; send EOI to PIC
		popa
		pop es
		iret ;jmp far [cs:oldisr1]


setkbisr:
	push es
	push ax
	xor ax, ax
			mov es, ax
			mov ax, [es:9*4]
			mov [oldisr1], ax
			mov ax, [es:9*4+2]
			mov [oldisr1+2], ax
			cli
			mov word [es:9*4], kbisr ; store offset at n*4
			mov [es:9*4+2], cs ; store segment at n*4+2
			sti
			
	pop ax
	pop es
	ret
		
timer:		
	push ax
	inc word [cs:tickdel]
	
	cmp word [cs:tickdel], 18
	jne skipdel
		
		xor ax, ax
		mov [cs:tickdel], ax
		inc word [cs:tickcount] ;increment each second
		
	skipdel:
	

	mov al, 0x20
	out 0x20, al ; end of interrupt

	pop ax
	iret ; return from interrupt
;------------------------------------------------------
setTimer:
		push es
		push ax
			xor ax, ax
			mov es, ax ; point es to IVT base
			
			mov ax, [es:8*4]
			mov [oldisr2], ax
			mov ax, [es:8*4+2]
			mov [oldisr2+2], ax
			cli ; disable interrupts
			mov word [es:8*4], timer; store offset at n*4
			mov [es:8*4+2], cs ; store segment at n*4+2
			sti ; enable interrupts

		pop ax
		pop es
		ret

printnum:
	push bp
	mov bp, sp
	push es
	pusha


	mov si, [bp+4] ; load number in ax= 4529
	mov ax, si

	mov bx, 10 ; use base 10 for division
	mov cx, 0

	nextdigit: mov dx, 0 ; zero upper half of dividend
	div bx ; divide by 10 AX/BX --> Quotient --> AX, Remainder --> DX .....
	add dx, 0x30 ; convert digit into ascii value
	push dx ; save ascii value on stack

	inc cx ; increment count of values
	cmp ax, 0 ; is the quotient zero
	jnz nextdigit ; if no divide it again

	mov bh, 00
	mov bl, [bp + 6] ;color
	mov dl, [bp + 10] ;col
	mov dh, [bp + 8]  ;row
	mov ah, 02h    ; BIOS.SetCursorPosition - Point to the location of dx and page no. of bh
	int 10h

	nextpos: pop ax; remove a digit from the stack
	mov ah,  0x0E
	int 10h
	inc dl
	add si, 1
	loop nextpos ; repeat for all digits on stack

	popa
	pop es
	pop bp
	ret 8
	
;------------------------------------------------------------ANIMATION----------------------------------------------------------------------
PrintAnimation:
	push cx
	
	xor cx, cx
	
	mov cx, 1
	
	shiftR:
	cmp word[escape],1
	je skipr0
		call shiftScreenRight
		skipr0:
		loop shiftR
		
	mov cx, 5
	
	shiftL1:
		cmp word[escape],1
	je skipl0
		push word 22080
		call shiftScreenLeft
		skipl0:
		loop shiftL1
		
	mov cx, 2
	
	shiftL2:
	cmp word[escape],1
	je skipl2
		push word 32960
		call shiftScreenLeft
		skipl2:
		loop shiftL2
	
	pop cx
	ret
	
;-----------------------------------------------------------START_SCREEN-------------------------------------------------------------------
PrintStartScreen:
	call PrintBackground
	call PrintForeground
	call ReservedSpace
	
	ret


;------------------------------------------------------------BACKGROUND----------------------------------------------------------------------
PrintBackground:
	call PrintSky
	call PrintMountains
	
	ret
	
PrintSky:

	push es
	push ax
	push di
	push bx
	
	mov ax, 0xA000
	mov es, ax
	mov di, 0
	
	mov bl, 0x36
	
	mov ax, [backgroundEnd]
	mul word [dimWidth]
	
	nextSkyPixel: mov [es:di], bl
		inc di
		cmp di, ax
		jne nextSkyPixel
		
	pop bx
	pop di
	pop ax
	pop es
	ret
	
PrintMountains:
	
	push es
	push ax
	push di
	push si
	push cx
	push dx
	push bx
	
	mov ax, 0xA000
	mov es, ax
	
	;calculate starting pixel
	mov ax, [backgroundEnd]
	sub ax, 1
	mul word [dimWidth]
	
	mov di, ax ;starting pixel
	mov bx, 8;number of mountains
	
	nextMountain:
		mov cx, 40 ;size of mountains
		mov dl, cl
		firstHalfMountain:
			mov dh, dl
			mov si, di
			l1:
				;to avoid going in the next line after one last row complete
				add ax, [dimWidth]
				sub ax, 1
				cmp di, ax
				jle skipR1
					sub di, [dimWidth]
				skipR1:
					sub ax, [dimWidth]
					add ax, 1

				;printing mountain
				mov byte [es:di], 0x2B
				inc di
				dec dh
				jnz l1
			mov di, si
			
			;move a pixel 1 up and 1 right
			sub di, [dimWidth]
			add di, 1
			
			dec dl
			loop firstHalfMountain
		
		;nullify the last extra addition by bringing pixel 1 down and 1 left
		add di, [dimWidth]
		sub di, 1
		
		mov cx, 40;size of mountains
		mov dl, 1
		secondHalfMountain:
			mov dh, dl
			mov si, di
			l2:
				;to avoid going in the next line after last row complete
				add ax, [dimWidth]
				sub ax, 1
				cmp di, ax
				jle skipR2
					sub di, [dimWidth]
				skipR2:
					sub ax, [dimWidth]
					add ax, 1
					
				;printing mountain
				mov byte [es:di], 0x2A
				inc di
				dec dh
				jnz l2
			mov di, si
			
			;move 1 down
			add di, [dimWidth]
			inc dl
			loop secondHalfMountain
		
		;nullify last addition by moving 1 up
		sub di, [dimWidth]
		
		dec bx
		jnz nextMountain
		
	pop bx
	pop dx
	pop cx
	pop si
	pop ax
	pop di	
	pop es
	ret

	
	
;-------------------------------------------------------------FOREGROUND------------------------------------------------------------------
PrintForeground:

	call PrintRoad
	
	push word[carStart1]
	call PrintCar
	
	push word[carStart2]
	call PrintCar
	
	ret


PrintRoad:
	push es
	push ax
	push di
	push si
	push bx
	
	mov ax, 0xA000
	mov es, ax
	
	;for top border
	;calculate starting pixel
	mov ax, [dimWidth]
	mul word[backgroundEnd]
	mov di, ax
	
	;calculate ending pixel
	mov ax, [backgroundEnd]
	add ax, 3
	mul word[dimWidth]
	
	
	;print top border
	nextblack:
		mov byte [es:di], 0x2B
		inc di
		cmp di, ax
		jne nextblack


	;for main road
	;calculate ending pixel
	;starting pixel will just be di and will already have the value we need from the previous loop
	mov ax, [foregroundEnd]
	sub ax, 3
	mul word[dimWidth]
	
	;print main road
	nextchar4: mov byte [es:di], 0x17
		inc di
		cmp di, ax
		jne nextchar4
	
	
	;for bottom border
	;calculate ending pixel 
	;starting pixel will just be di and will already have the value we need from the previous loop
	mov ax, [foregroundEnd]
	mul word[dimWidth]
	
	;print bottom border
	nextblack2:
		mov byte [es:di], 0x2B
		inc di
		cmp di, ax
		jne nextblack2
		
	
	;print stripes in middle
	mov ax, [foregroundEnd] ;135
	mov di, [backgroundEnd] ;66
	
	sub ax, di
	;divide by 2
	shr ax, 1
	add ax, [backgroundEnd]
	mul word[dimWidth]
	
	mov di, ax
	
	add ax, [dimWidth]
	sub ax, 1

	middleRoad:
		mov si, di
		add si, 32;size of strips?
		roadColB:
			mov byte [es:di], 0x0F
			mov byte [es:di + 320], 0x0F
			mov byte [es:di - 320], 0x0F
			inc di
			;checking end of row
			cmp di, ax
			jge skipR
			cmp di, si
			jne roadColB
	
		add di, 32
		cmp di, ax
		jle middleRoad
		
	skipR:
	
	
	pop bx
	pop si
	pop di
	pop ax
	pop es
	ret

PrintCar:  

	push bp
	mov bp, sp
	push es
	push ax
	push di
	push cx
	push si
	push dx
	push bx
	
	mov ax, 0xA000
	mov es, ax
	
	mov ax, [bp + 4]
	mov bx, [dimWidth]
	mul bx
	mov di, ax; 71 x 320 
	
	mov bl, 0x20 ;blue
	mov bh, 0x0E ;yellow
	
	mov dl, 0x04 ;red
	mov dh, 0x00 ;black
	
	;row1
	mov si, di ;storing di
	add di, 28
	
	mov [es:di], bl
	inc di
	mov [es:di], bl
	inc di
	mov [es:di], dl
	inc di
	mov [es:di], dl
	
	mov di, si
	add di, 320
	add di, 28
	
	mov [es:di], bl
	inc di
	mov [es:di], bl
	inc di
	mov [es:di], dl
	inc di
	mov [es:di], dl
	inc di
	

	mov si, di ;storing di
	
	;row2
	add di, 314
	mov [es:di], bl
	inc di
	mov [es:di], bl
	inc di
	mov [es:di], bl 
	inc di
	mov [es:di], bl
	inc di
	mov [es:di], dl
	inc di
	mov [es:di], dl
	inc di
	mov [es:di], dl
	inc di
	mov [es:di], dl
	
	mov di, si
	add di, 320
	
	add di, 314
	mov [es:di], bl
	inc di
	mov [es:di], bl
	inc di
	mov [es:di], bl
	inc di
	mov [es:di], bl
	inc di
	mov [es:di], dl
	inc di
	mov [es:di], dl
	inc di
	mov [es:di], dl
	inc di
	mov [es:di], dl
	
	add di, 310
	mov al, 18
	mov ah, 3
	mov si, di
	
	mov cl, 18
	r31:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r31
	
	mov di, si
	add di, 638
	mov si, di
	
	
	mov cl, 4
	r41:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r41
		
	mov cl, 6
	r42:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop r42
	
	mov cl, 2
	r43:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r43
	
	mov cl, 6
	r44:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop r44
	
	mov cl, 4
	r45:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r45
		
	mov di, si
	add di, 638
	mov si, di
	
	mov cl, 4
	r51:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r51
		
	mov cl, 8
	r52:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop r52
		
	mov cl, 2
	r53:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r53
		
	mov cl, 8
	r54:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop r54
		
	mov cl, 4
	r55:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r55
		
	mov di, si
	add di, 634
	mov si, di
	mov cl, 8
		
	r61:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r61
		
	
	mov cl, 10
	r62:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop r62
		
	mov cl, 2
	r63:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r63
		
	mov cl, 10
	r64:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop r64
	
	mov cl, 4
	r65:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r65
	
	
	mov di, si
	add di, 632
	mov si, di
	mov cl, 46
	r7:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r7
		
	mov di, si
	add di, 636
	mov si, di
	mov cl, 52
	
	r81:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r81
		
	mov di, si
	add di, 638
	mov si, di
	mov cl, 8
	
	r91:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r91
		
	mov cl, 4
	r92:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop r92
		
	mov cl, 30
	r93:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r93
	
	mov cl, 4
	r94:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop r94
		
	mov cl, 6
	r95:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop r95
		
	mov cl, 2
	r96:
		mov [es:di], dl
		mov [es:di + 320], dl
		inc di
		loop r96
		
	mov cl, 2
	r97:
		mov [es:di], bh
		mov [es:di + 320], bh
		inc di
		loop r97
		
			
	mov di, si
	add di, 640
	add di, 2
	mov si, di
	mov cl, 4
	
	rA1:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop rA1
	
	mov cl, 8
	rA2:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop rA2
		
	mov cl, 26
	rA3:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop rA3
				
	mov cl, 8
	rA4:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop rA4
		
	mov cl, 6
	rA5:
		mov [es:di], dh
		mov [es:di + 320], dh
		inc di
		loop rA5
		
	mov di, si
	add di, 644
	mov si, di
	mov cl, 8
	
	rB1:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop rB1
		
	add di, 26
	mov cl, 8
	rB2:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop rB2
	
	mov di, si
	add di, 640
	add di, 2
	mov cl, 4
	rC1:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop rC1
		
	add di, 30
	mov cl, 4
	rC2:
		mov byte[es:di], 0x07
		mov byte[es:di + 320], 0x07
		inc di
		loop rC2
		
	
	pop bx
	pop dx
	pop si
	pop cx
	pop di
	pop ax
	pop es
	pop bp
	ret 2


ReservedSpace:
	
	push es
	push ax
	push di
	push bx

	mov ax, 0xA000
	mov es, ax
	
	mov ax, [foregroundEnd]
	mov bx, 320
	
	mul bx
	
	mov di, ax	
	
	
	nextcharR: 
		mov byte [es:di], 0x02
		inc di
		cmp di, 64000
		jne nextcharR
		
	
	call PrintBrick
	
	cmp word [carrotRandom], 0
	jne skipcarrotPrint
	
	call PrintCarrot
	
	skipcarrotPrint:
	
	call PrintRabbit
	
	call PrintScore
	
	call PrintTimer
	
	
	pop bx	
	pop di
	pop ax
	pop es
	ret
	
PrintBrick:
	push es
	push ax
	push bx
	push cx
	push di
	
	mov ax, 0xA000
	mov es, ax
	
	mov ax, [brickStart1]
	mov bx, [dimWidth]
	mul bx
	add ax, 130 ;for centre
	add ax, [brickmove1]

	
	mov di, ax
	mov ah, 3
	
	
	b1:
		mov cx, 60 ;length of brick
		mov byte al, [brickC1]
		rep stosb
		add di, 260
		dec ah
		jnz b1
		
	
	mov ax, [brickStart2]
	mov bx, [dimWidth]
	mul bx
	add ax, [brickmove2]
	add ax, 130 ; for centre
	
	mov di, ax
	mov ah, 3
	
	b2:
		mov cx, 60 ;lenght of brick
		mov byte al, [brickC2]
		rep stosb
		add di, 260
		dec ah
		jnz b2
		
		
	mov ax, [brickStart3]
	mov bx, [dimWidth]
	mul bx
	add ax, [brickmove3]; for centre
	add ax, 130
	
	mov di, ax
	mov ah, 3
	
	b3:
		mov cx, 60 ;lenght of brick
		mov byte al, [brickC3]
		rep stosb
		add di, 260
		dec ah
		jnz b3
		
	pop di
	pop cx
	pop bx
	pop ax
	pop es
	ret
	
MoveBricks:
	push ax
	push bx
	
	call ReservedSpace

	mov bx, [brickSpeed]
	
	cmp byte [brickC1], 0x37 ;blue
	je exit1
	
	cmp word [brickflag1], 0
	je add1
	cmp word [brickflag1], 1
	je minus1
	
	add1:
	add word[brickmove1], bx
	cmp word[brickmove1], 40
	jle rightcheck1
		mov word[brickflag1], 1
	rightcheck1:
	jmp exit1
	
	minus1:
	sub word[brickmove1], bx
	cmp word[brickmove1], -40
	jge exit1
		mov word[brickflag1], 0
	
	exit1:
	
	
	cmp byte [brickC2], 0x37
	je exit2
	
	cmp word [brickflag2], 0
	je add2
	cmp word [brickflag2], 1
	je minus2
	
	add2:
	add word[brickmove2], bx
	cmp word[brickmove2], 40
	jle rightcheck2
		mov word[brickflag2], 1
	rightcheck2:
	jmp exit2
	
	minus2:
	sub word[brickmove2], bx
	cmp word[brickmove2], -40
	jge exit2
		mov word[brickflag2], 0
	
	exit2:
	
	
	cmp byte [brickC3], 0x37
	je setBlueBrickFlag
	
	cmp word [brickflag3], 0
	je add3
	cmp word [brickflag3], 1
	je minus3
	
	add3:
	add word[brickmove3], bx
	add word[rabbitMove], bx
	cmp word[brickmove3], 40
	jle rightcheck3
		mov word[brickflag3], 1
	rightcheck3:
	jmp exit3
	
	minus3:
	sub word[brickmove3], bx
	sub word[rabbitMove], bx
	cmp word[brickmove3], -40
	jge exit3
		mov word[brickflag3], 0
		jmp exit3
	
	
	setBlueBrickFlag:
	cmp word [blueBrickFlag], 1
	je checkBlueBrickFlag
		mov word [blueBrickFlag], 1
		mov word ax, [tickcount]
		add ax, 3
		mov word [blueBrickCount], ax
		jmp exit3
	
	checkBlueBrickFlag:
		mov word ax, [tickcount]
		cmp word ax, [blueBrickCount]
		jl exit3
		mov word [gameEnd], 1
	
		
	exit3:
	
	pop bx
	pop ax
	ret

	
PrintRabbit:
	push es
	push ax
	push bx
	push cx
	push di
	
	mov ax, 0xA000
	mov es, ax
	
	mov ax, [rabbitStart]
	mov bx, [dimWidth]
	mul bx
	add ax, [rabbitMove]
	add ax, 145; for centre
	
	mov di, ax
	mov ah, 15
	
	r1:
		mov cx, 20 ;length of rabbit
		mov al, 0x0F
		rep stosb
		add di, 300
		dec ah
		jnz r1
		
	pop di
	pop cx
	pop bx
	pop ax
	pop es
	ret
	
PrintCarrot:
	
	push es
	push ax
	push bx
	push cx
	push di
	
	mov ax, 0xA000
	mov es, ax
	
	mov ax, [carrotStart]
	mov bx, [dimWidth]
	mul bx
	add ax, 157; for centre
	
	add ax, [carrotMoveRand]
	mov di, ax
	mov ah, 3
	
	c1:
		mov cx, 5 ;length of carrot
		mov al, 0x2A
		rep stosb
		add di, 315
		dec ah
		jnz c1
		
		
	pop di
	pop cx
	pop bx
	pop ax
	pop es
	ret
	
PrintScore:
	push es
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 0x0F
	mov dx, 0x001F
	mov cx, 6
	push cs
	pop es
	mov bp, scoreP
	int 0x10 ;message print
	
	;score
	mov ax, 0x25 ;col
	push ax
		
	mov ax, 0x00 ;row
	push ax
	
	mov al, 0x0F
	push ax

	push word [score]

	call printnum ; print tick count
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	ret
	
PrintTimer:
	push es
	pusha
	
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 0x0F
	mov dx, 0x0000
	mov cx, 6
	push cs
	pop es
	mov bp, timeP
	int 0x10 ;message print
	
	
	;seconds
	mov ax, 0x06 ;col
	push ax
		
	mov ax, 0x00 ;row
	push ax
	
	mov al, 0x0F
	push ax

	push word [cs:tickcount]

	call printnum ; print tick count
	
	
	popa
	pop es
	ret

PrintIntro:
	pusha
	push es
	
	call clrscr
	
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x0900
	mov cx, 23
	push cs
	pop es
	mov bp, prompt1
	int 0x10 ;message print
	
	mov cx, 40
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x0B00
	push cs
	pop es
	mov bp, prompt2
	int 0x10 ;message print
	
	mov cx, 21
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x0D00
	push cs
	pop es
	mov bp, prompt3
	int 0x10 ;message print
	
	mov cx, 36
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x0F00
	push cs
	pop es
	mov bp, prompt4
	int 0x10 ;message print
	
	mov cx, 14
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x1603
	push cs
	pop es
	mov bp, prompt6
	int 0x10 ;message print
	
	mov cx, 14
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x1703
	push cs
	pop es
	mov bp, prompt5
	int 0x10 ;message print
	

	pop es
	popa
	ret
	
PrintOutro:
	pusha
	
	mov cx, 10
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x0B0F
	push cs
	pop es
	mov bp, prompt7
	int 0x10 ;message print
	
	mov cx, 7
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x0D0F
	push cs
	pop es
	mov bp, prompt8
	int 0x10 ;message print
	
	push 0x15
	push 0x0D
	push 0x0F
	
	push word [score]
	call printnum
	
	mov cx, 33
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x0F04
	push cs
	pop es
	mov bp, prompt10
	int 0x10 ;message print
		
	
	popa
	ret

PrintConfirmm:

	pusha
	push es
	
	mov word [cs:escape], 1
	call clrscr
	
	mov cx, 48
	mov ah, 0x13   ;string printing
	mov al, 1
	mov bh, 0
	mov bl, 7
	mov dx, 0x0D00
	push cs
	pop es
	mov bp, prompt9
	int 0x10 ;message print
	

	pop es
	popa
	ret

start:
	
	; mov cx, 2000
	; mov di, 0
	; mov ax, 0Xb800
	; mov es, ax
	
; ll2:	
; mov ax, [es:di]
	; mov word[buffer1+di], ax
	; add di,2
	; loop ll2
	
	;graphic mode
	mov  ax, 0x0013
	int 0x10
	
	;Introdution screen
	call PrintIntro
	
	mov cx, 4
	dell:
		call delay
		loop dell
	
	call PrintStartScreen
	
	call setkbisr
	
	call setTimer

	
	 infiniteLoop:
		cmp word [gameEnd], 1
		je end
		cmp word [escape], 1
		je skipanim
			call PrintAnimation
			call MoveBricks
			;call clrscr3
			jmp infiniteLoop
		skipanim:
	 jmp infiniteLoop

end:
	call clrscr
	call PrintOutro
	
	xor ax, ax
	mov es, ax
	
	
	;unhook keyboard
	mov ax, [oldisr1] ; read old offset in ax
	mov bx, [oldisr1+2] ; read old segment in bx
	cli ; disable interrupts
	mov [es:9*4], ax ; restore old offset from ax
	mov [es:9*4+2], bx ; restore old segment from bx
	sti
	
	
	;unhook timer
	mov ax, [oldisr2] ; read old offset in ax
	mov bx, [oldisr2+2] ; read old segment in bx
	cli ;disable interrupts
	mov [es:8*4], ax ; restore old offset from ax
	mov [es:8*4+2], bx ; restore old segment from bx
	sti
	
	mov cx, 4
	dell2:
		call delay
		loop dell2
	
	;back to text mode
	mov ax, 0x0003
	int 0x10
	
	; mov cx, 2000
	; mov di, 0
	; mov ax, 0Xb800
	; mov es, ax

; ll3:	
	; mov ax, word[buffer1+di]
	; mov [es:di],ax
	; add di,2
	; loop ll3
	
	mov ax, 0x4c00
	int 0x21
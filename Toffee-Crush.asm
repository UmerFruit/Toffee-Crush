;i22-0518 Umer Farooq
;i22-1636 Bilal Ikram
;i22-1632 Arsalan Javaid

;ON THE INITIAL SCREEN,PLEASE ENTER YOUR NAME FOR INPUT AND THEN PRESS ENTER
;THERE ARE 5 CANDIES AND 1 COLOR BOMB(The one with 5 colors)
;PRESS ESCAPE TO EXIT FROM THE GAME

hideMouseCursor macro  ;this macro hides the mouse cursor
	pushA
	mov ax,02
	int 33h
	
	mov ax,03
	int 33h
	mov mouseXCordSaveVar,cx
	mov mouseYCordSaveVar,dx
	
	mov ax,4
	mov cx,459
	mov dx,379
	int 33h

	popA
endm
showMouseCursor macro ;this macro shows the mouse cursor
	pushA	

	mov ax,4
	mov cx,mouseXCordSaveVar
	mov dx,mouseYCordSaveVar
	int 33h
	
	mov ax,01
	int 33h
	popA
endm

updateScore macro
	pushA
	mov dx,tempCandyNoForScore
	.if(isLevelOne==1)
		add levelOnePoints,dx
	.elseif(isLevelTwo==1)
		add levelTwoPoints,dx
	.elseif(isLevelThree==1)
		add levelThreePoints,dx
	.endif
	popA
endm

delay macro delayFactor
	pushA
	mov cx,1000
	.repeat
		mov bx,delayFactor      ;; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
		.repeat
			dec bx
		.until(bx==0)
	dec cx
	.until(cx==0)
	popA
endm
writePixel macro col

	mov ah, 0Ch
	mov al, col
	int 10h
endm
setcurs macro row, col, pg
	mov ah, 02
	mov bh, pg
	mov dh, row
	mov dl, col
	int 10h
endm
endl macro
	mov ah, 40h
	mov bx, handle
	mov cx, lengthof newLine
	mov dx, offset newLine
	int 21h
endm
makefile macro FileName

	mov ah,3dh
	mov dx,offset FileName
	mov al, 2  ;access code: 0 open for reading; 1 open for writing;2 for both 
	int 21h
endm

makescreen macro
	mov ah,00h
	mov al,12h ;using video mode 640 x 480 16 color graphics
	int 10h
	
	mov ah,00h   ; interrupt to get system timer in CX:DX 
	int 1AH
	mov randNumSeed, dx
endm
setActiveDisplay macro pageNo
	mov ah,05h
	mov al,pageNo 
	int 10h
endm
getRandNum macro firstNum,lastNum
	push 0000 ; local variable for random number
	push bp;storing base pointer if it is already being used
	mov bp,sp
	pushA
	.repeat
		mov     ax, 25173          ; LCG Multiplier
		mul randNumSeed
		add     ax, 13849          ; Add LCG increment value
		mov	randNumSeed, ax          ; Update seed = return value
		mov		dx,0
		mov     cx, 10    
		div     cx        ; here dx contains the remainder - from 0 to 9
	.until(dl>=firstNum && dl<=lastNum)
	mov dh,0
	mov word ptr[bp+2],dx ;moving rand no to the local variable
	popA; restoring registers
	pop bp;restore bp's previous value
	;now the random num will be stored at the top of the stack
endm
isEven macro num;returns 1 in top of the stack if number is even
	push 0000 ; local variable for random number
	push bp;storing base pointer if it is already being used
	mov bp,sp
	pushA
	mov ax,num
	mov bl,2 ;divisor
	div bl
	.if(ah==0);isEven
		mov word ptr[bp+2],1 ;moving one to the local variable
	.else;isOdd
		mov word ptr[bp+2],0 ;moving zero to the local variable
	.endif
	popA; restoring registers
	pop bp;restore bp's previous value
endm
getBit macro register,bitNumber ;only works with 16 bit register
	;returns the bitNumber in register that the user wants, bitNumber can be from 0-15
	shiftLogicalLeft register,15-bitNumber
	shiftLogicalRight register,15
endm

setmouse_xy macro
mov ax,7
mov cx,180
mov dx,460
int 33h

mov ax,8
mov cx,100
mov dx,380
int 33h

endm
coutfile macro var

	mov ah, 40h
	mov bx, handle
	mov cx, lengthof var
	mov dx, offset var
	int 21h

endm
shiftLogicalLeft macro register,count
	push cx
	mov cx,count
	.while(cx!=0)
		shl register,1
		dec cx
	.endw
	pop cx
endm

shiftLogicalRight macro register,count
	push cx
	mov cx,count
	.while(cx!=0)
		shr register,1
		dec cx
	.endw
	pop cx
endm



findCoordinatesOfCell macro cellNo ;this macro pushes the x and y coordinates of top left corner of the selected cell into the stack
	push 0000 ;y cordinate local variable
	push 0000 ; x coordinate local variable
	mov bp,sp; [bp] can access x coordinate, [bp+2] can access y coordinate variable
	pushA

	mov ax,cellNo ;cellNo/7 == Q: rowNum, R= colNum
	mov bl,7
	div bl ;Q=al, R=ah
	
	;First extracting remainder(colNum)
	mov al,ah
	mov ah,0
	;now remainder is in AX	
	mov bx,40
	mul bx; 40*colNum will be stored in DX:AX but the result will never go to DX but stay in AX as number is small
	add ax,180
	mov word ptr[bp],ax ;storing x coordinate in local variable
	

	mov ax,cellNo ;cellNo/7 == Q: rowNum, R= colNum
	mov bl,7
	div bl ;Q=al, R=ah
	;Now extracting Quotient(rowNum)
	mov ah,0
	;now quotient is in AX
	
	mov bx,40
	mul bx; 40*rowNum will be stored in DX:AX but the result will never go to DX but stay in AX as number is small
	add ax,100
	mov word ptr[bp+2],ax ;storing y coordinate in local variable
	popA
endm


multiply macro reg,intVal ;multiplies 2 values and returns the return value in ax
	pushA
	mov ax,reg
	mov bx,intVal
	mul bx
	mov bp,sp
	mov [bp+14],ax
	popA
endm

divide macro reg,intVal ;divides 2 values and returns the quotient value in al and remainder in ah
						;reg is dividend, intVal is divisor
	pushA
	mov ax,reg
	mov bl,intVal
	div bl
	mov bp,sp
	mov [bp+14],ax
	popA
endm
areCellsAdjacent macro box1,box2 ;this macro puts 1 in ax if both the cells are adjacent otherwise it puts 0 in ax
	push 0000 ;local variable
	mov bp,sp ;now [bp] can access local variable that will be 0 or 1 in accordance with the result of this macro and will later be popped into ax for returning
	pushA
	.if(box1==0)
		.if(box2==1 || box2==7)
			mov word ptr[bp],1
		.endif
	.elseif(box1==1)
		.if(box2==0 || box2==2 || box2==8)
			mov word ptr[bp],1
		.endif
	.elseif(box1==2)
		.if(box2==1 || box2==3 || box2==9)
			mov word ptr[bp],1
		.endif
	.elseif(box1==3)
		.if(box2==2 || box2==4 || box2==10)
			mov word ptr[bp],1
		.endif
	.elseif(box1==4)
		.if(box2==3 || box2==5 || box2==11)
			mov word ptr[bp],1
		.endif
	.elseif(box1==5)
		.if(box2==4 || box2==12 || box2==6)
			mov word ptr[bp],1
		.endif
	.elseif(box1==6)
		.if(box2==5 || box2==13)
			mov word ptr[bp],1
		.endif
	.elseif(box1==7)
		.if(box2==0 || box2==8 || box2==14)
			mov word ptr[bp],1
		.endif
	.elseif(box1==8)
		.if(box2==1 || box2==7 || box2==9 || box2==15)
			mov word ptr[bp],1
		.endif
	.elseif(box1==9)
		.if(box2==2 || box2==8 || box2==10 || box2==16)
			mov word ptr[bp],1
		.endif
	.elseif(box1==10)
		.if(box2==3 || box2==9 || box2==11 || box2==17)
			mov word ptr[bp],1
		.endif
	.elseif(box1==11)
		.if(box2==4 || box2==10 || box2==12 || box2==18)
			mov word ptr[bp],1
		.endif
	.elseif(box1==12)
		.if(box2==5 || box2==11 || box2==13 || box2==19)
			mov word ptr[bp],1
		.endif
	.elseif(box1==13)
		.if(box2==6 || box2==12 || box2==20)
			mov word ptr[bp],1
		.endif
	.elseif(box1==14)
		.if(box2==7 || box2==15 || box2==21)
			mov word ptr[bp],1
		.endif
	.elseif(box1==015)
		.if(box2==8 || box2==14 || box2==16 || box2==22)
			mov word ptr[bp],1
		.endif
	.elseif(box1==016)
		.if(box2==9 || box2==15 || box2==17 || box2==23)
			mov word ptr[bp],1
		.endif
	.elseif(box1==017)
		.if(box2==10 || box2==16 || box2==18 || box2==24)
			mov word ptr[bp],1
		.endif
	.elseif(box1==018)
		.if(box2==11 || box2==17 || box2==19 || box2==25)
			mov word ptr[bp],1
		.endif
	.elseif(box1==019)
		.if(box2==12 || box2==18 || box2==20 || box2==26)
			mov word ptr[bp],1
		.endif
	.elseif(box1==020)
		.if(box2==13 || box2==19 || box2==27)
			mov word ptr[bp],1
		.endif
	.elseif(box1==021)
		.if(box2==14 || box2==22 || box2==28)
			mov word ptr[bp],1
		.endif
	.elseif(box1==022)
		.if(box2==15 || box2==21 || box2==23 || box2==29)
			mov word ptr[bp],1
		.endif
	.elseif(box1==023)
		.if(box2==16 || box2==22 || box2==24 || box2==30)
			mov word ptr[bp],1
		.endif
	.elseif(box1==024)
		.if(box2==17 || box2==23 || box2==25 || box2==31)
			mov word ptr[bp],1
		.endif
	.elseif(box1==025)
		.if(box2==18 || box2==24 || box2==26 || box2==32)
			mov word ptr[bp],1
		.endif
	.elseif(box1==026)
		.if(box2==19 || box2==25 || box2==27 || box2==33)
			mov word ptr[bp],1
		.endif
	.elseif(box1==027)
		.if(box2==20 || box2==26 || box2==34)
			mov word ptr[bp],1
		.endif
	.elseif(box1==028)
		.if(box2==21 || box2==29 || box2==35)
			mov word ptr[bp],1
		.endif
	.elseif(box1==029)
		.if(box2==22 || box2==28 || box2==30 || box2==36)
			mov word ptr[bp],1
		.endif
	.elseif(box1==030)
		.if(box2==23 || box2==31 || box2==29 || box2==37)
			mov word ptr[bp],1
		.endif
	.elseif(box1==031)
		.if(box2==24 || box2==30 || box2==32 || box2==38)
			mov word ptr[bp],1
		.endif
	.elseif(box1==032)
		.if(box2==25 || box2==31 || box2==33 || box2==39)
			mov word ptr[bp],1
		.endif
	.elseif(box1==033)
		.if(box2==26 || box2==32 || box2==34 || box2==40)
			mov word ptr[bp],1
		.endif
	.elseif(box1==034)
		.if(box2==27 || box2==33 || box2==41)
			mov word ptr[bp],1
		.endif
	.elseif(box1==035)
		.if(box2==28 || box2==36 || box2==42)
			mov word ptr[bp],1
		.endif
	.elseif(box1==036)
		.if(box2==29 || box2==35 || box2==37 || box2==43)
			mov word ptr[bp],1
		.endif
	.elseif(box1==037)
		.if(box2==30 || box2==36 || box2==38 || box2==44)
			mov word ptr[bp],1
		.endif
	.elseif(box1==038)
		.if(box2==31 || box2==37 || box2==39 || box2==45)
			mov word ptr[bp],1
		.endif
	.elseif(box1==039)
		.if(box2==32 || box2==38 || box2==40 || box2==46)
			mov word ptr[bp],1
		.endif
	.elseif(box1==040)
		.if(box2==33 || box2==39 || box2==41 || box2==47)
			mov word ptr[bp],1
		.endif
	.elseif(box1==041)
		.if(box2==34 || box2==40 || box2==48)
			mov word ptr[bp],1
		.endif
	.elseif(box1==042)
		.if(box2==35 || box2==43)
			mov word ptr[bp],1
		.endif
	.elseif(box1==043)
		.if(box2==36 || box2==42 || box2==44)
			mov word ptr[bp],1
		.endif
	.elseif(box1==044)
		.if(box2==37 || box2==43 || box2==45)
			mov word ptr[bp],1
		.endif
	.elseif(box1==045)
		.if(box2==38 || box2==44 || box2==46)
			mov word ptr[bp],1
		.endif
	.elseif(box1==046)
		.if(box2==39 || box2==45 || box2==47)
			mov word ptr[bp],1
		.endif
	.elseif(box1==047)
		.if(box2==40 || box2==46 || box2==48)
			mov word ptr[bp],1
		.endif
	.elseif(box1==048)
		.if(box2==41 || box2==47)
			mov word ptr[bp],1
		.endif
	.endif	
	popA
	pop ax
endm

printSpace macro 
	pushA
	mov dx,' '
	mov ah,02
	int 21h
	popA
endm

printNum macro num
	pushA
	push 0000
	push num
	mov bp,sp; now [bp] can access number to print out and [bp+2] can access digit count
	 .repeat
		 mov ax, word ptr[bp]
		 mov dx,0
		 mov bx,10
		 div bx    
		 push dx
		 
		 mov word ptr[bp],ax
		 inc word ptr[bp+2]
	 .until(ax==0)
	 
	 .while(word ptr[bp+2]!=0)
		 dec word ptr[bp+2] 
		 pop dx
		 add dx,48
		 mov ah,02h
		 int 21h
	 .endw
	pop ax
	pop ax
	popA
endm

makeNullArray macro arrOffset,arrSize,nullNumber
	;this macro nullifies an array with the given number in nullNumber
	pushA
	mov bx arrOffset
	mov cx,arrSize
	mov si,0
	mov dx,nullNumber
	.while(cx!=0)
		mov [bx+si],dx
		add si,2
	.endw
	popA
endm

isCellInRange macro xSelect,ySelect,xPixel,yPixel ;returns 1 in ax if xSelect,ySelect coordinate are in the range of xPixel,yPixel coordinates
							;here xSelect has x coordinate of selected Cell and ySelect has y coordinate of selected cell
							;and xPixel has x coordinate of the printing pixel and yPixel has y coordinate of printing pixel
	mov ax,xSelect
	mov bx,ySelect
	mov cx,xPixel
	mov dx,yPixel
	
	.if(cx>=ax && dx>=bx)
		add ax,40
		add bx,40
		.if(cx<=ax && dx<=bx)
			mov ax,1
		.else
			mov ax,0
		.endif
	.else
		mov ax,0
	.endif

endm

.model small
.stack 100h
.386
.data
ruleMsg db "RULES $"
continueMsg db "Press [ENTER] to continue $"
rule1 db "1. This Game Consists of 3 Levels $"
rule2 db "2. You can swap two vertically or horizontally adjacent candies $"
rule3 db "3. If more then 3 candies are crushed, a color bomb will be created, $"
nameMsg db "Enter your name and press [ENTER] $"
nameMsg2 db "to continue $"
userName db 50 dup(?) ;Will store the userName
fileUserName db 50 dup(?)
cursorRow db 8
cursorCol db 29
levelOneMsg db "Level 1 $"
levelTwoMsg db "Level 2 $"
levelThreeMsg db "Level 3 $"
movesMsg db "Moves $"
pageNum db 0
isLevelOne db 0
isLevelTwo db 0
isLevelThree db 0
pixelColor db 0
numMoves dw 15 
candyArr dw 1,2,3,4,5 
gridStatus dw 7*7 dup(0) 
gridXCords dw 7*7 dup(0)
gridYCords dw 7*7 dup(0) 
generateCandies dw 1
generateGrid dw 1
levelOnePoints dw 0
levelTwoPoints dw 0
levelThreePoints dw 0
scoreDisplayCount dw 0 
scoreMsg db "Points: $"
exitMsg db "Press [ESC] to exit $"
nameTextMsg db "Name: $"
randNumSeed dw 0

finalCandyNum dw 0
successfulSwap dw 0 ;
tempFinalCandyNumIndexSI dw 0 
finalCellNo dw 100
initCandyNum dw 0
isSelected dw 0
selectedCellNo dw 100 
checkForSwap dw 0
initCellNo dw 100

moveMsg3 db "Press [ENTER] to exit $"
moveMsg4 db "Your Score: $"
moveMsg1 db "You failed to complete this level in the optimal moves! $"
moveMsg2 db "Restart to try again $"

successfulCrush dw 0 
tempCandyNo dw 0
tempCandyCounter dw 0
crushingCandiesCountRow dw 0
endingCellNoRow dw 20 dup (100)
startingCellNoCol dw 20 dup (100) 
endingCellNoCol dw 20 dup (100)
crushingCandiesCountCol dw 0
curshingCandies dw 7 dup (100) 
bombCounter dw 0 
bombPositions dw 10 dup (100) 
tempCandyBottom dw 0
candyBottomIndex dw 0
countOfCrushingCandies dw 0
startingCellNoRow dw 20 dup (100)
tempCandyTop dw 0
candyTopIndex dw 0

mouseInitXCord dw 0
mouseFinXCord dw 0
mouseFinYCord dw 0
mouseInitYCord dw 0
mouseYCordSaveVar dw 0
mouseXCordSaveVar dw 0
tempRtAddressfindCellNo dw 0 
tempCandyNoForScore dw  0 
tempCellNo dw 0
tempCandyNoForSwapping dw 100 
tempCellNoForSwapping dw 100
tempForHexaCandy dw 0
winMsg1 db "GGz WP <3"
fileLevelOneScore db "Level 1: "
fileLevelTwoScore db "Level 2: "
fileLevelThreeScore db "Level 3: "
newLine db 13,10 
winMsg2 db "Level 1: $"
winMsg3 db "Level 2: $"
winMsg4 db "Level 3: $"
winMsg5 db "Press [ENTER] to exit $"
winMsgScore db "SCORE $"
fileName db "data.txt"
handle dw ?
Filetemp dw ?
fileDigitCount db 0

.code
start:
main proc
	mov ax,@data
	mov ds,ax
	mov es, ax	
	makefile fileName ;Opens the file to write to 
	mov handle, ax
	mov ah,42h; adjust/edit file pointer command
	mov bx,handle; Bx holds the handle which tells in which file we have to write
	xor cx,cx; Movig 0 bytes to CX
	xor dx,dx; Movig 0 bytes to DX
	mov al, 2 ;2 movement oode is used to specify movement based on end of file 
	INT 21H
	endl
	makescreen
	call startingcout
	mov ah, 40h
	mov bx, handle
	mov cx, lengthof fileUserName
	mov dx, offset fileUserName
	int 21h
	makescreen
	call coutrules
	inc isLevelOne ;change this line to any other level to debug levels or view them, level one is the default level loaded here	
	makescreen ;Setting the video mode
	setmouse_xy
	call initgrid
	call startcrush
	mov ah,0Bh
	mov bh,00h
	mov bl,00000000b
	int 10h
	infiniteLoop:
	.if(numMoves >= 0 && isLevelThree == 1 && levelThreePoints >= 50) ;LEVEL 3 needs 50 or above score to beat
		call coutwin
		jmp EXIT
	.endif
	.if(numMoves == 0) ;If the number of remaining moves finish, the exit/lose screen is shown 
		call coutlose
		.if(isLevelOne == 1)	
			endl
			coutfile fileLevelOneScore
			mov bx, levelOnePoints
			call coutfilescore		
			endl
			coutfile fileLevelTwoScore
			mov bx, levelTwoPoints
			call coutfilescore		
		.elseif (isLevelTwo == 1)
			endl
			coutfile fileLevelTwoScore
			mov bx, levelTwoPoints
			call coutfilescore
		
		.endif
		 
		jmp EXIT
	.endif		
	.if(isLevelOne == 1 && levelOnePoints >= 350) ;Needs 350 to go to level 2
		dec isLevelOne
		inc isLevelTwo
		endl
		coutfile fileLevelOneScore
		mov bx, levelOnePoints
		call coutfilescore
		mov numMoves, 12
		makescreen ;Setting the video mode
		call initgrid
		call startcrush
		call displayGameData
		call displayPlayerScore
		call makeGrid
	.endif
	.if(isLevelTwo == 1 && levelTwoPoints >= 150) ;Needs 150 to go to level 3
		dec isLevelTwo
		inc isLevelThree
		endl
		coutfile fileLevelTwoScore
		mov bx, levelTwoPoints
		call coutfilescore
		mov numMoves, 5
		makescreen
		call initgrid
		call displayGameData
		call displayPlayerScore
		call makeGrid
		call makeCandies
		call startcrush
	.endif
	call displayGameData
	call displayPlayerScore
	.if(generateGrid==1) ;grid needs to be generated ONLY when a box is selected or deselected
		call makeGrid
	.endif
	.if(generateCandies==1)	;candies are first generated at the starting
		call makeCandies
	.endif
	call chkmouse
	.if(checkForSwap==1)
		call swapready
	.endif
	checkForExit:
	mov ah,01h
	int 16h
	jz infiniteLoop
	mov ah,00h
	int 16h
	.if al==27
	.else
		jmp infiniteLoop
	.endif
	EXIT:
	endl
	coutfile fileLevelThreeScore
	mov bx, levelThreePoints
	call coutfilescore
	endl
	mov ah,3eh
	mov bx,handle
	int 21h
	setcurs 0, 0, pageNum
	mov ah,4ch
	int 21h
	main endp
	
	coutrules proc

	pushA
	mov dx, offset ruleMsg
	push dx
	mov dx, lengthof ruleMsg
	push dx
	mov cursorRow, 3
	mov cursorCol, 38
	call displayColorData
	
	mov dx, offset rule1
	push dx
	mov dx, lengthof rule1
	push dx
	mov cursorRow, 7
	mov cursorCol, 8
	call displayColorData
	
	
	mov dx, offset rule2
	push dx
	mov dx, lengthof rule2
	push dx
	mov cursorRow, 9
	mov cursorCol, 8
	call displayColorData
	
	mov dx, offset rule3
	push dx
	mov dx, lengthof rule3
	push dx
	mov cursorRow, 11
	mov cursorCol, 8
	call displayColorData
	
	mov dx, offset continueMsg
	push dx
	mov dx, lengthof continueMsg
	push dx
	mov cursorRow, 26
	mov cursorCol, 27
	call displayColorData
	
	
	
	setcurs 100, 100, pageNum
	mov ax, 0
	.while(al != 13)
	mov ah, 01
	int 21h
	.endw
	
	
	popA
	ret

coutrules endp

coutlose Proc
	pushA
	makescreen
	mov cursorRow, 7
	mov cursorCol, 12
	mov dx, offset moveMsg1
	push dx
	mov dx, lengthof moveMsg1
	push dx
	call displayColorData
	mov cursorCol, 32
	mov cursorRow, 15
	mov dx, offset moveMsg4
	push dx
	mov dx, lengthof moveMsg4
	push dx
	call displayColorData
	setcurs 15, 44, pageNum
	.if(isLevelOne == 1)
		.if(levelOnePoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelOnePoints
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.elseif(isLevelTwo == 1)
		.if(levelTwoPoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelTwoPoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.elseif(isLevelThree == 1)
		.if(levelThreePoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelThreePoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.endif
	mov cursorCol, 29
	mov cursorRow, 25
	mov dx, offset moveMsg3
	push dx
	mov dx, lengthof moveMsg3
	push dx
	call displayColorData
	mov ah, 01
	int 21h
	.while(al != 13)
		mov ah, 01
		int 21h
	.endw
	mov cursorRow, 8
	mov cursorRow, 29
	popA
	ret
coutlose endp
	
removeBombs proc; when initially (before game starts) candies are being crushed, bombs may generate. This procedure crushes them
	mov bx,offset gridStatus
	mov si,0
	.repeat
		mov dx,[bx+si]
		.if(dx==6); it is a color bomb
			getRandNum 1,5
			pop [bx+si] ;replace bomb with a arandom candy
		.endif
		add si,2
	.until(si==98) ;48*2 = 96, plus 2 for the last box
	ret
removeBombs endp
makeGrid proc; this procedure makes the grid
	pushA
	hideMouseCursor
	push 100 ;starting y coordinate
	push 180 ;starting x coordinate
	mov bp,sp
	mov cx,8 ;need to make 8 horizontal and vertical lines
	horizontalLines: ;this label prints the horizontal lines of the grid
		push cx
		.repeat
			mov ah,0ch
			push cx
			mov al,00001111b ;first 4 bits useless,
			pop cx
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			
			pushA
			.if (isSelected==1) ;a cell is already selected
				findCoordinatesOfCell selectedCellNo ;this macro will return 1 in ax if the cx,dx coordinates lie within the range of the selected cell
				mov bp,sp ;;now [bp] can access x coordinate and [bp+2] can access y coordinate of selected Cell
				isCellInRange word ptr[bp],word ptr[bp+2],cx,dx
				.if(ax==1)
					pop ax
					pop ax;destroying local variables from stack
					popA
				.else
					pop ax
					pop ax;destroying local variables from stack
					.if(isLevelOne == 1 || isLevelThree == 1)
						popA
						int 10h
					.elseif(isLevelTwo == 1 && ((cx <= 220 && dx == 140) || (cx <= 220 && dx == 340) || (cx >= 420 && dx == 140) || (cx >= 420 && dx == 340) || (cx >= 420 && dx == 380) || (cx <= 220 && dx == 380) || (cx <= 220 && dx == 100) || (cx >= 420 && dx == 100)))
						popA
					.elseif(isLevelTwo == 1 && ((cx >= 300 && cx <= 340 && dx == 100) || (cx >= 300 && cx <= 340 && dx == 380)))
						popA
					.else
						popA
						int 10h
					.endif
				.endif
			.else
				.if(isLevelOne == 1 || isLevelThree == 1)
					popA
					int 10h
				.elseif(isLevelTwo == 1 && ((cx <= 220 && dx == 140) || (cx <= 220 && dx == 340) || (cx >= 420 && dx == 140) || (cx >= 420 && dx == 340) || (cx >= 420 && dx == 380) || (cx <= 220 && dx == 380) || (cx <= 220 && dx == 100) || (cx >= 420 && dx == 100)))
					popA
				.elseif(isLevelTwo == 1 && ((cx >= 300 && cx <= 340 && dx == 100) || (cx >= 300 && cx <= 340 && dx == 380)))
					popA
				.else
					popA
					int 10h
				.endif
			.endif			
			inc word ptr[bp]
			mov ax,[bp]
		.until ax==460
		pop cx
		mov word ptr[bp],180
		add word ptr[bp+2],40
		dec cx
		jnz horizontalLines
	mov cx,8
	mov word ptr[bp],180 ;starting x coordinate
	mov word ptr[bp+2],100 ;starting y coordinate
	verticalLine: ;this label prints the vertical lines of the gridpush cx
		push cx
		.repeat
			mov ah,0ch
			mov al,00001111b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			pushA
			.if (isSelected==1) ;a cell is already selected
				findCoordinatesOfCell selectedCellNo ;this macro will return 1 in ax if the cx,dx coordinates lie within the range of the selected cell
				mov bp,sp ;;now [bp] can access x coordinate and [bp+2] can access y coordinate of selected Cell
				isCellInRange word ptr[bp],word ptr[bp+2],cx,dx
				.if(ax==1)
					pop ax
					pop ax;destroying local variables from stack
					popA
				.else
					pop ax
					pop ax;destroying local variables from stack
					.if(isLevelOne == 1 || isLevelThree == 1)
						popA
						int 10h
					.elseif(isLevelTwo == 1 && (dx >= 220 && dx <= 260 && cx == 180) || (dx >= 220 && dx <= 260 && cx == 460) || (dx >= 100 && dx <= 180 && (cx == 460 || cx == 180) || (dx >= 300 && (cx == 460 || cx == 180))))
						popA
					.else
						popA
						int 10h
					.endif
				.endif
			.else
				.if(isLevelOne == 1 || isLevelThree == 1)
					popA
					int 10h
				.elseif(isLevelTwo == 1 && (dx >= 220 && dx <= 260 && cx == 180) || (dx >= 220 && dx <= 260 && cx == 460) || (dx >= 100 && dx <= 180 && (cx == 460 || cx == 180) || (dx >= 300 && (cx == 460 || cx == 180))))
					popA
				.else
					popA
					int 10h
				.endif
			.endif			
			inc word ptr[bp+2]
			mov ax,[bp+2]
		.until ax==380
		pop cx
		add word ptr[bp],40
		mov word ptr[bp+2],100
		dec cx
		jnz verticalLine
		;loop verticalLine
	pop ax;removing local variables from stack
	pop ax
	mov ax,0
	.if (isSelected==1)
		
		.if(isLevelTwo == 1 && (selectedCellNo == 0 || selectedCellNo == 3 || selectedCellNo == 6 || selectedCellNo == 7 || selectedCellNo == 13 || selectedCellNo == 21 || selectedCellNo == 27 || selectedCellNo == 35 || selectedCellNo == 41 || selectedCellNo == 42 || selectedCellNo == 45 || selectedCellNo == 48))
			jmp cannotSelectCell ;the selected cell did not exist was was empty based on the level
		.elseif(isLevelThree == 1 && (selectedCellNo == 3 || selectedCellNo == 10 || selectedCellNo == 17 || selectedCellNo == 24 || selectedCellNo == 31 || selectedCellNo == 38 || selectedCellNo == 45 || selectedCellNo == 21 || selectedCellNo == 22 || selectedCellNo == 23 || selectedCellNo == 25 || selectedCellNo == 26 || selectedCellNo == 27))
			jmp cannotSelectCell ;the selected cell was part of the a filled cell/blockage 
		.endif	
		findCoordinatesOfCell selectedCellNo ;this function will return x and y coordinates stored in the stack
		mov bp,sp ;now [bp] can access x coordinate and [bp+2] can access y coordinate
		mov cx,40
		horizontalSelectedLines:
			push cx
			mov ah,0ch
			mov al,00001010b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			int 10h
			inc word ptr[bp]
			mov ah,0ch
			mov al,00001010b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			add dx,40
			int 10h
			pop cx
			loop horizontalSelectedLines
		mov cx,40
		sub word ptr[bp],40
		verticalSelectedLines:
			push cx
			mov ah,0ch
			mov al,00001010b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			int 10h
			inc word ptr[bp+2]
			mov ah,0ch
			mov al,00001010b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			add cx,40
			int 10h
			pop cx
			loop verticalSelectedLines
		pop ax;removing local variables from stack
		pop ax
		
	.endif	
	
	cannotSelectCell:
	mov generateGrid,0
	showMouseCursor
	popA
	ret
makeGrid endp
startcrush proc ;this procedure crushes any combinations that ar formed initially before starting the game
	.repeat
	mov successfulCrush,0 ;if successfulCrush == 1 then CHECK FOR CRUSHING AGAIN. otherwise END CRUSHING
	call removeBombs
	call dropCandies
	call crushCandies
	.until(successfulCrush == 0)
	mov generateCandies,1 ;they have already been generated using the loop
	.if(isLevelOne == 1)
		mov levelOnePoints,0
	.elseif(isLevelTwo == 1)
		mov levelTwoPoints,0
	.else
		mov levelThreePoints,0
	.endif
	ret
startcrush endp	

coutfilescore PROC uses bx
	mov fileDigitCount, 0 ;temporary variable for stroing length of the score 	
	mov ax, bx
	mov bx,10
	pushData:
		mov dx,0
		div bx
		push dx
		inc fileDigitCount
		cmp ax, 0
	jne pushData
	writeToFile:
		cmp fileDigitCount,0
		je closeFile 
		dec fileDigitCount
		pop bx
		add bx, 48
		mov Filetemp, bx

		mov ah,40h
		mov bx,handle
		mov cx, 1
		mov dx, offset Filetemp
		int 21h
	jmp writeToFile

	
	closeFile:
		ret
	
coutfilescore endp
makeCandies proc
	pushA
	hideMouseCursor
	mov si,0
	mov cx,0
	.repeat
		pushA
		
		mov bx,offset gridStatus
		push word ptr[bx+si];pushing the gridStatus i.e. the candy number that is in the grid
		mov bx,offset gridYCords
		push word ptr[bx+si];pushing the grid box's Y coordinate in the grid
		mov bx,offset gridXCords
		push word ptr[bx+si];pushing the grid box's X coordinate in the grid
		mov bp,sp
		call drawcandy
		popA
		add si,2
		inc cx
	.until(cx==49)
	mov generateCandies,0
	showMouseCursor
	popA
	ret
makeCandies endp

crushCandies proc
	pushA
	mov crushingCandiesCountRow,0 ;initializing variable for counting size of Row Crushing Arrays
	mov cx,0
	mov bx,offset gridStatus
	mov si,0
	mov dx,[bx+si]
	mov tempCandyNo,dx ;initializing tempCandyNo with the first candy
	mov tempCandyCounter,0 ;initializing counter of candies to zero
	.while(cx!=49) ;48 indices of the array
		push cx
		mov dx,[bx+si] ;moving currentCandyNum to dx
		.if(tempCandyNo==dx) ;if previous candy == current candy
			inc tempCandyCounter ;increment the candy counter
		.else ;if previous candy != current candy
			mov tempCandyNo,dx ;temp candy = current candy
			mov tempCandyCounter,1 ;temp candy counter = 1
		.endif
		.if(tempCandyNo == 7) ;in level 3, blockades are candy Num 7
			mov tempCandyCounter,0
		.endif
		.if(tempCandyCounter == 3) ;if 3 candies are in row
			mov successfulCrush,1 ;now the outer function will know NOT to swap back the candies
			push bx
			push si ;saving registers
			mov si,crushingCandiesCountRow
			mov bx,offset endingCellNoRow
			mov [bx+si],cx ;mov cell No(cx) in the endingCellNoRow array
			sub cx,2 ;going back 2 cells
			mov bx,offset startingCellNoRow
			mov [bx+si],cx  ;mov (cell No(cx) - 2) in the startingCellNoRow Array
			add crushingCandiesCountRow,2 ;this counter variable is used as a multiple of 2(because arrays are of size word)
			pop si ;recovering registers
			pop bx
		.elseif(tempCandyCounter > 3) ;if there are more than 3 consecutive candies in a row
			push bx
			push si ;saving registers
			sub crushingCandiesCountRow,2 
			mov si,crushingCandiesCountRow ; moving to the previous index in the startingCellNo,endingCellNoRow ARRAYS
			mov bx,offset endingCellNoRow
			mov [bx+si],cx ;updating endingCellNoRow with the newer cell 
			add crushingCandiesCountRow,2 ;reBalancing counter variable (as 2 was deducted from it temporarily)
			pop si ;recovering values
			pop bx
		.endif
		pop cx
		inc cx
		add si,2 ;word size array
		.if(cx == 7 || cx == 14 || cx == 21 || cx == 28 || cx == 35 || cx == 42) ;if cx reaches the end of a row
			mov tempCandyCounter,0 ;initialize the counter with zero again
			mov dx,[bx+si] 
			mov tempCandyNo,dx ;move the new candy to tempCandyNo
		.endif
	.endw
	mov crushingCandiesCountCol,0
	mov cx,0
	mov bx,offset gridStatus
	mov si,0
	mov dx,[bx+si] 
	mov tempCandyNo,dx ;initializing tempCandyNo with the first candy
	mov tempCandyCounter,0 ;temp var to count candies that are coming in a single row/col
	.while(cx!=55) ;48 indices of the array +7 = 55(for the last box)
		push cx
		mov ax,cx
		multiply ax,2
		mov si,ax
		mov dx,[bx+si] ;moving currentCandyNum to dx
		.if(tempCandyNo==dx) ;if previous candy == current candy
			inc tempCandyCounter ;increment the candy counter
		.else ;if previous candy != current candy
			mov tempCandyNo,dx ;temp candy = current candy
			mov tempCandyCounter,1 ;temp candy counter = 1
		.endif
		.if(tempCandyNo == 7) ;in level 3, blockades are candy Num 7
			mov tempCandyCounter,0
		.endif
		.if(tempCandyCounter == 3) ;if 3 candies are in a single row
			mov successfulCrush,1 ;now the outer function will know NOT to swap back the candie
			push bx
			push si ;saving registers
			mov si,crushingCandiesCountCol 
			mov bx,offset endingCellNoCol
			mov [bx+si],cx ;mov cell No(cx) in the endingCellNoCol array
			sub cx,14  ; sub 14 because 7*2 = 14 for previous row
			mov bx,offset startingCellNoCol
			mov [bx+si],cx ;mov (cell No(cx) - 2) in the startingCellNoCol Array
			add crushingCandiesCountCol,2 ;this counter variable is used as a multiple of 2(because arrays are of size word)
			pop si ;recovering register
			pop bx
		.elseif(tempCandyCounter > 3)
			push bx
			push si ;saving registers
			sub crushingCandiesCountCol,2  ; moving to the previous index in the startingCellNo,endingCellNoCols ARRAYS
			mov si,crushingCandiesCountCol
			mov bx,offset endingCellNoCol
			mov [bx+si],cx ;updating endingCellNoRow with the newer cell 
			add crushingCandiesCountCol,2 ;reBalancing counter variable (as 2 was deducted from it temporarily)
			pop si ;recover registers
			pop bx
		.endif
		pop cx
		add cx,7
		.if(cx == 49 || cx == 50 || cx == 51 || cx == 52 || cx == 53 || cx == 54) ;if cx reaches the end of a column
			push cx
			mov tempCandyCounter,0 ;initialize the counter with zero again
			mov ax,cx
			multiply ax,2
			mov si,ax
			mov dx,[bx+si]
			mov tempCandyNo,dx  ;move the new candy to tempCandyNo
			pop cx
			sub cx,48 ;to move to the next column 
		.endif
	.endw
	mov cx,crushingCandiesCountRow ;moving size of rowCrushingArray to cx (as counter)
	.while(cx!=0)
		push cx
		sub cx,2 ;moving to previous index from the size
		mov si,cx
		mov bx,offset startingCellNoRow
		mov ax,[bx + si] ;moving starting cell number to ax
		mov bx,offset endingCellNoRow
		mov dx,[bx + si] ;moving ending cell number to dx
		mov bx,offset gridStatus
		push ax
		multiply ax,2
		mov si,ax;multiplying ax by 2 and saving in si because gridStatus is a word array and word size is x2 of byte
		pop ax
		add dx,1 ;increment dx once for the loop to run another time so that the last candy is crushed
		push cx
		mov cx,0
		.repeat
			push dx
			mov dx,word ptr[bx+si]
			mov tempCandyNoForScore,dx ;move candy num to temp variable so that score can be updated in accordance with it
			pop dx
			updateScore
			
			.if(cx==3) ;drop a color bomb in this position
				mov word ptr[bx+si],6;color bomb
			.else
				mov word ptr[bx+si],9;remove the candies
			.endif
			
			;we also need to remove the candies from the GUI
			pushA
			mov cx,si ;moving current index to cx
			divide cx,2 ;now the quotient is in AL register
			mov ah,0 ;making remainder zero
			push ax; pushing the cell no(si/2 = ax ) which is the cell number
			mov bp,sp
			call removeCandy
			popA
				
			add si,2
			inc ax
			inc cx
		.until(ax == dx)
		pop cx
		pop cx
		sub cx,2 ; as crushingCandiesCountRow was being used as a counter of 2 so it will be decremented by 2
	.endw

	mov cx,crushingCandiesCountCol
	.while(cx!=0)
		push cx
		sub cx,2 ;moving to previous index from the size
		mov si,cx
		mov bx,offset startingCellNoCol
		mov ax,[bx + si] ;moving starting cell number to ax
		mov bx,offset endingCellNoCol
		mov dx,[bx + si] ;moving ending cell number to dx
		mov bx,offset gridStatus
		push ax
		multiply ax,2
		mov si,ax;multiplying ax by 2 and saving in si because gridStatus is a word array and word size is x2 of byte
		pop ax
		add dx,1 ;increment dx once for the loop to run another time so that the last candy is crushed
		push cx
		mov cx,0
		.repeat
			push dx
			mov dx,word ptr[bx+si]
			mov tempCandyNoForScore,dx ;move candy num to temp variable so that score can be updated in accordance with it
			pop dx
			updateScore
			.if(cx==3) ;drop a color bomb in this position
				mov word ptr[bx+si],6;color bomb
			.else
				mov word ptr[bx+si],9;remove the candies
				;we also need to remove the candies from the GUI
			.endif
			pushA
			mov cx,si
			divide cx,2 ;now the quotient is in AL register
			mov ah,0 ;making remainder zero
			push ax; pushing the cell no(si/2 = ax ) which is the cell number
			mov bp,sp
			call removeCandy
			popA
			add si,14 ; 14 = 2*7
			add ax,7
			inc cx
		.until(ax > dx)
		pop cx
		pop cx
		sub cx,2 ; as crushingCandiesCountCol was being used as a counter of 2 so it will be decremented by 2
	.endw
	popA
	ret
crushCandies endp

removeCandy proc ;gets passed a cell number to remove candies from using the stack
	pushA
	hideMouseCursor
	mov dx,word ptr[bp]
	mov tempCellNo,dx
	findCoordinatesOfCell tempCellNo
	mov ax,word ptr[bp+2]
	add word ptr[bp],1
	add word ptr[bp+2],1
	mov cx,38 ;candies are within the grid size of 38*38 pixels
	.while(cx!=0)
		push cx
		mov dx, word ptr[bp]
		push dx
		mov cx,38
		.while(cx!=0)
			push cx
			mov ah,0ch
			mov al,00000000b ;put black color over candy to remove it
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			int 10h
			inc word ptr[bp]
			pop cx
			dec cx
		.endw
		pop dx
		mov word ptr[bp],dx
		pop cx
		dec cx
		inc word ptr[bp+2]
	.endw
	pop ax;destroying local variables from stack
	pop ax;destroying local variables from stack
	showMouseCursor
	popA
	ret 2;destroying local variable that was passed
removeCandy endp
	
explodeBomb proc
	pushA
	mov bx,offset gridStatus
	mov si,0
	.repeat
		mov dx,[bx+si]
		.if(dx == word ptr[bp]) ;if currentCandy == the candy in [bp] (the candy that was swapped with the bomb)
			mov tempCandyNoForScore,dx
			updateScore
			mov word ptr[bx+si],9 ;remove candy
			pushA
			mov cx,si
			divide cx,2 ;now the quotient is in AL register
			mov ah,0 ;making remainder zero
			push ax; pushing the cell no(si/2 = ax ) which is the cell number
			mov bp,sp
			call removeCandy
			popA		
		.endif
		add si,2
	.until(si == 98) ;48*2 = 96 ; plus 2 for last cell
	popA
	ret 2 ;destroying local variable of candyNum
explodeBomb endp	

swapready proc
	pushA
	.if(checkForSwap==1) 
		mov cx,0
		mov bx,offset gridStatus
		mov si,0
		.while(cx!=49)
			.if(cx==initCellNo) ;if cx comes accross the cell no that was selected initially
				push si ;saving si of initial cell number so that it can be used later by popping
				mov cx,[bx+si]
				mov tempCandyNoForSwapping,cx
				mov initCandyNum,cx ;saving initial candy num in initCandyNum
				mov si,0
				mov cx,0
				.while(cx!=49)
					.if(cx==finalCellNo) ;if cx comes accross final cell number
						areCellsAdjacent initCellNo,finalCellNo
						.if(ax==1)
							.if(isLevelTwo == 1 && (initCandyNum ==  0)) 
								pop si
								jmp candiesNotSwapped
							.endif
							.if(isLevelTwo == 1 && (finalCellNo ==  0 || finalCellNo == 3 || finalCellNo == 6 || finalCellNo == 7 || finalCellNo == 13 || finalCellNo == 21 || finalCellNo == 27 || finalCellNo == 35 || finalCellNo == 41 || finalCellNo == 42 || finalCellNo == 45 || finalCellNo == 48))
								pop si
								jmp candiesNotSwapped
							.endif
							.if(isLevelThree == 1 && (initCandyNum == 7))
								pop si
								jmp candiesNotSwapped
							.endif
							.if(isLevelThree == 1 && (finalCellNo == 3 || finalCellNo == 10 || finalCellNo == 17 || finalCellNo == 24 || finalCellNo == 31 || finalCellNo == 38 || finalCellNo == 45 || finalCellNo == 21 || finalCellNo == 22 || finalCellNo == 23 || finalCellNo == 25 || finalCellNo == 26 || finalCellNo == 27))
								pop si
								jmp candiesNotSwapped
							.endif
						.else
							pop si
							jmp candiesNotSwapped
						.endif
						push finalCellNo ;making a local variable for final Cell number
						mov bp,sp ;now [bp] can access the local variable
						call removeCandy ;removing candies from those boxes
						push initCellNo ; making a local variable for initial cell number
						mov bp,sp ;now [bp] can access the local variable
						call removeCandy ;removing candies from those boxes
						mov dx,[bx+si]
						mov finalCandyNum,dx ;saving final candy num in finalCandyNum
						mov tempFinalCandyNumIndexSI,si
						mov dx,initCandyNum
						mov [bx+si],dx
						pop si;getting initial candy number si value
						mov dx,finalCandyNum
						mov [bx+si],dx
						jmp candiesSuccessfullySwapped
					.endif
				add si,2
				inc cx
				.endw
			.endif
		add si,2
		inc cx
		.endw
		candiesSuccessfullySwapped:
			call makeGrid
			call makeCandies
			delay 900
			.if(initCandyNum == 6 || finalCandyNum == 6) ;one of them was a color bomb
				.if(initCandyNum == 6) ;initCandyNum is bomb
					mov bx,offset gridStatus
					mov ax,finalCellNo
					multiply ax,2
					mov si,ax
					mov word ptr[bx+si],9 ;removing bomb after it has been exploded
					
					push finalCellNo ;making a local variable for init Cell number
					mov bp,sp ;now [bp] can access the local variable
					call removeCandy ;removing COLOR BOMB from that cell
					
					push finalCandyNum
					mov bp,sp
					call explodeBomb
				.else ; finalCandyNum is bomb
					mov bx,offset gridStatus
					mov ax,initCellNo
					multiply ax,2
					mov si,ax
					mov word ptr[bx+si],9 ;removing bomb after it has been exploded

					push initCellNo ;making a local variable for final Cell number
					mov bp,sp ;now [bp] can access the local variable
					call removeCandy ;removing COLOR BOMB from that cell
				
					push initCandyNum
					mov bp,sp
					call explodeBomb
				.endif
				jmp bombExploded
			.endif
			mov successfulCrush,0 ;if successfulCrush == 1 then DONT swap back candies. otherwise swap them back as there was nothing to be crushed
			call crushCandies
			.if(successfulCrush==1)
				bombExploded: ;this label after exploding the bomb acts as a jumping place for the program to continue to
				.repeat
					mov successfulCrush,0 ;if successfulCrush == 1 then CHECK FOR CRUSHING AGAIN. otherwise END CRUSHING
					call dropCandies
					call makeCandies
					delay 1300
					call crushCandies
				.until(successfulCrush == 0)
				dec numMoves
				mov generateCandies,0 ;they have already been generated using the loop
			.else;swap back the candies
				.if(isLevelOne==1 || isLevelTwo==1)
					push finalCellNo ;making a local variable for final Cell number
					mov bp,sp ;now [bp] can access the local variable
					call removeCandy ;removing candies from those boxes
					push initCellNo ; making a local variable for initial cell number
					mov bp,sp ;now [bp] can access the local variable
					call removeCandy ;removing candies from those boxes
					mov dx,initCandyNum
					mov [bx+si],dx 
					mov si,tempFinalCandyNumIndexSI ;getting final candy number si value
					mov dx,finalCandyNum
					mov [bx+si],dx
					mov generateCandies,1
				.endif
			.endif
			mov successfulSwap,1 ;initializing helping variables again
			mov checkForSwap,0
			mov initCandyNum,0
			mov finalCandyNum,0
			mov initCellNo,100
			mov finalCellNo,100
			mov successfulCrush,0
			jmp exitSwappingChecks
		candiesNotSwapped:		
			mov successfulSwap,0 ;initializing helping variables again
			mov checkForSwap,0
			mov initCandyNum,0
			mov finalCandyNum,0
			mov initCellNo,100
			mov finalCellNo,100
			mov generateCandies,0
			
			jmp exitSwappingChecks
	.endif
	exitSwappingChecks:
	
	popA
	ret
swapready endp

displayPlayerScore proc
	pushA
	mov dx, offset scoreMsg;Name Message 
	push dx
	mov dx, lengthof scoreMsg
	push dx
	mov cursorRow, 2
	mov cursorCol, 66
	call displayColorData
	setcurs 2, 74, pageNum
	
	.if(isLevelOne == 1)
		.if(levelOnePoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelOnePoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.elseif(isLevelTwo == 1)
		.if(levelTwoPoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelTwoPoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.elseif(isLevelThree == 1)
		.if(levelThreePoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelThreePoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.endif
	popA
	ret
	

displayPlayerScore endp

displayGameData proc
	pushA 
	.if(isLevelOne == 1)
		mov dx, offset levelOneMsg
		push dx
		mov dx, lengthof levelOneMsg
		push dx
		mov cursorRow, 2
		mov cursorCol, 37
		call displayColorData
	.elseif(isLevelTwo == 1)
		mov dx, offset levelTwoMsg
		push dx
		mov dx, lengthof levelTwoMsg
		push dx
		mov cursorRow, 2
		mov cursorCol, 37
		call displayColorData
	.elseif(isLevelThree == 1)
		mov dx, offset levelThreeMsg
		push dx
		mov dx, lengthof levelThreeMsg
		push dx
		mov cursorRow, 2
		mov cursorCol, 37
		call displayColorData
	.endif
	
	mov dx, offset nameTextMsg ;Name Message 
	push dx
	mov dx, lengthof nameTextMsg
	push dx
	mov cursorRow, 2
	mov cursorCol, 4
	call displayColorData
	
	setcurs 2, 10, pageNum
	mov dx, offset userName ;Displaying the actual name
	mov ah, 09
	int 21h
	
	mov dx, offset exitMsg ;Name Message 
	push dx
	mov dx, lengthof exitMsg
	push dx
	mov cursorRow, 29
	mov cursorCol, 31
	call displayColorData
	
	mov dx, offset movesMsg ;Name Message 
	push dx
	mov dx, lengthof movesMsg
	push dx
	mov cursorRow, 25
	mov cursorCol, 38
	call displayColorData
	
	.if(numMoves == 0)
		setcurs 27, 40, pageNum
		mov dx, '0'
		mov ah, 02
		int 21h
	.elseif(numMoves <= 9)
		setcurs 27, 39, pageNum
		mov dx, ' '
		mov ah, 02
		int 21h	
		mov dx, numMoves
		add dx, 48
		mov ah, 02
		int 21h
	.else
		setcurs 27, 39, pageNum
		mov dx, 0
		mov bx, 10
		mov ax, numMoves
		.while(ax != 0)
			div bx
			push dx
			mov dx, 0
			inc scoreDisplayCount
			mov dx, 0
		.endw
		.while(scoreDisplayCount != 0)
			pop dx
			add dx, 48
			mov ah, 02
			int 21h
			dec scoreDisplayCount
		.endw
		
	.endif
	popA
	ret
displayGameData endp	
dropCandies proc ;if candies are crushed then new candies have to be dropped from above and the top candies should be replaced with random candies
	pushA
	mov bx,offset gridStatus
	mov si,96 ;96 = (48*2) (word type array)
	.repeat
		.if(word ptr[bx+si] == 9) ;vacant cell detected
			push si
			mov candyBottomIndex,si
			.repeat
				.if(si < 14) ;this means that there is no vacant candy above the candy below
					jmp generateNewCandy
				.endif
				sub si,14 ;go one row above
				.if(word ptr[bx+si] == 0) ;this is for level 2 as there are zero index-ed boxes to keep empty
					jmp generateNewCandy
				.endif
			.until(word ptr[bx+si]!=9 && word ptr[bx+si] != 7) ;7 in case of level 3, dont drop the blockades
			mov dx,[bx+si]
			mov tempCandyTop,dx ;now the candy num of the candy at the top is saved in tempCandyTop
			mov candyTopIndex,si		
			mov word ptr[bx+si],9 ;making the candy at the top's candy num '9' in gridStatus array
			pushA
			mov cx,si
			divide cx,2 ;now the quotient is in AL register
			mov ah,0 ;making remainder zero
			push ax; pushing the cell no(si/2 = ax ) which is the cell number
			mov bp,sp
			call removeCandy
			popA
			jmp dontGenerateNewCandy
			generateNewCandy:
				pop si
				getRandNum 1,5
				pop [bx+si] ;popping the returned random num(from stack) to [bx+si] position to generate a new candy
				jmp exitDroppingCandies
			dontGenerateNewCandy: ;swap the candies instead
				pop si
				mov dx,tempCandyTop
				mov [bx+si],dx
			exitDroppingCandies:
		.endif
		sub si,2
	.until(si == -2) ;0th index can also have a vacant cell
	popA
	ret
dropCandies endp	


findCellNo proc;finds the cell no that was selected by the user(first candy) and moves it to the selectedCellNo variable
	pop tempRtAddressfindCellNo ; saving the return address at the top of the stack and popping it along with it
	pushA ;storing registers
	mov bx,offset gridXCords
	mov si,0
	mov cx,7
	.while(cx!=0)	 ;this loop finds the top left x coordinate of the box that was clicked
		mov dx,word ptr[bx+si]
		add dx,40
		.if (dx >= word ptr[bp]); - 40 )
			sub dx,40
			mov [bp],dx ;moving the new x coordinate to local variable for x coordinate
			jmp exitXCordFinder
		.endif
		add si,2
		dec cx
	.endw
	exitXCordFinder:
	mov bx,offset gridYCords
	mov si,0
	mov cx,7
	.while(cx!=0)	;this loop finds the top left y coordinate of the box that was clicked
		mov dx,word ptr[bx+si]
		add dx,40
		.if (dx >= word ptr[bp+2])
			sub dx,40
			mov [bp+2],dx ;moving the new y coordinatey to local variable for y coordinate
			jmp exitYCordFinder
		.endif
		add si,14 ;14 = 7*2 where 2 is size of a word and 7 a whole row
		dec cx
	.endw
	exitYCordFinder:
	popA ;restoring registers
	call calculateCellNo ;calculateCellNo will calculate the cell no as [bp+4],[bp],[bp+2] still hold local variables of cellNo,x coordinate and y coordinate respectively
	push tempRtAddressfindCellNo ;pushing back the return address at the top of the stack 
	ret
findCellNo endp

chkmouse proc
	mov ax,01
	int 33h;display the mouse cursor
	mov ax,5
	mov bx,0
	int 33h;to check if LMB is being pressed or not
	.if isSelected==0
		mov checkForSwap,0
		.if(bx!=0);LMB pressed
			mov ax,5
			int 33h
			getBit ax,0 ;getting the last bit of ax as it is the one that contains LMB's current status
			.while(ax==1)
				mov cx,0
				mov isSelected,1
				mov ax,3 ;check for x and y coordinates of mouse
				int 33h
				mov mouseInitXCord,cx
				mov mouseInitYCord,dx
				push 0000 ;pushing a local variable into the stack which will be used for returning cell Number
				push dx
				push cx
				mov bp,sp
				call findCellNo ;now [bp] points to x coordinate and [bp+2] to y coordinate and [bp+4] points to the local variable
				pop initCellNo
				mov ax,initCellNo
				mov selectedCellNo,ax
				mov ax,5
				int 33h;to check if LMB is still pressed or not
				getBit ax,0 ;again getting last bit of ax to check LMB's status
				mov generateGrid,1
			.endw
		.endif
	.else ;isSelected=1
		.if(bx!=0);LMB pressed
			mov ax,5
			int 33h
			getBit ax,0 ;getting the last bit of ax as it is the one that contains LMB's current status
			;while LMB is kept pressed, this loop will keep running and only break when it is released
			.while(ax==1)
				mov checkForSwap,1 ;now the checkForSwap Procedure will check if swap is possible or not
				mov isSelected,0
				mov selectedCellNo,100
				mov ax,3
				int 33h
				mov mouseFinXCord,cx
				mov mouseFinYCord,dx
				push 0000 ;pushing a local variable into the stack which will be used for returning cell Number
				push dx
				push cx
				mov bp,sp ;now [bp] points to x coordinate and [bp+2] to y coordinate
				call findCellNo
				pop finalCellNo
				mov ax,5
				int 33h;to check if LMB is still pressed or not
				getBit ax,0 ;again getting last bit of ax to check LMB's status
				mov generateGrid,1
			.endw
		.endif
	.endif
	ret
chkmouse endp

initgrid proc ;populates the arrays having x and y coordinates of the grid along with the candies in the grid(initialize)
	mov bx,offset gridStatus
	mov si,0
	mov cx,0
	.if(isLevelOne == 1) ;Generating the array numbers for level 1
		.repeat
			getRandNum 1,5 ;get any random candy number
			pop word ptr[bx+si] ;popping candy number from stack
			add si,2
			inc cx
		.until(cx==49);array size 49
	.elseif(isLevelTwo == 1) ;If level 2 is active, then level 2 candy numbers will be generated, but based on the edited board
		.repeat
			.if(cx == 0 || cx == 3 || cx == 6 || cx == 7 || cx == 13 || cx == 21 || cx == 27 || cx == 35 || cx == 41 || cx == 42 ||  cx == 45 || cx == 48)
				mov word ptr[bx + si], 0
				add si, 2
				inc cx
			.else
				getRandNum 1,5 ;get any random candy number
				pop word ptr[bx+si] ;popping candy number from stack
				add si,2
				inc cx
			.endif
		.until(cx==49);array size 49
	.elseif(isLevelThree == 1)
		.repeat
			.if(cx == 3 || cx == 10 || cx == 17 || cx == 24 || cx == 31 || cx == 38 || cx == 45 || cx == 21 || cx == 22 || cx == 23 || cx == 25 || cx == 26 || cx == 27)
				mov word ptr[bx + si], 7
				add si, 2
				inc cx
			.else
				getRandNum 1,5 ;get any random candy number
				pop word ptr[bx+si] ;popping candy number from stack
				add si,2
				inc cx
			.endif
		.until(cx==49);array size 49
	.endif
	mov bx,offset gridXCords
	mov si,0
	mov cx,0
	push 180 ; 180 is the x coordinate from the left side of the screen to the first grid box
	mov bp,sp ; now we can access a local variable of x coordinates 180 using [bp]
	.repeat
		push cx
		mov cx,0
		mov word ptr[bp],180 ; 180 is the x coordinate from the left side of the screen to the first grid box
		.repeat
			mov dx,word ptr[bp]
			mov word ptr[bx+si],dx
			add word ptr[bp],40 ; incrementing 40 pixels for each grid square 
			add si,2
			inc cx
		.until(cx==7);2d array rows 7
		pop cx
		inc cx
	.until(cx==7);2d array cols 7
	pop ax;destroying local variable
	
	mov bx,offset gridYCords
	mov si,0
	mov cx,0
	push 100 ; 100 is the y coordinate from the top side of the screen to the first grid box
	mov bp,sp ; now we can access a local variable of y coordinates 100 using [bp]
	.repeat
		push cx
		mov cx,0
		.repeat
			mov dx,word ptr[bp]
			mov word ptr[bx+si],dx
			add si,2
			inc cx
		.until(cx==7);2d array rows 7
		pop cx
		inc cx
		add word ptr[bp],40 ; incrementing 40 pixels for each grid square 
	.until(cx==7);2d array cols 7
	pop ax;destroying local variable
	ret 
initgrid endp
calculateCellNo proc ;this function gets passed arguments through base pointer [bp] and it calculates the cell number(0-49) which is the location of the x and y coordinates that are passed
	pushA;storing registers
	sub word ptr[bp],180
	mov ax,word ptr[bp] ; dividend
	mov bl,40 ;divisor
	div bl
	mov ah,0 ;we dont need the remainder, just need the quotient. the remainder will always be zero
	mov word ptr[bp],ax ;saving the col number in [bp] now
	
	sub word ptr[bp+2],100
	mov ax,word ptr[bp+2] ; dividend
	mov bl,40 ;divisor
	div bl
	mov ah,0 ;we dont need the remainder, just need the quotient. the remainder will always be zero
	mov word ptr[bp+2],ax ;saving the row number in [bp+2] now
	
	mov ax,word ptr[bp+2] ;row no is now in [bp+2]
	mov bx,7;according to formula
	mul bx
	add ax,word ptr[bp] ; colNum is in [bp]
	mov word ptr[bp+4],ax ;[bp+4] is the local variable for cellNo
	
	popA ;restoring registers
	ret 4  ;destroying x and y coordinates from stack while keeping the local variable
calculateCellNo endp	
drawcandy proc
	.if word ptr[bp+4]==1 ; if candyNum==1 -> draw green box
	add word ptr[bp],9
	add word ptr[bp+2],9
	mov cx,23 ;green box width 20
	greenBoxLabel1:
		push cx
		mov cx,23 ; green box height 20
		mov dx,[bp]
		push dx
		greenBoxLabel2:
			push cx
			mov ah,0ch
			mov al,00000010b
			mov bh,0 ;page 0
			mov cx,[bp] ; x cordinate
			mov dx,[bp+2] ; y cordinate
			int 10h
			inc word ptr[bp]
			pop cx
			loop greenBoxLabel2
		pop dx
		mov [bp],dx
		pop cx
		inc word ptr[bp+2]
		loop greenBoxLabel1
	.elseif word ptr[bp+4]==2 ; cyan diamond
		mov cx,13
	add word ptr[bp],9
	add word ptr[bp+2],9
	mov cx,23 ;green box width 20
	greenBoxLabel3:
		push cx
		mov cx,23 ; green box height 20
		mov dx,[bp]
		push dx
		greenBoxLabel4:
			push cx
			mov ah,0ch
			mov al,00001011b
			mov bh,0 ;page 0
			mov cx,[bp] ; x cordinate
			mov dx,[bp+2] ; y cordinate
			int 10h
			inc word ptr[bp]
			pop cx
			loop greenBoxLabel4
		pop dx
		mov [bp],dx
		pop cx
		inc word ptr[bp+2]
		loop greenBoxLabel3
	.elseif word ptr[bp+4]==3 ; magenta triangle
		mov cx,13
	add word ptr[bp],9
	add word ptr[bp+2],9
	mov cx,23 ;green box width 20
	greenBoxLabel5:
		push cx
		mov cx,23 ; green box height 20
		mov dx,[bp]
		push dx
		greenBoxLabel6:
			push cx
			mov ah,0ch
			mov al,00000001b
			mov bh,0 ;page 0
			mov cx,[bp] ; x cordinate
			mov dx,[bp+2] ; y cordinate
			int 10h
			inc word ptr[bp]
			pop cx
			loop greenBoxLabel6
		pop dx
		mov [bp],dx
		pop cx
		inc word ptr[bp+2]
		loop greenBoxLabel5
	.elseif word ptr[bp+4]==4 ;toffee
		mov cx,13
	add word ptr[bp],9
	add word ptr[bp+2],9
	mov cx,23 ;green box width 20
	greenBoxLabel7:
		push cx
		mov cx,23 ; green box height 20
		mov dx,[bp]
		push dx
		greenBoxLabel8:
			push cx
			mov ah,0ch
			mov al,00001100b
			mov bh,0 ;page 0
			mov cx,[bp] ; x cordinate
			mov dx,[bp+2] ; y cordinate
			int 10h
			inc word ptr[bp]
			pop cx
			loop greenBoxLabel8
		pop dx
		mov [bp],dx
		pop cx
		inc word ptr[bp+2]
		loop greenBoxLabel7
			
	.elseif word ptr[bp+4]==5 ; if candyNum==5 -> draw hexa candy
		mov cx,13
	add word ptr[bp],9
	add word ptr[bp+2],9
	mov cx,23 ;green box width 20
	greenBoxLabel9:
		push cx
		mov cx,23 ; green box height 20
		mov dx,[bp]
		push dx
		greenBoxLabel0:
			push cx
			mov ah,0ch
			mov al,00001110b
			mov bh,0 ;page 0
			mov cx,[bp] ; x cordinate
			mov dx,[bp+2] ; y cordinate
			int 10h
			inc word ptr[bp]
			pop cx
			loop greenBoxLabel0
		pop dx
		mov [bp],dx
		pop cx
		inc word ptr[bp+2]
		loop greenBoxLabel9
	.elseif word ptr[bp+4]==4 ;toffee
		mov cx,13
	add word ptr[bp],9
	add word ptr[bp+2],9
	mov cx,23 ;green box width 20
	greenBoxLabela:
		push cx
		mov cx,23 ; green box height 20
		mov dx,[bp]
		push dx
		greenBoxLabelb:
			push cx
			mov ah,0ch
			mov al,00001111b 
			mov bh,0 ;page 0
			mov cx,[bp] ; x cordinate
			mov dx,[bp+2] ; y cordinate
			int 10h
			inc word ptr[bp]
			pop cx
			loop greenBoxLabelb
		pop dx
		mov [bp],dx
		pop cx
		inc word ptr[bp+2]
		loop greenBoxLabela
	.elseif word ptr[bp+4]==6 ;color bomb
mov cx,12
		add word ptr[bp],8
		add word ptr[bp+2],8
		mov si,1
		triangleLabel1: ; this label makes the right triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the increasing right triangle
				push cx
				mov ah,0ch
				mov al,00000110b
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				mov cx,[bp] ; x cordinate
				inc word ptr[bp]
				int 10h
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			inc si
			pop cx
			inc word ptr[bp+2]
			loop triangleLabel1
		mov cx,12
		triangleLabel2:  ;this label makes the left triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the decreasing right triangle
				push cx
				mov ah,0ch
				mov al,00001111b
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				mov cx,[bp] ; x cordinate
				int 10h
				inc word ptr[bp]
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			dec si
			pop cx
			inc word ptr[bp+2]
			loop triangleLabel2	
			
	.endif
	ret 6 ;destroying candy number, x and y coordinate from stack
drawcandy endp

startingcout proc

	pushA
	sub cursorCol, 5
	mov dx, offset nameMsg
	push dx
	mov dx, lengthof nameMsg
	push dx
	call displayColorData
	add cursorRow, 1 ;Displaying second part of the name prompt
	add cursorCol, 11
	mov dx, offset nameMsg2
	push dx
	mov dx, lengthof nameMsg2
	push dx
	call displayColorData
	add cursorRow, 5
	setcurs cursorRow, cursorCol, pageNum
	mov ch, 0
	mov cl, 7
	mov ah, 01
	int 10h
	
	mov si, offset userName ;will store the name of the player
	input:
		mov ah, 01
		int 21h
		mov [si], al
		inc si
		cmp al, 13
		jne input
		mov al, '$'
		mov [si], al
	
	popA
	ret

startingcout endp

displayColorData proc
	mov bp, sp
	pushA
	mov dx, [bp+2] ;Stores the length of the data
	mov si, [bp +4]
	
	
	mov cx, dx
	dec cx
	
	mov bp, si
	mov ah,13h 		; function 13 - write string
	mov al,01h 		; attrib in bl,move cursor
	mov bh, pageNum	
	mov bl,0fh	;clr
	mov dh,cursorRow		; row to put string
	mov dl, cursorCol 		; column to put string
	int 10h
	
	popA
	ret 4
displayColorData endp
	
coutwin proc

	makescreen
	mov cursorRow, 5
	mov cursorCol, 24
	mov dx, offset winMsg1
	push dx
	mov dx, lengthof winMsg1
	push dx
	call displayColorData
	mov cursorRow, 8
	mov cursorCol, 37
	mov dx, offset winMsgScore
	push dx
	mov dx, lengthof winMsgScore
	push dx
	call displayColorData
	mov cursorRow, 12 
	mov cursorCol, 31
	mov dx, offset winMsg2
	push dx
	mov dx, lengthof winMsg2
	push dx
	call displayColorData
	setcurs 12, 41, pageNum
	mov dx, 0
	mov bx, 10
	mov ax, levelOnePoints		
	.while(ax != 0)
		div bx
		push dx
		mov dx, 0
		inc scoreDisplayCount
	.endw	
	.while(scoreDisplayCount != 0)
		pop dx
		add dx, 48
		mov ah, 02
		int 21h
		dec scoreDisplayCount
	.endw

	mov cursorRow, 15
	mov cursorCol, 31
	mov dx, offset winMsg3
	push dx
	mov dx, lengthof winMsg3
	push dx
	call displayColorData
	setcurs 15, 41, pageNum
	mov dx, 0
	mov bx, 10
	mov ax, levelTwoPoints	
	.while(ax != 0)
		div bx
		push dx
		mov dx, 0
		inc scoreDisplayCount
	.endw
	.while(scoreDisplayCount != 0)
		pop dx
		add dx, 48
		mov ah, 02
		int 21h
		dec scoreDisplayCount
	.endw
	mov cursorRow, 18
	mov cursorCol, 31
	mov dx, offset winMsg4
	push dx
	mov dx, lengthof winMsg4
	push dx
	call displayColorData
	setcurs 18, 41, pageNum
	mov dx, 0
	mov bx, 10
	mov ax, levelThreePoints	
	.while(ax != 0)
		div bx
		push dx
		mov dx, 0
		inc scoreDisplayCount
	.endw
	.while(scoreDisplayCount != 0)
		pop dx
		add dx, 48
		mov ah, 02
		int 21h
		dec scoreDisplayCount
	.endw
	mov cursorRow, 25
	mov cursorCol, 29
	mov dx, offset winMsg5
	push dx
	mov dx, lengthof winMsg5
	push dx
	call displayColorData
	setcurs 50, 50, pageNum
	.while(al != 13)
		mov ah, 01
		int 21h
	.endw	
	ret
coutwin endp
end start
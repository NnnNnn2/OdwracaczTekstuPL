; wczytywanie i wy�wietlanie tekstu wielkimi literami
; (inne znaki si� nie zmieniaj�)
.686
.model flat
extern _ExitProcess@4 : PROC
extern __write : PROC ; (dwa znaki podkre�lenia)
extern __read : PROC ; (dwa znaki podkre�lenia)
extern _MessageBoxW@16 : PROC ; biblioteka do okienka 
public _main
.data

pl_znaki_latin2		db 0A5H, 0A4H, 86H, 8FH, 0A9H, 0A8H, 88H, 9DH, 0E4H, 0E3H ; �����ʳ���
					db 0A2H, 0E0H, 98H, 97H, 0ABH, 8DH, 0BEH, 0BDH ; �Ӝ�����
pl_znaki_UTF16		dw 0105H, 0104H, 0107H, 0106H, 0119H, 0118H, 0142H, 0141H, 0144H, 0143H ; �����ʳ���
					dw 00F3H, 00D3H, 015BH, 015AH, 017AH, 0179H, 017CH, 017BH ; �Ӝ�����


tytul_okna dw 'W','y','n','i','k',0
tekst_pocz db 10, 'Prosz',0A9H,' napisa',86H,' jaki', 98H ,' tekst '
db 'i nacisn',0A5H,86H,' Enter',0, 10
koniec_t db ?
magazyn db 80 dup (?)
nowa_linia db 10
liczba_znakow dd ?
magazyn16 dw 80 dup (?)

.code
_main:
	; wy�wietlenie tekstu informacyjnego
	; liczba znak�w tekstu

	 mov ecx,(OFFSET koniec_t) - (OFFSET tekst_pocz)
	 push ecx
	 push OFFSET tekst_pocz ; adres tekstu
	 push 1 ; nr urz�dzenia (tu: ekran - nr 1)

	 call __write ; wy�wietlenie tekstu pocz�tkowego

	 add esp, 12 ; usuniecie parametr�w ze stosu

	; czytanie wiersza z klawiatury
	 push 80 ; maksymalna liczba znak�w
	 push OFFSET magazyn
	 push 0 ; nr urz�dzenia (tu: klawiatura - nr 0)
	 call __read ; czytanie znak�w z klawiatury
	 add esp, 12 ; usuniecie parametr�w ze stosu
	; kody ASCII napisanego tekstu zosta�y wprowadzone

	; do obszaru 'magazyn'
	; funkcja read wpisuje do rejestru EAX liczb�
	; wprowadzonych znak�w
	 mov liczba_znakow, eax
	 mov ecx, eax
	 mov ebx, 0 ; indeks pocz�tkowy

	;eax - liczba znak�w
	;ebx - zmienna steruj�ca 
	;ecx - g�rny indeks
	sub ecx,2
	 ptl:
		cmp ebx, ecx		  ;warunek wyj�cia z p�tli
		jnb wyjdz
		mov dl, magazyn[ebx]  ;dl jako bufor
		xchg dl, magazyn[ecx] ;zamiana zawarto�ci buforu i ostatniego znaku
		mov magazyn[ebx], dl  ;zamiana zawarto�ci pierwszego znaki i buforu
		inc ebx
		dec ecx
		jmp ptl
	 wyjdz:
		
	 
	 mov ebx, 0
	 osiemNa16:
		
		cmp magazyn[ebx], 080h
		jb standardowa_zmiana				;skok do zmiany na normaln� liter�
				mov edi, 0					;reset zmiennej steruj�cj
				mov dl, magazyn[ebx]
			zmiana_pl:
				cmp dl, pl_znaki_latin2[edi]
				jne jezeli_nie				;pomini�cie zmiany

				mov bp, pl_znaki_UTF16[edi*2]	;przepisanie do rejestru sp znaku z tablicy UTF16
				mov magazyn16[ebx*2], bp 		;przepisanie do magazynu znaku z rejestru sp
				jmp zapetl

				jezeli_nie:
				inc edi
				cmp edi, 18					;ilo�� liter do sprawdzenia
				jb zmiana_pl
				jmp zapetl

		standardowa_zmiana:
			mov dh, 0
			mov dl, magazyn[ebx]
			mov magazyn16[ebx*2], dx
			mov magazyn16[ebx*2+1], 0
	 
	 zapetl:
	 inc ebx
	 cmp ebx, eax
	 jb osiemNa16

	 dalej:
	 push eax
	 push offset magazyn
	 push 1
	 call __write
	 popa

	 push 0
	 push offset tytul_okna
	 push offset magazyn16
	 push 0
	 call _MessageBoxW@16
	 popa
	 
	 push 0
	 call _ExitProcess@4 ; zako�czenie programu
END 
let g:UseLeaderInAutoEncapsManip = 0

let g:quoteMap            = ['.','!','~','h']
let g:quoteMapForGeneral  = ["'",'"','h','.']
let g:quoteMapForSnippets = ['!','~']

let g:ListBra = [')','(']
let g:ListSha = ['>','<']
let g:ListCur = ['}','{']
let g:ListRec = [']','[']
let g:ListDuo = ['"','"']
let g:ListSma = ["'","'"]

fun DeleteInQuote(avoid)
	let avoid      = a:avoid
	let avoid_cmp1 = [a:avoid[0],a:avoid[0]]
	let avoid_cmp2 = [a:avoid[1],a:avoid[1]]

	let safe1      = SafetyCheckIsOK(avoid_cmp1)
	let safe2      = SafetyCheckIsOK(avoid_cmp2)

	if safe1
		let index = 0
	elseif safe2
		let index = 1
	else
		"echo 'It cannot be erased!!'
		"echo avoid_cmp1[0] . ' ' . avoid_cmp1[1]
	endif

	if safe1 + safe2 == 1
		while     getline('.')[col('.')]   != avoid[index]
			normal x
		endwhile

		while     getline('.')[col('.')-2] != avoid[index]
			normal dh
		endwhile
		normal x
	elseif safe1 * safe2
		while     getline('.')[col('.')]   != avoid[1]
			normal x
		endwhile

		while     getline('.')[col('.')-2] != avoid[1]
			normal dh
		endwhile
		normal x

	endif
endf


fun DeleteInBra(avoid)
	let avoid = a:avoid
	if SafetyCheckIsOK(avoid)
		while getline('.')[col('.')] != avoid[0]
			normal x
		endwhile
		while getline('.')[col('.')-2] != avoid[1]
			normal dh
		endwhile
		normal x
	endif
endf
fun DeleteInBraDanger(avoid)
	let avoid = a:avoid
	while getline('.')[col('.')] != avoid[0]
		normal x
	endwhile
	while getline('.')[col('.')-2] != avoid[1]
		normal dh
	endwhile
	normal x
endf



fun DeleteInBraOnce(avoid)
	let avoid = a:avoid
	let safe1 = SafetyCheckIsOK(avoid[0])
	let safe2 = SafetyCheckIsOK(avoid[1])
	let safe3 = SafetyCheckIsOK(avoid[2])
	let safe4 = SafetyCheckIsOK(avoid[3])

	if safe1 + safe2 + safe3 + safe4 > 0
		while (   getline ('.')[col('.')]     != avoid[0][0] &&
		\         getline ('.')[col('.')]     != avoid[1][0] &&
		\         getline ('.')[col('.')]     != avoid[2][0] &&
		\         getline ('.')[col('.')]     != avoid[3][0] )
			normal x
		endwhile
		while (
		\         getline ('.')[col('.') -2 ] != avoid[0][1] &&
		\         getline ('.')[col('.') -2 ] != avoid[1][1] &&
		\         getline ('.')[col('.') -2 ] != avoid[2][1] &&
		\         getline ('.')[col('.') -2 ] != avoid[3][1] )
			normal dh
		endwhile
		normal x
	else
		echo 'Not proper place!'
	endif
endf


fun SafetyCheckIsOK(arg)

	let bang            = a:arg
	let left_bang       = bang[1]
	let right_bang      = bang[0]
	let left_bounded    = 0
	let right_bounded   = 0

	let current_line    = getline('.')
	let current_col_ref = col('.') - 1

	let col_left        = current_col_ref

	let same_bang = (left_bang == right_bang)

	while !left_bounded

		if col_left < col("^") + 1
			break
		endif

		if same_bang
			if current_line[col_left-1] is left_bang
				let left_bounded = 1
				break
			else
				let col_left = col_left -1
			endif
		else
			if current_line[col_left-1] is right_bang
				break
			elseif current_line[col_left-1] is left_bang
				let left_bounded = 1
			else
				let col_left = col_left -1
			endif
		endif
	endwhile

	let col_right       = current_col_ref
	while !right_bounded
		if col_right> col("$") - 1
			break
		endif
		if same_bang
			if current_line[col_right+1] is right_bang
				let right_bounded = 1
				break
			else
				let col_right = col_right+1
			endif
		else
			if current_line[col_right+1] is left_bang
				break
			elseif current_line[col_right+1] is right_bang
				let right_bounded = 1
			else
				let col_right = col_right+1
			endif
		endif
	endwhile

	"let ok = right_bounded * left_bounded
	"echo ok
	return right_bounded * left_bounded
endf


fun EraseEncaps(arg)
	let sav_pos          = getpos('.')
	let line_text        = getline('.')
	let line_num         = line('.')
	let current_col_ref  = col('.')-1
	let left_bang        = a:arg[1]
	let right_bang       = a:arg[0]
	let right_remove_col = -1
	let left_remove_col  = -1
	let col_end          = col('$')-1
	let col_start        = col('^')+1

	if SafetyCheckIsOK(a:arg)
		let col_to_right = current_col_ref
		while line_text[col_to_right] != right_bang && col_to_right < col_end 
			let col_to_right = col_to_right +1
		endwhile
		let right_remove_col = col_to_right +1

		let col_to_left = current_col_ref
		while line_text[col_to_left] != left_bang && col_to_left > col_start
			let col_to_left = col_to_left -1
		endwhile
		if col_to_left > 1
			let left_remove_col = col_to_left +1
		else
			let left_remove_col = col_to_left
		endif

		call setpos('.',[0,line_num,right_remove_col,0])
		normal x
		call setpos('.',[0,line_num,left_remove_col,0])
		normal x
	else
		echo "Can't erase outer encaps."
	endif
	call setpos('.',sav_pos)
endf


fun WordsBracket(arg) range
	let lin_ref = line('.')
	let col_ref = col('.')

	let cnt = a:arg
	let stand_alone = (col_ref == col('$') -1)
	if stand_alone
		normal bi(
	else
		normal ebi(
	endif
	if cnt > 1
		while cnt - 1
			normal e
			let cnt = cnt - 1
		endwhile
	endif
	normal ea)
	call cursor(lin_ref,col_ref)
endf

fun WordsEncapsN(encapsList,includeMap)
	let pos          = getpos('.')
	let left_encaps  = a:encapsList[1]
	let right_encaps = a:encapsList[0]
	let include		 = a:includeMap

	normal wb
	let existsInclude = SearchBackSpot(include)

	exe "normal i" . left_encaps

	if !existsInclude
		normal e
	else
		normal le
	endif
	call SearchNextSpot(include)

	exe "normal a" . right_encaps

	call setpos('.',pos)
endf
fun WordsEncapsV(encapslist,includeMap) range

	let left_encaps  = a:encapslist[1]
	let right_encaps = a:encapslist[0]
	let include		 = a:includeMap

	call cursor(line("'<"),col("'<"))
	normal wb
	let existsInclude = SearchBackSpot(include)

	exe "normal i" . left_encaps

	call cursor(line("'>"),col("'>"))

	if !existsInclude
		normal e
	else
		normal le
	endif
	call SearchNextSpot(include)

	exe "normal a" . right_encaps

	call cursor(line("'<"),col("'<"))
endf


fun SearchNextSpot(toInclude) 
	let quoteMap = a:toInclude
	let spot = getline('.')[col('.')]
	let gotit = 0
	for si in quoteMap
		if spot is si
			normal l
			call SearchNextSpot(quoteMap)
			let gotit = 1
		endif
	endfor
	return gotit
endf
fun SearchBackSpot(toInclude) 
	let quoteMap = a:toInclude
	let spot = getline('.')[col('.')-2]
	let gotit = 0
	for si in quoteMap
		if spot is si && col('.') != 1
			normal h
			call SearchBackSpot(quoteMap)
			let gotit = 1
		endif
	endfor
	return gotit
endf

fun SearchNextSpotSmall(sp,a1,a2,a3) 
	let spot = a:sp
	let s1 = a:a1
	let s2 = a:a2
	let s3 = a:a3
	let spot = getline('.')[col('.')]
	if spot is s1 || spot is s2 || spot is s3
		normal l
		call SearchNextSpotSmall(spot,s1,s2,s3)
	else
		normal a'
	endif
endf

fun WordsEmphasizeV() range
	call cursor(line("'<"),col("'<"))
	normal wb
	call SearchBackSpot(g:quoteMapForSnippets)
	normal i<em>

	call cursor(line("'>"),col("'>"))
	normal e

	call SearchNextSpot(g:quoteMapForSnippets)
	normal a</em>

	call cursor(line("'<"),col("'<"))
endf
fun WordsEmphasize()

	let pos = getpos('.')
	normal e

	call SearchNextSpot(g:quoteMapForSnippets)
	normal a</em>

	call setpos('.',pos)

	normal wb
	call SearchBackSpot(g:quoteMapForSnippets)
	normal i<em>

	call setpos('.',pos)
endf

fun WordsSnippetsV() range

	call cursor(line("'>"),col("'>")-1)
	normal e

	call SearchNextSpot(g:quoteMapForSnippets)
	normal a}

	call cursor(line("'<"),col("'<")+1)
	normal b

	call SearchBackSpot(g:quoteMapForSnippets)
	normal i${1:
	normal h
	" call cursor(line("'<"),col("'<"))
endf
fun WordsSnippets()
	let pos = getpos('.')
	normal e
	call SearchNextSpot(g:quoteMapForSnippets)
	normal a}

	call setpos('.',pos)
	normal wb
	call SearchBackSpot(g:quoteMapForSnippets)
	normal i${1:
	normal h
endf

let avoidList = ["'",'"']
nmap <A-'> :call DeleteInQuote(avoidList)<CR>


let g:ListTotal = [g:ListBra,g:ListSha,g:ListCur,g:ListRec]
nmap <A-]> :call DeleteInBraOnce(g:ListTotal)<CR>
"
"Drop in your .vim/plugin or vimfiles/plugin
"Feel free changing to your favorite key mapping.
"Very humble but simple and easy to use

fun s:SetMapAutoEncapsManipNonLeader()
	" 1. "Make encaps."
	nmap )( :call WordsEncapsN(g:ListBra,g:quoteMapForGeneral)<CR>
	nmap >< :call WordsEncapsN(g:ListSha,g:quoteMapForGeneral)<CR>
	nmap ][ :call WordsEncapsN(g:ListRec,g:quoteMapForGeneral)<CR>
	nmap }{ :call WordsEncapsN(g:ListCur,g:quoteMapForSnippets)<CR>
	nmap '; :call WordsEncapsN(g:ListSma,g:quoteMap)<CR>
	nmap ": :call WordsEncapsN(g:ListDuo,g:quoteMap)<CR>

	vmap )( :call WordsEncapsV(g:ListBra,g:quoteMapForGeneral)<CR>
	vmap >< :call WordsEncapsV(g:ListSha,g:quoteMapForGeneral)<CR>
	vmap ][ :call WordsEncapsV(g:ListRec,g:quoteMapForGeneral)<CR>
	vmap }{ :call WordsEncapsV(g:ListCur,g:quoteMapForSnippets)<CR>
	vmap '; :call WordsEncapsV(g:ListSma,g:quoteMap)<CR>
	vmap ": :call WordsEncapsV(g:ListDuo,g:quoteMap)<CR>

	" 2. "Delete contents in encaps."
	nmap ()( :call DeleteInBra(g:ListBra)<CR>
	nmap <>< :call DeleteInBra(g:ListSha)<CR>
	nmap {}{ :call DeleteInBra(g:ListCur)<CR>
	nmap [][ :call DeleteInBra(g:ListRec)<CR>
	nmap :": :call DeleteInBra(g:ListDuo)<CR>
	nmap ;'; :call DeleteInBra(g:ListSma)<CR>
		    
	vmap ()( x:call DeleteInBra(g:ListBra)<CR>
	vmap <>< x:call DeleteInBra(g:ListSha)<CR>
	vmap {}{ x:call DeleteInBra(g:ListCur)<CR>
	vmap [][ x:call DeleteInBra(g:ListRec)<CR>
	vmap :": x:call DeleteInBra(g:ListDuo)<CR>
	vmap ;'; x:call DeleteInBra(g:ListSma)<CR>

	" {3}. "Remove encaps leaving contents intact."
	nmap ()) :call EraseEncaps(g:ListBra)<CR>
	nmap <>> :call EraseEncaps(g:ListSha)<CR>
	nmap {}} :call EraseEncaps(g:ListCur)<CR>
	nmap []] :call EraseEncaps(g:ListRec)<CR>
	nmap :"" :call EraseEncaps(g:ListDuo)<CR>
	nmap ;'' :call EraseEncaps(g:ListSma)<CR>
endf

fun s:SetMapAutoEncapsManipUseLeader()
	" 1. "Make encaps."
	nmap <leader>)( :call WordsEncapsN(g:ListBra,g:quoteMapForGeneral)<CR>
	vmap <leader>)( :call WordsEncapsV(g:ListBra,g:quoteMapForGeneral)<CR>
	nmap <leader>>< :call WordsEncapsN(g:ListSha,g:quoteMapForGeneral)<CR>
	vmap <leader>>< :call WordsEncapsV(g:ListSha,g:quoteMapForGeneral)<CR>
	nmap <leader>][ :call WordsEncapsN(g:ListRec,g:quoteMapForGeneral)<CR>
	vmap <leader>][ :call WordsEncapsV(g:ListRec,g:quoteMapForGeneral)<CR>
	nmap <leader>}{ :call WordsEncapsN(g:ListCur,g:quoteMapForSnippets)<CR>
	vmap <leader>}{ :call WordsEncapsV(g:ListCur,g:quoteMapForSnippets)<CR>


	vmap <leader>'; :call WordsEncapsV(g:ListSma,g:quoteMap)<CR>
	nmap <leader>'; :call WordsEncapsN(g:ListSma,g:quoteMap)<CR>

	vmap <leader>": :call WordsEncapsV(g:ListDuo,g:quoteMap)<CR>
	nmap <leader>": :call WordsEncapsN(g:ListDuo,g:quoteMap)<CR>

	" 2. "Delete contents in encaps."
	nmap <leader>()( :call DeleteInBra(g:ListBra)<CR>
	nmap <leader><>< :call DeleteInBra(g:ListSha)<CR>
	nmap <leader>{}{ :call DeleteInBra(g:ListCur)<CR>
	nmap <leader>[][ :call DeleteInBra(g:ListRec)<CR>
	nmap <leader>:": :call DeleteInBra(g:ListDuo)<CR>
	nmap <leader>;'; :call DeleteInBra(g:ListSma)<CR>
	vmap <leader>()( x:call DeleteInBra(g:ListBra)<CR>
	vmap <leader><>< x:call DeleteInBra(g:ListSha)<CR>
	vmap <leader>{}{ x:call DeleteInBra(g:ListCur)<CR>
	vmap <leader>[][ x:call DeleteInBra(g:ListRec)<CR>
	vmap <leader>:": x:call DeleteInBra(g:ListDuo)<CR>
	vmap <leader>;'; x:call DeleteInBra(g:ListSma)<CR>

	" {3}. "Remove encaps leaving contents intact."
	nmap <leader>()) :call EraseEncaps(g:ListBra)<CR>
	nmap <leader><>> :call EraseEncaps(g:ListSha)<CR>
	nmap <leader>{}} :call EraseEncaps(g:ListCur)<CR>
	nmap <leader>[]] :call EraseEncaps(g:ListRec)<CR>
	nmap <leader>:"" :call EraseEncaps(g:ListDuo)<CR>
	nmap <leader>;'' :call EraseEncaps(g:ListSma)<CR>
endf

fun SetForSnippets()
	vmap <A-]><A-[> :call WordsSnippetsV()<CR>
	nmap <A-]><A-[> :call WordsSnippets()<CR>
endf
fun SetForHTML()
	vmap <A-]><A-[> :call WordsEmphasizeV()<CR>
	nmap <A-]><A-[> :call WordsEmphasize()<CR>
endf

au BufNewFile,BufRead,Bufenter,BufReadPost *.html call SetForHTML()
au BufNewFile,BufRead,Bufenter,BufReadPost *.snippets call SetForSnippets()

if g:UseLeaderInAutoEncapsManip == 0
	call s:SetMapAutoEncapsManipNonLeader()
elseif g:UseLeaderInAutoEncapsManip == 1
	call s:SetMapAutoEncapsManipUseLeader()
endif


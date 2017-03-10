Scriptname INEQ_MenuButtonConditional extends Quest  Conditional

bool	Property	B0	Auto	Conditional

bool	Property	B1	Auto	Conditional
bool	Property	B2	Auto	Conditional
bool	Property	B3	Auto	Conditional
bool	Property	B4	Auto	Conditional
bool	Property	B5	Auto	Conditional
bool	Property	B6	Auto	Conditional
bool	Property	B7	Auto	Conditional
bool	Property	B8	Auto	Conditional

bool	Property	B9	Auto	Conditional

function set(int button, bool value = true)
	if  Button == 0
		B0 = value
	elseif	Button == 1
		B1 = value
	elseif Button == 2
		B2 = value
	elseif button == 3
		B3 = value
	elseif	Button == 4
		B4= value
	elseif Button == 5
		B5 = value
	elseif button == 6
		B6 = value
	elseif  Button == 7
		B7 = value
	elseif	Button == 8
		B8 = value
	elseif Button == 9
		B9 = value
	endif
endfunction

function clear(int start = 0)
	B0 = False
	B1 = False
	B2 = False
	B3 = False
	B4 = False
	B5 = False
	B6 = False
	B7 = False
	B8 = False
	B9 = False
endfunction
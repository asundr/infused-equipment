Scriptname INEQ_MagickaDrainConditional extends Quest  Conditional

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
bool	Property	B10	Auto	Conditional

int property maximum  = 2047	autoreadonly

; returns true if successful, false otherwise
bool function set(int value)
	if value > maximum
		return false
	endif
	
	bool[] temp = new bool[10]
	int i = 0
	while value != 0
		if  value%2
			temp[i] = true
		endif
		value /= 2
		i += 1
	endwhile
	
;	while i < temp.length
;		temp[i] = false
;	endwhile
	
	bArrayToProperty(temp)
	return true
endfunction



function bArrayToProperty(bool[] arr)
	B0 = arr[0]
	B1 = arr[1]
	B2 = arr[2]
	B3 = arr[3]
	B4 = arr[4]
	B5 = arr[5]
	B6 = arr[6]
	B7 = arr[7]
	B8 = arr[8]
	B9 = arr[9]
	B10 = arr[10]
endfunction

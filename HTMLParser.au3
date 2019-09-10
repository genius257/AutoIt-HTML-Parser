#include-once
#include <Memory.au3>
#include "doublyLinkedList.au3"
#include <WinAPIMem.au3>

; #INDEX# =======================================================================================================================
; Title .........: HTML Parser
; AutoIt Version : 3.3.14.2
; Language ......: English
; Description ...: HTML Parser using native AutoIt.
; Author(s) .....: Anders Pedersen (genius257)
; GitHub ........: https://github.com/genius257/AutoIt-HTML-Parser
; Dll ...........: None
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Enum $__HTMLPARSERCONSTANT_TYPE_NONE, $__HTMLPARSERCONSTANT_TYPE_CDATA, $__HTMLPARSERCONSTANT_TYPE_COMMENT, $__HTMLPARSERCONSTANT_TYPE_DOCTYPE, $__HTMLPARSERCONSTANT_TYPE_STARTTAG, $__HTMLPARSERCONSTANT_TYPE_ENDTAG, $__HTMLPARSERCONSTANT_TYPE_TEXT
Global Const $__HTMLPARSERCONSTANT_tagToken = "PTR data;INT length;BYTE type;ALIGN 1;"
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_HTMLParser
;_HTMLParser_GetElementByID
;_HTMLParser_GetElementsByClassName
;_HTMLParser_GetElementsByTagName
;_HTMLParser_Element_GetText
;_HTMLParser_Element_GetAttribute
;_HTMLParser_Element_GetParent
;_HTMLParser_Element_GetChildren
;_HTMLParser_GetFirstStartTag
;_HTMLParser_VoidOrSelfClosingElement
;_HTMLParser_IsVoidElement
;_HTMLParser_IsForeignElement
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _HTMLParser
; Description ...: Parses and returns as much HTML as possible
; Syntax.........: _HTMLParser($sHTML)
; Parameters ....: $sHTML       - HTML string
; Return values .: $tagTokenListList structure with parsed elements
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......: @extended is set to indicate where no more matches could be parsed.
;                  To check for errors check @extended with string length or check if $tagTokenListList.First is equals zero.
;                  Note: Currently this function uses the same $tagTokenListList structure every time it is called. Calling this
;                  function multiple times will add the new results to the previous results. This may have unexspected results.
; Related .......: $tagTokenListList
; Link ..........: https://github.com/genius257/AutoIt-HTML-Parser/wiki/_HTMLParser-Function
; Example .......: Yes
; ===============================================================================================================================

;FIXME: error checking!
Func _HTMLParser($sHTML)
	Local $iExtended, $i, $aRet, $iOffset = 1
	Local $tDoublyLinkedList = DllStructCreate($tagDoublyLinkedList)
	Local $tToken
	Local $pStr = _WinAPI_CreateString($sHTML);  _WinAPI_IsMemory()
	While 1
		$aRet=StringRegExp($sHTML, "\G<![dD][oO][cC][tT][yY][pP][eE][\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]+[^>]*?>", 1, $iOffset)
		If @error=0 Then
			$iExtended = @extended
;~ 			ConsoleWrite(StringMid($sHTML, $iOffset, $iExtended-($iOffset))&@CRLF)
			;If _TokenList_CreateToken($__HTMLPARSERCONSTANT_TYPE_DOCTYPE, $iOffset, $iExtended-($iOffset)) = 0 Then Return SetError(1, 1, 0)
			$tToken = __HTMLParser_CreateToken($pStr + $iOffset * 2 - 2, $iExtended-($iOffset), $__HTMLPARSERCONSTANT_TYPE_DOCTYPE)
			_doublyLinkedList_Append($tDoublyLinkedList, $tToken)
			$iOffset = $iExtended
			ContinueLoop
		EndIf

		$aRet=StringRegExp($sHTML, "\G[<][0-9a-zA-Z]+(?:[\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]+[^\x{0000}-\x{001F}\x{007F}-\x{009F}\x{0020}\x{0022}\x{0027}\x{003E}\x{002F}\x{003D}\x{FDD0}\x{FDEF}\x{FFFE}\x{FFFF}\x{1FFFE}\x{1FFFF}\x{2FFFE}\x{2FFFF}\x{3FFFE}\x{3FFFF}\x{4FFFE}\x{4FFFF}\x{5FFFE}\x{5FFFF}\x{6FFFE}\x{6FFFF}\x{7FFFE}\x{7FFFF}\x{8FFFE}\x{8FFFF}\x{9FFFE}\x{9FFFF}\x{AFFFE}\x{AFFFF}\x{BFFFE}\x{BFFFF}\x{CFFFE}\x{CFFFF}\x{DFFFE}\x{DFFFF}\x{EFFFE}\x{EFFFF}\x{FFFFE}\x{FFFFF}\x{10FFFE}\x{10FFFF}]+(?:[\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]*[=][\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]*(?:[^\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}\x{0022}\x{0027}\x{003D}\x{003C}\x{003E}\x{0060}]+|['][^']*[']|[""""][^""""]*[""""]))?)*[\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]*[/]?[>]", 1, $iOffset)
		If @error=0 Then
			$iExtended = @extended
;~ 			ConsoleWrite(StringMid($sHTML, $iOffset, $iExtended-($iOffset))&@CRLF)
			;If _TokenList_CreateToken($__HTMLPARSERCONSTANT_TYPE_STARTTAG, $iOffset, $iExtended-($iOffset)) = 0 Then Return SetError(1, 2, 0)
			$tToken = __HTMLParser_CreateToken($pStr + $iOffset * 2 - 2, $iExtended-($iOffset), $__HTMLPARSERCONSTANT_TYPE_STARTTAG)
			_doublyLinkedList_Append($tDoublyLinkedList, $tToken)
			If StringLower(StringRegExp($sHTML, "\G[<]([0-9a-zA-Z]+)", 1, $iOffset)[0]) == "script" Then
				$aRet = StringRegExp($sHTML, "(?si)\G(.*?)<\/script>", 1, $iExtended)
				If @error = 0 Then
					;If _TokenList_CreateToken($__HTMLPARSERCONSTANT_TYPE_TEXT, $iExtended, $iExtended+StringLen($aRet)) = 0 Then Return SetError(1, 2.1, 0)
					$tToken = __HTMLParser_CreateToken($pStr + $iExtended * 2 - 2, StringLen($aRet[0]), $__HTMLPARSERCONSTANT_TYPE_TEXT)
					_doublyLinkedList_Append($tDoublyLinkedList, $tToken)
					$iExtended += StringLen($aRet[0])
				EndIf
			EndIf
			$iOffset = $iExtended
			ContinueLoop
		EndIf

		$aRet=StringRegExp($sHTML, "\G[<][/][0-9a-zA-Z]+[\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]*[>]", 1, $iOffset)
		If @error=0 Then
			$iExtended = @extended
;~ 			ConsoleWrite(StringMid($sHTML, $iOffset, $iExtended-($iOffset))&@CRLF)
			;If _TokenList_CreateToken($__HTMLPARSERCONSTANT_TYPE_ENDTAG, $iOffset, $iExtended-($iOffset)) = 0 Then Return SetError(1, 3, 0)
			$tToken = __HTMLParser_CreateToken($pStr + $iOffset * 2 - 2, $iExtended-($iOffset), $__HTMLPARSERCONSTANT_TYPE_ENDTAG)
			_doublyLinkedList_Append($tDoublyLinkedList, $tToken)
			$iOffset = $iExtended
			ContinueLoop
		EndIf

		$aRet=StringRegExp($sHTML, "\G<!\[CDATA\[.*?\]\]>", 1, $iOffset)
		If @error=0 Then
			$iExtended = @extended
;~ 			ConsoleWrite(StringMid($sHTML, $iOffset, $iExtended-($iOffset))&@CRLF)
			;If _TokenList_CreateToken($__HTMLPARSERCONSTANT_TYPE_CDATA, $iOffset, $iExtended-($iOffset)) = 0 Then Return SetError(1, 4, 0)
			$tToken = __HTMLParser_CreateToken($pStr + $iOffset * 2 - 2, $iExtended-($iOffset), $__HTMLPARSERCONSTANT_TYPE_CDATA)
			_doublyLinkedList_Append($tDoublyLinkedList, $tToken)
			$iOffset = $iExtended
			ContinueLoop
		EndIf

		$aRet=StringRegExp($sHTML, "\G<!--.*?-->", 1, $iOffset)
		If @error=0 Then
			$iExtended = @extended
;~ 			ConsoleWrite(StringMid($sHTML, $iOffset, $iExtended-($iOffset))&@CRLF)
			;If _TokenList_CreateToken($__HTMLPARSERCONSTANT_TYPE_COMMENT, $iOffset, $iExtended-($iOffset)) = 0 Then Return SetError(1, 5, 0)
			$tToken = __HTMLParser_CreateToken($pStr + $iOffset * 2 - 2, $iExtended-($iOffset), $__HTMLPARSERCONSTANT_TYPE_COMMENT)
			_doublyLinkedList_Append($tDoublyLinkedList, $tToken)
			$iOffset = $iExtended
			ContinueLoop
		EndIf

		$aRet=StringRegExp($sHTML, "\G[^<]+", 1, $iOffset)
		If @error=0 Then
			$iExtended = @extended
;~ 			$s = StringStripWS(StringMid($sHTML, $iOffset, $iExtended-($iOffset)),1+2)
;~ 			If Not StringIsSpace($s) Then ConsoleWrite($s&@CRLF)
			;If _TokenList_CreateToken($__HTMLPARSERCONSTANT_TYPE_TEXT, $iOffset, $iExtended-($iOffset)) = 0 Then Return SetError(1, 6, 0)
			$tToken = __HTMLParser_CreateToken($pStr + $iOffset * 2 - 2, $iExtended-($iOffset), $__HTMLPARSERCONSTANT_TYPE_TEXT)
			_doublyLinkedList_Append($tDoublyLinkedList, $tToken)
			$iOffset = $iExtended
			ContinueLoop
		EndIf

		ExitLoop
	WEnd
	Return SetError(0, $iExtended, $tDoublyLinkedList)
EndFunc

Func __HTMLParser_CreateToken($pStr, $iLength, $iType)
	Local $tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken)
	$tToken.data = $pStr
	$tToken.length = $iLength
	$tToken.type = $iType
	Return $tToken
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _HTMLParser_GetElementByID
; Description ...: Returns the first found start tag with ID attribute contents matching $sID within $pItem
; Syntax.........: _HTMLParser_GetElementByID($sID, $pItem, $sHTML)
; Parameters ....: $sID         - ID string
;                  $pItem       - $tagTokenListToken structure pointer
;                  $sHTML       - HTML string
; Return values .: Success      - $tagTokenListToken structure pointer with first found start tag
;                  Failure      - 0 and sets the @error flag to non-zero
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......: $sID is case-sensitive
; Related .......: $tagTokenListToken
; Link ..........: https://github.com/genius257/AutoIt-HTML-Parser/wiki/_HTMLParser_GetElementByID-Function
; Example .......: Yes
; ===============================================================================================================================
Func _HTMLParser_GetElementByID($sID, $pItem)
	Local $sAttrval, $aRegexRet

	If $pItem = 0 Then Return SetError(3, 0, 0)
	$tNode = __doublyLinkedList_Node($pItem)
	$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	;If Not ($__g_tTokenListToken.Type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)
	If Not ($tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)

	$sActiveTag = StringLower(StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)[0])
	$iActiveTag = 0

	While 1
		If $tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG Then
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag+=1
			If $aRegexRet[0]=$sActiveTag And _HTMLParser_VoidOrSelfClosingElement($tNode.data) Then $iActiveTag-=1
			$sAttrval=_HTMLParser_Element_GetAttribute("id", $pItem)
			If @error=0 And $sAttrval=$sID Then
				Return $pItem
			EndIf
		ElseIf $tToken.type = $__HTMLPARSERCONSTANT_TYPE_ENDTAG Then
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<][/]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag-=1
		EndIf
		If $tNode.next = 0 Or $iActiveTag<1 Then ExitLoop
		$pItem = $tNode.next
		$tNode = __doublyLinkedList_Node($pItem)
		$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	WEnd

	Return SetError(1, 0, 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _HTMLParser_GetElementsByClassName
; Description ...: Returns found start tags with class attribute contents matching $sClassName
; Syntax.........: _HTMLParser_GetElementsByClassName($sClassName)
; Parameters ....: $sClassName  - ClassName string
;                  $pItem       - $tagTokenListToken structure pointer
;                  $sHTML       - HTML string
; Return values .: Success      - Array with $tagTokenListToken structure pointers with found start tags
;                  Failure      - 0 and sets the @error flag to non-zero
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......: $sClassName is case-sensitive
; Related .......: $tagTokenListToken
; Link ..........: https://github.com/genius257/AutoIt-HTML-Parser/wiki/_HTMLParser_GetElementsByClassName-Function
; Example .......: No
; ===============================================================================================================================
Func _HTMLParser_GetElementsByClassName($sClassName, $pItem)
	Local $sAttrval, $aRegexRet, $aRet[0]
	
	If $pItem = 0 Then Return SetError(3, 0, 0)
	$tNode = __doublyLinkedList_Node($pItem)
	$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	;If Not ($__g_tTokenListToken.Type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)
	If Not ($tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)

	Local $sActiveTag = StringLower(StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)[0])
	Local $iActiveTag = 0

	While 1
		If $tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG Then
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag+=1
			If $aRegexRet[0]=$sActiveTag And _HTMLParser_VoidOrSelfClosingElement($tNode.data) Then $iActiveTag-=1
			$sAttrval=_HTMLParser_Element_GetAttribute("class", $pItem)
			If @error=0 And StringRegExp($sAttrval, "(^|[ ])"&$sClassName&"($|[ ])") Then
				ReDim $aRet[UBound($aRet, 1)+1]
				$aRet[UBound($aRet, 1)-1] = $pItem
			EndIf
		ElseIf $tToken.type = $__HTMLPARSERCONSTANT_TYPE_ENDTAG Then
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<][/]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag-=1
		EndIf

		If $tNode.next = 0 Or $iActiveTag<1 Then ExitLoop
		$pItem = $tNode.next
		$tNode = __doublyLinkedList_Node($pItem)
		$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	WEnd

	If UBound($aRet, 1)>0 Then Return $aRet
	Return SetError(1, 0, 0)
EndFunc

Func _HTMLParser_GetElementsByName($sName, $pItem)
	Local $sAttrval, $aRegexRet, $aRet[0]
	
	If $pItem = 0 Then Return SetError(3, 0, 0)
	$tNode = __doublyLinkedList_Node($pItem)
	$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	;If Not ($__g_tTokenListToken.Type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)
	If Not ($tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)

	Local $sActiveTag = StringLower(StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)[0])
	Local $iActiveTag = 0

	While 1
		If $tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG Then
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag+=1
			If $aRegexRet[0]=$sActiveTag And _HTMLParser_VoidOrSelfClosingElement($tNode.data) Then $iActiveTag-=1
			$sAttrval=_HTMLParser_Element_GetAttribute("name", $pItem)
			If @error=0 And StringRegExp($sAttrval, "(^|[ ])"&$sName&"($|[ ])") Then
				ReDim $aRet[UBound($aRet, 1)+1]
				$aRet[UBound($aRet, 1)-1] = $pItem
			EndIf
		ElseIf $tToken.type = $__HTMLPARSERCONSTANT_TYPE_ENDTAG Then
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<][/]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag-=1
		EndIf

		If $tNode.next = 0 Or $iActiveTag<1 Then ExitLoop
		$pItem = $tNode.next
		$tNode = __doublyLinkedList_Node($pItem)
		$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	WEnd

	If UBound($aRet, 1)>0 Then Return $aRet
	Return SetError(1, 0, 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _HTMLParser_GetElementsByTagName
; Description ...: Returns found start tags with tag names matching $sTagName within $pItem
; Syntax.........: _HTMLParser_GetElementsByTagName($sTagName, $pItem, $sHTML)
; Parameters ....: $sTagName    - Tag name string
;                  $pItem       - $tagTokenListToken structure pointer
;                  $sHTML       - HTML string
; Return values .: Success      - Array with $tagTokenListToken structure pointers with found start tags within $pItem
;                  Failure      - 0 and sets the @error flag to non-zero
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......: $sTagName is case-insensitive
; Related .......: $tagTokenListToken
; Link ..........: https://github.com/genius257/AutoIt-HTML-Parser/wiki/_HTMLParser_GetElementsByTagName-Function
; Example .......: Yes
; ===============================================================================================================================
Func _HTMLParser_GetElementsByTagName($sTagName, $pItem)
	Local $aRet[100], $iRet = 0, $aRegexRet

	If $pItem = 0 Then Return SetError(3, 0, 0)
	$tNode = __doublyLinkedList_Node($pItem)
	$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	;If Not ($__g_tTokenListToken.Type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)
	If Not ($tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)

	;$sActiveTag = StringLower(StringRegExp(StringMid($sHTML, $__g_tTokenListToken.Start, $__g_tTokenListToken.Length), "^[<]([0-9a-zA-Z]+)", 1)[0])
	$sActiveTag = StringLower(StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)[0])
	$iActiveTag = 0

	While 1
		If $tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG Then
			;$aRegexRet = StringRegExp(StringMid($sHTML, $__g_tTokenListToken.Start, $__g_tTokenListToken.Length), "^[<]([0-9a-zA-Z]+)", 1)
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag+=1
			If $aRegexRet[0]=$sActiveTag And _HTMLParser_VoidOrSelfClosingElement($tNode.data) Then $iActiveTag-=1
			If $aRegexRet[0]=$sTagName Then
				If UBound($aRet, 1)=$iRet Then ReDim $aRet[$iRet+100]
				$aRet[$iRet]=$pItem
				$iRet+=1
			EndIf
		ElseIf $tToken.type = $__HTMLPARSERCONSTANT_TYPE_ENDTAG Then
			;$aRegexRet = StringRegExp(StringMid($sHTML, $__g_tTokenListToken.Start, $__g_tTokenListToken.Length), "^[<][/]([0-9a-zA-Z]+)", 1)
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<][/]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag-=1
		EndIf
		If $tNode.next = 0 Or $iActiveTag<1 Then ExitLoop
		$pItem = $tNode.next
		;_MemMoveMemory($pItem, $__g_pTokenListToken, $__g_iTokenListToken)
		$tNode = __doublyLinkedList_Node($pItem)
		$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	WEnd

	If $iRet = 0 Then Return SetError(1, 0, 0)
	ReDim $aRet[$iRet]
	Return $aRet
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _HTMLParser_Element_GetText
; Description ...: Returns found text within $pItem
; Syntax.........: _HTMLParser_Element_GetText($pItem, $sHTML[, $strtrim = True])
; Parameters ....: $pItem       - $tagTokenListToken structure pointer
;                  $sHTML       - HTML string
;                  $strtrim     - If True, strips leading and trailing white space (currently not supported)
; Return values .: Success      - Array with $tagTokenListToken structure pointers with found text within $pItem
;                  Failure      - 0 and sets the @error flag to non-zero
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......:
; Related .......: $tagTokenListToken
; Link ..........: https://github.com/genius257/AutoIt-HTML-Parser/wiki/_HTMLParser_Element_GetText-Function
; Example .......: Yes
; ===============================================================================================================================
Func _HTMLParser_Element_GetText($pItem, $strtrim=True)
	;TODO: if $pItem passed is a Void/Foreign element Return SetError(3, 0, 0)
	Local $aRet[100], $iRet = 0, $aRegexRet
	Local $tNode, $tToken

	If $pItem = 0 Then Return SetError(3, 0, 0)
	$tNode = __doublyLinkedList_Node($pItem)
	$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	;If Not ($__g_tTokenListToken.Type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)
	If Not ($tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)

	;$sActiveTag = StringLower(StringRegExp(StringMid($sHTML, $__g_tTokenListToken.Start, $__g_tTokenListToken.Length), "^[<]([0-9a-zA-Z]+)", 1)[0])
	$sActiveTag = StringLower(StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)[0])
	$iActiveTag = 0

	While 1
		If $tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG Then
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag+=1
			If $aRegexRet[0]=$sActiveTag And _HTMLParser_VoidOrSelfClosingElement($tNode.data) Then $iActiveTag-=1
		ElseIf $tToken.Type = $__HTMLPARSERCONSTANT_TYPE_ENDTAG Then
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<][/]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag-=1
		ElseIf $tToken.Type = $__HTMLPARSERCONSTANT_TYPE_TEXT Then
			If UBound($aRet, 1)=$iRet Then ReDim $aRet[$iRet+100]
			$aRet[$iRet]=$pItem
			$iRet+=1
		EndIf

		;If $__g_tTokenListToken.Next = 0 Or $iActiveTag<1 Then ExitLoop
		If $tNode.Next = 0 Or $iActiveTag<1 Then ExitLoop
		;$pItem = $__g_tTokenListToken.Next
		$pItem = $tNode.Next
		$tNode = __doublyLinkedList_Node($pItem)
		$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	WEnd

	If $iRet = 0 Then Return SetError(1, 0, 0)
	ReDim $aRet[$iRet]
	Return $aRet
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _HTMLParser_Element_GetAttribute
; Description ...: Returns value of attribute from $pItem
; Syntax.........: _HTMLParser_Element_GetAttribute($sAttributeName, $pItem, $sHTML)
; Parameters ....: $sAttributeName - Attribute name string
;                  $pItem          - $tagTokenListToken structure pointer
;                  $sHTML          - HTML string
; Return values .: Success         - String value of attribute from $pItem
;                  Failure         - 0 and sets the @error flag to non-zero
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......: $sAttributeName is case-insensitive
; Related .......: $tagTokenListToken
; Link ..........: https://github.com/genius257/AutoIt-HTML-Parser/wiki/_HTMLParser_Element_GetAttribute-Function
; Example .......: Yes
; ===============================================================================================================================
Func _HTMLParser_Element_GetAttribute($sAttributeName, $pItem)
	Local $aRet, $iOffset

	If $pItem = 0 Then Return SetError(3, 0, 0)
	$tNode = __doublyLinkedList_Node($pItem)
	$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	;If Not ($__g_tTokenListToken.Type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)
	If Not ($tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)

	$sAttributeName = StringLower($sAttributeName)

	;$aRet = StringRegExp($sHTML, "\G([<][0-9a-zA-Z]+)", 1, $__g_tTokenListToken.Start)
	$aRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "\G([<][0-9a-zA-Z]+)", 1)
	;$iOffset = $__g_tTokenListToken.Start + StringLen($aRet[0])
	$iOffset = 1 + StringLen($aRet[0])

	While 1
		;$aRet = StringRegExp($sHTML, "\G[\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]+([^\x{0000}-\x{001F}\x{007F}-\x{009F}\x{0020}\x{0022}\x{0027}\x{003E}\x{002F}\x{003D}\x{FDD0}\x{FDEF}\x{FFFE}\x{FFFF}\x{1FFFE}\x{1FFFF}\x{2FFFE}\x{2FFFF}\x{3FFFE}\x{3FFFF}\x{4FFFE}\x{4FFFF}\x{5FFFE}\x{5FFFF}\x{6FFFE}\x{6FFFF}\x{7FFFE}\x{7FFFF}\x{8FFFE}\x{8FFFF}\x{9FFFE}\x{9FFFF}\x{AFFFE}\x{AFFFF}\x{BFFFE}\x{BFFFF}\x{CFFFE}\x{CFFFF}\x{DFFFE}\x{DFFFF}\x{EFFFE}\x{EFFFF}\x{FFFFE}\x{FFFFF}\x{10FFFE}\x{10FFFF}]+)(?:[\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]*[=][\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]*(?:([^\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}\x{0022}\x{0027}\x{003D}\x{003C}\x{003E}\x{0060}]+)|[']([^']*)[']|[""""]([^""""]*)[""""]))", 1, $iOffset)
		$aRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "\G[\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]+([^\x{0000}-\x{001F}\x{007F}-\x{009F}\x{0020}\x{0022}\x{0027}\x{003E}\x{002F}\x{003D}\x{FDD0}\x{FDEF}\x{FFFE}\x{FFFF}\x{1FFFE}\x{1FFFF}\x{2FFFE}\x{2FFFF}\x{3FFFE}\x{3FFFF}\x{4FFFE}\x{4FFFF}\x{5FFFE}\x{5FFFF}\x{6FFFE}\x{6FFFF}\x{7FFFE}\x{7FFFF}\x{8FFFE}\x{8FFFF}\x{9FFFE}\x{9FFFF}\x{AFFFE}\x{AFFFF}\x{BFFFE}\x{BFFFF}\x{CFFFE}\x{CFFFF}\x{DFFFE}\x{DFFFF}\x{EFFFE}\x{EFFFF}\x{FFFFE}\x{FFFFF}\x{10FFFE}\x{10FFFF}]+)(?:[\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]*[=][\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}]*(?:([^\x{0009}\x{000A}\x{000C}\x{000D}\x{0020}\x{0022}\x{0027}\x{003D}\x{003C}\x{003E}\x{0060}]+)|[']([^']*)[']|[""""]([^""""]*)[""""]))", 1, $iOffset)
		$iOffset = @extended
		If @error<>0 Then Return SetError(1, 0, "")
		If StringLower($aRet[0]) = $sAttributeName Then
			Return $aRet[(UBound($aRet, 1)<3?1:UBound($aRet, 1)<4?2:3)]
		EndIf
	WEnd

	Return SetError(4, 0, 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _HTMLParser_Element_GetParent
; Description ...: Returns parent start tag of $pItem
; Syntax.........: _HTMLParser_Element_GetParent($pItem)
; Parameters ....: $pItem       - $tagTokenListToken structure pointer
; Return values .: Success      - $tagTokenListToken structure pointer
;                  Failure      - 0 and sets the @error flag to non-zero
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......:
; Related .......: $tagTokenListToken
; Link ..........: https://github.com/genius257/AutoIt-HTML-Parser/wiki/_HTMLParser_Element_GetParent-Function
; Example .......: No
; ===============================================================================================================================
Func _HTMLParser_Element_GetParent($pItem)
	Local $sAttrval, $aRegexRet

	If $pItem = 0 Then Return SetError(3, 0, 0)
	$tNode = __doublyLinkedList_Node($pItem)
	$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	If Not ($tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)

	$iActiveTag = 0

	While 1
		If $tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG Then
			If Not _HTMLParser_VoidOrSelfClosingElement($tNode.data) Then $iActiveTag+=1
			If @error=0 And $iActiveTag=2 Then
				Return $pItem
			EndIf
		ElseIf $tToken.type = $__HTMLPARSERCONSTANT_TYPE_ENDTAG Then
			$iActiveTag-=1
		EndIf
		If $tNode.previous = 0 Or $iActiveTag<1 Then ExitLoop
		$pItem = $tNode.previous
		$tNode = __doublyLinkedList_Node($pItem)
		$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	WEnd

	Return SetError(1, 0, 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _HTMLParser_Element_GetChildren
; Description ...: Returns children start tags within $pItem
; Syntax.........: _HTMLParser_Element_GetChildren($pItem)
; Parameters ....: $pItem       - $tagTokenListToken structure pointer
; Return values .: Success      - Array with $tagTokenListToken structure pointers
;                  Failure      - 0 and sets the @error flag to non-zero
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......:
; Related .......: $tagTokenListToken
; Link ..........: https://github.com/genius257/AutoIt-HTML-Parser/wiki/_HTMLParser_Element_GetChildren-Function
; Example .......: No
; ===============================================================================================================================
Func _HTMLParser_Element_GetChildren($pItem)
	Local $aRet[0], $iRet = 0, $aRegexRet, $iLevel = 0

	If $pItem = 0 Then Return SetError(3, 0, 0)
	$tNode = __doublyLinkedList_Node($pItem)
	$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	;If Not ($__g_tTokenListToken.Type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)
	If Not ($tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG) Then Return SetError(2, 0, 0)

	$sActiveTag = StringLower(StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)[0])
	$iActiveTag = 0

	While 1
		If $tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG Then
			$iLevel += 1
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag+=1
			If $aRegexRet[0]=$sActiveTag And _HTMLParser_VoidOrSelfClosingElement($tNode.data) Then $iActiveTag-=1
			If $iLevel = 2 Then
				ReDim $aRet[UBound($aRet, 1) + 1]
				$aRet[UBound($aRet, 1) - 1] = $pItem
			EndIf
			If _HTMLParser_VoidOrSelfClosingElement($tNode.data) Then $iLevel -= 1
		ElseIf $tToken.type = $__HTMLPARSERCONSTANT_TYPE_ENDTAG Then
			$iLevel -= 1
			$aRegexRet = StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<][/]([0-9a-zA-Z]+)", 1)
			$aRegexRet[0] = StringLower($aRegexRet[0])
			If $aRegexRet[0]=$sActiveTag Then $iActiveTag-=1
		EndIf

		If $tNode.next = 0 Or $iActiveTag<1 Then ExitLoop
		$pItem = $tNode.next
		$tNode = __doublyLinkedList_Node($pItem)
		$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	WEnd

	If UBound($aRet, 1) = 0 Then Return SetError(1, 0, 0)
	Return $aRet
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _HTMLParser_GetFirstStartTag
; Description ...: Returns the first found start tag
; Syntax.........: _HTMLParser_GetFirstStartTag($pItem, $sHTML)
; Parameters ....: $pItem       - $tagTokenListToken structure pointer
;                  $sHTML       - HTML string
; Return values .: Success      - $tagTokenListToken structure pointer
;                  Failure      - 0 and sets the @error flag to non-zero
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......: Intended for use with _HTMLParser(s) $tagTokenListList.First due to first element most likely won't be a start
;                  tag, required for most functions
; Related .......: _HTMLParser, $tagTokenListList, $tagTokenListToken
; Link ..........: https://github.com/genius257/AutoIt-HTML-Parser/wiki/_HTMLParser_GetFirstStartTag-Function
; Example .......: Yes
; ===============================================================================================================================
Func _HTMLParser_GetFirstStartTag($pItem)
	If $pItem = 0 Then Return SetError(2, 0, 0)
	Local $tNode = __doublyLinkedList_Node($pItem)
	Local $tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)

	While 1
		If $tToken.type = $__HTMLPARSERCONSTANT_TYPE_STARTTAG Then Return $pItem
		If $tNode.next = 0 Then ExitLoop
		$pitem = $tNode.next
		$tNode =  __doublyLinkedList_Node($pitem)
		$tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $tNode.data)
	WEnd

	Return SetError(1, 0, 0)
EndFunc

Func __HTMLParser_GetString($pItem)
	Local $tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $pItem)
	Return DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1)
EndFunc

Func _HTMLParser_VoidOrSelfClosingElement($pItem)
    ;_MemMoveMemory($pItem, $__g_pTokenListToken, $__g_iTokenListToken)
	Local $tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $pItem)
    ;$EOT = StringLeft(StringMid($sHTML, $__g_tTokenListToken.Start, $__g_tTokenListToken.Length), 2)
    $EOT = StringLeft(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), 2)
    Return _HTMLParser_IsVoidElement($pItem) Or (_HTMLParser_IsForeignElement($pItem) And $EOT == '/>')
EndFunc

Func _HTMLParser_IsVoidElement($pItem)
    Local Static $voidElements = ['area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source', 'track', 'wbr']
	;_MemMoveMemory($pItem, $__g_pTokenListToken, $__g_iTokenListToken)
	Local $tToken = DllStructCreate($__HTMLPARSERCONSTANT_tagToken, $pItem)
    ;$tagName = StringLower(StringRegExp(StringMid($sHTML, $__g_tTokenListToken.Start, $__g_tTokenListToken.Length), "^[<]([0-9a-zA-Z]+)", 1)[0])
    $tagName = StringLower(StringRegExp(DllStructGetData(DllStructCreate("WCHAR["&$tToken.length&"]", $tToken.data), 1), "^[<]([0-9a-zA-Z]+)", 1)[0])
    For $voidElement In $voidElements
        If StringLower($voidElement) == $tagName Then Return True
    Next
    Return False
EndFunc

Func _HTMLParser_IsForeignElement($pItem)
    Return False;TODO: implement true check of foreign elements
EndFunc

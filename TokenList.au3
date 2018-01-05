#include-once
#include <Memory.au3>

; #CONSTANTS# ===================================================================================================================
Global Const $tagTokenListToken = "align 1;PTR Next;BYTE Type;UINT64 Start;UINT64 Length"
Global Const $__g_tTokenListToken = DllStructCreate($tagTokenListToken)
Global Const $__g_pTokenListToken = DllStructGetPtr($__g_tTokenListToken)
Global Const $__g_iTokenListToken = DllStructGetSize($__g_tTokenListToken)
Global Const $tagTokenListList = "PTR First;PTR Last;"
Global Const $__g_tTokenListList = DllStructCreate($tagTokenListList)
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _TokenList_CreateToken
; Description ...: Returns the current mouse position
; Syntax.........: _TokenList_CreateToken($iType, $iStart, $iLength[, $__g_tTokenListList = $__g_tTokenListList
;                  [, $__g_tTokenListToken = $__g_tTokenListToken]])
; Parameters ....: $iType               - Number specifying the token type
;                  $iStart              - Number specifying the start of the token
;                  $iLength             - Number specifying the end of the token
;                  $__g_tTokenListList  - The desired $tagTokenListList structure (default is the structure created at startup:
;                                         $__g_tTokenListList)
;                  $__g_tTokenListToken - The desired $tagTokenListToken structure (default is the structure created at startup:
;                                         $__g_tTokenListToken)
; Return values .: Success              - $tagTokenListToken structure pointer
;                  Failure              - 0 and sets the @error flag to non zero
; Author ........: Anders Pedersen (genius257)
; Modified.......:
; Remarks .......: Currently only the $__g_tTokenListList parameter should be used. The $__g_tTokenListToken is for internal use
; Related .......: $tagTokenListList, $tagTokenListToken
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _TokenList_CreateToken($iType, $iStart, $iLength, $__g_tTokenListList = $__g_tTokenListList, $__g_tTokenListToken = $__g_tTokenListToken)
	Local $pToken
	$__g_tTokenListToken.Next = 0
	$__g_tTokenListToken.Type = $iType
	$__g_tTokenListToken.Start = $iStart
	$__g_tTokenListToken.Length = $iLength

	$pToken = _MemGlobalAlloc($__g_iTokenListToken, $GPTR)
	If $pToken = 0 Then Return SetError(1, 0, 0)
	_MemMoveMemory($__g_pTokenListToken, $pToken, $__g_iTokenListToken)

	If $__g_tTokenListList.Last<>0 Then
		_MemMoveMemory($__g_tTokenListList.Last, $__g_pTokenListToken, $__g_iTokenListToken)
		$__g_tTokenListToken.Next = $pToken
		_MemMoveMemory($__g_pTokenListToken, $__g_tTokenListList.Last, $__g_iTokenListToken)
		$__g_tTokenListList.Last = $pToken
	EndIf
	If $__g_tTokenListList.First = 0 Then
		$__g_tTokenListList.First = $pToken
		$__g_tTokenListList.Last = $pToken
	EndIf

	Return $pToken
EndFunc
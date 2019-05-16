#include "..\HTMLParser.au3"

$sHTML = FileRead("data.html")

$tTokenList = _HTMLParser($sHTML)

$pItem = _HTMLParser_GetFirstStartTag($tTokenList.First, $sHTML);finds first start tag. In this example it will be <html>

$aText = _HTMLParser_Element_GetText($pItem, $sHTML)

$aLinks = _HTMLParser_GetElementsByTagName("a", $pItem, $sHTML);finds all links <a>
;list all href attribute values from a tags
For $i=0 To Ubound($aLinks, 1)-1
    ConsoleWrite(_HTMLParser_Element_GetAttribute("href", $aLinks[$i], $sHTML)&@crlf)
Next

;lists all text node found in file
;this will be changed for a later version
For $i=0 To Ubound($aText, 1)-1
    _MemMoveMemory($aText[$i], $__g_pTokenListToken, $__g_iTokenListToken)
    ConsoleWrite(StringStripWS(StringMid($sHTML, $__g_tTokenListToken.Start, $__g_tTokenListToken.Length), 8)&@crlf)
Next

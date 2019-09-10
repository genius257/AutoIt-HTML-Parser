#include "..\HTMLParser.au3"

$sHTML = FileRead("data.html")

$tTokenList = _HTMLParser($sHTML)

$pNode = _HTMLParser_GetFirstStartTag($tTokenList.head);finds first start tag. In this example it will be <html>

$pNode2 = _HTMLParser_GetElementByID("test", $pNode)
$tNode = __doublyLinkedList_Node($pNode2)
ConsoleWrite(__HTMLParser_GetString($tNode.data)&@CRLF)

$pNode2 = _HTMLParser_GetElementsByClassName("test", $pNode)
$tNode = __doublyLinkedList_Node($pNode2[0])
ConsoleWrite(__HTMLParser_GetString($tNode.data)&@CRLF)

$pNode2 = _HTMLParser_GetElementsByName("test", $pNode)
$tNode = __doublyLinkedList_Node($pNode2[0])
ConsoleWrite(__HTMLParser_GetString($tNode.data)&@CRLF)

$aText = _HTMLParser_Element_GetText($pNode)

$aLinks = _HTMLParser_GetElementsByTagName("a", $pNode);finds all links <a>
;list all href attribute values from a tags
For $i=0 To Ubound($aLinks, 1)-1
    ConsoleWrite(_HTMLParser_Element_GetAttribute("href", $aLinks[$i])&@crlf)
Next

;lists all text node found in file
;this will be changed for a later version
For $i=0 To Ubound($aText, 1)-1
    $tNode = __doublyLinkedList_Node($aText[$i])
    ConsoleWrite(StringStripWS(__HTMLParser_GetString($tNode.data), 3)&@CRLF)
Next

$aChildren = _HTMLParser_Element_GetChildren($pNode)

For $i=0 To UBound($aChildren, 1) - 1
    $tNode = __doublyLinkedList_Node($aChildren[$i])
    ConsoleWrite(StringStripWS(__HTMLParser_GetString($tNode.data), 3)&@CRLF)
Next

$tNode = __doublyLinkedList_Node(_HTMLParser_Element_GetParent($aLinks[0]))
ConsoleWrite(StringStripWS(__HTMLParser_GetString($tNode.data), 3)&@CRLF)

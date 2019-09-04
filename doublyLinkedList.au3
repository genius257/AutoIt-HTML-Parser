#cs
# Doubly Linked List in AutoIt
#
# @author genius257
# @see https://medium.com/dev-blogs/ds-with-js-linked-lists-ii-3b387596e27e
#ce

#include <Memory.au3>

$tagDoublyLinkedList = "PTR head;PTR tail;"
$tagDoublyLinkedListNode = "PTR previous;PTR data;PTR next;"

;_MemGlobalAlloc
;_MemVirtualAllocEx
;_WinAPI_CoTaskMemAlloc

;NOTE: remove functions does currently not release the node memory
;TODO: _doublyLinkedList_Swap breaks when nodeOne >= nodeTwo

#cs
# Append item to the list
#
# @param struct|handle $vDoublyLinkedList A reference to a doubly linked list
# @param struct|handle $vItem             A reference to a value, either by structure or by handle
#ce
Func _doublyLinkedList_Append($vDoublyLinkedList, $vItem)
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $hItem = IsDllStruct($vItem) ? __doublyLinkedList_StructToMem($vItem) : $vItem
    Local $hNode = __doublyLinkedList_StructToMem(DllStructCreate($tagDoublyLinkedListNode))
    Local $tNode = DllStructCreate($tagDoublyLinkedListNode, $hNode)
        $tNode.data = $hItem
    If $tDoublyLinkedList.head = 0 Then
        $tDoublyLinkedList.head = $hNode
        $tDoublyLinkedList.tail = $hNode
    Else
        $tNode.previous = $tDoublyLinkedList.tail
        $tTailNode = DllStructCreate($tagDoublyLinkedListNode, $tDoublyLinkedList.tail)
        $tTailNode.next = $hNode
        $tDoublyLinkedList.tail = $hNode
    EndIf
EndFunc

#cs
# Append item to the list, at a requested position
#
# @param struct|handle $vDoublyLinkedList A reference to a doubly linked list
# @param int           $pos               The position the item will be inserted
# @param struct|handle $vItem             A reference to a value, either by structure or by handle
#ce
Func _doublyLinkedList_AppendAt($vDoublyLinkedList, $pos, $vItem)
    Local $fNode = __doublyLinkedList_Node
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $current = $tDoublyLinkedList.head
    Local $counter = 1
    Local $hItem = IsDllStruct($vItem) ? __doublyLinkedList_StructToMem($vItem) : $vItem
    Local $hNode = __doublyLinkedList_StructToMem(DllStructCreate($tagDoublyLinkedListNode))
    Local $tNode = $fNode($hNode)
        $tNode.data = $hItem
    If $pos = 0 Then
        $tHeadNode = $fNode($tDoublyLinkedList.head)
        $tHeadNode.previous = $hNode
        $tNode.next = $tDoublyLinkedList.head
        $tDoublyLinkedList.head = $hNode
    Else
        While $current
            $current = $fNode($current).next

            If $counter = $pos Then
                $tNode.previous = $fNode($current).previous
                Local $tPreviousNode = $fNode($fNode($current).previous)
                $tPreviousNode.next = $hNode
                $tNode.next = $current
                Local $tCurrentNode = $fNode($current)
                $tCurrentNode.previous = $hNode
            EndIf
            $counter+=1
        WEnd
    EndIf
EndFunc

Func _doublyLinkedList_Remove($vDoublyLinkedList, $hItem)
    Local $fNode = __doublyLinkedList_Node
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $current = $tDoublyLinkedList.head

    While $current
        If $fNode($current).data = $hItem Then
            If $current = $tDoublyLinkedList.head And $current = $tDoublyLinkedList.tail Then
                $tDoublyLinkedList.head = 0
                $tDoublyLinkedList.tail = 0
            ElseIf $current = $tDoublyLinkedList.head Then
                $tDoublyLinkedList.head = $fNode($tDoublyLinkedList.head).next
                Local $tHeadNode = $fNode($tDoublyLinkedList.head)
                $tHeadNode.previous = 0
            ElseIf $current = $tDoublyLinkedList.tail Then
                $tDoublyLinkedList.tail = $fNode($tDoublyLinkedList.tail).previous
                Local $tTailNode = $fNode($tDoublyLinkedList.tail)
                $tTailNode.next = 0
            Else
                Local $tPreviousNode = $fNode($fNode($current).previous)
                Local $tNextNode = $fNode($fNode($current).next)
                $tPreviousNode.next = $fNode($current).next
                $tNextNode.previous = $fNode($current).previous
            EndIf
        EndIf
        $current = $fNode($current).next
    WEnd
EndFunc

Func _doublyLinkedList_RemoveAt($vDoublyLinkedList, $pos)
    Local $fNode = __doublyLinkedList_Node
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $current = $tDoublyLinkedList.head
    Local $counter = 1
    If $pos = 0 Then
        $tDoublyLinkedList.head = $fNode($tDoublyLinkedList.head).next
        $tHeadNode = $fNode($tDoublyLinkedList.head)
        $tHeadNode.previous = 0
    Else
        While $current
            $current = $fNode($current).next
            If $current = $tDoublyLinkedList.tail Then
                $tDoublyLinkedList.tail = $fNode($tDoublyLinkedList.tail).previous
                Local $tTailNode = $fNode($tDoublyLinkedList.tail)
                $tTailNode.next = 0
            ElseIf $counter = $pos Then
                Local $tPreviousNode = $fNode($fNode($current).previous)
                $tPreviousNode.next = $fNode($current).next
                Local $tNextNode = $fNode($fNode($current).next)
                $tNextNode.previous = $fNode($current).previous
                ExitLoop
            EndIf
            $counter+=1
        WEnd
    EndIf
EndFunc

Func _doublyLinkedList_Reverse($vDoublyLinkedList)
    Local $fNode = __doublyLinkedList_Node
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $current = $tDoublyLinkedList.head
    local $prev = 0
    While $current
        Local $next = $fNode($current).next
        Local $tCurrent = $fNode($current)
        $tCurrent.next = $prev
        $tCurrent.previous = $next
        $prev = $current
        $current = $next
    WEnd
    $tDoublyLinkedList.tail = $tDoublyLinkedList.head
    $tDoublyLinkedList.head = $prev
EndFunc

Func _doublyLinkedList_Swap($vDoublyLinkedList, $nodeOne, $nodeTwo)
    Local $fNode = __doublyLinkedList_Node
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $current = $tDoublyLinkedList.head
    Local $counter = 0
    Local $firstNode
    While $current
        If $counter = $nodeOne Then
            $firstNode = $current
        ElseIf $counter = $nodeTwo Then
            Local $tCurrent = $fNode($current)
            Local $tFirstNode = $fNode($firstNode)
            Local $temp = $tCurrent.data
            $tCurrent.data = $tFirstNode.data
            $tFirstNode.data = $temp
        EndIf
        $current = $fNode($current).next
        $counter+=1
    WEnd
    return True
EndFunc

Func _doublyLinkedList_IsEmpty($vDoublyLinkedList)
    Return _doublyLinkedList_Length($vDoublyLinkedList) < 1
EndFunc

Func _doublyLinkedList_Length($vDoublyLinkedList)
    Local $fNode = __doublyLinkedList_Node
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $current = $tDoublyLinkedList.head
    Local $counter = 0
    While $current
        $counter+=1
        $current = $fNode($current).next
    WEnd
    Return $counter
EndFunc

Func _doublyLinkedList_Traverse($vDoublyLinkedList, $fn)
    Local $fNode = __doublyLinkedList_Node
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $current = $tDoublyLinkedList.head
    While $current
        $tCurrent = $fNode($current)
        $fn($tCurrent)
        $current = $tCurrent.next
    WEnd
    Return True
EndFunc

Func _doublyLinkedList_TraverseReverse($vDoublyLinkedList, $fn)
    Local $fNode = __doublyLinkedList_Node
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $current = $tDoublyLinkedList.tail
    While $current
        $tCurrent = $fNode($current)
        $fn($tCurrent)
        $current = $tCurrent.previous
    WEnd
    Return True
EndFunc

Func _doublyLinkedList_Search($vDoublyLinkedList, $hData)
    Local $fNode = __doublyLinkedList_Node
    Local $tDoublyLinkedList = IsDllStruct($vDoublyLinkedList) ? $vDoublyLinkedList : DllStructCreate($tagDoublyLinkedList, $vDoublyLinkedList)
    Local $current = $tDoublyLinkedList.head
    Local $counter = 0
    While $current
        Local $tCurrent = $fNode($current)
        If $tCurrent.data = $hData Then Return $counter
        $current = $tCurrent.next
        $counter+=1
    WEnd
    Return False
EndFunc

#cs
# Copies AutoIt struct to heap, for keeping data without storing the struct in a AutoIt variable
#
# @param struct $tStruct structure to copy to heap memory
#ce
Func __doublyLinkedList_StructToMem($tStruct)
    Local $hBytes = _MemGlobalAlloc(DllStructGetSize($tStruct), $GPTR)
    _MemMoveMemory(DllStructGetPtr($tStruct), $hBytes, DllStructGetSize($tStruct))
    Return $hBytes
EndFunc

#cs
# Initiates node struct from node handle
#
# @param struct|handle $hNode
#
# @return struct
#ce
Func __doublyLinkedList_Node($hNode)
    If IsDllStruct($hNode) Then Return $hNode
    Return DllStructCreate($tagDoublyLinkedListNode, $hNode)
EndFunc

#cs
# Free memory with associated handle, allocated with doublyLinedList functions
#
# @param handle $hItem Memory pointer created with _MemGlobalAlloc
#ce
Func _doublyLinkedList_Release($hItem)
    Return _MemGlobalFree($hItem)
EndFunc

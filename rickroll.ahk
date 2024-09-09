#Persistent
#NoEnv
SendMode Input
BlockAltF4() {
    Hotkey, !F4, BlockAltF4Handler
    Return
}

BlockAltF4Handler() {
    ; Do nothing, effectively blocking Alt + F4
    Return
}

BlockAltF4()
Return

    org $74876     ; the string we're replacing starts at this address
    dc.b $0E, $0D, $10, '   HELLO, WORLD!  (FROM OUR PATCH)  ', $2F
                   ; $0E is the X location of text, with $05 being left most column
                   ; $0D is the Y location of text, with $02 being top most row
                   ; $10 contains text attributes
                   ; 
                   ; we must start from an even offset and have an even length
                   ; which is why the extra $2F is there at the end

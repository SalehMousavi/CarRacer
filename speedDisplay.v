`timescale 1ns / 1ns
module speedToHex(
    input [6:0] speed,
    input Clock,
    input DisplayEnable,
    output reg [6:0] Digit1,
    output reg [6:0] Digit2,
    output reg [6:0] Digit3
); 

localparam  NOTHING        = 7'b1111111,
            ZERO           = 7'b0000001,
            ONE            = 7'b1001111,
            TWO            = 7'b0010010,
			THREE	       = 7'b0000110,
            FOUR           = 7'b1001100,
            FIVE           = 7'b0100100,
            SIX            = 7'b0100000,
            SEVEN          = 7'b0001111,
            EIGHT          = 7'b0000000,
            NINE           = 7'b0000100;

reg [6:0] absSpeed;
reg [3:0] OnesDigit;
reg [3:0] TensDigit;

always@(*)
begin
    if(speed < 7'd27) 
        absSpeed = 7'd27 - speed;
    else
        absSpeed = speed - 7'd27;

    OnesDigit = absSpeed % 10;
    TensDigit = (absSpeed / 10) % 10;
    
    if(absSpeed == 7'd100) 
        Digit1 = ONE;
    else 
        Digit1 = ZERO;
    
    case(TensDigit)
        0: Digit2 = ZERO;
        1: Digit2 = ONE;
        2: Digit2 = TWO;
        3: Digit2 = THREE;
        4: Digit2 = FOUR;
        5: Digit2 = FIVE;
        6: Digit2 = SIX;
        7: Digit2 = SEVEN;
        8: Digit2 = EIGHT;
        9: Digit2 = NINE;
    endcase

    case(OnesDigit)
        0: Digit3 = ZERO;
        1: Digit3 = ONE;
        2: Digit3 = TWO;
        3: Digit3 = THREE;
        4: Digit3 = FOUR;
        5: Digit3 = FIVE;
        6: Digit3 = SIX;
        7: Digit3 = SEVEN;
        8: Digit3 = EIGHT;
        9: Digit3 = NINE;
    endcase
    if(!DisplayEnable)
    begin 
        Digit1 = NOTHING;
        Digit2 = NOTHING;
        Digit3 = NOTHING;
    end
end
endmodule

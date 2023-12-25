`timescale 1ns / 1ns
module collisionToHex(
    input [5:0] collision,
    input Clock,
    input DisplayEnable,
    output reg [6:0] Digit1,
    output reg [6:0] Digit2
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

reg [3:0] OnesDigit;
reg [3:0] TensDigit;

always@(*)
begin

    OnesDigit = collision % 10;
    TensDigit = (collision / 10) % 10;
    
    case(TensDigit)
        0: Digit1 = ZERO;
        1: Digit1 = ONE;
        2: Digit1 = TWO;
        3: Digit1 = THREE;
        4: Digit1 = FOUR;
        5: Digit1 = FIVE;
        6: Digit1 = SIX;
        7: Digit1 = SEVEN;
        8: Digit1 = EIGHT;
        9: Digit1 = NINE;
    endcase

    case(OnesDigit)
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
    if(!DisplayEnable)
    begin 
        Digit1 = NOTHING;
        Digit2 = NOTHING;
    end
end
endmodule

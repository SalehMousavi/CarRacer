module randomGen #(parameter N = 7) (
    input clock,
    input resetn,
    output reg [N-1:0] num
);
    localparam seed = 3;
    reg closeLoop;
   

	 always@(*)
	 begin
		closeLoop <= num[5] ^ num[2] ^ num[1] ^ num[0];
	 end
	 
    always @(posedge clock, negedge resetn) begin
        if (!resetn)
            num <= seed;
        else 
            num <= {num[N-2:0], closeLoop};
    end
    
endmodule

//module randomGen #(parameter N = 7) (
//    input clock,
//    input resetn,
//    output reg [N-1:0] num
//);
//    localparam seed = 3;
//    reg closeLoop;
//	 reg [N-1:0] counter;
//	 
//	 always@(posedge clock, negedge resetn) begin
//		if (!resetn) begin
//			counter <= 0;
//		end
//		
//		else if (counter >= 60) begin
//			counter <= 0;
//		end
//		else begin
//			counter <= counter + 1;
//		end
//		num = counter;
//	 end
// 
//endmodule
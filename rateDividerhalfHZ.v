module clockToHalfHZ(
    input clock,
    input resetn,
    input enableCount,
    output reg Enable
);

reg [24:0] count;

always@(posedge clock, negedge resetn) 
begin
    if(!resetn) begin
        count <= 0;
        Enable = 1'b0;
    end
    else if(count == 25'd5000000) begin
        Enable = 1'b1;
        count <= 0;
    end
    else if(enableCount)
    begin
        count <= count + 1;
        Enable = 1'b0;
    end
end
endmodule
module BIGFSM(
	input reset,
	input driveButton,
	input parkButton,
	input [1:0] x_speed,
	input [6:0] y_speed,
	input clock_50,
	output reg parkEnable,
	output reg driveEnable
	);
	
		 
	reg [2:0] current_state, next_state;
					
	localparam S_OFF = 3'd0,
				  S_PARK= 3'd1,
				  S_DRIVE = 3'd2;
				  
		
		
	always@(*)
	begin: state_table
		case (current_state)
			S_OFF :next_state = parkButton? S_PARK : S_OFF;
			S_PARK : next_state = driveButton? S_DRIVE : S_PARK; 
			S_DRIVE: next_state = (x_speed == 0 && y_speed == 7'd27 && parkButton == 1)? S_PARK : S_DRIVE; 
																																																		
		default: next_state = S_OFF;
		
		endcase
	end //state_table
	
	
	
	always@(*) 
	begin: enable_signals
		
		parkEnable = 1'b0;
		driveEnable = 1'b0;
	//Data signals from control path to datapath 
	
	case (current_state)
	
	  S_OFF : begin
		 end
		 
	  S_PARK : begin
		 parkEnable = 1'b1;
	  	 end
	  
	  S_DRIVE : begin
		 driveEnable = 1'b1;
		 end
	  endcase
	end // enable_signals
	
	//curent_state registers
	always@(posedge clock_50)
	begin: state_FFS
		if(reset)
			current_state <= S_OFF;
		else current_state <= next_state;
	end //state_FFS
endmodule 
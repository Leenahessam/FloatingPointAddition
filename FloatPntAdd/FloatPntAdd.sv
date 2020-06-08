module FloatPntAdd(input logic [31:0] a,b,output logic [31:0] sum); 
	 //calls all modules	 
    logic [7:0] expA, expB, exp_result, biggest_exp, shiftAmount;
    logic AlessB, sign = 1'b0;
    logic [23:0] mantA,mantB,shiftMant;
    logic [22:0] mantissa_result;
	 logic [32:0] temp = 32'bx;
	 
	 
    assign {expA,mantA} = {a[30:23],1'b1,a[22:0]};
    assign {expB,mantB} = {b[30:23],1'b1,b[22:0]};
	 
	 always @*
	  begin
	     //zero
		  if(a[30:0] == 31'b0)
			 temp = b;
		  
		  if(b[30:0] == 31'b0)
			 temp = a;
		  
		  //positive infinity
		  if(a == 32'b01111111100000000000000000000000 || b == 32'b01111111100000000000000000000000)
			 temp = 32'b01111111100000000000000000000000;
		  
		  //negative infinity
		  if(a == 32'b11111111100000000000000000000000 || b == 32'b11111111100000000000000000000000)
			 temp = 32'b11111111100000000000000000000000;
		  
		  //NaN
		  if ((expA == 8'b1 && mantA != 23'b0)||(expB == 8'b1 && mantB != 23'b0))
			 temp = 32'b?1111111100000000000000000000001;
	  end
	 
    expcompare expcomp1(expA, expB, AlessB, biggest_exp, shiftAmount);
    shiftmant shiftmant1(AlessB, mantA, mantB, shiftAmount, shiftMant);
    addmant addmant1(AlessB, mantA, mantB, shiftMant,biggest_exp, mantissa_result,exp_result);
	 always @*
	  begin
	   if (sum == 32'b0)
		 begin
		 $display("sum of given numbers is zero");
		 end
	  end
	  
	 assign sum = (temp === 32'bx)? {sign,exp_result,mantissa_result} : temp;
endmodule

//comparing exponents
module expcompare(input logic[7:0] expA, expB,
                output logic AlessB,
                output logic[7:0] biggest_exp, shiftAmount);
   
    logic[7:0] AminusB, BminusA;
    assign AminusB = expA - expB;
    assign BminusA = expB - expA;
    assign AlessB = AminusB[7];
   
    always_comb
        if (AlessB) begin
            biggest_exp = expB;
            shiftAmount = BminusA;
        end
        else 
		   begin
            biggest_exp = expA;
            shiftAmount = AminusB;
        end
endmodule
 
module shiftmant(input logic AlessB,
                    input logic [23:0] mantA, mantB,
                    input logic [7:0] shiftAmount,
                    output logic [23:0] shiftMant);
 
    logic [23:0] shiftedvalue;
	 
    assign shiftedvalue = AlessB ? (mantA >> shiftAmount): (mantB >> shiftAmount);
 
    always_comb
        if (shiftAmount[7] | shiftAmount[6] | shiftAmount[5] | (shiftAmount[4] & shiftAmount[3]))
            shiftMant = 24'b0;
        else
            shiftMant = shiftedvalue;
endmodule
 
module addmant(input logic AlessB,
                input logic[23:0] mantA, mantB, shiftMant,
                input logic[7:0]  biggest_exp,
                output logic[22:0]mantissa_result,
                output logic[7:0] exp_result);
   
    logic[24:0] addresult;
    logic[23:0] mant_to_shift;
    assign mant_to_shift = AlessB ? mantB : mantA;
    assign addresult = mant_to_shift +shiftMant ;
    assign mantissa_result = addresult[24]?addresult[23:1]:addresult[22:0];
   
    assign exp_result = addresult[24]?(biggest_exp + 1):biggest_exp;
   
endmodule

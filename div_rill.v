/*  
* module:div_rill  
*function:Verilog 除法不可综合，需要自己设计除法模块
*/  
  
module div_rill  
(  
input[31:0] a,   //被除数
input[31:0] b,   //除数
  
output reg [31:0] shang,  
output reg [31:0] yushu  
);  
  
reg[31:0] tempa;  
reg[31:0] tempb;  
reg[63:0] temp_a;  
reg[63:0] temp_b;  
 
integer i;  
 
always @(a or b)  //当被除数或除数的值发生改变时
begin  
    tempa <= a;   //把wire型的输入a赋值给寄存器tempa
    tempb <= b;   //把wire型的输入b赋值给寄存器tempb
end  

//移位除法的实现  
always @(tempa or tempb)  
begin  
    temp_a = {32'h00000000,tempa};  
    temp_b = {tempb,32'h00000000};   
    for(i = 0;i < 32;i = i + 1)  
        begin  
            temp_a = {temp_a[62:0],1'b0};  //移位相除
            if(temp_a[63:32] >= tempb)  
                temp_a = temp_a - temp_b + 1'b1;  
            else  
                temp_a = temp_a;  
        end  
//将结果输出  
    shang <= temp_a[31:0];  				
    yushu <= temp_a[63:32];  
end  
 
endmodule  

//          计时      //////////////////////////////////////////////////
module timer(
    input clk,
    input rst,
    input [31:0] lin,
    output [31:0] tim_reg,
    output [31:0] tim
    );
    
    reg[31:0] t;
    assign tim=t;//实时时间
    reg[31:0] tim_stop=0;

    always@(posedge clk,posedge rst)
        begin
            if(rst)
                t<=0;
            else
                t<=t+1;
        end
    //计数加一，表示时间在计时
    assign tim_reg=tim_stop;//截至总时间

    always @(t,lin)
        begin
            if(lin==11)
                tim_stop<=t;//lin==12?
        end
endmodule

//刹车制动，方向控制；
module  delay(
        input rst,
        input clk,
        input [31:0] lin,
        output [3:0] direction,
        output pwm_ctrl
);
reg [31:0] cnt=0;
reg [3:0] direct;//方向变量
assign direction=direct;//方向

reg pwm_c;//pwm波的输出控制，==1 输出 ==0没有输出；
assign pwm_ctrl=pwm_c;

always @ (posedge clk)
    begin
        if(rst)//rst复位，计数器清零
            begin
                cnt<=0;
            end
        if(lin<6)
            begin
                direct<=4'b1010;//电机1010都正转，前进
                pwm_c<=1;
            end
        else //lin>=6
            direct<=4'b0101;//0101反转，后退；

        if(lin==6)//在G点停车，并停留一段时间；
            begin
                cnt<=cnt+1;
                if(cnt<100)//延时100个单位时间
                    pwm_c<=0;
                else 
                    pwm_c<=1;
            end
        else if(lin>=12)
            pwm_c<=0;//返回起点，刹车
        else
            pwm_c<=1;//一直有输出，运动
    end
endmodule

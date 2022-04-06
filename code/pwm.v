//      PWM     ////////////////////////////////////////
//利用计数器统计期望占空比维持的时间，没有达到时间持续输出高电平，达到了输出低电平，总的周期用num控制；
//      clk1Mhz
module PWM(
    input clk,
    input rst,
    input [31:0] duty,//1000分辨率,设置占空比，相当于高电平维持时间，取决于左右电机需要的占空比时长。
    output out
    );
    
    integer div=20;//分频数常量
    wire p_clk;
    reg pwm;

    assign out=pwm;
    
    
    clk_divider pwm_clk(            //50kHz,f_pwm=50Hz，分频子函数，输出一个p_clk信号，
            .clk(clk),
            .d_val(div),
            .d_clk(p_clk)
    );
    
    reg[15:0] cnt;//计数器
    integer num=1000;//有符号整数，总周期；

    always @(posedge p_clk)
    begin 
        pwm=0;//初始化pwm输出波形为低电平
        if(rst||cnt>=num)// 如果 rst复位或者计数器>给定值，重置计数器
            cnt<=0;
        else //否则就计数
            cnt<=cnt+1;

        if(cnt<=duty) //如果计数器小于占空比维持的时间，输出高电平
            pwm=1;
        else 
            pwm=0;
    end
endmodule

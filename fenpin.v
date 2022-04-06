module clk_divider(
    input clk,
    input [32:0] d_val,//分频器所需的频率；由integer常数设置输入。
    output d_clk
    );
    
        reg [32:1] cnt=0;//计数器
        
        reg x=1'b0;//输出初始化为0；
        assign d_clk=x;//输出产生的是一个clk时钟信号！！！
        
        always @(posedge clk)
        begin 
            if(cnt==((d_val/2)-1))
                begin
                    cnt<=0;
                    x=~x;
                end
            else 
                cnt<=cnt+1;
        end
endmodule

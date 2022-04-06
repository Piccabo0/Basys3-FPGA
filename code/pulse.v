//测脉宽，计脉冲数      //////////////////////////////////////////////////////////////
//输入1Mhz时钟
//输出脉冲数量，*脉宽*
module dis_spd(
    input pulse,
    input rst,
    input clk,
    output [15:0] distance,
    output [15:0] pul_wid           //ms
    );
    
    integer div_count=100;     //1ms
    wire cou_clk;
    

    clk_divider(
            .clk(clk),
            .d_val(div_count),
            .d_clk(cou_clk)
    );//把输出cou_clk作为时钟信号；
    
    reg [15:0] dt=0;//初始化计数器
    reg [15:0] pw=0;//初始化输出
    reg [15:0] pw2;
    assign pul_wid=pw;//输出脉冲宽度
    
    always@(posedge cou_clk, posedge rst)
    begin
        if(rst)
            begin
                dt<=0;
                pw<=0;
                pw2<=0;
            end//rst复位信号全部清零。
        else
            begin
                if(pulse)
                    begin
                        dt<=dt+1;
                        pw2<=dt;
                    end//pulse高电平期间计数，pw2中间寄存器；
                 else
                    begin
                        pw<=pw2;//pulse下降沿则把pw2的保存值赋给pw输出；
                        dt<=0;//同时计数器清零等待下一次高电平的到来；
                    end
            end
    end
    
    reg[15:0] dis;
    assign distance=dis;//输出距离检测值

    always @(posedge pulse,posedge rst)
    begin
        if(rst)
            dis<=0;//rst复位则dis清零重新计数
        else 
            dis<=dis+1;//脉冲进入则高电平一直加加加
    
    end
endmodule

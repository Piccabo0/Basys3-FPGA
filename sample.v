module sample(
        input clk,
        input line,
        input dis,
        input sw,
        input menu,
        input [4:0]sw_l,
        input [4:0] sw_r,
        output line_val,
        output dis_val,
        output sw_val,
        output [4:0]sw_l_val,
        output [4:0]sw_r_val,
        output menu_val
);

    reg l,d,s,m;//l==线，d==距离，s==pwm信号，m==菜单，内参数；
    reg [4:0] sl,sr;
    
    assign line_val=l;
    assign dis_val=d;
    assign sw_val=s;//sw==pwm信号，
    assign menu_val=m;
    assign sw_l_val=sl;
    assign sw_r_val=sr;
    
    always @(posedge clk)//检测采样，就是循环用input赋值output，循环输出output，
    begin
        s<=sw;
        l<=line;
        d<=dis;
        m<=menu;
        sl<=sw_l;
        sr<=sw_r;
    end

endmodule

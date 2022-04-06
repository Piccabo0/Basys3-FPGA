module main(
    input clk,  //时钟信号
    input rst,  //复位信号
    input sw,       //pwm输出开关
    input line,     //线检测输入
    input dis,       //距离测量输入
    input menu, //菜单按键输入
    input [4:0] sw_l,       //左pwm 调整
    input [4:0] sw_r,       //右pwm 调整
    output [3:0] bit,       //seven_seg _bit
    output [7:0] seg,       //seven_seg_segment
    output [3:0] dir,       //direction
    output [2:0] menu_show,     //菜单指示
    output pl,
    output pr
    );
    

    wire sw_val;//sw==pwm信号，
    wire line_val;//黑线检测信号的输入
    wire dis_val;
    wire menu_val;//菜单输入选择信号
    wire [4:0] sw_l_val;//pwm左轮的输入？从哪来？
    wire [4:0] sw_r_val;

    integer div=100;//用于分频器计数
    wire clock;
    integer div_tim=10000000;//用于分频器计数
    wire t_clk;


    clk_divider s_clk(          //1Mhz
        .clk(clk),
        .d_val(div),
        .d_clk(clock)

    );

    clk_divider t_clock(        //10Hz
        .clk(clk),
        .d_val(div_tim),
        .d_clk(t_clk)
    );
    
    
    //      取样1Mhz      /////////////////////////////////////////
    sample s1(
            .clk(clock),
            .line(line),
            .sw(sw),
            .dis(dis),
            .menu(menu),
            .sw_l(sw_l),
            .sw_r(sw_r),
            .line_val(line_val),
            .dis_val(dis_val),
            .sw_val(sw_val),
            .sw_l_val(sw_l_val),
            .sw_r_val(sw_r_val),
            .menu_val(menu_val)
    );
   //////////////////////////////////////////////////////////////// 
    
    
//      线数      ///////////////////////////////////////////////////
    wire[31:0] lin;//黑线数量的输出值；
    line_det line1(
        .pulse(line_val),
        .rst(rst),
        .num(lin)
    );
    
    
    
    //      时间      //////////////////////////////////////////////////
    wire [31:0]tim;
    wire [31:0] tim_reg;        //保存结束时间
    timer t1(                          //10Hz输入,*0.1s
            .clk(t_clk),
            .rst(rst),
            .lin(lin),
            .tim(tim),
            .tim_reg(tim_reg)
    );
    ///////////////////////////////////////////////////////////////
    
    
    //      脉宽，脉冲数         /////////////////////////////////////
    wire [15:0] length;
    wire [15:0] width;
    dis_spd dp(
        .pulse(dis_val),
        .rst(rst),
        .clk(clock),
        .distance(length),
        .pul_wid(width)
    );
    //////////////////////////////////////////////////////////////////////////////
    
    
    //      speed_ctrl       /////////////////////////////////////////////////
    wire [31:0] pwm_l;
    wire [31:0] pwm_r;
    speed_ctrl sc(
            .lin(lin),
            .sw_l_val(sw_l_val),
            .sw_r_val(sw_r_val),
            .pwm_l(pwm_l),
            .pwm_r(pwm_r)
    );//速度输出为pwm_r,pwm_l，用于占空比的设置
    //////////////////////////////////////////////////////////////////
    
    
    
    /////      延时      ////////////////////////////////////////////////////////////
    wire pwm_ctrl;      //pwm开关控制
    delay d1(
            .rst(rst),
            .clk(t_clk),
            .lin(lin),
            .direction(dir),
            .pwm_ctrl(pwm_ctrl)
    );//pwm输出的开关
    
    //////////////////////////////////////////////////////////////
    
    
    //      两路pwm输出     ///////////////////////////////////////
    wire pl_out,pr_out;
    wire L,R;
    assign pl=L;
    assign pr=R;
    PWM PWML(
        .clk(clock),
        .rst(rst),
        .duty(pwm_l),
        .out(pl_out)
    );
        PWM PWMR(
        .clk(clock),
        .rst(rst),
        .duty(pwm_r),
        .out(pr_out)
    );
    and a1(L,pwm_ctrl,pl_out,sw_val);
    and a2(R,pwm_ctrl,pr_out,sw_val);
    /////////////////////////////////////////////////////////
    
   
    //      显示        /////////////////////////////////////////
    wire [31:0] current_show;
    menu_select ms(
            .clk(t_clk),
            .lin(lin),
            .tim(tim),
            .tim_reg(tim_reg),
            .distance(length),
            .select(menu_val),
            .selected(current_show),
            .menu_show(menu_show)
    );//current_show 是menu_select函数的输出，是被选择的时间、距离等参数；
    
    disp p1(
    .clk(clock),
    .val(current_show),
    .bit(bit),
    .seg(seg)
    );
    ////////////////////////////////////////////////////////


endmodule

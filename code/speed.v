module speed_ctrl(
        input [31:0] lin,
        input [4:0] sw_l_val,
        input [4:0] sw_r_val,
        output [31:0] pwm_l,
        output [31:0] pwm_r
        );
        reg [31:0] pl;//轮子转速输出，
        reg [31:0] pr;
        assign pwm_l=pl;
        assign pwm_r=pr;

    always@(lin)//速度由黑线数目来控制；
        begin
            //BCD段 EFG段 GFE段 DCB段全速通过
            if(lin<3||(lin>=4&&lin<9)||(lin>=10&&lin<12))
                begin
                    pl<=500+(sw_l_val*5);
                    pr<=500+(sw_r_val*5);
                end
            //DE ED段减速通过
            else if(lin==3||lin==9)
                begin
                    pl<=150+(sw_l_val*5);
                    pr<=150+(sw_r_val*5);
                end
        end
endmodule

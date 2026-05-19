library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TestPIPMIPS is
    Port ( clk_sig : in STD_LOGIC;
           clk : in STD_logic;
           rst : in STD_LOGIC;
           switches : in std_logic_vector(2 downto 0);
           leds : out std_logic_vector(15 downto 0);
           Cat : out STD_LOGIC_VECTOR (6 downto 0);
           An : out STD_LOGIC_VECTOR (3 downto 0)
           );
end TestPIPMIPS;

architecture Behavioral of TestPIPMIPS is

component PIPMIPS is
    Port ( clk : in STD_LOGIC;
           rst : in STD_Logic;
           
           instruction_out : out std_logic_vector(15 downto 0);
           next_branch_addr_out : out std_logic_vector(15 downto 0);
           RD1_out : out std_logic_vector(15 downto 0);
           RD2_out : out std_logic_vector(15 downto 0);
           extImm_out : out std_logic_vector(15 downto 0);
           aluRes_out : out std_logic_vector(15 downto 0);
           memData_out : out std_logic_vector(15 downto 0);
           WD_out : out std_logic_vector(15 downto 0);
           
           cu_aluop_out : out std_logic_vector(1 downto 0); 
           cu_regdst_out : out std_logic;
           cu_extop_out : out std_logic;
           cu_regWrite_out : out std_logic;
           
           cu_branch_out : out std_logic;
           cu_branch_type_out : out std_logic;
           
           cu_jump_out : out std_logic ;
           cu_aluSrcB_out : out std_logic ;
           cu_memWrite_out : out std_logic;
           cu_memToReg_out : out std_logic 
         );
end component;

component SevenSegDisplayer is
    Port ( clk : in STD_LOGIC;
           Digit0 : in STD_LOGIC_VECTOR (3 downto 0);
           Digit1 : in STD_LOGIC_VECTOR (3 downto 0);
           Digit2 : in STD_LOGIC_VECTOR (3 downto 0);
           Digit3 : in STD_LOGIC_VECTOR (3 downto 0);
           Cat : out STD_LOGIC_VECTOR (6 downto 0);
           An : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component MPG is
    Port ( CLK : in STD_LOGIC;
           BTN : in STD_LOGIC;
           EN : out STD_LOGIC := '0');
end component;

signal seven_seg_displayer_signal : std_logic_vector(15 downto 0);
signal rst_mpg : std_logic;
signal clk_mpg : std_logic;

signal instruction_out : std_logic_vector(15 downto 0);
signal next_branch_addr_out : std_logic_vector(15 downto 0);
signal RD1_out : std_logic_vector(15 downto 0);
signal RD2_out : std_logic_vector(15 downto 0);
signal extImm_out : std_logic_vector(15 downto 0);
signal aluRes_out :  std_logic_vector(15 downto 0);
signal memData_out :  std_logic_vector(15 downto 0);
signal WD_out :  std_logic_vector(15 downto 0);

signal cu_aluop_out : std_logic_vector(1 downto 0); 
signal cu_regdst_out : std_logic;
signal cu_extop_out : std_logic;
signal cu_regWrite_out : std_logic;
signal cu_branch_out : std_logic;
signal cu_branch_type_out : std_logic;
signal cu_jump_out :  std_logic;
signal cu_aluSrcB_out : std_logic;
signal cu_memWrite_out : std_logic;
signal cu_memToReg_out : std_logic;

begin

MPG1: mpg port map ( clk => clk_sig, btn => clk, en => clk_mpg);
MPG2: mpg port map ( clk => clk_sig, btn => rst, en => rst_mpg); 

SevSegDis: SevenSegDisplayer port map ( clk => clk_sig, 
                    Digit0 => seven_seg_displayer_signal(3 downto 0),
                    Digit1 => seven_seg_displayer_signal(7 downto 4),
                    Digit2 => seven_seg_displayer_signal(11 downto 8),
                    Digit3 => seven_seg_displayer_signal(15 downto 12),
                    cat => cat, an => an);
                    
PipelinedMips : PIPMIPS port map (
            clk => clk_mpg,rst => rst_mpg,     
            instruction_out => instruction_out,
            next_branch_addr_out => next_branch_addr_out,
            RD1_out => RD1_out, RD2_out => RD2_out,
            extImm_out => extImm_out, aluRes_out => aluRes_out,
            memData_out => memData_out, WD_out => wd_out,  
            cu_aluop_out => cu_aluop_out,
            cu_regdst_out => cu_regdst_out,
            cu_extop_out => cu_extop_out,
            cu_regWrite_out => cu_regWrite_out,
            cu_branch_out => cu_branch_out,
            cu_branch_type_out => cu_branch_type_out,
            cu_jump_out => cu_jump_out,
            cu_aluSrcB_out => cu_aluSrcB_out,
            cu_memWrite_out => cu_memWrite_out,
            cu_memToReg_out => cu_memToReg_out);  
                          
mux : process(switches) 
begin
    case switches is
        when "000" => seven_seg_displayer_signal <= instruction_out;
        when "001" => seven_seg_displayer_signal <= next_branch_addr_out;
        when "010" => seven_seg_displayer_signal <= RD1_out;
        when "011" => seven_seg_displayer_signal <= RD2_out;
        when "100" => seven_seg_displayer_signal <= extImm_out;
        when "101" => seven_seg_displayer_signal <= aluRes_out;
        when "110" => seven_seg_displayer_signal <= memData_out;
        when "111" => seven_seg_displayer_signal <= WD_out;
        when others => seven_seg_displayer_signal <= x"0000";
    end case;
end process;

leds(1 downto 0) <= cu_aluop_out; 
leds(2) <= cu_regdst_out;
leds(3) <= cu_extop_out;
leds(4) <= cu_regWrite_out;
leds(5) <= cu_branch_out;
leds(6) <= cu_branch_type_out;
leds(7) <= cu_jump_out;
leds(8) <= cu_aluSrcB_out;
leds(9) <= cu_memWrite_out;
leds(10) <= cu_memToReg_out;
leds(15 downto 11) <= "00000";

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_disp is
  Port (
        info : in std_logic_vector ( 63 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        outp: out std_logic_vector ( 15 downto 0)
   );
end seven_seg_disp;

architecture Behavioral of seven_seg_disp is
component mux_8to1_8bit is
    Port ( 
        in1 : in std_logic_vector(7 downto 0);
        in2 : in std_logic_vector(7 downto 0);
        in3 : in std_logic_vector(7 downto 0);
        in4 : in std_logic_vector(7 downto 0);
        in5 : in std_logic_vector(7 downto 0);
        in6 : in std_logic_vector(7 downto 0);
        in7 : in std_logic_vector(7 downto 0);
        in8 : in std_logic_vector(7 downto 0);
        s : in std_logic_vector(2 downto 0);
        outp : out std_logic_vector(7 downto 0)
    );
end component mux_8to1_8bit;

signal cnt : std_logic_vector(2 downto 0):="000";
signal clock_div : integer range 0 to 12499 := 0;
signal selected_digit : std_logic_vector ( 7 downto 0);
signal selected_anodes: std_logic_vector ( 7 downto 0);
begin

c0: mux_8to1_8bit port map ( in1 => info( 63 downto 56) , in2 => info( 55 downto 48), in3 => info(47 downto 40),
                             in4 => info(39 downto 32)  , in5 => info( 31 downto 24), in6 => info(23 downto 16),
                             in7 => info(15 downto 8)   , in8 => info(7 downto 0), s => cnt, outp => selected_digit );

outp (15 downto 8) <= selected_digit;
outp(7 downto 0) <= selected_anodes;

process(clk, rst)
begin
    if rst = '1' then
        cnt <= "000";
        clock_div <= 0;
    elsif rising_edge(clk) then
        if clock_div = 12499  then
            clock_div <= 0;
            cnt <= std_logic_vector ( unsigned ( cnt) + 1);
        else
            clock_div <= clock_div + 1;
        end if;
        selected_anodes <= (others => '1'); 
        selected_anodes(to_integer(unsigned(cnt))) <= '0'; 
    end if;
end process;

end Behavioral;

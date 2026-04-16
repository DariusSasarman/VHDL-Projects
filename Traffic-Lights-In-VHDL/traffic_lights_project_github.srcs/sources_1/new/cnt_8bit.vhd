library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cnt_8bit is
  Port ( 
         load_info : in std_logic_vector ( 7 downto 0);
         load : in std_logic;
         en : in std_logic;
         clk : in std_logic;
         rst : in std_logic;
         outp : out std_logic_vector (7 downto 0)
  );
end cnt_8bit;

architecture Behavioral of cnt_8bit is

signal internal_state : std_logic_vector ( 7 downto 0) := x"FF";

begin

outp <= internal_state;

process(clk, rst)
begin
    if(rst = '1') then
        internal_state <= x"FF";
    elsif ( load = '1' ) then
        internal_state <= load_info;
    elsif(rising_edge (clk)) then
        if( en = '1') then
            internal_state <= std_logic_vector( ( UNSIGNED(internal_state)) -1);
        end if;
    end if;
end process;

end Behavioral;

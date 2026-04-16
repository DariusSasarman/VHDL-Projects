library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity d_flip_flop is
    Port ( D : in STD_LOGIC;
           Clk : in STD_LOGIC; 
           Set : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Q : out STD_LOGIC;
           NQ : out STD_LOGIC);
end d_flip_flop;

architecture Behavioral of d_flip_flop is

signal internal_state : std_logic := '0';

begin

Q <= internal_state;
NQ<= not internal_state;

process(clk, Set, Reset)
begin
    if(Reset = '1') then
        internal_state <= '0';
    elsif( Set = '1') then
        internal_state <= '1';
    elsif(rising_edge (clk)) then
        internal_state <= D;
    end if;
end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_divider_1hz is
  Port ( 
        clk : in std_logic;
        rst : in std_logic;
        en : out std_logic
  );
end clk_divider_1hz;

architecture Behavioral of clk_divider_1hz is

signal count : integer := 0;
signal state : std_logic := '0';

begin

en <= state;

process(clk,rst)
begin
    if(rst ='1') then
        count <= 0;
        state <='0';
    elsif(rising_edge(clk)) then
        if(count = 49999999) then
            state <= not state;
            count <= 0;
        else 
            count <= count +1;
        end if;
    end if;
end process;

end Behavioral;

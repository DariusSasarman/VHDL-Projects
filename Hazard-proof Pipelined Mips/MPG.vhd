library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.All ;

entity MPG is
    Port ( CLK : in STD_LOGIC;
           BTN : in STD_LOGIC;
           EN : out STD_LOGIC := '0');
end MPG;

architecture Behavioral of MPG is

signal count : std_logic_vector(15 downto 0) := (others => '0');
signal en1 : std_logic := '0';
signal q1 : std_logic := '0';
signal q2 : std_logic := '0';
signal q3 : std_logic := '0';
signal q4 : std_logic := '0';
signal outp : std_logic := '0';

begin

counter1 : process(clk)
begin
    if rising_edge(clk) then
        if count = x"FFFF" then
            en1 <= '1';
            count <= (others => '0');
        else
            en1 <= '0';
            count <= std_logic_vector(unsigned(count) + 1);
        end if;
    end if;
end process;

dff1 : process(clk)
begin
    if rising_edge(clk) then
        if en1 = '1' then
            q1 <= BTN;
        end if;
    end if;
end process;


dff2 : process(clk)
begin
    if rising_edge(clk) then
        q2 <= q1;
    end if;
end process;


dff3 : process(clk)
begin
    if rising_edge(clk) then
        q3 <= q2;
    end if;
end process;

q4 <= q2 and not q3;

EN <= q4;

end Behavioral;
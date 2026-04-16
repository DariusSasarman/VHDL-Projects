library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2to1_8bit is
  Port (
    in1 : in std_logic_vector ( 7 downto 0);
    in2 : in std_logic_vector ( 7 downto 0);
    s : in std_logic;
    outp : out std_logic_vector (7 downto 0)
   );
end mux_2to1_8bit;

architecture Behavioral of mux_2to1_8bit is

begin

outp <= in1 when s='0' else in2;

end Behavioral;

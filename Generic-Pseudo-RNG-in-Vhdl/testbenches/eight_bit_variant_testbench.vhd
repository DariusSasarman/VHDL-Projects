library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity test is
end test;

architecture Behavioral of test is
    component pseudo_rng is
  Generic (
        length : integer := 16
   );
  Port (
        seed : in std_logic_vector ( length - 1 downto 0);
        clk : in std_logic;
        outp : out std_logic_vector ( length -1 downto 0)
   );
end component pseudo_rng;

constant length : integer := 8;
signal seedt :  std_logic_vector ( length - 1 downto 0) := (others =>'0');
signal clkt :  std_logic := '0';
signal outpt :  std_logic_vector ( length -1 downto 0) := (others => '0');
begin

clkt <= not clkt after 1ns;

uut : pseudo_rng generic map ( length => 8) port map ( seed => seedt, clk => clkt, outp => outpt);

end Behavioral;

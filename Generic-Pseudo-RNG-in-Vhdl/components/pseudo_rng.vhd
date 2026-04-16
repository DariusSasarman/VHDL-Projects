library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity pseudo_rng is
  Generic (
        length : integer := 16
   );
  Port (
        seed : in std_logic_vector ( length - 1 downto 0);
        clk : in std_logic;
        outp : out std_logic_vector ( length -1 downto 0)
   );
end pseudo_rng;

architecture Behavioral of pseudo_rng is

component d_flip_flop is
    Port ( D : in STD_LOGIC;
           Clk : in STD_LOGIC; 
           Set : in STD_LOGIC;
           Reset : in STD_LOGIC;
           Q : out STD_LOGIC;
           NQ : out STD_LOGIC);
end component d_flip_flop;

component dmux_2to1_1bit is
    Port ( Inp : in STD_LOGIC;
           S : in STD_LOGIC;
           O0 : out STD_LOGIC;
           O1 : out STD_LOGIC);
end component dmux_2to1_1bit;

signal feedback : std_Logic :=  '0';
signal all_zero : std_logic :=  '0';
signal internal_ties : std_logic_vector ( length downto 0) := (others => '0');
signal dmux0_outp : std_logic_vector ( length -1 downto 0) := (others => '0');
signal dmux1_outp : std_logic_vector ( length -1 downto 0) := (others => '0');
signal seed_state : std_logic_vector ( length -1 downto 0) := (others => '0');
signal seed_prev  : std_logic_vector (length - 1 downto 0) := (others => '0');

begin

feedback <= internal_ties(0) xor internal_ties( length -1) xor internal_ties((length-1)/2);
internal_ties(length) <= feedback;
outp <= internal_ties( length-1 downto 0);

process ( internal_ties)
    variable result : std_logic := '0';
begin
    result := '0';
    for i in length-1 downto 0 loop
        result := result or internal_ties(i);
    end loop;
    all_zero <= not result;
    
end process;

process(clk)
begin
    if(rising_edge(clk)) then
        if seed_prev /= seed then
            seed_state <= seed;
        elsif all_zero = '1' then
            seed_state <= std_logic_vector(unsigned(seed_state) + 1);
        else
            seed_state <= seed_state;
        end if;
        seed_prev <= seed;
    end if;
end process;

gen : for i in length - 1 downto 0 generate
    dmux:  dmux_2to1_1bit port map ( Inp => all_zero, s => seed_state(i), O0 => dmux0_outp(i), O1 => dmux1_outp(i));
    dffs:  d_flip_flop port map ( D => internal_ties(i+1), clk => clk, set => dmux1_outp(i), reset => dmux0_outp(i), Q => internal_ties(i), NQ => open);
end generate;


end Behavioral;

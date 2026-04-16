library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Execution_Unit is
  Port (
        clk : in std_logic;
        rst : in std_logic;
        ped_time : in std_logic_vector ( 7 downto 0);
        car_time : in std_logic_vector ( 7 downto 0);
        car_or_ped : in std_logic;
        load : in std_logic;
        seven_seg_info : out std_logic_vector ( 15 downto 0);
        current_count : out std_Logic_vector ( 7 downto 0)
   );
end Execution_Unit;

architecture Behavioral of Execution_Unit is

component cnt_8bit is
  Port ( 
         load_info : in std_logic_vector ( 7 downto 0);
         load : in std_logic;
         en : in std_logic;
         clk : in std_logic;
         rst : in std_logic;
         outp : out std_logic_vector (7 downto 0)
  );
end component cnt_8bit;

component clk_divider_1hz is
  Port ( 
        clk : in std_logic;
        rst : in std_logic;
        en : out std_logic
  );
end component clk_divider_1hz;
component dmux_1to2_1bit is
  Port (
        inp : in std_logic;
        s : in std_Logic;
        out1: out std_logic;
        out2: out std_logic
   );
end component dmux_1to2_1bit;

component mux_2to1_8bit is
  Port (
    in1 : in std_logic_vector ( 7 downto 0);
    in2 : in std_logic_vector ( 7 downto 0);
    s : in std_logic;
    outp : out std_logic_vector (7 downto 0)
   );
end component mux_2to1_8bit;

component ROM_8bit_to_7seg is
  Port (
        inp : in std_logic_vector ( 7 downto 0);
        outp: out std_logic_vector( 63 downto 0)
   );
end component ROM_8bit_to_7seg;

component seven_seg_disp is
  Port (
        info : in std_logic_vector ( 63 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        outp: out std_logic_vector ( 15 downto 0)
   );
end component seven_seg_disp;

signal car_en : std_logic := '1';
signal ped_en : std_logic := '1';
signal clk_divided : std_logic := '1';
signal car_clk : std_logic := '1';
signal ped_clk : std_logic := '1';
signal mux_feed1: std_logic_vector ( 7 downto 0):= x"FF";
signal mux_feed2: std_logic_vector ( 7 downto 0):= x"FF";
signal rom_feed : std_logic_vector ( 7 downto 0) := x"FF";
signal rom_output : std_logic_vector ( 63 downto 0);

begin

car_en <= not car_or_ped;
ped_en <= car_or_ped;
current_count <= rom_feed;
cnt1: cnt_8bit port map ( load_info => car_time, load => load, en => car_en, clk => clk_divided, rst => rst, outp => mux_feed1); 
cnt2: cnt_8bit port map ( load_info => ped_time, load => load, en => ped_en, clk => clk_divided, rst => rst, outp => mux_feed2); 
clk_div: clk_divider_1hz port map ( clk => clk, rst => rst, en => clk_divided);
mux: mux_2to1_8bit port map ( in1 => mux_feed1, in2 => mux_feed2, s => car_or_ped, outp => rom_feed);
rom: ROM_8bit_to_7seg port map ( inp => rom_feed, outp => rom_output);
seg7: seven_seg_disp port map ( info => rom_output, clk => clk, rst => rst, outp => seven_seg_info);

end Behavioral;

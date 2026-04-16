
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity traffic_light is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           pedestrian_time : in std_logic_vector ( 7 downto 0);
           car_time : in std_logic_vector ( 7 downto 0);
           s : out STD_LOGIC_VECTOR (7 downto 0);
           AN : out STD_LOGIC_VECTOR (7 downto 0);
           pedestrian_r : out STD_LOGIC;
           pedestrian_g : out STD_LOGIC;
           car_r : out STD_LOGIC;
           car_g : out STD_LOGIC);
end traffic_light;

architecture Behavioral of traffic_light is

component Control_Unit is
    Port ( 
        --outside inputs
        pedestrian_time : in std_logic_vector ( 7 downto 0);
        car_time : in std_logic_vector ( 7 downto 0);
        clk : in std_logic;
        rst : in std_logic;
        --outside outputs
        seven_seg_outp : out std_logic_vector ( 15 downto 0);
        car_r : out std_logic;
        car_g : out std_logic;
        ped_r : out std_logic;
        ped_g : out std_logic;
        --E.U. inputs
        seven_seg_info : in std_logic_vector ( 15 downto 0);
        current_count : in std_Logic_vector ( 7 downto 0);
        --E.U. outputs
        ped_time_eu : out std_logic_vector ( 7 downto 0);
        car_time_eu : out std_logic_vector ( 7 downto 0);
        reset_eu : out std_logic;
        car_or_ped : out std_logic; -- 0 = car, 1 = pedestrian
        load_cnt_values : out std_logic
    );
end component Control_Unit;

component Execution_Unit is
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
end component Execution_Unit;

signal seven_seg_total_info: std_logic_vector (15 downto 0);---dont forget the outputs
signal seven_seg_EU : std_logic_vector (15 downto 0);
signal count_EU : std_logic_vector (7 downto 0);
signal ped_EU : std_logic_vector (7 downto 0);
signal car_EU : std_logic_vector (7 downto 0);
signal RST_EU : std_logic;
signal car_or_ped_EU : std_logic;
signal load_EU : std_logic;

begin

s <= seven_seg_total_info ( 15 downto 8);
AN <= seven_seg_total_info ( 7 downto 0);

CU: Control_Unit port map ( pedestrian_time => pedestrian_time, car_time => car_time, clk => clk,
                            rst => rst, seven_seg_outp => seven_seg_total_info, car_r => car_r,
                            car_g => car_g, ped_r => pedestrian_r, ped_g => pedestrian_g, seven_seg_info => seven_seg_EU,
                            current_count => count_EU, ped_time_eu => ped_EU, car_time_eu => car_EU,
                            reset_eu => RST_EU, car_or_ped => car_or_ped_EU, load_cnt_values => load_EU);
EU: Execution_Unit port map ( clk => clk, rst => RST_EU, ped_time => ped_EU, car_time => car_EU, 
                            car_or_ped => car_or_ped_EU,load => load_EU, seven_seg_info => seven_seg_EU,
                            current_count => count_EU);

end Behavioral;

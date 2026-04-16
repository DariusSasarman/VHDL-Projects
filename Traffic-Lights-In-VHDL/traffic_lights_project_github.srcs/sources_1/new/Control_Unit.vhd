library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control_Unit is
  Port ( 
    -- outside inputs
    pedestrian_time  : in  std_logic_vector(7 downto 0);
    car_time         : in  std_logic_vector(7 downto 0);
    clk              : in  std_logic;
    rst              : in  std_logic;
    -- outside outputs
    seven_seg_outp   : out std_logic_vector(15 downto 0);
    car_r            : out std_logic;
    car_g            : out std_logic;
    ped_r            : out std_logic;
    ped_g            : out std_logic;
    -- E.U. inputs
    seven_seg_info   : in  std_logic_vector(15 downto 0);
    current_count    : in  std_logic_vector(7 downto 0);
    -- E.U. outputs
    ped_time_eu      : out std_logic_vector(7 downto 0);
    car_time_eu      : out std_logic_vector(7 downto 0);
    reset_eu         : out std_logic;
    car_or_ped       : out std_logic;  -- 0 = car, 1 = pedestrian
    load_cnt_values  : out std_logic
  );
end Control_Unit;

architecture Behavioral of Control_Unit is

  type state_type is ( RESTART, GREENCAR, YELLOWCAR, REDCAR );
  signal state : state_type := RESTART;

  -- counters to pass to the Execution Unit
  signal ped  : std_logic_vector(7 downto 0) := (others => '0');
  signal car  : std_logic_vector(7 downto 0) := (others => '0');
  signal car_or_ped_buf : std_logic := '0';
begin

  -- drive EU inputs
  ped_time_eu <= ped;
  car_time_eu <= car;
  car_or_ped <= car_or_ped_buf;
  process(clk, rst)
  begin
    if rst = '1' then
      -- Asynchronous reset: drive *every* output to a known state
      state           <= RESTART;
      ped             <= pedestrian_time;
      car             <= car_time;
      reset_eu        <= '1';
      load_cnt_values <= '1';
      seven_seg_outp  <= x"FFFF";
      car_g           <= '0';
      car_r           <= '0';
      ped_g           <= '0';
      ped_r           <= '0';
      car_or_ped_buf  <= '0';

    elsif rising_edge(clk) then
      ----------------------------------------------------------------
      -- Defaults: safe "hold" or "off" values for everything
      reset_eu        <= '0';
      load_cnt_values <= '0';
      seven_seg_outp  <= seven_seg_info;
      ped             <= ped;       -- hold last value
      car             <= car;
      car_or_ped_buf  <= '0';
      ----------------------------------------------------------------

      case state is
        when RESTART =>
          -- Reload pedestrian_time & car_time into EU
          ped            <= pedestrian_time;
          car            <= car_time;
          load_cnt_values<= '1';   -- tell the counter to grab the new values
          car_g          <= '0';
          car_r          <= '0';
          ped_g          <= '0';
          ped_r          <= '0';
          car_or_ped_buf <= '0';
          state          <= GREENCAR;

        when GREENCAR =>
          ped_g     <= '0';
          ped_r     <= '1';
          car_g     <= '1';
          car_r     <= '0';
          car_or_ped_buf <= '0';
          if TO_INTEGER (unsigned(current_count)) <= 10 then
            state    <= YELLOWCAR;
          end if;

        when YELLOWCAR =>
          ped_g     <= '0';
          ped_r     <= '1';
          car_g     <= '1';
          car_r     <= '1';
          car_or_ped_buf <= '0';
          if current_count = x"00" then
            car_or_ped_buf <= '1';
            state      <= REDCAR;
          end if;

        when REDCAR =>
          ped_g     <= '1';
          ped_r     <= '0';
          car_g     <= '0';
          car_r     <= '1';
          if (current_count = x"00" and car_or_ped_buf = '1') then
            state    <= RESTART;
          end if;
          car_or_ped_buf <= '1';

      end case;
    end if;
  end process;

end Behavioral;

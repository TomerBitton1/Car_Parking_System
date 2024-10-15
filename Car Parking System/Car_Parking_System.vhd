-- VHDL code for car parking system
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
entity Car_Parking_System_VHDL is
port 
(
  clk,reset: in std_logic; -- Clock and reset of the car parking system
  front_sensor, back_sensor : in std_logic; -- Two sensor in front and behind the gate of the car parking system
  password: in std_logic_vector(1 downto 0); -- Input password, Right password is "01" 
  GREEN_LED,RED_LED: out std_logic -- Signaling LEDs
);
end Car_Parking_System_VHDL;


architecture Behavioral of Car_Parking_System_VHDL is
-- FSM States
type FSM_States is (IDLE,WAIT_PASSWORD,WRONG_PASS,RIGHT_PASS,STOP);
signal current_state,next_state: FSM_States;
signal red_tmp, green_tmp: std_logic;
signal car_count : integer := 0;  -- The number of cars in the parking lot
constant MAX_CARS : integer := 5; -- Maximum number of cars in the parking lot
constant MIN_CARS : integer := 0; -- Minimum number of cars in the parking lot

begin
-- Sequential process for updating car_count and state transitions
process(clk, reset)
begin
 if(reset = '0') then
  car_count <= 0;  -- Reset car count when the system is reset
 elsif(rising_edge(clk)) then
   -- Handle car entering or exiting based on the state transitions
   if current_state = IDLE then
     if (back_sensor = '1' and car_count > MIN_CARS) then
       car_count <= car_count - 1;  -- Car exiting, decrement count
     end if;
   elsif next_state = RIGHT_PASS then
     if car_count < MAX_CARS then
       car_count <= car_count + 1;  -- Car entering, increment count
     end if;
   end if;
   -- Update current_state
   current_state <= next_state;
 end if;
end process;

-- Combinational logic for state transitions
process(current_state, front_sensor, password, back_sensor)
begin
 case current_state is  
  when IDLE =>
    if back_sensor = '1' and car_count > MIN_CARS then -- Car exiting
      next_state <= IDLE;
    elsif (front_sensor = '1' and back_sensor = '0' and car_count < MAX_CARS) then -- Car entering
      next_state <= WAIT_PASSWORD;
    else
      next_state <= IDLE;
    end if;
  
  when WAIT_PASSWORD =>
    if car_count < MAX_CARS then -- If there is enough space in the parking lot
      if (password = "01") then -- Password correct
        next_state <= RIGHT_PASS;
      else
        next_state <= WRONG_PASS;
      end if;
    else
      next_state <= IDLE;  -- Parking lot is full
    end if;
    
  when WRONG_PASS =>
    if (password = "01" and car_count < MAX_CARS) then
      next_state <= RIGHT_PASS;
    else
      next_state <= WRONG_PASS;
    end if;
  
  when RIGHT_PASS =>
    if (front_sensor = '1' and back_sensor = '1') then -- If there is another car at the entrance to the parking lot
      next_state <= STOP;
    else
      next_state <= IDLE;
    end if;

  when STOP =>
    if (password = "01" and car_count < MAX_CARS) then
      next_state <= RIGHT_PASS;
    elsif (password /= "01") then
      next_state <= WRONG_PASS;
    else
      next_state <= IDLE;
    end if;
  
  when others =>
    next_state <= IDLE;
 end case;
end process;


-- output 
 process(clk) -- LED checking
 begin
 if(rising_edge(clk)) then
 case(current_state) is
 when IDLE => 
	green_tmp <= '0';
	red_tmp <= '0';
 
 when WAIT_PASSWORD =>
 if next_state = RIGHT_PASS then
	green_tmp <= '1';
	red_tmp <= '0';
 elsif next_state = WRONG_PASS then
	green_tmp <= '0';
	red_tmp <= '1';
 end if;
 
 when WRONG_PASS =>
 if next_state = RIGHT_PASS then
	green_tmp <= '1';
	red_tmp <= '0';
 elsif next_state = WRONG_PASS then
	green_tmp <= '0'; 
	red_tmp <= '1';
 end if;
 
 when RIGHT_PASS =>
	green_tmp <= '1';
	red_tmp <= '0'; 
 if next_state = STOP then
	green_tmp <= '0';
	red_tmp <= '1';
 elsif next_state = IDLE then
	green_tmp <= '0';
	red_tmp <= '0';
 end if;
 
 when STOP =>
 if next_state = RIGHT_PASS then
	green_tmp <= '1';
	red_tmp <= '0';
 elsif next_state = WRONG_PASS then
	green_tmp <= '0';
	red_tmp <= '1'; 
 end if;
 
 when others => 
	green_tmp <= '0';
	red_tmp <= '0';
 end case;
 end if;
 end process;
 
  RED_LED <= red_tmp  ;
  GREEN_LED <= green_tmp;
end Behavioral;
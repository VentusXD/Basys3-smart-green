library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Pump is
   port(
      En         		: in std_logic;
	  CLK         	    : in std_logic;
      pump_speed        : in std_logic_vector(7 downto 0);
      out_pump          : out std_logic
   );
end Pump;

architecture behavioral of Pump is
Component PWM is 
	port(
	   reset		: in std_logic;
       clk		    : in std_logic; 
       w            : in std_logic_vector(7 downto 0);
       pwm_pulse    : out std_logic);
end component;
   
signal out1 : std_logic ;
	
begin
   
    comp : PWM
        port map(
            reset     => '0',
            clk       => clk,
            w         => pump_speed,
            pwm_pulse => out1
        );
	
    out_Pump <= out1 when (En = '1') else '0';
end behavioral;
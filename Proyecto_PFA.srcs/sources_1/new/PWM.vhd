library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity PWM is
   port(
      reset		   : in std_logic;
      clk		   : in std_logic; 
	  w            : in std_logic_vector(7 downto 0);
      pwm_pulse    : out std_logic
   );
end PWM;

architecture behavioral of PWM is
   signal r_reg: unsigned(7 downto 0);
   signal r_next: unsigned(7 downto 0);
   signal buf_reg: std_logic;
   signal buf_next: std_logic;
begin
   -- register & output buffer
   process(clk,reset)
   begin
      if (reset='1') then
         r_reg <= (others=>'0');
         buf_reg <= '0';
      elsif (clk'event and clk='1') then
         r_reg <= r_next;
         buf_reg <= buf_next;
      end if;
   end process;
   -- next-state logic
   r_next <= r_reg + 1;
   -- output logic
   buf_next <= '1' when (r_reg < unsigned(w)) else '0';
   pwm_pulse <= buf_reg;
end behavioral;
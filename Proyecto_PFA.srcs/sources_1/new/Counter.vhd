Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

Entity Counter is
	generic(busWidth : integer := 8);
	port(
	RST : in std_logic;
	CLK : in std_logic;
	INC : in std_logic;
	CNT : out std_logic_vector(busWidth - 1 downto 0)
	);
end Counter;

Architecture Behavioral of Counter is
signal Cp, Cn : std_logic_vector(busWidth - 1 downto 0);
begin
	Combinational : process(Cp, INC)
	begin
		if INC = '1' then
			Cn <= Cp + 1;
		else
			Cn <= Cp;
		end  if;
		CNT <= Cp;
	end process Combinational;
	Sequential : process(RST, CLK)
	begin
		if RST = '0' then
			Cp <= (others => '0');
		elsif CLK'event and CLK = '1' then
			Cp <= Cn;
		end if;
	end process Sequential;
end Behavioral;
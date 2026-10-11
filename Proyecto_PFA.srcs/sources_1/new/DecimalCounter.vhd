Library IEEE;
use IEEE.std_logic_1164.all;

Entity DecimalCounter is
	port(
	RST : in std_logic;
	CLK : in std_logic;
	ENI : in std_logic;
	ONE : out std_logic_vector(3 downto 0);
	TEN : out std_logic_vector(3 downto 0);
	HUN : out std_logic_vector(3 downto 0);
	THO : out std_logic_vector(3 downto 0)
	);
end DecimalCounter;

Architecture Structural of DecimalCounter is
Component CounterM10 is port(
	RST : in std_logic;
	CLK : in std_logic;
	ENI : in std_logic;
	ENO : out std_logic;
	CNT : out std_logic_vector(3 downto 0));
end Component;
signal EN1, EN2, EN3 : std_logic;
begin
	U01 : CounterM10 port map(RST, CLK, ENI, EN1, ONE);
	U02 : CounterM10 port map(RST, CLK, EN1, EN2, TEN);
	U03 : CounterM10 port map(RST, CLK, EN2, EN3, HUN);
	U04 : CounterM10 port map(RST, CLK, EN3, OPEN, THO);
end Structural;
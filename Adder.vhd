library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
--use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

Entity Adder is
	Generic ( N : natural := 64 );
	Port ( A, B : in std_logic_vector( N-1 downto 0 );
		Y : out std_logic_vector( N-1 downto 0 );
		
		-- Control signals
		Cin : in std_logic;
		
		-- Status signals
		Cout, Ovfl : out std_logic );
End Entity Adder;

architecture rtl of Adder is

	signal output : std_logic_vector(N downto 0);
	signal a_signal : unsigned(N-1 downto 0);
	signal b_signal : unsigned(N-1 downto 0);
	signal cin_signal : unsigned(0 downto 0);

begin

	a_signal <= unsigned(A);
	b_signal <= unsigned(B);
	cin_signal(0) <= Cin;
	
	output <= ('0' & a_signal) +  ('0' & b_signal) + ("0000000000000000000000000000000000000000000000000000000000000000" & cin_signal);
	
	Y <= output(N-1 downto 0);
	Cout <= output(N);
	Ovfl <= output(N) xor output(N-1);


end rtl;
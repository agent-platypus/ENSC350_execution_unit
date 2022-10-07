library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.ALL;

Entity SLL64 is
Generic ( N : natural := 64 );
Port ( X : in std_logic_vector( N-1 downto 0 );
Y : out std_logic_vector( N-1 downto 0 );
ShiftCount : in unsigned( integer(ceil(log2(real(N))))-1 downto 0 ) );
End Entity SLL64;

architecture behavior of SLL64 is

signal x_unsign: unsigned(N-1 downto 0);
signal mux1, mux2: unsigned(N-1 downto 0);

begin
--6 bits used to control the shift count 2^6 = 64
		process(ShiftCount, x_unsign, X)
			begin
		x_unsign <= unsigned(X);
--1st MUX: shift options = 0, 16, 32, 48
	if ShiftCount(5 downto 4) = "00" then
	mux1 <= X_unsign;
	
	elsif ShiftCount(5 downto 4) = "01" then
	--shift 16
	mux1 <= shift_left(X_unsign, 16);
	
	elsif ShiftCount(5 downto 4) = "10" then
	--shift by 32
	mux1 <= shift_left(X_unsign, 32);
	
	elsif ShiftCount(5 downto 4) = "11" then
	--shift by 48
	mux1 <= shift_left(X_unsign, 48);
	else
		mux1 <= x_unsign;
	end if;
end process;

--2nd MUX: shift options = 0, 4, 8, 12
process(ShiftCount, mux1)
	begin
	if ShiftCount(3 downto 2) = "00" then
	mux2 <= mux1;
	
	elsif ShiftCount(3 downto 2) = "01" then
	--shift by 4
	mux2 <= shift_left(mux1, 4);
	
	elsif ShiftCount(3 downto 2) = "10" then
	--shift by 8
	mux2 <= shift_left(mux1, 8);
	
	elsif ShiftCount(3 downto 2) = "11" then
	--shift by 12
	mux2 <= shift_left(mux1, 12);
	else
	mux2 <= mux1;
	end if;
end process;

process(ShiftCount, mux2)
	begin
--3rd MUX: shift options = 0, 1, 2, 3
	if ShiftCount(1 downto 0) = "00" then
	--shift by 0
	Y <= std_logic_vector(mux2);
	
	elsif ShiftCount(1 downto 0) = "01" then
	--shift by 1
	Y <= std_logic_vector(shift_left(mux2, 1));
	
	elsif ShiftCount(1 downto 0) = "10" then
	--shift by 2
	Y <= std_logic_vector(shift_left(mux2, 2));
	
	elsif ShiftCount(1 downto 0) = "11" then
	--shift by 3
	Y <= std_logic_vector(shift_left(mux2, 3));
	else
	Y <= std_logic_vector(mux2);
	end if;
	
end process;

end behavior;
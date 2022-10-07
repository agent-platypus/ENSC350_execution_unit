library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
--use ieee.numeric_std.resize;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.nor_reduce;
use ieee.math_real.all;

Entity ArithUnit is

	Generic ( N : natural := 64 );
	Port ( A, B : in std_logic_vector( N-1 downto 0 );
		AddY, Y : out std_logic_vector( N-1 downto 0 );
		
	-- Control signals
		AddnSub, ExtWord : in std_logic := '0';
		
	-- Status signals
		Cout, Ovfl, Zero, AltB, AltBu : out std_logic );
		
End Entity ArithUnit;


architecture rtl of ArithUnit is


	component Adder
		generic ( N : natural := 64 );
		port ( A, B : in std_logic_vector( N-1 downto 0 );
		Y : out std_logic_vector( N-1 downto 0 );
		
		-- Control signals
		Cin : in std_logic;
		
		-- Status signals
		Cout, Ovfl : out std_logic );
	end component;
	
	--signal A_sig : std_logic_vector(63 downto 0); --Signals that are going to connect to A
	signal B_sig : std_logic_vector(63 downto 0); --Signals that are going to connect to B
	signal AddY_sig : std_logic_vector(63 downto 0); --Signals that are going to connect to the output of the Adder circuit
	signal Cout_sig : std_logic;
	signal Ovfl_sig : std_logic;
	
	signal B_mux : std_logic_vector(63 downto 0); --B will be connected to this signal and change depending on control signals
	signal Y_mux : std_logic_vector(63 downto 0); --Y will be connected to this signal and change depending on control signals
	
begin

	adder1: Adder 
		generic map(N => 64)
		port map( A => A, B => B_mux, Y => AddY_sig, Cin => AddnSub, Cout => Cout_sig, Ovfl => Ovfl_sig);
		
	B_sig <= B;
	AddY <= AddY_sig;
	Y <= Y_mux;
	Cout <= Cout_sig;
	Zero <= nor_reduce(AddY_sig);
	Ovfl <= Ovfl_sig; --Overflow for arith
	
	
	
	
	process(AddnSub, B_sig)
		begin
		
		if(AddnSub = '1') then 
			B_mux <= not B_sig;
		else 
			B_mux <= B_sig;
			
		end if;
			
	end process;
	
	
	process(ExtWord, AddY_sig)
		begin
			
			if(ExtWord = '1') then
				Y_mux <= AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31) & AddY_sig(31 downto 0);
				--Y_mux <= std_logic_vector(resize(signed(AddY_sig(31 downto 0)), Y_mux'length));
			else
				Y_mux <= AddY_sig;
			end if;
				
	end process;
	
	
	process(Cout_sig, Ovfl_sig, AddY_sig(63))
		begin
		
		if(AddY_sig(63) /= Ovfl_sig) then
			AltB <= '1';
		else
			AltB <= '0';
		end if;
		
		if(Cout_sig = '0') then
			AltBu <= '1';
		else
			AltBu <= '0';
		end if;
		
	end process;
	

end rtl;






















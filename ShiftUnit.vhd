library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.ALL;


Entity ShiftUnit is
	Generic ( N : natural := 64 );
	Port ( 	A, B, C : in std_logic_vector( N-1 downto 0 );
	--C comes from the adder unit---
	---- A to be shifted by count from B---
						Y : out std_logic_vector( N-1 downto 0 );
				ShiftFN : in std_logic_vector( 1 downto 0 );
				ExtWord : in std_logic );
				
End Entity ShiftUnit;

architecture rtl of ShiftUnit is

--SLL64 unit--------
component SLL64
Generic ( N : natural := 64 );
Port ( X : in std_logic_vector( N-1 downto 0 );
Y : out std_logic_vector( N-1 downto 0 );
ShiftCount : in unsigned( integer(ceil(log2(real(N))))-1 downto 0 ) );
end component;
--------------------------

----SRL64 unit-------
component SRL64 
Generic ( N : natural := 64 );
Port ( X : in std_logic_vector( N-1 downto 0 );
Y : out std_logic_vector( N-1 downto 0 );
ShiftCount : in unsigned(integer(ceil(log2(real(N))))-1 downto 0 ) );
end component;
---------------------


---SRA64 unit----------
component SRA64
Generic ( N : natural := 64 );
Port ( X : in std_logic_vector( N-1 downto 0 );
Y : out std_logic_vector( N-1 downto 0 );
ShiftCount : in unsigned(integer(ceil(log2(real(N))))-1 downto 0 ) );
end component;
---------------------

-----shifter output signals------
signal SRLout, SLLout, SRAout: std_logic_vector(N-1 downto 0);
---------

--1st multiplexor that takes in A and outputs to the 3 shifters
signal muxA: std_logic_vector( N-1 downto 0);
signal muxA_con: std_logic;
--------------

--mux output for adder and sll output--
signal muxB: std_logic_vector(N-1 downto 0);
-------------------------------------

--mux output for SRL and SRA--
signal muxC: std_logic_vector(N-1 downto 0);
-------------------------------------

--mux output for PassmuxC or SgnExtLower--
signal muxD: std_logic_vector(N-1 downto 0);
-------------------------------------

--mux output for PassMuxB or SgnExtUpper--
signal muxE: std_logic_vector(N-1 downto 0);
-------------------------------------

signal B_mask_shift: std_logic_vector(5 downto 0); 

begin

-------masking operation------------
mask: process(ExtWord, B)
	begin
		if ExtWord = '1' then
			B_mask_shift <= '0' & B(4 downto 0);
		else
			B_mask_shift <= B(5 downto 0);
		end if;
	end process;
----****************************--------------


-----1st MUX that takes in A operand---------
	moxA: process(A, ShiftFN(1), ExtWord, muxA_con)
			begin 
			muxA_con <= ShiftFN(1) and ExtWord;
				if muxA_con = '0' then
					muxA <= A;
				else
					muxA <= A(31 downto 0) & A(63 downto 32);
				end if;
			end process;
------------------


----port mapping components---------
shift_LL: SLL64
	generic map(N => 64)
	port map(X => muxA, Y => SLLout, ShiftCount => unsigned(B_mask_shift));

shift_RL: SRL64
	generic map(N => 64)
	port map(X => muxA, Y => SRLout, ShiftCount => unsigned(B_mask_shift));

shift_RA: SRA64
	generic map(N => 64)
	port map(X => muxA, Y => SRAout, ShiftCount => unsigned(B_mask_shift));
--************************************----


---MUX for adder output and sll output---
moxB_and_SLL64: process(C, ShiftFN(0), SLLout)
	begin
		if(ShiftFN(0) = '1') then
			muxB <= SLLout;
		else 
			muxB <= C;
	end if;
end process;
--------------------------	
		
---MUX for SRL and SRA---
moxC_and_SRop: process(SRLout, ShiftFN(0), SRAout)
	begin
		if(ShiftFN(0) = '1') then
			muxC <= SRAout;
		else 
			muxC <= SRLout;
	end if;
end process;
--------------------------	

moxD: process(ExtWord, muxB)
	begin
		if(ExtWord = '1') then
			muxD <= std_logic_vector(resize(signed(muxB(31 downto 0)), muxD'length));---signextend lower???----;
		else
			muxD <= muxB;
		end if;
end process;

moxE: process(ExtWord, muxC)
	begin
		if(ExtWord = '1') then
			muxE <= std_logic_vector(resize(signed(muxC(63 downto 32)), muxE'length));---signextend upper???----;
		else
			muxE <= muxC;
		end if;
end process;

final_mux: process(ShiftFN(1), muxD, muxE)
	begin
		if(ShiftFN(1) = '1') then
			Y <= muxE;
		else 
			Y <= muxD;
		end if;
	end process;


end rtl;
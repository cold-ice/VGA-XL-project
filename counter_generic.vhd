library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity counter_generic is
generic (N : integer);
	port (
		clk     : in std_logic;
		rst     : in std_logic;
		clear   : in std_logic;
		en      : in std_logic;
		end_val : in std_logic_vector(N-1 downto 0);
		cnt_out : out std_logic_vector(N-1 downto 0);
		tc      : out std_logic
);
end entity counter_generic;

architecture rtl of counter_generic is
signal count: std_logic_vector(N-1 downto 0);
begin

--@Description: synchronous process
--@that...
--@
process (clk, rst, en, clear)
--variable count: std_logic_vector(N-1 downto 0) := (others => '0');
begin
  if (rst = '0' or clear = '0') then
    count <= (others => '0');
    tc <= '0';
  elsif (falling_edge(clk)) then
    if (en = '1') then
      if (count = end_val) then
        tc <= '1';
        count <= (others => '0');
      else
        count <= count + 1;
        tc <= '0';
      end if;
    end if; --en
  end if; --rst
end process;

cnt_out <= count;

end architecture rtl;

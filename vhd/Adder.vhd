library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADDER is

  port(DATA_IN0 : in  signed(15 downto 0);
       DATA_IN1 : in  signed(15 downto 0);
       C0       : in  std_logic;
       DATA_OUT : out signed(15 downto 0)
       );

end ADDER;

architecture behavioural of ADDER is

  signal SUM, SUBTRACTION : signed(15 downto 0);

begin

  with C0 select DATA_OUT <= SUM when '0',
                             SUBTRACTION when '1',
                             SUM         when others;

  SUM         <= DATA_IN0 + DATA_IN1;
  SUBTRACTION <= DATA_IN0 - DATA_IN1;

end behavioural;

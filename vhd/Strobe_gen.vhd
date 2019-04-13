library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity STROBE_GEN is

  generic (DIVIDER : integer);
  port(CLOCK_50 : in  std_logic;
       EN       : in  std_logic;
       STROBE   : out std_logic
       );

end STROBE_GEN;

architecture behavioural of STROBE_GEN is

  signal STROBE_BUFFER, FLAG : std_logic := '0';

begin

  STROBE <= STROBE_BUFFER;

  Strobe_gen : process(EN, CLOCK_50)
  begin
    if(EN = '0') then
      STROBE_BUFFER <= '0';
    elsif(FALLING_EDGE(CLOCK_50)) then
      STROBE_BUFFER <= not STROBE_BUFFER;
    end if;

  end process;

end behavioural;

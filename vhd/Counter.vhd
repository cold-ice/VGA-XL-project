library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity COUNTER is

  generic (MAX   : integer;
           DEBUG : integer);
  port(STROBE : in  std_logic;
       EN     : in  std_logic;
       CL     : in  std_logic;
       COUNT  : out integer range 0 to MAX
       );

end COUNTER;

architecture behavioural of COUNTER is

  signal COUNT_BUFFER : integer range 0 to MAX := DEBUG;

begin

  COUNT <= COUNT_BUFFER;

  Counter : process(STROBE, EN, CL)
  begin
    if(EN = '1') then
      if(RISING_EDGE(STROBE)) then
        if(COUNT_BUFFER < MAX) then
          COUNT_BUFFER <= COUNT_BUFFER+1;
        else
          COUNT_BUFFER <= 0;
        end if;
      end if;
    elsif(CL = '1') then
      COUNT_BUFFER <= 0;
      --ELSE

    end if;

  end process;

end behavioural;

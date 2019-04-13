library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REGISTER_32BIT is

  port(STROBE  : in  std_logic;
       EN      : in  std_logic;
       CL      : in  std_logic;
       COUNT_X : out integer range 0 to 797
       );

end REGISTER_32BIT;

architecture behavioural of REGISTER_32BIT is

  signal COUNT_BUFFER : integer range 0 to 797 := 0;

begin

  COUNT_X <= COUNT_BUFFER;

  Counter : process(STROBE, EN, CL)
  begin
    if(EN = '1') then
      if(FALLING_EDGE(STROBE)) then
        if(COUNT_BUFFER < 797) then
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

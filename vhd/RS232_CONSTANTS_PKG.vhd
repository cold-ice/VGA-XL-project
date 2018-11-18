library ieee;
use ieee.std_logic_1164.all;

package RS232_CONSTANTS_PKG is

constant NBITS_REG_8 : integer := 8;
constant NBITS_REG_16 : integer := 16;
constant NBITS_DEMUX_1TO6 : integer := 8;
constant NBITS_COUNTER : integer := 3;
constant END_VAL_CNT : std_logic_vector(NBITS_COUNTER-1 downto 0):= "110";

end package RS232_CONSTANTS_PKG;
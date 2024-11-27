----------------------------------------------------------------------------------

-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong

-- Engineer:

-- 

-- Create Date: 09/09/2022 06:20:56 PM

-- Design Name: system top

-- Module Name: uart

-- Project Name: Music Decoder

-- Target Devices: Xilinx Basys3

-- Tool Versions: Vivado 2022.1

-- Description: 

-- 

-- Dependencies: 

-- 

-- Revision:

-- Revision 0.01 - File Created

-- Additional Comments:

-- 

----------------------------------------------------------------------------------



-- Uncomment the following library declaration if instantiating

-- any Xilinx leaf cells in this code.

--library UNISIM;

--use UNISIM.VComponents.all;

library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;



entity myuart is

    Port ( 

           din  : in  STD_LOGIC_VECTOR (7 downto 0); -- 8-bit data input

           busy : out STD_LOGIC;                    -- UART busy flag

           wen  : in  STD_LOGIC;                    -- Write enable (1 cycle pulse)

           sout : out STD_LOGIC;                    -- Serial output

           clr  : in  STD_LOGIC;                    -- Asynchronous clear

           clk  : in  STD_LOGIC                     -- 96kHz clock input

    );

end myuart;



architecture rtl of myuart is

    -- State definition for UART transmission

    type uart_state_type is (IDLE, DATA_BITS);

    signal state       : uart_state_type := IDLE;

    

    signal baud_counter : unsigned(3 downto 0) := (others => '0'); -- Counter for baud rate (0 to 9)

    signal repeat_counter : unsigned(3 downto 0) := (others => '0'); -- Counter for sent out bits (0 to 9)                       

    

    -- Shift register for data transmission

    signal data_reg     : STD_LOGIC_VECTOR(9 downto 0) := "1000000001";

    signal data_temp    : STD_LOGIC := '1';

    signal data_reg_temp : STD_LOGIC_VECTOR(9 downto 0) := "1000000001";

    

begin



    -- UART transmission state machine

    SYNC_PROC: process(clk, clr)

    begin

        if clr = '1' then

            state <= IDLE;

            baud_counter <= x"0";

            repeat_counter <= x"0";
            
            data_reg(9 downto 0) <= "1000000001";
            
            data_temp <= '1';
            
            sout <= '0';

        elsif rising_edge(clk) then

                case state is

                    when IDLE =>

                        if wen = '1' then

                            data_reg<= '1' & din & '0';  -- Load data into shift register

                            state <= DATA_BITS;



                        end if;



                    when DATA_BITS =>

                            data_temp <= data_reg(0);

                            sout <= data_temp;



                            if (baud_counter = 9) then

                                baud_counter <= x"0";

                                repeat_counter <= repeat_counter +1;



                                if (repeat_counter = 9) then

                                    state <= IDLE;

                                    repeat_counter <= x"0";

                                    

                                else

                                    data_reg(8) <= data_reg(9);

                                    data_reg(7) <= data_reg(8);                            

                                    data_reg(6) <= data_reg(7);

                                    data_reg(5) <= data_reg(6);

                                    data_reg(4) <= data_reg(5);

                                    data_reg(3) <= data_reg(4);

                                    data_reg(2) <= data_reg(3);

                                    data_reg(1) <= data_reg(2);

                                    data_reg(0) <= data_reg(1);

                                end if;

                            else

                                  baud_counter <= baud_counter + 1;  

                            end if;



                end case;

        end if;



    end process;

    

    output_logic: process(state)

    begin

        case state is

            when IDLE => 

                busy <= '0';

            when DATA_BITS =>

                busy <= '1';



        end case;

    end process;

end rtl;
